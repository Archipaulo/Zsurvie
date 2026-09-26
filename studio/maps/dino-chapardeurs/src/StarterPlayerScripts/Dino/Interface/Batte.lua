-- Interface/Batte : frappe à la batte (clic, touche F, bouton mobile), gros rond de recharge en bas au centre, « BONK ! » géant à la frappe,
-- et effets locaux de l'étourdissement (étoiles 💫 cernées au-dessus de la tête, léger flou).
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local M = {}

local NOM_OUTIL = "Batte"
local MARGE_RECHARGE = 0.05 -- petite marge pour ne jamais devancer la recharge du serveur
local DUREE_ELAN = 0.09
local DUREE_RETOUR = 0.22
local ANGLE_ELAN = 1.5
local FLOU = 8
local NB_ETOILES = 3

function M.demarrer(ctx)
	local Style = ctx.Style
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local E = ctx.Equilibrage
	local joueur = ctx.joueur

	local REGLES = E.batte or {}
	local RECHARGE = tonumber(REGLES.recharge) or 1.2
	local OR = (E.boutique and E.boutique.BatteOr) or {}
	local FACTEUR_OR = tonumber(OR.recharge) or 1

	local finRecharge = 0
	local dureeRecharge = RECHARGE
	local gripsOrigine = setmetatable({}, { __mode = "k" }) -- [outil] = Grip d'origine
	local enElan = setmetatable({}, { __mode = "k" }) -- [outil] = true pendant l'animation
	local branches = setmetatable({}, { __mode = "k" }) -- [outil] = true si déjà branché

	-- ===== utilitaires =====
	local function humanoidVivant()
		local perso = joueur.Character
		if not perso then return nil, nil end
		local humanoid = perso:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return nil, nil end
		return perso, humanoid
	end

	local function batteEquipee()
		local perso = joueur.Character
		if not perso then return nil end
		local outil = perso:FindFirstChild(NOM_OUTIL)
		if outil and outil:IsA("Tool") then return outil end
		return nil
	end

	local function batteDuSac()
		local sac = joueur:FindFirstChildOfClass("Backpack")
		if not sac then return nil end
		local outil = sac:FindFirstChild(NOM_OUTIL)
		if outil and outil:IsA("Tool") then return outil end
		return nil
	end

	local function rechargeActuelle()
		local r = RECHARGE
		if joueur:GetAttribute("Objet_BatteOr") == true then r = r * FACTEUR_OR end
		return r
	end

	-- ===== animation locale : la batte bascule vers l'avant puis revient =====
	local function animerElan(outil)
		if enElan[outil] then return end
		local origine = gripsOrigine[outil]
		if not origine then
			origine = outil.Grip
			gripsOrigine[outil] = origine
		end
		enElan[outil] = true
		local anim = coroutine.wrap(function()
			local debut = os.clock()
			local total = DUREE_ELAN + DUREE_RETOUR
			while outil.Parent do
				local t = os.clock() - debut
				if t >= total then break end
				local angle
				if t < DUREE_ELAN then
					angle = ANGLE_ELAN * (t / DUREE_ELAN)
				else
					local u = (t - DUREE_ELAN) / DUREE_RETOUR
					angle = ANGLE_ELAN * (1 - u * u)
				end
				pcall(function() outil.Grip = origine * CFrame.Angles(angle, 0, 0) end)
				RunService.RenderStepped:Wait()
			end
			pcall(function() outil.Grip = origine end)
			enElan[outil] = nil
		end)
		local ok = pcall(anim)
		if not ok then
			enElan[outil] = nil
			pcall(function() outil.Grip = origine end)
		end
	end

	-- ===== « BONK ! » géant cerné qui pop au moment de la frappe =====
	local bonkActuel = nil
	local function montrerBonk()
		if bonkActuel then
			pcall(function() bonkActuel:Destroy() end)
			bonkActuel = nil
		end
		local bonk = Style.texte(ctx.gui, {
			Name = "Bonk",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5 + (math.random() - 0.5) * 0.06, 0, 0.36, 0),
			Size = UDim2.new(0.5, 0, 0.14, 0),
			Rotation = math.random(-10, 10),
			Text = "BONK !",
			titre = true,
			contour = 5,
			tailleMax = 96,
			ZIndex = 20,
		})
		Style.degrade(bonk, Style.boutons.jaune[1], Style.boutons.orange[2])
		local contrainte = Instance.new("UISizeConstraint")
		contrainte.MaxSize = Vector2.new(520, 110)
		contrainte.MinSize = Vector2.new(220, 56)
		contrainte.Parent = bonk
		bonkActuel = bonk
		Style.pop(bonk, 1.3)
		task.delay(0.35, function()
			if not bonk.Parent then return end
			local infos = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			pcall(function()
				TweenService:Create(bonk, infos, {
					TextTransparency = 1,
					Position = bonk.Position - UDim2.new(0, 0, 0.05, 0),
				}):Play()
				local trait = bonk:FindFirstChild("Contour")
				if trait then TweenService:Create(trait, infos, { Transparency = 1 }):Play() end
			end)
			task.delay(0.4, function()
				if bonkActuel == bonk then bonkActuel = nil end
				pcall(function() bonk:Destroy() end)
			end)
		end)
	end

	-- ===== frappe =====
	local function frapper(outil)
		local _, humanoid = humanoidVivant()
		if not humanoid then return end
		if joueur:GetAttribute("Etourdi") == true then return end
		local maintenant = os.clock()
		if maintenant < finRecharge then return end
		dureeRecharge = rechargeActuelle() + MARGE_RECHARGE
		finRecharge = maintenant + dureeRecharge
		pcall(function() Reseau.Frapper:FireServer() end)
		Bus.emettre("Son", "frappe")
		pcall(montrerBonk)
		if outil then
			task.spawn(animerElan, outil)
		end
	end

	-- touche F ou bouton mobile : équipe la batte si besoin, puis frappe
	local function frapperAuClavier()
		local _, humanoid = humanoidVivant()
		if not humanoid then return end
		local outil = batteEquipee()
		if not outil then
			outil = batteDuSac()
			if not outil then return end
			local ok = pcall(function() humanoid:EquipTool(outil) end)
			if not ok then return end
		end
		frapper(outil)
	end

	local function brancherOutil(outil)
		if branches[outil] then return end
		if not outil:IsA("Tool") or outil.Name ~= NOM_OUTIL then return end
		branches[outil] = true
		gripsOrigine[outil] = outil.Grip
		outil.Activated:Connect(function()
			frapper(outil)
		end)
	end

	local function surPersonnage(perso)
		for _, enfant in ipairs(perso:GetChildren()) do
			pcall(brancherOutil, enfant)
		end
		perso.ChildAdded:Connect(function(enfant)
			pcall(brancherOutil, enfant)
		end)
	end

	UserInputService.InputBegan:Connect(function(entree, traite)
		if traite then return end
		if entree.KeyCode == Enum.KeyCode.F then
			frapperAuClavier()
		end
	end)
	Bus.ecouter("Frapper", frapperAuClavier)

	-- ===== gros rond de recharge en bas au centre, au-dessus du bouton Collecter =====
	-- le bouton Collecter (HUD) occupe le bas de l'écran jusqu'à 178 px du bord : le rond reste au-dessus.
	local TAILLE_ROND = 76
	local anneau = Instance.new("Frame")
	anneau.Name = "RechargeBatte"
	anneau.AnchorPoint = Vector2.new(0.5, 1)
	anneau.Position = UDim2.new(0.5, 0, 1, -192)
	anneau.Size = UDim2.fromOffset(TAILLE_ROND, TAILLE_ROND)
	anneau.BackgroundColor3 = Style.couleurs.fond
	anneau.BackgroundTransparency = 0.1
	anneau.BorderSizePixel = 0
	anneau.Visible = false
	anneau.Parent = ctx.gui
	Style.coins(anneau, TAILLE_ROND)
	local trait = Style.bordure(anneau, 4)

	-- disque intérieur en dégradé qui grandit pendant la recharge (jaune), vert quand c'est prêt
	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.AnchorPoint = Vector2.new(0.5, 0.5)
	remplissage.Position = UDim2.fromScale(0.5, 0.5)
	remplissage.Size = UDim2.fromScale(0, 0)
	remplissage.BackgroundColor3 = Color3.new(1, 1, 1)
	remplissage.BorderSizePixel = 0
	remplissage.ZIndex = 2
	remplissage.Parent = anneau
	Style.coins(remplissage, TAILLE_ROND)
	local degradeRemplissage = Style.degrade(remplissage, Style.boutons.jaune[1], Style.boutons.jaune[2])

	local compteur = Style.texte(anneau, {
		Name = "Compteur",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.78, 0.6),
		Text = "F",
		titre = true,
		contour = 3,
		tailleMax = 40,
		ZIndex = 3,
	})

	-- petite légende « BATTE » sous le rond
	local legende = Style.texte(anneau, {
		Name = "Legende",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1.3, 0, 0, 20),
		Text = "🏏 BATTE",
		contour = 2.5,
		tailleMax = 18,
		ZIndex = 4,
	})

	local tactile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local etatRond = nil -- "recharge" ou "pret" : pour ne refaire les réglages qu'au changement

	RunService.RenderStepped:Connect(function()
		local reste = finRecharge - os.clock()
		local equipee = batteEquipee() ~= nil
		if reste > 0 then
			anneau.Visible = true
			local p = 1 - reste / math.max(dureeRecharge, 0.01)
			if p < 0 then p = 0 end
			remplissage.Size = UDim2.fromScale(p, p)
			if etatRond ~= "recharge" then
				etatRond = "recharge"
				degradeRemplissage.Color = ColorSequence.new(Style.boutons.jaune[1], Style.boutons.jaune[2])
				compteur.TextColor3 = Style.couleurs.revenu
				trait.Color = Style.couleurs.contour
			end
			local texte = string.format("%.1f", reste)
			compteur.Text = string.gsub(texte, "%.", ",")
		elseif equipee then
			anneau.Visible = true
			remplissage.Size = UDim2.fromScale(1, 1)
			if etatRond ~= "pret" then
				etatRond = "pret"
				degradeRemplissage.Color = ColorSequence.new(Style.boutons.vert[1], Style.boutons.vert[2])
				compteur.TextColor3 = Style.couleurs.texte
				trait.Color = Style.couleurs.contour
				Style.pop(anneau, 1.15)
			end
			if tactile then
				compteur.Text = "✔"
			else
				compteur.Text = "F"
			end
		else
			anneau.Visible = false
			etatRond = nil
		end
	end)

	-- ===== étourdissement : étoiles et flou =====
	local etoiles = nil
	local flou = nil
	local connexionEtoiles = nil

	local function retirerEtoiles()
		if connexionEtoiles then
			connexionEtoiles:Disconnect()
			connexionEtoiles = nil
		end
		if etoiles then
			pcall(function() etoiles:Destroy() end)
			etoiles = nil
		end
	end

	local function retirerFlou()
		local ancien = flou
		flou = nil
		if not ancien then return end
		local ok = pcall(function()
			local tw = TweenService:Create(ancien, TweenInfo.new(0.3), { Size = 0 })
			tw:Play()
			tw.Completed:Connect(function()
				pcall(function() ancien:Destroy() end)
			end)
		end)
		if not ok then
			pcall(function() ancien:Destroy() end)
		end
	end

	local function montrerEtoiles()
		retirerEtoiles()
		local perso = joueur.Character
		if not perso then return end
		local tete = perso:FindFirstChild("Head")
		if not tete then return end
		local bb = Instance.new("BillboardGui")
		bb.Name = "EtoilesEtourdi"
		bb.Adornee = tete
		bb.Size = UDim2.new(5, 0, 2, 0)
		bb.StudsOffset = Vector3.new(0, 2.4, 0)
		bb.AlwaysOnTop = false
		bb.LightInfluence = 0
		bb.ResetOnSpawn = false
		local liste = {}
		local contours = {}
		for i = 1, NB_ETOILES do
			local etoile = Style.texte(bb, {
				Name = "Etoile" .. i,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.3, 0.7),
				Text = "💫",
				contour = 3,
			})
			table.insert(liste, etoile)
			table.insert(contours, etoile:FindFirstChild("Contour"))
		end
		-- dans PlayerGui : un BillboardGui n'est pas rendu à l'intérieur d'un ScreenGui
		bb.Parent = ctx.gui.Parent
		etoiles = bb
		-- les étoiles tournent en ellipse autour de la tête
		local debut = os.clock()
		connexionEtoiles = RunService.RenderStepped:Connect(function()
			local t = (os.clock() - debut) * 4
			for i, etoile in ipairs(liste) do
				local a = t + (i - 1) * (2 * math.pi / NB_ETOILES)
				local profondeur = (math.sin(a) + 1) / 2
				etoile.Position = UDim2.fromScale(0.5 + 0.38 * math.cos(a), 0.5 + 0.18 * math.sin(a))
				local transparence = 0.35 - 0.35 * profondeur
				etoile.TextTransparency = transparence
				if contours[i] then contours[i].Transparency = transparence end
				etoile.ZIndex = 1 + math.floor(profondeur * 2)
			end
		end)
	end

	local function montrerFlou()
		if flou then return end
		local camera = workspace.CurrentCamera
		if not camera then return end
		local b = Instance.new("BlurEffect")
		b.Name = "FlouEtourdi"
		b.Size = 0
		b.Parent = camera
		flou = b
		pcall(function()
			TweenService:Create(b, TweenInfo.new(0.15), { Size = FLOU }):Play()
		end)
	end

	local function majEtourdi()
		if joueur:GetAttribute("Etourdi") == true then
			montrerEtoiles()
			montrerFlou()
		else
			retirerEtoiles()
			retirerFlou()
		end
	end

	joueur:GetAttributeChangedSignal("Etourdi"):Connect(function()
		local ok = pcall(majEtourdi)
		if not ok then
			retirerEtoiles()
			retirerFlou()
		end
	end)

	-- ===== personnage =====
	joueur.CharacterAdded:Connect(function(perso)
		-- nouvelle vie : plus d'effets d'étourdissement ni de recharge en cours
		retirerEtoiles()
		retirerFlou()
		finRecharge = 0
		pcall(surPersonnage, perso)
	end)
	if joueur.Character then
		pcall(surPersonnage, joueur.Character)
	end
	pcall(majEtourdi)
end

return M
