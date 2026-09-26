# A05 — Analyse de marché : Zsurvie sur Roblox

## Synthèse

- **Positionnement** : Zsurvie croise trois genres porteurs, le TD coopératif, la survie coop jour/nuit et l'incrémental à collection. **Aucun hit ne combine un survivant qui court et tire, une maison unique partagée et une méta roguelite dans un lobby 3D.** C'est notre créneau.
- **Risque principal** : des runs trop longues et une interface illisible sur téléphone. Cible : run de 12 à 18 min, premier colosse (jour 5) vers la 8e minute.
- **Rétention n°1** : un rendez-vous quotidien et une progression permanente **visible** dans le Laboratoire.

## Panorama concurrentiel

| Jeu | Boucle | Ce qui retient | Faiblesses exploitables |
|---|---|---|---|
| **Tower Defense Simulator** | TD coop 1-4, vagues + boss, tours permanentes | Boss spectaculaires, lobby à ascenseurs, événements saisonniers | Joueur immobile, parties de 25 à 40 min, courbe raide |
| **Anime Vanguards** | TD à unités obtenues par tirage | Tirages, échanges, mises à jour hebdomadaires | Gacha payant, écran surchargé sur mobile |
| **99 Nights in the Forest** | Survie coop 1-5, feu de camp central à améliorer | Objectif chiffré (« 99 nuits »), classes, monstre culte (le Cerf) | Runs très longues, collecte répétitive, peu de méta entre runs |
| **Dead Rails** | Roguelite coop en train, assauts nocturnes | Objectif de run, classes, tension la nuit | Punitif pour les 9-12 ans, perte sèche en cas d'échec |
| **Plants vs Brainrots** | Défense de couloir idle, monstres vaincus collectionnés | Collection de créatures absurdes, progression même inactif | Solo en parallèle, peu de profondeur, dépend d'un mème |
| **Zombie Attack** | Shooter coop par vagues | Prise en main instantanée | Visuels datés, aucune base, aucune méta |
| **Doors** | Roguelite coop 1-4, lobby à ascenseurs | Départ entre amis, monstres à règle unique, boutique d'avant-run | Horreur hors cible pour les 9-11 ans |

### À reprendre

- **Départ par ascenseurs** (TDS, Doors) → 3 « Pods de départ » dans le Laboratoire (Normal / Difficile / Défi quotidien), 1 à 6 places, compte à rebours de 15 s, `TeleportService:ReserveServer` puis `TeleportService:TeleportAsync` avec `TeleportOptions.ReservedServerAccessCode`.
- **Objectif chiffré affiché** (99 Nights) → « Record : jour X » dans un `BillboardGui` géant au-dessus de la maison.
- **Monstres à règle unique** (Doors) → notre bestiaire l'a déjà : le casqué impose les critiques, le gluant se divise, le volant ignore les murets.

### À éviter

- **Gacha payant** : inadapté aux 9-15 ans ; les objets aléatoires payants imposent d'afficher les probabilités et sont restreints dans certains pays.
- **Perte sèche** : quand la maison tombe, on gagne toujours des gemmes proportionnelles au jour atteint.
- **Joueur passif** : le survivant a toujours quelque chose à faire (tirer, réparer, ramasser les pièces).

## Tendances 2025-2026

1. **Survie coop avec compteur** : le jour atteint devient le chiffre qu'on partage.
2. **Collection idle de créatures absurdes** (Grow a Garden, Steal a Brainrot) : progression hors ligne, vitrine sociale.
3. **Live-ops à heure fixe** : mise à jour chaque samedi, compte à rebours dans le lobby, pics de fréquentation.
4. **Chat restreint** : depuis début 2026, le chat Roblox exige une vérification d'âge. Beaucoup de 9-12 ans jouent sans chat, donc **la coop doit marcher avec des pings**.
5. **Monétisation cosmétique** : skins, passes de confort, serveurs privés. Le gacha payant est sous pression réglementaire.
6. **Leviers de retour natifs** : `ExperienceNotificationService` et `SocialService:PromptGameInvite`.

## Public cible réaliste

| Critère | Réalité visée | Conséquence design |
|---|---|---|
| Âge | Cœur 9-13 ans, frange 13-15 | Tout se lit sans texte. Label de maturité **Léger (Mild)** : pas de sang, les monstres éclatent en confettis |
| Plateforme | Téléphone majoritaire (estimation 65-75 %, beaucoup d'Android d'entrée de gamme), PC 15-20 % | Boutons tactiles ≥ 60 px, visée automatique, 80 monstres simultanés au maximum |
| Session | 20 à 35 min : 1 à 2 runs + 3 à 5 min au Laboratoire | Gemmes sauvegardées à chaque jour franchi |
| Groupe | Duos et trios d'amis, beaucoup de solos en matchmaking | PV des monstres × (1 + 0,35 × (joueurs − 1)) |

## 3 opportunités de différenciation

### 1. Le seul TD où l'on court, lisible au téléphone

Dans TDS, le joueur est immobile ; dans Zombie Attack, il n'y a pas de base. Zsurvie réunit les deux.

- **Caméra surélevée** fidèle à l'original : `Camera.CameraType = Enum.CameraType.Scriptable`, décalage (0, 45, 28) studs, `FieldOfView = 50`, zoom de 35 à 60 studs. On voit les hordes arriver de tous côtés.
- **Tir automatique sur mobile** sur le monstre le plus proche dans un rayon de 40 studs. Le client envoie une intention ; le serveur valide la cible, la distance et la cadence.
- **Rôles sans chat** : réparer (maintenir appuyé près de la maison), tirer, poser (3 défenses maximum par joueur).
- **Roue de 4 pings** : « Colosse ! », « Répare ! », « Ici ! », « Merci ! ». Icône 3D visible 5 s, 1 ping par seconde maximum, limité côté serveur.

### 2. Le Laboratoire comme rendez-vous quotidien

Dans 99 Nights et Dead Rails, il n'y a presque rien à faire entre deux runs. Chez nous, le Laboratoire est vivant.

- **Recherches physiques** : chaque recherche (tourelle de toit, balles perforantes, visée critique, foreuse de la mine) apparaît comme une machine animée dans l'alcôve du joueur, visible par tous.
- **Mine idle** : la foreuse produit des gemmes hors ligne, plafonnées à 8 h.
- **Défi quotidien** : 2 modificateurs tirés à partir de la date UTC, identiques sur tous les serveurs, classement du jour (`OrderedDataStore`), 150 gemmes pour la première victoire contre le colosse.

```lua
-- ModuleScript : ServerScriptService/DefiQuotidien
-- Appelé uniquement par le gestionnaire de partie côté serveur.
local DataStoreService = game:GetService("DataStoreService")

local DefiQuotidien = {}

local recompenses = DataStoreService:GetDataStore("DefiQuotidien_v1")
local RECOMPENSE_GEMMES = 150
local MODIFICATEURS = {
	{ id = "GluantsTriples", texte = "Les gluants se divisent en trois" },
	{ id = "RueeDoree", texte = "Dorés x3, gemmes x2" },
	{ id = "Blindage", texte = "30 % de casqués blindés" },
	{ id = "Ressorts", texte = "Sauteurs +50 % de vitesse" },
	{ id = "ColossePresse", texte = "Colosse dès le jour 3" },
	{ id = "CielCharge", texte = "Deux fois plus de volants" },
}

function DefiQuotidien.jourUTC(): number
	return os.time() // 86400
end

-- Même tirage sur tous les serveurs pour un jour donné
function DefiQuotidien.modificateurs(jour: number): { { id: string, texte: string } }
	local rng = Random.new(jour)
	local pool = table.clone(MODIFICATEURS)
	local choisis = {}
	for _ = 1, 2 do
		table.insert(choisis, table.remove(pool, rng:NextInteger(1, #pool)))
	end
	return choisis
end

-- `jour` est figé au lancement de la partie : une run à cheval sur minuit reste valide
function DefiQuotidien.recompenser(joueur: Player, jour: number, ajouterGemmes: (Player, number) -> ()): boolean
	local premiereFois = false
	local ok, err = pcall(function()
		recompenses:UpdateAsync(tostring(joueur.UserId), function(dernierJour)
			if dernierJour == jour then
				premiereFois = false
				return nil -- déjà récompensé aujourd'hui : écriture annulée
			end
			premiereFois = true
			return jour
		end)
	end)
	if not ok then
		warn("[DefiQuotidien]", err)
		return false
	end
	if premiereFois then
		ajouterGemmes(joueur, RECOMPENSE_GEMMES)
	end
	return premiereFois
end

return DefiQuotidien
```

À terme, ce drapeau rejoindra le profil joueur pour que les gemmes et le jour soient écrits en une seule opération.

### 3. Le bestiaire rigolo comme collection, sans gacha

Plants vs Brainrots prouve que les joueurs adorent collectionner des créatures drôles. Chez nous, on les collectionne en jouant, jamais en payant.

- **Carnet de bestiaire** : figurines animées des 8 monstres et du colosse sur des socles (`ProximityPrompt` pour la fiche). Paliers de 10, 100 et 1 000 éliminations : variantes cosmétiques (chapeaux, couleurs) qui apparaissent ensuite dans les hordes du joueur.
- **Monstre de la semaine** : une variante spéciale (par exemple un doré géant) chaque samedi à 17 h, heure de Paris, annoncée par un compte à rebours au Laboratoire.
- **Monétisation éthique** : skins de survivant et de maison, apparence de la tourelle de toit, serveurs privés. On ne vend **jamais** de gemmes ni de dégâts : un argument de confiance pour les parents face aux TD gacha.

## Décisions et écarts

- Aucun canon du directeur créatif n'était disponible : noms repris du brief (Zsurvie, Laboratoire, gemmes, pièces, colosse, mine, foreuse, bestiaire).
- « Pods de départ », « Défi quotidien », « Carnet de bestiaire » et « Monstre de la semaine » sont des **noms de travail**, à remplacer par le canon.
- Les chiffres de plateforme sont des estimations à revérifier avant présentation au client.
