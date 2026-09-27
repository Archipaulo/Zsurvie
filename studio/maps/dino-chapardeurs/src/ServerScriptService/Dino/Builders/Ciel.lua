-- Constructeur Ciel : éclairage de Dino Chapardeurs (Lighting uniquement, aucune part).
-- Version 2 (STYLE.md §4) : rendu « Future » des jeux Roblox soignés. Plein jour chaud et lumineux
-- la plupart du temps (vers 14 h), ombres douces mais nettes, reflets d'environnement complets,
-- Atmosphere légère bleu clair avec voile lointain, Bloom discret, rayons de soleil, couleurs vives
-- et flou de profondeur très léger au loin. Cycle jour/nuit très lent calé sur l'heure serveur,
-- avec une nuit courte et claire. Ambiances vives pendant les événements (Eruption, PluieDeMeteores, LuneDoree).
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local M = {}

-- réglages par défaut (surchargés par Equilibrage.ciel s'il existe)
local DEFAUTS = {
	dureeCycle = 1800,     -- secondes réelles pour un cycle complet (30 min)
	dureeNuit = 240,       -- dont secondes de nuit (courte : 4 min)
	heureLever = 6,
	heureCoucher = 20,
	midiDebut = 13.6,      -- plateau de plein jour : l'heure reste entre midiDebut et midiFin (autour de 14 h)
	midiFin = 14.4,
	partMatin = 0.07,      -- part du jour passée à monter du lever au plateau
	partSoir = 0.07,       -- part du jour passée à descendre du plateau au coucher
	dureeTransition = 2.5, -- secondes de fondu lors d'un changement d'événement
	pas = 0.25,            -- secondes entre deux mises à jour du cycle
	latitude = 23,         -- soleil haut de l'après-midi : ombres courtes, légèrement portées
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

local function rgb(r, v, b)
	return Color3.fromRGB(r, v, b)
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

-- groupes de propriétés d'une ambiance (chacun correspond à un objet de Lighting)
local GROUPES = { "lighting", "atmosphere", "clouds", "bloom", "correction", "rayons", "profondeur" }

-- ===== les ambiances =====
-- chaque ambiance donne les propriétés cibles de Lighting, Atmosphere, Clouds, Bloom, ColorCorrection,
-- SunRays et DepthOfField. Règle du style : jamais sombre ; un voile lointain léger donne de la
-- profondeur sans jamais cacher le terrain de jeu.
local function ambiances(C, S)
	local blanc = Color3.new(1, 1, 1)
	if S and S.couleurs and S.couleurs.texte then
		blanc = S.couleurs.texte
	end
	-- bleu ciel clair des jeux soignés (légèrement tiré de la gemme de la Charte)
	local bleuCiel = rgb(196, 224, 246):Lerp(C.gemme, 0.08)
	local bleuVoile = rgb(214, 232, 248)
	local bleuNuit = C.nuit:Lerp(C.gemme, 0.45)
	-- chaleur de l'après-midi
	local chaud = C.creme:Lerp(C.sable, 0.35)

	-- flou de profondeur : nul de près, à peine visible sur l'horizon
	local profondeurStandard = { FarIntensity = 0.08, NearIntensity = 0, FocusDistance = 200, InFocusRadius = 50 }

	local A = {}

	-- plein jour (14 h) : lumière chaude et forte, ciel bleu clair, voile lointain léger
	A.Jour = {
		lighting = {
			Brightness = 3,
			Ambient = mul(chaud, 0.52),
			OutdoorAmbient = mul(chaud:Lerp(bleuCiel, 0.15), 0.62),
			ColorShift_Top = mul(C.sable:Lerp(C.dore, 0.2), 0.45),
			ColorShift_Bottom = mul(C.herbe, 0.08),
			ExposureCompensation = 0,
		},
		atmosphere = {
			Density = 0.28,
			Offset = 0.25,
			Color = bleuCiel,
			Decay = bleuVoile:Lerp(C.sable, 0.25),
			Glare = 0.2,
			Haze = 1.2,
		},
		clouds = { Cover = 0.46, Density = 0.38, Color = blanc },
		bloom = { Intensity = 0.5, Size = 24, Threshold = 1.3 },
		correction = { Brightness = 0.02, Contrast = 0.1, Saturation = 0.15, TintColor = blanc:Lerp(C.sable, 0.05) },
		rayons = { Intensity = 0.06, Spread = 0.45 },
		profondeur = profondeurStandard,
	}

	-- lever et coucher : or chaud, toujours lumineux
	A.Crepuscule = {
		lighting = {
			Brightness = 2.6,
			Ambient = mul(C.dore:Lerp(C.creme, 0.55), 0.55),
			OutdoorAmbient = mul(C.lave:Lerp(C.creme, 0.55), 0.72),
			ColorShift_Top = mul(C.dore:Lerp(C.lave, 0.4), 0.7),
			ColorShift_Bottom = mul(C.violet, 0.1),
			ExposureCompensation = 0.1,
		},
		atmosphere = {
			Density = 0.3,
			Offset = 0.2,
			Color = C.dore:Lerp(bleuCiel, 0.5),
			Decay = C.lave:Lerp(C.dore, 0.55),
			Glare = 0.6,
			Haze = 1.6,
		},
		clouds = { Cover = 0.5, Density = 0.42, Color = C.dore:Lerp(blanc, 0.55) },
		bloom = { Intensity = 0.6, Size = 26, Threshold = 1.2 },
		correction = { Brightness = 0.02, Contrast = 0.12, Saturation = 0.22, TintColor = blanc:Lerp(C.dore, 0.1) },
		rayons = { Intensity = 0.12, Spread = 0.6 },
		profondeur = profondeurStandard,
	}

	-- nuit courte et claire : bleu lumineux, on voit tout le terrain, torches mises en valeur
	A.Nuit = {
		lighting = {
			Brightness = 1.4,
			Ambient = mul(bleuNuit:Lerp(blanc, 0.35), 0.62),
			OutdoorAmbient = mul(bleuNuit:Lerp(blanc, 0.4), 0.82),
			ColorShift_Top = mul(C.gemme, 0.3),
			ColorShift_Bottom = mul(C.violet, 0.12),
			ExposureCompensation = 0.35,
		},
		atmosphere = {
			Density = 0.26,
			Offset = 0.2,
			Color = bleuNuit,
			Decay = bleuNuit:Lerp(C.violet, 0.3),
			Glare = 0,
			Haze = 0.8,
		},
		clouds = { Cover = 0.4, Density = 0.3, Color = bleuNuit:Lerp(blanc, 0.55) },
		bloom = { Intensity = 0.65, Size = 26, Threshold = 1.1 },
		correction = { Brightness = 0.04, Contrast = 0.1, Saturation = 0.12, TintColor = blanc:Lerp(C.gemme, 0.1) },
		rayons = { Intensity = 0.02, Spread = 0.4 },
		profondeur = profondeurStandard,
	}

	-- éruption : ciel orange vif, lumière rouge-or, voile chaud sans noirceur
	A.Eruption = {
		heure = 17.4,
		lighting = {
			Brightness = 2.8,
			Ambient = mul(C.lave:Lerp(C.creme, 0.45), 0.62),
			OutdoorAmbient = mul(C.lave:Lerp(C.dore, 0.4), 0.78),
			ColorShift_Top = C.lave,
			ColorShift_Bottom = mul(C.alerte, 0.35),
			ExposureCompensation = 0.05,
		},
		atmosphere = {
			Density = 0.36,
			Offset = 0.2,
			Color = C.lave:Lerp(C.dore, 0.35),
			Decay = C.alerte:Lerp(C.lave, 0.4),
			Glare = 0.8,
			Haze = 2.2,
		},
		clouds = { Cover = 0.65, Density = 0.55, Color = C.lave:Lerp(C.dore, 0.5) },
		bloom = { Intensity = 0.75, Size = 28, Threshold = 1.15 },
		correction = { Brightness = 0.02, Contrast = 0.16, Saturation = 0.3, TintColor = blanc:Lerp(C.lave, 0.18) },
		rayons = { Intensity = 0.14, Spread = 0.7 },
		profondeur = { FarIntensity = 0.12, NearIntensity = 0, FocusDistance = 200, InFocusRadius = 50 },
	}

	-- pluie de météores : nuit violette très étoilée, bien éclairée
	A.PluieDeMeteores = {
		heure = 22,
		etoiles = 8000,
		lighting = {
			Brightness = 1.7,
			Ambient = mul(C.violet:Lerp(blanc, 0.35), 0.62),
			OutdoorAmbient = mul(C.violet:Lerp(C.gemme, 0.3), 0.85),
			ColorShift_Top = C.violet,
			ColorShift_Bottom = mul(C.gemme, 0.25),
			ExposureCompensation = 0.35,
		},
		atmosphere = {
			Density = 0.26,
			Offset = 0.2,
			Color = C.violet:Lerp(C.gemme, 0.2),
			Decay = C.violet:Lerp(C.alerte, 0.25),
			Glare = 0.3,
			Haze = 0.6,
		},
		clouds = { Cover = 0.3, Density = 0.25, Color = C.violet:Lerp(blanc, 0.5) },
		bloom = { Intensity = 0.85, Size = 28, Threshold = 1 },
		correction = { Brightness = 0.04, Contrast = 0.12, Saturation = 0.3, TintColor = blanc:Lerp(C.violet, 0.18) },
		rayons = { Intensity = 0.03, Spread = 0.4 },
		profondeur = profondeurStandard,
	}

	-- lune dorée : nuit baignée d'une lumière d'or éclatante, lune géante
	A.LuneDoree = {
		heure = 23,
		lune = 28,
		lighting = {
			Brightness = 2,
			Ambient = mul(C.dore:Lerp(blanc, 0.3), 0.62),
			OutdoorAmbient = mul(C.dore:Lerp(C.creme, 0.3), 0.82),
			ColorShift_Top = C.dore,
			ColorShift_Bottom = mul(C.lave, 0.2),
			ExposureCompensation = 0.35,
		},
		atmosphere = {
			Density = 0.26,
			Offset = 0.2,
			Color = C.dore:Lerp(bleuNuit, 0.35),
			Decay = C.dore:Lerp(C.lave, 0.25),
			Glare = 0.6,
			Haze = 0.8,
		},
		clouds = { Cover = 0.35, Density = 0.3, Color = C.dore:Lerp(blanc, 0.4) },
		bloom = { Intensity = 0.9, Size = 30, Threshold = 1 },
		correction = { Brightness = 0.04, Contrast = 0.12, Saturation = 0.28, TintColor = blanc:Lerp(C.dore, 0.22) },
		rayons = { Intensity = 0.08, Spread = 0.6 },
		profondeur = profondeurStandard,
	}

	return A
end

-- mélange de deux ambiances (nombres et couleurs) ; un groupe absent d'un côté est repris tel quel
local function melanger(a, b, t)
	local r = {}
	for _, groupe in ipairs(GROUPES) do
		local ga, gb = a[groupe], b[groupe]
		if ga and gb then
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
		elseif ga then
			r[groupe] = ga
		elseif gb then
			r[groupe] = gb
		end
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
	local A = ambiances(C, ctx.Style)

	local dureeCycle = math.max(60, reglage(ctx, "dureeCycle"))
	local dureeNuit = math.max(10, math.min(dureeCycle - 10, reglage(ctx, "dureeNuit")))
	local dureeJour = dureeCycle - dureeNuit
	local lever = reglage(ctx, "heureLever")
	local coucher = reglage(ctx, "heureCoucher")
	local midiDebut = math.max(lever + 0.5, math.min(coucher - 1, reglage(ctx, "midiDebut")))
	local midiFin = math.max(midiDebut, math.min(coucher - 0.5, reglage(ctx, "midiFin")))
	local partMatin = math.max(0.01, math.min(0.45, reglage(ctx, "partMatin")))
	local partSoir = math.max(0.01, math.min(0.45, reglage(ctx, "partSoir")))
	local dureeHeuresNuit = 24 - (coucher - lever)
	local transition = math.max(0.1, reglage(ctx, "dureeTransition"))
	local pas = math.max(0.05, reglage(ctx, "pas"))

	-- ===== réglages généraux de Lighting =====
	-- chaque propriété à part : si l'une est refusée (ex. Technology hors Studio), les autres passent
	local generaux = {
		GlobalShadows = true,
		ShadowSoftness = 0.25,
		GeographicLatitude = reglage(ctx, "latitude"),
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		FogStart = 0,
		FogEnd = 100000,
		ClockTime = 14,
	}
	for cle, valeur in pairs(generaux) do
		pcall(function()
			Lighting[cle] = valeur
		end)
	end
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)

	-- ===== objets de ciel =====
	retirerClasse(Lighting, "Atmosphere")
	retirerClasse(Lighting, "Sky")
	nettoyer(Lighting, "DinoBloom")
	nettoyer(Lighting, "DinoCouleurs")
	nettoyer(Lighting, "DinoRayons")
	nettoyer(Lighting, "DinoProfondeur")

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "DinoAtmosphere"
	atmosphere.Parent = Lighting

	-- ciel clair : skybox par défaut de Roblox (bleu net), soleil net et lune ronde
	local ciel = Instance.new("Sky")
	ciel.Name = "DinoCiel"
	pcall(function()
		ciel.StarCount = 3000
		ciel.SunAngularSize = 12
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
	rayons.Parent = Lighting

	-- flou très léger au loin seulement (NearIntensity = 0 : le jeu reste net autour du joueur)
	local profondeur = nil
	pcall(function()
		profondeur = Instance.new("DepthOfFieldEffect")
		profondeur.Name = "DinoProfondeur"
		profondeur.Parent = Lighting
	end)

	-- nuages dans le Terrain : cumulus blancs épars, le ciel reste bien bleu
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
		rayons = rayons,
		profondeur = profondeur,
	}

	-- ===== le cycle jour/nuit =====
	-- heure du jeu déduite de l'heure serveur. Le jour : courte montée du lever au plateau,
	-- long plateau de plein jour (midiDebut -> midiFin), courte descente vers le coucher ; puis nuit courte.
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
			local p = phase / dureeJour
			if p < partMatin then
				heure = lever + (midiDebut - lever) * p / partMatin
			elseif p > 1 - partSoir then
				heure = midiFin + (coucher - midiFin) * (p - (1 - partSoir)) / partSoir
			else
				heure = midiDebut + (midiFin - midiDebut) * (p - partMatin) / (1 - partMatin - partSoir)
			end
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
		return melanger(base, A.Crepuscule, dore * 0.8)
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
