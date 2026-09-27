-- Constructeur Place : la grande place du sud où tout le monde apparaît (version 2, rendu « pro »).
-- Dallage en pavés clairs (Cobblestone) dessiné d'anneaux et de rayons d'ardoise (Slate), bordé d'une
-- plinthe en relief ; au centre, l'unique SpawnLocation encastrée dans une estrade de marbre ;
-- au nord, une fontaine de pierre sculptée (Marble / Slate) à l'eau de verre bleu, gardée par une
-- statue de dino en bronze qui crache de l'eau ; au bord sud, la borne Dinodex (coque Metal, écran Neon,
-- invite « Index ») ; bancs en lattes de bois sur pieds de métal, bacs à fleurs et lampadaires.
-- Titres flottants géants (« 🦖 DINO CHAPARDEURS » arc-en-ciel, « 📖 DINODEX » bleu).
-- Emprise (CONTRAT §10) : disque r20 autour de Plan.place.centre. Le secteur ouest-nord-ouest
-- reste libre pour le tableau d'honneur (Systemes/Classement), les axes est et ouest pour les
-- allées vers l'Autel et le Comptoir, l'axe nord pour l'allée du Tapis.
local M = {}

local BUDGET = 260 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.place
local DEFAUTS = {
	rayon = 20,              -- rayon du dallage (emprise)
	epaisseurDalle = 0.22,   -- dessus du dallage (pavés du bord) à Y = 0,22
	tailleApparition = 8,    -- SpawnLocation 8 x 8
	hauteurApparition = 1,   -- dessus de la SpawnLocation à Y = 1
	reculFontaine = 13.5,    -- distance du centre de la fontaine au centre (vers le nord)
	rayonFontaine = 5,       -- rayon du bassin (axe de la margelle)
	echelleStatue = 0.7,     -- échelle de la statue de dino
	debitJet = 60,           -- particules par seconde crachées par le dino
	distanceBorne = 16.5,    -- distance de la borne Dinodex au centre (vers le sud)
	distanceInvite = 10,     -- portée de l'invite « Index »
	rayonBancs = 15,
	rayonFleurs = 17.5,
	rayonLampes = 18.5,
}

local function lireReglages(ctx)
	local source = nil
	if ctx.Equilibrage and type(ctx.Equilibrage.place) == "table" then
		source = ctx.Equilibrage.place
	end
	local r = {}
	for cle, defaut in pairs(DEFAUTS) do
		local v = nil
		if source then
			v = source[cle]
		end
		if type(v) == "number" then
			r[cle] = v
		else
			r[cle] = defaut
		end
	end
	return r
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	local infoPlace = Plan.place or {}
	local CENTRE = infoPlace.centre or Vector3.new(0, 0, 100)
	local CX, CZ = CENTRE.X, CENTRE.Z
	local RAYON = math.min(R.rayon, infoPlace.rayon or R.rayon)
	local Y_SOL = R.epaisseurDalle -- niveau de pose des accessoires
	local Style = ctx.Style
	local hex = Charte.hex
	local ombre = Charte.ombre
	local lumiere = Charte.lumiere

	local MAT = Enum.Material
	-- palette : pavés clairs, ardoise gris-bleu, marbre crème, bronze patiné, eau bleue
	local TEINTES = {
		pave = hex("E8DFCC"),         -- pavés clairs du dallage
		paveCoeur = hex("F1EADB"),    -- pavés du cœur, un ton plus clair
		ardoise = hex("7C8096"),      -- anneaux, rayons et plinthes
		ardoiseFonce = hex("5B5F73"),
		marbre = hex("F3EFE6"),
		marbreOmbre = hex("D9D3C6"),
		pierre = hex("A9A5B6"),       -- pierre sculptée de la margelle
		eau = hex("3FB6EA"),
		eauFond = hex("1F6E8C"),
		bronze = hex("47AE8A"),       -- statue : bronze patiné (vert-de-gris)
		bronzeClair = hex("8FD9B6"),
		or_ = hex("F2B632"),
		bleuBorne = hex("3B7BFF"),
		ecran = hex("5FE3FF"),
		bois = hex("B8743A"),
		metal = hex("3A4152"),
		lanterne = hex("FFE3A3"),
		terreCuite = hex("C8734A"),
		feuillage = hex("3FAE4A"),
	}

	-- ===== compteur de parts : on s'arrête net au budget =====
	local nbParts = 0
	local function reserver(n)
		n = n or 1
		if nbParts + n > BUDGET then
			return false
		end
		nbParts = nbParts + n
		return true
	end
	local function bloc(parent, props)
		if not reserver(1) then return nil end
		return Outils.bloc(parent, props)
	end
	local function coin(parent, props)
		if not reserver(1) then return nil end
		return Outils.coin(parent, props)
	end
	local function boule(parent, props)
		if not reserver(1) then return nil end
		return Outils.boule(parent, props)
	end
	-- bloc aux arêtes verticales arrondies (6 parts)
	local function arrondi(parent, props, rayon)
		if not reserver(6) then return nil end
		return Outils.blocArrondi(parent, props, rayon)
	end
	-- dalle sur liseré en relief (2 parts)
	local function dalleBordee(parent, props, bord, couleurBord)
		if not reserver(2) then return nil end
		return Outils.dalleBordee(parent, props, bord, couleurBord)
	end
	-- cylindre d'axe vertical (l'axe d'un cylindre Roblox est X : on le couche sur Z), posé de yBas à yBas + hauteur
	local function disque(parent, nom, x, z, rayon, hauteur, yBas, couleur, materiau, props)
		if not reserver(1) then return nil end
		local p = Outils.cylindre(parent, {
			Name = nom,
			Size = Vector3.new(hauteur, rayon * 2, rayon * 2),
			CFrame = CFrame.new(x, yBas + hauteur / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
			Material = materiau or MAT.SmoothPlastic,
		})
		if props then
			for cle, valeur in pairs(props) do
				p[cle] = valeur
			end
		end
		return p
	end
	-- anneau de segments droits (margelles, plinthes) autour de (x, z)
	local function anneau(parent, nom, x, z, rayon, segments, largeur, hauteur, yBas, couleur, materiau, couleurAlt)
		local longueur = 2 * rayon * math.tan(math.pi / segments) + largeur * 0.45
		for k = 0, segments - 1 do
			local a = (k + 0.5) * 2 * math.pi / segments
			local c = couleur
			if couleurAlt and k % 2 == 1 then
				c = couleurAlt
			end
			bloc(parent, {
				Name = nom,
				Size = Vector3.new(largeur, hauteur, longueur),
				CFrame = CFrame.new(x + rayon * math.cos(a), yBas + hauteur / 2, z + rayon * math.sin(a)) * CFrame.Angles(0, -a, 0),
				Color = c,
				Material = materiau,
			})
		end
	end
	-- lumière à ombres (les ombres ne sont qu'un plus)
	local function lampe(part, props)
		local l = Outils.lumiere(part, props)
		pcall(function()
			l.Shadows = true
		end)
		return l
	end

	-- position au sol autour du centre (angle en degrés : 0 = est, 90 = sud, 270 = nord)
	local function autour(rayon, angleDeg)
		local a = math.rad(angleDeg)
		return Vector3.new(CX + rayon * math.cos(a), 0, CZ + rayon * math.sin(a))
	end

	-- lance une étape sans que son échec empêche les autres
	local function etape(nom, fn)
		local ok, err = pcall(fn)
		if not ok then
			warn("[Dino] Place / " .. nom .. " : " .. tostring(err))
		end
	end

	-- ===== 1. dallage circulaire : pavés clairs, anneaux et rayons d'ardoise, plinthe =====
	etape("dallage", function()
		local m = Outils.modele(dossier, "Dallage")
		-- disques pleins empilés : chacun dépasse le précédent de 2 cm (pas de scintillement)
		disque(m, "Fond", CX, CZ, RAYON, 0.2, 0, TEINTES.ardoiseFonce, MAT.Slate)
		disque(m, "Paves", CX, CZ, RAYON - 0.7, Y_SOL, 0, TEINTES.pave, MAT.Cobblestone)
		disque(m, "AnneauArdoise", CX, CZ, RAYON * 0.65, Y_SOL + 0.02, 0, TEINTES.ardoise, MAT.Slate)
		disque(m, "PavesCoeur", CX, CZ, RAYON * 0.62, Y_SOL + 0.04, 0, TEINTES.paveCoeur, MAT.Cobblestone)

		-- rose des vents : huit rayons d'ardoise entre l'estrade et l'anneau
		local rInt, rExt = 6.6, RAYON * 0.62
		for k = 0, 7 do
			local angle = k * 45 + 22.5
			local p = autour((rInt + rExt) / 2, angle)
			bloc(m, {
				Name = "Rayon",
				Size = Vector3.new(rExt - rInt, 0.06, 0.7),
				CFrame = CFrame.new(p.X, Y_SOL + 0.04, p.Z) * CFrame.Angles(0, -math.rad(angle), 0),
				Color = TEINTES.ardoise,
				Material = MAT.Slate,
			})
		end
		-- rayons extérieurs, dans l'axe des diagonales (hors allées, fontaine et borne)
		local rInt2, rExt2 = RAYON * 0.65, RAYON - 0.7
		for _, angle in ipairs({ 45, 135, 225, 315, 0, 180 }) do
			local p = autour((rInt2 + rExt2) / 2, angle)
			bloc(m, {
				Name = "RayonExterieur",
				Size = Vector3.new(rExt2 - rInt2, 0.04, 0.5),
				CFrame = CFrame.new(p.X, Y_SOL + 0.01, p.Z) * CFrame.Angles(0, -math.rad(angle), 0),
				Color = TEINTES.ardoise,
				Material = MAT.Slate,
			})
		end

		-- plinthe en relief tout autour (ardoise, arêtes claires en alternance)
		anneau(m, "Plinthe", CX, CZ, RAYON - 0.45, 20, 0.7, 0.4, 0, TEINTES.ardoise, MAT.Slate, lumiere(TEINTES.ardoise))
	end)

	-- ===== 2. l'unique SpawnLocation, encastrée dans une estrade de marbre =====
	etape("apparition", function()
		local m = Outils.modele(dossier, "Apparition")
		local t = R.tailleApparition
		local h = R.hauteurApparition
		local rEstrade = t * 0.707 + 0.7
		disque(m, "Marche", CX, CZ, rEstrade + 0.6, 0.45, 0, TEINTES.ardoise, MAT.Slate)
		disque(m, "Estrade", CX, CZ, rEstrade, 0.6, 0, TEINTES.marbre, MAT.Marble)
		-- cadre d'ardoise sous la SpawnLocation (liseré de 0,4 visible tout autour)
		bloc(m, {
			Name = "Cadre",
			Size = Vector3.new(t + 0.8, h - 0.15, t + 0.8),
			CFrame = CFrame.new(CX, (h - 0.15) / 2, CZ),
			Color = TEINTES.ardoiseFonce,
			Material = MAT.Slate,
		})
		-- clous dorés aux quatre coins du cadre
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				disque(m, "Clou", CX + sx * (t / 2 + 0.2), CZ + sz * (t / 2 + 0.2), 0.3, 0.25, h - 0.15, TEINTES.or_, MAT.Metal, {
					CanCollide = false,
				})
			end
		end
		if reserver(1) then
			local sp = Instance.new("SpawnLocation")
			sp.Name = "Apparition"
			sp.Anchored = true
			sp.Size = Vector3.new(t, h, t)
			sp.CFrame = CFrame.new(CX, h / 2, CZ) -- dessus à Y = h
			sp.Material = MAT.Marble
			sp.TopSurface = Enum.SurfaceType.Smooth
			sp.BottomSurface = Enum.SurfaceType.Smooth
			sp.Color = hex("F5C54A")
			sp.Neutral = true
			sp.Duration = 0
			sp.AllowTeamChangeOnTouch = false
			sp.Enabled = true
			sp.Parent = m
			local ok = pcall(function()
				local inscription = Outils.texte(sp, "Top", "DINO CHAPARDEURS", {
					couleur = Color3.new(1, 1, 1),
					police = Style and Style.policeTitre or Charte.police,
					pixelsParStud = 30,
				})
				if Style and inscription then
					Style.contour(inscription, 4)
				end
			end)
			if not ok then
				sp:ClearAllChildren()
			end
		end
	end)

	-- ===== 3. fontaine de pierre sculptée et statue de dino en bronze =====
	etape("fontaine", function()
		local m = Outils.modele(dossier, "Fontaine")
		local fx, fz = CX, CZ - R.reculFontaine
		local rf = R.rayonFontaine

		-- socle, fond sombre, eau de verre bleu
		disque(m, "Socle", fx, fz, rf + 0.8, 0.4, 0, TEINTES.ardoiseFonce, MAT.Slate)
		disque(m, "Fond", fx, fz, rf - 0.3, 0.45, 0, TEINTES.eauFond, MAT.Slate)
		local eau = disque(m, "Eau", fx, fz, rf - 0.3, 0.25, 1.15, TEINTES.eau, MAT.Glass, {
			Transparency = 0.35,
			Reflectance = 0.15,
			CanCollide = false,
		})
		-- margelle : mur de pierre et couronnement de marbre qui déborde
		anneau(m, "Margelle", fx, fz, rf, 16, 0.8, 1.4, 0.3, TEINTES.pierre, MAT.Slate, ombre(TEINTES.pierre))
		anneau(m, "Couronnement", fx, fz, rf, 16, 1.15, 0.28, 1.7, TEINTES.marbre, MAT.Marble)

		-- piédestal sculpté : base, fût, bague dorée, chapiteau et tablette
		disque(m, "BasePiedestal", fx, fz, 1.9, 0.9, 0.3, TEINTES.pierre, MAT.Slate)
		local piedestal = disque(m, "Piedestal", fx, fz, 1.4, 2.9, 0.3, TEINTES.marbre, MAT.Marble)
		disque(m, "Bague", fx, fz, 1.5, 0.22, 2.35, TEINTES.or_, MAT.Metal)
		disque(m, "Chapiteau", fx, fz, 2, 0.35, 3.2, TEINTES.pierre, MAT.Slate)
		disque(m, "Tablette", fx, fz, 1.75, 0.2, 3.55, TEINTES.marbreOmbre, MAT.Marble)
		local yStatue = 3.75

		-- quatre becs de pierre sur le fût, qui crachent un filet d'eau vers le bassin
		for _, deg in ipairs({ 45, 135, 225, 315 }) do
			local a = math.rad(deg)
			local dx, dz = math.cos(a), math.sin(a)
			local bec = bloc(m, {
				Name = "Bec",
				Size = Vector3.new(0.7, 0.35, 0.45),
				CFrame = CFrame.new(fx + dx * 1.6, 1.95, fz + dz * 1.6) * CFrame.Angles(0, -a, 0),
				Color = TEINTES.ardoise,
				Material = MAT.Slate,
			})
			if bec then
				pcall(function()
					local att = Instance.new("Attachment")
					att.Name = "Filet"
					att.Parent = bec
					att.WorldCFrame = CFrame.lookAt(Vector3.new(fx + dx * 1.95, 1.95, fz + dz * 1.95), Vector3.new(fx + dx * 3, 2.3, fz + dz * 3))
					local filet = Instance.new("ParticleEmitter")
					filet.Name = "Eau"
					filet.EmissionDirection = Enum.NormalId.Front
					filet.Color = ColorSequence.new(lumiere(TEINTES.eau), Color3.new(1, 1, 1))
					filet.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.18),
						NumberSequenceKeypoint.new(1, 0.35),
					})
					filet.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.2),
						NumberSequenceKeypoint.new(1, 0.8),
					})
					filet.Lifetime = NumberRange.new(0.45, 0.55)
					filet.Rate = 30
					filet.Speed = NumberRange.new(3, 3.4)
					filet.SpreadAngle = Vector2.new(3, 3)
					filet.Acceleration = Vector3.new(0, -18, 0)
					filet.LightEmission = 0.2
					filet.Parent = att
				end)
			end
		end

		-- statue : repère tourné vers le sud (le dino regarde l'apparition), reculé d'un stud
		local S = R.echelleStatue
		local repere = CFrame.new(fx, yStatue, fz) * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, 1)
		local bronze = TEINTES.bronze
		local bronzeOmbre = ombre(TEINTES.bronze)
		local ventre = TEINTES.bronzeClair
		-- (x, y, avant) en unités de statue ; l'avant est -Z local
		local function morceau(nom, sx, sy, sz, x, y, f, couleur, rotX, forme, materiau)
			local props = {
				Name = nom,
				Size = Vector3.new(sx * S, sy * S, sz * S),
				CFrame = repere * CFrame.new(x * S, y * S, -f * S) * CFrame.Angles(math.rad(rotX or 0), 0, 0),
				Color = couleur,
				Material = materiau or MAT.Metal,
				CanCollide = false,
			}
			if forme == "boule" then
				return boule(m, props)
			elseif forme == "coin" then
				return coin(m, props)
			end
			return bloc(m, props)
		end

		morceau("Corps", 3, 3, 4, 0, 2.9, 0, bronze)
		morceau("Poitrail", 2.9, 2.9, 2.9, 0, 3.1, 1.1, bronze, 0, "boule")
		morceau("Ventre", 2.1, 2.1, 0.3, 0, 2.7, 2.35, ventre)
		morceau("CuisseG", 1.5, 2.4, 2.4, -1.35, 2, -0.3, bronze, 0, "boule")
		morceau("CuisseD", 1.5, 2.4, 2.4, 1.35, 2, -0.3, bronze, 0, "boule")
		morceau("JambeG", 1, 1.4, 1, -1.35, 0.8, 0, bronzeOmbre)
		morceau("JambeD", 1, 1.4, 1, 1.35, 0.8, 0, bronzeOmbre)
		morceau("PiedG", 1.4, 0.5, 2.2, -1.35, 0.25, 0.4, bronzeOmbre)
		morceau("PiedD", 1.4, 0.5, 2.2, 1.35, 0.25, 0.4, bronzeOmbre)
		morceau("BrasG", 0.5, 0.5, 1.3, -1.2, 3.4, 2.4, bronze, -20)
		morceau("BrasD", 0.5, 0.5, 1.3, 1.2, 3.4, 2.4, bronze, -20)
		morceau("Cou", 1.8, 2, 1.8, 0, 4.6, 1.5, bronze)
		morceau("Tete", 2.4, 2, 2.8, 0, 5.9, 2.4, bronze)
		local machoire = morceau("Machoire", 2, 0.9, 1.8, 0, 5.8, 4.4, bronze)
		morceau("MachoireBas", 1.8, 0.5, 1.6, 0, 4.9, 4.1, ventre, -15)
		morceau("DentG", 0.3, 0.4, 0.3, -0.6, 5.2, 5.0, TEINTES.marbre, 0, nil, MAT.Marble)
		morceau("DentD", 0.3, 0.4, 0.3, 0.6, 5.2, 5.0, TEINTES.marbre, 0, nil, MAT.Marble)
		morceau("OeilG", 0.7, 0.7, 0.7, -1.15, 6.3, 3.0, TEINTES.or_, 0, "boule")
		morceau("OeilD", 0.7, 0.7, 0.7, 1.15, 6.3, 3.0, TEINTES.or_, 0, "boule")
		morceau("Queue", 2.2, 2.2, 2.4, 0, 3, -3.1, bronze)
		morceau("QueueMilieu", 1.7, 1.7, 2, 0.4, 2.6, -4.7, bronzeOmbre)
		morceau("QueueBout", 1.1, 1.1, 1.8, 1.2, 2.2, -5.7, bronze)
		morceau("Pic", 0.4, 1, 1.2, 0, 4.9, -1.3, TEINTES.or_, 0, "coin")
		morceau("Pic", 0.4, 1, 1.2, 0, 4.9, 0, TEINTES.or_, 0, "coin")
		morceau("Pic", 0.4, 0.8, 1, 0, 4.5, -3.1, TEINTES.or_, 0, "coin")
		morceau("Pic", 0.4, 0.8, 1, 0, 6.9, 1.9, TEINTES.or_, 0, "coin")

		-- le jet : de la gueule, presque vertical, retombe dans le bassin
		if machoire then
			local okJet = pcall(function()
				local attache = Instance.new("Attachment")
				attache.Name = "Jet"
				attache.Parent = machoire
				attache.WorldCFrame = machoire.CFrame * CFrame.new(0, -0.3 * S, -0.7 * S) * CFrame.Angles(math.rad(-10), 0, 0)
				local jet = Instance.new("ParticleEmitter")
				jet.Name = "Eau"
				jet.EmissionDirection = Enum.NormalId.Top
				jet.Color = ColorSequence.new(TEINTES.eau, Color3.new(1, 1, 1))
				jet.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 0.55),
				})
				jet.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.15),
					NumberSequenceKeypoint.new(1, 0.7),
				})
				jet.Lifetime = NumberRange.new(1, 1.1)
				jet.Rate = R.debitJet
				jet.Speed = NumberRange.new(6, 6.5)
				jet.SpreadAngle = Vector2.new(4, 4)
				jet.Acceleration = Vector3.new(0, -20, 0)
				jet.LightEmission = 0.2
				jet.Parent = attache
			end)
			if not okJet then
				local reste = machoire:FindFirstChild("Jet")
				if reste then reste:Destroy() end
			end
		end

		-- éclaboussures là où le jet retombe, reflets et lumière sous l'eau
		if eau then
			pcall(function()
				local impact = Instance.new("Attachment")
				impact.Name = "Impact"
				impact.Parent = eau
				impact.WorldCFrame = CFrame.new(fx, 1.45, fz + 3.9 * S * 1.1)
				local gerbe = Instance.new("ParticleEmitter")
				gerbe.Name = "Gerbe"
				gerbe.EmissionDirection = Enum.NormalId.Top
				gerbe.Color = ColorSequence.new(Color3.new(1, 1, 1))
				gerbe.Size = NumberSequence.new(0.25)
				gerbe.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1),
				})
				gerbe.Lifetime = NumberRange.new(0.35, 0.5)
				gerbe.Rate = 25
				gerbe.Speed = NumberRange.new(2, 4)
				gerbe.SpreadAngle = Vector2.new(35, 35)
				gerbe.Acceleration = Vector3.new(0, -20, 0)
				gerbe.Parent = impact

				-- scintillements à la surface du bassin
				local surface = Instance.new("Attachment")
				surface.Name = "Surface"
				surface.Parent = eau
				surface.WorldCFrame = CFrame.new(fx + 2.8, 1.45, fz)
				local reflets = Instance.new("ParticleEmitter")
				reflets.Name = "Reflets"
				reflets.EmissionDirection = Enum.NormalId.Top
				reflets.Color = ColorSequence.new(Color3.new(1, 1, 1))
				reflets.Size = NumberSequence.new(0.15)
				reflets.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 1),
				})
				reflets.Lifetime = NumberRange.new(0.6, 0.9)
				reflets.Rate = 8
				reflets.Speed = NumberRange.new(0.3, 0.6)
				reflets.SpreadAngle = Vector2.new(80, 80)
				reflets.LightEmission = 0.6
				reflets.Parent = surface

				Outils.lumiere(eau, { Range = 10, Brightness = 0.7, Color = Charte.gemme })
			end)
		end

		-- titre flottant géant au-dessus de la fontaine, arc-en-ciel animé, visible de loin
		if Style then
			local ancre = bloc(m, {
				Name = "AncreTitre",
				Size = Vector3.new(1, 1, 1),
				CFrame = CFrame.new(fx, yStatue + 9 * S + 3, fz),
				Transparency = 1,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
			})
			if not ancre then
				ancre = piedestal
			end
			if ancre then
				local decalage = Vector3.new(0, 0, 0)
				if ancre == piedestal then
					decalage = Vector3.new(0, 9 * S + 3, 0)
				end
				Style.etiquette(ancre, {
					{ texte = "🦖 DINO CHAPARDEURS", titre = true, rarete = "Divin", taille = 1, contour = 4, nom = "Titre" },
					{ texte = "Chaparde les dinos les plus rares !", couleur = Style.couleurs.revenu, taille = 0.45, contour = 3, nom = "Slogan" },
				}, {
					Name = "TitrePlace",
					largeur = 34,
					hauteurLigne = 5,
					StudsOffset = decalage,
					MaxDistance = 300,
					AlwaysOnTop = false,
				})
			end
		end
	end)

	-- ===== 4. borne Dinodex au bord sud : coque Metal, écran Neon =====
	etape("dinodex", function()
		local m = Outils.modele(dossier, "Dinodex")
		local bx, bz = CX, CZ + R.distanceBorne
		-- la borne regarde le nord (face avant -Z vers le centre de la Place)
		local function ici(x, y, z)
			return CFrame.new(bx + x, y, bz + z)
		end

		dalleBordee(m, {
			Name = "Socle",
			Size = Vector3.new(5.6, 0.5, 3.6),
			CFrame = ici(0, 0.25 + 0.2, 0),
			Color = TEINTES.pierre,
			Material = MAT.Slate,
		}, 0.35, TEINTES.ardoiseFonce)
		local yBas = 0.7
		bloc(m, {
			Name = "Plinthe",
			Size = Vector3.new(4.8, 0.4, 2.8),
			CFrame = ici(0, yBas + 0.2, 0.3),
			Color = TEINTES.metal,
			Material = MAT.DiamondPlate,
		})
		yBas = yBas + 0.4
		local hCoque = 5.4
		local coque = arrondi(m, {
			Name = "Coque",
			Size = Vector3.new(4.2, hCoque, 2.2),
			CFrame = ici(0, yBas + hCoque / 2, 0.3),
			Color = TEINTES.bleuBorne,
			Material = MAT.Metal,
		}, 0.45)
		local borne = nil
		if coque then
			borne = coque:FindFirstChild("CoeurX")
			if borne then
				borne.Name = "Borne"
			end
		end
		local avant = 0.3 - 1.1 -- face avant de la coque
		bloc(m, {
			Name = "Cadre",
			Size = Vector3.new(3.8, 3, 0.2),
			CFrame = ici(0, yBas + 3.3, avant - 0.1),
			Color = TEINTES.metal,
			Material = MAT.Metal,
		})
		local ecran = bloc(m, {
			Name = "Ecran",
			Size = Vector3.new(3.4, 2.6, 0.1),
			CFrame = ici(0, yBas + 3.3, avant - 0.25),
			Color = TEINTES.ecran,
			Material = MAT.Neon,
		})
		-- pupitre incliné sous l'écran, avec son voyant
		coin(m, {
			Name = "Pupitre",
			Size = Vector3.new(3.4, 0.9, 0.8),
			CFrame = ici(0, yBas + 1.45, avant - 0.4),
			Color = ombre(TEINTES.bleuBorne),
			Material = MAT.Metal,
		})
		local voyant = bloc(m, {
			Name = "Voyant",
			Size = Vector3.new(1.4, 0.25, 0.12),
			CFrame = ici(0, yBas + 0.8, avant - 0.08),
			Color = Charte.gemme,
			Material = MAT.Neon,
		})
		-- filets lumineux de part et d'autre de l'écran
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Liseret",
				Size = Vector3.new(0.14, 3, 0.22),
				CFrame = ici(sx * 1.97, yBas + 3.3, avant - 0.1),
				Color = Charte.gemme,
				Material = MAT.Neon,
			})
		end
		-- toit, nid doré, œuf lumineux et halo tournant
		bloc(m, {
			Name = "Toit",
			Size = Vector3.new(4.7, 0.35, 2.7),
			CFrame = ici(0, yBas + hCoque + 0.175, 0.3),
			Color = ombre(TEINTES.bleuBorne),
			Material = MAT.Metal,
		})
		local yToit = yBas + hCoque + 0.35
		disque(m, "Nid", bx, bz + 0.3, 0.9, 0.35, yToit, TEINTES.or_, MAT.Metal)
		local oeuf = boule(m, {
			Name = "Oeuf",
			Size = Vector3.new(1.4, 1.7, 1.4),
			CFrame = ici(0, yToit + 1.5, 0.3),
			Color = Charte.dore,
			Material = MAT.Neon,
			CanCollide = false,
		})
		local halo = disque(m, "Halo", bx, bz + 0.3, 1.3, 0.1, yToit + 1.4, Charte.gemme, MAT.Neon, {
			Transparency = 0.45,
			CanCollide = false,
		})
		if halo then
			Outils.animer(halo, "tourne", 0.6)
		end
		if oeuf then
			Outils.animer(oeuf, "flotte", 0.8)
			lampe(oeuf, { Range = 12, Brightness = 1.2, Color = Charte.dore })
		end
		if voyant then
			Outils.animer(voyant, "pulse", 1.2)
		end
		if ecran then
			Outils.lumiere(ecran, { genre = "Surface", Range = 8, Brightness = 0.8, Color = TEINTES.ecran })
		end
		if not borne then
			-- repli : une part simple porte l'invite
			borne = bloc(m, {
				Name = "Borne",
				Size = Vector3.new(4, hCoque, 2),
				CFrame = ici(0, yBas + hCoque / 2, 0.3),
				Color = TEINTES.bleuBorne,
				Material = MAT.Metal,
			})
		end
		if borne then
			m.PrimaryPart = borne
			-- aucun rappel : le client ouvre le panneau (Client.client.lua filtre « Index »)
			Outils.invite(borne, { nom = "Index", action = "Ouvrir", objet = "Dinodex", distance = R.distanceInvite })
		end

		local nbEspeces = 0
		local especes = ctx.Equilibrage and ctx.Equilibrage.especes
		if type(especes) == "table" then
			for _ in pairs(especes) do
				nbEspeces = nbEspeces + 1
			end
		end
		local texteEspeces = "Toutes les espèces à découvrir"
		if nbEspeces > 0 then
			texteEspeces = nbEspeces .. " espèces à découvrir"
		end

		-- titre flottant « 📖 DINODEX » bleu cerné de noir au-dessus de la borne (et de l'œuf)
		if Style and borne then
			local bleu = Style.boutons.bleu
			local _, lignes = Style.etiquette(borne, {
				{ texte = "📖 DINODEX", titre = true, couleur = Color3.new(1, 1, 1), taille = 1, contour = 4, nom = "Titre" },
				{ texte = texteEspeces, taille = 0.5, contour = 3, nom = "SousTitre" },
			}, {
				Name = "TitreDinodex",
				largeur = 14,
				hauteurLigne = 2.4,
				StudsOffset = Vector3.new(0, 8.4, 0),
				MaxDistance = 160,
				AlwaysOnTop = false,
			})
			if lignes and lignes[1] then
				Style.degrade(lignes[1], bleu[1], bleu[2])
			end
		end

		-- écran : titre, bandeau des raretés, nombre d'espèces
		if ecran then
			local ok, err = pcall(function()
				local gui = Instance.new("SurfaceGui")
				gui.Name = "Affiche"
				gui.Face = Enum.NormalId.Front
				gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
				gui.PixelsPerStud = 50
				gui.LightInfluence = 0
				gui.Parent = ecran

				local fond = Instance.new("Frame")
				fond.Name = "Fond"
				fond.Size = UDim2.fromScale(1, 1)
				fond.BackgroundColor3 = Charte.encre
				fond.BorderSizePixel = 0
				fond.Parent = gui
				if Style then
					-- fond blanc teinté par un dégradé bleu nuit, comme un écran allumé
					fond.BackgroundColor3 = Color3.new(1, 1, 1)
					Style.degrade(fond, Style.couleurs.fondHaut or lumiere(Style.couleurs.fond), Style.couleurs.fond)
				end

				local titre
				if Style then
					titre = Style.texte(fond, {
						Name = "Titre",
						Position = UDim2.fromScale(0.05, 0.06),
						Size = UDim2.fromScale(0.9, 0.4),
						Text = "📖 DINODEX",
						titre = true,
						contour = 4,
					})
					Style.degrade(titre, Style.boutons.bleu[1], Style.boutons.bleu[2])
				else
					titre = Instance.new("TextLabel")
					titre.Name = "Titre"
					titre.BackgroundTransparency = 1
					titre.Position = UDim2.fromScale(0.05, 0.06)
					titre.Size = UDim2.fromScale(0.9, 0.4)
					titre.Font = Charte.police
					titre.Text = "DINODEX"
					titre.TextScaled = true
					titre.TextColor3 = Charte.dore
					titre.Parent = fond
				end

				-- bandeau : une case par rareté, dans l'ordre
				local cles = {}
				local raretes = ctx.Equilibrage and ctx.Equilibrage.raretes
				if type(raretes) == "table" then
					for cle, info in pairs(raretes) do
						if Charte.raretes[cle] then
							local ordre = 99
							if type(info) == "table" and type(info.ordre) == "number" then
								ordre = info.ordre
							end
							table.insert(cles, { cle = cle, ordre = ordre })
						end
					end
				end
				table.sort(cles, function(a, b) return a.ordre < b.ordre end)
				local n = #cles
				for i, e in ipairs(cles) do
					local case = Instance.new("Frame")
					case.Name = "Rarete" .. e.cle
					case.BorderSizePixel = 0
					case.BackgroundColor3 = Charte.raretes[e.cle]
					case.Position = UDim2.fromScale(0.08 + (i - 1) * (0.84 / n), 0.49)
					case.Size = UDim2.fromScale(0.84 / n - 0.02, 0.13)
					case.Parent = fond
					if Style then
						-- case blanche teintée par le dégradé de rareté, arrondie et cernée
						case.BackgroundColor3 = Color3.new(1, 1, 1)
						Style.degradeRarete(case, e.cle)
						Style.coins(case, 6)
						Style.bordure(case, 2)
					end
				end

				if Style then
					Style.texte(fond, {
						Name = "SousTitre",
						Position = UDim2.fromScale(0.05, 0.68),
						Size = UDim2.fromScale(0.9, 0.24),
						Text = texteEspeces,
						contour = 3,
					})
				else
					local sous = Instance.new("TextLabel")
					sous.Name = "SousTitre"
					sous.BackgroundTransparency = 1
					sous.Position = UDim2.fromScale(0.05, 0.66)
					sous.Size = UDim2.fromScale(0.9, 0.26)
					sous.Font = Charte.policeTexte
					sous.Text = texteEspeces
					sous.TextScaled = true
					sous.TextColor3 = Charte.creme
					sous.Parent = fond
				end
			end)
			if not ok then
				warn("[Dino] Place / écran Dinodex : " .. tostring(err))
			end
		end
	end)

	-- ===== 5. bancs : lattes de bois sur pieds de métal =====
	etape("bancs", function()
		local m = Outils.modele(dossier, "Bancs")
		local fontaine = Vector3.new(CX, 0, CZ - R.reculFontaine)
		local bois = TEINTES.bois
		local function banc(pos, cible)
			-- l'avant (-Z local) regarde la cible
			local repere = CFrame.lookAt(Vector3.new(pos.X, Y_SOL, pos.Z), Vector3.new(cible.X, Y_SOL, cible.Z))
			bloc(m, { Name = "Latte", Size = Vector3.new(5, 0.22, 0.72), CFrame = repere * CFrame.new(0, 1.25, -0.39), Color = bois, Material = MAT.WoodPlanks })
			bloc(m, { Name = "Latte", Size = Vector3.new(5, 0.22, 0.72), CFrame = repere * CFrame.new(0, 1.25, 0.39), Color = ombre(bois), Material = MAT.WoodPlanks })
			-- dossier incliné vers l'arrière (+Z local)
			local dos = repere * CFrame.new(0, 0, 0.6) * CFrame.Angles(math.rad(10), 0, 0)
			bloc(m, { Name = "Dossier", Size = Vector3.new(5, 0.5, 0.18), CFrame = dos * CFrame.new(0, 1.85, 0), Color = bois, Material = MAT.WoodPlanks })
			bloc(m, { Name = "Dossier", Size = Vector3.new(5, 0.5, 0.18), CFrame = dos * CFrame.new(0, 2.5, 0), Color = lumiere(bois), Material = MAT.WoodPlanks })
			for _, sx in ipairs({ -2.1, 2.1 }) do
				bloc(m, { Name = "Pied", Size = Vector3.new(0.22, 1.14, 1.6), CFrame = repere * CFrame.new(sx, 0.57, 0), Color = TEINTES.metal, Material = MAT.Metal })
				bloc(m, { Name = "Montant", Size = Vector3.new(0.22, 1.7, 0.22), CFrame = dos * CFrame.new(sx, 2.05, 0.15), Color = TEINTES.metal, Material = MAT.Metal })
			end
		end
		banc(autour(R.rayonBancs, 45), CENTRE)
		banc(autour(R.rayonBancs, 135), CENTRE)
		-- de part et d'autre de la fontaine, face à elle
		banc(Vector3.new(CX - 8.5, 0, fontaine.Z), fontaine)
		banc(Vector3.new(CX + 8.5, 0, fontaine.Z), fontaine)
	end)

	-- ===== 6. bacs à fleurs : terre cuite, rebord d'ardoise, buisson fleuri =====
	etape("fleurs", function()
		local m = Outils.modele(dossier, "Fleurs")
		local couleursFleurs = { Charte.alerte, Charte.dore, Charte.violet, hex("FF8FC7"), Color3.new(1, 1, 1) }
		local hasard = Outils.aleatoire(2026)
		local function bac(x, z, angle)
			local repere = CFrame.new(x, Y_SOL, z) * CFrame.Angles(0, -math.rad(angle), 0)
			bloc(m, { Name = "Bac", Size = Vector3.new(2.4, 1, 2.4), CFrame = repere * CFrame.new(0, 0.5, 0), Color = TEINTES.terreCuite, Material = MAT.Brick })
			bloc(m, { Name = "Rebord", Size = Vector3.new(2.7, 0.22, 2.7), CFrame = repere * CFrame.new(0, 1.05, 0), Color = TEINTES.pierre, Material = MAT.Slate })
			boule(m, {
				Name = "Buisson",
				Size = Vector3.new(2.3, 1.5, 2.3),
				CFrame = repere * CFrame.new(0, 1.55, 0),
				Color = TEINTES.feuillage,
				Material = MAT.LeafyGrass,
				CanCollide = false,
			})
			local places = { { -0.55, -0.45 }, { 0.6, -0.3 }, { 0, 0.6 } }
			local premiere = hasard:NextInteger(1, #couleursFleurs)
			for i, d in ipairs(places) do
				local c = couleursFleurs[(premiere + i - 2) % #couleursFleurs + 1]
				boule(m, {
					Name = "Fleur",
					Size = Vector3.new(0.6, 0.6, 0.6),
					CFrame = repere * CFrame.new(d[1], 2.2 + hasard:NextNumber() * 0.15, d[2]),
					Color = c,
					CanCollide = false,
				})
			end
		end
		for _, a in ipairs({ 25, 155, 340 }) do
			local p = autour(R.rayonFleurs, a)
			bac(p.X, p.Z, a)
		end
		-- de part et d'autre de la borne Dinodex
		bac(CX - 5.3, CZ + R.distanceBorne + 0.3, 0)
		bac(CX + 5.3, CZ + R.distanceBorne + 0.3, 0)
	end)

	-- ===== 7. lampadaires (fonte sombre, lanterne chaude à ombres) =====
	etape("lampadaires", function()
		local m = Outils.modele(dossier, "Lampadaires")
		local function lampadaire(pos)
			local x, z = pos.X, pos.Z
			disque(m, "Pied", x, z, 0.55, 0.5, Y_SOL, TEINTES.metal, MAT.Metal)
			disque(m, "Mat", x, z, 0.18, 5.6, Y_SOL + 0.5, TEINTES.metal, MAT.Metal)
			disque(m, "Bague", x, z, 0.28, 0.25, Y_SOL + 2.2, TEINTES.or_, MAT.Metal)
			disque(m, "Coupelle", x, z, 0.45, 0.2, Y_SOL + 6.1, TEINTES.metal, MAT.Metal)
			local globe = boule(m, {
				Name = "Lanterne",
				Size = Vector3.new(1.1, 1.1, 1.1),
				CFrame = CFrame.new(x, Y_SOL + 6.85, z),
				Color = TEINTES.lanterne,
				Material = MAT.Neon,
				CanCollide = false,
			})
			disque(m, "Chapeau", x, z, 0.7, 0.22, Y_SOL + 7.4, TEINTES.metal, MAT.Metal)
			if globe then
				lampe(globe, { Range = 16, Brightness = 1.1, Color = TEINTES.lanterne })
			end
		end
		for _, a in ipairs({ 45, 135, 235, 305 }) do
			lampadaire(autour(R.rayonLampes, a))
		end
	end)

	dossier:SetAttribute("Parts", nbParts)
end

return M
