-- Constructeur Ciel : éclairage de Dino Chapardeurs (Lighting uniquement, aucune part).
-- Style « simulateur Roblox » (voir STYLE.md) : plein jour lumineux la plupart du temps, ciel bleu
-- clair, brume presque nulle, ombres douces. Cycle jour/nuit très lent calé sur l'heure serveur,
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
	midiDebut = 13,        -- plateau de plein jour : l'heure reste entre midiDebut et midiFin
	midiFin = 14,
	partMatin = 0.07,      -- part du jour passée à monter du lever au plateau
	partSoir = 0.07,       -- part du jour passée à descendre du plateau au coucher
	dureeTransition = 2.5, -- secondes de fondu lors d'un changement d'événement
	pas = 0.25,            -- secondes entre deux mises à jour du cycle
	latitude = 12,         -- soleil haut, ombres courtes et lisibles
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
-- chaque ambiance donne les propriétés cibles de Lighting, Atmosphere, Clouds, Bloom et ColorCorrection.
-- Règle du style : jamais sombre, jamais brumeux ; les couleurs viennent de la Charte et du Style.
local function ambiances(C, S)
	local blanc = Color3.new(1, 1, 1)
	if S and S.couleurs and S.couleurs.texte then
		blanc = S.couleurs.texte
	end
	-- bleu ciel clair des simulateurs, tiré de la gemme de la Charte
	local bleuCiel = C.gemme:Lerp(blanc, 0.45)
	local bleuNuit = C.nuit:Lerp(C.gemme, 0.45)

	local A = {}

	-- plein jour : lumière chaude et forte, ciel bleu net, couleurs saturées
	A.Jour = {
		lighting = {
			Brightness = 3,
			Ambient = mul(C.creme, 0.62),
			OutdoorAmbient = mul(C.creme:Lerp(bleuCiel, 0.2), 0.85),
			ColorShift_Top = mul(C.sable, 0.5),
			ColorShift_Bottom = mul(C.herbe, 0.1),
			ExposureCompensation = 0.15,
		},
		atmosphere = {
			Density = 0.18,
			Offset = 0,
			Color = bleuCiel,
			Decay = bleuCiel:Lerp(blanc, 0.3),
			Glare = 0,
			Haze = 0,
		},
		clouds = { Cover = 0.5, Density = 0.4, Color = blanc },
		bloom = { Intensity = 0.3, Size = 22, Threshold = 1.8 },
		correction = { Brightness = 0.04, Contrast = 0.1, Saturation = 0.35, TintColor = blanc:Lerp(C.sable, 0.06) },
	}

	-- lever et coucher : or chaud, toujours lumineux
	A.Crepuscule = {
		lighting = {
			Brightness = 2.6,
			Ambient = mul(C.dore:Lerp(C.creme, 0.55), 0.6),
			OutdoorAmbient = mul(C.lave:Lerp(C.creme, 0.55), 0.8),
			ColorShift_Top = mul(C.dore:Lerp(C.lave, 0.4), 0.7),
			ColorShift_Bottom = mul(C.violet, 0.1),
			ExposureCompensation = 0.15,
		},
		atmosphere = {
			Density = 0.22,
			Offset = 0,
			Color = C.dore:Lerp(bleuCiel, 0.45),
			Decay = C.lave:Lerp(C.dore, 0.5),
			Glare = 0.3,
			Haze = 0.3,
		},
		clouds = { Cover = 0.5, Density = 0.45, Color = C.dore:Lerp(blanc, 0.55) },
		bloom = { Intensity = 0.4, Size = 24, Threshold = 1.6 },
		correction = { Brightness = 0.04, Contrast = 0.1, Saturation = 0.4, TintColor = blanc:Lerp(C.dore, 0.1) },
	}

	-- nuit courte et claire : bleu lumineux, on voit tout le terrain
	A.Nuit = {
		lighting = {
			Brightness = 1.6,
			Ambient = mul(bleuNuit:Lerp(blanc, 0.35), 0.75),
			OutdoorAmbient = mul(bleuNuit:Lerp(blanc, 0.4), 0.95),
			ColorShift_Top = mul(C.gemme, 0.3),
			ColorShift_Bottom = mul(C.violet, 0.12),
			ExposureCompensation = 0.4,
		},
		atmosphere = {
			Density = 0.18,
			Offset = 0,
			Color = bleuNuit,
			Decay = bleuNuit:Lerp(C.violet, 0.3),
			Glare = 0,
			Haze = 0,
		},
		clouds = { Cover = 0.4, Density = 0.3, Color = bleuNuit:Lerp(blanc, 0.55) },
		bloom = { Intensity = 0.45, Size = 24, Threshold = 1.4 },
		correction = { Brightness = 0.06, Contrast = 0.08, Saturation = 0.3, TintColor = blanc:Lerp(C.gemme, 0.1) },
	}

	-- éruption : ciel orange vif, lumière rouge-or, sans brume sombre
	A.Eruption = {
		heure = 17.4,
		lighting = {
			Brightness = 2.8,
			Ambient = mul(C.lave:Lerp(C.creme, 0.45), 0.7),
			OutdoorAmbient = mul(C.lave:Lerp(C.dore, 0.4), 0.85),
			ColorShift_Top = C.lave,
			ColorShift_Bottom = mul(C.alerte, 0.35),
			ExposureCompensation = 0.1,
		},
		atmosphere = {
			Density = 0.3,
			Offset = 0,
			Color = C.lave:Lerp(C.dore, 0.35),
			Decay = C.alerte:Lerp(C.lave, 0.4),
			Glare = 0.5,
			Haze = 0.6,
		},
		clouds = { Cover = 0.65, Density = 0.55, Color = C.lave:Lerp(C.dore, 0.5) },
		bloom = { Intensity = 0.6, Size = 28, Threshold = 1.3 },
		correction = { Brightness = 0.03, Contrast = 0.14, Saturation = 0.5, TintColor = blanc:Lerp(C.lave, 0.2) },
	}

	-- pluie de météores : nuit violette très étoilée, bien éclairée
	A.PluieDeMeteores = {
		heure = 22,
		etoiles = 8000,
		lighting = {
			Brightness = 1.8,
			Ambient = mul(C.violet:Lerp(blanc, 0.35), 0.7),
			OutdoorAmbient = mul(C.violet:Lerp(C.gemme, 0.3), 0.95),
			ColorShift_Top = C.violet,
			ColorShift_Bottom = mul(C.gemme, 0.25),
			ExposureCompensation = 0.4,
		},
		atmosphere = {
			Density = 0.2,
			Offset = 0,
			Color = C.violet:Lerp(C.gemme, 0.2),
			Decay = C.violet:Lerp(C.alerte, 0.25),
			Glare = 0.2,
			Haze = 0,
		},
		clouds = { Cover = 0.3, Density = 0.25, Color = C.violet:Lerp(blanc, 0.5) },
		bloom = { Intensity = 0.7, Size = 28, Threshold = 1.1 },
		correction = { Brightness = 0.06, Contrast = 0.12, Saturation = 0.55, TintColor = blanc:Lerp(C.violet, 0.2) },
	}

	-- lune dorée : nuit baignée d'une lumière d'or éclatante, lune géante
	A.LuneDoree = {
		heure = 23,
		lune = 28,
		lighting = {
			Brightness = 2,
			Ambient = mul(C.dore:Lerp(blanc, 0.3), 0.7),
			OutdoorAmbient = mul(C.dore:Lerp(C.creme, 0.3), 0.9),
			ColorShift_Top = C.dore,
			ColorShift_Bottom = mul(C.lave, 0.2),
			ExposureCompensation = 0.4,
		},
		atmosphere = {
			Density = 0.2,
			Offset = 0,
			Color = C.dore:Lerp(bleuNuit, 0.35),
			Decay = C.dore:Lerp(C.lave, 0.25),
			Glare = 0.4,
			Haze = 0,
		},
		clouds = { Cover = 0.35, Density = 0.3, Color = C.dore:Lerp(blanc, 0.4) },
		bloom = { Intensity = 0.8, Size = 30, Threshold = 1.1 },
		correction = { Brightness = 0.06, Contrast = 0.12, Saturation = 0.5, TintColor = blanc:Lerp(C.dore, 0.25) },
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
	pcall(function()
		Lighting.GlobalShadows = true
		Lighting.ShadowSoftness = 0.7
		Lighting.GeographicLatitude = reglage(ctx, "latitude")
		Lighting.EnvironmentDiffuseScale = 0.8
		Lighting.EnvironmentSpecularScale = 0.3
		Lighting.FogStart = 0
		Lighting.FogEnd = 100000
		Lighting.ClockTime = 13.5
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
		ciel.StarCount = 4000
		ciel.SunAngularSize = 16
		ciel.MoonAngularSize = 14
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
		rayons.Intensity = 0.04
		rayons.Spread = 0.5
	end)
	rayons.Parent = Lighting

	-- nuages dans le Terrain : petits cumulus blancs bien découpés
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
				ciel.StarCount = 4000
				ciel.MoonAngularSize = 14
			end)
			local heure = heureDuCycle()
			fondre(ambianceCycle(heure), heure)
		else
			local amb = A[nom]
			pcall(function()
				ciel.StarCount = amb.etoiles or 4000
				ciel.MoonAngularSize = amb.lune or 14
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
