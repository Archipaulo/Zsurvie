-- Constructeur Signaletique : panneaux-flèches épais aux couleurs vives, look « simulateur Roblox » (STYLE.md).
-- Sur la Place, quatre panneaux-flèches (planche orientée vers la destination, pointe au bout) :
-- Boutique (Comptoir, ouest, orange), Renaissance (Autel, est, violet), Dinos à vendre (Tapis, nord, rouge),
-- Dinodex (borne, sud, bleu). Au-dessus de chacun, un titre géant flottant cerné de noir (Style.etiquette).
-- Au début du Tapis « NURSERIE → », à la fin « GRANDE PORTE → », de chaque côté du Tapis.
-- Au nord de la Place, face aux joueurs qui apparaissent, un panneau de règles court et lisible.
-- Les flèches du texte sont recalculées pour chaque face : elles pointent toujours dans la bonne direction.
-- Emprise (CONTRAT §10) : Place (hors secteur du tableau d'honneur) et bouts du Tapis.
local M = {}

local BUDGET = 100 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.signaletique
local DEFAUTS = {
	largeurFleche = 9,      -- largeur d'une planche indicatrice
	reculBoutPlace = 17,    -- distance des panneaux Boutique / Renaissance au centre (sur l'axe est-ouest)
	decalageAllee = 3.5,    -- décalage vers le sud pour laisser les allées libres
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
local HAUTEUR_POTEAU = 5
local HAUTEUR_PLANCHE = 2.6
local EPAISSEUR_PLANCHE = 0.9
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

	-- palette { haut, bas } d'une couleur de bouton (Style.boutons), avec repli sur la Charte
	local function palette(nom, repli)
		if Style and Style.boutons and Style.boutons[nom] then
			return Style.boutons[nom]
		end
		return { repli, repli }
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

	-- face d'une planche : fond en dégradé vif, bordure noire épaisse, texte blanc cerné
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
		fond.Size = UDim2.new(1, -12, 1, -12)
		fond.BackgroundColor3 = Color3.new(1, 1, 1)
		fond.BorderSizePixel = 0
		if Style then
			Style.coins(fond, 14)
			Style.bordure(fond, 6)
			Style.degrade(fond, couleurs[1], couleurs[2])
		else
			fond.BackgroundColor3 = couleurs[2]
		end
		fond.Parent = gui
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

	-- panneau-flèche : planche épaisse orientée vers la destination, pointe au bout, titre flottant
	-- info : { nom, titre, droite, gauche, couleurs = { haut, bas } }
	local function fleche(parent, info, position, direction)
		local d = Vector3.new(direction.X, 0, direction.Z)
		if d.Magnitude < 0.01 then
			d = Vector3.new(1, 0, 0)
		end
		d = d.Unit
		-- l'axe X local de la planche pointe vers la destination
		local angle = math.deg(math.atan2(-d.Z, d.X))
		local largeur = R.largeurFleche
		local couleurs = info.couleurs
		if not reserver(2) then return nil end

		local m = Outils.modele(parent, info.nom)
		local tailleP = Vector3.new(0.8, HAUTEUR_POTEAU, 0.8)
		Outils.bloc(m, {
			Name = "Poteau",
			Size = tailleP,
			CFrame = Outils.surSol(tailleP, position.X, position.Z, angle, position.Y),
			Color = NOIR,
		})
		local planche = Outils.bloc(m, {
			Name = "Planche",
			Size = Vector3.new(largeur, HAUTEUR_PLANCHE, EPAISSEUR_PLANCHE),
			CFrame = CFrame.new(position.X, position.Y + HAUTEUR_POTEAU, position.Z) * CFrame.Angles(0, math.rad(angle), 0),
			Color = couleurs[2],
			CanCollide = false,
		})
		m.PrimaryPart = planche

		-- faces : la face arrière se lit vers +X local, la face avant vers -X local
		for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
			local droite = planche.CFrame.RightVector
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
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -24, 1, -16),
					Text = mot,
					titre = true,
				}, 4)
			end)
		end

		-- pointe en losange, cernée de noir par un losange plus grand derrière
		bloc(m, {
			Name = "Pointe",
			Size = Vector3.new(1.8, 1.8, EPAISSEUR_PLANCHE + 0.1),
			CFrame = planche.CFrame * CFrame.new(largeur / 2, 0, 0) * CFrame.Angles(0, 0, math.rad(45)),
			Color = couleurs[1],
			CanCollide = false,
		})
		bloc(m, {
			Name = "PointeContour",
			Size = Vector3.new(2.2, 2.2, EPAISSEUR_PLANCHE - 0.1),
			CFrame = planche.CFrame * CFrame.new(largeur / 2, 0, 0) * CFrame.Angles(0, 0, math.rad(45)),
			Color = NOIR,
			CanCollide = false,
		})
		-- pied de pierre claire
		bloc(m, {
			Name = "Pied",
			Size = Vector3.new(1.6, 0.5, 1.6),
			CFrame = Outils.surSol(Vector3.new(1.6, 0.5, 1.6), position.X, position.Z, angle, position.Y),
			Color = Charte.sable,
		})

		-- titre géant flottant, lisible de loin (et sur mobile)
		if info.titre then
			titreFlottant(planche, {
				{ texte = info.titre, couleur = couleurs[1], titre = true, contour = 4 },
			}, {
				Name = "Titre",
				largeur = 14,
				hauteurLigne = 2.4,
				StudsOffset = Vector3.new(0, 3.2, 0),
				MaxDistance = 150,
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
			titre = "🛒 BOUTIQUE →",
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
			titre = "♻️ RENAISSANCE →",
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
			titre = "🦖 DINOS À VENDRE",
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
			titre = "📖 DINODEX",
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

	-- ===== 3. panneau des règles, face à la Place =====
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
		local hPoteau = bas + H + 0.4
		local bleu = palette("bleu", Charte.gemme)

		for _, s in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Poteau",
				Size = Vector3.new(1, hPoteau, 1),
				CFrame = ici(s * (L / 2 + 0.9), hPoteau / 2, 0),
				Color = NOIR,
			})
			bloc(m, {
				Name = "Pied",
				Size = Vector3.new(1.8, 0.6, 1.8),
				CFrame = ici(s * (L / 2 + 0.9), 0.3, 0),
				Color = Charte.sable,
			})
		end
		local planche = bloc(m, {
			Name = "Planche",
			Size = Vector3.new(L, H, 1),
			CFrame = ici(0, yMilieu, 0),
			Color = Style and Style.couleurs.fond or Charte.nuit,
		})
		-- cadre noir épais, façon bordure cartoon
		bloc(m, { Name = "Cadre", Size = Vector3.new(L + 1.2, 0.6, 1.2), CFrame = ici(0, bas + H + 0.3, 0), Color = NOIR })
		bloc(m, { Name = "Cadre", Size = Vector3.new(L + 1.2, 0.6, 1.2), CFrame = ici(0, bas - 0.3, 0), Color = NOIR })
		bloc(m, { Name = "Cadre", Size = Vector3.new(0.6, H, 1.2), CFrame = ici(-L / 2 - 0.3, yMilieu, 0), Color = NOIR })
		bloc(m, { Name = "Cadre", Size = Vector3.new(0.6, H, 1.2), CFrame = ici(L / 2 + 0.3, yMilieu, 0), Color = NOIR })
		-- œuf doré qui flotte au-dessus
		local oeuf = boule(m, {
			Name = "Oeuf",
			Size = Vector3.new(1.4, 1.8, 1.4),
			CFrame = ici(0, hPoteau + 4.2, 0),
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

		-- titre géant flottant
		titreFlottant(planche, {
			{ texte = "📜 RÈGLES", couleur = Style and Style.couleurs.revenu or Charte.dore, titre = true, contour = 4 },
		}, {
			Name = "Titre",
			largeur = 12,
			hauteurLigne = 2.6,
			StudsOffset = Vector3.new(0, H / 2 + 1.6, 0),
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
		if Style and Style.couleurs then
			vert = Style.couleurs.argent
			jaune = Style.couleurs.revenu
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
			faceCartoon(planche, face, { bleu[1], bleu[2] }, function(fond)
				-- le fond du panneau reste sombre : on retire le dégradé bleu, gardé pour le bandeau
				local degrade = fond:FindFirstChildOfClass("UIGradient")
				if degrade then
					degrade:Destroy()
				end
				fond.BackgroundColor3 = Style and Style.couleurs.fond or Charte.nuit

				local bandeau = Instance.new("Frame")
				bandeau.Name = "Bandeau"
				bandeau.BorderSizePixel = 0
				bandeau.BackgroundColor3 = Color3.new(1, 1, 1)
				bandeau.Size = UDim2.fromScale(1, 0.2)
				if Style then
					Style.coins(bandeau, 14)
					Style.degrade(bandeau, bleu[1], bleu[2])
				else
					bandeau.BackgroundColor3 = bleu[2]
				end
				bandeau.Parent = fond
				texte(bandeau, {
					Name = "Titre",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.9, 0.8),
					Text = "COMMENT JOUER ?",
					titre = true,
				}, 4)

				for i, ligne in ipairs(lignes) do
					texte(fond, {
						Name = "Ligne" .. i,
						Position = UDim2.fromScale(0.05, 0.23 + (i - 1) * 0.155),
						Size = UDim2.fromScale(0.9, 0.14),
						Text = ligne.texte,
						TextColor3 = ligne.couleur,
					}, 4)
				end

				texte(fond, {
					Name = "Pied",
					Position = UDim2.fromScale(0.1, 0.86),
					Size = UDim2.fromScale(0.8, 0.1),
					Text = pied,
					TextColor3 = vert,
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
