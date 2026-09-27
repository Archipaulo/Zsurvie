-- Outils partagés : construction en blocs (serveur) et petits éléments d'interface (client).
local Charte = require(script.Parent.Charte)

local Outils = {}
local compteurParts = 0
local BUDGET_PARTS = 14000

local function appliquer(inst, props)
	if not props then return end
	for cle, valeur in pairs(props) do
		if cle ~= "Parent" then
			inst[cle] = valeur
		end
	end
end

local function nouvellePart(classe, parent, props)
	local p = Instance.new(classe)
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Color = Charte.creme
	appliquer(p, props)
	p.Parent = parent
	compteurParts = compteurParts + 1
	if compteurParts == BUDGET_PARTS then
		warn("[Dino] budget de parts atteint (" .. BUDGET_PARTS .. ")")
	end
	return p
end

-- ===== construction =====
function Outils.bloc(parent, props) return nouvellePart("Part", parent, props) end
function Outils.coin(parent, props) return nouvellePart("WedgePart", parent, props) end
function Outils.cylindre(parent, props)
	-- attention : l'axe d'un cylindre Roblox est l'axe X de la part
	local p = nouvellePart("Part", parent, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end
function Outils.boule(parent, props)
	local p = nouvellePart("Part", parent, props)
	p.Shape = Enum.PartType.Ball
	return p
end

function Outils.modele(parent, nom)
	local m = Instance.new("Model")
	m.Name = nom
	m.Parent = parent
	return m
end
function Outils.dossier(parent, nom)
	local f = Instance.new("Folder")
	f.Name = nom
	f.Parent = parent
	return f
end

-- CFrame d'une part de taille `taille` posée sur le sol (ySol, 0 par défaut) en (x, z), tournée de angleDeg autour de Y
function Outils.surSol(taille, x, z, angleDeg, ySol)
	return CFrame.new(x, (ySol or 0) + taille.Y / 2, z) * CFrame.Angles(0, math.rad(angleDeg or 0), 0)
end

-- texte affiché sur une face d'une part (face : "Front", "Back", "Top", "Left", "Right", "Bottom")
function Outils.texte(part, face, texte, props)
	props = props or {}
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId[face or "Front"]
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = props.pixelsParStud or 40
	gui.LightInfluence = 0
	gui.Parent = part
	local etiquette = Instance.new("TextLabel")
	etiquette.Size = UDim2.fromScale(1, 1)
	etiquette.BackgroundTransparency = 1
	etiquette.Text = texte
	etiquette.TextScaled = true
	etiquette.Font = props.police or Charte.police
	etiquette.TextColor3 = props.couleur or Charte.encre
	etiquette.Parent = gui
	return etiquette
end

-- panneau sur poteau ; props : position (Vector3 au sol), texte, angle (degrés), largeur, couleur
function Outils.panneau(parent, props)
	local m = Outils.modele(parent, props.nom or "Panneau")
	local pos = props.position
	local largeur = props.largeur or 6
	Outils.bloc(m, { Name = "Poteau", Size = Vector3.new(0.6, 5, 0.6), CFrame = Outils.surSol(Vector3.new(0.6, 5, 0.6), pos.X, pos.Z, props.angle, pos.Y), Color = Charte.terre })
	local planche = Outils.bloc(m, {
		Name = "Planche",
		Size = Vector3.new(largeur, 2, 0.4),
		CFrame = CFrame.new(pos.X, pos.Y + 5, pos.Z) * CFrame.Angles(0, math.rad(props.angle or 0), 0),
		Color = props.couleur or Charte.creme,
	})
	Outils.texte(planche, "Front", props.texte or "", { couleur = props.couleurTexte or Charte.encre })
	Outils.texte(planche, "Back", props.texte or "", { couleur = props.couleurTexte or Charte.encre })
	return m
end

-- lumière attachée à une part ; props : genre ("Point", "Spot", "Surface"), Range, Brightness, Color
function Outils.lumiere(part, props)
	props = props or {}
	local l = Instance.new((props.genre or "Point") .. "Light")
	l.Range = props.Range or 12
	l.Brightness = props.Brightness or 1
	l.Color = props.Color or Charte.creme
	l.Parent = part
	return l
end

-- invite d'interaction ; props : nom, action, objet, duree, distance. Le rappel reçoit le joueur (côté serveur).
function Outils.invite(part, props, rappel)
	props = props or {}
	local invite = Instance.new("ProximityPrompt")
	invite.Name = props.nom or "Invite"
	invite.ActionText = props.action or "Utiliser"
	invite.ObjectText = props.objet or ""
	invite.HoldDuration = props.duree or 0
	invite.MaxActivationDistance = props.distance or 10
	invite.RequiresLineOfSight = false
	invite.Parent = part
	if rappel and game:GetService("RunService"):IsServer() then
		invite.Triggered:Connect(rappel)
	end
	return invite
end

-- demande une animation au client (module AnimationsDecor) : "tourne", "flotte" ou "pulse"
function Outils.animer(inst, genre, vitesse)
	inst:SetAttribute("Anime", genre)
	inst:SetAttribute("AnimeVitesse", vitesse or 1)
end

function Outils.aleatoire(graine)
	return Random.new(graine or 1)
end

function Outils.distanceXZ(a, b)
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end


-- ===== terrain Roblox (sol, roches, eau) : toujours dans un pcall, sans jamais bloquer la construction =====
local function remplir(methode, ...)
	local args = table.pack(...)
	local ok, err = pcall(function()
		local t = workspace.Terrain
		t[methode](t, table.unpack(args, 1, args.n))
	end)
	if not ok then warn("[Dino] Terrain:" .. methode .. " : " .. tostring(err)) end
end
-- bloc de terrain (cf = centre, taille = Vector3, materiau = Enum.Material : Grass, LeafyGrass, Ground, Sand, Rock, Slate, Basalt, CrackedLava, Water, Mud...)
function Outils.terrainBloc(cf, taille, materiau) remplir("FillBlock", cf, taille, materiau) end
function Outils.terrainBoule(centre, rayon, materiau) remplir("FillBall", centre, rayon, materiau) end
-- cylindre de terrain d'axe Y (cf = centre)
function Outils.terrainCylindre(cf, hauteur, rayon, materiau) remplir("FillCylinder", cf, hauteur, rayon, materiau) end
-- coin de terrain (comme une WedgePart : pente vers -Z local)
function Outils.terrainCoin(cf, taille, materiau) remplir("FillWedge", cf, taille, materiau) end
function Outils.couleurTerrain(materiau, couleur)
	pcall(function() workspace.Terrain:SetMaterialColor(materiau, couleur) end)
end

-- ===== formes « pro » =====
-- bloc aux arêtes verticales arrondies (piliers, socles, meubles) : 2 blocs en croix + 4 cylindres d'angle.
-- props : Size, CFrame (centre), Color, Material, Name... ; rayon : rayon des arêtes (défaut 0,6). Renvoie un Model.
function Outils.blocArrondi(parent, props, rayon)
	local m = Outils.modele(parent, props.Name or "BlocArrondi")
	local taille = props.Size or Vector3.new(4, 4, 4)
	local cf = props.CFrame or CFrame.new()
	local r = math.min(rayon or 0.6, taille.X / 2 - 0.05, taille.Z / 2 - 0.05)
	local function copie(extra)
		local t = {}
		for k, v in pairs(props) do t[k] = v end
		for k, v in pairs(extra) do t[k] = v end
		return t
	end
	Outils.bloc(m, copie({ Name = "CoeurX", Size = Vector3.new(taille.X - 2 * r, taille.Y, taille.Z), CFrame = cf }))
	Outils.bloc(m, copie({ Name = "CoeurZ", Size = Vector3.new(taille.X, taille.Y, taille.Z - 2 * r), CFrame = cf }))
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			Outils.cylindre(m, copie({
				Name = "Arete",
				Size = Vector3.new(taille.Y, 2 * r, 2 * r),
				CFrame = cf * CFrame.new(sx * (taille.X / 2 - r), 0, sz * (taille.Z / 2 - r)) * CFrame.Angles(0, 0, math.rad(90)),
			}))
		end
	end
	return m
end

-- dalle posée sur un liseré plus sombre et un peu plus large (bordure en relief) ; renvoie la dalle et le liseré
function Outils.dalleBordee(parent, props, bord, couleurBord)
	bord = bord or 0.4
	local taille = props.Size or Vector3.new(8, 1, 8)
	local cf = props.CFrame or CFrame.new()
	local liseret = Outils.bloc(parent, {
		Name = (props.Name or "Dalle") .. "Bord",
		Size = Vector3.new(taille.X + 2 * bord, taille.Y * 0.8, taille.Z + 2 * bord),
		CFrame = cf * CFrame.new(0, -taille.Y * 0.2, 0),
		Color = couleurBord or Charte.ombre(props.Color or Charte.creme),
		Material = props.MaterialBord or props.Material or Enum.Material.SmoothPlastic,
	})
	local t = {}
	for k, v in pairs(props) do if k ~= "MaterialBord" then t[k] = v end end
	local dalle = Outils.bloc(parent, t)
	return dalle, liseret
end

function Outils.nombreParts()
	return compteurParts
end

-- ===== interface (client) =====
local function coins(inst, rayon)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, rayon or 10)
	c.Parent = inst
end

function Outils.cadre(parent, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = Charte.encre
	f.BackgroundTransparency = 0.15
	f.BorderSizePixel = 0
	appliquer(f, props)
	coins(f)
	f.Parent = parent
	return f
end

function Outils.etiquette(parent, props)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Charte.police
	t.TextColor3 = Charte.creme
	t.TextScaled = true
	appliquer(t, props)
	t.Parent = parent
	return t
end

function Outils.bouton(parent, props, rappel)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = Charte.lave
	b.BorderSizePixel = 0
	b.Font = Charte.police
	b.TextColor3 = Charte.creme
	b.TextScaled = true
	b.AutoButtonColor = true
	appliquer(b, props)
	coins(b)
	b.Parent = parent
	if rappel then b.Activated:Connect(rappel) end
	return b
end

return Outils
