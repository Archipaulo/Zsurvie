-- Interface Tutoriel : bulles d'aide montrées une seule fois par session (7 s ou un clic pour fermer),
-- et flèche locale vers le Tapis tant que le joueur n'a rien acheté.
-- Look « simulateur » (STYLE.md) : ruban jaune en dégradé cerné de noir, texte blanc cerné, pop à
-- l'apparition, petite flèche qui rebondit ; dans le monde, grosse flèche « ⬇ » cernée qui rebondit
-- au-dessus de la cible de l'étape (Tapis, dalle de collecte, bouton de verrou).
-- Tout est local à ce client : aucune part, seulement des Attachments, un Beam et un BillboardGui.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local M = {}

local DUREE_BULLE = 7        -- secondes d'affichage d'une bulle
local PAUSE_ENTRE = 0.8      -- pause entre deux bulles
local PERIODE = 0.5          -- rafraîchissement des conditions et de la flèche
local DELAI_DEPART = 2       -- première bulle après l'arrivée
local ATTENTE_DONNEES = 8    -- attente max du chargement des données
local PROCHE_TAPIS = 10      -- en dessous de cette distance, le faisceau s'efface

local TEXTES = {
	"Va au Tapis rouge et achète ton premier dino 🦖",
	"Ton dino gagne de l'argent dans ta base : marche sur la dalle 💰 pour encaisser",
	"Attention aux voleurs ! Verrouille ta base 🔒 avec le bouton près de l'entrée",
	"Toi aussi, vole les dinos des autres : maintiens E sur un de leurs dinos et rapporte-le chez toi !",
	"Frappe les voleurs avec ta batte 🏏 (F) pour récupérer ton dino",
	"Bientôt la renaissance ♻️ à l'Autel !",
}

-- étapes qui montrent un objet de la base du joueur : enfant de la Base et libellé de la flèche
local CIBLES_BASE = {
	[2] = { enfant = "Collecte", libelle = "COLLECTE 💰" },
	[3] = { enfant = "BoutonVerrou", libelle = "VERROU 🔒" },
}

function M.demarrer(ctx)
	local Style = ctx.Style
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	local Bus = ctx.Bus
	local joueur = ctx.joueur
	local gui = ctx.gui
	local dinos = ctx.dinos
	local racine = ctx.racine

	local JAUNE = Style.boutons.jaune
	local ORANGE = Style.boutons.orange

	local uid = joueur.UserId
	local vues = {}        -- vues[n] = true : bulle déjà montrée (ou en file)
	local file = {}        -- bulles en attente
	local actif = true
	local etapeEnCours = nil -- numéro de la bulle affichée (pilote la flèche du monde)

	-- rebond infini (aller-retour) ; sans effet si le tween échoue
	local function rebond(inst, duree, props)
		pcall(function()
			local info = TweenInfo.new(duree, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			TweenService:Create(inst, info, props):Play()
		end)
	end

	-- ===== la bulle : ruban jaune cerné =====
	local bulle = Instance.new("TextButton")
	bulle.Name = "Tutoriel"
	bulle.AnchorPoint = Vector2.new(0.5, 1)
	bulle.Position = UDim2.new(0.5, 0, 1, 40)
	bulle.Size = UDim2.new(0.92, 0, 0, 96)
	bulle.BackgroundColor3 = Color3.new(1, 1, 1)
	bulle.BorderSizePixel = 0
	bulle.AutoButtonColor = false
	bulle.Text = ""
	bulle.Visible = false
	bulle.ZIndex = 30
	Style.coins(bulle, 20)
	Style.bordure(bulle, 4)
	Style.degrade(bulle, JAUNE[1], JAUNE[2])
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(620, 96)
	limite.Parent = bulle
	bulle.Parent = gui

	-- pastille ronde orange avec le numéro de l'étape
	local pastille = Instance.new("Frame")
	pastille.Name = "Pastille"
	pastille.AnchorPoint = Vector2.new(0, 0.5)
	pastille.Position = UDim2.new(0, 12, 0.5, 0)
	pastille.Size = UDim2.new(0, 62, 0, 62)
	pastille.BackgroundColor3 = Color3.new(1, 1, 1)
	pastille.BorderSizePixel = 0
	pastille.ZIndex = 31
	Style.coins(pastille, 31)
	Style.bordure(pastille, 3)
	Style.degrade(pastille, ORANGE[1], ORANGE[2])
	pastille.Parent = bulle
	local numero = Style.texte(pastille, {
		Name = "Numero",
		Size = UDim2.new(1, -12, 1, -12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = "1",
		titre = true,
		contour = 3,
		ZIndex = 32,
	})

	local texte = Style.texte(bulle, {
		Name = "Texte",
		Position = UDim2.new(0, 86, 0, 8),
		Size = UDim2.new(1, -100, 1, -30),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		contour = 3,
		ZIndex = 31,
	})
	local tailleTexte = Instance.new("UITextSizeConstraint")
	tailleTexte.MaxTextSize = 26
	tailleTexte.MinTextSize = 14
	tailleTexte.Parent = texte

	Style.texte(bulle, {
		Name = "Indice",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -6),
		Size = UDim2.new(0, 170, 0, 16),
		Text = "touche pour fermer",
		TextXAlignment = Enum.TextXAlignment.Right,
		contour = 2,
		ZIndex = 31,
	})

	-- barre de temps : blanche cernée
	local barre = Instance.new("Frame")
	barre.Name = "Temps"
	barre.AnchorPoint = Vector2.new(0, 1)
	barre.Position = UDim2.new(0, 86, 1, -8)
	barre.Size = UDim2.new(0, 0, 0, 6)
	barre.BackgroundColor3 = Style.couleurs.texte
	barre.BorderSizePixel = 0
	barre.ZIndex = 31
	Style.coins(barre, 3)
	Style.bordure(barre, 2)
	barre.Parent = bulle

	-- petite flèche qui rebondit sous le ruban (« regarde le monde »)
	local petiteFleche = Style.texte(bulle, {
		Name = "Fleche",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 2),
		Size = UDim2.new(0, 40, 0, 36),
		Text = "⬇",
		TextColor3 = JAUNE[1],
		contour = 3,
		ZIndex = 31,
	})
	rebond(petiteFleche, 0.4, { Position = UDim2.new(0.5, 0, 1, 12) })

	local POS_VISIBLE = UDim2.new(0.5, 0, 1, -186)
	local POS_CACHEE = UDim2.new(0.5, 0, 1, 140)

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

	local majFleche -- définie plus bas

	local function montrer(n)
		numero.Text = tostring(n)
		texte.Text = TEXTES[n] or ""
		fermeeParClic = false
		etapeEnCours = n
		bulle.Position = POS_CACHEE
		bulle.Visible = true
		barre.Size = UDim2.new(1, -100, 0, 6)
		tween(bulle, 0.4, { Position = POS_VISIBLE })
		pcall(Style.pop, bulle, 1.08)
		pcall(Style.pop, pastille, 1.25)
		pcall(function()
			TweenService:Create(barre, TweenInfo.new(DUREE_BULLE, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 6) }):Play()
		end)
		if majFleche then pcall(majFleche) end
		Bus.emettre("TutorielEtape", n)
		Bus.emettre("Son", "clic")
		local debut = os.clock()
		while os.clock() - debut < DUREE_BULLE and not fermeeParClic and actif do
			task.wait(0.1)
		end
		etapeEnCours = nil
		if majFleche then pcall(majFleche) end
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
				if not ok then
					etapeEnCours = nil
					bulle.Visible = false
				end
				task.wait(PAUSE_ENTRE)
			else
				task.wait(0.2)
			end
		end
	end)

	-- ===== grosse flèche du monde (Tapis, puis objets de la base pendant l'étape) =====
	local flecheActive = false
	local cible = Instance.new("Attachment")
	cible.Name = "TutorielCibleTapis"
	local panneau = Instance.new("BillboardGui")
	panneau.Name = "TutorielTapis"
	panneau.Size = UDim2.new(4, 60, 6, 80)
	panneau.StudsOffset = Vector3.new(0, 4, 0)
	panneau.AlwaysOnTop = true
	panneau.LightInfluence = 0
	panneau.MaxDistance = 400
	panneau.Enabled = false
	panneau.Parent = cible
	local libelleMonde = Style.texte(panneau, {
		Name = "Texte",
		Size = UDim2.fromScale(1, 0.3),
		Text = "TAPIS 🦖",
		titre = true,
		contour = 4,
	})
	local grosseFleche = Style.texte(panneau, {
		Name = "Fleche",
		Position = UDim2.fromScale(0, 0.28),
		Size = UDim2.fromScale(1, 0.72),
		Text = "⬇",
		contour = 5,
	})
	Style.degrade(grosseFleche, JAUNE[1], JAUNE[2])
	rebond(panneau, 0.45, { StudsOffset = Vector3.new(0, 6, 0) })

	local depart = Instance.new("Attachment")
	depart.Name = "TutorielDepart"
	local faisceau = Instance.new("Beam")
	faisceau.Name = "TutorielFleche"
	faisceau.Attachment0 = depart
	faisceau.Attachment1 = cible
	faisceau.Color = ColorSequence.new(JAUNE[1], JAUNE[2])
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

	-- objet de la base du joueur visé par l'étape en cours (nil si aucun)
	local function pointBase()
		local def = etapeEnCours and CIBLES_BASE[etapeEnCours]
		if not def then return nil end
		local index = tonumber(joueur:GetAttribute("Base"))
		if not index then return nil end
		local dossier = racine or workspace:FindFirstChild("Dino")
		local bases = dossier and dossier:FindFirstChild("Bases")
		local base = bases and bases:FindFirstChild("Base" .. index)
		local objet = base and base:FindFirstChild(def.enfant)
		if not objet or not objet:IsA("BasePart") then return nil end
		return objet.Position + Vector3.new(0, objet.Size.Y / 2 + 1, 0), def.libelle
	end

	majFleche = function()
		local rp = racineDe()
		local point, libelle = nil, nil
		if rp then
			point, libelle = pointBase()
			if not point and flecheActive then
				point = pointTapis(rp.Position)
				libelle = "TAPIS 🦖"
			end
		end
		if not point then
			faisceau.Enabled = false
			panneau.Enabled = false
			return
		end
		if depart.Parent ~= rp then
			depart.Parent = rp
			faisceau.Parent = rp
		end
		cible.WorldPosition = point
		if libelleMonde.Text ~= libelle then libelleMonde.Text = libelle end
		local proche = Outils.distanceXZ and Outils.distanceXZ(rp.Position, point) or (rp.Position - point).Magnitude
		faisceau.Enabled = proche > PROCHE_TAPIS
		if not panneau.Enabled then
			panneau.Enabled = true
			pcall(Style.pop, grosseFleche, 1.3)
		end
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
