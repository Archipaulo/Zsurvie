-- Interface/Mobile : boutons tactiles (frapper, collecter) en bas à droite, au-dessus du bouton de saut.
-- Look « simulateur Roblox » : gros boutons ronds en dégradé cernés de noir (Style.bouton), emoji géant,
-- libellé blanc cerné dessous, rebond au toucher. Rien n'est créé sans écran tactile.
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local M = {}

-- tailles de référence (avant UIScale), toujours >= 80 px à l'écran (92 x 0,9 = 83)
local TAILLE_FRAPPER = 116
local TAILLE_COLLECTER = 92
local ECART = 16
local ECHELLE_MIN = 0.9
local ECHELLE_MAX = 1.45
local ANTI_REBOND_FRAPPER = 0.25
local ANTI_REBOND_COLLECTER = 0.5

function M.demarrer(ctx)
	local ok, tactile = pcall(function() return UserInputService.TouchEnabled end)
	if not ok or not tactile then return end

	local Style = ctx.Style
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur

	-- conteneur ancré en bas à droite : l'UIScale le grossit autour de son coin
	local largeur = TAILLE_FRAPPER + ECART + TAILLE_COLLECTER
	local hauteur = TAILLE_FRAPPER
	local zone = Instance.new("Frame")
	zone.Name = "Mobile"
	zone.AnchorPoint = Vector2.new(1, 1)
	zone.Size = UDim2.fromOffset(largeur, hauteur)
	zone.BackgroundTransparency = 1
	zone.Parent = ctx.gui
	local echelle = Instance.new("UIScale")
	echelle.Parent = zone

	local function fabriquerBouton(nom, taille, couleur, symbole, legende, position, rappel)
		local b, libelle = Style.bouton(zone, {
			Name = nom,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = UDim2.fromOffset(taille, taille),
			couleur = couleur,
			texte = symbole,
			rayon = math.floor(taille / 2),
			tailleMax = 100,
		})
		-- bordure plus épaisse pour un bouton de cette taille
		local bordure = b:FindFirstChild("Bordure")
		if bordure then bordure.Thickness = 4 end
		-- l'emoji géant en haut, le libellé cerné dessous
		libelle.Name = "Symbole"
		libelle.AnchorPoint = Vector2.new(0.5, 0.5)
		libelle.Position = UDim2.fromScale(0.5, 0.42)
		libelle.Size = UDim2.fromScale(0.62, 0.58)
		local texte = Style.texte(b, {
			Name = "Legende",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -8),
			Size = UDim2.fromScale(0.86, 0.24),
			Text = legende,
			ZIndex = 2,
			contour = 3,
			tailleMax = 24,
		})
		texte.Font = Style.policeTitre

		-- rebond au toucher : s'écrase sous le doigt, rebondit en « pop » au relâcher
		local ressort = b:FindFirstChild("Echelle")
		local infos = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local function vers(s)
			if ressort then
				pcall(function() TweenService:Create(ressort, infos, { Scale = s }):Play() end)
			end
		end
		b.InputBegan:Connect(function(entree)
			if entree.UserInputType == Enum.UserInputType.Touch or entree.UserInputType == Enum.UserInputType.MouseButton1 then
				vers(0.88)
			end
		end)
		b.InputEnded:Connect(function(entree)
			if entree.UserInputType == Enum.UserInputType.Touch or entree.UserInputType == Enum.UserInputType.MouseButton1 then
				vers(1)
			end
		end)
		b.Activated:Connect(function()
			pcall(Style.pop, libelle, 1.2)
			local okRappel = pcall(rappel)
			if not okRappel then vers(1) end
		end)
		return b
	end

	-- gros bouton rond rouge de frappe, dans le coin
	local dernierCoup = 0
	local boutonFrapper = fabriquerBouton("Frapper", TAILLE_FRAPPER, "rouge", "🏏", "FRAPPER",
		UDim2.new(1, -TAILLE_FRAPPER / 2, 1, -TAILLE_FRAPPER / 2),
		function()
			local maintenant = os.clock()
			if maintenant - dernierCoup < ANTI_REBOND_FRAPPER then return end
			dernierCoup = maintenant
			Bus.emettre("Frapper")
		end)

	-- bouton rond vert de collecte, à gauche du bouton de frappe (loin du joystick)
	local derniereCollecte = 0
	local boutonCollecter = fabriquerBouton("Collecter", TAILLE_COLLECTER, "vert", "💰", "COLLECTER",
		UDim2.new(1, -(TAILLE_FRAPPER + ECART + TAILLE_COLLECTER / 2), 1, -TAILLE_COLLECTER / 2),
		function()
			local maintenant = os.clock()
			if maintenant - derniereCollecte < ANTI_REBOND_COLLECTER then return end
			derniereCollecte = maintenant
			Bus.emettre("Son", "clic")
			if Reseau and Reseau.Collecter then
				Reseau.Collecter:FireServer()
			end
		end)

	-- adaptation à la taille de l'écran : échelle et place au-dessus du bouton de saut
	local function adapter()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local vue = camera.ViewportSize
		local cote = math.min(vue.X, vue.Y)
		if cote <= 0 then return end
		local e = math.clamp(cote / 420, ECHELLE_MIN, ECHELLE_MAX)
		echelle.Scale = e
		-- le bouton de saut Roblox monte à 90 px du bas sur petit écran, à 210 px sinon (120 px posé à 1,75 x sa taille)
		local margeDroite = 16
		local margeBas = 104
		if cote > 500 then
			margeDroite = 28
			margeBas = 222
		end
		zone.Position = UDim2.new(1, -margeDroite, 1, -margeBas)
	end

	local connexionVue
	local function suivreCamera()
		if connexionVue then
			connexionVue:Disconnect()
			connexionVue = nil
		end
		local camera = workspace.CurrentCamera
		if camera then
			connexionVue = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				pcall(adapter)
			end)
		end
		pcall(adapter)
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(suivreCamera)
	suivreCamera()

	-- état visuel : frappe grise quand étourdi, collecte grise et estompée sans Base
	local function rafraichir()
		local etourdi = joueur:GetAttribute("Etourdi") == true
		if etourdi then
			Style.couleurBouton(boutonFrapper, "gris")
		else
			Style.couleurBouton(boutonFrapper, "rouge")
		end
		local base = tonumber(joueur:GetAttribute("Base"))
		local symbole = boutonCollecter:FindFirstChild("Symbole")
		if base and base > 0 then
			Style.couleurBouton(boutonCollecter, "vert")
			if symbole then symbole.TextTransparency = 0 end
		else
			Style.couleurBouton(boutonCollecter, "gris")
			if symbole then symbole.TextTransparency = 0.35 end
		end
	end
	joueur:GetAttributeChangedSignal("Etourdi"):Connect(function() pcall(rafraichir) end)
	joueur:GetAttributeChangedSignal("Base"):Connect(function() pcall(rafraichir) end)
	pcall(rafraichir)

	-- boutons cachés quand le personnage n'est pas là (mort, réapparition), qui repoppent au retour
	local function surPersonnage(perso)
		zone.Visible = true
		-- le pop se fait sur l'emoji (le bouton a déjà son UIScale « Echelle » pour le rebond)
		local s1 = boutonFrapper:FindFirstChild("Symbole")
		local s2 = boutonCollecter:FindFirstChild("Symbole")
		if s1 then pcall(Style.pop, s1) end
		if s2 then pcall(Style.pop, s2) end
		local humanoid = perso:FindFirstChildOfClass("Humanoid") or perso:WaitForChild("Humanoid", 10)
		if humanoid then
			humanoid.Died:Connect(function()
				zone.Visible = false
			end)
		end
	end
	joueur.CharacterAdded:Connect(function(perso) pcall(surPersonnage, perso) end)
	if joueur.Character then
		task.spawn(function() pcall(surPersonnage, joueur.Character) end)
	end
end

return M
