-- Constructeur Jungle (plan v2 « plus d'air », STYLE.md §4) : végétation dense dans Plan.decor.jungleOuest,
-- jungleEst et jungleNord, sans empiéter sur le Volcan (rayon + 6), le Cratère (rayon + 6), les Falaises, la
-- Rivière ni les abords du sentier du coffre. Toutes les positions viennent de Plan.lua.
-- Sol de jungle en terrain (LeafyGrass, sentiers de terre Ground qui serpentent, talus au fond, buttes sous les
-- gros arbres, rochers Rock/Slate coiffés de mousse), gros arbres à canopée en boules Grass (trois teintes,
-- racines contreforts, lianes) et arbres de fond plus simples, palmiers aux troncs Wood courbés et palmes en
-- arcs retombants, bananiers, fougères, buissons à fleurs tropicales, champignons (certains luisent),
-- troncs couchés moussus, touffes fleuries, lucioles et papillons discrets.
-- Densité : les grands végétaux remplissent d'abord la périphérie (côté falaises), la lisière tournée vers le
-- centre de jeu est soignée (bande d'herbe rase au bord mordu, bordure régulière de plantes basses et fleurs).
-- Sentiers : les allées entre les Bases se prolongent en sentes jusqu'à une clairière (ou jusqu'au pied du
-- Volcan), et UN sentier de terre (pas japonais sur la pelouse) prolonge le chemin de ronde des Bases jusqu'au
-- pied du sentier d'escalade des Falaises (coffre caché).
-- Bosquets (Plan.decor.bosquets) : sur les grandes pelouses, chaque îlot reçoit un petit bois (grand arbre au
-- centre, palmier, arbres moyens, buissons à fleurs, fougère, rochers moussus), sans toucher chemins ni Bases.
-- Animations (client, Interface/AnimationsDecor) : quelques couronnes de palmiers, feuilles de bananiers et
-- cimes d'arbres « flottent » doucement, les pois des champignons luisants « pulsent ».
local M = {}

-- réglages par défaut (surchargés par Equilibrage.jungle s'il existe)
local DEFAUTS = {
	budget = 2500,        -- parts au maximum pour ce constructeur (le terrain ne compte pas)
	graine = 7331,        -- graine fixe : la jungle est identique à chaque partie
	margeVolcan = 6,      -- distance gardée autour du Volcan
	margeCratere = 6,     -- distance gardée autour du Cratère
	gardeDisques = 2,     -- jeu en plus : l'objet ENTIER (canopée, palmes, racines...) reste à 2 studs de ces marges
	margeRiviere = 3,     -- distance gardée de part et d'autre de la bande de la Rivière
	margeFalaises = 1,    -- distance gardée devant les bandes de falaises
	celluleCotes = 12,    -- les grands végétaux sont répartis par cellules (densité régulière)
	celluleNord = 16,
	partVides = 0.08,     -- part des cellules laissées aux rochers et bananiers
	profondeurPalmiers = 16, -- les palmiers poussent plutôt près de la lisière (on les voit), les arbres au fond
	partPalmiers = 0.5,
	profondeurSimples = 17,  -- au-delà, un arbre sur deux est un arbre de fond simplifié (6 parts)
	partSimples = 0.55,
	palmiers = 8,         -- palmiers au plus (~54 parts chacun avec leurs palmes en arcs)
	reserveBasse = 820,   -- parts gardées pour la bordure de lisière et les plantes basses
	rochers = 20,
	bananiers = 10,
	fougeres = 12,
	buissons = 10,
	champignons = 10,     -- groupes de 1 à 3 champignons
	troncs = 5,           -- troncs couchés
	lianesArc = 6,        -- lianes tendues entre deux palmiers
	touffes = 6,          -- touffes d'herbe (parfois fleuries) en plus de la bordure
	essais = 90,          -- tirages au plus pour placer un élément
	essaisCellule = 30,
	largeurChemin = 7,    -- largeur des sentes
	largeurAllee = 10,    -- largeur du sentier qui mène au pied du Volcan
	profondeurSente = 34, -- longueur d'une sente avant sa clairière
	rayonClairiere = 7,
	lisiere = 5,          -- bande côté centre de jeu : seulement des plantes basses et clairsemées
	densiteLisiere = 0.35,
	pasBordure = 8.5,     -- espacement moyen des plantes de la bordure de lisière
	pasLucioles = 34,     -- espacement des nuées de lucioles le long de la lisière
	animes = 36,          -- feuillages animés au plus (client)
	pasPavage = 4,        -- pavage du sol de jungle autour du Volcan et du Cratère
	budgetBosquets = 370, -- parts en plus pour les bosquets des pelouses et les pas japonais du sentier du coffre
	pasJaponais = 4.5,    -- écart entre deux pas japonais sur le sentier du coffre
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
	local zones = {}
	for _, nom in ipairs({ "jungleOuest", "jungleEst", "jungleNord" }) do
		local z = Plan.decor[nom]
		if z and z.min and z.max then
			local x0 = math.min(z.min.X, z.max.X)
			local x1 = math.max(z.min.X, z.max.X)
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

	-- disques interdits : Volcan et Cratère (rayon + marge)
	local disques = {}
	local volcanCentre = nil
	local volcanRayon = 0
	if Plan.volcan and Plan.volcan.centre then
		volcanCentre = Plan.volcan.centre
		volcanRayon = (Plan.volcan.rayon or 36) + reglage(ctx, "margeVolcan")
		table.insert(disques, { x = volcanCentre.X, z = volcanCentre.Z, r = volcanRayon, nom = "Volcan" })
	end
	if Plan.cratere and Plan.cratere.centre then
		table.insert(disques, { x = Plan.cratere.centre.X, z = Plan.cratere.centre.Z, r = (Plan.cratere.rayon or 16) + reglage(ctx, "margeCratere"), nom = "Cratere" })
	end

	-- rectangles interdits : bandes de falaises, bande de la Rivière (et ses berges), abords du sentier du coffre
	local interdits = {}
	if type(Plan.falaises) == "table" then
		local m = reglage(ctx, "margeFalaises")
		for _, f in pairs(Plan.falaises) do
			if type(f) == "table" and f.xMin and f.xMax and f.zMin and f.zMax then
				table.insert(interdits, { x0 = f.xMin - m, x1 = f.xMax + m, z0 = f.zMin - m, z1 = f.zMax + m })
			end
		end
	end
	if type(Plan.riviere) == "table" and Plan.riviere.zMin and Plan.riviere.zMax then
		local m = reglage(ctx, "margeRiviere")
		local rx0 = Plan.riviere.xMin or Plan.monde.min.X
		local rx1 = Plan.riviere.xMax or Plan.monde.max.X
		table.insert(interdits, { x0 = rx0 - m, x1 = rx1 + m, z0 = Plan.riviere.zMin - m, z1 = Plan.riviere.zMax + m })
	end
	if Plan.coffre then
		-- la plateforme et l'anse du sentier sont dans la falaise : on laisse aussi ses abords dégagés
		local c = Plan.coffre
		local versCentre = 1
		if c.Z > 0 then
			versCentre = -1
		end
		local zA, zB = c.Z - versCentre * 12, c.Z + versCentre * 62
		table.insert(interdits, { x0 = c.X - 16, x1 = c.X + 16, z0 = math.min(zA, zB), z1 = math.max(zA, zB) })
	end

	-- le cercle (x, z, r) touche-t-il le rectangle ?
	local function cercleRect(x, z, r, q)
		local px = math.max(q.x0, math.min(x, q.x1))
		local pz = math.max(q.z0, math.min(z, q.z1))
		local dx, dz = x - px, z - pz
		return dx * dx + dz * dz < r * r
	end

	-- le cercle (x, z, r) évite-t-il le Volcan, le Cratère, les falaises, la rivière et le coffre ?
	local function horsExclusions(x, z, r)
		for _, d in ipairs(disques) do
			local dx, dz = x - d.x, z - d.z
			if dx * dx + dz * dz < (d.r + r) * (d.r + r) then
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

	-- l'objet entier (portée réelle autour de son point de pousse : canopée, palmes, racines, feuilles...) reste-t-il
	-- hors du disque du Volcan et du Cratère (rayon + marge), avec un jeu en plus ? Le point de pousse seul ne suffit
	-- pas : une canopée ou un tronc couché mordraient la marge et paraîtraient collés au pied du Volcan.
	local GARDE_DISQUES = reglage(ctx, "gardeDisques")
	local function loinDesDisques(x, z, portee)
		for _, d in ipairs(disques) do
			local dx, dz = x - d.x, z - d.z
			local mini = d.r + portee + GARDE_DISQUES
			if dx * dx + dz * dz < mini * mini then
				return false
			end
		end
		return true
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
		return horsExclusions(x, z, r)
	end

	-- ===== sentiers libres (segments ; rien ne pousse dessus, terre battue au sol) et clairières =====
	local chemins = {}   -- { ax, az, bx, bz, demi }
	local clairieres = {} -- { x, z, r }
	local function ajouterChemin(a, b, demiLargeur)
		table.insert(chemins, { ax = a.X, az = a.Z, bx = b.X, bz = b.Z, demi = demiLargeur })
	end
	local function distanceSegment(x, z, s)
		local vx, vz = s.bx - s.ax, s.bz - s.az
		local l2 = vx * vx + vz * vz
		local t = 0
		if l2 > 0 then
			t = math.max(0, math.min(1, ((x - s.ax) * vx + (z - s.az) * vz) / l2))
		end
		local dx, dz = x - (s.ax + vx * t), z - (s.az + vz * t)
		return math.sqrt(dx * dx + dz * dz)
	end
	local function surChemin(x, z, r)
		for _, s in ipairs(chemins) do
			if distanceSegment(x, z, s) < s.demi + r then
				return true
			end
		end
		for _, c in ipairs(clairieres) do
			local dx, dz = x - c.x, z - c.z
			if dx * dx + dz * dz < (c.r + r) * (c.r + r) then
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

	-- point d'un côté de lisière : a le long du côté, n à la profondeur p (négative = hors de la jungle)
	local function pointCote(c, a, p)
		local n = c.v + c.sens * p
		if c.axe == "Z" then
			return V3(a, 0, n)
		end
		return V3(n, 0, a)
	end

	-- 1) les allées entre les Bases (Plan.allees.x) se prolongent en sentes dans la jungle qui leur fait face ;
	--    celle qui bute sur le Volcan devient un large sentier jusqu'à son pied
	local demi = reglage(ctx, "largeurChemin") / 2
	local demiAllee = reglage(ctx, "largeurAllee") / 2
	local PROF_SENTE = reglage(ctx, "profondeurSente")
	local R_CLAIRIERE = reglage(ctx, "rayonClairiere")
	if type(Plan.allees) == "table" and type(Plan.allees.x) == "table" then
		for _, ax in ipairs(Plan.allees.x) do
			for _, c in ipairs(cotes) do
				if c.axe == "Z" and ax > c.a0 + demiAllee + 2 and ax < c.a1 - demiAllee - 2 then
					-- avance dans la jungle jusqu'à la profondeur voulue ou jusqu'au pied du Volcan
					local versVolcan = false
					local p = 0
					while p < PROF_SENTE do
						local q = pointCote(c, ax, p + 1)
						if not horsExclusions(q.X, q.Z, 0) then
							versVolcan = true
							break
						end
						p = p + 1
					end
					local depart = pointCote(c, ax, -1.5)
					if versVolcan then
						ajouterChemin(depart, pointCote(c, ax, p + 2), demiAllee)
					elseif p >= R_CLAIRIERE * 2 then
						-- sente qui ondule un peu, puis clairière
						local fin = pointCote(c, ax + hasard(-5, 5), p - R_CLAIRIERE)
						local milieu = pointCote(c, ax + hasard(-4, 4), p * 0.45)
						ajouterChemin(depart, milieu, demi)
						ajouterChemin(milieu, fin, demi)
						table.insert(clairieres, { x = fin.X, z = fin.Z, r = R_CLAIRIERE })
					end
				end
			end
		end
	end

	-- chemins de sable et bâtiments posés par Builders/Sol, recalculés depuis Plan avec les mêmes règles (réglages
	-- Equilibrage.sol, sinon les mêmes valeurs par défaut) : les bosquets et le sentier du coffre n'y touchent jamais
	-- (bloc à part : la fonction construire approche la limite de 200 variables locales)
	local surSol = nil
	local sentierCoffre = {} -- points du sentier du coffre (pour les pas japonais)
	do
	local function reglageSol(cle, defaut)
		local s = ctx.Equilibrage and ctx.Equilibrage.sol
		if type(s) == "table" and type(s[cle]) == "number" then
			return s[cle]
		end
		return defaut
	end
	local solZones = {}
	local function zRect(x0, x1, z0, z1)
		table.insert(solZones, { g = "rect", x0 = math.min(x0, x1), x1 = math.max(x0, x1), z0 = math.min(z0, z1), z1 = math.max(z0, z1) })
	end
	local function zDisque(x, z, r)
		table.insert(solZones, { g = "disque", x = x, z = z, r = r })
	end
	local function zRuban(ax, az, bx, bz, l)
		table.insert(solZones, { g = "ruban", ax = ax, az = az, bx = bx, bz = bz, demi = l })
	end
	local basePlan = Plan.base or { largeur = 44, profondeur = 50 }
	local promenade = Plan.promenade or { zMax = 27 }
	local demiBX, demiBZ = basePlan.largeur / 2, basePlan.profondeur / 2
	local xBasesMax, zBasesFond = 0, promenade.zMax + basePlan.profondeur
	for _, b in ipairs(Plan.bases or {}) do
		xBasesMax = math.max(xBasesMax, math.abs(b.centre.X) + demiBX)
		zBasesFond = math.max(zBasesFond, math.abs(b.centre.Z) + demiBZ)
		zRect(b.centre.X - demiBX - 1, b.centre.X + demiBX + 1, b.centre.Z - demiBZ - 1, b.centre.Z + demiBZ + 1)
	end
	local zRondeA = zBasesFond + reglageSol("ecartRonde", 3)
	local zRondeB = zRondeA + reglageSol("largeurRonde", 8)
	local xContreA = xBasesMax + reglageSol("ecartContre", 2)
	local xContreB = xContreA + reglageSol("largeurContre", 10)
	local dSentierSol = reglageSol("demiSentier", 3.5)
	do
		local zP = promenade.zMax
		local zSableB = reglageSol("promenadeSableMax", 23)
		local xBout = xContreB + zP
		if Plan.nurserie then xBout = math.abs(Plan.nurserie.centre.X) end
		if Plan.finTapis then xBout = math.max(xBout, math.abs(Plan.finTapis.centre.X)) end
		local margeJ = reglageSol("margeJungle", 2)
		if Plan.decor.jungleOuest then xBout = math.min(xBout, math.abs(Plan.decor.jungleOuest.max.X) - margeJ - zP) end
		if Plan.decor.jungleEst then xBout = math.min(xBout, math.abs(Plan.decor.jungleEst.min.X) - margeJ - zP) end
		zRect(-xBout, xBout, -zP, zP)
		zDisque(-xBout, 0, zSableB)
		zDisque(xBout, 0, zSableB)
		for _, n in ipairs({ Plan.nurserie, Plan.finTapis }) do
			if n and n.centre then zDisque(n.centre.X, n.centre.Z, n.rayon or 15) end
		end
		for _, s in ipairs({ -1, 1 }) do
			zRect(-xContreB, xContreB, s * zRondeA, s * zRondeB)
			zRect(s * xContreA, s * xContreB, -zRondeB, zRondeB)
			if type(Plan.allees) == "table" and type(Plan.allees.x) == "table" then
				local l = math.min((Plan.allees.largeur or 22) / 2, reglageSol("demiAllee", 6))
				for _, ax in ipairs(Plan.allees.x) do
					zRect(ax - l, ax + l, s * zSableB, s * zRondeB)
				end
			end
		end
		local zPlageA = nil
		if Plan.riviere then
			zPlageA = Plan.riviere.zMin - reglageSol("plage", 6)
			if Plan.decor.jungleOuest then zPlageA = math.min(zPlageA, Plan.decor.jungleOuest.max.Z) end
			local xJeuMin = (Plan.falaises and Plan.falaises.ouest and Plan.falaises.ouest.xMax) or Plan.monde.min.X
			local xJeuMax = (Plan.falaises and Plan.falaises.est and Plan.falaises.est.xMin) or Plan.monde.max.X
			zRect(xJeuMin, xJeuMax, zPlageA, Plan.riviere.zMax + 2)
			for _, s in ipairs({ -1, 1 }) do
				local ax, az = s * (xContreA + xContreB) / 2, (zRondeA + zRondeB) / 2
				local bx = s * math.min(xContreB + (zPlageA - az) * 0.35, xJeuMax - 30)
				zRuban(ax, az, bx, zPlageA + 1, dSentierSol)
			end
		end
		if Plan.decor.jungleNord and type(Plan.allees) == "table" and type(Plan.allees.x) == "table" then
			for _, ax in ipairs(Plan.allees.x) do
				zRuban(ax, -zRondeB, ax, Plan.decor.jungleNord.max.Z - 2, dSentierSol)
			end
		end
		local place = Plan.place
		if place then
			local rPlace = place.rayon + reglageSol("anneauPlace", 6)
			local dLien = reglageSol("demiLien", 6)
			local mBat = reglageSol("margeBatiment", 3)
			zDisque(place.centre.X, place.centre.Z, rPlace)
			zRect(place.centre.X - dLien, place.centre.X + dLien, zRondeB - 1, place.centre.Z)
			if Plan.comptoir then
				local co = Plan.comptoir
				zRect(co.centre.X - co.taille.X / 2 - mBat, place.centre.X, co.centre.Z - co.taille.Z / 2 - mBat, co.centre.Z + co.taille.Z / 2 + mBat)
			end
			if Plan.autel then
				zRect(place.centre.X, Plan.autel.centre.X, Plan.autel.centre.Z - dLien, Plan.autel.centre.Z + dLien)
				zDisque(Plan.autel.centre.X, Plan.autel.centre.Z, Plan.autel.rayon + mBat)
			end
			if zPlageA then
				local dR = reglageSol("demiRiviere", 5)
				zRect(place.centre.X - dR, place.centre.X + dR, place.centre.Z, zPlageA + 1)
			end
		end
		if Plan.cratere then
			local rC = Plan.cratere.rayon + reglageSol("anneauCratere", 6)
			zDisque(Plan.cratere.centre.X, Plan.cratere.centre.Z, rC)
			local dLien = reglageSol("demiLien", 6)
			zRect(Plan.cratere.centre.X - dLien, Plan.cratere.centre.X + dLien, Plan.cratere.centre.Z, -zRondeB)
			if Plan.volcan then
				zRuban(Plan.cratere.centre.X, Plan.cratere.centre.Z, Plan.volcan.centre.X, Plan.volcan.centre.Z, dSentierSol)
			end
		end
		if Plan.volcan then
			zDisque(Plan.volcan.centre.X, Plan.volcan.centre.Z, Plan.volcan.rayon + 6)
		end
	end
	-- le cercle (x, z, r) touche-t-il un chemin, une Base ou un bâtiment du Sol ?
	surSol = function(x, z, r)
		for _, q in ipairs(solZones) do
			if q.g == "rect" then
				if cercleRect(x, z, r, q) then
					return true
				end
			elseif q.g == "disque" then
				local dx, dz = x - q.x, z - q.z
				if dx * dx + dz * dz < (q.r + r) * (q.r + r) then
					return true
				end
			elseif distanceSegment(x, z, { ax = q.ax, az = q.az, bx = q.bx, bz = q.bz }) < q.demi + r then
				return true
			end
		end
		return false
	end

	-- 2) UN seul sentier de terre mène du bout du chemin de ronde (côté du coffre) au pied du sentier d'escalade des
	--    Falaises : il prolonge le chemin de ronde, ondule en S sur la pelouse, entre dans la jungle et finit tout
	--    droit dans l'anse de la falaise, au pied de la première marche. Le pied est recalculé comme dans
	--    Builders/Falaises (plateforme de 12, marches de 4,5, montée et écart d'Equilibrage.falaises).
	if Plan.coffre and Plan.bases and #Plan.bases > 0 then
		local c = Plan.coffre
		local SX, SENS, SZ = 1, 1, -1
		if c.X < 0 then SX = -1 end
		if c.Z > 0 then SENS, SZ = -1, 1 end
		local F = {}
		if ctx.Equilibrage and type(ctx.Equilibrage.falaises) == "table" then
			F = ctx.Equilibrage.falaises
		end
		local montee, ecart = 3, 2
		if type(F.montee) == "number" then montee = F.montee end
		if type(F.ecart) == "number" then ecart = F.ecart end
		montee = math.min(4, math.max(1, montee))
		ecart = math.min(6, math.max(1, ecart))
		local DEMI_PF, COTE = 6, 4.5
		local nb = math.ceil(c.Y / montee) - 1
		local xPied, zPied = c.X, c.Z + SENS * (DEMI_PF + 4)
		if nb >= 1 then
			local rang = nb - 1 -- la marche la plus basse
			local zM = c.Z + SENS * (DEMI_PF + ecart + COTE / 2 + rang * (COTE + ecart))
			xPied = c.X + SX * 0.5
			if rang % 2 == 1 then
				xPied = c.X + SX * 3
			end
			zPied = zM + SENS * (COTE / 2 + 2)
		end
		-- face de la falaise du côté du coffre (l'anse s'ouvre là)
		local xFace = xPied - SX * 12
		local bande = Plan.falaises and ((SX > 0 and Plan.falaises.est) or (SX < 0 and Plan.falaises.ouest))
		if bande then
			xFace = bande.xMin
			if SX < 0 then xFace = bande.xMax end
		end
		local P0 = V3(SX * (xContreB + demi * 0.75), 0, SZ * (zRondeA + zRondeB) / 2)
		local A = V3(xFace - SX * 12, 0, zPied)
		local B = V3(xPied - SX * 1, 0, zPied)
		local L = (A - P0).Magnitude
		local P1 = P0 + V3(SX * L * 0.35, 0, 0)
		local P2 = A - V3(SX * L * 0.35, 0, 0)
		local n = 12
		local precedent = P0
		table.insert(sentierCoffre, P0)
		for k = 1, n do
			local u = k / n
			local v = 1 - u
			local p = P0 * (v * v * v) + P1 * (3 * v * v * u) + P2 * (3 * v * u * u) + A * (u * u * u)
			ajouterChemin(precedent, p, demi)
			chemins[#chemins].libre = true
			table.insert(sentierCoffre, p)
			precedent = p
		end
		ajouterChemin(A, B, demi)
		chemins[#chemins].libre = true
		table.insert(sentierCoffre, B)
	end
	end -- fin du bloc chemins du Sol / sentier du coffre

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
	-- plante basse : pied libre hors sentiers, clairsemée en lisière ; portee = rayon réel de l'objet (feuilles,
	-- second rocher...) gardé hors du Volcan et du Cratère (rEmprise par défaut)
	local function placeBasse(rSol, rEmprise, profMin, cellule, portee)
		return chercher(function(x, z)
			if not (dansEmprise(x, z, rEmprise) and not surChemin(x, z, rSol) and libre(x, z, rSol)) then
				return false
			end
			if not loinDesDisques(x, z, portee or rEmprise) then
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
	local dBordure = Outils.dossier(dossier, "Bordure")

	-- ===== animations légères (client) : quelques feuillages seulement =====
	local ANIMES_MAX = reglage(ctx, "animes")
	local nbAnimes = 0
	local function animer(inst, genre, vitesse)
		if not inst or nbAnimes >= ANIMES_MAX or not Outils.animer then
			return
		end
		nbAnimes = nbAnimes + 1
		pcall(Outils.animer, inst, genre, vitesse)
	end

	-- ===== 1. sol de jungle en terrain : herbe touffue, lisière herbeuse irrégulière, sentiers de terre =====
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
	-- rectangles peignables : dans la zone, hors falaises, rivière et coffre, hors carrés du Volcan et du Cratère
	-- (ces carrés sont ensuite pavés, case par case, en dehors des disques)
	local exclus = {}
	for _, q in ipairs(interdits) do
		table.insert(exclus, q)
	end
	for _, d in ipairs(disques) do
		table.insert(exclus, { x0 = d.x - d.r, x1 = d.x + d.r, z0 = d.z - d.r, z1 = d.z + d.r })
	end
	local PAS_PAVAGE = reglage(ctx, "pasPavage")
	local function caseLibre(x0, x1, z0, z1)
		for _, d in ipairs(disques) do
			local px = math.max(x0, math.min(d.x, x1))
			local pz = math.max(z0, math.min(d.z, z1))
			local dx, dz = d.x - px, d.z - pz
			if dx * dx + dz * dz < d.r * d.r then
				return false
			end
		end
		for _, q in ipairs(interdits) do
			if not (x1 <= q.x0 or x0 >= q.x1 or z1 <= q.z0 or z0 >= q.z1) then
				return false
			end
		end
		return true
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
			Outils.terrainBloc(CFrame.new((m.x0 + m.x1) / 2, dessus - h / 2, (m.z0 + m.z1) / 2), V3(m.x1 - m.x0, h, m.z1 - m.z0), materiau)
		end
		-- autour des disques : pavage hors du disque (le sol de jungle épouse le pied du Volcan)
		for _, d in ipairs(disques) do
			local x0, x1 = math.max(r.x0, d.x - d.r), math.min(r.x1, d.x + d.r)
			local z0, z1 = math.max(r.z0, d.z - d.r), math.min(r.z1, d.z + d.r)
			if x1 - x0 > 0.5 and z1 - z0 > 0.5 then
				local x = x0
				while x < x1 - 0.01 do
					local xb = math.min(x + PAS_PAVAGE, x1)
					local z = z0
					while z < z1 - 0.01 do
						local zb = math.min(z + PAS_PAVAGE, z1)
						if caseLibre(x, xb, z, zb) then
							Outils.terrainBloc(CFrame.new((x + xb) / 2, dessus - h / 2, (z + zb) / 2), V3(xb - x, h, zb - z), materiau)
						end
						z = zb
					end
					x = xb
				end
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
				if dansEmprise(x, z, 0.5) and horsExclusions(x, z, rayon) then
					Outils.terrainCylindre(CFrame.new(x, -1.98, z), 4, rayon, Mat.Grass)
				end
				a = a + hasard(6, 11)
			end
		end
		-- sentiers de terre battue : disques de terre enchaînés (bords arrondis, largeur qui varie un peu),
		-- bordés d'une frange d'herbe rase ; clairières en herbe rase avec un cœur de terre
		local function tamponner(x, z, rayon, materiau, y)
			if dansEmprise(x, z, 0) and horsExclusions(x, z, rayon) then
				Outils.terrainCylindre(CFrame.new(x, y - 2, z), 4, rayon, materiau)
			end
		end
		for _, c in ipairs(clairieres) do
			tamponner(c.x, c.z, c.r + 1, Mat.Grass, 0.03)
		end
		for _, s in ipairs(chemins) do
			local long = math.sqrt((s.bx - s.ax) ^ 2 + (s.bz - s.az) ^ 2)
			local n = math.max(1, math.floor(long / 2.5))
			for k = 0, n do
				local u = k / n
				local x, z = s.ax + (s.bx - s.ax) * u, s.az + (s.bz - s.az) * u
				tamponner(x, z, s.demi + 1.2, Mat.Grass, 0.03)
			end
		end
		-- le sentier du coffre traverse aussi la pelouse et entre dans l'anse de la falaise : sa terre est posée
		-- partout (hors Volcan et Cratère), avec une largeur plus régulière
		local function tamponnerLibre(x, z, rayon)
			if loinDesDisques(x, z, rayon) then
				Outils.terrainCylindre(CFrame.new(x, 0.04 - 2, z), 4, rayon, Mat.Ground)
			end
		end
		for _, s in ipairs(chemins) do
			local long = math.sqrt((s.bx - s.ax) ^ 2 + (s.bz - s.az) ^ 2)
			local n = math.max(1, math.floor(long / 2.5))
			for k = 0, n do
				local u = k / n
				local x, z = s.ax + (s.bx - s.ax) * u, s.az + (s.bz - s.az) * u
				if s.libre then
					tamponnerLibre(x, z, s.demi * hasard(0.8, 0.88))
				else
					tamponner(x, z, s.demi * hasard(0.72, 0.9), Mat.Ground, 0.04)
				end
			end
		end
		for _, c in ipairs(clairieres) do
			tamponner(c.x + hasard(-1, 1), c.z + hasard(-1, 1), c.r * 0.55, Mat.Ground, 0.04)
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
					if dansEmprise(x, z, r) and not surChemin(x, z, r) and loinDesDisques(x, z, r) then
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
			local long = math.max(4, math.min(24, pas - 4))
			if dansEmprise(x, z, 2.5) and loinDesDisques(x, z, math.sqrt((long / 2) ^ 2 + 4)) then
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

	-- papillons colorés qui voltigent dans les clairières au bout des sentes (très peu de particules)
	for k, c in ipairs(clairieres) do
		local zone = bloc(dLucioles, {
			Name = "Papillons" .. k,
			Size = V3(c.r * 1.4, 3, c.r * 1.4),
			CFrame = CFrame.new(c.x, 2.5, c.z),
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})
		if zone then
			pcall(function()
				local p = Instance.new("ParticleEmitter")
				p.Name = "Papillons"
				p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				p.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, FLEURS[1]),
					ColorSequenceKeypoint.new(0.35, FLEURS[4]),
					ColorSequenceKeypoint.new(0.7, FLEURS[3]),
					ColorSequenceKeypoint.new(1, FLEURS[5]),
				})
				p.LightEmission = 0.3
				p.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.15, 0.45),
					NumberSequenceKeypoint.new(0.85, 0.45),
					NumberSequenceKeypoint.new(1, 0),
				})
				p.Lifetime = NumberRange.new(3, 5)
				p.Rate = 0.8
				p.Speed = NumberRange.new(1, 2.2)
				p.SpreadAngle = Vector2.new(180, 60)
				p.RotSpeed = NumberRange.new(-180, 180)
				p.Acceleration = V3(0, 0.3, 0)
				p.Drag = 1.2
				p.Parent = zone
			end)
		end
	end

	-- ===== 3. gros arbres à canopée =====
	-- arbre complet ~16 parts ; arbre de fond simplifié (simple = true, plus haut, sans racines ni liane) 6 parts
	local COUT_ARBRE = 16
	local COUT_SIMPLE = 6
	local R_CANOPEE = 7
	local PORTEE_PIED = 4.6 -- racines contreforts (dT / 2 + lR - 0,6) et butte au pied
	local function arbre(numero, cellule, simple)
		local cout = COUT_ARBRE
		if simple then
			cout = COUT_SIMPLE
		end
		if reste() < cout then
			return false
		end
		local H = hasard(11, 14.5)
		local dT = hasard(2.3, 3)
		local lean = hasard(4, 11)
		local nSeg = 3
		if simple then
			H = hasard(14, 19)
			dT = hasard(2.4, 3.1)
			lean = hasard(2, 7)
			nSeg = 2
		end
		local pts = nil
		local y0 = 0
		local x, z = chercher(function(px, pz)
			-- pied : racines contreforts jusqu'à ~4,6 du tronc
			if not (dansEmprise(px, pz, 3) and not surChemin(px, pz, 3.2) and libre(px, pz, 3.4) and loinDesDisques(px, pz, PORTEE_PIED)) then
				return false
			end
			if profondeur(px, pz) < 7 then
				return false
			end
			local h = hauteurSol(px, pz)
			local essai = pointsTronc(V3(px, h - 0.8, pz), H + 0.8, nSeg, lean, hasard(0, DEUX_PI))
			local top = essai[#essai]
			-- canopée : les lobes atteignent R_CANOPEE autour du sommet du tronc
			if dansEmprise(top.X, top.Z, R_CANOPEE + 0.2) and cimeLibre(top.X, top.Z, R_CANOPEE) and loinDesDisques(top.X, top.Z, R_CANOPEE) then
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
		local nbRacines = 3
		if simple then
			nbRacines = 0
		end
		for k = 1, nbRacines do
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
		local nbLobes = 4
		if simple then
			nbLobes = 2
		end
		for k = 1, nbLobes do
			local a = decL + (k - 1) * (DEUX_PI / nbLobes) + hasard(-0.35, 0.35)
			local s = hasard(5.8, 6.8)
			local r = R_CANOPEE - s / 2
			local pos = centre + V3(math.cos(a) * r, hasard(-2.4, -0.8), math.sin(a) * r)
			local couleur = ombre(base)
			if k % 2 == 0 then
				couleur = base:Lerp(ombre(base), 0.5)
			end
			boule(m, { Name = "Lobe" .. k, Size = V3(s, s, s), CFrame = CFrame.new(pos), Color = couleur, Material = Mat.LeafyGrass, CanCollide = false })
			table.insert(lobes, { pos = pos, s = s })
			if k == 1 and not simple then
				cylEntre(m, T - V3(0, 2.2, 0), pos, 0.8, 0.3, { Name = "Branche" .. k, Color = ECORCE_CLAIRE, Material = Mat.Wood, CanCollide = false })
			end
		end
		local sommet = boule(m, {
			Name = "Sommet",
			Size = V3(6.4, 6.4, 6.4),
			CFrame = CFrame.new(centre + V3(hasard(-1, 1), 3.6, hasard(-1, 1))),
			Color = lumiere(base),
			Material = Mat.Grass,
			CanCollide = false,
		})
		-- la cime des arbres visibles depuis le centre respire doucement au vent (client)
		if not simple and profondeur(x, z) < 22 and rng:NextNumber() < 0.35 then
			animer(sommet, "flotte", hasard(0.45, 0.75))
		end
		-- une liane qui pend d'un lobe, terminée par une feuille
		local lobe = lobes[rng:NextInteger(1, #lobes)]
		if lobe and not simple and rng:NextNumber() < 0.6 then
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
			if not (dansEmprise(px, pz, 2) and not surChemin(px, pz, 2.4) and libre(px, pz, 2.6) and loinDesDisques(px, pz, 2)) then
				return false
			end
			if profondeur(px, pz) < 5 then
				return false
			end
			local h = hauteurSol(px, pz)
			local essai = pointsTronc(V3(px, h - 0.6, pz), hauteur, n, lean, hasard(0, DEUX_PI))
			local top = essai[#essai]
			-- les palmes débordent de rCouronne : leur portée réelle (longueur + demi-largeur) reste hors du Volcan
			if dansEmprise(top.X, top.Z, rCouronne) and cimeLibre(top.X, top.Z, rCouronne) and loinDesDisques(top.X, top.Z, longPalme * 1.05 + 0.8) then
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
		-- la couronne se balance doucement (client) sur un palmier sur deux
		if rng:NextNumber() < 0.55 then
			animer(palmes, "flotte", hasard(0.55, 0.85))
		end
		table.insert(couronnes, { pos = sommet, rayon = longPalme })
		return true
	end

	-- ===== 5. les grands végétaux, cellule par cellule =====
	-- d'abord les palmiers, répartis près de la lisière (ce sont eux qu'on voit du centre de jeu) ; puis les arbres,
	-- de la périphérie vers la lisière (ordre un peu brassé) : le fond est plein, le budget restant ouvre des
	-- clairières près du bord où poussent les plantes basses.
	local cellules = {}
	for _, q in ipairs(zones) do
		local taille = reglage(ctx, "celluleCotes")
		if q.nom == "jungleNord" then
			taille = reglage(ctx, "celluleNord")
		end
		local nx = math.max(1, math.floor((q.x1 - q.x0) / taille + 0.5))
		local nz = math.max(1, math.floor((q.z1 - q.z0) / taille + 0.5))
		local lx, lz = (q.x1 - q.x0) / nx, (q.z1 - q.z0) / nz
		-- clé de tri : profondeur relative à l'épaisseur de la zone (1 = dans sa moitié côté falaise), un peu
		-- brassée, pour que chaque zone ait son fond plein quelle que soit sa largeur
		local demiEpaisseur = math.max(1, math.min(q.x1 - q.x0, q.z1 - q.z0) / 2)
		for i = 0, nx - 1 do
			for j = 0, nz - 1 do
				local c = { x0 = q.x0 + i * lx, x1 = q.x0 + (i + 1) * lx, z0 = q.z0 + j * lz, z1 = q.z0 + (j + 1) * lz }
				c.prof = profondeur((c.x0 + c.x1) / 2, (c.z0 + c.z1) / 2)
				c.relatif = math.min(1, c.prof / demiEpaisseur)
				c.cle = c.relatif + hasard(0, 0.45)
				table.insert(cellules, c)
			end
		end
	end
	for i = #cellules, 2, -1 do
		local j = rng:NextInteger(1, i)
		cellules[i], cellules[j] = cellules[j], cellules[i]
	end
	local PART_VIDES = reglage(ctx, "partVides")
	local PROF_PALMIERS = reglage(ctx, "profondeurPalmiers")
	local PART_PALMIERS = reglage(ctx, "partPalmiers")
	local PROF_SIMPLES = reglage(ctx, "profondeurSimples")
	local PART_SIMPLES = reglage(ctx, "partSimples")
	local nbArbres, nbPalmiers = 0, 0
	local cellulesLibres = {}
	local PALMIERS_MAX = reglage(ctx, "palmiers")
	local RESERVE_BASSE = reglage(ctx, "reserveBasse")
	local plantees = {}
	for _, c in ipairs(cellules) do
		if nbPalmiers >= PALMIERS_MAX or reste() < RESERVE_BASSE + COUT_PALMIER then
			break
		end
		if c.prof < PROF_PALMIERS and rng:NextNumber() < PART_PALMIERS and palmier(nbPalmiers + 1, c) then
			nbPalmiers = nbPalmiers + 1
			plantees[c] = true
		end
	end
	table.sort(cellules, function(a, b)
		return a.cle > b.cle
	end)
	for _, c in ipairs(cellules) do
		if not plantees[c] then
			if reste() < RESERVE_BASSE or rng:NextNumber() < PART_VIDES then
				-- le reste du budget va aux plantes basses : les cellules restantes deviennent des clairières
				table.insert(cellulesLibres, c)
			else
				local simple = (c.prof > PROF_SIMPLES or c.relatif > 0.6) and rng:NextNumber() < PART_SIMPLES
				if arbre(nbArbres + 1, c, simple) then
					nbArbres = nbArbres + 1
				elseif arbre(nbArbres + 1, c, true) then
					nbArbres = nbArbres + 1
				else
					table.insert(cellulesLibres, c)
				end
			end
		end
	end
	-- les cellules libres les plus proches de la lisière d'abord (rochers, bananiers)
	table.sort(cellulesLibres, function(a, b)
		return a.prof < b.prof
	end)

	-- ===== 5. rochers en terrain (Rock, Slate), coiffés de mousse =====
	-- d'abord dans les cellules laissées libres par les grands végétaux, puis n'importe où
	if terrainOk then
		for i = 1, reglage(ctx, "rochers") do
			local r = hasard(1.8, 3.6)
			-- le second rocher déborde jusqu'à r × 0,85 + r × 0,7
			local x, z = placeBasse(r * 0.9, r + 1, 2.5, cellulesLibres[i], r * 1.6)
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
		local x, z = placeBasse(2.6, longFeuille * 0.8, 4, cellule, longFeuille + 1.6)
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
		local anime = rng:NextNumber() < 0.5
		for k = 1, 5 do
			local yaw = decalage + (k - 1) * (DEUX_PI / 5) + hasard(-0.2, 0.2)
			local pitch = math.rad(hasard(-18, 30))
			local couleur = choisir(BANANIER_FEUILLES)
			local feuille = bloc(m, {
				Name = "Feuille" .. k,
				Size = V3(hasard(2.5, 3.1), 0.2, longFeuille),
				CFrame = CFrame.new(sommet) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, math.rad(hasard(-12, 12))) * CFrame.new(0, 0, -longFeuille / 2),
				Color = couleur,
				Material = Mat.LeafyGrass,
				CanCollide = false,
			})
			-- deux grandes feuilles qui ondulent (client), une sur deux plantes
			if anime and (k == 1 or k == 3) then
				animer(feuille, "flotte", hasard(0.8, 1.3))
			end
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
	-- px, pz : position imposée (bordure de lisière, déjà vérifiée) ; sinon tirée au hasard
	local function fougere(numero, px, pz, parent, longMax, nbFrondes)
		local nbF = nbFrondes or COUT_FOUGERE -- une part par fronde
		if reste() < nbF then
			return false
		end
		local long = hasard(4.2, longMax or 6)
		local x, z = px, pz
		if not x then
			x, z = placeBasse(2, long * 0.65, 1.5, nil, long * 1.05 + 0.8)
		end
		if not x then
			return false
		end
		occuper(x, z, 2)
		local m = Outils.modele(parent or dFougeres, "Fougere" .. numero)
		local decalage = hasard(0, DEUX_PI)
		local base = V3(x, hauteurSol(x, z) + 0.15, z)
		for k = 1, nbF do
			local yaw = decalage + (k - 1) * (DEUX_PI / nbF) + hasard(-0.18, 0.18)
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
	-- px, pz : position imposée (bordure de lisière) ; echelle < 1 pour un buisson plus bas
	local function buisson(numero, px, pz, parent, echelle, nbFleurs)
		if reste() < COUT_BUISSON then
			return false
		end
		local x, z = px, pz
		if not x then
			x, z = placeBasse(2.4, 3.6, 1, nil, 1.4 + 2 * (echelle or 1) + 0.8)
		end
		if not x then
			return false
		end
		occuper(x, z, 2.4)
		local y0 = hauteurSol(x, z)
		local m = Outils.modele(parent or dBuissons, "Buisson" .. numero)
		local boules = {}
		local nb = rng:NextInteger(2, 3)
		local teinte = choisir(FEUILLAGES)
		for k = 1, nb do
			local s = hasard(2.8, 4) * (echelle or 1)
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
		for k = 1, (nbFleurs or 3) do
			local b = boules[rng:NextInteger(1, #boules)]
			local a = hasard(0, DEUX_PI)
			local el = hasard(0.3, 1.1)
			local dir = V3(math.cos(a) * math.cos(el), math.sin(el), math.sin(a) * math.cos(el))
			fleur(m, b.centre + dir * (b.s / 2), dir, hasard(1.2, 1.6), couleurFleur, "Fleur" .. k)
		end
		return true
	end

	-- touffe d'herbe (3 brins), parfois fleurie ; px, pz : position imposée, sinon tirée en lisière
	local function touffe(numero, px, pz, parent, chanceFleur)
		if reste() < 6 then
			return false
		end
		local x, z = px, pz
		if not x then
			x, z = chercher(function(qx, qz)
				local p = profondeur(qx, qz)
				return p >= 0.8 and p <= LISIERE + 3 and dansEmprise(qx, qz, 1.2) and not surChemin(qx, qz, 1.2) and libre(qx, qz, 1.2) and loinDesDisques(qx, qz, 1.4)
			end)
		end
		if not x then
			return false
		end
		occuper(x, z, 1.2)
		local y0 = hauteurSol(x, z)
		local m = Outils.modele(parent or dTouffes, "Touffe" .. numero)
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
				CFrame = CFrame.new(x, y0, z) * CFrame.Angles(0, dec + (k - 1) * 2.1, 0) * CFrame.Angles(math.rad(-12), 0, 0) * CFrame.new(0, h / 2 - 0.1, 0.3),
				Color = couleur,
				Material = Mat.Grass,
				CanCollide = false,
				CastShadow = false,
			})
		end
		if rng:NextNumber() < (chanceFleur or 0.5) then
			local h = hasard(1.6, 2.2)
			cylEntre(m, V3(x, y0, z), V3(x + 0.2, y0 + h, z), 0.18, 0, { Name = "Tige", Color = FOUGERE, Material = Mat.Grass, CanCollide = false, CastShadow = false })
			fleur(m, V3(x + 0.2, y0 + h, z), V3(0.25, 1, 0.1).Unit, 1.1, choisir(FLEURS), "Fleur")
		end
		return true
	end

	-- ===== 8 bis. bordure de lisière : une frise de plantes basses le long du bord tourné vers le centre de jeu =====
	-- (fougères, touffes fleuries, petits buissons à fleurs, galets moussus), espacées assez régulièrement pour un
	-- bord « jardiné », avec un léger décalage en profondeur pour éviter l'alignement parfait
	local PAS_BORDURE = reglage(ctx, "pasBordure")
	local nbBordure = 0
	for _, c in ipairs(cotes) do
		local a = c.a0 + hasard(2, 5)
		while a < c.a1 - 2 do
			local t = rng:NextNumber()
			-- portee : rayon réel de la plante (frondes de 5 × 1,05, buisson à l'échelle 0,75, galet de 1,7)
			local genre, rayon, portee = "touffe", 1.2, 1.4
			if t < 0.3 then
				genre, rayon, portee = "fougere", 3.6, 6.1
			elseif t < 0.5 then
				genre, rayon, portee = "buisson", 2.8, 3.8
			elseif t < 0.62 then
				genre, rayon, portee = "galet", 1.6, 1.8
			end
			local p = pointCote(c, a + hasard(-1, 1), rayon + hasard(0.3, 1.6))
			if dansEmprise(p.X, p.Z, rayon) and not surChemin(p.X, p.Z, rayon) and libre(p.X, p.Z, math.min(rayon, 2)) and loinDesDisques(p.X, p.Z, portee) then
				nbBordure = nbBordure + 1
				if genre == "fougere" then
					fougere(nbBordure, p.X, p.Z, dBordure, 5)
				elseif genre == "buisson" then
					buisson(nbBordure, p.X, p.Z, dBordure, 0.75)
				elseif genre == "galet" then
					if terrainOk then
						occuper(p.X, p.Z, rayon)
						local r = hasard(1.1, 1.7)
						Outils.terrainBoule(V3(p.X, -r * 0.35, p.Z), r, Mat.Slate)
						Outils.terrainBoule(V3(p.X + hasard(-0.3, 0.3), r * 0.35, p.Z + hasard(-0.3, 0.3)), r * 0.6, Mat.LeafyGrass)
					end
				else
					touffe(nbBordure, p.X, p.Z, dBordure, 0.6)
				end
			end
			a = a + PAS_BORDURE * hasard(0.7, 1.3)
		end
	end

	for i = 1, reglage(ctx, "fougeres") do
		fougere(i)
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
			local pois = boule(parent, {
				Name = "Pois" .. numero .. "_" .. k,
				Size = V3(sp, sp, sp),
				CFrame = CFrame.new(centre + dir * (dDome / 2 - sp * 0.25)),
				Color = couleurPois,
				Material = matiere,
				CanCollide = false,
				CastShadow = false,
			})
			-- les pois luisants palpitent lentement (client)
			if lumineux then
				animer(pois, "pulse", hasard(0.9, 1.4))
			end
		end
		if lumineux and dome then
			pcall(Outils.lumiere, dome, { Range = 9, Brightness = 0.7, Color = Charte.gemme })
		end
	end
	local function champignons(numero)
		if reste() < 15 then
			return false
		end
		local x, z = placeBasse(2.4, 3.2, 1.5, nil, 3.4)
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
		local x, z = placeBasse(L / 2, L / 2 + 0.5, 4, nil, math.sqrt((L / 2 + 0.1) ^ 2 + (d / 2) ^ 2) + 0.2)
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
					if not (dansEmprise(p.X, p.Z, 0.5) and loinDesDisques(p.X, p.Z, 0.5)) then
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

	-- ===== 12. touffes d'herbe en lisière, parfois fleuries (en plus de la bordure) =====
	for i = 1, reglage(ctx, "touffes") do
		touffe(i)
	end
	local partsJungle = nbParts
	do -- bloc à part (limite de 200 variables locales)

	-- ===== 13. hors de la jungle : budget à part pour le sentier du coffre et les bosquets des pelouses =====
	BUDGET = nbParts + reglage(ctx, "budgetBosquets")

	-- pas japonais d'ardoise sur la partie du sentier du coffre qui traverse la pelouse (comme les sentiers du Sol)
	local PIERRES = { hex("C4BAB4"), hex("B5ACAA"), hex("A79E9C") }
	if #sentierCoffre > 1 then
		local dSentier = Outils.dossier(dossier, "SentierCoffre")
		local PAS_J = reglage(ctx, "pasJaponais")
		local function horsPelouse(x, z)
			for _, q in ipairs(zones) do
				if x > q.x0 - 1.5 and x < q.x1 + 1.5 and z > q.z0 - 1.5 and z < q.z1 + 1.5 then
					return true
				end
			end
			for _, f in pairs(Plan.falaises or {}) do
				if type(f) == "table" and f.xMin and x > f.xMin - 1.5 and x < f.xMax + 1.5 and z > f.zMin - 1.5 and z < f.zMax + 1.5 then
					return true
				end
			end
			return surSol(x, z, 1.5)
		end
		local cumul, prochain, nbPas = 0, PAS_J * 0.8, 0
		for k = 2, #sentierCoffre do
			local a, b = sentierCoffre[k - 1], sentierCoffre[k]
			local seg = (b - a).Magnitude
			if seg > 0.01 then
				local dir = (b - a).Unit
				while prochain <= cumul + seg do
					local p = a:Lerp(b, (prochain - cumul) / seg) + V3(-dir.Z, 0, dir.X) * hasard(-0.6, 0.6)
					if not horsPelouse(p.X, p.Z) then
						nbPas = nbPas + 1
						local d = hasard(2.2, 2.7)
						cylindre(dSentier, {
							Name = "Pas" .. nbPas,
							Size = V3(0.22, d, d),
							CFrame = CFrame.new(p.X, 0.1, p.Z) * CFrame.Angles(0, 0, math.rad(90)),
							Color = choisir(PIERRES),
							Material = Mat.Slate,
							CanCollide = false,
						})
					end
					prochain = prochain + PAS_J * hasard(0.9, 1.1)
				end
				cumul = cumul + seg
			end
		end
	end

	-- ===== 14. bosquets : un petit bois soigné dans chaque îlot de Plan.decor.bosquets (centre c, rayon r) =====
	-- dense au centre (un grand arbre sur sa butte, parfois un palmier penché vers l'extérieur, des arbres moyens
	-- tout autour), qui s'ouvre sur les bords (buissons à fleurs, fougère, rochers moussus, touffes fleuries, tapis
	-- d'herbe touffue festonné) ; rien ne touche un chemin du Sol, une Base ni le sentier du coffre.
	local ilots = Plan.decor.bosquets
	if type(ilots) == "table" and #ilots > 0 then
		local dBosquets = Outils.dossier(dossier, "Bosquets")

		-- arbre de bosquet : tronc (1 ou 2 segments) et houppier de boules en trois teintes (nSeg + nbLobes + 2 parts)
		local function arbreIlot(parent, nom, x, z, y0, H, rC, nSeg, nbLobes, lean, psi)
			local m = Outils.modele(parent, nom)
			local pts = pointsTronc(V3(x, y0 - 0.6, z), H + 0.6, nSeg, lean, psi)
			local T = pts[#pts]
			local dT = 1.1 + H * 0.1
			for i = 1, nSeg do
				local couleur = ECORCE
				if i % 2 == 0 then
					couleur = ECORCE_CLAIRE
				end
				cylEntre(m, pts[i], pts[i + 1], dT - (i - 1) * 0.35, 0.5, { Name = "Tronc" .. i, Color = couleur, Material = Mat.Wood })
			end
			local base = choisir(FEUILLAGES)
			local centre = T + V3(0, rC * 0.3, 0)
			local dC = rC * 1.45
			boule(m, { Name = "Canopee", Size = V3(dC, dC, dC), CFrame = CFrame.new(centre), Color = base, Material = Mat.Grass, CanCollide = false })
			local decL = hasard(0, DEUX_PI)
			for k = 1, nbLobes do
				local a = decL + (k - 1) * (DEUX_PI / nbLobes) + hasard(-0.35, 0.35)
				local s = rC * hasard(0.8, 0.95)
				local r = rC - s / 2
				local couleur = ombre(base)
				if k % 2 == 0 then
					couleur = base:Lerp(ombre(base), 0.5)
				end
				boule(m, { Name = "Lobe" .. k, Size = V3(s, s, s), CFrame = CFrame.new(centre + V3(math.cos(a) * r, -rC * hasard(0.15, 0.35), math.sin(a) * r)), Color = couleur, Material = Mat.LeafyGrass, CanCollide = false })
			end
			local dS = rC * 0.9
			return boule(m, { Name = "Sommet", Size = V3(dS, dS, dS), CFrame = CFrame.new(centre + V3(hasard(-0.4, 0.4), rC * 0.5, hasard(-0.4, 0.4))), Color = lumiere(base), Material = Mat.Grass, CanCollide = false })
		end

		-- palmier de bosquet (24 parts) : tronc courbé en 3 segments, cœur, 3 palmes basses sombres qui retombent et
		-- 2 palmes hautes plus claires, chacune en 2 segments pliés en V
		local COUT_PALMIER_ILOT = 24
		local function palmierIlot(parent, nom, x, z, hauteur, lean, psi, longPalme)
			local m = Outils.modele(parent, nom)
			local pts = pointsTronc(V3(x, -0.6, z), hauteur, 3, lean, psi)
			local sommet = pts[#pts]
			local d0 = hasard(1.5, 1.8)
			for i = 1, 3 do
				local couleur = TRONC
				if i % 2 == 0 then
					couleur = TRONC_CLAIR
				end
				cylEntre(m, pts[i], pts[i + 1], d0 - (i - 1) * 0.2, 0.45, { Name = "Tronc" .. i, Color = couleur, Material = Mat.Wood })
			end
			boule(m, { Name = "Coeur", Size = V3(2, 2, 2), CFrame = CFrame.new(sommet + V3(0, 0.3, 0)), Color = COEUR, Material = Mat.LeafyGrass, CanCollide = false })
			local palmes = Outils.modele(m, "Palmes")
			local pli = math.rad(16)
			local dec = hasard(0, DEUX_PI)
			-- { nombre, décalage, inclinaison mini/maxi, longueur relative, couleur, matière }
			local couronnesIlot = {
				{ 3, 0, -24, -10, 1, PALME_SOMBRE, Mat.LeafyGrass },
				{ 2, 1.05, 2, 14, 0.8, PALME, Mat.Grass },
			}
			for _, c in ipairs(couronnesIlot) do
				for k = 1, c[1] do
					local yaw = dec + c[2] + (k - 1) * (DEUX_PI / c[1]) + hasard(-0.15, 0.15)
					local F = CFrame.new(sommet + V3(0, 0.3, 0)) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(math.rad(hasard(c[3], c[4])), 0, 0) * CFrame.new(0, 0, -0.3)
					local long = longPalme * c[5] * hasard(0.92, 1.05)
					for s = 1, 2 do
						local L = long * 0.55
						local w = 1.4
						local teinte = c[6]
						if s == 2 then
							L = long * 0.45
							w = 0.9
							teinte = teinte:Lerp(lumiere(teinte), 0.3)
						end
						demiFeuille(palmes, F * CFrame.Angles(0, 0, -pli), L, w, 0.2, 1, { Name = "Palme" .. k .. "S" .. s .. "D", Color = ombre(teinte):Lerp(teinte, 0.55), Material = c[7], CanCollide = false })
						demiFeuille(palmes, F * CFrame.Angles(0, 0, pli), L, w, 0.2, -1, { Name = "Palme" .. k .. "S" .. s .. "G", Color = teinte, Material = c[7], CanCollide = false })
						F = F * CFrame.new(0, 0, -L * 0.93) * CFrame.Angles(-math.rad(22), 0, 0)
					end
				end
			end
			animer(palmes, "flotte", hasard(0.55, 0.85))
		end

		for i, b in ipairs(ilots) do
			if b.c and type(b.r) == "number" and b.r > 3 then
				local R = b.r
				local cx, cz = b.c.X, b.c.Z
				-- chaque îlot suivant garde de quoi planter son grand arbre, deux arbres moyens et un buisson
				local reserve = (#ilots - i) * 22
				local function dispo(cout)
					return reste() - reserve >= cout
				end
				local m = Outils.modele(dBosquets, "Bosquet" .. i)
				local cimesB = {}
				local function cimeOk(x, z, r)
					for _, c in ipairs(cimesB) do
						local dx, dz = x - c.x, z - c.z
						local mini = (r + c.r) * 0.55
						if dx * dx + dz * dz < mini * mini then
							return false
						end
					end
					return true
				end
				-- pied (rayon rPied) entièrement dans l'îlot, hors des chemins et des autres pieds
				local function pied(x, z, rPied)
					local dx, dz = x - cx, z - cz
					return math.sqrt(dx * dx + dz * dz) + rPied <= R and not surSol(x, z, rPied + 1) and not surChemin(x, z, rPied + 1) and libre(x, z, rPied) and loinDesDisques(x, z, rPied)
				end
				-- houppier (rayon rC) : peut déborder un peu de l'îlot, jamais au-dessus d'un chemin
				local function houppier(top, rC)
					local dx, dz = top.X - cx, top.Z - cz
					return math.sqrt(dx * dx + dz * dz) + rC * 0.55 <= R + 1.5 and not surSol(top.X, top.Z, rC) and not surChemin(top.X, top.Z, rC)
				end
				-- point tiré dans la couronne [dMin, dMax] × R, près de l'angle aPref s'il est donné
				local function placer(dMin, dMax, aPref, essai)
					for t = 1, 50 do
						local a = hasard(0, DEUX_PI)
						if aPref and t <= 30 then
							a = aPref + hasard(-0.6, 0.6)
						end
						local d = R * math.sqrt(hasard(dMin * dMin, dMax * dMax))
						local x, z = cx + math.cos(a) * d, cz + math.sin(a) * d
						if essai(x, z, a) then
							return x, z
						end
					end
					return nil, nil
				end

				-- sol : tapis d'herbe touffue festonné (terrain, 0 part)
				if terrainOk then
					local function tapis(x, z, r)
						if not surSol(x, z, r + 0.5) and not surChemin(x, z, r + 0.5) then
							Outils.terrainCylindre(CFrame.new(x, 0.02 - 2, z), 4, r, Mat.LeafyGrass)
						end
					end
					tapis(cx, cz, R * 0.62)
					local a0 = hasard(0, DEUX_PI)
					for k = 1, 5 do
						local a = a0 + k * DEUX_PI / 5 + hasard(-0.3, 0.3)
						local d = R * hasard(0.45, 0.6)
						tapis(cx + math.cos(a) * d, cz + math.sin(a) * d, R * hasard(0.25, 0.34))
					end
				end

				-- arbres : le grand au centre (sur sa butte), puis le palmier, puis les moyens répartis tout autour
				local nbArbres = 3
				if R >= 11 then
					nbArbres = 4
				end
				if R >= 13 then
					nbArbres = 5
				end
				local nbPlantes = 0
				local function planterArbre(dMin, dMax, aPref, H, rC, nSeg, nbLobes, butte)
					if reste() < nSeg + nbLobes + 2 or (not butte and not dispo(nSeg + nbLobes + 2)) then
						return false
					end
					local lean = hasard(3, 9)
					local psi = 0
					local rPied = 1.6
					if butte then
						rPied = 2.6
					end
					local x, z = placer(dMin, dMax, aPref, function(px, pz, a)
						if not pied(px, pz, rPied) then
							return false
						end
						psi = a + hasard(-0.5, 0.5) -- penche plutôt vers l'extérieur du bosquet
						local essai = pointsTronc(V3(px, -0.6, pz), H + 0.6, nSeg, lean, psi)
						local top = essai[#essai]
						return houppier(top, rC) and cimeOk(top.X, top.Z, rC)
					end)
					if not x then
						return false
					end
					occuper(x, z, rPied)
					local y0 = 0
					if butte and terrainOk then
						Outils.terrainBoule(V3(x, -2.8, z), 3.8, Mat.LeafyGrass)
						table.insert(buttes, { x = x, y = -2.8, z = z, r = 3.8 })
						y0 = 0.6
					end
					nbPlantes = nbPlantes + 1
					local sommet = arbreIlot(m, "Arbre" .. nbPlantes, x, z, y0, H, rC, nSeg, nbLobes, lean, psi)
					local top = pointsTronc(V3(x, -0.6, z), H + 0.6, nSeg, lean, psi)
					top = top[#top]
					table.insert(cimesB, { x = top.X, z = top.Z, r = rC })
					if butte and sommet then
						animer(sommet, "flotte", hasard(0.45, 0.7))
					end
					return true
				end
				local aBase = hasard(0, DEUX_PI)
				local plantes = 0
				if planterArbre(0, 0.22, nil, hasard(11.5, 14), hasard(5.4, 6.2), 2, 2, true) or planterArbre(0, 0.4, nil, hasard(10, 12), hasard(4.8, 5.4), 2, 2, false) then
					plantes = plantes + 1
				end
				if R >= 12 and dispo(COUT_PALMIER_ILOT + 12) then
					local hauteur = hasard(13, 17)
					local lean = hasard(14, 24)
					local longPalme = hasard(6.5, 8)
					local psi = 0
					local x, z = placer(0.3, 0.55, aBase, function(px, pz, a)
						if not pied(px, pz, 1.6) then
							return false
						end
						psi = a + hasard(-0.3, 0.3)
						local essai = pointsTronc(V3(px, -0.6, pz), hauteur, 3, lean, psi)
						local top = essai[#essai]
						return houppier(top, longPalme * 0.8) and cimeOk(top.X, top.Z, longPalme * 0.5)
					end)
					if x then
						occuper(x, z, 1.6)
						nbPlantes = nbPlantes + 1
						palmierIlot(m, "Palmier" .. nbPlantes, x, z, hauteur, lean, psi, longPalme)
						plantes = plantes + 1
					end
				end
				local nbMoyens = nbArbres - plantes
				for k = 1, nbMoyens do
					local aPref = aBase + math.pi + (k - 0.5) * (DEUX_PI / math.max(1, nbMoyens)) * 0.8
					if not planterArbre(0.35, 0.68, aPref, hasard(7, 10), hasard(3.6, 4.6), 1, 1, false) then
						planterArbre(0.25, 0.75, nil, hasard(6.5, 8.5), hasard(3.2, 4), 1, 1, false)
					end
				end

				-- strate basse, plus clairsemée vers les bords
				local nbBuissons = 1
				if R >= 13 then
					nbBuissons = 2
				end
				for k = 1, nbBuissons do
					local x, z = nil, nil
					if k == 1 or dispo(9) then
						x, z = placer(0.5, 0.85, nil, function(px, pz)
							return pied(px, pz, 2.8)
						end)
					end
					if x then
						nbPlantes = nbPlantes + 1
						buisson(nbPlantes, x, z, m, 0.8, 2)
					end
				end
				if R >= 12 and dispo(5) then
					local x, z = placer(0.4, 0.8, nil, function(px, pz)
						return pied(px, pz, 3.6)
					end)
					if x then
						nbPlantes = nbPlantes + 1
						fougere(nbPlantes, x, z, m, 4.8, 5)
					end
				end
				if R < 11 and dispo(6) then
					local x, z = placer(0.75, 0.95, nil, function(px, pz)
						return pied(px, pz, 1.2)
					end)
					if x then
						nbPlantes = nbPlantes + 1
						touffe(nbPlantes, x, z, m, 0.8)
					end
				end
				-- rochers moussus en terrain (Rock / Slate coiffés de mousse)
				if terrainOk then
					local nbRochers = 1
					if R >= 12 then
						nbRochers = 2
					end
					for _ = 1, nbRochers do
						local r = hasard(1.3, 2)
						local x, z = placer(0.45, 0.92, nil, function(px, pz)
							return pied(px, pz, r * 1.5)
						end)
						if x then
							occuper(x, z, r * 1.2)
							local principal, second = Mat.Rock, Mat.Slate
							if rng:NextNumber() < 0.4 then
								principal, second = Mat.Slate, Mat.Rock
							end
							local centre = V3(x, hauteurSol(x, z) + r * 0.1, z)
							Outils.terrainBoule(centre, r, principal)
							local a = hasard(0, DEUX_PI)
							local r2 = r * hasard(0.5, 0.65)
							Outils.terrainBoule(V3(x + math.cos(a) * r * 0.8, centre.Y - r * 0.25, z + math.sin(a) * r * 0.8), r2, second)
							Outils.terrainBoule(centre + V3(hasard(-0.3, 0.3), r * 0.5, hasard(-0.3, 0.3)), r * 0.62, Mat.LeafyGrass)
						end
					end
				end
			end
		end
	end

	end -- fin du bloc sentier du coffre / bosquets

	dossier:SetAttribute("Parts", nbParts)
	dossier:SetAttribute("PartsBosquets", nbParts - partsJungle)
end

return M
