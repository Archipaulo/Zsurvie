# Contrat technique — map Roblox « Zsurvie »

Ce document est la loi commune des 50 agents. Chacun écrit **un seul fichier**
et ne communique avec les autres **que** par ce qui est décrit ici.

## 1. Arborescence (format Rojo)

```
src/ReplicatedStorage/Zsurvie/      -> ReplicatedStorage.Zsurvie (partagé)
  Charte.lua  Plan.lua  Outils.lua  Equilibrage.lua  Reseau.lua  Bus.lua
src/ServerScriptService/Zsurvie/    -> ServerScriptService.Zsurvie
  Demarrage.server.lua              (ne pas modifier)
  Builders/<Nom>.lua                (constructeurs de décor, ModuleScript)
  Systemes/<Nom>.lua                (systèmes serveur, ModuleScript)
src/StarterPlayerScripts/Zsurvie/   -> StarterPlayer.StarterPlayerScripts.Zsurvie
  Client.client.lua                 (ne pas modifier)
  Interface/<Nom>.lua               (modules client, ModuleScript)
```

**Lire les fichiers partagés avant d'écrire** : `Charte.lua` (couleurs), `Plan.lua`
(coordonnées), `Outils.lua` (fonctions de construction), `Equilibrage.lua` (tous
les chiffres). Ne jamais recopier un chiffre d'équilibrage en dur.

## 2. Forme d'un module

```lua
-- Builders/<Nom>.lua
local M = {}
function M.construire(ctx)
	-- tout ce qui est construit va dans ctx.dossier (Folder Workspace.Zsurvie.<Nom>)
end
return M

-- Systemes/<Nom>.lua  et  Interface/<Nom>.lua
local M = {}
function M.demarrer(ctx)
	-- abonnements, boucles (task.spawn), etc.
end
return M
```

`ctx` côté serveur : `Charte, Outils, Plan, Equilibrage, Bus, Reseau` (table des
RemoteEvents), `Etat` (Folder à attributs), `racine` (Workspace.Zsurvie), `horde`
(Workspace.Zsurvie.Horde), `stockage` (ServerStorage.Zsurvie), et pour un
constructeur `dossier`.

`ctx` côté client : `Charte, Outils, Plan, Equilibrage, Bus` (bus local au client),
`Reseau` (RemoteEvents), `Etat`, `joueur` (LocalPlayer), `gui` (ScreenGui
« ZsurvieGui », ResetOnSpawn = false), `racine`, `horde`.

Ne **pas** faire `require` d'un autre module de Builders/Systemes/Interface : passer
par `ctx`. Les constructeurs sont exécutés l'un après l'autre (ordre :
Zbires, Ciel, IleLabo, Prairie, Relief, Vegetation, Eau, Maison, Mine, Props,
PointsInteret, Portails, Lumieres, Signaletique, Fanions, Laboratoire,
QuaiCapsules, Galerie, Parcours, Enigme, Records, Monument, ScenePhoto) ; ils
peuvent lancer des boucles avec `task.spawn` / `task.wait` (jamais de boucle
bloquante dans `construire`). Les systèmes démarrent ensuite, chacun dans sa
propre coroutine. Un système qui gère les joueurs doit traiter
`Players:GetPlayers()` **et** `Players.PlayerAdded`.

## 3. Sous-ensemble de Luau autorisé (obligatoire)

Le code est vérifié automatiquement par un analyseur Lua 5.1 et exécuté dans un
simulateur. Donc **interdits** : `+=` `-=` `*=` `..=` (écrire `x = x + 1`),
`continue` et `goto` (structurer avec `if`),
annotations de type (`: number`, `-> ()`), chaînes à accents graves `` `...` ``,
`if ... then ... else` en expression, `//`. Utiliser `task.wait`, `task.spawn`,
`task.delay` (jamais `wait`, `spawn`, `delay`). Ne pas utiliser `loadstring`,
`getfenv`, `setfenv`. Tabulations pour l'indentation, commentaires en français,
sobres.

## 4. État partagé

`ReplicatedStorage.ZsurvieEtat` (attributs, écrits par le serveur uniquement) :

| Attribut | Écrit par | Sens |
|---|---|---|
| `Phase` | Systemes/Jour | `"Lobby"`, `"Horde"`, `"Repit"`, `"Defaite"` |
| `Jour` | Systemes/Jour | jour de la run en cours (0 au lobby) |
| `TempsRestant` | Systemes/Jour | secondes restantes de la phase (entier) |
| `PVMaison`, `PVMaisonMax` | Systemes/Jour | points de vie de la Maison |
| `ZbiresRestants` | Systemes/Horde | Zbires vivants + à venir ce jour |
| `ColosseActif` | Systemes/Horde | un Colosse est en jeu |
| `Record` | Systemes/Classement | meilleur jour atteint sur le serveur |

Attributs des joueurs (`Player`) :

| Attribut | Écrit par | Sens |
|---|---|---|
| `Pieces` | Systemes/Economie | pièces de la run |
| `Gemmes` | Systemes/Donnees | gemmes, permanentes et sauvegardées |
| `Niv_<Amelioration>` | Systemes/Etabli | niveau d'amélioration de la run (0..max) |
| `Rech_<Recherche>` | Systemes/Laboratoire (chargé par Donnees) | `true` si débloquée |
| `RecordJour` | Systemes/Classement (sauvegardé par Donnees) | meilleur jour du joueur |
| `ParcoursFait`, `EnigmeFaite` | Builders/Parcours, Builders/Enigme (sauvegardés par Donnees) | récompense déjà touchée |
| `EnRun` | Builders/QuaiCapsules (mis à true), Systemes/Jour (remis à false) | le joueur est sur la Prairie |
| `DonneesChargees` | Systemes/Donnees | la sauvegarde est chargée |

## 5. Bus serveur (`ctx.Bus`)

Notifications (`Bus.emettre(nom, ...)` / `Bus.ecouter(nom, fn)`) :

| Événement | Émis par | Arguments |
|---|---|---|
| `RunDebut` | Builders/QuaiCapsules | `joueurs` (liste de Player téléportés sur le parvis) |
| `JourDebut` | Systemes/Jour | `jour` |
| `RepitDebut` | Systemes/Jour | `jour` (celui qui vient d'être survécu) |
| `MaisonTombee` | Systemes/Jour | `jour` |
| `RetourLobby` | Systemes/Jour | — (joueurs renvoyés au lobby, Phase = "Lobby") |
| `HordeTerminee` | Systemes/Horde | `jour` (tous les Zbires du jour sont apparus et vaincus) |
| `NettoyerHorde` | Systemes/Jour | — (Horde détruit tous les Zbires restants) |
| `ZbireApparu` | Systemes/Horde | `modele, type` |
| `ColosseApparu` | Systemes/Horde | `modele` |
| `DegatsZbire` | Systemes/Blaster, Systemes/TourelleToit | `modele, degats, joueur (ou nil), critique (bool)` |
| `ZbireVaincu` | Systemes/Horde | `modele, type, position (Vector3), tueur (Player ou nil)` |
| `DegatsMaison` | Systemes/Horde | `montant` |
| `SoinMaison` | Systemes/Economie (réparation) | `montant` |
| `PiecesGagnees` | Systemes/Economie | `joueur, n` |
| `GemmesGagnees` | Systemes/Donnees | `joueur, n, source` |
| `AmeliorationAchetee` | Systemes/Etabli | `joueur, nom, niveau` |
| `RechercheDebloquee` | Systemes/Laboratoire | `joueur, nom` |

Questions (`Bus.demander(nom, ...)`, un seul répondeur déclaré par `Bus.repondre`) :

| Question | Répondeur | Arguments → retour |
|---|---|---|
| `AjouterPieces` | Systemes/Economie | `joueur, n` → nouveau total |
| `DepenserPieces` | Systemes/Economie | `joueur, n` → `true` si payé |
| `AjouterGemmes` | Systemes/Donnees | `joueur, n, source` → nouveau total |
| `DepenserGemmes` | Systemes/Donnees | `joueur, n` → `true` si payé |
| `AutoriserAction` | Systemes/Securite | `joueur, action (texte), intervalle (s)` → `true`/`false` (limiteur de fréquence) |

`Bus.demander` renvoie `nil` si personne ne répond : toujours prévoir ce cas
(ex. `if Bus.demander("AutoriserAction", j, "Tirer", 0.1) == false then return end`).

## 6. Réseau (`ctx.Reseau`, RemoteEvents de ReplicatedStorage.ZsurvieReseau)

| RemoteEvent | Sens | Arguments | Traité par |
|---|---|---|---|
| `Tirer` | client → serveur | `position (Vector3 visée), idZbire (texte ou nil)` | Systemes/Blaster |
| `Acheter` | client → serveur | `nom` d'amélioration | Systemes/Etabli |
| `Rechercher` | client → serveur | `nom` de recherche | Systemes/Laboratoire |
| `Reparer` | client → serveur | — | Systemes/Economie |
| `Ping` | client → serveur | `texte` parmi `"Aide !"`, `"Ici !"`, `"Colosse !"`, `"Merci !"` | Systemes/Securite (rediffuse en Notification) |
| `Effet` | serveur → clients | `genre, position, donnees (table ou nil)` | Interface/Effets, Interface/Sons |
| `Notification` | serveur → client(s) | `texte, genre` (`"info"`, `"succes"`, `"alerte"`) | Interface/HUD, Interface/Sons |

Genres d'`Effet` : `"Tir"` (position = cible, donnees.origine = Vector3, donnees.critique),
`"Impact"`, `"Vaincu"` (donnees.type), `"Piece"` (donnees.n), `"Gemme"` (donnees.n),
`"Reparation"`, `"Explosion"` (donnees.rayon), `"Colosse"`, `"DegatsMaison"`,
`"Amelioration"` (donnees.nom), `"Recherche"` (donnees.nom), `"JourDebut"` (donnees.jour).
Ne jamais faire confiance au client : vérifier types (`typeof(x) == "Vector3"`),
distances, cadence, coûts, côté serveur.

## 7. Bus client (`ctx.Bus` côté client, local au joueur)

| Événement | Émis par | Arguments |
|---|---|---|
| `OuvrirPanneau` | Client.client.lua (invites) , Interface/HUD, Interface/Mobile | `"Etabli"` ou `"Recherches"` |
| `FermerPanneaux` | n'importe qui | — |
| `TirLocal` | Interface/Blaster | `origine, cible` (Vector3) — retour visuel immédiat |
| `TirAuto` | Interface/Mobile | — (demande à Interface/Blaster de tirer sur le Zbire le plus proche) |
| `Son` | n'importe qui | `nom` parmi `"clic"`, `"tir"`, `"impact"`, `"piece"`, `"gemme"`, `"achat"`, `"refus"`, `"alerte"`, `"victoire"`, `"defaite"`, `"saut"` |
| `TutorielEtape` | Interface/Tutoriel | `numero` |

## 8. Les Zbires

Modèles gabarits dans `ServerStorage.Zsurvie.Zbires.<Type>` (Builders/Zbires),
un par type d'`Equilibrage.zbires` (Marcheur, Rapide, Costaud, Dore, Sauteur,
Gluant, MiniGluant, Volant, Casque, Colosse), déjà à l'échelle `taille`,
ancrés, `CanCollide = false`, `PrimaryPart` = part « Corps ». Le pivot du modèle
(`WorldPivot`) est à la base, au sol : `modele:PivotTo(CFrame.new(x, 0, z))` pose
le Zbire sur le sol en (x, z), regard vers -Z local. Chaque gabarit contient un
`BillboardGui` « Barre » (sur Corps) avec un `Frame` « Fond » contenant un
`Frame` « Remplissage » (largeur = PV/PVMax, via Size.X.Scale).

En jeu (Systemes/Horde), les clones vivent dans `Workspace.Zsurvie.Horde` avec
les attributs `Type`, `Id` (texte unique), `PV`, `PVMax`. Horde les déplace en
`PivotTo` (sans physique) vers la Maison, avec un léger dandinement.

## 9. Emprises (qui construit où)

Sol à Y = 0. La Prairie est centrée sur (0,0,0). L'île du Laboratoire est
centrée sur `Plan.lobby.origine` = (0,0,600). Coordonnées ci-dessous relatives
à ces centres. Ne rien construire hors de son emprise, sauf mention.

**Prairie (Plan.prairie)**
- Prairie : sol (disque ou carré de 240 × 240, dessus à Y = 0, épaisseur 2),
  4 chemins de terre en croix (largeur 6, de 9 à 100), parvis (Plan.parvis).
- Maison : carré de 16 × 16 au centre, hauteur 14, toit orange.
- Mine : disque r7 autour de Plan.mine. Props : Établi (disque r6 autour de
  Plan.etabli) + petits props dans l'anneau 20..60 hors chemins, hors autres
  emprises, hauteur ≤ Plan.hauteurMaxPres.
- Eau : étang (Plan.etang, r8). PointsInteret : 4 disques r8 (Plan.pointsInteret).
- Vegetation : anneau 70..86 (hors couloirs de chemins ±5). Relief : anneau
  88..112 (hors couloirs ±8). Portails : 4 portails (Plan.portails), sur les chemins.
- Lumieres : réverbères le long des 4 chemins à 20, 40, 60 du centre, décalés de
  5 studs du chemin ; et sur l'île (voir plus bas).
- Signaletique : panneaux sur le parvis (bords) et aux abords (≤ 3 panneaux) +
  île (voir plus bas).
- Fanions : guirlandes autour du parvis et sur la Maison (sans dépasser 16 de haut).

**Île du Laboratoire (Plan.lobby, rayon 70)**
- IleLabo : sol de l'île (disque r70 à Y = 0, bords rocheux jusqu'à r78,
  dessous flottant), allées entre les zones, eau/ciel autour à distance.
- Laboratoire : disque r22 autour de lobby.laboratoire (Arbre des Recherches au
  centre avec l'invite « ArbreRecherches », 12 Alcôves à r16, Doc Boulon).
- QuaiCapsules : rectangle 36 × 12 autour de lobby.quai + la `SpawnLocation`
  unique en lobby.spawn (8 × 8).
- Galerie : 16 × 24 autour de lobby.galerie. Parcours : 20 × 30 autour de
  lobby.parcours (jusqu'à 30 de haut). Enigme : 14 × 14 autour de lobby.enigme.
- Records : 10 × 4 autour de lobby.records. Monument : 30 × 6 autour de
  lobby.monument. ScenePhoto : 12 × 12 autour de lobby.scenePhoto.
- Lumieres : lampadaires à r58 autour de l'origine de l'île, tous les 30°, en
  sautant ceux à moins de 14 studs d'une zone ci-dessus.
- Signaletique : panneaux indicateurs autour de lobby.spawn (anneau 6..10).
- Fanions : mâts et guirlandes à r66 de l'origine de l'île (en sautant ±14
  autour de lobby.monument).
- Ciel : service Lighting uniquement (+ Atmosphere, Sky, nuages) et effets.

## 10. Charte

Style « jouet » : blocs lisses (SmoothPlastic, Neon pour ce qui brille),
contours lisibles, couleurs **uniquement** depuis `ctx.Charte` (et
`Charte.ombre/lumiere`). Violet = ennemi, orange/crème = à nous, or = pièces,
cyan = gemmes, rose-rouge = danger. Polices `Charte.police` / `Charte.policeTexte`.
Budget : ~9000 parts au total ; chaque constructeur annonce son budget
dans sa mission et le respecte.

## 11. Sons

Uniquement des sons intégrés à Roblox (`rbxasset://sounds/...`) :
`swordslash.wav`, `electronicpingshort.wav`, `button.wav`, `uuhhh.mp3`,
`action_jump.mp3`, `action_get_up.mp3`, `impact_water.mp3`, `bass.wav`,
`clickfast.wav`, `snap.wav`, `hit.wav`, `victory.wav` ...
En cas de doute, créer le `Sound` quand même : un son absent n'arrête pas le jeu.
