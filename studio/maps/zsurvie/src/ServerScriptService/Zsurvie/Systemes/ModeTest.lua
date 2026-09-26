-- Systemes/ModeTest : commandes de chat pour les playtests, actives uniquement dans Roblox Studio.
-- /gemmes N, /pieces N, /soin, /tuer, /defaite, /aide
local M = {}

-- valeurs de débogage (propres au mode test, hors équilibrage du jeu)
local SOIN_TEST = 10000
local DEGATS_TEST = 99999
local MONTANT_MAX = 1000000
local ANTI_DOUBLON = 0.3 -- s : une même commande reçue deux fois (chat classique + TextChatService)

local AIDE = "Commandes de test : /gemmes N, /pieces N, /soin, /tuer, /defaite, /aide"

function M.demarrer(ctx)
	local okRun, RunService = pcall(function() return game:GetService("RunService") end)
	if not okRun or not RunService then return end
	local okStudio, enStudio = pcall(function() return RunService:IsStudio() end)
	if not okStudio or enStudio ~= true then return end

	local Players = game:GetService("Players")
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local horde = ctx.horde

	local dernieres = {} -- joueur -> { texte, instant }

	local function notifier(joueur, texte, genre)
		local ev = Reseau.Notification
		if not ev then
			print("[ModeTest] " .. texte)
			return
		end
		pcall(function() ev:FireClient(joueur, texte, genre or "info") end)
	end

	local function lireMontant(arg)
		local n = tonumber(arg)
		if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
		n = math.floor(n + 0.5)
		if n <= 0 then return nil end
		if n > MONTANT_MAX then n = MONTANT_MAX end
		return n
	end

	-- ===== les commandes =====
	local commandes = {}

	commandes["/gemmes"] = function(joueur, arg)
		local n = lireMontant(arg)
		if not n then
			notifier(joueur, "Usage : /gemmes N (N entier positif)", "alerte")
			return
		end
		local total = Bus.demander("AjouterGemmes", joueur, n, "ModeTest")
		if total == nil then
			notifier(joueur, "Gemmes indisponibles (système Donnees absent)", "alerte")
		else
			notifier(joueur, "+" .. n .. " gemmes (total " .. tostring(total) .. ")", "succes")
		end
	end

	commandes["/pieces"] = function(joueur, arg)
		local n = lireMontant(arg)
		if not n then
			notifier(joueur, "Usage : /pieces N (N entier positif)", "alerte")
			return
		end
		local total = Bus.demander("AjouterPieces", joueur, n)
		if total == nil then
			notifier(joueur, "Pièces indisponibles (système Economie absent)", "alerte")
		else
			notifier(joueur, "+" .. n .. " pièces (total " .. tostring(total) .. ")", "succes")
		end
	end

	commandes["/soin"] = function(joueur)
		Bus.emettre("SoinMaison", SOIN_TEST)
		notifier(joueur, "Maison soignée", "succes")
	end

	commandes["/tuer"] = function(joueur)
		if not horde or not horde.Parent then
			notifier(joueur, "Aucune horde en jeu", "info")
			return
		end
		local cibles = {}
		for _, enfant in ipairs(horde:GetChildren()) do
			if enfant:IsA("Model") then table.insert(cibles, enfant) end
		end
		for _, modele in ipairs(cibles) do
			if modele.Parent == horde then
				Bus.emettre("DegatsZbire", modele, DEGATS_TEST, joueur, true)
			end
		end
		notifier(joueur, #cibles .. " Zbire(s) touchés", "succes")
	end

	commandes["/defaite"] = function(joueur)
		Bus.emettre("DegatsMaison", DEGATS_TEST)
		notifier(joueur, "Dégâts massifs infligés à la Maison", "alerte")
	end

	commandes["/aide"] = function(joueur)
		notifier(joueur, AIDE, "info")
	end

	-- ===== analyse d'un message =====
	local function traiter(joueur, message)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		if type(message) ~= "string" then return end
		local mots = {}
		for mot in string.gmatch(message, "%S+") do table.insert(mots, mot) end
		if #mots == 0 then return end
		local nom = string.lower(mots[1])
		local action = commandes[nom]
		if not action then return end

		-- évite l'exécution en double si les deux systèmes de chat relaient le message
		local maintenant = os.clock()
		local derniere = dernieres[joueur]
		if derniere and derniere.texte == message and maintenant - derniere.instant < ANTI_DOUBLON then return end
		dernieres[joueur] = { texte = message, instant = maintenant }

		local ok, err = pcall(action, joueur, mots[2])
		if not ok then
			warn("[ModeTest] commande " .. nom .. " : " .. tostring(err))
		end
	end

	-- ===== chat classique =====
	local function brancher(joueur)
		joueur.Chatted:Connect(function(message)
			traiter(joueur, message)
		end)
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		brancher(joueur)
	end
	Players.PlayerAdded:Connect(brancher)
	Players.PlayerRemoving:Connect(function(joueur)
		dernieres[joueur] = nil
	end)

	-- ===== TextChatService (facultatif) : les messages « / » y sont des commandes =====
	pcall(function()
		local TextChatService = game:GetService("TextChatService")
		if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then return end
		local dossier = TextChatService:FindFirstChild("ZsurvieModeTest")
		if not dossier then
			dossier = Instance.new("Folder")
			dossier.Name = "ZsurvieModeTest"
			dossier.Parent = TextChatService
		end
		for nom, _ in pairs(commandes) do
			local nomInstance = "Commande_" .. string.sub(nom, 2)
			local cmd = dossier:FindFirstChild(nomInstance)
			if not cmd then
				cmd = Instance.new("TextChatCommand")
				cmd.Name = nomInstance
				cmd.PrimaryAlias = nom
				cmd.Parent = dossier
			end
			cmd.Triggered:Connect(function(source, message)
				if not source then return end
				local joueur = Players:GetPlayerByUserId(source.UserId)
				if joueur then traiter(joueur, message) end
			end)
		end
	end)

	print("ModeTest actif (Studio)")
end

return M
