-- Interface Musique : la musique de fond, « Symphonie de la jungle » pour piano (do majeur, 76 bpm).
-- Trois façons de la jouer, de la meilleure à la plus simple :
--   1. MUSIQUE_ID : l'enregistrement complet (musique/symphonie-piano.wav, à téléverser sur Roblox) en boucle ;
--   2. NOTE_PIANO_ID : un do4 de piano (musique/note-piano-do4.wav) ; la partition (ReplicatedStorage.Dino.Partition)
--      est jouée note par note en transposant ce son ;
--   3. sinon, la même partition jouée par un son intégré de Roblox (timbre de boîte à musique).
-- Pendant un événement la musique s'anime un peu (plus vite, plus forte) ; quand on porte un dino volé, elle
-- accélère encore. Elle s'efface légèrement sous les gros bruitages (Bus local « Ducking », envoyé par Interface/Sons).
-- Bouton rond « 🎵 » en haut à droite pour couper la musique (attribut local MusiqueCoupee).
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local M = {}

-- ===== à compléter après téléversement sur Roblox (Creator Hub > Création > Audio) =====
local MUSIQUE_ID = ""    -- ex. "rbxassetid://123456789" : musique/symphonie-piano.wav
local NOTE_PIANO_ID = "" -- ex. "rbxassetid://123456789" : musique/note-piano-do4.wav (do4 = MIDI 60)
-- repli sans téléversement : un son intégré, supposé proche d'un do5 (MIDI 72), joué plus doucement
local NOTE_REPLI = { id = "rbxasset://sounds/electronicpingshort.wav", midi = 72, volume = 0.45 }

local VOLUME = 0.32
local VOIX = 28 -- notes simultanées possibles
local ACCELERATION = { Evenement = 1.08, Vol = 1.15 }

function M.demarrer(ctx)
	local joueur = ctx.joueur
	local Etat = ctx.Etat
	local Bus = ctx.Bus
	local Style = ctx.Style

	local ancien = SoundService:FindFirstChild("DinoMusique")
	if ancien then pcall(function() ancien:Destroy() end) end
	local dossier = Instance.new("Folder")
	dossier.Name = "DinoMusique"
	dossier.Parent = SoundService

	local groupe = Instance.new("SoundGroup")
	groupe.Name = "Musique"
	groupe.Volume = VOLUME
	groupe.Parent = dossier
	-- un peu de salle, des aigus adoucis : un piano chaleureux qui laisse la place aux bruitages
	local salle = Instance.new("ReverbSoundEffect")
	salle.DecayTime = 2.2
	salle.Density = 0.9
	salle.Diffusion = 0.9
	salle.DryLevel = -2
	salle.WetLevel = -9
	salle.Parent = groupe
	local egaliseur = Instance.new("EqualizerSoundEffect")
	egaliseur.HighGain = -4
	egaliseur.MidGain = 0
	egaliseur.LowGain = 1
	egaliseur.Parent = groupe

	local coupee = joueur:GetAttribute("MusiqueCoupee") == true
	local vitesse = 1
	local volumeCible = VOLUME

	-- réglage du joueur (panneau ⚙️ Réglages) : 0..1
	local function reglage()
		local v = joueur:GetAttribute("VolumeMusique")
		if type(v) ~= "number" then return 1 end
		return math.clamp(v, 0, 1)
	end
	local function appliquerVolume(duree)
		local v = volumeCible * reglage()
		if coupee then v = 0 end
		pcall(function()
			TweenService:Create(groupe, TweenInfo.new(duree or 1.2, Enum.EasingStyle.Sine), { Volume = v }):Play()
		end)
	end

	-- ===== mode 1 : l'enregistrement complet =====
	local piste = nil
	if MUSIQUE_ID ~= "" then
		piste = Instance.new("Sound")
		piste.Name = "Symphonie"
		piste.SoundId = MUSIQUE_ID
		piste.Looped = true
		piste.Volume = 1
		piste.SoundGroup = groupe
		piste.Parent = dossier
		piste:Play()
	end

	-- ===== modes 2 et 3 : la partition jouée note par note =====
	local partition = nil
	if not piste then
		local module = ReplicatedStorage:FindFirstChild("Dino") and ReplicatedStorage.Dino:FindFirstChild("Partition")
		if module then
			local ok, p = pcall(require, module)
			if ok and type(p) == "table" and type(p.notes) == "table" then partition = p end
		end
	end
	if partition then
		local source = { id = NOTE_PIANO_ID, midi = 60, volume = 1 }
		if NOTE_PIANO_ID == "" then source = NOTE_REPLI end
		local voix = {}
		for i = 1, VOIX do
			local s = Instance.new("Sound")
			s.Name = "Voix" .. i
			s.SoundId = source.id
			s.SoundGroup = groupe
			s.Parent = dossier
			voix[i] = s
		end
		local prochaineVoix = 1
		local function jouerNote(hauteur, velocite, dureeS)
			local s = voix[prochaineVoix]
			prochaineVoix = prochaineVoix % VOIX + 1
			s.PlaybackSpeed = 2 ^ ((hauteur - source.midi) / 12)
			s.Volume = velocite * source.volume
			s.TimePosition = 0
			s:Play()
			-- étouffoir : on laisse sonner un peu après la durée écrite puis on coupe en douceur
			local jeton = {}
			s:SetAttribute("Jeton", tostring(jeton))
			task.delay(dureeS + 0.9, function()
				if s:GetAttribute("Jeton") == tostring(jeton) then
					pcall(function() TweenService:Create(s, TweenInfo.new(0.4), { Volume = 0 }):Play() end)
				end
			end)
		end

		local notes = partition.notes
		local secParTemps = 60 / (partition.bpm or 76)
		local dureeBoucle = partition.duree or 136
		local position = 0 -- en battements
		local index = 1
		RunService.Heartbeat:Connect(function(dt)
			if coupee then return end
			local suivante = position + dt / secParTemps * vitesse
			if suivante >= dureeBoucle then
				-- fin de boucle : on joue ce qui reste puis on repart au début
				while index <= #notes do
					local n = notes[index]
					pcall(jouerNote, n[3], n[4], n[2] * secParTemps / vitesse)
					index = index + 1
				end
				suivante = suivante - dureeBoucle
				index = 1
			end
			while index <= #notes and notes[index][1] < suivante do
				local n = notes[index]
				pcall(jouerNote, n[3], n[4], n[2] * secParTemps / vitesse)
				index = index + 1
			end
			position = suivante
		end)
		-- Interface/Sons cale ses fanfares sur la pulsation
		if Bus then
			Bus.repondre("TempsMusique", function()
				return position, secParTemps / vitesse
			end)
		end
	end

	-- ===== ambiance : plus d'élan pendant un événement ou un vol =====
	local function actualiser()
		local v = 1
		local vol = VOLUME
		if Etat and type(Etat:GetAttribute("Evenement")) == "string" and Etat:GetAttribute("Evenement") ~= "" then
			v = ACCELERATION.Evenement
			vol = VOLUME * 1.15
		end
		local porte = joueur:GetAttribute("Porte")
		if type(porte) == "string" and porte ~= "" then
			v = ACCELERATION.Vol
			vol = VOLUME * 1.2
		end
		vitesse = v
		if piste then pcall(function() piste.PlaybackSpeed = v end) end
		volumeCible = vol
		appliquerVolume(1.5)
	end
	if Etat then Etat:GetAttributeChangedSignal("Evenement"):Connect(actualiser) end
	joueur:GetAttributeChangedSignal("Porte"):Connect(actualiser)
	actualiser()

	-- ===== la musique s'efface un instant sous les gros bruitages =====
	if Bus then
		Bus.ecouter("Ducking", function(force, duree)
			if coupee then return end
			force = math.clamp(tonumber(force) or 0.5, 0, 1)
			local bas = volumeCible * reglage() * (1 - force)
			pcall(function()
				local t = TweenService:Create(groupe, TweenInfo.new(0.08), { Volume = bas })
				t:Play()
				task.delay(tonumber(duree) or 0.6, function() appliquerVolume(0.8) end)
			end)
		end)
	end

	-- ===== bouton « 🎵 » =====
	local bouton, libelle
	pcall(function()
		bouton, libelle = Style.bouton(ctx.gui, {
			Name = "BoutonMusique",
			Size = UDim2.fromOffset(56, 56),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 64),
			couleur = "bleu",
			texte = "🎵",
			rayon = 28,
		}, function()
			joueur:SetAttribute("MusiqueCoupee", not coupee)
		end)
	end)
	local function majBouton()
		if not bouton then return end
		if libelle then libelle.Text = coupee and "🔇" or "🎵" end
		pcall(function() Style.couleurBouton(bouton, coupee and "gris" or "bleu") end)
	end
	joueur:GetAttributeChangedSignal("MusiqueCoupee"):Connect(function()
		coupee = joueur:GetAttribute("MusiqueCoupee") == true
		if piste then
			if coupee then pcall(function() piste:Pause() end) else pcall(function() piste:Resume() end) end
		end
		appliquerVolume(0.4)
		majBouton()
	end)
	joueur:GetAttributeChangedSignal("VolumeMusique"):Connect(function() appliquerVolume(0.15) end)
	majBouton()
	appliquerVolume(2)
end

return M
