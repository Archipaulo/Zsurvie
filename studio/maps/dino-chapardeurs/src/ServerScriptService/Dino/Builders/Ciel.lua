-- Constructeur Ciel : éclairage de Dino Chapardeurs (Lighting uniquement, aucune part).
-- Journée tropicale ensoleillée, cycle jour/nuit lent calé sur l'heure serveur,
-- ambiances particulières pendant les événements (Eruption, PluieDeMeteores, LuneDoree).
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local M = {}

-- réglages par défaut (surchargés par Equilibrage.ciel s'il existe)
local DEFAUTS = {
	dureeCycle = 720,      -- secondes réelles pour un cycle complet (12 min)
	dureeNuit = 180,       -- dont secondes de nuit (19 h -> 7 h)
	heureLever = 7,
	heureCoucher = 19,
	dureeTransition = 3,   -- secondes de fondu lors d'un changement d'événement
	pas = 0.25,            -- secondes entre deux mises à jour du cycle
	latitude = 8,          -- latitude tropicale : soleil haut
}

local function reglage(ctx, cle)
	local E = ctx.Equilibrage
	local ciel = E and E.ciel
	if type(ciel) == "table" and type(ciel[cle]) == "number" then
		return ciel[cle]
	end
	return DEFAUTS[cle]
end

local function mul(c, k)
	return Color3.new(math.min(1, c.R * k), math.min(1, c.G * k), math.min(1, c.B * k))
end

local function lerpNombre(a, b, t)
	return a + (b - a) * t
end

-- supprime un ancien objet du même nom (relance de la construction)
local function nettoyer(parent, nom)
	local ancien = parent:FindFirstChild(nom)
	while ancien do
		ancien:Destroy()
		ancien = parent:FindFirstChild(nom)
	end
end

-- une seule Atmosphere / un seul Sky comptent : on retire les autres
local function retirerClasse(parent, classe)
	for _, enfant in ipairs(parent:GetChildren()) do
		if enfant:IsA(classe) then
			enfant:Destroy()
		end
	end
end

-- ===== les ambiances =====
-- chaque ambiance donne les propriétés cibles de Lighting, Atmosphere, Clouds, Bloom et ColorCorrection
local function ambiances(C)
	local A = {}

	A.Jour = {
		lighting = {
			Brightness = 3,
			Ambient = mul(C.creme, 0.42),
			OutdoorAmbient = mul(C.creme:Lerp(C.gemme, 0.15), 0.62),
			ColorShift_Top = mul(C.sable, 0.35),
			ColorShift_Bottom = mul(C.herbe, 0.12),
			ExposureCompensation = 0.1,
		},
		atmosphere = {
			Density = 0.28,
			Offset = 0.12,
			Color = C.gemme:Lerp(C.creme, 0.62),
			Decay = C.sable:Lerp(C.creme, 0.3),
			Glare = 0.25,
			Haze = 1.1,
		},
		clouds = { Cover = 0.55, Density = 0.55, Color = C.creme:Lerp(Color3.new(1, 1, 1), 0.6) },
		bloom = { Intensity = 0.45, Size = 26, Threshold = 1.6 },
		correction = { Brightness = 0.02, Contrast = 0.08, Saturation = 0.28, TintColor = Color3.new(1, 1, 1):Lerp(C.sable, 0.08) },
	}

	A.Crepuscule = {
		lighting = {
			Brightness = 2,
			Ambient = mul(C.lave:Lerp(C.creme, 0.5), 0.36),
			OutdoorAmbient = mul(C.lave:Lerp(C.creme, 0.45), 0.5),
			ColorShift_Top = mul(C.lave, 0.6),
			ColorShift_Bottom = mul(C.violet, 0.15),
			ExposureCompensation = 0.05,
		},
		atmosphere = {
			Density = 0.34,
			Offset = 0.1,
			Color = C.lave:Lerp(C.dore, 0.5):Lerp(C.creme, 0.35),
			Decay = C.violet:Lerp(C.lave, 0.4),
			Glare = 0.6,
			Haze = 1.6,
		},
		clouds = { Cover = 0.58, Density = 0.6, Color = C.dore:Lerp(C.creme, 0.4) },
		bloom = { Intensity = 0.6, Size = 30, Threshold = 1.4 },
		correction = { Brightness = 0.01, Contrast = 0.1, Saturation = 0.3, TintColor = Color3.new(1, 1, 1):Lerp(C.dore, 0.15) },
	}

	A.Nuit = {
		lighting = {
			Brightness = 0.6,
			Ambient = mul(C.nuit:Lerp(C.gemme, 0.2), 0.85),
			OutdoorAmbient = mul(C.nuit:Lerp(C.gemme, 0.25), 1.1),
			ColorShift_Top = mul(C.gemme, 0.2),
			ColorShift_Bottom = mul(C.nuit, 0.3),
			ExposureCompensation = 0.25,
		},
		atmosphere = {
			Density = 0.3,
			Offset = 0.08,
			Color = C.nuit:Lerp(C.gemme, 0.25),
			Decay = C.nuit,
			Glare = 0,
			Haze = 0.8,
		},
		clouds = { Cover = 0.5, Density = 0.45, Color = mul(C.nuit:Lerp(C.creme, 0.35), 0.9) },
		bloom = { Intensity = 0.7, Size = 28, Threshold = 1.2 },
		correction = { Brightness = 0.03, Contrast = 0.1, Saturation = 0.18, TintColor = Color3.new(1, 1, 1):Lerp(C.gemme, 0.12) },
	}

	-- éruption : ciel orangé, brume épaisse de cendres
	A.Eruption = {
		heure = 17.7,
		lighting = {
			Brightness = 2.2,
			Ambient = mul(C.lave:Lerp(C.encre, 0.3), 0.55),
			OutdoorAmbient = mul(C.lave:Lerp(C.creme, 0.25), 0.55),
			ColorShift_Top = mul(C.lave, 0.8),
			ColorShift_Bottom = mul(C.alerte, 0.3),
			ExposureCompensation = 0,
		},
		atmosphere = {
			Density = 0.52,
			Offset = 0.25,
			Color = C.lave:Lerp(C.dore, 0.3),
			Decay = C.alerte:Lerp(C.encre, 0.35),
			Glare = 0.8,
			Haze = 2.6,
		},
		clouds = { Cover = 0.78, Density = 0.8, Color = mul(C.lave:Lerp(C.pierre, 0.5), 0.9) },
		bloom = { Intensity = 0.8, Size = 32, Threshold = 1.2 },
		correction = { Brightness = 0, Contrast = 0.14, Saturation = 0.35, TintColor = Color3.new(1, 1, 1):Lerp(C.lave, 0.22) },
	}

	-- pluie de météores : nuit violette très étoilée
	A.PluieDeMeteores = {
		heure = 22,
		etoiles = 6000,
		lighting = {
			Brightness = 0.8,
			Ambient = mul(C.violet:Lerp(C.nuit, 0.5), 0.8),
			OutdoorAmbient = mul(C.violet:Lerp(C.nuit, 0.35), 1),
			ColorShift_Top = mul(C.violet, 0.45),
			ColorShift_Bottom = mul(C.gemme, 0.15),
			ExposureCompensation = 0.3,
		},
		atmosphere = {
			Density = 0.26,
			Offset = 0.05,
			Color = C.violet:Lerp(C.nuit, 0.35),
			Decay = C.violet:Lerp(C.gemme, 0.25),
			Glare = 0.2,
			Haze = 0.9,
		},
		clouds = { Cover = 0.35, Density = 0.35, Color = mul(C.violet:Lerp(C.creme, 0.3), 0.8) },
		bloom = { Intensity = 0.9, Size = 30, Threshold = 1 },
		correction = { Brightness = 0.03, Contrast = 0.12, Saturation = 0.35, TintColor = Color3.new(1, 1, 1):Lerp(C.violet, 0.2) },
	}

	-- lune dorée : nuit baignée d'une lumière d'or
	A.LuneDoree = {
		heure = 23,
		lune = 22,
		lighting = {
			Brightness = 1,
			Ambient = mul(C.dore:Lerp(C.nuit, 0.55), 0.85),
			OutdoorAmbient = mul(C.dore:Lerp(C.nuit, 0.4), 1),
			ColorShift_Top = mul(C.dore, 0.55),
			ColorShift_Bottom = mul(C.nuit, 0.3),
			ExposureCompensation = 0.3,
		},
		atmosphere = {
			Density = 0.3,
			Offset = 0.08,
			Color = C.dore:Lerp(C.nuit, 0.45),
			Decay = C.dore:Lerp(C.lave, 0.2),
			Glare = 0.4,
			Haze = 1.2,
		},
		clouds = { Cover = 0.45, Density = 0.4, Color = C.dore:Lerp(C.creme, 0.35) },
		bloom = { Intensity = 1, Size = 34, Threshold = 1 },
		correction = { Brightness = 0.03, Contrast = 0.1, Saturation = 0.32, TintColor = Color3.new(1, 1, 1):Lerp(C.dore, 0.22) },
	}

	return A
end

-- mélange de deux ambiances (nombres et couleurs)
local function melanger(a, b, t)
	local r = {}
	for _, groupe in ipairs({ "lighting", "atmosphere", "clouds", "bloom", "correction" }) do
		local ga, gb = a[groupe], b[groupe]
		local g = {}
		for cle, va in pairs(ga) do
			local vb = gb[cle]
			if type(va) == "number" and type(vb) == "number" then
				g[cle] = lerpNombre(va, vb, t)
			elseif typeof(va) == "Color3" and typeof(vb) == "Color3" then
				g[cle] = va:Lerp(vb, t)
			else
				g[cle] = va
			end
		end
		r[groupe] = g
	end
	return r
end

local function appliquerDirect(inst, props)
	if not inst or not inst.Parent then return end
	for cle, valeur in pairs(props) do
		pcall(function()
			inst[cle] = valeur
		end)
	end
end

function M.construire(ctx)
	local C = ctx.Charte
	local A = ambiances(C)

	local dureeCycle = math.max(60, reglage(ctx, "dureeCycle"))
	local dureeNuit = math.max(10, math.min(dureeCycle - 10, reglage(ctx, "dureeNuit")))
	local dureeJour = dureeCycle - dureeNuit
	local lever = reglage(ctx, "heureLever")
	local coucher = reglage(ctx, "heureCoucher")
	local dureeHeuresJour = coucher - lever
	local dureeHeuresNuit = 24 - dureeHeuresJour
	local transition = math.max(0.1, reglage(ctx, "dureeTransition"))
	local pas = math.max(0.05, reglage(ctx, "pas"))

	-- ===== réglages généraux de Lighting =====
	pcall(function()
		Lighting.GlobalShadows = true
		Lighting.ShadowSoftness = 0.25
		Lighting.GeographicLatitude = reglage(ctx, "latitude")
		Lighting.EnvironmentDiffuseScale = 0.6
		Lighting.EnvironmentSpecularScale = 0.5
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
		Lighting.ClockTime = 10
	end)

	-- ===== objets de ciel =====
	retirerClasse(Lighting, "Atmosphere")
	retirerClasse(Lighting, "Sky")
	nettoyer(Lighting, "DinoBloom")
	nettoyer(Lighting, "DinoCouleurs")
	nettoyer(Lighting, "DinoRayons")

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "DinoAtmosphere"
	atmosphere.Parent = Lighting

	local ciel = Instance.new("Sky")
	ciel.Name = "DinoCiel"
	pcall(function()
		ciel.StarCount = 3000
		ciel.SunAngularSize = 18
		ciel.MoonAngularSize = 11
		ciel.CelestialBodiesShown = true
	end)
	ciel.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "DinoBloom"
	bloom.Parent = Lighting

	local correction = Instance.new("ColorCorrectionEffect")
	correction.Name = "DinoCouleurs"
	correction.Parent = Lighting

	local rayons = Instance.new("SunRaysEffect")
	rayons.Name = "DinoRayons"
	pcall(function()
		rayons.Intensity = 0.06
		rayons.Spread = 0.6
	end)
	rayons.Parent = Lighting

	-- nuages dans le Terrain
	local nuages = nil
	pcall(function()
		local terrain = workspace:FindFirstChildOfClass("Terrain") or workspace.Terrain
		if terrain then
			for _, enfant in ipairs(terrain:GetChildren()) do
				if enfant:IsA("Clouds") then
					enfant:Destroy()
				end
			end
			nuages = Instance.new("Clouds")
			nuages.Name = "DinoNuages"
			nuages.Parent = terrain
		end
	end)

	local cibles = {
		lighting = Lighting,
		atmosphere = atmosphere,
		clouds = nuages,
		bloom = bloom,
		correction = correction,
	}

	-- ===== le cycle jour/nuit =====
	-- heure du jeu déduite de l'heure serveur : jour de lever à coucher, puis nuit plus courte
	local function heureDuCycle()
		local maintenant = 0
		local ok, t = pcall(function()
			return workspace:GetServerTimeNow()
		end)
		if ok and type(t) == "number" then
			maintenant = t
		else
			maintenant = os.clock()
		end
		local phase = maintenant % dureeCycle
		local heure
		if phase < dureeJour then
			heure = lever + dureeHeuresJour * phase / dureeJour
		else
			heure = coucher + dureeHeuresNuit * (phase - dureeJour) / dureeNuit
		end
		return heure % 24
	end

	-- ambiance du cycle pour une heure donnée
	local function ambianceCycle(heure)
		-- facteur de jour : 1 en pleine journée, 0 la nuit
		local jour
		if heure >= lever + 1 and heure <= coucher - 1 then
			jour = 1
		elseif heure > lever - 1 and heure < lever + 1 then
			jour = (heure - (lever - 1)) / 2
		elseif heure > coucher - 1 and heure < coucher + 1 then
			jour = 1 - (heure - (coucher - 1)) / 2
		else
			jour = 0
		end
		-- lumière dorée autour du lever et du coucher
		local dore = math.max(0, 1 - math.abs(heure - lever) / 1.2) + math.max(0, 1 - math.abs(heure - (coucher - 0.3)) / 1.6)
		dore = math.min(1, dore)
		local base = melanger(A.Nuit, A.Jour, jour)
		return melanger(base, A.Crepuscule, dore * 0.85)
	end

	local function appliquerAmbiance(amb)
		for groupe, inst in pairs(cibles) do
			if inst and amb[groupe] then
				appliquerDirect(inst, amb[groupe])
			end
		end
	end

	local function fondre(amb, heure)
		local info = TweenInfo.new(transition, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		for groupe, inst in pairs(cibles) do
			if inst and inst.Parent and amb[groupe] then
				local props = {}
				for cle, valeur in pairs(amb[groupe]) do
					props[cle] = valeur
				end
				if groupe == "lighting" and type(heure) == "number" then
					props.ClockTime = heure
				end
				local ok, tween = pcall(function()
					return TweenService:Create(inst, info, props)
				end)
				if ok and tween then
					tween:Play()
				else
					appliquerDirect(inst, props)
				end
			end
		end
	end

	-- ===== les événements =====
	local modeActuel = ""
	local libreA = 0 -- os.clock() à partir duquel le cycle reprend la main

	local function lireEvenement()
		local valeur = ""
		pcall(function()
			valeur = ctx.Etat:GetAttribute("Evenement")
		end)
		if type(valeur) ~= "string" then return "" end
		if valeur ~= "" and not A[valeur] then return "" end
		if valeur == "Jour" or valeur == "Nuit" or valeur == "Crepuscule" then return "" end
		return valeur
	end

	-- heure cible d'une ambiance nocturne sans faire tourner le soleil à l'envers en plein jour
	local function heureEvenement(amb)
		local actuelle = Lighting.ClockTime
		if amb.heure and amb.heure >= 20 then
			if actuelle < 5 then
				return actuelle
			end
			return amb.heure
		end
		return amb.heure
	end

	local function changerMode(nom)
		if nom == modeActuel then return end
		modeActuel = nom
		libreA = os.clock() + transition
		if nom == "" then
			pcall(function()
				ciel.StarCount = 3000
				ciel.MoonAngularSize = 11
			end)
			local heure = heureDuCycle()
			fondre(ambianceCycle(heure), heure)
		else
			local amb = A[nom]
			pcall(function()
				ciel.StarCount = amb.etoiles or 3000
				ciel.MoonAngularSize = amb.lune or 11
			end)
			fondre(amb, heureEvenement(amb))
		end
	end

	pcall(function()
		ctx.Etat:GetAttributeChangedSignal("Evenement"):Connect(function()
			local ok = pcall(changerMode, lireEvenement())
			if not ok then
				modeActuel = ""
			end
		end)
	end)

	-- état de départ
	local depart = heureDuCycle()
	appliquerAmbiance(ambianceCycle(depart))
	pcall(function()
		Lighting.ClockTime = depart
	end)
	pcall(changerMode, lireEvenement())

	-- boucle du cycle : avance l'heure seulement hors événement et hors fondu
	task.spawn(function()
		while true do
			if modeActuel == "" and os.clock() >= libreA then
				pcall(function()
					local heure = heureDuCycle()
					Lighting.ClockTime = heure
					appliquerAmbiance(ambianceCycle(heure))
				end)
			end
			task.wait(pas)
		end
	end)
end

return M
