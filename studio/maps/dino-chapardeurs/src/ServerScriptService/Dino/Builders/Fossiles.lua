-- Constructeur Fossiles : petits props de décor (4 studs de haut au plus) façon « expédition paléontologique ».
-- Version 2 (rendu pro, STYLE.md §4) : peu de props mais soignés, en vrais matériaux et en trois teintes.
-- Os et crânes fossiles en Limestone / Sandstone, caisses WoodPlanks à ferrures Metal, tonneaux cerclés,
-- jeeps d'explorateurs détaillées (Metal peint, pneus, arceau, roue de secours), rochers en Slate moussu,
-- campements sur une clairière de terre battue en Terrain, chantier de fouille (fosse, squelette, ruban), lanternes.
-- Emprise (CONTRAT §10) :
--   * couloirs entre les Bases (|x - c| ≤ 5 pour c = -56, 0, 56 et 20 ≤ |z| ≤ 66) : props rangés contre
--     les murs des Bases (3 ≤ |x - c| ≤ 5), l'allée centrale reste libre et rien n'y bloque (CanCollide false) ;
--   * anneau 21..28 de la Place : hors de l'allée en anneau, des torches, des liens vers Comptoir / Autel,
--     de la borne Dinodex et de l'arrivée des couloirs au nord ;
--   * de part et d'autre de la Nurserie et de la Fin du tapis (|z| 16..30) : un chantier de fouille
--     (squelette entouré de ruban) et un campement d'explorateurs.
-- Graine fixe : la map est identique à chaque démarrage. Budget : 400 parts.
local M = {}

-- réglages par défaut (remplaçables par Equilibrage.fossiles)
local DEFAUTS = {
	budget = 400,          -- parts au maximum pour ce constructeur
	graine = 1842,         -- année où le mot « dinosaure » est né
	gardeCouloir = 3,      -- distance minimale à l'axe d'un couloir (allée libre)
	demiCouloir = 5,       -- distance maximale à l'axe d'un couloir
	zCouloirMin = 20,
	zCouloirMax = 66,
	gardeEntree = 3,       -- recul depuis le bord intérieur des Bases (entrées)
	decalageProp = 4,      -- distance à l'axe où l'on pose les props d'un couloir
	anneauMin = 21,
	anneauMax = 28,
	margeAllee = 0.3,      -- marge au-delà du bord extérieur de l'allée en anneau
	zCoteMin = 16,
	zCoteMax = 30,
	gardeTorche = 6,       -- demi-angle (degrés) laissé libre autour des torches de la Place
	gardeLien = 22,        -- demi-angle laissé libre vers le Comptoir et l'Autel
	gardeNord = 48,        -- demi-angle laissé libre vers le nord (couloirs, traverse)
	gardeDinodex = 12,     -- demi-angle laissé libre au sud (borne Dinodex)
}

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- ===== réglages =====
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.fossiles) == "table" then
		reglages = ctx.Equilibrage.fossiles
	end
	local function reglage(cle)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return DEFAUTS[cle]
	end

	local BUDGET = reglage("budget")
	local rng = Outils.aleatoire(reglage("graine"))
	local compte = 0
	local collision = false -- collision des parts du prop en cours de construction

	local Style = ctx.Style

	-- ===== matériaux (repli sur SmoothPlastic si un nom manque) =====
	local function materiau(nom)
		local ok, m = pcall(function()
			return Enum.Material[nom]
		end)
		if ok and m then
			return m
		end
		return Enum.Material.SmoothPlastic
	end
	local M_OS = materiau("Limestone")
	local M_OS_VIEUX = materiau("Sandstone")
	local M_PLANCHES = materiau("WoodPlanks")
	local M_BOIS = materiau("Wood")
	local M_METAL = materiau("Metal")
	local M_GRILLE = materiau("DiamondPlate")
	local M_PNEU = materiau("Rubber")
	local M_CUIR = materiau("Leather")
	local M_TISSU = materiau("Fabric")
	local M_VERRE = materiau("Glass")
	local M_ROCHE = materiau("Slate")
	local M_MOUSSE = materiau("LeafyGrass")
	local M_TERRE = materiau("Ground")
	local NEON = Enum.Material.Neon

	-- ===== couleurs : trois teintes par matière (base, Charte.ombre, Charte.lumiere) =====
	local hex = Charte.hex
	local OS = hex("EFE6CF")            -- os fossile ivoire, lisible de loin
	local OS_LUMIERE = Charte.lumiere(OS)
	local OS_VIEUX = hex("D6B98A")      -- parties plus anciennes, grès
	local CREUX = hex("3A3340")         -- orbites
	local BOIS = hex("B8773D")          -- planches des caisses
	local BOIS_OMBRE = Charte.ombre(BOIS)
	local BOIS_CLAIR = Charte.lumiere(BOIS)
	local BOIS_FONCE = hex("6E4424")    -- manches, poteaux
	local TONNEAU = hex("9A5B2E")
	local TONNEAU_OMBRE = Charte.ombre(TONNEAU)
	local FER = hex("4A4F59")           -- ferrures, cerclages
	local FER_CLAIR = hex("A9AFB8")
	local JEEP = hex("7E9A48")          -- vert safari, métal peint
	local JEEP_OMBRE = Charte.ombre(JEEP)
	local JEEP_LUMIERE = Charte.lumiere(JEEP)
	local JEEP_BANDE = hex("F2E3B6")
	local CHASSIS = hex("2F3238")
	local PNEU = hex("26262B")
	local JANTE = hex("C9CDD3")
	local SIEGE = hex("7B4A2A")
	local JERRICAN = hex("C0392B")
	local VITRE = Charte.gemme
	local FEU = Charte.dore
	local ROCHE = hex("7E7A8A")
	local ROCHE_OMBRE = Charte.ombre(ROCHE)
	local ROCHE_CLAIRE = Charte.lumiere(ROCHE)
	local MOUSSE = hex("5FAE3C")
	local TERRE = hex("8E6444")
	local TERRE_FONCEE = Charte.ombre(TERRE)
	local RUBAN = hex("FFD23F")
	local POCHOIR = hex("C8412E")       -- marquage peint des caisses

	-- ===== fabrication des parts (budget compté ici) =====
	local function reglerPart(p, collide)
		pcall(function()
			p.CanTouch = false
			p.CanCollide = collide
			if not collide then
				p.CanQuery = false
			end
		end)
	end

	local function piece(genre, parent, props)
		if compte >= BUDGET then
			return nil
		end
		local fabrique = Outils[genre]
		if type(fabrique) ~= "function" then
			return nil
		end
		local collide = collision
		if props.CanCollide ~= nil then
			collide = props.CanCollide
			props.CanCollide = nil
		end
		local ok, p = pcall(fabrique, parent, props)
		if not ok or not p then
			return nil
		end
		compte = compte + 1
		reglerPart(p, collide)
		return p
	end
	local function bloc(m, props) return piece("bloc", m, props) end
	local function coin(m, props) return piece("coin", m, props) end
	local function cylindre(m, props) return piece("cylindre", m, props) end
	local function boule(m, props) return piece("boule", m, props) end

	-- dalle à liseré en relief (Outils.dalleBordee, 2 parts) ; repli sur un simple bloc
	local function dalle(m, props, bord, couleurBord, collide)
		if collide == nil then
			collide = collision
		end
		if type(Outils.dalleBordee) ~= "function" or compte + 2 > BUDGET then
			local simple = {}
			for k, v in pairs(props) do
				if k ~= "MaterialBord" then
					simple[k] = v
				end
			end
			simple.CanCollide = collide
			return bloc(m, simple)
		end
		local ok, d, l = pcall(Outils.dalleBordee, m, props, bord, couleurBord)
		if not ok then
			return nil
		end
		for _, p in ipairs({ d, l }) do
			if p then
				compte = compte + 1
				reglerPart(p, collide)
			end
		end
		return d
	end

	-- repère local : décalage (x, y, z) puis rotation (degrés)
	local function ici(cf, x, y, z, rx, ry, rz)
		return cf * CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
	end
	local function V(x, y, z)
		return Vector3.new(x, y, z)
	end

	-- ===== les props =====
	-- chaque fonction reçoit le modèle, le CFrame au sol (regard vers -Z local) et une échelle
	local fabriques = {}

	-- os fossile couché le long de Z local, à demi enterré : fût, deux collets en grès, quatre condyles (7 parts)
	function fabriques.os(m, cf, s)
		local L = 3.0 * s
		local y = 0.4 * s
		cylindre(m, { Name = "Fut", Size = V(L, 0.56 * s, 0.56 * s), CFrame = ici(cf, 0, y, 0, 0, 90, 0), Color = OS, Material = M_OS })
		for _, sz in ipairs({ -1, 1 }) do
			cylindre(m, {
				Name = "Col",
				Size = V(0.55 * s, 0.74 * s, 0.74 * s),
				CFrame = ici(cf, 0, y, sz * (L / 2 - 0.3 * s), 0, 90, 0),
				Color = OS_VIEUX,
				Material = M_OS_VIEUX,
			})
			for _, sx in ipairs({ -1, 1 }) do
				boule(m, {
					Name = "Condyle",
					Size = V(0.92 * s, 0.92 * s, 0.92 * s),
					CFrame = ici(cf, sx * 0.3 * s, y + 0.03 * s, sz * L / 2),
					Color = OS_LUMIERE,
					Material = M_OS,
				})
			end
		end
	end

	-- crâne fossile de théropode qui regarde vers -Z : boîte crânienne et front en pente, museau et chanfrein,
	-- mâchoire entrouverte en grès, orbites et fenêtres antorbitaires, dents (13 parts)
	function fabriques.crane(m, cf, s)
		bloc(m, { Name = "Boite", Size = V(2.2 * s, 1.5 * s, 2.0 * s), CFrame = ici(cf, 0, 0.75 * s, 0.55 * s), Color = OS, Material = M_OS })
		coin(m, { Name = "Front", Size = V(2.2 * s, 0.5 * s, 2.0 * s), CFrame = ici(cf, 0, 1.75 * s, 0.55 * s), Color = OS_LUMIERE, Material = M_OS })
		bloc(m, { Name = "Museau", Size = V(1.3 * s, 0.75 * s, 2.0 * s), CFrame = ici(cf, 0, 0.85 * s, -1.45 * s), Color = OS, Material = M_OS })
		coin(m, { Name = "Chanfrein", Size = V(1.3 * s, 0.3 * s, 2.0 * s), CFrame = ici(cf, 0, 1.375 * s, -1.45 * s), Color = OS_LUMIERE, Material = M_OS })
		bloc(m, {
			Name = "Machoire",
			Size = V(1.15 * s, 0.3 * s, 2.2 * s),
			CFrame = ici(cf, 0, 0.2 * s, -1.3 * s, -5, 0, 0),
			Color = OS_VIEUX,
			Material = M_OS_VIEUX,
		})
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Orbite",
				Size = V(0.14 * s, 0.6 * s, 0.7 * s),
				CFrame = ici(cf, sx * 1.08 * s, 1.05 * s, -0.05 * s),
				Color = CREUX,
				Material = M_ROCHE,
			})
			bloc(m, {
				Name = "Fenetre",
				Size = V(0.12 * s, 0.4 * s, 0.62 * s),
				CFrame = ici(cf, sx * 0.64 * s, 0.9 * s, -1.4 * s),
				Color = CREUX,
				Material = M_ROCHE,
			})
			for _, z in ipairs({ -2.05, -1.2 }) do
				bloc(m, {
					Name = "Dent",
					Size = V(0.16 * s, 0.24 * s, 0.16 * s),
					CFrame = ici(cf, sx * 0.5 * s, 0.42 * s, z * s),
					Color = Charte.creme,
					Material = M_OS,
				})
			end
		end
	end

	-- crâne exposé sur un socle d'ardoise à plinthe (15 parts)
	function fabriques.exposition(m, cf, s)
		dalle(m, {
			Name = "Socle",
			Size = V(2.2 * s, 0.5 * s, 3.6 * s),
			CFrame = ici(cf, 0, 0.25 * s, 0),
			Color = ROCHE,
			Material = M_ROCHE,
			MaterialBord = M_ROCHE,
		}, 0.15 * s, ROCHE_OMBRE)
		fabriques.crane(m, ici(cf, 0, 0.5 * s, 0.26 * s), 0.7 * s)
	end

	-- caisse d'expédition en planches : cadres haut et bas, cornières en fer, traverse, marquage « FRAGILE » (8 parts)
	function fabriques.caisse(m, cf, s, sansMarquage)
		local corps = bloc(m, { Name = "Caisse", Size = V(2 * s, 2 * s, 2 * s), CFrame = ici(cf, 0, s, 0), Color = BOIS, Material = M_PLANCHES })
		for _, y in ipairs({ 0.11, 1.89 }) do
			bloc(m, { Name = "Cadre", Size = V(2.1 * s, 0.22 * s, 2.1 * s), CFrame = ici(cf, 0, y * s, 0), Color = BOIS_OMBRE, Material = M_BOIS })
		end
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				bloc(m, {
					Name = "Ferrure",
					Size = V(0.28 * s, 2.04 * s, 0.28 * s),
					CFrame = ici(cf, sx * 0.97 * s, 1.02 * s, sz * 0.97 * s),
					Color = FER,
					Material = M_METAL,
				})
			end
		end
		bloc(m, {
			Name = "Traverse",
			Size = V(0.1 * s, 2.2 * s, 0.26 * s),
			CFrame = ici(cf, 1.03 * s, s, 0, 45, 0, 0),
			Color = BOIS_OMBRE,
			Material = M_BOIS,
		})
		if corps and not sansMarquage then
			pcall(function()
				-- marquage au pochoir, en biais, cerné de noir (grammaire « simulateur »)
				local t = Outils.texte(corps, "Front", "FRAGILE", { couleur = POCHOIR })
				t.AnchorPoint = Vector2.new(0.5, 0.5)
				t.Position = UDim2.fromScale(0.5, 0.5)
				t.Size = UDim2.fromScale(0.84, 0.3)
				t.Rotation = -8
				if Style then
					t.Font = Style.policeTitre
					Style.contour(t, 2)
				end
			end)
		end
	end

	-- deux caisses empilées, la seconde plus petite et un peu tournée (16 parts)
	function fabriques.pile(m, cf, s)
		fabriques.caisse(m, cf, s)
		fabriques.caisse(m, ici(cf, 0.08 * s, 2.0 * s, 0.05 * s, 0, 18, 0), 0.62 * s, true)
	end

	-- tonneau debout, bombé (trois tronçons), quatre cercles de fer, couvercle en planches (8 parts)
	function fabriques.tonneau(m, cf, s)
		local function troncon(nom, y, h, d, couleur, mat)
			cylindre(m, { Name = nom, Size = V(h, d, d), CFrame = ici(cf, 0, y, 0, 0, 0, 90), Color = couleur, Material = mat })
		end
		troncon("Bas", 0.3 * s, 0.6 * s, 1.5 * s, TONNEAU_OMBRE, M_BOIS)
		troncon("Ventre", 1.1 * s, 1.1 * s, 1.7 * s, TONNEAU, M_BOIS)
		troncon("Haut", 1.9 * s, 0.6 * s, 1.5 * s, TONNEAU, M_BOIS)
		for _, e in ipairs({ { 0.28, 1.58 }, { 0.72, 1.76 }, { 1.48, 1.76 }, { 1.92, 1.58 } }) do
			troncon("Cercle", e[1] * s, 0.14 * s, e[2] * s, FER, M_METAL)
		end
		troncon("Couvercle", 2.2 * s + 0.03, 0.06, 1.3 * s, BOIS_CLAIR, M_PLANCHES)
	end

	-- jeep d'explorateurs, capot vers -Z : métal peint vert safari, châssis et pare-chocs sombres, calandre,
	-- phares, ailes, pneus et jantes, pare-brise incliné, sièges en cuir, volant, arceau, roue de secours,
	-- jerrican et caisse dans la benne (33 parts)
	function fabriques.jeep(m, cf, s)
		local function v(x, y, z) return V(x * s, y * s, z * s) end
		local function en(x, y, z, rx, ry, rz) return ici(cf, x * s, y * s, z * s, rx, ry, rz) end
		bloc(m, { Name = "Chassis", Size = v(2.4, 0.35, 4.9), CFrame = en(0, 0.78, -0.1), Color = CHASSIS, Material = M_METAL })
		bloc(m, { Name = "Carrosserie", Size = v(2.8, 0.95, 3.2), CFrame = en(0, 1.38, 0.7), Color = JEEP, Material = M_METAL })
		bloc(m, { Name = "Bande", Size = v(2.86, 0.16, 3.26), CFrame = en(0, 1.5, 0.7), Color = JEEP_BANDE, Material = M_METAL })
		bloc(m, { Name = "Capot", Size = v(2.5, 0.75, 1.75), CFrame = en(0, 1.3, -1.72), Color = JEEP_LUMIERE, Material = M_METAL })
		bloc(m, { Name = "Calandre", Size = v(2.2, 0.62, 0.12), CFrame = en(0, 1.25, -2.64), Color = CHASSIS, Material = M_GRILLE })
		bloc(m, { Name = "ParechocsAvant", Size = v(3.0, 0.3, 0.3), CFrame = en(0, 0.78, -2.75), Color = CHASSIS, Material = M_METAL })
		bloc(m, { Name = "ParechocsArriere", Size = v(2.9, 0.3, 0.3), CFrame = en(0, 0.78, 2.4), Color = CHASSIS, Material = M_METAL })
		for _, sx in ipairs({ -1, 1 }) do
			cylindre(m, { Name = "Phare", Size = v(0.12, 0.45, 0.45), CFrame = en(sx * 0.82, 1.38, -2.72, 0, 90, 0), Color = FEU, Material = NEON })
			bloc(m, { Name = "Siege", Size = v(0.9, 0.95, 0.28), CFrame = en(sx * 0.65, 2.1, 1.05), Color = SIEGE, Material = M_CUIR })
			bloc(m, { Name = "Montant", Size = v(0.18, 1.15, 0.18), CFrame = en(sx * 1.25, 2.4, 1.75), Color = CHASSIS, Material = M_METAL })
			for _, z in ipairs({ -1.7, 1.5 }) do
				cylindre(m, { Name = "Pneu", Size = v(0.62, 1.4, 1.4), CFrame = en(sx * 1.33, 0.7, z), Color = PNEU, Material = M_PNEU })
				cylindre(m, { Name = "Jante", Size = v(0.66, 0.7, 0.7), CFrame = en(sx * 1.33, 0.7, z), Color = JANTE, Material = M_METAL })
				bloc(m, { Name = "Aile", Size = v(0.6, 0.2, 1.75), CFrame = en(sx * 1.38, 1.5, z), Color = JEEP_OMBRE, Material = M_METAL })
			end
		end
		bloc(m, {
			Name = "PareBrise",
			Size = v(2.5, 0.85, 0.08),
			CFrame = en(0, 2.3, -0.85, 12, 0, 0),
			Color = VITRE,
			Material = M_VERRE,
			Transparency = 0.45,
			CastShadow = false,
		})
		bloc(m, { Name = "CadrePareBrise", Size = v(2.7, 0.14, 0.18), CFrame = en(0, 2.78, -0.75, 12, 0, 0), Color = JEEP, Material = M_METAL })
		cylindre(m, { Name = "Volant", Size = v(0.08, 0.62, 0.62), CFrame = en(-0.65, 2.02, -0.35, -35, 90, 0), Color = CHASSIS, Material = M_METAL })
		bloc(m, { Name = "Arceau", Size = v(2.68, 0.18, 0.18), CFrame = en(0, 3.0, 1.75), Color = CHASSIS, Material = M_METAL })
		cylindre(m, { Name = "Secours", Size = v(0.5, 1.2, 1.2), CFrame = en(0, 1.55, 2.6, 0, 90, 0), Color = PNEU, Material = M_PNEU })
		cylindre(m, { Name = "JanteSecours", Size = v(0.54, 0.6, 0.6), CFrame = en(0, 1.55, 2.6, 0, 90, 0), Color = JANTE, Material = M_METAL })
		bloc(m, { Name = "Jerrican", Size = v(0.4, 0.7, 0.55), CFrame = en(0.8, 2.2, 2.0), Color = JERRICAN, Material = M_METAL })
		bloc(m, { Name = "Cargaison", Size = v(0.9, 0.6, 0.7), CFrame = en(-0.55, 2.15, 1.95), Color = BOIS, Material = M_PLANCHES })
	end

	-- lanterne suspendue à un poteau de bois sur socle de pierre (la lueur respire doucement) (6 parts)
	function fabriques.lanterne(m, cf, s)
		bloc(m, { Name = "Socle", Size = V(0.8 * s, 0.3 * s, 0.8 * s), CFrame = ici(cf, 0, 0.15 * s, 0.45 * s, 0, 20, 0), Color = ROCHE, Material = M_ROCHE })
		cylindre(m, { Name = "Poteau", Size = V(3.0 * s, 0.3 * s, 0.3 * s), CFrame = ici(cf, 0, 1.6 * s, 0.45 * s, 0, 0, 90), Color = BOIS_FONCE, Material = M_BOIS })
		bloc(m, { Name = "Bras", Size = V(0.14 * s, 0.14 * s, 1.05 * s), CFrame = ici(cf, 0, 3.05 * s, 0), Color = FER, Material = M_METAL })
		bloc(m, { Name = "Culot", Size = V(0.6 * s, 0.12 * s, 0.6 * s), CFrame = ici(cf, 0, 2.12 * s, -0.45 * s), Color = FER, Material = M_METAL })
		local verre = bloc(m, {
			Name = "Verre",
			Size = V(0.5 * s, 0.62 * s, 0.5 * s),
			CFrame = ici(cf, 0, 2.49 * s, -0.45 * s),
			Color = FEU,
			Material = NEON,
			CastShadow = false,
		})
		bloc(m, { Name = "Chapeau", Size = V(0.72 * s, 0.18 * s, 0.72 * s), CFrame = ici(cf, 0, 2.89 * s, -0.45 * s), Color = FER, Material = M_METAL })
		if verre then
			pcall(function()
				local l = Outils.lumiere(verre, { Range = 12, Brightness = 0.9, Color = FEU })
				l.Shadows = false
				Outils.animer(verre, "pulse", 0.6)
			end)
		end
	end

	-- pelle plantée dans un tas de terre retournée, un peu penchée (5 parts)
	function fabriques.pelle(m, cf, s)
		boule(m, { Name = "Tas", Size = V(1.9 * s, 1.9 * s, 1.9 * s), CFrame = ici(cf, 0, -0.5 * s, 0), Color = TERRE, Material = M_TERRE })
		boule(m, { Name = "Motte", Size = V(1.1 * s, 1.1 * s, 1.1 * s), CFrame = ici(cf, 0.8 * s, -0.3 * s, 0.5 * s), Color = TERRE_FONCEE, Material = M_TERRE })
		local penche = ici(cf, 0, 0, 0, 14, 0, 0)
		cylindre(m, { Name = "Manche", Size = V(2.5 * s, 0.2 * s, 0.2 * s), CFrame = ici(penche, 0, 1.65 * s, 0, 0, 0, 90), Color = BOIS, Material = M_BOIS })
		bloc(m, { Name = "Lame", Size = V(0.75 * s, 0.85 * s, 0.08 * s), CFrame = ici(penche, 0, 0.35 * s, 0), Color = FER_CLAIR, Material = M_METAL })
		bloc(m, { Name = "Poignee", Size = V(0.55 * s, 0.14 * s, 0.14 * s), CFrame = ici(penche, 0, 2.95 * s, 0), Color = BOIS_FONCE, Material = M_BOIS })
	end

	-- rocher d'ardoise à demi enterré : deux blocs croisés, chapeau plus clair et mousse (4 parts)
	function fabriques.rocher(m, cf, s)
		-- deux blocs croisés à 45° (silhouette à facettes, jamais une « boîte »), un peu inclinés et enterrés
		local base = ici(cf, 0, 0.3 * s, 0, rng:NextNumber(-10, 10), rng:NextNumber(0, 360), rng:NextNumber(-10, 10))
		bloc(m, { Name = "Rocher", Size = V(1.7 * s, 1.1 * s, 1.4 * s), CFrame = base, Color = ROCHE, Material = M_ROCHE })
		bloc(m, {
			Name = "Facette",
			Size = V(1.45 * s, 0.95 * s, 1.5 * s),
			CFrame = base * CFrame.new(0, -0.05 * s, 0) * CFrame.Angles(0, math.rad(45), 0),
			Color = ROCHE_OMBRE,
			Material = M_ROCHE,
		})
		-- chapeau plus clair et tourné, avec une touffe de mousse dessus
		local cfChapeau = base * CFrame.new(0.12 * s, 0.68 * s, -0.08 * s)
			* CFrame.Angles(math.rad(rng:NextNumber(-12, 12)), math.rad(rng:NextNumber(10, 80)), math.rad(rng:NextNumber(-12, 12)))
		bloc(m, { Name = "Chapeau", Size = V(1.0 * s, 0.5 * s, 0.9 * s), CFrame = cfChapeau, Color = ROCHE_CLAIRE, Material = M_ROCHE })
		bloc(m, {
			Name = "Mousse",
			Size = V(0.55 * s, 0.08 * s, 0.45 * s),
			CFrame = cfChapeau * CFrame.new(0.15 * s, 0.25 * s, -0.1 * s) * CFrame.Angles(0, math.rad(35), 0),
			Color = MOUSSE,
			Material = M_MOUSSE,
		})
	end

	-- squelette en cours de fouille, crâne vers -Z : fosse de terre retournée à bourrelet, vertèbres,
	-- côtes, crâne, queue, et ruban de chantier tendu sur piquets (40 parts)
	function fabriques.squelette(m, cf, s)
		dalle(m, {
			Name = "Fosse",
			Size = V(4.0 * s, 0.14, 12.6 * s),
			CFrame = ici(cf, 0, 0.07, -0.55 * s),
			Color = TERRE,
			Material = M_TERRE,
			MaterialBord = M_TERRE,
			CastShadow = false,
		}, 0.3, TERRE_FONCEE, false)
		for k = 0, 5 do
			local couleur, mat = OS, M_OS
			if k % 2 == 1 then
				couleur, mat = OS_VIEUX, M_OS_VIEUX
			end
			boule(m, { Name = "Vertebre", Size = V(0.72 * s, 0.72 * s, 0.72 * s), CFrame = ici(cf, 0, 0.36 * s, (-3 + k * 1.2) * s), Color = couleur, Material = mat })
		end
		for k = 0, 3 do
			local longueur = (1.9 - 0.2 * k) * s
			for _, cote in ipairs({ -1, 1 }) do
				bloc(m, {
					Name = "Cote",
					Size = V(0.22 * s, longueur, 0.26 * s),
					CFrame = ici(cf, cote * 0.75 * s, longueur / 2 - 0.1 * s, (-2.1 + k * 1.2) * s, 0, 0, -cote * 22),
					Color = OS,
					Material = M_OS,
				})
			end
		end
		fabriques.crane(m, ici(cf, 0, 0.14, -4.4 * s), 0.9 * s)
		local tailles = { 0.65, 0.5, 0.4 }
		local zQueue = { 3.9, 4.6, 5.2 }
		for i = 1, 3 do
			boule(m, {
				Name = "Queue",
				Size = V(tailles[i] * s, tailles[i] * s, tailles[i] * s),
				CFrame = ici(cf, 0, 0.2 * s, zQueue[i] * s),
				Color = OS_VIEUX,
				Material = M_OS_VIEUX,
			})
		end
		-- ruban de chantier : on peut l'enjamber, il ne bloque personne
		local x0, zA, zB = 2.4 * s, -7.4 * s, 6.3 * s
		for _, sx in ipairs({ -1, 1 }) do
			for _, z in ipairs({ zA, zB }) do
				bloc(m, { Name = "Piquet", Size = V(0.3, 1.0, 0.3), CFrame = ici(cf, sx * x0, 0.5, z), Color = BOIS_FONCE, Material = M_BOIS, CanCollide = false })
			end
			bloc(m, {
				Name = "Ruban",
				Size = V(0.12, 0.14, zB - zA),
				CFrame = ici(cf, sx * x0, 0.85, (zA + zB) / 2),
				Color = RUBAN,
				Material = M_TISSU,
				CanCollide = false,
				CastShadow = false,
			})
		end
		for _, z in ipairs({ zA, zB }) do
			bloc(m, {
				Name = "Ruban",
				Size = V(2 * x0, 0.14, 0.12),
				CFrame = ici(cf, 0, 0.85, z),
				Color = RUBAN,
				Material = M_TISSU,
				CanCollide = false,
				CastShadow = false,
			})
		end
	end

	-- nom du modèle, coût en parts et demi-emprise au sol (a sur X local, b sur Z local) selon l'échelle
	local PROPS = {
		os = { nom = "Os", cout = 7, a = 0.76, b = 1.96 },
		crane = { nom = "Crane", cout = 13, a = 1.2, b = 2.5 },
		exposition = { nom = "Exposition", cout = 15, a = 1.25, b = 1.95 },
		caisse = { nom = "Caisse", cout = 8, a = 1.11, b = 1.11 },
		pile = { nom = "Caisses", cout = 16, a = 1.11, b = 1.11 },
		tonneau = { nom = "Tonneau", cout = 8, a = 0.88, b = 0.88 },
		jeep = { nom = "Jeep", cout = 33, a = 1.7, b = 2.9 },
		lanterne = { nom = "Lanterne", cout = 6, a = 0.4, b = 0.85 },
		pelle = { nom = "Pelle", cout = 5, a = 1.35, b = 1.35 },
		rocher = { nom = "Rocher", cout = 4, a = 1.2, b = 1.2 },
		squelette = { nom = "Squelette", cout = 40, a = 2.55, b = 7.55 },
	}

	-- demi-étendue d'un rectangle (a, b) tourné de ry degrés, mesurée selon la direction (dx, dz)
	local function demiEtendue(a, b, ry, dx, dz)
		local r = math.rad(ry)
		local c, sn = math.cos(r), math.sin(r)
		-- axes locaux X et Z exprimés dans le monde : (c, -sn) et (sn, c)
		return a * math.abs(c * dx - sn * dz) + b * math.abs(sn * dx + c * dz)
	end

	-- ===== emprises =====
	-- couloirs
	local xCouloirs = {}
	if Plan.decor and type(Plan.decor.couloirs) == "table" then
		for _, c in ipairs(Plan.decor.couloirs) do
			table.insert(xCouloirs, c.X)
		end
	end
	if #xCouloirs == 0 then
		xCouloirs = { -56, 0, 56 }
	end
	local bordBases = 18
	if Plan.base and type(Plan.base.bordInterieur) == "number" then
		bordBases = Plan.base.bordInterieur
	end
	local GARDE = reglage("gardeCouloir")
	local DEMI = reglage("demiCouloir")
	local Z_DEBUT = math.max(reglage("zCouloirMin"), bordBases + reglage("gardeEntree"))
	local Z_FIN = reglage("zCouloirMax")

	local function dansCouloir(x, z, hx, hz)
		for _, c in ipairs(xCouloirs) do
			local d = math.abs(x - c)
			if d - hx >= GARDE and d + hx <= DEMI and math.abs(z) - hz >= Z_DEBUT and math.abs(z) + hz <= Z_FIN then
				return true
			end
		end
		return false
	end

	-- anneau de la Place
	local infoPlace = Plan.place or {}
	local PC = infoPlace.centre or Vector3.new(0, 0, 100)
	local bordAllee = 24
	local sol = ctx.Equilibrage and ctx.Equilibrage.sol
	if type(sol) == "table" and type(sol.rayonAnneau) == "number" and type(sol.largeurAnneau) == "number" then
		bordAllee = sol.rayonAnneau + sol.largeurAnneau / 2
	end
	local R_MIN = math.max(reglage("anneauMin"), bordAllee + reglage("margeAllee"))
	local R_MAX = reglage("anneauMax")

	local function angleVers(p)
		return math.deg(math.atan2(p.Z - PC.Z, p.X - PC.X)) % 360
	end
	-- directions à laisser libres : { angle, demi-angle }
	local interdits = {}
	local gardeLien = reglage("gardeLien")
	if Plan.comptoir and Plan.comptoir.centre then
		table.insert(interdits, { angleVers(Plan.comptoir.centre), gardeLien })
	end
	if Plan.autel and Plan.autel.centre then
		table.insert(interdits, { angleVers(Plan.autel.centre), gardeLien })
	end
	table.insert(interdits, { angleVers(Vector3.new(PC.X, 0, 0)), reglage("gardeNord") }) -- vers le Tapis
	table.insert(interdits, { angleVers(Vector3.new(PC.X, 0, PC.Z + 1)), reglage("gardeDinodex") }) -- borne au sud
	-- torches de la Place (Builders/Lumieres)
	local pasTorche, decalageTorche = 45, 22.5
	local lum = ctx.Equilibrage and ctx.Equilibrage.lumieres
	if type(lum) == "table" then
		if type(lum.placePas) == "number" and lum.placePas > 0 then
			pasTorche = lum.placePas
		end
		if type(lum.placeDecalage) == "number" then
			decalageTorche = lum.placeDecalage
		end
	end
	local angleTorche = 0
	while angleTorche < 360 - 0.01 do
		table.insert(interdits, { (angleTorche + decalageTorche) % 360, reglage("gardeTorche") })
		angleTorche = angleTorche + pasTorche
	end

	local function ecartAngle(a, b)
		return math.abs(((a - b + 180) % 360) - 180)
	end

	local function dansAnneau(x, z, ry, a, b)
		local dx, dz = x - PC.X, z - PC.Z
		local d = math.sqrt(dx * dx + dz * dz)
		if d < 1 then
			return false
		end
		local ux, uz = dx / d, dz / d
		local radial = demiEtendue(a, b, ry, ux, uz)
		local tangent = demiEtendue(a, b, ry, -uz, ux)
		if d - radial < R_MIN or d + radial > R_MAX then
			return false
		end
		local theta = math.deg(math.atan2(dz, dx)) % 360
		local demi = math.deg(tangent / d)
		for _, interdit in ipairs(interdits) do
			if ecartAngle(theta, interdit[1]) < interdit[2] + demi then
				return false
			end
		end
		return true
	end

	-- côtés de la Nurserie et de la Fin du tapis
	local cotes = {}
	local nurserie = Plan.nurserie or { centre = Vector3.new(-128, 0, 0), rayon = 14 }
	local finTapis = Plan.finTapis or { centre = Vector3.new(128, 0, 0), rayon = 14 }
	table.insert(cotes, { centre = nurserie.centre, rayon = nurserie.rayon or 14 })
	table.insert(cotes, { centre = finTapis.centre, rayon = finTapis.rayon or 14 })
	local Z_COTE_MIN = reglage("zCoteMin")
	local Z_COTE_MAX = reglage("zCoteMax")

	local function dansCote(x, z, hx, hz)
		for _, cote in ipairs(cotes) do
			local dz = math.abs(z - cote.centre.Z)
			if math.abs(x - cote.centre.X) + hx <= cote.rayon and dz - hz >= Z_COTE_MIN and dz + hz <= Z_COTE_MAX then
				return true
			end
		end
		return false
	end

	-- ===== pose d'un prop (emprise et budget vérifiés avant de construire) =====
	local erreurSignalee = false
	local function poser(zone, nom, x, z, ry, s)
		local def = PROPS[nom]
		local fabrique = fabriques[nom]
		if not def or not fabrique then
			return nil
		end
		s = s or 1
		ry = ry or 0
		if compte + def.cout > BUDGET then
			return nil
		end
		local a, b = def.a * s, def.b * s
		local permis
		if zone.genre == "couloir" then
			permis = dansCouloir(x, z, demiEtendue(a, b, ry, 1, 0), demiEtendue(a, b, ry, 0, 1))
		elseif zone.genre == "anneau" then
			permis = dansAnneau(x, z, ry, a, b)
		else
			permis = dansCote(x, z, demiEtendue(a, b, ry, 1, 0), demiEtendue(a, b, ry, 0, 1))
		end
		if not permis then
			return nil
		end
		collision = zone.collision
		local m = Outils.modele(zone.dossier, def.nom)
		local cf = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(ry), 0)
		local ok, err = pcall(fabrique, m, cf, s)
		if not ok and not erreurSignalee then
			erreurSignalee = true
			warn("[Dino] Fossiles, " .. def.nom .. " : " .. tostring(err))
		end
		if #m:GetChildren() == 0 then
			m:Destroy()
			return nil
		end
		return m
	end

	-- ===== 1. les couloirs entre les Bases =====
	-- collision coupée : les courses-poursuites de vol ne s'accrochent jamais au décor.
	-- Couloirs dégagés : par moitié de couloir, une seule composition collée au mur d'une Base,
	-- soit un crâne tourné vers le Tapis, soit un os à demi enterré au pied d'un rocher moussu.
	local zoneCouloir = { genre = "couloir", collision = false, dossier = Outils.dossier(dossier, "Couloirs") }
	local DX = reglage("decalageProp")

	for i, c in ipairs(xCouloirs) do
		for _, sens in ipairs({ 1, -1 }) do
			local cote = sens
			local x = c + cote * DX
			if (i + (sens + 1) / 2) % 2 == 0 then
				-- le crâne regarde vers le Tapis (z = 0)
				local ryCrane = 0
				if sens == -1 then
					ryCrane = 180
				end
				poser(zoneCouloir, "crane", x, sens * 46, ryCrane, 0.8)
			else
				poser(zoneCouloir, "os", x, sens * 38, 0, 1.3)
				poser(zoneCouloir, "rocher", x, sens * 41.7, 0, 0.8)
			end
		end
	end

	-- ===== 2. l'anneau de la Place =====
	local zoneAnneau = { genre = "anneau", collision = true, dossier = Outils.dossier(dossier, "Place") }
	local rPose = (R_MIN + R_MAX) / 2
	-- { prop, angle (degrés, x = cos, z = sin), échelle } ; chaque prop est posé le long de l'anneau
	local ANNEAU = {
		{ "pile", 36.5, 1 },
		{ "exposition", 45.5, 1 },
		{ "os", 55.5, 1.1 },
		{ "tonneau", 123, 1 },
		{ "tonneau", 127.2, 1 },
		{ "caisse", 133.5, 0.9 },
		{ "rocher", 146, 0.8 },
		{ "pelle", 214, 1 },
	}
	for _, e in ipairs(ANNEAU) do
		local theta = e[2]
		local t = math.rad(theta)
		local x = PC.X + rPose * math.cos(t)
		local z = PC.Z + rPose * math.sin(t)
		-- axe Z local tangent à l'anneau
		poser(zoneAnneau, e[1], x, z, 180 - theta, e[3])
	end

	-- ===== 3. les côtés de la Nurserie et de la Fin du tapis =====
	local zMilieu = (Z_COTE_MIN + Z_COTE_MAX) / 2

	-- chantier de fouille : squelette dans sa fosse sous ruban, lanterne, pelle et caisse autour
	local function chantier(zone, cx, sgn, ryCorps)
		local function en(lx, lz)
			return cx + lx, sgn * (zMilieu + lz)
		end
		local x, z = en(0, 0)
		local squelette = poser(zone, "squelette", x, z, ryCorps, 1)
		-- petite étiquette flottante façon simulateur au-dessus du chantier
		if squelette and Style and type(Style.etiquette) == "function" then
			local support = squelette:FindFirstChild("Boite") or squelette:FindFirstChildWhichIsA("BasePart")
			if support then
				pcall(function()
					Style.etiquette(support, {
						{ texte = "🦴 FOUILLES", titre = true, couleur = Style.couleurs.revenu },
					}, { Name = "EtiquetteFouilles", largeur = 9, hauteurLigne = 2, StudsOffset = Vector3.new(0, 4, 0), MaxDistance = 80 })
				end)
			end
		end
		x, z = en(9.5, -4.5)
		poser(zone, "lanterne", x, z, 90, 1)
		x, z = en(-10.5, 4.2)
		poser(zone, "pelle", x, z, rng:NextNumber(0, 360), 1)
		x, z = en(10.5, 4)
		poser(zone, "caisse", x, z, rng:NextNumber(-25, 25), 1)
	end

	-- campement : clairière de terre battue (Terrain), jeep, caisses empilées, tonneau, lanterne et gros rocher
	local function campement(zone, cx, sgn)
		local function en(lx, lz)
			return cx + lx, sgn * (zMilieu + lz)
		end
		-- clairière : deux disques de terre (Ground) au ras de l'herbe, une couche de voxels
		if type(Outils.terrainCylindre) == "function" then
			for _, d in ipairs({ { -2, 0, 6.5 }, { 5, 0.5, 5 } }) do
				local x, z = en(d[1], d[2])
				local rayon = d[3]
				local dansZone = math.abs(x - cx) + rayon <= 14 and math.abs(z) - rayon >= Z_COTE_MIN and math.abs(z) + rayon <= Z_COTE_MAX
				if dansZone then
					Outils.terrainCylindre(CFrame.new(x, 0.05 - 2.025, z), 4.05, rayon, Enum.Material.Ground)
				end
			end
		end
		local x, z = en(-6, 0)
		poser(zone, "jeep", x, z, 90, 1.15)
		x, z = en(-1.2, -3)
		poser(zone, "lanterne", x, z, 0, 1)
		x, z = en(1.8, -3.2)
		poser(zone, "pile", x, z, rng:NextNumber(-20, 20), 1)
		x, z = en(1.5, 3.3)
		poser(zone, "tonneau", x, z, 0, 1)
		x, z = en(9, 1.5)
		poser(zone, "rocher", x, z, 0, 1.7)
	end

	local zoneNurserie = { genre = "cote", collision = true, dossier = Outils.dossier(dossier, "Nurserie") }
	local zoneFin = { genre = "cote", collision = true, dossier = Outils.dossier(dossier, "FinTapis") }
	chantier(zoneNurserie, nurserie.centre.X, -1, 90)
	campement(zoneNurserie, nurserie.centre.X, 1)
	campement(zoneFin, finTapis.centre.X, -1)
	chantier(zoneFin, finTapis.centre.X, 1, -90)

	dossier:SetAttribute("Parts", compte)
end

return M
