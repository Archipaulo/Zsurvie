-- Système Donnees : chargement et sauvegarde de la progression des joueurs (DataStore « DinoChapardeursV1 »).
-- Chargement à l'arrivée -> attributs du joueur, puis restauration des dinos dès que la Base est attribuée.
-- Sauvegarde : toutes les 60 s, au départ du joueur et à la fermeture du serveur.
-- Un joueur dont le chargement a échoué n'est JAMAIS sauvegardé (pour ne pas écraser sa vraie progression).
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local M = {}

local NOM_MAGASIN = "DinoChapardeursV1"
local ESSAIS = 3
local PAUSE_ESSAI = 1.5
local AUTOSAVE = 60
local ATTENTE_BASE = 15
local ATTENTE_FERMETURE = 25
local MAX_CLES = 200

local CHAMPS_NOMBRES = { "Argent", "Renaissances", "Vols", "BonusIndex", "Serie", "DerniereConnexion", "CoffreOuvert" }

local function estFini(n)
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

local function positif(n)
	if not estFini(n) or n < 0 then return 0 end
	return n
end

local function cleValide(cle)
	return type(cle) == "string" and #cle > 0 and #cle <= 40 and string.match(cle, "^[%w_]+$") ~= nil
end

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Plan = ctx.Plan

	local maxDinos = 24
	if Plan and Plan.base and estFini(Plan.base.emplacementsMax) then
		maxDinos = math.max(12, math.floor(Plan.base.emplacementsMax)) * 2
	end

	local argentDepart = 0
	if estFini(E.argentDepart) and E.argentDepart >= 0 then
		argentDepart = math.floor(E.argentDepart)
	end

	-- état par joueur (clé : UserId)
	local charges = {}       -- true : données chargées avec succès (le joueur peut être sauvegardé)
	local captures = {}      -- liste de dinos relevée juste avant la destruction de la Base
	local sauvegardes = {}   -- nombre de sauvegardes en cours pour ce joueur
	local enCours = 0        -- nombre total de sauvegardes en cours
	local fermeture = false

	-- ===== le magasin =====
	local magasin = nil
	local okMagasin, resultat = pcall(function()
		return DataStoreService:GetDataStore(NOM_MAGASIN)
	end)
	if okMagasin then
		magasin = resultat
	else
		print("[Dino] sauvegardes indisponibles (DataStore inaccessible) : la progression ne sera pas enregistrée.")
	end

	local function cleDe(uid)
		return "Joueur_" .. tostring(uid)
	end

	local function notifier(joueur, texte, genre)
		local ev = ctx.Reseau and ctx.Reseau.Notification
		if ev and joueur.Parent == Players then
			pcall(function()
				ev:FireClient(joueur, texte, genre)
			end)
		end
	end

	-- ===== lecture des dinos d'un joueur =====
	-- Enclos ou EnRoute ; un dino porté par un voleur appartient encore à sa victime,
	-- sauf au départ de la victime (avecPortes faux) : Vol laisse alors le voleur le livrer,
	-- le garder dans la sauvegarde le dupliquerait.
	local function releverDinos(uid, avecPortes)
		local liste = {}
		local ok = pcall(function()
			for _, dino in ipairs(ctx.dinos:GetChildren()) do
				if #liste >= maxDinos then break end
				if dino:IsA("Model") and dino:GetAttribute("Proprietaire") == uid then
					local etat = dino:GetAttribute("Etat")
					if etat == "Enclos" or etat == "EnRoute" or (etat == "Porte" and avecPortes) then
						local espece = dino:GetAttribute("Espece")
						local mutation = dino:GetAttribute("Mutation")
						if type(espece) == "string" and E.especes[espece] then
							if type(mutation) ~= "string" or not (E.mutations and E.mutations[mutation]) then
								mutation = "Normal"
							end
							table.insert(liste, { Espece = espece, Mutation = mutation })
						end
					end
				end
			end
		end)
		if not ok then return nil end
		return liste
	end

	-- dès que la Base est libérée (le joueur part), Enclos détruit ses dinos : on les relève avant.
	-- Cet écouteur est enregistré avant celui d'Enclos (Donnees démarre en premier).
	Bus.ecouter("BaseLiberee", function(joueur)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		local uid = joueur.UserId
		if charges[uid] then
			local liste = releverDinos(uid, false)
			if liste then captures[uid] = liste end
		end
	end)

	Bus.ecouter("BaseAttribuee", function(joueur)
		if typeof(joueur) == "Instance" and joueur:IsA("Player") then
			captures[joueur.UserId] = nil
		end
	end)

	-- ===== construction de la fiche à sauvegarder =====
	local function fiche(joueur, dinos)
		local f = {
			Objets = {},
			Index = {},
			Dinos = dinos or {},
		}
		for _, nom in ipairs(CHAMPS_NOMBRES) do
			f[nom] = positif(joueur:GetAttribute(nom))
		end
		local nbObjets, nbIndex = 0, 0
		for cle, valeur in pairs(joueur:GetAttributes()) do
			if valeur == true then
				local objet = string.match(cle, "^Objet_(.+)$")
				local espece = string.match(cle, "^Index_(.+)$")
				if objet and cleValide(objet) and nbObjets < MAX_CLES then
					f.Objets[objet] = true
					nbObjets = nbObjets + 1
				elseif espece and cleValide(espece) and nbIndex < MAX_CLES then
					f.Index[espece] = true
					nbIndex = nbIndex + 1
				end
			end
		end
		return f
	end

	-- ===== sauvegarde =====
	local function ecrire(uid, f)
		local cle = cleDe(uid)
		for essai = 1, ESSAIS do
			local ok = pcall(function()
				magasin:UpdateAsync(cle, function()
					return f
				end)
			end)
			if ok then return true end
			if essai < ESSAIS then task.wait(PAUSE_ESSAI * essai) end
		end
		return false
	end

	local function sauvegarder(joueur, dinos)
		if not magasin then return false end
		local uid = joueur.UserId
		if not charges[uid] then return false end
		local okFiche, f = pcall(fiche, joueur, dinos)
		if not okFiche or type(f) ~= "table" then return false end

		sauvegardes[uid] = (sauvegardes[uid] or 0) + 1
		enCours = enCours + 1
		local ok = ecrire(uid, f)
		enCours = enCours - 1
		sauvegardes[uid] = sauvegardes[uid] - 1
		if sauvegardes[uid] <= 0 then sauvegardes[uid] = nil end
		if not ok then
			warn("[Dino] sauvegarde impossible pour " .. joueur.Name .. " après " .. ESSAIS .. " essais.")
		end
		return ok
	end

	-- ===== lecture =====
	local function lire(uid)
		if not magasin then return false, nil end
		local cle = cleDe(uid)
		for essai = 1, ESSAIS do
			local ok, donnees = pcall(function()
				return magasin:GetAsync(cle)
			end)
			if ok then return true, donnees end
			if essai < ESSAIS then task.wait(PAUSE_ESSAI * essai) end
		end
		return false, nil
	end

	-- ===== application des données au joueur =====
	local function appliquer(joueur, donnees)
		if type(donnees) ~= "table" then donnees = {} end
		for _, nom in ipairs(CHAMPS_NOMBRES) do
			local valeur = donnees[nom]
			if estFini(valeur) and valeur >= 0 then
				joueur:SetAttribute(nom, valeur)
			elseif nom == "Argent" then
				joueur:SetAttribute(nom, argentDepart)
			else
				joueur:SetAttribute(nom, 0)
			end
		end
		if type(donnees.Objets) == "table" then
			local n = 0
			for nom, valeur in pairs(donnees.Objets) do
				if valeur == true and cleValide(nom) and n < MAX_CLES then
					joueur:SetAttribute("Objet_" .. nom, true)
					n = n + 1
				end
			end
		end
		if type(donnees.Index) == "table" then
			local n = 0
			for espece, valeur in pairs(donnees.Index) do
				if valeur == true and cleValide(espece) and n < MAX_CLES then
					joueur:SetAttribute("Index_" .. espece, true)
					n = n + 1
				end
			end
		end
	end

	-- liste des dinos à restaurer : seulement les espèces qui existent encore
	local function dinosValides(donnees)
		local liste = {}
		if type(donnees) ~= "table" or type(donnees.Dinos) ~= "table" then return liste end
		for _, d in ipairs(donnees.Dinos) do
			if #liste >= maxDinos then break end
			if type(d) == "table" and type(d.Espece) == "string" and E.especes[d.Espece] then
				local mutation = d.Mutation
				if type(mutation) ~= "string" or not (E.mutations and E.mutations[mutation]) then
					mutation = "Normal"
				end
				table.insert(liste, { Espece = d.Espece, Mutation = mutation })
			end
		end
		return liste
	end

	-- attend l'attribut Base (15 s max) puis demande la restauration des dinos
	local function restaurer(joueur, liste)
		if #liste == 0 then return end
		local debut = os.clock()
		while joueur.Parent == Players and os.clock() - debut < ATTENTE_BASE do
			local base = joueur:GetAttribute("Base")
			if type(base) == "number" and base > 0 then break end
			task.wait(0.25)
		end
		if joueur.Parent ~= Players then return end
		local base = joueur:GetAttribute("Base")
		if type(base) ~= "number" or base <= 0 then return end
		Bus.emettre("RestaurerDinos", joueur, liste)
	end

	-- ===== arrivée =====
	local traites = {}

	local function arrivee(joueur)
		local uid = joueur.UserId
		if traites[joueur] then return end
		traites[joueur] = true
		charges[uid] = nil
		captures[uid] = nil

		-- retour rapide sur le même serveur : on attend la fin de la sauvegarde de départ
		-- (sinon on relirait l'ancienne fiche, et la fin du départ effacerait charges[uid])
		local debutAttente = os.clock()
		while sauvegardes[uid] and os.clock() - debutAttente < ATTENTE_FERMETURE do
			task.wait(0.2)
		end
		if joueur.Parent ~= Players then
			traites[joueur] = nil
			return
		end

		local ok, donnees = lire(uid)
		if joueur.Parent ~= Players then
			traites[joueur] = nil
			return
		end
		if ok then
			local okApp = pcall(appliquer, joueur, donnees)
			if okApp then
				charges[uid] = true
			else
				pcall(appliquer, joueur, nil)
			end
		else
			pcall(appliquer, joueur, nil)
		end
		joueur:SetAttribute("DonneesChargees", true)

		if not charges[uid] then
			if magasin then
				notifier(joueur, "Tes données n'ont pas pu être chargées : ta progression de cette partie ne sera pas sauvegardée.", "alerte")
			end
			return
		end

		local liste = dinosValides(donnees)
		restaurer(joueur, liste)
	end

	-- ===== départ =====
	local function depart(joueur)
		local uid = joueur.UserId
		traites[joueur] = nil
		if not charges[uid] then
			captures[uid] = nil
			return
		end
		-- déjà pris en charge par la fermeture du serveur
		if fermeture and sauvegardes[uid] then return end
		-- relevé immédiat (avant que la Base soit vidée), sinon la capture faite à BaseLiberee
		local liste = captures[uid]
		if not liste then
			liste = releverDinos(uid, false)
		end
		if not liste then liste = {} end
		sauvegarder(joueur, liste)
		charges[uid] = nil
		captures[uid] = nil
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(arrivee, joueur)
	end
	Players.PlayerAdded:Connect(arrivee)
	Players.PlayerRemoving:Connect(depart)

	-- ===== sauvegarde automatique =====
	task.spawn(function()
		while not fermeture do
			task.wait(AUTOSAVE)
			if fermeture then break end
			local liste = Players:GetPlayers()
			for i, joueur in ipairs(liste) do
				if fermeture then break end
				local uid = joueur.UserId
				if joueur.Parent == Players and charges[uid] and not sauvegardes[uid] then
					local dinos = releverDinos(uid, true)
					if dinos then
						sauvegarder(joueur, dinos)
					end
				end
				-- étale les requêtes pour ménager le budget du DataStore
				if i < #liste then task.wait(0.5) end
			end
		end
	end)

	-- ===== fermeture du serveur =====
	game:BindToClose(function()
		fermeture = true
		local debut = os.clock()
		for _, joueur in ipairs(Players:GetPlayers()) do
			local uid = joueur.UserId
			if charges[uid] and not sauvegardes[uid] then
				local dinos = captures[uid] or releverDinos(uid, true) or {}
				task.spawn(function()
					sauvegarder(joueur, dinos)
					charges[uid] = nil
				end)
			end
		end
		-- attend aussi les sauvegardes de départ déjà en cours (25 s max)
		task.wait(0.1)
		while enCours > 0 and os.clock() - debut < ATTENTE_FERMETURE do
			task.wait(0.2)
		end
	end)
end

return M
