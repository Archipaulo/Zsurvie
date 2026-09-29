-- Constructeur Signaletique (plan v2 « plus d'air ») : panneaux-flèches en bois, finition « pro » (STYLE.md §4).
-- Chaque panneau : socle de pierre rond, poteau en bois coiffé d'une petite gemme Neon qui « respire »,
-- planche en WoodPlanks aux bords biseautés côté arrière (coins) et pointe de flèche peinte côté destination.
-- Sur chaque face, une plaque peinte en dégradé, cerclée de noir, avec reflet, clous et texte blanc cerné ;
-- les flèches du texte sont recalculées pour chaque face : elles pointent toujours dans la bonne direction.
-- Placement (tout est lu dans Plan.lua, aucune coordonnée en dur) :
--   * Place : Boutique et Renaissance au bord de la Place, sur le côté sud du lien vers le Comptoir / l'Autel
--     (le côté nord de l'ouest est au tableau d'honneur) ; Dinos à l'est de l'entrée nord, dans
--     l'alignement de la torche nord-est et du lampadaire (hors de l'entrée et de la margelle) ; Dinodex entre l'apparition
--     et la borne. Distances en fractions de Plan.place.rayon.
--   * bouts du Tapis : « ← NURSERIE » et « GRANDE PORTE → » des deux côtés, au bord extérieur de la
--     promenade (|z| = Plan.promenade.zMax - bordPromenade), sur le côté des demi-lunes, un peu au-delà des
--     bouts du Tapis : hors des contre-allées, des disques Nurserie / Grande Porte et loin des torches ;
--     la promenade reste entièrement libre de |z| = 11 à 23 sur toute sa longueur.
--   * entrée des allées centrales (Plan.allees) : le long du mur est, juste après le coin des Bases, « PLACE »
--     au sud et « CRATÈRE » au nord ; le milieu de l'allée et la promenade restent libres.
--   * tableau des règles à toit de bardeaux : sur l'herbe au nord-est de la Place, entre son anneau et le
--     chemin de ronde des Bases, tourné vers le centre de la Place.
-- Emprise (CONTRAT §10) : Place et ses abords, bouts du Tapis, entrées des allées (props en bordure seulement).
local M = {}

local BUDGET = 120 -- parts au maximum pour ce constructeur (≈ 102 utilisées)

-- valeurs par défaut, remplaçables par Equilibrage.signaletique (distances, jamais de position)
local DEFAUTS = {
	largeurFleche = 9,      -- largeur d'une planche indicatrice
	-- Place (« × rayon » : fractions de Plan.place.rayon)
	reculLien = 1,          -- × rayon : panneaux Boutique / Renaissance, du centre vers le Comptoir / l'Autel
	gardeLien = 7.2,        -- décalage vers le sud depuis l'axe du lien (bord du chemin de sable)
	tapisX = 0.65,          -- × rayon : panneau vers le Tapis, décalage est (x ≈ 14 : à l'est de la torche nord-est
	                        -- et du lampadaire à 305°, hors de l'entrée nord et loin de la margelle de la fontaine)
	tapisRecul = 0.875,     -- × rayon : ... et distance au nord du centre (z ≈ 92,75 : talon à ~3 du lampadaire)
	dinodexX = -0.2,        -- × rayon : panneau vers le Dinodex, décalage ouest (hors de l'apparition)
	dinodexRecul = 0.39,    -- × rayon : ... et distance au sud du centre
	distanceBorne = 0.83,   -- × rayon : position de la borne Dinodex si elle est introuvable
	-- bouts du Tapis
	bordPromenade = 2.2,    -- poteau à cette distance du bord extérieur de la promenade (socle hors des galets)
	reculBout = 4,          -- poteau à cette distance au-delà du bout du Tapis, sur le côté de la demi-lune
	-- entrée des allées
	reculAllee = 0.5,       -- le talon du panneau commence à cette distance après le coin des Bases (dans l'allée)
	retraitAllee = 3,       -- distance entre le mur de la Base et le poteau (hors des piliers d'angle)
	-- tableau des règles (« × rayon » depuis le centre de la Place)
	reglesX = 1.4,          -- × rayon : décalage est
	reglesRecul = 0.62,     -- × rayon : distance au nord
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
local PARTS_FLECHE = 9        -- socle, poteau, gemme, planche, talon, 2 biseaux, 2 demi-pointes
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
	local Plan = ctx.Plan or {}
	local E = ctx.Equilibrage or {}
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	-- la Place (centre et rayon) : sans elle, pas de panneaux de Place ni de règles
	local infoPlace = Plan.place
	local placeOk = type(infoPlace) == "table" and typeof(infoPlace.centre) == "Vector3" and type(infoPlace.rayon) == "number"
	local CX, CZ, RAYON = 0, 0, 0
	if placeOk then
		CX, CZ, RAYON = infoPlace.centre.X, infoPlace.centre.Z, infoPlace.rayon
	end

	local NOIR = Charte.encre
	local BLANC = Charte.creme
	if Style and Style.couleurs then
		NOIR = Style.couleurs.contour
		BLANC = Style.couleurs.texte
	end

	-- bois en trois teintes (base, ombre, lumière) et pierre des socles
	local BOIS = Charte.bois
	local BOIS_SOMBRE = Charte.ombre(Charte.bois)
	local PIERRE = Charte.lumiere(Charte.pierre)
	local MAT_PLANCHES = Enum.Material.WoodPlanks
	local MAT_BOIS = Enum.Material.Wood
	local MAT_PIERRE = Enum.Material.Slate

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
	-- talon biseauté à l'arrière, pointe peinte au bout, gemme lumineuse au sommet du poteau
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
		-- gemme Neon aux couleurs de la destination, qui « respire » doucement (client, Interface/AnimationsDecor)
		local gemme = Outils.boule(m, {
			Name = "Boule",
			Size = Vector3.new(0.95, 0.95, 0.95),
			CFrame = CFrame.new(x, y0 + hPoteau + 0.35, z),
			Color = couleurs[1],
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		Outils.animer(gemme, "pulse", 1.6)

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

		-- titre flottant facultatif : discret, juste au-dessus de la gemme
		if info.titre then
			titreFlottant(planche, {
				{ texte = info.titre, couleur = couleurs[1], titre = true, contour = 4 },
			}, {
				Name = "Titre",
				largeur = 9,
				hauteurLigne = 1.6,
				StudsOffset = Vector3.new(0, 2.6, 0),
				MaxDistance = 90,
			})
		end
		return m
	end

	-- longueur du panneau derrière le poteau (talon compris)
	local DEMI_ARRIERE = R.largeurFleche / 2 + BISEAU

	-- ===== 1. panneaux-flèches sur la Place =====
	if placeOk then
		etape("place", function()
			local m = Outils.modele(dossier, "Place")

			-- Boutique : façade du Comptoir, ouverte vers la Place (+X) ; panneau au bord sud du lien
			if Plan.comptoir and typeof(Plan.comptoir.centre) == "Vector3" then
				local demiLargeur = 0
				if typeof(Plan.comptoir.taille) == "Vector3" then
					demiLargeur = Plan.comptoir.taille.X / 2
				end
				local cible = Plan.comptoir.centre + Vector3.new(demiLargeur, 0, 0)
				local sensX = 1
				if cible.X < CX then
					sensX = -1
				end
				local pos = Vector3.new(CX + sensX * RAYON * R.reculLien, 0, Plan.comptoir.centre.Z + R.gardeLien)
				fleche(m, {
					nom = "VersBoutique",
					droite = "BOUTIQUE →",
					gauche = "← BOUTIQUE",
					couleurs = palette("orange", Charte.lave),
				}, pos, cible - pos)
			end

			-- Renaissance : l'Autel ; panneau au bord sud du lien (symétrique de la Boutique)
			if Plan.autel and typeof(Plan.autel.centre) == "Vector3" then
				local cible = Plan.autel.centre
				local sensX = 1
				if cible.X < CX then
					sensX = -1
				end
				local pos = Vector3.new(CX + sensX * RAYON * R.reculLien, 0, cible.Z + R.gardeLien)
				fleche(m, {
					nom = "VersRenaissance",
					droite = "RENAISSANCE →",
					gauche = "← RENAISSANCE",
					couleurs = palette("violet", Charte.violet),
				}, pos, cible - pos)
			end

			-- Tapis : vers le nord, par l'allée centrale (à côté de la fontaine)
			if Plan.tapis and typeof(Plan.tapis.debut) == "Vector3" and typeof(Plan.tapis.fin) == "Vector3" then
				local milieu = (Plan.tapis.debut + Plan.tapis.fin) / 2
				local cible = Vector3.new(CX, 0, milieu.Z)
				local versNord = 1
				if milieu.Z < CZ then
					versNord = -1
				end
				local pos = Vector3.new(CX + RAYON * R.tapisX, 0, CZ + versNord * RAYON * R.tapisRecul)
				fleche(m, {
					nom = "VersTapis",
					droite = "DINOS →",
					gauche = "← DINOS",
					couleurs = palette("rouge", Charte.tapis),
				}, pos, cible - pos)
			end

			-- Dinodex : la borne au bord sud de la Place (position réelle si elle existe)
			local cibleBorne = Vector3.new(CX, 0, CZ + RAYON * R.distanceBorne)
			local place = ctx.racine and ctx.racine:FindFirstChild("Place")
			local borne = place and place:FindFirstChild("Dinodex", true)
			if borne and borne:IsA("Model") then
				local ok, pivot = pcall(function()
					return borne:GetPivot()
				end)
				if ok and pivot then
					cibleBorne = Vector3.new(pivot.Position.X, 0, pivot.Position.Z)
				end
			end
			local posDinodex = Vector3.new(CX + RAYON * R.dinodexX, 0, CZ + RAYON * R.dinodexRecul)
			fleche(m, {
				nom = "VersDinodex",
				droite = "DINODEX →",
				gauche = "← DINODEX",
				couleurs = palette("bleu", Charte.gemme),
			}, posDinodex, cibleBorne - posDinodex)
		end)
	end

	-- ===== 2. les deux bouts du Tapis (des deux côtés, au bord extérieur de la promenade) =====
	local tapis = Plan.tapis
	if type(tapis) == "table" and typeof(tapis.debut) == "Vector3" and typeof(tapis.fin) == "Vector3" then
		etape("tapis", function()
			local m = Outils.modele(dossier, "Tapis")
			local debut, fin = tapis.debut, tapis.fin
			local sens = Vector3.new(fin.X - debut.X, 0, fin.Z - debut.Z)
			if sens.Magnitude < 0.01 then
				return
			end
			sens = sens.Unit
			local cote = Vector3.new(-sens.Z, 0, sens.X) -- perpendiculaire au Tapis, dans le plan
			-- bord extérieur de la promenade (côté façade des Bases) : la bande où l'on circule reste libre
			local zPromenade = nil
			if type(Plan.promenade) == "table" and type(Plan.promenade.zMax) == "number" then
				zPromenade = Plan.promenade.zMax
			else
				local emprise = tapis.emprise
				if type(emprise) ~= "number" then
					emprise = (tapis.largeur or 0) / 2 + 2.5
				end
				zPromenade = emprise + 17.5
			end
			local ecart = zPromenade - R.bordPromenade

			for _, s in ipairs({ 1, -1 }) do
				-- début : la flèche montre la Nurserie (d'où sortent les dinos) ; poteau au-delà du bout du Tapis,
				-- hors de l'embouchure de la contre-allée qui longe la dernière Base
				local posDebut = debut - sens * R.reculBout + cote * (ecart * s)
				fleche(m, {
					nom = "Nurserie",
					droite = "NURSERIE →",
					gauche = "← NURSERIE",
					couleurs = palette("vert", Charte.herbe),
				}, Vector3.new(posDebut.X, 0, posDebut.Z), -sens)

				-- fin : les dinos invendus passent la Grande Porte
				local posFin = fin + sens * R.reculBout + cote * (ecart * s)
				fleche(m, {
					nom = "GrandePorte",
					droite = "GRANDE PORTE →",
					gauche = "← GRANDE PORTE",
					couleurs = palette("jaune", Charte.dore),
				}, Vector3.new(posFin.X, 0, posFin.Z), sens)
			end
		end)
	end

	-- ===== 3. entrée des allées centrales, côté promenade =====
	-- l'allée la plus proche de la Place (au sud) mène à la Place, celle la plus proche du Cratère (au nord) au Cratère
	local allees = Plan.allees
	if type(allees) == "table" and type(allees.x) == "table" and #allees.x > 0 and type(allees.zMin) == "number" then
		etape("allees", function()
			local m = Outils.modele(dossier, "Allees")
			local demi = (allees.largeur or 0) / 2
			local zAxe = 0
			if tapis and typeof(tapis.debut) == "Vector3" and typeof(tapis.fin) == "Vector3" then
				zAxe = (tapis.debut.Z + tapis.fin.Z) / 2
			end

			local function plusProche(xCible)
				local meilleur = allees.x[1]
				for _, xa in ipairs(allees.x) do
					if math.abs(xa - xCible) < math.abs(meilleur - xCible) then
						meilleur = xa
					end
				end
				return meilleur
			end

			-- panneau le long du mur est de l'allée, juste après le coin des Bases, la flèche vers le fond de l'allée
			local function entree(nom, cible, texteDestination, couleurs)
				local s = 1
				if cible.Z < zAxe then
					s = -1
				end
				local xa = plusProche(cible.X)
				local pos = Vector3.new(xa + demi - R.retraitAllee, 0, zAxe + s * (allees.zMin + R.reculAllee + DEMI_ARRIERE))
				fleche(m, {
					nom = nom,
					droite = texteDestination .. " →",
					gauche = "← " .. texteDestination,
					couleurs = couleurs,
				}, pos, Vector3.new(0, 0, s))
			end

			if placeOk then
				entree("VersPlace", infoPlace.centre, "PLACE", palette("rose", Charte.alerte))
			end
			if Plan.cratere and typeof(Plan.cratere.centre) == "Vector3" then
				entree("VersCratere", Plan.cratere.centre, "CRATÈRE", palette("orange", Charte.lave))
			end
		end)
	end

	-- ===== 4. tableau des règles, au nord-est de la Place =====
	-- sur l'herbe entre l'anneau de la Place et le chemin de ronde des Bases, tourné vers le centre de la Place
	if not placeOk then
		dossier:SetAttribute("Parts", nbParts)
		return
	end
	etape("regles", function()
		local m = Outils.modele(dossier, "Regles")
		local L = R.reglesLargeur
		local H = R.reglesHauteur
		local bas = R.reglesBas
		local px, pz = CX + RAYON * R.reglesX, CZ - RAYON * R.reglesRecul
		-- repère au sol, face avant du panneau (-Z local) tournée vers le centre de la Place
		local repere = CFrame.lookAt(Vector3.new(px, 0, pz), Vector3.new(CX, 0, CZ))
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
		-- œuf doré qui flotte au-dessus du faîtage, entouré de quelques étincelles
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
			local ok, err = pcall(function()
				local e = Instance.new("ParticleEmitter")
				e.Name = "Etincelles"
				e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				e.Color = ColorSequence.new(Charte.dore, Charte.creme)
				e.LightEmission = 1
				e.Rate = 3
				e.Lifetime = NumberRange.new(1, 1.6)
				e.Speed = NumberRange.new(0.4, 1)
				e.SpreadAngle = Vector2.new(180, 180)
				e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
				e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
				e.Parent = oeuf
			end)
			if not ok then
				warn("[Dino] Signaletique / étincelles : " .. tostring(err))
			end
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
