-- Interface Tutoriel : bulles d'aide montrées une seule fois par session (7 s ou un clic pour fermer),
-- et flèche locale vers le Tapis tant que le joueur n'a rien acheté.
-- Tout est local à ce client : aucune part, seulement des Attachments, un Beam et un BillboardGui.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local M = {}

local DUREE_BULLE = 7        -- secondes d'affichage d'une bulle
local PAUSE_ENTRE = 0.8      -- pause entre deux bulles
local PERIODE = 0.5          -- rafraîchissement des conditions et de la flèche
local DELAI_DEPART = 2       -- première bulle après l'arrivée
local ATTENTE_DONNEES = 8    -- attente max du chargement des données
local PROCHE_TAPIS = 10      -- en dessous de cette distance, la flèche s'efface

local TEXTES = {
	"Va au Tapis rouge et achète ton premier dino 🦖",
	"Ton dino gagne de l'argent dans ta base : marche sur la dalle 💰 pour encaisser",
	"Attention aux voleurs ! Verrouille ta base 🔒 avec le bouton près de l'entrée",
	"Toi aussi, vole les dinos des autres : maintiens E sur un de leurs dinos et rapporte-le chez toi !",
	"Frappe les voleurs avec ta batte 🏏 (F) pour récupérer ton dino",
	"Bientôt la renaissance ♻️ à l'Autel !",
}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	local Bus = ctx.Bus
	local joueur = ctx.joueur
	local gui = ctx.gui
	local dinos = ctx.dinos

	local ENCRE = Charte.encre or Color3.new(0.1, 0.1, 0.2)
	local CREME = Charte.creme or Color3.new(1, 1, 1)
	local DORE = Charte.dore or Color3.new(1, 0.8, 0.2)
	local ROUGE = Charte.tapis or Color3.new(0.85, 0.15, 0.25)

	local uid = joueur.UserId
	local vues = {}        -- vues[n] = true : bulle déjà montrée (ou en file)
	local file = {}        -- bulles en attente
	local actif = true

	-- ===== la bulle =====
	local bulle = Outils.bouton(gui, {
		Name = "Tutoriel",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 40),
		Size = UDim2.new(0.9, 0, 0, 86),
		BackgroundColor3 = ENCRE,
		BackgroundTransparency = 0.1,
		AutoButtonColor = false,
		Text = "",
		TextScaled = false,
		Visible = false,
		ZIndex = 30,
	})
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(580, 86)
	limite.Parent = bulle
	local contour = Instance.new("UIStroke")
	contour.Color = DORE
	contour.Thickness = 3
	contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contour.Parent = bulle

	local pastille = Outils.cadre(bulle, {
		Name = "Pastille",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.new(0, 56, 0, 56),
		BackgroundColor3 = DORE,
		BackgroundTransparency = 0,
		ZIndex = 31,
	})
	local numero = Outils.etiquette(pastille, {
		Name = "Numero",
		Size = UDim2.fromScale(1, 1),
		Text = "1",
		TextColor3 = ENCRE,
		Font = Charte.police,
		ZIndex = 32,
	})
	local texte = Outils.etiquette(bulle, {
		Name = "Texte",
		Position = UDim2.new(0, 78, 0, 8),
		Size = UDim2.new(1, -90, 1, -24),
		Text = "",
		TextColor3 = CREME,
		Font = Charte.police,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 31,
	})
	local tailleTexte = Instance.new("UITextSizeConstraint")
	tailleTexte.MaxTextSize = 24
	tailleTexte.MinTextSize = 12
	tailleTexte.Parent = texte
	Outils.etiquette(bulle, {
		Name = "Indice",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -6),
		Size = UDim2.new(0, 160, 0, 12),
		Text = "clic pour fermer",
		TextColor3 = CREME,
		TextTransparency = 0.4,
		Font = Charte.policeTexte or Charte.police,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 31,
	})
	local barre = Outils.cadre(bulle, {
		Name = "Temps",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 78, 1, -4),
		Size = UDim2.new(0, 0, 0, 3),
		BackgroundColor3 = DORE,
		BackgroundTransparency = 0,
		ZIndex = 31,
	})

	local POS_VISIBLE = UDim2.new(0.5, 0, 1, -186)
	local POS_CACHEE = UDim2.new(0.5, 0, 1, 120)

	local fermeeParClic = false
	bulle.Activated:Connect(function()
		fermeeParClic = true
	end)

	local function tween(inst, duree, props)
		local ok, t = pcall(function()
			return TweenService:Create(inst, TweenInfo.new(duree, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
		end)
		if ok and t then t:Play() end
		return t
	end

	local function montrer(n)
		numero.Text = tostring(n)
		texte.Text = TEXTES[n] or ""
		fermeeParClic = false
		bulle.Position = POS_CACHEE
		bulle.Visible = true
		barre.Size = UDim2.new(1, -90, 0, 3)
		tween(bulle, 0.45, { Position = POS_VISIBLE })
		pcall(function()
			TweenService:Create(barre, TweenInfo.new(DUREE_BULLE, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) }):Play()
		end)
		Bus.emettre("TutorielEtape", n)
		Bus.emettre("Son", "clic")
		local debut = os.clock()
		while os.clock() - debut < DUREE_BULLE and not fermeeParClic and actif do
			task.wait(0.1)
		end
		pcall(function()
			TweenService:Create(bulle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = POS_CACHEE }):Play()
		end)
		task.wait(0.3)
		bulle.Visible = false
	end

	local function demander(n)
		if vues[n] then return end
		vues[n] = true
		table.insert(file, n)
	end

	-- une seule bulle à la fois, dans l'ordre d'arrivée
	task.spawn(function()
		while actif do
			if #file > 0 then
				local n = table.remove(file, 1)
				local ok = pcall(montrer, n)
				if not ok then bulle.Visible = false end
				task.wait(PAUSE_ENTRE)
			else
				task.wait(0.2)
			end
		end
	end)

	-- ===== flèche locale vers le Tapis =====
	local flecheActive = false
	local cible = Instance.new("Attachment")
	cible.Name = "TutorielCibleTapis"
	local panneau = Instance.new("BillboardGui")
	panneau.Name = "TutorielTapis"
	panneau.Size = UDim2.new(0, 150, 0, 50)
	panneau.StudsOffset = Vector3.new(0, 4, 0)
	panneau.AlwaysOnTop = true
	panneau.MaxDistance = 400
	panneau.Enabled = false
	panneau.Parent = cible
	Outils.etiquette(panneau, {
		Name = "Texte",
		Size = UDim2.fromScale(1, 1),
		Text = "⬇ Tapis 🦖",
		TextColor3 = CREME,
		TextStrokeColor3 = ROUGE,
		TextStrokeTransparency = 0,
		Font = Charte.police,
	})
	local depart = Instance.new("Attachment")
	depart.Name = "TutorielDepart"
	local faisceau = Instance.new("Beam")
	faisceau.Name = "TutorielFleche"
	faisceau.Attachment0 = depart
	faisceau.Attachment1 = cible
	faisceau.Color = ColorSequence.new(DORE, ROUGE)
	faisceau.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1, 0),
	})
	faisceau.Width0 = 0.6
	faisceau.Width1 = 1.4
	faisceau.FaceCamera = true
	faisceau.LightEmission = 0.6
	faisceau.Segments = 20
	faisceau.CurveSize0 = 6
	faisceau.CurveSize1 = -2
	faisceau.Enabled = false

	pcall(function()
		cible.Parent = workspace.Terrain
	end)

	local function racineDe()
		local perso = joueur.Character
		if not perso then return nil end
		return perso:FindFirstChild("HumanoidRootPart")
	end

	local function pointTapis(pos)
		local t = Plan.tapis or {}
		local a = t.debut or Vector3.new(-112, 0, 0)
		local b = t.fin or Vector3.new(112, 0, 0)
		local h = tonumber(t.hauteur) or 0.8
		local minX = math.min(a.X, b.X)
		local maxX = math.max(a.X, b.X)
		local x = math.clamp(pos.X, minX + 6, maxX - 6)
		return Vector3.new(x, h + 2, (a.Z + b.Z) / 2)
	end

	local function majFleche()
		local rp = racineDe()
		if not flecheActive or not rp then
			faisceau.Enabled = false
			panneau.Enabled = false
			return
		end
		if depart.Parent ~= rp then
			depart.Parent = rp
			faisceau.Parent = rp
		end
		local point = pointTapis(rp.Position)
		cible.WorldPosition = point
		local proche = Outils.distanceXZ and Outils.distanceXZ(rp.Position, point) or (rp.Position - point).Magnitude
		faisceau.Enabled = proche > PROCHE_TAPIS
		panneau.Enabled = true
	end

	local function arreterFleche()
		flecheActive = false
		faisceau.Enabled = false
		panneau.Enabled = false
	end

	-- ===== lecture de l'état du joueur =====
	local function mesDinos()
		local total, enBase, vole = 0, 0, false
		for _, d in ipairs(dinos:GetChildren()) do
			if d:GetAttribute("Proprietaire") == uid then
				local etat = d:GetAttribute("Etat")
				if etat == "Enclos" or etat == "EnRoute" or etat == "Porte" then
					total = total + 1
				end
				if etat == "Enclos" then
					enBase = enBase + 1
				end
				local voleur = tonumber(d:GetAttribute("Voleur")) or 0
				if voleur ~= 0 and voleur ~= uid then
					vole = true
				end
			end
		end
		return total, enBase, vole
	end

	local function procheRenaissance()
		local n = tonumber(joueur:GetAttribute("Renaissances")) or 0
		local max = tonumber(E.renaissanceMax) or 10
		if n >= max then return false end
		if type(E.coutRenaissance) ~= "function" then return false end
		local ok, cout = pcall(E.coutRenaissance, n)
		if not ok or type(cout) ~= "number" or cout <= 0 then return false end
		local argent = tonumber(joueur:GetAttribute("Argent")) or 0
		return argent >= cout * 0.5
	end

	-- premier vol subi : aussi signalé par l'effet réseau (plus réactif que le balayage)
	local Reseau = ctx.Reseau
	if Reseau and Reseau.Effet then
		Reseau.Effet.OnClientEvent:Connect(function(genre, _, donnees)
			if genre ~= "VolDebut" or type(donnees) ~= "table" then return end
			local victime = donnees.victime
			if victime == uid or victime == joueur or victime == joueur.Name or tonumber(victime) == uid then
				demander(5)
			end
		end)
	end

	-- ===== boucle principale =====
	task.spawn(function()
		-- attend le chargement des données pour ne pas se tromper sur les anciens joueurs
		local debut = os.clock()
		while joueur:GetAttribute("DonneesChargees") ~= true and os.clock() - debut < ATTENTE_DONNEES do
			task.wait(0.25)
		end
		task.wait(DELAI_DEPART)
		if not joueur.Parent then return end

		local total = mesDinos()
		if total > 0 then
			-- joueur déjà équipé : pas besoin des deux premières bulles
			vues[1] = true
			vues[2] = true
		else
			demander(1)
			flecheActive = true
		end

		while actif and joueur.Parent do
			local ok = pcall(function()
				local nb, enBase, vole = mesDinos()
				if nb > 0 then
					if flecheActive then arreterFleche() end
					demander(2)
				end
				if enBase >= 3 then
					demander(3)
					demander(4)
				end
				if vole then
					demander(5)
				end
				if procheRenaissance() then
					demander(6)
				end
				majFleche()
			end)
			if not ok then arreterFleche() end
			task.wait(PERIODE)
		end
	end)

	-- nettoyage si le joueur quitte
	Players.PlayerRemoving:Connect(function(qui)
		if qui == joueur then
			actif = false
			arreterFleche()
			pcall(function() cible:Destroy() end)
		end
	end)
end

return M
