-- Builders/Props : l'Établi (avec son invite, ouverte côté client) et les petits props
-- semés dans l'anneau 20..60 de la Prairie (caisses, tonneaux, clôtures, rochers,
-- lanternes, brouettes, meules de foin). Placement déterministe (graine fixe).
local M = {}

local GRAINE = 2323
local BUDGET = 500
local ANNEAU_MIN = 20
local ANNEAU_MAX = 60
local COULOIR = 5
local MARGE_EMPRISE = 3
local ESPACEMENT = 1.2
local ESSAIS = 40

function M.construire(ctx)
	if type(ctx) ~= "table" or not ctx.dossier then return end
	local C = ctx.Charte
	local O = ctx.Outils
	local P = ctx.Plan
	local HMAX = P.hauteurMaxPres or 6

	-- ===== comptage des parts =====
	local nbParts = 0
	local function bloc(parent, props)
		nbParts = nbParts + 1
		return O.bloc(parent, props)
	end
	local function coin(parent, props)
		nbParts = nbParts + 1
		return O.coin(parent, props)
	end
	local function cylindre(parent, props)
		nbParts = nbParts + 1
		return O.cylindre(parent, props)
	end
	local function boule(parent, props)
		nbParts = nbParts + 1
		return O.boule(parent, props)
	end
	-- cylindre debout : l'axe X de la part devient vertical
	local function debout(cf)
		return cf * CFrame.Angles(0, 0, math.rad(90))
	end

	local bois = C.terre
	local boisSombre = C.ombre(C.terre)
	local boisClair = C.lumiere(C.terre)
	local metal = C.ardoise
	local metalSombre = C.ombre(C.ardoise)
	local metalClair = C.lumiere(C.ardoise)
	local neon = Enum.Material.Neon

	-- ===================================================================
	-- 1. L'Établi
	-- ===================================================================
	local function construireEtabli()
		if not P.etabli then return end
		local centre = P.etabli.centre
		local cible = Vector3.new(0, centre.Y, 0)
		if P.maison and P.maison.centre then
			cible = Vector3.new(P.maison.centre.X, centre.Y, P.maison.centre.Z)
		end
		-- repère local : -Z regarde vers la Maison
		local base = CFrame.lookAt(centre, cible)
		local _, lacet = base:ToOrientation()
		local modele = O.modele(ctx.dossier, "Etabli")

		local function b(nom, taille, cfLocal, couleur, materiau)
			return bloc(modele, { Name = nom, Size = taille, CFrame = base * cfLocal, Color = couleur, Material = materiau })
		end
		local function incline(x, y, z, rx, ry, rz)
			return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
		end

		-- plancher de l'atelier (disque plat)
		local diametre = P.etabli.rayon * 2 - 0.4
		cylindre(modele, {
			Name = "Plancher",
			Size = Vector3.new(0.1, diametre, diametre),
			CFrame = debout(CFrame.new(centre.X, centre.Y + 0.05, centre.Z)),
			Color = boisClair,
		})

		-- l'établi de bois : plateau (part principale), pieds, étagère, dosseret
		local plateau = b("Plateau", Vector3.new(7, 0.5, 2.6), CFrame.new(0, 2.75, 0.6), bois)
		local piedsX = { -3.1, 3.1 }
		local piedsZ = { -0.4, 1.6 }
		for _, px in ipairs(piedsX) do
			for _, pz in ipairs(piedsZ) do
				b("Pied", Vector3.new(0.6, 2.5, 0.6), CFrame.new(px, 1.25, pz), boisSombre)
			end
		end
		b("Etagere", Vector3.new(6.2, 0.3, 2), CFrame.new(0, 0.8, 0.6), boisSombre)
		b("Dosseret", Vector3.new(7, 1.4, 0.3), CFrame.new(0, 3.7, 1.75), boisSombre)
		-- outils accrochés au dosseret
		b("Tournevis", Vector3.new(0.2, 0.9, 0.1), CFrame.new(-1.2, 3.8, 1.55), C.toit)
		b("Scie", Vector3.new(1.4, 0.6, 0.1), CFrame.new(0.3, 3.8, 1.55), metalClair)
		b("Lampe", Vector3.new(0.5, 0.5, 0.5), CFrame.new(1.8, 3.9, 1.5), C.dore, neon)
		-- petits objets sur le plateau
		b("Planchette", Vector3.new(1.8, 0.2, 0.8), incline(0.6, 3.1, 0.3, 0, 15, 0), boisClair)
		b("Boulon", Vector3.new(0.4, 0.4, 0.4), incline(1.8, 3.2, 0.1, 0, 30, 0), C.dore)

		-- étau à gauche du plateau
		b("EtauSocle", Vector3.new(1, 0.3, 0.8), CFrame.new(-2.7, 3.15, 0.2), metal)
		b("MachoireFixe", Vector3.new(0.3, 0.8, 0.8), CFrame.new(-2.35, 3.7, 0.2), metal)
		b("MachoireMobile", Vector3.new(0.3, 0.8, 0.8), CFrame.new(-3.05, 3.7, 0.2), metalClair)
		cylindre(modele, { Name = "Vis", Size = Vector3.new(1.3, 0.25, 0.25), CFrame = base * CFrame.new(-3.2, 3.55, 0.2), Color = metalSombre })
		b("Manivelle", Vector3.new(0.15, 0.9, 0.15), CFrame.new(-3.85, 3.55, 0.2), C.toit)

		-- enclume sur sa souche, devant à droite
		cylindre(modele, { Name = "Souche", Size = Vector3.new(1.6, 1.8, 1.8), CFrame = base * debout(CFrame.new(3.2, 0.8, -2.6)), Color = boisSombre })
		b("EnclumePied", Vector3.new(1.2, 0.5, 0.9), CFrame.new(3.2, 1.85, -2.6), metalSombre)
		b("EnclumeTaille", Vector3.new(0.7, 0.6, 0.6), CFrame.new(3.2, 2.4, -2.6), metalSombre)
		b("EnclumeTable", Vector3.new(1.8, 0.5, 0.9), CFrame.new(3.2, 2.95, -2.6), metal)
		coin(modele, {
			Name = "EnclumeBigorne",
			Size = Vector3.new(0.9, 0.5, 0.9),
			CFrame = base * CFrame.new(4.55, 2.95, -2.6) * CFrame.Angles(0, math.rad(-90), 0),
			Color = metal,
		})
		b("MarteauManche", Vector3.new(0.2, 0.2, 1.2), incline(3, 3.3, -2.5, 0, 20, 0), bois)
		b("MarteauTete", Vector3.new(0.6, 0.35, 0.35), incline(2.8, 3.35, -3.05, 0, 20, 0), metalSombre)

		-- caisse d'outils, devant à gauche
		b("CaisseOutils", Vector3.new(1.8, 1, 1), CFrame.new(-3.5, 0.5, -2.6), C.toit)
		b("Couvercle", Vector3.new(1.9, 0.2, 1.1), CFrame.new(-3.5, 1.1, -2.6), C.lumiere(C.toit))
		b("Poignee", Vector3.new(1, 0.2, 0.2), CFrame.new(-3.5, 1.65, -2.6), C.encre)
		b("PoigneeMontant", Vector3.new(0.2, 0.45, 0.2), CFrame.new(-3.9, 1.4, -2.6), C.encre)
		b("PoigneeMontant", Vector3.new(0.2, 0.45, 0.2), CFrame.new(-3.1, 1.4, -2.6), C.encre)
		b("Fermoir", Vector3.new(0.3, 0.3, 0.1), CFrame.new(-3.5, 0.85, -3.12), C.dore)

		-- clé géante appuyée contre l'établi
		local cle = CFrame.new(4.1, 0, 1.4) * CFrame.Angles(0, math.rad(-20), math.rad(10))
		b("CleManche", Vector3.new(0.5, 4.2, 0.3), cle * CFrame.new(0, 2.3, 0), metalClair)
		b("CleAnneau", Vector3.new(0.9, 0.5, 0.35), cle * CFrame.new(0, 0.3, 0), metalClair)
		b("CleTete", Vector3.new(1.6, 0.5, 0.35), cle * CFrame.new(0, 4.6, 0), metalClair)
		b("CleMachoire", Vector3.new(0.45, 0.8, 0.35), cle * CFrame.new(-0.575, 5.2, 0), metalClair)
		b("CleMachoire", Vector3.new(0.45, 0.8, 0.35), cle * CFrame.new(0.575, 5.2, 0), metalClair)

		-- panneau « Établi » derrière, tourné vers la Maison
		local posPanneau = (base * CFrame.new(0, 0, 3.6)).Position
		O.panneau(modele, {
			nom = "PanneauEtabli",
			position = Vector3.new(posPanneau.X, centre.Y, posPanneau.Z),
			texte = "Établi",
			angle = math.deg(lacet),
			largeur = 4.5,
			couleur = C.toit,
			couleurTexte = C.creme,
		})
		nbParts = nbParts + 2

		-- lumière douce de la lampe d'atelier
		local lampe = modele:FindFirstChild("Lampe")
		if lampe then
			O.lumiere(lampe, { Range = 10, Brightness = 0.8, Color = C.dore })
		end

		-- invite : le client ouvre le panneau des améliorations (pas de rappel serveur)
		O.invite(plateau, { nom = "Etabli", action = "Améliorer", objet = "Établi", distance = 12 })
		modele.PrimaryPart = plateau
	end

	local ok, err = pcall(construireEtabli)
	if not ok then
		warn("[Zsurvie] Props : établi non construit : " .. tostring(err))
	end

	-- ===================================================================
	-- 2. Les petits props de la Prairie
	-- ===================================================================
	local rng = O.aleatoire(GRAINE)
	local decor = O.dossier(ctx.dossier, "Decor")

	-- emprises à éviter : disques (centre, rayon)
	local disques = {}
	local function ajouterDisque(zone, rayonParDefaut)
		if type(zone) == "table" and typeof(zone.centre) == "Vector3" then
			table.insert(disques, { c = zone.centre, r = zone.rayon or rayonParDefaut })
		end
	end
	ajouterDisque(P.mine, 7)
	ajouterDisque(P.etabli, 6)
	ajouterDisque(P.etang, 8)
	if type(P.pointsInteret) == "table" then
		for _, pos in ipairs(P.pointsInteret) do
			if typeof(pos) == "Vector3" then
				table.insert(disques, { c = pos, r = P.rayonPointInteret or 8 })
			end
		end
	end
	-- réverbères prévus le long des chemins (20, 40, 60 du centre, de part et d'autre)
	local reverberes = {}
	local distancesLampes = { 20, 40, 60 }
	local decalages = { -8, -5, 5, 8 }
	for _, d in ipairs(distancesLampes) do
		for _, s in ipairs({ -1, 1 }) do
			for _, dec in ipairs(decalages) do
				table.insert(reverberes, Vector3.new(dec, 0, d * s))
				table.insert(reverberes, Vector3.new(d * s, 0, dec))
			end
		end
	end

	local parvis = P.parvis
	local function distanceParvis(x, z)
		if type(parvis) ~= "table" or typeof(parvis.centre) ~= "Vector3" or typeof(parvis.taille) ~= "Vector3" then
			return math.huge
		end
		local dx = math.max(math.abs(x - parvis.centre.X) - parvis.taille.X / 2, 0)
		local dz = math.max(math.abs(z - parvis.centre.Z) - parvis.taille.Z / 2, 0)
		return math.sqrt(dx * dx + dz * dz)
	end

	local places = {}
	local function valide(x, z, r)
		local d = math.sqrt(x * x + z * z)
		if d - r < ANNEAU_MIN or d + r > ANNEAU_MAX then return false end
		if math.abs(x) < COULOIR + r or math.abs(z) < COULOIR + r then return false end
		local pos = Vector3.new(x, 0, z)
		for _, disque in ipairs(disques) do
			if O.distanceXZ(pos, disque.c) < disque.r + MARGE_EMPRISE + r then return false end
		end
		if distanceParvis(x, z) < MARGE_EMPRISE + r then return false end
		for _, lampe in ipairs(reverberes) do
			if O.distanceXZ(pos, lampe) < 2 + r then return false end
		end
		for _, autre in ipairs(places) do
			if O.distanceXZ(pos, autre.p) < autre.r + r + ESPACEMENT then return false end
		end
		return true
	end

	-- ----- constructeurs de props (base = CFrame au sol, tourné) -----
	local function caisse(modele, base)
		local s = rng:NextNumber(2.2, 3.1)
		local couleur = bois
		if rng:NextNumber() < 0.5 then couleur = boisClair end
		bloc(modele, { Name = "Caisse", Size = Vector3.new(s, s, s), CFrame = base * CFrame.new(0, s / 2, 0), Color = couleur })
		bloc(modele, { Name = "Cerclage", Size = Vector3.new(s + 0.12, 0.3, s + 0.12), CFrame = base * CFrame.new(0, 0.25, 0), Color = boisSombre })
		bloc(modele, { Name = "Cerclage", Size = Vector3.new(s + 0.12, 0.3, s + 0.12), CFrame = base * CFrame.new(0, s - 0.25, 0), Color = boisSombre })
		-- parfois une petite caisse empilée
		local s2 = s * 0.65
		if rng:NextNumber() < 0.4 and s + s2 <= HMAX then
			local haut = base * CFrame.new(rng:NextNumber(-0.3, 0.3), s, rng:NextNumber(-0.3, 0.3)) * CFrame.Angles(0, math.rad(rng:NextNumber(10, 35)), 0)
			bloc(modele, { Name = "Caisse", Size = Vector3.new(s2, s2, s2), CFrame = haut * CFrame.new(0, s2 / 2, 0), Color = boisClair })
			bloc(modele, { Name = "Cerclage", Size = Vector3.new(s2 + 0.1, 0.25, s2 + 0.1), CFrame = haut * CFrame.new(0, s2 - 0.2, 0), Color = boisSombre })
		end
	end

	local function tonneau(modele, base)
		local h = rng:NextNumber(2.6, 3.2)
		local d = 2.2
		cylindre(modele, { Name = "Tonneau", Size = Vector3.new(h, d, d), CFrame = base * debout(CFrame.new(0, h / 2, 0)), Color = bois })
		cylindre(modele, { Name = "Cercle", Size = Vector3.new(0.25, d + 0.12, d + 0.12), CFrame = base * debout(CFrame.new(0, 0.5, 0)), Color = metal })
		cylindre(modele, { Name = "Cercle", Size = Vector3.new(0.25, d + 0.12, d + 0.12), CFrame = base * debout(CFrame.new(0, h - 0.5, 0)), Color = metal })
		cylindre(modele, { Name = "Couvercle", Size = Vector3.new(0.1, d - 0.3, d - 0.3), CFrame = base * debout(CFrame.new(0, h + 0.05, 0)), Color = boisSombre })
	end

	local function cloture(modele, base)
		local poteaux = { -2.8, 0, 2.8 }
		for _, px in ipairs(poteaux) do
			bloc(modele, { Name = "Poteau", Size = Vector3.new(0.5, 2.6, 0.5), CFrame = base * CFrame.new(px, 1.3, 0), Color = C.creme })
		end
		bloc(modele, { Name = "Traverse", Size = Vector3.new(6.2, 0.35, 0.25), CFrame = base * CFrame.new(0, 2, -0.35), Color = boisClair })
		-- traverse basse parfois décrochée
		local chute = 0
		if rng:NextNumber() < 0.35 then chute = rng:NextNumber(8, 16) end
		bloc(modele, { Name = "Traverse", Size = Vector3.new(6.2, 0.35, 0.25), CFrame = base * CFrame.new(0, 1, -0.35) * CFrame.Angles(0, 0, math.rad(chute)), Color = boisClair })
	end

	local function rocher(modele, base)
		local teintes = { metal, metalClair, metalSombre }
		local s = rng:NextNumber(2, 3.2)
		boule(modele, { Name = "Rocher", Size = Vector3.new(s, s * 0.8, s), CFrame = base * CFrame.new(0, s * 0.3, 0), Color = teintes[rng:NextInteger(1, 3)] })
		local n = rng:NextInteger(1, 2)
		for i = 1, n do
			local t = rng:NextNumber(0.9, 1.5)
			local a = math.rad(rng:NextNumber(0, 360))
			local r = s * 0.5 + t * 0.2
			boule(modele, {
				Name = "Caillou",
				Size = Vector3.new(t, t * 0.8, t),
				CFrame = base * CFrame.new(math.cos(a) * r, t * 0.3, math.sin(a) * r),
				Color = teintes[((i + n) % 3) + 1],
			})
		end
	end

	local function lanterne(modele, base)
		bloc(modele, { Name = "Socle", Size = Vector3.new(0.9, 0.3, 0.9), CFrame = base * CFrame.new(0, 0.15, 0), Color = metalSombre })
		bloc(modele, { Name = "Poteau", Size = Vector3.new(0.35, 3.8, 0.35), CFrame = base * CFrame.new(0, 2.2, 0), Color = bois })
		bloc(modele, { Name = "Bras", Size = Vector3.new(1.2, 0.25, 0.25), CFrame = base * CFrame.new(0.5, 3.95, 0), Color = bois })
		bloc(modele, { Name = "Chapeau", Size = Vector3.new(0.9, 0.25, 0.9), CFrame = base * CFrame.new(0.95, 3.7, 0), Color = C.encre, CanCollide = false })
		local flamme = bloc(modele, { Name = "Flamme", Size = Vector3.new(0.55, 0.7, 0.55), CFrame = base * CFrame.new(0.95, 3.2, 0), Color = C.dore, Material = neon, CanCollide = false })
		O.lumiere(flamme, { Range = 14, Brightness = 1, Color = C.dore })
	end

	local function brouette(modele, base)
		local bac = base * CFrame.new(0, 1.3, 0.2) * CFrame.Angles(math.rad(-6), 0, 0)
		bloc(modele, { Name = "Bac", Size = Vector3.new(1.8, 0.9, 2.6), CFrame = bac, Color = C.toit })
		bloc(modele, { Name = "Chargement", Size = Vector3.new(1.5, 0.3, 2.2), CFrame = bac * CFrame.new(0, 0.5, 0), Color = C.lumiere(C.dore) })
		cylindre(modele, { Name = "Roue", Size = Vector3.new(0.4, 1.2, 1.2), CFrame = base * CFrame.new(0, 0.6, -1.5), Color = C.encre })
		bloc(modele, { Name = "Brancard", Size = Vector3.new(0.2, 0.2, 2.2), CFrame = base * CFrame.new(-0.7, 1.05, 1.9), Color = bois })
		bloc(modele, { Name = "Brancard", Size = Vector3.new(0.2, 0.2, 2.2), CFrame = base * CFrame.new(0.7, 1.05, 1.9), Color = bois })
		bloc(modele, { Name = "Bequille", Size = Vector3.new(0.2, 0.9, 0.2), CFrame = base * CFrame.new(-0.6, 0.45, 1), Color = boisSombre })
		bloc(modele, { Name = "Bequille", Size = Vector3.new(0.2, 0.9, 0.2), CFrame = base * CFrame.new(0.6, 0.45, 1), Color = boisSombre })
	end

	local function meule(modele, base)
		local foin = C.lumiere(C.dore)
		local lien = C.ombre(C.dore)
		if rng:NextNumber() < 0.5 then
			-- balle ronde couchée (axe X horizontal)
			cylindre(modele, { Name = "Balle", Size = Vector3.new(2.4, 2.6, 2.6), CFrame = base * CFrame.new(0, 1.3, 0), Color = foin })
			cylindre(modele, { Name = "Lien", Size = Vector3.new(0.15, 2.66, 2.66), CFrame = base * CFrame.new(-0.6, 1.3, 0), Color = lien })
			cylindre(modele, { Name = "Lien", Size = Vector3.new(0.15, 2.66, 2.66), CFrame = base * CFrame.new(0.6, 1.3, 0), Color = lien })
		else
			-- balles carrées empilées
			bloc(modele, { Name = "Botte", Size = Vector3.new(1.4, 1.2, 2.6), CFrame = base * CFrame.new(-0.75, 0.6, 0), Color = foin })
			bloc(modele, { Name = "Botte", Size = Vector3.new(1.4, 1.2, 2.6), CFrame = base * CFrame.new(0.75, 0.6, 0), Color = foin })
			bloc(modele, { Name = "Botte", Size = Vector3.new(1.4, 1.2, 2.6), CFrame = base * CFrame.new(0, 1.8, 0.1) * CFrame.Angles(0, math.rad(8), 0), Color = C.lumiere(foin) })
		end
	end

	-- nom, rayon d'emprise, parts au plus, nombre voulu, constructeur
	local TYPES = {
		{ nom = "Caisse", rayon = 2.4, maxParts = 5, nombre = 14, fn = caisse },
		{ nom = "Tonneau", rayon = 1.3, maxParts = 4, nombre = 12, fn = tonneau },
		{ nom = "Cloture", rayon = 3.2, maxParts = 5, nombre = 10, fn = cloture },
		{ nom = "Rocher", rayon = 2.4, maxParts = 3, nombre = 16, fn = rocher },
		{ nom = "Lanterne", rayon = 1.3, maxParts = 5, nombre = 8, fn = lanterne },
		{ nom = "Brouette", rayon = 3, maxParts = 7, nombre = 3, fn = brouette },
		{ nom = "MeuleDeFoin", rayon = 2, maxParts = 3, nombre = 10, fn = meule },
	}

	local taches = {}
	for _, t in ipairs(TYPES) do
		for _ = 1, t.nombre do
			table.insert(taches, t)
		end
	end
	-- mélange déterministe (Fisher-Yates)
	for i = #taches, 2, -1 do
		local j = rng:NextInteger(1, i)
		taches[i], taches[j] = taches[j], taches[i]
	end

	local poses = 0
	for _, t in ipairs(taches) do
		if nbParts + t.maxParts <= BUDGET then
			for _ = 1, ESSAIS do
				local a = rng:NextNumber(0, math.pi * 2)
				local d = rng:NextNumber(ANNEAU_MIN + t.rayon, ANNEAU_MAX - t.rayon)
				local x = math.cos(a) * d
				local z = math.sin(a) * d
				if valide(x, z, t.rayon) then
					table.insert(places, { p = Vector3.new(x, 0, z), r = t.rayon })
					local modele = O.modele(decor, t.nom)
					local base = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), 0)
					local okProp, errProp = pcall(t.fn, modele, base)
					if okProp then
						poses = poses + 1
					else
						warn("[Zsurvie] Props : " .. t.nom .. " non construit : " .. tostring(errProp))
					end
					break
				end
			end
		end
	end

	ctx.dossier:SetAttribute("Parts", nbParts)
	ctx.dossier:SetAttribute("PropsPoses", poses)
end

return M
