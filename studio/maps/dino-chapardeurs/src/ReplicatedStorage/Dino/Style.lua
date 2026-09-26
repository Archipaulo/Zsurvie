-- Style : la boîte à outils visuelle de Dino Chapardeurs (voir STYLE.md).
-- Look « simulateur Roblox » : police ronde épaisse, textes blancs cernés de noir, gros boutons
-- en dégradé qui rebondissent, étiquettes géantes flottantes au-dessus du monde, raretés en dégradé.
-- Utilisable côté serveur (étiquettes du monde) et côté client (interface).
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Charte = require(script.Parent.Charte)

local Style = {}
local hex = Charte.hex

Style.police = Enum.Font.FredokaOne
Style.policeTitre = Enum.Font.LuckiestGuy

Style.couleurs = {
	texte = hex("FFFFFF"),
	contour = hex("0E0D16"),
	argent = hex("5CFF5C"),   -- les prix et l'argent : vert vif
	revenu = hex("FFE14D"),   -- les revenus par seconde : jaune
	fond = hex("1E2240"),     -- fond des panneaux
	carte = hex("2D3363"),    -- fond des cartes dans un panneau
	carteClaire = hex("3B4380"),
	ombre = hex("000000"),
}

-- dégradés de boutons : { haut, bas }
Style.boutons = {
	vert = { hex("7CFF6B"), hex("1FAF3A") },
	bleu = { hex("62D0FF"), hex("1F6FE0") },
	violet = { hex("D28CFF"), hex("7A2FF0") },
	rouge = { hex("FF7A7A"), hex("D1203A") },
	jaune = { hex("FFE85C"), hex("F29B00") },
	orange = { hex("FFB25C"), hex("F0600F") },
	gris = { hex("C9CED8"), hex("7A8294") },
	rose = { hex("FF8AD8"), hex("E0308F") },
}

-- dégradés de rareté ; « anime » : arc-en-ciel qui défile (voir Style.animerDegrades)
Style.raretes = {
	Commun = { hex("F2F4F7"), hex("A7B0BD") },
	Rare = { hex("7FD0FF"), hex("2F6BFF") },
	Epique = { hex("E2A1FF"), hex("8A2BE2") },
	Legendaire = { hex("FFF06A"), hex("FF9A1F") },
	Mythique = { hex("FF8FA3"), hex("FF1E56") },
	Divin = { anime = "arcenciel" },
	Secret = { anime = "secret" },
}

local ARC_EN_CIEL = {
	hex("FF3B3B"), hex("FF9F1C"), hex("FFE14D"), hex("5CFF5C"), hex("3DD6F5"), hex("7A5CFF"), hex("FF5CE1"), hex("FF3B3B"),
}

local function sequence(couleurs)
	local points = {}
	local n = #couleurs
	for i, c in ipairs(couleurs) do
		table.insert(points, ColorSequenceKeypoint.new((i - 1) / math.max(n - 1, 1), c))
	end
	return ColorSequence.new(points)
end
Style.sequence = sequence

local function appliquer(inst, props)
	if not props then return end
	for cle, valeur in pairs(props) do
		if cle ~= "Parent" then inst[cle] = valeur end
	end
end

-- ===== briques =====

-- contour noir épais autour d'un texte (TextLabel, TextButton, TextBox)
function Style.contour(texte, epaisseur, couleur)
	local s = Instance.new("UIStroke")
	s.Name = "Contour"
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	s.Thickness = epaisseur or 2.5
	s.Color = couleur or Style.couleurs.contour
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = texte
	return s
end

-- bordure autour d'un cadre (le fond, pas le texte)
function Style.bordure(gui, epaisseur, couleur)
	local s = Instance.new("UIStroke")
	s.Name = "Bordure"
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Thickness = epaisseur or 3
	s.Color = couleur or Style.couleurs.contour
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = gui
	return s
end

function Style.coins(gui, rayon)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, rayon or 14)
	c.Parent = gui
	return c
end

-- dégradé vertical (haut -> bas). Attention : un UIGradient teinte AUSSI le texte de l'objet.
function Style.degrade(gui, haut, bas, rotation)
	local g = Instance.new("UIGradient")
	g.Name = "Degrade"
	g.Color = ColorSequence.new(haut, bas or haut)
	g.Rotation = rotation or 90
	g.Parent = gui
	return g
end

-- dégradé de rareté sur un texte ou un cadre (à poser sur un texte BLANC)
function Style.degradeRarete(gui, rarete)
	local def = Style.raretes[rarete] or Style.raretes.Commun
	local g = Instance.new("UIGradient")
	g.Name = "Rarete"
	if def.anime == "arcenciel" then
		g.Color = sequence(ARC_EN_CIEL)
		g.Rotation = 0
		g:SetAttribute("Anime", "arcenciel")
	elseif def.anime == "secret" then
		g.Color = sequence({ hex("FFFFFF"), hex("2A2A2A"), hex("FFFFFF"), hex("2A2A2A"), hex("FFFFFF") })
		g.Rotation = 0
		g:SetAttribute("Anime", "secret")
	else
		g.Color = ColorSequence.new(def[1], def[2])
		g.Rotation = 90
	end
	g.Parent = gui
	return g
end

-- texte blanc cerné de noir (police du jeu), fond transparent
function Style.texte(parent, props)
	props = props or {}
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = props.titre and Style.policeTitre or Style.police
	t.TextColor3 = Style.couleurs.texte
	t.TextScaled = true
	t.Text = ""
	local tailleMax = props.tailleMax
	local titre = props.titre
	local epaisseur = props.contour
	props.tailleMax = nil
	props.titre = nil
	props.contour = nil
	appliquer(t, props)
	Style.contour(t, epaisseur or 2.5)
	if tailleMax then
		local c = Instance.new("UITextSizeConstraint")
		c.MaxTextSize = tailleMax
		c.Parent = t
	end
	t.Parent = parent
	props.tailleMax, props.titre, props.contour = tailleMax, titre, epaisseur
	return t
end

-- petit « pop » d'apparition (client)
function Style.pop(gui, force)
	if not RunService:IsClient() then return end
	local echelle = gui:FindFirstChild("Pop")
	if not echelle then
		echelle = Instance.new("UIScale")
		echelle.Name = "Pop"
		echelle.Parent = gui
	end
	echelle.Scale = 0.6
	local t1 = TweenService:Create(echelle, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = force or 1.12 })
	t1.Completed:Connect(function()
		TweenService:Create(echelle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end)
	t1:Play()
end

-- gros bouton cartoon : fond en dégradé, bordure noire épaisse, coins ronds, libellé blanc cerné,
-- grossit au survol et s'écrase au clic. props : Name, Size, Position, AnchorPoint, LayoutOrder, ZIndex,
-- texte, couleur (clé de Style.boutons), icone (emoji placé à gauche ou seul), rayon.
-- Renvoie le TextButton et son libellé (TextLabel « Libelle »).
function Style.bouton(parent, props, rappel)
	props = props or {}
	local palette = Style.boutons[props.couleur or "vert"] or Style.boutons.vert
	local b = Instance.new("TextButton")
	b.Name = props.Name or "Bouton"
	b.Text = ""
	b.AutoButtonColor = false
	b.BackgroundColor3 = Color3.new(1, 1, 1)
	b.BorderSizePixel = 0
	b.Size = props.Size or UDim2.fromOffset(160, 56)
	if props.Position then b.Position = props.Position end
	if props.AnchorPoint then b.AnchorPoint = props.AnchorPoint end
	if props.LayoutOrder then b.LayoutOrder = props.LayoutOrder end
	if props.ZIndex then b.ZIndex = props.ZIndex end
	Style.coins(b, props.rayon or 14)
	Style.bordure(b, 3)
	local degrade = Style.degrade(b, palette[1], palette[2])
	degrade.Name = "Fond"
	local texte = props.texte or ""
	if props.icone and texte ~= "" then texte = props.icone .. " " .. texte elseif props.icone then texte = props.icone end
	local libelle = Style.texte(b, {
		Name = "Libelle",
		Size = UDim2.new(1, -14, 1, -10),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = texte,
		ZIndex = (props.ZIndex or 1) + 1,
		tailleMax = props.tailleMax or 34,
	})
	local echelle = Instance.new("UIScale")
	echelle.Name = "Echelle"
	echelle.Parent = b
	if RunService:IsClient() then
		local function vers(s)
			TweenService:Create(echelle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = s }):Play()
		end
		b.MouseEnter:Connect(function() vers(1.06) end)
		b.MouseLeave:Connect(function() vers(1) end)
		b.MouseButton1Down:Connect(function() vers(0.93) end)
		b.MouseButton1Up:Connect(function() vers(1.06) end)
	end
	if rappel then b.Activated:Connect(rappel) end
	b.Parent = parent
	return b, libelle
end

-- change la couleur d'un bouton créé par Style.bouton (ex. vert -> gris quand on ne peut pas payer)
function Style.couleurBouton(b, couleur)
	local palette = Style.boutons[couleur] or Style.boutons.vert
	local g = b:FindFirstChild("Fond")
	if g then g.Color = ColorSequence.new(palette[1], palette[2]) end
end

-- carte (cadre sombre arrondi et cerné) pour les listes des panneaux
function Style.carte(parent, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = Style.couleurs.carte
	f.BorderSizePixel = 0
	appliquer(f, props)
	Style.coins(f, 16)
	Style.bordure(f, 3)
	f.Parent = parent
	return f
end

-- fenêtre centrale : fond sombre, bandeau de titre en dégradé, gros X rouge rond.
-- props : Name, titre, icone, couleur (clé de Style.boutons), Size. Renvoie cadre, contenu, boutonFermer.
function Style.panneau(parent, props)
	props = props or {}
	local palette = Style.boutons[props.couleur or "bleu"] or Style.boutons.bleu
	local cadre = Instance.new("Frame")
	cadre.Name = props.Name or "Panneau"
	cadre.AnchorPoint = Vector2.new(0.5, 0.5)
	cadre.Position = UDim2.fromScale(0.5, 0.52)
	cadre.Size = props.Size or UDim2.new(0.62, 0, 0.7, 0)
	cadre.BackgroundColor3 = Style.couleurs.fond
	cadre.BorderSizePixel = 0
	cadre.Active = true
	Style.coins(cadre, 22)
	Style.bordure(cadre, 5)
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MaxSize = Vector2.new(900, 620)
	contrainte.MinSize = Vector2.new(300, 240)
	contrainte.Parent = cadre

	local bandeau = Instance.new("Frame")
	bandeau.Name = "Bandeau"
	bandeau.Size = UDim2.new(1, 0, 0, 64)
	bandeau.BackgroundColor3 = Color3.new(1, 1, 1)
	bandeau.BorderSizePixel = 0
	Style.coins(bandeau, 22)
	Style.degrade(bandeau, palette[1], palette[2])
	bandeau.Parent = cadre
	local titre = props.titre or ""
	if props.icone then titre = props.icone .. " " .. titre end
	Style.texte(bandeau, {
		Name = "Titre",
		Size = UDim2.new(1, -120, 0, 48),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = titre,
		titre = true,
		contour = 3,
		tailleMax = 42,
	})

	local fermer = Style.bouton(cadre, {
		Name = "Fermer",
		Size = UDim2.fromOffset(56, 56),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -8, 0, 8),
		couleur = "rouge",
		texte = "X",
		rayon = 28,
		ZIndex = 5,
	})

	local contenu = Instance.new("Frame")
	contenu.Name = "Contenu"
	contenu.BackgroundTransparency = 1
	contenu.Position = UDim2.new(0, 16, 0, 76)
	contenu.Size = UDim2.new(1, -32, 1, -92)
	contenu.Parent = cadre

	cadre.Parent = parent
	return cadre, contenu, fermer
end

-- ===== étiquettes du monde (BillboardGui) =====
-- lignes : liste de { texte, couleur (Color3, défaut blanc), taille (hauteur relative, défaut 1),
--   rarete (clé : dégradé de rareté), titre (police titre), nom (nom du TextLabel) }
-- props : Name, largeur (studs, défaut 10), hauteurLigne (studs, défaut 1.3), StudsOffset, MaxDistance, AlwaysOnTop
function Style.etiquette(adornee, lignes, props)
	props = props or {}
	local total = 0
	for _, l in ipairs(lignes) do total = total + (l.taille or 1) end
	local hauteurLigne = props.hauteurLigne or 1.3
	local g = Instance.new("BillboardGui")
	g.Name = props.Name or "Etiquette"
	g.Size = UDim2.new(props.largeur or 10, 0, total * hauteurLigne, 0)
	g.StudsOffset = props.StudsOffset or Vector3.new(0, 4, 0)
	g.MaxDistance = props.MaxDistance or 120
	g.AlwaysOnTop = props.AlwaysOnTop == true
	g.LightInfluence = 0
	local liste = Instance.new("UIListLayout")
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.HorizontalAlignment = Enum.HorizontalAlignment.Center
	liste.VerticalAlignment = Enum.VerticalAlignment.Bottom
	liste.Parent = g
	local textes = {}
	for i, l in ipairs(lignes) do
		local t = Style.texte(g, {
			Name = l.nom or ("Ligne" .. i),
			LayoutOrder = i,
			Size = UDim2.new(1, 0, (l.taille or 1) / total, 0),
			Text = l.texte or "",
			TextColor3 = l.couleur or Style.couleurs.texte,
			titre = l.titre,
			contour = l.contour or 3,
		})
		if l.rarete then Style.degradeRarete(t, l.rarete) end
		textes[i] = t
	end
	g.Adornee = adornee
	g.Parent = adornee
	return g, textes
end

-- ===== animation des dégradés « arc-en-ciel » et « secret » (client) =====
local animationLancee = false
function Style.animerDegrades(racines)
	if animationLancee or not RunService:IsClient() then return end
	animationLancee = true
	local suivis = {}
	local function examiner(o)
		if o:IsA("UIGradient") and o:GetAttribute("Anime") then suivis[o] = true end
	end
	for _, r in ipairs(racines) do
		for _, o in ipairs(r:GetDescendants()) do examiner(o) end
		r.DescendantAdded:Connect(examiner)
	end
	local cumul = 0
	RunService.RenderStepped:Connect(function(dt)
		cumul = cumul + dt
		if cumul < 1 / 30 then return end
		local t = os.clock()
		cumul = 0
		for g in pairs(suivis) do
			if g.Parent then
				local x = (t * 0.35) % 2 - 1
				g.Offset = Vector2.new(x, 0)
			else
				suivis[g] = nil
			end
		end
	end)
end

-- ===== montants =====
function Style.argent(n)
	return Charte.argent(n)
end
function Style.revenu(n)
	return Charte.argent(n) .. "/s"
end

return Style
