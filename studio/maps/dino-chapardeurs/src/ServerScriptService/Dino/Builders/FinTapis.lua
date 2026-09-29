-- Constructeur FinTapis : la « Grande Porte » par où partent les dinos invendus (plan v2 « plus d'air »).
-- Deux piliers de roche taillée (socle, fût et chapiteau à arêtes arrondies Outils.blocArrondi, pans de
-- pierre inclinés de 10 à 20° qui donnent des facettes), un linteau en gros rondin cerclé d'or (comme
-- l'arche de la Nurserie) portant l'enseigne « AU REVOIR ! » et deux braseros, des battants de bois
-- entrouverts derrière les piliers, puis une galerie couverte en planches (étais, palissades, toit) où
-- flotte une brume légère : les dinos passent entre les battants et s'enfoncent dans la pénombre.
-- Flammes animées (langues Neon qui tournoient, cœur qui pulse, Fire, étincelles, PointLight à ombres),
-- 4 touffes de mousse, 2 lianes et des festons. Au sol, un parvis rond dallé que les joueurs contournent.
-- Tout vient de Plan.finTapis (centre, rayon) et Plan.tapis (axe, largeur) : aucune coordonnée en dur.
-- Le couloir du tapis (|z local| < demi-largeur du tapis + 1) reste libre jusqu'à 12,5 de haut.
-- Le titre flottant est posé au-dessus du point le plus haut réellement construit (+ 5 studs).
-- Emprise (CONTRAT §10) : disque de rayon Plan.finTapis.rayon. Budget : 250 parts.
local M = {}

local BUDGET = 250
local PLAFOND_COULOIR = 12.5 -- rien sous cette hauteur au-dessus du couloir
local MARGE_TITRE = 5        -- écart entre le sommet de la porte (flammes comprises) et le bas du titre

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- ===== repère : Plan.finTapis (centre, rayon), orienté selon l'axe de Plan.tapis =====
	local reglage = Plan.finTapis or {}
	local infoTapis = Plan.tapis or {}
	local rayon = 15
	if type(reglage.rayon) == "number" and reglage.rayon > 0 then
		rayon = reglage.rayon
	end
	-- axe du tapis (du début vers la fin) : +X local pointe vers l'arrière de la porte
	local axe = Vector3.new(1, 0, 0)
	if typeof(infoTapis.debut) == "Vector3" and typeof(infoTapis.fin) == "Vector3" then
		local d = Vector3.new(infoTapis.fin.X - infoTapis.debut.X, 0, infoTapis.fin.Z - infoTapis.debut.Z)
		if d.Magnitude > 1 then
			axe = d.Unit
		end
	end
	local centre = reglage.centre
	if typeof(centre) ~= "Vector3" then
		-- secours : juste après la fin du tapis
		if typeof(infoTapis.fin) ~= "Vector3" then
			return
		end
		centre = infoTapis.fin + axe * (rayon + 2)
	end
	local haut = Vector3.new(0, 1, 0)
	local origine = CFrame.fromMatrix(centre, axe, haut, axe:Cross(haut))

	-- couloir du tapis : demi-largeur de la bande + 1 (8 avec le plan v2)
	local largeurTapis = 14
	if type(infoTapis.largeur) == "number" and infoTapis.largeur > 0 then
		largeurTapis = infoTapis.largeur
	end
	local C = largeurTapis / 2 + 1

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
	local PARVIS = hex("948B80")
	local FER = hex("3B3A42")
	local PLANCHE = hex("B9804A")
	local CADRE = hex("5B3A22")
	local TISSU = hex("3A2A20")
	local TIGE = hex("2F6E2C")
	local FEUILLES = { hex("3F9E3A"), hex("58B947"), hex("2E8034") }
	local FLAMME = hex("FF8A1F")
	local FLAMME_VIVE = hex("FF5A1A")
	local FLAMME_COEUR = hex("FFE066")
	local LUEUR = hex("FFB45A")
	local BRUME = hex("E6EEEA")
	local DORE = Charte.dore or hex("FFC933")
	local ROCHE = hex("8A8494")           -- pierre taillée des piliers
	local ROCHE_CLAIRE = Charte.lumiere(ROCHE)
	local ROCHE_OMBRE = Charte.ombre(ROCHE)
	local MOUSSE = { hex("4FA83E"), hex("67C24C"), hex("3A8C35") }

	local Mat = Enum.Material

	-- ===== création protégée, comptée, limitée à l'emprise et hors du couloir =====
	local nombre = 0
	local yMax = 0 -- sommet réel de ce qui est construit (pour placer le titre au-dessus)

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
		if math.abs(dz) - hz >= C then
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

	local function accepte(p, ex, ey, ez, invisible, rond)
		if nombre >= BUDGET then
			return false
		end
		if rond then
			-- disque plat (parvis) : on vérifie le rayon et non la boîte
			if math.sqrt(p.X * p.X + p.Z * p.Z) + math.max(ex, ez) > rayon then
				return false
			end
		elseif not dansDisque(p.X, p.Z, ex, ez) then
			return false
		end
		if not invisible and gene(p.Z, ez, p.Y - ey, p.Y + ey) then
			return false
		end
		if not invisible then
			yMax = math.max(yMax, p.Y + ey)
		end
		return true
	end

	-- part générique ; cfL : CFrame locale (origine au centre, au sol) ; opts : solide, invisible, ombre, boule, rond
	local function piece(fabrique, parent, nom, cfL, taille, couleur, materiau, opts)
		opts = opts or {}
		local ex, ey, ez
		if opts.boule then
			ex, ey, ez = taille.X / 2, taille.Y / 2, taille.Z / 2
		else
			ex, ey, ez = etendue(cfL, taille)
		end
		if not accepte(cfL.Position, ex, ey, ez, opts.invisible, opts.rond) then
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

	-- disque plat posé au sol (centre local x, z), de diamètre d et d'épaisseur h
	local function disquePlat(parent, nom, x, z, d, h, couleur, materiau)
		local cf = CFrame.new(x, h / 2, z) * CFrame.Angles(0, 0, math.rad(90))
		return piece(Outils.cylindre, parent, nom, cf, Vector3.new(h, d, d), couleur, materiau, { solide = true, rond = true, ombre = false })
	end

	-- bloc aux arêtes verticales arrondies (Outils.blocArrondi : 6 parts) ; arrondi : rayon des arêtes
	local function socle(parent, nom, x, y, z, taille, couleur, materiau, arrondi)
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
		}, arrondi or 0.7)
		if ok and m then
			nombre = nombre + 6
			return m
		end
		return nil
	end

	-- ===== flammes animées (côté client via Outils.animer : effets légers) =====
	-- étincelles qui montent du feu (peu de particules, pas de collision)
	local function etincelles(part, debit)
		pcall(function()
			local p = Instance.new("ParticleEmitter")
			p.Name = "Etincelles"
			p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			p.Color = ColorSequence.new(FLAMME_COEUR, FLAMME_VIVE)
			p.LightEmission = 1
			p.LightInfluence = 0
			p.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.28),
				NumberSequenceKeypoint.new(1, 0),
			})
			p.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.7, 0.2),
				NumberSequenceKeypoint.new(1, 1),
			})
			p.Lifetime = NumberRange.new(0.8, 1.6)
			p.Rate = debit
			p.Speed = NumberRange.new(1.5, 3.5)
			p.SpreadAngle = Vector2.new(18, 18)
			p.EmissionDirection = Enum.NormalId.Top
			p.Acceleration = Vector3.new(0, 1.5, 0)
			p.Drag = 1
			p.Parent = part
		end)
	end

	-- feu : Fire + PointLight à ombres + étincelles
	local function feu(part, taille, portee, eclat, debit)
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
		etincelles(part, debit)
	end

	-- flamme stylisée : langues de feu en « diamants » Neon qui tournoient (modèle « tourne »)
	-- autour d'un cœur jaune qui pulse ; d = taille de la flamme ; renvoie la langue principale
	local function flamme(parent, nom, x, y, z, d, vitesse)
		local m = Outils.modele(parent, nom)
		local diamant = CFrame.Angles(math.rad(45), 0, math.rad(35.26))
		local langue = bloc(m, "Langue", CFrame.new(x, y + d * 0.45, z) * diamant, Vector3.new(d, d, d), FLAMME, Mat.Neon, { ombre = false })
		bloc(m, "LangueVive", CFrame.new(x + d * 0.12, y + d * 0.35, z - d * 0.1) * CFrame.Angles(0, math.rad(40), 0) * diamant,
			Vector3.new(d * 0.75, d * 0.75, d * 0.75), FLAMME_VIVE, Mat.Neon, { ombre = false })
		bloc(m, "Pointe", CFrame.new(x - d * 0.05, y + d * 1.05, z + d * 0.05) * CFrame.Angles(0, math.rad(20), 0) * diamant,
			Vector3.new(d * 0.45, d * 0.45, d * 0.45), FLAMME, Mat.Neon, { ombre = false })
		local coeur = boule(m, "Coeur", x, y + d * 0.35, z, d * 0.6, FLAMME_COEUR, Mat.Neon, { ombre = false })
		pcall(function()
			m.WorldPivot = origine * CFrame.new(x, y + d * 0.45, z)
		end)
		pcall(Outils.animer, m, "tourne", vitesse or 2.4)
		if coeur then
			pcall(Outils.animer, coeur, "pulse", 3.1)
		end
		return langue or coeur
	end

	local modelePorte = Outils.modele(dossier, "GrandePorte")
	local modeleGalerie = Outils.modele(dossier, "Galerie")
	local modeleLianes = Outils.modele(dossier, "Lianes")
	local modeleTorches = Outils.modele(dossier, "Torches")

	-- ===== 1. sol : parvis rond dallé, liseré d'ardoise, chemin pavé et seuil (hauteur <= 0,3) =====
	local XP = -5 -- plan de la porte (x local) : les piliers tiennent dans le disque, devant la galerie
	disquePlat(dossier, "ParvisBord", 0, 0, 2 * rayon - 0.2, 0.18, PIERRE_OMBRE, Mat.Slate)
	disquePlat(dossier, "Parvis", 0, 0, 2 * rayon - 1.6, 0.22, PARVIS, Mat.Slate)
	bloc(dossier, "Chemin", CFrame.new(-2, 0.13, 0), Vector3.new(20, 0.26, 2 * C + 1), PAVE, Mat.Cobblestone, { solide = true, ombre = false })
	bloc(dossier, "Seuil", CFrame.new(XP, 0.14, 0), Vector3.new(2.4, 0.28, 2 * C + 1), PIERRE, Mat.Slate, { solide = true, ombre = false })

	-- ===== 2. les deux piliers de roche taillée =====
	-- zc : axe des piliers (face intérieure à C + 0,7, hors du couloir) ; fût 4 x 11 x 3,6
	local zcAbs = C + 2.5
	local Y_FUT_BAS, Y_FUT_HAUT = 1.2, 12.2
	local Y_CHAPITEAU = 12.75 -- chapiteau de 12,2 à 13,3 : le linteau repose dessus
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		local zc = s * zcAbs
		local pilier = Outils.modele(modelePorte, "Pilier" .. suffixe)
		-- socle, fût et chapiteau aux arêtes arrondies
		socle(pilier, "Socle", XP, 0.6, zc, Vector3.new(4.8, 1.2, 4.4), PIERRE_OMBRE, Mat.Cobblestone, 0.8)
		socle(pilier, "Fut", XP, (Y_FUT_BAS + Y_FUT_HAUT) / 2, zc, Vector3.new(4, Y_FUT_HAUT - Y_FUT_BAS, 3.6), ROCHE, Mat.Slate, 0.9)
		socle(pilier, "Chapiteau", XP, Y_CHAPITEAU, zc, Vector3.new(4.8, 1.1, 4.4), ROCHE_CLAIRE, Mat.Slate, 0.6)
		-- filet doré sur la face avant du chapiteau (vers le tapis)
		bloc(pilier, "FiletDore", CFrame.new(XP - 2.44, Y_CHAPITEAU, zc), Vector3.new(0.14, 0.32, 3.6), DORE, Mat.Metal, { ombre = false })

		-- facettes : pans de pierre taillée inclinés de 10 à 20°, à moitié noyés dans le fût
		bloc(pilier, "PanAvant", CFrame.new(XP - 1.75, 3.7, zc) * CFrame.Angles(0, math.rad(6 * s), math.rad(-14)),
			Vector3.new(1.3, 5.4, 3.1), ROCHE_CLAIRE, Mat.Slate, { solide = true })
		bloc(pilier, "PanAvantHaut", CFrame.new(XP - 1.7, 10.4, zc + s * 0.35) * CFrame.Angles(0, 0, math.rad(12)),
			Vector3.new(1.1, 2.6, 2.4), ROCHE, Mat.Slate, { solide = true })
		bloc(pilier, "PanExterieur", CFrame.new(XP + 0.3, 3.4, zc + s * 1.55) * CFrame.Angles(math.rad(-16 * s), 0, 0),
			Vector3.new(3.3, 4.6, 1.1), ROCHE_OMBRE, Mat.Rock, { solide = true })
		bloc(pilier, "PanExterieurHaut", CFrame.new(XP - 0.3, 8.9, zc + s * 1.45) * CFrame.Angles(math.rad(12 * s), math.rad(-10 * s), 0),
			Vector3.new(2.9, 3.8, 1), ROCHE_CLAIRE, Mat.Slate, { solide = true })
		bloc(pilier, "PanArriere", CFrame.new(XP + 1.75, 6, zc + s * 0.9) * CFrame.Angles(0, math.rad(-8 * s), math.rad(10)),
			Vector3.new(1.2, 6.5, 1.8), ROCHE_OMBRE, Mat.Slate, { solide = true })
		-- éclats de taille au pied (cailloux inclinés)
		bloc(pilier, "Eclat1", CFrame.new(XP - 2.9, 0.45, zc - s * 0.7) * CFrame.Angles(math.rad(18), math.rad(30), math.rad(-15)),
			Vector3.new(1.5, 0.9, 1.2), ROCHE_OMBRE, Mat.Slate)
		bloc(pilier, "Eclat2", CFrame.new(XP - 2.6, 0.35, zc + s * 1) * CFrame.Angles(math.rad(-12), math.rad(-20), math.rad(16)),
			Vector3.new(1, 0.7, 0.9), ROCHE, Mat.Slate)

		-- torche murale sur la face avant du fût (côté extérieur, la liane pend côté couloir)
		local zt = zc + s * 0.6
		bloc(modeleTorches, "TorchePilier" .. suffixe .. "Support", CFrame.new(XP - 2.4, 7.4, zt), Vector3.new(1, 0.35, 0.35), FER, Mat.Metal)
		rondin(modeleTorches, "TorchePilier" .. suffixe .. "Manche", Vector3.new(XP - 2.7, 6.6, zt), Vector3.new(XP - 3.1, 8.9, zt), 0.42, BOIS_OMBRE, Mat.Wood)
		rondin(modeleTorches, "TorchePilier" .. suffixe .. "Tete", Vector3.new(XP - 3.04, 8.55, zt), Vector3.new(XP - 3.18, 9.3, zt), 0.68, TISSU, Mat.Fabric)
		local petite = flamme(modeleTorches, "TorchePilier" .. suffixe .. "Flamme", XP - 3.2, 9.25, zt, 0.8, 2.8)
		feu(petite, 3, 16, 1.6, 2)
	end

	-- ===== 3. le linteau : gros rondin cerclé d'or posé sur les chapiteaux =====
	local Y_LINTEAU = 14.5
	local D_LINTEAU = 2.4
	local portee = zcAbs + 2.1
	local linteau = rondin(modelePorte, "Linteau", Vector3.new(XP, Y_LINTEAU, -portee), Vector3.new(XP, Y_LINTEAU, portee), D_LINTEAU, BOIS, Mat.Wood, { solide = true })
	for _, zb in ipairs({ -(zcAbs + 1.4), -(C - 1.5), -3, 3, C - 1.5, zcAbs + 1.4 }) do
		rondin(modelePorte, "Cerclage", Vector3.new(XP, Y_LINTEAU, zb - 0.22), Vector3.new(XP, Y_LINTEAU, zb + 0.22), D_LINTEAU + 0.25, DORE, Mat.Metal)
	end
	for _, s in ipairs({ -1, 1 }) do
		rondin(modelePorte, "Coupe" .. ((s < 0) and "N" or "S"), Vector3.new(XP, Y_LINTEAU, s * (portee - 0.02)), Vector3.new(XP, Y_LINTEAU, s * (portee + 0.08)),
			D_LINTEAU - 0.4, BOIS_CLAIR, Mat.Wood)
	end
	local yDessusLinteau = Y_LINTEAU + D_LINTEAU / 2

	-- grande enseigne en planches posée sur le linteau, cadre sombre, texte doré cerné tourné vers le tapis (-X)
	local largeurEnseigne = 2 * C
	local yEnseigne = yDessusLinteau + 2
	local enseigne = bloc(modelePorte, "Enseigne", CFrame.new(XP, yEnseigne, 0), Vector3.new(0.5, 3.2, largeurEnseigne), PLANCHE, Mat.WoodPlanks)
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
	bloc(modelePorte, "CadreEnseigne", CFrame.new(XP, yEnseigne + 1.8, 0), Vector3.new(0.75, 0.45, largeurEnseigne + 0.9), CADRE, Mat.Wood)
	bloc(modelePorte, "CadreEnseigneBas", CFrame.new(XP, yEnseigne - 1.75, 0), Vector3.new(0.75, 0.4, largeurEnseigne + 0.9), CADRE, Mat.Wood)
	bloc(modelePorte, "MontantN", CFrame.new(XP, yEnseigne, -(largeurEnseigne / 2 + 0.25)), Vector3.new(0.75, 3.9, 0.45), CADRE, Mat.Wood)
	bloc(modelePorte, "MontantS", CFrame.new(XP, yEnseigne, largeurEnseigne / 2 + 0.25), Vector3.new(0.75, 3.9, 0.45), CADRE, Mat.Wood)
	-- clous dorés aux quatre coins du cadre
	for _, cy in ipairs({ -1, 1 }) do
		for _, cz in ipairs({ -1, 1 }) do
			boule(modelePorte, "Clou", XP - 0.42, yEnseigne + cy * 1.78, cz * (largeurEnseigne / 2 + 0.2), 0.36, DORE, Mat.Metal, { ombre = false })
		end
	end

	-- braseros sur les bouts du linteau, au-dessus des piliers : braises et grande flamme animée
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		local zp = s * (zcAbs + 0.8)
		rondin(modelePorte, "Brasero" .. suffixe, Vector3.new(XP, yDessusLinteau - 0.2, zp), Vector3.new(XP, yDessusLinteau + 0.8, zp), 2.4, PIERRE, Mat.Slate)
		rondin(modelePorte, "Cerclage" .. suffixe, Vector3.new(XP, yDessusLinteau + 0.6, zp), Vector3.new(XP, yDessusLinteau + 0.9, zp), 2.6, DORE, Mat.Metal)
		local braises = rondin(modeleTorches, "Braises" .. suffixe, Vector3.new(XP, yDessusLinteau + 0.7, zp), Vector3.new(XP, yDessusLinteau + 1.02, zp), 2, FLAMME_VIVE, Mat.Neon, { ombre = false })
		if braises then
			pcall(Outils.animer, braises, "pulse", 1.3)
		end
		local grande = flamme(modeleTorches, "Brasier" .. suffixe, XP, yDessusLinteau + 1, zp, 1.4, 2 + 0.4 * s)
		feu(grande, 4, 24, 2.2, 5)
	end

	-- ===== 4. battants de bois entrouverts, fixés derrière les piliers et repoussés vers la galerie =====
	local ANGLE_BATTANT = math.rad(70) -- 0 = fermé ; au-delà de 68°, le battant laisse le couloir libre
	local hauteursPlanches = { 10.4, 10.9, 10.6, 11.1 }
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		local battant = Outils.modele(modelePorte, "Battant" .. suffixe)
		local gond = Vector3.new(XP + 2.15, 0, s * (C + 1.95))
		local u = Vector3.new(math.sin(ANGLE_BATTANT), 0, -s * math.cos(ANGLE_BATTANT)) -- du gond vers le bord libre
		local normale = u:Cross(Vector3.new(0, 1, 0)) * s -- côté visible depuis le tapis : -normale
		local function surBattant(w, y, recul)
			return gond + u * w + Vector3.new(0, y, 0) - normale * (recul or 0)
		end
		-- gonds : axe de fer vertical contre le pilier
		rondin(battant, "Gond", gond + Vector3.new(0, 0.3, 0), gond + Vector3.new(0, 10.6, 0), 0.45, FER, Mat.Metal)
		-- planches (hauteurs inégales, pointes taillées)
		for i = 1, 4 do
			local w = 0.35 + (i - 0.5) * 1.05
			local h = hauteursPlanches[i]
			local teinte = (i % 2 == 0) and BOIS_OMBRE or PLANCHE
			bloc(battant, "Planche" .. i, CFrame.fromMatrix(surBattant(w, 0.3 + h / 2), u, Vector3.new(0, 1, 0)), Vector3.new(1, h, 0.45), teinte, Mat.WoodPlanks, { solide = true })
			bloc(battant, "Pointe" .. i, CFrame.fromMatrix(surBattant(w, 0.3 + h), u, Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.rad(45)),
				Vector3.new(0.7, 0.7, 0.44), BOIS_CLAIR, Mat.Wood)
		end
		-- traverses, écharpe et pentures sur la face visible
		for i, y in ipairs({ 2.6, 8.4 }) do
			bloc(battant, "Traverse" .. i, CFrame.fromMatrix(surBattant(1.85, y, 0.34), u, Vector3.new(0, 1, 0)), Vector3.new(3, 0.55, 0.25), CADRE, Mat.Wood)
			bloc(battant, "Penture" .. i, CFrame.fromMatrix(surBattant(0.9, y, 0.5), u, Vector3.new(0, 1, 0)), Vector3.new(1.5, 0.3, 0.1), DORE, Mat.Metal, { ombre = false })
		end
		rondin(battant, "Echarpe", surBattant(0.6, 2.9, 0.34), surBattant(3.1, 8.1, 0.34), 0.4, CADRE, Mat.Wood)
	end

	-- ===== 5. la galerie couverte : étais, palissades et toit de planches ; lueur chaude et brume =====
	for i, xa in ipairs({ 3.2, 9 }) do
		for _, s in ipairs({ -1, 1 }) do
			rondin(modeleGalerie, "Etai" .. i .. ((s < 0) and "N" or "S"), Vector3.new(xa, 0, s * (C + 0.6)), Vector3.new(xa, 13.4, s * (C + 0.6)), 0.9, BOIS_OMBRE, Mat.Wood)
		end
		local poutre = rondin(modeleGalerie, "Chapeau" .. i, Vector3.new(xa, 13.05, -(C + 1.2)), Vector3.new(xa, 13.05, C + 1.2), 0.9, BOIS, Mat.Wood)
		if poutre then
			pcall(function()
				local l = Outils.lumiere(poutre, { Range = 16, Brightness = 1.1, Color = LUEUR })
				l.Shadows = true
			end)
		end
	end
	for _, s in ipairs({ -1, 1 }) do
		bloc(modeleGalerie, "Palissade" .. ((s < 0) and "N" or "S"), CFrame.new(6, 6, s * (C + 1.15)), Vector3.new(7.6, 11.4, 0.4), BOIS_OMBRE, Mat.WoodPlanks, { solide = true })
	end
	bloc(modeleGalerie, "Toit", CFrame.new(6, 13.75, 0), Vector3.new(8.4, 0.5, 2 * C + 3), CADRE, Mat.WoodPlanks, { solide = true })
	bloc(modeleGalerie, "Faitage", CFrame.new(6, 14.2, 0), Vector3.new(8.8, 0.4, 1.2), BOIS, Mat.Wood)

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
	brume("BrumeGalerie", 6, 1.5, 0, Vector3.new(7, 0.5, 2 * C - 2), 9, 5)
	brume("BrumeEntree", XP + 3.5, 0.6, 0, Vector3.new(3, 0.4, 2 * C - 3), 5, 3)

	-- ===== 6. torches de parvis sur poteau, de part et d'autre de l'arrivée du tapis =====
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		local xt, zt = XP - 5.1, s * (C + 0.6)
		rondin(modeleTorches, "Poteau" .. suffixe, Vector3.new(xt, 0.2, zt), Vector3.new(xt, 4.6, zt), 0.5, BOIS_OMBRE, Mat.Wood)
		rondin(modeleTorches, "Ligature" .. suffixe, Vector3.new(xt, 3.4, zt), Vector3.new(xt, 3.7, zt), 0.62, CORDE, Mat.Fabric)
		rondin(modeleTorches, "Coupelle" .. suffixe, Vector3.new(xt, 4.6, zt), Vector3.new(xt, 5.1, zt), 1, FER, Mat.Metal)
		local f = flamme(modeleTorches, "TorcheParvis" .. suffixe .. "Flamme", xt, 5.05, zt, 0.85, 2.6 - 0.3 * s)
		feu(f, 3, 14, 1.4, 2)
	end

	-- ===== 7. mousse : 4 touffes seulement, là où l'eau de pluie s'arrête =====
	local numero = 0
	local function feuille(x, y, z, d, teinte)
		numero = numero + 1
		return boule(modeleLianes, "Feuille" .. numero, x, y, z, d, teinte or FEUILLES[(numero % 3) + 1], Mat.LeafyGrass, { ombre = false })
	end
	local function touffe(nom, x, y, z, d)
		local m = Outils.modele(modeleLianes, nom)
		boule(m, "Mousse1", x, y, z, d, MOUSSE[1], Mat.LeafyGrass)
		boule(m, "Mousse2", x + d * 0.35, y - d * 0.12, z + d * 0.3, d * 0.72, MOUSSE[2], Mat.LeafyGrass)
		boule(m, "Mousse3", x - d * 0.3, y - d * 0.2, z - d * 0.32, d * 0.6, MOUSSE[3], Mat.LeafyGrass)
	end
	touffe("MousseChapiteauN", XP + 1.9, Y_CHAPITEAU + 0.75, -(zcAbs + 1.4), 1.6)  -- sur le chapiteau nord, derrière le linteau
	touffe("MousseSocleS", XP - 1.8, 1.25, zcAbs + 1.4, 1.5)                        -- au pied du pilier sud, devant
	touffe("MousseLinteau", XP + 0.2, yDessusLinteau + 0.15, C + 1.2, 1.4)          -- sur le linteau, entre l'enseigne et le brasero
	touffe("MousseSocleN", XP + 1.6, 1.4, -(zcAbs + 1.5), 1.3)                      -- au pied du pilier nord, derrière

	-- ===== 8. deux lianes qui tombent des chapiteaux et festons, jamais sous 12,5 au-dessus du couloir =====
	local alea = Outils.aleatoire(128)
	local function liane(x0, z0, yHaut, yBas, sens)
		numero = numero + 1
		local nom = "Liane" .. numero
		local n = math.max(2, math.ceil((yHaut - yBas) / 3.4))
		local precedent = Vector3.new(x0, yHaut, z0)
		feuille(x0 + sens * 0.2, yHaut + 0.2, z0, 1.6)
		for i = 1, n do
			local t = i / n
			local p = Vector3.new(
				x0 + sens * math.sin(t * math.pi) * 0.45,
				yHaut - (yHaut - yBas) * t,
				z0 + alea:NextNumber(-0.3, 0.3)
			)
			rondin(modeleLianes, nom .. "Brin" .. i, precedent, p, 0.26, TIGE, Mat.Grass, { ombre = false })
			feuille(p.X, p.Y, p.Z, 1.3 - 0.5 * t + alea:NextNumber(-0.1, 0.1))
			precedent = p
		end
	end
	-- elles pendent devant l'arête intérieure des piliers, depuis les chapiteaux
	liane(XP - 2.6, -(C + 1.2), Y_CHAPITEAU + 0.3, 7, -1)
	liane(XP - 2.6, C + 1.2, Y_CHAPITEAU + 0.3, 9, -1)

	-- festons de liane accrochés au linteau (point bas au-dessus de 12,5)
	for _, s in ipairs({ -1, 1 }) do
		local a = Vector3.new(XP - 1.25, Y_LINTEAU + 0.1, s * (C + 0.3))
		local bas = Vector3.new(XP - 1.35, 13.4, s * (C * 0.5 + 0.6))
		local b = Vector3.new(XP - 1.25, Y_LINTEAU + 0.1, s * 1)
		rondin(modeleLianes, "Feston" .. ((s < 0) and "N" or "S") .. "1", a, bas, 0.24, TIGE, Mat.Grass, { ombre = false })
		rondin(modeleLianes, "Feston" .. ((s < 0) and "N" or "S") .. "2", bas, b, 0.24, TIGE, Mat.Grass, { ombre = false })
		feuille(bas.X, bas.Y - 0.1, bas.Z, 1)
	end

	-- ===== 9. grand titre flottant « 👋 AU REVOIR ! », au-dessus du point le plus haut de la porte =====
	-- (Style.etiquette, lisible de loin et sur mobile) ; bas du titre = sommet réel + MARGE_TITRE
	local lignesTitre = {
		{ texte = "👋 AU REVOIR !", titre = true, taille = 1.5, contour = 4, nom = "Titre" },
		{ texte = "Les dinos invendus partent ici", taille = 0.6, couleur = Style and Style.couleurs.revenu or FLAMME_COEUR, nom = "SousTitre" },
	}
	local HAUTEUR_LIGNE = 3
	local hauteurTitre = (1.5 + 0.6) * HAUTEUR_LIGNE
	local sommet = math.max(yMax, yEnseigne + 2)
	local yTitre = sommet + MARGE_TITRE + hauteurTitre / 2
	local ancreTitre = bloc(modelePorte, "AncreTitre", CFrame.new(XP, yTitre, 0), Vector3.new(0.2, 0.2, 0.2), BRUME, Mat.SmoothPlastic, { invisible = true })
	local support = ancreTitre or enseigne or linteau
	if support and Style then
		pcall(function()
			local _, textes = Style.etiquette(support, lignesTitre, {
				Name = "TitreGrandePorte",
				largeur = 24,
				hauteurLigne = HAUTEUR_LIGNE,
				StudsOffset = (support == ancreTitre) and Vector3.new(0, 0, 0) or Vector3.new(0, yTitre - support.Position.Y, 0),
				MaxDistance = 260,
			})
			if textes and textes[1] then
				local jaune = Style.boutons.jaune
				Style.degrade(textes[1], Color3.new(1, 1, 1), jaune[1])
			end
		end)
	end

	dossier:SetAttribute("Parts", nombre)
end

return M
