-- Constructeur ScenePhoto : diorama pour les vignettes du jeu (12 x 12 autour de Plan.lobby.scenePhoto).
-- Mini-Maison au toit orange, un Survivant jouet et son blaster face à trois Zbires,
-- mur de fond « ZSURVIE », projecteurs. La caméra conseillée est notée en attribut du dossier.
local M = {}

local BUDGET = 150
local DEMI = 6 -- demi-côté de l'emprise
local EPAISSEUR_SOCLE = 0.4
local ECHELLE_ZBIRES = 0.6

-- ===== petits utilitaires =====

-- pose une part dans un repère local ; genre : "bloc", "boule", "cylindre", "coin"
local function poser(f, genre, nom, taille, pos, couleur, extra, rot)
	local cf = f.repere * CFrame.new(pos)
	if rot then
		cf = cf * rot
	end
	local props = {
		Name = nom,
		Size = taille,
		CFrame = cf,
		Color = couleur,
		CanCollide = false,
	}
	if extra then
		for cle, valeur in pairs(extra) do
			props[cle] = valeur
		end
	end
	local O = f.Outils
	local p
	if genre == "boule" then
		p = O.boule(f.parent, props)
	elseif genre == "cylindre" then
		p = O.cylindre(f.parent, props)
	elseif genre == "coin" then
		p = O.coin(f.parent, props)
	else
		p = O.bloc(f.parent, props)
	end
	return p
end

local function compterParts(inst)
	local n = 0
	if inst:IsA("BasePart") then
		n = 1
	end
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("BasePart") then
			n = n + 1
		end
	end
	return n
end

-- ===== socle et mur de fond =====
local function socle(ctx, C, parent)
	local O, Ch = ctx.Outils, ctx.Charte
	local f = { Outils = O, parent = parent, repere = CFrame.new(C) }
	poser(f, "bloc", "Socle", Vector3.new(DEMI * 2 - 0.8, EPAISSEUR_SOCLE, DEMI * 2 - 0.8), Vector3.new(0, EPAISSEUR_SOCLE / 2, 0), Ch.prairie, { CanCollide = true })
	-- bordure en terre, coins inclus dans les côtés avant/arrière
	local bords = {
		{ Vector3.new(DEMI * 2, 0.6, 0.4), Vector3.new(0, 0.3, DEMI - 0.2) },
		{ Vector3.new(DEMI * 2, 0.6, 0.4), Vector3.new(0, 0.3, -DEMI + 0.2) },
		{ Vector3.new(0.4, 0.6, DEMI * 2 - 0.8), Vector3.new(DEMI - 0.2, 0.3, 0) },
		{ Vector3.new(0.4, 0.6, DEMI * 2 - 0.8), Vector3.new(-DEMI + 0.2, 0.3, 0) },
	}
	for i, b in ipairs(bords) do
		poser(f, "bloc", "Bordure" .. i, b[1], b[2], Ch.terre, { CanCollide = true })
	end
end

local function murDeFond(ctx, C, parent)
	local O, Ch = ctx.Outils, ctx.Charte
	local m = O.modele(parent, "MurDeFond")
	local f = { Outils = O, parent = m, repere = CFrame.new(C) }
	local zMur = -DEMI + 0.8
	local hauteur = 8
	local mur = poser(f, "bloc", "Mur", Vector3.new(DEMI * 2 - 0.8, hauteur, 0.6), Vector3.new(0, EPAISSEUR_SOCLE + hauteur / 2, zMur), Ch.nuitLabo)
	-- chapeau et bande dorée
	poser(f, "bloc", "Chapeau", Vector3.new(DEMI * 2 - 0.4, 0.5, 1), Vector3.new(0, EPAISSEUR_SOCLE + hauteur + 0.25, zMur), Ch.toit)
	poser(f, "bloc", "Bande", Vector3.new(DEMI * 2 - 0.8, 0.4, 0.1), Vector3.new(0, EPAISSEUR_SOCLE + 2.6, zMur + 0.35), Ch.dore, { Material = Enum.Material.Neon })

	-- grand titre sur la face tournée vers l'île (+Z = face « Back »)
	local titre = O.texte(mur, "Back", "ZSURVIE", { couleur = Ch.toit, pixelsParStud = 50, police = Ch.police })
	titre.Size = UDim2.fromScale(0.94, 0.42)
	titre.Position = UDim2.fromScale(0.03, 0.06)
	local contour = Instance.new("UIStroke")
	contour.Color = Ch.encre
	contour.Thickness = 6
	contour.Parent = titre
	local gui = titre.Parent
	if gui then
		gui.Name = "Titre"
		local sousTitre = Instance.new("TextLabel")
		sousTitre.Name = "SousTitre"
		sousTitre.BackgroundTransparency = 1
		sousTitre.Size = UDim2.fromScale(0.8, 0.12)
		sousTitre.Position = UDim2.fromScale(0.1, 0.5)
		sousTitre.Text = "DÉFENDS LA MAISON !"
		sousTitre.TextScaled = true
		sousTitre.Font = Ch.policeTexte
		sousTitre.TextColor3 = Ch.creme
		sousTitre.Parent = gui
		local contour2 = Instance.new("UIStroke")
		contour2.Color = Ch.encre
		contour2.Thickness = 3
		contour2.Parent = sousTitre
	end

	-- étoiles dorées posées sur le mur
	local etoiles = {
		{ -4.6, 1.6, 0.8 }, { 4.5, 1.5, 0.9 }, { -2.5, 1.2, 0.5 }, { 2.6, 1.3, 0.6 }, { 0, 1.4, 0.5 },
	}
	for i, e in ipairs(etoiles) do
		poser(f, "bloc", "Etoile" .. i, Vector3.new(e[3], e[3], 0.2), Vector3.new(e[1], EPAISSEUR_SOCLE + e[2], zMur + 0.4), Ch.dore,
			{ Material = Enum.Material.Neon }, CFrame.Angles(0, 0, math.rad(45)))
	end
	return m
end

-- ===== mini-Maison réplique (Maison au quart) =====
local function miniMaison(ctx, C, parent)
	local O, Ch = ctx.Outils, ctx.Charte
	local m = O.modele(parent, "MiniMaison")
	local L, H = 4, 3.5 -- côté et hauteur des murs
	local y0 = EPAISSEUR_SOCLE
	local f = { Outils = O, parent = m, repere = CFrame.new(C + Vector3.new(-3, y0, -2.1)) * CFrame.Angles(0, math.rad(20), 0) }
	local corps = poser(f, "bloc", "Corps", Vector3.new(L, H, L), Vector3.new(0, H / 2, 0), Ch.creme)
	m.PrimaryPart = corps
	-- pignons : losange dont seule la moitié haute dépasse des murs
	local cote = (L / 2) * math.sqrt(2)
	poser(f, "bloc", "Pignon", Vector3.new(L - 0.1, cote, cote), Vector3.new(0, H, 0), Ch.creme, nil, CFrame.Angles(math.rad(45), 0, 0))
	-- toit orange à deux pans (45°)
	local d = L / 2 + 0.3
	local ep = 0.3
	local longueur = d * math.sqrt(2) + 0.1
	local decal = ep / 2 / math.sqrt(2)
	poser(f, "bloc", "ToitAvant", Vector3.new(L + 0.5, ep, longueur), Vector3.new(0, H + (L / 2 - d / 2) + decal, -d / 2 - decal), Ch.toit, nil, CFrame.Angles(math.rad(-45), 0, 0))
	poser(f, "bloc", "ToitArriere", Vector3.new(L + 0.5, ep, longueur), Vector3.new(0, H + (L / 2 - d / 2) + decal, d / 2 + decal), Ch.ombre(Ch.toit), nil, CFrame.Angles(math.rad(45), 0, 0))
	poser(f, "bloc", "Faitage", Vector3.new(L + 0.6, 0.3, 0.3), Vector3.new(0, H + L / 2 + 0.2, 0), Ch.lumiere(Ch.toit))
	poser(f, "bloc", "Cheminee", Vector3.new(0.5, 1.2, 0.5), Vector3.new(1.1, H + 1.9, 0.6), Ch.terre)
	-- porte et fenêtres sur la face +Z locale, tournée vers la caméra
	poser(f, "bloc", "Porte", Vector3.new(0.9, 1.6, 0.1), Vector3.new(0, 0.8, L / 2 + 0.05), Ch.terre)
	poser(f, "bloc", "FenetreG", Vector3.new(0.7, 0.7, 0.1), Vector3.new(-1.2, 2.2, L / 2 + 0.05), Ch.dore, { Material = Enum.Material.Neon })
	poser(f, "bloc", "FenetreD", Vector3.new(0.7, 0.7, 0.1), Vector3.new(1.2, 2.2, L / 2 + 0.05), Ch.dore, { Material = Enum.Material.Neon })
	poser(f, "bloc", "FenetreCote", Vector3.new(0.1, 0.7, 0.9), Vector3.new(L / 2 + 0.05, 2.2, 0), Ch.dore, { Material = Enum.Material.Neon })
	poser(f, "bloc", "Marche", Vector3.new(1.3, 0.2, 0.5), Vector3.new(0, 0.1, L / 2 + 0.25), Ch.ardoise)
	return m
end

-- ===== Survivant jouet avec son blaster =====
local function survivant(ctx, C, parent)
	local O, Ch = ctx.Outils, ctx.Charte
	local m = O.modele(parent, "Survivant")
	local peau = Ch.lumiere(Ch.terre)
	-- regard vers +X, légèrement tourné vers la caméra (+Z)
	local f = { Outils = O, parent = m, repere = CFrame.new(C + Vector3.new(-1.2, EPAISSEUR_SOCLE, 1.6)) * CFrame.Angles(0, math.rad(-115), 0) }
	poser(f, "bloc", "JambeG", Vector3.new(0.45, 1.1, 0.5), Vector3.new(-0.27, 0.55, 0), Ch.ardoise)
	poser(f, "bloc", "JambeD", Vector3.new(0.45, 1.1, 0.5), Vector3.new(0.27, 0.55, 0), Ch.ardoise)
	local torse = poser(f, "bloc", "Torse", Vector3.new(1.2, 1.2, 0.7), Vector3.new(0, 1.7, 0), Ch.toit)
	m.PrimaryPart = torse
	poser(f, "bloc", "Ceinture", Vector3.new(1.25, 0.2, 0.75), Vector3.new(0, 1.15, 0), Ch.encre)
	poser(f, "bloc", "SacADos", Vector3.new(0.9, 0.9, 0.4), Vector3.new(0, 1.8, 0.55), Ch.terre)
	poser(f, "boule", "Tete", Vector3.new(1, 1, 1), Vector3.new(0, 2.8, 0), peau)
	poser(f, "bloc", "OeilG", Vector3.new(0.14, 0.24, 0.1), Vector3.new(-0.2, 2.85, -0.47), Ch.encre)
	poser(f, "bloc", "OeilD", Vector3.new(0.14, 0.24, 0.1), Vector3.new(0.2, 2.85, -0.47), Ch.encre)
	poser(f, "bloc", "Casquette", Vector3.new(1.05, 0.3, 1.05), Vector3.new(0, 3.25, 0), Ch.toit)
	poser(f, "bloc", "Visiere", Vector3.new(0.9, 0.1, 0.45), Vector3.new(0, 3.12, -0.7), Ch.ombre(Ch.toit))
	poser(f, "bloc", "BrasG", Vector3.new(0.38, 1.1, 0.38), Vector3.new(-0.8, 1.65, 0), Ch.toit)
	-- bras droit tendu vers l'avant, main sur le blaster
	poser(f, "bloc", "BrasD", Vector3.new(0.38, 0.38, 1), Vector3.new(0.8, 2, -0.4), Ch.toit)
	-- blaster
	local blaster = O.modele(m, "Blaster")
	local fb = { Outils = O, parent = blaster, repere = f.repere }
	poser(fb, "bloc", "Carcasse", Vector3.new(0.5, 0.6, 1.2), Vector3.new(0.8, 2.15, -1.1), Ch.dore)
	poser(fb, "bloc", "Poignee", Vector3.new(0.3, 0.55, 0.3), Vector3.new(0.8, 1.7, -0.85), Ch.ardoise)
	poser(fb, "cylindre", "Canon", Vector3.new(0.8, 0.35, 0.35), Vector3.new(0.8, 2.2, -2), Ch.creme, nil, CFrame.Angles(0, math.rad(90), 0))
	poser(fb, "boule", "Bout", Vector3.new(0.4, 0.4, 0.4), Vector3.new(0.8, 2.2, -2.45), Ch.gemme, { Material = Enum.Material.Neon })
	poser(fb, "bloc", "Reservoir", Vector3.new(0.3, 0.3, 0.6), Vector3.new(0.8, 2.55, -1.1), Ch.gemme, { Material = Enum.Material.Neon })
	return m
end

-- ===== Zbires : clones des gabarits, ou petite figurine de secours =====
local function nettoyerClone(modele)
	for _, d in ipairs(modele:GetDescendants()) do
		if d:IsA("BillboardGui") and d.Name == "Barre" then
			d:Destroy()
		elseif d:IsA("Script") or d:IsA("LocalScript") then
			d:Destroy()
		end
	end
	for _, d in ipairs(modele:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
		end
	end
end

local function zbireDeSecours(ctx, parent, nom, couleur, echelle)
	local O, Ch = ctx.Outils, ctx.Charte
	local m = O.modele(parent, nom)
	local s = echelle
	local f = { Outils = O, parent = m, repere = CFrame.new() }
	poser(f, "bloc", "Jambes", Vector3.new(1.1, 1.2, 0.6) * s, Vector3.new(0, 0.6, 0) * s, Ch.ombre(couleur))
	local corps = poser(f, "bloc", "Corps", Vector3.new(1.5, 1.4, 0.9) * s, Vector3.new(0, 1.9, 0) * s, couleur)
	poser(f, "bloc", "Tete", Vector3.new(1.2, 1.1, 1.1) * s, Vector3.new(0, 3.15, 0) * s, Ch.lumiere(couleur))
	poser(f, "bloc", "OeilG", Vector3.new(0.25, 0.25, 0.1) * s, Vector3.new(-0.28, 3.25, -0.57) * s, Ch.dore, { Material = Enum.Material.Neon })
	poser(f, "bloc", "OeilD", Vector3.new(0.25, 0.25, 0.1) * s, Vector3.new(0.28, 3.25, -0.57) * s, Ch.dore, { Material = Enum.Material.Neon })
	poser(f, "bloc", "BrasG", Vector3.new(0.4, 0.4, 1.3) * s, Vector3.new(-0.95, 2.2, -0.5) * s, couleur)
	poser(f, "bloc", "BrasD", Vector3.new(0.4, 0.4, 1.3) * s, Vector3.new(0.95, 2.2, -0.5) * s, couleur)
	m.PrimaryPart = corps
	m.WorldPivot = CFrame.new()
	return m
end

local function placerZbires(ctx, C, parent, budgetRestant)
	local Ch = ctx.Charte
	local groupe = ctx.Outils.modele(parent, "Zbires")
	local gabarits = nil
	if ctx.stockage then
		gabarits = ctx.stockage:FindFirstChild("Zbires")
	end
	-- regard vers -X, un peu tourné vers la caméra
	local poses = {
		{ type = "Costaud", x = 3.4, z = -1.6, angle = 105, couleur = Ch.violet },
		{ type = "Marcheur", x = 2, z = 1.4, angle = 125, couleur = Ch.violet },
		{ type = "Dore", x = 4, z = 3.4, angle = 135, couleur = Ch.dore },
	}
	local ECHELLE_SECOURS = 0.8
	local COUT_SECOURS = 7
	local reste = budgetRestant
	for _, p in ipairs(poses) do
		local modele = nil
		local gabarit = nil
		if gabarits then
			gabarit = gabarits:FindFirstChild(p.type)
		end
		if gabarit and gabarit:IsA("Model") then
			local ok, clone = pcall(function()
				return gabarit:Clone()
			end)
			if ok and clone then
				nettoyerClone(clone)
				pcall(function()
					clone:ScaleTo(clone:GetScale() * ECHELLE_ZBIRES)
				end)
				local n = compterParts(clone)
				if n <= reste then
					reste = reste - n
					modele = clone
				else
					clone:Destroy()
				end
			end
		end
		if not modele and reste >= COUT_SECOURS then
			local avant = ctx.Outils.nombreParts()
			modele = zbireDeSecours(ctx, groupe, p.type, p.couleur, ECHELLE_SECOURS)
			reste = reste - (ctx.Outils.nombreParts() - avant)
		end
		if modele then
			modele.Name = p.type
			modele:SetAttribute("Decor", true)
			local pose = CFrame.new(C + Vector3.new(p.x, EPAISSEUR_SOCLE, p.z)) * CFrame.Angles(0, math.rad(p.angle), 0)
			local okPose = pcall(function()
				modele:PivotTo(pose)
			end)
			if okPose then
				modele.Parent = groupe
			else
				modele:Destroy()
			end
		end
	end
	return groupe
end

-- ===== petits accessoires de mise en scène =====
local function accessoires(ctx, C, parent)
	local O, Ch = ctx.Outils, ctx.Charte
	local m = O.modele(parent, "Accessoires")
	local f = { Outils = O, parent = m, repere = CFrame.new(C + Vector3.new(0, EPAISSEUR_SOCLE, 0)) }
	-- pile de pièces près du Survivant
	local debout = CFrame.Angles(0, 0, math.rad(90))
	for i = 1, 3 do
		poser(f, "cylindre", "Piece" .. i, Vector3.new(0.18, 0.8, 0.8), Vector3.new(-3.4 + i * 0.05, 0.09 + (i - 1) * 0.18, 3.6), Ch.dore, { Material = Enum.Material.Neon }, debout)
	end
	poser(f, "cylindre", "PieceSeule", Vector3.new(0.18, 0.8, 0.8), Vector3.new(-2.3, 0.09, 4.3), Ch.dore, { Material = Enum.Material.Neon }, debout)
	-- gemme qui tourne
	local gemme = poser(f, "bloc", "Gemme", Vector3.new(0.6, 0.6, 0.6), Vector3.new(-4.7, 0.9, 1.2), Ch.gemme,
		{ Material = Enum.Material.Neon }, CFrame.Angles(math.rad(45), 0, math.rad(45)))
	O.animer(gemme, "tourne", 1)
	-- caisses
	poser(f, "bloc", "Caisse1", Vector3.new(1, 1, 1), Vector3.new(-4.6, 0.5, 4), Ch.terre, nil, CFrame.Angles(0, math.rad(15), 0))
	poser(f, "bloc", "Caisse2", Vector3.new(0.7, 0.7, 0.7), Vector3.new(-4.5, 1.35, 4.05), Ch.ombre(Ch.terre), nil, CFrame.Angles(0, math.rad(-10), 0))
	-- touffes d'herbe
	local touffes = { { 0.4, 4.6 }, { 5, -3.8 }, { -0.2, -3.9 }, { 1.2, 5 }, { 4.8, 0.3 }, { -1.4, 5 } }
	for i, t in ipairs(touffes) do
		poser(f, "bloc", "Herbe" .. i, Vector3.new(0.5, 0.5, 0.5), Vector3.new(t[1], 0.2, t[2]), Ch.ombre(Ch.prairie), nil, CFrame.Angles(0, math.rad(i * 37), 0))
	end
	-- petite clôture devant la Maison
	for i = 0, 2 do
		poser(f, "bloc", "Piquet" .. i, Vector3.new(0.2, 0.8, 0.2), Vector3.new(-5.2 + i * 0.9, 0.4, -0.9), Ch.creme)
	end
	poser(f, "bloc", "Lisse", Vector3.new(2, 0.15, 0.1), Vector3.new(-4.3, 0.55, -0.9), Ch.creme)
	-- flaque violette sous les Zbires (trace d'ennemi)
	poser(f, "cylindre", "Flaque", Vector3.new(0.05, 3, 3), Vector3.new(3.2, 0.03, 1.2), Ch.ombre(Ch.violet), nil, debout)
	return m
end

-- ===== projecteurs =====
local function projecteurs(ctx, C, parent)
	local O, Ch = ctx.Outils, ctx.Charte
	local m = O.modele(parent, "Projecteurs")
	local y0 = EPAISSEUR_SOCLE
	local liste = {
		{ pied = Vector3.new(-5.2, 0, 5.2), hauteur = 4, cible = Vector3.new(0, 1.5, -0.5), couleur = Ch.creme },
		{ pied = Vector3.new(5.2, 0, 5.2), hauteur = 4, cible = Vector3.new(1, 1.5, 0), couleur = Ch.lumiere(Ch.violet) },
		{ pied = nil, tete = Vector3.new(0, y0 + 9.1, -DEMI + 1), cible = Vector3.new(-1, 1, 2), couleur = Ch.lumiere(Ch.dore) },
	}
	for i, p in ipairs(liste) do
		local posTete
		if p.pied then
			local basePied = C + Vector3.new(p.pied.X, y0, p.pied.Z)
			O.bloc(m, { Name = "Pied" .. i, Size = Vector3.new(0.9, 0.3, 0.9), CFrame = CFrame.new(basePied + Vector3.new(0, 0.15, 0)), Color = Ch.ardoise, CanCollide = false })
			O.bloc(m, { Name = "Mat" .. i, Size = Vector3.new(0.25, p.hauteur, 0.25), CFrame = CFrame.new(basePied + Vector3.new(0, p.hauteur / 2, 0)), Color = Ch.encre, CanCollide = false })
			posTete = basePied + Vector3.new(0, p.hauteur + 0.3, 0)
		else
			posTete = C + p.tete
		end
		local cible = C + Vector3.new(p.cible.X, y0 + p.cible.Y, p.cible.Z)
		local cf = CFrame.lookAt(posTete, cible)
		local tete = O.bloc(m, { Name = "Tete" .. i, Size = Vector3.new(0.8, 0.8, 1.1), CFrame = cf, Color = Ch.encre, CanCollide = false })
		O.bloc(m, { Name = "Lentille" .. i, Size = Vector3.new(0.6, 0.6, 0.05), CFrame = cf * CFrame.new(0, 0, -0.57), Color = p.couleur, Material = Enum.Material.Neon, CanCollide = false })
		local spot = O.lumiere(tete, { genre = "Spot", Range = 16, Brightness = 3, Color = p.couleur })
		spot.Face = Enum.NormalId.Front
		spot.Angle = 55
		spot.Shadows = true
	end
	return m
end

-- ===== point d'entrée =====
function M.construire(ctx)
	local Plan = ctx.Plan
	if not (Plan and Plan.lobby and Plan.lobby.scenePhoto) then
		return
	end
	local C = Plan.lobby.scenePhoto
	local dossier = ctx.dossier
	local depart = ctx.Outils.nombreParts()

	socle(ctx, C, dossier)
	murDeFond(ctx, C, dossier)
	miniMaison(ctx, C, dossier)
	survivant(ctx, C, dossier)
	accessoires(ctx, C, dossier)
	projecteurs(ctx, C, dossier)

	local utilise = ctx.Outils.nombreParts() - depart
	placerZbires(ctx, C, dossier, BUDGET - utilise)

	-- cadrage conseillé pour la capture des vignettes
	local oeil = C + Vector3.new(1.5, 5.5, 15)
	local vise = C + Vector3.new(0, 2.5, -1)
	dossier:SetAttribute("CameraCFrame", CFrame.lookAt(oeil, vise))
	dossier:SetAttribute("CameraChamp", 50)
end

return M
