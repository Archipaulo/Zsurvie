-- Tous les chiffres du jeu. Les modules lisent ces valeurs : ne jamais les recopier en dur ailleurs.
--
-- Courbe visée (joueur actif, 8 joueurs sur le serveur) :
--   premiers achats dès l'arrivée (100 $ de départ = un Compy + un Galli tout de suite),
--   premier Rare vers 3-4 min, premier Épique vers 10 min, premier Légendaire vers 30-45 min,
--   première renaissance vers 1 h 30, Mythique entre 1 h et 2 h, Divin au-delà de 2 h 30.
-- Règle de prix : prix = revenu x rentabilité, la rentabilité (secondes pour rembourser un dino)
-- monte avec la rareté : Commun ~25-32 s, Rare ~40-47 s, Épique ~55-63 s, Légendaire ~71-77 s,
-- Mythique ~82-86 s, Divin ~88-89 s, Secret 90 s.
-- Le revenu est multiplié par ~6 à ~25 d'une rareté à la suivante : avec 8 emplacements,
-- remplir sa Base d'une rareté ne suffit pas, il faut monter de rareté pour progresser.
-- Chiffres vérifiés par simulation (tapis partagé, 15 à 20 % des dinos accessibles au joueur,
-- revente du plus faible à 50 %) : Épique 9-10 min, Légendaire 26-30 min, 150 M $ vers 75-93 min
-- (médianes) ; les trajets et les vols réels ajoutent de 10 à 30 %.
local E = {}

-- ===== les raretés =====
-- poids : chance relative d'apparaître sur le Tapis ; ordre : pour trier les listes
-- Total ~100, un dino toutes les 2,2 s :
--   Légendaire 2,4 % -> un toutes les ~90 s (on en voit souvent, on en rêve),
--   Mythique 0,5 % -> un toutes les ~7 min, Divin 0,1 % -> un toutes les ~37 min,
--   Secret 0,015 % -> un toutes les ~4 h de serveur (moment mémorable).
E.raretes = {
	Commun = { ordre = 1, poids = 64, nom = "COMMUN" },
	Rare = { ordre = 2, poids = 25, nom = "RARE" },
	Epique = { ordre = 3, poids = 8, nom = "ÉPIQUE" },
	Legendaire = { ordre = 4, poids = 2.4, nom = "LÉGENDAIRE" },
	Mythique = { ordre = 5, poids = 0.5, nom = "MYTHIQUE" },
	Divin = { ordre = 6, poids = 0.1, nom = "DIVIN" },
	Secret = { ordre = 7, poids = 0.015, nom = "SECRET" },
}

-- ===== les espèces =====
-- prix ($), revenu ($ par seconde dans une Base), taille (facteur d'échelle du modèle), famille (qui fabrique le modèle)
-- Entre parenthèses : rentabilité = prix / revenu.
-- Communs : 25 à 160 $ (25-32 s), achetables dans les premières secondes.
-- Rares : 600 à 1 700 $ (40-47 s) ; une Base de 8 Communs (~30 $/s) en paie un en 20 à 60 s.
-- Épiques : 12 k à 25 k $ (55-63 s) ; une Base de Rares (~200 $/s) en paie un en 1 à 2 min.
-- Légendaires : 500 k à 925 k $ (71-77 s) ; il faut une Base pleine d'Épiques (~2,4 k $/s)
--   et environ 4 à 6 min d'économies : c'est le grand objectif de la première demi-heure.
-- Mythiques : 8,2 M et 12 M $ (82-86 s) ; Divins : 88 M et 125 M $ (88-89 s) ;
-- Secret : 1,08 Md $ (90 s), le trophée ultime (après plusieurs renaissances).
E.especes = {
	-- herbivores (Builders/DinosHerbivores)
	Galli = { nom = "Galli", rarete = "Commun", prix = 55, revenu = 2, taille = 0.9, famille = "Herbivore" }, -- 27,5 s
	Pachy = { nom = "Pachy", rarete = "Commun", prix = 85, revenu = 3, taille = 1, famille = "Herbivore" }, -- 28 s
	Tricera = { nom = "Tricéra", rarete = "Commun", prix = 160, revenu = 5, taille = 1.1, famille = "Herbivore" }, -- 32 s
	Stego = { nom = "Stégo", rarete = "Rare", prix = 600, revenu = 15, taille = 1.2, famille = "Herbivore" }, -- 40 s
	Parasaure = { nom = "Parasaure", rarete = "Rare", prix = 1250, revenu = 28, taille = 1.1, famille = "Herbivore" }, -- 44,6 s
	Ankylo = { nom = "Ankylo", rarete = "Epique", prix = 12000, revenu = 220, taille = 1.2, famille = "Herbivore" }, -- 54,5 s
	Iguano = { nom = "Iguano", rarete = "Epique", prix = 25000, revenu = 400, taille = 1.3, famille = "Herbivore" }, -- 62,5 s
	Brachio = { nom = "Brachio", rarete = "Legendaire", prix = 675000, revenu = 9000, taille = 1.6, famille = "Herbivore" }, -- 75 s
	Diplodo = { nom = "Diplodo", rarete = "Mythique", prix = 8200000, revenu = 100000, taille = 1.7, famille = "Herbivore" }, -- 82 s
	Therizino = { nom = "Thérizino", rarete = "Divin", prix = 88000000, revenu = 1000000, taille = 1.6, famille = "Herbivore" }, -- 88 s
	-- carnivores, volants et marins (Builders/DinosCarnivores)
	Compy = { nom = "Compy", rarete = "Commun", prix = 25, revenu = 1, taille = 0.7, famille = "Carnivore" }, -- 25 s, le tout premier achat
	Raptor = { nom = "Raptor", rarete = "Commun", prix = 120, revenu = 4, taille = 0.9, famille = "Carnivore" }, -- 30 s
	Dilopho = { nom = "Dilopho", rarete = "Rare", prix = 850, revenu = 20, taille = 1.1, famille = "Carnivore" }, -- 42,5 s
	Ptero = { nom = "Ptéro", rarete = "Rare", prix = 1700, revenu = 36, taille = 1, famille = "Carnivore" }, -- 47 s
	Carno = { nom = "Carno", rarete = "Epique", prix = 17500, revenu = 300, taille = 1.2, famille = "Carnivore" }, -- 58 s
	Spino = { nom = "Spino", rarete = "Legendaire", prix = 500000, revenu = 7000, taille = 1.5, famille = "Carnivore" }, -- 71 s
	Rex = { nom = "Rex", rarete = "Legendaire", prix = 925000, revenu = 12000, taille = 1.6, famille = "Carnivore" }, -- 77 s
	Mosa = { nom = "Mosa", rarete = "Mythique", prix = 12000000, revenu = 140000, taille = 1.6, famille = "Carnivore" }, -- 85,7 s
	Giga = { nom = "Giga", rarete = "Divin", prix = 125000000, revenu = 1400000, taille = 1.9, famille = "Carnivore" }, -- 89 s
	Cosmosaure = { nom = "Cosmosaure", rarete = "Secret", prix = 1080000000, revenu = 12000000, taille = 2, famille = "Carnivore" }, -- 90 s
}

-- ===== les mutations =====
-- multiplicateur de prix et de revenu ; poids : chance relative (Normal compris) ; evenement : n'existe que pendant cet événement
-- Le multiplicateur s'applique au prix ET au revenu : la rentabilité ne change pas, l'économie
-- reste saine. Une mutation fait rêver parce qu'elle fait sauter une marche : un Épique
-- Arc-en-ciel (x5) rapporte autant qu'un tiers de Légendaire, et c'est la cible n° 1 des voleurs.
-- Hors événement (total 99,7) : Or 8 %, Diamant 3 %, Arc-en-ciel 0,7 % (un toutes les ~5 min).
E.mutations = {
	Normal = { multiplicateur = 1, poids = 88, nom = "" },
	Or = { multiplicateur = 1.5, poids = 8, nom = "Or" },
	Diamant = { multiplicateur = 2.5, poids = 3, nom = "Diamant" },
	ArcEnCiel = { multiplicateur = 5, poids = 0.7, nom = "Arc-en-ciel" },
	Lave = { multiplicateur = 3, poids = 0, nom = "Lave", evenement = "Eruption" },
	Meteore = { multiplicateur = 6, poids = 0, nom = "Météore", evenement = "PluieDeMeteores" },
}

-- ===== le Tapis =====
-- 2,2 s entre deux dinos et ~32 s de traversée : ~15 dinos visibles en permanence,
-- assez de choix pour 8 joueurs sans noyer les raretés.
E.tapis = {
	intervalle = 2,    -- secondes minimum entre deux dinos (le Tapis attend en plus 6 studs libres derrière le précédent)
	vitesse = 7,       -- studs par seconde (environ 32 s pour traverser)
	maxDinos = 24,     -- plafond de dinos présents sur le tapis (performances : ≈ 200 parts par dino)
	vitesseMarche = 14, -- vitesse d'un dino acheté qui rejoint sa Base
}

-- ===== les Bases =====
-- Verrou de 60 s puis 15 s de recharge : une fenêtre de vol de 15 s par minute au mieux,
-- et le propriétaire doit être chez lui pour relancer le verrou : partir au Tapis, c'est prendre un risque.
E.base = {
	emplacementsDepart = 8,  -- emplacements utilisables sans renaissance (max Plan.base.emplacementsMax)
	emplacementsParRenaissance = 1, -- 12 emplacements atteints à la 4e renaissance
	dureeVerrou = 60,        -- secondes de verrouillage
	recharge = 15,           -- secondes entre la fin d'un verrou et le suivant
}

-- ===== l'argent =====
E.argentDepart = 100 -- un Compy (25 $) + un Galli (55 $) dès la première seconde
E.vente = { part = 0.5 } -- revendre un dino rapporte la moitié de son prix (libère une place, sans être une ferme à argent)

-- ===== le vol =====
-- Tentant : un vol rapporte un dino entier gratuitement (un Légendaire volé = 5 à 15 min de revenu).
-- Risqué : 1,5 s d'appui dans la Base adverse, puis retour à 11 de vitesse (16 pour le propriétaire,
-- 20 avec les Bottes) : la victime rattrape le voleur en quelques secondes et la batte fait tout lâcher.
E.vol = {
	dureeAppui = 1.5,      -- secondes d'appui sur « Voler »
	vitesseVoleur = 11,    -- WalkSpeed pendant qu'on porte un dino
	delaiMax = 45,         -- au-delà, le dino rentre chez lui (une traversée de carte prend ~20 s à 11 studs/s)
	distanceLivraison = 0, -- 0 : il suffit d'entrer dans la zone de sa propre Base
}

-- ===== la batte =====
-- Une frappe tous les 1,2 s (0,96 s avec la Batte dorée), portée 8 studs : la frappe fait lâcher
-- le butin, c'est l'essentiel. Étourdissement 0,9 s, plus court que la recharge même dorée :
-- la cible retrouve toujours ses jambes avant le coup suivant, pas d'étourdissement en chaîne.
E.batte = { recharge = 1.2, portee = 8, recul = 60, etourdissement = 0.9 }

-- ===== les renaissances =====
-- Première renaissance : 150 M $, soit le prix d'un Divin ; avec ~165 k $/s vers 1 h 30
-- (Base de Légendaires et un ou deux Mythiques), elle tombe vers 1 h 20 - 1 h 40.
-- Ensuite x3 par niveau : 450 M, 1,35 Md, 4,05 Md... ; le multiplicateur (x1,5, x2, x2,5...)
-- et l'emplacement en plus font remonter plus vite à chaque cycle, chaque cycle dure ~1 h.
function E.coutRenaissance(n) -- n = nombre de renaissances déjà faites
	return 150000000 * 3 ^ n
end
function E.multiplicateurRenaissance(n)
	return 1 + 0.5 * n
end
E.renaissanceMax = 10

-- ===== la boutique (payée en argent du jeu) =====
-- Chaque objet coûte 45 à 150 s du revenu attendu au moment où on le découvre :
-- Bottes vers 5 min (~65 $/s), Batte dorée vers 10 min (~400 $/s),
-- Aimant vers 15 min (~1 k $/s), Radar vers 20 min (~1,7 k $/s) pour chasser le premier Légendaire.
E.boutique = {
	Bottes = { prix = 3000, nom = "Bottes Turbo", description = "⚡ +4 de vitesse : file comme un raptor !", vitesse = 4 },
	BatteOr = { prix = 20000, nom = "Batte dorée", description = "💥 Recul x1,5 et frappe plus vite !", recul = 1.5, recharge = 0.8 },
	Aimant = { prix = 90000, nom = "Aimant à billets", description = "💸 Ramasse tes $ à distance toutes les 10 s !", intervalle = 10 },
	Radar = { prix = 250000, nom = "Radar à dinos", description = "📡 Repère les LÉGENDAIRES et mieux sur le Tapis !", rareteMin = "Legendaire" },
}

-- ===== les événements =====
-- Un événement de 90 s toutes les 7 min (~21 % du temps) : rare assez pour être attendu.
-- bonusRarete multiplie les poids Épique et plus : x1,5 pendant 90 s -> environ +10 % d'Épiques
-- et mieux sur la durée, sans casser la courbe.
-- bonusMutation s'ajoute au poids : Météore 5 sur ~105 -> ~4,8 % de dinos x6 pendant la pluie ;
-- Lave 10 sur ~110 -> ~9 % de dinos x3 ; Lune dorée : Or ~26 % et Diamant ~6 %.
E.evenements = {
	intervalle = 420, -- secondes entre deux débuts d'événement
	duree = 90,
	liste = {
		PluieDeMeteores = { nom = "☄️ PLUIE DE MÉTÉORES", bonusMutation = { Meteore = 5 }, bonusRarete = 1.5 },
		Eruption = { nom = "🌋 ÉRUPTION DU VOLCAN", bonusMutation = { Lave = 10 }, bonusRarete = 1.3 },
		LuneDoree = { nom = "🌕 LUNE DORÉE", bonusMutation = { Or = 25, Diamant = 5 }, bonusRarete = 1.2 },
	},
}

-- ===== les récompenses =====
E.recompenses = {
	tempsDeJeu = { intervalle = 600, gain = 0.5 }, -- toutes les 10 min : revenu par minute x 0,5 = 30 s de revenu offertes
	connexion = { base = 500, parJour = 500, max = 7 }, -- série quotidienne : 500 $ le 1er jour, 3 500 $ le 7e (gros coup de pouce du début)
	coffre = { gainMinimum = 2500, secondesDeRevenu = 180, recharge = 86400 }, -- coffre des falaises : 3 min de revenu, une fois par jour
}

-- ===== l'Index (Dinodex) =====
-- Découverte : 50 $ x ordre de rareté (Commun 50 $, Secret 350 $) : un clin d'œil, pas un raccourci
-- (à 250 $ les 5 Communs rapportaient 1 250 $, douze fois l'argent de départ).
-- Rareté complète : +10 % de revenu permanent (jusqu'à +70 % pour le Dinodex complet).
E.index = { recompenseParEspece = 50, bonusCompletRarete = 0.1 } -- bonus de revenu permanent par rareté complète

-- ===== l'étage de la Base =====
-- chaque amélioration ajoute UN podium à l'étage (amélioration 1 : 1 podium, … amélioration 12 : 12 podiums)
E.etages = {
	max = 12,
	hauteur = 12, -- hauteur du plancher de l'étage au-dessus du sol de la Base
}
function E.coutEtage(niveau) -- prix de l'amélioration numéro « niveau » (1 à 12)
	return math.floor(2500 * 2.2 ^ (niveau - 1) + 0.5)
end

E.joueursMax = 8

return E
