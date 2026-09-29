-- Constructeur Volcan : pièce maîtresse du nord, version 2 « rendu professionnel ».
-- Cône irrégulier sculpté en Terrain Roblox : tranches de terrain empilées (flancs bas en cendre brun-rouge
-- = Asphalt 6E4F45, haut en Basalt 5B4E57 : dégradé sombre du pied au sommet, jamais la teinte des allées),
-- légèrement penché, arêtes rocheuses qui descendent du sommet, bosses et éboulis au pied.
-- Matériaux de terrain possédés par ce module : Asphalt, Basalt, CrackedLava (Rock appartient aux Falaises).
-- Rebord du cratère en boules de basalte, paroi intérieure en CrackedLava, lac de lave Neon avec cœur
-- plus chaud, croûtes et bulles ; coulées de lave Neon enfoncées dans des chenaux creusés (lit de
-- CrackedLava, levées de croûte de chaque côté), largeur irrégulière, qui refroidissent vers le bas
-- (orange doré → rouge sombre) et finissent en lave figée (Basalt/CrackedLava non Neon) près des mares. Fumée (Smoke + panache), braises (ParticleEmitter), fumerolles.
-- Pendant l'événement « Eruption » (ctx.Etat.Evenement) : projections, lumière vive qui scintille,
-- lave jaune-orange qui pulse vite, fumée sombre et épaisse et alerte flottante « ÉRUPTION ! ».
-- Plan v2 : plus haut et plus large (sommet ≈ 56), rebord du cratère dentelé et plus haut à l'arrière
-- (le lac reste visible depuis la Place), petit cône adventif fumant sur le flanc est, orgues basaltiques
-- au pied côté Cratère, halo de chaleur au-dessus du lac. La Bouche porte les attributs Sommet, RayonCratere,
-- RayonLac et RayonBas : Interface/EclatsLave s'en sert pour faire retomber ses éclats sur les flancs.
-- Emprise (CONTRAT §10) : disque de Plan.volcan.rayon (36) autour de Plan.volcan.centre, hauteur ≤ Plan.volcan.hauteur (75).
local M = {}

local BUDGET = 320 -- parts au maximum pour ce constructeur (le terrain ne compte pas)

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier

	-- réglages facultatifs (Equilibrage.volcan), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.volcan) == "table" then
		reglages = ctx.Equilibrage.volcan
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end
	local function borne(v, mini, maxi)
		return math.max(mini, math.min(maxi, v))
	end

	-- position et limites de l'emprise
	local infoVolcan = Plan.volcan or {}
	local CENTRE = infoVolcan.centre or Vector3.new(0, 0, -190)
	local RAYON_MAX = infoVolcan.rayon or 36
	local HAUTEUR_MAX = infoVolcan.hauteur or 75
	local CX, CZ = CENTRE.X, CENTRE.Z

	-- le titre flotte 16 studs au-dessus du lac : le sommet garde de la marge sous la hauteur maximale
	local SOMMET = borne(reglage("sommet", 56), 30, HAUTEUR_MAX - 17)
	local RAYON_BAS = math.min(RAYON_MAX - 3.5, reglage("rayonBas", 32.5))
	local RAYON_HAUT = borne(reglage("rayonHaut", 11.5), 8, RAYON_BAS - 8)
	local RAYON_LAC = RAYON_HAUT - 3.2
	local RAYON_REBORD = RAYON_HAUT - 1
	local NB_COULEES = math.floor(borne(reglage("coulees", 4), 2, 6))
	local VITESSE_PULSE_CALME = reglage("pulseCalme", 0.7)
	local VITESSE_PULSE_ERUPTION = reglage("pulseEruption", 4)
	local PAS = 1.5 -- épaisseur des tranches de terrain
	local LIMITE_ROCHE = SOMMET * 0.36 -- sous cette hauteur, les flancs sont en cendre (Asphalt)
	local LEVEE = 0.15 -- la lave affleure dans son chenal creusé (jamais en relief sur le flanc)

	local rng = Outils.aleatoire(reglage("graine", 2026))
	local M_BASALTE = Enum.Material.Basalt
	local M_ROCHE = Enum.Material.Asphalt -- cendre du pied : matériau réservé au Volcan (Rock = Falaises)
	local M_FISSURE = Enum.Material.CrackedLava
	local HAUT = Vector3.new(0, 1, 0)

	-- ===== couleurs (palette du Style) =====
	local hex = Charte.hex
	local BASALTE_T = hex("5B4E57") -- basalte du terrain : gris chaud légèrement violacé
	local FISSURE_T = hex("4E3530") -- CrackedLava du terrain : croûte brun sombre, fissures orange
	local CENDRE_T = hex("6E4F45") -- Asphalt du terrain : cendre brun-rouge du pied du volcan
	local LAVE_FROIDE = hex("8A1E0E") -- rouge sombre de la lave qui refroidit en bas des coulées
	local ROCHE_PART = hex("54474F")
	local ROCHE_PART_CLAIRE = Charte.lumiere(ROCHE_PART)
	local CROUTE = hex("2E2528")
	local LAVE = Charte.lave
	local LAVE_VIVE = Charte.lumiere(Charte.lave)
	local COEUR = Charte.dore
	local BRAISE = Charte.dore
	local CONTOUR = Charte.encre
	local BLANC = Color3.new(1, 1, 1)
	local ALERTE = Charte.lave
	local TITRE_HAUT, TITRE_BAS = BRAISE, LAVE
	if Style and Style.boutons and Style.couleurs then
		local orange = Style.boutons.orange
		local jaune = Style.boutons.jaune
		if orange and jaune then
			LAVE = Charte.ombre(orange[2]) -- orange profond (le Neon l'éclaircit déjà)
			LAVE_VIVE = jaune[1]:Lerp(orange[1], 0.4) -- jaune-orange éclatant pendant l'éruption
			COEUR = jaune[1]:Lerp(orange[1], 0.25)
			TITRE_HAUT, TITRE_BAS = jaune[1], orange[2]
		end
		if Style.couleurs.revenu then
			BRAISE = Style.couleurs.revenu
		end
		if Style.couleurs.contour then
			CONTOUR = Style.couleurs.contour
		end
		if Style.couleurs.texte then
			BLANC = Style.couleurs.texte
		end
		if Style.boutons.rouge then
			ALERTE = Style.boutons.rouge[1]
		end
	end
	local FUMEE_CALME = hex("E4DED8")
	local FUMEE_ERUPTION = hex("5E5660")

	-- compteur de parts : on s'arrête net au budget
	local compteur = 0
	local function part(fabrique, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		compteur = compteur + 1
		return fabrique(parent, props)
	end
	-- propriétés d'une part de lave (Neon, sans collision ni ombre)
	local function propsLave(extra)
		local t = {
			Color = LAVE,
			Material = Enum.Material.Neon,
			CanCollide = false,
			CanQuery = false,
			CastShadow = false,
		}
		for k, v in pairs(extra) do
			t[k] = v
		end
		return t
	end

	local modele = Outils.modele(dossier, "Volcan")
	local cone = Outils.modele(modele, "Cone")
	local rochers = Outils.modele(modele, "Rochers")
	local croutes = Outils.modele(modele, "Croutes")
	local lave = Outils.modele(modele, "Lave") -- tout ce qui brille et pulse
	local laveFigee = Outils.modele(modele, "LaveRefroidie") -- bas des coulées : ne brille pas, ne pulse pas

	-- ===== géométrie du cône =====
	local function direction(a)
		return Vector3.new(math.cos(a), 0, math.sin(a))
	end
	-- le cône penche un peu (axe qui dérive doucement avec la hauteur) : silhouette naturelle
	local phiPenche = rng:NextNumber(0, math.pi * 2)
	local function centreA(y)
		local t = borne(y / SOMMET, 0, 1)
		local amp = 0.4 + 1.8 * t
		local phi = phiPenche + 0.5 * math.sin(y * 0.06)
		return Vector3.new(CX + math.cos(phi) * amp, y, CZ + math.sin(phi) * amp)
	end
	-- profil concave de volcan : pied large et doux, sommet plus raide
	local function rayonA(y)
		local u = 1 - borne(y / SOMMET, 0, 1)
		return RAYON_HAUT + (RAYON_BAS - RAYON_HAUT) * (math.pow(u, 1.8) * 0.75 + u * 0.25)
	end
	-- point de la surface à la hauteur y dans la direction a, décalé de `ecart` vers l'extérieur
	local function surface(y, a, ecart)
		return centreA(y) + direction(a) * (rayonA(y) + (ecart or 0))
	end
	-- normale extérieure de la surface
	local function normale(y, a)
		if y >= SOMMET - 0.2 then
			return HAUT
		end
		local dr = rayonA(y + 0.5) - rayonA(y - 0.5)
		return (direction(a) - Vector3.new(0, dr, 0)).Unit
	end
	-- ramène une boule (ou un objet) dans l'emprise
	local function dansEmprise(pos, rayon)
		local dx, dz = pos.X - CX, pos.Z - CZ
		local d = math.sqrt(dx * dx + dz * dz)
		local maxi = RAYON_MAX - 0.4 - rayon
		if d > maxi and d > 0.01 then
			local k = maxi / d
			return Vector3.new(CX + dx * k, pos.Y, CZ + dz * k)
		end
		return pos
	end
	local function ecartAngle(a, b)
		return math.abs(((a - b + math.pi) % (math.pi * 2)) - math.pi)
	end

	-- ===== tracés des coulées (définis avant le relief pour y laisser des chenaux) =====
	local DECALAGES = { -0.55, 0.5, 1.8, -1.85, 3.14, 2.55 }
	local traces = {}
	for k = 1, NB_COULEES do
		local a0 = math.pi / 2 + DECALAGES[k] + rng:NextNumber(-0.12, 0.12) -- tournées vers la Place (+Z)
		table.insert(traces, {
			a0 = a0,
			phase = rng:NextNumber(0, math.pi * 2),
			ampl = rng:NextNumber(2, 3.2),
			freq = rng:NextNumber(0.1, 0.15),
		})
	end
	-- angle d'une coulée à la hauteur y : elle serpente, sauf au débord du cratère
	local function angleTrace(tr, y)
		local enveloppe = borne((SOMMET - y) / 10, 0, 1)
		local lateral = tr.ampl * math.sin(y * tr.freq + tr.phase) * enveloppe
		return tr.a0 + lateral / math.max(4, rayonA(y))
	end
	-- vrai si le point (y, a) est à moins de `marge` studs (sur le flanc) d'une coulée
	local function presDUneCoulee(a, y, marge)
		for _, tr in ipairs(traces) do
			if ecartAngle(a, angleTrace(tr, y)) * rayonA(y) < marge then
				return true
			end
		end
		return false
	end

	-- ===== le relief en terrain =====
	local terrainOk = Outils.terrainCylindre ~= nil and Outils.terrainBoule ~= nil
	if terrainOk then
		if Outils.couleurTerrain then
			Outils.couleurTerrain(M_BASALTE, BASALTE_T)
			Outils.couleurTerrain(M_FISSURE, FISSURE_T)
			Outils.couleurTerrain(M_ROCHE, CENDRE_T)
		end

		-- 1. tranches empilées (le pied descend sous l'herbe pour la remplacer)
		local y0 = -2
		while y0 < SOMMET - 0.01 do
			local ym = math.max(0, y0 + PAS / 2)
			local materiau = M_BASALTE
			if ym < LIMITE_ROCHE then
				materiau = M_ROCHE
			end
			Outils.terrainCylindre(CFrame.new(centreA(ym)) + Vector3.new(0, y0 + PAS / 2 - ym, 0), PAS + 0.4, rayonA(ym), materiau)
			y0 = y0 + PAS
		end

		-- 2. arêtes de basalte qui descendent du sommet (langues sombres dans la cendre)
		local NB_ARETES = 7
		local decalageAretes = rng:NextNumber(0, math.pi * 2)
		for k = 1, NB_ARETES do
			local a0 = (k - 0.5) / NB_ARETES * math.pi * 2 + decalageAretes + rng:NextNumber(-0.2, 0.2)
			local y = SOMMET - rng:NextNumber(2, 5)
			local yBas = rng:NextNumber(3, LIMITE_ROCHE)
			while y > yBas do
				local t = y / SOMMET
				local rad = (2.2 + 2.6 * (1 - t)) * rng:NextNumber(0.85, 1.15)
				local a = a0 + 0.07 * math.sin(y * 0.15 + k)
				if not presDUneCoulee(a, y, rad + 2.8) then
					local materiau = M_BASALTE
					if y < LIMITE_ROCHE - 6 and rng:NextNumber() < 0.5 then
						materiau = M_ROCHE
					end
					Outils.terrainBoule(dansEmprise(surface(y, a, -rad * 0.55), rad), rad, materiau)
				end
				y = y - rad * 0.8
			end
		end

		-- 3. bosses : cendre rousse dans le basalte, basalte dans la cendre
		for n = 1, 30 do
			local y = rng:NextNumber(2, SOMMET - 6)
			local a = rng:NextNumber(0, math.pi * 2)
			local t = y / SOMMET
			local rad = rng:NextNumber(2.4, 4.2) * (1 + 0.4 * (1 - t))
			if not presDUneCoulee(a, y, rad + 2.2) then
				local materiau = M_BASALTE
				if y < LIMITE_ROCHE then
					if rng:NextNumber() > 0.3 then
						materiau = M_ROCHE
					end
				elseif rng:NextNumber() < 0.25 then
					materiau = M_ROCHE
				end
				Outils.terrainBoule(dansEmprise(surface(y, a, -rad * 0.6), rad), rad, materiau)
			end
		end

		-- 3 bis. frange irrégulière entre la cendre du bas et le basalte du haut
		for n = 1, 22 do
			local a = (n - 1) / 22 * math.pi * 2 + rng:NextNumber(-0.1, 0.1)
			local rad = rng:NextNumber(2.6, 4)
			local y = LIMITE_ROCHE - rng:NextNumber(0, 6)
			if not presDUneCoulee(a, y, rad + 2.2) then
				Outils.terrainBoule(dansEmprise(surface(y, a, -rad * 0.62), rad), rad, M_BASALTE)
			end
		end

		-- 4. éboulis au pied (le volcan se fond dans l'herbe)
		for n = 1, 18 do
			local a = (n - 1) / 18 * math.pi * 2 + rng:NextNumber(-0.12, 0.12)
			local rad = rng:NextNumber(2, 3.4)
			if not presDUneCoulee(a, 0, rad + 3.5) then
				local materiau = M_ROCHE
				if rng:NextNumber() < 0.3 then
					materiau = M_BASALTE
				end
				local pos = centreA(0) + direction(a) * (RAYON_BAS + rng:NextNumber(-0.5, 1.5)) + Vector3.new(0, rng:NextNumber(-1.2, 0), 0)
				Outils.terrainBoule(dansEmprise(pos, rad), rad, materiau)
			end
		end
	else
		-- Outils sans terrain : cône de secours en parts
		for i = 1, 8 do
			local y = (i - 0.5) / 8 * SOMMET
			part(Outils.cylindre, cone, {
				Name = "Tranche" .. i,
				Size = Vector3.new(SOMMET / 8 + 0.2, rayonA(y) * 2, rayonA(y) * 2),
				CFrame = CFrame.new(centreA(y)) * CFrame.Angles(0, 0, math.pi / 2),
				Color = ROCHE_PART,
				Material = M_BASALTE,
			})
		end
	end

	-- ===== le cratère : rebord en boules, paroi fissurée, lac de lave =====
	local cS = centreA(SOMMET)
	if terrainOk then
		local NB_REBORD = 16
		for b = 1, NB_REBORD do
			local a = (b - 1) / NB_REBORD * math.pi * 2 + rng:NextNumber(-0.05, 0.05)
			local rad = rng:NextNumber(2.8, 3.6)
			local ecartMin = math.pi
			for _, tr in ipairs(traces) do
				ecartMin = math.min(ecartMin, ecartAngle(a, tr.a0))
			end
			-- échancrure là où la lave déborde
			if ecartMin > math.rad(20) then
				if ecartMin < math.rad(36) then
					rad = 2.3
				end
				Outils.terrainBoule(cS + direction(a) * RAYON_REBORD + Vector3.new(0, 0.6 + rng:NextNumber(-0.4, 0.8), 0), rad, M_BASALTE)
				-- dents du rebord : plus hautes à l'arrière (nord, -Z) pour une silhouette déchiquetée,
				-- basses à l'avant pour qu'on voie le lac depuis la Place
				local arriere = -math.sin(a) -- 1 plein nord, -1 plein sud (côté joueurs)
				if ecartMin > math.rad(40) and arriere > -0.1 then
					-- un mur de boules larges qui se chevauchent (pas des piles) : le rebord monte en crête vers le nord
					local etages = math.floor((arriere + 0.1) * 1.7 + rng:NextNumber(0, 0.7))
					local r = rad
					for e = 1, etages do
						r = r * rng:NextNumber(0.86, 0.95)
						local aE = a + rng:NextNumber(-0.12, 0.12)
						local derive = direction(aE) * (RAYON_REBORD + 0.4 + rng:NextNumber(-0.4, 0.6))
						Outils.terrainBoule(cS + derive + Vector3.new(0, 0.6 + e * rad * 0.62, 0), r, M_BASALTE)
					end
				end
			end
		end
		-- paroi intérieure fissurée (lueur orange sous le rebord)
		for b = 1, 12 do
			local a = (b - 1) / 12 * math.pi * 2
			local ecartMin = math.pi
			for _, tr in ipairs(traces) do
				ecartMin = math.min(ecartMin, ecartAngle(a, tr.a0))
			end
			if ecartMin > math.rad(16) then
				Outils.terrainBoule(cS + direction(a) * (RAYON_LAC + 1.2) + Vector3.new(0, 0.3, 0), 1.8, M_FISSURE)
			end
		end
	end

	local lac = part(Outils.cylindre, lave, propsLave({
		Name = "LacDeLave",
		Size = Vector3.new(0.8, RAYON_LAC * 2, RAYON_LAC * 2),
		CFrame = CFrame.new(cS + Vector3.new(0, 0.9, 0)) * CFrame.Angles(0, 0, math.pi / 2),
	}))
	-- cœur plus chaud au centre du lac
	part(Outils.cylindre, lave, propsLave({
		Name = "CoeurDuLac",
		Size = Vector3.new(0.3, RAYON_LAC * 1.1, RAYON_LAC * 1.1),
		CFrame = CFrame.new(cS + Vector3.new(0, 1.38, 0)) * CFrame.Angles(0, 0, math.pi / 2),
		Color = COEUR,
	}))
	-- croûtes sombres qui flottent sur le lac
	for n = 1, 5 do
		local a = n / 5 * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
		local d = rng:NextNumber(RAYON_LAC * 0.45, RAYON_LAC * 0.8)
		part(Outils.bloc, croutes, {
			Name = "Croute",
			Size = Vector3.new(rng:NextNumber(1.4, 2.4), 0.45, rng:NextNumber(1, 1.8)),
			CFrame = CFrame.new(cS + direction(a) * d + Vector3.new(0, 1.35, 0)) * CFrame.Angles(0, rng:NextNumber(0, math.pi), 0),
			Color = CROUTE,
			Material = M_BASALTE,
			CanCollide = false,
			CanQuery = false,
		})
	end
	-- bulles de lave qui flottent dans le lac
	for b = 1, 4 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(0.5, RAYON_LAC * 0.6)
		local taille = rng:NextNumber(1.2, 2)
		local bulle = part(Outils.boule, lave, propsLave({
			Name = "Bulle",
			Size = Vector3.new(taille, taille, taille),
			CFrame = CFrame.new(cS + direction(a) * d + Vector3.new(0, 1.2, 0)),
			Color = LAVE_VIVE,
		}))
		if bulle then
			Outils.animer(bulle, "flotte", rng:NextNumber(1.2, 2.2))
		end
	end

	-- ===== les coulées : lave Neon enfoncée dans un chenal creusé, qui refroidit vers le bas =====
	local coulees = {} -- parts de lave Neon (pour les changer de teinte pendant l'éruption)
	local teinteBase = {} -- teinte de repos de chaque part de lave (dégradé chaud → froid)
	local function ajouterLave(p)
		if p then
			table.insert(coulees, p)
			teinteBase[p] = p.Color
		end
		return p
	end
	ajouterLave(lac)
	local lueursPied = {}
	local lueursCoulees = {}
	local RESERVE = 50 -- parts gardées pour les fissures, rochers, orgues, cône adventif, fumerolles et la bouche

	-- teinte de la lave selon la hauteur : cœur doré au cratère, orange, puis rouge sombre en bas
	local function teinteCoulee(y)
		local t = borne(1 - y / SOMMET, 0, 1)
		return COEUR:Lerp(LAVE, t):Lerp(LAVE_FROIDE, t * t)
	end

	-- plaque orientée de pA à pB, face du dessus selon nrm (roulis facultatif autour de l'axe du ruban)
	local function ruban(parent, nom, pA, pB, largeur, epaisseur, nrm, props, roulis)
		local long = (pB - pA).Magnitude
		if long < 0.05 then
			return nil
		end
		local t = {}
		for k, v in pairs(props) do
			t[k] = v
		end
		t.Name = nom
		t.Size = Vector3.new(largeur, epaisseur, long + 0.3)
		t.CFrame = CFrame.lookAt((pA + pB) / 2, pB, nrm) * CFrame.Angles(0, 0, roulis or 0)
		return part(Outils.bloc, parent, t)
	end
	-- disque posé sur la surface (arrondit les coudes de la coulée)
	local function disquePose(parent, nom, pos, diametre, epaisseur, nrm, props)
		local tangente = HAUT:Cross(nrm)
		if tangente.Magnitude < 0.01 then
			tangente = Vector3.new(1, 0, 0)
		end
		local t = {}
		for k, v in pairs(props) do
			t[k] = v
		end
		t.Name = nom
		t.Size = Vector3.new(epaisseur, diametre, diametre)
		t.CFrame = CFrame.fromMatrix(pos, nrm, tangente.Unit)
		return part(Outils.cylindre, parent, t)
	end
	-- lave figée (non Neon) : basalte sombre ou croûte fissurée rougeâtre, en alternance
	local function propsFigee(i)
		local t = {
			CanCollide = false,
			CanQuery = false,
		}
		if i % 2 == 0 then
			t.Material = M_BASALTE
			t.Color = CROUTE:Lerp(ROCHE_PART, rng:NextNumber(0.1, 0.35))
		else
			t.Material = M_FISSURE
			t.Color = CROUTE:Lerp(LAVE_FROIDE, rng:NextNumber(0.12, 0.25))
		end
		return t
	end

	local NB_POINTS = math.max(8, math.floor(SOMMET / 4.5))
	for k, tr in ipairs(traces) do
		local coulee = Outils.modele(lave, "Coulee" .. k)
		local figee = Outils.modele(laveFigee, "Coulee" .. k)
		-- points du tracé : débord sur le lac, bord du cratère, puis le flanc jusqu'au pied
		local points = {}
		table.insert(points, { pos = cS + direction(tr.a0) * (RAYON_LAC - 1.5) + Vector3.new(0, 1.1, 0), y = SOMMET, a = tr.a0 })
		table.insert(points, { pos = cS + direction(tr.a0) * (RAYON_HAUT + 0.3) + Vector3.new(0, 0.55, 0), y = SOMMET, a = tr.a0 })
		for i = 1, NB_POINTS do
			local y = (SOMMET - 2) * (1 - (i - 1) / (NB_POINTS - 1)) + 0.5 * (i - 1) / (NB_POINTS - 1)
			local a = angleTrace(tr, y)
			table.insert(points, { pos = surface(y, a, LEVEE), y = y, a = a })
		end
		local nSeg = #points - 1
		local debutFige = math.floor(nSeg * 2 / 3) + 1 -- le dernier tiers de la coulée est figé

		-- largeur irrégulière, segment par segment (renflements et étranglements)
		local largeurs = {}
		for i = 1, nSeg do
			local q = points[i + 1]
			local base = 3 + 2.8 * (1 - q.y / SOMMET)
			largeurs[i] = math.max(1.8, base * (0.75 + 0.5 * math.noise(i * 0.4, k + 0.31)))
		end

		-- chenal dans le terrain : on creuse d'abord toute la coulée, puis on pose le lit de CrackedLava
		-- juste sous la surface d'origine (la lave affleure, ses bords sont cachés dans le creux)
		if terrainOk then
			local echantillons = {}
			for i = 1, nSeg do
				local p, q = points[i], points[i + 1]
				local long = (q.pos - p.pos).Magnitude
				local n = math.max(1, math.ceil(long / 2.2))
				for j = 0, n - 1 do
					local f = j / n
					local y = p.y + (q.y - p.y) * f
					local a = p.a + (q.a - p.a) * f
					local nrmS = normale(y, a)
					if i == 1 then
						nrmS = HAUT
					end
					table.insert(echantillons, {
						surf = p.pos:Lerp(q.pos, f) - nrmS * LEVEE,
						nrm = nrmS,
						largeur = largeurs[i],
						creuser = i > 1, -- pas de creusement sous le lac
					})
				end
			end
			for _, e in ipairs(echantillons) do
				if e.creuser then
					local radC = e.largeur / 2 + 0.8
					Outils.terrainBoule(dansEmprise(e.surf - e.nrm * (0.4 * radC), radC), radC, Enum.Material.Air)
				end
			end
			for _, e in ipairs(echantillons) do
				local radB = e.largeur / 2 + 0.6
				Outils.terrainBoule(dansEmprise(e.surf - e.nrm * (radB + 0.3), radB), radB, M_FISSURE)
			end
		end

		for i = 1, nSeg do
			local p, q = points[i], points[i + 1]
			local largeur = largeurs[i]
			local nrm = normale(q.y, q.a)
			if i == 1 then
				nrm = HAUT
			end
			local nrmSeg = (normale(p.y, p.a) + nrm).Unit
			local chaud = i < debutFige
			local seg
			if chaud then
				seg = ajouterLave(ruban(coulee, "Coulee", p.pos, q.pos, largeur, 0.6, nrmSeg, propsLave({ Color = teinteCoulee(q.y) })))
			else
				-- lave refroidie : à peine plus épaisse que le Neon (elle en recouvre la fin), un peu bosselée
				seg = ruban(figee, "LaveFigee", p.pos, q.pos, largeur, 0.66, nrmSeg, propsFigee(i), rng:NextNumber(-0.05, 0.05))
			end
			if i > 1 and i < nSeg then
				local diametre = math.max(largeur, largeurs[i + 1]) + 0.1
				if i + 1 < debutFige then
					ajouterLave(disquePose(coulee, "Coude", q.pos, diametre, 0.6, nrm, propsLave({ Color = teinteCoulee(q.y) })))
				else
					disquePose(figee, "CoudeFige", q.pos, diametre, 0.66, nrm, propsFigee(i + 1))
				end
			end
			-- levées de croûte de chaque côté (petits blocs inclinés, irréguliers, au lieu d'un bord net)
			if i > 1 and seg and compteur < BUDGET - RESERVE then
				local cfSeg = seg.CFrame
				local long = (q.pos - p.pos).Magnitude
				for _, cote in ipairs({ -1, 1 }) do
					if rng:NextNumber() < 0.8 then
						local haut = rng:NextNumber(0.35, 0.7)
						local centre = cfSeg.Position
							+ cfSeg.RightVector * cote * (largeur / 2 + rng:NextNumber(0.25, 0.55))
							+ cfSeg.LookVector * long * rng:NextNumber(-0.25, 0.25)
							+ cfSeg.UpVector * (0.05 + haut * 0.15)
						local teinte = CROUTE:Lerp(ROCHE_PART, rng:NextNumber(0.2, 0.6))
						part(Outils.bloc, croutes, {
							Name = "Levee",
							Size = Vector3.new(rng:NextNumber(0.5, 0.9), haut, long * rng:NextNumber(0.3, 0.6)),
							CFrame = CFrame.fromMatrix(centre, cfSeg.RightVector, cfSeg.UpVector)
								* CFrame.Angles(rng:NextNumber(-0.15, 0.15), rng:NextNumber(-0.35, 0.35), -cote * rng:NextNumber(0.3, 0.6)),
							Color = teinte,
							Material = M_BASALTE,
							CanCollide = false,
							CanQuery = false,
						})
					end
				end
			end
			-- lueur au milieu du flanc
			if i == math.floor(#points / 2) and seg and chaud then
				table.insert(lueursCoulees, Outils.lumiere(seg, { Range = 14, Brightness = 1.2, Color = teinteCoulee(q.y) }))
			end
		end

		-- mare au pied de la coulée, dans une cuvette de CrackedLava : lave presque éteinte, rouge sombre, croûtée
		local fin = points[#points]
		local rayonMare = 2.8
		local posMare = centreA(0) + direction(fin.a) * math.min(RAYON_BAS + 0.8, RAYON_MAX - rayonMare - 1)
		posMare = dansEmprise(Vector3.new(posMare.X, 0, posMare.Z), rayonMare + 0.6)
		if terrainOk then
			Outils.terrainCylindre(CFrame.new(posMare.X, -0.4, posMare.Z), 1.8, rayonMare + 0.5, M_FISSURE)
		end
		local mare = ajouterLave(part(Outils.cylindre, coulee, propsLave({
			Name = "Mare",
			Size = Vector3.new(0.4, rayonMare * 2, rayonMare * 2),
			CFrame = CFrame.new(posMare.X, 0.62, posMare.Z) * CFrame.Angles(0, 0, math.pi / 2),
			Color = LAVE_FROIDE:Lerp(LAVE, 0.3),
		})))
		if mare then
			local l = Outils.lumiere(mare, { Range = 12, Brightness = 1.2, Color = LAVE })
			l.Shadows = false
			table.insert(lueursPied, l)
			for n = 1, 2 do
				if compteur < BUDGET - RESERVE then
					local a = rng:NextNumber(0, math.pi * 2)
					part(Outils.bloc, croutes, {
						Name = "Croute",
						Size = Vector3.new(rng:NextNumber(1.2, 1.9), 0.35, rng:NextNumber(0.9, 1.4)),
						CFrame = CFrame.new(Vector3.new(posMare.X, 0.8, posMare.Z) + direction(a) * rng:NextNumber(0.6, 1.5))
							* CFrame.Angles(0, rng:NextNumber(0, math.pi), 0),
						Color = CROUTE,
						Material = M_BASALTE,
						CanCollide = false,
						CanQuery = false,
					})
				end
			end
		end
	end

	-- ===== fissures incandescentes dans le basalte du haut =====
	for n = 1, 6 do
		local y = rng:NextNumber(LIMITE_ROCHE + 4, SOMMET - 5)
		local a = rng:NextNumber(0, math.pi * 2)
		local essais = 0
		while presDUneCoulee(a, y, 5) and essais < 8 do
			a = rng:NextNumber(0, math.pi * 2)
			essais = essais + 1
		end
		if not presDUneCoulee(a, y, 5) then
			local fissure = Outils.modele(lave, "Fissure")
			local p1 = surface(y, a, 0.45)
			local p2 = surface(y - 2.6, a + 0.9 / rayonA(y), 0.45)
			local p3 = surface(y - 5, a - 0.4 / rayonA(y), 0.45)
			local s1 = ruban(fissure, "Fissure", p1, p2, 0.4, 0.3, normale(y, a), propsLave({}))
			local s2 = ruban(fissure, "Fissure", p2, p3, 0.35, 0.3, normale(y - 3, a), propsLave({}))
			ajouterLave(s1)
			ajouterLave(s2)
		end
	end

	-- ===== rochers de basalte au pied (petits détails, hors des coulées) =====
	for n = 1, 12 do
		local a = rng:NextNumber(0, math.pi * 2)
		if not presDUneCoulee(a, 0, 5) then
			local taille = Vector3.new(rng:NextNumber(1.8, 3.4), rng:NextNumber(1.2, 2.4), rng:NextNumber(1.8, 3))
			local pos = centreA(0) + direction(a) * (RAYON_BAS + rng:NextNumber(0.5, 2.5))
			pos = dansEmprise(Vector3.new(pos.X, taille.Y * 0.3, pos.Z), taille.Magnitude / 2)
			part(Outils.bloc, rochers, {
				Name = "Rocher",
				Size = taille,
				CFrame = CFrame.new(pos) * CFrame.Angles(rng:NextNumber(-0.4, 0.4), rng:NextNumber(0, math.pi * 2), rng:NextNumber(-0.4, 0.4)),
				Color = ROCHE_PART:Lerp(ROCHE_PART_CLAIRE, rng:NextNumber(0, 0.6)),
				Material = M_BASALTE,
			})
		end
	end

	-- hauteur du flanc à la distance r de l'axe (inverse du profil, par dichotomie)
	local function hauteurFlanc(r)
		if r >= RAYON_BAS then
			return 0
		end
		if r <= RAYON_HAUT then
			return SOMMET
		end
		local bas, haut = 0, SOMMET
		for _ = 1, 16 do
			local m = (bas + haut) / 2
			if rayonA(m) > r then
				bas = m
			else
				haut = m
			end
		end
		return (bas + haut) / 2
	end

	-- ===== orgues basaltiques : deux bouquets de colonnes au pied, côté Cratère =====
	for _, aVoulu in ipairs({ math.pi / 2 - 0.22, math.pi / 2 + 1.2 }) do
		local aOrgue = nil
		for _, d in ipairs({ 0, 0.22, -0.22, 0.4, -0.4 }) do
			if not aOrgue and not presDUneCoulee(aVoulu + d, 1, 8) then
				aOrgue = aVoulu + d
			end
		end
		if aOrgue and compteur < BUDGET - 12 then
			local orgue = Outils.modele(rochers, "Orgue")
			-- tout au pied (le flanc n'y fait que 1 à 3 studs de haut) : les colonnes restent bien visibles
			local cOrgue = centreA(0) + direction(aOrgue) * (RAYON_BAS - 0.8)
			local versVolcan = -direction(aOrgue)
			for c = 1, 7 do
				local pos = cOrgue
				if c > 1 then
					local ang = (c - 2) / 6 * math.pi * 2 + aOrgue
					pos = cOrgue + direction(ang) * rng:NextNumber(1.9, 2.3)
				end
				local diam = rng:NextNumber(1.8, 2.4)
				pos = dansEmprise(Vector3.new(pos.X, 0, pos.Z), diam / 2)
				-- plus hautes au centre et côté volcan : l'orgue monte en gradins vers le flanc
				local h = rng:NextNumber(8, 9.5)
				local ecart = Vector3.new(pos.X - cOrgue.X, 0, pos.Z - cOrgue.Z)
				if c > 1 and ecart.Magnitude > 0.01 then
					h = 5 + 2.6 * ecart.Unit:Dot(versVolcan) + rng:NextNumber(-0.8, 0.8)
				end
				local long = h + 1.5
				part(Outils.cylindre, orgue, {
					Name = "Colonne",
					Size = Vector3.new(long, diam, diam),
					CFrame = CFrame.new(pos.X, long / 2 - 1.5, pos.Z)
						* CFrame.Angles(rng:NextNumber(-0.05, 0.05), rng:NextNumber(0, math.pi * 2), rng:NextNumber(-0.05, 0.05))
						* CFrame.Angles(0, 0, math.pi / 2),
					Color = ROCHE_PART:Lerp(CROUTE, rng:NextNumber(0.15, 0.5)),
					Material = M_BASALTE,
				})
			end
		end
	end

	-- ===== cône adventif : petite bouche secondaire qui fume sur un flanc (hors des coulées) =====
	local R_ADVENTIF = 22
	local fumeesAdventif = {}
	do
		local yA = hauteurFlanc(R_ADVENTIF)
		local aC = nil
		for _, a in ipairs({ 0.3, 2.85, -0.4, 3.5 }) do
			if not aC and not presDUneCoulee(a, yA, 9) and not presDUneCoulee(a, yA * 0.5, 7) then
				aC = a
			end
		end
		if aC then
			local base = centreA(yA) + direction(aC) * R_ADVENTIF
			local HAUT_C = 7
			if terrainOk then
				local y = -5
				while y < HAUT_C - 0.01 do
					local t = (y + 5) / (HAUT_C + 5)
					local rad = 7 - 4.4 * t
					local pos = dansEmprise(Vector3.new(base.X, base.Y + y + 0.75, base.Z), rad)
					Outils.terrainCylindre(CFrame.new(pos), 1.9, rad, M_BASALTE)
					y = y + 1.5
				end
				Outils.terrainCylindre(CFrame.new(base + Vector3.new(0, HAUT_C + 0.2, 0)), 1, 2.6, M_FISSURE)
			end
			local gueule = part(Outils.boule, lave, propsLave({
				Name = "BoucheAdventive",
				Size = Vector3.new(2.8, 2.8, 2.8),
				CFrame = CFrame.new(base + Vector3.new(0, HAUT_C + 0.5, 0)),
				Color = COEUR:Lerp(LAVE, 0.4),
			}))
			if gueule then
				ajouterLave(gueule)
				local l = Outils.lumiere(gueule, { Range = 12, Brightness = 1.4, Color = LAVE })
				l.Shadows = false
				table.insert(lueursPied, l)
				pcall(function()
					local s = Instance.new("Smoke")
					s.Name = "Fumee"
					s.Color = FUMEE_CALME
					s.Opacity = 0.1
					s.RiseVelocity = 4
					s.Size = 4
					s.Parent = gueule
					table.insert(fumeesAdventif, s)
				end)
			end
		end
	end

	-- ===== fumerolles sur les flancs =====
	local fumerolles = {}
	for _, s in ipairs(fumeesAdventif) do
		table.insert(fumerolles, s)
	end
	for n = 1, 2 do
		local y = SOMMET * (0.55 + 0.15 * n)
		local a = traces[1].a0 + (n * 2 - 3) * 0.9
		local event = part(Outils.bloc, modele, {
			Name = "Fumerolle",
			Size = Vector3.new(1, 1, 1),
			CFrame = CFrame.new(surface(y, a, 0.3)),
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})
		if event then
			pcall(function()
				local s = Instance.new("Smoke")
				s.Name = "Fumee"
				s.Color = FUMEE_CALME
				s.Opacity = 0.08
				s.RiseVelocity = 3
				s.Size = 3
				s.Parent = event
				table.insert(fumerolles, s)
			end)
		end
	end

	-- ===== la bouche : fumée, braises, lueur, projections et titre flottant =====
	local bouche = part(Outils.bloc, modele, {
		Name = "Bouche",
		Size = Vector3.new(RAYON_LAC * 1.4, 1, RAYON_LAC * 1.4),
		CFrame = CFrame.new(cS + Vector3.new(0, 1.5, 0)),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
	})

	local fumee, panache, braises, lumiere, projections, alerte, chaleur
	if bouche then
		-- repères pour les effets locaux (Interface/EclatsLave) : profil du cône et taille du cratère
		bouche:SetAttribute("Sommet", SOMMET)
		bouche:SetAttribute("RayonCratere", RAYON_HAUT)
		bouche:SetAttribute("RayonLac", RAYON_LAC)
		bouche:SetAttribute("RayonBas", RAYON_BAS)

		-- halo de chaleur orangé au-dessus du lac : le cratère rougeoie de loin
		pcall(function()
			chaleur = Instance.new("ParticleEmitter")
			chaleur.Name = "Chaleur"
			chaleur.Texture = "rbxasset://textures/particles/smoke_main.dds"
			chaleur.Color = ColorSequence.new(COEUR, LAVE)
			chaleur.LightEmission = 1
			chaleur.LightInfluence = 0
			chaleur.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, RAYON_LAC * 1.4),
				NumberSequenceKeypoint.new(1, RAYON_LAC * 2.4),
			})
			chaleur.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.3, 0.86),
				NumberSequenceKeypoint.new(1, 1),
			})
			chaleur.Speed = NumberRange.new(1.5, 3)
			chaleur.Lifetime = NumberRange.new(2.5, 4)
			chaleur.Rotation = NumberRange.new(0, 360)
			chaleur.RotSpeed = NumberRange.new(-10, 10)
			chaleur.Rate = 1.5
			chaleur.Parent = bouche
		end)

		pcall(function()
			fumee = Instance.new("Smoke")
			fumee.Name = "Fumee"
			fumee.Color = FUMEE_CALME
			fumee.Opacity = 0.2
			fumee.RiseVelocity = 6
			fumee.Size = 12
			fumee.Parent = bouche
		end)

		-- panache de fumée douce qui dérive avec le vent
		pcall(function()
			panache = Instance.new("ParticleEmitter")
			panache.Name = "Panache"
			panache.Texture = "rbxasset://textures/particles/smoke_main.dds"
			panache.Color = ColorSequence.new(FUMEE_CALME, hex("BDB4AE"))
			panache.LightInfluence = 1
			panache.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 6),
				NumberSequenceKeypoint.new(1, 20),
			})
			panache.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.55),
				NumberSequenceKeypoint.new(0.6, 0.75),
				NumberSequenceKeypoint.new(1, 1),
			})
			panache.Speed = NumberRange.new(4, 7)
			panache.SpreadAngle = Vector2.new(12, 12)
			panache.Acceleration = Vector3.new(1.5, 0.8, 0)
			panache.Lifetime = NumberRange.new(6, 9)
			panache.Rotation = NumberRange.new(0, 360)
			panache.RotSpeed = NumberRange.new(-20, 20)
			panache.Rate = 3
			panache.Parent = bouche
		end)

		-- braises qui s'échappent du lac en permanence
		pcall(function()
			braises = Instance.new("ParticleEmitter")
			braises.Name = "Braises"
			braises.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			braises.Color = ColorSequence.new(BRAISE, LAVE)
			braises.LightEmission = 1
			braises.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 0),
			})
			braises.Speed = NumberRange.new(6, 12)
			braises.SpreadAngle = Vector2.new(40, 40)
			braises.Acceleration = Vector3.new(0.8, -2, 0)
			braises.Lifetime = NumberRange.new(1.5, 3)
			braises.Rate = 6
			braises.Parent = bouche
		end)

		lumiere = Outils.lumiere(bouche, { Range = 40, Brightness = 2, Color = LAVE })
		lumiere.Name = "Lueur"
		lumiere.Shadows = false

		pcall(function()
			projections = Instance.new("ParticleEmitter")
			projections.Name = "Projections"
			projections.EmissionDirection = Enum.NormalId.Top
			projections.Color = ColorSequence.new(BRAISE, LAVE)
			projections.LightEmission = 1
			projections.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.8),
				NumberSequenceKeypoint.new(1, 0.5),
			})
			projections.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.8, 0.1),
				NumberSequenceKeypoint.new(1, 1),
			})
			projections.Speed = NumberRange.new(35, 55)
			projections.SpreadAngle = Vector2.new(35, 35)
			projections.Acceleration = Vector3.new(0, -40, 0)
			projections.Lifetime = NumberRange.new(2.2, 3.4)
			projections.Rotation = NumberRange.new(0, 360)
			projections.RotSpeed = NumberRange.new(-120, 120)
			projections.Rate = reglage("projectionsParSeconde", 45)
			projections.Enabled = false
			projections.Parent = bouche
		end)

		-- titre géant flottant au-dessus du cratère (grammaire des lieux : texte cerné, dégradé orange)
		if Style and type(Style.etiquette) == "function" then
			pcall(function()
				local _, textes = Style.etiquette(bouche, {
					{ texte = "", nom = "Alerte", couleur = ALERTE, taille = 0.7 },
					{ texte = "🌋 VOLCAN", nom = "Titre", couleur = BLANC, titre = true, contour = 4 },
				}, {
					Name = "EtiquetteVolcan",
					largeur = 34,
					hauteurLigne = 7,
					StudsOffset = Vector3.new(0, 16, 0),
					MaxDistance = 500,
					AlwaysOnTop = false,
				})
				if textes then
					alerte = textes[1]
					if textes[2] and type(Style.degrade) == "function" then
						Style.degrade(textes[2], TITRE_HAUT, TITRE_BAS)
					end
					if textes[1] and type(Style.contour) == "function" then
						local c = textes[1]:FindFirstChild("Contour")
						if c then
							c.Thickness = 4
							c.Color = CONTOUR
						end
					end
				end
			end)
		end
	end

	-- la lave pulse doucement au calme
	Outils.animer(lave, "pulse", VITESSE_PULSE_CALME)

	-- ===== réaction à l'éruption =====
	local Etat = ctx.Etat
	local generation = 0 -- change à chaque bascule : arrête l'ancienne boucle de scintillement

	local function appliquer(enEruption)
		generation = generation + 1
		local maGeneration = generation
		pcall(function()
			-- au calme chaque part reprend sa teinte du dégradé ; en éruption tout s'embrase vers le jaune-orange
			for _, p in ipairs(coulees) do
				if p.Parent then
					local base = teinteBase[p] or LAVE
					if enEruption then
						p.Color = base:Lerp(LAVE_VIVE, 0.75)
					else
						p.Color = base
					end
				end
			end
			for _, l in ipairs(lueursPied) do
				if l.Parent then
					if enEruption then
						l.Brightness = 2.5
						l.Range = 16
					else
						l.Brightness = 1.2
						l.Range = 12
					end
				end
			end
			for _, l in ipairs(lueursCoulees) do
				if l.Parent then
					if enEruption then
						l.Brightness = 2.5
						l.Range = 18
					else
						l.Brightness = 1.2
						l.Range = 14
					end
				end
			end
		end)
		pcall(function()
			if enEruption then
				Outils.animer(lave, "pulse", VITESSE_PULSE_ERUPTION)
			else
				Outils.animer(lave, "pulse", VITESSE_PULSE_CALME)
			end
		end)
		pcall(function()
			if projections then
				projections.Enabled = enEruption
			end
			if braises then
				if enEruption then
					braises.Rate = 40
				else
					braises.Rate = 6
				end
			end
			if chaleur then
				if enEruption then
					chaleur.Rate = 5
				else
					chaleur.Rate = 1.5
				end
			end
			if panache then
				if enEruption then
					panache.Rate = 10
					panache.Color = ColorSequence.new(FUMEE_ERUPTION, hex("3A3238"))
				else
					panache.Rate = 3
					panache.Color = ColorSequence.new(FUMEE_CALME, hex("BDB4AE"))
				end
			end
			for _, s in ipairs(fumerolles) do
				if enEruption then
					s.Opacity = 0.25
					s.Color = FUMEE_ERUPTION
				else
					s.Opacity = 0.08
					s.Color = FUMEE_CALME
				end
			end
			if fumee then
				if enEruption then
					fumee.Color = FUMEE_ERUPTION
					fumee.Opacity = 0.5
					fumee.RiseVelocity = 14
					fumee.Size = 22
				else
					fumee.Color = FUMEE_CALME
					fumee.Opacity = 0.2
					fumee.RiseVelocity = 6
					fumee.Size = 12
				end
			end
			if lumiere then
				if enEruption then
					lumiere.Range = 60
					lumiere.Brightness = 6
				else
					lumiere.Range = 40
					lumiere.Brightness = 2
				end
			end
			if alerte then
				if enEruption then
					alerte.Text = "⚠️ ÉRUPTION ! ⚠️"
				else
					alerte.Text = ""
				end
			end
		end)
		-- scintillement de la lueur pendant l'éruption
		if enEruption and lumiere then
			task.spawn(function()
				local alea = Random.new()
				while generation == maGeneration and lumiere.Parent and dossier.Parent do
					lumiere.Brightness = alea:NextNumber(4.5, 7.5)
					task.wait(0.15)
				end
			end)
		end
	end

	local etatCourant = false
	local function verifier()
		local evenement = ""
		if Etat then
			local ok, valeur = pcall(function()
				return Etat:GetAttribute("Evenement")
			end)
			if ok and type(valeur) == "string" then
				evenement = valeur
			end
		end
		local enEruption = evenement == "Eruption"
		if enEruption ~= etatCourant then
			etatCourant = enEruption
			appliquer(enEruption)
		end
	end

	if Etat then
		local ok, signal = pcall(function()
			return Etat:GetAttributeChangedSignal("Evenement")
		end)
		if ok and signal then
			local connexion
			connexion = signal:Connect(function()
				if not dossier.Parent then
					connexion:Disconnect()
					return
				end
				verifier()
			end)
		end
	end
	verifier()
end

return M
