-- Constructeur Comptoir : la cabane-boutique d'explorateur, au sud-ouest de la Place (version 2, rendu « pro »).
-- Cabane en rondins (Wood) sur un plancher de WoodPlanks posé sur un socle de pierre, toit de palmes à deux
-- pentes en couches superposées (pignon et enseigne « BOUTIQUE » tournés vers la Place), fenêtres à volets,
-- véranda couverte d'un auvent en Fabric rayé orange et crème à lambrequin festonné, comptoir en bois verni
-- portant l'invite « Boutique » (ouverte côté client), étagères garnies, lanternes à vraie lumière, vitrines
-- rondes des objets de Equilibrage.boutique et un marchand jouet en casque colonial.
-- Emprise (CONTRAT §10) : 26 x 18 autour de Plan.comptoir.centre, ouverte vers +X (la Place).
local M = {}

local BUDGET = 260 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	local dossier = ctx.dossier
	local Style = ctx.Style

	-- emprise : tout vient de Plan.comptoir (plan v2), aucune position écrite en dur
	local infoComptoir = Plan.comptoir
	if not infoComptoir or typeof(infoComptoir.centre) ~= "Vector3" then
		warn("[Dino] Comptoir : Plan.comptoir.centre manquant, boutique non construite")
		return
	end
	local CENTRE = infoComptoir.centre
	local CX, CZ = CENTRE.X, CENTRE.Z
	local SOL = 0.8 -- dessus du plancher

	-- matériaux
	local M_BOIS = Enum.Material.Wood
	local M_PLANCHES = Enum.Material.WoodPlanks
	local M_TISSU = Enum.Material.Fabric
	local M_PALMES = Enum.Material.LeafyGrass
	local M_METAL = Enum.Material.Metal
	local M_VERRE = Enum.Material.Glass
	local M_NEON = Enum.Material.Neon

	-- couleurs (toutes dérivées de la Charte) : trois teintes par couleur
	local BOIS = Charte.bois
	local BOIS_OMBRE = Charte.ombre(Charte.bois)
	local BOIS_CLAIR = Charte.lumiere(Charte.bois)
	local RONDIN_A = Charte.bois:Lerp(Charte.terre, 0.3)
	local RONDIN_B = Charte.bois:Lerp(Charte.terre, 0.1)
	local PLANCHER = Charte.terre:Lerp(Charte.bois, 0.35)
	local VERNIS = Charte.ombre(Charte.bois:Lerp(Charte.lave, 0.18))
	local VERNIS_CLAIR = Charte.bois:Lerp(Charte.lave, 0.22)
	local PIERRE = Charte.lumiere(Charte.pierre)
	local METAL = Charte.encre:Lerp(Charte.pierre, 0.45)
	local SABLE = Charte.sable
	local KAKI = Charte.sable:Lerp(Charte.terre, 0.45)
	local PEAU = Charte.creme:Lerp(Charte.terre, 0.35)
	local CREME = Charte.creme
	local ENCRE = Charte.encre
	local DORE = Charte.dore
	local PALME = Charte.jungle
	local PALME_CLAIRE = Charte.jungle:Lerp(Charte.herbe, 0.55)
	local PALME_OMBRE = Charte.ombre(Charte.jungle)
	local ORANGE = Charte.lave
	local ORANGE_OMBRE = Charte.ombre(Charte.lave)
	local TERRE_CUITE = Charte.terre:Lerp(Charte.lave, 0.3)

	-- ===== outils locaux =====
	local compte = 0

	-- crée une part si le budget le permet ; genre : "bloc", "cylindre", "boule" ou "coin"
	local function piece(parent, genre, nom, taille, cf, couleur, extra)
		if compte >= BUDGET then
			return nil
		end
		local props = { Name = nom, Size = taille, CFrame = cf, Color = couleur }
		if extra then
			for cle, valeur in pairs(extra) do
				props[cle] = valeur
			end
		end
		local p
		if genre == "cylindre" then
			p = Outils.cylindre(parent, props)
		elseif genre == "boule" then
			p = Outils.boule(parent, props)
		elseif genre == "coin" then
			p = Outils.coin(parent, props)
		else
			p = Outils.bloc(parent, props)
		end
		compte = compte + 1
		return p
	end

	-- propriétés : matériau, sans collision si leger vaut true, plus des extras
	local function mat(materiau, leger, extra)
		local t = { Material = materiau }
		if leger then
			t.CanCollide = false
			t.CanQuery = false
			t.CanTouch = false
		end
		if extra then
			for cle, valeur in pairs(extra) do
				t[cle] = valeur
			end
		end
		return t
	end

	local function ecrire(part, face, texte, props)
		if not part then
			return nil
		end
		local ok, etiquette = pcall(Outils.texte, part, face, texte, props)
		if ok then
			return etiquette
		end
		return nil
	end

	-- texte de panneau blanc cerné de noir épais (règle d'or n° 1)
	local function ecrireCerne(part, face, texte, pixelsParStud, epaisseur)
		local couleur = CREME
		if Style then
			couleur = Style.couleurs.texte
		end
		local etiquette = ecrire(part, face, texte, { couleur = couleur, pixelsParStud = pixelsParStud })
		if etiquette and Style then
			Style.contour(etiquette, epaisseur or 4)
			if Style.policeTitre then
				etiquette.Font = Style.policeTitre
			end
		end
		return etiquette
	end

	-- étiquette géante flottante (BillboardGui), seulement si la part existe
	local function flottante(part, lignes, props)
		if not part or not Style then
			return nil, {}
		end
		local ok, gui, textes = pcall(Style.etiquette, part, lignes, props)
		if ok then
			return gui, textes or {}
		end
		return nil, {}
	end

	local function lumiere(part, portee, eclat)
		if not part then
			return
		end
		pcall(function()
			local l = Outils.lumiere(part, { Range = portee, Brightness = eclat, Color = Charte.lumiere(DORE) })
			l.Shadows = true
		end)
	end

	local VERTICAL = CFrame.Angles(0, 0, math.rad(90)) -- axe d'un cylindre à la verticale
	local LE_LONG_DE_Z = CFrame.Angles(0, math.rad(90), 0) -- axe d'un cylindre le long de Z

	-- rondins (cylindres Wood)
	local function rondinX(parent, nom, x0, x1, y, z, diametre, couleur)
		return piece(parent, "cylindre", nom, Vector3.new(x1 - x0, diametre, diametre),
			CFrame.new(CX + (x0 + x1) / 2, y, CZ + z), couleur, mat(M_BOIS))
	end
	local function rondinZ(parent, nom, z0, z1, y, x, diametre, couleur)
		return piece(parent, "cylindre", nom, Vector3.new(z1 - z0, diametre, diametre),
			CFrame.new(CX + x, y, CZ + (z0 + z1) / 2) * LE_LONG_DE_Z, couleur, mat(M_BOIS))
	end
	local function rondinV(parent, nom, x, z, y0, y1, diametre, couleur)
		return piece(parent, "cylindre", nom, Vector3.new(y1 - y0, diametre, diametre),
			CFrame.new(CX + x, (y0 + y1) / 2, CZ + z) * VERTICAL, couleur, mat(M_BOIS))
	end

	-- lanterne suspendue : chaînette, chapeau, verre, flamme lumineuse, culot (5 parts)
	local function lanterne(parent, x, yAccroche, z, longueurChaine)
		local px, pz = CX + x, CZ + z
		local yChapeau = yAccroche - longueurChaine
		piece(parent, "bloc", "Chainette", Vector3.new(0.1, longueurChaine, 0.1),
			CFrame.new(px, yAccroche - longueurChaine / 2, pz), METAL, mat(M_METAL, true))
		piece(parent, "cylindre", "ChapeauLanterne", Vector3.new(0.3, 0.9, 0.9),
			CFrame.new(px, yChapeau - 0.15, pz) * VERTICAL, METAL, mat(M_METAL, true))
		piece(parent, "bloc", "VerreLanterne", Vector3.new(0.7, 0.9, 0.7),
			CFrame.new(px, yChapeau - 0.75, pz), Charte.lumiere(DORE), mat(M_VERRE, true, { Transparency = 0.45 }))
		local flamme = piece(parent, "boule", "Flamme", Vector3.new(0.38, 0.38, 0.38),
			CFrame.new(px, yChapeau - 0.75, pz), DORE, mat(M_NEON, true))
		piece(parent, "cylindre", "CulotLanterne", Vector3.new(0.2, 0.8, 0.8),
			CFrame.new(px, yChapeau - 1.3, pz) * VERTICAL, METAL, mat(M_METAL, true))
		lumiere(flamme, 16, 1.4)
		-- la flamme vacille doucement (animation client, AnimationsDecor)
		if flamme then
			Outils.animer(flamme, "pulse", 2.6)
		end
	end

	-- quelques étincelles dorées, très légères (effet client, rendu seulement de près)
	local function etincelles(part, couleur, debit)
		if not part then
			return
		end
		pcall(function()
			local e = Instance.new("ParticleEmitter")
			e.Name = "Etincelles"
			e.Color = ColorSequence.new(Charte.lumiere(couleur), couleur)
			e.LightEmission = 1
			e.Size = NumberSequence.new(0.22, 0)
			e.Transparency = NumberSequence.new(0.15, 1)
			e.Lifetime = NumberRange.new(1.2, 2)
			e.Rate = debit or 1.5
			e.Speed = NumberRange.new(0.3, 0.8)
			e.SpreadAngle = Vector2.new(180, 180)
			e.Acceleration = Vector3.new(0, 0.6, 0)
			e.Parent = part
		end)
	end

	local cabane = Outils.modele(dossier, "Cabane")
	local modeleComptoir = Outils.modele(dossier, "Comptoir")
	local vitrines = Outils.modele(dossier, "Vitrines")
	local marchand = Outils.modele(dossier, "Marchand")

	-- ===== 1. plancher de planches sur socle de pierre, marches, tapis =====
	local xFondPlancher = -12.6
	local xAvantPlancher = 11
	if compte + 2 <= BUDGET then
		Outils.dalleBordee(cabane, {
			Name = "Plancher",
			Size = Vector3.new(xAvantPlancher - xFondPlancher, SOL, 16.6),
			CFrame = CFrame.new(CX + (xFondPlancher + xAvantPlancher) / 2, SOL / 2, CZ),
			Color = PLANCHER,
			Material = M_PLANCHES,
			MaterialBord = Enum.Material.Cobblestone,
		}, 0.35, PIERRE)
		compte = compte + 2
	end
	-- deux marches face à la Place
	piece(cabane, "bloc", "Marche", Vector3.new(0.8, 0.55, 8), CFrame.new(CX + 11.75, 0.275, CZ), BOIS_CLAIR, mat(M_PLANCHES))
	piece(cabane, "bloc", "Marche", Vector3.new(0.8, 0.3, 8), CFrame.new(CX + 12.55, 0.15, CZ), PLANCHER, mat(M_PLANCHES))
	-- tapis d'accueil devant le comptoir
	piece(cabane, "bloc", "TapisBord", Vector3.new(3.2, 0.06, 6.4), CFrame.new(CX + 9.3, SOL + 0.03, CZ), CREME, mat(M_TISSU, true))
	piece(cabane, "bloc", "Tapis", Vector3.new(2.7, 0.08, 5.9), CFrame.new(CX + 9.3, SOL + 0.05, CZ), ORANGE, mat(M_TISSU, true))

	-- ===== 2. murs de rondins =====
	local D = 1.2 -- diamètre des rondins
	local NIVEAUX = 7
	local xMurFond = -12
	local zMur = 7.6
	local xFacade = -1.8
	local function yNiveau(k)
		return SOL + D / 2 + k * D
	end
	local yHautMur = SOL + NIVEAUX * D -- 9.2
	-- mur du fond : rondins couchés le long de Z, qui dépassent aux angles
	for k = 0, NIVEAUX - 1 do
		local couleur = RONDIN_A
		if k % 2 == 1 then
			couleur = RONDIN_B
		end
		rondinZ(cabane, "RondinFond", -8.6, 8.6, yNiveau(k), xMurFond, D, couleur)
	end
	-- murs latéraux : rondins le long de X, avec une fenêtre au milieu (niveaux 3 à 5)
	local xFenetre0, xFenetre1 = -9.2, -5.6
	for _, signe in ipairs({ -1, 1 }) do
		local z = signe * zMur
		for k = 0, NIVEAUX - 1 do
			local couleur = RONDIN_B
			if k % 2 == 1 then
				couleur = RONDIN_A
			end
			if k >= 3 and k <= 5 then
				rondinX(cabane, "RondinCote", -13, xFenetre0, yNiveau(k), z, D, couleur)
				rondinX(cabane, "RondinCote", xFenetre1, xFacade + 0.3, yNiveau(k), z, D, couleur)
			else
				rondinX(cabane, "RondinCote", -13, xFacade + 0.3, yNiveau(k), z, D, couleur)
			end
		end
		-- appui de fenêtre et volets orange ouverts contre le mur
		local ySeuil = yNiveau(3) - D / 2
		piece(cabane, "bloc", "Appui", Vector3.new(xFenetre1 - xFenetre0 + 0.6, 0.25, 1.7),
			CFrame.new(CX + (xFenetre0 + xFenetre1) / 2, ySeuil + 0.12, CZ + z), BOIS_CLAIR, mat(M_PLANCHES))
		local hFenetre = 3 * D
		for _, cote in ipairs({ -1, 1 }) do
			local xBord = xFenetre0
			if cote == 1 then
				xBord = xFenetre1
			end
			piece(cabane, "bloc", "Volet", Vector3.new(1.4, hFenetre - 0.2, 0.15),
				CFrame.new(CX + xBord + cote * 0.8, ySeuil + hFenetre / 2, CZ + signe * (zMur + D / 2 + 0.2))
					* CFrame.Angles(0, math.rad(12 * cote * signe), 0),
				ORANGE_OMBRE, mat(M_PLANCHES, true))
		end
	end
	-- jardinière fleurie sous la fenêtre sud
	local yJardiniere = yNiveau(3) - D / 2 - 0.45
	piece(cabane, "bloc", "Jardiniere", Vector3.new(3.4, 0.7, 0.7),
		CFrame.new(CX + (xFenetre0 + xFenetre1) / 2, yJardiniere, CZ + zMur + D / 2 + 0.35), BOIS_OMBRE, mat(M_PLANCHES, true))
	piece(cabane, "boule", "Fleurs", Vector3.new(1, 1, 1),
		CFrame.new(CX + xFenetre0 + 1, yJardiniere + 0.45, CZ + zMur + D / 2 + 0.35), Charte.alerte, mat(Enum.Material.Grass, true))
	piece(cabane, "boule", "Fleurs", Vector3.new(1, 1, 1),
		CFrame.new(CX + xFenetre1 - 1, yJardiniere + 0.45, CZ + zMur + D / 2 + 0.35), DORE, mat(Enum.Material.Grass, true))
	-- façade : deux poteaux d'angle et une poutre de linteau
	for _, signe in ipairs({ -1, 1 }) do
		rondinV(cabane, "PoteauFacade", xFacade, signe * zMur, SOL, yHautMur, D, RONDIN_B)
	end
	rondinZ(cabane, "Linteau", -8.6, 8.6, yNiveau(NIVEAUX - 1), xFacade, D, RONDIN_A)

	-- ===== 3. toit de palmes à deux pentes, en couches =====
	local PENTE = math.rad(35)
	local tanPente = math.tan(PENTE)
	local yFaitage = yHautMur + 0.05 + zMur * tanPente -- ligne de faîtage (dessous des palmes)
	local DEBORD = 8.9 -- demi-largeur du toit (bord de l'emprise)
	local longueurPente = DEBORD / math.cos(PENTE)
	local xToit0, xToit1 = -13, -0.6
	local longueurToit = xToit1 - xToit0
	local xToit = CX + (xToit0 + xToit1) / 2
	local ORIGINE_TOIT = CFrame.new(xToit, yFaitage, CZ)
	local COUCHES = 4
	local couleursCouches = { PALME_CLAIRE, PALME, PALME_CLAIRE:Lerp(PALME, 0.5), PALME_OMBRE }
	for _, signe in ipairs({ -1, 1 }) do
		local incline = ORIGINE_TOIT * CFrame.Angles(signe * PENTE, 0, 0)
		for i = 1, COUCHES do
			-- les couches du haut recouvrent celles du bas (comme des bardeaux)
			local bas = i * longueurPente / COUCHES - 0.3
			local hautCouche = (i - 1) * longueurPente / COUCHES - 0.9
			local s = (bas + hautCouche) / 2
			local h = 0.35 + (COUCHES - i) * 0.16
			piece(cabane, "bloc", "Palmes", Vector3.new(longueurToit, 0.7, bas - hautCouche),
				incline * CFrame.new(0, h, signe * s), couleursCouches[i], mat(M_PALMES))
			-- frange effilée qui retombe sous le bord de la couche
			piece(cabane, "bloc", "Frange", Vector3.new(longueurToit + 0.1, 0.16, 0.9),
				incline * CFrame.new(0, h - 0.12, signe * (bas - 0.25)) * CFrame.Angles(signe * math.rad(32), 0, 0) * CFrame.new(0, 0, signe * 0.4),
				Charte.ombre(couleursCouches[i]), mat(M_PALMES, true))
		end
		-- planche de rive le long du pignon avant
		piece(cabane, "bloc", "Rive", Vector3.new(0.3, 0.7, longueurPente),
			incline * CFrame.new(longueurToit / 2 + 0.1, 0.1, signe * (longueurPente / 2 - 0.2)), BOIS_OMBRE, mat(M_BOIS, true))
	end
	-- faîtage en rondin et palmes croisées en crête
	local yCrete = yFaitage + 1.05
	rondinX(cabane, "Faitage", xToit0, xToit1 + 0.2, yCrete, 0, 0.9, BOIS_OMBRE)
	for _, dx in ipairs({ xToit0 + 1.4, xToit1 - 1.4 }) do
		for _, signe in ipairs({ -1, 1 }) do
			piece(cabane, "bloc", "Crete", Vector3.new(1.6, 0.14, 3.2),
				CFrame.new(CX + dx, yCrete + 0.55, CZ) * CFrame.Angles(signe * math.rad(55), 0, 0) * CFrame.new(0, 0, signe * 0.9),
				PALME_OMBRE, mat(M_PALMES, true))
		end
	end
	-- pignons en planches (avant et arrière)
	local hPignon = yFaitage - yHautMur - 0.1
	local demiPignon = hPignon / tanPente
	for _, x in ipairs({ xFacade, xMurFond }) do
		piece(cabane, "coin", "Pignon", Vector3.new(0.4, hPignon, demiPignon),
			CFrame.new(CX + x, yHautMur + hPignon / 2, CZ - demiPignon / 2), BOIS_CLAIR, mat(M_PLANCHES))
		piece(cabane, "coin", "Pignon", Vector3.new(0.4, hPignon, demiPignon),
			CFrame.new(CX + x, yHautMur + hPignon / 2, CZ + demiPignon / 2) * CFrame.Angles(0, math.pi, 0), BOIS_CLAIR, mat(M_PLANCHES))
	end

	-- ===== 4. véranda : auvent rayé orange et crème =====
	local xA0, yA0 = -1.2, yHautMur
	local xA1, yA1 = 10.9, 7.6
	local portee = xA1 - xA0
	local chute = yA0 - yA1
	local angle = math.atan(chute / portee)
	local longueurAuvent = math.sqrt(portee * portee + chute * chute)
	local BANDES = 10
	local largeurBande = 17 / BANDES
	for j = 1, BANDES do
		local z = CZ - 8.5 + (j - 0.5) * largeurBande
		local couleur = ORANGE
		if j % 2 == 0 then
			couleur = CREME
		end
		piece(cabane, "bloc", "Auvent", Vector3.new(longueurAuvent + 0.1, 0.2, largeurBande + 0.02),
			CFrame.new(CX + (xA0 + xA1) / 2, (yA0 + yA1) / 2 + 0.1, z) * CFrame.Angles(0, 0, -angle), couleur, mat(M_TISSU, true))
		-- lambrequin festonné : bande droite et feston arrondi de la même couleur
		piece(cabane, "bloc", "Lambrequin", Vector3.new(0.12, 0.85, largeurBande),
			CFrame.new(CX + xA1 + 0.05, yA1 - 0.42, z), couleur, mat(M_TISSU, true))
		piece(cabane, "cylindre", "Feston", Vector3.new(0.1, largeurBande, largeurBande),
			CFrame.new(CX + xA1 + 0.04, yA1 - 0.85, z), couleur, mat(M_TISSU, true))
	end
	-- poteaux, poutre avant et jambes de force
	local xPoteau = 10.5
	local yPoutre = yA1 - 0.35
	rondinZ(cabane, "PoutreAvant", -8.7, 8.7, yPoutre, xPoteau + 0.1, 0.6, RONDIN_A)
	for _, signe in ipairs({ -1, 1 }) do
		rondinV(cabane, "PoteauAvant", xPoteau, signe * 8.15, SOL, yPoutre, 0.7, RONDIN_B)
		piece(cabane, "cylindre", "JambeDeForce", Vector3.new(1.9, 0.35, 0.35),
			CFrame.new(CX + xPoteau, yPoutre - 0.65, CZ + signe * 7.5) * CFrame.Angles(signe * math.rad(45), 0, 0) * LE_LONG_DE_Z,
			BOIS_OMBRE, mat(M_BOIS, true))
	end

	-- ===== 5. enseigne « BOUTIQUE » sur le pignon, tournée vers la Place =====
	local ySigne = yHautMur + 1.35
	piece(cabane, "bloc", "CadreEnseigne", Vector3.new(0.3, 2.6, 8.6), CFrame.new(CX + xFacade + 0.55, ySigne, CZ), BOIS_OMBRE, mat(M_BOIS))
	local planche = piece(cabane, "bloc", "Enseigne", Vector3.new(0.15, 2.1, 8), CFrame.new(CX + xFacade + 0.77, ySigne, CZ), ORANGE, mat(M_PLANCHES))
	ecrireCerne(planche, "Right", "🛒 BOUTIQUE", 40, 5)
	-- titre flottant géant, lisible depuis toute la Place
	local _, titres = flottante(planche, {
		{ texte = "🛒 BOUTIQUE", titre = true, taille = 1.7, contour = 4, nom = "Titre" },
		{ texte = "Objets d'explorateur", taille = 0.8, contour = 3, nom = "SousTitre", couleur = Style and Style.couleurs.revenu or DORE },
	}, {
		Name = "TitreBoutique",
		largeur = 24,
		hauteurLigne = 2.6,
		StudsOffset = Vector3.new(0, 7, 0),
		MaxDistance = 260,
	})
	if titres[1] and Style then
		-- dégradé jaune -> orange sur le titre blanc
		Style.degrade(titres[1], Style.boutons.jaune[1], Style.boutons.orange[2])
	end
	-- os croisés aux coins de l'enseigne
	for _, signe in ipairs({ -1, 1 }) do
		piece(cabane, "bloc", "Os", Vector3.new(0.2, 0.45, 1.8),
			CFrame.new(CX + xFacade + 0.85, ySigne + 1.2, CZ + signe * 4.2) * CFrame.Angles(math.rad(35 * signe), 0, 0), CREME, mat(Enum.Material.SmoothPlastic, true))
	end

	-- ===== 6. le comptoir en bois verni et son invite =====
	local xComptoir = 5.8
	local hCaisson = 3.05
	piece(modeleComptoir, "bloc", "Plinthe", Vector3.new(2.5, 0.35, 8.8), CFrame.new(CX + xComptoir, SOL + 0.175, CZ), BOIS_OMBRE, mat(M_PLANCHES))
	if compte + 6 <= BUDGET then
		Outils.blocArrondi(modeleComptoir, {
			Name = "Caisson",
			Size = Vector3.new(2.2, hCaisson, 8.4),
			CFrame = CFrame.new(CX + xComptoir, SOL + 0.35 + hCaisson / 2, CZ),
			Color = VERNIS,
			Material = M_PLANCHES,
			Reflectance = 0.04,
		}, 0.45)
		compte = compte + 6
	end
	local yPlateau = SOL + 0.35 + hCaisson + 0.35
	local partComptoir = piece(modeleComptoir, "bloc", "Plateau", Vector3.new(3, 0.35, 9.2),
		CFrame.new(CX + xComptoir, yPlateau - 0.175, CZ), VERNIS_CLAIR, mat(M_BOIS, false, { Reflectance = 0.12 }))
	local plaque = piece(modeleComptoir, "bloc", "Plaque", Vector3.new(0.14, 1.3, 5.6),
		CFrame.new(CX + xComptoir + 1.17, SOL + 2.1, CZ), ORANGE_OMBRE, mat(M_PLANCHES, true))
	ecrireCerne(plaque, "Right", "OBJETS D'EXPLORATEUR", 30, 3)
	-- caisse enregistreuse en laiton, clochette, grand livre et pépite
	piece(modeleComptoir, "bloc", "CaisseEnregistreuse", Vector3.new(1.2, 0.8, 1.4),
		CFrame.new(CX + xComptoir - 0.3, yPlateau + 0.4, CZ + 2.8), DORE, mat(M_METAL, true, { Reflectance = 0.15 }))
	piece(modeleComptoir, "coin", "Clavier", Vector3.new(1.2, 0.4, 0.9),
		CFrame.new(CX + xComptoir - 0.3, yPlateau + 1, CZ + 2.8) * CFrame.Angles(0, math.rad(-90), 0), CREME, mat(Enum.Material.SmoothPlastic, true))
	piece(modeleComptoir, "cylindre", "SocleClochette", Vector3.new(0.12, 0.7, 0.7),
		CFrame.new(CX + xComptoir + 0.6, yPlateau + 0.06, CZ - 2.6) * VERTICAL, BOIS_OMBRE, mat(M_BOIS, true))
	piece(modeleComptoir, "boule", "Clochette", Vector3.new(0.6, 0.6, 0.6),
		CFrame.new(CX + xComptoir + 0.6, yPlateau + 0.3, CZ - 2.6), DORE, mat(M_METAL, true, { Reflectance = 0.2 }))
	piece(modeleComptoir, "bloc", "GrandLivre", Vector3.new(1.1, 0.18, 1.6),
		CFrame.new(CX + xComptoir + 0.2, yPlateau + 0.09, CZ - 0.6) * CFrame.Angles(0, math.rad(-10), 0), CREME, mat(Enum.Material.SmoothPlastic, true))
	local pepite = piece(modeleComptoir, "boule", "Pepite", Vector3.new(0.5, 0.5, 0.5),
		CFrame.new(CX + xComptoir + 0.3, yPlateau + 0.25, CZ + 0.9), Charte.gemme, mat(M_VERRE, true, { Transparency = 0.15 }))
	etincelles(pepite, Charte.gemme, 1)
	if partComptoir then
		partComptoir.Name = "Comptoir"
		Outils.invite(partComptoir, { nom = "Boutique", action = "Acheter", objet = "Boutique", distance = 12 })
	end

	-- ===== 7. vitrines rondes des objets de la boutique =====
	local boutique = E.boutique or {}
	local ORDRE = { "Bottes", "BatteOr", "Aimant", "Radar" }
	local NOMS_DEFAUT = { Bottes = "Bottes de course", BatteOr = "Batte dorée", Aimant = "Aimant à billets", Radar = "Radar à dinos" }
	local liste = {}
	for _, cle in ipairs(ORDRE) do
		if boutique[cle] ~= nil or next(boutique) == nil then
			table.insert(liste, cle)
		end
	end
	-- objets ajoutés plus tard à Equilibrage.boutique (s'il reste des places)
	local autres = {}
	for cle in pairs(boutique) do
		if NOMS_DEFAUT[cle] == nil then
			table.insert(autres, cle)
		end
	end
	table.sort(autres)
	for _, cle in ipairs(autres) do
		table.insert(liste, cle)
	end

	-- maquette d'un objet, centrée en `centre` (CFrame regardant vers +X)
	local function maquette(parent, cle, centre)
		local function morceau(genre, nom, taille, decalage, couleur, materiau, extra)
			return piece(parent, genre, nom, taille, centre * decalage, couleur, mat(materiau or Enum.Material.SmoothPlastic, true, extra))
		end
		if cle == "Bottes" then
			for _, dz in ipairs({ -0.35, 0.35 }) do
				morceau("bloc", "Tige", Vector3.new(0.5, 0.9, 0.5), CFrame.new(-0.15, 0.15, dz), Charte.lave, M_TISSU)
				morceau("bloc", "Pied", Vector3.new(1, 0.4, 0.5), CFrame.new(0.1, -0.45, dz), BOIS_OMBRE)
				morceau("bloc", "Aile", Vector3.new(0.4, 0.35, 0.1), CFrame.new(-0.35, 0.35, dz * 1.9) * CFrame.Angles(0, 0, math.rad(25)), DORE, M_METAL)
			end
		elseif cle == "BatteOr" then
			local incline = CFrame.Angles(0, 0, math.rad(65))
			morceau("cylindre", "Manche", Vector3.new(1, 0.25, 0.25), incline * CFrame.new(-0.8, 0, 0), BOIS_OMBRE, M_BOIS)
			morceau("cylindre", "Batte", Vector3.new(1.4, 0.5, 0.5), incline * CFrame.new(0.35, 0, 0), DORE, M_METAL, { Reflectance = 0.25 })
			morceau("boule", "Pommeau", Vector3.new(0.35, 0.35, 0.35), incline * CFrame.new(-1.3, 0, 0), BOIS_OMBRE, M_BOIS)
		elseif cle == "Aimant" then
			for _, dz in ipairs({ -0.45, 0.45 }) do
				morceau("bloc", "Branche", Vector3.new(0.4, 1, 0.4), CFrame.new(0, 0.05, dz), Charte.alerte)
				morceau("bloc", "Pointe", Vector3.new(0.42, 0.3, 0.42), CFrame.new(0, 0.7, dz), CREME, M_METAL)
			end
			morceau("bloc", "Arc", Vector3.new(0.4, 0.4, 1.3), CFrame.new(0, -0.6, 0), Charte.alerte)
		elseif cle == "Radar" then
			morceau("bloc", "Socle", Vector3.new(0.9, 0.3, 0.9), CFrame.new(0, -0.75, 0), METAL, M_METAL)
			morceau("bloc", "Mat", Vector3.new(0.2, 0.7, 0.2), CFrame.new(0, -0.3, 0), METAL, M_METAL)
			morceau("cylindre", "Parabole", Vector3.new(0.15, 1.3, 1.3), CFrame.new(0.1, 0.25, 0) * CFrame.Angles(0, 0, math.rad(40)), CREME)
			morceau("boule", "Capteur", Vector3.new(0.35, 0.35, 0.35), CFrame.new(0.4, 0.55, 0), Charte.gemme, M_NEON)
		else
			morceau("boule", "Gemme", Vector3.new(0.9, 0.9, 0.9), CFrame.new(0, 0, 0), Charte.gemme, M_VERRE)
		end
	end

	local xVitrine = CX + 8.6
	local positionsZ = { CZ - 7.4, CZ - 4.4, CZ + 4.4, CZ + 7.4 } -- 3 studs entre deux vitrines
	for i, cle in ipairs(liste) do
		local z = positionsZ[i]
		if z == nil then
			break
		end
		local infos = boutique[cle]
		if type(infos) ~= "table" then
			infos = {}
		end
		local vitrine = Outils.modele(vitrines, "Vitrine_" .. tostring(cle))
		vitrine:SetAttribute("Objet", tostring(cle))
		local hSocle = 2.4
		piece(vitrine, "cylindre", "Socle", Vector3.new(hSocle, 2, 2), CFrame.new(xVitrine, SOL + hSocle / 2, z) * VERTICAL, VERNIS, mat(M_PLANCHES))
		piece(vitrine, "cylindre", "Lisere", Vector3.new(0.25, 2.3, 2.3), CFrame.new(xVitrine, SOL + hSocle + 0.12, z) * VERTICAL, DORE, mat(M_METAL, false, { Reflectance = 0.15 }))
		local yVerre = SOL + hSocle + 0.25
		piece(vitrine, "cylindre", "Verre", Vector3.new(2.1, 1.9, 1.9), CFrame.new(xVitrine, yVerre + 1.05, z) * VERTICAL,
			Charte.lumiere(Charte.gemme), mat(M_VERRE, false, { Transparency = 0.7 }))
		local chapeau = piece(vitrine, "cylindre", "Chapeau", Vector3.new(0.25, 2.2, 2.2), CFrame.new(xVitrine, yVerre + 2.2, z) * VERTICAL,
			DORE, mat(M_METAL, false, { Reflectance = 0.15 }))
		-- étiquette : nom et prix, lisible depuis la Place
		local etiquette = piece(vitrine, "bloc", "Etiquette", Vector3.new(0.12, 1.1, 1.5), CFrame.new(xVitrine + 1.02, SOL + 1.3, z), ORANGE_OMBRE, mat(M_PLANCHES, true))
		local nom = infos.nom
		if type(nom) ~= "string" then
			nom = NOMS_DEFAUT[cle] or tostring(cle)
		end
		local texte = nom
		local lignes = { { texte = nom, taille = 1, nom = "Nom" } }
		if type(infos.prix) == "number" then
			texte = nom .. "\n" .. Charte.argent(infos.prix)
			local vert = DORE
			if Style then
				vert = Style.couleurs.argent
			end
			table.insert(lignes, { texte = Charte.argent(infos.prix), taille = 1.1, nom = "Prix", couleur = vert })
		end
		ecrireCerne(etiquette, "Right", texte, 40, 3)
		-- petite étiquette (nom blanc, prix vert) juste au-dessus du chapeau, sous la toile de l'auvent :
		-- 2,3 studs de large pour 3 studs entre vitrines, donc jamais de chevauchement
		flottante(chapeau, lignes, {
			Name = "EtiquetteObjet",
			largeur = 2.3,
			hauteurLigne = 0.55,
			StudsOffset = Vector3.new(0, 1.0, 0),
			MaxDistance = 40,
		})
		-- la maquette, qui tourne doucement dans son verre
		local objet = Outils.modele(vitrine, "Maquette")
		local centre = CFrame.new(xVitrine, yVerre + 1.05, z)
		maquette(objet, cle, centre)
		pcall(function()
			objet.WorldPivot = centre
		end)
		Outils.animer(objet, "tourne", 0.6)
		-- scintillement discret autour de l'objet exposé
		etincelles(chapeau, DORE, 1.2)
	end

	-- ===== 8. le marchand jouet (regard vers +X) =====
	local xM = CX + 3
	local zM = CZ
	local yJambes = SOL
	local TISSU = mat(M_TISSU, true)
	local LISSE = mat(Enum.Material.SmoothPlastic, true)
	for _, signe in ipairs({ -1, 1 }) do
		piece(marchand, "bloc", "Jambe", Vector3.new(0.8, 1.8, 0.8), CFrame.new(xM, yJambes + 0.9, zM + signe * 0.5), KAKI, TISSU)
		piece(marchand, "bloc", "Botte", Vector3.new(1.1, 0.5, 0.9), CFrame.new(xM + 0.15, yJambes + 0.25, zM + signe * 0.5), BOIS_OMBRE, LISSE)
	end
	local yTorse = yJambes + 1.8
	piece(marchand, "bloc", "Torse", Vector3.new(1.2, 2.2, 2.2), CFrame.new(xM, yTorse + 1.1, zM), SABLE, TISSU)
	piece(marchand, "bloc", "Ceinture", Vector3.new(1.3, 0.3, 2.3), CFrame.new(xM, yTorse + 0.25, zM), BOIS, LISSE)
	piece(marchand, "bloc", "Foulard", Vector3.new(1.3, 0.4, 1.5), CFrame.new(xM + 0.05, yTorse + 2.05, zM), Charte.lave, TISSU)
	-- bras posés sur le comptoir
	local xMain = CX + xComptoir - 0.6
	local longueurBras = xMain - xM
	for _, signe in ipairs({ -1, 1 }) do
		piece(marchand, "bloc", "Bras", Vector3.new(longueurBras, 0.6, 0.6),
			CFrame.new(xM + longueurBras / 2, yPlateau + 0.25, zM + signe * 1.4), SABLE, TISSU)
		piece(marchand, "bloc", "Main", Vector3.new(0.6, 0.6, 0.6), CFrame.new(xMain + 0.1, yPlateau + 0.3, zM + signe * 1.4), PEAU, LISSE)
	end
	-- tête
	local yTete = yTorse + 2.2 + 0.8
	piece(marchand, "bloc", "Tete", Vector3.new(1.6, 1.6, 1.6), CFrame.new(xM, yTete, zM), PEAU, LISSE)
	for _, signe in ipairs({ -1, 1 }) do
		piece(marchand, "bloc", "Oeil", Vector3.new(0.1, 0.35, 0.25), CFrame.new(xM + 0.81, yTete + 0.2, zM + signe * 0.35), ENCRE, LISSE)
	end
	piece(marchand, "bloc", "Moustache", Vector3.new(0.15, 0.25, 1), CFrame.new(xM + 0.82, yTete - 0.3, zM), BOIS_OMBRE, LISSE)
	-- casque colonial
	local yCasque = yTete + 0.8
	piece(marchand, "cylindre", "Bord", Vector3.new(0.15, 2.8, 2.8), CFrame.new(xM, yCasque + 0.05, zM) * VERTICAL, Charte.lumiere(SABLE), LISSE)
	piece(marchand, "cylindre", "Bandeau", Vector3.new(0.35, 1.82, 1.82), CFrame.new(xM, yCasque + 0.3, zM) * VERTICAL, BOIS, LISSE)
	piece(marchand, "boule", "Calotte", Vector3.new(1.8, 1.8, 1.8), CFrame.new(xM, yCasque + 0.35, zM), SABLE, LISSE)
	piece(marchand, "boule", "Bouton", Vector3.new(0.35, 0.35, 0.35), CFrame.new(xM, yCasque + 1.25, zM), CREME, LISSE)

	-- ===== 9. lanternes : deux sous l'auvent, une sous le faîtage =====
	for _, signe in ipairs({ -1, 1 }) do
		lanterne(cabane, xPoteau + 0.1, yPoutre - 0.3, signe * 5.3, 0.5)
	end
	lanterne(cabane, -7, yFaitage - 0.2, 0, 2.6)

	-- ===== 10. étagères du fond garnies =====
	local xEtagere = xMurFond + 1.25
	for _, signe in ipairs({ -1, 1 }) do
		piece(cabane, "bloc", "Montant", Vector3.new(1.3, 7, 0.3), CFrame.new(CX + xEtagere, SOL + 3.5, CZ + signe * 5.3), BOIS_OMBRE, mat(M_PLANCHES))
	end
	local couleursObjets = { Charte.gemme, Charte.violet, DORE, Charte.lave, PALME_CLAIRE, Charte.alerte }
	for n, hEtagere in ipairs({ 1.1, 3.4, 5.7 }) do
		local yE = SOL + hEtagere
		piece(cabane, "bloc", "Etagere", Vector3.new(1.3, 0.22, 10.9), CFrame.new(CX + xEtagere, yE, CZ), BOIS_CLAIR, mat(M_PLANCHES))
		for k = 0, 3 do
			local z = CZ - 3.6 + k * 2.4
			local couleur = couleursObjets[((k + 2 * n) % #couleursObjets) + 1]
			local genre = (k + n) % 4
			if genre == 0 then
				-- bocal de verre coloré
				piece(cabane, "cylindre", "Bocal", Vector3.new(1.1, 0.9, 0.9),
					CFrame.new(CX + xEtagere, yE + 0.66, z) * VERTICAL, couleur, mat(M_VERRE, true, { Transparency = 0.3 }))
			elseif genre == 1 then
				-- pile de livres
				piece(cabane, "bloc", "Livres", Vector3.new(0.9, 1.1, 1.3),
					CFrame.new(CX + xEtagere, yE + 0.66, z), couleur, mat(M_TISSU, true))
			elseif genre == 2 then
				-- carte roulée
				piece(cabane, "cylindre", "Carte", Vector3.new(1.8, 0.5, 0.5),
					CFrame.new(CX + xEtagere, yE + 0.36, z) * LE_LONG_DE_Z, SABLE, mat(M_TISSU, true))
			else
				-- boîte en bois
				piece(cabane, "bloc", "Boite", Vector3.new(0.9, 0.8, 1.1),
					CFrame.new(CX + xEtagere, yE + 0.51, z) * CFrame.Angles(0, math.rad(10), 0), BOIS, mat(M_PLANCHES, true))
			end
		end
	end

	-- ===== 11. caisses et tonneaux dans les coins de la cabane =====
	piece(cabane, "bloc", "Caisse", Vector3.new(2, 2, 2), CFrame.new(CX - 3.7, SOL + 1, CZ - 5.9), BOIS_CLAIR, mat(M_PLANCHES))
	piece(cabane, "bloc", "Caisse", Vector3.new(1.4, 1.4, 1.4),
		CFrame.new(CX - 3.7, SOL + 2.7, CZ - 5.9) * CFrame.Angles(0, math.rad(20), 0), BOIS, mat(M_PLANCHES))
	piece(cabane, "bloc", "Caisse", Vector3.new(1.6, 1.6, 1.6),
		CFrame.new(CX - 5.9, SOL + 0.8, CZ - 6.1) * CFrame.Angles(0, math.rad(-12), 0), PLANCHER, mat(M_PLANCHES))
	for _, dx in ipairs({ -3.5, -5.3 }) do
		piece(cabane, "cylindre", "Tonneau", Vector3.new(2.2, 1.6, 1.6),
			CFrame.new(CX + dx, SOL + 1.1, CZ + 6.1) * VERTICAL, RONDIN_A, mat(M_BOIS))
		piece(cabane, "cylindre", "Cerclage", Vector3.new(0.22, 1.7, 1.7),
			CFrame.new(CX + dx, SOL + 1.55, CZ + 6.1) * VERTICAL, METAL, mat(M_METAL, true))
	end

	-- ===== 12. palmiers en pot de part et d'autre des marches =====
	for _, signe in ipairs({ -1, 1 }) do
		local px, pz = CX + 12.3, CZ + signe * 5.8
		piece(cabane, "cylindre", "Pot", Vector3.new(1.1, 1.1, 1.1), CFrame.new(px, 0.55, pz) * VERTICAL, TERRE_CUITE, mat(Enum.Material.Concrete, true))
		piece(cabane, "boule", "Buisson", Vector3.new(1.5, 1.5, 1.5), CFrame.new(px, 1.45, pz), PALME, mat(M_PALMES, true))
		local haut = CFrame.new(px, 1.8, pz)
		for f, lacet in ipairs({ 90, -90 }) do
			local couleur = PALME_CLAIRE
			if f == 2 then
				couleur = PALME_CLAIRE:Lerp(PALME, 0.4)
			end
			piece(cabane, "bloc", "Fronde", Vector3.new(1.9, 0.12, 0.8),
				haut * CFrame.Angles(0, math.rad(lacet + 25), 0) * CFrame.Angles(0, 0, math.rad(40)) * CFrame.new(0.7, 0, 0),
				couleur, mat(M_PALMES, true))
		end
	end

	-- ===== 13. pioche et pelle croisées sur le mur sud, près de la façade =====
	local zTrophee = CZ + zMur + D / 2 + 0.15
	local centreTrophee = CFrame.new(CX - 2.7, SOL + 5.2, zTrophee)
	for _, signe in ipairs({ -1, 1 }) do
		piece(cabane, "cylindre", "Manche", Vector3.new(2.6, 0.22, 0.22),
			centreTrophee * CFrame.Angles(0, 0, math.rad(45 * signe)), BOIS_CLAIR, mat(M_BOIS, true))
	end
	piece(cabane, "bloc", "Pioche", Vector3.new(1.9, 0.3, 0.2),
		centreTrophee * CFrame.Angles(0, 0, math.rad(45)) * CFrame.new(1.2, 0, 0) * CFrame.Angles(0, 0, math.rad(90)), METAL, mat(M_METAL, true))
	piece(cabane, "bloc", "Pelle", Vector3.new(0.9, 0.8, 0.15),
		centreTrophee * CFrame.Angles(0, 0, math.rad(-45)) * CFrame.new(-1.3, 0, 0), METAL, mat(M_METAL, true))

	dossier:SetAttribute("Parts", compte)
end

return M
