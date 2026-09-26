-- Interface/Sons : banque de sons locale (sons intégrés à Roblox) et lecture sur événements.
-- Joue sur le Bus client « Son », sur Reseau.Effet, Reseau.Notification et les changements de Phase.
local SoundService = game:GetService("SoundService")

local M = {}

local INTERVALLE_MIN = 0.05 -- un même son au plus toutes les 0,05 s
local VOIX_PAR_SON = 3 -- lectures simultanées possibles d'un même son
local DISTANCE_PLEINE = 30 -- en deçà, le tir est joué à plein volume
local DISTANCE_MUETTE = 180 -- au-delà, le tir est joué au volume plancher
local VOLUME_PLANCHER = 0.15
local FENETRE_TIR_LOCAL = 0.35 -- un tir serveur proche d'un tir local récent a déjà été entendu
local DISTANCE_TIR_LOCAL = 8

-- nom -> fichier intégré, volume, hauteur (PlaybackSpeed)
local DEFINITIONS = {
	clic = { fichier = "rbxasset://sounds/button.wav", volume = 0.5, hauteur = 1.2 },
	tir = { fichier = "rbxasset://sounds/swordslash.wav", volume = 0.35, hauteur = 1.6 },
	impact = { fichier = "rbxasset://sounds/hit.wav", volume = 0.5, hauteur = 1.1 },
	impactGrave = { fichier = "rbxasset://sounds/hit.wav", volume = 0.7, hauteur = 0.6 },
	piece = { fichier = "rbxasset://sounds/electronicpingshort.wav", volume = 0.45, hauteur = 1.5 },
	gemme = { fichier = "rbxasset://sounds/electronicpingshort.wav", volume = 0.55, hauteur = 2.1 },
	achat = { fichier = "rbxasset://sounds/snap.wav", volume = 0.6, hauteur = 1.3 },
	refus = { fichier = "rbxasset://sounds/uuhhh.mp3", volume = 0.5, hauteur = 1.4 },
	alerte = { fichier = "rbxasset://sounds/bass.wav", volume = 0.8, hauteur = 0.8 },
	victoire = { fichier = "rbxasset://sounds/victory.wav", volume = 0.6, hauteur = 1 },
	defaite = { fichier = "rbxasset://sounds/uuhhh.mp3", volume = 0.7, hauteur = 0.7 },
	saut = { fichier = "rbxasset://sounds/action_jump.mp3", volume = 0.5, hauteur = 1.1 },
}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat

	-- dossier de la banque (SoundService, sinon dossier local du joueur)
	local parent = SoundService
	local okParent = pcall(function()
		local _ = SoundService.Name
	end)
	if not okParent or SoundService == nil then
		parent = ctx.joueur
	end
	local banque = parent:FindFirstChild("ZsurvieSons")
	if banque then
		banque:Destroy()
	end
	banque = Instance.new("Folder")
	banque.Name = "ZsurvieSons"
	banque.Parent = parent

	-- création des voix de chaque son
	local voix = {}
	local prochaineVoix = {}
	local dernierJeu = {}
	for nom, def in pairs(DEFINITIONS) do
		local liste = {}
		for i = 1, VOIX_PAR_SON do
			local ok, son = pcall(function()
				local s = Instance.new("Sound")
				s.Name = nom .. "_" .. tostring(i)
				s.SoundId = def.fichier
				s.Volume = def.volume
				s.PlaybackSpeed = def.hauteur
				s.Parent = banque
				return s
			end)
			if ok and son then
				table.insert(liste, son)
			end
		end
		voix[nom] = liste
		prochaineVoix[nom] = 1
		dernierJeu[nom] = 0
	end

	-- joue un son par son nom ; facteur optionnel sur le volume (0..1)
	local function jouer(nom, facteur)
		if type(nom) ~= "string" then return end
		local def = DEFINITIONS[nom]
		local liste = voix[nom]
		if not def or not liste or #liste == 0 then return end
		local maintenant = os.clock()
		if maintenant - dernierJeu[nom] < INTERVALLE_MIN then return end
		dernierJeu[nom] = maintenant
		local index = prochaineVoix[nom]
		local son = liste[index]
		index = index + 1
		if index > #liste then index = 1 end
		prochaineVoix[nom] = index
		local f = 1
		if type(facteur) == "number" then
			f = math.clamp(facteur, 0, 1)
		end
		pcall(function()
			son.Volume = def.volume * f
			son.TimePosition = 0
			son:Play()
		end)
	end

	-- facteur de volume selon la distance entre la caméra et une position
	local function facteurDistance(position)
		if typeof(position) ~= "Vector3" then return 1 end
		local camera = workspace.CurrentCamera
		if not camera then return 1 end
		local distance = (camera.CFrame.Position - position).Magnitude
		if distance <= DISTANCE_PLEINE then return 1 end
		if distance >= DISTANCE_MUETTE then return VOLUME_PLANCHER end
		local t = (distance - DISTANCE_PLEINE) / (DISTANCE_MUETTE - DISTANCE_PLEINE)
		return 1 - t * (1 - VOLUME_PLANCHER)
	end

	-- bus client
	Bus.ecouter("Son", function(nom)
		jouer(nom)
	end)

	-- tir local récent : son déjà joué par Interface/Blaster, l'écho serveur ne le rejoue pas
	local dernierTirLocal = -10
	local origineTirLocal = nil
	Bus.ecouter("TirLocal", function(origine)
		if typeof(origine) == "Vector3" then
			dernierTirLocal = os.clock()
			origineTirLocal = origine
		end
	end)
	local function echoTirLocal(donnees)
		if os.clock() - dernierTirLocal > FENETRE_TIR_LOCAL or not origineTirLocal then return false end
		if type(donnees) ~= "table" or typeof(donnees.origine) ~= "Vector3" then return false end
		return (donnees.origine - origineTirLocal).Magnitude <= DISTANCE_TIR_LOCAL
	end

	-- effets envoyés par le serveur
	local SONS_EFFET = {
		Impact = "impact",
		Vaincu = "impactGrave",
		Piece = "piece",
		Gemme = "gemme",
		Colosse = "alerte",
		JourDebut = "victoire",
	}
	if Reseau and Reseau.Effet then
		Reseau.Effet.OnClientEvent:Connect(function(genre, position, donnees)
			if type(genre) ~= "string" then return end
			if genre == "Tir" then
				if not echoTirLocal(donnees) then
					jouer("tir", facteurDistance(position))
				end
			elseif SONS_EFFET[genre] then
				jouer(SONS_EFFET[genre])
			end
		end)
	end

	-- notifications
	if Reseau and Reseau.Notification then
		Reseau.Notification.OnClientEvent:Connect(function(_, genre)
			if genre == "alerte" then
				jouer("alerte")
			elseif genre == "succes" then
				jouer("achat")
			end
		end)
	end

	-- changements de phase
	if Etat then
		Etat:GetAttributeChangedSignal("Phase"):Connect(function()
			local phase = Etat:GetAttribute("Phase")
			if phase == "Defaite" then
				jouer("defaite")
			elseif phase == "Repit" then
				jouer("victoire")
			end
		end)
	end
end

return M
