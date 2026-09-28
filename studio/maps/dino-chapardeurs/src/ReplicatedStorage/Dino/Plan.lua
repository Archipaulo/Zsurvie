-- Plan du monde (studs). Le sol est à Y = 0 partout. Chaque module de construction reste dans son emprise (CONTRAT.md §9).
-- Vue de dessus : le Tapis traverse le monde d'ouest (Nurserie) en est (Fin du tapis) le long de z = 0 ;
-- 4 Bases au nord (z < 0) et 4 au sud (z > 0) ouvrent leur entrée vers le Tapis ;
-- la Place (apparition, Comptoir, Autel) est au sud, le Volcan et le Cratère au nord.
local Plan = {}

Plan.monde = {
	min = Vector3.new(-180, 0, -175), -- coin nord-ouest du sol
	max = Vector3.new(180, 0, 150),   -- coin sud-est du sol
	bord = 190,                        -- murs invisibles au-delà
}

-- ===== le Tapis roulant =====
Plan.tapis = {
	debut = Vector3.new(-112, 0, 0), -- les dinos apparaissent ici (sortie de la Nurserie)
	fin = Vector3.new(112, 0, 0),    -- ... et disparaissent ici (entrée de la Fin du tapis)
	largeur = 14,                    -- les dinos voxel les plus larges sont réduits à la volée pour y tenir (Systemes/Tapis)
	hauteur = 0.8,                   -- dessus du tapis : les dinos y marchent à Y = hauteur
}
Plan.nurserie = { centre = Vector3.new(-128, 0, 0), rayon = 14 }
Plan.finTapis = { centre = Vector3.new(128, 0, 0), rayon = 14 }

-- ===== les 8 Bases =====
-- taille : 44 (x) sur 50 (z) ; l'entrée est le bord le plus proche du Tapis (|z| = 18) ;
-- versTapis = direction (en z) de l'entrée : -1 pour les bases du sud, +1 pour celles du nord.
Plan.base = { largeur = 44, profondeur = 50, bordInterieur = 18, hauteurSol = 1, emplacementsMax = 12 }
Plan.bases = {}
local X = { -84, -28, 28, 84 }
for i = 1, 4 do
	table.insert(Plan.bases, { centre = Vector3.new(X[i], 0, -43), versTapis = 1 })
end
for i = 1, 4 do
	table.insert(Plan.bases, { centre = Vector3.new(X[i], 0, 43), versTapis = -1 })
end

-- ===== le Sud : la Place =====
Plan.place = { centre = Vector3.new(0, 0, 100), rayon = 20 }        -- SpawnLocation unique au centre
Plan.comptoir = { centre = Vector3.new(-50, 0, 104), taille = Vector3.new(26, 16, 18) } -- boutique
Plan.autel = { centre = Vector3.new(50, 0, 104), rayon = 11 }       -- renaissances
Plan.riviere = { z = 138, largeur = 14 }                            -- rivière d'ouest en est, de x = -180 à 180

-- ===== le Nord : Volcan et Cratère =====
Plan.cratere = { centre = Vector3.new(0, 0, -96), rayon = 16 }      -- scène des événements
Plan.volcan = { centre = Vector3.new(0, 0, -150), rayon = 34, hauteur = 70 }
Plan.coffre = Vector3.new(160, 22, -158)                            -- coffre caché en haut des falaises (Recompenses)

-- ===== zones de décor =====
Plan.decor = {
	jungleOuest = { min = Vector3.new(-166, 0, -166), max = Vector3.new(-146, 0, 128) },
	jungleEst = { min = Vector3.new(146, 0, -166), max = Vector3.new(166, 0, 128) },
	jungleNord = { min = Vector3.new(-146, 0, -166), max = Vector3.new(146, 0, -118) }, -- sauf le Volcan (rayon + 6)
	couloirs = { -- allées libres entre les bases (x = ±56, 0) : petits props seulement
		Vector3.new(-56, 0, 0), Vector3.new(0, 0, 0), Vector3.new(56, 0, 0),
	},
}

return Plan
