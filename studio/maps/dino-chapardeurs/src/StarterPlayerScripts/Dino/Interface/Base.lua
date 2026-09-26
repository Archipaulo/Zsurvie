-- Interface Base : invites locales (Vendre / Voler / Verrouiller), repère « Ta base »,
-- minuteur au-dessus du bouton de verrou et ruban de verrou dans l'écran (look STYLE.md, via ctx.Style).
-- Tout est local : ProximityPrompt.Enabled n'est modifié que sur ce client, le serveur vérifie toujours.

local M = {}

local DISTANCE_REPERE = 60 -- au-delà, le repère « Ta base » s'affiche
local PERIODE = 0.2        -- rafraîchissement des minuteurs
local PERIODE_SURETE = 2   -- recalcul complet des invites, au cas où un changement aurait échappé

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Style = ctx.Style
	local ROUGE = Charte.hex("FF4B4B")
	local VERT = Style.couleurs.argent
	local JAUNE = Style.couleurs.revenu
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

	-- ===== repère « Ta base » et minuteur du verrou (BillboardGui locaux) =====
	local conteneur = ctx.gui.Parent -- PlayerGui : un BillboardGui n'est pas rendu à l'intérieur d'un ScreenGui

	-- repère géant « 🏠 TA BASE » : taille en pixels pour rester lisible de très loin, toujours devant
	local repere, lignesRepere = Style.etiquette(nil, {
		{ texte = "🏠 TA BASE", couleur = VERT, taille = 1.4, titre = true, nom = "Titre", contour = 4 },
		{ texte = "", couleur = Style.couleurs.texte, taille = 0.8, nom = "Distance", contour = 3 },
	}, { Name = "RepereBase", AlwaysOnTop = true, MaxDistance = 100000, StudsOffset = Vector3.new(0, 7, 0) })
	repere.Size = UDim2.fromOffset(280, 100)
	repere.ResetOnSpawn = false
	repere.Enabled = false
	repere.Parent = conteneur
	local distanceRepere = lignesRepere[2]

	-- minuteur du verrou : gros texte cerné flottant au-dessus du bouton (taille en studs, comme le monde)
	local minuteur, lignesMinuteur = Style.etiquette(nil, {
		{ texte = "🔓 PRÊT", couleur = VERT, titre = true, nom = "Texte", contour = 4 },
	}, { Name = "MinuteurVerrou", AlwaysOnTop = false, MaxDistance = 90, largeur = 9, hauteurLigne = 2.6, StudsOffset = Vector3.new(0, 4, 0) })
	minuteur.ResetOnSpawn = false
	minuteur.Enabled = false
	minuteur.Parent = conteneur
	local texteMinuteur = lignesMinuteur[1]
	local etatMinuteur = ""

	-- ===== ruban de verrou dans l'écran =====
	-- sous le bandeau d'événement du HUD (10..84) : zone 144..196, au-dessus du bandeau de vol (198..)
	local barre = Instance.new("Frame")
	barre.Name = "BarreVerrou"
	barre.AnchorPoint = Vector2.new(0.5, 0)
	barre.Position = UDim2.new(0.5, 0, 0, 144)
	barre.Size = UDim2.new(0.9, 0, 0, 52)
	barre.BackgroundColor3 = Color3.new(1, 1, 1)
	barre.BorderSizePixel = 0
	barre.Visible = false
	Style.coins(barre, 16)
	Style.bordure(barre, 4)
	Style.degrade(barre, Style.boutons.rouge[1], Style.boutons.rouge[2])
	local limiteBarre = Instance.new("UISizeConstraint")
	limiteBarre.MaxSize = Vector2.new(440, 52)
	limiteBarre.Parent = barre
	barre.Parent = ctx.gui
	local texteBarre = Style.texte(barre, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 3),
		Size = UDim2.new(1, -20, 0, 32),
		Text = "",
		titre = true,
		contour = 3,
		tailleMax = 30,
	})
	local rail = Instance.new("Frame")
	rail.Name = "Rail"
	rail.Position = UDim2.new(0, 12, 1, -13)
	rail.Size = UDim2.new(1, -24, 0, 8)
	rail.BackgroundColor3 = Style.couleurs.contour
	rail.BorderSizePixel = 0
	Style.coins(rail, 4)
	rail.Parent = barre
	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(1, 1)
	remplissage.BackgroundColor3 = Color3.new(1, 1, 1)
	remplissage.BorderSizePixel = 0
	Style.coins(remplissage, 4)
	local degradeRemplissage = Style.degrade(remplissage, Style.boutons.jaune[1], Style.boutons.jaune[2])
	remplissage.Parent = rail
	local barreAffichee = false

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
			barre.Visible = false
			barreAffichee = false
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
					Style.pop(lignesRepere[1])
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
		if verrouillee and type(fin) == "number" then
			reste = math.max(0, fin - t)
		end
		if bouton and bouton:IsA("BasePart") then
			if minuteur.Adornee ~= bouton then minuteur.Adornee = bouton end
			local etat = "pret"
			if verrouillee then
				etat = "verrou"
				texteMinuteur.Text = "🔒 " .. math.ceil(reste) .. "s"
				texteMinuteur.TextColor3 = ROUGE
			elseif (finRecharge[index] or 0) > t then
				etat = "recharge"
				texteMinuteur.Text = "⏳ " .. math.ceil(finRecharge[index] - t) .. "s"
				texteMinuteur.TextColor3 = JAUNE
			else
				texteMinuteur.Text = "🔓 PRÊT"
				texteMinuteur.TextColor3 = VERT
			end
			minuteur.Enabled = true
			if etat ~= etatMinuteur then
				etatMinuteur = etat
				Style.pop(texteMinuteur)
			end
		else
			minuteur.Enabled = false
		end

		-- barre de verrou
		if verrouillee then
			texteBarre.Text = "🔒 BASE VERROUILLÉE " .. math.ceil(reste) .. "s"
			local part = 1
			if DUREE_VERROU > 0 then part = math.clamp(reste / DUREE_VERROU, 0, 1) end
			remplissage.Size = UDim2.fromScale(part, 1)
			if reste <= 10 then
				-- fin proche : la jauge passe au blanc et le texte clignote en jaune
				degradeRemplissage.Color = ColorSequence.new(Color3.new(1, 1, 1), Style.boutons.gris[1])
				if math.floor(t * 2) % 2 == 0 then
					texteBarre.TextColor3 = JAUNE
				else
					texteBarre.TextColor3 = Style.couleurs.texte
				end
			else
				degradeRemplissage.Color = ColorSequence.new(Style.boutons.jaune[1], Style.boutons.jaune[2])
				texteBarre.TextColor3 = Style.couleurs.texte
			end
			barre.Visible = true
			if not barreAffichee then
				barreAffichee = true
				Style.pop(barre)
			end
		else
			barre.Visible = false
			barreAffichee = false
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
