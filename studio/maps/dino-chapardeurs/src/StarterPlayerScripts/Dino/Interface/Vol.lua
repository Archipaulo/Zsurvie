-- Interface Vol : guide du voleur (bandeau, faisceau vers sa base, vignette pulsante)
-- et alerte de la victime (écran rouge « ON TE VOLE ! », son, surbrillance du voleur).
-- Tout est local à ce client : aucune part, seulement des Attachments, un Beam et des Highlights.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local M = {}

local PERIODE = 0.25      -- rafraîchissement du suivi (faisceau, voleurs)
local DUREE_ALERTE = 2    -- durée de l'alerte plein écran
local ANTI_DOUBLON = 1.5  -- deux signaux d'un même vol à moins de 1,5 s = une seule alerte

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local gui = ctx.gui
	local racine = ctx.racine
	local dinos = ctx.dinos

	local reglesVol = (ctx.Equilibrage and ctx.Equilibrage.vol) or {}
	local DELAI_MAX = tonumber(reglesVol.delaiMax) or 60

	local DORE = Charte.dore or Color3.new(1, 0.8, 0.2)
	local ROUGE = Charte.alerte or Color3.new(1, 0.2, 0.4)
	local CREME = Charte.creme or Color3.new(1, 1, 1)
	local ENCRE = Charte.encre or Color3.new(0.1, 0.1, 0.2)

	-- ===== écran : conteneur propre au module =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Vol"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundTransparency = 1
	ecran.BorderSizePixel = 0
	ecran.ZIndex = 20
	ecran.Parent = gui

	-- vignette : quatre bords en dégradé qui pulsent
	local vignette = Instance.new("Frame")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.fromScale(1, 1)
	vignette.BackgroundTransparency = 1
	vignette.Visible = false
	vignette.ZIndex = 20
	vignette.Parent = ecran

	local bords = {}
	local function bord(nom, taille, position, rotation)
		local f = Instance.new("Frame")
		f.Name = nom
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = taille
		f.Position = position
		f.BackgroundColor3 = DORE
		f.BackgroundTransparency = 0
		f.BorderSizePixel = 0
		f.ZIndex = 20
		local degrade = Instance.new("UIGradient")
		degrade.Rotation = rotation
		degrade.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.35),
			NumberSequenceKeypoint.new(1, 1),
		})
		degrade.Parent = f
		f.Parent = vignette
		table.insert(bords, f)
		return f
	end
	bord("Haut", UDim2.fromScale(1, 0.18), UDim2.fromScale(0.5, 0.09), 90)
	bord("Bas", UDim2.fromScale(1, 0.18), UDim2.fromScale(0.5, 0.91), 270)
	bord("Gauche", UDim2.fromScale(0.14, 1), UDim2.fromScale(0.07, 0.5), 0)
	bord("Droite", UDim2.fromScale(0.14, 1), UDim2.fromScale(0.93, 0.5), 180)

	-- bandeau « Rapporte-le dans ta base ! »
	local bandeau = Outils.cadre(ecran, {
		Name = "Bandeau",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 70),
		Size = UDim2.new(0.5, 0, 0, 64),
		BackgroundColor3 = ENCRE,
		BackgroundTransparency = 0.1,
		Visible = false,
		ZIndex = 21,
	})
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MinSize = Vector2.new(280, 56)
	contrainte.MaxSize = Vector2.new(620, 80)
	contrainte.Parent = bandeau
	local contour = Instance.new("UIStroke")
	contour.Color = DORE
	contour.Thickness = 3
	contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contour.Parent = bandeau
	local titreBandeau = Outils.etiquette(bandeau, {
		Name = "Titre",
		Position = UDim2.fromScale(0.04, 0.06),
		Size = UDim2.fromScale(0.92, 0.58),
		Text = "Rapporte-le dans ta base !",
		TextColor3 = DORE,
		ZIndex = 22,
	})
	local infoBandeau = Outils.etiquette(bandeau, {
		Name = "Info",
		Position = UDim2.fromScale(0.04, 0.64),
		Size = UDim2.fromScale(0.92, 0.3),
		Font = Charte.policeTexte or Enum.Font.GothamBold,
		Text = "",
		TextColor3 = CREME,
		ZIndex = 22,
	})

	-- alerte plein écran de la victime
	local alerte = Instance.new("Frame")
	alerte.Name = "Alerte"
	alerte.Size = UDim2.fromScale(1, 1)
	alerte.BackgroundColor3 = ROUGE
	alerte.BackgroundTransparency = 0.45
	alerte.BorderSizePixel = 0
	alerte.Visible = false
	alerte.ZIndex = 30
	alerte.Parent = ecran
	local texteAlerte = Outils.etiquette(alerte, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.fromScale(0.8, 0.16),
		Text = "ON TE VOLE !",
		TextColor3 = CREME,
		ZIndex = 31,
	})
	local contourTexte = Instance.new("UIStroke")
	contourTexte.Color = ENCRE
	contourTexte.Thickness = 4
	contourTexte.Parent = texteAlerte
	local sousAlerte = Outils.etiquette(alerte, {
		Name = "Voleur",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.54),
		Size = UDim2.fromScale(0.6, 0.06),
		Font = Charte.policeTexte or Enum.Font.GothamBold,
		Text = "",
		TextColor3 = CREME,
		ZIndex = 31,
	})

	-- ===== outils communs =====
	local function horloge()
		return os.clock()
	end

	local function valide(inst)
		return inst ~= nil and typeof(inst) == "Instance" and inst.Parent ~= nil
	end

	local function detruire(inst)
		if inst then pcall(function() inst:Destroy() end) end
	end

	local function racineDe(p)
		if not p then return nil end
		local perso = p.Character
		if not perso then return nil end
		return perso:FindFirstChild("HumanoidRootPart")
	end

	local function apparitionDeMaBase()
		local index = joueur:GetAttribute("Base")
		if type(index) ~= "number" or index <= 0 then return nil end
		local bases = racine:FindFirstChild("Bases")
		if not bases then return nil end
		local base = bases:FindFirstChild("Base" .. index)
		if not base then return nil end
		return base:FindFirstChild("Apparition") or base:FindFirstChild("Sol")
	end

	local function nomEspece(id)
		if type(id) ~= "string" or id == "" then return nil end
		for _, d in ipairs(dinos:GetChildren()) do
			if d:GetAttribute("Id") == id then
				local espece = d:GetAttribute("Espece")
				if type(espece) == "string" then return espece end
			end
		end
		return nil
	end

	-- ===== partie voleur : guide vers la base =====
	local attacheJoueur = nil
	local attacheBase = nil
	local faisceau = nil
	local debutPort = 0
	local porte = false

	local function nettoyerGuide()
		detruire(faisceau)
		detruire(attacheJoueur)
		detruire(attacheBase)
		faisceau = nil
		attacheJoueur = nil
		attacheBase = nil
	end

	local function assurerGuide()
		local hrp = racineDe(joueur)
		local cible = apparitionDeMaBase()
		if not hrp or not cible or not cible:IsA("BasePart") then
			nettoyerGuide()
			return nil, nil
		end
		if not valide(attacheJoueur) or attacheJoueur.Parent ~= hrp then
			detruire(attacheJoueur)
			attacheJoueur = Instance.new("Attachment")
			attacheJoueur.Name = "VolGuideJoueur"
			attacheJoueur.Position = Vector3.new(0, -1.5, 0)
			attacheJoueur.Parent = hrp
		end
		if not valide(attacheBase) or attacheBase.Parent ~= cible then
			detruire(attacheBase)
			attacheBase = Instance.new("Attachment")
			attacheBase.Name = "VolGuideBase"
			attacheBase.Position = Vector3.new(0, 2, 0)
			attacheBase.Parent = cible
		end
		if not valide(faisceau) then
			faisceau = Instance.new("Beam")
			faisceau.Name = "VolGuide"
			faisceau.Color = ColorSequence.new(DORE, Charte.lumiere and Charte.lumiere(DORE) or DORE)
			faisceau.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.8, 0.3),
				NumberSequenceKeypoint.new(1, 0.7),
			})
			faisceau.Width0 = 1.4
			faisceau.Width1 = 0.6
			faisceau.FaceCamera = true
			faisceau.LightEmission = 1
			faisceau.LightInfluence = 0
			faisceau.Segments = 12
			faisceau.CurveSize0 = 0
			faisceau.CurveSize1 = 0
			faisceau.Parent = hrp
		end
		faisceau.Attachment0 = attacheJoueur
		faisceau.Attachment1 = attacheBase
		if faisceau.Parent ~= hrp then faisceau.Parent = hrp end
		return hrp, cible
	end

	local function majPort()
		local valeur = joueur:GetAttribute("Porte")
		local maintenant = type(valeur) == "string" and valeur ~= ""
		if maintenant and not porte then
			porte = true
			debutPort = horloge()
			local espece = nomEspece(valeur)
			if espece then
				titreBandeau.Text = "Rapporte le " .. espece .. " dans ta base !"
			else
				titreBandeau.Text = "Rapporte-le dans ta base !"
			end
			bandeau.Visible = true
			vignette.Visible = true
			assurerGuide()
		elseif not maintenant and porte then
			porte = false
			bandeau.Visible = false
			vignette.Visible = false
			nettoyerGuide()
		end
	end

	-- ===== partie victime : alerte et surbrillance des voleurs =====
	local surbrillances = {} -- UserId du voleur -> Highlight
	local connus = {}        -- UserId des voleurs déjà signalés pendant le vol en cours
	local derniereAlerte = -100
	local finAlerte = 0

	local function nomDe(p)
		if not p then return "Quelqu'un" end
		local ok, nom = pcall(function() return p.DisplayName end)
		if ok and type(nom) == "string" and nom ~= "" then return nom end
		return p.Name
	end

	local function lancerAlerte(voleur)
		local t = horloge()
		if t - derniereAlerte < ANTI_DOUBLON then
			if voleur then sousAlerte.Text = nomDe(voleur) .. " embarque ton dino !" end
			return
		end
		derniereAlerte = t
		finAlerte = t + DUREE_ALERTE
		if voleur then
			sousAlerte.Text = nomDe(voleur) .. " embarque ton dino !"
		else
			sousAlerte.Text = "Défends ta base !"
		end
		alerte.Visible = true
		Bus.emettre("Son", "alerte")
	end

	local function surligner(uid)
		local existant = surbrillances[uid]
		local voleur = Players:GetPlayerByUserId(uid)
		local perso = voleur and voleur.Character
		if not perso then
			if existant then
				detruire(existant)
				surbrillances[uid] = nil
			end
			return
		end
		if valide(existant) and existant.Adornee == perso then return end
		detruire(existant)
		local h = Instance.new("Highlight")
		h.Name = "VolVoleur"
		h.FillColor = ROUGE
		h.OutlineColor = CREME
		h.FillTransparency = 0.45
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Adornee = perso
		h.Parent = perso -- instance locale : invisible pour les autres joueurs
		surbrillances[uid] = h
	end

	local function retirerSurbrillance(uid)
		detruire(surbrillances[uid])
		surbrillances[uid] = nil
	end

	-- voleurs en cours sur MES dinos, lus sur les attributs des dinos
	local function voleursActuels()
		local liste = {}
		for _, d in ipairs(dinos:GetChildren()) do
			if d:GetAttribute("Proprietaire") == joueur.UserId then
				local uid = d:GetAttribute("Voleur")
				if type(uid) == "number" and uid ~= 0 and uid ~= joueur.UserId then
					liste[uid] = true
				end
			end
		end
		return liste
	end

	local function majVoleurs()
		local liste = voleursActuels()
		for uid in pairs(liste) do
			if not connus[uid] then
				-- vol repéré sans signal réseau (message perdu) : on alerte quand même
				connus[uid] = true
				lancerAlerte(Players:GetPlayerByUserId(uid))
			end
			surligner(uid)
		end
		for uid in pairs(connus) do
			if not liste[uid] then connus[uid] = nil end
		end
		for uid in pairs(surbrillances) do
			if not liste[uid] then retirerSurbrillance(uid) end
		end
	end

	-- ===== signaux réseau =====
	if Reseau and Reseau.Effet then
		Reseau.Effet.OnClientEvent:Connect(function(genre, position, donnees)
			if genre ~= "VolDebut" or type(donnees) ~= "table" then return end
			if donnees.victime ~= joueur.UserId then return end
			local uid = donnees.voleur
			local voleur = nil
			if type(uid) == "number" then
				voleur = Players:GetPlayerByUserId(uid)
			end
			lancerAlerte(voleur)
			if type(uid) == "number" and uid ~= joueur.UserId then
				connus[uid] = true
				surligner(uid)
			end
		end)
	end

	if Reseau and Reseau.Notification then
		Reseau.Notification.OnClientEvent:Connect(function(texte, genre)
			if genre ~= "vol" then return end
			-- seul un vol en cours déclenche l'alerte (pas l'annonce d'un vol déjà terminé)
			local liste = voleursActuels()
			local premier = nil
			for uid in pairs(liste) do
				if not premier then premier = uid end
			end
			if premier then
				connus[premier] = true
				lancerAlerte(Players:GetPlayerByUserId(premier))
				surligner(premier)
			end
		end)
	end

	-- ===== joueurs qui partent =====
	Players.PlayerRemoving:Connect(function(p)
		if not p then return end
		connus[p.UserId] = nil
		if surbrillances[p.UserId] then retirerSurbrillance(p.UserId) end
	end)

	joueur:GetAttributeChangedSignal("Porte"):Connect(majPort)
	joueur:GetAttributeChangedSignal("Base"):Connect(function()
		if porte then
			nettoyerGuide()
			assurerGuide()
		end
	end)
	joueur.CharacterAdded:Connect(function()
		if porte then
			task.delay(0.5, function()
				if porte then assurerGuide() end
			end)
		end
	end)
	majPort()

	-- ===== animations : pulsation de la vignette et fondu de l'alerte =====
	RunService.Heartbeat:Connect(function()
		local t = horloge()
		if porte then
			local pulse = 0.5 + 0.5 * math.sin(t * 5)
			for _, f in ipairs(bords) do
				f.BackgroundTransparency = 0.15 + 0.45 * pulse
			end
			contour.Transparency = 0.5 * pulse
		end
		if alerte.Visible then
			local reste = finAlerte - t
			if reste <= 0 then
				alerte.Visible = false
			else
				local clignote = 0.5 + 0.5 * math.sin(t * 14)
				local fondu = 1
				if reste < 0.5 then fondu = reste / 0.5 end
				alerte.BackgroundTransparency = 1 - (0.25 + 0.2 * clignote) * fondu
				texteAlerte.TextTransparency = 1 - fondu
				sousAlerte.TextTransparency = 1 - fondu
				contourTexte.Transparency = 1 - fondu
				local echelle = 1 + 0.06 * clignote
				texteAlerte.Size = UDim2.fromScale(0.8 * echelle, 0.16 * echelle)
			end
		end
	end)

	-- ===== boucle de suivi =====
	while ecran.Parent do
		local ok = pcall(function()
			if porte then
				local hrp, cible = assurerGuide()
				local reste = math.max(0, math.ceil(DELAI_MAX - (horloge() - debutPort)))
				if hrp and cible then
					local d = (cible.Position - hrp.Position)
					local distance = math.floor(Vector3.new(d.X, 0, d.Z).Magnitude + 0.5)
					infoBandeau.Text = "Suis la lumière dorée : " .. distance .. " m - " .. reste .. " s"
				else
					infoBandeau.Text = "Encore " .. reste .. " s avant qu'il ne s'échappe"
				end
				if reste <= 10 then
					infoBandeau.TextColor3 = ROUGE
				else
					infoBandeau.TextColor3 = CREME
				end
			end
			majVoleurs()
		end)
		if not ok then
			-- une erreur passagère ne doit pas figer l'interface : on repart proprement
			nettoyerGuide()
		end
		task.wait(PERIODE)
	end

	-- l'écran a disparu : on range tout
	nettoyerGuide()
	for uid in pairs(surbrillances) do retirerSurbrillance(uid) end
end

return M
