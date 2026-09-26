## 1. Principes

- **Ajouts au canon, à valider par Victor Lanoue :** le **Niveau de Survivant** (1 à 30) nourri par l'**XP**, les **Galons**, le **Calendrier de Doc Boulon** et la **Foreuse Turbo**. Aucun autre écart.
- Le niveau n'achète aucune puissance et ne crée aucune source de gemmes. Il fait trois choses : il **verrouille** 3 défenses et le Calendrier, il **révèle** les recherches dans l'Arbre et il **offre** des cosmétiques. Il ne touche plus aux Capsules.
- **Une règle, un affichage :** chaque cadenas affiche exactement la condition vérifiée par le serveur. Le serveur publie `Niveau`, `Galons`, `RecordNormale` et `Colosses` en attributs du `Player`. L'UI les lit, mais aucune règle client ne s'en sert.
- Le serveur calcule toute l'XP. Le client reçoit `NiveauAtteint` et ne peut envoyer qu'une demande : `ReclamerCalendrier`.
- **Jour de jeu :** `Temps.cleJour()` (minuit à Paris) dans les deux places, pour le Calendrier, le bonus de première run et les plafonds quotidiens.
- **Écriture :** `XP`, `DernierBonus`, `Calendrier`, `TurboForeuseFin`, `Cosmetiques` et `Stats` passent uniquement par `Donnees.Modifier` (schéma v2 de a27). Ils sont sauvegardés avec les gemmes à chaque jour franchi et avant le `TeleportAsync` de retour.

## 2. XP et niveaux

**XP pour passer du niveau n au niveau n + 1 = arrondi à 10 de (100 + 60 × n^1,5).** Le niveau 30 est atteint à 116 310 XP au total.

| Source | XP | Multiplicateur de run | Règle |
|---|---|---|---|
| Tutoriel de Doc Boulon | 160 | non | Une seule fois. Il se termine au niveau 2 |
| Jour N franchi | 30 + 10 × N | oui | Toute l'équipe, étourdis compris, si `Economie.estActif` (a07) |
| Colosse vaincu | 150 | oui | Même anti-AFK. Compte comme « 1er Colosse repoussé » |
| Zbire éliminé | 1 | oui | Pour chaque Survivant qui l'a touché dans les 5 dernières secondes. Plafond : 250 par run |
| Réparation | 1 par 20 PV | oui | Plafond : 150 par run |
| Défi du Jour réussi | 300 | non | En plus des 150 gemmes du canon |
| Zbire de la Semaine | 500 | non | Pour une participation, une fois par semaine |
| Secret découvert (a13) | 50 | non | 1re découverte seulement. **Plafond : 200 par jour** |
| Mission hebdomadaire (a49) | 500 | non | **Plafond : 1 000 par jour** (2 missions) |
| Calendrier de Doc Boulon | 250 à 500 | non | Voir §6 |

- **Multiplicateurs de run :** × 2 pour la première run du jour de jeu, et + 10 % par ami Roblox présent dans la Capsule (+ 30 % au maximum). Ils s'appliquent après les plafonds. La partie décimale est reportée sur le gain suivant, donc rien ne se perd à l'arrondi.
- **Anti-AFK :** `Economie.estActif(joueur)` (a07) remplace le seuil de 20 studs et `MarquerActif`. Il conditionne l'XP des jours, celle du Colosse et le Record.
- **Plafond quotidien :** `Ajouter` renvoie l'XP réellement accordée. Si elle vaut 0, a49 laisse la mission réclamable le lendemain, sans rien perdre. Secrets et missions rapportent au plus 1 200 XP par jour, moins que la première run du jour (environ 1 880 XP).
- **Rythme visé** (une run moyenne atteint le Jour 8 et rapporte environ 940 XP sans multiplicateur) :
  - niveau 5 à la fin de la 1re session de 2 runs ;
  - niveau 10 au 3e jour ;
  - niveau 20 vers le 16e jour ;
  - niveau 30 vers la 6e semaine.
- **Réglage :** si les tests s'écartent de plus de 20 % de ce rythme, on ajuste le coefficient 60, jamais les sources.
- **Montée de niveau :**
  - en run, un bandeau non bloquant de 2 s et un jingle 8-bit ;
  - au Laboratoire, Doc Boulon applaudit, la plaque d'Alcôve se met à jour et des confettis cubiques jaillissent (`ParticleEmitter:Emit(30)`).

## 3. Ce que le niveau ouvre

### 3.1 Verrous vérifiés par le serveur (cadenas pour a28)

| Clé | Niv | Refus serveur | Cadenas fourni à a28 |
|---|---|---|---|
| `Muret` | 1 | Pose | Jamais affiché |
| `TapisCollant` | 2 | Pose | « Niv. 2 » sur le bouton |
| `Calendrier` | 3 | `ReclamerCalendrier` | « Niv. 3 » sur la console (`ProximityPrompt.Enabled = false`) |
| `MiniTourelle` | 4 | Pose | « Niv. 4 » sur le bouton |

**Cadenas :**
- **Aspect :** un voile `Frame` Ardoise #4A4560 (`BackgroundTransparency` 0,35) couvre le bouton de 60 × 60 px minimum. Il porte une icône de cadenas Crème #F6E7C1 à 50 % de la hauteur et, en bas, un `TextLabel` « Niv. X » Crème (`TextScaled`).
- **Affichage :** tant que `LocalPlayer:GetAttribute("Niveau") < X`, mis à jour par `GetAttributeChangedSignal("Niveau")`.
- **Appui :** le bouton rebondit (écrasement × 0,8 en 0,15 s) et une bulle affiche « Débloqué au niveau X ». Aucune demande n'est envoyée au serveur.
- **Couleur :** jamais d'Alerte, car un cadenas n'est pas un danger.

### 3.2 Recherches révélées dans l'Arbre

| Recherche | Révélée au niveau | Prix (a07) |
|---|---|---|
| Tourelle de toit | 1 | 40 gemmes |
| Visée critique | 3 | 2e prix |
| Balles perforantes | 4 | 3e prix |
| Foreuse (niveau 1 sur 5) | 5 | 100 gemmes |

- **Ordre :** les recherches apparaissent dans l'ordre des prix. La Foreuse arrive en fin de 1re session, pour produire dès la première nuit (8 h au maximum).
- **Pas de cadenas :** une recherche non révélée n'apparaît pas dans l'Arbre. L'achat (a07) refuse quand même toute recherche pour laquelle `EstRevelee` est faux.
- **Premier retour :** Doc Boulon désigne la Tourelle de toit avec un `Highlight` (`FillColor` Or #FFC933, `OutlineColor` Crème), sur son nœud et sur l'emplacement de sa machine dans l'Alcôve. C'est l'étape `PremiereRecherche` de a50.
- **Arbitrage :** j'applique la consigne du chef de projet (Foreuse au niveau 5), et non la variante QA (Foreuse au 2, Visée au 6, Balles au 8), qui ne respectait pas l'ordre des prix.

### 3.3 Capsules : une seule condition, jamais le niveau

| Capsule | Condition (serveur = affichage) | Texte du SurfaceGui |
|---|---|---|
| Normale | Aucune | « Ouverte à tous » |
| Difficile | `Stats.RecordNormale` ≥ 10 | « Record Jour 10 en Normale · Toi : Jour 7 » |
| du Jour | `Stats.Colosses` ≥ 1 | « Repousse ton 1er Colosse » |

- **Défi du Jour :** il a la même condition que la Capsule du Jour. a07 appelle `CapsuleOuverte(j, "DuJour")`.
- **Record :** `RecordNormale` est le plus haut jour atteint en Normale (jour N franchi → N + 1). C'est la même mesure que le « Record : Jour X » de la Maison.
- **Embarquement :** chaque passager est vérifié. Un Survivant refusé est reposé sur le Quai et le SurfaceGui lui rappelle la condition. Les autres partent sans lui.
- **SurfaceGui :** un par Capsule dans `StarterGui` (`ResetOnSpawn = false`), avec ces propriétés : `Adornee` = `Workspace.Quai.<Capsule>.Panneau`, `Face = Front`, `SizingMode = PixelsPerStud`, `PixelsPerStud = 50`, `LightInfluence = 0`. Chaque enfant voit son propre état, lu dans les attributs `RecordNormale` et `Colosses`. Capsule ouverte : texte Or. Capsule fermée : texte Crème sur fond Ardoise.

### 3.4 Les 30 niveaux

| Niv | XP totale | Déblocage |
|---|---|---|
| 1 | 0 | **Blaster, Sac à dos, Muret**, **Tourelle de toit** révélée, plaque d'Alcôve « Niv. 1 » |
| 2 | 160 | **Tapis Collant** |
| 3 | 430 | **Calendrier de Doc Boulon**, **Visée critique** révélée |
| 4 | 840 | **Mini-Tourelle**, **Balles perforantes** révélées |
| 5 | 1 420 | **Foreuse** révélée, titre « Recrue » |
| 6 | 2 190 | Cadre de plaque d'Alcôve « Cubes Prairie » |
| 7 | 3 170 | Blaster « Toit orange » |
| 8 | 4 380 | Sac à dos « Boîte à outils » |
| 9 | 5 840 | Sac à dos « Panier pique-nique » |
| 10 | 7 560 | Titre « Défenseur », tapis néon d'Alcôve |
| 11 | 9 560 | Roue des Pings au style « 8-bit » (mêmes 4 messages) |
| 12 | 11 850 | Blaster « Prairie » |
| 13 | 14 440 | Emote « Rebond » |
| 14 | 17 350 | Traînée de tir « Confettis crème » |
| 15 | 20 590 | Titre « Vétéran », fanion orange animé d'Alcôve |
| 16 | 24 180 | Sac à dos « Mini-Foreuse » |
| 17 | 28 120 | Effet d'étourdissement « Étoiles rétro » |
| 18 | 32 430 | Tenue « Blouse de labo » |
| 19 | 37 110 | Distributeur de pop-corn d'Alcôve |
| 20 | 42 180 | Blaster « Liseré d'or », titre « Gardien de la Maison », cadre d'Alcôve doré |
| 21 | 47 650 | Effet de réparation « Clé géante » |
| 22 | 53 520 | Emote « Salut de Doc Boulon » |
| 23 | 59 810 | Sac à dos « Mini-Maison » |
| 24 | 66 530 | Traînée de tir « Pixels Prairie et orange » |
| 25 | 73 680 | Titre « Chef d'équipe », panneau d'Alcôve « Record : Jour X » |
| 26 | 81 280 | Tenue « Combinaison Nuit labo » |
| 27 | 89 330 | Apparence de Muret « Briques orange » |
| 28 | 97 850 | Emote « Danse 8-bit » |
| 29 | 106 840 | Apparence de Mini-Tourelle « Hélice » |
| 30 | 116 310 | Titre « Légende de Zsurvie », Blaster « Bloc de Légende », **Galons** |

**Règles cosmétiques :**
- jamais de Violet horde ni d'Alerte ;
- une apparence de défense garde la silhouette, la taille et la hitbox d'origine ;
- l'étourdissement dure toujours 2 s.

## 4. Vérification : le novice tombé au Colosse du Jour 5

**Hypothèses :** première run du jour (× 2), sans ami, jours 1 à 4 franchis.

| Poste | Faible | Estimation QA | Maximum |
|---|---|---|---|
| Tutoriel | 160 | 160 | 160 |
| Jours 1 à 4 : (40 + 50 + 60 + 70) × 2 | 440 | 440 | 440 |
| Éliminations × 2 | 240 | 500 (plafond) | 500 |
| Réparations × 2 | 0 | 0 | 300 (plafond) |
| **Total** | **840** | **1 100** | **1 400** |
| **Niveau** (le 5 demande 1 420) | **4** | **4** | **4** |

- **Recherches visibles :** Tourelle de toit, Visée critique et Balles perforantes. La Tourelle est visible quel que soit le score, puisqu'elle est révélée au niveau 1. Même sans aucune élimination (600 XP, niveau 3), le novice a quelque chose à acheter.
- **Gemmes :** a07 garantit un plancher de 40 gemmes à la première run, et la QA estime le solde au J5 à 74 gemmes. La Tourelle de toit (40 gemmes) est donc achetable, avec 0 à 34 gemmes de reste.
- **Ordre au retour :** Doc Boulon désigne d'abord la Tourelle de toit, puis le Calendrier (case 1 : + 250 XP). Seul un novice à 1 170 XP ou plus passe alors au niveau 5. La Foreuse apparaît, mais reste hors de prix.
- **Fin de 1re session :** la 2e run (× 1, environ 940 XP) fait passer le novice de 1 350 à 2 290 XP, soit le niveau 6. La Foreuse est révélée au 2e retour. a07 confirme que le solde de gemmes atteint alors 100.

## 5. Prestige : les Galons

- **Pas de renaissance destructive.** La run tient déjà ce rôle, et effacer les recherches détruirait les machines de l'Alcôve (pilier 3).
- Au niveau 30, chaque tranche de **10 000 XP** donne **1 Galon**, sans rien perdre.
- **Rangs :** Bronze (1 à 4), Argent (5 à 9), Or (10 à 19) et Gemme (20 et plus). Le rang s'affiche à côté du titre et sur la plaque d'Alcôve.
- Tous les 5 Galons, le joueur gagne une variante de couleur de la Charte pour un cosmétique qu'il possède. Les Galons ne donnent aucun bonus de jeu.

## 6. Récompenses quotidiennes

Le jour de jeu suit `Temps.cleJour()` : il change à minuit, heure de Paris (heure d'été comprise), dans les deux places, comme pour le Zbire de la Semaine. Doc Boulon guide le retour du joueur dans cet ordre :

1. récolte de la Foreuse (8 h hors connexion au maximum) ;
2. Calendrier de Doc Boulon (dès le niveau 3) ;
3. Défi du Jour (après le 1er Colosse repoussé) ;
4. première run du jour : XP × 2.

| Case | Récompense |
|---|---|
| 1 | 250 XP |
| 2 | Foreuse Turbo : production × 2 pendant 8 h (400 XP pour qui n'a pas encore de Foreuse) |
| 3 | 350 XP |
| 4 | Couleur de la Roue des Pings (cycle de 4) |
| 5 | 500 XP |
| 6 | Foreuse Turbo (même règle) |
| 7 | Chapeau-figurine du Zbire de la Semaine, en Crème et Toit orange |

- **Jour manqué :** il met le Calendrier en pause, sans jamais le remettre à zéro.
- **Transparence :** toutes les récompenses sont affichées d'avance. Aucun tirage au hasard, et rien ne s'achète avec des Robux.
- **Contrôle de la Turbo (validation a07) :**
  - au plus 2 Turbos par période de 7 jours de jeu, soit un gain maximal de 16 h de production par semaine ;
  - pour un joueur qui récolte ses 8 h chaque jour (56 h par semaine), c'est + 28,6 % à tous les niveaux de la Foreuse, car le gain est proportionnel à la production ;
  - a07 convertit ce gain en gemmes au niveau 5 de la Foreuse. S'il dépasse son budget, la Turbo passe à 4 h (+ 14,3 %) et le nombre de cases ne change pas.
- **Calcul de la Turbo :** `TurboForeuseFin` est un horodatage `os.time()`. a07 double la production sur la période commune à [dernière récolte, maintenant] et [`TurboForeuseFin` − 8 h, `TurboForeuseFin`].

## 7. Badges

**Attribution :** par le serveur, avec `BadgeService:AwardBadge` sous `pcall`. On peut créer 5 badges par jour, donc il faut 2 jours pour les 10. Icônes 512 × 512 en Pixel-bloc. Les compteurs cumulés sont rangés dans `Stats`.

| # | Badge | Condition |
|---|---|---|
| 1 | Bienvenue au Labo | Terminer le tutoriel de Doc Boulon |
| 2 | Premier Colosse | Repousser un Colosse |
| 3 | Jour 12 | Franchir le Jour 12 |
| 4 | Brise-casque | Éliminer 100 Casqués d'un coup critique (au total) |
| 5 | Équipe complète | Franchir le Jour 5 dans une Capsule de 6 Survivants |
| 6 | Mécano | Réparer 5 000 PV de Maison (au total) |
| 7 | Savant fou | Posséder les 4 recherches |
| 8 | Défi relevé | Réussir 7 Défis du Jour |
| 9 | Rendez-vous du samedi | Participer à un Zbire de la Semaine |
| 10 | Légende de Zsurvie | Atteindre le niveau 30 |

## 8. Code serveur

**Emplacement :** `ServerScriptService.ProgressionService` (ModuleScript), requis dans les deux places.

**API de a27 supposée ici :** `Donnees.Lire(joueur, cle)` et `Donnees.Modifier(joueur, cle, fn)`, appliqués de façon synchrone au profil en cache.

**Branchements :**
- **Prairie :**
  - `DemarrerRun(j, equipe)` à l'arrivée ;
  - l'événement serveur `JourFranchi` → `Progression.JourFranchi(j, capsule, N)` ;
  - `ColosseVaincu` → `Progression.ColosseVaincu(j)` ;
  - `ZbireElimine` → `Ajouter(j, "Elimination", 1)` pour chaque contributeur ;
  - la réparation appelle `Ajouter(j, "Reparation", 1)` tous les 20 PV ;
  - chaque pose de défense vérifie `EstDebloque`.
- **Laboratoire :**
  - `Charger(j)` après le chargement des données (a27) ;
  - `ReclamerCalendrier.OnServerInvoke` appelle `Progression.ReclamerCalendrier` ;
  - l'embarquement vérifie `CapsuleOuverte` ;
  - l'achat d'une recherche (a07) vérifie `EstRevelee`.
- **Autres appelants :**
  - a13 : `Ajouter(j, "Secret", 50)` ;
  - a49 : `Ajouter(j, "Mission", 500)` ;
  - a07 : `Ajouter(j, "DefiDuJour", 300)` et `Ajouter(j, "ZbireSemaine", 500)` ;
  - a50 : `Ajouter(j, "Tutoriel", 160)`.

```lua
-- ServerScriptService.ProgressionService (ModuleScript)
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Donnees = require(ServerScriptService.Donnees) -- a27, schéma v2
local Economie = require(ServerScriptService.Economie) -- a07
local Temps = require(ReplicatedStorage.Temps) -- cleJour() : minuit à Paris
local NiveauAtteint = ReplicatedStorage.Remotes.NiveauAtteint :: RemoteEvent

local NIVEAU_MAX, XP_PAR_GALON = 30, 10000
local BADGE_LEGENDE = 0 -- BadgeId « Légende de Zsurvie »
local VERROUS = { Muret = 1, TapisCollant = 2, Calendrier = 3, MiniTourelle = 4 }
local REVELATION = { TourelleDeToit = 1, ViseeCritique = 3, BallesPerforantes = 4, Foreuse = 5 }
local PLAFONDS_RUN = { Elimination = 250, Reparation = 150 }
local PLAFONDS_JOUR = { Secret = 200, Mission = 1000 }
local MULTIPLIEES = { Jour = true, Colosse = true, Elimination = true, Reparation = true }
local CALENDRIER = { { XP = 250 }, { Turbo = true }, { XP = 350 }, { Cosmetique = "CouleurPing" },
	{ XP = 500 }, { Turbo = true }, { Cosmetique = "ChapeauSemaine" } }

type Run = { mult: number, reste: number, Elimination: number, Reparation: number }

local Progression = {}
local runs: { [Player]: Run } = {}

local seuils = { 0 }
for n = 1, NIVEAU_MAX - 1 do
	seuils[n + 1] = seuils[n] + math.floor((100 + 60 * n ^ 1.5) / 10 + 0.5) * 10
end

function Progression.Niveau(xp: number): (number, number)
	for n = NIVEAU_MAX, 1, -1 do
		if xp >= seuils[n] then
			return n, if n == NIVEAU_MAX then math.floor((xp - seuils[n]) / XP_PAR_GALON) else 0
		end
	end
	return 1, 0
end

local function niveauDe(joueur: Player): number
	return (Progression.Niveau(Donnees.Lire(joueur, "XP") or 0))
end

local function publier(joueur: Player) -- attributs d'affichage uniquement
	local niv, gal = Progression.Niveau(Donnees.Lire(joueur, "XP") or 0)
	local stats = Donnees.Lire(joueur, "Stats") or {}
	joueur:SetAttribute("Niveau", niv)
	joueur:SetAttribute("Galons", gal)
	joueur:SetAttribute("RecordNormale", stats.RecordNormale or 0)
	joueur:SetAttribute("Colosses", stats.Colosses or 0)
end

local function majStats(joueur: Player, fn: (any) -> ())
	Donnees.Modifier(joueur, "Stats", function(s)
		s = s or {}
		fn(s)
		return s
	end)
	publier(joueur)
end

function Progression.Charger(joueur: Player)
	publier(joueur)
end

function Progression.Liberer(joueur: Player)
	runs[joueur] = nil
end

function Progression.EstDebloque(joueur: Player, cle: string): boolean
	return niveauDe(joueur) >= (VERROUS[cle] or math.huge)
end

function Progression.EstRevelee(joueur: Player, recherche: string): boolean
	return niveauDe(joueur) >= (REVELATION[recherche] or math.huge)
end

function Progression.CapsuleOuverte(joueur: Player, capsule: string): boolean
	local s = Donnees.Lire(joueur, "Stats") or {}
	if capsule == "Normale" then return true end
	if capsule == "Difficile" then return (s.RecordNormale or 0) >= 10 end
	if capsule == "DuJour" then return (s.Colosses or 0) >= 1 end -- vaut aussi pour le Défi du Jour
	return false
end

function Progression.DemarrerRun(joueur: Player, equipe: { Player })
	local cle, premiere = Temps.cleJour(), false
	Donnees.Modifier(joueur, "DernierBonus", function(dernier)
		premiere = dernier ~= cle
		return cle
	end)
	local amis = 0
	for _, autre in equipe do
		if autre ~= joueur then
			local ok, ami = pcall(joueur.IsFriendsWith, joueur, autre.UserId)
			if ok and ami then amis += 1 end
		end
	end
	runs[joueur] = {
		mult = (if premiere then 2 else 1) * (1 + 0.1 * math.min(amis, 3)),
		reste = 0, Elimination = 0, Reparation = 0,
	}
end

-- Renvoie l'XP réellement accordée (0 si plafond atteint).
function Progression.Ajouter(joueur: Player, source: string, montant: number): number
	if montant <= 0 or joueur.Parent == nil then return 0 end
	local run = runs[joueur]
	local plafond = PLAFONDS_RUN[source]
	if plafond then
		if not run then return 0 end
		montant = math.min(montant, plafond - run[source])
		if montant <= 0 then return 0 end
		run[source] += montant
	end
	local plafondJour = PLAFONDS_JOUR[source]
	if plafondJour then
		local cle, accorde = Temps.cleJour(), 0
		majStats(joueur, function(s)
			if not s.XPJour or s.XPJour.Cle ~= cle then
				s.XPJour = { Cle = cle, Secret = 0, Mission = 0 }
			end
			accorde = math.max(0, math.min(montant, plafondJour - s.XPJour[source]))
			s.XPJour[source] += accorde
		end)
		montant = accorde
		if montant <= 0 then return 0 end
	end
	if MULTIPLIEES[source] and run then
		local brut = montant * run.mult + run.reste
		montant = math.floor(brut)
		run.reste = brut - montant
	end
	local xp0, xp1 = 0, 0
	Donnees.Modifier(joueur, "XP", function(xp)
		xp0 = xp or 0
		xp1 = xp0 + montant
		return xp1
	end)
	local niv0, gal0 = Progression.Niveau(xp0)
	local niv1, gal1 = Progression.Niveau(xp1)
	if niv1 > niv0 or gal1 > gal0 then
		publier(joueur)
		NiveauAtteint:FireClient(joueur, niv1, gal1)
	end
	if niv1 == NIVEAU_MAX and niv0 < NIVEAU_MAX then
		task.spawn(pcall, BadgeService.AwardBadge, BadgeService, joueur.UserId, BADGE_LEGENDE)
	end
	return montant
end

function Progression.JourFranchi(joueur: Player, capsule: string, n: number)
	if not Economie.estActif(joueur) then return end -- anti-AFK a07
	if capsule == "Normale" then
		majStats(joueur, function(s) s.RecordNormale = math.max(s.RecordNormale or 0, n + 1) end)
	end
	Progression.Ajouter(joueur, "Jour", 30 + 10 * n)
end

function Progression.ColosseVaincu(joueur: Player)
	if not Economie.estActif(joueur) then return end
	majStats(joueur, function(s) s.Colosses = (s.Colosses or 0) + 1 end)
	Progression.Ajouter(joueur, "Colosse", 150)
end

function Progression.ReclamerCalendrier(joueur: Player): number?
	if not Progression.EstDebloque(joueur, "Calendrier") then return nil end
	local cle = Temps.cleJour()
	local case: number? = nil
	Donnees.Modifier(joueur, "Calendrier", function(cal)
		if cal.DernierJour ~= cle then -- une case par jour de Paris
			cal.DernierJour = cle
			cal.Case = cal.Case % 7 + 1 -- jour manqué = pause, jamais de remise à zéro
			case = cal.Case
		end
		return cal
	end)
	if not case then return nil end
	local r = CALENDRIER[case]
	local foreuse = (Donnees.Lire(joueur, "Recherches") or {}).Foreuse or 0 -- niveau 0 à 5
	if r.Turbo and foreuse < 1 then r = { XP = 400 } end
	if r.XP then Progression.Ajouter(joueur, "Calendrier", r.XP) end
	if r.Turbo then
		Donnees.Modifier(joueur, "TurboForeuseFin", function() return os.time() + 8 * 3600 end)
	end
	if r.Cosmetique then
		Donnees.Modifier(joueur, "Cosmetiques", function(c)
			c = c or {}
			c[r.Cosmetique] = (c[r.Cosmetique] or 0) + 1
			return c
		end)
	end
	return case
end

return Progression
```
