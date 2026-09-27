-- Constructeur Jungle (version 2, STYLE.md §4) : végétation dense dans Plan.decor.jungleOuest, jungleEst et jungleNord.
-- Sol de jungle en terrain (LeafyGrass, sentiers de terre Ground, buttes sous les gros arbres, rochers Rock/Slate
-- coiffés de mousse), gros arbres à canopée en boules Grass (trois teintes, racines contreforts, lianes),
-- palmiers aux troncs Wood en segments cylindriques légèrement courbés et palmes en arcs retombants de trois
-- segments pliés en V (deux couronnes décalées, deux verts, pointes éclaircies),
-- bananiers, fougères, buissons à fleurs tropicales, champignons, troncs couchés moussus, touffes fleuries,
-- et des lucioles très discrètes en lisière. Les grands végétaux restent au fond ; la lisière tournée vers
-- le centre de jeu ne garde que des plantes basses et clairsemées. Rien hors de l'emprise, ni dans le Volcan
-- (rayon + 6), ni sur le sentier des Falaises (coffre), ni sur les sentiers de la jungle.
local M = {}

-- réglages par défaut (surchargés par Equilibrage.jungle s'il existe)
local DEFAUTS = {
	budget = 1300,        -- parts au maximum pour ce constructeur (le terrain ne compte pas)
	graine = 7331,        -- graine fixe : la jungle est identique à chaque partie
	limiteX = 166,        -- |x| maximal de l'emprise
	margeVolcan = 6,      -- distance gardée autour du Volcan
	celluleCotes = 15,    -- les grands végétaux sont répartis par cellules (densité régulière)
	celluleNord = 22,
	partArbres = 0.5,     -- part des cellules plantées d'un gros arbre (sinon palmier, parfois bananier)
	palmiers = 10,        -- palmiers au plus (~54 parts chacun avec leurs palmes en arcs) ; au-delà, gros arbres
	reserveBasse = 380,   -- parts gardées pour bananiers, fougères, buissons, champignons, troncs, lianes et touffes
	partVides = 0.12,     -- part des cellules laissées aux rochers et bananiers
	rochers = 16,
	bananiers = 8,
	fougeres = 16,
	buissons = 12,
	champignons = 8,      -- groupes de 1 à 3 champignons
	troncs = 3,           -- troncs couchés
	lianesArc = 5,        -- lianes tendues entre deux palmiers
	touffes = 14,         -- touffes d'herbe (parfois fleuries) en lisière
	essais = 90,          -- tirages au plus pour placer un élément
	essaisCellule = 30,
	largeurChemin = 7,    -- largeur des sentiers libres
	lisiere = 4,          -- bande côté centre de jeu : seulement des plantes basses et clairsemées
	densiteLisiere = 0.35,
	pasLucioles = 34,     -- espacement des nuées de lucioles le long de la lisière
	zSolMax = 118,        -- le sol de jungle s'arrête avant la plage de la rivière
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

	local Mat = Enum.Material
	local V3 = Vector3.new
	local DEUX_PI = math.pi * 2
	local BUDGET = reglage(ctx, "budget")
	local nbParts = 0
	local rng = Outils.aleatoire(reglage(ctx, "graine"))
	local terrainOk = Outils.terrainBloc ~= nil and Outils.terrainBoule ~= nil and Outils.terrainCylindre ~= nil

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

	-- ===== palette (trois teintes : base, Charte.ombre, Charte.lumiere) =====
	local hex = Charte.hex
	local ombre = Charte.ombre
	local lumiere = Charte.lumiere
	local PALME = hex("4CC83F")          -- palmes claires (Grass)
	local PALME_SOMBRE = hex("2A9B3C")   -- palmes foncées (LeafyGrass)
	local PALME_SECHE = hex("B98A3E")    -- vieille palme qui pend
	local COEUR = hex("2E8A33")
	local TRONC = hex("9C6A3C")
	local TRONC_CLAIR = hex("B8844F")
	local TRONC_PIED = hex("7A4F2C")
	local NOIX = hex("6B4424")
	local ECORCE = hex("6E4526")
	local ECORCE_CLAIRE = hex("875632")
	local FEUILLAGES = { hex("3FB548"), hex("35A84A"), hex("4DBF3A") }
	local FOUGERE = hex("2FA04A")
	local FOUGERE_CLAIRE = hex("5CC94F")
	local HERBE = hex("8EDB4A")
	local BANANIER_TIGE = hex("8DB04E")
	local BANANIER_FEUILLES = { hex("4CC24A"), hex("37A845"), hex("62D14F") }
	local BANANES = hex("FFD83A")
	local BOURGEON = hex("9B3FB5")
	local FLEURS = { hex("FF3B5C"), hex("FF8A1F"), hex("FF5CC8"), hex("FFD23F"), hex("A45CFF"), hex("FF6A3D") }
	local PISTIL = hex("FFE14D")
	local CHAPEAUX = { hex("E8323C"), hex("FF7A1F"), hex("8E4DFF"), hex("E8323C") }
	local CHAPEAU_LUMINEUX = CHAPEAUX[3]
	local CREME = Charte.creme
	local LIANE = hex("3E8E2E")
	local LUCIOLE = hex("FFF27A")

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

	-- rectangles interdits : le sentier et la plateforme du coffre (Falaises), avec l'accès à son pied
	local interdits = {}
	if Plan.coffre then
		local c = Plan.coffre
		local versCentre = 1
		if c.Z > 0 then
			versCentre = -1
		end
		local zA, zB = c.Z - versCentre * 12, c.Z + versCentre * 62
		table.insert(interdits, { x0 = c.X - 16, x1 = c.X + 16, z0 = math.min(zA, zB), z1 = math.max(zA, zB) })
	end

	-- sentiers libres (rien ne pousse dessus, terre battue au sol)
	local demi = reglage(ctx, "largeurChemin") / 2
	local chemins = {}
	for _, z in ipairs(zones) do
		if z.nom == "jungleNord" then
			for _, cx in ipairs({ -98, 98 }) do
				if cx > z.x0 and cx < z.x1 then
					table.insert(chemins, { x0 = cx - demi, x1 = cx + demi, z0 = z.z0, z1 = z.z1 })
				end
			end
		else
			for _, cz in ipairs({ -80, -8, 64 }) do
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

	-- ===== lisière : côtés des zones tournés vers le centre de jeu (sans les côtés collés à une autre zone) =====
	local cotes = {}
	for _, q in ipairs(zones) do
		local candidats = {}
		if q.x1 <= 0 then table.insert(candidats, { axe = "X", v = q.x1, sens = -1, a0 = q.z0, a1 = q.z1 }) end
		if q.x0 >= 0 then table.insert(candidats, { axe = "X", v = q.x0, sens = 1, a0 = q.z0, a1 = q.z1 }) end
		if q.z1 <= 0 then table.insert(candidats, { axe = "Z", v = q.z1, sens = -1, a0 = q.x0, a1 = q.x1 }) end
		if q.z0 >= 0 then table.insert(candidats, { axe = "Z", v = q.z0, sens = 1, a0 = q.x0, a1 = q.x1 }) end
		for _, c in ipairs(candidats) do
			local morceaux = { { c.a0, c.a1 } }
			for _, r in ipairs(zones) do
				if r ~= q then
					local colle, b0, b1 = false, 0, 0
					if c.axe == "X" then
						if c.sens < 0 then colle = math.abs(r.x0 - c.v) < 0.5 else colle = math.abs(r.x1 - c.v) < 0.5 end
						b0, b1 = r.z0, r.z1
					else
						if c.sens < 0 then colle = math.abs(r.z0 - c.v) < 0.5 else colle = math.abs(r.z1 - c.v) < 0.5 end
						b0, b1 = r.x0, r.x1
					end
					if colle then
						local nouveaux = {}
						for _, m in ipairs(morceaux) do
							if m[1] < b0 then table.insert(nouveaux, { m[1], math.min(m[2], b0) }) end
							if m[2] > b1 then table.insert(nouveaux, { math.max(m[1], b1), m[2] }) end
						end
						morceaux = nouveaux
					end
				end
			end
			for _, m in ipairs(morceaux) do
				if m[2] - m[1] > 0.5 then
					table.insert(cotes, { axe = c.axe, v = c.v, sens = c.sens, a0 = m[1], a1 = m[2] })
				end
			end
		end
	end

	-- distance à la lisière (profondeur dans la jungle)
	local function profondeur(x, z)
		local d = 1e9
		for _, c in ipairs(cotes) do
			local n, a = x, z
			if c.axe == "Z" then
				n, a = z, x
			end
			local dn = math.abs(n - c.v)
			local da = math.max(0, c.a0 - a, a - c.a1)
			d = math.min(d, math.sqrt(dn * dn + da * da))
		end
		return d
	end

	-- occupation du sol (pieds des plantes) et des cimes (couronnes, canopées)
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
	local cimes = {}
	local function cimeLibre(x, z, r)
		for _, c in ipairs(cimes) do
			local dx, dz = x - c.x, z - c.z
			local mini = (r + c.r) * 0.72
			if dx * dx + dz * dz < mini * mini then
				return false
			end
		end
		return true
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

	local ESSAIS = reglage(ctx, "essais")
	local LISIERE = reglage(ctx, "lisiere")
	local DENSITE_LISIERE = reglage(ctx, "densiteLisiere")
	local ESSAIS_CELLULE = reglage(ctx, "essaisCellule")
	-- cherche un point qui convient (dans une cellule si elle est donnée, sinon n'importe où)
	local function chercher(essai, cellule)
		local n = ESSAIS
		if cellule then
			n = ESSAIS_CELLULE
		end
		for _ = 1, n do
			local x, z = nil, nil
			if cellule then
				x, z = hasard(cellule.x0, cellule.x1), hasard(cellule.z0, cellule.z1)
			else
				x, z = pointAuHasard()
			end
			if essai(x, z) then
				return x, z
			end
		end
		return nil, nil
	end

	-- relief : buttes de terrain (talus au fond, butte au pied des arbres) ; hauteur du sol sous un point
	local buttes = {}
	local function hauteurSol(x, z)
		local h = 0
		for _, b in ipairs(buttes) do
			local dx, dz = x - b.x, z - b.z
			local d2 = dx * dx + dz * dz
			if d2 < b.r * b.r then
				h = math.max(h, b.y + math.sqrt(b.r * b.r - d2))
			end
		end
		return h
	end
	-- plante basse : pied libre hors sentiers, clairsemée en lisière
	local function placeBasse(rSol, rEmprise, profMin, cellule)
		return chercher(function(x, z)
			if not (dansEmprise(x, z, rEmprise) and not surChemin(x, z, rSol) and libre(x, z, rSol)) then
				return false
			end
			local p = profondeur(x, z)
			if p < (profMin or 0) then
				return false
			end
			if p < LISIERE then
				return rng:NextNumber() < DENSITE_LISIERE
			end
			return true
		end, cellule)
	end

	-- ===== géométrie =====
	-- cylindre (axe X de la part) tendu entre deux points
	local function cylEntre(parent, a, b, d, recouvrement, props)
		local dir = b - a
		local long = dir.Magnitude
		if long < 0.05 then
			return nil
		end
		local haut = V3(0, 1, 0)
		if math.abs(dir.Unit.Y) > 0.9 then
			haut = V3(1, 0, 0)
		end
		props.Size = V3(long + recouvrement, d, d)
		props.CFrame = CFrame.lookAt(a:Lerp(b, 0.5), b, haut) * CFrame.Angles(0, math.rad(90), 0)
		return cylindre(parent, props)
	end
	-- bloc fin tendu entre deux points (lianes)
	local function segment(parent, a, b, epaisseur, couleur, nom)
		local d = b - a
		local long = d.Magnitude
		if long < 0.05 then
			return nil
		end
		local haut = V3(0, 1, 0)
		if math.abs(d.Unit.Y) > 0.9 then
			haut = V3(1, 0, 0)
		end
		return bloc(parent, {
			Name = nom or "Liane",
			Size = V3(epaisseur, epaisseur, long + epaisseur * 0.5),
			CFrame = CFrame.lookAt(a:Lerp(b, 0.5), b, haut),
			Color = couleur,
			Material = Mat.LeafyGrass,
			CanCollide = false,
		})
	end
	-- points d'un tronc qui s'incline de plus en plus (courbe douce)
	local function pointsTronc(base, hauteur, n, lean, psi)
		local points = { base }
		local p = base
		local L = hauteur / n
		for i = 1, n do
			local t = math.rad(lean) * (i / n) ^ 1.5
			local dir = V3(math.sin(t) * math.cos(psi), math.cos(t), math.sin(t) * math.sin(psi))
			p = p + dir * L
			table.insert(points, p)
		end
		return points
	end
	-- demi-feuille : coin couché en triangle, bord droit sur la nervure (x = 0), large à la base, pointe vers -Z de F
	local function demiFeuille(parent, F, L, w, epaisseur, cote, props)
		props.Size = V3(epaisseur, w, L)
		props.CFrame = F * CFrame.new(cote * w / 2, 0, -L / 2) * CFrame.Angles(0, 0, -cote * math.rad(90))
		return coin(parent, props)
	end

	-- ===== dossiers =====
	local dArbres = Outils.dossier(dossier, "Arbres")
	local dPalmiers = Outils.dossier(dossier, "Palmiers")
	local dLianes = Outils.dossier(dossier, "Lianes")
	local dBananiers = Outils.dossier(dossier, "Bananiers")
	local dFougeres = Outils.dossier(dossier, "Fougeres")
	local dBuissons = Outils.dossier(dossier, "Buissons")
	local dChampignons = Outils.dossier(dossier, "Champignons")
	local dTroncs = Outils.dossier(dossier, "TroncsCouches")
	local dTouffes = Outils.dossier(dossier, "Touffes")
	local dLucioles = Outils.dossier(dossier, "Lucioles")

	-- ===== 1. sol de jungle en terrain : herbe touffue, lisière herbeuse irrégulière, sentiers de terre =====
	local zSolMax = reglage(ctx, "zSolMax")
	local function soustraire(r, q)
		if q.x1 <= r.x0 or q.x0 >= r.x1 or q.z1 <= r.z0 or q.z0 >= r.z1 then
			return { r }
		end
		local res = {}
		if q.x0 > r.x0 then table.insert(res, { x0 = r.x0, x1 = q.x0, z0 = r.z0, z1 = r.z1 }) end
		if q.x1 < r.x1 then table.insert(res, { x0 = q.x1, x1 = r.x1, z0 = r.z0, z1 = r.z1 }) end
		local xa, xb = math.max(r.x0, q.x0), math.min(r.x1, q.x1)
		if q.z0 > r.z0 then table.insert(res, { x0 = xa, x1 = xb, z0 = r.z0, z1 = q.z0 }) end
		if q.z1 < r.z1 then table.insert(res, { x0 = xa, x1 = xb, z0 = q.z1, z1 = r.z1 }) end
		return res
	end
	-- rectangles peignables : dans la zone, avant la plage, hors coffre et hors carré du Volcan
	local exclus = {}
	for _, q in ipairs(interdits) do
		table.insert(exclus, q)
	end
	if volcanCentre then
		table.insert(exclus, { x0 = volcanCentre.X - volcanRayon, x1 = volcanCentre.X + volcanRayon, z0 = volcanCentre.Z - volcanRayon, z1 = volcanCentre.Z + volcanRayon })
	end
	local function morceaux(r)
		local liste = { r }
		for _, q in ipairs(exclus) do
			local suivants = {}
			for _, m in ipairs(liste) do
				for _, s in ipairs(soustraire(m, q)) do
					if s.x1 - s.x0 > 0.5 and s.z1 - s.z0 > 0.5 then
						table.insert(suivants, s)
					end
				end
			end
			liste = suivants
		end
		return liste
	end
	local function plaque(r, materiau, dessus)
		local h = 4 + dessus
		for _, m in ipairs(morceaux(r)) do
			local z1 = math.min(m.z1, zSolMax)
			if z1 - m.z0 > 0.5 then
				Outils.terrainBloc(CFrame.new((m.x0 + m.x1) / 2, dessus - h / 2, (m.z0 + z1) / 2), V3(m.x1 - m.x0, h, z1 - m.z0), materiau)
			end
		end
	end
	if terrainOk then
		for _, q in ipairs(zones) do
			plaque(q, Mat.LeafyGrass, 0.02)
		end
		-- lisière : bande d'herbe rase, bord mordu par des disques irréguliers
		for _, c in ipairs(cotes) do
			local n0, n1 = c.v, c.v + c.sens * 2
			local r = nil
			if c.axe == "X" then
				r = { x0 = math.min(n0, n1), x1 = math.max(n0, n1), z0 = c.a0, z1 = c.a1 }
			else
				r = { x0 = c.a0, x1 = c.a1, z0 = math.min(n0, n1), z1 = math.max(n0, n1) }
			end
			plaque(r, Mat.Grass, 0.02)
			local a = c.a0 + hasard(2, 6)
			while a < c.a1 - 3 do
				local rayon = hasard(2.5, 4.5)
				local n = c.v + c.sens * hasard(1.5, 3.5)
				local x, z = n, a
				if c.axe == "Z" then
					x, z = a, n
				end
				if z < zSolMax - rayon and dansEmprise(x, z, 0.5) then
					Outils.terrainCylindre(CFrame.new(x, -1.98, z), 4, rayon, Mat.Grass)
				end
				a = a + hasard(6, 11)
			end
		end
		-- sentiers de terre battue
		for _, ch in ipairs(chemins) do
			plaque({ x0 = ch.x0 + 0.5, x1 = ch.x1 - 0.5, z0 = ch.z0 + 0.5, z1 = ch.z1 - 0.5 }, Mat.Ground, 0.04)
		end
		-- talus d'herbe touffue au fond (côté falaises) : la jungle monte en gradins vers l'extérieur
		for _, q in ipairs(zones) do
			local fonds = {}
			if q.x1 <= 0 then table.insert(fonds, { axe = "X", v = q.x0, sens = 1, a0 = q.z0, a1 = q.z1 }) end
			if q.x0 >= 0 then table.insert(fonds, { axe = "X", v = q.x1, sens = -1, a0 = q.z0, a1 = q.z1 }) end
			if q.z1 <= 0 then table.insert(fonds, { axe = "Z", v = q.z0, sens = 1, a0 = q.x0, a1 = q.x1 }) end
			if q.z0 >= 0 then table.insert(fonds, { axe = "Z", v = q.z1, sens = -1, a0 = q.x0, a1 = q.x1 }) end
			for _, f in ipairs(fonds) do
				local a = f.a0 + hasard(3, 6)
				while a < f.a1 - 3 do
					local r = hasard(5.5, 8)
					local n = f.v + f.sens * (r + 0.05)
					local x, z = n, a
					if f.axe == "Z" then
						x, z = a, n
					end
					local y = -r + hasard(2.2, 4.4)
					if z + r < zSolMax and dansEmprise(x, z, r) and not surChemin(x, z, r) then
						Outils.terrainBoule(V3(x, y, z), r, Mat.LeafyGrass)
						table.insert(buttes, { x = x, y = y, z = z, r = r })
					end
					a = a + hasard(5, 8)
				end
			end
		end
	end

	-- ===== 2. lucioles : nuées jaunes très discrètes le long de la lisière =====
	local PAS = reglage(ctx, "pasLucioles")
	for _, c in ipairs(cotes) do
		local longueur = c.a1 - c.a0
		local nb = math.max(1, math.floor(longueur / PAS))
		local pas = longueur / nb
		for k = 1, nb do
			local a = c.a0 + (k - 0.5) * pas
			local n = c.v + c.sens * 3
			local x, z = n, a
			if c.axe == "Z" then
				x, z = a, n
			end
			if dansEmprise(x, z, 2.5) then
				local long = math.max(4, math.min(24, pas - 4))
				local taille = V3(4, 5, long)
				if c.axe == "Z" then
					taille = V3(long, 5, 4)
				end
				local zone = bloc(dLucioles, {
					Name = "Lucioles" .. k,
					Size = taille,
					CFrame = CFrame.new(x, 3.5, z),
					Transparency = 1,
					CanCollide = false,
					CanQuery = false,
					CanTouch = false,
					CastShadow = false,
				})
				if zone then
					pcall(function()
						local p = Instance.new("ParticleEmitter")
						p.Name = "Lucioles"
						p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
						p.Color = ColorSequence.new(LUCIOLE)
						p.LightEmission = 1
						p.LightInfluence = 0
						p.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.2, 0.2),
							NumberSequenceKeypoint.new(0.8, 0.2),
							NumberSequenceKeypoint.new(1, 0),
						})
						p.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.3, 0.25),
							NumberSequenceKeypoint.new(0.7, 0.4),
							NumberSequenceKeypoint.new(1, 1),
						})
						p.Lifetime = NumberRange.new(4, 7)
						p.Rate = 1.2
						p.Speed = NumberRange.new(0.2, 0.6)
						p.SpreadAngle = Vector2.new(180, 180)
						p.Acceleration = V3(0, 0.12, 0)
						p.Drag = 0.6
						p.Parent = zone
					end)
				end
			end
		end
	end

	-- ===== 3. gros arbres à canopée =====
	local COUT_ARBRE = 16
	local R_CANOPEE = 7
	local function arbre(numero, cellule)
		if reste() < COUT_ARBRE then
			return false
		end
		local H = hasard(11, 14.5)
		local dT = hasard(2.3, 3)
		local lean = hasard(4, 11)
		local pts = nil
		local y0 = 0
		local x, z = chercher(function(px, pz)
			if not (dansEmprise(px, pz, 3) and not surChemin(px, pz, 3.2) and libre(px, pz, 3.4)) then
				return false
			end
			if profondeur(px, pz) < 7 then
				return false
			end
			local h = hauteurSol(px, pz)
			local essai = pointsTronc(V3(px, h - 0.8, pz), H + 0.8, 3, lean, hasard(0, DEUX_PI))
			local top = essai[#essai]
			if dansEmprise(top.X, top.Z, R_CANOPEE * 0.95) and cimeLibre(top.X, top.Z, R_CANOPEE) then
				pts = essai
				y0 = h
				return true
			end
			return false
		end, cellule)
		if not x then
			return false
		end
		occuper(x, z, 3.4)
		local T = pts[#pts]
		table.insert(cimes, { x = T.X, z = T.Z, r = R_CANOPEE })
		local m = Outils.modele(dArbres, "Arbre" .. numero)
		if terrainOk and y0 < 0.5 then
			-- petite butte d'herbe touffue au pied
			Outils.terrainBoule(V3(x, -2.8, z), 3.8, Mat.LeafyGrass)
			y0 = 0.6
		end
		-- racines contreforts : coins hauts contre le tronc, pente vers l'extérieur
		local dec = hasard(0, DEUX_PI)
		for k = 1, 3 do
			local yaw = dec + (k - 1) * (DEUX_PI / 3) + hasard(-0.3, 0.3)
			local hR = hasard(2.2, 3.4)
			local lR = hasard(2.6, 3.6)
			coin(m, {
				Name = "Racine" .. k,
				Size = V3(0.9, hR, lR),
				CFrame = CFrame.new(x, y0 + hR / 2 - 0.5, z) * CFrame.Angles(0, yaw, 0) * CFrame.new(0, 0, -(dT / 2 + lR / 2 - 0.6)),
				Color = ECORCE,
				Material = Mat.Wood,
			})
		end
		-- tronc en trois segments cylindriques, légèrement courbé
		for i = 1, #pts - 1 do
			local couleur = ECORCE
			if i % 2 == 0 then
				couleur = ECORCE_CLAIRE
			end
			cylEntre(m, pts[i], pts[i + 1], dT - (i - 1) * 0.3, 0.5, { Name = "Tronc" .. i, Color = couleur, Material = Mat.Wood })
		end
		-- canopée : grosse boule centrale, quatre lobes plus bas et plus sombres, un sommet éclairé
		local base = choisir(FEUILLAGES)
		local centre = T + V3(0, 2.2, 0)
		boule(m, { Name = "Canopee", Size = V3(10, 10, 10), CFrame = CFrame.new(centre), Color = base, Material = Mat.Grass, CanCollide = false })
		local lobes = {}
		local decL = hasard(0, DEUX_PI)
		for k = 1, 4 do
			local a = decL + (k - 1) * (DEUX_PI / 4) + hasard(-0.35, 0.35)
			local s = hasard(5.8, 6.8)
			local r = R_CANOPEE - s / 2
			local pos = centre + V3(math.cos(a) * r, hasard(-2.4, -0.8), math.sin(a) * r)
			local couleur = ombre(base)
			if k % 2 == 0 then
				couleur = base:Lerp(ombre(base), 0.5)
			end
			boule(m, { Name = "Lobe" .. k, Size = V3(s, s, s), CFrame = CFrame.new(pos), Color = couleur, Material = Mat.LeafyGrass, CanCollide = false })
			table.insert(lobes, { pos = pos, s = s })
			if k == 1 then
				cylEntre(m, T - V3(0, 2.2, 0), pos, 0.8, 0.3, { Name = "Branche" .. k, Color = ECORCE_CLAIRE, Material = Mat.Wood, CanCollide = false })
			end
		end
		boule(m, {
			Name = "Sommet",
			Size = V3(6.4, 6.4, 6.4),
			CFrame = CFrame.new(centre + V3(hasard(-1, 1), 3.6, hasard(-1, 1))),
			Color = lumiere(base),
			Material = Mat.Grass,
			CanCollide = false,
		})
		-- une liane qui pend d'un lobe, terminée par une feuille
		local lobe = lobes[rng:NextInteger(1, #lobes)]
		if lobe and rng:NextNumber() < 0.6 then
			local haut = lobe.pos - V3(0, lobe.s / 2 - 0.6, 0)
			local basY = y0 + hasard(3.5, 5.5)
			if haut.Y - basY > 2.5 then
				local milieu = V3(haut.X + hasard(-0.5, 0.5), (haut.Y + basY) / 2, haut.Z + hasard(-0.5, 0.5))
				local bas = V3(haut.X + hasard(-0.4, 0.4), basY, haut.Z + hasard(-0.4, 0.4))
				segment(m, haut, milieu, 0.35, LIANE, "Liane1")
				segment(m, milieu, bas, 0.35, LIANE, "Liane2")
				boule(m, { Name = "FeuilleLiane", Size = V3(1.1, 1.1, 1.1), CFrame = CFrame.new(bas), Color = PALME, Material = Mat.LeafyGrass, CanCollide = false, CastShadow = false })
			end
		end
		return true
	end

	-- ===== 4. palmiers =====
	-- pied 1 + tronc 6 + coeur 1 + noix 2 + palmes (7 ou 8) × 3 segments × 2 demi-feuilles + palme sèche 4 (~54 en moyenne)
	local COUT_PALMIER = 10 + 8 * 6 + 4
	local couronnes = {}
	local function palmier(numero, cellule)
		if reste() < COUT_PALMIER then
			return false
		end
		local hauteur = hasard(15, 24)
		local n = 6
		local lean = hasard(10, 26)
		local longPalme = hasard(7.5, 9.5)
		local rCouronne = longPalme * 0.75
		local pts = nil
		local y0 = 0
		local x, z = chercher(function(px, pz)
			if not (dansEmprise(px, pz, 2) and not surChemin(px, pz, 2.4) and libre(px, pz, 2.6)) then
				return false
			end
			if profondeur(px, pz) < 5 then
				return false
			end
			local h = hauteurSol(px, pz)
			local essai = pointsTronc(V3(px, h - 0.6, pz), hauteur, n, lean, hasard(0, DEUX_PI))
			local top = essai[#essai]
			if dansEmprise(top.X, top.Z, rCouronne) and cimeLibre(top.X, top.Z, rCouronne) then
				pts = essai
				y0 = h
				return true
			end
			return false
		end, cellule)
		if not x then
			return false
		end
		occuper(x, z, 2.6)
		local sommet = pts[#pts]
		table.insert(cimes, { x = sommet.X, z = sommet.Z, r = rCouronne })
		local m = Outils.modele(dPalmiers, "Palmier" .. numero)
		-- pied évasé
		local d0 = hasard(1.7, 2)
		cylindre(m, {
			Name = "Pied",
			Size = V3(1.4, d0 * 1.45, d0 * 1.45),
			CFrame = CFrame.new(x, y0 + 0.1, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = TRONC_PIED,
			Material = Mat.Wood,
		})
		-- tronc : segments cylindriques Wood de plus en plus fins, anneaux clair/foncé
		for i = 1, n do
			local couleur = TRONC
			if i % 2 == 0 then
				couleur = TRONC_CLAIR
			end
			cylEntre(m, pts[i], pts[i + 1], d0 - (i - 1) * 0.12, 0.45, { Name = "Tronc" .. i, Color = couleur, Material = Mat.Wood })
		end
		-- coeur et noix de coco
		boule(m, { Name = "Coeur", Size = V3(2.3, 2.3, 2.3), CFrame = CFrame.new(sommet + V3(0, 0.3, 0)), Color = COEUR, Material = Mat.LeafyGrass, CanCollide = false })
		local aN = hasard(0, DEUX_PI)
		for k = 1, 2 do
			local a = aN + (k - 1) * 2.3
			boule(m, {
				Name = "Noix" .. k,
				Size = V3(1.15, 1.15, 1.15),
				CFrame = CFrame.new(sommet + V3(math.cos(a) * 0.95, -0.9, math.sin(a) * 0.95)),
				Color = NOIX,
				Material = Mat.Wood,
				CanCollide = false,
			})
		end
		-- palmes : chaque palme est un arc de trois segments enchaînés (0,4 / 0,35 / 0,25 de sa longueur) qui
		-- retombe de 18° à chaque articulation et s'effile (1,4 -> 1,1 -> 0,6) ; chaque segment garde le pli en V
		-- (deux demi-feuilles de part et d'autre de la nervure). Les triangles enchaînés dessinent des folioles.
		-- Deux couronnes décalées de 20° : en bas les palmes longues et sombres qui retombent, en haut les
		-- palmes plus courtes et plus claires, relevées puis courbées.
		local palmes = Outils.modele(m, "Palmes")
		local decalage = hasard(0, DEUX_PI)
		local pli = math.rad(16)
		local SEGMENTS = { { 0.4, 1.4 }, { 0.35, 1.1 }, { 0.25, 0.6 } }
		local COURBURE = math.rad(18)
		local function palme(nom, F, long, echelle, couleur, matiere, nbSeg, courbure)
			for s = 1, nbSeg do
				local L = long * SEGMENTS[s][1]
				local w = SEGMENTS[s][2] * echelle
				local teinte = couleur
				if s == nbSeg then
					teinte = couleur:Lerp(lumiere(couleur), 0.3) -- pointes éclaircies : la lumière accroche le bout des palmes
				end
				demiFeuille(palmes, F * CFrame.Angles(0, 0, -pli), L, w, 0.2, 1, { Name = nom .. "S" .. s .. "D", Color = ombre(teinte):Lerp(teinte, 0.55), Material = matiere, CanCollide = false })
				demiFeuille(palmes, F * CFrame.Angles(0, 0, pli), L, w, 0.2, -1, { Name = nom .. "S" .. s .. "G", Color = teinte, Material = matiere, CanCollide = false })
				-- articulation : le segment suivant part un peu avant la pointe (pas de jour) et retombe
				F = F * CFrame.new(0, 0, -L * 0.93) * CFrame.Angles(-courbure, 0, 0)
			end
		end
		local couronnesPalmes = {
			-- { nombre, décalage, hauteur, inclinaison mini/maxi, longueur mini/maxi, couleur, matière }
			{ 4, 0, 0.2, -26, -10, 0.92, 1.05, PALME_SOMBRE, Mat.LeafyGrass, "Palme" },
			{ (rng:NextNumber() < 0.3) and 4 or 3, math.rad(20), 0.65, 2, 16, 0.72, 0.85, PALME, Mat.Grass, "PalmeHaut" },
		}
		for _, c in ipairs(couronnesPalmes) do
			local nb = c[1]
			for k = 1, nb do
				local yaw = decalage + c[2] + (k - 1) * (DEUX_PI / nb) + hasard(-0.14, 0.14)
				local pitch = math.rad(hasard(c[4], c[5]))
				local long = longPalme * hasard(c[6], c[7])
				local F = CFrame.new(sommet + V3(0, c[3], 0)) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, -0.3)
				palme(c[10] .. k, F, long, hasard(0.9, 1.08), c[8], c[9], 3, COURBURE * hasard(0.85, 1.15))
			end
		end
		-- une vieille palme sèche qui pend (une fois sur trois) : deux segments très retombants
		if rng:NextNumber() < 0.35 then
			local F = CFrame.new(sommet + V3(0, -0.2, 0)) * CFrame.Angles(0, hasard(0, DEUX_PI), 0) * CFrame.Angles(-math.rad(hasard(50, 60)), 0, 0) * CFrame.new(0, 0, -0.6)
			palme("PalmeSeche", F, longPalme * 0.9, 0.85, PALME_SECHE, Mat.Grass, 2, math.rad(22))
		end
		table.insert(couronnes, { pos = sommet, rayon = longPalme })
		return true
	end

	-- ===== 5. les grands végétaux, cellule par cellule (ordre mélangé : le budget se répartit partout) =====
	local cellules = {}
	for _, q in ipairs(zones) do
		local taille = reglage(ctx, "celluleCotes")
		if q.nom == "jungleNord" then
			taille = reglage(ctx, "celluleNord")
		end
		local nx = math.max(1, math.floor((q.x1 - q.x0) / taille + 0.5))
		local nz = math.max(1, math.floor((q.z1 - q.z0) / taille + 0.5))
		local lx, lz = (q.x1 - q.x0) / nx, (q.z1 - q.z0) / nz
		for i = 0, nx - 1 do
			for j = 0, nz - 1 do
				table.insert(cellules, { x0 = q.x0 + i * lx, x1 = q.x0 + (i + 1) * lx, z0 = q.z0 + j * lz, z1 = q.z0 + (j + 1) * lz })
			end
		end
	end
	for i = #cellules, 2, -1 do
		local j = rng:NextInteger(1, i)
		cellules[i], cellules[j] = cellules[j], cellules[i]
	end
	local PART_ARBRES = reglage(ctx, "partArbres")
	local PART_VIDES = reglage(ctx, "partVides")
	local nbArbres, nbPalmiers = 0, 0
	local cellulesLibres = {}
	local PALMIERS_MAX = reglage(ctx, "palmiers")
	local RESERVE_BASSE = reglage(ctx, "reserveBasse")
	for _, c in ipairs(cellules) do
		local t = rng:NextNumber()
		local fait = false
		if reste() < RESERVE_BASSE then
			-- le reste du budget va aux plantes basses : les cellules restantes deviennent des clairières
			table.insert(cellulesLibres, c)
			fait = true
		elseif t < PART_VIDES then
			table.insert(cellulesLibres, c)
			fait = true
		elseif t < PART_VIDES + PART_ARBRES then
			fait = arbre(nbArbres + 1, c)
			if fait then
				nbArbres = nbArbres + 1
			end
		end
		if not fait then
			if nbPalmiers < PALMIERS_MAX and palmier(nbPalmiers + 1, c) then
				nbPalmiers = nbPalmiers + 1
			elseif arbre(nbArbres + 1, c) then
				nbArbres = nbArbres + 1
			end
		end
	end

	-- ===== 5. rochers en terrain (Rock, Slate), coiffés de mousse =====
	-- d'abord dans les cellules laissées libres par les grands végétaux, puis n'importe où
	if terrainOk then
		for i = 1, reglage(ctx, "rochers") do
			local r = hasard(1.8, 3.6)
			local x, z = placeBasse(r * 0.9, r + 1, 2.5, cellulesLibres[i])
			if x then
				occuper(x, z, r * 0.9)
				local principal = Mat.Rock
				local second = Mat.Slate
				if rng:NextNumber() < 0.35 then
					principal, second = Mat.Slate, Mat.Rock
				end
				local centre = V3(x, hauteurSol(x, z) + r * 0.2, z)
				Outils.terrainBoule(centre, r, principal)
				local a = hasard(0, DEUX_PI)
				local r2 = r * hasard(0.5, 0.7)
				Outils.terrainBoule(V3(x + math.cos(a) * r * 0.85, centre.Y - r * 0.2 + r2 * 0.1, z + math.sin(a) * r * 0.85), r2, second)
				-- mousse sur le dessus
				Outils.terrainBoule(centre + V3(hasard(-0.3, 0.3), r * 0.5, hasard(-0.3, 0.3)), r * 0.65, Mat.LeafyGrass)
			end
		end
	end

	-- ===== 6. bananiers =====
	local COUT_BANANIER = 9
	local function bananier(numero, cellule)
		if reste() < COUT_BANANIER then
			return false
		end
		local hauteur = hasard(5.5, 8)
		local longFeuille = hasard(5, 6.5)
		local x, z = placeBasse(2.6, longFeuille * 0.8, 4, cellule)
		if not x then
			return false
		end
		occuper(x, z, 2.6)
		local y0 = hauteurSol(x, z)
		local m = Outils.modele(dBananiers, "Bananier" .. numero)
		local d = hasard(1.1, 1.4)
		cylindre(m, {
			Name = "Tige",
			Size = V3(hauteur + 0.5, d, d),
			CFrame = CFrame.new(x, y0 + (hauteur - 0.5) / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = BANANIER_TIGE,
			Material = Mat.Grass,
		})
		local sommet = V3(x, y0 + hauteur, z)
		local decalage = hasard(0, DEUX_PI)
		for k = 1, 5 do
			local yaw = decalage + (k - 1) * (DEUX_PI / 5) + hasard(-0.2, 0.2)
			local pitch = math.rad(hasard(-18, 30))
			local couleur = choisir(BANANIER_FEUILLES)
			bloc(m, {
				Name = "Feuille" .. k,
				Size = V3(hasard(2.5, 3.1), 0.2, longFeuille),
				CFrame = CFrame.new(sommet) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, math.rad(hasard(-12, 12))) * CFrame.new(0, 0, -longFeuille / 2),
				Color = couleur,
				Material = Mat.LeafyGrass,
				CanCollide = false,
			})
		end
		-- régime de bananes et bourgeon violet
		local a = hasard(0, DEUX_PI)
		local regime = sommet + V3(math.cos(a) * 1.1, -1.5, math.sin(a) * 1.1)
		cylindre(m, {
			Name = "Bananes",
			Size = V3(1.8, 1.2, 1.2),
			CFrame = CFrame.new(regime) * CFrame.Angles(0, 0, math.rad(90)),
			Color = BANANES,
			CanCollide = false,
		})
		cylindre(m, {
			Name = "BananesHaut",
			Size = V3(0.8, 0.9, 0.9),
			CFrame = CFrame.new(regime + V3(0, 1.2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = lumiere(BANANES),
			CanCollide = false,
		})
		boule(m, {
			Name = "Bourgeon",
			Size = V3(1.1, 1.1, 1.1),
			CFrame = CFrame.new(regime - V3(0, 1.3, 0)),
			Color = BOURGEON,
			CanCollide = false,
		})
		return true
	end
	for i = 1, reglage(ctx, "bananiers") do
		bananier(i, cellulesLibres[i])
	end

	-- ===== 7. fougères =====
	local COUT_FOUGERE = 6
	local function fougere(numero)
		if reste() < COUT_FOUGERE then
			return false
		end
		local long = hasard(4.2, 6)
		local x, z = placeBasse(2, long * 0.65, 1.5)
		if not x then
			return false
		end
		occuper(x, z, 2)
		local m = Outils.modele(dFougeres, "Fougere" .. numero)
		local decalage = hasard(0, DEUX_PI)
		local base = V3(x, hauteurSol(x, z) + 0.15, z)
		for k = 1, 6 do
			local yaw = decalage + (k - 1) * (DEUX_PI / 6) + hasard(-0.18, 0.18)
			local pitch = math.rad(hasard(30, 55))
			local l = long * hasard(0.8, 1.05)
			local couleur = FOUGERE
			if k % 2 == 0 then
				couleur = FOUGERE_CLAIRE
			end
			local cote = 1
			if k % 2 == 0 then
				cote = -1
			end
			local F = CFrame.new(base) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
			demiFeuille(m, F, l, hasard(1.2, 1.6), 0.18, cote, { Name = "Fronde" .. k, Color = couleur, Material = Mat.LeafyGrass, CanCollide = false })
		end
		return true
	end
	for i = 1, reglage(ctx, "fougeres") do
		fougere(i)
	end

	-- une fleur tropicale : corolle plate orientée selon `dir` et pistil jaune
	local function fleur(parent, pos, dir, taille, couleur, nom)
		cylindre(parent, {
			Name = nom,
			Size = V3(0.3, taille, taille),
			CFrame = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, math.rad(90), 0),
			Color = couleur,
			CanCollide = false,
			CastShadow = false,
		})
		boule(parent, {
			Name = nom .. "Pistil",
			Size = V3(0.5, 0.5, 0.5),
			CFrame = CFrame.new(pos + dir * 0.2),
			Color = PISTIL,
			CanCollide = false,
			CastShadow = false,
		})
	end

	-- ===== 8. buissons à fleurs tropicales =====
	local COUT_BUISSON = 9
	local function buisson(numero)
		if reste() < COUT_BUISSON then
			return false
		end
		local x, z = placeBasse(2.4, 3.6, 1)
		if not x then
			return false
		end
		occuper(x, z, 2.4)
		local y0 = hauteurSol(x, z)
		local m = Outils.modele(dBuissons, "Buisson" .. numero)
		local boules = {}
		local nb = rng:NextInteger(2, 3)
		local teinte = choisir(FEUILLAGES)
		for k = 1, nb do
			local s = hasard(2.8, 4)
			local a = hasard(0, DEUX_PI)
			local r = 0
			if k > 1 then
				r = hasard(0.9, 1.4)
			end
			local centre = V3(x + math.cos(a) * r, y0 + s * 0.38, z + math.sin(a) * r)
			local couleur = teinte
			if k == 2 then
				couleur = ombre(teinte)
			elseif k == 3 then
				couleur = lumiere(teinte)
			end
			boule(m, { Name = "Feuillage" .. k, Size = V3(s, s, s), CFrame = CFrame.new(centre), Color = couleur, Material = Mat.LeafyGrass, CanCollide = false })
			table.insert(boules, { centre = centre, s = s })
		end
		local couleurFleur = choisir(FLEURS)
		for k = 1, 3 do
			local b = boules[rng:NextInteger(1, #boules)]
			local a = hasard(0, DEUX_PI)
			local el = hasard(0.3, 1.1)
			local dir = V3(math.cos(a) * math.cos(el), math.sin(el), math.sin(a) * math.cos(el))
			fleur(m, b.centre + dir * (b.s / 2), dir, hasard(1.2, 1.6), couleurFleur, "Fleur" .. k)
		end
		return true
	end
	for i = 1, reglage(ctx, "buissons") do
		buisson(i)
	end

	-- ===== 9. champignons (groupes de 1 à 3) =====
	local function unChampignon(parent, x, z, hs, dc, couleur, numero)
		local y0 = hauteurSol(x, z)
		local ds = math.max(0.5, dc * 0.22)
		cylindre(parent, {
			Name = "Pied" .. numero,
			Size = V3(hs + 0.4, ds, ds),
			CFrame = CFrame.new(x, y0 + (hs - 0.4) / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = CREME,
			CanCollide = false,
		})
		cylindre(parent, {
			Name = "Chapeau" .. numero,
			Size = V3(0.6, dc, dc),
			CFrame = CFrame.new(x, y0 + hs + 0.3, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = ombre(couleur),
			CanCollide = false,
		})
		local dDome = dc * 0.72
		local centre = V3(x, y0 + hs + 0.6, z)
		local dome = boule(parent, { Name = "Dome" .. numero, Size = V3(dDome, dDome, dDome), CFrame = CFrame.new(centre), Color = couleur, CanCollide = false })
		local lumineux = couleur == CHAPEAU_LUMINEUX
		local couleurPois, matiere = CREME, Mat.SmoothPlastic
		if lumineux then
			couleurPois, matiere = Charte.gemme, Mat.Neon
		end
		local nbPois = 1
		if dc > 3.5 then
			nbPois = 2
		end
		for k = 1, nbPois do
			local a = hasard(0, DEUX_PI)
			local el = hasard(0.7, 1.2)
			local dir = V3(math.cos(a) * math.cos(el), math.sin(el), math.sin(a) * math.cos(el))
			local sp = dc * 0.2
			boule(parent, {
				Name = "Pois" .. numero .. "_" .. k,
				Size = V3(sp, sp, sp),
				CFrame = CFrame.new(centre + dir * (dDome / 2 - sp * 0.25)),
				Color = couleurPois,
				Material = matiere,
				CanCollide = false,
				CastShadow = false,
			})
		end
		if lumineux and dome then
			pcall(Outils.lumiere, dome, { Range = 9, Brightness = 0.7, Color = Charte.gemme })
		end
	end
	local function champignons(numero)
		if reste() < 15 then
			return false
		end
		local x, z = placeBasse(2.4, 3.2, 1.5)
		if not x then
			return false
		end
		occuper(x, z, 2.4)
		local m = Outils.modele(dChampignons, "Champignons" .. numero)
		local couleur = choisir(CHAPEAUX)
		local nb = rng:NextInteger(1, 3)
		local a0 = hasard(0, DEUX_PI)
		for k = 1, nb do
			local dc = hasard(3, 4.6)
			local hs = hasard(1.6, 3.2)
			local ox, oz = 0, 0
			if k > 1 then
				dc = dc * 0.55
				hs = hs * 0.55
				local a = a0 + k * 2.1
				ox, oz = math.cos(a) * 1.9, math.sin(a) * 1.9
			end
			unChampignon(m, x + ox, z + oz, hs, dc, couleur, k)
		end
		return true
	end
	for i = 1, reglage(ctx, "champignons") do
		champignons(i)
	end

	-- ===== 10. troncs couchés moussus =====
	local function troncCouche(numero)
		if reste() < 3 then
			return false
		end
		local L = hasard(7, 10)
		local d = hasard(1.6, 2.1)
		local x, z = placeBasse(L / 2, L / 2 + 0.5, 4)
		if not x or hauteurSol(x, z) > 0.2 then
			-- pas sur les talus : un tronc droit y flotterait
			return false
		end
		occuper(x, z, L / 2)
		local m = Outils.modele(dTroncs, "TroncCouche" .. numero)
		local yaw = hasard(0, DEUX_PI)
		local cf = CFrame.new(x, hauteurSol(x, z) + d / 2 - 0.35, z) * CFrame.Angles(0, yaw, 0)
		cylindre(m, { Name = "Tronc", Size = V3(L, d, d), CFrame = cf, Color = ECORCE, Material = Mat.Wood })
		cylindre(m, { Name = "Coupe", Size = V3(0.12, d - 0.3, d - 0.3), CFrame = cf * CFrame.new(L / 2 + 0.02, 0, 0), Color = TRONC_CLAIR, Material = Mat.Wood, CanCollide = false })
		bloc(m, { Name = "Mousse", Size = V3(L * 0.7, 0.3, d * 0.55), CFrame = cf * CFrame.new(-L * 0.08, d / 2 - 0.05, 0), Color = FOUGERE, Material = Mat.LeafyGrass, CanCollide = false })
		return true
	end
	for i = 1, reglage(ctx, "troncs") do
		troncCouche(i)
	end

	-- ===== 11. lianes tendues entre deux couronnes voisines =====
	local lies = {}
	local nbArcs = 0
	local ARCS_MAX = reglage(ctx, "lianesArc")
	for i, a in ipairs(couronnes) do
		if nbArcs >= ARCS_MAX or reste() < 4 then
			break
		end
		if not lies[i] then
			local meilleur, dMeilleur = nil, 1e9
			for j, b in ipairs(couronnes) do
				if j ~= i and not lies[j] then
					local d = Outils.distanceXZ(a.pos, b.pos)
					if d >= 8 and d <= 22 and d < dMeilleur then
						meilleur, dMeilleur = j, d
					end
				end
			end
			if meilleur then
				local b = couronnes[meilleur]
				local depart = a.pos - V3(0, 0.8, 0)
				local arrivee = b.pos - V3(0, 0.8, 0)
				local creux = hasard(2.5, 4.5)
				local points = {}
				local n = 4
				local valide = true
				for k = 0, n do
					local u = k / n
					local p = depart:Lerp(arrivee, u) - V3(0, creux * 4 * u * (1 - u), 0)
					if not dansEmprise(p.X, p.Z, 0.5) then
						valide = false
					end
					table.insert(points, p)
				end
				if valide then
					local m = Outils.modele(dLianes, "LianeArc" .. (nbArcs + 1))
					for k = 1, n do
						segment(m, points[k], points[k + 1], 0.4, LIANE, "Liane" .. k)
					end
					lies[i] = true
					lies[meilleur] = true
					nbArcs = nbArcs + 1
				end
			end
		end
	end

	-- ===== 12. touffes d'herbe en lisière, parfois fleuries =====
	local function touffe(numero)
		if reste() < 6 then
			return false
		end
		local x, z = chercher(function(px, pz)
			local p = profondeur(px, pz)
			return p >= 0.8 and p <= LISIERE + 3 and dansEmprise(px, pz, 1.2) and not surChemin(px, pz, 1.2) and libre(px, pz, 1.2)
		end)
		if not x then
			return false
		end
		occuper(x, z, 1.2)
		local m = Outils.modele(dTouffes, "Touffe" .. numero)
		local dec = hasard(0, DEUX_PI)
		for k = 1, 3 do
			local h = hasard(1.4, 2.3)
			local couleur = HERBE
			if k == 2 then
				couleur = FOUGERE_CLAIRE
			end
			coin(m, {
				Name = "Brin" .. k,
				Size = V3(0.35, h, 0.9),
				CFrame = CFrame.new(x, 0, z) * CFrame.Angles(0, dec + (k - 1) * 2.1, 0) * CFrame.Angles(math.rad(-12), 0, 0) * CFrame.new(0, h / 2 - 0.1, 0.3),
				Color = couleur,
				Material = Mat.Grass,
				CanCollide = false,
				CastShadow = false,
			})
		end
		if rng:NextNumber() < 0.5 then
			local h = hasard(1.6, 2.2)
			cylEntre(m, V3(x, 0, z), V3(x + 0.2, h, z), 0.18, 0, { Name = "Tige", Color = FOUGERE, Material = Mat.Grass, CanCollide = false, CastShadow = false })
			fleur(m, V3(x + 0.2, h, z), V3(0.25, 1, 0.1).Unit, 1.1, choisir(FLEURS), "Fleur")
		end
		return true
	end
	for i = 1, reglage(ctx, "touffes") do
		touffe(i)
	end

	dossier:SetAttribute("Parts", nbParts)
end

return M
