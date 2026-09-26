-- Tous les chiffres du jeu. Les modules lisent ces valeurs : ne jamais les recopier en dur ailleurs.
local E = {}

-- ===== les Zbires =====
-- pv, vitesse (studs/s), degats (à la Maison, par coup), cadence (s entre deux coups),
-- pieces (butin), gemmes (butin rare), taille (facteur d'échelle du modèle)
E.zbires = {
	Marcheur = { pv = 30, vitesse = 6, degats = 5, cadence = 1.2, pieces = 2, gemmes = 0, taille = 1 },
	Rapide = { pv = 18, vitesse = 11, degats = 3, cadence = 0.9, pieces = 2, gemmes = 0, taille = 0.8 },
	Costaud = { pv = 90, vitesse = 4, degats = 12, cadence = 1.6, pieces = 5, gemmes = 0, taille = 1.5 },
	Dore = { pv = 45, vitesse = 7, degats = 4, cadence = 1.2, pieces = 4, gemmes = 3, taille = 1 },
	Sauteur = { pv = 25, vitesse = 9, degats = 5, cadence = 1.2, pieces = 3, gemmes = 0, taille = 0.9 },
	Gluant = { pv = 50, vitesse = 5, degats = 6, cadence = 1.3, pieces = 3, gemmes = 0, taille = 1.2, division = 2 },
	MiniGluant = { pv = 12, vitesse = 9, degats = 2, cadence = 1, pieces = 1, gemmes = 0, taille = 0.55 },
	Volant = { pv = 20, vitesse = 8, degats = 4, cadence = 1.1, pieces = 3, gemmes = 0, taille = 0.85, altitude = 6 },
	Casque = { pv = 60, vitesse = 5, degats = 8, cadence = 1.4, pieces = 4, gemmes = 0, taille = 1.1, armure = 0.5 },
	Colosse = { pv = 600, vitesse = 3, degats = 40, cadence = 2.5, pieces = 40, gemmes = 15, taille = 2.7 },
}
E.porteeAttaqueZbire = 11 -- distance au centre de la Maison à laquelle un Zbire frappe

-- ===== les jours =====
E.jour = {
	dureeHorde = 80,
	dureeRepit = 15,
	colosseTousLes = 5,
	multiplicateurPv = 1.18, -- pv x multiplicateur^(jour-1)
	multiplicateurCoop = 0.35, -- +35 % de Zbires par Survivant au-delà du premier
}
function E.zbiresDuJour(jour)
	return math.min(6 + jour * 3, 70)
end
-- types disponibles et poids d'apparition selon le jour
function E.compositionDuJour(jour)
	local c = { { "Marcheur", 10 } }
	if jour >= 2 then table.insert(c, { "Rapide", 6 }) end
	if jour >= 3 then table.insert(c, { "Sauteur", 4 }) end
	if jour >= 4 then table.insert(c, { "Costaud", 4 }) end
	if jour >= 4 then table.insert(c, { "Dore", 1.3 }) end
	if jour >= 6 then table.insert(c, { "Gluant", 3.5 }) end
	if jour >= 7 then table.insert(c, { "Volant", 3.5 }) end
	if jour >= 8 then table.insert(c, { "Casque", 3 }) end
	return c
end

-- ===== la Maison =====
E.maison = { pv = 400, reparationParAction = 8, delaiReparation = 0.4, distanceReparation = 16 }

-- ===== le Blaster =====
E.blaster = { degats = 10, cadence = 3, portee = 60, chanceCritique = 0.08, multiplicateurCritique = 2 }

-- ===== les améliorations de l'Établi (pièces, valables jusqu'à la fin de la run) =====
-- cout(niveau) = coutBase * facteur^niveau ; effet par niveau ; equipe = profite à toute l'équipe
E.ameliorations = {
	Degats = { coutBase = 20, facteur = 1.5, max = 10, effet = 0.25, equipe = false },
	Cadence = { coutBase = 25, facteur = 1.55, max = 8, effet = 0.15, equipe = false },
	Portee = { coutBase = 30, facteur = 1.6, max = 5, effet = 8, equipe = false },
	Solidite = { coutBase = 35, facteur = 1.55, max = 8, effet = 0.2, equipe = true },
	Reparation = { coutBase = 20, facteur = 1.45, max = 8, effet = 0.3, equipe = true },
	Regeneration = { coutBase = 45, facteur = 1.6, max = 6, effet = 1, equipe = true },
	Butin = { coutBase = 35, facteur = 1.6, max = 6, effet = 0.2, equipe = false },
	BallesExplosives = { coutBase = 120, facteur = 1.7, max = 5, effet = 4, equipe = false },
}
function E.coutAmelioration(nom, niveau)
	local a = E.ameliorations[nom]
	return math.floor(a.coutBase * a.facteur ^ niveau + 0.5)
end

-- ===== les recherches du Laboratoire (gemmes, permanentes) =====
E.recherches = {
	TourelleToit = { cout = 40, description = "Une tourelle sur le toit de la Maison tire seule" },
	BallesPerforantes = { cout = 60, description = "Les tirs traversent un Zbire de plus" },
	ViseeCritique = { cout = 50, description = "+10 % de chance de coup critique" },
	Foreuse = { cout = 80, description = "La Mine produit deux fois plus de gemmes" },
}

-- ===== les gemmes =====
E.gemmes = {
	mineIntervalle = 12, -- une gemme par Survivant toutes les 12 s pendant une run
	parcours = 10,       -- récompense unique du parcours du lobby
	enigme = 15,         -- récompense unique de l'énigme du lobby
}
function E.gemmesFinDeRun(jour)
	return 5 + jour * 6
end

-- ===== la tourelle de toit =====
E.tourelle = { degats = 8, cadence = 1.2, portee = 45 }

E.joueursMax = 6
E.delaiCapsule = 5 -- secondes entre la première montée dans une Capsule et le départ

return E
