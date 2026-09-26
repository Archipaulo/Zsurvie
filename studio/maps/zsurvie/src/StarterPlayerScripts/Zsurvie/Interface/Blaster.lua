-- Interface/Blaster : tir du joueur (clic ou toucher, maintien = tir automatique), tir assisté et réticule.
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local M = {}

local DISTANCE_RAYON = 300 -- longueur du rayon de visée
local PAS_BOUCLE = 0.03 -- pas d'attente de la boucle de tir automatique
local TAILLE_RETICULE = 22

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Charte = ctx.Charte
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local horde = ctx.horde

	local remoteTirer = Reseau and Reseau.Tirer
	if not remoteTirer then
		warn("[Zsurvie] Interface Blaster : RemoteEvent « Tirer » introuvable")
		return
	end

	local dernierTir = 0
	local entreeActive = nil -- InputObject du clic ou du toucher maintenu
	local jetonBoucle = 0

	-- niveau d'amélioration (nombre valide, 0 sinon)
	local function niveau(nom)
		local v = joueur:GetAttribute("Niv_" .. nom)
		if type(v) ~= "number" or v ~= v or v < 0 then return 0 end
		return v
	end

	local function effetAmelioration(nom)
		local a = E.ameliorations and E.ameliorations[nom]
		if a and type(a.effet) == "number" then return a.effet end
		return 0
	end

	-- intervalle minimal entre deux tirs (même formule que le serveur)
	local function intervalle()
		local cadence = E.blaster.cadence * (1 + niveau("Cadence") * effetAmelioration("Cadence"))
		if cadence <= 0 then return nil end
		return 1 / cadence
	end

	local function portee()
		return E.blaster.portee + niveau("Portee") * effetAmelioration("Portee")
	end

	local function peutTirer()
		if joueur:GetAttribute("EnRun") ~= true then return false end
		local phase = Etat and Etat:GetAttribute("Phase")
		return phase == "Horde" or phase == "Repit"
	end

	local function racinePerso()
		local perso = joueur.Character
		if not perso then return nil, nil end
		local hrp = perso:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return perso, hrp end
		return perso, nil
	end

	-- Zbire (Model enfant direct de la horde) auquel appartient une part
	local function zbireDe(instance)
		if not horde then return nil end
		local courant = instance
		while courant and courant ~= horde do
			if courant.Parent == horde then
				if courant:IsA("Model") then return courant end
				return nil
			end
			courant = courant.Parent
		end
		return nil
	end

	local function pivotDe(modele)
		local ok, cf = pcall(function() return modele:GetPivot() end)
		if ok and cf then return cf.Position end
		return nil
	end

	-- envoie le tir si la cadence le permet ; renvoie true si tiré
	local function envoyerTir(cible, idZbire)
		if not peutTirer() then return false end
		local attente = intervalle()
		if not attente then return false end
		local maintenant = os.clock()
		if maintenant - dernierTir < attente then return false end
		local _, hrp = racinePerso()
		if not hrp then return false end
		dernierTir = maintenant
		local origine = hrp.Position
		pcall(function() remoteTirer:FireServer(cible, idZbire) end)
		Bus.emettre("TirLocal", origine, cible)
		Bus.emettre("Son", "tir")
		return true
	end

	local function parametresRayon()
		local params = RaycastParams.new()
		local ok = pcall(function() params.FilterType = Enum.RaycastFilterType.Exclude end)
		if not ok then
			pcall(function() params.FilterType = Enum.RaycastFilterType.Blacklist end)
		end
		local perso = joueur.Character
		if perso then params.FilterDescendantsInstances = { perso } end
		return params
	end

	-- position écran (viewport) de l'entrée en cours
	local function pointEcran(entree)
		if entree and entree.UserInputType == Enum.UserInputType.Touch then
			local x, y = entree.Position.X, entree.Position.Y
			local ok, encart = pcall(function() return GuiService:GetGuiInset() end)
			if ok and encart then
				x = x + encart.X
				y = y + encart.Y
			end
			return x, y
		end
		local souris = UserInputService:GetMouseLocation()
		return souris.X, souris.Y
	end

	-- tir vers un point de l'écran
	local function tirerVers(x, y)
		if not peutTirer() then return end
		local attente = intervalle()
		if not attente or os.clock() - dernierTir < attente then return end
		local camera = workspace.CurrentCamera
		if not camera then return end
		local ok, rayon = pcall(function() return camera:ViewportPointToRay(x, y) end)
		if not ok or not rayon then return end
		local resultat = workspace:Raycast(rayon.Origin, rayon.Direction * DISTANCE_RAYON, parametresRayon())
		local cible = nil
		local idZbire = nil
		if resultat then
			local modele = zbireDe(resultat.Instance)
			if modele then
				local id = modele:GetAttribute("Id")
				if type(id) == "string" then idZbire = id end
				cible = pivotDe(modele)
			end
			if not cible then cible = resultat.Position end
		else
			cible = rayon.Origin + rayon.Direction * DISTANCE_RAYON
		end
		envoyerTir(cible, idZbire)
	end

	-- boucle de tir tant que l'entrée reste enfoncée
	local function lancerBoucle(entree)
		jetonBoucle = jetonBoucle + 1
		local monJeton = jetonBoucle
		entreeActive = entree
		task.spawn(function()
			while jetonBoucle == monJeton and entreeActive == entree do
				local x, y = pointEcran(entree)
				tirerVers(x, y)
				task.wait(PAS_BOUCLE)
			end
		end)
	end

	UserInputService.InputBegan:Connect(function(entree, traite)
		if traite then return end
		local genre = entree.UserInputType
		if genre ~= Enum.UserInputType.MouseButton1 and genre ~= Enum.UserInputType.Touch then return end
		if not peutTirer() then return end
		lancerBoucle(entree)
	end)

	UserInputService.InputEnded:Connect(function(entree)
		if entree == entreeActive or (entree.UserInputType == Enum.UserInputType.MouseButton1 and entreeActive and entreeActive.UserInputType == Enum.UserInputType.MouseButton1) then
			entreeActive = nil
			jetonBoucle = jetonBoucle + 1
		end
	end)

	-- tir assisté : le Zbire vivant le plus proche à portée
	Bus.ecouter("TirAuto", function()
		if not peutTirer() or not horde then return end
		local _, hrp = racinePerso()
		if not hrp then return end
		local origine = hrp.Position
		local meilleur, meilleureDist, meilleurePos = nil, portee(), nil
		for _, enfant in ipairs(horde:GetChildren()) do
			if enfant:IsA("Model") then
				local pv = enfant:GetAttribute("PV")
				if type(pv) ~= "number" or pv > 0 then
					local pos = pivotDe(enfant)
					if pos then
						local d = (pos - origine).Magnitude
						if d <= meilleureDist then
							meilleur = enfant
							meilleureDist = d
							meilleurePos = pos
						end
					end
				end
			end
		end
		if not meilleur then return end
		local id = meilleur:GetAttribute("Id")
		if type(id) ~= "string" then id = nil end
		envoyerTir(meilleurePos, id)
	end)

	-- réticule : petit cadre qui suit la souris pendant la run
	local reticule = Instance.new("Frame")
	reticule.Name = "Reticule"
	reticule.AnchorPoint = Vector2.new(0.5, 0.5)
	reticule.Size = UDim2.fromOffset(TAILLE_RETICULE, TAILLE_RETICULE)
	reticule.BackgroundTransparency = 1
	reticule.BorderSizePixel = 0
	reticule.Visible = false
	reticule.ZIndex = 50
	reticule.Active = false

	local coin = Instance.new("UICorner")
	coin.CornerRadius = UDim.new(0.3, 0)
	coin.Parent = reticule

	local contour = Instance.new("UIStroke")
	contour.Color = Charte.creme
	contour.Thickness = 2
	contour.Parent = reticule

	local point = Instance.new("Frame")
	point.Name = "Point"
	point.AnchorPoint = Vector2.new(0.5, 0.5)
	point.Position = UDim2.fromScale(0.5, 0.5)
	point.Size = UDim2.fromOffset(4, 4)
	point.BackgroundColor3 = Charte.toit
	point.BorderSizePixel = 0
	point.ZIndex = 51
	point.Parent = reticule

	local coinPoint = Instance.new("UICorner")
	coinPoint.CornerRadius = UDim.new(1, 0)
	coinPoint.Parent = point

	local ombreContour = Instance.new("Frame")
	ombreContour.Name = "Ombre"
	ombreContour.AnchorPoint = Vector2.new(0.5, 0.5)
	ombreContour.Position = UDim2.fromScale(0.5, 0.5)
	ombreContour.Size = UDim2.new(1, 4, 1, 4)
	ombreContour.BackgroundTransparency = 1
	ombreContour.BorderSizePixel = 0
	ombreContour.ZIndex = 49
	ombreContour.Parent = reticule

	local coinOmbre = Instance.new("UICorner")
	coinOmbre.CornerRadius = UDim.new(0.3, 0)
	coinOmbre.Parent = ombreContour

	local contourOmbre = Instance.new("UIStroke")
	contourOmbre.Color = Charte.encre
	contourOmbre.Thickness = 1
	contourOmbre.Transparency = 0.3
	contourOmbre.Parent = ombreContour

	reticule.Parent = ctx.gui

	RunService.RenderStepped:Connect(function()
		local visible = peutTirer() and UserInputService.MouseEnabled
		reticule.Visible = visible
		if visible then
			local souris = UserInputService:GetMouseLocation()
			reticule.Position = UDim2.fromOffset(souris.X, souris.Y)
			local attente = intervalle()
			if attente and os.clock() - dernierTir < attente then
				contour.Color = Charte.dore
			else
				contour.Color = Charte.creme
			end
		end
	end)
end

return M
