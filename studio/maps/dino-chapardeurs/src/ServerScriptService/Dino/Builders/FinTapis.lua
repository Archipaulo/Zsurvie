-- Constructeur FinTapis : la « Grande Porte » par où partent les dinos invendus.
-- Version 2 (STYLE.md §4) : porte de parc en rondins (Wood) sur socles de pierre (Slate), braseros et
-- torches à vrai feu (Fire + PointLight à ombres), battants en rondins taillés en pointe ouverts vers le
-- tapis, grande enseigne en planches « AU REVOIR ! ». Derrière, un rocher en Terrain Rock (strates Slate,
-- mousse LeafyGrass) percé d'un tunnel étayé de bois, couvert de lianes, où flotte une brume légère.
-- Le couloir du tapis (|z| <= 6) reste libre jusqu'à 12,5 de haut (seules des ancres invisibles y sont).
-- Emprise (CONTRAT §10) : disque r14 autour de Plan.finTapis.centre. Budget : 200 parts (le terrain n'en coûte pas).
local M = {}

local BUDGET = 200
local COULOIR = 6            -- demi-largeur du couloir du tapis à laisser libre
local PLAFOND_COULOIR = 12.5 -- rien sous cette hauteur au-dessus du couloir
local MARGE_TERRAIN = 0.3    -- le terrain (voxels) garde un peu plus de distance avec le couloir

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- ===== repère (Plan.finTapis, avec valeurs de secours) =====
	local reglage = Plan.finTapis or {}
	local centre = reglage.centre
	if typeof(centre) ~= "Vector3" then
		centre = Vector3.new(128, 0, 0)
	end
	local rayon = 14
	if type(reglage.rayon) == "number" and reglage.rayon > 0 then
		rayon = reglage.rayon
	end
	local cx, cz = centre.X, centre.Z
	local ySol = centre.Y
	local origine = CFrame.new(cx, ySol, cz)

	-- ===== palette (trois teintes par matière) =====
	local hex = Charte.hex
	local BOIS = hex("7B4F2C")            -- rondins
	local BOIS_OMBRE = Charte.ombre(BOIS)
	local BOIS_CLAIR = hex("C69463")      -- bois de bout (coupes)
	local CORDE = hex("D2B07A")
	local PIERRE = hex("7E7B88")          -- Slate des socles
	local PIERRE_CLAIRE = Charte.lumiere(PIERRE)
	local PIERRE_OMBRE = Charte.ombre(PIERRE)
	local PAVE = hex("A89F92")
	local FER = hex("3B3A42")
	local PLANCHE = hex("B9804A")
	local CADRE = hex("5B3A22")
	local TISSU = hex("3A2A20")
	local TIGE = hex("2F6E2C")
	local FEUILLES = { hex("3F9E3A"), hex("58B947"), hex("2E8034") }
	local FLAMME = hex("FF8A1F")
	local FLAMME_COEUR = hex("FFE066")
	local LUEUR = hex("FFB45A")
	local BRUME = hex("E6EEEA")

	local Mat = Enum.Material

	-- ===== création protégée, comptée, limitée à l'emprise et hors du couloir =====
	local nombre = 0

	-- vrai si une boîte (centre local dx, dz ; demi-tailles hx, hz) tient dans le disque
	local function dansDisque(dx, dz, hx, hz)
		local ax = math.abs(dx) + hx
		local az = math.abs(dz) + hz
		return ax * ax + az * az <= rayon * rayon
	end

	-- vrai si la boîte gêne le couloir du tapis (hors dalle de sol)
	local function gene(dz, hz, yBas, yHaut)
		if yHaut <= 0.3 then
			return false -- dalle au ras du sol : on marche dessus
		end
		if math.abs(dz) - hz >= COULOIR then
			return false
		end
		return yBas < PLAFOND_COULOIR
	end

	-- demi-étendues (x, y, z) de la boîte englobante d'une part tournée
	local function etendue(cf, taille)
		local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
		local ex = math.abs(r.X) * taille.X / 2 + math.abs(u.X) * taille.Y / 2 + math.abs(l.X) * taille.Z / 2
		local ey = math.abs(r.Y) * taille.X / 2 + math.abs(u.Y) * taille.Y / 2 + math.abs(l.Y) * taille.Z / 2
		local ez = math.abs(r.Z) * taille.X / 2 + math.abs(u.Z) * taille.Y / 2 + math.abs(l.Z) * taille.Z / 2
		return ex, ey, ez
	end

	local function accepte(p, ex, ey, ez, invisible)
		if nombre >= BUDGET then
			return false
		end
		if not dansDisque(p.X, p.Z, ex, ez) then
			return false
		end
		if not invisible and gene(p.Z, ez, p.Y - ey, p.Y + ey) then
			return false
		end
		return true
	end

	-- part générique ; cfL : CFrame locale (origine au centre, au sol) ; opts : solide, invisible, ombre, boule
	local function piece(fabrique, parent, nom, cfL, taille, couleur, materiau, opts)
		opts = opts or {}
		local ex, ey, ez
		if opts.boule then
			ex, ey, ez = taille.X / 2, taille.Y / 2, taille.Z / 2
		else
			ex, ey, ez = etendue(cfL, taille)
		end
		if not accepte(cfL.Position, ex, ey, ez, opts.invisible) then
			return nil
		end
		local props = {
			Name = nom,
			Size = taille,
			CFrame = origine * cfL,
			Color = couleur,
			Material = materiau or Mat.SmoothPlastic,
			Anchored = true,
			CanCollide = opts.solide == true,
			CanQuery = opts.solide == true,
			CanTouch = false,
			CastShadow = opts.ombre ~= false and not opts.invisible,
		}
		if opts.invisible then
			props.Transparency = 1
		end
		local ok, part = pcall(fabrique, parent, props)
		if ok and part then
			nombre = nombre + 1
			return part
		end
		return nil
	end

	local function bloc(parent, nom, cfL, taille, couleur, materiau, opts)
		return piece(Outils.bloc, parent, nom, cfL, taille, couleur, materiau, opts)
	end

	local function boule(parent, nom, x, y, z, d, couleur, materiau, opts)
		opts = opts or {}
		opts.boule = true
		return piece(Outils.boule, parent, nom, CFrame.new(x, y, z), Vector3.new(d, d, d), couleur, materiau, opts)
	end

	-- rondin (cylindre) du point local a au point local b, de diamètre d
	local function rondin(parent, nom, a, b, d, couleur, materiau, opts)
		local dir = b - a
		local longueur = dir.Magnitude
		if longueur < 0.05 then
			return nil
		end
		local milieu = (a + b) / 2
		local cf
		if math.abs(dir.Unit.Y) > 0.98 then
			cf = CFrame.new(milieu) * CFrame.Angles(0, 0, math.rad(90))
		else
			cf = CFrame.lookAt(milieu, b) * CFrame.Angles(0, math.rad(90), 0)
		end
		return piece(Outils.cylindre, parent, nom, cf, Vector3.new(longueur, d, d), couleur, materiau, opts)
	end

	-- pilier aux arêtes arrondies (Outils.blocArrondi : 6 parts)
	local function socle(parent, nom, x, y, z, taille, couleur, materiau)
		if nombre + 6 > BUDGET or not Outils.blocArrondi then
			return nil
		end
		if not accepte(Vector3.new(x, y, z), taille.X / 2, taille.Y / 2, taille.Z / 2, false) then
			return nil
		end
		local ok, m = pcall(Outils.blocArrondi, parent, {
			Name = nom,
			Size = taille,
			CFrame = origine * CFrame.new(x, y, z),
			Color = couleur,
			Material = materiau,
			Anchored = true,
			CanCollide = true,
			CanQuery = true,
			CanTouch = false,
		}, 0.7)
		if ok and m then
			nombre = nombre + 6
			return m
		end
		return nil
	end

	-- feu : Fire + PointLight à ombres, flamme Neon qui pulse (l'aperçu ne montre que la flamme)
	local function feu(part, taille, portee, eclat)
		if not part then
			return
		end
		pcall(function()
			local f = Instance.new("Fire")
			f.Name = "Feu"
			f.Size = taille
			f.Heat = taille + 3
			f.Color = FLAMME
			f.SecondaryColor = FLAMME_COEUR
			f.Parent = part
		end)
		pcall(function()
			local l = Outils.lumiere(part, { Range = portee, Brightness = eclat, Color = LUEUR })
			l.Shadows = true
		end)
		pcall(Outils.animer, part, "pulse", 1.3)
	end

	-- ===== terrain Roblox : roche, strates et mousse (jamais dans le couloir ni hors du disque) =====
	local terrainOk = Outils.terrainBloc ~= nil and Outils.terrainBoule ~= nil and Outils.terrainCylindre ~= nil
	local limiteZ = COULOIR + MARGE_TERRAIN
	local limiteY = PLAFOND_COULOIR + MARGE_TERRAIN

	local function borne(v, a, b)
		return math.max(a, math.min(b, v))
	end

	local function rocheBoule(dx, y, dz, r, materiau)
		if not terrainOk then
			return
		end
		r = math.min(r, rayon + 0.3 - math.sqrt(dx * dx + dz * dz))
		local qz = borne(dz, -limiteZ, limiteZ)
		local qy = borne(y, 0.3, limiteY)
		local ecart = math.sqrt((dz - qz) * (dz - qz) + (y - qy) * (y - qy))
		if ecart < r then
			r = ecart - 0.1
		end
		if r < 1.5 then
			return
		end
		Outils.terrainBoule(Vector3.new(cx + dx, ySol + y, cz + dz), r, materiau)
	end

	-- cylindre de terrain vertical (centre dx, y, dz)
	local function rocheCylindre(dx, y, dz, h, r, materiau)
		if not terrainOk then
			return
		end
		if math.sqrt(dx * dx + dz * dz) + r > rayon + 0.3 then
			return
		end
		if math.abs(dz) - r < limiteZ and y - h / 2 < limiteY and y + h / 2 > 0.3 then
			return
		end
		Outils.terrainCylindre(CFrame.new(cx + dx, ySol + y, cz + dz), h, r, materiau)
	end

	-- bloc de terrain, éventuellement incliné (cfL : CFrame locale), vérifié sur sa boîte englobante
	local function rocheBloc(cfL, taille, materiau)
		if not terrainOk then
			return
		end
		local p = cfL.Position
		local ex, ey, ez = etendue(cfL, taille)
		if not dansDisque(p.X, p.Z, ex, ez) then
			return
		end
		if math.abs(p.Z) - ez < limiteZ and p.Y - ey < limiteY and p.Y + ey > 0.3 then
			return
		end
		Outils.terrainBloc(origine * cfL, taille, materiau)
	end

	local modelePorte = Outils.modele(dossier, "GrandePorte")
	local modeleRocher = Outils.modele(dossier, "Rocher")
	local modeleLianes = Outils.modele(dossier, "Lianes")
	local modeleTorches = Outils.modele(dossier, "Torches")

	-- ===== 1. le rocher en terrain (x local de -4 à 11) =====
	for _, s in ipairs({ -1, 1 }) do
		-- parois du tunnel (noyau caché)
		rocheBloc(CFrame.new(2, 6.75, s * 8.5), Vector3.new(12, 13.5, 3.4), Mat.Rock)
		-- flancs : masses arrondies de tailles variées (le terrain les fond en une seule roche)
		rocheBoule(-2, 3.5, s * 10.3, 3.8, Mat.Rock)
		rocheBoule(3, 4, s * 10.2, 3.6, Mat.Rock)
		rocheBoule(7.5, 4, s * 8.6, 2.3, Mat.Rock)
		rocheBoule(0.5, 9.5, s * 10, 3.7, Mat.Rock)
		rocheBoule(5.5, 9, s * 9.4, 3.1, Mat.Rock)
		rocheCylindre(8.5, 6, s * 8.4, 12, 2, Mat.Rock)
		rocheBoule(1, 12.5, s * 9.8, 3.5, Mat.Rock)
		rocheBoule(2, 16.8, s * 9.3, 4.5, Mat.Rock)
		rocheBoule(-3.5, 9, s * 8.8, 2.4, Mat.Rock)
		rocheBoule(7, 15, s * 8.5, 2.9, Mat.Rock)
		-- pan de roche incliné en façade (silhouette anguleuse), strate d'ardoise qui affleure, éboulis au pied
		rocheBloc(CFrame.new(-2.5, 7, s * 10.9) * CFrame.Angles(0, math.rad(-20 * s), math.rad(4 * s)), Vector3.new(4.5, 12, 2.2), Mat.Rock)
		rocheBloc(CFrame.new(1.5, 6, s * 11.4) * CFrame.Angles(0, 0, math.rad(12)), Vector3.new(6.5, 1.8, 2.4), Mat.Slate)
		rocheBoule(-4, 1.5, s * 10.8, 2.6, Mat.Slate)
		rocheBoule(6, 1.6, s * 10.5, 2.2, Mat.Slate)
		rocheBoule(7.5, 11, s * 8.6, 2.4, Mat.Slate)
		-- mousse sur les épaules
		rocheBoule(1, 19.8, s * 10.8, 2.5, Mat.LeafyGrass)
	end
	-- voûte et crête (la crête a une dalle inclinée pour une silhouette anguleuse)
	rocheBloc(CFrame.new(2.75, 16, 0), Vector3.new(13.5, 5, 15), Mat.Rock)
	rocheBoule(3, 19, 0, 5.8, Mat.Rock)
	rocheBoule(-1, 19.5, -3, 4.5, Mat.Rock)
	rocheBoule(6, 19, 3.5, 4.3, Mat.Rock)
	rocheBoule(-3.5, 16, 0, 3, Mat.Rock)
	rocheBoule(8.5, 16.5, 0, 3.5, Mat.Rock)
	rocheBloc(CFrame.new(3.5, 21.5, 1) * CFrame.Angles(math.rad(10), math.rad(25), math.rad(-8)), Vector3.new(9, 3, 7), Mat.Rock)
	rocheBloc(CFrame.new(5.5, 18.5, -5) * CFrame.Angles(math.rad(-14), math.rad(-15), 0), Vector3.new(7, 1.4, 4), Mat.Slate)
	-- chapeau de mousse sur la crête
	rocheBoule(2, 23.5, -1, 2.8, Mat.LeafyGrass)
	rocheBoule(5.5, 22, 4, 2.5, Mat.LeafyGrass)
	rocheBoule(-1.5, 22.8, -4, 2.4, Mat.LeafyGrass)

	-- ===== 2. sol : chemin pavé bordé d'ardoise et seuil de pierre (hauteur <= 0,3) =====
	if Outils.dalleBordee and nombre + 2 <= BUDGET then
		pcall(Outils.dalleBordee, dossier, {
			Name = "Dalle",
			Size = Vector3.new(20, 0.2, 11),
			CFrame = origine * CFrame.new(-2, 0.1, 0),
			Color = PAVE,
			Material = Mat.Cobblestone,
			MaterialBord = Mat.Slate,
			Anchored = true,
			CanCollide = true,
			CanTouch = false,
		}, 0.4, PIERRE_OMBRE)
		nombre = nombre + 2
	end
	bloc(dossier, "Seuil", CFrame.new(-7, 0.13, 0), Vector3.new(2.2, 0.26, 13), PIERRE, Mat.Slate, { solide = true })

	-- ===== 3. la Grande Porte en rondins (x local -7) =====
	local XP = -7
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		local zp = s * 8.4
		-- socle de pierre arrondi et sa dalle de couronnement
		socle(modelePorte, "Socle" .. suffixe, XP, 1.5, s * 8.6, Vector3.new(4, 3, 4), PIERRE, Mat.Slate)
		bloc(modelePorte, "Couronne" .. suffixe, CFrame.new(XP, 3.25, s * 8.5), Vector3.new(4.2, 0.5, 4.2), PIERRE_CLAIRE, Mat.Slate, { solide = true })
		-- gros rondin et deux rondins d'appui côté extérieur
		rondin(modelePorte, "Pilier" .. suffixe, Vector3.new(XP, 3.5, zp), Vector3.new(XP, 19, zp), 2.8, BOIS, Mat.Wood, { solide = true })
		rondin(modelePorte, "Appui" .. suffixe .. "1", Vector3.new(XP - 0.6, 3.5, s * 9.9), Vector3.new(XP - 0.6, 16.5, s * 9.9), 1.2, BOIS_OMBRE, Mat.Wood, { solide = true })
		rondin(modelePorte, "Appui" .. suffixe .. "2", Vector3.new(XP + 0.6, 3.5, s * 9.9), Vector3.new(XP + 0.6, 15, s * 9.9), 1.2, BOIS, Mat.Wood, { solide = true })
		-- ligatures de corde
		for i, y in ipairs({ 6.5, 12.5 }) do
			rondin(modelePorte, "Corde" .. suffixe .. i, Vector3.new(XP, y - 0.3, s * 8.9), Vector3.new(XP, y + 0.3, s * 8.9), 3.6, CORDE, Mat.Fabric)
		end
		-- brasero de pierre au sommet
		rondin(modelePorte, "Brasero" .. suffixe, Vector3.new(XP, 19, zp), Vector3.new(XP, 20, zp), 3.2, PIERRE, Mat.Slate)
		rondin(modelePorte, "Cerclage" .. suffixe, Vector3.new(XP, 19.8, zp), Vector3.new(XP, 20.1, zp), 3.5, FER, Mat.Metal)
		rondin(modeleTorches, "Braises" .. suffixe, Vector3.new(XP, 19.9, zp), Vector3.new(XP, 20.25, zp), 2.6, FLAMME, Mat.Neon, { ombre = false })
		local flamme = boule(modeleTorches, "Brasier" .. suffixe, XP, 20.85, zp, 1.4, FLAMME, Mat.Neon, { ombre = false })
		boule(modeleTorches, "Brasier" .. suffixe .. "Coeur", XP, 21.45, zp, 0.8, FLAMME_COEUR, Mat.Neon, { ombre = false })
		feu(flamme, 6, 24, 2.2)

		-- torche murale sur la face avant du pilier (vers le tapis)
		local tz = s * 8.2
		bloc(modeleTorches, "TorchePilier" .. suffixe .. "Support", CFrame.new(XP - 1.85, 9.3, tz), Vector3.new(1.1, 0.35, 0.35), FER, Mat.Metal)
		rondin(modeleTorches, "TorchePilier" .. suffixe .. "Manche", Vector3.new(XP - 2.2, 8.4, tz), Vector3.new(XP - 2.7, 10.9, tz), 0.42, BOIS_OMBRE, Mat.Wood)
		rondin(modeleTorches, "TorchePilier" .. suffixe .. "Tete", Vector3.new(XP - 2.62, 10.5, tz), Vector3.new(XP - 2.78, 11.3, tz), 0.68, TISSU, Mat.Fabric)
		local petite = boule(modeleTorches, "TorchePilier" .. suffixe .. "Flamme", XP - 2.82, 11.75, tz, 0.95, FLAMME, Mat.Neon, { ombre = false })
		feu(petite, 3, 16, 1.6)

		-- battant en rondins taillés en pointe, grand ouvert vers le tapis (hors couloir)
		local battant = Outils.modele(modelePorte, "Battant" .. suffixe)
		local zb = s * 6.9
		local hauts = { 11.2, 11.7, 11.35, 11.8, 11.45 }
		for i = 1, 5 do
			local xb = XP - 1.03 - (i - 1) * 0.86
			local haut = hauts[i]
			local teinte = BOIS
			if i % 2 == 0 then
				teinte = BOIS_OMBRE
			end
			rondin(battant, "Rondin" .. i, Vector3.new(xb, 0.3, zb), Vector3.new(xb, haut, zb), 0.86, teinte, Mat.Wood, { solide = true })
			bloc(battant, "Pointe" .. i, CFrame.new(xb, haut, zb) * CFrame.Angles(0, 0, math.rad(45)), Vector3.new(0.6, 0.6, 0.8), BOIS_CLAIR, Mat.Wood)
		end
		local zt = s * 7.63
		rondin(battant, "TraverseBas", Vector3.new(XP - 0.8, 2.8, zt), Vector3.new(XP - 4.4, 2.8, zt), 0.55, BOIS_OMBRE, Mat.Wood)
		rondin(battant, "TraverseHaut", Vector3.new(XP - 0.8, 8.8, zt), Vector3.new(XP - 4.4, 8.8, zt), 0.55, BOIS_OMBRE, Mat.Wood)
		rondin(battant, "Echarpe", Vector3.new(XP - 1, 3.2, zt), Vector3.new(XP - 4.2, 8.4, zt), 0.45, BOIS_OMBRE, Mat.Wood)
		for i, y in ipairs({ 2.8, 8.8 }) do
			bloc(battant, "Penture" .. i, CFrame.new(XP - 1.5, y, s * 6.42), Vector3.new(1.8, 0.35, 0.12), FER, Mat.Metal)
		end
	end

	-- poutres transversales (au-dessus du couloir, à partir de 13,2)
	local linteau = rondin(modelePorte, "Linteau", Vector3.new(XP, 17, -11), Vector3.new(XP, 17, 11), 2.2, BOIS, Mat.Wood, { solide = true })
	rondin(modelePorte, "LinteauBas", Vector3.new(XP, 13.9, -9.6), Vector3.new(XP, 13.9, 9.6), 1.4, BOIS_OMBRE, Mat.Wood, { solide = true })
	for _, s in ipairs({ -1, 1 }) do
		rondin(modelePorte, "Coupe" .. ((s < 0) and "N" or "S"), Vector3.new(XP, 17, s * 10.98), Vector3.new(XP, 17, s * 11.1), 2, BOIS_CLAIR, Mat.Wood)
	end

	-- grande enseigne en planches posée sur le linteau, cadre sombre, texte doré cerné tourné vers le tapis (-X)
	local enseigne = bloc(modelePorte, "Enseigne", CFrame.new(XP, 19.9, 0), Vector3.new(0.5, 3.2, 12), PLANCHE, Mat.WoodPlanks)
	if enseigne then
		local ok, etiquette = pcall(Outils.texte, enseigne, "Left", "AU REVOIR !", { couleur = Color3.new(1, 1, 1) })
		if ok and etiquette and Style then
			pcall(function()
				etiquette.Font = Style.policeTitre
				Style.contour(etiquette, 4)
				Style.degrade(etiquette, Color3.new(1, 1, 1), Style.boutons.jaune[1])
			end)
		end
	end
	bloc(modelePorte, "CadreEnseigne", CFrame.new(XP, 21.7, 0), Vector3.new(0.75, 0.45, 12.9), CADRE, Mat.Wood)
	bloc(modelePorte, "CadreEnseigneBas", CFrame.new(XP, 18.2, 0), Vector3.new(0.75, 0.4, 12.9), CADRE, Mat.Wood)
	bloc(modelePorte, "MontantN", CFrame.new(XP, 19.95, -6.25), Vector3.new(0.75, 3.9, 0.45), CADRE, Mat.Wood)
	bloc(modelePorte, "MontantS", CFrame.new(XP, 19.95, 6.25), Vector3.new(0.75, 3.9, 0.45), CADRE, Mat.Wood)

	-- ===== grand titre flottant « 👋 AU REVOIR ! » (Style.etiquette, lisible de loin et sur mobile) =====
	local support = enseigne or linteau
	if support and Style then
		pcall(function()
			local _, textes = Style.etiquette(support, {
				{ texte = "👋 AU REVOIR !", titre = true, taille = 1.5, contour = 4, nom = "Titre" },
				{ texte = "Les dinos invendus partent ici", taille = 0.6, couleur = Style.couleurs.revenu, nom = "SousTitre" },
			}, {
				Name = "TitreGrandePorte",
				largeur = 24,
				hauteurLigne = 3,
				StudsOffset = Vector3.new(0, 7, 0),
				MaxDistance = 260,
			})
			if textes and textes[1] then
				local jaune = Style.boutons.jaune
				Style.degrade(textes[1], Color3.new(1, 1, 1), jaune[1])
			end
		end)
	end

	-- ===== 4. le tunnel : cadres de soutènement en bois, lueur chaude, brume =====
	for i, xa in ipairs({ -1, 5, 9.6 }) do
		rondin(modeleRocher, "Etai" .. i .. "N", Vector3.new(xa, 0, -6.6), Vector3.new(xa, 13.3, -6.6), 0.9, BOIS_OMBRE, Mat.Wood)
		rondin(modeleRocher, "Etai" .. i .. "S", Vector3.new(xa, 0, 6.6), Vector3.new(xa, 13.3, 6.6), 0.9, BOIS_OMBRE, Mat.Wood)
		local poutre = rondin(modeleRocher, "Chapeau" .. i, Vector3.new(xa, 13.05, -7.2), Vector3.new(xa, 13.05, 7.2), 0.9, BOIS, Mat.Wood)
		if poutre and i <= 2 then
			pcall(function()
				local l = Outils.lumiere(poutre, { Range = 16, Brightness = 1.1, Color = LUEUR })
				l.Shadows = true
			end)
		end
	end

	-- brume : ancres invisibles (sans collision ni requête) et particules de fumée claire qui roulent vers le tapis
	local function brume(nom, x, y, z, taille, grosseur, debit)
		local ancre = bloc(dossier, nom, CFrame.new(x, y, z), taille, BRUME, Mat.SmoothPlastic, { invisible = true })
		if not ancre then
			return
		end
		pcall(function()
			local p = Instance.new("ParticleEmitter")
			p.Name = "Brume"
			p.Texture = "rbxasset://textures/particles/smoke_main.dds"
			p.Color = ColorSequence.new(BRUME)
			p.LightInfluence = 0.7
			p.Size = NumberSequence.new(grosseur * 0.6, grosseur)
			p.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.3, 0.72),
				NumberSequenceKeypoint.new(1, 1),
			})
			p.Lifetime = NumberRange.new(6, 10)
			p.Rate = debit
			p.Speed = NumberRange.new(0.4, 1.1)
			p.RotSpeed = NumberRange.new(-10, 10)
			p.Rotation = NumberRange.new(0, 360)
			p.EmissionDirection = Enum.NormalId.Left
			p.SpreadAngle = Vector2.new(35, 8)
			p.Acceleration = Vector3.new(0, 0.12, 0)
			p.Parent = ancre
		end)
	end
	brume("BrumeTunnel", 3, 1.5, 0, Vector3.new(12, 0.5, 10), 9, 5)
	brume("BrumeEntree", -5.5, 0.6, 0, Vector3.new(5, 0.4, 11), 5, 3)

	-- ===== 5. buissons au pied du rocher et sur la crête =====
	boule(modeleLianes, "BuissonN", -5, 1, -11, 2.2, FEUILLES[1], Mat.LeafyGrass)
	boule(modeleLianes, "BuissonS", -5, 1, 11, 2.2, FEUILLES[2], Mat.LeafyGrass)
	boule(modeleLianes, "BuissonN2", 1, 1.1, -12, 2.4, FEUILLES[3], Mat.LeafyGrass)
	boule(modeleLianes, "BuissonS2", 1, 1.1, 12, 2.4, FEUILLES[1], Mat.LeafyGrass)
	boule(modeleLianes, "TouffeCrete", 3, 24.6, -1, 2.6, FEUILLES[2], Mat.LeafyGrass)
	boule(modeleLianes, "TouffeCrete2", 6.5, 23.2, 3, 2.2, FEUILLES[1], Mat.LeafyGrass)

	-- ===== 6. lianes (tige en segments et grappes de feuilles), jamais sous 12,5 au-dessus du couloir =====
	local alea = Outils.aleatoire(128)
	local numero = 0
	local function feuille(x, y, z, d)
		numero = numero + 1
		local teinte = FEUILLES[(numero % 3) + 1]
		return boule(modeleLianes, "Feuille" .. numero, x, y, z, d, teinte, Mat.LeafyGrass, { ombre = false })
	end

	-- liane qui tombe de (x0, yHaut, z0) jusqu'à yBas en s'écartant de la paroi (sens = -1 vers -X, 1 vers +X)
	local function liane(x0, z0, yHaut, yBas, sens)
		numero = numero + 1
		local nom = "Liane" .. numero
		local n = math.max(2, math.ceil((yHaut - yBas) / 3.4))
		local precedent = Vector3.new(x0, yHaut, z0)
		-- touffe d'accroche en haut
		feuille(x0 + sens * 0.2, yHaut + 0.2, z0, 1.7)
		for i = 1, n do
			local t = i / n
			local p = Vector3.new(
				x0 + sens * math.sin(t * math.pi) * 0.45,
				yHaut - (yHaut - yBas) * t,
				z0 + alea:NextNumber(-0.35, 0.35)
			)
			rondin(modeleLianes, nom .. "Brin" .. i, precedent, p, 0.26, TIGE, Mat.Grass, { ombre = false })
			-- grappes de plus en plus petites vers le bas
			feuille(p.X, p.Y, p.Z, 1.45 - 0.6 * t + alea:NextNumber(-0.1, 0.1))
			precedent = p
		end
	end

	-- façade (vers le tapis)
	liane(-4.3, -7.1, 15, 5.5, -1)
	liane(-4.3, 7.2, 15, 4, -1)
	liane(-4.5, -9, 16, 9, -1)
	liane(-4.5, 9, 16, 10.5, -1)
	-- flanc sud et flanc nord
	liane(2, 12.5, 19, 6, 1)
	liane(-1.5, 12.2, 18, 9.5, 1)
	liane(2, -12.5, 19, 7.5, 1)
	-- sortie arrière du tunnel
	liane(10.3, 7.4, 15.5, 6, 0)
	liane(10.3, -7.4, 15.5, 8, 0)

	-- frange de feuilles au bord des deux bouches du tunnel (au-dessus de 12,7)
	for _, z in ipairs({ -5.2, -3.1, -1, 1.2, 3.3, 5.4 }) do
		feuille(-4.3, 13.3, z, 1.1)
	end
	for _, z in ipairs({ -4, -1, 2.5, 5 }) do
		feuille(10.3, 13.3, z, 1.1)
	end

	-- festons de liane accrochés au linteau (point bas à 15,4)
	for _, s in ipairs({ -1, 1 }) do
		local a = Vector3.new(XP - 1.15, 17.2, s * 6.3)
		local bas = Vector3.new(XP - 1.2, 15.6, s * 3.6)
		local b = Vector3.new(XP - 1.15, 17.2, s * 1)
		rondin(modeleLianes, "Feston" .. ((s < 0) and "N" or "S") .. "1", a, bas, 0.26, TIGE, Mat.Grass, { ombre = false })
		rondin(modeleLianes, "Feston" .. ((s < 0) and "N" or "S") .. "2", bas, b, 0.26, TIGE, Mat.Grass, { ombre = false })
		feuille(bas.X, bas.Y - 0.1, bas.Z, 1.1)
		feuille(a.X, a.Y - 0.6, (a.Z + bas.Z) / 2, 0.9)
		feuille(b.X, b.Y - 0.6, (b.Z + bas.Z) / 2, 0.9)
	end

	dossier:SetAttribute("Parts", nombre)
end

return M
