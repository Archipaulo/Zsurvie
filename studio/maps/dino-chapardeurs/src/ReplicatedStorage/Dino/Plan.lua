-- Plan du monde (studs), version 2 « plus d'air ». Le sol est à Y = 0 partout.
-- Chaque module de construction reste dans son emprise (CONTRAT.md §10) et lit ses coordonnées ICI
-- (aucune position du décor ne doit être écrite en dur ailleurs).
-- Vue de dessus : le Tapis traverse le monde d'ouest (Nurserie) en est (Grande Porte) le long de z = 0 ;
-- 4 Bases au nord et 4 au sud, séparées par de larges allées (22 studs), entrée tournée vers le Tapis
-- avec une promenade de ~18 studs entre le Tapis et les Bases ; la Place au sud, le Cratère et le Volcan au nord.
local Plan = {}

Plan.monde = {
	min = Vector3.new(-215, 0, -245), -- coin nord-ouest du sol
	max = Vector3.new(215, 0, 185),   -- coin sud-est du sol
	bord = 228,                        -- murs invisibles : |x| = 228, z = -258 et z = 198
	bordNord = -258,
	bordSud = 198,
}

-- ===== le Tapis roulant =====
Plan.tapis = {
	debut = Vector3.new(-140, 0, 0), -- les dinos apparaissent ici (sortie de la Nurserie)
	fin = Vector3.new(140, 0, 0),    -- ... et disparaissent ici (entrée de la Grande Porte)
	largeur = 14,                    -- les dinos voxel les plus larges sont réduits à la volée pour y tenir (Systemes/Tapis)
	hauteur = 0.8,                   -- dessus du tapis : les dinos y marchent à Y = hauteur
	emprise = 9.5,                   -- rebords compris : rien d'autre à moins de 9,5 de l'axe
}
Plan.nurserie = { centre = Vector3.new(-157, 0, 0), rayon = 15 }
Plan.finTapis = { centre = Vector3.new(157, 0, 0), rayon = 15 }
-- la promenade : bande libre de chaque côté du Tapis, entre ses rebords et l'entrée des Bases
Plan.promenade = { zMin = 9.5, zMax = 27 }

-- ===== les 8 Bases =====
-- taille : 44 (x) sur 50 (z) ; l'entrée est le bord le plus proche du Tapis (|z| = bordInterieur) ;
-- versTapis = direction (en z) de l'entrée : -1 pour les bases du sud, +1 pour celles du nord.
Plan.base = { largeur = 44, profondeur = 50, bordInterieur = 27, hauteurSol = 1, emplacementsMax = 12 }
Plan.bases = {}
local X = { -99, -33, 33, 99 }
local Z = Plan.base.bordInterieur + Plan.base.profondeur / 2 -- 52
for i = 1, 4 do
	table.insert(Plan.bases, { centre = Vector3.new(X[i], 0, -Z), versTapis = 1 })
end
for i = 1, 4 do
	table.insert(Plan.bases, { centre = Vector3.new(X[i], 0, Z), versTapis = -1 })
end
-- allées entre les Bases (22 de large) : x = -66, 0, 66 ; libres de tout obstacle au milieu (props en bordure seulement)
Plan.allees = { x = { -66, 0, 66 }, largeur = 22, zMin = 27, zMax = 77 }

-- ===== le Sud : la Place =====
Plan.place = { centre = Vector3.new(0, 0, 112), rayon = 22 }       -- SpawnLocation unique au centre
Plan.comptoir = { centre = Vector3.new(-56, 0, 118), taille = Vector3.new(26, 16, 18) } -- boutique, ouverte vers +X
Plan.autel = { centre = Vector3.new(56, 0, 118), rayon = 11 }      -- renaissances, tourné vers -X
Plan.riviere = { z = 157, largeur = 14, zMin = 150, zMax = 164, xMin = -198, xMax = 198 } -- d'ouest en est

-- ===== le Nord : Cratère et Volcan =====
Plan.cratere = { centre = Vector3.new(0, 0, -112), rayon = 16 }    -- scène des événements
Plan.volcan = { centre = Vector3.new(0, 0, -190), rayon = 36, hauteur = 75 }
-- coffre caché : dessus de la plateforme au sommet de la falaise nord-est
Plan.coffre = Vector3.new(212, 22, -214)

-- ===== bandes de falaises (bord du monde) =====
Plan.falaises = {
	est = { xMin = 200, xMax = 228, zMin = -258, zMax = 198 },
	ouest = { xMin = -228, xMax = -200, zMin = -258, zMax = 198 },
	nord = { xMin = -228, xMax = 228, zMin = -258, zMax = -232 },
	sud = { xMin = -228, xMax = 228, zMin = 170, zMax = 198 },
}

-- ===== zones de décor =====
Plan.decor = {
	jungleOuest = { min = Vector3.new(-198, 0, -230), max = Vector3.new(-176, 0, 146) },
	jungleEst = { min = Vector3.new(176, 0, -230), max = Vector3.new(198, 0, 146) },
	jungleNord = { min = Vector3.new(-176, 0, -230), max = Vector3.new(176, 0, -136) }, -- sauf le Volcan (rayon + 6) et le Cratère
	couloirs = { -- allées libres entre les bases : petits props seulement, en bordure
		Vector3.new(-66, 0, 0), Vector3.new(0, 0, 0), Vector3.new(66, 0, 0),
	},
}

-- ===== le ciel =====
Plan.ciel = { altitudeVols = { 95, 140 } } -- les ptérosaures passent très haut au-dessus de la carte

return Plan
