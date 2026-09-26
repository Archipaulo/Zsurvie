-- Plan de la map (studs). Le sol de la Prairie et de l'île du Laboratoire est à Y = 0.
-- Chaque module de construction reste dans son emprise (voir CONTRAT.md).
local Plan = {}

-- ===== La Prairie (zone de run), centrée sur l'origine =====
Plan.prairie = {
	centre = Vector3.new(0, 0, 0),
	rayon = 70,            -- arène de jeu
	lisiereInterieur = 70, -- anneau d'apparition des Zbires
	lisiereExterieur = 100,
	bordMonde = 115,       -- au-delà : rien
	largeurChemin = 6,     -- 4 chemins en croix sur les axes X et Z, de 9 à 100 studs du centre
}

Plan.maison = { centre = Vector3.new(0, 0, 0), taille = Vector3.new(16, 14, 16) }
Plan.mine = { centre = Vector3.new(22, 0, -22), rayon = 7 }
Plan.etabli = { centre = Vector3.new(-22, 0, 22), rayon = 6 }
Plan.parvis = { centre = Vector3.new(0, 0, 36), taille = Vector3.new(20, 1, 12) } -- atterrissage des Survivants
Plan.etang = { centre = Vector3.new(46, 0, 20), rayon = 8 }

-- 4 portails violets sur la Lisière, un par chemin
Plan.portails = {
	Nord = Vector3.new(0, 0, -85),
	Est = Vector3.new(85, 0, 0),
	Sud = Vector3.new(0, 0, 85),
	Ouest = Vector3.new(-85, 0, 0),
}

-- 4 emplacements de points d'intérêt, sur les diagonales
Plan.pointsInteret = {
	Vector3.new(37, 0, 37),
	Vector3.new(-37, 0, 37),
	Vector3.new(-37, 0, -37),
	Vector3.new(37, 0, -37),
}
Plan.rayonPointInteret = 8

-- ===== L'île du Laboratoire (lobby), loin de la Prairie =====
local L = Vector3.new(0, 0, 600)
Plan.lobby = {
	origine = L,
	rayon = 70,
	spawn = L + Vector3.new(0, 0, 48),         -- SpawnLocation unique (module QuaiCapsules)
	laboratoire = L + Vector3.new(0, 0, -25),  -- Arbre des Recherches au centre, 12 Alcôves autour (rayon 16)
	quai = L + Vector3.new(0, 0, 28),          -- Quai des Capsules, 36 x 12
	galerie = L + Vector3.new(-40, 0, 0),      -- Galerie des Zbires, 16 x 24
	parcours = L + Vector3.new(40, 0, 0),      -- parcours d'obstacles, 20 x 30, jusqu'à 30 studs de haut
	enigme = L + Vector3.new(-40, 0, -35),     -- énigme, 14 x 14
	records = L + Vector3.new(20, 0, 40),      -- tableau des records
	monument = L + Vector3.new(0, 0, 62),      -- lettres ZSURVIE
	scenePhoto = L + Vector3.new(38, 0, -40),  -- décor pour les vignettes, 12 x 12
}

-- hauteur maximale du décor à moins de 60 studs de la Maison (la Maison elle-même fait 14)
Plan.hauteurMaxPres = 6

return Plan
