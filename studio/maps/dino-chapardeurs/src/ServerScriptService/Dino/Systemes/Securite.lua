-- Système Securite : anti-rebond des actions, surveillance du débit réseau, détection grossière de téléportation.
-- Aucune expulsion, aucune correction automatique : on signale seulement (attribut « Suspect » et print).
local Players = game:GetService("Players")

local M = {}

-- valeurs par défaut, remplaçables par Equilibrage.securite si l'équilibrage les définit
local DEFAUTS = {
	messagesParSeconde = 30,   -- au-delà : seconde « excessive » pour ce remote
	secondesExcessives = 5,    -- nombre de secondes excessives consécutives avant signalement
	periodeDeplacement = 0.5,  -- période de contrôle des déplacements
	distanceMax = 120,         -- studs parcourus au plus par période
	teleportRecent = 2,        -- âge maximal (s) de l'attribut TeleportAutorise
	graceApparition = 3,       -- secondes ignorées après l'apparition d'un personnage
	rappelSignalement = 30,    -- délai minimal entre deux print pour un même joueur et un même motif
}

local function reglages(ctx)
	local source = nil
	if ctx.Equilibrage and type(ctx.Equilibrage.securite) == "table" then
		source = ctx.Equilibrage.securite
	end
	local r = {}
	for cle, valeur in pairs(DEFAUTS) do
		local v = source and source[cle]
		if type(v) == "number" and v > 0 then
			r[cle] = v
		else
			r[cle] = valeur
		end
	end
	return r
end

local function estJoueur(objet)
	return typeof(objet) == "Instance" and objet:IsA("Player")
end

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local R = reglages(ctx)

	local dernieresActions = {}   -- [joueur] = { [action] = os.clock() }
	local compteurs = {}          -- [joueur] = { [remote] = messages dans la seconde en cours }
	local secondesTrop = {}       -- [joueur] = { [remote] = secondes excessives consécutives }
	local suivis = {}             -- [joueur] = { personnage, position, apparition }
	local derniersAvis = {}       -- [joueur] = { [motif] = os.clock() }

	local function nomDe(joueur)
		local ok, nom = pcall(function() return joueur.Name .. " (" .. tostring(joueur.UserId) .. ")" end)
		if ok then return nom end
		return "?"
	end

	-- print limité : un même motif n'est répété qu'après R.rappelSignalement secondes
	local function signaler(joueur, motif, texte)
		local avis = derniersAvis[joueur]
		if not avis then
			avis = {}
			derniersAvis[joueur] = avis
		end
		local t = os.clock()
		if avis[motif] and t - avis[motif] < R.rappelSignalement then return end
		avis[motif] = t
		print("[Dino][Securite] " .. nomDe(joueur) .. " : " .. texte)
	end

	-- ===== anti-rebond des actions =====
	Bus.repondre("AutoriserAction", function(joueur, action, intervalle)
		if not estJoueur(joueur) or not joueur.Parent then return false end
		if type(action) ~= "string" then return false end
		if type(intervalle) ~= "number" or intervalle ~= intervalle or intervalle < 0 then
			intervalle = 0.25
		end
		local actions = dernieresActions[joueur]
		if not actions then
			actions = {}
			dernieresActions[joueur] = actions
		end
		local t = os.clock()
		local derniere = actions[action]
		if derniere and t - derniere < intervalle then return false end
		actions[action] = t
		return true
	end)

	-- ===== débit des remotes =====
	local function compter(joueur, nom)
		if not estJoueur(joueur) then return end
		local c = compteurs[joueur]
		if not c then
			c = {}
			compteurs[joueur] = c
		end
		c[nom] = (c[nom] or 0) + 1
	end

	if type(ctx.Reseau) == "table" then
		for nom, remote in pairs(ctx.Reseau) do
			if typeof(remote) == "Instance" and remote:IsA("RemoteEvent") then
				local nomRemote = tostring(nom)
				remote.OnServerEvent:Connect(function(joueur)
					compter(joueur, nomRemote)
				end)
			end
		end
	end

	-- bilan de chaque seconde écoulée
	local function bilanSeconde()
		for joueur, c in pairs(compteurs) do
			if joueur.Parent then
				local trop = secondesTrop[joueur]
				if not trop then
					trop = {}
					secondesTrop[joueur] = trop
				end
				for nom, n in pairs(c) do
					if n > R.messagesParSeconde then
						trop[nom] = (trop[nom] or 0) + 1
						if trop[nom] >= R.secondesExcessives then
							pcall(function() joueur:SetAttribute("Suspect", true) end)
							signaler(joueur, "debit_" .. nom, string.format(
								"remote « %s » inondé (%d messages/s pendant %d s)", nom, n, trop[nom]))
						end
					else
						trop[nom] = 0
					end
				end
			end
		end
		-- remise à zéro : les remotes silencieux cette seconde repartent de zéro
		for joueur, trop in pairs(secondesTrop) do
			local c = compteurs[joueur]
			for nom in pairs(trop) do
				if not c or not c[nom] then trop[nom] = 0 end
			end
		end
		compteurs = {}
	end

	-- ===== déplacements =====
	local function racineDe(personnage)
		if not personnage then return nil end
		local racine = personnage:FindFirstChild("HumanoidRootPart")
		if racine and racine:IsA("BasePart") then return racine end
		return nil
	end

	local function teleportAutorise(joueur, personnage, maintenant)
		local sources = { personnage, joueur }
		for _, objet in ipairs(sources) do
			local ok, valeur = pcall(function() return objet:GetAttribute("TeleportAutorise") end)
			if ok and type(valeur) == "number" and maintenant - valeur < R.teleportRecent and maintenant - valeur > -1 then
				return true
			end
		end
		return false
	end

	local function estPorteur(joueur)
		local porte = joueur:GetAttribute("Porte")
		return type(porte) == "string" and porte ~= ""
	end

	local function controlerDeplacements(duree)
		local maintenant = workspace:GetServerTimeNow()
		local horloge = os.clock()
		-- si la boucle a pris du retard, la distance tolérée grandit d'autant
		local limite = R.distanceMax * math.max(1, duree / R.periodeDeplacement)
		for _, joueur in ipairs(Players:GetPlayers()) do
			local personnage = joueur.Character
			local racine = racineDe(personnage)
			local suivi = suivis[joueur]
			if not racine then
				suivis[joueur] = nil
			elseif not suivi or suivi.personnage ~= personnage then
				suivis[joueur] = { personnage = personnage, position = racine.Position, apparition = horloge }
			else
				local position = racine.Position
				local distance = (position - suivi.position).Magnitude
				local humanoide = personnage:FindFirstChildOfClass("Humanoid")
				local vivant = humanoide == nil or humanoide.Health > 0
				if distance > limite and vivant
					and horloge - suivi.apparition > R.graceApparition
					and not estPorteur(joueur)
					and not teleportAutorise(joueur, personnage, maintenant) then
					signaler(joueur, "teleport", string.format(
						"déplacement suspect de %.0f studs en %.2f s (de %.0f, %.0f, %.0f à %.0f, %.0f, %.0f)",
						distance, duree, suivi.position.X, suivi.position.Y, suivi.position.Z,
						position.X, position.Y, position.Z))
				end
				suivi.position = position
			end
		end
	end

	-- ===== joueurs =====
	local function surJoueur(joueur)
		if joueur:GetAttribute("Suspect") == nil then
			pcall(function() joueur:SetAttribute("Suspect", false) end)
		end
		joueur.CharacterAdded:Connect(function()
			-- nouveau personnage : on repart de zéro, le suivi sera recréé à la prochaine vérification
			suivis[joueur] = nil
		end)
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(surJoueur, joueur)
	end
	Players.PlayerAdded:Connect(surJoueur)
	Players.PlayerRemoving:Connect(function(joueur)
		dernieresActions[joueur] = nil
		compteurs[joueur] = nil
		secondesTrop[joueur] = nil
		suivis[joueur] = nil
		derniersAvis[joueur] = nil
	end)

	-- la Base attribuée replace le joueur : on oublie sa position de référence
	Bus.ecouter("BaseAttribuee", function(joueur)
		if estJoueur(joueur) then suivis[joueur] = nil end
	end)

	-- ===== boucles =====
	task.spawn(function()
		while true do
			task.wait(1)
			local ok, err = pcall(bilanSeconde)
			if not ok then print("[Dino][Securite] bilan : " .. tostring(err)) end
		end
	end)

	task.spawn(function()
		local precedent = os.clock()
		while true do
			task.wait(R.periodeDeplacement)
			local t = os.clock()
			local duree = t - precedent
			precedent = t
			local ok, err = pcall(controlerDeplacements, duree)
			if not ok then print("[Dino][Securite] déplacements : " .. tostring(err)) end
		end
	end)
end

return M
