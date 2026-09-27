-- Interface Index (Dinodex) : le carnet des espèces découvertes.
-- S'ouvre sur Bus « OuvrirPanneau » == "Index" ; se ferme par le X rouge, Échap (ou bouton B), clic sur le voile et Bus « FermerPanneaux ».
-- Grille des espèces triées par rareté, onglets par rareté, en-tête « x/20 découverts » et bonus actuel (BonusIndex).
-- Mise à jour en direct sur les attributs Index_<Espece> et BonusIndex posés par le serveur (Systemes/Index).
-- Look « simulateur Roblox » (STYLE.md §4) : tout passe par ctx.Style ; ouverture en pop, fermeture en fondu.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

-- cartes : largeur par défaut (ajustée au panneau en jeu), hauteur fixe, écart régulier
local LARGEUR_CARTE = 136
local LARGEUR_MIN = 118
local LARGEUR_MAX = 156
local HAUTEUR_CARTE = 150
local ECART = 12
local MARGE_GAUCHE = 4
local MARGE_DROITE = 14

-- onglets : hauteur d'une ligne et écart
local HAUTEUR_ONGLET = 32
local ECART_ONGLET = 6

local function rond(gui)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = gui
	return c
end

local function jouer(inst, duree, buts, style, sens)
	local ok, t = pcall(function()
		return TweenService:Create(inst, TweenInfo.new(duree, style or Enum.EasingStyle.Quad, sens or Enum.EasingDirection.Out), buts)
	end)
	if ok and t then
		t:Play()
		return t
	end
	return nil
end

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Bus = ctx.Bus
	local joueur = ctx.joueur
	local E = ctx.Equilibrage
	local Style = ctx.Style or require(game:GetService("ReplicatedStorage").Dino.Style)
	local couleurs = Style.couleurs
	local blanc = Color3.new(1, 1, 1)
	local noir = Color3.new(0, 0, 0)

	local RARETES = E.raretes or {}
	local ESPECES = E.especes or {}
	local reglages = E.index or {}
	local BONUS_RARETE = tonumber(reglages.bonusCompletRarete) or 0.1

	local FOND_INCONNU = couleurs.fond:Lerp(couleurs.ombre, 0.35)
	local MEDAILLON_INCONNU = couleurs.fond:Lerp(couleurs.ombre, 0.55)
	local VOILE_TRANSPARENCE = 0.45

	-- ===== utilitaires =====
	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function argentTexte(n)
		local ok, t = pcall(Style.argent, n)
		if ok and type(t) == "string" then return t end
		return "$" .. tostring(math.floor(tonumber(n) or 0))
	end

	local function revenuTexte(n)
		local ok, t = pcall(Style.revenu, n)
		if ok and type(t) == "string" then return t end
		return argentTexte(n) .. "/s"
	end

	local function ordreRarete(rarete)
		local fiche = RARETES[rarete]
		if type(fiche) == "table" and tonumber(fiche.ordre) then
			return tonumber(fiche.ordre)
		end
		return 99
	end

	local function nomRarete(rarete)
		local fiche = RARETES[rarete]
		if type(fiche) == "table" and type(fiche.nom) == "string" then
			return fiche.nom
		end
		return tostring(rarete)
	end

	-- couleur franche d'une rareté (liserés) : bas du dégradé, sinon la Charte
	local function couleurRarete(rarete)
		local def = Style.raretes[rarete]
		if type(def) == "table" and typeof(def[2]) == "Color3" then return def[2] end
		if type(def) == "table" and def.anime == "arcenciel" then return Color3.fromRGB(255, 92, 225) end
		if type(def) == "table" and def.anime == "secret" then return blanc end
		local c = Charte.raretes and Charte.raretes[rarete]
		if typeof(c) == "Color3" then return c end
		return couleurs.texte
	end

	local function decouverte(espece)
		return joueur:GetAttribute("Index_" .. espece) == true
	end

	local function pourcent(x)
		local p = math.floor((tonumber(x) or 0) * 100 + 0.5)
		return tostring(p) .. "%"
	end

	-- dégradé « deux teintes » posé sur le fond d'un cadre créé par Style.carte / Style.bouton
	local function teinterFond(gui, haut, bas)
		local g = gui:FindFirstChild("Fond")
		if g and g:IsA("UIGradient") then
			g.Color = ColorSequence.new(haut, bas)
		end
	end

	-- ===== espèces triées : rareté, puis prix, puis nom =====
	local liste = {}
	for cle, fiche in pairs(ESPECES) do
		if type(fiche) == "table" and type(fiche.rarete) == "string" then
			table.insert(liste, { cle = cle, fiche = fiche })
		end
	end
	table.sort(liste, function(a, b)
		local oa, ob = ordreRarete(a.fiche.rarete), ordreRarete(b.fiche.rarete)
		if oa ~= ob then return oa < ob end
		local pa, pb = tonumber(a.fiche.prix) or 0, tonumber(b.fiche.prix) or 0
		if pa ~= pb then return pa < pb end
		return tostring(a.cle) < tostring(b.cle)
	end)
	local TOTAL = #liste

	-- raretés présentes, dans l'ordre
	local raretesPresentes = {}
	local dejaVue = {}
	for _, entree in ipairs(liste) do
		local r = entree.fiche.rarete
		if not dejaVue[r] then
			dejaVue[r] = true
			table.insert(raretesPresentes, r)
		end
	end

	-- ===== fond sombre et panneau =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Index"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundColor3 = couleurs.ombre
	ecran.BackgroundTransparency = VOILE_TRANSPARENCE
	ecran.BorderSizePixel = 0
	ecran.Visible = false
	ecran.ZIndex = 20
	ecran.Parent = ctx.gui

	-- cliquer sur le voile ferme le panneau
	local voile = Instance.new("TextButton")
	voile.Name = "Voile"
	voile.Size = UDim2.fromScale(1, 1)
	voile.BackgroundTransparency = 1
	voile.Text = ""
	voile.AutoButtonColor = false
	voile.ZIndex = 1
	voile.Parent = ecran

	local panneau, contenu, boutonFermer = Style.panneau(ecran, {
		Name = "Panneau",
		titre = "DINODEX",
		icone = "📖",
		couleur = "bleu",
		Size = UDim2.new(0.94, 0, 0.86, 0),
	})
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.ZIndex = 2 -- au-dessus du voile : un clic sur le panneau ne le traverse pas
	local limite = panneau:FindFirstChildOfClass("UISizeConstraint")
	if limite then
		limite.MaxSize = Vector2.new(780, 560)
		limite.MinSize = Vector2.new(290, 300)
	end
	-- l'ombre portée (cadre frère « PanneauOmbre ») garde sa propre contrainte : on la cale sur celle du panneau
	local ombreP = ecran:FindFirstChild("PanneauOmbre")
	local lo = ombreP and ombreP:FindFirstChildOfClass("UISizeConstraint")
	if lo and limite then
		lo.MaxSize = limite.MaxSize
		lo.MinSize = limite.MinSize
	end

	local fermer = nil
	boutonFermer.Activated:Connect(function()
		son("clic")
		if fermer then fermer() end
	end)

	-- ===== en-tête : « 12/20 découverts » + pastille de bonus =====
	local entete = Instance.new("Frame")
	entete.Name = "Entete"
	entete.BackgroundTransparency = 1
	entete.Size = UDim2.new(1, 0, 0, 34)
	entete.Parent = contenu

	local compteur = Style.texte(entete, {
		Name = "Compteur",
		Position = UDim2.new(0, 2, 0, 0),
		Size = UDim2.new(0.52, -8, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		RichText = true,
		Text = "",
		contour = 3,
		tailleMax = 28,
	})

	local cadreBonus = Instance.new("Frame")
	cadreBonus.Name = "CadreBonus"
	cadreBonus.AnchorPoint = Vector2.new(1, 0.5)
	cadreBonus.Position = UDim2.new(1, -2, 0.5, 0)
	cadreBonus.Size = UDim2.new(0.46, 0, 0, 30)
	cadreBonus.BackgroundColor3 = couleurs.ombre
	cadreBonus.BackgroundTransparency = 0.45
	cadreBonus.BorderSizePixel = 0
	rond(cadreBonus)
	local bordBonus = Style.bordure(cadreBonus, 2)
	local limiteBonus = Instance.new("UISizeConstraint")
	limiteBonus.MaxSize = Vector2.new(250, 30)
	limiteBonus.Parent = cadreBonus
	cadreBonus.Parent = entete
	local bonusTexte = Style.texte(cadreBonus, {
		Name = "Bonus",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -20, 1, -8),
		TextColor3 = couleurs.revenu,
		Text = "",
		contour = 2.5,
		tailleMax = 18,
	})

	-- barre de progression : rail sombre cerné, remplissage vert brillant, pourcentage au centre
	local barre = Instance.new("Frame")
	barre.Name = "Progression"
	barre.Position = UDim2.new(0, 2, 0, 42)
	barre.Size = UDim2.new(1, -4, 0, 18)
	barre.BackgroundColor3 = MEDAILLON_INCONNU
	barre.BorderSizePixel = 0
	barre.ClipsDescendants = true
	rond(barre)
	Style.bordure(barre, 3)
	barre.Parent = contenu
	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(0, 1)
	remplissage.BackgroundColor3 = blanc
	remplissage.BorderSizePixel = 0
	remplissage.ZIndex = 1
	rond(remplissage)
	Style.degrade(remplissage, Style.boutons.vert[1], Style.boutons.vert[2])
	remplissage.Parent = barre
	local refletBarre = Instance.new("Frame")
	refletBarre.Name = "Reflet"
	refletBarre.Position = UDim2.new(0, 4, 0, 2)
	refletBarre.Size = UDim2.new(1, -8, 0.4, 0)
	refletBarre.BackgroundColor3 = blanc
	refletBarre.BackgroundTransparency = 0.6
	refletBarre.BorderSizePixel = 0
	refletBarre.ZIndex = 2
	rond(refletBarre)
	refletBarre.Parent = remplissage
	local pourcentTexte = Style.texte(barre, {
		Name = "Pourcent",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 80, 1, -2),
		Text = "",
		ZIndex = 3,
		contour = 2,
		tailleMax = 15,
	})

	-- ===== onglets par rareté : une grille de pastilles lisibles (1 ou 2 lignes, sans défilement) =====
	local nbOnglets = #raretesPresentes + 1
	local lignesOnglets = 1
	if nbOnglets > 4 then lignesOnglets = 2 end
	local colonnesOnglets = math.max(1, math.ceil(nbOnglets / lignesOnglets))
	local hauteurOnglets = lignesOnglets * HAUTEUR_ONGLET + (lignesOnglets - 1) * ECART_ONGLET
	local hautOnglets = 70

	local bandeOnglets = Instance.new("Frame")
	bandeOnglets.Name = "Onglets"
	bandeOnglets.Position = UDim2.new(0, 2, 0, hautOnglets)
	bandeOnglets.Size = UDim2.new(1, -4, 0, hauteurOnglets)
	bandeOnglets.BackgroundTransparency = 1
	bandeOnglets.BorderSizePixel = 0
	bandeOnglets.Parent = contenu
	local dispoOnglets = Instance.new("UIGridLayout")
	dispoOnglets.CellSize = UDim2.new(1 / colonnesOnglets, -math.ceil(ECART_ONGLET * (colonnesOnglets - 1) / colonnesOnglets), 0, HAUTEUR_ONGLET)
	dispoOnglets.CellPadding = UDim2.new(0, ECART_ONGLET, 0, ECART_ONGLET)
	dispoOnglets.FillDirection = Enum.FillDirection.Horizontal
	dispoOnglets.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dispoOnglets.SortOrder = Enum.SortOrder.LayoutOrder
	dispoOnglets.Parent = bandeOnglets

	-- ===== grille =====
	local hautGrille = hautOnglets + hauteurOnglets + 10
	local grille = Instance.new("ScrollingFrame")
	grille.Name = "Grille"
	grille.Position = UDim2.new(0, 0, 0, hautGrille)
	grille.Size = UDim2.new(1, 0, 1, -(hautGrille + 42)) -- 8 px d'écart avec le pied de page
	grille.BackgroundTransparency = 1
	grille.BorderSizePixel = 0
	grille.ScrollBarThickness = 8
	grille.ScrollBarImageColor3 = Style.boutons.bleu[1]
	grille.ScrollBarImageTransparency = 0.15
	grille.ScrollingDirection = Enum.ScrollingDirection.Y
	grille.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grille.CanvasSize = UDim2.new(0, 0, 0, 0)
	grille.Parent = contenu
	local dispoGrille = Instance.new("UIGridLayout")
	dispoGrille.CellSize = UDim2.new(0, LARGEUR_CARTE, 0, HAUTEUR_CARTE)
	dispoGrille.CellPadding = UDim2.new(0, ECART, 0, ECART)
	dispoGrille.FillDirection = Enum.FillDirection.Horizontal
	dispoGrille.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dispoGrille.SortOrder = Enum.SortOrder.LayoutOrder
	dispoGrille.Parent = grille
	local margeGrille = Instance.new("UIPadding")
	margeGrille.PaddingTop = UDim.new(0, 4)
	margeGrille.PaddingBottom = UDim.new(0, 10)
	margeGrille.PaddingLeft = UDim.new(0, MARGE_GAUCHE)
	margeGrille.PaddingRight = UDim.new(0, MARGE_DROITE)
	margeGrille.Parent = grille

	-- fondu en bas de liste : les cartes s'effacent dans le fond du panneau (indice « ça défile »)
	local fonduBas = Instance.new("Frame")
	fonduBas.Name = "FonduBas"
	fonduBas.AnchorPoint = Vector2.new(0, 1)
	fonduBas.Position = UDim2.new(0, 0, 1, -42)
	fonduBas.Size = UDim2.new(1, -(MARGE_DROITE - 2), 0, 24) -- laisse la barre de défilement visible
	fonduBas.BackgroundColor3 = couleurs.fond
	fonduBas.BorderSizePixel = 0
	fonduBas.Active = false
	fonduBas.ZIndex = grille.ZIndex + 1
	local degFondu = Instance.new("UIGradient")
	degFondu.Rotation = 90
	degFondu.Transparency = NumberSequence.new(1, 0)
	degFondu.Parent = fonduBas
	fonduBas.Parent = contenu
	-- le fondu disparaît quand on est tout en bas (plus rien à faire défiler)
	local function majFondu()
		local ok = pcall(function()
			local reste = grille.AbsoluteCanvasSize.Y - grille.AbsoluteWindowSize.Y - grille.CanvasPosition.Y
			fonduBas.Visible = reste > 4
		end)
		if not ok then fonduBas.Visible = true end
	end
	pcall(function()
		grille:GetPropertyChangedSignal("CanvasPosition"):Connect(majFondu)
		grille:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(majFondu)
		grille:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(majFondu)
	end)

	-- en jeu : le nombre de colonnes et la largeur des cartes suivent la taille réelle du panneau
	local function ajusterGrille()
		local ok, taille = pcall(function() return grille.AbsoluteSize end)
		-- taille pas encore calculée (ou irréaliste) : on garde la largeur par défaut
		if not ok or typeof(taille) ~= "Vector2" or taille.X < 220 then return end
		local utile = taille.X - MARGE_GAUCHE - MARGE_DROITE
		local colonnes = math.max(2, math.floor((utile + ECART) / (LARGEUR_MIN + ECART)))
		local largeur = math.floor((utile - (colonnes - 1) * ECART) / colonnes)
		largeur = math.max(96, math.min(LARGEUR_MAX, largeur))
		dispoGrille.CellSize = UDim2.new(0, largeur, 0, HAUTEUR_CARTE)
	end
	pcall(function()
		grille:GetPropertyChangedSignal("AbsoluteSize"):Connect(ajusterGrille)
	end)

	local pied = Style.texte(contenu, {
		Name = "Pied",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 22),
		TextColor3 = couleurs.revenu,
		Text = "🏆 Complète une rareté entière : +" .. pourcent(BONUS_RARETE) .. " de revenu pour toujours !",
		contour = 2.5,
		tailleMax = 19,
	})
	if TOTAL == 0 then
		pied.Text = "Aucune espèce connue pour le moment."
	end

	-- ===== cartes =====
	local cartes = {} -- [espece] = { cle, fiche, cadre, ... }
	local ordreCartes = {}

	local function majCarte(c)
		local rarete = c.fiche.rarete
		c.rarete.Text = string.upper(nomRarete(rarete))
		if decouverte(c.cle) then
			teinterFond(c.cadre, couleurs.carteClaire:Lerp(blanc, 0.06), couleurs.carte:Lerp(noir, 0.18))
			c.lueur.Visible = true
			c.halo.Visible = true
			c.medaillon.BackgroundColor3 = blanc
			c.fondMedaillon.Enabled = true
			c.refletMedaillon.Visible = true
			c.icone.Visible = true
			c.mystere.Visible = false
			c.nom.Text = tostring(c.fiche.nom or c.cle)
			c.nom.TextTransparency = 0
			c.prix.Text = argentTexte(c.fiche.prix)
			c.prix.TextTransparency = 0
			c.revenu.Text = revenuTexte(c.fiche.revenu)
			c.revenu.TextTransparency = 0
			c.voileRuban.Visible = false
			c.trait.Color = couleurRarete(rarete)
			c.trait.Thickness = 2.5
			c.trait.Transparency = 0
		else
			-- carte sombre, médaillon « ? » : seule la rareté est révélée
			teinterFond(c.cadre, FOND_INCONNU:Lerp(blanc, 0.05), FOND_INCONNU:Lerp(noir, 0.25))
			c.lueur.Visible = false
			c.halo.Visible = false
			c.medaillon.BackgroundColor3 = MEDAILLON_INCONNU
			c.fondMedaillon.Enabled = false
			c.refletMedaillon.Visible = false
			c.icone.Visible = false
			c.mystere.Visible = true
			c.nom.Text = "???"
			c.nom.TextTransparency = 0.3
			c.prix.Text = "$???"
			c.prix.TextTransparency = 0.5
			c.revenu.Text = "$???/s"
			c.revenu.TextTransparency = 0.5
			c.voileRuban.Visible = true
			c.trait.Color = couleurs.carteClaire
			c.trait.Thickness = 2
			c.trait.Transparency = 0.35
		end
	end

	for i, entree in ipairs(liste) do
		local fiche = entree.fiche
		local cadre = Style.carte(grille, {
			Name = "Index_" .. tostring(entree.cle),
			LayoutOrder = i,
			BackgroundColor3 = FOND_INCONNU,
		})
		local echelle = Instance.new("UIScale")
		echelle.Name = "Echelle"
		echelle.Parent = cadre

		-- lueur de rareté en haut de la carte (fondue vers le bas)
		local lueur = Instance.new("Frame")
		lueur.Name = "Lueur"
		lueur.Size = UDim2.new(1, 0, 0.62, 0)
		lueur.BackgroundColor3 = blanc
		lueur.BorderSizePixel = 0
		lueur.ZIndex = 1
		Style.coins(lueur, 16)
		local degLueur = Style.degradeRarete(lueur, fiche.rarete)
		if degLueur:GetAttribute("Anime") then
			degLueur.Transparency = NumberSequence.new(0.8)
		else
			degLueur.Transparency = NumberSequence.new(0.62, 1)
		end
		lueur.Parent = cadre

		-- liseré intérieur de la couleur de rareté (sous la bordure noire)
		local liseret = Instance.new("Frame")
		liseret.Name = "Liseret"
		liseret.Position = UDim2.new(0, 2, 0, 2)
		liseret.Size = UDim2.new(1, -4, 1, -4)
		liseret.BackgroundTransparency = 1
		liseret.BorderSizePixel = 0
		liseret.ZIndex = 2
		Style.coins(liseret, 14)
		local trait = Style.bordure(liseret, 2.5, couleurRarete(fiche.rarete))
		liseret.Parent = cadre

		-- médaillon rond : halo, disque au dégradé de rareté, reflet, emoji
		local halo = Instance.new("Frame")
		halo.Name = "Halo"
		halo.AnchorPoint = Vector2.new(0.5, 0.5)
		halo.Position = UDim2.new(0.5, 0, 0, 40)
		halo.Size = UDim2.new(0, 76, 0, 76)
		halo.BackgroundColor3 = blanc
		halo.BorderSizePixel = 0
		halo.ZIndex = 2
		rond(halo)
		local degHalo = Style.degradeRarete(halo, fiche.rarete)
		degHalo.Transparency = NumberSequence.new(0.6)
		halo.Parent = cadre

		local medaillon = Instance.new("Frame")
		medaillon.Name = "Medaillon"
		medaillon.AnchorPoint = Vector2.new(0.5, 0.5)
		medaillon.Position = UDim2.new(0.5, 0, 0, 40)
		medaillon.Size = UDim2.new(0, 62, 0, 62)
		medaillon.BackgroundColor3 = MEDAILLON_INCONNU
		medaillon.BorderSizePixel = 0
		medaillon.ZIndex = 3
		rond(medaillon)
		Style.bordure(medaillon, 3)
		local fondMedaillon = Style.degradeRarete(medaillon, fiche.rarete)
		fondMedaillon.Enabled = false
		medaillon.Parent = cadre

		local refletMedaillon = Instance.new("Frame")
		refletMedaillon.Name = "Reflet"
		refletMedaillon.AnchorPoint = Vector2.new(0.5, 0)
		refletMedaillon.Position = UDim2.new(0.5, 0, 0, 4)
		refletMedaillon.Size = UDim2.new(0.7, 0, 0.36, 0)
		refletMedaillon.BackgroundColor3 = blanc
		refletMedaillon.BackgroundTransparency = 0.6
		refletMedaillon.BorderSizePixel = 0
		refletMedaillon.ZIndex = 1
		rond(refletMedaillon)
		local fonduReflet = Instance.new("UIGradient")
		fonduReflet.Rotation = 90
		fonduReflet.Transparency = NumberSequence.new(0.15, 1)
		fonduReflet.Parent = refletMedaillon
		refletMedaillon.Parent = medaillon

		local pictogramme = "🦖"
		if fiche.famille == "Herbivore" then pictogramme = "🦕" end
		local icone = Style.texte(medaillon, {
			Name = "Icone",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.new(1, -12, 1, -12),
			Text = pictogramme,
			ZIndex = 2,
			contour = 0,
			tailleMax = 44,
		})
		local mystere = Style.texte(medaillon, {
			Name = "Mystere",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.54),
			Size = UDim2.new(1, -14, 1, -14),
			Text = "?",
			TextColor3 = couleurs.ombre,
			ZIndex = 2,
			titre = true,
			tailleMax = 40,
		})
		local contourMystere = mystere:FindFirstChild("Contour")
		if contourMystere then
			contourMystere.Color = couleurs.carteClaire
			contourMystere.Thickness = 2.5
		end

		local nom = Style.texte(cadre, {
			Name = "Nom",
			Position = UDim2.new(0, 8, 0, 76),
			Size = UDim2.new(1, -16, 0, 20),
			Text = "???",
			ZIndex = 3,
			contour = 2.5,
			tailleMax = 19,
		})

		local prix = Style.texte(cadre, {
			Name = "Prix",
			Position = UDim2.new(0, 6, 0, 97),
			Size = UDim2.new(0.5, -8, 0, 17),
			TextColor3 = couleurs.argent,
			Text = "",
			ZIndex = 3,
			contour = 2,
			tailleMax = 16,
		})
		local revenu = Style.texte(cadre, {
			Name = "Revenu",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -6, 0, 97),
			Size = UDim2.new(0.5, -8, 0, 17),
			TextColor3 = couleurs.revenu,
			Text = "",
			ZIndex = 3,
			contour = 2,
			tailleMax = 16,
		})

		-- ruban de rareté : pilule au dégradé de rareté, texte blanc cerné
		local ruban = Instance.new("Frame")
		ruban.Name = "Ruban"
		ruban.Position = UDim2.new(0, 8, 0, 119)
		ruban.Size = UDim2.new(1, -16, 0, 22)
		ruban.BackgroundColor3 = blanc
		ruban.BorderSizePixel = 0
		ruban.ZIndex = 3
		rond(ruban)
		Style.bordure(ruban, 2)
		Style.degradeRarete(ruban, fiche.rarete)
		ruban.Parent = cadre
		local voileRuban = Instance.new("Frame")
		voileRuban.Name = "Voile"
		voileRuban.Size = UDim2.fromScale(1, 1)
		voileRuban.BackgroundColor3 = couleurs.ombre
		voileRuban.BackgroundTransparency = 0.45
		voileRuban.BorderSizePixel = 0
		voileRuban.ZIndex = 1
		rond(voileRuban)
		voileRuban.Parent = ruban
		local rarete = Style.texte(ruban, {
			Name = "Rarete",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -10, 1, -4),
			Text = string.upper(nomRarete(fiche.rarete)),
			ZIndex = 2,
			titre = true,
			contour = 2,
			tailleMax = 15,
		})

		local c = {
			cle = entree.cle,
			fiche = fiche,
			cadre = cadre,
			echelle = echelle,
			lueur = lueur,
			trait = trait,
			halo = halo,
			medaillon = medaillon,
			fondMedaillon = fondMedaillon,
			refletMedaillon = refletMedaillon,
			icone = icone,
			mystere = mystere,
			pictogramme = pictogramme,
			nom = nom,
			rarete = rarete,
			voileRuban = voileRuban,
			prix = prix,
			revenu = revenu,
		}
		cartes[entree.cle] = c
		table.insert(ordreCartes, c)
		pcall(majCarte, c)

		-- survol : la carte grossit légèrement
		pcall(function()
			cadre.MouseEnter:Connect(function() jouer(echelle, 0.1, { Scale = 1.05 }) end)
			cadre.MouseLeave:Connect(function() jouer(echelle, 0.1, { Scale = 1 }) end)
		end)
	end

	-- ===== onglets =====
	local ongletActif = "Toutes"
	local onglets = {} -- { cle, bouton, libelle, compte, texteCompte }

	local function nombreDecouvertes(rarete)
		local n, total = 0, 0
		for _, c in ipairs(ordreCartes) do
			if rarete == "Toutes" or c.fiche.rarete == rarete then
				total = total + 1
				if decouverte(c.cle) then n = n + 1 end
			end
		end
		return n, total
	end

	local function majOnglets()
		for _, o in ipairs(onglets) do
			local n, total = nombreDecouvertes(o.cle)
			local complet = total > 0 and n == total
			if complet and o.cle ~= "Toutes" then
				o.texteCompte.Text = "✔"
				o.compte.BackgroundColor3 = Style.boutons.vert[2]
				o.compte.BackgroundTransparency = 0
			else
				o.texteCompte.Text = n .. "/" .. total
				o.compte.BackgroundColor3 = couleurs.ombre
				o.compte.BackgroundTransparency = 0.5
			end
			if o.cle == ongletActif then
				teinterFond(o.bouton, Style.boutons.bleu[1], Style.boutons.bleu[2])
			else
				teinterFond(o.bouton, couleurs.carteClaire, couleurs.fond)
			end
		end
	end

	local function appliquerFiltre(anime)
		local rang = 0
		for _, c in ipairs(ordreCartes) do
			local montre = ongletActif == "Toutes" or c.fiche.rarete == ongletActif
			c.cadre.Visible = montre
			if montre and anime then
				-- apparition douce, en cascade
				rang = rang + 1
				c.echelle.Scale = 0.85
				local d = math.min(rang, 12) * 0.015
				task.delay(d, function()
					jouer(c.echelle, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
				end)
			end
		end
		grille.CanvasPosition = Vector2.new(0, 0)
		majOnglets()
	end

	-- pastille ronde de la couleur de la rareté (« Toutes » : toutes les couleurs)
	local function pastille(parent, cle)
		local p = Instance.new("Frame")
		p.Name = "Pastille"
		p.AnchorPoint = Vector2.new(0, 0.5)
		p.Position = UDim2.new(0, 10, 0.5, 0)
		p.Size = UDim2.new(0, 16, 0, 16)
		p.BackgroundColor3 = blanc
		p.BorderSizePixel = 0
		p.ZIndex = 2
		rond(p)
		Style.bordure(p, 2)
		if cle == "Toutes" then
			local teintes = {}
			for _, r in ipairs(raretesPresentes) do
				table.insert(teintes, couleurRarete(r))
			end
			if #teintes < 2 then teintes = { Style.boutons.bleu[1], Style.boutons.bleu[2] } end
			local g = Instance.new("UIGradient")
			g.Name = "Rarete"
			g.Color = Style.sequence(teintes)
			g.Rotation = 45
			g.Parent = p
		else
			Style.degradeRarete(p, cle)
		end
		p.Parent = parent
		return p
	end

	local function creerOnglet(cle, rang)
		local o = { cle = cle }
		local texte = "TOUTES"
		if cle ~= "Toutes" then texte = string.upper(nomRarete(cle)) end
		o.bouton, o.libelle = Style.bouton(bandeOnglets, {
			Name = "Onglet_" .. cle,
			LayoutOrder = rang,
			Size = UDim2.new(1, 0, 0, HAUTEUR_ONGLET),
			couleur = "gris",
			texte = texte,
			rayon = 10,
			tailleMax = 15,
		}, function()
			if ongletActif ~= cle then
				ongletActif = cle
				son("clic")
				pcall(appliquerFiltre, true)
			end
		end)
		-- libellé sur une ligne, entre la pastille et le compteur
		o.libelle.AnchorPoint = Vector2.new(0, 0.5)
		o.libelle.Position = UDim2.new(0, 31, 0.5, 0)
		o.libelle.Size = UDim2.new(1, -82, 1, -12)
		o.libelle.TextXAlignment = Enum.TextXAlignment.Left
		o.libelle.TextWrapped = false
		pastille(o.bouton, cle)

		o.compte = Instance.new("Frame")
		o.compte.Name = "Compte"
		o.compte.AnchorPoint = Vector2.new(1, 0.5)
		o.compte.Position = UDim2.new(1, -6, 0.5, 0)
		o.compte.Size = UDim2.new(0, 42, 0, 22)
		o.compte.BackgroundColor3 = couleurs.ombre
		o.compte.BackgroundTransparency = 0.5
		o.compte.BorderSizePixel = 0
		o.compte.ZIndex = 2
		rond(o.compte)
		o.compte.Parent = o.bouton
		o.texteCompte = Style.texte(o.compte, {
			Name = "Texte",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -8, 1, -4),
			Text = "",
			ZIndex = 3,
			contour = 2,
			tailleMax = 15,
		})
		table.insert(onglets, o)
	end

	creerOnglet("Toutes", 0)
	for i, r in ipairs(raretesPresentes) do
		creerOnglet(r, i)
	end

	-- ===== en-tête : compteur, barre et bonus =====
	local function majEntete()
		local n = nombreDecouvertes("Toutes")
		compteur.Text = "<font color=\"#" .. couleurs.argent:ToHex() .. "\">" .. n .. "/" .. TOTAL .. "</font> découverts"
		local fraction = 0
		if TOTAL > 0 then fraction = n / TOTAL end
		remplissage.Visible = fraction > 0
		if ecran.Visible then
			jouer(remplissage, 0.35, { Size = UDim2.fromScale(fraction, 1) })
		else
			remplissage.Size = UDim2.fromScale(fraction, 1)
		end
		pourcentTexte.Text = pourcent(fraction)
		local bonus = tonumber(joueur:GetAttribute("BonusIndex")) or 0
		if bonus > 0 then
			bonusTexte.Text = "⭐ BONUS +" .. pourcent(bonus) .. " revenu"
			bonusTexte.TextColor3 = couleurs.revenu
			bordBonus.Color = couleurs.revenu
		else
			bonusTexte.Text = "Bonus : aucun"
			bonusTexte.TextColor3 = couleurs.texte
			bordBonus.Color = couleurs.contour
		end
	end

	local function majTout()
		for _, c in ipairs(ordreCartes) do
			pcall(majCarte, c)
		end
		pcall(majEntete)
		pcall(majOnglets)
	end

	-- éclat sur une carte fraîchement découverte
	local function celebrer(c)
		pcall(function()
			c.trait.Thickness = 6
			c.trait.Color = couleurs.revenu
			jouer(c.trait, 0.8, { Thickness = 2.5, Color = couleurRarete(c.fiche.rarete) })
			c.echelle.Scale = 1.18
			jouer(c.echelle, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		end)
	end

	-- ===== ouverture (pop) / fermeture (fondu) =====
	local ouvert = false
	local jeton = 0

	local function ouvrir()
		majTout()
		if ouvert then return end
		ouvert = true
		jeton = jeton + 1
		ecran.BackgroundTransparency = 1
		ecran.Visible = true
		jouer(ecran, 0.18, { BackgroundTransparency = VOILE_TRANSPARENCE })
		pcall(Style.pop, panneau)
		son("clic")
	end

	fermer = function()
		if not ouvert then return end
		ouvert = false
		jeton = jeton + 1
		local moi = jeton
		jouer(ecran, 0.14, { BackgroundTransparency = 1 })
		local pop = panneau:FindFirstChild("Pop")
		if pop then
			jouer(pop, 0.14, { Scale = 0.88 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
		task.delay(0.15, function()
			if jeton == moi and not ouvert then
				ecran.Visible = false
				ecran.BackgroundTransparency = VOILE_TRANSPARENCE
				if pop then pop.Scale = 1 end
			end
		end)
	end

	voile.Activated:Connect(function()
		if fermer then fermer() end
	end)

	Bus.ecouter("OuvrirPanneau", function(nom)
		if nom == "Index" then
			ouvrir()
		else
			fermer()
		end
	end)
	Bus.ecouter("FermerPanneaux", function()
		fermer()
	end)

	UserInputService.InputBegan:Connect(function(entree)
		if not ouvert then return end
		if entree.KeyCode == Enum.KeyCode.Escape or entree.KeyCode == Enum.KeyCode.ButtonB then
			fermer()
		end
	end)

	-- ===== mise à jour en direct =====
	joueur.AttributeChanged:Connect(function(attribut)
		if attribut == "BonusIndex" then
			pcall(majEntete)
		elseif string.sub(attribut, 1, 6) == "Index_" then
			local c = cartes[string.sub(attribut, 7)]
			if c then
				pcall(majCarte, c)
				if ouvert and decouverte(c.cle) then
					celebrer(c)
				end
			end
			pcall(majEntete)
			pcall(majOnglets)
		end
	end)

	appliquerFiltre(false)
	majTout()
	ajusterGrille()
	majFondu()
end

return M
