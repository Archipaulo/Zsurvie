-- Constructeur Tapis : le grand tapis roulant rouge qui traverse le monde de la Nurserie à la Grande Porte.
-- Version 3 (plan v2, STYLE.md §3-4) : bande en Fabric rouge (Charte.tapis) légèrement bombée, tambours
-- d'extrémité, longerons en Metal gris foncé (chapeau clair, semelle), têtes de rouleaux sur les flancs,
-- pieds de soutien sur une plinthe sombre. Effets : chevrons blancs en Neon qui pulsent en vague décalée
-- vers la Fin du tapis (genre « pulse » + attribut AnimePhase), veilleuses Neon dorées sur les rebords
-- qui suivent la même vague, et deux arches légères au-dessus des bouts (piliers rouges, traverse,
-- ampoules, œuf côté Nurserie, chevron côté Grande Porte), assez hautes pour laisser passer tous les dinos.
-- Emprise (CONTRAT §10) : de Plan.tapis.debut à Plan.tapis.fin, |z| <= Plan.tapis.emprise autour de l'axe.
-- Aucune coordonnée en dur : tout vient de Plan.tapis. Budget : 340 parts.
local M = {}

local BUDGET = 340           -- parts au maximum pour ce constructeur
local LONGUEUR_SEGMENT = 28  -- longueur d'un segment de bande
local PAS_ROULEAU = 16       -- une tête de rouleau (et un pied) environ tous les 16 studs
local PAS_FLECHE = 16        -- un chevron tous les 16 studs
local PAS_VEILLEUSE = 8      -- une veilleuse tous les 8 studs sur chaque rebord
local VITESSE_VAGUE = 2.5    -- vitesse angulaire de la pulsation (rad/s)
local DEPHASAGE_PAS = 1.2    -- retard de phase par chevron : la vague file vers la Fin (~33 studs/s)
local MARGE_EMPRISE = 2.5    -- emprise de secours au-delà de la demi-largeur

-- profil en travers (distances à l'axe, hauteurs depuis le sol)
local LARGEUR_BOMBE = 11     -- dessus central de la bande (au niveau Plan.tapis.hauteur)
local ABAISSE_BORD = 0.06    -- les bords de la bande sont un peu plus bas : effet bombé
local DIAMETRE_ARRONDI = 0.36
local EPAISSEUR_BANDE = 0.3
local HAUT_PLINTHE = 0.2
local BAS_LONGERON = 0.55
local HAUT_LONGERON = 1.3
local EPAISSEUR_LONGERON = 0.5

-- arches des bouts
local PASSAGE_LIBRE = 17     -- hauteur libre sous la traverse (les plus grands dinos font ~13 de haut)
local COTE_PILIER = 0.9
local HAUT_TRAVERSE = 1.1

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- ===== géométrie : uniquement Plan.tapis =====
	local reglage = Plan.tapis
	if type(reglage) ~= "table" then
		return
	end
	local debut = reglage.debut
	local fin = reglage.fin
	if typeof(debut) ~= "Vector3" or typeof(fin) ~= "Vector3" then
		return
	end
	local largeur = 10
	if type(reglage.largeur) == "number" and reglage.largeur > 0 then
		largeur = reglage.largeur
	end
	local hauteur = 0.8
	if type(reglage.hauteur) == "number" and reglage.hauteur > 0 then
		hauteur = reglage.hauteur
	end
	local emprise = largeur / 2 + MARGE_EMPRISE
	if type(reglage.emprise) == "number" and reglage.emprise > 1 then
		emprise = reglage.emprise
	end
	-- la bande, les longerons et la plinthe doivent tenir dans l'emprise latérale
	largeur = math.min(largeur, (emprise - 1.6) * 2)

	-- repère local : u le long du tapis (de debut vers fin), y vertical, w latéral
	local a = Vector3.new(debut.X, 0, debut.Z)
	local b = Vector3.new(fin.X, 0, fin.Z)
	local longueur = (b - a).Magnitude
	if longueur < 2 then
		return
	end
	local axe = (b - a).Unit
	local haut = Vector3.new(0, 1, 0)
	local cote = axe:Cross(haut)
	local repere = CFrame.fromMatrix(a, axe, haut, cote)
	local function cadre(u, y, w)
		return repere * CFrame.new(u, y, w)
	end
	-- un cylindre (axe X de la part) couché en travers du tapis
	local TRAVERS = CFrame.Angles(0, math.rad(90), 0)

	-- profil en travers
	local demi = largeur / 2
	local wBord = demi - 0.3                          -- bord extérieur de la bande (arrondi)
	local largeurBombe = math.min(LARGEUR_BOMBE, largeur - 3)
	local wBombe = largeurBombe / 2
	local hautBord = hauteur - ABAISSE_BORD
	local basBande = math.max(HAUT_PLINTHE + 0.1, hauteur - EPAISSEUR_BANDE)
	local wInterieur = wBord + 0.15                   -- face intérieure des longerons
	local wExterieur = wInterieur + EPAISSEUR_LONGERON -- face extérieure des longerons
	local wLongeron = (wInterieur + wExterieur) / 2
	local hautLongeron = math.max(HAUT_LONGERON, hauteur + 0.4)
	local basLongeron = math.min(BAS_LONGERON, hauteur - 0.25)
	local rayonTambour = (hauteur - HAUT_PLINTHE - 0.05) / 2
	local uTambour = math.min(rayonTambour, longueur / 4)

	-- ===== couleurs (charte uniquement, en trois teintes) =====
	local rouge = Charte.tapis
	local rougeOmbre = Charte.ombre(rouge)
	local rougeBord = rouge:Lerp(rougeOmbre, 0.5)
	local rougeClair = Charte.lumiere(rouge)
	local metalFonce = Charte.pierre:Lerp(Charte.encre, 0.55)
	local metalOmbre = Charte.ombre(metalFonce)
	local metalClair = Charte.pierre:Lerp(Charte.creme, 0.1)
	local metalRouleau = Charte.lumiere(Charte.pierre)
	local metalBrillant = Charte.pierre:Lerp(Charte.creme, 0.45)
	local plinthe = Charte.encre:Lerp(Charte.pierre, 0.25)
	local plintheBas = Charte.encre
	local blancNeon = Charte.creme                    -- chevrons : « flèches blanches Neon » (STYLE §3)
	local ambre = Charte.dore                         -- veilleuses et ampoules
	local ambreDoux = Charte.dore:Lerp(Charte.creme, 0.35)

	-- ===== création protégée et comptée =====
	local nombre = 0
	local function creer(fabrique, parent, props)
		if nombre >= BUDGET then
			return nil
		end
		local ok, part = pcall(fabrique, parent, props)
		if ok and part then
			nombre = nombre + 1
			return part
		end
		return nil
	end
	-- décor pur : ni collision, ni requête, ni contact (les petites pièces ne font pas d'ombre)
	local function decor(props, sansOmbre)
		props.CanCollide = false
		props.CanQuery = false
		props.CanTouch = false
		if sansOmbre then
			props.CastShadow = false
		end
		return props
	end
	-- pulsation client (Interface/AnimationsDecor) ; AnimePhase cale la vague le long du tapis
	local function pulser(inst, u)
		if not inst then
			return
		end
		pcall(Outils.animer, inst, "pulse", VITESSE_VAGUE)
		pcall(function()
			inst:SetAttribute("AnimePhase", -(u / PAS_FLECHE) * DEPHASAGE_PAS)
		end)
	end

	local modele = Outils.modele(dossier, "TapisRoulant")
	local bande = Outils.dossier(modele, "Bande")
	local fleches = Outils.dossier(modele, "Fleches")
	local rebords = Outils.dossier(modele, "Rebords")
	local veilleuses = Outils.dossier(modele, "Veilleuses")
	local rouleaux = Outils.dossier(modele, "Rouleaux")
	local socle = Outils.dossier(modele, "Socle")
	local arches = Outils.dossier(modele, "Arches")

	-- la bande court entre les deux tambours d'extrémité
	local uDebutBande = uTambour
	local uFinBande = longueur - uTambour
	local longueurBande = uFinBande - uDebutBande
	local nbSegments = math.max(1, math.ceil(longueurBande / LONGUEUR_SEGMENT - 0.001))
	local longueurSegment = longueurBande / nbSegments
	local uMilieuBande = (uDebutBande + uFinBande) / 2

	-- ===== 1. la bande en Fabric rouge, dessus central en segments égaux =====
	for i = 1, nbSegments do
		local u0 = uDebutBande + (i - 1) * longueurSegment
		local segment = creer(Outils.bloc, bande, {
			Name = "Segment" .. i,
			Size = Vector3.new(longueurSegment, hauteur - basBande, largeurBombe),
			CFrame = cadre(u0 + longueurSegment / 2, (hauteur + basBande) / 2, 0),
			Color = rouge,
			Material = Enum.Material.Fabric,
			CanCollide = true,
			CanQuery = true,
			CanTouch = false,
		})
		if segment then
			segment:SetAttribute("Segment", i)
		end
	end

	-- bords de la bande un peu plus bas, puis arrondis : la bande paraît bombée
	for _, signe in ipairs({ 1, -1 }) do
		local largeurBord = wBord - wBombe
		creer(Outils.bloc, bande, {
			Name = "BordBande",
			Size = Vector3.new(longueurBande, hautBord - basBande, largeurBord),
			CFrame = cadre(uMilieuBande, (hautBord + basBande) / 2, signe * (wBombe + largeurBord / 2)),
			Color = rougeBord,
			Material = Enum.Material.Fabric,
			CanCollide = true,
			CanQuery = true,
			CanTouch = false,
		})
		creer(Outils.cylindre, bande, decor({
			Name = "Arrondi",
			Size = Vector3.new(longueurBande, DIAMETRE_ARRONDI, DIAMETRE_ARRONDI),
			CFrame = cadre(uMilieuBande, hautBord - DIAMETRE_ARRONDI / 2, signe * wBord),
			Color = rougeOmbre,
			Material = Enum.Material.Fabric,
		}))
	end

	-- tambours d'extrémité : la bande s'enroule autour (bouts arrondis)
	for _, u in ipairs({ uTambour, longueur - uTambour }) do
		creer(Outils.cylindre, bande, decor({
			Name = "Tambour",
			Size = Vector3.new(wBord * 2, rayonTambour * 2, rayonTambour * 2),
			CFrame = cadre(u, hauteur - rayonTambour, 0) * TRAVERS,
			Color = rougeOmbre,
			Material = Enum.Material.Fabric,
		}))
	end

	-- ===== 2. longerons en Metal gris foncé : âme, chapeau clair, semelle =====
	for _, signe in ipairs({ 1, -1 }) do
		creer(Outils.bloc, rebords, decor({
			Name = "Longeron",
			Size = Vector3.new(longueur, hautLongeron - basLongeron, EPAISSEUR_LONGERON),
			CFrame = cadre(longueur / 2, (hautLongeron + basLongeron) / 2, signe * wLongeron),
			Color = metalFonce,
			Material = Enum.Material.Metal,
		}))
		creer(Outils.bloc, rebords, decor({
			Name = "Chapeau",
			Size = Vector3.new(longueur, 0.12, EPAISSEUR_LONGERON + 0.3),
			CFrame = cadre(longueur / 2, hautLongeron + 0.06, signe * (wLongeron - 0.05)),
			Color = metalClair,
			Material = Enum.Material.Metal,
		}))
		creer(Outils.bloc, rebords, decor({
			Name = "Semelle",
			Size = Vector3.new(longueur, 0.1, EPAISSEUR_LONGERON + 0.2),
			CFrame = cadre(longueur / 2, basLongeron + 0.05, signe * (wLongeron + 0.1)),
			Color = metalOmbre,
			Material = Enum.Material.Metal,
		}))
	end

	-- ===== 3. socle : plinthe sombre bordée et châssis dans l'ombre sous la bande =====
	local largeurPlinthe = math.min(emprise * 2 - 0.4, (wExterieur + 1) * 2)
	creer(Outils.bloc, socle, {
		Name = "PlintheBas",
		Size = Vector3.new(longueur, HAUT_PLINTHE * 0.6, largeurPlinthe),
		CFrame = cadre(longueur / 2, HAUT_PLINTHE * 0.3, 0),
		Color = plintheBas,
		Material = Enum.Material.Slate,
		CanCollide = true,
		CanQuery = false,
		CanTouch = false,
	})
	creer(Outils.bloc, socle, {
		Name = "Plinthe",
		Size = Vector3.new(longueur - 0.4, HAUT_PLINTHE * 0.5, largeurPlinthe - 0.5),
		CFrame = cadre(longueur / 2, HAUT_PLINTHE * 0.75, 0),
		Color = plinthe,
		Material = Enum.Material.Slate,
		CanCollide = true,
		CanQuery = false,
		CanTouch = false,
	})
	creer(Outils.bloc, socle, decor({
		Name = "Chassis",
		Size = Vector3.new(longueur - 0.2, basBande - HAUT_PLINTHE, wInterieur * 2),
		CFrame = cadre(longueur / 2, (basBande + HAUT_PLINTHE) / 2, 0),
		Color = plintheBas,
		Material = Enum.Material.Metal,
	}))

	-- ===== 4. chevrons Neon blancs tous les 16 studs, pointant vers la Fin du tapis =====
	-- Chaque modèle Fleche pulse (genre « pulse ») avec une phase qui recule le long du tapis :
	-- les chevrons s'allument l'un après l'autre et la lumière semble courir vers la Grande Porte.
	local nbFleches = math.max(1, math.floor(longueurBande / PAS_FLECHE))
	local margeFleches = (longueurBande - nbFleches * PAS_FLECHE) / 2
	local demiEnvergure = math.min(2.8, wBombe - 0.8)
	local recul = demiEnvergure * 0.85
	local epaisseurBras = 0.7
	local longueurBras = math.sqrt(recul * recul + demiEnvergure * demiEnvergure) + epaisseurBras * 0.6
	local angleBras = math.atan2(demiEnvergure, recul)
	for k = 0, nbFleches - 1 do
		local u = uDebutBande + margeFleches + PAS_FLECHE / 2 + k * PAS_FLECHE
		local fleche = Outils.modele(fleches, "Fleche" .. (k + 1))
		for _, signe in ipairs({ 1, -1 }) do
			-- chaque bras relie la pointe (sur l'axe, en avant) à un coin arrière
			creer(Outils.bloc, fleche, decor({
				Name = "Bras",
				Size = Vector3.new(longueurBras, 0.06, epaisseurBras),
				CFrame = cadre(u, hauteur + 0.03, signe * demiEnvergure / 2) * CFrame.Angles(0, signe * angleBras, 0),
				Color = blancNeon,
				Material = Enum.Material.Neon,
				Transparency = 0.15,
			}, true))
		end
		pulser(fleche, u)
	end

	-- ===== 5. têtes de rouleaux sur les flancs (environ tous les 16 studs, tambours compris) =====
	local yRouleau = (basLongeron + hautLongeron) / 2
	local nbRouleaux = math.max(1, math.floor(longueurBande / PAS_ROULEAU + 0.5))
	local pasRouleau = longueurBande / nbRouleaux
	for k = 0, nbRouleaux do
		local u = uDebutBande + k * pasRouleau
		for _, signe in ipairs({ 1, -1 }) do
			creer(Outils.cylindre, rouleaux, decor({
				Name = "Rouleau",
				Size = Vector3.new(0.32, 0.66, 0.66),
				CFrame = cadre(u, yRouleau, signe * (wExterieur + 0.16)) * TRAVERS,
				Color = metalRouleau,
				Material = Enum.Material.Metal,
			}, true))
			creer(Outils.cylindre, rouleaux, decor({
				Name = "Axe",
				Size = Vector3.new(0.14, 0.28, 0.28),
				CFrame = cadre(u, yRouleau, signe * (wExterieur + 0.39)) * TRAVERS,
				Color = metalBrillant,
				Material = Enum.Material.Metal,
			}, true))
		end
	end

	-- ===== 6. pieds de soutien sous les longerons, posés sur la plinthe (entre les rouleaux) =====
	local hautPied = basLongeron - HAUT_PLINTHE
	if hautPied > 0.05 then
		for k = 0, nbRouleaux - 1 do
			local u = uDebutBande + (k + 0.5) * pasRouleau
			for _, signe in ipairs({ 1, -1 }) do
				creer(Outils.bloc, socle, decor({
					Name = "Pied",
					Size = Vector3.new(0.7, hautPied, EPAISSEUR_LONGERON + 0.1),
					CFrame = cadre(u, HAUT_PLINTHE + hautPied / 2, signe * wLongeron),
					Color = metalOmbre,
					Material = Enum.Material.Metal,
				}, true))
			end
		end
	end

	-- ===== 7. veilleuses Neon dorées sur le chapeau des rebords, dans la même vague que les chevrons =====
	local nbVeilleuses = math.max(1, math.floor(longueurBande / PAS_VEILLEUSE))
	local margeVeilleuses = (longueurBande - (nbVeilleuses - 1) * PAS_VEILLEUSE) / 2
	local yChapeau = hautLongeron + 0.12
	for k = 0, nbVeilleuses - 1 do
		local u = uDebutBande + margeVeilleuses + k * PAS_VEILLEUSE
		for _, signe in ipairs({ 1, -1 }) do
			local veilleuse = creer(Outils.boule, veilleuses, decor({
				Name = "Veilleuse",
				Size = Vector3.new(0.5, 0.32, 0.5),
				CFrame = cadre(u, yChapeau, signe * (wLongeron - 0.05)),
				Color = ambre,
				Material = Enum.Material.Neon,
			}, true))
			pulser(veilleuse, u)
		end
	end

	-- ===== 8. deux arches légères au-dessus des bouts =====
	-- piliers juste à l'intérieur de l'emprise, hors de la bande : les dinos passent librement dessous
	local wArche = emprise - COTE_PILIER / 2 - 0.1
	local yTraverse = math.max(PASSAGE_LIBRE, hauteur + PASSAGE_LIBRE - 1) -- dessous de la traverse
	local yHautPilier = yTraverse + HAUT_TRAVERSE
	local uArche = math.min(1.2, longueur / 4)

	local function arche(nom, u, sensCimier)
		local m = Outils.modele(arches, nom)
		for _, signe in ipairs({ 1, -1 }) do
			local w = signe * wArche
			-- patin au sol, pilier rouge cerclé de métal, ampoule dorée au sommet
			creer(Outils.bloc, m, {
				Name = "Patin",
				Size = Vector3.new(COTE_PILIER + 0.6, 0.4, COTE_PILIER + 0.2),
				CFrame = cadre(u, 0.2, w),
				Color = metalOmbre,
				Material = Enum.Material.DiamondPlate,
				CanCollide = true,
				CanQuery = false,
				CanTouch = false,
			})
			creer(Outils.bloc, m, {
				Name = "Pilier",
				Size = Vector3.new(COTE_PILIER, yHautPilier - 0.4, COTE_PILIER),
				CFrame = cadre(u, 0.4 + (yHautPilier - 0.4) / 2, w),
				Color = rouge,
				Material = Enum.Material.SmoothPlastic,
				CanCollide = true,
				CanQuery = false,
				CanTouch = false,
			})
			for _, y in ipairs({ 1.6, yTraverse * 0.55 }) do
				creer(Outils.bloc, m, decor({
					Name = "Cerclage",
					Size = Vector3.new(COTE_PILIER + 0.16, 0.3, COTE_PILIER + 0.16),
					CFrame = cadre(u, y, w),
					Color = metalClair,
					Material = Enum.Material.Metal,
				}, true))
			end
			local ampoule = creer(Outils.boule, m, decor({
				Name = "Ampoule",
				Size = Vector3.new(0.9, 0.9, 0.9),
				CFrame = cadre(u, yHautPilier + 0.45, w),
				Color = ambre,
				Material = Enum.Material.Neon,
			}, true))
			if ampoule then
				pcall(Outils.lumiere, ampoule, { Range = 12, Brightness = 1.2, Color = ambreDoux })
			end
			-- jambe de force en diagonale entre le pilier et la traverse
			creer(Outils.bloc, m, decor({
				Name = "JambeDeForce",
				Size = Vector3.new(0.5, 0.35, 2.9),
				CFrame = cadre(u, yTraverse - 1, signe * (wArche - COTE_PILIER / 2 - 1)) * CFrame.Angles(signe * math.rad(45), 0, 0),
				Color = metalFonce,
				Material = Enum.Material.Metal,
			}, true))
		end
		-- traverse : poutre métal, liseré rouge clair dessus, bandeaux Neon sur les deux faces
		local largeurTraverse = 2 * wArche + COTE_PILIER
		local traverse = creer(Outils.bloc, m, decor({
			Name = "Traverse",
			Size = Vector3.new(COTE_PILIER, HAUT_TRAVERSE, largeurTraverse),
			CFrame = cadre(u, yTraverse + HAUT_TRAVERSE / 2, 0),
			Color = metalFonce,
			Material = Enum.Material.Metal,
		}))
		creer(Outils.bloc, m, decor({
			Name = "Liseret",
			Size = Vector3.new(COTE_PILIER + 0.2, 0.2, largeurTraverse + 0.2),
			CFrame = cadre(u, yHautPilier + 0.1, 0),
			Color = rougeClair,
			Material = Enum.Material.SmoothPlastic,
		}, true))
		for _, face in ipairs({ 1, -1 }) do
			local bandeau = creer(Outils.bloc, m, decor({
				Name = "Bandeau",
				Size = Vector3.new(0.08, 0.28, largeurTraverse - 1.4),
				CFrame = cadre(u + face * (COTE_PILIER / 2 + 0.04), yTraverse + HAUT_TRAVERSE / 2, 0),
				Color = blancNeon,
				Material = Enum.Material.Neon,
			}, true))
			pulser(bandeau, u)
		end
		-- guirlande d'ampoules sur la traverse (dorées et crème en alternance), laissant le cimier au milieu
		for i, f in ipairs({ -0.7, -0.4, 0.4, 0.7 }) do
			local couleur = ambre
			if i % 2 == 0 then
				couleur = blancNeon
			end
			local bulbe = creer(Outils.boule, m, decor({
				Name = "Guirlande",
				Size = Vector3.new(0.5, 0.5, 0.5),
				CFrame = cadre(u, yHautPilier + 0.45, f * wArche),
				Color = couleur,
				Material = Enum.Material.Neon,
			}, true))
			pulser(bulbe, u + i * 3)
		end
		-- projecteur sous la traverse, vers le tapis
		if traverse then
			pcall(function()
				local spot = Outils.lumiere(traverse, { genre = "Spot", Range = 20, Brightness = 1.4, Color = ambreDoux })
				spot.Face = Enum.NormalId.Bottom
				spot.Angle = 70
			end)
			-- quelques étincelles dorées qui tombent doucement de la traverse (effet léger)
			pcall(function()
				local etincelles = Instance.new("ParticleEmitter")
				etincelles.Name = "Etincelles"
				etincelles.Color = ColorSequence.new(ambre, Charte.creme)
				etincelles.LightEmission = 1
				etincelles.Size = NumberSequence.new(0.25, 0)
				etincelles.Transparency = NumberSequence.new(0.1, 1)
				etincelles.Lifetime = NumberRange.new(1.2, 2)
				etincelles.Rate = 3
				etincelles.Speed = NumberRange.new(0.5, 1.2)
				etincelles.SpreadAngle = Vector2.new(60, 60)
				etincelles.EmissionDirection = Enum.NormalId.Bottom
				etincelles.Parent = traverse
			end)
		end
		-- cimier au milieu de la traverse
		local yCimier = yHautPilier + 0.2
		if sensCimier == 0 then
			-- côté Nurserie : un gros œuf crème tacheté d'or
			creer(Outils.boule, m, decor({
				Name = "Oeuf",
				Size = Vector3.new(1.9, 2.5, 1.9),
				CFrame = cadre(u, yCimier + 1.15, 0),
				Color = Charte.creme,
				Material = Enum.Material.SmoothPlastic,
			}))
			for _, p in ipairs({ { 0.5, 1.5, 0.75 }, { -0.35, 0.9, -0.8 } }) do
				creer(Outils.boule, m, decor({
					Name = "Tache",
					Size = Vector3.new(0.55, 0.55, 0.55),
					CFrame = cadre(u + p[1], yCimier + p[2], p[3]),
					Color = ambre,
					Material = Enum.Material.SmoothPlastic,
				}, true))
			end
		else
			-- côté Grande Porte : un chevron Neon qui montre la sortie, sur un socle doré
			creer(Outils.cylindre, m, decor({
				Name = "SocleCimier",
				Size = Vector3.new(0.4, 1.2, 1.2),
				CFrame = cadre(u, yCimier + 0.2, 0) * CFrame.Angles(0, 0, math.rad(90)),
				Color = Charte.dore,
				Material = Enum.Material.Metal,
			}, true))
			for _, s in ipairs({ 1, -1 }) do
				local bras = creer(Outils.bloc, m, decor({
					Name = "Chevron",
					Size = Vector3.new(1.5, 0.35, 0.35),
					CFrame = cadre(u, yCimier + 1.05 + s * 0.45, 0) * CFrame.Angles(0, 0, -s * math.rad(35)),
					Color = blancNeon,
					Material = Enum.Material.Neon,
				}, true))
				pulser(bras, u)
			end
		end
	end
	arche("ArcheNurserie", uArche, 0)
	arche("ArcheGrandePorte", longueur - uArche, 1)

	modele:SetAttribute("Parts", nombre)
end

return M
