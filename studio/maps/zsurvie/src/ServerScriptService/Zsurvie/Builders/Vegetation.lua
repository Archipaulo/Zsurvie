-- Builders/Vegetation.lua
-- Forêt jouet en anneau autour de la Prairie (rayons 70 à 86), hors couloirs des chemins.
-- Arbres à feuillage étagé, sapins en coins empilés, buissons ronds, buissons à baies, fleurs.
-- Graine fixe : la forêt est identique à chaque lancement. Budget : 900 parts.
local M = {}

local GRAINE = 7017
local BUDGET = 900
local RAYON_EXTERIEUR = 86 -- limite de l'emprise (CONTRAT §9)
local COULOIR = 5          -- demi-largeur des couloirs de chemins à laisser libres
local MARGE = 0.6          -- espace minimal entre deux éléments
local TENTATIVES = 40

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not dossier then
		return
	end

	local rng = Outils.aleatoire(GRAINE)
	local centre = Vector3.new(0, 0, 0)
	local rayonInterieur = 70
	if Plan and Plan.prairie then
		if Plan.prairie.centre then
			centre = Plan.prairie.centre
		end
		if Plan.prairie.rayon then
			rayonInterieur = Plan.prairie.rayon
		end
	end
	local ySol = centre.Y

	-- palette : verts dérivés de la prairie, uniquement depuis la Charte
	local vertBase = Charte.prairie
	local verts = {
		vertBase,
		Charte.ombre(vertBase),
		Charte.lumiere(vertBase),
		Charte.ombre(Charte.ombre(vertBase)),
		vertBase:Lerp(Charte.encre, 0.25),
	}
	local vertsSapin = {
		Charte.ombre(vertBase),
		Charte.ombre(Charte.ombre(vertBase)),
		vertBase:Lerp(Charte.encre, 0.35),
	}
	local couleursFleurs = { Charte.dore, Charte.creme, Charte.toit, Charte.gemme, Charte.lumiere(Charte.alerte) }
	local tronc = Charte.terre
	local troncSombre = Charte.ombre(Charte.terre)

	local function choisir(liste)
		return liste[rng:NextInteger(1, #liste)]
	end

	-- compteur de parts propre à ce constructeur
	local partsPosees = 0
	local function reste()
		return BUDGET - partsPosees
	end
	local function compter(n)
		partsPosees = partsPosees + n
	end

	-- sous-dossiers par famille
	local dArbres = Outils.dossier(dossier, "Arbres")
	local dSapins = Outils.dossier(dossier, "Sapins")
	local dBuissons = Outils.dossier(dossier, "Buissons")
	local dBaies = Outils.dossier(dossier, "BuissonsBaies")
	local dFleurs = Outils.dossier(dossier, "Fleurs")

	-- emplacements déjà pris : { x, z, r }
	local occupes = {}

	local function libre(x, z, r)
		for _, o in ipairs(occupes) do
			local dx, dz = x - o.x, z - o.z
			local mini = r + o.r + MARGE
			if dx * dx + dz * dz < mini * mini then
				return false
			end
		end
		return true
	end

	-- cherche un point de l'anneau où un objet de rayon r tient entièrement
	local function trouverPlace(r)
		local rMin = rayonInterieur + r
		local rMax = RAYON_EXTERIEUR - r
		if rMax < rMin then
			return nil
		end
		for _ = 1, TENTATIVES do
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(rMin, rMax)
			local lx = math.cos(a) * d
			local lz = math.sin(a) * d
			if math.abs(lx) >= COULOIR + r and math.abs(lz) >= COULOIR + r then
				local x = centre.X + lx
				local z = centre.Z + lz
				if libre(x, z, r) then
					table.insert(occupes, { x = x, z = z, r = r })
					return x, z
				end
			end
		end
		return nil
	end

	-- ===== arbre jouet : tronc + 2 ou 3 blocs de feuillage étagés =====
	local function arbre(x, z, echelle, etages)
		local m = Outils.modele(dArbres, "Arbre")
		local angle = rng:NextNumber(0, 360)
		local base = CFrame.new(x, ySol, z) * CFrame.Angles(0, math.rad(angle), 0)
		local largeurTronc = 1.2 * echelle
		local hauteurTronc = rng:NextNumber(3, 4.5) * echelle
		local t = Outils.bloc(m, {
			Name = "Tronc",
			Size = Vector3.new(largeurTronc, hauteurTronc, largeurTronc),
			CFrame = base * CFrame.new(0, hauteurTronc / 2, 0),
			Color = tronc,
		})
		m.PrimaryPart = t
		local y = hauteurTronc - 0.4 * echelle
		local cote = rng:NextNumber(5, 6.5) * echelle
		local dernier = nil
		for i = 1, etages do
			local h = rng:NextNumber(2, 2.8) * echelle
			local c = cote * (1 - 0.24 * (i - 1))
			dernier = Outils.bloc(m, {
				Name = "Feuillage" .. i,
				Size = Vector3.new(c, h, c),
				CFrame = base * CFrame.new(0, y + h / 2, 0) * CFrame.Angles(0, math.rad(rng:NextNumber(-25, 25)), 0),
				Color = choisir(verts),
			})
			y = y + h * 0.85
		end
		-- certains sommets flottent doucement
		if dernier and rng:NextNumber() < 0.35 then
			Outils.animer(dernier, "flotte", 0.3)
		end
		compter(1 + etages)
	end

	-- ===== sapin : tronc + étages pyramidaux de 4 coins =====
	local function sapin(x, z, echelle, etages)
		local m = Outils.modele(dSapins, "Sapin")
		local angle = rng:NextNumber(0, 360)
		local base = CFrame.new(x, ySol, z) * CFrame.Angles(0, math.rad(angle), 0)
		local hauteurTronc = 2 * echelle
		local largeurTronc = 1 * echelle
		local t = Outils.bloc(m, {
			Name = "Tronc",
			Size = Vector3.new(largeurTronc, hauteurTronc, largeurTronc),
			CFrame = base * CFrame.new(0, hauteurTronc / 2, 0),
			Color = troncSombre,
		})
		m.PrimaryPart = t
		local couleur = choisir(vertsSapin)
		local y = hauteurTronc - 0.3 * echelle
		local demi = 3 * echelle
		for i = 1, etages do
			local h = 3 * echelle * (1 - 0.12 * (i - 1))
			local r = demi * (1 - 0.26 * (i - 1))
			local teinte = couleur
			if i % 2 == 0 then
				teinte = Charte.lumiere(couleur)
			end
			local tour = CFrame.Angles(0, math.rad(rng:NextNumber(0, 90)), 0)
			for k = 0, 3 do
				-- le côté bas du coin (face avant, -Z) pointe vers l'extérieur
				Outils.coin(m, {
					Name = "Etage" .. i,
					Size = Vector3.new(r * 2, h, r),
					CFrame = base * CFrame.new(0, y + h / 2, 0) * tour * CFrame.Angles(0, math.rad(90 * k), 0) * CFrame.new(0, 0, -r / 2),
					Color = teinte,
				})
			end
			y = y + h * 0.6
		end
		compter(1 + etages * 4)
	end

	-- ===== buisson rond : 2 ou 3 boules =====
	local function buisson(x, z, echelle, boules)
		local m = Outils.modele(dBuissons, "Buisson")
		local base = CFrame.new(x, ySol, z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), 0)
		local d = 2.6 * echelle
		local premiere = Outils.boule(m, {
			Name = "Boule1",
			Size = Vector3.new(d, d, d),
			CFrame = base * CFrame.new(0, d * 0.4, 0),
			Color = choisir(verts),
		})
		m.PrimaryPart = premiere
		for i = 2, boules do
			local dd = d * rng:NextNumber(0.6, 0.8)
			local cote = 1
			if i == 3 then
				cote = -1
			end
			Outils.boule(m, {
				Name = "Boule" .. i,
				Size = Vector3.new(dd, dd, dd),
				CFrame = base * CFrame.new(cote * d * 0.45, dd * 0.4, rng:NextNumber(-0.3, 0.3) * d),
				Color = choisir(verts),
			})
		end
		compter(boules)
	end

	-- ===== buisson à baies : boule verte + petites baies rose-rouge =====
	local function buissonBaies(x, z, echelle, baies)
		local m = Outils.modele(dBaies, "BuissonBaies")
		local base = CFrame.new(x, ySol, z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), 0)
		local d = 2.4 * echelle
		local rayon = d / 2
		local centreY = d * 0.42
		local b = Outils.boule(m, {
			Name = "Feuilles",
			Size = Vector3.new(d, d, d),
			CFrame = base * CFrame.new(0, centreY, 0),
			Color = Charte.ombre(vertBase),
		})
		m.PrimaryPart = b
		for i = 1, baies do
			-- baies réparties sur la moitié haute de la boule
			local a = (i / baies) * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
			local elev = rng:NextNumber(0.15, 0.9)
			local px = math.cos(a) * math.cos(elev) * rayon
			local pz = math.sin(a) * math.cos(elev) * rayon
			local py = centreY + math.sin(elev) * rayon
			local taille = 0.45 * echelle
			Outils.boule(m, {
				Name = "Baie",
				Size = Vector3.new(taille, taille, taille),
				CFrame = base * CFrame.new(px, py, pz),
				Color = Charte.alerte,
				CanCollide = false,
				CastShadow = false,
			})
		end
		compter(1 + baies)
	end

	-- ===== fleur : tige + corolle en disque =====
	local function fleur(x, z, echelle)
		local m = Outils.modele(dFleurs, "Fleur")
		local h = rng:NextNumber(0.8, 1.6) * echelle
		local tige = Outils.bloc(m, {
			Name = "Tige",
			Size = Vector3.new(0.2, h, 0.2),
			CFrame = CFrame.new(x, ySol + h / 2, z),
			Color = Charte.ombre(vertBase),
			CanCollide = false,
			CastShadow = false,
		})
		m.PrimaryPart = tige
		local d = rng:NextNumber(0.7, 1.1) * echelle
		Outils.cylindre(m, {
			Name = "Corolle",
			Size = Vector3.new(0.25, d, d),
			CFrame = CFrame.new(x, ySol + h, z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), math.rad(90)),
			Color = choisir(couleursFleurs),
			CanCollide = false,
			CastShadow = false,
		})
		compter(2)
	end

	-- ===== placement, des plus grands aux plus petits =====
	-- chaque famille : nombre visé ; la pose s'arrête dès que le budget serait dépassé
	local nbSapins = 26
	for _ = 1, nbSapins do
		local etages = rng:NextInteger(2, 3)
		local cout = 1 + etages * 4
		if reste() >= cout then
			local echelle = rng:NextNumber(0.8, 1.25)
			local x, z = trouverPlace(3 * echelle + 0.2)
			if x then
				sapin(x, z, echelle, etages)
			end
		end
	end

	local nbArbres = 42
	for _ = 1, nbArbres do
		local etages = rng:NextInteger(2, 3)
		local cout = 1 + etages
		if reste() >= cout then
			local echelle = rng:NextNumber(0.75, 1.3)
			-- demi-diagonale du plus grand bloc de feuillage
			local x, z = trouverPlace(6.5 * echelle * 0.71)
			if x then
				arbre(x, z, echelle, etages)
			end
		end
	end

	local nbBaies = 20
	for _ = 1, nbBaies do
		local baies = rng:NextInteger(3, 5)
		if reste() >= 1 + baies then
			local echelle = rng:NextNumber(0.8, 1.2)
			local x, z = trouverPlace(1.2 * echelle + 0.3)
			if x then
				buissonBaies(x, z, echelle, baies)
			end
		end
	end

	local nbBuissons = 45
	for _ = 1, nbBuissons do
		local boules = rng:NextInteger(2, 3)
		if reste() >= boules then
			local echelle = rng:NextNumber(0.7, 1.3)
			local x, z = trouverPlace(2.6 * echelle * 0.95)
			if x then
				buisson(x, z, echelle, boules)
			end
		end
	end

	-- fleurs jusqu'à épuisement du budget (ou de la place)
	local echecs = 0
	while reste() >= 2 and echecs < 30 do
		local echelle = rng:NextNumber(0.8, 1.2)
		local x, z = trouverPlace(0.6 * echelle)
		if x then
			fleur(x, z, echelle)
		else
			echecs = echecs + 1
		end
	end

	dossier:SetAttribute("Parts", partsPosees)
end

return M
