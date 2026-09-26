-- ReplicatedStorage.Reseau.ReglesRemotes (ModuleScript, enfant de Reseau) : le contrat réseau unique de Zsurvie
-- Table de a29, figée avec a27 le 29/09. Reseau génère ReplicatedStorage.Remotes depuis cette table et rien d'autre.
-- Demandes client (C2S) : noms Demande*, RemoteEvent uniquement, aucune RemoteFunction. Les réponses partent par Annonce.
-- Types : typeof() attendu par argument ; suffixe "?" = optionnel, "|" = alternatives.
-- ParSeconde : débit soutenu accepté ; Rafale : jetons maximum du seau (défaut : max(1, ParSeconde)).

return table.freeze({
	-- Demandes : Prairie
	DemandeTir = { Classe = "RemoteEvent", Sens = "C2S", Types = { "number" }, ParSeconde = 15, Rafale = 15 }, -- (idZbire)
	DemandeReparation = { Classe = "RemoteEvent", Sens = "C2S", Types = { "boolean" }, ParSeconde = 4 }, -- (actif)
	DemandeAchat = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "number" }, ParSeconde = 4 }, -- (cle, niveauVise)
	DemandePose = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "Vector3", "number" }, ParSeconde = 2 }, -- (defense, position, rotationY)
	DemandeReprise = { Classe = "RemoteEvent", Sens = "C2S", Types = { "number" }, ParSeconde = 2 }, -- (idDefense)
	DemandePing = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "Vector3?" }, ParSeconde = 0.67, Rafale = 2 }, -- (type, position?)

	-- Demandes : Laboratoire
	DemandeCapsule = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "string?" }, ParSeconde = 1, Rafale = 2 }, -- ("Monter", capsule) | ("Quitter") | ("Rejoindre")
	DemandeRecherche = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "number" }, ParSeconde = 2, Rafale = 2 }, -- (nom, niveauVise)
	DemandeForeuse = { Classe = "RemoteEvent", Sens = "C2S", Types = {}, ParSeconde = 0.5, Rafale = 1 }, -- ()

	-- Demandes : les deux places
	DemandeDeblocage = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "string|number" }, ParSeconde = 2, Rafale = 4 }, -- (genre, id)
	DemandeReglage = { Classe = "RemoteEvent", Sens = "C2S", Types = { "string", "boolean|number" }, ParSeconde = 2, Rafale = 5 }, -- (cle, valeur)

	-- Serveur -> client, fiables
	Annonce = { Classe = "RemoteEvent", Sens = "S2C" }, -- (code, donnees?) : Refus, Recherche, Foreuse, Sauvegarde, PassageAnnule, FinDeRun
	PingDiffuse = { Classe = "RemoteEvent", Sens = "S2C" }, -- (userId, type, position?)
	ProfilMaj = { Classe = "RemoteEvent", Sens = "S2C" }, -- ({ [champ] = valeur }) : champs modifiés seulement
	PiecesLachees = { Classe = "RemoteEvent", Sens = "S2C" }, -- ({ {id, position, valeur} }) au propriétaire seul
	Butin = { Classe = "RemoteEvent", Sens = "S2C" }, -- (idsRamasses, pieces) au propriétaire seul

	-- Serveur -> client, non fiables (buffers, 10 Hz)
	EtatZbires = { Classe = "UnreliableRemoteEvent", Sens = "S2C" }, -- 9 octets par Zbire
	Evenements = { Classe = "UnreliableRemoteEvent", Sens = "S2C" }, -- 8 octets par fait, 100 faits au plus
})
