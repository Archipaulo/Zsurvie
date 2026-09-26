-- Builders/PointsInteret : quatre petits lieux sur les diagonales de la Prairie.
-- Camp de survivants, vieux puits, tour de guet en ruine, chariot renversé.
-- Chaque lieu tient dans un disque de rayon Plan.rayonPointInteret, sous 6 studs de haut.
local M = {}

local BUDGET = 300
local SOL = 0.2 -- dessus du disque de sol de chaque lieu

function M.construire(ctx)
	local C = ctx.Charte
	local O = ctx.Outils
	local P = ctx.Plan

	local compteur = 0

	-- palette (uniquement la Charte)
	local bois = C.terre
	local boisSombre = C.ombre(C.terre)
	local boisClair = C.lumiere(C.terre)
	local pierre = C.ardoise
	local pierreClaire = C.lumiere(C.ardoise)
	local pierreSombre = C.ombre(C.ardoise)
	local mousse = C.ombre(C.prairie)
	local eau = C.ombre(C.gemme)
	local neon = Enum.Material.Neon

	local function cf(x, y, z, rx, ry, rz)
		return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
	end

	-- crée une part dans le budget ; renvoie nil si le budget est épuisé ou si la création échoue
	local function creer(genre, parent, cfMonde, nom, taille, couleur, materiau)
		if compteur >= BUDGET then
			return nil
		end
		local props = {
			Name = nom,
			Size = taille,
			CFrame = cfMonde,
			Color = couleur or C.creme,
			Material = materiau or Enum.Material.SmoothPlastic,
		}
		local ok, part = pcall(function()
			if genre == "coin" then
				return O.coin(parent, props)
			elseif genre == "cyl" then
				return O.cylindre(parent, props)
			elseif genre == "boule" then
				return O.boule(parent, props)
			end
			return O.bloc(parent, props)
		end)
		if ok and part then
			compteur = compteur + 1
			return part
		end
		return nil
	end

	local function regler(part, props)
		if part then
			for cle, valeur in pairs(props) do
				part[cle] = valeur
			end
		end
		return part
	end

	local function lumiere(part, props)
		if not part then
			return nil
		end
		local ok, l = pcall(O.lumiere, part, props)
		if ok then
			return l
		end
		return nil
	end

	-- fabrique : fonctions de construction dans le repère local d'un lieu
	local function fabrique(modele, repere)
		local f = {}
		function f.bloc(nom, taille, cfl, couleur, materiau)
			return creer("bloc", modele, repere * cfl, nom, taille, couleur, materiau)
		end
		function f.coin(nom, taille, cfl, couleur, materiau)
			return creer("coin", modele, repere * cfl, nom, taille, couleur, materiau)
		end
		-- l'axe du cylindre est l'axe X local de cfl
		function f.cyl(nom, longueur, diametre, cfl, couleur, materiau)
			return creer("cyl", modele, repere * cfl, nom, Vector3.new(longueur, diametre, diametre), couleur, materiau)
		end
		function f.boule(nom, diametre, cfl, couleur, materiau)
			return creer("boule", modele, repere * cfl, nom, Vector3.new(diametre, diametre, diametre), couleur, materiau)
		end
		-- poutre droite entre deux points locaux (jamais parfaitement verticale)
		function f.poutre(nom, a, b, epaisseur, couleur)
			local longueur = (b - a).Magnitude
			local cfl = CFrame.lookAt(a, b) * CFrame.new(0, 0, -longueur / 2)
			return f.bloc(nom, Vector3.new(epaisseur, epaisseur, longueur), cfl, couleur)
		end
		-- roue : cfl donne le centre, l'axe de la roue est l'axe X local
		function f.roue(nom, cfl, diametre)
			local d = diametre or 2.2
			f.cyl(nom, 0.3, d, cfl, boisSombre)
			f.cyl(nom .. "Moyeu", 0.5, d * 0.27, cfl, bois)
			f.bloc(nom .. "Rayon", Vector3.new(0.12, d * 0.9, 0.18), cfl * CFrame.Angles(math.rad(45), 0, 0), bois)
			f.bloc(nom .. "Rayon", Vector3.new(0.12, d * 0.9, 0.18), cfl * CFrame.Angles(math.rad(-45), 0, 0), bois)
		end
		-- disque de sol plat du lieu
		function f.sol(diametre, couleur)
			return f.cyl("Sol", SOL, diametre, cf(0, SOL / 2, 0, 0, 0, 90), couleur)
		end
		return f
	end

	-- repère d'un lieu : centré sur l'emplacement, -Z local tourné vers la Maison
	local function repereDe(centre)
		local maison = P.maison and P.maison.centre or Vector3.new(0, 0, 0)
		local sol = Vector3.new(centre.X, 0, centre.Z)
		local cible = Vector3.new(maison.X, 0, maison.Z)
		if (cible - sol).Magnitude < 0.1 then
			return CFrame.new(sol)
		end
		return CFrame.lookAt(sol, cible)
	end

	local rayon = P.rayonPointInteret or 8
	local diametreSol = rayon * 2 - 1

	-- ===== 1. camp de survivants =====
	local function camp(modele, f)
		local sol = f.sol(diametreSol, boisClair)

		-- cercle de pierres autour du feu
		for i = 0, 7 do
			local a = math.rad(i * 45)
			local couleur = pierre
			if i % 2 == 0 then
				couleur = pierreClaire
			end
			f.boule("PierreFoyer", 0.9, cf(math.cos(a) * 1.6, SOL + 0.3, math.sin(a) * 1.6), couleur)
		end
		-- bûches croisées dans le foyer
		for i = 0, 2 do
			f.cyl("BucheFoyer", 2, 0.45, cf(0, SOL + 0.4, 0, 0, i * 60, 12), boisSombre)
		end
		-- braises, flammes, feu et lumière
		local braises = f.bloc("Braises", Vector3.new(1.4, 0.3, 1.4), cf(0, SOL + 0.15, 0), C.toit, neon)
		regler(f.boule("Flamme", 1, cf(0, SOL + 0.9, 0), C.dore, neon), { Transparency = 0.25, CanCollide = false })
		regler(f.boule("Flamme", 0.6, cf(0.1, SOL + 1.5, -0.1), C.lumiere(C.dore), neon), { Transparency = 0.3, CanCollide = false })
		if braises then
			pcall(function()
				local feu = Instance.new("Fire")
				feu.Size = 4
				feu.Heat = 7
				feu.Color = C.toit
				feu.SecondaryColor = C.dore
				feu.Parent = braises
			end)
			local lueur = lumiere(braises, { genre = "Point", Range = 18, Brightness = 2, Color = C.lumiere(C.dore) })
			if lueur then
				-- léger vacillement du feu
				task.spawn(function()
					local rng = O.aleatoire(3737)
					while lueur.Parent and modele.Parent do
						lueur.Brightness = 1.6 + rng:NextNumber() * 0.9
						task.wait(0.12 + rng:NextNumber() * 0.12)
					end
				end)
			end
		end

		-- trépied et marmite
		local sommet = Vector3.new(0, SOL + 3.1, 0)
		for i = 0, 2 do
			local a = math.rad(i * 120 + 30)
			f.poutre("Trepied", Vector3.new(math.cos(a) * 1.3, SOL, math.sin(a) * 1.3), sommet, 0.2, boisSombre)
		end
		f.bloc("Chaine", Vector3.new(0.1, 0.6, 0.1), cf(0, SOL + 2.8, 0), C.encre)
		f.boule("Marmite", 1.1, cf(0, SOL + 2.1, 0), C.encre)

		-- bûches pour s'asseoir (axe tangent au cercle)
		local sieges = { { a = 270, l = 3.6 }, { a = 200, l = 2.6 }, { a = 340, l = 2.6 } }
		for _, s in ipairs(sieges) do
			local a = math.rad(s.a)
			local centreBuche = cf(math.cos(a) * 3.3, SOL + 0.5, math.sin(a) * 3.3, 0, -(s.a + 90), 0)
			f.cyl("Siege", s.l, 1, centreBuche, bois)
			f.cyl("Cerne", 0.08, 0.8, centreBuche * CFrame.new(s.l / 2 + 0.02, 0, 0), boisClair)
			f.cyl("Cerne", 0.08, 0.8, centreBuche * CFrame.new(-s.l / 2 - 0.02, 0, 0), boisClair)
		end

		-- tentes : faîte selon X local, entrée (+X) tournée vers le feu
		local function tente(cx, cz, couleur)
			local ry = math.deg(math.atan2(cz, -cx))
			local t = cf(cx, SOL, cz, 0, ry, 0)
			local h, l, d = 2.6, 3.6, 1.6
			f.bloc("Tapis", Vector3.new(4.2, 0.08, 3.6), t * cf(0, 0.04, 0), C.ombre(couleur))
			f.coin("Toile", Vector3.new(l, h, d), t * cf(0, h / 2, -d / 2), couleur)
			f.coin("Toile", Vector3.new(l, h, d), t * cf(0, h / 2, d / 2, 0, 180, 0), C.lumiere(couleur))
			f.cyl("Faite", l + 0.4, 0.2, t * cf(0, h + 0.05, 0), bois)
			f.bloc("Mat", Vector3.new(0.2, h, 0.2), t * cf(l / 2 + 0.12, h / 2, 0), boisSombre)
			f.bloc("Mat", Vector3.new(0.2, h, 0.2), t * cf(-l / 2 - 0.12, h / 2, 0), boisSombre)
			f.bloc("Entree", Vector3.new(0.06, 1.5, 0.9), t * cf(l / 2 + 0.01, 0.8, 0), C.encre)
			f.bloc("Piquet", Vector3.new(0.2, 0.5, 0.2), t * cf(1.9, 0.25, 1.75), boisSombre)
			f.bloc("Piquet", Vector3.new(0.2, 0.5, 0.2), t * cf(1.9, 0.25, -1.75), boisSombre)
			f.bloc("Piquet", Vector3.new(0.2, 0.5, 0.2), t * cf(-1.9, 0.25, 1.75), boisSombre)
			f.bloc("Piquet", Vector3.new(0.2, 0.5, 0.2), t * cf(-1.9, 0.25, -1.75), boisSombre)
		end
		tente(3.4, 3.7, C.toit)
		tente(-3.4, 3.7, C.creme)

		-- tas de bois
		local rangs = { { -0.5, 0, 0.5 }, { -0.25, 0.25 }, { 0 } }
		for r, ligne in ipairs(rangs) do
			for _, dz in ipairs(ligne) do
				f.cyl("TasBois", 2, 0.5, cf(-5.6, SOL + 0.25 + (r - 1) * 0.43, -3 + dz), bois)
			end
		end

		-- billot et hache
		f.cyl("Billot", 0.9, 1.2, cf(5.4, SOL + 0.45, -3.2, 0, 0, 90), bois)
		f.bloc("Manche", Vector3.new(0.15, 1.4, 0.15), cf(5.5, SOL + 1.35, -3.2, 0, 0, 25), boisClair)
		f.bloc("Fer", Vector3.new(0.5, 0.35, 0.1), cf(5.25, SOL + 1.05, -3.2, 0, 0, 25), pierreClaire)

		-- sac à dos
		f.bloc("SacDos", Vector3.new(0.9, 1.1, 0.6), cf(-5.8, SOL + 0.55, 1.0, 0, 20, 0), C.toit)
		f.boule("SacRabat", 0.8, cf(-5.8, SOL + 1.1, 1.0), C.ombre(C.toit))

		-- lanterne
		f.bloc("LanterneSocle", Vector3.new(0.6, 0.15, 0.6), cf(5.8, SOL + 0.075, 1.2), C.encre)
		local verre = f.bloc("LanterneVerre", Vector3.new(0.45, 0.6, 0.45), cf(5.8, SOL + 0.45, 1.2), C.dore, neon)
		f.bloc("LanterneChapeau", Vector3.new(0.6, 0.15, 0.6), cf(5.8, SOL + 0.825, 1.2), C.encre)
		lumiere(verre, { genre = "Point", Range = 8, Brightness = 1, Color = C.lumiere(C.dore) })

		return sol
	end

	-- ===== 2. vieux puits =====
	local function puits(modele, f)
		local sol = f.sol(diametreSol, C.lumiere(C.prairie):Lerp(C.terre, 0.5))
		local rng = O.aleatoire(4242)

		-- dalles autour du puits
		for i = 0, 9 do
			local a = math.rad(i * 36 + rng:NextNumber(-8, 8))
			local couleur = pierreClaire
			if i % 3 == 0 then
				couleur = pierre
			end
			f.bloc("Dalle", Vector3.new(1.6, 0.12, 1.2), cf(math.cos(a) * 4.3, SOL + 0.06, math.sin(a) * 4.3, 0, rng:NextNumber(0, 90), 0), couleur)
		end

		-- margelle : deux rangs de pierres décalés
		for rang = 0, 1 do
			for i = 0, 11 do
				local deg = i * 30 + rang * 15
				local a = math.rad(deg)
				local couleur = pierre
				if (i + rang) % 2 == 0 then
					couleur = pierreClaire
				end
				f.bloc("Margelle", Vector3.new(0.7, 1, 1.25), cf(math.cos(a) * 2.2, SOL + 0.5 + rang, math.sin(a) * 2.2, 0, -deg, 0), couleur)
			end
		end
		-- fond sombre et eau
		f.cyl("Fond", 0.1, 3.6, cf(0, SOL + 0.6, 0, 0, 0, 90), C.encre)
		regler(f.cyl("Eau", 0.1, 3.6, cf(0, SOL + 1.1, 0, 0, 0, 90), eau), { Transparency = 0.3, Reflectance = 0.1 })

		-- montants, traverse et petit toit
		f.bloc("Montant", Vector3.new(0.5, 4.6, 0.5), cf(2.55, SOL + 2.3, 0), bois)
		f.bloc("Montant", Vector3.new(0.5, 4.6, 0.5), cf(-2.55, SOL + 2.3, 0), bois)
		f.bloc("Traverse", Vector3.new(5.6, 0.4, 0.4), cf(0, SOL + 4.4, 0), boisSombre)
		f.coin("Toit", Vector3.new(6, 1.1, 2.2), cf(0, SOL + 5.15, -1.1), boisSombre)
		f.coin("Toit", Vector3.new(6, 1.1, 2.2), cf(0, SOL + 5.15, 1.1, 0, 180, 0), C.ombre(boisSombre))
		f.cyl("Faitage", 6.2, 0.25, cf(0, SOL + 5.7, 0), bois)

		-- treuil, manivelle, corde et seau
		f.cyl("Treuil", 4.6, 0.5, cf(0, SOL + 3.4, 0), boisClair)
		f.bloc("Manivelle", Vector3.new(0.2, 0.9, 0.2), cf(2.95, SOL + 3.0, 0), C.encre)
		f.cyl("Poignee", 0.6, 0.2, cf(3.25, SOL + 2.6, 0), boisSombre)
		f.bloc("Corde", Vector3.new(0.12, 0.5, 0.12), cf(0, SOL + 2.95, 0), C.ombre(C.creme))
		f.cyl("Seau", 0.7, 0.8, cf(0, SOL + 2.35, 0, 0, 0, 90), bois)
		f.cyl("Cerclage", 0.12, 0.86, cf(0, SOL + 2.5, 0, 0, 0, 90), C.encre)

		-- seau renversé et flaque
		f.cyl("SeauRenverse", 0.8, 0.8, cf(3.6, SOL + 0.4, 2.8, 0, 35, 0), bois)
		regler(f.cyl("Flaque", 0.05, 1.4, cf(4.3, SOL + 0.03, 3.3, 0, 0, 90), eau), { Transparency = 0.4, CanCollide = false })

		-- abreuvoir
		local ab = cf(-4.4, SOL + 0.12, 3.2, 0, 30, 0)
		f.bloc("AbreuvoirFond", Vector3.new(2.6, 0.2, 1), ab * cf(0, 0.1, 0), boisSombre)
		f.bloc("AbreuvoirBord", Vector3.new(2.6, 0.7, 0.15), ab * cf(0, 0.35, 0.5), bois)
		f.bloc("AbreuvoirBord", Vector3.new(2.6, 0.7, 0.15), ab * cf(0, 0.35, -0.5), bois)
		f.bloc("AbreuvoirBord", Vector3.new(0.15, 0.7, 1), ab * cf(1.3, 0.35, 0), bois)
		f.bloc("AbreuvoirBord", Vector3.new(0.15, 0.7, 1), ab * cf(-1.3, 0.35, 0), bois)
		regler(f.bloc("AbreuvoirEau", Vector3.new(2.3, 0.1, 0.7), ab * cf(0, 0.55, 0), eau), { Transparency = 0.3 })

		-- mousse sur la margelle
		for _, deg in ipairs({ 20, 110, 200, 290 }) do
			local a = math.rad(deg)
			f.bloc("Mousse", Vector3.new(0.6, 0.06, 0.9), cf(math.cos(a) * 2.2, SOL + 2.03, math.sin(a) * 2.2, 0, -deg, 0), mousse)
		end

		-- pierres tombées
		f.bloc("PierreTombee", Vector3.new(0.7, 0.6, 1.1), cf(-3.2, SOL + 0.3, -1.4, 0, 25, 8), pierre)
		f.bloc("PierreTombee", Vector3.new(0.6, 0.5, 0.9), cf(1.2, SOL + 0.25, -3.4, 0, -40, 0), pierreSombre)
		f.boule("Caillou", 0.6, cf(-2.4, SOL + 0.25, -3.0), pierreClaire)

		return sol
	end

	-- ===== 3. tour de guet en ruine (basse) =====
	local function tour(modele, f)
		local sol = f.sol(diametreSol, C.ombre(C.terre):Lerp(C.prairie, 0.35))
		local rng = O.aleatoire(5151)
		local teintes = { pierre, pierreClaire, pierreSombre }
		local function teinte()
			return teintes[rng:NextInteger(1, #teintes)]
		end

		-- murs nord/sud (Z fixe, 5 segments), une porte au milieu du mur face à la Maison
		local mursZ = {
			{ z = -2.6, h = { 5.2, 2.2, 0, 0.6, 4.4 } },
			{ z = 2.6, h = { 5.8, 5.0, 3.6, 2.4, 1.2 } },
		}
		for _, mur in ipairs(mursZ) do
			for i, h in ipairs(mur.h) do
				if h > 0 then
					f.bloc("Mur", Vector3.new(1.2, h, 0.8), cf(-2.4 + (i - 1) * 1.2, SOL + h / 2, mur.z), teinte())
				end
			end
		end
		-- murs est/ouest (X fixe, 4 segments entre les précédents)
		local mursX = {
			{ x = -2.6, h = { 4.8, 3.4, 4.0, 1.6 } },
			{ x = 2.6, h = { 5.5, 4.6, 2.0, 2.8 } },
		}
		for _, mur in ipairs(mursX) do
			for i, h in ipairs(mur.h) do
				f.bloc("Mur", Vector3.new(0.8, h, 1.1), cf(mur.x, SOL + h / 2, -1.65 + (i - 1) * 1.1), teinte())
			end
		end

		-- poteaux d'angle, poutres et plancher effondré en partie
		local poteaux = { { -1.9, -1.9, 5.6 }, { 1.9, -1.9, 4.2 }, { -1.9, 1.9, 5.8 }, { 1.9, 1.9, 2.5 } }
		for _, p in ipairs(poteaux) do
			f.bloc("Poteau", Vector3.new(0.4, p[3], 0.4), cf(p[1], SOL + p[3] / 2, p[2]), boisSombre)
		end
		f.bloc("Solive", Vector3.new(0.4, 0.4, 4.2), cf(-1.9, SOL + 2.9, 0), bois)
		f.bloc("Solive", Vector3.new(0.4, 0.4, 3.0), cf(1.9, SOL + 2.9, -0.6), bois)
		for _, z in ipairs({ -1.4, -0.7, 0 }) do
			f.bloc("Planche", Vector3.new(4.2, 0.2, 0.66), cf(0, SOL + 3.2, z), boisClair)
		end
		f.bloc("PlancheTombee", Vector3.new(3.4, 0.2, 0.66), cf(0.6, SOL + 0.6, 1.4, 0, 20, 18), boisClair)
		f.bloc("PlancheTombee", Vector3.new(2.6, 0.2, 0.66), cf(-0.8, SOL + 0.15, 0.9, 0, -35, 0), bois)

		-- échelle appuyée contre le mur est (un barreau manque)
		local ga = Vector3.new(4.4, SOL, -0.95)
		local gb = Vector3.new(3.1, SOL + 4.4, -0.95)
		local da = Vector3.new(4.4, SOL, -0.15)
		local db = Vector3.new(3.1, SOL + 4.4, -0.15)
		f.poutre("Montant", ga, gb, 0.18, bois)
		f.poutre("Montant", da, db, 0.18, bois)
		for _, t in ipairs({ 0.15, 0.35, 0.55, 0.75 }) do
			f.poutre("Barreau", ga:Lerp(gb, t), da:Lerp(db, t), 0.14, boisClair)
		end

		-- étendard déchiré sur le mur arrière
		f.cyl("Hampe", 1.8, 0.14, cf(-0.6, SOL + 4.1, 3.08), boisSombre)
		f.bloc("Etendard", Vector3.new(1.4, 2, 0.08), cf(-0.6, SOL + 3.05, 3.08, 0, 0, 3), C.toit)

		-- torche près de la porte
		f.bloc("Torche", Vector3.new(0.25, 0.8, 0.25), cf(-2.4, SOL + 3.2, -3.1, -15, 0, 0), boisSombre)
		local flamme = f.boule("TorcheFlamme", 0.45, cf(-2.4, SOL + 3.7, -3.2), C.dore, neon)
		regler(flamme, { CanCollide = false })
		lumiere(flamme, { genre = "Point", Range = 10, Brightness = 1.2, Color = C.lumiere(C.dore) })

		-- meurtrières
		f.bloc("Meurtriere", Vector3.new(0.3, 1, 0.06), cf(-2.4, SOL + 4.2, 3.02), C.encre)
		f.bloc("Meurtriere", Vector3.new(0.06, 1, 0.3), cf(-3.02, SOL + 3.6, -1.65), C.encre)

		-- mousse et lierre
		f.bloc("Lierre", Vector3.new(0.06, 2.2, 0.8), cf(3.02, SOL + 3.6, -1.7), mousse)
		f.bloc("Mousse", Vector3.new(1.2, 0.08, 0.8), cf(-2.4, SOL + 5.24, 2.6), mousse)
		f.bloc("Mousse", Vector3.new(0.8, 0.08, 1.1), cf(-2.6, SOL + 4.04, 0.55), mousse)

		-- poutres tombées dehors
		f.bloc("PoutreTombee", Vector3.new(0.4, 0.4, 3.2), cf(-4.6, SOL + 0.2, 2.2, 0, 30, 0), boisSombre)
		f.bloc("PoutreTombee", Vector3.new(0.4, 0.4, 2.6), cf(2.2, SOL + 0.2, -4.6, 0, 75, 6), boisSombre)

		-- éboulis autour de la tour (hors du pied de l'échelle)
		local poses, essais = 0, 0
		while poses < 10 and essais < 40 do
			essais = essais + 1
			local a = rng:NextNumber(0, math.pi * 2)
			local r = rng:NextNumber(3.7, rayon - 1.8)
			local x, z = math.cos(a) * r, math.sin(a) * r
			local surEchelle = x > 2.8 and x < 5.2 and z > -1.6 and z < 0.5
			if not surEchelle then
				local s = rng:NextNumber(0.5, 1.1)
				f.bloc("Eboulis", Vector3.new(s, s * 0.7, s * 1.2), cf(x, SOL + s * 0.3, z, rng:NextNumber(-15, 15), rng:NextNumber(0, 180), rng:NextNumber(-15, 15)), teinte())
				poses = poses + 1
			end
		end
		-- deux pierres à l'intérieur
		f.bloc("Eboulis", Vector3.new(0.9, 0.6, 0.8), cf(-1.2, SOL + 0.3, -1.1, 0, 20, 0), teinte())
		f.bloc("Eboulis", Vector3.new(0.7, 0.5, 0.7), cf(1.0, SOL + 0.25, -1.5, 0, -30, 10), teinte())

		return sol
	end

	-- ===== 4. chariot renversé, caisses et gemmes =====
	local function chariot(modele, f)
		local sol = f.sol(diametreSol, C.lumiere(C.terre):Lerp(C.prairie, 0.3))
		local rng = O.aleatoire(6464)

		-- ornières
		f.bloc("Orniere", Vector3.new(0.8, 0.05, 5), cf(-3.6, SOL + 0.025, -3.2, 0, 70, 0), boisSombre)
		f.bloc("Orniere", Vector3.new(0.8, 0.05, 4.2), cf(-3.2, SOL + 0.025, -4.4, 0, 72, 0), boisSombre)

		-- le chariot, couché sur le flanc (repère propre)
		local ch = cf(-1.2, SOL + 1.9, -0.5, 0, 20, 0) * CFrame.Angles(math.rad(75), 0, 0)
		f.bloc("Plateau", Vector3.new(6, 0.3, 3.6), ch, bois)
		f.bloc("Ridelle", Vector3.new(6, 1.4, 0.25), ch * cf(0, 0.85, 1.675), boisClair)
		f.bloc("Ridelle", Vector3.new(6, 1.4, 0.25), ch * cf(0, 0.85, -1.675), boisClair)
		f.bloc("Ridelle", Vector3.new(0.25, 1.4, 3.1), ch * cf(2.875, 0.85, 0), boisClair)
		f.bloc("Ridelle", Vector3.new(0.25, 1.4, 3.1), ch * cf(-2.875, 0.85, 0), boisClair)
		f.bloc("Renfort", Vector3.new(0.3, 0.1, 3.7), ch * cf(1.5, -0.2, 0), boisSombre)
		f.bloc("Renfort", Vector3.new(0.3, 0.1, 3.7), ch * cf(-1.5, -0.2, 0), boisSombre)
		f.cyl("Essieu", 4.4, 0.35, ch * cf(2, -0.55, 0, 0, 90, 0), C.encre)
		f.cyl("Essieu", 4.4, 0.35, ch * cf(-2, -0.55, 0, 0, 90, 0), C.encre)
		-- les deux roues restées en l'air
		f.roue("Roue", ch * cf(2, -0.55, -2.25, 0, 90, 0), 2.2)
		f.roue("Roue", ch * cf(-2, -0.55, -2.25, 0, 90, 0), 2.2)
		-- brancards (l'un cassé)
		f.bloc("Brancard", Vector3.new(3.2, 0.25, 0.25), ch * cf(4.6, -0.3, 0.9), bois)
		f.bloc("Brancard", Vector3.new(1.8, 0.25, 0.25), ch * cf(3.9, -0.3, -0.9), bois)

		-- une roue tombée à plat, une autre appuyée
		f.roue("RoueTombee", cf(3.6, SOL + 0.15, 4.4, 0, 0, 90), 2.2)
		f.roue("RoueAppuyee", cf(-5.2, SOL + 1.12, 2.6, 0, 30, 0) * CFrame.Angles(0, 0, math.rad(-12)), 2.2)

		-- caisses
		local function caisse(x, y, z, s, ry)
			local c = cf(x, y + s / 2, z, 0, ry, 0)
			f.bloc("Caisse", Vector3.new(s, s, s), c, bois)
			f.bloc("Cerclage", Vector3.new(s + 0.06, 0.18, s + 0.06), c * cf(0, s / 2 - 0.15, 0), boisSombre)
			f.bloc("Cerclage", Vector3.new(s + 0.06, 0.18, s + 0.06), c * cf(0, -s / 2 + 0.15, 0), boisSombre)
			return c
		end
		caisse(2.6, SOL, 3.2, 1.6, 10)
		caisse(2.5, SOL + 1.6, 3.2, 1.2, 35)
		caisse(-0.2, SOL, 4.3, 1.4, -20)
		caisse(0.8, SOL, -5.3, 1.3, 15)
		-- caisse éventrée : couvercle posé de travers à côté
		caisse(-3.0, SOL, 4.6, 1.5, 5)
		f.bloc("Couvercle", Vector3.new(1.5, 0.15, 1.5), cf(-2.0, SOL + 0.55, 5.6, 0, 20, 55), boisClair)

		-- gemmes répandues (de la caisse éventrée vers le chariot)
		local gemmes = {
			{ -2.2, 3.4 }, { -1.6, 2.9 }, { -2.7, 3.0 }, { -1.0, 3.6 }, { -3.9, 3.5 }, { 1.4, 2.0 },
			{ 4.0, 2.2 }, { -0.4, 2.5 }, { 4.2, -0.9 }, { 3.2, -1.6 }, { -4.6, 1.2 },
		}
		for i, g in ipairs(gemmes) do
			local gem = f.bloc("Gemme", Vector3.new(0.5, 0.8, 0.5), cf(g[1], SOL + 0.35, g[2], rng:NextNumber(-30, 30), rng:NextNumber(0, 90), 45), C.gemme, neon)
			regler(gem, { CanCollide = false })
			if gem and i % 4 == 1 then
				O.animer(gem, "pulse", 0.8)
				lumiere(gem, { genre = "Point", Range = 6, Brightness = 0.8, Color = C.gemme })
			end
		end
		-- grosse gemme posée sur la pile de caisses
		local grosse = f.bloc("GrosseGemme", Vector3.new(0.8, 1.2, 0.8), cf(2.5, SOL + 3.4, 3.2, 0, 30, 45), C.lumiere(C.gemme), neon)
		regler(grosse, { CanCollide = false })
		if grosse then
			O.animer(grosse, "pulse", 1)
			lumiere(grosse, { genre = "Point", Range = 8, Brightness = 1, Color = C.gemme })
		end

		-- quelques pièces
		for i = 1, 4 do
			local a = rng:NextNumber(0, math.pi * 2)
			local x = 0.4 + math.cos(a) * rng:NextNumber(0.4, 1.4)
			local z = 3.0 + math.sin(a) * rng:NextNumber(0.2, 0.6)
			f.cyl("Piece", 0.12, 0.6, cf(x, SOL + 0.06, z, 0, rng:NextNumber(0, 180), 90), C.dore)
		end

		-- sac de toile
		f.boule("Sac", 1.3, cf(4.8, SOL + 0.6, 1.4), C.creme)
		f.cyl("SacLien", 0.2, 0.5, cf(4.8, SOL + 1.25, 1.4, 0, 0, 90), boisSombre)

		return sol
	end

	-- ===== pose des quatre lieux =====
	local lieux = {
		{ nom = "CampSurvivants", fonction = camp },
		{ nom = "VieuxPuits", fonction = puits },
		{ nom = "TourGuetRuine", fonction = tour },
		{ nom = "ChariotRenverse", fonction = chariot },
	}
	local emplacements = P.pointsInteret or {}
	for i, lieu in ipairs(lieux) do
		local centre = emplacements[i]
		if typeof(centre) == "Vector3" then
			local modele = O.modele(ctx.dossier, lieu.nom)
			modele:SetAttribute("PointInteret", lieu.nom)
			local f = fabrique(modele, repereDe(centre))
			local ok, resultat = pcall(lieu.fonction, modele, f)
			if not ok then
				warn("[Zsurvie] PointsInteret : échec du lieu " .. lieu.nom .. " : " .. tostring(resultat))
			elseif resultat then
				modele.PrimaryPart = resultat
			end
		end
	end
end

return M
