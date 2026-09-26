-- Constructeur Place : la grande place du sud où tout le monde apparaît.
-- Au centre, l'unique SpawnLocation sur un socle ; dallage circulaire sable et crème ;
-- au nord, une fontaine gardée par une statue de dino en blocs qui crache de l'eau ;
-- au bord sud, la borne Dinodex (invite « Index », ouverte côté client) ; bancs et bacs à fleurs.
-- Emprise (CONTRAT §10) : disque r20 autour de Plan.place.centre. Le secteur ouest-nord-ouest
-- reste libre pour le tableau d'honneur (Systemes/Classement), les axes est et ouest pour les
-- allées vers l'Autel et le Comptoir.
local M = {}

local BUDGET = 200 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.place
local DEFAUTS = {
	rayon = 20,              -- rayon du dallage (emprise)
	epaisseurDalle = 0.2,    -- dessus du dallage à Y = 0,2
	tailleApparition = 8,    -- SpawnLocation 8 x 8
	hauteurApparition = 1,   -- dessus de la SpawnLocation à Y = 1
	reculFontaine = 13.5,    -- distance du centre de la fontaine au centre (vers le nord)
	rayonFontaine = 5,       -- rayon du bassin
	echelleStatue = 0.7,     -- échelle de la statue de dino
	debitJet = 60,           -- particules par seconde crachées par le dino
	distanceBorne = 16.5,    -- distance de la borne Dinodex au centre (vers le sud)
	distanceInvite = 10,     -- portée de l'invite « Index »
	rayonBancs = 15,
	rayonFleurs = 17.5,
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
	local Y_DALLE = R.epaisseurDalle

	-- ===== compteur de parts : on s'arrête net au budget =====
	local nbParts = 0
	local function reserver()
		if nbParts >= BUDGET then
			return false
		end
		nbParts = nbParts + 1
		return true
	end
	local function bloc(parent, props)
		if not reserver() then return nil end
		return Outils.bloc(parent, props)
	end
	local function coin(parent, props)
		if not reserver() then return nil end
		return Outils.coin(parent, props)
	end
	local function boule(parent, props)
		if not reserver() then return nil end
		return Outils.boule(parent, props)
	end
	-- disque horizontal (l'axe d'un cylindre Roblox est X : on le couche sur Z)
	local function disque(parent, nom, x, z, rayon, epaisseur, yBas, couleur, props)
		if not reserver() then return nil end
		local p = Outils.cylindre(parent, {
			Name = nom,
			Size = Vector3.new(epaisseur, rayon * 2, rayon * 2),
			CFrame = CFrame.new(x, yBas + epaisseur / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
		})
		if props then
			for cle, valeur in pairs(props) do
				p[cle] = valeur
			end
		end
		return p
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

	-- ===== 1. dallage circulaire =====
	etape("dallage", function()
		local m = Outils.modele(dossier, "Dallage")
		-- anneaux concentriques, chacun un souffle plus haut pour éviter le scintillement
		disque(m, "Bord", CX, CZ, RAYON, Y_DALLE, 0, Charte.sable)
		disque(m, "AnneauCreme", CX, CZ, RAYON * 0.75, 0.02, Y_DALLE, Charte.creme)
		disque(m, "AnneauSable", CX, CZ, RAYON * 0.67, 0.02, Y_DALLE + 0.02, Charte.sable)
		disque(m, "Coeur", CX, CZ, RAYON * 0.36, 0.02, Y_DALLE + 0.04, Charte.creme)
		-- rayons de dalles crème entre le cœur et l'anneau, comme une rose des vents
		local rInt, rExt = RAYON * 0.36, RAYON * 0.67
		local longueur = rExt - rInt
		for k = 0, 7 do
			local angle = k * 45 + 22.5
			local p = autour((rInt + rExt) / 2, angle)
			bloc(m, {
				Name = "Rayon",
				Size = Vector3.new(longueur, 0.02, 0.8),
				CFrame = CFrame.new(p.X, Y_DALLE + 0.05, p.Z) * CFrame.Angles(0, -math.rad(angle), 0),
				Color = Charte.creme,
			})
		end
	end)

	-- ===== 2. l'unique SpawnLocation =====
	etape("apparition", function()
		local m = Outils.modele(dossier, "Apparition")
		local t = R.tailleApparition
		local h = R.hauteurApparition
		-- socle en marche d'escalier autour de la SpawnLocation
		bloc(m, {
			Name = "Socle",
			Size = Vector3.new(t + 1.6, h * 0.6, t + 1.6),
			CFrame = CFrame.new(CX, Y_DALLE + h * 0.3, CZ),
			Color = Charte.lumiere(Charte.pierre),
		})
		if reserver() then
			local sp = Instance.new("SpawnLocation")
			sp.Name = "Apparition"
			sp.Anchored = true
			sp.Size = Vector3.new(t, h, t)
			sp.CFrame = CFrame.new(CX, h / 2, CZ) -- dessus à Y = h
			sp.Material = Enum.Material.SmoothPlastic
			sp.TopSurface = Enum.SurfaceType.Smooth
			sp.BottomSurface = Enum.SurfaceType.Smooth
			sp.Color = Charte.dore
			sp.Neutral = true
			sp.Duration = 0
			sp.AllowTeamChangeOnTouch = false
			sp.Enabled = true
			sp.Parent = m
			local ok = pcall(function()
				Outils.texte(sp, "Top", "DINO CHAPARDEURS", { couleur = Charte.encre, pixelsParStud = 30 })
			end)
			if not ok then
				sp:ClearAllChildren()
			end
		end
	end)

	-- ===== 3. fontaine et statue de dino =====
	etape("fontaine", function()
		local m = Outils.modele(dossier, "Fontaine")
		local fx, fz = CX, CZ - R.reculFontaine
		local rf = R.rayonFontaine
		local pierreClaire = Charte.lumiere(Charte.pierre)

		-- fond, eau et margelle en 16 segments
		disque(m, "Fond", fx, fz, rf, 0.3, Y_DALLE, Charte.pierre)
		local eau = disque(m, "Eau", fx, fz, rf - 0.4, 0.3, Y_DALLE + 0.6, Charte.gemme, {
			Transparency = 0.35,
			Reflectance = 0.15,
			CanCollide = false,
		})
		local segments = 16
		local longueur = 2 * rf * math.tan(math.pi / segments) + 0.35
		for k = 0, segments - 1 do
			local a = k * 2 * math.pi / segments
			local x = fx + rf * math.cos(a)
			local z = fz + rf * math.sin(a)
			local couleur = Charte.pierre
			if k % 2 == 0 then
				couleur = pierreClaire
			end
			bloc(m, {
				Name = "Margelle",
				Size = Vector3.new(0.9, 1.3, longueur),
				CFrame = CFrame.new(x, Y_DALLE + 0.65, z) * CFrame.Angles(0, -a, 0),
				Color = couleur,
			})
		end

		-- piédestal
		local hPied = 2.2
		local rPied = 1.8
		disque(m, "Piedestal", fx, fz, rPied, hPied, Y_DALLE, Charte.pierre)
		disque(m, "Chapiteau", fx, fz, rPied + 0.3, 0.3, Y_DALLE + hPied - 0.3, Charte.dore)
		local yStatue = Y_DALLE + hPied

		-- statue : repère tourné vers le sud (le dino regarde l'apparition), reculé d'un stud
		local S = R.echelleStatue
		local repere = CFrame.new(fx, yStatue, fz) * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, 1)
		local vert = Charte.jungle
		local ventre = Charte.lumiere(Charte.herbe)
		-- (x, y, avant) en unités de statue ; l'avant est -Z local
		local function morceau(nom, sx, sy, sz, x, y, f, couleur, rotX, forme)
			local props = {
				Name = nom,
				Size = Vector3.new(sx * S, sy * S, sz * S),
				CFrame = repere * CFrame.new(x * S, y * S, -f * S) * CFrame.Angles(math.rad(rotX or 0), 0, 0),
				Color = couleur,
				CanCollide = false,
			}
			if forme == "boule" then
				return boule(m, props)
			elseif forme == "coin" then
				return coin(m, props)
			end
			return bloc(m, props)
		end

		morceau("Corps", 3, 3, 4, 0, 2.9, 0, vert)
		morceau("Ventre", 2.2, 2.2, 0.3, 0, 2.6, 2.05, ventre)
		morceau("CuisseG", 1.3, 2.6, 2, -1.3, 1.9, -0.3, vert)
		morceau("CuisseD", 1.3, 2.6, 2, 1.3, 1.9, -0.3, vert)
		morceau("PiedG", 1.4, 0.6, 2.2, -1.3, 0.3, 0.2, Charte.ombre(vert))
		morceau("PiedD", 1.4, 0.6, 2.2, 1.3, 0.3, 0.2, Charte.ombre(vert))
		morceau("BrasG", 0.5, 0.5, 1.3, -1.3, 3.4, 2.2, vert, -20)
		morceau("BrasD", 0.5, 0.5, 1.3, 1.3, 3.4, 2.2, vert, -20)
		morceau("Cou", 1.8, 2, 1.8, 0, 4.6, 1.4, vert)
		morceau("Tete", 2.4, 2, 2.8, 0, 5.9, 2.4, vert)
		local machoire = morceau("Machoire", 2, 0.9, 1.8, 0, 5.8, 4.4, vert)
		morceau("MachoireBas", 1.8, 0.5, 1.6, 0, 4.9, 4.1, ventre, -15)
		morceau("DentG", 0.3, 0.4, 0.3, -0.6, 5.2, 5.0, Charte.creme)
		morceau("DentD", 0.3, 0.4, 0.3, 0.6, 5.2, 5.0, Charte.creme)
		morceau("OeilG", 0.7, 0.7, 0.7, -1.15, 6.3, 3.0, Charte.creme, 0, "boule")
		morceau("OeilD", 0.7, 0.7, 0.7, 1.15, 6.3, 3.0, Charte.creme, 0, "boule")
		morceau("PupilleG", 0.35, 0.35, 0.35, -1.4, 6.3, 3.1, Charte.encre, 0, "boule")
		morceau("PupilleD", 0.35, 0.35, 0.35, 1.4, 6.3, 3.1, Charte.encre, 0, "boule")
		morceau("Queue", 2.2, 2.2, 2.4, 0, 3, -3.1, vert)
		morceau("QueueBout", 1.4, 1.4, 2.2, 0, 3.3, -5.2, Charte.ombre(vert))
		morceau("Pic", 0.4, 1, 1.2, 0, 4.9, -1.5, Charte.dore, 0, "coin")
		morceau("Pic", 0.4, 1, 1.2, 0, 4.9, -0.2, Charte.dore, 0, "coin")
		morceau("Pic", 0.4, 0.8, 1, 0, 4.5, -3.1, Charte.dore, 0, "coin")
		morceau("Pic", 0.4, 0.8, 1, 0, 6.9, 1.9, Charte.dore, 0, "coin")

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
				jet.Color = ColorSequence.new(Charte.gemme, Charte.creme)
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

		-- éclaboussures là où le jet retombe
		if eau then
			pcall(function()
				local impact = Instance.new("Attachment")
				impact.Name = "Impact"
				impact.Parent = eau
				impact.WorldCFrame = CFrame.new(fx, Y_DALLE + 0.95, fz + 3.9 * S * 1.1)
				local gerbe = Instance.new("ParticleEmitter")
				gerbe.Name = "Gerbe"
				gerbe.EmissionDirection = Enum.NormalId.Top
				gerbe.Color = ColorSequence.new(Charte.creme)
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
				Outils.lumiere(eau, { Range = 10, Brightness = 0.6, Color = Charte.gemme })
			end)
		end
	end)

	-- ===== 4. borne Dinodex au bord sud =====
	etape("dinodex", function()
		local m = Outils.modele(dossier, "Dinodex")
		local bx, bz = CX, CZ + R.distanceBorne
		-- la borne regarde le nord (face avant -Z vers le centre de la Place)
		local function ici(x, y, z)
			return CFrame.new(bx + x, y, bz + z)
		end

		bloc(m, {
			Name = "Socle",
			Size = Vector3.new(5.4, 0.6, 3.4),
			CFrame = ici(0, Y_DALLE + 0.3, 0),
			Color = Charte.pierre,
		})
		local yBas = Y_DALLE + 0.6
		local borne = bloc(m, {
			Name = "Borne",
			Size = Vector3.new(4, 5.2, 2),
			CFrame = ici(0, yBas + 2.6, 0.3),
			Color = Charte.nuit,
		})
		local ecran = bloc(m, {
			Name = "Ecran",
			Size = Vector3.new(3.4, 2.6, 0.2),
			CFrame = ici(0, yBas + 3.5, -0.8),
			Color = Charte.encre,
		})
		bloc(m, { Name = "Cadre", Size = Vector3.new(3.8, 0.3, 0.3), CFrame = ici(0, yBas + 4.95, -0.8), Color = Charte.dore })
		bloc(m, { Name = "Cadre", Size = Vector3.new(3.8, 0.3, 0.3), CFrame = ici(0, yBas + 2.05, -0.8), Color = Charte.dore })
		local voyant = bloc(m, {
			Name = "Voyant",
			Size = Vector3.new(1.4, 0.8, 0.3),
			CFrame = ici(0, yBas + 1.1, -0.75),
			Color = Charte.gemme,
			Material = Enum.Material.Neon,
		})
		bloc(m, { Name = "Liseret", Size = Vector3.new(0.25, 5.2, 0.25), CFrame = ici(-2.05, yBas + 2.6, -0.65), Color = Charte.violet })
		bloc(m, { Name = "Liseret", Size = Vector3.new(0.25, 5.2, 0.25), CFrame = ici(2.05, yBas + 2.6, -0.65), Color = Charte.violet })
		bloc(m, {
			Name = "Toit",
			Size = Vector3.new(4.6, 0.5, 2.6),
			CFrame = ici(0, yBas + 5.45, 0.3),
			Color = Charte.violet,
		})
		disque(m, "Nid", bx, bz + 0.3, 0.9, 0.4, yBas + 5.7, Charte.bois)
		local oeuf = boule(m, {
			Name = "Oeuf",
			Size = Vector3.new(1.6, 1.6, 1.6),
			CFrame = ici(0, yBas + 6.95, 0.3),
			Color = Charte.dore,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		if oeuf then
			Outils.animer(oeuf, "flotte", 0.8)
			Outils.lumiere(oeuf, { Range = 12, Brightness = 1.2, Color = Charte.dore })
		end
		if voyant then
			Outils.animer(voyant, "pulse", 1.2)
		end
		if borne then
			m.PrimaryPart = borne
			-- aucun rappel : le client ouvre le panneau (Client.client.lua filtre « Index »)
			Outils.invite(borne, { nom = "Index", action = "Ouvrir", objet = "Dinodex", distance = R.distanceInvite })
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

				local titre = Instance.new("TextLabel")
				titre.Name = "Titre"
				titre.BackgroundTransparency = 1
				titre.Position = UDim2.fromScale(0.05, 0.06)
				titre.Size = UDim2.fromScale(0.9, 0.4)
				titre.Font = Charte.police
				titre.Text = "DINODEX"
				titre.TextScaled = true
				titre.TextColor3 = Charte.dore
				titre.Parent = fond

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
					case.Position = UDim2.fromScale(0.08 + (i - 1) * (0.84 / n), 0.5)
					case.Size = UDim2.fromScale(0.84 / n - 0.015, 0.1)
					case.Parent = fond
				end

				local nbEspeces = 0
				local especes = ctx.Equilibrage and ctx.Equilibrage.especes
				if type(especes) == "table" then
					for _ in pairs(especes) do
						nbEspeces = nbEspeces + 1
					end
				end
				local sous = Instance.new("TextLabel")
				sous.Name = "SousTitre"
				sous.BackgroundTransparency = 1
				sous.Position = UDim2.fromScale(0.05, 0.66)
				sous.Size = UDim2.fromScale(0.9, 0.26)
				sous.Font = Charte.policeTexte
				if nbEspeces > 0 then
					sous.Text = nbEspeces .. " espèces à découvrir"
				else
					sous.Text = "Toutes les espèces à découvrir"
				end
				sous.TextScaled = true
				sous.TextColor3 = Charte.creme
				sous.Parent = fond
			end)
			if not ok then
				warn("[Dino] Place / écran Dinodex : " .. tostring(err))
			end
		end
	end)

	-- ===== 5. bancs (tournés vers le centre ou vers la fontaine) =====
	etape("bancs", function()
		local m = Outils.modele(dossier, "Bancs")
		local fontaine = Vector3.new(CX, 0, CZ - R.reculFontaine)
		local function banc(pos, cible)
			local repere = CFrame.lookAt(Vector3.new(pos.X, Y_DALLE, pos.Z), Vector3.new(cible.X, Y_DALLE, cible.Z))
			bloc(m, { Name = "Assise", Size = Vector3.new(5, 0.4, 1.6), CFrame = repere * CFrame.new(0, 1.3, 0), Color = Charte.bois })
			bloc(m, { Name = "Dossier", Size = Vector3.new(5, 1.4, 0.3), CFrame = repere * CFrame.new(0, 2.2, 0.75), Color = Charte.bois })
			bloc(m, { Name = "Pied", Size = Vector3.new(0.5, 1.1, 1.4), CFrame = repere * CFrame.new(-2, 0.55, 0), Color = Charte.pierre })
			bloc(m, { Name = "Pied", Size = Vector3.new(0.5, 1.1, 1.4), CFrame = repere * CFrame.new(2, 0.55, 0), Color = Charte.pierre })
		end
		banc(autour(R.rayonBancs, 45), CENTRE)
		banc(autour(R.rayonBancs, 135), CENTRE)
		-- de part et d'autre de la fontaine, face à elle
		banc(Vector3.new(CX - 8.5, 0, fontaine.Z), fontaine)
		banc(Vector3.new(CX + 8.5, 0, fontaine.Z), fontaine)
	end)

	-- ===== 6. bacs à fleurs =====
	etape("fleurs", function()
		local m = Outils.modele(dossier, "Fleurs")
		local couleursFleurs = { Charte.alerte, Charte.dore, Charte.violet, Charte.gemme, Charte.lave }
		local hasard = Outils.aleatoire(2026)
		local function bac(angle)
			local p = autour(R.rayonFleurs, angle)
			local repere = CFrame.new(p.X, Y_DALLE, p.Z) * CFrame.Angles(0, -math.rad(angle), 0)
			bloc(m, { Name = "Bac", Size = Vector3.new(2.4, 1, 2.4), CFrame = repere * CFrame.new(0, 0.5, 0), Color = Charte.bois })
			bloc(m, { Name = "Terreau", Size = Vector3.new(2, 0.1, 2), CFrame = repere * CFrame.new(0, 1.02, 0), Color = Charte.terre })
			local places = { { -0.55, -0.5 }, { 0.55, -0.4 }, { 0, 0.55 } }
			for _, d in ipairs(places) do
				local haut = 0.8 + hasard:NextNumber() * 0.5
				bloc(m, {
					Name = "Tige",
					Size = Vector3.new(0.2, haut, 0.2),
					CFrame = repere * CFrame.new(d[1], 1.05 + haut / 2, d[2]),
					Color = Charte.jungle,
					CanCollide = false,
				})
				boule(m, {
					Name = "Fleur",
					Size = Vector3.new(0.6, 0.6, 0.6),
					CFrame = repere * CFrame.new(d[1], 1.05 + haut + 0.2, d[2]),
					Color = couleursFleurs[hasard:NextInteger(1, #couleursFleurs)],
					CanCollide = false,
				})
			end
		end
		local angles = { 25, 65, 115, 155, 340 }
		for _, a in ipairs(angles) do
			bac(a)
		end
	end)

	dossier:SetAttribute("Parts", nbParts)
end

return M
