-- Interface/Effets : effets visuels locaux (tirs, impacts, butin, explosions, secousses, annonces).
-- Tout est construit côté client dans workspace.EffetsLocaux, sans collision ni requête, et nettoyé par Debris.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local M = {}

local MAX_PARTS = 150 -- parts d'effets simultanées au maximum
local DUREE_TIR = 0.12
local DUREE_SECOUSSE = 0.6
local AMPLITUDE_SECOUSSE = 0.8
local INTERVALLE_LISERE = 0.5
local FENETRE_TIR_LOCAL = 0.35 -- un tir serveur proche d'un tir local récent est déjà dessiné
local DISTANCE_TIR_LOCAL = 8

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local gui = ctx.gui

	-- dossier des effets (réutilisé s'il existe déjà)
	local dossier = workspace:FindFirstChild("EffetsLocaux")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "EffetsLocaux"
		dossier.Parent = workspace
	end

	-- ===== comptage des parts actives =====
	local actives = {}
	local function nettoyerActives()
		local maintenant = os.clock()
		for i = #actives, 1, -1 do
			local a = actives[i]
			if a.part.Parent == nil or maintenant > a.fin then
				table.remove(actives, i)
			end
		end
		return #actives
	end

	local function placeLibre(n)
		return nettoyerActives() + (n or 1) <= MAX_PARTS
	end

	local function tween(inst, duree, props, style, sens)
		local ok, t = pcall(function()
			return TweenService:Create(inst, TweenInfo.new(duree, style or Enum.EasingStyle.Quad, sens or Enum.EasingDirection.Out), props)
		end)
		if ok and t then
			t:Play()
		end
		return t
	end

	-- crée une part d'effet si le budget le permet ; renvoie nil sinon
	local function nouvellePart(forme, taille, cframe, couleur, duree, neon)
		if not placeLibre(1) then
			return nil
		end
		local p = Instance.new("Part")
		p.Name = "Effet"
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Shape = forme or Enum.PartType.Block
		p.Size = taille
		p.CFrame = cframe
		p.Color = couleur
		if neon then
			p.Material = Enum.Material.Neon
		else
			p.Material = Enum.Material.SmoothPlastic
		end
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = dossier
		table.insert(actives, { part = p, fin = os.clock() + duree + 0.2 })
		Debris:AddItem(p, duree)
		return p
	end

	local function aleaUnitaire()
		local v = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
		if v.Magnitude < 0.01 then
			return Vector3.new(0, 1, 0)
		end
		return v.Unit
	end

	local function positionJoueur()
		local perso = joueur and joueur.Character
		local racinePerso = perso and perso:FindFirstChild("HumanoidRootPart")
		if racinePerso then
			return racinePerso.Position
		end
		return nil
	end

	-- ===== effets 3D =====

	-- trait lumineux entre deux points
	local function trait(origine, cible, critique)
		if typeof(origine) ~= "Vector3" or typeof(cible) ~= "Vector3" then
			return
		end
		local longueur = (cible - origine).Magnitude
		if longueur < 0.05 then
			return
		end
		local epaisseur = 0.18
		local couleur = Charte.lumiere(Charte.toit)
		if critique then
			epaisseur = 0.45
			couleur = Charte.dore
		end
		local cf = CFrame.lookAt((origine + cible) / 2, cible)
		local p = nouvellePart(Enum.PartType.Block, Vector3.new(epaisseur, epaisseur, longueur), cf, couleur, DUREE_TIR, true)
		if p then
			tween(p, DUREE_TIR, { Transparency = 1 }, Enum.EasingStyle.Linear)
		end
	end

	-- gerbe de petits éclats qui s'écartent d'un point
	local function gerbe(position, couleur, nombre, taille, portee, duree, neon)
		for _ = 1, nombre do
			local p = nouvellePart(Enum.PartType.Block, Vector3.new(taille, taille, taille), CFrame.new(position) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0), couleur, duree, neon)
			if not p then
				return
			end
			local direction = aleaUnitaire()
			local arrivee = position + direction * portee * (0.5 + math.random() * 0.5)
			tween(p, duree, {
				CFrame = CFrame.new(arrivee) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, 0),
				Size = Vector3.new(taille * 0.2, taille * 0.2, taille * 0.2),
				Transparency = 1,
			})
		end
	end

	-- étincelles qui montent (réparation, gemmes)
	local function etincelles(position, couleur, nombre, rayon, hauteur, duree)
		for _ = 1, nombre do
			local angle = math.random() * math.pi * 2
			local r = math.random() * rayon
			local depart = position + Vector3.new(math.cos(angle) * r, math.random() * 1.5, math.sin(angle) * r)
			local p = nouvellePart(Enum.PartType.Block, Vector3.new(0.3, 0.3, 0.3), CFrame.new(depart), couleur, duree, true)
			if not p then
				return
			end
			tween(p, duree, {
				CFrame = CFrame.new(depart + Vector3.new(0, hauteur * (0.6 + math.random() * 0.4), 0)) * CFrame.Angles(0, math.random() * 6.28, math.random() * 6.28),
				Size = Vector3.new(0.08, 0.08, 0.08),
				Transparency = 1,
			}, Enum.EasingStyle.Sine)
		end
	end

	-- texte flottant au-dessus d'un point (porté par une petite part invisible)
	local function texteFlottant(position, texte, couleur)
		local p = nouvellePart(Enum.PartType.Block, Vector3.new(0.2, 0.2, 0.2), CFrame.new(position + Vector3.new(0, 2, 0)), couleur, 1.3, false)
		if not p then
			return
		end
		p.Transparency = 1
		local bb = Instance.new("BillboardGui")
		bb.Name = "Texte"
		bb.Size = UDim2.new(0, 120, 0, 40)
		bb.AlwaysOnTop = true
		bb.LightInfluence = 0
		bb.MaxDistance = 150
		bb.Parent = p
		local etiquette = Instance.new("TextLabel")
		etiquette.BackgroundTransparency = 1
		etiquette.Size = UDim2.new(1, 0, 1, 0)
		etiquette.Font = Charte.police
		etiquette.TextScaled = true
		etiquette.Text = texte
		etiquette.TextColor3 = couleur
		etiquette.TextStrokeColor3 = Charte.encre
		etiquette.TextStrokeTransparency = 0
		etiquette.Parent = bb
		tween(p, 1.2, { CFrame = p.CFrame + Vector3.new(0, 4, 0) }, Enum.EasingStyle.Quad)
		tween(etiquette, 1.2, { TextTransparency = 1, TextStrokeTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	end

	local function nombreDe(donnees)
		if type(donnees) == "table" and type(donnees.n) == "number" then
			return math.floor(donnees.n + 0.5)
		end
		return 1
	end

	-- nuage de cubes violets à la mort d'un Zbire
	local function nuageVaincu(position, donnees)
		local taille = 1
		if type(donnees) == "table" and type(donnees.type) == "string" then
			local stats = ctx.Equilibrage.zbires and ctx.Equilibrage.zbires[donnees.type]
			if stats and type(stats.taille) == "number" then
				taille = stats.taille
			end
		end
		local centre = position + Vector3.new(0, 2 * taille, 0)
		local nombre = math.clamp(math.floor(10 * taille), 6, 24)
		for i = 1, nombre do
			local cote = (0.5 + math.random() * 0.7) * taille
			local couleur = Charte.violet
			if i % 3 == 0 then
				couleur = Charte.ombre(Charte.violet)
			elseif i % 3 == 1 then
				couleur = Charte.lumiere(Charte.violet)
			end
			local depart = centre + aleaUnitaire() * taille
			local p = nouvellePart(Enum.PartType.Block, Vector3.new(cote, cote, cote), CFrame.new(depart), couleur, 0.9, false)
			if not p then
				return
			end
			local arrivee = depart + aleaUnitaire() * 3 * taille + Vector3.new(0, 2 * taille, 0)
			tween(p, 0.9, {
				CFrame = CFrame.new(arrivee) * CFrame.Angles(math.random() * 3, math.random() * 3, math.random() * 3),
				Size = Vector3.new(cote * 0.1, cote * 0.1, cote * 0.1),
				Transparency = 1,
			})
		end
	end

	-- sphère orange qui grossit jusqu'au rayon indiqué
	local function explosion(position, donnees)
		local rayon = 6
		if type(donnees) == "table" and type(donnees.rayon) == "number" and donnees.rayon > 0 then
			rayon = math.min(donnees.rayon, 60)
		end
		local p = nouvellePart(Enum.PartType.Ball, Vector3.new(1, 1, 1), CFrame.new(position), Charte.toit, 0.5, true)
		if p then
			p.Transparency = 0.2
			tween(p, 0.45, { Size = Vector3.new(rayon * 2, rayon * 2, rayon * 2), Transparency = 1 })
		end
		gerbe(position, Charte.dore, 8, 0.6, rayon, 0.5, true)
	end

	-- confettis aux couleurs de la charte
	local COULEURS_CONFETTIS = { Charte.toit, Charte.dore, Charte.gemme, Charte.creme, Charte.prairie }
	local function confettis(position)
		local centre = position + Vector3.new(0, 3, 0)
		for i = 1, 18 do
			local couleur = COULEURS_CONFETTIS[(i % #COULEURS_CONFETTIS) + 1]
			local p = nouvellePart(Enum.PartType.Block, Vector3.new(0.4, 0.08, 0.25), CFrame.new(centre), couleur, 1.4, false)
			if not p then
				return
			end
			local angle = math.random() * math.pi * 2
			local haut = centre + Vector3.new(math.cos(angle) * (1 + math.random() * 3), 3 + math.random() * 3, math.sin(angle) * (1 + math.random() * 3))
			local rotation = CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
			tween(p, 0.5, { CFrame = CFrame.new(haut) * rotation })
			task.delay(0.5, function()
				if p.Parent then
					tween(p, 0.85, { CFrame = CFrame.new(haut - Vector3.new(0, 4, 0)) * rotation * CFrame.Angles(3, 2, 1), Transparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
				end
			end)
		end
	end

	-- ===== effets d'écran =====

	-- cadre de quatre bandes dégradées sur les bords de l'écran
	local function cadreEcran(nom, couleur, epaisseur, duree, opacite)
		if not gui then
			return
		end
		local cadre = Instance.new("Frame")
		cadre.Name = nom
		cadre.BackgroundTransparency = 1
		cadre.Size = UDim2.new(1, 0, 1, 0)
		cadre.ZIndex = 20
		cadre.Parent = gui
		local bandes = {
			{ UDim2.new(1, 0, epaisseur, 0), UDim2.new(0, 0, 0, 0), 90 },
			{ UDim2.new(1, 0, epaisseur, 0), UDim2.new(0, 0, 1 - epaisseur, 0), -90 },
			{ UDim2.new(epaisseur, 0, 1, 0), UDim2.new(0, 0, 0, 0), 0 },
			{ UDim2.new(epaisseur, 0, 1, 0), UDim2.new(1 - epaisseur, 0, 0, 0), 180 },
		}
		local liste = {}
		for _, b in ipairs(bandes) do
			local f = Instance.new("Frame")
			f.BorderSizePixel = 0
			f.BackgroundColor3 = couleur
			f.BackgroundTransparency = 1 - opacite
			f.Size = b[1]
			f.Position = b[2]
			f.ZIndex = 20
			f.Parent = cadre
			local degrade = Instance.new("UIGradient")
			degrade.Rotation = b[3]
			degrade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			degrade.Parent = f
			table.insert(liste, f)
		end
		for _, f in ipairs(liste) do
			tween(f, duree, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
		Debris:AddItem(cadre, duree + 0.1)
	end

	local secousseFin = 0
	local secousseActive = false
	local function secousse(duree)
		secousseFin = math.max(secousseFin, os.clock() + duree)
		if secousseActive then
			return
		end
		secousseActive = true
		local nomLiaison = "ZsurvieSecousse"
		local ok = pcall(function()
			RunService:BindToRenderStep(nomLiaison, Enum.RenderPriority.Camera.Value + 1, function()
				local camera = workspace.CurrentCamera
				local reste = secousseFin - os.clock()
				if reste <= 0 then
					secousseActive = false
					pcall(function()
						RunService:UnbindFromRenderStep(nomLiaison)
					end)
					return
				end
				if camera then
					local force = AMPLITUDE_SECOUSSE * math.min(1, reste / duree)
					local d = Vector3.new(math.random() - 0.5, math.random() - 0.5, 0) * force
					camera.CFrame = camera.CFrame * CFrame.new(d) * CFrame.Angles(0, 0, (math.random() - 0.5) * 0.02 * force)
				end
			end)
		end)
		if not ok then
			secousseActive = false
		end
	end

	local dernierLisere = -10
	local function lisereDegats()
		local maintenant = os.clock()
		if maintenant - dernierLisere < INTERVALLE_LISERE then
			return
		end
		dernierLisere = maintenant
		cadreEcran("LisereDegats", Charte.alerte, 0.04, 0.35, 0.8)
	end

	-- grand texte « JOUR n » au centre de l'écran
	local function annonceJour(donnees)
		if not gui then
			return
		end
		local jour = ""
		if type(donnees) == "table" and type(donnees.jour) == "number" then
			jour = tostring(math.floor(donnees.jour))
		end
		local ancienne = gui:FindFirstChild("AnnonceJour")
		if ancienne then
			ancienne:Destroy()
		end
		local etiquette = Instance.new("TextLabel")
		etiquette.Name = "AnnonceJour"
		etiquette.BackgroundTransparency = 1
		etiquette.AnchorPoint = Vector2.new(0.5, 0.5)
		etiquette.Position = UDim2.new(0.5, 0, 0.4, 0)
		etiquette.Size = UDim2.new(0.5, 0, 0.1, 0)
		etiquette.Font = Charte.police
		etiquette.TextScaled = true
		etiquette.Text = "JOUR " .. jour
		etiquette.TextColor3 = Charte.creme
		etiquette.TextStrokeColor3 = Charte.encre
		etiquette.TextStrokeTransparency = 0
		etiquette.TextTransparency = 1
		etiquette.ZIndex = 25
		etiquette.Parent = gui
		local contour = Instance.new("UIStroke")
		contour.Color = Charte.toit
		contour.Thickness = 3
		contour.Transparency = 1
		contour.Parent = etiquette
		tween(etiquette, 0.5, { TextTransparency = 0, Size = UDim2.new(0.7, 0, 0.16, 0) }, Enum.EasingStyle.Back)
		tween(contour, 0.5, { Transparency = 0 })
		task.delay(2, function()
			if etiquette.Parent then
				tween(etiquette, 0.8, { TextTransparency = 1, TextStrokeTransparency = 1 })
				tween(contour, 0.8, { Transparency = 1 })
			end
		end)
		Debris:AddItem(etiquette, 3)
	end

	-- ===== aiguillage =====
	local dernierTirLocal = -10
	local function tirDejaDessine(origine)
		if os.clock() - dernierTirLocal > FENETRE_TIR_LOCAL then
			return false
		end
		local ici = positionJoueur()
		return ici ~= nil and (ici - origine).Magnitude <= DISTANCE_TIR_LOCAL
	end

	local function centreMaison()
		local m = Plan.maison
		if m and typeof(m.centre) == "Vector3" then
			local hauteur = 14
			if typeof(m.taille) == "Vector3" then
				hauteur = m.taille.Y
			end
			return m.centre + Vector3.new(0, hauteur / 2, 0), m.taille
		end
		return Vector3.new(0, 7, 0), Vector3.new(16, 14, 16)
	end

	local GESTIONNAIRES = {}

	GESTIONNAIRES.Tir = function(position, donnees)
		if type(donnees) ~= "table" or typeof(donnees.origine) ~= "Vector3" then
			return
		end
		local critique = donnees.critique == true
		if not critique and tirDejaDessine(donnees.origine) then
			return
		end
		trait(donnees.origine, position, critique)
	end

	GESTIONNAIRES.Impact = function(position)
		gerbe(position, Charte.lumiere(Charte.dore), 5, 0.35, 2, 0.3, true)
	end

	GESTIONNAIRES.Vaincu = function(position, donnees)
		nuageVaincu(position, donnees)
	end

	GESTIONNAIRES.Piece = function(position, donnees)
		texteFlottant(position, "+" .. nombreDe(donnees) .. " 🪙", Charte.dore)
	end

	GESTIONNAIRES.Gemme = function(position, donnees)
		etincelles(position, Charte.gemme, 8, 1.5, 4, 0.8)
		texteFlottant(position, "+" .. nombreDe(donnees) .. " 💎", Charte.gemme)
	end

	GESTIONNAIRES.Reparation = function(position)
		local centre, taille = centreMaison()
		local rayon = 8
		if typeof(taille) == "Vector3" then
			rayon = taille.X / 2
		end
		local base = centre
		if typeof(position) == "Vector3" and (position - centre).Magnitude < 30 then
			base = position
		end
		etincelles(base, Charte.prairie, 12, rayon, 6, 0.9)
		etincelles(centre, Charte.lumiere(Charte.prairie), 6, rayon, 8, 1)
	end

	GESTIONNAIRES.Explosion = function(position, donnees)
		explosion(position, donnees)
	end

	GESTIONNAIRES.Colosse = function()
		secousse(DUREE_SECOUSSE)
		cadreEcran("VignetteColosse", Charte.alerte, 0.18, 1.2, 0.6)
	end

	GESTIONNAIRES.DegatsMaison = function()
		lisereDegats()
	end

	GESTIONNAIRES.Amelioration = function(position)
		confettis(position)
	end

	GESTIONNAIRES.Recherche = function(position)
		confettis(position)
	end

	GESTIONNAIRES.JourDebut = function(_, donnees)
		annonceJour(donnees)
	end

	-- genres sans position utile : on se replie sur le joueur ou la Maison
	local SANS_POSITION = { Colosse = true, DegatsMaison = true, JourDebut = true }

	local function traiter(genre, position, donnees)
		if type(genre) ~= "string" then
			return
		end
		local gestionnaire = GESTIONNAIRES[genre]
		if not gestionnaire then
			return
		end
		if typeof(position) ~= "Vector3" and not SANS_POSITION[genre] then
			position = positionJoueur()
			if not position then
				position = centreMaison()
			end
		end
		local ok, err = pcall(gestionnaire, position, donnees)
		if not ok then
			warn("[Zsurvie] Effets « " .. genre .. " » : " .. tostring(err))
		end
	end

	local remoteEffet = Reseau and Reseau.Effet
	if remoteEffet then
		remoteEffet.OnClientEvent:Connect(traiter)
	else
		warn("[Zsurvie] Interface Effets : RemoteEvent « Effet » introuvable")
	end

	if Bus then
		Bus.ecouter("TirLocal", function(origine, cible)
			if typeof(origine) == "Vector3" and typeof(cible) == "Vector3" then
				dernierTirLocal = os.clock()
				trait(origine, cible, false)
			end
		end)
	end
end

return M
