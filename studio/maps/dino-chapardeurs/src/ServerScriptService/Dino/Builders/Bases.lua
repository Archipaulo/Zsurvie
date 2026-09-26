-- Constructeur Bases : les 8 Bases des joueurs (CONTRAT §5).
-- Chaque Base : sol surélevé de 44 x 50 avec rampe d'entrée, murets bas et piliers, portique avec la barrière
-- « Entree » et l'« Enseigne », bouton de verrou, dalle de collecte, 12 podiums, point d'apparition au fond.
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

	-- couleur dominante de chaque base (une par index, dans l'ordre)
	local teintes = { Charte.lave, Charte.gemme, Charte.violet, Charte.herbe, Charte.dore, Charte.alerte, Charte.sable, Charte.jungle }

	local VERTICAL = CFrame.Angles(0, 0, math.rad(90)) -- axe X du cylindre dressé à la verticale

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

		local couleur = teintes[((index - 1) % #teintes) + 1] or Charte.pierre
		local couleurSombre = Charte.ombre(couleur)
		local couleurClaire = Charte.lumiere(couleur)
		local couleurSol = couleur:Lerp(Charte.creme, 0.72)

		local modele = Outils.modele(dossier, "Base" .. index)
		modele:SetAttribute("Index", index)
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

		-- ===== sol, rampe et parvis =====
		local longueurSol = PROFONDEUR - 3
		local sol = part(Outils.bloc, modele, {
			Name = "Sol",
			Size = Vector3.new(LARGEUR, H, longueurSol),
			CFrame = ici(0, H / 2, -demiP + longueurSol / 2),
			Color = couleurSol,
		})
		modele.PrimaryPart = sol
		local zAvant = -demiP + longueurSol -- bord avant du sol (début de la rampe)

		-- la rampe descend vers le Tapis : le côté haut d'un coin est vers +Z local (face Back),
		-- on le retourne d'un demi-tour pour que le haut touche le sol de la base et la pente regarde le Tapis
		part(Outils.coin, modele, {
			Name = "Rampe",
			Size = Vector3.new(LARGEUR_ENTREE, H, demiP - zAvant),
			CFrame = ici(0, H / 2, (zAvant + demiP) / 2, CFrame.Angles(0, math.pi, 0)),
			Color = couleurSol,
		})
		local largeurJardin = demiL - LARGEUR_ENTREE / 2
		for _, cote in ipairs({ -1, 1 }) do
			local xJardin = cote * (LARGEUR_ENTREE / 2 + largeurJardin / 2)
			part(Outils.bloc, decor, {
				Name = "Jardiniere",
				Size = Vector3.new(largeurJardin, H + 0.2, demiP - zAvant),
				CFrame = ici(xJardin, (H + 0.2) / 2, (zAvant + demiP) / 2),
				Color = Charte.herbe,
			}, true)
			part(Outils.boule, decor, {
				Name = "Buisson",
				Size = Vector3.new(3, 3, 3),
				CFrame = ici(cote * 14, H + 1, (zAvant + demiP) / 2),
				Color = Charte.jungle,
				CanCollide = false,
			}, true)
		end
		-- tapis d'accueil entre l'entrée et la première rangée
		part(Outils.bloc, decor, {
			Name = "TapisAccueil",
			Size = Vector3.new(6, 0.1, 8),
			CFrame = ici(0, H + 0.05, 16.5),
			Color = couleur,
			CanCollide = false,
		}, true)

		-- ===== murets bas (fond, côtés et façade de part et d'autre du portique) =====
		local HAUT_MURET = 2.5
		local function muret(x, z, sx, sz)
			part(Outils.bloc, decor, {
				Name = "Muret",
				Size = Vector3.new(sx, HAUT_MURET, sz),
				CFrame = ici(x, H + HAUT_MURET / 2, z),
				Color = couleur,
			}, true)
			part(Outils.bloc, decor, {
				Name = "Chaperon",
				Size = Vector3.new(sx + 0.4, 0.4, sz + 0.4),
				CFrame = ici(x, H + HAUT_MURET + 0.2, z),
				Color = couleurClaire,
			}, true)
		end
		local zFacade = zAvant - 0.5
		muret(0, -demiP + 0.5, LARGEUR, 1)
		muret(-demiL + 0.5, (-demiP + zAvant) / 2, 1, longueurSol)
		muret(demiL - 0.5, (-demiP + zAvant) / 2, 1, longueurSol)
		local debutFacade = LARGEUR_ENTREE / 2 + 3
		local longueurFacade = demiL - debutFacade
		muret(-(debutFacade + longueurFacade / 2), zFacade, longueurFacade, 1)
		muret(debutFacade + longueurFacade / 2, zFacade, longueurFacade, 1)

		-- ===== piliers (coins et milieu des côtés) =====
		local positionsPiliers = {
			{ -demiL + 1, -demiP + 1 }, { demiL - 1, -demiP + 1 },
			{ -demiL + 1, zFacade }, { demiL - 1, zFacade },
			{ -demiL + 1, (-demiP + zAvant) / 2 }, { demiL - 1, (-demiP + zAvant) / 2 },
		}
		for _, p in ipairs(positionsPiliers) do
			part(Outils.bloc, decor, {
				Name = "Pilier",
				Size = Vector3.new(2, 4, 2),
				CFrame = ici(p[1], H + 2, p[2]),
				Color = couleurSombre,
			}, true)
			part(Outils.bloc, decor, {
				Name = "Chapiteau",
				Size = Vector3.new(2.6, 0.6, 2.6),
				CFrame = ici(p[1], H + 4.3, p[2]),
				Color = couleurClaire,
			}, true)
		end

		-- ===== portique d'entrée =====
		local HAUT_PORTIQUE = 12
		local xPoteau = LARGEUR_ENTREE / 2 + 1.5
		for _, cote in ipairs({ -1, 1 }) do
			part(Outils.bloc, decor, {
				Name = "Poteau",
				Size = Vector3.new(3, H + HAUT_PORTIQUE, 3),
				CFrame = ici(cote * xPoteau, (H + HAUT_PORTIQUE) / 2, zFacade),
				Color = couleurSombre,
			}, true)
			local lanterne = part(Outils.boule, decor, {
				Name = "Lanterne",
				Size = Vector3.new(1.6, 1.6, 1.6),
				CFrame = ici(cote * xPoteau, H + HAUT_PORTIQUE - 2, zFacade + 2),
				Color = Charte.dore,
				Material = Enum.Material.Neon,
				CanCollide = false,
			}, true)
			if lanterne then
				Outils.lumiere(lanterne, { Range = 14, Brightness = 1.2, Color = Charte.dore })
			end
		end
		local yLinteau = H + HAUT_PORTIQUE + 1
		part(Outils.bloc, decor, {
			Name = "Linteau",
			Size = Vector3.new(LARGEUR_ENTREE + 6, 2, 3.4),
			CFrame = ici(0, yLinteau, zFacade),
			Color = couleur,
		}, true)
		part(Outils.bloc, decor, {
			Name = "Lisere",
			Size = Vector3.new(LARGEUR_ENTREE + 6, 0.4, 0.2),
			CFrame = ici(0, yLinteau - 0.6, zFacade + 1.8),
			Color = couleurClaire,
			Material = Enum.Material.Neon,
			CanCollide = false,
		}, true)

		-- enseigne face au Tapis : cadre coloré et panneau crème avec le nom du propriétaire
		local yEnseigne = yLinteau + 1 + 2.6
		part(Outils.bloc, decor, {
			Name = "CadreEnseigne",
			Size = Vector3.new(LARGEUR_ENTREE + 5.2, 5.8, 0.6),
			CFrame = ici(0, yEnseigne, zFacade - 0.3),
			Color = couleurSombre,
		}, true)
		local enseigne = part(Outils.bloc, modele, {
			Name = "Enseigne",
			Size = Vector3.new(LARGEUR_ENTREE + 4, 4.8, 0.4),
			CFrame = ici(0, yEnseigne, zFacade + 0.2),
			Color = Charte.creme,
		})
		-- la face « Back » (+Z local de la part) regarde le Tapis
		local titre = Outils.texte(enseigne, "Back", "Base libre", { couleur = Charte.encre, pixelsParStud = 30 })
		titre.Name = "Titre"
		if titre.Parent then
			titre.Parent.Name = "Affiche"
		end

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
		part(Outils.bloc, decor, {
			Name = "Seuil",
			Size = Vector3.new(LARGEUR_ENTREE, 0.2, 2),
			CFrame = ici(0, H + 0.1, zFacade),
			Color = Charte.dore,
			CanCollide = false,
		}, true)

		-- ===== bouton de verrou : juste à l'intérieur, à droite en entrant (+x local) =====
		local xBouton, zBouton = 10, zFacade - 4.5
		local socleBouton = part(Outils.bloc, decor, {
			Name = "SocleVerrou",
			Size = Vector3.new(3, 2.6, 3),
			CFrame = ici(xBouton, H + 1.3, zBouton),
			Color = Charte.pierre,
		}, true)
		if socleBouton then
			Outils.texte(socleBouton, "Back", "VERROU", { couleur = Charte.creme, pixelsParStud = 30 })
			Outils.texte(socleBouton, "Left", "VERROU", { couleur = Charte.creme, pixelsParStud = 30 })
		end
		local bouton = part(Outils.cylindre, modele, {
			Name = "BoutonVerrou",
			Size = Vector3.new(1, 2.6, 2.6),
			CFrame = ici(xBouton, H + 2.6 + 0.5, zBouton, VERTICAL),
			Color = Charte.alerte,
			Material = Enum.Material.Neon,
		})
		pcall(function()
			Outils.invite(bouton, { nom = "Verrouiller", action = "Verrouiller", objet = "Base", distance = 10 })
		end)
		Outils.lumiere(bouton, { Range = 8, Brightness = 0.8, Color = Charte.alerte })

		-- ===== dalle de collecte : à gauche en entrant (-x local) =====
		local xCollecte, zCollecte = -10, zFacade - 4.5
		part(Outils.bloc, decor, {
			Name = "BordCollecte",
			Size = Vector3.new(8, 0.2, 8),
			CFrame = ici(xCollecte, H + 0.1, zCollecte),
			Color = Charte.ombre(Charte.dore),
		}, true)
		local collecte = part(Outils.bloc, modele, {
			Name = "Collecte",
			Size = Vector3.new(7, 0.3, 7),
			CFrame = ici(xCollecte, H + 0.15, zCollecte),
			Color = Charte.dore,
			CanTouch = true,
		})
		Outils.texte(collecte, "Top", "COLLECTE", { couleur = Charte.encre, pixelsParStud = 20 })
		Outils.lumiere(collecte, { Range = 10, Brightness = 0.6, Color = Charte.dore })

		-- ===== 12 podiums : 3 rangées de 4, E1 au premier rang (côté entrée) =====
		local emplacements = Outils.dossier(modele, "Emplacements")
		local colonnes = 4
		local rangees = math.ceil(NB_EMPLACEMENTS / colonnes)
		local zPremier = 9
		for numero = 1, NB_EMPLACEMENTS do
			local col = (numero - 1) % colonnes
			local rang = math.floor((numero - 1) / colonnes)
			local x = (col - (colonnes - 1) / 2) * ECART_PODIUMS
			local z = zPremier - rang * ECART_PODIUMS
			local socle = part(Outils.bloc, decor, {
				Name = "Socle",
				Size = Vector3.new(5.4, 1.2, 5.4),
				CFrame = ici(x, H + 0.6, z),
				Color = Charte.pierre,
			})
			Outils.texte(socle, "Back", tostring(numero), { couleur = Charte.creme, pixelsParStud = 20 })
			local plaque = part(Outils.bloc, emplacements, {
				Name = "E" .. numero,
				Size = Vector3.new(4.6, 0.4, 4.6),
				CFrame = ici(x, H + 1.4, z),
				Color = couleurClaire,
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
			CFrame = ici(0, H + 0.1, zApparition, VERTICAL),
			Color = couleurClaire,
			Material = Enum.Material.Neon,
			Transparency = 0.3,
			CanCollide = false,
		}, true)

		-- drapeaux aux coins du fond
		for _, cote in ipairs({ -1, 1 }) do
			local xMat = cote * (demiL - 3.5)
			local zMat = -demiP + 3.5
			part(Outils.bloc, decor, {
				Name = "Mat",
				Size = Vector3.new(0.5, 9, 0.5),
				CFrame = ici(xMat, H + 4.5, zMat),
				Color = Charte.bois,
				CanCollide = false,
			}, true)
			local drapeau = part(Outils.bloc, decor, {
				Name = "Drapeau",
				Size = Vector3.new(4, 2.5, 0.2),
				CFrame = ici(xMat - cote * 2.25, H + 7.6, zMat),
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
