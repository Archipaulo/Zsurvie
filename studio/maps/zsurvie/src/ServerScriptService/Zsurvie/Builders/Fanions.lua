-- Builders/Fanions.lua : guirlandes de petits fanions triangulaires (coins fins) tendues entre des mâts.
-- Prairie : autour du parvis, sans couper le chemin Sud qui mène à la Maison (trouée au milieu
-- des côtés Nord et Sud), hauteur limitée par Plan.hauteurMaxPres.
-- Île du Laboratoire : mâts à r66 de Plan.lobby.origine, en sautant ceux proches du monument.
-- La corde suit une chaînette (points calculés) ; quelques fanions flottent (Outils.animer).
-- Budget : 500 parts.
local M = {}

local BUDGET = 500

-- réglages visuels (décor, pas des chiffres de jeu)
local MARGE_PARVIS = 3.5       -- écart entre le bord du parvis et les mâts (laisse la place aux panneaux et au réverbère Sud)
local DEMI_TROUEE = 4.5        -- demi-largeur laissée libre autour du chemin (axe X = 0)
local RAYON_ILE = 66
local PAS_ANGLE_ILE = 20
local ECART_MONUMENT = 14

local MAT_PRAIRIE = { hauteur = 5.2, flecheCorde = 0.9, espaceFanion = 1.8 }
local MAT_ILE = { hauteur = 8, flecheCorde = 2.2, espaceFanion = 2.6 }

local COTE_MAT = 0.5
local DIAMETRE_BOULE = 0.9
local EPAISSEUR_CORDE = 0.12
local FANION_LARGEUR = 1.1
local FANION_HAUTEUR = 1.3
local FANION_EPAISSEUR = 0.1
local COURBURE_CHAINETTE = 1.4
local SEGMENTS_MAX = 6
local LONGUEUR_SEGMENT = 4
local TOUS_LES_N_ANIMES = 4
local VITESSE_FLOTTE = 0.6

-- cosinus hyperbolique (évite de dépendre de math.cosh)
local function ch(x)
	return (math.exp(x) + math.exp(-x)) / 2
end

-- point de la chaînette entre a et b (mêmes hauteurs ou non), t dans [0, 1], fleche = creux au milieu
local function pointChainette(a, b, t, fleche)
	local base = a:Lerp(b, t)
	local s = t * 2 - 1
	local k = COURBURE_CHAINETTE
	local profil = (ch(k * s) - 1) / (ch(k) - 1) -- 1 aux extrémités, 0 au milieu
	return base - Vector3.new(0, fleche * (1 - profil), 0)
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	local couleursFanions = { Charte.toit, Charte.dore, Charte.creme, Charte.gemme }
	local couleurMat = Charte.terre
	local couleurBoule = Charte.dore
	local couleurCorde = Charte.ombre(Charte.creme)

	-- compteur de parts propre au module
	local nbParts = 0
	local function creer(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return fabrique(parent, props)
	end

	local indiceCouleur = 0
	local indiceFanion = 0

	-- mât posé au sol en pos, retourne le point d'accroche (haut du mât)
	local function mat(parent, pos, hauteur)
		local taille = Vector3.new(COTE_MAT, hauteur, COTE_MAT)
		creer(Outils.bloc, parent, {
			Name = "Mat",
			Size = taille,
			CFrame = Outils.surSol(taille, pos.X, pos.Z, 0, pos.Y),
			Color = couleurMat,
		})
		creer(Outils.boule, parent, {
			Name = "Pommeau",
			Size = Vector3.new(DIAMETRE_BOULE, DIAMETRE_BOULE, DIAMETRE_BOULE),
			CFrame = CFrame.new(pos.X, pos.Y + hauteur + DIAMETRE_BOULE / 2 - 0.1, pos.Z),
			Color = couleurBoule,
		})
		return Vector3.new(pos.X, pos.Y + hauteur - 0.3, pos.Z)
	end

	-- fanion triangulaire suspendu sous le point p, dans le plan vertical de la direction horizontale dir
	local function fanion(parent, p, dir)
		indiceCouleur = indiceCouleur + 1
		indiceFanion = indiceFanion + 1
		local couleur = couleursFanions[((indiceCouleur - 1) % #couleursFanions) + 1]
		local haut = Vector3.new(0, 1, 0)
		local cote = haut:Cross(dir)
		if cote.Magnitude < 0.01 then
			cote = Vector3.new(1, 0, 0)
		end
		cote = cote.Unit
		-- coin retourné : grand côté en haut, pointe vers le bas
		local repere = CFrame.fromMatrix(p - Vector3.new(0, FANION_HAUTEUR / 2, 0), cote, haut) * CFrame.Angles(math.pi, 0, 0)
		local f = creer(Outils.coin, parent, {
			Name = "Fanion",
			Size = Vector3.new(FANION_EPAISSEUR, FANION_HAUTEUR, FANION_LARGEUR),
			CFrame = repere,
			Color = couleur,
			CanCollide = false,
			CanQuery = false,
			CastShadow = false,
		})
		if f and indiceFanion % TOUS_LES_N_ANIMES == 0 then
			Outils.animer(f, "flotte", VITESSE_FLOTTE)
		end
		return f
	end

	-- guirlande complète entre deux points d'accroche
	local function guirlande(parent, a, b, reglage)
		local horizontal = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
		local longueur = horizontal.Magnitude
		if longueur < 1 then
			return
		end
		local dir = horizontal.Unit
		local modele = Outils.modele(parent, "Guirlande")

		-- corde : segments droits entre les points de la chaînette
		local nbSegments = math.max(2, math.min(SEGMENTS_MAX, math.ceil(longueur / LONGUEUR_SEGMENT)))
		local precedent = a
		for i = 1, nbSegments do
			local suivant = pointChainette(a, b, i / nbSegments, reglage.flecheCorde)
			local ecart = suivant - precedent
			if ecart.Magnitude > 0.05 then
				creer(Outils.bloc, modele, {
					Name = "Corde",
					Size = Vector3.new(EPAISSEUR_CORDE, EPAISSEUR_CORDE, ecart.Magnitude + EPAISSEUR_CORDE),
					CFrame = CFrame.lookAt((precedent + suivant) / 2, suivant),
					Color = couleurCorde,
					CanCollide = false,
					CanQuery = false,
					CastShadow = false,
				})
			end
			precedent = suivant
		end

		-- fanions régulièrement espacés, sans toucher les mâts
		local nbFanions = math.floor((longueur - 1) / reglage.espaceFanion)
		if nbFanions < 1 then
			nbFanions = 1
		end
		for i = 1, nbFanions do
			local t = i / (nbFanions + 1)
			fanion(modele, pointChainette(a, b, t, reglage.flecheCorde), dir)
		end
	end

	-- ===== Prairie : autour du parvis =====
	local parvis = Plan.parvis
	if parvis and parvis.centre and parvis.taille then
		local groupe = Outils.dossier(dossier, "Parvis")
		local c = parvis.centre
		local hauteurMat = MAT_PRAIRIE.hauteur
		if Plan.hauteurMaxPres and hauteurMat + DIAMETRE_BOULE > Plan.hauteurMaxPres then
			hauteurMat = Plan.hauteurMaxPres - DIAMETRE_BOULE
		end
		local dx = parvis.taille.X / 2 + MARGE_PARVIS
		local dz = parvis.taille.Z / 2 + MARGE_PARVIS
		local zNord = c.Z - dz
		local zSud = c.Z + dz
		local sol = c.Y

		-- mâts : 4 coins + 4 bords de la trouée du chemin (côtés Nord et Sud)
		local accroches = {
			no = mat(groupe, Vector3.new(c.X - dx, sol, zNord), hauteurMat),
			ne = mat(groupe, Vector3.new(c.X + dx, sol, zNord), hauteurMat),
			so = mat(groupe, Vector3.new(c.X - dx, sol, zSud), hauteurMat),
			se = mat(groupe, Vector3.new(c.X + dx, sol, zSud), hauteurMat),
		}
		local trouee = dx > DEMI_TROUEE + 2
		if trouee then
			accroches.nog = mat(groupe, Vector3.new(c.X - DEMI_TROUEE, sol, zNord), hauteurMat)
			accroches.nod = mat(groupe, Vector3.new(c.X + DEMI_TROUEE, sol, zNord), hauteurMat)
			accroches.sug = mat(groupe, Vector3.new(c.X - DEMI_TROUEE, sol, zSud), hauteurMat)
			accroches.sud = mat(groupe, Vector3.new(c.X + DEMI_TROUEE, sol, zSud), hauteurMat)
		end

		-- côtés Est et Ouest : guirlandes pleines
		guirlande(groupe, accroches.no, accroches.so, MAT_PRAIRIE)
		guirlande(groupe, accroches.ne, accroches.se, MAT_PRAIRIE)
		-- côtés Nord et Sud : de part et d'autre du chemin, accès à la Maison dégagé
		if trouee then
			guirlande(groupe, accroches.no, accroches.nog, MAT_PRAIRIE)
			guirlande(groupe, accroches.nod, accroches.ne, MAT_PRAIRIE)
			guirlande(groupe, accroches.so, accroches.sug, MAT_PRAIRIE)
			guirlande(groupe, accroches.sud, accroches.se, MAT_PRAIRIE)
		end
	end

	-- ===== Île du Laboratoire : couronne de mâts à r66 =====
	local lobby = Plan.lobby
	if lobby and lobby.origine then
		local groupe = Outils.dossier(dossier, "Ile")
		local o = lobby.origine
		local monument = lobby.monument
		local nbMats = math.floor(360 / PAS_ANGLE_ILE)

		-- positions retenues (nil = sautée près du monument)
		local positions = {}
		for i = 1, nbMats do
			local angle = math.rad((i - 1) * PAS_ANGLE_ILE)
			local pos = Vector3.new(o.X + math.sin(angle) * RAYON_ILE, o.Y, o.Z + math.cos(angle) * RAYON_ILE)
			local garder = true
			if monument and Outils.distanceXZ(pos, monument) < ECART_MONUMENT then
				garder = false
			end
			if garder then
				positions[i] = pos
			end
		end

		local accroches = {}
		for i = 1, nbMats do
			if positions[i] then
				accroches[i] = mat(groupe, positions[i], MAT_ILE.hauteur)
			end
		end

		-- guirlandes entre mâts voisins, seulement si le tronçon reste loin du monument
		for i = 1, nbMats do
			local j = (i % nbMats) + 1
			local a = accroches[i]
			local b = accroches[j]
			if a and b then
				local milieu = (a + b) / 2
				if not monument or Outils.distanceXZ(milieu, monument) >= ECART_MONUMENT then
					guirlande(groupe, a, b, MAT_ILE)
				end
			end
		end
	end

	dossier:SetAttribute("Parts", nbParts)
end

return M
