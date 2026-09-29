-- Constructeur Cratere (version 2, STYLE.md §4) : scène des événements au nord de la Place.
-- Cuvette d'impact en TERRAIN Roblox, sculptée uniquement avec des formes d'au moins 4 studs (la grille
-- de voxels du terrain) : un anneau de basalte creusé au centre, un fond plat, 8 grosses bosses de roche
-- qui cassent le rebord et une entrée ouverte au sud (+Z). Tous les détails plus fins (éjectas, cailloux,
-- éboulis) sont des parts Basalt/Slate/Rock en boules aplaties tournées au hasard ; dalles d'éjecta en
-- ardoise basculées vers l'extérieur sur la crête. Au centre, une météorite géante en basalte à demi
-- enterrée, bosselée, veinée de fissures Neon violettes, un coeur incandescent qui fume et crache des
-- braises, un cristal biterminé qui flotte au-dessus. Des grappes de cristaux de verre (coeur Neon)
-- entourent la météorite, des fissures lumineuses zigzaguent sur le fond. À l'entrée sud, un portique
-- de pierre « ZONE DES ÉVÉNEMENTS » avec deux lanternes et une plaque qui annonce l'événement.
-- Pendant un événement (ctx.Etat.Evenement ~= "") : veines, cristaux, lumières et fumée s'intensifient.
-- Emprise (CONTRAT §10) : disque de rayon 16 autour de Plan.cratere.centre. Budget : 160 parts
-- (le terrain ne compte pas).
local TweenService = game:GetService("TweenService")

local M = {}

local BUDGET = 160

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	local Etat = ctx.Etat
	local Style = ctx.Style

	-- réglages facultatifs (Equilibrage.cratere), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.cratere) == "table" then
		reglages = ctx.Equilibrage.cratere
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	-- tout vient du plan (v2 : Plan.cratere) ; aucune coordonnée du décor n'est écrite ici
	local infoCratere = Plan.cratere
	if type(infoCratere) ~= "table" or typeof(infoCratere.centre) ~= "Vector3" then
		warn("[Cratere] Plan.cratere absent : cratère non construit")
		dossier:SetAttribute("Parts", 0)
		return
	end
	local CENTRE = infoCratere.centre
	local RAYON = infoCratere.rayon or 16
	local CX, CZ = CENTRE.X, CENTRE.Z
	local rng = Outils.aleatoire(reglage("graine", 1996))

	-- géométrie (tout reste à l'intérieur du disque RAYON)
	local RAYON_FOND = RAYON - 4.5      -- fond plat de basalte
	local RAYON_CRETE = RAYON - 3.4     -- centre des bosses de la crête
	local OUVERTURE = math.rad(24)      -- demi-angle de l'ouverture, côté sud (+Z, vers les Bases)
	local RAYON_METEORITE = 4.2
	local Y_METEORITE = 3.4
	local Y_FOND = 0.1                  -- dessus du fond de terrain
	local Y_FISSURE = Y_FOND + 0.04

	-- couleurs : pierre volcanique gris-violet en trois teintes, Neon violet et cyan
	local hex = Charte.hex
	local ROCHE = hex("6E6480")
	local ROCHE_OMBRE = Charte.ombre(ROCHE)
	local ROCHE_CLAIRE = Charte.lumiere(ROCHE)
	local METEORE = hex("3A3048")
	local METEORE_BOSSE = hex("463A58")
	local METEORE_SOMBRE = hex("2A2334")
	local CAILLOU = hex("4A4054")
	local VIOLET = Charte.violet
	local VIOLET_VIF = hex("E0A3FF")
	local VIOLET_FAIBLE = hex("A45CFF")
	local CYAN_VIF = Charte.lumiere(Charte.gemme)
	local CYAN_FAIBLE = hex("2BB8E0")
	local TRANSP_REPOS = 0.15
	local VERRE_REPOS = 0.35
	local VERRE_ACTIF = 0.18
	local FUMEE = hex("B9B0CC")
	local BOIS = hex("5C3A21")
	local FOND_PLAQUE = (Style and Style.couleurs.fond) or Charte.encre

	local MAT_BASALTE = Enum.Material.Basalt
	local MAT_ROCHE = Enum.Material.Rock
	local MAT_ARDOISE = Enum.Material.Slate
	local MAT_VERRE = Enum.Material.Glass
	local MAT_NEON = Enum.Material.Neon

	-- teinte des lumières selon l'événement en cours
	local COULEURS_EVENEMENT = {
		PluieDeMeteores = Charte.violet,
		Eruption = Charte.lave,
		LuneDoree = Charte.dore,
	}

	-- ===== création avec compteur : on s'arrête net au budget =====
	local compteur = 0
	local function creer(fabrique, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		compteur = compteur + 1
		return fabrique(parent, props)
	end
	local function bloc(parent, props)
		return creer(Outils.bloc, parent, props)
	end
	local function coin(parent, props)
		return creer(Outils.coin, parent, props)
	end
	local function boule(parent, props)
		return creer(Outils.boule, parent, props)
	end
	local function cylindre(parent, props)
		return creer(Outils.cylindre, parent, props)
	end

	local function point(angle, rayon, y)
		return Vector3.new(CX + math.sin(angle) * rayon, y, CZ + math.cos(angle) * rayon)
	end
	local function ecartSud(angle)
		return math.abs(math.atan2(math.sin(angle), math.cos(angle)))
	end
	-- éléments qui réagissent aux événements
	local veines = {}   -- parts Neon violettes (météorite et fissures)
	local cristaux = {} -- { part, vif, faible, repos, actif } (transparences au repos / pendant l'événement)
	local lumieres = {} -- { l, repos = {...}, actif = {...} } ; la première est celle du coeur
	local emetteurs = {} -- { e, genre, rateRepos, rateActif }

	local function lumiere(part, portee, eclat, couleur, porteeActive, eclatActif, ombres)
		if not part then
			return nil
		end
		local l = Outils.lumiere(part, { Range = portee, Brightness = eclat, Color = couleur })
		pcall(function()
			l.Shadows = ombres == true
		end)
		table.insert(lumieres, {
			l = l,
			repos = { Brightness = eclat, Range = portee, Color = couleur },
			actif = { Brightness = eclatActif, Range = porteeActive },
		})
		return l
	end

	local modele = Outils.modele(dossier, "Cratere")

	-- ===== 1. la cuvette en terrain =====
	-- Règle : aucune forme de terrain sous 4 studs (taille d'un voxel Roblox), sinon elle devient un
	-- grumeau ou disparaît. Les détails plus fins sont des parts (plus bas).
	local RAYON_CREUX = RAYON_CRETE - 2          -- bord intérieur du rebord (paroi de la cuvette)
	local RAYON_BOSSES = RAYON_CRETE - 0.8       -- centre des 8 bosses qui cassent le rebord
	-- bosses et grappes de cristaux alternent (angles en degrés depuis le sud, +Z) : rien ne s'enterre
	local ANGLES_BOSSES = { 42, 85, 125, 160, 200, 235, 275, 318 }
	local ANGLES_GRAPPES = { 65, 145, 180, 215, 295 }
	local RAYON_GRAPPES = 7
	local terrainOk = Outils.terrainBoule ~= nil and Outils.terrainCylindre ~= nil
	local fond = Outils.modele(modele, "Fond")
	if terrainOk then
		-- anneau plein de basalte (y -0,5 à 2,5), qui reste dans le disque de l'emprise
		Outils.terrainCylindre(CFrame.new(CX, 1, CZ), 3, RAYON_CRETE + 3, MAT_BASALTE)
		-- creusé au centre : la paroi intérieure nette du cratère
		Outils.terrainCylindre(CFrame.new(CX, 1.5, CZ), 4, RAYON_CREUX, Enum.Material.Air)
		-- fond plat de basalte (dessus à Y_FOND)
		local h = 4 + Y_FOND
		Outils.terrainCylindre(CFrame.new(CX, Y_FOND - h / 2, CZ), h, RAYON_FOND, MAT_BASALTE)
		-- butte sous la météorite : elle paraît enfoncée dans le sol
		Outils.terrainBoule(Vector3.new(CX, -3.3, CZ), 5.6, MAT_BASALTE)
		-- 8 grosses bosses de roche claire (même pierre que les flancs du Volcan) qui cassent le rebord ;
		-- rayon 4 à 4,3 au plus pour que la partie visible reste dans l'emprise (disque RAYON)
		for i, deg in ipairs(ANGLES_BOSSES) do
			local a = math.rad(deg + rng:NextNumber(-4, 4))
			local y = rng:NextNumber(-1, -0.2)
			local rMax = math.sqrt((RAYON - 0.1 - RAYON_BOSSES) ^ 2 + y * y)
			local r = math.max(4, math.min(rng:NextNumber(4, 4.6), rMax))
			if i == 1 or i == #ANGLES_BOSSES then
				-- épaules de l'entrée : plus basses
				r, y = 4, -1
			end
			Outils.terrainBoule(point(a, RAYON_BOSSES, y), r, MAT_ROCHE)
		end
		-- entrée sud ouverte : on vide le rebord entre les piliers du portique (le sol reste à Y_FOND)
		-- (on part de 3 studs dans la cuvette : aucun seuil ne reste dans le voxel de la paroi)
		local zDebut, zFin = CZ + RAYON_CREUX - 3, CZ + RAYON - 0.1
		local hautEntree = 6
		Outils.terrainBloc(
			CFrame.new(CX, Y_FOND + hautEntree / 2, (zDebut + zFin) / 2),
			Vector3.new(11.2, hautEntree, zFin - zDebut),
			Enum.Material.Air
		)
		-- sol continu de l'entrée (dessus à Y_FOND) : ni seuil ni creux entre le parvis et le fond
		Outils.terrainBloc(
			CFrame.new(CX, Y_FOND - 2, (zDebut + zFin) / 2),
			Vector3.new(11.2, 4, zFin - zDebut),
			MAT_BASALTE
		)
	else
		-- sans terrain : un disque de secours en parts
		cylindre(fond, {
			Name = "Fond",
			Size = Vector3.new(0.2, RAYON_FOND * 2, RAYON_FOND * 2),
			CFrame = CFrame.new(CX, 0.1, CZ) * CFrame.Angles(0, 0, math.rad(90)),
			Color = CAILLOU,
			Material = MAT_BASALTE,
			CanTouch = false,
		})
	end

	-- petit rocher (moins de 4 studs, donc en part) : boule aplatie Size (r*2, r*1,2, r*1,6), tournée au hasard,
	-- posée à demi enfoncée sur ySol
	local function rocher(parent, nom, a, rayon, ySol, r, couleur, materiau, solide)
		local taille = Vector3.new(r * 2, r * 1.2, r * 1.6)
		return boule(parent, {
			Name = nom,
			Size = taille,
			CFrame = CFrame.new(point(a, rayon, ySol + taille.Y * 0.18))
				* CFrame.Angles(0, rng:NextNumber(0, 2 * math.pi), 0)
				* CFrame.Angles(rng:NextNumber(-0.3, 0.3), 0, rng:NextNumber(-0.3, 0.3)),
			Color = couleur,
			Material = materiau,
			CanCollide = solide == true,
			CanTouch = false,
		})
	end

	-- éjectas : blocs arrachés tout autour de la butte de la météorite (jamais dans l'allée d'entrée)
	for i, deg in ipairs({ 30, 105, 162, 198, 255, 330 }) do
		local a = math.rad(deg + rng:NextNumber(-5, 5))
		if ecartSud(a) > math.rad(18) then
			local materiau = MAT_BASALTE
			local couleur = CAILLOU
			if i % 2 == 0 then
				materiau = MAT_ARDOISE
				couleur = ROCHE_OMBRE
			end
			rocher(fond, "Ejecta", a, 5.3, Y_FOND, rng:NextNumber(1.1, 1.5), couleur, materiau, true)
		end
	end

	-- fissures lumineuses en zigzag qui rayonnent depuis la météorite
	local function segmentFissure(a, b, largeur)
		local longueur = (b - a).Magnitude
		if longueur < 0.1 then
			return
		end
		local f = bloc(fond, {
			Name = "Fissure",
			Size = Vector3.new(largeur, 0.14, longueur + largeur * 0.5),
			CFrame = CFrame.lookAt((a + b) / 2, b),
			Color = VIOLET_FAIBLE,
			Material = MAT_NEON,
			Transparency = TRANSP_REPOS,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,
		})
		if f then
			table.insert(veines, f)
		end
	end
	local NB_FISSURES = 8
	for i = 1, NB_FISSURES do
		local a = (i - 0.5) * (2 * math.pi / NB_FISSURES) + rng:NextNumber(-0.15, 0.15)
		-- elles s'arrêtent avant le pied du talus (rayon ~7,5)
		local p0 = point(a, 4.4, Y_FISSURE)
		local aA = a + rng:NextNumber(-0.35, 0.35)
		local p1 = p0 + Vector3.new(math.sin(aA), 0, math.cos(aA)) * rng:NextNumber(1.7, 2.1)
		local aB = a + rng:NextNumber(-0.5, 0.5)
		local p2 = p1 + Vector3.new(math.sin(aB), 0, math.cos(aB)) * rng:NextNumber(1.1, 1.4)
		segmentFissure(p0, p1, 0.42)
		segmentFissure(p1, p2, 0.24)
	end

	-- cailloux de basalte et d'ardoise sur le fond (jamais dans l'allée d'entrée ni sur les grappes)
	local function loinDesGrappes(a, rayon)
		local p = point(a, rayon, 0)
		for _, deg in ipairs(ANGLES_GRAPPES) do
			if Outils.distanceXZ(p, point(math.rad(deg), RAYON_GRAPPES, 0)) < 2.4 then
				return false
			end
		end
		return true
	end
	local posesCailloux = 0
	local essais = 0
	while posesCailloux < 8 and essais < 60 do
		essais = essais + 1
		local a = rng:NextNumber(0, 2 * math.pi)
		local rayon = rng:NextNumber(5.4, 7.4)
		if ecartSud(a) > math.rad(30) and loinDesGrappes(a, rayon) then
			posesCailloux = posesCailloux + 1
			local materiau, couleur = MAT_BASALTE, CAILLOU
			if posesCailloux % 3 == 0 then
				materiau, couleur = MAT_ARDOISE, ROCHE_OMBRE
			end
			rocher(fond, "Caillou", a, rayon, Y_FOND, rng:NextNumber(0.35, 0.6), couleur, materiau, false)
		end
	end

	-- ===== 2. le rebord : dalles d'éjecta basculées vers l'extérieur et blocs =====
	local rebord = Outils.modele(modele, "Rebord")
	-- dalles et blocs extérieurs en pierre chaude (accord avec la crête de roche et le Volcan), en trois teintes
	local PIERRE_CHAUDE = hex("9C8069")
	local teintesChaudes = { PIERRE_CHAUDE, Charte.ombre(PIERRE_CHAUDE), Charte.lumiere(PIERRE_CHAUDE) }
	local teintes = teintesChaudes
	local NB_DALLES = 14
	for i = 0, NB_DALLES - 1 do
		local a = (i + 0.5) * (2 * math.pi / NB_DALLES) + rng:NextNumber(-0.08, 0.08)
		if ecartSud(a) > OUVERTURE + math.rad(12) then
			local taille = Vector3.new(rng:NextNumber(2.4, 3.4), rng:NextNumber(1.3, 1.9), rng:NextNumber(1.8, 2.6))
			bloc(rebord, {
				Name = "Dalle",
				Size = taille,
				CFrame = CFrame.new(point(a, RAYON_CRETE + 0.3, 2.6 + rng:NextNumber(0, 0.5)))
					* CFrame.Angles(0, a + rng:NextNumber(-0.25, 0.25), 0)
					* CFrame.Angles(rng:NextNumber(0.35, 0.6), 0, rng:NextNumber(-0.15, 0.15)),
				Color = teintes[rng:NextInteger(1, 3)],
				Material = MAT_ARDOISE,
				CanTouch = false,
			})
		end
	end
	-- éboulis : blocs aplatis sur l'épaule extérieure de la crête et au pied de la paroi intérieure
	-- (entre les bosses, là où la paroi reste nette)
	for i = 1, 10 do
		local deg = ANGLES_BOSSES[(i - 1) % #ANGLES_BOSSES + 1]
		local suivant = ANGLES_BOSSES[i % #ANGLES_BOSSES + 1]
		if suivant < deg then
			suivant = suivant + 360
		end
		local a = math.rad(deg + (suivant - deg) * rng:NextNumber(0.3, 0.7))
		if ecartSud(a) > OUVERTURE + math.rad(8) then
			local exterieur = i % 2 == 0
			-- dehors : pierre chaude comme la crête, sur l'épaule ; dedans : basalte brûlé au pied de la paroi
			if exterieur then
				rocher(rebord, "Bloc", a, RAYON - 1.9, 2.2, rng:NextNumber(0.9, 1.2), teintesChaudes[rng:NextInteger(1, 3)], MAT_ROCHE, true)
			else
				rocher(rebord, "Bloc", a, RAYON_CREUX - 1, Y_FOND, rng:NextNumber(0.9, 1.3), CAILLOU, MAT_BASALTE, true)
			end
		end
	end

	-- ===== 3. la météorite géante =====
	local meteorite = Outils.modele(modele, "Meteorite")
	local centreMeteorite = Vector3.new(CX, Y_METEORITE, CZ)
	local corps = boule(meteorite, {
		Name = "Corps",
		Size = Vector3.new(RAYON_METEORITE * 2, RAYON_METEORITE * 2, RAYON_METEORITE * 2),
		CFrame = CFrame.new(centreMeteorite),
		Color = METEORE,
		Material = MAT_BASALTE,
	})
	if corps then
		meteorite.PrimaryPart = corps
	end

	-- direction aléatoire (composante verticale entre yMin et yMax)
	local function direction(yMin, yMax)
		local d = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(yMin, yMax), rng:NextNumber(-1, 1))
		if d.Magnitude < 0.05 then
			d = Vector3.new(0, 1, 0)
		end
		return d.Unit
	end

	-- bosses qui cassent la rondeur (plutôt en bas et sur les flancs)
	for _ = 1, 4 do
		local d = direction(-0.25, 0.35)
		local t = rng:NextNumber(3.6, 4.6)
		boule(meteorite, {
			Name = "Bosse",
			Size = Vector3.new(t, t, t),
			CFrame = CFrame.new(centreMeteorite + d * (RAYON_METEORITE - 1.1)),
			Color = METEORE_BOSSE,
			Material = MAT_BASALTE,
		})
	end
	-- facettes taillées à plat (éclats arrachés à l'impact), tangentes à la surface
	local eclats = {}
	for _ = 1, 4 do
		local d = direction(-0.1, 0.6)
		local t = rng:NextNumber(2.4, 3.2)
		local p = centreMeteorite + d * (RAYON_METEORITE - 0.25)
		local e = bloc(meteorite, {
			Name = "Eclat",
			Size = Vector3.new(t, t * rng:NextNumber(0.6, 0.85), 0.9),
			CFrame = CFrame.lookAt(p, p + d) * CFrame.Angles(0, 0, rng:NextNumber(0, 6.28)),
			Color = METEORE_SOMBRE,
			Material = MAT_BASALTE,
		})
		if e then
			table.insert(eclats, e)
		end
	end

	-- veines Neon : petites chaînes de 2 segments qui suivent la surface
	local function segmentVeine(n, t, longueur, largeur)
		local vy = n:Cross(t)
		local p = centreMeteorite + n * (RAYON_METEORITE + 0.04)
		local v = bloc(meteorite, {
			Name = "Veine",
			Size = Vector3.new(longueur, largeur, 0.4),
			CFrame = CFrame.fromMatrix(p, t, vy),
			Color = VIOLET_FAIBLE,
			Material = MAT_NEON,
			Transparency = TRANSP_REPOS,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,
		})
		if v then
			table.insert(veines, v)
		end
	end
	local function tangente(n, v)
		local t = v - n * v:Dot(n)
		if t.Magnitude < 0.05 then
			t = n:Cross(Vector3.new(0, 0, 1))
			if t.Magnitude < 0.05 then
				t = n:Cross(Vector3.new(1, 0, 0))
			end
		end
		return t.Unit
	end
	for _ = 1, 6 do
		local n1 = direction(-0.05, 1)
		local t1 = tangente(n1, direction(-1, 1))
		local L1 = rng:NextNumber(2, 2.8)
		segmentVeine(n1, t1, L1, 0.3)
		local L2 = rng:NextNumber(1.5, 2.2)
		local bout = n1 * RAYON_METEORITE + t1 * (L1 / 2 - 0.1)
		local t2 = tangente(bout.Unit, t1 + bout.Unit:Cross(t1) * rng:NextNumber(-0.7, 0.7))
		local n2 = (bout + t2 * (L2 / 2)).Unit
		segmentVeine(n2, tangente(n2, t2), L2, 0.22)
	end

	-- coeur incandescent au sommet (lumière, fumée et braises principales)
	local coeur = boule(meteorite, {
		Name = "Coeur",
		Size = Vector3.new(2.2, 2.2, 2.2),
		CFrame = CFrame.new(centreMeteorite + Vector3.new(0.4, RAYON_METEORITE - 0.55, -0.3)),
		Color = VIOLET_FAIBLE,
		Material = MAT_NEON,
		Transparency = 0.05,
		CanCollide = false,
		CanTouch = false,
		CastShadow = false,
	})
	if coeur then
		table.insert(veines, coeur)
		lumiere(coeur, 16, 1.2, VIOLET, 26, 4, true)
	end

	-- fumée et braises en particules (repli sur un Smoke classique si besoin)
	local function fumer(part, taille, debit)
		if not part then
			return
		end
		local ok, e = pcall(function()
			local p = Instance.new("ParticleEmitter")
			p.Name = "Fumee"
			p.Texture = "rbxasset://textures/particles/smoke_main.dds"
			p.Color = ColorSequence.new(FUMEE, Charte.ombre(FUMEE))
			p.Size = NumberSequence.new(taille, taille * 3)
			p.Transparency = NumberSequence.new(0.55, 1)
			p.Lifetime = NumberRange.new(4, 6)
			p.Rate = debit
			p.Speed = NumberRange.new(2, 4)
			p.SpreadAngle = Vector2.new(14, 14)
			p.Rotation = NumberRange.new(0, 360)
			p.RotSpeed = NumberRange.new(-20, 20)
			p.LightInfluence = 0.6
			p.Parent = part
			return p
		end)
		if ok and e then
			table.insert(emetteurs, { e = e, genre = "fumee", rateRepos = debit, rateActif = debit * 3 })
		else
			pcall(function()
				local s = Instance.new("Smoke")
				s.Color = FUMEE
				s.Opacity = 0.12
				s.RiseVelocity = 3
				s.Size = taille
				s.Parent = part
			end)
		end
	end
	fumer(coeur, 1.6, 3)
	fumer(eclats[1], 1, 1.5)
	fumer(eclats[3], 1, 1.5)
	if coeur then
		local ok, e = pcall(function()
			local p = Instance.new("ParticleEmitter")
			p.Name = "Braises"
			p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			p.Color = ColorSequence.new(VIOLET_VIF, VIOLET)
			p.Size = NumberSequence.new(0.35, 0.05)
			p.Transparency = NumberSequence.new(0, 1)
			p.Lifetime = NumberRange.new(1.5, 2.5)
			p.Rate = 4
			p.Speed = NumberRange.new(3, 6)
			p.SpreadAngle = Vector2.new(35, 35)
			p.LightEmission = 1
			p.Parent = coeur
			return p
		end)
		if ok and e then
			table.insert(emetteurs, { e = e, genre = "braises", rateRepos = 4, rateActif = 18 })
		end
	end

	-- ===== 4. cristaux de verre (coeur Neon) =====
	-- cristal posé sur cfBase (axe du cristal = Y local) : prisme de verre, pointe en toit, coeur lumineux
	local function cristal(parent, cfBase, largeur, hauteur, vif, faible, avecCoeur, bitermine)
		local prof = largeur * 0.8
		local pointe = largeur * 1.15
		local corpsC = bloc(parent, {
			Name = "Cristal",
			Size = Vector3.new(largeur, hauteur, prof),
			CFrame = cfBase * CFrame.new(0, hauteur / 2, 0),
			Color = faible,
			Material = MAT_VERRE,
			Transparency = VERRE_REPOS,
			Reflectance = 0.1,
			CanTouch = false,
			CastShadow = false,
		})
		if corpsC then
			table.insert(cristaux, { part = corpsC, vif = vif, faible = faible, repos = VERRE_REPOS, actif = VERRE_ACTIF })
		end
		local bouts = { hauteur + pointe / 2 }
		if bitermine then
			table.insert(bouts, -pointe / 2)
		end
		for k, y in ipairs(bouts) do
			for s = -1, 1, 2 do
				local cf = cfBase * CFrame.new(0, y, s * prof / 4)
				if s > 0 then
					cf = cf * CFrame.Angles(0, math.pi, 0)
				end
				if k == 2 then
					cf = cf * CFrame.Angles(0, 0, math.pi)
				end
				local p = coin(parent, {
					Name = "Pointe",
					Size = Vector3.new(largeur, pointe, prof / 2),
					CFrame = cf,
					Color = faible,
					Material = MAT_VERRE,
					Transparency = VERRE_REPOS,
					Reflectance = 0.1,
					CanCollide = false,
					CanTouch = false,
					CastShadow = false,
				})
				if p then
					table.insert(cristaux, { part = p, vif = vif, faible = faible, repos = VERRE_REPOS, actif = VERRE_ACTIF })
				end
			end
		end
		local lueur = nil
		if avecCoeur then
			lueur = bloc(parent, {
				Name = "Lueur",
				Size = Vector3.new(largeur * 0.38, hauteur * 0.85, prof * 0.38),
				CFrame = cfBase * CFrame.new(0, hauteur / 2 + 0.1, 0),
				Color = faible,
				Material = MAT_NEON,
				Transparency = 0.1,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
				CastShadow = false,
			})
			if lueur then
				table.insert(cristaux, { part = lueur, vif = vif, faible = faible, repos = 0.1, actif = 0 })
			end
		end
		return corpsC, lueur
	end

	-- cristal biterminé qui flotte au-dessus de la météorite (modèle animé)
	local flottant = Outils.modele(meteorite, "CristalFlottant")
	local hautFlottant = 2.6
	local cfFlottant = CFrame.new(CX, Y_METEORITE + RAYON_METEORITE + 2.4, CZ) * CFrame.Angles(0, math.rad(30), math.rad(10))
	local corpsFlottant = cristal(flottant, cfFlottant, 1.3, hautFlottant, VIOLET_VIF, VIOLET_FAIBLE, true, true)
	if corpsFlottant then
		flottant.PrimaryPart = corpsFlottant
		pcall(Outils.animer, flottant, "flotte", 0.6)
	end

	-- grappes autour de la météorite, en alternance violet / cyan, jamais dans l'allée sud
	local grappes = Outils.modele(modele, "Cristaux")
	-- (angles et rayon définis avec les bosses du rebord, section 1 : les grappes tombent entre elles)
	for g, deg in ipairs(ANGLES_GRAPPES) do
		local a = math.rad(deg + rng:NextNumber(-3, 3))
		local base = point(a, RAYON_GRAPPES, Y_FOND)
		local vif, faible = VIOLET_VIF, VIOLET_FAIBLE
		if g % 2 == 0 then
			vif, faible = CYAN_VIF, CYAN_FAIBLE
		end
		local socle = bloc(grappes, {
			Name = "Socle",
			Size = Vector3.new(2.6, 0.9, 2.3),
			CFrame = CFrame.new(base + Vector3.new(0, 0.2, 0)) * CFrame.Angles(rng:NextNumber(-0.12, 0.12), rng:NextNumber(0, 6.28), rng:NextNumber(-0.12, 0.12)),
			Color = ROCHE_OMBRE,
			Material = MAT_ARDOISE,
			CanTouch = false,
		})
		-- orientation de la grappe : penchée vers le centre du cratère
		local versCentre = a + math.pi
		local grand = 4.2
		if deg == 180 then
			grand = 5.4
		end
		local cfGrand = CFrame.new(base + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, versCentre, 0) * CFrame.Angles(-0.12, 0, 0)
		local _, lueur = cristal(grappes, cfGrand, 1.25, grand + rng:NextNumber(-0.4, 0.4), vif, faible, true, false)
		for c = 1, 2 do
			local lateral = -1
			if c == 2 then
				lateral = 1
			end
			local cf = CFrame.new(base + Vector3.new(0, 0.2, 0))
				* CFrame.Angles(0, versCentre + lateral * rng:NextNumber(0.9, 1.4), 0)
				* CFrame.new(0, 0, 0.5)
				* CFrame.Angles(rng:NextNumber(0.35, 0.6), 0, 0)
			cristal(grappes, cf, rng:NextNumber(0.75, 0.95), rng:NextNumber(2, 3), vif, faible, false, false)
		end
		lumiere(lueur or socle, 10, 0.9, vif, 16, 2.5, false)
	end

	-- ===== 5. portique « ZONE DES ÉVÉNEMENTS » au-dessus de l'entrée sud =====
	local plaqueTextes = {}
	local ligneEtat = nil -- ligne jaune sous le titre flottant

	-- texte de SurfaceGui au look simulateur : blanc (ou coloré), police du jeu, cerné de noir épais
	local function styliserTexte(etiquette, couleur)
		if not etiquette then
			return
		end
		etiquette.TextColor3 = couleur or Color3.new(1, 1, 1)
		if Style then
			etiquette.Font = Style.police
			Style.contour(etiquette, 3)
		end
	end

	if compteur + 11 <= BUDGET then
		local panneau = Outils.modele(modele, "PanneauEvenements")
		local zPortique = CZ + RAYON - 2.6
		local demiPortee = 6.4
		local HAUT_PILIER = 9.2
		local Y_PLANCHE = 8
		for s = -1, 1, 2 do
			local x = CX + s * demiPortee
			bloc(panneau, {
				Name = "Pilier",
				Size = Vector3.new(1.5, HAUT_PILIER, 1.5),
				CFrame = CFrame.new(x, HAUT_PILIER / 2 - 0.3, zPortique),
				Color = ROCHE,
				Material = MAT_ARDOISE,
			})
			bloc(panneau, {
				Name = "Chapeau",
				Size = Vector3.new(2, 0.5, 2),
				CFrame = CFrame.new(x, HAUT_PILIER - 0.05, zPortique),
				Color = ROCHE_OMBRE,
				Material = MAT_ARDOISE,
			})
			local lanterne = boule(panneau, {
				Name = "Lanterne",
				Size = Vector3.new(1.1, 1.1, 1.1),
				CFrame = CFrame.new(x, HAUT_PILIER + 0.7, zPortique),
				Color = VIOLET_FAIBLE,
				Material = MAT_NEON,
				CanCollide = false,
				CanTouch = false,
				CastShadow = false,
			})
			if lanterne then
				table.insert(veines, lanterne)
				lumiere(lanterne, 12, 1, VIOLET, 18, 2.2, false)
			end
		end
		-- traverse en bois cerclée d'un cadre sombre (bordure en relief)
		bloc(panneau, {
			Name = "Cadre",
			Size = Vector3.new(demiPortee * 2 + 0.6, 3.1, 0.5),
			CFrame = CFrame.new(CX, Y_PLANCHE, zPortique),
			Color = BOIS,
			Material = Enum.Material.Wood,
		})
		local planche = bloc(panneau, {
			Name = "Planche",
			Size = Vector3.new(demiPortee * 2 - 1.8, 2.3, 0.8),
			CFrame = CFrame.new(CX, Y_PLANCHE, zPortique),
			Color = Charte.ombre(VIOLET),
			Material = Enum.Material.WoodPlanks,
		})
		if planche then
			for _, face in ipairs({ "Front", "Back" }) do
				local t = Outils.texte(planche, face, "ZONE DES ÉVÉNEMENTS", { couleur = Color3.new(1, 1, 1) })
				styliserTexte(t, Color3.new(1, 1, 1))
			end
		end
		local plaque = bloc(panneau, {
			Name = "Plaque",
			Size = Vector3.new(7.5, 0.9, 0.6),
			CFrame = CFrame.new(CX, Y_PLANCHE - 2.05, zPortique),
			Color = FOND_PLAQUE,
			Material = Enum.Material.Metal,
			CanCollide = false,
			CanTouch = false,
		})
		if plaque then
			local avant = Outils.texte(plaque, "Front", "", { couleur = Charte.dore })
			local arriere = Outils.texte(plaque, "Back", "", { couleur = Charte.dore })
			styliserTexte(avant, Style and Style.couleurs.revenu or Charte.dore)
			styliserTexte(arriere, Style and Style.couleurs.revenu or Charte.dore)
			table.insert(plaqueTextes, avant)
			table.insert(plaqueTextes, arriere)
		end

		-- titre géant flottant « ☄️ ÉVÉNEMENTS » au-dessus du portique, lisible de loin (et sur mobile) ;
		-- le titre de l'événement en cours, lui, flotte au-dessus de la météorite (Systemes/Evenements)
		if Style and planche then
			pcall(function()
				local _, textes = Style.etiquette(planche, {
					{ texte = "☄️ ÉVÉNEMENTS", taille = 1.5, titre = true, rarete = "Epique", contour = 4, nom = "Titre" },
					{ texte = "", taille = 1, couleur = Style.couleurs.revenu, contour = 3.5, nom = "Etat" },
				}, {
					Name = "EtiquetteCratere",
					largeur = 16,
					hauteurLigne = 2,
					StudsOffset = Vector3.new(0, 4.4, 0),
					MaxDistance = 220,
					AlwaysOnTop = false,
				})
				ligneEtat = textes[2]
			end)
		end
	end

	-- ===== 6. réaction aux événements =====
	local function lireAttribut(nom)
		if not Etat then
			return nil
		end
		local ok, valeur = pcall(function()
			return Etat:GetAttribute(nom)
		end)
		if ok then
			return valeur
		end
		return nil
	end

	local function lireEvenement()
		local v = lireAttribut("Evenement")
		if type(v) == "string" then
			return v
		end
		return ""
	end

	local function nomEvenement(cle)
		local E = ctx.Equilibrage
		if E and type(E.evenements) == "table" and type(E.evenements.liste) == "table" then
			local fiche = E.evenements.liste[cle]
			if type(fiche) == "table" and type(fiche.nom) == "string" then
				return fiche.nom
			end
		end
		return cle
	end

	local function ecrirePlaque(texte)
		for _, etiquette in ipairs(plaqueTextes) do
			if etiquette.Parent and etiquette.Text ~= texte then
				etiquette.Text = texte
			end
		end
	end

	local function texteAttente()
		local prochain = lireAttribut("ProchainEvenement")
		if type(prochain) ~= "number" or prochain <= 0 then
			return "Prochain événement bientôt"
		end
		local reste = math.floor(prochain - workspace:GetServerTimeNow())
		if reste <= 0 then
			return "Prochain événement imminent !"
		end
		local minutes = math.floor(reste / 60)
		local secondes = reste % 60
		if minutes > 0 then
			return string.format("Prochain événement : %d min %02d s", minutes, secondes)
		end
		return string.format("Prochain événement : %d s", secondes)
	end

	local function texteEnCours(cle)
		local texte = nomEvenement(cle) .. " en cours !"
		local fin = lireAttribut("EvenementFin")
		if type(fin) == "number" and fin > 0 then
			local reste = math.floor(fin - workspace:GetServerTimeNow())
			if reste > 0 then
				texte = string.format("%s : %d s", nomEvenement(cle), reste)
			end
		end
		return texte
	end

	-- ligne courte sous le titre flottant : compte à rebours jaune, ou « EN COURS ! » rouge vif
	local function ecrireLigneEtat(cle)
		if not ligneEtat or not ligneEtat.Parent then
			return
		end
		local texte = "⏳ BIENTÔT"
		local couleur = Charte.dore
		if Style then
			couleur = Style.couleurs.revenu
		end
		if cle ~= "" then
			texte = "🔥 EN COURS !"
			couleur = Charte.alerte
		else
			local prochain = lireAttribut("ProchainEvenement")
			if type(prochain) == "number" and prochain > 0 then
				local reste = math.floor(prochain - workspace:GetServerTimeNow())
				if reste > 0 then
					texte = string.format("⏳ %d:%02d", math.floor(reste / 60), reste % 60)
				else
					texte = "⏳ IMMINENT !"
				end
			end
		end
		if ligneEtat.Text ~= texte then
			ligneEtat.Text = texte
		end
		if ligneEtat.TextColor3 ~= couleur then
			ligneEtat.TextColor3 = couleur
		end
	end

	local function animerVers(inst, props, duree)
		local ok = pcall(function()
			local info = TweenInfo.new(duree, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			TweenService:Create(inst, info, props):Play()
		end)
		if not ok then
			for cle, valeur in pairs(props) do
				pcall(function()
					inst[cle] = valeur
				end)
			end
		end
	end

	local generation = 0
	local actifCourant = nil
	local cleCourante = nil

	local function appliquer(cle)
		local actif = cle ~= ""
		if actif == actifCourant and cle == cleCourante then
			return
		end
		actifCourant = actif
		cleCourante = cle
		generation = generation + 1
		local maGeneration = generation
		local teinte = COULEURS_EVENEMENT[cle] or VIOLET
		local duree = 1.2

		for _, v in ipairs(veines) do
			if v.Parent then
				if actif then
					animerVers(v, { Color = VIOLET_VIF, Transparency = 0 }, duree)
				else
					animerVers(v, { Color = VIOLET_FAIBLE, Transparency = TRANSP_REPOS }, duree)
				end
			end
		end
		for _, fiche in ipairs(cristaux) do
			if fiche.part.Parent then
				if actif then
					animerVers(fiche.part, { Color = fiche.vif, Transparency = fiche.actif }, duree)
				else
					animerVers(fiche.part, { Color = fiche.faible, Transparency = fiche.repos }, duree)
				end
			end
		end
		for i, fiche in ipairs(lumieres) do
			local l = fiche.l
			if l and l.Parent then
				if actif then
					local couleur = teinte
					if i > 1 then
						couleur = teinte:Lerp(Charte.creme, 0.25)
					end
					animerVers(l, { Brightness = fiche.actif.Brightness, Range = fiche.actif.Range, Color = couleur }, duree)
				else
					animerVers(l, { Brightness = fiche.repos.Brightness, Range = fiche.repos.Range, Color = fiche.repos.Color }, duree)
				end
			end
		end
		for _, fiche in ipairs(emetteurs) do
			local e = fiche.e
			if e.Parent then
				pcall(function()
					if actif then
						e.Rate = fiche.rateActif
						if fiche.genre == "fumee" then
							e.Color = ColorSequence.new(FUMEE:Lerp(teinte, 0.45), Charte.ombre(FUMEE))
						else
							e.Color = ColorSequence.new(teinte:Lerp(Charte.creme, 0.3), teinte)
						end
					else
						e.Rate = fiche.rateRepos
						if fiche.genre == "fumee" then
							e.Color = ColorSequence.new(FUMEE, Charte.ombre(FUMEE))
						else
							e.Color = ColorSequence.new(VIOLET_VIF, VIOLET)
						end
					end
				end)
			end
		end

		-- pendant l'événement, la lumière du coeur palpite doucement
		local premiere = lumieres[1]
		if actif and premiere and premiere.l then
			local lumiereCoeur = premiere.l
			task.spawn(function()
				task.wait(duree)
				local t = 0
				while generation == maGeneration and lumiereCoeur.Parent and dossier.Parent do
					t = t + 0.1
					lumiereCoeur.Brightness = 3.5 + math.sin(t * 3) * 1.2
					task.wait(0.1)
				end
			end)
		end
	end

	local function verifier()
		local ok = pcall(appliquer, lireEvenement())
		return ok
	end

	if Etat then
		local ok, signal = pcall(function()
			return Etat:GetAttributeChangedSignal("Evenement")
		end)
		if ok and signal then
			local connexion
			connexion = signal:Connect(function()
				if not dossier.Parent then
					if connexion then
						connexion:Disconnect()
					end
					return
				end
				verifier()
			end)
		end
	end
	verifier()

	-- plaque d'annonce : rafraîchie chaque seconde tant que la map existe
	if #plaqueTextes > 0 or ligneEtat then
		task.spawn(function()
			while dossier.Parent do
				pcall(function()
					local cle = lireEvenement()
					if cle ~= "" then
						ecrirePlaque(texteEnCours(cle))
					else
						ecrirePlaque(texteAttente())
					end
					ecrireLigneEtat(cle)
				end)
				task.wait(1)
			end
		end)
	end

	dossier:SetAttribute("Parts", compteur)
end

return M
