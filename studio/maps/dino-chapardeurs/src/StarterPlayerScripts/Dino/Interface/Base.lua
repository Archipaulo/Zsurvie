-- Interface Base : invites locales (Vendre / Voler / Verrouiller), repère « Ta base »,
-- minuteur au-dessus du bouton de verrou et barre de verrou dans l'écran.
-- Tout est local : ProximityPrompt.Enabled n'est modifié que sur ce client, le serveur vérifie toujours.

local M = {}

local DISTANCE_REPERE = 60 -- au-delà, le repère « Ta base » s'affiche
local PERIODE = 0.2        -- rafraîchissement des minuteurs
local PERIODE_SURETE = 2   -- recalcul complet des invites, au cas où un changement aurait échappé

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
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

	local repere = Instance.new("BillboardGui")
	repere.Name = "RepereBase"
	repere.AlwaysOnTop = true
	repere.ResetOnSpawn = false
	repere.LightInfluence = 0
	repere.Size = UDim2.fromOffset(170, 58)
	repere.StudsOffset = Vector3.new(0, 5, 0)
	repere.MaxDistance = 100000
	repere.Enabled = false
	repere.Parent = conteneur
	local fondRepere = Outils.cadre(repere, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0.25,
	})
	local traitRepere = Instance.new("UIStroke")
	traitRepere.Color = Charte.dore
	traitRepere.Thickness = 2
	traitRepere.Parent = fondRepere
	Outils.etiquette(fondRepere, {
		Name = "Titre",
		Size = UDim2.new(1, -12, 0.6, -4),
		Position = UDim2.fromOffset(6, 4),
		Text = "🏠 Ta base",
		TextColor3 = Charte.dore,
	})
	local distanceRepere = Outils.etiquette(fondRepere, {
		Name = "Distance",
		Size = UDim2.new(1, -12, 0.4, -4),
		Position = UDim2.new(0, 6, 0.6, 0),
		Text = "",
		Font = Charte.policeTexte,
		TextColor3 = Charte.creme,
	})

	local minuteur = Instance.new("BillboardGui")
	minuteur.Name = "MinuteurVerrou"
	minuteur.AlwaysOnTop = false
	minuteur.ResetOnSpawn = false
	minuteur.LightInfluence = 0
	minuteur.Size = UDim2.fromOffset(120, 44)
	minuteur.StudsOffset = Vector3.new(0, 3.2, 0)
	minuteur.MaxDistance = 90
	minuteur.Enabled = false
	minuteur.Parent = conteneur
	local fondMinuteur = Outils.cadre(minuteur, {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0.2,
	})
	local traitMinuteur = Instance.new("UIStroke")
	traitMinuteur.Color = Charte.herbe
	traitMinuteur.Thickness = 2
	traitMinuteur.Parent = fondMinuteur
	local texteMinuteur = Outils.etiquette(fondMinuteur, {
		Name = "Texte",
		Size = UDim2.new(1, -10, 1, -8),
		Position = UDim2.fromOffset(5, 4),
		Text = "Prêt",
		TextColor3 = Charte.herbe,
	})

	-- ===== barre de verrou dans l'écran =====
	local barre = Outils.cadre(ctx.gui, {
		Name = "BarreVerrou",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 144), -- sous l'argent (10..88) et le bandeau d'événement du HUD (96..136)
		Size = UDim2.fromOffset(300, 46),
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0.15,
		Visible = false,
	})
	local traitBarre = Instance.new("UIStroke")
	traitBarre.Color = Charte.alerte
	traitBarre.Thickness = 2
	traitBarre.Parent = barre
	local texteBarre = Outils.etiquette(barre, {
		Name = "Texte",
		Size = UDim2.new(1, -16, 0, 22),
		Position = UDim2.fromOffset(8, 4),
		Text = "",
		TextColor3 = Charte.creme,
	})
	local rail = Outils.cadre(barre, {
		Name = "Rail",
		Position = UDim2.new(0, 10, 0, 30),
		Size = UDim2.new(1, -20, 0, 9),
		BackgroundColor3 = Charte.nuit,
		BackgroundTransparency = 0,
	})
	local remplissage = Outils.cadre(rail, {
		Name = "Remplissage",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Charte.alerte,
		BackgroundTransparency = 0,
	})

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
				repere.Enabled = true
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
			if verrouillee then
				texteMinuteur.Text = "🔒 " .. math.ceil(reste) .. " s"
				texteMinuteur.TextColor3 = Charte.alerte
				traitMinuteur.Color = Charte.alerte
			elseif (finRecharge[index] or 0) > t then
				texteMinuteur.Text = "⏳ " .. math.ceil(finRecharge[index] - t) .. " s"
				texteMinuteur.TextColor3 = Charte.dore
				traitMinuteur.Color = Charte.dore
			else
				texteMinuteur.Text = "Prêt"
				texteMinuteur.TextColor3 = Charte.herbe
				traitMinuteur.Color = Charte.herbe
			end
			minuteur.Enabled = true
		else
			minuteur.Enabled = false
		end

		-- barre de verrou
		if verrouillee then
			texteBarre.Text = "🔒 Base verrouillée · " .. math.ceil(reste) .. " s"
			local part = 1
			if DUREE_VERROU > 0 then part = math.clamp(reste / DUREE_VERROU, 0, 1) end
			remplissage.Size = UDim2.fromScale(part, 1)
			if reste <= 10 then
				remplissage.BackgroundColor3 = Charte.dore
			else
				remplissage.BackgroundColor3 = Charte.alerte
			end
			barre.Visible = true
		else
			barre.Visible = false
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
