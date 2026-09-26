-- Interface Boutique : le comptoir de l'explorateur, au look « simulateur Roblox » (voir STYLE.md).
-- S'ouvre sur Bus « OuvrirPanneau » == "Boutique" ; se ferme par X, Échap (ou bouton B) et Bus « FermerPanneaux ».
-- Une carte par objet de Equilibrage.boutique, mise à jour en direct sur Argent et Objet_*.
-- L'achat est demandé au serveur (Reseau.Acheter) qui vérifie tout.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local HAUTEUR_CARTE = 112
local ECART_CARTES = 12
local LARGEUR_BOUTON = 156
local ATTENTE_MAX = 3 -- secondes avant de rendre la main si le serveur ne répond pas

-- pictogrammes des objets connus (les autres prennent le sac à dos)
local ICONES = {
	Bottes = "🥾",
	BatteOr = "🏏",
	Aimant = "🧲",
	Radar = "📡",
}

function M.demarrer(ctx)
	local Style = ctx.Style
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local E = ctx.Equilibrage

	local CATALOGUE = E.boutique or {}
	local couleurs = Style.couleurs

	-- ===== utilitaires =====
	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function argentTexte(n)
		local ok, t = pcall(Style.argent, n)
		if ok and type(t) == "string" then return t end
		return "$" .. tostring(math.floor(tonumber(n) or 0))
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

	-- ===== fond sombre et panneau =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Boutique"
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
		titre = "BOUTIQUE",
		icone = "🛒",
		couleur = "orange",
		Size = UDim2.new(0.94, 0, 0.86, 0),
	})
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.ZIndex = 2 -- au-dessus du voile : un clic sur le panneau ne le traverse pas
	local limite = panneau:FindFirstChildOfClass("UISizeConstraint")
	if limite then
		limite.MaxSize = Vector2.new(680, 580)
		limite.MinSize = Vector2.new(290, 260)
	end

	-- ===== en-tête : « Ton argent : $X » =====
	local bourse = Instance.new("Frame")
	bourse.Name = "Bourse"
	bourse.BackgroundTransparency = 1
	bourse.Size = UDim2.new(1, 0, 0, 40)
	bourse.Parent = contenu
	local ligneBourse = Instance.new("UIListLayout")
	ligneBourse.FillDirection = Enum.FillDirection.Horizontal
	ligneBourse.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ligneBourse.VerticalAlignment = Enum.VerticalAlignment.Center
	ligneBourse.SortOrder = Enum.SortOrder.LayoutOrder
	ligneBourse.Padding = UDim.new(0, 8)
	ligneBourse.Parent = bourse
	Style.texte(bourse, {
		Name = "Libelle",
		LayoutOrder = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextScaled = false,
		TextSize = 26,
		Text = "Ton argent :",
		contour = 3,
	})
	local montant = Style.texte(bourse, {
		Name = "Montant",
		LayoutOrder = 2,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextScaled = false,
		TextSize = 32,
		TextColor3 = couleurs.argent,
		Text = "$0",
		contour = 3,
	})

	-- ===== liste des cartes =====
	local defilement = Instance.new("ScrollingFrame")
	defilement.Name = "Objets"
	defilement.Position = UDim2.new(0, 0, 0, 48)
	defilement.Size = UDim2.new(1, 0, 1, -80)
	defilement.BackgroundTransparency = 1
	defilement.BorderSizePixel = 0
	defilement.ScrollBarThickness = 10
	defilement.ScrollBarImageColor3 = Style.boutons.orange[1]
	defilement.ScrollingDirection = Enum.ScrollingDirection.Y
	defilement.CanvasSize = UDim2.new(0, 0, 0, math.max(0, #liste * (HAUTEUR_CARTE + ECART_CARTES) - ECART_CARTES + 12))
	defilement.Parent = contenu
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Vertical
	disposition.Padding = UDim.new(0, ECART_CARTES)
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Parent = defilement
	local marge = Instance.new("UIPadding")
	marge.PaddingLeft = UDim.new(0, 4)
	marge.PaddingRight = UDim.new(0, 14)
	marge.PaddingTop = UDim.new(0, 4)
	marge.PaddingBottom = UDim.new(0, 4)
	marge.Parent = defilement

	local pied = Style.texte(contenu, {
		Name = "Pied",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 24),
		TextColor3 = couleurs.revenu,
		Text = "Objets permanents : achetés une fois, gardés pour toujours !",
		contour = 2,
		tailleMax = 20,
	})

	if #liste == 0 then
		pied.Text = "La boutique est vide pour le moment."
	end

	-- ===== cartes =====
	local cartes = {} -- { cle, objet, carte, bouton, libelle, contour, prix, enAttente }

	local function majCarte(c)
		local prix = prixDe(c.objet)
		if possede(c.cle) then
			c.enAttente = nil
			Style.couleurBouton(c.bouton, "gris")
			c.libelle.Text = "✔ POSSÉDÉ"
			if c.contour then
				c.contour.Color = couleurs.revenu
				c.contour.Thickness = 4
			end
			c.carte.BackgroundColor3 = couleurs.carteClaire
			c.prix.Text = "✔ ACQUIS"
			c.prix.TextColor3 = couleurs.revenu
			return
		end
		c.prix.Text = argentTexte(prix)
		c.prix.TextColor3 = couleurs.argent
		c.carte.BackgroundColor3 = couleurs.carte
		if c.contour then
			c.contour.Color = couleurs.contour
			c.contour.Thickness = 3
		end
		if c.enAttente then
			Style.couleurBouton(c.bouton, "gris")
			c.libelle.Text = "…"
			return
		end
		if argentJoueur() >= prix then
			Style.couleurBouton(c.bouton, "vert")
			c.libelle.Text = "ACHETER"
		else
			Style.couleurBouton(c.bouton, "gris")
			c.libelle.Text = "🔒 ACHETER"
		end
	end

	local function majTout()
		montant.Text = argentTexte(argentJoueur())
		for _, c in ipairs(cartes) do
			local ok = pcall(majCarte, c)
			if not ok then
				c.libelle.Text = "ACHETER"
			end
		end
	end

	-- petit tremblement quand l'achat est impossible
	local function secouer(inst)
		local depart = inst.Position
		task.spawn(function()
			local decalages = { 8, -8, 5, -5, 0 }
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
		local carte = Style.carte(defilement, {
			Name = "Carte_" .. tostring(entree.cle),
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, HAUTEUR_CARTE),
		})

		-- médaillon de l'objet : grande icône emoji sur fond orange
		local medaillon = Instance.new("Frame")
		medaillon.Name = "Medaillon"
		medaillon.AnchorPoint = Vector2.new(0, 0.5)
		medaillon.Position = UDim2.new(0, 12, 0.5, 0)
		medaillon.Size = UDim2.new(0, 84, 0, 84)
		medaillon.BackgroundColor3 = Color3.new(1, 1, 1)
		medaillon.BorderSizePixel = 0
		Style.coins(medaillon, 18)
		Style.bordure(medaillon, 3)
		Style.degrade(medaillon, Style.boutons.orange[1], Style.boutons.orange[2])
		medaillon.Parent = carte
		-- l'icône est posée à côté (pas dans) le médaillon : le dégradé ne doit pas la teinter
		Style.texte(carte, {
			Name = "Icone",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 54, 0.5, 0),
			Size = UDim2.new(0, 68, 0, 68),
			Text = ICONES[entree.cle] or "🎒",
			ZIndex = 2,
			contour = 0,
		})

		Style.texte(carte, {
			Name = "Nom",
			Position = UDim2.new(0, 108, 0, 8),
			Size = UDim2.new(1, -(108 + LARGEUR_BOUTON + 24), 0, 32),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = tostring(objet.nom or entree.cle),
			contour = 3,
			tailleMax = 28,
		})
		Style.texte(carte, {
			Name = "Description",
			Position = UDim2.new(0, 108, 0, 42),
			Size = UDim2.new(1, -(108 + LARGEUR_BOUTON + 24), 0, 32),
			TextColor3 = Color3.fromRGB(216, 222, 245),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Text = tostring(objet.description or ""),
			contour = 1.5,
			tailleMax = 18,
		})
		local prix = Style.texte(carte, {
			Name = "Prix",
			Position = UDim2.new(0, 108, 1, -36),
			Size = UDim2.new(1, -(108 + LARGEUR_BOUTON + 24), 0, 30),
			TextColor3 = couleurs.argent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = argentTexte(prixDe(objet)),
			contour = 3,
			tailleMax = 28,
		})

		local c = { cle = entree.cle, objet = objet, carte = carte, contour = carte:FindFirstChild("Bordure"), prix = prix }
		c.bouton, c.libelle = Style.bouton(carte, {
			Name = "Acheter",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(0, LARGEUR_BOUTON, 0, 60),
			couleur = "vert",
			texte = "ACHETER",
			tailleMax = 26,
			ZIndex = 3,
		}, function()
			local ok = pcall(acheter, c)
			if not ok then
				c.enAttente = nil
			end
		end)
		table.insert(cartes, c)
	end

	-- ===== ouverture / fermeture =====
	local ouvert = false

	local function ouvrir()
		majTout()
		if ouvert then return end
		ouvert = true
		ecran.Visible = true
		Style.pop(panneau)
		son("clic")
	end

	local function fermer()
		if not ouvert then return end
		ouvert = false
		ecran.Visible = false
	end

	boutonFermer.Activated:Connect(function()
		son("clic")
		fermer()
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
						Style.pop(c.carte, 1.06)
						if c.contour then
							c.contour.Thickness = 8
							TweenService:Create(c.contour, TweenInfo.new(0.4), { Thickness = 4 }):Play()
						end
					end
				end
			end
			if ouvert then majTout() end
		end
	end)

	majTout()
end

return M
