-- Interface/Recherches : panneau « Arbre des Recherches » du Laboratoire.
-- Ouvert par Bus « OuvrirPanneau » == "Recherches", fermé par « FermerPanneaux », ✕ ou Échap.
-- Une carte par recherche d'Equilibrage.recherches ; achat via Reseau.Rechercher.
local M = {}

local ICONES = {
	TourelleToit = "🗼",
	ViseeCritique = "🎯",
	BallesPerforantes = "🔫",
	Foreuse = "⛏️",
}
local ICONE_DEFAUT = "🔬"

-- délai pendant lequel un bouton reste en attente après un clic (anti double clic)
local ATTENTE_CLIC = 1

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Equilibrage = ctx.Equilibrage or {}
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local joueur = ctx.joueur
	local gui = ctx.gui
	if not (Charte and Outils and Bus and joueur and gui) then return end

	local okTween, TweenService = pcall(function() return game:GetService("TweenService") end)
	if not okTween then TweenService = nil end
	local okUis, UserInputService = pcall(function() return game:GetService("UserInputService") end)
	if not okUis then UserInputService = nil end

	local recherches = Equilibrage.recherches or {}

	-- liste triée par coût croissant puis par nom, pour un ordre stable
	local noms = {}
	for nom, _ in pairs(recherches) do
		table.insert(noms, nom)
	end
	table.sort(noms, function(a, b)
		local ca = tonumber(recherches[a].cout) or 0
		local cb = tonumber(recherches[b].cout) or 0
		if ca == cb then return a < b end
		return ca < cb
	end)

	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function gemmes()
		return tonumber(joueur:GetAttribute("Gemmes")) or 0
	end

	local function debloquee(nom)
		return joueur:GetAttribute("Rech_" .. nom) == true
	end

	-- ===== construction du panneau =====
	local fond = Outils.cadre(gui, {
		Name = "PanneauRecherches",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.62, 0, 0.72, 0),
		BackgroundColor3 = Charte.nuitLabo,
		BackgroundTransparency = 0.05,
		Visible = false,
		ZIndex = 20,
	})
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MinSize = Vector2.new(300, 280)
	contrainte.MaxSize = Vector2.new(760, 560)
	contrainte.Parent = fond

	local contour = Instance.new("UIStroke")
	contour.Color = Charte.gemme
	contour.Thickness = 3
	contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contour.Parent = fond

	local echelle = Instance.new("UIScale")
	echelle.Scale = 1
	echelle.Parent = fond

	Outils.etiquette(fond, {
		Name = "Titre",
		Text = "🔬 Arbre des Recherches",
		Position = UDim2.new(0, 16, 0, 10),
		Size = UDim2.new(1, -200, 0, 40),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Charte.creme,
		ZIndex = 21,
	})

	local compteur = Outils.cadre(fond, {
		Name = "Compteur",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -64, 0, 12),
		Size = UDim2.new(0, 120, 0, 36),
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0.2,
		ZIndex = 21,
	})
	local texteGemmes = Outils.etiquette(compteur, {
		Name = "Texte",
		Text = "💎 0",
		Position = UDim2.new(0, 8, 0, 4),
		Size = UDim2.new(1, -16, 1, -8),
		TextColor3 = Charte.gemme,
		ZIndex = 22,
	})

	local boutonFermer = Outils.bouton(fond, {
		Name = "Fermer",
		Text = "✕",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.new(0, 40, 0, 36),
		BackgroundColor3 = Charte.alerte,
		ZIndex = 21,
	})

	Outils.etiquette(fond, {
		Name = "SousTitre",
		Text = "Les recherches sont permanentes et se paient en gemmes.",
		Font = Charte.policeTexte,
		Position = UDim2.new(0, 16, 0, 54),
		Size = UDim2.new(1, -32, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Charte.lumiere(Charte.nuitLabo),
		ZIndex = 21,
	})

	local liste = Instance.new("ScrollingFrame")
	liste.Name = "Liste"
	liste.BackgroundTransparency = 1
	liste.BorderSizePixel = 0
	liste.Position = UDim2.new(0, 12, 0, 84)
	liste.Size = UDim2.new(1, -24, 1, -96)
	liste.ScrollBarThickness = 6
	liste.ScrollBarImageColor3 = Charte.gemme
	liste.CanvasSize = UDim2.new(0, 0, 0, 0)
	liste.ZIndex = 21
	liste.Parent = fond

	local grille = Instance.new("UIGridLayout")
	grille.CellSize = UDim2.new(0.5, -8, 0, 150)
	grille.CellPadding = UDim2.new(0, 8, 0, 8)
	grille.SortOrder = Enum.SortOrder.LayoutOrder
	grille.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grille.Parent = liste

	local function ajusterCanevas()
		local ok, taille = pcall(function() return grille.AbsoluteContentSize end)
		if ok and taille then
			liste.CanvasSize = UDim2.new(0, 0, 0, taille.Y + 8)
		end
	end
	pcall(function()
		grille:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ajusterCanevas)
	end)

	-- ===== cartes =====
	local cartes = {}
	local enAttente = {}

	local function rafraichir()
		local g = gemmes()
		texteGemmes.Text = "💎 " .. tostring(math.floor(g))
		for _, nom in ipairs(noms) do
			local c = cartes[nom]
			if c then
				local cout = tonumber(recherches[nom].cout) or 0
				if debloquee(nom) then
					c.bouton.Visible = false
					c.etat.Visible = true
					c.contour.Color = Charte.prairie
					c.cout.Text = "Acquise"
				else
					c.etat.Visible = false
					c.bouton.Visible = true
					c.contour.Color = Charte.gemme
					c.cout.Text = "💎 " .. tostring(cout)
					local possible = g >= cout and not enAttente[nom]
					c.bouton.Active = possible
					c.bouton.AutoButtonColor = possible
					if enAttente[nom] then
						c.bouton.Text = "…"
						c.bouton.BackgroundColor3 = Charte.ardoise
					elseif possible then
						c.bouton.Text = "Rechercher"
						c.bouton.BackgroundColor3 = Charte.toit
					else
						c.bouton.Text = "Rechercher"
						c.bouton.BackgroundColor3 = Charte.ardoise
					end
				end
			end
		end
	end

	local function lancer(nom)
		if enAttente[nom] or debloquee(nom) then return end
		local cout = tonumber(recherches[nom].cout) or 0
		if gemmes() < cout then
			son("refus")
			return
		end
		local remote = Reseau.Rechercher
		if not remote then
			son("refus")
			return
		end
		local ok = pcall(function() remote:FireServer(nom) end)
		if not ok then
			son("refus")
			return
		end
		son("clic")
		enAttente[nom] = true
		rafraichir()
		task.delay(ATTENTE_CLIC, function()
			enAttente[nom] = nil
			rafraichir()
		end)
	end

	for ordre, nom in ipairs(noms) do
		local donnees = recherches[nom]
		local carte = Outils.cadre(liste, {
			Name = "Carte_" .. nom,
			LayoutOrder = ordre,
			BackgroundColor3 = Charte.encre,
			BackgroundTransparency = 0.1,
			ZIndex = 22,
		})
		local bord = Instance.new("UIStroke")
		bord.Color = Charte.gemme
		bord.Thickness = 2
		bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bord.Parent = carte

		Outils.etiquette(carte, {
			Name = "Icone",
			Text = ICONES[nom] or ICONE_DEFAUT,
			Position = UDim2.new(0, 8, 0, 8),
			Size = UDim2.new(0, 48, 0, 48),
			ZIndex = 23,
		})
		Outils.etiquette(carte, {
			Name = "Nom",
			Text = nom,
			Position = UDim2.new(0, 64, 0, 10),
			Size = UDim2.new(1, -72, 0, 26),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Charte.creme,
			ZIndex = 23,
		})
		local cout = Outils.etiquette(carte, {
			Name = "Cout",
			Text = "💎 " .. tostring(tonumber(donnees.cout) or 0),
			Position = UDim2.new(0, 64, 0, 36),
			Size = UDim2.new(1, -72, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Charte.gemme,
			ZIndex = 23,
		})
		Outils.etiquette(carte, {
			Name = "Description",
			Text = tostring(donnees.description or ""),
			Font = Charte.policeTexte,
			TextScaled = false,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.new(0, 10, 0, 62),
			Size = UDim2.new(1, -20, 0, 40),
			TextColor3 = Charte.lumiere(Charte.ardoise),
			ZIndex = 23,
		})
		local etat = Outils.etiquette(carte, {
			Name = "Etat",
			Text = "✔ Débloquée",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -8),
			Size = UDim2.new(1, -20, 0, 32),
			TextColor3 = Charte.prairie,
			Visible = false,
			ZIndex = 23,
		})
		local bouton = Outils.bouton(carte, {
			Name = "Rechercher",
			Text = "Rechercher",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -8),
			Size = UDim2.new(1, -20, 0, 32),
			ZIndex = 23,
		}, function()
			lancer(nom)
		end)
		cartes[nom] = { carte = carte, contour = bord, cout = cout, etat = etat, bouton = bouton }
	end

	if #noms == 0 then
		Outils.etiquette(liste, {
			Name = "Vide",
			Text = "Aucune recherche disponible.",
			Font = Charte.policeTexte,
			TextColor3 = Charte.creme,
			ZIndex = 22,
		})
	end
	ajusterCanevas()

	-- ===== ouverture / fermeture =====
	local ouvert = false

	local function ouvrir()
		rafraichir()
		ajusterCanevas()
		if ouvert then return end
		ouvert = true
		fond.Visible = true
		if TweenService then
			echelle.Scale = 0.85
			local ok = pcall(function()
				TweenService:Create(echelle, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			end)
			if not ok then echelle.Scale = 1 end
		end
	end

	local function fermer()
		if not ouvert then return end
		ouvert = false
		fond.Visible = false
		echelle.Scale = 1
	end

	Bus.ecouter("OuvrirPanneau", function(nom)
		if nom == "Recherches" then
			son("clic")
			ouvrir()
		else
			fermer()
		end
	end)
	Bus.ecouter("FermerPanneaux", fermer)

	boutonFermer.Activated:Connect(function()
		son("clic")
		Bus.emettre("FermerPanneaux")
	end)

	if UserInputService then
		UserInputService.InputBegan:Connect(function(entree)
			if ouvert and entree.KeyCode == Enum.KeyCode.Escape then
				Bus.emettre("FermerPanneaux")
			end
		end)
	end

	-- ===== mises à jour =====
	joueur:GetAttributeChangedSignal("Gemmes"):Connect(rafraichir)
	for _, nom in ipairs(noms) do
		local n = nom
		joueur:GetAttributeChangedSignal("Rech_" .. n):Connect(function()
			if debloquee(n) then
				enAttente[n] = nil
				if ouvert then son("victoire") end
			end
			rafraichir()
		end)
	end

	rafraichir()
end

return M
