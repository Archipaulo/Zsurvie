-- Constructeur Nurserie : la couveuse d'où sortent les dinos, à l'ouest du Tapis.
-- Deux croissants de nid (paille et branches) de part et d'autre du couloir du Tapis, œufs géants tachetés
-- aux couleurs des raretés (certains fissurés, d'autres qui « respirent »), lampes chauffantes orangées
-- et arche d'entrée « NURSERIE » au-dessus du couloir, tournée vers le début du Tapis.
-- Emprise (CONTRAT §10) : disque de rayon 14 autour de Plan.nurserie.centre ; couloir |z| ≤ 6 laissé libre
-- (seules l'enseigne et la poutre de l'arche le survolent, bien au-dessus des dinos).
local M = {}

local BUDGET = 220 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier

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

	-- emprise
	local infoNurserie = Plan.nurserie or {}
	local CENTRE = infoNurserie.centre or Vector3.new(-128, 0, 0)
	local RAYON = infoNurserie.rayon or 14
	local CX, CZ = CENTRE.X, CENTRE.Z
	local largeurTapis = 10
	if Plan.tapis and type(Plan.tapis.largeur) == "number" then
		largeurTapis = Plan.tapis.largeur
	end
	local COULOIR = largeurTapis / 2 + 1 -- demi-largeur du couloir libre (6)
	local HAUT_LIBRE = 9                  -- au-dessus de cette hauteur, le couloir peut être survolé
	local MARGE = 0.05

	local rng = Outils.aleatoire(reglage("graine", 1128))

	-- couleurs (toutes dérivées de la Charte)
	local PAILLE = Charte.sable
	local PAILLE_OMBRE = Charte.ombre(Charte.sable)
	local TERRE = Charte.terre
	local BOIS = Charte.bois
	local BOIS_OMBRE = Charte.ombre(Charte.bois)
	local CREME = Charte.creme
	local ENCRE = Charte.encre
	local DORE = Charte.dore
	local CHALEUR = Charte.lave:Lerp(Charte.dore, 0.35)

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

	-- vrai si la part (CFrame, taille) reste dans le disque et hors du couloir (sauf si elle le survole)
	local function dansEmprise(cf, taille, estBoule)
		local points = {}
		if estBoule then
			local r = math.min(taille.X, taille.Y, taille.Z) / 2
			local p = cf.Position
			-- pour une boule, on teste le bord réel du disque et du couloir
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
		for ix = -1, 1, 2 do
			for iy = -1, 1, 2 do
				for iz = -1, 1, 2 do
					local coinPos = cf:PointToWorldSpace(Vector3.new(ix * hx, iy * hy, iz * hz))
					table.insert(points, coinPos)
					if coinPos.Y < minY then
						minY = coinPos.Y
					end
				end
			end
		end
		if minY < -0.5 then
			return false
		end
		for _, p in ipairs(points) do
			local dx, dz = p.X - CX, p.Z - CZ
			if dx * dx + dz * dz > (RAYON - MARGE) * (RAYON - MARGE) then
				return false
			end
		end
		if minY < HAUT_LIBRE then
			-- la part touche le couloir si sa boîte le chevauche en z
			local zMin, zMax = math.huge, -math.huge
			for _, p in ipairs(points) do
				local z = p.Z - CZ
				if z < zMin then zMin = z end
				if z > zMax then zMax = z end
			end
			if zMax > -COULOIR and zMin < COULOIR then
				return false
			end
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

	local function polaire(angleDeg, rayon)
		local a = math.rad(angleDeg)
		return CX + math.cos(a) * rayon, CZ + math.sin(a) * rayon
	end

	-- ===== 1. le nid : litière, bourrelet de paille, branches =====
	local nid = Outils.modele(dossier, "Nid")

	-- litière de paille au fond de chaque croissant (très basse)
	for _, cote in ipairs({ 1, -1 }) do
		local litieres = {
			{ x = 0, z = 9.6, lx = 16, lz = 3.4 },
			{ x = 0, z = 12.2, lx = 8, lz = 2 },
		}
		for i, l in ipairs(litieres) do
			local taille = Vector3.new(l.lx, 0.4, l.lz)
			local couleur = PAILLE
			if i == 2 then
				couleur = PAILLE_OMBRE
			end
			poser("bloc", nid, {
				Name = "Litiere",
				Size = taille,
				CFrame = CFrame.new(CX + l.x, 0.2, CZ + cote * l.z),
				Color = couleur,
			})
		end
	end

	-- bourrelet du nid : couronne de bottes de paille alternant paille et terre
	local PAS_COURONNE = 12
	local RAYON_COURONNE = 12.3
	local numero = 0
	for angle = 0, 359, PAS_COURONNE do
		numero = numero + 1
		local x, z = polaire(angle, RAYON_COURONNE)
		local hauteur = 1.8 + rng:NextNumber(0, 0.8)
		local taille = Vector3.new(2.2, hauteur, 3.4)
		local couleur = PAILLE
		if numero % 2 == 0 then
			couleur = TERRE
		end
		-- l'axe X de la part pointe vers le centre (radial), Z le long de la couronne
		local cf = CFrame.new(x, hauteur / 2, z) * CFrame.Angles(0, -math.rad(angle), 0) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-6, 6)))
		poser("bloc", nid, { Name = "Paille", Size = taille, CFrame = cf, Color = couleur, CanCollide = true })
	end

	-- branches couchées sur le bourrelet (cylindres tangents, légèrement inclinés)
	for angle = 6, 359, 24 do
		local x, z = polaire(angle, 12.1)
		local longueur = 5 + rng:NextNumber(0, 1.2)
		local taille = Vector3.new(longueur, 0.6, 0.6)
		local cf = CFrame.new(x, 2.3 + rng:NextNumber(0, 0.5), z)
			* CFrame.Angles(0, -math.rad(angle) - math.pi / 2, 0)
			* CFrame.Angles(0, 0, math.rad(rng:NextNumber(-12, 12)))
		poser("cylindre", nid, { Name = "Branche", Size = taille, CFrame = cf, Color = BOIS })
	end

	-- brindilles dressées, penchées vers l'intérieur du nid
	for angle = 18, 359, 30 do
		local x, z = polaire(angle, 11.8)
		local longueur = 3 + rng:NextNumber(0, 1)
		local taille = Vector3.new(longueur, 0.4, 0.4)
		-- cylindre (axe X) redressé à la verticale puis penché vers le centre
		local cf = CFrame.new(x, longueur / 2 + 0.6, z)
			* CFrame.Angles(0, -math.rad(angle), 0)
			* CFrame.Angles(0, 0, math.rad(-70))
		poser("cylindre", nid, { Name = "Brindille", Size = taille, CFrame = cf, Color = BOIS_OMBRE })
	end

	-- touffes de paille éparses (petits coins)
	for i = 1, 14 do
		local cote = 1
		if i % 2 == 0 then
			cote = -1
		end
		local x = CX + rng:NextNumber(-9, 9)
		local z = CZ + cote * rng:NextNumber(7, 12.5)
		local taille = Vector3.new(1.2, 0.7, 1)
		poser("coin", nid, {
			Name = "Touffe",
			Size = taille,
			CFrame = Outils.surSol(taille, x, z, rng:NextNumber(0, 360), 0.3),
			Color = PAILLE_OMBRE,
		})
	end

	-- ===== 2. les œufs géants =====
	local oeufs = Outils.modele(dossier, "Oeufs")

	-- une tache posée sur la surface d'une boule
	local function tache(parent, centre, rayon, direction, couleur, taille)
		local d = direction.Unit
		local pos = centre + d * (rayon - taille * 0.3)
		return poser("boule", parent, {
			Name = "Tache",
			Size = Vector3.new(taille, taille, taille),
			CFrame = CFrame.new(pos),
			Color = couleur,
		})
	end

	-- une fissure lumineuse : fin segment Neon plaqué sur la surface
	local function fissure(parent, centre, rayon, direction, rotation, couleur)
		local d = direction.Unit
		local pos = centre + d * (rayon - 0.05)
		local cf = CFrame.lookAt(pos, pos + d) * CFrame.Angles(0, 0, math.rad(rotation))
		return poser("bloc", parent, {
			Name = "Fissure",
			Size = Vector3.new(1.4, 0.22, 0.3),
			CFrame = cf,
			Color = couleur,
			Material = Enum.Material.Neon,
		})
	end

	-- description des œufs : décalage (x, |z|), côté, diamètre, fissuré, respire
	local listeOeufs = {
		{ dx = -7.5, dz = 8.7, cote = 1, d = 3.8, fissure = false, respire = false },
		{ dx = -2.6, dz = 8.9, cote = 1, d = 4.4, fissure = true, respire = false, bebe = true },
		{ dx = 2.6, dz = 8.7, cote = 1, d = 3.6, fissure = false, respire = true },
		{ dx = 7.4, dz = 8.6, cote = 1, d = 3.8, fissure = false, respire = false },
		{ dx = -7.4, dz = 8.6, cote = -1, d = 3.6, fissure = false, respire = true },
		{ dx = -2.5, dz = 8.9, cote = -1, d = 4.2, fissure = false, respire = false },
		{ dx = 2.7, dz = 8.9, cote = -1, d = 4.4, fissure = true, respire = false },
		{ dx = 7.5, dz = 8.6, cote = -1, d = 3.6, fissure = true, respire = true },
	}
	-- raretés attribuées : on mélange les plus rares parmi les communes pour un nid varié
	local ordreRaretes = { 1, 4, 2, 3, 2, 5, 6, 7 }

	local debris = {}
	for i, info in ipairs(listeOeufs) do
		local cleRarete = rareteNumero(ordreRaretes[i] or i)
		local teinte = couleurRarete(cleRarete)
		local coquille = Charte.lumiere(teinte)
		local motif = Charte.ombre(teinte)
		if cleRarete == "Secret" then
			motif = Charte.pierre
		end

		local m = Outils.modele(oeufs, "Oeuf" .. i)
		m:SetAttribute("Rarete", cleRarete)
		local R = info.d / 2
		local enfoncement = 0.4
		local xC = CX + info.dx
		local zC = CZ + info.cote * info.dz
		local centreBas = Vector3.new(xC, R - enfoncement, zC)
		local rHaut = R * 0.8
		local decalHaut = Vector3.new(0, R * 0.7, 0)
		if info.fissure then
			-- la calotte a glissé : l'œuf commence à éclore
			decalHaut = Vector3.new(0.25, R * 0.72, -info.cote * 0.2)
		end
		local centreHaut = centreBas + decalHaut

		local bas = poser("boule", m, {
			Name = "Coquille",
			Size = Vector3.new(info.d, info.d, info.d),
			CFrame = CFrame.new(centreBas),
			Color = coquille,
			CanCollide = true,
		})
		local haut = poser("boule", m, {
			Name = "Calotte",
			Size = Vector3.new(rHaut * 2, rHaut * 2, rHaut * 2),
			CFrame = CFrame.new(centreHaut),
			Color = coquille,
			CanCollide = true,
		})
		if bas then
			m.PrimaryPart = bas
		end

		-- taches : trois sur le ventre, une sur la calotte
		for t = 1, 3 do
			local angle = rng:NextNumber(0, math.pi * 2)
			local dir = Vector3.new(math.cos(angle), rng:NextNumber(-0.25, 0.3), math.sin(angle))
			tache(m, centreBas, R, dir, motif, rng:NextNumber(0.7, 1.1))
		end
		if haut then
			local angle = rng:NextNumber(0, math.pi * 2)
			tache(m, centreHaut, rHaut, Vector3.new(math.cos(angle), 0.6, math.sin(angle)), motif, 0.7)
		end

		if info.fissure then
			-- fissures en zigzag tournées vers le couloir (côté spectateurs)
			local versCouloir = Vector3.new(0, 0, -info.cote)
			local pointsFissure = {
				{ dir = versCouloir + Vector3.new(-0.35, 0.35, 0), rot = 25 },
				{ dir = versCouloir + Vector3.new(0, 0.2, 0), rot = -30 },
				{ dir = versCouloir + Vector3.new(0.35, 0.35, 0), rot = 25 },
			}
			for _, pf in ipairs(pointsFissure) do
				fissure(m, centreBas, R, pf.dir, pf.rot, teinte)
			end
			-- lueur de la rareté qui filtre par les fissures
			if bas then
				pcall(function()
					Outils.lumiere(bas, { Range = 8, Brightness = 1.2, Color = teinte })
				end)
			end
			table.insert(debris, { x = xC, z = zC, cote = info.cote, couleur = coquille })
		end

		-- un bébé dino pointe le museau hors de l'œuf le plus fissuré
		if info.bebe and haut then
			local tete = centreBas + Vector3.new(0, R * 0.55, -info.cote * (R * 0.55))
			local peau = Charte.herbe
			local cfTete = CFrame.lookAt(tete, tete + Vector3.new(0, 0, -info.cote))
			local tetePart = poser("bloc", m, { Name = "TeteBebe", Size = Vector3.new(1.3, 1.1, 1.2), CFrame = cfTete, Color = peau })
			if tetePart then
				poser("bloc", m, {
					Name = "MuseauBebe",
					Size = Vector3.new(0.9, 0.6, 0.8),
					CFrame = cfTete * CFrame.new(0, -0.15, -0.8),
					Color = Charte.lumiere(peau),
				})
				poser("boule", m, { Name = "OeilG", Size = Vector3.new(0.35, 0.35, 0.35), CFrame = cfTete * CFrame.new(-0.35, 0.25, -0.6), Color = ENCRE })
				poser("boule", m, { Name = "OeilD", Size = Vector3.new(0.35, 0.35, 0.35), CFrame = cfTete * CFrame.new(0.35, 0.25, -0.6), Color = ENCRE })
			end
		end

		if info.respire then
			-- l'œuf « respire » : pulsation douce, un peu décalée d'un œuf à l'autre
			Outils.animer(m, "pulse", 0.5 + (i % 3) * 0.15)
		end
	end

	-- éclats de coquille au pied des œufs fissurés, côté couloir (bien visibles)
	for _, d in ipairs(debris) do
		for e = 1, 2 do
			local taille = Vector3.new(0.9, 0.35, 0.7)
			local x = d.x + (e * 2 - 3) * rng:NextNumber(0.6, 1.8)
			local z = CZ + d.cote * 7
			poser("coin", oeufs, {
				Name = "Eclat",
				Size = taille,
				CFrame = Outils.surSol(taille, x, z, rng:NextNumber(0, 360), 0.3),
				Color = d.couleur,
			})
		end
	end

	-- ===== 3. les lampes chauffantes =====
	local lampes = Outils.modele(dossier, "Lampes")
	local HAUTEUR_LAMPE = 9.5
	for _, angle in ipairs({ 55, 125, 235, 305 }) do
		local lampe = Outils.modele(lampes, "Lampe")
		local xP, zP = polaire(angle, 12.9)
		local poteau = poser("bloc", lampe, {
			Name = "Poteau",
			Size = Vector3.new(0.7, HAUTEUR_LAMPE, 0.7),
			CFrame = CFrame.new(xP, HAUTEUR_LAMPE / 2, zP),
			Color = BOIS_OMBRE,
			CanCollide = true,
		})
		if poteau then
			-- bras horizontal qui avance au-dessus des œufs
			local xB, zB = polaire(angle, 11.1)
			poser("bloc", lampe, {
				Name = "Bras",
				Size = Vector3.new(3.8, 0.45, 0.45),
				CFrame = CFrame.new(xB, HAUTEUR_LAMPE - 0.2, zB) * CFrame.Angles(0, -math.rad(angle), 0),
				Color = ENCRE,
			})
			-- abat-jour (cylindre vertical) et ampoule Neon
			local xL, zL = polaire(angle, 9.5)
			poser("cylindre", lampe, {
				Name = "AbatJour",
				Size = Vector3.new(1, 2.2, 2.2),
				CFrame = CFrame.new(xL, HAUTEUR_LAMPE - 0.7, zL) * CFrame.Angles(0, 0, math.pi / 2),
				Color = ENCRE,
			})
			local ampoule = poser("boule", lampe, {
				Name = "Ampoule",
				Size = Vector3.new(1.3, 1.3, 1.3),
				CFrame = CFrame.new(xL, HAUTEUR_LAMPE - 1.4, zL),
				Color = CHALEUR,
				Material = Enum.Material.Neon,
			})
			if ampoule then
				pcall(function()
					Outils.lumiere(ampoule, { Range = reglage("porteeLampe", 16), Brightness = reglage("eclatLampe", 2), Color = CHALEUR })
				end)
			end
		end
	end

	-- ===== 4. l'arche d'entrée « NURSERIE » =====
	local arche = Outils.modele(dossier, "Arche")
	-- l'arche se dresse au bord est du disque, juste avant le début du Tapis
	local xA = CX + math.min(9.5, RAYON - 4.5)
	local HAUTEUR_POTEAU = 13
	local ZP = COULOIR + 1.6
	for _, cote in ipairs({ 1, -1 }) do
		poser("bloc", arche, {
			Name = "Socle",
			Size = Vector3.new(2, 1, 2),
			CFrame = CFrame.new(xA, 0.5, CZ + cote * (ZP + 0.1)),
			Color = Charte.pierre,
			CanCollide = true,
		})
		poser("bloc", arche, {
			Name = "Pilier",
			Size = Vector3.new(1.4, HAUTEUR_POTEAU, 1.4),
			CFrame = CFrame.new(xA, HAUTEUR_POTEAU / 2, CZ + cote * ZP),
			Color = BOIS,
			CanCollide = true,
		})
		poser("boule", arche, {
			Name = "Pommeau",
			Size = Vector3.new(2, 2, 2),
			CFrame = CFrame.new(xA, HAUTEUR_POTEAU + 1.6, CZ + cote * ZP),
			Color = DORE,
		})
		-- lanterne sur la face est du pilier, vers les joueurs
		local lanterne = poser("boule", arche, {
			Name = "Lanterne",
			Size = Vector3.new(0.9, 0.9, 0.9),
			CFrame = CFrame.new(xA + 0.8, 7, CZ + cote * ZP),
			Color = CHALEUR,
			Material = Enum.Material.Neon,
		})
		if lanterne then
			pcall(function()
				Outils.lumiere(lanterne, { Range = 10, Brightness = 1.2, Color = CHALEUR })
			end)
		end
	end

	-- poutre transversale au sommet des piliers
	poser("bloc", arche, {
		Name = "Poutre",
		Size = Vector3.new(1.8, 1.2, 2 * ZP + 2),
		CFrame = CFrame.new(xA, HAUTEUR_POTEAU + 0.5, CZ),
		Color = BOIS_OMBRE,
	})

	-- enseigne suspendue sous la poutre, lisible des deux côtés
	local largeurEnseigne = 2 * ZP - 2.2
	poser("bloc", arche, {
		Name = "Cadre",
		Size = Vector3.new(0.4, 2.9, largeurEnseigne + 0.4),
		CFrame = CFrame.new(xA, HAUTEUR_POTEAU - 1.45, CZ),
		Color = DORE,
	})
	local enseigne = poser("bloc", arche, {
		Name = "Enseigne",
		Size = Vector3.new(0.6, 2.5, largeurEnseigne),
		CFrame = CFrame.new(xA, HAUTEUR_POTEAU - 1.45, CZ),
		Color = CREME,
	})
	if enseigne then
		for _, face in ipairs({ "Right", "Left" }) do
			pcall(function()
				local etiquette = Outils.texte(enseigne, face, "NURSERIE", { couleur = Charte.lave, pixelsParStud = 40 })
				local gui = etiquette.Parent
				gui.Name = "Affiche"
				etiquette.Name = "Titre"
				local contour = Instance.new("UIStroke")
				contour.Color = ENCRE
				contour.Thickness = 3
				contour.Parent = etiquette
				local marge = Instance.new("UIPadding")
				marge.PaddingTop = UDim.new(0.1, 0)
				marge.PaddingBottom = UDim.new(0.1, 0)
				marge.PaddingLeft = UDim.new(0.05, 0)
				marge.PaddingRight = UDim.new(0.05, 0)
				marge.Parent = etiquette
			end)
		end
	end

	-- œuf doré qui trône sur l'arche et respire lentement
	local oeufArche = Outils.modele(arche, "OeufArche")
	local couleurArche = couleurRarete("Legendaire")
	local yBase = HAUTEUR_POTEAU + 1.1
	poser("boule", oeufArche, {
		Name = "Coquille",
		Size = Vector3.new(2, 2, 2),
		CFrame = CFrame.new(xA, yBase + 1, CZ),
		Color = Charte.lumiere(couleurArche),
	})
	poser("boule", oeufArche, {
		Name = "Calotte",
		Size = Vector3.new(1.6, 1.6, 1.6),
		CFrame = CFrame.new(xA, yBase + 1.7, CZ),
		Color = Charte.lumiere(couleurArche),
	})
	poser("boule", oeufArche, {
		Name = "Tache",
		Size = Vector3.new(0.6, 0.6, 0.6),
		CFrame = CFrame.new(xA + 0.8, yBase + 1.2, CZ + 0.3),
		Color = Charte.ombre(couleurArche),
	})
	Outils.animer(oeufArche, "pulse", 0.4)

	dossier:SetAttribute("Parts", compteur)
end

return M
