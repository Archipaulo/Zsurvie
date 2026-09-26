-- Tous les chiffres du jeu. Les modules lisent ces valeurs : ne jamais les recopier en dur ailleurs.
--
-- Courbe visée (joueur seul) :
--   jours 1 à 3 : prise en main, la Maison ne souffre presque pas ;
--   jour 4      : arrivée des Costauds, premiers vrais coups sur la Maison ;
--   jour 5      : le Colosse, premier pic ; un débutant y tombe une fois sur deux ;
--   jours 6 à 7 : fin de la première run d'un débutant ;
--   jours 8 à 10: mur des joueurs réguliers (Casques, Volants, second Colosse).
-- Économie visée : environ une amélioration par répit en début de run, deux ensuite ;
-- première recherche abordable après une ou deux runs.
local E = {}

-- ===== les Zbires =====
-- pv, vitesse (studs/s), degats (à la Maison, par coup), cadence (s entre deux coups),
-- pieces (butin), gemmes (butin rare), taille (facteur d'échelle du modèle)
-- Intention : le Marcheur est l'étalon (30 pv = 2 s de tir d'un débutant).
-- Le Costaud est la vraie menace de la Maison (≈ 5,6 dégâts/s), il paie en conséquence.
-- Le Doré est une piñata : fragile, rapide à fuir, riche en pièces et en gemmes.
-- Le Colosse : ≈ 7 dégâts/s seul, mais il arrive au cœur de la vague et fixe l'attention.
E.zbires = {
	Marcheur = { pv = 30, vitesse = 6, degats = 5, cadence = 1.2, pieces = 2, gemmes = 0, taille = 1 },
	Rapide = { pv = 18, vitesse = 11, degats = 3, cadence = 0.9, pieces = 2, gemmes = 0, taille = 0.8 },
	Costaud = { pv = 80, vitesse = 4, degats = 9, cadence = 1.6, pieces = 5, gemmes = 0, taille = 1.5 },
	Dore = { pv = 45, vitesse = 7, degats = 4, cadence = 1.2, pieces = 6, gemmes = 2, taille = 1 },
	Sauteur = { pv = 25, vitesse = 9, degats = 5, cadence = 1.2, pieces = 3, gemmes = 0, taille = 0.9 },
	Gluant = { pv = 50, vitesse = 5, degats = 6, cadence = 1.3, pieces = 3, gemmes = 0, taille = 1.2, division = 2 },
	MiniGluant = { pv = 12, vitesse = 9, degats = 2, cadence = 1, pieces = 1, gemmes = 0, taille = 0.55 },
	Volant = { pv = 20, vitesse = 8, degats = 4, cadence = 1.1, pieces = 3, gemmes = 0, taille = 0.85, altitude = 6 },
	Casque = { pv = 60, vitesse = 5, degats = 8, cadence = 1.4, pieces = 5, gemmes = 0, taille = 1.1, armure = 0.5 },
	Colosse = { pv = 420, vitesse = 2.8, degats = 18, cadence = 2.5, pieces = 50, gemmes = 10, taille = 2.7 },
}
E.porteeAttaqueZbire = 11 -- distance au centre de la Maison à laquelle un Zbire frappe

-- ===== les jours =====
-- Intention : 80 s de horde (apparitions étalées sur 48 s), 20 s de répit pour
-- réparer ET passer à l'Établi. Les pv montent de 16 % par jour (x1,8 au jour 5,
-- x3,8 au jour 10), ce que les améliorations Degats/Cadence compensent à peu près.
-- En coopération, +55 % de Zbires par Survivant : l'équipe reste plus forte
-- qu'un joueur seul, sans rendre la Prairie vide.
E.jour = {
	dureeHorde = 80,
	dureeRepit = 20,
	colosseTousLes = 5,
	multiplicateurPv = 1.16, -- pv x multiplicateur^(jour-1)
	multiplicateurCoop = 0.55, -- +55 % de Zbires par Survivant au-delà du premier
}
-- nombre de Zbires (joueur seul) : 10, 14, 18, 22, 26 (+ Colosse), ... plafonné à 70
function E.zbiresDuJour(jour)
	return math.min(6 + jour * 4, 70)
end
-- types disponibles et poids d'apparition selon le jour
-- Intention : un nouveau type tous les un ou deux jours ; Costauds et Casques
-- entrent en petit nombre puis gagnent du poids jour après jour.
function E.compositionDuJour(jour)
	local c = { { "Marcheur", 10 } }
	if jour >= 2 then table.insert(c, { "Rapide", 6 }) end
	if jour >= 3 then table.insert(c, { "Sauteur", 4 }) end
	if jour >= 4 then table.insert(c, { "Costaud", 1.5 + 0.4 * (jour - 4) }) end
	if jour >= 4 then table.insert(c, { "Dore", 1.2 }) end
	if jour >= 6 then table.insert(c, { "Gluant", 3 }) end
	if jour >= 7 then table.insert(c, { "Volant", 3.5 }) end
	if jour >= 8 then table.insert(c, { "Casque", 1.5 + 0.3 * (jour - 8) }) end
	return c
end

-- ===== la Maison =====
-- Intention : 550 pv tiennent environ 25 s face au Colosse et deux Costauds.
-- Réparer rend 12 pv/s : un répit complet passé à réparer rend ≈ 240 pv,
-- mais réparer pendant la horde, c'est ne plus tirer.
E.maison = { pv = 550, reparationParAction = 6, delaiReparation = 0.5, distanceReparation = 16 }

-- ===== le Blaster =====
-- Intention : 30 dégâts/s théoriques, ≈ 15 à 20 réels pour un débutant qui vise mal.
E.blaster = { degats = 10, cadence = 3, portee = 60, chanceCritique = 0.08, multiplicateurCritique = 2 }

-- ===== les améliorations de l'Établi (pièces, valables jusqu'à la fin de la run) =====
-- cout(niveau) = coutBase * facteur^niveau ; effet par niveau ; equipe = profite à toute l'équipe
-- Intention : gains d'un débutant ≈ 20, 30, 40, 50 pièces aux jours 1 à 4, ≈ 110 au jour 5
-- (Colosse). Premier niveau de Degats (20) payé dès le jour 1 ; Degats et Cadence restent
-- les achats sûrs ; Solidite/Reparation/Regeneration pour qui défend ; Butin rentabilisé
-- en ≈ 3 jours ; BallesExplosives (110) est le gros achat du milieu de run.
-- Regeneration : effet en pv/s, soit ≈ 60 pv par jour et par niveau.
E.ameliorations = {
	Degats = { coutBase = 20, facteur = 1.45, max = 10, effet = 0.25, equipe = false },
	Cadence = { coutBase = 25, facteur = 1.5, max = 8, effet = 0.15, equipe = false },
	Portee = { coutBase = 25, facteur = 1.6, max = 5, effet = 8, equipe = false },
	Solidite = { coutBase = 30, facteur = 1.5, max = 8, effet = 0.2, equipe = true },
	Reparation = { coutBase = 20, facteur = 1.45, max = 8, effet = 0.3, equipe = true },
	Regeneration = { coutBase = 45, facteur = 1.6, max = 6, effet = 0.6, equipe = true },
	Butin = { coutBase = 35, facteur = 1.6, max = 6, effet = 0.2, equipe = false },
	BallesExplosives = { coutBase = 110, facteur = 1.7, max = 5, effet = 4, equipe = false },
}
function E.coutAmelioration(nom, niveau)
	local a = E.ameliorations[nom]
	return math.floor(a.coutBase * a.facteur ^ niveau + 0.5)
end

-- ===== les recherches du Laboratoire (gemmes, permanentes) =====
-- Intention : une run de débutant rapporte ≈ 35 à 45 gemmes, une run correcte ≈ 70.
-- ViseeCritique (45) s'achète après une run + parcours/énigme, ou après deux runs ;
-- TourelleToit (60) après deux runs ; Foreuse, la plus chère, est un investissement
-- (+4 gemmes par jour survécu, rentabilisée en trois ou quatre runs).
E.recherches = {
	TourelleToit = { cout = 60, description = "Une tourelle sur le toit de la Maison tire seule" },
	BallesPerforantes = { cout = 90, description = "Les tirs traversent un Zbire de plus" },
	ViseeCritique = { cout = 45, description = "+10 % de chance de coup critique" },
	Foreuse = { cout = 110, description = "La Mine produit deux fois plus de gemmes" },
}

-- ===== les gemmes =====
-- Intention : la Mine rapporte ≈ 4 gemmes par jour (100 s de horde + répit),
-- la fin de run récompense surtout la durée de survie.
E.gemmes = {
	mineIntervalle = 25, -- une gemme par Survivant toutes les 25 s pendant une run
	parcours = 10,       -- récompense unique du parcours du lobby
	enigme = 15,         -- récompense unique de l'énigme du lobby
}
-- 18 gemmes au jour 5, 24 au jour 7, 33 au jour 10
function E.gemmesFinDeRun(jour)
	return 3 + jour * 3
end

-- ===== la tourelle de toit =====
-- Intention : ≈ 10 dégâts/s qui ne grandissent pas ; précieuse au début, simple appoint ensuite.
-- cadence = tirs par seconde
E.tourelle = { degats = 8, cadence = 1.3, portee = 48 }

E.joueursMax = 6
E.delaiCapsule = 6 -- secondes entre la première montée dans une Capsule et le départ

return E
