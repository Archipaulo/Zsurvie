-- Interface Index (Dinodex) : le carnet des espèces découvertes.
-- S'ouvre sur Bus « OuvrirPanneau » == "Index" ; se ferme par le X rouge, Échap (ou bouton B), clic sur le voile et Bus « FermerPanneaux ».
-- Grille des espèces triées par rareté, onglets par rareté, en-tête « x/20 découverts » et bonus actuel (BonusIndex).
-- Mise à jour en direct sur les attributs Index_<Espece> et BonusIndex posés par le serveur (Systemes/Index).
-- Look « simulateur Roblox » (STYLE.md) : tout passe par ctx.Style.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local LARGEUR_CARTE = 128
local HAUTEUR_CARTE = 176
local ECART = 12

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Bus = ctx.Bus
	local joueur = ctx.joueur
	local E = ctx.Equilibrage
	local Style = ctx.Style or require(game:GetService("ReplicatedStorage").Dino.Style)
	local couleurs = Style.couleurs

	local RARETES = E.raretes or {}
	local ESPECES = E.especes or {}
	local reglages = E.index or {}
	local BONUS_RARETE = tonumber(reglages.bonusCompletRarete) or 0.1

	local FOND_INCONNU = couleurs.fond:Lerp(couleurs.ombre, 0.45)
	local BANDEAU_INCONNU = couleurs.fond:Lerp(couleurs.ombre, 0.25)

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

	-- couleur franche d'une rareté (bordures, barre) : bas du dégradé, sinon la Charte
	local function couleurRarete(rarete)
		local def = Style.raretes[rarete]
		if type(def) == "table" and typeof(def[2]) == "Color3" then return def[2] end
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
	ecran.BackgroundTransparency = 0.5
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
		limite.MaxSize = Vector2.new(780, 600)
		limite.MinSize = Vector2.new(290, 300)
	end

	local fermer = nil
	boutonFermer.Activated:Connect(function()
		son("clic")
		if fermer then fermer() end
	end)

	-- ===== en-tête : « 12/20 découverts » + bonus =====
	local entete = Instance.new("Frame")
	entete.Name = "Entete"
	entete.BackgroundTransparency = 1
	entete.Size = UDim2.new(1, 0, 0, 40)
	entete.Parent = contenu

	local compteur = Style.texte(entete, {
		Name = "Compteur",
		Size = UDim2.new(0.5, -6, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		contour = 3,
		tailleMax = 32,
	})
	local bonusTexte = Style.texte(entete, {
		Name = "Bonus",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 4),
		Size = UDim2.new(0.5, -6, 1, -8),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = couleurs.revenu,
		Text = "",
		contour = 3,
		tailleMax = 24,
	})

	-- barre de progression : fond sombre cerné, remplissage vert en dégradé
	local barre = Instance.new("Frame")
	barre.Name = "Progression"
	barre.Position = UDim2.new(0, 2, 0, 46)
	barre.Size = UDim2.new(1, -4, 0, 16)
	barre.BackgroundColor3 = FOND_INCONNU
	barre.BorderSizePixel = 0
	barre.ClipsDescendants = true
	Style.coins(barre, 8)
	Style.bordure(barre, 3)
	barre.Parent = contenu
	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(0, 1)
	remplissage.BackgroundColor3 = Color3.new(1, 1, 1)
	remplissage.BorderSizePixel = 0
	Style.coins(remplissage, 8)
	Style.degrade(remplissage, Style.boutons.vert[1], Style.boutons.vert[2])
	remplissage.Parent = barre

	-- ===== onglets par rareté =====
	local bandeOnglets = Instance.new("ScrollingFrame")
	bandeOnglets.Name = "Onglets"
	bandeOnglets.Position = UDim2.new(0, 0, 0, 70)
	bandeOnglets.Size = UDim2.new(1, 0, 0, 52)
	bandeOnglets.BackgroundTransparency = 1
	bandeOnglets.BorderSizePixel = 0
	bandeOnglets.ScrollBarThickness = 4
	bandeOnglets.ScrollBarImageColor3 = Style.boutons.bleu[1]
	bandeOnglets.ScrollingDirection = Enum.ScrollingDirection.X
	bandeOnglets.AutomaticCanvasSize = Enum.AutomaticSize.X
	bandeOnglets.CanvasSize = UDim2.new(0, 0, 0, 0)
	bandeOnglets.Parent = contenu
	local dispoOnglets = Instance.new("UIListLayout")
	dispoOnglets.FillDirection = Enum.FillDirection.Horizontal
	dispoOnglets.Padding = UDim.new(0, 8)
	dispoOnglets.SortOrder = Enum.SortOrder.LayoutOrder
	dispoOnglets.VerticalAlignment = Enum.VerticalAlignment.Center
	dispoOnglets.Parent = bandeOnglets
	local margeOnglets = Instance.new("UIPadding")
	margeOnglets.PaddingLeft = UDim.new(0, 4)
	margeOnglets.PaddingRight = UDim.new(0, 4)
	margeOnglets.Parent = bandeOnglets

	-- ===== grille =====
	local grille = Instance.new("ScrollingFrame")
	grille.Name = "Grille"
	grille.Position = UDim2.new(0, 0, 0, 128)
	grille.Size = UDim2.new(1, 0, 1, -158)
	grille.BackgroundTransparency = 1
	grille.BorderSizePixel = 0
	grille.ScrollBarThickness = 10
	grille.ScrollBarImageColor3 = Style.boutons.bleu[1]
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
	margeGrille.PaddingTop = UDim.new(0, 6)
	margeGrille.PaddingBottom = UDim.new(0, 10)
	margeGrille.PaddingLeft = UDim.new(0, 4)
	margeGrille.PaddingRight = UDim.new(0, 14)
	margeGrille.Parent = grille

	local pied = Style.texte(contenu, {
		Name = "Pied",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 24),
		TextColor3 = couleurs.revenu,
		Text = "Complète une rareté entière : +" .. pourcent(BONUS_RARETE) .. " de revenu pour toujours !",
		contour = 2,
		tailleMax = 20,
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
			c.cadre.BackgroundColor3 = couleurs.carte
			c.bandeau.BackgroundColor3 = Color3.new(1, 1, 1)
			c.fondRarete.Enabled = true
			c.icone.Visible = true
			c.mystere.Visible = false
			c.nom.Text = tostring(c.fiche.nom or c.cle)
			c.prix.Text = argentTexte(c.fiche.prix)
			c.prix.TextTransparency = 0
			c.revenu.Text = revenuTexte(c.fiche.revenu)
			c.revenu.TextTransparency = 0
			c.trait.Color = couleurRarete(rarete)
			c.trait.Thickness = 4
		else
			-- carte sombre, grande silhouette « ? » : seule la rareté est révélée
			c.cadre.BackgroundColor3 = FOND_INCONNU
			c.bandeau.BackgroundColor3 = BANDEAU_INCONNU
			c.fondRarete.Enabled = false
			c.icone.Visible = false
			c.mystere.Visible = true
			c.nom.Text = "???"
			c.prix.Text = "$???"
			c.prix.TextTransparency = 0.45
			c.revenu.Text = "$???/s"
			c.revenu.TextTransparency = 0.45
			c.trait.Color = couleurs.contour
			c.trait.Thickness = 3
		end
	end

	for i, entree in ipairs(liste) do
		local fiche = entree.fiche
		local cadre = Style.carte(grille, {
			Name = "Index_" .. tostring(entree.cle),
			LayoutOrder = i,
			BackgroundColor3 = FOND_INCONNU,
		})
		local trait = cadre:FindFirstChild("Bordure")
		if not trait then trait = Style.bordure(cadre, 3) end

		-- vignette : fond au dégradé de rareté (découvert) ou sombre (inconnu)
		local bandeau = Instance.new("Frame")
		bandeau.Name = "Bandeau"
		bandeau.Position = UDim2.new(0, 6, 0, 6)
		bandeau.Size = UDim2.new(1, -12, 0, 78)
		bandeau.BackgroundColor3 = BANDEAU_INCONNU
		bandeau.BorderSizePixel = 0
		Style.coins(bandeau, 12)
		Style.bordure(bandeau, 2)
		bandeau.Parent = cadre
		local fondRarete = Style.degradeRarete(bandeau, fiche.rarete)
		fondRarete.Enabled = false

		local pictogramme = "🦖"
		if fiche.famille == "Herbivore" then pictogramme = "🦕" end
		local icone = Style.texte(bandeau, {
			Name = "Icone",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -10, 1, -8),
			Text = pictogramme,
			contour = 0,
			tailleMax = 60,
		})
		local mystere = Style.texte(bandeau, {
			Name = "Mystere",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.new(1, -10, 1, -4),
			Text = "?",
			TextColor3 = couleurs.ombre,
			titre = true,
			tailleMax = 72,
		})
		local contourMystere = mystere:FindFirstChild("Contour")
		if contourMystere then
			contourMystere.Color = couleurs.carteClaire
			contourMystere.Thickness = 3
		end

		local nom = Style.texte(cadre, {
			Name = "Nom",
			Position = UDim2.new(0, 6, 0, 88),
			Size = UDim2.new(1, -12, 0, 24),
			Text = "???",
			contour = 2.5,
			tailleMax = 22,
		})

		local rarete = Style.texte(cadre, {
			Name = "Rarete",
			Position = UDim2.new(0, 6, 0, 112),
			Size = UDim2.new(1, -12, 0, 20),
			Text = string.upper(nomRarete(fiche.rarete)),
			titre = true,
			contour = 2.5,
			tailleMax = 18,
		})
		Style.degradeRarete(rarete, fiche.rarete)

		local prix = Style.texte(cadre, {
			Name = "Prix",
			Position = UDim2.new(0, 6, 0, 132),
			Size = UDim2.new(1, -12, 0, 20),
			TextColor3 = couleurs.argent,
			Text = "",
			contour = 2.5,
			tailleMax = 20,
		})
		local revenu = Style.texte(cadre, {
			Name = "Revenu",
			Position = UDim2.new(0, 6, 0, 152),
			Size = UDim2.new(1, -12, 0, 18),
			TextColor3 = couleurs.revenu,
			Text = "",
			contour = 2.5,
			tailleMax = 18,
		})

		local c = {
			cle = entree.cle,
			fiche = fiche,
			cadre = cadre,
			trait = trait,
			bandeau = bandeau,
			fondRarete = fondRarete,
			icone = icone,
			mystere = mystere,
			pictogramme = pictogramme,
			nom = nom,
			rarete = rarete,
			prix = prix,
			revenu = revenu,
		}
		cartes[entree.cle] = c
		table.insert(ordreCartes, c)
		pcall(majCarte, c)
	end

	-- ===== onglets =====
	local ongletActif = "Toutes"
	local onglets = {} -- { cle, bouton, libelle }

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
			local libelle = "TOUTES"
			if o.cle ~= "Toutes" then libelle = string.upper(nomRarete(o.cle)) end
			local complet = total > 0 and n == total
			local suffixe = " " .. n .. "/" .. total
			if complet and o.cle ~= "Toutes" then suffixe = " ✔" end
			o.libelle.Text = libelle .. suffixe
			if o.cle == ongletActif then
				Style.couleurBouton(o.bouton, "bleu")
			else
				Style.couleurBouton(o.bouton, "gris")
			end
		end
	end

	local function appliquerFiltre()
		for _, c in ipairs(ordreCartes) do
			c.cadre.Visible = ongletActif == "Toutes" or c.fiche.rarete == ongletActif
		end
		grille.CanvasPosition = Vector2.new(0, 0)
		majOnglets()
	end

	local function creerOnglet(cle, rang)
		local largeur = 118
		if cle ~= "Toutes" then
			largeur = math.max(118, 56 + 11 * string.len(nomRarete(cle)))
		end
		local o = { cle = cle }
		o.bouton, o.libelle = Style.bouton(bandeOnglets, {
			Name = "Onglet_" .. cle,
			LayoutOrder = rang,
			Size = UDim2.new(0, largeur, 0, 40),
			couleur = "gris",
			texte = cle,
			rayon = 12,
			tailleMax = 20,
		}, function()
			if ongletActif ~= cle then
				ongletActif = cle
				son("clic")
				pcall(appliquerFiltre)
			end
		end)
		if cle ~= "Toutes" then
			Style.degradeRarete(o.libelle, cle)
		end
		table.insert(onglets, o)
	end

	creerOnglet("Toutes", 0)
	for i, r in ipairs(raretesPresentes) do
		creerOnglet(r, i)
	end

	-- ===== en-tête : compteur et bonus =====
	local function majEntete()
		local n = nombreDecouvertes("Toutes")
		compteur.Text = n .. "/" .. TOTAL .. " découverts"
		local fraction = 0
		if TOTAL > 0 then fraction = n / TOTAL end
		remplissage.Size = UDim2.fromScale(fraction, 1)
		remplissage.Visible = fraction > 0
		local bonus = tonumber(joueur:GetAttribute("BonusIndex")) or 0
		if bonus > 0 then
			bonusTexte.Text = "BONUS +" .. pourcent(bonus) .. " revenu"
			bonusTexte.TextColor3 = couleurs.revenu
		else
			bonusTexte.Text = "Bonus : aucun"
			bonusTexte.TextColor3 = couleurs.texte
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
			c.trait.Thickness = 9
			c.trait.Color = couleurs.revenu
			local t = TweenService:Create(c.trait, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Thickness = 4,
				Color = couleurRarete(c.fiche.rarete),
			})
			t:Play()
			Style.pop(c.cadre, 1.18)
		end)
	end

	-- ===== ouverture / fermeture =====
	local ouvert = false

	local function ouvrir()
		majTout()
		if ouvert then return end
		ouvert = true
		ecran.Visible = true
		pcall(Style.pop, panneau)
		son("clic")
	end

	fermer = function()
		if not ouvert then return end
		ouvert = false
		ecran.Visible = false
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

	appliquerFiltre()
	majTout()
end

return M
