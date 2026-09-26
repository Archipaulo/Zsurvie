-- Interface/Batte : frappe à la batte (clic, touche F, bouton mobile), anneau de recharge près du réticule,
-- et effets locaux de l'étourdissement (étoiles au-dessus de la tête, léger flou).
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
	local Charte = ctx.Charte
	local Outils = ctx.Outils
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

	-- ===== anneau de recharge sous le réticule =====
	local anneau = Instance.new("Frame")
	anneau.Name = "RechargeBatte"
	anneau.AnchorPoint = Vector2.new(0.5, 0.5)
	anneau.Position = UDim2.new(0.5, 0, 0.5, 40)
	anneau.Size = UDim2.new(0, 34, 0, 34)
	anneau.BackgroundColor3 = Charte.encre
	anneau.BackgroundTransparency = 0.45
	anneau.BorderSizePixel = 0
	anneau.Visible = false
	anneau.Parent = ctx.gui
	local rond = Instance.new("UICorner")
	rond.CornerRadius = UDim.new(1, 0)
	rond.Parent = anneau
	local trait = Instance.new("UIStroke")
	trait.Thickness = 3
	trait.Color = Charte.dore
	trait.Parent = anneau

	-- disque intérieur qui grandit pendant la recharge
	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.AnchorPoint = Vector2.new(0.5, 0.5)
	remplissage.Position = UDim2.fromScale(0.5, 0.5)
	remplissage.Size = UDim2.fromScale(0, 0)
	remplissage.BackgroundColor3 = Charte.dore
	remplissage.BackgroundTransparency = 0.35
	remplissage.BorderSizePixel = 0
	remplissage.Parent = anneau
	local rond2 = Instance.new("UICorner")
	rond2.CornerRadius = UDim.new(1, 0)
	rond2.Parent = remplissage

	local compteur = Outils.etiquette(anneau, {
		Name = "Compteur",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.55),
		Font = Charte.police,
		TextColor3 = Charte.creme,
		Text = "F",
		ZIndex = 3,
	})

	local tactile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	RunService.RenderStepped:Connect(function()
		local reste = finRecharge - os.clock()
		local equipee = batteEquipee() ~= nil
		if reste > 0 then
			anneau.Visible = true
			local p = 1 - reste / math.max(dureeRecharge, 0.01)
			if p < 0 then p = 0 end
			remplissage.Size = UDim2.fromScale(p, p)
			remplissage.Visible = true
			trait.Color = Charte.pierre
			local texte = string.format("%.1f", reste)
			compteur.Text = string.gsub(texte, "%.", ",")
		elseif equipee then
			anneau.Visible = true
			remplissage.Visible = false
			trait.Color = Charte.dore
			if tactile then
				compteur.Text = ""
			else
				compteur.Text = "F"
			end
		else
			anneau.Visible = false
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
		bb.Size = UDim2.new(4, 0, 1.6, 0)
		bb.StudsOffset = Vector3.new(0, 2.2, 0)
		bb.AlwaysOnTop = false
		bb.ResetOnSpawn = false
		local liste = {}
		for i = 1, NB_ETOILES do
			local etoile = Outils.etiquette(bb, {
				Name = "Etoile" .. i,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.3, 0.75),
				Text = "★",
				TextColor3 = Charte.dore,
			})
			local contour = Instance.new("UIStroke")
			contour.Color = Charte.ombre(Charte.bois)
			contour.Thickness = 1.5
			contour.Parent = etoile
			table.insert(liste, etoile)
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
				etoile.TextTransparency = 0.35 - 0.35 * profondeur
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
