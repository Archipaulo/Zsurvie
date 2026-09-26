-- Constructeur Jungle : végétation dense dans Plan.decor.jungleOuest, jungleEst et jungleNord.
-- Palmiers (troncs en segments inclinés, palmes en coins), bananiers, fougères géantes, lianes,
-- gros champignons, buissons à fleurs tropicales et rochers moussus. Des chemins restent libres.
-- Rien ne déborde des zones, ni dans le Volcan (rayon + 6), ni vers le sentier des Falaises (coffre).
local M = {}

-- réglages par défaut (surchargés par Equilibrage.jungle s'il existe)
local DEFAUTS = {
	budget = 1100,        -- parts au maximum pour ce constructeur
	graine = 7331,        -- graine fixe : la jungle est identique à chaque partie
	limiteX = 166,        -- |x| maximal de l'emprise
	margeVolcan = 6,      -- distance gardée autour du Volcan
	palmiers = 30,
	lianesArc = 12,       -- lianes tendues entre deux palmiers
	lianesPendantes = 8,  -- lianes qui pendent d'une couronne
	bananiers = 14,
	rochers = 12,
	champignons = 18,
	fougeres = 26,
	buissons = 26,
	essais = 80,          -- tirages au plus pour placer un élément
	largeurChemin = 8,    -- largeur des chemins libres
	animes = 14,          -- feuillages animés au plus
	vitesseAnime = 0.3,
}

local function reglage(ctx, cle)
	local E = ctx.Equilibrage
	local j = E and E.jungle
	if type(j) == "table" and type(j[cle]) == "number" then
		return j[cle]
	end
	return DEFAUTS[cle]
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier and Plan.decor) then
		return
	end

	local BUDGET = reglage(ctx, "budget")
	local nbParts = 0
	local rng = Outils.aleatoire(reglage(ctx, "graine"))

	-- ===== compteur de parts =====
	local function reste()
		return BUDGET - nbParts
	end

	local function creer(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		local ok, p = pcall(fabrique, parent, props)
		if not ok then
			return nil
		end
		nbParts = nbParts + 1
		return p
	end
	local function bloc(parent, props) return creer(Outils.bloc, parent, props) end
	local function coin(parent, props) return creer(Outils.coin, parent, props) end
	local function cylindre(parent, props) return creer(Outils.cylindre, parent, props) end
	local function boule(parent, props) return creer(Outils.boule, parent, props) end

	local function hasard(a, b)
		return rng:NextNumber(a, b)
	end
	local function choisir(liste)
		return liste[rng:NextInteger(1, #liste)]
	end

	-- ===== couleurs (toutes issues de la charte) =====
	local VERT = Charte.jungle
	local VERT_CLAIR = Charte.herbe
	local VERT_SOMBRE = Charte.ombre(Charte.jungle)
	local VERTS = { VERT, VERT_CLAIR, VERT_SOMBRE, Charte.lumiere(Charte.jungle) }
	local BOIS = Charte.bois
	local BOIS_CLAIR = Charte.terre
	local FLEURS = {
		Charte.alerte, Charte.dore, Charte.violet, Charte.lave, Charte.gemme,
		(Charte.raretes and Charte.raretes.Mythique) or Charte.alerte,
	}
	local CHAPEAUX = { Charte.alerte, Charte.lave, Charte.violet }

	-- ===== emprise =====
	local limiteX = reglage(ctx, "limiteX")
	local zones = {}
	for _, nom in ipairs({ "jungleOuest", "jungleEst", "jungleNord" }) do
		local z = Plan.decor[nom]
		if z and z.min and z.max then
			local x0 = math.max(math.min(z.min.X, z.max.X), -limiteX)
			local x1 = math.min(math.max(z.min.X, z.max.X), limiteX)
			local z0 = math.min(z.min.Z, z.max.Z)
			local z1 = math.max(z.min.Z, z.max.Z)
			if x1 > x0 and z1 > z0 then
				table.insert(zones, { nom = nom, x0 = x0, x1 = x1, z0 = z0, z1 = z1, aire = (x1 - x0) * (z1 - z0) })
			end
		end
	end
	if #zones == 0 then
		return
	end
	local aireTotale = 0
	for _, z in ipairs(zones) do
		aireTotale = aireTotale + z.aire
	end

	-- Volcan : disque interdit (rayon + marge)
	local volcanCentre = nil
	local volcanRayon = 0
	if Plan.volcan and Plan.volcan.centre then
		volcanCentre = Plan.volcan.centre
		volcanRayon = (Plan.volcan.rayon or 34) + reglage(ctx, "margeVolcan")
	end

	-- rectangles interdits : le sentier et la plateforme du coffre (Falaises)
	local interdits = {}
	if Plan.coffre then
		local c = Plan.coffre
		table.insert(interdits, { x0 = c.X - 16, x1 = c.X + 16, z0 = c.Z - 12, z1 = c.Z + 24 })
	end

	-- chemins libres (rien ne pousse dessus au sol)
	local demi = reglage(ctx, "largeurChemin") / 2
	local chemins = {}
	for _, z in ipairs(zones) do
		if z.nom == "jungleNord" then
			-- allées nord-sud vers le fond de la carte
			for _, cx in ipairs({ -115, -62, 62, 115 }) do
				if cx > z.x0 and cx < z.x1 then
					table.insert(chemins, { x0 = cx - demi, x1 = cx + demi, z0 = z.z0, z1 = z.z1 })
				end
			end
		else
			-- traversées est-ouest des bandes latérales
			for _, cz in ipairs({ -100, -45, 0, 50, 100 }) do
				if cz > z.z0 and cz < z.z1 then
					table.insert(chemins, { x0 = z.x0, x1 = z.x1, z0 = cz - demi, z1 = cz + demi })
				end
			end
		end
	end

	-- le cercle (x, z, r) touche-t-il le rectangle ?
	local function cercleRect(x, z, r, q)
		local px = math.max(q.x0, math.min(x, q.x1))
		local pz = math.max(q.z0, math.min(z, q.z1))
		local dx, dz = x - px, z - pz
		return dx * dx + dz * dz < r * r
	end

	-- le cercle (x, z, r) est-il entièrement dans l'emprise autorisée ?
	local function dansEmprise(x, z, r)
		local dedans = false
		for _, q in ipairs(zones) do
			if x - r >= q.x0 and x + r <= q.x1 and z - r >= q.z0 and z + r <= q.z1 then
				dedans = true
				break
			end
		end
		if not dedans then
			return false
		end
		if volcanCentre then
			local dx, dz = x - volcanCentre.X, z - volcanCentre.Z
			if math.sqrt(dx * dx + dz * dz) < volcanRayon + r then
				return false
			end
		end
		for _, q in ipairs(interdits) do
			if cercleRect(x, z, r, q) then
				return false
			end
		end
		return true
	end

	local function surChemin(x, z, r)
		for _, q in ipairs(chemins) do
			if cercleRect(x, z, r, q) then
				return true
			end
		end
		return false
	end

	-- occupation du sol (pieds des plantes) pour espacer les éléments
	local occupes = {}
	local function libre(x, z, r)
		for _, o in ipairs(occupes) do
			local dx, dz = x - o.x, z - o.z
			local mini = (r + o.r) * 0.9
			if dx * dx + dz * dz < mini * mini then
				return false
			end
		end
		return true
	end
	local function occuper(x, z, r)
		table.insert(occupes, { x = x, z = z, r = r })
	end

	-- tirage d'un point au hasard, zones pondérées par leur aire
	local function pointAuHasard()
		local t = hasard(0, aireTotale)
		local zone = zones[#zones]
		for _, q in ipairs(zones) do
			if t <= q.aire then
				zone = q
				break
			end
			t = t - q.aire
		end
		return hasard(zone.x0, zone.x1), hasard(zone.z0, zone.z1)
	end

	-- cherche un emplacement : pied libre (rayon rSol) hors chemins, feuillage (rayon rEmprise) dans l'emprise
	local ESSAIS = reglage(ctx, "essais")
	local function trouverPlace(rSol, rEmprise)
		for _ = 1, ESSAIS do
			local x, z = pointAuHasard()
			if dansEmprise(x, z, rEmprise) and not surChemin(x, z, rSol) and libre(x, z, rSol) then
				return x, z
			end
		end
		return nil, nil
	end

	-- feuillages animés (quelques-uns seulement)
	local nbAnimes = 0
	local ANIMES_MAX = reglage(ctx, "animes")
	local VITESSE = reglage(ctx, "vitesseAnime")
	local function peutEtreAnime(modele, chance)
		if nbAnimes < ANIMES_MAX and rng:NextNumber() < chance then
			nbAnimes = nbAnimes + 1
			pcall(Outils.animer, modele, "flotte", VITESSE)
		end
	end

	-- segment fin entre deux points (lianes)
	local function segment(parent, a, b, epaisseur, couleur, nom)
		local d = b - a
		local long = d.Magnitude
		if long < 0.05 then
			return nil
		end
		local haut = Vector3.new(0, 1, 0)
		if math.abs(d.Unit.Y) > 0.9 then
			haut = Vector3.new(1, 0, 0)
		end
		local milieu = a:Lerp(b, 0.5)
		return bloc(parent, {
			Name = nom or "Liane",
			Size = Vector3.new(epaisseur, epaisseur, long + epaisseur * 0.5),
			CFrame = CFrame.lookAt(milieu, b, haut),
			Color = couleur,
			CanCollide = false,
		})
	end

	-- ===== dossiers =====
	local dPalmiers = Outils.dossier(dossier, "Palmiers")
	local dLianes = Outils.dossier(dossier, "Lianes")
	local dBananiers = Outils.dossier(dossier, "Bananiers")
	local dRochers = Outils.dossier(dossier, "Rochers")
	local dChampignons = Outils.dossier(dossier, "Champignons")
	local dFougeres = Outils.dossier(dossier, "Fougeres")
	local dBuissons = Outils.dossier(dossier, "Buissons")

	-- ===== palmiers =====
	local COUT_PALMIER = 15
	local couronnes = {} -- sommets des palmiers : { pos, rayon }

	-- calcule le tronc (segments inclinés de plus en plus) et le sommet
	local function tronc(x, z, hauteur, n, lean, psi)
		local segs = {}
		local p = Vector3.new(x, 0, z)
		local longueur = hauteur / n
		for i = 1, n do
			local t = math.rad(lean * i / n)
			local dir = Vector3.new(math.sin(t) * math.cos(psi), math.cos(t), -math.sin(t) * math.sin(psi))
			local centre = p + dir * (longueur / 2)
			table.insert(segs, { centre = centre, t = t, longueur = longueur })
			p = p + dir * longueur
		end
		return segs, p
	end

	local function palmier(numero)
		if reste() < COUT_PALMIER then
			return false
		end
		local hauteur = hasard(15, 23)
		local n = 5
		local lean = hasard(6, 22)
		local psi = hasard(0, math.pi * 2)
		local longPalme = hasard(5.5, 7.5)
		local rCouronne = longPalme * 0.95 + 1
		-- le sommet dépend de l'inclinaison : on vérifie la couronne à sa vraie place
		local x, z = nil, nil
		local segs, sommet = nil, nil
		for _ = 1, ESSAIS do
			local px, pz = pointAuHasard()
			if dansEmprise(px, pz, 2) and not surChemin(px, pz, 2.2) and libre(px, pz, 2.5) then
				local s, top = tronc(px, pz, hauteur, n, lean, psi)
				if dansEmprise(top.X, top.Z, rCouronne) then
					x, z, segs, sommet = px, pz, s, top
					break
				end
			end
		end
		if not x then
			return false
		end
		occuper(x, z, 2.5)

		local m = Outils.modele(dPalmiers, "Palmier" .. numero)
		local largeur = 1.7
		for i, s in ipairs(segs) do
			local w = largeur - (i - 1) * 0.12
			local couleur = BOIS
			if i % 2 == 0 then
				couleur = BOIS_CLAIR
			end
			bloc(m, {
				Name = "Tronc" .. i,
				Size = Vector3.new(w, s.longueur + 0.35, w),
				CFrame = CFrame.new(s.centre) * CFrame.Angles(0, psi, 0) * CFrame.Angles(0, 0, -s.t),
				Color = couleur,
			})
		end
		boule(m, { Name = "Coeur", Size = Vector3.new(2.4, 2.4, 2.4), CFrame = CFrame.new(sommet), Color = VERT_SOMBRE, CanCollide = false })
		for k = 1, 2 do
			local a = hasard(0, math.pi * 2)
			boule(m, {
				Name = "Noix" .. k,
				Size = Vector3.new(1, 1, 1),
				CFrame = CFrame.new(sommet + Vector3.new(math.cos(a) * 0.9, -1.1, math.sin(a) * 0.9)),
				Color = Charte.ombre(BOIS),
				CanCollide = false,
			})
		end
		-- palmes en coins : partie haute contre le coeur, pointe qui retombe vers l'extérieur
		local palmes = Outils.modele(m, "Palmes")
		local nbPalmes = 7
		local decalage = hasard(0, math.pi * 2)
		for k = 1, nbPalmes do
			local yaw = decalage + (k - 1) * (math.pi * 2 / nbPalmes) + hasard(-0.15, 0.15)
			local pitch = -math.rad(hasard(18, 34))
			local long = longPalme * hasard(0.85, 1.05)
			local couleur = VERT
			if k % 2 == 0 then
				couleur = VERT_CLAIR
			end
			coin(palmes, {
				Name = "Palme" .. k,
				Size = Vector3.new(hasard(2, 2.6), 0.7, long),
				CFrame = CFrame.new(sommet) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0.1, -long / 2),
				Color = couleur,
				CanCollide = false,
			})
		end
		peutEtreAnime(palmes, 0.2)
		table.insert(couronnes, { pos = sommet, rayon = longPalme })
		return true
	end

	for i = 1, reglage(ctx, "palmiers") do
		palmier(i)
	end

	-- vérifie que tous les points d'une liane restent dans l'emprise
	local function cheminValide(points)
		for _, p in ipairs(points) do
			if not dansEmprise(p.X, p.Z, 0.5) then
				return false
			end
		end
		return true
	end

	-- ===== lianes tendues entre deux couronnes voisines =====
	local COULEUR_LIANE = Charte.ombre(VERT_SOMBRE)
	local lies = {}
	local nbArcs = 0
	local ARCS_MAX = reglage(ctx, "lianesArc")
	for i, a in ipairs(couronnes) do
		if nbArcs >= ARCS_MAX or reste() < 5 then
			break
		end
		local meilleur, dMeilleur = nil, 1e9
		for j, b in ipairs(couronnes) do
			if j ~= i and not lies[j] then
				local d = Outils.distanceXZ(a.pos, b.pos)
				if d >= 8 and d <= 22 and d < dMeilleur then
					meilleur, dMeilleur = j, d
				end
			end
		end
		if meilleur and not lies[i] then
			local b = couronnes[meilleur]
			local depart = a.pos - Vector3.new(0, 0.8, 0)
			local arrivee = b.pos - Vector3.new(0, 0.8, 0)
			local creux = hasard(2.5, 4.5)
			local points = {}
			local n = 5
			for k = 0, n do
				local u = k / n
				table.insert(points, depart:Lerp(arrivee, u) - Vector3.new(0, creux * 4 * u * (1 - u), 0))
			end
			if cheminValide(points) then
				local m = Outils.modele(dLianes, "LianeArc" .. (nbArcs + 1))
				for k = 1, n do
					segment(m, points[k], points[k + 1], 0.35, COULEUR_LIANE, "Liane" .. k)
				end
				lies[i] = true
				lies[meilleur] = true
				nbArcs = nbArcs + 1
			end
		end
	end

	-- ===== lianes pendantes sous les couronnes =====
	local nbPendantes = 0
	local PENDANTES_MAX = reglage(ctx, "lianesPendantes")
	for i, c in ipairs(couronnes) do
		if nbPendantes >= PENDANTES_MAX or reste() < 3 then
			break
		end
		if i % 3 == 1 then
			local a = hasard(0, math.pi * 2)
			local ecart = c.rayon * 0.55
			local haut = c.pos + Vector3.new(math.cos(a) * ecart, -1.6, math.sin(a) * ecart)
			local basY = hasard(3.5, 6.5)
			local milieu = Vector3.new(haut.X + hasard(-0.6, 0.6), (haut.Y + basY) / 2, haut.Z + hasard(-0.6, 0.6))
			local bas = Vector3.new(haut.X + hasard(-0.4, 0.4), basY, haut.Z + hasard(-0.4, 0.4))
			if haut.Y - basY > 3 and cheminValide({ haut, milieu, bas }) then
				local m = Outils.modele(dLianes, "LianePendante" .. (nbPendantes + 1))
				segment(m, haut, milieu, 0.3, COULEUR_LIANE, "Liane1")
				segment(m, milieu, bas, 0.3, COULEUR_LIANE, "Liane2")
				boule(m, { Name = "Feuille", Size = Vector3.new(0.9, 0.9, 0.9), CFrame = CFrame.new(bas), Color = VERT_CLAIR, CanCollide = false })
				nbPendantes = nbPendantes + 1
			end
		end
	end

	-- ===== bananiers =====
	local COUT_BANANIER = 8
	local function bananier(numero)
		if reste() < COUT_BANANIER then
			return false
		end
		local hauteur = hasard(6.5, 9)
		local longFeuille = hasard(5, 6.5)
		local x, z = trouverPlace(3, longFeuille + 0.5)
		if not x then
			return false
		end
		occuper(x, z, 3)
		local m = Outils.modele(dBananiers, "Bananier" .. numero)
		local d = hasard(1.2, 1.6)
		cylindre(m, {
			Name = "Tige",
			Size = Vector3.new(hauteur, d, d),
			CFrame = CFrame.new(x, hauteur / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Charte.lumiere(VERT_CLAIR),
		})
		local sommet = Vector3.new(x, hauteur, z)
		local feuilles = Outils.modele(m, "Feuilles")
		local decalage = hasard(0, math.pi * 2)
		for k = 1, 5 do
			local yaw = decalage + (k - 1) * (math.pi * 2 / 5) + hasard(-0.2, 0.2)
			local pitch = math.rad(hasard(-8, 28))
			bloc(feuilles, {
				Name = "Feuille" .. k,
				Size = Vector3.new(hasard(2.2, 2.8), 0.25, longFeuille),
				CFrame = CFrame.new(sommet) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, -longFeuille / 2),
				Color = choisir(VERTS),
				CanCollide = false,
			})
		end
		peutEtreAnime(feuilles, 0.25)
		-- régime de bananes et fleur violette
		local a = hasard(0, math.pi * 2)
		local regime = sommet + Vector3.new(math.cos(a) * 1.1, -1.6, math.sin(a) * 1.1)
		bloc(m, {
			Name = "Bananes",
			Size = Vector3.new(1.1, 1.8, 1.1),
			CFrame = CFrame.new(regime) * CFrame.Angles(0, a, 0),
			Color = Charte.dore,
			CanCollide = false,
		})
		boule(m, {
			Name = "Fleur",
			Size = Vector3.new(0.9, 0.9, 0.9),
			CFrame = CFrame.new(regime - Vector3.new(0, 1.3, 0)),
			Color = Charte.violet,
			CanCollide = false,
		})
		return true
	end

	for i = 1, reglage(ctx, "bananiers") do
		bananier(i)
	end

	-- ===== rochers moussus =====
	local COUT_ROCHER = 3
	local function rocher(numero)
		if reste() < COUT_ROCHER then
			return false
		end
		local sx, sy, sz = hasard(3, 6), hasard(2, 4), hasard(3, 6)
		local r = math.sqrt(sx * sx + sz * sz) / 2
		local x, z = trouverPlace(r * 0.8, r + 1.5)
		if not x then
			return false
		end
		occuper(x, z, r * 0.8)
		local m = Outils.modele(dRochers, "Rocher" .. numero)
		local angle = hasard(0, 360)
		local taille = Vector3.new(sx, sy, sz)
		bloc(m, { Name = "Pierre", Size = taille, CFrame = Outils.surSol(taille, x, z, angle), Color = Charte.pierre })
		local mousse = Vector3.new(sx * 0.85, 0.35, sz * 0.85)
		bloc(m, {
			Name = "Mousse",
			Size = mousse,
			CFrame = Outils.surSol(mousse, x, z, angle, sy - 0.05),
			Color = VERT_CLAIR,
			CanCollide = false,
		})
		-- petit caillou accolé
		local petit = Vector3.new(sx * 0.45, sy * 0.5, sz * 0.45)
		local a = math.rad(angle)
		bloc(m, {
			Name = "Caillou",
			Size = petit,
			CFrame = Outils.surSol(petit, x + math.cos(a) * sx * 0.6, z - math.sin(a) * sx * 0.6, angle + 25),
			Color = Charte.ombre(Charte.pierre),
		})
		return true
	end

	for i = 1, reglage(ctx, "rochers") do
		rocher(i)
	end

	-- ===== gros champignons =====
	local COUT_CHAMPIGNON = 5
	local function champignon(numero)
		if reste() < COUT_CHAMPIGNON then
			return false
		end
		local hs = hasard(2, 5)
		local ds = hasard(0.9, 1.5)
		local dc = hasard(3.5, 6)
		local x, z = trouverPlace(dc * 0.4, dc / 2 + 0.2)
		if not x then
			return false
		end
		occuper(x, z, dc * 0.4)
		local m = Outils.modele(dChampignons, "Champignon" .. numero)
		local couleur = choisir(CHAPEAUX)
		local lumineux = couleur == Charte.violet
		cylindre(m, {
			Name = "Pied",
			Size = Vector3.new(hs, ds, ds),
			CFrame = CFrame.new(x, hs / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Charte.creme,
		})
		local hc = 1.1
		cylindre(m, {
			Name = "Chapeau",
			Size = Vector3.new(hc, dc, dc),
			CFrame = CFrame.new(x, hs + hc / 2 - 0.2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
		})
		local haut = cylindre(m, {
			Name = "Dome",
			Size = Vector3.new(hc * 0.8, dc * 0.65, dc * 0.65),
			CFrame = CFrame.new(x, hs + hc + hc * 0.4 - 0.2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
		})
		local yTop = hs + hc + hc * 0.8 - 0.2
		local couleurPois = Charte.creme
		local matiere = Enum.Material.SmoothPlastic
		if lumineux then
			couleurPois = Charte.gemme
			matiere = Enum.Material.Neon
		end
		for k = 1, 2 do
			local a = hasard(0, math.pi * 2)
			local r = dc * hasard(0.12, 0.28)
			boule(m, {
				Name = "Pois" .. k,
				Size = Vector3.new(0.8, 0.8, 0.8),
				CFrame = CFrame.new(x + math.cos(a) * r, yTop, z + math.sin(a) * r),
				Color = couleurPois,
				Material = matiere,
				CanCollide = false,
			})
		end
		if lumineux and haut then
			pcall(Outils.lumiere, haut, { Range = 10, Brightness = 0.8, Color = Charte.gemme })
		end
		return true
	end

	for i = 1, reglage(ctx, "champignons") do
		champignon(i)
	end

	-- ===== fougères géantes =====
	local COUT_FOUGERE = 7
	local function fougere(numero)
		if reste() < COUT_FOUGERE then
			return false
		end
		local long = hasard(4.5, 6.5)
		local x, z = trouverPlace(2.5, long * 0.75 + 0.5)
		if not x then
			return false
		end
		occuper(x, z, 2.5)
		local m = Outils.modele(dFougeres, "Fougere" .. numero)
		local feuilles = Outils.modele(m, "Feuilles")
		local decalage = hasard(0, math.pi * 2)
		local base = Vector3.new(x, 0.3, z)
		for k = 1, 7 do
			local yaw = decalage + (k - 1) * (math.pi * 2 / 7) + hasard(-0.2, 0.2)
			local pitch = math.rad(hasard(38, 56))
			local l = long * hasard(0.85, 1.05)
			local couleur = VERT
			if k % 2 == 0 then
				couleur = VERT_SOMBRE
			end
			coin(feuilles, {
				Name = "Fronde" .. k,
				Size = Vector3.new(hasard(1.2, 1.6), 0.45, l),
				CFrame = CFrame.new(base) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, -l / 2),
				Color = couleur,
				CanCollide = false,
			})
		end
		peutEtreAnime(feuilles, 0.25)
		return true
	end

	for i = 1, reglage(ctx, "fougeres") do
		fougere(i)
	end

	-- ===== buissons à fleurs tropicales =====
	local COUT_BUISSON = 6
	local function buisson(numero)
		if reste() < COUT_BUISSON then
			return false
		end
		local x, z = trouverPlace(2.2, 3.8)
		if not x then
			return false
		end
		occuper(x, z, 2.2)
		local m = Outils.modele(dBuissons, "Buisson" .. numero)
		local boules = {}
		local nb = rng:NextInteger(2, 3)
		for k = 1, nb do
			local s = hasard(2.8, 4.2)
			local a = hasard(0, math.pi * 2)
			local r = 0
			if k > 1 then
				r = hasard(0.8, 1.4)
			end
			local centre = Vector3.new(x + math.cos(a) * r, s * 0.4, z + math.sin(a) * r)
			boule(m, {
				Name = "Feuillage" .. k,
				Size = Vector3.new(s, s, s),
				CFrame = CFrame.new(centre),
				Color = choisir(VERTS),
				CanCollide = false,
			})
			table.insert(boules, { centre = centre, s = s })
		end
		-- fleurs posées sur le dessus des boules de feuillage
		for k = 1, 6 - nb do
			local b = boules[rng:NextInteger(1, #boules)]
			local a = hasard(0, math.pi * 2)
			local el = hasard(0.35, 1.2)
			local dir = Vector3.new(math.cos(a) * math.cos(el), math.sin(el), math.sin(a) * math.cos(el))
			boule(m, {
				Name = "Fleur" .. k,
				Size = Vector3.new(0.9, 0.9, 0.9),
				CFrame = CFrame.new(b.centre + dir * (b.s / 2)),
				Color = choisir(FLEURS),
				CanCollide = false,
			})
		end
		return true
	end

	for i = 1, reglage(ctx, "buissons") do
		buisson(i)
	end

	dossier:SetAttribute("Parts", nbParts)
end

return M
