-- Interface/Mobile : commandes tactiles (tir assisté maintenu, Réparer, Établi)
-- et mise à l'échelle de l'écran. Ne fait rien sur ordinateur.
local M = {}

-- tailles minimales et marges, en pixels réels à l'écran
local TACTILE_MIN = 64
local DIAMETRE_TIR = 104
local DIAMETRE_ACTION = 72
local ECART = 14
-- rythme d'envoi des demandes de tir au Blaster (qui garde sa propre cadence)
local INTERVALLE_TIR_DEFAUT = 0.15
-- part de l'écran réservée au joystick, à gauche
local ZONE_JOYSTICK = 0.45

local function nombre(v, defaut)
	local n = tonumber(v)
	if n and n > 0 then return n end
	return defaut
end

function M.demarrer(ctx)
	local okUis, UserInputService = pcall(function() return game:GetService("UserInputService") end)
	if not okUis or not UserInputService then return end
	if not UserInputService.TouchEnabled then return end

	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Equilibrage = ctx.Equilibrage or {}
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local joueur = ctx.joueur
	local gui = ctx.gui
	if not gui or not joueur or not Bus then return end

	-- chiffres de jeu lus dans l'équilibrage
	local intervalleTir = INTERVALLE_TIR_DEFAUT
	if type(Equilibrage.mobile) == "table" then
		intervalleTir = nombre(Equilibrage.mobile.intervalleTirAuto, intervalleTir)
	end
	local delaiReparation = 0.4
	if type(Equilibrage.maison) == "table" then
		delaiReparation = nombre(Equilibrage.maison.delaiReparation, delaiReparation)
	end

	local function son(nom)
		Bus.emettre("Son", nom)
	end

	-- ===== mise à l'échelle de tout l'écran =====
	local echelle = gui:FindFirstChild("EchelleMobile")
	if not echelle then
		echelle = Instance.new("UIScale")
		echelle.Name = "EchelleMobile"
		echelle.Parent = gui
	end

	-- ===== conteneur des commandes (moitié droite, hors joystick) =====
	local commandes = Instance.new("Frame")
	commandes.Name = "CommandesMobile"
	commandes.BackgroundTransparency = 1
	commandes.AnchorPoint = Vector2.new(1, 1)
	commandes.Position = UDim2.new(1, 0, 1, 0)
	commandes.Size = UDim2.new(1 - ZONE_JOYSTICK, 0, 1, 0)
	commandes.ZIndex = 5
	commandes.Visible = false
	commandes.Parent = gui

	local function contour(b, epaisseur)
		local c = Instance.new("UIStroke")
		c.Color = Charte.encre
		c.Thickness = epaisseur
		c.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		c.Parent = b
		return c
	end

	local function rond(b)
		local coin = b:FindFirstChildOfClass("UICorner")
		if not coin then
			coin = Instance.new("UICorner")
			coin.Parent = b
		end
		coin.CornerRadius = UDim.new(0.5, 0)
	end

	local boutonTir = Outils.bouton(commandes, {
		Name = "Tir",
		AnchorPoint = Vector2.new(1, 1),
		Text = "🔫",
		BackgroundColor3 = Charte.alerte,
		AutoButtonColor = false,
		ZIndex = 6,
	})
	rond(boutonTir)
	local contourTir = contour(boutonTir, 3)

	local boutonReparer = Outils.bouton(commandes, {
		Name = "Reparer",
		AnchorPoint = Vector2.new(1, 1),
		Text = "🔧",
		BackgroundColor3 = Charte.prairie,
		AutoButtonColor = false,
		ZIndex = 6,
	})
	rond(boutonReparer)
	contour(boutonReparer, 2)

	local boutonEtabli = Outils.bouton(commandes, {
		Name = "Etabli",
		AnchorPoint = Vector2.new(1, 1),
		Text = "🛠️",
		BackgroundColor3 = Charte.toit,
		AutoButtonColor = false,
		ZIndex = 6,
	}, function()
		son("clic")
		Bus.emettre("OuvrirPanneau", "Etabli")
	end)
	rond(boutonEtabli)
	contour(boutonEtabli, 2)

	-- ===== disposition selon la taille de l'écran =====
	local function tailleEcran()
		local camera = workspace.CurrentCamera
		if camera then
			local v = camera.ViewportSize
			if v.X > 1 and v.Y > 1 then return v end
		end
		return Vector2.new(1280, 720)
	end

	local function disposer()
		local v = tailleEcran()
		local petit = math.min(v.X, v.Y)
		-- référence : un écran de 720 px de haut garde l'échelle 1
		local e = math.max(0.6, math.min(petit / 720, 1.25))
		echelle.Scale = e

		-- tout est calculé en pixels réels puis ramené dans l'espace mis à l'échelle
		local dTir = math.max(DIAMETRE_TIR, TACTILE_MIN)
		local dAction = math.max(DIAMETRE_ACTION, TACTILE_MIN)
		if petit < 500 then
			dTir = math.max(88, TACTILE_MIN)
			dAction = math.max(66, TACTILE_MIN)
		end
		-- le bouton de saut de Roblox occupe le coin bas-droit : on se place au-dessus
		local basSaut = 225
		if petit <= 500 then basSaut = 165 end
		local margeDroite = 24

		local function px(n)
			return n / e
		end

		boutonTir.Size = UDim2.new(0, px(dTir), 0, px(dTir))
		boutonTir.Position = UDim2.new(1, -px(margeDroite), 1, -px(basSaut))

		-- Réparer à gauche du tir, Établi au-dessus de Réparer
		local xAction = margeDroite + dTir + ECART
		boutonReparer.Size = UDim2.new(0, px(dAction), 0, px(dAction))
		boutonReparer.Position = UDim2.new(1, -px(xAction), 1, -px(basSaut))
		boutonEtabli.Size = UDim2.new(0, px(dAction), 0, px(dAction))
		boutonEtabli.Position = UDim2.new(1, -px(xAction), 1, -px(basSaut + dAction + ECART))
	end

	local liaisonCamera = nil
	local function suivreCamera()
		if liaisonCamera then
			liaisonCamera:Disconnect()
			liaisonCamera = nil
		end
		local camera = workspace.CurrentCamera
		if camera then
			liaisonCamera = camera:GetPropertyChangedSignal("ViewportSize"):Connect(disposer)
		end
		disposer()
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(suivreCamera)
	suivreCamera()

	-- ===== appui maintenu : répète une action tant que le doigt reste posé =====
	local function maintenir(bouton, intervalle, action, surDebut, surFin)
		local entreeActive = nil
		local jeton = 0

		local function relacher()
			if entreeActive == nil then return end
			entreeActive = nil
			jeton = jeton + 1
			if surFin then surFin() end
		end

		bouton.InputBegan:Connect(function(entree)
			local genre = entree.UserInputType
			if genre ~= Enum.UserInputType.Touch and genre ~= Enum.UserInputType.MouseButton1 then return end
			if entreeActive ~= nil then return end
			entreeActive = entree
			jeton = jeton + 1
			local monJeton = jeton
			if surDebut then surDebut() end
			task.spawn(function()
				while jeton == monJeton and commandes.Visible do
					local ok, err = pcall(action)
					if not ok then
						warn("[Zsurvie] Mobile : " .. tostring(err))
						break
					end
					task.wait(intervalle)
				end
				if jeton == monJeton then relacher() end
			end)
		end)

		UserInputService.InputEnded:Connect(function(entree)
			if entree == entreeActive then relacher() end
		end)
		bouton.InputEnded:Connect(function(entree)
			if entree == entreeActive then relacher() end
		end)

		return relacher
	end

	-- tir assisté : Interface/Blaster vise le Zbire le plus proche
	local relacherTir = maintenir(boutonTir, intervalleTir, function()
		Bus.emettre("TirAuto")
	end, function()
		boutonTir.BackgroundColor3 = Charte.ombre(Charte.alerte)
		contourTir.Color = Charte.dore
	end, function()
		boutonTir.BackgroundColor3 = Charte.alerte
		contourTir.Color = Charte.encre
	end)

	-- réparation : un envoi par délai de réparation tant que le doigt reste posé
	local derniereReparation = 0
	local relacherReparer = maintenir(boutonReparer, delaiReparation, function()
		local maintenant = os.clock()
		if maintenant - derniereReparation < delaiReparation then return end
		derniereReparation = maintenant
		local ev = Reseau.Reparer
		if ev then
			ev:FireServer()
			son("clic")
		end
	end, function()
		boutonReparer.BackgroundColor3 = Charte.ombre(Charte.prairie)
	end, function()
		boutonReparer.BackgroundColor3 = Charte.prairie
	end)

	-- ===== visibilité : seulement pendant une run =====
	local function majVisibilite()
		local visible = joueur:GetAttribute("EnRun") == true
		commandes.Visible = visible
		if not visible then
			relacherTir()
			relacherReparer()
		end
	end
	joueur:GetAttributeChangedSignal("EnRun"):Connect(majVisibilite)
	majVisibilite()
end

return M
