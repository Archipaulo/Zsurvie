-- ReplicatedStorage/Partage/Config (ModuleScript)
-- Constantes de gameplay partagées serveur et client.
-- AUCUNE valeur de mouvement ici (vitesses, étourdissement, saut) : elles vivent dans
-- ReplicatedStorage.Config.Mouvement, lu par GardienMouvement, seul propriétaire de WalkSpeed et JumpHeight.
-- [canon] = valeur imposée par Victor Lanoue ; [02/10] = consigne du chef de projet ; (a11) = repère de la map.

-- Pool client de 70 modèles (ZbiresRendu). Le serveur ne fait sortir un Zbire que si son type a une place.
local QUOTAS_RENDU = table.freeze({
	Marcheur = 18,
	Rapide = 10,
	Costaud = 5,
	Dore = 2,
	Sauteur = 6,
	Gluant = 5,
	MiniGluant = 10,
	Volant = 5,
	Casque = 8,
	Colosse = 1,
})

local Config = {
	-- Simulation de la horde
	TICK = 0.1, -- [canon] position, PV et cible 10 fois par seconde
	MAX_ZBIRES = 60, -- [canon] Mini-Gluants compris, Colosse en plus
	APPARITIONS_PAR_TICK = 3,
	DUREE_HORDE = 80, -- [canon]
	DUREE_REPIT = 15, -- [canon]
	PERIODE_COLOSSE = 5, -- [canon] un Colosse les jours 5, 10, 15...

	-- Formules [02/10]
	CROISSANCE_JOUR = 1.15, -- PV x 1,15^(jour - 1)
	FACTEUR_TENSION = 1.3, -- PV x 1,3^Tension (a06)
	COOP_PV = 0.35, -- [canon] PV x (1 + 0,35 x (actifs - 1))
	COOP_NOMBRE = 0.2, -- Zbires du jour x (1 + 0,2 x (actifs - 1))
	JOUEURS_MAX = 6,
	DPS_MAISON = 4, -- PV/s par Zbire au contact, x 1,15^(jour - 1) x multMaison du type
	COLOSSE_ENRAGE_APRES = 60, -- s après sa sortie du portail
	COLOSSE_ENRAGE_VITESSE = 1.5,
	COLOSSE_ENRAGE_MAISON = 3,

	-- Repère de la Prairie (a11) : origine au centre de la Maison, sol à Y = 0, Nord = -Z
	CENTRE = Vector3.zero,
	SOL_Y = 0,
	MAISON_DEMI = 8, -- [canon] Maison de 16 x 16 studs
	TAG_PORTAIL = "PortailZbire",
	NB_PORTAILS = 8, -- sans portail tagué : Plan.positionPortail(1 à 8)
	PORTAIL_DISPERSION = 2, -- studs autour du portail
	GRAND_PORTAIL = Vector3.new(0, 0, -80), -- sortie du Colosse (a11)
	ALERTE_PORTAIL = 1.5, -- [02/10] s d'alerte avant la sortie
	ALERTE_COLOSSE = 4, -- [02/10]
	DELAI_CIBLABLE = 0.8, -- [02/10] ciblableA = sortie + 0,8 s
	DORE_RAYON_FUITE = 96,
	DORE_DECALAGE = 0.8, -- radians : le Doré coupe la Prairie à ~37 studs de la Maison

	-- Survivants
	PORTEE_COUP_ZBIRE = 2, -- studs ajoutés au rayon du Zbire
	RECHARGE_COUP_SURVIVANT = 1.5,
	ETOURDI_IMMUNITE = 2, -- s de protection après un étourdissement
	DEBLOCAGE_INTERVALLE = 10, -- [02/10] 1 demande toutes les 10 s
	DEBLOCAGE_RAYON_LIBRE = 4, -- SpawnLocation libre : aucun autre Survivant à moins de 4 studs

	-- Blaster (les courbes sont dans BlasterStats)
	TIR_RAFALE = 2, -- tirs d'avance tolérés (gigue réseau)
	TIR_TOLERANCE = 4, -- studs ajoutés à la portée
	PERFORATION_LONGUEUR = 14, -- studs derrière la cible
	HYSTERESIS_CIBLE = 0.4, -- s entre deux changements de cible du tir auto

	-- Réseau et rendu
	OCTETS_PAR_ZBIRE = 9, -- 61 x 9 x 10 Hz = 5,5 Ko/s par client
	ETAT_CIBLABLE = 1,
	ETAT_BOND = 2,
	ETAT_ENRAGE = 4,
	ETAT_CONTACT = 8,
	QUOTAS_RENDU = QUOTAS_RENDU,
	HAUTEUR_VOL = 3.5, -- bas du Volant entre 3,2 et 3,8 studs : au-dessus d'un Muret de 3, sommet vers 6
	OUBLI_RENDU = 0.5, -- s sans nouvelle d'un Zbire avant de rendre son modèle au pool
}

return table.freeze(Config)
