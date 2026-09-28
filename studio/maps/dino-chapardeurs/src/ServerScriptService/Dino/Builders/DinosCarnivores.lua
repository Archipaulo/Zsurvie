-- Constructeur DinosCarnivores : gabarits des 10 espèces de la famille « Carnivore »
-- (carnivores, volant et marin), rangés dans ServerStorage.Dino.Dinos.
-- Version 4 « petits cubes » (STYLE.md §5) : chaque dino est modélisé en voxels avec ctx.Voxel,
-- comme les créatures des simulateurs « Steal a … » : grosse tête chibi en boîte arrondie,
-- gros yeux sur la face (pupille noire qui regarde devant, reflet isolé en haut, blanc côté extérieur,
-- toujours au moins une colonne de peau jusqu'au bord), joues roses, bouche lisible avec crocs,
-- volume par la couleur (dessus clair, dessous foncé), ventre contrasté, motifs et accessoires
-- contrastés (crêtes, cornes, collerette, voile, couronne, ailes, auréole, anneau de Saturne).
-- Texture « petits cubes » : après le modelage, des paires de cubes voisins prennent une nuance
-- plus claire ou plus foncée (grain stable par hachage), dans la limite du budget de parts.
-- Visage rangé dans ses propres groupes (Oeil, Pupille, Reflet, Iris, Sourcil, Joue, Bouche, Dent,
-- Narine) : les mutations (Tapis.appliquerMutation) ne le recolorent pas.
-- Taille selon la rareté, Neon à partir de Mythique, 150 parts au plus par dino.
-- Repère : origine au sol sous le centre du dino, regard vers -Z ; on modèle le côté droit (x > 0),
-- la gauche est recopiée par V:symetriser() (groupes « …D » -> « …G »).
local M = {}

local BUDGET = 150 -- parts maximum par gabarit (vérifié par Voxel:construire)
local MARGE = 2 -- parts gardées en réserve sous le budget quand on pose le grain

function M.construire(ctx)
	local Charte = ctx.Charte
	local Voxel = ctx.Voxel
	local E = ctx.Equilibrage
	local stockage = ctx.stockage
	if not (Charte and Voxel and E and E.especes and stockage) then
		return
	end

	local dossierDinos = stockage:FindFirstChild("Dinos")
	if not dossierDinos then
		if ctx.Outils and ctx.Outils.dossier then
			dossierDinos = ctx.Outils.dossier(stockage, "Dinos")
		else
			dossierDinos = Instance.new("Folder")
			dossierDinos.Name = "Dinos"
			dossierDinos.Parent = stockage
		end
	end

	local hex = Charte.hex
	local NEON = Enum.Material.Neon

	-- ===== palette =====
	local BLANC = Color3.new(1, 1, 1)
	local NOIR = Charte.encre or hex("1B1A2E")
	local JOUE = hex("FF8FB8")
	local BOUCHE = hex("6E1230")
	local GRIFFE = hex("FFF6E0")
	local OR = hex("FFC933")

	-- trois teintes d'une couleur : base, dessus (lumière) et dessous (ombre)
	local function clair(c)
		return Charte.lumiere(c)
	end
	local function fonce(c)
		return Charte.ombre(c)
	end
	local function neon(c)
		return { couleur = c, materiau = NEON }
	end

	-- petit hachage stable dans [0, 1[ (grain, étoiles, taches)
	local function hache(x, y, z)
		local s = math.sin(x * 12.9898 + y * 78.233 + z * 37.719) * 43758.5453
		return s - math.floor(s)
	end

	-- ===== outils de modelage =====

	-- superellipsoïde : n = 2 boule, n = 4 à 6 boîte aux coins arrondis
	local function bloc(V, cx, cy, cz, rx, ry, rz, couleur, groupe, n)
		n = n or 4
		for x = math.floor(cx - rx), math.ceil(cx + rx) do
			for y = math.floor(cy - ry), math.ceil(cy + ry) do
				for z = math.floor(cz - rz), math.ceil(cz + rz) do
					local dx = math.abs((x - cx) / rx)
					local dy = math.abs((y - cy) / ry)
					local dz = math.abs((z - cz) / rz)
					if dx ^ n + dy ^ n + dz ^ n <= 1.05 then
						V:mettre(x, y, z, couleur, groupe)
					end
				end
			end
		end
	end

	-- repeint le cube le plus en avant (plus petit z) de la colonne (x, y) : peinture sur la face ;
	-- groupe : nouveau groupe du cube (Oeil, Pupille… pour que les mutations épargnent le visage)
	local function face(V, x, y, couleur, zmin, zmax, groupe)
		for z = zmin, zmax do
			local v = V:lire(x, y, z)
			if v then
				V:mettre(x, y, z, couleur, groupe or v.g)
				return z
			end
		end
		return nil
	end

	-- plus haut cube de la colonne (x, z) (nil si vide)
	local function sommet(V, x, z, ymax)
		for y = ymax or 40, 0, -1 do
			if V:lire(x, y, z) then
				return y
			end
		end
		return nil
	end

	-- repeint le cube le plus à l'extérieur (plus grand x) de la rangée (y, z) : tache sur un flanc
	local function flanc(V, y, z, couleur, groupe, xmax)
		for x = xmax or 12, 1, -1 do
			local v = V:lire(x, y, z)
			if v then
				V:mettre(x, y, z, couleur, groupe or v.g)
				return x
			end
		end
		return nil
	end

	-- gros œil peint sur la face (œil droit ; x0 = colonne intérieure, y0 = ligne du bas,
	-- e = taille, o.l / o.h = largeur / hauteur si l'œil n'est pas carré) :
	-- pupille noire côté intérieur sur toute la hauteur (regard droit devant), blanc sur la colonne
	-- extérieure, reflet blanc en haut à l'intérieur (il touche la peau et la pupille, jamais le blanc),
	-- colonne d'iris éventuelle entre pupille et blanc (o.blanc : autre « blanc » sur une peau claire),
	-- sourcil éventuel, joues roses dessous
	local function yeux(V, x0, y0, e, zmin, zmax, o)
		o = o or {}
		local l, h = o.l or e, o.h or e
		for dx = 0, l - 1 do
			for dy = 0, h - 1 do
				local col, g = NOIR, "Pupille"
				if dx == l - 1 then
					col, g = o.blanc or BLANC, "Oeil"
				elseif o.iris and l >= 3 and dx == l - 2 and dy < h - 1 then
					col, g = o.iris, "Iris"
				end
				face(V, x0 + dx, y0 + dy, col, zmin, zmax, g)
			end
		end
		face(V, x0, y0 + h - 1, BLANC, zmin, zmax, "Reflet")
		if o.sourcil then
			for dx = 0, l - 1 do
				face(V, x0 + dx, y0 + h, o.sourcil, zmin, zmax, "Sourcil")
			end
			if o.sourcilBas then
				-- bout intérieur abaissé dans la peau entre les yeux : air colérique sans toucher l'œil
				face(V, x0 - 1, y0 + h - 1, o.sourcil, zmin, zmax, "Sourcil")
			end
		end
		if o.joue ~= false then
			local yj = y0 - 1 - (o.joueBas or 0)
			local cj = o.couleurJoue or JOUE
			face(V, x0 + l - 2, yj, cj, zmin, zmax, "Joue")
			face(V, x0 + l - 1, yj, cj, zmin, zmax, "Joue")
		end
	end

	-- tête chibi : boîte arrondie ; T = { W (demi-largeur), yb (bas), H (hauteur), zf (face), D (profondeur), n } ;
	-- rangée du haut claire (la rangée du bas, cachée par le museau, garde la couleur de base)
	local function tete(V, T, couleur, cl, fo)
		local cy = T.yb + (T.H - 1) / 2
		local cz = T.zf + (T.D - 1) / 2
		bloc(V, 0, cy, cz, T.W + 0.5, (T.H - 1) / 2 + 0.5, (T.D - 1) / 2 + 0.5, couleur, "Tete", T.n or 6)
		local haut = T.yb + T.H - 1
		V:peindre(function(_, y)
			if y >= haut then
				return cl
			end
			return nil
		end, "Tete")
	end

	-- museau en boîte devant la face, coins avant arrondis : mâchoire du bas contrastée (y0),
	-- o.rangs rangées de bouche foncée (front et côtés), dessus clair (y1), crocs blancs, narines.
	-- Mu = { w (demi-largeur), y0 (bas), y1 (haut), L (longueur devant la face) }
	-- o.dents : x des crocs qui pendent de la mâchoire du haut (rangée de bouche du haut) ;
	-- o.crocs : cubes blancs posés sur la face avant { x, y } ; o.dentsCote : crocs sur le côté (dz)
	local function museau(V, Mu, zf, couleur, o)
		local z0, z1 = zf - Mu.L, zf
		local nb = o.rangs or 1
		V:boite(0, Mu.y0, z0, Mu.w, Mu.y1, z1, couleur, "Tete")
		V:boite(0, Mu.y0, z0, Mu.w, Mu.y0, z1, o.machoire or couleur, "Tete")
		V:boite(0, Mu.y1, z0, Mu.w, Mu.y1, z1, o.dessus or couleur, "Tete")
		local yb, yh = Mu.y0 + 1, Mu.y0 + nb
		V:boite(0, yb, z0, Mu.w, yh, z0, BOUCHE, "Bouche")
		V:boite(Mu.w, yb, z0, Mu.w, yh, z1, BOUCHE, "Bouche")
		for _, x in ipairs(o.dents or {}) do
			V:mettre(x, yh, z0, BLANC, "Dent")
		end
		for _, d in ipairs(o.crocs or {}) do
			V:mettre(d[1], d[2], z0, BLANC, "Dent")
		end
		for _, dz in ipairs(o.dentsCote or {}) do
			V:mettre(Mu.w, yh, z0 + dz, BLANC, "Dent")
		end
		-- coins avant arrondis
		V:mettre(Mu.w, Mu.y1, z0, nil)
		V:mettre(Mu.w, Mu.y0, z0, nil)
		if o.narines ~= false and Mu.y1 > yh then -- (museau de 2 rangées : la bouche prend la rangée du haut)
			V:mettre(1, Mu.y1, z0, o.narine or fonce(couleur), "Narine")
		end
		return z0
	end

	-- queue en tronçons de boîtes qui s'affinent et remontent : liste de { demiLargeur, yBas, yHaut, longueur } ;
	-- dessus clair (le dessous, jamais vu, reste de la couleur de base : moins de parts)
	local function queue(V, z0, troncons, couleur, cl, fo)
		local z = z0
		for _, t in ipairs(troncons) do
			local hw, ya, yh, l = t[1], t[2], t[3], t[4]
			V:boite(0, ya, z, hw, yh, z + l - 1, couleur, "Queue")
			if yh > ya then
				V:boite(0, yh, z, hw, yh, z + l - 1, cl, "Queue")
			end
			z = z + l
		end
		return z - 1
	end

	-- théropode chibi : jambes, corps, queue, petits bras, tête, museau, yeux ; volume par la couleur
	-- P : couleur, clair, fonce, ventre, machoire, jambe { x, y, z, r, s, avant, hp, griffes },
	--     corps { y, z, rx, ry, rz, n }, tete { W, yb, H, zf, D, n }, museau { w, y0, y1, L, rangs },
	--     queue { z0, troncons }, bras { x, y, z, griffe }, yeux { x0, y0, e, l, h, iris, sourcil… },
	--     dents, crocs, dentsCote, narines
	local function theropode(V, P)
		local c = P.couleur
		local cl, fo = P.clair or clair(c), P.fonce or fonce(c)
		local J, C, T, Mu, Q, B = P.jambe, P.corps, P.tete, P.museau, P.queue, P.bras

		-- jambes (côté droit) : cuisse arrondie, mollet, pied, griffes
		bloc(V, J.x, J.y, J.z, J.r, J.r + 0.3, J.r + 0.5, c, "PatteArD", 6)
		V:boite(J.x - J.s, 1, J.z - J.s, J.x + J.s, math.max(1, math.floor(J.y)), J.z + J.s, fo, "PatteArD")
		local avant = J.avant or 2
		V:boite(J.x - 1, 0, J.z - avant, J.x + 1, J.hp or 0, J.z + 1, fo, "PatteArD")
		if J.griffes then
			V:boite(J.x - 1, 0, J.z - avant - 1, J.x + 1, 0, J.z - avant - 1, J.griffes, "PatteArD")
		else
			V:mettre(J.x - 1, 0, J.z - avant - 1, GRIFFE, "PatteArD")
			V:mettre(J.x + 1, 0, J.z - avant - 1, GRIFFE, "PatteArD")
		end
		-- corps
		bloc(V, 0, C.y, C.z, C.rx, C.ry, C.rz, c, "Corps", C.n or 3)
		V:peindre(function(x, y, z)
			if y >= C.y + C.ry * 0.35 then
				return cl
			elseif y <= C.y - C.ry * 0.55 then
				return fo
			elseif P.ventre and z <= C.z and math.abs(x) <= C.rx * 0.6 then
				return P.ventre
			end
			return nil
		end, "Corps")
		if P.ventre then
			V:peindre(function(x, y, z)
				if z <= C.z - C.rz * 0.3 and y < C.y + C.ry * 0.35 and math.abs(x) <= C.rx * 0.6 then
					return P.ventre
				end
				return nil
			end, "Corps")
		end
		-- queue
		queue(V, Q.z0, Q.troncons, c, cl, fo)
		-- petits bras : griffe seulement si la tête est haute (sinon elle se lit comme un débris
		-- sous le menton), dans la couleur foncée du corps sauf griffe choisie
		if B then
			V:boite(B.x, B.y - 1, B.z - 1, B.x, B.y, B.z, c, "PatteAvD")
			if B.griffe ~= false and T.yb > 3 then
				V:mettre(B.x, B.y - 1, B.z - 2, B.griffe or fo, "PatteAvD")
			end
		end
		-- tête et museau
		tete(V, T, c, cl, fo)
		museau(V, Mu, T.zf, c, {
			machoire = P.machoire or P.ventre or fo,
			dessus = cl,
			rangs = Mu.rangs,
			dents = P.dents,
			crocs = P.crocs,
			dentsCote = P.dentsCote,
			narines = P.narines,
		})
		local Y = P.yeux
		yeux(V, Y.x0, Y.y0, Y.e, T.zf - Mu.L - 2, T.zf + T.D, Y)
		V.teintes = { c, cl }
	end

	-- motif en rayures transversales sur le dos (corps et queue) : liste de z
	local function rayures(V, liste, couleur, yMin, groupes)
		local set = {}
		for _, z in ipairs(liste) do
			set[z] = true
		end
		for _, g in ipairs(groupes or { "Corps", "Queue" }) do
			V:peindre(function(_, y, z)
				if set[z] and y >= yMin then
					return couleur
				end
				return nil
			end, g)
		end
	end

	-- anneau plat rectangulaire aux coins coupés (couronne) : 4 barres
	local function anneau(V, cx, y, cz, rx, rz, couleur, groupe)
		V:boite(cx - rx + 1, y, cz - rz, cx + rx - 1, y, cz - rz, couleur, groupe)
		V:boite(cx - rx + 1, y, cz + rz, cx + rx - 1, y, cz + rz, couleur, groupe)
		V:boite(cx - rx, y, cz - rz + 1, cx - rx, y, cz + rz - 1, couleur, groupe)
		V:boite(cx + rx, y, cz - rz + 1, cx + rx, y, cz + rz - 1, couleur, groupe)
	end

	-- vrai si le voxel v a au moins une face à l'air libre
	local function visible(V, v)
		return not (V:lire(v.x + 1, v.y, v.z) and V:lire(v.x - 1, v.y, v.z) and V:lire(v.x, v.y + 1, v.z)
			and V:lire(v.x, v.y - 1, v.z) and V:lire(v.x, v.y, v.z + 1) and V:lire(v.x, v.y, v.z - 1))
	end

	-- sème des cubes (étoiles, points lumineux) sur la surface : test(x, y, z, v) choisit les cubes
	-- candidats, couleurs est une liste utilisée en alternance, max le nombre de cubes posés
	local function semer(V, test, couleurs, max)
		local liste = {}
		for _, v in pairs(V.grille) do
			if v.c.materiau == nil and test(v.x, v.y, v.z, v) and visible(V, v) then
				table.insert(liste, v)
			end
		end
		table.sort(liste, function(a, b)
			return hache(a.z, a.x, a.y) < hache(b.z, b.x, b.y)
		end)
		for i = 1, math.min(max, #liste) do
			local v = liste[i]
			V:mettre(v.x, v.y, v.z, couleurs[(i - 1) % #couleurs + 1], v.g)
		end
	end

	-- nombre de parts que Voxel:construire fabriquera (même maillage glouton, sans rien créer)
	local function cle(x, y, z)
		return x .. "," .. y .. "," .. z
	end
	local function compter(V)
		local grille = V.grille
		local cache = {}
		local function interieur(v)
			local r = cache[v]
			if r == nil then
				r = (grille[cle(v.x + 1, v.y, v.z)] and grille[cle(v.x - 1, v.y, v.z)]
					and grille[cle(v.x, v.y + 1, v.z)] and grille[cle(v.x, v.y - 1, v.z)]
					and grille[cle(v.x, v.y, v.z + 1)] and grille[cle(v.x, v.y, v.z - 1)]) and true or false
				cache[v] = r
			end
			return r
		end
		local parGroupe = {}
		for _, v in pairs(grille) do
			parGroupe[v.g] = parGroupe[v.g] or {}
			table.insert(parGroupe[v.g], v)
		end
		local n = 0
		for g, liste in pairs(parGroupe) do
			table.sort(liste, function(a, b)
				local ia, ib = interieur(a), interieur(b)
				if ia ~= ib then
					return ib
				end
				if a.z ~= b.z then
					return a.z < b.z
				end
				if a.y ~= b.y then
					return a.y < b.y
				end
				return a.x < b.x
			end)
			local pris = {}
			local function libre(x, y, z, c)
				local v = grille[cle(x, y, z)]
				if not v or v.g ~= g or pris[v] then
					return false
				end
				return (v.c.couleur == c.couleur and v.c.materiau == c.materiau) or interieur(v)
			end
			for _, graine in ipairs(liste) do
				if not pris[graine] then
					local c = graine.c
					local x0, y0, z0 = graine.x, graine.y, graine.z
					local x1 = x0
					while libre(x1 + 1, y0, z0, c) do
						x1 = x1 + 1
					end
					local y1 = y0
					local ok = true
					while ok do
						for x = x0, x1 do
							if not libre(x, y1 + 1, z0, c) then
								ok = false
								break
							end
						end
						if ok then
							y1 = y1 + 1
						end
					end
					local z1 = z0
					ok = true
					while ok do
						for x = x0, x1 do
							for y = y0, y1 do
								if not libre(x, y, z1 + 1, c) then
									ok = false
									break
								end
							end
							if not ok then
								break
							end
						end
						if ok then
							z1 = z1 + 1
						end
					end
					for x = x0, x1 do
						for y = y0, y1 do
							for z = z0, z1 do
								pris[grille[cle(x, y, z)]] = true
							end
						end
					end
					n = n + 1
				end
			end
		end
		return n
	end

	-- texture « petits cubes » : sur les cubes visibles des teintes de base, des paires de 2 cubes
	-- voisins (alignés en z ou en y) prennent une nuance plus claire ou plus foncée (hachage stable).
	-- Chaque paire n'est gardée que si elle coûte au plus o.cout parts et tient dans le budget :
	-- on obtient le grain le plus dense possible pour les 150 parts
	local function grain(V, teintes, o)
		o = o or {}
		local force = o.force or 1
		local taux = o.taux or 0.3
		local cands = {}
		for _, v in pairs(V.grille) do
			if v.c.materiau == nil then
				for _, t in ipairs(teintes) do
					if v.c.couleur == t then
						for _, d in ipairs({ { 0, 0, 1 }, { 0, 1, 0 } }) do
							local w = V:lire(v.x + d[1], v.y + d[2], v.z + d[3])
							local pair = (d[3] == 1 and v.z % 2 == 0) or (d[2] == 1 and v.y % 2 == 0)
							if pair and w and w.g == v.g and w.c.materiau == nil and w.c.couleur == t
								and visible(V, v) and visible(V, w) then
								local h = hache(v.x + d[2] * 0.5, v.y, v.z)
								if h < taux then
									local nuance
									if h < taux * 0.55 then
										nuance = t:Lerp(Charte.creme, 0.3 * force)
									else
										nuance = t:Lerp(Charte.ombre(t), 0.85 * force)
									end
									-- priorité aux cubes vus de la vitrine : face avant, flancs, dessus
									local vu = not V:lire(v.x, v.y, v.z - 1) or not V:lire(v.x, v.y + 1, v.z)
										or not V:lire(v.x + (v.x >= 0 and 1 or -1), v.y, v.z)
									table.insert(cands, { v, w, nuance, hache(v.z, v.y + d[2], v.x) - (vu and 1 or 0) })
								end
							end
						end
						break
					end
				end
			end
		end
		table.sort(cands, function(a, b)
			return a[4] < b[4]
		end)
		local limite = BUDGET - MARGE
		local cout = o.cout or 2
		local max = o.max or 25
		local essais = o.essais or 70
		local pris = {}
		local total = compter(V)
		local n = 0
		-- 1re passe : les paires qui coûtent le moins ; 2e passe : un peu plus chères s'il reste du budget
		for passe = 1, 2 do
			local c = (passe == 1) and cout or cout + 1
			for i = 1, math.min(#cands, essais) do
				if n >= max or total >= limite then
					break
				end
				local k = cands[i]
				if not pris[k[1]] and not pris[k[2]] then
					local a, b = k[1].c, k[2].c
					k[1].c = { couleur = k[3], materiau = nil }
					k[2].c = { couleur = k[3], materiau = nil }
					local t = compter(V)
					if t <= limite and t - total <= c then
						total = t
						n = n + 1
						pris[k[1]] = true
						pris[k[2]] = true
					else
						k[1].c, k[2].c = a, b
					end
				end
			end
		end
		return n
	end

	-- petite lumière d'aura sur la part principale (Mythique et plus)
	local function aura(modele, couleur, portee)
		local corps = modele.PrimaryPart
		if not corps then
			return
		end
		local l = Instance.new("PointLight")
		l.Name = "Aura"
		l.Color = couleur
		l.Range = portee or 14
		l.Brightness = 1.2
		l.Shadows = false
		l.Parent = corps
	end

	-- ===== les espèces =====
	-- chaque recette modèle le côté droit ; elle peut renvoyer { apres = fonction(V) } (détails
	-- asymétriques posés après la symétrie) et { grain = { max, force } }
	local ESPECES = {}

	-- Compy (Commun, 8 cubes) : bébé lézard vert pomme, ventre crème, taches jaunes, crête orange en pics
	ESPECES.Compy = function(V)
		local c = hex("7ED957")
		theropode(V, {
			couleur = c,
			ventre = hex("FFF1B8"),
			jambe = { x = 2, y = 1.6, z = 2, r = 1, s = 0 },
			corps = { y = 3, z = 3, rx = 3.4, ry = 2.4, rz = 3, n = 4 },
			tete = { W = 4, yb = 3, H = 4, zf = -5, D = 5 },
			museau = { w = 2, y0 = 2, y1 = 3, L = 2 },
			queue = { z0 = 6, troncons = { { 2, 2, 4, 2 }, { 1, 3, 4, 2 }, { 0, 4, 4, 2 } } },
			bras = { x = 3, y = 2, z = -1 },
			yeux = { x0 = 1, y0 = 4, e = 3 },
			dents = { 1 },
		})
		-- taches jaunes sur les flancs (à la place des rayures vert sapin du Rex)
		local jaune = hex("FFE14D")
		for _, s in ipairs({ { 3, 1 }, { 3, 4 }, { 2, 6 } }) do
			flanc(V, s[1], s[2], jaune, "Tache")
		end
		V:mettre(1, 4, 8, jaune, "Queue")
		-- crête orange : arête peinte dans la rangée du haut de la tête et deux pics clairs
		local orange = hex("FF9F1C")
		V:boite(0, 6, -4, 0, 6, -1, orange, "Crete")
		V:mettre(0, 7, -4, hex("FFC04D"), "Crete")
		V:mettre(0, 7, -2, orange, "Crete")
	end

	-- Raptor (Commun, 9 cubes) : orange sable élancé, rayures brunes, plumes bleues, griffe en faucille
	ESPECES.Raptor = function(V)
		local brun = hex("6B3418")
		local bleu = hex("3AA0FF")
		theropode(V, {
			couleur = hex("F5A04A"),
			ventre = hex("FFEBC8"),
			jambe = { x = 2, y = 2.4, z = 2, r = 1, s = 0 },
			corps = { y = 3.8, z = 2.5, rx = 2.6, ry = 1.8, rz = 3.8 },
			tete = { W = 3, yb = 3, H = 5, zf = -5, D = 5 },
			museau = { w = 2, y0 = 2, y1 = 4, L = 3 },
			queue = { z0 = 6, troncons = { { 1, 3, 5, 3 }, { 1, 4, 5, 3 }, { 0, 4, 5, 4 } } },
			bras = { x = 2, y = 2, z = -1 },
			yeux = { x0 = 1, y0 = 5, e = 3, l = 2, joue = false },
			crocs = { { 1, 4 } }, -- crocs qui pendent de la mâchoire du haut sur une gueule sombre
			dentsCote = { 1 },
			narines = false,
		})
		rayures(V, { 1, 3, 5, 8, 11, 14 }, brun, 4)
		-- plumes bleues en crête et au bout de la queue
		V:boite(0, 8, -4, 0, 8, -1, bleu, "Crete")
		V:mettre(1, 8, -1, bleu, "Crete")
		V:boite(0, 6, 14, 0, 6, 15, bleu, "Queue")
		-- griffe en faucille relevée, collée à la griffe extérieure du pied
		V:boite(3, 1, -1, 3, 2, -1, GRIFFE, "PatteArD")
	end

	-- Dilopho (Rare, 10 cubes) : vert d'eau, ventre jaune, double crête rouge, collerette magenta
	ESPECES.Dilopho = function(V)
		local c = hex("4FD9A8")
		theropode(V, {
			couleur = c,
			ventre = hex("FFE066"),
			jambe = { x = 2, y = 2.2, z = 2, r = 1.2, s = 0 },
			corps = { y = 4, z = 2.5, rx = 3, ry = 2.2, rz = 3.6, n = 4 },
			tete = { W = 4, yb = 3, H = 5, zf = -4, D = 6 },
			museau = { w = 2, y0 = 2, y1 = 4, L = 3 },
			queue = { z0 = 6, troncons = { { 1, 3, 5, 3 }, { 1, 4, 5, 3 }, { 0, 5, 5, 2 } } },
			bras = { x = 2, y = 2, z = -1 },
			yeux = { x0 = 1, y0 = 5, e = 3 },
			dents = { 2 },
			dentsCote = { 1 },
		})
		rayures(V, { 3, 5, 9, 12 }, hex("2A9C78"), 5)
		-- collerette : anneau déployé derrière la tête (magenta, 2 taches violettes 2 x 2, bord cyan)
		local zc = 2
		local cy = 5
		local taches = {}
		for _, t in ipairs({ { 4, 6 }, { 5, 2 } }) do
			for dx = 0, 1 do
				for dy = 0, 1 do
					taches[cle(t[1] + dx, t[2] + dy, 0)] = true
				end
			end
		end
		for x = 0, 7 do
			for y = 1, 10 do
				local dx, dy = x / 6.4, (y - cy) / 4.8
				local d = math.sqrt(dx * dx + dy * dy)
				if d <= 1.02 and d >= 0.5 and not V:lire(x, y, zc) then
					local col = hex("FF4FD8")
					if d >= 0.86 then
						col = hex("5CF2FF")
					elseif taches[cle(x, y, 0)] then
						col = hex("8E3BD9")
					end
					V:mettre(x, y, zc, col, "Crete")
				end
			end
		end
		-- double crête rouge sur le crâne (x = ±1), qui part de la rangée du haut, pointes jaunes
		local rouge = hex("E8323C")
		local hauts = { 8, 9, 9, 9, 8 }
		for i, yh in ipairs(hauts) do
			local z = -4 + i -- derrière la face : le reflet de l'œil reste libre
			V:boite(1, 7, z, 1, yh - 1, z, rouge, "Crete")
			V:mettre(1, yh, z, hex("FFD23F"), "Crete")
		end
	end

	-- Ptéro (Rare, 10 cubes) : volant corail et rose, long bec jaune, crête jaune vers l'arrière,
	-- grandes ailes verticales en éventail
	ESPECES.Ptero = function(V)
		local c = hex("FF7EB6")
		local cl, fo = hex("FFB3D6"), hex("D94F8F")
		local creme = hex("FFF1D6")
		local jaune = hex("FFC933")
		local orangeB = hex("FFA31A")
		-- pattes courtes orange
		local orange = hex("FFB23F")
		V:boite(1, 0, 1, 1, 2, 1, orange, "PatteArD")
		V:boite(1, 0, -1, 2, 0, 1, orange, "PatteArD")
		V:mettre(2, 0, -2, GRIFFE, "PatteArD")
		-- corps en poire et petite queue
		bloc(V, 0, 3.6, 1.5, 2.4, 2.2, 2.4, c, "Corps", 3)
		V:peindre(function(x, y, z)
			if y >= 5 then
				return cl
			elseif z <= 1 and math.abs(x) <= 1 then
				return creme
			elseif y <= 2 then
				return fo
			end
			return nil
		end, "Corps")
		V:boite(0, 3, 4, 0, 3, 6, fo, "Queue")
		-- tête en boîte arrondie
		local T = { W = 4, yb = 4, H = 5, zf = -3, D = 6 }
		tete(V, T, c, cl, fo)
		-- long bec sur 3 rangées : dessus jaune, bouche sur les côtés, mâchoire du bas orange
		V:boite(0, 5, -6, 1, 6, -4, jaune, "Tete")
		V:boite(0, 5, -9, 0, 6, -7, jaune, "Tete")
		V:boite(1, 5, -6, 1, 5, -4, BOUCHE, "Bouche")
		V:boite(0, 4, -8, 0, 4, -4, orangeB, "Tete")
		V:boite(1, 4, -6, 1, 4, -4, orangeB, "Tete")
		-- crête jaune qui file vers l'arrière, bout orange
		V:boite(0, 9, -1, 0, 9, 4, jaune, "Crete")
		V:boite(0, 8, 3, 0, 8, 5, jaune, "Crete")
		V:mettre(0, 8, 5, orangeB, "Crete")
		yeux(V, 2, 6, 3, -10, 5, { l = 2 })
		-- ailes : membrane verticale (plan XY, z = 3) qui s'élargit en éventail vers le bout,
		-- os foncé en haut, bord de fuite rose foncé en bas, griffe au pli
		local membrane = hex("FFD1E6")
		local os = hex("C23A7A")
		for x = 3, 12 do
			local yb = 4 + math.floor((x - 3) * 0.3)
			local yh = 6 + math.floor((x - 3) * 0.35)
			V:boite(x, yb + 1, 3, x, yh - 1, 3, membrane, "AileD")
			V:mettre(x, yb, 3, fo, "AileD")
			V:mettre(x, yh, 3, os, "AileD")
		end
		V:mettre(7, 7, 2, GRIFFE, "AileD")
		V.teintes = { c, cl }
	end

	-- Carno (Épique, 12 cubes) : rouge vif, cornes de taureau montantes, sourcils rouge sombre,
	-- écailles en relief sur le crâne, gueule sombre à deux crocs
	ESPECES.Carno = function(V)
		local c = hex("E8453C")
		local sombre = hex("8A1E1A")
		theropode(V, {
			couleur = c,
			ventre = hex("FFD7A8"),
			jambe = { x = 3, y = 3.2, z = 2, r = 1.4, s = 1 },
			corps = { y = 5.2, z = 2.5, rx = 3.6, ry = 2.6, rz = 4, n = 5 },
			tete = { W = 4, yb = 5, H = 5, zf = -4, D = 7 },
			museau = { w = 3, y0 = 2, y1 = 5, L = 3, rangs = 2 },
			queue = { z0 = 7, troncons = { { 2, 4, 7, 3 }, { 1, 5, 7, 3 }, { 1, 6, 7, 2 }, { 0, 7, 8, 2 } } },
			bras = { x = 3, y = 4, z = -1 },
			yeux = { x0 = 1, y0 = 6, e = 3, sourcil = sombre, sourcilBas = true },
			dents = { 2 },
			dentsCote = { 1 },
		})
		-- écailles en relief (bosses claires) sur le crâne et le long du dos
		local bosse = hex("FFB39C")
		V:mettre(1, 10, -1, bosse, "Bosse")
		V:mettre(3, 10, 0, bosse, "Bosse")
		for _, z in ipairs({ 4, 6 }) do
			local yt = sommet(V, 1, z, 20)
			if yt then
				V:mettre(1, yt + 1, z, bosse, "Bosse")
			end
		end
		-- rayures rouge sombre sur le dessus de la tête et la queue
		V:peindre(function(_, y, z)
			if y == 9 and (z == -2 or z == 0) then
				return fonce(c)
			end
			return nil
		end, "Tete")
		rayures(V, { 10, 13 }, sombre, 5, { "Queue" })
		-- cornes de taureau : sortent du côté de la tête puis montent, pointe foncée
		local corne = hex("FFF1D6")
		for _, p in ipairs({ { 5, 9 }, { 6, 9 }, { 6, 10 }, { 7, 10 } }) do
			V:boite(p[1], p[2], -3, p[1], p[2], -2, corne, "Corne")
		end
		V:boite(7, 11, -3, 7, 11, -2, hex("C9B48A"), "Corne")
	end

	-- Spino (Légendaire, 14 cubes) : bleu lagon à écailles de croco, museau fin, grande voile
	-- rouge à rayons orange et bord jaune
	ESPECES.Spino = function(V)
		local c = hex("2F8FD8")
		local fo = hex("1A5A94")
		local ventre = hex("FFF0B3")
		theropode(V, {
			couleur = c,
			fonce = fo,
			ventre = ventre,
			jambe = { x = 3, y = 3.4, z = 2, r = 1.5, s = 1 },
			corps = { y = 5.6, z = 3, rx = 3.6, ry = 2.7, rz = 4.6, n = 5 },
			tete = { W = 4, yb = 6, H = 5, zf = -4, D = 7 },
			museau = { w = 1, y0 = 4, y1 = 6, L = 6 },
			queue = { z0 = 8, troncons = { { 2, 4, 7, 3 }, { 1, 5, 7, 3 }, { 1, 6, 7, 3 }, { 0, 7, 7, 2 } } },
			bras = { x = 3, y = 5, z = -1 },
			yeux = { x0 = 1, y0 = 7, e = 3 },
			dents = {},
			dentsCote = { 2, 4 },
		})
		-- bout du museau renflé (rosette de croco), foncé, un croc blanc visible de face
		V:boite(2, 4, -10, 2, 6, -9, fo, "Tete")
		V:boite(2, 4, -10, 2, 4, -9, ventre, "Tete")
		V:mettre(2, 5, -9, BOUCHE, "Bouche")
		V:mettre(2, 5, -10, BLANC, "Dent")
		-- écailles de croco : damier 2 x 2 sur le dessus de la tête
		V:peindre(function(x, y, z)
			if y == 10 and z <= -1 and (math.floor(math.abs(x) / 2) + math.floor(z / 2)) % 2 == 0 then
				return c
			end
			return nil
		end, "Tete")
		-- voile dorsale épaisse (x = -1..1) : rouge, rayons orange, bord jaune ; amorce de pointes sur la nuque
		local orange, jaune, rouge = hex("FF7A2F"), hex("FFD23F"), hex("E8323C")
		local z0, z1 = 0, 12
		for z = z0, z1 do
			local t = (z - (z0 + z1) / 2) / ((z1 - z0) / 2 + 0.8)
			local top = 8 + math.floor(5 * math.sqrt(math.max(0, 1 - t * t)) + 0.5)
			for x = 0, 1 do
				local yb = sommet(V, x, z, 20)
				if yb and top > yb then
					for y = yb + 1, top do
						local col = (z % 2 == 0) and orange or rouge
						if y == top then
							col = jaune
						end
						V:mettre(x, y, z, col, "Crete")
					end
				end
			end
		end
		V:boite(0, 11, -3, 0, 11, -1, rouge, "Crete")
	end

	-- Rex (Légendaire, 14 cubes) : le roi : vert profond rayé, gueule énorme à crocs décalés,
	-- petits bras bien visibles, couronne d'or à gemmes
	ESPECES.Rex = function(V)
		local c = hex("2F9E44")
		local raie = hex("16502A")
		theropode(V, {
			couleur = c,
			clair = hex("4FC45E"),
			fonce = hex("1E6B2E"),
			ventre = hex("FFF0B3"),
			jambe = { x = 3, y = 3.4, z = 2, r = 1.7, s = 1 },
			corps = { y = 6, z = 3, rx = 4.2, ry = 3, rz = 4.6, n = 4 },
			tete = { W = 4, yb = 6, H = 5, zf = -5, D = 8 },
			museau = { w = 3, y0 = 3, y1 = 6, L = 3, rangs = 2 },
			queue = { z0 = 8, troncons = { { 2, 4, 8, 3 }, { 2, 5, 8, 3 }, { 1, 6, 8, 3 }, { 0, 7, 8, 2 } } },
			bras = { x = 4, y = 5, z = -3, griffe = GRIFFE },
			yeux = { x0 = 1, y0 = 7, e = 3 },
			crocs = { { 2, 5 }, { 1, 4 } }, -- 2 en haut, 2 en bas, décalés : gueule ouverte
			dentsCote = { 1 },
		})
		rayures(V, { 4, 7, 10 }, raie, 7)
		V:peindre(function(_, y, z)
			if y == 10 and z == -4 then
				return raie
			end
			return nil
		end, "Tete")
		-- couronne d'or de 2 rangées, 5 pointes, rubis et saphirs sur le devant
		anneau(V, 0, 11, -1, 3, 2, OR, "Couronne")
		anneau(V, 0, 12, -1, 3, 2, OR, "Couronne")
		V:mettre(0, 13, -3, OR, "Couronne")
		V:mettre(2, 13, -3, OR, "Couronne")
		V:mettre(3, 13, -1, OR, "Couronne")
		V:mettre(0, 11, -3, hex("FF3D5A"), "Couronne")
		V:mettre(2, 11, -3, hex("3DA5FF"), "Couronne")
	end

	-- Mosa (Mythique, 16 cubes) : monstre marin bleu abyssal dressé sur sa queue, aileron de requin,
	-- nageoires en pagaie, gueule pleine de crocs, iris et points bioluminescents Neon
	ESPECES.Mosa = function(V)
		local c = hex("1B3A8C")
		local cl, fo = hex("2D6BFF"), hex("0D1E4F")
		local cyan = hex("00E5FF")
		local pointe = hex("00D5FF")
		local crete = hex("2DB8FF")
		local ventre = hex("BFF6FF")
		-- corps en S : ventre posé, poitrine dressée ; poitrail rayé (bandes de 2 rangées)
		bloc(V, 0, 3.5, 3, 3.5, 3, 4.5, c, "Corps", 4)
		bloc(V, 0, 7.5, 0, 3.2, 3, 3, c, "Corps", 4)
		V:peindre(function(x, y, z)
			if z <= 1 and math.abs(x) <= 2 then
				return (y % 4 < 2) and ventre or hex("9FE8FF")
			elseif y >= 6 then
				return cl
			elseif y <= 1 then
				return fo
			end
			return nil
		end, "Corps")
		-- queue qui ondule au sol, nageoire en croissant
		local zq = queue(V, 8, { { 2, 1, 4, 3 }, { 1, 1, 3, 3 }, { 1, 1, 2, 2 } }, c, cl, fo)
		V:boite(0, 0, zq + 1, 0, 5, zq + 1, fo, "Queue")
		V:boite(0, 3, zq + 2, 0, 6, zq + 2, fo, "Queue")
		V:mettre(0, 6, zq + 1, neon(cyan), "Queue")
		-- tête allongée
		local T = { W = 4, yb = 9, H = 5, zf = -5, D = 8 }
		tete(V, T, c, cl, fo)
		local z0 = museau(V, { w = 3, y0 = 7, y1 = 9, L = 5 }, T.zf, c,
			{ machoire = ventre, dessus = cl, dentsCote = { 1, 2, 3, 4 }, narines = false })
		-- mâchoire du bas avancée d'un cube, crocs en quinconce sur les deux mâchoires
		V:boite(0, 7, z0 - 1, 2, 7, z0 - 1, ventre, "Tete")
		for _, x in ipairs({ 0, 2 }) do
			V:mettre(x, 8, z0, BLANC, "Dent")
		end
		V:mettre(1, 9, z0, BLANC, "Dent")
		yeux(V, 1, 10, 3, -13, 4, { iris = neon(cyan), joue = false }) -- pas de joues : les crocs du haut sont là
		-- nageoires avant en pagaie verticale (visibles de face), pointe Neon
		for _, r in ipairs({ { 7, 4, 5 }, { 6, 4, 6 }, { 5, 4, 7 }, { 4, 5, 8 }, { 3, 6, 8 } }) do
			V:boite(r[2], r[1], -1, r[3], r[1], -1, cl, "PatteAvD")
		end
		V:mettre(8, 3, -1, neon(pointe), "PatteAvD")
		-- nageoires arrière accrochées au ventre
		V:boite(3, 1, 4, 4, 1, 5, fo, "PatteArD")
		V:boite(4, 0, 4, 6, 0, 6, fo, "PatteArD")
		-- aileron de requin sur le crâne (3 d'épaisseur), pointe Neon
		V:boite(0, 14, -2, 1, 14, 1, crete, "Crete")
		V:boite(0, 15, 0, 0, 15, 0, crete, "Crete")
		V:mettre(0, 15, 1, neon(pointe), "Crete")
		-- crête dorsale : pointes de 2 cubes, seul le cube du sommet en Neon
		for _, z in ipairs({ 3, 5 }) do
			local yt = sommet(V, 0, z, 20)
			if yt then
				V:mettre(0, yt + 1, z, crete, "Crete")
				V:mettre(0, yt + 2, z, neon(pointe), "Crete")
			end
		end
		-- points bioluminescents Neon sur le dos et la tête
		semer(V, function(x, y, z, v)
			return x >= 0 and y >= 6 and (v.g == "Corps" or v.g == "Tete") and (v.c.couleur == c or v.c.couleur == cl)
				and (math.abs(x) * 5 + y * 11 + z * 7) % 14 == 0
		end, { neon(cyan) }, 4)
		V.teintes = { c, cl }
	end

	-- Giga (Divin, 17 cubes) : colosse nacré à accessoires d'or : mâchoire, rayures, épines, griffes
	-- et plaques d'armure dorées, grandes ailes d'ange en V, auréole verticale qui encadre la tête
	ESPECES.Giga = function(V)
		local nacre = hex("F3EDFF") -- nacre légèrement lavande : le blanc des yeux reste lisible
		local orN = hex("FFB300")
		theropode(V, {
			couleur = nacre,
			clair = BLANC,
			fonce = hex("E8DDF5"),
			ventre = hex("FFEFC2"),
			machoire = OR,
			jambe = { x = 3, y = 3.8, z = 2, r = 1.8, s = 1, griffes = OR },
			corps = { y = 6.4, z = 3, rx = 4.6, ry = 3.2, rz = 5, n = 5 },
			tete = { W = 4, yb = 7, H = 6, zf = -5, D = 8 },
			museau = { w = 3, y0 = 4, y1 = 7, L = 4, rangs = 2 },
			queue = { z0 = 8, troncons = { { 2, 4, 8, 3 }, { 2, 5, 8, 3 }, { 1, 6, 8, 3 }, { 0, 7, 9, 3 } } },
			bras = { x = 4, y = 5, z = -1, griffe = OR },
			yeux = { x0 = 1, y0 = 8, e = 3, iris = neon(orN), blanc = hex("FFE08A") },
			dents = { 2 },
			dentsCote = { 1 },
			narines = false,
		})
		rayures(V, { 4, 8 }, OR, 8)
		-- plaques d'armure dorées sur les tempes
		V:boite(4, 10, -4, 5, 11, -3, OR, "Armure")
		-- épines d'or sur le crâne
		for _, z in ipairs({ -3, -1, 1 }) do
			local yt = sommet(V, 0, z, 30)
			if yt then
				V:mettre(0, yt + 1, z, OR, "Crete")
			end
		end
		-- ailes d'ange : partent de l'épaule et montent en V au-dessus de la tête, plumes d'or au bord
		for x = 5, 12 do
			local base = 8 + math.floor(math.floor((x - 5) / 2) * 1.7) -- colonnes par paires (moins de parts)
			local haut = base + 3
			local col = (x == 12) and OR or BLANC
			V:boite(x, base, 5, x, haut - 1, 5, col, "AileD")
			V:mettre(x, haut, 5, OR, "AileD")
		end
		-- auréole verticale derrière la tête (plan XY, z = 3) : cercle de rayon 5 centré en (0, 11)
		-- tracé en barres (haut, coins, côtés) qui encadre le visage de face ; coins en Neon or saturé
		V:boite(0, 16, 3, 2, 16, 3, OR, "Aureole")
		V:mettre(3, 15, 3, neon(orN), "Aureole")
		V:mettre(4, 14, 3, OR, "Aureole")
		V:boite(5, 9, 3, 5, 13, 3, OR, "Aureole")
	end

	-- Cosmosaure (Secret, 18 cubes) : cosmique : indigo lumineux, grosse tête ronde, ventre nébuleuse,
	-- grand anneau de Saturne autour de la taille, diadème de cristaux Neon, étoiles Neon, iris Neon
	ESPECES.Cosmosaure = function(V)
		local c = hex("4B36B8")
		local rose, cyanN = hex("FF4FD8"), hex("00D9FF")
		theropode(V, {
			couleur = c,
			clair = hex("7A5CFF"),
			fonce = hex("2E2280"),
			ventre = hex("D14BFF"),
			jambe = { x = 4, y = 4, z = 2, r = 1.9, s = 1, avant = 4, hp = 1, griffes = neon(rose) },
			corps = { y = 7, z = 3, rx = 4.2, ry = 3.4, rz = 5.2 },
			tete = { W = 5, yb = 8, H = 7, zf = -5, D = 8, n = 4.5 },
			museau = { w = 3, y0 = 6, y1 = 8, L = 3 },
			queue = { z0 = 8, troncons = { { 2, 5, 9, 3 }, { 2, 6, 9, 3 }, { 1, 7, 9, 3 }, { 0, 8, 10, 3 } } },
			yeux = { x0 = 1, y0 = 10, e = 3, iris = neon(rose), couleurJoue = hex("FFA3E0") },
			dents = { 2 },
			narines = false,
		})
		-- anneau de Saturne : ellipse plate à y = 5, sous le menton, autour de la taille
		local cz = 3
		for x = 0, 9 do
			for z = cz - 10, cz + 10 do
				local ext = (x / 8.5) ^ 4 + ((z - cz) / 10) ^ 4
				local int = (x / 6.5) ^ 4 + ((z - cz) / 8) ^ 4
				if ext <= 1 and int > 1 and not V:lire(x, 5, z) then
					V:mettre(x, 5, z, hex("FFE58A"), "Anneau")
				end
			end
		end
		-- diadème de cristaux sur le crâne : socle violet, cristaux Neon rose (centre) et cyan
		for _, k in ipairs({ { 0, 2, hex("FF2FD0") }, { 2, 1, hex("00C8FF") } }) do
			local yt = sommet(V, k[1], -3, 30)
			if yt then
				V:mettre(k[1], yt + 1, -3, hex("6A4FE0"), "Crete")
				V:boite(k[1], yt + 2, -3, k[1], yt + 1 + k[2], -3, neon(k[3]), "Crete")
			end
		end
		-- étoiles Neon cyan peintes sur le front, aux coins
		face(V, 4, 13, neon(cyanN), -12, 4)
		-- cristaux Neon le long du dos (vus de profil et de 3/4)
		for _, k in ipairs({ { 5, 2, rose }, { 11, 1, cyanN } }) do
			local yt = sommet(V, 0, k[1], 30)
			if yt then
				V:boite(0, yt + 1, k[1], 0, yt + k[2], k[1], neon(k[3]), "Crete")
			end
		end
		return {
			-- étoiles Neon semées (asymétriques) sur les flancs et la queue
			apres = function(W)
				semer(W, function(x, y, z, v)
					return (v.g == "Corps" or v.g == "Queue") and math.abs(x) >= 2 and y >= 6 and z >= 1
						and (v.c.couleur == c or v.c.couleur == hex("7A5CFF"))
				end, { neon(BLANC), neon(cyanN) }, 5)
			end,
		}
	end

	-- ===== fabrication =====
	local ORDRE = { "Compy", "Raptor", "Dilopho", "Ptero", "Carno", "Spino", "Rex", "Mosa", "Giga", "Cosmosaure" }
	local AURAS = {
		Mosa = hex("00E5FF"),
		Giga = OR,
		Cosmosaure = hex("B35CFF"),
	}

	local function fabriquer(espece, recette)
		local infos = E.especes[espece]
		local ancien = dossierDinos:FindFirstChild(espece)
		if ancien then
			ancien:Destroy()
		end
		local ok, err = pcall(function()
			local V = Voxel.nouveau()
			local options = recette(V) or {}
			V:symetriser()
			if options.apres then
				options.apres(V)
			end
			local taches = 0
			if V.teintes then
				taches = grain(V, V.teintes, options.grain)
			end
			local modele = V:construire(dossierDinos, { nom = espece, origine = CFrame.new(), budget = BUDGET })
			modele:SetAttribute("Espece", espece)
			modele:SetAttribute("Grain", taches) -- paires de cubes nuancés (texture « petits cubes »)
			if infos and infos.famille then
				modele:SetAttribute("Famille", infos.famille)
			end
			if AURAS[espece] then
				aura(modele, AURAS[espece])
			end
		end)
		if not ok then
			local reste = dossierDinos:FindFirstChild(espece)
			if reste then
				reste:Destroy()
			end
			warn("[Dino] gabarit voxel « " .. espece .. " » non construit : " .. tostring(err))
		end
	end

	local faites = {}
	for _, espece in ipairs(ORDRE) do
		if E.especes[espece] and ESPECES[espece] then
			fabriquer(espece, ESPECES[espece])
			faites[espece] = true
		end
	end

	-- une espèce carnivore ajoutée à l'équilibrage sans recette : raptor voxel teinté par sa rareté
	for espece, infos in pairs(E.especes) do
		if infos.famille == "Carnivore" and not faites[espece] then
			local teinte = (Charte.raretes and Charte.raretes[infos.rarete]) or Charte.terre
			fabriquer(espece, function(V)
				theropode(V, {
					couleur = teinte,
					ventre = Charte.creme,
					jambe = { x = 2, y = 2.4, z = 2, r = 1, s = 0 },
					corps = { y = 3.8, z = 2.5, rx = 2.8, ry = 1.8, rz = 3.8 },
					tete = { W = 4, yb = 3, H = 5, zf = -5, D = 5 },
					museau = { w = 2, y0 = 2, y1 = 4, L = 2 },
					queue = { z0 = 6, troncons = { { 1, 3, 5, 3 }, { 1, 4, 5, 3 }, { 0, 4, 5, 3 } } },
					bras = { x = 2, y = 2, z = -1 },
					yeux = { x0 = 1, y0 = 5, e = 3 },
					dents = { 2 },
				})
			end)
		end
	end
end

return M
