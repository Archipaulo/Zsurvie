-- Constructeur Sol (version 2, STYLE.md §4) : le sol de tout le monde en TERRAIN Roblox.
-- Herbe Grass vert vif cartoon (dessus exactement à Y = 0, épaisseur 8, brins d'herbe activés),
-- plaques d'herbe touffue (LeafyGrass) en périphérie, terre battue (Ground) sous les bâtiments,
-- allées de sable (Sand) au ras de l'herbe, calées sur la grille de 4 studs du terrain :
-- promenade le long du Tapis, seuils des Bases, couloirs entre les Bases, traverses, parvis de
-- la Place, du Cratère, de la Nurserie et de la Fin du tapis, liens vers Comptoir et Autel, plages
-- de la rivière. Bordures de galets (parts Cobblestone, dessus à 0,3) le long des allées,
-- quelques galets sur la plage et des fleurs plates sur l'herbe touffue. Murs invisibles au bord.
local M = {}

-- réglages par défaut (surchargés par Equilibrage.sol s'il existe)
local DEFAUTS = {
	budget = 250,          -- parts au maximum pour ce constructeur
	epaisseur = 8,         -- épaisseur du terrain d'herbe
	marge = 10,            -- l'herbe dépasse les murs invisibles de cette marge
	dessusAllee = 0.06,    -- dessus des allées (au ras de l'herbe)
	dessusTerre = 0.04,    -- dessus de la terre battue sous les bâtiments
	dessusTouffue = 0.02,  -- dessus des plaques d'herbe touffue
	zPromenade = 12,       -- promenade de sable le long du Tapis : |z| <= zPromenade
	xPromenade = 120,
	demiCouloir = 4,       -- couloirs entre les Bases : c - 4 .. c + 4
	couloirLoin = 72,      -- les couloirs rejoignent les traverses à |z| = 72
	traverseLoin = 80,     -- traverses : 72 <= |z| <= 80
	xTraverse = 60,
	rayonParvis = 24,      -- parvis de sable autour de la Place
	rayonParvisCratere = 20,
	rayonParvisNurserie = 16,
	demiLien = 4,          -- liens Place -> Comptoir et Place -> Autel
	demiSeuil = 4,         -- seuils de sable devant l'entrée de chaque Base
	zPlageSud = 122,       -- plages : de zPlageSud au bord de la rivière, et de l'autre rive à zPlageNord
	zPlageNord = 152,
	largeurBordure = 1,
	hauteurBordure = 0.5,  -- enfoncée de 0,2 : dessus à 0,3
	segment = 24,          -- longueur maximale d'une pierre de bordure droite
	segmentArc = 8,        -- corde maximale d'une pierre de bordure en arc
	jointure = 0.25,       -- petit joint entre deux pierres
	hauteurMur = 60,
	epaisseurMur = 4,
	touffues = 18,         -- plaques d'herbe touffue en périphérie
	fleursParPlaque = 2,   -- de 1 à fleursParPlaque + 1 fleurs par plaque
	galetsPlage = 26,
	xPeripherie = 110,     -- périphérie : au-delà de |x|
	zPeripherieNord = -92, -- ou au nord de cette ligne
	graine = 2026,
}

local function reglage(ctx, cle)
	local E = ctx.Equilibrage
	local sol = E and E.sol
	if type(sol) == "table" and type(sol[cle]) == "number" then
		return sol[cle]
	end
	return DEFAUTS[cle]
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	local BUDGET = reglage(ctx, "budget")
	local nbParts = 0

	-- toutes les parts passent par ici : compte le budget et refuse au-delà
	local function part(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return fabrique(parent, props)
	end

	local function hex(h, defaut)
		if Charte.hex then
			return Charte.hex(h)
		end
		return defaut
	end

	-- ===== palette =====
	local herbe = hex("6BD64A", Charte.herbe)
	local touffue = herbe:Lerp(Charte.jungle, 0.45)
	local terre = Charte.terre:Lerp(Charte.sable, 0.45)
	local sable = Charte.sable:Lerp(Charte.terre, 0.08)
	local pierre = Charte.pierre:Lerp(Charte.creme, 0.5)
	local teintesPierre = { pierre, pierre:Lerp(Charte.creme, 0.18), pierre:Lerp(Charte.ombre(pierre), 0.35) }

	local monde = Plan.monde
	local bord = monde.bord or 190
	local EP = reglage(ctx, "epaisseur")
	local marge = reglage(ctx, "marge")
	local couloirs = (Plan.decor and Plan.decor.couloirs) or { Vector3.new(-56, 0, 0), Vector3.new(0, 0, 0), Vector3.new(56, 0, 0) }
	local place = Plan.place
	local comptoir = Plan.comptoir
	local autel = Plan.autel
	local cratere = Plan.cratere

	local M_HERBE = Enum.Material.Grass
	local M_TOUFFUE = Enum.Material.LeafyGrass
	local M_TERRE = Enum.Material.Ground
	local M_SABLE = Enum.Material.Sand

	local terrainOk = Outils.terrainBloc ~= nil and Outils.terrainCylindre ~= nil

	-- remplissages au ras du sol : dessus à `dessus`, 4 studs d'épaisseur (une couche de voxels)
	local function plaque(x0, x1, z0, z1, materiau, dessus)
		if x1 - x0 <= 0 or z1 - z0 <= 0 then
			return
		end
		local h = 4 + dessus
		Outils.terrainBloc(CFrame.new((x0 + x1) / 2, dessus - h / 2, (z0 + z1) / 2), Vector3.new(x1 - x0, h, z1 - z0), materiau)
	end
	local function disque(x, z, rayon, materiau, dessus)
		local h = 4 + dessus
		Outils.terrainCylindre(CFrame.new(x, dessus - h / 2, z), h, rayon, materiau)
	end

	-- ===== 1. le terrain =====
	local ok, err = pcall(function()
		if not terrainOk then
			-- Outils sans terrain : une seule dalle d'herbe de secours
			part(Outils.bloc, dossier, {
				Name = "SolSecours",
				Size = Vector3.new(2 * bord, EP, 2 * bord),
				CFrame = CFrame.new(0, -EP / 2, 0),
				Color = herbe,
				Material = Enum.Material.Grass,
			})
			return
		end

		Outils.couleurTerrain(M_HERBE, herbe)
		Outils.couleurTerrain(M_TOUFFUE, touffue)
		Outils.couleurTerrain(M_TERRE, terre)
		Outils.couleurTerrain(M_SABLE, sable)
		pcall(function()
			workspace.Terrain.Decoration = true
		end)

		-- herbe sur tout le monde, jusqu'au-delà des murs invisibles
		local xA = math.min(monde.min.X, -bord) - marge
		local xB = math.max(monde.max.X, bord) + marge
		local zA = math.min(monde.min.Z, -bord) - marge
		local zB = math.max(monde.max.Z, bord) + marge
		Outils.terrainBloc(CFrame.new((xA + xB) / 2, -EP / 2, (zA + zB) / 2), Vector3.new(xB - xA, EP, zB - zA), M_HERBE)
	end)
	if not ok then
		warn("[Dino] Sol, terrain : " .. tostring(err))
	end

	-- ===== 2. les murs invisibles =====
	ok, err = pcall(function()
		local murs = Outils.dossier(dossier, "Murs")
		local H = reglage(ctx, "hauteurMur")
		local e = reglage(ctx, "epaisseurMur")
		local long = 2 * bord + 2 * e
		local defs = {
			{ Vector3.new(e, H, long), Vector3.new(-bord - e / 2, H / 2, 0) },
			{ Vector3.new(e, H, long), Vector3.new(bord + e / 2, H / 2, 0) },
			{ Vector3.new(long, H, e), Vector3.new(0, H / 2, -bord - e / 2) },
			{ Vector3.new(long, H, e), Vector3.new(0, H / 2, bord + e / 2) },
		}
		for _, d in ipairs(defs) do
			part(Outils.bloc, murs, {
				Name = "MurInvisible",
				Size = d[1],
				CFrame = CFrame.new(d[2]),
				Transparency = 1,
				CanCollide = true,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
		end
	end)
	if not ok then
		warn("[Dino] Sol, murs : " .. tostring(err))
	end

	-- ===== zones occupées (allées, bâtiments) : la périphérie décorée les évite =====
	local zP = reglage(ctx, "zPromenade")
	local xP = reglage(ctx, "xPromenade")
	local dC = reglage(ctx, "demiCouloir")
	local zCL = reglage(ctx, "couloirLoin")
	local zTL = reglage(ctx, "traverseLoin")
	local xT = reglage(ctx, "xTraverse")
	local rParvis = reglage(ctx, "rayonParvis")
	local rCratere = reglage(ctx, "rayonParvisCratere")
	local rNurserie = reglage(ctx, "rayonParvisNurserie")
	local dL = reglage(ctx, "demiLien")
	local dS = reglage(ctx, "demiSeuil")
	local zPlageSud = reglage(ctx, "zPlageSud")
	local zPlageNord = reglage(ctx, "zPlageNord")
	local zRivA, zRivB = 131, 145
	if Plan.riviere then
		zRivA = Plan.riviere.z - Plan.riviere.largeur / 2
		zRivB = Plan.riviere.z + Plan.riviere.largeur / 2
	end
	local base = Plan.base
	local demiBX = ((base and base.largeur) or 44) / 2
	local demiBZ = ((base and base.profondeur) or 50) / 2

	local function dansDisque(x, z, centre, rayon)
		local dx, dz = x - centre.X, z - centre.Z
		return dx * dx + dz * dz <= rayon * rayon
	end

	local function libre(x, z)
		if math.abs(x) >= 186 or math.abs(z) >= 186 then return false end
		if z > zPlageSud - 2 then return false end
		if math.abs(z) <= zP + 3 and math.abs(x) <= xP + 3 then return false end
		if Plan.nurserie and dansDisque(x, z, Plan.nurserie.centre, rNurserie + 3) then return false end
		if Plan.finTapis and dansDisque(x, z, Plan.finTapis.centre, rNurserie + 3) then return false end
		for _, b in ipairs(Plan.bases or {}) do
			if math.abs(x - b.centre.X) <= demiBX + 3 and math.abs(z - b.centre.Z) <= demiBZ + 3 then return false end
		end
		for _, c in ipairs(couloirs) do
			if math.abs(x - c.X) <= dC + 3 and math.abs(z) <= zTL + 3 then return false end
		end
		if math.abs(math.abs(z) - (zCL + zTL) / 2) <= (zTL - zCL) / 2 + 3 and math.abs(x) <= xT + 3 then return false end
		if place and dansDisque(x, z, place.centre, rParvis + 4) then return false end
		if cratere and dansDisque(x, z, cratere.centre, rCratere + 4) then return false end
		if comptoir then
			if math.abs(x - comptoir.centre.X) <= comptoir.taille.X / 2 + 4 and math.abs(z - comptoir.centre.Z) <= comptoir.taille.Z / 2 + 4 then return false end
		end
		if autel and dansDisque(x, z, autel.centre, autel.rayon + 4) then return false end
		if Plan.volcan and dansDisque(x, z, Plan.volcan.centre, Plan.volcan.rayon + 8) then return false end
		return true
	end

	local xPeri = reglage(ctx, "xPeripherie")
	local zPeriNord = reglage(ctx, "zPeripherieNord")
	local function peripherie(x, z)
		return math.abs(x) >= xPeri or z <= zPeriNord
	end

	local alea = Outils.aleatoire(reglage(ctx, "graine"))

	-- ===== 3. plaques d'herbe touffue en périphérie (et leurs fleurs, posées plus loin) =====
	local plaques = {}
	ok, err = pcall(function()
		if not terrainOk then return end
		local voulues = reglage(ctx, "touffues")
		local dessus = reglage(ctx, "dessusTouffue")
		local essais = 0
		while #plaques < voulues and essais < 1500 do
			essais = essais + 1
			local x = alea:NextNumber(-184, 184)
			local z = alea:NextNumber(-184, zPlageSud)
			local r = alea:NextNumber(5, 11)
			local bon = peripherie(x, z) and libre(x, z)
				and libre(x + r, z) and libre(x - r, z) and libre(x, z + r) and libre(x, z - r)
			if bon then
				for _, p in ipairs(plaques) do
					if (p.x - x) * (p.x - x) + (p.z - z) * (p.z - z) < (p.r + r + 6) * (p.r + r + 6) then
						bon = false
						break
					end
				end
			end
			if bon then
				disque(x, z, r, M_TOUFFUE, dessus)
				-- une petite plaque satellite pour casser le rond
				local a = alea:NextNumber(0, 2 * math.pi)
				local r2 = r * alea:NextNumber(0.45, 0.65)
				local x2, z2 = x + math.cos(a) * r * 0.9, z + math.sin(a) * r * 0.9
				if libre(x2, z2) then
					disque(x2, z2, r2, M_TOUFFUE, dessus)
				end
				table.insert(plaques, { x = x, z = z, r = r })
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, herbe touffue : " .. tostring(err))
	end

	-- ===== 4. terre battue sous les bâtiments (pas de brins d'herbe à travers les dalles) =====
	ok, err = pcall(function()
		if not terrainOk then return end
		local d = reglage(ctx, "dessusTerre")
		for _, b in ipairs(Plan.bases or {}) do
			local c = b.centre
			plaque(c.X - demiBX + 1, c.X + demiBX - 1, c.Z - demiBZ + 1, c.Z + demiBZ - 1, M_TERRE, d)
		end
		if comptoir then
			local c, t = comptoir.centre, comptoir.taille
			plaque(c.X - t.X / 2 + 0.5, c.X + t.X / 2 - 0.5, c.Z - t.Z / 2 + 0.5, c.Z + t.Z / 2 - 0.5, M_TERRE, d)
		end
		if autel then
			disque(autel.centre.X, autel.centre.Z, autel.rayon, M_TERRE, d)
		end
	end)
	if not ok then
		warn("[Dino] Sol, terre battue : " .. tostring(err))
	end

	-- ===== 5. les allées de sable, au ras de l'herbe =====
	ok, err = pcall(function()
		if not terrainOk then return end
		local d = reglage(ctx, "dessusAllee")
		-- promenade le long du Tapis (le Tapis et ses rebords sont posés dessus)
		plaque(-xP, xP, -zP, zP, M_SABLE, d)
		-- parvis de la Nurserie et de la Fin du tapis
		if Plan.nurserie then
			disque(Plan.nurserie.centre.X, Plan.nurserie.centre.Z, rNurserie, M_SABLE, d)
		end
		if Plan.finTapis then
			disque(Plan.finTapis.centre.X, Plan.finTapis.centre.Z, rNurserie, M_SABLE, d)
		end
		-- seuils devant l'entrée de chaque Base
		local bi = (base and base.bordInterieur) or 18
		for _, b in ipairs(Plan.bases or {}) do
			local x = b.centre.X
			if b.centre.Z > 0 then
				plaque(x - dS, x + dS, zP, bi + 2, M_SABLE, d)
			else
				plaque(x - dS, x + dS, -bi - 2, -zP, M_SABLE, d)
			end
		end
		-- couloirs entre les Bases et traverses (nord : vers le Cratère ; sud : vers la Place)
		for _, c in ipairs(couloirs) do
			plaque(c.X - dC, c.X + dC, zP, zCL, M_SABLE, d)
			plaque(c.X - dC, c.X + dC, -zCL, -zP, M_SABLE, d)
		end
		plaque(-xT, xT, zCL, zTL, M_SABLE, d)
		plaque(-xT, xT, -zTL, -zCL, M_SABLE, d)
		-- parvis de la Place et du Cratère
		if place then
			disque(place.centre.X, place.centre.Z, rParvis, M_SABLE, d)
			-- liens vers le Comptoir (ouest) et l'Autel (est)
			if comptoir then
				local zc = comptoir.centre.Z
				plaque(comptoir.centre.X + comptoir.taille.X / 2 - 3, place.centre.X - rParvis + 4, zc - dL, zc + dL, M_SABLE, d)
			end
			if autel then
				local zc = autel.centre.Z
				plaque(place.centre.X + rParvis - 4, autel.centre.X - autel.rayon + 1, zc - dL, zc + dL, M_SABLE, d)
			end
		end
		if cratere then
			disque(cratere.centre.X, cratere.centre.Z, rCratere, M_SABLE, d)
		end
		-- plages de part et d'autre de la rivière (la rivière remplace le reste)
		local xR = 166
		plaque(-xR, xR, zPlageSud, zRivA, M_SABLE, d)
		plaque(-xR, xR, zRivB, zPlageNord, M_SABLE, d)
	end)
	if not ok then
		warn("[Dino] Sol, allées : " .. tostring(err))
	end

	-- ===== 6. bordures de galets le long des allées =====
	local LB = reglage(ctx, "largeurBordure")
	local HB = reglage(ctx, "hauteurBordure")
	local SEG = reglage(ctx, "segment")
	local SEGA = reglage(ctx, "segmentArc")
	local JOINT = reglage(ctx, "jointure")
	local yBordure = 0.3 - HB / 2

	ok, err = pcall(function()
		local bordures = Outils.dossier(dossier, "Bordures")
		local rang = 0

		local function pierreDroite(x0, z0, x1, z1)
			local dx, dz = x1 - x0, z1 - z0
			local long = math.sqrt(dx * dx + dz * dz) - JOINT
			if long <= 0.3 then
				return
			end
			rang = rang + 1
			local a = math.atan2(dz, dx)
			part(Outils.bloc, bordures, {
				Name = "Bordure",
				Size = Vector3.new(long, HB, LB),
				CFrame = CFrame.new((x0 + x1) / 2, yBordure, (z0 + z1) / 2) * CFrame.Angles(0, -a, 0),
				Color = teintesPierre[1 + rang % #teintesPierre],
				Material = Enum.Material.Cobblestone,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
		end

		-- ligne droite découpée en pierres d'au plus SEG studs
		local function ligne(x0, z0, x1, z1)
			local dx, dz = x1 - x0, z1 - z0
			local long = math.sqrt(dx * dx + dz * dz)
			if long <= 0.3 then
				return
			end
			local n = math.max(1, math.ceil(long / SEG))
			for i = 0, n - 1 do
				local t0, t1 = i / n, (i + 1) / n
				pierreDroite(x0 + dx * t0, z0 + dz * t0, x0 + dx * t1, z0 + dz * t1)
			end
		end

		-- ligne à z constant, de xa à xb, avec des ouvertures { {x0, x1}, ... } (triées)
		local function ligneOuverte(z, xa, xb, ouvertures)
			local x = xa
			for _, o in ipairs(ouvertures) do
				if o[1] > x and o[1] < xb then
					ligne(x, z, o[1], z)
				end
				if o[2] > x then
					x = o[2]
				end
			end
			if xb > x then
				ligne(x, z, xb, z)
			end
		end

		-- arc de cercle (degrés ; x = cx + r cos a, z = cz + r sin a) en cordes d'au plus SEGA studs
		local function arc(cx, cz, r, a0, a1)
			local longueur = r * math.rad(a1 - a0)
			if longueur <= 0.3 then
				return
			end
			local n = math.max(1, math.ceil(longueur / SEGA))
			for i = 0, n - 1 do
				local b0 = math.rad(a0 + (a1 - a0) * i / n)
				local b1 = math.rad(a0 + (a1 - a0) * (i + 1) / n)
				pierreDroite(cx + r * math.cos(b0), cz + r * math.sin(b0), cx + r * math.cos(b1), cz + r * math.sin(b1))
			end
		end

		-- demi-angle (degrés) sous lequel une allée de demi-largeur h entre dans un cercle de rayon r
		local function demiAngle(h, r)
			return math.deg(math.asin(math.min(1, h / r)))
		end

		-- promenade : ouvertures des couloirs et des seuils
		local ouvertures = {}
		for _, c in ipairs(couloirs) do
			table.insert(ouvertures, { c.X - dC, c.X + dC })
		end
		for _, b in ipairs(Plan.bases or {}) do
			if b.centre.Z > 0 then
				table.insert(ouvertures, { b.centre.X - dS, b.centre.X + dS })
			end
		end
		table.sort(ouvertures, function(p, q) return p[1] < q[1] end)
		local xFinP = xP
		if Plan.finTapis then
			local dxN = math.sqrt(math.max(0, rNurserie * rNurserie - zP * zP))
			xFinP = math.min(xP, Plan.finTapis.centre.X - dxN)
		end
		local xDebP = -xP
		if Plan.nurserie then
			local dxN = math.sqrt(math.max(0, rNurserie * rNurserie - zP * zP))
			xDebP = math.max(-xP, Plan.nurserie.centre.X + dxN)
		end
		ligneOuverte(zP, xDebP, xFinP, ouvertures)
		ligneOuverte(-zP, xDebP, xFinP, ouvertures)

		-- parvis de la Nurserie (ouvert à l'est) et de la Fin du tapis (ouvert à l'ouest)
		local aP = demiAngle(zP, rNurserie)
		if Plan.nurserie then
			arc(Plan.nurserie.centre.X, Plan.nurserie.centre.Z, rNurserie, aP, 360 - aP)
		end
		if Plan.finTapis then
			arc(Plan.finTapis.centre.X, Plan.finTapis.centre.Z, rNurserie, aP - 180, 180 - aP)
		end

		-- couloirs : les bords extérieurs des couloirs extrêmes longent aussi le bout des traverses
		local xMinC, xMaxC = 0, 0
		for _, c in ipairs(couloirs) do
			xMinC = math.min(xMinC, c.X)
			xMaxC = math.max(xMaxC, c.X)
		end
		for _, c in ipairs(couloirs) do
			for _, sx in ipairs({ -1, 1 }) do
				local x = c.X + sx * dC
				local zFin = zCL
				if (c.X == xMinC and sx < 0) or (c.X == xMaxC and sx > 0) then
					zFin = zTL
				end
				ligne(x, zP, x, zFin)
				ligne(x, -zP, x, -zFin)
			end
		end

		-- traverses : bord côté Tapis ouvert sur les couloirs, bord opposé ouvert sur le parvis
		local ouvCouloirs = {}
		for _, c in ipairs(couloirs) do
			if c.X ~= xMinC and c.X ~= xMaxC then
				table.insert(ouvCouloirs, { c.X - dC, c.X + dC })
			end
		end
		table.sort(ouvCouloirs, function(p, q) return p[1] < q[1] end)
		ligneOuverte(zCL, xMinC + dC, xMaxC - dC, ouvCouloirs)
		ligneOuverte(-zCL, xMinC + dC, xMaxC - dC, ouvCouloirs)
		if place then
			local dz = math.abs(place.centre.Z - zTL)
			local ox = math.sqrt(math.max(0, rParvis * rParvis - dz * dz))
			ligneOuverte(zTL, -xT, xT, { { place.centre.X - ox, place.centre.X + ox } })
		else
			ligne(-xT, zTL, xT, zTL)
		end
		if cratere then
			local dz = math.abs(cratere.centre.Z + zTL)
			local ox = math.sqrt(math.max(0, rCratere * rCratere - dz * dz))
			ligneOuverte(-zTL, -xT, xT, { { cratere.centre.X - ox, cratere.centre.X + ox } })
		else
			ligne(-xT, -zTL, xT, -zTL)
		end

		-- parvis de la Place : ouvert au nord (traverse), à l'ouest (Comptoir) et à l'est (Autel)
		if place then
			local cx, cz = place.centre.X, place.centre.Z
			local dz = math.abs(cz - zTL)
			local aNord = math.deg(math.atan2(-dz, math.sqrt(math.max(0, rParvis * rParvis - dz * dz))))
			local aEst0, aEst1 = 0, 0
			local aOuest0, aOuest1 = 180, 180
			if autel then
				local z0 = autel.centre.Z - dL - cz
				local z1 = autel.centre.Z + dL - cz
				aEst0 = math.deg(math.asin(math.max(-1, math.min(1, z0 / rParvis))))
				aEst1 = math.deg(math.asin(math.max(-1, math.min(1, z1 / rParvis))))
			end
			if comptoir then
				local z0 = comptoir.centre.Z - dL - cz
				local z1 = comptoir.centre.Z + dL - cz
				aOuest0 = 180 - math.deg(math.asin(math.max(-1, math.min(1, z1 / rParvis))))
				aOuest1 = 180 - math.deg(math.asin(math.max(-1, math.min(1, z0 / rParvis))))
			end
			-- aNord est l'angle de la sortie nord-est (entre -90 et 0) ; la sortie nord-ouest est son symétrique
			local aNordOuest = -180 - aNord
			arc(cx, cz, rParvis, aNord, aEst0)
			arc(cx, cz, rParvis, aEst1, aOuest0)
			arc(cx, cz, rParvis, aOuest1, 360 + aNordOuest)

			-- liens : bords le long du Comptoir et de l'Autel
			if comptoir then
				local xBord = comptoir.centre.X + comptoir.taille.X / 2
				for _, sz in ipairs({ -1, 1 }) do
					local z = comptoir.centre.Z + sz * dL
					local dzc = z - cz
					local xRing = cx - math.sqrt(math.max(0, rParvis * rParvis - dzc * dzc))
					ligne(xBord, z, xRing, z)
				end
			end
			if autel then
				for _, sz in ipairs({ -1, 1 }) do
					local z = autel.centre.Z + sz * dL
					local dzc = z - cz
					local xRing = cx + math.sqrt(math.max(0, rParvis * rParvis - dzc * dzc))
					local dza = z - autel.centre.Z
					local xAutel = autel.centre.X - math.sqrt(math.max(0, autel.rayon * autel.rayon - dza * dza))
					ligne(xRing, z, xAutel, z)
				end
			end
		end

		-- parvis du Cratère : ouvert au sud (traverse nord)
		if cratere then
			local cx, cz = cratere.centre.X, cratere.centre.Z
			local dz = math.abs(-zTL - cz)
			local aSud = math.deg(math.atan2(dz, math.sqrt(math.max(0, rCratere * rCratere - dz * dz))))
			arc(cx, cz, rCratere, 180 - aSud, 360 + aSud)
		end
	end)
	if not ok then
		warn("[Dino] Sol, bordures : " .. tostring(err))
	end

	-- ===== 7. détails : galets sur les plages, fleurs sur l'herbe touffue (dessus <= 0,3) =====
	ok, err = pcall(function()
		local decor = Outils.dossier(dossier, "Decor")

		-- disque plat posé au sol (axe du cylindre vertical)
		local function rond(nom, diametre, epaisseur, x, z, couleur, materiau, yBas)
			return part(Outils.cylindre, decor, {
				Name = nom,
				Size = Vector3.new(epaisseur, diametre, diametre),
				CFrame = CFrame.new(x, (yBas or 0) + epaisseur / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
				Color = couleur,
				Material = materiau,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
		end

		-- galets plats sur les plages, par petits groupes
		local voulus = reglage(ctx, "galetsPlage")
		local poses, essais = 0, 0
		while poses < voulus and essais < 200 and nbParts < BUDGET do
			essais = essais + 1
			local x = alea:NextNumber(-150, 150)
			local surRive = alea:NextNumber() < 0.5
			local z
			if surRive then
				z = alea:NextNumber(zRivA - 5, zRivA - 1.5)
			else
				z = alea:NextNumber(zRivB + 1.5, math.min(zPlageNord, zRivB + 4.5))
			end
			local loinPlace = not (place and dansDisque(x, z, place.centre, rParvis + 2))
			if loinPlace then
				local n = alea:NextInteger(1, 3)
				for _ = 1, n do
					if poses >= voulus then
						break
					end
					local gx = x + alea:NextNumber(-1.6, 1.6)
					local gz = z + alea:NextNumber(-1.2, 1.2)
					local couleur = teintesPierre[alea:NextInteger(1, #teintesPierre)]
					rond("Galet", alea:NextNumber(0.7, 1.8), alea:NextNumber(0.18, 0.3), gx, gz, couleur, Enum.Material.Slate, -0.02)
					poses = poses + 1
				end
			end
		end

		-- fleurs plates sur les plaques d'herbe touffue
		local couleursFleurs = { Charte.creme, Charte.dore, Charte.violet, Charte.alerte, Charte.gemme }
		if ctx.Style and ctx.Style.couleurs and ctx.Style.couleurs.revenu then
			couleursFleurs[2] = ctx.Style.couleurs.revenu
		end
		local parPlaque = reglage(ctx, "fleursParPlaque")
		for _, p in ipairs(plaques) do
			local n = alea:NextInteger(1, math.max(1, parPlaque + 1))
			for _ = 1, n do
				if nbParts + 2 > BUDGET then
					break
				end
				local a = alea:NextNumber(0, 2 * math.pi)
				local dist = alea:NextNumber(0, p.r * 0.6)
				local x, z = p.x + math.cos(a) * dist, p.z + math.sin(a) * dist
				local couleur = couleursFleurs[alea:NextInteger(1, #couleursFleurs)]
				local coeur = Charte.dore
				if couleur == couleursFleurs[2] then
					coeur = Charte.creme
				end
				local d = alea:NextNumber(1, 1.4)
				rond("Petales", d, 0.18, x, z, couleur, Enum.Material.SmoothPlastic, 0.04)
				rond("Coeur", d * 0.38, 0.26, x, z, coeur, Enum.Material.SmoothPlastic, 0.04)
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, décor : " .. tostring(err))
	end

	dossier:SetAttribute("Parts", nbParts)
end

return M
