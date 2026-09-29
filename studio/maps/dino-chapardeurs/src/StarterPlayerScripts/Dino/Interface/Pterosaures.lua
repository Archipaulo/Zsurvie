-- Interface/Pterosaures : de temps en temps, un vol de ptérosaures voxel traverse le ciel très haut
-- (altitude Plan.ciel.altitudeVols), d'un bord de la carte à l'autre, en file ondulée ou en V.
-- Purement local : rien n'est répliqué ; un seul vol à la fois ; tout est détruit à la sortie de la carte.
-- Ailes en deux segments (bras + main) qui battent autour de l'épaule et du poignet, planés entre les
-- séries de battements, UNE seule ombre au sol selon le soleil (la vraie silhouette du moteur quand ses ombres
-- sont actives, sinon une ombre douce de secours posée sur le sol seulement), cri lointain discret de temps en temps.
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local M = {}

local VITESSE = 25 -- studs/s
local PREMIER_VOL = { 25, 45 } -- secondes après l'arrivée (le joueur découvre vite le ciel animé)
local INTERVALLE = { 35, 90 } -- secondes entre deux départs de vol
local MARGE = 45 -- les vols naissent et meurent à cette distance au-delà des murs du monde
local TAILLE_VOXEL = 1.25 -- studs par cube : envergure ~ 34 studs, lisible tout là-haut
local BUDGET = 170 -- parts par ptérosaure
local EPAULE_X = 1.5 -- articulation épaule (en cubes)
local POIGNET_X = 7.5 -- articulation poignet (en cubes)
local RAYON_OMBRE = 0.15 -- secondes entre deux lancers de rayon pour l'ombre
local SOL_MAX = 1.5 -- une surface plus haute que ça (lampadaire, étage, toit, dino) n'est pas le sol : le rayon la traverse
local ESSAIS_SOL = 4 -- obstacles traversés au plus par un rayon d'ombre
local EXCLUS_MAX = 150 -- obstacles mémorisés au plus pendant un vol (au-delà : pas d'ombre plutôt qu'une ombre en l'air)
local VERIF_SOURCE = 2 -- secondes entre deux vérifications de la source d'ombre (réglage graphique du joueur)
local deplacementGroupe = nil -- workspace:BulkMoveTo disponible ? (vérifié au premier usage)

local function borne(v, a, b)
	if v < a then return a end
	if v > b then return b end
	return v
end

local function arrondi(v)
	return math.floor(v + 0.5)
end

-- ===== palettes (toutes dérivées de la Charte) =====
local function palettes(Charte)
	return {
		{ -- rouille
			nom = "Rouille",
			corps = Charte.lave:Lerp(Charte.bois, 0.55),
			ventre = Charte.sable:Lerp(Charte.terre, 0.35),
			membrane = Charte.terre:Lerp(Charte.lave, 0.35),
			os = Charte.ombre(Charte.bois),
			crete = Charte.dore,
			bec = Charte.dore:Lerp(Charte.creme, 0.45),
		},
		{ -- bleu nuit
			nom = "BleuNuit",
			corps = Charte.nuit,
			ventre = Charte.nuit:Lerp(Charte.creme, 0.45),
			membrane = Charte.nuit:Lerp(Charte.violet, 0.45),
			os = Charte.encre,
			crete = Charte.gemme,
			bec = Charte.sable,
		},
		{ -- émeraude
			nom = "Emeraude",
			corps = Charte.jungle,
			ventre = Charte.herbe:Lerp(Charte.creme, 0.5),
			membrane = Charte.jungle:Lerp(Charte.gemme, 0.35),
			os = Charte.ombre(Charte.ombre(Charte.jungle)),
			crete = Charte.alerte,
			bec = Charte.creme,
		},
	}
end

-- ===== modèle voxel d'un ptérosaure (repère : centre du corps en (0, 0, 0), regard vers -Z) =====
local function modeliser(ctx, pal, graine)
	local Charte = ctx.Charte
	local V = ctx.Voxel.nouveau()
	local rng = Random.new(graine)

	-- corps fuselé, cou, tête, long bec pointu, crête vers l'arrière
	V:ellipsoide(0, 0, 0, 1.6, 1.3, 3.2, pal.corps, "Corps")
	V:tube(0, 0.4, -2.5, 0, 1.2, -4.5, 0.9, pal.corps, "Corps")
	V:ellipsoide(0, 1.5, -5.5, 1.1, 1.1, 1.6, pal.corps, "Tete")
	V:tube(0, 1.3, -6.5, 0, 0.7, -11, 0.8, pal.bec, "Tete", 0.2)
	V:tube(0, 2.3, -5, 0, 3.6, -1.2, 0.7, pal.crete, "Tete", 0.2)
	V:mettre(1, 2, -6, Charte.encre, "Tete")
	-- petite queue et pattes repliées vers l'arrière
	V:tube(0, 0, 3, 0, 0.3, 6, 0.6, pal.corps, "Corps", 0.2)
	V:tube(1, -1, 2, 1, -1, 4.5, 0.5, pal.os, "Corps")

	-- aile droite (x > 0) : membrane d'un cube d'épaisseur, bord d'attaque osseux, en flèche vers l'arrière
	for x = 2, 13 do
		local t = (x - 2) / 11
		local zf = arrondi(-1.5 + 1.8 * t)
		local zb = arrondi(4.2 - 3.6 * t)
		if zb < zf then zb = zf end
		local groupe = "AileD"
		if x > POIGNET_X then groupe = "BoutAileD" end
		for z = zf, zb do
			local c = pal.membrane
			if x % 3 == 0 and z > zf then
				c = Charte.ombre(pal.membrane) -- nervures
			elseif z == zb then
				c = Charte.lumiere(pal.membrane) -- liseré du bord de fuite
			end
			V:mettre(x, 0, z, c, groupe)
		end
		V:mettre(x, 0, zf, pal.os, groupe)
		if x <= 9 then V:mettre(x, 1, zf, pal.os, groupe) end
	end
	V:mettre(14, 0, 0, pal.os, "BoutAileD") -- pointe de l'aile
	V:mettre(8, 1, -1, pal.crete, "BoutAileD") -- petite griffe au poignet

	-- tramage : dessus plus clair, ventre contrasté, quelques cubes plus clairs ou plus foncés
	V:peindre(function(x, y, z, v)
		if v.c.couleur ~= pal.corps then return nil end
		if y < 0 then return pal.ventre end
		local r = rng:NextNumber()
		if r < 0.12 then return Charte.lumiere(pal.corps) end
		if r < 0.2 then return Charte.ombre(pal.corps) end
		return nil
	end)
	V:symetriser()
	return V
end

-- ===== un ptérosaure prêt à voler : parts ancrées et leur position locale =====
local function fabriquer(ctx, pal, graine, echelle, parent)
	local t = TAILLE_VOXEL * echelle
	local V = modeliser(ctx, pal, graine)
	local modele = V:construire(nil, {
		nom = "Pterosaure",
		taille = t,
		assemblage = false,
		budget = BUDGET,
		origine = CFrame.new(),
	})
	local fiche = {
		modele = modele,
		echelle = t,
		rigides = {},
		ailes = { D = {}, G = {} },
		bouts = { D = {}, G = {} },
		demiEnvergure = 14.5 * t,
		epauleD = CFrame.new(EPAULE_X * t, 0.5 * t, 0),
		epauleG = CFrame.new(-EPAULE_X * t, 0.5 * t, 0),
		poignetD = CFrame.new(POIGNET_X * t, 0.5 * t, 0),
		poignetG = CFrame.new(-POIGNET_X * t, 0.5 * t, 0),
	}
	for _, p in ipairs(modele:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false -- réglé par appliquerSource : une seule source d'ombre à la fois
			local e = { part = p, local0 = p.CFrame }
			if p.Name == "AileD" then
				table.insert(fiche.ailes.D, e)
			elseif p.Name == "AileG" then
				table.insert(fiche.ailes.G, e)
			elseif p.Name == "BoutAileD" then
				table.insert(fiche.bouts.D, e)
			elseif p.Name == "BoutAileG" then
				table.insert(fiche.bouts.G, e)
			else
				table.insert(fiche.rigides, e)
			end
		end
	end
	modele:PivotTo(CFrame.new(0, -500, 0))
	modele.Parent = parent
	return fiche
end

-- ombres du moteur utilisables ? (GlobalShadows actif et qualité graphique pas basse ; Automatique = oui)
local function ombresMoteur()
	if not Lighting.GlobalShadows then return false end
	local ok, niveau = pcall(function()
		return UserSettings():GetService("UserGameSettings").SavedQualityLevel.Value
	end)
	if ok and type(niveau) == "number" and niveau >= 1 and niveau <= 3 then return false end
	return true
end

-- une seule source d'ombre : la silhouette voxel projette (moteur) OU l'ombre douce de secours est affichée
local function appliquerSource(fiche, moteur)
	if fiche.moteur == moteur then return end
	fiche.moteur = moteur
	for _, p in ipairs(fiche.modele:GetDescendants()) do
		if p:IsA("BasePart") then p.CastShadow = moteur end
	end
end

-- ombre douce de secours (qualité basse ou ombres du moteur coupées) :
-- corps + deux ailes, qui raccourcissent quand les ailes se lèvent ; posée sur le sol seulement
local function fabriquerOmbre(ctx, parent, fiche)
	local Charte = ctx.Charte
	local function plaque(nom, taille)
		local p = Instance.new("Part")
		p.Name = nom
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.SmoothPlastic
		p.Color = Charte.encre
		p.Transparency = 0.78
		p.Size = taille
		p.CFrame = CFrame.new(0, -500, 0)
		p.Parent = parent
		return p
	end
	local t = fiche.echelle
	return {
		corps = plaque("OmbreCorps", Vector3.new(2.6 * t, 0.1, 15 * t)),
		aileD = plaque("OmbreAile", Vector3.new(fiche.demiEnvergure, 0.1, 3.4 * t)),
		aileG = plaque("OmbreAile", Vector3.new(fiche.demiEnvergure, 0.1, 3.4 * t)),
		sol = 0,
		prochainRayon = 0,
		normale = Vector3.new(0, 1, 0),
	}
end

-- ===== trajectoire : entrée et sortie du rectangle du monde (élargi de MARGE) =====
local function traversee(Plan, rng)
	local bord = (Plan.monde.bord or 228) + MARGE
	local zMin = (Plan.monde.bordNord or -258) - MARGE
	local zMax = (Plan.monde.bordSud or 198) + MARGE
	local angle = rng:NextNumber(0, 2 * math.pi)
	local dir = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local c = Vector3.new(rng:NextNumber(-90, 90), 0, rng:NextNumber(-110, 60))
	-- intersection de la droite c + dir * s avec le rectangle : s dans [sMin, sMax]
	local sMin, sMax = -1e9, 1e9
	local function axe(o, d, a, b)
		if math.abs(d) < 1e-6 then return end
		local s1, s2 = (a - o) / d, (b - o) / d
		if s1 > s2 then s1, s2 = s2, s1 end
		if s1 > sMin then sMin = s1 end
		if s2 < sMax then sMax = s2 end
	end
	axe(c.X, dir.X, -bord, bord)
	axe(c.Z, dir.Z, zMin, zMax)
	return c + dir * sMin, dir, sMax - sMin
end

local function jouerCri(ctx, part)
	local volume = 1
	local ok, v = pcall(function() return ctx.joueur:GetAttribute("VolumeEffets") end)
	if ok and type(v) == "number" then volume = v end
	if volume <= 0 then return end
	-- deux notes descendantes « kri-kraa », très lointaines
	local notes = { { 0.78, 0 }, { 0.62, 0.22 } }
	for _, n in ipairs(notes) do
		task.delay(n[2], function()
			if not part.Parent then return end
			local s = Instance.new("Sound")
			s.Name = "Cri"
			s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
			s.PlaybackSpeed = n[1]
			s.Volume = 0.22 * volume
			s.RollOffMode = Enum.RollOffMode.InverseTapered
			s.RollOffMinDistance = 60
			s.RollOffMaxDistance = 500
			s.Parent = part
			s:Play()
			task.delay(2, function() s:Destroy() end)
		end)
	end
end

-- ===== un vol complet (bloque jusqu'à la sortie de la carte) =====
local function voler(ctx, dossier, rng)
	local Plan = ctx.Plan
	local alt = (Plan.ciel and Plan.ciel.altitudeVols) or { 95, 140 }
	local altitude = rng:NextNumber(alt[1], alt[2])
	local depart, dir, longueur = traversee(Plan, rng)
	local lateral = Vector3.new(-dir.Z, 0, dir.X)
	local amplitude = rng:NextNumber(5, 12)
	local onde = rng:NextNumber(140, 220) -- longueur d'onde de l'ondulation (studs)
	local dephasage = rng:NextNumber(0, 2 * math.pi)
	local nombre = rng:NextInteger(1, 4)
	local enV = nombre >= 3 or rng:NextNumber() < 0.5

	local liste = palettes(ctx.Charte)
	local palette = liste[rng:NextInteger(1, #liste)]
	local melange = rng:NextNumber() < 0.2

	local vol = Instance.new("Model")
	vol.Name = "Vol"
	vol.Parent = dossier

	local pteros = {}
	local recul = 0
	for i = 1, nombre do
		local pal = palette
		if melange and i > 1 then pal = liste[rng:NextInteger(1, #liste)] end
		local echelle = rng:NextNumber(0.88, 1.02)
		if i == 1 then echelle = 1.1 end
		local ok, fiche = pcall(fabriquer, ctx, pal, rng:NextInteger(1, 99999), echelle, vol)
		if ok and fiche then
			local rang = math.floor(i / 2)
			local cote = 1
			if i % 2 == 1 then cote = -1 end
			if enV then
				fiche.recul = rang * 13
				fiche.decalage = cote * rang * 15
			else
				-- file indienne un peu désordonnée
				fiche.recul = (i - 1) * 16
				fiche.decalage = rng:NextNumber(-5, 5)
			end
			if fiche.recul > recul then recul = fiche.recul end
			fiche.hauteur = rng:NextNumber(-3, 3)
			if i == 1 then fiche.hauteur = 0 end
			fiche.phase = rng:NextNumber(0, 2 * math.pi)
			fiche.frequence = rng:NextNumber(0.85, 1.1) / echelle -- battements/s : les grands battent plus lentement
			fiche.phasePlane = rng:NextNumber(0, 2 * math.pi)
			fiche.periodePlane = rng:NextNumber(7, 11)
			fiche.ombre = fabriquerOmbre(ctx, vol, fiche)
			table.insert(pteros, fiche)
		else
			warn("[Dino] Pterosaures : " .. tostring(fiche))
		end
	end
	if #pteros == 0 then
		vol:Destroy()
		return 0
	end

	local soleil = Vector3.new(0.3, 0.9, 0.3).Unit
	pcall(function() soleil = Lighting:GetSunDirection() end)
	if soleil.Y < 0.35 then soleil = Vector3.new(soleil.X, 0.35, soleil.Z).Unit end

	-- rayon d'ombre : ne s'arrête que sur le sol (Terrain, ou dalle au ras du sol : Tapis, plancher de Base,
	-- Place). Lampadaires, étages, toits, dinos, étiquettes et murs invisibles sont traversés, puis mémorisés
	-- pour ne plus arrêter les rayons suivants de ce vol.
	local exclus = { dossier }
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclus
	params.IgnoreWater = false
	local terrain = workspace.Terrain
	local function sonderSol(x, yHaut, z)
		local origine = Vector3.new(x, yHaut, z)
		local direction = Vector3.new(0, -(yHaut + 60), 0)
		for _ = 1, ESSAIS_SOL do
			local ok, res = pcall(function() return workspace:Raycast(origine, direction, params) end)
			if not ok or not res then return nil end
			if res.Instance == terrain or res.Position.Y <= SOL_MAX then return res end
			if #exclus >= EXCLUS_MAX then return nil end
			table.insert(exclus, res.Instance)
			params.FilterDescendantsInstances = exclus
		end
		return nil
	end

	local moteur = ombresMoteur()
	for _, fiche in ipairs(pteros) do appliquerSource(fiche, moteur) end
	local prochaineVerif = VERIF_SOURCE

	local k = 2 * math.pi / onde
	local function chemin(s)
		local w = amplitude * math.sin(k * s + dephasage)
		local dw = amplitude * k * math.cos(k * s + dephasage)
		local ddw = -amplitude * k * k * math.sin(k * s + dephasage)
		local tangente = (dir + lateral * dw).Unit
		return depart + dir * s + lateral * w, tangente, ddw
	end

	-- instants des cris : 45 % des vols crient une fois, parfois deux
	local cris = {}
	if rng:NextNumber() < 0.45 then
		table.insert(cris, rng:NextNumber(0.3, 0.6) * longueur / VITESSE)
		if rng:NextNumber() < 0.3 then table.insert(cris, cris[1] + rng:NextNumber(2.5, 5)) end
	end

	local duree = (longueur + recul) / VITESSE
	local horloge = 0 -- secondes de vol (somme des dt : suit le rythme de l'image)
	local fini = false
	local haut = Vector3.new(0, 1, 0)
	local liaison
	local prochainCri = 1

	local function cacherOmbre(o)
		o.corps.Transparency = 1
		o.aileD.Transparency = 1
		o.aileG.Transparency = 1
	end

	local function placerOmbre(fiche, cf, angleAile, maintenant)
		local o = fiche.ombre
		if fiche.moteur then
			-- la vraie silhouette suffit : pas de seconde ombre, pas de rayon
			if o.cachee ~= true then
				cacherOmbre(o)
				o.cachee = true
			end
			o.prochainRayon = 0
			return
		end
		o.cachee = false
		local pos = cf.Position
		local h = pos.Y - o.sol
		local projete = pos - soleil * (h / soleil.Y)
		if maintenant >= o.prochainRayon then
			o.prochainRayon = maintenant + RAYON_OMBRE
			local res = sonderSol(projete.X, pos.Y - 5, projete.Z)
			if res then
				o.sol = res.Position.Y
				o.normale = res.Normal
				o.visible = true
			else
				-- au-delà des falaises (rien sous le vol) ou sol introuvable : pas d'ombre plutôt qu'une ombre en l'air
				o.sol = 0
				o.normale = haut
				o.visible = false
			end
			projete = pos - soleil * ((pos.Y - o.sol) / soleil.Y)
		end
		local n = o.normale
		local avant = cf.LookVector
		avant = avant - n * avant:Dot(n)
		if avant.Magnitude < 0.01 then avant = dir end
		local p = Vector3.new(projete.X, o.sol, projete.Z) + n * 0.08
		local base = CFrame.lookAt(p, p + avant.Unit, n)
		local t = fiche.echelle
		o.corps.CFrame = base * CFrame.new(0, 0, -1.5 * t)
		-- les ailes se raccourcissent à l'ombre quand elles se lèvent
		local l = fiche.demiEnvergure * math.max(0.35, math.cos(angleAile))
		local taille = Vector3.new(l, 0.1, 3.4 * t)
		o.aileD.Size = taille
		o.aileG.Size = taille
		o.aileD.CFrame = base * CFrame.new(EPAULE_X * t + l / 2, 0, 1.2 * t)
		o.aileG.CFrame = base * CFrame.new(-EPAULE_X * t - l / 2, 0, 1.2 * t)
		-- plus le vol est haut, plus l'ombre est pâle
		local tr = borne(0.74 + h / 900, 0.8, 0.9)
		if o.visible == false then tr = 1 end
		o.corps.Transparency = tr
		o.aileD.Transparency = tr
		o.aileG.Transparency = tr
	end

	local function poser(fiche, s, horloge, maintenant)
		local pos, tangente, courbure = chemin(s - fiche.recul)
		pos = pos + lateral * fiche.decalage
		-- alternance battements / planés
		local e = borne(0.55 + 0.9 * math.sin(2 * math.pi * horloge / fiche.periodePlane + fiche.phasePlane), 0, 1)
		local w = 2 * math.pi * fiche.frequence * horloge + fiche.phase
		local a1 = (1 - e) * math.rad(7) + e * math.rad(34) * math.sin(w)
		local a2 = (1 - e) * math.rad(-5) + e * math.rad(24) * math.sin(w - 0.8)
		local rebond = -e * 0.45 * fiche.echelle * math.cos(w)
		local roulis = borne(-courbure * 10, -0.25, 0.25) -- penche dans les virages de l'ondulation
		local tangage = e * 0.05 * math.sin(w + 1.2)
		local p = pos + Vector3.new(0, altitude + fiche.hauteur + rebond, 0)
		local cf = CFrame.lookAt(p, p + tangente) * CFrame.Angles(tangage, 0, roulis)

		local parts, cfs = {}, {}
		for _, e2 in ipairs(fiche.rigides) do
			table.insert(parts, e2.part)
			table.insert(cfs, cf * e2.local0)
		end
		-- aile droite : rotation autour de Z à l'épaule (a1 > 0 lève l'aile), puis au poignet
		local brasD = cf * fiche.epauleD * CFrame.Angles(0, 0, a1) * fiche.epauleD:Inverse()
		local mainD = brasD * fiche.poignetD * CFrame.Angles(0, 0, a2) * fiche.poignetD:Inverse()
		local brasG = cf * fiche.epauleG * CFrame.Angles(0, 0, -a1) * fiche.epauleG:Inverse()
		local mainG = brasG * fiche.poignetG * CFrame.Angles(0, 0, -a2) * fiche.poignetG:Inverse()
		for _, e2 in ipairs(fiche.ailes.D) do
			table.insert(parts, e2.part)
			table.insert(cfs, brasD * e2.local0)
		end
		for _, e2 in ipairs(fiche.bouts.D) do
			table.insert(parts, e2.part)
			table.insert(cfs, mainD * e2.local0)
		end
		for _, e2 in ipairs(fiche.ailes.G) do
			table.insert(parts, e2.part)
			table.insert(cfs, brasG * e2.local0)
		end
		for _, e2 in ipairs(fiche.bouts.G) do
			table.insert(parts, e2.part)
			table.insert(cfs, mainG * e2.local0)
		end
		local fait = false
		if deplacementGroupe ~= false then
			fait = pcall(function()
				workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
			end)
			if deplacementGroupe == nil then
				-- premier essai : on vérifie une fois que le déplacement groupé a bien eu lieu
				fait = fait and parts[1] ~= nil and (parts[1].Position - cfs[1].Position).Magnitude < 0.05
				deplacementGroupe = fait
			end
		end
		if not fait then
			for i = 1, #parts do parts[i].CFrame = cfs[i] end
		end
		placerOmbre(fiche, cf, a1, maintenant)
	end

	local function etape(dt)
		if fini then return end
		horloge = horloge + borne(tonumber(dt) or 0, 0, 0.2)
		local maintenant = horloge
		local s = horloge * VITESSE
		if horloge >= duree or not vol.Parent then
			fini = true
			return
		end
		if horloge >= prochaineVerif then
			-- le joueur peut changer sa qualité graphique en plein vol : on suit sans jamais doubler l'ombre
			prochaineVerif = horloge + VERIF_SOURCE
			moteur = ombresMoteur()
			for _, fiche in ipairs(pteros) do appliquerSource(fiche, moteur) end
		end
		for _, fiche in ipairs(pteros) do
			local ok, err = pcall(poser, fiche, s, horloge, maintenant)
			if not ok then
				warn("[Dino] Pterosaures : " .. tostring(err))
				fini = true
				return
			end
		end
		if cris[prochainCri] and horloge >= cris[prochainCri] then
			prochainCri = prochainCri + 1
			local chef = pteros[1].modele.PrimaryPart
			if chef then jouerCri(ctx, chef) end
		end
	end

	etape(0)
	liaison = RunService.Heartbeat:Connect(etape)
	while not fini do
		task.wait(0.25)
	end
	if liaison then liaison:Disconnect() end
	vol:Destroy()
	return duree
end

function M.demarrer(ctx)
	if not ctx.Voxel or not ctx.racine then return end
	local rng = Random.new()
	local dossier = ctx.racine:FindFirstChild("Pterosaures")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Pterosaures" -- local : jamais vu par le serveur ni les autres joueurs
		dossier.Parent = ctx.racine
	end

	task.wait(rng:NextNumber(PREMIER_VOL[1], PREMIER_VOL[2]))
	while true do
		local ok, duree = pcall(voler, ctx, dossier, rng)
		if not ok then
			warn("[Dino] Pterosaures : " .. tostring(duree))
			duree = 0
		end
		-- un seul vol à la fois : l'intervalle court d'un départ à l'autre, avec au moins 10 s de ciel vide
		task.wait(math.max(10, rng:NextNumber(INTERVALLE[1], INTERVALLE[2]) - (duree or 0)))
	end
end

return M
