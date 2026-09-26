-- Constructeur Bases : les 8 Bases des joueurs (CONTRAT §5), look « simulateur Roblox » (STYLE.md §3).
-- Chaque Base : plateforme gris clair surélevée de 44 x 50 avec rampe d'entrée, murets bas et piliers dans la couleur
-- saturée de la base, portique simple avec la barrière « Entree » et l'« Enseigne », gros bouton de verrou rouge,
-- dalle de collecte vert vif, 12 podiums gris clair à liseré de couleur, point d'apparition au fond.
-- Repère local d'une base : x en travers, z positif vers le Tapis (l'entrée). Les bases du sud sont tournées de 180°.
-- Emprise (CONTRAT §10) : le rectangle 44 x 50 de chaque base, rien entre elles. Budget : 90 parts par base.
local M = {}

local BUDGET = 90
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

	-- palette : plateforme et podiums gris clair, contours sombres façon « trait noir » cartoon
	local GRIS = hex("DCE1EA")
	local GRIS_CLAIR = hex("F2F4F8")
	local NOIR = hex("1B1A2E")
	local ROUGE = hex("E8233F")
	local VERT = hex("5CFF5C")
	if Style and Style.couleurs then
		NOIR = Style.couleurs.contour or NOIR
		VERT = Style.couleurs.argent or VERT
	end
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

		local modele = Outils.modele(dossier, "Base" .. index)
		modele:SetAttribute("Index", index)
		modele:SetAttribute("Couleur", couleur)
		local decor = Outils.modele(modele, "Decor")

		-- compteur de parts : le décor est sacrifié si le budget est atteint, jamais les pièces obligatoires
		local compte = 0
		local function part(fabrique, parent, props, facultatif)
			if facultatif and compte >= BUDGET then
				return nil
			end
			compte = compte + 1
			return fabrique(parent, props)
		end

		-- ===== plateforme gris clair surélevée et rampe =====
		local longueurSol = PROFONDEUR - 3
		local sol = part(Outils.bloc, modele, {
			Name = "Sol",
			Size = Vector3.new(LARGEUR, H, longueurSol),
			CFrame = ici(0, H / 2, -demiP + longueurSol / 2),
			Color = GRIS,
		})
		modele.PrimaryPart = sol
		local zAvant = -demiP + longueurSol -- bord avant du sol (début de la rampe)

		-- la rampe descend vers le Tapis : coin retourné d'un demi-tour, le haut contre la plateforme
		part(Outils.coin, modele, {
			Name = "Rampe",
			Size = Vector3.new(LARGEUR_ENTREE, H, demiP - zAvant),
			CFrame = ici(0, H / 2, (zAvant + demiP) / 2, CFrame.Angles(0, math.pi, 0)),
			Color = GRIS,
		})

		-- ===== murets bas (fond, côtés, façade de part et d'autre du portique) =====
		local HAUT_MURET = 3
		local function muret(x, z, sx, sz)
			part(Outils.bloc, decor, {
				Name = "Muret",
				Size = Vector3.new(sx, HAUT_MURET, sz),
				CFrame = ici(x, H + HAUT_MURET / 2, z),
				Color = couleur,
			}, true)
		end
		local zFacade = zAvant - 0.5
		local zMilieu = (-demiP + zAvant) / 2
		muret(0, -demiP + 0.5, LARGEUR, 1)
		muret(-demiL + 0.5, zMilieu, 1, longueurSol)
		muret(demiL - 0.5, zMilieu, 1, longueurSol)
		local debutFacade = LARGEUR_ENTREE / 2 + 2.5
		local longueurFacade = demiL - debutFacade
		muret(-(debutFacade + longueurFacade / 2), zFacade, longueurFacade, 1)
		muret(debutFacade + longueurFacade / 2, zFacade, longueurFacade, 1)

		-- ===== piliers (coins et milieu des côtés) : couleur de la base, chapeau clair =====
		local HAUT_PILIER = 5
		local positionsPiliers = {
			{ -demiL + 1, -demiP + 1 }, { demiL - 1, -demiP + 1 },
			{ -demiL + 1, zFacade }, { demiL - 1, zFacade },
			{ -demiL + 1, zMilieu }, { demiL - 1, zMilieu },
		}
		for _, p in ipairs(positionsPiliers) do
			part(Outils.bloc, decor, {
				Name = "Pilier",
				Size = Vector3.new(2.2, HAUT_PILIER, 2.2),
				CFrame = ici(p[1], H + HAUT_PILIER / 2, p[2]),
				Color = couleur,
			}, true)
			part(Outils.bloc, decor, {
				Name = "Chapiteau",
				Size = Vector3.new(2.8, 0.6, 2.8),
				CFrame = ici(p[1], H + HAUT_PILIER + 0.3, p[2]),
				Color = couleurClaire,
			}, true)
		end

		-- ===== portique d'entrée : deux poteaux et un linteau, nets =====
		local HAUT_PORTIQUE = 12
		local xPoteau = LARGEUR_ENTREE / 2 + 1.25
		for _, cote in ipairs({ -1, 1 }) do
			part(Outils.bloc, decor, {
				Name = "Poteau",
				Size = Vector3.new(2.5, H + HAUT_PORTIQUE, 2.5),
				CFrame = ici(cote * xPoteau, (H + HAUT_PORTIQUE) / 2, zFacade),
				Color = couleur,
			}, true)
		end
		local yLinteau = H + HAUT_PORTIQUE + 1
		part(Outils.bloc, decor, {
			Name = "Linteau",
			Size = Vector3.new(LARGEUR_ENTREE + 5, 2, 2.5),
			CFrame = ici(0, yLinteau, zFacade),
			Color = couleurClaire,
		}, true)

		-- enseigne face au Tapis : panneau de la couleur de la base, cadre noir, nom blanc cerné de noir
		local yEnseigne = yLinteau + 1 + 2.9
		part(Outils.bloc, decor, {
			Name = "CadreEnseigne",
			Size = Vector3.new(LARGEUR_ENTREE + 5.6, 6.4, 0.6),
			CFrame = ici(0, yEnseigne, zFacade - 0.3),
			Color = NOIR,
		}, true)
		local enseigne = part(Outils.bloc, modele, {
			Name = "Enseigne",
			Size = Vector3.new(LARGEUR_ENTREE + 4.4, 5.2, 0.4),
			CFrame = ici(0, yEnseigne, zFacade + 0.2),
			Color = couleur,
		})
		-- la face « Back » (+Z local de la part) regarde le Tapis
		texteFace(enseigne, "Back", "Affiche", "Titre", "BASE LIBRE", 30)

		-- ===== barrière laser de l'entrée (invisible tant que la base n'est pas verrouillée) =====
		part(Outils.bloc, modele, {
			Name = "Entree",
			Size = Vector3.new(LARGEUR_ENTREE, HAUT_PORTIQUE, 0.6),
			CFrame = ici(0, H + HAUT_PORTIQUE / 2, zFacade),
			Color = Charte.alerte,
			Material = Enum.Material.Neon,
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})

		-- allée de la couleur de la base, de l'entrée jusqu'au fond
		local zFinAllee = -demiP + 4
		part(Outils.bloc, decor, {
			Name = "Allee",
			Size = Vector3.new(4, 0.1, zFacade - zFinAllee),
			CFrame = ici(0, H + 0.05, (zFacade + zFinAllee) / 2),
			Color = couleurClaire,
			CanCollide = false,
		}, true)

		-- ===== gros bouton de verrou rond rouge : juste à l'intérieur, à droite en entrant (+x local) =====
		local xBouton, zBouton = 10, zFacade - 4.5
		part(Outils.cylindre, decor, {
			Name = "SocleVerrou",
			Size = Vector3.new(0.8, 5.6, 5.6),
			CFrame = ici(xBouton, H + 0.4, zBouton, VERTICAL),
			Color = GRIS_CLAIR,
		}, true)
		part(Outils.cylindre, decor, {
			Name = "BagueVerrou",
			Size = Vector3.new(0.4, 4.6, 4.6),
			CFrame = ici(xBouton, H + 1, zBouton, VERTICAL),
			Color = NOIR,
		}, true)
		local bouton = part(Outils.cylindre, modele, {
			Name = "BoutonVerrou",
			Size = Vector3.new(0.9, 4, 4),
			CFrame = ici(xBouton, H + 1.6, zBouton, VERTICAL),
			Color = ROUGE,
			Material = Enum.Material.Neon,
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

		-- ===== dalle de collecte vert vif (Neon léger) : à gauche en entrant (-x local) =====
		local xCollecte, zCollecte = -10, zFacade - 4.5
		part(Outils.bloc, decor, {
			Name = "BordCollecte",
			Size = Vector3.new(8, 0.2, 8),
			CFrame = ici(xCollecte, H + 0.1, zCollecte),
			Color = NOIR,
		}, true)
		local collecte = part(Outils.bloc, modele, {
			Name = "Collecte",
			Size = Vector3.new(7, 0.3, 7),
			CFrame = ici(xCollecte, H + 0.15, zCollecte),
			Color = VERT,
			Material = Enum.Material.Neon,
			Transparency = 0.15,
			CanTouch = true,
		})
		texteFace(collecte, "Top", "Marquage", "Signe", "$", 20)

		-- ===== 12 podiums : 3 rangées de 4, E1 au premier rang (côté entrée) =====
		-- socle cylindrique gris clair, liseré de la couleur de la base, plaque E<n> au-dessus
		local emplacements = Outils.dossier(modele, "Emplacements")
		local colonnes = 4
		local rangees = math.ceil(NB_EMPLACEMENTS / colonnes)
		local zPremier = 9
		local HAUT_SOCLE = 1.2
		for numero = 1, NB_EMPLACEMENTS do
			local col = (numero - 1) % colonnes
			local rang = math.floor((numero - 1) / colonnes)
			local x = (col - (colonnes - 1) / 2) * ECART_PODIUMS
			local z = zPremier - rang * ECART_PODIUMS
			part(Outils.cylindre, decor, {
				Name = "Socle",
				Size = Vector3.new(HAUT_SOCLE, 6, 6),
				CFrame = ici(x, H + HAUT_SOCLE / 2, z, VERTICAL),
				Color = GRIS_CLAIR,
			})
			part(Outils.cylindre, decor, {
				Name = "Lisere",
				Size = Vector3.new(0.35, 6.5, 6.5),
				CFrame = ici(x, H + HAUT_SOCLE - 0.2, z, VERTICAL),
				Color = couleur,
			})
			local plaque = part(Outils.bloc, emplacements, {
				Name = "E" .. numero,
				Size = Vector3.new(4.2, 0.3, 4.2),
				CFrame = ici(x, H + HAUT_SOCLE + 0.15, z),
				Color = GRIS_CLAIR,
			})
			plaque:SetAttribute("Debloque", numero <= 8)
		end
		local zDernier = zPremier - (rangees - 1) * ECART_PODIUMS

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
			Material = Enum.Material.Neon,
			Transparency = 0.3,
			CanCollide = false,
		}, true)

		-- drapeaux de la couleur de la base aux coins du fond
		for _, cote in ipairs({ -1, 1 }) do
			local xMat = cote * (demiL - 3.5)
			local zMat = -demiP + 3.5
			part(Outils.bloc, decor, {
				Name = "Mat",
				Size = Vector3.new(0.6, 10, 0.6),
				CFrame = ici(xMat, H + 5, zMat),
				Color = GRIS_CLAIR,
				CanCollide = false,
			}, true)
			local drapeau = part(Outils.bloc, decor, {
				Name = "Drapeau",
				Size = Vector3.new(4.5, 2.8, 0.2),
				CFrame = ici(xMat - cote * 2.55, H + 8.4, zMat),
				Color = couleur,
				CanCollide = false,
			}, true)
			if drapeau then
				Outils.animer(drapeau, "flotte", 0.6)
			end
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
