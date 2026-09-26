-- Interface HUD : argent et revenu, menu de gauche, bouton de collecte, bandeau d'événement et notifications.
-- Look « simulateur Roblox » (voir STYLE.md §2) : tout passe par ctx.Style.
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local DUREE_TOAST = 3
local TOASTS_MAX = 5
local PERIODE_BASE = 0.3
local HAUTEUR_TOAST = 46
local TAILLE_MENU = 80
local ECART_MENU = 14

-- icône et couleur (clé de Style.boutons) du ruban pour chaque événement connu
local EVENEMENTS = {
	PluieDeMeteores = { icone = "☄️", couleur = "orange" },
	Eruption = { icone = "🌋", couleur = "rouge" },
	LuneDoree = { icone = "🌕", couleur = "jaune" },
}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Style = ctx.Style or require(game:GetService("ReplicatedStorage").Dino.Style)
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local Equilibrage = ctx.Equilibrage
	local hex = Charte.hex

	local ROUGE = hex("FF3B3B")
	local BLANC = Style.couleurs.texte

	local ecran = Instance.new("Frame")
	ecran.Name = "HUD"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundTransparency = 1
	ecran.Parent = ctx.gui

	local function son(nom)
		Bus.emettre("Son", nom)
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
	})

	local texteRevenu = Style.texte(blocArgent, {
		Name = "Revenu",
		Position = UDim2.fromOffset(4, 76),
		Size = UDim2.new(1, -4, 0, 36),
		TextColor3 = Style.couleurs.revenu,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "+" .. Style.revenu(0),
		contour = 3,
		tailleMax = 34,
	})

	local cible = tonumber(joueur:GetAttribute("Argent")) or 0
	local affiche = cible
	local dernierTexte = ""
	texteArgent.Text = Charte.argent(affiche)

	local dernierPop = 0
	local function rebondir()
		local maintenant = os.clock()
		if maintenant - dernierPop < 0.2 then return end
		dernierPop = maintenant
		Style.pop(texteArgent, 1.18)
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
			ZIndex = 3,
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
		cible = n
	end)

	-- défilement doux du compteur vers la valeur réelle
	RunService.Heartbeat:Connect(function(dt)
		if affiche ~= cible then
			local ecart = cible - affiche
			local pas = ecart * math.min(1, dt * 10)
			if math.abs(ecart) < 1 or math.abs(pas) < 0.5 then
				affiche = cible
			else
				affiche = affiche + pas
			end
		end
		local t = Charte.argent(affiche)
		if t ~= dernierTexte then
			dernierTexte = t
			texteArgent.Text = t
		end
	end)

	local function majRevenu()
		local r = tonumber(joueur:GetAttribute("RevenuParSeconde")) or 0
		texteRevenu.Text = "+" .. Style.revenu(r)
	end
	joueur:GetAttributeChangedSignal("RevenuParSeconde"):Connect(majRevenu)
	majRevenu()

	-- ===== bandeau d'événement (ruban en haut au centre) =====
	local zoneEvenement = groupe("Evenement", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(440, 74),
		Visible = false,
	})
	local ruban = Instance.new("Frame")
	ruban.Name = "Ruban"
	ruban.Size = UDim2.fromScale(1, 1)
	ruban.BackgroundColor3 = Color3.new(1, 1, 1)
	ruban.BorderSizePixel = 0
	Style.coins(ruban, 18)
	local bordRuban = Style.bordure(ruban, 4)
	local degradeRuban = Style.degrade(ruban, Style.boutons.violet[1], Style.boutons.violet[2])
	ruban.Parent = zoneEvenement

	local texteBandeau = Style.texte(ruban, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.new(1, -24, 0, 40),
		Text = "",
		titre = true,
		contour = 3.5,
		tailleMax = 36,
	})
	local texteCompte = Style.texte(ruban, {
		Name = "Compte",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -4),
		Size = UDim2.new(1, -24, 0, 26),
		TextColor3 = Style.couleurs.revenu,
		Text = "",
		contour = 3,
		tailleMax = 26,
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
			texteBandeau.Text = def.icone .. " " .. string.upper(nomEvenement(cle)) .. " " .. def.icone
			zoneEvenement.Visible = true
			Style.pop(ruban, 1.15)
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
				-- la bordure du ruban clignote noir / jaune pour attirer l'œil
				if phase % 2 == 0 then
					bordRuban.Color = Style.couleurs.contour
				else
					bordRuban.Color = Style.couleurs.revenu
				end
			end
			task.wait(0.5)
		end
	end)

	-- ===== menu de gauche : gros boutons carrés =====
	local BOUTONS = {
		{ icone = "🛒", nom = "Boutique", panneau = "Boutique", couleur = "orange" },
		{ icone = "♻️", nom = "Renaissance", panneau = "Renaissance", couleur = "violet" },
		{ icone = "📖", nom = "Dinodex", panneau = "Index", couleur = "bleu" },
	}
	local hauteurMenu = #BOUTONS * TAILLE_MENU + (#BOUTONS - 1) * ECART_MENU
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
		local b, icone = Style.bouton(colonne, {
			Name = def.panneau,
			LayoutOrder = i,
			Size = UDim2.fromOffset(TAILLE_MENU, TAILLE_MENU),
			couleur = def.couleur,
			icone = def.icone,
			rayon = 18,
			tailleMax = 46,
		}, function()
			son("clic")
			Bus.emettre("OuvrirPanneau", def.panneau)
		end)
		-- emoji géant en haut, petit libellé cerné en bas
		icone.Size = UDim2.new(1, -12, 0.62, 0)
		icone.Position = UDim2.new(0.5, 0, 0.38, 0)
		Style.texte(b, {
			Name = "Nom",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -4),
			Size = UDim2.new(1, 0, 0, 22),
			Text = def.nom,
			contour = 2.5,
			tailleMax = 18,
			ZIndex = 3,
		})
	end

	-- ===== bouton Collecter (visible dans sa Base) =====
	local zoneCollecte = groupe("ZoneCollecte", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -100),
		Size = UDim2.fromOffset(320, 78),
		Visible = false,
	})
	local derniereCollecte = 0
	local boutonCollecte, libelleCollecte = Style.bouton(zoneCollecte, {
		Name = "Collecter",
		Size = UDim2.fromScale(1, 1),
		couleur = "vert",
		texte = "COLLECTER",
		icone = "💰",
		rayon = 22,
		tailleMax = 40,
	}, function()
		local maintenant = os.clock()
		if maintenant - derniereCollecte < 0.5 then return end
		derniereCollecte = maintenant
		son("clic")
		pcall(function() Reseau.Collecter:FireServer() end)
	end)
	libelleCollecte.Font = Style.policeTitre
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
					libelleCollecte.Text = "💰 COLLECTER " .. Charte.argent(stock)
					couleur = "vert"
				else
					libelleCollecte.Text = "💰 COLLECTER"
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

	-- ===== notifications (gros textes cernés au milieu-haut) =====
	local pile = groupe("Toasts", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 270), -- sous la barre de verrou (144..190) et le bandeau de vol (198..262)
		Size = UDim2.fromOffset(640, TOASTS_MAX * (HAUTEUR_TOAST + 4)),
	})
	local dispoPile = Instance.new("UIListLayout")
	dispoPile.FillDirection = Enum.FillDirection.Vertical
	dispoPile.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dispoPile.Padding = UDim.new(0, 4)
	dispoPile.SortOrder = Enum.SortOrder.LayoutOrder
	dispoPile.Parent = pile

	local COULEURS = {
		info = Style.couleurs.revenu,
		succes = Style.couleurs.argent,
		alerte = ROUGE,
		vol = ROUGE,
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

	local function toast(texte, genre)
		if type(texte) ~= "string" or texte == "" then return end
		if type(genre) ~= "string" or not COULEURS[genre] then
			genre = "info"
		end
		local couleur = COULEURS[genre]
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

		local etiquette = Style.texte(t, {
			Name = "Texte",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			TextColor3 = couleur,
			Text = texte,
			titre = true,
			contour = 3.5,
			tailleMax = 40,
		})
		local contourTexte = etiquette:FindFirstChild("Contour")
		Style.pop(etiquette, 1.22)

		-- un vol clignote rouge / blanc pendant toute sa durée
		if genre == "vol" then
			task.spawn(function()
				local allume = true
				while t.Parent do
					if allume then
						etiquette.TextColor3 = BLANC
						if contourTexte then contourTexte.Color = ROUGE end
					else
						etiquette.TextColor3 = ROUGE
						if contourTexte then contourTexte.Color = Style.couleurs.contour end
					end
					allume = not allume
					task.wait(0.25)
				end
			end)
		end

		task.delay(DUREE_TOAST, function()
			if not t.Parent then return end
			local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			pcall(function()
				TweenService:Create(etiquette, info, { TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -14) }):Play()
				if contourTexte then
					TweenService:Create(contourTexte, info, { Transparency = 1 }):Play()
				end
			end)
			task.wait(0.35)
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
			colonne.Position = UDim2.new(0, 12, 0, 56 + math.floor(124 * f))
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
