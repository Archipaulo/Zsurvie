-- Interface Base : invites locales (Vendre / Voler / Verrouiller), repère « Ta base »,
-- minuteur au-dessus du bouton de verrou et ruban de verrou dans l'écran (look STYLE.md, via ctx.Style).
-- Tout est local : ProximityPrompt.Enabled n'est modifié que sur ce client, le serveur vérifie toujours.

local TweenService = game:GetService("TweenService")

local M = {}

local DISTANCE_REPERE = 60 -- au-delà, le repère « Ta base » s'affiche
local PERIODE = 0.2        -- rafraîchissement des minuteurs
local PERIODE_SURETE = 2   -- recalcul complet des invites, au cas où un changement aurait échappé
local ALERTE = 10          -- secondes restantes à partir desquelles le ruban clignote

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Style = ctx.Style
	local ROUGE = Charte.hex("FF4B4B")
	local VERT = Style.couleurs.argent
	local JAUNE = Style.couleurs.revenu
	local BLANC = Style.couleurs.texte
	local NOIR = Style.couleurs.contour
	local Equilibrage = ctx.Equilibrage
	local joueur = ctx.joueur
	local racine = ctx.racine
	local dinos = ctx.dinos

	local reglages = Equilibrage.base or {}
	local DUREE_VERROU = tonumber(reglages.dureeVerrou) or 60
	local RECHARGE = tonumber(reglages.recharge) or 5

	local bases = nil          -- Workspace.Dino.Bases (arrive peut-être plus tard)
	local finRecharge = {}     -- index de base -> heure serveur de fin de recharge (estimée localement)
	local connexionsDinos = {} -- dino -> connexion AttributeChanged
	local connexionsBases = {} -- modèle de base -> connexion AttributeChanged

	local function maintenant()
		local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
		if ok and type(t) == "number" then return t end
		return os.clock()
	end

	-- ===== ma base =====
	local function modeleBase(index)
		if not bases or type(index) ~= "number" then return nil end
		return bases:FindFirstChild("Base" .. index)
	end

	local function monIndex()
		local index = joueur:GetAttribute("Base")
		if type(index) == "number" and index > 0 then
			local m = modeleBase(index)
			if m and m:GetAttribute("Proprietaire") == joueur.UserId then return index end
		end
		if bases then
			for _, m in ipairs(bases:GetChildren()) do
				if m:GetAttribute("Proprietaire") == joueur.UserId then
					local i = m:GetAttribute("Index")
					if type(i) == "number" then return i end
					local n = tonumber(string.match(m.Name, "^Base(%d+)$"))
					if n then return n end
				end
			end
		end
		return nil
	end

	local function baseVerrouillee(index)
		local m = modeleBase(index)
		if not m then return false end
		if m:GetAttribute("Verrouillee") ~= true then return false end
		local fin = m:GetAttribute("FinVerrou")
		if type(fin) == "number" and fin > 0 and fin <= maintenant() then return false end
		return true
	end

	-- ===== invites des dinos =====
	local function regler(invite, actif)
		if invite.Enabled ~= actif then
			pcall(function() invite.Enabled = actif end)
		end
	end

	local function majDino(dino)
		if not dino or not dino.Parent then return end
		local proprietaire = dino:GetAttribute("Proprietaire")
		local etat = dino:GetAttribute("Etat")
		local voleur = dino:GetAttribute("Voleur")
		local aMoi = proprietaire == joueur.UserId
		local placeOk = etat == nil or etat == "Enclos"
		local volable = type(proprietaire) == "number" and proprietaire ~= 0 and not aMoi and placeOk
			and (voleur == nil or voleur == 0) and not baseVerrouillee(dino:GetAttribute("Base"))
		for _, d in ipairs(dino:GetDescendants()) do
			if d:IsA("ProximityPrompt") then
				if d.Name == "Vendre" then
					regler(d, aMoi and placeOk)
				elseif d.Name == "Voler" then
					regler(d, volable)
				end
			end
		end
	end

	local function majTousDinos()
		for _, dino in ipairs(dinos:GetChildren()) do
			majDino(dino)
		end
	end

	local function majDinosDeBase(index)
		for _, dino in ipairs(dinos:GetChildren()) do
			if dino:GetAttribute("Base") == index then majDino(dino) end
		end
	end

	local function suivreDino(dino)
		if connexionsDinos[dino] then return end
		connexionsDinos[dino] = dino.AttributeChanged:Connect(function(nom)
			if nom == "Proprietaire" or nom == "Base" or nom == "Etat" or nom == "Voleur" then
				majDino(dino)
			end
		end)
		majDino(dino)
	end

	for _, dino in ipairs(dinos:GetChildren()) do
		suivreDino(dino)
	end
	dinos.ChildAdded:Connect(function(dino)
		suivreDino(dino)
	end)
	dinos.ChildRemoved:Connect(function(dino)
		local c = connexionsDinos[dino]
		if c then
			c:Disconnect()
			connexionsDinos[dino] = nil
		end
	end)
	dinos.DescendantAdded:Connect(function(d)
		if d:IsA("ProximityPrompt") and (d.Name == "Vendre" or d.Name == "Voler") then
			-- remonte jusqu'au modèle enfant direct de ctx.dinos
			local dino = d
			while dino and dino.Parent ~= dinos do
				dino = dino.Parent
			end
			if dino then majDino(dino) end
		end
	end)

	-- ===== invites « Verrouiller » =====
	local function majVerrous()
		if not bases then return end
		for _, m in ipairs(bases:GetChildren()) do
			local aMoi = m:GetAttribute("Proprietaire") == joueur.UserId
			local bouton = m:FindFirstChild("BoutonVerrou")
			if bouton then
				for _, d in ipairs(bouton:GetDescendants()) do
					if d:IsA("ProximityPrompt") and d.Name == "Verrouiller" then
						regler(d, aMoi)
					end
				end
			end
		end
	end

	-- ===== petites briques graphiques =====
	local function cadre(parent, props)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		for cle, valeur in pairs(props) do
			f[cle] = valeur
		end
		f.Parent = parent
		return f
	end

	local function coinsRonds(gui)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = gui
		return c
	end

	-- reflet brillant sur la moitié haute (même effet « bonbon » que Style.bouton)
	local function reflet(parent, rayon, z, opacite)
		local r = cadre(parent, {
			Name = "Reflet",
			BackgroundTransparency = opacite or 0.7,
			Position = UDim2.new(0, 4, 0, 3),
			Size = UDim2.new(1, -8, 0.45, 0),
			ZIndex = z,
		})
		if rayon then Style.coins(r, rayon) else coinsRonds(r) end
		local fondu = Instance.new("UIGradient")
		fondu.Rotation = 90
		fondu.Transparency = NumberSequence.new(0.1, 1)
		fondu.Parent = r
		return r
	end

	-- battement bref (grossit puis revient à 1)
	local function pulser(gui, force)
		local e = gui:FindFirstChild("Pulse")
		if not e then
			e = Instance.new("UIScale")
			e.Name = "Pulse"
			e.Parent = gui
		end
		e.Scale = force or 1.18
		TweenService:Create(e, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end

	-- ===== repère « Ta base » et minuteur du verrou (BillboardGui locaux) =====
	local conteneur = ctx.gui.Parent -- PlayerGui : un BillboardGui n'est pas rendu à l'intérieur d'un ScreenGui

	-- repère géant « 🏠 TA BASE » : plaque verte, distance dans une capsule, flèche qui rebondit.
	-- Taille en pixels pour rester lisible de très loin, toujours devant.
	local repere = Instance.new("BillboardGui")
	repere.Name = "RepereBase"
	repere.Size = UDim2.fromOffset(240, 132)
	repere.StudsOffset = Vector3.new(0, 8, 0)
	repere.AlwaysOnTop = true
	repere.MaxDistance = 100000
	repere.LightInfluence = 0
	repere.ResetOnSpawn = false
	repere.Enabled = false

	local ombreRepere = cadre(repere, {
		Name = "Ombre",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(212, 56),
		BackgroundColor3 = Style.couleurs.ombre,
		BackgroundTransparency = 0.55,
		ZIndex = 1,
	})
	Style.coins(ombreRepere, 20)
	local plaqueRepere = cadre(repere, {
		Name = "Plaque",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromOffset(212, 56),
		ZIndex = 2,
	})
	Style.coins(plaqueRepere, 20)
	Style.bordure(plaqueRepere, 4)
	Style.degrade(plaqueRepere, Style.boutons.vert[1], Style.boutons.vert[2]).Name = "Fond"
	reflet(plaqueRepere, 16, 3)
	local titreRepere = Style.texte(plaqueRepere, {
		Name = "Titre",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -20, 1, -12),
		Text = "🏠 TA BASE",
		titre = true,
		contour = 3.5,
		tailleMax = 38,
		ZIndex = 4,
	})
	local capsuleDistance = cadre(repere, {
		Name = "Capsule",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 50),
		Size = UDim2.fromOffset(124, 28),
		BackgroundColor3 = NOIR,
		BackgroundTransparency = 0.12,
		ZIndex = 5,
	})
	coinsRonds(capsuleDistance)
	Style.bordure(capsuleDistance, 2.5, BLANC).Transparency = 0.35
	local distanceRepere = Style.texte(capsuleDistance, {
		Name = "Distance",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -14, 1, -8),
		Text = "",
		TextColor3 = JAUNE,
		contour = 2,
		tailleMax = 20,
		ZIndex = 6,
	})
	local HAUT_FLECHE = 80
	local fleche = Style.texte(repere, {
		Name = "Fleche",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, HAUT_FLECHE),
		Size = UDim2.fromOffset(48, 40),
		Text = "▼",
		TextColor3 = VERT,
		contour = 4,
		ZIndex = 4,
	})
	-- la flèche rebondit doucement vers la base (tween en boucle, aller-retour)
	TweenService:Create(fleche, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Position = UDim2.new(0.5, 0, 0, HAUT_FLECHE + 10),
	}):Play()
	repere.Parent = conteneur

	-- minuteur du verrou : capsule sombre au-dessus du bouton, texte coloré et mini-jauge
	-- (taille en studs, comme le monde)
	local minuteur = Instance.new("BillboardGui")
	minuteur.Name = "MinuteurVerrou"
	minuteur.Size = UDim2.new(8, 0, 3.4, 0)
	minuteur.StudsOffset = Vector3.new(0, 4.4, 0)
	minuteur.AlwaysOnTop = false
	minuteur.MaxDistance = 90
	minuteur.LightInfluence = 0
	minuteur.ResetOnSpawn = false
	minuteur.Enabled = false
	local plaqueMinuteur = cadre(minuteur, {
		Name = "Plaque",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 0.72),
	})
	coinsRonds(plaqueMinuteur)
	Style.bordure(plaqueMinuteur, 3)
	Style.degrade(plaqueMinuteur, Style.couleurs.fondHaut, Style.couleurs.fond).Name = "Fond"
	reflet(plaqueMinuteur, nil, 2, 0.8)
	local texteMinuteur = Style.texte(plaqueMinuteur, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.78),
		Text = "🔓 PRÊT",
		TextColor3 = VERT,
		titre = true,
		contour = 3,
		ZIndex = 3,
	})
	local railMinuteur = cadre(minuteur, {
		Name = "Rail",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(0.7, 0.16),
		BackgroundColor3 = NOIR,
		BackgroundTransparency = 0.1,
		Visible = false,
	})
	coinsRonds(railMinuteur)
	Style.bordure(railMinuteur, 2)
	local jaugeMinuteur = cadre(railMinuteur, {
		Name = "Jauge",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = ROUGE,
		ZIndex = 2,
	})
	coinsRonds(jaugeMinuteur)
	minuteur.Parent = conteneur
	local etatMinuteur = ""

	-- ===== ruban de verrou dans l'écran =====
	-- sous le bandeau d'événement du HUD (10..84) : zone 144..196, au-dessus du bandeau de vol (198..).
	-- Conteneur transparent : ombre portée, corps rouge brillant, médaillon cadenas, capsule du temps
	-- et jauge qui se vide en continu.
	local barre = cadre(nil, {
		Name = "BarreVerrou",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 144),
		Size = UDim2.new(0.9, 0, 0, 52),
		BackgroundTransparency = 1,
		Visible = false,
	})
	local limiteBarre = Instance.new("UISizeConstraint")
	limiteBarre.MaxSize = Vector2.new(460, 52)
	limiteBarre.Parent = barre

	local ombreBarre = cadre(barre, {
		Name = "Ombre",
		Position = UDim2.new(0, 0, 0, 5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Style.couleurs.ombre,
		BackgroundTransparency = 0.55,
		ZIndex = 1,
	})
	Style.coins(ombreBarre, 18)

	local corps = cadre(barre, {
		Name = "Corps",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
	})
	Style.coins(corps, 18)
	Style.bordure(corps, 4)
	local degradeCorps = Style.degrade(corps, Style.boutons.rouge[1], Style.boutons.rouge[2])
	degradeCorps.Name = "Fond"
	reflet(corps, 14, 3)

	local GAUCHE = 54 -- place laissée au médaillon
	local texteBarre = Style.texte(corps, {
		Name = "Texte",
		Position = UDim2.new(0, GAUCHE, 0, 4),
		Size = UDim2.new(1, -GAUCHE - 92, 0, 28),
		Text = "BASE VERROUILLÉE",
		TextXAlignment = Enum.TextXAlignment.Left,
		titre = true,
		contour = 3,
		tailleMax = 26,
		ZIndex = 4,
	})

	local capsuleTemps = cadre(corps, {
		Name = "Temps",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 5),
		Size = UDim2.fromOffset(78, 26),
		BackgroundColor3 = NOIR,
		BackgroundTransparency = 0.25,
		ZIndex = 4,
	})
	coinsRonds(capsuleTemps)
	local texteTemps = Style.texte(capsuleTemps, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -12, 1, -4),
		Text = "",
		TextColor3 = JAUNE,
		titre = true,
		contour = 2.5,
		tailleMax = 22,
		ZIndex = 5,
	})

	local rail = cadre(corps, {
		Name = "Rail",
		Position = UDim2.new(0, GAUCHE, 1, -16),
		Size = UDim2.new(1, -GAUCHE - 10, 0, 10),
		BackgroundColor3 = NOIR,
		BackgroundTransparency = 0.15,
		ZIndex = 4,
	})
	coinsRonds(rail)
	Style.bordure(rail, 1.5, NOIR)
	local remplissage = cadre(rail, {
		Name = "Remplissage",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
	})
	coinsRonds(remplissage)
	local degradeRemplissage = Style.degrade(remplissage, Style.boutons.jaune[1], Style.boutons.jaune[2])
	local brillance = cadre(remplissage, {
		Name = "Brillance",
		Position = UDim2.new(0, 2, 0, 1),
		Size = UDim2.new(1, -4, 0.4, 0),
		BackgroundTransparency = 0.45,
		ZIndex = 6,
	})
	coinsRonds(brillance)

	-- médaillon rond à gauche : anneau doré cerné de noir, disque sombre, gros cadenas
	local medaillon = cadre(barre, {
		Name = "Medaillon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 20, 0.5, 0),
		Size = UDim2.fromOffset(58, 58),
		ZIndex = 7,
	})
	coinsRonds(medaillon)
	Style.bordure(medaillon, 4)
	Style.degrade(medaillon, Style.boutons.jaune[1], Style.boutons.jaune[2]).Name = "Fond"
	local disque = cadre(medaillon, {
		Name = "Disque",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -12, 1, -12),
		ZIndex = 8,
	})
	coinsRonds(disque)
	Style.degrade(disque, Style.couleurs.fondHaut, Style.couleurs.fond).Name = "Fond"
	Style.texte(disque, {
		Name = "Icone",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.78, 0.78),
		Text = "🔒",
		contour = 2,
		ZIndex = 9,
	})
	barre.Parent = ctx.gui

	local barreAffichee = false
	local finAnimee = nil       -- FinVerrou pour laquelle la jauge se vide déjà
	local tweenJauge = nil
	local derniereSeconde = -1

	local function arreterJauge()
		if tweenJauge then
			tweenJauge:Cancel()
			tweenJauge = nil
		end
		finAnimee = nil
	end

	local function afficherBarre()
		barre.Visible = true
		if not barreAffichee then
			barreAffichee = true
			Style.pop(barre)
			pulser(medaillon, 1.3)
		end
	end

	-- fermeture : le ruban se replie puis disparaît
	local function masquerBarre()
		if not barreAffichee then
			barre.Visible = false
			return
		end
		barreAffichee = false
		arreterJauge()
		derniereSeconde = -1
		local echelle = barre:FindFirstChild("Pop")
		if not echelle then
			barre.Visible = false
			return
		end
		local t = TweenService:Create(echelle, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.3 })
		t.Completed:Connect(function()
			if not barreAffichee then
				barre.Visible = false
				echelle.Scale = 1
			end
		end)
		t:Play()
	end

	-- ===== suivi des bases =====
	local function suivreBase(m)
		if connexionsBases[m] or not m:IsA("Model") then return end
		local precedente = m:GetAttribute("FinVerrou")
		connexionsBases[m] = m.AttributeChanged:Connect(function(nom)
			if nom == "Proprietaire" then
				majVerrous()
				majTousDinos()
			elseif nom == "Verrouillee" or nom == "FinVerrou" then
				local fin = m:GetAttribute("FinVerrou")
				local index = m:GetAttribute("Index")
				if type(index) ~= "number" then index = tonumber(string.match(m.Name, "^Base(%d+)$")) end
				-- fin d'un verrou : la recharge démarre (estimation locale, le serveur reste juge)
				if index and type(precedente) == "number" and precedente > 0 and (fin == 0 or fin == nil) then
					finRecharge[index] = maintenant() + RECHARGE
				end
				precedente = fin
				if index then majDinosDeBase(index) end
			end
		end)
	end

	local function brancherBases(dossier)
		bases = dossier
		for _, m in ipairs(dossier:GetChildren()) do
			suivreBase(m)
		end
		dossier.ChildAdded:Connect(function(m)
			suivreBase(m)
			majVerrous()
		end)
		dossier.ChildRemoved:Connect(function(m)
			local c = connexionsBases[m]
			if c then
				c:Disconnect()
				connexionsBases[m] = nil
			end
		end)
		dossier.DescendantAdded:Connect(function(d)
			if d:IsA("ProximityPrompt") and d.Name == "Verrouiller" then
				majVerrous()
			end
		end)
		majVerrous()
		majTousDinos()
	end

	joueur:GetAttributeChangedSignal("Base"):Connect(function()
		majVerrous()
		majTousDinos()
	end)

	task.spawn(function()
		local dossier = racine:FindFirstChild("Bases") or racine:WaitForChild("Bases", 60)
		while not dossier do
			task.wait(2)
			dossier = racine:FindFirstChild("Bases")
		end
		brancherBases(dossier)
	end)

	-- ===== rafraîchissement des minuteurs et du repère =====
	local function positionPersonnage()
		local perso = joueur.Character
		if not perso then return nil end
		local r = perso:FindFirstChild("HumanoidRootPart")
		if r and r:IsA("BasePart") then return r.Position end
		return nil
	end

	local function rafraichir()
		local index = monIndex()
		local m = modeleBase(index)
		if not m then
			repere.Enabled = false
			minuteur.Enabled = false
			masquerBarre()
			return
		end
		local t = maintenant()

		-- repère au-dessus de l'enseigne quand on est loin
		local enseigne = m:FindFirstChild("Enseigne")
		local cible = enseigne or m:FindFirstChild("Sol")
		local pos = positionPersonnage()
		if cible and cible:IsA("BasePart") and pos then
			if repere.Adornee ~= cible then repere.Adornee = cible end
			local d = Outils.distanceXZ(pos, cible.Position)
			if d > DISTANCE_REPERE then
				distanceRepere.Text = math.floor(d + 0.5) .. " studs"
				if not repere.Enabled then
					repere.Enabled = true
					Style.pop(plaqueRepere)
					Style.pop(titreRepere)
				end
			else
				repere.Enabled = false
			end
		else
			repere.Enabled = false
		end

		-- minuteur au-dessus du bouton de verrou
		local bouton = m:FindFirstChild("BoutonVerrou")
		local verrouillee = baseVerrouillee(index)
		local fin = m:GetAttribute("FinVerrou")
		local reste = 0
		local finConnue = verrouillee and type(fin) == "number" and fin > 0
		if finConnue then
			reste = math.max(0, fin - t)
		end
		if bouton and bouton:IsA("BasePart") then
			if minuteur.Adornee ~= bouton then minuteur.Adornee = bouton end
			local etat = "pret"
			if verrouillee then
				etat = "verrou"
				if finConnue then
					texteMinuteur.Text = "🔒 " .. math.ceil(reste) .. "s"
				else
					texteMinuteur.Text = "🔒"
				end
				texteMinuteur.TextColor3 = ROUGE
				jaugeMinuteur.BackgroundColor3 = ROUGE
				local part = 1
				if finConnue and DUREE_VERROU > 0 then part = math.clamp(reste / DUREE_VERROU, 0, 1) end
				jaugeMinuteur.Size = UDim2.fromScale(part, 1)
				railMinuteur.Visible = true
			elseif (finRecharge[index] or 0) > t then
				etat = "recharge"
				local r = finRecharge[index] - t
				texteMinuteur.Text = "⏳ " .. math.ceil(r) .. "s"
				texteMinuteur.TextColor3 = JAUNE
				jaugeMinuteur.BackgroundColor3 = JAUNE
				local part = 1
				if RECHARGE > 0 then part = 1 - math.clamp(r / RECHARGE, 0, 1) end
				jaugeMinuteur.Size = UDim2.fromScale(part, 1)
				railMinuteur.Visible = true
			else
				texteMinuteur.Text = "🔓 PRÊT"
				texteMinuteur.TextColor3 = VERT
				railMinuteur.Visible = false
			end
			minuteur.Enabled = true
			if etat ~= etatMinuteur then
				etatMinuteur = etat
				Style.pop(plaqueMinuteur)
			end
		else
			minuteur.Enabled = false
		end

		-- ruban de verrou
		if verrouillee then
			if finConnue then
				texteTemps.Text = math.ceil(reste) .. "s"
				-- la jauge se vide en continu jusqu'à la fin du verrou (un seul tween par verrou)
				if finAnimee ~= fin then
					arreterJauge()
					finAnimee = fin
					local part = 1
					if DUREE_VERROU > 0 then part = math.clamp(reste / DUREE_VERROU, 0, 1) end
					remplissage.Size = UDim2.fromScale(part, 1)
					if reste > 0 then
						tweenJauge = TweenService:Create(remplissage, TweenInfo.new(reste, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
						tweenJauge:Play()
					end
				end
			else
				texteTemps.Text = "🔒"
				arreterJauge()
				remplissage.Size = UDim2.fromScale(1, 1)
			end
			if finConnue and reste <= ALERTE then
				-- fin proche : jauge blanc-rouge, texte qui clignote, médaillon qui bat à chaque seconde
				degradeRemplissage.Color = ColorSequence.new(BLANC, ROUGE)
				local clignote = math.floor(t * 2) % 2 == 0
				if clignote then
					texteBarre.TextColor3 = JAUNE
					texteTemps.TextColor3 = BLANC
				else
					texteBarre.TextColor3 = BLANC
					texteTemps.TextColor3 = JAUNE
				end
				local seconde = math.ceil(reste)
				if seconde ~= derniereSeconde then
					derniereSeconde = seconde
					pulser(medaillon, 1.2)
				end
			else
				degradeRemplissage.Color = ColorSequence.new(Style.boutons.jaune[1], Style.boutons.jaune[2])
				texteBarre.TextColor3 = BLANC
				texteTemps.TextColor3 = JAUNE
			end
			afficherBarre()
		else
			masquerBarre()
		end
	end

	local ecoule = 0
	while true do
		local ok = pcall(rafraichir)
		if not ok then
			repere.Enabled = false
		end
		ecoule = ecoule + PERIODE
		if ecoule >= PERIODE_SURETE then
			ecoule = 0
			pcall(majVerrous)
			pcall(majTousDinos)
		end
		task.wait(PERIODE)
	end
end

return M
