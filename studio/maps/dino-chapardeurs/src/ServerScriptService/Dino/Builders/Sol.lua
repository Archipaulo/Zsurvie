-- Constructeur Sol : le sol de tout le monde (dessus à Y = 0, épaisseur 4) en grandes dalles,
-- herbe en damier doux au centre, sable près de la rivière, terre brûlée près du Volcan ;
-- allées de terre (Place <-> Tapis par les couloirs entre les Bases, anneau autour de la Place),
-- touffes d'herbe et fleurs plates (hauteur <= 0,3) hors zones construites, murs invisibles au bord.
local M = {}

-- réglages par défaut (surchargés par Equilibrage.sol s'il existe)
local DEFAUTS = {
	budget = 600,          -- parts au maximum pour ce constructeur
	epaisseur = 4,         -- épaisseur des dalles
	colonnes = 10,         -- dalles d'ouest en est
	rangsNord = 2,         -- rangées de terre brûlée
	rangsCentre = 7,       -- rangées d'herbe
	rangsSud = 1,          -- rangées de sable
	zVolcan = -110,        -- au nord de cette ligne : terre brûlée
	zSable = 120,          -- au sud de cette ligne : sable
	epaisseurAllee = 0.2,
	largeurCouloir = 8,
	couloirProche = 8,     -- |z| où commencent les couloirs (bord du Tapis)
	couloirLoin = 80,      -- |z| où ils s'arrêtent (Place au sud, Cratère au nord)
	zTraverse = 76,        -- allée est-ouest qui relie les couloirs du sud à la Place
	largeurTraverse = 6,
	rayonAnneau = 22,      -- anneau d'allée autour de la Place (milieu)
	largeurAnneau = 4,
	segmentsAnneau = 16,
	largeurLien = 5,       -- allées Place -> Comptoir et Place -> Autel
	hauteurMur = 60,
	epaisseurMur = 4,
	braises = 18,          -- éclats de braise dans la bande brûlée libre
	essaisDecor = 5000,
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
	local function part(parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return Outils.bloc(parent, props)
	end

	local function douce(c, t)
		return c:Lerp(Charte.lumiere(c), t)
	end
	local function sombre(c, t)
		return c:Lerp(Charte.ombre(c), t)
	end

	-- teintes des trois zones (damier doux : deux ou trois nuances proches)
	local teintes = {
		herbe = { Charte.herbe, douce(Charte.herbe, 0.55), sombre(Charte.herbe, 0.45) },
		sable = { Charte.sable, douce(Charte.sable, 0.6), sombre(Charte.sable, 0.25) },
		brule = { Charte.encre:Lerp(Charte.lave, 0.26), Charte.encre:Lerp(Charte.lave, 0.18) },
	}

	local monde = Plan.monde
	local xMin, xMax = monde.min.X, monde.max.X
	local zMin, zMax = monde.min.Z, monde.max.Z
	local bord = monde.bord or 190
	local EP = reglage(ctx, "epaisseur")
	local zVolcan = reglage(ctx, "zVolcan")
	local zSable = reglage(ctx, "zSable")

	local function dalle(parent, nom, x0, x1, z0, z1, couleur)
		if x1 - x0 <= 0 or z1 - z0 <= 0 then
			return nil
		end
		return part(parent, {
			Name = nom,
			Size = Vector3.new(x1 - x0, EP, z1 - z0),
			CFrame = CFrame.new((x0 + x1) / 2, -EP / 2, (z0 + z1) / 2),
			Color = couleur,
			CanCollide = true,
			CanQuery = true,
			CanTouch = true,
		})
	end

	-- ===== 1. les dalles du monde =====
	local ok, err = pcall(function()
		local dalles = Outils.dossier(dossier, "Dalles")
		local colonnes = math.max(1, math.floor(reglage(ctx, "colonnes")))
		local largeurCol = (xMax - xMin) / colonnes

		-- bandes de rangées : { z début, z fin, nombre de rangées, zone }
		local bandes = {
			{ zMin, math.max(zMin, zVolcan), reglage(ctx, "rangsNord"), "brule" },
			{ math.max(zMin, zVolcan), math.min(zMax, zSable), reglage(ctx, "rangsCentre"), "herbe" },
			{ math.min(zMax, zSable), zMax, reglage(ctx, "rangsSud"), "sable" },
		}
		local rangGlobal = 0
		for _, b in ipairs(bandes) do
			local z0, z1 = b[1], b[2]
			local rangs = math.max(1, math.floor(b[3]))
			if z1 > z0 then
				local pasZ = (z1 - z0) / rangs
				local palette = teintes[b[4]]
				for r = 1, rangs do
					rangGlobal = rangGlobal + 1
					local za = z0 + (r - 1) * pasZ
					for c = 1, colonnes do
						local xa = xMin + (c - 1) * largeurCol
						-- damier doux : une case sur deux en teinte de base, les autres alternent
						local teinte
						if (c + rangGlobal) % 2 == 0 then
							teinte = palette[1]
						else
							local k = 2 + (math.floor((c + 1) / 2) + rangGlobal) % (#palette - 1)
							teinte = palette[k]
						end
						dalle(dalles, "Dalle", xa, xa + largeurCol, za, za + pasZ, teinte)
					end
				end
			end
		end

		-- bordure entre le monde et les murs, pour qu'il n'y ait aucun trou
		local tBrule, tHerbe, tSable = teintes.brule[2], sombre(Charte.herbe, 0.3), teintes.sable[1]
		local zA = math.max(zMin, zVolcan)
		local zB = math.min(zMax, zSable)
		for _, cote in ipairs({ { -bord, xMin }, { xMax, bord } }) do
			dalle(dalles, "Bordure", cote[1], cote[2], -bord, zA, tBrule)
			dalle(dalles, "Bordure", cote[1], cote[2], zA, zB, tHerbe)
			dalle(dalles, "Bordure", cote[1], cote[2], zB, bord, tSable)
		end
		dalle(dalles, "Bordure", xMin, xMax, -bord, zMin, tBrule)
		dalle(dalles, "Bordure", xMin, xMax, zMax, bord, tSable)
	end)
	if not ok then
		warn("[Dino] Sol, dalles : " .. tostring(err))
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
			part(murs, {
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

	-- ===== 3. les allées de terre =====
	local EA = reglage(ctx, "epaisseurAllee")
	local couloirs = (Plan.decor and Plan.decor.couloirs) or { Vector3.new(-56, 0, 0), Vector3.new(0, 0, 0), Vector3.new(56, 0, 0) }
	local place = Plan.place
	local comptoir = Plan.comptoir
	local autel = Plan.autel

	ok, err = pcall(function()
		local allees = Outils.dossier(dossier, "Allees")
		local terre = Charte.terre
		local terreClaire = douce(Charte.terre, 0.35)

		local function allee(nom, cf, sx, sz, couleur)
			return part(allees, {
				Name = nom,
				Size = Vector3.new(sx, EA, sz),
				CFrame = cf,
				Color = couleur or terre,
				CanCollide = true,
				CanQuery = true,
				CanTouch = true,
				CastShadow = false,
			})
		end

		-- couloirs entre les Bases : du Tapis vers la Place (sud) et vers le Cratère (nord)
		local L = reglage(ctx, "largeurCouloir")
		local proche = reglage(ctx, "couloirProche")
		local loin = reglage(ctx, "couloirLoin")
		for _, c in ipairs(couloirs) do
			for _, sens in ipairs({ 1, -1 }) do
				local zc = sens * (proche + loin) / 2
				allee("Couloir", CFrame.new(c.X, EA / 2, zc), L, loin - proche)
			end
		end

		-- traverse est-ouest qui rejoint la Place depuis les couloirs du sud
		local xExt = 0
		for _, c in ipairs(couloirs) do
			xExt = math.max(xExt, math.abs(c.X))
		end
		local zT = reglage(ctx, "zTraverse")
		allee("Traverse", CFrame.new(0, EA / 2, zT), 2 * xExt + L, reglage(ctx, "largeurTraverse"))

		-- anneau autour de la Place (légèrement plus clair)
		if place then
			local n = math.max(6, math.floor(reglage(ctx, "segmentsAnneau")))
			local r = reglage(ctx, "rayonAnneau")
			local la = reglage(ctx, "largeurAnneau")
			local longueur = 2 * (r + la / 2) * math.tan(math.pi / n) + 0.4
			for k = 0, n - 1 do
				local a = k * 2 * math.pi / n
				local x = place.centre.X + r * math.cos(a)
				local z = place.centre.Z + r * math.sin(a)
				allee("Anneau", CFrame.new(x, EA / 2, z) * CFrame.Angles(0, -a, 0), la, longueur, terreClaire)
			end

			-- liens Place -> Comptoir (ouest) et Place -> Autel (est)
			local lien = reglage(ctx, "largeurLien")
			local xAnneau = r
			if comptoir then
				local xBord = comptoir.centre.X + comptoir.taille.X / 2 -- façade ouverte vers +X
				local x1 = place.centre.X - xAnneau
				if x1 > xBord then
					allee("LienComptoir", CFrame.new((xBord + x1) / 2, EA / 2, comptoir.centre.Z), x1 - xBord, lien)
				end
			end
			if autel then
				local xBord = autel.centre.X - autel.rayon
				local x0 = place.centre.X + xAnneau
				if xBord > x0 then
					allee("LienAutel", CFrame.new((x0 + xBord) / 2, EA / 2, autel.centre.Z), xBord - x0, lien)
				end
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, allées : " .. tostring(err))
	end

	-- ===== 4. zones libres pour le décor =====
	local function dansDisque(x, z, centre, rayon)
		local dx, dz = x - centre.X, z - centre.Z
		return dx * dx + dz * dz <= rayon * rayon
	end

	local function libre(x, z)
		-- herbe uniquement, hors jungles (|x| > 144) et loin de la rivière
		if x < -144 or x > 144 then return false end
		if z < zVolcan + 2 then return false end
		local zRiv = 131
		if Plan.riviere then
			zRiv = Plan.riviere.z - Plan.riviere.largeur / 2
		end
		if z > math.min(zSable, zRiv) - 3 then return false end
		-- Tapis et ses rebords
		if math.abs(z) <= 11 then return false end
		-- Nurserie et Fin du tapis (et leurs fossiles de part et d'autre)
		if Plan.nurserie and dansDisque(x, z, Plan.nurserie.centre, 32) then return false end
		if Plan.finTapis and dansDisque(x, z, Plan.finTapis.centre, 32) then return false end
		-- Bases (44 x 50) avec une marge
		local base = Plan.base
		local demiX = ((base and base.largeur) or 44) / 2 + 2
		local demiZ = ((base and base.profondeur) or 50) / 2 + 2
		for _, b in ipairs(Plan.bases or {}) do
			if math.abs(x - b.centre.X) <= demiX and math.abs(z - b.centre.Z) <= demiZ then return false end
		end
		-- couloirs et traverse
		for _, c in ipairs(couloirs) do
			if math.abs(x - c.X) <= 7 and math.abs(z) <= 84 then return false end
		end
		if math.abs(z - reglage(ctx, "zTraverse")) <= 6 and math.abs(x) <= 64 then return false end
		-- Place, Comptoir, Autel et leurs liens
		if place and dansDisque(x, z, place.centre, 30) then return false end
		if comptoir then
			if math.abs(x - comptoir.centre.X) <= comptoir.taille.X / 2 + 4 and math.abs(z - comptoir.centre.Z) <= comptoir.taille.Z / 2 + 4 then return false end
			if math.abs(z - comptoir.centre.Z) <= 5 and x > comptoir.centre.X and x < 0 then return false end
		end
		if autel then
			if dansDisque(x, z, autel.centre, autel.rayon + 4) then return false end
			if math.abs(z - autel.centre.Z) <= 5 and x < autel.centre.X and x > 0 then return false end
		end
		-- Cratère et Volcan
		if Plan.cratere and dansDisque(x, z, Plan.cratere.centre, Plan.cratere.rayon + 4) then return false end
		if Plan.volcan and dansDisque(x, z, Plan.volcan.centre, Plan.volcan.rayon + 8) then return false end
		return true
	end

	-- ===== 5. braises, touffes d'herbe et fleurs (plates : dessus <= 0,3) =====
	ok, err = pcall(function()
		local decor = Outils.dossier(dossier, "Decor")
		local alea = Outils.aleatoire(reglage(ctx, "graine"))

		local function petit(nom, taille, x, z, angle, couleur, materiau)
			return part(decor, {
				Name = nom,
				Size = taille,
				CFrame = Outils.surSol(taille, x, z, angle),
				Color = couleur,
				Material = materiau or Enum.Material.SmoothPlastic,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
		end

		-- éclats de braise dans la bande brûlée qui reste visible (entre la jungle nord et l'herbe)
		local zHautJungle = -118
		if Plan.decor and Plan.decor.jungleNord then
			zHautJungle = Plan.decor.jungleNord.max.Z
		end
		local posees, essais = 0, 0
		local nbBraises = reglage(ctx, "braises")
		while posees < nbBraises and essais < 400 and nbParts < BUDGET do
			essais = essais + 1
			local x = alea:NextNumber(-144, 144)
			local z = alea:NextNumber(zHautJungle + 1, zVolcan - 1)
			local loinVolcan = not (Plan.volcan and dansDisque(x, z, Plan.volcan.centre, Plan.volcan.rayon + 6))
			if loinVolcan and z < zVolcan then
				local cote = alea:NextNumber(0.5, 1)
				petit("Braise", Vector3.new(cote, 0.1, cote), x, z, alea:NextNumber(0, 90), Charte.lave, Enum.Material.Neon)
				posees = posees + 1
			end
		end

		local couleursFleurs = { Charte.creme, Charte.dore, Charte.violet, Charte.alerte, Charte.gemme }
		local teintesTouffe = { Charte.jungle, sombre(Charte.herbe, 0.7), douce(Charte.jungle, 0.3) }

		local function touffe(x, z)
			local couleur = teintesTouffe[alea:NextInteger(1, #teintesTouffe)]
			local angle = alea:NextNumber(0, 180)
			local long = alea:NextNumber(1.2, 1.8)
			petit("Touffe", Vector3.new(long, 0.3, 0.35), x, z, angle, couleur)
			petit("Touffe", Vector3.new(long * 0.8, 0.25, 0.35), x, z, angle + 70, couleur)
		end

		local function fleur(x, z)
			local couleur = couleursFleurs[alea:NextInteger(1, #couleursFleurs)]
			local coeur = Charte.dore
			if couleur == Charte.dore then
				coeur = Charte.creme
			end
			petit("Petales", Vector3.new(0.9, 0.2, 0.9), x, z, 45, couleur)
			petit("Coeur", Vector3.new(0.35, 0.3, 0.35), x, z, 0, coeur)
		end

		-- bosquets de 2 à 5 éléments autour d'un point libre
		local maxEssais = reglage(ctx, "essaisDecor")
		essais = 0
		while essais < maxEssais and nbParts + 2 <= BUDGET do
			essais = essais + 1
			local cx = alea:NextNumber(-144, 144)
			local cz = alea:NextNumber(zVolcan, zSable)
			if libre(cx, cz) then
				local n = alea:NextInteger(2, 5)
				local fleurs = alea:NextNumber() < 0.4
				for _ = 1, n do
					if nbParts + 2 > BUDGET then
						break
					end
					local x = cx + alea:NextNumber(-3, 3)
					local z = cz + alea:NextNumber(-3, 3)
					if libre(x, z) then
						if fleurs and alea:NextNumber() < 0.7 then
							fleur(x, z)
						else
							touffe(x, z)
						end
					end
				end
			end
		end
	end)
	if not ok then
		warn("[Dino] Sol, décor : " .. tostring(err))
	end

	dossier:SetAttribute("Parts", nbParts)
end

return M
