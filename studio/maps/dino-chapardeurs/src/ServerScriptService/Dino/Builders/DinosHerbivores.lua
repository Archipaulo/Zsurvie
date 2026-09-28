-- Constructeur DinosHerbivores : gabarits des espèces de la famille « Herbivore »,
-- rangés dans ServerStorage.Dino.Dinos (clonés ensuite par Systemes/Tapis).
-- Style « petits cubes » des simulateurs « Steal a … » (STYLE.md §5) : chaque dino est
-- modélisé en voxels de 1 stud avec ctx.Voxel, fusionnés en parts à texture « Studs ».
-- Chibi : grosse tête carrée aux arêtes adoucies, jamais plus large que ce qu'elle doit laisser
-- voir (cou, collerette, carapace, plaques) ; yeux comme les carnivores (blanc, pupille noire,
-- reflet blanc), joues roses, bouche lisible ; volume par la couleur (cubes exposés vers le haut
-- plus clairs, ombres chaudes choisies à la main), grain de couleur cube par cube, ventre
-- contrasté, accessoires-signatures qui dépassent de la silhouette ; taille selon la rareté,
-- Neon dès Mythique (seulement en pointe, pour que le halo garde la forme), lumière d'aura.
-- Repère : origine au sol sous le centre du dino, regard vers -Z, x > 0 = côté droit (D).
-- Groupes nommés pour les animations (Corps, Tete, Cou, Queue, PatteAvG/D, PatteArG/D, Massue)
-- et pour les mutations (Oeil, Pupille, Reflet, Joue, Bouche : jamais recolorés ; Crete, Tache).
local M = {}

local BUDGET = 150 -- parts maximum par gabarit (vérifié par Voxel:construire)

-- ===== boîte à outils commune =====
local function kit(ctx)
	local C = ctx.Charte
	local K = { C = C }
	local hex = C.hex
	K.hex = hex
	K.encre = hex("1E1B33")
	K.blanc = hex("FFFFFF")
	K.rose = hex("FF8FB1")
	K.creme = hex("FFF4DC")
	K.bouche = hex("7A1F3D")
	K.langue = hex("FF6F91")

	-- les teintes d'une couleur : base, clair (dessus), foncé (dessous), très foncé (détails)
	-- hOmbre : teinte d'ombre choisie à la main (évite les jaunes « olive »)
	function K.pal(h, hOmbre)
		local b = hex(h)
		local f
		if hOmbre then
			f = hex(hOmbre)
		else
			f = C.ombre(b)
		end
		return { b = b, c = C.lumiere(b), f = f, ff = C.ombre(f) }
	end

	-- pavé aux arêtes adoucies (r = 0 : pavé plein ; r = 1 : arêtes retirées ; r = 2 : très arrondi)
	function K.pave(V, x1, y1, z1, x2, y2, z2, c, g, r)
		r = r or 0
		local xa, xb = math.min(x1, x2), math.max(x1, x2)
		local ya, yb = math.min(y1, y2), math.max(y1, y2)
		local za, zb = math.min(z1, z2), math.max(z1, z2)
		for x = xa, xb do
			for y = ya, yb do
				for z = za, zb do
					local garder = true
					if r > 0 then
						local qx = math.max(r - math.min(x - xa, xb - x), 0)
						local qy = math.max(r - math.min(y - ya, yb - y), 0)
						local qz = math.max(r - math.min(z - za, zb - z), 0)
						garder = (qx * qx + qy * qy + qz * qz) <= (r + 0.2) * (r + 0.2)
					end
					if garder then
						V:mettre(x, y, z, c, g)
					end
				end
			end
		end
	end

	-- ellipsoïde limitée aux cases où test(x, y, z) est vrai
	function K.ellipsoideSi(V, cx, cy, cz, rx, ry, rz, c, g, test)
		for x = math.floor(cx - rx), math.ceil(cx + rx) do
			for y = math.floor(cy - ry), math.ceil(cy + ry) do
				for z = math.floor(cz - rz), math.ceil(cz + rz) do
					local dx, dy, dz = (x - cx) / rx, (y - cy) / ry, (z - cz) / rz
					if dx * dx + dy * dy + dz * dz <= 1.05 and test(x, y, z) then
						V:mettre(x, y, z, c, g)
					end
				end
			end
		end
	end

	-- plaque pointue dans le plan YZ, épaisse de x1 à x2 : largeurs = demi-largeurs de chaque rangée
	-- (du bas vers le haut). Intérieur c ; bord cBord sur la rangée du haut et une case sur deux du contour.
	function K.plaque(V, x1, x2, yBase, zc, largeurs, c, cBord, g)
		for i, l in ipairs(largeurs) do
			local y = yBase + i - 1
			for dz = -l, l do
				local couleur = c
				if i == #largeurs or (math.abs(dz) == l and (y + dz) % 2 == 0) then
					couleur = cBord
				end
				V:boite(x1, y, zc + dz, x2, y, zc + dz, couleur, g)
			end
		end
	end

	-- chemin de cubes reliés par leurs faces entre des points successifs { x, y, z }
	-- couleurDe(i) : couleur du i-ème cube posé (i à partir de 1)
	function K.chemin(V, points, couleurDe, g)
		local i = 0
		local function poser(x, y, z)
			if not V:lire(x, y, z) or V:lire(x, y, z).g == g then
				i = i + 1
				V:mettre(x, y, z, couleurDe(i), g)
			end
		end
		local x, y, z = points[1][1], points[1][2], points[1][3]
		poser(x, y, z)
		for k = 2, #points do
			local p = points[k]
			while x ~= p[1] or y ~= p[2] or z ~= p[3] do
				if x ~= p[1] then
					x = x + (p[1] > x and 1 or -1)
				elseif y ~= p[2] then
					y = y + (p[2] > y and 1 or -1)
				else
					z = z + (p[3] > z and 1 or -1)
				end
				poser(x, y, z)
			end
		end
	end

	-- volume par la couleur : cube de teinte « b » sans voisin au-dessus -> clair ;
	-- yBas (facultatif) : les cubes de teinte « b » à cette hauteur ou plus bas -> foncé
	function K.volume(V, p, yBas)
		local liste = {}
		for _, v in pairs(V.grille) do
			if v.c.couleur == p.b and v.c.materiau == nil then
				if not V:lire(v.x, v.y + 1, v.z) then
					table.insert(liste, { v, p.c })
				elseif yBas and v.y <= yBas then
					table.insert(liste, { v, p.f })
				end
			end
		end
		for _, e in ipairs(liste) do
			e[1].c = { couleur = e[2], materiau = nil }
		end
	end

	-- repeint les cubes d'une palette (base, clair ou foncé) quand test(x, y, z, v) est vrai
	function K.repeindre(V, p, couleur, test, groupes)
		V:peindre(function(x, y, z, v)
			local c = v.c.couleur
			if (c == p.b or c == p.c or c == p.f) and v.c.materiau == nil and (not groupes or groupes[v.g]) and test(x, y, z, v) then
				return couleur
			end
			return nil
		end)
	end

	-- petit hachage stable (motifs), symétrique en x
	function K.hache(x, y, z)
		local h = math.abs(x) * 7 + y * 13 + z * 31 + math.abs(x * y) * 3
		return (h % 11) / 11
	end

	-- grain de couleur cube par cube (références « Steal a … ») : quelques cubes clairs et foncés isolés
	function K.grain(V, p, groupes)
		K.repeindre(V, p, p.c, function(x, y, z) return K.hache(x, y, z) > 0.85 end, groupes)
		K.repeindre(V, p, p.f, function(x, y, z, v) return v.c.couleur == p.b and K.hache(x, y + 1, z + 2) > 0.85 end, groupes)
	end

	-- peint la surface avant (premier cube rencontré en venant de -Z, jusqu'à zmax) en (x, y)
	function K.facade(V, x, y, c, g, zmax)
		for z = -40, zmax or 40 do
			if V:lire(x, y, z) then
				V:mettre(x, y, z, c, g)
				return z
			end
		end
		return nil
	end

	-- tête chibi : pavé arrondi (demi-largeur hw, bas y, hauteur h, face avant z, profondeur d)
	-- et museau en saillie de 2 cubes de haut (o.museau = { hw, d, c, bec = couleur de la mâchoire })
	function K.tete(V, o)
		K.pave(V, -o.hw, o.y, o.z, o.hw, o.y + o.h - 1, o.z + o.d - 1, o.c, "Tete", 1)
		local m = o.museau
		if m then
			V:boite(-m.hw, o.y, o.z - m.d, m.hw, o.y + 1, o.z, m.c or o.c, "Tete")
			if m.bec then
				V:boite(-m.hw, o.y, o.z - m.d, m.hw, o.y, o.z - 1, m.bec, "Tete")
			end
		end
	end

	-- visage de la tête o (après les couleurs de volume), même langage que les carnivores :
	-- œil de 3 de large sur t rangées : pupille noire 2 x 2 côté intérieur (colonnes xo, xo + 1),
	-- blanc (groupe « Oeil ») sur la colonne extérieure xo + 2 et, si t = 3, sur la rangée du haut ;
	-- reflet blanc en haut à l'intérieur de la pupille ; joues roses sous le coin extérieur ;
	-- o.front : rangées de front laissées libres au-dessus des yeux ; sourire en U sur le museau (sauf bec)
	function K.visage(V, o)
		local t = o.t or 2
		local xo = o.xo or math.max(1, o.hw - 3 - (o.ecart or 0)) -- colonne intérieure de l'œil droit
		local yo = o.y + o.h - 1 - t - (o.front or 0)
		local zmax = o.z + 1
		for _, s in ipairs({ 1, -1 }) do
			for j = 0, t - 1 do
				for i = 0, 2 do
					local c, g = o.blanc or K.blanc, "Oeil"
					if i <= 1 and j <= 1 then
						c, g = o.pupille or K.encre, "Pupille"
					end
					if i == 0 and j == 1 then
						c, g = o.reflet or K.blanc, "Reflet"
					end
					K.facade(V, s * (xo + i), yo + j, c, g, zmax)
				end
			end
			for x = xo + 2, xo + 3 do
				K.facade(V, s * x, yo - 1, o.couleurJoue or K.rose, "Joue", zmax)
			end
		end
		local m = o.museau
		if m and not m.bec then
			local l = m.hw - 1
			for x = -l, l do
				K.facade(V, x, o.y, o.bouche or K.bouche, "Bouche", zmax)
			end
			K.facade(V, m.hw, o.y + 1, o.bouche or K.bouche, "Bouche", zmax)
			K.facade(V, -m.hw, o.y + 1, o.bouche or K.bouche, "Bouche", zmax)
			if o.langue then
				K.facade(V, 0, o.y, o.langue, "Bouche", zmax)
			end
		end
	end
	return K
end

local ESPECES = {}
local CORPS = { Corps = true, Queue = true, Cou = true }
local TRONC = { Corps = true }
local PEAU = { Corps = true, Tete = true, Queue = true, Cou = true }

-- ===== Commun (8 cubes de haut au plus) =====

-- Galli : petit coureur à bec orange pointu, grosse tête ronde, crête rouge, queue en plumeau
function ESPECES.Galli(V, K)
	local p = K.pal("FFB23F", "E8872E")
	local rouge = K.pal("FF4F5E")
	local orange = K.pal("FF8A1F")
	local ventre = K.hex("FFF1C9")
	-- pattes 2 x 2 et orteils
	V:boite(1, 0, 1, 2, 1, 2, orange.f, "PatteArD")
	V:boite(1, 0, 0, 2, 0, 0, orange.b, "PatteArD")
	-- corps de coureur (7 x 3 x 7), soudé à la tête par un cou
	K.pave(V, -3, 2, -1, 3, 4, 5, p.b, "Corps", 1)
	V:boite(-1, 3, -1, 1, 4, 0, p.b, "Corps")
	V:boite(4, 3, 1, 4, 3, 2, p.b, "PatteAvD") -- aileron collé au flanc
	-- queue en plumeau relevée : dépasse derrière la tête en 3/4
	V:tube(0, 3, 5, 0, 5, 7, 1.1, p.b, "Queue", 0.6)
	V:boite(0, 5, 7, 0, 7, 8, rouge.b, "Queue")
	V:boite(1, 6, 7, 1, 7, 7, rouge.c, "Queue")
	local tete = { hw = 4, y = 2, h = 5, z = -5, d = 5, c = p.b }
	K.tete(V, tete)
	-- crête rouge : croix peinte dans la rangée du haut et trois lobes
	V:boite(0, 6, -4, 0, 6, -2, rouge.b, "Crete")
	V:mettre(1, 6, -3, rouge.b, "Crete")
	V:boite(0, 7, -4, 0, 7, -2, rouge.b, "Crete")
	V:symetriser()
	K.volume(V, p)
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 3 and math.abs(x) <= 1 end, TRONC)
	K.grain(V, p, { Corps = true, Tete = true })
	K.visage(V, tete)
	-- bec pointu : rétrécit vers l'avant et libère les joues ; bouche et barbillon dessous
	V:boite(-1, 3, -6, 1, 3, -6, K.hex("FF9F1C"), "Tete")
	V:mettre(0, 3, -7, K.hex("FF9F1C"), "Tete")
	V:mettre(0, 2, -6, K.hex("E8872E"), "Tete")
	V:mettre(1, 2, -6, K.bouche, "Bouche")
	V:mettre(-1, 2, -6, K.bouche, "Bouche")
	V:mettre(0, 1, -6, rouge.b, "Tete")
end

-- Pachy : dôme jaune bosselé de violet sur une tête bleue, petit corps trapu
function ESPECES.Pachy(V, K)
	local p = K.pal("5BC0FF")
	local dome = K.pal("FFC23D", "F29A2E")
	local bosse = K.hex("B86BFF")
	local ventre = K.hex("DDF3FF")
	V:boite(1, 0, 1, 2, 1, 2, p.f, "PatteArD")
	V:boite(1, 0, 0, 2, 0, 0, K.creme, "PatteArD")
	K.pave(V, -3, 2, 0, 3, 5, 4, p.b, "Corps", 1)
	V:mettre(4, 3, 1, p.b, "PatteAvD")
	V:tube(0, 3, 4, 0, 2, 8, 1.2, p.b, "Queue", 0.5)
	local tete = { hw = 4, y = 1, h = 5, z = -5, d = 5, c = p.b, front = 1 }
	K.tete(V, tete)
	V:boite(-3, 1, -5, 3, 1, -5, p.b, "Tete") -- menton carré (la rangée de la bouche reste en façade)
	-- dôme : remplace la rangée du haut de la tête, sommet à y = 7
	K.ellipsoideSi(V, 0, 3.6, -2.5, 3.9, 3.6, 3.4, dome.b, "Crete", function(x, y, z) return y >= 5 end)
	-- bosses violettes posées sur le dôme
	for _, b in ipairs({ { 2, 7, -4 }, { 2, 7, -1 }, { 3, 6, -2 }, { 0, 7, -3 } }) do
		V:mettre(b[1], b[2], b[3], bosse, "Crete")
	end
	V:symetriser()
	K.volume(V, p)
	K.volume(V, dome)
	-- liseré violet sur le bord bas du dôme
	local liste = {}
	for _, v in pairs(V.grille) do
		if v.g == "Crete" and v.y == 5 then
			for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
				local w = V:lire(v.x + d[1], 5, v.z + d[2])
				if not w or w.g ~= "Crete" then
					table.insert(liste, v)
					break
				end
			end
		end
	end
	for _, v in ipairs(liste) do
		v.c = { couleur = bosse, materiau = nil }
	end
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 3 and math.abs(x) <= 1 end, TRONC)
	K.grain(V, p, TRONC)
	-- front bleu clair sous le dôme
	for x = -3, 3 do
		K.facade(V, x, 4, p.c, "Tete", -4)
	end
	K.visage(V, tete)
	-- bouche avec langue, joues aux coins de la bouche
	K.facade(V, -1, 1, K.bouche, "Bouche", -4)
	K.facade(V, 1, 1, K.bouche, "Bouche", -4)
	K.facade(V, 0, 1, K.langue, "Bouche", -4)
end

-- Tricéra : collerette rose bordée de crème à picots blancs, trois cornes vers l'avant, bec pointu
function ESPECES.Tricera(V, K)
	local p = K.pal("6BD64A")
	local rose = K.hex("FF8FB1")
	local bord = K.hex("FFF4DC")
	local tache = K.hex("D6283A")
	local corne = K.hex("FFF4DC")
	local ventre = K.hex("E6FFB8")
	V:boite(2, 0, -2, 3, 1, -1, p.f, "PatteAvD")
	V:boite(2, 0, 3, 3, 1, 4, p.f, "PatteArD")
	V:boite(2, 0, -2, 3, 0, -2, corne, "PatteAvD")
	V:boite(2, 0, 3, 3, 0, 3, corne, "PatteArD")
	K.pave(V, -3, 2, -3, 3, 5, 5, p.b, "Corps", 1)
	V:tube(0, 3, 5, 0, 2, 9, 1.3, p.b, "Queue", 0.5)
	-- collerette en deux couches : avant (z = -3) et arrière (z = -2) décalée d'un cran vers le haut,
	-- liseré crème d'un cube sur chaque couche
	for _, couche in ipairs({ { -3, 3.2 }, { -2, 3.8 } }) do
		local zc, cy = couche[1], couche[2]
		K.ellipsoideSi(V, 0, cy, zc, 6.4, 3.2, 0.6, rose, "Crete", function(x, y, z) return y >= 2 end)
		V:peindre(function(x, y, z)
			if z ~= zc then return nil end
			local a, b = x / 6.4, (y - cy) / 3.2
			if a * a + b * b > 0.85 then return bord end
			return nil
		end, "Crete")
	end
	-- picots blancs qui dépassent du bord, taches rouges dans le rose
	for _, b in ipairs({ { 2, 7 }, { 4, 7 }, { 6, 5 }, { 7, 3 } }) do
		V:mettre(b[1], b[2], -2, K.blanc, "Crete")
	end
	for _, b in ipairs({ { 3, 5 }, { 5, 3 } }) do
		V:mettre(b[1], b[2], -3, tache, "Crete")
	end
	local tete = { hw = 4, y = 1, h = 5, z = -8, d = 5, c = p.b }
	K.tete(V, tete)
	-- cornes de front : partent du crâne, montent et sortent devant la face
	K.chemin(V, { { 2, 6, -7 }, { 2, 6, -8 }, { 2, 7, -8 } }, function() return corne end, "Corne")
	V:mettre(2, 7, -9, K.blanc, "Corne")
	V:symetriser()
	K.volume(V, p)
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 2 and math.abs(x) <= 2 end, TRONC)
	K.repeindre(V, p, p.f, function(x, y, z) return y >= 5 and z % 3 == 0 end, CORPS)
	K.grain(V, p, TRONC)
	K.visage(V, tete)
	-- bec pointu de perroquet (rétrécit vers l'avant), bouche aux coins
	local bec, becF = K.hex("FF9F45"), K.hex("E07A2E")
	V:boite(-1, 2, -9, 1, 2, -9, bec, "Tete")
	V:mettre(0, 2, -10, bec, "Tete")
	V:mettre(0, 1, -9, becF, "Tete")
	V:mettre(0, 1, -10, becF, "Tete")
	V:mettre(1, 1, -9, K.bouche, "Bouche")
	V:mettre(-1, 1, -9, K.bouche, "Bouche")
	-- corne de nez : part du haut du bec, pointe blanche
	V:mettre(0, 3, -10, corne, "Corne")
	V:mettre(0, 4, -10, K.blanc, "Corne")
end

-- ===== Rare (10 à 11 cubes) =====

-- Stégo : deux rangées décalées de grandes plaques pointues orange, queue à pointes
function ESPECES.Stego(V, K)
	local p = K.pal("2EC4B6")
	local orange = K.hex("FF8C42")
	local bord = K.hex("D9601E")
	local ventre = K.hex("D6FFF7")
	V:boite(2, 0, -2, 3, 1, -1, p.f, "PatteAvD")
	V:boite(2, 0, 4, 3, 1, 5, p.f, "PatteArD")
	V:boite(2, 0, -2, 3, 0, -2, K.creme, "PatteAvD")
	V:boite(2, 0, 4, 3, 0, 4, K.creme, "PatteArD")
	K.pave(V, -3, 2, -3, 3, 6, 6, p.b, "Corps", 1)
	-- tête basse et plus étroite que le corps : le dos et les plaques se voient de face
	local tete = { hw = 3, y = 1, h = 5, z = -8, d = 5, c = p.b, museau = { hw = 2, d = 1 } }
	K.tete(V, tete)
	V:symetriser()
	-- queue légèrement courbée vers la droite : dépasse du flanc en 3/4
	V:tube(0, 4, 6, 3, 5, 11, 1.4, p.b, "Queue", 0.6)
	K.volume(V, p)
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 3 and math.abs(x) <= 2 end, TRONC)
	-- taches foncées sur les flancs
	K.repeindre(V, p, p.f, function(x, y, z) return math.abs(x) == 3 and y >= 4 and y <= 5 and z % 4 == 0 end, TRONC)
	K.grain(V, p, TRONC)
	K.visage(V, tete)
	-- plaques de 2 cubes d'épaisseur, décalées d'un côté à l'autre, plus hautes au milieu
	local petite, grande = { 1, 2, 1 }, { 1, 2, 1, 0 }
	K.plaque(V, 1, 2, 6, -2, petite, orange, bord, "Crete")
	K.plaque(V, 1, 2, 6, 2, grande, orange, bord, "Crete")
	K.plaque(V, 1, 2, 6, 6, petite, orange, bord, "Crete")
	K.plaque(V, -2, -1, 6, 0, grande, orange, bord, "Crete")
	K.plaque(V, -2, -1, 6, 4, petite, orange, bord, "Crete")
	-- thagomizer : paires de pointes crème à bout blanc, vers le haut et l'extérieur
	for _, pt in ipairs({ { 8, 1, 2 }, { 10, 2, 3 } }) do
		local z, xg, xd = pt[1], pt[2], pt[3]
		V:boite(xg, 6, z, xg, 7, z, K.creme, "Queue")
		V:boite(xd, 6, z, xd, 7, z, K.creme, "Queue")
		V:mettre(xg - 1, 7, z, K.blanc, "Queue")
		V:mettre(xd + 1, 7, z, K.blanc, "Queue")
	end
end

-- Parasaure : bec de canard jaune, longue crête rose en tube recourbé vers l'arrière
function ESPECES.Parasaure(V, K)
	local p = K.pal("4D96FF")
	local rose = K.pal("FF5CA8")
	local jaune = K.hex("FFD166")
	local jauneF = K.hex("F2A93B")
	local ventre = K.hex("FFE9B0")
	V:boite(2, 0, 2, 3, 1, 3, p.f, "PatteArD")
	V:boite(2, 0, 1, 3, 0, 1, jauneF, "PatteArD")
	V:boite(4, 3, -1, 4, 4, -1, p.b, "PatteAvD")
	K.pave(V, -3, 2, -2, 3, 5, 5, p.b, "Corps", 1)
	V:tube(0, 4, 5, 0, 3, 10, 1.4, p.b, "Queue", 0.5)
	local tete = { hw = 4, y = 3, h = 5, z = -6, d = 5, c = p.b }
	K.tete(V, tete)
	-- crête : part du crâne et monte de 3 cubes vers l'arrière, bout recourbé plus foncé
	V:tube(0, 8, -3, 0, 10, 4, 1, rose.b, "Crete", 0.7)
	V:boite(0, 10, 5, 0, 9, 6, rose.f, "Crete")
	V:symetriser()
	K.volume(V, p)
	K.volume(V, rose)
	-- deux anneaux plus clairs sur la crête
	V:peindre(function(x, y, z) if z == -1 or z == 2 then return rose.c end return nil end, "Crete")
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 4 and z <= 3 and math.abs(x) <= 2 end, TRONC)
	K.repeindre(V, p, rose.b, function(x, y, z) return y >= 4 and z >= 0 and z % 3 == 1 and math.abs(x) == 3 end, CORPS)
	K.grain(V, p, TRONC)
	K.visage(V, tete)
	-- bec de canard : rangée du haut sur 2 cubes, rangée du bas reculée d'un cube ; narines, commissures
	V:boite(-2, 4, -8, 2, 4, -7, jaune, "Tete")
	V:boite(-1, 3, -7, 1, 3, -7, jauneF, "Tete")
	V:mettre(2, 3, -7, K.bouche, "Bouche")
	V:mettre(-2, 3, -7, K.bouche, "Bouche")
	V:mettre(1, 4, -8, K.hex("C9731E"), "Tete") -- narines
	V:mettre(-1, 4, -8, K.hex("C9731E"), "Tete")
end

-- ===== Épique (10 à 12 cubes) =====

-- Ankylo : large carapace brune qui encadre la tête, pointes crème, massue au bout de la queue
function ESPECES.Ankylo(V, K)
	local p = K.pal("F4A259", "D9793A")
	local brun = K.pal("A0522D")
	local pointe = K.hex("FFF4DC")
	local ventre = K.hex("FFE3C2")
	V:boite(3, 0, -2, 4, 1, -1, p.f, "PatteAvD")
	V:boite(3, 0, 4, 4, 1, 5, p.f, "PatteArD")
	-- carapace plus large (13) que la tête (9) : bord brun visible tout autour
	K.pave(V, -6, 2, -3, 6, 7, 7, p.b, "Corps", 1)
	V:peindre(function(x, y, z) if y >= 5 then return brun.b end return nil end, "Corps")
	-- pointes latérales et dorsales de 2 cubes : dépassent de la silhouette de face
	for _, z in ipairs({ -1, 2, 5 }) do
		V:boite(7, 5, z, 8, 5, z, pointe, "Crete")
		V:boite(3, 8, z, 3, 9, z, pointe, "Crete")
	end
	for _, z in ipairs({ 0, 3 }) do
		V:boite(0, 8, z, 0, 9, z, pointe, "Crete")
	end
	-- tête basse devant la carapace (la nuque fait une marche)
	local tete = { hw = 4, y = 1, h = 6, z = -9, d = 6, c = p.b, t = 3, museau = { hw = 2, d = 1 } }
	K.tete(V, tete)
	-- cornes crème aux coins arrière du crâne
	V:boite(3, 7, -5, 3, 8, -5, pointe, "Corne")
	V:mettre(2, 7, -7, pointe, "Crete")
	V:symetriser()
	-- queue courbée vers la droite : la massue se voit de face et de 3/4
	V:tube(0, 4, 7, 4, 3, 11, 1.2, p.b, "Queue", 0.8)
	K.pave(V, 2, 2, 11, 6, 5, 13, brun.b, "Massue", 1)
	for _, b in ipairs({ { 7, 3, 12 }, { 4, 6, 12 }, { 4, 3, 14 }, { 5, 4, 14 } }) do
		V:mettre(b[1], b[2], b[3], pointe, "Massue")
	end
	K.volume(V, p)
	K.volume(V, brun)
	-- plaque brune peinte dans la rangée du haut de la tête
	V:peindre(function(x, y, z) if y == 6 then return brun.b end return nil end, "Tete")
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 3 and math.abs(x) <= 3 end, TRONC)
	K.grain(V, brun, TRONC)
	tete.langue = K.langue
	K.visage(V, tete)
end

-- Iguano : ardoise, debout, pouces en pointe, fanon orange, crête d'épines, ventre jaune
function ESPECES.Iguano(V, K)
	local p = K.pal("7A8CA8", "56647E")
	local ventre = K.hex("FFF4DC")
	local bande = K.hex("FFE14D")
	local orange = K.hex("FF9F1C")
	local jaune = K.hex("FFE14D")
	local fanon = K.hex("FF6B3D")
	local pouce = K.hex("FFF4DC")
	V:boite(2, 0, 1, 3, 1, 2, p.f, "PatteArD")
	V:boite(2, 0, 0, 3, 0, 0, p.ff, "PatteArD")
	K.pave(V, -3, 2, -2, 3, 8, 4, p.b, "Corps", 1)
	V:tube(0, 4, 4, 0, 2, 10, 1.5, p.b, "Queue", 0.5)
	local tete = { hw = 4, y = 6, h = 5, z = -6, d = 5, c = p.b, museau = { hw = 2, d = 2 } }
	K.tete(V, tete)
	-- bras posés APRÈS la tête et hors de son volume ; pouce crème en pointe vers l'avant
	V:boite(4, 3, -1, 4, 5, 0, p.b, "PatteAvD")
	V:boite(5, 4, -2, 5, 5, -1, p.b, "PatteAvD")
	V:boite(5, 6, -2, 5, 7, -2, pouce, "PatteAvD")
	V:mettre(5, 8, -2, K.blanc, "PatteAvD")
	V:symetriser()
	K.volume(V, p)
	-- ventre jaune étendu : se voit sous le menton entre les bras
	K.repeindre(V, p, ventre, function(x, y, z) return z <= -1 and y <= 7 and math.abs(x) <= 2 end, TRONC)
	V:peindre(function(x, y, z, v)
		if v.c.couleur == ventre and (y == 3 or y == 5 or y == 7) then return bande end
		return nil
	end, "Corps")
	K.repeindre(V, p, p.f, function(x, y, z) return z >= 2 and z % 2 == 0 and math.abs(x) <= 2 end, CORPS)
	K.grain(V, p, { Corps = true, Tete = true })
	tete.langue = K.langue
	K.visage(V, tete)
	-- fanon orange-rouge sous le museau, écaille jaune
	V:boite(-1, 5, -7, 1, 5, -6, fanon, "Tete")
	V:mettre(0, 4, -7, fanon, "Tete")
	V:mettre(0, 4, -6, jaune, "Tete")
	-- épines : crâne (jaune à pointe orange) puis dos (orange)
	V:boite(0, 10, -5, 0, 10, -3, jaune, "Crete")
	V:mettre(0, 11, -4, orange, "Crete")
	for _, z in ipairs({ -1, 1, 3 }) do
		V:mettre(0, 9, z, jaune, "Crete")
		V:mettre(0, 10, z, orange, "Crete")
	end
	V:mettre(0, 7, 5, orange, "Crete")
end

-- ===== Légendaire (12 à 14 cubes) =====

-- Brachio : girafe jaune à taches orange, long cou dressé, couronne de fleurs, bouquet dans la bouche
function ESPECES.Brachio(V, K)
	local p = K.pal("FFD23F", "F2B02E")
	local orange = K.hex("FF9F1C")
	local ventre = K.hex("FFE08A")
	local feuille = K.hex("5BD13B")
	local feuilleClaire = K.hex("9BEA5E")
	local fleur = K.hex("FF6FAE")
	-- pattes avant plus longues : le poitrail se relève
	V:boite(2, 0, -3, 3, 3, -2, p.f, "PatteAvD")
	V:boite(2, 0, 4, 3, 1, 5, p.f, "PatteArD")
	V:boite(2, 0, -4, 3, 0, -4, K.creme, "PatteAvD")
	V:boite(2, 0, 3, 3, 0, 3, K.creme, "PatteArD")
	K.pave(V, -4, 2, -2, 4, 6, 7, p.b, "Corps", 1)
	-- long cou dressé (girafe) : 3 à 4 rangées visibles entre le corps et la tête
	V:tube(0, 5, -2, 0, 10, -7, 1.6, p.b, "Cou", 1.3)
	V:tube(0, 4, 7, 0, 2, 13, 1.6, p.b, "Queue", 0.6)
	local tete = { hw = 3, y = 8, h = 5, z = -11, d = 5, c = p.b, museau = { hw = 2, d = 1 } }
	K.tete(V, tete)
	V:symetriser()
	K.volume(V, p)
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 3 and math.abs(x) <= 3 end, TRONC)
	-- grandes taches orange (blocs 2 x 2 bien espacés) sur le corps, le cou et la queue
	K.repeindre(V, p, orange, function(x, y, z)
		local bx, by, bz = math.floor(math.abs(x) / 2), math.floor(y / 2), math.floor(z / 2)
		return y >= 4 and by % 2 == 0 and (bz + bx + by / 2) % 3 == 0
	end, CORPS)
	-- bosse orange peinte au milieu du crâne
	V:boite(-1, 12, -9, 1, 12, -9, orange, "Tete")
	tete.langue = K.langue
	K.visage(V, tete)
	-- couronne de fleurs posée sur le crâne : fleurs roses et blanches sur des feuilles
	for x = -2, 2 do
		for z = -10, -8 do
			if math.abs(x) == 2 or z ~= -9 then
				V:mettre(x, 13, z, feuille, "Crete")
			end
		end
	end
	for _, f in ipairs({ { 0, -10, fleur }, { 2, -10, K.blanc }, { -2, -10, K.blanc }, { 2, -8, fleur }, { -2, -8, fleur }, { 0, -8, K.blanc } }) do
		V:mettre(f[1], 13, f[2], f[3], "Crete")
	end
	-- bouquet de feuilles au coin de la bouche : tige, touffe 2 x 2 en biais, une fleur
	V:mettre(3, 8, -12, K.hex("8B5A2B"), "Tete")
	V:boite(4, 8, -12, 5, 9, -12, feuille, "Tete")
	V:mettre(4, 9, -12, feuilleClaire, "Tete")
	V:mettre(5, 8, -12, feuilleClaire, "Tete")
	V:mettre(5, 9, -13, feuilleClaire, "Tete")
	V:mettre(5, 10, -12, fleur, "Tete")
end

-- ===== Mythique (14 à 16 cubes) =====

-- Diplodo : très long, cou dressé annelé, damier rose sur le dos, cristaux Neon cyan en pointe
function ESPECES.Diplodo(V, K)
	local p = K.pal("B15CFF")
	local rose = K.hex("FF6FD8")
	local socle = K.hex("7FE8FF")
	local cristal = { couleur = K.hex("00B8FF"), materiau = Enum.Material.Neon }
	local ventre = K.hex("FFC2F0")
	V:boite(2, 0, -3, 3, 2, -2, p.f, "PatteAvD")
	V:boite(2, 0, 5, 3, 2, 6, p.f, "PatteArD")
	V:boite(2, 0, -3, 3, 0, -3, K.creme, "PatteAvD")
	V:boite(2, 0, 5, 3, 0, 5, K.creme, "PatteArD")
	K.pave(V, -4, 3, -4, 4, 8, 8, p.b, "Corps", 1)
	-- cou dressé : 3 cubes visibles entre le corps et la tête
	V:tube(0, 8, -3, 0, 11, -11, 1.6, p.b, "Cou", 1.2)
	V:tube(0, 6, 8, 0, 4, 14, 1.5, p.b, "Queue", 0.9)
	local tete = { hw = 3, y = 10, h = 5, z = -16, d = 5, c = p.b, museau = { hw = 2, d = 1 } }
	K.tete(V, tete)
	V:symetriser()
	-- bout de queue en fouet, recourbé vers la droite, cristal dans l'alignement
	V:tube(0, 4, 14, 3, 3, 18, 0.9, p.b, "Queue", 0.5)
	V:mettre(3, 3, 19, cristal, "Queue")
	K.volume(V, p)
	K.repeindre(V, p, ventre, function(x, y, z) return y <= 4 and math.abs(x) <= 3 end, TRONC)
	-- damier rose sur le dessus du corps (cases de 3, lisibles par-dessus), anneaux roses sur le cou
	K.repeindre(V, p, rose, function(x, y, z)
		return y >= 8 and (math.floor((x + 1) / 3) + math.floor(z / 3)) % 2 == 0
	end, TRONC)
	K.repeindre(V, p, rose, function(x, y, z) return z % 3 == 0 end, { Cou = true })
	tete.langue = K.langue
	K.visage(V, tete)
	-- cristaux de l'échine : socle clair, pointe Neon saturée
	for _, c in ipairs({ { -1, 1 }, { 2, 2 }, { 5, 1 } }) do
		V:boite(0, 9, c[1], 0, 8 + c[2], c[1], socle, "Cristal")
		V:mettre(0, 9 + c[2], c[1], cristal, "Cristal")
	end
	-- diadème : trois cristaux (socle peint dans le crâne, pointe Neon seulement au centre)
	V:mettre(0, 14, -14, socle, "Cristal")
	V:mettre(0, 15, -14, cristal, "Cristal")
	for _, s in ipairs({ 2, -2 }) do
		V:mettre(s, 14, -13, socle, "Cristal")
		V:mettre(s, 15, -13, socle, "Cristal")
	end
end

-- ===== Divin (15 à 17 cubes) =====

-- Thérizino : plumage blanc et or, faux dorées à pointe Neon, crête de plumes, auréole verticale
function ESPECES.Therizino(V, K)
	local p = K.pal("FFF8EE", "FFE9C2")
	local or_ = K.pal("FFC933", "F29E1F")
	local rose = K.pal("FF5CE1")
	local neonOr = { couleur = K.hex("FFB300"), materiau = Enum.Material.Neon }
	V:boite(1, 0, 1, 2, 3, 2, or_.f, "PatteArD")
	V:boite(1, 0, 0, 2, 0, 0, or_.b, "PatteArD")
	K.pave(V, -3, 3, -3, 3, 9, 4, p.b, "Corps", 1)
	V:boite(-3, 9, -3, 3, 9, -3, p.b, "Corps") -- nuque : la tête tient au corps
	-- bras blancs, main dorée
	V:boite(4, 6, -3, 4, 8, -1, p.b, "PatteAvD")
	V:boite(4, 6, -5, 6, 7, -4, or_.b, "PatteAvD")
	-- queue en plumes
	V:tube(0, 6, 4, 0, 8, 8, 1.4, p.b, "Queue", 0.8)
	V:boite(0, 8, 8, 0, 10, 9, or_.b, "Queue")
	V:mettre(1, 9, 8, or_.b, "Queue")
	local tete = { hw = 4, y = 9, h = 6, z = -6, d = 6, c = p.b, t = 3, museau = { hw = 1, d = 2, c = or_.b, bec = or_.f } }
	K.tete(V, tete)
	-- crête de plumes dorées
	V:boite(0, 15, -5, 0, 15, -1, or_.c, "Crete")
	-- trois faux courbes par main (arrêtées au-dessus du sol), seule la pointe est en Neon
	for _, lame in ipairs({ { 4, 0 }, { 5, 1 }, { 6, 0 } }) do
		local x, recul = lame[1], lame[2]
		local c = function() return K.hex("FFC933") end
		K.chemin(V, { { x, 5, -5 }, { x, 5, -6 }, { x, 4 + recul, -6 }, { x, 4 + recul, -7 }, { x, 3 + recul, -7 } }, c, "PatteAvD")
		V:mettre(x, 3 + recul, -8, neonOr, "PatteAvD")
	end
	-- ventre blanc bordé d'or (peint sur la face avant du corps)
	K.ellipsoideSi(V, 0, 5.5, -3, 3.6, 3.1, 0.6, or_.b, "Corps", function(x, y, z) return y <= 8 end)
	K.ellipsoideSi(V, 0, 5.5, -3, 2.9, 2.5, 0.6, K.blanc, "Corps", function() return true end)
	V:symetriser()
	-- auréole verticale derrière la tête : arche dorée qui l'entoure vue de face, éclats Neon
	local points = {}
	for a = 0, 20 do
		local ang = math.rad(-25 + a * 11.5)
		table.insert(points, { math.floor(math.cos(ang) * 5.6 + 0.5), math.floor(12.4 + math.sin(ang) * 3.6 + 0.5), 0 })
	end
	K.chemin(V, points, function(i) if i % 6 == 3 then return neonOr end return or_.c end, "Aureole")
	K.volume(V, p)
	-- plumes dorées en blocs 2 x 2 sur le dos et les flancs
	K.repeindre(V, p, or_.b, function(x, y, z)
		return y >= 7 and z >= 1 and (math.floor(z / 2) + math.floor(y / 2)) % 2 == 0
	end, CORPS)
	tete.couleurJoue = rose.b
	tete.blanc = or_.c -- œil cerclé d'or (un blanc disparaîtrait sur la tête blanche)
	K.visage(V, tete)
end

-- ===== construction =====
local ORDRE = { "Galli", "Pachy", "Tricera", "Stego", "Parasaure", "Ankylo", "Iguano", "Brachio", "Diplodo", "Therizino" }

-- lumière d'aura (Mythique et plus), mêmes réglages que aura() côté carnivores
local AURAS = { Diplodo = "5CF2FF", Therizino = "FFD84D" }

local function construireEspece(ctx, K, dossier, cle, infos)
	local fabrique = ESPECES[cle]
	if not fabrique then
		return false
	end
	local ancien = dossier:FindFirstChild(cle)
	if ancien then
		ancien:Destroy()
	end
	local V = ctx.Voxel.nouveau()
	fabrique(V, K)
	local modele = V:construire(dossier, { nom = cle, origine = CFrame.new(), budget = BUDGET })
	modele:SetAttribute("Espece", cle)
	modele:SetAttribute("Rarete", infos.rarete or "Commun")
	modele:SetAttribute("Famille", "Herbivore")
	if AURAS[cle] and modele.PrimaryPart then
		local l = Instance.new("PointLight")
		l.Name = "Aura"
		l.Color = K.hex(AURAS[cle])
		l.Range = 14
		l.Brightness = 1.2
		l.Shadows = false
		l.Parent = modele.PrimaryPart
	end
	return true
end

function M.construire(ctx)
	local E = ctx.Equilibrage
	local stockage = ctx.stockage
	if not stockage or not E or type(E.especes) ~= "table" or not ctx.Voxel then
		return
	end
	local dossier = stockage:FindFirstChild("Dinos")
	if not dossier then
		dossier = ctx.Outils.dossier(stockage, "Dinos")
	end
	local K = kit(ctx)
	for _, cle in ipairs(ORDRE) do
		local infos = E.especes[cle]
		if type(infos) == "table" and infos.famille == "Herbivore" then
			local ok, err = pcall(construireEspece, ctx, K, dossier, cle, infos)
			if not ok then
				warn("[Dino] gabarit voxel « " .. cle .. " » : " .. tostring(err))
			end
		end
	end
end

return M
