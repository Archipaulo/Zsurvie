-- Interface/Sons : banque de bruitages du jeu (sons intégrés uniquement).
-- Joue sur le Bus local « Son » et réagit aux Effets et Notifications du serveur.
-- Chaque son est fait de couches (fichier, vitesse, volume, retard) ; un petit
-- réservoir de Sound par couche permet les chevauchements sans coupure.
local SoundService = game:GetService("SoundService")

local M = {}

local INTERVALLE_MIN = 0.05 -- anti-cacophonie : délai minimal entre deux lectures d'un même son
local TAILLE_RESERVOIR = 3 -- lectures simultanées possibles par couche
local VOLUME_GENERAL = 0.5
local DISTANCE_PLEINE = 40 -- en deçà, un effet du monde s'entend à plein volume
local DISTANCE_MAX = 220 -- au-delà, il ne s'entend plus
local VOLUME_LOINTAIN = 0.15 -- volume relatif juste avant la limite

-- série d'encaissements : la tonalité monte à chaque gain rapproché (style « juicy »)
local SERIE_DELAI = 1.5 -- sans gain pendant ce délai, la tonalité revient à la normale

-- raretés qui déclenchent le son « rare » renforcé (ordre d'Equilibrage.raretes)
local ORDRE_FORT = 5 -- Mythique et au-delà
local RARETES_FORTES = { Mythique = true, Divin = true, Secret = true } -- repli sans Equilibrage

local S = "rbxasset://sounds/"

-- ===== accord avec la musique =====
-- La musique (Interface/Musique) est en do majeur. Le son « ping » intégré est pris comme un do5 (MIDI 72),
-- la même hypothèse que le repli de la musique : chaque bruitage mélodique joue des notes de la gamme de do
-- (surtout la pentatonique do-ré-mi-sol-la), et les grandes fanfares tombent sur le demi-temps suivant.
local PING = S .. "electronicpingshort.wav"
local function n(midi) return 2 ^ ((midi - 72) / 12) end
local DO5, RE5, MI5, SOL5, LA5, DO6, MI6, SOL6 = 72, 74, 76, 79, 81, 84, 88, 91

-- banque : nom -> liste de couches { fichier, vitesse, volume, retard }
local BANQUE = {
	clic = {
		{ S .. "button.wav", 1.2, 0.3, 0 },
	},
	achat = { -- quinte montante sol-do
		{ PING, n(SOL5), 0.45, 0 },
		{ PING, n(DO6), 0.4, 0.09 },
	},
	refus = { -- un « bonk » grave et doux, sans note fausse
		{ S .. "button.wav", 0.6, 0.4, 0 },
	},
	argent = { -- tierce do-mi ; la série d'encaissements monte dans la pentatonique
		{ PING, n(DO6), 0.35, 0 },
		{ PING, n(MI6), 0.25, 0.05 },
	},
	vol = {
		{ S .. "swordlunge.wav", 0.8, 0.45, 0 },
		{ PING, n(LA5 - 12), 0.35, 0.06 },
	},
	alerte = { -- la mineur : inquiétant mais dans le ton
		{ PING, n(LA5 - 12), 0.45, 0 },
		{ PING, n(DO5), 0.4, 0.16 },
	},
	alerteGrave = {
		{ PING, n(LA5 - 24), 0.55, 0 },
		{ PING, n(MI5 - 12), 0.5, 0.2 },
		{ S .. "impact_water.mp3", 0.45, 0.45, 0.1 },
	},
	frappe = {
		{ S .. "swordslash.wav", 1.0, 0.5, 0 },
		{ S .. "action_jump.mp3", 0.6, 0.25, 0.03 },
	},
	verrou = {
		{ S .. "clickfast.wav", 0.7, 0.45, 0 },
		{ PING, n(SOL5 - 12), 0.35, 0.07 },
	},
	deverrou = {
		{ S .. "clickfast.wav", 1.1, 0.4, 0 },
		{ PING, n(DO5), 0.3, 0.07 },
	},
	rare = { -- arpège do-mi-sol
		{ PING, n(DO5), 0.4, 0 },
		{ PING, n(MI5), 0.4, 0.09 },
		{ PING, n(SOL5), 0.45, 0.18 },
	},
	rareFort = { -- arpège do-mi-sol-do-mi, cloche d'eau à la fin
		{ PING, n(DO5), 0.6, 0 },
		{ PING, n(MI5), 0.6, 0.08 },
		{ PING, n(SOL5), 0.65, 0.16 },
		{ PING, n(DO6), 0.7, 0.24 },
		{ PING, n(MI6), 0.6, 0.32 },
		{ S .. "impact_water.mp3", 1.3, 0.35, 0.32 },
	},
	renaissance = { -- montée do-mi-sol-do puis accord
		{ PING, n(DO5), 0.45, 0 },
		{ PING, n(MI5), 0.45, 0.13 },
		{ PING, n(SOL5), 0.45, 0.26 },
		{ PING, n(DO6), 0.55, 0.39 },
		{ PING, n(MI6), 0.4, 0.39 },
		{ S .. "impact_water.mp3", 0.7, 0.35, 0.39 },
	},
	decouverte = {
		{ PING, n(SOL5), 0.4, 0 },
		{ PING, n(DO6), 0.4, 0.1 },
		{ PING, n(MI6), 0.35, 0.2 },
	},
	eclosion = { -- craquement puis fanfare do-sol-do-mi-sol
		{ S .. "snap.wav", 1.0, 0.5, 0 },
		{ PING, n(DO5), 0.55, 0.12 },
		{ PING, n(SOL5), 0.55, 0.2 },
		{ PING, n(DO6), 0.6, 0.28 },
		{ PING, n(MI6), 0.6, 0.36 },
		{ PING, n(SOL6), 0.55, 0.44 },
		{ S .. "impact_water.mp3", 1.1, 0.35, 0.44 },
	},
}

-- série d'encaissements : degrés de la pentatonique (do ré mi sol la do…) en rapports de vitesse
local SERIE_NOTES = { 0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24 }
-- gros bruitages : la musique s'efface un peu (force, durée) et ils tombent sur le demi-temps
local DUCKING = { rareFort = { 0.45, 1.2 }, renaissance = { 0.5, 1.5 }, eclosion = { 0.55, 1.6 }, alerteGrave = { 0.4, 1 }, vol = { 0.3, 0.8 } }
local EN_RYTHME = { rareFort = true, renaissance = true, eclosion = true, decouverte = true }

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
	Eclosion = "eclosion",
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
	-- même salle que la musique et des aigus adoucis : bruitages et piano se fondent
	local salle = Instance.new("ReverbSoundEffect")
	salle.DecayTime = 1.6
	salle.DryLevel = -1
	salle.WetLevel = -12
	salle.Parent = groupe
	local egaliseur = Instance.new("EqualizerSoundEffect")
	egaliseur.HighGain = -3
	egaliseur.MidGain = 0
	egaliseur.LowGain = 0
	egaliseur.Parent = groupe

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

	-- série d'encaissements en cours
	local serie = 0
	local dernierGain = 0

	-- hausse de tonalité pour ce gain, puis prolonge la série
	local function tonaliteGain(maintenant)
		if maintenant - dernierGain > SERIE_DELAI then
			serie = 0
		end
		dernierGain = maintenant
		local degre = SERIE_NOTES[math.min(serie + 1, #SERIE_NOTES)]
		serie = serie + 1
		return 2 ^ (degre / 12)
	end

	local function lireCouche(entree, facteur, vitesse)
		local son = entree.sons[entree.prochain]
		entree.prochain = entree.prochain % #entree.sons + 1
		if not son or not son.Parent then return end
		pcall(function()
			son.Volume = entree.couche[3] * facteur
			son.PlaybackSpeed = entree.couche[2] * vitesse
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
		local vitesse = 1
		if nom == "argent" then
			vitesse = tonaliteGain(maintenant)
		end
		local d = DUCKING[nom]
		if d and ctx.Bus then ctx.Bus.emettre("Ducking", d[1], d[2]) end
		-- fanfares : calées sur le demi-temps suivant de la musique (au plus un quart de seconde d'attente)
		local attente = 0
		if EN_RYTHME[nom] and ctx.Bus then
			local position, secParTemps = ctx.Bus.demander("TempsMusique")
			if type(position) == "number" and type(secParTemps) == "number" and secParTemps > 0 then
				local reste = (0.5 - (position % 0.5)) * secParTemps
				if reste <= 0.25 then attente = reste end
			end
		end
		for _, entree in ipairs(liste) do
			local retard = (entree.couche[4] or 0) + attente
			if retard > 0 then
				task.delay(retard, lireCouche, entree, facteur, vitesse)
			else
				lireCouche(entree, facteur, vitesse)
			end
		end
	end

	-- vrai si la rareté vaut Mythique ou mieux
	local function rareteForte(rarete)
		if type(rarete) ~= "string" then return false end
		if RARETES_FORTES[rarete] then return true end
		local raretes = ctx.Equilibrage and ctx.Equilibrage.raretes
		local def = raretes and raretes[rarete]
		if type(def) == "table" and type(def.ordre) == "number" then
			return def.ordre >= ORDRE_FORT
		end
		return false
	end

	-- raretés animées de la charte visuelle (Divin, Secret) : toujours du côté fort
	local Style = ctx.Style
	if Style and type(Style.raretes) == "table" then
		for nomRarete, def in pairs(Style.raretes) do
			if type(def) == "table" and def.anime then
				RARETES_FORTES[nomRarete] = true
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
			local fort = type(donnees) == "table" and rareteForte(donnees.rarete)
			if genre == "Apparition" and fort then
				nom = "rareFort"
			end
			local facteur = 1
			if not GLOBAUX[genre] then
				facteur = attenuation(position)
			end
			-- un dino Mythique+ s'entend de loin, et son achat sonne comme un événement
			if fort and (genre == "Apparition" or genre == "Achat") then
				facteur = math.max(facteur, 0.6)
				if genre == "Achat" then
					jouer("rareFort", facteur)
				end
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

	-- « clic » sur chaque bouton de l'interface (anti-cacophonie : un seul par pression)
	local gui = ctx.gui
	if gui then
		local branches = {}
		setmetatable(branches, { __mode = "k" })
		local function brancher(objet)
			if branches[objet] then return end
			if not objet:IsA("TextButton") then return end
			branches[objet] = true
			objet.Activated:Connect(function()
				jouer("clic", 1)
			end)
		end
		for _, objet in ipairs(gui:GetDescendants()) do
			brancher(objet)
		end
		gui.DescendantAdded:Connect(brancher)
	end
end

return M
