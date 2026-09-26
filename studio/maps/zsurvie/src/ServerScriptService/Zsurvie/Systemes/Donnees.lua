-- Systemes/Donnees : sauvegarde permanente des joueurs (gemmes, record, récompenses du lobby, recherches).
-- Un joueur dont le chargement a échoué reçoit des valeurs par défaut mais n'est JAMAIS sauvegardé,
-- pour ne pas écraser sa vraie sauvegarde.
local Players = game:GetService("Players")

local M = {}

local NOM_STORE = "ZsurvieV1"
local ESSAIS = 3                -- tentatives par opération DataStore
local PAUSE_ESSAI = 2           -- secondes entre deux tentatives
local INTERVALLE_AUTO = 60      -- sauvegarde automatique (s)
local DELAI_FERMETURE = 25      -- attente maximale à la fermeture du serveur (s)

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Bus = ctx.Bus

	-- liste des recherches connues
	local nomsRecherches = {}
	if E and type(E.recherches) == "table" then
		for nom, _ in pairs(E.recherches) do
			table.insert(nomsRecherches, nom)
		end
	end
	table.sort(nomsRecherches)

	-- ===== accès au DataStore =====
	local store = nil
	local okService, DataStoreService = pcall(function()
		return game:GetService("DataStoreService")
	end)
	if okService and DataStoreService then
		local okStore, resultat = pcall(function()
			return DataStoreService:GetDataStore(NOM_STORE)
		end)
		if okStore then
			store = resultat
		else
			warn("[Zsurvie] Donnees : DataStore indisponible (" .. tostring(resultat) .. "), aucune sauvegarde sur ce serveur")
		end
	else
		warn("[Zsurvie] Donnees : service DataStore indisponible, aucune sauvegarde sur ce serveur")
	end

	-- état par joueur : { charge = bool, sauvegardable = bool, enCours = bool }
	local etats = {}
	-- gemmes gagnées avant la fin du chargement (ajoutées ensuite)
	local gemmesEnAttente = {}
	-- sauvegardes de départ encore en cours (attendues par BindToClose)
	local departsEnCours = 0

	local function estJoueur(j)
		return typeof(j) == "Instance" and j:IsA("Player")
	end

	local function cle(joueur)
		return "J_" .. tostring(joueur.UserId)
	end

	-- exécute fn en pcall, avec plusieurs essais espacés
	local function avecEssais(fn)
		local derniereErreur = nil
		for essai = 1, ESSAIS do
			local ok, resultat = pcall(fn)
			if ok then
				return true, resultat
			end
			derniereErreur = resultat
			if essai < ESSAIS then
				task.wait(PAUSE_ESSAI)
			end
		end
		return false, derniereErreur
	end

	local function entier(v, defaut)
		if type(v) ~= "number" or v ~= v or v == math.huge or v == -math.huge then
			return defaut
		end
		return math.floor(v)
	end

	local function lireGemmes(joueur)
		local v = joueur:GetAttribute("Gemmes")
		if type(v) ~= "number" then return 0 end
		return v
	end

	-- ===== chargement =====
	local function appliquer(joueur, donnees)
		donnees = donnees or {}
		-- on fusionne avec ce qui a pu être posé avant la fin du chargement
		local gemmes = math.max(0, entier(donnees.Gemmes, 0))
		local attente = gemmesEnAttente[joueur] or 0
		gemmesEnAttente[joueur] = nil
		joueur:SetAttribute("Gemmes", gemmes + attente)

		local record = math.max(0, entier(donnees.RecordJour, 0))
		local recordActuel = joueur:GetAttribute("RecordJour")
		if type(recordActuel) == "number" and recordActuel > record then
			record = recordActuel
		end
		joueur:SetAttribute("RecordJour", record)

		joueur:SetAttribute("ParcoursFait", donnees.ParcoursFait == true or joueur:GetAttribute("ParcoursFait") == true)
		joueur:SetAttribute("EnigmeFaite", donnees.EnigmeFaite == true or joueur:GetAttribute("EnigmeFaite") == true)

		local recherches = donnees.Recherches
		if type(recherches) ~= "table" then recherches = {} end
		for _, nom in ipairs(nomsRecherches) do
			local attr = "Rech_" .. nom
			joueur:SetAttribute(attr, recherches[nom] == true or joueur:GetAttribute(attr) == true)
		end
	end

	local function charger(joueur)
		if etats[joueur] then return end
		local etat = { charge = false, sauvegardable = false, enCours = false }
		etats[joueur] = etat

		local ok = false
		local donnees = nil
		if store then
			local cleJoueur = cle(joueur)
			ok, donnees = avecEssais(function()
				return store:GetAsync(cleJoueur)
			end)
			if not ok then
				warn("[Zsurvie] Donnees : chargement impossible pour " .. joueur.Name .. " (" .. tostring(donnees) .. ")")
				donnees = nil
			elseif type(donnees) ~= "table" then
				-- nouveau joueur (ou sauvegarde illisible) : valeurs par défaut
				donnees = nil
			end
		end

		-- le joueur a pu partir pendant le chargement
		if joueur.Parent ~= Players then
			etats[joueur] = nil
			gemmesEnAttente[joueur] = nil
			return
		end

		local okApplique, err = pcall(appliquer, joueur, donnees)
		if not okApplique then
			warn("[Zsurvie] Donnees : application impossible pour " .. joueur.Name .. " (" .. tostring(err) .. ")")
			ok = false
			pcall(appliquer, joueur, nil)
		end

		etat.sauvegardable = ok and store ~= nil
		etat.charge = true
		joueur:SetAttribute("DonneesChargees", true)
	end

	-- ===== sauvegarde =====
	local function instantane(joueur)
		local recherches = {}
		for _, nom in ipairs(nomsRecherches) do
			if joueur:GetAttribute("Rech_" .. nom) == true then
				recherches[nom] = true
			end
		end
		return {
			Gemmes = math.max(0, entier(joueur:GetAttribute("Gemmes"), 0)),
			RecordJour = math.max(0, entier(joueur:GetAttribute("RecordJour"), 0)),
			ParcoursFait = joueur:GetAttribute("ParcoursFait") == true,
			EnigmeFaite = joueur:GetAttribute("EnigmeFaite") == true,
			Recherches = recherches,
		}
	end

	local function sauvegarder(joueur)
		local etat = etats[joueur]
		if not etat or not etat.charge or not etat.sauvegardable or not store then return end
		if etat.enCours then
			-- une sauvegarde est déjà partie : on attend qu'elle finisse puis on refait
			local attente = 0
			while etat.enCours and attente < DELAI_FERMETURE do
				task.wait(0.5)
				attente = attente + 0.5
			end
			if etat.enCours then return end
		end
		etat.enCours = true
		local okInstant, donnees = pcall(instantane, joueur)
		if okInstant then
			local cleJoueur = cle(joueur)
			local ok, err = avecEssais(function()
				return store:UpdateAsync(cleJoueur, function(ancien)
					-- on ne perd jamais un record ni une récompense déjà sauvegardés
					if type(ancien) == "table" then
						local ancienRecord = entier(ancien.RecordJour, 0)
						if ancienRecord > donnees.RecordJour then
							donnees.RecordJour = ancienRecord
						end
						if ancien.ParcoursFait == true then donnees.ParcoursFait = true end
						if ancien.EnigmeFaite == true then donnees.EnigmeFaite = true end
						if type(ancien.Recherches) == "table" then
							for nom, valeur in pairs(ancien.Recherches) do
								if valeur == true and type(nom) == "string" then
									donnees.Recherches[nom] = true
								end
							end
						end
					end
					return donnees
				end)
			end)
			if not ok then
				warn("[Zsurvie] Donnees : sauvegarde impossible pour " .. joueur.Name .. " (" .. tostring(err) .. ")")
			end
		end
		etat.enCours = false
	end

	-- ===== joueurs =====
	local function arrivee(joueur)
		local ok, err = pcall(charger, joueur)
		if not ok then
			warn("[Zsurvie] Donnees : erreur au chargement de " .. tostring(joueur.Name) .. " (" .. tostring(err) .. ")")
			-- valeurs par défaut, jamais sauvegardées
			local etat = etats[joueur]
			if not etat then
				etat = { charge = false, sauvegardable = false, enCours = false }
				etats[joueur] = etat
			end
			if joueur.Parent == Players then
				pcall(appliquer, joueur, nil)
				etat.sauvegardable = false
				etat.charge = true
				pcall(function()
					joueur:SetAttribute("DonneesChargees", true)
				end)
			end
		end
	end

	Players.PlayerAdded:Connect(function(joueur)
		task.spawn(arrivee, joueur)
	end)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(arrivee, joueur)
	end

	Players.PlayerRemoving:Connect(function(joueur)
		departsEnCours = departsEnCours + 1
		task.spawn(function()
			local ok, err = pcall(sauvegarder, joueur)
			if not ok then
				warn("[Zsurvie] Donnees : erreur de sauvegarde au départ (" .. tostring(err) .. ")")
			end
			etats[joueur] = nil
			gemmesEnAttente[joueur] = nil
			departsEnCours = departsEnCours - 1
		end)
	end)

	-- sauvegarde automatique
	task.spawn(function()
		while true do
			task.wait(INTERVALLE_AUTO)
			for _, joueur in ipairs(Players:GetPlayers()) do
				local etat = etats[joueur]
				if etat and etat.charge and etat.sauvegardable and not etat.enCours then
					task.spawn(function()
						pcall(sauvegarder, joueur)
					end)
				end
			end
		end
	end)

	-- fermeture du serveur : on sauvegarde tout le monde en parallèle
	pcall(function()
		game:BindToClose(function()
			local restants = 0
			for _, joueur in ipairs(Players:GetPlayers()) do
				restants = restants + 1
				task.spawn(function()
					pcall(sauvegarder, joueur)
					restants = restants - 1
				end)
			end
			local attente = 0
			-- on attend aussi les sauvegardes lancées par PlayerRemoving (dernier joueur parti)
			while (restants > 0 or departsEnCours > 0) and attente < DELAI_FERMETURE do
				task.wait(0.5)
				attente = attente + 0.5
			end
		end)
	end)

	-- ===== répondeurs =====
	local function entierPositif(n)
		if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then return nil end
		n = math.floor(n + 0.5)
		if n <= 0 then return nil end
		return n
	end

	Bus.repondre("AjouterGemmes", function(joueur, n, source)
		if not estJoueur(joueur) then return nil end
		local montant = entierPositif(n)
		if not montant then return lireGemmes(joueur) end
		if type(source) ~= "string" then source = "inconnue" end
		local etat = etats[joueur]
		if etat and etat.charge then
			joueur:SetAttribute("Gemmes", lireGemmes(joueur) + montant)
		else
			-- chargement pas encore terminé : on met de côté
			gemmesEnAttente[joueur] = (gemmesEnAttente[joueur] or 0) + montant
		end
		Bus.emettre("GemmesGagnees", joueur, montant, source)
		return lireGemmes(joueur) + (gemmesEnAttente[joueur] or 0)
	end)

	Bus.repondre("DepenserGemmes", function(joueur, n)
		if not estJoueur(joueur) then return false end
		local etat = etats[joueur]
		if not etat or not etat.charge then return false end
		local montant = entierPositif(n)
		if not montant then return false end
		local total = lireGemmes(joueur)
		if total < montant then return false end
		joueur:SetAttribute("Gemmes", total - montant)
		return true
	end)
end

return M
