-- Constructeur Riviere (plan v2, STYLE.md §4) : rivière d'ouest en est au sud de la Place, sur la bande Plan.riviere.
-- Elle naît d'une cascade à deux étages qui sort d'une gorge taillée dans la falaise est (Plan.falaises.est),
-- coule vers l'ouest dans un lit SINUEUX creusé dans le terrain (Air, fond de Sand, Water jusqu'à 0,8 sous l'herbe)
-- et se perd sous un amas de roches au pied de la falaise ouest. Berges en pente de sable, boue, rochers Slate/Rock,
-- galets, roseaux, nénuphars. UN SEUL pont de bois en arc, dans l'axe de la Place (Plan.place.centre.X), qui mène au
-- belvédère de la rive sud (terrasse de planches au pied de la falaise sud, feu de camp, banc et longue-vue tournés vers la
-- cascade) : plus aucun pont ne bute contre la falaise. Au bout des autres allées (Plan.allees.x), de simples pontons de
-- pêche partent de la rive NORD et s'arrêtent au milieu du courant (barque amarrée, canne à pêche) : un but, pas une impasse.
-- Effets légers : reflets et flocons d'écume qui descendent le courant, ronds dans l'eau, lucioles, libellules qui
-- tournent au-dessus de l'eau (Outils.animer), embruns, gouttes et arc-en-ciel (Beams) au pied de la cascade.
-- Emprise (CONTRAT §10) : bande Plan.riviere (zMin..zMax sur xMin..xMax) + la cascade dans la falaise est.
-- Aucune coordonnée en dur : tout vient de Plan.
local M = {}

local BUDGET = 320 -- parts au maximum pour ce constructeur (le terrain ne compte pas)

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	local Mat = Enum.Material

	-- réglages facultatifs (Equilibrage.riviere), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.riviere) == "table" then
		reglages = ctx.Equilibrage.riviere
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	-- ===== géométrie (Plan v2) =====
	local R = Plan.riviere
	if type(R) ~= "table" then
		warn("[Dino] Riviere : Plan.riviere absent")
		return
	end
	local largeurPlan = R.largeur or 14
	local zPlan = R.z
	if type(zPlan) ~= "number" then
		zPlan = (R.zMin + R.zMax) / 2
	end
	local Z_MIN = R.zMin or (zPlan - largeurPlan / 2)
	local Z_MAX = R.zMax or (zPlan + largeurPlan / 2)
	local zCentre = (Z_MIN + Z_MAX) / 2
	local LARGEUR = Z_MAX - Z_MIN
	local X_MIN = R.xMin
	local X_MAX = R.xMax
	local monde = Plan.monde
	if type(X_MIN) ~= "number" then
		X_MIN = monde.min.X + 17
	end
	if type(X_MAX) ~= "number" then
		X_MAX = monde.max.X - 17
	end

	-- falaises : la cascade sort de la falaise est, la rivière se perd au pied de la falaise ouest
	local F = Plan.falaises or {}
	local XF = X_MAX + 2 -- pied de la falaise est
	if F.est and type(F.est.xMin) == "number" then
		XF = F.est.xMin
	end
	local PROF_FALAISE = 16 -- la gorge s'enfonce au plus de ... studs dans la falaise
	if F.est and type(F.est.xMax) == "number" then
		PROF_FALAISE = math.max(12, math.min(PROF_FALAISE, F.est.xMax - XF - 6))
	end

	-- couloir libre : entre la Jungle (au nord) et la falaise sud
	local Z_LIBRE_MIN, Z_LIBRE_MAX = Z_MIN - 2, Z_MAX + 2
	if Plan.decor then
		for _, cle in ipairs({ "jungleOuest", "jungleEst" }) do
			local j = Plan.decor[cle]
			if j and j.max then
				Z_LIBRE_MIN = math.max(Z_LIBRE_MIN, j.max.Z + 1)
			end
		end
	end
	if F.sud and type(F.sud.zMin) == "number" then
		Z_LIBRE_MAX = math.min(Z_LIBRE_MAX, F.sud.zMin - 2)
	end

	local PROF = 4                                -- profondeur de l'eau (dessus du sol à Y = 0)
	local X_ROCHE = X_MAX - 4                     -- face ouest du contrefort de la cascade
	local HAUT_CASCADE = math.min(18, math.max(10, reglage("hauteurCascade", 14)))
	local HAUT_ETAGE = 8                          -- l'étage haut de la cascade, au fond de la gorge
	local LARGEUR_CHUTE = math.min(7, LARGEUR - 5)
	local X_GORGE = XF + math.floor(PROF_FALAISE * 0.45) -- fond de la gorge basse (pied de la chute haute)
	local X_GORGE_FIN = XF + PROF_FALAISE          -- fond de la gorge haute

	-- un seul pont, dans l'axe de la Place (il mène au belvédère de la rive sud) ; au bout des autres allées,
	-- des pontons de pêche côté nord (la rive sud n'a que quelques studs avant la falaise : pas de traversée sans but)
	local ponts = {}
	local pontons = {}
	local xAllees = {}
	if Plan.allees and type(Plan.allees.x) == "table" then
		xAllees = Plan.allees.x
	end
	local xPlace = nil
	if Plan.place and Plan.place.centre then
		xPlace = Plan.place.centre.X
	elseif #xAllees > 0 then
		-- sans Place : l'allée la plus proche du centre
		xPlace = xAllees[1]
		for _, xa in ipairs(xAllees) do
			if math.abs(xa) < math.abs(xPlace) then
				xPlace = xa
			end
		end
	end
	if xPlace then
		table.insert(ponts, { x = xPlace, largeur = 9 })
	end
	for _, xa in ipairs(xAllees) do
		if not xPlace or math.abs(xa - xPlace) > 12 then
			table.insert(pontons, { x = xa, largeur = 4 })
		end
	end
	local ARC_PONT = 1.8

	local rng = Outils.aleatoire(reglage("graine", 1157))

	-- ===== tracé sinueux =====
	local PAS = 4                 -- pas du tracé sur x (grille du terrain)
	local Y_EAU = -0.8            -- surface de l'eau : 0,8 stud sous les berges (herbe à Y = 0)
	local LARGE_BERGE = 3.6       -- largeur de la pente de sable d'une berge
	local HAUT_BERGE = 1.5        -- la berge descend de 0 à -1,5
	local K = LARGEUR / 14        -- amplitude des boucles proportionnelle à la bande
	-- axe du lit ; il rejoint le milieu de la bande devant la cascade (bassin centré) et sous les ponts
	local function zc(x)
		local z = zCentre + 3.5 * K * math.sin(x / 37) + 1.5 * K * math.sin(x / 13)
		local w = math.clamp((x - (X_ROCHE - 36)) / 24, 0, 1)
		z = z + (zCentre - z) * w
		return math.clamp(z, Z_MIN + 2, Z_MAX - 2)
	end
	-- axe, demi-largeur de l'eau (r) et demi-largeur du lit au bord haut des berges (h) à l'abscisse x
	local function lit(x)
		local z = zc(x)
		local r = 4.2 + 0.5 * math.sin(x / 23 + 1.3)
		r = math.min(r, z - Z_LIBRE_MIN - 2.2, Z_LIBRE_MAX - z - 2.2)
		r = math.max(r, 2.6)
		return z, r, r + 2.2
	end
	-- hauteur du sol à la distance d de l'axe : herbe (0), pente de sable (0 -> -1,5), fond (-PROF)
	local function ySol(x, d)
		local _, _, h = lit(x)
		d = math.abs(d)
		if d >= h then
			return 0
		end
		local t = (h - d) / LARGE_BERGE
		if t <= 1 then
			return -HAUT_BERGE * t
		end
		return -PROF
	end

	-- ===== couleurs (base, ombre, lumière) =====
	local hex = Charte.hex
	local EAU = hex("1FD3DE")          -- turquoise vif du terrain Water
	local EAU_CLAIRE = hex("B8F4FF")   -- reflets, filets de la chute
	local CHUTE = hex("E6FAFF")        -- rideau blanc-bleu
	local ROCHE_LEVRE = hex("A88B70")  -- rebord de pierre (Slate) assorti aux falaises
	local ECUME = hex("FFFFFF")
	local BOIS = hex("B97A45")         -- planches (WoodPlanks)
	local BOIS_CLAIR = Charte.lumiere(BOIS)
	local POUTRE = hex("7A4E2C")       -- poteaux, rambardes, poutres (Wood)
	local POUTRE_OMBRE = Charte.ombre(POUTRE)
	local LANTERNE = hex("FFC766")
	local GALETS = { hex("9AA2AE"), hex("B3B9C2"), hex("7F8793"), hex("C2B8A8"), hex("8D8579") }
	local TIGE = hex("5DAA3C")
	local TIGE_OMBRE = Charte.ombre(TIGE)
	local MASSETTE = hex("6B4428")
	local FEUILLE = hex("5CC23F")
	local FEUILLE_OMBRE = Charte.ombre(FEUILLE)
	local FLEURS = { hex("FF7EB9"), hex("FFFFFF"), hex("FFD84D") }
	local LIBELLULES = { hex("2FA8FF"), hex("35D07F"), hex("B45CFF"), hex("FF5C8A") }
	local AILE = hex("DDF6FF")
	local LUCIOLE = hex("E8FF7A")
	local ARC = { hex("FF4D4D"), hex("FF9F2E"), hex("FFE14D"), hex("5CE65C"), hex("4DA6FF"), hex("A05CFF") }

	-- ===== création sous budget =====
	local compte = 0
	local function reste()
		return BUDGET - compte
	end
	local function creer(fabrique, parent, props)
		if compte >= BUDGET then
			return nil
		end
		local ok, part = pcall(fabrique, parent, props)
		if not ok or not part then
			return nil
		end
		compte = compte + 1
		return part
	end
	local function bloc(parent, props) return creer(Outils.bloc, parent, props) end
	local function boule(parent, props) return creer(Outils.boule, parent, props) end
	local function cylindre(parent, props) return creer(Outils.cylindre, parent, props) end

	-- décor pur : ni collision, ni requête, ni contact
	local function decor(props)
		props.CanCollide = false
		props.CanQuery = false
		props.CanTouch = false
		return props
	end

	-- terrain : seulement si les outils de terrain existent
	local terrainOk = Outils.terrainBloc ~= nil and Outils.terrainBoule ~= nil and Outils.terrainCoin ~= nil
	local function tBloc(cf, taille, materiau)
		if terrainOk then
			Outils.terrainBloc(cf, taille, materiau)
		end
	end
	local function tBoule(centre, rayon, materiau)
		if terrainOk then
			Outils.terrainBoule(centre, rayon, materiau)
		end
	end
	local function tCoin(cf, taille, materiau)
		if terrainOk then
			Outils.terrainCoin(cf, taille, materiau)
		end
	end
	-- cylindre d'axe Y (cf = centre) ; à défaut d'outil, un bloc carré de même emprise
	local function tCylindre(cf, hauteur, rayon, materiau)
		if not terrainOk then
			return
		end
		if Outils.terrainCylindre then
			Outils.terrainCylindre(cf, hauteur, rayon, materiau)
		else
			Outils.terrainBloc(cf, Vector3.new(2 * rayon, hauteur, 2 * rayon), materiau)
		end
	end
	-- bloc de terrain donné par ses bornes
	local function tBornes(x0, x1, y0, y1, z0, z1, materiau)
		if x1 <= x0 or y1 <= y0 or z1 <= z0 then
			return
		end
		tBloc(CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), Vector3.new(x1 - x0, y1 - y0, z1 - z0), materiau)
	end

	-- zones à ne pas encombrer (ponts, cascade) pour les petits objets
	local function surPont(x, marge)
		for _, liste in ipairs({ ponts, pontons }) do
			for _, p in ipairs(liste) do
				if math.abs(x - p.x) <= p.largeur / 2 + marge then
					return true
				end
			end
		end
		return false
	end
	local occupes = {}
	local function libre(x, z, rayon)
		if surPont(x, rayon + 1) then
			return false
		end
		if x > X_ROCHE - 9 or x < X_MIN + 5 then
			return false
		end
		for _, o in ipairs(occupes) do
			local dx, dz = x - o[1], z - o[2]
			local r = rayon + o[3]
			if dx * dx + dz * dz < r * r then
				return false
			end
		end
		return true
	end
	local function occuper(x, z, rayon)
		table.insert(occupes, { x, z, rayon })
	end

	-- émetteur de particules : chaque réglage dans son pcall (un réglage inconnu n'annule pas les autres)
	local function emetteur(parent, nom, props)
		if not parent then
			return nil
		end
		local ok, p = pcall(function()
			local e = Instance.new("ParticleEmitter")
			e.Name = nom
			e.Texture = "rbxasset://textures/particles/smoke_main.dds"
			return e
		end)
		if not ok or not p then
			return nil
		end
		for cle, valeur in pairs(props) do
			pcall(function()
				p[cle] = valeur
			end)
		end
		pcall(function()
			p.Parent = parent
		end)
		return p
	end
	local function fondu(a, b)
		return NumberSequence.new({ NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(1, b) })
	end
	local function apparaitFond(a, pic, b)
		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, pic),
			NumberSequenceKeypoint.new(1, b),
		})
	end

	local dBerges = Outils.dossier(dossier, "Berges")
	local dVegetation = Outils.dossier(dossier, "Vegetation")
	local dPonts = Outils.dossier(dossier, "Ponts")
	local dEffets = Outils.dossier(dossier, "Effets")

	-- ===== 1. l'eau et le lit (terrain) =====
	local function construireEau()
		pcall(function()
			local t = workspace.Terrain
			t.WaterColor = EAU
			t.WaterTransparency = 0.4
			t.WaterWaveSize = 0.1
			t.WaterWaveSpeed = 8
			t.WaterReflectance = 0.6
		end)
		if not terrainOk then
			-- outils sans terrain : une seule nappe d'eau de secours
			bloc(dossier, decor({
				Name = "EauSecours",
				Size = Vector3.new(X_ROCHE - X_MIN, 0.4, LARGEUR),
				CFrame = CFrame.new((X_MIN + X_ROCHE) / 2, 0.2, zCentre),
				Color = EAU,
				Material = Mat.Glass,
				Transparency = 0.35,
			}))
			return
		end
		-- le lit, pas à pas le long de l'axe sinueux : on creuse (Air) de -0,8 à +1, on pose le fond
		-- de sable, puis l'eau de -PROF à -0,8 (surface sous le niveau des berges)
		local hCreux = 1 - Y_EAU
		local x = X_MIN
		while x <= X_ROCHE - PAS do
			local z, r, h = lit(x)
			tCylindre(CFrame.new(x, (Y_EAU + 1) / 2, z), hCreux, h, Mat.Air)
			tCylindre(CFrame.new(x, -PROF - 1, z), 2, r + 0.8, Mat.Sand)
			tCylindre(CFrame.new(x, (-PROF + Y_EAU) / 2, z), PROF + Y_EAU, r, Mat.Water)
			x = x + PAS
		end
		-- bassin plus large et plus profond au pied de la cascade
		local xb = X_ROCHE - 5
		local rb = math.min(6, LARGEUR / 2 - 1)
		tCylindre(CFrame.new(xb, (Y_EAU + 1) / 2, zCentre), hCreux, rb + 0.8, Mat.Air)
		tCylindre(CFrame.new(xb, -PROF - 2.5, zCentre), 2, rb + 1, Mat.Sand)
		tCylindre(CFrame.new(xb, (-PROF - 1.5 + Y_EAU) / 2, zCentre), PROF + 1.5 + Y_EAU, rb, Mat.Water)
	end

	-- ===== 2. berges en pente douce (sable, de 0 à -1,5) qui suivent les boucles, un peu de boue au bord =====
	local function construireBerges()
		local x = X_MIN + PAS
		while x <= X_ROCHE - 10 do
			local z, r, h = lit(x)
			-- orientation locale du tracé : X local le long de la rivière, Z local vers la rive
			local a = math.atan((zc(x + 1) - zc(x - 1)) / 2)
			local nx, nz = -math.sin(a), math.cos(a)
			local le_long = CFrame.Angles(0, -a, 0)
			for _, s in ipairs({ -1, 1 }) do
				-- coin de terrain : haut (0) côté herbe, bas (-1,5) côté eau
				local d = h - LARGE_BERGE / 2
				local cf = CFrame.new(x + s * nx * d, -HAUT_BERGE / 2, z + s * nz * d) * le_long
				if s < 0 then
					cf = cf * CFrame.Angles(0, math.pi, 0)
				end
				tCoin(cf, Vector3.new(PAS + 1.2, HAUT_BERGE, LARGE_BERGE), Mat.Sand)
				-- quelques plaques de boue plates juste sous la surface, au pied de la berge (hauts-fonds bruns)
				if rng:NextNumber() < 0.25 and not surPont(x, 2) then
					local dm = r + rng:NextNumber(-0.3, 0.3)
					local rm = rng:NextNumber(1.2, 1.8)
					tCylindre(CFrame.new(x + s * nx * dm + rng:NextNumber(-1, 1), Y_EAU - 0.35, z + s * nz * dm), 0.5, rm, Mat.Mud)
				end
			end
			x = x + PAS
		end
	end

	-- ===== 3. rochers en terrain (Slate et Rock), jamais sur les ponts =====
	local function construireRochers()
		-- la perte à l'ouest : la rivière disparaît sous un amas de roches au pied de la falaise
		local zs, rs, hs = lit(X_MIN)
		tBoule(Vector3.new(X_MIN - 1, 0.5, zs - hs + 1.5), 3.4, Mat.Rock)
		tBoule(Vector3.new(X_MIN - 1, 0.8, zs + hs - 1.5), 3.6, Mat.Slate)
		tBoule(Vector3.new(X_MIN - 2, 2.4, zs), 3.4, Mat.Rock)
		tBoule(Vector3.new(X_MIN + 1.5, -1.4, zs + rs * 0.5), 2, Mat.Slate)
		tBoule(Vector3.new(X_MIN + 2.5, -1.8, zs - rs * 0.5), 1.6, Mat.Rock)
		occuper(X_MIN, zs, 7)
		local n = math.max(0, math.floor(reglage("rochers", 26)))
		local essais = 0
		local poses = 0
		while poses < n and essais < n * 8 do
			essais = essais + 1
			local r = rng:NextNumber(1.3, 2.6)
			local x = rng:NextNumber(X_MIN + 8, X_ROCHE - 12)
			local dansEau = rng:NextNumber() < 0.4
			local zl, rl = lit(x)
			local z, y
			if dansEau then
				z = zl + rng:NextNumber(-(rl - 1.2), rl - 1.2)
				y = -PROF + r * rng:NextNumber(0.9, 1.25)
			else
				-- à cheval sur la berge : moitié dans l'eau, moitié sur le sable
				local s = 1
				if rng:NextInteger(1, 2) == 1 then
					s = -1
				end
				z = zl + s * (rl + rng:NextNumber(0, 1.5))
				y = rng:NextNumber(-1.4, -0.6)
			end
			if libre(x, z, r + 0.5) then
				local materiau = Mat.Slate
				if rng:NextNumber() < 0.35 then
					materiau = Mat.Rock
				end
				tBoule(Vector3.new(x, y, z), r, materiau)
				-- un second rocher collé au premier pour casser la forme de boule
				if r > 1.8 then
					tBoule(Vector3.new(x + rng:NextNumber(-1.4, 1.4), y - 0.4, z + rng:NextNumber(-0.8, 0.8)), r * 0.65, Mat.Slate)
				end
				occuper(x, z, r + 0.5)
				poses = poses + 1
			end
		end
		-- culées de pierre aux quatre coins de chaque pont (hors du tablier)
		for _, p in ipairs(ponts) do
			local zp, _, hp = lit(p.x)
			for _, sx in ipairs({ -1, 1 }) do
				tBoule(Vector3.new(p.x + sx * (p.largeur / 2 + 1.6), -0.9, zp - hp + 0.8), 1.7, Mat.Slate)
				tBoule(Vector3.new(p.x + sx * (p.largeur / 2 + 1.6), -0.9, zp + hp - 0.8), 1.7, Mat.Slate)
			end
		end
	end

	-- ===== 4. ponts de bois en arc (d'une berge à l'autre) =====
	-- hauteur du dessus du tablier à la fraction t (0..1) de la traversée
	local function hauteurTablier(t)
		return ARC_PONT * math.sin(math.pi * t)
	end
	local zDepart, portee = Z_MIN, LARGEUR
	local function zTablier(t)
		return zDepart + portee * t
	end

	-- poutre droite entre deux points (planche, rambarde, longeron)
	local function poutre(parent, nom, a, b, epaisseurX, epaisseurY, couleur, materiau)
		local long = (b - a).Magnitude
		return bloc(parent, {
			Name = nom,
			Size = Vector3.new(epaisseurX, epaisseurY, long),
			CFrame = CFrame.lookAt((a + b) / 2, b),
			Color = couleur,
			Material = materiau,
		})
	end

	local function construirePont(index, p)
		local xp = p.x
		local LARGEUR_PONT = p.largeur
		local large = LARGEUR_PONT > 7
		local m = Outils.modele(dPonts, "Pont" .. index)
		local demi = LARGEUR_PONT / 2
		-- le tablier part de l'herbe d'une rive et arrive sur l'herbe de l'autre
		local zp, _, hp = lit(xp)
		zDepart = zp - hp - 0.8
		portee = 2 * (hp + 0.8)
		-- tablier : planches inclinées qui suivent l'arc
		local N = 9
		for k = 1, N do
			local ta, tb = (k - 1) / N, k / N
			local a = Vector3.new(xp, hauteurTablier(ta) - 0.22, zTablier(ta))
			local b = Vector3.new(xp, hauteurTablier(tb) - 0.22, zTablier(tb))
			local couleur = BOIS
			if k % 2 == 0 then
				couleur = BOIS_CLAIR
			end
			local planche = poutre(m, "Planche" .. k, a, b, LARGEUR_PONT + rng:NextNumber(-0.25, 0.25), 0.44, couleur, Mat.WoodPlanks)
			if planche then
				-- un léger recouvrement entre deux planches, sans marche
				planche.Size = planche.Size + Vector3.new(0, 0, 0.12)
				planche.CanTouch = false
			end
		end
		-- longerons sous le tablier (deux cordes de l'arc, de chaque côté)
		for _, sx in ipairs({ -1, 1 }) do
			local xl = xp + sx * (demi - 0.45)
			local pA = Vector3.new(xl, -0.7, zTablier(0))
			local pM = Vector3.new(xl, hauteurTablier(0.5) - 0.75, zTablier(0.5))
			local pB = Vector3.new(xl, -0.7, zTablier(1))
			poutre(m, "Longeron", pA, pM, 0.5, 0.6, POUTRE_OMBRE, Mat.Wood)
			poutre(m, "Longeron", pM, pB, 0.5, 0.6, POUTRE_OMBRE, Mat.Wood)
		end
		-- poteaux, rambardes (haute et basse), pilotis et lanternes
		local ts = { 0.02, 0.26, 0.5, 0.74, 0.98 }
		local H_RAMBARDE = 2.3
		for _, sx in ipairs({ -1, 1 }) do
			local xq = xp + sx * (demi - 0.25)
			local hauts = {}
			for i, t in ipairs(ts) do
				local dessus = hauteurTablier(t)
				local bas = math.min(dessus - 0.6, -0.2)
				local haut = dessus + H_RAMBARDE + 0.25
				if i == 1 or i == #ts then
					haut = haut + 0.35
				end
				local z = zTablier(t)
				bloc(m, {
					Name = "Poteau",
					Size = Vector3.new(0.5, haut - bas, 0.5),
					CFrame = CFrame.new(xq, (haut + bas) / 2, z),
					Color = POUTRE,
					Material = Mat.Wood,
				})
				hauts[i] = Vector3.new(xq, dessus, z)
				-- lanterne sur un poteau d'entrée sur deux (en diagonale) ; aux quatre coins sur le grand pont
				local extremite = (i == 1 and sx == -1) or (i == #ts and sx == 1)
				if large and (i == 1 or i == #ts) then
					extremite = true
				end
				if extremite then
					bloc(m, {
						Name = "Toit",
						Size = Vector3.new(0.9, 0.25, 0.9),
						CFrame = CFrame.new(xq, haut + 0.95, z),
						Color = POUTRE_OMBRE,
						Material = Mat.Wood,
					})
					local feu = bloc(m, decor({
						Name = "Lanterne",
						Size = Vector3.new(0.55, 0.7, 0.55),
						CFrame = CFrame.new(xq, haut + 0.45, z),
						Color = LANTERNE,
						Material = Mat.Neon,
					}))
					if feu then
						pcall(function()
							Outils.lumiere(feu, { Range = 14, Brightness = 1.2, Color = LANTERNE })
						end)
						Outils.animer(feu, "pulse", 0.6)
					end
				elseif i == 1 or i == #ts then
					bloc(m, {
						Name = "Chapeau",
						Size = Vector3.new(0.7, 0.2, 0.7),
						CFrame = CFrame.new(xq, haut + 0.1, z),
						Color = POUTRE_OMBRE,
						Material = Mat.Wood,
					})
				end
			end
			-- rambardes : une lisse haute et une lisse basse entre chaque paire de poteaux
			for i = 1, #hauts - 1 do
				local a, b = hauts[i], hauts[i + 1]
				poutre(m, "Rambarde", a + Vector3.new(0, H_RAMBARDE, 0), b + Vector3.new(0, H_RAMBARDE, 0), 0.34, 0.3, POUTRE, Mat.Wood)
				poutre(m, "Lisse", a + Vector3.new(0, 1.1, 0), b + Vector3.new(0, 1.1, 0), 0.22, 0.2, POUTRE_OMBRE, Mat.Wood)
			end
			-- pilotis dans l'eau, sous le tiers et les deux tiers du pont
			for _, t in ipairs({ 0.34, 0.66 }) do
				local haut = hauteurTablier(t) - 0.5
				local bas = -PROF - 0.5
				bloc(m, {
					Name = "Pilotis",
					Size = Vector3.new(0.7, haut - bas, 0.7),
					CFrame = CFrame.new(xp + sx * (demi - 0.9), (haut + bas) / 2, zTablier(t)),
					Color = POUTRE_OMBRE,
					Material = Mat.Wood,
					CanTouch = false,
				})
			end
		end
	end

	local function construirePonts()
		for index, p in ipairs(ponts) do
			if p.x - p.largeur / 2 > X_MIN + 6 and p.x + p.largeur / 2 < X_ROCHE - 12 then
				construirePont(index, p)
				occuper(p.x, zc(p.x), p.largeur / 2 + 1)
				p.construit = true
			end
		end
	end

	-- poteau de rambarde coiffé d'une lanterne (toit, verre Neon, lumière douce qui pulse)
	local function poteauLanterne(parent, x, z, bas, haut)
		bloc(parent, {
			Name = "Poteau",
			Size = Vector3.new(0.5, haut - bas, 0.5),
			CFrame = CFrame.new(x, (haut + bas) / 2, z),
			Color = POUTRE,
			Material = Mat.Wood,
		})
		bloc(parent, {
			Name = "Toit",
			Size = Vector3.new(0.9, 0.25, 0.9),
			CFrame = CFrame.new(x, haut + 0.95, z),
			Color = POUTRE_OMBRE,
			Material = Mat.Wood,
		})
		local feu = bloc(parent, decor({
			Name = "Lanterne",
			Size = Vector3.new(0.55, 0.7, 0.55),
			CFrame = CFrame.new(x, haut + 0.45, z),
			Color = LANTERNE,
			Material = Mat.Neon,
		}))
		if feu then
			pcall(function()
				Outils.lumiere(feu, { Range = 14, Brightness = 1.2, Color = LANTERNE })
			end)
			Outils.animer(feu, "pulse", 0.6)
		end
	end

	-- ===== 4 bis. le belvédère de la rive sud : la destination du pont de la Place =====
	-- terrasse de planches entre l'arrivée du pont et le pied de la falaise sud, ouverte au nord sur le pont ;
	-- à l'ouest un feu de camp et ses rondins, à l'est un banc et une longue-vue tournés vers la cascade,
	-- au fond, contre la falaise, le panneau « BELVÉDÈRE » entre deux jardinières. Le passage central reste libre.
	local function construireBelvedere()
		local p = ponts[1]
		if not p or not p.construit then
			return
		end
		local xp = p.x
		local zp, _, hp = lit(xp)
		local zFalaise = Z_MAX + 6
		if F.sud and type(F.sud.zMin) == "number" then
			zFalaise = F.sud.zMin
		end
		local z0 = zp + hp + 0.5          -- au bout du tablier du pont (herbe de la rive sud)
		local z1 = zFalaise - 0.4         -- pied de la falaise
		local prof = z1 - z0
		if prof < 3 then
			warn("[Dino] Riviere : rive sud trop étroite pour le belvédère (" .. tostring(prof) .. " studs)")
			return
		end
		local DEMI = math.max(p.largeur / 2 + 5.5, 10)
		local OUVERTURE = p.largeur / 2 + 0.8   -- l'ouverture de la rambarde nord, face au pont
		local Y = 0.25                          -- dessus du platelage
		local zMil = (z0 + z1) / 2
		local m = Outils.modele(dossier, "Belvedere")
		-- rien de ce constructeur (rochers, roseaux, galets) ne vient sous la terrasse
		local xo = xp - DEMI
		while xo <= xp + DEMI do
			occuper(xo, z0 + 1, 2.5)
			xo = xo + 3
		end

		-- platelage : planches sur toute la largeur, deux teintes, et une poutre de rive sur trois côtés
		local n = math.max(3, math.floor(prof / 0.95 + 0.5))
		local d = prof / n
		for k = 1, n do
			local couleur = BOIS
			if k % 2 == 0 then
				couleur = BOIS_CLAIR
			end
			bloc(m, {
				Name = "Planche",
				Size = Vector3.new(2 * DEMI + rng:NextNumber(-0.3, 0.3), 0.5, d - 0.06),
				CFrame = CFrame.new(xp + rng:NextNumber(-0.1, 0.1), Y - 0.25, z0 + (k - 0.5) * d),
				Color = couleur,
				Material = Mat.WoodPlanks,
				CanTouch = false,
			})
		end
		bloc(m, {
			Name = "Rive",
			Size = Vector3.new(2 * DEMI + 0.5, 0.7, 0.5),
			CFrame = CFrame.new(xp, Y - 0.3, z0 - 0.2),
			Color = POUTRE_OMBRE,
			Material = Mat.Wood,
		})
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Rive",
				Size = Vector3.new(0.5, 0.7, prof + 0.4),
				CFrame = CFrame.new(xp + sx * (DEMI + 0.05), Y - 0.3, zMil),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
			})
		end

		-- rambardes : côté rivière (de part et d'autre de l'arrivée du pont) et aux deux bouts ; pas côté falaise
		local H_RAMBARDE = 2.3
		local bas = Y - 0.6
		local basN = -1.8   -- côté rivière, les poteaux descendent dans la berge : ils servent de pilotis au bord de la terrasse
		local haut = Y + H_RAMBARDE + 0.25
		local zN, zS = z0 + 0.3, z1 - 0.3
		for _, sx in ipairs({ -1, 1 }) do
			local xCoin = xp + sx * (DEMI - 0.25)
			local xOuv = xp + sx * OUVERTURE
			-- poteau d'angle avec lanterne, poteau d'ouverture, poteau du fond
			poteauLanterne(m, xCoin, zN, basN, haut + 0.35)
			bloc(m, {
				Name = "Poteau",
				Size = Vector3.new(0.5, haut + 0.35 - basN, 0.5),
				CFrame = CFrame.new(xOuv, (haut + 0.35 + basN) / 2, zN),
				Color = POUTRE,
				Material = Mat.Wood,
			})
			bloc(m, {
				Name = "Chapeau",
				Size = Vector3.new(0.7, 0.2, 0.7),
				CFrame = CFrame.new(xOuv, haut + 0.45, zN),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
			})
			bloc(m, {
				Name = "Poteau",
				Size = Vector3.new(0.5, haut - bas, 0.5),
				CFrame = CFrame.new(xCoin, (haut + bas) / 2, zS),
				Color = POUTRE,
				Material = Mat.Wood,
			})
			local segments = {
				{ Vector3.new(xCoin, Y, zN), Vector3.new(xOuv, Y, zN) },
				{ Vector3.new(xCoin, Y, zN), Vector3.new(xCoin, Y, zS) },
			}
			for _, sg in ipairs(segments) do
				poutre(m, "Rambarde", sg[1] + Vector3.new(0, H_RAMBARDE, 0), sg[2] + Vector3.new(0, H_RAMBARDE, 0), 0.34, 0.3, POUTRE, Mat.Wood)
				poutre(m, "Lisse", sg[1] + Vector3.new(0, 1.1, 0), sg[2] + Vector3.new(0, 1.1, 0), 0.22, 0.2, POUTRE_OMBRE, Mat.Wood)
			end
		end

		-- ouest : feu de camp sur une sole de pierre, cercle de galets, bûches en tipi, braises ; deux rondins pour s'asseoir
		local xFeu = xp - (OUVERTURE + DEMI) / 2 + 0.4
		local zFeu = zMil - 0.2
		cylindre(m, {
			Name = "Sole",
			Size = Vector3.new(0.2, 2.6, 2.6),
			CFrame = CFrame.new(xFeu, Y + 0.1, zFeu) * CFrame.Angles(0, 0, math.rad(90)),
			Color = GALETS[3],
			Material = Mat.Slate,
			CanTouch = false,
		})
		for i = 1, 7 do
			local a = (i / 7) * 2 * math.pi
			local dg = rng:NextNumber(0.5, 0.65)
			boule(m, decor({
				Name = "Pierre",
				Size = Vector3.new(dg, dg * 0.8, dg),
				CFrame = CFrame.new(xFeu + 1.1 * math.cos(a), Y + 0.2 + dg * 0.3, zFeu + 1.1 * math.sin(a)),
				Color = GALETS[rng:NextInteger(1, #GALETS)],
				Material = Mat.Slate,
			}))
		end
		for i = 1, 3 do
			local a = (i / 3) * 2 * math.pi + 0.4
			cylindre(m, decor({
				Name = "Buche",
				Size = Vector3.new(1.3, 0.3, 0.3),
				CFrame = CFrame.new(xFeu + 0.3 * math.cos(a), Y + 0.65, zFeu + 0.3 * math.sin(a))
					* CFrame.Angles(0, -a, 0) * CFrame.Angles(0, 0, math.rad(55)),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
			}))
		end
		local flamme = bloc(m, decor({
			Name = "Flamme",
			Size = Vector3.new(0.5, 0.6, 0.5),
			CFrame = CFrame.new(xFeu, Y + 0.6, zFeu),
			Color = hex("FF8A2B"),
			Material = Mat.Neon,
			Transparency = 0.3,
		}))
		if flamme then
			pcall(function()
				local feu = Instance.new("Fire")
				feu.Color = hex("FF7A1A")
				feu.SecondaryColor = hex("FFD84D")
				feu.Size = 2.6
				feu.Heat = 6
				feu.Parent = flamme
			end)
			pcall(function()
				Outils.lumiere(flamme, { Range = 16, Brightness = 1.6, Color = hex("FFA04D") })
			end)
			Outils.animer(flamme, "pulse", 1.4)
			-- braises qui montent et s'éteignent
			emetteur(flamme, "Braises", {
				Color = ColorSequence.new(hex("FFD84D"), hex("FF5A1F")),
				LightEmission = 1,
				Size = fondu(0.18, 0),
				Transparency = fondu(0, 1),
				Lifetime = NumberRange.new(1.2, 2.2),
				Rate = 6,
				Speed = NumberRange.new(2, 4),
				SpreadAngle = Vector2.new(20, 20),
				Acceleration = Vector3.new(0, 1.5, 0),
			})
		end
		-- rondins : un le long du bout ouest, un contre la falaise
		local rondins = {
			{ CFrame.new(xp - DEMI + 0.9, Y + 0.45, zFeu) * CFrame.Angles(0, math.rad(90), 0), math.min(3.2, prof - 1.4) },
			{ CFrame.new(xFeu - 0.2, Y + 0.45, z1 - 0.9), 2.4 },
		}
		for _, rd in ipairs(rondins) do
			cylindre(m, {
				Name = "Rondin",
				Size = Vector3.new(rd[2], 0.9, 0.9),
				CFrame = rd[1],
				Color = POUTRE,
				Material = Mat.Wood,
			})
		end

		-- est : banc face à la cascade (assise le long de z, dossier à l'ouest) et longue-vue pointée sur la chute
		local xBanc = xp + (OUVERTURE + DEMI) / 2 - 0.6
		local LB = math.min(3.4, prof - 1.4)
		bloc(m, {
			Name = "Assise",
			Size = Vector3.new(1.3, 0.25, LB),
			CFrame = CFrame.new(xBanc, Y + 1.1, zMil + 0.2),
			Color = BOIS_CLAIR,
			Material = Mat.WoodPlanks,
		})
		bloc(m, {
			Name = "Dossier",
			Size = Vector3.new(0.25, 1.1, LB),
			CFrame = CFrame.new(xBanc - 0.6, Y + 1.85, zMil + 0.2) * CFrame.Angles(0, 0, math.rad(-10)),
			Color = BOIS,
			Material = Mat.WoodPlanks,
		})
		for _, sz in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Pied",
				Size = Vector3.new(1.1, 1, 0.3),
				CFrame = CFrame.new(xBanc, Y + 0.5, zMil + 0.2 + sz * (LB / 2 - 0.4)),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
			})
		end
		local pied = Vector3.new(xp + DEMI - 1.3, Y, zN + 1.1)
		local oeil = pied + Vector3.new(0, 2.6, 0)
		local cible = Vector3.new(X_ROCHE, HAUT_CASCADE * 0.6, zCentre)
		for i = 1, 3 do
			local a = (i / 3) * 2 * math.pi
			local sol = pied + Vector3.new(0.6 * math.cos(a), 0, 0.6 * math.sin(a))
			poutre(m, "Trepied", sol, oeil - Vector3.new(0, 0.2, 0), 0.12, 0.12, POUTRE_OMBRE, Mat.Metal)
		end
		local vise = CFrame.lookAt(oeil, cible)
		cylindre(m, {
			Name = "LongueVue",
			Size = Vector3.new(1.8, 0.45, 0.45),
			CFrame = vise * CFrame.new(0, 0, -0.3) * CFrame.Angles(0, math.rad(90), 0),
			Color = hex("C9A227"),
			Material = Mat.Metal,
		})
		cylindre(m, {
			Name = "Objectif",
			Size = Vector3.new(0.3, 0.6, 0.6),
			CFrame = vise * CFrame.new(0, 0, -1.2) * CFrame.Angles(0, math.rad(90), 0),
			Color = hex("8C6A12"),
			Material = Mat.Metal,
		})
		cylindre(m, {
			Name = "Oculaire",
			Size = Vector3.new(0.35, 0.3, 0.3),
			CFrame = vise * CFrame.new(0, 0, 0.75) * CFrame.Angles(0, math.rad(90), 0),
			Color = POUTRE_OMBRE,
			Material = Mat.Metal,
		})

		-- fond, contre la falaise : panneau « BELVÉDÈRE » (face au pont) entre deux jardinières fleuries
		local zPanneau = z1 - 0.45
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "PoteauPanneau",
				Size = Vector3.new(0.4, 3.4, 0.4),
				CFrame = CFrame.new(xp + sx * 2.4, Y + 1.7, zPanneau),
				Color = POUTRE,
				Material = Mat.Wood,
			})
		end
		local planche = bloc(m, {
			Name = "Panneau",
			Size = Vector3.new(5.6, 1.5, 0.3),
			CFrame = CFrame.new(xp, Y + 2.7, zPanneau - 0.3),
			Color = BOIS,
			Material = Mat.WoodPlanks,
		})
		if planche then
			pcall(function()
				local etiquette = Outils.texte(planche, "Front", "BELVÉDÈRE", { couleur = ECUME })
				if ctx.Style and ctx.Style.contour then
					ctx.Style.contour(etiquette, 3)
				end
			end)
		end
		for _, sx in ipairs({ -1, 1 }) do
			local xj = xp + sx * (OUVERTURE - 0.2)
			local zj = z1 - 0.9
			bloc(m, {
				Name = "Jardiniere",
				Size = Vector3.new(1.4, 0.8, 1.1),
				CFrame = CFrame.new(xj, Y + 0.4, zj),
				Color = POUTRE,
				Material = Mat.WoodPlanks,
			})
			boule(m, decor({
				Name = "Feuillage",
				Size = Vector3.new(1.5, 1.1, 1.2),
				CFrame = CFrame.new(xj, Y + 1.1, zj),
				Color = FEUILLE,
				Material = Mat.LeafyGrass,
			}))
			boule(m, decor({
				Name = "Fleurs",
				Size = Vector3.new(0.6, 0.6, 0.6),
				CFrame = CFrame.new(xj + 0.3 * sx, Y + 1.55, zj - 0.2),
				Color = FLEURS[rng:NextInteger(1, #FLEURS)],
				Material = Mat.SmoothPlastic,
			}))
		end
	end

	-- ===== 4 ter. pontons de pêche au bout des autres allées (rive nord, jusqu'au milieu du courant) =====
	local function construirePonton(index, p)
		local xp = p.x
		local zp, r, h = lit(xp)
		local z0 = zp - h - 1.5    -- sur l'herbe de la rive nord
		local z1 = zp - 0.4        -- s'arrête au milieu du courant : pas de traversée
		local L = z1 - z0
		local demi = p.largeur / 2
		local Y = 0.35             -- dessus du platelage
		local m = Outils.modele(dPonts, "Ponton" .. index)
		-- planches en travers, légèrement irrégulières
		local n = math.max(3, math.floor(L / 0.9 + 0.5))
		local d = L / n
		for k = 1, n do
			local couleur = BOIS
			if k % 2 == 0 then
				couleur = BOIS_CLAIR
			end
			bloc(m, {
				Name = "Planche",
				Size = Vector3.new(p.largeur + rng:NextNumber(-0.2, 0.2), 0.4, d - 0.08),
				CFrame = CFrame.new(xp + rng:NextNumber(-0.08, 0.08), Y - 0.2, z0 + (k - 0.5) * d)
					* CFrame.Angles(0, math.rad(rng:NextNumber(-1.5, 1.5)), 0),
				Color = couleur,
				Material = Mat.WoodPlanks,
				CanTouch = false,
			})
		end
		-- longerons et pilotis ; les deux pilotis du bout dépassent (bittes d'amarrage), l'un porte la lanterne
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Longeron",
				Size = Vector3.new(0.4, 0.4, L),
				CFrame = CFrame.new(xp + sx * (demi - 0.4), Y - 0.6, (z0 + z1) / 2),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
			})
			local fond = -PROF - 0.5
			local zMilieu = z0 + L * 0.55
			bloc(m, {
				Name = "Pilotis",
				Size = Vector3.new(0.6, Y - 0.4 - fond, 0.6),
				CFrame = CFrame.new(xp + sx * (demi - 0.3), (Y - 0.4 + fond) / 2, zMilieu),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
				CanTouch = false,
			})
			local lanterne = (sx > 0) == (xp > 0)
			if lanterne then
				poteauLanterne(m, xp + sx * (demi - 0.3), z1 - 0.3, fond, Y + 2.8)
			else
				bloc(m, {
					Name = "Bitte",
					Size = Vector3.new(0.7, Y + 0.8 - fond, 0.7),
					CFrame = CFrame.new(xp + sx * (demi - 0.3), (Y + 0.8 + fond) / 2, z1 - 0.3),
					Color = POUTRE_OMBRE,
					Material = Mat.Wood,
				})
			end
		end
		-- canne à pêche calée dans un seau, fil et bouchon qui dansent sur l'eau
		local cote = 1
		if xp > 0 then
			cote = -1
		end
		local seau = Vector3.new(xp + cote * (demi - 0.7), Y, z1 - 1.4)
		cylindre(m, decor({
			Name = "Seau",
			Size = Vector3.new(0.8, 0.7, 0.7),
			CFrame = CFrame.new(seau + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = hex("6E8FA6"),
			Material = Mat.Metal,
		}))
		local bout = Vector3.new(xp + cote * 0.3, Y + 3.1, z1 + 2.2)
		poutre(m, "Canne", seau + Vector3.new(0, 0.6, 0), bout, 0.12, 0.12, POUTRE, Mat.Wood)
		local surface = Vector3.new(bout.X, Y_EAU + 0.1, bout.Z)
		poutre(m, "Fil", bout, surface, 0.04, 0.04, ECUME, Mat.SmoothPlastic)
		local bouchon = boule(m, decor({
			Name = "Bouchon",
			Size = Vector3.new(0.35, 0.35, 0.35),
			CFrame = CFrame.new(surface),
			Color = hex("FF4D4D"),
			Material = Mat.SmoothPlastic,
		}))
		if bouchon then
			Outils.animer(bouchon, "flotte", 1.3)
		end
		-- barque amarrée le long du ponton, qui se balance doucement
		if reste() > 12 then
			local bx = xp - cote * (demi + 1.4)
			local bz = zp - 1
			local LB, lB = 4.4, 1.8
			local barque = Outils.modele(m, "Barque")
			local fondB = Y_EAU - 0.35
			bloc(barque, {
				Name = "Coque",
				Size = Vector3.new(lB - 0.4, 0.3, LB - 0.6),
				CFrame = CFrame.new(bx, fondB, bz),
				Color = POUTRE,
				Material = Mat.WoodPlanks,
			})
			for _, sx in ipairs({ -1, 1 }) do
				bloc(barque, {
					Name = "Bordage",
					Size = Vector3.new(0.25, 0.8, LB),
					CFrame = CFrame.new(bx + sx * (lB / 2 - 0.12), fondB + 0.3, bz) * CFrame.Angles(0, 0, math.rad(-12 * sx)),
					Color = BOIS,
					Material = Mat.WoodPlanks,
				})
			end
			for _, sz in ipairs({ -1, 1 }) do
				bloc(barque, {
					Name = "Tableau",
					Size = Vector3.new(lB - 0.3, 0.7, 0.25),
					CFrame = CFrame.new(bx, fondB + 0.3, bz + sz * (LB / 2 - 0.12)),
					Color = BOIS_CLAIR,
					Material = Mat.WoodPlanks,
				})
			end
			bloc(barque, {
				Name = "Banc",
				Size = Vector3.new(lB - 0.4, 0.15, 0.6),
				CFrame = CFrame.new(bx, fondB + 0.5, bz + 0.3),
				Color = BOIS_CLAIR,
				Material = Mat.WoodPlanks,
			})
			bloc(barque, {
				Name = "Rame",
				Size = Vector3.new(0.18, 0.1, 3.2),
				CFrame = CFrame.new(bx + 0.2, fondB + 0.7, bz - 0.4) * CFrame.Angles(0, math.rad(12), math.rad(8)),
				Color = POUTRE_OMBRE,
				Material = Mat.Wood,
			})
			for _, inst in ipairs(barque:GetDescendants()) do
				if inst:IsA("BasePart") then
					inst.CanCollide = false
					inst.CanTouch = false
				end
			end
			Outils.animer(barque, "flotte", 0.4)
			occuper(bx, bz, 2.6)
		end
		occuper(xp, (z0 + z1) / 2, demi + 1.5)
	end

	local function construirePontons()
		for index, p in ipairs(pontons) do
			if p.x - p.largeur / 2 > X_MIN + 10 and p.x + p.largeur / 2 < X_ROCHE - 14 then
				construirePonton(index, p)
			end
		end
	end

	-- ===== 5. cascade à deux étages, sortie d'une gorge taillée dans la falaise est =====
	local function construireCascade()
		local m = Outils.modele(dossier, "Cascade")
		local H = HAUT_CASCADE
		local W = LARGEUR_CHUTE
		local H2 = H + HAUT_ETAGE
		-- le contrefort de roche en avant de la falaise, dessus d'herbe sur les épaules
		tBornes(X_ROCHE, X_GORGE_FIN + 2, -1, H, zCentre - LARGEUR / 2 - 1, zCentre + LARGEUR / 2 + 1, Mat.Rock)
		tBornes(X_ROCHE + 0.5, XF + 4, H - 0.8, H, zCentre - LARGEUR / 2 - 1, zCentre + LARGEUR / 2 + 1, Mat.Grass)
		-- l'étage haut : un gradin de roche au fond de la gorge
		tBornes(X_GORGE, X_GORGE_FIN + 2, H - 1, H2, zCentre - W / 2 - 3, zCentre + W / 2 + 3, Mat.Rock)
		-- la gorge : on ouvre la falaise au-dessus du lit de chaque étage (parois de roche de part et d'autre)
		tBornes(X_ROCHE + 2.4, X_GORGE, H, H + 45, zCentre - W / 2 - 1, zCentre + W / 2 + 1, Mat.Air)
		tBornes(X_GORGE, X_GORGE_FIN, H2, H2 + 45, zCentre - W / 2, zCentre + W / 2, Mat.Air)
		-- fond d'ardoise des deux lits
		tBornes(X_ROCHE + 2.4, X_GORGE, H - 0.8, H, zCentre - W / 2 - 1, zCentre + W / 2 + 1, Mat.Slate)
		tBornes(X_GORGE, X_GORGE_FIN, H2 - 0.8, H2, zCentre - W / 2, zCentre + W / 2, Mat.Slate)
		-- la source : l'eau sort de sous un amas de roches au fond de la gorge haute
		tBoule(Vector3.new(X_GORGE_FIN + 1, H2 + 1.2, zCentre - 1.8), 2.4, Mat.Slate)
		tBoule(Vector3.new(X_GORGE_FIN + 1.5, H2 + 1.4, zCentre + 2), 2.5, Mat.Rock)
		tBoule(Vector3.new(X_GORGE_FIN + 2.5, H2 + 3.8, zCentre), 3, Mat.Rock)
		-- blocs arrondis sur les bords : la gorge n'est pas taillée au couteau
		for _, sz in ipairs({ -1, 1 }) do
			local zb = zCentre + sz * (W / 2 + 2.4)
			tBoule(Vector3.new(X_ROCHE + 0.2, 1.5, zb), 3, Mat.Slate)
			tBoule(Vector3.new(X_ROCHE + 0.6, 6, zb + sz * 0.6), 2.8, Mat.Rock)
			tBoule(Vector3.new(X_ROCHE + 0.9, H - 4, zb), 2.6, Mat.Slate)
			tBoule(Vector3.new(X_ROCHE + 1.5, H + 0.5, zb + sz * 0.8), 2.2, Mat.Rock)
			tBoule(Vector3.new((X_ROCHE + X_GORGE) / 2 + 2, H + 1.2, zCentre + sz * (W / 2 + 2)), 1.9, Mat.Slate)
			tBoule(Vector3.new(X_GORGE + 0.5, H2 + 0.8, zCentre + sz * (W / 2 + 1.4)), 1.8, Mat.Rock)
			-- rochers au pied, à moitié dans le bassin
			tBoule(Vector3.new(X_ROCHE - 5.5, -0.9, zCentre + sz * (W / 2 + 0.6)), 1.8, Mat.Slate)
		end

		-- l'étage haut : ruisseau qui sort du fond de la gorge et petite chute sur le gradin
		local wHaut = math.max(3, W - 2.5)
		bloc(m, decor({
			Name = "RuisseauHaut",
			Size = Vector3.new(X_GORGE_FIN - X_GORGE, 0.3, wHaut),
			CFrame = CFrame.new((X_GORGE + X_GORGE_FIN) / 2, H2 + 0.15, zCentre),
			Color = EAU,
			Material = Mat.Glass,
			Transparency = 0.25,
			CastShadow = false,
		}))
		local levreHaute = cylindre(m, {
			Name = "LevreHaute",
			Size = Vector3.new(wHaut + 1.4, 0.9, 0.9),
			CFrame = CFrame.new(X_GORGE - 0.2, H2 - 0.1, zCentre) * CFrame.Angles(0, math.rad(90), 0),
			Color = ROCHE_LEVRE,
			Material = Mat.Slate,
		})
		local chuteHaute = bloc(m, decor({
			Name = "ChuteHaute",
			Size = Vector3.new(0.6, HAUT_ETAGE, wHaut),
			CFrame = CFrame.new(X_GORGE - 0.95, H + HAUT_ETAGE / 2, zCentre),
			Color = CHUTE,
			Material = Mat.Glass,
			Transparency = 0.16,
			CastShadow = false,
		}))
		if chuteHaute then
			Outils.animer(chuteHaute, "pulse", 1.8)
		end
		-- le lit bas : ruisseau du pied de la chute haute jusqu'au rebord
		local ruisseau = bloc(m, decor({
			Name = "Ruisseau",
			Size = Vector3.new(X_GORGE - X_ROCHE - 0.6, 0.3, W - 0.6),
			CFrame = CFrame.new((X_ROCHE + 0.6 + X_GORGE) / 2, H + 0.15, zCentre),
			Color = EAU,
			Material = Mat.Glass,
			Transparency = 0.25,
			CastShadow = false,
		}))
		if ruisseau then
			-- bouillons au pied de la chute haute
			emetteur(ruisseau, "Bouillons", {
				Color = ColorSequence.new(ECUME),
				LightEmission = 0.3,
				Size = fondu(0.8, 2.2),
				Transparency = fondu(0.3, 1),
				Lifetime = NumberRange.new(0.6, 1.2),
				Rate = 8,
				Speed = NumberRange.new(1.5, 3),
				SpreadAngle = Vector2.new(35, 35),
				Acceleration = Vector3.new(0, -6, 0),
				EmissionDirection = Enum.NormalId.Top,
			})
		end
		if levreHaute then
			emetteur(levreHaute, "Gouttes", {
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new(EAU_CLAIRE),
				LightEmission = 0.4,
				Size = NumberSequence.new(0.22),
				Transparency = fondu(0.2, 1),
				Lifetime = NumberRange.new(0.6, 1),
				Rate = 6,
				Speed = NumberRange.new(1, 2.5),
				SpreadAngle = Vector2.new(20, 40),
				Acceleration = Vector3.new(0, -30, 0),
				EmissionDirection = Enum.NormalId.Left,
			})
		end

		-- le rebord de pierre d'où tombe la grande chute
		local xLevre = X_ROCHE - 0.9
		bloc(m, {
			Name = "Levre",
			Size = Vector3.new(2.4, 1, W + 1.6),
			CFrame = CFrame.new(X_ROCHE + 0.3, H - 0.1, zCentre),
			Color = ROCHE_LEVRE,
			Material = Mat.Slate,
		})
		cylindre(m, {
			Name = "LevreArrondie",
			Size = Vector3.new(W + 1.6, 1, 1),
			CFrame = CFrame.new(xLevre, H - 0.1, zCentre) * CFrame.Angles(0, math.rad(90), 0),
			Color = ROCHE_LEVRE,
			Material = Mat.Slate,
		})
		-- l'eau qui passe le rebord en s'arrondissant, puis le rideau
		local courbe = bloc(m, decor({
			Name = "Courbe",
			Size = Vector3.new(0.7, 2.4, W),
			CFrame = CFrame.new(xLevre - 0.55, H - 0.6, zCentre) * CFrame.Angles(0, 0, math.rad(-28)),
			Color = CHUTE,
			Material = Mat.Glass,
			Transparency = 0.12,
			CastShadow = false,
		}))
		local xRideau = xLevre - 1.15
		local hautRideau = H - 1.8 -- le rideau descend jusqu'à la surface du bassin (Y_EAU)
		local hRideau = hautRideau - Y_EAU
		bloc(m, decor({
			Name = "Chute",
			Size = Vector3.new(0.7, hRideau, W),
			CFrame = CFrame.new(xRideau, (hautRideau + Y_EAU) / 2, zCentre),
			Color = CHUTE,
			Material = Mat.Glass,
			Transparency = 0.14,
			CastShadow = false,
		}))
		-- filets blancs devant le rideau : l'eau qui file
		local nFilets = 6
		for k = 1, nFilets do
			local z = zCentre - W / 2 + 0.5 + (W - 1) * (k - 0.5) / nFilets + rng:NextNumber(-0.25, 0.25)
			local long = hRideau * rng:NextNumber(0.55, 1)
			local filet = bloc(m, decor({
				Name = "Filet",
				Size = Vector3.new(0.25, long, rng:NextNumber(0.35, 0.6)),
				CFrame = CFrame.new(xRideau - 0.45, hautRideau - long / 2, z),
				Color = ECUME,
				Material = Mat.SmoothPlastic,
				Transparency = 0,
				CastShadow = false,
			}))
			if filet and k % 2 == 1 then
				Outils.animer(filet, "pulse", rng:NextNumber(1.5, 2.5))
			end
		end
		-- écume au pied : anneaux et bouillons blancs
		local xPied = xRideau - 1.2
		local ecume = cylindre(m, decor({
			Name = "Ecume",
			Size = Vector3.new(0.3, W + 1.2, W + 1.2),
			CFrame = CFrame.new(xPied, Y_EAU + 0.12, zCentre) * CFrame.Angles(0, 0, math.rad(90)),
			Color = ECUME,
			Material = Mat.SmoothPlastic,
			Transparency = 0,
			CastShadow = false,
		}))
		if ecume then
			Outils.animer(ecume, "pulse", 2)
		end
		local anneau = cylindre(m, decor({
			Name = "Remous",
			Size = Vector3.new(0.2, W + 5, W + 5),
			CFrame = CFrame.new(xPied - 1, Y_EAU + 0.04, zCentre) * CFrame.Angles(0, 0, math.rad(90)),
			Color = EAU_CLAIRE,
			Material = Mat.SmoothPlastic,
			Transparency = 0.55,
			CastShadow = false,
		}))
		if anneau then
			Outils.animer(anneau, "pulse", 1.2)
		end
		for k = 1, 4 do
			local d = rng:NextNumber(1.2, 2)
			local bouillon = boule(m, decor({
				Name = "Bouillon",
				Size = Vector3.new(d, d, d),
				CFrame = CFrame.new(xPied + rng:NextNumber(-1, 0.6), Y_EAU + d * 0.3, zCentre - W / 2 + (k - 0.5) * W / 4),
				Color = ECUME,
				Material = Mat.SmoothPlastic,
				Transparency = 0,
				CastShadow = false,
			}))
			if bouillon then
				Outils.animer(bouillon, "flotte", rng:NextNumber(1.5, 3))
			end
		end

		-- particules : écume qui gicle, embruns, gouttes au rebord
		if ecume then
			emetteur(ecume, "Ecume", {
				Color = ColorSequence.new(ECUME),
				LightEmission = 0.3,
				Size = fondu(1.2, 3.2),
				Transparency = fondu(0.25, 1),
				Lifetime = NumberRange.new(0.8, 1.6),
				Rate = 30,
				Speed = NumberRange.new(4, 8),
				SpreadAngle = Vector2.new(40, 60),
				Acceleration = Vector3.new(0, -9, 0),
				EmissionDirection = Enum.NormalId.Right,
			})
			emetteur(ecume, "Embruns", {
				Color = ColorSequence.new(EAU_CLAIRE),
				LightEmission = 0.2,
				Size = fondu(2.5, 7),
				Transparency = apparaitFond(1, 0.6, 1),
				Lifetime = NumberRange.new(1.8, 3),
				Rate = 9,
				Speed = NumberRange.new(1.5, 3),
				SpreadAngle = Vector2.new(70, 70),
				Acceleration = Vector3.new(-0.6, 0.4, 0),
				EmissionDirection = Enum.NormalId.Right,
			})
			pcall(function()
				Outils.lumiere(ecume, { Range = 16, Brightness = 0.7, Color = EAU_CLAIRE })
			end)
		end
		if courbe then
			emetteur(courbe, "Gouttes", {
				Texture = "rbxasset://textures/particles/sparkles_main.dds",
				Color = ColorSequence.new(EAU_CLAIRE),
				LightEmission = 0.4,
				Size = NumberSequence.new(0.25),
				Transparency = fondu(0.2, 1),
				Lifetime = NumberRange.new(1, 1.6),
				Rate = 12,
				Speed = NumberRange.new(1, 3),
				SpreadAngle = Vector2.new(20, 40),
				Acceleration = Vector3.new(0, -30, 0),
				EmissionDirection = Enum.NormalId.Left,
			})
		end

		-- arc-en-ciel dans les embruns : six Beams courbés, accrochés à une part invisible (aucune part de plus à l'écran)
		local ancre = bloc(dEffets, decor({
			Name = "ArcEnCiel",
			Size = Vector3.new(0.2, 0.2, 0.2),
			CFrame = CFrame.new(xPied - 2.5, Y_EAU + 0.6, zCentre),
			Transparency = 1,
			CastShadow = false,
		}))
		if ancre then
			pcall(function()
				local demiArc = W / 2 + 3
				for i, couleur in ipairs(ARC) do
					local e = (i - 1) * 0.42
					-- l'axe X des attaches pointe vers le haut : les courbes du Beam montent
					local a0 = Instance.new("Attachment")
					a0.Name = "ArcA" .. i
					a0.CFrame = CFrame.new(0, 0, -demiArc - e) * CFrame.Angles(0, 0, math.rad(90))
					a0.Parent = ancre
					local a1 = Instance.new("Attachment")
					a1.Name = "ArcB" .. i
					a1.CFrame = CFrame.new(0, 0, demiArc + e) * CFrame.Angles(0, 0, math.rad(90))
					a1.Parent = ancre
					local b = Instance.new("Beam")
					b.Name = "Bande" .. i
					b.Attachment0 = a0
					b.Attachment1 = a1
					b.Color = ColorSequence.new(couleur)
					b.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.25, 0.72),
						NumberSequenceKeypoint.new(0.75, 0.72),
						NumberSequenceKeypoint.new(1, 1),
					})
					b.LightEmission = 0.6
					b.FaceCamera = true
					b.Segments = 24
					b.Width0 = 0.45
					b.Width1 = 0.45
					b.CurveSize0 = 9 + e * 1.3
					b.CurveSize1 = -(9 + e * 1.3)
					b.Parent = ancre
				end
			end)
		end
		occuper(xPied, zCentre, 7)
	end

	-- ===== 6. le courant : reflets, flocons d'écume qui descendent vers l'ouest, ronds dans l'eau, lucioles =====
	local function construireCourant()
		local LONG = 44
		local x0 = X_MIN + 6
		local x1 = X_ROCHE - 8
		local n = math.max(1, math.floor((x1 - x0) / LONG + 0.5))
		local pas = (x1 - x0) / n
		for i = 1, n do
			if reste() <= 40 then
				return
			end
			local xa = x0 + (i - 1) * pas
			local xb = xa + pas
			local za, zb = zc(xa), zc(xb)
			local _, rMilieu = lit((xa + xb) / 2)
			local a = Vector3.new(xa, Y_EAU + 0.15, za)
			local b = Vector3.new(xb, Y_EAU + 0.15, zb)
			-- part invisible couchée sur l'eau, le long du courant (Z local = sens du tracé)
			local nappe = bloc(dEffets, decor({
				Name = "Courant" .. i,
				Size = Vector3.new(math.max(1.5, rMilieu * 1.3), 0.2, (b - a).Magnitude),
				CFrame = CFrame.lookAt((a + b) / 2, a),
				Transparency = 1,
				CastShadow = false,
			}))
			if nappe then
				emetteur(nappe, "Reflets", {
					Texture = "rbxasset://textures/particles/sparkles_main.dds",
					Color = ColorSequence.new(EAU_CLAIRE),
					LightEmission = 1,
					Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.5, 0.45),
						NumberSequenceKeypoint.new(1, 0),
					}),
					Lifetime = NumberRange.new(0.6, 1.2),
					Rate = 4,
					Speed = NumberRange.new(0),
				})
				-- l'eau coule vers l'ouest (de la cascade vers la perte) : -Z local de la nappe
				emetteur(nappe, "Flocons", {
					Color = ColorSequence.new(ECUME),
					LightEmission = 0.1,
					Size = fondu(0.35, 0.6),
					Transparency = apparaitFond(1, 0.35, 1),
					Lifetime = NumberRange.new(4, 6),
					Rate = 1.6,
					Speed = NumberRange.new(2, 3.2),
					SpreadAngle = Vector2.new(4, 4),
					EmissionDirection = Enum.NormalId.Front,
				})
				-- ronds dans l'eau (poissons, gouttes) : taches à plat qui s'élargissent, de temps en temps
				emetteur(nappe, "Ronds", {
					Color = ColorSequence.new(EAU_CLAIRE),
					LightEmission = 0.15,
					Size = fondu(0.3, 3),
					Transparency = fondu(0.45, 1),
					Lifetime = NumberRange.new(1.2, 1.8),
					Rate = 0.35,
					Speed = NumberRange.new(0.01),
					EmissionDirection = Enum.NormalId.Top,
					Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
				})
				-- lucioles au-dessus de l'eau, une nappe sur deux
				if i % 2 == 1 then
					emetteur(nappe, "Lucioles", {
						Texture = "rbxasset://textures/particles/sparkles_main.dds",
						Color = ColorSequence.new(LUCIOLE),
						LightEmission = 1,
						Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.2, 0.35),
							NumberSequenceKeypoint.new(0.8, 0.35),
							NumberSequenceKeypoint.new(1, 0),
						}),
						Lifetime = NumberRange.new(4, 7),
						Rate = 0.8,
						Speed = NumberRange.new(0.4, 1),
						SpreadAngle = Vector2.new(60, 60),
						Acceleration = Vector3.new(0, 0.12, 0),
						EmissionDirection = Enum.NormalId.Top,
					})
				end
			end
		end
	end

	-- ===== 7. libellules qui tournent au-dessus de l'eau (le modèle tourne autour de son axe invisible) =====
	local function construireLibellules()
		local n = math.max(0, math.floor(reglage("libellules", 5)))
		local essais = 0
		local poses = 0
		while poses < n and essais < n * 10 and reste() > 50 do
			essais = essais + 1
			local x = rng:NextNumber(X_MIN + 15, X_ROCHE - 20)
			local z = zc(x)
			if not surPont(x, 6) then
				local rayon = rng:NextNumber(2.2, 3.8)
				local y = Y_EAU + rng:NextNumber(1.4, 2.6)
				local groupe = Outils.modele(dVegetation, "Libellule")
				local axe = bloc(groupe, decor({
					Name = "Axe",
					Size = Vector3.new(0.2, 0.2, 0.2),
					CFrame = CFrame.new(x, y, z),
					Transparency = 1,
					CastShadow = false,
				}))
				if axe then
					groupe.PrimaryPart = axe
					local couleur = LIBELLULES[rng:NextInteger(1, #LIBELLULES)]
					local cfCorps = CFrame.new(x + rayon, y, z)
					bloc(groupe, decor({
						Name = "Corps",
						Size = Vector3.new(0.22, 0.22, 1.5),
						CFrame = cfCorps,
						Color = couleur,
						Material = Mat.SmoothPlastic,
					}))
					boule(groupe, decor({
						Name = "Tete",
						Size = Vector3.new(0.38, 0.38, 0.38),
						CFrame = cfCorps * CFrame.new(0, 0.02, -0.8),
						Color = Charte.ombre(couleur),
						Material = Mat.SmoothPlastic,
					}))
					local aile = bloc(groupe, decor({
						Name = "Ailes",
						Size = Vector3.new(1.9, 0.05, 0.36),
						CFrame = cfCorps * CFrame.new(0, 0.12, -0.3),
						Color = AILE,
						Material = Mat.Glass,
						Transparency = 0.35,
						CastShadow = false,
					}))
					if aile then
						Outils.animer(aile, "pulse", rng:NextNumber(9, 13))
					end
					-- sens et vitesse de ronde propres à chaque libellule
					Outils.animer(groupe, "tourne", rng:NextNumber(0.9, 1.6))
					occuper(x, z, 1)
					poses = poses + 1
				else
					groupe:Destroy()
				end
			end
		end
	end

	-- ===== 8. nénuphars =====
	local function construireNenuphars()
		local n = math.max(0, math.floor(reglage("nenuphars", 13)))
		local essais = 0
		local poses = 0
		while poses < n and essais < n * 10 and reste() > 70 do
			essais = essais + 1
			local d = rng:NextNumber(1.6, 2.6)
			local x = rng:NextNumber(X_MIN + 8, X_ROCHE - 14)
			local zl, rl = lit(x)
			local marge = math.max(0, rl - 1 - d / 2)
			local z = zl + rng:NextNumber(-marge, marge)
			if marge > 0.3 and libre(x, z, d / 2 + 0.3) then
				local groupe = Outils.modele(dVegetation, "Nenuphar")
				local feuille = cylindre(groupe, decor({
					Name = "Feuille",
					Size = Vector3.new(0.12, d, d),
					CFrame = CFrame.new(x, Y_EAU + 0.08, z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), math.rad(90)),
					Color = FEUILLE,
					Material = Mat.LeafyGrass,
				}))
				if feuille then
					groupe.PrimaryPart = feuille
					if rng:NextNumber() < 0.55 then
						boule(groupe, decor({
							Name = "Fleur",
							Size = Vector3.new(0.6, 0.6, 0.6),
							CFrame = CFrame.new(x + rng:NextNumber(-0.3, 0.3), Y_EAU + 0.33, z + rng:NextNumber(-0.3, 0.3)),
							Color = FLEURS[rng:NextInteger(1, #FLEURS)],
							Material = Mat.SmoothPlastic,
						}))
					else
						cylindre(groupe, decor({
							Name = "Petite",
							Size = Vector3.new(0.12, d * 0.5, d * 0.5),
							CFrame = CFrame.new(x + d * 0.55, Y_EAU + 0.06, z + d * 0.2) * CFrame.Angles(0, 0, math.rad(90)),
							Color = FEUILLE_OMBRE,
							Material = Mat.LeafyGrass,
						}))
					end
					-- une feuille sur deux dérive doucement sur elle-même, les autres dansent sur les vaguelettes
					if rng:NextNumber() < 0.5 then
						Outils.animer(groupe, "tourne", rng:NextNumber(0.05, 0.12))
					else
						Outils.animer(groupe, "flotte", rng:NextNumber(0.5, 0.9))
					end
					occuper(x, z, d / 2 + 0.3)
					poses = poses + 1
				else
					groupe:Destroy()
				end
			end
		end
	end

	-- ===== 9. roseaux au bord de l'eau (touffes de tiges et massettes) =====
	local function construireRoseaux()
		local n = math.max(0, math.floor(reglage("roseaux", 10)))
		local essais = 0
		local poses = 0
		while poses < n and essais < n * 10 and reste() > 60 do
			essais = essais + 1
			local x = rng:NextNumber(X_MIN + 8, X_ROCHE - 14)
			-- au bord de l'eau, là où la berge de sable plonge sous la surface
			local zl, rl = lit(x)
			local s = 1
			if rng:NextInteger(1, 2) == 1 then
				s = -1
			end
			local z = zl + s * (rl + rng:NextNumber(-0.3, 1.2))
			if libre(x, z, 1.2) then
				local touffe = Outils.modele(dVegetation, "Roseaux")
				for k = 1, 4 do
					local pz = z + rng:NextNumber(-0.5, 0.5)
					local px = x + rng:NextNumber(-0.7, 0.7)
					-- la tige part du sable de la berge, qui descend vers le milieu
					local fond = ySol(px, pz - zc(px)) - 0.2
					local h = rng:NextNumber(2.4, 3.6) - fond
					local penche = CFrame.Angles(math.rad(rng:NextNumber(-10, 10)), 0, math.rad(rng:NextNumber(-10, 10)))
					local couleur = TIGE
					if k % 2 == 0 then
						couleur = TIGE_OMBRE
					end
					local base = CFrame.new(px, fond, pz) * penche
					bloc(touffe, decor({
						Name = "Tige",
						Size = Vector3.new(0.14, h, 0.14),
						CFrame = base * CFrame.new(0, h / 2, 0),
						Color = couleur,
						Material = Mat.Grass,
					}))
					if k <= 2 then
						cylindre(touffe, decor({
							Name = "Massette",
							Size = Vector3.new(0.8, 0.3, 0.3),
							CFrame = base * CFrame.new(0, h - 0.3, 0) * CFrame.Angles(0, 0, math.rad(90)),
							Color = MASSETTE,
							Material = Mat.Fabric,
						}))
					end
				end
				occuper(x, z, 1.2)
				poses = poses + 1
			end
		end
	end

	-- ===== 10. galets Slate arrondis sur les berges, en petits groupes =====
	local function semerGalets(nombre)
		local poses = 0
		local essais = 0
		while poses < nombre and essais < nombre * 4 and reste() > 0 do
			essais = essais + 1
			local x = rng:NextNumber(X_MIN + 6, X_ROCHE - 10)
			local zl, rl = lit(x)
			local s = 1
			if rng:NextInteger(1, 2) == 1 then
				s = -1
			end
			-- sur la pente de sable, entre le bord de l'eau et l'herbe
			local z = zl + s * (rl + rng:NextNumber(0.2, 2))
			if not surPont(x, 1) then
				local tas = rng:NextInteger(2, 4)
				for _ = 1, tas do
					if poses >= nombre or reste() <= 0 then
						return
					end
					local d = rng:NextNumber(0.45, 1.1)
					local gx = x + rng:NextNumber(-1, 1)
					local gz = math.clamp(z + rng:NextNumber(-0.5, 0.5), Z_LIBRE_MIN + d / 2, Z_LIBRE_MAX - d / 2)
					-- posé sur la berge qui descend vers l'eau, à moitié enfoncé dans le sable
					local y = ySol(gx, gz - zc(gx)) + d * 0.15
					boule(dBerges, decor({
						Name = "Galet",
						Size = Vector3.new(d, d, d),
						CFrame = CFrame.new(gx, y, gz),
						Color = GALETS[rng:NextInteger(1, #GALETS)],
						Material = Mat.Slate,
					}))
					poses = poses + 1
				end
			end
		end
	end

	-- ===== ordre : terrain et grandes pièces d'abord, le décor fin selon le budget restant =====
	local etapes = {
		{ "eau", construireEau },
		{ "berges", construireBerges },
		{ "cascade", construireCascade },
		{ "ponts", construirePonts },
		{ "belvedere", construireBelvedere },
		{ "pontons", construirePontons },
		{ "rochers", construireRochers },
		{ "courant", construireCourant },
		{ "libellules", construireLibellules },
		{ "nenuphars", construireNenuphars },
		{ "roseaux", construireRoseaux },
		{ "galets", function() semerGalets(math.max(0, reste())) end },
	}
	for _, etape in ipairs(etapes) do
		local ok, err = pcall(etape[2])
		if not ok then
			warn("[Dino] Riviere, " .. etape[1] .. " : " .. tostring(err))
		end
	end
	dossier:SetAttribute("Parts", compte)
end

return M
