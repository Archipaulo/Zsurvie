-- Interface Tutoriel : bulles d'aide montrées une seule fois par session (7 s ou un clic pour fermer),
-- et flèche locale vers le Tapis tant que le joueur n'a rien acheté.
-- Look « simulateur » soigné (STYLE.md §4) : carte jaune en dégradé cernée de noir avec reflet,
-- liseré clair et ombre portée ; grosse pastille ronde colorée avec l'icône de l'étape qui déborde
-- à gauche ; en-tête « ETAPE 2/6 » et barre de progression en six segments ; petit X rouge ;
-- barre de temps sur piste sombre. Ouverture en glissé + pop, fermeture en fondu.
-- Dans le monde, grosse flèche « ⬇ » cernée qui rebondit au-dessus de la cible de l'étape
-- (Tapis, dalle de collecte, bouton de verrou).
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

local HAUTEUR = 118          -- hauteur de la carte (px)
local LARGEUR_MAX = 640
local MARGE_TEXTE = 92       -- début du texte (après la pastille)

local TEXTES = {
	"Va au Tapis rouge et achète ton premier dino 🦖",
	"Ton dino gagne de l'argent dans ta base : marche sur la dalle 💰 pour encaisser",
	"Attention aux voleurs ! Verrouille ta base 🔒 avec le bouton près de l'entrée",
	"Toi aussi, vole les dinos des autres : maintiens E sur un de leurs dinos et rapporte-le chez toi !",
	"Frappe les voleurs avec ta batte 🏏 (F) pour récupérer ton dino",
	"Bientôt la renaissance ♻️ à l'Autel !",
}

-- icône et couleur (clé de Style.boutons) de la pastille de chaque étape
local ETAPES = {
	{ icone = "🦖", couleur = "rouge" },
	{ icone = "💰", couleur = "vert" },
	{ icone = "🔒", couleur = "bleu" },
	{ icone = "🏃", couleur = "violet" },
	{ icone = "🏏", couleur = "orange" },
	{ icone = "♻️", couleur = "rose" },
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
	local VERT = Style.boutons.vert
	local ORANGE = Style.boutons.orange
	local NOIR = Style.couleurs.contour
	local BLANC = Color3.new(1, 1, 1)
	local NB_ETAPES = #TEXTES

	local uid = joueur.UserId
	local vues = {}        -- vues[n] = true : bulle déjà montrée (ou en file)
	local montrees = {}    -- montrees[n] = true : bulle réellement affichée (barre de progression)
	local file = {}        -- bulles en attente
	local actif = true
	local etapeEnCours = nil -- numéro de la bulle affichée (pilote la flèche du monde)

	-- rebond infini (aller-retour) ; renvoie le tween (ou nil)
	local function rebond(inst, duree, props)
		local ok, t = pcall(function()
			local info = TweenInfo.new(duree, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			local tw = TweenService:Create(inst, info, props)
			tw:Play()
			return tw
		end)
		if ok then return t end
		return nil
	end

	local function tweenner(inst, info, props)
		local ok, t = pcall(function()
			local tw = TweenService:Create(inst, info, props)
			tw:Play()
			return tw
		end)
		if ok then return t end
		return nil
	end

	local function cadre(parent, props)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = BLANC
		for cle, valeur in pairs(props) do f[cle] = valeur end
		f.Parent = parent
		return f
	end

	-- reflet brillant (moitié haute, fondu vers le bas) comme sur les boutons
	local function reflet(parent, rayon, zindex, transparence)
		local r = cadre(parent, {
			Name = "Reflet",
			Position = UDim2.new(0, 6, 0, 4),
			Size = UDim2.new(1, -12, 0.46, 0),
			BackgroundTransparency = transparence or 0.6,
			ZIndex = zindex,
		})
		Style.coins(r, rayon)
		local g = Instance.new("UIGradient")
		g.Rotation = 90
		g.Transparency = NumberSequence.new(0.05, 1)
		g.Parent = r
		return r
	end

	-- ===== la bulle : conteneur transparent cliquable (ombre + carte + pastille) =====
	local bulle = Instance.new("TextButton")
	bulle.Name = "Tutoriel"
	bulle.AnchorPoint = Vector2.new(0.5, 1)
	bulle.Position = UDim2.new(0.5, 0, 1, 40)
	bulle.Size = UDim2.new(0.9, 0, 0, HAUTEUR)
	bulle.BackgroundTransparency = 1
	bulle.BorderSizePixel = 0
	bulle.AutoButtonColor = false
	bulle.Text = ""
	bulle.Visible = false
	bulle.ZIndex = 30
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(LARGEUR_MAX, HAUTEUR)
	limite.Parent = bulle
	local echelle = Instance.new("UIScale")
	echelle.Name = "Pop"
	echelle.Parent = bulle
	bulle.Parent = gui

	-- ombre portée douce (deux couches décalées)
	local ombre = cadre(bulle, {
		Name = "Ombre",
		Position = UDim2.new(0, 0, 0, 8),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Style.couleurs.ombre,
		BackgroundTransparency = 0.55,
		ZIndex = 30,
	})
	Style.coins(ombre, 24)
	local ombreDouce = cadre(bulle, {
		Name = "OmbreDouce",
		Position = UDim2.new(0, -3, 0, 12),
		Size = UDim2.new(1, 6, 1, 2),
		BackgroundColor3 = Style.couleurs.ombre,
		BackgroundTransparency = 0.8,
		ZIndex = 30,
	})
	Style.coins(ombreDouce, 26)

	-- carte jaune en dégradé, cernée, avec reflet et liseré clair intérieur
	local carte = cadre(bulle, {
		Name = "Carte",
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 31,
	})
	Style.coins(carte, 22)
	Style.bordure(carte, 4)
	Style.degrade(carte, JAUNE[1], JAUNE[2])
	reflet(carte, 16, 32, 0.55)
	local lisere = cadre(carte, {
		Name = "Lisere",
		Position = UDim2.new(0, 4, 0, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		ZIndex = 32,
	})
	Style.coins(lisere, 18)
	local traitLisere = Style.bordure(lisere, 2, BLANC)
	traitLisere.Transparency = 0.45

	-- en-tête : « ETAPE 2/6 »
	local etiquetteEtape = Style.texte(carte, {
		Name = "Etape",
		Position = UDim2.new(0, MARGE_TEXTE, 0, 10),
		Size = UDim2.new(0, 112, 0, 22),
		Text = "ETAPE 1/" .. NB_ETAPES,
		TextXAlignment = Enum.TextXAlignment.Left,
		titre = true,
		contour = 2.5,
		tailleMax = 20,
		ZIndex = 33,
	})

	-- barre de progression : un segment par étape
	local progression = cadre(carte, {
		Name = "Progression",
		Position = UDim2.new(0, MARGE_TEXTE + 118, 0, 14),
		Size = UDim2.new(1, -(MARGE_TEXTE + 118 + 34), 0, 14),
		BackgroundTransparency = 1,
		ZIndex = 33,
	})
	local rangee = Instance.new("UIListLayout")
	rangee.FillDirection = Enum.FillDirection.Horizontal
	rangee.SortOrder = Enum.SortOrder.LayoutOrder
	rangee.VerticalAlignment = Enum.VerticalAlignment.Center
	rangee.Padding = UDim.new(0, 5)
	rangee.Parent = progression
	local segments = {}
	for i = 1, NB_ETAPES do
		local s = cadre(progression, {
			Name = "Segment" .. i,
			LayoutOrder = i,
			Size = UDim2.new(1 / NB_ETAPES, -5, 1, 0),
			ZIndex = 33,
		})
		Style.coins(s, 7)
		Style.bordure(s, 2)
		local g = Style.degrade(s, NOIR, NOIR)
		local pouls = Instance.new("UIScale")
		pouls.Name = "Pouls"
		pouls.Parent = s
		segments[i] = { cadre = s, degrade = g, pouls = pouls }
	end

	-- petit X rouge dans le coin (toute la bulle reste cliquable)
	local fermeeParClic = false
	Style.bouton(bulle, {
		Name = "Fermer",
		Size = UDim2.fromOffset(36, 36),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -8, 0, 8),
		couleur = "rouge",
		texte = "X",
		rayon = 18,
		ZIndex = 35,
		tailleMax = 22,
	}, function()
		fermeeParClic = true
	end)

	-- texte de l'étape
	local texte = Style.texte(carte, {
		Name = "Texte",
		Position = UDim2.new(0, MARGE_TEXTE, 0, 36),
		Size = UDim2.new(1, -(MARGE_TEXTE + 18), 1, -62),
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		contour = 3,
		ZIndex = 33,
	})
	local tailleTexte = Instance.new("UITextSizeConstraint")
	tailleTexte.MaxTextSize = 24
	tailleTexte.MinTextSize = 14
	tailleTexte.Parent = texte

	-- barre de temps : piste sombre, remplissage blanc cerné
	local piste = cadre(carte, {
		Name = "Piste",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, MARGE_TEXTE, 1, -12),
		Size = UDim2.new(1, -(MARGE_TEXTE + 18), 0, 8),
		BackgroundColor3 = NOIR,
		BackgroundTransparency = 0.6,
		ZIndex = 33,
	})
	Style.coins(piste, 4)
	local barre = cadre(piste, {
		Name = "Temps",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Style.couleurs.texte,
		ZIndex = 34,
	})
	Style.coins(barre, 4)
	Style.bordure(barre, 2)

	-- pastille ronde colorée avec l'icône de l'étape, qui déborde à gauche
	local pastille = cadre(bulle, {
		Name = "Pastille",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -12, 0.5, -4),
		Size = UDim2.new(0, 90, 0, 90),
		ZIndex = 34,
	})
	Style.coins(pastille, 45)
	Style.bordure(pastille, 4)
	local degradePastille = Style.degrade(pastille, ORANGE[1], ORANGE[2])
	reflet(pastille, 30, 35, 0.5)
	local anneau = cadre(pastille, {
		Name = "Anneau",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -10, 1, -10),
		BackgroundTransparency = 1,
		ZIndex = 35,
	})
	Style.coins(anneau, 40)
	local traitAnneau = Style.bordure(anneau, 2, BLANC)
	traitAnneau.Transparency = 0.4
	local icone = Style.texte(pastille, {
		Name = "Icone",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -24, 1, -24),
		Text = ETAPES[1].icone,
		contour = 2,
		tailleMax = 48,
		ZIndex = 36,
	})
	icone.Rotation = -7
	rebond(icone, 0.7, { Rotation = 7 })

	-- petite flèche qui rebondit sous la carte (« regarde le monde »), décalée à droite pour ne pas
	-- passer sur le bouton Collecter du HUD
	local petiteFleche = Style.texte(bulle, {
		Name = "Fleche",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.84, 0, 1, 4),
		Size = UDim2.new(0, 40, 0, 36),
		Text = "⬇",
		TextColor3 = JAUNE[1],
		contour = 3,
		ZIndex = 31,
	})
	rebond(petiteFleche, 0.4, { Position = UDim2.new(0.84, 0, 1, 14) })

	-- transparences d'origine de tout ce qui s'efface au fondu de fermeture
	local fondus = {}
	local function retenir(o, prop)
		local ok, v = pcall(function() return o[prop] end)
		if ok and type(v) == "number" and v < 1 then
			table.insert(fondus, { objet = o, prop = prop, base = v })
		end
	end
	for _, o in ipairs(bulle:GetDescendants()) do
		if o:IsA("UIStroke") then
			retenir(o, "Transparency")
		elseif o:IsA("TextLabel") or o:IsA("TextButton") then
			retenir(o, "BackgroundTransparency")
			retenir(o, "TextTransparency")
		elseif o:IsA("GuiObject") then
			retenir(o, "BackgroundTransparency")
		end
	end

	local function opacite(pleine, duree)
		for _, f in ipairs(fondus) do
			local but = pleine and f.base or 1
			if duree and duree > 0 then
				local props = {}
				props[f.prop] = but
				tweenner(f.objet, TweenInfo.new(duree, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
			else
				pcall(function() f.objet[f.prop] = but end)
			end
		end
	end

	-- visible : au-dessus du bouton Collecter du HUD (haut à 100 + 78 px du bas), ombre comprise
	local POS_VISIBLE = UDim2.new(0.5, 0, 1, -196)
	local POS_CACHEE = UDim2.new(0.5, 0, 1, 150)
	local POS_SORTIE = UDim2.new(0.5, 0, 1, -180)

	bulle.Activated:Connect(function()
		fermeeParClic = true
	end)

	-- couleurs des segments : faits en vert, en cours en orange qui pulse, à venir en sombre
	local poulsEnCours = nil
	local function majProgression(n)
		if poulsEnCours then
			pcall(function() poulsEnCours:Cancel() end)
			poulsEnCours = nil
		end
		for i, s in ipairs(segments) do
			s.pouls.Scale = 1
			if i == n then
				s.degrade.Color = ColorSequence.new(ORANGE[1], ORANGE[2])
			elseif montrees[i] then
				s.degrade.Color = ColorSequence.new(VERT[1], VERT[2])
			else
				s.degrade.Color = ColorSequence.new(Style.couleurs.carteClaire, Style.couleurs.fond)
			end
		end
		if segments[n] then
			poulsEnCours = rebond(segments[n].pouls, 0.45, { Scale = 1.18 })
		end
	end

	local majFleche -- définie plus bas

	local function montrer(n)
		local def = ETAPES[n] or ETAPES[1]
		local palette = Style.boutons[def.couleur] or ORANGE
		montrees[n] = true
		etiquetteEtape.Text = "ETAPE " .. n .. "/" .. NB_ETAPES
		icone.Text = def.icone
		degradePastille.Color = ColorSequence.new(palette[1], palette[2])
		texte.Text = TEXTES[n] or ""
		majProgression(n)
		fermeeParClic = false
		etapeEnCours = n

		-- ouverture : glissé depuis le bas (Back) + pop, pastille qui rebondit un peu après
		opacite(true)
		echelle.Scale = 1
		bulle.Position = POS_CACHEE
		bulle.Visible = true
		barre.Size = UDim2.new(1, 0, 1, 0)
		tweenner(bulle, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = POS_VISIBLE })
		pcall(Style.pop, bulle, 1.06)
		task.delay(0.15, function()
			if etapeEnCours == n then pcall(Style.pop, pastille, 1.18) end
		end)
		tweenner(barre, TweenInfo.new(DUREE_BULLE, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
		if majFleche then pcall(majFleche) end
		Bus.emettre("TutorielEtape", n)
		Bus.emettre("Son", "clic")

		local debut = os.clock()
		while os.clock() - debut < DUREE_BULLE and not fermeeParClic and actif do
			task.wait(0.1)
		end
		etapeEnCours = nil
		if majFleche then pcall(majFleche) end

		-- fermeture : fondu, léger recul et petite descente
		opacite(false, 0.28)
		tweenner(echelle, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.92 })
		tweenner(bulle, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = POS_SORTIE })
		task.wait(0.3)
		bulle.Visible = false
		if poulsEnCours then
			pcall(function() poulsEnCours:Cancel() end)
			poulsEnCours = nil
		end
		opacite(true)
		echelle.Scale = 1
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
					pcall(opacite, true)
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
			-- joueur déjà équipé : pas besoin des deux premières bulles (comptées comme faites)
			vues[1] = true
			vues[2] = true
			montrees[1] = true
			montrees[2] = true
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
