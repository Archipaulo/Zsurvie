# Contrat technique — « Dino Chapardeurs » (jeu Roblox)

Ce document est la loi commune des 50 agents. Chacun écrit **un seul fichier**
et ne communique avec les autres **que** par ce qui est décrit ici.

**Le jeu** : chaque joueur reçoit une Base. Des dinos défilent sur un grand
Tapis roulant au milieu du monde ; on les achète, ils rejoignent notre Base et
y produisent de l'argent chaque seconde. On peut **voler** les dinos des autres
en entrant dans leur Base et en les rapportant chez soi — sauf si leur Base est
verrouillée. La **batte** fait lâcher son butin à un voleur. Raretés, mutations,
événements, renaissances, Dinodex, boutique.

## 1. Arborescence (format Rojo)

```
src/ReplicatedStorage/Dino/        -> ReplicatedStorage.Dino (partagé)
  Charte.lua  Plan.lua  Outils.lua  Equilibrage.lua  Reseau.lua  Bus.lua
src/ServerScriptService/Dino/      -> ServerScriptService.Dino
  Demarrage.server.lua             (ne pas modifier)
  Builders/<Nom>.lua               (constructeurs, ModuleScript)
  Systemes/<Nom>.lua               (systèmes serveur, ModuleScript)
src/StarterPlayerScripts/Dino/     -> StarterPlayer.StarterPlayerScripts.Dino
  Client.client.lua                (ne pas modifier)
  Interface/<Nom>.lua              (modules client, ModuleScript)
```

**Lire avant d'écrire** : `Charte.lua` (couleurs, `Charte.raretes`,
`Charte.mutations`, `Charte.argent(n)` pour afficher une somme), `Plan.lua`
(coordonnées), `Outils.lua` (construction : `bloc`, `coin`, `cylindre` dont
l'axe est X, `boule`, `modele`, `surSol`, `texte`, `panneau`, `lumiere`,
`invite`, `animer` ; interface : `cadre`, `etiquette`, `bouton`),
`Equilibrage.lua` (tous les chiffres, espèces, mutations), `Reseau.lua`, `Bus.lua`.

## 2. Forme d'un module

```lua
local M = {}
function M.construire(ctx) ... end  -- Builders : tout va dans ctx.dossier (Workspace.Dino.<Nom>)
function M.demarrer(ctx) ... end    -- Systemes et Interface
return M
```

`ctx` serveur : `Charte, Outils, Plan, Equilibrage, Bus, Reseau` (RemoteEvents),
`Etat` (Folder à attributs), `racine` (Workspace.Dino), `dinos`
(Workspace.Dino.Dinos : **tous** les dinos vivants), `stockage`
(ServerStorage.Dino) ; `dossier` pour un constructeur.
`ctx` client : `Charte, Outils, Plan, Equilibrage, Bus` (bus local),
`Reseau`, `Etat`, `joueur` (LocalPlayer), `gui` (ScreenGui « DinoGui »,
ResetOnSpawn = false), `racine`, `dinos`.

Jamais de `require` d'un autre module de Builders/Systemes/Interface. Les
constructeurs s'exécutent l'un après l'autre (ordre : DinosHerbivores,
DinosCarnivores, Ciel, Sol, Falaises, Jungle, Riviere, Volcan, Tapis, Nurserie,
FinTapis, Bases, Place, Comptoir, Autel, Cratere, Fossiles, Lumieres,
Signaletique), puis les systèmes démarrent chacun dans sa coroutine (ordre :
Donnees, Economie, Bases, Tapis, Enclos, Achat, Vol, Batte, Renaissance,
Boutique, Index, Evenements, Classement, Recompenses, Securite, GardeFou,
Autotest, ModeTest). Un système qui gère les joueurs traite
`Players:GetPlayers()` **et** `Players.PlayerAdded` (et `PlayerRemoving`).
Les invites (ProximityPrompt) se traitent côté serveur avec
`ProximityPromptService.PromptTriggered:Connect(function(invite, joueur) ... end)`
en filtrant **par `invite.Name`** (chaque système ne traite que les siennes).

## 3. Sous-ensemble de Luau autorisé (obligatoire)

Vérifié par un analyseur Lua 5.1 et exécuté dans un simulateur. **Interdits** :
`+=` `-=` `*=` `..=`, `continue`, `goto`, annotations de type, chaînes à accents
graves, `if ... then ... else` en expression, `//`. Utiliser `task.wait`,
`task.spawn`, `task.delay` (jamais `wait`, `spawn`, `delay`). Pas de
`loadstring`/`getfenv`/`setfenv`. Tabulations, commentaires en français sobres.
Heure partagée serveur/client : `workspace:GetServerTimeNow()`.

## 4. Les dinos

**Gabarits** (Builders/DinosHerbivores et Builders/DinosCarnivores) :
`ctx.stockage.Dinos.<Espece>` (clé de `Equilibrage.especes`), un `Model` par
espèce de leur famille, à l'échelle `taille`, style jouet en blocs, toutes les
parts `Anchored`, `CanCollide = false`, `CanQuery = true`. `PrimaryPart` =
part « Corps » ; `Corps.PivotOffset` réglé pour que `GetPivot()` soit **au sol
sous le dino**, regard vers **-Z local**. Parts nommées si possible « Tete »,
« Queue », « PatteAvG », « PatteAvD », « PatteArG », « PatteArD » (et « AileG »,
« AileD » pour les volants). Attribut `Espece`. Pas de BillboardGui.

**Dinos vivants** (dans `ctx.dinos`), fabriqués **uniquement** par
`Bus.demander("CreerDino", espece, mutation)` (Systemes/Tapis). Attributs :

| Attribut | Sens |
|---|---|
| `Id` | texte unique |
| `Espece`, `Rarete`, `Mutation` | clés d'Equilibrage (`Mutation` = "Normal" si aucune) |
| `Prix`, `Revenu` | prix ($) et revenu ($/s) **mutation comprise** (sans bonus du joueur) |
| `Etat` | `"Tapis"`, `"EnRoute"` (acheté, marche vers sa Base), `"Enclos"`, `"Porte"` (volé, sur la tête du voleur) |
| `Proprietaire` | `UserId` du propriétaire (0 si aucun) |
| `Base`, `Emplacement` | index de Base (1..8) et numéro d'emplacement (0 si aucun) |
| `Voleur` | `UserId` du voleur pendant un vol (0 sinon) |
| `Stock` | argent accumulé dans son emplacement, pas encore collecté |

CreerDino ajoute sur Corps un BillboardGui « Etiquette » (nom, rareté colorée,
mutation, prix, revenu) et l'aspect de la mutation. Invites sur Corps (toutes
`RequiresLineOfSight = false`) : **« Acheter »** (posée par Tapis, retirée à
l'achat), **« Voler »** (HoldDuration = `Equilibrage.vol.dureeAppui`) et
**« Vendre »** (posées par Enclos quand le dino est placé).

## 5. Les Bases (Builders/Bases construit, Systemes/Bases gère)

`Workspace.Dino.Bases.Base1` … `Base8` (Models, attribut `Index`), construites
sur `Plan.bases[i]` (44 x 50, sol dessus à Y = `Plan.base.hauteurSol`, entrée
côté Tapis). Enfants **obligatoires** et nommés exactement :

| Enfant | Rôle |
|---|---|
| `Sol` | dalle de la base |
| `Zone` | part invisible (Transparency 1, CanCollide/CanQuery/CanTouch false) couvrant tout le volume de la base (44 x 30 x 50) |
| `Entree` | barrière de l'entrée (laser) : Transparency 1 et CanCollide false par défaut |
| `BoutonVerrou` | gros bouton avec l'invite **« Verrouiller »** |
| `Collecte` | dalle de collecte (marcher dessus = encaisser) |
| `Emplacements` | Folder de parts `E1` … `E12` (podiums) en 2 rangées de 6 le long des murets gauche et droit (E1 gauche, E2 droite au 1er rang côté entrée…) ; les dinos, dos au muret, se font face de part et d'autre de l'allée centrale et sont réduits pour tenir dans leur emplacement (Systemes/Enclos) |
| `Enseigne` | panneau avec SurfaceGui « Affiche » > TextLabel « Titre » (nom du propriétaire) |
| `Apparition` | part invisible où le propriétaire (ré)apparaît |

Attributs posés par Systemes/Bases sur le Model : `Proprietaire` (UserId, 0),
`NomProprietaire`, `Verrouillee` (bool), `FinVerrou` (heure serveur). Sur
chaque `E<n>` : `Debloque` (bool, selon le nombre d'emplacements du joueur).

### Dalles de collecte (Systemes/Enclos)

Devant chaque podium débloqué (côté allée), une dalle verte `C<n>` de la largeur du podium
(dossier `Collectes` de la Base) : quand le propriétaire marche dessus, il encaisse l'argent de
CE dino ; le montant (BillboardGui « Stock ») flotte juste au-dessus de la dalle.

### Étage de la Base (Systemes/Etages)

Borne « Etage » à l'entrée de chaque Base (invite réservée au propriétaire) : chaque
amélioration (prix `Equilibrage.coutEtage(n)`, 12 au maximum) ajoute un podium à l'étage
(E13 à E24, dossier `Emplacements`) ; l'étage (plancher, escalier, garde-corps) apparaît à la
première. Attribut joueur `Etage` (sauvegardé, conservé à la renaissance). Enclos remplit
d'abord le rez-de-chaussée puis l'étage. Événement Bus `EtageAchete(joueur, niveau)`.

## 6. Attributs

`ReplicatedStorage.DinoEtat` : `Evenement` ("" ou clé de
`Equilibrage.evenements.liste`), `EvenementFin`, `ProchainEvenement` (heures
serveur) — Systemes/Evenements ; `DinosSurTapis` — Systemes/Tapis ;
`MeilleurRevenu` — Systemes/Classement.

Joueurs : `Argent` (Economie), `RevenuParSeconde` (Enclos), `Renaissances`
(Renaissance), `Vols` (Vol), `Base` (Bases), `Porte` (Id du dino porté ou "",
Vol), `Etourdi` (bool, Batte), `Objet_<nom>` (bool, Boutique), `Index_<Espece>`
(bool) et `BonusIndex` (nombre, Index), `Serie`, `DerniereConnexion`,
`CoffreOuvert` (Recompenses), `DonneesChargees` (Donnees).
Donnees sauvegarde : Argent, Renaissances, Vols, Objet_*, Index_*, BonusIndex,
Serie, DerniereConnexion, CoffreOuvert, et la liste des dinos du joueur.

## 7. Bus serveur

Notifications (`Bus.emettre` / `Bus.ecouter`) :

| Événement | Émis par | Arguments |
|---|---|---|
| `BaseAttribuee` | Bases | `joueur, index` |
| `BaseLiberee` | Bases | `joueur, index` (le joueur part : Enclos détruit ses dinos) |
| `BaseVerrouillee` | Bases | `index, joueur` |
| `DinoApparu` | Tapis | `dino` |
| `DinoAchete` | Achat | `dino, joueur` |
| `DinoPlace` | Enclos | `dino, joueur, numero` |
| `DinoVendu` | Enclos | `joueur, espece, montant` |
| `VolDebut` | Vol | `dino, voleur, victime` |
| `DinoVole` | Vol | `dino, voleur, victime` (livré chez le voleur) |
| `VolRate` | Vol | `dino, voleur, victime, raison` (le dino rentre chez sa victime) |
| `Frappe` | Batte | `cible, attaquant` |
| `ArgentGagne` | Economie | `joueur, n, source` |
| `Renaissance` | Renaissance | `joueur, niveau` (Enclos vide la Base du joueur) |
| `ObjetAchete` | Boutique | `joueur, nom` |
| `EspeceDecouverte` | Index | `joueur, espece` |
| `EvenementDebut` / `EvenementFin` | Evenements | `nom` |
| `RestaurerDinos` | Donnees | `joueur, liste` ({ {Espece=, Mutation=}, ... }) après chargement **et** attribution de la Base |

Questions (`Bus.demander`, un seul répondeur ; prévoir le retour `nil`) :

| Question | Répondeur | Arguments → retour |
|---|---|---|
| `AjouterArgent` / `DepenserArgent` | Economie | `joueur, n, source` → total / `joueur, n` → `true` si payé |
| `MultiplicateurRevenu` | Economie | `joueur` → renaissances × (1 + BonusIndex) |
| `CreerDino` | Tapis | `espece, mutation` → Model dans ctx.dinos (Etat à poser par l'appelant) |
| `BaseDe` | Bases | `joueur` → index ou nil |
| `ModeleBase` | Bases | `index` → Model |
| `JoueurDeBase` | Bases | `index` → Player ou nil |
| `DansBase` | Bases | `position (Vector3), index` → bool (dans la Zone) |
| `BaseVerrouillee` | Bases | `index` → bool |
| `NombreEmplacements` | Bases | `joueur` → n |
| `CFrameEmplacement` | Bases | `index, numero` → CFrame du pivot d'un dino posé sur ce podium |
| `ReserverEmplacement` | Enclos | `joueur` → numero ou nil |
| `LibererEmplacement` | Enclos | `joueur, numero` |
| `PlacerDino` | Enclos | `dino, joueur, numero` → bool (pose, attributs, invites Voler/Vendre) |
| `DinosDe` | Enclos | `joueur` → liste des dinos du joueur (Enclos + EnRoute) |
| `LancerEvenement` | Evenements | `nom` → bool |
| `AutoriserAction` | Securite | `joueur, action, intervalle` → bool |

## 8. Réseau (`ctx.Reseau`, ReplicatedStorage.DinoReseau)

| RemoteEvent | Sens | Arguments | Traité par |
|---|---|---|---|
| `Acheter` | client → serveur | `nom` d'objet de `Equilibrage.boutique` | Systemes/Boutique |
| `Renaissance` | client → serveur | — | Systemes/Renaissance |
| `Frapper` | client → serveur | — | Systemes/Batte |
| `Collecter` | client → serveur | — (collecte tout si le joueur est dans sa Base) | Systemes/Enclos |
| `Effet` | serveur → clients | `genre, position, donnees` | Interface/Effets, Interface/Sons |
| `Notification` | serveur → client(s) | `texte, genre` (`"info"`, `"succes"`, `"alerte"`, `"vol"`) | Interface/HUD, Interface/Sons |

Genres d'Effet : `"Apparition"` (dino rare sur le Tapis, donnees {rarete, mutation, espece}),
`"Achat"` {rarete}, `"Collecte"` {montant}, `"Vente"` {montant}, `"VolDebut"` {voleur, victime},
`"VolReussi"`, `"VolRate"`, `"Frappe"`, `"Verrou"` {index, actif}, `"Renaissance"` {niveau},
`"Evenement"` {nom}, `"Meteore"`, `"Decouverte"` {espece}, `"Coffre"` {montant}.
Le serveur vérifie tout (types, distances, fréquences, argent) : jamais
confiance au client.

## 9. Bus client

| Événement | Émis par | Arguments |
|---|---|---|
| `OuvrirPanneau` | Client.client.lua (invites « Boutique », « Renaissance », « Index »), HUD | `"Boutique"`, `"Renaissance"` ou `"Index"` |
| `FermerPanneaux` | n'importe qui | — |
| `Frapper` | Interface/Mobile | — (Interface/Batte frappe) |
| `Son` | n'importe qui | `"clic"`, `"achat"`, `"refus"`, `"argent"`, `"vol"`, `"alerte"`, `"frappe"`, `"verrou"`, `"rare"`, `"renaissance"`, `"decouverte"` |
| `TutorielEtape` | Interface/Tutoriel | `numero` |

## 10. Emprises (qui construit où)

Sol à Y = 0. Ne rien construire hors de son emprise.
- **Sol** : sol de tout `Plan.monde` (dessus à Y = 0), allées de terre (de la
  Place vers le Tapis par les couloirs x = -56, 0, 56 entre les Bases), murs
  invisibles à `Plan.monde.bord`. Hauteur ≤ 0,3 hors murs.
- **Tapis** : le tapis de `Plan.tapis.debut` à `fin` (largeur 10, dessus à Y =
  `Plan.tapis.hauteur`) et ses rebords (|z| ≤ 9,5).
- **Nurserie** / **FinTapis** : disques de rayon 14 autour de leurs centres.
- **Bases** : les 8 bases (voir §5), rien entre elles.
- **Place** : disque r20 autour de `Plan.place.centre` : l'**unique**
  SpawnLocation (8 x 8, dessus à Y = 1) au centre, une fontaine, et la borne
  **Dinodex** avec l'invite « Index » au bord sud.
- **Comptoir** : la boutique (26 x 18 autour de `Plan.comptoir.centre`), invite
  « Boutique », ouverte vers la Place (+X).
- **Autel** : disque r11 autour de `Plan.autel.centre`, invite « Renaissance »,
  tournée vers la Place (-X).
- **Cratere** : disque r16 autour de `Plan.cratere.centre`.
- **Volcan** : disque r34 autour de `Plan.volcan.centre`, hauteur ≤ 70.
- **Falaises** : bandes |x| 168..190, z -190..-168 et z 150..165 ; plus un
  sentier d'escalade jusqu'à une plateforme dont le dessus est à `Plan.coffre`.
- **Jungle** : `Plan.decor.jungleOuest/Est/Nord` limitées à |x| ≤ 166, sans
  empiéter sur le Volcan (rayon + 6) ni les Falaises.
- **Riviere** : bande z 131..145 sur x -166..166 (+ une cascade qui sort des
  falaises de l'est).
- **Fossiles** : petits props (≤ 4 de haut) dans les couloirs entre les Bases
  (|x - c| ≤ 5 pour c = -56, 0, 56 et 20 ≤ |z| ≤ 66), dans l'anneau 21..28 de la
  Place et de part et d'autre de la Nurserie et de la Fin du tapis (|z| 16..30).
- **Lumieres** : torches le long du Tapis (z = ±8, tous les 16 studs) et autour
  de la Place (r = 23, tous les 45°).
- **Signaletique** : panneaux sur la Place (vers Comptoir, Autel, Tapis,
  Dinodex) et à chaque bout du Tapis.
- **Ciel** : Lighting uniquement.
- **DinosHerbivores**, **DinosCarnivores** : ServerStorage uniquement.

## 11. Charte, sons, budget

Style jouet : blocs lisses (SmoothPlastic ; Neon pour ce qui brille), couleurs
**uniquement** via `ctx.Charte`. Sons intégrés `rbxasset://sounds/...` seulement
(ex. `electronicpingshort.wav`, `button.wav`, `swordslash.wav`, `uuhhh.mp3`,
`action_jump.mp3`, `impact_water.mp3`) ; la musique a des SoundId vides à
compléter. Budget total ~14000 parts ; chacun respecte le sien (voir sa mission).
