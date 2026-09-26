-- Builders/Relief.lua : collines et falaises en terrasses sur l'anneau 88..112 autour de la Prairie,
-- en laissant libres les couloirs de ±8 studs autour des axes X et Z (chemins et portails).
-- Chaque massif : empilement de blocs de terre coiffés d'herbe, rampes en coin, quelques rochers.
-- Budget : 500 parts.
local M = {}

local BUDGET = 500
local GRAINE = 8812
local RAYON_MIN = 88
local RAYON_MAX = 112
local COULOIR = 8           -- demi-largeur des couloirs libres autour des axes
local MARGE = 0.6           -- marge de sécurité autour de l'emprise d'un massif
local HAUTEUR_MIN = 6
local HAUTEUR_MAX = 25
local LARGEUR_MIN = 10      -- largeur tangentielle d'un massif
local LARGEUR_MAX = 18
local PROFONDEUR_MIN = 8    -- profondeur radiale d'un massif
local PROFONDEUR_MAX = 15
local EPAISSEUR_HERBE = 0.8
local DEBORD_HERBE = 0.3
local PARTS_MAX_MASSIF = 16 -- au pire : 4 étages x 2 + 3 rampes + 1 rampe basse + 2 flancs + 2 rochers

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	local prairie = Plan.prairie or {}
	local centre = prairie.centre or Vector3.new(0, 0, 0)
	local cx, cz = centre.X, centre.Z

	local rng = Outils.aleatoire(GRAINE)

	local couleurHerbe = Charte.prairie
	local couleurTerre = Charte.terre
	local couleurTerreOmbre = Charte.ombre(Charte.terre)
	local couleurRoche = Charte.ardoise
	local couleurRocheOmbre = Charte.ombre(Charte.ardoise)

	-- compteur de parts propre au module
	local nbParts = 0
	local function bloc(parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return Outils.bloc(parent, props)
	end
	local function coin(parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return Outils.coin(parent, props)
	end

	-- un point (x, z) du monde est-il dans l'emprise autorisée ? (quadrant imposé par sx, sz)
	local function pointValide(p, sx, sz)
		local dx = p.X - cx
		local dz = p.Z - cz
		local r = math.sqrt(dx * dx + dz * dz)
		if r < RAYON_MIN or r > RAYON_MAX then
			return false
		end
		if dx * sx < COULOIR or dz * sz < COULOIR then
			return false
		end
		return true
	end

	-- vérifie l'emprise rectangulaire d'un massif (repère local : X tangentiel, -Z vers le centre)
	local function empriseValide(repere, xMin, xMax, zMin, zMax, sx, sz)
		local xm = (xMin + xMax) / 2
		local zm = (zMin + zMax) / 2
		local points = {
			Vector3.new(xMin, 0, zMin), Vector3.new(xMax, 0, zMin),
			Vector3.new(xMin, 0, zMax), Vector3.new(xMax, 0, zMax),
			Vector3.new(xm, 0, zMin), Vector3.new(xm, 0, zMax),
			Vector3.new(xMin, 0, zm), Vector3.new(xMax, 0, zm),
		}
		for _, p in ipairs(points) do
			if not pointValide(repere * p, sx, sz) then
				return false
			end
		end
		return true
	end

	-- tire les dimensions d'un massif
	local function tirerMassif()
		local m = {}
		m.hauteur = math.floor(rng:NextNumber(HAUTEUR_MIN, HAUTEUR_MAX) + 0.5)
		if m.hauteur < HAUTEUR_MIN then m.hauteur = HAUTEUR_MIN end
		if m.hauteur > HAUTEUR_MAX then m.hauteur = HAUTEUR_MAX end
		m.etages = math.floor(m.hauteur / 6.5) + 1
		if m.etages < 2 then m.etages = 2 end
		if m.etages > 4 then m.etages = 4 end
		m.largeur = rng:NextNumber(LARGEUR_MIN, LARGEUR_MAX)
		m.profondeur = rng:NextNumber(PROFONDEUR_MIN, PROFONDEUR_MAX)
		-- rampe basse face au centre (parfois)
		m.rampe = 0
		if rng:NextNumber() < 0.55 then
			m.rampe = rng:NextNumber(3, 5)
		end
		-- coins sur les flancs latéraux (parfois)
		m.flanc = 0
		if rng:NextNumber() < 0.5 then
			m.flanc = rng:NextNumber(2.5, 4)
		end
		return m
	end

	-- construit un massif en terrasses dans le repère donné
	local function construireMassif(parent, repere, m, numero)
		local modele = Outils.modele(parent, "Massif" .. numero)
		local n = m.etages
		local h = m.hauteur / n
		local W = m.largeur
		local D = m.profondeur
		local largeurs = {}
		local profondeurs = {}

		for k = 0, n - 1 do
			local wk = W * (1 - k * 0.35 / n)
			local dk = D * (1 - k * 0.6 / n)
			largeurs[k] = wk
			profondeurs[k] = dk
			-- falaise adossée à l'extérieur : le dos de chaque étage est aligné sur +D/2
			local zc = D / 2 - dk / 2
			local base = k * h
			local hautBloc = h - EPAISSEUR_HERBE
			local couleurFlanc = couleurTerre
			if k % 2 == 1 then
				couleurFlanc = couleurTerreOmbre
			end
			bloc(modele, {
				Name = "Etage" .. k,
				Size = Vector3.new(wk, hautBloc, dk),
				CFrame = repere * CFrame.new(0, base + hautBloc / 2, zc),
				Color = couleurFlanc,
			})
			bloc(modele, {
				Name = "Herbe" .. k,
				Size = Vector3.new(wk + DEBORD_HERBE * 2, EPAISSEUR_HERBE, dk + DEBORD_HERBE * 2),
				CFrame = repere * CFrame.new(0, base + hautBloc + EPAISSEUR_HERBE / 2, zc),
				Color = couleurHerbe,
			})
			-- rampe herbeuse sur la terrasse, contre l'étage (le coin descend vers le centre)
			if k >= 1 and rng:NextNumber() < 0.6 then
				local palier = profondeurs[k - 1] - dk
				local longueur = math.min(palier, h * 1.4)
				if longueur > 1 then
					local largeurRampe = wk * rng:NextNumber(0.35, 0.6)
					local decalage = rng:NextNumber(-(wk - largeurRampe) / 2, (wk - largeurRampe) / 2)
					local avant = D / 2 - dk
					coin(modele, {
						Name = "Rampe" .. k,
						Size = Vector3.new(largeurRampe, h, longueur),
						CFrame = repere * CFrame.new(decalage, base + h / 2, avant - longueur / 2),
						Color = couleurHerbe,
					})
				end
			end
		end

		-- rampe basse, du sol jusqu'au premier palier
		if m.rampe > 0 then
			local largeurRampe = largeurs[0] * rng:NextNumber(0.4, 0.7)
			local decalage = rng:NextNumber(-(largeurs[0] - largeurRampe) / 2, (largeurs[0] - largeurRampe) / 2)
			coin(modele, {
				Name = "RampeBasse",
				Size = Vector3.new(largeurRampe, h, m.rampe),
				CFrame = repere * CFrame.new(decalage, h / 2, -D / 2 - m.rampe / 2),
				Color = couleurHerbe,
			})
		end

		-- coins d'éboulis sur les deux flancs latéraux du premier étage
		if m.flanc > 0 then
			local profondeurFlanc = profondeurs[0] * 0.7
			local zc = D / 2 - profondeurFlanc / 2
			local demi = largeurs[0] / 2 + m.flanc / 2
			coin(modele, {
				Name = "FlancDroit",
				Size = Vector3.new(profondeurFlanc, h, m.flanc),
				CFrame = repere * CFrame.new(demi, h / 2, zc) * CFrame.Angles(0, -math.pi / 2, 0),
				Color = couleurTerreOmbre,
			})
			coin(modele, {
				Name = "FlancGauche",
				Size = Vector3.new(profondeurFlanc, h, m.flanc),
				CFrame = repere * CFrame.new(-demi, h / 2, zc) * CFrame.Angles(0, math.pi / 2, 0),
				Color = couleurTerreOmbre,
			})
		end

		-- quelques rochers d'ardoise posés sur le sommet ou sur la première terrasse
		local nbRochers = 0
		local tirage = rng:NextNumber()
		if tirage < 0.15 then
			nbRochers = 2
		elseif tirage < 0.45 then
			nbRochers = 1
		end
		for i = 1, nbRochers do
			local etage = n - 1
			if i == 2 then
				etage = 0
			end
			local wk = largeurs[etage]
			local dk = profondeurs[etage]
			local cote = rng:NextNumber(1.6, 3.2)
			local taille = Vector3.new(cote * rng:NextNumber(0.9, 1.4), cote * rng:NextNumber(0.7, 1.1), cote)
			local limiteX = math.max(0, wk / 2 - cote)
			local zDebut = D / 2 - dk
			local zMin = zDebut + cote
			local zMax = D / 2 - cote
			if etage < n - 1 then
				-- sur la terrasse, devant l'étage suivant
				zMax = D / 2 - profondeurs[etage + 1] - cote * 0.6
			end
			if zMax < zMin then
				zMax = zMin
			end
			local couleur = couleurRoche
			if rng:NextInteger(0, 1) == 1 then
				couleur = couleurRocheOmbre
			end
			bloc(modele, {
				Name = "Rocher" .. i,
				Size = taille,
				CFrame = repere
					* CFrame.new(rng:NextNumber(-limiteX, limiteX), (etage + 1) * h + taille.Y / 2 - 0.3, rng:NextNumber(zMin, zMax))
					* CFrame.Angles(math.rad(rng:NextNumber(-8, 8)), math.rad(rng:NextNumber(0, 90)), math.rad(rng:NextNumber(-8, 8))),
				Color = couleur,
				Material = Enum.Material.Slate,
			})
		end
		return modele
	end

	-- ===== parcours des quatre quadrants, un quart du budget chacun =====
	local quadrants = {
		{ sx = 1, sz = 1 },
		{ sx = -1, sz = 1 },
		{ sx = -1, sz = -1 },
		{ sx = 1, sz = -1 },
	}
	local budgetQuadrant = math.floor(BUDGET / #quadrants)
	local numero = 0

	for q, quad in ipairs(quadrants) do
		local sousDossier = Outils.dossier(dossier, "Quadrant" .. q)
		local debutQuadrant = nbParts
		local angle = (q - 1) * 90
		local angleFin = q * 90
		local fini = false
		while angle < angleFin and not fini do
			if nbParts - debutQuadrant + PARTS_MAX_MASSIF > budgetQuadrant or nbParts + PARTS_MAX_MASSIF > BUDGET then
				fini = true
			else
				local m = tirerMassif()
				local place = false
				local essai = 0
				local avance = 1
				while essai < 4 and not place do
					essai = essai + 1
					local largeurTotale = m.largeur + 2 * m.flanc + 2 * DEBORD_HERBE
					local profondeurTotale = m.profondeur + m.rampe + DEBORD_HERBE
					local rMin = RAYON_MIN + MARGE + m.rampe + m.profondeur / 2 + DEBORD_HERBE
					local rMax = RAYON_MAX - MARGE - m.profondeur / 2 - DEBORD_HERBE
					if rMax >= rMin and profondeurTotale < RAYON_MAX - RAYON_MIN then
						local rc = rng:NextNumber(rMin, rMax)
						-- le massif est centré un peu plus loin sur l'arc pour ne pas chevaucher le précédent
						local a = math.rad(angle) + (largeurTotale / 2) / rc
						local pos = Vector3.new(cx + rc * math.cos(a), 0, cz + rc * math.sin(a))
						local repere = CFrame.lookAt(pos, Vector3.new(cx, 0, cz))
						local demiX = largeurTotale / 2 + MARGE
						if empriseValide(repere, -demiX, demiX, -m.profondeur / 2 - m.rampe - DEBORD_HERBE - MARGE, m.profondeur / 2 + DEBORD_HERBE + MARGE, quad.sx, quad.sz) then
							numero = numero + 1
							construireMassif(sousDossier, repere, m, numero)
							place = true
							-- les massifs se recouvrent légèrement pour former une chaîne continue
							avance = math.deg((largeurTotale * 0.8) / rc)
						end
					end
					if not place then
						-- plus étroit, sans flancs : utile près des couloirs
						m.largeur = math.max(LARGEUR_MIN * 0.6, m.largeur * 0.75)
						m.flanc = 0
					end
				end
				angle = angle + avance
			end
		end
	end
end

return M
