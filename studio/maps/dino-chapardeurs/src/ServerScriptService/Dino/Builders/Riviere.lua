-- Constructeur Riviere (version 2, STYLE.md §4) : rivière d'ouest en est au sud de la Place.
-- Lit SINUEUX creusé dans le terrain : axe zc(x) = 138 + 3,5 sin(x/37) + 1,5 sin(x/13) (dans 131..145),
-- tracé par pas de 4 studs (cylindres Air pour creuser, Sand pour le fond, Water jusqu'à Y = -0,8 :
-- la surface est 0,8 stud sous l'herbe), berges en pente de sable (0 -> -1,5) avec un peu de boue,
-- rochers de terrain Slate/Rock, galets Slate arrondis, roseaux et nénuphars ; deux ponts de bois
-- en arc (planches WoodPlanks, rambardes et poteaux Wood, lanternes) ; une cascade en parts Glass
-- blanc-bleu qui sort des falaises de l'est, avec écume, embruns et gouttes (ParticleEmitter).
-- Emprise (CONTRAT §10) : bande z 131..145 sur x -166..166 (+ la roche de la cascade adossée aux falaises) ;
-- seules les berges de terrain débordent un peu dans les boucles, sans jamais sortir du couloir libre z 129..149.
local M = {}

local BUDGET = 250 -- parts au maximum pour ce constructeur (le terrain ne compte pas)

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

	-- ===== géométrie =====
	local zCentre = 138
	local largeur = 14
	if Plan and type(Plan.riviere) == "table" then
		if type(Plan.riviere.z) == "number" then
			zCentre = Plan.riviere.z
		end
		if type(Plan.riviere.largeur) == "number" then
			largeur = Plan.riviere.largeur
		end
	end
	-- on reste dans l'emprise du contrat quoi qu'il arrive
	local Z_MIN = math.max(131, zCentre - largeur / 2)
	local Z_MAX = math.min(145, zCentre + largeur / 2)
	if Z_MAX - Z_MIN < 8 then
		Z_MIN = 131
		Z_MAX = 145
	end
	zCentre = (Z_MIN + Z_MAX) / 2
	local LARGEUR = Z_MAX - Z_MIN
	local X_MIN = -166
	local X_MAX = 166

	local PROF = 4                -- profondeur de l'eau (dessus du sol à Y = 0)
	local X_ROCHE = 164           -- face ouest de la roche de la cascade
	local HAUT_CASCADE = math.min(20, math.max(10, reglage("hauteurCascade", 16)))
	local LARGEUR_CHUTE = math.min(7, LARGEUR - 5)

	local X_PONTS = { reglage("pontOuest", -92), reglage("pontEst", 92) }
	local LARGEUR_PONT = 6
	local ARC_PONT = 1.8

	local rng = Outils.aleatoire(reglage("graine", 1138))

	-- ===== tracé sinueux =====
	local PAS = 4                 -- pas du tracé sur x (grille du terrain)
	local Y_EAU = -0.8            -- surface de l'eau : 0,8 stud sous les berges (herbe à Y = 0)
	local LARGE_BERGE = 3.6       -- largeur de la pente de sable d'une berge
	local HAUT_BERGE = 1.5        -- la berge descend de 0 à -1,5
	-- couloir libre entre la Jungle (z <= 128) et le bord sud du monde (z = 150)
	local Z_LIBRE_MIN, Z_LIBRE_MAX = 129, 149
	-- axe du lit ; il rejoint le milieu de la bande devant la cascade (bassin centré)
	local function zc(x)
		local z = zCentre + 3.5 * math.sin(x / 37) + 1.5 * math.sin(x / 13)
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

	-- zones à ne pas encombrer (ponts, cascade) pour les petits objets
	local function surPont(x, marge)
		for _, xp in ipairs(X_PONTS) do
			if math.abs(x - xp) <= LARGEUR_PONT / 2 + marge then
				return true
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

	local dBerges = Outils.dossier(dossier, "Berges")
	local dVegetation = Outils.dossier(dossier, "Vegetation")
	local dPonts = Outils.dossier(dossier, "Ponts")

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
		local x = X_MIN + PAS
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
		-- la source à l'ouest : un amas de roches d'où sort la rivière
		local zs, _, hs = lit(X_MIN + PAS)
		tBoule(Vector3.new(X_MIN + 1, 0.5, zs - hs + 1.5), 3.2, Mat.Rock)
		tBoule(Vector3.new(X_MIN + 1, 0.8, zs + hs - 1.5), 3.4, Mat.Slate)
		tBoule(Vector3.new(X_MIN + 0.5, 2, zs), 3, Mat.Rock)
		tBoule(Vector3.new(X_MIN + 3, -1.2, zs + 2), 2, Mat.Slate)
		occuper(X_MIN, zs, 6)
		local n = math.max(0, math.floor(reglage("rochers", 22)))
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
		for _, xp in ipairs(X_PONTS) do
			local zp, _, hp = lit(xp)
			for _, sx in ipairs({ -1, 1 }) do
				tBoule(Vector3.new(xp + sx * (LARGEUR_PONT / 2 + 1.6), -0.9, zp - hp + 0.8), 1.7, Mat.Slate)
				tBoule(Vector3.new(xp + sx * (LARGEUR_PONT / 2 + 1.6), -0.9, zp + hp - 0.8), 1.7, Mat.Slate)
			end
		end
	end

	-- ===== 4. ponts de bois en arc (d'une berge à l'autre, là où passe la boucle) =====
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

	local function construirePont(index, xp)
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
				-- lanterne sur un poteau d'entrée sur deux (en diagonale), sinon un chapeau
				local extremite = (i == 1 and sx == -1) or (i == #ts and sx == 1)
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
		for index, xp in ipairs(X_PONTS) do
			if xp - LARGEUR_PONT / 2 > X_MIN + 6 and xp + LARGEUR_PONT / 2 < X_ROCHE - 12 then
				construirePont(index, xp)
				occuper(xp, zc(xp), LARGEUR_PONT / 2 + 1)
			end
		end
	end

	-- ===== 5. cascade =====
	local function emetteur(parent, nom, props)
		pcall(function()
			local p = Instance.new("ParticleEmitter")
			p.Name = nom
			p.Texture = "rbxasset://textures/particles/smoke_main.dds"
			for cle, valeur in pairs(props) do
				p[cle] = valeur
			end
			p.Parent = parent
		end)
	end

	local function construireCascade()
		local m = Outils.modele(dossier, "Cascade")
		local H = HAUT_CASCADE
		local W = LARGEUR_CHUTE
		-- la roche adossée aux falaises (terrain) : un contrefort, des blocs arrondis de chaque côté
		tBloc(CFrame.new(X_ROCHE + 4, H / 2 - 1, zCentre), Vector3.new(8, H + 2, LARGEUR + 2), Mat.Rock)
		tBloc(CFrame.new(X_ROCHE + 4.5, H - 0.25, zCentre), Vector3.new(7, 1.5, LARGEUR + 2), Mat.Grass)
		for _, sz in ipairs({ -1, 1 }) do
			local zb = zCentre + sz * (W / 2 + 2.4)
			tBoule(Vector3.new(X_ROCHE + 0.2, 1.5, zb), 3, Mat.Slate)
			tBoule(Vector3.new(X_ROCHE + 0.6, 6, zb + sz * 0.6), 2.8, Mat.Rock)
			tBoule(Vector3.new(X_ROCHE + 0.9, H - 4, zb), 2.6, Mat.Slate)
			tBoule(Vector3.new(X_ROCHE + 1.5, H - 0.5, zb + sz * 0.8), 2.2, Mat.Rock)
			-- rochers au pied, à moitié dans le bassin
			tBoule(Vector3.new(X_ROCHE - 5.5, -0.9, zCentre + sz * (W / 2 + 0.6)), 1.8, Mat.Slate)
		end

		-- le ruisseau sur le dessus, puis le rebord de pierre d'où tombe l'eau
		local xLevre = X_ROCHE - 0.9
		bloc(m, decor({
			Name = "Ruisseau",
			Size = Vector3.new(7, 0.3, W - 0.6),
			CFrame = CFrame.new(X_ROCHE + 3, H + 0.55, zCentre),
			Color = EAU,
			Material = Mat.Glass,
			Transparency = 0.25,
			CastShadow = false,
		}))
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
				Outils.animer(bouillon, "pulse", rng:NextNumber(1.5, 3))
			end
		end

		-- particules : écume qui gicle, embruns, gouttes au rebord
		if ecume then
			emetteur(ecume, "Ecume", {
				Color = ColorSequence.new(ECUME),
				LightEmission = 0.3,
				Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 3.2) }),
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) }),
				Lifetime = NumberRange.new(0.8, 1.6),
				Rate = 36,
				Speed = NumberRange.new(4, 8),
				SpreadAngle = Vector2.new(40, 60),
				Acceleration = Vector3.new(0, -9, 0),
				EmissionDirection = Enum.NormalId.Right,
			})
			emetteur(ecume, "Embruns", {
				Color = ColorSequence.new(EAU_CLAIRE),
				LightEmission = 0.2,
				Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 6) }),
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) }),
				Lifetime = NumberRange.new(1.5, 2.8),
				Rate = 10,
				Speed = NumberRange.new(1.5, 3),
				SpreadAngle = Vector2.new(70, 70),
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
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }),
				Lifetime = NumberRange.new(1, 1.6),
				Rate = 14,
				Speed = NumberRange.new(1, 3),
				SpreadAngle = Vector2.new(20, 40),
				Acceleration = Vector3.new(0, -30, 0),
				EmissionDirection = Enum.NormalId.Left,
			})
		end
		occuper(xPied, zCentre, 7)
	end

	-- ===== 6. nénuphars =====
	local function construireNenuphars()
		local n = math.max(0, math.floor(reglage("nenuphars", 11)))
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
					Outils.animer(groupe, "flotte", rng:NextNumber(0.5, 0.9))
					occuper(x, z, d / 2 + 0.3)
					poses = poses + 1
				else
					groupe:Destroy()
				end
			end
		end
	end

	-- ===== 7. roseaux au bord de l'eau (touffes de tiges et massettes) =====
	local function construireRoseaux()
		local n = math.max(0, math.floor(reglage("roseaux", 8)))
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

	-- ===== 8. galets Slate arrondis sur les berges, en petits groupes =====
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
		{ "rochers", construireRochers },
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
