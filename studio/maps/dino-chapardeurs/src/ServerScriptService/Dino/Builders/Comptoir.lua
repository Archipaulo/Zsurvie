-- Constructeur Comptoir : la cabane-boutique d'explorateur, au sud-ouest de la Place.
-- Plancher de bois, mur du fond en rondins, toit de palmes en pente vers la Place, enseigne « BOUTIQUE »,
-- comptoir portant l'invite « Boutique » (ouverte côté client), vitrines des objets de Equilibrage.boutique
-- en maquettes de blocs, et un marchand jouet en casque colonial.
-- Look « simulateur » (STYLE.md) : cabane cartoon orange et jaune vif, auvent rayé, titre flottant géant
-- « 🛒 BOUTIQUE » cerné de noir (Style.etiquette), nom et prix de chaque vitrine en étiquette flottante.
-- Emprise (CONTRAT §10) : 26 x 18 autour de Plan.comptoir.centre, ouverte vers +X (la Place).
local M = {}

local BUDGET = 250 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	local dossier = ctx.dossier

	-- emprise
	local infoComptoir = Plan.comptoir or {}
	local CENTRE = infoComptoir.centre or Vector3.new(-50, 0, 104)
	local CX, CZ = CENTRE.X, CENTRE.Z
	local DEMI_X = 13 -- 26 / 2
	local DEMI_Z = 9  -- 18 / 2
	local SOL = 0.6    -- dessus du plancher

	-- couleurs (toutes dérivées de la Charte)
	local BOIS = Charte.bois
	local BOIS_OMBRE = Charte.ombre(Charte.bois)
	local BOIS_CLAIR = Charte.lumiere(Charte.bois)
	local SABLE = Charte.sable
	local KAKI = Charte.sable:Lerp(Charte.terre, 0.45)
	local PEAU = Charte.creme:Lerp(Charte.terre, 0.35)
	local CREME = Charte.creme
	local ENCRE = Charte.encre
	local DORE = Charte.dore
	local PALME = Charte.jungle
	local PALME_CLAIRE = Charte.herbe
	local PALME_OMBRE = Charte.ombre(Charte.jungle)
	-- couleurs cartoon de la boutique (orange = boutique, jaune = argent)
	local ORANGE = Charte.lave
	local ORANGE_OMBRE = Charte.ombre(Charte.lave)
	local JAUNE = Charte.dore
	local JAUNE_CLAIR = Charte.lumiere(Charte.dore)

	local Style = ctx.Style

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

	-- décor sans collision (petits objets)
	local LEGER = { CanCollide = false, CanQuery = false, CanTouch = false }
	local function leger(extra)
		local t = { CanCollide = false, CanQuery = false, CanTouch = false }
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

	local VERTICAL = CFrame.Angles(0, 0, math.rad(90)) -- oriente l'axe d'un cylindre à la verticale

	local cabane = Outils.modele(dossier, "Cabane")
	local modeleComptoir = Outils.modele(dossier, "Comptoir")
	local vitrines = Outils.modele(dossier, "Vitrines")
	local marchand = Outils.modele(dossier, "Marchand")

	-- ===== 1. plancher =====
	local xFondPlancher = CX - DEMI_X
	local xAvantPlancher = CX + 11
	local longueurPlancher = xAvantPlancher - xFondPlancher
	piece(cabane, "bloc", "Plancher", Vector3.new(longueurPlancher, SOL, 16),
		CFrame.new((xFondPlancher + xAvantPlancher) / 2, SOL / 2, CZ), BOIS_CLAIR)
	-- lattes
	for i = 1, 5 do
		local x = xFondPlancher + i * longueurPlancher / 6
		piece(cabane, "bloc", "Latte", Vector3.new(0.15, 0.05, 16), CFrame.new(x, SOL + 0.02, CZ), BOIS, LEGER)
	end
	-- marche d'accès face à la Place
	piece(cabane, "bloc", "Marche", Vector3.new(1, 0.3, 7), CFrame.new(xAvantPlancher + 0.5, 0.15, CZ), BOIS)

	-- ===== 2. murs de rondins =====
	-- mur du fond : rondins verticaux
	local xFond = CX - 12.4
	local hauteurFond = 12
	local nbRondins = 13
	for i = 0, nbRondins - 1 do
		local z = CZ - 7.2 + i * 1.2
		local couleur = BOIS
		if i % 2 == 1 then
			couleur = BOIS_OMBRE
		end
		piece(cabane, "cylindre", "RondinFond", Vector3.new(hauteurFond, 1.2, 1.2),
			CFrame.new(xFond, SOL + hauteurFond / 2, z) * VERTICAL, couleur)
	end
	-- murs latéraux : rondins couchés (axe X), à mi-hauteur pour laisser voir l'intérieur
	local xDebutCote = CX - 12
	local xFinCote = CX - 3.6
	local longueurCote = xFinCote - xDebutCote
	for _, signe in ipairs({ -1, 1 }) do
		local z = CZ + signe * 7.4
		for k = 0, 4 do
			local couleur = BOIS
			if k % 2 == 1 then
				couleur = BOIS_OMBRE
			end
			piece(cabane, "cylindre", "RondinCote", Vector3.new(longueurCote, 1.2, 1.2),
				CFrame.new((xDebutCote + xFinCote) / 2, SOL + 0.6 + k * 1.2, z), couleur)
		end
	end

	-- ===== 3. toit de palmes en pente vers la Place =====
	local xToitFond = CX - 12.8
	local xToitAvant = CX + 12.8
	local yToitFond = 13.2
	local yToitAvant = 9.2
	local chute = yToitFond - yToitAvant
	local portee = xToitAvant - xToitFond
	local angle = math.atan(chute / portee)
	local pente = CFrame.Angles(0, 0, -angle)
	local function yToit(x)
		return yToitFond - chute * (x - xToitFond) / portee
	end

	-- poteaux : deux à l'avant (sur le sol), deux au bout des murs latéraux
	local xPoteauAvant = CX + 12
	for _, signe in ipairs({ -1, 1 }) do
		local z = CZ + signe * 8.3
		local h = yToit(xPoteauAvant) - 0.2
		piece(cabane, "bloc", "PoteauAvant", Vector3.new(0.8, h, 0.8), CFrame.new(xPoteauAvant, h / 2, z), ORANGE)
		local hc = yToit(xFinCote) - 0.2 - SOL
		piece(cabane, "bloc", "PoteauCote", Vector3.new(0.8, hc, 0.8), CFrame.new(xFinCote, SOL + hc / 2, CZ + signe * 7.4), ORANGE)
	end
	-- poutre avant
	local yPoutre = yToit(xPoteauAvant) - 0.5
	piece(cabane, "bloc", "PoutreAvant", Vector3.new(0.8, 0.6, 17.2), CFrame.new(xPoteauAvant, yPoutre, CZ), JAUNE)
	-- chevrons sous le toit
	for _, dz in ipairs({ -7.4, 0, 7.4 }) do
		piece(cabane, "bloc", "Chevron", Vector3.new(portee, 0.4, 0.5),
			CFrame.new((xToitFond + xToitAvant) / 2, (yToitFond + yToitAvant) / 2 - 0.45, CZ + dz) * pente, BOIS_OMBRE, LEGER)
	end
	-- auvent rayé orange et jaune (bandes qui se chevauchent)
	local nbBandes = 6
	local longueurPente = math.sqrt(portee * portee + chute * chute)
	local longueurBande = longueurPente / nbBandes * 1.08
	for i = 1, nbBandes do
		local t = (i - 0.5) / nbBandes
		local x = xToitFond + portee * t
		local decalage = 0
		local couleur = ORANGE
		if i % 2 == 0 then
			decalage = 0.15
			couleur = JAUNE_CLAIR
		end
		piece(cabane, "bloc", "Palmes", Vector3.new(longueurBande, 0.6, 2 * DEMI_Z),
			CFrame.new(x, yToit(x) + decalage, CZ) * pente, couleur)
	end
	-- frange festonnée qui pend à l'avant, orange et jaune
	for i = 0, 9 do
		local z = CZ - 8.1 + i * 1.8
		local couleur = JAUNE
		if i % 2 == 1 then
			couleur = ORANGE
		end
		piece(cabane, "bloc", "Frange", Vector3.new(0.2, 1.4, 1.6),
			CFrame.new(xToitAvant - 0.3, yToitAvant - 0.6, z) * CFrame.Angles(0, 0, math.rad(-12)), couleur, LEGER)
	end
	-- palmes en éventail sur le haut du toit
	for i = 0, 3 do
		local z = CZ - 5.4 + i * 3.6
		local sens = 1
		if i % 2 == 1 then
			sens = -1
		end
		piece(cabane, "bloc", "Eventail", Vector3.new(4, 0.25, 1.2),
			CFrame.new(xToitFond + 2.4, yToitFond + 0.7, z) * CFrame.Angles(math.rad(12 * sens), math.rad(25 * sens), math.rad(18)), PALME_CLAIRE, LEGER)
		piece(cabane, "bloc", "Eventail", Vector3.new(3.4, 0.25, 1),
			CFrame.new(xToitFond + 2.2, yToitFond + 0.9, z + 0.6 * sens) * CFrame.Angles(0, math.rad(-35 * sens), math.rad(28)), PALME, LEGER)
	end

	-- ===== 4. enseigne « BOUTIQUE » tournée vers la Place =====
	local ySigne = yToitAvant + 2
	local xSigne = CX + 12.1
	piece(cabane, "bloc", "SupportEnseigne", Vector3.new(0.4, 3.4, 12.6), CFrame.new(xSigne, ySigne, CZ), ORANGE_OMBRE)
	local planche = piece(cabane, "bloc", "Enseigne", Vector3.new(0.15, 2.6, 11.6), CFrame.new(xSigne + 0.27, ySigne, CZ), ORANGE)
	ecrireCerne(planche, "Right", "🛒 BOUTIQUE", 40, 5)
	-- titre flottant géant, lisible depuis toute la Place
	local _, titres = flottante(planche, {
		{ texte = "🛒 BOUTIQUE", titre = true, taille = 1.7, contour = 4, nom = "Titre" },
		{ texte = "Objets d'explorateur", taille = 0.8, contour = 3, nom = "SousTitre", couleur = Style and Style.couleurs.revenu or JAUNE },
	}, {
		Name = "TitreBoutique",
		largeur = 24,
		hauteurLigne = 2.6,
		StudsOffset = Vector3.new(0, 6.5, 0),
		MaxDistance = 260,
	})
	if titres[1] and Style then
		-- dégradé jaune -> orange sur le titre blanc
		Style.degrade(titres[1], Style.boutons.jaune[1], Style.boutons.orange[2])
	end
	-- petits os croisés décoratifs aux coins de l'enseigne
	for _, signe in ipairs({ -1, 1 }) do
		piece(cabane, "bloc", "Os", Vector3.new(0.2, 0.5, 1.8),
			CFrame.new(xSigne + 0.3, ySigne + 1.55, CZ + signe * 6.6) * CFrame.Angles(math.rad(35 * signe), 0, 0), CREME, LEGER)
	end

	-- lanternes suspendues à la poutre avant
	for _, signe in ipairs({ -1, 1 }) do
		local z = CZ + signe * 6
		piece(cabane, "bloc", "Chainette", Vector3.new(0.15, 0.9, 0.15), CFrame.new(xPoteauAvant, yPoutre - 0.75, z), ENCRE, LEGER)
		local lanterne = piece(cabane, "boule", "Lanterne", Vector3.new(0.9, 0.9, 0.9),
			CFrame.new(xPoteauAvant, yPoutre - 1.6, z), DORE, leger({ Material = Enum.Material.Neon }))
		if lanterne then
			pcall(Outils.lumiere, lanterne, { Range = 14, Brightness = 1.2, Color = Charte.lumiere(DORE) })
		end
	end

	-- guirlande de fanions aux couleurs des raretés
	local couleursFanions = {}
	local raretes = Charte.raretes or {}
	for _, cle in ipairs({ "Commun", "Rare", "Epique", "Legendaire", "Mythique", "Divin" }) do
		if raretes[cle] then
			table.insert(couleursFanions, raretes[cle])
		end
	end
	if #couleursFanions == 0 then
		couleursFanions = { DORE, Charte.lave, Charte.gemme }
	end
	for i = 0, 8 do
		local z = CZ - 6 + i * 1.5
		local couleur = couleursFanions[(i % #couleursFanions) + 1]
		piece(cabane, "bloc", "Fanion", Vector3.new(0.1, 0.7, 0.7),
			CFrame.new(xPoteauAvant + 0.2, yPoutre - 0.55, z) * CFrame.Angles(math.rad(45), 0, 0), couleur, LEGER)
	end

	-- ===== 5. étagères du fond et marchandises =====
	local xEtagere = xFond + 1.3
	local couleursBocaux = { Charte.gemme, Charte.violet, DORE, Charte.lave, PALME_CLAIRE }
	for n, yEtagere in ipairs({ 5, 8.2 }) do
		piece(cabane, "bloc", "Etagere", Vector3.new(1.4, 0.25, 12), CFrame.new(xEtagere, yEtagere, CZ), BOIS_CLAIR)
		for k = 0, 4 do
			local z = CZ - 4.8 + k * 2.4
			local couleur = couleursBocaux[((k + n) % #couleursBocaux) + 1]
			if (k + n) % 2 == 0 then
				-- bocal lumineux
				piece(cabane, "cylindre", "Bocal", Vector3.new(1.1, 0.9, 0.9),
					CFrame.new(xEtagere, yEtagere + 0.68, z) * VERTICAL, couleur,
					leger({ Material = Enum.Material.Neon, Transparency = 0.25 }))
			else
				-- boîte
				piece(cabane, "bloc", "Boite", Vector3.new(0.9, 0.8, 1.1),
					CFrame.new(xEtagere, yEtagere + 0.53, z) * CFrame.Angles(0, math.rad(8 * k), 0), couleur, LEGER)
			end
		end
	end

	-- caisses et tonneaux dans les coins
	local xCoin = CX - 8.5
	piece(cabane, "bloc", "Caisse", Vector3.new(2.2, 2.2, 2.2), CFrame.new(xCoin, SOL + 1.1, CZ - 5.2), BOIS)
	piece(cabane, "bloc", "Caisse", Vector3.new(1.6, 1.6, 1.6),
		CFrame.new(xCoin, SOL + 3, CZ - 5.2) * CFrame.Angles(0, math.rad(20), 0), BOIS_CLAIR)
	piece(cabane, "bloc", "Caisse", Vector3.new(1.8, 1.8, 1.8),
		CFrame.new(xCoin + 2.4, SOL + 0.9, CZ - 5.8) * CFrame.Angles(0, math.rad(-12), 0), BOIS_OMBRE)
	for _, dx in ipairs({ 0, 2.2 }) do
		piece(cabane, "cylindre", "Tonneau", Vector3.new(2.4, 1.9, 1.9),
			CFrame.new(xCoin + dx, SOL + 1.2, CZ + 5.4) * VERTICAL, BOIS)
		piece(cabane, "cylindre", "Cerclage", Vector3.new(0.25, 2, 2),
			CFrame.new(xCoin + dx, SOL + 1.6, CZ + 5.4) * VERTICAL, Charte.pierre, LEGER)
	end

	-- ===== 6. le comptoir et son invite =====
	local xComptoir = CX + 6
	local hComptoir = 3.4
	piece(modeleComptoir, "bloc", "Caisson", Vector3.new(2, hComptoir, 7), CFrame.new(xComptoir, SOL + hComptoir / 2, CZ), ORANGE)
	local partComptoir = piece(modeleComptoir, "bloc", "Plateau", Vector3.new(2.8, 0.4, 7.8),
		CFrame.new(xComptoir, SOL + hComptoir + 0.2, CZ), JAUNE)
	local yPlateau = SOL + hComptoir + 0.4
	for _, signe in ipairs({ -1, 1 }) do
		piece(modeleComptoir, "bloc", "Montant", Vector3.new(0.3, hComptoir, 0.5),
			CFrame.new(xComptoir + 1.05, SOL + hComptoir / 2, CZ + signe * 3.25), JAUNE, LEGER)
	end
	local plaque = piece(modeleComptoir, "bloc", "Plaque", Vector3.new(0.15, 1.3, 5.2),
		CFrame.new(xComptoir + 1.05, SOL + hComptoir / 2 + 0.3, CZ), ORANGE_OMBRE, LEGER)
	ecrireCerne(plaque, "Right", "OBJETS D'EXPLORATEUR", 30, 3)
	-- caisse enregistreuse et clochette
	piece(modeleComptoir, "bloc", "CaisseEnregistreuse", Vector3.new(1.2, 0.8, 1.4), CFrame.new(xComptoir - 0.2, yPlateau + 0.4, CZ + 2.2), DORE, LEGER)
	piece(modeleComptoir, "coin", "Clavier", Vector3.new(1.2, 0.4, 0.9),
		CFrame.new(xComptoir - 0.2, yPlateau + 1, CZ + 2.2) * CFrame.Angles(0, math.rad(-90), 0), CREME, LEGER)
	piece(modeleComptoir, "boule", "Clochette", Vector3.new(0.6, 0.6, 0.6), CFrame.new(xComptoir + 0.5, yPlateau + 0.3, CZ - 2.3), DORE, LEGER)
	piece(modeleComptoir, "boule", "Pepite", Vector3.new(0.5, 0.5, 0.5), CFrame.new(xComptoir + 0.2, yPlateau + 0.25, CZ - 0.8), Charte.gemme,
		leger({ Material = Enum.Material.Neon }))
	if partComptoir then
		partComptoir.Name = "Comptoir"
		Outils.invite(partComptoir, { nom = "Boutique", action = "Acheter", objet = "Boutique", distance = 12 })
	end

	-- ===== 7. le marchand jouet (regard vers +X) =====
	local xM = CX + 3
	local zM = CZ
	local yJambes = SOL
	for _, signe in ipairs({ -1, 1 }) do
		piece(marchand, "bloc", "Jambe", Vector3.new(0.8, 1.8, 0.8), CFrame.new(xM, yJambes + 0.9, zM + signe * 0.5), KAKI, LEGER)
		piece(marchand, "bloc", "Botte", Vector3.new(1.1, 0.5, 0.9), CFrame.new(xM + 0.15, yJambes + 0.25, zM + signe * 0.5), BOIS_OMBRE, LEGER)
	end
	local yTorse = yJambes + 1.8
	piece(marchand, "bloc", "Torse", Vector3.new(1.2, 2.2, 2.2), CFrame.new(xM, yTorse + 1.1, zM), SABLE, LEGER)
	piece(marchand, "bloc", "Ceinture", Vector3.new(1.3, 0.3, 2.3), CFrame.new(xM, yTorse + 0.25, zM), BOIS, LEGER)
	piece(marchand, "bloc", "Foulard", Vector3.new(1.3, 0.4, 1.5), CFrame.new(xM + 0.05, yTorse + 2.05, zM), Charte.lave, LEGER)
	-- bras posés sur le comptoir
	local xMain = xComptoir - 0.5
	local longueurBras = xMain - xM
	for _, signe in ipairs({ -1, 1 }) do
		piece(marchand, "bloc", "Bras", Vector3.new(longueurBras, 0.6, 0.6),
			CFrame.new(xM + longueurBras / 2, yPlateau + 0.25, zM + signe * 1.4), SABLE, LEGER)
		piece(marchand, "bloc", "Main", Vector3.new(0.6, 0.6, 0.6), CFrame.new(xMain + 0.1, yPlateau + 0.3, zM + signe * 1.4), PEAU, LEGER)
	end
	-- tête
	local yTete = yTorse + 2.2 + 0.8
	piece(marchand, "bloc", "Tete", Vector3.new(1.6, 1.6, 1.6), CFrame.new(xM, yTete, zM), PEAU, LEGER)
	for _, signe in ipairs({ -1, 1 }) do
		piece(marchand, "bloc", "Oeil", Vector3.new(0.1, 0.35, 0.25), CFrame.new(xM + 0.81, yTete + 0.2, zM + signe * 0.35), ENCRE, LEGER)
	end
	piece(marchand, "bloc", "Moustache", Vector3.new(0.15, 0.25, 1), CFrame.new(xM + 0.82, yTete - 0.3, zM), BOIS_OMBRE, LEGER)
	-- casque colonial
	local yCasque = yTete + 0.8
	piece(marchand, "cylindre", "Bord", Vector3.new(0.15, 2.8, 2.8), CFrame.new(xM, yCasque + 0.05, zM) * VERTICAL, Charte.lumiere(SABLE), LEGER)
	piece(marchand, "cylindre", "Bandeau", Vector3.new(0.35, 1.82, 1.82), CFrame.new(xM, yCasque + 0.3, zM) * VERTICAL, BOIS, LEGER)
	piece(marchand, "boule", "Calotte", Vector3.new(1.8, 1.8, 1.8), CFrame.new(xM, yCasque + 0.35, zM), SABLE, LEGER)
	piece(marchand, "boule", "Bouton", Vector3.new(0.35, 0.35, 0.35), CFrame.new(xM, yCasque + 1.25, zM), CREME, LEGER)

	-- ===== 8. vitrines des objets de la boutique =====
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
		local function morceau(genre, nom, taille, decalage, couleur, extra)
			return piece(parent, genre, nom, taille, centre * decalage, couleur, leger(extra))
		end
		if cle == "Bottes" then
			for _, dz in ipairs({ -0.35, 0.35 }) do
				morceau("bloc", "Tige", Vector3.new(0.5, 0.9, 0.5), CFrame.new(-0.15, 0.15, dz), Charte.lave)
				morceau("bloc", "Pied", Vector3.new(1, 0.4, 0.5), CFrame.new(0.1, -0.45, dz), BOIS_OMBRE)
				morceau("bloc", "Aile", Vector3.new(0.4, 0.35, 0.1), CFrame.new(-0.35, 0.35, dz * 1.9) * CFrame.Angles(0, 0, math.rad(25)), DORE)
			end
		elseif cle == "BatteOr" then
			local incline = CFrame.Angles(0, 0, math.rad(65))
			morceau("cylindre", "Manche", Vector3.new(1, 0.25, 0.25), incline * CFrame.new(-0.8, 0, 0), BOIS_OMBRE)
			morceau("cylindre", "Batte", Vector3.new(1.4, 0.5, 0.5), incline * CFrame.new(0.35, 0, 0), DORE, { Material = Enum.Material.Neon })
			morceau("boule", "Pommeau", Vector3.new(0.35, 0.35, 0.35), incline * CFrame.new(-1.3, 0, 0), BOIS_OMBRE)
		elseif cle == "Aimant" then
			for _, dz in ipairs({ -0.45, 0.45 }) do
				morceau("bloc", "Branche", Vector3.new(0.4, 1, 0.4), CFrame.new(0, 0.05, dz), Charte.alerte)
				morceau("bloc", "Pointe", Vector3.new(0.42, 0.3, 0.42), CFrame.new(0, 0.7, dz), CREME)
			end
			morceau("bloc", "Arc", Vector3.new(0.4, 0.4, 1.3), CFrame.new(0, -0.6, 0), Charte.alerte)
		elseif cle == "Radar" then
			morceau("bloc", "Socle", Vector3.new(0.9, 0.3, 0.9), CFrame.new(0, -0.75, 0), Charte.pierre)
			morceau("bloc", "Mat", Vector3.new(0.2, 0.7, 0.2), CFrame.new(0, -0.3, 0), Charte.pierre)
			morceau("cylindre", "Parabole", Vector3.new(0.15, 1.3, 1.3), CFrame.new(0.1, 0.25, 0) * CFrame.Angles(0, 0, math.rad(40)), CREME)
			morceau("boule", "Capteur", Vector3.new(0.35, 0.35, 0.35), CFrame.new(0.4, 0.55, 0), Charte.gemme, { Material = Enum.Material.Neon })
		else
			morceau("boule", "Gemme", Vector3.new(0.9, 0.9, 0.9), CFrame.new(0, 0, 0), Charte.gemme, { Material = Enum.Material.Neon })
		end
	end

	local xVitrine = CX + 9.5
	local positionsZ = { CZ - 7, CZ - 4.6, CZ + 4.6, CZ + 7 }
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
		local hSocle = 2.6
		piece(vitrine, "bloc", "Socle", Vector3.new(2.2, hSocle, 2.2), CFrame.new(xVitrine, SOL + hSocle / 2, z), ORANGE)
		piece(vitrine, "bloc", "Lisere", Vector3.new(2.4, 0.2, 2.4), CFrame.new(xVitrine, SOL + hSocle + 0.1, z), JAUNE)
		local yVerre = SOL + hSocle + 0.2
		piece(vitrine, "bloc", "Verre", Vector3.new(2.2, 2.4, 2.2), CFrame.new(xVitrine, yVerre + 1.2, z),
			Charte.lumiere(Charte.gemme), { Material = Enum.Material.Glass, Transparency = 0.7 })
		local chapeau = piece(vitrine, "bloc", "Chapeau", Vector3.new(2.4, 0.2, 2.4), CFrame.new(xVitrine, yVerre + 2.5, z), JAUNE)
		-- étiquette : nom et prix, lisible depuis la Place
		local etiquette = piece(vitrine, "bloc", "Etiquette", Vector3.new(0.12, 1.4, 2), CFrame.new(xVitrine + 1.16, SOL + hSocle / 2 + 0.2, z), ORANGE_OMBRE, LEGER)
		local nom = infos.nom
		if type(nom) ~= "string" then
			nom = NOMS_DEFAUT[cle] or tostring(cle)
		end
		local texte = nom
		local lignes = { { texte = nom, taille = 1, nom = "Nom" } }
		if type(infos.prix) == "number" then
			texte = nom .. "\n" .. Charte.argent(infos.prix)
			local vert = JAUNE
			if Style then
				vert = Style.couleurs.argent
			end
			table.insert(lignes, { texte = Charte.argent(infos.prix), taille = 1.1, nom = "Prix", couleur = vert })
		end
		ecrireCerne(etiquette, "Right", texte, 40, 3)
		-- nom blanc et prix vert flottant au-dessus de la vitrine
		flottante(chapeau, lignes, {
			Name = "EtiquetteObjet",
			largeur = 7,
			hauteurLigne = 1.1,
			StudsOffset = Vector3.new(0, 2, 0),
			MaxDistance = 80,
		})
		-- la maquette, qui tourne doucement dans son verre
		local objet = Outils.modele(vitrine, "Maquette")
		local centre = CFrame.new(xVitrine, yVerre + 1.1, z)
		maquette(objet, cle, centre)
		pcall(function()
			objet.WorldPivot = centre
		end)
		Outils.animer(objet, "tourne", 0.6)
	end

	dossier:SetAttribute("Parts", compte)
end

return M
