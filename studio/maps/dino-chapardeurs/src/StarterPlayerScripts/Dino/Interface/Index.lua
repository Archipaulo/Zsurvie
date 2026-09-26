-- Interface Index (Dinodex) : le carnet des espèces découvertes.
-- S'ouvre sur Bus « OuvrirPanneau » == "Index" ; se ferme par ✕, Échap (ou bouton B), clic sur le voile et Bus « FermerPanneaux ».
-- Grille des espèces triées par rareté, onglets par rareté, en-tête « x/20 découverts » et bonus actuel (BonusIndex).
-- Mise à jour en direct sur les attributs Index_<Espece> et BonusIndex posés par le serveur (Systemes/Index).
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local LARGEUR_CARTE = 128
local HAUTEUR_CARTE = 158
local ECART = 10

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Bus = ctx.Bus
	local joueur = ctx.joueur
	local E = ctx.Equilibrage

	local RARETES = E.raretes or {}
	local ESPECES = E.especes or {}
	local reglages = E.index or {}
	local BONUS_RARETE = tonumber(reglages.bonusCompletRarete) or 0.1

	-- ===== utilitaires =====
	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function argentTexte(n)
		local ok, t = pcall(Charte.argent, n)
		if ok and type(t) == "string" then return t end
		return tostring(math.floor(tonumber(n) or 0)) .. " $"
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

	local function couleurRarete(rarete)
		local c = Charte.raretes and Charte.raretes[rarete]
		if typeof(c) == "Color3" then return c end
		return Charte.pierre
	end

	local function decouverte(espece)
		return joueur:GetAttribute("Index_" .. espece) == true
	end

	local function pourcent(x)
		local p = math.floor((tonumber(x) or 0) * 100 + 0.5)
		return tostring(p) .. " %"
	end

	local function contour(inst, couleur, epaisseur, mode)
		local s = Instance.new("UIStroke")
		s.Color = couleur
		s.Thickness = epaisseur or 2
		s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
		s.Parent = inst
		return s
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

	-- ===== fond et panneau =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Index"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundColor3 = Charte.encre
	ecran.BackgroundTransparency = 0.55
	ecran.BorderSizePixel = 0
	ecran.Visible = false
	ecran.ZIndex = 20
	ecran.Parent = ctx.gui

	local voile = Instance.new("TextButton")
	voile.Name = "Voile"
	voile.Size = UDim2.fromScale(1, 1)
	voile.BackgroundTransparency = 1
	voile.Text = ""
	voile.AutoButtonColor = false
	voile.ZIndex = 20
	voile.Parent = ecran

	local panneau = Outils.cadre(ecran, {
		Name = "Panneau",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.94, 0, 0.86, 0),
		BackgroundColor3 = Charte.sable,
		BackgroundTransparency = 0,
		Active = true,
		ZIndex = 21,
	})
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(760, 580)
	limite.MinSize = Vector2.new(290, 300)
	limite.Parent = panneau
	contour(panneau, Charte.jungle, 5)
	local echelle = Instance.new("UIScale")
	echelle.Parent = panneau

	-- ===== en-tête =====
	local entete = Outils.cadre(panneau, {
		Name = "Entete",
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = Charte.jungle,
		BackgroundTransparency = 0,
		ZIndex = 22,
	})
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Charte.lumiere(Charte.jungle), Charte.ombre(Charte.jungle))
	degrade.Rotation = 90
	degrade.Parent = entete

	local titre = Outils.etiquette(entete, {
		Name = "Titre",
		Position = UDim2.new(0, 16, 0, 6),
		Size = UDim2.new(1, -90, 0, 30),
		TextColor3 = Charte.creme,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "📖 Dinodex",
		ZIndex = 23,
	})
	contour(titre, Charte.ombre(Charte.jungle), 2, Enum.ApplyStrokeMode.Contextual)

	local compteur = Outils.etiquette(entete, {
		Name = "Compteur",
		Position = UDim2.new(0, 16, 0, 38),
		Size = UDim2.new(0.5, -24, 0, 22),
		Font = Charte.policeTexte,
		TextColor3 = Charte.creme,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 23,
	})
	local bonusTexte = Outils.etiquette(entete, {
		Name = "Bonus",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -72, 0, 38),
		Size = UDim2.new(0.5, -72, 0, 22),
		Font = Charte.policeTexte,
		TextColor3 = Charte.dore,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
		ZIndex = 23,
	})

	-- barre de progression sous l'en-tête
	local barre = Outils.cadre(entete, {
		Name = "Progression",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 16, 1, -4),
		Size = UDim2.new(1, -32, 0, 6),
		BackgroundColor3 = Charte.ombre(Charte.jungle),
		BackgroundTransparency = 0,
		ZIndex = 23,
	})
	local remplissage = Outils.cadre(barre, {
		Name = "Remplissage",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Charte.dore,
		BackgroundTransparency = 0,
		ZIndex = 24,
	})

	local fermer = nil
	local boutonFermer = Outils.bouton(entete, {
		Name = "Fermer",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.new(0, 44, 0, 44),
		BackgroundColor3 = Charte.alerte,
		Text = "✕",
		ZIndex = 24,
	}, function()
		son("clic")
		if fermer then fermer() end
	end)
	contour(boutonFermer, Charte.creme, 2)

	-- ===== onglets par rareté =====
	local bandeOnglets = Instance.new("ScrollingFrame")
	bandeOnglets.Name = "Onglets"
	bandeOnglets.Position = UDim2.new(0, 12, 0, 80)
	bandeOnglets.Size = UDim2.new(1, -24, 0, 40)
	bandeOnglets.BackgroundTransparency = 1
	bandeOnglets.BorderSizePixel = 0
	bandeOnglets.ScrollBarThickness = 4
	bandeOnglets.ScrollBarImageColor3 = Charte.bois
	bandeOnglets.ScrollingDirection = Enum.ScrollingDirection.X
	bandeOnglets.AutomaticCanvasSize = Enum.AutomaticSize.X
	bandeOnglets.CanvasSize = UDim2.new(0, 0, 0, 0)
	bandeOnglets.ZIndex = 22
	bandeOnglets.Parent = panneau
	local dispoOnglets = Instance.new("UIListLayout")
	dispoOnglets.FillDirection = Enum.FillDirection.Horizontal
	dispoOnglets.Padding = UDim.new(0, 6)
	dispoOnglets.SortOrder = Enum.SortOrder.LayoutOrder
	dispoOnglets.VerticalAlignment = Enum.VerticalAlignment.Top
	dispoOnglets.Parent = bandeOnglets

	-- ===== grille =====
	local grille = Instance.new("ScrollingFrame")
	grille.Name = "Grille"
	grille.Position = UDim2.new(0, 12, 0, 126)
	grille.Size = UDim2.new(1, -24, 1, -162)
	grille.BackgroundTransparency = 1
	grille.BorderSizePixel = 0
	grille.ScrollBarThickness = 8
	grille.ScrollBarImageColor3 = Charte.jungle
	grille.ScrollingDirection = Enum.ScrollingDirection.Y
	grille.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grille.CanvasSize = UDim2.new(0, 0, 0, 0)
	grille.ZIndex = 22
	grille.Parent = panneau
	local dispoGrille = Instance.new("UIGridLayout")
	dispoGrille.CellSize = UDim2.new(0, LARGEUR_CARTE, 0, HAUTEUR_CARTE)
	dispoGrille.CellPadding = UDim2.new(0, ECART, 0, ECART)
	dispoGrille.FillDirection = Enum.FillDirection.Horizontal
	dispoGrille.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dispoGrille.SortOrder = Enum.SortOrder.LayoutOrder
	dispoGrille.Parent = grille
	local margeGrille = Instance.new("UIPadding")
	margeGrille.PaddingTop = UDim.new(0, 4)
	margeGrille.PaddingBottom = UDim.new(0, 8)
	margeGrille.PaddingRight = UDim.new(0, 8)
	margeGrille.Parent = grille

	local pied = Outils.etiquette(panneau, {
		Name = "Pied",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1, -24, 0, 20),
		Font = Charte.policeTexte,
		TextColor3 = Charte.ombre(Charte.bois),
		Text = "Complète une rareté entière : +" .. pourcent(BONUS_RARETE) .. " de revenu pour toujours !",
		ZIndex = 22,
	})
	if TOTAL == 0 then
		pied.Text = "Aucune espèce connue pour le moment."
	end

	-- ===== cartes =====
	local cartes = {} -- [espece] = { cle, fiche, cadre, ... }
	local ordreCartes = {}

	local function majCarte(c)
		local rarete = c.fiche.rarete
		local couleur = couleurRarete(rarete)
		c.pastille.BackgroundColor3 = couleur
		c.rarete.Text = nomRarete(rarete)
		if decouverte(c.cle) then
			c.cadre.BackgroundColor3 = Charte.creme
			c.bandeau.BackgroundColor3 = couleur
			c.icone.Text = c.pictogramme
			c.icone.TextTransparency = 0
			c.nom.Text = tostring(c.fiche.nom or c.cle)
			c.nom.TextColor3 = Charte.encre
			c.prix.Text = "💰 " .. argentTexte(c.fiche.prix)
			c.prix.TextColor3 = Charte.ombre(Charte.bois)
			c.revenu.Text = "+" .. argentTexte(c.fiche.revenu) .. "/s"
			c.revenu.TextColor3 = Charte.ombre(Charte.jungle)
			c.trait.Color = couleur
			c.trait.Thickness = 3
		else
			-- silhouette : couleurs éteintes, rien de révélé sauf la rareté
			c.cadre.BackgroundColor3 = Charte.nuit
			c.bandeau.BackgroundColor3 = Charte.encre
			c.icone.Text = c.pictogramme
			c.icone.TextTransparency = 0.82
			c.nom.Text = "???"
			c.nom.TextColor3 = Charte.creme
			c.prix.Text = "💰 ???"
			c.prix.TextColor3 = Charte.pierre
			c.revenu.Text = "+??? /s"
			c.revenu.TextColor3 = Charte.pierre
			c.trait.Color = Charte.encre
			c.trait.Thickness = 2
		end
	end

	for i, entree in ipairs(liste) do
		local fiche = entree.fiche
		local cadre = Outils.cadre(grille, {
			Name = "Index_" .. tostring(entree.cle),
			LayoutOrder = i,
			BackgroundColor3 = Charte.nuit,
			BackgroundTransparency = 0,
			ClipsDescendants = true,
			ZIndex = 23,
		})
		local trait = contour(cadre, Charte.encre, 2)

		local bandeau = Outils.cadre(cadre, {
			Name = "Bandeau",
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundColor3 = Charte.encre,
			BackgroundTransparency = 0,
			ZIndex = 24,
		})
		local pictogramme = "🦖"
		if fiche.famille == "Herbivore" then pictogramme = "🦕" end
		local icone = Outils.etiquette(bandeau, {
			Name = "Icone",
			Position = UDim2.new(0, 12, 0, 6),
			Size = UDim2.new(1, -24, 1, -12),
			Text = pictogramme,
			ZIndex = 25,
		})

		local nom = Outils.etiquette(cadre, {
			Name = "Nom",
			Position = UDim2.new(0, 6, 0, 74),
			Size = UDim2.new(1, -12, 0, 22),
			Text = "???",
			ZIndex = 24,
		})

		local pastille = Outils.cadre(cadre, {
			Name = "Rarete",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 98),
			Size = UDim2.new(1, -20, 0, 16),
			BackgroundColor3 = couleurRarete(fiche.rarete),
			BackgroundTransparency = 0,
			ZIndex = 24,
		})
		local rarete = Outils.etiquette(pastille, {
			Name = "Texte",
			Position = UDim2.new(0, 4, 0, 1),
			Size = UDim2.new(1, -8, 1, -2),
			Font = Charte.policeTexte,
			TextColor3 = Charte.encre,
			Text = nomRarete(fiche.rarete),
			ZIndex = 25,
		})

		local prix = Outils.etiquette(cadre, {
			Name = "Prix",
			Position = UDim2.new(0, 6, 0, 118),
			Size = UDim2.new(1, -12, 0, 16),
			Font = Charte.policeTexte,
			Text = "",
			ZIndex = 24,
		})
		local revenu = Outils.etiquette(cadre, {
			Name = "Revenu",
			Position = UDim2.new(0, 6, 0, 136),
			Size = UDim2.new(1, -12, 0, 16),
			Font = Charte.policeTexte,
			Text = "",
			ZIndex = 24,
		})

		local c = {
			cle = entree.cle,
			fiche = fiche,
			cadre = cadre,
			trait = trait,
			bandeau = bandeau,
			icone = icone,
			pictogramme = pictogramme,
			nom = nom,
			pastille = pastille,
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
	local onglets = {} -- { cle, bouton, trait, couleur }

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
			local libelle = "Toutes"
			if o.cle ~= "Toutes" then libelle = nomRarete(o.cle) end
			local complet = total > 0 and n == total
			local suffixe = " " .. n .. "/" .. total
			if complet and o.cle ~= "Toutes" then suffixe = " ✔" end
			o.bouton.Text = libelle .. suffixe
			if o.cle == ongletActif then
				o.bouton.BackgroundColor3 = o.couleur
				o.bouton.TextColor3 = Charte.encre
				o.trait.Color = Charte.encre
				o.trait.Thickness = 2
			else
				o.bouton.BackgroundColor3 = Charte.creme
				o.bouton.TextColor3 = Charte.encre
				o.trait.Color = o.couleur
				o.trait.Thickness = 2
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

	local function creerOnglet(cle, couleur, rang)
		local largeur = 96
		if cle ~= "Toutes" then
			largeur = math.max(96, 26 + 9 * string.len(nomRarete(cle)))
		end
		local o = { cle = cle, couleur = couleur }
		o.bouton = Outils.bouton(bandeOnglets, {
			Name = "Onglet_" .. cle,
			LayoutOrder = rang,
			Size = UDim2.new(0, largeur, 0, 32),
			BackgroundColor3 = Charte.creme,
			TextColor3 = Charte.encre,
			Font = Charte.policeTexte,
			Text = cle,
			ZIndex = 23,
		}, function()
			if ongletActif ~= cle then
				ongletActif = cle
				son("clic")
				pcall(appliquerFiltre)
			end
		end)
		local marge = Instance.new("UIPadding")
		marge.PaddingLeft = UDim.new(0, 6)
		marge.PaddingRight = UDim.new(0, 6)
		marge.PaddingTop = UDim.new(0, 6)
		marge.PaddingBottom = UDim.new(0, 6)
		marge.Parent = o.bouton
		o.trait = contour(o.bouton, couleur, 2)
		table.insert(onglets, o)
	end

	creerOnglet("Toutes", Charte.dore, 0)
	for i, r in ipairs(raretesPresentes) do
		creerOnglet(r, couleurRarete(r), i)
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
			bonusTexte.Text = "Bonus : +" .. pourcent(bonus) .. " de revenu"
			bonusTexte.TextColor3 = Charte.dore
		else
			bonusTexte.Text = "Bonus : aucun pour l'instant"
			bonusTexte.TextColor3 = Charte.creme
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
			c.trait.Thickness = 8
			c.trait.Color = Charte.dore
			local t = TweenService:Create(c.trait, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Thickness = 3,
				Color = couleurRarete(c.fiche.rarete),
			})
			t:Play()
		end)
	end

	-- ===== ouverture / fermeture =====
	local ouvert = false
	local animation = nil

	local function ouvrir()
		majTout()
		if ouvert then return end
		ouvert = true
		ecran.Visible = true
		if animation then pcall(function() animation:Cancel() end) end
		echelle.Scale = 0.85
		animation = TweenService:Create(echelle, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		animation:Play()
		son("clic")
	end

	fermer = function()
		if not ouvert then return end
		ouvert = false
		if animation then pcall(function() animation:Cancel() end) end
		animation = nil
		echelle.Scale = 1
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
