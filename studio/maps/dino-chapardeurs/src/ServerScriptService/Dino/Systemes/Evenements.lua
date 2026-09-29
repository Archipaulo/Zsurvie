-- Systeme Evenements : lance regulierement un evenement aleatoire (pluie de meteores, eruption, lune doree).
-- Etat.Evenement / EvenementFin / ProchainEvenement sont tenus a jour ; l'Eruption est jouee par le Volcan
-- et la Lune doree par le Ciel (ils lisent Etat.Evenement) ; ce module fait tomber les meteores.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local M = {}

local PREMIER_DELAI = 120     -- secondes avant le premier evenement
local PERIODE_METEORE = 1.5   -- une meteorite toutes les 1,5 s
local HAUTEUR_CHUTE = 140     -- altitude de depart d'une meteorite
local DUREE_CHUTE = 1.6       -- temps de chute (s)
local MARGE_BASE = 4          -- marge autour des Bases ou rien ne tombe

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local reglages = ctx.Equilibrage.evenements or {}
	local liste = reglages.liste or {}
	local intervalle = tonumber(reglages.intervalle) or 300
	local duree = tonumber(reglages.duree) or 90
	local alea = Random.new()

	local function maintenant()
		return workspace:GetServerTimeNow()
	end

	local function notifierTous(texte, genre)
		pcall(function()
			Reseau.Notification:FireAllClients(texte, genre)
		end)
	end

	local function effetTous(genre, position, donnees)
		pcall(function()
			Reseau.Effet:FireAllClients(genre, position, donnees)
		end)
	end

	-- dossier des meteorites (objets passagers)
	local dossier = ctx.racine:FindFirstChild("Meteores")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Meteores"
		dossier.Parent = ctx.racine
	end

	-- ===== titre flottant geant au-dessus du Cratere (style simulateur) =====
	local Style = ctx.Style
	local ICONES = {
		PluieDeMeteores = "☄️",
		Eruption = "🌋",
		LuneDoree = "🌕",
	}
	local titre = nil        -- BillboardGui
	local lignesTitre = nil  -- { icone, nom, chrono }
	pcall(function()
		if not Style then
			return
		end
		local scene = ctx.racine:FindFirstChild("TitreEvenement")
		if not scene then
			scene = Instance.new("Folder")
			scene.Name = "TitreEvenement"
			scene.Parent = ctx.racine
		end
		local ancre = Instance.new("Part")
		ancre.Name = "AncreTitre"
		ancre.Anchored = true
		ancre.CanCollide = false
		ancre.CanQuery = false
		ancre.CanTouch = false
		ancre.CastShadow = false
		ancre.Transparency = 1
		ancre.Size = Vector3.new(1, 1, 1)
		ancre.Position = Plan.cratere.centre + Vector3.new(0, 14, 0)
		ancre.Parent = scene
		local g, textes = Style.etiquette(ancre, {
			{ texte = "⭐", taille = 1.2, nom = "Icone" },
			{ texte = "", taille = 1.6, titre = true, rarete = "Divin", contour = 4, nom = "Nom" },
			{ texte = "", taille = 1, couleur = Style.couleurs.revenu, contour = 3.5, nom = "Chrono" },
		}, {
			Name = "TitreEvenement",
			largeur = 40,
			hauteurLigne = 3.4,
			StudsOffset = Vector3.new(0, 6, 0),
			MaxDistance = 400,
			AlwaysOnTop = false,
		})
		g.Enabled = false
		titre = g
		lignesTitre = textes
	end)

	local function chrono(secondes)
		secondes = math.max(0, math.floor(secondes))
		local m = math.floor(secondes / 60)
		local s = secondes % 60
		if s < 10 then
			return m .. ":0" .. s
		end
		return m .. ":" .. s
	end

	-- noms des evenements (tries pour un tirage stable)
	local noms = {}
	for cle in pairs(liste) do
		table.insert(noms, cle)
	end
	table.sort(noms)

	local function nomAffiche(cle)
		local infos = liste[cle]
		if infos and type(infos.nom) == "string" then
			return infos.nom
		end
		return cle
	end

	-- affiche le titre pendant un evenement (nom arc-en-ciel + compte a rebours), le masque sinon
	local function majTitre()
		if not titre or not lignesTitre then
			return
		end
		pcall(function()
			local nom = Etat:GetAttribute("Evenement")
			if type(nom) ~= "string" or nom == "" then
				if titre.Enabled then
					titre.Enabled = false
				end
				return
			end
			local fin = tonumber(Etat:GetAttribute("EvenementFin")) or 0
			local icone = ICONES[nom] or "⭐"
			local texteNom = string.upper(nomAffiche(nom))
			local texteChrono = "⏱ " .. chrono(fin - maintenant())
			if lignesTitre[1].Text ~= icone then
				lignesTitre[1].Text = icone
			end
			if lignesTitre[2].Text ~= texteNom then
				lignesTitre[2].Text = texteNom
			end
			if lignesTitre[3].Text ~= texteChrono then
				lignesTitre[3].Text = texteChrono
			end
			if not titre.Enabled then
				titre.Enabled = true
			end
		end)
	end

	-- ===== choix d'un point d'impact =====
	local function dansUneBase(x, z)
		local demiX = Plan.base.largeur / 2 + MARGE_BASE
		local demiZ = Plan.base.profondeur / 2 + MARGE_BASE
		for _, b in ipairs(Plan.bases) do
			if math.abs(x - b.centre.X) <= demiX and math.abs(z - b.centre.Z) <= demiZ then
				return true
			end
		end
		return false
	end

	local function pointInterdit(x, z)
		if dansUneBase(x, z) then
			return true
		end
		local p = Vector3.new(x, 0, z)
		-- ni dans le cone du volcan, ni sur l'apparition
		if Plan.volcan and ctx.Outils.distanceXZ(p, Plan.volcan.centre) <= Plan.volcan.rayon + 4 then
			return true
		end
		if Plan.place and ctx.Outils.distanceXZ(p, Plan.place.centre) <= 8 then
			return true
		end
		-- ni dans la Rivière, ni sur le toit de la Nurserie ou de la Grande Porte
		local r = Plan.riviere
		if r and z >= r.zMin - 2 and z <= r.zMax + 2 then
			return true
		end
		for _, abri in ipairs({ Plan.nurserie, Plan.finTapis }) do
			if abri and ctx.Outils.distanceXZ(p, abri.centre) <= abri.rayon + 3 then
				return true
			end
		end
		return false
	end

	local function hauteurSol(x, z)
		local y = 0
		pcall(function()
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { dossier, ctx.dinos }
			local resultat = workspace:Raycast(Vector3.new(x, 250, z), Vector3.new(0, -300, 0), params)
			if resultat then
				y = resultat.Position.Y
			end
		end)
		return y
	end

	-- zone de chute : Plan.monde sans les bandes de falaises (bord du monde, hors de portée des joueurs)
	local function zoneDeChute()
		local xMin, xMax = Plan.monde.min.X + 12, Plan.monde.max.X - 12
		local zMin, zMax = Plan.monde.min.Z + 12, Plan.monde.max.Z - 12
		local f = Plan.falaises
		if f then
			if f.ouest then xMin = math.max(xMin, f.ouest.xMax + 6) end
			if f.est then xMax = math.min(xMax, f.est.xMin - 6) end
			if f.nord then zMin = math.max(zMin, f.nord.zMax + 6) end
			if f.sud then zMax = math.min(zMax, f.sud.zMin - 6) end
		end
		return xMin, xMax, zMin, zMax
	end

	local function pointAleatoire()
		local xMin, xMax, zMin, zMax = zoneDeChute()
		for _ = 1, 25 do
			local x = alea:NextNumber(xMin, xMax)
			local z = alea:NextNumber(zMin, zMax)
			if not pointInterdit(x, z) then
				return Vector3.new(x, hauteurSol(x, z), z)
			end
		end
		local c = Plan.cratere.centre
		return Vector3.new(c.X, hauteurSol(c.X, c.Z), c.Z)
	end

	-- ===== une meteorite =====
	local function nouvellePart(props)
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		for cle, valeur in pairs(props) do
			p[cle] = valeur
		end
		p.Parent = dossier
		return p
	end

	-- palette : roche Basalt sombre, veines Neon de feu (blanc chaud -> jaune -> orange -> braise)
	local JAUNE = Charte.dore
	local ORANGE = Charte.lave
	if Style then
		JAUNE = Style.couleurs.revenu
		ORANGE = Style.boutons.orange[2]
	end
	local BLANC_CHAUD = Color3.fromRGB(255, 244, 205)
	local BRAISE = Color3.fromRGB(200, 42, 18)
	local BRAISE_FROIDE = Color3.fromRGB(110, 24, 14)
	local BASALTE = Color3.fromRGB(58, 49, 48)
	local BASALTE_CLAIR = Color3.fromRGB(84, 73, 70)
	local BASALTE_SOMBRE = Color3.fromRGB(36, 30, 31)
	local CALCINE = Color3.fromRGB(48, 38, 34)
	local FUMEE_SOMBRE = Color3.fromRGB(64, 56, 54)
	local FUMEE_CLAIRE = Color3.fromRGB(128, 120, 116)
	local POUSSIERE = Charte.sable:Lerp(Charte.pierre, 0.5)
	local TEXTURE_FEU = "rbxasset://textures/particles/fire_main.dds"
	local TEXTURE_FUMEE = "rbxasset://textures/particles/smoke_main.dds"
	local QUAD = Enum.EasingStyle.Quad
	local SORTIE = Enum.EasingDirection.Out
	local ENTREE = Enum.EasingDirection.In

	local function animer(inst, duree, style, sens, buts)
		local t = TweenService:Create(inst, TweenInfo.new(duree, style, sens), buts)
		t:Play()
		return t
	end

	local function cube(t)
		return Vector3.new(t, t, t)
	end

	local function suite(cles)
		local points = {}
		for _, c in ipairs(cles) do
			table.insert(points, NumberSequenceKeypoint.new(c[1], c[2]))
		end
		return NumberSequence.new(points)
	end

	-- direction aleatoire ; hauteurMax borne la composante verticale (evite les cas degeneres de lookAt)
	local function directionAleatoire(hauteurMax)
		local h = hauteurMax or 1
		local y = alea:NextNumber(-h, h)
		local a = alea:NextNumber(0, math.pi * 2)
		local r = math.sqrt(1 - y * y)
		return Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
	end

	local function emetteur(parent, props)
		local e = Instance.new("ParticleEmitter")
		for cle, valeur in pairs(props) do
			e[cle] = valeur
		end
		e.Parent = parent
		return e
	end

	-- fait disparaitre une part en douceur puis la detruit
	local function effacer(part, attente, duree)
		task.delay(attente, function()
			if part.Parent then
				TweenService:Create(part, TweenInfo.new(duree, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
			end
		end)
		Debris:AddItem(part, attente + duree + 0.2)
	end

	-- disque plat (cylindre couche) centre sur un point du sol
	local function disque(nom, centre, diametre, epaisseur, couleur, materiau)
		return nouvellePart({
			Name = nom,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(epaisseur, diametre, diametre),
			CFrame = CFrame.new(centre + Vector3.new(0, epaisseur / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
			Material = materiau,
		})
	end

	-- ===== le rocher : Basalt bossele, veines Neon, face avant chauffee a blanc =====
	local function rocher(centre, d, sens)
		local m = { pieces = {}, veines = {} }
		-- coeur de lave : il transparait entre les blocs de basalte (veines lumineuses)
		m.coeur = nouvellePart({
			Name = "Meteore",
			Shape = Enum.PartType.Ball,
			Size = cube(d * 0.92),
			Position = centre,
			Color = ORANGE,
			Material = Enum.Material.Neon,
		})
		table.insert(m.pieces, m.coeur)
		table.insert(m.veines, m.coeur)
		-- six blocs de basalte autour du coeur : silhouette de vrai rocher, trois teintes pour le volume
		local axes = {
			Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 1, 0),
			Vector3.new(0, -1, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
		}
		local teintes = { BASALTE, BASALTE_SOMBRE, BASALTE_CLAIR }
		local tourne = CFrame.Angles(alea:NextNumber(0, 6.28), alea:NextNumber(0, 6.28), 0)
		for i, axe in ipairs(axes) do
			local dir = (tourne * (axe + directionAleatoire() * 0.18)).Unit
			local t = d * alea:NextNumber(0.52, 0.76)
			table.insert(m.pieces, nouvellePart({
				Name = "Bosse",
				Shape = Enum.PartType.Ball,
				Size = cube(t),
				Position = centre + dir * d * alea:NextNumber(0.24, 0.29),
				Color = teintes[(i - 1) % 3 + 1],
				Material = Enum.Material.Basalt,
			}))
		end
		-- veines de lave : fines lames Neon posees a fleur de roche
		for i = 1, 3 do
			local dir = directionAleatoire(0.8)
			local couleur = ORANGE
			if i % 2 == 0 then
				couleur = JAUNE
			end
			local veine = nouvellePart({
				Name = "Veine",
				Size = Vector3.new(0.3, d * 0.45, 0.3),
				CFrame = CFrame.lookAt(centre + dir * (d * 0.56 - 0.15), centre + dir * d) * CFrame.Angles(0, 0, alea:NextNumber(0, math.pi)),
				Color = couleur,
				Material = Enum.Material.Neon,
			})
			table.insert(m.veines, veine)
			table.insert(m.pieces, veine)
		end
		-- face avant incandescente, du cote de la chute
		m.front = nouvellePart({
			Name = "FrontChaud",
			Shape = Enum.PartType.Ball,
			Size = cube(d * 0.82),
			Position = centre + sens * d * 0.24,
			Color = JAUNE:Lerp(BLANC_CHAUD, 0.35),
			Material = Enum.Material.Neon,
			Transparency = 0.1,
		})
		table.insert(m.pieces, m.front)

		-- trainee de feu large : blanc chaud -> jaune -> orange -> braise -> fumee
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(d * 0.45, 0, 0)
		a0.Parent = m.coeur
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(-d * 0.45, 0, 0)
		a1.Parent = m.coeur
		local trainee = Instance.new("Trail")
		trainee.Attachment0 = a0
		trainee.Attachment1 = a1
		trainee.Lifetime = 0.6
		trainee.LightEmission = 0.9
		trainee.FaceCamera = true
		trainee.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BLANC_CHAUD),
			ColorSequenceKeypoint.new(0.15, JAUNE),
			ColorSequenceKeypoint.new(0.4, ORANGE),
			ColorSequenceKeypoint.new(0.7, BRAISE),
			ColorSequenceKeypoint.new(1, FUMEE_SOMBRE),
		})
		trainee.Transparency = suite({ { 0, 0 }, { 0.4, 0.2 }, { 0.75, 0.6 }, { 1, 1 } })
		trainee.WidthScale = suite({ { 0, 1 }, { 1, 0.25 } })
		trainee.Parent = m.coeur
		m.trainee = trainee
		-- flammes qui lechent le rocher
		m.feu = emetteur(m.coeur, {
			Texture = TEXTURE_FEU,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, BLANC_CHAUD),
				ColorSequenceKeypoint.new(0.25, JAUNE),
				ColorSequenceKeypoint.new(0.6, ORANGE),
				ColorSequenceKeypoint.new(1, BRAISE),
			}),
			LightEmission = 1,
			Size = suite({ { 0, d * 0.75 }, { 1, d * 0.2 } }),
			Transparency = suite({ { 0, 0.1 }, { 0.7, 0.5 }, { 1, 1 } }),
			Lifetime = NumberRange.new(0.35, 0.6),
			Speed = NumberRange.new(3, 6),
			SpreadAngle = Vector2.new(25, 25),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-90, 90),
			Rate = 70,
		})
		-- panache de fumee sombre
		m.fumee = emetteur(m.coeur, {
			Texture = TEXTURE_FUMEE,
			Color = ColorSequence.new(FUMEE_SOMBRE, FUMEE_CLAIRE),
			LightInfluence = 1,
			Size = suite({ { 0, d * 0.5 }, { 1, d * 1.8 } }),
			Transparency = suite({ { 0, 0.45 }, { 1, 1 } }),
			Lifetime = NumberRange.new(1.4, 2.2),
			Speed = NumberRange.new(1, 2.5),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-30, 30),
			Drag = 1,
			Rate = 28,
		})
		-- etincelles
		m.etincelles = emetteur(m.coeur, {
			Color = ColorSequence.new(JAUNE, ORANGE),
			LightEmission = 1,
			Size = suite({ { 0, 0.8 }, { 1, 0 } }),
			Lifetime = NumberRange.new(0.4, 0.7),
			Speed = NumberRange.new(4, 9),
			SpreadAngle = Vector2.new(180, 180),
			Rate = 22,
		})
		m.lueur = Instance.new("PointLight")
		m.lueur.Color = ORANGE
		m.lueur.Range = 24
		m.lueur.Brightness = 4
		m.lueur.Parent = m.coeur
		return m
	end

	-- ===== l'impact : eclair, onde de choc, fumee, cratere calcine, fissures de lave, eclats projetes =====
	local function impacter(impact, d, m)
		-- le rocher reste fiche dans le sol et refroidit (veines qui virent a la braise)
		pcall(function()
			m.trainee.Enabled = false
			m.feu.Enabled = false
			m.etincelles.Enabled = false
			m.fumee.Rate = 8
			animer(m.front, 0.4, QUAD, SORTIE, { Transparency = 1 })
			animer(m.lueur, 3, QUAD, SORTIE, { Brightness = 0 })
			for _, veine in ipairs(m.veines) do
				animer(veine, 2.8, Enum.EasingStyle.Linear, SORTIE, { Color = BRAISE_FROIDE })
			end
		end)
		task.delay(2.6, function()
			if m.fumee.Parent then
				m.fumee.Enabled = false
			end
		end)
		for _, piece in ipairs(m.pieces) do
			effacer(piece, 3.8, 1.2)
		end

		-- eclair blanc qui gonfle et s'evanouit
		local eclair = nouvellePart({
			Name = "Eclair",
			Shape = Enum.PartType.Ball,
			Size = cube(d * 1.3),
			Position = impact + Vector3.new(0, d * 0.4, 0),
			Color = BLANC_CHAUD,
			Material = Enum.Material.Neon,
			Transparency = 0.1,
		})
		animer(eclair, 0.35, QUAD, SORTIE, { Size = cube(d * 4.2), Transparency = 1 })
		Debris:AddItem(eclair, 0.5)

		-- onde de choc lumineuse puis anneau de poussiere plus lent
		local onde = disque("OndeDeChoc", impact + Vector3.new(0, 0.15, 0), d * 1.2, 0.35, JAUNE:Lerp(BLANC_CHAUD, 0.4), Enum.Material.Neon)
		onde.Transparency = 0.1
		animer(onde, 0.6, QUAD, SORTIE, { Size = Vector3.new(0.15, d * 7.5, d * 7.5), Transparency = 1 })
		Debris:AddItem(onde, 0.8)
		local poussiere = disque("Poussiere", impact + Vector3.new(0, 0.05, 0), d * 1.6, 0.6, POUSSIERE, Enum.Material.SmoothPlastic)
		poussiere.Transparency = 0.25
		animer(poussiere, 1.2, Enum.EasingStyle.Quint, SORTIE, { Size = Vector3.new(0.2, d * 5.5, d * 5.5), Transparency = 1 })
		Debris:AddItem(poussiere, 1.4)

		-- cratere : sol calcine, mare de lave qui refroidit
		local brulure = disque("CratereRebord", impact, d * 2.7, 0.18, CALCINE, Enum.Material.Basalt)
		effacer(brulure, 4.2, 1.4)
		local lave = disque("CratereCoeur", impact, d * 1.6, 0.3, ORANGE, Enum.Material.Neon)
		animer(lave, 2.4, Enum.EasingStyle.Linear, SORTIE, { Color = BRAISE_FROIDE })
		effacer(lave, 2.2, 2)

		-- fissures de lave qui rayonnent depuis le rocher
		for i = 1, 4 do
			local angle = (i / 4) * math.pi * 2 + alea:NextNumber(-0.5, 0.5)
			local longueur = d * alea:NextNumber(0.45, 0.72)
			local milieu = d * 0.55 + longueur / 2
			local fissure = nouvellePart({
				Name = "Fissure",
				Size = Vector3.new(longueur, 0.3, alea:NextNumber(0.25, 0.4)),
				CFrame = CFrame.new(impact + Vector3.new(math.cos(angle) * milieu, 0.12, math.sin(angle) * milieu)) * CFrame.Angles(0, -angle, 0),
				Color = JAUNE:Lerp(ORANGE, 0.5),
				Material = Enum.Material.Neon,
			})
			animer(fissure, 2.4, Enum.EasingStyle.Linear, SORTIE, { Color = BRAISE_FROIDE })
			effacer(fissure, 1.8, 1.8)
		end

		-- rebord : dalles de basalte soulevees, qui jaillissent du sol
		for i = 1, 6 do
			local angle = (i / 6) * math.pi * 2 + alea:NextNumber(-0.25, 0.25)
			local dist = d * alea:NextNumber(1.1, 1.3)
			local l = alea:NextNumber(1.4, 2.4)
			local h = alea:NextNumber(0.8, 1.5)
			local couleur = BASALTE
			if i % 2 == 0 then
				couleur = BASALTE_SOMBRE
			end
			local cf = CFrame.new(impact + Vector3.new(math.cos(angle) * dist, h * 0.3, math.sin(angle) * dist))
				* CFrame.Angles(0, -angle, 0)
				* CFrame.Angles(0, 0, -math.rad(alea:NextNumber(18, 32)))
			local dalle = nouvellePart({
				Name = "Rebord",
				Size = Vector3.new(l, h, l * 0.7),
				CFrame = cf * CFrame.new(0, -h, 0),
				Color = couleur,
				Material = Enum.Material.Basalt,
			})
			animer(dalle, 0.22, Enum.EasingStyle.Back, SORTIE, { CFrame = cf })
			effacer(dalle, 3.8, 1.2)
		end

		-- eclats projetes en cloche (deux braises Neon, le reste en basalte)
		for i = 1, 5 do
			local angle = alea:NextNumber(0, math.pi * 2)
			local dist = d * alea:NextNumber(1.8, 2.8)
			local t = alea:NextNumber(0.7, 1.3)
			local couleur = BASALTE_CLAIR
			local materiau = Enum.Material.Basalt
			if i <= 2 then
				couleur = ORANGE
				materiau = Enum.Material.Neon
			end
			local depart = impact + Vector3.new(0, d * 0.5, 0)
			local arrivee = impact + Vector3.new(math.cos(angle) * dist, t * 0.35, math.sin(angle) * dist)
			local sommet = depart:Lerp(arrivee, 0.5) + Vector3.new(0, d * 0.9, 0)
			local eclat = nouvellePart({
				Name = "Debris",
				Size = Vector3.new(t, t * 0.8, t),
				CFrame = CFrame.new(depart),
				Color = couleur,
				Material = materiau,
			})
			animer(eclat, 0.25, QUAD, SORTIE, { CFrame = CFrame.new(sommet) * CFrame.Angles(alea:NextNumber(0, 3), alea:NextNumber(0, 3), 0) })
			task.delay(0.25, function()
				if eclat.Parent then
					animer(eclat, 0.3, QUAD, ENTREE, { CFrame = CFrame.new(arrivee) * CFrame.Angles(alea:NextNumber(0, 3), alea:NextNumber(0, 3), alea:NextNumber(0, 3)) })
				end
			end)
			if i <= 2 then
				animer(eclat, 2.5, Enum.EasingStyle.Linear, SORTIE, { Color = BRAISE_FROIDE })
			end
			effacer(eclat, 3, 1)
		end

		-- bouffee de fumee et gerbe d'etincelles
		local souffle = nouvellePart({
			Name = "Souffle",
			Size = Vector3.new(d, 0.5, d),
			Position = impact + Vector3.new(0, 0.6, 0),
			Transparency = 1,
		})
		local nuage = emetteur(souffle, {
			Texture = TEXTURE_FUMEE,
			Color = ColorSequence.new(POUSSIERE, FUMEE_CLAIRE),
			LightInfluence = 1,
			Size = suite({ { 0, d * 0.5 }, { 1, d * 1.7 } }),
			Transparency = suite({ { 0, 0.3 }, { 0.7, 0.6 }, { 1, 1 } }),
			Lifetime = NumberRange.new(1.2, 2),
			Speed = NumberRange.new(6, 12),
			SpreadAngle = Vector2.new(80, 80),
			Drag = 3,
			Acceleration = Vector3.new(0, 3, 0),
			Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-40, 40),
			Rate = 0,
		})
		local gerbe = emetteur(souffle, {
			Color = ColorSequence.new(BLANC_CHAUD, ORANGE),
			LightEmission = 1,
			Size = suite({ { 0, 0.6 }, { 1, 0 } }),
			Lifetime = NumberRange.new(0.6, 1.1),
			Speed = NumberRange.new(22, 38),
			SpreadAngle = Vector2.new(55, 55),
			Acceleration = Vector3.new(0, -60, 0),
			Rate = 0,
		})
		pcall(function()
			nuage:Emit(18)
			gerbe:Emit(30)
		end)
		local flash = Instance.new("PointLight")
		flash.Color = JAUNE
		flash.Range = 30
		flash.Brightness = 6
		flash.Parent = souffle
		animer(flash, 0.8, QUAD, SORTIE, { Brightness = 0 })
		Debris:AddItem(souffle, 2.6)
	end

	local function lancerMeteore()
		local impact = pointAleatoire()
		local depart = impact + Vector3.new(alea:NextNumber(-40, 40), HAUTEUR_CHUTE, alea:NextNumber(-40, 40))
		local d = alea:NextNumber(5, 7)
		local arrivee = impact + Vector3.new(0, d * 0.3, 0) -- le rocher finit a moitie enfonce
		local deplacement = arrivee - depart
		local m = rocher(depart, d, deplacement.Unit)
		for _, piece in ipairs(m.pieces) do
			Debris:AddItem(piece, DUREE_CHUTE + 6)
		end

		-- toutes les pieces glissent du meme vecteur, avec la meme courbe : le rocher reste solidaire
		local info = TweenInfo.new(DUREE_CHUTE, QUAD, ENTREE)
		local tween = nil
		for _, piece in ipairs(m.pieces) do
			local t = TweenService:Create(piece, info, { Position = piece.Position + deplacement })
			if piece == m.coeur then
				tween = t
			end
			t:Play()
		end
		tween.Completed:Connect(function()
			effetTous("Meteore", impact, {})
			pcall(impacter, impact, d, m)
		end)
	end

	-- ===== deroulement =====
	local generation = 0 -- change a chaque debut : invalide les fins et pluies de l'evenement precedent

	local function terminer(gen)
		if gen ~= generation then
			return
		end
		local nom = Etat:GetAttribute("Evenement")
		if type(nom) ~= "string" or nom == "" then
			return
		end
		generation = generation + 1
		Etat:SetAttribute("Evenement", "")
		Etat:SetAttribute("EvenementFin", 0)
		majTitre()
		Bus.emettre("EvenementFin", nom)
		notifierTous(nomAffiche(nom) .. " : c'est fini !", "info")
	end

	local function pluie(gen)
		while gen == generation and Etat:GetAttribute("Evenement") == "PluieDeMeteores" do
			pcall(lancerMeteore)
			task.wait(PERIODE_METEORE)
		end
	end

	local function lancer(nom)
		if type(nom) ~= "string" or not liste[nom] then
			return false
		end
		-- un evenement deja en cours se termine proprement avant le nouveau
		local enCours = Etat:GetAttribute("Evenement")
		if type(enCours) == "string" and enCours ~= "" then
			terminer(generation)
		end
		generation = generation + 1
		local gen = generation
		local debut = maintenant()
		Etat:SetAttribute("Evenement", nom)
		Etat:SetAttribute("EvenementFin", debut + duree)
		Etat:SetAttribute("ProchainEvenement", debut + intervalle)
		majTitre()
		Bus.emettre("EvenementDebut", nom)
		notifierTous("Événement : " .. nomAffiche(nom) .. " !", "alerte")
		effetTous("Evenement", Plan.cratere.centre, { nom = nom })
		if nom == "PluieDeMeteores" then
			task.spawn(pluie, gen)
		end
		task.delay(duree, function()
			terminer(gen)
		end)
		return true
	end

	Bus.repondre("LancerEvenement", function(nom)
		return lancer(nom)
	end)

	-- ===== horloge =====
	Etat:SetAttribute("Evenement", "")
	Etat:SetAttribute("EvenementFin", 0)
	Etat:SetAttribute("ProchainEvenement", maintenant() + PREMIER_DELAI)

	-- compte a rebours du titre, rafraichi plus souvent que l'horloge
	task.spawn(function()
		while true do
			majTitre()
			task.wait(0.5)
		end
	end)

	while true do
		task.wait(1)
		local enCours = Etat:GetAttribute("Evenement")
		local libre = type(enCours) ~= "string" or enCours == ""
		local prochain = tonumber(Etat:GetAttribute("ProchainEvenement")) or 0
		if libre and #noms > 0 and maintenant() >= prochain then
			local ok = pcall(lancer, noms[alea:NextInteger(1, #noms)])
			if not ok then
				Etat:SetAttribute("ProchainEvenement", maintenant() + intervalle)
			end
		end
	end
end

return M
