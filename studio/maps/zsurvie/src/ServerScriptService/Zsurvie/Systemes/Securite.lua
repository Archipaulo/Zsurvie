-- Systemes/Securite : limiteur de fréquence (AutoriserAction), pings d'équipe, surveillance anti-spam des remotes.
local Players = game:GetService("Players")

local M = {}

-- textes de ping autorisés (CONTRAT §6)
local PINGS_AUTORISES = {
	["Aide !"] = true,
	["Ici !"] = true,
	["Colosse !"] = true,
	["Merci !"] = true,
}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}

	-- réglages de sécurité : pris dans Equilibrage.securite s'il existe, sinon valeurs de la mission
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.securite) == "table" then
		reglages = ctx.Equilibrage.securite
	end
	local DELAI_PING = tonumber(reglages.delaiPing) or 3
	local SEUIL_PAR_SECONDE = tonumber(reglages.seuilRemotesParSeconde) or 40
	local SECONDES_SUSPECTES = tonumber(reglages.secondesSuspectes) or 5

	-- ===== limiteur de fréquence =====
	-- dernieresActions[joueur][action] = os.clock() de la dernière action acceptée
	local dernieresActions = {}

	local function autoriserAction(joueur, action, intervalle)
		if joueur == nil then
			return true
		end
		local cle = tostring(action)
		local duree = tonumber(intervalle) or 0
		local maintenant = os.clock()
		local actions = dernieresActions[joueur]
		if not actions then
			actions = {}
			dernieresActions[joueur] = actions
		end
		local derniere = actions[cle]
		if derniere and maintenant - derniere < duree then
			return false
		end
		actions[cle] = maintenant
		return true
	end

	if Bus and type(Bus.repondre) == "function" then
		Bus.repondre("AutoriserAction", autoriserAction)
	end

	-- ===== surveillance anti-spam =====
	-- compteurs[joueur] = nombre d'OnServerEvent reçus dans la seconde en cours
	-- depassements[joueur] = nombre de secondes d'affilée au-delà du seuil
	local compteurs = {}
	local depassements = {}
	local signales = {}

	local function compter(joueur)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
			return
		end
		compteurs[joueur] = (compteurs[joueur] or 0) + 1
	end

	for _, remote in pairs(Reseau) do
		if typeof(remote) == "Instance" and remote:IsA("RemoteEvent") then
			local ok, err = pcall(function()
				remote.OnServerEvent:Connect(function(joueur)
					compter(joueur)
				end)
			end)
			if not ok then
				warn("[Zsurvie] Securite : surveillance impossible de " .. remote.Name .. " : " .. tostring(err))
			end
		end
	end

	task.spawn(function()
		while true do
			task.wait(1)
			local releve = compteurs
			compteurs = {}
			for _, joueur in ipairs(Players:GetPlayers()) do
				local n = releve[joueur] or 0
				if n > SEUIL_PAR_SECONDE then
					depassements[joueur] = (depassements[joueur] or 0) + 1
					if depassements[joueur] >= SECONDES_SUSPECTES and not signales[joueur] then
						signales[joueur] = true
						print(string.format("[Zsurvie] Securite : %s (%d) envoie plus de %d requêtes/s depuis %d s, marqué Suspect",
							joueur.Name, joueur.UserId, SEUIL_PAR_SECONDE, depassements[joueur]))
						pcall(function()
							joueur:SetAttribute("Suspect", true)
						end)
					end
				else
					depassements[joueur] = 0
				end
			end
		end
	end)

	-- ===== pings d'équipe =====
	local remotePing = Reseau.Ping
	local remoteNotification = Reseau.Notification
	if remotePing then
		remotePing.OnServerEvent:Connect(function(joueur, texte)
			if type(texte) ~= "string" or not PINGS_AUTORISES[texte] then
				return
			end
			if not autoriserAction(joueur, "Ping", DELAI_PING) then
				return
			end
			if remoteNotification then
				local nom = joueur.DisplayName or joueur.Name
				pcall(function()
					remoteNotification:FireAllClients(nom .. " : " .. texte, "info")
				end)
			end
		end)
	end

	-- ===== arrivées et départs =====
	local function preparer(joueur)
		if not dernieresActions[joueur] then
			dernieresActions[joueur] = {}
		end
		depassements[joueur] = 0
	end
	for _, joueur in ipairs(Players:GetPlayers()) do
		preparer(joueur)
	end
	Players.PlayerAdded:Connect(preparer)

	Players.PlayerRemoving:Connect(function(joueur)
		dernieresActions[joueur] = nil
		compteurs[joueur] = nil
		depassements[joueur] = nil
		signales[joueur] = nil
	end)
end

return M
