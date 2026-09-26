-- Interface Vol : guide du voleur (ruban rouge qui pulse, faisceau vers sa base, bords dorés)
-- et alerte de la victime (texte géant « ON TE VOLE ! » qui tremble, bords rouges, son, surbrillance du voleur).
-- Look « simulateur Roblox » : tout passe par ctx.Style (voir STYLE.md).
-- Tout est local à ce client : aucune part, seulement des Attachments, un Beam et des Highlights.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local M = {}

local PERIODE = 0.25      -- rafraîchissement du suivi (faisceau, voleurs)
local DUREE_ALERTE = 2    -- durée de l'alerte (le texte tremble pendant tout ce temps)
local ANTI_DOUBLON = 1.5  -- deux signaux d'un même vol à moins de 1,5 s = une seule alerte
local HAUT_RUBAN = 198    -- sous l'argent, le bandeau d'événement (10..84) et la barre de verrou (144..190)
local HAUTEUR_RUBAN = 64  -- la pile de notifications du HUD commence à 270

function M.demarrer(ctx)
	local Style = ctx.Style
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local gui = ctx.gui
	local racine = ctx.racine
	local dinos = ctx.dinos

	local reglesVol = (ctx.Equilibrage and ctx.Equilibrage.vol) or {}
	local DELAI_MAX = tonumber(reglesVol.delaiMax) or 60

	local BLANC = Style.couleurs.texte
	local JAUNE = Style.couleurs.revenu
	local ROUGE_VIF = Style.boutons.rouge[2]
	local ROUGE_CLAIR = Style.boutons.rouge[1]
	local OR_HAUT = Style.boutons.jaune[1]
	local OR_BAS = Style.boutons.jaune[2]

	-- ===== écran : conteneur propre au module =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Vol"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundTransparency = 1
	ecran.BorderSizePixel = 0
	ecran.ZIndex = 20
	ecran.Parent = gui

	-- bords d'écran : quatre dégradés qui s'estompent vers le centre
	local function creerBords(parent, nom, couleur, epaisseur)
		local cadre = Instance.new("Frame")
		cadre.Name = nom
		cadre.Size = UDim2.fromScale(1, 1)
		cadre.BackgroundTransparency = 1
		cadre.Visible = false
		cadre.ZIndex = 20
		cadre.Parent = parent
		local liste = {}
		local function bord(n, taille, position, rotation)
			local f = Instance.new("Frame")
			f.Name = n
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Size = taille
			f.Position = position
			f.BackgroundColor3 = couleur
			f.BackgroundTransparency = 0
			f.BorderSizePixel = 0
			f.ZIndex = 20
			local degrade = Instance.new("UIGradient")
			degrade.Rotation = rotation
			degrade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.35, 0.45),
				NumberSequenceKeypoint.new(1, 1),
			})
			degrade.Parent = f
			f.Parent = cadre
			table.insert(liste, f)
		end
		bord("Haut", UDim2.fromScale(1, epaisseur), UDim2.fromScale(0.5, epaisseur / 2), 90)
		bord("Bas", UDim2.fromScale(1, epaisseur), UDim2.fromScale(0.5, 1 - epaisseur / 2), 270)
		bord("Gauche", UDim2.fromScale(epaisseur * 0.75, 1), UDim2.fromScale(epaisseur * 0.375, 0.5), 0)
		bord("Droite", UDim2.fromScale(epaisseur * 0.75, 1), UDim2.fromScale(1 - epaisseur * 0.375, 0.5), 180)
		return cadre, liste
	end

	-- bords dorés pendant qu'on porte un dino
	local vignette, bords = creerBords(ecran, "Vignette", OR_HAUT, 0.14)

	-- ===== ruban « 🦖 RAPPORTE-LE CHEZ TOI ! » en haut au centre =====
	local bandeau = Instance.new("Frame")
	bandeau.Name = "Bandeau"
	bandeau.AnchorPoint = Vector2.new(0.5, 0)
	bandeau.Position = UDim2.new(0.5, 0, 0, HAUT_RUBAN)
	bandeau.Size = UDim2.new(0.5, 0, 0, HAUTEUR_RUBAN)
	bandeau.BackgroundTransparency = 1
	bandeau.BorderSizePixel = 0
	bandeau.Visible = false
	bandeau.ZIndex = 21
	bandeau.Parent = ecran
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MinSize = Vector2.new(290, HAUTEUR_RUBAN)
	contrainte.MaxSize = Vector2.new(560, HAUTEUR_RUBAN)
	contrainte.Parent = bandeau

	-- le ruban lui-même (le « pop » d'apparition est sur le conteneur, la pulsation sur le ruban)
	local ruban = Instance.new("Frame")
	ruban.Name = "Ruban"
	ruban.Size = UDim2.fromScale(1, 1)
	ruban.BackgroundColor3 = Color3.new(1, 1, 1)
	ruban.BorderSizePixel = 0
	ruban.ZIndex = 21
	ruban.Parent = bandeau
	Style.coins(ruban, 18)
	local contour = Style.bordure(ruban, 4)
	Style.degrade(ruban, ROUGE_CLAIR, ROUGE_VIF)
	local pulsation = Instance.new("UIScale")
	pulsation.Name = "Pulsation"
	pulsation.Parent = ruban

	local titreBandeau = Style.texte(ruban, {
		Name = "Titre",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 3),
		Size = UDim2.new(1, -20, 0, 36),
		Text = "🦖 RAPPORTE-LE CHEZ TOI !",
		titre = true,
		contour = 3.5,
		tailleMax = 34,
		ZIndex = 22,
	})
	local infoBandeau = Style.texte(ruban, {
		Name = "Info",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -3),
		Size = UDim2.new(1, -20, 0, 22),
		Text = "",
		TextColor3 = JAUNE,
		contour = 2.5,
		tailleMax = 22,
		ZIndex = 22,
	})

	-- ===== alerte de la victime =====
	local alerte = Instance.new("Frame")
	alerte.Name = "Alerte"
	alerte.Size = UDim2.fromScale(1, 1)
	alerte.BackgroundColor3 = ROUGE_VIF
	alerte.BackgroundTransparency = 1
	alerte.BorderSizePixel = 0
	alerte.Visible = false
	alerte.ZIndex = 30
	alerte.Parent = ecran

	-- bords rouges (dans l'alerte : ils disparaissent avec elle)
	local bordsRouges, listeRouges = creerBords(alerte, "BordsRouges", ROUGE_VIF, 0.2)
	bordsRouges.Visible = true

	-- bloc central : texte géant qui tremble + nom du voleur
	local blocAlerte = Instance.new("Frame")
	blocAlerte.Name = "Bloc"
	blocAlerte.AnchorPoint = Vector2.new(0.5, 0.5)
	blocAlerte.Position = UDim2.fromScale(0.5, 0.6) -- sous les notifications du HUD (milieu-haut)
	blocAlerte.Size = UDim2.fromScale(0.9, 0.3)
	blocAlerte.BackgroundTransparency = 1
	blocAlerte.ZIndex = 31
	blocAlerte.Parent = alerte
	local contrainteAlerte = Instance.new("UISizeConstraint")
	contrainteAlerte.MinSize = Vector2.new(280, 110)
	contrainteAlerte.MaxSize = Vector2.new(1000, 240)
	contrainteAlerte.Parent = blocAlerte

	local texteAlerte = Style.texte(blocAlerte, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.36),
		Size = UDim2.fromScale(1, 0.7),
		Text = "ON TE VOLE !",
		TextColor3 = ROUGE_VIF,
		titre = true,
		contour = 5,
		tailleMax = 120,
		ZIndex = 32,
	})
	local contourTexte = texteAlerte:FindFirstChild("Contour")
	local sousAlerte = Style.texte(blocAlerte, {
		Name = "Voleur",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(0.8, 0.26),
		Text = "",
		TextColor3 = BLANC,
		contour = 3,
		tailleMax = 38,
		ZIndex = 32,
	})
	local contourSous = sousAlerte:FindFirstChild("Contour")

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
	local especePortee = nil

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
			faisceau.Color = ColorSequence.new(OR_HAUT, OR_BAS)
			faisceau.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(0.8, 0.25),
				NumberSequenceKeypoint.new(1, 0.6),
			})
			faisceau.Width0 = 1.6
			faisceau.Width1 = 0.7
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
			especePortee = nomEspece(valeur)
			infoBandeau.Text = ""
			bandeau.Visible = true
			vignette.Visible = true
			Style.pop(bandeau, 1.15)
			assurerGuide()
		elseif not maintenant and porte then
			porte = false
			especePortee = nil
			bandeau.Visible = false
			vignette.Visible = false
			pulsation.Scale = 1
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
		Style.pop(blocAlerte, 1.25)
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
		h.FillColor = ROUGE_VIF
		h.OutlineColor = BLANC
		h.FillTransparency = 0.4
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

	-- ===== animations : pulsation du ruban, tremblement de l'alerte =====
	RunService.Heartbeat:Connect(function()
		local t = horloge()
		if porte then
			local pulse = 0.5 + 0.5 * math.sin(t * 6)
			pulsation.Scale = 1 + 0.05 * pulse
			for _, f in ipairs(bords) do
				f.BackgroundTransparency = 0.35 + 0.4 * pulse
			end
			contour.Transparency = 0
		end
		if alerte.Visible then
			local reste = finAlerte - t
			if reste <= 0 then
				alerte.Visible = false
				texteAlerte.Position = UDim2.fromScale(0.5, 0.36)
				texteAlerte.Rotation = 0
			else
				local clignote = 0.5 + 0.5 * math.sin(t * 16)
				local fondu = 1
				if reste < 0.4 then fondu = reste / 0.4 end
				-- voile rouge léger + bords rouges qui clignotent
				alerte.BackgroundTransparency = 1 - (0.08 + 0.1 * clignote) * fondu
				for _, f in ipairs(listeRouges) do
					f.BackgroundTransparency = 1 - (0.55 + 0.45 * clignote) * fondu
				end
				-- tremblement du texte géant
				local force = 7 * fondu
				local dx = (math.random() * 2 - 1) * force
				local dy = (math.random() * 2 - 1) * force
				texteAlerte.Position = UDim2.new(0.5, dx, 0.36, dy)
				texteAlerte.Rotation = (math.random() * 2 - 1) * 4 * fondu
				texteAlerte.TextTransparency = 1 - fondu
				sousAlerte.TextTransparency = 1 - fondu
				if contourTexte then contourTexte.Transparency = 1 - fondu end
				if contourSous then contourSous.Transparency = 1 - fondu end
			end
		end
	end)

	-- ===== boucle de suivi =====
	while ecran.Parent do
		local ok = pcall(function()
			if porte then
				local hrp, cible = assurerGuide()
				local reste = math.max(0, math.ceil(DELAI_MAX - (horloge() - debutPort)))
				local prefixe = ""
				if especePortee then prefixe = string.upper(especePortee) .. " · " end
				if hrp and cible then
					local d = (cible.Position - hrp.Position)
					local distance = math.floor(Vector3.new(d.X, 0, d.Z).Magnitude + 0.5)
					infoBandeau.Text = prefixe .. "Suis la lumière : " .. distance .. " m · ⏱ " .. reste .. " s"
				else
					infoBandeau.Text = prefixe .. "⏱ " .. reste .. " s avant qu'il ne s'échappe !"
				end
				if reste <= 10 then
					infoBandeau.TextColor3 = BLANC
				else
					infoBandeau.TextColor3 = JAUNE
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
