-- Constructeur DinosCarnivores : gabarits des 10 espèces de la famille « Carnivore »
-- (carnivores, volant et marin), rangés dans ServerStorage.Dino.Dinos.
-- Style « simulateur » chibi : grosse tête, très gros yeux brillants tournés vers l'avant,
-- couleurs saturées, grandes dents blanches rigolotes, pattes courtes, silhouettes lisibles de loin.
-- Chaque gabarit : pivot au sol sous le dino, regard vers -Z local, PrimaryPart = « Corps », au plus 30 parts.
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
	local SANS_OMBRE = { CastShadow = false }

	-- tête chibi : gros crâne, museau court, bouche ouverte en sourire, grandes dents blanches
	-- sur l'avant, énormes yeux tournés vers l'avant avec pupille noire et reflet blanc.
	-- o : pos (centre du crâne), crane, museau, couleur, machoire, dents, oeil (multiplicateur),
	--     pupille, pupilleNeon, joues (bool)
	local function tete(o)
		local P, T, Mu = o.pos, o.crane, o.museau
		local couleur = o.couleur
		piece("bloc", "Tete", T, P, couleur)

		-- museau devant le crâne, dans sa moitié basse
		local yMu = P.Y - T.Y / 2 + Mu.Y / 2 + T.Y * 0.06
		local zMu = P.Z - T.Z / 2 - Mu.Z / 2 + 0.1
		piece("bloc", "Museau", Mu, V(0, yMu, zMu), couleur)

		-- grandes dents : une rangée bien visible sur l'avant du museau
		local n = o.dents or 0
		local pasDent = (Mu.X * 0.8) / math.max(n, 1)
		local d = math.min(0.5, pasDent * 0.75)
		local hD = d * 1.25

		-- mâchoire inférieure grande ouverte et intérieur de la bouche
		local basMu = yMu - Mu.Y / 2
		local ecart = math.max(Mu.Y * 0.45, hD * 0.9)
		local hJ = Mu.Y * 0.5
		piece("bloc", "Machoire", V(Mu.X * 0.9, hJ, Mu.Z + T.Z * 0.45), V(0, basMu - ecart - hJ / 2, zMu + T.Z * 0.22), o.machoire or ombre(couleur))
		piece("bloc", "Bouche", V(Mu.X * 0.8, ecart + 0.1, Mu.Z * 0.9), V(0, basMu - ecart / 2, zMu + 0.1), INTERIEUR_BOUCHE, nil, SANS_OMBRE)

		if n > 0 then
			local zDent = zMu - Mu.Z / 2 + d * 0.5 + 0.03
			for i = 1, n do
				local x = (i - (n + 1) / 2) * pasDent
				piece("bloc", "Dent", V(d, hD, d), V(x, basMu - hD / 2 + 0.06, zDent), BLANC, nil, SANS_OMBRE)
			end
		end

		-- énormes yeux sur l'avant du crâne, au-dessus du museau
		local e = T.X * 0.48 * (o.oeil or 1)
		local xO = T.X * 0.27
		local yO = P.Y + T.Y * 0.22
		local zO = P.Z - T.Z / 2 + e * 0.15
		paire("boule", "Oeil", V(e, e, e), V(xO, yO, zO), BLANC)
		local extraPupille = SANS_OMBRE
		if o.pupilleNeon then
			extraPupille = { Material = Enum.Material.Neon, CastShadow = false }
		end
		local p = e * 0.55
		local xP = xO - e * 0.05
		local zP = zO - e * 0.25
		paire("boule", "Pupille", V(p, p, p), V(xP, yO, zP), o.pupille or NOIR, nil, extraPupille)
		-- petit reflet blanc qui fait « briller » le regard
		local rf = e * 0.2
		paire("boule", "Reflet", V(rf, rf, rf), V(xP + e * 0.1, yO + e * 0.12, zP - e * 0.2), BLANC, nil, SANS_OMBRE)

		-- joues roses (espèces les plus mignonnes)
		if o.joues then
			paire("bloc", "Joue", V(0.1, e * 0.3, e * 0.5), V(T.X / 2 + 0.03, yO - e * 0.6, zO + e * 0.2), ROSE_JOUE, nil, SANS_OMBRE)
		end

		return { yMu = yMu, zMu = zMu, basMu = basMu, xO = xO, yO = yO, zO = zO, e = e }
	end

	-- sourcils épais au-dessus des yeux (regard de méchant rigolo)
	local function sourcils(r, couleur, extra)
		local y = r.tete
		paire("bloc", "Sourcil", V(y.e * 0.95, y.e * 0.24, y.e * 0.5), V(y.xO, y.yO + y.e * 0.6, y.zO - y.e * 0.05), couleur, V(0, 0, 15), extra)
	end

	-- corps de théropode chibi (bipède trapu) ; renvoie les repères utiles aux détails de l'espèce
	-- o : corps, jambe, epaisseur, cou, bras, queue, couleur, ventre, crane, museau, dents, oeil...
	local function theropode(o)
		local C = o.corps
		local couleur = o.couleur
		local jambe = o.jambe or 1.5
		local ep = o.epaisseur or 1
		local yCorps = 0.4 + jambe + C.Y / 2 - 0.5
		local xJ = C.X / 2 - 0.45 * ep

		-- pattes arrière courtes et gros pieds
		paire("bloc", "Pied", V(1.1 * ep, 0.45, 1.5 * ep), V(xJ, 0.225, -0.15), ombre(couleur))
		paire("bloc", "PatteAr", V(0.95 * ep, jambe, 1.1 * ep), V(xJ, 0.4 + jambe / 2, 0.25), couleur)

		-- corps trapu et plastron clair
		piece("bloc", "Corps", C, V(0, yCorps, 0), couleur)
		piece("bloc", "Ventre", V(C.X * 0.8, C.Y * 0.65, 0.2), V(0, yCorps - C.Y * 0.08, -C.Z / 2 - 0.05), o.ventre or Charte.creme, nil, o.extraVentre)

		-- cou court et grosse tête posée presque sur le corps
		local T = o.crane
		local yT = yCorps + C.Y * 0.5 + (o.cou or 0.2) + T.Y * 0.3
		local zT = -C.Z / 2 - T.Z * 0.2
		local hCou = yT - yCorps
		piece("bloc", "Cou", V(T.X * 0.6, hCou, T.Z * 0.6), V(0, yCorps + hCou / 2, -C.Z / 2 + 0.2 - T.Z * 0.1), couleur)
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
			joues = o.joues,
		})

		-- petits bras tendus vers l'avant et le bas
		local bras = o.bras or 0.8
		local eb = 0.4 * (o.epaisseurBras or 1)
		paire("bloc", "PatteAv", V(eb, eb, bras), V(C.X / 2 - 0.1, yCorps - C.Y * 0.12, -C.Z / 2 - bras * 0.3), couleur, V(-35, 0, 0))

		-- queue courte et dodue en deux tronçons
		local q = o.queue or 2.0
		local yQ = yCorps - C.Y * 0.05
		piece("bloc", "Queue", V(C.X * 0.62, C.Y * 0.58, q), V(0, yQ, C.Z / 2 + q / 2 - 0.4), couleur, V(8, 0, 0))
		piece("bloc", "QueueBout", V(C.X * 0.38, C.Y * 0.36, q * 0.75), V(0, yQ - q * 0.2, C.Z / 2 + q * 1.25 - 0.5), o.couleurBout or couleur, V(14, 0, 0), o.extraBout)

		return {
			yCorps = yCorps,
			C = C,
			yT = yT,
			zT = zT,
			T = T,
			xJ = xJ,
			ep = ep,
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

	-- Compy : petit chapardeur vert pomme, énorme tête, joues roses
	ESPECES.Compy = function()
		local couleur = vif(Charte.herbe)
		local r = theropode({
			corps = V(1.8, 1.7, 2.4),
			jambe = 1.3,
			epaisseur = 0.9,
			cou = 0.1,
			bras = 0.7,
			queue = 1.8,
			couleur = couleur,
			ventre = Charte.creme,
			crane = V(2.4, 2.2, 2.2),
			museau = V(1.4, 0.6, 0.8),
			dents = 2,
			oeil = 1.05,
			joues = true,
		})
		rayures(r, 2, vif(Charte.jungle))
		-- petite crête dorée
		piece("coin", "Crete", V(0.3, 0.7, 1.3), V(0, r.yT + r.T.Y / 2 + 0.3, r.zT + 0.2), vif(Charte.dore))
	end

	-- Raptor : orange caramel rayé, plumes rouges et griffe en faucille
	ESPECES.Raptor = function()
		local couleur = vif(Charte.terre)
		local r = theropode({
			corps = V(2.0, 1.8, 2.8),
			jambe = 1.5,
			epaisseur = 0.9,
			cou = 0.2,
			bras = 1.0,
			queue = 2.4,
			couleur = couleur,
			ventre = Charte.sable,
			crane = V(2.2, 2.0, 2.2),
			museau = V(1.3, 0.7, 1.1),
			dents = 2,
		})
		rayures(r, 2, ombre(ombre(couleur)))
		-- plumes sur la tête
		local rouge = vif(Charte.tapis)
		piece("bloc", "Plume", V(0.3, 1.1, 0.55), V(0, r.yT + r.T.Y / 2 + 0.35, r.zT + 0.2), rouge, V(-25, 0, 0))
		piece("bloc", "Plume", V(0.3, 0.85, 0.55), V(0, r.yT + r.T.Y / 2 + 0.2, r.zT + 0.8), rouge, V(-40, 0, 0))
		-- griffes en faucille au bout des pieds
		paire("coin", "Griffe", V(0.3, 0.6, 0.6), V(r.xJ, 0.55, -0.15 - 0.75 * r.ep - 0.2), BLANC)
	end

	-- Dilopho : jaune vif, double crête rouge et collerette déployée derrière la tête
	ESPECES.Dilopho = function()
		local r = theropode({
			corps = V(2.2, 2.0, 3.0),
			jambe = 1.5,
			cou = 0.3,
			queue = 2.2,
			couleur = vif(Charte.dore),
			ventre = Charte.creme,
			crane = V(2.3, 2.0, 2.3),
			museau = V(1.3, 0.6, 1.0),
			dents = 2,
		})
		-- les deux crêtes
		paire("bloc", "Crete", V(0.25, 1.0, 1.8), V(r.T.X * 0.25, r.yT + r.T.Y / 2 + 0.35, r.zT - 0.1), vif(Charte.alerte))
		-- collerette : quatre grands pétales en éventail derrière la tête
		local angles = { -120, -60, 60, 120 }
		local centre = V(0, r.yT - 0.2, r.zT + r.T.Z * 0.45)
		local rayon = r.T.X * 0.7
		for i, a in ipairs(angles) do
			local rad = math.rad(a)
			local couleur = vif(Charte.lave)
			if i % 2 == 0 then
				couleur = vif(Charte.alerte)
			end
			local pos = centre + V(-math.sin(rad) * rayon, math.cos(rad) * rayon, 0)
			piece("bloc", "Collerette", V(1.0, 2.2, 0.15), pos, couleur, V(0, 0, a))
		end
	end

	-- Ptéro : reptile volant rose, grandes ailes jaunes déployées, bec et crête
	ESPECES.Ptero = function()
		local couleur = vif(Charte.alerte)
		local membrane = vif(Charte.sable)
		-- pattes courtes et pieds
		paire("bloc", "Pied", V(0.7, 0.3, 0.9), V(0.6, 0.15, -0.1), ombre(couleur))
		paire("bloc", "PatteAr", V(0.45, 1.0, 0.45), V(0.6, 0.8, 0.1), couleur)
		-- corps
		local yCorps = 2.0
		piece("bloc", "Corps", V(1.8, 1.7, 2.2), V(0, yCorps, 0), couleur)
		piece("bloc", "Ventre", V(1.4, 1.1, 0.2), V(0, yCorps - 0.1, -1.15), Charte.creme)
		piece("bloc", "Cou", V(0.8, 0.8, 0.8), V(0, 2.9, -0.7), couleur)
		-- grosse tête à bec
		local yT, zT = 3.7, -1.2
		tete({
			pos = V(0, yT, zT),
			crane = V(1.9, 1.7, 1.8),
			museau = V(0.7, 0.5, 1.6),
			couleur = couleur,
			machoire = vif(Charte.dore),
			dents = 2,
		})
		-- crête vers l'arrière
		piece("bloc", "Crete", V(0.3, 0.9, 2.0), V(0, yT + 0.85, zT + 1.3), vif(Charte.dore), V(-20, 0, 0))
		-- ailes : membrane, bout d'aile et bras osseux sur le bord d'attaque
		paire("bloc", "Aile", V(4.0, 0.2, 2.0), V(2.8, 2.5, 0.2), membrane, V(0, 0, 12))
		paire("bloc", "AileBout", V(2.2, 0.2, 1.3), V(5.5, 3.1, 0), membrane, V(0, 0, 20))
		paire("bloc", "PatteAv", V(4.2, 0.4, 0.4), V(2.8, 2.55, -0.8), couleur, V(0, 0, 12))
		-- petite queue
		piece("bloc", "Queue", V(0.45, 0.45, 1.1), V(0, 1.9, 1.5), couleur, V(10, 0, 0))
		-- taches sur les ailes
		paire("bloc", "Tache", V(1.1, 0.25, 0.8), V(3.2, 2.6, 0.5), vif(Charte.lave), V(0, 0, 12))
	end

	-- Carno : rouge vif, cornes au-dessus des yeux, gros crocs, bras minuscules, dos bosselé
	ESPECES.Carno = function()
		local couleur = vif(Charte.tapis)
		local r = theropode({
			corps = V(2.4, 2.2, 3.0),
			jambe = 1.5,
			epaisseur = 1.1,
			cou = 0.2,
			bras = 0.45,
			queue = 2.2,
			couleur = couleur,
			ventre = Charte.sable,
			crane = V(2.5, 2.2, 2.4),
			museau = V(1.6, 0.8, 0.9),
			dents = 2,
		})
		-- cornes
		paire("coin", "Corne", V(0.55, 1.1, 0.8), V(r.T.X * 0.3, r.yT + r.T.Y / 2 + 0.5, r.zT), vif(Charte.dore), V(0, 0, -20))
		sourcils(r, ombre(ombre(couleur)))
		-- bosses le long du dos
		for i = 1, 3 do
			piece("bloc", "Bosse", V(0.6, 0.45, 0.6), V(0, r.yCorps + r.C.Y / 2 + 0.15, -1.0 + (i - 1) * 1.0), ombre(couleur), V(0, 45, 0))
		end
	end

	-- Spino : bleu vif, museau de crocodile et grande voile orange et jaune
	ESPECES.Spino = function()
		local r = theropode({
			corps = V(2.4, 2.2, 3.4),
			jambe = 1.5,
			epaisseur = 1.05,
			cou = 0.3,
			bras = 1.0,
			queue = 2.4,
			couleur = vif(Charte.raretes.Rare or Charte.gemme),
			ventre = Charte.creme,
			crane = V(2.3, 2.0, 2.4),
			museau = V(1.1, 0.6, 1.8),
			dents = 2,
		})
		-- voile : lames de hauteurs croissantes puis décroissantes
		local hauteurs = { 1.2, 2.0, 2.6, 2.6, 2.0, 1.2 }
		local n = #hauteurs
		local haut = r.yCorps + r.C.Y / 2 - 0.2
		for i, h in ipairs(hauteurs) do
			local c = vif(Charte.lave)
			if i % 2 == 0 then
				c = vif(Charte.dore)
			end
			local z = -r.C.Z / 2 + 0.4 + (r.C.Z - 0.8) * (i - 1) / (n - 1)
			piece("bloc", "Voile", V(0.3, h, 0.7), V(0, haut + h / 2, z), c)
		end
	end

	-- Rex : énorme tête verte, quatre grandes dents, sourcils froncés, bras ridicules
	ESPECES.Rex = function()
		local couleur = vif(Charte.jungle)
		local r = theropode({
			corps = V(2.8, 2.6, 3.2),
			jambe = 1.7,
			epaisseur = 1.3,
			cou = 0.1,
			bras = 0.5,
			epaisseurBras = 0.8,
			queue = 2.2,
			couleur = couleur,
			ventre = Charte.sable,
			crane = V(3.0, 2.6, 2.8),
			museau = V(2.2, 1.0, 1.3),
			dents = 4,
		})
		rayures(r, 2, ombre(couleur))
		sourcils(r, ombre(ombre(couleur)))
	end

	-- Mosa : reptile marin turquoise, grosse tête ronde, quatre nageoires et queue en croissant
	ESPECES.Mosa = function()
		local couleur = vif(ombre(Charte.gemme))
		local nageoire = vif(Charte.nuit)
		local yCorps = 1.5
		piece("bloc", "Corps", V(2.4, 1.8, 3.6), V(0, yCorps, 0), couleur)
		piece("bloc", "Ventre", V(2.5, 0.6, 3.2), V(0, 0.95, 0), Charte.creme)
		-- grosse tête de crocodile marin
		tete({
			pos = V(0, 2.0, -2.6),
			crane = V(2.4, 1.9, 2.2),
			museau = V(1.5, 0.6, 1.2),
			couleur = couleur,
			machoire = lumiere(couleur),
			dents = 4,
		})
		-- nageoires
		paire("bloc", "PatteAv", V(1.9, 0.25, 0.9), V(1.9, 0.8, -0.9), nageoire, V(0, -25, -15))
		paire("bloc", "PatteAr", V(1.4, 0.25, 0.7), V(1.7, 0.8, 1.2), nageoire, V(0, -25, -15))
		-- queue et nageoire caudale
		piece("bloc", "Queue", V(1.4, 1.1, 2.4), V(0, 1.4, 3.0), couleur)
		piece("bloc", "QueueBout", V(0.8, 0.7, 1.6), V(0, 1.4, 4.8), couleur)
		piece("bloc", "NageoireQueue", V(0.25, 1.8, 0.8), V(0, 2.2, 5.8), nageoire, V(30, 0, 0))
		piece("bloc", "NageoireQueue", V(0.25, 1.2, 0.7), V(0, 0.8, 5.8), nageoire, V(-30, 0, 0))
		-- aileron dorsal et bandes claires sur le dos
		piece("coin", "Aileron", V(0.3, 1.2, 1.6), V(0, yCorps + 0.9 + 0.6, 0.2), nageoire)
		for i = 1, 2 do
			piece("bloc", "Rayure", V(2.5, 0.3, 0.5), V(0, yCorps + 0.8, -0.9 + (i - 1) * 1.8), lumiere(couleur))
		end
	end

	-- Giga : colosse de pierre claire, épines, sourcils et regard divins lumineux
	ESPECES.Giga = function()
		local divin = Charte.raretes.Divin or Charte.gemme
		local couleur = lumiere(Charte.pierre)
		local r = theropode({
			corps = V(3.0, 2.8, 3.6),
			jambe = 1.8,
			epaisseur = 1.35,
			cou = 0.1,
			bras = 0.7,
			queue = 2.4,
			couleur = couleur,
			ventre = lumiere(couleur),
			crane = V(3.0, 2.6, 2.8),
			museau = V(2.1, 0.9, 1.4),
			dents = 2,
			pupille = divin,
			pupilleNeon = true,
		})
		-- épines lumineuses sur le dos
		for i = 1, 4 do
			local h = 1.0
			if i == 2 or i == 3 then
				h = 1.4
			end
			piece("coin", "Epine", V(0.4, h, 1.0), V(0, r.yCorps + r.C.Y / 2 + h / 2 - 0.1, -1.4 + (i - 1) * 0.95), divin, nil, NEON)
		end
		-- sourcils lumineux
		sourcils(r, divin, NEON)
	end

	-- Cosmosaure : secret cosmique violet vif, bandes de gemme lumineuses et étoiles en orbite
	ESPECES.Cosmosaure = function()
		local couleur = vif(Charte.violet)
		local r = theropode({
			corps = V(2.8, 2.6, 3.6),
			jambe = 1.7,
			epaisseur = 1.25,
			cou = 0.2,
			bras = 0.7,
			queue = 2.4,
			couleur = couleur,
			couleurTete = couleur,
			ventre = Charte.gemme,
			extraVentre = NEON,
			couleurBout = Charte.gemme,
			extraBout = NEON,
			crane = V(2.9, 2.5, 2.7),
			museau = V(1.8, 0.8, 1.3),
			dents = 2,
			pupille = Charte.gemme,
			pupilleNeon = true,
		})
		rayures(r, 2, Charte.gemme, NEON)
		-- étoiles à quatre branches (deux barres croisées) et une petite étoile ronde
		local yE = r.yCorps + r.C.Y / 2
		local etoiles = {
			{ pos = V(-2.2, yE + 2.2, 0.8), taille = 1.0, couleur = vif(Charte.dore) },
			{ pos = V(2.2, yE + 1.6, 0.2), taille = 0.8, couleur = BLANC },
		}
		for _, et in ipairs(etoiles) do
			local t = et.taille
			piece("bloc", "Etoile", V(0.25, t * 1.6, 0.25), et.pos, et.couleur, V(0, 0, 45), NEON)
			piece("bloc", "Etoile", V(0.25, t * 1.6, 0.25), et.pos, et.couleur, V(0, 0, -45), NEON)
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

	-- une espèce carnivore ajoutée à l'équilibrage sans recette : raptor chibi teinté par sa rareté
	for espece, infos in pairs(E.especes) do
		if infos.famille == "Carnivore" and not faites[espece] then
			local teinte = vif(Charte.raretes[infos.rarete] or Charte.terre)
			fabriquer(espece, function()
				local r = theropode({
					corps = V(2.2, 2.0, 3.0),
					jambe = 1.5,
					couleur = teinte,
					ventre = Charte.creme,
					crane = V(2.3, 2.0, 2.3),
					museau = V(1.3, 0.7, 1.1),
					dents = 2,
				})
				rayures(r, 2, ombre(teinte))
			end)
		end
	end

	courant.modele = nil
end

return M
