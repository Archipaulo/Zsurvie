-- Constructeur Signaletique : panneaux-flèches en bois, finition « pro » (STYLE.md §4).
-- Chaque panneau : socle de pierre rond, poteau en bois coiffé d'une boule peinte, planche en WoodPlanks
-- aux bords biseautés côté arrière (coins) et pointe de flèche peinte côté destination (deux coins).
-- Sur chaque face, une plaque peinte en dégradé, cerclée de noir, avec reflet, clous et texte blanc cerné.
-- Sur la Place, quatre panneaux-flèches : Boutique (Comptoir, ouest, orange), Renaissance (Autel, est, violet),
-- Dinos à vendre (Tapis, nord, rouge), Dinodex (borne, sud, bleu). Au-dessus de chacun, un titre géant flottant.
-- Au début du Tapis « NURSERIE → », à la fin « GRANDE PORTE → », de chaque côté du Tapis.
-- Au nord de la Place, face aux joueurs qui apparaissent, un tableau des règles à toit de bardeaux.
-- Les flèches du texte sont recalculées pour chaque face : elles pointent toujours dans la bonne direction.
-- Emprise (CONTRAT §10) : Place (hors secteur du tableau d'honneur) et bouts du Tapis.
local M = {}

local BUDGET = 120 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.signaletique
local DEFAUTS = {
	largeurFleche = 9,      -- largeur d'une planche indicatrice
	reculBoutPlace = 17,    -- distance des panneaux Boutique / Renaissance au centre (sur l'axe est-ouest)
	decalageAllee = 6.5,    -- décalage vers le sud : allées libres, et hors du champ du tableau d'honneur (z > 106)
	tapisX = 6.5,           -- panneau vers le Tapis : décalage est (hors de la margelle de la fontaine, rayon 5,45)
	tapisRecul = 17.5,      -- ... et distance au nord du centre
	dinodexX = -4.5,        -- panneau vers le Dinodex : décalage ouest
	dinodexRecul = 8.5,     -- ... et distance au sud du centre
	distanceBorne = 16.5,   -- position de la borne si elle est introuvable
	bordTapis = 6,          -- écart entre le rebord du Tapis et les panneaux des bouts
	retraitTapis = 3,       -- retrait des panneaux vers l'intérieur du Tapis
	reglesX = 16,           -- grand panneau des règles : décalage est
	reglesRecul = 29,       -- ... et distance au nord du centre (entre la Place et les Bases)
	reglesLargeur = 12,
	reglesHauteur = 6,
	reglesBas = 3,          -- hauteur du bas du panneau
}

-- forme des panneaux-flèches
local HAUTEUR_POTEAU = 5      -- hauteur du centre de la planche au-dessus du sol
local HAUTEUR_PLANCHE = 2.6
local EPAISSEUR_PLANCHE = 0.7
local LONGUEUR_POINTE = 1.6   -- pointe de flèche (côté destination)
local BISEAU = 0.55           -- coins coupés (côté arrière)
local PARTS_FLECHE = 9        -- socle, poteau, boule, planche, talon, 2 biseaux, 2 demi-pointes
local PIXELS_PAR_STUD = 40

local function lireReglages(ctx)
	local source = nil
	if ctx.Equilibrage and type(ctx.Equilibrage.signaletique) == "table" then
		source = ctx.Equilibrage.signaletique
	end
	local r = {}
	for cle, defaut in pairs(DEFAUTS) do
		local v = nil
		if source then
			v = source[cle]
		end
		if type(v) == "number" then
			r[cle] = v
		else
			r[cle] = defaut
		end
	end
	return r
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Style = ctx.Style
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	local infoPlace = Plan.place or {}
	local CENTRE = infoPlace.centre or Vector3.new(0, 0, 100)
	local CX, CZ = CENTRE.X, CENTRE.Z

	local NOIR = Charte.encre
	local BLANC = Charte.creme
	if Style and Style.couleurs then
		NOIR = Style.couleurs.contour
		BLANC = Style.couleurs.texte
	end

	-- bois en trois teintes (base, ombre, lumière) et pierre des socles
	local BOIS = Charte.bois
	local BOIS_SOMBRE = Charte.ombre(Charte.bois)
	local BOIS_CLAIR = Charte.lumiere(Charte.bois)
	local PIERRE = Charte.lumiere(Charte.pierre)
	local MAT_PLANCHES = Enum.Material.WoodPlanks
	local MAT_BOIS = Enum.Material.Wood
	local MAT_PIERRE = Enum.Material.Slate
	local METAL = Charte.ombre(Charte.pierre)

	-- palette { haut, bas } d'une couleur de bouton (Style.boutons), avec repli sur la Charte
	local function palette(nom, repli)
		if Style and Style.boutons and Style.boutons[nom] then
			return Style.boutons[nom]
		end
		return { Charte.lumiere(repli), repli }
	end

	-- ===== compteur de parts : on s'arrête net au budget =====
	local nbParts = 0
	local function reserver(n)
		if nbParts + n > BUDGET then
			return false
		end
		nbParts = nbParts + n
		return true
	end
	local function bloc(parent, props)
		if not reserver(1) then return nil end
		return Outils.bloc(parent, props)
	end
	local function coin(parent, props)
		if not reserver(1) then return nil end
		return Outils.coin(parent, props)
	end
	local function cylindre(parent, props)
		if not reserver(1) then return nil end
		return Outils.cylindre(parent, props)
	end
	local function boule(parent, props)
		if not reserver(1) then return nil end
		return Outils.boule(parent, props)
	end

	-- lance une étape sans que son échec empêche les autres
	local function etape(nom, fn)
		local ok, err = pcall(fn)
		if not ok then
			warn("[Dino] Signaletique / " .. nom .. " : " .. tostring(err))
		end
	end

	-- texte blanc cerné de noir (via Style), avec repli simple si Style manque
	local function texte(parent, props, epaisseur)
		if Style and type(Style.texte) == "function" then
			props.contour = epaisseur or 3
			return Style.texte(parent, props)
		end
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.TextScaled = true
		t.Font = Charte.police
		t.TextColor3 = BLANC
		t.TextStrokeColor3 = NOIR
		t.TextStrokeTransparency = 0
		for cle, valeur in pairs(props) do
			if cle ~= "titre" and cle ~= "tailleMax" and cle ~= "contour" then
				t[cle] = valeur
			end
		end
		t.Parent = parent
		return t
	end

	-- petit cadre d'interface (reflet, clou, pastille)
	local function cadreGui(parent, props, rayon)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		for cle, valeur in pairs(props) do
			f[cle] = valeur
		end
		if rayon then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, rayon)
			c.Parent = f
		end
		f.Parent = parent
		return f
	end

	-- quatre clous de métal aux coins d'une plaque
	local function clous(plaque, taille, retrait)
		for _, ax in ipairs({ 0, 1 }) do
			for _, ay in ipairs({ 0, 1 }) do
				local clou = cadreGui(plaque, {
					Name = "Clou",
					AnchorPoint = Vector2.new(ax, ay),
					Position = UDim2.new(ax, retrait * (1 - 2 * ax), ay, retrait * (1 - 2 * ay)),
					Size = UDim2.fromOffset(taille, taille),
					BackgroundColor3 = Charte.lumiere(Charte.pierre),
					ZIndex = 3,
				}, taille)
				if Style then
					Style.bordure(clou, 2)
				end
			end
		end
	end

	-- face d'une planche : marge de bois visible, plaque peinte en dégradé, cerclée de noir, reflet brillant et clous
	local function faceCartoon(planche, face, couleurs, contenu)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Affiche"
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = PIXELS_PAR_STUD
		gui.LightInfluence = 0
		gui.Parent = planche

		local fond = Instance.new("Frame")
		fond.Name = "Fond"
		fond.AnchorPoint = Vector2.new(0.5, 0.5)
		fond.Position = UDim2.fromScale(0.5, 0.5)
		fond.Size = UDim2.new(1, -18, 1, -18)
		fond.BackgroundColor3 = Color3.new(1, 1, 1)
		fond.BorderSizePixel = 0
		if Style then
			Style.coins(fond, 12)
			Style.bordure(fond, 5)
			Style.degrade(fond, couleurs[1], couleurs[2])
		else
			fond.BackgroundColor3 = couleurs[2]
		end
		fond.Parent = gui

		-- reflet brillant sur le haut de la plaque
		cadreGui(fond, {
			Name = "Reflet",
			Position = UDim2.fromOffset(6, 5),
			Size = UDim2.new(1, -12, 0.4, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.78,
			ZIndex = 2,
		}, 9)
		clous(fond, 9, 6)
		contenu(fond)
		return gui
	end

	-- titre géant flottant au-dessus d'un panneau
	local function titreFlottant(part, lignes, props)
		if not (Style and type(Style.etiquette) == "function") then
			return nil
		end
		return Style.etiquette(part, lignes, props)
	end

	-- panneau-flèche : poteau de bois, planche en WoodPlanks orientée vers la destination,
	-- talon biseauté à l'arrière, pointe peinte au bout, titre flottant
	-- info : { nom, titre, droite, gauche, couleurs = { haut, bas } }
	local function fleche(parent, info, position, direction)
		local d = Vector3.new(direction.X, 0, direction.Z)
		if d.Magnitude < 0.01 then
			d = Vector3.new(1, 0, 0)
		end
		d = d.Unit
		-- l'axe X local de la planche pointe vers la destination
		local angle = math.deg(math.atan2(-d.Z, d.X))
		local W = R.largeurFleche
		local H = HAUTEUR_PLANCHE
		local T = EPAISSEUR_PLANCHE
		local L = LONGUEUR_POINTE
		local C = BISEAU
		local couleurs = info.couleurs
		-- tout le panneau ou rien
		if not reserver(PARTS_FLECHE) then return nil end

		local m = Outils.modele(parent, info.nom)
		local x, y0, z = position.X, position.Y, position.Z

		-- socle de pierre rond (axe du cylindre = X, couché à la verticale)
		Outils.cylindre(m, {
			Name = "Pied",
			Size = Vector3.new(0.5, 2, 2),
			CFrame = CFrame.new(x, y0 + 0.25, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = PIERRE,
			Material = MAT_PIERRE,
		})
		-- poteau de bois qui dépasse un peu au-dessus de la planche
		local hPoteau = HAUTEUR_POTEAU + H / 2 + 0.3
		local tailleP = Vector3.new(0.7, hPoteau, 0.7)
		Outils.bloc(m, {
			Name = "Poteau",
			Size = tailleP,
			CFrame = Outils.surSol(tailleP, x, z, angle, y0),
			Color = BOIS_SOMBRE,
			Material = MAT_BOIS,
		})
		-- boule peinte au sommet du poteau
		Outils.boule(m, {
			Name = "Boule",
			Size = Vector3.new(0.9, 0.9, 0.9),
			CFrame = CFrame.new(x, y0 + hPoteau + 0.3, z),
			Color = couleurs[2],
			Material = MAT_BOIS,
			CanCollide = false,
		})

		local planche = Outils.bloc(m, {
			Name = "Planche",
			Size = Vector3.new(W, H, T),
			CFrame = CFrame.new(x, y0 + HAUTEUR_POTEAU, z) * CFrame.Angles(0, math.rad(angle), 0),
			Color = BOIS,
			Material = MAT_PLANCHES,
			CanCollide = false,
		})
		m.PrimaryPart = planche
		local cf = planche.CFrame

		-- talon arrière : bloc central + deux coins qui coupent les angles en biseau
		Outils.bloc(m, {
			Name = "Talon",
			Size = Vector3.new(C, H - 2 * C, T),
			CFrame = cf * CFrame.new(-W / 2 - C / 2, 0, 0),
			Color = BOIS,
			Material = MAT_PLANCHES,
			CanCollide = false,
		})
		-- pointe de flèche : deux demi-triangles peints aux couleurs de la destination
		for _, s in ipairs({ 1, -1 }) do
			local retourne = CFrame.new()
			if s < 0 then
				retourne = CFrame.Angles(0, 0, math.pi)
			end
			-- biseau : face verticale contre la planche (+X local du coin), pente vers l'arrière
			Outils.coin(m, {
				Name = "Biseau",
				Size = Vector3.new(T, C, C),
				CFrame = cf * CFrame.new(-W / 2 - C / 2, s * (H / 2 - C / 2), 0) * CFrame.Angles(0, math.rad(90), 0) * retourne,
				Color = BOIS,
				Material = MAT_PLANCHES,
				CanCollide = false,
			})
			-- demi-pointe : face verticale contre la planche, pente vers la destination
			Outils.coin(m, {
				Name = "Pointe",
				Size = Vector3.new(T, H / 2, L),
				CFrame = cf * CFrame.new(W / 2 + L / 2, s * H / 4, 0) * CFrame.Angles(0, math.rad(-90), 0) * retourne,
				Color = couleurs[2],
				Material = MAT_PLANCHES,
				CanCollide = false,
			})
		end

		-- faces : la face arrière se lit vers +X local, la face avant vers -X local
		for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
			local droite = cf.RightVector
			if face == Enum.NormalId.Front then
				droite = -droite
			end
			local mot = info.gauche
			if droite:Dot(d) > 0 then
				mot = info.droite
			end
			faceCartoon(planche, face, couleurs, function(fond)
				texte(fond, {
					Name = "Texte",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.52),
					Size = UDim2.new(1, -40, 1, -22),
					Text = mot,
					ZIndex = 4,
					titre = true,
				}, 4)
			end)
		end

		-- titre flottant facultatif : discret, juste au-dessus de la planche (sous la boule du poteau).
		-- Les panneaux de la Place n'en portent plus : la borne, le Comptoir et la fontaine ont déjà le leur.
		if info.titre then
			titreFlottant(planche, {
				{ texte = info.titre, couleur = couleurs[1], titre = true, contour = 4 },
			}, {
				Name = "Titre",
				largeur = 9,
				hauteurLigne = 1.6,
				StudsOffset = Vector3.new(0, 2.2, 0),
				MaxDistance = 70,
			})
		end
		return m
	end

	-- ===== 1. panneaux-flèches sur la Place =====
	etape("place", function()
		local m = Outils.modele(dossier, "Place")

		-- Boutique : façade du Comptoir, ouverte vers la Place (+X)
		local cibleComptoir = Vector3.new(CX - 50, 0, CZ + 4)
		if Plan.comptoir and Plan.comptoir.centre then
			local demiLargeur = 13
			if Plan.comptoir.taille then
				demiLargeur = Plan.comptoir.taille.X / 2
			end
			cibleComptoir = Plan.comptoir.centre + Vector3.new(demiLargeur, 0, 0)
		end
		local posBoutique = Vector3.new(CX - R.reculBoutPlace, 0, CZ + R.decalageAllee)
		fleche(m, {
			nom = "VersBoutique",
			droite = "BOUTIQUE →",
			gauche = "← BOUTIQUE",
			couleurs = palette("orange", Charte.lave),
		}, posBoutique, cibleComptoir - posBoutique)

		-- Renaissance : l'Autel, à l'est
		local cibleAutel = Vector3.new(CX + 50, 0, CZ + 4)
		if Plan.autel and Plan.autel.centre then
			cibleAutel = Plan.autel.centre
		end
		local posAutel = Vector3.new(CX + R.reculBoutPlace, 0, CZ + R.decalageAllee)
		fleche(m, {
			nom = "VersRenaissance",
			droite = "RENAISSANCE →",
			gauche = "← RENAISSANCE",
			couleurs = palette("violet", Charte.violet),
		}, posAutel, cibleAutel - posAutel)

		-- Tapis : vers le nord, par l'allée centrale
		local cibleTapis = Vector3.new(CX, 0, 0)
		if Plan.tapis and Plan.tapis.debut and Plan.tapis.fin then
			local milieu = (Plan.tapis.debut + Plan.tapis.fin) / 2
			cibleTapis = Vector3.new(CX, 0, milieu.Z)
		end
		local posTapis = Vector3.new(CX + R.tapisX, 0, CZ - R.tapisRecul)
		fleche(m, {
			nom = "VersTapis",
			droite = "DINOS →",
			gauche = "← DINOS",
			couleurs = palette("rouge", Charte.tapis),
		}, posTapis, cibleTapis - posTapis)

		-- Dinodex : la borne au bord sud de la Place (position réelle si elle existe)
		local cibleBorne = Vector3.new(CX, 0, CZ + R.distanceBorne)
		local place = ctx.racine and ctx.racine:FindFirstChild("Place")
		local borne = place and place:FindFirstChild("Dinodex")
		if borne and borne:IsA("Model") then
			local ok, pivot = pcall(function()
				return borne:GetPivot()
			end)
			if ok and pivot then
				cibleBorne = Vector3.new(pivot.Position.X, 0, pivot.Position.Z)
			end
		end
		local posDinodex = Vector3.new(CX + R.dinodexX, 0, CZ + R.dinodexRecul)
		fleche(m, {
			nom = "VersDinodex",
			droite = "DINODEX →",
			gauche = "← DINODEX",
			couleurs = palette("bleu", Charte.gemme),
		}, posDinodex, cibleBorne - posDinodex)
	end)

	-- ===== 2. les deux bouts du Tapis (des deux côtés) =====
	etape("tapis", function()
		local m = Outils.modele(dossier, "Tapis")
		local tapis = Plan.tapis or {}
		local debut = tapis.debut or Vector3.new(-112, 0, 0)
		local fin = tapis.fin or Vector3.new(112, 0, 0)
		local sens = fin - debut
		if sens.Magnitude < 0.01 then
			sens = Vector3.new(1, 0, 0)
		end
		sens = Vector3.new(sens.X, 0, sens.Z).Unit
		local cote = Vector3.new(-sens.Z, 0, sens.X) -- perpendiculaire au Tapis, dans le plan
		local ecart = (tapis.largeur or 10) / 2 + R.bordTapis

		for _, s in ipairs({ 1, -1 }) do
			-- début : les dinos sortent de la Nurserie et partent dans le sens du Tapis
			local posDebut = debut + sens * R.retraitTapis + cote * (ecart * s)
			fleche(m, {
				nom = "Nurserie",
				droite = "NURSERIE →",
				gauche = "← NURSERIE",
				couleurs = palette("vert", Charte.herbe),
			}, Vector3.new(posDebut.X, 0, posDebut.Z), sens)

			-- fin : les dinos invendus passent la Grande Porte
			local posFin = fin - sens * R.retraitTapis + cote * (ecart * s)
			fleche(m, {
				nom = "GrandePorte",
				droite = "GRANDE PORTE →",
				gauche = "← GRANDE PORTE",
				couleurs = palette("jaune", Charte.dore),
			}, Vector3.new(posFin.X, 0, posFin.Z), sens)
		end
	end)

	-- ===== 3. tableau des règles, face à la Place =====
	-- entre la Place et l'arrière des Bases du sud, visible dès l'apparition (on regarde vers le nord)
	etape("regles", function()
		local m = Outils.modele(dossier, "Regles")
		local L = R.reglesLargeur
		local H = R.reglesHauteur
		local bas = R.reglesBas
		local px, pz = CX + R.reglesX, CZ - R.reglesRecul
		-- repère au sol, face avant du panneau (-Z local) tournée vers la Place (plein sud),
		-- parallèle à l'arrière des Bases pour ne pas déborder sur elles
		local repere = CFrame.lookAt(Vector3.new(px, 0, pz), Vector3.new(px, 0, CZ))
		local function ici(x, y, z)
			return repere * CFrame.new(x, y, z)
		end
		local yMilieu = bas + H / 2
		local yHaut = bas + H           -- haut de la planche
		local yToit = yHaut + 0.7       -- dessous du toit (dessus de la poutre)
		local hToit = 1.9
		local profToit = 2.3            -- avancée de chaque pan du toit
		local largeurToit = L + 4
		local xPoteau = L / 2 + 0.5
		local bleu = palette("bleu", Charte.gemme)
		local rougeToit = Charte.ombre(Charte.tapis)

		-- poteaux de bois sur socles de pierre ronds
		for _, s in ipairs({ -1, 1 }) do
			cylindre(m, {
				Name = "Pied",
				Size = Vector3.new(0.6, 2.2, 2.2),
				CFrame = ici(s * xPoteau, 0.3, 0) * CFrame.Angles(0, 0, math.rad(90)),
				Color = PIERRE,
				Material = MAT_PIERRE,
			})
			bloc(m, {
				Name = "Poteau",
				Size = Vector3.new(1, yToit, 1),
				CFrame = ici(s * xPoteau, yToit / 2, 0),
				Color = BOIS_SOMBRE,
				Material = MAT_BOIS,
			})
		end
		local planche = bloc(m, {
			Name = "Planche",
			Size = Vector3.new(L, H, 0.6),
			CFrame = ici(0, yMilieu, 0),
			Color = BOIS,
			Material = MAT_PLANCHES,
		})
		-- poutres haute et basse en bois sombre
		bloc(m, {
			Name = "Poutre",
			Size = Vector3.new(L + 3, 0.7, 1.1),
			CFrame = ici(0, yHaut + 0.35, 0),
			Color = BOIS_SOMBRE,
			Material = MAT_PLANCHES,
		})
		bloc(m, {
			Name = "Poutre",
			Size = Vector3.new(L, 0.5, 0.9),
			CFrame = ici(0, bas - 0.25, 0),
			Color = BOIS_SOMBRE,
			Material = MAT_PLANCHES,
		})
		-- toit à deux pans (coins) en bardeaux rouges, faîtage en bois
		coin(m, {
			Name = "Toit",
			Size = Vector3.new(largeurToit, hToit, profToit),
			CFrame = ici(0, yToit + hToit / 2, -profToit / 2),
			Color = rougeToit,
			Material = MAT_PLANCHES,
		})
		coin(m, {
			Name = "Toit",
			Size = Vector3.new(largeurToit, hToit, profToit),
			CFrame = ici(0, yToit + hToit / 2, profToit / 2) * CFrame.Angles(0, math.pi, 0),
			Color = rougeToit,
			Material = MAT_PLANCHES,
		})
		cylindre(m, {
			Name = "Faitage",
			Size = Vector3.new(largeurToit + 0.4, 0.5, 0.5),
			CFrame = ici(0, yToit + hToit, 0),
			Color = BOIS_SOMBRE,
			Material = MAT_BOIS,
		})
		-- lanterne sous l'avancée du toit, au-dessus du tableau
		local lampe = bloc(m, {
			Name = "Lanterne",
			Size = Vector3.new(0.5, 0.5, 0.5),
			CFrame = ici(0, yToit - 0.05, -1.2),
			Color = Charte.dore,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		if lampe then
			local l = Outils.lumiere(lampe, { Range = 12, Brightness = 1.2, Color = Charte.dore })
			l.Shadows = true
		end
		-- œuf doré qui flotte au-dessus du faîtage
		local yOeuf = yToit + hToit + 1.5
		local oeuf = boule(m, {
			Name = "Oeuf",
			Size = Vector3.new(1.4, 1.8, 1.4),
			CFrame = ici(0, yOeuf, 0),
			Color = Charte.dore,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		if oeuf then
			Outils.animer(oeuf, "flotte", 0.7)
			Outils.lumiere(oeuf, { Range = 14, Brightness = 1, Color = Charte.dore })
		end
		if not planche then
			return
		end
		m.PrimaryPart = planche

		-- titre géant flottant, au-dessus de l'œuf
		titreFlottant(planche, {
			{ texte = "📜 RÈGLES", couleur = Style and Style.couleurs.revenu or Charte.dore, titre = true, contour = 4 },
		}, {
			Name = "Titre",
			largeur = 12,
			hauteurLigne = 2.6,
			StudsOffset = Vector3.new(0, yOeuf - yMilieu + 2.8, 0),
			MaxDistance = 160,
		})

		-- chiffres du jeu pour la ligne du bas
		local depart = 100
		if type(E.argentDepart) == "number" then
			depart = E.argentDepart
		end
		local dureeVerrou = 60
		if type(E.base) == "table" and type(E.base.dureeVerrou) == "number" then
			dureeVerrou = E.base.dureeVerrou
		end
		local vert = Charte.herbe
		local jaune = Charte.dore
		local fondHaut = Charte.nuit
		local fondBas = Charte.nuit
		local carte = Charte.lumiere(Charte.nuit)
		if Style and Style.couleurs then
			vert = Style.couleurs.argent
			jaune = Style.couleurs.revenu
			fondHaut = Style.couleurs.fondHaut
			fondBas = Style.couleurs.fond
			carte = Style.couleurs.carte
		end

		-- règles courtes, une idée par ligne
		local lignes = {
			{ texte = "🦖 ACHÈTE des dinos", couleur = BLANC },
			{ texte = "💰 Ils rapportent des $", couleur = vert },
			{ texte = "😈 VOLE ceux des autres !", couleur = jaune },
			{ texte = "🔒 VERROUILLE ta base", couleur = Charte.gemme },
		}
		local pied = "Départ " .. Charte.argent(depart) .. "  •  Verrou " .. tostring(math.floor(dureeVerrou + 0.5)) .. " s"

		local function affiche(face)
			faceCartoon(planche, face, { fondHaut, fondBas }, function(fond)
				-- bandeau de titre bleu brillant
				local bandeau = cadreGui(fond, {
					Name = "Bandeau",
					Position = UDim2.new(0, 10, 0, 10),
					Size = UDim2.new(1, -20, 0.19, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex = 3,
				}, 10)
				if Style then
					Style.degrade(bandeau, bleu[1], bleu[2])
					Style.bordure(bandeau, 3)
				else
					bandeau.BackgroundColor3 = bleu[2]
				end
				texte(bandeau, {
					Name = "Titre",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.9, 0.8),
					Text = "COMMENT JOUER ?",
					ZIndex = 4,
					titre = true,
				}, 4)

				-- une pastille arrondie par règle
				for i, ligne in ipairs(lignes) do
					local pastille = cadreGui(fond, {
						Name = "Regle" .. i,
						Position = UDim2.new(0.04, 0, 0.245 + (i - 1) * 0.152, 0),
						Size = UDim2.new(0.92, 0, 0.13, 0),
						BackgroundColor3 = carte,
						BackgroundTransparency = 0.15,
						ZIndex = 3,
					}, 8)
					texte(pastille, {
						Name = "Ligne" .. i,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -16, 1, -4),
						Text = ligne.texte,
						TextColor3 = ligne.couleur,
						ZIndex = 4,
					}, 3)
				end

				texte(fond, {
					Name = "Pied",
					Position = UDim2.fromScale(0.1, 0.86),
					Size = UDim2.fromScale(0.8, 0.1),
					Text = pied,
					TextColor3 = vert,
					ZIndex = 4,
				}, 3)
			end)
		end

		local ok, err = pcall(function()
			affiche(Enum.NormalId.Front) -- côté Place
			affiche(Enum.NormalId.Back)  -- côté Bases
		end)
		if not ok then
			warn("[Dino] Signaletique / affiche des règles : " .. tostring(err))
		end
	end)

	dossier:SetAttribute("Parts", nbParts)
end

return M
