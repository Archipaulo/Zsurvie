-- Builders/IleLabo.lua : l'île flottante du lobby, centrée sur Plan.lobby.origine.
-- Sol d'herbe bleutée (r70), bordure rocheuse irrégulière (jusqu'à r78),
-- dessous flottant en pyramide inversée avec cristaux, allées de dalles depuis
-- la place du spawn, cristaux et buissons sur les bords (anneau 60..70).
local M = {}

local BUDGET = 500

-- géométrie de l'île (studs, relative à l'origine de l'île)
local RAYON_SOL = 70
local RAYON_BORDURE = 78
local RAYON_PLACE = 10
local GARDE_ZONES = 14
local PAS_DALLE = 4.2

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local lobby = Plan.lobby
	if not lobby or not lobby.origine then
		return
	end
	local O = lobby.origine
	local rng = Outils.aleatoire(600)
	local nbParts = 0

	-- toute part passe par ici : le budget de l'île est respecté
	local function poser(genre, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return Outils[genre](parent, props)
	end

	local function hasard(a, b)
		return rng:NextNumber(a, b)
	end

	-- disque horizontal (cylindre couché) de centre (x, y, z)
	local function disque(parent, nom, x, y, z, rayon, epaisseur, couleur, props)
		local p = {
			Name = nom,
			Size = Vector3.new(epaisseur, rayon * 2, rayon * 2),
			CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
		}
		if props then
			for cle, valeur in pairs(props) do
				p[cle] = valeur
			end
		end
		return poser("cylindre", parent, p)
	end

	-- couleurs, toutes dérivées de la Charte
	local herbe = Charte.prairie:Lerp(Charte.nuitLabo, 0.35)
	local herbeOmbre = Charte.ombre(herbe)
	local herbeClaire = Charte.lumiere(herbe)
	local roche = Charte.ardoise
	local rocheOmbre = Charte.ombre(Charte.ardoise)
	local rocheNuit = Charte.ardoise:Lerp(Charte.nuitLabo, 0.45)
	local rocheClaire = Charte.lumiere(Charte.ardoise)
	local couleursRoche = { roche, rocheOmbre, rocheNuit, rocheClaire }

	local dossierSol = Outils.dossier(ctx.dossier, "Sol")
	local dossierBordure = Outils.dossier(ctx.dossier, "Bordure")
	local dossierDessous = Outils.dossier(ctx.dossier, "Dessous")
	local dossierAllees = Outils.dossier(ctx.dossier, "Allees")
	local dossierBords = Outils.dossier(ctx.dossier, "Bords")

	-- ===== 1. sol : disque r70, dessus à Y = 0 =====
	poser("cylindre", dossierSol, {
		Name = "Herbe",
		Size = Vector3.new(4, RAYON_SOL * 2, RAYON_SOL * 2),
		CFrame = CFrame.new(O.X, -2, O.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color = herbe,
	})

	-- ===== 2. bordure rocheuse irrégulière (r68..78) =====
	local nbRochers = 40
	for i = 1, nbRochers do
		local angle = (i - 1) / nbRochers * math.pi * 2 + hasard(-0.04, 0.04)
		local profondeur = hasard(7, 10)
		local r = RAYON_BORDURE - profondeur / 2 - hasard(0, 1)
		local haut = hasard(0.4, 2.6)
		local bas = -5.5
		local hauteur = haut - bas
		local largeur = 2 * math.pi * r / nbRochers * hasard(1.15, 1.4)
		local x = O.X + math.cos(angle) * r
		local z = O.Z + math.sin(angle) * r
		poser("bloc", dossierBordure, {
			Name = "Rocher",
			Size = Vector3.new(profondeur, hauteur, largeur),
			CFrame = CFrame.new(x, bas + hauteur / 2, z)
				* CFrame.Angles(0, -angle, 0)
				* CFrame.Angles(math.rad(hasard(-4, 4)), 0, math.rad(hasard(-4, 4))),
			Color = couleursRoche[rng:NextInteger(1, #couleursRoche)],
		})
	end

	-- ===== 3. dessous flottant : pyramide inversée de couronnes rocheuses =====
	local rayonsCouches = { 72, 60, 48, 36, 24, 12 }
	local hauteurCouche = 6
	local basCouches = {}
	for i, R in ipairs(rayonsCouches) do
		local haut = -4 - (i - 1) * hauteurCouche
		local bas = haut - hauteurCouche
		basCouches[i] = bas
		local teinte = rocheOmbre:Lerp(Charte.nuitLabo, (i - 1) * 0.08)
		-- cœur plein de la couche
		if R - 6 > 0 then
			disque(dossierDessous, "Coeur", O.X, haut - hauteurCouche / 2, O.Z, R - 6, hauteurCouche, teinte, { CanCollide = false })
		end
		-- couronne de rochers autour du cœur
		local n = math.max(5, math.floor(2 * math.pi * R / 13))
		local decalage = hasard(0, math.pi * 2)
		for k = 1, n do
			local angle = decalage + (k - 1) / n * math.pi * 2 + hasard(-0.05, 0.05)
			local r = R - 4 + hasard(-0.8, 0.8)
			local h = hasard(6, 8.5)
			local largeur = 2 * math.pi * r / n * hasard(1.2, 1.45)
			local couleur = couleursRoche[rng:NextInteger(1, #couleursRoche)]:Lerp(Charte.nuitLabo, 0.15 + (i - 1) * 0.06)
			poser("bloc", dossierDessous, {
				Name = "Roc",
				Size = Vector3.new(10, h, largeur),
				CFrame = CFrame.new(O.X + math.cos(angle) * r, haut + 0.5 - h / 2, O.Z + math.sin(angle) * r)
					* CFrame.Angles(0, -angle, 0)
					* CFrame.Angles(math.rad(hasard(-5, 5)), 0, math.rad(hasard(-5, 5))),
				Color = couleur,
				CanCollide = false,
			})
		end
	end

	-- pointe finale sous la dernière couche
	local yPointe = basCouches[#basCouches]
	local taillesPointe = { 9, 6, 3.5 }
	for k, t in ipairs(taillesPointe) do
		local h = t * 0.8
		poser("bloc", dossierDessous, {
			Name = "Pointe",
			Size = Vector3.new(t, h, t),
			CFrame = CFrame.new(O.X, yPointe - h / 2 + 0.4, O.Z) * CFrame.Angles(0, math.rad(k * 27), 0),
			Color = rocheNuit,
			CanCollide = false,
		})
		yPointe = yPointe - h + 0.4
	end
	local cristalPointe = poser("bloc", dossierDessous, {
		Name = "CristalPointe",
		Size = Vector3.new(1.8, 6, 1.8),
		CFrame = CFrame.new(O.X, yPointe - 2.6, O.Z) * CFrame.Angles(0, math.rad(45), 0),
		Color = Charte.gemme,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	if cristalPointe then
		Outils.lumiere(cristalPointe, { Range = 18, Brightness = 1.2, Color = Charte.gemme })
		Outils.animer(cristalPointe, "pulse", 0.6)
	end

	-- rochers pendants (petites pyramides inversées) sous chaque gradin
	for i = 1, #rayonsCouches - 1 do
		local R = rayonsCouches[i]
		local nbPendants = 3
		if i <= 2 then
			nbPendants = 4
		end
		local decalage = hasard(0, math.pi * 2)
		for k = 1, nbPendants do
			local angle = decalage + (k - 1) / nbPendants * math.pi * 2 + hasard(-0.3, 0.3)
			local r = R - 5 + hasard(-1, 1)
			local x = O.X + math.cos(angle) * r
			local z = O.Z + math.sin(angle) * r
			local y = basCouches[i] + 0.6
			local tailles = { hasard(4, 5.5), hasard(2.6, 3.4), hasard(1.2, 1.8) }
			for n, t in ipairs(tailles) do
				local h = t * 1.1
				poser("bloc", dossierDessous, {
					Name = "Pendant",
					Size = Vector3.new(t, h, t),
					CFrame = CFrame.new(x, y - h / 2, z) * CFrame.Angles(0, hasard(0, math.pi), 0),
					Color = couleursRoche[1 + (n % #couleursRoche)]:Lerp(Charte.nuitLabo, 0.3),
					CanCollide = false,
				})
				y = y - h + 0.4
			end
		end
	end

	-- cristaux de gemme qui pendent sous l'île
	local nbGrappes = 12
	for k = 1, nbGrappes do
		local i = 1 + (k % (#rayonsCouches - 1))
		local R = rayonsCouches[i]
		local angle = (k - 1) / nbGrappes * math.pi * 2 + hasard(0, 0.4)
		local r = R - 8 + hasard(-1.5, 1.5)
		local x = O.X + math.cos(angle) * r
		local z = O.Z + math.sin(angle) * r
		local yHaut = basCouches[i] + 0.5
		for n = 1, 2 do
			local l = hasard(3, 6) / n
			local cristal = poser("bloc", dossierDessous, {
				Name = "Cristal",
				Size = Vector3.new(1.1, l, 1.1),
				CFrame = CFrame.new(x + (n - 1) * 1.2, yHaut - l / 2, z + (n - 1) * 0.6)
					* CFrame.Angles(math.rad(hasard(-15, 15)), hasard(0, math.pi), math.rad(hasard(-15, 15))),
				Color = Charte.gemme,
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			if cristal and n == 1 and k % 3 == 0 then
				Outils.lumiere(cristal, { Range = 14, Brightness = 0.9, Color = Charte.gemme })
			end
		end
	end

	-- ===== 4. place du spawn et allées de dalles =====
	local spawn = lobby.spawn or (O + Vector3.new(0, 0, 48))
	disque(dossierAllees, "BordPlace", spawn.X, 0.08, spawn.Z, RAYON_PLACE + 0.8, 0.16, Charte.terre)
	disque(dossierAllees, "Place", spawn.X, 0.1, spawn.Z, RAYON_PLACE, 0.2, Charte.creme)

	-- emprises des autres zones (demi-dimensions prudentes)
	local zones = {}
	local function ajouterZone(nom, rayon, dx, dz)
		local pos = lobby[nom]
		if typeof(pos) == "Vector3" then
			table.insert(zones, { nom = nom, pos = pos, rayon = rayon, dx = dx, dz = dz })
		end
	end
	ajouterZone("laboratoire", 22, nil, nil)
	ajouterZone("quai", nil, 18, 6)
	ajouterZone("galerie", nil, 12, 12)
	ajouterZone("parcours", nil, 15, 15)
	ajouterZone("enigme", nil, 7, 7)
	ajouterZone("records", nil, 5, 5)
	ajouterZone("monument", nil, 15, 3)
	ajouterZone("scenePhoto", nil, 6, 6)

	local function zoneDe(p, marge)
		for _, zone in ipairs(zones) do
			if zone.rayon then
				if Outils.distanceXZ(p, zone.pos) < zone.rayon + marge then
					return zone
				end
			else
				if math.abs(p.X - zone.pos.X) < zone.dx + marge and math.abs(p.Z - zone.pos.Z) < zone.dz + marge then
					return zone
				end
			end
		end
		return nil
	end

	local dalles = {}
	local function presDalle(p, distance)
		for _, d in ipairs(dalles) do
			if Outils.distanceXZ(p, d) < distance then
				return true
			end
		end
		return false
	end

	local nbDalles = 0
	for _, cible in ipairs(zones) do
		local ecart = Vector3.new(cible.pos.X - spawn.X, 0, cible.pos.Z - spawn.Z)
		local longueur = ecart.Magnitude
		if longueur > 1 then
			local dir = ecart / longueur
			local t = RAYON_PLACE + 2.4
			local arrive = false
			while t < longueur and not arrive do
				local p = Vector3.new(spawn.X, 0, spawn.Z) + dir * t
				local zone = zoneDe(p, 2.5)
				if zone == cible then
					arrive = true
				elseif zone == nil and Outils.distanceXZ(p, O) < RAYON_SOL - 6 and not presDalle(p, 3.2) then
					nbDalles = nbDalles + 1
					local couleur = Charte.creme
					if nbDalles % 3 == 0 then
						couleur = Charte.terre
					end
					local dalle = poser("bloc", dossierAllees, {
						Name = "Dalle",
						Size = Vector3.new(3.6, 0.2, 3.2),
						CFrame = CFrame.lookAt(p + Vector3.new(0, 0.1, 0), p + Vector3.new(dir.X, 0.1, dir.Z))
							* CFrame.Angles(0, math.rad(hasard(-6, 6)), 0),
						Color = couleur,
					})
					if dalle then
						table.insert(dalles, p)
					end
				end
				t = t + PAS_DALLE
			end
		end
	end

	-- ===== 5. cristaux et buissons sur les bords (anneau 60..70) =====
	local points = {}
	for _, cle in ipairs({ "spawn", "laboratoire", "quai", "galerie", "parcours", "enigme", "records", "monument", "scenePhoto" }) do
		if typeof(lobby[cle]) == "Vector3" then
			table.insert(points, lobby[cle])
		end
	end

	local function loinDesZones(p)
		for _, pt in ipairs(points) do
			if Outils.distanceXZ(p, pt) < GARDE_ZONES then
				return false
			end
		end
		return true
	end

	local decors = {}
	local function loinDesDecors(p)
		for _, d in ipairs(decors) do
			if Outils.distanceXZ(p, d) < 5 then
				return false
			end
		end
		return true
	end

	local function cristaux(p, avecLumiere)
		local m = Outils.modele(dossierBords, "Cristaux")
		poser("bloc", m, {
			Name = "Socle",
			Size = Vector3.new(3, 1, 3),
			CFrame = CFrame.new(p.X, 0.3, p.Z) * CFrame.Angles(0, hasard(0, math.pi), 0),
			Color = rocheClaire,
		})
		for n = 1, 3 do
			local h = hasard(2.5, 5.5)
			local a = n / 3 * math.pi * 2
			local cristal = poser("bloc", m, {
				Name = "Cristal",
				Size = Vector3.new(0.9, h, 0.9),
				CFrame = CFrame.new(p.X + math.cos(a) * 0.6, h / 2 + 0.2, p.Z + math.sin(a) * 0.6)
					* CFrame.Angles(math.rad(hasard(-18, 18)), hasard(0, math.pi), math.rad(hasard(-18, 18))),
				Color = Charte.gemme,
				Material = Enum.Material.Neon,
			})
			if cristal and n == 1 and avecLumiere then
				Outils.lumiere(cristal, { Range = 10, Brightness = 0.8, Color = Charte.gemme })
			end
		end
	end

	local function buisson(p)
		local m = Outils.modele(dossierBords, "Buisson")
		local teintes = { herbeOmbre, herbe, herbeClaire }
		for n = 1, 3 do
			local t = hasard(2.2, 3.6) - (n - 1) * 0.3
			local a = hasard(0, math.pi * 2)
			local ecart = 0
			if n > 1 then
				ecart = 1.1
			end
			poser("boule", m, {
				Name = "Feuillage",
				Size = Vector3.new(t, t, t),
				CFrame = CFrame.new(p.X + math.cos(a) * ecart, t * 0.38, p.Z + math.sin(a) * ecart),
				Color = teintes[n],
			})
		end
	end

	local voulus = 22
	local essais = 0
	while #decors < voulus and essais < 400 and nbParts < BUDGET - 4 do
		essais = essais + 1
		local angle = hasard(0, math.pi * 2)
		-- on évite la ligne des mâts de fanions (r66) et les lampadaires (r58)
		local r = hasard(60.5, 64.5)
		if rng:NextNumber() < 0.4 then
			r = hasard(67.5, 69)
		end
		local p = Vector3.new(O.X + math.cos(angle) * r, 0, O.Z + math.sin(angle) * r)
		if loinDesZones(p) and loinDesDecors(p) and not presDalle(p, 4) and zoneDe(p, 3) == nil then
			table.insert(decors, p)
			if #decors % 2 == 0 then
				cristaux(p, #decors % 4 == 0)
			else
				buisson(p)
			end
		end
	end

	ctx.dossier:SetAttribute("Parts", nbParts)
end

return M
