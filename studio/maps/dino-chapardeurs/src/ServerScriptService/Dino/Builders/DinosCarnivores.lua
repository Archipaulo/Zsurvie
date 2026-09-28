-- Constructeur DinosCarnivores : gabarits des 10 espèces de la famille « Carnivore »
-- (carnivores, volant et marin), rangés dans ServerStorage.Dino.Dinos.
-- Version 5 « vrais animaux en petits cubes » (STYLE.md §5 corrigé) : chaque dino est modélisé en voxels
-- de 1 stud avec ctx.Voxel, comme un animal entier qu'on reconnaît de profil : pattes épaisses bien
-- détachées du corps, corps horizontal, cou, tête ≈ 30 % de la hauteur, longue queue effilée.
-- Petits yeux sur les côtés de la tête (pupille noire + un cube blanc de reflet), bouche fine d'un cube
-- de haut avec dents blanches SEULEMENT sur les flancs (face avant du museau couleur peau : pas de
-- bandeau « masque » de face), 2 narines sur le dessus du bout du museau ; dessus plus clair, flancs du bas plus foncés, ventre contrasté ;
-- motifs nets (rayures, taches) et accessoires qui grandissent avec la rareté (crêtes, cornes, voile,
-- couronne, ailes, auréole, anneau) ; Neon à partir de Mythique seulement.
-- Texture « petits cubes » des références : tramage de cubes un peu plus clairs ou plus foncés (graine
-- fixe), aussi dense que le budget de 220 parts le permet (réglé par dichotomie).
-- Visage rangé dans ses propres groupes (Pupille, Reflet, Iris, Sourcil, Bouche, Dent, Narine) : les
-- mutations (Tapis.appliquerMutation) ne le recolorent pas.
-- Repère : origine au sol sous le centre du dino, regard vers -Z ; on modèle le côté droit (x >= 0),
-- la gauche est recopiée par V:symetriser() (groupes « …D » -> « …G »).
local M = {}

local BUDGET = 220 -- parts maximum par gabarit (vérifié par Voxel:construire)
local MARGE = 3 -- parts gardées en réserve sous le budget pendant le tramage
local TRAME_MAX = 0.5 -- part maximale des cubes visibles de peau qui changent de nuance

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
	local NOIR = hex("16141F")
	local GRIFFE = hex("FFF4DC")
	local OR = hex("FFC933")

	local function clair(c, t)
		return c:Lerp(BLANC, t or 0.25)
	end
	local function fonce(c, t)
		return c:Lerp(Color3.new(0, 0, 0), t or 0.28)
	end
	local function neon(c)
		return { couleur = c, materiau = NEON }
	end
	-- trois teintes (base, dessus, dessous) et un ventre
	local function teintes(c, ventre, cl, fo)
		return { couleur = c, clair = cl or clair(c), fonce = fo or fonce(c), ventre = ventre }
	end

	-- petit hachage stable dans [0, 1[ (tramage, étoiles, taches)
	local function hache(x, y, z)
		local s = math.sin(x * 12.9898 + y * 78.233 + z * 37.719) * 43758.5453
		return s - math.floor(s)
	end

	-- ===== outils de modelage =====

	-- teinte d'un cube selon sa hauteur relative dans sa section (rel de -1 en bas à 1 en haut), son
	-- écart au plan médian (ax de 0 au centre à 1 sur le flanc) ; avant : face avant (poitrail, gorge)
	local function teinteSection(T, rel, ax, avant)
		if avant and T.ventre and rel <= 0.3 and ax <= 0.7 then
			return T.ventre
		elseif rel > 0.6 then
			return T.clair
		elseif rel < -0.55 then
			if T.ventre and ax <= 0.62 then
				return T.ventre
			end
			return T.fonce
		end
		return T.couleur
	end

	-- tronçons extrudés le long de z (corps, cou, queue) : { { z0, z1, y0, y1, X [, biseau] }, ... } ;
	-- pavé de demi-largeur X (de -X à X après symétrie), lignes y0..y1, arêtes longues biseautées.
	-- Des tronçons constants sur plusieurs z se fusionnent en peu de parts (budget).
	-- o.poitrail : la face avant du premier tronçon prend la couleur du ventre
	local function troncons(V, liste, T, groupe, o)
		o = o or {}
		for i, s in ipairs(liste) do
			local z0, z1, y0, y1, X = s[1], s[2], s[3], s[4], s[5]
			local cy, ry = (y0 + y1) / 2, math.max((y1 - y0) / 2, 0.5)
			local k = s[6] or ((X >= 3 and y1 - y0 >= 5) and 2 or ((X >= 1 and y1 - y0 >= 2) and 1 or 0))
			for z = z0, z1 do
				local avant = o.poitrail and i == 1 and z == z0
				for x = 0, X do
					for y = math.max(0, y0), y1 do
						local bord = math.min(y - y0, y1 - y)
						if (X - x) + bord >= k then
							V:mettre(x, y, z, teinteSection(T, (y - cy) / ry, x / math.max(X, 1), avant), groupe)
						end
					end
				end
			end
		end
	end

	-- pavé aux arêtes extérieures (côté x1) biseautées, teinté par rangée (cuisses, épaules)
	local function pave(V, x0, y0, z0, x1, y1, z1, T, groupe)
		local cy, ry = (y0 + y1) / 2, math.max((y1 - y0) / 2, 0.5)
		for x = x0, x1 do
			for y = y0, y1 do
				for z = z0, z1 do
					if not (x == x1 and (y == y0 or y == y1 or z == z0 or z == z1)) then
						V:mettre(x, y, z, teinteSection(T, (y - cy) / ry, 1), groupe)
					end
				end
			end
		end
	end

	-- patte arrière (côté droit) : cuisse en jambon, tibia e x e, pied à trois orteils griffus
	-- J = { x (colonne intérieure du tibia), z (avant du tibia), e (épaisseur), yt (haut du tibia),
	--       cuisse = { x0, y0, z0, x1, y1, z1 }, av (pied devant le tibia), griffe, tibia, pied (couleurs) }
	local function patteAr(V, J, T, groupe)
		groupe = groupe or "PatteArD"
		local e = J.e or 2
		local cu = J.cuisse
		if cu then
			pave(V, cu[1], cu[2], cu[3], cu[4], cu[5], cu[6], T, groupe)
		end
		local tibia = J.tibia or T.fonce
		V:boite(J.x, 1, J.z, J.x + e - 1, J.yt, J.z + e - 1, tibia, groupe)
		local av = J.av or 2
		local zf = J.z - av
		local pied = J.pied or tibia
		V:boite(J.x, 0, zf, J.x + e, 0, J.z + e - 1, pied, groupe)
		local griffe = J.griffe or GRIFFE
		local milieu = J.x + math.floor(e / 2)
		V:mettre(J.x, 0, zf - 1, griffe, groupe)
		V:mettre(J.x + e, 0, zf - 1, griffe, groupe)
		V:mettre(milieu, 0, zf - 1, pied, groupe)
		V:mettre(milieu, 0, zf - 2, griffe, groupe)
		if J.faucille then
			-- griffe en faucille relevée (raptor) sur l'orteil intérieur
			V:boite(J.x, 1, zf, J.x, 2, zf, griffe, groupe)
		end
	end

	-- petit bras (côté droit) : épaule, avant-bras tendu vers l'avant, griffe
	-- B = { x, y (épaule), z, l (avant-bras), e (épaisseur en x), griffe }
	local function bras(V, B, T)
		local g = "PatteAvD"
		local e = B.e or 1
		local l = B.l or 1
		V:boite(B.x, B.y - 1, B.z, B.x + e - 1, B.y, B.z, T.couleur, g)
		V:boite(B.x, B.y - 1, B.z - l, B.x + e - 1, B.y - 1, B.z - 1, T.couleur, g)
		V:mettre(B.x, B.y - 2, B.z - l, B.griffe or GRIFFE, g)
	end

	-- tête : crâne en bloc biseauté + museau devant ; bouche fine d'un cube de haut (dents blanches en
	-- alternance), petit œil sur le flanc du crâne (pupille noire + reflet blanc), arcade, narines.
	-- H = { zN (nuque), zc (début du museau), zb (bout du museau), yb (bas), yh (haut du crâne),
	--       ys (haut du museau), W, w (demi-largeurs crâne / museau), mb (bouche sous le crâne),
	--       oeil = { y, z, l, h } (au moins deux rangées au-dessus du bas : jamais collé à la bouche),
	--       pointe (cubes de bout de museau affinés) }
	-- o : machoire, museau, museauClair, machoireMuseau (couleurs), dents (false : pas de dents), bouche,
	--     iris, arcade (couleur ou false), narines (false), narine (couleur)
	local function tete(V, H, T, o)
		o = o or {}
		local mach = o.machoire or T.ventre or T.fonce
		local mus = o.museau or T.couleur
		local musCl = o.museauClair or (o.museau and clair(o.museau, 0.2)) or T.clair
		local musBas = o.machoireMuseau or mach
		for x = 0, H.W do
			for y = H.yb, H.yh do
				for z = H.zc, H.zN do
					local col = T.couleur
					if y == H.yh then
						col = T.clair
					elseif y == H.yb then
						col = mach
					end
					V:mettre(x, y, z, col, "Tete")
				end
			end
		end
		for x = 0, H.w do
			for y = H.yb, H.ys do
				for z = H.zb, H.zc - 1 do
					local col = mus
					if y == H.ys then
						col = musCl
					elseif y == H.yb then
						col = musBas
					end
					V:mettre(x, y, z, col, "Tete")
				end
			end
		end
		-- biseaux : arête du dessus, arrière du crâne, coin avant du museau
		for z = H.zc, H.zN do
			V:mettre(H.W, H.yh, z, nil)
		end
		for x = 0, H.W do
			V:mettre(x, H.yh, H.zN, nil)
		end
		for y = H.yb, H.yh do
			V:mettre(H.W, y, H.zN, nil)
		end
		V:mettre(H.w, H.ys, H.zb, nil)
		if H.w >= 2 then
			V:mettre(H.w, H.yb, H.zb, nil)
		end
		-- bout du museau affiné
		local pointe = H.pointe or 0
		for z = H.zb, H.zb + pointe - 1 do
			for y = H.yb, H.ys do
				V:mettre(H.w, y, z, nil)
			end
		end
		local zbw = H.zb + pointe -- premier z où le museau a toute sa largeur
		-- bouche : fente fine d'un cube de haut SEULEMENT sur les flancs (jamais sur la face avant z = zb,
		-- qui garde la couleur du museau : sinon, de face, une bande sombre refait le « masque » de la v1) ;
		-- couleur à peine plus sombre que la mâchoire ; une dent blanche au coin avant du museau, puis
		-- une dent tous les 2 cubes le long du flanc.
		-- o.bouche : couleur de la fente, ou false (pas de bouche : la recette la pose elle-même)
		if o.bouche ~= false then
			local yB = H.yb + 1
			local coulB = o.bouche or fonce(musBas, 0.45)
			local avecDents = o.dents ~= false
			-- museau étroit (w = 1) : pas de croc au coin avant (2 cubes blancs sur 3 feraient une
			-- bande blanche de face) ; la première dent passe sur le flanc
			local coin = avecDents and pointe == 0 and H.w >= 2
			if coin and V:lire(H.w, yB, H.zb) then
				V:mettre(H.w, yB, H.zb, BLANC, "Dent")
			end
			local parite = coin and 0 or 1
			for z = H.zb + 1, H.zc + (H.mb or 1) - 1 do
				local x = (z >= H.zc) and H.W or ((z < zbw) and H.w - 1 or H.w)
				if x >= 1 and V:lire(x, yB, z) then
					local dent = avecDents and z < H.zc and (z - H.zb) % 2 == parite
					V:mettre(x, yB, z, dent and BLANC or coulB, dent and "Dent" or "Bouche")
				end
			end
		end
		-- œil sur le flanc du crâne : pupille noire, reflet blanc en haut vers l'avant
		local O = H.oeil
		local l, h = O.l or 1, O.h or 2
		for dz = 0, l - 1 do
			for dy = 0, h - 1 do
				local col, g = NOIR, "Pupille"
				if dy == h - 1 and dz == 0 then
					col, g = BLANC, "Reflet"
				elseif o.iris and dy == 0 and dz == l - 1 and h >= 2 then
					col, g = o.iris, "Iris"
				end
				V:mettre(H.W, O.y + dy, O.z + dz, col, g)
			end
		end
		-- arcade au-dessus de l'œil (air de prédateur)
		if o.arcade ~= false then
			for dz = 0, l - 1 do
				V:mettre(H.W, O.y + h, O.z + dz, o.arcade or T.fonce, "Sourcil")
			end
		end
		-- narines : sur le dessus du museau, un cube en retrait du bout (vues d'en haut, jamais prises
		-- pour des yeux quand on regarde le dino de face)
		if o.narines ~= false then
			local nc = o.narine or fonce(musCl, 0.35)
			local nx = math.max(1, H.w - 1)
			if H.w == 1 then
				nx = 1
			end
			V:mettre(nx, H.ys, zbw + 1, nc, "Narine")
		end
	end

	-- théropode entier : corps, cou, queue, pattes, bras, tête
	-- P = { T (teintes), corps, cou, queue (tronçons), jambe, bras, tete, opt (options de tête), Tjambe }
	local function theropode(V, P)
		local T = P.T
		troncons(V, P.corps, T, "Corps", { poitrail = true })
		if P.cou then
			troncons(V, P.cou, T, "Corps", { poitrail = true })
		end
		troncons(V, P.queue, { couleur = T.couleur, clair = T.clair, fonce = T.fonce }, "Queue")
		patteAr(V, P.jambe, P.Tjambe or T)
		if P.bras then
			bras(V, P.bras, T)
		end
		tete(V, P.tete, T, P.opt)
		V.peaux = { T.couleur, T.clair, T.fonce, T.ventre }
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

	-- plus grand x occupé de la rangée (y, z) (flanc droit)
	local function flanc(V, y, z)
		for x = 14, 0, -1 do
			if V:lire(x, y, z) then
				return x
			end
		end
		return nil
	end

	-- rayures transversales : repeint les cubes du dessus et des flancs (teinte de base ou claire) ;
	-- dos = true : seulement les cubes clairs du dessus (bandes sur le dos, bien moins de parts)
	local function rayures(V, zs, col, T, groupes, dos)
		local set = {}
		for _, z in ipairs(zs) do
			set[z] = true
		end
		for _, g in ipairs(groupes or { "Corps", "Queue" }) do
			V:peindre(function(_, y, z, v)
				if set[z] and (v.c.couleur == T.clair or (not dos and v.c.couleur == T.couleur)) then
					return col
				end
				return nil
			end, g)
		end
	end

	-- tache 2 x 2 peinte sur le flanc droit autour de (y, z)
	local function tache(V, y, z, col)
		for dy = 0, 1 do
			for dz = 0, 1 do
				local x = flanc(V, y + dy, z + dz)
				if x and x > 0 then
					local v = V:lire(x, y + dy, z + dz)
					if v.g == "Corps" or v.g == "Queue" then
						V:mettre(x, y + dy, z + dz, col, v.g)
					end
				end
			end
		end
	end

	-- vrai si le voxel v a au moins une face à l'air libre
	local function visible(V, v)
		return not (V:lire(v.x + 1, v.y, v.z) and V:lire(v.x - 1, v.y, v.z) and V:lire(v.x, v.y + 1, v.z)
			and V:lire(v.x, v.y - 1, v.z) and V:lire(v.x, v.y, v.z + 1) and V:lire(v.x, v.y, v.z - 1))
	end

	-- sème des cubes (étoiles, points lumineux) sur la surface : test(x, y, z, v) choisit les candidats
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

	-- tramage « petits cubes » : des cubes visibles de peau (dessus, flancs, avant) prennent une nuance
	-- un peu plus claire ou plus foncée (graine fixe). Les cubes qui coûtent le moins de parts passent
	-- d'abord (bout de rangée, bord d'une zone de couleur : ils ne coupent qu'une part en deux), mêlés
	-- au hasard pour garder un grain régulier ; le nombre de cubes nuancés est réglé par dichotomie pour
	-- tenir dans le budget. Renvoie la part des cubes candidats nuancés.
	local function tramer(V, peaux, o)
		o = o or {}
		local force = o.force or 1
		local nuances = {}
		for _, t in ipairs(peaux) do
			if t then
				table.insert(nuances, { t, t:Lerp(BLANC, o.clair or 0.17 * force), t:Lerp(Color3.new(0, 0, 0), 0.16 * force) })
			end
		end
		local function pareil(v, x, y, z)
			local w = V:lire(x, y, z)
			return w and w.g == v.g and w.c.materiau == nil and w.c.couleur == v.c.couleur
		end
		local cands = {}
		for _, v in pairs(V.grille) do
			local vu = not V:lire(v.x, v.y + 1, v.z) or not V:lire(v.x + 1, v.y, v.z) or not V:lire(v.x - 1, v.y, v.z)
				or not V:lire(v.x, v.y, v.z - 1)
			if v.c.materiau == nil and vu then
				for _, nu in ipairs(nuances) do
					if v.c.couleur == nu[1] then
						-- coût estimé : voisins de même couleur qui seraient séparés (rangée en x, puis en y)
						local cout = 0
						if pareil(v, v.x + 1, v.y, v.z) then cout = cout + 1 end
						if pareil(v, v.x - 1, v.y, v.z) then cout = cout + 1 end
						if pareil(v, v.x, v.y + 1, v.z) then cout = cout + 0.5 end
						if pareil(v, v.x, v.y - 1, v.z) then cout = cout + 0.5 end
						local h = hache(v.x * 1.7 + 0.3, v.y, v.z)
						table.insert(cands, { v = v, rang = h + cout * (o.econome or 0.9), sens = hache(v.z, v.x, v.y) < 0.5, nu = nu })
						break
					end
				end
			end
		end
		table.sort(cands, function(a, b)
			return a.rang < b.rang
		end)
		local function appliquer(n)
			for i, k in ipairs(cands) do
				local col = k.nu[1]
				if i <= n then
					col = k.sens and k.nu[2] or k.nu[3]
				end
				k.v.c = { couleur = col, materiau = nil }
			end
		end
		local limite = BUDGET - MARGE
		local nmax = math.floor(#cands * (o.max or TRAME_MAX))
		appliquer(nmax)
		if compter(V) <= limite then
			return nmax / math.max(1, #cands)
		end
		local bas, haut = 0, nmax
		while haut - bas > 1 do
			local mil = math.floor((bas + haut) / 2)
			appliquer(mil)
			if compter(V) <= limite then
				bas = mil
			else
				haut = mil
			end
		end
		appliquer(bas)
		return bas / math.max(1, #cands)
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
		l.Range = portee or 16
		l.Brightness = 1.2
		l.Shadows = false
		l.Parent = corps
	end

	-- ===== les espèces =====
	-- chaque recette modèle le côté droit ; elle peut renvoyer { apres = fonction(V) } (détails
	-- asymétriques posés après la symétrie) et { trame = { force, max } }.
	-- Tronçons : { z0, z1, y0, y1, X } ; l'avant est vers -Z, le sol à y = 0.
	local ESPECES = {}

	-- Compy (Commun, 10 cubes) : petit chasseur vert pomme au long cou et à la longue queue relevée,
	-- ventre crème, taches jaunes, crête orange en pics
	ESPECES.Compy = function(V)
		local T = teintes(hex("7ED957"), hex("FFF1B8"), hex("A8EC84"), hex("4FA83A"))
		theropode(V, {
			T = T,
			corps = { { -2, -2, 4, 6, 1 }, { -1, 3, 3, 7, 2 }, { 4, 4, 4, 6, 1 } },
			cou = { { -5, -3, 5, 8, 1 } },
			queue = { { 5, 7, 4, 6, 1 }, { 8, 10, 5, 6, 0 }, { 11, 13, 6, 7, 0 } },
			jambe = { x = 2, z = 1, e = 2, yt = 2, cuisse = { 2, 2, 0, 3, 5, 2 } },
			bras = { x = 2, y = 5, z = -2, l = 1 },
			tete = { zN = -5, zc = -8, zb = -10, yb = 6, yh = 9, ys = 8, W = 2, w = 1, mb = 1, oeil = { y = 8, z = -7, l = 2, h = 1 } },
			opt = { arcade = false },
		})
		local jaune = hex("FFD93D")
		tache(V, 5, -1, jaune)
		tache(V, 4, 2, jaune)
		V:mettre(1, 6, 6, jaune, "Queue")
		-- crête orange en pics sur la tête et la nuque
		local orange = hex("FF9F1C")
		for _, p in ipairs({ { -7, 1 }, { -6, 1 }, { -4, 1 } }) do
			local yt = sommet(V, 0, p[1], 20)
			if yt then
				V:boite(0, yt + 1, p[1], 0, yt + p[2], p[1], orange, "Crete")
			end
		end
	end

	-- Raptor (Commun, 11 cubes) : chasseur orange sable élancé, long museau, rayures brunes, plumes
	-- bleues (crête, bras, bout de queue), griffe en faucille
	ESPECES.Raptor = function(V)
		local T = teintes(hex("F5A04A"), hex("FFEBC8"), hex("FFC27A"), hex("C06F25"))
		local brun = hex("7A3A18")
		local bleu = hex("3AA0FF")
		theropode(V, {
			T = T,
			corps = { { -3, -3, 4, 6, 1 }, { -2, 3, 3, 7, 2 }, { 4, 5, 4, 7, 1 } },
			cou = { { -6, -4, 5, 8, 1 } },
			queue = { { 6, 9, 5, 7, 1 }, { 10, 13, 6, 7, 1 }, { 14, 17, 6, 7, 0 } },
			jambe = { x = 2, z = 1, e = 2, yt = 2, cuisse = { 2, 2, 0, 3, 5, 2 }, faucille = true },
			bras = { x = 2, y = 5, z = -3, l = 2 },
			tete = { zN = -5, zc = -8, zb = -12, yb = 6, yh = 9, ys = 8, W = 2, w = 1, mb = 1, oeil = { y = 8, z = -7, l = 2, h = 1 } },
			opt = { arcade = brun },
		})
		rayures(V, { -1, 2, 7, 11 }, brun, T)
		-- plumes bleues : crête sur le crâne, plumes aux bras et au bout de la queue
		V:boite(0, 9, -7, 0, 9, -4, bleu, "Crete")
		V:boite(0, 10, -6, 0, 10, -5, bleu, "Crete")
		V:mettre(0, 10, -4, hex("7CC4FF"), "Crete")
		V:mettre(2, 3, -3, bleu, "PatteAvD")
		V:boite(0, 8, 16, 0, 8, 18, bleu, "Queue")
		V:mettre(0, 7, 18, bleu, "Queue")
	end

	-- Dilopho (Rare, 12 cubes) : vert d'eau, ventre jaune, double crête rouge sur le crâne,
	-- collerette magenta déployée autour du cou
	ESPECES.Dilopho = function(V)
		local T = teintes(hex("4FD9A8"), hex("FFE066"), hex("8CF0CB"), hex("2E9C77"))
		theropode(V, {
			T = T,
			corps = { { -3, -3, 4, 7, 2 }, { -2, 3, 3, 8, 3 }, { 4, 5, 4, 8, 2 } },
			cou = { { -7, -4, 6, 9, 1 } },
			queue = { { 6, 8, 5, 8, 2 }, { 9, 12, 6, 8, 1 }, { 13, 16, 6, 7, 0 } },
			jambe = { x = 2, z = 1, e = 2, yt = 2, cuisse = { 3, 2, 0, 4, 6, 2 } },
			bras = { x = 3, y = 6, z = -3, l = 1 },
			tete = { zN = -6, zc = -9, zb = -12, yb = 7, yh = 10, ys = 9, W = 2, w = 1, mb = 1, oeil = { y = 9, z = -8, l = 2, h = 1 } },
		})
		rayures(V, { 0, 3, 8, 11 }, hex("2A8C6C"), T)
		-- collerette déployée autour du cou (plan z = -5) : magenta, taches violettes, bord cyan
		local zc, cy = -5, 7.5
		for x = 0, 5 do
			for y = 3, 12 do
				local dx, dy = x / 4.4, (y - cy) / 3.8
				local d = math.sqrt(dx * dx + dy * dy)
				if d <= 1.02 and d >= 0.5 and not V:lire(x, y, zc) then
					local col = hex("FF4FD8")
					if d >= 0.8 then
						col = hex("5CF2FF")
					elseif (x + y) % 3 == 0 then
						col = hex("9B3BE0")
					end
					V:mettre(x, y, zc, col, "Crete")
				end
			end
		end
		-- double crête rouge sur le crâne (x = ±1), pointes jaunes
		local rouge = hex("E8323C")
		for i, yh in ipairs({ 10, 11, 11, 10 }) do
			local z = -11 + i
			if yh - 1 >= 10 then
				V:boite(1, 10, z, 1, yh - 1, z, rouge, "Crete")
			end
			V:mettre(1, yh, z, hex("FFD23F"), "Crete")
		end
	end

	-- Ptéro (Rare, 12 cubes) : volant rose corail dressé sur ses pattes, long bec jaune, crête jaune
	-- vers l'arrière, grandes ailes de chauve-souris levées en V
	ESPECES.Ptero = function(V)
		local T = teintes(hex("FF7EB6"), hex("FFF1C9"), hex("FFB0D4"), hex("D94F8F"))
		local jaune, orange = hex("FFC933"), hex("FFA31A")
		-- torse penché vers l'avant (pas un pilier), cou bas : la tête avance devant les ailes
		troncons(V, { { -3, -2, 4, 7, 1 }, { -2, 2, 3, 7, 2 }, { 3, 3, 3, 6, 1 } }, T, "Corps", { poitrail = true })
		troncons(V, { { -5, -3, 5, 8, 1 } }, T, "Corps", { poitrail = true })
		troncons(V, { { 4, 6, 4, 5, 0 } }, T, "Queue")
		patteAr(V, { x = 1, z = 0, e = 2, yt = 1, cuisse = { 2, 1, -1, 3, 3, 1 }, tibia = orange }, T)
		-- tête étroite (3 de large) et long bec fermé qui s'affine à 1 cube sur les 3 derniers z ;
		-- pas de bouche de face : la commissure est posée à la main sur les flancs
		tete(V, { zN = -4, zc = -7, zb = -13, yb = 8, yh = 11, ys = 10, W = 1, w = 1, mb = 1, pointe = 3,
			oeil = { y = 10, z = -6, l = 2, h = 1 } }, T,
			{ museau = jaune, machoireMuseau = orange, dents = false, bouche = false, arcade = false })
		V:mettre(0, 10, -13, nil) -- pointe du bec effilée
		for z = -10, -7 do
			if V:lire(1, 8, z) then
				V:mettre(1, 8, z, fonce(orange), "Bouche")
			end
		end
		-- crête jaune qui file vers l'arrière depuis le crâne, bout orange
		V:boite(0, 11, -4, 0, 11, 0, jaune, "Crete")
		V:mettre(0, 11, 1, orange, "Crete")
		-- ailes en triangle plein, reculées en V (lisibles de profil) : bras osseux en haut, membrane
		-- rose pâle, nervures claires tous les 3 x, bord de fuite foncé doublé en z + 1, griffe au poignet
		local membrane, os, bord = hex("FFD1E6"), hex("B8326F"), hex("E0679F")
		local yb10 = 3 + math.floor((10 - 3) * 0.25)
		for x = 3, 13 do
			local yo = 7 + math.floor((x - 3) * 0.4 + 0.5)
			local yb = 3 + math.floor((x - 3) * 0.25)
			if x >= 11 then
				yb = yb10 + math.floor((yo - yb10) * (x - 10) / 3 + 0.5)
			end
			local z = math.floor((x - 3) / 4)
			if yb < yo then
				V:mettre(x, yb, z, bord, "AileD")
				V:mettre(x, yb, z + 1, bord, "AileD")
				if yb + 1 <= yo - 1 then
					V:boite(x, yb + 1, z, x, yo - 1, z, (x % 3 == 0) and T.clair or membrane, "AileD")
				end
			end
			V:mettre(x, yo, z, os, "AileD")
		end
		V:mettre(8, 9, 0, GRIFFE, "AileD")
		V:mettre(14, 11, 2, os, "AileD")
		V.peaux = { T.couleur, T.clair, T.fonce, T.ventre }
	end

	-- Carno (Épique, 14 cubes) : rouge vif trapu, tête courte et haute, cornes de taureau, bras
	-- minuscules, écailles en relief sur le dos
	ESPECES.Carno = function(V)
		local T = teintes(hex("E8453C"), hex("FFD7A8"), hex("FF7A66"), hex("A82A24"))
		local sombre = hex("7A1A16")
		theropode(V, {
			T = T,
			corps = { { -5, -5, 6, 9, 2 }, { -4, 3, 5, 10, 3 }, { 4, 5, 6, 10, 2 } },
			cou = { { -7, -6, 7, 10, 2 } },
			queue = { { 6, 8, 6, 9, 2 }, { 9, 12, 7, 9, 1 }, { 13, 16, 7, 8, 0 } },
			jambe = { x = 2, z = 1, e = 2, yt = 4, cuisse = { 3, 3, 0, 4, 7, 3 } },
			bras = { x = 3, y = 8, z = -5, l = 1 },
			tete = { zN = -6, zc = -9, zb = -12, yb = 8, yh = 12, ys = 11, W = 3, w = 2, mb = 2, oeil = { y = 10, z = -8, l = 2, h = 2 } },
			opt = { arcade = sombre },
		})
		rayures(V, { 10, 13 }, sombre, T, { "Queue" })
		-- écailles en relief le long du dos
		local bosse = hex("FFB39C")
		for _, z in ipairs({ -3, 0, 3 }) do
			local yt = sommet(V, 1, z, 20)
			if yt then
				V:mettre(1, yt + 1, z, bosse, "Bosse")
			end
		end
		-- cornes de taureau : sortent au-dessus des yeux puis montent, pointe foncée
		local corne = hex("FFF1D6")
		V:boite(3, 12, -8, 4, 12, -8, corne, "Corne")
		V:mettre(4, 13, -8, hex("C9B48A"), "Corne")
	end

	-- Spino (Légendaire, 16 cubes) : bleu lagon, long museau de crocodile, grande voile dorsale rouge
	-- à rayons orange et bord jaune, queue en pagaie
	ESPECES.Spino = function(V)
		local T = teintes(hex("2F8FD8"), hex("FFF0B3"), hex("6CB8F0"), hex("1A5A94"))
		theropode(V, {
			T = T,
			corps = { { -6, -6, 6, 10, 2 }, { -5, 4, 5, 11, 3 }, { 5, 7, 6, 10, 2 } },
			cou = { { -9, -7, 8, 11, 2 } },
			queue = { { 8, 11, 6, 10, 1 }, { 12, 15, 6, 9, 1 }, { 16, 19, 7, 9, 0 } },
			jambe = { x = 2, z = 1, e = 2, yt = 4, cuisse = { 3, 3, 0, 4, 7, 3 } },
			bras = { x = 3, y = 8, z = -6, l = 2 },
			tete = { zN = -8, zc = -11, zb = -17, yb = 9, yh = 13, ys = 11, W = 2, w = 1, mb = 2, oeil = { y = 11, z = -10, l = 2, h = 2 } },
		})
		-- bout du museau renflé (rosette de crocodile)
		V:boite(2, 9, -17, 2, 11, -16, T.couleur, "Tete")
		V:mettre(2, 9, -17, T.ventre, "Tete")
		V:mettre(2, 9, -16, T.ventre, "Tete")
		V:mettre(2, 10, -17, BLANC, "Dent")
		V:mettre(2, 10, -16, fonce(T.ventre, 0.45), "Bouche")
		-- voile dorsale (x = 0) : rouge, rayons orange, bord jaune
		local orange, jaune, rouge = hex("FF7A2F"), hex("FFD23F"), hex("E8323C")
		local z0, z1 = -5, 7
		for z = z0, z1 do
			local t = (z - (z0 + z1) / 2) / ((z1 - z0) / 2 + 0.8)
			local top = 11 + math.floor(4 * math.sqrt(math.max(0, 1 - t * t)) + 0.5)
			local yb = sommet(V, 0, z, 20)
			if yb and top > yb then
				for y = yb + 1, top do
					local col = (z % 3 == 0) and orange or rouge
					if y == top then
						col = jaune
					end
					V:mettre(0, y, z, col, "Crete")
				end
			end
		end
	end

	-- Rex (Légendaire, 16 cubes) : le roi : vert profond rayé, grosse tête à dents, petits bras,
	-- couronne d'or à rubis
	ESPECES.Rex = function(V)
		local T = teintes(hex("2F9E44"), hex("FFF0B3"), hex("5CC46A"), hex("1E6B2E"))
		local raie = hex("16502A")
		theropode(V, {
			T = T,
			corps = { { -6, -6, 6, 10, 3 }, { -5, 3, 5, 11, 4 }, { 4, 6, 6, 11, 3 } },
			cou = { { -8, -7, 8, 12, 2 } },
			queue = { { 7, 9, 6, 10, 2 }, { 10, 13, 7, 10, 1 }, { 14, 16, 7, 9, 1 }, { 17, 19, 8, 9, 0 } },
			jambe = { x = 3, z = 1, e = 2, yt = 4, cuisse = { 3, 3, -1, 5, 8, 3 } },
			bras = { x = 4, y = 8, z = -6, l = 1 },
			tete = { zN = -7, zc = -11, zb = -14, yb = 9, yh = 13, ys = 12, W = 3, w = 2, mb = 2, oeil = { y = 11, z = -10, l = 2, h = 2 } },
			opt = { arcade = raie },
		})
		rayures(V, { -3, 1, 5, 10, 14 }, raie, T, nil, true)
		-- couronne d'or : anneau sur le crâne, 3 pointes, rubis devant
		local cz, rz = -9, 2
		V:boite(0, 13, cz - rz, 2, 13, cz - rz, OR, "Couronne")
		V:boite(0, 13, cz + rz, 2, 13, cz + rz, OR, "Couronne")
		V:boite(2, 13, cz - rz + 1, 2, 13, cz + rz - 1, OR, "Couronne")
		V:mettre(0, 14, cz - rz, OR, "Couronne")
		V:mettre(2, 14, cz - rz, OR, "Couronne")
		V:mettre(2, 14, cz + rz, OR, "Couronne")
		V:mettre(0, 13, cz - rz, hex("FF3D5A"), "Couronne")
	end

	-- Mosa (Mythique, 17 cubes) : monstre marin bleu abyssal dressé hors de l'eau : queue posée au sol
	-- terminée par une nageoire en croissant, poitrail levé, 4 nageoires en pagaie, gueule de crocodile
	-- pleine de crocs, aileron dorsal et points bioluminescents Neon
	ESPECES.Mosa = function(V)
		local T = teintes(hex("1F4FB8"), hex("BFF6FF"), hex("3D7BFF"), hex("122C6E"))
		local cyan = hex("00E5FF")
		troncons(V, { { -7, -6, 9, 14, 2 }, { -5, -3, 6, 12, 3 }, { -2, 0, 3, 10, 3 }, { 1, 4, 0, 7, 3 } },
			T, "Corps", { poitrail = true })
		troncons(V, { { 5, 8, 0, 5, 2 }, { 9, 12, 0, 4, 1 }, { 13, 17, 1, 3, 1 } },
			{ couleur = T.couleur, clair = T.clair, fonce = T.fonce }, "Queue")
		-- nageoire caudale en croissant, pointe Neon
		V:boite(0, 0, 18, 0, 5, 18, T.fonce, "Queue")
		V:boite(0, 4, 19, 0, 7, 19, T.fonce, "Queue")
		V:boite(0, 6, 20, 0, 8, 20, T.fonce, "Queue")
		V:mettre(0, 9, 20, neon(cyan), "Queue")
		V:boite(0, 0, 19, 0, 1, 20, T.fonce, "Queue")
		tete(V, { zN = -6, zc = -9, zb = -15, yb = 11, yh = 15, ys = 13, W = 3, w = 2, mb = 2,
			oeil = { y = 13, z = -8, l = 2, h = 2 } }, T, { iris = neon(cyan), arcade = T.fonce })
		-- nageoires avant en pagaie, écartées vers le bas
		local pag, bordP = T.clair, hex("0D1E4F")
		V:boite(4, 6, -4, 4, 7, -3, T.couleur, "PatteAvD")
		V:boite(5, 3, -5, 6, 5, -2, pag, "PatteAvD")
		V:boite(7, 1, -5, 7, 3, -3, pag, "PatteAvD")
		V:mettre(8, 1, -4, neon(cyan), "PatteAvD")
		V:boite(5, 3, -2, 6, 3, -2, bordP, "PatteAvD")
		-- nageoires arrière posées au sol
		V:boite(3, 0, 5, 4, 1, 6, T.couleur, "PatteArD")
		V:boite(5, 0, 6, 6, 0, 8, pag, "PatteArD")
		-- aileron dorsal sur les épaules, pointe Neon
		local aileron = hex("2DB8FF")
		for i, z in ipairs({ -3, -2, -1, 0 }) do
			local yt = sommet(V, 0, z, 20)
			if yt then
				local h = ({ 1, 2, 3, 2 })[i]
				V:boite(0, yt + 1, z, 0, yt + h, z, aileron, "Crete")
			end
		end
		local ya = sommet(V, 0, -1, 25)
		if ya then
			V:mettre(0, ya + 1, -1, neon(cyan), "Crete")
		end
		-- petites pointes Neon le long du dos et de la queue
		for _, z in ipairs({ 3, 7, 11 }) do
			local yt = sommet(V, 0, z, 20)
			if yt then
				V:mettre(0, yt + 1, z, neon(cyan), "Crete")
			end
		end
		V.peaux = { T.couleur, T.clair, T.fonce, T.ventre }
		return {
			apres = function(W)
				-- points bioluminescents Neon sur les flancs
				semer(W, function(x, y, z, v)
					return (v.g == "Corps" or v.g == "Queue") and math.abs(x) >= 2 and y >= 3 and v.c.couleur == T.couleur
				end, { neon(cyan) }, 5)
			end,
		}
	end

	-- Giga (Divin, 19 cubes) : colosse nacré à accessoires d'or : rayures d'or, mâchoire et griffes
	-- d'or, grandes ailes d'ange levées, auréole d'or flottant au-dessus de la tête, iris Neon
	ESPECES.Giga = function(V)
		-- lavande nacrée franche (pas de gris pâle : il se délave sur le ciel), dessus presque blanc,
		-- flancs bas violets, ventre doré : vrai contraste dessus / dessous
		local T = teintes(hex("C9B8F0"), hex("FFE7A8"), hex("F2EAFF"), hex("7F6BC2"))
		local plume = hex("FFE7A8")
		local orN = hex("FFB300")
		theropode(V, {
			T = T,
			corps = { { -7, -7, 7, 12, 3 }, { -6, 4, 6, 14, 4 }, { 5, 7, 7, 13, 3 } },
			cou = { { -10, -8, 9, 14, 2 } },
			queue = { { 8, 10, 7, 12, 2 }, { 11, 14, 8, 11, 1 }, { 15, 18, 8, 10, 1 }, { 19, 21, 9, 9, 0 } },
			jambe = { x = 3, z = 1, e = 3, yt = 5, cuisse = { 3, 4, -1, 5, 10, 4 }, griffe = OR },
			bras = { x = 4, y = 10, z = -7, l = 2, griffe = OR },
			tete = { zN = -9, zc = -13, zb = -17, yb = 11, yh = 16, ys = 14, W = 3, w = 2, mb = 2, oeil = { y = 13, z = -12, l = 2, h = 2 } },
			opt = { machoire = OR, iris = neon(orN), arcade = OR },
		})
		rayures(V, { -3, -2, 2, 3, 12, 13 }, OR, T, nil, true)
		-- ailes d'ange : partent des épaules, montent en V et reculent (z grandit avec x : lisibles de
		-- profil) ; plumes blanches, 2 cubes dorés au bas des plumes, 2e couche de plumes sur les
		-- colonnes paires, liseré d'or sur le bord haut
		for x = 5, 14 do
			local paire = math.floor((x - 5) / 2) -- colonnes par paires : moins de parts
			local yb = 11 + paire
			local yh = 13 + math.floor(paire * 1.3 + 0.5)
			if x % 2 == 0 then
				yb = yb - 1 -- plumes en dents de scie
			end
			local z = 1 + math.floor((x - 5) / 3)
			local couches = (x % 2 == 0) and { z, z + 1 } or { z }
			for _, zz in ipairs(couches) do
				for y = yb, yh - 1 do
					V:mettre(x, y, zz, (y <= yb + 1) and plume or BLANC, "AileD")
				end
			end
			V:mettre(x, yh, z, OR, "AileD")
		end
		-- auréole d'or au-dessus de la tête (anneau horizontal), coins Neon
		local ya, cz = 18, -12
		V:boite(0, ya, cz - 3, 1, ya, cz - 3, OR, "Aureole")
		V:boite(0, ya, cz + 3, 1, ya, cz + 3, OR, "Aureole")
		V:boite(3, ya, cz - 1, 3, ya, cz + 1, OR, "Aureole")
		V:mettre(2, ya, cz - 2, neon(orN), "Aureole")
		V:mettre(2, ya, cz + 2, neon(orN), "Aureole")
		-- épines d'or sur la nuque
		for _, z in ipairs({ -8, -6 }) do
			local yt = sommet(V, 0, z, 30)
			if yt then
				V:mettre(0, yt + 1, z, OR, "Crete")
			end
		end
		return { trame = { max = 0.3 } } -- tramage plafonné : sur la nacre, trop de nuances font du bruit gris
	end

	-- Cosmosaure (Secret, 20 cubes) : théropode cosmique indigo, ventre nébuleuse rose, grand anneau de
	-- Saturne rayé autour de la taille, cristaux Neon sur le dos, étoiles Neon, iris Neon
	ESPECES.Cosmosaure = function(V)
		local T = teintes(hex("4B36B8"), hex("D14BFF"), hex("7A5CFF"), hex("2E2280"))
		local rose, cyanN = hex("FF4FD8"), hex("00D9FF")
		theropode(V, {
			T = T,
			corps = { { -7, -7, 8, 13, 3 }, { -6, 4, 7, 15, 4 }, { 5, 7, 8, 14, 3 } },
			-- cou redressé et tête haute : silhouette de Secret, distincte du Giga (cou bas, tête en avant)
			cou = { { -10, -8, 12, 17, 2 } },
			queue = { { 8, 10, 8, 13, 2 }, { 11, 14, 9, 12, 1 }, { 15, 18, 9, 11, 1 }, { 19, 21, 10, 10, 0 } },
			jambe = { x = 3, z = 1, e = 3, yt = 6, cuisse = { 3, 5, -1, 5, 11, 4 }, griffe = neon(rose) },
			bras = { x = 4, y = 11, z = -7, l = 2, griffe = neon(cyanN) },
			tete = { zN = -9, zc = -13, zb = -17, yb = 14, yh = 19, ys = 17, W = 3, w = 2, mb = 2, oeil = { y = 16, z = -12, l = 2, h = 2 } },
			opt = { iris = neon(rose), arcade = hex("2E2280") },
		})
		-- anneau de Saturne large et évasé autour de la taille (référence « Saturnitas ») : octogone de
		-- 3 cubes de large sur 2 couches, bandes bleu ciel / jaune / bleu ciel, quelques reflets blancs ;
		-- incliné (plus bas devant, plus haut derrière) pour qu'on en voie le dessus depuis l'avant ;
		-- l'intérieur reste vide (au moins 1 cube d'air entre l'anneau et le flanc)
		local ciel, paille = hex("8FD8FF"), hex("FFE58A")
		local cz, a, b, c = 0, 11, 12, 3
		for x = 0, a do
			for z = cz - b, cz + b do
				local dx, dz = a - x, b - math.abs(z - cz)
				local d = math.min(dx, dz, dx + dz - c)
				if d >= 0 and d <= 2 then
					local ya = 11 + math.floor((z - cz) / 5)
					for y = ya, ya + 1 do
						if not V:lire(x, y, z) then
							local col = (d == 1) and paille or ciel
							-- reflets blancs sur les coins en escalier de la bande extérieure (cubes déjà
							-- isolés : presque aucune part de plus)
							if y == ya + 1 and d == 0 and dx > 0 and dz > 0 and x % 2 == 0 then
								col = BLANC
							end
							V:mettre(x, y, z, col, "Anneau")
						end
					end
				end
			end
		end
		-- cornes de cristal Neon inclinées vers l'arrière
		for i, p in ipairs({ { 20, -11 }, { 20, -10 }, { 21, -9 } }) do
			V:mettre(2, p[1], p[2], neon(i == 3 and rose or cyanN), "Corne")
		end
		-- bout de queue en étoile : croix de 5 cubes Neon
		local etoile = neon(hex("FFE58A"))
		for _, p in ipairs({ { 0, 10 }, { 1, 10 }, { 0, 9 }, { 0, 11 } }) do
			V:boite(p[1], p[2], 21, p[1], p[2], 22, etoile, "Queue")
		end
		-- cristaux Neon le long du dos (socle violet)
		for _, k in ipairs({ { -5, 2, rose }, { -1, 3, cyanN }, { 3, 2, rose } }) do
			local yt = sommet(V, 0, k[1], 30)
			if yt then
				V:mettre(0, yt + 1, k[1], hex("6A4FE0"), "Crete")
				V:boite(0, yt + 2, k[1], 0, yt + 1 + k[2], k[1], neon(k[3]), "Crete")
			end
		end
		return {
			apres = function(W)
				-- étoiles Neon semées sur le dos, les flancs et la queue
				semer(W, function(x, y, z, v)
					return (v.g == "Corps" or v.g == "Queue") and math.abs(x) >= 2 and y >= 8
						and (v.c.couleur == T.couleur or v.c.couleur == T.fonce)
				end, { neon(BLANC), neon(cyanN), neon(hex("FFE58A")) }, 5)
			end,
			trame = { clair = 0.42 }, -- cubes clairs très pâles : ciel étoilé
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
			local trame = 0
			if V.peaux then
				trame = tramer(V, V.peaux, options.trame)
			end
			local modele = V:construire(dossierDinos, { nom = espece, origine = CFrame.new(), budget = BUDGET })
			modele:SetAttribute("Espece", espece)
			modele:SetAttribute("Trame", math.floor(trame * 100 + 0.5)) -- % de cubes de peau nuancés
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
			local teinte = (Charte.raretes and Charte.raretes[infos.rarete]) or Charte.terre or hex("C08A5B")
			fabriquer(espece, function(V)
				theropode(V, {
					T = teintes(teinte, Charte.creme or hex("FFF4DC")),
					corps = { { -3, -3, 5, 7, 1 }, { -2, 3, 4, 8, 2 }, { 4, 5, 5, 8, 1 } },
					cou = { { -6, -4, 6, 9, 1 } },
					queue = { { 6, 9, 6, 8, 1 }, { 10, 13, 7, 8, 1 }, { 14, 17, 7, 8, 0 } },
					jambe = { x = 2, z = 1, e = 2, yt = 3, cuisse = { 2, 3, 0, 3, 6, 2 } },
					bras = { x = 2, y = 6, z = -3, l = 1 },
					tete = { zN = -5, zc = -8, zb = -11, yb = 7, yh = 10, ys = 9, W = 2, w = 1, mb = 1, oeil = { y = 9, z = -7, l = 2, h = 1 } },
				})
			end)
		end
	end
end

return M
