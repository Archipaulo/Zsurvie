-- ReplicatedStorage.Catalogue (ModuleScript) : valeurs persistantes partagées client/serveur, en lecture seule
-- Le client s'en sert pour l'affichage ; le serveur fait foi pour chaque dépense et chaque gain.
-- Coûts provisoires : à caler à l'équilibrage (phase 6) sans toucher au schéma de sauvegarde.

local function geler(t: { [any]: any })
	for _, valeur in t do
		if type(valeur) == "table" then
			geler(valeur)
		end
	end
	return table.freeze(t)
end

return geler({
	-- PlaceId de l'univers Zsurvie, à renseigner à la publication (Creator Hub > Places). 0 = téléport refusé.
	Places = { Laboratoire = 0, Prairie = 0 },

	-- Clés = champs de Recherches dans le profil. Couts[n] = prix en Gemmes pour passer au niveau n.
	Recherches = {
		TourelleDeToit = { NiveauMax = 5, Couts = { 40, 90, 180, 320, 520 } },
		BallesPerforantes = { NiveauMax = 5, Couts = { 30, 70, 140, 260, 450 } },
		ViseeCritique = { NiveauMax = 5, Couts = { 30, 70, 140, 260, 450 } },
		Foreuse = { NiveauMax = 5, Couts = { 60, 120, 220, 380, 600 } },
	},

	-- Foreuse : 5 à 27 gemmes par heure, hors connexion comprise, 8 h au maximum (canon).
	-- Turbo (a08) : x 1,35, plafonné à 27 gemmes par heure.
	Foreuse = {
		GemmesParHeure = { 5, 8, 12, 16, 20 },
		MultiplicateurTurbo = 1.35,
		PlafondParHeure = 27,
		HeuresMax = 8,
	},

	-- Canon : 2 modificateurs et 150 gemmes.
	DefiDuJour = { Gemmes = 150, Modificateurs = 2 },

	-- Quai des Capsules : 1 à 6 places, départ 15 s après le premier passager (canon).
	Capsules = { Modes = { "Normale", "Difficile", "DuJour" }, Places = 6, DelaiDepart = 15 },

	-- Accueil de Doc Boulon (a50) : étapes 1 à 12, sans récompense.
	Accueil = { Etapes = 12 },

	-- Emplacements cosmétiques sauvegardés (Cosmetiques.Equipes).
	Emplacements = { "Blaster", "SacADos", "Alcove" },
})
