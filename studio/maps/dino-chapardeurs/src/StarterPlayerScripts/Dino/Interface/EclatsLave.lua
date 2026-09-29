-- Interface/EclatsLave : de temps en temps (toutes les 25 à 70 s), le volcan crache quelques petits éclats
-- de lave. Ils jaillissent du cratère avec une bouffée de fumée et un éclair orangé, décrivent une parabole
-- (petit cube Neon qui tournoie, traînée incandescente, fumée pour les plus gros) et retombent sur les flancs
-- en une gerbe d'étincelles, puis s'aplatissent, noircissent et disparaissent (Debris).
-- Pendant l'événement « Eruption » (ctx.Etat.Evenement) : salves bien plus fréquentes et plus nourries.
-- Effets 100 % locaux (dossier dans workspace.CurrentCamera), une seule boucle Heartbeat active seulement
-- pendant les vols, rien du tout si le joueur est à plus de 450 studs du volcan.
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local M = {}

local DISTANCE_MAX = 450
local GRAVITE = 46 -- gravité « dessin animé » des éclats (studs/s²)
local ECLATS_MAX = 24 -- jamais plus d'éclats en vol à la fois
local FUMEE = "rbxasset://textures/particles/smoke_main.dds"
local ETINCELLE = "rbxasset://textures/particles/sparkles_main.dds"

local function sequence(points)
	local kp = {}
	for _, p in ipairs(points) do
		table.insert(kp, NumberSequenceKeypoint.new(p[1], p[2]))
	end
	return NumberSequence.new(kp)
end

function M.demarrer(ctx)
	local Plan = ctx.Plan or {}
	local Charte = ctx.Charte
	local Etat = ctx.Etat
	local joueur = ctx.joueur

	-- ===== couleurs =====
	local LAVE = Color3.fromRGB(255, 90, 31)
	local DORE = Color3.fromRGB(255, 201, 51)
	if Charte then
		LAVE = Charte.lave or LAVE
		DORE = Charte.dore or DORE
	end
	local JAUNE = DORE:Lerp(Color3.new(1, 1, 1), 0.25)
	local ORANGE = LAVE:Lerp(DORE, 0.35)
	local ROUGE_SOMBRE = Color3.fromRGB(120, 24, 10)
	local SCORIE = Color3.fromRGB(46, 37, 40)
	local FUMEE_CLAIRE = Color3.fromRGB(150, 140, 136)
	local FUMEE_SOMBRE = Color3.fromRGB(70, 62, 66)

	-- ===== géométrie du volcan (Plan, puis attributs de la Bouche posés par Builders/Volcan) =====
	local infoVolcan = Plan.volcan or {}
	local centre = infoVolcan.centre or Vector3.new(0, 0, -190)
	local geo = {
		sommet = math.min(56, (infoVolcan.hauteur or 75) - 17),
		rayonHaut = 11.5,
		rayonLac = 8.3,
		rayonBas = (infoVolcan.rayon or 36) - 3.5,
	}
	geo.bouche = centre + Vector3.new(0, geo.sommet + 1.5, 0)
	local boucheTrouvee = false

	local function chercherBouche()
		if boucheTrouvee then
			return
		end
		pcall(function()
			local dossierVolcan = ctx.racine and ctx.racine:FindFirstChild("Volcan")
			local modele = dossierVolcan and dossierVolcan:FindFirstChild("Volcan")
			local bouche = modele and modele:FindFirstChild("Bouche")
			if bouche and bouche:IsA("BasePart") then
				geo.bouche = bouche.Position
				local s = bouche:GetAttribute("Sommet")
				if type(s) == "number" then geo.sommet = s end
				local rh = bouche:GetAttribute("RayonCratere")
				if type(rh) == "number" then geo.rayonHaut = rh end
				local rl = bouche:GetAttribute("RayonLac")
				if type(rl) == "number" then geo.rayonLac = rl end
				local rb = bouche:GetAttribute("RayonBas")
				if type(rb) == "number" then geo.rayonBas = rb end
				boucheTrouvee = true
			end
		end)
	end

	-- profil du cône (même formule que Builders/Volcan) et son inverse : hauteur du flanc à la distance r
	local function rayonA(y)
		local u = 1 - math.max(0, math.min(1, y / geo.sommet))
		return geo.rayonHaut + (geo.rayonBas - geo.rayonHaut) * (math.pow(u, 1.8) * 0.75 + u * 0.25)
	end
	local function hauteurFlanc(r)
		if r >= geo.rayonBas then return 0 end
		if r <= geo.rayonHaut then return geo.sommet end
		local bas, haut = 0, geo.sommet
		for _ = 1, 14 do
			local m = (bas + haut) / 2
			if rayonA(m) > r then bas = m else haut = m end
		end
		return (bas + haut) / 2
	end
	-- l'axe du cône penche un peu : on glisse du centre au sol vers la bouche avec la hauteur
	local function axeA(y)
		local t = math.max(0, math.min(1, y / geo.sommet))
		return Vector3.new(centre.X + (geo.bouche.X - centre.X) * t, y, centre.Z + (geo.bouche.Z - centre.Z) * t)
	end

	-- ===== dossier local =====
	local dossier = Instance.new("Folder")
	dossier.Name = "EclatsLave"
	local function rattacher()
		local camera = workspace.CurrentCamera
		if camera and dossier.Parent ~= camera then
			dossier.Parent = camera
		end
		return dossier.Parent ~= nil
	end

	local function enEruption()
		local ok, v = pcall(function() return Etat and Etat:GetAttribute("Evenement") end)
		return ok and v == "Eruption"
	end

	local function positionJoueur()
		local perso = joueur and joueur.Character
		local racinePerso = perso and perso:FindFirstChild("HumanoidRootPart")
		if racinePerso and racinePerso:IsA("BasePart") then
			return racinePerso.Position
		end
		local camera = workspace.CurrentCamera
		if camera then
			return camera.CFrame.Position
		end
		return nil
	end

	local function assezPres()
		local p = positionJoueur()
		if not p then return false end
		local dx, dz = p.X - centre.X, p.Z - centre.Z
		return dx * dx + dz * dz <= DISTANCE_MAX * DISTANCE_MAX
	end

	local alea = Random.new()

	-- ===== petites pièces d'effets =====
	local function partEffet(nom, taille, cf, props)
		local p = Instance.new("Part")
		p.Name = nom
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Size = taille
		p.CFrame = cf
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		if props then
			for k, v in pairs(props) do p[k] = v end
		end
		return p
	end

	local function emetteurEtincelles(parent, nombreParSalve, vitesseMin, vitesseMax)
		local e = Instance.new("ParticleEmitter")
		e.Name = "Etincelles"
		e.Texture = ETINCELLE
		e.Color = ColorSequence.new(JAUNE, LAVE)
		e.LightEmission = 1
		e.LightInfluence = 0
		e.Size = sequence({ { 0, 0.45 }, { 1, 0 } })
		e.Transparency = sequence({ { 0, 0 }, { 0.7, 0.2 }, { 1, 1 } })
		e.Speed = NumberRange.new(vitesseMin or 7, vitesseMax or 15)
		e.SpreadAngle = Vector2.new(70, 70)
		e.Acceleration = Vector3.new(0, -34, 0)
		e.Drag = 1.5
		e.Lifetime = NumberRange.new(0.35, 0.8)
		e.EmissionDirection = Enum.NormalId.Top
		e.Rate = 0
		e.Enabled = false
		e.Parent = parent
		e:Emit(nombreParSalve)
		return e
	end

	local function emetteurFumee(parent, couleur, taille, nombre)
		local e = Instance.new("ParticleEmitter")
		e.Name = "Fumee"
		e.Texture = FUMEE
		e.Color = ColorSequence.new(couleur)
		e.LightInfluence = 1
		e.Size = sequence({ { 0, taille * 0.5 }, { 1, taille * 1.6 } })
		e.Transparency = sequence({ { 0, 0.45 }, { 1, 1 } })
		e.Speed = NumberRange.new(1.5, 4)
		e.SpreadAngle = Vector2.new(50, 50)
		e.Acceleration = Vector3.new(0.6, 2.2, 0)
		e.Lifetime = NumberRange.new(1, 1.8)
		e.Rotation = NumberRange.new(0, 360)
		e.RotSpeed = NumberRange.new(-40, 40)
		e.Rate = 0
		e.Enabled = false
		e.Parent = parent
		if nombre and nombre > 0 then
			e:Emit(nombre)
		end
		return e
	end

	-- ===== vol des éclats : une seule boucle Heartbeat, branchée seulement quand il y a des éclats en l'air =====
	local actifs = {}
	local connexion = nil

	local function atterrir(e)
		local p = e.part
		if not p.Parent then return end
		pcall(function()
			p.CFrame = CFrame.new(e.p1) * CFrame.Angles(0, alea:NextNumber(0, math.pi * 2), 0)
			local trainee = p:FindFirstChild("Trainee")
			if trainee then trainee.Enabled = false end
			local fumee = p:FindFirstChild("FumeeVol")
			if fumee then fumee.Enabled = false end
			emetteurEtincelles(p, math.floor(8 + e.taille * 6))
			emetteurFumee(p, FUMEE_CLAIRE, 1.2 + e.taille, 2)
			-- la goutte s'écrase, rougit puis noircit et s'éteint
			local t = e.taille
			TweenService:Create(p, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(t * 1.7, t * 0.35, t * 1.7),
			}):Play()
			TweenService:Create(p, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Color = ROUGE_SOMBRE,
			}):Play()
			task.delay(1.3, function()
				if p.Parent then
					p.Material = Enum.Material.Basalt
					p.Color = SCORIE
					TweenService:Create(p, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Transparency = 1,
					}):Play()
				end
			end)
		end)
		Debris:AddItem(p, 2.6)
	end

	local function pas()
		local maintenant = os.clock()
		for i = #actifs, 1, -1 do
			local e = actifs[i]
			local u = maintenant - e.debut
			if not e.part.Parent then
				table.remove(actifs, i)
			elseif u >= e.duree then
				table.remove(actifs, i)
				atterrir(e)
			else
				local pos = e.p0 + e.v * u - Vector3.new(0, 0.5 * GRAVITE * u * u, 0)
				e.part.CFrame = CFrame.new(pos) * e.rot0 * CFrame.Angles(u * e.vrille, 0, 0)
			end
		end
		if #actifs == 0 and connexion then
			connexion:Disconnect()
			connexion = nil
		end
	end

	local function lancerEclat(fort, avecFumee)
		if #actifs >= ECLATS_MAX or not dossier.Parent then return end
		local taille = alea:NextNumber(0.7, 1.3)
		if fort then taille = alea:NextNumber(0.8, 1.7) end
		-- point de chute : sur les flancs, de préférence côté Place (+Z) où se trouvent les joueurs
		local a
		if alea:NextNumber() < 0.65 then
			a = math.pi / 2 + alea:NextNumber(-1.5, 1.5)
		else
			a = alea:NextNumber(0, math.pi * 2)
		end
		local rMin = geo.rayonHaut + 3
		local rMax = geo.rayonHaut + (geo.rayonBas - geo.rayonHaut) * 0.62
		if fort then rMax = geo.rayonHaut + (geo.rayonBas - geo.rayonHaut) * 0.85 end
		local r = alea:NextNumber(rMin, math.max(rMin + 1, rMax))
		local yChute = hauteurFlanc(r)
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local p1 = axeA(yChute) + dir * r + Vector3.new(0, taille * 0.3, 0)
		local p0 = geo.bouche + Vector3.new(alea:NextNumber(-1, 1) * geo.rayonLac * 0.4, 0.5, alea:NextNumber(-1, 1) * geo.rayonLac * 0.4)
		-- durée de vol : plus c'est loin, plus c'est long (vitesse initiale déduite pour tomber pile sur p1)
		local k = (r - rMin) / math.max(1, geo.rayonBas - rMin)
		local duree = 1.9 + 1.2 * k + alea:NextNumber(0, 0.45)
		local v = (p1 - p0) / duree + Vector3.new(0, 0.5 * GRAVITE * duree, 0)

		local couleur = JAUNE:Lerp(ORANGE, alea:NextNumber(0.2, 0.9))
		local p = partEffet("Eclat", Vector3.new(taille, taille, taille), CFrame.new(p0), {
			Material = Enum.Material.Neon,
			Color = couleur,
		})
		-- traînée incandescente (face caméra : largeur constante quelle que soit la rotation)
		local a0 = Instance.new("Attachment")
		a0.Name = "TraineeA"
		a0.Position = Vector3.new(taille * 0.4, 0, 0)
		a0.Parent = p
		local a1 = Instance.new("Attachment")
		a1.Name = "TraineeB"
		a1.Position = Vector3.new(-taille * 0.4, 0, 0)
		a1.Parent = p
		local trainee = Instance.new("Trail")
		trainee.Name = "Trainee"
		trainee.Attachment0 = a0
		trainee.Attachment1 = a1
		trainee.FaceCamera = true
		trainee.Lifetime = 0.5
		trainee.MinLength = 0.05
		trainee.LightEmission = 1
		trainee.LightInfluence = 0
		trainee.Color = ColorSequence.new(JAUNE, ROUGE_SOMBRE)
		trainee.Transparency = sequence({ { 0, 0.05 }, { 0.6, 0.5 }, { 1, 1 } })
		trainee.WidthScale = sequence({ { 0, 1 }, { 1, 0.15 } })
		trainee.Parent = p
		if avecFumee then
			local f = emetteurFumee(p, FUMEE_SOMBRE, 0.9 + taille * 0.5, 0)
			f.Name = "FumeeVol"
			f.Speed = NumberRange.new(0.3, 1)
			f.Lifetime = NumberRange.new(0.8, 1.4)
			f.Rate = 14
			f.Enabled = true
		end
		p.Parent = dossier

		table.insert(actifs, {
			part = p,
			taille = taille,
			p0 = p0,
			p1 = p1,
			v = v,
			duree = duree,
			debut = os.clock(),
			rot0 = CFrame.Angles(alea:NextNumber(0, math.pi * 2), alea:NextNumber(0, math.pi * 2), 0),
			vrille = alea:NextNumber(4, 9) * (alea:NextNumber() < 0.5 and -1 or 1),
		})
		Debris:AddItem(p, duree + 3) -- filet de sécurité
		if not connexion then
			connexion = RunService.Heartbeat:Connect(pas)
		end
	end

	-- bouffée au départ : fumée sombre, étincelles et bref éclair orangé au-dessus du lac
	local function souffle(fort)
		local p = partEffet("Souffle", Vector3.new(geo.rayonLac, 1, geo.rayonLac), CFrame.new(geo.bouche + Vector3.new(0, 1, 0)), {
			Transparency = 1,
		})
		p.Parent = dossier
		pcall(function()
			local nombreEtincelles = 14
			if fort then nombreEtincelles = 28 end
			emetteurEtincelles(p, nombreEtincelles, 12, 24)
			emetteurFumee(p, FUMEE_SOMBRE, 4, fort and 6 or 3)
			local lueur = Instance.new("PointLight")
			lueur.Name = "Eclair"
			lueur.Color = ORANGE
			lueur.Range = 34
			lueur.Brightness = fort and 5 or 3.5
			lueur.Shadows = false
			lueur.Parent = p
			TweenService:Create(lueur, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Brightness = 0 }):Play()
		end)
		Debris:AddItem(p, 2.2)
	end

	-- une salve : quelques éclats, lâchés en rafale sur une demi-seconde
	local function salve()
		if not assezPres() or not rattacher() then return end
		chercherBouche()
		local fort = enEruption()
		local nombre = alea:NextInteger(3, 8)
		if fort then nombre = alea:NextInteger(7, 12) end
		souffle(fort)
		local fumees = 0
		for i = 1, nombre do
			local avecFumee = false
			if fumees < 2 and alea:NextNumber() < 0.4 then
				avecFumee = true
				fumees = fumees + 1
			end
			task.delay((i - 1) * alea:NextNumber(0.04, 0.12), function()
				pcall(lancerEclat, fort, avecFumee)
			end)
		end
	end

	local function delaiSuivant()
		if enEruption() then
			return alea:NextNumber(5, 12)
		end
		return alea:NextNumber(25, 70)
	end

	local prochain = os.clock() + alea:NextNumber(10, 30)
	if Etat then
		pcall(function()
			Etat:GetAttributeChangedSignal("Evenement"):Connect(function()
				-- au début d'une éruption, la première salve part presque tout de suite
				if enEruption() then
					prochain = math.min(prochain, os.clock() + alea:NextNumber(1, 3))
				end
			end)
		end)
	end

	chercherBouche()
	while true do
		task.wait(0.5)
		if os.clock() >= prochain then
			prochain = os.clock() + delaiSuivant()
			local ok, err = pcall(salve)
			if not ok then
				warn("[Dino] EclatsLave : " .. tostring(err))
			end
		end
	end
end

return M
