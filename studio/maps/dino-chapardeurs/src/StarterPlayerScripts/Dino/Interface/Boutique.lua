-- Interface Boutique : le comptoir de l'explorateur.
-- S'ouvre sur Bus « OuvrirPanneau » == "Boutique" ; se ferme par ✕, Échap (ou bouton B) et Bus « FermerPanneaux ».
-- Une carte par objet de Equilibrage.boutique, mise à jour en direct sur Argent et Objet_*.
-- L'achat est demandé au serveur (Reseau.Acheter) qui vérifie tout.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local HAUTEUR_CARTE = 104
local ECART_CARTES = 10
local ATTENTE_MAX = 3 -- secondes avant de rendre la main si le serveur ne répond pas

-- pictogrammes des objets connus (les autres prennent le sac à dos)
local ICONES = {
	Bottes = "🥾",
	BatteOr = "🏏",
	Aimant = "🧲",
	Radar = "📡",
}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local E = ctx.Equilibrage

	local CATALOGUE = E.boutique or {}

	-- ===== utilitaires =====
	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function argentTexte(n)
		local ok, t = pcall(Charte.argent, n)
		if ok and type(t) == "string" then return t end
		return tostring(math.floor(tonumber(n) or 0)) .. " $"
	end

	local function argentJoueur()
		return tonumber(joueur:GetAttribute("Argent")) or 0
	end

	local function possede(cle)
		return joueur:GetAttribute("Objet_" .. cle) == true
	end

	local function prixDe(objet)
		return math.max(0, math.floor(tonumber(objet.prix) or 0))
	end

	-- objets triés du moins cher au plus cher
	local liste = {}
	for cle, objet in pairs(CATALOGUE) do
		if type(objet) == "table" then
			table.insert(liste, { cle = cle, objet = objet })
		end
	end
	table.sort(liste, function(a, b)
		local pa, pb = prixDe(a.objet), prixDe(b.objet)
		if pa == pb then return tostring(a.cle) < tostring(b.cle) end
		return pa < pb
	end)

	-- ===== fond et panneau =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Boutique"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundColor3 = Charte.encre
	ecran.BackgroundTransparency = 0.55
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
	voile.ZIndex = 20
	voile.Parent = ecran

	local panneau = Outils.cadre(ecran, {
		Name = "Panneau",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.92, 0, 0.82, 0),
		BackgroundColor3 = Charte.sable,
		BackgroundTransparency = 0,
		Active = true, -- un clic sur le panneau ne traverse pas jusqu'au voile
		ZIndex = 21,
	})
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(620, 520)
	limite.MinSize = Vector2.new(280, 260)
	limite.Parent = panneau
	local cadreBois = Instance.new("UIStroke")
	cadreBois.Color = Charte.bois
	cadreBois.Thickness = 5
	cadreBois.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	cadreBois.Parent = panneau
	local echelle = Instance.new("UIScale")
	echelle.Parent = panneau

	-- ===== en-tête : planche de bois =====
	local entete = Outils.cadre(panneau, {
		Name = "Entete",
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = Charte.bois,
		BackgroundTransparency = 0,
		ZIndex = 22,
	})
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Charte.lumiere(Charte.bois), Charte.ombre(Charte.bois))
	degrade.Rotation = 90
	degrade.Parent = entete

	local titre = Outils.etiquette(entete, {
		Name = "Titre",
		Position = UDim2.new(0, 16, 0, 6),
		Size = UDim2.new(1, -90, 0, 32),
		Font = Charte.police,
		TextColor3 = Charte.creme,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "🧭 Comptoir de l'explorateur",
		ZIndex = 23,
	})
	local ombreTitre = Instance.new("UIStroke")
	ombreTitre.Color = Charte.ombre(Charte.bois)
	ombreTitre.Thickness = 2
	ombreTitre.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	ombreTitre.Parent = titre

	local bourse = Outils.etiquette(entete, {
		Name = "Bourse",
		Position = UDim2.new(0, 16, 0, 38),
		Size = UDim2.new(1, -90, 0, 20),
		Font = Charte.policeTexte,
		TextColor3 = Charte.dore,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 23,
	})

	local fermer = nil -- défini plus bas
	local boutonFermer = Outils.bouton(entete, {
		Name = "Fermer",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 44, 0, 44),
		BackgroundColor3 = Charte.alerte,
		Text = "✕",
		ZIndex = 24,
	}, function()
		if fermer then fermer() end
	end)
	local contourFermer = Instance.new("UIStroke")
	contourFermer.Color = Charte.creme
	contourFermer.Thickness = 2
	contourFermer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contourFermer.Parent = boutonFermer

	-- ===== liste des cartes =====
	local defilement = Instance.new("ScrollingFrame")
	defilement.Name = "Objets"
	defilement.Position = UDim2.new(0, 12, 0, 76)
	defilement.Size = UDim2.new(1, -24, 1, -112)
	defilement.BackgroundTransparency = 1
	defilement.BorderSizePixel = 0
	defilement.ScrollBarThickness = 8
	defilement.ScrollBarImageColor3 = Charte.bois
	defilement.ScrollingDirection = Enum.ScrollingDirection.Y
	defilement.CanvasSize = UDim2.new(0, 0, 0, math.max(0, #liste * (HAUTEUR_CARTE + ECART_CARTES) - ECART_CARTES + 4))
	defilement.ZIndex = 22
	defilement.Parent = panneau
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Vertical
	disposition.Padding = UDim.new(0, ECART_CARTES)
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Parent = defilement
	local marge = Instance.new("UIPadding")
	marge.PaddingRight = UDim.new(0, 10)
	marge.PaddingTop = UDim.new(0, 2)
	marge.Parent = defilement

	local pied = Outils.etiquette(panneau, {
		Name = "Pied",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1, -24, 0, 20),
		Font = Charte.policeTexte,
		TextColor3 = Charte.ombre(Charte.bois),
		Text = "Objets permanents : achetés une fois, gardés pour toujours.",
		ZIndex = 22,
	})

	if #liste == 0 then
		pied.Text = "Le comptoir est vide pour le moment."
	end

	-- ===== cartes =====
	local cartes = {} -- { cle, objet, bouton, contour, prix, enAttente }

	local function majCarte(c)
		local prix = prixDe(c.objet)
		if possede(c.cle) then
			c.enAttente = nil
			c.bouton.Text = "✔ Possédé"
			c.bouton.BackgroundColor3 = Charte.dore
			c.bouton.TextColor3 = Charte.encre
			c.bouton.AutoButtonColor = false
			c.contour.Color = Charte.dore
			c.contour.Thickness = 3
			c.prix.Text = "Acquis"
			c.prix.TextColor3 = Charte.ombre(Charte.jungle)
			return
		end
		c.prix.Text = argentTexte(prix)
		c.contour.Color = Charte.ombre(Charte.sable)
		c.contour.Thickness = 2
		if c.enAttente then
			c.bouton.Text = "…"
			c.bouton.BackgroundColor3 = Charte.pierre
			c.bouton.TextColor3 = Charte.creme
			c.bouton.AutoButtonColor = false
			c.prix.TextColor3 = Charte.ombre(Charte.bois)
			return
		end
		if argentJoueur() >= prix then
			c.bouton.Text = "Acheter"
			c.bouton.BackgroundColor3 = Charte.jungle
			c.bouton.TextColor3 = Charte.creme
			c.bouton.AutoButtonColor = true
			c.prix.TextColor3 = Charte.ombre(Charte.bois)
		else
			c.bouton.Text = "Il manque " .. argentTexte(prix - argentJoueur())
			c.bouton.BackgroundColor3 = Charte.pierre
			c.bouton.TextColor3 = Charte.creme
			c.bouton.AutoButtonColor = false
			c.prix.TextColor3 = Charte.alerte
		end
	end

	local function majTout()
		bourse.Text = "Ta bourse : " .. argentTexte(argentJoueur())
		for _, c in ipairs(cartes) do
			local ok = pcall(majCarte, c)
			if not ok then
				c.bouton.Text = "Acheter"
			end
		end
	end

	-- petit tremblement quand l'achat est impossible
	local function secouer(inst)
		local depart = inst.Position
		task.spawn(function()
			local decalages = { 6, -6, 4, -4, 0 }
			for _, dx in ipairs(decalages) do
				if not inst.Parent then return end
				inst.Position = depart + UDim2.new(0, dx, 0, 0)
				task.wait(0.04)
			end
			inst.Position = depart
		end)
	end

	local function acheter(c)
		if possede(c.cle) or c.enAttente then return end
		local prix = prixDe(c.objet)
		if argentJoueur() < prix then
			son("refus")
			secouer(c.bouton)
			return
		end
		son("clic")
		c.enAttente = true
		pcall(majCarte, c)
		pcall(function()
			Reseau.Acheter:FireServer(c.cle)
		end)
		-- si le serveur refuse (notification), on rend le bouton après un délai
		task.delay(ATTENTE_MAX, function()
			if c.enAttente then
				c.enAttente = nil
				pcall(majCarte, c)
			end
		end)
	end

	for i, entree in ipairs(liste) do
		local objet = entree.objet
		local carte = Outils.cadre(defilement, {
			Name = "Carte_" .. tostring(entree.cle),
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, HAUTEUR_CARTE),
			BackgroundColor3 = Charte.creme,
			BackgroundTransparency = 0,
			ZIndex = 23,
		})
		local contour = Instance.new("UIStroke")
		contour.Color = Charte.ombre(Charte.sable)
		contour.Thickness = 2
		contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		contour.Parent = carte

		-- médaillon de l'objet
		local medaillon = Outils.cadre(carte, {
			Name = "Medaillon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.new(0, 72, 0, 72),
			BackgroundColor3 = Charte.terre,
			BackgroundTransparency = 0,
			ZIndex = 24,
		})
		Outils.etiquette(medaillon, {
			Name = "Icone",
			Position = UDim2.new(0, 8, 0, 8),
			Size = UDim2.new(1, -16, 1, -16),
			Text = ICONES[entree.cle] or "🎒",
			ZIndex = 25,
		})

		Outils.etiquette(carte, {
			Name = "Nom",
			Position = UDim2.new(0, 94, 0, 10),
			Size = UDim2.new(1, -250, 0, 28),
			Font = Charte.police,
			TextColor3 = Charte.encre,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = tostring(objet.nom or entree.cle),
			ZIndex = 24,
		})
		Outils.etiquette(carte, {
			Name = "Description",
			Position = UDim2.new(0, 94, 0, 40),
			Size = UDim2.new(1, -250, 0, 32),
			Font = Charte.policeTexte,
			TextColor3 = Charte.pierre,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Text = tostring(objet.description or ""),
			ZIndex = 24,
		})
		local prix = Outils.etiquette(carte, {
			Name = "Prix",
			Position = UDim2.new(0, 94, 1, -30),
			Size = UDim2.new(1, -250, 0, 22),
			Font = Charte.police,
			TextColor3 = Charte.ombre(Charte.bois),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = argentTexte(prixDe(objet)),
			ZIndex = 24,
		})

		local c = { cle = entree.cle, objet = objet, contour = contour, prix = prix }
		c.bouton = Outils.bouton(carte, {
			Name = "Acheter",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(0, 136, 0, 48),
			BackgroundColor3 = Charte.jungle,
			Text = "Acheter",
			ZIndex = 25,
		}, function()
			local ok = pcall(acheter, c)
			if not ok then
				c.enAttente = nil
			end
		end)
		local marge2 = Instance.new("UIPadding")
		marge2.PaddingLeft = UDim.new(0, 8)
		marge2.PaddingRight = UDim.new(0, 8)
		marge2.PaddingTop = UDim.new(0, 6)
		marge2.PaddingBottom = UDim.new(0, 6)
		marge2.Parent = c.bouton
		table.insert(cartes, c)
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

	boutonFermer.Activated:Connect(function()
		son("clic")
	end)
	voile.Activated:Connect(function()
		fermer()
	end)

	Bus.ecouter("OuvrirPanneau", function(nom)
		if nom == "Boutique" then
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
		if attribut == "Argent" then
			if ouvert then majTout() end
		elseif string.sub(attribut, 1, 6) == "Objet_" then
			local cle = string.sub(attribut, 7)
			for _, c in ipairs(cartes) do
				if c.cle == cle then
					local attendu = c.enAttente
					pcall(majCarte, c)
					if attendu and possede(cle) and ouvert then
						son("achat")
						local contourAnime = TweenService:Create(c.contour, TweenInfo.new(0.4), { Thickness = 3 })
						c.contour.Thickness = 7
						contourAnime:Play()
					end
				end
			end
			if ouvert then majTout() end
		end
	end)

	majTout()
end

return M
