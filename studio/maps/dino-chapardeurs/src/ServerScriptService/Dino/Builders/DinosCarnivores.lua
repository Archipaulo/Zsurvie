-- Constructeur DinosCarnivores : gabarits des 10 espèces de la famille « Carnivore »
-- (carnivores, volant et marin), rangés dans ServerStorage.Dino.Dinos.
-- Version 2 « jouet de collection » : formes organiques en boules et cylindres (corps en poire,
-- grosses cuisses, queue en perles), museau arrondi, mâchoire entrouverte avec dents et crocs,
-- griffes blanches, gros yeux brillants (pupille, iris, reflet lumineux), motifs (taches, crêtes).
-- Chaque gabarit : pivot au sol sous le dino, regard vers -Z local, PrimaryPart = « Corps »,
-- au plus 40 parts, en SmoothPlastic (Neon seulement pour ce qui brille).
local M = {}

local BUDGET = 40 -- parts maximum par gabarit

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local E = ctx.Equilibrage
	local stockage = ctx.stockage
	if not (Charte and Outils and E and E.especes and stockage) then
		return
	end

	local dossierDinos = stockage:FindFirstChild("Dinos")
	if not dossierDinos then
		dossierDinos = Outils.dossier(stockage, "Dinos")
	end

	local ombre = Charte.ombre
	local lumiere = Charte.lumiere
	local V = Vector3.new
	local RAD = math.rad

	-- blanc pur et noir d'encre de la boîte à outils visuelle (repli sur la Charte)
	local Style = ctx.Style
	local BLANC = Charte.creme
	local NOIR = Charte.encre
	if Style and Style.couleurs then
		BLANC = Style.couleurs.texte or BLANC
		NOIR = Style.couleurs.contour or NOIR
	end

	-- version saturée et lumineuse d'une couleur de la Charte (look jouet vif)
	local function vif(c)
		local h, s, v = c:ToHSV()
		return Color3.fromHSV(h, math.min(1, s * 1.2 + 0.08), math.min(1, v * 1.08 + 0.04))
	end

	local ROSE_JOUE = lumiere(lumiere(Charte.alerte))
	local INTERIEUR_BOUCHE = ombre(ombre(Charte.alerte))

	local NEON = { Material = Enum.Material.Neon }
	local SANS_OMBRE = { CastShadow = false }
	local NEON_SANS_OMBRE = { Material = Enum.Material.Neon, CastShadow = false }

	-- gabarit en cours de construction
	local courant = { modele = nil, s = 1, compte = 0 }

	local FORMES = {
		bloc = Outils.bloc,
		boule = Outils.boule,
		coin = Outils.coin,
		cylindre = Outils.cylindre,
	}

	-- ===== primitives (tailles et positions en unités « taille 1 », mises à l'échelle ici) =====

	-- une part du gabarit placée par un CFrame
	local function poser(forme, nom, taille, cf, couleur, extra)
		if courant.compte >= BUDGET then
			return nil
		end
		local s = courant.s
		local props = {
			Name = nom,
			Size = taille * s,
			CFrame = CFrame.new(cf.Position * s) * cf.Rotation,
			Color = couleur,
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
			CanQuery = true,
			CanTouch = false,
			CastShadow = true,
		}
		if extra then
			for cle, valeur in pairs(extra) do
				props[cle] = valeur
			end
		end
		local fabrique = FORMES[forme] or Outils.bloc
		local p = fabrique(courant.modele, props)
		courant.compte = courant.compte + 1
		return p
	end

	-- une part placée par position et rotation (degrés)
	local function piece(forme, nom, taille, pos, couleur, rot, extra)
		local cf = CFrame.new(pos)
		if rot then
			cf = cf * CFrame.Angles(RAD(rot.X), RAD(rot.Y), RAD(rot.Z))
		end
		return poser(forme, nom, taille, cf, couleur, extra)
	end

	local function boule(nom, d, pos, couleur, extra)
		return poser("boule", nom, V(d, d, d), CFrame.new(pos), couleur, extra)
	end

	-- repère dont l'axe X (axe des cylindres Roblox) pointe de depart vers cible
	local function viser(depart, cible)
		local dir = cible - depart
		local haut = V(0, 1, 0)
		if math.abs(dir.Unit.Y) > 0.98 then
			haut = V(0, 0, -1)
		end
		return CFrame.lookAt(depart, cible, haut) * CFrame.Angles(0, RAD(90), 0)
	end

	-- cylindre tendu entre deux points (membres, rayons de voile)
	local function segment(nom, a, b, d, couleur, extra)
		return poser("cylindre", nom, V((b - a).Magnitude, d, d), viser((a + b) * 0.5, b), couleur, extra)
	end

	-- disque (cylindre plat) centré en centre, face tournée vers normale
	local function disque(nom, centre, normale, d, ep, couleur, extra)
		return poser("cylindre", nom, V(ep, d, d), viser(centre, centre + normale), couleur, extra)
	end

	-- tache peinte à plat sur une sphère (centre, diamètre), dans la direction dir
	local function tache(nom, centre, diametre, dir, d, couleur, extra)
		local n = dir.Unit
		local r = diametre / 2
		local fleche = d * d / (8 * r)
		return disque(nom, centre + n * (r - fleche * 0.6), n, d, 0.07 + fleche, couleur, extra)
	end

	-- appelle fn pour le côté gauche (-X) puis le côté droit (+X) du dino qui regarde vers -Z
	local function cotes(fn)
		fn(-1, "G")
		fn(1, "D")
	end

	-- membrane triangulaire à plat (aile, nageoire) : angle droit côté corps ; balaye = pointe vers l'arrière
	local function membrane(sx, centre, envergure, corde, ep, pente, balaye)
		local vz = V(0, 0, -1)
		local vx = V(0, sx, 0)
		if balaye then
			vz = V(0, 0, 1)
			vx = V(0, -sx, 0)
		end
		local cf = CFrame.new(centre) * CFrame.Angles(0, 0, RAD(sx * pente)) * CFrame.fromMatrix(V(0, 0, 0), vx, V(sx, 0, 0), vz)
		return cf, V(ep, envergure, corde)
	end

	-- ===== la tête =====

	-- gros yeux sur l'avant du crâne : blanc, iris éventuel, pupille noire, reflet lumineux
	local function yeux(H, R, e, o)
		local centres = {}
		cotes(function(sx, cote)
			local c = H + V(sx * R * (o.ecartYeux or 0.47), R * 0.3, -R * 0.74)
			boule("Oeil" .. cote, e, c, BLANC)
			local regard = V(sx * 0.16, 0.03, -1).Unit
			local p = e * 0.6
			local cp = c + regard * (e / 2 - p / 2 + p * 0.2)
			if o.iris then
				local i = e * 0.74
				local ci = c + regard * (e / 2 - i / 2 + i * 0.1)
				local ext = SANS_OMBRE
				if o.irisNeon then
					ext = NEON_SANS_OMBRE
				end
				boule("Iris" .. cote, i, ci, o.iris, ext)
				p = e * 0.4
				cp = ci + regard * (i / 2 - p / 2 + p * 0.22)
			end
			boule("Pupille" .. cote, p, cp, NOIR, SANS_OMBRE)
			boule("Reflet" .. cote, e * 0.22, cp + V(0.45, 0.6, -0.66).Unit * (p * 0.45), BLANC, NEON_SANS_OMBRE)
			centres[cote] = c
		end)
		return centres
	end

	-- tête chibi : crâne rond, museau à bout arrondi, mâchoire entrouverte, dents, crocs, narines
	-- o : museau { l, h, avance, bas }, machoire, ouverture (degrés), dents (0, 2, 4), crocs, dent,
	--     oeil, iris, irisNeon, joues, narines (false pour s'en passer)
	local function tete(o, H, T, c)
		local R = T / 2
		boule("Tete", T, H, c)

		-- museau : bloc prolongé d'un cylindre couché (nez rond)
		local mu = o.museau
		local wM, hM = mu.l, mu.h
		local zAr = H.Z - R * 0.15
		local zNez = H.Z - R - mu.avance
		local zAv = zNez + hM / 2
		local LM = zAr - zAv
		local yMu = H.Y - R * (mu.bas or 0.12) - hM / 2
		local basMu = yMu - hM / 2
		piece("bloc", "Museau", V(wM, hM, LM), V(0, yMu, (zAv + zAr) / 2), c)
		piece("cylindre", "MuseauBout", V(wM, hM, hM), V(0, yMu, zAv), c)

		local e = T * 0.4 * (o.oeil or 1)
		local centresYeux = yeux(H, R, e, o)

		-- mâchoire inférieure ouverte autour d'une charnière sous l'arrière du museau
		local ouv = o.ouverture or 15
		local wJ = wM * 0.9
		local hJ = hM * 0.72
		local LJ = LM + (hM - hJ) / 2
		local charniere = CFrame.new(0, basMu - 0.04, zAr) * CFrame.Angles(RAD(-ouv), 0, 0)
		local cMach = o.machoire or lumiere(c)
		poser("bloc", "Machoire", V(wJ, hJ, LJ), charniere * CFrame.new(0, -hJ / 2, -LJ / 2), cMach)
		poser("cylindre", "Menton", V(wJ, hJ, hJ), charniere * CFrame.new(0, -hJ / 2, -LJ), cMach)
		local LB = LJ * 0.94
		local hB = LJ * math.sin(RAD(ouv)) + 0.14
		poser("bloc", "Bouche", V(wM * 0.84, hB, LB), CFrame.new(0, basMu - 0.03, zAr) * CFrame.Angles(RAD(-ouv / 2), 0, 0) * CFrame.new(0, 0, -LB / 2), INTERIEUR_BOUCHE, SANS_OMBRE)

		-- dents du haut : losanges à moitié enfoncés dans la gencive (pointe vers le bas)
		local td = o.dent or math.min(0.44, wM * 0.24)
		local n = o.dents or 2
		local rangee = {}
		if n >= 4 then
			rangee = { V(-wM * 0.16, 0, 0), V(wM * 0.16, 0, 0), V(-wM * 0.35, 0, LM * 0.3), V(wM * 0.35, 0, LM * 0.3) }
		elseif n > 0 then
			rangee = { V(-wM * 0.22, 0, 0), V(wM * 0.22, 0, 0) }
		end
		for _, d in ipairs(rangee) do
			piece("bloc", "Dent", V(td, td, td * 0.55), V(d.X, basMu, zAv + 0.03 + d.Z), BLANC, V(0, 0, 45), SANS_OMBRE)
		end
		-- crocs du bas, pointe vers le haut, sur le bout de la mâchoire
		if o.crocs then
			cotes(function(sx)
				poser("bloc", "Croc", V(td * 0.9, td * 0.9, td * 0.5), charniere * CFrame.new(sx * wJ * 0.32, 0, -LJ + hJ * 0.2) * CFrame.Angles(0, 0, RAD(45)), BLANC, SANS_OMBRE)
			end)
		end

		-- narines sur le dessus du nez
		if o.narines ~= false then
			local dn = hM * 0.22
			cotes(function(sx, cote)
				boule("Narine" .. cote, dn, V(sx * wM * 0.2, yMu + hM / 2 - dn * 0.2, zAv - hM * 0.1), ombre(ombre(c)), SANS_OMBRE)
			end)
		end

		-- joues roses peintes sous les yeux
		if o.joues then
			cotes(function(sx, cote)
				local nj = V(sx * 0.85, -0.2, -0.48).Unit
				disque("Joue" .. cote, H + nj * (R - 0.03), nj, R * 0.5, 0.08, ROSE_JOUE, SANS_OMBRE)
			end)
		end

		return { H = H, R = R, d = T, e = e, yeux = centresYeux, wM = wM, hM = hM, yMu = yMu, zNez = zNez }
	end

	-- sourcils froncés au-dessus des yeux (regard de méchant rigolo)
	local function sourcils(t, couleur, extra)
		cotes(function(sx, cote)
			local c = t.yeux[cote] + V(-sx * t.e * 0.05, t.e * 0.52, t.e * 0.05)
			piece("bloc", "Sourcil" .. cote, V(t.e * 0.95, t.e * 0.22, t.e * 0.4), c, couleur, V(0, -20 * sx, 20 * sx), extra)
		end)
	end

	-- ===== le corps =====

	-- pattes arrière : grosse cuisse ronde, pied, deux griffes blanches
	local function pattesArriere(c, xJ, zTh, dT, cPied, g, ep)
		local hP = 0.42
		local yTh = hP + dT * 0.4
		cotes(function(sx, cote)
			boule("PatteAr" .. cote, dT, V(sx * xJ, yTh, zTh), c)
			local lP = dT
			local zP = zTh - dT * 0.2
			piece("bloc", "Pied" .. cote, V(dT * 0.62, hP, lP), V(sx * xJ, hP / 2, zP), cPied)
			for _, dx in ipairs({ -0.2, 0.2 }) do
				piece("coin", "Griffe" .. cote, V(0.26 * ep, 0.34 * g, 0.4 * g), V(sx * xJ + dx * dT, 0.17 * g, zP - lP / 2 - 0.1 * g), BLANC)
			end
		end)
		return yTh
	end

	-- théropode chibi (bipède trapu) : corps en poire, grosse tête, petits bras, queue en perles
	-- o : corps (diamètre), tete (diamètre), epaisseur, bras, epaisseurBras, queue, leveQueue,
	--     couleur, couleurTete, ventre, extraVentre, couleurBout, extraBout, griffe + options de tête
	local function theropode(o)
		local D = o.corps
		local c = o.couleur
		local ep = o.epaisseur or 1
		local dT = D * 0.55 * ep
		local yTh = 0.42 + dT * 0.4
		local yC = yTh + D * 0.3
		local cCorps = V(0, yC, 0)
		local cHanche = V(0, yC + D * 0.02, D * 0.34)

		boule("Corps", D, cCorps, c)
		boule("Ventre", D * 0.8, V(0, yC - D * 0.1, -D * 0.19), o.ventre or Charte.creme, o.extraVentre)
		boule("Hanche", D * 0.86, cHanche, c)

		local T = o.tete
		local t = tete(o, V(0, yC + D * 0.4 + T * 0.3, -D * 0.28 - T * 0.16), T, o.couleurTete or c)

		pattesArriere(c, D * 0.36, D * 0.12, dT, ombre(c), o.griffe or 1, ep)

		-- petits bras pendants vers l'avant et le bas, sur les flancs (sous la mâchoire)
		local bras = o.bras or 0.6
		local eb = 0.3 * (o.epaisseurBras or 1)
		cotes(function(sx, cote)
			segment("PatteAv" .. cote, V(sx * D * 0.36, yC - D * 0.06, -D * 0.26), V(sx * D * 0.46, yC - D * 0.3, -D * 0.4 - bras * 0.75), eb, c)
		end)

		-- queue : trois perles de plus en plus petites, bout relevé
		local q = o.queue or 2.2
		local a = V(0, yC, D * 0.55)
		local b = V(0, yC - D * 0.3, D * 0.55 + q)
		local perles = { { "Queue", 0.25, 0.64 }, { "QueueMilieu", 0.57, 0.5 }, { "QueueBout", 0.86, 0.36 } }
		for i, pr in ipairs(perles) do
			local t0 = pr[2]
			local pos = a + (b - a) * t0 + V(0, (o.leveQueue or 0) * t0 * t0, 0)
			local col = c
			local ext = nil
			if i == 3 then
				col = o.couleurBout or ombre(c)
				ext = o.extraBout
			end
			boule(pr[1], D * pr[3], pos, col, ext)
		end

		return { D = D, yC = yC, corps = { c = cCorps, d = D }, hanche = { c = cHanche, d = D * 0.86 }, t = t }
	end

	-- taches peintes sur le dos ; liste de { dir, d (fraction du corps), sur = "corps" ou "hanche" }
	local function motifs(r, liste, couleur, extra)
		for _, m in ipairs(liste) do
			local sph = r.hanche
			if m.sur == "corps" then
				sph = r.corps
			end
			tache("Tache", sph.c, sph.d, m.dir, m.d * r.D, couleur, extra)
		end
	end

	-- point de la surface d'une sphère du dos (pour épines et bosses)
	local function surDos(r, sur, dir, enfoncement)
		local sph = r.hanche
		if sur == "corps" then
			sph = r.corps
		end
		return sph.c + dir.Unit * (sph.d / 2 - (enfoncement or 0))
	end

	-- ===== les espèces =====
	local ESPECES = {}

	-- Compy : petit chapardeur vert pomme, tête énorme, joues roses, crête dorée
	ESPECES.Compy = function()
		local c = vif(Charte.herbe)
		local r = theropode({
			corps = 2.2,
			tete = 2.6,
			epaisseur = 0.9,
			bras = 0.45,
			queue = 1.8,
			leveQueue = 0.5,
			couleur = c,
			ventre = Charte.creme,
			museau = { l = 1.25, h = 0.7, avance = 0.4 },
			dents = 2,
			oeil = 1.1,
			joues = true,
		})
		local t = r.t
		piece("coin", "Crete", V(0.26, 0.9, 1.3), t.H + V(0, t.R * 0.9, t.R * 0.3), vif(Charte.dore), V(0, 180, 0))
		motifs(r, {
			{ dir = V(0.5, 0.8, 0.1), d = 0.26 },
			{ dir = V(-0.5, 0.8, 0.1), d = 0.26 },
		}, vif(Charte.jungle))
	end

	-- Raptor : orange caramel tacheté, plumes rouges, grandes griffes en faucille
	ESPECES.Raptor = function()
		local c = vif(Charte.terre)
		local r = theropode({
			corps = 2.3,
			tete = 2.3,
			epaisseur = 0.9,
			bras = 0.8,
			queue = 2.6,
			leveQueue = 0.6,
			couleur = c,
			ventre = Charte.sable,
			couleurBout = ombre(ombre(c)),
			museau = { l = 1.1, h = 0.72, avance = 0.95 },
			dents = 4,
			griffe = 1.45,
		})
		local t = r.t
		local rouge = vif(Charte.tapis)
		piece("coin", "Plume", V(0.24, 1.1, 1.5), t.H + V(0, t.R * 0.95, t.R * 0.25), rouge, V(0, 180, 0))
		piece("coin", "Plume", V(0.24, 0.85, 1.2), t.H + V(0, t.R * 0.6, t.R * 0.85), lumiere(rouge), V(0, 180, 0))
		motifs(r, {
			{ dir = V(0, 0.95, 0.3), d = 0.28 },
			{ dir = V(0.6, 0.75, 0.2), d = 0.24 },
			{ dir = V(-0.6, 0.75, 0.2), d = 0.24 },
		}, ombre(ombre(c)))
	end

	-- Dilopho : jaune vif, double crête rouge en demi-lune, grande collerette bicolore
	ESPECES.Dilopho = function()
		local c = vif(Charte.dore)
		local r = theropode({
			corps = 2.4,
			tete = 2.4,
			bras = 0.6,
			queue = 2.4,
			leveQueue = 0.4,
			couleur = c,
			ventre = Charte.creme,
			museau = { l = 1.2, h = 0.7, avance = 0.8 },
			dents = 2,
		})
		local t = r.t
		cotes(function(sx)
			disque("Crete", t.H + V(sx * 0.3, t.R * 0.8, t.R * 0.25), V(1, 0, 0), 1.8, 0.2, vif(Charte.alerte))
		end)
		local cc = t.H + V(0, -t.R * 0.15, t.R * 0.45)
		disque("Collerette", cc, V(0, 0, -1), t.d * 1.75, 0.16, vif(Charte.lave))
		disque("Collerette", cc + V(0, 0, -0.14), V(0, 0, -1), t.d * 1.4, 0.16, vif(Charte.alerte))
		motifs(r, {
			{ dir = V(0.45, 0.85, 0.2), d = 0.26 },
			{ dir = V(-0.45, 0.85, 0.2), d = 0.26 },
		}, vif(Charte.lave))
	end

	-- Ptéro : reptile volant rose, bec doré, grande crête, ailes triangulaires déployées
	ESPECES.Ptero = function()
		local c = vif(Charte.alerte)
		local peauAile = vif(Charte.sable)
		local D = 1.9
		local yC = 2.0
		boule("Corps", D, V(0, yC, 0), c)
		boule("Ventre", D * 0.78, V(0, yC - 0.2, -0.38), Charte.creme)

		-- tête ronde et bec
		local T = 1.9
		local R = T / 2
		local H = V(0, 3.35, -0.75)
		boule("Tete", T, H, c)
		yeux(H, R, T * 0.42, {})
		local bec = vif(Charte.dore)
		local yBec = H.Y - 0.3
		piece("coin", "BecHaut", V(0.8, 0.6, 2.2), V(0, yBec, H.Z - R - 0.65), bec)
		piece("bloc", "Bouche", V(0.5, 0.22, 1.1), V(0, yBec - 0.36, H.Z - R - 0.05), INTERIEUR_BOUCHE, nil, SANS_OMBRE)
		piece("coin", "BecBas", V(0.56, 0.36, 1.6), V(0, yBec - 0.3 - 0.12 - 0.18, H.Z - R - 0.3), ombre(bec), V(0, 0, 180))
		cotes(function(sx)
			piece("bloc", "Dent", V(0.2, 0.2, 0.12), V(sx * 0.18, yBec - 0.3, H.Z - R - 0.35), BLANC, V(0, 0, 45), SANS_OMBRE)
		end)
		cotes(function(sx, cote)
			local nj = V(sx * 0.85, -0.2, -0.48).Unit
			disque("Joue" .. cote, H + nj * (R - 0.03), nj, R * 0.5, 0.08, ROSE_JOUE, SANS_OMBRE)
		end)
		-- crête pointée vers l'arrière, bout coloré
		local cCrete = V(0, H.Y + R * 0.55, H.Z + R * 0.55 + 0.7)
		piece("coin", "Crete", V(0.24, 1.1, 2.2), cCrete, bec, V(0, 180, 0))
		piece("coin", "CreteBout", V(0.3, 0.6, 1.2), cCrete + V(0, -0.25, 0.5), vif(Charte.lave), V(0, 180, 0))

		-- pattes
		pattesArriere(c, 0.5, 0.15, 0.9, ombre(c), 0.8, 0.8)

		-- ailes : membrane, bout coloré, bras osseux sur le bord d'attaque, tache
		local envergure, corde = 4.4, 2.6
		cotes(function(sx, cote)
			local cf, taille = membrane(sx, V(sx * (0.5 + envergure / 2), yC + 0.35, -0.55 + corde / 2), envergure, corde, 0.18, 14, false)
			poser("coin", "Aile" .. cote, taille, cf, peauAile)
			poser("coin", "AileBout" .. cote, V(0.24, envergure * 0.36, corde * 0.36), cf * CFrame.new(0, envergure * 0.32, corde * 0.32), vif(Charte.lave))
			local a = (cf * CFrame.new(0, -envergure / 2 + 0.2, corde / 2)).Position
			local b = (cf * CFrame.new(0, envergure / 2, corde / 2)).Position
			segment("PatteAv" .. cote, a, b, 0.3, c)
			poser("cylindre", "Tache" .. cote, V(0.22, 0.9, 0.9), cf * CFrame.new(0, -envergure * 0.12, corde * 0.12), vif(Charte.lave))
		end)

		-- petite queue
		boule("Queue", 0.6, V(0, yC - 0.1, 0.95), c)
		boule("QueueBout", 0.36, V(0, yC - 0.15, 1.4), ombre(c))
	end

	-- Carno : rouge vif, cornes dorées, sourcils froncés, bras minuscules, dos bosselé
	ESPECES.Carno = function()
		local c = vif(Charte.tapis)
		local r = theropode({
			corps = 2.5,
			tete = 2.5,
			epaisseur = 1.1,
			bras = 0.25,
			epaisseurBras = 0.9,
			queue = 2.4,
			leveQueue = 0.3,
			couleur = c,
			ventre = Charte.sable,
			museau = { l = 1.6, h = 0.85, avance = 0.6 },
			dents = 4,
			narines = false,
		})
		local t = r.t
		cotes(function(sx, cote)
			-- losange à moitié enfoncé : une corne triangulaire penchée vers l'extérieur
			piece("bloc", "Corne" .. cote, V(0.75, 0.75, 0.6), t.H + V(sx * t.R * 0.55, t.R * 0.82, t.R * 0.1), vif(Charte.dore), V(0, 0, 45 - 18 * sx))
		end)
		sourcils(t, ombre(ombre(c)))
		for _, dir in ipairs({ V(0, 1, -0.1), V(0, 0.85, 0.5), V(0, 0.5, 0.9) }) do
			boule("Bosse", 0.55, surDos(r, "hanche", dir, 0.08), ombre(c))
		end
	end

	-- Spino : bleu vif, long museau de crocodile, grande voile bicolore à rayons
	ESPECES.Spino = function()
		local c = vif(Charte.raretes.Rare or Charte.gemme)
		local r = theropode({
			corps = 2.5,
			tete = 2.3,
			epaisseur = 1.05,
			bras = 0.8,
			queue = 2.8,
			leveQueue = 0.4,
			couleur = c,
			ventre = Charte.creme,
			museau = { l = 1.0, h = 0.62, avance = 1.7 },
			dents = 4,
		})
		local centre = r.corps.c + V(0, r.D * 0.5, r.D * 0.18)
		disque("Voile", centre, V(1, 0, 0), 3.6, 0.22, vif(Charte.dore))
		disque("Voile", centre + V(0, -0.1, 0), V(1, 0, 0), 2.7, 0.3, vif(Charte.lave))
		for _, a in ipairs({ -50, 0, 50 }) do
			local bout = centre + V(0, math.cos(RAD(a)) * 1.7, math.sin(RAD(a)) * 1.7)
			segment("Rayon", centre, bout, 0.38, ombre(vif(Charte.lave)))
		end
	end

	-- Rex : énorme tête verte, grandes dents et crocs, sourcils froncés, bras ridicules
	ESPECES.Rex = function()
		local c = vif(Charte.jungle)
		local r = theropode({
			corps = 2.6,
			tete = 3.1,
			epaisseur = 1.3,
			bras = 0.3,
			epaisseurBras = 0.8,
			queue = 2.4,
			leveQueue = 0.3,
			couleur = c,
			ventre = Charte.sable,
			museau = { l = 2.0, h = 1.0, avance = 0.8 },
			dents = 4,
			crocs = true,
			ouverture = 18,
		})
		sourcils(r.t, ombre(ombre(c)))
		motifs(r, {
			{ dir = V(0.5, 0.8, 0.25), d = 0.3 },
			{ dir = V(-0.5, 0.8, 0.25), d = 0.3 },
		}, ombre(c))
	end

	-- Mosa : reptile marin turquoise allongé, museau de crocodile, nageoires en pagaie, queue en cœur
	ESPECES.Mosa = function()
		local c = vif(ombre(Charte.gemme))
		local nageoire = vif(Charte.nuit)
		local cCorps = V(0, 1.3, 0)
		boule("Corps", 2.3, cCorps, c)
		boule("Ventre", 2.0, V(0, 1.05, -0.35), Charte.creme)
		tete({
			museau = { l = 1.4, h = 0.62, avance = 1.3 },
			machoire = lumiere(c),
			ouverture = 12,
			dents = 4,
			crocs = true,
		}, V(0, 1.85, -1.75), 2.3, c)
		local cHanche = V(0, 1.2, 1.2)
		boule("Hanche", 1.9, cHanche, c)
		boule("Queue", 1.4, V(0, 1.05, 2.3), c)
		boule("QueueMilieu", 1.0, V(0, 1.0, 3.2), c)
		boule("QueueBout", 0.66, V(0, 1.05, 3.95), c)

		-- nageoires en pagaie, balayées vers l'arrière
		cotes(function(sx, cote)
			local cf, taille = membrane(sx, V(sx * 1.5, 0.6, -0.4), 1.8, 1.2, 0.2, -20, true)
			poser("coin", "PatteAv" .. cote, taille, cf, nageoire)
			cf, taille = membrane(sx, V(sx * 1.25, 0.55, 1.4), 1.3, 0.9, 0.2, -20, true)
			poser("coin", "PatteAr" .. cote, taille, cf, nageoire)
		end)
		-- nageoire caudale en cœur et aileron dorsal
		disque("NageoireQueue", V(0, 1.9, 4.5), V(1, 0, 0), 1.3, 0.2, nageoire)
		disque("NageoireQueue", V(0, 0.7, 4.4), V(1, 0, 0), 1.0, 0.2, nageoire)
		piece("coin", "Aileron", V(0.26, 1.1, 1.5), V(0, 2.85, 0.6), nageoire)

		-- bandes claires sur le dos
		local clair = lumiere(lumiere(c))
		tache("Tache", cCorps, 2.3, V(0.6, 0.8, 0.1), 0.7, clair)
		tache("Tache", cCorps, 2.3, V(-0.6, 0.8, 0.1), 0.7, clair)
		tache("Tache", cHanche, 1.9, V(0, 1, 0.3), 0.7, clair)
	end

	-- Giga : colosse de pierre claire, regard, sourcils et épines divins lumineux
	ESPECES.Giga = function()
		local divin = Charte.raretes.Divin or Charte.gemme
		local c = lumiere(lumiere(Charte.pierre))
		local r = theropode({
			corps = 2.6,
			tete = 2.8,
			epaisseur = 1.25,
			bras = 0.5,
			queue = 2.6,
			leveQueue = 0.3,
			couleur = c,
			ventre = lumiere(c),
			couleurBout = ombre(c),
			museau = { l = 1.9, h = 0.95, avance = 0.8 },
			dents = 4,
			narines = false,
			iris = divin,
			irisNeon = true,
		})
		sourcils(r.t, divin, NEON)
		local epines = {
			{ dir = V(0, 1, -0.1), h = 1.0 },
			{ dir = V(0, 0.95, 0.4), h = 1.3 },
			{ dir = V(0, 0.65, 0.8), h = 1.1 },
			{ dir = V(0, 0.2, 1), h = 0.8 },
		}
		for _, ep in ipairs(epines) do
			local p = surDos(r, "hanche", ep.dir, 0.15)
			piece("coin", "Epine", V(0.4, ep.h, ep.h * 0.9), p + V(0, ep.h * 0.3, 0), divin, nil, NEON)
		end
		local corps = courant.modele:FindFirstChild("Corps")
		if corps then
			Outils.lumiere(corps, { genre = "Point", Range = 12, Brightness = 1.2, Color = divin })
		end
	end

	-- Cosmosaure : secret cosmique violet, taches et bout de queue lumineux, étoiles en orbite
	ESPECES.Cosmosaure = function()
		local c = vif(Charte.violet)
		local r = theropode({
			corps = 2.6,
			tete = 2.8,
			epaisseur = 1.2,
			bras = 0.6,
			queue = 2.6,
			leveQueue = 0.7,
			couleur = c,
			ventre = lumiere(Charte.gemme),
			couleurBout = Charte.gemme,
			extraBout = NEON,
			museau = { l = 1.7, h = 0.85, avance = 0.7 },
			dents = 2,
			narines = false,
			iris = Charte.gemme,
			irisNeon = true,
		})
		motifs(r, {
			{ dir = V(0, 0.95, 0.3), d = 0.26 },
			{ dir = V(0.6, 0.7, 0.2), d = 0.2 },
			{ dir = V(-0.6, 0.7, 0.2), d = 0.2 },
		}, Charte.gemme, NEON)
		-- étoiles à quatre branches (deux barres croisées) et une petite lune ronde
		local yE = r.yC + r.D / 2
		local etoiles = {
			{ pos = V(-2.4, yE + 2.0, 0.6), taille = 1.0, couleur = vif(Charte.dore) },
			{ pos = V(2.3, yE + 1.5, 0.2), taille = 0.8, couleur = BLANC },
		}
		for _, et in ipairs(etoiles) do
			piece("bloc", "Etoile", V(0.25, et.taille * 1.6, 0.25), et.pos, et.couleur, V(0, 0, 45), NEON)
			piece("bloc", "Etoile", V(0.25, et.taille * 1.6, 0.25), et.pos, et.couleur, V(0, 0, -45), NEON)
		end
		boule("Etoile", 0.5, V(0.4, yE + 2.8, 2.2), Charte.gemme, NEON)

		-- halo violet autour du corps
		local corps = courant.modele:FindFirstChild("Corps")
		if corps then
			Outils.lumiere(corps, { genre = "Point", Range = 14, Brightness = 1.5, Color = Charte.violet })
		end
	end

	-- ===== fabrication =====
	local ORDRE = { "Compy", "Raptor", "Dilopho", "Ptero", "Carno", "Spino", "Rex", "Mosa", "Giga", "Cosmosaure" }

	local function fabriquer(espece, recette)
		local infos = E.especes[espece]
		local ancien = dossierDinos:FindFirstChild(espece)
		if ancien then
			ancien:Destroy()
		end
		local modele = Instance.new("Model")
		modele.Name = espece
		courant.modele = modele
		courant.s = (infos and tonumber(infos.taille)) or 1
		courant.compte = 0

		local ok, err = pcall(recette)
		local corps = modele:FindFirstChild("Corps")
		if not ok or not corps then
			modele:Destroy()
			warn("[Dino] gabarit « " .. espece .. " » non construit : " .. tostring(err))
			return
		end

		-- pivot au sol sous le Corps, regard vers -Z
		modele.PrimaryPart = corps
		local centre = corps.Position
		corps.PivotOffset = CFrame.new(-centre.X, -centre.Y, -centre.Z)
		modele:SetAttribute("Espece", espece)
		if infos and infos.famille then
			modele:SetAttribute("Famille", infos.famille)
		end
		modele.Parent = dossierDinos
	end

	local faites = {}
	for _, espece in ipairs(ORDRE) do
		local infos = E.especes[espece]
		if infos and ESPECES[espece] then
			fabriquer(espece, ESPECES[espece])
			faites[espece] = true
		end
	end

	-- une espèce carnivore ajoutée à l'équilibrage sans recette : raptor chibi teinté par sa rareté
	for espece, infos in pairs(E.especes) do
		if infos.famille == "Carnivore" and not faites[espece] then
			local teinte = vif(Charte.raretes[infos.rarete] or Charte.terre)
			fabriquer(espece, function()
				local r = theropode({
					corps = 2.4,
					tete = 2.4,
					bras = 0.6,
					queue = 2.4,
					leveQueue = 0.4,
					couleur = teinte,
					ventre = Charte.creme,
					museau = { l = 1.2, h = 0.72, avance = 0.8 },
					dents = 2,
				})
				motifs(r, {
					{ dir = V(0.5, 0.8, 0.2), d = 0.26 },
					{ dir = V(-0.5, 0.8, 0.2), d = 0.26 },
				}, ombre(teinte))
			end)
		end
	end

	courant.modele = nil
end

return M
