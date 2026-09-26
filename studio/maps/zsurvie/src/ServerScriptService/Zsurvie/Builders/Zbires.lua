-- Constructeur Zbires : fabrique les gabarits des ennemis dans ServerStorage.Zsurvie.Zbires.
-- Un Model par type d'Equilibrage.zbires, style jouet en blocs, construit au sol en (0, 0, 0),
-- regard vers -Z, pivot au sol sous le modèle. Systemes/Horde clone ces gabarits.
local M = {}

local ORDRE = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local BUDGET = 25
local BUDGET_COLOSSE = 40

-- ===== fabrique de parts =====
-- f : { m (Model), s (échelle), repere (CFrame appliqué aux parts du haut), Outils, n (compteur) }
local function part(f, genre, nom, taille, pos, couleur, extra, rot)
	local cf = f.repere * CFrame.new(pos * f.s)
	if rot then
		cf = cf * rot
	end
	local props = {
		Name = nom,
		Size = taille * f.s,
		CFrame = cf,
		Color = couleur,
		Anchored = true,
		CanCollide = false,
	}
	if f.materiau then
		props.Material = f.materiau
	end
	if f.transparence then
		props.Transparency = f.transparence
	end
	if extra then
		for cle, valeur in pairs(extra) do
			props[cle] = valeur
		end
	end
	local p
	if genre == "boule" then
		p = f.Outils.boule(f.m, props)
	elseif genre == "cylindre" then
		p = f.Outils.cylindre(f.m, props)
	else
		p = f.Outils.bloc(f.m, props)
	end
	-- sécurité : ces réglages ne doivent pas être écrasés par les props
	p.Anchored = true
	p.CanCollide = false
	f.n = f.n + 1
	return p
end

local NEON = { Material = Enum.Material.Neon, Transparency = 0 }

-- ===== silhouette humanoïde commune =====
-- o : couleur, yeux, largeur, epaisseur, jambe, jambeLarg, hauteurCorps, bras, tete, socle, inclinaison
local function humanoide(f, C, o)
	local couleur = o.couleur or C.violet
	local largeur = o.largeur or 1
	local epaisseur = o.epaisseur or 1
	local hj = o.jambe or 1.6
	local lj = o.jambeLarg or 0.8
	local hc = o.hauteurCorps or 2
	local ba = 0.6 * (o.bras or 1)
	local t = o.tete or 1.6
	local socle = o.socle or 0
	local wc = 2 * largeur
	local dc = 1.2 * epaisseur
	local k = t / 1.6

	local ombre = C.ombre(couleur)
	local clair = C.lumiere(couleur)

	-- jambes (jamais inclinées)
	f.repere = CFrame.new()
	local xj = wc / 4 + 0.02
	part(f, "bloc", "JambeG", Vector3.new(lj, hj, lj), Vector3.new(-xj, socle + hj / 2, 0), ombre)
	part(f, "bloc", "JambeD", Vector3.new(lj, hj, lj), Vector3.new(xj, socle + hj / 2, 0), ombre)

	-- le haut du corps peut pencher vers l'avant (-Z) autour des hanches
	local hanche = socle + hj
	if o.inclinaison and o.inclinaison ~= 0 then
		local yh = hanche * f.s
		f.repere = CFrame.new(0, yh, 0) * CFrame.Angles(-o.inclinaison, 0, 0) * CFrame.new(0, -yh, 0)
	end

	local corpsY = hanche + hc / 2
	local corps = part(f, "bloc", "Corps", Vector3.new(wc, hc, dc), Vector3.new(0, corpsY, 0), couleur)

	-- bras tendus vers l'avant, à la manière des zombies
	local yb = corpsY + hc / 2 - ba / 2 - 0.1
	local lb = 1.8 * (o.longueurBras or 1)
	part(f, "bloc", "BrasG", Vector3.new(ba, ba, lb), Vector3.new(-(wc / 2 + ba / 2), yb, -lb / 2 + 0.2), ombre)
	part(f, "bloc", "BrasD", Vector3.new(ba, ba, lb), Vector3.new(wc / 2 + ba / 2, yb, -lb / 2 + 0.2), ombre)

	local teteY = hanche + hc + t / 2
	part(f, "bloc", "Tete", Vector3.new(t, t, t), Vector3.new(0, teteY, 0), clair)

	local zFace = -t / 2 - 0.04
	local couleurYeux = o.yeux or C.creme
	part(f, "bloc", "OeilG", Vector3.new(0.35, 0.35, 0.1) * k, Vector3.new(-0.35 * k, teteY + 0.2 * k, zFace), couleurYeux, NEON)
	part(f, "bloc", "OeilD", Vector3.new(0.35, 0.35, 0.1) * k, Vector3.new(0.35 * k, teteY + 0.2 * k, zFace), couleurYeux, NEON)
	part(f, "bloc", "Bouche", Vector3.new(0.8, 0.2, 0.1) * k, Vector3.new(0, teteY - 0.35 * k, zFace), C.encre, { Transparency = 0 })

	return {
		corps = corps,
		corpsY = corpsY,
		hc = hc,
		wc = wc,
		dc = dc,
		teteY = teteY,
		t = t,
		hautTete = teteY + t / 2,
		zFace = zFace,
		k = k,
	}
end

-- ===== silhouette ronde (Gluant, MiniGluant) =====
local function gluant(f, C, couleur)
	local ombre = C.ombre(couleur)
	local clair = C.lumiere(couleur)
	f.repere = CFrame.new()
	f.transparence = 0.3

	part(f, "boule", "JambeG", Vector3.new(0.9, 0.9, 0.9), Vector3.new(-0.7, 0.45, 0), ombre)
	part(f, "boule", "JambeD", Vector3.new(0.9, 0.9, 0.9), Vector3.new(0.7, 0.45, 0), ombre)
	local corps = part(f, "boule", "Corps", Vector3.new(3.2, 3.2, 3.2), Vector3.new(0, 2, 0), couleur)
	part(f, "boule", "BrasG", Vector3.new(0.8, 0.8, 0.8), Vector3.new(-1.6, 2.2, -0.4), ombre)
	part(f, "boule", "BrasD", Vector3.new(0.8, 0.8, 0.8), Vector3.new(1.6, 2.2, -0.4), ombre)
	part(f, "boule", "Tete", Vector3.new(2, 2, 2), Vector3.new(0, 3.9, 0), clair)
	-- gouttes qui coulent sur les flancs
	part(f, "boule", "Goutte", Vector3.new(0.5, 0.5, 0.5), Vector3.new(-1.1, 1.1, -0.9), clair)
	part(f, "boule", "Goutte", Vector3.new(0.4, 0.4, 0.4), Vector3.new(1.2, 2.9, 0.6), clair)

	f.transparence = nil
	-- noyau sombre visible à travers la gelée
	part(f, "boule", "Noyau", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.9, 0), ombre)
	part(f, "boule", "OeilG", Vector3.new(0.45, 0.45, 0.45), Vector3.new(-0.4, 4.1, -0.85), C.creme, NEON)
	part(f, "boule", "OeilD", Vector3.new(0.45, 0.45, 0.45), Vector3.new(0.4, 4.1, -0.85), C.creme, NEON)
	part(f, "bloc", "Bouche", Vector3.new(0.7, 0.18, 0.1), Vector3.new(0, 3.55, -0.95), C.encre)

	return { corps = corps, hautTete = 4.9 }
end

-- ===== détails propres à chaque type =====
local construction = {}

function construction.Marcheur(f, C)
	return humanoide(f, C, {})
end

function construction.Rapide(f, C)
	local info = humanoide(f, C, {
		largeur = 0.75,
		epaisseur = 0.8,
		jambe = 1.9,
		jambeLarg = 0.6,
		hauteurCorps = 1.8,
		bras = 0.75,
		longueurBras = 1.2,
		tete = 1.4,
		inclinaison = 0.35,
	})
	-- mèche en pointe, penchée avec le haut du corps
	part(f, "bloc", "Meche", Vector3.new(0.3, 0.5, 0.9), Vector3.new(0, info.hautTete + 0.2, 0.2), C.ombre(C.violet), nil, CFrame.Angles(0.5, 0, 0))
	return info
end

function construction.Costaud(f, C)
	local info = humanoide(f, C, {
		largeur = 1.5,
		epaisseur = 1.3,
		jambe = 1.3,
		jambeLarg = 1.1,
		hauteurCorps = 2.2,
		bras = 1.5,
		tete = 1.5,
	})
	-- piquants : cubes tournés, pointe vers l'extérieur
	local rot = CFrame.Angles(math.rad(45), 0, math.rad(45))
	local haut = info.corpsY + info.hc / 2
	local dos = info.dc / 2 + 0.1
	local taille = Vector3.new(0.5, 0.5, 0.5)
	part(f, "bloc", "Piquant", taille, Vector3.new(-info.wc / 2 + 0.35, haut + 0.1, 0), C.alerte, nil, rot)
	part(f, "bloc", "Piquant", taille, Vector3.new(info.wc / 2 - 0.35, haut + 0.1, 0), C.alerte, nil, rot)
	part(f, "bloc", "Piquant", taille, Vector3.new(-0.6, info.corpsY + 0.5, dos), C.alerte, nil, rot)
	part(f, "bloc", "Piquant", taille, Vector3.new(0.6, info.corpsY + 0.5, dos), C.alerte, nil, rot)
	part(f, "bloc", "Piquant", taille, Vector3.new(0, info.corpsY - 0.4, dos), C.alerte, nil, rot)
	part(f, "bloc", "Piquant", Vector3.new(0.4, 0.4, 0.4), Vector3.new(0, info.hautTete + 0.05, 0), C.alerte, nil, rot)
	part(f, "bloc", "Ceinture", Vector3.new(info.wc + 0.1, 0.35, info.dc + 0.1), Vector3.new(0, info.corpsY - info.hc / 2 + 0.25, 0), C.encre)
	return info
end

function construction.Dore(f, C)
	f.materiau = Enum.Material.Foil
	local info = humanoide(f, C, { couleur = C.dore })
	f.materiau = nil
	-- scintillement et halo doré
	pcall(function()
		local eclat = Instance.new("Sparkles")
		eclat.SparkleColor = C.dore
		eclat.Parent = info.corps
	end)
	pcall(function()
		local l = Instance.new("PointLight")
		l.Color = C.dore
		l.Range = 8 * f.s
		l.Brightness = 1.2
		l.Parent = info.corps
	end)
	part(f, "bloc", "Piece", Vector3.new(0.7, 0.7, 0.12), Vector3.new(0, info.corpsY + 0.2, -info.dc / 2 - 0.06), C.lumiere(C.dore), NEON, CFrame.Angles(0, 0, math.rad(45)))
	return info
end

function construction.Sauteur(f, C)
	local socle = 1.0
	local info = humanoide(f, C, { socle = socle, jambe = 0.9, largeur = 0.9, tete = 1.5 })
	-- ressorts sous chaque jambe : anneaux empilés (axe vertical)
	local xj = info.wc / 4 + 0.02
	local vertical = CFrame.Angles(0, 0, math.rad(90))
	local cotes = { -xj, xj }
	for _, x in ipairs(cotes) do
		part(f, "bloc", "Pied", Vector3.new(1, 0.2, 1), Vector3.new(x, 0.1, 0), C.ombre(C.violet))
		part(f, "cylindre", "Ressort", Vector3.new(0.2, 0.85, 0.85), Vector3.new(x, 0.35, 0), C.ardoise, nil, vertical)
		part(f, "cylindre", "Ressort", Vector3.new(0.2, 0.85, 0.85), Vector3.new(x, 0.6, 0), C.lumiere(C.ardoise), nil, vertical)
		part(f, "cylindre", "Ressort", Vector3.new(0.2, 0.85, 0.85), Vector3.new(x, 0.85, 0), C.ardoise, nil, vertical)
		part(f, "bloc", "Tige", Vector3.new(0.25, socle, 0.25), Vector3.new(x, socle / 2, 0), C.ombre(C.ardoise))
	end
	return info
end

function construction.Gluant(f, C)
	return gluant(f, C, C.violet)
end

function construction.MiniGluant(f, C)
	return gluant(f, C, C.lumiere(C.violet))
end

function construction.Volant(f, C)
	local info = humanoide(f, C, { jambe = 1.2, jambeLarg = 0.6, largeur = 0.9, tete = 1.5 })
	-- ailes : un pan principal et une pointe plus relevée de chaque côté
	local l1, l2 = 2.6, 1.8
	local a1, a2 = math.rad(20), math.rad(38)
	local y0 = info.corpsY + 0.5
	local x0 = info.wc / 2
	local z = 0.5
	local ombre = C.ombre(C.violet)
	local clair = C.lumiere(C.violet)
	local cotes = { -1, 1 }
	for _, sens in ipairs(cotes) do
		local nom = "AileD"
		if sens < 0 then
			nom = "AileG"
		end
		local cx1 = x0 + math.cos(a1) * l1 / 2
		local cy1 = y0 + math.sin(a1) * l1 / 2
		local xBout = x0 + math.cos(a1) * l1
		local yBout = y0 + math.sin(a1) * l1
		local cx2 = xBout + math.cos(a2) * l2 / 2 - 0.1
		local cy2 = yBout + math.sin(a2) * l2 / 2
		part(f, "bloc", nom, Vector3.new(l1, 0.15, 1.5), Vector3.new(sens * cx1, cy1, z), ombre, { Transparency = 0.1 }, CFrame.Angles(0, 0, sens * a1))
		part(f, "bloc", nom .. "Pointe", Vector3.new(l2, 0.15, 1.1), Vector3.new(sens * cx2, cy2, z + 0.1), clair, { Transparency = 0.1 }, CFrame.Angles(0, 0, sens * a2))
	end
	return info
end

function construction.Casque(f, C)
	local info = humanoide(f, C, { largeur = 1.05, epaisseur = 1.05 })
	local h = info.hautTete
	local t = info.t
	part(f, "bloc", "Casque", Vector3.new(t + 0.3, 0.7, t + 0.3), Vector3.new(0, h - 0.05, 0), C.ardoise)
	part(f, "bloc", "Visiere", Vector3.new(t + 0.3, 0.25, 0.5), Vector3.new(0, h - 0.3, -t / 2 - 0.2), C.ombre(C.ardoise))
	part(f, "bloc", "Crete", Vector3.new(0.3, 0.45, t + 0.1), Vector3.new(0, h + 0.5, 0), C.lumiere(C.ardoise))
	part(f, "bloc", "Plastron", Vector3.new(info.wc - 0.2, info.hc - 0.6, 0.2), Vector3.new(0, info.corpsY + 0.1, -info.dc / 2 - 0.1), C.ardoise)
	info.hautMax = h + 0.75
	return info
end

function construction.Colosse(f, C)
	local info = humanoide(f, C, {
		largeur = 1.4,
		epaisseur = 1.3,
		jambe = 1.5,
		jambeLarg = 1.0,
		hauteurCorps = 2.4,
		bras = 1.4,
		tete = 1.7,
		yeux = C.alerte,
	})
	local h = info.hautTete
	local t = info.t
	local haut = info.corpsY + info.hc / 2

	-- couronne dorée : bandeau, 4 pointes aux coins, 4 pointes au milieu des côtés, joyau
	local or1 = C.dore
	local or2 = C.lumiere(C.dore)
	local foil = { Material = Enum.Material.Foil }
	local b = t / 2 + 0.05
	part(f, "bloc", "Couronne", Vector3.new(t + 0.2, 0.4, t + 0.2), Vector3.new(0, h + 0.15, 0), or1, foil)
	local coins = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }
	for _, c in ipairs(coins) do
		part(f, "bloc", "PointeCouronne", Vector3.new(0.35, 0.6, 0.35), Vector3.new(c[1] * b, h + 0.6, c[2] * b), or2, foil)
	end
	local milieux = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }
	for _, c in ipairs(milieux) do
		part(f, "bloc", "PointeCouronne", Vector3.new(0.3, 0.45, 0.3), Vector3.new(c[1] * b, h + 0.52, c[2] * b), or1, foil)
	end
	part(f, "bloc", "Joyau", Vector3.new(0.35, 0.35, 0.12), Vector3.new(0, h + 0.15, -t / 2 - 0.16), C.gemme, NEON, CFrame.Angles(0, 0, math.rad(45)))

	-- épaulettes et piquants
	local rot = CFrame.Angles(math.rad(45), 0, math.rad(45))
	local cotes = { -1, 1 }
	for _, sens in ipairs(cotes) do
		local xe = sens * (info.wc / 2 + 0.3)
		part(f, "bloc", "Epaulette", Vector3.new(1.3, 0.5, 1.5), Vector3.new(xe, haut + 0.1, 0), C.ardoise)
		part(f, "bloc", "Piquant", Vector3.new(0.45, 0.45, 0.45), Vector3.new(xe, haut + 0.45, -0.35), C.alerte, nil, rot)
		part(f, "bloc", "Piquant", Vector3.new(0.45, 0.45, 0.45), Vector3.new(xe, haut + 0.45, 0.35), C.alerte, nil, rot)
	end

	-- ceinture et crocs
	part(f, "bloc", "Ceinture", Vector3.new(info.wc + 0.1, 0.4, info.dc + 0.1), Vector3.new(0, info.corpsY - info.hc / 2 + 0.3, 0), C.encre)
	local k = info.k
	part(f, "bloc", "Croc", Vector3.new(0.15, 0.2, 0.08) * k, Vector3.new(-0.22 * k, info.teteY - 0.47 * k, info.zFace - 0.01), C.creme)
	part(f, "bloc", "Croc", Vector3.new(0.15, 0.2, 0.08) * k, Vector3.new(0.22 * k, info.teteY - 0.47 * k, info.zFace - 0.01), C.creme)

	-- lueur rouge des yeux
	pcall(function()
		local l = Instance.new("PointLight")
		l.Color = C.alerte
		l.Range = 6 * f.s
		l.Brightness = 1
		l.Parent = info.corps
	end)

	info.hautMax = h + 0.9
	return info
end

-- ===== barre de vie =====
local function barreDeVie(C, corps, s, hauteurMax)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Barre"
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.MaxDistance = 150
	gui.Size = UDim2.new(3 * s, 0, 0.4 * s, 0)
	gui.StudsOffset = Vector3.new(0, hauteurMax - corps.Position.Y + 0.8 * s, 0)
	gui.Adornee = corps

	local fond = Instance.new("Frame")
	fond.Name = "Fond"
	fond.Size = UDim2.fromScale(1, 1)
	fond.BackgroundColor3 = C.encre
	fond.BorderSizePixel = 0
	fond.Parent = gui

	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(1, 1)
	remplissage.BackgroundColor3 = C.alerte
	remplissage.BorderSizePixel = 0
	remplissage.Parent = fond

	gui.Parent = corps
	return gui
end

-- ===== assemblage d'un gabarit =====
local function fabriquer(ctx, nomType, stats, dossierZbires)
	local C = ctx.Charte
	local s = 1
	if type(stats) == "table" and type(stats.taille) == "number" and stats.taille > 0 then
		s = stats.taille
	end

	local m = Instance.new("Model")
	m.Name = nomType
	local f = { m = m, s = s, repere = CFrame.new(), Outils = ctx.Outils, n = 0 }

	local fn = construction[nomType] or construction.Marcheur
	local info = fn(f, C)
	local corps = info.corps

	-- pivot au sol, sous le modèle, regard vers -Z
	m.PrimaryPart = corps
	local ok = pcall(function()
		corps.PivotOffset = corps.CFrame:Inverse()
	end)
	if not ok then
		pcall(function()
			m.WorldPivot = CFrame.new()
		end)
	end

	local hautMax = (info.hautMax or info.hautTete) * s
	barreDeVie(C, corps, s, hautMax)
	m:SetAttribute("Type", nomType)

	local budget = BUDGET
	if nomType == "Colosse" then
		budget = BUDGET_COLOSSE
	end
	if f.n > budget then
		warn("[Zsurvie] gabarit « " .. nomType .. " » : " .. f.n .. " parts pour un budget de " .. budget)
	end

	local ancien = dossierZbires:FindFirstChild(nomType)
	if ancien then
		ancien:Destroy()
	end
	m.Parent = dossierZbires
	return m
end

function M.construire(ctx)
	-- dossier de stockage (ServerStorage.Zsurvie.Zbires), jamais dans le Workspace
	local stockage = ctx.stockage
	if not stockage then
		pcall(function()
			local ServerStorage = game:GetService("ServerStorage")
			stockage = ServerStorage:FindFirstChild("Zsurvie") or ctx.Outils.dossier(ServerStorage, "Zsurvie")
		end)
	end
	if not stockage then
		warn("[Zsurvie] Zbires : stockage serveur introuvable")
		return
	end
	local dossierZbires = stockage:FindFirstChild("Zbires")
	if not dossierZbires then
		dossierZbires = ctx.Outils.dossier(stockage, "Zbires")
	end

	local stats = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.zbires) == "table" then
		stats = ctx.Equilibrage.zbires
	end

	-- types connus dans l'ordre, puis les éventuels types ajoutés à l'équilibrage
	local liste, vus = {}, {}
	for _, nom in ipairs(ORDRE) do
		table.insert(liste, nom)
		vus[nom] = true
	end
	local extras = {}
	for nom in pairs(stats) do
		if type(nom) == "string" and not vus[nom] then
			table.insert(extras, nom)
		end
	end
	table.sort(extras)
	for _, nom in ipairs(extras) do
		table.insert(liste, nom)
	end

	for _, nom in ipairs(liste) do
		local ok, err = pcall(fabriquer, ctx, nom, stats[nom], dossierZbires)
		if not ok then
			warn("[Zsurvie] gabarit « " .. nom .. " » : " .. tostring(err))
		end
	end
end

return M
