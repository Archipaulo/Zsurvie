-- Interface/AmbianceDecor : petite vie d'ambiance autour du joueur (rayon ~80 studs), purement locale.
--   * papillons colorés qui voltigent de fleur en fleur et à l'orée de la jungle (le jour) ;
--   * feuilles qui se détachent des arbres, tombent en se balançant, se posent puis s'effacent ;
--   * lucioles clignotantes près des fleurs et de la jungle la nuit (Lighting.ClockTime) ;
--   * petites étincelles dorées qui montent le long des rebords du Tapis ;
--   * reflets scintillants et bulles qui éclatent à la surface de la rivière.
-- Tout vit dans un Folder de workspace.CurrentCamera ; parts ancrées, sans collision ni ombre ni requête.
-- Budget : jamais plus de 80 objets à la fois (parts + lumières), une seule boucle Heartbeat.
-- Positions lues dans ctx.Plan et dans le décor construit (fleurs, canopées), rien en dur.
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local M = {}

local RAYON = 80 -- les effets naissent à moins de 80 studs du joueur
local RAYON_OUBLI = 110 -- et disparaissent s'il s'en éloigne au-delà
local BUDGET = 80 -- objets simultanés au maximum (parts + lumières)
local LUMIERES_MAX = 4 -- lucioles qui éclairent vraiment
local QUOTAS = { papillon = 8, feuille = 12, luciole = 16, etincelle = 14, riviere = 12 }
local CADENCES = { papillon = 1.3, feuille = 0.9, luciole = 0.45, etincelle = 0.3, riviere = 0.45 } -- secondes entre deux naissances
local RAFRAICHIR = 1.5 -- secondes entre deux tris des points proches
local V3 = Vector3.new

local function hasard(a, b)
	return a + math.random() * (b - a)
end

local function borne(v, a, b)
	if v < a then return a end
	if v > b then return b end
	return v
end

local function choisir(liste)
	if #liste == 0 then return nil end
	return liste[math.random(1, #liste)]
end

local function distanceXZ(a, b)
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

-- fondu d'entrée et de sortie : 0 = invisible, 1 = plein
local function fondu(age, vie, entree, sortie)
	local a = 1
	if age < entree then a = age / entree end
	if age > vie - sortie then a = math.min(a, (vie - age) / sortie) end
	return borne(a, 0, 1)
end

function M.demarrer(ctx)
	local Plan = ctx.Plan or {}
	local Charte = ctx.Charte
	local joueur = ctx.joueur
	local racine = ctx.racine

	-- ===== couleurs (toutes issues de la Charte) =====
	local CREME = Charte.creme
	local DORE = Charte.dore
	local PAPILLONS = {
		Charte.dore, Charte.violet, Charte.gemme, Charte.alerte, Charte.lave,
		Charte.creme, Charte.lumiere(Charte.violet), Charte.dore:Lerp(Charte.lave, 0.4),
	}
	local FEUILLES = {
		Charte.jungle, Charte.herbe, Charte.lumiere(Charte.herbe), Charte.ombre(Charte.jungle),
		Charte.herbe:Lerp(Charte.dore, 0.45), Charte.terre:Lerp(Charte.dore, 0.35),
	}
	local LUCIOLE = Charte.dore:Lerp(Charte.herbe, 0.3)
	local ETINCELLES = { Charte.dore, Charte.dore:Lerp(Charte.creme, 0.45), Charte.dore:Lerp(Charte.lave, 0.25) }
	local REFLET = Charte.creme:Lerp(Charte.gemme, 0.25)
	local BULLE = Charte.creme:Lerp(Charte.gemme, 0.5)

	-- ===== dossier local (dans la caméra) et comptage des objets =====
	local dossierEffets = nil
	local nbObjets = 0
	local nbLumieres = 0
	local actifs = {}
	local compte = { papillon = 0, feuille = 0, luciole = 0, etincelle = 0, riviere = 0 }

	local function oublierTout()
		actifs = {}
		nbObjets = 0
		nbLumieres = 0
		for genre in pairs(compte) do compte[genre] = 0 end
	end

	local function dossier()
		local camera = workspace.CurrentCamera
		if dossierEffets and dossierEffets.Parent == nil then
			-- la caméra a été détruite avec nos effets : on repart de zéro
			dossierEffets = nil
			oublierTout()
		end
		if not dossierEffets then
			dossierEffets = Instance.new("Folder")
			dossierEffets.Name = "AmbianceDecor"
			dossierEffets.Parent = camera or workspace
		elseif camera and dossierEffets.Parent ~= camera then
			dossierEffets.Parent = camera
		end
		return dossierEffets
	end

	local function nouvellePart(taille, couleur, matiere, forme)
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Material = matiere or Enum.Material.SmoothPlastic
		if forme then p.Shape = forme end
		p.Size = taille
		p.Color = couleur
		p.Transparency = 1
		p.CFrame = CFrame.new(0, -500, 0)
		p.Parent = dossier()
		nbObjets = nbObjets + 1
		return p
	end

	local function place(nb)
		return nbObjets + nb <= BUDGET
	end

	local function finir(e)
		if e.lumiere then
			nbLumieres = nbLumieres - 1
			nbObjets = nbObjets - 1
			pcall(function() e.lumiere:Destroy() end)
			e.lumiere = nil
		end
		for _, p in ipairs(e.parts) do
			nbObjets = nbObjets - 1
			pcall(function() p:Destroy() end)
		end
		e.parts = {}
		compte[e.genre] = math.max(0, compte[e.genre] - 1)
	end

	local function ajouter(e)
		table.insert(actifs, e)
		compte[e.genre] = compte[e.genre] + 1
	end

	-- ===== où est le joueur, fait-il nuit ? =====
	local function positionJoueur()
		local perso = joueur and joueur.Character
		if perso then
			local rp = perso:FindFirstChild("HumanoidRootPart")
			if rp and rp:IsA("BasePart") then return rp.Position end
		end
		return nil
	end

	-- 0 en plein jour, 1 en pleine nuit, fondu entre 17,5 h et 18,5 h (et 5,5 h - 6,5 h)
	local function facteurNuit()
		local ok, h = pcall(function() return Lighting.ClockTime end)
		if not ok or type(h) ~= "number" then return 0 end
		if h >= 18.5 or h <= 5.5 then return 1 end
		if h > 17.5 then return h - 17.5 end
		if h < 6.5 then return 6.5 - h end
		return 0
	end

	-- ===== points d'intérêt : bords de jungle et Place (Plan), fleurs et canopées (décor construit) =====
	local fleurs = {} -- points au sol (fleurs, orée de la jungle, massifs de la Place)
	local cimes = {} -- centres de feuillage (d'où tombent les feuilles)

	local function pres(p, centre, r)
		return centre and distanceXZ(p, centre) < r
	end
	local volcan = Plan.volcan or {}
	local cratere = Plan.cratere or {}
	local function horsZonesInterdites(p)
		if pres(p, volcan.centre, (volcan.rayon or 36) + 8) then return false end
		if pres(p, cratere.centre, (cratere.rayon or 16) + 8) then return false end
		return true
	end

	do
		local D = Plan.decor or {}
		local function bord(x, z)
			local p = V3(x, 0, z)
			if horsZonesInterdites(p) then
				table.insert(fleurs, p)
				table.insert(cimes, V3(x, 15, z))
			end
		end
		local j = D.jungleOuest
		if j then
			for z = j.min.Z + 6, j.max.Z - 6, 14 do bord(j.max.X - 3, z) end
		end
		j = D.jungleEst
		if j then
			for z = j.min.Z + 6, j.max.Z - 6, 14 do bord(j.min.X + 3, z) end
		end
		j = D.jungleNord
		if j then
			for x = j.min.X + 6, j.max.X - 6, 14 do bord(x, j.max.Z - 3) end
		end
		local P = Plan.place
		if P and P.centre then
			for k = 1, 14 do
				local a = k / 14 * math.pi * 2
				local r = (P.rayon or 22) + 5
				table.insert(fleurs, P.centre + V3(math.cos(a) * r, 0, math.sin(a) * r))
			end
		end
	end

	local function estFleur(nom)
		return nom == "Fleur" or string.sub(nom, 1, 6) == "Petale"
	end
	local function estCime(nom)
		return nom == "Canopee" or nom == "Noix" or string.sub(nom, 1, 9) == "Feuillage"
	end

	-- lecture du décor, une fois construit (sans jamais bloquer : on rend la main régulièrement)
	task.spawn(function()
		task.wait(3)
		if not racine then return end
		local lus = 0
		for _, zone in ipairs(racine:GetChildren()) do
			if zone.Name ~= "Dinos" and zone.Name ~= "Bases" and zone.Name ~= "Tapis" then
				local ok, liste = pcall(function() return zone:GetDescendants() end)
				if ok and liste then
					for _, d in ipairs(liste) do
						lus = lus + 1
						if lus % 2500 == 0 then task.wait() end
						if d:IsA("BasePart") then
							local nom = d.Name
							if estFleur(nom) then
								if #fleurs < 1500 then table.insert(fleurs, V3(d.Position.X, 0, d.Position.Z)) end
							elseif estCime(nom) and d.Position.Y > 6 then
								if #cimes < 800 then table.insert(cimes, d.Position) end
							end
						end
					end
				end
			end
		end
	end)

	-- listes des points proches du joueur (rafraîchies toutes les 1,5 s)
	local fleursProches, cimesProches = {}, {}
	local function trierProches(pos)
		fleursProches, cimesProches = {}, {}
		for _, p in ipairs(fleurs) do
			if distanceXZ(p, pos) < RAYON then table.insert(fleursProches, p) end
		end
		for _, p in ipairs(cimes) do
			if distanceXZ(p, pos) < RAYON then table.insert(cimesProches, p) end
		end
	end

	-- vent doux qui tourne lentement (feuilles, papillons)
	local horloge = 0
	local function vent()
		local a = horloge * 0.04
		return V3(math.cos(a), 0, math.sin(a)) * (0.7 + 0.4 * math.sin(horloge * 0.23))
	end

	-- ===== papillons =====
	local function naitrePapillon()
		local ancre = choisir(fleursProches)
		if not ancre or not place(2) then return end
		local couleur = choisir(PAPILLONS)
		local e = {
			genre = "papillon",
			parts = {
				nouvellePart(V3(0.8, 0.06, 0.95), couleur),
				nouvellePart(V3(0.8, 0.06, 0.95), Charte.lumiere(couleur)),
			},
			age = 0,
			vie = hasard(14, 26),
			ancre = ancre,
			cible = ancre,
			prochainSaut = hasard(5, 9),
			phase = hasard(0, 6.28),
			rx = hasard(1.8, 4),
			rz = hasard(1.8, 4),
			fa = hasard(0.5, 0.9),
			fb = hasard(0.45, 0.8),
			battement = hasard(13, 19),
			haut = hasard(1.2, 2.6),
			dir = V3(0, 0, -1),
		}
		e.pos = ancre + V3(0, e.haut, 0)
		function e.maj(self, dt)
			self.age = self.age + dt
			local t = self.age
			-- de temps en temps, il file vers une autre fleur toute proche
			self.prochainSaut = self.prochainSaut - dt
			if self.prochainSaut <= 0 then
				self.prochainSaut = hasard(6, 11)
				for _ = 1, 6 do
					local f = choisir(fleursProches)
					if f and distanceXZ(f, self.ancre) < 22 then
						self.cible = f
						break
					end
				end
			end
			local ecart = self.cible - self.ancre
			local d = ecart.Magnitude
			if d > 0.05 then
				self.ancre = self.ancre + ecart * (math.min(d, 3.5 * dt) / d)
			end
			local but = self.ancre + V3(
				math.sin(t * self.fa + self.phase) * self.rx,
				self.haut + math.sin(t * self.fb * 1.7) * 0.7 + math.abs(math.sin(t * 2.9)) * 0.35,
				math.cos(t * self.fb + self.phase * 1.3) * self.rz
			) + vent() * 0.4
			if t > self.vie - 3 then
				-- fin de vie : il s'envole vers le haut
				but = but + V3(0, (t - (self.vie - 3)) * 5, 0)
			end
			local ancienne = self.pos
			self.pos = ancienne:Lerp(but, math.min(1, dt * 3))
			local dep = self.pos - ancienne
			local plat = V3(dep.X, 0, dep.Z)
			if plat.Magnitude > 0.002 then
				self.dir = self.dir:Lerp(plat.Unit, math.min(1, dt * 6))
			end
			if self.dir.Magnitude < 0.01 then self.dir = V3(0, 0, -1) end
			local base = CFrame.lookAt(self.pos, self.pos + self.dir)
			local angle = math.rad(12 + 62 * (0.5 + 0.5 * math.sin(t * self.battement)))
			local tr = 1 - fondu(t, self.vie, 0.8, 1.2)
			local aileG, aileD = self.parts[1], self.parts[2]
			aileG.CFrame = base * CFrame.Angles(0, 0, -angle) * CFrame.new(-0.42, 0, 0)
			aileD.CFrame = base * CFrame.Angles(0, 0, angle) * CFrame.new(0.42, 0, 0)
			aileG.Transparency = tr
			aileD.Transparency = tr
			return t < self.vie
		end
		ajouter(e)
	end

	-- ===== feuilles qui tombent =====
	local function naitreFeuille()
		local cime = choisir(cimesProches)
		if not cime or not place(1) then return end
		local depart = cime + V3(hasard(-4, 4), -hasard(2, 4.5), hasard(-4, 4))
		if depart.Y < 4 then depart = V3(depart.X, 4, depart.Z) end
		local e = {
			genre = "feuille",
			parts = { nouvellePart(V3(0.85, 0.06, 0.55), choisir(FEUILLES)) },
			age = 0,
			vie = 40,
			x = depart.X,
			y = depart.Y,
			z = depart.Z,
			chute = hasard(1.4, 2.4),
			amp = hasard(0.9, 1.8),
			freq = hasard(1.3, 2),
			phase = hasard(0, 6.28),
			lacet = hasard(0, 6.28),
			tourne = hasard(-1.2, 1.2),
			pose = nil,
		}
		e.pos = depart
		function e.maj(self, dt)
			self.age = self.age + dt
			local feuille = self.parts[1]
			if self.pose then
				-- posée au sol : elle s'efface doucement
				self.pose = self.pose + dt
				feuille.Transparency = borne(self.pose / 2.5, 0, 1)
				return self.pose < 2.5
			end
			local w = vent()
			self.y = self.y - self.chute * dt
			self.x = self.x + w.X * 0.8 * dt
			self.z = self.z + w.Z * 0.8 * dt
			self.lacet = self.lacet + self.tourne * dt
			local s = math.sin(self.age * self.freq + self.phase)
			local cf = CFrame.new(self.x, self.y, self.z) * CFrame.Angles(0, self.lacet, 0) * CFrame.new(s * self.amp, 0, 0) * CFrame.Angles(0, 0, s * 0.6)
			if self.y <= 0.08 then
				self.pose = 0
				cf = CFrame.new(cf.Position.X, 0.06, cf.Position.Z) * CFrame.Angles(0, self.lacet, 0)
			end
			feuille.CFrame = cf
			self.pos = cf.Position
			feuille.Transparency = 1 - fondu(self.age, self.vie, 0.5, 0.01)
			return self.age < self.vie
		end
		ajouter(e)
	end

	-- ===== lucioles (la nuit) =====
	local function naitreLuciole()
		local ancre = choisir(fleursProches)
		if not ancre or not place(1) then return end
		ancre = ancre + V3(hasard(-5, 5), 0, hasard(-5, 5))
		local p = nouvellePart(V3(0.32, 0.32, 0.32), LUCIOLE, Enum.Material.Neon, Enum.PartType.Ball)
		local e = {
			genre = "luciole",
			parts = { p },
			age = 0,
			vie = hasard(10, 20),
			ancre = ancre,
			phase = hasard(0, 6.28),
			fa = hasard(0.3, 0.6),
			fb = hasard(0.5, 0.9),
			fc = hasard(0.3, 0.6),
			clignote = hasard(1.4, 2.6),
			haut = hasard(1, 3.2),
		}
		e.pos = ancre
		if nbLumieres < LUMIERES_MAX and place(1) then
			local l = Instance.new("PointLight")
			l.Range = 7
			l.Brightness = 0
			l.Color = LUCIOLE
			l.Shadows = false
			l.Parent = p
			e.lumiere = l
			nbLumieres = nbLumieres + 1
			nbObjets = nbObjets + 1
		end
		function e.maj(self, dt)
			self.age = self.age + dt
			local t = self.age
			local pos = self.ancre + V3(
				math.sin(t * self.fa + self.phase) * 3,
				self.haut + math.sin(t * self.fb) * 1.1,
				math.cos(t * self.fc + self.phase * 0.7) * 3
			)
			self.pos = pos
			local lueur = borne(math.sin(t * self.clignote + self.phase) * 1.6, 0, 1)
			lueur = (0.15 + 0.85 * lueur) * fondu(t, self.vie, 1, 1.5) * borne(facteurNuit() * 1.5, 0, 1)
			local boule = self.parts[1]
			boule.CFrame = CFrame.new(pos)
			boule.Transparency = 1 - lueur
			if self.lumiere then self.lumiere.Brightness = 1.6 * lueur end
			return t < self.vie
		end
		ajouter(e)
	end

	-- ===== étincelles dorées le long du Tapis =====
	local T = Plan.tapis
	local function naitreEtincelle(pos)
		if not T or not T.debut or not T.fin or not place(1) then return end
		local xMin = math.min(T.debut.X, T.fin.X)
		local xMax = math.max(T.debut.X, T.fin.X)
		local x = borne(pos.X + hasard(-55, 55), xMin + 2, xMax - 2)
		local cote = 1
		if math.random() < 0.5 then cote = -1 end
		local z = T.debut.Z + cote * ((T.largeur or 14) / 2 + hasard(0.2, 1.8))
		local y0 = (T.hauteur or 0.8) + hasard(0.4, 1.2)
		local taille = hasard(0.16, 0.3)
		local e = {
			genre = "etincelle",
			parts = { nouvellePart(V3(taille, taille, taille), choisir(ETINCELLES), Enum.Material.Neon) },
			age = 0,
			vie = hasard(1.4, 2.6),
			x = x,
			z = z,
			y0 = y0,
			monte = hasard(2.2, 3.8),
			phase = hasard(0, 6.28),
			tourne = hasard(2, 5),
		}
		e.pos = V3(x, y0, z)
		function e.maj(self, dt)
			self.age = self.age + dt
			local t = self.age
			local pos = V3(
				self.x + math.sin(t * 3 + self.phase) * 0.35,
				self.y0 + self.monte * t - 0.25 * t * t,
				self.z + math.cos(t * 2.4 + self.phase) * 0.25
			)
			self.pos = pos
			local p = self.parts[1]
			p.CFrame = CFrame.new(pos) * CFrame.Angles(t * self.tourne, t * self.tourne * 0.7, 0)
			-- scintillement : petite pulsation pendant l'ascension
			local eclat = 0.75 + 0.25 * math.sin(t * 18 + self.phase)
			p.Transparency = 1 - fondu(t, self.vie, 0.2, 0.9) * eclat
			return t < self.vie
		end
		ajouter(e)
	end

	-- ===== reflets et bulles sur la rivière =====
	local R = Plan.riviere
	local Y_EAU = -0.8 -- surface de l'eau (Builders/Riviere)
	local zCentreRiv, largeurRiv, xFinRiv = 0, 14, 0
	if R then
		zCentreRiv = R.z or ((R.zMin + R.zMax) / 2)
		if R.zMin and R.zMax then
			zCentreRiv = (R.zMin + R.zMax) / 2
			largeurRiv = R.zMax - R.zMin
		end
		xFinRiv = R.xMax or 198
	end
	-- axe du lit sinueux (même tracé que Builders/Riviere)
	local function axeRiviere(x)
		local K = largeurRiv / 14
		local z = zCentreRiv + 3.5 * K * math.sin(x / 37) + 1.5 * K * math.sin(x / 13)
		local w = borne((x - (xFinRiv - 4 - 36)) / 24, 0, 1)
		z = z + (zCentreRiv - z) * w
		return borne(z, (R.zMin or zCentreRiv - 7) + 2, (R.zMax or zCentreRiv + 7) - 2)
	end
	-- vérifie (si possible) qu'il y a bien de l'eau à cet endroit : ni berge, ni pont
	local function surEau(x, z)
		local ok, res = pcall(function()
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local ignorer = { dossier() }
			if joueur and joueur.Character then table.insert(ignorer, joueur.Character) end
			params.FilterDescendantsInstances = ignorer
			params.IgnoreWater = false
			return workspace:Raycast(V3(x, 6, z), V3(0, -10, 0), params)
		end)
		if not ok or not res then return true end
		return res.Material == Enum.Material.Water
	end

	local function naitreRiviere(pos)
		if not R or not place(1) then return end
		local x = borne(pos.X + hasard(-50, 50), (R.xMin or -198) + 4, xFinRiv - 6)
		local z = axeRiviere(x) + hasard(-2, 2)
		if distanceXZ(V3(x, 0, z), pos) > RAYON or not surEau(x, z) then return end
		local e
		if math.random() < 0.65 then
			-- reflet : éclat de lumière couché sur l'eau, qui scintille et dérive avec le courant (vers l'ouest)
			local long = hasard(0.8, 2.2)
			e = {
				genre = "riviere",
				parts = { nouvellePart(V3(long, 0.05, hasard(0.18, 0.4)), REFLET, Enum.Material.Neon) },
				age = 0,
				vie = hasard(1.6, 3.2),
				x = x,
				z = z,
				courant = hasard(1, 2),
				angle = hasard(-0.25, 0.25),
				phase = hasard(0, 6.28),
			}
			function e.maj(self, dt)
				self.age = self.age + dt
				self.x = self.x - self.courant * dt
				local t = self.age
				local p = self.parts[1]
				local etire = 1 + 0.25 * math.sin(t * 5 + self.phase)
				p.Size = V3(long * etire, 0.05, p.Size.Z)
				p.CFrame = CFrame.new(self.x, Y_EAU + 0.06, self.z) * CFrame.Angles(0, self.angle, 0)
				local a = math.sin(math.pi * borne(t / self.vie, 0, 1))
				p.Transparency = 1 - 0.7 * a * (0.7 + 0.3 * math.sin(t * 11 + self.phase))
				self.pos = p.Position
				return t < self.vie
			end
		else
			-- bulle : monte du fond, affleure, gonfle et éclate
			local d = hasard(0.22, 0.42)
			e = {
				genre = "riviere",
				parts = { nouvellePart(V3(d, d, d), BULLE, Enum.Material.Glass, Enum.PartType.Ball) },
				age = 0,
				vie = hasard(1.2, 2),
				x = x,
				z = z,
				d = d,
				phase = hasard(0, 6.28),
			}
			function e.maj(self, dt)
				self.age = self.age + dt
				local t = self.age
				local montee = self.vie - 0.3
				local p = self.parts[1]
				self.x = self.x - 0.8 * dt
				if t < montee then
					local y = Y_EAU - 1.2 + 1.2 * (t / montee)
					p.CFrame = CFrame.new(self.x + math.sin(t * 6 + self.phase) * 0.08, y, self.z)
					p.Transparency = 0.35 + 0.3 * (1 - t / montee)
				else
					-- éclatement : elle gonfle et disparaît
					local k = borne((t - montee) / 0.3, 0, 1)
					local s = self.d * (1 + 0.9 * k)
					p.Size = V3(s, s, s)
					p.CFrame = CFrame.new(self.x, Y_EAU + 0.05, self.z)
					p.Transparency = 0.35 + 0.65 * k
				end
				self.pos = p.Position
				return t < self.vie
			end
		end
		ajouter(e)
	end

	-- ===== la boucle unique =====
	local minuteries = { papillon = 0, feuille = 0, luciole = 0, etincelle = 0, riviere = 0 }
	local prochainTri = 0
	local erreurSignalee = false

	local function pret(genre, dt)
		minuteries[genre] = minuteries[genre] - dt
		if minuteries[genre] > 0 then return false end
		minuteries[genre] = CADENCES[genre] * hasard(0.7, 1.3)
		return true
	end

	RunService.Heartbeat:Connect(function(dt)
		dt = math.min(dt or 0, 0.1)
		horloge = horloge + dt
		dossier()
		local pos = positionJoueur()

		-- mise à jour des effets vivants (retrait par échange avec le dernier)
		local i = 1
		while i <= #actifs do
			local e = actifs[i]
			local ok, vivant = pcall(e.maj, e, dt)
			if not ok and not erreurSignalee then
				erreurSignalee = true
				warn("[Dino] AmbianceDecor (" .. tostring(e.genre) .. ") : " .. tostring(vivant))
			end
			if ok and vivant and pos and e.pos and distanceXZ(e.pos, pos) > RAYON_OUBLI then
				vivant = false
			end
			if ok and vivant then
				i = i + 1
			else
				finir(e)
				actifs[i] = actifs[#actifs]
				actifs[#actifs] = nil
			end
		end

		if not pos then return end
		prochainTri = prochainTri - dt
		if prochainTri <= 0 then
			prochainTri = RAFRAICHIR
			trierProches(pos)
		end

		local nuit = facteurNuit()
		-- papillons le jour, lucioles la nuit (fondu au crépuscule)
		local voulusPapillons = math.floor(QUOTAS.papillon * (1 - nuit) + 0.5)
		if compte.papillon < voulusPapillons and pret("papillon", dt) then naitrePapillon() end
		local voulusLucioles = math.floor(QUOTAS.luciole * nuit + 0.5)
		if compte.luciole < voulusLucioles and pret("luciole", dt) then naitreLuciole() end
		if compte.feuille < QUOTAS.feuille and #cimesProches > 0 and pret("feuille", dt) then naitreFeuille() end
		if T and T.debut and math.abs(pos.Z - T.debut.Z) < RAYON and compte.etincelle < QUOTAS.etincelle and pret("etincelle", dt) then
			if pos.X > math.min(T.debut.X, T.fin.X) - RAYON and pos.X < math.max(T.debut.X, T.fin.X) + RAYON then
				naitreEtincelle(pos)
			end
		end
		if R and math.abs(pos.Z - zCentreRiv) < RAYON and compte.riviere < QUOTAS.riviere and pret("riviere", dt) then
			naitreRiviere(pos)
		end
	end)
end

return M
