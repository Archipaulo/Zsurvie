-- Builders/Ciel.lua : ambiance du ciel (service Lighting uniquement, aucune part).
-- Atmosphere, Sky, nuages du Terrain, Bloom et correction colorimétrique doux.
-- L'ambiance suit la phase de jeu (Etat.Phase) et s'assombrit quand un Colosse est en jeu.
local M = {}

local DUREE_TRANSITION = 3

-- noms de nos instances dans Lighting (pour les retrouver et éviter les doublons)
local NOM_ATMO = "ZsurvieAtmosphere"
local NOM_CIEL = "ZsurvieCiel"
local NOM_BLOOM = "ZsurvieBloom"
local NOM_CORRECTION = "ZsurvieCorrection"

-- teinte neutre : identité de la correction colorimétrique (aucune coloration)
local NEUTRE = Color3.new(1, 1, 1)

local function service(nom)
	local ok, s = pcall(function()
		return game:GetService(nom)
	end)
	if ok then
		return s
	end
	return nil
end

-- réutilise une instance de la bonne classe si elle existe déjà, sinon la crée
local function obtenir(parent, classe, nom)
	local existante = parent:FindFirstChild(nom)
	if existante and existante:IsA(classe) then
		return existante
	end
	if existante then
		existante:Destroy()
	end
	local inst = Instance.new(classe)
	inst.Name = nom
	inst.Parent = parent
	return inst
end

-- retire les instances uniques concurrentes (une seule Atmosphere et un seul Sky comptent)
local function retirerAutres(parent, classe, nomGarde)
	for _, enfant in ipairs(parent:GetChildren()) do
		if enfant:IsA(classe) and enfant.Name ~= nomGarde then
			enfant:Destroy()
		end
	end
end

-- construit les réglages de chaque phase, toutes couleurs dérivées de la Charte
local function preparerAmbiances(Charte)
	local nuit = Charte.nuitLabo
	local ambiances = {}

	-- Lobby : nuit bleutée du laboratoire
	ambiances.Lobby = {
		eclairage = {
			ClockTime = 22,
			Brightness = 1.6,
			Ambient = nuit:Lerp(Charte.gemme, 0.2),
			OutdoorAmbient = Charte.lumiere(nuit):Lerp(Charte.gemme, 0.15),
		},
		atmo = {
			Density = 0.34,
			Color = nuit:Lerp(Charte.creme, 0.35),
			Decay = nuit,
			Haze = 1.2,
		},
		nuages = { Color = Charte.lumiere(nuit), Cover = 0.5, Density = 0.55 },
		bloom = { Intensity = 0.5, Size = 24, Threshold = 1.4 },
		correction = {
			Brightness = 0,
			Contrast = 0.08,
			Saturation = 0.05,
			TintColor = NEUTRE:Lerp(Charte.gemme, 0.08),
		},
	}

	-- Horde : après-midi légèrement violacé et contrasté
	ambiances.Horde = {
		eclairage = {
			ClockTime = 14.5,
			Brightness = 2.6,
			Ambient = Charte.ardoise:Lerp(Charte.violet, 0.25),
			OutdoorAmbient = Charte.creme:Lerp(Charte.violet, 0.3),
		},
		atmo = {
			Density = 0.3,
			Color = Charte.creme:Lerp(Charte.violet, 0.25),
			Decay = Charte.violet:Lerp(Charte.encre, 0.3),
			Haze = 1,
		},
		nuages = { Color = Charte.creme:Lerp(Charte.violet, 0.12), Cover = 0.55, Density = 0.6 },
		bloom = { Intensity = 0.35, Size = 22, Threshold = 1.6 },
		correction = {
			Brightness = 0,
			Contrast = 0.15,
			Saturation = 0.1,
			TintColor = NEUTRE:Lerp(Charte.violet, 0.06),
		},
	}

	-- Repit : heure dorée
	ambiances.Repit = {
		eclairage = {
			ClockTime = 17.4,
			Brightness = 2.2,
			Ambient = Charte.ardoise:Lerp(Charte.toit, 0.35),
			OutdoorAmbient = Charte.creme:Lerp(Charte.dore, 0.4),
		},
		atmo = {
			Density = 0.32,
			Color = Charte.creme:Lerp(Charte.dore, 0.5),
			Decay = Charte.toit:Lerp(Charte.alerte, 0.2),
			Haze = 2,
		},
		nuages = { Color = Charte.creme:Lerp(Charte.toit, 0.25), Cover = 0.5, Density = 0.55 },
		bloom = { Intensity = 0.45, Size = 26, Threshold = 1.4 },
		correction = {
			Brightness = 0.02,
			Contrast = 0.05,
			Saturation = 0.12,
			TintColor = NEUTRE:Lerp(Charte.dore, 0.1),
		},
	}

	-- Defaite : teinte rouge sombre
	ambiances.Defaite = {
		eclairage = {
			ClockTime = 18.2,
			Brightness = 1.4,
			Ambient = Charte.encre:Lerp(Charte.alerte, 0.35),
			OutdoorAmbient = Charte.ombre(Charte.alerte):Lerp(Charte.encre, 0.4),
		},
		atmo = {
			Density = 0.45,
			Color = Charte.alerte:Lerp(Charte.encre, 0.45),
			Decay = Charte.ombre(Charte.alerte),
			Haze = 2.5,
		},
		nuages = { Color = Charte.ombre(Charte.alerte):Lerp(Charte.encre, 0.3), Cover = 0.7, Density = 0.7 },
		bloom = { Intensity = 0.3, Size = 20, Threshold = 1.8 },
		correction = {
			Brightness = -0.04,
			Contrast = 0.2,
			Saturation = -0.2,
			TintColor = NEUTRE:Lerp(Charte.alerte, 0.3),
		},
	}

	return ambiances
end

-- copie d'une table de réglages (pour appliquer le renfort Colosse sans altérer l'original)
local function copier(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	return c
end

-- renfort « alerte » quand un Colosse est en jeu : saturation et teinte rose-rouge renforcées
local function renforcerAlerte(ambiance, Charte)
	local r = {
		eclairage = copier(ambiance.eclairage),
		atmo = copier(ambiance.atmo),
		nuages = copier(ambiance.nuages),
		bloom = copier(ambiance.bloom),
		correction = copier(ambiance.correction),
	}
	r.correction.Saturation = r.correction.Saturation + 0.25
	r.correction.Contrast = r.correction.Contrast + 0.08
	r.correction.TintColor = r.correction.TintColor:Lerp(Charte.alerte, 0.18)
	r.atmo.Decay = r.atmo.Decay:Lerp(Charte.alerte, 0.3)
	r.atmo.Color = r.atmo.Color:Lerp(Charte.alerte, 0.12)
	r.eclairage.Ambient = r.eclairage.Ambient:Lerp(Charte.alerte, 0.15)
	r.nuages.Color = r.nuages.Color:Lerp(Charte.alerte, 0.15)
	r.bloom.Intensity = r.bloom.Intensity + 0.15
	return r
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Lighting = service("Lighting")
	if not Lighting then
		return
	end
	local TweenService = service("TweenService")

	-- réglages fixes du service
	pcall(function()
		Lighting.GlobalShadows = true
		Lighting.GeographicLatitude = 30
		Lighting.ExposureCompensation = 0
	end)

	-- Atmosphere
	retirerAutres(Lighting, "Atmosphere", NOM_ATMO)
	local atmo = obtenir(Lighting, "Atmosphere", NOM_ATMO)
	pcall(function()
		atmo.Offset = 0.1
		atmo.Glare = 0.2
	end)

	-- Sky (on garde le ciel par défaut de Roblox, avec soleil, lune et étoiles)
	retirerAutres(Lighting, "Sky", NOM_CIEL)
	local ciel = obtenir(Lighting, "Sky", NOM_CIEL)
	pcall(function()
		ciel.CelestialBodiesShown = true
		ciel.StarCount = 3000
		ciel.SunAngularSize = 18
		ciel.MoonAngularSize = 11
	end)

	-- effets de post-traitement, doux
	local bloom = obtenir(Lighting, "BloomEffect", NOM_BLOOM)
	local correction = obtenir(Lighting, "ColorCorrectionEffect", NOM_CORRECTION)

	-- nuages dans le Terrain (optionnel : le Terrain peut manquer)
	local nuages = nil
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		local ok, resultat = pcall(function()
			local c = terrain:FindFirstChildOfClass("Clouds")
			if not c then
				c = Instance.new("Clouds")
				c.Parent = terrain
			end
			c.Enabled = true
			return c
		end)
		if ok then
			nuages = resultat
		end
	end

	local ambiances = preparerAmbiances(Charte)
	local tweensEnCours = {}

	local function annulerTweens()
		for _, tw in ipairs(tweensEnCours) do
			pcall(function()
				tw:Cancel()
			end)
		end
		tweensEnCours = {}
	end

	-- applique des propriétés à une instance, en fondu ou d'un coup
	local function poser(inst, proprietes, enFondu)
		if not inst or not inst.Parent then
			return
		end
		if enFondu and TweenService then
			local ok, tw = pcall(function()
				local info = TweenInfo.new(DUREE_TRANSITION, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				return TweenService:Create(inst, info, proprietes)
			end)
			if ok and tw then
				table.insert(tweensEnCours, tw)
				tw:Play()
				return
			end
		end
		for k, v in pairs(proprietes) do
			pcall(function()
				inst[k] = v
			end)
		end
	end

	local function ambianceActuelle()
		local phase = nil
		local colosse = false
		if ctx.Etat then
			phase = ctx.Etat:GetAttribute("Phase")
			colosse = ctx.Etat:GetAttribute("ColosseActif") == true
		end
		local ambiance = ambiances[phase or "Lobby"]
		if not ambiance then
			ambiance = ambiances.Lobby
		end
		if colosse then
			ambiance = renforcerAlerte(ambiance, Charte)
		end
		return ambiance
	end

	local function appliquer(enFondu)
		local a = ambianceActuelle()
		annulerTweens()
		poser(Lighting, a.eclairage, enFondu)
		poser(atmo, a.atmo, enFondu)
		poser(bloom, a.bloom, enFondu)
		poser(correction, a.correction, enFondu)
		if nuages then
			poser(nuages, a.nuages, enFondu)
		end
	end

	-- état initial sans fondu, puis transitions de 3 s à chaque changement
	appliquer(false)

	if ctx.Etat then
		ctx.Etat:GetAttributeChangedSignal("Phase"):Connect(function()
			appliquer(true)
		end)
		ctx.Etat:GetAttributeChangedSignal("ColosseActif"):Connect(function()
			appliquer(true)
		end)
	end
end

return M
