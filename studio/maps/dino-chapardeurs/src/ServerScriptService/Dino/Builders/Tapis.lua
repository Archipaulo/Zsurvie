-- Constructeur Tapis : le grand tapis roulant rouge qui traverse le monde de la Nurserie à la Fin du tapis.
-- Version 2 (STYLE.md §4) : bande en Fabric rouge (Charte.tapis) légèrement bombée (dessus central,
-- bords plus bas et arrondis), tambours d'extrémité où la bande s'enroule, longerons en Metal gris foncé
-- (chapeau clair, semelle, rivets), têtes de rouleaux visibles sur les côtés, pieds de soutien sur une
-- plinthe sombre, chevrons rouge clair mats (SmoothPlastic, pas de Neon : pas de halo Bloom) tous les
-- 16 studs, qui défilent côté client à la vitesse des dinos (genre « defile ») vers la Fin du tapis.
-- Emprise (CONTRAT §10) : de Plan.tapis.debut à Plan.tapis.fin, |z| <= 7 autour de l'axe. Budget : 300 parts.
local M = {}

local BUDGET = 300           -- parts au maximum pour ce constructeur
local LONGUEUR_SEGMENT = 16  -- longueur d'un segment de bande (et pas des rouleaux)
local PAS_FLECHE = 16        -- un chevron tous les 16 studs (période du défilement)
local VITESSE_TAPIS = 7      -- studs/s, remplacée par Equilibrage.tapis.vitesse
local EMPRISE_LATERALE = 7   -- rien au-delà de |z| = 7

-- profil en travers (distances à l'axe, hauteurs depuis le sol)
local LARGEUR_BOMBE = 7      -- dessus central de la bande (au niveau Plan.tapis.hauteur)
local ABAISSE_BORD = 0.06    -- les bords de la bande sont un peu plus bas : effet bombé
local DIAMETRE_ARRONDI = 0.36
local EPAISSEUR_BANDE = 0.3
local HAUT_PLINTHE = 0.2
local BAS_LONGERON = 0.55
local HAUT_LONGERON = 1.3
local EPAISSEUR_LONGERON = 0.5

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- ===== géométrie (Plan.tapis, avec valeurs de secours) =====
	local reglage = Plan.tapis or {}
	local debut = reglage.debut
	local fin = reglage.fin
	if typeof(debut) ~= "Vector3" then
		debut = Vector3.new(-112, 0, 0)
	end
	if typeof(fin) ~= "Vector3" then
		fin = Vector3.new(112, 0, 0)
	end
	local largeur = 10
	if type(reglage.largeur) == "number" and reglage.largeur > 0 then
		largeur = reglage.largeur
	end
	local hauteur = 0.8
	if type(reglage.hauteur) == "number" and reglage.hauteur > 0 then
		hauteur = reglage.hauteur
	end
	-- la bande, les longerons et la plinthe doivent tenir dans l'emprise latérale
	largeur = math.min(largeur, (EMPRISE_LATERALE - 1.6) * 2)

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
	local metalFonce = Charte.pierre:Lerp(Charte.encre, 0.55)
	local metalOmbre = Charte.ombre(metalFonce)
	local metalClair = Charte.pierre:Lerp(Charte.creme, 0.1)
	local metalRouleau = Charte.lumiere(Charte.pierre)
	local metalBrillant = Charte.pierre:Lerp(Charte.creme, 0.45)
	local plinthe = Charte.encre:Lerp(Charte.pierre, 0.25)
	local plintheBas = Charte.encre
	-- chevrons : rouge éclairci mat, lisibles sans voler la vedette aux dinos (ni Neon, ni Bloom)
	local teinteFleche = Charte.lumiere(rouge)
	local vitesseTapis = VITESSE_TAPIS
	local Equilibrage = ctx.Equilibrage
	if Equilibrage and type(Equilibrage.tapis) == "table" and type(Equilibrage.tapis.vitesse) == "number" then
		vitesseTapis = Equilibrage.tapis.vitesse
	end

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

	local modele = Outils.modele(dossier, "TapisRoulant")
	local bande = Outils.dossier(modele, "Bande")
	local fleches = Outils.dossier(modele, "Fleches")
	local rebords = Outils.dossier(modele, "Rebords")
	local rouleaux = Outils.dossier(modele, "Rouleaux")
	local socle = Outils.dossier(modele, "Socle")

	-- la bande court entre les deux tambours d'extrémité
	local uDebutBande = uTambour
	local uFinBande = longueur - uTambour
	local longueurBande = uFinBande - uDebutBande
	local nbSegments = math.max(1, math.ceil(longueurBande / LONGUEUR_SEGMENT - 0.001))
	local function bornes(i)
		local u0 = uDebutBande + (i - 1) * LONGUEUR_SEGMENT
		local u1 = math.min(uFinBande, u0 + LONGUEUR_SEGMENT)
		return u0, u1 - u0
	end
	local uMilieuBande = (uDebutBande + uFinBande) / 2

	-- ===== 1. la bande en Fabric rouge, dessus central en segments de 16 =====
	for i = 1, nbSegments do
		local u0, l = bornes(i)
		if l > 0.05 then
			local segment = creer(Outils.bloc, bande, {
				Name = "Segment" .. i,
				Size = Vector3.new(l, hauteur - basBande, largeurBombe),
				CFrame = cadre(u0 + l / 2, (hauteur + basBande) / 2, 0),
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
	local largeurPlinthe = math.min(EMPRISE_LATERALE * 2 - 0.4, (wExterieur + 1) * 2)
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

	-- ===== 4. chevrons mats tous les 16 studs, pointant vers la Fin du tapis =====
	-- Genre « defile » (Interface/AnimationsDecor, côté client) : chaque modèle Fleche avance le long de
	-- DefileAxe à AnimeVitesse studs/s, décalage modulo DefilePas, pour que la bande semble avancer avec les dinos.
	local nbFleches = math.floor(longueur / PAS_FLECHE)
	local demiEnvergure = math.min(2.6, wBombe - 0.8)
	local recul = demiEnvergure * 0.9
	local epaisseurBras = 0.8
	local longueurBras = math.sqrt(recul * recul + demiEnvergure * demiEnvergure) + epaisseurBras * 0.6
	local angleBras = math.atan2(demiEnvergure, recul)
	for k = 0, nbFleches - 1 do
		local u = PAS_FLECHE / 2 + k * PAS_FLECHE
		local fleche = Outils.modele(fleches, "Fleche" .. (k + 1))
		for _, signe in ipairs({ 1, -1 }) do
			-- chaque bras relie la pointe (sur l'axe, en avant) à un coin arrière
			creer(Outils.bloc, fleche, decor({
				Name = "Bras",
				Size = Vector3.new(longueurBras, 0.08, epaisseurBras),
				CFrame = cadre(u, hauteur + 0.03, signe * demiEnvergure / 2) * CFrame.Angles(0, signe * angleBras, 0),
				Color = teinteFleche,
				Material = Enum.Material.SmoothPlastic,
				Transparency = 0.25,
			}, true))
		end
		pcall(Outils.animer, fleche, "defile", vitesseTapis)
		pcall(function()
			fleche:SetAttribute("DefilePas", PAS_FLECHE)
			fleche:SetAttribute("DefileAxe", axe)
		end)
	end

	-- ===== 5. têtes de rouleaux sur les flancs (environ tous les 16 studs, tambours compris) =====
	local yRouleau = (basLongeron + hautLongeron) / 2
	local nbRouleaux = math.max(1, math.floor(longueur / LONGUEUR_SEGMENT + 0.5))
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

	-- ===== 6. pieds de soutien sous les longerons, posés sur la plinthe =====
	local hautPied = basLongeron - HAUT_PLINTHE
	for k = 0, nbRouleaux - 1 do
		local u = uDebutBande + (k + 0.5) * pasRouleau
		if u < longueur - 1 then
			for _, signe in ipairs({ 1, -1 }) do
				creer(Outils.bloc, socle, decor({
					Name = "Pied",
					Size = Vector3.new(0.6, hautPied, EPAISSEUR_LONGERON),
					CFrame = cadre(u, HAUT_PLINTHE + hautPied / 2, signe * wLongeron),
					Color = metalOmbre,
					Material = Enum.Material.Metal,
				}, true))
				creer(Outils.bloc, socle, decor({
					Name = "Patin",
					Size = Vector3.new(1.1, 0.08, EPAISSEUR_LONGERON + 0.5),
					CFrame = cadre(u, HAUT_PLINTHE + 0.04, signe * wLongeron),
					Color = metalFonce,
					Material = Enum.Material.DiamondPlate,
				}, true))
			end
		end
	end

	-- ===== 7. rivets sur les longerons (entre les rouleaux et les pieds) =====
	local yRivet = hautLongeron - 0.16
	for k = 0, nbRouleaux - 1 do
		for _, decalage in ipairs({ 0.25, 0.75 }) do
			local u = uDebutBande + (k + decalage) * pasRouleau
			if u < longueur - 1 then
				for _, signe in ipairs({ 1, -1 }) do
					creer(Outils.boule, rebords, decor({
						Name = "Rivet",
						Size = Vector3.new(0.22, 0.22, 0.22),
						CFrame = cadre(u, yRivet, signe * (wExterieur + 0.02)),
						Color = metalBrillant,
						Material = Enum.Material.Metal,
					}, true))
				end
			end
		end
	end

	modele:SetAttribute("Parts", nombre)
end

return M
