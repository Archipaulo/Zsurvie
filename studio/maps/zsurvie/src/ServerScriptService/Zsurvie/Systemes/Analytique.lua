-- Systemes/Analytique : compteurs de session et envoi vers AnalyticsService.
-- Tous les appels à AnalyticsService sont protégés (pcall) et lancés hors du fil appelant.
-- Les gains fréquents (pièces, Zbires vaincus) sont regroupés par joueur puis envoyés par lots.
local M = {}

local INTERVALLE_RESUME = 300 -- secondes entre deux résumés dans la sortie
local INTERVALLE_LOT = 60 -- secondes entre deux envois groupés

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Equilibrage = ctx.Equilibrage

	local okPlayers, Players = pcall(function() return game:GetService("Players") end)
	if not okPlayers then Players = nil end
	local okAnalytics, Analytics = pcall(function() return game:GetService("AnalyticsService") end)
	if not okAnalytics then Analytics = nil end

	-- réglages optionnels depuis l'équilibrage
	local reglages = Equilibrage and Equilibrage.analytique
	if type(reglages) == "table" then
		if type(reglages.intervalleResume) == "number" and reglages.intervalleResume > 0 then
			INTERVALLE_RESUME = reglages.intervalleResume
		end
		if type(reglages.intervalleLot) == "number" and reglages.intervalleLot > 0 then
			INTERVALLE_LOT = reglages.intervalleLot
		end
	end

	-- ===== compteurs de la session =====
	local stats = {
		runs = 0,
		defaites = 0,
		sommeJoursDefaite = 0,
		jourMax = 0,
		joursCommences = 0,
		ameliorations = 0,
		recherches = 0,
		pieces = 0,
		gemmes = 0,
		zbiresTotal = 0,
		zbiresParType = {},
	}

	-- lots en attente par joueur : { pieces = n, zbires = n }
	local lots = {}
	-- joueurs de la run en cours
	local participants = {}

	local function estJoueur(x)
		return typeof(x) == "Instance" and x:IsA("Player") and x.Parent ~= nil
	end

	local function nombre(x)
		if type(x) == "number" and x == x and x ~= math.huge and x ~= -math.huge then
			return x
		end
		return nil
	end

	-- appel sans bloquer, erreurs ignorées (quotas, Studio hors ligne, etc.)
	local function envoyer(fn)
		if not Analytics then return end
		task.spawn(function()
			pcall(fn)
		end)
	end

	local function progression(joueur, statut, niveau)
		if not estJoueur(joueur) then return end
		envoyer(function()
			local typeProgression = Enum.AnalyticsProgressionType[statut]
			Analytics:LogProgressionEvent(joueur, "Run", typeProgression, niveau, "Jour " .. tostring(niveau))
		end)
	end

	local function economie(joueur, monnaie, montant, typeTransaction, article)
		if not estJoueur(joueur) then return end
		if montant <= 0 then return end
		local solde = joueur:GetAttribute(monnaie)
		if type(solde) ~= "number" then solde = 0 end
		envoyer(function()
			local flux = Enum.AnalyticsEconomyFlowType.Source
			local transaction = Enum.AnalyticsEconomyTransactionType[typeTransaction].Name
			Analytics:LogEconomyEvent(joueur, flux, monnaie, montant, solde, transaction, article)
		end)
	end

	local function personnalise(joueur, nom, valeur)
		if not estJoueur(joueur) then return end
		envoyer(function()
			Analytics:LogCustomEvent(joueur, nom, valeur)
		end)
	end

	local function lotDe(joueur)
		local lot = lots[joueur]
		if not lot then
			lot = { pieces = 0, zbires = 0 }
			lots[joueur] = lot
		end
		return lot
	end

	-- envoie et vide le lot d'un joueur
	local function viderLot(joueur)
		local lot = lots[joueur]
		if not lot then return end
		lots[joueur] = nil
		if not estJoueur(joueur) then return end
		if lot.pieces > 0 then
			economie(joueur, "Pieces", lot.pieces, "Gameplay", "Horde")
		end
		if lot.zbires > 0 then
			personnalise(joueur, "ZbiresVaincus", lot.zbires)
		end
	end

	local function viderTousLesLots()
		local liste = {}
		for joueur in pairs(lots) do table.insert(liste, joueur) end
		for _, joueur in ipairs(liste) do viderLot(joueur) end
	end

	-- joueurs encore présents de la run en cours (ou, à défaut, ceux marqués EnRun)
	local function joueursDeLaRun()
		local liste = {}
		for joueur in pairs(participants) do
			if estJoueur(joueur) then
				table.insert(liste, joueur)
			else
				participants[joueur] = nil
			end
		end
		if #liste == 0 and Players then
			local ok, tous = pcall(function() return Players:GetPlayers() end)
			if ok and type(tous) == "table" then
				for _, joueur in ipairs(tous) do
					if joueur:GetAttribute("EnRun") == true then table.insert(liste, joueur) end
				end
			end
		end
		return liste
	end

	-- ===== écoutes du bus =====
	Bus.ecouter("RunDebut", function(joueurs)
		stats.runs = stats.runs + 1
		participants = {}
		if type(joueurs) == "table" then
			for _, joueur in ipairs(joueurs) do
				if estJoueur(joueur) then
					participants[joueur] = true
					progression(joueur, "Start", 1)
				end
			end
		end
	end)

	Bus.ecouter("JourDebut", function(jour)
		jour = nombre(jour)
		if not jour then return end
		stats.joursCommences = stats.joursCommences + 1
		if jour > stats.jourMax then stats.jourMax = jour end
		for _, joueur in ipairs(joueursDeLaRun()) do
			if jour > 1 then
				progression(joueur, "Complete", jour - 1)
			end
			progression(joueur, "Start", jour)
		end
	end)

	Bus.ecouter("MaisonTombee", function(jour)
		jour = nombre(jour)
		if not jour then return end
		stats.defaites = stats.defaites + 1
		stats.sommeJoursDefaite = stats.sommeJoursDefaite + jour
		for _, joueur in ipairs(joueursDeLaRun()) do
			progression(joueur, "Fail", jour)
			personnalise(joueur, "JourDefaite", jour)
		end
		viderTousLesLots()
		participants = {}
	end)

	Bus.ecouter("AmeliorationAchetee", function(joueur, nom, niveau)
		if not estJoueur(joueur) or type(nom) ~= "string" then return end
		niveau = nombre(niveau) or 0
		stats.ameliorations = stats.ameliorations + 1
		personnalise(joueur, "Amelioration_" .. nom, niveau)
	end)

	Bus.ecouter("RechercheDebloquee", function(joueur, nom)
		if not estJoueur(joueur) or type(nom) ~= "string" then return end
		stats.recherches = stats.recherches + 1
		personnalise(joueur, "Recherche_" .. nom, 1)
	end)

	Bus.ecouter("GemmesGagnees", function(joueur, n, source)
		n = nombre(n)
		if not estJoueur(joueur) or not n or n <= 0 then return end
		stats.gemmes = stats.gemmes + n
		local article = "Gemmes"
		if type(source) == "string" and source ~= "" then article = source end
		economie(joueur, "Gemmes", n, "Gameplay", article)
	end)

	Bus.ecouter("PiecesGagnees", function(joueur, n)
		n = nombre(n)
		if not estJoueur(joueur) or not n or n <= 0 then return end
		stats.pieces = stats.pieces + n
		local lot = lotDe(joueur)
		lot.pieces = lot.pieces + n
	end)

	Bus.ecouter("ZbireVaincu", function(modele, typeZbire, position, tueur)
		local nomType = "Inconnu"
		if type(typeZbire) == "string" and typeZbire ~= "" then nomType = typeZbire end
		stats.zbiresTotal = stats.zbiresTotal + 1
		stats.zbiresParType[nomType] = (stats.zbiresParType[nomType] or 0) + 1
		if estJoueur(tueur) then
			local lot = lotDe(tueur)
			lot.zbires = lot.zbires + 1
		end
	end)

	-- un joueur qui part : on envoie son lot et on l'oublie
	if Players then
		pcall(function()
			Players.PlayerRemoving:Connect(function(joueur)
				local lot = lots[joueur]
				lots[joueur] = nil
				participants[joueur] = nil
				if lot then
					-- le joueur est encore accessible pendant PlayerRemoving
					if lot.pieces > 0 then
						local solde = joueur:GetAttribute("Pieces")
						if type(solde) ~= "number" then solde = 0 end
						envoyer(function()
							Analytics:LogEconomyEvent(joueur, Enum.AnalyticsEconomyFlowType.Source, "Pieces",
								lot.pieces, solde, Enum.AnalyticsEconomyTransactionType.Gameplay.Name, "Horde")
						end)
					end
					if lot.zbires > 0 then
						envoyer(function()
							Analytics:LogCustomEvent(joueur, "ZbiresVaincus", lot.zbires)
						end)
					end
				end
			end)
		end)
	end

	-- ===== résumé =====
	local function resume()
		local jourMoyen = 0
		if stats.defaites > 0 then jourMoyen = stats.sommeJoursDefaite / stats.defaites end
		local types = {}
		for nom in pairs(stats.zbiresParType) do table.insert(types, nom) end
		table.sort(types)
		local morceaux = {}
		for _, nom in ipairs(types) do
			table.insert(morceaux, nom .. "=" .. tostring(stats.zbiresParType[nom]))
		end
		local detail = "aucun"
		if #morceaux > 0 then detail = table.concat(morceaux, ", ") end
		print(string.format(
			"[Zsurvie] Analytique : %d run(s), %d défaite(s), jour moyen de défaite %.1f, meilleur jour %d | "
				.. "Zbires vaincus %d (%s) | pièces %d, gemmes %d | améliorations %d, recherches %d",
			stats.runs, stats.defaites, jourMoyen, math.floor(stats.jourMax),
			stats.zbiresTotal, detail, math.floor(stats.pieces), math.floor(stats.gemmes),
			stats.ameliorations, stats.recherches
		))
	end

	-- envoi des lots
	task.spawn(function()
		while true do
			task.wait(INTERVALLE_LOT)
			pcall(viderTousLesLots)
		end
	end)

	-- résumé périodique
	task.spawn(function()
		while true do
			task.wait(INTERVALLE_RESUME)
			pcall(resume)
		end
	end)
end

return M
