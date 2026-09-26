-- Interface/Sons : banque de bruitages du jeu (sons intégrés uniquement).
-- Joue sur le Bus local « Son » et réagit aux Effets et Notifications du serveur.
-- Chaque son est fait de couches (fichier, vitesse, volume, retard) ; un petit
-- réservoir de Sound par couche permet les chevauchements sans coupure.
local SoundService = game:GetService("SoundService")

local M = {}

local INTERVALLE_MIN = 0.05 -- anti-cacophonie : délai minimal entre deux lectures d'un même son
local TAILLE_RESERVOIR = 3 -- lectures simultanées possibles par couche
local VOLUME_GENERAL = 0.6
local DISTANCE_PLEINE = 40 -- en deçà, un effet du monde s'entend à plein volume
local DISTANCE_MAX = 220 -- au-delà, il ne s'entend plus
local VOLUME_LOINTAIN = 0.15 -- volume relatif juste avant la limite

local S = "rbxasset://sounds/"

-- banque : nom -> liste de couches { fichier, vitesse, volume, retard }
local BANQUE = {
	clic = {
		{ S .. "button.wav", 1.25, 0.45, 0 },
	},
	achat = {
		{ S .. "electronicpingshort.wav", 1.0, 0.7, 0 },
		{ S .. "electronicpingshort.wav", 1.5, 0.55, 0.08 },
	},
	refus = {
		{ S .. "button.wav", 0.55, 0.6, 0 },
		{ S .. "button.wav", 0.45, 0.5, 0.09 },
	},
	argent = {
		{ S .. "electronicpingshort.wav", 1.8, 0.5, 0 },
		{ S .. "electronicpingshort.wav", 2.25, 0.4, 0.05 },
	},
	vol = {
		{ S .. "swordlunge.wav", 0.8, 0.6, 0 },
		{ S .. "unsheath.wav", 1.2, 0.35, 0.06 },
	},
	alerte = {
		{ S .. "electronicpingshort.wav", 0.7, 0.7, 0 },
		{ S .. "electronicpingshort.wav", 0.7, 0.7, 0.18 },
	},
	alerteGrave = {
		{ S .. "electronicpingshort.wav", 0.4, 0.8, 0 },
		{ S .. "electronicpingshort.wav", 0.4, 0.8, 0.25 },
		{ S .. "impact_water.mp3", 0.45, 0.6, 0.1 },
	},
	frappe = {
		{ S .. "swordslash.wav", 1.0, 0.65, 0 },
		{ S .. "action_jump.mp3", 0.6, 0.35, 0.03 },
	},
	verrou = {
		{ S .. "clickfast.wav", 0.7, 0.6, 0 },
		{ S .. "electronicpingshort.wav", 0.85, 0.45, 0.07 },
	},
	deverrou = {
		{ S .. "clickfast.wav", 1.1, 0.5, 0 },
		{ S .. "electronicpingshort.wav", 0.65, 0.35, 0.07 },
	},
	rare = {
		{ S .. "electronicpingshort.wav", 1.2, 0.55, 0 },
		{ S .. "electronicpingshort.wav", 1.5, 0.55, 0.09 },
		{ S .. "electronicpingshort.wav", 1.8, 0.6, 0.18 },
	},
	renaissance = {
		{ S .. "electronicpingshort.wav", 0.8, 0.6, 0 },
		{ S .. "electronicpingshort.wav", 1.0, 0.6, 0.12 },
		{ S .. "electronicpingshort.wav", 1.25, 0.6, 0.24 },
		{ S .. "electronicpingshort.wav", 1.6, 0.7, 0.36 },
		{ S .. "impact_water.mp3", 0.7, 0.45, 0.36 },
	},
	decouverte = {
		{ S .. "electronicpingshort.wav", 1.4, 0.55, 0 },
		{ S .. "electronicpingshort.wav", 1.9, 0.5, 0.1 },
		{ S .. "button.wav", 1.6, 0.3, 0.1 },
	},
}

-- genre d'Effet -> son (une fonction peut choisir selon les données)
local EFFETS = {
	Achat = "achat",
	Collecte = "argent",
	Vente = "argent",
	Coffre = "argent",
	VolDebut = "vol",
	Frappe = "frappe",
	Apparition = "rare",
	Renaissance = "renaissance",
	Decouverte = "decouverte",
	Meteore = "alerteGrave",
}

-- effets qui s'entendent partout, sans atténuation
local GLOBAUX = {
	Meteore = true,
	Decouverte = true,
}

-- genre de Notification -> son
local NOTIFICATIONS = {
	alerte = "alerte",
	vol = "alerte",
	succes = "achat",
}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau

	-- rangement des Sound
	local dossier = SoundService:FindFirstChild("DinoSons")
	if dossier then
		dossier:Destroy()
	end
	dossier = Instance.new("Folder")
	dossier.Name = "DinoSons"
	dossier.Parent = SoundService

	local groupe = Instance.new("SoundGroup")
	groupe.Name = "Effets"
	groupe.Volume = VOLUME_GENERAL
	groupe.Parent = dossier

	-- construction des réservoirs
	local reservoirs = {} -- [nom] = { { sons = {...}, prochain = 1, couche = {...} }, ... }
	for nom, couches in pairs(BANQUE) do
		local liste = {}
		for i, couche in ipairs(couches) do
			local sons = {}
			for j = 1, TAILLE_RESERVOIR do
				local son = Instance.new("Sound")
				son.Name = nom .. "_" .. i .. "_" .. j
				son.SoundId = couche[1]
				son.PlaybackSpeed = couche[2]
				son.Volume = couche[3]
				son.SoundGroup = groupe
				son.Parent = dossier
				sons[j] = son
			end
			liste[i] = { sons = sons, prochain = 1, couche = couche }
		end
		reservoirs[nom] = liste
	end

	local dernier = {} -- [nom] = os.clock() de la dernière lecture

	local function lireCouche(entree, facteur)
		local son = entree.sons[entree.prochain]
		entree.prochain = entree.prochain % #entree.sons + 1
		if not son or not son.Parent then return end
		pcall(function()
			son.Volume = entree.couche[3] * facteur
			son.TimePosition = 0
			son:Play()
		end)
	end

	-- joue un son de la banque ; facteur = volume relatif (1 par défaut)
	local function jouer(nom, facteur)
		if type(nom) ~= "string" then return end
		local liste = reservoirs[nom]
		if not liste then return end
		facteur = tonumber(facteur) or 1
		if facteur <= 0 then return end
		local maintenant = os.clock()
		local precedent = dernier[nom]
		if precedent and maintenant - precedent < INTERVALLE_MIN then return end
		dernier[nom] = maintenant
		for _, entree in ipairs(liste) do
			local retard = entree.couche[4] or 0
			if retard > 0 then
				task.delay(retard, lireCouche, entree, facteur)
			else
				lireCouche(entree, facteur)
			end
		end
	end

	-- volume relatif selon la distance entre la caméra et l'effet
	local function attenuation(position)
		if typeof(position) ~= "Vector3" then return 1 end
		local camera = workspace.CurrentCamera
		local origine = nil
		if camera then
			origine = camera.CFrame.Position
		end
		local perso = ctx.joueur.Character
		local racine = perso and perso:FindFirstChild("HumanoidRootPart")
		if racine and racine:IsA("BasePart") then
			origine = racine.Position
		end
		if not origine then return 1 end
		local d = (position - origine).Magnitude
		if d <= DISTANCE_PLEINE then return 1 end
		if d >= DISTANCE_MAX then return 0 end
		local t = (d - DISTANCE_PLEINE) / (DISTANCE_MAX - DISTANCE_PLEINE)
		return 1 - t * (1 - VOLUME_LOINTAIN)
	end

	-- sons demandés par les autres modules d'interface
	Bus.ecouter("Son", function(nom)
		jouer(nom, 1)
	end)

	-- effets du serveur
	local effet = Reseau and Reseau.Effet
	if effet then
		effet.OnClientEvent:Connect(function(genre, position, donnees)
			if type(genre) ~= "string" then return end
			local nom = EFFETS[genre]
			if genre == "Verrou" then
				nom = "verrou"
				if type(donnees) == "table" and donnees.actif == false then
					nom = "deverrou"
				end
			end
			if not nom then return end
			local facteur = 1
			if not GLOBAUX[genre] then
				facteur = attenuation(position)
			end
			-- un vol qui nous concerne s'entend toujours à plein volume
			if genre == "VolDebut" and type(donnees) == "table" then
				local moi = ctx.joueur.UserId
				local voleur = donnees.voleur
				local victime = donnees.victime
				if voleur == moi or victime == moi or voleur == ctx.joueur or victime == ctx.joueur then
					facteur = 1
				end
			end
			jouer(nom, facteur)
		end)
	end

	-- notifications du serveur
	local notification = Reseau and Reseau.Notification
	if notification then
		notification.OnClientEvent:Connect(function(texte, genre)
			if type(genre) ~= "string" then return end
			local nom = NOTIFICATIONS[genre]
			if nom then
				jouer(nom, 1)
			end
		end)
	end
end

return M
