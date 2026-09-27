-- Interface HUD : argent et revenu, menu de gauche, bouton de collecte, bandeau d'événement et notifications.
-- Look « simulateur Roblox » (voir STYLE.md §2 et §4) : tout passe par ctx.Style.
-- Version 2 : ombres portées, compteur d'argent qui défile, grandes icônes, ruban d'événement
-- en dégradé avec pastille d'icône, notifications en capsule avec petite icône et fondu de sortie.
-- Retouche : ruban d'événement compact (en haut à droite) quand un panneau est ouvert, libellés du menu
-- à taille fixe sur capsule, bouton Collecter en deux niveaux (libellé + capsule du montant),
-- notifications en vraie capsule mesurée, pas de doublon de l'alerte de vol (Interface/Vol s'en charge).
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local DUREE_TOAST = 3
local TOASTS_MAX = 5
local PERIODE_BASE = 0.3
local HAUTEUR_TOAST = 46
local ECART_TOAST = 6
local TAILLE_MENU = 84       -- côté des boutons carrés du menu (avant l'échelle d'écran)
local TAILLE_NOM_MENU = 14   -- taille fixe commune des libellés du menu
local ECART_MENU = 18       -- laisse la place à la capsule du libellé qui dépasse sous chaque bouton
local DUREE_COMPTEUR = 0.65 -- durée du défilement de l'argent vers sa nouvelle valeur
local DECALAGE_OMBRE = 5    -- ombre portée des blocs (px, vers le bas)

-- icône et couleur (clé de Style.boutons) du ruban pour chaque événement connu
local EVENEMENTS = {
	PluieDeMeteores = { icone = "☄️", couleur = "orange" },
	Eruption = { icone = "🌋", couleur = "rouge" },
	LuneDoree = { icone = "🌕", couleur = "jaune" },
}

-- petite icône et couleur de pastille (clé de Style.boutons) de chaque genre de notification
local GENRES = {
	info = { icone = "✨", pastille = "jaune" },
	succes = { icone = "✅", pastille = "vert" },
	alerte = { icone = "⚠️", pastille = "rouge" },
	vol = { icone = "🚨", pastille = "rouge" },
}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Style = ctx.Style or require(game:GetService("ReplicatedStorage").Dino.Style)
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local Equilibrage = ctx.Equilibrage

	local BLANC = Style.couleurs.texte
	local NOIR = Style.couleurs.ombre

	local ecran = Instance.new("Frame")
	ecran.Name = "HUD"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundTransparency = 1
	ecran.Parent = ctx.gui

	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function animer(objet, duree, props, style, direction)
		pcall(function()
			local info = TweenInfo.new(duree, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
			TweenService:Create(objet, info, props):Play()
		end)
	end

	-- un groupe = cadre transparent dont l'UIScale « Adapte » suit la taille de l'écran
	local groupes = {}
	local function groupe(nom, props)
		local f = Instance.new("Frame")
		f.Name = nom
		f.BackgroundTransparency = 1
		for cle, valeur in pairs(props) do
			f[cle] = valeur
		end
		local e = Instance.new("UIScale")
		e.Name = "Adapte"
		e.Parent = f
		f.Parent = ecran
		table.insert(groupes, e)
		return f
	end

	-- ombre portée douce : cadre noir translucide arrondi, frère de l'objet et placé derrière lui
	local function ombrePortee(parent, props)
		local o = Instance.new("Frame")
		o.Name = "Ombre"
		o.BackgroundColor3 = NOIR
		o.BackgroundTransparency = props.transparence or 0.6
		o.BorderSizePixel = 0
		o.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
		o.Position = props.Position or UDim2.fromOffset(0, DECALAGE_OMBRE)
		o.Size = props.Size or UDim2.fromScale(1, 1)
		o.ZIndex = props.ZIndex or 1
		Style.coins(o, props.rayon or 16)
		o.Parent = parent
		return o
	end

	-- texte « ombre » : copie noire translucide décalée sous un texte cerné (effet de relief)
	local function ombreTexte(parent, modele, props)
		local o = Style.texte(parent, {
			Name = modele.Name .. "Ombre",
			AnchorPoint = modele.AnchorPoint,
			Position = modele.Position + UDim2.fromOffset(props.dx or 2, props.dy or 4),
			Size = modele.Size,
			TextColor3 = NOIR,
			TextTransparency = 0.55,
			TextXAlignment = modele.TextXAlignment,
			Text = modele.Text,
			titre = props.titre,
			contour = props.contour,
			tailleMax = props.tailleMax,
			ZIndex = math.max(1, modele.ZIndex - 1),
		})
		local c = o:FindFirstChild("Contour")
		if c then
			c.Color = NOIR
			c.Transparency = 0.55
		end
		return o
	end

	-- ===== argent (énorme, en bas à gauche) =====
	local blocArgent = groupe("Argent", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 16, 1, -16),
		Size = UDim2.fromOffset(360, 116),
	})

	local texteArgent = Style.texte(blocArgent, {
		Name = "Montant",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 76),
		TextColor3 = Style.couleurs.argent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Charte.argent(0),
		titre = true,
		contour = 4,
		tailleMax = 72,
		ZIndex = 3,
	})
	local ombreArgent = ombreTexte(blocArgent, texteArgent, { titre = true, contour = 4, tailleMax = 72, dx = 2, dy = 5 })

	local texteRevenu = Style.texte(blocArgent, {
		Name = "Revenu",
		Position = UDim2.fromOffset(4, 78),
		Size = UDim2.new(1, -4, 0, 34),
		TextColor3 = Style.couleurs.revenu,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "+" .. Style.revenu(0),
		contour = 3,
		tailleMax = 34,
		ZIndex = 3,
	})
	local ombreRevenu = ombreTexte(blocArgent, texteRevenu, { contour = 3, tailleMax = 34, dx = 1, dy = 3 })

	local cible = tonumber(joueur:GetAttribute("Argent")) or 0
	local affiche = cible
	local depart = cible
	local progression = 1
	local dernierTexte = ""

	local function ecrireArgent(texte)
		texteArgent.Text = texte
		ombreArgent.Text = texte
	end
	ecrireArgent(Charte.argent(affiche))

	local dernierPop = 0
	local function rebondir()
		local maintenant = os.clock()
		if maintenant - dernierPop < 0.2 then return end
		dernierPop = maintenant
		Style.pop(texteArgent, 1.18)
		Style.pop(ombreArgent, 1.18)
		-- éclair blanc qui revient au vert
		texteArgent.TextColor3 = BLANC
		animer(texteArgent, 0.45, { TextColor3 = Style.couleurs.argent })
	end

	-- petit « +$120 » vert qui monte au-dessus du compteur puis s'efface
	local function gainFlottant(n)
		local t = Style.texte(blocArgent, {
			Name = "Gain",
			Position = UDim2.fromOffset(8, -6),
			Size = UDim2.fromOffset(220, 38),
			TextColor3 = Style.couleurs.argent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "+" .. Charte.argent(n),
			titre = true,
			contour = 3,
			tailleMax = 34,
			ZIndex = 4,
		})
		Style.pop(t, 1.2)
		local info = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		pcall(function()
			TweenService:Create(t, info, { Position = UDim2.fromOffset(8, -46), TextTransparency = 1 }):Play()
			local c = t:FindFirstChild("Contour")
			if c then TweenService:Create(c, info, { Transparency = 1 }):Play() end
		end)
		task.delay(0.95, function()
			if t.Parent then t:Destroy() end
		end)
	end

	joueur:GetAttributeChangedSignal("Argent"):Connect(function()
		local n = tonumber(joueur:GetAttribute("Argent")) or 0
		if n > cible then
			rebondir()
			if n - cible >= 1 then
				pcall(gainFlottant, n - cible)
			end
		end
		-- le compteur repart de la valeur affichée vers la nouvelle cible
		depart = affiche
		cible = n
		progression = 0
	end)

	-- défilement du compteur : courbe « ease-out » cubique sur DUREE_COMPTEUR secondes
	RunService.Heartbeat:Connect(function(dt)
		if affiche ~= cible then
			progression = math.min(1, progression + (dt or 0) / DUREE_COMPTEUR)
			local k = 1 - (1 - progression) ^ 3
			affiche = depart + (cible - depart) * k
			if progression >= 1 or math.abs(cible - affiche) < 0.5 then
				affiche = cible
			end
		end
		local t = Charte.argent(math.floor(affiche + 0.5))
		if t ~= dernierTexte then
			dernierTexte = t
			ecrireArgent(t)
		end
	end)

	local function majRevenu()
		local r = tonumber(joueur:GetAttribute("RevenuParSeconde")) or 0
		local t = "+" .. Style.revenu(r)
		texteRevenu.Text = t
		ombreRevenu.Text = t
	end
	joueur:GetAttributeChangedSignal("RevenuParSeconde"):Connect(majRevenu)
	majRevenu()

	-- ===== bandeau d'événement (ruban en haut au centre, 10..84 px) =====
	local zoneEvenement = groupe("Evenement", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(480, 74),
		Visible = false,
	})
	-- cadre « Compact » : porte l'UIScale du mode compact (l'UIScale « Adapte » reste sur la zone)
	local cadreCompact = Instance.new("Frame")
	cadreCompact.Name = "Compact"
	cadreCompact.BackgroundTransparency = 1
	cadreCompact.AnchorPoint = Vector2.new(0.5, 0)
	cadreCompact.Position = UDim2.fromScale(0.5, 0)
	cadreCompact.Size = UDim2.fromScale(1, 1)
	cadreCompact.Parent = zoneEvenement
	local echelleCompact = Instance.new("UIScale")
	echelleCompact.Name = "EchelleCompact"
	echelleCompact.Scale = 1
	echelleCompact.Parent = cadreCompact

	-- tout le ruban dans un cadre « Bandeau » pour le faire rebondir d'un bloc
	local bandeau = Instance.new("Frame")
	bandeau.Name = "Bandeau"
	bandeau.BackgroundTransparency = 1
	bandeau.Size = UDim2.fromScale(1, 1)
	bandeau.Parent = cadreCompact

	-- halo coloré qui « respire » autour du ruban
	local halo = Instance.new("Frame")
	halo.Name = "Halo"
	halo.BackgroundColor3 = Style.boutons.violet[1]
	halo.BackgroundTransparency = 0.6
	halo.BorderSizePixel = 0
	halo.Position = UDim2.fromOffset(24, -2)
	halo.Size = UDim2.new(1, -18, 1, -2)
	halo.ZIndex = 1
	Style.coins(halo, 24)
	halo.Parent = bandeau
	ombrePortee(bandeau, { Position = UDim2.fromOffset(30, 4 + DECALAGE_OMBRE), Size = UDim2.new(1, -30, 1, -10), rayon = 18, transparence = 0.5, ZIndex = 1 })

	local ruban = Instance.new("Frame")
	ruban.Name = "Ruban"
	ruban.Position = UDim2.fromOffset(30, 4)
	ruban.Size = UDim2.new(1, -30, 1, -10)
	ruban.BackgroundColor3 = Color3.new(1, 1, 1)
	ruban.BorderSizePixel = 0
	ruban.ZIndex = 2
	Style.coins(ruban, 18)
	Style.bordure(ruban, 4)
	local degradeRuban = Style.degrade(ruban, Style.boutons.violet[1], Style.boutons.violet[2])
	ruban.Parent = bandeau

	-- reflet brillant sur la moitié haute du ruban (comme les boutons)
	local refletRuban = Instance.new("Frame")
	refletRuban.Name = "Reflet"
	refletRuban.BackgroundColor3 = Color3.new(1, 1, 1)
	refletRuban.BackgroundTransparency = 0.7
	refletRuban.BorderSizePixel = 0
	refletRuban.Position = UDim2.fromOffset(6, 3)
	refletRuban.Size = UDim2.new(1, -12, 0.44, 0)
	refletRuban.ZIndex = 2
	Style.coins(refletRuban, 14)
	local fonduRefletRuban = Instance.new("UIGradient")
	fonduRefletRuban.Rotation = 90
	fonduRefletRuban.Transparency = NumberSequence.new(0.1, 1)
	fonduRefletRuban.Parent = refletRuban
	refletRuban.Parent = ruban

	local texteBandeau = Style.texte(ruban, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(52, 5),
		Size = UDim2.new(1, -64, 0, 32),
		Text = "",
		titre = true,
		contour = 3.5,
		tailleMax = 30,
		ZIndex = 3,
	})

	-- pastille sombre du compte à rebours, sous le titre
	local pastilleCompte = Instance.new("Frame")
	pastilleCompte.Name = "Pastille"
	pastilleCompte.AnchorPoint = Vector2.new(0.5, 1)
	pastilleCompte.Position = UDim2.new(0.5, 19, 1, -5)
	pastilleCompte.Size = UDim2.fromOffset(112, 22)
	pastilleCompte.BackgroundColor3 = NOIR
	pastilleCompte.BackgroundTransparency = 0.5
	pastilleCompte.BorderSizePixel = 0
	pastilleCompte.ZIndex = 3
	Style.coins(pastilleCompte, 11)
	pastilleCompte.Parent = ruban
	local texteCompte = Style.texte(pastilleCompte, {
		Name = "Compte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -10, 1, -2),
		TextColor3 = Style.couleurs.revenu,
		Text = "",
		contour = 2.5,
		tailleMax = 26,
		ZIndex = 4,
	})

	-- grosse pastille ronde de l'icône, qui déborde à gauche du ruban
	local pastilleIcone = Instance.new("Frame")
	pastilleIcone.Name = "Icone"
	pastilleIcone.Position = UDim2.fromOffset(0, 0)
	pastilleIcone.Size = UDim2.fromOffset(72, 72)
	pastilleIcone.BackgroundColor3 = Color3.new(1, 1, 1)
	pastilleIcone.BorderSizePixel = 0
	pastilleIcone.ZIndex = 4
	Style.coins(pastilleIcone, 36)
	Style.bordure(pastilleIcone, 4)
	Style.degrade(pastilleIcone, Style.couleurs.fondHaut, Style.couleurs.fond).Name = "Fond"
	pastilleIcone.Parent = bandeau
	local emojiEvenement = Style.texte(pastilleIcone, {
		Name = "Emoji",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.74, 0.74),
		Text = "",
		contour = 2,
		tailleMax = 48,
		ZIndex = 5,
	})

	local function nomEvenement(cle)
		local liste = Equilibrage.evenements and Equilibrage.evenements.liste
		if liste and liste[cle] and liste[cle].nom then
			return liste[cle].nom
		end
		return tostring(cle)
	end

	local function formatDuree(s)
		s = math.max(0, math.floor(s))
		return string.format("%d:%02d", math.floor(s / 60), s % 60)
	end

	local evenementAffiche = ""
	local function majBandeau()
		local cle = Etat:GetAttribute("Evenement")
		if type(cle) ~= "string" or cle == "" then
			zoneEvenement.Visible = false
			evenementAffiche = ""
			return
		end
		local fin = tonumber(Etat:GetAttribute("EvenementFin")) or 0
		local reste = fin - workspace:GetServerTimeNow()
		if cle ~= evenementAffiche then
			evenementAffiche = cle
			local def = EVENEMENTS[cle] or { icone = "🦖", couleur = "violet" }
			local palette = Style.boutons[def.couleur] or Style.boutons.violet
			degradeRuban.Color = ColorSequence.new(palette[1], palette[2])
			halo.BackgroundColor3 = palette[1]
			emojiEvenement.Text = def.icone
			texteBandeau.Text = string.upper(nomEvenement(cle))
			zoneEvenement.Visible = true
			Style.pop(bandeau, 1.12)
		end
		zoneEvenement.Visible = true
		texteCompte.Text = "⏱ " .. formatDuree(reste)
	end

	task.spawn(function()
		local phase = 0
		while ecran.Parent do
			local ok = pcall(majBandeau)
			if ok and zoneEvenement.Visible then
				phase = phase + 1
				-- le halo respire doucement pour attirer l'œil sans clignoter
				if phase % 2 == 0 then
					animer(halo, 0.5, { BackgroundTransparency = 0.35 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				else
					animer(halo, 0.5, { BackgroundTransparency = 0.8 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				end
			end
			task.wait(0.5)
		end
	end)

	-- ===== ruban compact pendant qu'un panneau est ouvert =====
	-- Les panneaux (Boutique, Dinodex, Renaissance) occupent le haut du centre : le ruban se range en
	-- pastille « icône + chrono » en haut à droite, sous le bouton musique (64..120 px), puis revient.
	local DUREE_COMPACT = 0.2
	local ECHELLE_COMPACT = 0.7
	local NORMAL = {
		zone = { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(480, 74) },
		cadre = { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0) },
		compte = { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 19, 1, -5), Size = UDim2.fromOffset(112, 22) },
		titre = 0,
	}
	local COMPACT = {
		zone = { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 128), Size = UDim2.fromOffset(232, 74) },
		cadre = { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0) },
		compte = { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(128, 38) },
		titre = 1,
	}
	local contourTitre = texteBandeau:FindFirstChild("Contour")
	local modeCompact = false

	local function appliquerMode(compact)
		if compact == modeCompact then return end
		modeCompact = compact
		local m = compact and COMPACT or NORMAL
		local instantane = not zoneEvenement.Visible
		local function vers(objet, props)
			if instantane then
				for cle, valeur in pairs(props) do objet[cle] = valeur end
			else
				animer(objet, DUREE_COMPACT, props)
			end
		end
		vers(zoneEvenement, m.zone)
		vers(cadreCompact, m.cadre)
		vers(echelleCompact, { Scale = compact and ECHELLE_COMPACT or 1 })
		vers(pastilleCompte, m.compte)
		vers(texteBandeau, { TextTransparency = m.titre })
		if contourTitre then vers(contourTitre, { Transparency = m.titre }) end
	end

	-- panneaux fabriqués par Style.panneau (cadre avec « Bandeau », « Contenu » et bouton « Fermer »)
	local panneaux = {}
	local function chercherPanneaux()
		panneaux = {}
		for _, o in ipairs(ctx.gui:GetDescendants()) do
			if o:IsA("Frame") and o:FindFirstChild("Contenu") and o:FindFirstChild("Bandeau") and o:FindFirstChild("Fermer") then
				table.insert(panneaux, o)
			end
		end
	end

	-- vrai si le panneau est affiché (lui et tous ses parents visibles, groupe non fondu)
	local function affiche(o)
		while o and o ~= ctx.gui do
			if o:IsA("GuiObject") and not o.Visible then return false end
			if o:IsA("CanvasGroup") and o.GroupTransparency > 0.95 then return false end
			o = o.Parent
		end
		return o == ctx.gui
	end

	local function unPanneauOuvert()
		for _, p in ipairs(panneaux) do
			if p.Parent and affiche(p) then return true end
		end
		return false
	end

	-- les panneaux se ferment aussi par leur X, Échap ou le voile, sans passer par le Bus :
	-- on surveille leur visibilité tant que le ruban est compact
	local surveillance = 0
	local function surveiller()
		surveillance = surveillance + 1
		local moi = surveillance
		task.spawn(function()
			task.wait(0.4)
			while modeCompact and surveillance == moi and ecran.Parent do
				if #panneaux == 0 then pcall(chercherPanneaux) end
				if #panneaux > 0 then
					local ok, ouvert = pcall(unPanneauOuvert)
					if ok and not ouvert then
						appliquerMode(false)
						break
					end
				end
				task.wait(0.25)
			end
		end)
	end

	Bus.ecouter("OuvrirPanneau", function()
		appliquerMode(true)
		surveiller()
	end)
	Bus.ecouter("FermerPanneaux", function()
		surveillance = surveillance + 1
		appliquerMode(false)
	end)

	-- ===== menu de gauche : gros boutons carrés à grande icône =====
	-- libellé court « Renaître » : les trois noms tiennent à la même taille fixe (le panneau reste « Renaissance »)
	local BOUTONS = {
		{ icone = "🛒", nom = "Boutique", panneau = "Boutique", couleur = "orange" },
		{ icone = "♻️", nom = "Renaître", panneau = "Renaissance", couleur = "violet" },
		{ icone = "📖", nom = "Dinodex", panneau = "Index", couleur = "bleu" },
	}
	local DEBORD_NOM = 6   -- la capsule du libellé dépasse de 6 px sous le bouton
	local hauteurMenu = #BOUTONS * TAILLE_MENU + (#BOUTONS - 1) * ECART_MENU + DEBORD_NOM + DECALAGE_OMBRE
	local colonne = groupe("Boutons", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(TAILLE_MENU + 8, hauteurMenu),
	})
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Vertical
	disposition.HorizontalAlignment = Enum.HorizontalAlignment.Center
	disposition.Padding = UDim.new(0, ECART_MENU)
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Parent = colonne

	for i, def in ipairs(BOUTONS) do
		-- chaque bouton est posé dans une « case » qui porte aussi son ombre portée
		local case = Instance.new("Frame")
		case.Name = "Case" .. def.panneau
		case.LayoutOrder = i
		case.BackgroundTransparency = 1
		case.Size = UDim2.fromOffset(TAILLE_MENU, TAILLE_MENU)
		case.Parent = colonne
		ombrePortee(case, { rayon = 20, transparence = 0.55, ZIndex = 1 })

		local b, icone = Style.bouton(case, {
			Name = def.panneau,
			Size = UDim2.fromScale(1, 1),
			couleur = def.couleur,
			icone = def.icone,
			rayon = 20,
			tailleMax = 56,
			ZIndex = 2,
		}, function()
			son("clic")
			Bus.emettre("OuvrirPanneau", def.panneau)
		end)
		-- emoji géant dans les 2/3 hauts, sans toucher la capsule du libellé
		icone.Size = UDim2.new(1, -12, 0.6, 0)
		icone.Position = UDim2.new(0.5, 0, 0.36, 0)

		-- capsule sombre à cheval sur le bas du bouton, libellé à taille fixe commune
		local capsule = Instance.new("Frame")
		capsule.Name = "CapsuleNom"
		capsule.AnchorPoint = Vector2.new(0.5, 1)
		capsule.Position = UDim2.new(0.5, 0, 1, DEBORD_NOM)
		capsule.Size = UDim2.new(1, -6, 0, 22)
		capsule.BackgroundColor3 = Style.couleurs.fond
		capsule.BackgroundTransparency = 0.1
		capsule.BorderSizePixel = 0
		capsule.ZIndex = 4
		Style.coins(capsule, 11)
		Style.bordure(capsule, 2.5)
		capsule.Parent = b
		local nom = Style.texte(capsule, {
			Name = "Nom",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -4, 1, 0),
			Text = def.nom,
			contour = 2.5,
			ZIndex = 5,
		})
		nom.TextScaled = false
		nom.TextSize = TAILLE_NOM_MENU
	end

	-- ===== bouton Collecter (visible dans sa Base) =====
	local zoneCollecte = groupe("ZoneCollecte", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -100),
		Size = UDim2.fromOffset(340, 84),
		Visible = false,
	})
	ombrePortee(zoneCollecte, { Position = UDim2.fromOffset(0, 6), rayon = 24, transparence = 0.5, ZIndex = 1 })
	local derniereCollecte = 0
	local boutonCollecte, libelleCollecte = Style.bouton(zoneCollecte, {
		Name = "Collecter",
		Size = UDim2.fromScale(1, 1),
		couleur = "vert",
		texte = "COLLECTER",
		icone = "💰",
		rayon = 24,
		tailleMax = 32,
		ZIndex = 2,
	}, function()
		local maintenant = os.clock()
		if maintenant - derniereCollecte < 0.5 then return end
		derniereCollecte = maintenant
		son("clic")
		pcall(function() Reseau.Collecter:FireServer() end)
	end)
	libelleCollecte.Font = Style.policeTitre
	libelleCollecte.TextWrapped = false
	local contourCollecte = libelleCollecte:FindFirstChild("Contour")
	if contourCollecte then contourCollecte.Thickness = 3.5 end

	-- deux niveaux : « 💰 COLLECTER » sur une ligne en haut, montant dans une capsule sombre dessous
	local LIBELLE_SEUL = { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }
	local LIBELLE_HAUT = { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 4) }
	libelleCollecte.Size = UDim2.new(1, -28, 0.55, 0)
	libelleCollecte.AnchorPoint = LIBELLE_SEUL.AnchorPoint
	libelleCollecte.Position = LIBELLE_SEUL.Position

	local capsuleMontant = Instance.new("Frame")
	capsuleMontant.Name = "CapsuleMontant"
	capsuleMontant.AnchorPoint = Vector2.new(0.5, 1)
	capsuleMontant.Position = UDim2.new(0.5, 0, 1, -5)
	capsuleMontant.Size = UDim2.fromOffset(120, 30)
	capsuleMontant.BackgroundColor3 = NOIR
	capsuleMontant.BackgroundTransparency = 0.35
	capsuleMontant.BorderSizePixel = 0
	capsuleMontant.ZIndex = 3
	capsuleMontant.Visible = false
	Style.coins(capsuleMontant, 14)
	capsuleMontant.Parent = boutonCollecte
	local texteMontant = Style.texte(capsuleMontant, {
		Name = "Montant",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -14, 1, -2),
		TextColor3 = Style.couleurs.argent,
		Text = "",
		titre = true,
		contour = 2.5,
		tailleMax = 24,
		ZIndex = 4,
	})

	local function afficherMontant(stock)
		if stock then
			local t = Charte.argent(stock)
			if texteMontant.Text ~= t then
				texteMontant.Text = t
				local n = (utf8 and utf8.len(t)) or #t
				capsuleMontant.Size = UDim2.fromOffset(math.clamp(n * 16 + 34, 96, 210), 30)
			end
			capsuleMontant.Visible = true
			libelleCollecte.AnchorPoint = LIBELLE_HAUT.AnchorPoint
			libelleCollecte.Position = LIBELLE_HAUT.Position
		else
			capsuleMontant.Visible = false
			libelleCollecte.AnchorPoint = LIBELLE_SEUL.AnchorPoint
			libelleCollecte.Position = LIBELLE_SEUL.Position
		end
	end
	local couleurCollecte = "vert"

	local function zoneDeMaBase()
		local index = tonumber(joueur:GetAttribute("Base"))
		if not index then return nil end
		local bases = ctx.racine:FindFirstChild("Bases")
		if not bases then return nil end
		local base = bases:FindFirstChild("Base" .. index)
		if not base then return nil end
		local zone = base:FindFirstChild("Zone")
		if zone and zone:IsA("BasePart") then
			return zone
		end
		return nil
	end

	local function dansMaBase()
		local perso = joueur.Character
		if not perso then return false end
		local rac = perso:FindFirstChild("HumanoidRootPart")
		if not rac then return false end
		local zone = zoneDeMaBase()
		if not zone then return false end
		local p = zone.CFrame:PointToObjectSpace(rac.Position)
		local d = zone.Size / 2
		return math.abs(p.X) <= d.X and math.abs(p.Y) <= d.Y and math.abs(p.Z) <= d.Z
	end

	local function stockEnAttente()
		local total = 0
		local id = joueur.UserId
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:GetAttribute("Proprietaire") == id and dino:GetAttribute("Etat") == "Enclos" then
				total = total + (tonumber(dino:GetAttribute("Stock")) or 0)
			end
		end
		return total
	end

	task.spawn(function()
		local visiblePrec = false
		while ecran.Parent do
			local ok, dedans = pcall(dansMaBase)
			local visible = ok and dedans == true
			if visible then
				local ok2, stock = pcall(stockEnAttente)
				local couleur = "gris"
				if ok2 and stock >= 1 then
					afficherMontant(stock)
					couleur = "vert"
				else
					afficherMontant(nil)
				end
				if couleur ~= couleurCollecte then
					couleurCollecte = couleur
					Style.couleurBouton(boutonCollecte, couleur)
				end
			end
			if visible ~= visiblePrec then
				visiblePrec = visible
				zoneCollecte.Visible = visible
				if visible then
					Style.pop(boutonCollecte:FindFirstChild("Libelle") or boutonCollecte, 1.15)
				end
			end
			task.wait(PERIODE_BASE)
		end
	end)

	-- ===== notifications (capsules sombres cernées au milieu-haut, gros texte cerné) =====
	local TAILLE_TEXTE_TOAST = 28
	local pile = groupe("Toasts", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 270), -- sous la barre de verrou (144..190) et le bandeau de vol (198..262)
		Size = UDim2.fromOffset(640, TOASTS_MAX * (HAUTEUR_TOAST + ECART_TOAST)),
	})
	local dispoPile = Instance.new("UIListLayout")
	dispoPile.FillDirection = Enum.FillDirection.Vertical
	dispoPile.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dispoPile.Padding = UDim.new(0, ECART_TOAST)
	dispoPile.SortOrder = Enum.SortOrder.LayoutOrder
	dispoPile.Parent = pile

	-- couleurs de texte choisies pour rester lisibles sur la capsule bleu nuit
	local COULEURS = {
		info = Style.couleurs.revenu,
		succes = Style.couleurs.argent,
		alerte = Style.boutons.rouge[1],
		vol = Style.boutons.rouge[1],
	}
	local ordreToast = 0
	local toasts = {}

	local function retirer(t)
		for i = #toasts, 1, -1 do
			if toasts[i] == t then
				table.remove(toasts, i)
			end
		end
		if t.Parent then
			t:Destroy()
		end
	end

	-- sépare un emoji de tête (« 💰 +$5K ») du reste du texte : il passe dans la pastille
	local function separerIcone(texte)
		local premier = string.byte(texte, 1) or 0
		if premier < 226 then return nil, texte end
		local espace = string.find(texte, " ", 1, true)
		if not espace or espace > 16 then return nil, texte end
		local reste = string.sub(texte, espace + 1)
		if reste == "" then return nil, texte end
		return string.sub(texte, 1, espace - 1), reste
	end

	-- largeur réelle du texte (TextService), estimation en secours
	local function largeurTexte(texte, taille)
		local ok, dim = pcall(function()
			return TextService:GetTextSize(texte, taille, Style.policeTitre, Vector2.new(4000, 200))
		end)
		if ok and typeof(dim) == "Vector2" and dim.X > 0 then
			return dim.X
		end
		local n = (utf8 and utf8.len(texte)) or #texte
		return n * taille * 0.62
	end

	-- vrai si un de mes dinos est en train d'être volé (Interface/Vol affiche alors l'alerte géante)
	local function volEnCours()
		local id = joueur.UserId
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:GetAttribute("Proprietaire") == id then
				local voleur = dino:GetAttribute("Voleur")
				if type(voleur) == "number" and voleur ~= 0 and voleur ~= id then
					return true
				end
			end
		end
		return false
	end

	local function toast(texte, genre)
		if type(texte) ~= "string" or texte == "" then return end
		if type(genre) ~= "string" or not COULEURS[genre] then
			genre = "info"
		end
		if genre == "vol" then
			-- pas de doublon : « ON TE VOLE ! » et la plaque du voleur (Interface/Vol) suffisent ;
			-- le son reste joué par Interface/Sons. Un vol déjà terminé s'annonce en simple alerte.
			local ok, enCours = pcall(volEnCours)
			if not ok or enCours then return end
			genre = "alerte"
		end
		local couleur = COULEURS[genre]
		local defGenre = GENRES[genre] or GENRES.info
		local iconeTete, corps = separerIcone(texte)
		local icone = iconeTete or defGenre.icone
		ordreToast = ordreToast + 1

		while #toasts >= TOASTS_MAX do
			retirer(toasts[1])
		end

		local t = Instance.new("Frame")
		t.Name = "Toast"
		t.LayoutOrder = ordreToast
		t.BackgroundTransparency = 1
		t.Size = UDim2.new(1, 0, 0, HAUTEUR_TOAST)
		t.Parent = pile
		table.insert(toasts, t)

		-- capsule bleu nuit (comme les panneaux), cernée de noir, largeur mesurée sur le texte
		local MARGE_GAUCHE, MARGE_DROITE = 52, 20
		local largeur = math.clamp(math.ceil(largeurTexte(corps, TAILLE_TEXTE_TOAST)) + MARGE_GAUCHE + MARGE_DROITE, 200, 640)
		local plaque = Instance.new("Frame")
		plaque.Name = "Plaque"
		plaque.AnchorPoint = Vector2.new(0.5, 0.5)
		plaque.Position = UDim2.fromScale(0.5, 0.5)
		plaque.Size = UDim2.new(0, largeur, 1, 0)
		plaque.BackgroundColor3 = Color3.new(1, 1, 1)
		plaque.BackgroundTransparency = 1
		plaque.BorderSizePixel = 0
		plaque.ZIndex = 1
		Style.coins(plaque, 23)
		local bordPlaque = Style.bordure(plaque, 3)
		Style.degrade(plaque, Style.couleurs.fondHaut, Style.couleurs.fond).Name = "Fond"
		plaque.Parent = t

		-- petite pastille ronde colorée avec l'icône du genre, calée dans l'arrondi gauche
		local palette = Style.boutons[defGenre.pastille] or Style.boutons.jaune
		local pastille = Instance.new("Frame")
		pastille.Name = "Pastille"
		pastille.AnchorPoint = Vector2.new(0, 0.5)
		pastille.Position = UDim2.new(0, 7, 0.5, 0)
		pastille.Size = UDim2.fromOffset(34, 34)
		pastille.BackgroundColor3 = Color3.new(1, 1, 1)
		pastille.BorderSizePixel = 0
		pastille.ZIndex = 2
		Style.coins(pastille, 17)
		local bordPastille = Style.bordure(pastille, 2.5)
		Style.degrade(pastille, palette[1], palette[2]).Name = "Fond"
		pastille.Parent = plaque
		local emoji = Style.texte(pastille, {
			Name = "Icone",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.78, 0.78),
			Text = icone,
			contour = 1.5,
			tailleMax = 24,
			ZIndex = 3,
		})

		local etiquette = Style.texte(plaque, {
			Name = "Texte",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, MARGE_GAUCHE, 0.5, 0),
			Size = UDim2.new(1, -(MARGE_GAUCHE + MARGE_DROITE - 6), 0, 32),
			TextColor3 = couleur,
			Text = corps,
			titre = true,
			contour = 3,
			tailleMax = TAILLE_TEXTE_TOAST,
			ZIndex = 3,
		})
		local contourTexte = etiquette:FindFirstChild("Contour")
		Style.pop(plaque, 1.12)
		animer(plaque, 0.18, { BackgroundTransparency = 0.15 })

		-- sortie : tout monte un peu et se fond
		task.delay(DUREE_TOAST, function()
			if not t.Parent then return end
			local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			pcall(function()
				TweenService:Create(plaque, info, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -10) }):Play()
				TweenService:Create(bordPlaque, info, { Transparency = 1 }):Play()
				TweenService:Create(pastille, info, { BackgroundTransparency = 1 }):Play()
				TweenService:Create(bordPastille, info, { Transparency = 1 }):Play()
				TweenService:Create(emoji, info, { TextTransparency = 1 }):Play()
				TweenService:Create(etiquette, info, { TextTransparency = 1 }):Play()
				local contourEmoji = emoji:FindFirstChild("Contour")
				if contourEmoji then
					TweenService:Create(contourEmoji, info, { Transparency = 1 }):Play()
				end
				if contourTexte then
					TweenService:Create(contourTexte, info, { Transparency = 1 }):Play()
				end
			end)
			task.wait(0.4)
			retirer(t)
		end)
	end

	if Reseau.Notification then
		Reseau.Notification.OnClientEvent:Connect(function(texte, genre)
			pcall(toast, texte, genre)
		end)
	end

	-- ===== mise en page selon l'écran (mobile : plus petit, argent en haut hors du joystick) =====
	local function disposer()
		local camera = workspace.CurrentCamera
		local taille = Vector2.new(1280, 720)
		if camera then taille = camera.ViewportSize end
		local f = math.clamp(math.min(taille.Y / 760, taille.X / 1100), 0.6, 1)
		for _, e in ipairs(groupes) do
			e.Scale = f
		end
		local tactile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		if tactile then
			-- le joystick occupe le bas à gauche : argent en haut à gauche, menu juste dessous
			blocArgent.AnchorPoint = Vector2.new(0, 0)
			blocArgent.Position = UDim2.new(0, 12, 0, 56)
			colonne.AnchorPoint = Vector2.new(0, 0)
			local haut = 56 + math.floor(124 * f)
			colonne.Position = UDim2.new(0, 12, 0, haut)
			-- cible tactile ≥ 64 px quand l'écran le permet (le menu ne descend pas sous le bas de l'écran)
			local adapte = colonne:FindFirstChild("Adapte")
			if adapte then
				local fMenu = math.max(f, 64 / TAILLE_MENU)
				if haut + hauteurMenu * fMenu > taille.Y - 8 then
					fMenu = math.max(f, (taille.Y - 8 - haut) / hauteurMenu)
				end
				adapte.Scale = fMenu
			end
		else
			blocArgent.AnchorPoint = Vector2.new(0, 1)
			blocArgent.Position = UDim2.new(0, 16, 1, -16)
			colonne.AnchorPoint = Vector2.new(0, 0.5)
			colonne.Position = UDim2.new(0, 16, 0.5, 0)
		end
	end
	pcall(disposer)
	pcall(function()
		local camera = workspace.CurrentCamera
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				pcall(disposer)
			end)
		end
	end)
end

return M
