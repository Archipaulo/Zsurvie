-- Constructeur Nurserie : la couveuse d'où sortent les dinos, à l'ouest du Tapis (plan v2 « plus d'air »).
-- De l'ouest vers l'est, le long du couloir du Tapis (qui reste libre, sans rien au sol) :
--   * bottes de paille (sud) et foyer à bouilloire fumante (nord) au pied de la couveuse ;
--   * la Couveuse : halle en bois (Wood, WoodPlanks) au toit de palmes à deux pans qui enjambe le couloir
--     très haut, cheminée de vapeur sur le faîtage, et de chaque côté une caisse de paille tenant deux œufs
--     sous une lampe suspendue ;
--   * deux Nids de paille (Grass, Sand) de part et d'autre du couloir, œufs lisses tachetés aux couleurs des
--     raretés (l'un fissuré laisse passer un bébé dino qui pointe le museau), lampes chauffantes à deux têtes ;
--   * l'Arche d'entrée : piliers en rondins cerclés d'or sur socles de pierre, linteau en rondin, toit de
--     palmes, enseigne « 🥚 NURSERIE » au-dessus du couloir, lanternes et œuf doré qui tourne au sommet.
-- Vie : œufs qui remuent (Outils.animer « flotte » / « tourne »), bébé qui sort la tête, ampoules qui
-- respirent, vapeur chaude (particules légères) sur les nids, les caisses, la cheminée et la bouilloire.
-- Emprise (CONTRAT §10) : disque de rayon Plan.nurserie.rayon autour de Plan.nurserie.centre ; couloir du
-- Tapis (|z| ≤ largeur / 2 + 1) laissé libre : seuls le toit de la couveuse, l'enseigne et le linteau de
-- l'arche le survolent, bien au-dessus du sol. Aucune coordonnée en dur : tout est relatif au Plan.
local M = {}

local BUDGET = 290 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	local Style = ctx.Style
	local MAT = Enum.Material
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- réglages facultatifs (Equilibrage.nurserie), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.nurserie) == "table" then
		reglages = ctx.Equilibrage.nurserie
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	-- emprise : uniquement Plan.nurserie et Plan.tapis
	local infoNurserie = Plan.nurserie
	if type(infoNurserie) ~= "table" or typeof(infoNurserie.centre) ~= "Vector3" then
		return
	end
	local CENTRE = infoNurserie.centre
	local RAYON = tonumber(infoNurserie.rayon) or 15
	local CX, CZ = CENTRE.X, CENTRE.Z
	local largeurTapis = 14
	if Plan.tapis and type(Plan.tapis.largeur) == "number" then
		largeurTapis = Plan.tapis.largeur
	end
	local COULOIR = largeurTapis / 2 + 1 -- demi-largeur du couloir libre (8 avec le plan v2)
	local HAUT_LIBRE = 9                  -- au-dessus de cette hauteur, le couloir peut être survolé
	local MARGE = 0.05

	local rng = Outils.aleatoire(reglage("graine", 1128))

	-- ===== couleurs (toutes dérivées de la Charte), en trois teintes pour le volume =====
	local PAILLE = Charte.dore:Lerp(Charte.sable, 0.4)
	local PAILLE_OMBRE = Charte.ombre(PAILLE)
	local PAILLE_LUM = Charte.lumiere(PAILLE)
	local BOIS = Charte.bois
	local BOIS_OMBRE = Charte.ombre(BOIS)
	local BOIS_SOMBRE = Charte.ombre(BOIS_OMBRE)
	local BOIS_LUM = Charte.lumiere(BOIS)
	local PALME = Charte.jungle
	local PALME_OMBRE = Charte.ombre(Charte.jungle)
	local PALME_LUM = Charte.herbe
	local PIERRE = Charte.pierre:Lerp(Charte.creme, 0.35)
	local PIERRE_OMBRE = Charte.ombre(PIERRE)
	local METAL = Charte.pierre
	local CUIVRE = Charte.lave:Lerp(Charte.bois, 0.45)
	local ABAT_JOUR = Charte.alerte
	local CHALEUR = Charte.lave:Lerp(Charte.dore, 0.4)
	local BRAISE = Charte.lave
	local DORE = Charte.dore
	local ENSEIGNE = Charte.lave
	local CREME = Charte.creme
	local VAPEUR = Charte.creme:Lerp(Charte.gemme, 0.08)
	local ENCRE = Charte.encre
	local BLANC = Charte.creme
	if Style and Style.couleurs and Style.couleurs.texte then
		BLANC = Style.couleurs.texte
	end
	if Style and Style.couleurs and Style.couleurs.contour then
		ENCRE = Style.couleurs.contour
	end

	-- couleurs des raretés, triées de la plus commune à la plus rare
	local raretes = {}
	local infosRaretes = (ctx.Equilibrage and ctx.Equilibrage.raretes) or {}
	for cle, infos in pairs(infosRaretes) do
		if type(infos) == "table" then
			table.insert(raretes, { cle = cle, ordre = tonumber(infos.ordre) or 99 })
		end
	end
	table.sort(raretes, function(a, b)
		return a.ordre < b.ordre
	end)
	local function couleurRarete(cle)
		if Charte.raretes and Charte.raretes[cle] then
			return Charte.raretes[cle]
		end
		return CREME
	end
	local function rareteNumero(n)
		if #raretes == 0 then
			return "Commun"
		end
		local i = ((n - 1) % #raretes) + 1
		return raretes[i].cle
	end

	-- ===== garde-fous : emprise et budget =====
	local compteur = 0
	local refusees = 0

	-- vrai si la part (CFrame, taille) reste dans le disque et hors du couloir (sauf si elle le survole)
	local function dansEmprise(cf, taille, estBoule)
		if estBoule then
			local r = math.min(taille.X, taille.Y, taille.Z) / 2
			local p = cf.Position
			local d = math.sqrt((p.X - CX) * (p.X - CX) + (p.Z - CZ) * (p.Z - CZ))
			if d + r > RAYON - MARGE then
				return false
			end
			if p.Y - r < -0.5 then
				return false
			end
			if p.Y - r < HAUT_LIBRE and math.abs(p.Z - CZ) - r < COULOIR then
				return false
			end
			return true
		end
		local hx, hy, hz = taille.X / 2, taille.Y / 2, taille.Z / 2
		local minY = math.huge
		local zMin, zMax = math.huge, -math.huge
		for ix = -1, 1, 2 do
			for iy = -1, 1, 2 do
				for iz = -1, 1, 2 do
					local p = cf:PointToWorldSpace(Vector3.new(ix * hx, iy * hy, iz * hz))
					if p.Y < minY then
						minY = p.Y
					end
					local dx, dz = p.X - CX, p.Z - CZ
					if dx * dx + dz * dz > (RAYON - MARGE) * (RAYON - MARGE) then
						return false
					end
					if dz < zMin then zMin = dz end
					if dz > zMax then zMax = dz end
				end
			end
		end
		if minY < -0.5 then
			return false
		end
		if minY < HAUT_LIBRE and zMax > -COULOIR and zMin < COULOIR then
			return false
		end
		return true
	end

	-- crée une part via Outils si le budget et l'emprise le permettent ; renvoie nil sinon
	local function poser(genre, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		if not props.CFrame or not props.Size then
			return nil
		end
		if not dansEmprise(props.CFrame, props.Size, genre == "boule") then
			refusees = refusees + 1
			return nil
		end
		local fabrique = Outils.bloc
		if genre == "coin" then
			fabrique = Outils.coin
		elseif genre == "cylindre" then
			fabrique = Outils.cylindre
		elseif genre == "boule" then
			fabrique = Outils.boule
		end
		local ok, part = pcall(fabrique, parent, props)
		if not ok then
			return nil
		end
		compteur = compteur + 1
		if props.CanCollide == nil then
			part.CanCollide = false
		end
		return part
	end

	-- position monde depuis (x le long du couloir, hauteur, distance a au couloir, côté s = ±1)
	local function P(x, y, a, s)
		return Vector3.new(CX + x, y, CZ + s * a)
	end
	-- cylindre vertical (l'axe d'un cylindre Roblox est X)
	local function cfVertical(pos)
		return CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
	end
	-- lampe chauffante : PointLight orangée avec ombres
	local function lumiereChaude(part, portee, eclat, couleur, ombres)
		pcall(function()
			local l = Outils.lumiere(part, { Range = portee, Brightness = eclat, Color = couleur or CHALEUR })
			l.Shadows = ombres ~= false
		end)
	end
	-- vapeur chaude : quelques volutes blanches qui montent doucement (effet léger : débit de 1 à 3 par seconde)
	local function vapeur(part, debit, taille, vitesse, nom)
		if not part then
			return
		end
		pcall(function()
			local e = Instance.new("ParticleEmitter")
			e.Name = nom or "Vapeur"
			e.Texture = "rbxasset://textures/particles/smoke_main.dds"
			e.Color = ColorSequence.new(VAPEUR, CREME)
			e.LightEmission = 0.15
			e.LightInfluence = 0.6
			e.Size = NumberSequence.new(taille, taille * 2.6)
			e.Transparency = NumberSequence.new(0.55, 1)
			e.Lifetime = NumberRange.new(2.2, 3.6)
			e.Rate = debit
			e.Speed = NumberRange.new(vitesse * 0.6, vitesse)
			e.SpreadAngle = Vector2.new(14, 14)
			e.Acceleration = Vector3.new(0.25, 0.5, 0)
			e.Drag = 0.4
			e.Rotation = NumberRange.new(0, 360)
			e.RotSpeed = NumberRange.new(-25, 25)
			e.EmissionDirection = Enum.NormalId.Top
			e.Parent = part
		end)
	end
	-- étincelles dorées (œuf de l'arche, œuf qui éclot)
	local function etincelles(part, debit)
		if not part then
			return
		end
		pcall(function()
			local e = Instance.new("ParticleEmitter")
			e.Name = "Etincelles"
			e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			e.Color = ColorSequence.new(Charte.lumiere(DORE), DORE)
			e.LightEmission = 1
			e.Size = NumberSequence.new(0.35, 0)
			e.Transparency = NumberSequence.new(0.1, 1)
			e.Lifetime = NumberRange.new(1, 1.8)
			e.Rate = debit
			e.Speed = NumberRange.new(0.6, 1.4)
			e.SpreadAngle = Vector2.new(70, 70)
			e.EmissionDirection = Enum.NormalId.Top
			e.Parent = part
		end)
	end

	-- ===== œufs lisses tachetés =====
	local oeufs = Outils.modele(dossier, "Oeufs")

	-- tache plate (disque) posée sur la surface d'une boule de centre `centre` et de rayon `rayon`
	local function tache(parent, centre, rayon, direction, couleur, diametre)
		local d = direction.Unit
		local pos = centre + d * (rayon - 0.03)
		return poser("cylindre", parent, {
			Name = "Tache",
			Size = Vector3.new(0.16, diametre, diametre),
			CFrame = CFrame.lookAt(pos, pos + d) * CFrame.Angles(0, math.rad(90), 0),
			Color = couleur,
			Material = MAT.SmoothPlastic,
		})
	end

	-- fissure lumineuse : fin segment Neon plaqué sur la surface
	local function fissure(parent, centre, rayon, direction, rotation, couleur)
		local d = direction.Unit
		local pos = centre + d * (rayon - 0.04)
		return poser("bloc", parent, {
			Name = "Fissure",
			Size = Vector3.new(1.2, 0.2, 0.25),
			CFrame = CFrame.lookAt(pos, pos + d) * CFrame.Angles(0, 0, math.rad(rotation)),
			Color = couleur,
			Material = MAT.Neon,
		})
	end

	-- un œuf : trois boules lisses (bas, ventre, calotte) et des taches tournées vers le couloir.
	-- options : fissure (bool), bebe (bool), remue (vitesse : petits sauts), tourne (vitesse : pivote lentement)
	local numeroOeuf = 0
	local function oeuf(x, a, s, diametre, ySol, rangRarete, options)
		options = options or {}
		numeroOeuf = numeroOeuf + 1
		local cle = rareteNumero(rangRarete)
		local teinte = couleurRarete(cle)
		local motif = BLANC
		if cle == "Secret" then
			motif = ENCRE
		end
		local m = Outils.modele(oeufs, "Oeuf" .. numeroOeuf)
		m:SetAttribute("Rarete", cle)

		local R = diametre / 2
		local base = P(x, ySol + R - 0.35, a, s)
		local versCouloir = Vector3.new(0, 0, -s)
		-- boules très proches les unes des autres : profil d'œuf continu, sans « cou » visible
		local centreVentre = base + Vector3.new(0, R * 0.26, 0)
		local rVentre = R * 0.96
		local centreHaut = base + Vector3.new(0, R * 0.56, 0)
		if options.fissure then
			-- la calotte a glissé : l'œuf commence à éclore
			centreHaut = base + Vector3.new(0.45 * R, R * 0.6, s * 0.3 * R)
		end

		local bas = poser("boule", m, {
			Name = "Coquille",
			Size = Vector3.new(diametre, diametre, diametre),
			CFrame = CFrame.new(base),
			Color = teinte,
			Material = MAT.SmoothPlastic,
			Reflectance = 0.06,
			CanCollide = true,
		})
		poser("boule", m, {
			Name = "Ventre",
			Size = Vector3.new(2 * rVentre, 2 * rVentre, 2 * rVentre),
			CFrame = CFrame.new(centreVentre),
			Color = teinte,
			Material = MAT.SmoothPlastic,
			Reflectance = 0.06,
			CanCollide = true,
		})
		local haut = poser("boule", m, {
			Name = "Calotte",
			Size = Vector3.new(1.68 * R, 1.68 * R, 1.68 * R),
			CFrame = CFrame.new(centreHaut),
			Color = Charte.lumiere(teinte):Lerp(teinte, 0.5),
			Material = MAT.SmoothPlastic,
			Reflectance = 0.06,
			CanCollide = true,
		})
		if bas then
			m.PrimaryPart = bas
		end

		-- taches : surtout sur la face tournée vers le couloir, une au dos, à des hauteurs variées
		local azimutBase = math.atan2(versCouloir.Z, versCouloir.X)
		local reperes = { { -0.9, 0.15, 0.36 }, { 0.35, 0.55, 0.28 }, { 1.0, -0.05, 0.24 }, { 3.3, 0.3, 0.32 } }
		for _, rp in ipairs(reperes) do
			local az = azimutBase + rp[1] + rng:NextNumber(-0.2, 0.2)
			local dir = Vector3.new(math.cos(az), rp[2], math.sin(az))
			tache(m, centreVentre, rVentre, dir, motif, diametre * rp[3])
		end

		if options.fissure then
			-- fissures en zigzag tournées vers le couloir
			local points = {
				{ dir = versCouloir + Vector3.new(-0.4, 0.55, 0), rot = 30 },
				{ dir = versCouloir + Vector3.new(0, 0.45, 0), rot = -35 },
				{ dir = versCouloir + Vector3.new(0.4, 0.55, 0), rot = 30 },
			}
			for _, pf in ipairs(points) do
				local f = fissure(m, centreVentre, rVentre, pf.dir, pf.rot, Charte.lumiere(DORE))
				if f then
					Outils.animer(f, "pulse", 2.2)
				end
			end
			if bas then
				lumiereChaude(bas, 8, 1.2, teinte, false)
			end
			if haut then
				etincelles(haut, 2)
			end
			-- éclats de coquille devant l'œuf
			for e = -1, 1, 2 do
				local taille = Vector3.new(0.7, 0.28, 0.55)
				local pos = P(x + e * R * 0.7, ySol + 0.14, a - R * 0.95, s)
				poser("coin", m, {
					Name = "Eclat",
					Size = taille,
					CFrame = CFrame.new(pos) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0),
					Color = Charte.lumiere(teinte),
					Material = MAT.SmoothPlastic,
				})
			end
		end

		-- un bébé dino pointe le museau hors de l'œuf, regard vers le couloir ; il monte et redescend
		-- (modèle à part : l'œuf lui-même reste immobile pour ne pas mélanger deux animations)
		if options.bebe and haut then
			local bebe = Outils.modele(m, "Bebe")
			local peau = Charte.herbe
			local tete = centreVentre + Vector3.new(0, rVentre * 0.85, 0) + versCouloir * (rVentre * 0.4)
			local cfTete = CFrame.lookAt(tete, tete + versCouloir + Vector3.new(0, 0.25, 0))
			local tetePart = poser("bloc", bebe, { Name = "TeteBebe", Size = Vector3.new(1.3, 1.1, 1.2), CFrame = cfTete, Color = peau, Material = MAT.SmoothPlastic })
			if tetePart then
				bebe.PrimaryPart = tetePart
				poser("bloc", bebe, {
					Name = "MuseauBebe",
					Size = Vector3.new(0.95, 0.6, 0.8),
					CFrame = cfTete * CFrame.new(0, -0.15, -0.8),
					Color = Charte.lumiere(peau),
					Material = MAT.SmoothPlastic,
				})
				poser("bloc", bebe, {
					Name = "CreteBebe",
					Size = Vector3.new(0.3, 0.45, 0.8),
					CFrame = cfTete * CFrame.new(0, 0.7, 0.1),
					Color = Charte.ombre(peau),
					Material = MAT.SmoothPlastic,
				})
				poser("boule", bebe, { Name = "OeilG", Size = Vector3.new(0.34, 0.34, 0.34), CFrame = cfTete * CFrame.new(-0.36, 0.25, -0.6), Color = ENCRE })
				poser("boule", bebe, { Name = "OeilD", Size = Vector3.new(0.34, 0.34, 0.34), CFrame = cfTete * CFrame.new(0.36, 0.25, -0.6), Color = ENCRE })
				Outils.animer(bebe, "flotte", 1.3)
			end
		elseif options.remue then
			Outils.animer(m, "flotte", options.remue)
		elseif options.tourne and not options.fissure then
			Outils.animer(m, "tourne", options.tourne)
		end
		return m
	end

	-- ===== 1. l'arche d'entrée, au bord est du disque, juste avant le début du Tapis =====
	local arche = Outils.modele(dossier, "Arche")
	local ZP = COULOIR + 2           -- axe des piliers, dans l'alignement des rebords du Tapis
	local R_PILIER = 1.15
	local R_SOCLE = 1.55
	-- le socle doit tenir dans le disque : on recule l'arche vers l'ouest autant qu'il le faut
	local XA = math.sqrt(math.max(0, (RAYON - 0.3) * (RAYON - 0.3) - (ZP + R_SOCLE) * (ZP + R_SOCLE))) - R_SOCLE
	XA = math.max(0, math.min(XA, RAYON - 6))
	local Y_LINTEAU = 14.6
	for _, s in ipairs({ 1, -1 }) do
		-- socle de pierre à deux étages
		poser("cylindre", arche, {
			Name = "Socle",
			Size = Vector3.new(1.0, 2 * R_SOCLE, 2 * R_SOCLE),
			CFrame = cfVertical(P(XA, 0.5, ZP, s)),
			Color = PIERRE_OMBRE,
			Material = MAT.Cobblestone,
			CanCollide = true,
		})
		poser("cylindre", arche, {
			Name = "SocleHaut",
			Size = Vector3.new(0.5, 2 * R_SOCLE - 0.4, 2 * R_SOCLE - 0.4),
			CFrame = cfVertical(P(XA, 1.25, ZP, s)),
			Color = PIERRE,
			Material = MAT.Slate,
			CanCollide = true,
		})
		-- pilier en rondin
		local hPilier = Y_LINTEAU - 1.5
		poser("cylindre", arche, {
			Name = "Pilier",
			Size = Vector3.new(hPilier, 2 * R_PILIER, 2 * R_PILIER),
			CFrame = cfVertical(P(XA, 1.5 + hPilier / 2, ZP, s)),
			Color = BOIS,
			Material = MAT.Wood,
			CanCollide = true,
		})
		-- cerclages dorés
		for _, yB in ipairs({ 3.2, 11.4 }) do
			poser("cylindre", arche, {
				Name = "Cerclage",
				Size = Vector3.new(0.45, 2 * R_PILIER + 0.2, 2 * R_PILIER + 0.2),
				CFrame = cfVertical(P(XA, yB, ZP, s)),
				Color = DORE,
				Material = MAT.Metal,
			})
		end
		-- lanterne sur la face est du pilier, vers le Tapis
		local xL = XA + R_PILIER + 0.55
		poser("bloc", arche, {
			Name = "Potence",
			Size = Vector3.new(0.9, 0.25, 0.25),
			CFrame = CFrame.new(P(XA + R_PILIER + 0.2, 8.1, ZP, s)),
			Color = METAL,
			Material = MAT.Metal,
		})
		local lanterne = poser("boule", arche, {
			Name = "Lanterne",
			Size = Vector3.new(0.95, 0.95, 0.95),
			CFrame = CFrame.new(P(xL, 7.45, ZP, s)),
			Color = CHALEUR,
			Material = MAT.Neon,
		})
		poser("cylindre", arche, {
			Name = "Chapeau",
			Size = Vector3.new(0.3, 1.2, 1.2),
			CFrame = cfVertical(P(xL, 8.05, ZP, s)),
			Color = METAL,
			Material = MAT.Metal,
		})
		if lanterne then
			lumiereChaude(lanterne, 12, 1.4, CHALEUR, true)
		end
	end

	-- linteau : gros rondin surmonté d'une poutre en planches
	poser("cylindre", arche, {
		Name = "Linteau",
		Size = Vector3.new(2 * ZP + 3.4, 2, 2),
		CFrame = CFrame.new(P(XA, Y_LINTEAU, 0, 1)) * CFrame.Angles(0, math.rad(90), 0),
		Color = BOIS_OMBRE,
		Material = MAT.Wood,
	})
	poser("bloc", arche, {
		Name = "Poutre",
		Size = Vector3.new(2.6, 0.8, 2 * ZP + 1.6),
		CFrame = CFrame.new(P(XA, Y_LINTEAU + 1.3, 0, 1)),
		Color = BOIS_LUM,
		Material = MAT.WoodPlanks,
	})
	-- clous dorés sur la face est de la poutre
	for k = -2, 2 do
		if k ~= 0 then
			local zc = k * ZP * 0.4
			poser("cylindre", arche, {
				Name = "Clou",
				Size = Vector3.new(0.2, 0.4, 0.4),
				CFrame = CFrame.new(P(XA + 1.35, Y_LINTEAU + 1.3, zc, 1)),
				Color = DORE,
				Material = MAT.Metal,
			})
		end
	end

	-- toit de palmes à deux pans (est / ouest) sur le linteau
	local Y_FAITE_ARCHE = Y_LINTEAU + 3.9
	local Y_BORD_ARCHE = Y_LINTEAU + 1.8
	local DEBORD_ARCHE = 2.2
	local penteArche = math.atan2(Y_FAITE_ARCHE - Y_BORD_ARCHE, DEBORD_ARCHE)
	local longueurPan = math.sqrt(DEBORD_ARCHE * DEBORD_ARCHE + (Y_FAITE_ARCHE - Y_BORD_ARCHE) * (Y_FAITE_ARCHE - Y_BORD_ARCHE)) + 0.4
	for _, u in ipairs({ 1, -1 }) do
		local milieu = P(XA + u * DEBORD_ARCHE / 2, (Y_FAITE_ARCHE + Y_BORD_ARCHE) / 2, 0, 1)
		local couleur = PALME
		if u < 0 then
			couleur = PALME_OMBRE
		end
		poser("bloc", arche, {
			Name = "Palmes",
			Size = Vector3.new(longueurPan, 0.7, 2 * ZP),
			CFrame = CFrame.new(milieu) * CFrame.Angles(0, 0, -u * penteArche) * CFrame.new(0, 0.35, 0),
			Color = couleur,
			Material = MAT.LeafyGrass,
		})
	end
	-- frange de palmes en dents de scie sous le bord est
	local nbFrangeArche = 4
	for k = -nbFrangeArche, nbFrangeArche do
		local zf = k * (ZP - 0.9) / nbFrangeArche
		poser("bloc", arche, {
			Name = "Frange",
			Size = Vector3.new(0.2, 1.5, 1.5),
			CFrame = CFrame.new(P(XA + DEBORD_ARCHE - 0.1, Y_BORD_ARCHE - 0.05, zf, 1)) * CFrame.Angles(math.rad(45), 0, 0),
			Color = PALME_LUM,
			Material = MAT.Grass,
		})
	end
	-- faîtage en paille
	poser("cylindre", arche, {
		Name = "Faitage",
		Size = Vector3.new(2 * ZP + 0.8, 1.1, 1.1),
		CFrame = CFrame.new(P(XA, Y_FAITE_ARCHE + 0.2, 0, 1)) * CFrame.Angles(0, math.rad(90), 0),
		Color = PAILLE,
		Material = MAT.Grass,
	})

	-- enseigne suspendue sous le linteau, lisible des deux côtés
	local largeurEnseigne = math.min(2 * (ZP - R_PILIER) - 0.9, 15)
	local Y_ENSEIGNE = Y_LINTEAU - 2.7
	poser("bloc", arche, {
		Name = "Cadre",
		Size = Vector3.new(0.45, 3.5, largeurEnseigne + 0.5),
		CFrame = CFrame.new(P(XA, Y_ENSEIGNE, 0, 1)),
		Color = ENCRE, -- liseré sombre épais, comme les contours de l'interface
		Material = MAT.WoodPlanks,
	})
	local enseigne = poser("bloc", arche, {
		Name = "Enseigne",
		Size = Vector3.new(0.65, 3.0, largeurEnseigne),
		CFrame = CFrame.new(P(XA, Y_ENSEIGNE, 0, 1)),
		Color = ENSEIGNE,
		Material = MAT.WoodPlanks,
	})
	if enseigne then
		for _, face in ipairs({ "Right", "Left" }) do
			pcall(function()
				local police = nil
				if Style then
					police = Style.policeTitre
				end
				local etiquette = Outils.texte(enseigne, face, "🥚 NURSERIE", { couleur = BLANC, pixelsParStud = 40, police = police })
				local gui = etiquette.Parent
				gui.Name = "Affiche"
				etiquette.Name = "Titre"
				if Style then
					Style.contour(etiquette, 4)
				else
					local contour = Instance.new("UIStroke")
					contour.Color = ENCRE
					contour.Thickness = 4
					contour.Parent = etiquette
				end
				local marge = Instance.new("UIPadding")
				marge.PaddingTop = UDim.new(0.12, 0)
				marge.PaddingBottom = UDim.new(0.12, 0)
				marge.PaddingLeft = UDim.new(0.05, 0)
				marge.PaddingRight = UDim.new(0.05, 0)
				marge.Parent = etiquette
			end)
		end
	end

	-- œuf doré qui trône sur le faîtage et tourne lentement en scintillant
	local oeufArche = Outils.modele(arche, "OeufArche")
	local couleurArche = couleurRarete("Legendaire")
	local yBase = Y_FAITE_ARCHE + 0.5
	local coquilleArche = poser("boule", oeufArche, {
		Name = "Coquille",
		Size = Vector3.new(2.3, 2.3, 2.3),
		CFrame = CFrame.new(P(XA, yBase + 1.05, 0, 1)),
		Color = couleurArche,
		Material = MAT.SmoothPlastic,
		Reflectance = 0.1,
	})
	poser("boule", oeufArche, {
		Name = "Calotte",
		Size = Vector3.new(1.75, 1.75, 1.75),
		CFrame = CFrame.new(P(XA, yBase + 1.9, 0, 1)),
		Color = Charte.lumiere(couleurArche),
		Material = MAT.SmoothPlastic,
		Reflectance = 0.1,
	})
	tache(oeufArche, P(XA, yBase + 1.05, 0, 1), 1.15, Vector3.new(1, 0.3, 0.4), BLANC, 0.7)
	tache(oeufArche, P(XA, yBase + 1.05, 0, 1), 1.15, Vector3.new(1, -0.1, -0.5), BLANC, 0.5)
	tache(oeufArche, P(XA, yBase + 1.05, 0, 1), 1.15, Vector3.new(-1, 0.2, 0.2), BLANC, 0.6)
	if coquilleArche then
		oeufArche.PrimaryPart = coquilleArche
		etincelles(coquilleArche, 3)
	end
	Outils.animer(oeufArche, "tourne", 0.6)

	-- ===== 2. la Couveuse : halle en bois au toit de palmes qui enjambe le couloir =====
	local couveuse = Outils.modele(dossier, "Couveuse")
	local X_POTEAUX = { -7.4, -2.2 }
	local X_TOIT_MIN, X_TOIT_MAX = -8.1, -1.5
	local A_POTEAU = COULOIR + 2.6
	local A_BORD = A_POTEAU + 1.1 -- bord du toit (égout)
	local Y_FAITE = 16.8
	local Y_SABLIERE = 10.0
	local PENTE = (Y_FAITE - 10.4) / A_POTEAU -- le toit passe à 10,4 au droit des poteaux
	local anglePente = math.atan(PENTE)
	local function yToit(a)
		return Y_FAITE - a * PENTE
	end
	local xMilieuToit = (X_TOIT_MIN + X_TOIT_MAX) / 2
	local longueurToit = X_TOIT_MAX - X_TOIT_MIN

	for _, s in ipairs({ 1, -1 }) do
		-- poteaux sur plots de pierre
		for _, xp in ipairs(X_POTEAUX) do
			poser("bloc", couveuse, {
				Name = "Plot",
				Size = Vector3.new(1.5, 0.6, 1.5),
				CFrame = CFrame.new(P(xp, 0.3, A_POTEAU, s)),
				Color = PIERRE,
				Material = MAT.Cobblestone,
				CanCollide = true,
			})
			local hPoteau = Y_SABLIERE + 0.3 - 0.6
			poser("cylindre", couveuse, {
				Name = "Poteau",
				Size = Vector3.new(hPoteau, 0.95, 0.95),
				CFrame = cfVertical(P(xp, 0.6 + hPoteau / 2, A_POTEAU, s)),
				Color = BOIS,
				Material = MAT.Wood,
				CanCollide = true,
			})
		end
		-- sablière le long du couloir
		poser("bloc", couveuse, {
			Name = "Sabliere",
			Size = Vector3.new(X_POTEAUX[2] - X_POTEAUX[1] + 1.4, 0.6, 0.7),
			CFrame = CFrame.new(P((X_POTEAUX[1] + X_POTEAUX[2]) / 2, Y_SABLIERE, A_POTEAU, s)),
			Color = BOIS_OMBRE,
			Material = MAT.WoodPlanks,
		})
		-- jambes de force entre poteaux et sablière
		for _, k in ipairs({ 1, -1 }) do
			local xp = X_POTEAUX[1]
			if k < 0 then
				xp = X_POTEAUX[2]
			end
			poser("bloc", couveuse, {
				Name = "JambeDeForce",
				Size = Vector3.new(0.35, 2.4, 0.35),
				CFrame = CFrame.new(P(xp + k * 0.9, Y_SABLIERE - 1.0, A_POTEAU, s)) * CFrame.Angles(0, 0, math.rad(-k * 45)),
				Color = BOIS_OMBRE,
				Material = MAT.Wood,
			})
		end

		-- pan de toit : trois rangs de palmes qui se recouvrent (le rang du haut par-dessus)
		local rangs = {
			{ a0 = -0.2, a1 = A_BORD * 0.38, leve = 0.3, couleur = PALME, mat = MAT.LeafyGrass },
			{ a0 = A_BORD * 0.32, a1 = A_BORD * 0.7, leve = 0.15, couleur = PALME_OMBRE, mat = MAT.Grass },
			{ a0 = A_BORD * 0.64, a1 = A_BORD, leve = 0, couleur = PALME, mat = MAT.LeafyGrass },
		}
		for _, r in ipairs(rangs) do
			local aM = (r.a0 + r.a1) / 2
			local longueur = (r.a1 - r.a0) / math.cos(anglePente)
			poser("bloc", couveuse, {
				Name = "Palmes",
				Size = Vector3.new(longueurToit, 0.6, longueur),
				CFrame = CFrame.new(P(xMilieuToit, yToit(aM), aM, s)) * CFrame.Angles(s * anglePente, 0, 0) * CFrame.new(0, 0.3 + r.leve, 0),
				Color = r.couleur,
				Material = r.mat,
			})
		end
		-- frange en dents de scie sous le bord du toit
		local nbFrange = 6
		for k = 0, nbFrange - 1 do
			local xf = X_TOIT_MIN + 0.6 + k * (longueurToit - 1.2) / (nbFrange - 1)
			poser("bloc", couveuse, {
				Name = "Frange",
				Size = Vector3.new(1.25, 1.25, 0.2),
				CFrame = CFrame.new(P(xf, yToit(A_BORD - 0.3) - 0.1, A_BORD - 0.3, s)) * CFrame.Angles(s * anglePente, 0, 0) * CFrame.Angles(0, 0, math.rad(45)),
				Color = PALME_LUM,
				Material = MAT.Grass,
			})
		end
		-- chevrons visibles aux deux pignons ouverts
		for _, xc in ipairs({ X_TOIT_MIN + 0.3, X_TOIT_MAX - 0.3 }) do
			local aM = (A_BORD - 0.3) / 2
			local longueur = (A_BORD - 0.3) / math.cos(anglePente)
			poser("bloc", couveuse, {
				Name = "Chevron",
				Size = Vector3.new(0.45, 0.45, longueur),
				CFrame = CFrame.new(P(xc, yToit(aM), aM, s)) * CFrame.Angles(s * anglePente, 0, 0) * CFrame.new(0, -0.2, 0),
				Color = BOIS_SOMBRE,
				Material = MAT.Wood,
			})
		end
		-- croisillons de palmes aux deux bouts du faîtage (style paillote)
		for _, xc in ipairs({ X_TOIT_MIN - 0.1, X_TOIT_MAX + 0.1 }) do
			poser("bloc", couveuse, {
				Name = "PalmeFaitage",
				Size = Vector3.new(0.2, 3.2, 1.0),
				CFrame = CFrame.new(P(xc, Y_FAITE + 1.2, 0.55, s)) * CFrame.Angles(-s * math.rad(35), 0, 0),
				Color = PALME_LUM,
				Material = MAT.Grass,
			})
		end
	end

	-- entraits qui enjambent le couloir (bien au-dessus des dinos) et poinçons jusqu'au faîtage
	for _, xp in ipairs(X_POTEAUX) do
		poser("bloc", couveuse, {
			Name = "Entrait",
			Size = Vector3.new(0.6, 0.6, 2 * A_POTEAU + 0.7),
			CFrame = CFrame.new(P(xp, Y_SABLIERE, 0, 1)),
			Color = BOIS_OMBRE,
			Material = MAT.WoodPlanks,
		})
		poser("bloc", couveuse, {
			Name = "Poincon",
			Size = Vector3.new(0.5, Y_FAITE - Y_SABLIERE - 0.3, 0.5),
			CFrame = CFrame.new(P(xp, (Y_FAITE + Y_SABLIERE) / 2, 0, 1)),
			Color = BOIS_SOMBRE,
			Material = MAT.Wood,
		})
	end
	-- faîtage : gros boudin de paille
	poser("cylindre", couveuse, {
		Name = "Faitage",
		Size = Vector3.new(longueurToit + 0.6, 1.3, 1.3),
		CFrame = CFrame.new(P(xMilieuToit, Y_FAITE + 0.35, 0, 1)),
		Color = PAILLE,
		Material = MAT.Grass,
	})
	-- cheminée de la couveuse (briques) posée sur le faîtage : la vapeur chaude s'en échappe en volutes
	local xCheminee = xMilieuToit + 1.2
	poser("bloc", couveuse, {
		Name = "Cheminee",
		Size = Vector3.new(1.1, 2.2, 1.1),
		CFrame = CFrame.new(P(xCheminee, Y_FAITE + 1.4, 0, 1)),
		Color = Charte.ombre(CUIVRE),
		Material = MAT.Brick,
	})
	local bouche = poser("bloc", couveuse, {
		Name = "BoucheCheminee",
		Size = Vector3.new(1.45, 0.35, 1.45),
		CFrame = CFrame.new(P(xCheminee, Y_FAITE + 2.65, 0, 1)),
		Color = PIERRE_OMBRE,
		Material = MAT.Slate,
	})
	vapeur(bouche, 3, 1.1, 3.2, "VapeurCheminee")

	-- caisses de paille sous le toit, deux œufs chacune, lampe suspendue au-dessus
	local lampes = Outils.modele(dossier, "Lampes")
	local ordreCaisses = { { 6, 2 }, { 7, 3 } }
	local xC = (X_POTEAUX[1] + X_POTEAUX[2]) / 2
	local aC = COULOIR + 1.5
	local largeurCaisse = X_POTEAUX[2] - X_POTEAUX[1] - 1.3
	for i, s in ipairs({ 1, -1 }) do
		local caisse = Outils.modele(couveuse, "Caisse")
		poser("bloc", caisse, {
			Name = "Coffre",
			Size = Vector3.new(largeurCaisse, 1.1, 2.4),
			CFrame = CFrame.new(P(xC, 0.55, aC, s)),
			Color = BOIS_OMBRE,
			Material = MAT.WoodPlanks,
			CanCollide = true,
		})
		for _, bord in ipairs({ -1, 1 }) do
			poser("bloc", caisse, {
				Name = "Rebord",
				Size = Vector3.new(largeurCaisse + 0.2, 0.35, 0.3),
				CFrame = CFrame.new(P(xC, 1.2, aC + bord * 1.1, s)),
				Color = BOIS_LUM,
				Material = MAT.Wood,
			})
		end
		local paille = poser("bloc", caisse, {
			Name = "Paille",
			Size = Vector3.new(largeurCaisse - 0.3, 0.4, 2.0),
			CFrame = CFrame.new(P(xC, 1.2, aC, s)),
			Color = PAILLE,
			Material = MAT.Grass,
		})
		vapeur(paille, 1.2, 0.6, 1.2)
		local rangs = ordreCaisses[i]
		oeuf(xC - 1.05, aC + 0.05, s, 2.2, 1.35, rangs[1], { remue = 3.2 + i * 0.4 })
		oeuf(xC + 1.05, aC - 0.05, s, 2.0, 1.35, rangs[2], { tourne = 0.35 })

		-- lampe suspendue au toit
		local lampe = Outils.modele(lampes, "Lampe")
		local yHaut = yToit(aC) - 0.1
		local yAbat = 7.2
		poser("cylindre", lampe, {
			Name = "Chaine",
			Size = Vector3.new(yHaut - yAbat, 0.14, 0.14),
			CFrame = cfVertical(P(xC, (yHaut + yAbat) / 2, aC, s)),
			Color = METAL,
			Material = MAT.Metal,
		})
		poser("cylindre", lampe, {
			Name = "AbatJour",
			Size = Vector3.new(0.9, 1.9, 1.9),
			CFrame = cfVertical(P(xC, yAbat, aC, s)),
			Color = ABAT_JOUR,
			Material = MAT.Metal,
		})
		local ampoule = poser("boule", lampe, {
			Name = "Ampoule",
			Size = Vector3.new(1.05, 1.05, 1.05),
			CFrame = CFrame.new(P(xC, yAbat - 0.5, aC, s)),
			Color = CHALEUR,
			Material = MAT.Neon,
		})
		if ampoule then
			lumiereChaude(ampoule, reglage("porteeLampe", 16), reglage("eclatLampe", 2), CHALEUR, true)
			Outils.animer(ampoule, "pulse", 0.9)
		end
	end

	-- ===== 3. les nids de paille de part et d'autre du couloir, entre la couveuse et l'arche =====
	local nid = Outils.modele(dossier, "Nid")
	local RX, RZ = 3.2, 2.2                        -- demi-axes de l'ellipse du bourrelet
	local NA = COULOIR + RZ + 1.0                  -- centre du nid : distance au couloir
	local NX = (X_TOIT_MAX + XA - R_SOCLE) / 2 - 0.2 -- centre du nid : entre la couveuse et l'arche
	local ordreNids = { [1] = { 3, 5, 1 }, [-1] = { 1, 4, 2 } }
	for _, s in ipairs({ 1, -1 }) do
		-- fond de paille (d'où monte la vapeur chaude)
		local litiere = poser("bloc", nid, {
			Name = "Litiere",
			Size = Vector3.new(2 * RX - 1.4, 0.5, 2 * RZ - 1.2),
			CFrame = CFrame.new(P(NX, 0.3, NA, s)),
			Color = PAILLE_OMBRE,
			Material = MAT.Sand,
		})
		vapeur(litiere, 1.6, 0.8, 1.4)
		-- bourrelet : boudins de paille tangents à l'ellipse, en trois teintes
		local teintes = { PAILLE, PAILLE_LUM, PAILLE_OMBRE }
		for k = 0, 9 do
			local t = math.rad(k * 36)
			local x = NX + RX * math.cos(t)
			local a = NA + RZ * math.sin(t)
			-- tangente dans le plan (x, z monde)
			local tx = -RX * math.sin(t)
			local tz = s * RZ * math.cos(t)
			local lacet = math.atan2(-tz, tx)
			local hauteur = 0.7
			if math.sin(t) < -0.5 then
				hauteur = 0.55 -- bord avant plus bas : les œufs restent visibles depuis le couloir
			end
			poser("cylindre", nid, {
				Name = "Paille",
				Size = Vector3.new(2.2, 1.1, 1.1),
				CFrame = CFrame.new(P(x, hauteur, a, s)) * CFrame.Angles(0, lacet, 0) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-5, 5))),
				Color = teintes[(k % 3) + 1],
				Material = MAT.Grass,
				CanCollide = true,
			})
		end
		-- brindilles couchées en travers du bourrelet
		for _, t0 in ipairs({ 30, 150, 250 }) do
			local t = math.rad(t0)
			local x = NX + (RX + 0.1) * math.cos(t)
			local a = NA + (RZ + 0.1) * math.sin(t)
			poser("cylindre", nid, {
				Name = "Brindille",
				Size = Vector3.new(2.2, 0.26, 0.26),
				CFrame = CFrame.new(P(x, 1.25, a, s)) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 180)), math.rad(rng:NextNumber(-10, 10))),
				Color = BOIS_OMBRE,
				Material = MAT.Wood,
			})
		end
		-- touffes de paille qui dépassent vers l'extérieur
		for _, t0 in ipairs({ 20, 160, 215, 325 }) do
			local t = math.rad(t0)
			local x = NX + (RX + 0.45) * math.cos(t)
			local a = NA + (RZ + 0.45) * math.sin(t)
			local taille = Vector3.new(1.2, 0.75, 0.9)
			poser("coin", nid, {
				Name = "Touffe",
				Size = taille,
				CFrame = Outils.surSol(taille, CX + x, CZ + s * a, rng:NextNumber(0, 360), 0),
				Color = PAILLE_LUM,
				Material = MAT.Grass,
			})
		end

		-- œufs du nid : deux sur les côtés, un plus gros au fond
		local rangs = ordreNids[s]
		local ySol = 0.55
		if s < 0 then
			-- nid du nord : l'œuf du fond éclot, un bébé regarde le couloir
			oeuf(NX - 1.95, NA - 0.4, s, 2.4, ySol, rangs[1], { remue = 2.6 })
			oeuf(NX + 0.05, NA + 0.7, s, 2.9, ySol, rangs[2], { fissure = true, bebe = true })
			oeuf(NX + 1.95, NA - 0.45, s, 2.3, ySol, rangs[3], { tourne = 0.45 })
		else
			oeuf(NX - 1.95, NA - 0.45, s, 2.3, ySol, rangs[1], { tourne = 0.4 })
			oeuf(NX + 0.05, NA + 0.7, s, 2.9, ySol, rangs[2], { remue = 2.2 })
			oeuf(NX + 1.95, NA - 0.4, s, 2.4, ySol, rangs[3], { fissure = true, remue = 4.2 })
		end

		-- lampe chauffante à deux têtes plantée derrière le nid
		local lampe = Outils.modele(lampes, "Lampe")
		local xPoteau = NX - 1.3
		local aPoteau = NA + RZ + 0.7
		local hPoteau = 9.2
		poser("boule", lampe, {
			Name = "Pied",
			Size = Vector3.new(1.1, 1.1, 1.1),
			CFrame = CFrame.new(P(xPoteau, 0.2, aPoteau, s)),
			Color = PIERRE_OMBRE,
			Material = MAT.Slate,
		})
		poser("cylindre", lampe, {
			Name = "Poteau",
			Size = Vector3.new(hPoteau, 0.55, 0.55),
			CFrame = cfVertical(P(xPoteau, hPoteau / 2, aPoteau, s)),
			Color = BOIS,
			Material = MAT.Wood,
			CanCollide = true,
		})
		local aTete = NA + 0.1
		poser("bloc", lampe, {
			Name = "Bras",
			Size = Vector3.new(0.4, 0.4, aPoteau - aTete + 0.4),
			CFrame = CFrame.new(P(xPoteau, hPoteau - 0.3, (aPoteau + aTete) / 2, s)),
			Color = METAL,
			Material = MAT.Metal,
		})
		poser("bloc", lampe, {
			Name = "Traverse",
			Size = Vector3.new(2 * RX - 1.6, 0.35, 0.35),
			CFrame = CFrame.new(P(NX, hPoteau - 0.3, aTete, s)),
			Color = METAL,
			Material = MAT.Metal,
		})
		for _, dx in ipairs({ -(RX - 1.2), RX - 1.2 }) do
			local yAbat = hPoteau - 1.1
			poser("cylindre", lampe, {
				Name = "AbatJour",
				Size = Vector3.new(0.9, 1.7, 1.7),
				CFrame = cfVertical(P(NX + dx, yAbat, aTete, s)),
				Color = ABAT_JOUR,
				Material = MAT.Metal,
			})
			local ampoule = poser("boule", lampe, {
				Name = "Ampoule",
				Size = Vector3.new(0.95, 0.95, 0.95),
				CFrame = CFrame.new(P(NX + dx, yAbat - 0.5, aTete, s)),
				Color = CHALEUR,
				Material = MAT.Neon,
			})
			if ampoule then
				lumiereChaude(ampoule, reglage("porteeLampe", 16), reglage("eclatLampe", 2), CHALEUR, true)
				Outils.animer(ampoule, "pulse", 0.7 + dx * 0.05)
			end
		end
	end

	-- ===== 4. au pied de la couveuse, côté ouest : bottes de paille (sud) et foyer à bouilloire (nord) =====
	local bottes = Outils.modele(dossier, "Bottes")
	local xOuest = X_POTEAUX[1] - 1.8
	local aOuest = COULOIR + 1.4
	-- bottes de paille empilées (sud)
	poser("cylindre", bottes, {
		Name = "Botte",
		Size = Vector3.new(1.5, 2.2, 2.2),
		CFrame = cfVertical(P(xOuest, 0.75, aOuest, 1)),
		Color = PAILLE,
		Material = MAT.Grass,
		CanCollide = true,
	})
	poser("cylindre", bottes, {
		Name = "Botte",
		Size = Vector3.new(1.3, 1.8, 1.8),
		CFrame = cfVertical(P(xOuest + 0.2, 2.15, aOuest + 0.1, 1)),
		Color = PAILLE_LUM,
		Material = MAT.Grass,
	})
	-- foyer de pierre et bouilloire de cuivre (nord) : la vapeur chaude monte du bec
	local foyer = Outils.modele(dossier, "Foyer")
	poser("cylindre", foyer, {
		Name = "Foyer",
		Size = Vector3.new(0.7, 2.3, 2.3),
		CFrame = cfVertical(P(xOuest, 0.35, aOuest, -1)),
		Color = PIERRE_OMBRE,
		Material = MAT.Cobblestone,
		CanCollide = true,
	})
	local braises = poser("cylindre", foyer, {
		Name = "Braises",
		Size = Vector3.new(0.2, 1.6, 1.6),
		CFrame = cfVertical(P(xOuest, 0.75, aOuest, -1)),
		Color = BRAISE,
		Material = MAT.Neon,
	})
	if braises then
		lumiereChaude(braises, 9, 1.3, BRAISE, false)
		Outils.animer(braises, "pulse", 1.6)
	end
	poser("boule", foyer, {
		Name = "Bouilloire",
		Size = Vector3.new(1.6, 1.6, 1.6),
		CFrame = CFrame.new(P(xOuest, 1.55, aOuest, -1)),
		Color = CUIVRE,
		Material = MAT.Metal,
		Reflectance = 0.1,
	})
	poser("cylindre", foyer, {
		Name = "Couvercle",
		Size = Vector3.new(0.3, 0.8, 0.8),
		CFrame = cfVertical(P(xOuest, 2.35, aOuest, -1)),
		Color = Charte.lumiere(CUIVRE),
		Material = MAT.Metal,
	})
	local bec = poser("bloc", foyer, {
		Name = "Bec",
		Size = Vector3.new(0.9, 0.3, 0.3),
		CFrame = CFrame.new(P(xOuest + 0.95, 1.85, aOuest, -1)) * CFrame.Angles(0, 0, math.rad(35)),
		Color = CUIVRE,
		Material = MAT.Metal,
	})
	vapeur(bec, 2.4, 0.45, 2.2, "VapeurBouilloire")

	-- brins de paille éparpillés sur le sable, hors du couloir
	for i = 1, 6 do
		local s = 1
		if i % 2 == 0 then
			s = -1
		end
		local x = rng:NextNumber(X_POTEAUX[1] - 3.4, X_POTEAUX[1] + 0.4)
		local a = rng:NextNumber(COULOIR + 1.0, COULOIR + 1.6)
		poser("bloc", bottes, {
			Name = "Brins",
			Size = Vector3.new(1.6, 0.12, 0.7),
			CFrame = CFrame.new(P(x, 0.06, a, s)) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 180)), 0),
			Color = PAILLE_LUM,
			Material = MAT.Grass,
		})
	end
	-- cailloux au pied des socles de l'arche
	for _, s in ipairs({ 1, -1 }) do
		for _, c in ipairs({ { XA - 1.3, COULOIR + 0.5, 0.8 }, { XA + 2.0, COULOIR + 0.4, 0.6 } }) do
			poser("boule", bottes, {
				Name = "Caillou",
				Size = Vector3.new(c[3], c[3], c[3]),
				CFrame = CFrame.new(P(c[1], 0.15, c[2], s)),
				Color = PIERRE_OMBRE,
				Material = MAT.Slate,
			})
		end
	end

	-- ===== 5. titre géant flottant « 🥚 NURSERIE » (lisible de loin, même sur mobile) =====
	local support = enseigne or dossier:FindFirstChild("Poutre", true)
	if Style and support then
		pcall(function()
			local _, textes = Style.etiquette(support, {
				{ texte = "🥚 NURSERIE", titre = true, taille = 1.6, contour = 4, nom = "Titre" },
				{ texte = "Les dinos éclosent ici !", couleur = Style.couleurs.revenu, taille = 0.8, nom = "SousTitre" },
			}, {
				Name = "TitreNurserie",
				largeur = 22,
				hauteurLigne = 2.6,
				StudsOffset = Vector3.new(0, 12, 0),
				MaxDistance = 320,
				AlwaysOnTop = false,
			})
			-- titre blanc qui se dore vers le bas, comme les grands titres des simulateurs
			if textes and textes[1] then
				Style.degrade(textes[1], BLANC, DORE)
			end
		end)
	end

	dossier:SetAttribute("Parts", compteur)
	dossier:SetAttribute("PartsRefusees", refusees)
end

return M
