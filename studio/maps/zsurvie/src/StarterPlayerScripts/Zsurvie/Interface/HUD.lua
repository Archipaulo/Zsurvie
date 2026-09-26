-- Interface/HUD : barre du haut (jour, phase, minuteur, PV de la Maison, Zbires),
-- compteurs de pièces et gemmes, boutons Réparer / Établi, pings et notifications.
local M = {}

local NOMS_PHASE = {
	Lobby = "Lobby",
	Horde = "Horde",
	Repit = "Répit",
	Defaite = "Défaite",
}

local PINGS = { "Aide !", "Ici !", "Colosse !", "Merci !" }

local DUREE_TOAST = 3
local TOASTS_MAX = 5

local function formaterTemps(secondes)
	local s = math.max(0, math.floor(tonumber(secondes) or 0))
	local minutes = math.floor(s / 60)
	local reste = s % 60
	return string.format("%d:%02d", minutes, reste)
end

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Equilibrage = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local gui = ctx.gui

	local okTween, TweenService = pcall(function() return game:GetService("TweenService") end)
	if not okTween then TweenService = nil end
	local okUis, UserInputService = pcall(function() return game:GetService("UserInputService") end)
	if not okUis then UserInputService = nil end

	local function tween(inst, duree, props, style)
		if not TweenService then
			for cle, valeur in pairs(props) do
				inst[cle] = valeur
			end
			return nil
		end
		local info = TweenInfo.new(duree, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local t = TweenService:Create(inst, info, props)
		t:Play()
		return t
	end

	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function lireEtat(nom, defaut)
		if not Etat then return defaut end
		local v = Etat:GetAttribute(nom)
		if v == nil then return defaut end
		return v
	end

	local racineHud = Instance.new("Frame")
	racineHud.Name = "HUD"
	racineHud.Size = UDim2.fromScale(1, 1)
	racineHud.BackgroundTransparency = 1
	racineHud.Parent = gui

	-- ===== barre du haut =====
	local barre = Outils.cadre(racineHud, {
		Name = "BarreHaut",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.new(0, 460, 0, 70),
	})
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MaxSize = Vector2.new(460, 70)
	contrainte.Parent = barre
	barre.Size = UDim2.new(0.9, 0, 0, 70)

	local etiquetteJour = Outils.etiquette(barre, {
		Name = "Jour",
		Position = UDim2.new(0, 12, 0, 6),
		Size = UDim2.new(0.3, -12, 0, 30),
		Text = "Jour 0",
		TextColor3 = Charte.dore,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local etiquettePhase = Outils.etiquette(barre, {
		Name = "Phase",
		Position = UDim2.new(0.3, 0, 0, 6),
		Size = UDim2.new(0.4, 0, 0, 30),
		Text = "Lobby",
	})

	local etiquetteZbires = Outils.etiquette(barre, {
		Name = "Zbires",
		Position = UDim2.new(0.7, 0, 0, 6),
		Size = UDim2.new(0.3, -12, 0, 30),
		Text = "Zbires : 0",
		TextColor3 = Charte.lumiere(Charte.violet),
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local fondPv = Outils.cadre(barre, {
		Name = "FondPV",
		Position = UDim2.new(0, 12, 0, 42),
		Size = UDim2.new(1, -24, 0, 20),
		BackgroundColor3 = Charte.ardoise,
		BackgroundTransparency = 0,
		ClipsDescendants = true,
	})
	local remplissagePv = Outils.cadre(fondPv, {
		Name = "Remplissage",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Charte.prairie,
		BackgroundTransparency = 0,
	})
	local textePv = Outils.etiquette(fondPv, {
		Name = "Texte",
		Size = UDim2.fromScale(1, 1),
		Font = Charte.policeTexte,
		Text = "Maison",
		TextColor3 = Charte.creme,
		ZIndex = 3,
	})
	local contourPv = Instance.new("UIStroke")
	contourPv.Color = Charte.encre
	contourPv.Thickness = 2
	contourPv.Parent = textePv

	-- ===== bandeau Colosse =====
	local bandeauColosse = Outils.cadre(racineHud, {
		Name = "BandeauColosse",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 88),
		Size = UDim2.new(0, 280, 0, 40),
		BackgroundColor3 = Charte.alerte,
		BackgroundTransparency = 0.05,
		Visible = false,
	})
	Outils.etiquette(bandeauColosse, {
		Name = "Texte",
		Position = UDim2.new(0, 8, 0, 4),
		Size = UDim2.new(1, -16, 1, -8),
		Text = "⚠ COLOSSE !",
		TextColor3 = Charte.creme,
	})
	local echelleColosse = Instance.new("UIScale")
	echelleColosse.Parent = bandeauColosse

	-- ===== bandeau du lobby =====
	local bandeauLobby = Outils.cadre(racineHud, {
		Name = "BandeauLobby",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 88),
		Size = UDim2.new(0.9, 0, 0, 36),
		BackgroundColor3 = Charte.nuitLabo,
		BackgroundTransparency = 0.1,
		Visible = false,
	})
	local contrainteLobby = Instance.new("UISizeConstraint")
	contrainteLobby.MaxSize = Vector2.new(560, 36)
	contrainteLobby.Parent = bandeauLobby
	Outils.etiquette(bandeauLobby, {
		Name = "Texte",
		Position = UDim2.new(0, 10, 0, 4),
		Size = UDim2.new(1, -20, 1, -8),
		Font = Charte.policeTexte,
		Text = "Laboratoire — explore l'île et monte dans une capsule 🚀",
		TextColor3 = Charte.creme,
	})

	-- ===== compteurs à gauche =====
	local colonne = Instance.new("Frame")
	colonne.Name = "Compteurs"
	colonne.BackgroundTransparency = 1
	colonne.Position = UDim2.new(0, 12, 0, 96)
	colonne.Size = UDim2.new(0, 150, 0, 100)
	colonne.Parent = racineHud
	local listeCompteurs = Instance.new("UIListLayout")
	listeCompteurs.Padding = UDim.new(0, 8)
	listeCompteurs.SortOrder = Enum.SortOrder.LayoutOrder
	listeCompteurs.Parent = colonne

	local function creerCompteur(nom, icone, couleur, ordre)
		local cadre = Outils.cadre(colonne, {
			Name = nom,
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = ordre,
		})
		local echelle = Instance.new("UIScale")
		echelle.Parent = cadre
		local contour = Instance.new("UIStroke")
		contour.Color = couleur
		contour.Thickness = 2
		contour.Parent = cadre
		local texte = Outils.etiquette(cadre, {
			Name = "Texte",
			Position = UDim2.new(0, 10, 0, 5),
			Size = UDim2.new(1, -20, 1, -10),
			Text = icone .. " 0",
			TextColor3 = couleur,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		return { texte = texte, echelle = echelle, icone = icone, valeur = nil }
	end

	local compteurPieces = creerCompteur("Pieces", "🪙", Charte.dore, 1)
	local compteurGemmes = creerCompteur("Gemmes", "💎", Charte.gemme, 2)

	local function rebond(compteur)
		local echelle = compteur.echelle
		echelle.Scale = 1.25
		tween(echelle, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	end

	local function majCompteur(compteur, attribut)
		local v = tonumber(joueur:GetAttribute(attribut)) or 0
		compteur.texte.Text = compteur.icone .. " " .. tostring(math.floor(v))
		if compteur.valeur ~= nil and v > compteur.valeur then
			rebond(compteur)
		end
		compteur.valeur = v
	end

	majCompteur(compteurPieces, "Pieces")
	majCompteur(compteurGemmes, "Gemmes")
	joueur:GetAttributeChangedSignal("Pieces"):Connect(function()
		majCompteur(compteurPieces, "Pieces")
	end)
	joueur:GetAttributeChangedSignal("Gemmes"):Connect(function()
		majCompteur(compteurGemmes, "Gemmes")
	end)

	-- ===== boutons d'action (en run seulement) =====
	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.BackgroundTransparency = 1
	actions.Position = UDim2.new(0, 12, 0, 206)
	actions.Size = UDim2.new(0, 150, 0, 100)
	actions.Visible = false
	actions.Parent = racineHud
	local listeActions = Instance.new("UIListLayout")
	listeActions.Padding = UDim.new(0, 8)
	listeActions.SortOrder = Enum.SortOrder.LayoutOrder
	listeActions.Parent = actions

	local delaiReparation = 0.4
	if Equilibrage and Equilibrage.maison and tonumber(Equilibrage.maison.delaiReparation) then
		delaiReparation = tonumber(Equilibrage.maison.delaiReparation)
	end
	local derniereReparation = 0

	local function enRun()
		return joueur:GetAttribute("EnRun") == true
	end

	local function reparer()
		if not enRun() then return end
		local maintenant = os.clock()
		if maintenant - derniereReparation < delaiReparation then return end
		derniereReparation = maintenant
		local ev = Reseau.Reparer
		if ev then
			ev:FireServer()
			son("clic")
		end
	end

	local boutonReparer = Outils.bouton(actions, {
		Name = "Reparer",
		Size = UDim2.new(1, 0, 0, 42),
		LayoutOrder = 1,
		Text = "🔧 Réparer (R)",
		BackgroundColor3 = Charte.prairie,
	}, reparer)
	local contourReparer = Instance.new("UIStroke")
	contourReparer.Color = Charte.encre
	contourReparer.Thickness = 2
	contourReparer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contourReparer.Parent = boutonReparer

	local boutonEtabli = Outils.bouton(actions, {
		Name = "Etabli",
		Size = UDim2.new(1, 0, 0, 42),
		LayoutOrder = 2,
		Text = "🛠️ Établi",
		BackgroundColor3 = Charte.toit,
	}, function()
		son("clic")
		Bus.emettre("OuvrirPanneau", "Etabli")
	end)
	local contourEtabli = Instance.new("UIStroke")
	contourEtabli.Color = Charte.encre
	contourEtabli.Thickness = 2
	contourEtabli.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contourEtabli.Parent = boutonEtabli

	if UserInputService then
		UserInputService.InputBegan:Connect(function(entree, traite)
			if traite then return end
			if entree.KeyCode == Enum.KeyCode.R then
				reparer()
			end
		end)
	end

	-- ===== pings =====
	local pings = Instance.new("Frame")
	pings.Name = "Pings"
	pings.BackgroundTransparency = 1
	pings.Position = UDim2.new(0, 12, 0, 316)
	pings.Size = UDim2.new(0, 150, 0, 68)
	pings.Parent = racineHud
	local grille = Instance.new("UIGridLayout")
	grille.CellSize = UDim2.new(0.5, -4, 0, 30)
	grille.CellPadding = UDim2.new(0, 8, 0, 8)
	grille.SortOrder = Enum.SortOrder.LayoutOrder
	grille.Parent = pings

	local dernierPing = 0
	for i, texte in ipairs(PINGS) do
		local couleur = Charte.ardoise
		if texte == "Colosse !" then couleur = Charte.alerte end
		Outils.bouton(pings, {
			Name = "Ping" .. i,
			LayoutOrder = i,
			Text = texte,
			Font = Charte.policeTexte,
			BackgroundColor3 = couleur,
		}, function()
			local maintenant = os.clock()
			if maintenant - dernierPing < 1 then return end
			dernierPing = maintenant
			local ev = Reseau.Ping
			if ev then
				ev:FireServer(texte)
				son("clic")
			end
		end)
	end

	-- ===== notifications (toasts empilés) =====
	local pile = Instance.new("Frame")
	pile.Name = "Notifications"
	pile.BackgroundTransparency = 1
	pile.AnchorPoint = Vector2.new(0.5, 0)
	pile.Position = UDim2.new(0.5, 0, 0, 134)
	pile.Size = UDim2.new(0, 340, 0, 260)
	pile.Parent = racineHud
	local listeToasts = Instance.new("UIListLayout")
	listeToasts.Padding = UDim.new(0, 6)
	listeToasts.SortOrder = Enum.SortOrder.LayoutOrder
	listeToasts.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listeToasts.Parent = pile

	local COULEURS_GENRE = {
		info = Charte.ardoise,
		succes = Charte.prairie,
		alerte = Charte.alerte,
	}

	local ordreToast = 0
	local toasts = {}

	local function retirerToast(toast)
		for i = #toasts, 1, -1 do
			if toasts[i] == toast then table.remove(toasts, i) end
		end
		if toast.Parent then toast:Destroy() end
	end

	local function afficherToast(texte, genre)
		if type(texte) ~= "string" or texte == "" then return end
		local couleur = COULEURS_GENRE[genre] or Charte.ardoise
		ordreToast = ordreToast + 1
		local toast = Outils.cadre(pile, {
			Name = "Toast",
			Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = ordreToast,
			BackgroundColor3 = couleur,
			BackgroundTransparency = 0.05,
		})
		local contour = Instance.new("UIStroke")
		contour.Color = Charte.ombre(couleur)
		contour.Thickness = 2
		contour.Parent = toast
		local etiquette = Outils.etiquette(toast, {
			Name = "Texte",
			Position = UDim2.new(0, 10, 0, 4),
			Size = UDim2.new(1, -20, 1, -8),
			Font = Charte.policeTexte,
			Text = texte,
			TextColor3 = Charte.creme,
		})
		local echelle = Instance.new("UIScale")
		echelle.Scale = 0.6
		echelle.Parent = toast
		tween(echelle, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)

		table.insert(toasts, toast)
		while #toasts > TOASTS_MAX do
			retirerToast(toasts[1])
		end

		task.delay(DUREE_TOAST, function()
			if not toast.Parent then return end
			tween(toast, 0.3, { BackgroundTransparency = 1 })
			tween(etiquette, 0.3, { TextTransparency = 1 })
			tween(contour, 0.3, { Transparency = 1 })
			task.wait(0.3)
			retirerToast(toast)
		end)
	end

	if Reseau.Notification then
		Reseau.Notification.OnClientEvent:Connect(function(texte, genre)
			if type(texte) ~= "string" then return end
			if type(genre) ~= "string" then genre = "info" end
			afficherToast(texte, genre)
		end)
	end

	-- ===== mise à jour de l'état =====
	local colosseAffiche = false
	local animationColosse = 0

	local function couleurPv(ratio)
		if ratio >= 0.5 then
			return Charte.dore:Lerp(Charte.prairie, (ratio - 0.5) * 2)
		end
		return Charte.alerte:Lerp(Charte.dore, ratio * 2)
	end

	local function majBarre()
		local phase = lireEtat("Phase", "Lobby")
		local jour = tonumber(lireEtat("Jour", 0)) or 0
		local temps = lireEtat("TempsRestant", 0)
		local nomPhase = NOMS_PHASE[phase] or tostring(phase)

		etiquetteJour.Text = "Jour " .. tostring(math.floor(jour))
		if phase == "Lobby" then
			etiquettePhase.Text = nomPhase
		else
			etiquettePhase.Text = nomPhase .. " " .. formaterTemps(temps)
		end
		if phase == "Horde" then
			etiquettePhase.TextColor3 = Charte.lumiere(Charte.violet)
		elseif phase == "Defaite" then
			etiquettePhase.TextColor3 = Charte.alerte
		else
			etiquettePhase.TextColor3 = Charte.creme
		end

		local pv = tonumber(lireEtat("PVMaison", 0)) or 0
		local pvMax = tonumber(lireEtat("PVMaisonMax", 0)) or 0
		if pvMax <= 0 and Equilibrage and Equilibrage.maison then
			pvMax = tonumber(Equilibrage.maison.pv) or 1
		end
		if pvMax <= 0 then pvMax = 1 end
		local ratio = math.clamp(pv / pvMax, 0, 1)
		tween(remplissagePv, 0.2, { Size = UDim2.fromScale(ratio, 1) })
		remplissagePv.BackgroundColor3 = couleurPv(ratio)
		textePv.Text = "🏠 " .. tostring(math.floor(pv)) .. " / " .. tostring(math.floor(pvMax))

		local zbires = tonumber(lireEtat("ZbiresRestants", 0)) or 0
		etiquetteZbires.Text = "Zbires : " .. tostring(math.floor(zbires))
	end

	local function majColosse()
		local actif = lireEtat("ColosseActif", false) == true and enRun()
		bandeauColosse.Visible = actif
		if actif and not colosseAffiche then
			son("alerte")
			animationColosse = animationColosse + 1
			local numero = animationColosse
			task.spawn(function()
				while colosseAffiche and numero == animationColosse and bandeauColosse.Parent do
					tween(echelleColosse, 0.4, { Scale = 1.08 }, Enum.EasingStyle.Sine)
					task.wait(0.4)
					tween(echelleColosse, 0.4, { Scale = 1 }, Enum.EasingStyle.Sine)
					task.wait(0.4)
				end
			end)
		end
		colosseAffiche = actif
		if not actif then echelleColosse.Scale = 1 end
	end

	local function majVisibilite()
		local dansRun = enRun()
		actions.Visible = dansRun
		bandeauLobby.Visible = not dansRun
		majColosse()
	end

	majBarre()
	majVisibilite()

	if Etat then
		local attributsBarre = { "Phase", "Jour", "TempsRestant", "PVMaison", "PVMaisonMax", "ZbiresRestants" }
		for _, nom in ipairs(attributsBarre) do
			Etat:GetAttributeChangedSignal(nom):Connect(majBarre)
		end
		Etat:GetAttributeChangedSignal("ColosseActif"):Connect(majColosse)
		Etat:GetAttributeChangedSignal("Phase"):Connect(majVisibilite)
	end
	joueur:GetAttributeChangedSignal("EnRun"):Connect(majVisibilite)
end

return M
