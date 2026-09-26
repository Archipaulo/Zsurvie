-- Système ModeTest : commandes de chat réservées à Roblox Studio pour tester le jeu rapidement.
-- /argent N, /dino Espece [Mutation], /evenement Nom, /renaissance, /vider, /aide.
-- Inactif en jeu publié (RunService:IsStudio() faux).
local M = {}

local ARGENT_MAX_COMMANDE = 1e15 -- plafond d'une seule commande /argent
local ANTI_DOUBLON = 0.5         -- secondes : une même commande reçue deux fois (Chatted + TextChatCommand) n'est traitée qu'une fois

local SUFFIXES = { k = 1e3, m = 1e6, b = 1e9, t = 1e12 }

local AIDE = {
	"/argent N : ajoute N $ (ex. /argent 5000, /argent 2m)",
	"/dino Espece [Mutation] : pose un dino dans ta Base (ex. /dino Rex Or)",
	"/evenement Nom : lance un événement (PluieDeMeteores, Eruption, LuneDoree)",
	"/renaissance : met ton argent au coût de ta prochaine renaissance",
	"/vider : retire tous tes dinos de ta Base (sans gain)",
	"/aide : affiche cette liste",
}

function M.demarrer(ctx)
	local RunService = game:GetService("RunService")
	if not RunService:IsStudio() then return end

	local Players = game:GetService("Players")
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local E = ctx.Equilibrage
	local Charte = ctx.Charte

	local dernieres = {} -- [joueur] = { texte = ..., heure = ... }
	local connexions = {} -- [joueur] = connexion Chatted

	-- ===== utilitaires =====
	local function estJoueur(j)
		return typeof(j) == "Instance" and j:IsA("Player") and j.Parent == Players
	end

	local function estFini(n)
		return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
	end

	local function notifier(joueur, texte, genre)
		pcall(function()
			Reseau.Notification:FireClient(joueur, texte, genre or "info")
		end)
	end

	local function montant(n)
		local ok, texte = pcall(Charte.argent, n)
		if ok and type(texte) == "string" then return texte end
		return tostring(math.floor(n)) .. " $"
	end

	-- cherche une clé d'une table sans tenir compte de la casse (ni des accents du nom affiché)
	local function trouverCle(t, saisie)
		if type(t) ~= "table" or type(saisie) ~= "string" or saisie == "" then return nil end
		local bas = string.lower(saisie)
		for cle, infos in pairs(t) do
			if type(cle) == "string" then
				if string.lower(cle) == bas then return cle end
				if type(infos) == "table" and type(infos.nom) == "string" and infos.nom ~= "" and string.lower(infos.nom) == bas then
					return cle
				end
			end
		end
		return nil
	end

	local function listeCles(t)
		local noms = {}
		if type(t) ~= "table" then return "" end
		for cle in pairs(t) do
			if type(cle) == "string" then table.insert(noms, cle) end
		end
		table.sort(noms)
		return table.concat(noms, ", ")
	end

	-- lit « 5000 », « 2.5k », « 3m », « 1e6 »
	local function lireNombre(texte)
		if type(texte) ~= "string" then return nil end
		local direct = tonumber(texte)
		if direct then return direct end
		local chiffres, suffixe = string.match(string.lower(texte), "^([%d%.]+)(%a)$")
		if chiffres and SUFFIXES[suffixe] then
			local n = tonumber(chiffres)
			if n then return n * SUFFIXES[suffixe] end
		end
		return nil
	end

	local function decouper(texte)
		local mots = {}
		for mot in string.gmatch(texte, "%S+") do
			table.insert(mots, mot)
		end
		return mots
	end

	-- ===== commandes =====
	local commandes = {}

	commandes.aide = function(joueur)
		for _, ligne in ipairs(AIDE) do
			notifier(joueur, ligne, "info")
		end
		print("[Dino] ModeTest : " .. table.concat(AIDE, " | "))
	end

	commandes.argent = function(joueur, args)
		local n = lireNombre(args[1])
		if not estFini(n) or n <= 0 then
			notifier(joueur, "Usage : /argent N (nombre positif)", "alerte")
			return
		end
		n = math.min(math.floor(n), ARGENT_MAX_COMMANDE)
		if n <= 0 then
			notifier(joueur, "Usage : /argent N (nombre positif)", "alerte")
			return
		end
		local total = Bus.demander("AjouterArgent", joueur, n, "ModeTest")
		if type(total) ~= "number" then
			notifier(joueur, "Économie indisponible.", "alerte")
			return
		end
		notifier(joueur, "+" .. montant(n) .. " (total " .. montant(total) .. ")", "succes")
	end

	commandes.dino = function(joueur, args)
		local espece = trouverCle(E.especes, args[1])
		if not espece then
			notifier(joueur, "Espèce inconnue. Choix : " .. listeCles(E.especes), "alerte")
			return
		end
		local mutation = "Normal"
		if args[2] then
			mutation = trouverCle(E.mutations, args[2])
			if not mutation then
				notifier(joueur, "Mutation inconnue. Choix : " .. listeCles(E.mutations), "alerte")
				return
			end
		end

		local index = Bus.demander("BaseDe", joueur)
		if type(index) ~= "number" then
			notifier(joueur, "Tu n'as pas encore de Base.", "alerte")
			return
		end
		local numero = Bus.demander("ReserverEmplacement", joueur)
		if type(numero) ~= "number" then
			notifier(joueur, "Ta Base est pleine.", "alerte")
			return
		end

		local dino = Bus.demander("CreerDino", espece, mutation)
		if typeof(dino) ~= "Instance" or not dino:IsA("Model") then
			Bus.demander("LibererEmplacement", joueur, numero)
			notifier(joueur, "Impossible de créer ce dino.", "alerte")
			return
		end
		-- sort tout de suite de l'état « Tapis » pour que le Tapis ne l'adopte pas
		pcall(function()
			dino:SetAttribute("Etat", "EnRoute")
			dino:SetAttribute("Proprietaire", joueur.UserId)
			dino:SetAttribute("Base", index)
			dino:SetAttribute("Emplacement", numero)
			local acheter = dino:FindFirstChild("Acheter", true)
			if acheter and acheter:IsA("ProximityPrompt") then acheter:Destroy() end
		end)

		local place = Bus.demander("PlacerDino", dino, joueur, numero)
		if place ~= true then
			Bus.demander("LibererEmplacement", joueur, numero)
			pcall(function() dino:Destroy() end)
			notifier(joueur, "Impossible de poser ce dino dans ta Base.", "alerte")
			return
		end
		local texte = espece
		if mutation ~= "Normal" then texte = texte .. " " .. mutation end
		notifier(joueur, texte .. " posé sur l'emplacement " .. tostring(dino:GetAttribute("Emplacement") or numero), "succes")
	end

	commandes.evenement = function(joueur, args)
		local liste = E.evenements and E.evenements.liste
		local nom = trouverCle(liste, args[1])
		if not nom then
			notifier(joueur, "Événement inconnu. Choix : " .. listeCles(liste), "alerte")
			return
		end
		local ok = Bus.demander("LancerEvenement", nom)
		if ok == true then
			notifier(joueur, "Événement « " .. nom .. " » lancé.", "succes")
		else
			notifier(joueur, "Impossible de lancer « " .. nom .. " » (un événement est peut-être en cours).", "alerte")
		end
	end

	commandes.renaissance = function(joueur)
		local niveau = joueur:GetAttribute("Renaissances")
		if not estFini(niveau) or niveau < 0 then niveau = 0 end
		niveau = math.floor(niveau)
		if type(E.renaissanceMax) == "number" and niveau >= E.renaissanceMax then
			notifier(joueur, "Renaissance maximale déjà atteinte.", "alerte")
			return
		end
		local ok, cout = pcall(E.coutRenaissance, niveau)
		if not ok or not estFini(cout) or cout < 0 then
			notifier(joueur, "Coût de renaissance introuvable.", "alerte")
			return
		end
		cout = math.ceil(cout)
		local argent = joueur:GetAttribute("Argent")
		if not estFini(argent) or argent < 0 then argent = 0 end
		if argent < cout then
			Bus.demander("AjouterArgent", joueur, cout - argent, "ModeTest")
		elseif argent > cout then
			Bus.demander("DepenserArgent", joueur, argent - cout)
		end
		notifier(joueur, "Argent réglé à " .. montant(cout) .. " : renaissance " .. tostring(niveau + 1) .. " possible.", "succes")
	end

	commandes.vider = function(joueur)
		local liste = Bus.demander("DinosDe", joueur)
		if type(liste) ~= "table" then
			notifier(joueur, "Enclos indisponible.", "alerte")
			return
		end
		local compte = 0
		for _, dino in ipairs(liste) do
			if typeof(dino) == "Instance" and dino.Parent and dino:GetAttribute("Proprietaire") == joueur.UserId then
				local espece = dino:GetAttribute("Espece")
				local numero = dino:GetAttribute("Emplacement")
				pcall(function()
					dino:SetAttribute("Etat", "Vendu")
					dino:SetAttribute("Stock", 0)
				end)
				if type(numero) == "number" and numero > 0 then
					Bus.demander("LibererEmplacement", joueur, numero)
				end
				pcall(function() dino:Destroy() end)
				Bus.emettre("DinoVendu", joueur, espece, 0)
				compte = compte + 1
			end
		end
		pcall(function() joueur:SetAttribute("RevenuParSeconde", 0) end)
		notifier(joueur, tostring(compte) .. " dino(s) retiré(s) de ta Base.", "info")
	end

	-- ===== analyse d'un message =====
	local function traiter(joueur, texte)
		if not estJoueur(joueur) or type(texte) ~= "string" then return end
		texte = string.sub(texte, 1, 200)
		if string.sub(texte, 1, 1) ~= "/" then return end
		local mots = decouper(texte)
		if #mots == 0 then return end
		local nom = string.lower(string.sub(mots[1], 2))
		local fn = commandes[nom]
		if not fn then return end

		-- anti-doublon : Chatted et TextChatCommand peuvent livrer le même message
		local maintenant = os.clock()
		local derniere = dernieres[joueur]
		local cle = string.lower(texte)
		if derniere and derniere.texte == cle and maintenant - derniere.heure < ANTI_DOUBLON then return end
		dernieres[joueur] = { texte = cle, heure = maintenant }

		local args = {}
		for i = 2, #mots do
			table.insert(args, mots[i])
		end
		local ok, err = pcall(fn, joueur, args)
		if not ok then
			print("[Dino] ModeTest : erreur sur " .. nom .. " : " .. tostring(err))
			notifier(joueur, "Erreur pendant la commande /" .. nom .. ".", "alerte")
		end
	end

	-- ===== ancien chat : Player.Chatted =====
	local function brancher(joueur)
		if connexions[joueur] then return end
		local ok, connexion = pcall(function()
			return joueur.Chatted:Connect(function(message)
				traiter(joueur, message)
			end)
		end)
		if ok and connexion then connexions[joueur] = connexion end
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		brancher(joueur)
	end
	Players.PlayerAdded:Connect(brancher)
	Players.PlayerRemoving:Connect(function(joueur)
		local c = connexions[joueur]
		if c then pcall(function() c:Disconnect() end) end
		connexions[joueur] = nil
		dernieres[joueur] = nil
	end)

	-- ===== nouveau chat : TextChatCommand =====
	pcall(function()
		local TextChatService = game:GetService("TextChatService")
		if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then return end
		local parent = TextChatService:FindFirstChild("TextChatCommands") or TextChatService
		local ancien = parent:FindFirstChild("DinoModeTest")
		if ancien then ancien:Destroy() end
		local dossier = Instance.new("Folder")
		dossier.Name = "DinoModeTest"
		for nom in pairs(commandes) do
			local commande = Instance.new("TextChatCommand")
			commande.Name = "Dino_" .. nom
			commande.PrimaryAlias = "/" .. nom
			commande.Triggered:Connect(function(source, texte)
				if not source then return end
				local joueur = Players:GetPlayerByUserId(source.UserId)
				if joueur then traiter(joueur, texte) end
			end)
			commande.Parent = dossier
		end
		dossier.Parent = parent
	end)

	print("[Dino] ModeTest actif (Studio) : tape /aide dans le chat.")
end

return M
