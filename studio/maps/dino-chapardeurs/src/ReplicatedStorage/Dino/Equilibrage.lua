-- Tous les chiffres du jeu. Les modules lisent ces valeurs : ne jamais les recopier en dur ailleurs.
local E = {}

-- ===== les raretés =====
-- poids : chance relative d'apparaître sur le Tapis ; ordre : pour trier les listes
E.raretes = {
	Commun = { ordre = 1, poids = 62, nom = "Commun" },
	Rare = { ordre = 2, poids = 25, nom = "Rare" },
	Epique = { ordre = 3, poids = 9, nom = "Épique" },
	Legendaire = { ordre = 4, poids = 3, nom = "Légendaire" },
	Mythique = { ordre = 5, poids = 0.8, nom = "Mythique" },
	Divin = { ordre = 6, poids = 0.18, nom = "Divin" },
	Secret = { ordre = 7, poids = 0.02, nom = "Secret" },
}

-- ===== les espèces =====
-- prix ($), revenu ($ par seconde dans une Base), taille (facteur d'échelle du modèle), famille (qui fabrique le modèle)
E.especes = {
	-- herbivores (Builders/DinosHerbivores)
	Galli = { nom = "Galli", rarete = "Commun", prix = 15, revenu = 1, taille = 0.9, famille = "Herbivore" },
	Pachy = { nom = "Pachy", rarete = "Commun", prix = 30, revenu = 2, taille = 1, famille = "Herbivore" },
	Tricera = { nom = "Tricéra", rarete = "Commun", prix = 60, revenu = 3, taille = 1.1, famille = "Herbivore" },
	Stego = { nom = "Stégo", rarete = "Rare", prix = 250, revenu = 9, taille = 1.2, famille = "Herbivore" },
	Parasaure = { nom = "Parasaure", rarete = "Rare", prix = 500, revenu = 15, taille = 1.1, famille = "Herbivore" },
	Ankylo = { nom = "Ankylo", rarete = "Epique", prix = 2500, revenu = 50, taille = 1.2, famille = "Herbivore" },
	Iguano = { nom = "Iguano", rarete = "Epique", prix = 4500, revenu = 80, taille = 1.3, famille = "Herbivore" },
	Brachio = { nom = "Brachio", rarete = "Legendaire", prix = 40000, revenu = 450, taille = 1.6, famille = "Herbivore" },
	Diplodo = { nom = "Diplodo", rarete = "Mythique", prix = 350000, revenu = 3200, taille = 1.7, famille = "Herbivore" },
	Therizino = { nom = "Thérizino", rarete = "Divin", prix = 3000000, revenu = 24000, taille = 1.6, famille = "Herbivore" },
	-- carnivores, volants et marins (Builders/DinosCarnivores)
	Compy = { nom = "Compy", rarete = "Commun", prix = 10, revenu = 1, taille = 0.7, famille = "Carnivore" },
	Raptor = { nom = "Raptor", rarete = "Commun", prix = 45, revenu = 2, taille = 0.9, famille = "Carnivore" },
	Dilopho = { nom = "Dilopho", rarete = "Rare", prix = 350, revenu = 12, taille = 1.1, famille = "Carnivore" },
	Ptero = { nom = "Ptéro", rarete = "Rare", prix = 700, revenu = 18, taille = 1, famille = "Carnivore" },
	Carno = { nom = "Carno", rarete = "Epique", prix = 3500, revenu = 65, taille = 1.2, famille = "Carnivore" },
	Spino = { nom = "Spino", rarete = "Legendaire", prix = 30000, revenu = 380, taille = 1.5, famille = "Carnivore" },
	Rex = { nom = "Rex", rarete = "Legendaire", prix = 60000, revenu = 600, taille = 1.6, famille = "Carnivore" },
	Mosa = { nom = "Mosa", rarete = "Mythique", prix = 500000, revenu = 4200, taille = 1.6, famille = "Carnivore" },
	Giga = { nom = "Giga", rarete = "Divin", prix = 5000000, revenu = 38000, taille = 1.9, famille = "Carnivore" },
	Cosmosaure = { nom = "Cosmosaure", rarete = "Secret", prix = 60000000, revenu = 350000, taille = 2, famille = "Carnivore" },
}

-- ===== les mutations =====
-- multiplicateur de prix et de revenu ; poids : chance relative (Normal compris) ; evenement : n'existe que pendant cet événement
E.mutations = {
	Normal = { multiplicateur = 1, poids = 88, nom = "" },
	Or = { multiplicateur = 1.5, poids = 8, nom = "Or" },
	Diamant = { multiplicateur = 2, poids = 3, nom = "Diamant" },
	ArcEnCiel = { multiplicateur = 4, poids = 0.8, nom = "Arc-en-ciel" },
	Lave = { multiplicateur = 3, poids = 0, nom = "Lave", evenement = "Eruption" },
	Meteore = { multiplicateur = 5, poids = 0, nom = "Météore", evenement = "PluieDeMeteores" },
}

-- ===== le Tapis =====
E.tapis = {
	intervalle = 2.2,  -- secondes entre deux dinos
	vitesse = 7,       -- studs par seconde (environ 32 s pour traverser)
	maxDinos = 60,     -- plafond de dinos présents sur le tapis
	vitesseMarche = 14, -- vitesse d'un dino acheté qui rejoint sa Base
}

-- ===== les Bases =====
E.base = {
	emplacementsDepart = 8,  -- emplacements utilisables sans renaissance (max Plan.base.emplacementsMax)
	emplacementsParRenaissance = 1,
	dureeVerrou = 60,        -- secondes de verrouillage
	recharge = 5,            -- secondes entre la fin d'un verrou et le suivant
}

-- ===== l'argent =====
E.argentDepart = 100
E.vente = { part = 0.5 } -- revendre un dino rapporte la moitié de son prix

-- ===== le vol =====
E.vol = {
	dureeAppui = 1.2,      -- secondes d'appui sur « Voler »
	vitesseVoleur = 11,    -- WalkSpeed pendant qu'on porte un dino
	delaiMax = 60,         -- au-delà, le dino rentre chez lui
	distanceLivraison = 0, -- 0 : il suffit d'entrer dans la zone de sa propre Base
}

-- ===== la batte =====
E.batte = { recharge = 1.2, portee = 8, recul = 60, etourdissement = 1.6 }

-- ===== les renaissances =====
function E.coutRenaissance(n) -- n = nombre de renaissances déjà faites
	return 1000000 * 5 ^ n
end
function E.multiplicateurRenaissance(n)
	return 1 + 0.5 * n
end
E.renaissanceMax = 10

-- ===== la boutique (payée en argent du jeu) =====
E.boutique = {
	Bottes = { prix = 5000, nom = "Bottes de course", description = "+4 de vitesse de marche", vitesse = 4 },
	BatteOr = { prix = 25000, nom = "Batte dorée", description = "Recul x1,5 et recharge plus courte", recul = 1.5, recharge = 0.8 },
	Aimant = { prix = 60000, nom = "Aimant à billets", description = "Collecte ta Base à distance toutes les 10 s", intervalle = 10 },
	Radar = { prix = 150000, nom = "Radar à dinos", description = "Signale les dinos Légendaires et plus rares sur le Tapis", rareteMin = "Legendaire" },
}

-- ===== les événements =====
E.evenements = {
	intervalle = 300, -- secondes entre deux événements
	duree = 90,
	liste = {
		PluieDeMeteores = { nom = "Pluie de météores", bonusMutation = { Meteore = 6 }, bonusRarete = 1.5 },
		Eruption = { nom = "Éruption du volcan", bonusMutation = { Lave = 8 }, bonusRarete = 1.3 },
		LuneDoree = { nom = "Lune dorée", bonusMutation = { Or = 30, Diamant = 6 }, bonusRarete = 1.2 },
	},
}

-- ===== les récompenses =====
E.recompenses = {
	tempsDeJeu = { intervalle = 600, gain = 0.25 }, -- toutes les 10 min : 25 % du revenu par minute x 10
	connexion = { base = 500, parJour = 500, max = 7 }, -- série quotidienne
	coffre = { gainMinimum = 1000, secondesDeRevenu = 120, recharge = 86400 },
}

-- ===== l'Index (Dinodex) =====
E.index = { recompenseParEspece = 250, bonusCompletRarete = 0.1 } -- bonus de revenu permanent par rareté complète

E.joueursMax = 8

return E
