-- Constructeur Tapis : le grand tapis roulant rouge qui traverse le monde de la Nurserie à la Fin du tapis.
-- Bande rouge en segments de 16, bandes transversales sombres, chevrons Neon dorés qui pulsent,
-- rebords en bois (non collisionnables), petits rouleaux sur les côtés et rouleaux d'extrémité.
-- Emprise (CONTRAT §10) : de Plan.tapis.debut à Plan.tapis.fin, |z| <= 7 autour de l'axe. Budget : 300 parts.
local M = {}

local BUDGET = 300           -- parts au maximum pour ce constructeur
local LONGUEUR_SEGMENT = 16  -- longueur d'un segment de bande
local PAS_FLECHE = 8         -- une flèche tous les 8 studs
local EMPRISE_LATERALE = 7   -- rien au-delà de |z| = 7
local HAUTEUR_REBORD = 1.2   -- hauteur maximale des rebords

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
	-- la bande et ses rebords doivent tenir dans l'emprise latérale
	largeur = math.min(largeur, (EMPRISE_LATERALE - 2) * 2)

	-- repère local : u le long du tapis (de debut vers fin), y vertical, w latéral
	local a = Vector3.new(debut.X, 0, debut.Z)
	local b = Vector3.new(fin.X, 0, fin.Z)
	local longueur = (b - a).Magnitude
	if longueur < 1 then
		return
	end
	local axe = (b - a).Unit
	local haut = Vector3.new(0, 1, 0)
	local cote = axe:Cross(haut)
	local repere = CFrame.fromMatrix(a, axe, haut, cote)
	local function cadre(u, y, w)
		return repere * CFrame.new(u, y, w)
	end

	-- ===== couleurs =====
	local rouge = Charte.tapis
	local rougeSombre = Charte.ombre(Charte.tapis)
	local or_ = Charte.dore
	local bois = Charte.bois
	local boisClair = Charte.lumiere(Charte.bois)
	local metal = Charte.pierre

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
	-- décor pur : ni collision, ni requête, ni contact
	local function decor(props)
		props.CanCollide = false
		props.CanQuery = false
		props.CanTouch = false
		return props
	end

	local modele = Outils.modele(dossier, "TapisRoulant")
	local bande = Outils.dossier(modele, "Bande")
	local fleches = Outils.dossier(modele, "Fleches")
	local rebords = Outils.dossier(modele, "Rebords")
	local rouleaux = Outils.dossier(modele, "Rouleaux")

	-- ===== 1. la bande rouge, en segments de 16 =====
	local nbSegments = math.max(1, math.ceil(longueur / LONGUEUR_SEGMENT - 0.001))
	for i = 1, nbSegments do
		local u0 = (i - 1) * LONGUEUR_SEGMENT
		local u1 = math.min(longueur, u0 + LONGUEUR_SEGMENT)
		local l = u1 - u0
		if l > 0.05 then
			local segment = creer(Outils.bloc, bande, {
				Name = "Segment" .. i,
				Size = Vector3.new(l, hauteur, largeur),
				CFrame = cadre(u0 + l / 2, hauteur / 2, 0),
				Color = rouge,
				CanCollide = true,
				CanQuery = true,
				CanTouch = false,
			})
			if segment then
				segment:SetAttribute("Segment", i)
			end
		end
	end

	-- ===== 2. bandes transversales sombres (texture de bandes), entre les flèches =====
	local nbFleches = math.floor(longueur / PAS_FLECHE)
	for k = 1, nbFleches - 1 do
		local u = k * PAS_FLECHE
		creer(Outils.bloc, bande, decor({
			Name = "Bandeau",
			Size = Vector3.new(0.5, 0.04, largeur - 0.2),
			CFrame = cadre(u, hauteur - 0.01, 0),
			Color = rougeSombre,
		}))
	end

	-- ===== 3. chevrons Neon dorés tous les 8 studs, pointant vers la Fin du tapis =====
	local demiEnvergure = math.min(2, largeur / 2 - 1.2)
	local recul = demiEnvergure
	local longueurBras = math.sqrt(recul * recul + demiEnvergure * demiEnvergure) + 0.6
	local angleBras = math.atan2(demiEnvergure, recul)
	for k = 0, nbFleches - 1 do
		local u = PAS_FLECHE / 2 + k * PAS_FLECHE
		local fleche = Outils.modele(fleches, "Fleche" .. (k + 1))
		local pointe = u + recul / 2
		for _, signe in ipairs({ 1, -1 }) do
			-- chaque bras relie la pointe (sur l'axe) à un coin arrière
			local centreU = pointe - recul / 2
			local centreW = signe * demiEnvergure / 2
			creer(Outils.bloc, fleche, decor({
				Name = "Bras",
				Size = Vector3.new(longueurBras, 0.08, 0.6),
				CFrame = cadre(centreU, hauteur + 0.03, centreW) * CFrame.Angles(0, signe * angleBras, 0),
				Color = or_,
				Material = Enum.Material.Neon,
			}))
		end
		pcall(Outils.animer, fleche, "pulse", 1.5)
	end

	-- ===== 4. rebords en bois de chaque côté (non collisionnables) =====
	local hauteurCorps = HAUTEUR_REBORD - 0.2
	local wRebord = largeur / 2 + 0.5
	for i = 1, nbSegments do
		local u0 = (i - 1) * LONGUEUR_SEGMENT
		local u1 = math.min(longueur, u0 + LONGUEUR_SEGMENT)
		local l = u1 - u0
		if l > 0.05 then
			for _, signe in ipairs({ 1, -1 }) do
				creer(Outils.bloc, rebords, decor({
					Name = "Rebord",
					Size = Vector3.new(l, hauteurCorps, 1),
					CFrame = cadre(u0 + l / 2, hauteurCorps / 2, signe * wRebord),
					Color = bois,
				}))
				-- lisse claire sur le dessus, sommet à HAUTEUR_REBORD
				creer(Outils.bloc, rebords, decor({
					Name = "Lisse",
					Size = Vector3.new(l, 0.2, 1.3),
					CFrame = cadre(u0 + l / 2, HAUTEUR_REBORD - 0.1, signe * (wRebord + 0.05)),
					Color = boisClair,
				}))
			end
		end
	end

	-- ===== 5. petits rouleaux visibles sur les flancs extérieurs =====
	-- cylindre : axe X de la part, tourné pour être perpendiculaire au tapis
	local diametre = 0.8
	local wRouleau = wRebord + 0.5 + 0.35
	if wRouleau + 0.35 > EMPRISE_LATERALE then
		wRouleau = EMPRISE_LATERALE - 0.35
	end
	local quartDeTour = CFrame.Angles(0, math.rad(90), 0)
	for k = 1, nbFleches - 1 do
		local u = k * PAS_FLECHE
		for _, signe in ipairs({ 1, -1 }) do
			creer(Outils.cylindre, rouleaux, decor({
				Name = "Rouleau",
				Size = Vector3.new(0.7, diametre, diametre),
				CFrame = cadre(u, diametre / 2 + 0.05, signe * wRouleau) * quartDeTour,
				Color = metal,
			}))
			-- moyeu doré au bout du rouleau
			creer(Outils.cylindre, rouleaux, decor({
				Name = "Moyeu",
				Size = Vector3.new(0.1, 0.4, 0.4),
				CFrame = cadre(u, diametre / 2 + 0.05, signe * (wRouleau + 0.38)) * quartDeTour,
				Color = or_,
			}))
		end
	end

	-- ===== 6. rouleaux d'extrémité, dans l'emprise, à chaque bout de la bande =====
	local rayonFin = math.min(hauteur, 0.9) / 2
	for _, u in ipairs({ rayonFin, longueur - rayonFin }) do
		creer(Outils.cylindre, rouleaux, decor({
			Name = "RouleauBout",
			Size = Vector3.new(largeur + 0.4, rayonFin * 2 + 0.1, rayonFin * 2 + 0.1),
			CFrame = cadre(u, rayonFin + 0.05, 0) * quartDeTour,
			Color = rougeSombre,
		}))
	end

	modele:SetAttribute("Parts", nombre)
end

return M
