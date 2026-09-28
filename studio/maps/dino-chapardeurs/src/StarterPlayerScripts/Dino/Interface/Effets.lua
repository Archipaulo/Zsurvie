-- Interface/Effets : effets visuels locaux déclenchés par le serveur (Reseau.Effet).
-- Tout est construit côté client dans workspace.EffetsLocaux : parts ancrées, non collidables, nettoyées par Debris.
-- Version 2 : les éclats sont des ParticleEmitter (étincelles, fumée, feu) émis en rafale depuis une seule part
-- support ; ondes de choc en anneaux segmentés Neon ; traînées (Trail) sur les fusées et les orbes.
-- Un seul moteur (Heartbeat) anime les parts ; au plus MAX_PARTS parts et MAX_PARTICULES particules à la fois.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local M = {}

-- réglages purement visuels (les chiffres de jeu viennent de ctx.Equilibrage)
local MAX_PARTS = 150
local MAX_PARTICULES = 450    -- particules vivantes au plus (toutes rafales confondues)
local DISTANCE_MAX = 380      -- au-delà, un effet dans le monde n'est pas affiché
local DISTANCE_PROCHE = 90    -- en deçà : effets complets ; au-delà : rafales allégées
local DISTANCE_SECOUSSE = 80  -- rayon de la secousse de caméra d'un météore
local HAUTEUR_DOME = 18
local TAU = math.pi * 2

-- textures de particules intégrées à Roblox
local TEX = {
	etincelle = "rbxasset://textures/particles/sparkles_main.dds",
	fumee = "rbxasset://textures/particles/smoke_main.dds",
	feu = "rbxasset://textures/particles/fire_main.dds",
}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local Style = ctx.Style
	local SC = Style.couleurs
	local E = ctx.Equilibrage
	local joueur = ctx.joueur
	local alea = Random.new()

	local function r(a, b)
		return alea:NextNumber(a, b)
	end

	-- ===== dossier local et budget de parts =====
	local dossier = workspace:FindFirstChild("EffetsLocaux")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "EffetsLocaux"
		dossier.Parent = workspace
	end

	local actifs = {}
	local function compter()
		for i = #actifs, 1, -1 do
			if actifs[i].Parent == nil then
				table.remove(actifs, i)
			end
		end
		return #actifs
	end

	local function placesLibres()
		return MAX_PARTS - compter()
	end

	-- crée une part d'effet (nil si le budget est atteint) ; Shape est posée avant Size
	local function nouvellePart(props, duree)
		if compter() >= MAX_PARTS then return nil end
		local p = Instance.new("Part")
		if props.Shape then p.Shape = props.Shape end
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.Neon
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Color = Charte.creme
		for cle, valeur in pairs(props) do
			if cle ~= "Parent" and cle ~= "Shape" then
				p[cle] = valeur
			end
		end
		p.Parent = dossier
		table.insert(actifs, p)
		Debris:AddItem(p, duree or 5)
		return p
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

	local function camera()
		return workspace.CurrentCamera
	end

	local function visible(position)
		local cam = camera()
		if not cam or not position then return true end
		return (cam.CFrame.Position - position).Magnitude <= DISTANCE_MAX
	end

	-- facteur de densité selon la distance à la caméra (les effets lointains sont allégés)
	local function qualite(position)
		local cam = camera()
		if not cam or not position then return 1 end
		local d = (cam.CFrame.Position - position).Magnitude
		if d <= DISTANCE_PROCHE then return 1 end
		if d <= 200 then return 0.6 end
		return 0.35
	end

	-- ===== budget de particules =====
	local vivantes = {}
	local function reserver(n, vie)
		local maintenant = os.clock()
		local total = 0
		for i = #vivantes, 1, -1 do
			if vivantes[i].fin < maintenant then
				table.remove(vivantes, i)
			else
				total = total + vivantes[i].n
			end
		end
		n = math.min(math.floor(n + 0.5), MAX_PARTICULES - total)
		if n <= 0 then return 0 end
		table.insert(vivantes, { fin = maintenant + vie, n = n })
		return n
	end

	-- NumberSequence à partir d'un nombre ou d'une liste { t0, v0, t1, v1, ... }
	local function suite(points)
		if type(points) == "number" then return NumberSequence.new(points) end
		local cles = {}
		for i = 1, #points, 2 do
			table.insert(cles, NumberSequenceKeypoint.new(points[i], points[i + 1]))
		end
		return NumberSequence.new(cles)
	end

	-- ParticleEmitter réglé ; o : texture, couleur, couleur2, taille, transparence, vie {min,max}, vitesse {min,max},
	-- ecart (degrés), acceleration, frein, tourne, direction, lumiere, eclat, debit, zDecalage
	local function emetteur(parent, o)
		local e = Instance.new("ParticleEmitter")
		e.Name = o.nom or "Particules"
		e.Enabled = false
		e.Rate = o.debit or 0
		e.Texture = o.texture or TEX.etincelle
		e.Color = ColorSequence.new(o.couleur or SC.texte, o.couleur2 or o.couleur or SC.texte)
		e.LightEmission = o.lumiere or 1
		e.LightInfluence = 0
		e.Brightness = o.eclat or 1.5
		e.Size = suite(o.taille or { 0, 1, 1, 0 })
		e.Transparency = suite(o.transparence or { 0, 0, 0.7, 0.15, 1, 1 })
		local vie = o.vie or { 0.6, 1 }
		e.Lifetime = NumberRange.new(vie[1], vie[2])
		local vitesse = o.vitesse or { 8, 14 }
		e.Speed = NumberRange.new(vitesse[1], vitesse[2])
		local ecart = o.ecart or 180
		e.SpreadAngle = Vector2.new(ecart, ecart)
		e.Acceleration = o.acceleration or Vector3.new(0, 0, 0)
		e.Drag = o.frein or 0
		e.Rotation = NumberRange.new(0, 360)
		local tourne = o.tourne or 90
		e.RotSpeed = NumberRange.new(-tourne, tourne)
		e.EmissionDirection = o.direction or Enum.NormalId.Top
		e.ZOffset = o.zDecalage or 0
		e.Parent = parent
		return e
	end

	-- rafale : une seule part support invisible porte un ou plusieurs émetteurs, chacun émet n particules d'un coup
	-- liste : { { n = , ...réglages d'emetteur }, ... } ; zone : taille de la part (volume d'émission)
	local function rafale(position, liste, zone)
		if not position then return nil end
		local facteur = qualite(position)
		local vieMax = 0
		for _, o in ipairs(liste) do
			local vie = o.vie or { 0.6, 1 }
			vieMax = math.max(vieMax, vie[2])
		end
		local support = nouvellePart({
			Name = "Rafale",
			Size = zone or Vector3.new(0.4, 0.4, 0.4),
			Transparency = 1,
			CFrame = CFrame.new(position),
		}, vieMax + 0.6)
		if not support then return nil end
		for _, o in ipairs(liste) do
			local vie = o.vie or { 0.6, 1 }
			local n = reserver((o.n or 12) * facteur, vie[2])
			if n > 0 then
				local e = emetteur(support, o)
				e:Emit(n)
			end
		end
		return support
	end

	-- réglages d'étincelles lumineuses (le plus courant)
	local function etincelles(n, couleur, couleur2, props)
		local o = {
			n = n,
			texture = TEX.etincelle,
			couleur = couleur,
			couleur2 = couleur2 or couleur,
			taille = { 0, 0.9, 0.25, 0.7, 1, 0 },
			transparence = { 0, 0, 0.75, 0.1, 1, 1 },
			vie = { 0.5, 0.9 },
			vitesse = { 10, 18 },
			frein = 3,
			acceleration = Vector3.new(0, -12, 0),
			tourne = 200,
			eclat = 2,
		}
		if props then
			for cle, valeur in pairs(props) do o[cle] = valeur end
		end
		return o
	end

	-- ===== moteur de parts animées =====
	local particules = {}
	local connexion = nil
	local VERTICAL = CFrame.Angles(0, 0, math.pi / 2) -- un cylindre Roblox a son axe sur X

	local function pas(dt)
		for i = #particules, 1, -1 do
			local q = particules[i]
			local p = q.part
			q.age = q.age + dt
			if q.age >= q.vie or p.Parent == nil then
				table.remove(particules, i)
				if p.Parent ~= nil then
					if q.garder then
						-- la part s'éteint mais reste le temps que sa traînée s'efface (Debris la retire)
						p.Transparency = 1
					else
						p:Destroy()
					end
				end
			else
				local k = q.age / q.vie
				if q.anneau then
					-- segment d'une onde de choc : glisse vers l'extérieur en s'allongeant et s'amincissant
					local a = q.anneau
					local s = 1 - (1 - k) * (1 - k) * (1 - k)
					local rayon = a.r0 + (a.r1 - a.r0) * s
					q.pos = a.centre + Vector3.new(math.cos(a.angle) * rayon, a.montee * s, math.sin(a.angle) * rayon)
					p.Size = Vector3.new(TAU * rayon / a.n * 1.12, q.taille.Y * (1 - 0.5 * k), q.taille.Z * (1 - 0.6 * k))
				elseif q.cible and q.cible.Parent ~= nil then
					-- suit un modèle (colonne sur un dino qui avance)
					local ok, pivot = pcall(function() return q.cible:GetPivot() end)
					if ok and pivot then q.pos = pivot.Position + q.decalage end
				elseif q.orbite then
					local o = q.orbite
					local angle = o.angle + o.vitesse * q.age
					local rayon = math.max(0, o.rayon + (o.ouverture or 0) * q.age)
					q.pos = o.centre + Vector3.new(math.cos(angle) * rayon, o.montee * q.age, math.sin(angle) * rayon)
				else
					q.vel = q.vel - Vector3.new(0, q.gravite * dt, 0)
					if q.frein > 0 then
						q.vel = q.vel * math.max(0, 1 - q.frein * dt)
					end
					q.pos = q.pos + q.vel * dt
				end
				q.rot = q.rot + q.vrot * dt
				if q.croissance ~= 0 then
					p.Size = q.taille * math.max(0.05, 1 + q.croissance * q.age)
				end
				p.CFrame = CFrame.new(q.pos) * CFrame.Angles(q.rot.X, q.rot.Y, q.rot.Z) * q.base
				if q.fondu then
					local f = 0
					if k > q.debutFondu then
						f = (k - q.debutFondu) / (1 - q.debutFondu)
					end
					p.Transparency = q.t0 + (1 - q.t0) * f * f
				end
			end
		end
		if #particules == 0 and connexion then
			connexion:Disconnect()
			connexion = nil
		end
	end

	local function assurerMoteur()
		if connexion then return end
		connexion = RunService.Heartbeat:Connect(function(dt)
			local ok = pcall(pas, dt)
			if not ok then
				-- un état incohérent : on vide proprement plutôt que de boucler en erreur
				for _, q in ipairs(particules) do
					pcall(function() q.part:Destroy() end)
				end
				particules = {}
			end
		end)
	end

	-- confie une part existante au moteur
	local function animer(p, o)
		local q = {
			part = p,
			pos = o.pos or p.Position,
			vel = o.vel or Vector3.new(0, 0, 0),
			gravite = o.gravite or 0,
			frein = o.frein or 0,
			vie = o.vie or 1,
			age = 0,
			rot = o.rot or Vector3.new(0, 0, 0),
			vrot = o.vrot or Vector3.new(0, 0, 0),
			taille = p.Size,
			croissance = o.croissance or 0,
			t0 = p.Transparency,
			fondu = o.fondu ~= false,
			debutFondu = o.debutFondu or 0,
			orbite = o.orbite,
			anneau = o.anneau,
			cible = o.cible,
			garder = o.garder == true,
			decalage = o.decalage or Vector3.new(0, 0, 0),
			base = o.base or CFrame.new(),
		}
		if q.anneau then q.pos = q.anneau.centre end
		p.CFrame = CFrame.new(q.pos) * CFrame.Angles(q.rot.X, q.rot.Y, q.rot.Z) * q.base
		table.insert(particules, q)
		assurerMoteur()
		return q
	end

	local function particule(props, o, dureeEnPlus)
		local p = nouvellePart(props, (o.vie or 1) + (dureeEnPlus or 1))
		if not p then return nil end
		animer(p, o)
		return p
	end

	local function rotAleatoire()
		return Vector3.new(r(0, 6.28), r(0, 6.28), r(0, 6.28))
	end

	local function vrotAleatoire(v)
		return Vector3.new(r(-v, v), r(-v, v), r(-v, v))
	end

	-- gerbe : n parts lancées depuis une position (nombre plafonné par le budget)
	local function gerbe(position, n, fabrique)
		local nombre = math.min(math.floor(n * qualite(position) + 0.5), placesLibres())
		for i = 1, nombre do
			fabrique(i, position)
		end
	end

	-- traînée lumineuse (Trail) sur une part animée ; largeur en studs, vie en secondes
	local function trainee(p, couleur, couleur2, largeur, vie)
		local demi = (largeur or 0.6) / 2
		local a0 = Instance.new("Attachment")
		a0.Name = "TraineeA"
		a0.Position = Vector3.new(0, demi, 0)
		a0.Parent = p
		local a1 = Instance.new("Attachment")
		a1.Name = "TraineeB"
		a1.Position = Vector3.new(0, -demi, 0)
		a1.Parent = p
		local t = Instance.new("Trail")
		t.Name = "Trainee"
		t.Attachment0 = a0
		t.Attachment1 = a1
		t.Color = ColorSequence.new(couleur, couleur2 or couleur)
		t.Transparency = suite({ 0, 0.05, 0.6, 0.5, 1, 1 })
		t.WidthScale = suite({ 0, 1, 1, 0.1 })
		t.Lifetime = vie or 0.35
		t.MinLength = 0.05
		t.LightEmission = 1
		t.LightInfluence = 0
		t.FaceCamera = true
		t.Parent = p
		return t
	end

	-- point du sol sous une position (les ondes collent au sol même si l'effet est annoncé à hauteur de buste)
	local function auSol(position)
		local ok, resultat = pcall(function()
			local filtre = { dossier, ctx.dinos }
			for _, j in ipairs(Players:GetPlayers()) do
				if j.Character then table.insert(filtre, j.Character) end
			end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = filtre
			params.RespectCanCollide = true
			return workspace:Raycast(position + Vector3.new(0, 1, 0), Vector3.new(0, -9, 0), params)
		end)
		if ok and resultat then
			return Vector3.new(position.X, resultat.Position.Y, position.Z)
		end
		return position
	end

	-- onde de choc : anneau de segments Neon qui s'ouvre au sol (horizontal) puis s'évanouit
	-- o : depart, rayon, vie, epaisseur, hauteur, segments, transparence, montee, leve (hauteur au-dessus du sol)
	local function onde(centre, couleur, o)
		if not centre then return end
		o = o or {}
		centre = auSol(centre) + Vector3.new(0, o.leve or 0.3, 0)
		local n = math.min(o.segments or 16, placesLibres() - 12)
		if n < 8 then return end
		local vie = o.vie or 0.55
		for i = 1, n do
			local angle = (i - 1) / n * TAU
			local seg = nouvellePart({
				Name = "Onde",
				Size = Vector3.new(1, o.hauteur or 0.3, o.epaisseur or 0.6),
				Color = couleur,
				Transparency = o.transparence or 0.05,
			}, vie + 0.5)
			if seg then
				animer(seg, {
					anneau = {
						centre = centre,
						angle = angle,
						r0 = o.depart or 1,
						r1 = o.rayon or 10,
						n = n,
						montee = o.montee or 0,
					},
					rot = Vector3.new(0, -angle - math.pi / 2, 0),
					vie = vie,
					debutFondu = 0.2,
				})
			end
		end
	end

	-- éclair lumineux (boule Neon qui gonfle et s'efface) avec lumière ponctuelle
	local function flash(position, couleur, taille, vie, portee)
		local b = nouvellePart({
			Name = "Flash",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(taille, taille, taille),
			Color = couleur,
			Transparency = 0.25,
		}, vie + 0.5)
		if not b then return nil end
		if portee then
			local lumiere = Instance.new("PointLight")
			lumiere.Color = couleur
			lumiere.Range = portee
			lumiere.Brightness = 3
			lumiere.Parent = b
			tween(lumiere, vie, { Brightness = 0 })
		end
		animer(b, { pos = position, croissance = 3 / math.max(vie, 0.05), vie = vie })
		return b
	end

	-- ===== textes flottants dans le monde =====
	-- efface un texte cerné (le texte et son contour noir)
	local function fondre(t, duree)
		if not t or t.Parent == nil then return end
		tween(t, duree, { TextTransparency = 1 })
		local s = t:FindFirstChild("Contour")
		if s then tween(s, duree, { Transparency = 1 }) end
	end

	-- texte cerné de noir qui jaillit, monte et grossit (style simulateur : « +$1,2K » vert)
	-- options : degrade = { haut, bas } ou rarete = clé (le texte est alors blanc sous le dégradé), contour
	local function texteFlottant(position, texte, couleur, hauteur, duree, options)
		duree = duree or 1.8
		options = options or {}
		local p = nouvellePart({ Name = "Texte", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1 }, duree + 0.5)
		if not p then return end
		local largeur = hauteur * 4.5
		local bb = Instance.new("BillboardGui")
		bb.Name = "Texte"
		bb.Adornee = p
		bb.AlwaysOnTop = true
		bb.LightInfluence = 0
		bb.MaxDistance = 220
		bb.Size = UDim2.new(largeur * 0.3, 0, hauteur * 0.3, 0)
		bb.Parent = p
		local etiquette = Style.texte(bb, {
			Name = "Texte",
			Size = UDim2.fromScale(1, 1),
			Text = texte,
			TextColor3 = couleur or SC.argent,
			titre = true,
			contour = options.contour or 4,
		})
		if options.rarete then
			etiquette.TextColor3 = SC.texte
			Style.degradeRarete(etiquette, options.rarete)
		elseif options.degrade then
			etiquette.TextColor3 = SC.texte
			Style.degrade(etiquette, options.degrade[1], options.degrade[2])
		end
		animer(p, { pos = position, vel = Vector3.new(0, 7, 0), frein = 1, vie = duree, fondu = false })
		-- pop d'apparition puis lente croissance pendant la montée
		tween(bb, 0.22, { Size = UDim2.new(largeur * 1.1, 0, hauteur * 1.1, 0) }, Enum.EasingStyle.Back)
		task.delay(0.22, function()
			if bb.Parent then
				tween(bb, math.max(duree - 0.22, 0.1), { Size = UDim2.new(largeur * 1.4, 0, hauteur * 1.4, 0) }, Enum.EasingStyle.Sine)
			end
		end)
		task.delay(duree * 0.6, function()
			fondre(etiquette, duree * 0.4)
		end)
	end

	-- ===== secousse de caméra =====
	local secousse = { fin = 0, duree = 1, force = 0, liee = false }
	local NOM_SECOUSSE = "DinoSecousseEffets"

	local function secouer(force, duree)
		local maintenant = os.clock()
		if maintenant < secousse.fin then
			secousse.force = math.max(secousse.force, force)
		else
			secousse.force = force
		end
		secousse.duree = duree
		secousse.fin = maintenant + duree
		if secousse.liee then return end
		local ok = pcall(function()
			RunService:BindToRenderStep(NOM_SECOUSSE, Enum.RenderPriority.Camera.Value + 1, function()
				local reste = secousse.fin - os.clock()
				if reste <= 0 then
					pcall(function() RunService:UnbindFromRenderStep(NOM_SECOUSSE) end)
					secousse.liee = false
					secousse.force = 0
					return
				end
				local cam = camera()
				if cam then
					local a = secousse.force * (reste / secousse.duree)
					cam.CFrame = cam.CFrame * CFrame.new(r(-a, a), r(-a, a), 0) * CFrame.Angles(0, 0, math.rad(r(-a, a) * 1.5))
				end
			end)
		end)
		secousse.liee = ok
	end

	local function positionPersonnage()
		local perso = joueur.Character
		if not perso then return nil end
		local racine = perso:FindFirstChild("HumanoidRootPart")
		if racine then return racine.Position end
		return nil
	end

	-- ===== couche d'écran =====
	local couche = ctx.gui:FindFirstChild("EffetsEcran")
	if not couche then
		couche = Instance.new("Frame")
		couche.Name = "EffetsEcran"
		couche.Size = UDim2.fromScale(1, 1)
		couche.BackgroundTransparency = 1
		couche.Active = false
		couche.ZIndex = 40
		couche.Parent = ctx.gui
	end

	-- ===== couleurs utiles (tirées de ctx.Style) =====
	local B = Style.boutons
	local OR = { B.jaune[1], B.jaune[2] }      -- dégradé « BONK ! » / titres dorés
	local VIOLET = { B.violet[1], B.violet[2] }

	-- couleur franche d'une rareté (pour la lumière dans le monde)
	local function couleurRarete(rarete)
		local def = type(rarete) == "string" and Style.raretes[rarete]
		if def and def[1] and def[2] then
			return def[1]:Lerp(def[2], 0.6)
		end
		if rarete == "Divin" then return B.rose[1] end
		if rarete == "Secret" then return SC.texte end
		return SC.revenu
	end

	local function ordreRarete(rarete)
		local infos = type(rarete) == "string" and E.raretes[rarete]
		if infos then return infos.ordre end
		return 1
	end

	-- nom de rareté en capitales (string.upper ne gère pas les accents)
	local RARETES_MAJ = {
		Commun = "COMMUN", Rare = "RARE", Epique = "ÉPIQUE", Legendaire = "LÉGENDAIRE",
		Mythique = "MYTHIQUE", Divin = "DIVIN", Secret = "SECRET",
	}
	local function rareteMaj(rarete)
		if type(rarete) ~= "string" then return "" end
		if RARETES_MAJ[rarete] then return RARETES_MAJ[rarete] end
		local infos = E.raretes[rarete]
		return string.upper((infos and infos.nom) or rarete)
	end

	local CONFETTIS = {
		SC.argent, SC.revenu, B.bleu[1], B.violet[1], B.rouge[1], B.rose[1], B.orange[1], SC.texte,
	}

	local COULEURS_EVENEMENT = {
		PluieDeMeteores = B.violet[2],
		Eruption = B.orange[2],
		LuneDoree = B.jaune[1],
	}

	-- confettis d'écran : petits rectangles vifs qui tombent en tournoyant
	local function confettisEcran(n)
		for i = 1, n do
			local c = Instance.new("Frame")
			c.Name = "Confetti"
			c.BorderSizePixel = 0
			c.AnchorPoint = Vector2.new(0.5, 0.5)
			c.BackgroundColor3 = CONFETTIS[(i % #CONFETTIS) + 1]
			c.Size = UDim2.fromOffset(math.floor(r(10, 18)), math.floor(r(6, 10)))
			local x = r(0.05, 0.95)
			c.Position = UDim2.new(x, 0, r(-0.12, -0.02), 0)
			c.Rotation = r(0, 360)
			c.ZIndex = 47
			Style.coins(c, 2)
			c.Parent = couche
			local duree = r(1.8, 2.8)
			tween(c, duree, {
				Position = UDim2.new(x + r(-0.12, 0.12), 0, r(0.75, 1.05), 0),
				Rotation = c.Rotation + r(-540, 540),
			}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(duree * 0.7, function()
				if c.Parent then tween(c, duree * 0.3, { BackgroundTransparency = 1 }) end
			end)
			Debris:AddItem(c, duree + 0.1)
		end
	end

	-- bandeau sombre en fondu horizontal, lisere doré dessus et dessous (derrière les grands titres d'écran)
	local function bandeau(parent, hauteur, y, zindex)
		local b = Instance.new("Frame")
		b.Name = "Bandeau"
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.new(0.5, 0, 0, y)
		b.Size = UDim2.new(1.3, 0, 0, hauteur)
		b.BackgroundColor3 = SC.ombre
		b.BackgroundTransparency = 0
		b.BorderSizePixel = 0
		b.ZIndex = zindex
		local g = Instance.new("UIGradient")
		g.Transparency = suite({ 0, 1, 0.2, 0.45, 0.8, 0.45, 1, 1 })
		g.Parent = b
		for _, bord in ipairs({ 0, 1 }) do
			local lisere = Instance.new("Frame")
			lisere.Name = "Lisere"
			lisere.AnchorPoint = Vector2.new(0.5, bord)
			lisere.Position = UDim2.new(0.5, 0, bord, 0)
			lisere.Size = UDim2.new(1, 0, 0, 3)
			lisere.BackgroundColor3 = OR[1]
			lisere.BorderSizePixel = 0
			lisere.ZIndex = zindex
			local gl = Instance.new("UIGradient")
			gl.Transparency = suite({ 0, 1, 0.3, 0.1, 0.7, 0.1, 1, 1 })
			gl.Parent = lisere
			lisere.Parent = b
		end
		b.Parent = parent
		return b
	end

	-- ===== les effets =====
	local effets = {}

	-- dino rare sur le Tapis : colonne de lumière qui le suit, pluie d'étincelles montantes, orbes à traînée
	function effets.Apparition(position, d)
		if not visible(position) then return end
		local couleur = couleurRarete(d.rarete)
		if d.mutation and d.mutation ~= "Normal" and Charte.mutations[d.mutation] and ordreRarete(d.rarete) < 4 then
			couleur = Charte.mutations[d.mutation]
		end
		local clair = couleur:Lerp(SC.texte, 0.55)
		local ordre = ordreRarete(d.rarete)
		-- retrouve le dino le plus proche de la position annoncée
		local cible, meilleure = nil, 14
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:IsA("Model") and dino:GetAttribute("Etat") == "Tapis"
				and (d.espece == nil or dino:GetAttribute("Espece") == d.espece) then
				local ok, pivot = pcall(function() return dino:GetPivot() end)
				if ok and pivot then
					local ecart = (pivot.Position - position).Magnitude
					if ecart < meilleure then
						cible = dino
						meilleure = ecart
					end
				end
			end
		end
		local duree = 3.5 + ordre * 0.5
		local hauteur = 40 + ordre * 8
		local colonne = nouvellePart({
			Name = "Colonne",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(hauteur, 4 + ordre * 0.4, 4 + ordre * 0.4),
			Color = couleur,
			Transparency = 0.55,
		}, duree + 1.5)
		if colonne then
			animer(colonne, {
				pos = position + Vector3.new(0, hauteur / 2, 0),
				cible = cible,
				decalage = Vector3.new(0, hauteur / 2, 0),
				vie = duree,
				base = VERTICAL,
				debutFondu = 0.6,
				garder = true,
			})
			-- étincelles qui montent le long de la colonne tant qu'elle brille (débit continu, budget réservé)
			local debit = math.floor((8 + ordre * 2) * qualite(position))
			if debit > 0 and reserver(debit * 1.6, duree) > 0 then
				local montee = emetteur(colonne, etincelles(0, clair, couleur, {
					debit = debit,
					vitesse = { 2, 5 },
					ecart = 12,
					direction = Enum.NormalId.Right,
					frein = 0,
					acceleration = Vector3.new(0, 4, 0),
					vie = { 1, 1.6 },
					taille = { 0, 0.3, 0.2, 0.9, 1, 0 },
				}))
				montee.Enabled = true
				task.delay(duree * 0.7, function()
					if montee.Parent then montee.Enabled = false end
				end)
			end
		end
		-- cœur blanc lumineux au centre de la colonne
		local coeur = nouvellePart({
			Name = "ColonneCoeur",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(hauteur, 1.2, 1.2),
			Color = clair,
			Transparency = 0.15,
		}, duree + 1)
		if coeur then
			animer(coeur, {
				pos = position + Vector3.new(0, hauteur / 2, 0),
				cible = cible,
				decalage = Vector3.new(0, hauteur / 2, 0),
				vie = duree,
				base = VERTICAL,
				debutFondu = 0.6,
			})
		end
		-- Divin : la colonne défile en arc-en-ciel ; Secret : clignote noir et blanc
		if colonne and (d.rarete == "Divin" or d.rarete == "Secret") then
			task.spawn(function()
				local debut = os.clock()
				while colonne.Parent and os.clock() - debut < duree do
					local t = os.clock() - debut
					if d.rarete == "Divin" then
						colonne.Color = Color3.fromHSV((t * 0.6) % 1, 0.75, 1)
					elseif math.floor(t * 4) % 2 == 0 then
						colonne.Color = SC.texte
					else
						colonne.Color = Color3.fromRGB(40, 40, 40)
					end
					task.wait(0.08)
				end
			end)
		end
		-- petite étiquette « ✨ LÉGENDAIRE ! » en dégradé de rareté au-dessus du dino
		local support = nouvellePart({ Name = "EtiquetteRarete", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1 }, duree + 1)
		if support then
			local _, lignes = Style.etiquette(support, {
				{ texte = "✨ " .. rareteMaj(d.rarete) .. " ! ✨", rarete = d.rarete, titre = true, contour = 4 },
			}, { Name = "Rarete", largeur = 14, hauteurLigne = 2.4, StudsOffset = Vector3.new(0, 0, 0), MaxDistance = 260, AlwaysOnTop = true })
			animer(support, {
				pos = position + Vector3.new(0, 9, 0),
				cible = cible,
				decalage = Vector3.new(0, 9, 0),
				vie = duree,
				fondu = false,
			})
			local texte = lignes and lignes[1]
			if texte then
				Style.pop(texte, 1.25)
				task.delay(duree * 0.75, function()
					fondre(texte, duree * 0.25)
				end)
			end
		end
		-- éclat d'arrivée : onde au sol + gerbe d'étincelles
		onde(position + Vector3.new(0, 0.6, 0), clair, { rayon = 9 + ordre, vie = 0.7, segments = 18 })
		rafale(position + Vector3.new(0, 2, 0), {
			etincelles(14 + ordre * 4, clair, couleur, { vitesse = { 12, 22 }, vie = { 0.6, 1.1 } }),
		})
		-- orbes à traînée qui s'enroulent autour du dino en montant
		gerbe(position, 3 + math.floor(ordre / 2), function(i, pos)
			local orbe = particule({ Name = "Orbe", Shape = Enum.PartType.Ball, Size = Vector3.new(0.5, 0.5, 0.5), Color = (i % 2 == 0) and SC.texte or clair }, {
				orbite = {
					centre = pos + Vector3.new(0, 0.5, 0),
					angle = i * 2.1,
					vitesse = r(3.5, 4.5),
					rayon = r(3, 4),
					ouverture = -0.6,
					montee = r(5, 8),
				},
				vie = r(1.6, 2.2),
				debutFondu = 0.65,
				garder = true,
			})
			if orbe then trainee(orbe, clair, couleur, 0.45, 0.4) end
		end)
	end

	-- achat : gerbe d'étincelles de la couleur de rareté, onde dorée et confettis
	function effets.Achat(position, d)
		if not visible(position) then return end
		local couleur = couleurRarete(d.rarete)
		onde(position + Vector3.new(0, 0.4, 0), SC.revenu, { rayon = 8, vie = 0.5 })
		rafale(position + Vector3.new(0, 2.5, 0), {
			etincelles(26, couleur:Lerp(SC.texte, 0.4), couleur, { vitesse = { 14, 24 } }),
			etincelles(12, SC.texte, SC.revenu, { vitesse = { 4, 8 }, ecart = 25, acceleration = Vector3.new(0, 6, 0), vie = { 0.8, 1.2 }, frein = 1 }),
		})
		gerbe(position, 20, function(i, pos)
			local teinte = CONFETTIS[(i % #CONFETTIS) + 1]
			if i % 4 == 0 then teinte = couleur end
			particule({ Name = "Confetti", Size = Vector3.new(0.7, 0.06, 0.4), Color = teinte, Material = Enum.Material.SmoothPlastic }, {
				pos = pos + Vector3.new(0, 3, 0),
				vel = Vector3.new(r(-9, 9), r(14, 24), r(-9, 9)),
				gravite = 30,
				frein = 1.5,
				rot = rotAleatoire(),
				vrot = vrotAleatoire(10),
				vie = r(1.4, 2.2),
				debutFondu = 0.6,
			})
		end)
	end

	-- collecte : fontaine d'étincelles dorées, onde verte, quelques billets et « +X $ »
	function effets.Collecte(position, d)
		if not visible(position) then return end
		local montant = tonumber(d.montant) or 0
		local force = 1
		if montant > 0 then
			force = math.clamp(0.6 + math.log10(montant + 1) * 0.18, 0.7, 1.6)
		end
		if d.aimant then force = force * 0.5 end
		onde(position + Vector3.new(0, 0.4, 0), SC.argent, { rayon = 6 + 2 * force, vie = 0.45, segments = 14 })
		rafale(position + Vector3.new(0, 1.2, 0), {
			etincelles(22 * force, Charte.dore:Lerp(SC.texte, 0.35), Charte.dore, {
				vitesse = { 14, 22 }, ecart = 30, acceleration = Vector3.new(0, -28, 0), frein = 1, vie = { 0.7, 1.1 },
			}),
			etincelles(10 * force, SC.texte, SC.revenu, {
				vitesse = { 3, 6 }, ecart = 15, acceleration = Vector3.new(0, 5, 0), frein = 0.5, vie = { 0.9, 1.4 },
				taille = { 0, 0.3, 0.3, 0.8, 1, 0 },
			}),
		}, Vector3.new(2, 0.4, 2))
		gerbe(position, math.floor(4 + 4 * force), function(i, pos)
			particule({ Name = "Billet", Size = Vector3.new(1.2, 0.06, 0.6), Color = (i % 2 == 0) and SC.argent or B.vert[2], Material = Enum.Material.SmoothPlastic }, {
				pos = pos + Vector3.new(0, 1.5, 0),
				vel = Vector3.new(r(-6, 6), r(16, 26), r(-6, 6)),
				gravite = 38,
				frein = 0.8,
				rot = rotAleatoire(),
				vrot = vrotAleatoire(8),
				vie = r(1.2, 1.8),
				debutFondu = 0.55,
			})
		end)
		if montant > 0 then
			texteFlottant(position + Vector3.new(0, 5, 0), "+" .. Style.argent(montant), SC.argent, 2.4, 1.8)
		end
	end

	-- vente : pièces d'or qui tournoient, éclat doré et onde jaune
	function effets.Vente(position, d)
		if not visible(position) then return end
		onde(position + Vector3.new(0, 0.4, 0), SC.revenu, { rayon = 7, vie = 0.45, segments = 14 })
		rafale(position + Vector3.new(0, 2, 0), {
			etincelles(22, Charte.dore:Lerp(SC.texte, 0.4), B.jaune[2]),
		})
		gerbe(position, 10, function(i, pos)
			particule({ Name = "Piece", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.18, 1, 1), Color = (i % 3 == 0) and B.jaune[2] or SC.revenu, Material = Enum.Material.Metal }, {
				pos = pos + Vector3.new(0, 2, 0),
				vel = Vector3.new(r(-7, 7), r(14, 22), r(-7, 7)),
				gravite = 36,
				rot = Vector3.new(0, r(0, 6.28), 0),
				vrot = Vector3.new(0, r(8, 14), 0),
				vie = r(1.2, 1.7),
				debutFondu = 0.6,
			})
		end)
		local montant = tonumber(d.montant) or 0
		if montant > 0 then
			texteFlottant(position + Vector3.new(0, 5, 0), "+" .. Style.argent(montant), SC.argent, 2.6, 1.9)
		end
	end

	-- début de vol : éclair rouge qui frappe le dino, gerbe d'étincelles et onde rouge
	function effets.VolDebut(position, d)
		if not visible(position) then return end
		local depart = position + Vector3.new(r(-4, 4), 38, r(-4, 4))
		local points = { depart }
		local segments = 7
		for i = 1, segments - 1 do
			local t = i / segments
			local p = depart:Lerp(position, t)
			table.insert(points, p + Vector3.new(r(-2.5, 2.5), 0, r(-2.5, 2.5)))
		end
		table.insert(points, position)
		for i = 1, #points - 1 do
			local a, b = points[i], points[i + 1]
			local longueur = (b - a).Magnitude
			local seg = nouvellePart({
				Name = "Eclair",
				Size = Vector3.new(0.45, 0.45, longueur + 0.3),
				CFrame = CFrame.lookAt((a + b) / 2, b),
				Color = Charte.alerte:Lerp(SC.texte, 0.25),
			}, 0.6)
			if seg then
				tween(seg, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
		end
		flash(position + Vector3.new(0, 1, 0), Charte.alerte, 2, 0.4, 22)
		onde(position + Vector3.new(0, 0.4, 0), Charte.alerte, { rayon = 7, vie = 0.4, segments = 12 })
		rafale(position + Vector3.new(0, 1, 0), {
			etincelles(20, Charte.alerte:Lerp(SC.texte, 0.5), Charte.alerte, { vitesse = { 14, 24 }, acceleration = Vector3.new(0, -30, 0), vie = { 0.4, 0.7 } }),
		})
	end

	-- vol réussi : feu d'artifice (fusées à traînée puis explosions d'étincelles) au-dessus de la base du voleur
	function effets.VolReussi(position, d)
		if not visible(position) then return end
		local couleurs = { SC.revenu, SC.argent, B.bleu[1], B.violet[1], B.rose[1], B.orange[1] }
		for salve = 1, 3 do
			local decalage = Vector3.new(r(-6, 6), 0, r(-6, 6))
			local teinte = couleurs[alea:NextInteger(1, #couleurs)]
			task.delay((salve - 1) * 0.35, function()
				local fusee = particule({ Name = "Fusee", Shape = Enum.PartType.Ball, Size = Vector3.new(0.5, 0.5, 0.5), Color = Charte.creme }, {
					pos = position + decalage + Vector3.new(0, 1, 0),
					vel = Vector3.new(0, 42, 0),
					gravite = 20,
					vie = 0.7,
					fondu = false,
					garder = true,
				}, 1)
				if not fusee then return end
				trainee(fusee, Charte.creme, teinte, 0.4, 0.3)
				task.delay(0.65, function()
					local haut = position + decalage + Vector3.new(0, 1 + 42 * 0.65 - 10 * 0.65 * 0.65, 0)
					flash(haut, teinte:Lerp(SC.texte, 0.5), 1.5, 0.3, 30)
					rafale(haut, {
						etincelles(46, teinte:Lerp(SC.texte, 0.3), teinte, {
							vitesse = { 18, 26 }, frein = 2.2, acceleration = Vector3.new(0, -7, 0), vie = { 1, 1.5 },
							taille = { 0, 1.1, 0.15, 0.9, 1, 0 },
						}),
						etincelles(18, SC.texte, SC.texte, {
							vitesse = { 6, 12 }, frein = 2, acceleration = Vector3.new(0, -4, 0), vie = { 0.6, 1.2 },
							taille = { 0, 0.5, 0.5, 0.4, 1, 0 },
						}),
					}, Vector3.new(1, 1, 1))
				end)
			end)
		end
	end

	-- vol raté : nuage de poussière qui roule au sol
	function effets.VolRate(position, d)
		if not visible(position) then return end
		rafale(position + Vector3.new(0, 0.8, 0), {
			{
				n = 16,
				texture = TEX.fumee,
				couleur = Charte.sable,
				couleur2 = Charte.terre,
				lumiere = 0,
				eclat = 1,
				taille = { 0, 1.5, 1, 4.5 },
				transparence = { 0, 0.35, 0.6, 0.6, 1, 1 },
				vie = { 0.9, 1.5 },
				vitesse = { 6, 10 },
				ecart = 80,
				frein = 3,
				acceleration = Vector3.new(0, 2, 0),
				tourne = 40,
			},
		}, Vector3.new(2, 0.5, 2))
		onde(position + Vector3.new(0, 0.3, 0), Charte.sable, { rayon = 6, vie = 0.5, segments = 12, transparence = 0.3 })
	end

	-- coup de batte : onde de choc + éclat d'étoiles + étoiles qui tournent + « BONK ! »
	function effets.Frappe(position, d)
		if not visible(position) then return end
		if d.leger then
			-- coup dans le vide : petit souffle de poussière claire
			rafale(position + Vector3.new(0, 1.5, 0), {
				{
					n = 6, texture = TEX.fumee, couleur = Charte.creme, lumiere = 0, eclat = 1,
					taille = { 0, 0.8, 1, 2.2 }, transparence = { 0, 0.5, 1, 1 },
					vie = { 0.3, 0.5 }, vitesse = { 4, 7 }, frein = 4, tourne = 60,
				},
			})
			return
		end
		onde(position + Vector3.new(0, 0.5, 0), Charte.creme, { rayon = 10, vie = 0.45, segments = 16 })
		onde(position + Vector3.new(0, 0.7, 0), SC.revenu, { depart = 0.5, rayon = 6, vie = 0.35, segments = 12, epaisseur = 0.4, leve = 0.45 })
		flash(position + Vector3.new(0, 2, 0), SC.revenu, 1.5, 0.3, 18)
		rafale(position + Vector3.new(0, 2, 0), {
			etincelles(22, SC.texte, SC.revenu, { vitesse = { 16, 26 }, vie = { 0.35, 0.6 }, taille = { 0, 1.2, 1, 0 } }),
		})
		gerbe(position, 5, function(i, pos)
			local etoile = particule({ Name = "Etoile", Shape = Enum.PartType.Ball, Size = Vector3.new(0.45, 0.45, 0.45), Color = SC.revenu }, {
				orbite = {
					centre = pos + Vector3.new(0, 3.2, 0),
					angle = i * 1.256,
					vitesse = 6,
					rayon = 1.6,
					montee = 0,
				},
				vie = 1.4,
				debutFondu = 0.6,
				garder = true,
			})
			if etoile then trainee(etoile, SC.texte, SC.revenu, 0.35, 0.25) end
		end)
		texteFlottant(position + Vector3.new(0, 4, 0), "BONK !", SC.revenu, 3, 1.1, { degrade = OR, contour = 5 })
	end

	-- verrou : dôme translucide rouge sur la base tant qu'elle est verrouillée
	local domes = {}

	local function retirerDome(index)
		local dome = domes[index]
		domes[index] = nil
		if dome and dome.Parent then
			tween(dome, 0.5, { Transparency = 1 })
			Debris:AddItem(dome, 0.6)
		end
	end

	function effets.Verrou(position, d)
		local index = tonumber(d.index)
		if not index or not Plan.bases[index] then return end
		if d.actif == false then
			retirerDome(index)
			return
		end
		retirerDome(index)
		local bases = ctx.racine:FindFirstChild("Bases")
		local modele = bases and bases:FindFirstChild("Base" .. index)
		local centre = Plan.bases[index].centre
		if modele then
			local sol = modele:FindFirstChild("Sol")
			if sol and sol:IsA("BasePart") then centre = sol.Position end
		end
		centre = Vector3.new(centre.X, Plan.base.hauteurSol, centre.Z)
		local dureeMax = E.base.dureeVerrou + 2
		local dome = nouvellePart({
			Name = "Dome",
			Size = Vector3.new(Plan.base.largeur + 4, HAUTEUR_DOME * 2, Plan.base.profondeur + 4),
			CFrame = CFrame.new(centre),
			Color = Charte.alerte,
			Material = Enum.Material.ForceField,
			Transparency = 1,
		}, dureeMax + 1)
		if not dome then return end
		local forme = Instance.new("SpecialMesh")
		forme.MeshType = Enum.MeshType.Sphere
		forme.Scale = Vector3.new(0.1, 0.1, 0.1)
		forme.Parent = dome
		domes[index] = dome
		tween(dome, 0.4, { Transparency = 0.35 })
		tween(forme, 0.5, { Scale = Vector3.new(1, 1, 1) }, Enum.EasingStyle.Back)
		-- onde rouge au sol à l'apparition, et étincelles qui jaillissent du centre
		if visible(centre) then
			onde(centre + Vector3.new(0, 0.4, 0), Charte.alerte, { depart = 3, rayon = Plan.base.largeur * 0.62, vie = 0.8, segments = 24, epaisseur = 0.8 })
			rafale(centre + Vector3.new(0, 1, 0), {
				etincelles(24, Charte.alerte:Lerp(SC.texte, 0.5), Charte.alerte, { vitesse = { 16, 26 }, ecart = 60, acceleration = Vector3.new(0, -20, 0), vie = { 0.8, 1.2 } }),
			}, Vector3.new(4, 0.5, 4))
		end
		-- surveillance : fin du verrou, base libérée ou propriétaire parti
		task.spawn(function()
			local debut = os.clock()
			while domes[index] == dome and dome.Parent do
				task.wait(0.5)
				local fini = os.clock() - debut > dureeMax
				if modele and modele.Parent then
					if modele:GetAttribute("Verrouillee") == false then fini = true end
					if modele:GetAttribute("Proprietaire") == 0 then fini = true end
					local finVerrou = modele:GetAttribute("FinVerrou")
					if type(finVerrou) == "number" and finVerrou > 0 and workspace:GetServerTimeNow() > finVerrou + 0.5 then
						fini = true
					end
				end
				if fini then
					if domes[index] == dome then retirerDome(index) end
					return
				end
			end
		end)
	end

	-- renaissance : spirale d'orbes à traînée violettes et dorées qui monte autour du joueur
	function effets.Renaissance(position, d)
		if not visible(position) then return end
		local centre = position - Vector3.new(0, 2, 0)
		onde(centre + Vector3.new(0, 0.4, 0), B.violet[1], { rayon = 12, vie = 0.8, segments = 20 })
		onde(centre + Vector3.new(0, 0.6, 0), SC.revenu, { depart = 0.5, rayon = 7, vie = 0.6, segments = 14, epaisseur = 0.4, leve = 0.45 })
		rafale(centre + Vector3.new(0, 1, 0), {
			etincelles(30, B.violet[1], B.violet[2], { vitesse = { 4, 8 }, ecart = 20, acceleration = Vector3.new(0, 10, 0), frein = 0.5, vie = { 1.2, 1.8 } }),
			etincelles(20, SC.texte, SC.revenu, { vitesse = { 14, 22 }, vie = { 0.6, 1 } }),
		}, Vector3.new(4, 0.5, 4))
		gerbe(centre, 12, function(i, pos)
			task.delay(i * 0.05, function()
				local couleur = (i % 2 == 0) and B.violet[1] or SC.revenu
				local orbe = particule({ Name = "Spirale", Shape = Enum.PartType.Ball, Size = Vector3.new(0.6, 0.6, 0.6), Color = couleur:Lerp(SC.texte, 0.3) }, {
					orbite = {
						centre = pos,
						angle = i * 0.52,
						vitesse = 5,
						rayon = 3.5,
						ouverture = -1.2,
						montee = 9,
					},
					vie = 1.8,
					debutFondu = 0.6,
					garder = true,
				})
				if orbe then trainee(orbe, couleur:Lerp(SC.texte, 0.4), couleur, 0.55, 0.45) end
			end)
		end)
		local niveau = tonumber(d.niveau)
		if niveau then
			texteFlottant(position + Vector3.new(0, 6, 0), "RENAISSANCE " .. niveau .. " !", B.violet[1], 2.8, 2.4, { degrade = VIOLET, contour = 5 })
		end
	end

	-- événement : titre géant à l'écran sur un bandeau sombre lisere d'or
	local titreActif = nil
	-- éclosion d'un Œuf mystère : spirale de renaissance aux couleurs de la rareté obtenue
	function effets.Eclosion(position, d)
		effets.Renaissance(position, d)
	end

	function effets.Evenement(position, d)
		if type(d.nom) ~= "string" or d.nom == "" then return end
		local infos = E.evenements.liste[d.nom]
		local titre = (infos and infos.nom) or d.nom
		local couleur = COULEURS_EVENEMENT[d.nom] or SC.revenu
		if titreActif then titreActif:Destroy() end

		local eclair = Instance.new("Frame")
		eclair.Name = "FlashEvenement"
		eclair.Size = UDim2.fromScale(1, 1)
		eclair.BackgroundColor3 = couleur
		eclair.BackgroundTransparency = 0.55
		eclair.BorderSizePixel = 0
		eclair.ZIndex = 41
		eclair.Parent = couche
		tween(eclair, 0.9, { BackgroundTransparency = 1 })
		Debris:AddItem(eclair, 1)

		local bloc = Instance.new("Frame")
		bloc.Name = "TitreEvenement"
		bloc.AnchorPoint = Vector2.new(0.5, 0.5)
		bloc.Position = UDim2.fromScale(0.5, 0.36)
		bloc.Size = UDim2.new(0.94, 0, 0, 170)
		bloc.BackgroundTransparency = 1
		bloc.ZIndex = 42
		bloc.Parent = couche
		titreActif = bloc
		local echelle = Instance.new("UIScale")
		echelle.Scale = 0.2
		echelle.Parent = bloc
		local fond = bandeau(bloc, 176, 84, 42)
		-- sur-titre jaune-orangé cerné, puis titre géant arc-en-ciel animé cerné de noir épais
		local sur = Style.texte(bloc, {
			Name = "SurTitre",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(0.8, 0, 0, 44),
			Text = "⚡ ÉVÉNEMENT ! ⚡",
			titre = true,
			contour = 4,
			tailleMax = 44,
			ZIndex = 43,
		})
		Style.degrade(sur, OR[1], OR[2])
		local grand = Style.texte(bloc, {
			Name = "Titre",
			Position = UDim2.new(0, 0, 0, 46),
			Size = UDim2.new(1, 0, 0, 118),
			Text = titre,
			titre = true,
			contour = 6,
			tailleMax = 110,
			ZIndex = 43,
		})
		Style.degradeRarete(grand, "Divin")
		tween(echelle, 0.5, { Scale = 1 }, Enum.EasingStyle.Back)
		-- petit battement du titre tant qu'il est affiché
		task.delay(0.55, function()
			for _ = 1, 3 do
				if titreActif ~= bloc then return end
				tween(echelle, 0.25, { Scale = 1.08 }, Enum.EasingStyle.Sine)
				task.wait(0.28)
				if titreActif ~= bloc then return end
				tween(echelle, 0.25, { Scale = 1 }, Enum.EasingStyle.Sine)
				task.wait(0.55)
			end
		end)
		confettisEcran(28)
		task.delay(3.6, function()
			if titreActif ~= bloc then return end
			tween(echelle, 0.6, { Scale = 1.3 })
			tween(fond, 0.5, { BackgroundTransparency = 1 })
			for _, l in ipairs(fond:GetChildren()) do
				if l:IsA("Frame") then tween(l, 0.5, { BackgroundTransparency = 1 }) end
			end
			fondre(sur, 0.6)
			fondre(grand, 0.6)
			task.delay(0.7, function()
				if titreActif == bloc then titreActif = nil end
				bloc:Destroy()
			end)
		end)
	end

	-- météore : cratère fumant, gerbe de feu et d'étincelles, onde orange, secousse si le joueur est proche
	function effets.Meteore(position, d)
		local perso = positionPersonnage()
		if perso then
			local distance = (perso - position).Magnitude
			if distance < DISTANCE_SECOUSSE then
				secouer(0.25 + 1.1 * (1 - distance / DISTANCE_SECOUSSE), 0.7)
			end
		end
		if not visible(position) then return end
		local sol = Vector3.new(position.X, position.Y, position.Z)
		local vie = 8
		local trou = nouvellePart({ Name = "Cratere", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 10, 10), Color = Charte.encre, Material = Enum.Material.Basalt }, vie + 1)
		if trou then
			animer(trou, { pos = sol + Vector3.new(0, 0.1, 0), base = VERTICAL, vie = vie, debutFondu = 0.75 })
		end
		local braise = nouvellePart({ Name = "Braise", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.25, 5, 5), Color = Charte.lave }, vie + 1)
		if braise then
			local lumiere = Instance.new("PointLight")
			lumiere.Color = Charte.lave
			lumiere.Range = 16
			lumiere.Brightness = 3
			lumiere.Parent = braise
			tween(lumiere, vie, { Brightness = 0 })
			animer(braise, { pos = sol + Vector3.new(0, 0.15, 0), base = VERTICAL, vie = vie, croissance = -0.08, debutFondu = 0.4 })
		end
		gerbe(sol, 7, function(i, pos)
			local angle = i / 7 * TAU
			local taille = r(1, 2)
			local roche = Charte.pierre
			if i % 2 == 0 then roche = Charte.ombre(Charte.pierre) end
			particule({ Name = "Roche", Size = Vector3.new(taille, taille * 0.7, taille), Color = roche, Material = Enum.Material.Slate }, {
				pos = pos + Vector3.new(math.cos(angle) * 5.5, taille * 0.3, math.sin(angle) * 5.5),
				rot = Vector3.new(r(-0.4, 0.4), r(0, 6.28), r(-0.4, 0.4)),
				vie = vie,
				debutFondu = 0.8,
			})
		end)
		flash(sol + Vector3.new(0, 1.5, 0), Charte.dore, 3, 0.35, 30)
		onde(sol + Vector3.new(0, 0.4, 0), Charte.lave, { depart = 2, rayon = 14, vie = 0.6, segments = 20, epaisseur = 0.8 })
		rafale(sol + Vector3.new(0, 1, 0), {
			{
				n = 18, texture = TEX.feu, couleur = Charte.dore, couleur2 = Charte.lave, lumiere = 1, eclat = 2,
				taille = { 0, 2.2, 1, 0.4 }, transparence = { 0, 0.1, 0.7, 0.4, 1, 1 },
				vie = { 0.5, 0.9 }, vitesse = { 8, 16 }, ecart = 70, frein = 2.5, acceleration = Vector3.new(0, 6, 0), tourne = 120,
			},
			etincelles(26, Charte.dore, Charte.lave, {
				vitesse = { 16, 28 }, ecart = 60, acceleration = Vector3.new(0, -45, 0), frein = 0.6, vie = { 0.8, 1.3 },
			}),
		}, Vector3.new(2, 0.5, 2))
		-- fumée qui s'échappe du cratère quelques secondes (un seul émetteur continu)
		local fumoir = nouvellePart({ Name = "Fumee", Size = Vector3.new(4, 0.4, 4), Transparency = 1, CFrame = CFrame.new(sol + Vector3.new(0, 0.6, 0)) }, 9)
		if fumoir and reserver(6 * 3.2, 8.5) > 0 then
			local fumee = emetteur(fumoir, {
				texture = TEX.fumee, couleur = Charte.pierre, couleur2 = Charte.lumiere(Charte.pierre), lumiere = 0, eclat = 1,
				taille = { 0, 2, 1, 6 }, transparence = { 0, 0.45, 0.5, 0.6, 1, 1 },
				vie = { 2.4, 3.2 }, vitesse = { 3, 6 }, ecart = 15, frein = 0.3, acceleration = Vector3.new(0.6, 1.5, 0), tourne = 25,
				debit = math.max(2, math.floor(6 * qualite(sol))),
			})
			fumee.Enabled = true
			task.delay(5, function()
				if fumee.Parent then fumee.Enabled = false end
			end)
		end
	end

	-- découverte : carte « Nouvelle espèce ! » (une à la fois, en file)
	local fileCartes = {}
	local carteEnCours = false

	local function montrerCarte(espece)
		local infos = E.especes[espece]
		local nom = (infos and infos.nom) or espece
		local rarete = (infos and infos.rarete) or "Commun"

		-- bloc central : ombre portée, halo en dégradé de rareté derrière une carte sombre cernée de noir
		local bloc = Instance.new("Frame")
		bloc.Name = "CarteDecouverte"
		bloc.AnchorPoint = Vector2.new(0.5, 0.5)
		bloc.Position = UDim2.fromScale(0.5, 0.42)
		bloc.Size = UDim2.new(0.86, 0, 0, 196)
		bloc.BackgroundTransparency = 1
		bloc.ZIndex = 44
		local limite = Instance.new("UISizeConstraint")
		limite.MaxSize = Vector2.new(440, 196)
		limite.Parent = bloc
		bloc.Parent = couche

		local ombre = Instance.new("Frame")
		ombre.Name = "Ombre"
		ombre.AnchorPoint = Vector2.new(0.5, 0.5)
		ombre.Position = UDim2.new(0.5, 0, 0.5, 8)
		ombre.Size = UDim2.new(1, 22, 1, 22)
		ombre.BackgroundColor3 = SC.ombre
		ombre.BackgroundTransparency = 0.55
		ombre.BorderSizePixel = 0
		ombre.ZIndex = 44
		Style.coins(ombre, 28)
		ombre.Parent = bloc

		local halo = Instance.new("Frame")
		halo.Name = "Halo"
		halo.AnchorPoint = Vector2.new(0.5, 0.5)
		halo.Position = UDim2.fromScale(0.5, 0.5)
		halo.Size = UDim2.new(1, 16, 1, 16)
		halo.BackgroundColor3 = SC.texte
		halo.BackgroundTransparency = 0.15
		halo.BorderSizePixel = 0
		halo.ZIndex = 44
		Style.coins(halo, 24)
		Style.bordure(halo, 4)
		Style.degradeRarete(halo, rarete)
		halo.Parent = bloc

		local carte = Style.carte(bloc, {
			Name = "Carte",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = SC.fond,
			ZIndex = 45,
		})
		local haut = Style.texte(carte, {
			Name = "Haut",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 10),
			Size = UDim2.new(1, -24, 0, 38),
			Text = "✨ NOUVELLE ESPÈCE ! ✨",
			titre = true,
			contour = 3,
			tailleMax = 36,
			ZIndex = 46,
		})
		Style.degrade(haut, OR[1], OR[2])
		local grand = Style.texte(carte, {
			Name = "Nom",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 52),
			Size = UDim2.new(1, -24, 0, 80),
			Text = nom,
			titre = true,
			contour = 5,
			tailleMax = 78,
			ZIndex = 46,
		})
		Style.degradeRarete(grand, rarete)
		local bas = Style.texte(carte, {
			Name = "Rarete",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 140),
			Size = UDim2.new(1, -24, 0, 40),
			Text = rareteMaj(rarete),
			contour = 3.5,
			tailleMax = 36,
			ZIndex = 46,
		})
		Style.degradeRarete(bas, rarete)

		Style.pop(bloc, 1.15)
		confettisEcran(22)
		task.wait(3.4)
		local echelle = bloc:FindFirstChild("Pop")
		if echelle then
			tween(echelle, 0.3, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		end
		task.wait(0.35)
		bloc:Destroy()
	end

	function effets.Decouverte(position, d)
		if type(d.espece) ~= "string" then return end
		table.insert(fileCartes, d.espece)
		if carteEnCours then return end
		carteEnCours = true
		while #fileCartes > 0 do
			local espece = table.remove(fileCartes, 1)
			pcall(montrerCarte, espece)
		end
		carteEnCours = false
	end

	-- coffre : pluie d'or (pièces et poussière dorée scintillante), onde dorée
	function effets.Coffre(position, d)
		if not visible(position) then return end
		onde(position + Vector3.new(0, 0.4, 0), Charte.dore, { rayon = 9, vie = 0.6, segments = 18 })
		rafale(position + Vector3.new(0, 1.5, 0), {
			etincelles(24, SC.texte, Charte.dore, { vitesse = { 16, 26 }, ecart = 35, acceleration = Vector3.new(0, -30, 0), frein = 0.8, vie = { 0.8, 1.2 } }),
		})
		rafale(position + Vector3.new(0, 16, 0), {
			etincelles(34, Charte.dore:Lerp(SC.texte, 0.3), Charte.dore, {
				direction = Enum.NormalId.Bottom, ecart = 10, vitesse = { 2, 5 }, acceleration = Vector3.new(0, -14, 0),
				frein = 0.2, vie = { 1.2, 1.7 }, taille = { 0, 0.3, 0.2, 0.7, 1, 0.1 },
			}),
		}, Vector3.new(10, 1, 10))
		gerbe(position, 16, function(i, pos)
			task.delay(r(0, 0.8), function()
				particule({ Name = "Or", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.18, 1, 1), Color = (i % 3 == 0) and B.jaune[2] or SC.revenu, Material = Enum.Material.Metal }, {
					pos = pos + Vector3.new(r(-6, 6), r(14, 20), r(-6, 6)),
					vel = Vector3.new(0, r(-4, 0), 0),
					gravite = 30,
					rot = Vector3.new(0, r(0, 6.28), r(0, 6.28)),
					vrot = Vector3.new(0, r(6, 12), 0),
					vie = 1.3,
					debutFondu = 0.7,
				})
			end)
		end)
		local montant = tonumber(d.montant) or 0
		if montant > 0 then
			texteFlottant(position + Vector3.new(0, 4, 0), "+" .. Style.argent(montant), SC.argent, 2.8, 2.2)
		end
	end

	-- genres sans position dans le monde
	local SANS_POSITION = { Evenement = true, Decouverte = true, Verrou = true }

	ctx.Reseau.Effet.OnClientEvent:Connect(function(genre, position, donnees)
		if type(genre) ~= "string" then return end
		local effet = effets[genre]
		if not effet then return end
		if typeof(position) ~= "Vector3" then
			if not SANS_POSITION[genre] then return end
			position = nil
		end
		if type(donnees) ~= "table" then donnees = {} end
		task.spawn(function()
			local ok, err = pcall(effet, position, donnees)
			if not ok then
				warn("[Dino] effet « " .. genre .. " » : " .. tostring(err))
			end
		end)
	end)

	-- ménage à la mort du personnage : la secousse s'arrête
	joueur.CharacterAdded:Connect(function()
		secousse.fin = 0
	end)

	-- les dômes des bases dont le propriétaire est parti disparaissent
	Players.PlayerRemoving:Connect(function(qui)
		local bases = ctx.racine:FindFirstChild("Bases")
		if not bases then return end
		for index in pairs(domes) do
			local modele = bases:FindFirstChild("Base" .. index)
			if modele and modele:GetAttribute("Proprietaire") == qui.UserId then
				retirerDome(index)
			end
		end
	end)
end

return M
