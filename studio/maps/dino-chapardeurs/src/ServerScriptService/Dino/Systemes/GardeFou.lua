-- GardeFou : filet de sécurité du serveur (toutes les 2 s).
-- Dinos cassés ou coincés, joueurs tombés hors du monde, argent invalide.
-- Ne remplace aucun système : il n'intervient que quand un état anormal dure.
local Players = game:GetService("Players")

local M = {}

local PERIODE = 2
local DELAI_EN_ROUTE = 40      -- secondes max pour qu'un dino acheté rejoigne sa Base
local DELAI_PORTE_ORPHELIN = 20 -- secondes après le départ du voleur
local Y_MIN = -30
local HAUTEUR_REAPPARITION = 4

local function vivant(instance)
	return instance ~= nil and instance.Parent ~= nil
end

local function estNaN(n)
	return n ~= n
end

local function vecteurInvalide(v)
	if typeof(v) ~= "Vector3" then return true end
	if estNaN(v.X) or estNaN(v.Y) or estNaN(v.Z) then return true end
	if math.abs(v.X) == math.huge or math.abs(v.Y) == math.huge or math.abs(v.Z) == math.huge then return true end
	return false
end

local function nombre(v, defaut)
	if type(v) == "number" and not estNaN(v) then return v end
	return defaut
end

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Plan = ctx.Plan

	-- suivi par dino : état observé, depuis quand, départ du voleur, anomalies consécutives
	local suivi = {}

	local function journal(texte)
		print("[Dino][GardeFou] " .. texte)
	end

	local function nomDe(dino)
		local ok, nom = pcall(function() return dino:GetAttribute("Espece") end)
		if ok and type(nom) == "string" then return nom end
		return dino.Name
	end

	local function detruire(dino, raison)
		journal("dino " .. nomDe(dino) .. " supprimé (" .. raison .. ")")
		suivi[dino] = nil
		pcall(function() dino:Destroy() end)
	end

	-- renvoie le dino chez un joueur présent, sinon le supprime
	local function rapatrier(dino, uid, raison)
		local proprio = nil
		if type(uid) == "number" and uid ~= 0 then
			proprio = Players:GetPlayerByUserId(uid)
		end
		if not proprio then
			detruire(dino, raison .. ", propriétaire absent")
			return
		end
		local numero = nombre(dino:GetAttribute("Emplacement"), 0)
		pcall(function() dino:SetAttribute("Voleur", 0) end)
		local place = Bus.demander("PlacerDino", dino, proprio, numero)
		if place == true then
			journal("dino " .. nomDe(dino) .. " replacé chez " .. proprio.Name .. " (" .. raison .. ")")
			suivi[dino] = nil
		else
			if numero > 0 then
				Bus.demander("LibererEmplacement", proprio, numero)
			end
			detruire(dino, raison .. ", pose impossible")
		end
	end

	-- ===== dinos =====
	local function verifierDino(dino, maintenant)
		if not dino:IsA("Model") then return end
		local s = suivi[dino]
		if not s then
			s = { etat = nil, depuis = maintenant, departVoleur = nil, anomalies = 0 }
			suivi[dino] = s
		end

		-- structure : PrimaryPart présente et position valide (vu deux fois de suite)
		local casse = false
		if not dino.PrimaryPart then
			casse = true
		else
			local ok, pivot = pcall(function() return dino:GetPivot() end)
			if not ok or typeof(pivot) ~= "CFrame" or vecteurInvalide(pivot.Position) then
				casse = true
			end
		end
		if casse then
			s.anomalies = s.anomalies + 1
			if s.anomalies >= 2 then
				detruire(dino, "sans corps ou position invalide")
			end
			return
		end
		s.anomalies = 0

		local etat = dino:GetAttribute("Etat")
		if etat ~= s.etat then
			s.etat = etat
			s.depuis = maintenant
			s.departVoleur = nil
		end

		if etat == "EnRoute" then
			if maintenant - s.depuis > DELAI_EN_ROUTE then
				rapatrier(dino, dino:GetAttribute("Proprietaire"), "bloqué en route")
			end
		elseif etat == "Porte" then
			local uidVoleur = nombre(dino:GetAttribute("Voleur"), 0)
			local voleur = nil
			if uidVoleur ~= 0 then
				voleur = Players:GetPlayerByUserId(uidVoleur)
			end
			if voleur then
				s.departVoleur = nil
			else
				-- Vol s'occupe normalement du retour ; on n'agit qu'après un délai
				if not s.departVoleur then
					s.departVoleur = maintenant
				elseif maintenant - s.departVoleur > DELAI_PORTE_ORPHELIN then
					rapatrier(dino, dino:GetAttribute("Proprietaire"), "porté par un voleur parti")
				end
			end
		end
	end

	local function verifierDinos(maintenant)
		local presents = {}
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			presents[dino] = true
			if vivant(dino) then
				local ok, err = pcall(verifierDino, dino, maintenant)
				if not ok then
					journal("vérification d'un dino impossible : " .. tostring(err))
				end
			end
		end
		-- oublie les dinos disparus
		local anciens = {}
		for dino in pairs(suivi) do
			if not presents[dino] or not vivant(dino) then table.insert(anciens, dino) end
		end
		for _, dino in ipairs(anciens) do
			suivi[dino] = nil
		end
	end

	-- ===== joueurs =====
	local function pointDeRetour(joueur)
		local index = Bus.demander("BaseDe", joueur)
		if type(index) == "number" then
			local modele = Bus.demander("ModeleBase", index)
			if typeof(modele) == "Instance" and vivant(modele) then
				local apparition = modele:FindFirstChild("Apparition")
				if apparition and apparition:IsA("BasePart") then
					return apparition.Position + Vector3.new(0, HAUTEUR_REAPPARITION, 0)
				end
			end
		end
		return Plan.place.centre + Vector3.new(0, HAUTEUR_REAPPARITION, 0)
	end

	local function verifierJoueur(joueur)
		-- argent invalide
		local argent = joueur:GetAttribute("Argent")
		if type(argent) == "number" and (estNaN(argent) or argent < 0) then
			joueur:SetAttribute("Argent", 0)
			journal("argent invalide de " .. joueur.Name .. " remis à 0")
		end

		-- chute hors du monde
		local perso = joueur.Character
		if not perso then return end
		local racine = perso:FindFirstChild("HumanoidRootPart")
		if not racine or not racine:IsA("BasePart") then return end
		local humanoid = perso:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health <= 0 then return end
		local position = racine.Position
		if vecteurInvalide(position) or position.Y < Y_MIN then
			local cible = pointDeRetour(joueur)
			pcall(function()
				racine.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				racine.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end)
			local ok = pcall(function() perso:PivotTo(CFrame.new(cible)) end)
			if ok then
				journal(joueur.Name .. " replacé après une chute")
			end
		end
	end

	local function verifierJoueurs()
		for _, joueur in ipairs(Players:GetPlayers()) do
			if joueur.Parent then
				local ok, err = pcall(verifierJoueur, joueur)
				if not ok then
					journal("vérification de " .. joueur.Name .. " impossible : " .. tostring(err))
				end
			end
		end
	end

	-- ===== boucle =====
	journal("démarré")
	while true do
		task.wait(PERIODE)
		local maintenant = workspace:GetServerTimeNow()
		local ok, err = pcall(verifierDinos, maintenant)
		if not ok then journal("tour dinos : " .. tostring(err)) end
		ok, err = pcall(verifierJoueurs)
		if not ok then journal("tour joueurs : " .. tostring(err)) end
	end
end

return M
