-- Constructeur Sol (plan v2 « plus d'air », STYLE.md §4) : le sol de tout Plan.monde en TERRAIN Roblox.
-- Herbe Grass vert vif (dessus à Y = 0, brins d'herbe activés), sous-bois d'herbe touffue (LeafyGrass) sous
-- les jungles et plaques touffues fleuries en périphérie, terre battue (Ground) sous les bâtiments.
-- Réseau de chemins de sable (Sand) au ras de l'herbe, tout calculé depuis Plan :
--   promenades de part et d'autre du Tapis sur toute sa longueur, terminées en demi-lune devant la Nurserie
--   et la Grande Porte ; allées entre les Bases (Plan.allees) jusqu'aux chemins de ronde derrière les Bases ;
--   contre-allées le long des Bases extrêmes ; liaison Tapis <-> Place par l'allée x = 0 ; anneau de la Place,
--   liens vers le Comptoir et l'Autel ; parvis du Cratère ; sentier vers la rivière et ses plages.
-- Sentiers de terre (Ground) avec pas japonais vers le Volcan et vers les plages.
-- Bordures de galets posées automatiquement là où un chemin de sable touche l'herbe (ouvertures aux croisements).
-- Murs invisibles aux bords (Plan.monde.bord, bordNord, bordSud).
local M = {}

-- réglages par défaut (surchargés par Equilibrage.sol s'il existe) : largeurs et marges, jamais de position
local DEFAUTS = {
	budget = 340,           -- parts au maximum pour ce constructeur
	epaisseur = 8,          -- épaisseur du terrain d'herbe
	marge = 12,             -- l'herbe dépasse les murs invisibles de cette marge
	dessusAllee = 0.06,     -- dessus des allées de sable (au ras de l'herbe)
	dessusSentier = 0.05,   -- dessus des sentiers de terre
	dessusTerre = 0.04,     -- dessus de la terre battue sous les bâtiments
	dessusTouffue = 0.02,   -- dessus des plaques d'herbe touffue
	margeJungle = 2,        -- la demi-lune des bouts du Tapis s'arrête à cette distance des jungles
	ecartRonde = 3,         -- herbe entre le fond des Bases et le chemin de ronde
	largeurRonde = 8,       -- chemin de ronde derrière les Bases
	ecartContre = 2,        -- herbe entre les Bases extrêmes et la contre-allée
	largeurContre = 10,     -- contre-allées le long des Bases extrêmes
	anneauPlace = 6,        -- l'anneau de sable dépasse la Place de ... studs
	anneauCratere = 6,      -- parvis du Cratère : rayon + ...
	demiLien = 6,           -- liens Place -> Comptoir / Autel, Cratère -> chemin de ronde
	margeBatiment = 3,      -- sable autour du Comptoir et de l'Autel
	demiRiviere = 5,        -- sentier Place -> rivière
	plage = 6,              -- plage nord de la rivière (vers la Place)
	demiSentier = 3.5,      -- sentiers de terre (Volcan, plages)
	largeurBordure = 1,
	hauteurBordure = 0.5,   -- enfoncée de 0,2 : dessus à 0,3
	pas = 1,                -- pas d'échantillonnage des bords de chemin
	segment = 16,           -- longueur maximale d'une pierre de bordure droite
	segmentArc = 7,         -- corde maximale d'une pierre de bordure en arc
	jointure = 0.3,         -- petit joint entre deux pierres
	hauteurMur = 80,
	epaisseurMur = 4,
	touffues = 22,          -- plaques d'herbe touffue en périphérie
	fleursParPlaque = 2,    -- de 1 à fleursParPlaque + 1 fleurs par plaque
	galetsPlage = 24,
	pasJaponais = 4.5,      -- écart entre deux pas japonais sur un sentier
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
	if not (Charte and Outils and Plan and dossier and Plan.monde) then
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
	local touffue = herbe:Lerp(Charte.jungle, 0.5)
	local terre = Charte.terre:Lerp(Charte.sable, 0.35)
	local sable = Charte.sable:Lerp(Charte.terre, 0.06)
	local pierre = Charte.pierre:Lerp(Charte.creme, 0.5)
	local teintesPierre = { pierre, pierre:Lerp(Charte.creme, 0.2), pierre:Lerp(Charte.ombre(pierre), 0.4) }

	local M_HERBE = Enum.Material.Grass
	local M_TOUFFUE = Enum.Material.LeafyGrass
	local M_TERRE = Enum.Material.Ground
	local M_SABLE = Enum.Material.Sand

	-- ===== lecture du Plan =====
	local monde = Plan.monde
	local bordX = monde.bord or math.max(math.abs(monde.min.X), math.abs(monde.max.X)) + 13
	local bordN = monde.bordNord or (monde.min.Z - 13)
	local bordS = monde.bordSud or (monde.max.Z + 13)
	local tapis = Plan.tapis
	local promenade = Plan.promenade or { zMin = (tapis and tapis.emprise) or 9.5, zMax = 27 }
	local base = Plan.base or { largeur = 44, profondeur = 50 }
	local bases = Plan.bases or {}
	local allees = Plan.allees
	local place = Plan.place
	local comptoir = Plan.comptoir
	local autel = Plan.autel
	local cratere = Plan.cratere
	local volcan = Plan.volcan
	local riviere = Plan.riviere
	local nurserie = Plan.nurserie
	local finTapis = Plan.finTapis
	local falaises = Plan.falaises or {}
	local decor = Plan.decor or {}
	local demiBX = base.largeur / 2
	local demiBZ = base.profondeur / 2

	-- limites de la zone jouable (intérieur des falaises)
	local xJeuMin = (falaises.ouest and falaises.ouest.xMax) or monde.min.X
	local xJeuMax = (falaises.est and falaises.est.xMin) or monde.max.X
	local zJeuMin = (falaises.nord and falaises.nord.zMax) or monde.min.Z
	local zJeuMax = (falaises.sud and falaises.sud.zMin) or monde.max.Z

	-- étendue des Bases (x) et de leurs rangées (|z|)
	local xBasesMax, zBasesFond = 0, promenade.zMax + base.profondeur
	for _, b in ipairs(bases) do
		xBasesMax = math.max(xBasesMax, math.abs(b.centre.X) + demiBX)
		zBasesFond = math.max(zBasesFond, math.abs(b.centre.Z) + demiBZ)
	end

	-- ===== les zones : chemins (sable / terre) et obstacles (bâtiments, eau, falaises) =====
	-- rect : {x0, x1, z0, z1} ; disque : {x, z, r} ; ruban : segment (ax, az) -> (bx, bz) de demi-largeur l, bouts ronds
	local chemins = {}   -- dans l'ordre de remplissage
	local obstacles = {}

	local function rect(x0, x1, z0, z1, mat, bordure)
		local z = { g = "rect", x0 = math.min(x0, x1), x1 = math.max(x0, x1), z0 = math.min(z0, z1), z1 = math.max(z0, z1), mat = mat, bordure = bordure }
		return z
	end
	local function disque(x, z, r, mat, bordure)
		return { g = "disque", x = x, z = z, r = r, mat = mat, bordure = bordure }
	end
	local function ruban(ax, az, bx, bz, l, mat)
		return { g = "ruban", ax = ax, az = az, bx = bx, bz = bz, l = l, mat = mat, bordure = false }
	end
	local function chemin(zone)
		table.insert(chemins, zone)
		return zone
	end
	local function obstacle(zone)
		table.insert(obstacles, zone)
		return zone
	end

	-- vrai si (x, z) est dans la zone agrandie de m (m < 0 : rétrécie)
	local function dedans(zone, x, z, m)
		m = m or 0
		if zone.g == "rect" then
			return x >= zone.x0 - m and x <= zone.x1 + m and z >= zone.z0 - m and z <= zone.z1 + m
		elseif zone.g == "disque" then
			local dx, dz = x - zone.x, z - zone.z
			local r = zone.r + m
			return r > 0 and dx * dx + dz * dz <= r * r
		else
			local vx, vz = zone.bx - zone.ax, zone.bz - zone.az
			local L2 = vx * vx + vz * vz
			local t = 0
			if L2 > 0 then
				t = math.max(0, math.min(1, ((x - zone.ax) * vx + (z - zone.az) * vz) / L2))
			end
			local px, pz = zone.ax + vx * t - x, zone.az + vz * t - z
			local r = zone.l + m
			return r > 0 and px * px + pz * pz <= r * r
		end
	end
	local function dansListe(liste, x, z, m, sauf)
		for _, zone in ipairs(liste) do
			if zone ~= sauf and dedans(zone, x, z, m) then
				return true
			end
		end
		return false
	end

	-- --- obstacles ---
	for _, b in ipairs(bases) do
		obstacle(rect(b.centre.X - demiBX, b.centre.X + demiBX, b.centre.Z - demiBZ, b.centre.Z + demiBZ))
	end
	if tapis then
		obstacle(rect(tapis.debut.X, tapis.fin.X, -tapis.emprise, tapis.emprise))
	end
	if nurserie then obstacle(disque(nurserie.centre.X, nurserie.centre.Z, nurserie.rayon)) end
	if finTapis then obstacle(disque(finTapis.centre.X, finTapis.centre.Z, finTapis.rayon)) end
	if place then obstacle(disque(place.centre.X, place.centre.Z, place.rayon)) end
	if comptoir then
		obstacle(rect(comptoir.centre.X - comptoir.taille.X / 2, comptoir.centre.X + comptoir.taille.X / 2,
			comptoir.centre.Z - comptoir.taille.Z / 2, comptoir.centre.Z + comptoir.taille.Z / 2))
	end
	if autel then obstacle(disque(autel.centre.X, autel.centre.Z, autel.rayon)) end
	if cratere then obstacle(disque(cratere.centre.X, cratere.centre.Z, cratere.rayon)) end
	if volcan then obstacle(disque(volcan.centre.X, volcan.centre.Z, volcan.rayon)) end
	if riviere then obstacle(rect(riviere.xMin, riviere.xMax, riviere.zMin, riviere.zMax)) end
	for _, f in pairs(falaises) do
		obstacle(rect(f.xMin, f.xMax, f.zMin, f.zMax))
	end

	-- --- sentiers de terre (remplis en premier : le sable les recouvre aux jonctions) ---
	local dSentier = reglage(ctx, "demiSentier")
	local sentiers = {}
	local zRondeA = zBasesFond + reglage(ctx, "ecartRonde")
	local zRondeB = zRondeA + reglage(ctx, "largeurRonde")
	local xContreA = xBasesMax + reglage(ctx, "ecartContre")
	local xContreB = xContreA + reglage(ctx, "largeurContre")
	local xContre = (xContreA + xContreB) / 2
	local rCratere = 0
	if cratere then
		rCratere = cratere.rayon + reglage(ctx, "anneauCratere")
	end
	-- vers le pied du Volcan, depuis le parvis du Cratère
	if cratere and volcan then
		local zA = cratere.centre.Z - rCratere + 2
		local zB = volcan.centre.Z + volcan.rayon
		if zA > zB then
			table.insert(sentiers, chemin(ruban(cratere.centre.X, zA, volcan.centre.X, zB, dSentier, M_TERRE)))
		end
	end
	-- vers les plages : des coins sud du chemin de ronde, en biais vers la rivière
	local zPlageA, zPlageB
	if riviere then
		zPlageA = riviere.zMin - reglage(ctx, "plage")
		zPlageB = riviere.zMin + 2
		if decor.jungleOuest then
			zPlageA = math.min(zPlageA, decor.jungleOuest.max.Z)
		end
		for _, s in ipairs({ -1, 1 }) do
			local ax, az = s * xContre, (zRondeA + zRondeB) / 2
			local bx = s * math.min(xContreB + (zPlageA - az) * 0.35, xJeuMax - 30)
			table.insert(sentiers, chemin(ruban(ax, az, bx, zPlageA + 1, dSentier, M_TERRE)))
		end
	end

	-- --- chemins de sable (bordés de galets) ---
	-- promenades des deux côtés du Tapis (et dessous), en « stade » : demi-lunes devant Nurserie et Grande Porte
	local zP = promenade.zMax
	local xBout = xContreB + zP
	if nurserie then xBout = math.abs(nurserie.centre.X) end
	if finTapis then xBout = math.max(xBout, math.abs(finTapis.centre.X)) end
	local margeJ = reglage(ctx, "margeJungle")
	if decor.jungleOuest then
		xBout = math.min(xBout, math.abs(decor.jungleOuest.max.X) - margeJ - zP)
	end
	if decor.jungleEst then
		xBout = math.min(xBout, math.abs(decor.jungleEst.min.X) - margeJ - zP)
	end
	chemin(rect(-xBout, xBout, -zP, zP, M_SABLE, true))
	chemin(disque(-xBout, 0, zP, M_SABLE, true))
	chemin(disque(xBout, 0, zP, M_SABLE, true))

	-- allées entre les Bases, de la promenade au chemin de ronde (nord et sud)
	if allees then
		for _, ax in ipairs(allees.x) do
			local l = allees.largeur / 2
			chemin(rect(ax - l, ax + l, allees.zMin - 1, zRondeA + 1, M_SABLE, true))
			chemin(rect(ax - l, ax + l, -zRondeA - 1, -allees.zMin + 1, M_SABLE, true))
		end
	end
	-- chemins de ronde derrière les Bases et contre-allées le long des Bases extrêmes
	chemin(rect(-xContreB, xContreB, zRondeA, zRondeB, M_SABLE, true))
	chemin(rect(-xContreB, xContreB, -zRondeB, -zRondeA, M_SABLE, true))
	for _, s in ipairs({ -1, 1 }) do
		chemin(rect(s * xContreA, s * xContreB, zP - 1, zRondeA + 1, M_SABLE, true))
		chemin(rect(s * xContreA, s * xContreB, -zRondeA - 1, -zP + 1, M_SABLE, true))
	end

	-- la Place : anneau, liens vers le Comptoir et l'Autel, sentier vers la rivière
	local dLien = reglage(ctx, "demiLien")
	local mBat = reglage(ctx, "margeBatiment")
	local rPlace = 0
	if place then
		rPlace = place.rayon + reglage(ctx, "anneauPlace")
		chemin(disque(place.centre.X, place.centre.Z, rPlace, M_SABLE, true))
		-- l'allée x = 0 rejoint déjà le chemin de ronde ; si l'anneau ne le touche pas, on prolonge
		if place.centre.Z - rPlace > zRondeB then
			chemin(rect(place.centre.X - dLien, place.centre.X + dLien, zRondeB - 1, place.centre.Z - rPlace + 2, M_SABLE, true))
		end
		if comptoir then
			local cx = comptoir.centre.X + comptoir.taille.X / 2
			chemin(rect(cx - 1, place.centre.X - rPlace + 3, comptoir.centre.Z - dLien, comptoir.centre.Z + dLien, M_SABLE, true))
			chemin(rect(comptoir.centre.X - comptoir.taille.X / 2 - mBat, comptoir.centre.X + comptoir.taille.X / 2 + mBat,
				comptoir.centre.Z - comptoir.taille.Z / 2 - mBat, comptoir.centre.Z + comptoir.taille.Z / 2 + mBat, M_SABLE, true))
		end
		if autel then
			chemin(rect(place.centre.X + rPlace - 3, autel.centre.X - autel.rayon + 1, autel.centre.Z - dLien, autel.centre.Z + dLien, M_SABLE, true))
			chemin(disque(autel.centre.X, autel.centre.Z, autel.rayon + mBat, M_SABLE, true))
		end
		if riviere then
			local dR = reglage(ctx, "demiRiviere")
			chemin(rect(place.centre.X - dR, place.centre.X + dR, place.centre.Z + rPlace - 3, zPlageA + 1, M_SABLE, true))
		end
	end
	-- plages de la rivière (sans bordure : le sable se fond dans l'herbe)
	if riviere then
		chemin(rect(xJeuMin, xJeuMax, zPlageA, zPlageB, M_SABLE, false))
		chemin(rect(xJeuMin, xJeuMax, riviere.zMax - 2, zJeuMax + 2, M_SABLE, false))
	end
	-- le Cratère : parvis relié au chemin de ronde nord
	if cratere then
		chemin(disque(cratere.centre.X, cratere.centre.Z, rCratere, M_SABLE, true))
		local zHaut = cratere.centre.Z + rCratere - 2
		if zHaut < -zRondeB then
			chemin(rect(cratere.centre.X - dLien, cratere.centre.X + dLien, zHaut, -zRondeB + 1, M_SABLE, true))
		end
	end

	-- ===== remplissages de terrain =====
	local terrainOk = Outils.terrainBloc ~= nil and Outils.terrainCylindre ~= nil
	local EP = reglage(ctx, "epaisseur")
	local marge = reglage(ctx, "marge")

	-- une couche au ras du sol : dessus à `dessus`, 4 studs d'épaisseur (une couche de voxels)
	local function remplirZone(zone, materiau, dessus)
		local h = 4 + dessus
		local y = dessus - h / 2
		if zone.g == "rect" then
			if zone.x1 - zone.x0 > 0 and zone.z1 - zone.z0 > 0 then
				Outils.terrainBloc(CFrame.new((zone.x0 + zone.x1) / 2, y, (zone.z0 + zone.z1) / 2), Vector3.new(zone.x1 - zone.x0, h, zone.z1 - zone.z0), materiau)
			end
		elseif zone.g == "disque" then
			Outils.terrainCylindre(CFrame.new(zone.x, y, zone.z), h, zone.r, materiau)
		else
			local dx, dz = zone.bx - zone.ax, zone.bz - zone.az
			local L = math.sqrt(dx * dx + dz * dz)
			if L > 0 then
				local a = math.atan2(dz, dx)
				Outils.terrainBloc(CFrame.new((zone.ax + zone.bx) / 2, y, (zone.az + zone.bz) / 2) * CFrame.Angles(0, -a, 0), Vector3.new(L, h, 2 * zone.l), materiau)
			end
			Outils.terrainCylindre(CFrame.new(zone.ax, y, zone.az), h, zone.l, materiau)
			Outils.terrainCylindre(CFrame.new(zone.bx, y, zone.bz), h, zone.l, materiau)
		end
	end

	local alea = Outils.aleatoire(reglage(ctx, "graine"))

	-- 1. l'herbe sur tout le monde, jusqu'au-delà des murs invisibles
	local ok, err = pcall(function()
		if not terrainOk then
			part(Outils.bloc, dossier, {
				Name = "SolSecours",
				Size = Vector3.new(2 * bordX, EP, bordS - bordN),
				CFrame = CFrame.new(0, -EP / 2, (bordN + bordS) / 2),
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
		local xA, xB = -bordX - marge, bordX + marge
		local zA, zB = bordN - marge, bordS + marge
		Outils.terrainBloc(CFrame.new((xA + xB) / 2, -EP / 2, (zA + zB) / 2), Vector3.new(xB - xA, EP, zB - zA), M_HERBE)
	end)
	if not ok then
		warn("[Dino] Sol, terrain : " .. tostring(err))
	end

	-- 2. sous-bois d'herbe touffue sous les jungles, au bord festonné
	ok, err = pcall(function()
		if not terrainOk then return end
		local d = reglage(ctx, "dessusTouffue")
		for _, nom in ipairs({ "jungleOuest", "jungleEst", "jungleNord" }) do
			local j = decor[nom]
			if j then
				local zone = rect(j.min.X, j.max.X, j.min.Z, j.max.Z)
				remplirZone(zone, M_TOUFFUE, d)
				-- festons sur les bords tournés vers le centre du monde
				local cx, cz = (j.min.X + j.max.X) / 2, (j.min.Z + j.max.Z) / 2
				local bordsInt = {}
				if math.abs(cx) > math.abs(cz) then
					local xi = j.max.X
					if cx > 0 then xi = j.min.X end
					table.insert(bordsInt, { xi, j.min.Z, xi, j.max.Z })
				else
					table.insert(bordsInt, { j.min.X, j.max.Z, j.max.X, j.max.Z })
				end
				for _, b in ipairs(bordsInt) do
					local long = math.sqrt((b[3] - b[1]) ^ 2 + (b[4] - b[2]) ^ 2)
					local n = math.floor(long / 14)
					for i = 1, n do
						local t = (i - 0.5) / n
						local x = b[1] + (b[3] - b[1]) * t + alea:NextNumber(-3, 3)
						local z = b[2] + (b[4] - b[2]) * t + alea:NextNumber(-3, 3)
						local r = alea:NextNumber(4, 8)
						if not dansListe(chemins, x, z, r + 2) and not dansListe(obstacles, x, z, r) then
							remplirZone(disque(x, z, r), M_TOUFFUE, d)
						end
					end
				end
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, sous-bois : " .. tostring(err))
	end

	-- une place est « libre » (herbe sans rien) si elle est dans la zone jouable, loin des chemins et des obstacles
	local function libre(x, z, m)
		m = m or 3
		if x < xJeuMin + m or x > xJeuMax - m or z < zJeuMin + m or z > zJeuMax - m then return false end
		if dansListe(chemins, x, z, m) then return false end
		if dansListe(obstacles, x, z, m) then return false end
		return true
	end
	-- la périphérie : hors du cœur de jeu (Bases, promenades, chemins de ronde)
	local function peripherie(x, z)
		return math.abs(x) > xContreB + 8 or math.abs(z) > zRondeB + 8
	end

	-- 3. plaques d'herbe touffue en périphérie (fleurs posées plus loin)
	local plaques = {}
	ok, err = pcall(function()
		if not terrainOk then return end
		local voulues = reglage(ctx, "touffues")
		local d = reglage(ctx, "dessusTouffue")
		local essais = 0
		while #plaques < voulues and essais < 2000 do
			essais = essais + 1
			local x = alea:NextNumber(xJeuMin, xJeuMax)
			local z = alea:NextNumber(zJeuMin, zJeuMax)
			local r = alea:NextNumber(5, 11)
			local bon = peripherie(x, z) and libre(x, z, r + 2)
			if bon then
				for _, p in ipairs(plaques) do
					if (p.x - x) * (p.x - x) + (p.z - z) * (p.z - z) < (p.r + r + 8) * (p.r + r + 8) then
						bon = false
						break
					end
				end
			end
			if bon then
				remplirZone(disque(x, z, r), M_TOUFFUE, d)
				-- une ou deux plaques satellites pour casser le rond
				for _ = 1, alea:NextInteger(1, 2) do
					local a = alea:NextNumber(0, 2 * math.pi)
					local r2 = r * alea:NextNumber(0.4, 0.65)
					local x2, z2 = x + math.cos(a) * r * 0.9, z + math.sin(a) * r * 0.9
					if libre(x2, z2, r2 + 1) then
						remplirZone(disque(x2, z2, r2), M_TOUFFUE, d)
					end
				end
				table.insert(plaques, { x = x, z = z, r = r })
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, herbe touffue : " .. tostring(err))
	end

	-- 4. les chemins : sentiers de terre puis allées de sable (dans l'ordre de la liste)
	ok, err = pcall(function()
		if not terrainOk then return end
		local dA = reglage(ctx, "dessusAllee")
		local dS = reglage(ctx, "dessusSentier")
		for _, zone in ipairs(chemins) do
			if zone.mat == M_TERRE then
				remplirZone(zone, M_TERRE, dS)
			else
				remplirZone(zone, M_SABLE, dA)
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, chemins : " .. tostring(err))
	end

	-- 5. terre battue sous les bâtiments (pas de brins d'herbe à travers les dalles)
	ok, err = pcall(function()
		if not terrainOk then return end
		local d = reglage(ctx, "dessusTerre")
		for _, b in ipairs(bases) do
			local c = b.centre
			remplirZone(rect(c.X - demiBX + 1, c.X + demiBX - 1, c.Z - demiBZ + 1, c.Z + demiBZ - 1), M_TERRE, d)
		end
		if comptoir then
			local c, t = comptoir.centre, comptoir.taille
			remplirZone(rect(c.X - t.X / 2 + 0.5, c.X + t.X / 2 - 0.5, c.Z - t.Z / 2 + 0.5, c.Z + t.Z / 2 - 0.5), M_TERRE, d)
		end
		if autel then
			remplirZone(disque(autel.centre.X, autel.centre.Z, autel.rayon), M_TERRE, d)
		end
	end)
	if not ok then
		warn("[Dino] Sol, terre battue : " .. tostring(err))
	end

	-- 6. les murs invisibles
	ok, err = pcall(function()
		local murs = Outils.dossier(dossier, "Murs")
		local H = reglage(ctx, "hauteurMur")
		local e = reglage(ctx, "epaisseurMur")
		local longX = 2 * bordX + 2 * e
		local longZ = bordS - bordN + 2 * e
		local zMilieu = (bordN + bordS) / 2
		local defs = {
			{ Vector3.new(e, H, longZ), Vector3.new(-bordX - e / 2, H / 2, zMilieu) },
			{ Vector3.new(e, H, longZ), Vector3.new(bordX + e / 2, H / 2, zMilieu) },
			{ Vector3.new(longX, H, e), Vector3.new(0, H / 2, bordN - e / 2) },
			{ Vector3.new(longX, H, e), Vector3.new(0, H / 2, bordS + e / 2) },
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

	-- 7. bordures de galets : là où un chemin de sable touche l'herbe libre (ouvertures automatiques
	-- aux croisements, contre les Bases, les bâtiments, l'eau et les falaises)
	local LB = reglage(ctx, "largeurBordure")
	local HB = reglage(ctx, "hauteurBordure")
	local PAS = reglage(ctx, "pas")
	local SEG = reglage(ctx, "segment")
	local SEGA = reglage(ctx, "segmentArc")
	local JOINT = reglage(ctx, "jointure")
	local yBordure = 0.3 - HB / 2

	ok, err = pcall(function()
		local bordures = Outils.dossier(dossier, "Bordures")
		local rang = 0

		-- une pierre de p à q, décalée vers l'intérieur du chemin (normale sortante n)
		local function pierre(p, q, nx, nz)
			local dx, dz = q[1] - p[1], q[2] - p[2]
			local long = math.sqrt(dx * dx + dz * dz) - JOINT
			if long < 1 then
				return
			end
			rang = rang + 1
			local a = math.atan2(dz, dx)
			local mx = (p[1] + q[1]) / 2 - nx * LB / 2
			local mz = (p[2] + q[2]) / 2 - nz * LB / 2
			part(Outils.bloc, bordures, {
				Name = "Bordure",
				Size = Vector3.new(long, HB, LB),
				CFrame = CFrame.new(mx, yBordure, mz) * CFrame.Angles(0, -a, 0),
				Color = teintesPierre[1 + rang % #teintesPierre],
				Material = Enum.Material.Cobblestone,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
		end

		-- un point du bord garde sa pierre si, juste dehors, c'est de l'herbe libre, et s'il n'est pas dans un autre chemin
		local function garder(zone, x, z, nx, nz)
			local ox, oz = x + nx * 1.5, z + nz * 1.5
			if ox < xJeuMin or ox > xJeuMax or oz < zJeuMin or oz > zJeuMax then return false end
			if dansListe(chemins, ox, oz, 0) then return false end
			if dansListe(obstacles, ox, oz, 0.5) then return false end
			if dansListe(chemins, x, z, -0.4, zone) then return false end
			return true
		end

		-- suit un bord échantillonné (points {x, z, nx, nz}) et pose des pierres de longueur <= maxi sur les parties gardées
		local function poserBord(zone, points, maxi, ferme)
			local n = #points
			if n < 2 then return end
			local garde = {}
			local depart = 1
			local toutGarde = true
			for i = 1, n do
				local p = points[i]
				garde[i] = garder(zone, p[1], p[2], p[3], p[4])
				if not garde[i] then
					toutGarde = false
					if ferme and depart == 1 then depart = i end
				end
			end
			local function idx(k)
				return ((k - 1) % n) + 1
			end
			local total = n
			if not ferme then depart = 1 end
			if ferme and toutGarde then total = n + 1 end
			local debut = nil
			local longueur = 0
			local function fermer(fin)
				if debut and fin ~= debut then
					local p, q = points[idx(debut)], points[idx(fin)]
					local nx, nz = (p[3] + q[3]) / 2, (p[4] + q[4]) / 2
					pierre(p, q, nx, nz)
				end
				debut = nil
				longueur = 0
			end
			for k = depart, depart + total - 1 do
				local i = idx(k)
				if garde[i] then
					if not debut then
						debut = k
						longueur = 0
					else
						local p, q = points[idx(k - 1)], points[i]
						longueur = longueur + math.sqrt((q[1] - p[1]) ^ 2 + (q[2] - p[2]) ^ 2)
						if longueur >= maxi then
							fermer(k)
							debut = k
						end
					end
				else
					if debut then fermer(k - 1) end
				end
			end
			if debut then fermer(depart + total - 1) end
		end

		local function segmentDroit(zone, x0, z0, x1, z1, nx, nz)
			local dx, dz = x1 - x0, z1 - z0
			local long = math.sqrt(dx * dx + dz * dz)
			local n = math.max(1, math.floor(long / PAS + 0.5))
			local points = {}
			for i = 0, n do
				local t = i / n
				table.insert(points, { x0 + dx * t, z0 + dz * t, nx, nz })
			end
			poserBord(zone, points, SEG, false)
		end

		for _, zone in ipairs(chemins) do
			if zone.bordure then
				if zone.g == "rect" then
					segmentDroit(zone, zone.x0, zone.z0, zone.x1, zone.z0, 0, -1)
					segmentDroit(zone, zone.x0, zone.z1, zone.x1, zone.z1, 0, 1)
					segmentDroit(zone, zone.x0, zone.z0, zone.x0, zone.z1, -1, 0)
					segmentDroit(zone, zone.x1, zone.z0, zone.x1, zone.z1, 1, 0)
				elseif zone.g == "disque" then
					local n = math.max(12, math.floor(2 * math.pi * zone.r / PAS))
					local points = {}
					for i = 1, n do
						local a = 2 * math.pi * (i - 1) / n
						local c, s = math.cos(a), math.sin(a)
						table.insert(points, { zone.x + zone.r * c, zone.z + zone.r * s, c, s })
					end
					poserBord(zone, points, SEGA, true)
				end
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, bordures : " .. tostring(err))
	end

	-- 8. détails plats (dessus <= 0,3) : pas japonais sur les sentiers, galets sur les plages, fleurs
	ok, err = pcall(function()
		local details = Outils.dossier(dossier, "Decor")

		-- disque plat posé au sol (axe du cylindre vertical)
		local function rond(nom, diametre, epaisseur, x, z, couleur, materiau, yBas)
			return part(Outils.cylindre, details, {
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

		-- pas japonais : dalles d'ardoise en quinconce le long des sentiers de terre
		local ecart = reglage(ctx, "pasJaponais")
		for _, s in ipairs(sentiers) do
			local dx, dz = s.bx - s.ax, s.bz - s.az
			local L = math.sqrt(dx * dx + dz * dz)
			if L > 0 then
				local ux, uz = dx / L, dz / L
				local n = math.floor(L / ecart)
				for i = 1, n - 1 do
					local cote = 0.9
					if i % 2 == 0 then cote = -0.9 end
					local x = s.ax + ux * ecart * i - uz * cote
					local z = s.az + uz * ecart * i + ux * cote
					if not dansListe(obstacles, x, z, 1) and not dansListe(chemins, x, z, 0.5, s) then
						local couleur = teintesPierre[alea:NextInteger(1, #teintesPierre)]
						rond("PasJaponais", alea:NextNumber(2.2, 2.8), 0.22, x, z, couleur, Enum.Material.Slate, 0.02)
					end
				end
			end
		end

		-- galets plats sur la plage nord, par petits groupes, loin du sentier de la Place
		if riviere and zPlageA then
			local voulus = reglage(ctx, "galetsPlage")
			local poses, essais = 0, 0
			while poses < voulus and essais < 300 and nbParts < BUDGET do
				essais = essais + 1
				local x = alea:NextNumber(xJeuMin + 8, xJeuMax - 8)
				local z = alea:NextNumber(zPlageA + 1, riviere.zMin - 1)
				if not (place and math.abs(x - place.centre.X) < reglage(ctx, "demiRiviere") + 6) then
					for _ = 1, alea:NextInteger(1, 3) do
						if poses < voulus then
							local couleur = teintesPierre[alea:NextInteger(1, #teintesPierre)]
							rond("Galet", alea:NextNumber(0.7, 1.8), alea:NextNumber(0.18, 0.3),
								x + alea:NextNumber(-1.6, 1.6), z + alea:NextNumber(-1, 1), couleur, Enum.Material.Slate, -0.02)
							poses = poses + 1
						end
					end
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
