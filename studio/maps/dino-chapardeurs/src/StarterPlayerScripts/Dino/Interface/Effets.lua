-- Interface/Effets : effets visuels locaux déclenchés par le serveur (Reseau.Effet).
-- Tout est construit côté client dans workspace.EffetsLocaux : parts ancrées, non collidables, nettoyées par Debris.
-- Un seul moteur de particules (Heartbeat) anime toutes les parts ; au plus MAX_PARTS parts vivent en même temps.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local M = {}

-- réglages purement visuels (les chiffres de jeu viennent de ctx.Equilibrage)
local MAX_PARTS = 150
local DISTANCE_MAX = 380      -- au-delà, un effet dans le monde n'est pas affiché
local DISTANCE_SECOUSSE = 80  -- rayon de la secousse de caméra d'un météore
local HAUTEUR_DOME = 18

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local Outils = ctx.Outils
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

	-- ===== moteur de particules =====
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
				if p.Parent ~= nil then p:Destroy() end
			else
				local k = q.age / q.vie
				if q.cible and q.cible.Parent ~= nil then
					-- suit un modèle (colonne sur un dino qui avance)
					local ok, pivot = pcall(function() return q.cible:GetPivot() end)
					if ok and pivot then q.pos = pivot.Position + q.decalage end
				elseif q.orbite then
					local o = q.orbite
					local angle = o.angle + o.vitesse * q.age
					local rayon = o.rayon + (o.ouverture or 0) * q.age
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
			cible = o.cible,
			decalage = o.decalage or Vector3.new(0, 0, 0),
			base = o.base or CFrame.new(),
		}
		p.CFrame = CFrame.new(q.pos) * CFrame.Angles(q.rot.X, q.rot.Y, q.rot.Z) * q.base
		table.insert(particules, q)
		assurerMoteur()
		return q
	end

	local function particule(props, o)
		local p = nouvellePart(props, (o.vie or 1) + 1)
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

	-- gerbe : n particules lancées depuis une position
	local function gerbe(position, n, fabrique)
		local nombre = math.min(n, placesLibres())
		for i = 1, nombre do
			fabrique(i, position)
		end
	end

	-- ===== textes flottants dans le monde =====
	local function texteFlottant(position, texte, couleur, hauteur, duree)
		duree = duree or 1.8
		local p = nouvellePart({ Name = "Texte", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1 }, duree + 0.5)
		if not p then return end
		local bb = Instance.new("BillboardGui")
		bb.Name = "Texte"
		bb.Adornee = p
		bb.AlwaysOnTop = true
		bb.LightInfluence = 0
		bb.MaxDistance = 220
		bb.Size = UDim2.new(0, 0, 0, 0)
		bb.Parent = p
		local etiquette = Outils.etiquette(bb, {
			Size = UDim2.fromScale(1, 1),
			Text = texte,
			TextColor3 = couleur or Charte.dore,
			TextStrokeColor3 = Charte.encre,
			TextStrokeTransparency = 0,
		})
		animer(p, { pos = position, vel = Vector3.new(0, 4, 0), frein = 1.2, vie = duree, fondu = false })
		tween(bb, 0.3, { Size = UDim2.new(hauteur * 4, 0, hauteur, 0) }, Enum.EasingStyle.Back)
		task.delay(duree * 0.6, function()
			if etiquette.Parent then
				tween(etiquette, duree * 0.4, { TextTransparency = 1, TextStrokeTransparency = 1 })
			end
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

	local function contour(inst, couleur, epaisseur)
		local s = Instance.new("UIStroke")
		s.Color = couleur
		s.Thickness = epaisseur
		s.Parent = inst
		return s
	end

	-- ===== couleurs utiles =====
	local function couleurRarete(rarete)
		if type(rarete) == "string" and Charte.raretes[rarete] then
			return Charte.raretes[rarete]
		end
		return Charte.dore
	end

	local function ordreRarete(rarete)
		local infos = type(rarete) == "string" and E.raretes[rarete]
		if infos then return infos.ordre end
		return 1
	end

	local CONFETTIS = {
		Charte.dore, Charte.gemme, Charte.violet, Charte.alerte, Charte.herbe, Charte.lave, Charte.creme,
	}

	local COULEURS_EVENEMENT = {
		PluieDeMeteores = Charte.violet,
		Eruption = Charte.lave,
		LuneDoree = Charte.dore,
	}

	-- ===== les effets =====
	local effets = {}

	-- dino rare sur le Tapis : colonne de lumière qui le suit + étoiles
	function effets.Apparition(position, d)
		if not visible(position) then return end
		local couleur = couleurRarete(d.rarete)
		if d.mutation and d.mutation ~= "Normal" and Charte.mutations[d.mutation] and ordreRarete(d.rarete) < 4 then
			couleur = Charte.mutations[d.mutation]
		end
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
			Transparency = 0.45,
		}, duree + 1)
		if colonne then
			animer(colonne, {
				pos = position + Vector3.new(0, hauteur / 2, 0),
				cible = cible,
				decalage = Vector3.new(0, hauteur / 2, 0),
				vie = duree,
				base = VERTICAL,
				debutFondu = 0.6,
			})
		end
		local anneau = nouvellePart({
			Name = "Anneau",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.3, 3, 3),
			Color = Charte.lumiere(couleur),
			Transparency = 0.2,
		}, 2)
		if anneau then
			animer(anneau, { pos = position + Vector3.new(0, 1, 0), vie = 1.2, base = VERTICAL, croissance = 3 })
		end
		gerbe(position, 8 + ordre * 3, function(i, pos)
			local taille = r(0.4, 0.9)
			particule({ Name = "Etoile", Shape = Enum.PartType.Ball, Size = Vector3.new(taille, taille, taille), Color = (i % 3 == 0) and Charte.creme or couleur }, {
				pos = pos + Vector3.new(0, 2, 0),
				orbite = {
					centre = pos + Vector3.new(0, 1, 0),
					angle = r(0, 6.28),
					vitesse = r(2, 4),
					rayon = r(2, 3.5),
					ouverture = r(0.5, 1.5),
					montee = r(5, 10),
				},
				vie = r(1.6, 2.6),
				debutFondu = 0.5,
			})
		end)
	end

	-- achat : confettis multicolores
	function effets.Achat(position, d)
		if not visible(position) then return end
		local couleur = couleurRarete(d.rarete)
		gerbe(position, 26, function(i, pos)
			local teinte = CONFETTIS[(i % #CONFETTIS) + 1]
			if i % 4 == 0 then teinte = couleur end
			particule({ Name = "Confetti", Size = Vector3.new(0.5, 0.08, 0.3), Color = teinte, Material = Enum.Material.SmoothPlastic }, {
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

	-- collecte : billets verts qui jaillissent + « +X $ »
	function effets.Collecte(position, d)
		if not visible(position) then return end
		local montant = tonumber(d.montant) or 0
		local n = 6
		if montant > 0 then
			n = math.clamp(math.floor(4 + math.log10(montant + 1) * 3), 6, 22)
		end
		if d.aimant then n = math.floor(n / 2) end
		gerbe(position, n, function(i, pos)
			particule({ Name = "Billet", Size = Vector3.new(1.2, 0.06, 0.6), Color = (i % 2 == 0) and Charte.herbe or Charte.jungle, Material = Enum.Material.SmoothPlastic }, {
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
			texteFlottant(position + Vector3.new(0, 5, 0), "+" .. Charte.argent(montant), Charte.herbe, 2.2, 1.8)
		end
	end

	-- vente : pièces d'or qui tournoient
	function effets.Vente(position, d)
		if not visible(position) then return end
		gerbe(position, 14, function(i, pos)
			particule({ Name = "Piece", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.18, 1, 1), Color = Charte.dore }, {
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
			texteFlottant(position + Vector3.new(0, 5, 0), "+" .. Charte.argent(montant), Charte.dore, 2.2, 1.8)
		end
	end

	-- début de vol : éclair rouge qui frappe le dino
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
				Size = Vector3.new(0.5, 0.5, longueur),
				CFrame = CFrame.lookAt((a + b) / 2, b),
				Color = Charte.alerte,
			}, 0.6)
			if seg then
				tween(seg, 0.5, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
		end
		local flash = nouvellePart({ Name = "Flash", Shape = Enum.PartType.Ball, Size = Vector3.new(2, 2, 2), Color = Charte.alerte, Transparency = 0.2 }, 1)
		if flash then
			local lumiere = Instance.new("PointLight")
			lumiere.Color = Charte.alerte
			lumiere.Range = 22
			lumiere.Brightness = 4
			lumiere.Parent = flash
			animer(flash, { pos = position + Vector3.new(0, 1, 0), croissance = 5, vie = 0.5 })
		end
		gerbe(position, 8, function(i, pos)
			particule({ Name = "Etincelle", Size = Vector3.new(0.25, 0.25, 0.25), Color = Charte.alerte }, {
				pos = pos + Vector3.new(0, 1, 0),
				vel = Vector3.new(r(-12, 12), r(6, 14), r(-12, 12)),
				gravite = 40,
				vie = r(0.5, 0.8),
			})
		end)
	end

	-- vol réussi : feu d'artifice au-dessus de la base du voleur
	function effets.VolReussi(position, d)
		if not visible(position) then return end
		local couleurs = { Charte.dore, Charte.gemme, Charte.violet, Charte.alerte, Charte.herbe }
		for salve = 1, 3 do
			local decalage = Vector3.new(r(-6, 6), 0, r(-6, 6))
			local teinte = couleurs[alea:NextInteger(1, #couleurs)]
			task.delay((salve - 1) * 0.35, function()
				local fusee = particule({ Name = "Fusee", Shape = Enum.PartType.Ball, Size = Vector3.new(0.6, 0.6, 0.6), Color = Charte.creme }, {
					pos = position + decalage + Vector3.new(0, 1, 0),
					vel = Vector3.new(0, 42, 0),
					gravite = 20,
					vie = 0.7,
					fondu = false,
				})
				if not fusee then return end
				task.delay(0.65, function()
					local haut = position + decalage + Vector3.new(0, 1 + 42 * 0.65 - 10 * 0.65 * 0.65, 0)
					gerbe(haut, 22, function(i, pos)
						local dir = Vector3.new(r(-1, 1), r(-1, 1), r(-1, 1))
						if dir.Magnitude < 0.05 then dir = Vector3.new(0, 1, 0) end
						particule({ Name = "Gerbe", Size = Vector3.new(0.35, 0.35, 0.35), Color = (i % 4 == 0) and Charte.creme or teinte }, {
							pos = pos,
							vel = dir.Unit * r(14, 20),
							gravite = 9,
							frein = 1.8,
							vie = r(1, 1.5),
							debutFondu = 0.3,
						})
					end)
				end)
			end)
		end
	end

	-- vol raté : nuage de poussière
	function effets.VolRate(position, d)
		if not visible(position) then return end
		gerbe(position, 12, function(i, pos)
			local taille = r(1, 2)
			particule({
				Name = "Poussiere",
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(taille, taille, taille),
				Color = (i % 2 == 0) and Charte.terre or Charte.sable,
				Material = Enum.Material.SmoothPlastic,
				Transparency = 0.35,
			}, {
				pos = pos + Vector3.new(r(-1, 1), 0.8, r(-1, 1)),
				vel = Vector3.new(r(-6, 6), r(1, 4), r(-6, 6)),
				frein = 2.5,
				croissance = 1.2,
				vie = r(1, 1.6),
			})
		end)
	end

	-- coup de batte : onde de choc + « BONK ! »
	function effets.Frappe(position, d)
		if not visible(position) then return end
		if d.leger then
			-- coup dans le vide : petit souffle
			local souffle = nouvellePart({ Name = "Souffle", Shape = Enum.PartType.Ball, Size = Vector3.new(1, 1, 1), Color = Charte.creme, Transparency = 0.5 }, 1)
			if souffle then
				animer(souffle, { pos = position + Vector3.new(0, 1.5, 0), croissance = 4, vie = 0.3 })
			end
			return
		end
		local onde = nouvellePart({ Name = "Onde", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 2, 2), Color = Charte.creme, Transparency = 0.15 }, 1.2)
		if onde then
			animer(onde, { pos = position + Vector3.new(0, 0.5, 0), base = VERTICAL, croissance = 18, vie = 0.5 })
		end
		local boule = nouvellePart({ Name = "Impact", Shape = Enum.PartType.Ball, Size = Vector3.new(1.5, 1.5, 1.5), Color = Charte.dore, Transparency = 0.3 }, 1)
		if boule then
			animer(boule, { pos = position + Vector3.new(0, 2, 0), croissance = 5, vie = 0.35 })
		end
		gerbe(position, 5, function(i, pos)
			particule({ Name = "Etoile", Shape = Enum.PartType.Ball, Size = Vector3.new(0.5, 0.5, 0.5), Color = Charte.dore }, {
				orbite = {
					centre = pos + Vector3.new(0, 3.2, 0),
					angle = i * 1.256,
					vitesse = 6,
					rayon = 1.6,
					montee = 0,
				},
				vie = 1.4,
				debutFondu = 0.6,
			})
		end)
		texteFlottant(position + Vector3.new(0, 4, 0), "BONK !", Charte.dore, 2.8, 1.2)
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
		-- onde rouge au sol à l'apparition
		local onde = nouvellePart({ Name = "OndeVerrou", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 4, 4), Color = Charte.alerte, Transparency = 0.3 }, 1.5)
		if onde then
			animer(onde, { pos = centre + Vector3.new(0, 0.3, 0), base = VERTICAL, croissance = 12, vie = 0.8 })
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

	-- renaissance : spirale dorée qui monte autour du joueur
	function effets.Renaissance(position, d)
		if not visible(position) then return end
		local centre = position - Vector3.new(0, 2, 0)
		gerbe(centre, 36, function(i, pos)
			task.delay(i * 0.03, function()
				local taille = 0.6
				if i % 3 == 0 then taille = 0.9 end
				particule({ Name = "Spirale", Shape = Enum.PartType.Ball, Size = Vector3.new(taille, taille, taille), Color = (i % 4 == 0) and Charte.creme or Charte.dore }, {
					orbite = {
						centre = pos,
						angle = i * 0.55,
						vitesse = 5,
						rayon = 3.5,
						ouverture = -1.2,
						montee = 9,
					},
					vie = 1.8,
					debutFondu = 0.5,
				})
			end)
		end)
		local anneau = nouvellePart({ Name = "Anneau", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 3, 3), Color = Charte.dore, Transparency = 0.2 }, 2)
		if anneau then
			animer(anneau, { pos = centre + Vector3.new(0, 0.3, 0), base = VERTICAL, croissance = 6, vie = 1 })
		end
		local niveau = tonumber(d.niveau)
		if niveau then
			texteFlottant(position + Vector3.new(0, 6, 0), "Renaissance " .. niveau .. " !", Charte.dore, 2.5, 2.4)
		end
	end

	-- événement : titre géant à l'écran
	local titreActif = nil
	function effets.Evenement(position, d)
		if type(d.nom) ~= "string" or d.nom == "" then return end
		local infos = E.evenements.liste[d.nom]
		local titre = (infos and infos.nom) or d.nom
		local couleur = COULEURS_EVENEMENT[d.nom] or Charte.dore
		if titreActif then titreActif:Destroy() end

		local flash = Instance.new("Frame")
		flash.Name = "FlashEvenement"
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = couleur
		flash.BackgroundTransparency = 0.55
		flash.BorderSizePixel = 0
		flash.ZIndex = 41
		flash.Parent = couche
		tween(flash, 0.9, { BackgroundTransparency = 1 })
		Debris:AddItem(flash, 1)

		local bloc = Instance.new("Frame")
		bloc.Name = "TitreEvenement"
		bloc.AnchorPoint = Vector2.new(0.5, 0.5)
		bloc.Position = UDim2.fromScale(0.5, 0.36)
		bloc.Size = UDim2.new(0.8, 0, 0, 150)
		bloc.BackgroundTransparency = 1
		bloc.ZIndex = 42
		bloc.Parent = couche
		titreActif = bloc
		local echelle = Instance.new("UIScale")
		echelle.Scale = 0.2
		echelle.Parent = bloc
		local sur = Outils.etiquette(bloc, {
			Size = UDim2.new(1, 0, 0, 36),
			Text = "ÉVÉNEMENT !",
			TextColor3 = Charte.creme,
			ZIndex = 43,
		})
		contour(sur, Charte.encre, 3)
		local grand = Outils.etiquette(bloc, {
			Position = UDim2.new(0, 0, 0, 38),
			Size = UDim2.new(1, 0, 0, 100),
			Text = titre,
			TextColor3 = couleur,
			ZIndex = 43,
		})
		contour(grand, Charte.encre, 5)
		tween(echelle, 0.5, { Scale = 1 }, Enum.EasingStyle.Back)
		task.delay(3.6, function()
			if titreActif ~= bloc then return end
			tween(echelle, 0.6, { Scale = 1.3 })
			tween(sur, 0.6, { TextTransparency = 1 })
			tween(grand, 0.6, { TextTransparency = 1 })
			for _, c in ipairs({ sur, grand }) do
				local s = c:FindFirstChildOfClass("UIStroke")
				if s then tween(s, 0.6, { Transparency = 1 }) end
			end
			task.delay(0.7, function()
				if titreActif == bloc then titreActif = nil end
				bloc:Destroy()
			end)
		end)
	end

	-- météore : cratère fumant, gerbe de lave, secousse si le joueur est proche
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
		local trou = nouvellePart({ Name = "Cratere", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 10, 10), Color = Charte.encre, Material = Enum.Material.SmoothPlastic }, vie + 1)
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
			animer(braise, { pos = sol + Vector3.new(0, 0.15, 0), base = VERTICAL, vie = vie, croissance = -0.08, debutFondu = 0.4 })
		end
		gerbe(sol, 7, function(i, pos)
			local angle = i / 7 * math.pi * 2
			local taille = r(1, 2)
			particule({ Name = "Roche", Size = Vector3.new(taille, taille * 0.7, taille), Color = Charte.pierre, Material = Enum.Material.SmoothPlastic }, {
				pos = pos + Vector3.new(math.cos(angle) * 5.5, taille * 0.3, math.sin(angle) * 5.5),
				rot = Vector3.new(r(-0.4, 0.4), r(0, 6.28), r(-0.4, 0.4)),
				vie = vie,
				debutFondu = 0.8,
			})
		end)
		gerbe(sol, 16, function(i, pos)
			particule({ Name = "Lave", Size = Vector3.new(0.5, 0.5, 0.5), Color = (i % 3 == 0) and Charte.dore or Charte.lave }, {
				pos = pos + Vector3.new(0, 1, 0),
				vel = Vector3.new(r(-14, 14), r(14, 26), r(-14, 14)),
				gravite = 45,
				rot = rotAleatoire(),
				vrot = vrotAleatoire(6),
				vie = r(0.9, 1.4),
				debutFondu = 0.5,
			})
		end)
		-- fumée qui s'échappe quelques secondes
		task.spawn(function()
			for _ = 1, 10 do
				gerbe(sol, 2, function(i, pos)
					local taille = r(1.5, 2.5)
					particule({
						Name = "Fumee",
						Shape = Enum.PartType.Ball,
						Size = Vector3.new(taille, taille, taille),
						Color = Charte.pierre,
						Material = Enum.Material.SmoothPlastic,
						Transparency = 0.4,
					}, {
						pos = pos + Vector3.new(r(-2, 2), 1, r(-2, 2)),
						vel = Vector3.new(r(-1, 1), r(4, 7), r(-1, 1)),
						croissance = 0.9,
						vie = r(2, 2.8),
					})
				end)
				task.wait(0.5)
			end
		end)
	end

	-- découverte : carte « Nouvelle espèce ! » (une à la fois, en file)
	local fileCartes = {}
	local carteEnCours = false

	local function montrerCarte(espece)
		local infos = E.especes[espece]
		local nom = (infos and infos.nom) or espece
		local rarete = infos and infos.rarete
		local couleur = couleurRarete(rarete)
		local nomRarete = ""
		if rarete and E.raretes[rarete] then nomRarete = E.raretes[rarete].nom end

		local carte = Outils.cadre(couche, {
			Name = "CarteDecouverte",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 360, 0.5, 0),
			Size = UDim2.new(0, 300, 0, 120),
			ZIndex = 44,
		})
		contour(carte, couleur, 3)
		local haut = Outils.etiquette(carte, {
			Position = UDim2.new(0, 12, 0, 8),
			Size = UDim2.new(1, -24, 0, 30),
			Text = "Nouvelle espèce !",
			TextColor3 = Charte.dore,
			ZIndex = 45,
		})
		contour(haut, Charte.encre, 2)
		Outils.etiquette(carte, {
			Position = UDim2.new(0, 12, 0, 42),
			Size = UDim2.new(1, -24, 0, 42),
			Text = nom,
			TextColor3 = Charte.creme,
			ZIndex = 45,
		})
		Outils.etiquette(carte, {
			Position = UDim2.new(0, 12, 0, 86),
			Size = UDim2.new(1, -24, 0, 24),
			Text = nomRarete,
			TextColor3 = couleur,
			Font = Charte.policeTexte,
			ZIndex = 45,
		})
		tween(carte, 0.45, { Position = UDim2.new(1, -20, 0.5, 0) }, Enum.EasingStyle.Back)
		task.wait(3.4)
		tween(carte, 0.35, { Position = UDim2.new(1, 360, 0.5, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.4)
		carte:Destroy()
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

	-- coffre : pluie d'or
	function effets.Coffre(position, d)
		if not visible(position) then return end
		gerbe(position, 30, function(i, pos)
			task.delay(r(0, 0.8), function()
				particule({ Name = "Or", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.18, 1, 1), Color = Charte.dore }, {
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
			texteFlottant(position + Vector3.new(0, 4, 0), "+" .. Charte.argent(montant), Charte.dore, 2.6, 2.2)
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
