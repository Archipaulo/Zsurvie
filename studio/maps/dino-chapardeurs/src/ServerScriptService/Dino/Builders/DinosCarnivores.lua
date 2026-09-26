-- Constructeur DinosCarnivores : gabarits des 10 espèces de la famille « Carnivore »
-- (carnivores, volant et marin), rangés dans ServerStorage.Dino.Dinos.
-- Style jouet en blocs. Chaque gabarit : pivot au sol sous le dino, regard vers -Z local,
-- PrimaryPart = « Corps », au plus 30 parts.
local M = {}

local BUDGET = 30 -- parts maximum par gabarit

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

	-- gabarit en cours de construction
	local courant = { modele = nil, s = 1, compte = 0 }

	local FORMES = {
		bloc = Outils.bloc,
		boule = Outils.boule,
		coin = Outils.coin,
		cylindre = Outils.cylindre,
	}

	-- une part du gabarit ; taille et position en unités « taille 1 », rotation en degrés
	local function piece(forme, nom, taille, pos, couleur, rot, extra)
		if courant.compte >= BUDGET then
			return nil
		end
		local s = courant.s
		local cf = CFrame.new(pos * s)
		if rot then
			cf = cf * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
		local props = {
			Name = nom,
			Size = taille * s,
			CFrame = cf,
			Color = couleur,
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

	-- deux parts symétriques : G du côté -X (gauche du dino qui regarde vers -Z), D du côté +X
	local function paire(forme, nom, taille, pos, couleur, rot, extra)
		local x = math.abs(pos.X)
		local rotG, rotD = nil, nil
		if rot then
			rotG = V(rot.X, -rot.Y, -rot.Z)
			rotD = rot
		end
		piece(forme, nom .. "G", taille, V(-x, pos.Y, pos.Z), couleur, rotG, extra)
		piece(forme, nom .. "D", taille, V(x, pos.Y, pos.Z), couleur, rotD, extra)
	end

	local NEON = { Material = Enum.Material.Neon }

	-- tête : crâne, museau, mâchoire ouverte, bouche, dents, gros yeux
	-- o : pos (centre du crâne), crane, museau, couleur, machoire, dents, oeil, pupille, pupilleNeon, couleurDents
	local function tete(o)
		local P, T, Mu = o.pos, o.crane, o.museau
		local couleur = o.couleur
		piece("bloc", "Tete", T, P, couleur)

		-- museau devant le crâne, un peu plus bas
		local yMu = P.Y - T.Y / 2 + Mu.Y / 2 + T.Y * 0.15
		local zMu = P.Z - T.Z / 2 - Mu.Z / 2 + 0.1
		piece("bloc", "Museau", Mu, V(0, yMu, zMu), couleur)

		-- mâchoire inférieure entrouverte et intérieur de la bouche
		local basMu = yMu - Mu.Y / 2
		local ecart = Mu.Y * 0.35
		local hJ = Mu.Y * 0.5
		piece("bloc", "Machoire", V(Mu.X * 0.9, hJ, Mu.Z + T.Z * 0.45), V(0, basMu - ecart - hJ / 2, zMu + T.Z * 0.22), o.machoire or ombre(couleur))
		piece("bloc", "Bouche", V(Mu.X * 0.8, ecart + 0.1, Mu.Z * 0.9), V(0, basMu - ecart / 2, zMu + 0.1), ombre(Charte.alerte))

		-- dents plantées sous le museau, alternées gauche / droite de l'avant vers l'arrière
		local n = o.dents or 0
		if n > 0 then
			local d = math.min(0.32, Mu.X * 0.3)
			local rangs = math.ceil(n / 2)
			local pas = (Mu.Z * 0.75) / rangs
			local avant = zMu - Mu.Z / 2 + d * 0.8
			for i = 1, n do
				local cote = -1
				if i % 2 == 0 then
					cote = 1
				end
				local rang = math.ceil(i / 2)
				local x = cote * (Mu.X / 2 - d * 0.6)
				piece("bloc", "Dent", V(d, d, d), V(x, basMu - d * 0.25, avant + (rang - 1) * pas), o.couleurDents or Charte.creme, V(45, 0, 0))
			end
		end

		-- gros yeux sur les côtés du crâne
		local e = o.oeil or 0.8
		local xO = T.X / 2 - e * 0.2
		local yO = P.Y + T.Y * 0.2
		local zO = P.Z - T.Z * 0.15
		paire("boule", "Oeil", V(e, e, e), V(xO, yO, zO), Charte.creme)
		local extraPupille = nil
		if o.pupilleNeon then
			extraPupille = NEON
		end
		paire("boule", "Pupille", V(e * 0.55, e * 0.55, e * 0.55), V(xO + e * 0.3, yO + e * 0.05, zO - e * 0.18), o.pupille or Charte.encre, nil, extraPupille)

		return { yMu = yMu, zMu = zMu, basMu = basMu }
	end

	-- corps de théropode (bipède) ; renvoie les repères utiles aux détails de l'espèce
	-- o : corps, jambe, epaisseur, cou, bras, queue, couleur, ventre, crane, museau, dents, oeil...
	local function theropode(o)
		local C = o.corps
		local couleur = o.couleur
		local jambe = o.jambe or 2.2
		local ep = o.epaisseur or 1
		local yCorps = 0.4 + jambe + C.Y / 2 - 0.5
		local xJ = C.X / 2 - 0.45 * ep

		-- pattes arrière et pieds
		paire("bloc", "Pied", V(1.0 * ep, 0.4, 1.6 * ep), V(xJ, 0.2, -0.1), ombre(couleur))
		paire("bloc", "PatteAr", V(0.9 * ep, jambe, 1.2 * ep), V(xJ, 0.4 + jambe / 2, 0.3), couleur)

		-- corps et plastron
		piece("bloc", "Corps", C, V(0, yCorps, 0), couleur)
		piece("bloc", "Ventre", V(C.X * 0.8, C.Y * 0.6, 0.2), V(0, yCorps - C.Y * 0.1, -C.Z / 2 - 0.05), o.ventre or Charte.creme, nil, o.extraVentre)

		-- cou et tête
		local T = o.crane
		local yT = yCorps + C.Y * 0.5 + (o.cou or 0.5) + T.Y * 0.3
		local zT = -C.Z / 2 - T.Z * 0.25
		local hCou = yT - yCorps
		piece("bloc", "Cou", V(T.X * 0.7, hCou, T.Z * 0.7), V(0, yCorps + hCou / 2, -C.Z / 2 + 0.2 - T.Z * 0.1), couleur)
		local infosTete = tete({
			pos = V(0, yT, zT),
			crane = T,
			museau = o.museau,
			couleur = o.couleurTete or couleur,
			machoire = o.machoire,
			dents = o.dents,
			oeil = o.oeil,
			pupille = o.pupille,
			pupilleNeon = o.pupilleNeon,
			couleurDents = o.couleurDents,
		})

		-- petits bras tendus vers l'avant et le bas
		local bras = o.bras or 1.0
		local eb = 0.35 * (o.epaisseurBras or 1)
		paire("bloc", "PatteAv", V(eb, eb, bras), V(C.X / 2 - 0.15, yCorps - C.Y * 0.15, -C.Z / 2 - bras * 0.3), couleur, V(-35, 0, 0))

		-- queue en deux tronçons qui descendent
		local q = o.queue or 2.6
		local yQ = yCorps + C.Y * 0.05
		piece("bloc", "Queue", V(C.X * 0.6, C.Y * 0.55, q), V(0, yQ, C.Z / 2 + q / 2 - 0.4), couleur, V(8, 0, 0))
		piece("bloc", "QueueBout", V(C.X * 0.35, C.Y * 0.32, q * 0.8), V(0, yQ - q * 0.22, C.Z / 2 + q * 1.3 - 0.5), o.couleurBout or couleur, V(14, 0, 0), o.extraBout)

		return {
			yCorps = yCorps,
			C = C,
			yT = yT,
			zT = zT,
			T = T,
			tete = infosTete,
		}
	end

	-- rayures sur le dos : n bandes en travers du corps
	local function rayures(r, n, couleur, extra)
		local C = r.C
		for i = 1, n do
			local z = -C.Z / 2 + C.Z * (i - 0.5) / n
			piece("bloc", "Rayure", V(C.X + 0.1, 0.3, C.Z / (n * 2.2)), V(0, r.yCorps + C.Y / 2 - 0.1, z), couleur, nil, extra)
		end
	end

	-- ===== les espèces =====
	local ESPECES = {}

	-- Compy : petit chapardeur vert, grosse tête et grands yeux
	ESPECES.Compy = function()
		local r = theropode({
			corps = V(2.0, 1.8, 3.0),
			jambe = 2.0,
			epaisseur = 0.85,
			cou = 0.4,
			queue = 2.6,
			couleur = Charte.herbe,
			ventre = Charte.creme,
			crane = V(1.9, 1.7, 1.9),
			museau = V(1.2, 0.7, 1.0),
			dents = 2,
			oeil = 1.0,
		})
		rayures(r, 3, Charte.jungle)
		-- petite crête
		piece("coin", "Crete", V(0.25, 0.6, 1.2), V(0, r.yT + r.T.Y / 2 + 0.25, r.zT + 0.2), Charte.dore)
	end

	-- Raptor : sable rayé, plumes rouges et griffe en faucille
	ESPECES.Raptor = function()
		local r = theropode({
			corps = V(2.2, 2.0, 3.4),
			jambe = 2.4,
			epaisseur = 0.9,
			cou = 0.5,
			bras = 1.3,
			queue = 3.0,
			couleur = Charte.sable,
			ventre = Charte.creme,
			crane = V(1.6, 1.4, 1.8),
			museau = V(1.2, 0.8, 1.6),
			dents = 4,
			oeil = 0.8,
		})
		rayures(r, 2, Charte.terre)
		-- plumes sur la tête
		piece("bloc", "Plume", V(0.25, 0.9, 0.5), V(0, r.yT + r.T.Y / 2 + 0.3, r.zT + 0.3), Charte.lave, V(-25, 0, 0))
		piece("bloc", "Plume", V(0.25, 0.7, 0.5), V(0, r.yT + r.T.Y / 2 + 0.15, r.zT + 0.8), Charte.lave, V(-40, 0, 0))
		-- griffes en faucille au bout des pieds
		paire("coin", "Griffe", V(0.25, 0.6, 0.6), V(r.C.X / 2 - 0.4, 0.6, -1.0), Charte.creme)
	end

	-- Dilopho : jaune tacheté, double crête et collerette déployée
	ESPECES.Dilopho = function()
		local r = theropode({
			corps = V(2.4, 2.2, 3.6),
			jambe = 2.2,
			cou = 0.7,
			queue = 2.8,
			couleur = Charte.dore,
			ventre = Charte.creme,
			crane = V(1.6, 1.4, 1.8),
			museau = V(1.2, 0.7, 1.4),
			dents = 2,
			oeil = 0.85,
		})
		-- les deux crêtes
		paire("bloc", "Crete", V(0.2, 0.8, 1.8), V(0.4, r.yT + r.T.Y / 2 + 0.3, r.zT - 0.2), Charte.alerte)
		-- collerette : pétales en éventail autour du cou, derrière la tête
		local angles = { -130, -80, -30, 30, 80, 130 }
		local centre = V(0, r.yT - 0.2, r.zT + r.T.Z * 0.3)
		local rayon = 1.35
		for i, a in ipairs(angles) do
			local rad = math.rad(a)
			local couleur = Charte.lave
			if i % 2 == 0 then
				couleur = Charte.dore
			end
			local pos = centre + V(-math.sin(rad) * rayon, math.cos(rad) * rayon, 0)
			piece("bloc", "Collerette", V(0.9, 2.0, 0.15), pos, couleur, V(0, 0, a))
		end
		-- une tache sur le dos
		piece("bloc", "Tache", V(r.C.X + 0.1, 0.3, 1.0), V(0, r.yCorps + r.C.Y / 2 - 0.1, 0.4), Charte.jungle)
	end

	-- Ptéro : reptile volant, grandes ailes déployées, bec et crête
	ESPECES.Ptero = function()
		local couleur = Charte.terre
		local membrane = lumiere(Charte.sable)
		-- pattes et pieds
		paire("bloc", "Pied", V(0.6, 0.3, 0.9), V(0.6, 0.15, -0.1), ombre(couleur))
		paire("bloc", "PatteAr", V(0.4, 1.5, 0.4), V(0.6, 1.0, 0.1), couleur)
		-- corps
		local yCorps = 2.4
		piece("bloc", "Corps", V(1.6, 1.6, 2.4), V(0, yCorps, 0), couleur)
		piece("bloc", "Ventre", V(1.3, 1.0, 0.2), V(0, yCorps - 0.1, -1.25), Charte.creme)
		piece("bloc", "Cou", V(0.7, 1.2, 0.7), V(0, 3.4, -1.0), couleur)
		-- tête à long bec
		local yT, zT = 4.1, -1.5
		tete({
			pos = V(0, yT, zT),
			crane = V(1.2, 1.0, 1.4),
			museau = V(0.6, 0.5, 2.4),
			couleur = couleur,
			machoire = Charte.dore,
			dents = 2,
			oeil = 0.7,
		})
		-- crête vers l'arrière
		piece("bloc", "Crete", V(0.3, 0.7, 2.0), V(0, yT + 0.6, zT + 1.2), Charte.alerte, V(-20, 0, 0))
		-- ailes : membrane, bout d'aile et bras osseux sur le bord d'attaque
		paire("bloc", "Aile", V(4.4, 0.2, 2.2), V(2.9, 3.0, 0.2), membrane, V(0, 0, 12))
		paire("bloc", "AileBout", V(2.4, 0.2, 1.4), V(5.9, 3.65, 0), membrane, V(0, 0, 20))
		paire("bloc", "PatteAv", V(4.6, 0.35, 0.35), V(2.9, 3.05, -0.85), couleur, V(0, 0, 12))
		-- petite queue
		piece("bloc", "Queue", V(0.4, 0.4, 1.3), V(0, 2.3, 1.7), couleur, V(10, 0, 0))
		-- taches sur les ailes
		paire("bloc", "Tache", V(1.2, 0.25, 0.9), V(3.4, 3.1, 0.5), Charte.lave, V(0, 0, 12))
	end

	-- Carno : rouge, cornes au-dessus des yeux, bras minuscules, dos bosselé
	ESPECES.Carno = function()
		local r = theropode({
			corps = V(2.6, 2.4, 3.8),
			jambe = 2.4,
			epaisseur = 1.1,
			cou = 0.5,
			bras = 0.5,
			queue = 2.8,
			couleur = Charte.tapis,
			ventre = Charte.sable,
			crane = V(1.8, 1.6, 1.8),
			museau = V(1.4, 1.0, 1.1),
			dents = 4,
			oeil = 0.8,
			pupille = Charte.encre,
		})
		-- cornes
		paire("coin", "Corne", V(0.45, 1.0, 0.7), V(0.55, r.yT + r.T.Y / 2 + 0.45, r.zT - 0.1), Charte.sable, V(0, 0, -20))
		-- bosses le long du dos
		for i = 1, 3 do
			piece("bloc", "Bosse", V(0.6, 0.4, 0.6), V(0, r.yCorps + r.C.Y / 2 + 0.15, -1.2 + (i - 1) * 1.2), ombre(Charte.tapis), V(0, 45, 0))
		end
	end

	-- Spino : long museau de crocodile et grande voile sur le dos
	ESPECES.Spino = function()
		local couleur = ombre(Charte.gemme)
		local r = theropode({
			corps = V(2.6, 2.4, 4.2),
			jambe = 2.2,
			epaisseur = 1.05,
			cou = 0.6,
			bras = 1.3,
			queue = 3.0,
			couleur = couleur,
			ventre = Charte.creme,
			crane = V(1.5, 1.3, 1.8),
			museau = V(1.0, 0.7, 2.8),
			dents = 4,
			oeil = 0.8,
		})
		-- voile : lames de hauteurs croissantes puis décroissantes
		local hauteurs = { 1.4, 2.4, 3.1, 3.1, 2.4, 1.4 }
		local n = #hauteurs
		local haut = r.yCorps + r.C.Y / 2 - 0.2
		for i, h in ipairs(hauteurs) do
			local c = Charte.lave
			if i % 2 == 0 then
				c = Charte.dore
			end
			local z = -r.C.Z / 2 + 0.4 + (r.C.Z - 0.8) * (i - 1) / (n - 1)
			piece("bloc", "Voile", V(0.3, h, 0.75), V(0, haut + h / 2, z), c)
		end
	end

	-- Rex : grosse tête, dents en série, bras ridicules
	ESPECES.Rex = function()
		local couleur = Charte.jungle
		local r = theropode({
			corps = V(3.0, 2.8, 4.0),
			jambe = 2.6,
			epaisseur = 1.3,
			cou = 0.4,
			bras = 0.6,
			epaisseurBras = 0.8,
			queue = 2.8,
			couleur = couleur,
			ventre = Charte.sable,
			crane = V(2.4, 2.0, 2.4),
			museau = V(2.0, 1.2, 1.8),
			dents = 5,
			oeil = 0.9,
		})
		rayures(r, 3, ombre(couleur))
		-- arcades sourcilières
		paire("bloc", "Sourcil", V(0.6, 0.3, 0.9), V(0.75, r.yT + r.T.Y / 2 + 0.1, r.zT - 0.5), ombre(couleur), V(0, 0, 15))
	end

	-- Mosa : reptile marin allongé, quatre nageoires et queue en croissant
	ESPECES.Mosa = function()
		local couleur = Charte.nuit
		local nageoire = Charte.gemme
		local yCorps = 1.5
		piece("bloc", "Corps", V(2.4, 1.8, 4.2), V(0, yCorps, 0), couleur)
		piece("bloc", "Ventre", V(2.5, 0.6, 3.8), V(0, 0.95, 0), lumiere(Charte.gemme))
		-- tête de crocodile marin
		tete({
			pos = V(0, 1.8, -2.8),
			crane = V(1.8, 1.3, 1.8),
			museau = V(1.3, 0.7, 2.2),
			couleur = couleur,
			machoire = lumiere(Charte.gemme),
			dents = 6,
			oeil = 0.8,
		})
		-- nageoires
		paire("bloc", "PatteAv", V(1.9, 0.2, 0.9), V(1.9, 0.8, -1.1), nageoire, V(0, -25, -15))
		paire("bloc", "PatteAr", V(1.4, 0.2, 0.7), V(1.7, 0.8, 1.4), nageoire, V(0, -25, -15))
		-- queue et nageoire caudale
		piece("bloc", "Queue", V(1.5, 1.2, 3.0), V(0, 1.4, 3.5), couleur)
		piece("bloc", "QueueBout", V(0.8, 0.7, 2.2), V(0, 1.4, 5.9), couleur)
		piece("bloc", "NageoireQueue", V(0.2, 1.8, 0.8), V(0, 2.2, 7.0), nageoire, V(30, 0, 0))
		piece("bloc", "NageoireQueue", V(0.2, 1.2, 0.7), V(0, 0.8, 7.0), nageoire, V(-30, 0, 0))
		-- aileron dorsal et bandes sur le dos
		piece("coin", "Aileron", V(0.25, 1.1, 1.6), V(0, yCorps + 0.9 + 0.55, 0.2), nageoire)
		for i = 1, 2 do
			piece("bloc", "Rayure", V(2.5, 0.3, 0.5), V(0, yCorps + 0.8, -1.4 + (i - 1) * 2.8), lumiere(couleur))
		end
	end

	-- Giga : colosse de pierre, épines et regard divins lumineux
	ESPECES.Giga = function()
		local divin = Charte.raretes.Divin or Charte.gemme
		local couleur = Charte.pierre
		local r = theropode({
			corps = V(3.2, 3.0, 4.4),
			jambe = 2.8,
			epaisseur = 1.35,
			cou = 0.4,
			bras = 0.9,
			queue = 2.8,
			couleur = couleur,
			ventre = lumiere(Charte.pierre),
			crane = V(2.4, 2.0, 2.6),
			museau = V(2.0, 1.1, 2.2),
			dents = 5,
			oeil = 0.9,
			pupille = divin,
			pupilleNeon = true,
		})
		-- épines lumineuses sur le dos
		for i = 1, 4 do
			local h = 1.0
			if i == 2 or i == 3 then
				h = 1.4
			end
			piece("coin", "Epine", V(0.35, h, 1.0), V(0, r.yCorps + r.C.Y / 2 + h / 2 - 0.1, -1.6 + (i - 1) * 1.1), divin, nil, NEON)
		end
		-- arcades lumineuses
		paire("bloc", "Sourcil", V(0.6, 0.25, 1.0), V(0.75, r.yT + r.T.Y / 2 + 0.05, r.zT - 0.5), divin, V(0, 0, 15), NEON)
	end

	-- Cosmosaure : secret cosmique violet, bandes de gemme lumineuses et étoiles en orbite
	ESPECES.Cosmosaure = function()
		local couleur = Charte.violet
		local r = theropode({
			corps = V(3.0, 2.8, 4.4),
			jambe = 2.6,
			epaisseur = 1.25,
			cou = 0.5,
			bras = 0.9,
			queue = 2.8,
			couleur = couleur,
			couleurTete = couleur,
			ventre = Charte.gemme,
			extraVentre = NEON,
			couleurBout = Charte.gemme,
			extraBout = NEON,
			crane = V(2.2, 1.9, 2.4),
			museau = V(1.8, 1.0, 2.0),
			dents = 4,
			couleurDents = Charte.gemme,
			oeil = 0.95,
			pupille = Charte.gemme,
			pupilleNeon = true,
		})
		rayures(r, 2, Charte.gemme, NEON)
		-- étoiles à quatre branches (deux barres croisées) et une petite étoile ronde
		local yE = r.yCorps + r.C.Y / 2
		local etoiles = {
			{ pos = V(-2.0, yE + 2.2, 0.8), taille = 1.0, couleur = Charte.dore },
			{ pos = V(2.0, yE + 1.6, -0.6), taille = 0.8, couleur = Charte.creme },
		}
		for _, et in ipairs(etoiles) do
			local t = et.taille
			piece("bloc", "Etoile", V(0.2, t * 1.6, 0.2), et.pos, et.couleur, V(0, 0, 45), NEON)
			piece("bloc", "Etoile", V(0.2, t * 1.6, 0.2), et.pos, et.couleur, V(0, 0, -45), NEON)
		end
		piece("boule", "Etoile", V(0.5, 0.5, 0.5), V(0.3, yE + 3.0, 2.2), Charte.gemme, nil, NEON)

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

	-- une espèce carnivore ajoutée à l'équilibrage sans recette : raptor recoloré par sa rareté
	for espece, infos in pairs(E.especes) do
		if infos.famille == "Carnivore" and not faites[espece] then
			local teinte = Charte.raretes[infos.rarete] or Charte.terre
			fabriquer(espece, function()
				local r = theropode({
					corps = V(2.4, 2.2, 3.6),
					couleur = teinte,
					ventre = Charte.creme,
					crane = V(1.7, 1.5, 1.9),
					museau = V(1.2, 0.8, 1.4),
					dents = 4,
					oeil = 0.85,
				})
				rayures(r, 2, ombre(teinte))
			end)
		end
	end

	courant.modele = nil
end

return M
