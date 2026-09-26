-- Constructeur Fossiles : petits props de décor (4 studs de haut au plus) façon « expédition paléontologique ».
-- Os géants, crânes fossiles, empreintes de pas géantes au sol, caisses « FRAGILE », tonneaux,
-- jeeps jouets d'explorateurs, lanternes, pelles et rochers.
-- Emprise (CONTRAT §10) :
--   * couloirs entre les Bases (|x - c| ≤ 5 pour c = -56, 0, 56 et 20 ≤ |z| ≤ 66) : props rangés contre
--     les murs des Bases (3 ≤ |x - c| ≤ 5), l'allée centrale reste libre et rien n'y bloque (CanCollide false) ;
--   * anneau 21..28 de la Place : hors de l'allée en anneau, des torches, des liens vers Comptoir / Autel,
--     de la borne Dinodex et de l'arrivée des couloirs au nord ;
--   * de part et d'autre de la Nurserie et de la Fin du tapis (|z| 16..30) : un chantier de fouille
--     (squelette entouré de ruban) et un campement d'explorateurs.
-- Graine fixe : la map est identique à chaque démarrage. Budget : 450 parts.
local M = {}

-- réglages par défaut (remplaçables par Equilibrage.fossiles)
local DEFAUTS = {
	budget = 450,          -- parts au maximum pour ce constructeur
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

	-- ===== couleurs : palette cartoon vive (style simulateur, voir STYLE.md) =====
	local hex = Charte.hex
	local OS = hex("FFFBF0")          -- os blanc éclatant, lisible de loin
	local OS_BOUT = hex("FFE9B8")     -- rotules crème chaude
	local EMPREINTE = hex("B8743A")   -- empreinte terre bien contrastée sur l'herbe
	local CAISSE = hex("FF9E3D")      -- caisse orange vif
	local CERCLAGE = hex("B5561C")
	local TONNEAU = hex("E8453C")     -- tonneau rouge cartoon
	local COUVERCLE = hex("A82A24")
	local METAL = hex("FFD23F")       -- cerclages jaunes
	local SOMBRE = Charte.encre
	local ROCHE = hex("A9A3C2")       -- pierre claire lavande
	local ROCHE_CLAIRE = hex("D6D2EA")
	local JEEP = hex("FFD23F")        -- jeep jaune vif
	local JEEP_CAPOT = hex("FFE77A")
	local BANDE = hex("2ECC55")       -- bande verte
	local VITRE = Charte.gemme
	local FEU = Charte.dore
	local RUBAN = hex("FFE14D")
	local TAS = hex("D9884A")
	local MANCHE = hex("C8742F")

	-- ===== fabrication des parts (budget compté ici) =====
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
		pcall(function()
			p.CanTouch = false
			p.CanCollide = collide
			if not collide then
				p.CanQuery = false
			end
		end)
		return p
	end
	local function bloc(m, props) return piece("bloc", m, props) end
	local function coin(m, props) return piece("coin", m, props) end
	local function cylindre(m, props) return piece("cylindre", m, props) end
	local function boule(m, props) return piece("boule", m, props) end

	-- repère local : décalage (x, y, z) puis rotation (degrés)
	local function ici(cf, x, y, z, rx, ry, rz)
		return cf * CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
	end

	local NEON = Enum.Material.Neon

	-- ===== les props =====
	-- chaque fonction reçoit le modèle, le CFrame au sol (regard vers -Z local) et une échelle
	local fabriques = {}

	-- os couché le long de Z local : fût + quatre rotules
	function fabriques.os(m, cf, s)
		local L = 3.2 * s
		local y = 0.45 * s
		cylindre(m, { Name = "Fut", Size = Vector3.new(L, 0.55 * s, 0.55 * s), CFrame = ici(cf, 0, y, 0, 0, 90, 0), Color = OS })
		for _, sz in ipairs({ -1, 1 }) do
			for _, sx in ipairs({ -1, 1 }) do
				boule(m, {
					Name = "Rotule",
					Size = Vector3.new(0.9 * s, 0.9 * s, 0.9 * s),
					CFrame = ici(cf, sx * 0.3 * s, y, sz * L / 2),
					Color = OS_BOUT,
				})
			end
		end
	end

	-- crâne fossile qui regarde vers -Z : boîte crânienne, museau, mâchoire, orbites, dents, corne
	function fabriques.crane(m, cf, s)
		bloc(m, { Name = "Boite", Size = Vector3.new(2.4 * s, 1.8 * s, 2.2 * s), CFrame = ici(cf, 0, 0.9 * s, 0.5 * s), Color = OS })
		bloc(m, { Name = "Museau", Size = Vector3.new(1.1 * s, 0.8 * s, 1.8 * s), CFrame = ici(cf, 0, 0.85 * s, -1.5 * s), Color = OS })
		bloc(m, { Name = "Machoire", Size = Vector3.new(1.0 * s, 0.3 * s, 1.7 * s), CFrame = ici(cf, 0, 0.15 * s, -1.45 * s), Color = OS_BOUT })
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Orbite",
				Size = Vector3.new(0.6 * s, 0.6 * s, 0.1 * s),
				CFrame = ici(cf, sx * 0.78 * s, 1.3 * s, -0.63 * s),
				Color = SOMBRE,
			})
		end
		for k = -1, 1 do
			bloc(m, {
				Name = "Dent",
				Size = Vector3.new(0.18 * s, 0.22 * s, 0.18 * s),
				CFrame = ici(cf, k * 0.35 * s, 0.34 * s, -2.2 * s),
				Color = Charte.creme,
			})
		end
		coin(m, { Name = "Corne", Size = Vector3.new(0.3 * s, 0.6 * s, 0.6 * s), CFrame = ici(cf, 0, 1.55 * s, -2.0 * s), Color = OS_BOUT })
	end

	-- empreinte de pas géante (à plat, jamais d'obstacle) : coussinet + trois doigts vers -Z
	function fabriques.empreinte(m, cf, s)
		cylindre(m, {
			Name = "Coussinet",
			Size = Vector3.new(0.3, 1.9 * s, 1.9 * s),
			CFrame = ici(cf, 0, 0.1, 0, 0, 0, 90),
			Color = EMPREINTE,
			CanCollide = false,
			CastShadow = false,
		})
		for _, a in ipairs({ -28, 0, 28 }) do
			bloc(m, {
				Name = "Doigt",
				Size = Vector3.new(0.55 * s, 0.3, 1.3 * s),
				CFrame = cf * CFrame.Angles(0, math.rad(a), 0) * CFrame.new(0, 0.1, -1.25 * s),
				Color = EMPREINTE,
				CanCollide = false,
				CastShadow = false,
			})
		end
	end

	-- caisse d'expédition en bois, cerclée, marquée « FRAGILE »
	function fabriques.caisse(m, cf, s)
		local corps = bloc(m, { Name = "Caisse", Size = Vector3.new(2 * s, 2 * s, 2 * s), CFrame = ici(cf, 0, s, 0), Color = CAISSE })
		for _, y in ipairs({ 0.3, 1.7 }) do
			bloc(m, { Name = "Cerclage", Size = Vector3.new(2.06 * s, 0.28 * s, 2.06 * s), CFrame = ici(cf, 0, y * s, 0), Color = CERCLAGE })
		end
		if corps then
			pcall(function()
				-- texte blanc cerné de noir, police du jeu (grammaire « simulateur »)
				local t1 = Outils.texte(corps, "Front", "FRAGILE", { couleur = Charte.alerte })
				local t2 = Outils.texte(corps, "Right", "🦴", { couleur = Style and Style.couleurs.texte or Charte.creme })
				if Style then
					t1.Font = Style.policeTitre
					t2.Font = Style.police
					Style.contour(t1, 3)
					Style.contour(t2, 3)
				end
			end)
		end
	end

	-- deux caisses empilées (la seconde plus petite, un peu tournée)
	function fabriques.pile(m, cf, s)
		fabriques.caisse(m, cf, s)
		fabriques.caisse(m, ici(cf, 0.1 * s, 2 * s, 0.05 * s, 0, 18, 0), 0.7 * s)
	end

	-- tonneau debout cerclé de fer
	function fabriques.tonneau(m, cf, s)
		cylindre(m, { Name = "Tonneau", Size = Vector3.new(2.2 * s, 1.6 * s, 1.6 * s), CFrame = ici(cf, 0, 1.1 * s, 0, 0, 0, 90), Color = TONNEAU })
		for _, y in ipairs({ 0.45, 1.75 }) do
			cylindre(m, { Name = "Cercle", Size = Vector3.new(0.18 * s, 1.72 * s, 1.72 * s), CFrame = ici(cf, 0, y * s, 0, 0, 0, 90), Color = METAL })
		end
		cylindre(m, { Name = "Couvercle", Size = Vector3.new(0.06, 1.35 * s, 1.35 * s), CFrame = ici(cf, 0, 2.2 * s + 0.03, 0, 0, 0, 90), Color = COUVERCLE })
	end

	-- jeep jouet d'explorateurs, capot vers -Z
	function fabriques.jeep(m, cf, s)
		bloc(m, { Name = "Carrosserie", Size = Vector3.new(3 * s, 0.9 * s, 5 * s), CFrame = ici(cf, 0, 1.25 * s, 0), Color = JEEP })
		bloc(m, { Name = "Bande", Size = Vector3.new(3.04 * s, 0.22 * s, 5.04 * s), CFrame = ici(cf, 0, 1.35 * s, 0), Color = BANDE })
		bloc(m, { Name = "Capot", Size = Vector3.new(2.6 * s, 0.3 * s, 1.7 * s), CFrame = ici(cf, 0, 1.85 * s, -1.5 * s), Color = JEEP_CAPOT })
		bloc(m, {
			Name = "PareBrise",
			Size = Vector3.new(2.8 * s, 1.0 * s, 0.15 * s),
			CFrame = ici(cf, 0, 2.2 * s, -0.55 * s),
			Color = VITRE,
			Transparency = 0.35,
		})
		bloc(m, { Name = "Arceau", Size = Vector3.new(2.8 * s, 0.25 * s, 0.25 * s), CFrame = ici(cf, 0, 2.95 * s, 1.6 * s), Color = SOMBRE })
		for _, sx in ipairs({ -1, 1 }) do
			bloc(m, { Name = "Montant", Size = Vector3.new(0.25 * s, 1.25 * s, 0.25 * s), CFrame = ici(cf, sx * 1.3 * s, 2.3 * s, 1.6 * s), Color = SOMBRE })
			bloc(m, {
				Name = "Phare",
				Size = Vector3.new(0.5 * s, 0.35 * s, 0.1 * s),
				CFrame = ici(cf, sx * 0.9 * s, 1.45 * s, -2.53 * s),
				Color = FEU,
				Material = NEON,
			})
			for _, sz in ipairs({ -1, 1 }) do
				cylindre(m, {
					Name = "Roue",
					Size = Vector3.new(0.6 * s, 1.4 * s, 1.4 * s),
					CFrame = ici(cf, sx * 1.55 * s, 0.7 * s, sz * 1.6 * s),
					Color = SOMBRE,
				})
			end
		end
		cylindre(m, { Name = "RoueSecours", Size = Vector3.new(0.5 * s, 1.3 * s, 1.3 * s), CFrame = ici(cf, 0, 1.4 * s, 2.75 * s, 0, 90, 0), Color = SOMBRE })
	end

	-- lanterne suspendue à un poteau de bois (la lueur respire doucement)
	function fabriques.lanterne(m, cf, s)
		cylindre(m, { Name = "Poteau", Size = Vector3.new(3.2 * s, 0.3 * s, 0.3 * s), CFrame = ici(cf, 0, 1.6 * s, 0.45 * s, 0, 0, 90), Color = MANCHE })
		bloc(m, { Name = "Bras", Size = Vector3.new(0.18 * s, 0.18 * s, 1.0 * s), CFrame = ici(cf, 0, 3.1 * s, 0), Color = SOMBRE })
		local verre = bloc(m, {
			Name = "Verre",
			Size = Vector3.new(0.6 * s, 0.7 * s, 0.6 * s),
			CFrame = ici(cf, 0, 2.55 * s, -0.45 * s),
			Color = FEU,
			Material = NEON,
			CastShadow = false,
		})
		bloc(m, { Name = "Chapeau", Size = Vector3.new(0.75 * s, 0.2 * s, 0.75 * s), CFrame = ici(cf, 0, 3.0 * s, -0.45 * s), Color = SOMBRE })
		if verre then
			pcall(function()
				local l = Outils.lumiere(verre, { Range = 12, Brightness = 0.9, Color = FEU })
				l.Shadows = false
				Outils.animer(verre, "pulse", 0.6)
			end)
		end
	end

	-- pelle plantée dans un petit tas de terre, un peu penchée
	function fabriques.pelle(m, cf, s)
		boule(m, { Name = "Tas", Size = Vector3.new(1.8 * s, 1.8 * s, 1.8 * s), CFrame = ici(cf, 0, -0.45 * s, 0), Color = TAS })
		local penche = ici(cf, 0, 0, 0, 12, 0, 0)
		cylindre(m, { Name = "Manche", Size = Vector3.new(2.6 * s, 0.2 * s, 0.2 * s), CFrame = ici(penche, 0, 1.6 * s, 0, 0, 0, 90), Color = MANCHE })
		bloc(m, { Name = "Lame", Size = Vector3.new(0.8 * s, 0.9 * s, 0.1 * s), CFrame = ici(penche, 0, 0.3 * s, 0), Color = METAL })
		bloc(m, { Name = "Poignee", Size = Vector3.new(0.6 * s, 0.16 * s, 0.16 * s), CFrame = ici(penche, 0, 2.95 * s, 0), Color = SOMBRE })
	end

	-- rocher à demi enterré et son petit caillou
	function fabriques.rocher(m, cf, s)
		bloc(m, {
			Name = "Rocher",
			Size = Vector3.new(1.6 * s, 1.1 * s, 1.4 * s),
			CFrame = ici(cf, 0, 0.45 * s, 0, rng:NextNumber(-10, 10), rng:NextNumber(0, 360), rng:NextNumber(-10, 10)),
			Color = ROCHE,
		})
		local a = rng:NextNumber(0, 2 * math.pi)
		boule(m, {
			Name = "Caillou",
			Size = Vector3.new(0.8 * s, 0.8 * s, 0.8 * s),
			CFrame = ici(cf, math.cos(a) * 0.95 * s, 0.2 * s, math.sin(a) * 0.95 * s),
			Color = ROCHE_CLAIRE,
		})
	end

	-- squelette en cours de fouille, crâne vers -Z, entouré d'un ruban tendu sur piquets
	function fabriques.squelette(m, cf, s)
		for k = 0, 5 do
			boule(m, { Name = "Vertebre", Size = Vector3.new(0.8 * s, 0.8 * s, 0.8 * s), CFrame = ici(cf, 0, 0.3 * s, (-3 + k * 1.2) * s), Color = OS_BOUT })
		end
		for k = 0, 3 do
			local longueur = (1.9 - 0.2 * k) * s
			for _, cote in ipairs({ -1, 1 }) do
				bloc(m, {
					Name = "Cote",
					Size = Vector3.new(0.22 * s, longueur, 0.26 * s),
					CFrame = ici(cf, cote * 0.75 * s, longueur / 2 - 0.1 * s, (-2.1 + k * 1.2) * s, 0, 0, -cote * 22),
					Color = OS,
				})
			end
		end
		fabriques.crane(m, ici(cf, 0, 0, -4.4 * s), 0.9 * s)
		local tailles = { 0.65, 0.5, 0.4 }
		local zQueue = { 3.9, 4.6, 5.2 }
		for i = 1, 3 do
			boule(m, {
				Name = "Queue",
				Size = Vector3.new(tailles[i] * s, tailles[i] * s, tailles[i] * s),
				CFrame = ici(cf, 0, 0.2 * s, zQueue[i] * s),
				Color = OS_BOUT,
			})
		end
		-- ruban de chantier : on peut l'enjamber, il ne bloque personne
		local x0, zA, zB = 2.4 * s, -7.4 * s, 6.3 * s
		for _, sx in ipairs({ -1, 1 }) do
			for _, z in ipairs({ zA, zB }) do
				bloc(m, { Name = "Piquet", Size = Vector3.new(0.3, 1.0, 0.3), CFrame = ici(cf, sx * x0, 0.5, z), Color = MANCHE, CanCollide = false })
			end
			bloc(m, {
				Name = "Ruban",
				Size = Vector3.new(0.12, 0.12, zB - zA),
				CFrame = ici(cf, sx * x0, 0.85, (zA + zB) / 2),
				Color = RUBAN,
				CanCollide = false,
				CastShadow = false,
			})
		end
		for _, z in ipairs({ zA, zB }) do
			bloc(m, {
				Name = "Ruban",
				Size = Vector3.new(2 * x0, 0.12, 0.12),
				CFrame = ici(cf, 0, 0.85, z),
				Color = RUBAN,
				CanCollide = false,
				CastShadow = false,
			})
		end
	end

	-- nom du modèle, coût en parts et demi-emprise au sol (a sur X local, b sur Z local) selon l'échelle
	local PROPS = {
		os = { nom = "Os", cout = 5, a = 0.75, b = 2.05 },
		crane = { nom = "Crane", cout = 9, a = 1.2, b = 2.4 },
		empreinte = { nom = "Empreinte", cout = 4, a = 1.15, b = 1.9 },
		caisse = { nom = "Caisse", cout = 3, a = 1.03, b = 1.03 },
		pile = { nom = "Caisses", cout = 6, a = 1.03, b = 1.03 },
		tonneau = { nom = "Tonneau", cout = 4, a = 0.86, b = 0.86 },
		jeep = { nom = "Jeep", cout = 14, a = 1.85, b = 3.0 },
		lanterne = { nom = "Lanterne", cout = 4, a = 0.4, b = 0.8 },
		pelle = { nom = "Pelle", cout = 4, a = 0.9, b = 0.9 },
		rocher = { nom = "Rocher", cout = 2, a = 1.4, b = 1.4 },
		squelette = { nom = "Squelette", cout = 34, a = 2.55, b = 7.55 },
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
	-- collision coupée : les courses-poursuites de vol ne s'accrochent jamais au décor
	local zoneCouloir = { genre = "couloir", collision = false, dossier = Outils.dossier(dossier, "Couloirs") }
	-- style simulateur : couloirs dégagés, seulement deux gros props bien lisibles par moitié de couloir
	-- (un gros os blanc et un crâne), collés aux murs des Bases, jamais au milieu de l'allée
	local ECHELLES_COULOIR = { os = 1.3, crane = 0.8 }
	local DX = reglage("decalageProp")

	for i, c in ipairs(xCouloirs) do
		for _, sens in ipairs({ 1, -1 }) do
			local premier, second = "os", "crane"
			if (i + (sens + 1) / 2) % 2 == 0 then
				premier, second = "crane", "os"
			end
			local cote = 1
			if sens == -1 then
				cote = -1
			end
			-- le crâne regarde vers le Tapis (z = 0)
			local ryCrane = 0
			if sens == -1 then
				ryCrane = 180
			end
			local ry1, ry2 = 0, ryCrane
			if premier == "crane" then
				ry1, ry2 = ryCrane, 0
			end
			poser(zoneCouloir, premier, c + cote * DX, sens * 33, ry1, ECHELLES_COULOIR[premier])
			poser(zoneCouloir, second, c - cote * DX, sens * 54, ry2, ECHELLES_COULOIR[second])
		end
	end

	-- ===== 2. l'anneau de la Place =====
	local zoneAnneau = { genre = "anneau", collision = true, dossier = Outils.dossier(dossier, "Place") }
	local rPose = (R_MIN + R_MAX) / 2
	-- { prop, angle (degrés, x = cos, z = sin), échelle } ; chaque prop est posé le long de l'anneau
	local ANNEAU = {
		{ "jeep", 35, 0.85 },
		{ "lanterne", 43, 1 },
		{ "pile", 48, 1 },
		{ "crane", 56, 0.9 },
		{ "os", 126, 1.5 },
		{ "tonneau", 136, 1 },
		{ "tonneau", 140.3, 1 },
		{ "lanterne", 145.2, 1 },
		{ "rocher", 149.2, 0.7 },
		{ "pelle", 211.5, 1 },
		{ "os", 217.7, 0.9 },
		{ "caisse", 321, 0.9 },
		{ "rocher", 327.5, 0.7 },
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

	-- chantier de fouille : squelette sous ruban, outils et caisses autour
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
		x, z = en(9, -4.8)
		poser(zone, "lanterne", x, z, 90, 1)
		x, z = en(-10, 4.5)
		poser(zone, "pelle", x, z, rng:NextNumber(0, 360), 1)
		x, z = en(10, 4.3)
		poser(zone, "caisse", x, z, rng:NextNumber(-25, 25), 1)
		x, z = en(12.6, 1.5)
		poser(zone, "tonneau", x, z, 0, 1)
		x, z = en(-11, -4.1)
		poser(zone, "os", x, z, 90, 1)
	end

	-- campement : jeep, caisses, tonneaux, gros os déjà sorti de terre
	local function campement(zone, cx, sgn)
		local regardTapis = 90 - 90 * sgn -- sud : vers -Z ; nord : vers +Z
		local function en(lx, lz)
			return cx + lx, sgn * (zMilieu + lz)
		end
		local x, z = en(-7, 0.5)
		poser(zone, "jeep", x, z, 90, 1)
		x, z = en(1, -3.5)
		poser(zone, "caisse", x, z, rng:NextNumber(-30, 30), 1)
		x, z = en(4, -2.8)
		poser(zone, "pile", x, z, rng:NextNumber(-20, 20), 1)
		x, z = en(1.5, 4.5)
		poser(zone, "tonneau", x, z, 0, 1)
		x, z = en(3.3, 4.9)
		poser(zone, "tonneau", x, z, 0, 1)
		x, z = en(-2, -1)
		poser(zone, "lanterne", x, z, 0, 1)
		x, z = en(9, 1.5)
		poser(zone, "os", x, z, 90, 1.6)
		x, z = en(10.5, -3.8)
		poser(zone, "crane", x, z, regardTapis, 1)
		x, z = en(-12, 5)
		poser(zone, "rocher", x, z, 0, 0.9)
		x, z = en(-12, -4.5)
		poser(zone, "pelle", x, z, rng:NextNumber(0, 360), 1)
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
