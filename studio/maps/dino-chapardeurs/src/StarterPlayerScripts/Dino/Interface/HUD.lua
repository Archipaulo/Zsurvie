-- Interface HUD : argent et revenu, boutons des panneaux, bouton de collecte, bandeau d'événement et toasts.
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local M = {}

local DUREE_TOAST = 3
local TOASTS_MAX = 5
local PERIODE_BASE = 0.3

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local Equilibrage = ctx.Equilibrage

	local ecran = Instance.new("Frame")
	ecran.Name = "HUD"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundTransparency = 1
	ecran.Parent = ctx.gui

	local function son(nom)
		Bus.emettre("Son", nom)
	end

	-- ===== argent (en haut au centre) =====
	local blocArgent = Outils.cadre(ecran, {
		Name = "Argent",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.new(0, 300, 0, 78),
		BackgroundTransparency = 0.25,
	})
	local contour = Instance.new("UIStroke")
	contour.Color = Charte.dore
	contour.Thickness = 2
	contour.Transparency = 0.3
	contour.Parent = blocArgent
	local echelle = Instance.new("UIScale")
	echelle.Parent = blocArgent

	local texteArgent = Outils.etiquette(blocArgent, {
		Name = "Montant",
		Position = UDim2.new(0, 10, 0, 4),
		Size = UDim2.new(1, -20, 0, 46),
		Font = Charte.police,
		TextColor3 = Charte.dore,
		Text = Charte.argent(0),
	})
	local ombreArgent = Instance.new("UIStroke")
	ombreArgent.Color = Charte.ombre(Charte.bois)
	ombreArgent.Thickness = 2
	ombreArgent.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	ombreArgent.Parent = texteArgent

	local texteRevenu = Outils.etiquette(blocArgent, {
		Name = "Revenu",
		Position = UDim2.new(0, 10, 0, 50),
		Size = UDim2.new(1, -20, 0, 22),
		Font = Charte.policeTexte,
		TextColor3 = Charte.creme,
		Text = "+" .. Charte.argent(0) .. "/s",
	})

	local cible = tonumber(joueur:GetAttribute("Argent")) or 0
	local affiche = cible
	local dernierTexte = ""
	texteArgent.Text = Charte.argent(affiche)

	local rebondEnCours = nil
	local function rebondir()
		if rebondEnCours then
			pcall(function() rebondEnCours:Cancel() end)
		end
		echelle.Scale = 1.18
		rebondEnCours = TweenService:Create(echelle, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		rebondEnCours:Play()
	end

	joueur:GetAttributeChangedSignal("Argent"):Connect(function()
		local n = tonumber(joueur:GetAttribute("Argent")) or 0
		if n > cible then
			rebondir()
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
		texteRevenu.Text = "+" .. Charte.argent(r) .. "/s"
	end
	joueur:GetAttributeChangedSignal("RevenuParSeconde"):Connect(majRevenu)
	majRevenu()

	-- ===== bandeau d'événement (sous l'argent) =====
	local bandeau = Outils.cadre(ecran, {
		Name = "Evenement",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 96),
		Size = UDim2.new(0, 340, 0, 40),
		BackgroundColor3 = Charte.violet,
		BackgroundTransparency = 0.1,
		Visible = false,
	})
	local contourBandeau = Instance.new("UIStroke")
	contourBandeau.Color = Charte.dore
	contourBandeau.Thickness = 2
	contourBandeau.Parent = bandeau
	local texteBandeau = Outils.etiquette(bandeau, {
		Name = "Texte",
		Position = UDim2.new(0, 10, 0, 4),
		Size = UDim2.new(1, -20, 1, -8),
		Font = Charte.police,
		TextColor3 = Charte.creme,
		Text = "",
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

	local function majBandeau()
		local cle = Etat:GetAttribute("Evenement")
		if type(cle) ~= "string" or cle == "" then
			bandeau.Visible = false
			return
		end
		local fin = tonumber(Etat:GetAttribute("EvenementFin")) or 0
		local reste = fin - workspace:GetServerTimeNow()
		bandeau.Visible = true
		texteBandeau.Text = "🌋 " .. nomEvenement(cle) .. " — " .. formatDuree(reste)
	end

	task.spawn(function()
		local phase = 0
		while ecran.Parent do
			local ok = pcall(majBandeau)
			if ok and bandeau.Visible then
				phase = phase + 1
				if phase % 2 == 0 then
					contourBandeau.Transparency = 0
				else
					contourBandeau.Transparency = 0.6
				end
			end
			task.wait(0.5)
		end
	end)

	-- ===== boutons de gauche =====
	local colonne = Instance.new("Frame")
	colonne.Name = "Boutons"
	colonne.AnchorPoint = Vector2.new(0, 0.5)
	colonne.Position = UDim2.new(0, 12, 0.5, 0)
	colonne.Size = UDim2.new(0, 170, 0, 3 * 52 + 2 * 10)
	colonne.BackgroundTransparency = 1
	colonne.Parent = ecran
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Vertical
	disposition.Padding = UDim.new(0, 10)
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Parent = colonne

	local BOUTONS = {
		{ texte = "🛒 Boutique", panneau = "Boutique", couleur = Charte.jungle },
		{ texte = "♻️ Renaissance", panneau = "Renaissance", couleur = Charte.violet },
		{ texte = "📖 Dinodex", panneau = "Index", couleur = Charte.gemme },
	}
	for i, def in ipairs(BOUTONS) do
		local b = Outils.bouton(colonne, {
			Name = def.panneau,
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundColor3 = def.couleur,
			Font = Charte.police,
			TextColor3 = Charte.creme,
			Text = def.texte,
		}, function()
			son("clic")
			Bus.emettre("OuvrirPanneau", def.panneau)
		end)
		local marge = Instance.new("UIPadding")
		marge.PaddingLeft = UDim.new(0, 8)
		marge.PaddingRight = UDim.new(0, 8)
		marge.PaddingTop = UDim.new(0, 8)
		marge.PaddingBottom = UDim.new(0, 8)
		marge.Parent = b
		local bord = Instance.new("UIStroke")
		bord.Color = Charte.ombre(def.couleur)
		bord.Thickness = 2
		bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bord.Parent = b
	end

	-- ===== bouton Collecter (visible dans sa Base) =====
	local boutonCollecte
	local derniereCollecte = 0
	boutonCollecte = Outils.bouton(ecran, {
		Name = "Collecter",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -110),
		Size = UDim2.new(0, 260, 0, 60),
		BackgroundColor3 = Charte.dore,
		Font = Charte.police,
		TextColor3 = Charte.encre,
		Text = "💰 Collecter",
		Visible = false,
	}, function()
		local maintenant = os.clock()
		if maintenant - derniereCollecte < 0.5 then return end
		derniereCollecte = maintenant
		son("clic")
		pcall(function() Reseau.Collecter:FireServer() end)
	end)
	local margeCollecte = Instance.new("UIPadding")
	margeCollecte.PaddingTop = UDim.new(0, 10)
	margeCollecte.PaddingBottom = UDim.new(0, 10)
	margeCollecte.PaddingLeft = UDim.new(0, 12)
	margeCollecte.PaddingRight = UDim.new(0, 12)
	margeCollecte.Parent = boutonCollecte
	local bordCollecte = Instance.new("UIStroke")
	bordCollecte.Color = Charte.ombre(Charte.dore)
	bordCollecte.Thickness = 3
	bordCollecte.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bordCollecte.Parent = boutonCollecte

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
				if ok2 and stock >= 1 then
					boutonCollecte.Text = "💰 Collecter " .. Charte.argent(stock)
				else
					boutonCollecte.Text = "💰 Collecter"
				end
			end
			if visible ~= visiblePrec then
				visiblePrec = visible
				boutonCollecte.Visible = visible
				if visible then
					local e = boutonCollecte:FindFirstChildOfClass("UIScale")
					if not e then
						e = Instance.new("UIScale")
						e.Parent = boutonCollecte
					end
					e.Scale = 0.6
					TweenService:Create(e, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
				end
			end
			task.wait(PERIODE_BASE)
		end
	end)

	-- ===== toasts (notifications du serveur) =====
	local pile = Instance.new("Frame")
	pile.Name = "Toasts"
	pile.AnchorPoint = Vector2.new(0.5, 0)
	pile.Position = UDim2.new(0.5, 0, 0, 146)
	pile.Size = UDim2.new(0, 420, 0, TOASTS_MAX * 50)
	pile.BackgroundTransparency = 1
	pile.Parent = ecran
	local dispoPile = Instance.new("UIListLayout")
	dispoPile.FillDirection = Enum.FillDirection.Vertical
	dispoPile.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dispoPile.Padding = UDim.new(0, 6)
	dispoPile.SortOrder = Enum.SortOrder.LayoutOrder
	dispoPile.Parent = pile

	local COULEURS = {
		info = Charte.gemme,
		succes = Charte.herbe,
		alerte = Charte.lave,
		vol = Charte.alerte,
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

		local t = Outils.cadre(pile, {
			Name = "Toast",
			LayoutOrder = ordreToast,
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Charte.encre,
			BackgroundTransparency = 0.1,
		})
		table.insert(toasts, t)
		local bord = Instance.new("UIStroke")
		bord.Color = couleur
		bord.Thickness = 2
		bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bord.Parent = t
		local pastille = Outils.cadre(t, {
			Name = "Pastille",
			Position = UDim2.new(0, 6, 0, 6),
			Size = UDim2.new(0, 8, 1, -12),
			BackgroundColor3 = couleur,
			BackgroundTransparency = 0,
		})
		local etiquette = Outils.etiquette(t, {
			Name = "Texte",
			Position = UDim2.new(0, 22, 0, 6),
			Size = UDim2.new(1, -32, 1, -12),
			Font = Charte.policeTexte,
			TextColor3 = couleur,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = texte,
		})
		local echelleToast = Instance.new("UIScale")
		echelleToast.Scale = 0.7
		echelleToast.Parent = t
		TweenService:Create(echelleToast, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

		-- un vol clignote en rouge pendant toute sa durée
		if genre == "vol" then
			task.spawn(function()
				local allume = true
				while t.Parent do
					if allume then
						t.BackgroundColor3 = Charte.alerte
						etiquette.TextColor3 = Charte.creme
						pastille.BackgroundColor3 = Charte.creme
					else
						t.BackgroundColor3 = Charte.encre
						etiquette.TextColor3 = Charte.alerte
						pastille.BackgroundColor3 = Charte.alerte
					end
					allume = not allume
					task.wait(0.25)
				end
			end)
		end

		task.delay(DUREE_TOAST, function()
			if not t.Parent then return end
			local info = TweenInfo.new(0.3)
			pcall(function()
				TweenService:Create(t, info, { BackgroundTransparency = 1 }):Play()
				TweenService:Create(etiquette, info, { TextTransparency = 1 }):Play()
				TweenService:Create(pastille, info, { BackgroundTransparency = 1 }):Play()
				TweenService:Create(bord, info, { Transparency = 1 }):Play()
			end)
			task.wait(0.3)
			retirer(t)
		end)
	end

	if Reseau.Notification then
		Reseau.Notification.OnClientEvent:Connect(function(texte, genre)
			pcall(toast, texte, genre)
		end)
	end
end

return M
