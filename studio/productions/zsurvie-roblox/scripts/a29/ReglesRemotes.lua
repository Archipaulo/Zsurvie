-- ReplicatedStorage.ReglesRemotes (ModuleScript)
--!strict
-- Source unique des RemoteEvent de Zsurvie. Validation (a29, serveur) crée ReplicatedStorage.Remotes et
-- filtre chaque demande d'après cette table ; Reseau (a27) en dérive son API des deux côtés.
-- Aucun secret ici : le client peut la lire, seule la copie du serveur fait foi.
-- Un remote absent de cette table n'existe pas. Valeurs de texte sans accents (ids).

export type Arg = {
	type: "nombre" | "texte" | "booleen" | "vecteur" | "scalaire", -- scalaire : nombre fini ou booléen
	optionnel: boolean?,
	entier: boolean?,
	min: number?,
	max: number?,
	valeurs: { string }?, -- liste fermée pour "texte"
	rayon: number?, -- distance horizontale max à l'origine de la place pour "vecteur"
}

export type Regle = {
	place: "Prairie" | "Laboratoire" | "Toutes",
	descendant: boolean?, -- serveur -> clients uniquement : tout appel client est un exploit
	nonFiable: boolean?, -- UnreliableRemoteEvent
	debit: number, -- jetons rechargés par seconde
	rafale: number, -- taille du seau de jetons
	args: { Arg },
	coherence: ((...any) -> boolean)?, -- contrôle croisé, appelé après la vérification de chaque argument
}

export type Reglage = { type: "nombre" | "booleen", min: number?, max: number? }

local NIVEAU_MAX = 20 -- borne de format ; le plafond réel de chaque niveau est vérifié en contexte
local ID_MAX = 2 ^ 31

local listes = {
	AMELIORATIONS = {
		"Degats",
		"Cadence",
		"Portee",
		"Solidite",
		"Reparation",
		"Regeneration",
		"Butin",
		"BallesExplosives",
	},
	DEFENSES = { "Muret", "MiniTourelle", "TapisCollant" },
	PINGS = { "Colosse", "Repare", "Ici", "Merci" },
	CAPSULES = { "Normale", "Difficile", "DuJour", "Quitter" },
	RECHERCHES = { "TourelleDeToit", "BallesPerforantes", "ViseeCritique", "Foreuse" },
	REGLAGES = {} :: { string },
}

-- Réglages du joueur : liste fermée, bornes serveur. Ajouter la clé ici avant de l'afficher dans l'UI.
local reglages: { [string]: Reglage } = {
	Musique = { type = "nombre", min = 0, max = 1 },
	Effets = { type = "nombre", min = 0, max = 1 },
	TirAuto = { type = "booleen" },
	Vibrations = { type = "booleen" },
	GraphismesLegers = { type = "booleen" },
}
for cle in reglages do
	table.insert(listes.REGLAGES, cle)
end
table.sort(listes.REGLAGES)

local remotes: { [string]: Regle } = {
	-- Prairie : client -> serveur
	DemandeTir = {
		place = "Prairie",
		debit = 12,
		rafale = 6,
		args = { { type = "nombre", entier = true, min = 1, max = ID_MAX } }, -- idZbire
	},
	DemandeReparation = {
		place = "Prairie",
		debit = 4,
		rafale = 4,
		args = { { type = "booleen" } }, -- true = commence, false = arrête
	},
	DemandeAchat = {
		place = "Prairie",
		debit = 2,
		rafale = 2, -- 2 jetons au plus : un double-tap passe, le second est refusé par niveauVise
		args = {
			{ type = "texte", valeurs = listes.AMELIORATIONS },
			{ type = "nombre", entier = true, min = 1, max = NIVEAU_MAX }, -- niveauVise = niveau actuel + 1
		},
	},
	DemandePose = {
		place = "Prairie",
		debit = 2,
		rafale = 3,
		args = {
			{ type = "texte", valeurs = listes.DEFENSES },
			{ type = "vecteur", rayon = 66 },
			{ type = "nombre", entier = true, min = 0, max = 3 }, -- quarts de tour
		},
	},
	DemandeReprise = {
		place = "Prairie",
		debit = 1,
		rafale = 2,
		args = { { type = "nombre", entier = true, min = 1, max = ID_MAX } }, -- defenseId
	},

	-- Laboratoire : client -> serveur
	DemandeCapsule = {
		place = "Laboratoire",
		debit = 1,
		rafale = 3,
		args = { { type = "texte", valeurs = listes.CAPSULES } },
	},
	DemandeRecherche = {
		place = "Laboratoire",
		debit = 0.5,
		rafale = 2,
		args = {
			{ type = "texte", valeurs = listes.RECHERCHES },
			{ type = "nombre", entier = true, min = 1, max = NIVEAU_MAX }, -- niveauVise = niveau actuel + 1
		},
	},
	DemandeForeuse = {
		place = "Laboratoire",
		debit = 0.2,
		rafale = 1,
		args = {},
	},

	-- Les deux places
	DemandePing = {
		place = "Toutes",
		debit = 0.5,
		rafale = 3,
		args = {
			{ type = "texte", valeurs = listes.PINGS },
			{ type = "vecteur", rayon = 140, optionnel = true }, -- seulement pour « Ici ! »
		},
	},
	DemandeDeblocage = {
		place = "Toutes",
		debit = 0.1, -- 1 toutes les 10 s
		rafale = 1,
		args = {},
	},
	DemandeReglage = {
		place = "Toutes",
		debit = 1,
		rafale = 3,
		args = {
			{ type = "texte", valeurs = listes.REGLAGES },
			{ type = "scalaire" },
		},
		coherence = function(cle: any, valeur: any): boolean
			local r = reglages[cle]
			if not r then
				return false
			elseif r.type == "booleen" then
				return typeof(valeur) == "boolean"
			end
			return typeof(valeur) == "number" and valeur >= (r.min or 0) and valeur <= (r.max or 1)
		end,
	},

	-- Serveur -> clients : pièges
	EtatHorde = { place = "Prairie", descendant = true, nonFiable = true, debit = 0, rafale = 0, args = {} },
	PingDiffuse = { place = "Toutes", descendant = true, debit = 0, rafale = 0, args = {} },
}

return {
	remotes = remotes,
	listes = listes,
	reglages = reglages,
}
