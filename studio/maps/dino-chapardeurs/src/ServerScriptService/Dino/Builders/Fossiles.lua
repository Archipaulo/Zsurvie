-- Constructeur Fossiles : petits props de décor (4 studs de haut au plus) façon « expédition paléontologique ».
-- Version 2 (rendu pro, STYLE.md §4) : peu de props mais soignés, en vrais matériaux et en trois teintes.
-- Os et crânes fossiles en Limestone / Sandstone, caisses WoodPlanks à ferrures Metal, tonneaux cerclés,
-- jeeps d'explorateurs détaillées (Metal peint, pneus, arceau, roue de secours), rochers en Slate moussu,
-- campements sur une clairière de terre battue en Terrain, chantier de fouille (fosse, squelette, ruban), lanternes.
-- Feu de camp aux flammes Neon qui palpitent (étincelles), éclats d'ambre qui flottent et scintillent.
-- Emprise (CONTRAT §10, plan v2 « plus d'air ») — tout est lu dans Plan, aucune coordonnée en dur :
--   * allées entre les Bases (Plan.allees) : props rangés dans une bande de bordure contre les murs des Bases,
--     le milieu de l'allée reste libre (≥ 13 studs) et rien n'y bloque (CanCollide false) ; une composition
--     et une lanterne par demi-allée, jamais à l'entrée côté promenade ;
--   * anneau de la Place, sur l'HERBE au-delà de l'anneau de sable (Plan.place.anneau, la même valeur que Sol) :
--     r = rayon + anneau + 1 .. rayon + anneau + 5 (29..33), dans les secteurs libres (hors liens vers Comptoir /
--     Autel, sentier de la rivière, allée du nord) ;
--   * de part et d'autre de la Nurserie et de la Grande Porte (|x - cx| <= rayon, rayon + 3 <= |dz| <= rayon + 27),
--     au-delà de la demi-lune de sable qui termine la promenade : un chantier de fouille (squelette sous ruban,
--     ambre) et un campement d'explorateurs (jeep, feu de camp), centrés à promenade.zMax + 8 (35) de l'axe du Tapis.
--   Anneau et côtés : chaque prop (et chaque clairière de terre) garde au moins `margeSable` d'herbe entre lui et
--   les chemins de sable de Sol (galets de bordure compris), recalculés ici depuis Plan : jamais sur un passage.
-- Graine fixe : la map est identique à chaque démarrage. Budget : 480 parts (≈ 460 utilisées).
local M = {}

-- réglages par défaut (remplaçables par Equilibrage.fossiles) : distances et marges, jamais de position
local DEFAUTS = {
	budget = 480,          -- parts au maximum pour ce constructeur
	graine = 1842,         -- année où le mot « dinosaure » est né
	bandeAllee = 4.5,      -- profondeur de la bande de bordure (depuis le mur d'une Base) où l'on pose
	jeuMur = 0.3,          -- jeu laissé contre le mur des Bases
	retraitMur = 2.2,      -- distance du mur au centre d'une composition
	retraitLanterne = 1.4, -- distance du mur au poteau d'une lanterne
	gardeEntree = 4,       -- rien à moins de ... de l'entrée d'une allée (côté promenade)
	gardeFond = 2,         -- ... ni du fond de l'allée (chemin de ronde)
	fractionPres = 0.33,   -- position des compositions le long de l'allée (0 = promenade, 1 = fond)
	fractionLoin = 0.7,    -- position des lanternes
	anneauSable = 6,       -- repli si Plan.place.anneau manque : l'anneau de sable de Sol dépasse la Place de ...
	anneauDebut = 1,       -- props de la Place sur l'herbe : du bord du sable + 1 ...
	anneauFin = 5,         -- ... au bord du sable + 5 (r 29..33 avec rayon 22 et anneau 6)
	margeSable = 1,        -- herbe laissée entre un prop et le bord d'un chemin de sable (galets compris)
	margeAnneau = 0.2,     -- recul depuis le bord extérieur de l'anneau
	rayonTorches = 23,     -- torches de la Place (Builders/Lumieres, placeRayon)
	ecartCote = 3,         -- côtés de la Nurserie / Grande Porte : de rayon + 3 ...
	profondeurCote = 24,   -- ... sur 24 studs (jusqu'à rayon + 27)
	ancreCote = 7,         -- compositions des côtés centrées à promenade.zMax + margeSable + 7 de l'axe du Tapis
	gardeTorche = 5,       -- demi-angle (degrés) laissé libre autour des torches de la Place
	gardeLien = 22,        -- demi-angle laissé libre vers le Comptoir et l'Autel (au moins 18)
	gardeNord = 42,        -- demi-angle laissé libre vers le nord (allée x = centre, chemin de ronde)
	gardeDinodex = 18,     -- demi-angle laissé libre au sud (borne Dinodex, sentier de la rivière)
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
	local FLAMME = hex("FF8A2A")        -- flammes du feu de camp
	local AMBRE = hex("FFA82E")         -- ambre fossile translucide

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

	-- ===== effets légers (particules), jamais bloquants =====
	local function particules(part, props)
		pcall(function()
			local p = Instance.new("ParticleEmitter")
			p.Name = props.nom or "Particules"
			p.Texture = props.texture or "rbxasset://textures/particles/sparkles_main.dds"
			p.Color = ColorSequence.new(props.couleur or FEU)
			p.LightEmission = props.emission or 1
			p.LightInfluence = 0
			local taille = props.taille or 0.25
			p.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, taille),
				NumberSequenceKeypoint.new(1, props.tailleFin or 0),
			})
			p.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, props.transparence or 0.2),
				NumberSequenceKeypoint.new(1, 1),
			})
			p.Lifetime = NumberRange.new(props.vieMin or 0.8, props.vieMax or 1.6)
			p.Rate = props.debit or 2
			p.Speed = NumberRange.new(props.vitesseMin or 0.5, props.vitesseMax or 1.5)
			p.SpreadAngle = Vector2.new(props.ouverture or 20, props.ouverture or 20)
			p.Acceleration = props.acceleration or Vector3.new(0, 0.6, 0)
			p.RotSpeed = NumberRange.new(-60, 60)
			p.Parent = part
		end)
	end

	-- feu de camp : couronne de pierres, deux bûches croisées, flammes Neon qui palpitent,
	-- lueur orangée et quelques étincelles qui montent (10 parts)
	function fabriques.feu(m, cf, s)
		for k = 0, 5 do
			local a = math.rad(k * 60 + 15)
			boule(m, {
				Name = "Pierre",
				Size = V(0.7 * s, 0.5 * s, 0.7 * s),
				CFrame = ici(cf, math.cos(a) * 1.15 * s, 0.18 * s, math.sin(a) * 1.15 * s),
				Color = (k % 2 == 0) and ROCHE or ROCHE_OMBRE,
				Material = M_ROCHE,
			})
		end
		for _, ry in ipairs({ 35, -35 }) do
			cylindre(m, {
				Name = "Buche",
				Size = V(1.9 * s, 0.34 * s, 0.34 * s),
				CFrame = ici(cf, 0, 0.22 * s, 0, 0, ry, 0),
				Color = BOIS_FONCE,
				Material = M_BOIS,
			})
		end
		local flamme = bloc(m, {
			Name = "Flamme",
			Size = V(0.62 * s, 0.95 * s, 0.62 * s),
			CFrame = ici(cf, 0, 0.78 * s, 0, 0, 45, 0),
			Color = FLAMME,
			Material = NEON,
			CastShadow = false,
			CanCollide = false,
		})
		local coeur = bloc(m, {
			Name = "Coeur",
			Size = V(0.34 * s, 0.62 * s, 0.34 * s),
			CFrame = ici(cf, 0.05 * s, 1.18 * s, 0.03 * s, 0, 20, 0),
			Color = FEU,
			Material = NEON,
			CastShadow = false,
			CanCollide = false,
		})
		if flamme then
			pcall(function()
				local l = Outils.lumiere(flamme, { Range = 14, Brightness = 1.1, Color = FLAMME })
				l.Shadows = false
				Outils.animer(flamme, "pulse", 1.4)
			end)
			particules(flamme, {
				nom = "Etincelles",
				couleur = FEU,
				taille = 0.16,
				debit = 3,
				vieMin = 0.8,
				vieMax = 1.5,
				vitesseMin = 2,
				vitesseMax = 3.5,
				ouverture = 18,
				acceleration = Vector3.new(0, 1, 0),
			})
		end
		if coeur then
			pcall(function()
				Outils.animer(coeur, "pulse", 1.9)
			end)
		end
	end

	-- éclat d'ambre fossile (un moustique pris dedans) qui flotte au-dessus d'un petit socle d'ardoise
	-- et scintille : la « trouvaille » du chantier (3 parts)
	function fabriques.ambre(m, cf, s)
		bloc(m, {
			Name = "Socle",
			Size = V(1.2 * s, 0.5 * s, 1.2 * s),
			CFrame = ici(cf, 0, 0.25 * s, 0, 0, 15, 0),
			Color = ROCHE_CLAIRE,
			Material = M_ROCHE,
		})
		local gemme = Outils.modele(m, "Trouvaille")
		local pierre = bloc(gemme, {
			Name = "Ambre",
			Size = V(0.75 * s, 0.95 * s, 0.6 * s),
			CFrame = ici(cf, 0, 1.35 * s, 0, 12, 30, 18),
			Color = AMBRE,
			Material = M_VERRE,
			Transparency = 0.2,
			CastShadow = false,
			CanCollide = false,
		})
		bloc(gemme, {
			Name = "Moustique",
			Size = V(0.14 * s, 0.1 * s, 0.3 * s),
			CFrame = ici(cf, 0, 1.35 * s, 0, 12, 30, 18),
			Color = CREUX,
			Material = M_OS,
			CastShadow = false,
			CanCollide = false,
		})
		if pierre then
			pcall(function()
				local l = Outils.lumiere(pierre, { Range = 7, Brightness = 0.7, Color = AMBRE })
				l.Shadows = false
				Outils.animer(gemme, "flotte", 0.6)
			end)
			particules(pierre, { nom = "Scintillement", couleur = FEU, taille = 0.22, debit = 1.5, vitesseMin = 0.2, vitesseMax = 0.6, ouverture = 180, acceleration = Vector3.new(0, 0.3, 0) })
		end
	end

	-- nom du modèle, coût en parts et demi-emprise au sol (a sur X local, b sur Z local) selon l'échelle
	local PROPS = {
		feu = { nom = "FeuDeCamp", cout = 10, a = 1.55, b = 1.55 },
		ambre = { nom = "Ambre", cout = 3, a = 0.85, b = 0.85 },
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

	-- ===== emprises (tout vient de Plan) =====
	-- allées entre les Bases : une bande de bordure contre le mur de chaque Base, le milieu reste libre
	local allees = Plan.allees
	local A_DEMI, A_BANDE, A_ZMIN, A_ZMAX = 0, 0, 0, 0
	if type(allees) == "table" and type(allees.x) == "table" and type(allees.largeur) == "number"
		and type(allees.zMin) == "number" and type(allees.zMax) == "number" then
		A_DEMI = allees.largeur / 2
		A_BANDE = math.min(reglage("bandeAllee"), A_DEMI * 0.45)
		A_ZMIN = allees.zMin + reglage("gardeEntree")
		A_ZMAX = allees.zMax - reglage("gardeFond")
	end
	local JEU_MUR = reglage("jeuMur")

	local function dansAllee(x, z, hx, hz)
		if A_DEMI <= 0 then
			return false
		end
		for _, c in ipairs(allees.x) do
			local d = math.abs(x - c)
			if d - hx >= A_DEMI - A_BANDE and d + hx <= A_DEMI - JEU_MUR and math.abs(z) - hz >= A_ZMIN and math.abs(z) + hz <= A_ZMAX then
				return true
			end
		end
		return false
	end

	-- ===== chemins de sable de Sol (galets de bordure compris), recalculés depuis Plan =====
	-- mêmes formes et mêmes réglages que Builders/Sol (Equilibrage.sol) : un prop de l'anneau ou des côtés
	-- doit laisser au moins `margeSable` d'herbe entre lui et chacune d'elles.
	local function reglageSol(cle, defaut)
		local sol = ctx.Equilibrage and ctx.Equilibrage.sol
		if type(sol) == "table" and type(sol[cle]) == "number" then
			return sol[cle]
		end
		return defaut
	end
	local MARGE_SABLE = reglage("margeSable")
	local sables = {}
	local function sableRect(x0, x1, z0, z1)
		table.insert(sables, { g = "rect", x0 = math.min(x0, x1), x1 = math.max(x0, x1), z0 = math.min(z0, z1), z1 = math.max(z0, z1) })
	end
	local function sableDisque(x, z, r)
		table.insert(sables, { g = "disque", x = x, z = z, r = r })
	end
	local decor = type(Plan.decor) == "table" and Plan.decor or {}
	local zP = (type(Plan.promenade) == "table" and type(Plan.promenade.zMax) == "number") and Plan.promenade.zMax or 27
	-- promenade en « stade » le long du Tapis, terminée par une demi-lune (rayon zP) devant la Nurserie et la Grande Porte
	local xBout = 0
	for _, bout in ipairs({ Plan.nurserie, Plan.finTapis }) do
		if type(bout) == "table" and typeof(bout.centre) == "Vector3" then
			xBout = math.max(xBout, math.abs(bout.centre.X))
		end
	end
	local margeJungle = reglageSol("margeJungle", 2)
	if type(decor.jungleOuest) == "table" and typeof(decor.jungleOuest.max) == "Vector3" then
		xBout = math.min(xBout, math.abs(decor.jungleOuest.max.X) - margeJungle - zP)
	end
	if type(decor.jungleEst) == "table" and typeof(decor.jungleEst.min) == "Vector3" then
		xBout = math.min(xBout, math.abs(decor.jungleEst.min.X) - margeJungle - zP)
	end
	if xBout > 0 then
		table.insert(sables, { g = "capsule", x0 = -xBout, x1 = xBout, z = 0, r = zP })
	end
	-- allées entre les Bases, chemins de ronde et contre-allées
	local zRondeA, zRondeB, xContreB = nil, nil, nil
	if type(Plan.base) == "table" and type(Plan.bases) == "table" then
		local xBasesMax, zBasesFond = 0, zP + (Plan.base.profondeur or 0)
		for _, b in ipairs(Plan.bases) do
			if typeof(b.centre) == "Vector3" then
				xBasesMax = math.max(xBasesMax, math.abs(b.centre.X) + (Plan.base.largeur or 0) / 2)
				zBasesFond = math.max(zBasesFond, math.abs(b.centre.Z) + (Plan.base.profondeur or 0) / 2)
			end
		end
		zRondeA = zBasesFond + reglageSol("ecartRonde", 3)
		zRondeB = zRondeA + reglageSol("largeurRonde", 8)
		local xContreA = xBasesMax + reglageSol("ecartContre", 2)
		xContreB = xContreA + reglageSol("largeurContre", 10)
		for _, s in ipairs({ -1, 1 }) do
			sableRect(-xContreB, xContreB, s * zRondeA, s * zRondeB)
			sableRect(s * xContreA, s * xContreB, s * (zP - 1), s * (zRondeA + 1))
		end
		if A_DEMI > 0 then
			for _, ax in ipairs(allees.x) do
				for _, s in ipairs({ -1, 1 }) do
					sableRect(ax - A_DEMI, ax + A_DEMI, s * (allees.zMin - 1), s * (zRondeA + 1))
				end
			end
		end
	end

	-- anneau de la Place : sur l'herbe, au-delà de l'anneau de sable (même largeur que Sol)
	local PC = nil
	local R_MIN, R_MAX = 0, 0
	if type(Plan.place) == "table" and typeof(Plan.place.centre) == "Vector3" and type(Plan.place.rayon) == "number" then
		PC = Plan.place.centre
		local anneauSable = Plan.place.anneau
		if type(anneauSable) ~= "number" then
			anneauSable = reglageSol("anneauPlace", reglage("anneauSable"))
		end
		local rPlace = Plan.place.rayon + anneauSable
		R_MIN = rPlace + reglage("anneauDebut")
		R_MAX = rPlace + reglage("anneauFin")
		-- l'anneau de sable, ses liens vers le Comptoir et l'Autel, le sentier et la plage de la rivière
		sableDisque(PC.X, PC.Z, rPlace)
		local dLien = reglageSol("demiLien", 6)
		local mBat = reglageSol("margeBatiment", 3)
		local comptoir = Plan.comptoir
		if type(comptoir) == "table" and typeof(comptoir.centre) == "Vector3" and typeof(comptoir.taille) == "Vector3" then
			local c, t = comptoir.centre, comptoir.taille
			sableRect(c.X + t.X / 2 - 1, PC.X - rPlace + 3, c.Z - dLien, c.Z + dLien)
			sableRect(c.X - t.X / 2 - mBat, c.X + t.X / 2 + mBat, c.Z - t.Z / 2 - mBat, c.Z + t.Z / 2 + mBat)
		end
		local autel = Plan.autel
		if type(autel) == "table" and typeof(autel.centre) == "Vector3" and type(autel.rayon) == "number" then
			sableRect(PC.X + rPlace - 3, autel.centre.X - autel.rayon + 1, autel.centre.Z - dLien, autel.centre.Z + dLien)
			sableDisque(autel.centre.X, autel.centre.Z, autel.rayon + mBat)
		end
		local riviere = Plan.riviere
		if type(riviere) == "table" and type(riviere.zMin) == "number" then
			local zPlageA = riviere.zMin - reglageSol("plage", 6)
			if type(decor.jungleOuest) == "table" and typeof(decor.jungleOuest.max) == "Vector3" then
				zPlageA = math.min(zPlageA, decor.jungleOuest.max.Z)
			end
			local dR = reglageSol("demiRiviere", 5)
			sableRect(PC.X - dR, PC.X + dR, PC.Z + rPlace - 3, zPlageA + 1)
			local xMin = type(riviere.xMin) == "number" and riviere.xMin or -1e4
			local xMax = type(riviere.xMax) == "number" and riviere.xMax or 1e4
			sableRect(xMin, xMax, zPlageA, riviere.zMin + 2)
		end
		-- liaison allée x = centre -> anneau quand l'anneau ne touche pas le chemin de ronde
		if zRondeB and PC.Z - rPlace > zRondeB then
			sableRect(PC.X - dLien, PC.X + dLien, zRondeB - 1, PC.Z - rPlace + 2)
		end
	end

	-- emprise au sol f = { x, z, a, b, ry } (rectangle tourné) ou { x, z, a, rond = true } (disque de rayon a) :
	-- demi-étendue selon la direction (ux, uz)
	local function etendue(f, ux, uz)
		if f.rond then
			return f.a
		end
		return demiEtendue(f.a, f.b, f.ry, ux, uz)
	end
	-- vrai si l'emprise f passe à moins de `marge` de la forme de sable s
	local function touche(f, s, marge)
		if s.g == "rect" then
			local hx, hz = (s.x1 - s.x0) / 2 + marge, (s.z1 - s.z0) / 2 + marge
			local dx, dz = f.x - (s.x0 + s.x1) / 2, f.z - (s.z0 + s.z1) / 2
			-- axes séparateurs : X et Z du monde, puis X et Z locaux du prop
			if math.abs(dx) >= hx + etendue(f, 1, 0) or math.abs(dz) >= hz + etendue(f, 0, 1) then
				return false
			end
			if not f.rond then
				local r = math.rad(f.ry)
				local c, sn = math.cos(r), math.sin(r)
				for _, ax in ipairs({ { c, -sn, f.a }, { sn, c, f.b } }) do
					if math.abs(dx * ax[1] + dz * ax[2]) >= ax[3] + hx * math.abs(ax[1]) + hz * math.abs(ax[2]) then
						return false
					end
				end
			end
			return true
		end
		-- disque, ou capsule le long de X (point le plus proche sur le segment x0..x1)
		local qx = s.x
		if s.g == "capsule" then
			qx = math.max(s.x0, math.min(s.x1, f.x))
		end
		local dx, dz = f.x - qx, f.z - s.z
		local d = math.sqrt(dx * dx + dz * dz)
		if d < 0.01 then
			return true
		end
		-- d - étendue minore la distance de l'emprise à l'axe de la forme
		return d - etendue(f, dx / d, dz / d) < s.r + marge
	end
	local function horsDuSable(f)
		for _, s in ipairs(sables) do
			if touche(f, s, MARGE_SABLE) then
				return false
			end
		end
		return true
	end

	local function angleVers(p)
		return math.deg(math.atan2(p.Z - PC.Z, p.X - PC.X)) % 360
	end
	-- directions à laisser libres : { angle, demi-angle }
	local interdits = {}
	if PC then
		local gardeLien = reglage("gardeLien")
		if Plan.comptoir and typeof(Plan.comptoir.centre) == "Vector3" then
			table.insert(interdits, { angleVers(Plan.comptoir.centre), gardeLien })
		end
		if Plan.autel and typeof(Plan.autel.centre) == "Vector3" then
			table.insert(interdits, { angleVers(Plan.autel.centre), gardeLien })
		end
		table.insert(interdits, { angleVers(PC - Vector3.new(0, 0, 1)), reglage("gardeNord") }) -- vers le Tapis
		table.insert(interdits, { angleVers(PC + Vector3.new(0, 0, 1)), reglage("gardeDinodex") }) -- borne et rivière au sud
	end
	-- torches de la Place (Builders/Lumieres) : gardées seulement si un prop descend jusqu'à leur cercle
	local pasTorche, decalageTorche, rayonTorche = 45, 22.5, reglage("rayonTorches")
	local lum = ctx.Equilibrage and ctx.Equilibrage.lumieres
	if type(lum) == "table" then
		if type(lum.placePas) == "number" and lum.placePas > 0 then
			pasTorche = lum.placePas
		end
		if type(lum.placeDecalage) == "number" then
			decalageTorche = lum.placeDecalage
		end
		if type(lum.placeRayon) == "number" then
			rayonTorche = lum.placeRayon
		end
	end
	local torches = {}
	local angleTorche = 0
	while angleTorche < 360 - 0.01 do
		table.insert(torches, (angleTorche + decalageTorche) % 360)
		angleTorche = angleTorche + pasTorche
	end

	local function ecartAngle(a, b)
		return math.abs(((a - b + 180) % 360) - 180)
	end

	local function dansAnneau(x, z, ry, a, b)
		if not PC then
			return false
		end
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
		if d - radial < rayonTorche + 2 then
			for _, t in ipairs(torches) do
				if ecartAngle(theta, t) < reglage("gardeTorche") + demi then
					return false
				end
			end
		end
		return horsDuSable({ x = x, z = z, a = a, b = b, ry = ry })
	end

	-- côtés de la Nurserie et de la Grande Porte : bandes au nord et au sud de leurs disques
	local cotes = {}
	local function ajouterCote(info)
		if type(info) == "table" and typeof(info.centre) == "Vector3" and type(info.rayon) == "number" then
			local zMin = info.rayon + reglage("ecartCote")
			local cote = { centre = info.centre, rayon = info.rayon, zMin = zMin, zMax = zMin + reglage("profondeurCote") }
			table.insert(cotes, cote)
			return cote
		end
		return nil
	end
	local coteNurserie = ajouterCote(Plan.nurserie)
	local coteFin = ajouterCote(Plan.finTapis)

	-- distance (|dz|) de l'axe du Tapis où l'on centre les compositions : au-delà de la demi-lune de sable
	local zAncre = zP + MARGE_SABLE + reglage("ancreCote")

	local function dansCote(x, z, hx, hz, f)
		for _, cote in ipairs(cotes) do
			local dz = math.abs(z - cote.centre.Z)
			if math.abs(x - cote.centre.X) + hx <= cote.rayon and dz - hz >= cote.zMin and dz + hz <= cote.zMax then
				return horsDuSable(f)
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
		if zone.genre == "allee" then
			permis = dansAllee(x, z, demiEtendue(a, b, ry, 1, 0), demiEtendue(a, b, ry, 0, 1))
		elseif zone.genre == "anneau" then
			permis = dansAnneau(x, z, ry, a, b)
		else
			permis = dansCote(x, z, demiEtendue(a, b, ry, 1, 0), demiEtendue(a, b, ry, 0, 1), { x = x, z = z, a = a, b = b, ry = ry })
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

	-- ===== 1. les allées entre les Bases =====
	-- collision coupée : les courses-poursuites de vol ne s'accrochent jamais au décor.
	-- Par demi-allée (au nord et au sud du Tapis) : une petite composition contre le mur d'une Base, au premier
	-- tiers, et une lanterne contre le mur d'en face, plus loin, qui penche vers l'allée. Le milieu reste libre.
	if A_DEMI > 0 then
		local zoneAllee = { genre = "allee", collision = false, dossier = Outils.dossier(dossier, "Allees") }
		local longueur = allees.zMax - allees.zMin
		local zPres = allees.zMin + longueur * reglage("fractionPres")
		local zLoin = allees.zMin + longueur * reglage("fractionLoin")
		local dProp = A_DEMI - reglage("retraitMur")
		local dLanterne = A_DEMI - reglage("retraitLanterne")
		local k = 0
		for _, c in ipairs(allees.x) do
			for _, sgn in ipairs({ -1, 1 }) do
				k = k + 1
				-- mur choisi en alternance d'une demi-allée à l'autre (jamais le même motif en miroir)
				local cote = 1
				if k % 2 == 0 then
					cote = -1
				end
				local x = c + cote * dProp
				local vers = 90 * cote -- regard (-Z local) tourné vers le milieu de l'allée
				local motif = k % 3
				if motif == 1 then
					-- crâne exposé sur son socle, un rocher moussu plus loin dans l'allée
					poser(zoneAllee, "exposition", x, sgn * zPres, vers, 0.9)
					poser(zoneAllee, "rocher", x, sgn * (zPres + 3.6), 0, 0.8)
				elseif motif == 2 then
					-- os à demi enterré au pied d'un rocher
					poser(zoneAllee, "os", x, sgn * zPres, 0, 1.3)
					poser(zoneAllee, "rocher", x, sgn * (zPres + 3.7), 0, 0.9)
				else
					-- tonneau et caisse d'expédition
					poser(zoneAllee, "tonneau", x, sgn * (zPres - 1.1), 0, 0.9)
					poser(zoneAllee, "caisse", x, sgn * (zPres + 1.4), rng:NextNumber(-20, 20), 0.85)
				end
				poser(zoneAllee, "lanterne", c - cote * dLanterne, sgn * zLoin, -vers, 1)
			end
		end
	end

	-- ===== 2. l'anneau de la Place =====
	-- quatre petites scènes dans les secteurs libres (entre les liens vers le Comptoir et l'Autel, l'allée du
	-- nord et le sentier du sud), sur l'herbe juste au-delà de l'anneau de sable : le sable reste libre.
	if PC then
		local zoneAnneau = { genre = "anneau", collision = true, dossier = Outils.dossier(dossier, "Place") }
		-- { prop, angle (degrés, x = cos, z = sin, 90 = sud), échelle, orientation }
		-- orientation « tangent » : axe Z local le long de l'anneau ; « face » : regard vers le centre
		local ANNEAU = {
			-- sud-est : la vitrine du paléontologue
			{ "caisse", 38, 1, "tangent" },
			{ "exposition", 47, 1, "face" },
			{ "ambre", 56, 1, "face" },
			{ "os", 64, 1.1, "tangent" },
			-- sud-ouest : la réserve de l'expédition
			{ "tonneau", 114, 1, "tangent" },
			{ "tonneau", 118.5, 0.85, "tangent" },
			{ "caisse", 125, 0.9, "tangent" },
			{ "lanterne", 134, 1, "face" },
			-- nord-ouest : le coin des fouilles
			{ "pelle", 205, 1, "tangent" },
			{ "rocher", 214, 1.2, "tangent" },
			-- nord-est : un os trouvé au pied d'une lanterne
			{ "lanterne", 318, 1, "face" },
			{ "os", 328, 1.1, "tangent" },
		}
		local marge = reglage("margeAnneau")
		for _, e in ipairs(ANNEAU) do
			local def = PROPS[e[1]]
			if def then
				local theta = e[2]
				local t = math.rad(theta)
				local ux, uz = math.cos(t), math.sin(t)
				local ry = 180 - theta
				if e[4] == "face" then
					ry = 90 - theta
				end
				-- collé au bord extérieur de l'anneau, sans jamais repasser sous R_MIN (props profonds : l'exposition)
				local radial = demiEtendue(def.a * e[3], def.b * e[3], ry, ux, uz)
				local r = math.max(R_MAX - radial - marge, R_MIN + radial + 0.05)
				poser(zoneAnneau, e[1], PC.X + r * ux, PC.Z + r * uz, ry, e[3])
			end
		end
	end

	-- ===== 3. les côtés de la Nurserie et de la Grande Porte =====
	-- chantier de fouille : squelette dans sa fosse sous ruban, ambre, lanterne, pelle et caisse autour
	local function chantier(zone, cote, sgn, ryCorps)
		local cx = cote.centre.X
		local zMilieu = zAncre
		local function en(lx, lz)
			return cx + lx, cote.centre.Z + sgn * (zMilieu + lz)
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
		-- la trouvaille du jour : un éclat d'ambre qui flotte et scintille près du crâne
		x, z = en(-9.8, -3.6)
		poser(zone, "ambre", x, z, 0, 1)
	end

	-- campement : clairière de terre battue (Terrain), jeep, caisse, tonneau, feu de camp (qui éclaire
	-- le campement) et gros rocher
	local function campement(zone, cote, sgn)
		local cx = cote.centre.X
		local zMilieu = zAncre
		local function en(lx, lz)
			return cx + lx, cote.centre.Z + sgn * (zMilieu + lz)
		end
		-- clairière : deux disques de terre (Ground) au ras de l'herbe, une couche de voxels
		if type(Outils.terrainCylindre) == "function" then
			for _, d in ipairs({ { -2, 0, 6.5 }, { 5, 0.5, 5 } }) do
				local x, z = en(d[1], d[2])
				local rayon = d[3]
				local dz = math.abs(z - cote.centre.Z)
				local dansZone = math.abs(x - cx) + rayon <= cote.rayon and dz - rayon >= cote.zMin and dz + rayon <= cote.zMax
					and horsDuSable({ x = x, z = z, a = rayon, rond = true })
				if dansZone then
					Outils.terrainCylindre(CFrame.new(x, 0.05 - 2.025, z), 4.05, rayon, Enum.Material.Ground)
				end
			end
		end
		local x, z = en(-6, 0)
		poser(zone, "jeep", x, z, 90, 1.15)
		x, z = en(1.8, -3.2)
		poser(zone, "caisse", x, z, rng:NextNumber(-20, 20), 1)
		x, z = en(1.5, 3.3)
		poser(zone, "tonneau", x, z, 0, 1)
		x, z = en(9, 1.5)
		poser(zone, "rocher", x, z, 0, 1.7)
		x, z = en(4.6, -0.9)
		poser(zone, "feu", x, z, 0, 1)
	end

	-- Nurserie : fouilles au nord, campement au sud ; Grande Porte : l'inverse (la carte reste équilibrée)
	if coteNurserie then
		local zoneNurserie = { genre = "cote", collision = true, dossier = Outils.dossier(dossier, "Nurserie") }
		chantier(zoneNurserie, coteNurserie, -1, 90)
		campement(zoneNurserie, coteNurserie, 1)
	end
	if coteFin then
		local zoneFin = { genre = "cote", collision = true, dossier = Outils.dossier(dossier, "FinTapis") }
		campement(zoneFin, coteFin, -1)
		chantier(zoneFin, coteFin, 1, -90)
	end

	dossier:SetAttribute("Parts", compte)
end

return M
