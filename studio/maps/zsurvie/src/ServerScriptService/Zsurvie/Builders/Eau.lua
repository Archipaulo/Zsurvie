-- Builders/Eau.lua
-- L'étang de la Prairie (Plan.etang, rayon 8) : eau translucide sur un fond sombre,
-- berge de galets, nénuphars flottants, roseaux, petit ponton de bois et grenouille jouet.
-- Graine fixe : l'étang est identique à chaque lancement. Hauteur max 6. Budget : 150 parts.
local M = {}

local GRAINE = 4608
local BUDGET = 150
local HAUTEUR_MAX = 6

-- écart angulaire (radians) ramené dans [0, pi]
local function ecartAngle(a, b)
	local d = math.abs(a - b) % (2 * math.pi)
	if d > math.pi then
		d = 2 * math.pi - d
	end
	return d
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not dossier or not Charte or not Outils then
		return
	end

	-- position et rayon de l'étang
	local centre = Vector3.new(46, 0, 20)
	local rayon = 8
	if Plan and Plan.etang then
		if Plan.etang.centre then
			centre = Plan.etang.centre
		end
		if Plan.etang.rayon then
			rayon = Plan.etang.rayon
		end
	end
	local hauteurMax = HAUTEUR_MAX
	if Plan and Plan.hauteurMaxPres and Plan.hauteurMaxPres < hauteurMax then
		hauteurMax = Plan.hauteurMaxPres
	end
	local cx, cz = centre.X, centre.Z
	local rng = Outils.aleatoire(GRAINE)

	-- compteur local de parts pour tenir le budget
	local nbParts = 0
	local function place(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return fabrique(parent, props)
	end
	local function bloc(parent, props) return place(Outils.bloc, parent, props) end
	local function boule(parent, props) return place(Outils.boule, parent, props) end
	local function cylindre(parent, props) return place(Outils.cylindre, parent, props) end
	local function coin(parent, props) return place(Outils.coin, parent, props) end

	-- palette, uniquement depuis la Charte
	local couleurEau = Charte.ombre(Charte.gemme)
	local couleurFond = Charte.ombre(Charte.ombre(Charte.gemme)):Lerp(Charte.encre, 0.35)
	local couleursGalets = { Charte.ardoise, Charte.lumiere(Charte.ardoise), Charte.lumiere(Charte.lumiere(Charte.ardoise)), Charte.ombre(Charte.creme) }
	local vertFeuille = Charte.ombre(Charte.prairie)
	local vertRoseau = Charte.ombre(Charte.ombre(Charte.prairie))
	local bois = Charte.terre
	local boisSombre = Charte.ombre(Charte.terre)
	local brunMassette = Charte.ombre(Charte.ombre(Charte.terre))

	-- cylindre vertical (l'axe d'un cylindre Roblox est X) : disque d'épaisseur e
	local VERTICAL = CFrame.Angles(0, 0, math.rad(90))
	local function disque(parent, nom, x, yCentre, z, diametre, epaisseur, props)
		local p = {
			Name = nom,
			Size = Vector3.new(epaisseur, diametre, diametre),
			CFrame = CFrame.new(x, yCentre, z) * VERTICAL,
		}
		if props then
			for k, v in pairs(props) do
				p[k] = v
			end
		end
		return cylindre(parent, p)
	end

	local function point(angle, r)
		return cx + math.cos(angle) * r, cz + math.sin(angle) * r
	end

	-- direction de la Maison : le ponton part de ce côté de la berge
	local maison = Vector3.new(0, 0, 0)
	if Plan and Plan.maison and Plan.maison.centre then
		maison = Plan.maison.centre
	end
	local dir = Vector3.new(maison.X - cx, 0, maison.Z - cz)
	if dir.Magnitude < 0.01 then
		dir = Vector3.new(-1, 0, 0)
	end
	dir = dir.Unit
	local anglePonton = math.atan2(dir.Z, dir.X)
	local repere = CFrame.lookAt(Vector3.new(cx, 0, cz), Vector3.new(cx, 0, cz) + dir)

	local rayonEau = rayon - 1.1

	-- ===== eau et fond =====
	local modeleEau = Outils.modele(dossier, "Etang")
	-- fond sombre, juste au-dessus du sol de la Prairie
	disque(modeleEau, "Fond", cx, 0.025, cz, rayonEau * 2 + 0.4, 0.05, { Color = couleurFond })
	-- surface d'eau : dessus à Y = 0.1
	local surface = disque(modeleEau, "Surface", cx, -0.1, cz, rayonEau * 2, 0.4, {
		Color = couleurEau,
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		CanCollide = false,
	})
	if surface then
		surface.CastShadow = false
	end

	-- ===== berge de galets =====
	local berge = Outils.modele(dossier, "Berge")
	local nbGalets = 26
	for i = 1, nbGalets do
		local angle = (i - 1) / nbGalets * 2 * math.pi + rng:NextNumber(-0.08, 0.08)
		if ecartAngle(angle, anglePonton) > math.rad(22) then
			local taille = rng:NextNumber(0.8, 1.3)
			local r = rayon - taille / 2 - rng:NextNumber(0.05, 0.4)
			local x, z = point(angle, r)
			boule(berge, {
				Name = "Galet",
				Size = Vector3.new(taille, taille, taille),
				CFrame = CFrame.new(x, taille * 0.15, z),
				Color = couleursGalets[rng:NextInteger(1, #couleursGalets)],
			})
		end
	end

	-- ===== nénuphars (flottent) =====
	local nenuphars = Outils.modele(dossier, "Nenuphars")
	local listeNenuphars = {
		{ a = 150, r = 2.4, d = 2.2, fleur = true },
		{ a = 205, r = 4.3, d = 1.8, fleur = false },
		{ a = 260, r = 3.2, d = 2.4, fleur = true },
		{ a = 320, r = 4.6, d = 1.6, fleur = false },
		{ a = 20, r = 3.6, d = 2.0, fleur = true },
		{ a = 95, r = 4.9, d = 1.5, fleur = false },
	}
	local couleursFleurs = { Charte.lumiere(Charte.creme), Charte.lumiere(Charte.alerte), Charte.dore }
	local indiceFleur = 0
	for i, n in ipairs(listeNenuphars) do
		local angle = anglePonton + math.rad(n.a)
		local x, z = point(angle, n.r)
		local vitesse = 0.6 + (i % 3) * 0.15
		local feuille = disque(nenuphars, "Nenuphar", x, 0.16, z, n.d, 0.12, { Color = vertFeuille, CanCollide = false })
		if feuille then
			Outils.animer(feuille, "flotte", vitesse)
		end
		if n.fleur then
			indiceFleur = indiceFleur + 1
			local fleur = boule(nenuphars, {
				Name = "Fleur",
				Size = Vector3.new(0.6, 0.6, 0.6),
				CFrame = CFrame.new(x + 0.2, 0.42, z - 0.1),
				Color = couleursFleurs[((indiceFleur - 1) % #couleursFleurs) + 1],
				CanCollide = false,
			})
			if fleur then
				Outils.animer(fleur, "flotte", vitesse)
			end
		end
	end

	-- ===== roseaux, en touffes sur la berge =====
	local roseaux = Outils.modele(dossier, "Roseaux")
	local touffes = { 110, 185, 250 }
	for _, degres in ipairs(touffes) do
		local angleTouffe = anglePonton + math.rad(degres)
		for j = 1, 5 do
			local angle = angleTouffe + rng:NextNumber(-0.22, 0.22)
			local r = rayon - rng:NextNumber(1.2, 2.2)
			local x, z = point(angle, r)
			local h = math.min(rng:NextNumber(2.2, 3.6), hauteurMax - 0.8)
			local tige = bloc(roseaux, {
				Name = "Tige",
				Size = Vector3.new(0.18, h, 0.18),
				CFrame = CFrame.new(x, h / 2, z) * CFrame.Angles(rng:NextNumber(-0.12, 0.12), 0, rng:NextNumber(-0.12, 0.12)),
				Color = vertRoseau,
				CanCollide = false,
			})
			-- une massette brune sur trois tiges sur cinq
			if tige and j % 2 == 1 then
				bloc(roseaux, {
					Name = "Massette",
					Size = Vector3.new(0.34, 0.7, 0.34),
					CFrame = tige.CFrame * CFrame.new(0, h / 2 - 0.2, 0),
					Color = brunMassette,
					CanCollide = false,
				})
			end
		end
	end

	-- ===== ponton de bois, côté Maison =====
	-- repère local : -Z pointe vers la Maison, la berge est à z = -rayon
	local ponton = Outils.modele(dossier, "Ponton")
	local yPlanche = 0.55
	local zPlanches = { -7.3, -6.3, -5.3, -4.3, -3.3 }
	for i, zp in ipairs(zPlanches) do
		local teinte = bois
		if i % 2 == 0 then
			teinte = Charte.lumiere(bois)
		end
		bloc(ponton, {
			Name = "Planche",
			Size = Vector3.new(3, 0.3, 0.9),
			CFrame = repere * CFrame.new(0, yPlanche, zp),
			Color = teinte,
		})
	end
	-- poteaux
	local poteaux = { { -1.4, -6.4 }, { 1.4, -6.4 }, { -1.4, -3.4 }, { 1.4, -3.4 } }
	for _, pt in ipairs(poteaux) do
		bloc(ponton, {
			Name = "Poteau",
			Size = Vector3.new(0.4, 1.4, 0.4),
			CFrame = repere * CFrame.new(pt[1], 0.3, pt[2]),
			Color = boisSombre,
		})
	end
	-- longerons sous les planches
	for _, xl in ipairs({ -1.2, 1.2 }) do
		bloc(ponton, {
			Name = "Longeron",
			Size = Vector3.new(0.3, 0.25, 4.8),
			CFrame = repere * CFrame.new(xl, yPlanche - 0.27, -5.3),
			Color = boisSombre,
		})
	end
	-- petite marche d'accès côté berge (le coin monte vers +Z local, donc vers le ponton)
	coin(ponton, {
		Name = "Marche",
		Size = Vector3.new(2.4, 0.7, 0.8),
		CFrame = repere * CFrame.new(0, 0.35, -7.6),
		Color = boisSombre,
	})

	-- ===== grenouille jouet, au bout du ponton, tournée vers l'eau =====
	local grenouille = Outils.modele(dossier, "Grenouille")
	local yPont = yPlanche + 0.15
	local base = repere * CFrame.new(0, yPont, -3.7) * CFrame.Angles(0, math.pi, 0)
	local vertGrenouille = Charte.lumiere(Charte.prairie)
	local corps = boule(grenouille, {
		Name = "Corps",
		Size = Vector3.new(1.2, 1.2, 1.2),
		CFrame = base * CFrame.new(0, 0.55, 0),
		Color = vertGrenouille,
	})
	boule(grenouille, {
		Name = "Tete",
		Size = Vector3.new(0.95, 0.95, 0.95),
		CFrame = base * CFrame.new(0, 0.95, -0.5),
		Color = vertGrenouille,
	})
	for _, cote in ipairs({ -1, 1 }) do
		boule(grenouille, {
			Name = "Oeil",
			Size = Vector3.new(0.4, 0.4, 0.4),
			CFrame = base * CFrame.new(0.3 * cote, 1.35, -0.6),
			Color = Charte.creme,
		})
		boule(grenouille, {
			Name = "Pupille",
			Size = Vector3.new(0.18, 0.18, 0.18),
			CFrame = base * CFrame.new(0.3 * cote, 1.4, -0.79),
			Color = Charte.encre,
		})
		bloc(grenouille, {
			Name = "PatteArriere",
			Size = Vector3.new(0.4, 0.3, 0.8),
			CFrame = base * CFrame.new(0.62 * cote, 0.15, 0.2),
			Color = Charte.ombre(vertGrenouille),
		})
		bloc(grenouille, {
			Name = "PatteAvant",
			Size = Vector3.new(0.22, 0.5, 0.22),
			CFrame = base * CFrame.new(0.38 * cote, 0.25, -0.62),
			Color = Charte.ombre(vertGrenouille),
		})
	end
	if corps then
		grenouille.PrimaryPart = corps
	end
end

return M
