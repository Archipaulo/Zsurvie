-- Constructeur Bases : les 8 Bases des joueurs (CONTRAT §5), rendu « version 2 » (STYLE.md §4).
-- Chaque Base se reconnaît à la couleur de son sol : dalle d'ardoise teintée (couleur claire de la base) bordée d'ardoise
-- sur 44 x 50 avec rampe d'entrée de la même teinte, allée dans l'ombre de la couleur, murets de brique peints sous
-- couvertine d'ardoise, piliers d'angle arrondis coiffés d'une lanterne, portique de métal peint éclairé par deux spots,
-- enseigne encadrée lisible des deux côtés, gros bouton de verrou rouge sur socle de métal, dalle de collecte en tôle verte,
-- 12 podiums (2 rangées de 6 le long des murs, face à face) carrés aux arêtes arrondies à plateau de métal et bandeau lumineux,
-- point d'apparition au fond, plantes et caisses contre les murs.
-- Repère local d'une base : x en travers, z positif vers le Tapis (l'entrée). Les bases du sud sont tournées de 180°.
-- Emprise (CONTRAT §10) : le rectangle 44 x 50 de chaque base, rien entre elles. Budget : 170 parts par base.
local M = {}

local BUDGET = 170
local OBLIGATOIRES = 20 -- Sol, Rampe, Entree, Enseigne, BoutonVerrou, Collecte, E1..E12, Apparition, Zone
local LARGEUR_ENTREE = 12
local HAUTEUR_ZONE = 30
local ECART_PODIUMS = 9

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end
	if type(Plan.bases) ~= "table" then
		return
	end

	local reglage = Plan.base or {}
	local LARGEUR = tonumber(reglage.largeur) or 44
	local PROFONDEUR = tonumber(reglage.profondeur) or 50
	local H = tonumber(reglage.hauteurSol) or 1
	local NB_EMPLACEMENTS = tonumber(reglage.emplacementsMax) or 12
	local demiL = LARGEUR / 2
	local demiP = PROFONDEUR / 2
	local hex = Charte.hex
	local Mat = Enum.Material

	-- palette des matériaux bâtis : ardoise, métal (les sols prennent la teinte de chaque base)
	local ARDOISE = hex("4A505E")
	local METAL = hex("C3C9D3")
	local METAL_SOMBRE = hex("383D48")
	local VERT_TOLE = hex("39C24B")
	local ROUGE = hex("F0223C")
	local LUMIERE_SPOT = hex("FFF1D6")
	if Style and Style.boutons and Style.boutons.rouge then
		ROUGE = Style.boutons.rouge[2] or ROUGE
	end

	-- couleur saturée de chaque base (une par index) ; publiée dans l'attribut « Couleur » pour Systemes/Bases
	local teintes = {
		Charte.lave, hex("2F8CFF"), Charte.violet, Charte.dore,
		Charte.alerte, hex("12C9A6"), hex("FF4FC8"), hex("3FD13A"),
	}

	local VERTICAL = CFrame.Angles(0, 0, math.rad(90)) -- axe X du cylindre dressé à la verticale

	-- texte blanc cerné de noir sur une face de part (SurfaceGui), via ctx.Style si disponible
	local function texteFace(part, face, nomGui, nomTexte, texte, pixels)
		if not (Style and Style.texte) then
			local t = Outils.texte(part, face, texte, { couleur = Charte.creme, pixelsParStud = pixels })
			t.Name = nomTexte
			if t.Parent then
				t.Parent.Name = nomGui
			end
			return t
		end
		local gui = Instance.new("SurfaceGui")
		gui.Name = nomGui
		gui.Face = Enum.NormalId[face]
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = pixels or 30
		gui.LightInfluence = 0
		gui.Parent = part
		return Style.texte(gui, {
			Name = nomTexte,
			Size = UDim2.fromScale(0.92, 0.8),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = texte,
			titre = true,
			contour = 4,
		})
	end

	local function construireBase(index, donnees)
		local centre = donnees.centre
		if typeof(centre) ~= "Vector3" then
			return
		end
		local sens = 1
		if type(donnees.versTapis) == "number" and donnees.versTapis < 0 then
			sens = -1
		end
		-- rotation exacte de 0° ou 180° autour de Y : z local positif = vers le Tapis
		local repere = CFrame.new(centre.X, centre.Y, centre.Z, sens, 0, 0, 0, 1, 0, 0, 0, sens)

		local function ici(x, y, z, rotation)
			local cf = repere * CFrame.new(x, y, z)
			if rotation then
				cf = cf * rotation
			end
			return cf
		end

		local couleur = teintes[((index - 1) % #teintes) + 1] or Charte.lave
		local couleurClaire = Charte.lumiere(couleur)
		local couleurSombre = Charte.ombre(couleur)
		-- teinte du sol : la couleur claire de la base, adoucie vers le blanc (chaque base se reconnaît de loin)
		local couleurSol = couleurClaire:Lerp(Color3.new(1, 1, 1), 0.55)

		local modele = Outils.modele(dossier, "Base" .. index)
		modele:SetAttribute("Index", index)
		modele:SetAttribute("Couleur", couleur)
		local decor = Outils.modele(modele, "Decor")

		-- compteur de parts : les pièces obligatoires ont leur place réservée, le décor s'arrête avant le budget
		local compte = 0
		local reserve = OBLIGATOIRES
		local function place(n)
			return compte + reserve + n <= BUDGET
		end
		local function part(fabrique, parent, props, facultatif)
			if facultatif then
				if not place(1) then
					return nil
				end
			else
				reserve = math.max(0, reserve - 1)
			end
			compte = compte + 1
			return fabrique(parent, props)
		end
		-- pilier arrondi (6 parts)
		local function arrondi(props, rayon)
			if not place(6) then
				return nil
			end
			compte = compte + 6
			return Outils.blocArrondi(decor, props, rayon)
		end

		-- ===== dalle d'ardoise teintée bordée d'ardoise sombre, et rampe =====
		local BORD = 0.4
		local longueurSol = PROFONDEUR - 3
		local zAvant = -demiP + longueurSol -- bord avant de la plateforme (début de la rampe)
		local cfSol = ici(0, H / 2, -demiP + longueurSol / 2)
		local sol, liseret
		if place(1) then
			compte = compte + 2
			reserve = reserve - 1
			sol, liseret = Outils.dalleBordee(modele, {
				Name = "Sol",
				Size = Vector3.new(LARGEUR - 2 * BORD, H, longueurSol - 2 * BORD),
				CFrame = cfSol,
				Color = couleurSol,
				Material = Mat.Slate,
				MaterialBord = Mat.Slate,
			}, BORD, ARDOISE)
			if liseret then
				liseret.Parent = decor
			end
		else
			sol = part(Outils.bloc, modele, {
				Name = "Sol",
				Size = Vector3.new(LARGEUR, H, longueurSol),
				CFrame = cfSol,
				Color = couleurSol,
				Material = Mat.Slate,
			})
		end
		modele.PrimaryPart = sol

		-- la rampe descend vers le Tapis : coin retourné d'un demi-tour, le haut contre la plateforme
		local zRampe = zAvant - BORD
		part(Outils.coin, modele, {
			Name = "Rampe",
			Size = Vector3.new(LARGEUR_ENTREE, H, demiP - zRampe),
			CFrame = ici(0, H / 2, (zRampe + demiP) / 2, CFrame.Angles(0, math.pi, 0)),
			Color = couleurSol,
			Material = Mat.Slate,
		})

		-- ===== murets de brique peints dans la couleur de la base, couvertine d'ardoise =====
		local HAUT_MURET = 3.5
		local EP_MURET = 1
		local function muret(x, z, sx, sz)
			part(Outils.bloc, decor, {
				Name = "Muret",
				Size = Vector3.new(sx, HAUT_MURET, sz),
				CFrame = ici(x, H + HAUT_MURET / 2, z),
				Color = couleur,
				Material = Mat.Brick,
			}, true)
			local debord = 0.5
			local lx, lz = sx + debord, sz + debord
			if sx > sz then
				lx = sx
			else
				lz = sz
			end
			part(Outils.bloc, decor, {
				Name = "Couvertine",
				Size = Vector3.new(lx, 0.4, lz),
				CFrame = ici(x, H + HAUT_MURET + 0.2, z),
				Color = ARDOISE,
				Material = Mat.Slate,
			}, true)
		end
		local xCote = demiL - BORD - EP_MURET / 2
		local zFond = -demiP + BORD + EP_MURET / 2
		local zFacade = zAvant - BORD - EP_MURET / 2
		local zMilieu = (zFond + zFacade) / 2
		muret(0, zFond, LARGEUR - 2 * BORD, EP_MURET)
		muret(-xCote, zMilieu, EP_MURET, zFacade - zFond)
		muret(xCote, zMilieu, EP_MURET, zFacade - zFond)
		local debutFacade = LARGEUR_ENTREE / 2 + 2.5
		local finFacade = demiL - BORD
		local longueurFacade = finFacade - debutFacade
		muret(-(debutFacade + longueurFacade / 2), zFacade, longueurFacade, EP_MURET)
		muret(debutFacade + longueurFacade / 2, zFacade, longueurFacade, EP_MURET)

		-- ===== piliers d'angle arrondis (ombre de la couleur), chapeau d'ardoise et lanterne =====
		local HAUT_PILIER = HAUT_MURET + 1.6
		local xPilier = demiL - BORD - 1.3
		local positionsPiliers = {
			{ -xPilier, zFond - 0.5 + 1.3 }, { xPilier, zFond - 0.5 + 1.3 },
			{ -xPilier, zFacade + 0.5 - 1.3 }, { xPilier, zFacade + 0.5 - 1.3 },
		}
		for _, p in ipairs(positionsPiliers) do
			arrondi({
				Name = "Pilier",
				Size = Vector3.new(2.6, HAUT_PILIER, 2.6),
				CFrame = ici(p[1], H + HAUT_PILIER / 2, p[2]),
				Color = couleurSombre,
				Material = Mat.Plaster,
			}, 0.7)
			part(Outils.cylindre, decor, {
				Name = "Chapeau",
				Size = Vector3.new(0.5, 3.1, 3.1),
				CFrame = ici(p[1], H + HAUT_PILIER + 0.25, p[2], VERTICAL),
				Color = ARDOISE,
				Material = Mat.Slate,
			}, true)
			part(Outils.boule, decor, {
				Name = "Lanterne",
				Size = Vector3.new(1.3, 1.3, 1.3),
				CFrame = ici(p[1], H + HAUT_PILIER + 1.1, p[2]),
				Color = couleurClaire,
				Material = Mat.Neon,
				CanCollide = false,
				CastShadow = false,
			}, true)
		end

		-- ===== portique d'entrée en métal peint, socles d'ardoise, deux spots vers le sol =====
		local HAUT_PORTIQUE = 12
		local xPoteau = LARGEUR_ENTREE / 2 + 1.25
		for _, cote in ipairs({ -1, 1 }) do
			part(Outils.bloc, decor, {
				Name = "SoclePoteau",
				Size = Vector3.new(3.3, 1.2, 3.3),
				CFrame = ici(cote * xPoteau, H + 0.6, zFacade),
				Color = ARDOISE,
				Material = Mat.Slate,
			}, true)
			part(Outils.bloc, decor, {
				Name = "Poteau",
				Size = Vector3.new(2.5, H + HAUT_PORTIQUE, 2.5),
				CFrame = ici(cote * xPoteau, (H + HAUT_PORTIQUE) / 2, zFacade),
				Color = couleur,
				Material = Mat.Metal,
			}, true)
		end
		local yLinteau = H + HAUT_PORTIQUE + 1
		part(Outils.bloc, decor, {
			Name = "Linteau",
			Size = Vector3.new(LARGEUR_ENTREE + 5, 2, 2.9),
			CFrame = ici(0, yLinteau, zFacade),
			Color = couleurSombre,
			Material = Mat.Metal,
		}, true)
		for _, cote in ipairs({ -1, 1 }) do
			local spot = part(Outils.bloc, decor, {
				Name = "Projecteur",
				Size = Vector3.new(1.3, 0.7, 1.3),
				CFrame = ici(cote * 3.5, yLinteau - 1.35, zFacade),
				Color = METAL_SOMBRE,
				Material = Mat.Metal,
				CanCollide = false,
			}, true)
			if spot then
				local lumiere = Outils.lumiere(spot, { genre = "Spot", Range = 18, Brightness = 4, Color = LUMIERE_SPOT })
				pcall(function()
					lumiere.Face = Enum.NormalId.Bottom
					lumiere.Angle = 75
					lumiere.Shadows = true
				end)
			end
		end

		-- enseigne lisible des deux côtés : panneau de métal peint serti dans un cadre sombre centré sur la façade.
		-- Le panneau (1,3) est un peu plus épais que le cadre (1,0) : il dépasse de 0,15 de chaque côté et le cadre
		-- forme une bordure de 0,6 tout autour, vue du Tapis comme de l'intérieur de la base.
		local yEnseigne = yLinteau + 1 + 2.9
		part(Outils.bloc, decor, {
			Name = "CadreEnseigne",
			Size = Vector3.new(LARGEUR_ENTREE + 5.6, 6.4, 1.0),
			CFrame = ici(0, yEnseigne, zFacade),
			Color = couleurSombre,
			Material = Mat.Metal,
		}, true)
		local enseigne = part(Outils.bloc, modele, {
			Name = "Enseigne",
			Size = Vector3.new(LARGEUR_ENTREE + 4.4, 5.2, 1.3),
			CFrame = ici(0, yEnseigne, zFacade),
			Color = couleur,
			Material = Mat.Metal,
		})
		-- la face « Back » (+Z local de la part) regarde le Tapis (« Affiche », CONTRAT §5) ; la face « Front » regarde
		-- l'intérieur (« AfficheDos »), recopiée automatiquement quand Systemes/Bases change le titre de « Affiche »
		local titreAvant = texteFace(enseigne, "Back", "Affiche", "Titre", "BASE LIBRE", 30)
		local titreDos = texteFace(enseigne, "Front", "AfficheDos", "Titre", "BASE LIBRE", 30)
		if titreAvant and titreDos then
			pcall(function()
				titreAvant:GetPropertyChangedSignal("Text"):Connect(function()
					titreDos.Text = titreAvant.Text
				end)
				titreAvant:GetPropertyChangedSignal("TextColor3"):Connect(function()
					titreDos.TextColor3 = titreAvant.TextColor3
				end)
			end)
		end

		-- ===== barrière laser de l'entrée (invisible tant que la base n'est pas verrouillée) =====
		part(Outils.bloc, modele, {
			Name = "Entree",
			Size = Vector3.new(LARGEUR_ENTREE, HAUT_PORTIQUE, 0.6),
			CFrame = ici(0, H + HAUT_PORTIQUE / 2, zFacade),
			Color = Charte.alerte,
			Material = Mat.Neon,
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})

		-- allée d'ardoise dans l'ombre de la couleur de la base, de l'entrée jusqu'au point d'apparition
		local zFinAllee = -demiP + 4
		part(Outils.bloc, decor, {
			Name = "Allee",
			Size = Vector3.new(4.5, 0.1, zFacade - zFinAllee),
			CFrame = ici(0, H + 0.05, (zFacade + zFinAllee) / 2),
			Color = couleurSombre,
			Material = Mat.Slate,
			CanCollide = false,
		}, true)

		-- ===== gros bouton de verrou rouge brillant sur socle de métal : à droite en entrant (+x local) =====
		local xBouton, zBouton = 10, zFacade - 4.5
		part(Outils.cylindre, decor, {
			Name = "SocleVerrou",
			Size = Vector3.new(1, 5.8, 5.8),
			CFrame = ici(xBouton, H + 0.5, zBouton, VERTICAL),
			Color = METAL_SOMBRE,
			Material = Mat.Metal,
		}, true)
		part(Outils.cylindre, decor, {
			Name = "BagueVerrou",
			Size = Vector3.new(0.5, 4.8, 4.8),
			CFrame = ici(xBouton, H + 1.2, zBouton, VERTICAL),
			Color = METAL,
			Material = Mat.Metal,
		}, true)
		local bouton = part(Outils.cylindre, modele, {
			Name = "BoutonVerrou",
			Size = Vector3.new(0.9, 4, 4),
			CFrame = ici(xBouton, H + 1.75, zBouton, VERTICAL),
			Color = ROUGE,
			Material = Mat.Neon,
		})
		pcall(function()
			Outils.invite(bouton, { nom = "Verrouiller", action = "Verrouiller", objet = "Base", distance = 10 })
		end)
		if Style and Style.etiquette then
			Style.etiquette(bouton, {
				{ texte = "🔒 VERROUILLER", titre = true, contour = 3.5, nom = "Titre" },
			}, {
				Name = "EtiquetteVerrou",
				largeur = 8,
				hauteurLigne = 1.6,
				StudsOffset = Vector3.new(0, 2.6, 0),
				MaxDistance = 60,
			})
		end

		-- ===== dalle de collecte en tôle verte, cadre d'ardoise : à gauche en entrant (-x local) =====
		local xCollecte, zCollecte = -10, zFacade - 4.5
		part(Outils.bloc, decor, {
			Name = "BordCollecte",
			Size = Vector3.new(8, 0.2, 8),
			CFrame = ici(xCollecte, H + 0.1, zCollecte),
			Color = ARDOISE,
			Material = Mat.Slate,
		}, true)
		local collecte = part(Outils.bloc, modele, {
			Name = "Collecte",
			Size = Vector3.new(7, 0.3, 7),
			CFrame = ici(xCollecte, H + 0.15, zCollecte),
			Color = VERT_TOLE,
			Material = Mat.DiamondPlate,
			CanTouch = true,
		})
		texteFace(collecte, "Top", "Marquage", "Signe", "$", 20)

		-- ===== 12 podiums : 2 rangées de 6 le long des murs gauche et droit, face à face de part et d'autre de l'allée =====
		-- E1 (gauche) et E2 (droite) au premier rang côté entrée, puis E3/E4… vers le fond (les 8 premiers sont débloqués d'office)
		-- socle carré aux arêtes arrondies dans l'ombre de la couleur, bandeau lumineux carré au ras du dessus,
		-- plateau de métal E<n> dans la couleur claire de la base
		local emplacements = Outils.dossier(modele, "Emplacements")
		local colonnes = 2
		local rangees = math.ceil(NB_EMPLACEMENTS / colonnes)
		local zPremier = 13.2 -- premier rang derrière le bouton de verrou et la dalle de collecte
		local PAS_RANGEE = 6.8
		local X_RANGEE = demiL - 9 -- podiums éloignés des murets, plus près de l'allée centrale
		local HAUT_SOCLE = 1.3
		for numero = 1, NB_EMPLACEMENTS do
			local col = (numero - 1) % colonnes
			local rang = math.floor((numero - 1) / colonnes)
			local x = (col == 0) and -X_RANGEE or X_RANGEE
			local z = zPremier - rang * PAS_RANGEE
			local propsSocle = {
				Name = "Socle",
				Size = Vector3.new(12.4, HAUT_SOCLE, 6.2), -- long dans le sens du dino (tourné vers l'allée)
				CFrame = ici(x, H + HAUT_SOCLE / 2, z),
				Color = couleurSombre,
				Material = Mat.Slate,
			}
			if not arrondi(propsSocle, 1.2) then
				part(Outils.bloc, decor, propsSocle, true)
			end
			-- bandeau lumineux : dépasse du socle de 0,1 sur les faces et nettement aux angles arrondis ; son dessus
			-- reste 0,05 sous celui du socle (pas de faces confondues)
			part(Outils.bloc, decor, {
				Name = "Anneau",
				Size = Vector3.new(12.6, 0.28, 6.4),
				CFrame = ici(x, H + HAUT_SOCLE - 0.05 - 0.14, z),
				Color = couleur,
				Material = Mat.Neon,
				Transparency = 0,
				CanCollide = false,
				CastShadow = false,
			}, true)
			local plaque = part(Outils.bloc, emplacements, {
				Name = "E" .. numero,
				Size = Vector3.new(12, 0.3, 5.8),
				CFrame = ici(x, H + HAUT_SOCLE + 0.15, z),
				Color = couleurClaire,
				Material = Mat.Metal,
			})
			plaque:SetAttribute("Debloque", numero <= 8)
		end
		local zDernier = zPremier - (rangees - 1) * PAS_RANGEE

		-- ===== apparition du propriétaire, au fond =====
		local zApparition = math.max(-demiP + 6, zDernier - 9)
		part(Outils.bloc, modele, {
			Name = "Apparition",
			Size = Vector3.new(6, 1, 6),
			CFrame = ici(0, H + 0.5, zApparition),
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})
		part(Outils.cylindre, decor, {
			Name = "CercleApparition",
			Size = Vector3.new(0.2, 6, 6),
			CFrame = ici(0, H + 0.12, zApparition, VERTICAL),
			Color = couleurClaire,
			Material = Mat.Neon,
			Transparency = 0.3,
			CanCollide = false,
		}, true)

		-- drapeaux de tissu de la couleur de la base aux coins du fond
		for _, cote in ipairs({ -1, 1 }) do
			local xMat = cote * (demiL - 4.5)
			local zMat = zFond + 2.2
			part(Outils.bloc, decor, {
				Name = "Mat",
				Size = Vector3.new(0.5, 10, 0.5),
				CFrame = ici(xMat, H + 5, zMat),
				Color = METAL,
				Material = Mat.Metal,
				CanCollide = false,
			}, true)
			local drapeau = part(Outils.bloc, decor, {
				Name = "Drapeau",
				Size = Vector3.new(4.5, 2.8, 0.2),
				CFrame = ici(xMat - cote * 2.5, H + 8.4, zMat),
				Color = couleur,
				Material = Mat.Fabric,
				CanCollide = false,
			}, true)
			if drapeau then
				Outils.animer(drapeau, "flotte", 0.6)
			end
		end

		-- ===== petits détails contre les murs : plantes en pot à l'avant, caisses au fond =====
		for _, cote in ipairs({ -1, 1 }) do
			local xPot = cote * (xCote - 2.2)
			local zPot = zFacade - 3.6
			part(Outils.cylindre, decor, {
				Name = "Pot",
				Size = Vector3.new(1.6, 2, 2),
				CFrame = ici(xPot, H + 0.8, zPot, VERTICAL),
				Color = Charte.terre,
				Material = Mat.Concrete,
			}, true)
			part(Outils.boule, decor, {
				Name = "Feuillage",
				Size = Vector3.new(3, 3, 3),
				CFrame = ici(xPot, H + 2.6, zPot),
				Color = Charte.jungle,
				Material = Mat.LeafyGrass,
				CanCollide = false,
			}, true)
		end
		local caisses = {
			{ -9, 2.6, 8 }, { 9.5, 2.2, -14 },
		}
		for _, c in ipairs(caisses) do
			local t = c[2]
			part(Outils.bloc, decor, {
				Name = "Caisse",
				Size = Vector3.new(t, t, t),
				CFrame = ici(c[1], H + t / 2, zFond + 0.5 + t / 2 + 0.3, CFrame.Angles(0, math.rad(c[3]), 0)),
				Color = Charte.bois,
				Material = Mat.WoodPlanks,
			}, true)
		end

		-- ===== volume de la base (détection, invisible) =====
		part(Outils.bloc, modele, {
			Name = "Zone",
			Size = Vector3.new(LARGEUR, HAUTEUR_ZONE, PROFONDEUR),
			CFrame = ici(0, HAUTEUR_ZONE / 2, 0),
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})

		-- attributs neutres en attendant Systemes/Bases
		modele:SetAttribute("Proprietaire", 0)
		modele:SetAttribute("NomProprietaire", "")
		modele:SetAttribute("Verrouillee", false)
		modele:SetAttribute("FinVerrou", 0)
	end

	for index, donnees in ipairs(Plan.bases) do
		if type(donnees) == "table" then
			local ok, err = pcall(construireBase, index, donnees)
			if not ok then
				warn("[Dino] Bases : base " .. index .. " : " .. tostring(err))
			end
		end
	end
end

return M
