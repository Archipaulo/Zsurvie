-- Interface/Tutoriel : bulles d'aide en bas au centre de l'écran.
-- Chaque étape ne s'affiche qu'une fois par session ; la bulle disparaît seule ou au clic.
local M = {}

-- réglages d'affichage (propres à l'interface, pas des chiffres de jeu)
local DUREE_BULLE = 6
local SEUIL_PV_MAISON = 0.5
local DELAI_LOBBY = 3
local PAUSE_ENTRE_BULLES = 0.4

local TEXTES = {
	"Explore l'île puis monte dans une Capsule 🚀",
	"Clique sur les Zbires pour tirer !",
	"Ouvre l'Établi 🛠️ pour t'améliorer",
	"Répare la Maison : approche-toi et appuie sur R 🔧",
	"Dépense tes 💎 à l'Arbre des Recherches du Laboratoire",
	"Un Colosse ! Concentrez vos tirs !",
}

-- étapes déjà montrées (le module vit le temps de la session du joueur)
local dejaVues = {}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local gui = ctx.gui
	if not gui or not joueur then return end

	local okTween, TweenService = pcall(function() return game:GetService("TweenService") end)
	if not okTween then TweenService = nil end

	local function tween(inst, duree, props)
		if not TweenService then
			for cle, valeur in pairs(props) do
				inst[cle] = valeur
			end
			return nil
		end
		local ok, t = pcall(function()
			return TweenService:Create(inst, TweenInfo.new(duree, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
		end)
		if ok and t then
			t:Play()
			return t
		end
		for cle, valeur in pairs(props) do
			inst[cle] = valeur
		end
		return nil
	end

	local function lireEtat(nom, defaut)
		if not Etat then return defaut end
		local v = Etat:GetAttribute(nom)
		if v == nil then return defaut end
		return v
	end

	local function enRun()
		return joueur:GetAttribute("EnRun") == true
	end

	-- ===== la bulle =====
	local POS_VISIBLE = UDim2.new(0.5, 0, 1, -120)
	local POS_CACHEE = UDim2.new(0.5, 0, 1, 40)

	local bulle = Instance.new("TextButton")
	bulle.Name = "BulleTutoriel"
	bulle.AnchorPoint = Vector2.new(0.5, 1)
	bulle.Size = UDim2.new(0.6, 0, 0, 64)
	bulle.Position = POS_CACHEE
	bulle.BackgroundColor3 = Charte.encre
	bulle.BackgroundTransparency = 0.1
	bulle.BorderSizePixel = 0
	bulle.AutoButtonColor = false
	bulle.Text = ""
	bulle.Visible = false
	bulle.ZIndex = 20
	bulle.Parent = gui

	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(560, 64)
	limite.MinSize = Vector2.new(240, 48)
	limite.Parent = bulle

	local coin = Instance.new("UICorner")
	coin.CornerRadius = UDim.new(0, 16)
	coin.Parent = bulle

	local contour = Instance.new("UIStroke")
	contour.Color = Charte.toit
	contour.Thickness = 3
	contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contour.Parent = bulle

	-- pastille du numéro d'étape
	local pastille = Instance.new("Frame")
	pastille.Name = "Pastille"
	pastille.AnchorPoint = Vector2.new(0, 0.5)
	pastille.Position = UDim2.new(0, 10, 0.5, 0)
	pastille.Size = UDim2.new(0, 40, 0, 40)
	pastille.BackgroundColor3 = Charte.toit
	pastille.BorderSizePixel = 0
	pastille.ZIndex = 21
	pastille.Parent = bulle
	local coinPastille = Instance.new("UICorner")
	coinPastille.CornerRadius = UDim.new(1, 0)
	coinPastille.Parent = pastille

	local etiquetteNumero
	local etiquetteTexte
	local function etiquette(parent, props)
		if Outils and Outils.etiquette then
			return Outils.etiquette(parent, props)
		end
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Font = Charte.police
		t.TextColor3 = Charte.creme
		t.TextScaled = true
		for cle, valeur in pairs(props) do
			t[cle] = valeur
		end
		t.Parent = parent
		return t
	end

	etiquetteNumero = etiquette(pastille, {
		Name = "Numero",
		Size = UDim2.new(1, 0, 1, 0),
		Font = Charte.police,
		TextColor3 = Charte.creme,
		Text = "?",
		ZIndex = 22,
	})

	etiquetteTexte = etiquette(bulle, {
		Name = "Texte",
		Position = UDim2.new(0, 60, 0, 8),
		Size = UDim2.new(1, -96, 1, -16),
		Font = Charte.police,
		TextColor3 = Charte.creme,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = "",
		ZIndex = 22,
	})

	local croix = etiquette(bulle, {
		Name = "Fermer",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		Size = UDim2.new(0, 20, 0, 20),
		Font = Charte.policeTexte,
		TextColor3 = Charte.lumiere(Charte.ardoise),
		Text = "✕",
		ZIndex = 22,
	})
	croix.Visible = true

	-- barre de temps restant
	local barre = Instance.new("Frame")
	barre.Name = "Temps"
	barre.AnchorPoint = Vector2.new(0, 1)
	barre.Position = UDim2.new(0, 16, 1, -4)
	barre.Size = UDim2.new(1, -32, 0, 3)
	barre.BackgroundColor3 = Charte.dore
	barre.BorderSizePixel = 0
	barre.ZIndex = 22
	barre.Parent = bulle

	-- ===== file d'attente =====
	local file = {}
	local affichee = false
	local jetonBulle = 0

	-- une étape encore pertinente au moment de l'affichage ?
	local function pertinente(n)
		if n == 1 then return not enRun() end
		if n == 2 or n == 3 or n == 6 then return enRun() end
		if n == 4 then
			local max = tonumber(lireEtat("PVMaisonMax", 0)) or 0
			local pv = tonumber(lireEtat("PVMaison", 0)) or 0
			return enRun() and max > 0 and pv > 0 and pv / max < SEUIL_PV_MAISON
		end
		if n == 5 then return not enRun() end
		return true
	end

	local afficherSuivante

	local function masquer(jeton)
		if jeton ~= jetonBulle or not affichee then return end
		jetonBulle = jetonBulle + 1
		tween(bulle, 0.25, { Position = POS_CACHEE })
		task.delay(0.3, function()
			if not affichee then return end
			bulle.Visible = false
			affichee = false
			task.delay(PAUSE_ENTRE_BULLES, function()
				if not affichee then afficherSuivante() end
			end)
		end)
	end

	local function montrer(n)
		affichee = true
		jetonBulle = jetonBulle + 1
		local jeton = jetonBulle
		etiquetteNumero.Text = tostring(n)
		etiquetteTexte.Text = TEXTES[n] or ""
		local accent = Charte.toit
		if n == 4 or n == 6 then accent = Charte.alerte end
		if n == 5 then accent = Charte.gemme end
		contour.Color = accent
		pastille.BackgroundColor3 = accent
		barre.Size = UDim2.new(1, -32, 0, 3)
		bulle.Position = POS_CACHEE
		bulle.Visible = true
		tween(bulle, 0.35, { Position = POS_VISIBLE })
		if TweenService then
			pcall(function()
				local info = TweenInfo.new(DUREE_BULLE, Enum.EasingStyle.Linear)
				TweenService:Create(barre, info, { Size = UDim2.new(0, 0, 0, 3) }):Play()
			end)
		end
		Bus.emettre("Son", "clic")
		Bus.emettre("TutorielEtape", n)
		task.delay(DUREE_BULLE, function()
			masquer(jeton)
		end)
	end

	afficherSuivante = function()
		while #file > 0 and not affichee do
			local n = table.remove(file, 1)
			if pertinente(n) then
				montrer(n)
			end
		end
	end

	local function demander(n)
		if dejaVues[n] or not TEXTES[n] then return end
		dejaVues[n] = true
		-- le Colosse passe devant les autres conseils
		if n == 6 then
			table.insert(file, 1, n)
		else
			table.insert(file, n)
		end
		if not affichee then afficherSuivante() end
	end

	bulle.Activated:Connect(function()
		Bus.emettre("Son", "clic")
		masquer(jetonBulle)
	end)

	-- ===== déclencheurs =====
	local etaitEnRun = enRun()
	local piecesDebutRun = tonumber(joueur:GetAttribute("Pieces")) or 0

	local function verifierPieces()
		if not enRun() then return end
		local p = tonumber(joueur:GetAttribute("Pieces")) or 0
		if p > piecesDebutRun and p > 0 then demander(3) end
	end

	local function verifierMaison()
		if not enRun() then return end
		local max = tonumber(lireEtat("PVMaisonMax", 0)) or 0
		local pv = tonumber(lireEtat("PVMaison", 0)) or 0
		if max > 0 and pv > 0 and pv / max < SEUIL_PV_MAISON then demander(4) end
	end

	local function verifierColosse()
		if enRun() and lireEtat("ColosseActif", false) == true then demander(6) end
	end

	joueur:GetAttributeChangedSignal("EnRun"):Connect(function()
		local maintenant = enRun()
		if maintenant and not etaitEnRun then
			-- début d'une run
			piecesDebutRun = tonumber(joueur:GetAttribute("Pieces")) or 0
			demander(2)
			verifierMaison()
			verifierColosse()
		elseif etaitEnRun and not maintenant then
			-- retour au lobby
			demander(5)
		end
		etaitEnRun = maintenant
	end)

	joueur:GetAttributeChangedSignal("Pieces"):Connect(verifierPieces)

	if Etat then
		Etat:GetAttributeChangedSignal("PVMaison"):Connect(verifierMaison)
		Etat:GetAttributeChangedSignal("PVMaisonMax"):Connect(verifierMaison)
		Etat:GetAttributeChangedSignal("ColosseActif"):Connect(verifierColosse)
	end

	-- l'effet « Colosse » du serveur sert de filet si l'attribut arrive en retard
	if Reseau.Effet then
		Reseau.Effet.OnClientEvent:Connect(function(genre)
			if genre == "Colosse" and enRun() then demander(6) end
		end)
	end

	-- premier conseil : au lobby, après un court instant
	task.delay(DELAI_LOBBY, function()
		if not enRun() then
			demander(1)
		else
			etaitEnRun = true
			demander(2)
			verifierMaison()
			verifierColosse()
		end
	end)
end

return M
