-- Constructeur DinosHerbivores : gabarits des espèces de la famille « Herbivore »,
-- rangés dans ServerStorage.Dino.Dinos (clonés ensuite par Systemes/Tapis).
-- Version 2 « petits cubes » (STYLE.md §5 corrigé) : de VRAIS ANIMAUX en voxels de 1 stud
-- (ctx.Voxel, faces « Studs »), reconnaissables de profil à leur silhouette : corps bien visible,
-- pattes épaisses (2 x 2 cubes au moins) détachées du corps, queue longue, cou, crêtes, cornes.
-- Tête ≈ 30 % de la hauteur ; PETITS yeux sur les côtés du museau (1 x 2 : pupille noire + un cube
-- blanc de reflet ; 2 x 2 seulement pour une tête d'au moins 6 cubes), bouche fine, narines.
-- Couleurs : dessus plus clair, dessous plus foncé, ventre contrasté, motifs nets, puis « tramage »
-- (cubes en 3 nuances plus claires ou plus foncées tirés au hasard, graine fixe) posé tant que
-- le gabarit tient dans le budget de parts (220).
-- Tailles selon la rareté (Commun 9-11 cubes de haut … Divin 17-19), Neon dès Mythique.
-- Repère : origine au sol sous le centre du dino, regard vers -Z, x > 0 = côté droit (D) ;
-- on modèle le côté droit puis V:symetriser() recopie à gauche (« …D » -> « …G »).
-- Groupes : Corps (PrimaryPart), Cou, Tete, Queue, PatteAvG/D, PatteArG/D, Massue (animations) ;
-- Oeil, Pupille, Reflet, Narine, Bouche (visage, jamais recoloré par les mutations) ;
-- Crete, Corne, Tache, Cristal, Aureole (accessoires).
local M = {}

local BUDGET = 220 -- parts maximum par gabarit (vérifié par Voxel:construire)
local MARGE = 3 -- parts gardées en réserve sous le budget quand on pose le tramage

-- groupes jamais tramés (visage lisible, cristaux et auréole nets)
local SANS_TRAME = { Oeil = true, Pupille = true, Reflet = true, Narine = true, Bouche = true, Cristal = true, Aureole = true }

-- ===== boîte à outils commune =====
local function kit(ctx)
	local C = ctx.Charte
	local K = {}
	local function hex(h)
		return Color3.fromRGB(tonumber(string.sub(h, 1, 2), 16), tonumber(string.sub(h, 3, 4), 16), tonumber(string.sub(h, 5, 6), 16))
	end
	K.hex = (C and C.hex) or hex
	K.encre = K.hex("1E1B33")
	K.blanc = K.hex("FFFFFF")
	K.creme = K.hex("FFF4DC")
	K.levre = K.hex("4A2436")
	K.narine = K.hex("3A2233")
	local BLANC = Color3.new(1, 1, 1)

	local function eclaircir(c, a)
		return c:Lerp(BLANC, a)
	end
	local function assombrir(c, a)
		return Color3.new(c.R * a, c.G * a, c.B * a)
	end
	K.eclaircir = eclaircir
	K.assombrir = assombrir

	-- teintes d'une couleur : b (base), c (dessus, plus clair), f (dessous, plus foncé), ff (détails)
	function K.pal(h, hOmbre)
		local b = K.hex(h)
		local f = hOmbre and K.hex(hOmbre) or assombrir(b, 0.8)
		return { b = b, c = eclaircir(b, 0.22), f = f, ff = assombrir(f, 0.78) }
	end

	-- petit hachage stable (tramage, motifs) : nombre dans [0, 1[
	function K.hache(x, y, z, graine)
		local s = math.sin(x * 12.9898 + y * 78.233 + z * 37.719 + (graine or 0) * 5.137) * 43758.5453
		return s - math.floor(s)
	end

	-- pavé aux arêtes adoucies (r = 1 : arêtes retirées)
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

	-- chemin de cubes reliés par leurs faces entre des points successifs { x, y, z }
	function K.chemin(V, points, couleurDe, g)
		local i = 0
		local function poser(x, y, z)
			i = i + 1
			V:mettre(x, y, z, couleurDe(i), g)
		end
		local x, y, z = points[1][1], points[1][2], points[1][3]
		poser(x, y, z)
		for k = 2, #points do
			local p = points[k]
			while x ~= p[1] or y ~= p[2] or z ~= p[3] do
				if y ~= p[2] then
					y = y + (p[2] > y and 1 or -1)
				elseif z ~= p[3] then
					z = z + (p[3] > z and 1 or -1)
				else
					x = x + (p[1] > x and 1 or -1)
				end
				poser(x, y, z)
			end
		end
	end

	-- patte épaisse : pilier l x p de y = 0 à y = h (le haut se cache dans le corps posé ensuite),
	-- ongles crème devant le pied
	function K.patte(V, o)
		V:boite(o.x, 0, o.z, o.x + o.l - 1, o.h, o.z + o.p - 1, o.c, o.g)
		if o.pied then
			V:boite(o.x, 0, o.z, o.x + o.l - 1, 0, o.z + o.p - 1, o.pied, o.g)
		end
		if o.ongle then
			local pas = math.max(1, o.l - 1)
			for x = o.x, o.x + o.l - 1, pas do
				V:mettre(x, 0, o.z - 1, o.ongle, o.g)
			end
		end
	end

	-- cube le plus à l'extérieur du côté s (1 : droite, -1 : gauche) en (y, z), dans le groupe g
	function K.bordX(V, s, y, z, g)
		for i = 16, 0, -1 do
			local v = V:lire(s * i, y, z)
			if v and (not g or v.g == g) then
				return s * i
			end
		end
		return nil
	end

	-- premier cube rencontré en venant de -Z en (x, y), jusqu'à zmax
	function K.facade(V, x, y, zmax)
		for z = -40, zmax or 40 do
			if V:lire(x, y, z) then
				return z
			end
		end
		return nil
	end

	-- premier cube rencontré en venant du haut en (x, z)
	function K.dessus(V, x, z)
		for y = 40, 0, -1 do
			if V:lire(x, y, z) then
				return y
			end
		end
		return nil
	end

	-- PETITS yeux sur les CÔTÉS de la tête ; (y, z) = pupille (coin bas-avant de l'œil) ;
	-- hTete = hauteur de la tête en cubes. Tête de moins de 6 cubes : œil 1 x 2 vertical, pupille
	-- noire en (bord, y, z) + reflet blanc en (bord, y + 1, z), rien en z + 1 (comme la référence :
	-- 1 noir + 1 blanc). Tête d'au moins 6 cubes : 2 x 2 = 2 noirs (bas-avant, haut-arrière) + reflet
	-- blanc en haut devant, le cube bas-arrière garde la peau. Jamais sur la façade : un cube n'est
	-- peint que s'il a un voisin devant lui (z - 1). Le haut de l'œil (y + 1) doit être une rangée
	-- pleine de la tête (pas la rangée du crâne aux arêtes retirées par K.tete).
	function K.yeux(V, y, z, hTete)
		local cases = { { 0, 0, K.encre, "Pupille" }, { 1, 0, K.blanc, "Reflet" } }
		if (hTete or 4) >= 6 then
			table.insert(cases, { 1, 1, K.encre, "Pupille" })
		end
		for _, s in ipairs({ 1, -1 }) do
			for _, c in ipairs(cases) do
				local yy, zz = y + c[1], z + c[2]
				local x = K.bordX(V, s, yy, zz, "Tete")
				if x and x ~= 0 and V:lire(x, yy, zz - 1) then
					V:mettre(x, yy, zz, c[3], c[4])
				end
			end
		end
	end

	-- bouche fine (1 cube de haut) : ligne sur les côtés du museau de z1 à z2 (et sur la façade
	-- sur une demi-largeur largeurFace si on la donne)
	function K.bouche(V, y, z1, z2, couleur, largeurFace)
		couleur = couleur or K.levre
		for _, s in ipairs({ 1, -1 }) do
			for z = z1, z2 do
				local x = K.bordX(V, s, y, z)
				if x then V:mettre(x, y, z, couleur, "Bouche") end
			end
		end
		if largeurFace then
			for x = -largeurFace, largeurFace do
				local z = K.facade(V, x, y)
				if z then V:mettre(x, y, z, couleur, "Bouche") end
			end
		end
	end

	-- pavé symétrique (demi-largeur hw) de y1 à y2 et de z1 à z2, arêtes adoucies si r = 1
	function K.bloc(V, hw, y1, y2, z1, z2, c, g, r)
		K.pave(V, -hw, y1, z1, hw, y2, z2, c, g, r)
	end

	-- tête : pavé symétrique dont on retire les arêtes du dessus (crâne arrondi, côtés plats pour les yeux)
	function K.tete(V, hw, y1, y2, z1, z2, c)
		V:boite(-hw, y1, z1, hw, y2, z2, c, "Tete")
		for x = -hw, hw do
			V:mettre(x, y2, z1, nil)
			V:mettre(x, y2, z2, nil)
		end
		for z = z1, z2 do
			V:mettre(-hw, y2, z, nil)
			V:mettre(hw, y2, z, nil)
		end
	end

	-- queue (ou cou) en escalier : liste de tronçons { hw, y1, y2, z1, z2 }
	function K.troncons(V, liste, c, g)
		for _, t in ipairs(liste) do
			V:boite(-t[1], t[2], t[4], t[1], t[3], t[5], c, g)
		end
	end

	-- narines : deux cubes sur la façade du museau, en x = ±ecart, à la hauteur y, d'une nuance
	-- plus sombre de la peau (discrètes : elles ne doivent pas passer pour des yeux)
	function K.narines(V, y, ecart)
		for _, s in ipairs({ 1, -1 }) do
			local z = K.facade(V, s * ecart, y)
			if z then
				local v = V:lire(s * ecart, y, z)
				V:mettre(s * ecart, y, z, assombrir(v.c.couleur, 0.62), "Narine")
			end
		end
	end

	-- volume par la couleur : cubes de teinte p.b sans voisin au-dessus -> clair,
	-- sans voisin en dessous (hors sol) -> foncé ; ventre(x, y, z) -> couleur du ventre (ou nil)
	function K.teinter(V, p, groupes, ventre)
		local liste = {}
		for _, v in pairs(V.grille) do
			if v.c.couleur == p.b and v.c.materiau == nil and (not groupes or groupes[v.g]) then
				local cv = ventre and ventre(v.x, v.y, v.z, v)
				if cv then
					table.insert(liste, { v, cv })
				elseif not V:lire(v.x, v.y + 1, v.z) then
					table.insert(liste, { v, p.c })
				elseif v.y > 0 and not V:lire(v.x, v.y - 1, v.z) then
					table.insert(liste, { v, p.f })
				end
			end
		end
		for _, e in ipairs(liste) do
			e[1].c = { couleur = e[2], materiau = nil }
		end
	end

	-- repeint les cubes des teintes d'une palette (b, c, f) quand test(x, y, z, v) est vrai
	function K.repeindre(V, p, couleur, test, groupes, groupeNouveau)
		for _, v in pairs(V.grille) do
			local c = v.c.couleur
			if (c == p.b or c == p.c or c == p.f) and v.c.materiau == nil and (not groupes or groupes[v.g]) and test(v.x, v.y, v.z, v) then
				v.c = { couleur = couleur, materiau = nil }
				if groupeNouveau then v.g = groupeNouveau end
			end
		end
	end

	-- origine sous le centre du dino : recentre la grille en z (x est déjà symétrique)
	function K.recentrer(V)
		local zmin, zmax = math.huge, -math.huge
		local liste = {}
		for _, v in pairs(V.grille) do
			zmin = math.min(zmin, v.z)
			zmax = math.max(zmax, v.z)
			table.insert(liste, v)
		end
		if #liste == 0 then return end
		local dz = -math.floor((zmin + zmax) / 2 + 0.5)
		if dz == 0 then return end
		V.grille = {}
		V.nombre = 0
		for _, v in ipairs(liste) do
			V:mettre(v.x, v.y, v.z + dz, { couleur = v.c.couleur, materiau = v.c.materiau }, v.g)
		end
	end

	-- compteur de parts : même maillage glouton que Voxel:construire, groupe par groupe
	local function cle(x, y, z)
		return x .. "," .. y .. "," .. z
	end
	function K.compteur(V)
		local grille = V.grille
		local interieur = {}
		local parGroupe = {}
		for _, v in pairs(grille) do
			interieur[v] = (grille[cle(v.x + 1, v.y, v.z)] and grille[cle(v.x - 1, v.y, v.z)]
				and grille[cle(v.x, v.y + 1, v.z)] and grille[cle(v.x, v.y - 1, v.z)]
				and grille[cle(v.x, v.y, v.z + 1)] and grille[cle(v.x, v.y, v.z - 1)]) and true or false
			parGroupe[v.g] = parGroupe[v.g] or {}
			table.insert(parGroupe[v.g], v)
		end
		for _, liste in pairs(parGroupe) do
			table.sort(liste, function(a, b)
				local ia, ib = interieur[a], interieur[b]
				if ia ~= ib then return ib end
				if a.z ~= b.z then return a.z < b.z end
				if a.y ~= b.y then return a.y < b.y end
				return a.x < b.x
			end)
		end
		local function compter(g)
			local liste = parGroupe[g]
			if not liste then return 0 end
			local pris = {}
			local n = 0
			local function libre(x, y, z, c)
				local v = grille[cle(x, y, z)]
				if not v or v.g ~= g or pris[v] then return false end
				return (v.c.couleur == c.couleur and v.c.materiau == c.materiau) or interieur[v]
			end
			for _, graine in ipairs(liste) do
				if not pris[graine] then
					local c = graine.c
					local x0, y0, z0 = graine.x, graine.y, graine.z
					local x1 = x0
					while libre(x1 + 1, y0, z0, c) do x1 = x1 + 1 end
					local y1 = y0
					local ok = true
					while ok do
						for x = x0, x1 do
							if not libre(x, y1 + 1, z0, c) then ok = false break end
						end
						if ok then y1 = y1 + 1 end
					end
					local z1 = z0
					ok = true
					while ok do
						for x = x0, x1 do
							for y = y0, y1 do
								if not libre(x, y, z1 + 1, c) then ok = false break end
							end
							if not ok then break end
						end
						if ok then z1 = z1 + 1 end
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
			return n
		end
		return compter, parGroupe, interieur
	end

	-- tramage : des cubes visibles, tirés au hasard (graine fixe), prennent une nuance un peu plus
	-- claire ou plus foncée de leur couleur ; chaque lot n'est gardé que si le gabarit reste sous
	-- le budget de parts. Renvoie le nombre de parts prévu.
	function K.tramer(V, budget, graine)
		local compter, parGroupe, interieur = K.compteur(V)
		local parG, total = {}, 0
		local noms = {}
		for g in pairs(parGroupe) do
			parG[g] = compter(g)
			total = total + parG[g]
			table.insert(noms, g)
		end
		table.sort(noms)
		local limite = budget - MARGE
		-- candidats groupe par groupe (les plus grandes surfaces d'abord)
		local candidats = {}
		for _, g in ipairs(noms) do
			if not SANS_TRAME[g] then
				local liste = {}
				for _, v in ipairs(parGroupe[g]) do
					if not interieur[v] and v.c.materiau == nil then
						table.insert(liste, v)
					end
				end
				table.sort(liste, function(a, b)
					return K.hache(a.x, a.y, a.z, graine) < K.hache(b.x, b.y, b.z, graine)
				end)
				table.insert(candidats, { g = g, liste = liste })
			end
		end
		table.sort(candidats, function(a, b)
			if #a.liste ~= #b.liste then return #a.liste > #b.liste end
			return a.g < b.g
		end)
		local essais = 0
		local trames = {} -- cubes déjà nuancés (jamais deux fois)
		local posesDe = {}
		-- deux passes : d'abord les lots bon marché (au plus 0,7 part par cube nuancé), sur tous les
		-- groupes, puis on complète avec le reste du budget
		for passe = 1, 2 do
		for _, cand in ipairs(candidats) do
			local g, liste = cand.g, cand.liste
			-- part de tramage visée : un cube visible sur 3 au plus (effet « petits cubes » à 2-3 teintes)
			local maxi = math.floor(#liste / 3)
			local poses, i, taille, refus = posesDe[g] or 0, 1, 6, 0
			while i <= #liste and poses < maxi and total < limite and essais < 200 and refus < 6 do
				local lot = {}
				for j = i, math.min(#liste, i + taille - 1) do
					table.insert(lot, liste[j])
				end
				i = i + #lot
				local anciens = {}
				local modifies = {}
				-- repeint un cube (s'il est libre, visible et encore de la couleur de base) ET son reflet
				-- en -x : la tête, le corps, le cou et la queue sont symétriques, et une rangée x = -a..a
				-- dont les deux bouts ont la même nuance reste une seule part (le milieu est caché)
				local function libre(w, base)
					return w and not anciens[w] and not trames[w] and w.g == g and not interieur[w] and w.c.materiau == nil and w.c.couleur == base
				end
				local function poser(w, nc)
					anciens[w] = w.c
					table.insert(modifies, w)
					w.c = { couleur = nc, materiau = nil }
					if w.x ~= 0 then
						local m = V:lire(-w.x, w.y, w.z)
						if libre(m, anciens[w].couleur) then
							anciens[m] = m.c
							table.insert(modifies, m)
							m.c = { couleur = nc, materiau = nil }
						end
					end
				end
				for _, v in ipairs(lot) do
					if not anciens[v] and not trames[v] then
						local h = K.hache(v.x, v.y, v.z, graine + 17)
						local base = v.c.couleur
						-- trois nuances : plus claire, un peu plus foncée, nettement plus foncée
						local nc
						if h < 0.42 then
							nc = eclaircir(base, 0.16)
						elseif h < 0.76 then
							nc = assombrir(base, 0.86)
						else
							nc = assombrir(base, 0.74)
						end
						poser(v, nc)
						-- petit trait vertical de 1 à 3 cubes (moins cher en parts que des cubes isolés)
						local h2 = K.hache(v.x, v.y, v.z, graine + 29)
						local longueur = (h2 < 0.35 and 1) or (h2 < 0.7 and 2) or 3
						for dy = 1, longueur - 1 do
							local dessous = V:lire(v.x, v.y - dy, v.z)
							if not libre(dessous, base) then break end
							poser(dessous, nc)
						end
					end
				end
				essais = essais + 1
				local n = compter(g)
				local cher = passe == 1 and (n - parG[g]) > math.max(1, #modifies * 0.7)
				if total - parG[g] + n <= limite and not cher then
					total = total - parG[g] + n
					parG[g] = n
					poses = poses + #modifies
					for _, v in ipairs(modifies) do
						trames[v] = true
					end
				else
					for _, v in ipairs(modifies) do
						v.c = anciens[v]
					end
					if not cher then
						refus = refus + 1
						taille = math.max(1, math.floor(taille / 2))
					end
				end
			end
			posesDe[g] = poses
		end
		end
		return total
	end
	return K
end

local ESPECES = {}

-- ensembles de groupes
local function groupes(...)
	local t = {}
	for _, g in ipairs({ ... }) do t[g] = true end
	return t
end
local PEAU = groupes("Corps", "Cou", "Tete", "Queue", "PatteAvD", "PatteAvG", "PatteArD", "PatteArG")

-- ventre : zone basse du tronc (Corps, Cou) dans |x| <= hw, y <= yMax, z1 <= z <= z2
local function zoneVentre(couleur, hw, yMax, z1, z2)
	return function(x, y, z, v)
		if (v.g == "Corps" or v.g == "Cou") and math.abs(x) <= hw and y <= yMax and z >= z1 and z <= z2 then
			return couleur
		end
		return nil
	end
end

-- ===== Commun (9 à 11 cubes de haut) =====

-- Galli : petit « dino-autruche » orange : longues jambes fines, corps court et bas, cou fin
-- dressé à la verticale devant le poitrail, petite tête portée en avant, bec pointu, queue en
-- plumeau rouge
function ESPECES.Galli(V, K)
	local p = K.pal("FFB23F", "E0822A")
	local rouge = K.pal("FF4F5E")
	local bec = K.pal("FF8A1F", "D9661A")
	local ventre = K.hex("FFF1C9")
	-- longues jambes : cuisse emplumée sur le flanc, tibia 2 x 2 haut, pied orange à ongles crème
	V:boite(3, 5, -1, 3, 7, 1, p.b, "PatteArD")
	K.patte(V, { x = 1, z = 0, l = 2, p = 2, h = 5, c = p.f, g = "PatteArD", pied = bec.b, ongle = K.creme })
	-- corps court (3 de haut) ; petits bras à griffe
	K.bloc(V, 2, 5, 7, -2, 3, p.b, "Corps", 1)
	V:boite(3, 6, -2, 3, 6, -1, p.b, "PatteAvD")
	V:mettre(3, 5, -2, K.creme, "PatteAvD")
	-- cou fin (3 de large) dressé à la verticale sur 5 cubes devant le poitrail
	K.troncons(V, { { 1, 5, 9, -4, -3 } }, p.b, "Cou")
	-- petite tête 3 x 3 portée en avant (vide dessous : silhouette d'autruche), bec de 3
	K.tete(V, 1, 8, 10, -7, -4, p.b)
	K.bloc(V, 0, 8, 9, -9, -8, bec.b, "Tete")
	V:mettre(0, 8, -10, bec.f, "Tete")
	-- queue fine et longue, plumeau rouge au bout
	K.troncons(V, { { 1, 5, 7, 4, 6 }, { 1, 6, 7, 7, 8 }, { 0, 6, 7, 9, 10 } }, p.b, "Queue")
	K.bloc(V, 1, 6, 7, 11, 11, rouge.b, "Queue")
	V:mettre(0, 8, 11, rouge.c, "Queue")
	V:mettre(0, 6, 12, rouge.f, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 1, 5, -6, 3))
	-- rayures foncées sur le dos et la queue
	K.repeindre(V, p, p.f, function(x, y, z) return y >= 7 and z >= 0 and z % 3 == 0 end, groupes("Corps", "Queue"))
	-- bec : mâchoire inférieure plus foncée (bouche)
	V:boite(0, 8, -9, 0, 8, -8, bec.f, "Tete")
	K.yeux(V, 8, -6, 3)
end

-- Pachy : bipède trapu bleu, tête tenue basse au niveau du dos, dôme osseux crème bombé bordé
-- de bosses violettes, queue épaisse
function ESPECES.Pachy(V, K)
	local p = K.pal("5BC0FF", "3B8FD6")
	local dome = K.hex("F3E2B8")
	local couronne = K.hex("D9C08E")
	local bosse = K.hex("B86BFF")
	local ventre = K.hex("DDF3FF")
	-- jambes courtes et épaisses, cuisse qui renfle le flanc
	V:boite(4, 3, 0, 5, 5, 2, p.b, "PatteArD")
	K.patte(V, { x = 2, z = 0, l = 2, p = 2, h = 3, c = p.f, g = "PatteArD", pied = p.ff, ongle = K.creme })
	-- corps trapu
	K.bloc(V, 4, 3, 7, -3, 3, p.b, "Corps", 1)
	V:boite(3, 4, -4, 3, 5, -4, p.b, "PatteAvD")
	V:mettre(3, 3, -4, K.creme, "PatteAvD")
	-- cou court et tête basse (le haut du crâne au niveau du dos)
	K.troncons(V, { { 2, 5, 7, -5, -4 } }, p.b, "Cou")
	V:boite(-2, 4, -9, 2, 7, -5, p.b, "Tete")
	K.bloc(V, 1, 4, 5, -10, -10, p.b, "Tete")
	K.troncons(V, { { 2, 4, 6, 4, 6 }, { 1, 4, 5, 7, 9 }, { 0, 4, 4, 10, 12 } }, p.b, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 4, -6, 3))
	K.repeindre(V, p, p.f, function(x, y, z) return y >= 6 and z >= -2 and z % 3 == 1 end, groupes("Corps", "Queue"))
	-- dôme osseux bombé sur 3 couches : y = 8 et y = 9 en 5 x 5 sans les coins (couronne plus
	-- foncée en y = 8), y = 10 en 3 x 3 plus clair
	for x = -2, 2 do
		for z = -9, -5 do
			if not (math.abs(x) == 2 and (z == -9 or z == -5)) then
				local bord = math.abs(x) == 2 or z == -9 or z == -5
				V:mettre(x, 8, z, bord and couronne or dome, "Crete")
				V:mettre(x, 9, z, dome, "Crete")
			end
		end
	end
	K.bloc(V, 1, 10, 10, -8, -6, K.eclaircir(dome, 0.35), "Crete")
	-- bosses violettes sur le bord du dôme seulement (plus rien au sommet)
	for _, s in ipairs({ 1, -1 }) do
		V:mettre(3 * s, 8, -8, bosse, "Crete")
		V:mettre(3 * s, 8, -6, bosse, "Crete")
		V:mettre(2 * s, 8, -4, bosse, "Crete")
	end
	K.yeux(V, 5, -8, 4)
	K.bouche(V, 4, -10, -8, p.ff)
	K.narines(V, 5, 1)
end

-- Tricéra : quadrupède vert, collerette rose tramée bordée d'orange à picots blancs, taches
-- rouges, trois cornes ivoire qui dépassent devant, bec orange
function ESPECES.Tricera(V, K)
	local p = K.pal("6BD64A", "4EA93A")
	local ventre = K.hex("E6FFB8")
	local rose = K.pal("FF8FB1", "E86A92")
	local tache = K.hex("D6283A")
	local corne = K.hex("E8D5A8")
	local bec = K.pal("FF9F45", "D97A2E")
	K.patte(V, { x = 2, z = -4, l = 2, p = 2, h = 3, c = p.f, g = "PatteAvD", ongle = K.creme })
	K.patte(V, { x = 2, z = 3, l = 2, p = 3, h = 3, c = p.f, g = "PatteArD", ongle = K.creme })
	K.bloc(V, 3, 3, 7, -5, 5, p.b, "Corps", 1)
	K.bloc(V, 2, 8, 8, -3, 3, p.b, "Corps")
	K.troncons(V, { { 2, 3, 6, -7, -6 } }, p.b, "Cou")
	-- tête relevée d'un cube (l'œil n'est plus à hauteur de genou), bec
	K.tete(V, 2, 3, 6, -11, -7, p.b)
	K.bloc(V, 1, 3, 5, -13, -12, bec.b, "Tete")
	V:boite(0, 3, -14, 0, 4, -14, bec.f, "Tete")
	-- collerette plate (z = -7 et -6) en demi-disque au-dessus de la nuque : bord d'un seul cube
	-- orange, intérieur rose tramé de rose foncé (1 cube sur 3)
	local function dedans(x, y)
		local a, b = x / 5.6, (y - 4) / 5.8
		return y >= 4 and a * a + b * b <= 1
	end
	for x = -5, 5 do
		for y = 4, 10 do
			if dedans(x, y) then
				local bord = not (dedans(x + 1, y) and dedans(x - 1, y) and dedans(x, y + 1))
				local c = rose.b
				if bord then
					c = bec.b
				elseif K.hache(math.abs(x), y, 0, 3) < 0.34 then
					c = rose.f
				end
				V:mettre(x, y, -7, c, "Crete")
				V:mettre(x, y, -6, c, "Crete")
			end
		end
	end
	-- picots blancs sur le bord, taches rouges dans le rose (sur la face avant)
	for _, b in ipairs({ { 2, 10 }, { 4, 9 }, { 6, 6 }, { 6, 4 } }) do
		V:mettre(b[1], b[2], -6, K.blanc, "Crete")
	end
	V:mettre(0, 10, -6, K.blanc, "Crete")
	for _, t in ipairs({ { 2, 8 }, { 4, 6 } }) do
		V:mettre(t[1], t[2], -7, tache, "Tache")
	end
	V:mettre(0, 8, -7, tache, "Tache")
	-- cornes de front : montent puis filent vers l'avant (dépassent la collerette), pointe blanche ;
	-- corne de nez sur le bec
	K.chemin(V, { { 1, 7, -9 }, { 1, 8, -9 }, { 1, 8, -12 } }, function() return corne end, "Corne")
	V:mettre(1, 8, -13, K.blanc, "Corne")
	V:mettre(0, 6, -12, corne, "Corne")
	V:mettre(0, 7, -12, K.blanc, "Corne")
	K.troncons(V, { { 2, 4, 6, 6, 8 }, { 1, 3, 5, 9, 11 }, { 0, 3, 3, 12, 13 } }, p.b, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 3, -6, 5))
	K.repeindre(V, p, p.f, function(x, y, z) return y >= 7 and z % 3 == 0 end, groupes("Corps", "Queue"))
	K.yeux(V, 4, -10, 4)
	K.bouche(V, 3, -13, -11, bec.ff)
	K.narines(V, 4, 1)
end

-- ===== Rare (11 à 12 cubes) =====

-- Stégo : dos voûté, deux rangées de grandes plaques orange, tête basse, queue à 4 pointes
function ESPECES.Stego(V, K)
	local p = K.pal("2EC4B6", "1E968C")
	local ventre = K.hex("D6FFF7")
	local orange = K.pal("FF8C42", "D9601E")
	local ivoire = K.hex("E8D5A8")
	K.patte(V, { x = 2, z = -5, l = 2, p = 2, h = 4, c = p.f, g = "PatteAvD", ongle = K.creme })
	K.patte(V, { x = 2, z = 3, l = 3, p = 3, h = 4, c = p.f, g = "PatteArD", ongle = K.creme })
	K.bloc(V, 3, 4, 7, -6, 6, p.b, "Corps", 1)
	K.bloc(V, 2, 8, 8, -4, 5, p.b, "Corps")
	K.troncons(V, { { 1, 3, 5, -8, -7 } }, p.b, "Cou")
	K.tete(V, 2, 2, 5, -12, -8, p.b)
	K.bloc(V, 1, 2, 3, -13, -13, p.b, "Tete")
	-- queue : le tronçon moyen va jusqu'à z = 14 pour porter la seconde paire de pointes
	K.troncons(V, { { 2, 5, 7, 7, 9 }, { 1, 5, 6, 10, 14 }, { 0, 5, 5, 15, 16 } }, p.b, "Queue")
	-- pointes de queue : chaîne de cubes reliés face contre face (vers l'extérieur puis le haut),
	-- ivoire, bout blanc
	for _, z in ipairs({ 11, 14 }) do
		V:mettre(1, 7, z, ivoire, "Queue")
		V:mettre(2, 7, z, ivoire, "Queue")
		V:mettre(2, 8, z, ivoire, "Queue")
		V:mettre(3, 8, z, K.blanc, "Queue")
	end
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 4, -7, 6))
	-- taches foncées sur les flancs
	K.repeindre(V, p, p.ff, function(x, y, z) return math.abs(x) == 3 and y == 6 and (z + 20) % 4 == 0 end, groupes("Corps"), "Tache")
	-- plaques pointues (1 cube d'épaisseur) en deux rangées décalées, plus hautes au milieu
	local function plaque(x, zc, largeurs)
		for i, l in ipairs(largeurs) do
			local y = 8 + i
			for dz = -l, l do
				local c = orange.b
				if i == #largeurs or math.abs(dz) == l then c = orange.f end
				V:mettre(x, y, zc + dz, c, "Crete")
			end
		end
	end
	plaque(1, -3, { 1, 0 })
	plaque(-1, -1, { 1, 1, 0 })
	plaque(1, 1, { 2, 1, 0 })
	plaque(-1, 3, { 1, 1, 0 })
	plaque(1, 5, { 1, 0 })
	K.yeux(V, 3, -11, 4)
	K.bouche(V, 2, -13, -11, p.ff)
	K.narines(V, 3, 1)
end

-- Parasaure : bleu, grandes pattes arrière, bec de canard jaune, crête rose en tube qui part du
-- crâne et monte en biais vers l'arrière (au-dessus de la tête et du cou, jamais au-dessus du dos)
function ESPECES.Parasaure(V, K)
	local p = K.pal("4D96FF", "2F6BD6")
	local ventre = K.hex("FFE9B0")
	local rose = K.pal("FF5CA8", "D93A86")
	local jaune = K.pal("FFD166", "F2A93B")
	V:boite(3, 4, 0, 4, 6, 3, p.b, "PatteArD")
	K.patte(V, { x = 2, z = 1, l = 2, p = 2, h = 4, c = p.f, g = "PatteArD", ongle = K.creme })
	K.patte(V, { x = 2, z = -4, l = 2, p = 2, h = 4, c = p.f, g = "PatteAvD", ongle = K.creme })
	K.bloc(V, 3, 4, 8, -5, 4, p.b, "Corps", 1)
	K.troncons(V, { { 1, 7, 9, -7, -5 } }, p.b, "Cou")
	K.tete(V, 2, 7, 10, -11, -7, p.b)
	-- bec de canard large et plat
	K.bloc(V, 2, 8, 8, -13, -12, jaune.b, "Tete")
	K.bloc(V, 1, 7, 7, -13, -12, jaune.f, "Tete")
	-- crête : tube de 3 de large posé sur le crâne et la nuque, qui monte d'un cube puis file vers
	-- l'arrière en s'affinant ; bout recourbé plus foncé
	V:boite(0, 10, -9, 1, 10, -6, rose.b, "Crete")
	V:boite(0, 11, -8, 1, 11, -5, rose.b, "Crete")
	V:mettre(0, 11, -4, rose.b, "Crete")
	V:mettre(0, 11, -3, rose.f, "Crete")
	K.troncons(V, { { 2, 5, 7, 5, 7 }, { 1, 5, 6, 8, 10 }, { 0, 4, 5, 11, 13 }, { 0, 4, 4, 14, 14 } }, p.b, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 5, -8, 4))
	K.teinter(V, rose, groupes("Crete"))
	V:peindre(function(x, y, z) if z == -7 or z == -5 then return rose.c end return nil end, "Crete")
	-- rayures roses sur le dos
	K.repeindre(V, p, rose.b, function(x, y, z) return y >= 8 and z >= -3 and z % 3 == 0 end, groupes("Corps", "Queue"), "Tache")
	K.yeux(V, 8, -10, 4)
	K.bouche(V, 7, -11, -10, jaune.ff)
	K.narines(V, 8, 1)
end

-- ===== Épique (12 à 14 cubes) =====

-- Ankylo : bas et large, carapace brune bombée à bosses plates crème, pointes latérales
-- horizontales qui s'affinent, massue de queue
function ESPECES.Ankylo(V, K)
	local p = K.pal("F4A259", "D9793A")
	local brun = K.pal("A0522D", "7A3B1E")
	local ivoire = K.hex("E8D5A8")
	local ventre = K.hex("FFE3C2")
	local bosse = K.hex("E8C9A0")
	-- pattes courtes et massives
	K.patte(V, { x = 3, z = -5, l = 3, p = 3, h = 3, c = p.f, g = "PatteAvD", ongle = ivoire })
	K.patte(V, { x = 3, z = 3, l = 3, p = 3, h = 3, c = p.f, g = "PatteArD", ongle = ivoire })
	-- corps large et bas, carapace bombée en trois étages
	K.bloc(V, 5, 3, 7, -6, 6, p.b, "Corps", 1)
	K.bloc(V, 4, 8, 8, -5, 5, brun.b, "Corps")
	K.bloc(V, 3, 9, 9, -4, 4, brun.b, "Corps")
	K.bloc(V, 2, 10, 10, -3, 3, brun.b, "Corps")
	V:peindre(function(x, y, z) if y >= 6 then return brun.b end return nil end, "Corps")
	-- tête plus étroite que les épaules (5 de large), plaque de crâne, cornes de joue
	K.troncons(V, { { 2, 3, 6, -7, -7 } }, p.b, "Cou")
	K.tete(V, 2, 3, 6, -12, -8, p.b)
	K.bloc(V, 1, 3, 4, -13, -13, p.b, "Tete")
	K.bloc(V, 1, 7, 7, -11, -9, brun.b, "Tete")
	V:mettre(3, 5, -9, ivoire, "Corne")
	V:mettre(3, 6, -9, K.blanc, "Corne")
	-- pointes latérales horizontales au bord de la carapace : brun foncé -> ivoire -> bout blanc
	for _, z in ipairs({ -4, -1, 2, 5 }) do
		V:mettre(6, 6, z, brun.f, "Crete")
		V:mettre(7, 6, z, ivoire, "Crete")
		if z == -1 or z == 2 then
			V:mettre(8, 6, z, K.blanc, "Crete")
		end
	end
	V:symetriser()
	-- queue et massue
	K.troncons(V, { { 2, 4, 6, 7, 9 }, { 1, 3, 5, 10, 13 } }, p.b, "Queue")
	K.bloc(V, 2, 1, 4, 14, 16, brun.b, "Massue", 1)
	for _, b in ipairs({ { 3, 3, 15 }, { -3, 3, 15 }, { 0, 5, 15 }, { 0, 3, 17 } }) do
		V:mettre(b[1], b[2], b[3], ivoire, "Massue")
	end
	K.teinter(V, p, PEAU, zoneVentre(ventre, 3, 4, -7, 6))
	K.teinter(V, brun, groupes("Corps", "Massue", "Tete"))
	-- bosses plates crème posées sur la carapace, trois rangées (milieu 1 x 2, côtés 2 x 2)
	local function poser(x, z)
		local y = K.dessus(V, x, z)
		if y then V:mettre(x, y + 1, z, bosse, "Crete") end
	end
	for _, z in ipairs({ -4, -1, 2, 5 }) do
		for dz = 0, 1 do
			if math.abs(z + dz) <= 3 then poser(0, z + dz) end
			for _, s in ipairs({ 1, -1 }) do
				poser(3 * s, z + dz)
				poser(4 * s, z + dz)
			end
		end
	end
	K.yeux(V, 4, -10, 4)
	K.bouche(V, 3, -13, -11, p.ff)
	K.narines(V, 4, 1)
end

-- Iguano : ardoise, à demi quadrupède (mains posées au sol), bec crème, pouces-éperons blancs
-- dressés, bande dorsale jaune, petit fanon sous la gorge
function ESPECES.Iguano(V, K)
	local p = K.pal("7A8CA8", "56647E")
	local ventre = K.hex("FFF4DC")
	local bande = K.hex("FFE14D")
	local bec = K.pal("FFF1D0", "E3CFA3")
	local fanon = K.hex("FF6B3D")
	-- jambes arrière puissantes
	V:boite(3, 4, 0, 4, 7, 3, p.b, "PatteArD")
	K.patte(V, { x = 2, z = 1, l = 3, p = 2, h = 4, c = p.f, g = "PatteArD", ongle = K.creme })
	-- bras-pattes avant 2 x 2 posés au sol, pouce-éperon blanc dressé contre le poignet
	K.patte(V, { x = 1, z = -5, l = 2, p = 2, h = 5, c = p.f, g = "PatteAvD", ongle = K.creme })
	V:boite(3, 1, -5, 3, 2, -5, K.blanc, "PatteAvD")
	-- tronc : bassin haut, poitrail un peu plus bas vers l'avant
	K.bloc(V, 3, 4, 9, -2, 4, p.b, "Corps", 1)
	K.bloc(V, 2, 5, 9, -6, -3, p.b, "Corps", 1)
	K.troncons(V, { { 1, 8, 10, -8, -6 } }, p.b, "Cou")
	K.tete(V, 2, 9, 12, -12, -8, p.b)
	-- bec crème de 3 de large et 2 de long au bout du museau
	K.bloc(V, 1, 9, 10, -14, -13, bec.b, "Tete")
	V:boite(-1, 9, -14, 1, 9, -13, bec.f, "Tete")
	K.troncons(V, { { 2, 5, 7, 5, 7 }, { 1, 4, 6, 8, 10 }, { 0, 3, 4, 11, 13 }, { 0, 2, 3, 14, 15 } }, p.b, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 6, -7, 4))
	-- chevrons foncés sur la queue
	K.repeindre(V, p, p.ff, function(x, y, z) return z % 3 == 0 end, groupes("Queue"), "Tache")
	-- bande dorsale jaune d'un cube de large (dessus du cou, du dos et de la queue)
	for _, v in pairs(V.grille) do
		if v.x == 0 and (v.g == "Corps" or v.g == "Cou" or v.g == "Queue") and not V:lire(0, v.y + 1, v.z) then
			v.c = { couleur = bande, materiau = nil }
		end
	end
	-- petit fanon (2 cubes) collé sous la gorge
	V:boite(0, 8, -10, 0, 8, -9, fanon, "Tete")
	K.yeux(V, 10, -11, 4)
	K.bouche(V, 9, -12, -11, p.ff)
	K.narines(V, 10, 1)
end

-- ===== Légendaire (14 à 16 cubes) =====

-- Brachio : jaune tacheté d'orange, épaules hautes (pattes avant plus longues), dos qui descend
-- vers la queue, long cou fin qui monte en diagonale, petite tête à fleurons d'or
function ESPECES.Brachio(V, K)
	local p = K.pal("FFD23F", "E6A92A")
	local orange = K.hex("FF9F1C")
	local ventre = K.hex("FFF0B8")
	local feuille = K.hex("5BD13B")
	local fleur = K.hex("FF6FAE")
	local or_ = K.hex("FFB300")
	K.patte(V, { x = 2, z = -5, l = 3, p = 3, h = 6, c = p.f, g = "PatteAvD", ongle = K.creme })
	K.patte(V, { x = 2, z = 3, l = 3, p = 3, h = 4, c = p.f, g = "PatteArD", ongle = K.creme })
	-- avant du corps plus haut que la croupe, garrot
	K.bloc(V, 4, 5, 8, -6, -1, p.b, "Corps", 1)
	K.bloc(V, 4, 4, 7, 0, 6, p.b, "Corps", 1)
	K.bloc(V, 3, 9, 9, -5, -2, p.b, "Corps")
	-- cou fin (3 de large) qui monte presque à la verticale devant le poitrail, sur 7 cubes
	K.troncons(V, { { 1, 7, 10, -7, -6 }, { 1, 9, 12, -8, -8 }, { 1, 11, 13, -9, -9 } }, p.b, "Cou")
	-- petite tête 3 x 3 portée en avant (vide dessous)
	V:boite(-1, 12, -13, 1, 14, -10, p.b, "Tete")
	K.troncons(V, { { 2, 4, 6, 7, 9 }, { 1, 4, 5, 10, 12 }, { 1, 3, 4, 13, 15 }, { 0, 2, 3, 16, 17 } }, p.b, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 5, -7, 6))
	-- grandes taches orange (blocs 2 x 2) sur les flancs et le cou
	K.repeindre(V, p, orange, function(x, y, z, v)
		local by, bz = math.floor(y / 2), math.floor((z + 40) / 2)
		return (math.abs(x) >= 2 or v.g == "Cou") and y >= 6 and (bz + by) % 3 == 0
	end, groupes("Corps", "Cou"), "Tache")
	-- brin de feuilles fleuri au coin droit de la bouche (d'un seul côté : de face, deux brins
	-- symétriques se liraient comme des oreilles)
	V:mettre(2, 12, -13, feuille, "Tete")
	V:mettre(3, 12, -13, feuille, "Tete")
	V:mettre(3, 12, -14, fleur, "Tete")
	-- trois fleurons d'or posés sur le crâne
	V:mettre(1, 15, -12, or_, "Crete")
	V:mettre(-1, 15, -12, or_, "Crete")
	V:mettre(0, 15, -11, or_, "Crete")
	K.yeux(V, 13, -12, 3)
	K.bouche(V, 12, -12, -11, p.ff)
	K.narines(V, 14, 1)
end

-- ===== Mythique (16 à 18 cubes) =====

-- Diplodo : violet, très long cou et queue en fouet, selle rose, cristaux Neon cyan sur l'échine
function ESPECES.Diplodo(V, K)
	local p = K.pal("B15CFF", "8A3FD6")
	local rose = K.pal("FF6FD8", "D94FB5")
	local socle = K.hex("7FE8FF")
	local cristal = { couleur = K.hex("00B8FF"), materiau = Enum.Material.Neon }
	local ventre = K.hex("FFC2F0")
	K.patte(V, { x = 2, z = -6, l = 3, p = 3, h = 6, c = p.f, g = "PatteAvD", ongle = K.creme })
	K.patte(V, { x = 2, z = 4, l = 3, p = 3, h = 6, c = p.f, g = "PatteArD", ongle = K.creme })
	K.bloc(V, 4, 6, 10, -7, 7, p.b, "Corps", 1)
	K.bloc(V, 3, 11, 11, -5, 5, p.b, "Corps")
	-- long cou qui monte vers l'avant, anneaux roses
	K.troncons(V, { { 2, 8, 11, -10, -8 }, { 2, 10, 12, -13, -11 }, { 1, 11, 13, -16, -14 }, { 1, 12, 14, -18, -17 } }, p.b, "Cou")
	K.tete(V, 2, 12, 15, -22, -18, p.b)
	K.bloc(V, 1, 12, 13, -23, -23, p.b, "Tete")
	-- queue en fouet
	K.troncons(V, { { 2, 7, 9, 8, 10 }, { 1, 6, 8, 11, 13 }, { 1, 5, 6, 14, 16 }, { 0, 4, 5, 17, 19 }, { 0, 3, 4, 20, 21 }, { 0, 3, 3, 22, 22 } }, p.b, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, zoneVentre(ventre, 2, 6, -8, 7))
	-- selle rose : bandes de 2 z tous les 5 z sur le dos (peu de coupures : les parts économisées
	-- financent le tramage), anneaux roses sur le cou et la queue
	K.repeindre(V, p, rose.b, function(x, y, z) return y >= 10 and (z + 40) % 5 < 2 end, groupes("Corps"), "Tache")
	K.repeindre(V, p, rose.b, function(x, y, z) return z == -12 or z == -16 or z == 12 or z == 18 end, groupes("Cou", "Queue"), "Tache")
	-- cristaux de l'échine : socle clair, pointe Neon
	for _, c in ipairs({ { -4, 1 }, { -1, 2 }, { 2, 2 }, { 5, 1 } }) do
		V:boite(0, 12, c[1], 0, 11 + c[2], c[1], socle, "Cristal")
		V:mettre(0, 12 + c[2], c[1], cristal, "Cristal")
	end
	-- diadème de cristaux sur le crâne, cristal au bout de la queue
	V:mettre(0, 15, -20, socle, "Cristal")
	V:mettre(0, 16, -20, cristal, "Cristal")
	V:mettre(1, 15, -19, cristal, "Cristal")
	V:mettre(-1, 15, -19, cristal, "Cristal")
	V:mettre(0, 3, 23, cristal, "Cristal")
	K.yeux(V, 13, -21, 4)
	K.bouche(V, 12, -23, -21, p.ff)
	K.narines(V, 13, 1)
end

-- ===== Divin (17 à 19 cubes) =====

-- Thérizino : bipède au plumage jade (dessus menthe, dessous vert profond), plastron crème,
-- l'or réservé aux faux, au bec et à l'éventail de la queue ; jambes 3 x 3 sur pieds d'or,
-- trois longues faux par main (pointes Neon), crête de plumes, auréole au-dessus de la tête
function ESPECES.Therizino(V, K)
	local jade = K.hex("3FCF8E")
	local p = { b = jade, c = K.hex("A8F5CF"), f = K.hex("1E8F5E") }
	p.ff = K.assombrir(p.f, 0.78)
	local plastron = K.hex("FFF3E0")
	local or_ = K.pal("FFC933", "E09A1F")
	local rose = K.hex("FF8FC8")
	local neonOr = { couleur = K.hex("FFB300"), materiau = Enum.Material.Neon }
	-- jambes 3 x 3 hautes, cuisse emplumée, pied d'or de 3 x 4
	V:boite(4, 5, 0, 4, 8, 3, p.b, "PatteArD")
	K.patte(V, { x = 2, z = 0, l = 3, p = 3, h = 6, c = p.f, g = "PatteArD", pied = or_.b })
	V:boite(2, 0, -1, 4, 0, -1, or_.b, "PatteArD")
	-- ventre descendu d'un cube, épaules plus étroites, poitrail
	K.bloc(V, 3, 4, 10, -3, 4, p.b, "Corps", 1)
	K.bloc(V, 2, 11, 13, -2, 2, p.b, "Corps")
	K.bloc(V, 2, 6, 10, -4, -4, p.b, "Corps")
	K.troncons(V, { { 1, 12, 14, -4, -3 } }, p.b, "Cou")
	K.tete(V, 2, 13, 16, -8, -4, p.b)
	-- bec doré
	K.bloc(V, 1, 13, 14, -10, -9, or_.b, "Tete")
	V:mettre(0, 13, -11, or_.f, "Tete")
	-- bras : épaule, avant-bras, main, trois longues faux d'or verticales (pointe Neon en y = 2)
	V:boite(3, 10, -2, 4, 12, -1, p.b, "PatteAvD")
	V:boite(4, 8, -4, 5, 9, -2, p.b, "PatteAvD")
	V:boite(4, 6, -5, 6, 7, -4, p.f, "PatteAvD")
	-- (lames alternées or clair / or, celle du milieu plus courte : on distingue les trois griffes ;
	-- chaque lame descend puis se recourbe vers l'avant, pointe Neon)
	for _, x in ipairs({ 4, 5, 6 }) do
		local milieu = x == 5
		local bas = milieu and 4 or 3
		local c = milieu and or_.b or or_.c
		V:boite(x, bas, -6, x, 7, -6, c, "PatteAvD")
		V:mettre(x, bas, -7, c, "PatteAvD")
		V:mettre(x, bas - 1, -7, neonOr, "PatteAvD")
	end
	-- queue en éventail de plumes dorées
	K.troncons(V, { { 2, 7, 9, 5, 7 }, { 1, 8, 9, 8, 10 } }, p.b, "Queue")
	K.bloc(V, 2, 8, 11, 11, 11, or_.b, "Queue")
	K.bloc(V, 1, 12, 12, 11, 11, or_.c, "Queue")
	V:symetriser()
	K.teinter(V, p, PEAU, nil)
	-- plumes en écailles plus claires sur le dos et les cuisses, plastron crème
	K.repeindre(V, p, p.c, function(x, y, z)
		return z >= 1 and y >= 7 and (z + y) % 3 == 0
	end, groupes("Corps", "Queue", "PatteArD", "PatteArG"), nil)
	K.repeindre(V, p, plastron, function(x, y, z) return z <= -3 and math.abs(x) <= 2 and y <= 12 end, groupes("Corps"))
	-- crête de plumes menthe à bout blanc
	V:boite(0, 16, -7, 0, 17, -4, p.c, "Crete")
	V:mettre(0, 17, -7, K.blanc, "Crete")
	V:mettre(0, 16, -3, p.c, "Crete")
	-- auréole horizontale au-dessus de la tête, éclats Neon
	for a = 0, 15 do
		local ang = math.rad(a * 22.5)
		local x, z = math.floor(math.cos(ang) * 3.5 + 0.5), math.floor(-6 + math.sin(ang) * 3.5 + 0.5)
		local c = (a % 4 == 0) and neonOr or or_.c
		V:mettre(x, 18, z, c, "Aureole")
	end
	K.yeux(V, 14, -7, 4)
	K.bouche(V, 13, -10, -8, or_.ff)
	-- joues roses en arrière des yeux
	for _, s in ipairs({ 1, -1 }) do
		local x = K.bordX(V, s, 13, -6, "Tete")
		if x then V:mettre(x, 13, -6, rose, "Joue") end
	end
end

-- ===== construction =====
local ORDRE = { "Galli", "Pachy", "Tricera", "Stego", "Parasaure", "Ankylo", "Iguano", "Brachio", "Diplodo", "Therizino" }

-- lumière d'aura (Mythique et plus)
local AURAS = { Diplodo = "5CF2FF", Therizino = "7CFFC4" }

local function construireEspece(ctx, K, dossier, cle, infos, rang)
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
	K.recentrer(V)
	K.tramer(V, BUDGET, rang * 7)
	local modele = V:construire(dossier, { nom = cle, origine = CFrame.new(), budget = BUDGET })
	modele:SetAttribute("Espece", cle)
	modele:SetAttribute("Rarete", infos.rarete or "Commun")
	modele:SetAttribute("Famille", "Herbivore")
	if AURAS[cle] and modele.PrimaryPart then
		local l = Instance.new("PointLight")
		l.Name = "Aura"
		l.Color = K.hex(AURAS[cle])
		l.Range = 16
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
	for rang, cle in ipairs(ORDRE) do
		local infos = E.especes[cle]
		if type(infos) == "table" and infos.famille == "Herbivore" then
			local ok, err = pcall(construireEspece, ctx, K, dossier, cle, infos, rang)
			if not ok then
				warn("[Dino] gabarit voxel « " .. cle .. " » : " .. tostring(err))
			end
		end
	end
end

return M
