-- Interface Boutique : le comptoir de l'explorateur, au look « simulateur Roblox » (voir STYLE.md §2 et §4).
-- S'ouvre sur Bus « OuvrirPanneau » == "Boutique" ; se ferme par X, Échap (ou bouton B) et Bus « FermerPanneaux ».
-- Une carte par objet de Equilibrage.boutique, mise à jour en direct sur Argent et Objet_*.
-- L'achat est demandé au serveur (Reseau.Acheter) qui vérifie tout.
-- Transitions : ouverture en « pop », fermeture en fondu.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local HAUTEUR_CARTE = 124
local ECART_CARTES = 14
local MARGE_LISTE = 8 -- marge autour de la liste (bordures et « pop » des cartes non rognés)
local LARGEUR_BOUTON = 150
local TAILLE_MEDAILLON = 96
local COLONNE_TEXTE = TAILLE_MEDAILLON + 18
local FOND_VOILE = 0.45
local DUREE_FONDU = 0.18
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
	local blanc = Color3.new(1, 1, 1)
	local noir = Color3.new(0, 0, 0)

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

	local function rond(gui)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = gui
		return c
	end

	-- reflet brillant sur la moitié haute d'un cadre (effet « bonbon », comme Style.bouton)
	local function reflet(parent, rayonPlein, zindex)
		local r = Instance.new("Frame")
		r.Name = "Reflet"
		r.BackgroundColor3 = blanc
		r.BackgroundTransparency = 0.6
		r.BorderSizePixel = 0
		r.AnchorPoint = Vector2.new(0.5, 0)
		r.Position = UDim2.new(0.5, 0, 0.06, 0)
		r.Size = UDim2.new(0.8, 0, 0.44, 0)
		r.ZIndex = zindex or 1
		if rayonPlein then rond(r) else Style.coins(r, 8) end
		local fondu = Instance.new("UIGradient")
		fondu.Rotation = 90
		fondu.Transparency = NumberSequence.new(0, 1)
		fondu.Parent = r
		r.Parent = parent
		return r
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
	ecran.BackgroundTransparency = FOND_VOILE
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
	local ombrePanneau = ecran:FindFirstChild("PanneauOmbre")
	if ombrePanneau then
		local limiteOmbre = ombrePanneau:FindFirstChildOfClass("UISizeConstraint")
		if limiteOmbre and limite then
			limiteOmbre.MaxSize = limite.MaxSize
			limiteOmbre.MinSize = limite.MinSize
		end
	end

	-- ===== en-tête : pastille « 💰 Ton argent : $X » sur une seule ligne =====
	local bourse = Instance.new("Frame")
	bourse.Name = "Bourse"
	bourse.AnchorPoint = Vector2.new(0.5, 0)
	bourse.Position = UDim2.new(0.5, 0, 0, 0)
	bourse.Size = UDim2.new(1, 0, 0, 46)
	bourse.BackgroundColor3 = blanc
	bourse.BorderSizePixel = 0
	rond(bourse)
	Style.bordure(bourse, 3)
	Style.degrade(bourse, couleurs.fond:Lerp(noir, 0.35), couleurs.fond:Lerp(noir, 0.1)).Name = "Fond"
	bourse.Parent = contenu
	local tailleBourse = Instance.new("UISizeConstraint")
	tailleBourse.MaxSize = Vector2.new(360, 46)
	tailleBourse.MinSize = Vector2.new(0, 46)
	tailleBourse.Parent = bourse
	local echelleBourse = Instance.new("UIScale")
	echelleBourse.Name = "Saut"
	echelleBourse.Parent = bourse
	local ligneBourse = Instance.new("UIListLayout")
	ligneBourse.FillDirection = Enum.FillDirection.Horizontal
	ligneBourse.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ligneBourse.VerticalAlignment = Enum.VerticalAlignment.Center
	ligneBourse.SortOrder = Enum.SortOrder.LayoutOrder
	ligneBourse.Padding = UDim.new(0, 8)
	ligneBourse.Parent = bourse
	Style.texte(bourse, {
		Name = "Piece",
		LayoutOrder = 0,
		Size = UDim2.new(0, 30, 0, 30),
		Text = "💰",
		contour = 0,
		tailleMax = 26,
	})
	Style.texte(bourse, {
		Name = "Libelle",
		LayoutOrder = 1,
		Size = UDim2.new(0, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		TextScaled = false,
		TextWrapped = false,
		TextSize = 22,
		Text = "Ton argent :",
		contour = 2.5,
	})
	local montant = Style.texte(bourse, {
		Name = "Montant",
		LayoutOrder = 2,
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		TextScaled = false,
		TextWrapped = false,
		TextSize = 30,
		TextColor3 = couleurs.argent,
		Text = "$0",
		contour = 3,
	})

	-- ===== liste des cartes =====
	local HAUT_LISTE = 56
	local defilement = Instance.new("ScrollingFrame")
	defilement.Name = "Objets"
	defilement.Position = UDim2.new(0, 0, 0, HAUT_LISTE)
	defilement.Size = UDim2.new(1, 0, 1, -(HAUT_LISTE + 30))
	defilement.BackgroundTransparency = 1
	defilement.BorderSizePixel = 0
	defilement.ScrollBarThickness = 8
	defilement.ScrollBarImageColor3 = Style.boutons.orange[1]
	defilement.ScrollingDirection = Enum.ScrollingDirection.Y
	defilement.CanvasSize = UDim2.new(0, 0, 0, math.max(0, #liste * (HAUTEUR_CARTE + ECART_CARTES) - ECART_CARTES + 2 * MARGE_LISTE))
	defilement.Parent = contenu
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Vertical
	disposition.HorizontalAlignment = Enum.HorizontalAlignment.Center
	disposition.Padding = UDim.new(0, ECART_CARTES)
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Parent = defilement
	local marge = Instance.new("UIPadding")
	marge.PaddingLeft = UDim.new(0, MARGE_LISTE)
	marge.PaddingRight = UDim.new(0, MARGE_LISTE + 10)
	marge.PaddingTop = UDim.new(0, MARGE_LISTE)
	marge.PaddingBottom = UDim.new(0, MARGE_LISTE)
	marge.Parent = defilement

	local pied = Style.texte(contenu, {
		Name = "Pied",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 24),
		TextColor3 = couleurs.revenu,
		Text = "✨ Objets permanents : achetés une fois, gardés pour toujours !",
		contour = 2,
		tailleMax = 19,
	})

	if #liste == 0 then
		pied.Text = "La boutique est vide pour le moment."
	end

	-- ===== cartes =====
	local cartes = {} -- { cle, objet, carte, bouton, libelle, contour, prix, pastille, disque, enAttente }

	-- libellé du bouton sur une seule ligne, un peu plus petit quand il est long
	local function libelleBouton(c, texte)
		c.libelle.Text = texte
		c.libelle.TextWrapped = false
		local limiteTexte = c.libelle:FindFirstChildOfClass("UITextSizeConstraint")
		if limiteTexte then
			limiteTexte.MaxTextSize = (utf8.len(texte) or #texte) > 8 and 20 or 24
		end
	end

	local function teinter(degrade, haut, bas)
		if degrade then degrade.Color = ColorSequence.new(haut, bas) end
	end

	local function majCarte(c)
		local prix = prixDe(c.objet)
		if possede(c.cle) then
			c.enAttente = nil
			Style.couleurBouton(c.bouton, "gris")
			libelleBouton(c, "✔ POSSÉDÉ")
			if c.contour then
				c.contour.Color = couleurs.revenu
				c.contour.Thickness = 4
			end
			teinter(c.fond, couleurs.carteClaire:Lerp(blanc, 0.1), couleurs.carteClaire:Lerp(noir, 0.1))
			teinter(c.disque, Style.boutons.vert[1], Style.boutons.vert[2])
			teinter(c.pastille, Style.boutons.jaune[1], Style.boutons.jaune[2])
			c.prix.Text = "✔ ACQUIS"
			c.prix.TextColor3 = blanc
			return
		end
		c.prix.Text = argentTexte(prix)
		c.prix.TextColor3 = couleurs.argent
		teinter(c.fond, couleurs.carte:Lerp(blanc, 0.08), couleurs.carte:Lerp(noir, 0.12))
		teinter(c.disque, Style.boutons.orange[1], Style.boutons.orange[2])
		teinter(c.pastille, couleurs.fond:Lerp(noir, 0.3), couleurs.fond:Lerp(noir, 0.55))
		if c.contour then
			c.contour.Color = couleurs.contour
			c.contour.Thickness = 3
		end
		if c.enAttente then
			Style.couleurBouton(c.bouton, "gris")
			libelleBouton(c, "…")
			return
		end
		if argentJoueur() >= prix then
			Style.couleurBouton(c.bouton, "vert")
			libelleBouton(c, "ACHETER")
		else
			Style.couleurBouton(c.bouton, "gris")
			libelleBouton(c, "🔒 ACHETER")
		end
	end

	local dernierMontant = nil
	local function majTout()
		local n = argentJoueur()
		montant.Text = argentTexte(n)
		if dernierMontant and n ~= dernierMontant and ecran.Visible then
			-- petit saut du compteur à chaque changement
			echelleBourse.Scale = 1.1
			TweenService:Create(echelleBourse, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end
		dernierMontant = n
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
		local interieur = Instance.new("UIPadding")
		interieur.PaddingLeft = UDim.new(0, 14)
		interieur.PaddingRight = UDim.new(0, 14)
		interieur.PaddingTop = UDim.new(0, 12)
		interieur.PaddingBottom = UDim.new(0, 12)
		interieur.Parent = carte

		-- médaillon rond : anneau sombre cerné de noir, disque en dégradé orange, reflet brillant
		local medaillon = Instance.new("Frame")
		medaillon.Name = "Medaillon"
		medaillon.AnchorPoint = Vector2.new(0, 0.5)
		medaillon.Position = UDim2.new(0, 0, 0.5, 0)
		medaillon.Size = UDim2.new(0, TAILLE_MEDAILLON, 0, TAILLE_MEDAILLON)
		medaillon.BackgroundColor3 = couleurs.fond:Lerp(noir, 0.35)
		medaillon.BorderSizePixel = 0
		rond(medaillon)
		Style.bordure(medaillon, 3)
		medaillon.Parent = carte
		local disque = Instance.new("Frame")
		disque.Name = "Disque"
		disque.AnchorPoint = Vector2.new(0.5, 0.5)
		disque.Position = UDim2.fromScale(0.5, 0.5)
		disque.Size = UDim2.new(1, -12, 1, -12)
		disque.BackgroundColor3 = blanc
		disque.BorderSizePixel = 0
		rond(disque)
		local degradeDisque = Style.degrade(disque, Style.boutons.orange[1], Style.boutons.orange[2])
		disque.Parent = medaillon
		reflet(disque, true, 1)
		-- l'icône est posée à côté (pas dans) le médaillon : le dégradé ne doit pas la teinter
		Style.texte(carte, {
			Name = "Icone",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, TAILLE_MEDAILLON / 2, 0.5, 2),
			Size = UDim2.new(0, 66, 0, 66),
			Text = ICONES[entree.cle] or "🎒",
			ZIndex = 3,
			contour = 0,
			tailleMax = 58,
		})

		local largeurTexte = -(COLONNE_TEXTE + LARGEUR_BOUTON + 14)
		Style.texte(carte, {
			Name = "Nom",
			Position = UDim2.new(0, COLONNE_TEXTE, 0, 0),
			Size = UDim2.new(1, largeurTexte, 0, 30),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = tostring(objet.nom or entree.cle),
			contour = 3,
			tailleMax = 28,
		})
		Style.texte(carte, {
			Name = "Description",
			Position = UDim2.new(0, COLONNE_TEXTE, 0, 33),
			Size = UDim2.new(1, largeurTexte, 0, 30),
			TextColor3 = Color3.fromRGB(220, 226, 248),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Text = tostring(objet.description or ""),
			contour = 1.5,
			tailleMax = 17,
		})

		-- prix dans une pastille arrondie cernée de noir
		local pastille = Instance.new("Frame")
		pastille.Name = "Pastille"
		pastille.AnchorPoint = Vector2.new(0, 1)
		pastille.Position = UDim2.new(0, COLONNE_TEXTE, 1, 0)
		pastille.Size = UDim2.new(0, 150, 0, 32)
		pastille.BackgroundColor3 = blanc
		pastille.BorderSizePixel = 0
		rond(pastille)
		Style.bordure(pastille, 2.5)
		local degradePastille = Style.degrade(pastille, couleurs.fond:Lerp(noir, 0.3), couleurs.fond:Lerp(noir, 0.55))
		pastille.Parent = carte
		local prix = Style.texte(pastille, {
			Name = "Prix",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -16, 1, -6),
			TextColor3 = couleurs.argent,
			TextWrapped = false,
			Text = argentTexte(prixDe(objet)),
			ZIndex = 2,
			contour = 2.5,
			tailleMax = 22,
		})

		local c = {
			cle = entree.cle, objet = objet, carte = carte, contour = carte:FindFirstChild("Bordure"),
			fond = carte:FindFirstChild("Fond"), prix = prix, pastille = degradePastille, disque = degradeDisque,
		}
		c.bouton, c.libelle = Style.bouton(carte, {
			Name = "Acheter",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, LARGEUR_BOUTON, 0, 58),
			couleur = "vert",
			texte = "ACHETER",
			tailleMax = 24,
			ZIndex = 3,
		}, function()
			local ok = pcall(acheter, c)
			if not ok then
				c.enAttente = nil
			end
		end)
		table.insert(cartes, c)
	end

	-- ===== ouverture (pop) / fermeture (fondu) =====
	local ouvert = false
	local jeton = 0
	local sauvegarde = nil -- { { inst, prop, valeur } } pendant un fondu
	local tweensFondu = {}

	-- remet les transparences d'origine (après un fondu terminé ou interrompu)
	local function restaurer()
		for _, tw in ipairs(tweensFondu) do
			pcall(function() tw:Cancel() end)
		end
		tweensFondu = {}
		if sauvegarde then
			for _, s in ipairs(sauvegarde) do
				pcall(function() s[1][s[2]] = s[3] end)
			end
			sauvegarde = nil
		end
	end

	local function fondre(inst, prop, info)
		local ok, valeur = pcall(function() return inst[prop] end)
		if not ok or type(valeur) ~= "number" or valeur >= 1 then return end
		table.insert(sauvegarde, { inst, prop, valeur })
		local tw = TweenService:Create(inst, info, { [prop] = 1 })
		table.insert(tweensFondu, tw)
		tw:Play()
	end

	local function ouvrir()
		jeton = jeton + 1
		restaurer()
		majTout()
		if ouvert then return end
		ouvert = true
		ecran.BackgroundTransparency = 1
		ecran.Visible = true
		TweenService:Create(ecran, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = FOND_VOILE }):Play()
		Style.pop(panneau)
		if ombrePanneau then Style.pop(ombrePanneau) end
		son("clic")
	end

	local function fermer()
		if not ouvert then return end
		ouvert = false
		jeton = jeton + 1
		local monJeton = jeton
		restaurer()
		sauvegarde = {}
		local info = TweenInfo.new(DUREE_FONDU, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ok = pcall(function()
			for _, o in ipairs(ecran:GetDescendants()) do
				if o:IsA("UIStroke") then
					fondre(o, "Transparency", info)
				elseif o:IsA("GuiObject") then
					fondre(o, "BackgroundTransparency", info)
					if o:IsA("TextLabel") or o:IsA("TextButton") then
						fondre(o, "TextTransparency", info)
					elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
						fondre(o, "ImageTransparency", info)
					end
				end
			end
			TweenService:Create(ecran, info, { BackgroundTransparency = 1 }):Play()
			local pop = panneau:FindFirstChild("Pop")
			if pop then
				TweenService:Create(pop, info, { Scale = 0.94 }):Play()
			end
		end)
		if not ok then
			restaurer()
			ecran.Visible = false
			return
		end
		task.delay(DUREE_FONDU + 0.02, function()
			if jeton ~= monJeton then return end
			ecran.Visible = false
			restaurer()
			ecran.BackgroundTransparency = FOND_VOILE
			local pop = panneau:FindFirstChild("Pop")
			if pop then pop.Scale = 1 end
		end)
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
