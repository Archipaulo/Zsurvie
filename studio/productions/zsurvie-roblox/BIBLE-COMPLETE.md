# 📖 Zsurvie : synthèse de la bible de production — Bible de production

*Atelier Roblox · 50 agents · workflow Claude Code*

> De 1 à 6 Survivants courent, tirent et réparent ensemble pour sauver la Maison des hordes de Zbires rigolos, jour après jour. Quand elle tombe, leurs gemmes deviennent des inventions permanentes au Laboratoire, et ils repartent plus forts. Une horde lisible en une seconde sur téléphone, une coop sans chat où l'on ne meurt jamais, et un Laboratoire dont chaque Alcôve montre à tout le serveur les machines qu'on a inventées.

## Le brief
Adapter mon jeu Zsurvie en expérience Roblox multijoueur coopérative.

Le jeu d'origine : un jeu de défense incrémental en vue surélevée, style pixel art coloré. Une petite maison au centre de la map est attaquée jour après jour par des hordes de petits monstres rigolos et très bien animés qui arrivent de tous les côtés. Un colosse attaque tous les 5 jours. Bestiaire : marcheur, rapide, costaud à piquants, doré (lâche des gemmes), sauteur bondissant, gluant qui se divise en deux à sa mort, volant, casqué blindé (ne subit que la moitié des dégâts sauf coups critiques). Une mine près de la maison produit des gemmes en continu. Pendant la partie, on achète des améliorations avec les pièces lâchées par les monstres (dégâts, cadence, portée, solidité de la maison, réparation, régénération, butin, balles explosives). Quand la maison tombe, on retourne au Laboratoire, un lobby où l'on dépense les gemmes en recherches permanentes (tourelle de toit, balles perforantes, visée critique, foreuse de la mine…), puis on recommence plus fort. Sons rétro 8-bit.

Sur Roblox : 1 à 6 joueurs défendent ensemble la même maison. Chaque joueur incarne un survivant qui se déplace librement, tire, répare et peut poser quelques défenses. Le Laboratoire devient un vrai lobby 3D où l'on se retrouve entre les parties. Garder l'esprit pixel art / blocky très coloré, fun et lisible. Public 9-15 ans, mobile d'abord. Je veux une map incroyable, mémorable, qui donne envie de revenir tous les jours.

## ⭐ Synthèse du directeur créatif
# Zsurvie : synthèse de la bible de production

*Victor Lanoue, directeur créatif. À lire en premier. Le canon fait foi. En cas de doute, le module source tranche (Plan, Catalogue, ZbiresDefs.Jours, Charte), pas la mémoire de quelqu'un.*

## 1. Le jeu en une page

**Zsurvie.** De 1 à 6 Survivants courent, tirent et réparent ensemble pour sauver la Maison des hordes de Zbires rigolos, jour après jour. Quand elle tombe, leurs gemmes deviennent des inventions permanentes au Laboratoire, et ils repartent plus forts.

**Les 3 piliers**
1. **Une horde lisible en une seconde.** Une silhouette, une règle : le Casqué impose les critiques, le Gluant se divise, le Volant passe au-dessus des Murets. Tout Zbire vaincu éclate en cubes et en pièces.
2. **Jouer ensemble sans chat.** On ne meurt jamais, un coup étourdit 2 s. La Roue des Pings remplace le chat.
3. **Un Laboratoire qui grandit.** Chaque recherche devient une machine animée dans l'Alcôve du joueur, visible par tous.

**Public et format.** 9-13 ans, jusqu'à 15, maturité Légère. Téléphone d'abord : 30 FPS sur Android 3 Go avec 6 joueurs et 60 Zbires. Sessions de 20 à 35 min : 1 ou 2 runs de 12 à 18 min sur la Prairie (serveur réservé de 6), puis 3 à 5 min au Laboratoire (12 joueurs).

**Jamais** : ni horreur, ni pay-to-win, ni tower defense immobile, ni PvP, ni survie à collecte, ni run de plus de 25 min.

## 2. La première session en 10 moments

1. **Bonjour, Doc Boulon.** Le novice apparaît près de la Capsule Normale. L'hologramme de Doc Boulon le salue en blips 8-bit, et des dalles cyan le guident.
2. **La Capsule.** « 3/6 · départ 12 s », puis un tunnel cyan emporte l'équipe.
3. **L'Arrivée (20 s).** La Capsule se pose sur le Parvis en rebondissant. Un anneau de portée et un joystick fantôme apprennent à bouger avant le premier ennemi.
4. **Le premier Zbire.** Un Marcheur réservé au novice sort à l'Est. Le Blaster vise seul, et le Marcheur éclate en cubes violets et en pièces or avant T 60.
5. **Le premier achat.** À 25 Pièces, la main or désigne Dégâts à l'Établi. Un tap, une fanfare.
6. **Le premier Répit.** 15 s pour souffler. On court plus vite, le « +X » gris rend la moitié des pièces oubliées, le bouton Muret pulse.
7. **La Maison touchée.** Réparer pulse, on le maintient, le marteau frappe. À trois, la Maison remonte deux fois plus vite.
8. **Le Colosse (7:20).** Au Répit qui précède le Jour 5, la lumière glisse vers le couchant et la piste Colosse démarre. Une flèche Alerte montre le Nord, le bouton Ping pulse sur « Colosse ! ». Colère 60 s après son entrée.
9. **La chute.** Le toit se soulève sur la maison d'enfance de Doc Boulon, sur un jingle comique. « La Maison a tenu X jours ! » : au moins 40 gemmes, environ 112 au Jour 6.
10. **La première invention.** Des dalles cyan mènent à l'Arbre des Recherches, la main or désigne la Tourelle de toit (40 gemmes). Un maintien de 0,5 s, et la machine s'installe dans l'Alcôve. On repart.

## 3. Ce qui rend cette map incroyable

**La promesse** : une maison qu'on aime, assiégée par des monstres qu'on adore faire éclater, et un repaire de savante qui garde la trace de chaque partie. Aucune expérience Roblox ne réunit ce trio : un pixel art en cubes lisible sur 5,5 pouces, une coop sans chat où chaque enfant compte, un lobby qui montre à tous ce que chacun a construit.

- **Game Design** : tempo de 95 s (80 s de horde, 15 s de Répit), Colosse tous les 5 jours, fin garantie, revenu par Survivant identique de 1 à 6 joueurs.
- **Level Design** : arène concentrique lisible d'un regard, rien au-dessus de 6 studs à moins de 60 studs, aucun obstacle sur les axes de horde.
- **Terrain & Environnement** : Lisière en amphithéâtre, basse côté caméra, qui cadre sans jamais masquer.
- **Construction** : Maison aux 3 états avec « Record : Jour X » sur le toit, Mine qui luit cyan, anneau de 12 Alcôves.
- **Scripting** : autorité serveur, Zbires simulés à 10 Hz et dessinés par le client, aucune gemme perdue.
- **UI/UX** : on lit en haut, on agit au pouce droit, 60 px minimum.
- **Lumière, VFX, Audio** : violet = ennemi, or = pièces, cyan = gemmes, rose-rouge = danger. Le Casqué fait « clank » ou « ding » : sa règle s'apprend à l'oreille.
- **Live Ops** : Défi du Jour, Foreuse et Zbire de la Semaine (samedi 17 h, Paris) font revenir chaque jour, sans pression d'achat.

## 4. Les décisions structurantes

**Direction créative : mes arbitrages, applicables dès aujourd'hui.**
- *Validés* : Arrivée de 20 s ; victoire au Colosse du J15 ; `LIMITE_RUN` à 25:00 ; Tension ; Jour parfait ; colère du Colosse (× 3 sur la Maison) ; Prairie sans saut (sous réserve de l'A/B de H2) ; tir automatique partout, rayon = Portée (40 → 52 studs) ; caméra (0, 52, 32) pendant le Colosse ; coop comptée sur les actifs ; 50 % des Pièces oubliées rendus au Répit ; Marcheurs `ReservePour` ; caméra Custom et StreamingEnabled au Laboratoire ; Mine à 12 studs bord à bord ; noms d'instances ASCII ; Niveau, XP, Galons, Calendrier de Doc Boulon, Foreuse Turbo (jamais en Robux) ; Tuyauterie, Ressorts, Cabine d'Essayage ; Pompon, Mur des Curiosités, Vestiaire ; Doré bordé de violet ; pad doux en chiptune.
- *Refusés ou reportés* : le Rapide qui contourne les Murets (sa règle, c'est la vitesse) ; toute gemme hors des 5 sources du canon ; Aimant à Pièces, missions hebdomadaires, nuit express et puits cosmétique en gemmes (vague 2).

**Game Design.** `ZbiresDefs.Jours` (a06) est la seule table réglée en playtest : PV × 1,15^(jour − 1), 18 + 7 × jour Zbires par paquets de 3 à 5, 1 portail aux J1-3 (jamais le Sud), 2 aux J4-8, puis 3 ou 4. Coop : PV × (1 + 0,35 × (actifs − 1)), effectifs × (1 + 0,2 × (actifs − 1)). Colosse aux J5, J10, J15 : 2 500 × 1,15^(jour − 1) PV. `ReplicatedStorage.Catalogue` (a07) : Établi à base × 1,45^(niv − 1), 10 niveaux, niveau 1 de Dégâts à 25 Pièces (la base de 10 est retirée) ; jour franchi à 5 + 2 × min(jour, 15) gemmes, doublé aux Jours du Colosse ; Mine 1 gemme / 20 s ; Doré 4 gemmes dès J3 ; Maison 1 000 PV. Capsule Difficile au Record Jour 10, Capsule du Jour au premier Colosse repoussé.

**Level Design.** `ReplicatedStorage.Plan` v1 (a11) : Maison à l'origine, porte au Sud (+Z), Établi (−12, 14), Mine X 20 → 32 / Z 20 → 32, 8 portails `PortailZbire` à R 80, barrière R 72, pose jusqu'à R 66 via `Plan.posePermise` (client et serveur). Laboratoire : Arbre des Recherches au centre, 12 Alcôves à R 43.

**Terrain & Environnement.** `Terrain:CountCells()` = 0 partout. a17 seul constructeur de la forêt (2 200 Parts). Météo purement cosmétique.

**Construction.** Maison : 3 états dans la place, seuils 66 % et 33 % avec hystérésis. Défenses traversables (CollisionGroup `Defenses`), 3 par Survivant, reprises à 50 %.

**Scripting.** Un seul `EtatRun`, écrit par BoucleDuJour. Un seul `Reseau`, sans RemoteFunction. `EtatZbires` (9 octets) et `Evenements` (8 octets) à 10 Hz. `ZbiresRendu` : pool de 70, un `BulkMoveTo` par image. `GardienMouvement` seul écrivain de `WalkSpeed` et `JumpHeight`. Store unique `Zsurvie_Joueurs_v1`, `CrediterRun` idempotent, `Temps.cleJour()` à minuit heure de Paris.

**UI/UX.** Maquette unique 800 × 360 (a28) : bandeau Maison en haut au centre ; Grappe en bas à droite (Réparer 96 px, défenses et Ping 64 px en arc) ; Établi par bouton contextuel de 72 px.

**Lumière, VFX, Audio.** AmbianceClient seul écrivain de `Lighting` : `ClockTime` 14, puis 17,5 au Jour du Colosse. Plafonds : 150 Neon, 12 lumières, 24 émetteurs, 16 voix en pool.

**Live Ops & Publication.** Robux = cosmétiques et serveur privé (50 R$ par mois), au Laboratoire seulement, 199 R$ au plus. Télémétrie par `Telemetrie` seul, entonnoir de 12 étapes, cibles J1 22 %, J7 8 %.

## 5. Les 5 risques principaux et leur parade

| Risque | Parade |
|---|---|
| **Le téléphone décroche au Jour du Colosse** | Gabarit à 6 500 Parts statiques (pic ≈ 7 900), Auditeur bloquant, rendu en pool, mode léger `Qualite`, test Android 3 Go à chaque jalon. |
| **Le novice rate sa première invention** | Prix lus dans le Catalogue, ouverture scriptée, Tourelle de toit visible dès le niveau 1, plancher de 40 gemmes, alerte à 10 points de perte. |
| **Une gemme se perd entre deux places** | Store unique, `CrediterRun` idempotent, téléport après un `Liberer` réussi, « Rejoindre la run », 20 allers-retours sans écart. |
| **Les contrats divergent de nouveau** | Une source par sujet, `assert` au démarrage, clé absente = erreur. Tout écart passe par moi. |
| **La run déborde ou la coop écrase la difficulté** | Une seule table réglée, `LIMITE_RUN`, coop sur les effectifs, playtest H7, alerte si la médiane des runs de rang 4 et plus passe sous le J8. |

## 6. Les prochaines étapes immédiates

1. **Aujourd'hui** : ces arbitrages entrent au canon ; chaque agent retire les valeurs abandonnées.
2. **29/09** : a30 livre la Charte ; a27 Reseau, EtatRun, Donnees v2 et Temps ; a29 ReglesRemotes.
3. **01/10** : a11 publie Plan v1 et le Gabarit ; a06 livre `ZbiresDefs.Jours`, a07 le Catalogue.
4. **Tranche verticale en greybox** : Laboratoire, Capsule, J1 à J6 avec le Colosse, chute, première recherche. Playtests H1, H2, H6 et H7 avec des 9-13 ans.
5. **Tests techniques** : Jour du Colosse sur Android 3 Go avec 6 comptes, 20 allers-retours, 2 clients à 0,3 s de latence.
6. **Production** : la productrice confirme ou déplace le lancement du 16 octobre 2026 ; le paquet Halloween se valide avant le 9 octobre.

Chaque ligne de cette bible sert une seule image : six enfants autour d'une petite maison, qui rient en faisant éclater une horde violette, et qui reviendront demain voir leur machine tourner.

## 🧭 Le canon
# Zsurvie : le canon

*Victor Lanoue, directeur créatif. Ce document fait foi. Tout écart passe par moi.*

## 1. Titre et pitch

**Titre officiel : Zsurvie.**

**Pitch :** de 1 à 6 Survivants courent, tirent et réparent ensemble pour sauver la Maison des hordes de Zbires rigolos, jour après jour. Quand elle tombe, leurs gemmes deviennent des inventions permanentes au Laboratoire, et ils repartent plus forts.

## 2. Les 3 piliers

1. **Une horde lisible en une seconde.** Chaque Zbire a sa silhouette et sa règle : le Casqué impose les critiques, le Gluant se divise, le Volant passe au-dessus des Murets. Un Zbire vaincu éclate en cubes et en pièces.
2. **Jouer ensemble sans chat.** Le Survivant bouge, tire, répare et pose des défenses. On ne meurt jamais : un coup nous étourdit 2 s. La Roue des Pings remplace le chat, dont beaucoup de 9-12 ans sont privés.
3. **Un Laboratoire qui grandit.** Chaque recherche devient une machine animée dans l'Alcôve du joueur, visible par tous. Le Défi du Jour, la Foreuse et le Zbire de la Semaine font revenir chaque jour.

## 3. Public et plateforme

- **Âge :** cœur de cible 9-13 ans, jusqu'à 15 ans. Label de maturité **Léger (Mild)**.
- **Plateforme prioritaire : le téléphone**, Android d'entrée de gamme compris. Viennent ensuite le PC et la tablette. Pas de console au lancement.
- **Session :** 20 à 35 min, soit 1 ou 2 runs de 12 à 18 min et 3 à 5 min au Laboratoire.

## 4. La boucle en 5 lignes

1. Au Laboratoire, on monte dans une Capsule (1 à 6 places). Elle part 15 s plus tard.
2. Sur la Prairie, chaque jour enchaîne 80 s de horde et 15 s de Répit. On tire, on ramasse ses pièces, on répare et on pose ses défenses.
3. À l'Établi, les pièces achètent des améliorations valables jusqu'à la fin de la run.
4. Le Colosse attaque tous les 5 jours. Le premier arrive vers la 8e minute.
5. Quand la Maison tombe, chacun gagne des gemmes selon le jour atteint. On lance ses recherches et on repart.

## 5. Les zones

| Zone | Place | Fonction | Ambiance |
|---|---|---|---|
| **Le Laboratoire** | Lobby | Doc Boulon, Arbre des Recherches, 12 Alcôves en anneau | Repaire de savant, néons cyan |
| **Le Quai des Capsules** | Lobby | 3 Capsules : Normale, Difficile et du Jour | Gare futuriste |
| **La Galerie des Zbires** | Lobby | Figurines animées. Des variantes cosmétiques se débloquent à 10, 100 et 1 000 éliminations | Musée rigolo |
| **La Maison** | Run | 16 × 16 × 14 studs, 3 états visuels, « Record : Jour X » affiché au-dessus | Cocon chaleureux |
| **La Mine** | Run | À 12 studs de la Maison. Produit des gemmes en continu | Trésor, lueur cyan |
| **La Prairie** | Run | Arène de 70 studs de rayon, traversée par 4 chemins en croix | Pique-nique qui tourne au chaos |
| **La Lisière** | Run | Anneau d'apparition entre 70 et 100 studs, avec des portails violets | Forêt de cubes, mystérieuse sans faire peur |

Le Jour du Colosse n'est pas une zone. C'est un état de la Prairie (`ClockTime` 17,5).

## 6. Les noms officiels

| Catégorie | Nom | Règle |
|---|---|---|
| Monnaie de run | **Pièces** | Chaque joueur a son propre butin. Les pièces sont perdues en fin de run |
| Monnaie permanente | **Gemmes** | Viennent de la Mine, du Doré, des jours franchis, de la Foreuse et du Défi du Jour |
| Joueurs | **Survivants** | Équipés d'un **Blaster** et d'un **Sac à dos** |
| PNJ | **Doc Boulon** | Savante du Laboratoire, guide du tutoriel |
| Monstres | **Zbires** | Marcheur, Rapide, Costaud, Doré, Sauteur, Gluant (se divise en 2 **Mini-Gluants**), Volant, Casqué. Boss : le **Colosse** |
| Défenses | **Muret**, **Mini-Tourelle**, **Tapis Collant** | 3 posées au maximum par Survivant |
| Améliorations (Établi) | Dégâts, Cadence, Portée, Solidité, Réparation, Régénération, Butin, Balles explosives | Solidité, Réparation et Régénération profitent à toute l'équipe |
| Recherches | Tourelle de toit, Balles perforantes, Visée critique, Foreuse | La Foreuse produit des gemmes hors connexion, 8 h au maximum |
| Rendez-vous | **Défi du Jour**, **Zbire de la Semaine** | Défi du Jour : 2 modificateurs et 150 gemmes. Zbire de la Semaine : le samedi à 17 h, heure de Paris |
| Pings | **Roue des Pings** | « Colosse ! », « Répare ! », « Ici ! », « Merci ! » |

**Écart :** ces noms remplacent les noms de travail de l'analyse de marché (Pods de départ, Défi quotidien, Carnet de bestiaire, Monstre de la semaine).

## 7. Direction artistique

**Style « Pixel-bloc » : le pixel art de Zsurvie construit en cubes.**

- **Grilles :** sur les personnages, 1 pixel = 1 cube de 0,5 stud. Le décor suit une grille de 1 stud, les bâtiments une grille de 4 studs.
- **Matériaux :** `SmoothPlastic` sur 90 % des surfaces, 150 Parts `Neon` au maximum, pas de Terrain lisse.

**Palette :** Encre #1E1B2E, Prairie #6CC24A, Terre battue #C8894F, Crème #F6E7C1, Toit orange #EF7A2F, Or #FFC933, Gemme cyan #33D6F0, Violet horde #9B5DE5, Alerte #FF2E63, Nuit labo #2A3263. S'y ajoute Ardoise #4A4560 pour le métal et la roche.

- **Teintes :** 3 par couleur : la base, l'ombre (× 0,8) et la lumière (+ 20 % de Crème). Jamais de noir ni de blanc purs.
- **Référence code :** toutes les couleurs sont définies dans le module `ReplicatedStorage.Charte`.
- **Code couleur :** violet = ennemi, orange et crème = à nous, or = pièces, cyan = gemmes, rose-rouge = danger.
- **Lisibilité :** rien de plus haut que 6 studs à moins de 60 studs de la Maison.
- **Animation :** effet élastique (écrasement × 0,8, étirement × 1,2) en 0,15 s.
- **Son :** chiptune 8-bit.

## 8. Contraintes techniques

- **Places :**
  - Laboratoire : `MaxPlayers` 12.
  - Prairie : serveurs réservés via `TeleportService:ReserveServer`, `MaxPlayers` 6.
- **Appareil de référence :** Android d'entrée de gamme à 3 Go de RAM. Il doit tenir 30 FPS avec 6 joueurs et 60 Zbires, sous 800 Mo de mémoire. Sur PC : 60 FPS.
- **Plafond :** 60 Zbires à la fois (Mini-Gluants compris), plus le Colosse. Les suivants attendent leur tour. *Écart : l'analyse de marché visait 80, j'arrête 60 pour tenir la cible de performance.*
- **Zbires :** pas de `Humanoid`, 30 Parts au maximum chacun. Le serveur calcule position, PV et cible 10 fois par seconde. Les clients lissent l'affichage.
- **Arène :** 220 × 220 studs, 10 000 Parts au maximum, `StreamingEnabled` désactivé.
- **Effets :** 12 `PointLight` au maximum, `ParticleEmitter.Rate` ≤ 20, 16 sons simultanés.
- **Autorité serveur :** le client n'envoie que des demandes (tir, réparation, achat, pose, ping). Le serveur vérifie la cible, la distance, la cadence et le solde.
- **Sauvegarde :** les gemmes sont enregistrées à chaque jour franchi (`UpdateAsync`).
- **Mobile :**
  - boutons de 60 px minimum ;
  - tir automatique dans un rayon de 40 studs ;
  - caméra `Scriptable` décalée de (0, 45, 28), `FieldOfView` 50.
- **Coopération :** PV des Zbires × (1 + 0,35 × (joueurs − 1)).

## 9. Ce que Zsurvie n'est PAS

- **Un jeu d'horreur :** ni sang, ni cadavre, ni jump scare.
- **Un gacha ou un pay-to-win :** les Robux n'achètent que des cosmétiques et des serveurs privés.
- **Un tower defense immobile :** l'arme principale, c'est le Survivant.
- **Du PvP :** aucun dégât entre joueurs, aucun vol de butin.
- **Un jeu de survie à collecte :** pas de faim, pas de bois à couper, pas d'inventaire.
- **Un marathon :** une run de plus de 25 min est un bug d'équilibrage.

## 🖼️ Direction artistique
## Décisions

- **Canon** : aucun document du directeur créatif n'existait encore dans `00-vision/`. Je reprends donc à la lettre les noms du brief : **Zsurvie**, **la maison**, **la mine**, **le Laboratoire**, **pièces**, **gemmes**, **colosse** et les 8 monstres. **Écart signalé** : « la Prairie » (zone de combat) et « la Lisière » (anneau d'apparition des hordes) sont des noms de travail, à aligner sur le canon.
- **Style retenu : « Pixel-bloc »**, c'est-à-dire le pixel art de Zsurvie traduit en voxels 3D : blocs pleins, aplats, faces ombrées à la main, aucune texture réaliste.
  - *Fidélité* : 1 pixel du sprite d'origine = 1 cube de 0,5 stud sur les personnages. Le décor suit une grille de 1 stud et les bâtiments des modules de 4 studs.
  - *Lisibilité mobile* : avec des aplats et des silhouettes franches, on distingue 40 monstres sur un écran de 6 pouces.
  - *Performance* : `SmoothPlastic` et Parts simples. Cible : 30 FPS sur un téléphone d'entrée de gamme, avec 6 joueurs et 60 monstres.
  - *Écartés* : le réaliste (trop lourd et trop sombre), le low-poly lisse (perd l'ADN pixel), le 8-bit plat en 3D (réservé à l'UI).

## Palette

| # | Nom | Hex | `Color3.fromRGB` | Usage | Jamais sur |
|---|---|---|---|---|---|
| 1 | Encre | #1E1B2E | 30, 27, 46 | Pupilles, piquants, contours UI | Grandes surfaces |
| 2 | Prairie | #6CC24A | 108, 194, 74 | Sol de la Prairie, feuillages | Monstres |
| 3 | Terre battue | #C8894F | 200, 137, 79 | Chemins d'arrivée, sol de la mine | UI |
| 4 | Crème | #F6E7C1 | 246, 231, 193 | Murs de la maison, planches, yeux, texte UI | Corps des monstres |
| 5 | Toit orange | #EF7A2F | 239, 122, 47 | Toit de la maison, kit des survivants, défenses | Monstres |
| 6 | Or | #FFC933 | 255, 201, 51 | Pièces, monstre doré, boutons d'achat | Décor |
| 7 | Gemme cyan | #33D6F0 | 51, 214, 240 | Gemmes, cristaux de la mine, recherches | Décor de la Prairie |
| 8 | Violet horde | #9B5DE5 | 155, 93, 229 | Corps des monstres, portails de la Lisière | Joueurs, objets amis |
| 9 | Alerte | #FF2E63 | 255, 46, 99 | Dégâts, PV bas, télégraphes, yeux du colosse | Décor |
| 10 | Nuit labo | #2A3263 | 42, 50, 99 | Laboratoire, ciel du jour du colosse | Prairie en jeu normal |

**Nuances** : 3 valeurs par couleur, pas une de plus :
- la *base* sur les faces avant ;
- l'*ombre* (base × 0,8) sur les côtés et le dessous ;
- la *lumière* (base mêlée à 20 % de Crème) sur le dessus.

Seule exception : **Ardoise #4A4560** (Encre éclairci), pour le métal, la roche et les casques. Jamais de #000000 ni de #FFFFFF.

**Code couleur de jeu** : violet = ennemi, orange/crème = à nous, or = pièces, cyan = gemmes, rose-rouge = danger. On doit comprendre la scène en 1 seconde, sans lire de texte.

## Formes et silhouettes

- **Formes autorisées** : `Part` Block, `WedgePart` et `CornerWedgePart`, en rotations de 90° (45° pour les toits). Un rond se construit en escalier de cubes. Un `MeshPart` n'est accepté que s'il est voxelisé.
- **Détail minimum** : 0,5 stud sur au moins deux dimensions. En dessous, le détail disparaît sur téléphone.
- **Monstres** : la tête fait 50 % de la hauteur, avec des yeux en 2×2 cubes Crème et une pupille Encre.
  - Chaque monstre doit rester reconnaissable en ombre chinoise à 40 studs, avec la caméra de jeu.
  - Le volant et le sauteur projettent une ombre au sol en cubes Encre (`Transparency` 0,6).

| Monstre | Hauteur (studs) | Clé de silhouette |
|---|---|---|
| marcheur | 3 | Cube sur deux pattes : la référence |
| rapide | 2,5 | Allongé, penché de 30° en avant, oreilles rabattues |
| costaud à piquants | 5 (4 de large) | Carré massif, piquants `WedgePart` Encre sur le dos |
| doré | 3 | Marcheur entièrement Or, étincelles (`ParticleEmitter` avec `Rate` 4) |
| sauteur bondissant | 3,5 | Pattes-ressorts deux fois plus longues, s'écrase avant chaque bond |
| gluant | 2,5 (4 de large) | Dôme plat en escalier, `Transparency` 0,2. À sa mort, il se divise en deux gluants de 1,5 |
| volant | 2, à 8 du sol | Ailes de 3 studs qui battent |
| casqué blindé | 3,5 | Casque-seau Ardoise sur les yeux. Coup normal : étincelles Ardoise. Coup critique : flash Crème |
| colosse | 18 | Marcheur × 6 avec un dos de piquants, yeux Alerte `Neon`. Seul monstre avec un `Highlight` |

- **La maison** : 16 × 16 studs au sol, 14 de haut.
  - **Rien d'autre ne dépasse 6 studs dans un rayon de 60 studs**, pour qu'aucune horde ne soit masquée.
  - 3 états visuels : intacte ; fissurée sous 60 % de PV ; en ruine sous 25 % de PV (trous, `Smoke` Encre).
  - Les planches réparées restent visibles.
- **Les survivants** : chaque joueur garde son avatar et porte un kit commun (sac à dos et blaster blocky) en Toit orange et Crème.
  - Les alliés restent visibles à travers les murs grâce à un `Highlight` : `FillTransparency` 1, `OutlineColor` Crème, `DepthMode` AlwaysOnTop.

## Matériaux Roblox

- **`SmoothPlastic`** : 90 % des surfaces. C'est notre pixel.
- **`Neon`** : gemmes, cristaux, yeux du colosse, télégraphes et écrans du Laboratoire. Plafond : 150 Parts.
- **`Glass`** : uniquement pour les vitrines du Laboratoire.
- **`ForceField`** : uniquement pour les effets temporaires.
- **Textures pixel** : peintes en 16×16 puis exportées en 256×256 au plus proche voisin. Dans l'UI : `ImageLabel.ResampleMode = Enum.ResamplerMode.Pixelated`.
- **Sol de la Prairie** : pas de Terrain lisse. On pose des dalles de 8×8 studs qui alternent Prairie base et Prairie lumière, avec `CastShadow = false`.
- **Lighting** :
  - `Technology` ShadowMap ;
  - `EnvironmentalSpecularScale` 0 et `EnvironmentalDiffuseScale` 0,3 ;
  - `ColorCorrectionEffect` : Saturation 0,15, Contrast 0,1 ;
  - `BloomEffect` : Intensity 0,4, Size 18, Threshold 1,5.

## Ambiance des zones

| Zone | Ambiance | Lumière | Signature mémorable |
|---|---|---|---|
| **La maison** | Cocon chaleureux | `PointLight` Or, `Range` 16 | Cheminée qui fume, drapeau orange |
| **La Prairie** | Pique-nique joyeux qui tourne au chaos | `ClockTime` 14, `Ambient` (110,106,128) | 4 chemins de Terre battue en croix. Des fleurs-cubes s'écrasent sous les hordes puis repoussent |
| **La Lisière** | Forêt de cubes, mystérieuse sans faire peur | `Atmosphere` Density 0,35 | Des portails violets gonflent 2 s avant chaque vague |
| **La mine** | Trésor | `PointLight` cyan, `Range` 12 | Un wagonnet déverse des gemmes. La foreuse apparaît une fois débloquée |
| **Le Laboratoire** | Repaire de savant sympa | Nuit labo, néons cyan | Arbre de recherches en tubes qui s'allument, vitrines du bestiaire, portail de départ |
| **Jour du colosse** | Boss de fête foraine | `ClockTime` 17,5, `TintColor` (255,214,194) | Son ombre géante traverse la Prairie 5 s avant son arrivée |

Chaque recherche permanente ajoute un objet visible dans le Laboratoire (tourelle de toit sur la maquette de la maison, foreuse miniature…). Le joueur voit ce qu'il a construit, et c'est ce qui le fait revenir le lendemain.

## Références visuelles

1. **Crossy Road** : voxels en aplats, 3 valeurs par face, décor bas. *On prend* la règle des nuances.
2. **Minecraft Dungeons** : vue surélevée, hordes lisibles de loin, butin qui brille au sol. *On prend* la lecture des hordes. *On laisse* l'obscurité.
3. **Le Zsurvie d'origine** : animations élastiques. *On prend* le squash & stretch (× 0,8 / × 1,2, en 0,15 s) et le « pouf » de disparition. *On refuse* les sprites 2D sur `BillboardGui`.

## Charte vérifiable dans Studio

Placer ce ModuleScript dans `ReplicatedStorage.Charte`. C'est la source unique des couleurs, aussi pour l'UI et les VFX.

```lua
local Charte = {}

Charte.Couleurs = {
	Encre = Color3.fromRGB(30, 27, 46),
	Ardoise = Color3.fromRGB(74, 69, 96),
	Prairie = Color3.fromRGB(108, 194, 74),
	TerreBattue = Color3.fromRGB(200, 137, 79),
	Creme = Color3.fromRGB(246, 231, 193),
	ToitOrange = Color3.fromRGB(239, 122, 47),
	OrPieces = Color3.fromRGB(255, 201, 51),
	GemmeCyan = Color3.fromRGB(51, 214, 240),
	VioletHorde = Color3.fromRGB(155, 93, 229),
	Alerte = Color3.fromRGB(255, 46, 99),
	NuitLabo = Color3.fromRGB(42, 50, 99),
}

Charte.MateriauxAutorises = {
	[Enum.Material.SmoothPlastic] = true,
	[Enum.Material.Neon] = true,
	[Enum.Material.Glass] = true,
	[Enum.Material.ForceField] = true,
}

Charte.MAX_NEON = 150
Charte.DETAIL_MIN = 0.5

function Charte.Ombre(c: Color3): Color3
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end

function Charte.Lumiere(c: Color3): Color3
	return c:Lerp(Charte.Couleurs.Creme, 0.2)
end

local TOLERANCE = 3 / 255
local function proche(a: Color3, b: Color3): boolean
	return math.abs(a.R - b.R) <= TOLERANCE
		and math.abs(a.G - b.G) <= TOLERANCE
		and math.abs(a.B - b.B) <= TOLERANCE
end

function Charte.CouleurValide(c: Color3): boolean
	for _, base in Charte.Couleurs do
		if proche(c, base) or proche(c, Charte.Ombre(base)) or proche(c, Charte.Lumiere(base)) then
			return true
		end
	end
	return false
end

return Charte
```

Lancer cet audit dans la barre de commande avant chaque livraison d'asset. Il doit renvoyer 0 écart.

```lua
local Charte = require(game:GetService("ReplicatedStorage").Charte)
local racines = { workspace:FindFirstChild("Map"), game:GetService("ServerStorage"):FindFirstChild("Monstres") }
local ecarts, neon = 0, 0

for _, racine in racines do
	for _, inst in racine:GetDescendants() do
		if inst:IsA("SurfaceAppearance") then
			ecarts += 1
			warn("[Charte] SurfaceAppearance interdite : " .. inst:GetFullName())
		elseif inst:IsA("BasePart") and not inst:IsA("Terrain") then
			local nom = inst:GetFullName()
			if not Charte.CouleurValide(inst.Color) then
				ecarts += 1
				warn(("[Charte] Couleur #%s hors palette : %s"):format(inst.Color:ToHex(), nom))
			end
			if not Charte.MateriauxAutorises[inst.Material] then
				ecarts += 1
				warn(("[Charte] Matériau %s interdit : %s"):format(inst.Material.Name, nom))
			end
			local d = { inst.Size.X, inst.Size.Y, inst.Size.Z }
			table.sort(d)
			if d[2] < Charte.DETAIL_MIN then
				ecarts += 1
				warn("[Charte] Détail trop fin pour mobile : " .. nom)
			end
			if inst.Material == Enum.Material.Neon then
				neon += 1
			end
		end
	end
end

if neon > Charte.MAX_NEON then
	ecarts += 1
	warn(("[Charte] %d Parts Neon (max %d)"):format(neon, Charte.MAX_NEON))
end
print(("[Charte] Audit terminé : %d écart(s), %d Neon"):format(ecarts, neon))
```

## À ne jamais faire

- Du sang ou des cadavres. Un monstre vaincu éclate en cubes violets et en pièces.
- Un monstre effrayant : pas de dents réalistes, pas de jump scare.
- Une couleur hors palette, du violet sur un objet ami ou de l'orange sur un ennemi.
- Des matériaux réalistes (`Brick`, `Granite`, `WoodPlanks`…) ou une `SurfaceAppearance`.
- Du `Neon` dans le décor.
- Un objet de plus de 6 studs dans un rayon de 60 studs autour de la maison.
- Une sphère, un mesh lisse ou un détail de moins de 0,5 stud.
- Plus de 3 flashs par seconde, ou des particules plein écran (`ParticleEmitter.Rate` ≤ 20).
- Du texte peint dans le décor.
- Deux monstres avec la même silhouette.

## ⚖️ Analyse de marché
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

## 🎲 Game Design

### 🔁 Conceptrice boucle de jeu — Léa Morvan (révisé)
## 1. Les trois horloges

| Échelle | Durée | Unité | Question du joueur | Récompense |
|---|---|---|---|---|
| Micro | 30 s | 3 salves | « Où je cours ? » | Pops, Pièces |
| Moyenne | ≈ 5 min | 3 jours de 95 s | « J'achète quoi avant le Colosse ? » | Améliorations, nouveau Zbire |
| Session | 20-35 min | 1 ou 2 runs + Laboratoire | « Quelle recherche ? » | Gemmes, machine d'Alcôve, Record |

- **Arrivée :** 20 s pour toutes les runs (Doc Boulon à la radio, premières défenses). *Ajout au canon, soumis à Victor Lanoue.*
- **Jour N :** 80 s de horde + 15 s de Répit. La horde du jour N part à 20 + (N − 1) × 95 s, plus les prolongations des Jours du Colosse.
- **Colosse (J5, J10, J15) :** il sort du Grand Portail Nord 40 s après le début de la horde (7:20 au J5). 60 s après son entrée, il entre en colère : vitesse × 1,5, dégâts sur la Maison × 3. Le jour finit à sa chute.
- **Chute visée en Capsule Normale :** J8 à J11, soit 12 à 18 min.
- **Fin garantie :** Colosse du J15 abattu = victoire ; à 25:00 (`LIMITE_RUN`), fin de run forcée. Gemmes normales dans les deux cas.

## 2. Boucle de 30 secondes : repérer, se placer, tirer, ramasser, décider

| Temps | Action | Map et UI |
|---|---|---|
| 0-2 s | Repérer | Portail de la Lisière en Violet horde 2 s avant la salve, flèche de bord d'écran, son 8-bit |
| 2-6 s | Se placer | Maison → Lisière en moins de 5 s par les 4 chemins en Terre battue |
| 6-20 s | Tirer | Tir auto à 40 studs sur mobile ; le Zbire éclate en cubes et en Pièces (élastique 0,15 s) |
| 20-26 s | Ramasser | Pièces personnelles, aimant de 10 studs, disparition à 12 s : on ne campe pas au centre |
| 26-30 s | Décider | Maison sous 70 % → réparer ; Mine pleine → la vider ; défense libre → poser |

- Un pop toutes les 2 à 4 s pour chaque Survivant. Touché = étourdi 2 s, jamais éliminé.
- **Mine (règle a06, codée par a09) :** 1 gemme toutes les 20 s par Survivant actif, stock 6 (2 min), lueur cyan pulsée quand elle est pleine. Le premier qui la touche la vide pour toute l'équipe : y aller rend service.
- **Rythme des 80 s :** Marcheurs aux salves de 0 et 10 s, croisière jusqu'à 50 s, vedette du jour à 60 et 70 s, arrêt des apparitions à 72 s, éclatement **sans butin** à 80 s.
- **Jour parfait** *(soumis à Victor)* : tout vaincre avant 80 s ou, au Jour du Colosse, l'abattre avant sa colère. Bonus : 25 % des Pièces gagnées dans le jour, versées par `Economie.ajouterPieces` (≈ 12 au J1, 60 au J5, 140 au J9), et bannière Or. Il paie un 2e achat au Répit, quel que soit le jour.

## 3. Table des jours : `ZbiresDefs.JOURS`

Seule cette table bouge en playtest. HordeService (a26) la lit ainsi :
- **PV** = base × `pv` × coop du canon, avec `pv` = 1,15^(jour − 1) × 1,3^max(0, jour − 10). La Tension y est déjà : HordeService ne la réapplique pas et elle ne grossit pas les paquets. L'attribut `Tension` sert au HUD et à la Météo.
- **Salves** toutes les 10 s, de 0 à 70 s. Quota cumulé = `zbires` ÷ 8 par salve, découpé en paquets de 3 à 5 Zbires du même type, au plus un par portail actif. Le reste passe à la salve suivante.
- **Portails** tirés au début du jour : J1-3, un parmi Est, Ouest et Nord (jamais le Sud) ; J4-8, deux ; J9-11, trois ; J12-15, quatre, parmi les 8 (Sud et diagonales permis).
- **Dorés** seuls, à la salve de 40 s. Dorés et Mini-Gluants hors quota. Au-delà de 60 Zbires, les suivants attendent ; ceux qui ne sont pas sortis à 72 s sont annulés.
- **Colosse :** 2 500 × 1,15^(jour − 1) PV avant coop, sans Tension (≈ 45 s de combat en solo au J5).

```lua
--!strict
-- ReplicatedStorage.ZbiresDefs.Jours (ModuleScript). Dans ZbiresDefs : JOURS = require(script.Jours)
export type Jour = {
	pv: number, zbires: number, portails: number, choix: { string },
	vedette: string, dores: number, colosse: number?,
}

local CHEMINS = { "Est", "Ouest", "Nord" }
local TOUS = { "Nord", "Sud", "Est", "Ouest", "NordEst", "NordOuest", "SudEst", "SudOuest" }

-- { pv (Tension comprise), zbires avant coop, portails, vedette, dorés, PV du Colosse }
local BRUT: { { any } } = {
	{ 1.00, 25, 1, "Marcheur", 0 },
	{ 1.15, 32, 1, "Rapide", 0 },
	{ 1.32, 39, 1, "Rapide", 1 },
	{ 1.52, 46, 2, "Costaud", 1 },
	{ 1.75, 53, 2, "Costaud", 1, 4373 },
	{ 2.01, 60, 2, "Sauteur", 1 },
	{ 2.31, 67, 2, "Gluant", 1 },
	{ 2.66, 74, 2, "Volant", 1 },
	{ 3.06, 81, 3, "Casqué", 1 },
	{ 3.52, 88, 3, "Gluant", 2, 8795 },
	{ 5.26, 95, 3, "Volant", 2 },
	{ 7.86, 102, 4, "Casqué", 2 },
	{ 11.75, 109, 4, "Sauteur", 2 },
	{ 17.57, 116, 4, "Costaud", 2 },
	{ 26.27, 123, 4, "Casqué", 2, 17689 },
}

local JOURS: { Jour } = {}
for jour, l in BRUT do
	JOURS[jour] = {
		pv = l[1], zbires = l[2], portails = l[3], vedette = l[4], dores = l[5], colosse = l[6],
		choix = if jour <= 3 then CHEMINS else TOUS,
	}
end
return table.freeze(JOURS)
```

## 4. Boucle de 5 minutes : 3 jours, 3 achats, 1 menace

1. **Répit (15 s) :** l'Établi, collé à la façade de la Maison, s'ouvre par `ProximityPrompt` (`MaxActivationDistance` 14, `HoldDuration` 0). Cible : 1 achat par Répit, 2 après un Jour parfait. Les 3 défenses se reprennent gratuitement.
2. **Menace :** bandeau « Colosse dans X jours ». Dès le Répit qui précède (`JourColosse`), MeteoServeur passe au couchant (`ClockTime` 17,5) ; 3 s avant l'entrée, une flèche Alerte pointe vers `ColosseAngle`.
3. **Sans chat :** au Répit, un `BillboardGui` montre les 3 meilleures améliorations de chaque Survivant.
4. **Découverte :** carte de 2 s (silhouette + règle) à la première apparition d'un type dans la run.

| Jour | Nouveau | Leçon → recherche désirée |
|---|---|---|
| 1 | Marcheur | tirer, ramasser |
| 2 | Rapide | se placer tôt |
| 3 | Doré | le chasser → Foreuse |
| 4 | Costaud | Dégâts, Mini-Tourelle → Balles perforantes |
| 5 | **Colosse** | ping « Colosse ! » → Tourelle de toit |
| 6 | Sauteur | anticiper ses bonds |
| 7 | Gluant | finir les Mini-Gluants → Balles perforantes |
| 8 | Volant | survole les Murets : Portée → Tourelle de toit |
| 9 | Casqué | seuls les critiques percent → Visée critique |

## 5. Session et retour du lendemain

- **Parcours :** Laboratoire (Foreuse, Défi du Jour, Alcôves voisines) → Capsule (départ 15 s) → run 1 → 4 min au Laboratoire (recherche, machine animée, Galerie) → run 2, souvent Capsule du Jour → panneau « Demain ».
- **Écran de fin (8 s, passable) :** « La Maison est tombée au Jour X », « Victoire : 15 jours tenus ! » ou « Temps écoulé : la Maison tient toujours ! ». Puis Record, gemmes (déjà sauvegardées), Zbire qui a le plus abîmé la Maison → recherche conseillée, « Plus que N gemmes ».
- **Gemmes : barème unique a07**, via `Economie.franchirJour(jour)` : 5 + 2 × min(N, 15), doublé aux J5, J10 et J15, anti-AFK compris. S'y ajoutent Mine, Doré, Foreuse et Défi du Jour. 1re recherche à 40 gemmes : acquise dès le J4 franchi (7 + 9 + 11 + 13).
- **Sans marathon :** Capsule Difficile ouverte au Record Jour 10 en Normale, seule condition. Les J11 à J15 font un mur sous les 25 min.
- **Objectifs :** la run (Jour parfait, Colosse, Record), la semaine (4 recherches, paliers 10 et 100 de la Galerie, Difficile), le mois (paliers 1 000, Alcôve complète, Zbire de la Semaine).
- **Demain :** Foreuse pleine en 8 h, Défi du Jour (150 gemmes, minuit heure de Paris), panneau « Demain » (écart vers la recherche, heure de Foreuse pleine, samedi 17 h). Aucune série punitive, aucun minuteur payant, aucun message culpabilisant.

## 6. Contrat `EtatRun` et code serveur

`BoucleDuJour` n'écrit que dans le `Folder` `ReplicatedStorage.EtatRun` (contrat a28, lu par le HUD a32). Le ciel revient à MeteoServeur (a18).

| Attribut | Valeur |
|---|---|
| `Jour` | 1 dès l'Arrivée, puis à chaque horde |
| `Phase`, `FinPhase` | `Arrivee`, `Horde`, `Repit` ; fin en `GetServerTimeNow` (Jour du Colosse : sa colère, puis « COLÈRE ! ») |
| `JourColosse` | du Répit qui précède J5, J10 ou J15 jusqu'à sa chute |
| `ColosseActif` | de l'entrée à la chute |
| `Tension` | max(0, jour − 10) |
| `ColosseAngle` | 3 s avant l'entrée ; degrés depuis la Maison, 0 = Nord (−Z), 90 = Est (+X) |
| `JourParfait` | fin de chaque jour *(ajout au contrat a28)* |

```lua
--!strict
-- ServerScriptService.Run.BoucleDuJour (ModuleScript, place Prairie)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JOURS = require(ReplicatedStorage.ZbiresDefs).JOURS
local EtatRun = ReplicatedStorage:WaitForChild("EtatRun") :: Folder

export type Horde = {
	demarrer: (jour: number) -> (), -- lit JOURS[jour]
	stopperApparitions: () -> (),
	toutVaincu: () -> boolean, -- file d'attente comprise
	lancerColosse: (pv: number) -> (), -- Grand Portail Nord, coop appliquée par a26
	colosseVivant: () -> boolean,
	enragerColosse: () -> (), -- vitesse × 1,5, dégâts sur la Maison × 3
	vider: () -> (), -- stoppe tout, éclatement sans butin
}
export type Deps = {
	Economie: {
		franchirJour: (jour: number) -> (),
		ajouterPieces: (joueur: Player, montant: number) -> (),
		piecesGagnees: (joueur: Player) -> number, -- cumul de run, achats non déduits
	},
	Meteo: {
		demarrerRun: () -> (),
		planifierJour: (jour: number, colosse: boolean) -> (),
		debutJour: (jour: number, colosse: boolean) -> (),
	},
	Telemetrie: { fermerJour: (jour: number, bilan: { [string]: any }) -> () },
}

local ARRIVEE, HORDE, FIN_APPARITIONS, REPIT = 20, 80, 72, 15
local ENTREE_COLOSSE, ALERTE, COLERE = 40, 3, 60
local LIMITE_RUN, PART_PARFAIT, DEBUT_TENSION = 25 * 60, 0.25, 10

local function phase(nom: string, duree: number)
	EtatRun:SetAttribute("Phase", nom)
	EtatRun:SetAttribute("FinPhase", workspace:GetServerTimeNow() + duree)
end

local function colosseParti()
	EtatRun:SetAttribute("ColosseActif", false)
	EtatRun:SetAttribute("ColosseAngle", nil)
end

local BoucleDuJour = {}

-- Renvoie le jour atteint et l'issue : "Maison", "Limite" ou "Victoire".
function BoucleDuJour.lancer(maison: Model, grandPortail: PVInstance, horde: Horde, deps: Deps): (number, string)
	local limite = os.clock() + LIMITE_RUN
	local debout = true
	local connexion = maison:GetAttributeChangedSignal("PV"):Connect(function()
		if (maison:GetAttribute("PV") or 0) <= 0 then
			debout = false
		end
	end)
	local function actif(): boolean
		return debout and os.clock() < limite
	end
	local function attendre(duree: number)
		local t = 0
		while actif() and t < duree do
			t += task.wait(0.1)
		end
	end
	local avant: { [Player]: number } = {}
	local function photographier()
		table.clear(avant)
		for _, joueur in Players:GetPlayers() do
			avant[joueur] = deps.Economie.piecesGagnees(joueur)
		end
	end
	local d = grandPortail:GetPivot().Position - maison:GetPivot().Position
	local angle = math.deg(math.atan2(d.X, -d.Z))

	deps.Meteo.demarrerRun()
	EtatRun:SetAttribute("Jour", 1)
	EtatRun:SetAttribute("Tension", 0)
	EtatRun:SetAttribute("JourColosse", false)
	EtatRun:SetAttribute("JourParfait", false)
	colosseParti()
	deps.Meteo.planifierJour(1, false)
	phase("Arrivee", ARRIVEE)
	photographier()
	attendre(ARRIVEE)

	local jour, ouvert, victoire = 0, false, false
	while actif() do
		jour += 1
		local pvColosse = JOURS[jour].colosse
		local colosse = pvColosse ~= nil
		EtatRun:SetAttribute("Jour", jour)
		EtatRun:SetAttribute("Tension", math.max(0, jour - DEBUT_TENSION))
		EtatRun:SetAttribute("JourColosse", colosse)
		EtatRun:SetAttribute("JourParfait", false)
		deps.Meteo.debutJour(jour, colosse)
		phase("Horde", if colosse then ENTREE_COLOSSE + COLERE else HORDE)
		horde.demarrer(jour)
		ouvert = true

		local t, arrete, entre, enrage = 0, false, false, false
		while actif() do
			if not arrete and t >= FIN_APPARITIONS then
				horde.stopperApparitions()
				arrete = true
			end
			if pvColosse and not entre and t >= ENTREE_COLOSSE - ALERTE then
				EtatRun:SetAttribute("ColosseAngle", angle)
				if t >= ENTREE_COLOSSE then
					horde.lancerColosse(pvColosse)
					EtatRun:SetAttribute("ColosseActif", true)
					entre = true
				end
			end
			if entre and not enrage and t >= ENTREE_COLOSSE + COLERE then
				horde.enragerColosse()
				enrage = true
			end
			if (entre and not horde.colosseVivant()) or (not colosse and t >= HORDE) then
				break
			end
			t += task.wait(0.1)
		end
		if not actif() then
			break
		end

		local parfait = if colosse then not enrage else horde.toutVaincu()
		horde.vider()
		colosseParti()
		deps.Economie.franchirJour(jour)
		if parfait then
			for _, joueur in Players:GetPlayers() do
				local base = avant[joueur]
				local bonus = if base then math.floor((deps.Economie.piecesGagnees(joueur) - base) * PART_PARFAIT) else 0
				if bonus > 0 then
					deps.Economie.ajouterPieces(joueur, bonus)
				end
			end
		end
		photographier()
		EtatRun:SetAttribute("JourParfait", parfait)
		deps.Telemetrie.fermerJour(jour, { issue = "franchi", parfait = parfait, duree = t })
		ouvert = false
		if jour >= #JOURS then
			victoire = true
			break
		end
		local suivant = JOURS[jour + 1].colosse ~= nil
		EtatRun:SetAttribute("JourColosse", suivant)
		deps.Meteo.planifierJour(jour + 1, suivant)
		phase("Repit", REPIT)
		attendre(REPIT)
	end

	connexion:Disconnect()
	horde.vider()
	colosseParti()
	local issue = if victoire then "Victoire" elseif debout then "Limite" else "Maison"
	if ouvert then
		deps.Telemetrie.fermerJour(jour, { issue = issue, parfait = false })
	end
	return jour, issue
end

return BoucleDuJour
```

Un `Script` de `ServerScriptService` appelle `BoucleDuJour.lancer(workspace.Maison, workspace.Lisiere.GrandPortailNord, Horde, { Economie = Economie, Meteo = MeteoServeur, Telemetrie = Telemetrie })` quand tous les Survivants sont arrivés, affiche l'écran de fin selon l'issue, met à jour le Record Normale, puis renvoie au Laboratoire. Les clients lisent `EtatRun` et n'envoient que des demandes.

### 💰 Designer économie de jeu — Hugo Ravel (révisé)
## 1. Règles de base

- **Deux monnaies (canon).** Les **Pièces** sont propres à chaque Survivant. Elles vivent en mémoire serveur et s'affichent par l'attribut `Pieces` du `Player`. Elles sont perdues quand la Maison tombe. Les **Gemmes** sont permanentes et passent uniquement par `Donnees.AjouterGemmes` et `Donnees.CrediterRun` (`UpdateAsync` à chaque jour franchi).
- **Une seule table de chiffres :** `ReplicatedStorage.Catalogue` (§7), lue par `Economie`, `Donnees`, l'UI et l'onboarding. Le `CATALOGUE` et `AcheterAmelioration` de a33 sont supprimés. a06 et a09 retirent leurs chiffres.
- **Un seul handler :** `Economie` (§8) traite `DemandeAchat(cle, niveauVise)`, la cagnotte, ainsi que le paiement et la reprise des défenses.
- **Interdit :** une 3e monnaie, toute conversion de Pièces en Gemmes, la vente de Gemmes en Robux.

## 2. Sources et puits

| Flux | Règle | Valeur (Catalogue) |
|---|---|---|
| + Pièces | Zbire éliminé, butin instancié | `PIECES_PAR_ZBIRE` × (1 + 0,12 × (jour − 1)) × (1 + 0,10 × Butin) ÷ (1 + 0,2 × (actifs − 1)) |
| + Pièces | Aimant serveur de 8 studs, 20 s au sol. Ce qui n'est pas ramassé est versé au début du Répit (« +X » gris) | 50 %, soit ≈ 85 % du butin encaissé |
| + Pièces | Jour parfait, via `ajouterPieces` | 25 % des Pièces du jour |
| + Pièces | Reprise d'une défense | 50 % du prix payé |
| − Pièces | Établi individuel : Dégâts, Cadence, Portée, Butin (niv. 5 max), Balles explosives | base × 1,45^(niv − 1), niv. 10 max |
| − Pièces | Cagnotte d'équipe : Solidité, Réparation, Régénération | même prix × (0,5 + 0,5 × joueurs) |
| − Pièces | Défenses (3 posées max) : Muret 15, Tapis Collant 25, Mini-Tourelle 60 | × (1 + 0,15 × (jour − 1)) |
| + Gemmes | Jour franchi | 5 + 2 × min(jour, 15), doublé aux J5, J10 et J15 |
| + Gemmes | Mine commune : 1 gemme toutes les 20 s, stock de 6. Au contact d'un Survivant, le stock est versé à chaque Survivant actif | ≈ 3 par minute |
| + Gemmes | Doré : 1 par jour dès le J3, 2 par jour dès le J8 | 4 par Survivant (+ 10 Pièces) |
| + Gemmes | Foreuse hors connexion, 8 h max | 5, 9, 14, 20, 27 par heure |
| + Gemmes | Défi du Jour, après le 1er Colosse repoussé, clé `Transactions.cleJourParis` | 150 |
| + Gemmes | Plancher de la 1re run terminée | 40 minimum |
| − Gemmes | Recherches | base × 1,7^(niv − 1) |

Pièces par Zbire : Marcheur 2, Rapide 2, Sauteur 3, Volant 3, Gluant 3, Mini-Gluant 1, Costaud 5, Casqué 5, Doré 10, Colosse 150. Le Colosse repoussé n'a pas de bonus propre : son jour franchi est doublé. Le Zbire de la Semaine n'a pas de source de gemmes propre.

## 3. Établi, défenses et Maison

| Ligne (base) | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 10 |
|---|---|---|---|---|---|---|---|---|
| Dégâts (10) | 10 | 15 | 20 | 30 | 45 | 65 | 135 | 285 |
| Portée, Réparation (20) | 20 | 30 | 40 | 60 | 90 | 130 | 270 | 565 |
| Cadence (25) | 25 | 35 | 55 | 75 | 110 | 160 | 335 | 710 |
| Solidité, Butin (30) | 30 | 45 | 65 | 90 | 135 | 190 | 405 | 850 |
| Régénération (40) | 40 | 60 | 85 | 120 | 175 | 255 | 540 | 1 135 |
| Balles explosives (60) | 60 | 85 | 125 | 185 | 265 | 385 | 810 | 1 700 |

- **Premier achat :** Dégâts 1 coûte 10 Pièces, soit 5 Marcheurs (6 à 85 % de ramassage). L'achat tient avant T 70 s (a10). *Écart à la consigne (base 25), qui lève le bloquant QA.*
- **Cumuls par Survivant** à 85 % de ramassage, hors Butin et Jour parfait : 780 au J5, 1 275 au J7, 2 700 au J10, 3 740 au J12 et 6 200 au J15, identiques de 1 à 6 joueurs. Tout l'Établi coûte ≈ 18 600 en solo. On en finance un tiers au J15, ce qui pousse à se spécialiser.
- **Cagnotte :** chacun paie 70 % du prix à 2,5 joueurs et 58 % à 6. Un tap verse ce qui manque, dans la limite du solde. Le niveau monte dès que la cagnotte atteint le prix, et le surplus reste pour le niveau suivant.
- **Défenses :** le prix est arrondi à l'unité et stocké dans l'attribut `PrixPaye`. Muret : 150 × 1,15^(jour − 1) PV (262 au J5, 528 au J10). Mini-Tourelle : 50 % des dégâts du Blaster de son poseur.
- **Maison :** 1 000 PV × (1 + 0,12 × Solidité). La réparation rend 1,5 % × (1 + 0,25 × niv) × (1 + 0,5 × (réparateurs − 1)) des PV max par seconde, avec 3 réparateurs comptés au plus : 15 PV/s seul au niveau 0, 30 PV/s à trois.
- L'Établi est à moins de 6 s de course de la Maison, pour tenir dans le Répit de 15 s.

## 4. Recherches (Gemmes)

| Ligne | Niv. 1 à 5 | Niv. 10 | Total | Effet (à caler avec le combat) |
|---|---|---|---|---|
| Tourelle de toit | 40, 70, 115, 195, 335 | 4 745 | 11 465 | Portée 35 studs, puis + 25 % de dégâts par niveau |
| Visée critique | 70, 120, 200, 345, 585 | 8 300 | 20 060 | 9 % de critiques (× 2), + 4 points par niveau |
| Balles perforantes | 80, 135, 230, 395, 670 | 9 485 | 22 925 | Traversent 1 Zbire : 50 % au 2e, + 10 points par niveau |
| Foreuse (5 niv.) | 100, 170, 290, 490, 835 | — | 1 885 | 5, 9, 14, 20, 27 gemmes/h (40 à 216 par nuit) |

L'arbre coûte ≈ 56 300 gemmes (≈ 45 h), soit la 6e semaine, comme le niveau 30 de a08. La Tourelle de toit 1 coûte 40 gemmes, le plancher : Doc Boulon peut toujours la faire acheter. Règle de réglage : la recherche la moins chère coûte entre 0,8 et 1,5 session de gains.

## 5. Courbe de gains (5 premières heures)

**Hypothèses :**
- **Coop :** 2,5 Survivants en moyenne. La horde (× 1,3 Zbires, × 1,525 PV) pèse × 1,98 face à un DPS × 2,5 : on tient ≈ 1 jour de plus qu'en solo.
- **Rythme :** 1 h par jour en 2 sessions. On ramasse 90 % de la Mine et on élimine 75 % des Dorés.
- **Défi du Jour :** débloqué dès la 1re run.
- **Bonus de run :**
  - Filon et Panier (a15) : + 10 % des gemmes de run.
  - Capsule Difficile : + 50 %. Hypothèse : ouverte au Record J10, chute 2 jours plus tôt.
  - Week-end (a49) : + 100 % sur les gemmes de run.
  - Ces bonus s'additionnent : × 2,5 au plus.
- **Foreuse :** pleine 1 fois par jour. Hypothèse : Turbo (a08) × 1,25 en moyenne.

| Chute au | J5 | J6 | J7 | J8 | J9 | J10 | J11 | J12 |
|---|---|---|---|---|---|---|---|---|
| Jours franchis | 40 | 70 | 87 | 106 | 127 | 150 | 200 | 227 |
| Mine + Dorés | 25 | 32 | 39 | 47 | 57 | 67 | 78 | 88 |
| **Gemmes par Survivant** | 65 | 102 | 126 | 153 | 184 | 217 | 278 | 315 |

**Cible publiée d'une 1re run au J6 : 112 gemmes**, soit 102 + ≈ 10 de a15. La fourchette H7/H8 va de 95 à 130 gemmes. Un week-end, la cible passe à 224, et jamais moins de 40. Doc Boulon fait acheter la Tourelle de toit 1 et la Visée critique 1 (110).

| Heure | Runs (chute) | Run + a15 | Défi | Foreuse | Total | Si week-end | Cumul | Recherches |
|---|---|---|---|---|---|---|---|---|
| 1 | J6, J7, J7, J8 | 558 | 150 | — | 708 | 1 266 | 708 | 7 |
| 2 | J8, J9, J9 | 573 | 150 | 50 | 773 | 1 346 | 1 481 | 11 |
| 3 | J9, J10, J10 | 680 | 150 | 90 | 920 | 1 600 | 2 401 | 14 |
| 4 | J10, J11, Difficile J9 | 848 | 150 | 140 | 1 138 | 1 885 | 3 539 | 17 |
| 5 | J11, J11, Difficile J10 | 970 | 150 | 200 | 1 320 | 2 170 | 4 859 | 19 |

Les gains par heure sont multipliés par 1,86, le prix de la prochaine recherche par 17 (de 40 à 670). On passe de 7 achats la 1re heure à 1 achat par session. Un joueur qui enchaîne 5 h d'affilée gagne 3 780 gemmes, soit 22 % de moins : revenir chaque jour rapporte plus, sans pénaliser les longues sessions.

## 6. Garde-fous

1. **Remise à zéro :** les Pièces sont perdues à chaque run. Les prix montent de 45 % par niveau, les gains de 12 % par jour.
2. **Fin de run garantie :** la Maison tombe entre J11 et J15, soit 22,8 min au plus. Si la médiane dépasse J15, on corrige les PV des Zbires, jamais les gains.
3. **Plafond :** les gemmes du jour franchi n'augmentent plus après J15. Une run rapporte ≈ 520 gemmes de base au maximum, bonus additifs compris.
4. **Coop bornée (correction QA) :**
   - HordeService multiplie les Zbires par jour par (1 + 0,2 × (actifs − 1)).
   - Les Pièces par Zbire sont divisées par ce même facteur. La fraction est conservée côté serveur, donc le revenu par Survivant est identique à tout effectif.
   - Bonus : ≈ + 1 jour à 2 ou 3 joueurs, + 0,6 jour à 6.
5. **Activité unique :**
   - `Economie.marquerActif` et `Economie.estActif`, aussi appelés par a08 (XP) et a14 (coop).
   - Ce qui compte : 4 studs de déplacement cumulé, une réparation, une pose, un ping ou un tap de ciblage. Le tir automatique est exclu.
   - Fenêtre de 90 s. À 75 s, l'attribut `Inactif` déclenche un « Zzz » et un bip.
   - Les gemmes refusées alimentent `GemmesInactif`. L'écran de fin affiche la ligne « Inactif : X gemmes non versées ».
   - H3 vérifie qu'aucun joueur réellement actif n'est pénalisé.
6. **Horloges serveur :**
   - La Foreuse lit `os.time()` et reste plafonnée à 8 h.
   - Le Défi du Jour, le Calendrier et les secrets se remettent à zéro sur `Transactions.cleJourParis`, à minuit heure de Paris. Le 0 h UTC est abandonné.
7. **Idempotence :** `CrediterRun` écrit le cumul de la run, avec `runId` = `game.JobId`.
8. **Robux :** ils n'achètent que des cosmétiques et des serveurs privés, où les gains sont les mêmes.
9. **Suivi :** `AnalyticsService:LogEconomyEvent` est appelé à chaque achat (Economie) et à chaque crédit de gemmes (Donnees). Alerte si le stock médian dépasse 2 fois le prochain prix.

## 7. `ReplicatedStorage.Catalogue`

```lua
--!strict
-- ReplicatedStorage > Catalogue (ModuleScript). Seule table de chiffres de Zsurvie.
local Catalogue = {}

Catalogue.ETABLI = {
	CROISSANCE = 1.45, RAYON_ACHAT = 14,
	BASES = { Degats = 10, Cadence = 25, Portee = 20, Reparation = 20, Solidite = 30,
		Butin = 30, Regeneration = 40, BallesExplosives = 60 } :: { [string]: number },
	NIVEAU_MAX = { Butin = 5 } :: { [string]: number }, -- 10 sinon
	PARTAGEES = { Solidite = true, Reparation = true, Regeneration = true } :: { [string]: boolean },
}
Catalogue.DEFENSES = {
	PRIX = { Muret = 15, TapisCollant = 25, MiniTourelle = 60 } :: { [string]: number },
	HAUSSE_JOUR = 0.15, REPRISE = 0.5, MAX_POSEES = 3,
	MURET_PV = 150, MURET_CROISSANCE = 1.15, TOURELLE_PART_BLASTER = 0.5,
}
Catalogue.PIECES_PAR_ZBIRE = { Marcheur = 2, Rapide = 2, Sauteur = 3, Volant = 3, Gluant = 3,
	MiniGluant = 1, Costaud = 5, Casque = 5, Dore = 10, Colosse = 150 } :: { [string]: number }
Catalogue.PIECES = { HAUSSE_JOUR = 0.12, BUTIN_NIVEAU = 0.10, AIMANT = 8, DUREE_SOL = 20,
	ASPIRATION_REPIT = 0.5, JOUR_PARFAIT = 0.25 }
Catalogue.GEMMES = { JOUR_BASE = 5, JOUR_PENTE = 2, JOUR_PLAFOND = 15, MINE_PERIODE = 20,
	MINE_STOCK = 6, MINE_CONTACT = 7, DORE = 4, DORE_DES_JOUR = 3, DORE_DOUBLE_DES_JOUR = 8,
	PLANCHER_PREMIERE_RUN = 40, DEFI_DU_JOUR = 150, BONUS_DIFFICILE = 0.5, BONUS_WEEKEND = 1 }
Catalogue.RECHERCHES = {
	CROISSANCE = 1.7, FOREUSE_PAR_HEURE = { 5, 9, 14, 20, 27 }, FOREUSE_HEURES_MAX = 8,
	LIGNES = { TourelleDeToit = { base = 40, max = 10 }, ViseeCritique = { base = 70, max = 10 },
		BallesPerforantes = { base = 80, max = 10 }, Foreuse = { base = 100, max = 5 },
	} :: { [string]: { base: number, max: number } },
}
Catalogue.MAISON = { PV = 1000, SOLIDITE_NIVEAU = 0.12, REPARATION = 0.015,
	REPARATION_NIVEAU = 0.25, REPARATEUR_EN_PLUS = 0.5, REPARATEURS_MAX = 3 }
Catalogue.COOP = { PV_ZBIRE = 0.35, ZBIRES_JOUR = 0.2 }
Catalogue.ACTIVITE = { FENETRE = 90, ALERTE = 75, DEPLACEMENT = 4 }

local function arrondi5(x: number): number
	return math.floor(x / 5 + 0.5) * 5
end

function Catalogue.prixEtabli(cle: string, niveau: number, joueurs: number): number?
	local base = Catalogue.ETABLI.BASES[cle]
	if base == nil or niveau < 1 or niveau % 1 ~= 0 or niveau > (Catalogue.ETABLI.NIVEAU_MAX[cle] or 10) then
		return nil
	end
	local prix = arrondi5(base * Catalogue.ETABLI.CROISSANCE ^ (niveau - 1))
	return if Catalogue.ETABLI.PARTAGEES[cle] then arrondi5(prix * (0.5 + 0.5 * math.max(joueurs, 1))) else prix
end

function Catalogue.prixDefense(cle: string, jour: number): number?
	local base = Catalogue.DEFENSES.PRIX[cle]
	return if base then math.floor(base * (1 + Catalogue.DEFENSES.HAUSSE_JOUR * (jour - 1)) + 0.5) else nil
end

function Catalogue.prixRecherche(cle: string, niveau: number): number?
	local ligne = Catalogue.RECHERCHES.LIGNES[cle]
	if ligne == nil or niveau < 1 or niveau > ligne.max then
		return nil
	end
	return arrondi5(ligne.base * Catalogue.RECHERCHES.CROISSANCE ^ (niveau - 1))
end

function Catalogue.gemmesJour(jour: number): number
	local g = Catalogue.GEMMES
	local gain = g.JOUR_BASE + g.JOUR_PENTE * math.min(jour, g.JOUR_PLAFOND)
	return if jour % 5 == 0 and jour <= g.JOUR_PLAFOND then gain * 2 else gain
end

function Catalogue.facteurHorde(actifs: number): number
	return 1 + Catalogue.COOP.ZBIRES_JOUR * (math.max(actifs, 1) - 1)
end

function Catalogue.pvMaison(solidite: number): number
	return Catalogue.MAISON.PV * (1 + Catalogue.MAISON.SOLIDITE_NIVEAU * solidite)
end

function Catalogue.reparationParSeconde(niveau: number, reparateurs: number, pvMax: number): number
	local m = Catalogue.MAISON
	local n = math.clamp(reparateurs, 1, m.REPARATEURS_MAX)
	return pvMax * m.REPARATION * (1 + m.REPARATION_NIVEAU * niveau) * (1 + m.REPARATEUR_EN_PLUS * (n - 1))
end

function Catalogue.pvMuret(jour: number): number
	return math.floor(Catalogue.DEFENSES.MURET_PV * Catalogue.DEFENSES.MURET_CROISSANCE ^ (jour - 1) + 0.5)
end

return table.freeze(Catalogue)
```

## 8. `ServerScriptService.Economie` (place Prairie)

**Appels attendus :**
- Directeur de run : `debutJour` (renvoie le facteur de horde à HordeService), `debutRepit(jourParfait)`, `franchirJour(jour)`, `finDeRun`.
- HordeService : `lacherButin`.
- Handlers de réparation, de pose, de ping et de ciblage : `marquerActif`.
- DemandePose : `payerDefense` et `reprendreDefense`.

```lua
--!strict
-- Seul script qui crédite ou débite des Pièces. Toute gemme de run passe par Donnees.
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local C = require(ReplicatedStorage.Catalogue)
local Donnees = require(ServerScriptService.Donnees)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DemandeAchat = Remotes:WaitForChild("DemandeAchat") :: RemoteEvent
local GainPieces = Remotes:WaitForChild("GainPieces") :: RemoteEvent
local Butin = Remotes:WaitForChild("Butin") :: RemoteEvent
local ButinRetire = Remotes:WaitForChild("ButinRetire") :: RemoteEvent
local Mine = workspace:WaitForChild("Mine") :: Model
local Etabli = workspace:WaitForChild("Etabli") :: Model

type Piece = { valeur: number, pos: Vector3, ne: number }
type Etat = { pieces: number, piecesJour: number, reliquat: number, fraction: number, perdues: number,
	niveaux: { [string]: number }, sol: { [number]: Piece }, derniereAction: number,
	derniereDemande: number, dernierePos: Vector3?, cumul: number }

local etats: { [Player]: Etat } = {}
local niveauxEquipe: { [string]: number } = {}
local cagnotte: { [string]: number } = {}
local EtatEquipe = Instance.new("Folder")
EtatEquipe.Name = "EtatEquipe"
EtatEquipe.Parent = ReplicatedStorage
local enRun, facteurHorde, stockMine, horlogeMine, prochainId = false, 1, 0, 0, 0
local Economie = {}

local function racine(joueur: Player): BasePart?
	local perso = joueur.Character
	return if perso then perso:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end

local function crediter(joueur: Player, e: Etat, montant: number, gain: boolean, gris: boolean)
	if montant <= 0 then return end
	e.pieces += montant
	if gain then e.piecesJour += montant end
	joueur:SetAttribute("Pieces", e.pieces)
	GainPieces:FireClient(joueur, montant, gris)
end

local function debiter(joueur: Player, e: Etat, montant: number, article: string)
	e.pieces -= montant
	joueur:SetAttribute("Pieces", e.pieces)
	AnalyticsService:LogEconomyEvent(joueur, Enum.AnalyticsEconomyFlowType.Sink, "Pieces",
		montant, e.pieces, Enum.AnalyticsEconomyTransactionType.Shop.Name, article)
end

-- Seule définition de « Survivant actif » (a07, a08, a14). Jamais appelé par le tir automatique.
function Economie.marquerActif(joueur: Player)
	local e = etats[joueur]
	if e then
		e.derniereAction, e.cumul = os.clock(), 0
		if joueur:GetAttribute("Inactif") then joueur:SetAttribute("Inactif", false) end
	end
end

function Economie.estActif(joueur: Player): boolean
	local e = etats[joueur]
	return e ~= nil and os.clock() - e.derniereAction < C.ACTIVITE.FENETRE
end

function Economie.nombreActifs(): number
	local n = 0
	for joueur in etats do
		if Economie.estActif(joueur) then n += 1 end
	end
	return math.max(n, 1)
end

function Economie.gagnerGemmes(joueur: Player, montant: number, source: string)
	local e = etats[joueur]
	if e == nil or montant <= 0 then return end
	if Economie.estActif(joueur) then
		Donnees.AjouterGemmes(joueur, montant, source)
	else
		e.perdues += montant
		joueur:SetAttribute("GemmesInactif", e.perdues) -- ligne « inactif » de l'écran de fin
	end
end

function Economie.prixEtabli(cle: string, niveau: number): number?
	return C.prixEtabli(cle, niveau, #Players:GetPlayers())
end

function Economie.ajouterPieces(joueur: Player, montant: number)
	local e = etats[joueur]
	if e then crediter(joueur, e, math.floor(montant), false, false) end
end

-- Butin instancié. Plus de Zbires en coop, chacun vaut moins : revenu par Survivant constant.
function Economie.lacherButin(typeZbire: string, position: Vector3, jour: number)
	local base = C.PIECES_PAR_ZBIRE[typeZbire]
	if base == nil or not enRun then return end
	for joueur, e in etats do
		local butin = math.min(e.niveaux.Butin or 0, 5)
		e.fraction += base * (1 + C.PIECES.HAUSSE_JOUR * (jour - 1)) * (1 + C.PIECES.BUTIN_NIVEAU * butin) / facteurHorde
		local valeur = math.floor(e.fraction)
		if valeur >= 1 then
			e.fraction -= valeur
			prochainId += 1
			e.sol[prochainId] = { valeur = valeur, pos = position, ne = os.clock() }
			Butin:FireClient(joueur, prochainId, position, valeur)
		end
		if typeZbire == "Dore" then Economie.gagnerGemmes(joueur, C.GEMMES.DORE, "Dore") end
	end
end

function Economie.payerDefense(joueur: Player, cle: string, jour: number): number?
	local e = etats[joueur]
	local prix = C.prixDefense(cle, jour)
	if e == nil or prix == nil or e.pieces < prix then return nil end
	debiter(joueur, e, prix, cle)
	return prix -- à écrire dans l'attribut PrixPaye de la défense
end

function Economie.reprendreDefense(joueur: Player, prixPaye: number)
	local e = etats[joueur]
	if e then crediter(joueur, e, math.floor(prixPaye * C.DEFENSES.REPRISE), false, false) end
end

local function acheter(joueur: Player, cle: unknown, niveauVise: unknown)
	local e = etats[joueur]
	local maintenant = os.clock()
	if e == nil or typeof(cle) ~= "string" or typeof(niveauVise) ~= "number"
		or maintenant - e.derniereDemande < 0.2 then return end
	e.derniereDemande = maintenant
	local r = racine(joueur)
	if r == nil or (r.Position - Etabli:GetPivot().Position).Magnitude > C.ETABLI.RAYON_ACHAT then return end
	local partagee = C.ETABLI.PARTAGEES[cle] == true
	local niveaux = if partagee then niveauxEquipe else e.niveaux
	if niveauVise ~= (niveaux[cle] or 0) + 1 then return end -- un double tap n'achète pas 2 fois
	local prix = Economie.prixEtabli(cle, niveauVise)
	if prix == nil then return end
	if not partagee then
		if e.pieces < prix then return end
		debiter(joueur, e, prix, cle)
		e.niveaux[cle] = niveauVise
		joueur:SetAttribute("Niv_" .. cle, niveauVise)
		return
	end
	-- Cagnotte : un tap verse ce qui manque, dans la limite du solde.
	local verse = math.min(math.max(prix - (cagnotte[cle] or 0), 0), e.pieces)
	if verse > 0 then debiter(joueur, e, verse, cle) end
	local total = (cagnotte[cle] or 0) + verse
	if total >= prix then
		total -= prix
		niveauxEquipe[cle] = niveauVise
		EtatEquipe:SetAttribute("Niv_" .. cle, niveauVise)
	end
	cagnotte[cle] = total
	EtatEquipe:SetAttribute("Cagnotte_" .. cle, total)
end

local function suivreActivite(joueur: Player, e: Etat, maintenant: number)
	local r = racine(joueur)
	if r then
		local d = if e.dernierePos then (r.Position - e.dernierePos).Magnitude else 0
		e.dernierePos = r.Position
		if d >= 0.1 then e.cumul += math.min(d, 10) end -- ignore le tremblement, borne la téléportation
		if e.cumul >= C.ACTIVITE.DEPLACEMENT then Economie.marquerActif(joueur) end
	end
	local alerte = maintenant - e.derniereAction >= C.ACTIVITE.ALERTE -- « Zzz » + bip côté client
	if joueur:GetAttribute("Inactif") ~= alerte then joueur:SetAttribute("Inactif", alerte) end
end

local function balayerSol(joueur: Player, e: Etat, maintenant: number)
	local r = racine(joueur)
	for id, p in e.sol do
		local ramassee = r ~= nil and (r.Position - p.pos).Magnitude <= C.PIECES.AIMANT
		if ramassee or maintenant - p.ne >= C.PIECES.DUREE_SOL then
			e.sol[id] = nil
			if ramassee then crediter(joueur, e, p.valeur, true, false) else e.reliquat += p.valeur end
			ButinRetire:FireClient(joueur, id, ramassee)
		end
	end
end

local function tickMine(pas: number)
	horlogeMine += pas
	while horlogeMine >= C.GEMMES.MINE_PERIODE do
		horlogeMine -= C.GEMMES.MINE_PERIODE
		stockMine = math.min(stockMine + 1, C.GEMMES.MINE_STOCK)
	end
	Mine:SetAttribute("Stock", stockMine)
	if stockMine == 0 then return end
	local centre = Mine:GetPivot().Position
	for joueur in etats do
		local r = racine(joueur)
		if r and (r.Position - centre).Magnitude <= C.GEMMES.MINE_CONTACT then
			local verse = stockMine
			stockMine = 0
			for survivant in etats do Economie.gagnerGemmes(survivant, verse, "Mine") end
			return
		end
	end
end

function Economie.debutJour(): number
	enRun = true
	facteurHorde = C.facteurHorde(Economie.nombreActifs())
	for _, e in etats do e.piecesJour = 0 end
	return facteurHorde -- HordeService : Zbires du jour × facteurHorde
end

function Economie.debutRepit(jourParfait: boolean)
	for joueur, e in etats do
		for _, p in e.sol do e.reliquat += p.valeur end
		table.clear(e.sol)
		ButinRetire:FireClient(joueur, 0, false) -- 0 : tout retirer
		crediter(joueur, e, math.floor(e.reliquat * C.PIECES.ASPIRATION_REPIT), true, true)
		e.reliquat = 0
		if jourParfait then Economie.ajouterPieces(joueur, e.piecesJour * C.PIECES.JOUR_PARFAIT) end
	end
end

function Economie.franchirJour(jour: number)
	for joueur in etats do
		Economie.gagnerGemmes(joueur, C.gemmesJour(jour), "Jour")
		task.spawn(Donnees.CrediterRun, joueur, false)
	end
end

function Economie.finDeRun()
	enRun = false
	for joueur in etats do
		task.spawn(Donnees.CrediterRun, joueur, true) -- Donnees applique le plancher de 40
	end
end

local function initialiser(joueur: Player)
	etats[joueur] = { pieces = 0, piecesJour = 0, reliquat = 0, fraction = 0, perdues = 0, niveaux = {},
		sol = {}, derniereAction = os.clock(), derniereDemande = 0, dernierePos = nil, cumul = 0 }
	joueur:SetAttribute("Pieces", 0)
	joueur:SetAttribute("GemmesInactif", 0)
end

Players.PlayerAdded:Connect(initialiser)
for _, joueur in Players:GetPlayers() do initialiser(joueur) end
Players.PlayerRemoving:Connect(function(joueur)
	Donnees.CrediterRun(joueur, false)
	etats[joueur] = nil -- les Pièces disparaissent avec la run (canon)
end)
DemandeAchat.OnServerEvent:Connect(acheter)

local accumule = 0
RunService.Heartbeat:Connect(function(dt)
	accumule += dt
	if accumule < 0.2 then return end
	local maintenant = os.clock()
	for joueur, e in etats do
		suivreActivite(joueur, e, maintenant)
		balayerSol(joueur, e, maintenant)
	end
	if enRun then tickMine(accumule) end
	accumule = 0
end)

return Economie
```

## 9. Soumis à Victor Lanoue

1. **Aspiration à 50 %.** Les Pièces non ramassées (après 20 s au sol, ou encore au sol au début du Répit) sont versées à moitié, avec un « +X » gris. Un enfant sur téléphone tire à 40 studs mais ne ramasse qu'à 8 : sans cette règle, on perd ≈ 30 % du butin. À 50 %, courir reste payant (pilier : l'arme, c'est le Survivant). En cas de refus, le ramassage tombe à ≈ 70 % et tous les prix de l'Établi passent à × 0,82 dans le Catalogue.
2. **Puits cosmétique.** Une fois l'arbre terminé (≈ 45 h), des teintes d'Alcôve de 500 à 2 000 gemmes, prises dans la palette de `Charte`. Rien n'est codé sans ton accord. À défaut, on ajoute des niveaux de recherche par mise à jour.
3. **Pour information :** le nombre de Zbires par jour est multiplié par (1 + 0,2 × (actifs − 1)). Le canon ne fixe que les PV : aucun écart.

### 📈 Designer progression — Aya Kessler (révisé)
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

### 🎯 Designer mécaniques — Nathan Brivel (révisé)
## 1. Déplacement et caméra (3C)

Valeurs publiées dans `ReplicatedStorage.Config.Mouvement` (§8). **`GardienMouvement` (a29) est le seul script qui écrit `WalkSpeed`, `JumpHeight` et les états du `Humanoid`.** Le combat, la réparation et le Répit n'écrivent qu'un état dans `StatsSurvivant`. Le Gardien en déduit la vitesse, avec cette priorité : étourdi > réparation > Répit > horde.

| Réglage | Laboratoire | Prairie | Dans Roblox Studio |
|---|---|---|---|
| Vitesse | 16 | 18 en horde, 24 au Répit, 8 en réparation, 0 étourdi | `StarterPlayer.CharacterWalkSpeed` 16 / 18 ; le reste est appliqué par le Gardien |
| Saut | 7,2 studs | 0 (profil A) ou 5 (profil B, A/B de H2) | `CharacterUseJumpPower = false`, `CharacterJumpHeight` 7,2 / 0 ; en profil A, le Gardien désactive aussi `HumanoidStateType.Jumping` |
| Orientation | `AutoRotate = true` | face à la cible | `Humanoid.AutoRotate = false` ; le client tourne le `HumanoidRootPart` (lissage 0,08 s) |
| Mort | impossible | impossible | `BreakJointsOnDeath = false`, `SetStateEnabled(Enum.HumanoidStateType.Dead, false)` |
| Stick mobile | dynamique | dynamique | `DevTouchMovementMode = DynamicThumbstick` |
| Caméra | `Classic` | `Scriptable`, (0, 45, 28), `FieldOfView` 50 | `BindToRenderStep` à `Enum.RenderPriority.Camera.Value + 1`, lissage `1 - math.exp(-12 * dt)` |

- **A/B de H2 :** un profil par serveur réservé, jamais par joueur. Le serveur de la Prairie le tire à son démarrage (parité d'un hachage de `game.PrivateServerId`) et le journalise. Quand `JumpHeight = 0`, le bouton Saut tactile de Roblox disparaît de lui-même. Le profil gagnant est soumis à Victor Lanoue.
- **Repères à 18 studs/s :** de la Maison à la Lisière (70 studs) en 3,9 s ; le tour de la Maison à 2 studs des murs (80 studs) en 4,4 s. Aucun obstacle n'oblige à sauter, car les défenses se traversent (§6).
- **Ni sprint ni roulade :** c'est un bouton de moins sur téléphone. Le passage à 24 studs/s au Répit crée le « rush » vers l'Établi.
- **Champ visible (16:9) :** 41 studs devant, 22 derrière, 44 de chaque côté. Des chevrons au bord de l'écran signalent le hors-champ : violets pour un groupe de 3 Zbires ou plus à moins de 30 studs de la Maison, couleur Alerte pour le Colosse.
- **Écart soumis à Victor Lanoue :** tant que le Colosse est sur la Prairie, la caméra passe en 1 s à (0, 52, 32), puis revient à (0, 45, 28). Sans son accord, elle reste à (0, 45, 28).

## 2. Tir : le Blaster

| Statistique | Base | Par niveau | Plafond proposé |
|---|---|---|---|
| Dégâts | 10 | +2,5 (Établi) | 30 (niv. 8) |
| Cadence | 4 tirs/s | +0,4 (Établi) | 6 tirs/s (niv. 5) |
| Portée | 40 studs | +3 (Établi) | 52 studs (niv. 4) |
| Critique | 5 %, dégâts × 2 | +4 % (Visée critique) | 25 % |
| Balles explosives | — | 1 tir sur 4, puis 1 sur 3, puis 1 sur 2 | rayon 6 studs, 50 % des dégâts |
| Balles perforantes | — | +1 Zbire traversé, à 70 % des dégâts | 3 Zbires |

- **Autorité serveur :** le client envoie `DemandeTir(zbireId)`. Le serveur vérifie la cible, la distance horizontale (portée + 4 studs de tolérance réseau), la cadence (90 % de l'intervalle) et l'état : pas de tir si le Survivant est étourdi ou en train de réparer. Le projectile est cosmétique : cube Crème de 0,5 stud, 120 studs/s, pool de 40 par client, en `SmoothPlastic` pour ménager le quota de `Neon`.
- **Casqué :** il ne prend que la moitié des dégâts, sauf sur un critique. Le critique fait sauter son casque (effet visuel seul).
- **Tir automatique sur toutes les plateformes, activé par défaut :** il vise le Zbire *visible à l'écran* le plus proche dans le rayon. La cible change au plus toutes les 0,4 s, et un anneau orange au sol la marque.
- **Écart soumis à Victor Lanoue :** je propose que le rayon du tir auto suive la Portée (de 40 à 52 studs), sinon l'amélioration ne sert à rien sur téléphone. Sans son accord, le rayon reste fixé à 40 studs.

| Événement | Visuel | Son (chiptune) |
|---|---|---|
| Tir | flash Crème de 0,05 s, recul du Blaster (écrasement × 0,8 en 0,15 s) | « pew », pitch 0,95 à 1,05 ; tirs alliés à volume 0,2 |
| Impact | le Zbire vire au Crème 0,06 s et recule de 0,3 stud | « tic » |
| Critique | chiffre Or « CRIT ! », étirement × 1,2 | « ding » aigu |
| Casqué sans critique | étincelles Ardoise, « ½ » gris | « tonk » métallique |
| Élimination | éclatement en 8 cubes violets (0,6 s) puis pièces | « pop » puis « tling » |
| Explosion | sphère orange translucide de 6 studs pendant 0,2 s | « boum » court |

Chaque joueur ne voit les chiffres de dégâts que pour ses propres tirs (pool de 10 `BillboardGui`). Le `SoundGroup` « Tirs » est plafonné à 6 voix sur les 16 autorisées.

## 3. Étourdissement : on ne meurt jamais

- **Contact (vérifié par le serveur à 10 Hz) :** distance horizontale ≤ rayon du Zbire + 2 studs **et** écart vertical ≤ 4 studs. Un Volant qui passe plus haut n'étourdit pas.
- **Onde du Colosse :** rayon de 12 studs, annoncée 1,2 s avant par un disque Alerte au sol qui se remplit du centre vers le bord.
- **Effet :** pendant 2 s, le Survivant ne peut ni bouger, ni tirer, ni réparer, ni poser. Suivent 2 s d'invulnérabilité : au plus un étourdissement toutes les 4 s. `ServiceCombat.etourdir` n'écrit plus `WalkSpeed`. Il remplit seulement `etourdiJusqua`, `invulnerableJusqua` et `repare = false`, et le Gardien applique la vitesse 0.
- **Recul :** 6 studs à l'opposé de la source, appliqué par le client (`ApplyImpulse` sur le `HumanoidRootPart`), qui possède son personnage sur le réseau.
- **Retour :** 3 étoiles Or tournent au-dessus de la tête, avec un « boing » descendant. Le joueur touché, et lui seul, ressent une secousse caméra de 0,4 stud et une vibration manette (`HapticService:SetMotor`, `Enum.VibrationMotor.Large`, 0,4 pendant 0,15 s). Pendant l'invulnérabilité, il clignote (`Transparency` 0 ↔ 0,5 toutes les 0,1 s).

## 4. Collecte

Les règles et les chiffres viennent de `ReplicatedStorage.Partage` (a07, Mine commune de a06). Je retire mon stock de 10 gemmes, ma cadence de 30 s et le rapatriement de 100 % des pièces. Cette section ne fixe que le ressenti.

**Pièces (butin instancié)**
- Chaque Zbire vaincu lâche des pièces pour chaque Survivant : même valeur pour tous, aucun bonus au dernier coup, aucun vol possible. Chaque client ne voit que les siennes.
- 1 à 5 cubes Or de 0,8 stud sont éjectés dans un rayon de 3 studs, avec un rebond élastique.
- **Aimant serveur (8 studs, Partage) :** le client n'envoie rien. Il anime seulement le vol des pièces vers le joueur, en 0,2 s. L'amélioration Butin augmente la valeur, pas le rayon.
- **Début du Répit :** le reliquat crédité par Partage file en ruban vers le joueur (0,6 s). Le compteur affiche alors « +X » en gris, pour le distinguer de l'Or du ramassage à la main : l'enfant voit que courir rapporte plus. Les pièces non créditées rapetissent et s'effacent en 0,3 s, sans son de perte.
- **Retour :** le compteur pulse (× 1,2). Le « tling » monte d'un demi-ton par pièce enchaînée en moins de 0,5 s (+8 au maximum).
- Au-delà du pool client de 60 cubes (a28), 5 pièces fusionnent à l'écran en une grosse pièce. La valeur côté serveur reste exacte.

**Gemmes**
- **Mine commune :** dès qu'un Survivant la touche, le serveur crédite toute l'équipe. Chaque client voit les gemmes jaillir de la Mine vers son propre compteur, sous le `DisplayName` de celui qui l'a touchée : un geste d'équipe, sans chat.
- **Retour :** son « cristal », compteur cyan dans le HUD.

## 5. Réparation

- Possible à 14 studs au plus du centre de la Maison, mesurés à l'horizontale (6 studs devant les murs), sauf pendant un étourdissement. Vitesse de 8 studs/s tant que l'on répare.
- Le client envoie `DemandeReparation(true)`, puis `(false)`. Le serveur compte des tranches de 0,5 s tenues sans interruption et crédite chacune au débit d'équipe de a07 (Partage). Une tranche interrompue (bouton lâché, sortie du rayon, étourdissement) ne rapporte rien. Le cumul illimité par Survivant est supprimé.
- **Retour :** un marteau Crème frappe une fois par tranche (toutes les 0,5 s, en phase avec le serveur), avec 3 étincelles. Un anneau de maintien se remplit sur le bouton. Le « tok » a un pitch qui suit les PV (0,8 à 1,2), et une barre de PV verte s'affiche au-dessus de la porte. La Maison change d'état visuel à 66 % et à 33 %.

## 6. Défenses

| Défense | Taille (studs) | PV | Règle |
|---|---|---|---|
| Muret | 8 × 3 × 2 | 150 × 1,15^(jour − 1) | Arrête les Zbires au sol, qui le frappent. Le Volant le survole et le Sauteur le franchit |
| Mini-Tourelle | 2 × 4 × 2 | 80 × 1,15^(jour − 1) | 50 % des dégâts du Blaster de son poseur (niveau de Dégâts compris, relu à chaque tir), 2 tirs/s, portée 25 studs, vise le Zbire le plus proche de la Maison, jamais de critique |
| Tapis Collant | 8 × 0,2 × 8 | indestructible | Zbires au sol ralentis de 50 %, Colosse de 20 %, Volant non affecté |

Les PV sont relevés au début de chaque jour, en gardant la même proportion. Les prix sont fixés par `Economie` (a07).

- **Collisions :** toutes les défenses sont dans le `CollisionGroup` `Defenses`, rendu non collidable avec `Survivants` (`PhysicsService:CollisionGroupSetCollidable`). Le Muret n'arrête que les Zbires simulés, par une règle du `Registre` et non par la physique : impossible de murer la Maison ou d'enfermer un coéquipier. **Retour :** quand un Survivant traverse un Muret, celui-ci passe à `Transparency` 0,4 pour ce joueur et ondule (× 0,8).
- **Quota de 3 :** la 4e pose est refusée. L'icône `PoseInterdite` s'affiche sur le fantôme avec un « bzzt » doux, et les 3 défenses du joueur clignotent en orange pendant 1 s pour montrer quoi reprendre. Rien n'est détruit. Le bouton Défenses affiche « 3/3 ».
- **Reprise :** maintenir le doigt 0,5 s sur une de ses défenses (un anneau Crème se remplit) envoie `DemandeReprise`. Le serveur vérifie que la défense appartient au joueur, puis `Economie` rend 50 % du prix payé (a07). La défense s'envole vers le Sac à dos en 0,3 s, avec un « +X » Or. *J'ai choisi un maintien de 0,5 s plutôt qu'un simple toucher : ainsi, un tap destiné à un Zbire ne reprend jamais une Mini-Tourelle.*
- **Fantôme :** il se place 6 studs devant le Survivant, dans sa dernière direction de déplacement (et non de visée, car la cible change), sur la grille de 4 studs alignée sur le centre de la Maison. Le Muret s'oriente tout seul tangent à la Maison : le bouton Pivoter disparaît. Le fantôme est orange à `Transparency` 0,5 si la pose est valide ; sinon il passe en couleur Alerte avec l'icône de la raison.
- **Un seul verdict :** le fantôme et le serveur appellent tous deux `Placement.verifier`. Cette fonction combine `Plan.posePermise` (a11 : zones interdites, distance maximale, chevauchement ; je ne fixe plus aucune de ces limites) et le refus de toute emprise qui touche un Survivant.
- La pose prend 0,5 s, avec une recharge de 3 s. Le serveur recalcule la cellule et l'orientation, puis revérifie le solde et le quota.
- **Retour de pose :** la défense tombe de 4 studs et s'écrase (× 0,8) à l'atterrissage, avec un « clonk » et une bouffée de 6 cubes Terre battue.

## 7. Contrôles

| Action | Mobile | PC | Manette (sur PC) |
|---|---|---|---|
| Se déplacer | stick dynamique | WASD (ZQSD en AZERTY), flèches | stick gauche |
| Sauter (Laboratoire ; Prairie en profil B) | bouton Saut de Roblox | Espace | `ButtonA` |
| Tirer | auto ; taper un Zbire le verrouille 3 s | auto ; clic gauche maintenu = Zbire le plus proche du curseur (5 studs) | auto ; stick droit (cône de 15°) + `ButtonR2` |
| Réparer | bouton contextuel maintenu | E maintenu | `ButtonX` maintenu |
| Défenses | bouton Défenses → 3 icônes → « Poser » ou « X » | 1 / 2 / 3, clic gauche pour poser, Échap pour annuler | croix gauche/haut/droite, `ButtonR2` pour poser, `ButtonB` pour annuler |
| Reprendre | maintien de 0,5 s sur sa défense | survol + R maintenu 0,5 s | `ButtonB` maintenu 0,5 s à moins de 8 studs, hors mode pose |
| Établi (< 8 studs) | bouton contextuel | F | `ButtonY` |
| Roue des Pings | bouton, puis glisser vers le secteur | G maintenu + souris | `ButtonL1` maintenu + stick droit |

- Les tailles, positions et espacements suivent la **maquette unique codée par a28** (60 px minimum, selon le canon). Mes tailles de boutons sont retirées.
- Les actions sont liées par `ContextActionService:BindAction` avec `createTouchButton = false` : les boutons tactiles sont les `ImageButton` de a28.
- **Roue des Pings :** « Colosse ! » (Alerte), « Répare ! » (Crème, marqueur sur la Maison), « Ici ! » (orange, aux pieds du joueur), « Merci ! » (Or, au-dessus de la tête). Chaque ping affiche un marqueur `BillboardGui` `AlwaysOnTop` pendant 6 s, avec un jingle de 3 notes. Anti-spam serveur : 3 pings en 5 s, puis 5 s de recharge.

## 8. Code

```lua
-- ReplicatedStorage.Config.Mouvement (ModuleScript)
-- Lu par GardienMouvement (a29), seul script qui écrit WalkSpeed et JumpHeight.
export type EtatSurvivant = { etourdi: boolean, repare: boolean, repit: boolean }

local Mouvement = {
	Laboratoire = table.freeze({ WalkSpeed = 16, UseJumpPower = false, JumpHeight = 7.2 }),
	Prairie = table.freeze({
		WalkSpeedHorde = 18,
		WalkSpeedRepit = 24,
		WalkSpeedReparation = 8,
		WalkSpeedEtourdi = 0,
		UseJumpPower = false,
		JumpHeight = 0, -- StarterPlayer.CharacterJumpHeight de la place Prairie
	}),
	-- A/B de H2 : un profil par serveur réservé, jamais par joueur
	ProfilsH2 = table.freeze({
		A = table.freeze({ JumpHeight = 0 }),
		B = table.freeze({ JumpHeight = 5 }),
	}),
}

-- Priorité : étourdi > réparation > Répit > horde
function Mouvement.vitessePrairie(etat: EtatSurvivant): number
	local p = Mouvement.Prairie
	if etat.etourdi then
		return p.WalkSpeedEtourdi
	elseif etat.repare then
		return p.WalkSpeedReparation
	elseif etat.repit then
		return p.WalkSpeedRepit
	end
	return p.WalkSpeedHorde
end

function Mouvement.sautPrairie(profil: string?): number
	local choix = Mouvement.ProfilsH2[profil or "A"] or Mouvement.ProfilsH2.A
	return choix.JumpHeight
end

return table.freeze(Mouvement)
```

```lua
-- ReplicatedStorage.Defenses.Placement (ModuleScript) : même code pour le fantôme et le serveur
local Players = game:GetService("Players")
local Plan = require(game:GetService("ReplicatedStorage").Plan) -- a11

local GRILLE, AVANCE = 4, 6
local Placement = {}
Placement.TAILLES = table.freeze({
	Muret = Vector3.new(8, 3, 2),
	MiniTourelle = Vector3.new(2, 4, 2),
	TapisCollant = Vector3.new(8, 0.2, 8),
})

-- Point visé : 6 studs devant, dans la dernière direction de déplacement
function Placement.devant(racine: Vector3, direction: Vector3): Vector3
	local plat = direction * Vector3.new(1, 0, 1)
	return racine + (if plat.Magnitude > 1e-3 then plat.Unit else Vector3.zAxis) * AVANCE
end

-- Cellule de la grille centrée sur la Maison ; LookVector vers l'extérieur, donc l'axe X (8 studs) du Muret est tangent
function Placement.cadre(position: Vector3): CFrame
	local centre = Plan.CENTRE_MAISON -- au niveau du sol
	local rel = position - centre
	local radial = Vector3.new(math.round(rel.X / GRILLE) * GRILLE, 0, math.round(rel.Z / GRILLE) * GRILLE)
	local p = centre + radial
	return if radial.Magnitude > 0 then CFrame.lookAt(p, p + radial) else CFrame.new(p)
end

function Placement.verifier(typeDefense: string, cadre: CFrame): (boolean, string?)
	local taille = Placement.TAILLES[typeDefense]
	if not taille then
		return false, "PoseInterdite"
	end
	local ok, raison = Plan.posePermise(typeDefense, cadre)
	if not ok then
		return false, raison
	end
	local persos = {}
	for _, joueur in Players:GetPlayers() do
		if joueur.Character then
			table.insert(persos, joueur.Character)
		end
	end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = persos
	local boite = Vector3.new(taille.X, 6, taille.Z)
	if #workspace:GetPartBoundsInBox(cadre + Vector3.new(0, 3, 0), boite, params) > 0 then
		return false, "SurvivantDessous"
	end
	return true, nil
end

return table.freeze(Placement)
```

```lua
-- ServerScriptService.Defenses.ServiceDefenses (ModuleScript, démarré par le Script de run)
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Placement = require(ReplicatedStorage.Defenses.Placement)
local Economie = require(ServerScriptService.Run.Economie) -- a07 : prix, débit, 50 % rendus
local Stats = require(ServerScriptService.Run.StatsSurvivant)
local Remotes = ReplicatedStorage.Remotes

local QUOTA, RECHARGE, TOLERANCE = 3, 3, 12 -- tolérance : 6 d'avance + 1 case + latence
local PV_BASE = { Muret = 150, MiniTourelle = 80 }
type Pose = { modele: Model, prix: number }
local poses: { [Player]: { Pose } } = {}
local dernierePose: { [Player]: number } = {}

local function grouper(racine: Instance, nom: string)
	for _, d in racine:GetDescendants() do
		if d:IsA("BasePart") then
			d.CollisionGroup = nom
		end
	end
end

local function retirer(liste: { Pose }, modele: Instance): Pose?
	for i, pose in liste do
		if pose.modele == modele then
			return table.remove(liste, i)
		end
	end
	return nil
end

local function surDemandePose(joueur: Player, typeDefense: unknown, position: unknown)
	if typeof(typeDefense) ~= "string" or typeof(position) ~= "Vector3" then return end
	local s, liste, t = Stats.obtenir(joueur), poses[joueur], os.clock()
	local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not s or not liste or not racine or t < s.etourdiJusqua then return end
	if t - (dernierePose[joueur] or 0) < RECHARGE then return end
	if #liste >= QUOTA then
		Remotes.PoseRefusee:FireClient(joueur, "PoseInterdite") -- rien n'est détruit
		return
	end
	local cadre = Placement.cadre(position)
	if ((cadre.Position - racine.Position) * Vector3.new(1, 0, 1)).Magnitude > TOLERANCE then return end
	local ok, raison = Placement.verifier(typeDefense, cadre)
	if not ok then
		Remotes.PoseRefusee:FireClient(joueur, raison)
		return
	end
	local prix = Economie.prixDefense(typeDefense)
	if not Economie.debiter(joueur, prix) then
		Remotes.PoseRefusee:FireClient(joueur, "SoldeInsuffisant")
		return
	end
	dernierePose[joueur] = t
	local modele = ServerStorage.Defenses[typeDefense]:Clone() :: Model
	modele:PivotTo(cadre)
	grouper(modele, "Defenses")
	modele:SetAttribute("Proprietaire", joueur.UserId)
	local base = PV_BASE[typeDefense]
	if base then
		modele:SetAttribute("PVMax", base * 1.15 ^ ((workspace:GetAttribute("Jour") or 1) - 1))
	end
	modele.Destroying:Once(function()
		retirer(liste, modele) -- Muret détruit par les Zbires : la place se libère
	end)
	table.insert(liste, { modele = modele, prix = prix })
	modele.Parent = workspace.Defenses
end

local function surDemandeReprise(joueur: Player, modele: unknown)
	local liste = poses[joueur]
	if not liste or typeof(modele) ~= "Instance" then return end
	local pose = retirer(liste, modele) -- nil si ce n'est pas l'une de ses défenses
	if not pose then return end
	local rendu = Economie.reprendreDefense(joueur, pose.prix) -- 50 % du prix payé (a07)
	Remotes.DefenseReprise:FireAllClients(joueur, pose.modele:GetPivot(), rendu)
	pose.modele:Destroy()
end

local ServiceDefenses = {}

function ServiceDefenses.demarrer()
	for _, nom in { "Survivants", "Defenses" } do
		if not PhysicsService:IsCollisionGroupRegistered(nom) then
			PhysicsService:RegisterCollisionGroup(nom)
		end
	end
	PhysicsService:CollisionGroupSetCollidable("Survivants", "Defenses", false)

	local function marquer(perso: Model)
		grouper(perso, "Survivants")
		perso.DescendantAdded:Connect(function(d)
			if d:IsA("BasePart") then
				d.CollisionGroup = "Survivants"
			end
		end)
	end
	local function suivre(joueur: Player)
		poses[joueur] = {}
		if joueur.Character then
			marquer(joueur.Character)
		end
		joueur.CharacterAdded:Connect(marquer)
	end
	Players.PlayerAdded:Connect(suivre)
	for _, joueur in Players:GetPlayers() do
		suivre(joueur)
	end
	Players.PlayerRemoving:Connect(function(joueur)
		local liste = poses[joueur] or {}
		poses[joueur], dernierePose[joueur] = nil, nil
		for _, pose in table.clone(liste) do
			pose.modele:Destroy()
		end
	end)
	Remotes.DemandePose.OnServerEvent:Connect(surDemandePose)
	Remotes.DemandeReprise.OnServerEvent:Connect(surDemandeReprise)
end

return ServiceDefenses
```

### 🚪 Designer onboarding — Clara Osmont (révisé)
## Principes de l'accueil

- **L'accueil** court du premier spawn jusqu'à l'étape **PremiereRecherche**. Le serveur lit deux champs du profil, écrits par `Donnees.Modifier` : `RunsTerminees` (fin de run, a06) et `AccueilEtape` (module Onboarding).
  - `RunsTerminees == 0` : **novice de run**. Il a droit à l'ouverture scriptée et aux indices de la Prairie.
  - `AccueilEtape` < PremiereRecherche : `Player.AccueilActif` vaut true, et a33 n'affiche **aucune carte d'arrivée**.
- **3 gestes en 90 s : bouger, ramasser, acheter.** Le tir est automatique (40 studs). On apprend à réparer, poser un Muret et pinguer au premier besoin.
- **Zéro mot** : pictogrammes, couleurs de `ReplicatedStorage.Charte`, sons 8-bit. Les chiffres restent permis.
- **Caméras** : au Laboratoire, `Custom` pour tous (arbitrage a11, **à valider par Victor Lanoue**) ; les dalles et l'hologramme de Doc Boulon guident. Sur la Prairie, caméra de run : `Scriptable`, (0, 45, 28), `FieldOfView` 50.
- **Écran de la Prairie** (téléphone en paysage) : bord haut ≈ 41 studs devant le Survivant, bord bas ≈ 22 derrière, côtés ≈ 44-49. Depuis le Parvis, la Maison masque le chemin Nord et le Sud tombe sous le bord bas. Les premiers Zbires viennent donc **par l'Est, puis par l'Ouest**.

## Les 90 premières secondes

T = apparition au Laboratoire. A = atterrissage (≈ T 28, T 30 au pire). H = A + 20 : début de la horde du Jour 1 (a06). Le Marcheur avance à 8 studs/s et tombe en 3 tirs. Avec la cadence de `ReplicatedStorage.Partage.BlasterStats` (4 tirs/s), il éclate 0,5 s après être entré dans l'anneau.

| T | Ce que vit le novice | Mise en œuvre |
|---|---|---|
| 0 | Il apparaît sur `SpawnNovice`, face à la Capsule Normale, à 12 studs. L'hologramme cyan de Doc Boulon salue, une bulle montre le picto « Capsule », jingle de 1 s | `CharacterAutoLoads` = false. `Onboarding.enregistrer` règle `RespawnLocation`, puis le chargeur appelle `LoadCharacter()` |
| 1-5 | 6 dalles cyan s'allument en cascade jusqu'à la porte. S'il est immobile à T 3 : joystick fantôme | Parts `Neon` 4 × 0,2 × 4, `Transparency` 1 par défaut, décalage de 0,15 s |
| 5-20 | Il monte, la porte se ferme en élastique. 15 LED s'éteignent ; l'écran boucle 3 pictos de 4 s : courir ; un Zbire entre dans le cercle et éclate en pièces ; pièces → Établi → Blaster plus gros | `MonteeCapsule`. `SurfaceGui`. S'il n'est pas monté à T 15 : Doc Boulon pointe, dalles 2 × plus lumineuses |
| 20-28 | Secousse de 0,5 s (0,3 stud au plus), tunnel cyan | `TeleportService:SetTeleportGui`, repris dans le `ReplicatedFirst` de la Prairie jusqu'à `game:IsLoaded()`. 10 s au plus sur Android 3 Go |
| A | La Capsule se pose sur le SpawnLocation du Parvis (Plan v1 : (−3 ; 0,5 ; 16)) et redécolle (règle des 6 studs). La Maison est en haut de l'écran, l'Établi à 9 studs à gauche. À A+1, un anneau crème de 40 studs montre la portée. À A+3, joystick fantôme s'il est immobile depuis 2 s | `ArriveePrairie`. Le HUD affiche la phase Arrivée (a06) |
| A+17 | Le portail Est (x = +72) s'illumine ; chevron violet au bord droit, « bloup » | Client |
| H+3 ≈ T 51 | Le Marcheur 1, réservé, sort du portail Est | `Onboarding.OUVERTURE`, `Onboarding.reserver` |
| H+8 ≈ T 56 | Il entre dans l'anneau vers x = +34 : réticule, 3 tirs. **Il éclate en cubes violets et lâche 2 Pièces : première récompense avant T 60** (T 58 au pire) | Serveur → `PremierZbire` |
| H+8-27 | Les Pièces rebondissent puis, à 8 studs, volent vers le compteur (× 1,2), avec un « ding » qui monte d'un demi-ton. Les Marcheurs 2 à 6 viennent de l'Est, les Marcheurs 7 à 13 de l'Ouest : les chevrons de gauche ramènent le novice près de l'Établi | `PlaybackSpeed` × 1,06 par pièce |
| ≈ T 79 | 25e Pièce (13e Marcheur) : balise or sur l'Établi, flèche or au bord de l'écran s'il est hors champ | Serveur : `solde >= Economie.prixEtabli('Degats', 1)` |
| ≈ T 81 | À 10 studs de l'Établi (`Plan.ETABLI`, (−12 ; 14)), un panneau s'ouvre en bas de l'écran, main or sur la carte Dégâts. Après l'achat : Blaster × 1,2, balles × 1,3, fanfare de 1,5 s, l'anneau s'efface en 3 s | L'Établi vérifie le solde et la distance → `PremierAchatEtabli` |

Le Jour 1 continue jusqu'à H+80, puis vient le Répit. Le 13e Marcheur part à H+27, et non à H+30, pour que l'achat tombe vers T 80. En groupe, les 11 Marcheurs non réservés se partagent : l'achat peut glisser après T 90, et la balise attend simplement le solde.

**Écart soumis à Victor Lanoue** : les 2 Marcheurs `ReservePour` échappent au multiplicateur coopératif de PV. Ni les Mini-Tourelles, ni la Tourelle de toit, ni les autres Survivants ne les visent. S'ils ne sont pas éliminés 20 s après leur apparition, l'attribut tombe : la Maison n'est jamais sacrifiée.

## Indices sans texte

| Indice | Message | Disparaît |
|---|---|---|
| Dalles cyan en cascade (Quai, puis Voie d'arrivée → pupitre) | « Va là. » | À la montée ; à la 1re recherche |
| Hologramme de Doc Boulon, bulle picto | « C'est ici. » | Au départ ; à la 1re recherche |
| Joystick fantôme (main de 80 px, aller-retour en 0,8 s) | « Glisse ton pouce. » | Au premier `MoveDirection` non nul |
| Anneau crème, `Transparency` 0,6 | « Ta portée. » | Au premier achat, ou à H+45 |
| Chevron violet de 60 px au bord de l'écran | « Un Zbire arrive par là. » | Jamais (visible par tous) |
| Réticule crème 3 × 3, 90° par seconde ; Pièces qui rebondissent (0,6 s) | « Je tire. » ; « Ramasse. » | Jamais |
| Balise et flèche or de l'Établi | « Dépense ici. » | Au premier achat |
| Main or de 72 px sur l'élément nommé par `AccueilCible` | « Celle-là. » | Au premier achat ; à la 1re recherche |

**Après les 90 s**, un seul indice à la fois :
- **Maison touchée** (seulement après le premier achat) : icône clé au-dessus de la façade, le bouton Réparer (96 px) pulse.
- **Premier Répit** : fantôme de Muret au sol, **le bouton Muret pulse**.
- **Premier Colosse** : **le bouton Ping pulse 2 s avec l'icône `PingColosse`**. La Roue des Pings ne s'ouvre jamais seule, et le ping « Colosse ! » part déjà automatiquement (a14).
- **Chaque étourdissement** : 3 étoiles or tournent pendant 2 s (Combat), pour montrer qu'on ne meurt jamais.

## Retour au Laboratoire : jusqu'à PremiereRecherche

1. Le joueur arrive sur la Voie d'arrivée (0, −55). `AccueilActif` vaut true : aucune carte d'arrivée de a33.
2. 10 dalles cyan s'allument en cascade jusqu'au pupitre de l'Arbre des Recherches et restent allumées. L'hologramme de Doc Boulon attend au pupitre et pointe l'arbre.
3. Dans l'arbre, seul le nœud Tourelle de toit est allumé, et la main or le pointe (`AccueilCible` = "TourelleDeToit").
4. Une fois la recherche validée par le serveur → `PremiereRecherche`. Dalles et hologramme s'éteignent, la machine apparaît dans l'Alcôve, puis les dalles du Quai guident 10 s vers la Capsule Normale. Les cartes de a33 reviennent à l'arrivée suivante.

Condition : la Tourelle de toit doit coûter moins que les gemmes d'une première run perdue au Jour 1 (a07).

## Accessibilité

- Chaque couleur a sa forme : pièce = disque, gemme = losange, danger = triangle, ennemi = contour violet.
- Chaque son a un équivalent visuel, car beaucoup d'enfants jouent téléphone en silencieux.
- Un seul bouton contextuel de 96 px à la fois, sous le pouce droit. Partout ailleurs, 60 px minimum.
- 3 flashs par seconde au maximum (pulse de 0,5 s) ; les secousses ne dépassent pas 0,3 stud.

## Serveur : module `Onboarding`

`ServerScriptService.Onboarding` est commun au Laboratoire et à la Prairie. Il n'accorde rien et n'appelle jamais `AnalyticsService` : ses jalons portent les noms de l'entonnoir de a50, et c'est `Telemetrie` qui les numérote.

```lua
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Donnees = require(ServerScriptService:WaitForChild("Donnees"))
local Telemetrie = require(ServerScriptService:WaitForChild("Telemetrie"))
local Economie = require(ReplicatedStorage:WaitForChild("Partage"):WaitForChild("Economie"))
local IndiceOnboarding = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("IndiceOnboarding") :: RemoteEvent

local PRIX_PREMIER_ACHAT: number = Economie.prixEtabli("Degats", 1) -- 25 Pièces (a07)
local DELAI_RESERVE = 20 -- s, puis le Marcheur redevient une cible pour tous
local PARCOURS = { "Laboratoire", "MonteeCapsule", "ArriveePrairie", "PremierZbire",
	"PremierAchatEtabli", "FinJour1", "PremiereRecherche" } -- étapes a50
local RANG: { [string]: number } = {}
for i, nom in PARCOURS do RANG[nom] = i end
local FIN = RANG.PremiereRecherche

type Profil = { RunsTerminees: number, AccueilEtape: number? }
type Etat = { runs: number, rang: number, vus: { [string]: boolean } }

local Onboarding = {}
local suivis: { [Player]: Etat } = {}
local tour = 0

-- t = secondes après H (début de la horde du Jour 1), joué par le Directeur si aDesNovices()
Onboarding.OUVERTURE = table.freeze({
	{ t = 3, chemin = "Est", reserve = true }, { t = 5, chemin = "Est", reserve = true },
	{ t = 7, chemin = "Est" }, { t = 9, chemin = "Est" }, { t = 11, chemin = "Est" }, { t = 13, chemin = "Est" },
	{ t = 15, chemin = "Ouest" }, { t = 17, chemin = "Ouest" }, { t = 19, chemin = "Ouest" },
	{ t = 21, chemin = "Ouest" }, { t = 23, chemin = "Ouest" }, { t = 25, chemin = "Ouest" },
	{ t = 27, chemin = "Ouest" },
})

local function franchir(joueur: Player, nom: string)
	local etat, rang = suivis[joueur], RANG[nom]
	if not etat or rang <= etat.rang then return end -- une fois, jamais en arrière
	etat.rang = rang
	Donnees.Modifier(joueur, "AccueilEtape", function(ancien: number?): number
		return math.max(ancien or 0, rang)
	end)
	Telemetrie.Etape(joueur, nom)
end

local function novice(joueur: Player): Etat?
	local etat = suivis[joueur]
	return if etat and etat.runs == 0 then etat else nil
end

function Onboarding.enregistrer(joueur: Player, profil: Profil, place: "Laboratoire" | "Prairie")
	local rang = profil.AccueilEtape or 0 -- appelé avant LoadCharacter()
	joueur:SetAttribute("AccueilActif", rang < FIN) -- a33 : aucune carte tant que vrai
	if rang >= FIN then return end
	suivis[joueur] = { runs = profil.RunsTerminees, rang = rang, vus = {} }
	if place == "Prairie" then
		if profil.RunsTerminees > 0 then return end
		franchir(joueur, "ArriveePrairie")
		IndiceOnboarding:FireClient(joueur, "Arrivee")
	elseif profil.RunsTerminees == 0 then
		joueur.RespawnLocation = workspace:FindFirstChild("SpawnNovice") :: SpawnLocation?
		franchir(joueur, "Laboratoire")
		IndiceOnboarding:FireClient(joueur, "Quai")
	else
		joueur:SetAttribute("AccueilCible", "TourelleDeToit")
		IndiceOnboarding:FireClient(joueur, "Recherche")
	end
end

function Onboarding.aDesNovices(): boolean
	for joueur in suivis do
		if novice(joueur) then return true end
	end
	return false
end

function Onboarding.reserver(zbire: Model) -- Directeur, entrées reserve = true
	local ids = {}
	for joueur in suivis do
		if novice(joueur) then table.insert(ids, joueur.UserId) end
	end
	if #ids == 0 then return end
	table.sort(ids)
	tour += 1
	zbire:SetAttribute("ReservePour", ids[(tour - 1) % #ids + 1]) -- à tour de rôle
	task.delay(DELAI_RESERVE, function()
		if zbire.Parent then zbire:SetAttribute("ReservePour", nil) end
	end)
end

function Onboarding.surMontee(joueur: Player) -- Quai : montée validée
	if novice(joueur) then franchir(joueur, "MonteeCapsule") end
end

function Onboarding.surElimination(joueur: Player) -- Combat : élimination validée
	if novice(joueur) then franchir(joueur, "PremierZbire") end
end

function Onboarding.surSolde(joueur: Player, solde: number) -- Économie : après chaque gain
	local etat = novice(joueur)
	if etat and not etat.vus.Etabli and solde >= PRIX_PREMIER_ACHAT then
		etat.vus.Etabli = true
		joueur:SetAttribute("AccueilCible", "Degats")
		IndiceOnboarding:FireClient(joueur, "Etabli")
	end
end

function Onboarding.surAchat(joueur: Player) -- Établi : débit validé
	local etat = novice(joueur)
	if not etat or etat.vus.Achat then return end
	etat.vus.Achat, etat.vus.Etabli = true, true
	franchir(joueur, "PremierAchatEtabli")
	joueur:SetAttribute("AccueilCible", nil)
	IndiceOnboarding:FireClient(joueur, "Fin")
end

function Onboarding.surJourFranchi(jour: number) -- a06
	if jour ~= 1 then return end
	for joueur in suivis do
		if novice(joueur) then franchir(joueur, "FinJour1") end
	end
end

function Onboarding.surEvenementRun(evenement: string) -- a06 : "MaisonTouchee", "Repit", "Colosse"
	for joueur, etat in suivis do
		local pret = evenement ~= "MaisonTouchee" or etat.vus.Achat == true -- la clé attend l'achat
		if etat.runs == 0 and pret and not etat.vus[evenement] then
			etat.vus[evenement] = true
			IndiceOnboarding:FireClient(joueur, evenement)
		end
	end
end

function Onboarding.surRecherche(joueur: Player) -- Recherches : recherche validée et payée
	if not suivis[joueur] then return end
	franchir(joueur, "PremiereRecherche")
	joueur:SetAttribute("AccueilCible", nil)
	joueur:SetAttribute("AccueilActif", false)
	IndiceOnboarding:FireClient(joueur, "FinAccueil")
	suivis[joueur] = nil
end

Players.PlayerRemoving:Connect(function(joueur)
	suivis[joueur] = nil
end)

return Onboarding
```

## Client : `StarterPlayerScripts.IndicesOnboarding`

Ce LocalScript ne fait que de l'affichage. La main or et la flèche hors champ relèvent du HUD.

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Charte = require(ReplicatedStorage:WaitForChild("Charte"))

local joueur = Players.LocalPlayer
local IndiceOnboarding = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("IndiceOnboarding")
local ICONE_PING_COLOSSE = "rbxassetid://0" -- PingColosse, livrée par l'UI
local PORTEE = 40 -- tir automatique (canon)
local anneau, suivi

local function hud(nom)
	local gui = joueur.PlayerGui:FindFirstChild("HUD")
	return gui and gui:FindFirstChild(nom, true)
end

local function dalles(dossier, allumer)
	local liste = workspace:WaitForChild("DallesAccueil"):WaitForChild(dossier):GetChildren()
	table.sort(liste, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)
	for i, dalle in liste do
		task.delay(if allumer then 0.15 * i else 0, function()
			dalle.Transparency = if allumer then 0 else 1
		end)
	end
end

local function joystickFantome()
	local humanoide = (joueur.Character or joueur.CharacterAdded:Wait()):WaitForChild("Humanoid")
	task.wait(2)
	local main = hud("JoystickFantome")
	if not main or humanoide.MoveDirection.Magnitude > 0 then return end
	main.Visible = true
	humanoide:GetPropertyChangedSignal("MoveDirection"):Once(function() main.Visible = false end)
end

local function balise(actif)
	local b = workspace:FindFirstChild("Etabli") and workspace.Etabli:FindFirstChild("Balise")
	for _, objet in (b and b:GetDescendants() or {}) do
		if objet:IsA("ParticleEmitter") or objet:IsA("BillboardGui") then objet.Enabled = actif end
	end
end

local function pulser(nom, duree, icone)
	local bouton = hud(nom)
	if not bouton then return end
	local echelle = bouton:FindFirstChildOfClass("UIScale")
	if not echelle then
		echelle = Instance.new("UIScale")
		echelle.Parent = bouton
	end
	local image = bouton.Icone.Image
	bouton.Icone.Image = icone or image
	local info = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(echelle, info, { Scale = 1.15 })
	tween:Play()
	task.delay(duree, function()
		tween:Cancel()
		echelle.Scale = 1
		bouton.Icone.Image = image
	end)
end

local function effacerAnneau()
	local p = anneau
	if not p then return end
	anneau = nil
	local tween = TweenService:Create(p.Decal, TweenInfo.new(3), { Transparency = 1 })
	tween.Completed:Once(function()
		suivi:Disconnect()
		p:Destroy()
	end)
	tween:Play()
end

local function montrerAnneau()
	local p = Instance.new("Part")
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.Transparency = true, false, false, false, 1
	p.Size = Vector3.new(PORTEE * 2, 0.1, PORTEE * 2)
	local d = Instance.new("Decal")
	d.Face, d.Color3, d.Transparency = Enum.NormalId.Top, Charte.Creme, 0.6
	d.Texture = "rbxassetid://0" -- anneau de 512 px, livré par l'UI
	d.Parent = p
	p.Parent = workspace
	anneau = p
	suivi = RunService.RenderStepped:Connect(function()
		local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
		if racine then p.CFrame = CFrame.new(racine.Position.X, 0.06, racine.Position.Z) end
	end)
	task.delay(65, effacerAnneau) -- A+65 = H+45 au plus tard
end

local ACTIONS = {
	Quai = function() dalles("Quai", true); joystickFantome() end,
	Recherche = function() dalles("Recherches", true) end,
	FinAccueil = function()
		dalles("Recherches", false)
		dalles("Quai", true)
		task.delay(10, dalles, "Quai", false)
	end,
	Arrivee = function() montrerAnneau(); joystickFantome() end,
	Etabli = function() balise(true) end,
	Fin = function() balise(false); effacerAnneau() end,
	MaisonTouchee = function() pulser("Reparer", 4) end,
	Repit = function() pulser("Muret", 4) end,
	Colosse = function() pulser("Ping", 2, ICONE_PING_COLOSSE) end,
}

IndiceOnboarding.OnClientEvent:Connect(function(indice)
	local action = ACTIONS[indice]
	if action then task.spawn(action) end
end)
```

## Les 3 mesures

| Mesure | Source | Cible | Alerte |
|---|---|---|---|
| **Entonnoir d'accueil** | Les 12 étapes de a50 via `Telemetrie`, dont les 7 jalons ci-dessus | Parmi les joueurs arrivés sur la Prairie : ≥ 85 % atteignent PremierZbire (80 % avant T 60), ≥ 65 % PremierAchatEtabli, ≥ 50 % PremiereRecherche | Plus de 10 points perdus entre deux jalons |
| **Taux de 2e run** | Joueurs qui remontent en Capsule dans la même session, après PremiereRecherche (a50) | ≥ 55 % | Sous 45 % : revoir le retour au Laboratoire |
| **Rétention J1 et J7** | Objectifs de a50, nouveaux joueurs, par plateforme | J1 ≥ 22 %, J7 ≥ 8 % | Téléphone 5 points sous le PC : problème de lisibilité mobile |

## 🗺️ Level Design

### 📐 Level designer principal — Bastien Ferro (révisé)
## 1. Règles de la carte

- **Repère :** l'origine est le centre de la Maison, sol à Y 0. **Nord = −Z = haut de l'écran.** La caméra `Scriptable` du canon est fixe et plonge à 58° : on voit environ 41 studs au Nord et 22 au Sud.
- **Source unique :** `ReplicatedStorage.Plan` v1 (§8) donne toutes les coordonnées. Greybox, scripts, audit et fantôme de pose le lisent. Aucune valeur en dur.
- **Hiérarchie :** `Workspace.Arene.{Sol, Decor, Props, Maison, Mine, Etabli, Portails, Defenses}`. `Decor` contient `Vegetation`, `Tramages`, `Meteo` et `POI`.
- **Paliers :**
  - A : sol plat.
  - B : décor de 1,5 stud au plus, avec `CanCollide`, `CanQuery` et `CanTouch` à false.
  - C : tout le reste.
- **Règle des axes :** aucun palier C à moins de 6 studs des 8 axes portail → Maison, tant que les Zbires avancent en ligne droite. `Sol`, `Maison`, `Portails` et `Defenses` sont exemptés.
- **Hauteurs maximales :**
  - 6 studs sous R 60 ;
  - **1 stud de R 45 à R 66 (îlots)** ;
  - 8 studs en Lisière Sud.
  - Les Parts à `Transparency` 1 sont exemptées.

## 2. Plan de la Prairie

```
1 colonne = 5 studs (X −110 → 110), 1 ligne = 10 studs (Z). Nord en haut.
 -90 %%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%
 -80 %%%%%%%%%%^^^^^^^^^^^^G^^^^^^^^^^^^%%%%%%%%%%
 -70 %%%%%%%%^^^^^^^^^^^...#...^^^^^^^^^^^%%%%%%%%
 -60 %%%%%%^^^^^@^^^n...n..#..n...n^^^@^^^^^%%%%%%
 -50 %%%%%^^^^^^^:.........#.........:^^^^^^^%%%%%
 -40 %%%%^^^^^^^...:.......x.......:...^^^^^^^%%%%
 -30 %%%^^^^^^.......:.....#.....:...n...^^V^^^%%%
 -20 %%%^^^^^^...n.....:ooo#ooo:..2....n.^^^^^^%%%
 -10 %%%^^^^^.......1.oo...#...oo.........^^^^^%%%
   0 %%^^^^@#######x######MMM######x#######@^^^^%%
  10 %%%^^^^^........:ooEESS,,,oo.........^^^^^%%%
  20 %%%^^^^^^..:...3...ooo#ooommm4....n.^^^^^^%%%
  30 %%%^^^^@^.............#.:.mmm.......^^^^^^%%%
  40 %%%%^^^^^^^...n.......x..:....n...^^^^^^^%%%%
  50 %%%%%^^^^^^^..........#...:......^^^^^^^%%%%%
  60 %%%%%%^^^^^^^^^..n....#.n.:...^^^^^^^^^%%%%%%
  70 %%%%%%%%^^^^^^^^C^^...#...^^^^^^^^^^^%%%%%%%%
  80 %%%%%%%%%%^^^^^^^^^^^^@^^^^@^^^^^^^%%%%%%%%%%
  90 %%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%
```

Légende :

- **Terrain :** `%` Bord · `^` Lisière (Douve non dessinée) · `.` Prairie · `#` chemin · `:` axe diagonal · `o` Ronde · `,` Parvis.
- **Bâtiments :** `M` Maison · `E` Établi · `S` atterrissage · `m` Mine.
- **Portails :** `G` Grand Portail · `@` portail · `x` Ressort.
- **POI :** `n` Nid du Panier · `C` Colosse endormi · `V` Nid du Volant · `1` à `4` repères de quartier.

## 3. Zones et circulation

| Zone | Emprise et position | Règle |
|---|---|---|
| **La Maison** | 16 × 16 × 14, centre (0, 7, 0) | Porte au Sud, en (0, 0, 8) |
| Parvis | X −16 → 16, Z 8 → 20 | Pose interdite |
| Établi | 6 × 3 × 5, centre (−12, 14) | Achat à 10 studs, vérifié par le serveur |
| Atterrissage | `SpawnLocation` 8 × 1 × 8 en (−3 ; 0,5 ; 16) | À 9,2 studs de l'Établi, soit 0,6 s de course |
| **La Mine** | 12 × 12 × 6, X 20 → 32, Z 20 → 32 | Coiffe invisible (voir sous le tableau) |
| Barrière | 48 Parts de 10 × 24 × 1, à R 72 | Invisible, franchissable seulement par les Zbires (voir sous le tableau) |
| Douve (a18) | R 73 → 77 | 4 ponts de 8 studs sur les chemins, 4 gués en sol plein sur les diagonales |
| **La Lisière** | R 70 → 100 | Couloirs de 12 studs, clairière de Ø 16 à chaque portail |

- **Coiffe de la Mine :** 4 `WedgePart` de 12 × 8 × 6 en pyramide (pente 53°). Elles ont `Transparency` 1, `CanCollide` true et `CanQuery` false. Avec `Humanoid.MaxSlopeAngle` à 45, le Survivant glisse et ne peut pas s'y percher.
- **Barrière :** les Parts ont `CanQuery` false et sont dans le groupe `LimiteSurvivants`, qui ne bloque que `Survivants`. Un voile `ForceField` violet de 12 × 6 marque chacun des 8 couloirs.
- **Chemins :** 4 chemins N, E, S et O de 8 studs de large (R 8 → 80), en Terre battue #C8894F. Des chevrons Crème, tous les 16 studs, pointent vers la Maison.
- **Ronde :** cercle de R 24, 4 studs de large, en #A06E3F. Elle relie le Parvis, l'Établi et la Mine.
- **Sol :** socle Ardoise de 220 × 220, puis 3 disques : Ø 200 en #569B3B, Ø 140 en #6CC24A, Ø 60 en #88C962.
- **Répit :** l'aller-retour entre l'Établi et le point de pose le plus lointain (84 studs) prend 10,6 s, dans les 15 s de Répit.

## 4. Portails et axes

- **Portails :** 8 Models, `Portail_N` à `Portail_NO`, dans `Arene.Portails`. Ils sont tagués `PortailZbire`, portent les attributs `Index` et `Angle`, et sont placés par `Plan.positionPortail(i)`.
- **Grand Portail Nord :** c'est l'index 1, en (0, 0, −80). Le Colosse en sort toujours.
- **Écart SE : 160° au lieu de 155°.** À 155°, l'axe passe à 4,6 studs du coin (20, 32) de la Mine, sous la marge de 6. À 160°, il passe à 7,9 studs.
- **Écart SO : 250° au lieu de 225°.** L'axe à 225° traverse l'Établi imposé (à 2,8 studs). À 250°, avec un Établi de 6 × 3, il passe à 6,6 studs.
- **Marges vérifiées :**

| Élément | Distance à l'axe le plus proche |
|---|---|
| Mine | 7,9 studs |
| Établi | 6,6 studs |
| Gâteau du Pique-nique | 6,4 studs |
| Trois Rochers de a14, déplacés de (−34, −34) à (−33, −14) | 10 studs |
| Autres POI | plus de 13 studs |

## 5. Repères et POI (`Plan.POI`)

| Élément | Position | Rôle |
|---|---|---|
| Toit de la Maison | (0, 0) | Le seul aplat Toit orange. Porte le panneau du Record (voir sous le tableau) |
| Mine | (26, 26) | Le seul cyan : 12 cristaux `Neon` et 1 `PointLight` de `Range` 16 |
| Établi | (−12, 14) | Enseigne en forme de pièce Or de 3 × 3. Un anneau au sol clignote pendant le Répit |
| Grand Portail | (0, −80) | Arche violette de 16 × 18. Passe en Alerte #FF2E63 10 s avant le Colosse (`PointLight` de `Range` 24) |
| 7 autres portails | R 80 | Arches violettes de 10 × 12, `ParticleEmitter.Rate` 8 |
| Repères de quartier | 1 Trois Rochers (−33, −14) · 2 Potager (37, −15) · 3 Pique-nique (−36, 22) · 4 Wagonnet (36, 22) | 6 studs de haut au plus, à R < 45. Ils situent le ping « Ici ! ». Le Verger est supprimé |
| Colosse endormi | Nez en (−29, 0, 72), `CFrame.lookAt(nez, Vector3.zero)` | 8 studs de haut, à 30 studs du portail S. `ProximityPrompt` de `MaxActivationDistance` 8 et `RequiresLineOfSight` false |
| Nid du Volant | (78, 0, −32) | À 32 studs des portails NE et E |
| 12 Nids du Panier (a15) | R 58 → 66, hors chemins | 1 stud de haut |
| Zones d'atterrissage des Ressorts (a12) | 4 zones de 6 × 6 en (0, ±40) et (±40, 0) | Pose interdite |

- **Panneau du Record :** `PanneauRecord` de 12 × 0,2 × 3, sur le pan Sud du toit incliné à 32°. Il porte un `SurfaceGui` (`Face` Top, `PixelsPerStud` 50, `LightInfluence` 0). Le serveur y écrit « Record : Jour X ».
- **Ombre de la Maison :** quand `Plan.estDansOmbreMaison` est vrai, `OmbreMaison` règle `LocalTransparencyModifier` à 0,7 sur les Parts taguées `Occultable`.

## 6. Budget : `ServerStorage.Outillage.Gabarit`

Le Gabarit est un jeu de dossiers vides qui reproduit `Arene`. Chaque dossier porte les attributs `Budget` et `BudgetNeon`. Toute greybox part d'un clone du Gabarit. La racine est plafonnée à 6 500 Parts et 128 Neon statiques.

| Dossier | Parts | Neon | Seul constructeur |
|---|---|---|---|
| Sol (chemins, Douve, barrière) | 300 | 0 | a16 (Douve : a18) |
| Maison · Mine · Etabli · Portails | 360 · 80 · 50 · 160 | 16 · 12 · 6 · 32 | a21/a22 |
| Decor.Vegetation | 2 200 | 16 (Champignons) | a17. a20 fixe les hauteurs et les teintes |
| Decor.Tramages · Meteo · POI | 350 · 150 · 200 | 0 · 0 · 11 (secrets) | a20 · a18 · a11 |
| Props | 1 200 | 0 | a23 |
| Marge | 1 450 | 35 | a11 |
| Dynamique : Defenses · Colosse | 450 · 30 | 18 · 4 | serveur |

- **Pic attendu :** environ 7 900 Parts, soit 6 500 statiques + 360 Zbires + 30 Colosse + 450 défenses + 240 avatars + 300 pools.
- **`PointLight` :** 2 pour la map.
- **Arbres :** a21 et a24 n'en posent plus.

## 7. Laboratoire (`MaxPlayers` 12)

| Élément | Position | Règle |
|---|---|---|
| Hall | Disque de R 52. Plafond : cylindre de 1 × 104 × 104 à Y 40 | Au moins 36 studs libres au-dessus de l'anneau |
| Arbre des Recherches | (0, 0), hologramme de 32 studs | 4 pupitres à R 10 |
| **Doc Boulon** | (0, 16) | — |
| Alcôves | `Alcove_01` à `Alcove_12`, 12 × 10 × 12, pivot au centre, R 43 | Caméra pour a33 : `Plan.LABO.cameraAlcove(k)` |
| **Quai des Capsules** | Z −88 → −58. Capsules en X −24, 0 et 24, à Z −76 | 7 Dalles chantantes de 4 × 4 derrière, à Z −84 |
| `SpawnNovice` | (0 ; 0,5 ; −64) | À 12 studs de la Capsule Normale. Assigné par `Player.RespawnLocation` tant que le joueur n'a fait aucune run |
| Voie d'arrivée · Entrée | (0, −55) · (0 ; 0,5 ; 64) | Retour de run via `TeleportData` (position uniquement) |
| **Galerie des Zbires** | X −100 → −60 | Le Colosse est dans l'axe du passage O |
| Cabine d'Essayage | 12 × 12 réservés, X 12 → 24, Z 58 → 70 | Construite seulement si Victor Lanoue la valide |

- **Sols :** tous tagués `ZoneJouable`.
- **Écart soumis à Victor Lanoue :** caméra `Custom` (`CameraMaxZoomDistance` 30) au Laboratoire. Elle reste sous le plafond.

## 8. Code Luau

```lua
-- ReplicatedStorage.Plan (ModuleScript) v1. Origine = centre de la Maison, Nord = -Z.
local Plan = { VERSION = 1, RACINE = "Arene" }
Plan.HIERARCHIE = { "Sol", "Decor", "Props", "Maison", "Mine", "Etabli", "Portails", "Defenses" }
Plan.MAISON = { centre = Vector3.new(0, 7, 0), taille = Vector3.new(16, 14, 16), porte = Vector3.new(0, 0, 8) }
Plan.MINE = { centre = Vector3.new(26, 3, 26), taille = Vector3.new(12, 6, 12) }
Plan.ETABLI = { centre = Vector3.new(-12, 2.5, 14), taille = Vector3.new(6, 5, 3), rayonAchat = 10 }
Plan.ATTERRISSAGE = CFrame.new(-3, 0.5, 16)
Plan.RAYON_BARRIERE, Plan.RAYON_PORTAIL, Plan.RAYON_POSE, Plan.MARGE_AXE = 72, 80, 66, 6
Plan.RAYON_BAS, Plan.HAUTEUR_MAX, Plan.ILOTS = 60, 6, { rMin = 45, rMax = 66, hauteur = 1 }
Plan.ANGLES_PORTAILS = { 0, 90, 180, 270, 45, 160, 250, 315 } -- sens horaire depuis le Nord
Plan.NOMS_PORTAILS = { "N", "E", "S", "O", "NE", "SE", "SO", "NO" }

function Plan.dossier(nom: string): Instance?
	local racine = workspace:FindFirstChild(Plan.RACINE)
	return racine and racine:FindFirstChild(nom)
end

function Plan.polaire(angle: number, rayon: number): Vector3
	local a = math.rad(angle)
	return Vector3.new(math.sin(a) * rayon, 0, -math.cos(a) * rayon)
end

function Plan.positionPortail(i: number): Vector3
	return Plan.polaire(Plan.ANGLES_PORTAILS[i], Plan.RAYON_PORTAIL)
end

-- Distance d'une emprise (centre, demi-largeurs X et Z) à l'axe portail -> Maison le plus proche
function Plan.distanceAxe(c: Vector3, dx: number, dz: number): number
	local mini = math.huge
	for _, angle in Plan.ANGLES_PORTAILS do
		for r = 8, Plan.RAYON_PORTAIL do
			local p = Plan.polaire(angle, r)
			local ex, ez = math.max(math.abs(p.X - c.X) - dx, 0), math.max(math.abs(p.Z - c.Z) - dz, 0)
			mini = math.min(mini, math.sqrt(ex * ex + ez * ez))
		end
	end
	return mini
end

-- { nom, centre X, centre Z, demi X, demi Z }
Plan.ZONES_SANS_POSE = {
	{ "Maison", 0, 0, 12, 12 }, -- bande de réparation
	{ "Porte", 0, 11, 4, 3 }, -- 6 studs devant la porte
	{ "Parvis", 0, 14, 16, 6 },
	{ "Mine", 26, 26, 10, 10 }, -- Mine + 4 studs
	{ "Ressort", 0, -40, 3, 3 }, { "Ressort", 40, 0, 3, 3 }, { "Ressort", 0, 40, 3, 3 }, { "Ressort", -40, 0, 3, 3 },
}
local EMPRISE = { Muret = 4, MiniTourelle = 1.5, TapisCollant = 3 }

-- Même fonction pour le fantôme client et la validation serveur
function Plan.posePermise(typeDefense: string, cf: CFrame): (boolean, string?)
	local m, p = EMPRISE[typeDefense], cf.Position
	if not m or p.X ~= p.X or p.Z ~= p.Z then return false, "invalide" end
	if Vector2.new(p.X, p.Z).Magnitude + m > Plan.RAYON_POSE then return false, "trop loin" end
	for _, z in Plan.ZONES_SANS_POSE do
		if math.abs(p.X - z[2]) <= z[4] + m and math.abs(p.Z - z[3]) <= z[5] + m then return false, z[1] end
	end
	local defenses = Plan.dossier("Defenses")
	if typeDefense == "MiniTourelle" and defenses then
		for _, d in defenses:GetChildren() do
			if d:IsA("PVInstance") and d:GetAttribute("Type") == "MiniTourelle" then
				local q = d:GetPivot().Position
				if Vector2.new(q.X - p.X, q.Z - p.Z).Magnitude < 8 then return false, "tourelle proche" end
			end
		end
	end
	return true
end

Plan.POI = {
	PiqueNique = Vector3.new(-36, 0, 22),
	TroisRochers = Vector3.new(-33, 0, -14),
	Potager = Vector3.new(37, 0, -15),
	Wagonnet = Vector3.new(36, 0, 22),
	ColosseEndormi = { nez = Vector3.new(-29, 0, 72), prompt = 8 },
	NidVolant = Vector3.new(78, 0, -32),
	Douve = { rMin = 73, rMax = 77, largeurPont = 8 },
	NidsPanier = {},
}
for i, angle in { 15, 30, 60, 75, 110, 135, 170, 202.5, 225, 292.5, 330, 345 } do
	Plan.POI.NidsPanier[i] = Plan.polaire(angle, 58 + (i % 3) * 4) -- R 58 à 66
end

function Plan.estDansOmbreMaison(p: Vector3): boolean
	return math.abs(p.X) <= 11 and p.Z >= -20 and p.Z <= -8
end

Plan.LABO = {
	PLAFOND_Y = 40,
	SPAWN_NOVICE = Vector3.new(0, 0.5, -64),
	VOIE_ARRIVEE = Vector3.new(0, 0.5, -55),
	CAPSULES = { Jour = Vector3.new(-24, 7, -76), Normale = Vector3.new(0, 7, -76), Difficile = Vector3.new(24, 7, -76) },
	CABINE = { centre = Vector3.new(18, 0, 64), taille = Vector3.new(12, 0, 12) },
}

function Plan.LABO.pivotAlcove(k: number): CFrame -- Alcove_01 à Alcove_12
	local pos = Plan.polaire(15 + 30 * (k - 1), 43) + Vector3.new(0, 5, 0)
	return CFrame.lookAt(pos, Vector3.new(0, 5, 0))
end

function Plan.LABO.cameraAlcove(k: number): CFrame -- pour a33
	local pivot = Plan.LABO.pivotAlcove(k)
	return CFrame.lookAt(pivot.Position + pivot.LookVector * 20 + Vector3.new(0, 9, 0), pivot.Position)
end

return Plan
```

```lua
-- Barre de commande de Studio, avant chaque publication
local Plan = require(game.ReplicatedStorage.Plan)
local arene = assert(workspace:FindFirstChild(Plan.RACINE), "Arene manquante : cloner ServerStorage.Outillage.Gabarit")
local EXEMPTS = { Sol = true, Maison = true, Portails = true, Defenses = true }
local fautes = 0
local function faute(modele: string, ...: any)
	fautes += 1
	warn(modele:format(...))
end

local function budget(dossier: Instance)
	local max, maxNeon = dossier:GetAttribute("Budget"), dossier:GetAttribute("BudgetNeon") or 0
	if not max then return faute("%s : attribut Budget manquant", dossier:GetFullName()) end
	local n, neon = 0, 0
	for _, d in dossier:GetDescendants() do
		if d:IsA("BasePart") then
			n += 1
			neon += if d.Material == Enum.Material.Neon then 1 else 0
		end
	end
	if n > max or neon > maxNeon then faute("%s : %d/%d Parts, %d/%d Neon", dossier:GetFullName(), n, max, neon, maxNeon) end
end

budget(arene)
for _, nom in Plan.HIERARCHIE do
	local dossier = arene:FindFirstChild(nom)
	if not dossier then faute("Arene.%s manquant", nom) continue end
	budget(dossier)
	for _, d in dossier:GetDescendants() do
		if d:IsA("Folder") and d:GetAttribute("Budget") then budget(d) end
		if not d:IsA("BasePart") or d.Transparency >= 1 or nom == "Maison" then continue end
		local cf, s = d.CFrame, d.Size / 2
		local function ext(a: Vector3): number
			return math.abs(cf.RightVector:Dot(a)) * s.X + math.abs(cf.UpVector:Dot(a)) * s.Y + math.abs(cf.LookVector:Dot(a)) * s.Z
		end
		local sommet, r = cf.Y + ext(Vector3.yAxis), Vector2.new(cf.X, cf.Z).Magnitude
		local plafond = if r >= Plan.ILOTS.rMin and r <= Plan.ILOTS.rMax then Plan.ILOTS.hauteur
			elseif r < Plan.RAYON_BAS then Plan.HAUTEUR_MAX else math.huge
		if nom ~= "Defenses" and sommet > plafond then faute("%s : %.1f studs à R %.0f", d:GetFullName(), sommet, r) end
		if not EXEMPTS[nom] and (d.CanCollide or sommet > 1.5)
			and Plan.distanceAxe(cf.Position, ext(Vector3.xAxis), ext(Vector3.zAxis)) < Plan.MARGE_AXE then
			faute("%s : palier C à moins de 6 studs d'un axe", d:GetFullName())
		end
	end
end
print(("Audit Plan v%d : %d faute(s)"):format(Plan.VERSION, fautes))
```

### 🧗 Designer obby & parkour — Maëlle Turin
## 1. Mouvement de référence (Laboratoire et Prairie)

Réglages identiques dans les deux places, jamais modifiés en cours de jeu : toutes les cotes de ce document en dépendent.

| Propriété | Valeur |
|---|---|
| `StarterPlayer.CharacterWalkSpeed` | 16 |
| `StarterPlayer.CharacterUseJumpPower` | false |
| `StarterPlayer.CharacterJumpHeight` | 7,2 |
| `Workspace.Gravity` | 196,2 |

Vitesse d'impulsion : √(2 × 196,2 × 7,2) = 53,2 studs/s. Temps de vol à plat : 0,54 s. Portée à plat : 8,7 studs.

**Portées bord à bord** (Δh = hauteur d'arrivée − hauteur de départ, en studs) :

| Δh | Portée théorique | Facile (60 %) | Moyen (75 %) | Expert (92 %) |
|---|---|---|---|---|
| +6 | 6,1 | interdit | interdit | 5,5 |
| +4 | 7,2 | 4 | 5,5 | 6,5 |
| +2 | 8,0 | 4,5 | 6 | 7,5 |
| 0 | 8,7 | 5 | 6,5 | 8 |
| −2 | 9,2 | 5,5 | 7 | 8,5 |
| −4 | 9,7 | 6 | 7 | 9 |

**Règles mobile d'abord**
- Un joystick incliné à moitié donne environ 10 studs/s : un saut obligatoire ne dépasse jamais la colonne « Moyen ». La colonne « Expert » est réservée aux raccourcis.
- Plateforme obligatoire : 3 × 3 studs minimum. Le 2 × 3 est réservé aux raccourcis.
- Les enchaînements restent dans un cône de ±30°. Les virages se font sur un palier de repos d'au moins 6 × 6, au plus tous les 3 sauts.
- Marche franchie sans sauter : 1 stud. Rebord grimpé d'un saut : 5 studs (6 en raccourci).
- Grimpe : `TrussPart` Ardoise #4A4560, 2 studs de large, 12 studs maximum d'un seul tenant.
- Lecture : dessus Crème #F6E7C1, flancs Ardoise, liseré d'appel Toit orange #EF7A2F de 0,5 stud, sur fond Nuit labo #2A3263.
- Ni `KillBrick` ni vide : on ne meurt jamais, lobby compris (pilier 2).

## 2. Le Laboratoire : la Tuyauterie de Doc Boulon

C'est un parcours facultatif d'environ 180 studs, qui s'enroule au-dessus de l'anneau des 12 Alcôves, de Y 0 à Y 28. En grimpant, on voit d'en haut les machines de recherche de tous les joueurs (pilier 3). Aucun saut n'est obligatoire pour aller du spawn aux Alcôves, à Doc Boulon ou au Quai des Capsules.

### Sections et courbe de difficulté

| Section | Y | Sauts | Écarts | Δh | Supports | Élément signature | Réussite visée au 1er essai |
|---|---|---|---|---|---|---|---|
| A. Les Paillasses (CP0 → CP1) | 0 → 10 | 7 | 4 → 5 (4,5 max en montée) | +1 / +2 | 6 × 6 puis 4 × 4 | `TrussPart` de 4 studs (apprend la grimpe) | 95 % |
| B. Les Tuyaux (CP1 → CP3) | 10 → 18 | 9 | 5,5 → 6,5 (6 max en montée) | ±2 | tuyaux carrés de 3 de large | 3 Clapets rythmés, puis `TrussPart` de 6 studs | 80 % |
| C. La Couronne des Néons (CP3 → CP5) | 18 → 28 | 8 | 6 → 7 (7 seulement en descente) | ±2 | caissons suspendus 3 × 3 | Ressort final vers la Passerelle de Doc Boulon | 60 % |

- **Clapets** : plateformes 4 × 4 présentes 1,5 s puis absentes 1,5 s. Elles clignotent en Alerte #FF2E63 pendant les 0,4 dernières secondes. Chaque client calcule la phase avec `workspace:GetServerTimeNow() % 3` et bascule `CanCollide` et `Transparency` en local : tout le monde voit le même rythme, sans latence.
- **Ressort final** (Y 18) : un LocalScript pose une `AssemblyLinearVelocity` verticale de 70 studs/s (apogée 12,5 studs). Le joueur se dirige en l'air vers la Passerelle, 10 studs plus haut.
- **Durées cibles** : 75 s au premier essai, 45 s ensuite, 24 s en expert.

### Checkpoints (un toutes les 15 s de jeu au premier essai)

| CP | Emplacement | Y |
|---|---|---|
| CP0 Départ | Pied de la Tuyauterie, à côté de Doc Boulon | 0 |
| CP1 | Fin des Paillasses | 10 |
| CP2 | Après les Clapets | 12 |
| CP3 | Sommet de la grimpe | 18 |
| CP4 | Milieu de la Couronne | 22 |
| CP5 Arrivée | Passerelle de Doc Boulon, face à l'Arbre des Recherches | 28 |

- **Instance** : une Part 6 × 1 × 6 `SmoothPlastic` Ardoise et un anneau `Neon` Gemme cyan #33D6F0, soit 6 Parts `Neon` sur le budget de 150. Tag `Checkpoint`, attribut `Index`.
- **Activation** : l'anneau passe au cyan pour ce joueur seulement (RemoteEvent `ParcoursRetour`), avec un bip chiptune.
- **Filets** : sous chaque support placé à plus de 8 studs du sol, un filet Crème tendu 6 à 8 studs plus bas, tagué `ZoneChute`. Le toucher ramène au dernier checkpoint. Une chute coûte au pire 15 s. Plus bas, le sol du Laboratoire sert de filet.

### Raccourcis experts (aucun ne saute un checkpoint)

| Raccourci | Où | Geste | Gain |
|---|---|---|---|
| R1 « Le Coup de rein » | A, avant CP1 | Rebord de 6 studs grimpé d'un saut | −4 s |
| R2 « Le Coude » | B, avant CP2 | 8 studs à plat depuis une console 2 × 3 | −6 s |
| R3 « La Lampe » | C, entre CP4 et l'Arrivée | 9 studs en Δh −4 depuis CP4 jusqu'à la lampe de Doc Boulon, puis 5 studs à plat vers le Ressort final | −10 s |

### Sortie rapide : la règle des 11 secondes

Une Capsule part 15 s après le premier embarquement. Depuis n'importe quel point de la Tuyauterie, le Quai des Capsules doit être à 11 s au plus :
- Toboggan de l'Arrivée → Quai des Capsules : 4 s.
- Trappes de sortie 4 × 4 à CP2 et CP4, hors de l'aplomb des filets : chute libre jusqu'au sol en moins de 0,6 s.
- Sol → Quai : 112 studs au plus, soit 7 s de marche.

### Revenir chaque jour

- Tableau « Record du Jour » sur la Passerelle : les 10 meilleurs chronos du jour (`OrderedDataStore` daté), remis à zéro chaque nuit.
- Badge « Tuyauterie » au premier passage. Le parcours ne donne aucune gemme : le canon fixe leurs sources, et il n'en fait pas partie.

## 3. Galerie des Zbires et Quai des Capsules

- **Sauteur-trampoline** : la figurine du Sauteur (socle à Y 4) renvoie vers le haut à 60 studs/s (apogée Y 13). Elle donne accès à la mezzanine (Y 10), d'où l'on voit toutes les figurines et leurs variantes.
- **Grimpe du Colosse** : figurine de 24 studs de haut. Son dos est fait de 2 `TrussPart` de 12 studs séparées par un palier d'épaule 4 × 4. La tête est un belvédère 6 × 6 tagué `ZoneBadge`, qui donne le badge « Sur la tête du Colosse ».
- **Quai des Capsules** : sol plat, aucun obstacle, un accès de 10 studs de large devant chacune des 3 Capsules.

## 4. La Prairie : courir vite, lire le terrain

Avec la caméra `Scriptable` décalée de (0, 45, 28), il n'y a pas de plateformes : la traversée se joue sur la fluidité. À 16 studs/s, on va de la Maison à la Haie de Lisière en 4,6 s et on traverse toute la Prairie en 9,2 s.

| Rayon depuis la Maison (studs) | Règle |
|---|---|
| 0 à 20 | Maison et Mine. Sol plat, aucun décor collidable |
| 20 à 45 | Décor de 1 stud maximum en `CanCollide` false (fleurs, nappes de pique-nique) |
| 45 à 66 | Îlots de 3 studs maximum (sautables), espacés de 12 studs minimum, jamais sur un chemin |
| 66 à 74 | Décor de 6 studs maximum, premiers cubes de la Lisière |
| 74 | Haie de Lisière : 5 studs visibles et un mur invisible de 16 studs (collision avec le groupe `Survivants` seulement). Les portails violets restent entre 85 et 95 studs |

- **Chemins en croix** : 8 studs de large, Terre battue #C8894F, aucun décor. Ce sont des repères de direction lisibles depuis la caméra.
- **Relief** : toute la Prairie est à Y 0, sans aucune marche de plus de 1 stud. Sur téléphone, un saut raté en pleine horde est une frustration gratuite.
- **Muret** : 3 studs de haut, pour qu'un Survivant le franchisse d'un saut. La pose est interdite à moins de 6 studs de la porte de la Maison et sur les zones d'atterrissage : personne ne peut enfermer un coéquipier.
- **Ressorts de retour** (raccourci de run) : 4 Parts 4 × 1 × 4 à 58 studs, sur les diagonales. Chacun lance vers le rayon 22 : D = 36 studs et t = 0,75 s, soit 48 studs/s à l'horizontale et 73,6 studs/s à la verticale (apogée 13,8 studs). Recharge : 3 s par joueur. Zone d'atterrissage 6 × 6 laissée libre. Si la Mine tombe sur la diagonale d'un Ressort, on décale ce Ressort de 15°.
- **Colosse** : si son attaque produit une onde au sol, elle fait au plus 1,5 stud de haut et avance au plus à 30 studs/s. Elle reste ainsi sautable (0,54 s en l'air).

## 5. Script serveur du parcours

Tags posés dans Studio : `Checkpoint` (attribut `Index` de 0 à 5), `ZoneChute` (filets), `ZoneBadge` (attribut `BadgeId`). Le client ne fait qu'afficher. Son chrono HUD est indicatif : seul le temps serveur est enregistré.

```lua
-- ServerScriptService/Laboratoire/Parcours.server.lua
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local BadgeService = game:GetService("BadgeService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BADGE_TUYAUTERIE = 0 -- ID du badge publié (0 = désactivé)
local INDEX_ARRIVEE = 5
local CHRONO_MIN = 15 -- s : un chrono plus court est rejeté
local ECART_MIN = 2 -- s minimum entre deux checkpoints

local retour = Instance.new("RemoteEvent")
retour.Name = "ParcoursRetour"
retour.Parent = ReplicatedStorage

type Etat = {
	index: number,
	depart: number?,
	dernier: number,
	reprise: BasePart?,
	badges: { [number]: boolean },
}
local etats: { [Player]: Etat } = {}

local function joueurDe(hit: BasePart): Player?
	local modele = hit:FindFirstAncestorOfClass("Model")
	return if modele then Players:GetPlayerFromCharacter(modele) else nil
end

local function attribuerBadge(joueur: Player, etat: Etat, id: number)
	if id == 0 or etat.badges[id] then return end
	etat.badges[id] = true
	task.spawn(function()
		pcall(BadgeService.AwardBadge, BadgeService, joueur.UserId, id)
	end)
end

local function enregistrerChrono(joueur: Player, duree: number)
	local centiemes = math.floor(duree * 100)
	-- Clé de jour à aligner sur celle du Défi du Jour.
	local store = DataStoreService:GetOrderedDataStore("Tuyauterie_" .. os.date("!%Y%m%d"))
	local ok, err = pcall(store.UpdateAsync, store, tostring(joueur.UserId), function(ancien: number?)
		if ancien and ancien <= centiemes then return nil end
		return centiemes
	end)
	if not ok then warn("[Parcours] chrono non enregistré :", err) end
end

local function surCheckpoint(cp: BasePart, hit: BasePart)
	local joueur = joueurDe(hit)
	local etat = joueur and etats[joueur]
	local index = cp:GetAttribute("Index")
	if not (joueur and etat and typeof(index) == "number") then return end
	local t = os.clock()
	if index == 0 then -- Départ : le chrono part au dernier contact
		etat.index, etat.depart, etat.dernier, etat.reprise = 0, t, t, cp
		return
	end
	local depart = etat.depart
	if index ~= etat.index + 1 or not depart or t - etat.dernier < ECART_MIN then return end
	etat.index, etat.dernier, etat.reprise = index, t, cp
	retour:FireClient(joueur, "Checkpoint", index)
	if index == INDEX_ARRIVEE then
		etat.depart = nil
		local duree = t - depart
		if duree < CHRONO_MIN then return end
		retour:FireClient(joueur, "Arrivee", duree)
		attribuerBadge(joueur, etat, BADGE_TUYAUTERIE)
		task.spawn(enregistrerChrono, joueur, duree)
	end
end

local function surChute(_zone: BasePart, hit: BasePart)
	local joueur = joueurDe(hit)
	local etat = joueur and etats[joueur]
	local perso = joueur and joueur.Character
	if etat and etat.reprise and perso then
		perso:PivotTo(etat.reprise.CFrame + Vector3.new(0, 4, 0))
	end
end

local function surZoneBadge(zone: BasePart, hit: BasePart)
	local joueur = joueurDe(hit)
	local etat = joueur and etats[joueur]
	local id = zone:GetAttribute("BadgeId")
	if joueur and etat and typeof(id) == "number" then
		attribuerBadge(joueur, etat, id)
	end
end

local function lier(tag: string, rappel: (BasePart, BasePart) -> ())
	local function brancher(inst: Instance)
		if inst:IsA("BasePart") then
			inst.Touched:Connect(function(hit) rappel(inst, hit) end)
		end
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(brancher)
	for _, inst in CollectionService:GetTagged(tag) do brancher(inst) end
end

local function initialiser(joueur: Player)
	etats[joueur] = { index = 0, dernier = 0, badges = {} }
end

Players.PlayerAdded:Connect(initialiser)
Players.PlayerRemoving:Connect(function(joueur) etats[joueur] = nil end)
for _, joueur in Players:GetPlayers() do initialiser(joueur) end

lier("Checkpoint", surCheckpoint)
lier("ZoneChute", surChute)
lier("ZoneBadge", surZoneBadge)
```

### 🏰 Designer points d'intérêt — Diego Salcedo
## Règles communes aux 11 POI

- **Repère :** la Maison est au centre (0, 0, 0), le sol à Y = 0 et le Nord vers −Z. Toutes les valeurs sont en studs.
- **Vu d'en haut :** en run, la caméra canon (0, 45, 28), `FieldOfView` 50, montre surtout le dessus des objets. Chaque secret de la Prairie porte donc son signal sur sa face supérieure.
- **Lisibilité :** aucun élément de secret ne dépasse 6 studs de haut à moins de 60 studs de la Maison.
- **Mobile :** on utilise un `ProximityPrompt` (`HoldDuration` 0,4, `MaxActivationDistance` 8, `RequiresLineOfSight` false) ou un simple passage (`Touched` lu par le serveur). Aucun secret ne demande de tir de précision.
- **Récompenses :** l'ensemble des secrets rapporte au plus 50 gemmes par jour et par joueur. Le Défi du Jour reste la grosse prise, à 150. Le reste se gagne en cosmétiques, en badges et en pièces de run. Aucun bonus de combat ne survit à la run.
- **Budget :** 11 Parts `Neon` sur la Prairie, 8 au Laboratoire, aucune `PointLight`, `ParticleEmitter.Rate` ≤ 20.
- **Collection :** dans la Galerie des Zbires, le **Mur des Curiosités** montre 11 cadres gris. Chaque cadre prend ses couleurs quand le joueur trouve le secret : c'est sa carte au trésor.

## Vue d'ensemble

| # | POI | Zone et repère | Récompense | Fréquence |
|---|---|---|---|---|
| 1 | Le Mini-Gluant fugueur | Laboratoire, 1 cache sur 8 | 15 gemmes | 1/jour |
| 2 | L'Atelier secret de Doc Boulon | Bibliothèque derrière l'Arbre des Recherches | Badge + Lunettes de Doc | 1 fois |
| 3 | L'Alcôve 13 | Anneau des Alcôves, entre la 12 et la 1 | Badge « Curieux » + 10 gemmes | 1 par mise à jour |
| 4 | La Capsule Zéro | Bout du Quai des Capsules | Casque de pilote d'essai | 1 fois |
| 5 | Pompon, le chat de la Maison | Paillasson sud (0 ; 0,5 ; 9,5) | Oreilles de Pompon à 50 caresses | 1 caresse par Répit |
| 6 | La Girouette-Zbire | Faîtage de la Maison, sommet à Y = 14 | Annonce le portail du prochain Doré | Permanent |
| 7 | Le Pique-nique abandonné | Prairie sud-est (32, 0, 30) | Butin +50 % jusqu'à la fin du jour | 1/run/joueur |
| 8 | Les Bornes des 4 Vents | Bout des 4 chemins, à 68 studs | 40 pièces + 20 gemmes par joueur | 1/run |
| 9 | Les Dalles chantantes | Entrée de la Mine | 10 gemmes | 1/jour |
| 10 | Le Nid du Volant | Lisière nord-est (55, 0, −55) | 3 × 15 pièces | 1/run/joueur |
| 11 | Le Colosse endormi | Lisière sud-ouest (−62, 0, 62) | Bonnet de nuit du Colosse après 5 runs | 1/run |

## Au Laboratoire

### 1. Le Mini-Gluant fugueur
- **Ce qui attire l'œil :** dans la Galerie, le socle du Mini-Gluant est vide, avec une plaque « ??? ». Trois traces de gelée cyan (`Decal`) filent vers une grille d'aération. La figurine se cache dans l'une des 8 Parts taguées `CacheMiniGluant` : sous le bureau de Doc Boulon, dans un tuyau du Quai, derrière la Capsule du Jour… Le tirage donne la même cache sur tous les serveurs du jour.
- **Indice :** la figurine gigote (écrasement élastique toutes les 4 s) et couine en 8-bit. On l'entend jusqu'à 20 studs (`RollOffMaxDistance` 20).
- **Histoire :** c'est un vrai Mini-Gluant, apprivoisé par Doc Boulon. La preuve que les Zbires ne sont pas méchants.

### 2. L'Atelier secret de Doc Boulon
- **Ce qui attire l'œil :** un seul livre dépasse de la bibliothèque. Son dos est Or et porte le titre « Zbirologie T.1 ». L'action « Tirer le livre » fait glisser la bibliothèque de 8 studs en 1,2 s (`TweenService`, `EasingStyle.Back`) et ouvre une salle de 16 × 12 studs. On y trouve le Tableau noir, qui donne l'ordre du jour des Bornes et les notes des Dalles, une photo de Doc Boulon tenant un bébé Colosse et le premier Blaster, bricolé à partir d'un sèche-cheveux.
- **Indice :** à la fin du tutoriel, Doc Boulon lance : « Et ne touche pas à ma Zbirologie ! »
- **Histoire :** c'est ici que Doc Boulon a compris que les Zbires sont attirés par la Mine.

### 3. L'Alcôve 13
- **Ce qui attire l'œil :** entre l'Alcôve 12 et l'Alcôve 1 se dresse un mur de briques Ardoise fendu. Une lueur cyan filtre par la fente (1 Part `Neon` de 0,2 × 3). L'action « Regarder par la fente » cadre la caméra locale 3 s sur une machine bâchée : la silhouette de la prochaine recherche. La bâche change à chaque mise à jour.
- **Indice :** l'anneau du sol compte 13 dalles numérotées pour 12 Alcôves.
- **Histoire :** c'est l'invention que Doc Boulon n'a pas finie. Chaque mise à jour relance les rumeurs.

### 4. La Capsule Zéro
- **Ce qui attire l'œil :** au bout du Quai, hors des rails, attend une Capsule rouillée (Ardoise, Toit orange délavé) sous un panneau « PROTOTYPE, NE PAS MONTER ». Elle a 6 `Seat` et 6 ampoules `Neon`, qui s'allument une par passager. À 4 passagers, elle tremble 3 s, bondit de 6 studs, lâche des confettis (`Rate` 20 pendant 1 s) puis retombe.
- **Indice :** les ampoules allumées se voient de tout le Quai et attirent les autres joueurs sans passer par le chat.
- **Histoire :** c'est la toute première Capsule. Elle n'a jamais atteint la Prairie.

## Pendant la run

### 5. Pompon, le chat de la Maison
- **Ce qui attire l'œil :** un chat pixel Crème et Toit orange (30 Parts au maximum, 1,5 stud de haut) dort sur le paillasson, face à la caméra. À l'état 3 de la Maison, il file sous le perron. Quand elle tombe, il saute dans la Capsule du retour. L'action « Caresser » n'est active que pendant le Répit : il ronronne et fait jaillir un cœur de particules. Les Zbires l'ignorent et il ne subit jamais de dégâts.
- **Indice :** Pompon est visible dès la première seconde. Le vrai secret, c'est le compteur de caresses.
- **Histoire :** on ne défend pas une maison, on défend Pompon.

### 6. La Girouette-Zbire
- **Ce qui attire l'œil :** une girouette Ardoise en forme de Marcheur grince sur le faîtage, sans dépasser le gabarit canon de la Maison. 5 s avant l'apparition d'un Doré, elle pivote vers son portail (tween de 0,6 s) et son ventre `Neon` Or s'allume.
- **Indice :** un conseil de l'écran de chargement : « Ma girouette ne suit pas le vent… »
- **Histoire :** c'est un gadget de Doc Boulon qui flaire l'or.

### 7. Le Pique-nique abandonné
- **Ce qui attire l'œil :** une nappe de 6 × 6 studs à carreaux Toit orange et Crème, un panier de 1,5 stud et une tarte entamée. L'action « Goûter la tarte » donne le bonus de Butin.
- **Indice :** des miettes (`Decal`) sont semées le long du chemin Sud.
- **Histoire :** une famille pique-niquait ici. Elle a fui la première horde en laissant la Maison… et Pompon.

### 8. Les Bornes des 4 Vents
- **Ce qui attire l'œil :** 4 bornes Crème de 2 × 4 × 2 studs portent chacune un symbole sur le dessus : Soleil, Lune, Éclair ou Cœur. Le symbole est Ardoise quand la borne est éteinte, `Neon` Or quand elle est allumée. Il faut toucher les bornes dans l'ordre du jour en 20 s au plus. Une erreur éteint tout. En solo, le tour prend environ 18 s au pas de course ; à 4, c'est une fête.
- **Indice :** l'ordre est écrit sur le Tableau noir du POI 2. Les joueurs se le transmettront : c'est le secret qui fera parler du jeu.
- **Histoire :** ce sont les restes d'une vieille barrière anti-Zbires, bâtie avant la Maison.

### 9. Les Dalles chantantes
- **Ce qui attire l'œil :** 5 dalles de cristal de 2 × 0,2 × 2 studs, dans les 3 teintes de Gemme cyan. Chacune joue une note quand on marche dessus : Do, Ré, Mi, Sol, La. Si l'on joue les 5 premières notes du jingle de départ des Capsules, la Mine crache une gerbe de gemmes.
- **Indice :** on entend le jingle à chaque départ, et ses notes colorées figurent sur le Tableau noir.
- **Histoire :** la Mine chante, et c'est son chant qui attire les Zbires.

### 10. Le Nid du Volant
- **Ce qui attire l'œil :** un arbre de cubes de 12 studs porte à sa cime un nid garni de 3 pièces géantes : le seul point doré de la canopée vu d'en haut. L'action « Secouer l'arbre », au pied du tronc, fait tomber les 3 pièces, qui éclatent en 15 pièces chacune.
- **Indice :** avant de fondre sur la Maison, les Volants font un crochet par cet arbre.
- **Histoire :** les Volants sont des pies : ils chipent tout ce qui brille.

### 11. Le Colosse endormi
- **Ce qui attire l'œil :** dans une clairière de 20 studs, un Colosse couvert de mousse (Ardoise et Prairie, 20 × 5 × 10 studs) ronfle en 8-bit sous des bulles de sommeil (`Rate` 2). L'action « Chatouiller le nez » le fait éternuer : souffle de particules et secousse de caméra de 0,3 s. Le Jour du Colosse, la clairière est vide.
- **Indice :** après chaque Jour du Colosse, des empreintes géantes (`Decal` de 4 × 6) relient la clairière à la Prairie.
- **Histoire :** le Colosse attaque tous les 5 jours parce qu'il dort les 4 autres.

## Code serveur : `ServerScriptService.Secrets`

Ce script est publié en Package dans les deux places. Chaque bloc ne fait rien si ses instances taguées sont absentes.

```lua
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

-- Équipe Données : get(player) -> profil?, ajouterGemmes(player, n, raison) via UpdateAsync
local Profils = require(ServerScriptService.Donnees.Profils)
local SecretTrouve = ReplicatedStorage.Remotes.SecretTrouve :: RemoteEvent

local PLAFOND_JOUR, VERSION_MAJ = 50, 1 -- incrémenter VERSION_MAJ quand la bâche de l'Alcôve 13 change
local SECRETS = {
	MiniGluant = { gemmes = 15, mode = "jour" },
	Alcove13 = { gemmes = 10, mode = "maj" },
	Dalles = { gemmes = 10, mode = "jour" },
	Bornes = { gemmes = 20, mode = "run" },
}
local faitsIci: { [Player]: { [string]: boolean } } = {}

local function jourUTC(): number
	return os.time() // 86400
end

local function aleaDuJour(sel: number): Random
	return Random.new(jourUTC() * 7919 + sel) -- même tirage sur tous les serveurs
end

local function aPortee(player: Player, cible: BasePart, portee: number): boolean
	local racine = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return racine ~= nil and racine:IsA("BasePart") and (racine.Position - cible.Position).Magnitude <= portee
end

local function reclamer(player: Player, id: string): boolean
	local def, profil, faits = SECRETS[id], Profils.get(player), faitsIci[player]
	if not (def and profil and faits) then return false end
	local s, jour = profil.secrets, jourUTC() -- { trouves = {}, jour = 0, gemmesDuJour = 0 }
	if s.jour ~= jour then s.jour, s.gemmesDuJour = jour, 0 end
	local marque = if def.mode == "jour" then jour elseif def.mode == "maj" then VERSION_MAJ else true
	if def.mode == "run" then
		if faits[id] then return false end
	elseif s.trouves[id] == marque then
		return false
	end
	faits[id], s.trouves[id] = true, marque
	local gain = math.min(def.gemmes, PLAFOND_JOUR - s.gemmesDuJour)
	if gain > 0 then
		s.gemmesDuJour += gain
		Profils.ajouterGemmes(player, gain, "secret:" .. id)
	end
	SecretTrouve:FireClient(player, id, gain)
	return true
end

local function placerMiniGluant()
	local caches = CollectionService:GetTagged("CacheMiniGluant")
	if #caches == 0 then return end
	table.sort(caches, function(a, b) return a.Name < b.Name end)
	local figurine = ServerStorage.Secrets.MiniGluant:Clone() -- Model, PrimaryPart = Corps
	local corps = figurine.PrimaryPart :: BasePart
	local prompt = corps:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
	figurine:PivotTo(caches[aleaDuJour(1):NextInteger(1, #caches)].CFrame)
	figurine.Parent = workspace
	prompt.Triggered:Connect(function(player)
		if aPortee(player, corps, prompt.MaxActivationDistance + 3) then reclamer(player, "MiniGluant") end
	end)
end

local function ordreDesBornes(): { string }
	local ordre, alea = { "Soleil", "Lune", "Eclair", "Coeur" }, aleaDuJour(2)
	for i = #ordre, 2, -1 do
		local j = alea:NextInteger(1, i)
		ordre[i], ordre[j] = ordre[j], ordre[i]
	end
	return ordre
end

local function preparerTableau() -- Laboratoire : SurfaceGui.Case1..4 contient 4 Frames masquées
	local tableau = workspace:FindFirstChild("TableauNoir", true)
	if not tableau then return end
	for rang, symbole in ordreDesBornes() do
		tableau.SurfaceGui["Case" .. rang][symbole].Visible = true
	end
end

local function preparerBornes() -- Prairie
	local bornes = CollectionService:GetTagged("BorneDesVents")
	if #bornes == 0 then return end
	local ordre, etape, essai, gagne = ordreDesBornes(), 0, 0, false
	local function eclairer()
		for _, borne in bornes do
			local rang = table.find(ordre, borne:GetAttribute("Symbole"))
			borne.Symbole.Material = if rang and rang <= etape then Enum.Material.Neon else Enum.Material.SmoothPlastic
		end
	end
	for _, borne in bornes do
		borne.Touched:Connect(function(touche)
			local player = Players:GetPlayerFromCharacter(touche.Parent)
			if gagne or not player or not aPortee(player, borne, 8) then return end
			local symbole = borne:GetAttribute("Symbole")
			if symbole == ordre[etape + 1] then
				if etape == 0 then
					essai += 1
					local ceTour = essai
					task.delay(20, function()
						if ceTour == essai and not gagne then etape = 0; eclairer() end
					end)
				end
				etape += 1
			elseif symbole ~= ordre[etape] then
				etape = 0 -- mauvais ordre : tout s'éteint
			end
			eclairer()
			if etape == 4 then
				gagne = true
				for _, p in Players:GetPlayers() do reclamer(p, "Bornes") end
				local pluie = ServerStorage.Evenements.PluieDePieces :: BindableEvent
				pluie:Fire(40) -- l'économie de run verse 40 pièces à chaque joueur
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(p) faitsIci[p] = {} end)
Players.PlayerRemoving:Connect(function(p) faitsIci[p] = nil end)
for _, p in Players:GetPlayers() do faitsIci[p] = {} end

preparerTableau()
preparerBornes()
placerMiniGluant()
```

Les autres POI suivent le même schéma : `Triggered` ou `Touched`, puis `aPortee`, puis `reclamer` ou un appel à l'économie de run.

**À valider par Victor Lanoue :** les noms Pompon, Capsule Zéro, Alcôve 13 et Mur des Curiosités, et le lore proposé : la Mine chante, et le Colosse dort 4 jours sur 5.

### ⚔️ Designer zones de combat — Olga Brandt
# Zones de tension : la Prairie

*Olga Brandt, Level Design.* Repère commun : la Maison est centrée en (0, 0, 0) et Y pointe vers le haut. **Nord = −Z = haut de l'écran** : la caméra est décalée de (0, 45, 28), donc au sud du Survivant. Les noms d'anneaux et d'îlots ci-dessous servent seulement en interne et ne sont jamais affichés aux joueurs.

## 1. Anneaux de la Prairie

| Anneau | Étendue | Rôle | Règles |
|---|---|---|---|
| Couloir | 4 studs autour des murs (carré 24 × 24) | Réparer | Ni pose ni décor. 6 `SpawnLocation` 4 × 1 × 4 (`Neutral` true, `Duration` 0, `Transparency` 1) : 2 au nord, 2 au sud, 1 à l'est, 1 à l'ouest |
| Pré carré | Du Couloir au rayon 30 | Défense rapprochée, Mine | Poses autorisées, décor ≤ 3 studs sauf la Mine |
| Champ de tir | Rayon 30 → 55 | Zone de tuerie, îlots | Poses jusqu'au rayon 50, décor ≤ 6 studs |
| Bordure | Rayon 55 → 70 | Entrée des paquets | Décor ≤ 1 stud : on voit tout ce qui entre |
| Lisière | Rayon 70 → 100 | 8 portails au rayon 86 | Survivants arrêtés au rayon 74 |

Le tir automatique porte à 40 studs. Depuis le Couloir, un Survivant couvre donc jusqu'au rayon 50 environ. Rester près de la Maison la protège, sortir rapporte les pièces : c'est la tension de base du jeu.

## 2. Trois paliers de hauteur, trois règles

| Palier | Hauteur | Exemples | Zbires bloqués | Tirs |
|---|---|---|---|---|
| A, Enjambable | ≤ 1 stud | nappes à carreaux, fleurs-cubes, Tapis Collant | aucun | passent |
| B, Muret | 3 studs | Muret, bancs, tables, haies de cubes | tous ceux au sol, sauf le Sauteur (bond de 4 studs) | passent |
| C, Rocher | 6 studs | 3 rochers Ardoise, la Mine | tous, sauf le Volant (vol à 8 studs) | bloqués |

- **Saut des Survivants :** `Humanoid.JumpHeight` 4,5. On peut sauter sur un banc, jamais sur un rocher.
- **Contact d'un Zbire :** distance horizontale ≤ 3 studs **et** écart vertical ≤ 4 studs. Monter sur une table ne met pas à l'abri.
- **Tir automatique :** il ne vise qu'une cible visible, avec un raycast filtré sur le dossier `BloqueTir` (Maison, rochers, Mine). Les Trois Rochers créent le seul angle mort de la Prairie : il faut se déplacer pour viser derrière.
- **Budget des îlots :** 400 Parts au total, 0 Neon, 0 `PointLight`.

## 3. Îlots de couverture et flanking

Les 4 chemins (Terre battue #C8894F, 8 studs de large) mènent aux portails N, E, S et O. On n'y met rien de fixe : c'est là que l'équipe pose ses Murets et ses Tapis. Chaque portail diagonal fait face à un îlot, qui partage son flux entre les deux chemins voisins. Ces Zbires arrivent donc sur le côté des défenses posées sur les chemins.

| Quadrant | Îlot (centre) | Composition | Effet |
|---|---|---|---|
| NE | Pique-nique renversé (32, 0, −32) | 2 nappes (A), 1 table 6 × 3 × 4 et 2 bancs (B) en arc de 12 studs | Partage le flux, le Sauteur passe par-dessus |
| NO | Les Trois Rochers (−34, 0, −34) | 3 rochers (C) 4 × 6 × 4 en V ouvert vers la Lisière, espacés de 3 studs | Angle mort et entonnoir |
| SO | La Haie en L (−30, 0, 30) | 2 haies (B) 12 × 3 × 2 | Couloir d'attaque sur le côté |
| SE | La Mine (20, 0, 20) | Mine (C) et 1 haie (B) 8 × 3 × 2 | Coupe le flux près de la Maison |

- **Pas de rocher au sud :** aucun palier C au sud, sauf la Mine. Côté caméra, il cacherait les Survivants.
- **Pas d'escalier :** aucun décor B à moins de 5 studs d'un décor C, pour qu'on ne puisse pas atteindre un perchoir.
- **Proposition à valider :** le Rapide contourne les Murets, grâce à un second champ de flux recalculé à chaque pose. Les autres Zbires au sol les frappent. S'il ne reste aucun passage, le Rapide frappe aussi.

## 4. Portails équitables

Les 8 portails sont au rayon 86 (N, NE, E, SE, S, SO, O, NO), dans des trouées de 22 studs. Chacun a un cadre carré de 4 barres Neon 12 × 1 × 1. Cela fait 32 Parts Neon sur les 150 autorisées, sans aucune lumière.

1. **Personne ne campe un portail.** 32 murs invisibles au rayon 74 : `Transparency` 1, `CanCollide` true, `CanQuery` false, `CanTouch` false, groupe de collision `LimiteSurvivants`, qui ne heurte que les Survivants. Au moins 12 studs séparent toujours un Survivant d'une sortie : personne n'est étourdi quand un Zbire apparaît.
2. **Alerte de 1,5 s avant chaque paquet.** Le cadre passe de Violet horde #9B5DE5 à Alerte #FF2E63, avec un « wouip » 8-bit. Une flèche en bord d'écran signale le portail s'il est hors champ.
3. **Sortie protégée de 0,8 s.** L'attribut `Ciblable` reste à false : on voit sortir tout le paquet avant de tirer.
4. **Paquets de 3 à 5 Zbires du même type**, espacés de 3 studs, pour lire la horde en une seconde.
5. **Portails actifs.** Les jours 1 et 2, seuls les 4 portails des chemins s'ouvrent. Ensuite, le nombre de portails ouverts vaut `clamp(2 + 2 × Survivants, 4, 8)`, et les portails ouverts changent chaque jour. Un joueur seul ne défend jamais 8 directions.
6. **Équité.** Chaque portail est tiré avec un poids de 1 / (1 + retard)², et le même portail ne lance jamais deux paquets de suite.
7. **Butin.** Un Zbire vaincu dans la Lisière lâche ses pièces au plus au rayon 68.

```lua
--!strict
-- ServerScriptService.Horde.Portails (ModuleScript, serveur uniquement)
-- Tirage équitable des portails, alerte et sortie protégée des paquets.
-- Horde.Zbires fournit creer() et gère la file du plafond de 60 Zbires.
local Workspace = game:GetService("Workspace")

local RAYON_PORTAIL = 86
local RAYON_BUTIN = 68 -- limite des Survivants : 74
local TELEGRAPHE = 1.5
local TELEGRAPHE_COLOSSE = 4
local SORTIE = 0.8
local ECART_PAQUET = 3
local NOMS = { "N", "NE", "E", "SE", "S", "SO", "O", "NO" }
local CHEMINS = { 1, 3, 5, 7 }
local PORTAILS_COLOSSE = { 1, 2, 3, 7, 8 } -- jamais par le sud (caméra)

type Portail = { nom: string, cframe: CFrame, compte: number, modele: Model? }
type Createur = (typeZbire: string, cframe: CFrame) -> Model

local dossier = Workspace:WaitForChild("Prairie"):WaitForChild("Portails")
local rng = Random.new()
local portails: { Portail } = {}
local actifs: { Portail } = {}
local dernier: Portail? = nil

for i, nom in NOMS do
	local angle = math.rad((i - 1) * 45)
	local position = Vector3.new(math.sin(angle), 0, -math.cos(angle)) * RAYON_PORTAIL
	portails[i] = {
		nom = nom,
		cframe = CFrame.lookAt(position, Vector3.zero), -- face à la Maison
		compte = 0,
		modele = dossier:FindFirstChild(nom) :: Model?,
	}
end

local function signaler(p: Portail, attribut: string, valeur: boolean)
	local modele = p.modele
	if modele then
		modele:SetAttribute(attribut, valeur) -- le client anime le cadre Neon
	end
end

local function choisir(): Portail
	local minimum = math.huge
	for _, p in actifs do
		minimum = math.min(minimum, p.compte)
	end
	local poids: { number } = {}
	local total = 0
	for i, p in actifs do
		local w = if p == dernier and #actifs > 1 then 0 else 1 / (1 + p.compte - minimum) ^ 2
		poids[i] = w
		total += w
	end
	local tirage = rng:NextNumber() * total
	for i, p in actifs do
		tirage -= poids[i]
		if tirage <= 0 and poids[i] > 0 then
			return p
		end
	end
	return actifs[1]
end

local Portails = {}

function Portails.nouveauJour(jour: number, nbSurvivants: number)
	table.clear(actifs)
	dernier = nil
	if jour <= 2 then
		for _, i in CHEMINS do
			table.insert(actifs, portails[i])
		end
	else
		local nb = math.clamp(2 + 2 * nbSurvivants, 4, 8)
		for k = 0, nb - 1 do
			table.insert(actifs, portails[(math.floor(k * 8 / nb) + jour) % 8 + 1])
		end
	end
	for _, p in portails do
		p.compte = 0
		signaler(p, "Ouvert", table.find(actifs, p) ~= nil)
	end
end

function Portails.lancerPaquet(typeZbire: string, taille: number, creer: Createur)
	if #actifs == 0 then
		return
	end
	local p = choisir()
	dernier = p
	p.compte += taille
	signaler(p, "Alerte", true)
	task.delay(TELEGRAPHE, function()
		signaler(p, "Alerte", false)
		for n = 1, taille do
			local decalage = (n - (taille + 1) / 2) * ECART_PAQUET
			local zbire = creer(typeZbire, p.cframe * CFrame.new(decalage, 0, 0))
			zbire:SetAttribute("Ciblable", false) -- ni tir auto ni dégâts
			task.delay(SORTIE, function()
				if zbire.Parent then
					zbire:SetAttribute("Ciblable", true)
				end
			end)
		end
	end)
end

function Portails.lancerColosse(jour: number, creer: Createur)
	local i = if jour == 5 then 1 else PORTAILS_COLOSSE[rng:NextInteger(1, #PORTAILS_COLOSSE)]
	local p = portails[i]
	signaler(p, "AlerteColosse", true) -- cadre 22 × 22, ping « Colosse ! »
	task.delay(TELEGRAPHE_COLOSSE, function()
		signaler(p, "AlerteColosse", false)
		creer("Colosse", p.cframe)
	end)
end

-- À 75 s : les portails s'éteignent un par un pendant `duree` secondes.
function Portails.fermer(duree: number)
	for k, p in actifs do
		task.delay((k - 1) * duree / #actifs, signaler, p, "Ouvert", false)
	end
	table.clear(actifs)
end

-- Point de chute des pièces : toujours à portée des Survivants.
function Portails.limiterAuPre(position: Vector3): Vector3
	local plat = Vector3.new(position.X, 0, position.Z)
	if plat.Magnitude <= RAYON_BUTIN then
		return position
	end
	return plat.Unit * RAYON_BUTIN + Vector3.yAxis * position.Y
end

return Portails
```

## 5. La caméra oriente la menace

Avec la caméra (0, 45, 28), un `FieldOfView` de 50 et un écran 16:9, un Survivant voit environ 41 studs devant lui (nord) et 44 sur les côtés, **mais seulement 22 derrière lui (sud)**.

- **Colosse.** Au Jour 5, il sort du portail N à t = 40 s, soit 7 min de run, au début de la 8e minute prévue par le canon. Ensuite, il sort de N, NE, E, O ou NO, jamais du sud. Son alerte dure 4 s : le cadre grandit à 22 × 22 et le ping « Colosse ! » part automatiquement.
- **Zbires hors champ.** Un chevron Alerte signale tout Zbire à 40 studs ou moins qui n'est pas à l'écran.
- **Lisière sud.** Les arbres font au plus 8 studs jusqu'au rayon 80, 20 studs jusqu'au rayon 90 et 30 studs au-delà.
- **Maison.** Elle cache le Survivant jusqu'à 9 studs derrière son mur nord. Tant qu'il s'y trouve, toutes ses Parts passent en `LocalTransparencyModifier` 0,6. Si une face attaquée est hors de vue, un chevron Alerte s'affiche au-dessus (`BillboardGui`, `AlwaysOnTop`).

## 6. Courbe de pression d'un jour

| Moment | Part des Zbires du jour | Déroulé |
|---|---|---|
| 0 à 15 s | 15 % | Paquets de 3, mise en place |
| 15 à 60 s | 55 % | Paquets de 4, les attaques de côté commencent |
| 60 à 75 s | 30 % | Paquets de 5, rush final, musique accélérée de 10 % |
| 75 à 80 s | 0 % | Les portails s'éteignent un par un (Neon → `SmoothPlastic` Ardoise #4A4560) |
| Répit, 15 s | 0 % | Réparer, passer à l'Établi, reposer ses défenses |

- **Jour du Colosse :** 50 % de paquets en moins. L'équipe se partage : 1 ou 2 Survivants sur le Colosse, les autres sur la horde.
- **Proposition à valider, la Course au Doré :** le Doré ignore la Maison et file vers le portail opposé en 14 s. Tout le monde quitte sa position pour le poursuivre. Le serveur verse ses gemmes à tous les Survivants.

## 7. Anti-camping

- **Maison :** fermée pendant la run (porte décorative). Son toit, à 14 studs, reste hors d'atteinte.
- **Poses :** entre le Couloir et le rayon 50, à 4 studs minimum d'un palier C, de la Mine et de la Maison. Les Mini-Tourelles sont espacées d'au moins 8 studs. 3 défenses au maximum par Survivant.
- **Enceinte de Murets :** elle ne suffit pas à tout arrêter. Les Zbires au sol la frappent, le Sauteur saute par-dessus et le Volant la survole.
- **Pièces :** elles disparaissent au bout de 15 s et clignotent pendant les 3 dernières. Il faut sortir les ramasser.
- **Étourdissement :** 2 s, puis 1,5 s d'immunité pendant lesquelles aucun Zbire ne cible le Survivant. On n'enchaîne jamais deux étourdissements.
- **Inactivité :** après 90 s sans aucune demande (déplacement, tir, pose), le Survivant ne compte plus dans le multiplicateur coop des nouveaux Zbires. Un « Zzz » s'affiche au-dessus de lui.
- **Réinitialisation :** désactivée côté client avec `StarterGui:SetCore("ResetButtonCallback", false)`.

### 🧩 Designer énigmes — Timothée Vasse
# Zsurvie : 4 énigmes environnementales

## Règles communes

- **Sans texte :** la forme, le code couleur du canon (violet = ennemi, or = pièces, cyan = gemmes, rose-rouge = danger), une note 8-bit et l'effet élastique (× 0,8 / × 1,2 en 0,15 s) portent toute l'information.
- **Rythme :** en run, une énigme n'existe que pendant le Répit de 15 s et se résout en 6 à 12 s. Il n'y en a aucune dans le Répit qui précède un Jour du Colosse (après les jours 4, 9, 14…) : ce Répit sert à se préparer.
- **Solo possible, coop plus rapide :** aucune plaque n'exige deux joueurs en même temps. Toutes les énigmes sont facultatives et n'ont jamais de pénalité pour l'équipe.
- **Économie :** aucune nouvelle source de gemmes. Les bonus de gemmes passent par la Mine et le Doré, deux sources du canon. Le lobby ne donne que des cosmétiques.
- **Autorité serveur :** chaque énigme porte un attribut `Etat` (`Inactive`, `Annonce`, `Ouverte`, `Resolue`, `Echec`). Le client lit cet attribut et anime, le serveur valide et récompense.
- **Mobile :** en run, avec la caméra `Scriptable` (0, 45, 28), on marche sur des plaques ou on tape un prompt. `ClickDetector` est réservé au lobby.

## Vue d'ensemble

| # | Énigme | Zone | Moment | Durée | Interaction | Récompense |
|---|---|---|---|---|---|---|
| 1 | Le Circuit du Réacteur | Laboratoire | Entre deux runs | 30 à 90 s | `ProximityPrompt` | Chapeau pixel, 1 par jour |
| 2 | Les Ombres de la Galerie | Galerie des Zbires | Entre deux runs | 20 à 60 s | `ClickDetector` | Tampon, 1 par jour |
| 3 | Le Filon qui chante | Mine | Répit après un jour impair | 8 à 12 s | `Touched` | Production de la Mine × 2 le jour suivant |
| 4 | Le Panier renversé | Prairie → Lisière | Répit après un jour pair | 10 à 14 s | `ProximityPrompt` maintenu | 1 Doré de plus le jour suivant |

## 1. Le Circuit du Réacteur (Laboratoire)

**Principe.** Entre le bureau de Doc Boulon et l'Arbre des Recherches, une grille de 3 × 3 dalles de 4 × 4 studs porte des tuyaux droits, coudés ou en T. D'un côté se trouve le Réacteur à gemmes, de l'autre la Machine à Chapeaux, éteinte.

**Solution.** Tourner les dalles d'un quart de tour jusqu'à relier le Réacteur à la Machine. La disposition change chaque jour UTC, avec 4 à 6 dalles à tourner.

**Indices progressifs.**
1. Immédiat : chaque tuyau relié au Réacteur s'allume en Gemme cyan. Une extrémité ouverte crache des étincelles Alerte #FF2E63 (`Rate` 8).
2. À 45 s : la Machine souffle des cubes Crème vers la grille, ce qui montre par quel côté le flux doit arriver.
3. À 90 s : Doc Boulon vient pointer la première dalle mal orientée. Celle-ci fait l'effet élastique toutes les 2 s.

**Récompense.** La Machine éjecte un chapeau pixel (collection permanente de 12) pour chaque Survivant à moins de 30 studs, une fois par jour et par joueur. Les résolutions suivantes ne donnent que des confettis. La grille se remélange 60 s après chaque résolution.

**Mise en œuvre.**
- Les dalles sont des Models `Workspace.Laboratoire.Circuit.Dalle1` à `Dalle9`, avec les attributs `Forme` (`Droit`, `Coude`, `T`) et `Rot` (0 à 3).
- Chaque dalle a un `ProximityPrompt` : `Style = Custom`, `HoldDuration = 0`, `MaxActivationDistance = 6`, `Exclusivity = OnePerButton`, `RequiresLineOfSight = false`. Le client affiche une icône ↻ de 80 px, sans texte.
- Sur `Triggered`, le serveur ignore une dalle tournée il y a moins de 0,4 s (le lobby compte 12 joueurs). Il fait ensuite `Rot = (Rot + 1) % 4`, tourne le tuyau de 90° en 0,15 s (`CanCollide = false`) et lance un parcours en largeur depuis le Réacteur. Les tuyaux atteints reçoivent `Alimente = true` et passent en `Neon` (9 Parts au plus).
- Les chapeaux sont enregistrés avec `DataStoreService`, clé `Survivant_<UserId>`, champs `chapeaux` et `jourChapeau`, écrits par `UpdateAsync`.

## 2. Les Ombres de la Galerie (Galerie des Zbires)

**Principe.** Au fond de la Galerie, une frise Crème rétroéclairée montre 4 silhouettes Encre #1E1B2E. Il faut réveiller, dans le même ordre, les figurines correspondantes parmi les 9 exposées (les 8 Zbires et le Mini-Gluant). L'énigme entraîne le pilier 1 : reconnaître un Zbire à sa silhouette.

**Solution.** Toucher les 4 figurines dans l'ordre de la frise, qui est tirée au sort chaque jour UTC. À partir du 3e Tampon, la frise glisse des paires pièges : Gluant et Mini-Gluant (la taille), Marcheur et Casqué (le casque), Rapide et Sauteur (la posture).

**Indices progressifs.**
1. La frise elle-même : chaque bonne figurine allume sa case en Or.
2. Après 2 erreurs : la prochaine silhouette pulse, pour ce joueur seulement.
3. Après 4 erreurs : 3 dalles du sol s'allument en pas japonais jusqu'à la bonne figurine.

**Récompense.** Un Tampon par jour. À 7 Tampons, consécutifs ou non, le joueur reçoit le skin de Blaster « Figurine ». À 30 Tampons, il reçoit le costume « Gardien de la Galerie ». Les variantes du canon (à 10, 100 et 1 000 éliminations) ne changent pas.

**Mise en œuvre.**
- Chaque figurine a un `ClickDetector` avec `MaxActivationDistance = 24`. Elle mesure au moins 3 × 3 studs pour qu'un doigt la touche sur téléphone.
- Le serveur garde l'état par joueur, `progression[joueur]` et `erreurs[joueur]`, effacés à `PlayerRemoving`.
- Une bonne figurine joue son animation signature pour tous (le Gluant se divise, le Sauteur bondit). Sur une erreur, la figurine secoue la tête en Alerte, pour ce joueur seul, via le `RemoteEvent` `GalerieRetour:FireClient`.
- En cas de réussite, les 4 figurines défilent 3 s sur leurs socles et le Tampon est écrit par `UpdateAsync`.

## 3. Le Filon qui chante (Mine)

**Principe.** Devant la Mine se dressent 4 cristaux Gemme cyan de 1, 2, 3 et 4 cubes de haut (4 studs au plus, sous la limite de 6). Chacun se trouve sur une plaque Terre battue de 4 × 4 studs. Au début du Répit, la Mine joue une suite : chaque cristal s'allume et chante sa note (Do, Mi, Sol, Do aigu).

**Solution.** Marcher sur les plaques dans le même ordre. La suite compte 3 notes, plus 1 tous les 5 jours, 5 au maximum, et jamais deux fois la même note d'affilée. L'équipe a 3 essais.

**Indices progressifs.**
1. La hauteur du cristal double la note : la suite se lit aussi sans le son.
2. Au premier échec, la suite est rejouée à mi-vitesse (0,6 s par note).
3. Au deuxième échec, le prochain cristal à toucher pulse (attribut `Prochain`, animé par le client).

**Récompense.** Le Filon : la Mine produit deux fois plus pendant les 80 s du jour suivant et crache des éclats cyan. Ce sont des gemmes de la Mine, une source du canon. Le service de la Mine lit `Mine.Filon` au passage en horde et le remet à `false` à la fin du jour.

**Mise en œuvre.** Script serveur complet, dans `ServerScriptService.Enigmes.FilonQuiChante` :

```lua
-- Hypothèse : Charte.Gemme = { Base, Ombre, Lumiere } (Color3)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local Partie = ReplicatedStorage:WaitForChild("Partie") -- attributs Phase ("Horde" | "Repit") et Jour
local mine = Workspace:WaitForChild("Mine")
local filon = mine:WaitForChild("Filon")
local fanfare = filon:WaitForChild("Fanfare") :: Sound
local buzz = filon:WaitForChild("Buzz") :: Sound

local cristaux, plaques, notes = {}, {}, {}
for i = 1, 4 do
	cristaux[i] = filon:WaitForChild("Cristal" .. i)
	plaques[i] = filon:WaitForChild("Plaque" .. i)
	notes[i] = cristaux[i]:WaitForChild("Note")
end

local rng = Random.new()
local sequence: { number } = {}
local progression, essais, generation = 0, 0, 0
local ouverte = false
local dernierPas: { [Player]: number } = {}

local function allumer(i: number, duree: number)
	local cristal = cristaux[i]
	cristal.Color = Charte.Gemme.Lumiere
	cristal.Material = Enum.Material.Neon
	notes[i]:Play()
	task.delay(duree, function()
		cristal.Color = Charte.Gemme.Base
		cristal.Material = Enum.Material.SmoothPlastic
	end)
end

local function annoncer(gen: number, duree: number)
	ouverte = false
	task.wait(0.8)
	if gen ~= generation then return end
	filon:SetAttribute("Etat", "Annonce")
	filon:SetAttribute("Prochain", 0)
	for _, i in sequence do
		if gen ~= generation then return end
		allumer(i, duree)
		task.wait(duree + 0.15)
	end
	if gen ~= generation then return end
	progression = 0
	ouverte = true
	filon:SetAttribute("Etat", "Ouverte")
	if essais >= 2 then
		filon:SetAttribute("Prochain", sequence[1]) -- indice 3
	end
end

local function demarrer(jour: number)
	generation += 1
	essais = 0
	table.clear(sequence)
	for n = 1, math.min(3 + jour // 5, 5) do
		local i
		repeat
			i = rng:NextInteger(1, 4)
		until i ~= sequence[n - 1]
		sequence[n] = i
	end
	task.spawn(annoncer, generation, 0.4)
end

local function fermer()
	generation += 1
	ouverte = false
	filon:SetAttribute("Etat", "Inactive")
	filon:SetAttribute("Prochain", 0)
end

local function surPas(i: number, hit: BasePart)
	if not ouverte then return end
	local joueur = Players:GetPlayerFromCharacter(hit.Parent)
	local racine = joueur and joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
	if not joueur or not racine then return end
	if (racine.Position - plaques[i].Position).Magnitude > 6 then return end
	local maintenant = os.clock()
	if maintenant - (dernierPas[joueur] or 0) < 0.3 then return end
	dernierPas[joueur] = maintenant
	if i == sequence[progression] then return end -- pieds encore sur la plaque validée

	if i == sequence[progression + 1] then
		progression += 1
		allumer(i, 0.25)
		if progression == #sequence then
			ouverte = false
			filon:SetAttribute("Etat", "Resolue")
			filon:SetAttribute("Prochain", 0)
			mine:SetAttribute("Filon", true) -- lu par le service de la Mine
			fanfare:Play()
		elseif essais >= 2 then
			filon:SetAttribute("Prochain", sequence[progression + 1])
		end
	else
		ouverte = false
		essais += 1
		filon:SetAttribute("Etat", "Echec")
		buzz:Play()
		if essais < 3 then
			task.spawn(annoncer, generation, 0.6) -- indice 2 : mi-vitesse
		end
	end
end

for i, plaque in plaques do
	plaque.Touched:Connect(function(hit)
		surPas(i, hit)
	end)
end

Partie:GetAttributeChangedSignal("Phase"):Connect(function()
	local jour = Partie:GetAttribute("Jour") or 1 -- pendant le Répit : le jour qui vient de finir
	if Partie:GetAttribute("Phase") == "Repit" and jour % 2 == 1 and jour % 5 ~= 4 then
		demarrer(jour)
	else
		fermer()
	end
end)

Players.PlayerRemoving:Connect(function(joueur)
	dernierPas[joueur] = nil
end)

fermer()
```

## 4. Le Panier renversé (Prairie → Lisière)

**Principe.** Au début du Répit, un panier de pique-nique se renverse à 35 studs de la Maison, sur l'un des 4 chemins. Il lance une gerbe de cubes Or (`Rate` 20 pendant 0,5 s) et un « hoquet » 8-bit spatialisé. Trois pistes d'empreintes en partent vers la Lisière : celles du Marcheur (larges et plates), du Sauteur (par paires espacées de 6 studs) et du Doré (petites, à 3 orteils). Seule la piste du Doré mène à son Nid, un buisson de cubes situé entre 75 et 85 studs de la Maison.

**Solution.** Suivre les empreintes du Doré, puis maintenir 1 s le prompt du bon buisson. Les Survivants peuvent se répartir les pistes et se guider avec « Ici ! » dans la Roue des Pings.

**Indices progressifs.**
1. La forme des empreintes, qui rappelle les silhouettes de la Galerie : les deux énigmes se répondent.
2. À 4 s : les empreintes du Doré scintillent (`ParticleEmitter` Or, `Rate` 4).
3. À 8 s : le bon buisson fait l'effet élastique et crache un cube Or toutes les 2 s.

**Récompense.** Le jour suivant, un Doré de plus sort du portail violet le plus proche du Nid, 5 s après le début de la horde. Il compte dans le plafond de 60 Zbires. Le risque est voulu : quand la horde repart, le Survivant qui a trouvé le Nid est à 80 studs de la Maison, soit 5 s de course.

**Mise en œuvre.**
- Les empreintes viennent de 3 gabarits rangés dans `ServerStorage.Enigmes.Empreintes` : des Parts de 1 × 0,1 × 1, avec `Anchored` à `true` et `CanCollide`, `CanQuery` et `CanTouch` à `false`. Le serveur en clone 10 par piste, soit 30 Parts, détruites à la fin du Répit.
- Chaque chemin a 3 buissons Nid (12 au total), dont un seul est actif par Répit. Chaque buisson porte un `ProximityPrompt` : `Style = Custom`, `HoldDuration = 1`, `MaxActivationDistance = 10`.
- Sur `Triggered`, le serveur vérifie que `Phase` vaut `"Repit"`, que `Etat` vaut `"Ouverte"` et que le `HumanoidRootPart` est à 12 studs au plus. Sur le bon buisson, il passe `Etat` à `"Resolue"` et appelle `Partie:SetAttribute("DoreBonus", indexPortail)`, que le service d'apparition consomme. Un mauvais buisson lâche une bouffée de cubes violets : la seule pénalité est le temps perdu.
- Au passage en horde, `Etat` repasse à `"Inactive"` et les prompts sont désactivés.

## Écart déclaré

Réacteur à gemmes, Machine à Chapeaux, Tampon, Filon, Nid du Doré et Panier renversé sont des noms de décor de travail, hors canon. Ils doivent être validés par Victor Lanoue.

## 🏔️ Terrain & Environnement

### ⛰️ Artiste terrain — Garance Weiss
## 1. Principe : zéro voxel, relief en blocs

Le Terrain Roblox est lisse par nature, et le canon l'interdit. Il n'y a donc **aucune cellule de Terrain** dans les deux places. Sol et relief sont des `Part` Block en `SmoothPlastic`, rangées dans `Workspace.Arene.Sol` et colorées avec `ReplicatedStorage.Charte`.

| Outil du Terrain Editor | Sur Zsurvie |
|---|---|
| Create > Clear | Seul outil utilisé : vider le Terrain des 2 places |
| Generate, Import | `SculpteurBloc` (§5), cellules de 8 studs |
| Draw, Sculpt, Add, Subtract | Parts posées à la main, Move snap 4, Rotate 90° |
| Flatten, Smooth, Sea Level | Inutiles ou interdits : sol à Y = 0, gradins nets, aucune eau |
| Paint | `Charte.Couleurs`, `Charte.Ombre` et `Charte.Lumiere` |

Terrain > `Decoration` = false. Contrôle QA : `print(workspace.Terrain:CountCells())` doit afficher `0`.

## 2. Plan de la Prairie

Repère a11 : origine au centre de la Maison, Nord = −Z. Les dalles de 8 × 8 sont centrées sur l'axe des chemins (bords à ±4, ±12…) : chaque chemin couvre une colonne de dalles.

| Élément | Emprise (studs) | Dessus Y | Teinte |
|---|---|---|---|
| Sol de base (`CanQuery` : cible du raycast de pose) | 220 × 2 × 220 | 0 | Prairie #6CC24A |
| Cœur en damier (spec a04) | r < 30 | 0,05 | Prairie base / lumière #88C962 |
| Champ en damier | r < 70 | 0,05 | Prairie base / ombre #569B3B |
| Lisière, puis trouées (axes) et alcôves (diagonales, r < 116) de 24 studs | 70 ≤ r < 100 | 0,05 | Prairie ombre |
| Couloir de réparation (a14) et Parvis (a11) | 24 × 24 ; 32 × 12, Z 8 → 20 | 0,2 | Terre battue lumière #D19C66 |
| 4 chemins | 8 de large, R 8 → 80 | 0,15 | Terre battue #C8894F |
| 8 pads de portail (Nord en 24 × 12 pour le cadre du Colosse) | 12 × 12 à R 80 | 0,1 | Violet horde ombre #7C4AB7 |
| Mine (a11) sur déblais 20 × 20 à 0,1 | 12 × 12 × 3 + 8 × 8 × 3, X 20 → 32, Z 20 → 32 | 6 | Ardoise ombre #3B374D et Ardoise ; déblais en Terre battue ombre #A06E3F |
| Berge nord | gradins de 4 (r < 116) et de 8 (r < 128), puis monts d'angle de 12 ou 18 | 4 → 18 | Dessus Prairie puis Prairie lumière ; flancs Terre battue ombre puis Ardoise |
| Berge sud (z > 20, plafond a11, hors champ) | r ≥ 100 | 4 ou 8 | Prairie |
| Canopée (4 Parts hors arène) | cadre ±108 → ±150 | 12, 8 au sud | Prairie ombre |

- **Lisibilité** : rien ne dépasse 6 studs sous r = 60, et le relief ne commence qu'à r = 100.
- **Occlusion** : la caméra regarde toujours vers −Z. Au sud, tout décor doit rester sous **1,6 × (r − 74)** studs, sinon il masque le Survivant arrêté à la barrière.

## 3. Transitions

- **Jamais deux teintes coplanaires** : chaque couche monte de 0,05 (Ronde à 0,15, chevrons a11 à 0,25). Deux Parts de même teinte peuvent se chevaucher.
- **Cœur → Champ → Lisière** : la dalle claire du damier devient sombre, puis tout le sol devient sombre. L'escalier de 8 studs dessine le cercle.
- **Prairie → chemin** : Terre battue franche, sans liseré. Le contraste tient sous `ClockTime` 17,5.
- **Lisière → berge** : on passe du vivant à la roche en montant (flancs Prairie, puis Terre battue ombre, puis Ardoise). Les dessus s'éclaircissent avec l'altitude.
- **Flancs au nord seulement** : la caméra ne voit que les faces tournées vers +Z. Au nord de z = 20 : corps (flanc) + chapeau de 1 stud. Au sud : une seule Part.

## 4. Performance

- **Terrain** : 0 cellule. **Eau** : aucune (reflets coûteux, bleu-cyan réservé aux gemmes).
- **Emprise** : 220 × 220 studs, de Y = −2 à Y = 18. Seule la Canopée dépasse (±150) : depuis la barrière, la caméra (0, 45, 28) en `FieldOfView` 50 voit environ 41 studs devant et 70 sur les côtés. Sans elle, on verrait le vide.
- **Budget : 400 Parts au plus** (environ 300 prévues), pris sur les 4 500 Parts décor de a11. Si on dépasse : un seul damier.
- **Physique** : tout est `Anchored`. Hors sol de base et Mine, `CanCollide`, `CanQuery` et `CanTouch` sont à false (ni physique ni raycast du Blaster).
- **Ombres** : `CastShadow` à false sous 2 studs d'épaisseur.
- **Batching** : 9 teintes, uniquement des Blocks, ni `UnionOperation` ni `MeshPart`.
- **Serveur** : tout sol foulé est à Y = 0, donc aucun raycast de sol pour les 60 Zbires à 10 Hz.

## 5. `SculpteurBloc`

ModuleScript `ServerStorage.OutilsMap.SculpteurBloc`, outil d'édition jamais requis en jeu : il génère dalles et berge. Les couches fixes du tableau se posent à la main.

```lua
-- Barre de commande : print(require(game.ServerStorage.OutilsMap.SculpteurBloc).construire())
local Charte = require(game:GetService("ReplicatedStorage").Charte)
local C, O, L = Charte.Couleurs, Charte.Ombre, Charte.Lumiere

local CELLULE, N = 8, 13 -- cellules -13..13, bords à ±108
local Z_SUD = 20 -- au sud, la caméra ne voit aucun flanc

type Rect = { i0: number, i1: number, j0: number, j1: number, genre: string }

local GENRES = {
	clair = { dessus = 0.05, couleur = L(C.Prairie) },
	sombre = { dessus = 0.05, couleur = O(C.Prairie) },
	gradin1 = { h = 4, couleur = C.Prairie },
	gradin2 = { h = 8, couleur = C.Prairie, flanc = O(C.TerreBattue) },
	gradin3 = { h = 12, couleur = L(C.Prairie), flanc = C.Ardoise },
	sommet = { h = 18, couleur = L(C.Prairie), flanc = C.Ardoise },
}

local function genreDe(i: number, j: number): string?
	local x, z = i * CELLULE, j * CELLULE
	local ax, az, r = math.abs(x), math.abs(z), math.sqrt(x * x + z * z)
	if (ax < 4 or az < 4) and r < 84 then
		return nil -- sous les chemins
	elseif r < 70 then
		if (i + j) % 2 == 0 then
			return nil -- dalle base : le sol de base reste visible
		end
		return if r < 30 then "clair" else "sombre"
	elseif r < 100 or ax < 12 or az < 12 or (r < 116 and math.abs(ax - az) < 12) then
		return "sombre" -- Lisière, trouées, alcôves
	elseif z > Z_SUD then
		return if r < 116 then "gradin1" else "gradin2"
	elseif r < 116 then
		return "gradin1"
	elseif r < 128 then
		return "gradin2"
	end
	return if math.noise(x / 40, z / 40, 7.3) > 0.1 then "sommet" else "gradin3"
end

local function poser(parent: Instance, taille: Vector3, centre: Vector3, couleur: Color3)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
	p.CastShadow = taille.Y >= 2
	p.Color = couleur
	p.Size = taille
	p.Position = centre
	p.Parent = parent
end

local function fermer(dossier: Folder, rect: Rect): number
	local g = GENRES[rect.genre]
	local sx, sz = (rect.i1 - rect.i0 + 1) * CELLULE, (rect.j1 - rect.j0 + 1) * CELLULE
	local cx, cz = (rect.i0 + rect.i1) / 2 * CELLULE, (rect.j0 + rect.j1) / 2 * CELLULE
	if g.dessus then
		poser(dossier, Vector3.new(sx, 0.2, sz), Vector3.new(cx, g.dessus - 0.1, cz), g.couleur)
		return 1
	elseif g.flanc and rect.j0 * CELLULE < Z_SUD then
		poser(dossier, Vector3.new(sx, g.h - 1, sz), Vector3.new(cx, (g.h - 1) / 2, cz), g.flanc)
		poser(dossier, Vector3.new(sx, 1, sz), Vector3.new(cx, g.h - 0.5, cz), g.couleur)
		return 2
	end
	poser(dossier, Vector3.new(sx, g.h, sz), Vector3.new(cx, g.h / 2, cz), g.couleur)
	return 1
end

local SculpteurBloc = {}

function SculpteurBloc.construire(): number
	local arene = workspace:FindFirstChild("Arene") or Instance.new("Folder")
	arene.Name, arene.Parent = "Arene", workspace
	local ancien = arene:FindFirstChild("Sol")
	if ancien then
		ancien:Destroy()
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "Sol"

	-- Fusion gloutonne : bandes par rangée, prolongées vers le sud si identiques
	local total = 0
	local ouverts: { [string]: Rect } = {}
	for j = -N, N do
		local courants: { [string]: Rect } = {}
		local i = -N
		while i <= N do
			local g, i0 = genreDe(i, j), i
			while i < N and genreDe(i + 1, j) == g do
				i += 1
			end
			if g then
				local cle = `{i0}:{i}:{g}`
				local rect = ouverts[cle] or { i0 = i0, i1 = i, j0 = j, j1 = j, genre = g }
				rect.j1 = j
				courants[cle] = rect
			end
			i += 1
		end
		for cle, rect in ouverts do
			if courants[cle] ~= rect then
				total += fermer(dossier, rect)
			end
		end
		ouverts = courants
	end
	for _, rect in ouverts do
		total += fermer(dossier, rect)
	end
	dossier.Parent = arene
	return total
end

return SculpteurBloc
```

## 6. Socle du Laboratoire (proposition)

La caméra Custom de a11 montre l'extérieur du lobby, absent du canon. À valider :

- Plateau en dalles de 8, qui déborde de 16 studs l'emprise a11 (hall R 52, Galerie, Quai, Spawn). Dessus à Y = 0, en Ardoise lumière #6C6573.
- 3 falaises de 8 studs, chacune en retrait de 8 : l'île flotte. Flancs en Ardoise, puis Ardoise ombre, puis Nuit labo.
- Quai des Capsules en surplomb de 16 studs, au-dessus d'une mer de nuages (8 dalles Crème de 64 × 4 × 64 vers Y = −44).
- 60 Parts au plus, aucun Terrain.

### 🌲 Artiste végétation — Élio Vance
## 1. Règles communes

- **Écart assumé par rapport à la mission : pas de Terrain Decoration.** On règle `Workspace.Terrain.Decoration = false` et on ne pose aucun voxel. Trois raisons : le canon interdit le Terrain lisse, l'herbe animée ne s'affiche que près de la caméra (la nôtre est à 53 studs du Survivant) et elle disparaît aux niveaux graphiques bas des Android d'entrée de gamme. L'herbe devient des Touffes-cubes en MeshPart instanciées.
- **Toute pièce végétale** : `Anchored = true` ; `CanCollide`, `CanQuery` et `CanTouch` à `false` ; matériau `SmoothPlastic`. Elle n'arrête ni un tir, ni un Zbire, ni une pose de défense. La limite de l'arène est un mur invisible, pas une haie.
- **Ombres** : `CastShadow = false`, sauf sur les houppiers d'arbres de 4 studs de haut ou plus.
- **MeshParts** : `RenderFidelity = Performance`, `CollisionFidelity = Box`, pas de `TextureID`. On utilise un seul MeshId par objet pour que toutes ses copies partent dans un seul lot de rendu ; seule la `Color` change d'une copie à l'autre.
- **Grille** : positions arrondies au stud, rotations par quarts de tour uniquement.
- **Couleurs** : seulement Prairie, Terre battue, Crème et Ardoise. Jamais d'or (on le confondrait avec les pièces au sol), de cyan (gemmes), de violet (Zbires, portails) ni de rose-rouge (danger).

## 2. Palette et kit (`ServerStorage.KitVegetation`)

| Couleur | Base | Ombre (× 0,8) | Lumière (+20 % Crème) |
|---|---|---|---|
| Prairie | #6CC24A | #569B3B | #88C962 |
| Terre battue | #C8894F | #A06E3F | #D19C66 |
| Crème | #F6E7C1 | #C5B99A | #F6E7C1 |
| Ardoise | #4A4560 | #3B374D | #6C6573 |

Chaque gabarit est un `Model` dont le `PrimaryPart` touche le sol. Les parties de feuillage s'appellent `Houppier` et prennent Prairie ombre (70 % des objets) ou Prairie base (30 %), tiré objet par objet. Le sommet s'appelle `Cime` et prend Prairie lumière.

| Gabarit | Construction (studs) | Hauteur | Parts | Tronc ou corps |
|---|---|---|---|---|
| `Touffe` | MeshPart, 3 brins de 0,5 × 1 × 0,5 | 1 | 1 | Prairie lumière |
| `Fleur` | MeshPart, croix de 5 cubes de 0,5 sur une tige | 1 | 1 | Crème |
| `BuissonBas` | Houppier 4 × 1,5 × 4, Cime 2 × 0,5 × 2 | 2 | 2 | — |
| `Fougere` | MeshPart, 4 feuilles en escalier | 2 | 1 | Prairie base |
| `Souche` | Block 2 × 1,5 × 2 | 1,5 | 1 | Terre battue ombre |
| `Champignon` | pied 1 × 2 × 1, chapeau 3 × 1 × 3 | 3 | 2 | Crème, chapeau Terre battue |
| `BuissonHaut` | Houppier 6 × 3 × 6, Cime 3 × 1 × 3 | 4 | 2 | — |
| `CheneNain` | tronc 2 × 3 × 2, Houppier 7 × 5 × 7, Cime 4 × 1 × 4 | 9 | 3 | Terre battue ombre |
| `Chene` | tronc 2 × 5 × 2, Houppier 10 × 6 × 10, Cime 6 × 3 × 6 | 14 | 3 | Terre battue ombre |
| `Bouleau` | tronc 1,5 × 9 × 1,5, Houppier 6 × 5 × 6 | 14 | 2 | Crème |
| `Pin` | tronc 2 × 4 × 2, Houppiers 8 × 3 × 8, 6 × 3 × 6 et 4 × 3 × 4, Cime 2 × 2 × 2 | 15 | 5 | Ardoise |
| `MasseFeuillage` | Block `Masse` 14 × 10 × 14, sans ombre | 10 | 1 | Prairie ombre |

## 3. Composition par zone

### La Prairie (rayon de 0 à 70 studs) : le pique-nique

| Anneau | Végétation | Hauteur max |
|---|---|---|
| 0 à 20 | Aucune (Maison, Mine, zone de pose). Sur le sol nu, pièces et gemmes restent lisibles | 0 |
| 20 à 45 | Touffes clairsemées (pas de 10), Fleurs à partir de 30 | 1 |
| 45 à 70 | Touffes denses (pas de 5), Fleurs, BuissonBas en petits groupes | 2 |

- **Chemins** : 6 studs libres de chaque côté de l'axe. Une bordure de Fleurs est posée tous les 6 studs, à 7 studs de l'axe, de 24 à 66 studs du centre : on lit les 4 directions sans flèche.
- **Lisibilité** : la caméra (0, 45, 28) plonge à 58°. Vu de là, un buisson de 2 studs ne cache aucun Zbire.
- **Floraison** : au jour 1, les bordures et 40 % des autres Fleurs sont ouvertes. Les autres éclosent entre le jour 1 et le jour 10. En fleurissant, la Prairie montre l'avancée de la run.

### La Lisière (de 70 à 100 studs) : la forêt de cubes

- **Orée irrégulière** : les premiers troncs se placent entre 72 et 80 studs, selon un bruit calculé sur l'angle. Dès 70 studs, le sous-bois (Fougere, Souche, Champignon, BuissonHaut) assure la transition.
- **Bosquets** : un bruit de période 24 studs regroupe les arbres par 3 à 5 et laisse des trouées entre les groupes.
- **Amphithéâtre** : la caméra est toujours au sud (+Z) du Survivant, donc les arbres montent en hauteur vers le nord.
  - Côté caméra (± 60° autour du sud) : `CheneNain` seulement. Il reste sous la ligne de visée même quand le Survivant touche la limite de l'arène.
  - Flancs : `Chene` et `Bouleau`.
  - Nord : `Pin`, `Chene` et `Bouleau`. C'est la toile de fond de toute la run.
- **Clairières des portails** (hypothèse : 8 portails à 85 studs, un tous les 45°) :
  - aucun arbre à moins de 14 studs d'un portail, aucun sous-bois à moins de 8 ;
  - à poser à la main : un rond de 4 Champignons par clairière, dont 2 portent un cube `Neon` Crème de 0,5 stud, soit 16 Neon en tout. Mystérieux, jamais effrayant.
- **Couloirs** : les chemins traversent la Lisière jusqu'aux portails situés sur leur axe. Derrière ces portails, la forêt se referme.
- **Interdits** : branches crochues, troncs noirs, yeux dans les buissons.

### Le fond (de 100 studs jusqu'aux bords)

Des `MasseFeuillage` au pas de 14 bouchent les coins de l'arène carrée : la caméra ne voit jamais le vide.

### Laboratoire, Quai des Capsules, Galerie des Zbires (150 BaseParts au maximum)

- **Laboratoire** :
  - un bac Ardoise 2 × 2 × 2 avec une `Fougere`, à gauche de chaque Alcôve, jamais devant les machines ;
  - du lierre en cubes (1 × 1 × 0,5, Prairie ombre), en coulées de 6 cubes sur 8 piliers ;
  - 3 bocaux-serres près de Doc Boulon (matériau `Glass`, `Transparency` 0,6).
- **Quai des Capsules** : 6 jardinières Ardoise de 8 × 2 × 2, coiffées d'une haie-cube Prairie.
- **Galerie des Zbires** : chaque vitrine a pour fond une Lisière miniature (`CheneNain`, `Touffe`, `Souche`), avec les mêmes MeshId qu'en run.

## 4. Budget d'instances (Prairie)

| Couche, par ordre de priorité | Rayon (studs) | Pas | Objets (≈) | BaseParts (≈) |
|---|---|---|---|---|
| Bordures de Fleurs | le long des chemins | 6 | 64 | 64 |
| Arbres | 72 à 100 | 7 | 70 | 230 |
| MasseFeuillage | 100 aux bords | 14 | 75 | 75 |
| Sous-bois | 70 à 100 | 6 | 100 | 150 |
| BuissonBas | 50 à 70 | 9 | 40 | 80 |
| Fleurs | 30 à 70 | 8 | 60 | 60 |
| Touffes | 20 à 70 | 10, puis 5 | 340 | 340 |
| Ronds de Champignons (à la main) | clairières | — | 32 | 80 |
| **Total** | | | **≈ 780** | **≈ 1 080** |

- **Plafond : 1 200 BaseParts**, soit 12 % des 10 000 Parts autorisées dans l'arène. Le générateur s'arrête à 1 120 pour laisser 80 Parts à la pose manuelle. Les Touffes sont en fin de liste : si le plafond est atteint, ce sont elles qui sautent.
- **Rendu** : les quelque 500 Touffes, Fleurs et Fougeres ne demandent que 3 MeshId. Tout le reste est statique, sans physique et hors des requêtes spatiales.
- **Pas de LOD** : `StreamingEnabled` est désactivé, donc `LevelOfDetail` ne sert à rien. On économise sur le nombre d'instances.
- **Critère de validation** : sur un Android de 3 Go, avec 6 joueurs et 60 Zbires, masquer `Workspace.Decor.Vegetation` doit faire gagner 2 FPS au plus. Au-delà, on passe les Touffes au pas de 6.

## 5. Générateur (outil Studio, le résultat est enregistré dans la place)

```lua
-- ServerStorage.Outils.GenerateurVegetation (ModuleScript), à lancer depuis la barre de commande :
-- require(game.ServerStorage.Outils.GenerateurVegetation).generer(2026)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage.Charte)
local KIT = ServerStorage.KitVegetation
local PLAFOND = 1120 -- + 80 Parts posées à la main = 1 200
local R_PORTAIL, NB_PORTAILS, DEMI_CHEMIN = 85, 8, 6
local P = Charte.Prairie
local OMBRE = Color3.new(P.R * 0.8, P.G * 0.8, P.B * 0.8)
local LUMIERE = P:Lerp(Charte.Creme, 0.2)

-- Ordre = priorité : au plafond, les Touffes sautent en premier.
local COUCHES = {
	{ nom = "Arbres", rMin = 76, rMax = 100, pas = 7, p = 0.35, tag = "ArbreLisiere", clair = 14 },
	{ nom = "MasseFeuillage", rMin = 100, rMax = 160, pas = 14, p = 0.9, tag = "Fond", clair = 0 },
	{ nom = "SousBois", rMin = 70, rMax = 100, pas = 6, p = 0.3, tag = "SousBois", clair = 8 },
	{ nom = "BuissonBas", rMin = 50, rMax = 70, pas = 9, p = 0.5, tag = "Buisson", clair = 0 },
	{ nom = "Fleur", rMin = 30, rMax = 70, pas = 8, p = 0.4, tag = "Fleur", clair = 0 },
	{ nom = "Touffe", rMin = 20, rMax = 45, pas = 10, p = 1, tag = "Touffe", clair = 0 },
	{ nom = "Touffe", rMin = 45, rMax = 70, pas = 5, p = 0.95, tag = "Touffe", clair = 0 },
}
local SOUS_BOIS = { "Fougere", "Fougere", "Souche", "Champignon", "BuissonHaut" }

local function choisir(nom: string, z: number, r: number, rng: Random): string
	if nom == "SousBois" then return SOUS_BOIS[rng:NextInteger(1, #SOUS_BOIS)] end
	if nom ~= "Arbres" then return nom end
	local cote = z / r -- 1 = plein côté caméra (+Z)
	if cote > 0.5 then return "CheneNain" end
	local liste = if cote < -0.5 then { "Pin", "Chene", "Bouleau" } else { "Chene", "Bouleau" }
	return liste[rng:NextInteger(1, #liste)]
end

local function exclu(x: number, z: number, r: number, clair: number): boolean
	if r < R_PORTAIL + 4 and (math.abs(x) < DEMI_CHEMIN or math.abs(z) < DEMI_CHEMIN) then
		return true -- les 4 chemins en croix, jusqu'aux portails d'axe
	end
	for i = 0, NB_PORTAILS - 1 do
		local a = i * 2 * math.pi / NB_PORTAILS
		local dx, dz = x - math.cos(a) * R_PORTAIL, z - math.sin(a) * R_PORTAIL
		if dx * dx + dz * dz < clair * clair then return true end
	end
	return false
end

local M = {}

function M.generer(graine: number): number
	local rng = Random.new(graine)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Workspace.Carte.Sol }
	local ancien = Workspace.Decor:FindFirstChild("Vegetation")
	if ancien then ancien:Destroy() end
	local racine = Instance.new("Folder")
	racine.Name = "Vegetation"
	racine.Parent = Workspace.Decor
	local total = 0

	local function poser(nom: string, tag: string, x: number, z: number, jourFixe: number?): boolean
		local sol = Workspace:Raycast(Vector3.new(x, 60, z), Vector3.new(0, -120, 0), params)
		if not sol then return true end
		local modele = (KIT:FindFirstChild(nom) :: Model):Clone()
		local teinte = if rng:NextNumber() < 0.7 then OMBRE else P
		local n = 0
		for _, part in modele:GetDescendants() do
			if part:IsA("BasePart") then
				n += 1
				part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
				part.CastShadow = part.Name == "Houppier" and part.Size.Y >= 4
				if part.Name == "Houppier" then part.Color = teinte end
				if part.Name == "Cime" then part.Color = LUMIERE end
			end
		end
		if total + n > PLAFOND then
			modele:Destroy()
			return false
		end
		total += n
		modele:PivotTo(CFrame.new(x, sol.Position.Y, z) * CFrame.Angles(0, rng:NextInteger(0, 3) * math.pi / 2, 0))
		if tag == "ArbreLisiere" then modele:SetAttribute("Angle", math.atan2(z, x)) end
		if tag == "Fleur" then
			local jour = jourFixe or (if rng:NextNumber() < 0.4 then 0 else rng:NextInteger(1, 10))
			modele:SetAttribute("Jour", jour)
			if jour > 0 then (modele.PrimaryPart :: BasePart).Transparency = 1 end
		end
		CollectionService:AddTag(modele, tag)
		modele.Parent = racine
		return true
	end

	-- Bordures fleuries des 4 chemins, ouvertes dès le jour 1
	for _, dir in { Vector3.xAxis, -Vector3.xAxis, Vector3.zAxis, -Vector3.zAxis } do
		local lateral = Vector3.new(dir.Z, 0, dir.X)
		for d = 24, 66, 6 do
			for _, s in { -7, 7 } do
				local pos = dir * d + lateral * s
				poser("Fleur", "Fleur", pos.X, pos.Z, 0)
			end
		end
	end

	-- Couches sur grille décalée au hasard, regroupées en bosquets par un bruit
	for _, c in COUCHES do
		for gx = -110, 110 - c.pas, c.pas do
			for gz = -110, 110 - c.pas, c.pas do
				local x = math.round(gx + rng:NextNumber() * c.pas)
				local z = math.round(gz + rng:NextNumber() * c.pas)
				local r = math.sqrt(x * x + z * z)
				local a = math.atan2(z, x)
				local bord = c.rMin
				if c.nom == "Arbres" then
					bord += 8 * math.noise(math.cos(a) * 2, math.sin(a) * 2, graine % 97 + 0.5)
				end
				local amas = math.clamp(math.noise(x / 24, z / 24, graine % 89 + 0.5) + 0.5, 0, 1)
				if r >= bord and r < c.rMax and math.abs(x) <= 108 and math.abs(z) <= 108
					and not exclu(x, z, r, c.clair) and rng:NextNumber() < c.p * 2 * amas then
					if not poser(choisir(c.nom, z, r, rng), c.tag, x, z) then
						warn(`Plafond de {PLAFOND} atteint dans la couche {c.nom}`)
						return total
					end
				end
			end
		end
	end
	return total
end

return M
```

Une même graine redonne toujours la même forêt. La méthode : on génère une fois, on retouche les bosquets à la main, puis on ne relance plus le générateur.

## 6. Végétation vivante (client, purement cosmétique)

Le serveur pose deux attributs sur `Workspace` : `Jour`, mis à jour à chaque jour franchi, et `ColosseAngle`, en radians, 3 s avant l'arrivée du Colosse. Le client lit ces attributs mais n'envoie rien au serveur.

```lua
-- StarterPlayer.StarterPlayerScripts.VegetationVivante (LocalScript)
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local POP = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local FRISSON = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 5, true)
local origines: { [BasePart]: CFrame } = {}

local function pieces(modele: Instance): { BasePart }
	local liste = {}
	for _, p in modele:GetDescendants() do
		if p:IsA("BasePart") then table.insert(liste, p) end
	end
	return liste
end

-- Floraison : étirement × 1,2 puis retour élastique en 0,15 s, en cascade
local function fleurir()
	local jour = Workspace:GetAttribute("Jour") or 0
	for _, fleur in CollectionService:GetTagged("Fleur") do
		local j = fleur:GetAttribute("Jour") or 0
		if j > 0 and j <= jour and fleur.PrimaryPart and fleur.PrimaryPart.Transparency == 1 then
			for _, p in pieces(fleur) do
				local taille = p.Size
				p.Size = taille * Vector3.new(0.8, 1.2, 0.8)
				p.Transparency = 0
				TweenService:Create(p, POP, { Size = taille }):Play()
			end
			task.wait(0.03)
		end
	end
end
Workspace:GetAttributeChangedSignal("Jour"):Connect(function() task.spawn(fleurir) end)
task.spawn(fleurir)

-- Frisson : les arbres du secteur (± 30°) d'où surgit le Colosse tremblent pour l'annoncer
Workspace:GetAttributeChangedSignal("ColosseAngle"):Connect(function()
	local cible = Workspace:GetAttribute("ColosseAngle")
	if typeof(cible) ~= "number" then return end
	for _, arbre in CollectionService:GetTagged("ArbreLisiere") do
		local a = arbre:GetAttribute("Angle")
		if typeof(a) == "number" and math.abs((a - cible + math.pi) % (2 * math.pi) - math.pi) < math.rad(30) then
			for _, p in pieces(arbre) do
				if p.Name == "Houppier" or p.Name == "Cime" then
					origines[p] = origines[p] or p.CFrame
					p.CFrame = origines[p]
					TweenService:Create(p, FRISSON, { CFrame = origines[p] * CFrame.Angles(0, 0, math.rad(6)) }):Play()
				end
			end
		end
	end
end)

-- Herbe écrasée : Touffes et Fleurs masquées sous chaque défense posée, jusqu'à la fin de la run
CollectionService:GetInstanceAddedSignal("Defense"):Connect(function(defense)
	if not defense:IsA("Model") then return end
	local centre = defense:GetPivot().Position
	local demi = defense:GetExtentsSize() / 2 + Vector3.new(0.5, 0, 0.5)
	for _, tag in { "Touffe", "Fleur" } do
		for _, veg in CollectionService:GetTagged(tag) do
			local d = veg:GetPivot().Position - centre
			if math.abs(d.X) < demi.X and math.abs(d.Z) < demi.Z then
				for _, p in pieces(veg) do p.LocalTransparencyModifier = 1 end
			end
		end
	end
end)
```

### 🌊 Artiste eau & climat — Naïma Duroc
## 1. Principes eau et climat

- **Pendant la run, le ciel reste hors champ.** Avec la caméra (0, 45, 28) et un `FieldOfView` de 50, le bord haut de l'écran reste 33° sous l'horizon. On ne consacre donc aucun budget à `Sky` ni à `Clouds` sur la Prairie : la météo se lit au sol, dans la teinte de l'image et au son.
- **La météo est cosmétique et c'est le serveur qui la décide.** Il publie des attributs sur `ReplicatedStorage` et le client dessine. Il n'y a aucun `RemoteEvent`, et la météo n'agit ni sur les PV, ni sur les pièces, ni sur les gemmes.
- **La lisibilité passe d'abord.** Un Zbire au bord haut de l'écran, à 82 studs de la caméra, doit rester net. D'où la règle : `Atmosphere.Density` ≤ 0,45.
- **La météo ne change que pendant le Répit**, avec un fondu de 8 s, jamais en pleine horde.
- **Style Pixel-bloc :** une goutte = 1 pixel étiré, un flocon = 1 cube de 0,5 stud, l'eau suit la grille de 4 studs.

## 2. L'eau

### Écart à faire valider par Victor Lanoue
Le canon interdit le Terrain lisse. **La Prairie n'a donc aucun voxel** : toute son eau est faite de Parts « Eau-bloc ». **Le Laboratoire a un seul volume de Terrain `Water`** : le Bassin de Doc Boulon, de 24 × 8 × 16 studs. Il est rempli par `Terrain:FillBlock` calé sur la grille de 4 studs, et ses bords sont cachés par des margelles `SmoothPlastic`. C'est le seul endroit du jeu où l'on nage. Si Victor refuse, le Bassin devient de l'Eau-bloc de 1 stud de fond où l'on patauge.

| `Workspace.Terrain` | Valeur | Effet |
|---|---|---|
| `WaterColor` | `Color3.fromRGB(41, 171, 192)` (ombre de Gemme cyan) | Raccord avec les néons cyan |
| `WaterTransparency` | 0,55 | On voit les 4 bandes `Neon` du fond |
| `WaterWaveSize` | 0,05 | Surface presque plane, qui garde une lecture « bloc » |
| `WaterWaveSpeed` | 6 | L'eau frémit, sans houle |
| `WaterReflectance` | 0,25 | Reflète les néons, sans effet miroir |

### La Douve de Lisière (Eau-bloc)
C'est un anneau d'eau entre 71 et 75 studs du centre, tracé en escalier pixel (160 Parts au maximum). 4 ponts-bloc de 8 studs de large le franchissent sur les chemins. La Douve marque la limite de la Prairie. Chaque Zbire au sol qui la traverse fait « plouf », alors que le Volant passe au-dessus sans éclabousser. C'est un décor de la Lisière, pas une nouvelle zone.

| Instance | Réglages |
|---|---|
| Surface | `SmoothPlastic`, #29ABC0, `Transparency` 0,35, `Reflectance` 0,1, `CastShadow`, `CanCollide` et `CanQuery` à false, posée à −0,5 stud |
| Lit | `SmoothPlastic` Nuit labo #2A3263 à −1,5 stud : il fonce l'eau sans ajouter de couleur |
| `Texture` vaguelettes (face `Top`) | 32 × 32 px, Crème, `Transparency` 0,6, `StudsPerTileU/V` 8, défilement côté client de 0,4 stud/s en diagonale |
| Plouf | Un seul `ParticleEmitter` partagé (`Rate` 0), `:Emit(5)` au franchissement, 6 ploufs par seconde au maximum, cubes Crème (`Size` 0,5 → 0, `Lifetime` 0,35) |
| Flaques | 16 Parts de 4 × 0,1 × 4 posées sur les chemins, tag `Flaque`, #29ABC0, `Reflectance` 0,2, `Transparency` 1 par défaut et 0,45 sous la pluie |

**L'eau ne doit pas ressembler aux gemmes.** Elle reste mate, n'est jamais en `Neon` et ne scintille jamais. Le cyan lumineux est réservé aux gemmes et à la Mine.

## 3. Météo dynamique

### Calendrier

| Jour | Météo |
|---|---|
| Jours 1 et 2 | Clair, pour que le tutoriel reste lisible |
| Veilles de Colosse (4, 9, 14…) | Clair, pour que l'orage marque le coup |
| Jour du Colosse (5, 10, 15…) | Orage |
| Autres jours | Tirage avec la graine de la run : Clair 50 %, Averse 30 %, Brume 20 %. Jamais 3 Averses ou 3 Brumes de suite |
| Défi du Jour, événement d'hiver | Peuvent imposer une météo, dont la Neige |
| Laboratoire | Ciel = météo du Défi du Jour (graine = date UTC), avec `Clouds` : `Cover` 0,5, `Density` 0,6, Crème. Au Quai des Capsules, un baromètre-bloc l'annonce |

### Cycle du jour
Le client calcule `ClockTime` 4 fois par seconde à partir de `JourDebut`, en temps serveur :
- pendant la horde (80 s), l'heure passe de 9 à 14,5 ;
- pendant le Répit (15 s), elle passe de 14,5 à 15,5, ou de 14,5 à 17,5 la veille d'un Colosse ;
- le Jour du Colosse, elle reste fixée à 17,5, comme le veut le canon ;
- au début d'un nouveau jour, elle repasse à 9 derrière un fondu d'aube : `Brightness` part de −0,3 et remonte en 0,6 s.

Hors Colosse, l'heure ne dépasse jamais 16 : le crépuscule appartient au Colosse.

### Profils (`Lighting.Atmosphere` + `ColorCorrectionEffect` « CorrectionMeteo »)
Quand un `Atmosphere` est présent, `FogStart` et `FogEnd` sont ignorés. `Glare` vaut 0 dans tous les états.

| État | `Density` | `Offset` | `Haze` | `Color` | `Decay` | `Saturation` | `Brightness` |
|---|---|---|---|---|---|---|---|
| Clair | 0,22 | 0,30 | 0,5 | Crème #F6E7C1 | Crème ombre #C5B99A | 0,10 | 0 |
| Averse | 0,34 | 0,20 | 1,2 | Ardoise lumière #6C6573 | Nuit labo #2A3263 | −0,05 | −0,04 |
| Brume | 0,42 | 0,10 | 2,0 | Crème | Ardoise lumière | −0,02 | 0,02 |
| Orage | 0,36 | 0,15 | 1,5 | Toit orange lumière #F0904C | Violet horde ombre #7C4AB7 | 0,05 | −0,06 |
| Neige | 0,30 | 0,25 | 1,0 | Crème | Nuit labo lumière #535676 | −0,08 | 0,04 |

### Effets (tous dans `ReplicatedStorage.KitMeteo`)
- **Voile de pluie** : il fait l'essentiel de la pluie pour un coût quasi nul. Ce sont 2 Parts côté client, dans `CurrentCamera`, placées à 12 et 24 studs devant l'objectif. Elles mesurent 32 × 16 et 60 × 28 studs, avec `Transparency` 1. Sur leur face `Back`, une `Texture` de traits pixel en 64 × 64 : `StudsPerTile` 6 et 10, `Transparency` 0,55 et 0,7, défilement à 30 et 18 studs/s pour créer de la parallaxe.
- **Gouttes** : 2 `ParticleEmitter` avec `Rate` 20, sur une Part de 60 × 1 × 60 placée 30 studs au-dessus du Survivant. Réglages : `Lifetime` 0,8, `Speed` 60, `Size` 0,5, `Squash` 2, `VelocityParallel`, `LightInfluence` 0, Crème.
- **Brume** : 24 Parts Crème de 8 × 2 × 8 (tag `BrumeCube`), `Transparency` 0,7, entre 78 et 96 studs du centre. Elles tournent autour de la Prairie à 2 studs/s. Les portails violets restent visibles à travers : l'ambiance est mystérieuse, sans jamais faire peur.
- **Neige** : 2 émetteurs avec `Rate` 18, `Lifetime` 3, `Speed` 8 et `RotSpeed` 90, qui lâchent des cubes Crème de 0,5 stud.
- **Éclairs** : ils sont espacés de 10 à 16 s. `Brightness` monte de 0,25 en 0,08 s, puis redescend en 0,35 s. Le tonnerre chiptune suit 1,2 s plus tard, avec un volume de 0,35 : pas de jump scare. L'attribut `EffetsReduits` du Player coupe les flashs.

**Budget par client (plafond du canon entre parenthèses) :**
- `Rate` : 20 (20) ;
- `Neon` : 0 sur la Prairie et 4 au Laboratoire (150) ;
- `PointLight` : 0 (12) ;
- sons : 2 dans le `SoundGroup` Ambiance (16) ;
- Parts : environ 205 (10 000).

**Mode léger** : si la moyenne tombe sous 27 FPS pendant les 5 premières secondes, le client coupe les gouttes, le voile lointain et un cube de brume sur deux.

## 4. Pseudo-code du système

```lua
-- ServerScriptService.MeteoServeur (ModuleScript), appelé par le Directeur de run
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MeteoServeur = {}
local TIRAGE = { { "Clair", 50 }, { "Averse", 30 }, { "Brume", 20 } }
local graineRun, forcee = 0, nil :: string?
local derniere, serie = "Clair", 0

local function publier(meteo: string, jour: number)
	serie = if meteo == derniere then serie + 1 else 1
	derniere = meteo
	ReplicatedStorage:SetAttribute("MeteoEtat", meteo)
	ReplicatedStorage:SetAttribute("MeteoGraine", graineRun * 1000 + jour)
	ReplicatedStorage:SetAttribute("MeteoDebut", workspace:GetServerTimeNow()) -- signal client
end

function MeteoServeur.debutJour(jour: number)
	ReplicatedStorage:SetAttribute("JourNumero", jour)
	ReplicatedStorage:SetAttribute("JourDebut", workspace:GetServerTimeNow())
end

function MeteoServeur.demarrerRun(graine: number, meteoForcee: string?)
	graineRun, forcee, derniere, serie = graine, meteoForcee, "Clair", 0
	MeteoServeur.debutJour(1)
	publier("Clair", 1)
end

-- Premier instant du Répit qui précède `jour`
function MeteoServeur.planifierJour(jour: number)
	local meteo = "Clair"
	if jour % 5 == 0 then
		meteo = "Orage" -- Jour du Colosse
	elseif jour > 2 and jour % 5 ~= 4 then
		if forcee then
			meteo = forcee
		else
			local n = Random.new(graineRun * 1000 + jour):NextInteger(1, 100)
			for _, e in TIRAGE do
				n -= e[2]
				if n <= 0 then meteo = e[1] break end
			end
			if meteo == derniere and serie >= 2 then meteo = "Clair" end
		end
	end
	publier(meteo, jour)
end

return MeteoServeur
```

```lua
-- StarterPlayerScripts.MeteoClient (LocalScript, Prairie ; centre de la Prairie = origine)
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local C = require(ReplicatedStorage.Charte)
local joueur, camera = Players.LocalPlayer, workspace.CurrentCamera
local atmo = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local cc = Lighting:WaitForChild("CorrectionMeteo") :: ColorCorrectionEffect
local kit = ReplicatedStorage:WaitForChild("KitMeteo")
local function attr(nom: string): any return ReplicatedStorage:GetAttribute(nom) end

-- Density, Offset, Haze, Color, Decay, Saturation, Brightness
local P = {
	Clair = { 0.22, 0.30, 0.5, C.Creme, C.CremeOmbre, 0.10, 0 },
	Averse = { 0.34, 0.20, 1.2, C.ArdoiseLumiere, C.NuitLabo, -0.05, -0.04, pluie = true },
	Brume = { 0.42, 0.10, 2.0, C.Creme, C.ArdoiseLumiere, -0.02, 0.02, brume = true },
	Orage = { 0.36, 0.15, 1.5, C.ToitOrangeLumiere, C.VioletHordeOmbre, 0.05, -0.06, pluie = true, eclairs = true },
	Neige = { 0.30, 0.25, 1.0, C.Creme, C.NuitLaboLumiere, -0.08, 0.04, neige = true },
}
local voiles = { kit.VoileProche:Clone(), kit.VoileLoin:Clone() }
local emetteurs = kit.Emetteurs:Clone() -- Pluie1, Pluie2, Neige1, Neige2
voiles[1].Parent, voiles[2].Parent, emetteurs.Parent = camera, camera, camera
local brume = {}
for _, cube in CollectionService:GetTagged("BrumeCube") do brume[cube] = cube.CFrame end
local etat, eclairs, leger = P.Clair, {} :: { number }, false

local function tween(obj: Instance, props: { [string]: any }, duree: number?)
	TweenService:Create(obj, TweenInfo.new(duree or 8, Enum.EasingStyle.Sine), props):Play()
end

local function appliquer()
	etat = P[attr("MeteoEtat")] or P.Clair
	tween(atmo, { Density = etat[1], Offset = etat[2], Haze = etat[3], Color = etat[4], Decay = etat[5] })
	tween(cc, { Saturation = etat[6], Brightness = etat[7] })
	for i, v in voiles do
		tween(v.Texture, { Transparency = if etat.pluie and not (leger and i == 2) then 0.4 + 0.15 * i else 1 })
	end
	for _, pe in emetteurs:GetChildren() do
		if pe:IsA("ParticleEmitter") then
			pe.Enabled = not leger and (if pe.Name:find("Pluie") then etat.pluie else etat.neige) == true
		end
	end
	for _, f in CollectionService:GetTagged("Flaque") do
		tween(f, { Transparency = if etat.pluie then 0.45 else 1 })
	end
	local n = 0
	for cube in brume do
		n += 1
		tween(cube, { Transparency = if etat.brume and not (leger and n % 2 == 0) then 0.7 else 1 })
	end
	table.clear(eclairs) -- même calendrier sur tous les clients, jamais d'éclair passé
	if etat.eclairs then
		local rng, t = Random.new(attr("MeteoGraine")), attr("MeteoDebut") + 10
		for _ = 1, 12 do
			t += rng:NextNumber(10, 16)
			if t > workspace:GetServerTimeNow() then table.insert(eclairs, t) end
		end
	end
end

local function eclair()
	local son = kit.Tonnerre:Clone() -- chiptune, Volume 0.35, SoundGroup Ambiance
	son.Parent = camera
	son.Ended:Once(function() son:Destroy() end)
	task.delay(1.2, son.Play, son)
	if joueur:GetAttribute("EffetsReduits") then return end
	tween(cc, { Brightness = etat[7] + 0.25 }, 0.08)
	task.delay(0.08, tween, cc, { Brightness = etat[7] }, 0.35)
end

local function heure(jour: number, t: number): number
	if jour % 5 == 0 then return 17.5 end -- Jour du Colosse (canon)
	if t <= 80 then return 9 + 5.5 * t / 80 end
	local fin = if jour % 5 == 4 then 17.5 else 15.5
	return 14.5 + (fin - 14.5) * math.min((t - 80) / 15, 1)
end

local accu, mesure, images = 0, 0, 0
RunService.Heartbeat:Connect(function(dt)
	local maintenant = workspace:GetServerTimeNow()
	for i, v in voiles do
		v.CFrame = camera.CFrame * CFrame.new(0, 0, -12 * i)
		v.Texture.OffsetStudsV = (v.Texture.OffsetStudsV + dt * (42 - 12 * i)) % v.Texture.StudsPerTileV
	end
	local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
	if racine then emetteurs.CFrame = CFrame.new(racine.Position + Vector3.yAxis * 30) end
	if etat.brume then
		local rot = CFrame.Angles(0, maintenant * 2 / 87, 0) -- 2 studs/s à 87 studs du centre
		for cube, base in brume do cube.CFrame = rot * base end
	end
	if eclairs[1] and maintenant >= eclairs[1] then
		table.remove(eclairs, 1)
		eclair()
	end
	accu += dt
	if accu >= 0.25 then
		accu = 0
		local cible = heure(attr("JourNumero") or 1, maintenant - (attr("JourDebut") or maintenant))
		if math.abs(cible - Lighting.ClockTime) > 1 then -- fondu d'aube
			cc.Brightness = etat[7] - 0.3
			tween(cc, { Brightness = etat[7] }, 0.6)
		end
		Lighting.ClockTime = cible
	end
	if mesure < 5 then
		mesure += dt
		images += 1
		if mesure >= 5 and images / mesure < 27 then
			leger = true
			appliquer()
		end
	end
end)

ReplicatedStorage:GetAttributeChangedSignal("MeteoDebut"):Connect(function() task.defer(appliquer) end)
appliquer()
```

### 🌌 Artiste ciel & ambiance — Piotr Melnik
## 1. Principes d'ambiance

- **Le ciel se lit au sol.** Caméra `Scriptable` à (0, 45, 28), `FieldOfView` 50 : plongée de 58°, le haut de l'écran vise 33° sous l'horizon. En run, le `Sky` n'est jamais à l'écran. L'humeur passe par la couleur du soleil, les ombres et l'`Atmosphere`. Le `Sky` se voit au Laboratoire et dans les plans de caméra levée : atterrissage de la Capsule, annonce du Colosse, chute de la Maison.
- **Le soleil est un chronomètre.** Sa course pendant les 80 s de horde indique le temps restant sans passer par l'UI.
- **Le code couleur reste lisible à toute heure.** Le violet, l'or, le cyan et le rose-rouge restent reconnaissables à chaque moment. Avec un `ColorShift_Bottom` froid et un `OutdoorAmbient` haut, les ombres sont bleutées et jamais noires.
- **Nuit douce.** Bleu Nuit labo, `ExposureCompensation` à 0,4 et jamais plus de 5 s de nuit.
- **Aucune lumière ne clignote à plus de 3 Hz** (risque de photosensibilité).
- Les couleurs de lumière sont des mélanges de la palette. Elles sont rangées dans `ReplicatedStorage.Charte.Ambiances`. Jamais de #000000 ni de #FFFFFF.

## 2. Réglages fixes

- `Technology` ShadowMap, `GlobalShadows` true, `ShadowSoftness` 0,1 (ombres nettes, style blocky), `GeographicLatitude` 20 (soleil haut, ombres courtes), `ColorShift_Bottom` #2A3263.
- `EnvironmentDiffuseScale` 0,25 et `EnvironmentSpecularScale` 0,1 sur la Prairie. Au Laboratoire, 0,4 et 0,3 pour que les néons se reflètent sur l'Ardoise.
- `ColorCorrectionEffect` nommé « ColorCorrection » :
  - Prairie : Saturation 0,12, Contrast 0,06, `TintColor` #FFF8EE ;
  - Laboratoire : Saturation 0,1, Contrast 0,08, `TintColor` propre à chaque zone (§ 6).
- `BloomEffect` : Intensity 0,35, Size 16, Threshold 1,6 sur la Prairie ; Intensity 0,6, Size 20, Threshold 1,3 au Laboratoire. Seules les Parts Neon rayonnent.
- Interdits : `SunRaysEffect`, `DepthOfFieldEffect` et `Clouds` (nuages réalistes, hors style). `PointLight.Shadows` est à false partout.

## 3. Réglages par moment

Dans ce tableau, « Exposure » désigne `ExposureCompensation`. Les colonnes Density à Glare sont les propriétés de `Lighting.Atmosphere`.

| Moment | ClockTime | Brightness | Ambient | OutdoorAmbient | ColorShift_Top | Exposure | Density | Offset | Color | Decay | Haze | Glare |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Aube | 5,5 | 1,8 | #4E4570 | #B08AAE | #F6B08A | 0,25 | 0,38 | 0,1 | #F4C6C0 | #8E6FB0 | 2,0 | 0 |
| Matin | 8,5 | 2,6 | #4E4A66 | #A6A2C0 | #F9DDB8 | 0,1 | 0,32 | 0,1 | #E6DDF0 | #8C7FB8 | 1,2 | 0 |
| Midi | 12 | 3,0 | #56526A | #B2ACA0 | #F6E7C1 | 0 | 0,26 | 0,1 | #D8EEF4 | #7FA7C9 | 0,8 | 0 |
| Après-midi | 15,5 | 2,8 | #5A4E5E | #B8A38F | #F8D39A | 0 | 0,30 | 0,1 | #F3E2C4 | #C8894F | 1,2 | 0 |
| Coucher | 18,6 | 1,8 | #4A3F5C | #AE808E | #EF7A2F | 0,2 | 0,36 | 0,1 | #F2B48A | #6B5A8E | 1,8 | 0,3 |
| Nuit | 21 → 3 | 1,2 | #3A3F6E | #6E76B0 | #8FA3E0 | 0,4 | 0,34 | 0,1 | #535676 | #2A3263 | 1,0 | 0 |
| Jour du Colosse | 17,5 | 2,4 | #5A3F58 | #C49494 | #F0904C | 0,1 | 0,40 | 0,05 | #F6A57A | #CC254F | 2,2 | 0,4 |
| Laboratoire | 19,4 fixe | 1,5 | #3C4478 | #5B64A0 | #9FB0E8 | 0,3 | 0,30 | 0 | #535676 | #2A3263 | 0,5 | 0 |

- **Midi** est le moment le plus saturé : c'est le pique-nique.
- **Jour du Colosse** : à 17,5, le soleil n'est qu'à 7° au-dessus de l'horizon et l'ombre de la Maison s'étire sur plus de 100 studs. L'`OutdoorAmbient` le plus clair du cycle garde les Zbires lisibles dans cette ombre. Leurs ombres immenses apportent le drame sans faire peur. Le `Decay` utilise l'ombre de l'Alerte, car le rose-rouge signale le danger.

## 4. Cycle jour / nuit : 95 s

| Temps du jour | Phase | `ClockTime` | Moment | Signal |
|---|---|---|---|---|
| 0 s | Horde | 8,5 | Matin | Portails : `Brightness` de 1 à 2,5 en 2 s |
| 40 s | Horde | 12 | Midi | — |
| 80 s | Répit | 15,5 | Après-midi | Les fenêtres de la Maison passent au Toit orange |
| 86 s | Répit | 18,6 | Coucher | — |
| 88 à 91 s | Nuit express | 21 → 3 | Nuit | Étoiles et Lune défilent, la Mine devient le phare |
| 93 s | Répit | 5,5 | Aube | — |
| 95 s = 0 s | Jour suivant | 8,5 | Matin | Bannière « Jour X », coq 8-bit |

- `ClockTime` évolue linéairement sur une horloge déroulée (8,5 → 32,5, modulo 24). Les couleurs et les autres valeurs suivent une courbe `smoothstep`.
- La horde se joue entre 8,5 et 15,5. Le soleil reste au-dessus de 35° et les ombres ne dépassent pas 1,5 fois la hauteur des objets.
- **Jour du Colosse** (jours 5, 10, 15…) : de 0 à 4 s, le soleil file de 8,5 à 17,5. Cette course annonce le Colosse, quel que soit son moment d'apparition. `ClockTime` reste ensuite à 17,5 jusqu'à 80 s, puis le Répit se déroule normalement. *Écart mineur avec le canon : la valeur 17,5 est atteinte à 4 s et non à 0 s.*
- **Chute de la Maison** : l'horloge se fige et la `Saturation` descend à -0,25 en 1,5 s, sans aller jusqu'au gris total.
- **Autorité** : le serveur publie la chronologie sous forme d'attributs, et chaque client calcule son éclairage 20 fois par seconde. Après le chargement, le serveur n'écrit plus dans `Lighting` : la réplication écraserait le calcul local.

## 5. Le Sky retenu : « Ciel Pixel-bloc »

Chaque place a une instance `Sky` dans `Lighting`. Roblox assombrit la skybox la nuit, donc un seul jeu de textures couvre tout le cycle.

- `SkyboxBk/Dn/Ft/Lf/Rt/Up` : 6 textures de 1024² peintes en pixels de 16 px.
  - Prairie : dégradé en 6 bandes, de la Crème à l'horizon au Gemme cyan clair (#5AD9E7) au zénith. Nuages cubiques en Crème et Crème ombre (#C5B99A).
  - Laboratoire (« Ciel Labo ») : dégradé du Nuit labo à l'Encre claire (#49444B), étoiles en croix de 3 × 3 pixels et une comète cyan.
- `SunTextureId` : soleil carré Or cerclé de Toit orange, `SunAngularSize` 18.
- `MoonTextureId` : Lune carrée Crème aux cratères Crème ombre, `MoonAngularSize` 14 (16 au Laboratoire).
- `StarCount` : 1200 sur la Prairie, 2000 au Laboratoire. `CelestialBodiesShown` : true.

## 6. Humeur par zone

| Zone | Humeur | Réglages |
|---|---|---|
| Laboratoire | Repaire de savant un soir de bricolage | Moment Laboratoire, `TintColor` #E8F6FA. Arbre des Recherches : `PointLight` #33D6F0, Range 20, Brightness 1,5. Doc Boulon : #5AD9E7, Range 12, Brightness 1. Une bande Neon cyan au sol par Alcôve. À la fin d'une recherche, sa machine flashe 2 fois en Or à 1 Hz |
| Quai des Capsules | Gare futuriste, départ imminent | `TintColor` #F6EEDC. Une `PointLight` par Capsule (Range 14, Brightness 1,2) : Normale #33D6F0, Difficile #FF2E63, du Jour #FFC933. Pendant les 15 s avant le départ, elle pulse de 0,5 à 2 Hz |
| Galerie des Zbires | Musée rigolo en visite nocturne | `TintColor` #F6EAF4. 3 `SpotLight` #FFC933 (Angle 45, Range 18, Brightness 2, `Face` Bottom) éclairent les socles : des figurines violettes sous un projecteur or |
| Maison | Cocon chaleureux | Fenêtres Neon Crème, en Toit orange pendant le Répit. `PointLight` intérieure #FFB36B (Range 16, Brightness 1,2), lampe de porche #F6E7C1 (Range 10). Sous 25 % de PV, le porche passe en #FF2E63 et pulse à 1 Hz |
| Mine | Trésor | `PointLight` #33D6F0, Range 12, Brightness 1,8. Elle gagne 30 % pendant 0,3 s à chaque gemme produite |
| Prairie | Pique-nique qui tourne au chaos | Midi saturé aux ombres courtes. Jour du Colosse orangé aux ombres immenses |
| Lisière | Forêt de cubes mystérieuse sans faire peur | L'`Atmosphere` adoucit l'anneau de 70 à 100 studs. 4 `PointLight` de portail #9B5DE5, Range 14, Brightness de 1 à 2,5 pendant 2 s à chaque début de horde. Le `ColorShift_Bottom` évite les ombres noires sous les arbres-cubes |

Le samedi de 16 h 45 à 17 h 15 (heure de Paris), le serveur du Laboratoire active l'attribut `ZbireDeLaSemaine`. La `TintColor` passe alors à #EFE3FB et les néons cyan virent au Violet horde.

## 7. Budget lumières

- **Prairie (12 lumières)** :
  - Maison : 2 ;
  - Mine : 1 ;
  - portails : 4 ;
  - Établi : 1 (#F0904C, Range 10) ;
  - Colosse : 1, les Jours du Colosse seulement ;
  - réserve : 3 éclats de 0,3 s maximum, recyclés.
- **Laboratoire (12 lumières)** :
  - Arbre des Recherches : 1 ;
  - Doc Boulon : 1 ;
  - Capsules : 3 ;
  - Galerie : 3 `SpotLight` ;
  - réserve : 4.
- **Neon d'ambiance sur la Prairie** : 32 Parts sur les 150 autorisées (6 fenêtres, 10 gemmes de la Mine, 16 pour les portails).

## 8. Code

```lua
-- ReplicatedStorage.Charte (extrait) : couleurs de lumière et cycle du jour
local hex = Color3.fromHex

local function moment(brightness, ambient, outdoor, top, exposure, density, offset, color, decay, haze, glare)
	return {
		Brightness = brightness, Ambient = hex(ambient), OutdoorAmbient = hex(outdoor),
		ColorShift_Top = hex(top), ExposureCompensation = exposure,
		Density = density, Offset = offset, Color = hex(color), Decay = hex(decay),
		Haze = haze, Glare = glare,
	}
end

Charte.Ambiances = {
	Aube = moment(1.8, "4E4570", "B08AAE", "F6B08A", 0.25, 0.38, 0.1, "F4C6C0", "8E6FB0", 2.0, 0),
	Matin = moment(2.6, "4E4A66", "A6A2C0", "F9DDB8", 0.1, 0.32, 0.1, "E6DDF0", "8C7FB8", 1.2, 0),
	Midi = moment(3.0, "56526A", "B2ACA0", "F6E7C1", 0, 0.26, 0.1, "D8EEF4", "7FA7C9", 0.8, 0),
	ApresMidi = moment(2.8, "5A4E5E", "B8A38F", "F8D39A", 0, 0.30, 0.1, "F3E2C4", "C8894F", 1.2, 0),
	Coucher = moment(1.8, "4A3F5C", "AE808E", "EF7A2F", 0.2, 0.36, 0.1, "F2B48A", "6B5A8E", 1.8, 0.3),
	Nuit = moment(1.2, "3A3F6E", "6E76B0", "8FA3E0", 0.4, 0.34, 0.1, "535676", "2A3263", 1.0, 0),
	Colosse = moment(2.4, "5A3F58", "C49494", "F0904C", 0.1, 0.40, 0.05, "F6A57A", "CC254F", 2.2, 0.4),
	Laboratoire = moment(1.5, "3C4478", "5B64A0", "9FB0E8", 0.3, 0.30, 0, "535676", "2A3263", 0.5, 0),
}

local FIN_DE_JOUR = {
	{ t = 86, clock = 18.6, moment = "Coucher" },
	{ t = 88, clock = 21, moment = "Nuit" },
	{ t = 91, clock = 27, moment = "Nuit" },
	{ t = 93, clock = 29.5, moment = "Aube" },
	{ t = 95, clock = 32.5, moment = "Matin" },
}

local function cycle(debut)
	local cles = table.clone(debut)
	for _, cle in FIN_DE_JOUR do
		table.insert(cles, cle)
	end
	return cles
end

Charte.DUREE_JOUR = 95
Charte.CycleJour = {
	Normal = cycle({ { t = 0, clock = 8.5, moment = "Matin" }, { t = 40, clock = 12, moment = "Midi" }, { t = 80, clock = 15.5, moment = "ApresMidi" } }),
	Colosse = cycle({ { t = 0, clock = 8.5, moment = "Matin" }, { t = 4, clock = 17.5, moment = "Colosse" }, { t = 80, clock = 17.5, moment = "Colosse" } }),
}
```

```lua
-- ServerScriptService.DirecteurDeRun (extrait) : le serveur possède le temps
local function commencerJour(numero: number)
	workspace:SetAttribute("JourNumero", numero)
	workspace:SetAttribute("JourColosse", numero % 5 == 0)
	workspace:SetAttribute("JourDebut", workspace:GetServerTimeNow())
end
-- À la chute de la Maison : workspace:SetAttribute("MaisonTombee", true)
```

```lua
-- StarterPlayer.StarterPlayerScripts.CycleCiel (LocalScript, place Prairie)
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local atmosphere = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local correction = Lighting:WaitForChild("ColorCorrection") :: ColorCorrectionEffect

local PROPS_LIGHTING = { "Brightness", "Ambient", "OutdoorAmbient", "ColorShift_Top", "ExposureCompensation" }
local PROPS_ATMOSPHERE = { "Density", "Offset", "Color", "Decay", "Haze", "Glare" }
local PAS = 1 / 20

local function melange(a, b, k)
	if typeof(a) == "Color3" then
		return a:Lerp(b, k)
	end
	return a + (b - a) * k
end

local function appliquer(a, b, k)
	for _, nom in PROPS_LIGHTING do
		Lighting[nom] = melange(a[nom], b[nom], k)
	end
	for _, nom in PROPS_ATMOSPHERE do
		atmosphere[nom] = melange(a[nom], b[nom], k)
	end
end

local function mettreAJour()
	local debut = workspace:GetAttribute("JourDebut")
	if not debut or workspace:GetAttribute("MaisonTombee") then
		return
	end
	local t = math.clamp(workspace:GetServerTimeNow() - debut, 0, Charte.DUREE_JOUR)
	local cles = if workspace:GetAttribute("JourColosse") then Charte.CycleJour.Colosse else Charte.CycleJour.Normal
	for i = 1, #cles - 1 do
		local a, b = cles[i], cles[i + 1]
		if t <= b.t then
			local k = (t - a.t) / (b.t - a.t)
			Lighting.ClockTime = (a.clock + (b.clock - a.clock) * k) % 24
			appliquer(Charte.Ambiances[a.moment], Charte.Ambiances[b.moment], k * k * (3 - 2 * k))
			return
		end
	end
end

local cumul = 0
RunService.Heartbeat:Connect(function(dt)
	cumul += dt
	if cumul >= PAS then
		cumul = 0
		mettreAJour()
	end
end)

workspace:GetAttributeChangedSignal("MaisonTombee"):Connect(function()
	if workspace:GetAttribute("MaisonTombee") then
		TweenService:Create(correction, TweenInfo.new(1.5), { Saturation = -0.25 }):Play()
	end
end)

-- État d'attente avant le premier jour (atterrissage de la Capsule)
Lighting.ClockTime = 8.5
appliquer(Charte.Ambiances.Matin, Charte.Ambiances.Matin, 0)
```

## 9. Recette

- **Planche de contrôle** : les 8 Zbires, une pièce et une gemme posés sur la Prairie, capturés aux 7 moments. 5 testeurs de 9 à 13 ans doivent nommer chaque couleur codée sans erreur.
- **Performance** : sur Android 3 Go, avec 6 joueurs et 60 Zbires un Jour du Colosse, le jeu tient 30 FPS. Au MicroProfiler, `CycleCiel` prend moins de 0,2 ms par mise à jour. Si la cible n'est pas tenue, le Bloom est coupé en premier.
- **Sécurité visuelle** : chaque lumière qui pulse est mesurée et ne dépasse pas 3 Hz.

### 🏜️ Designer de biomes — Judith Alba
## 1. Règles communes à tous les biomes

- **Aucun Terrain.** Parts ancrées en `SmoothPlastic`, décor sur grille de 1 stud, bâtiments sur grille de 4 studs. Décor non bloquant : `CanCollide`, `CanQuery`, `CanTouch` = `false` ; `CastShadow = false` sous 1 stud de haut.
- **Couleurs** tirées de `ReplicatedStorage.Charte` (base, ombre × 0,8, lumière + 20 % de Crème). Le décor ne prend jamais l'Or (réservé aux pièces). Le cyan reste à la Mine et au Laboratoire, le violet à la Lisière, l'Alerte aux dangers.
- **Fenêtre caméra.** Avec le décalage (0, 45, 28) et un `FieldOfView` de 50, un téléphone en paysage montre environ 88 studs de large, 41 studs devant le Survivant et 23 derrière. Chaque biome doit se reconnaître dans cette fenêtre : un repère au moins tous les 30 studs.
- **Les transitions se font par tramage.** Aucune frontière nette : un biome passe à l'autre par un motif de Bayer 4 × 4, en tuiles de 2 × 0,2 × 2 studs, sur 6 à 10 studs de large. On pose le disque du biome intérieur, puis des tuiles du biome extérieur, de plus en plus serrées. C'est la signature pixel art de Zsurvie (script au §6).

## 2. La run : une cible concentrique

La Maison est centrée sur l'origine, sol à Y = 0. Sa porte est au sud (+Z), face à la caméra.

| Bande (rayon) | Biome | Hauteur max | Parts |
|---|---|---|---|
| carré 16 × 16 | La Maison | 14 (canon) | 600 |
| 8 → 18 | Jardinet (transition) | 2 | 250 |
| centre (24, 0, −24) | La Mine et son carreau | 6 | 150 |
| 18 → 60 | La Prairie : 4 chemins de 8 studs, 4 quartiers | 6 | 1 900 |
| 60 → 70 | Orée (transition) | 8 | 400 |
| 70 → 100 | La Lisière et ses portails | 10 à 18 | 2 300 |
| 100 → bord | Fond | 20 | 400 |

Le décor prend 6 000 Parts. Les 4 000 restantes vont aux 60 Zbires (1 800), au Colosse, aux Survivants, aux 18 défenses et aux éclats. Budget du décor : 50 `Neon` sur 150, 6 `PointLight` sur 12, 6 sons sur 16.

**Lecture du canon.** Je lis « la Mine à 12 studs de la Maison » comme 12 studs de vide entre le mur et la Mine (8 × 8), soit un vrai couloir de course. Jardinet, Orée, Fond et les quartiers sont des noms de travail internes, jamais affichés au joueur.

## 3. Identité des biomes de la run

### La Maison et le Jardinet : « Je suis chez moi, je la protège »
- Sol en dalles Crème de 4 × 4, joints Crème ombre #C5B99A. L'herbe gagne sur les dalles par un tramage entre 12 et 18 studs.
- Pots de fleurs Toit orange de 1 × 1 × 1 et haie basse Prairie lumière #88C962. La Capsule d'arrivée (Toit orange, 6 studs) est posée au sud de la porte : le lien avec le Laboratoire se voit dès la première image.
- 6 fenêtres `Neon` Crème et une lanterne de porche : `PointLight` Crème, `Range` 14, `Brightness` 1,5. La lanterne ne s'allume qu'au Jour du Colosse.
- Pas de boucle sonore propre : le calme du centre tranche avec l'agitation de la périphérie.

### La Mine : « Un trésor qui brille, je veux le surveiller »
- Carreau d'Ardoise, avec un tramage d'herbe de 6 à 10 studs autour du centre. Rails Ardoise ombre #3B374D jusqu'à la porte, 2 wagonnets Terre battue.
- Rochers-cubes Ardoise et Ardoise lumière #6C6573, sommet à 6 studs au plus.
- 12 cubes `Neon` Gemme cyan, les seuls en cyan de la Prairie. Une `PointLight` cyan (`Range` 14, `Brightness` 1,2) et un `ParticleEmitter` d'étincelles (`Rate` 4).
- Carillon chiptune positionnel : `RollOffMaxDistance` 30, `Volume` 0,4.

### La Prairie : « Un pique-nique géant, on court partout »
- Sol Prairie parsemé d'environ 250 touffes Prairie lumière de 1 × 1 × 1.
- Chemins en Terre battue, bordés d'herbe tramée sur 1 stud. Au-delà de 50 studs, ils passent en Terre battue ombre #A06E3F. Dans l'Orée, des empreintes Violet horde ombre #7C4AB7 de 1 × 1 disent : « c'est par là qu'ils arrivent ».
- 4 quartiers d'orientation, pour que le ping « Ici ! » ait un sens sans chat :

| Quartier | Repère (6 studs au plus) | Accent |
|---|---|---|
| Nord-ouest : Verger | Pommiers-cubes de 5 studs (tronc 2, houppier 3 × 3 × 3) | Pommes Toit orange |
| Nord-est : Carreau | La Mine, les rails, les wagonnets | Gemme cyan |
| Sud-est : Potager | Sillons Terre battue, citrouilles de 2 × 2 × 2 | Toit orange ombre #BF6226 |
| Sud-ouest : Pique-nique | Nappes à carreaux de 6 × 6, paniers, parasols de 5 studs | Crème et Toit orange |

- **Le chaos progresse** avec les jours. Après chaque Colosse (jours 5, 10 et 15), le serveur renverse les props tagués `Chaos1`, `Chaos2` puis `Chaos3` (`CollectionService`) : nappes froissées, paniers retournés, pommes au sol. Il suffit d'environ 30 changements de `CFrame` par palier, sans ajouter de Part.

### L'Orée (60 → 70 studs) : « Le calme s'arrête ici »
- Tramage de la Prairie vers Prairie ombre #569B3B.
- Buissons-cubes de 2, 3 puis 4 studs, en escalier vers l'extérieur. Les premiers arbres (6 à 8 studs) apparaissent à 66 studs.
- Proposition : des murs invisibles fixent la limite jouable à 72 studs. Entre 70 et 74 studs, les troncs font un obstacle naturel.

### La Lisière (70 → 100 studs) : « Mystérieux, mais j'ai envie d'y jeter un œil »
- Environ 500 arbres-cubes de 4 Parts chacun. Tronc 2 × h × 2 en Terre battue ombre. Houppier de 2 ou 3 cubes de 4 × 4 × 4, en Prairie et Prairie ombre alternés. Le sol reste Prairie ombre, jamais Encre.
- **Décor de théâtre.** Au sud, côté caméra, les arbres font 10 studs au plus pour ne jamais masquer un Survivant. À l'est et à l'ouest : 14 studs au plus. Au nord, en fond d'image : 18 studs au plus.
- **Contamination douce.** À moins de 12 studs d'un portail, le cube du sommet des arbres passe en Violet horde ombre. Des champignons-cubes Violet horde lumière #AD79DE poussent au sol.
- **Portails.**
  - 4 grands dans l'axe des chemins, à r = 84 : arche Ardoise de 12 × 10, cœur `Neon` Violet horde lumière (5 `Neon`), `PointLight` de `Range` 16.
  - 4 petits en diagonale, à r = 80 : arche de 6 × 6, 3 `Neon`.
  - Chaque portail émet des cubes violets : `ParticleEmitter` avec `Rate` 12 et `Lifetime` 1,2.
  - Les 4 grands bourdonnent, en son positionnel avec `RollOffMaxDistance` 35.
- **Fond** (au-delà de 100 studs) : falaises-cubes Ardoise et Encre lumière #49444B de 12 à 20 studs, qui ferment l'horizon.

### Le Jour du Colosse : « Le grand moment, épique sans faire peur »
Ce n'est pas une zone, mais un état de la Prairie. `ClockTime` passe à 17,5 : lumière rasante orange, ombres violettes. Les fenêtres et la lanterne s'allument, et une basse chiptune lente remplace les oiseaux.

## 4. Les trois états de la Prairie

`Lighting.Ambient` reste fixé à Ardoise lumière. Le serveur se contente d'écrire `workspace:SetAttribute("EtatPrairie", ...)` avec la valeur `Horde`, `Repit` ou `Colosse`, et ne touche jamais à `Lighting`. Il passe à `Colosse` dès le Répit qui précède le Jour du Colosse.

| Propriété | Horde | Répit (15 s) | Colosse |
|---|---|---|---|
| Ressenti | Action joyeuse | On souffle, on répare | Tension épique |
| `ClockTime` | 14 | 14 | 17,5 |
| `Brightness` | 2,5 | 2,8 | 2 |
| `OutdoorAmbient` | Crème ombre | Crème ombre | Violet horde ombre |
| `ColorShift_Top` | Crème | Crème | Toit orange |
| `Atmosphere.Density` | 0,2 | 0,15 | 0,3 |
| `ColorCorrectionEffect.Saturation` | 0,15 | 0,25 | 0,2 |
| `Transparency` des `Neon` des portails | 0 | 0,6, particules coupées | 0 |
| Boucle d'ambiance | Tambours chiptune | Oiseaux 8-bit | Basse lente |

À préparer dans Studio :
- dans `SoundService`, 3 `Sound` en `Looped` : `BoucleHorde`, `BoucleRepit` et `BoucleColosse` ;
- dans `Lighting`, un `ColorCorrectionEffect` nommé `CorrectionBiome`.

```lua
-- StarterPlayerScripts > AmbianceBiomes (LocalScript, place Prairie). Purement cosmétique.
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local c = Charte.couleur -- c(nom, "base" | "ombre" | "lumiere") : Color3

local atmosphere = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local correction = Lighting:WaitForChild("CorrectionBiome") :: ColorCorrectionEffect
local portails = workspace:WaitForChild("Lisiere"):WaitForChild("Portails")
local NEUTRE = Color3.new(1, 1, 1)

local ETATS = {
	Horde = {
		duree = 2, son = "BoucleHorde", portail = 0,
		lighting = { ClockTime = 14, Brightness = 2.5, OutdoorAmbient = c("Creme", "ombre"), ColorShift_Top = c("Creme", "base") },
		atmo = { Density = 0.2, Color = c("Creme", "base"), Decay = c("Prairie", "lumiere") },
		cc = { Saturation = 0.15, Brightness = 0, TintColor = NEUTRE },
	},
	Repit = {
		duree = 1.5, son = "BoucleRepit", portail = 0.6,
		lighting = { ClockTime = 14, Brightness = 2.8, OutdoorAmbient = c("Creme", "ombre"), ColorShift_Top = c("Creme", "base") },
		atmo = { Density = 0.15, Color = c("Creme", "base"), Decay = c("Prairie", "lumiere") },
		cc = { Saturation = 0.25, Brightness = 0.05, TintColor = NEUTRE },
	},
	Colosse = {
		duree = 4, son = "BoucleColosse", portail = 0,
		lighting = { ClockTime = 17.5, Brightness = 2, OutdoorAmbient = c("VioletHorde", "ombre"), ColorShift_Top = c("ToitOrange", "base") },
		atmo = { Density = 0.3, Color = c("ToitOrange", "lumiere"), Decay = c("VioletHorde", "base") },
		cc = { Saturation = 0.2, Brightness = 0, TintColor = NEUTRE:Lerp(c("ToitOrange", "base"), 0.12) },
	},
}

local function tween(objet: Instance, duree: number, props: { [string]: any }): Tween
	local t = TweenService:Create(objet, TweenInfo.new(duree, Enum.EasingStyle.Sine), props)
	t:Play()
	return t
end

local boucleActive: Sound? = nil

local function appliquer(nom: any)
	local etat = ETATS[nom] or ETATS.Horde
	tween(Lighting, etat.duree, etat.lighting)
	tween(atmosphere, etat.duree, etat.atmo)
	tween(correction, etat.duree, etat.cc)
	for _, objet in portails:GetDescendants() do
		if objet:IsA("BasePart") and objet.Material == Enum.Material.Neon then
			tween(objet, etat.duree, { Transparency = etat.portail })
		elseif objet:IsA("ParticleEmitter") then
			objet.Enabled = etat.portail < 0.5
		end
	end
	local nouvelle = SoundService:FindFirstChild(etat.son) :: Sound?
	if nouvelle == boucleActive then return end
	local ancienne = boucleActive
	boucleActive = nouvelle
	if ancienne then
		tween(ancienne, 1.5, { Volume = 0 }).Completed:Once(function()
			if ancienne ~= boucleActive then ancienne:Stop() end
		end)
	end
	if nouvelle then
		nouvelle.Volume = 0
		nouvelle:Play()
		tween(nouvelle, 1.5, { Volume = 0.3 })
	end
end

appliquer(workspace:GetAttribute("EtatPrairie"))
workspace:GetAttributeChangedSignal("EtatPrairie"):Connect(function()
	appliquer(workspace:GetAttribute("EtatPrairie"))
end)
```

## 5. Le lobby : trois ambiances dans une seule place

Réglages communs de `Lighting` : `ClockTime` 0, `Sky.StarCount` 3000, `Ambient` et `OutdoorAmbient` en Nuit labo lumière #535676, `Brightness` 1. La rotonde du Laboratoire n'a pas de plafond (murs de 16 studs) : la caméra ne s'y coince jamais.

| Zone | Ressenti | Sol et murs | Accents et lumière | Son | Neon |
|---|---|---|---|---|---|
| Le Laboratoire | Fierté et curiosité : « mon Alcôve montre mes inventions » | Damier 4 × 4 Ardoise et Ardoise ombre, murs Nuit labo | Bandeau `Neon` cyan en haut des murs ; sol des Alcôves en Crème pour détacher les machines ; 6 `PointLight` cyan | Ronron de machines, bips | 70 |
| Le Quai des Capsules | Élan : « on part ensemble » | Quai Ardoise lumière, voies Encre lumière | Capsule Normale Toit orange, Difficile Alerte, du Jour Gemme cyan (elle rapporte des gemmes) ; 3 `PointLight` | Jingle de gare, 3 notes à chaque départ | 40 |
| La Galerie des Zbires | Rire et collection | Parquet Terre battue lumière #D19C66 en planches de 1 × 4, murs Crème | Socles Violet horde ombre ; liseré de palier Crème à 10 éliminations, Toit orange à 100, `Neon` cyan à 1 000 (jamais d'Or) ; 3 `PointLight` Crème | Boîte à musique 8-bit | 30 |

Il reste 10 `Neon` en réserve.

**Transitions du lobby.** Entre deux zones, un sas de 12 studs avec un sol tramé et une arche de 8 studs. Un dossier `ZonesLobby` contient 3 boîtes invisibles. Toutes les 0,25 s, le client compare `boite.CFrame:PointToObjectSpace(racine.Position)` à la moitié de `Size`. En changeant de zone, il fait glisser en 1,5 s le `TintColor` (Laboratoire : neutre + 8 % de cyan ; Galerie : neutre + 10 % de Crème) et fond les boucles d'ambiance.

**Du Laboratoire à la Prairie.** `TeleportService:SetTeleportGui` affiche un écran Nuit labo avec une Capsule en pixels. À l'arrivée, la même Capsule attend dans le Jardinet.

## 6. Générer les tramages (barre de commande Studio)

```lua
-- Mode édition. Tramage Bayer 4×4 en tuiles 2×2 : densité 0 % à rMin, 100 % à rMax.
-- Les chemins (|x| ou |z| < 4) restent nus.
local Charte = require(game:GetService("ReplicatedStorage").Charte)
local BAYER = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 }

local function tramer(nom: string, centre: Vector3, rMin: number, rMax: number, couleur: Color3, parent: Instance)
	local dossier = Instance.new("Folder")
	dossier.Name = nom
	local total = 0
	for gx = -rMax, rMax - 2, 2 do
		for gz = -rMax, rMax - 2, 2 do
			local x, z = centre.X + gx + 1, centre.Z + gz + 1
			local t = (math.sqrt((gx + 1) ^ 2 + (gz + 1) ^ 2) - rMin) / (rMax - rMin)
			local seuil = (BAYER[((gz // 2) % 4) * 4 + (gx // 2) % 4 + 1] + 0.5) / 16
			local surChemin = math.abs(x) < 4 or math.abs(z) < 4
			if t >= 0 and t < 1 and t > seuil and not surChemin then
				local tuile = Instance.new("Part")
				tuile.Anchored = true
				tuile.CanCollide, tuile.CanQuery, tuile.CanTouch, tuile.CastShadow = false, false, false, false
				tuile.Material = Enum.Material.SmoothPlastic
				tuile.Color = couleur
				tuile.Size = Vector3.new(2, 0.2, 2)
				tuile.Position = Vector3.new(x, centre.Y + 0.1, z)
				tuile.Parent = dossier
				total += 1
			end
		end
	end
	dossier.Parent = parent
	print(nom, total, "tuiles")
end

local decor = workspace:WaitForChild("Decor")
tramer("Tramage_Jardinet", Vector3.zero, 12, 18, Charte.couleur("Prairie", "base"), decor)
tramer("Tramage_Carreau", Vector3.new(24, 0, -24), 6, 10, Charte.couleur("Prairie", "base"), decor)
tramer("Tramage_Oree", Vector3.zero, 60, 70, Charte.couleur("Prairie", "ombre"), decor)
```

Les trois tramages doivent rester sous 350 tuiles au total (estimation : 70 pour le Jardinet, 25 pour le Carreau, 215 pour l'Orée).

## 🏗️ Construction & Modélisation

### 🏛️ Architecte — Armand Solère
# Zsurvie · Bâtiments et structures clés

*Armand Solère, Construction & Modélisation. Cotes en studs, sol à Y = 0, nord = −Z.*

## 1. Règles d'échelle

| Règle | Valeur |
|---|---|
| Survivant (R15) | ≈ 5 studs, référence de toutes les cotes |
| Grille des bâtiments | 4 studs : les bords des socles tombent sur des multiples de 4 |
| Portes | 4 × 8 au lobby, 4 × 6 sur la Maison (décor) |
| Lobby | Hauteur libre ≥ 16 pour la caméra `Classic`, passages de 12 |
| Façades | Tournées vers +Z, car la caméra de run (0, 45, 28) regarde vers −Z |
| Règle des 6 studs | Mesurée depuis le centre de la Maison. La Maison (14 studs, canon) est la seule exception |
| « À 12 studs de la Maison » | 12 studs libres entre le mur est et la Mine |

## 2. La Prairie : plan de masse

L'origine est le centre de la Maison. L'arène fait 220 × 220.

| Structure | Centre (X, Z) | Emprise | Haut. max | Fonction |
|---|---|---|---|---|
| Maison | (0, 0) | 16 × 16 | 14 | Cible des Zbires |
| Parvis | (0, 0) | 24 × 24 | 0,2 | Zone de réparation visible |
| Mine | (26, −14) | 12 × 12 | 6 | Gemmes en continu |
| Établi | (−22, 16) | 12 × 8 | 6 | Améliorations |
| Apparition | (0, 20) | 8 × 8 | 0,5 | `SpawnLocation`, `Neutral` = true |
| 4 chemins | Axes X et Z, de r = 12 à 72 | 8 de large | 0,2 | Terre battue |
| 3 pique-niques | (−40, −30), (38, 32), (−36, 44) | 8 × 8 | 3 | Décor, `CanCollide` false |
| Barrière | Cercle r = 72 | 24 segments | 12 | Invisible, `CanQuery` false |
| 8 portails violets | r = 86, tous les 45° | 12 × 2 | 14 | Apparition des Zbires |
| Portail nord | (0, −86) | 20 × 4 | 24 | Agrandi pour le Colosse |
| Lisière | Anneau 72 → 100 | — | 6 à 20 | Forêt de cubes |
| Fond | Anneau 100 → 110 | — | 24 au nord, 4 au sud | Horizon |

### La Maison · « Cocon chaleureux »

- **Volumes :**
  - socle Ardoise 16 × 1 × 16 ;
  - murs Crème de Y 1 à 8, avec des chaînages orange aux angles ;
  - toit Toit orange en 4 gradins de 1 stud (16, 12, 8 et 4 de côté), de Y 8 à 12 ;
  - cheminée 2 × 2 × 2 de Y 12 à 14.
- **Silhouette :** vue d'en haut, une cible de carrés orange emboîtés, lisible même au zoom minimum.
- **Façade :** porte 4 × 6 face à +Z, 4 fenêtres 4 × 3 en `Neon` Or et 1 `PointLight` Or (`Range` 14). La lueur chaude porte le Jour du Colosse.
- **Tourelle de toit :** une tourelle 4 × 2 × 4 remplace la cheminée. Le sommet reste à Y 14.
- **Record :** la Part `AncreRecord` (invisible, dans le Model) en (0, 18, 0) porte le `BillboardGui` « Record : Jour X ».
- **3 états**, sur des seuils proposés de > 60 %, 31 à 60 % et ≤ 30 % des PV :
  - *Intacte* ;
  - *Abîmée* : planches clouées, 2 blocs de toit tombés ;
  - *Critique* : moitié du toit en cubes au sol, fumée de cubes Ardoise (`Rate` 8).
- **Échange des états :** chaque état est un Model de 80 Parts au plus. Un seul est dans `Workspace`, les autres attendent dans `ServerStorage.EtatsMaison`.

### La Mine · « Trésor, lueur cyan »

- **Butte :** Ardoise en 3 gradins de 1 stud (12, 8 et 4 de côté). L'entrée de galerie 4 × 3, étayée, fait face à +Z.
- **Cristaux :** 8 cristaux `Neon` Gemme cyan 1 × 2,5 × 1, inclinés de 15°. 1 `PointLight` cyan (`Range` 16, `Brightness` 1,5).
- **Abords :** un wagonnet sur 8 studs de rails tournés vers la Maison.
- **Foreuse :** si un Survivant l'a recherchée, une tête 2 × 3 × 2 tourne au sommet, jusqu'à Y 6.
- **Silhouette :** une montagne grise hérissée de cyan, seule structure cyan de la Prairie.

### L'Établi · « À nous »

- **Structure :** comptoir Terre battue 12 × 3 × 4, à hauteur de coude, sous un auvent rayé orange et crème (de Y 5 à 6). Enseigne en forme de clé à molette 3 × 3 en Or.
- **Casiers :** 8 casiers d'icônes, un par amélioration. 1 `PointLight` Or (`Range` 12).
- **Usage :** un bouton de 60 px apparaît à moins de 10 studs. Le serveur revérifie la distance (≤ 12) et le solde.
- **Silhouette :** le seul toit plat de la Prairie.

### Portails et Lisière · « Mystérieuse sans faire peur »

- **Portail :** 2 piliers Ardoise 2 × 14 × 2, un linteau et un voile `Neon` Violet horde 8 × 10 × 0,4. Un `ParticleEmitter` lâche des cubes violets (`Rate` 10). Seuls les 4 portails cardinaux ont une `PointLight`.
- **Portail nord :** voile 16 × 20, à `Transparency` 1 sauf le Jour du Colosse.
- **Arbres-cubes :** tronc 2 × 4 × 2, surmonté de 1 à 3 cubes de feuillage de 6 en Prairie ombre ou lumière. Quelques champignons cubes violets.
- **Plafond sud :** vue de la caméra, la ligne vers les pieds d'un Survivant monte de 1,6 stud par stud.
  - Au sud (Z > 0), un objet respecte hauteur ≤ 1,6 × d, où d est l'écart en Z entre sa face nord et la barrière. Pour d = 4, 8 et 12 : 6, 12 et 20 studs.
  - Au nord, les arbres font de 10 à 20 studs, sans contrainte.

### Défenses posables

| Défense | Dimensions | Parts max | Lecture |
|---|---|---|---|
| Muret | 8 × 3 × 2 | 12 | Plus bas qu'un Survivant, le Volant le survole |
| Mini-Tourelle | 4 × 5 × 4 | 20 | Tête crème pivotante |
| Tapis Collant | 8 × 0,2 × 8 | 4 | Crème à pois orange |

Le serveur valide chaque pose : entre le parvis et r = 64, à plus de 4 studs de la Mine, de l'Établi et de l'apparition.

## 3. Le Laboratoire : plan de masse (`MaxPlayers` 12)

L'origine est le centre de la Rotonde.

| Structure | Centre (X, Z) | Emprise | Haut. | Fonction |
|---|---|---|---|---|
| Rotonde | (0, 0) | Ø 80 intérieur, 112 extérieur | Murs 16, dôme 34 | Cœur du lobby |
| Arbre des Recherches | (0, 0) | 12 × 12 | 30, antenne 44 | Interface des recherches |
| Podium de Doc Boulon | (12, 0) | 8 × 8 × 1 | — | Tutoriel, face à l'est |
| 12 Alcôves | Anneau r 40 → 56 | 12 × 16 | 16 | Machines de recherche |
| Sas d'arrivée* (est) | (48, 0) | 12 de large | 16 | `SpawnLocation` face au centre |
| Quai des Capsules (sud) | (0, 86) | 64 × 28 | Tubes 40 | Départ des runs |
| Galerie des Zbires (nord) | (0, −88) | 48 × 32 | 16 | Musée |
| Balcon des Rendez-vous* (ouest) | (−64, 0) | 16 × 16 | 16 | Défi du Jour, Zbire de la Semaine |

\* Noms de travail hors canon, à valider par Victor Lanoue.

### Rotonde et Arbre des Recherches · « Repaire de savant »

- **Travées :** 16 travées de 22,5°, soit 12 Alcôves (3 par quart) et 4 passages cardinaux. Chaque pilier Ardoise 4 × 16 × 4 porte un filet `Neon` cyan.
- **Dôme :** Nuit labo, en 5 anneaux-gradins de 4 studs, avec un oculus de Ø 16. Sa silhouette pixelisée se reconnaît depuis le Quai.
- **Arbre :**
  - tronc 8 × 30 × 8 et jusqu'à 24 nœuds cubes 2 × 2 × 2, un par recherche ;
  - un nœud passe en `Neon` cyan côté client quand le joueur possède la recherche (visuel seul) ;
  - une antenne coiffée d'une boule `Neon` à Y 44 se voit dans l'oculus.
- **Accès :** 4 `ProximityPrompt`, une par face, avec `MaxActivationDistance` 12 et `HoldDuration` 0.

### Les Alcôves · « Visibles par tous »

- **Volume :** 12 × 16 × 16, sol surélevé de 1 stud.
- **Socles :** 6 socles 3 × 3 au pas de 4 : Tourelle de toit, Balles perforantes, Visée critique, Foreuse, et 2 en réserve.
- **Machines :** 30 Parts et 10 studs au plus, animation élastique côté client.
- **Attribution :** le serveur attribue l'Alcôve au `PlayerAdded` (attribut `Proprietaire` = UserId). Une plaque `SurfaceGui` affiche le nom du joueur.

### Le Quai des Capsules · « Gare futuriste »

- **Capsules :** 3 Capsules octogonales Ø 12 × 16, en X = −20, 0 et 20 (Z = 90), chacune avec 6 sièges.
  - Normale : Crème et Toit orange.
  - Difficile : Alerte.
  - du Jour : Gemme cyan.
- **Départ :** chaque Capsule monte dans un tube transparent de Ø 14 qui s'élève jusqu'à Y 40 (tween client), pendant que le serveur téléporte.
- **Embarquement :** une dalle 8 × 8 devant chaque porte, testée par le serveur toutes les 0,5 s avec `workspace:GetPartBoundsInBox`. Il n'y a aucun bouton à viser.
- **Panneau :** un `SurfaceGui` affiche « 3/6 · départ 12 s ».

### La Galerie des Zbires · « Musée rigolo »

- **Entrée :** une arche Violet horde, seul violet du lobby.
- **Piédestaux :** 8 de 6 × 6 × 2 portent des figurines à l'échelle 1,5. Les Mini-Gluants partagent le piédestal du Gluant. Au fond, le Colosse se dresse sur un piédestal 12 × 12 × 2.
- **Cartels :** chaque piédestal affiche le compteur d'éliminations et les variantes à 10, 100 et 1 000.

## 4. Budgets

| | Prairie | Laboratoire |
|---|---|---|
| Parts | 10 000 : décor fixe 5 000 (dont Lisière et Fond 4 000), dynamique 2 860 (Zbires 1 800, éclats 550, défenses 360, Colosse 150), réserve 2 140 | 8 000 (proposition) |
| `Neon` | 150 : structures 30, Zbires et Colosse 70, réserve 50 | 150, dont Arbre 25 et piliers 16 |
| `PointLight` | 12 : Maison, Mine, Établi, 4 portails, Colosse, réserve 4 | 12 |

## 5. Vérificateur d'architecture

Les bâtiments sont rangés dans `Workspace.Carte.Batiments`, avec `PrimaryPart` = Socle non pivoté. Ce ModuleScript d'édition se lance depuis la barre de commande avant chaque livraison.

```lua
-- ServerStorage.OutilsArchi.Verificateur (ModuleScript)
-- require(game.ServerStorage.OutilsArchi.Verificateur).verifierPrairie()
local Verificateur = {}

local HAUTEUR_MAX, RAYON, GRILLE = 6, 60, 4
local LIMITES = { Parts = 5000, Neon = 80, PointLight = 11 } -- décor fixe

local function sommet(part: BasePart): number
	local cf, d = part.CFrame, part.Size / 2
	return cf.Position.Y + math.abs(cf.RightVector.Y) * d.X
		+ math.abs(cf.UpVector.Y) * d.Y + math.abs(cf.LookVector.Y) * d.Z
end

local function surGrille(v: number): boolean
	return math.abs(v - math.round(v / GRILLE) * GRILLE) < 0.01
end

function Verificateur.verifierPrairie(): boolean
	local batiments = workspace.Carte.Batiments
	local maison: Model = batiments.Maison
	local centre = maison:GetPivot().Position
	local n = { Parts = 0, Neon = 0, PointLight = 0, Lisse = 0 }
	local erreurs = 0
	local function signaler(message: string)
		warn(message)
		erreurs += 1
	end

	for _, objet in workspace:GetDescendants() do
		if objet:IsA("PointLight") then
			n.PointLight += 1
		elseif objet:IsA("BasePart") and not objet:IsA("Terrain") then
			n.Parts += 1
			if objet.Material == Enum.Material.Neon then n.Neon += 1 end
			if objet.Material == Enum.Material.SmoothPlastic then n.Lisse += 1 end
			local ecart = Vector2.new(objet.Position.X - centre.X, objet.Position.Z - centre.Z).Magnitude
			local haut = sommet(objet)
			if ecart < RAYON and haut > HAUTEUR_MAX + 0.01 and not objet:IsDescendantOf(maison) then
				signaler(("[Hauteur] %s : %.1f studs à %.0f de la Maison"):format(objet:GetFullName(), haut, ecart))
			end
		end
	end

	for _, modele in batiments:GetChildren() do
		local socle = modele:IsA("Model") and modele.PrimaryPart
		if socle then
			local p, d = socle.Position, socle.Size / 2
			for _, bord in { p.X - d.X, p.X + d.X, p.Z - d.Z, p.Z + d.Z } do
				if not surGrille(bord) then
					signaler(("[Grille] %s : bord à %.2f"):format(modele.Name, bord))
					break
				end
			end
		end
	end

	for nom, plafond in LIMITES do
		if n[nom] > plafond then
			signaler(("[Budget] %s : %d / %d"):format(nom, n[nom], plafond))
		end
	end
	if n.Lisse < 0.9 * n.Parts then
		signaler(("[Matériaux] SmoothPlastic : %d / %d Parts"):format(n.Lisse, n.Parts))
	end
	print(("[Vérificateur] %d Parts, %d Neon, %d erreur(s)"):format(n.Parts, n.Neon, erreurs))
	return erreurs == 0
end

return Verificateur
```

### 🛋️ Décoratrice d'intérieurs — Bérénice Yao
# Intérieurs de Zsurvie : pièce par pièce

## 0. Règles communes

- **Grilles :** murs sur 4 studs ; mobilier sur 1 stud (Studio : Move 1, Rotate 90°) ; aucun prop sous 1 stud.
- **Matériaux :** `SmoothPlastic` ; parquet en lattes de 1 stud, 2 teintes alternées. `Glass` seulement pour les hublots et le bocal.
- **Teintes** (base / ombre / lumière) :

  | Couleur | Base | Ombre | Lumière |
  |---|---|---|---|
  | Terre battue | #C8894F | #A06E3F | #D19C66 |
  | Nuit labo | #2A3263 | #22284F | #535676 |
  | Ardoise | #4A4560 | #3B374D | #6C6573 |
  | Crème | #F6E7C1 | #C5B99A | — |

- **Props :**
  - `Anchored` true ; `CastShadow`, `CanTouch` et `CanQuery` false.
  - `CanCollide` false sous 2 studs de haut : aucun Survivant coincé sur mobile.
- **Textes :** `SurfaceGui` (`PixelsPerStud` 25, `TextScaled`, `Enum.Font.FredokaOne`), lettres de 1 stud minimum.
- **Prompts :** `MaxActivationDistance` 8, `RequiresLineOfSight` false. Le client n'accorde jamais rien.
- **Budget lobby :**
  - 150 `Neon` : Cabinet 8, Alcôves 60, Quai 24, Galerie 20, Arbre des Recherches 38.
  - 12 `PointLight` : 3 chacun pour le Cabinet, le Quai, la Galerie et l'Arbre.

## 1. Cabinet de Doc Boulon (Laboratoire)

**Emprise :** 16 × 12 studs, au nord de l'Arbre des Recherches, face à l'apparition.

**Histoire :** Doc Boulon étudie les Zbires depuis bien avant vous et ne rentre jamais chez elle.

| Meuble | Studs | Couleurs | Indice |
|---|---|---|---|
| Bureau en L | 8 × 3 × 4 | Ardoise, plateau Crème | Plans « Maison v12 » : elle rebâtit la Maison après chaque chute |
| Tableau « Fiches Zbires » | 8 × 5, à 4 de haut | liège Terre battue, flèches Alerte | « Casqué : critique ! », « Gluant : × 2 ! », « Volant : passe les Murets ! » |
| Lit de camp | 6 × 3 × 2 | Toit orange | Elle dort ici |
| Bocal d'étude | 3 × 3 × 4 (`Glass`, `Transparency` 0,4) | Gluant Violet horde | Elle étudie la division |
| Bouton sous cloche | 2 × 2 × 2 | Alerte | Pancarte « NE PAS APPUYER » |
| 8 tubes au plafond | 6 × 1 × 1 (`Neon`) | Gemme cyan | Repaire de savant |

**Interactifs**

- **Doc Boulon :** prompt « Parler », qui lance le tutoriel.
- **Bocal :** prompt « Tapoter ». Animation locale :
  - le Gluant s'écrase (× 0,8) ;
  - il se divise en 2 Mini-Gluants pendant 2 s ;
  - puis il se reforme.

  La règle est enseignée sans texte.
- **Bouton :** prompt « Appuyer ». Il lance `ParticleEmitter:Emit(15)` (des cubes cyan) et Doc Boulon crie « Qui a appuyé ?! ». Effet local, 5 s de recharge, aucune récompense.

## 2. Les 12 Alcôves

**Gabarit :** `Laboratoire.Alcoves.Alcove01` à `Alcove12`.

- **Volume :** ouverture 12 studs, profondeur 10, hauteur 12, sol à +1 stud.
- **Finitions :** murs Nuit labo, seuil `Neon` cyan de 12 × 1 × 1.
- **Dossiers :** `Slots` (4 Parts invisibles), `Machines`, `Bache`, `Cartons`, `Tapis`, `Plaque` (avec `SurfaceGui.Nom`).
- **Budget :** 350 Parts au maximum, Alcôve équipée.

| État | Condition | Décor | Ce que ça raconte |
|---|---|---|---|
| Libre | sans propriétaire | bâches Crème ombre, plaque « Libre » | Place à prendre |
| Emménagement | moins de 2 recherches | 4 cartons, lit de camp, Sac à dos au crochet | « Je viens d'arriver » |
| Installé | 2 recherches ou plus | tapis Toit orange | « Ici, c'est chez moi » |

| Recherche | Slot | Stades 1 → 2 → 3 | Animation (client) |
|---|---|---|---|
| Tourelle de toit | fond gauche, sur un établi 4 × 3 × 3 | maquette de la Maison avec mini-tourelle → 2 canons → 3 canons et radar | pivote de 90° toutes les 3 s |
| Balles perforantes | fond droit | cible trouée → 3 cibles percées d'un même trou → banc de tir avec une plaque de Casqué | la cible oscille |
| Visée critique | mur du fond, à 7 studs | lunette sur trépied → mire Alerte → grande lunette | balaie ±30° |
| Foreuse | avant gauche, au seuil | foret de 3 studs → réservoir → double foret de 6 studs | des cubes cyan montent selon `ForeuseStock` |

**Machines :** 40 Parts au maximum par machine et par stade. Au stade 3, 1 Part `Neon`.

**Foreuse :** prompt « Récolter » (`HoldDuration` 0,5).

- Le client le masque chez les autres joueurs.
- Le serveur vérifie `Proprietaire == player.UserId`.

```lua
-- ServerScriptService/Alcoves (Script, place Laboratoire)
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local alcoves = workspace:WaitForChild("Laboratoire"):WaitForChild("Alcoves"):GetChildren()
table.sort(alcoves, function(a, b) return a.Name < b.Name end)
local gabarits = ServerStorage:WaitForChild("MachinesRecherche") -- <Recherche>/Stade1..3
local RECHERCHES = { "TourelleDeToit", "BallesPerforantes", "ViseeCritique", "Foreuse" }
local SEUILS = { 1, 3, 5 } -- niveau minimal des stades 1, 2, 3 (provisoire)
local alcoveDe: { [Player]: Model } = {}

local function montrer(dossier: Instance, visible: boolean)
	for _, p in dossier:GetDescendants() do
		if p:IsA("BasePart") then
			p.Transparency = if visible then 0 else 1
			p.CanCollide = visible and p.Size.Y >= 2
		end
	end
end

local function poser(alcove: Model, nom: string, niveau: number)
	local s = 0
	for i, seuil in SEUILS do
		if niveau >= seuil then s = i end
	end
	local actuelle = alcove.Machines:FindFirstChild(nom)
	if actuelle and actuelle:GetAttribute("Stade") == s then return end
	if actuelle then actuelle:Destroy() end
	if s == 0 then return end
	local machine = gabarits[nom]["Stade" .. s]:Clone()
	machine.Name = nom
	machine:SetAttribute("Stade", s)
	machine:PivotTo(alcove.Slots[nom].CFrame)
	machine.Parent = alcove.Machines -- le client joue le « pop » élastique sur ChildAdded
end

local function amenager(alcove: Model, player: Player?)
	local nb = 0
	for _, nom in RECHERCHES do
		local niveau = if player then (player:GetAttribute("Recherche_" .. nom) or 0) else 0
		poser(alcove, nom, niveau)
		if niveau > 0 then nb += 1 end
	end
	montrer(alcove.Bache, player == nil)
	montrer(alcove.Cartons, player ~= nil and nb < 2)
	montrer(alcove.Tapis, player ~= nil and nb >= 2)
	alcove.Plaque.SurfaceGui.Nom.Text = if player then player.DisplayName else "Libre"
	alcove:SetAttribute("Proprietaire", if player then player.UserId else 0)
end

local function arrivee(player: Player)
	if alcoveDe[player] then return end
	for _, alcove in alcoves do
		if alcove:GetAttribute("Proprietaire") == 0 then
			alcoveDe[player] = alcove
			amenager(alcove, player)
			player.AttributeChanged:Connect(function(attr)
				if string.sub(attr, 1, 10) == "Recherche_" and alcoveDe[player] == alcove then
					amenager(alcove, player)
				end
			end)
			return
		end
	end
end

for _, alcove in alcoves do amenager(alcove, nil) end
Players.PlayerAdded:Connect(arrivee)
for _, p in Players:GetPlayers() do arrivee(p) end
Players.PlayerRemoving:Connect(function(player)
	local alcove = alcoveDe[player]
	alcoveDe[player] = nil
	if alcove then amenager(alcove, nil) end
end)
```

## 3. Intérieur des Capsules (Quai des Capsules)

- **Cabine :** 12 × 8 × 8 studs, hublot `Glass` de 8 × 4.
- **Sièges :** 6 `Seat` de 2 × 1 × 2, en 2 rangées de 3, espacés de 3 studs.
- **Compte à rebours :** 15 s sur le panneau avant, calculées avec l'attribut `Depart` et `workspace:GetServerTimeNow()`.
- **Départ :** à 3 s, une barre de sécurité Crème descend (0,15 s, effet élastique).

| Capsule | Palette | Indice |
|---|---|---|
| Normale | Crème, Toit orange | Panier de pique-nique sous les sièges |
| Difficile | Ardoise, bandes Alerte | Casques cabossés suspendus : beaucoup de Casqués en vue |
| du Jour | Or, Gemme cyan | 2 panneaux 3 × 3 pour les 2 modificateurs, « 150 gemmes » |

## 4. La Galerie des Zbires

**La salle :** 40 × 24 studs, damier Crème et Crème ombre.

**Les socles :** 8 socles Ardoise de 4 × 4 × 1, dans l'ordre du bestiaire (Marcheur, Rapide, Costaud, Doré, Sauteur, Gluant, Volant, Casqué). Au fond, la niche du Colosse : socle 8 × 8, cordon Alerte, plaque « Tous les 5 jours ».

- **Figurine :** le modèle du jeu (30 Parts au maximum), avec une animation d'attente élastique en local.
- **Cartel :** le nom, la règle en une ligne et un compteur personnel « 57 / 100 » (attribut joueur `Elim_<Zbire>`).
- **Variantes :** à 10, 100 et 1 000 éliminations, le client affiche la variante débloquée. Chacun voit sa propre collection.
- **Détails :** pancarte « Ne pas nourrir les Zbires », un banc, une silhouette en carton de Doc Boulon au guichet.

## 5. La Maison (place Prairie)

**Volume :** 16 × 16 × 14 studs, 14 × 14 à l'intérieur, rez-de-chaussée de 8 studs, combles vides.

**Accès :** personne n'entre. La porte est barricadée (planches Terre battue) et les murs sont en `CanCollide`.

**Ce que voit la caméra :**

- Des baies de 4 × 5 studs : 2 au sud (côté caméra), 1 à l'est.
- À 45° de plongée, seule une bande de 5 studs derrière chaque baie est lisible. Les objets clés y sont placés.

**Budget :** 200 Parts au maximum, 0 `Neon`. Un seul `PointLight` (Range 14, Brightness 1,2, couleur Crème, `Shadows` false) : il fait briller les baies au Jour du Colosse (`ClockTime` 17,5).

**Histoire :** six Survivants vivent dans l'ancienne maison d'enfance de Doc Boulon. C'est un ajout au canon, à valider par Victor Lanoue.

| Objet | Place | Indice |
|---|---|---|
| Table et 6 bols | derrière la baie sud gauche | 6 = l'équipe complète |
| Calendrier 3 × 2 | sur la table, tourné vers la baie | « Jour X » (attribut `Jour`), un jour sur 5 entouré en Alerte : le Colosse |
| 3 lits superposés 6 × 3 × 6 | mur nord | 6 couvertures de couleurs différentes |
| Bocal de gemmes | rebord de la baie est | La Mine fait vivre la maison |
| Dessins de Zbires souriants | mur est | Rigolos, pas effrayants |

| `Etat` | PV (proposition) | Intérieur |
|---|---|---|
| 1 : Intacte | plus de 66 % | Rangé, bouquet sur la table |
| 2 : Abîmée | de 33 à 66 % | Cadres penchés de 8°, livres au sol, planche clouée sur la baie est, seau sous une fuite |
| 3 : Critique | moins de 33 % | Cadres à 16°, bols au sol, lumière Toit orange |

**Réglage dans Studio :** sur les Parts de `Maison.Interieur`, les attributs `EtatMin` et `EtatMax` règlent la visibilité, et l'attribut `Penche` l'inclinaison en degrés.

```lua
-- StarterPlayerScripts/InterieurMaison (LocalScript, place Prairie) : visuel seulement
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local maison = workspace:WaitForChild("Maison")
local interieur = maison:WaitForChild("Interieur")
local lampe = interieur:WaitForChild("Lampe"):WaitForChild("PointLight") :: PointLight
local ELASTIQUE = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local origines: { [BasePart]: CFrame } = {}

local function appliquer()
	local etat = maison:GetAttribute("Etat") or 1
	for _, p in interieur:GetDescendants() do
		if not p:IsA("BasePart") then continue end
		local mini, maxi = p:GetAttribute("EtatMin"), p:GetAttribute("EtatMax")
		if mini or maxi then
			p.Transparency = if etat >= (mini or 1) and etat <= (maxi or 3) then 0 else 1
		end
		local angle = p:GetAttribute("Penche")
		if angle then
			origines[p] = origines[p] or p.CFrame
			local cible = origines[p] * CFrame.Angles(0, 0, math.rad(angle * (etat - 1)))
			TweenService:Create(p, ELASTIQUE, { CFrame = cible }):Play()
		end
	end
	lampe.Color = if etat == 3 then Charte.ToitOrange else Charte.Creme
end

maison:GetAttributeChangedSignal("Etat"):Connect(appliquer)
appliquer()
```

**Chute de la Maison :** le toit se soulève de 6 studs en 0,6 s (`Back`) et la caméra plonge à la verticale pendant 3 s. C'est le seul moment où l'on voit tout l'intérieur, y compris l'œuf de Pâques du mur nord : une photo de Doc Boulon enfant devant la Maison.

## 6. Secrets

| Secret | Lieu | Récompense |
|---|---|---|
| 5 peluches Mini-Gluant (tag `PelucheSecrete`, attribut `Id` de 1 à 5) | sous le lit de camp, dans le tiroir du bureau, sous un siège de la Capsule Difficile, derrière le Colosse, au guichet de la Galerie | Badge « Chasseur de peluches » et peluche gratuite pour le Sac à dos |
| Bâche Violet horde, 9e socle | Galerie | Se lève le samedi à 17 h (heure de Paris) sur le Zbire de la Semaine |
| Photo de Doc Boulon enfant | Maison | Visible lors de la chute |

**Règle serveur des peluches :**

- Déclenchement : prompt « Câliner ».
- Vérifications :
  - le personnage est à 12 studs au plus ;
  - la peluche n'est pas déjà dans le masque.
- Sauvegarde : `UpdateAsync` sur un masque de 5 bits (DataStore `PeluchesSecretes_v1`).
- Récompense : à 5 peluches sur 5, `BadgeService:AwardBadge` et attribut `CosmetiquePeluche`.
- Un secret ne rapporte jamais de gemmes ni de pièces.

### 📦 Artiste props — Côme Registre
# Zsurvie : kit de props modulaires

## 1. Principes du kit

- **Grilles :** le pivot de chaque prop tombe sur la grille décor de 1 stud. Les modules qui se raccordent aux bâtiments (barrières, tuyaux, néons) font 4 studs de long. Les détails sont au demi-stud (0,5), comme le pixel des personnages. On tourne par pas de 90°, avec 45° toléré pour la végétation de la Lisière.
- **Pivot :** pas de Part racine. Le `WorldPivot` est au centre de la face inférieure, face avant vers −Z. Un `PivotTo` pose donc le prop au sol sans décalage.
- **Le dessus d'abord :** la caméra à (0, 45, 28) montre surtout le dessus des objets. La face supérieure est en teinte lumière, les côtés en base, le socle en ombre.
- **Code couleur sur la run :** les props utilisent Terre battue, Crème, Prairie et Ardoise. Violet horde, Or et Alerte leur sont interdits (Zbires, pièces, danger). Gemme cyan est réservé à la Mine. Jamais d'orange au sol : le Tapis Collant est le seul objet plat orange. Au Laboratoire, Gemme cyan et Nuit labo sont libres.
- **Matériaux :** `SmoothPlastic` partout, `Neon` seulement pour les ampoules, écrans et cristaux. Tout est construit en Parts. Une `MeshPart` n'est autorisée que si elle remplace au moins 5 Parts, avec `CollisionFidelity = Box`.

## 2. Catalogue (29 entrées)

| Prop | L × H × P (studs) | Parts | Variantes | Catégorie | Zones |
|---|---|---|---|---|---|
| `PRP_Caisse_S` | 2 × 2 × 2 | 3 | Bois, PiqueNique, Mine, Labo | Bloquant | Lisière, Mine, Quai, Labo |
| `PRP_Caisse_M` | 4 × 4 × 4 | 5 | Bois, Mine, Labo | Bloquant | Lisière, Quai, Labo |
| `PRP_Caisse_Pile` | 4 × 6 × 4 | 8 | Bois, Labo | Bloquant | Lisière, Quai |
| `PRP_Panier` | 2 × 2 × 1 | 4 | Osier, Creme | Décor | Prairie |
| `PRP_Nappe` | 8 × 0,2 × 8 | 1 + `Texture` damier (`StudsPerTileU/V` = 4) | Creme/TerreBattue | Sol | Prairie, 1 par quadrant |
| `PRP_Lampe_Borne` | 1 × 2 × 1 | 3 (1 Neon) | Prairie (Crème), Labo (cyan) | Décor | bords des chemins, Quai |
| `PRP_Lampe_Lampadaire` | 1 × 6 × 1, tête 2 × 1 × 2 | 5 (1 Neon) | Allume (`PointLight`), Eteint | Bloquant | chemins (8 max), Quai |
| `PRP_Lampe_Lanterne` | 1 × 1 × 1 | 2 (1 Neon) | Porche (Crème), Mine (cyan) | Décor | porche de la Maison, Mine |
| `PRP_Lampe_Neon` | 4 × 0,5 × 0,5 | 1 Neon | Cyan, Orange | Décor | Labo, Quai, Galerie |
| `PRP_Barriere` | Droit 4 × 2 × 1, Coin 1 × 2 × 1, Porte 4 × 2 × 1 (passage de 2) | 1 à 3 | Bois, Labo | Bloquant | Lisière, Quai, Alcôves |
| `PRP_Cordon` | 4 × 2 × 1 | 3 | Musee | Bloquant | Galerie |
| `PRP_Fleur` | 1 × 1 × 1 | 2 | Creme, Prairie | Décor | Prairie |
| `PRP_Buisson` | S 2 × 2 × 2, M 3 × 3 × 3 | 2 à 3 | Clair, Fonce | S Décor, M Bloquant | S Prairie, M Lisière |
| `PRP_Souche` | 2 × 1 × 2 | 2 | Bois | Décor | Prairie |
| `PRP_Rocher` | S 2 × 1 × 2, M 3 × 2 × 3, L 4 × 3 × 4 | 1 à 3 | Ardoise | Bloquant | Lisière |
| `PRP_Arbre` | S 3 × 5 × 3, M 4 × 8 × 4, L 6 × 12 × 6 | 3 à 6 | Vert, Fleuri | Bloquant (tronc) | S Quai et Lisière, M et L Lisière seulement |
| `PRP_Rail` | Droit 4 × 0,5 × 2, Courbe 4 × 0,5 × 4, Fin 2 × 1 × 2 | 3 | Ardoise | Sol | Mine |
| `PRP_Wagonnet` | 2 × 2 × 3 | 5 (+2 Neon) | Vide, Plein | Bloquant | empreinte de la Mine |
| `PRP_Cristal` | S 1 × 2 × 1, M 1 × 3 × 1 | 1 à 2 Neon | Cyan | Décor | Mine uniquement |
| `PRP_Etai` | 4 × 5 × 1 | 3 | Bois | Bloquant | entrée de la Mine |
| `PRP_Tuyau` | Droit 4 × 1 × 1, Coude 2 × 2 × 1, Te 2 × 2 × 1 | 1 à 3 | Ardoise | Décor | murs et plafonds du Labo et du Quai |
| `PRP_Console` | 2 × 3 × 1 | 4 (écran Neon) | Cyan, Orange | Bloquant | Labo, Alcôves |
| `PRP_Etagere` | 4 × 4 × 1 | 8 | Fioles cyan, vertes, orange | Bloquant | Labo |
| `PRP_Banc` | 4 × 1 × 2 | 3 | Labo, Quai | Bloquant | Quai, Galerie |
| `PRP_Socle` | 4 × 1 × 4 | 2 (+ plaque) | Creme | Bloquant | Galerie des Zbires |
| `PRP_Panneau` | 2 × 3 × 1 | 3 + `SurfaceGui` | Fleche, Info | Bloquant | Quai, Labo |
| `DEF_Muret` | 4 × 3 × 1 | 4 + `Fissure_1`, `Fissure_2` | attribut `Etat` de 1 à 3 | Bloquant | Prairie, posé en jeu |
| `DEF_MiniTourelle` | 2 × 3 × 2 | 8 | — | Bloquant | Prairie, posée en jeu |
| `DEF_TapisCollant` | 4 × 0,2 × 4 | 2 | — | Sol | Prairie, posé en jeu |

Les défenses sont en Crème et Toit orange (« à nous »). Je livre les modèles, la logique reste au scripting.

## 3. Convention de nommage

- **Maîtres :** `PRP_<Famille>_<Forme>_<Variante>`, par exemple `PRP_Caisse_S_PiqueNique`, `PRP_Lampe_Lampadaire_Eteint` ou `PRP_Rail_Courbe_Ardoise`. La forme vaut S, M, L ou le nom d'un module (Droit, Coin, Porte, Courbe).
- **Défenses :** `DEF_Muret`, `DEF_MiniTourelle` et `DEF_TapisCollant`. Leurs états passent par des attributs, pas par des modèles séparés.
- **Noms d'instances en ASCII PascalCase**, sans accents ni espaces, pour que `FindFirstChild` ne rate jamais. Les accents restent dans l'UI.
- **Parts :** `Corps` pour le volume principal, `Collision` pour la boîte invisible (facultative), `Ampoule` pour le Neon, `Detail_<Quoi>` pour le reste.
- **Copies placées :** elles gardent le nom du maître et sont rangées par zone.
- **Attributs du Model :** `Kit` (string), `Categorie` (`Bloquant`, `Decor` ou `Sol`) et `Version` (number).
- **Attributs des Parts :** `Couleur`, qui reprend une clé de `Charte.Palette` (par exemple `TerreBattue`), et `Teinte` (`base`, `ombre` ou `lumiere`). On ne saisit jamais `Color` à la main.
- **Tag `PropLumiere` :** il est posé automatiquement sur tout prop qui contient une `PointLight`.

## 4. Organisation des dossiers

```text
ServerStorage
└─ KitPropsMaitres        Contenants, Lumieres, Barrieres, Nature, Mine, Laboratoire
ReplicatedStorage
├─ Charte                 ModuleScript (canon)
└─ KitProps
   ├─ Regles              ModuleScript (section 7)
   └─ Defenses            DEF_Muret, DEF_MiniTourelle, DEF_TapisCollant
Workspace (place Prairie)
├─ Carte
│  ├─ Maison              département bâtiments
│  └─ Props               Maison, Prairie, Chemins, Mine, Lisiere
└─ Dynamique              vide dans Studio, rempli par le serveur : Zbires, Defenses, Pieces
Workspace (place Laboratoire)
└─ Carte
   └─ Props               Laboratoire, QuaiCapsules, GalerieZbires, Alcoves
```

- **Les maîtres de décor restent en `ServerStorage` :** ils ne sont jamais répliqués et ne prennent donc aucune mémoire sur les téléphones. Chaque maître est un Package. Les copies placées gardent le lien, si bien qu'un « Update All » propage une correction au Laboratoire et à la Prairie.
- **Les défenses sont en `ReplicatedStorage` :** le client en clone un fantôme pour l'aperçu de pose. Le serveur clone le vrai modèle une fois la demande validée (distance, solde, 3 par Survivant).

## 5. Ancrage et collisions

| Part | Anchored | CanCollide | CanQuery | CanTouch |
|---|---|---|---|---|
| `Collision` (à défaut `Corps`) d'un Bloquant | true | true | true | false |
| Autres Parts d'un Bloquant | true | false | false | false |
| Parts d'un Décor ou d'un Sol | true | false | false | false |
| Fantôme de pose côté client (`Transparency` ≥ 0,5) | true | false | false | false |

- **Tout est ancré, rien n'est soudé :** aucun `Weld`, aucune contrainte, aucun coût physique, et aucun joueur ne peut pousser un prop.
- **`CanTouch = false` partout :** on ne branche aucune logique sur `Touched`. Le serveur détecte le Tapis Collant par la distance.
- **`CanQuery` suit la collision :** le serveur refuse ainsi une défense posée sur un prop grâce à `GetPartBoundsInBox`. Le tir ne vise que `Workspace.Dynamique.Zbires` (`RaycastParams.FilterType = Include`). Aucun prop ne bloque donc une balle ni le tir automatique à 40 studs.
- **Couloir libre :** les Zbires n'ont pas de physique et traversent les obstacles. Dans la Prairie (rayon de 70 studs), on ne place donc que des props Décor ou Sol de 2 studs de haut au plus. Seules exceptions : 8 lampadaires, 2 par chemin à 1 stud du bord, et les props de l'empreinte de la Mine. Dans la Lisière, aucun prop Bloquant sur les chemins ni dans un couloir de 8 studs entre chaque portail et la Maison. Le Muret reste ainsi le seul mur de l'arène.
- **Hauteur :** 6 studs au maximum à moins de 60 studs de la Maison, Mine comprise.
- **`CastShadow` :** `true` uniquement sur un `Corps` de 2 studs ou plus, jamais sur un Sol.

## 6. Budgets du kit

| Place | Parts | Parts `Neon` | `PointLight` |
|---|---|---|---|
| Prairie | 2 500 sur 10 000 | 40 sur 150 | 4 sur 12 (2 au porche, 2 à la Mine) |
| Laboratoire | 3 000 | 60 sur 150 | 6 sur 12 |

Sur la Prairie, les lampadaires sont en variante `Eteint` : leur ampoule Neon suffit à les lire, et les autres `PointLight` vont aux effets. Les lanternes sont réglées ainsi : `Range` 12, `Brightness` 1,5, `Shadows = false`, couleur Crème au porche et Gemme cyan à la Mine.

## 7. Module `Regles`

```lua
--!strict
-- ReplicatedStorage.KitProps.Regles (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charte = require(ReplicatedStorage:WaitForChild("Charte"))

local Regles = {}

local HAUTEUR_MAX = 6 -- studs (canon)
local RAYON_BAS = 60 -- studs autour de la Maison

export type Budget = { parts: number, neon: number, lumieres: number }

local function teinte(nom: string, t: string?): Color3
	local base: Color3 = Charte.Palette[nom]
	assert(base, `Couleur absente de la Charte : {nom}`)
	if t == "ombre" then
		return Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8)
	elseif t == "lumiere" then
		return base:Lerp(Charte.Palette.Creme, 0.2)
	end
	return base
end

-- fantome = true : aperçu de pose côté client
function Regles.appliquer(model: Model, fantome: boolean?)
	local categorie = model:GetAttribute("Categorie")
	assert(categorie, `{model:GetFullName()} : attribut Categorie manquant`)
	local solide: Instance? = nil
	if categorie == "Bloquant" and not fantome then
		solide = model:FindFirstChild("Collision") or model:FindFirstChild("Corps")
	end
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			local couleur = d:GetAttribute("Couleur")
			if typeof(couleur) == "string" then
				d.Color = teinte(couleur, d:GetAttribute("Teinte"))
			end
			d.Anchored = true
			d.CanTouch = false
			d.CanCollide = d == solide
			d.CanQuery = d == solide
			local grand = math.max(d.Size.X, d.Size.Y, d.Size.Z) >= 2
			d.CastShadow = not fantome and categorie ~= "Sol" and d.Name == "Corps" and grand
			if d.Name == "Collision" then
				d.Transparency = 1
			end
			if fantome then
				d.Transparency = math.max(d.Transparency, 0.5)
			end
		end
	end
	if model:FindFirstChildWhichIsA("PointLight", true) then
		model:AddTag("PropLumiere")
	end
end

function Regles.auditer(racine: Instance, centreMaison: Vector3, budget: Budget): { string }
	local erreurs: { string } = {}
	local parts, neon, lumieres = 0, 0, 0
	for _, d in racine:GetDescendants() do
		if d:IsA("BasePart") then
			parts += 1
			if d.Material == Enum.Material.Neon then
				neon += 1
			elseif d.Material ~= Enum.Material.SmoothPlastic then
				table.insert(erreurs, `{d:GetFullName()} : matériau {d.Material.Name}`)
			end
			if not d.Anchored or d.CanTouch then
				table.insert(erreurs, `{d:GetFullName()} : Anchored ou CanTouch`)
			end
		elseif d:IsA("PointLight") then
			lumieres += 1
		elseif d:IsA("Model") and d:GetAttribute("Kit") then
			local cf, taille = d:GetBoundingBox()
			local ecart = cf.Position - centreMaison
			local distance = Vector2.new(ecart.X, ecart.Z).Magnitude
			if distance < RAYON_BAS and taille.Y > HAUTEUR_MAX + 0.01 then
				table.insert(erreurs, `{d:GetFullName()} : {taille.Y} studs à {math.floor(distance)} studs`)
			end
		end
	end
	if parts > budget.parts then table.insert(erreurs, `Parts {parts}/{budget.parts}`) end
	if neon > budget.neon then table.insert(erreurs, `Neon {neon}/{budget.neon}`) end
	if lumieres > budget.lumieres then table.insert(erreurs, `PointLight {lumieres}/{budget.lumieres}`) end
	return erreurs
end

return Regles
```

Avant chaque publication, on lance ceci dans la barre de commande de Studio :

```lua
local R = require(game.ReplicatedStorage.KitProps.Regles)
local props = workspace.Carte.Props
for _, m in props:GetDescendants() do
	if m:IsA("Model") and m:GetAttribute("Kit") then R.appliquer(m) end
end
print(R.auditer(props, workspace.Carte.Maison:GetPivot().Position, { parts = 2500, neon = 40, lumieres = 4 }))
```

## 8. Ajouter un prop

1. Le construire dans `ServerStorage.KitPropsMaitres`, pivot au centre de la base et face avant vers −Z.
2. Nommer les Parts, remplir les attributs, puis lancer `Regles.appliquer`.
3. Contrôler le dessus avec la caméra de jeu (0, 45, 28), `FieldOfView` 50, dans l'émulateur téléphone de Studio.
4. Le convertir en Package, le placer, puis relancer `auditer` jusqu'à zéro erreur.

### 🧊 Modeleuse 3D — Salomé Drancourt
## 1. Principes Pixel-bloc pour les meshes

- **Une MeshPart = une couleur de la Charte.** `TextureID` reste vide et le `Material` est `SmoothPlastic`, sauf `Neon` quand le nom finit par `__Neon`. Les textures ne coûtent donc aucune mémoire. La couleur vient de `ReplicatedStorage.Charte` : flash de dégâts, Capsules et variantes de la Galerie se font par recoloration.
- **Grilles** (snap Increment dans Blender) : 0,5 stud pour les personnages, le Blaster et le Sac à dos ; 1 stud pour le décor ; 4 studs pour la Maison, les Alcôves et le Quai.
- **Topologie** : faces internes supprimées, faces coplanaires de même couleur dissoutes, ombrage plat, maillage triangulé, aucune arête non-manifold.
- **Réutilisation** : un seul `MeshId` par forme. La Galerie, la Tourelle de toit et la Foreuse de l'Alcôve reprennent les meshes de la run. Roblox regroupe au rendu les MeshParts qui ont le même `MeshId` et le même `Material`.
- **Lisibilité** : à part la Maison, rien ne dépasse 6 studs de haut à moins de 60 studs de la Maison. Le Colosse est compris dans la règle.
- **Animation** : un Zbire, ce sont 2 à 5 MeshParts rigides que le client déplace par CFrame, sans skinning ni `Humanoid`. Seuls le Colosse et Doc Boulon ont un rig `Motor6D` avec un `AnimationController`.

## 2. MeshParts à produire

### Run (place Prairie)

| Asset | L × H × P (studs) | MeshParts | Tris max | Point clé |
|---|---|---|---|---|
| Marcheur | 2 × 2,5 × 2 | 4 | 400 | Mesh étalon du bestiaire |
| Rapide | 1,5 × 2 × 2,5 | 4 | 350 | Penché, silhouette en flèche |
| Costaud | 3,5 × 3,5 × 3 | 5 | 700 | Piquants séparés en `VioletHorde_Lumiere` |
| Doré | 2 × 2,5 × 2 | 4 | 450 | Corps `Or` |
| Sauteur | 2 × 2 × 2 | 4 | 400 | Ressorts séparés pour l'étirement × 1,2 |
| Gluant | 3 × 2 × 3 | 3 | 350 | Goutte en escalier |
| Mini-Gluant | 1,5 × 1 × 1,5 | 2 | 150 | Mesh à part, qui garde le pixel de 0,5 stud |
| Volant | 2,5 × 1,5 × 2 | 4 | 450 | Ailes séparées, corps à +4 studs, au-dessus du Muret |
| Casqué | 2,5 × 3 × 2,5 | 5 | 600 | Casque `Ardoise` séparé |
| Colosse | 9 × 6 × 9 | 12 | 3 000 | Trapu : il respecte les 6 studs et ne masque pas la Maison |
| Pièce | 1 × 1 × 0,25 | 1 | 60 | Pool de 200 |
| Gemme | 0,8 × 1 × 0,8 | 1 | 40 | Pool de 60 |
| Maison (3 états) | 16 × 14 × 16 | 8 à 12 | 3 500 par état | Socle commun aux 3 états, `Attache_TourelleToit` |
| Tourelle de toit | 3 × 3 × 3 | 4 | 600 | Canon pivotant |
| Mine | 8 × 5 × 8 | 6 | 1 500 | 4 cristaux `__Neon`, `Attache_Foreuse` |
| Foreuse | 3 × 5 × 3 | 3 | 500 | Mèche tournante |
| Établi | 6 × 4 × 4 | 5 | 1 200 | `Creme` et `ToitOrange` |
| Muret | 4 × 3 × 1 | 2 | 150 | Grille de 1 stud |
| Mini-Tourelle | 2 × 3 × 2 | 3 | 500 | Tête pivotante |
| Tapis Collant | 4 × 0,2 × 4 | 1 | 80 | Bulles en relief |
| Blaster | 1 × 1 × 2,5 | 3 | 300 | `Tool.Handle`, `Attache_Canon` |
| Sac à dos | 2 × 2 × 1 | 2 | 250 | `Accessory` sur `BodyBackAttachment` |
| Portail violet | 8 × 10 × 2 | 2 | 400 | 8 exemplaires, voile `__Neon` |
| Arbre-cube (3 variantes) | 6 × 10 à 16 × 6 | 2 | 200 | Lisière seulement, à plus de 70 studs |
| Kit Prairie (15 meshes) | 6 de haut au maximum | 1 à 3 | 30 à 300 | Nappe, panier, rochers, buissons, fleurs, clôture, borne |

**Budget de la Prairie** : 90 000 triangles visibles au maximum au pic (60 Zbires ≈ 27 000, décor ≈ 45 000, bâtiments ≈ 8 000, Colosse 3 000) et 70 meshes uniques au maximum.

### Lobby (place Laboratoire)

| Asset | L × H × P (studs) | MeshParts | Tris max | Point clé |
|---|---|---|---|---|
| Doc Boulon | 2 × 5 × 1,5 | 10 | 2 500 | Rig `Motor6D`, pivot aux pieds |
| Arbre des Recherches | 16 × 20 × 16 | 10 | 6 000 | Branches `__Neon` cyan |
| Alcôve | 12 × 12 × 12 | 4 | 1 500 | 12 exemplaires en anneau, même `MeshId` |
| Machines : Balles perforantes, Visée critique | 4 × 6 × 4 au maximum | 3 à 5 | 1 000 | Tourelle de toit et Foreuse : meshes de la run sur un socle |
| Capsule | 8 × 12 × 8 | 5 | 2 500 | 1 mesh en 3 couleurs : Normale `Creme`, Difficile `Alerte`, du Jour `Or` |
| Quai (6 modules) | 4 à 8 de côté | 1 à 3 | 400 | Kit modulaire sur la grille de 4 studs |
| Socle de la Galerie | 4 × 2 × 4 | 1 | 100 | Figurines = meshes des Zbires à l'échelle 1 |
| Accessoires de variantes | 1,5 au maximum | 1 | 150 | 16 meshes : à 10 éliminations, recoloration ; à 100 et 1 000, un accessoire sur `Attache_Tete` |

**Budget du Laboratoire** : 120 000 triangles et 60 meshes uniques au maximum.

## 3. Pipeline Blender → Roblox

**Scène Blender**
1. Dans `Scene Properties > Units`, régler `Unit System` sur `None` : 1 unité Blender = 1 stud.
2. Origine : le centre de l'emprise au sol, placé en (0, 0, 0). La face avant regarde vers -Y (vue Front, pavé 1).
3. Nommer les objets `Asset_Piece__CleCharte[__Neon]`, par exemple `Casque_Casque__Ardoise_Ombre` ou `Mine_Cristal__GemmeCyan__Neon`.
4. Nettoyer dans cet ordre : Apply All Transforms, Merge by Distance 0,001, Select Interior Faces puis Delete, Dissolve Limited à 1° (Delimit : Material), Triangulate (Beauty), Shade Flat, Recalculate Outside.

**Export FBX** (preset `Zsurvie_Roblox`) : Selected Objects, types Mesh et Empty, Scale 1,00, Apply Scalings `FBX All`, Forward `-Z`, Up `Y`, Apply Transform coché, Smoothing `Face`.

**Étalonnage** : le cube `Etalon` de 1 × 1 × 1 doit arriver avec une `Size` de (1, 1, 1). Sinon, on corrige `Scale Unit` dans l'importeur, jamais en redimensionnant dans Studio.

**3D Importer** : cocher `Anchored`, décocher `Merge Meshes` (une MeshPart par couleur), cocher le pivot sur l'origine de la scène et décocher `Insert Using Scene Position`. Si le `LookVector` du pivot ne sort pas par la face avant, changer `World Forward`.

**Après l'import**
- Régler le `PivotOffset` des pièces mobiles sur leur axe : tête de la Mini-Tourelle, canon de la Tourelle de toit, mèche de la Foreuse, ailes du Volant.
- Poser les `Attachment` : `Attache_TourelleToit`, `Attache_Foreuse`, `Attache_Canon` et `Attache_Tete`.
- Ranger les assets dans `ReplicatedStorage.Assets.Zbires`, `.Butin`, `.Defenses` et `.Equipement`. Le décor fixe va dans `Workspace.Prairie.Decor` et dans `Workspace.Laboratoire`.
- Poser un tag `CollectionService` sur le `Model`, puis lancer le script d'audit.
- Sources : `Zsurvie/Meshes/<Categorie>/<Asset>_v##.blend`.

## 4. Collisions et rendu

| Tag | Assets | `CollisionFidelity` | `RenderFidelity` | `CanCollide` / `CanQuery` | `CastShadow` |
|---|---|---|---|---|---|
| `Mesh_Zbire` | Zbires, Colosse, Pièce, Gemme | `Box` | `Precise` | false / false | Pièces `_Corps` seulement |
| `Mesh_Batiment` | Maison, Mine, Établi, Capsule, Alcôve, Arbre des Recherches | `Box` | `Precise` | false / false | true |
| `Mesh_Solide` | Muret, Mini-Tourelle, clôture | `Box` | `Automatic` | true / true | true |
| `Mesh_Rocher` | Rochers de la Prairie | `Hull` | `Automatic` | true / true | true |
| `Mesh_Decor` | Fleurs, nappe, Tapis Collant, buissons | `Box` | `Automatic` | false / false | false |
| `Mesh_Lointain` | Arbres-cubes, portails | `Box` | `Performance` | false / false | false |

- `Default` et `PreciseConvexDecomposition` sont interdits : sur mobile, ils coûtent de la mémoire physique et du temps de chargement.
- Les bâtiments ne collisionnent pas par leur mesh mais par des Parts invisibles, rangées dans un dossier `Collisions` (`Transparency` à 1, `CanCollide` à true) : un bloc de 16 × 14 × 16 pour la Maison, un bloc de 8 × 5 × 8 pour la Mine, et pour la Capsule le sol, 3 murs et le seuil.
- Chaque Zbire a une Part invisible `Hitbox` (`CanQuery` à true) pour le clic sur PC. Le tir automatique sur mobile et les validations passent par les positions calculées par le serveur. `CanTouch` est à false partout : l'effet du Tapis Collant est aussi calculé par le serveur.
- Avec la caméra en (0, 45, 28), tout reste à moins de 250 studs : `Automatic` donne donc le même rendu que `Precise`. On force `Precise` pour protéger les silhouettes et `Performance` pour la Lisière.
- `CollisionFidelity` et `RenderFidelity` ne se modifient pas en jeu. On les règle en mode édition avec le script ci-dessous.

## 5. Script d'audit (barre de commande de Studio)

```lua
-- Mode édition, après chaque import. Règle les MeshParts taguées Mesh_* et signale les écarts.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charte = require(ReplicatedStorage.Charte)
local palette = Charte.Couleurs or Charte
local CREME = palette.Creme or Color3.fromHex("F6E7C1")
local CF, RF = Enum.CollisionFidelity, Enum.RenderFidelity

local PRESETS = {
	Mesh_Zbire = { collision = CF.Box, rendu = RF.Precise, solide = false, ombre = false },
	Mesh_Batiment = { collision = CF.Box, rendu = RF.Precise, solide = false, ombre = true, grille = 4 },
	Mesh_Solide = { collision = CF.Box, rendu = RF.Automatic, solide = true, ombre = true, grille = 1 },
	Mesh_Rocher = { collision = CF.Hull, rendu = RF.Automatic, solide = true, ombre = true, grille = 1 },
	Mesh_Decor = { collision = CF.Box, rendu = RF.Automatic, solide = false, ombre = false, grille = 1 },
	Mesh_Lointain = { collision = CF.Box, rendu = RF.Performance, solide = false, ombre = false, grille = 1 },
}

local function couleur(cle: string): Color3?
	if typeof(palette[cle]) == "Color3" then
		return palette[cle]
	end
	local base, teinte = string.match(cle, "^(%w+)_(%a+)$")
	local c = base and palette[base]
	if typeof(c) ~= "Color3" then
		return nil
	elseif teinte == "Ombre" then
		return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
	elseif teinte == "Lumiere" then
		return c:Lerp(CREME, 0.2)
	end
	return nil
end

local function horsGrille(v: number, pas: number): boolean
	local r = v % pas
	return math.min(r, pas - r) > 0.01
end

local reglees, neons, alertes = 0, 0, 0
local function alerte(objet: Instance, message: string)
	alertes += 1
	warn(("[Audit] %s : %s"):format(objet:GetFullName(), message))
end

for tag, p in PRESETS do
	for _, racine in CollectionService:GetTagged(tag) do
		if not racine:IsA("PVInstance") then
			alerte(racine, "tag posé sur autre chose qu'un Model ou une Part")
			continue
		end
		local pivot = racine:GetPivot().Position
		if p.grille and (horsGrille(pivot.X, p.grille) or horsGrille(pivot.Z, p.grille)) then
			alerte(racine, ("pivot hors de la grille de %d studs"):format(p.grille))
		end
		local pieces = racine:GetDescendants()
		table.insert(pieces, racine)
		for _, part in pieces do
			if not part:IsA("MeshPart") then
				continue
			end
			local segments = string.split(part.Name, "__")
			local teinte = segments[2] and couleur(segments[2])
			if teinte then
				part.Color = teinte
			else
				alerte(part, "clé de Charte absente ou inconnue dans le nom")
			end
			if (part.Size - part.MeshSize).Magnitude > 0.01 then
				alerte(part, "Size différente de MeshSize : corriger l'échelle dans Blender")
			end
			local neon = segments[3] == "Neon"
			part.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
			part.TextureID = ""
			part.CollisionFidelity = p.collision
			part.RenderFidelity = p.rendu
			part.Anchored = true
			part.CanCollide = p.solide
			part.CanQuery = p.solide
			part.CanTouch = false
			part.CastShadow = p.ombre or string.find(part.Name, "_Corps", 1, true) ~= nil
			reglees += 1
			if neon and part:IsDescendantOf(workspace) then
				neons += 1
			end
		end
	end
end

print(("[Audit] %d MeshParts réglées, %d alertes, %d Neon dans Workspace (plafond : 150)"):format(reglees, alertes, neons))
```

## 6. Ordre de production

| Priorité | Phase | Assets | Objectif |
|---|---|---|---|
| P0 | 1 | Cube étalon, Marcheur, Pièce, Gemme, proxys de collision de la Maison, de la Mine et de l'Établi | Valider le pipeline, l'échelle et la lisibilité sur mobile |
| P1 | 3 | Les 7 autres Zbires, le Mini-Gluant, la Maison (3 états), la Mine, l'Établi, le Muret, la Mini-Tourelle, le Tapis Collant, le Blaster, le Sac à dos | Une run jouable |
| P2 | 2 et 3 | Colosse, Tourelle de toit, Foreuse, portail, arbres-cubes, kit Prairie | Le Jour du Colosse et l'ambiance |
| P3 | 3 | Capsule, Quai, Alcôve, Arbre des Recherches, 2 machines, Doc Boulon, socle | Le Laboratoire |
| P4 | 5 | 16 accessoires de variantes | Donner envie de revenir |
| P5 | 6 | Audit des deux places, profilage sur l'Android 3 Go | `GraphicsMeshParts` ≤ 40 Mo dans la Developer Console avec 60 Zbires |

### 🪶 Optimiseur d'assets — Ilan Berthet
# Zsurvie : budget performance et optimisation des assets

*Ilan Berthet, Optimiseur d'assets, Construction & Modélisation*

L'appareil de référence est un Android à 3 Go de RAM. Il doit tenir 30 FPS avec 6 Survivants, 60 Zbires et le Colosse, sous 800 Mo. Un asset qui dépasse son budget n'entre pas dans la place. Le script d'audit (§ 8) tranche avant chaque publication.

## 1. Budgets de la Prairie (place de run)

`StreamingEnabled` est désactivé (canon), donc toute la place reste en mémoire. Le plafond canon de 10 000 Parts s'applique au pic : Jour du Colosse et 60 Zbires.

| Poste | Parts | Triangles | Notes |
|---|---|---|---|
| Décor statique (Maison, Mine, Prairie, Lisière, Établi, portails) | ≤ 6 800 | ≤ 220 000 | tout en `Anchored` |
| Zbires (60 × 30 au maximum, cible 12) | ≤ 1 800 | ≤ 60 000 (1 000 chacun) | Mini-Gluants compris |
| Colosse | ≤ 30 | ≤ 5 000 | en MeshParts, règle des 30 Parts respectée |
| Défenses (6 × 3 × 25) | ≤ 450 | ≤ 14 400 | 800 triangles chacune |
| Survivants (avatars) | ≈ 240 | hors contrôle | comptés, jamais optimisés |
| Pools d'éclats et de pièces (client) | ≤ 300 | ≤ 15 000 | recyclés, jamais détruits |
| Marge | 380 | — | réservée aux correctifs, pas au décor |

| Autre budget | Plafond |
|---|---|
| Triangles à l'écran (mobile) | ≤ 120 000 |
| Draw calls à l'écran | ≤ 500 |
| Instances totales | ≤ 30 000 |
| Textures uniques | ≤ 20, `GraphicsTexture` ≤ 60 Mo |
| Sons | ≤ 40 assets, 16 simultanés |
| Parts `Neon` | ≤ 150 |
| Lumières (`PointLight`, `SpotLight`, `SurfaceLight`) | ≤ 12, toutes en `Shadows = false` |
| `ParticleEmitter` | `Rate` ≤ 20, ≤ 24 émetteurs actifs |
| `BillboardGui` actifs | ≤ 20, `MaxDistance` 60 |
| Mémoire | ≤ 800 Mo au total, dont `PlaceMemory` ≤ 350 Mo |
| Flux réseau des Zbires | ≈ 6 Ko/s par client |

Chaque zone reçoit une part fixe des Parts `Neon` et des lumières :

| Élément | Neon | Lumières |
|---|---|---|
| Maison (fenêtres) | 16 | 2 |
| Mine (cristaux) | 30 | 2 |
| Portails violets de la Lisière | 24 | 4 |
| Mini-Tourelles (1 voyant chacune) | 18 | 0 |
| Établi | 6 | 1 |
| Colosse (yeux) | 6 | 1 |
| Marge | 50 | 2 |

Les Zbires, les tirs et les pièces n'ont ni Neon ni lumière. Le flash du Blaster est un simple `ParticleEmitter:Emit(1)`.

## 2. Budgets du Laboratoire (lobby, 12 joueurs)

| Poste | Parts | Triangles |
|---|---|---|
| Hub, Arbre des Recherches et Doc Boulon | ≤ 4 000 | ≤ 90 000 |
| 12 Alcôves, machines comprises | 12 × ≤ 500 | 12 × ≤ 12 000 |
| Quai des Capsules | ≤ 1 500 | ≤ 40 000 |
| Galerie des Zbires | ≤ 1 500 | ≤ 40 000 |
| **Total** | **≤ 13 000** | **≤ 314 000** |

- Une machine de recherche compte 40 Parts et 1 000 triangles au maximum.
- Les plafonds de Neon (150) et de lumières (12) sont les mêmes qu'à la Prairie.
- Les figurines de la Galerie reprennent les `MeshId` des Zbires. On ne crée aucun nouvel asset, et les deux places partagent le cache de téléchargement.
- Doc Boulon est animée par un `AnimationController` et un `Animator`, sans `Humanoid`.
- Les machines portent le tag `MachineAnimee`. Un seul `LocalScript` les anime, et seulement à moins de 60 studs de la caméra.

## 3. StreamingEnabled

### Prairie : désactivé (canon)
L'arène mesure 220 × 220 studs. Sur un téléphone en paysage, la caméra (0, 45, 28) avec un `FieldOfView` de 50 voit environ 160 studs de large. Le streaming n'apporterait que des objets qui apparaissent en retard. En échange, le budget du § 1 est un plafond dur.

### Laboratoire : activé
Le canon ne dit rien du lobby. Je l'active parce que les 12 Alcôves se remplissent de machines au fil de la progression des joueurs. **Victor Lanoue doit valider ce choix.** L'empreinte du lobby est limitée à 240 × 240 studs.

| Propriété de `Workspace` | Valeur |
|---|---|
| `StreamingEnabled` | `true` |
| `ModelStreamingBehavior` | `Improved` |
| `StreamingIntegrityMode` | `MinimumRadiusPause` |
| `StreamingMinRadius` | 96 |
| `StreamingTargetRadius` | 256 |
| `StreamOutBehavior` | `Opportunistic` |

Sur PC, tout le lobby finit chargé. Sur l'Android de 3 Go, seul le rayon de 96 studs est garanti.

| Modèle | `ModelStreamingMode` | `LevelOfDetail` |
|---|---|---|
| Doc Boulon, les 3 Capsules, hub d'apparition | `Persistent` | `Disabled` |
| `Alcove_01` à `Alcove_12` | `PersistentPerPlayer` (pour le propriétaire) | `StreamingMesh` |
| Arbre des Recherches, figurines de la Galerie | `Atomic` | `StreamingMesh` |
| Décor d'ambiance | `Default` | `Disabled` |

Au Laboratoire, aucun `LocalScript` ne suppose qu'une instance est déjà chargée. Il passe par `WaitForChild` avec un délai, ou par `CollectionService:GetInstanceAddedSignal`.

```lua
-- ServerScriptService.StreamingLabo (ModuleScript, place Laboratoire)
-- Appelé par le système d'attribution des Alcôves et par le tutoriel de Doc Boulon.
local StreamingLabo = {}

function StreamingLabo.lierAlcove(player: Player, alcove: Model)
	-- L'Alcôve doit être en ModelStreamingMode = PersistentPerPlayer
	alcove:AddPersistentPlayer(player)
end

function StreamingLabo.delierAlcove(player: Player, alcove: Model)
	alcove:RemovePersistentPlayer(player)
end

-- À appeler avant chaque plan caméra scripté (tutoriel, nouvelle machine)
function StreamingLabo.precharger(player: Player, position: Vector3): boolean
	local ok, err = pcall(player.RequestStreamAroundAsync, player, position, 3)
	if not ok then
		warn(("[StreamingLabo] %s : %s"):format(player.Name, tostring(err)))
	end
	return ok
end

return StreamingLabo
```

## 4. LOD des Zbires dans la Prairie

Sans streaming, le LOD est géré par script.

- **Côté serveur :** il ne crée aucune Part de Zbire. Il garde position, PV et cible dans une table, à 10 Hz. Il diffuse un `buffer` par `UnreliableRemoteEvent`, soit 10 octets par Zbire : emplacement en `uint8`, x, y et z en `int16` au dixième de stud, PV en `uint16`, état en `uint8`. Les tirs sont validés sur ces données, avec une sphère de collision par type de Zbire.
- **Côté client :** chaque client clone ses Zbires depuis un pool (`ReplicatedStorage.ZbiresModeles`). Chaque Zbire a une racine en `Anchored` et des membres reliés par `Motor6D`. Toutes les parts sont en `CanCollide`, `CanTouch` et `CanQuery = false`.
- **Déplacement :** toutes les racines bougent en un seul appel, `workspace:BulkMoveTo(racines, cframes, Enum.BulkMoveMode.FireCFrameChanged)`.

| Palier (distance au Survivant local) | Rafraîchissement | Animation |
|---|---|---|
| Proche, moins de 50 studs | à chaque image, avec interpolation | écrasement et étirement en 0,15 s, membres animés |
| Moyen, de 50 à 100 studs | 20 Hz | rebond seul |
| Loin, plus de 100 studs | 5 Hz | figée |

- **Éclatement :** 6 cubes tirés du pool (120 cubes en vol au maximum) et un `ParticleEmitter:Emit(8)` à texture carrée, pendant 0,6 s.
- **Pièces :** seul leur propriétaire les voit, elles sont donc 100 % côté client. Au-delà de 40 pièces au sol, une nouvelle pièce fusionne à l'écran avec la plus proche. Seul le serveur crédite les pièces, après avoir vérifié la distance.
- **Maison :** un seul état est présent dans `Workspace`. Les états 2 et 3 reprennent la base commune et n'ajoutent ou ne retirent que 120 Parts de dégâts au maximum.

## 5. Textures légères

- **Palette unique `Charte_Palette` :** 128 × 128 px, en grille de 8 × 8 cases de 16 px. Elle contient les 33 teintes de `ReplicatedStorage.Charte` (11 couleurs × 3 teintes). Tout MeshPart de décor place ses UV au centre des cases. On obtient un seul `TextureID`, une instanciation maximale et environ 64 Ko de mémoire.
- **Pixel art net :** Roblox lisse les textures 3D (filtrage bilinéaire). Chaque motif est donc agrandi 4 fois au plus proche voisin avant l'import : un visage de 32 px devient 128 px.
- **Atlas des Zbires :** les 8 Zbires, le Mini-Gluant et le Colosse partagent une seule texture de 512 × 512.
- **Interface :** les icônes sont regroupées sur des planches de 1024 × 1024, lues avec `ImageRectOffset` et `ImageRectSize`, en `ResampleMode = Enum.ResamplerMode.Pixelated`.
- **Interdits :** `SurfaceAppearance`, textures de plus de 1024 px, `Decal` sur un objet répété, canal alpha sans usage.

## 6. Sons

- Le client utilise un pool de 16 `Sound`. Quand il est plein, le son le moins prioritaire est coupé. Ordre de priorité : Colosse, alerte de la Maison, tirs du joueur, tirs des autres, éclats, pièces.
- Trois `SoundGroup` : Musique, Effets et Interface.
- Les effets sont en mono et durent 1,5 s au maximum. Les musiques sont des boucles de 60 s au maximum.
- Réglage des sons 3D : `RollOffMode = InverseTapered`, `RollOffMaxDistance = 80`.
- Un même son joue au maximum 4 fois par 0,1 s.

## 7. Règles pour toute l'équipe

1. Un objet répété plus de 10 fois devient un `MeshPart` qui partage le même `MeshId`. Un arbre de la Lisière est un seul MeshPart de 300 triangles au maximum, pas 40 Parts. On garde 4 variantes d'arbre au maximum.
2. Avant l'import d'un maillage voxel, on supprime les faces internes et on fusionne les faces coplanaires (greedy meshing).
3. Pas d'`UnionOperation` dans la Prairie. Chaque Union a une géométrie unique et ne peut pas être instanciée. On l'exporte en MeshPart.
4. Réglage du décor :
   - `Anchored = true` et `CanTouch = false` ;
   - `CanQuery = false`, sauf sur le sol et les murs ;
   - `CastShadow = false` pour les objets de moins de 2 studs.
5. Réglage des `MeshPart` :
   - `CollisionFidelity = Box`, ou `Hull` pour la Maison ;
   - jamais `PreciseConvexDecomposition` ;
   - `RenderFidelity = Automatic`, sauf si la silhouette casse en dézoomant.
6. Pas de `Script` par objet. Un seul système par famille d'objets, via `CollectionService`.
7. Post-effets : ni `DepthOfFieldEffect` ni `SunRaysEffect`. `BloomEffect.Size` reste à 24 au maximum.
8. Le Terrain reste vide et aucun `Humanoid` n'est placé dans une place.

## 8. Script d'audit (barre de commande de Studio)

```lua
-- Audit budget Zsurvie : à lancer en édition, dans chacune des deux places
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local estPrairie = not workspace.StreamingEnabled
local BUDGET = {
	Parts = if estPrairie then 6800 else 13000, -- décor statique seul
	Neon = 150, Lumieres = 12, Textures = 20, Sons = 40, Instances = 30000,
}
local compte = { Parts = 0, Neon = 0, Lumieres = 0, Instances = 0, CanTouch = 0, Ombres = 0 }
local textures, sons, alertes = {}, {}, {}

local function alerte(motif: string, inst: Instance)
	table.insert(alertes, motif .. " : " .. inst:GetFullName())
end

local function taille(t: { [any]: boolean }): number
	local n = 0
	for _ in t do n += 1 end
	return n
end

for _, inst in workspace:GetDescendants() do
	compte.Instances += 1
	if inst:IsA("BasePart") then
		compte.Parts += 1
		if inst.Material == Enum.Material.Neon then compte.Neon += 1 end
		if inst.Anchored and inst.CanTouch and not CollectionService:HasTag(inst, "Interactif") then
			compte.CanTouch += 1
		end
		if inst.CastShadow and math.max(inst.Size.X, inst.Size.Y, inst.Size.Z) < 2 then
			compte.Ombres += 1
		end
		if inst:IsA("MeshPart") then
			if inst.TextureID ~= "" then textures[inst.TextureID] = true end
			if inst.CollisionFidelity == Enum.CollisionFidelity.PreciseConvexDecomposition then
				alerte("Collision précise", inst)
			end
		elseif inst:IsA("UnionOperation") and estPrairie then
			alerte("Union dans la Prairie", inst)
		end
	elseif inst:IsA("Light") then
		compte.Lumieres += 1
		if inst.Shadows then alerte("Lumière avec ombres", inst) end
	elseif inst:IsA("ParticleEmitter") and inst.Rate > 20 then
		alerte("Rate supérieur à 20", inst)
	elseif inst:IsA("Decal") then -- couvre aussi Texture
		textures[inst.Texture] = true
	elseif inst:IsA("SurfaceAppearance") or inst:IsA("Humanoid") then
		alerte(inst.ClassName .. " interdit", inst)
	end
end

for _, racine in { SoundService, ReplicatedStorage, workspace } do
	for _, inst in racine:GetDescendants() do
		if inst:IsA("Sound") then sons[inst.SoundId] = true end
	end
end

local cellules = workspace.Terrain:CountCells()
if cellules > 0 then table.insert(alertes, ("Terrain non vide : %d cellules"):format(cellules)) end

for _, m in {
	{ "Parts", compte.Parts, BUDGET.Parts }, { "Neon", compte.Neon, BUDGET.Neon },
	{ "Lumieres", compte.Lumieres, BUDGET.Lumieres }, { "Textures", taille(textures), BUDGET.Textures },
	{ "Sons", taille(sons), BUDGET.Sons }, { "Instances", compte.Instances, BUDGET.Instances },
} do
	print(("%-10s %6d / %-6d %s"):format(m[1], m[2], m[3], if m[2] <= m[3] then "OK" else "DÉPASSE"))
end
print(("CanTouch à couper : %d | Ombres de petits objets : %d"):format(compte.CanTouch, compte.Ombres))
for _, texte in alertes do warn(texte) end
print(("Audit terminé : %d alerte(s)"):format(#alertes))
```

## 9. Checklist avant publication

- [ ] L'audit du § 8 ne montre aucun « DÉPASSE » ni aucune alerte, dans les deux places.
- [ ] `Workspace.StreamingEnabled` vaut `false` sur la Prairie et `true` au Laboratoire.
- [ ] Test sur Android 3 Go avec 6 comptes, un Jour du Colosse et 60 Zbires : 30 FPS ou plus pendant 5 min, et `Stats:GetTotalMemoryUsageMb()` sous 800.
- [ ] Mémoire stable à ± 5 % entre le jour 5 et le jour 15. Au-delà, pools ou connexions fuient.
- [ ] Statistiques de rendu (Ctrl+Maj+F2) : 500 draw calls et 120 000 triangles à l'écran au maximum.
- [ ] Réseau (Ctrl+Maj+F3) : 50 Ko/s reçus par client au maximum.
- [ ] MicroProfiler côté serveur : boucle des Zbires à 4 ms par tick au maximum.
- [ ] Le compteur du pool ne dépasse jamais 16 sons simultanés.
- [ ] Laboratoire : Quai, Alcôve et Galerie s'affichent sans trou, et aucun `Infinite yield` n'apparaît en sortie.
- [ ] Téléportation vers la Prairie en 10 s au maximum sur l'Android de référence.
- [ ] Aucune texture de plus de 1024 px, aucun `SurfaceAppearance`, Terrain vide.

## 💻 Scripting Luau

### ⚙️ Scripteuse gameplay — Louise Fabre (révisé)
# Scripts de gameplay de Zsurvie : Horde, Blaster et rendu des Zbires

*Louise Fabre, scripteuse gameplay (Scripting Luau). Révision du 02/10. Code complet dans `scripts/a26/` (11 fichiers, emplacement Roblox en 1re ligne). Repère a11 : origine au centre de la Maison, sol à Y = 0.*

## 1. Fichiers

| Fichier | Emplacement | Rôle |
|---|---|---|
| `Config`, `ZbiresDefs`, `BlasterStats`, `Reseau` | `ReplicatedStorage.Partage` | Constantes, bestiaire (+ `ZbiresDefs.Jours` de a06), courbes du Blaster, remotes |
| `HordeService` | `ServerScriptService.Services` | Horde + portails (absorbe `ServerScriptService.Horde.Portails` de a14) |
| `BlasterService`, `StatsSurvivant` | idem | Tir serveur ; étourdissement, allures, déblocage, collisions |
| `Demarrage` | `ServerScriptService` | Branchements, `ModeTest` |
| `ZbiresRendu`, `BlasterControleur` | `StarterPlayerScripts.Controleurs` | Pool de 70 modèles ; la seule boucle de tir auto |
| `ClientDemarrage` | `StarterPlayerScripts` | Pool, contrôleurs, `ResetButtonCallback` |

**Supprimés :** le `RemoteEvent` fiable `EvenementsZbires`, `ImpactsTir` et l'échange « pret »/« liste ». Un joueur qui arrive reconstruit la horde dès le paquet `EtatZbires` suivant, qui porte le type de chaque Zbire.

## 2. Contrats

| API | Appelant | Rôle |
|---|---|---|
| `HordeService.demarrerJour(j)` | JourService, au début des 80 s | Lit `ZbiresDefs.jour(j)`, suit la rampe, ajoute le Colosse les jours 5, 10, 15… |
| `ajouterALaFile(type, n?, cframe?)` | Gluant, tests | Avec `cframe` : sortie sur place, en tête de file, sans alerte |
| `definirModificateurs({pv, vitesse})` | Défi du Jour, Zbire de la Semaine | Facteur « Défi » des PV |
| `infligerDegats(id, dmg, critique, joueur?)` → `(vaincu, reel, reduit)` | Blaster, tourelles | Seule porte des dégâts, refusée avant `ciblableA` |
| `plusProche`, `dansRayon`, `estCiblable` | Tourelles | Zbires ciblables seulement |
| `enregistrerObstacle(cle, pos, rayon, frapper(degats))`, `on("maison", fn(degats))` | DefensesService, MaisonService | Un seul appel par tick, dégâts cumulés |
| `on("vaincu", fn(type, pos, tueur?, critique))` | Economie, GalerieService | Pièces × `BlasterStats.butin(tueur)` |
| `StatsSurvivant.definirAllurePhase("Horde"/"Repit")`, `definirAllure(joueur, "Reparation"/nil)` | JourService, MaisonService | Transmis à `GardienMouvement.definirVitesse` |
| `ZbiresRendu.chercher(positionEcran, tolerancePx)`, `position(id)` | a28 | Tap vers identifiant ; position affichée |
| `BlasterControleur.definirCiblePrioritaire(id?)` | a28 | Cible forcée jusqu'à sa disparition |
| `ZbiresRendu.brancherAnimateur(fn(actifs, dt))` | ZbireAnimateur (a38) | Appelé juste après le `BulkMoveTo` |

**Flux `Evenements` (serveur vers clients) :** `apparition(id, type, x, z, alerte)` ; `impact`, `critique` ou `coupReduit(userId, id, x, z, explose)`, un message par tir ; `eclatement(id, type, x, z, critique)` ; `division(id, x, z)` ; `bond(id)` ; `onde(id, x, z, rayon, preavis)`.

## 3. BlasterStats : une seule courbe sur 10 niveaux

| Attribut du `Player` | Niv 0 | Par niveau | Maximum |
|---|---|---|---|
| `NivDegats` | 10 | + 2 | 30 (niv 10) |
| `NivCadence` | 4 tirs/s | + 0,2 | 6 tirs/s (niv 10) |
| `NivPortee` = rayon du tir auto | 40 studs | + 1,2 | 52 studs (niv 10) |
| `NivExplosives` | 0 % | + 5 % de chance | 50 % (niv 10), rayon 6 studs, 50 % des dégâts de base |
| `NivButin` | × 1 | + 10 % | × 1,5 (niv 5) |
| `RechViseeCritique` | 5 % | + 2 points | 25 % (niv 10), dégâts × 2 |
| `RechBallesPerforantes` | 0 | 45 % + 5 points | 95 % sur le 2e Zbire (niv 10) |

Le Casqué subit 50 % des dégâts hors critique. À Visée critique 10, son facteur moyen vaut 0,5 × 0,75 + 2 × 0,25 = **0,875** : le critique reste la réponse au Casqué. a07 et a09 lisent `BlasterStats.valeur(stat, niveau)` et `BlasterStats.MAX`.

## 4. HordeService

**Formules :**
- PV = base × 1,15^(jour − 1) × 1,3^Tension × (1 + 0,35 × (actifs − 1)) × Défi.
- Effectif = `JOURS[j].zbires` × (1 + 0,2 × (actifs − 1)), arrondi puis mélangé.
- `actifs` = Survivants pour qui `Economie.estActif` est vrai, entre 1 et 6.
- Colosse : 2 500 × 1,15^(jour − 1) × coop, sans Tension ni Défi. Enragé 60 s après sa sortie : vitesse × 1,5, dégâts sur la Maison × 3, attribut `workspace.ColosseEnrage`.
- Contact de la Maison : 4 × 1,15^(jour − 1) PV/s × `multMaison` (Costaud 2, Colosse 3, Doré 0, autres 1). Même débit contre un Muret.

**Portails (ex-a14) :**
- Parts taguées `PortailZbire`, placées par `Plan.positionPortail(Index)` (attribut `Index`), sinon par leur pivot. Sans tag : `Plan.positionPortail(1 à 8)`.
- `JOURS[j].portails` ouvre les N premiers. Tirage pondéré par l'attribut `Poids` (1 par défaut), jamais deux fois de suite le même portail.
- Alerte 1,5 s (Colosse : 4 s au Grand Portail), puis sortie. `ciblableA` = sortie + 0,8 s : avant, ni tir, ni tourelle, ni coup aux Survivants.
- `ZbiresDefs.rampe(t / 80)` donne la part cumulée du programme mise en file.

```lua
-- 3 sorties par tick au plus. Une entrée ne sort que si le plafond de 60 (Colosse exclu) ET le quota
-- de rendu de son type (pool client de 70) ont une place ; sinon les entrées suivantes passent devant.
local function traiterFile(maintenant: number)
	local crees, i = 0, 1
	while i <= #file and crees < Config.APPARITIONS_PAR_TICK do
		local entree = file[i]
		local boss = ZbiresDefs.Types[entree.type].boss == true
		local quota = Config.QUOTAS_RENDU[entree.type] or 0
		if (compte[entree.type] or 0) < quota and (boss or nbDansPlafond < Config.MAX_ZBIRES) then
			table.remove(file, i)
			creer(entree, maintenant)
			crees += 1
		else
			i += 1
		end
	end
end
```

**Réseau :** `EtatZbires` (`UnreliableRemoteEvent`), 9 octets par Zbire : 61 × 9 = 549 octets par tick, 5,5 Ko/s par client.

| Octets | 0-1 | 2-3 | 4-5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|
| Champ | id u16 | x i16 (1/10 stud) | z i16 | PV u8 | cap u8 | type (4 bits) + état : ciblable, bond, enragé, contact |

## 5. ZbiresRendu : le contrat figé

- **Pool :** `ZbiresRendu.preparer()` crée 70 modèles pendant l'Arrivée, 5 par image (~14 images). Ils sont parentés à `workspace.Zbires`, portent l'attribut `Id` (0 = libre) et attendent en (0, −200, 0).
- **Quotas** (`Config.QUOTAS_RENDU`) : Marcheur 18, Rapide 10, MiniGluant 10, Casque 8, Sauteur 6, Costaud 5, Gluant 5, Volant 5, Dore 2, Colosse 1.
- **Modèle** (`ReplicatedStorage.Modeles.Zbires.<Type>`, a24) : `Racine` ancrée de `Transparency` 1, plus 3 à 5 `MeshPart` (700 triangles au plus pour le Zbire) reliées par `Motor6D` aux noms de a38. `CastShadow`, `CanCollide`, `CanQuery` et `CanTouch` à false. Un `warn` par type sans modèle (cube greybox) ou hors contrat.
- **À chaque image** (`PreRender`) : interpolation du 10 Hz, un seul `BulkMoveTo` (Racines actives, modèles à garer, disque de l'onde), puis l'animateur de a38. Étiquette MicroProfiler : `ZbiresRendu`.
- **Retour au pool** sur `eclatement`, ou après 0,5 s sans nouvelle (Doré enfui, fin de run). Aucun `Instance.new`, `Clone` ni `Destroy` après `preparer()`.
- **Coût :** 61 Racines déplacées, 366 Parts au plus au lieu de 1 800.

```lua
	for _, e in aGarer do
		if e.id == 0 then -- pas repris entre-temps
			table.insert(racines, e.racine)
			table.insert(cadres, PARKING)
		end
	end
	table.clear(aGarer)
	if #racines > 0 then
		workspace:BulkMoveTo(racines, cadres, Enum.BulkMoveMode.FireCFrameChanged)
	end
	if animateur then
		animateur(actifs, dt) -- ZbireAnimateur (a38) : Motor6D.Transform, même budget de 3 ms
	end
	debug.profileend()
```

## 6. Tir, mouvement et déblocage

- **BlasterControleur :** une seule connexion `Heartbeat`. La cible prioritaire de a28 passe d'abord, sinon le Zbire ciblable et visible le plus proche, avec 0,4 s d'hystérésis. 12 traçantes recyclées : Ardoise sur un `coupReduit`, 0,6 stud d'épaisseur sur un `critique`.
- **BlasterService :** `Validation.brancher(Reseau.DemandeTir, { arguments = { "number" }, maxParSeconde = 10 }, surDemandeTir)`, puis seau à jetons (2 tirs d'avance), portée + rayon + 4 studs, `ciblableA`.
- **StatsSurvivant** n'écrit plus `WalkSpeed` ni `JumpHeight`. Il lit `ReplicatedStorage.Config.Mouvement` (`VITESSE_HORDE` 18, `VITESSE_REPIT` 24, `VITESSE_REPARATION` 8, `ETOURDI_DUREE` 2) et appelle `GardienMouvement.definirVitesse` et `etourdir`. Seul GardienMouvement lit `SAUT_SURVIVANT`.
- **Déblocage :** `ResetButtonCallback` reçoit un `BindableEvent` qui envoie `DemandeDeblocage` (1 toutes les 10 s). Le serveur revérifie (Validation + horodatage), puis appelle `GardienMouvement.teleporter` vers le `SpawnLocation` libre le plus proche (aucun autre Survivant à moins de 4 studs), 3 studs au-dessus.
- **Collisions :** groupes `Survivants` et `Defenses` non collidables entre eux. Les Murets bloquent toujours les Zbires, simulés côté serveur.

## 7. Tests dans Studio

1. Workspace : `ModeTest` = true, `JourTest` = 5 pour le Colosse d'emblée. Test > Clients and Servers, 2 joueurs.
2. Casqué, Visée critique 10, 1 000 tirs : dégâts moyens ≈ 0,875 × base (`BlasterStats.facteurMoyenCasque(10)`).
3. Tir dans les 0,8 s après la sortie : refusé, PV inchangés.
4. Gluant : 2 Mini-Gluants sur place, sans alerte. Volant au-dessus des Murets.
5. 3 Murets en (−13, 0, ±4) et (−18, 0, 0) : on les traverse. Échap > Réinitialiser : spawn libre ; 2e essai avant 10 s refusé.
6. 15 s de Répit à 24 et un Ressort : 0 correction de GardienMouvement.
7. Android 3 Go, 60 Zbires : `HordeTick` < 1 ms, `ZbiresRendu` (animateur compris) < 3 ms par image, `EtatZbires` ≈ 5,5 Ko/s (Developer Stats > Network).

## 8. Décisions et écarts

- **Quotas de rendu par type**, appliqués aussi par le serveur : un ajout au plafond de 60 du canon, cohérent avec « les suivants attendent leur tour ».
- **`multMaison` du Colosse à 3** (12 PV/s au jour 1, 36 enragé) : ma proposition, à valider par Victor Lanoue.
- **Volant à 3,5 studs du sol :** il survole un Muret de 3 studs, sommet vers 6 studs.
- **Le Colosse vient de `demarrerJour`**, plus de JourService.
- **Les entrées appartiennent à a28 :** BlasterControleur ne lit ni souris ni tap.
- **À valider par Victor Lanoue (inchangé) :** le Doré ne frappe pas la Maison ; le Colosse s'immobilise pendant l'annonce de son onde ; le Volant ne frappe pas les Survivants.
- **Identifiants ASCII** (`Dore`, `Casque`, `MiniGluant`), nom du canon dans `def.nom`. Les Recherches arrivent par le DataStore, jamais par `TeleportData`.

### 🗄️ Ingénieur systèmes serveur — Adrien Malouf (révisé)
## 1. Un store, un profil

- **Store unique** : `DataStoreService:GetDataStore("Zsurvie_Joueurs_v1")`, clé `J_<UserId>`, dans les deux places. En Studio, `Zsurvie_Joueurs_Studio` (*Game Settings > Security > Enable Studio Access to API Services*).
- **Supprimés** : `Gemmes_v1`, `Zsurvie_Profils_v1` (clés `Survivant_` et `Joueur_`), `Boutique_v1`, `Cosmetiques_v1`, `PeluchesSecretes_v1` et le store de `Transactions`. a06, a07, a13, a15, a22, a29 et a46 retirent leurs `GetDataStore` et passent par `Donnees`.
- **`UpdateAsync` seulement**, sous `pcall`, 5 essais (attentes 1, 2, 4, 8 s), budget vérifié, `{UserId}` joint à chaque écriture.
- **Verrou de session** `{Id, JobId, PlaceId, Horodatage}` : attente 10 × 3 s, verrou mort après 180 s. Un serveur dépossédé n'écrit plus jamais. Une écriture toutes les 7 s par clé au plus.

| Déclencheur | Appel |
|---|---|
| Jour franchi (Prairie) | `Run.JourFranchi` → `SauvegarderTous(true)` |
| Recherche, Foreuse, réglage, déblocage | `Planifier` (écritures regroupées) |
| Achat Robux | `EnregistrerAchat`, synchrone avant `PurchaseGranted` |
| Autosave | toutes les 60 s, rafraîchit le verrou |
| Départ, téléport | `Liberer` |
| `BindToClose` | `Run.Clore` (Prairie), puis `FermerTout` (27 s) |

## 2. `SchemaJoueur` version 2

| Champ | Défaut | Règle |
|---|---|---|
| `Gemmes`, `GemmesCumul`, `XP` | 0 | écrits par `Donnees` seul |
| `Recherches.TourelleDeToit`, `.BallesPerforantes`, `.ViseeCritique`, `.Foreuse` | 0 | niveaux 0 à 5 |
| `Foreuse = {DerniereRecolte, Reste}`, `TurboForeuseFin` | 0 | a08 ; `Reste` garde la gemme entamée |
| `RunsCreditees` | `{}` | `[runId] = gemmes déjà versées` |
| `RunsTerminees` | `{}` | 20 derniers `runId` clos |
| `AccueilEtape` | 0 | a50, remplace `Tutoriel` et `EtapeOnboarding` (a10) |
| `DernierBonus`, `Calendrier = {Case, CleJour}` | `""`, `{0, ""}` | clés `Temps.cleJour()` |
| `Secrets = {trouves, jour}` | `{{}, ""}` | a13 |
| `Chapeaux`, `JourChapeau`, `Tampons`, `JourTampon` | `{}`, `""` | a15 |
| `Peluches` | `{}` | a22 |
| `Cosmetiques.Possedes`, `.Equipes`, `Achats[PurchaseId]` | `{}`, `"Base"`, `{}` | a46 ; `Achats` = `os.time()`, purgé à 90 jours |
| `Reglages` | `VolumeMusique` 0,6, `VolumeEffets` 0,8, `EffetsReduits` false, `Secousses` true, `TirAuto` true | liste blanche |
| `Records`, `Eliminations`, `Quotidien.CleDefi`, `ZbireSemaine.CleSemaine` | 0, `""` | inchangés |

- **Migration v1 → v2** : `AccueilEtape = max(Tutoriel.Etape, EtapeOnboarding)`. `Musique`, `Effets` et `Vibrations` deviennent `VolumeMusique`, `VolumeEffets` et `Secousses`. La liste `Achats` devient un dictionnaire. `Reconcilier` pose les nouveaux champs. Environ 2,5 Ko par profil.
- **Jamais sauvegardés** : Pièces, niveaux d'Établi, défenses, étourdissement.
- **Profil illisible** : tout se joue dans le transform d'`UpdateAsync`. `Reconcilier` tente `tonumber` sur `Gemmes` et `Recherches.*`. En cas d'échec, le chargement est refusé (`return nil`, donc rien n'est écrit). L'incident part en `warn` et en `AnalyticsService:LogCustomEvent("ProfilCorrompu")`. `restaurer` relit ensuite les 10 dernières versions (`ListVersionsAsync`, `GetVersionAsync`) et réécrit la plus récente qui passe `Preparer`. Sinon, `Kick` rassurant, store intact. **Écart assumé** : même protection pour `Cosmetiques.Possedes` et `Achats`, payés en Robux.

## 3. Gemmes : une seule porte

| Source | Plafond par appel | Place | `runId` |
|---|---|---|---|
| `Jour` | 210 (J15 : 70 × 1,5 × 2) | Prairie | oui |
| `Mine` | 200 | Prairie | oui |
| `Dore` | 50 | Prairie | oui |
| `FinDeRun` | 1 500 | Prairie | oui |
| `Foreuse` | 216 (27 × 8 h) | Laboratoire | non |
| `DefiDuJour` | 150 | Prairie | non |

Toute autre source lève une erreur : `ZbireSemaine` n'existe plus. La Prairie crée `Run.Id = HttpService:GenerateGUID(false)` au démarrage. Chaque `AjouterGemmes(joueur, n, source, Run.Id)` ajoute aussi `n` à `RunsCreditees[runId]`. Quand la Maison tombe, `Run.Terminer(totaux, jour)` appelle :

```lua
function Donnees.CrediterRun(joueur: Player, runId: string, totalRun: number, terminer: boolean?): number
	assert(type(runId) == "string" and runId ~= "", "CrediterRun exige le runId de la Prairie")
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		if table.find(p.RunsTerminees, runId) then
			return false -- run déjà close : rien n'est versé deux fois
		end
		verse = verser(p, totalRun - (p.RunsCreditees[runId] or 0), "FinDeRun", runId)
		if terminer then
			p.RunsCreditees[runId] = nil
			table.insert(p.RunsTerminees, runId)
			if #p.RunsTerminees > RUNS_TERMINEES_MAX then
				table.remove(p.RunsTerminees, 1)
			end
			p.Records.Runs += 1
		end
		return verse > 0 or terminer == true
	end)
	return verse
end
```

Un `FinDeRun` rejoué, un double appel ou une reconnexion ne versent rien de plus.

- **Foreuse** : 5, 8, 12, 16 puis 20 gemmes/h selon le niveau, 8 h au plus. Le turbo multiplie par 1,35, plafonné à 27 (a08 appelle `ActiverTurboForeuse`).
- **Recherche** : `AcheterRecherche(joueur, nom, niveauVise)` refuse sans débit si `niveau + 1 ~= niveauVise`. Un double tap ne paie qu'un niveau.

## 4. Réseau : `ReplicatedStorage.Reseau`

Le module est généré depuis son enfant `ReglesRemotes` (table a29) : un seul dossier `Remotes`, vérifié par `assert` au démarrage puis 10 s plus tard. RemoteEvent uniquement, aucune RemoteFunction. `Reseau.Brancher` refuse une seconde connexion sur une même demande. `Validation.brancher` (a29) y délègue, et a26 y branche `DemandeTir`.

| Demande | Arguments | Débit (rafale) |
|---|---|---|
| `DemandeTir` | `idZbire` | 15/s |
| `DemandeReparation` | `actif` | 4/s |
| `DemandeAchat` | `cle, niveauVise` | 4/s |
| `DemandePose` | `defense, position, rotationY` | 2/s |
| `DemandeReprise` | `idDefense` | 2/s |
| `DemandePing` | `type, position?` | 0,67/s (2) |
| `DemandeCapsule` | `"Monter", capsule` / `"Quitter"` / `"Rejoindre"` | 1/s (2) |
| `DemandeRecherche` | `nom, niveauVise` | 2/s (2) |
| `DemandeForeuse` | — | 0,5/s (1) |
| `DemandeDeblocage` | `genre, id` | 2/s (4) |
| `DemandeReglage` | `cle, valeur` | 2/s (5) |

- **Garde**, dans l'ordre : `DonneesChargees`, seau de jetons, nombre et `typeof` des arguments (NaN, ±inf, chaînes de plus de 32 caractères et `Vector3` au-delà de 100 000 refusés), puis gestionnaire sous `pcall`. Toute réponse part par `Annonce(code, donnees)`. Un refus prend la forme `Annonce("Refus", {Demande, Raison})`.
- **`DemandeDeblocage`** passe par le routeur `Donnees.DefinirDeblocage(genre, fn)`. Genres : `Accueil` et `Equiper` (fournis), `Secret` (a13), `Chapeau` et `Tampon` (a15), `Peluche` (a22).
- **Retours** : `Annonce`, `PingDiffuse`, `ProfilMaj`, `PiecesLachees` et `Butin(idsRamasses, pieces)`. `ProfilMaj` ne contient que les champs modifiés (diff toutes les 0,2 s), jamais `Verrou`, `Achats`, `RunsCreditees` ni `RunsTerminees`.
- **`EtatZbires`** (UnreliableRemoteEvent, 10 Hz, `Reseau.DiffuserEtatZbires`) : 9 octets par Zbire. Format : `u16` id, `u8` type, `i16` X × 100, `i16` Z × 100, `u8` Y × 10, `u8` PV/255, positions relatives à `Workspace.CentrePlace`. 61 Zbires = 549 octets.
- **`Evenements`** (UnreliableRemoteEvent, 10 Hz, `Reseau.AjouterFait`) : 8 octets par fait (`u8` code, `u16` id, `i16` x, `i16` z, `u8` argument), soit 800 octets pour 100 faits.
  - Codes : 1 Apparition, 2 Coup, 3 Critique, 4 Éclatement, 5 Division, 6 ÉtatZbire, 7 Étourdi, 8 DéfensePosée, 9 DéfenseRetirée, 10 MaisonTouchée, 11 Réparation.
  - Côté client, `Reseau.SurFait(fn)` décode chaque paquet une seule fois. VfxClient, Son, ZbireAnimateur et l'UI s'y abonnent.
  - `Impact`, `Eclatement`, `VfxRapide`, `ZbireApparu`, `ZbireVaincu`, `Notification` et le remote `FinDeRun` disparaissent.

**Attributs**

- `Workspace` : `TypePlace`, `CentrePlace` et `RayonPlace` (70 sur la Prairie), posés dans Studio.
- `ReplicatedStorage.EtatRun` (`Configuration` créée par `Run.Demarrer`, Prairie seulement) : `Mode`, `Jour`, `Phase`, `FinPhase`, `Niv_Solidite`, `Niv_Reparation`, `Niv_Regeneration`, `Cagnotte_Solidite`, `Cagnotte_Reparation`, `Cagnotte_Regeneration`.
- `Player` : `DonneesChargees`, `Gemmes`, `RunEnCours`.

## 5. `Temps` : minuit à Paris

`Temps.cleJour()` et `Temps.SecondesAvantDemain()` pilotent le Défi du Jour, le Calendrier, les secrets, les énigmes et le Record du Jour. `Temps.cleSemaine()` pilote le Zbire de la Semaine. L'heure vient toujours du serveur : `os.time()`, ou `workspace:GetServerTimeNow()` sur le client.

```lua
function Temps.SecondesAvantDemain(t: number?): number
	local maintenant = t or Temps.maintenant()
	local d = dateParis(maintenant)
	local minuitNaif = DateTime.fromUniversalTime(d.year, d.month, d.day, 0, 0, 0, 0).UnixTimestamp + JOUR
	-- Minuit à Paris tombe à 22 h ou 23 h UTC, avant toute bascule (01:00 UTC) : le décalage de 23 h UTC fait foi.
	return minuitNaif - Temps.decalageParis(minuitNaif - 3600) - maintenant
end
```

## 6. Laboratoire ↔ Prairie

1. **Capsule** : 6 places, départ 15 s après le premier passager. Les attributs `Passagers` et `Depart` sont posés sur le modèle.
2. **Fiche** : `ReserveServer`, puis écriture en MemoryStore de `Capsules[privateServerId] = {Mode, CleJour, UserIds, Code, Terminee}`, TTL 1 800 s.
3. **Téléport** : `Passage.Teleporter` lance `Donnees.Liberer(joueur, true)` en parallèle (3 essais).
   - Réussi : `TeleportAsync` avec `ReservedServerAccessCode`.
   - Échoué : session gardée, `Annonce("Sauvegarde")` affiche « Sauvegarde… », nouvel essai toutes les 15 s (4 fois), puis `PassageAnnule`.
   - Téléport refusé par Roblox : `Donnees.Charger` à nouveau.
4. **Arrivée sur la Prairie** : une fois le profil chargé, écriture de `RunsEnCours["RunEnCours_<UserId>"] = {Code, Mode}`, TTL 1 800 s, prolongé à chaque jour.
5. **Reprise** : au Laboratoire, `Player.RunEnCours = true` affiche « Rejoindre la run », qui envoie `DemandeCapsule("Rejoindre")`.
6. **Fin** : `CrediterRun(…, true)`, fiche marquée `Terminee`, entrées `RunEnCours` effacées, 12 s d'écran, retour au Laboratoire. Une Prairie rouverte sur une fiche `Terminee` renvoie les joueurs au Laboratoire.

## 7. Fichiers (`scripts/a27/`)

| Fichier | Emplacement |
|---|---|
| `Reseau.lua`, `ReglesRemotes.lua` | `ReplicatedStorage.Reseau` et son enfant |
| `Catalogue.lua`, `Temps.lua` | `ReplicatedStorage` |
| `SchemaJoueur.lua`, `Donnees.lua`, `Passage.lua`, `Run.lua` | `ServerScriptService.Modules` |
| `Persistance.server.lua` | `ServerScriptService`, deux places |
| `ServicesLaboratoire.server.lua` | `ServerScriptService`, Laboratoire |

## 8. Tests d'acceptation

- **20 allers-retours** Laboratoire → Prairie → Laboratoire, sur le serveur de bêta avec 3 comptes. Chaque passage journalise `[Solde] J_<UserId>` au chargement et à la libération. Écart toléré : 0, gains de run annoncés compris.
- **Double tap**, depuis la console du client :
  ```lua
  local r = game.ReplicatedStorage.Remotes.DemandeRecherche
  r:FireServer("Foreuse", 1)
  r:FireServer("Foreuse", 1)
  ```
  Attendu : `Recherches.Foreuse = 1`, 60 gemmes débitées une seule fois, second retour `Refus` / `NiveauVise`. Même test sur `DemandeAchat`.
- **Corruption** : écrire `Gemmes = "abc"` dans le store Studio. Attendu : chargement refusé, version précédente restaurée, aucune écriture intermédiaire.
- **Heure** : `SecondesAvantDemain(1792843200)` vaut 36 000 (heure d'été) et `SecondesAvantDemain(1792929600)` vaut 39 600 (lendemain de la bascule).

### 🖱️ Scripteuse client & UI — Fanny Roux-Vidal (révisé)
# Zsurvie · Scripts client & UI (a28, Fanny Roux-Vidal) · révision du 02/10

## 1. Architecture client

| Fichier (`scripts/a28/`) | Emplacement Roblox | Rôle | Place |
|---|---|---|---|
| `UIKit.lua` | ReplicatedStorage › Client | Boîte à outils partagée : palette, rebond, `UIScale`, attentes, remotes, réglages, prix, crochets a10 | Les deux |
| `Hud.client.lua` | StarterPlayerScripts | Maquette HUD, bannières, voile d'étourdissement | Labo : Gemmes seules |
| `Controles.client.lua` | StarterPlayerScripts | Réparer, défenses, Ping, désignation, variante B de H2 | Prairie |
| `Etabli.client.lua` | StarterPlayerScripts | Bouton contextuel, panneau latéral, cagnotte | Prairie |
| `Effets.client.lua` | StarterPlayerScripts | Nombres de dégâts, pièces, étoiles, bulles de ping | Prairie |
| `CameraPrairie.client.lua` | StarterPlayerScripts | `Scriptable` (0, 45, 28), `FieldOfView` 50 | Prairie |
| `Reglages.client.lua` | StarterPlayerScripts | 5 réglages | Les deux |

- La place se reconnaît à `Workspace:GetAttribute("TypePlace")` (`"Laboratoire"` ou `"Prairie"`), lu après `game.Loaded`.
- Chaque `WaitForChild` attend 10 s au plus puis émet un `warn`. En cas d'échec, le script s'arrête proprement :

```lua
function UIKit.attendre(parent: Instance?, nom: string): Instance?
	if not parent then
		warn(`[a28] parent absent : {nom} ne peut pas être attendu`)
		return nil
	end
	local enfant = parent:WaitForChild(nom, UIKit.DELAI)
	if not enfant then
		warn(`[a28] {parent:GetFullName()}.{nom} introuvable après {UIKit.DELAI} s`)
	end
	return enfant
end
```

- **Supprimés** : ma boucle de tir, les traceurs, les remotes `Impact` et `Eclatement`, le pool de 90 cubes. Le tir revient à `BlasterControleur` (a26), l'éclatement au Z1 de a37.

## 2. Contrat serveur → client

| Source | Données lues | Usage |
|---|---|---|
| `ReplicatedStorage.EtatRun` | `Jour`, `Phase` (`Horde`/`Repit`), `FinPhase`, `Colosse`, `MaisonPV(Max)`, `ColossePV(Max)` | Bandeau, minuteur |
| `ReplicatedStorage.EtatRun` | `NivSolidite`, `NivReparation`, `NivRegeneration`, `CagnotteCle`, `CagnotteMontant`, `CagnotteObjectif`, `CagnotteContributeurs` (`"id,id"`) | Établi |
| Player | `Pieces`, `Gemmes`, `Defenses`, `EtourdiJusqua`, `Niv<Cle>` (dont `NivPortee`, `NivCadence`), `Verrou<Cle>`, `TestH2` | HUD, défenses |
| `Player.Reglages` | `TirAuto`, `Secousses`, `EffetsReduits`, `Musique`, `Effets` | Réglages |
| Modules | `Catalogue.prix(cle, niveauVise)`, `Plan.ETABLI`, `Plan.MAISON`, `BlasterStats.portee/cadence(niv)`, `ZbiresRendu.chercher/position`, `BlasterControleur.definirCiblePrioritaire`, `VfxClient.secouer` | — |

| Remote | Sens | Arguments |
|---|---|---|
| `DemandeReparation` | C→S | `true` à l'appui, `false` au relâchement |
| `DemandePose`, `DemandePing` | C→S | `cle`, `Vector3` |
| `DemandeAchat` | C→S | `cle`, `niveauVise` |
| `DemandeReglage` | C→S | `cle`, booléen ou 0 / 0,5 / 1 |
| `Annonce` | S→C | `Colosse`, `JourFranchi`, `Record`, `MaisonTombee`, `PiecesMaison {montant}`, `Refus {action, raison, cle}` |
| `ProfilMaj` | S→C | Fin de l'état Attente de l'Établi |
| `PiecesLachees` | S→propriétaire | `{ {id, position, montant, expireA} }` |
| `Butin` | S→propriétaire | `id, montant`, après le crédit |
| `PingDiffuse` | S→tous | `auteur, cle, position` |
| `Evenements` (Unreliable) | S→tous | Lots `{type = "Degats", position, valeur, critique, auteur, reduit}` |

Aucune demande ne porte de montant : le serveur fixe les prix, la part versée à la cagnotte et les crédits.

## 3. Maquette HUD unique (gabarit 800 × 360)

`UIScale` = clamp(min(X / 800, Y / 360), 1, 1,4), partagé via `UIKit.echelle`. `ScreenInsets` = `CoreUISafeInsets`, police `FredokaOne`, `UIStroke` Encre de 3 px.

| Zone | Élément | Taille (px) | Détail |
|---|---|---|---|
| Haut gauche (8, 8) | Pièces | 140 × 44 | Or, compteur roulant en 0,35 s (Gemmes cyan au Labo) |
| Sous le compteur | « +X » gris | 96 × 30 | Pastille Ardoise lumière, visible 2,5 s |
| Y = 8 + 88 × échelle | Réglages | 60 × 60 | Icône de la Charte, sinon 3 barres |
| Haut centre | Bandeau Maison (a32) | 280 × 66 | « JOUR X », minuteur `FinPhase − GetServerTimeNow()` (5 Hz), « MAISON 850 / 1 000 », jauge Colosse de 8 px |
| Haut droite | Têtes des Survivants | 6 × 32 | Contour Toit orange pour soi, Crème pour les autres, Alerte si étourdi |
| Bas droite | Grappe | 230 × 230, marge 12 | §4 |
| À gauche de la grappe | Établi | 72 | Écart de 12 px |

À 800 px de large, les zones ne se touchent pas : Pièces de 8 à 148, bandeau de 260 à 540, têtes de 580 à 792.

## 4. Contrôles

**Variante A (par défaut).** RÉPARER (96 px) occupe le coin. Muret, Mini-Tourelle, Tapis Collant et Ping (64 px) sont placés sur un arc de 150 px, avec 13,6 px entre deux boutons. **Aucun bouton de saut** : l'état `Jumping` est coupé sur l'Humanoid local, ce qui retire le bouton tactile.

```lua
local function surArc(index: number): Vector2
	local angle = math.rad(ANGLES_ARC[index])
	return CENTRE_REPARER + Vector2.new(math.cos(angle), math.sin(angle)) * RAYON_ARC
end
```

| Action | Tactile | Clavier | Manette |
|---|---|---|---|
| Tirer | Automatique ; un tap sur un Zbire le désigne comme cible prioritaire | Clic | — |
| Réparer | Maintenir RÉPARER | E | X |
| Défenses | Trois boutons de l'arc | 1, 2, 3 | Croix gauche, bas, droite |
| Ping | PING ouvre la Roue des Pings | Q, puis 1 à 4 | Croix haut |
| Établi | Bouton de 72 px | F | Y |

- Chaque défense affiche son prix `Catalogue.prix` en Or, ou en Alerte si le solde ne suffit pas. À la limite, elle se grise et affiche « 3/3 ». Si `Verrou<Cle>` > 0, un voile Encre la couvre avec un cadenas Crème et « Niv. X ».

```lua
reparer.bouton.InputBegan:Connect(function(entree: InputObject)
	local genre = entree.UserInputType
	if genre == Enum.UserInputType.Touch or genre == Enum.UserInputType.MouseButton1 then
		maintien = entree
		UIKit.rebond(reparer.bouton)
		commencerReparation() -- DemandeReparation(true)
	end
end)

local function finMaintien(entree: InputObject)
	if estMaintien(entree) then
		maintien = nil
		arreterReparation() -- DemandeReparation(false)
	end
end
reparer.bouton.InputEnded:Connect(finMaintien)
-- Filet : un doigt qui glisse hors du bouton se lève ailleurs ; on le rattrape ici.
UserInputService.InputEnded:Connect(finMaintien)
```

- Désignation : le marqueur suit la cible grâce à un seul appel par frame à `ZbiresRendu.position`.

```lua
local function designer(ecran: Vector2)
	if not (zbiresRendu and blaster) then
		return
	end
	local trouve, id = pcall(zbiresRendu.chercher, ecran, TOLERANCE_DESIGNATION)
	if not trouve or id == nil then
		return
	end
	pcall(blaster.definirCiblePrioritaire, id)
	cibleMarquee = id
	UIKit.son("Clic")
end
```

- **Variante B de H2**, activée si `Player.TestH2 == "B"`, sinon variante A au bout de 2 s : RÉPARER 96 px, POSER 72 px (roue des 3 défenses) et PINGS 72 px, avec 12 px d'écart. Les touches restent les mêmes.

## 5. Établi

- **Bouton** : le bouton contextuel de 72 px apparaît à 10 studs au plus de `Plan.ETABLI` et disparaît au-delà de 12 studs (contrôle à 4 Hz).
- **Ouverture** : automatique à l'entrée dans la zone **seulement si `Phase == "Repit"`**, sinon par le bouton, F ou ButtonY. Les taps sont ignorés pendant 0,8 s après l'ouverture.
- **Panneau** : latéral droit, 55 % de la largeur. Il s'arrête 24 px au-dessus de RÉPARER, qui reste utilisable (`DisplayOrder` 3 contre 2). L'arc est masqué pendant l'ouverture.
- **Cartes** : 2 colonnes, 64 px de haut, avec défilement. Chacune affiche le nom, l'aperçu `BlasterStats` pour Portée et Cadence (« 40 → 44 studs »), « Niv. 2 → 3 » et `Catalogue.prix(cle, niveauVise)`.
- **Achat** : `DemandeAchat(cle, niv + 1)` fait passer la carte en Attente (voile « … ») jusqu'à `ProfilMaj` ou une `Annonce` portant sa clé, avec un filet de 4 s. En cas de refus, la carte tremble de ±6°.
- **Cagnotte** (colonne de 36 %) : amélioration et niveau visé, jauge Or « montant / objectif », 6 têtes de contributeurs au plus. Toucher une carte ÉQUIPE revient à contribuer ; le serveur prélève min(solde, reste).

## 6. Retours visuels

| Déclencheur | Retour |
|---|---|
| Appui, gain, annonce | Rebond du canon (× 0,8 / × 1,2), 3 × 0,05 s |
| `PiecesLachees` | La pièce apparaît en 0,15 s, flotte et tourne (un seul `BulkMoveTo` ; immobile avec `EffetsReduits`) |
| `expireA` − 3 s | Clignote à 2,5 Hz, sous le seuil de 3 flashs/s |
| `expireA` | File vers `Plan.MAISON` + 8 studs en 0,6 s |
| `Butin` | Aspirée vers le Survivant en 0,2 s, « +N » en Or |
| `PiecesMaison` (Répit) | « +X » gris sous le compteur |
| `Degats` | Crème ; critique en Toit orange ; Casqué sans critique en gris avec « Tink » ; des coéquipiers, seuls les critiques s'affichent |
| Colosse, étourdissement, Maison −5 % | `UIKit.secouer` de 0,8, 0,6 et 0,3 stud (plafond 0,8) |

## 7. Réglages et crochets

- **Réglages** : boutons de 252 × 60 px. Un tap envoie `DemandeReglage`, mais l'affichage ne change qu'une fois que le serveur a écrit `Player.Reglages` (filet de 3 s). Effets de chaque réglage :
  - `Musique` et `Effets` : cycle 100 / 50 / 0 % sur les `SoundGroup` du même nom ;
  - `Secousses` : coupe `UIKit.secouer` ;
  - `TirAuto` : lu par `BlasterControleur` ;
  - `EffetsReduits` : immobilise les pièces et masque les critiques des coéquipiers.
- **Crochets a10** : `UIKit.pulser("Muret", true)`, `UIKit.pulser("Ping", true, "PingColosse")`, puis `UIKit.pulser(nom, false)` pour arrêter. Le contour pulse en Crème (5 px, 0,4 s). L'icône vient de `Charte.Icones` ; en son absence, le bouton garde son texte. En variante B, c'est POSER qui pulse.

## 8. Performance et sécurité

- Pools fixes : 20 nombres, 60 pièces, 6 bulles. Rien n'est créé pendant le combat. Aucune Part `Neon` ni `PointLight`.
- `Heartbeat` ne sert qu'aux pièces et `RenderStepped` qu'au marqueur. Le minuteur tourne à 5 Hz, RÉPARER et l'Établi à 4 Hz.
- Sons UI espacés d'au moins 80 ms. Pings limités à 4 phrases fixes.

## 9. Écarts et points à valider

- **Pas de saut sur la Prairie** : ajout au canon, confirmé par le chef de projet. Reste à valider par Victor Lanoue.
- **`TirAuto` actif par défaut sur tous les appareils** : le canon §8 le prévoit seulement sur mobile. Le réglage permet de le couper.
- Les attributs `Verrou<Cle>` et `Cagnotte*` sont des noms proposés, encore à confirmer.

### 🛡️ Expert anti-exploit — Oscar Lindqvist (révisé)
## 1. Doctrine

- Le client n'envoie que des **intentions** (« je vise le Zbire 812 », « j'achète Cadence niveau 3 ») : jamais de dégâts, de prix ni de récompense.
- Pas de remote pour ce que le serveur sait déjà : Pièces (aimant serveur de 8 studs), gemmes de la Mine et du Doré, jours franchis, Défi du Jour, Galerie des Zbires.
- Uniquement des `RemoteEvent`. Aucune `RemoteFunction`, jamais d'`InvokeClient`.
- La logique vit dans `ServerScriptService.Securite`. Seule `ReplicatedStorage.ReglesRemotes` est partagée : aucun secret, la copie du serveur fait foi.
- Corriger avant de sanctionner : un Android 3 Go en 4G n'est jamais exclu. Aucun bannissement automatique.
- Rien ne bloque le démarrage : un dossier ou un module absent déclenche un `warn` et coupe un contrôle, jamais le serveur.

## 2. Menaces

| Menace | Tentative | Parade |
|---|---|---|
| Téléportation | Sauter sur l'Établi ou sur ses Pièces | Budget de distance, retour à la dernière position valide |
| Vitesse, vol, noclip | Kiter la horde, ignorer l'étourdissement, entrer dans la Maison | `GardienMouvement` à 4 Hz, raycast de sol, `ZoneInterdite` |
| Remotes abusées | 100 tirs/s, `NaN`, 50 Murets, double-tap à l'Établi | `Validation.brancher`, `niveauVise`, puis contexte |
| Duplication | Gemmes créditées deux fois | Transformations idempotentes dans `Donnees` (a27) |
| `TeleportData` falsifié | Arriver « avec » des gemmes | Rien de valeur dedans |
| Fling | Éjecter un autre Survivant | Groupe `Survivants` non collidable avec lui-même, carte ancrée |

## 3. Contrat réseau : `ReglesRemotes`, source de `Reseau` (a27)

- `Validation` est le **seul créateur** de `ReplicatedStorage.Remotes`.
- `Reseau` dérive son API de `ReglesRemotes.remotes` et `ReglesRemotes.listes`. Côté serveur, il écoute avec `Validation.brancher` (une connexion par remote) et émet avec `Validation.remote(nom)`.
- Ordre des contrôles : **nombre d'arguments → débit → types et bornes (NaN, ±inf, texte ≤ 32 caractères, listes fermées) → `coherence` → contexte → effet.**

| Remote | Place | Arguments | Débit/s · rafale | Contexte vérifié par le serveur |
|---|---|---|---|---|
| `DemandeTir` | Prairie | `idZbire` entier | 12 · 6 | Non étourdi ; délai ≥ 0,85 × intervalle de Cadence ; Zbire vivant ; distance ≤ Portée + 6 studs de `positionSure` |
| `DemandeReparation` | Prairie | `actif` booléen | 4 · 4 | Un tick toutes les 0,5 s, à ≤ 6 studs de la Maison, non étourdi |
| `DemandeAchat` | Prairie | amélioration (8), `niveauVise` 1-20 | 2 · **2** | ≤ 10 studs de l'Établi ; `niveauVise` = niveau + 1, sinon refus muet ; Pièces débitées avant l'effet |
| `DemandePose` | Prairie | défense (3), `Vector3` ≤ 66, quart de tour 0-3 | 2 · 3 | ≤ 3 par Survivant ; ≤ 12 studs du Survivant ; ≥ 4 studs de la Maison, de la Mine et des autres défenses |
| `DemandeReprise` | Prairie | `defenseId` entier | 1 · 2 | Défense posée par ce Survivant, à ≤ 12 studs, non étourdi |
| `DemandeCapsule` | Laboratoire | Normale, Difficile, DuJour, Quitter | 1 · 3 | ≤ 12 studs ; 6 places ; code `ReserveServer` jamais transmis |
| `DemandeRecherche` | Laboratoire | recherche (4), `niveauVise` 1-20 | 0,5 · **2** | ≤ 10 studs de l'Arbre ; niveau, prérequis et coût vérifiés dans `UpdateAsync` |
| `DemandeForeuse` | Laboratoire | aucun | 0,2 · 1 | Gain calculé sur `os.time()` serveur, 8 h au plus |
| `DemandePing` | Toutes | ping (4), `Vector3` optionnel ≤ 140 | 0,5 · 3 | Position gardée pour « Ici ! » seulement ; aucun texte libre |
| `DemandeDeblocage` | Toutes | aucun | 0,1 · 1 | Branchée par a29 : immobile depuis 2 s, non étourdi → `PointDeblocage` le plus proche |
| `DemandeReglage` | Toutes | `cle` (5), valeur | 1 · 3 | `coherence` : `Musique` et `Effets` entre 0 et 1 ; `TirAuto`, `Vibrations` et `GraphismesLegers` booléens |
| `EtatHorde`, `PingDiffuse` | — | serveur → clients | — | Piège : tout appel client vaut 20 points |

## 4. Gardien de mouvement

### Démarrage sans blocage

- `Demarrage` enregistre le groupe `Survivants` **avant** tout `require`.
- `GardienMouvement` lit `ReplicatedStorage.Plan` (a11) en tâche de fond, puis `WaitForChild(Plan.RACINE, 10)`, avec un `warn` en cas d'échec. Le rayon de sol (160 studs) ne vise que ce dossier.
- **Un sol introuvable donne une hauteur de 0 : ce n'est jamais une faute.**
- `GardienMouvement.attendreRacine()` fournit ce dossier à `Demarrage` (Parts non ancrées, dossier `Defenses`).

### Vitesse et saut : a29 seul les écrit

- Valeurs de `ReplicatedStorage.Config.Mouvement` (a09), champs `WalkSpeed` et `JumpHeight` ; à défaut, `StarterPlayer` et un `warn`. Les hypothèses 18 et 7,2 sont retirées.
- `definirVitesse(vitesse, joueur?)` : sans joueur, s'applique à tous les Survivants et aux arrivants. La boucle de jour appelle `definirVitesse(24)` au Répit, puis `definirVitesse(Mouvement.WalkSpeed)`. Le budget n'exige une baisse de vitesse qu'après 1 s.
- `etourdir(joueur)` : 2 s à `WalkSpeed` 0 et `JumpHeight` 0, budget ramené à 1 s de course (aller-retour réseau), restauration par le serveur.

### Contrôles toutes les 0,25 s

| Contrôle | Seuil | Points |
|---|---|---|
| Budget de distance | Gagne vitesse × dt × 1,2, plafonné à 2,5 s de course ; perd la distance horizontale parcourue | 4 (8 si saut > 30 studs) |
| Hors zone | Prairie : au-delà de `RayonPlace` = `Plan.RAYON_BARRIERE` + 4 = **76** studs. Laboratoire : hors de toute Part `ZoneJouable`, avec 2 studs de marge | **0**, correction seule, dans les deux places |
| Traversée | Racine enfoncée de plus d'1 stud dans une `ZoneInterdite` (Maison, Mine) | 6 |
| Vol | Au choix : sol plus loin que `HipHeight` + ½ racine + `JumpHeight` + 6 ; plus de 6 studs pendant 1,2 s hors chute ; plus de 150 studs au-dessus de `CentrePlace` | 6 |
| Chute sous la carte | Y < centre − 20 | 0, replacement |

**Exemptions :**
- **Assis** (`SeatPart`, dans une Capsule) : position acceptée.
- **`accorderEnvol(joueur, durée)`**, appel serveur uniquement : vol ignoré et 70 studs/s tolérés pendant la durée demandée (5 s au plus) + 0,5 s de latence. Les Ressorts et la Tuyauterie de a12 l'appellent avec 1,5 s, tout recul serveur avec 1 s.
- **Parts `ZoneGlisse`** (Toboggan de l'Arrivée) : même régime.
- **`Climbing`** : l'état vient du client, il n'est donc cru que contre une Part collidable à ≤ 3 studs (Grimpe du Colosse, échelles).

Extrait de `controler` (fichier `GardienMouvement.lua`), après le contrôle du budget de distance :

```lua
	-- 2. Zone : une barrière physique arrête déjà les honnêtes, une sortie est corrigée sans points
	if horsZone(pos) then
		return corriger(joueur, personnage, racine, s, "HorsZone", 0)
	end
	if dansVolume("ZoneInterdite", pos, -1, false) then
		return corriger(joueur, personnage, racine, s, "Traversee", 6)
	end

	-- 3. Vol : ignoré en envol, en ZoneGlisse et en Climbing contre une Part ; sol introuvable = aucune faute
	if libre or grimpe(h, personnage, pos) then
		s.air = 0
	else
		local sol = if racineCarte then workspace:Raycast(pos, Vector3.new(0, -RAYON_SOL, 0), parametres) else nil
		local hauteur = if sol then pos.Y - sol.Position.Y else 0
		local chute = pos.Y < derniere.Y - 0.5
		local solAbsolu = h.HipHeight + racine.Size.Y / 2 + SAUT + MARGE_SAUT
		s.air = if hauteur > SOL_MAX and not chute then s.air + dt else 0
		if pos.Y - centre.Y > ALTITUDE_MAX or (hauteur > solAbsolu and not chute) or s.air > AIR_MAX then
			return corriger(joueur, personnage, racine, s, "Vol", 6)
		end
	end
```

Toute distance de gameplay passe par `positionSure` ou `aPortee`, et toute téléportation serveur par `teleporter`.

## 5. Sanctions

- **Seau de jetons** par Survivant et par remote : il laisse passer les paquets groupés d'un téléphone et coupe le flood.
- **Barème :** 0,5 hors seau ; 10 pour un format faux ou un argument en trop ; 20 pour une remote descendante ; 4 ou 8 pour la vitesse ; 6 pour une traversée ou un vol ; 0 pour une sortie de zone.
- **Seuil :** −1 point toutes les 3 s ; à 40, `Kick` avec un message neutre. Chaque faute de 2 points ou plus part dans `AnalyticsService` (`AE_Vitesse`…) pour une revue humaine.
- **Mesure QA :** `Validation.bilan(joueur)` renvoie le score et le cumul, `GardienMouvement.corrections(joueur)` le nombre de corrections.

## 6. Anti-duplication, désormais dans `Donnees` (a27)

- Le store `Zsurvie_Profils_v1` et le module `Transactions` sont supprimés. Chaque écriture de gemmes passe par une transformation `UpdateAsync` de `Donnees`, sans risque si elle est rejouée. a29 relit ce code.
- `CrediterRun` est appelé à chaque jour franchi, avec un `totalRun` cumulatif recalculé par le serveur :

```lua
-- Donnees.CrediterRun (a27) : transformation passée à UpdateAsync, rejouable sans double crédit
local deja = p.runs[runId]
local credite = if deja then deja.c else 0
if totalRun <= credite then
	return nil -- déjà crédité : UpdateAsync n'écrit rien
end
p.gemmes += totalRun - credite
p.runs[runId] = { c = totalRun, t = os.time() } -- entrées de plus de 24 h purgées
```

- **Recherche :** refusée si `niveauVise` ≠ niveau + 1, dans la même transformation que le débit.
- **Foreuse :** horodatage remis à `os.time()` dans la même écriture, gain plafonné à 8 h.
- **Défi du Jour :** la clé vient de `Temps.cleJour()` (a27), jamais du client. 150 gemmes une seule fois, 7 clés conservées.
- **Pièces :** chaque Pièce a un identifiant unique, retiré de la table serveur avant le crédit.
- **Capsules :** le manifeste (UserIds, mode) est écrit dans `MemoryStoreService` sous le `PrivateServerId`. La Prairie exclut tout joueur inconnu.

## 7. Réglages Studio et fichiers

- **Workspace, dans les deux places :**
  - attributs `TypePlace` et `CentrePlace` ;
  - `RejectCharacterDeletions` = `Enabled` ;
  - l'attribut `RayonPlace` est retiré.
- **Volumes tagués** `ZoneInterdite`, `ZoneJouable`, `ZoneGlisse` et `PointDeblocage` : `Anchored`, `CanCollide`, `CanQuery` et `CanTouch` à false, `Transparency` 1, tournés autour de Y seulement.
- **Maison :** sa `ZoneInterdite` épouse ses murs collidables sur 16 × 30 × 16 studs, toit compris.
- **Zbires :** Parts `CanCollide` false, pour qu'aucun Survivant ne se tienne dessus.
- **Fichiers `scripts/a29/` :** `ReglesRemotes.lua` → `ReplicatedStorage` ; `Validation.lua`, `GardienMouvement.lua`, `Demarrage.server.lua` → `ServerScriptService.Securite` ; `Transactions.lua` supprimé.

## 8. Tests d'acceptation

Réglage réseau : Studio, Test > Clients and Servers, `IncomingReplicationLag` 0,3 s.

| Test | Attendu |
|---|---|
| 2 clients, 3 min de horde | Cumul `Validation.bilan` à 0 pour chacun |
| 15 s de Répit à 24, puis un Ressort | `corrections` à 0 |
| Grimpe du Colosse et Toboggan de l'Arrivée | Cumul à 0 |
| Serveur lancé sans `Workspace.Arene` | Démarrage normal, `warn`, `Survivants` actif, cumul à 0 après 1 min |
| Un test par remote montante (11) | Appel légitime accepté ; un argument en trop vaut 10 |
| Vitesse × 1,5 ; vol à 20 studs | Corrigés en moins de 8 s et en moins de 1,5 s |

### 🔧 Ingénieure outillage — Prune Sézanne (révisé)
## Livré le 29/09, avant tout le reste

| Livrable | Emplacement Roblox | Fichier |
|---|---|---|
| Module **Charte** | `ReplicatedStorage.Charte`, Package `AutoUpdate` dans les 2 places | `scripts/a30/Charte.lua` |
| **Auditeur Pixel-bloc v2** | Plugin local, barre **Zsurvie Outillage** | `scripts/a30/AuditeurPixelBloc.server.lua` |
| **Forge à Zbires**, **Semeur de Prairie** | Même barre | Spécifiés ci-dessous |

## Écart déclaré à Victor Lanoue : noms d'instances sans accents

Les noms d'**instances** sont en ASCII, sans accent ni espace, car ils sont tapés dans le code (`FindFirstChild`, attributs, tags) : `Lisiere`, `Etabli`, `Dore`, `Casque`, `MiniGluant`, `GalerieZbires`, `TerreBattue`, `Creme`, `Lumiere`. Tout texte vu par le joueur (`TextLabel`, `BillboardGui`, Roue des Pings) garde l'orthographe du canon : « Lisière », « Doré », « Casqué », « Mini-Gluant ».

## Conventions communes

- **Nommage** `Zone_Objet_NN` : `Prairie_Botte_07`, `Lisiere_Portail_03`.
- **Place Prairie** : `Workspace.Maison` (Model), `Mine`, `Prairie`, `Lisiere`, `Decor.<Zone>`, `Runtime` (vide en édition) ; `ReplicatedStorage.Charte`, `ReplicatedStorage.Modeles.Zbires` ; `ServerStorage.Prefabs.Decor`, `ServerStorage.Outillage.Gabarit`.
- **Gabarit** (`Configuration` tenue par a11, dans les 2 places) : attribut `PartsStatiques` (6 500 en Prairie) et un attribut `Neon_<Zone>` par zone (`Neon_Lisiere`, `Neon_Mine`…), total ≤ 150. Une zone est un enfant de `Workspace` ou de `Workspace.Decor` ; une zone sans attribut a droit à 0 Neon.

## Module `ReplicatedStorage.Charte`

- **API complète et figée** : `Charte.Couleurs.<Nom>` (11 `Color3`), `Charte.teinte(nom, "Base" | "Ombre" | "Lumiere")`, `Charte.Interface`, `Charte.Ambiances`. Rien d'autre : `Palette`, `couleur()` ou `Gemme.Lumiere` lèvent « Charte.Palette n'existe pas » dès le premier test.
- **Un seul chargement** : `require(ReplicatedStorage:WaitForChild("Charte"))`, jamais de `require` relatif.
- **Propriétaires** : a31 règle les valeurs d'`Interface`, l'éclairage celles d'`Ambiances`. Toute nouvelle clé passe par moi, car l'Auditeur vérifie la forme exacte du module.

```lua
-- Emplacement Roblox : ReplicatedStorage > ModuleScript « Charte » (Package AutoUpdate, Laboratoire et Prairie)
-- Charte Pixel-bloc de Zsurvie : seule source des couleurs, de l'interface et des ambiances.
-- Chargement unique : require(game:GetService("ReplicatedStorage"):WaitForChild("Charte"))
export type Variante = "Base" | "Ombre" | "Lumiere"

local Couleurs = {
	Encre = Color3.fromHex("1E1B2E"),
	Prairie = Color3.fromHex("6CC24A"),
	TerreBattue = Color3.fromHex("C8894F"),
	Creme = Color3.fromHex("F6E7C1"),
	ToitOrange = Color3.fromHex("EF7A2F"),
	Or = Color3.fromHex("FFC933"),
	GemmeCyan = Color3.fromHex("33D6F0"),
	VioletHorde = Color3.fromHex("9B5DE5"),
	Alerte = Color3.fromHex("FF2E63"),
	NuitLabo = Color3.fromHex("2A3263"),
	Ardoise = Color3.fromHex("4A4560"),
}

-- 33 teintes : ombre = base × 0,8 ; lumière = base:Lerp(Creme, 0.2)
local teintes = {}
for nom, base in Couleurs do
	teintes[nom] = {
		Base = base,
		Ombre = Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8),
		Lumiere = base:Lerp(Couleurs.Creme, 0.2),
	}
end

local function teinte(nom: string, variante: Variante): Color3
	local c = teintes[nom] and teintes[nom][variante]
	if not c then
		error(("Charte.teinte : %s/%s inconnue"):format(tostring(nom), tostring(variante)), 2)
	end
	return c
end

-- Interface : valeurs tenues par a31
local Interface = {
	BoutonMin = 60, -- px, minimum canon sur téléphone
	Fond = teinte("NuitLabo", "Base"),
	Panneau = teinte("Creme", "Base"),
	Texte = teinte("Encre", "Base"),
	Action = teinte("ToitOrange", "Base"),
	ActionAppui = teinte("ToitOrange", "Ombre"),
	Pieces = teinte("Or", "Base"),
	Gemmes = teinte("GemmeCyan", "Base"),
	Danger = teinte("Alerte", "Base"),
}

-- Ambiances : propriétés de Lighting appliquées telles quelles ; caméras Scriptable levées
local Ambiances = {
	Laboratoire = {
		ClockTime = 0,
		Brightness = 1,
		Ambient = teinte("NuitLabo", "Lumiere"),
		OutdoorAmbient = teinte("NuitLabo", "Base"),
	},
	Cameras = {
		Prairie = { Decalage = Vector3.new(0, 45, 28), FieldOfView = 50 }, -- canon
		Colosse = { Decalage = Vector3.new(0, 56, 35), FieldOfView = 50 }, -- + 25 % le Jour du Colosse
	},
}

-- Gel récursif ; lire une clé absente (une ancienne API par exemple) lève une erreur explicite
local function geler(t: { [any]: any }, chemin: string)
	for cle, v in t do
		if type(v) == "table" then geler(v, chemin .. "." .. tostring(cle)) end
	end
	setmetatable(t, {
		__index = function(_, cle)
			error(("%s.%s n'existe pas"):format(chemin, tostring(cle)), 2)
		end,
	})
	return table.freeze(t)
end

return geler({ Couleurs = Couleurs, teinte = teinte, Interface = Interface, Ambiances = Ambiances }, "Charte")
```

## Outil 1 : Auditeur Pixel-bloc v2 (le plus utile)

Il protège les 30 FPS de l'Android 3 Go dès la phase 1 : un Neon de trop, un arbre de 9 studs devant la Maison ou un Zbire manquant (qui sortirait en cube provisoire) sont repérés le jour même.

| Contrôle bloquant | Seuil | Place |
|---|---|---|
| Charte | 4 clés, 11 couleurs du canon, `teinte` exacte | Les 2 |
| Parts statiques | 6 500 (Gabarit de a11, jamais relevé) ; Laboratoire 10 000 | Les 2 |
| Pic de horde | statique + 60 × pire Zbire + 30 (Colosse) + 450 (défenses) + 240 (avatars) + 300 (pièces, effets) ≤ 10 000 | Prairie |
| Neon | 150 au total et `Neon_<Zone>` du Gabarit | Les 2 |
| Lumières | 12, toutes classes (`PointLight`, `SpotLight`, `SurfaceLight`) | Les 2 |
| `ParticleEmitter` | 24 `Enabled` au plus ; `Rate` ≤ 20 (corrigeable) | Les 2 |
| Terrain | `workspace.Terrain:CountCells()` = 0 | Les 2 |
| Couleurs, matériaux | 33 teintes (corrigeable) ; `SmoothPlastic` ≥ 90 % | Les 2 |
| Zbires | 10 types dans `ReplicatedStorage.Modeles.Zbires`, format Forge ; ancien `ReplicatedStorage.Zbires` absent | Les 2 |
| Lisibilité | rien au-dessus de 6 studs à moins de 60 studs de la Maison (Maison exemptée) | Prairie |
| Arène | ± 110 studs ; Parts taguées `HorsArene`, sur elles ou un ancêtre (Canopée de a16) : ± 150 | Prairie |
| Streaming | `StreamingEnabled` = false | Prairie |

Seul avertissement : `Modeles.Zbires` en Package `AutoUpdate`. **Pic attendu** : 6 500 + 60 × 6 + 1 020 = **7 880 Parts**, 2 120 de marge (l'ancienne version, à 7 500 statiques, dépassait 10 000 avec les avatars). **Profil** : `Workspace.Maison` présent = Prairie, sinon Laboratoire.

**Usage**
1. **Auditer** (mode édition) : rapport dans l'Output, KO en orange, fautifs sélectionnés (`F` pour cadrer).
2. **Corriger** : couleurs et `Rate` du dernier audit, une étape annulable (`Ctrl+Z`).
3. Relancer jusqu'à « 0 bloquant », coller le rapport dans le message de commit.

**Installation** : coller le script dans un `Script` de `ServerStorage`, clic droit > *Save as Local Plugin…*

```lua
-- Emplacement Roblox : plugin local Studio (dossier Plugins), Script « AuditeurPixelBloc »
-- Auditeur Pixel-bloc v2 (Zsurvie) : Charte, budgets du canon et Zbires ; « Corriger » recale couleurs et Rate.
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local B = { PartsPrairie = 6500, PartsLabo = 10000, PartsArene = 10000, Neon = 150, Lumieres = 12, Rate = 20,
	Emetteurs = 24, Smooth = 0.9, Hauteur = 6, Rayon = 60, DemiArene = 110, DemiCadre = 150, Horde = 60,
	PartsZbire = 6, PartsColosse = 30, NeonColosse = 4,
	Reserve = 30 + 450 + 240 + 300 } -- Colosse, défenses, avatars, pièces et effets
local TYPES = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local CANON = { Encre = "1E1B2E", Prairie = "6CC24A", TerreBattue = "C8894F", Creme = "F6E7C1", ToitOrange = "EF7A2F",
	Or = "FFC933", GemmeCyan = "33D6F0", VioletHorde = "9B5DE5", Alerte = "FF2E63", NuitLabo = "2A3263", Ardoise = "4A4560" }
local API = { Couleurs = "table", teinte = "function", Interface = "table", Ambiances = "table" }
local TOLERANCE = 0.0003 -- écart RVB² toléré (arrondi Color3uint8)
local CREME = Color3.fromHex(CANON.Creme)
local dernier = { couleurs = {}, emetteurs = {} }

local function ombre(c: Color3): Color3
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end

local TEINTES = {} -- 33 teintes autorisées : base, ombre (× 0,8), lumière (Lerp Crème 0,2)
for _, hex in CANON do
	local c = Color3.fromHex(hex)
	table.insert(TEINTES, c)
	table.insert(TEINTES, ombre(c))
	table.insert(TEINTES, c:Lerp(CREME, 0.2))
end

-- ReplicatedStorage.Charte : 4 clés exactement, 11 couleurs du canon, teinte() exacte
local function charteConforme(): boolean
	local module = ReplicatedStorage:FindFirstChild("Charte")
	if not (module and module:IsA("ModuleScript")) then return false end
	local copie = module:Clone() -- contourne le cache de require
	local ok, charte = pcall(require, copie)
	copie:Destroy()
	if not ok or type(charte) ~= "table" then return false end
	for cle, v in charte do
		if API[cle] ~= type(v) then return false end
	end
	for cle, attendu in API do
		if type(rawget(charte, cle)) ~= attendu then return false end
	end
	local nb = 0
	for nom, c in charte.Couleurs do
		nb += 1
		if typeof(c) ~= "Color3" or CANON[nom] ~= c:ToHex():upper() then return false end
	end
	local a = Color3.fromHex(CANON.Alerte)
	for variante, attendu in { Ombre = ombre(a), Lumiere = a:Lerp(CREME, 0.2) } do
		local okT, t = pcall(charte.teinte, "Alerte", variante)
		if not okT or typeof(t) ~= "Color3" or t:ToHex() ~= attendu:ToHex() then return false end
	end
	return nb == 11
end

local function sommetY(p: BasePart): number -- sommet de la boîte englobante, même pivotée
	local cf, d = p.CFrame, p.Size / 2
	return cf.Y + math.abs(cf.RightVector.Y) * d.X + math.abs(cf.UpVector.Y) * d.Y + math.abs(cf.LookVector.Y) * d.Z
end

local function horsArene(inst: Instance): boolean -- tag HorsArene sur la Part ou un ancêtre (Canopée de a16)
	local i: Instance? = inst
	while i and i ~= workspace do
		if i:HasTag("HorsArene") then return true end
		i = i.Parent
	end
	return false
end

local function auditer()
	if not RunService:IsEdit() then return warn("[Auditeur] Auditer : mode édition uniquement.") end
	local maison = workspace:FindFirstChild("Maison")
	local prairie = maison ~= nil and maison:IsA("Model")
	local centre, solY = Vector3.zero, 0
	if prairie then
		local cf, taille = (maison :: Model):GetBoundingBox()
		centre, solY = cf.Position, cf.Y - taille.Y / 2
	end
	local outillage = ServerStorage:FindFirstChild("Outillage")
	local gabarit = outillage and outillage:FindFirstChild("Gabarit")
	local n = { parts = 0, smooth = 0, neon = 0, lumieres = 0, actifs = 0, hauts = 0, hors = 0 }
	local neonZone, fautifs, couleurs, emetteurs = {}, {}, {}, {}

	local function controlerCouleur(p: BasePart)
		local c, cible, ecart = p.Color, nil, math.huge
		for _, t in TEINTES do
			local e = (c.R - t.R) ^ 2 + (c.G - t.G) ^ 2 + (c.B - t.B) ^ 2
			if e < ecart then cible, ecart = t, e end
		end
		if ecart > TOLERANCE then table.insert(couleurs, { p, cible }) end
	end

	-- Zone = enfant de Workspace ou de Workspace.Decor (Decor.Lisiere compte dans « Lisiere »)
	local racines = {}
	for _, enfant in workspace:GetChildren() do
		if enfant.Name == "Decor" then
			for _, z in enfant:GetChildren() do table.insert(racines, z) end
		elseif not (enfant:IsA("Terrain") or enfant:IsA("Camera")) then
			table.insert(racines, enfant)
		end
	end
	for _, racine in racines do
		local zone, liste, controle = racine.Name, racine:GetDescendants(), prairie and racine ~= maison
		table.insert(liste, racine)
		for _, inst in liste do
			if inst:IsA("BasePart") then
				n.parts += 1
				if inst.Material == Enum.Material.SmoothPlastic then n.smooth += 1 end
				if inst.Material == Enum.Material.Neon then
					n.neon += 1
					neonZone[zone] = (neonZone[zone] or 0) + 1
				end
				controlerCouleur(inst)
				if controle then
					local dx, dz = inst.Position.X - centre.X, inst.Position.Z - centre.Z
					local ecart = math.max(math.abs(dx), math.abs(dz))
					if math.sqrt(dx * dx + dz * dz) < B.Rayon and sommetY(inst) - solY > B.Hauteur then
						n.hauts += 1
						table.insert(fautifs, inst)
					elseif ecart > B.DemiArene and (ecart > B.DemiCadre or not horsArene(inst)) then
						n.hors += 1
						table.insert(fautifs, inst)
					end
				end
			elseif inst:IsA("Light") then -- PointLight, SpotLight et SurfaceLight
				n.lumieres += 1
			elseif inst:IsA("ParticleEmitter") then
				if inst.Enabled then n.actifs += 1 end
				if inst.Rate > B.Rate then
					table.insert(emetteurs, inst)
					table.insert(fautifs, inst)
				end
			end
		end
	end

	-- Zbires : chemin unique ReplicatedStorage.Modeles.Zbires, les 10 types obligatoires
	local modeles = ReplicatedStorage:FindFirstChild("Modeles")
	local dossier = modeles and modeles:FindFirstChild("Zbires")
	local manquants, zbiresKO, pireZbire = {}, {}, 0
	for _, nom in TYPES do
		local modele = dossier and dossier:FindFirstChild(nom)
		if not (modele and modele:IsA("Model")) then
			table.insert(manquants, nom)
			continue
		end
		local colosse, nb, mesh, neon, drapeaux, defauts = nom == "Colosse", 0, 0, 0, false, {}
		for _, d in modele:GetDescendants() do
			if d:IsA("BasePart") then
				nb += 1
				if d:IsA("MeshPart") then mesh += 1 end
				if d.Material == Enum.Material.Neon then neon += 1 end
				drapeaux = drapeaux or d.CastShadow or d.CanCollide or d.CanQuery or d.CanTouch
				controlerCouleur(d)
			elseif d:IsA("Humanoid") or d:IsA("Animator") or d:IsA("Light") or d:IsA("ParticleEmitter")
				or d:IsA("LuaSourceContainer") then
				table.insert(defauts, d.ClassName)
			end
		end
		local racine = modele.PrimaryPart
		if not (racine and racine.Name == "Racine" and racine.Anchored and racine.Transparency == 1) then
			table.insert(defauts, "Racine")
		end
		if nb > (if colosse then B.PartsColosse else B.PartsZbire) then table.insert(defauts, nb .. " Parts") end
		if mesh < 3 or (not colosse and mesh > 5) then table.insert(defauts, mesh .. " MeshParts") end
		if neon > (if colosse then B.NeonColosse else 0) then table.insert(defauts, neon .. " Neon") end
		if drapeaux then table.insert(defauts, "CastShadow/CanCollide/CanQuery/CanTouch") end
		if not colosse then pireZbire = math.max(pireZbire, nb) end
		if #defauts > 0 then
			table.insert(zbiresKO, ("%s (%s)"):format(nom, table.concat(defauts, ", ")))
			table.insert(fautifs, modele)
		end
	end
	local okLien, auto = pcall(function()
		return (dossier :: any):FindFirstChildWhichIsA("PackageLink").AutoUpdate
	end)

	local bloquants = 0
	local function regle(ok: boolean, bloquant: boolean, texte: string)
		if ok then return print("  OK     " .. texte) end
		if bloquant then bloquants += 1 end
		warn((if bloquant then "  KO     " else "  AVERT  ") .. texte)
	end
	local plafond = if prairie
		then math.min(gabarit and gabarit:GetAttribute("PartsStatiques") or B.PartsPrairie, B.PartsPrairie)
		else B.PartsLabo
	local smooth = if n.parts > 0 then n.smooth / n.parts else 1
	print(("[Auditeur Pixel-bloc v2] %s, profil %s"):format(game.Name, if prairie then "Prairie" else "Laboratoire"))
	regle(charteConforme(), true, "Charte : Couleurs (11 du canon), teinte(), Interface, Ambiances, rien d'autre")
	regle(gabarit ~= nil, true, "ServerStorage.Outillage.Gabarit présent")
	regle(n.parts <= plafond, true, ("Parts statiques %d / %d"):format(n.parts, plafond))
	regle(n.neon <= B.Neon, true, ("Neon %d / %d"):format(n.neon, B.Neon))
	for zone, nb in neonZone do
		local budget = gabarit and gabarit:GetAttribute("Neon_" .. zone) or 0
		regle(nb <= budget, true, ("Neon %s %d / %d (Gabarit)"):format(zone, nb, budget))
	end
	regle(n.lumieres <= B.Lumieres, true, ("Lumières toutes classes %d / %d"):format(n.lumieres, B.Lumieres))
	regle(n.actifs <= B.Emetteurs, true, ("ParticleEmitter Enabled %d / %d"):format(n.actifs, B.Emetteurs))
	regle(#emetteurs == 0, true, ("Rate > 20 : %d émetteur(s), corrigeable"):format(#emetteurs))
	regle(#couleurs == 0, true, ("Hors palette : %d Part(s), corrigeable"):format(#couleurs))
	regle(smooth >= B.Smooth, true, ("SmoothPlastic %d %%, minimum 90"):format(math.floor(smooth * 100)))
	regle(workspace.Terrain:CountCells() == 0, true, "Terrain:CountCells() = 0")
	regle(#manquants == 0, true, "Modeles.Zbires, types manquants : " .. table.concat(manquants, ", "))
	regle(#zbiresKO == 0, true, "Format Forge : " .. table.concat(zbiresKO, " ; "))
	regle(ReplicatedStorage:FindFirstChild("Zbires") == nil, true, "Ancien dossier ReplicatedStorage.Zbires supprimé")
	regle(okLien and auto == true, false, "Modeles.Zbires en Package AutoUpdate")
	if prairie then
		local pire = if pireZbire > 0 then pireZbire else B.PartsZbire
		local pic = n.parts + B.Horde * pire + B.Reserve
		regle(n.hauts == 0, true, ("Plus de 6 studs à moins de 60 de la Maison : %d"):format(n.hauts))
		regle(n.hors == 0, true, ("Hors arène ± 110 (HorsArene ± 150) : %d"):format(n.hors))
		regle(not workspace.StreamingEnabled, true, "StreamingEnabled désactivé")
		regle(pic <= B.PartsArene, true,
			("Pic %d / %d = statique + 60 × %d + 30 + 450 + 240 + 300"):format(pic, B.PartsArene, pire))
	end
	print(("[Auditeur] %d bloquant(s)%s"):format(bloquants, if bloquants == 0 then " : publiable." else ", fautifs sélectionnés."))
	Selection:Set(fautifs)
	dernier = { couleurs = couleurs, emetteurs = emetteurs }
end

local function corriger()
	if not RunService:IsEdit() then return warn("[Auditeur] Corriger : mode édition uniquement.") end
	local id = ChangeHistoryService:TryBeginRecording("Corriger Pixel-bloc")
	if not id then return warn("[Auditeur] Enregistrement impossible, réessaie.") end
	local total = 0
	for _, paire in dernier.couleurs do
		if paire[1].Parent then paire[1].Color, total = paire[2], total + 1 end
	end
	for _, emetteur in dernier.emetteurs do
		if emetteur.Parent then emetteur.Rate, total = B.Rate, total + 1 end
	end
	ChangeHistoryService:FinishRecording(id, Enum.FinishRecordingOperation.Commit)
	dernier = { couleurs = {}, emetteurs = {} }
	print(("[Auditeur] %d correction(s), Ctrl+Z pour annuler. Relance « Auditer »."):format(total))
end

local barre = plugin:CreateToolbar("Zsurvie Outillage")
for _, def in { { "Auditer", "Charte Pixel-bloc, budgets du canon et Zbires", auditer },
	{ "Corriger", "Couleurs sur les 33 teintes, Rate à 20", corriger } } do
	local bouton = barre:CreateButton(def[1], def[2], "")
	bouton.ClickableWhenViewportHidden = true
	bouton.Click:Connect(function()
		bouton:SetActive(false)
		def[3]()
	end)
end
```

## Outil 2 : Semeur de Prairie

- **Greybox** (lit le Gabarit) : `Prairie_Sol` 220 × 1 × 220 en Prairie ; 4 chemins en croix en Terre battue, 8 studs de large ; `Maison` 16 × 16 × 14 en (0, 0, 0) ; `Mine` à 12 studs, hors des chemins ; repère à 70 studs ; 8 `Lisiere_Portail_NN` à 85 studs tous les 45° en Violet horde, chacun avec une `Attachment` `Apparition` lue par le serveur. Couleurs tirées de `Charte.teinte`.
- **Semis** : panneau `DockWidgetPluginGui` des prefabs de `ServerStorage.Prefabs.Decor` (attributs `Zone`, `Grille` = 1 ou 4) ; raycast sous la souris, arrondi à la grille, rotation de 90° (`R`), pinceau de 4 à 16 studs pour la Lisière.
- **Garde-fous** : fantôme en Alerte, pose refusée au-dessus de 6 studs à moins de 60 studs de la Maison, sur un chemin, à moins de 4 studs de la Maison ou de la Mine, au-delà de ± 110 studs (± 150 pour un prefab portant l'attribut `HorsArene`, tagué `HorsArene` à la pose).
- **Nommage** `Decor.<Zone>.<Zone>_<Prefab>_NNN`, une étape `ChangeHistoryService` par pose.

## Outil 3 : Forge à Zbires

**Chemin unique : `ReplicatedStorage.Modeles.Zbires`.** La Forge y range, l'Auditeur y contrôle, le Package `AutoUpdate` le partage entre les 2 places, la Galerie et `ZbiresRendu` (a26) y lisent. Aucune copie ailleurs.

| Types | Parts (Racine comprise) | MeshParts | Neon |
|---|---|---|---|
| Marcheur, Rapide, Costaud, Dore, Sauteur, Gluant, MiniGluant, Volant, Casque | 6 au plus | 3 à 5 | 0 |
| Colosse | 30 au plus | 3 au moins | 4 au plus |

- **Forger** (Models sélectionnés, une étape annulable) : supprime `Humanoid`, `Animator`, `Light`, `ParticleEmitter` et scripts ; arrondit à 0,5 stud ; crée `Racine` (Part 2 × 0,5 × 2, `Anchored`, `Transparency` 1, `PrimaryPart`) ; soude le reste par `WeldConstraint`, `Massless` ; met `CastShadow`, `CanCollide`, `CanQuery` et `CanTouch` à false partout ; recale les couleurs sur les 33 teintes ; renomme selon les 10 types et pose l'attribut `Type`. Tout modèle hors format est refusé : le modeleur fusionne ses cubes de 0,5 stud en 3 à 5 MeshParts avant l'import.
- Aucune stat dans les modèles : PV, vitesse et butin restent côté serveur. Le client déplace les Racines d'un seul `workspace:BulkMoveTo`.
- **Galerie** (Laboratoire) : par Zbire, un socle 6 × 6 `Galerie_Socle_NN`, la figurine × 1,5 (`Model:ScaleTo`) et 3 emplacements de variantes (attribut `Seuil` = 10, 100, 1 000).

## 🎨 UI / UX

### 🖌️ Designer d'interface — Milo Achard
## 1. Principes

- **Pixel-bloc** : grille de 4 px, petits arrondis, contour Encre épais et socle 3D sous chaque bouton, comme les cubes du décor.
- **Code couleur du canon** : orange et crème = à nous, or = pièces, cyan = gemmes, violet = Zbires, rose-rouge = danger. Ajout : vert Prairie = réussite.
- **Jamais la couleur seule** (daltonisme) : toujours une icône ou un mot. **Ni noir ni blanc purs** : Crème et Encre les remplacent.
- **Le serveur décide** : les compteurs ne lisent que les attributs `Pieces` et `Gemmes` posés par le serveur sur le `Player`. Un bouton d'achat attend la réponse du serveur.

## 2. Couleurs de l'interface

Ombre = base × 0,8 ; lumière = `base:Lerp(Creme, 0.2)`.

| Jeton | Base | Ombre | Lumière | Usage |
|---|---|---|---|---|
| Principal | #EF7A2F | #BF6226 | #F0904C | Bouton principal, PV de la Maison |
| Secondaire | #4A4560 | #3B374D | #6C6573 | Bouton secondaire, onglet inactif, verrouillé |
| Panneau | #F6E7C1 | #C5B99A | #F6E7C1 | Fond des panneaux de run, texte clair |
| PanneauLabo | #2A3263 | #22284F | #535676 | Fond des panneaux du Laboratoire |
| Contour | #1E1B2E | #181625 | #49444B | Contours, texte sur fond clair, pastilles HUD (transparence 0,2) |
| Pieces | #FFC933 | #CCA129 | #FDCF4F | Montants en pièces |
| Gemmes | #33D6F0 | #29ABC0 | #5AD9E7 | Montants en gemmes, contour des panneaux Labo |
| Ennemi | #9B5DE5 | #7C4AB7 | #AD79DE | Barre du Colosse, phase de horde |
| Danger | #FF2E63 | #CC254F | #FD5376 | Alertes, Maison sous 30 %, solde insuffisant |
| Succes | #6CC24A | #569B3B | #88C962 | Achat confirmé, Répit, « Merci ! » |

Contrastes : Encre sur Crème 13,7:1, sur Prairie 7,5:1, sur orange 6:1. Crème sur orange plafonne à 2,3:1 : tout libellé Crème posé sur une couleur porte un contour de texte Encre de 2 px.

## 3. Typographie

| Rôle | `Enum.Font` | `TextSize` | Usage |
|---|---|---|---|
| Affiche | `LuckiestGuy` | 40 | « JOUR 7 », « LE COLOSSE ARRIVE ! » (contour Encre 3 px) |
| Titre | `LuckiestGuy` | 28 | Bandeaux de panneaux |
| Bouton | `FredokaOne` | 22 / 18 | Principal / secondaire et onglets |
| Chiffres | `Arcade` | 16, 24, 32 | Pièces, gemmes, chronos |
| Corps | `BuilderSansBold` | 16 | Descriptions, notifications |
| Légende | `BuilderSansBold` | 14 | Niveaux, légendes d'icônes |

- `Arcade` est une police bitmap : multiples de 8 uniquement, sinon elle devient floue.
- Plancher 14 px. `TextScaled` seulement avec `UITextSizeConstraint` (`MinTextSize` 14).
- 2 mots par bouton, 10 par notification : beaucoup de 9 ans lisent encore lentement.

## 4. Grille, échelle et zones mobiles

- **Référence 780 × 360 px en paysage** (`StarterGui.ScreenOrientation = LandscapeSensor`). Toutes les valeurs sont à l'échelle 1.
- **Échelle** : chaque zone (enfant direct d'un `ScreenGui`, `AnchorPoint` sur son coin) porte un `UIScale` = `math.clamp(ViewportSize.Y / 360, 1, 1.5)`, recalculé sur `ViewportSize`.
- **Espacements** : 4 / 8 / 12 / 16 / 24 px ; marge d'écran 16 px.
- **Cibles** : 60 × 60 px minimum, 72 × 72 pour les actions de run, 16 px entre deux cibles.
- **Zones interdites** : 220 × 180 px en bas à gauche (joystick), 110 × 110 px en bas à droite (saut).
- `ScreenInsets = CoreUISafeInsets` partout, sauf `Transition` (`None`).
- `UICorner` 4 px (boutons, onglets), 8 px (panneaux) ; `UIStroke` Encre 2 px (boutons), 3 px (panneaux).

## 5. Composants et états

### Bouton principal

`Frame` « Socle » (Ombre, `UIStroke` Border) contenant un `TextButton` « Face » (Base, `AutoButtonColor = false`, 6 px moins haute, libellé avec `UIStroke` Contextual). 200 × 60 dans un panneau ; 72 × 72 en action HUD (icône 40 px + légende 14 px).

| État | Rendu | Déclencheur |
|---|---|---|
| Repos | Face Base, socle visible sur 6 px | — |
| Survol (PC) | Face Lumière | `MouseEnter` |
| Appuyé | Face descendue de 4 px | `InputBegan` |
| Attente | « … », `TextTransparency` 0,4, appuis ignorés | Demande envoyée |
| Validé | Ressort : hauteur × 0,8, largeur × 1,2, 0,15 s | Serveur : `true` |
| Refusé | Tremblement 4 px sur 0,2 s + notification « Il te manque 35 pièces » | Solde répliqué insuffisant ou serveur : `false` |
| Verrouillé | Face #6C6573, libellé #C5B99A + cadenas | Recherche prérequise absente |

### Bouton secondaire

Mêmes structure et états en Ardoise, 160 × 60, `FredokaOne` 18. Un seul bouton principal par écran. « Fermer » : secondaire 60 × 60, croix Crème, en haut à droite du panneau.

### Panneau

- **Run** : fond Crème, contour Encre 3 px. **Labo** : fond Nuit labo, contour #29ABC0, texte Crème.
- Bandeau de titre de 56 px : Établi orange, Arbre des Recherches cyan, Galerie des Zbires violet, Défi du Jour or.
- `UIPadding` 16 px, `UISizeConstraint.MaxSize` 640 × 320, ombre = `Frame` Encre, transparence 0,5, décalée de (0, 6).
- En run, l'Établi est un **panneau latéral droit de 55 %** : le Survivant reste visible, le tir automatique continue.
- États : Fermé (`Visible = false`) → Ouverture (`UIScale` 0,8 → 1, `Back`, 0,15 s) → Ouvert → Fermeture (0,1 s). Un seul panneau à la fois ; il masque les actions du HUD, jamais la barre de la Maison.

### Onglet

60 px de haut, 96 px de large minimum, `UIListLayout` horizontal (`Padding` 4).

| État | Rendu |
|---|---|
| Inactif | Face Ardoise, libellé Crème |
| Actif | Face couleur du fond, soudée au panneau, libellé Encre (Crème au Labo), trait de 4 px couleur du bandeau |
| Nouveau | Pastille Alerte de 16 px avec « ! » |
| Verrouillé | Ardoise lumière + cadenas ; l'appui affiche le prérequis |

### Notification

Toast 360 × 56 px centré sous les barres du haut ; `UIListLayout` vertical, 3 visibles, les suivantes attendent. Fond Crème, bande gauche de 8 px et icône 40 px à la couleur du type.

| Type | Couleur | Durée | Exemple |
|---|---|---|---|
| Info | Ardoise | 3 s | « Muret posé (2/3) » |
| Butin | Or ou Cyan | 2 s | « +150 gemmes » |
| Succès | Prairie | 3 s | « Cadence niveau 3 ! » |
| Danger | Fond Alerte, texte Crème contouré | 4 s | « La Maison est à 30 % ! » |
| Annonce | Bandeau violet pleine largeur, 72 px, `LuckiestGuy` 40 | 3 s | « LE COLOSSE ARRIVE ! » |

États : Entrée (glissé de 20 px + ressort 0,15 s), Affichée, Sortie (fondu 0,2 s), Fusion (même message en moins de 2 s : « × 3 » au lieu d'un nouveau toast).

## 6. Arborescence des ScreenGui

Tous : `ResetOnSpawn = false`, `ZIndexBehavior = Sibling`. Les composants vivent dans le Package `ReplicatedStorage.Interface`, partagé par les deux places. Le nombre après le nom est le `DisplayOrder`.

```text
StarterGui (place Prairie)
├─ HUD            10   HautGauche : Jour (Arcade 24) + barre horde violette / Répit verte
│                      HautCentre : BarreMaison (orange), BarreColosse (violette)
│                      HautDroite : Pieces, Gemmes, Menu
│                      BasDroite  : Reparer, Poser (Muret, Mini-Tourelle, Tapis Collant, x/3), Ping
├─ RouePings      20   4 quartiers : Colosse ! violet, Répare ! orange, Ici ! crème, Merci ! vert
├─ Panneaux       30   Etabli
├─ Notifications  40   File, Annonce
├─ FinDeRun       50   Jour atteint, gemmes gagnées, Retour au Laboratoire
└─ Transition     100  IgnoreGuiInset, passé à TeleportService:SetTeleportGui

StarterGui (place Laboratoire)
├─ HUD            10   Gemmes, DefiDuJour, Foreuse
├─ Capsule        20   Départ dans 15 s (Arcade 32), places x/6, Descendre
├─ Panneaux       30   ArbreRecherches, Galerie, DefiDuJour
├─ Notifications  40   File
├─ Tutoriel       60   Bulles de Doc Boulon
└─ Transition     100
```

Hors écran : `BillboardGui` « Record : Jour X » sur la Maison (`LuckiestGuy` 28) et `ProximityPrompt` en `Style = Custom`, dessinés au gabarit du bouton secondaire.

## 7. Code

```lua
-- ReplicatedStorage.Charte.Interface (ModuleScript enfant de Charte)
local Palette = require(script.Parent).Palette -- Color3 aux noms du canon, sans accents

local function teintes(base: Color3)
	return table.freeze({
		Base = base,
		Ombre = Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8),
		Lumiere = base:Lerp(Palette.Creme, 0.2),
	})
end

return table.freeze({
	Couleurs = table.freeze({
		Principal = teintes(Palette.ToitOrange), Secondaire = teintes(Palette.Ardoise),
		Panneau = teintes(Palette.Creme), PanneauLabo = teintes(Palette.NuitLabo),
		Pieces = teintes(Palette.Or), Gemmes = teintes(Palette.GemmeCyan),
		Ennemi = teintes(Palette.VioletHorde), Danger = teintes(Palette.Alerte),
		Succes = teintes(Palette.Prairie),
		Contour = Palette.Encre, TexteSurClair = Palette.Encre, TexteSurSombre = Palette.Creme,
	}),
	Polices = table.freeze({
		Affiche = Enum.Font.LuckiestGuy, Titre = Enum.Font.LuckiestGuy, Bouton = Enum.Font.FredokaOne,
		Chiffres = Enum.Font.Arcade, Corps = Enum.Font.BuilderSansBold,
	}),
	Tailles = table.freeze({
		Affiche = 40, Titre = 28, BoutonPrincipal = 22, BoutonSecondaire = 18,
		ChiffresGrands = 24, ChiffresPetits = 16, Corps = 16, Legende = 14,
	}),
	Rayons = table.freeze({ Bouton = UDim.new(0, 4), Panneau = UDim.new(0, 8) }),
	Contours = table.freeze({ Bouton = 2, Panneau = 3, Texte = 2 }),
	Socle = 6,
	CibleMin = 60,
	Ressort = table.freeze({ Duree = 0.15, Ecrasement = 0.8, Etirement = 1.2, EtirementLarge = 1.05 }),
	Reference = Vector2.new(780, 360),
})
```

```lua
-- ReplicatedStorage.Interface.Bouton (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UI = require(ReplicatedStorage.Charte.Interface)

local POSE = UDim2.new(0.5, 0, 1, -UI.Socle)
local APPUYE = UDim2.new(0.5, 0, 1, -2)
local CLICS = { [Enum.UserInputType.Touch] = true, [Enum.UserInputType.MouseButton1] = true }

local Bouton = {}
Bouton.__index = Bouton

local function habiller(objet: GuiObject, mode: Enum.ApplyStrokeMode)
	local coin = Instance.new("UICorner")
	coin.CornerRadius = UI.Rayons.Bouton
	coin.Parent = objet
	local contour = Instance.new("UIStroke")
	contour.Color = UI.Couleurs.Contour
	contour.Thickness = UI.Contours.Bouton
	contour.ApplyStrokeMode = mode
	contour.Parent = objet
end

function Bouton.new(parent: Instance, libelle: string, variante: string, taille: UDim2)
	local self = setmetatable({ libelle = libelle, variante = variante, etat = "Repos" }, Bouton)
	local socle = Instance.new("Frame")
	socle.Name = "Bouton" .. variante
	socle.Size = taille
	habiller(socle, Enum.ApplyStrokeMode.Border)

	local face = Instance.new("TextButton")
	face.Name = "Face"
	face.AutoButtonColor = false
	face.AnchorPoint = Vector2.new(0.5, 1)
	face.Position = POSE
	face.Size = UDim2.new(1, 0, 1, -UI.Socle)
	face.Font = UI.Polices.Bouton
	face.TextSize = if variante == "Principal" then UI.Tailles.BoutonPrincipal else UI.Tailles.BoutonSecondaire
	habiller(face, Enum.ApplyStrokeMode.Contextual)
	face.Parent = socle
	self.socle, self.face = socle, face
	self:definirEtat("Repos")

	face.MouseEnter:Connect(function()
		if self.etat == "Repos" then face.BackgroundColor3 = UI.Couleurs[variante].Lumiere end
	end)
	face.MouseLeave:Connect(function()
		if self.etat == "Repos" then face.BackgroundColor3 = UI.Couleurs[variante].Base end
	end)
	face.InputBegan:Connect(function(entree: InputObject)
		if self.etat == "Repos" and CLICS[entree.UserInputType] then face.Position = APPUYE end
	end)
	face.InputEnded:Connect(function() face.Position = POSE end)
	socle.Parent = parent
	return self
end

function Bouton:definirEtat(etat: string)
	self.etat = etat
	local verrouille = etat == "Verrouille"
	local teinte = if verrouille then UI.Couleurs.Secondaire else UI.Couleurs[self.variante]
	self.face.BackgroundColor3 = if verrouille then teinte.Lumiere else teinte.Base
	self.socle.BackgroundColor3 = teinte.Ombre
	self.face.TextColor3 = if verrouille then UI.Couleurs.Panneau.Ombre else UI.Couleurs.TexteSurSombre
	self.face.TextTransparency = if etat == "Attente" then 0.4 else 0
	self.face.Text = if etat == "Attente" then "…" else self.libelle
end

function Bouton:ressort()
	local a = self.socle.AbsoluteSize
	local etirement = if a.X > a.Y * 2 then UI.Ressort.EtirementLarge else UI.Ressort.Etirement
	local info = TweenInfo.new(UI.Ressort.Duree / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
	TweenService:Create(self.face, info, { Size = UDim2.new(etirement, 0, UI.Ressort.Ecrasement, -UI.Socle) }):Play()
end

function Bouton:refus()
	local info = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1, true)
	TweenService:Create(self.face, info, { Position = POSE + UDim2.fromOffset(4, 0) }):Play()
end

-- Le client demande ; le serveur vérifie solde, distance, cadence et renvoie (accepte, raison).
-- estAbordable lit un attribut posé par le serveur : il évite un aller-retour, il ne décide rien.
function Bouton:lierDemande(remote: RemoteFunction, estAbordable: () -> boolean, ...: any)
	local arguments = table.pack(...)
	self.face.Activated:Connect(function()
		if self.etat ~= "Repos" then return end
		if not estAbordable() then
			self:refus()
			return
		end
		self:definirEtat("Attente")
		local ok, accepte = pcall(remote.InvokeServer, remote, table.unpack(arguments, 1, arguments.n))
		self:definirEtat("Repos")
		if ok and accepte then self:ressort() else self:refus() end
	end)
end

return Bouton
```

## 8. Écarts et ajouts à valider par Victor Lanoue

- **Écart, ressort** : sur un bouton plus de 2 fois plus large que haut, l'étirement passe de × 1,2 à × 1,05 pour ne pas chevaucher ses voisins.
- **Ajouts au code couleur** : vert Prairie = réussite ; contour cyan des panneaux du Labo, car l'Encre disparaît sur Nuit labo.

### 🎛️ Designer HUD — Thaïs Norvin
## 1. Règles de composition

- **En haut on lit, en bas à droite on agit.** Sur tactile, seuls le groupe `BasDroite` et la Roue des Pings réagissent au toucher.
- **4 blocs permanents au maximum :** le Bandeau Maison, les Pièces, les têtes des Survivants et les boutons d'action. Le reste est contextuel ou replié.
- **Référence 1280 × 720, paysage forcé** (`StarterGui.ScreenOrientation = LandscapeSensor`). Chaque groupe ancré porte un `UIScale` tagué `HudScale`, réglé à `clamp(min(X/1280, Y/720), 0.6, 1.25)`. Un bouton de 100 réf. mesure donc toujours au moins 60 px.
- **ScreenGui `HUD` :** `ResetOnSpawn = false`, `IgnoreGuiInset = false`, `ScreenInsets = CoreUISafeInsets` (encoche et barre Roblox), `ZIndexBehavior = Sibling`, `DisplayOrder = 10`. Les CoreGui `Backpack`, `Health`, `PlayerList` et `EmotesMenu` sont désactivés pendant la run.
- **Zones interdites :** le coin bas-gauche sur 45 % × 55 % (joystick) et le centre, où se trouve le Survivant. Seules les annonces de 2,5 s y passent.
- **Saut :** hypothèse `JumpPower = 0`. Le bouton de saut natif se masque et libère le coin bas-droit.
- **Style Pixel-bloc :** panneaux Encre #1E1B2E en transparence 0,25, angles droits, `UIStroke` Encre 3 px, ombre décalée de (4, 4). Police `Enum.Font.FredokaOne` (`Arcade` réservée aux annonces). Texte Crème avec `UIStroke` 2 px. Libellés en 26 réf. (≈ 16 px sur téléphone), chiffres en 34 réf. (≈ 20 px).
- Le « Record : Jour X » reste un `BillboardGui` au-dessus de la Maison, comme le prévoit le canon. Le HUD ne le répète pas.

## 2. Maquette (téléphone en paysage)

```
┌────────────────────────────────────────────────────────────────┐
│[◎ 1 240]         [JOUR 7 ▓▓▓▓▓▓▓▓░░░ 0:42]         [☺☺☺☺☺☺] │
│[◆ +18]             [ COLOSSE ▓▓▓▓▓▓▓▓ ]                        │
│[☀][✦]                                                          │
│◄×9                   « JOUR 8 ! »                        ×4►  │
│                       (Survivant)                              │
│                                                        [PING]  │
│ (joystick)      ▼×3   [Tapis][Tour.][Muret][POSER 2/3][RÉPARE] │
└────────────────────────────────────────────────────────────────┘
```

## 3. Priorités d'information

| Rang | Information | Visibilité | Signal |
|---|---|---|---|
| 1 | PV de la Maison | Permanent | À 25 % ou moins : barre Alerte #FF2E63 qui pulse (0,5 s) et bip 8-bit |
| 2 | Colosse | Annonce 5 s avant, puis barre tant qu'il vit | Violet horde, flèche Alerte |
| 3 | Étourdi 2 s | Contextuel | Boutons grisés en Ardoise |
| 4 | Répare, Poser, Ping | Permanent (tactile) | Répare brille quand la Maison est abîmée |
| 5 | Jour et minuteur | Permanent | Crème pendant la horde, Prairie #6CC24A pendant le Répit |
| 6 | Pièces | Permanent | Or #FFC933, rebond à chaque gain |
| 7 | Zbires hors champ | Contextuel | Flèches de bord |
| 8 | Coéquipiers | Replié (têtes seules) | Tête grisée si étourdi, clignote quand il envoie un ping |
| 9 | Gemmes de la run | Pendant le Répit uniquement | Cyan #33D6F0 |
| 10 | Défi du Jour | Replié (2 icônes) | Texte en annonce au départ |

## 4. Placement

### Groupes ancrés

| Groupe | AnchorPoint | Position | Size | Adaptation |
|---|---|---|---|---|
| `HautGauche` | (0, 0) | `UDim2.new(0, 12, 0, 8)` | 220 × 170 | `UIScale` |
| `HautCentre` | (0.5, 0) | `UDim2.new(0.5, 0, 0, 8)` | 440 × 112 | `UIScale` |
| `HautDroite` | (1, 0) | `UDim2.new(1, -12, 0, 8)` | 270 × 40 | `UIScale` |
| `BasDroite` | (1, 1) | `UDim2.new(1, -16, 1, -16)` | 600 × 240 | `UIScale` |
| `AideClavier` (PC) | (0.5, 1) | `UDim2.new(0.5, 0, 1, -12)` | 560 × 36 | `UIScale` |
| `Annonces` | (0.5, 0.5) | `UDim2.fromScale(0.5, 0.28)` | `fromScale(0.6, 0.14)` | `UIAspectRatioConstraint` 5, `UITextSizeConstraint` 20–64 |
| `RouePings` | (0.5, 0.5) | `UDim2.fromScale(0.5, 0.5)` | `fromScale(0.55, 0.55)` | `UIAspectRatioConstraint` 1, `DominantAxis = Height` |
| `Indicateurs` | (0, 0) | `UDim2.fromScale(0, 0)` | `fromScale(1, 1)` | tailles en scale |

### Éléments (position dans leur groupe, taille de référence)

| Élément | AnchorPoint | Position | Taille | État |
|---|---|---|---|---|
| `Bandeau` | (0.5, 0) | `UDim2.new(0.5, 0, 0, 0)` | 440 × 64 | Permanent |
| · `Jour` | (0, 0.5) | `UDim2.new(0, 12, 0.5, 0)` | 100 × 40 | « JOUR 7 » |
| · `BarreMaison` | (0.5, 0.5) | `UDim2.fromScale(0.5, 0.5)` | 200 × 28 | Fond Ardoise, remplissage Toit orange #EF7A2F, crans tous les 25 % |
| · `Phase` | (1, 0.5) | `UDim2.new(1, -12, 0.5, 0)` | 100 × 40 | « 0:42 » ou « RÉPIT 12 » |
| `BarreColosse` | (0.5, 0) | `UDim2.new(0.5, 0, 0, 76)` | 360 × 28 | Contextuel |
| `Pieces` | (0, 0) | `UDim2.fromOffset(0, 0)` | 200 × 56 | Permanent |
| `GemmesRun` | (0, 0) | `UDim2.fromOffset(0, 64)` | 160 × 44 | Répit |
| `DefiDuJour` | (0, 0) | `UDim2.fromOffset(0, 116)` | 2 × 44 × 44 | Lecture seule |
| `Survivants` | (1, 0) | `UDim2.fromScale(1, 0)` | 6 têtes de 40 × 40, `UIListLayout` horizontal | Déplié sur PC avec Tab (une ligne de 220 × 44 par joueur) |
| `Repare` | (1, 1) | `UDim2.fromScale(1, 1)` | 120 × 120 | Permanent |
| `Poser` | (1, 1) | `UDim2.new(1, -136, 1, 0)` | 100 × 100 | Badge « 2/3 » |
| `ChoixDefense` | (1, 1) | `UDim2.new(1, -252, 1, 0)` | 332 × 100, `Padding` 16 | Replié : Muret, Mini-Tourelle, Tapis Collant |
| `Ping` | (1, 1) | `UDim2.new(1, 0, 1, -136)` | 100 × 100 | Permanent |
| Bulles de la Roue | (0.5, 0.5) | (0.5, 0.17), (0.17, 0.5), (0.5, 0.83), (0.83, 0.5) | `fromScale(0.33, 0.33)` | « Colosse ! », « Répare ! », « Ici ! », « Merci ! » ; fermeture après 3 s |

**Flèches de bord :** un pool de 8 `ImageLabel`, un par secteur de 45° non vide, plus une flèche pour le Colosse, une pour la Maison et une pour l'Établi.
- **Taille :** `fromScale(0, 0.1)` avec `UIAspectRatioConstraint` 1 et `DominantAxis = Height`.
- **Position :** sur une ellipse `fromScale(0.5 + 0.44·cos θ, 0.45 + 0.33·sin θ)`, avec `Rotation = θ` et une pastille « ×N ».
- **Couleurs :** Violet horde par défaut, Or si le secteur contient un Doré, Alerte pour le Colosse.
- **Comportement :** `Active = false` (aucun toucher capté), rafraîchies à 10 Hz.

## 5. Petits écrans

| Appareil (zone utile) | Échelle | Bouton de 100 réf. |
|---|---|---|
| Android d'entrée de gamme, 740 × 360 | 0,6 (plancher) | 60 px |
| iPhone, 844 × 390 | 0,6 | 60 px |
| iPad, 1024 × 768 | 0,8 | 80 px |
| PC, 1920 × 1080 | 1,25 (plafond) | 125 px |

Sur un écran de 740 px, les boutons d'action ouverts occupent 366 px à droite et le joystick 333 px à gauche : il reste 41 px de marge. Aucun `CanvasGroup`, trop gourmand en mémoire sur un appareil de 3 Go.

## 6. `HudController` (LocalScript)

```lua
-- StarterPlayer.StarterPlayerScripts.HudController (place Prairie)
-- Le HUD lit les attributs écrits par le serveur et n'envoie que des demandes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
for _, nom in { "DemandeReparation", "DemandePose", "DemandePing" } do
	Remotes:WaitForChild(nom)
end
local joueur = Players.LocalPlayer
local hud = joueur:WaitForChild("PlayerGui"):WaitForChild("HUD") :: ScreenGui
local etatRun = ReplicatedStorage:WaitForChild("EtatRun")
local maison = workspace:WaitForChild("Maison")
local camera = workspace.CurrentCamera

local function trouver(chemin: string): any
	local objet: Instance = hud
	for nom in string.gmatch(chemin, "[^%.]+") do
		objet = objet:WaitForChild(nom)
	end
	return objet
end

for _, t in { Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.EmotesMenu } do
	StarterGui:SetCoreGuiEnabled(t, false)
end

-- Échelle : plancher 0,6 → 60 px pour un bouton de 100 réf.
local function majEchelle()
	local vue = camera.ViewportSize
	local e = math.clamp(math.min(vue.X / 1280, vue.Y / 720), 0.6, 1.25)
	for _, s in CollectionService:GetTagged("HudScale") do
		if s:IsA("UIScale") and s:IsDescendantOf(hud) then s.Scale = e end
	end
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(majEchelle)
majEchelle()

local function rebond(objet: Instance) -- étirement × 1,2 puis retour en 0,15 s
	local s = objet:FindFirstChild("Rebond")
	if s and s:IsA("UIScale") then
		s.Scale = 1.2
		TweenService:Create(s, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
end

-- Bandeau Maison
local remplissage = trouver("HautCentre.Bandeau.BarreMaison.Remplissage")
local texteJour = trouver("HautCentre.Bandeau.Jour")
local textePhase = trouver("HautCentre.Bandeau.Phase")

local function majMaison()
	local ratio = math.clamp((maison:GetAttribute("PV") or 0) / math.max(maison:GetAttribute("PVMax") or 1, 1), 0, 1)
	TweenService:Create(remplissage, TweenInfo.new(0.15), { Size = UDim2.fromScale(ratio, 1) }):Play()
	remplissage.BackgroundColor3 = if ratio <= 0.25 then Charte.Alerte else Charte.ToitOrange
end
maison:GetAttributeChangedSignal("PV"):Connect(majMaison)
maison:GetAttributeChangedSignal("PVMax"):Connect(majMaison)
majMaison()

local function majJour()
	texteJour.Text = `JOUR {etatRun:GetAttribute("Jour") or 1}`
	rebond(texteJour)
end
etatRun:GetAttributeChangedSignal("Jour"):Connect(majJour)
majJour()

local cadreGemmes = trouver("HautGauche.GemmesRun")
task.spawn(function()
	while hud.Parent do
		local reste = math.max(0, math.ceil((etatRun:GetAttribute("FinPhase") or 0) - workspace:GetServerTimeNow()))
		local repit = etatRun:GetAttribute("Phase") == "Repit"
		textePhase.Text = if repit then `RÉPIT {reste}` else string.format("%d:%02d", reste // 60, reste % 60)
		textePhase.TextColor3 = if repit then Charte.Prairie
			elseif etatRun:GetAttribute("ColosseActif") then Charte.Alerte
			else Charte.Creme
		cadreGemmes.Visible = repit
		task.wait(0.25)
	end
end)

-- Pièces : affichage seul, le serveur décide du montant
local valeurPieces = trouver("HautGauche.Pieces.Valeur")
joueur:GetAttributeChangedSignal("Pieces"):Connect(function()
	valeurPieces.Text = tostring(joueur:GetAttribute("Pieces") or 0)
	rebond(valeurPieces)
end)

-- Actions : boutons sur tactile, E / 1-2-3 / Q sur PC
local basDroite = trouver("BasDroite")
local choix = trouver("BasDroite.ChoixDefense")
local roue = trouver("RouePings")

local function lier(nom: string, bouton: GuiButton, touche: Enum.KeyCode, action: () -> ())
	bouton.Activated:Connect(action)
	ContextActionService:BindAction(nom, function(_, etat)
		if etat == Enum.UserInputState.Begin then action() end
		return Enum.ContextActionResult.Sink
	end, false, touche)
end

lier("Reparer", trouver("BasDroite.Repare"), Enum.KeyCode.E, function()
	Remotes.DemandeReparation:FireServer() -- distance et cadence vérifiées par le serveur
end)
trouver("BasDroite.Poser").Activated:Connect(function() choix.Visible = not choix.Visible end)
local touches = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three }
for i, nom in { "Muret", "MiniTourelle", "TapisCollant" } do
	lier("Poser" .. nom, choix:WaitForChild(nom), touches[i], function()
		Remotes.DemandePose:FireServer(nom) -- emplacement et plafond de 3 validés par le serveur
		choix.Visible = false
	end)
end
lier("Pings", trouver("BasDroite.Ping"), Enum.KeyCode.Q, function() roue.Visible = not roue.Visible end)
for _, bulle in roue:GetChildren() do
	if bulle:IsA("GuiButton") then
		bulle.Activated:Connect(function()
			Remotes.DemandePing:FireServer(bulle.Name) -- "Colosse" | "Repare" | "Ici" | "Merci"
			roue.Visible = false
		end)
	end
end

joueur:GetAttributeChangedSignal("DefensesPosees"):Connect(function()
	trouver("BasDroite.Poser.Badge").Text = `{joueur:GetAttribute("DefensesPosees") or 0}/3`
end)

local tactile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
basDroite.Visible = tactile
trouver("AideClavier").Visible = not tactile

-- Étourdi : boutons grisés jusqu'à l'heure fixée par le serveur
local function griser(gris: boolean)
	for _, b in basDroite:GetDescendants() do
		if b:IsA("ImageButton") then
			b.ImageColor3 = if gris then Charte.Ardoise else Color3.new(1, 1, 1) -- teinte neutre
		end
	end
end
joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
	local reste = (joueur:GetAttribute("EtourdiJusqua") or 0) - workspace:GetServerTimeNow()
	if reste <= 0 then return end
	griser(true)
	task.delay(reste, function()
		if workspace:GetServerTimeNow() >= (joueur:GetAttribute("EtourdiJusqua") or 0) then griser(false) end
	end)
end)
```

## 7. HUD du Laboratoire (`HUDLabo`)

- **Gemmes :** en haut à gauche (`UDim2.new(0, 12, 0, 8)`), en Cyan. En dessous, la jauge de la Foreuse : « Foreuse 5 h 12 / 8 h ».
- **Capsule :** au centre en haut (`AnchorPoint (0.5, 0)`), 360 × 64, « Départ dans 12 · 4/6 ». Le bouton « Descendre » (160 × 100) est ancré en bas à droite.
- **Défi du Jour / Zbire de la Semaine :** bouton de 100 × 100 à `UDim2.new(1, -16, 1, -16)`, avec la pastille « ! » quand il est disponible.

### 🛒 Designer boutiques & menus — Gaspard Itier
## 1. Règles de navigation

- **Trois taps au maximum** entre l'écran de jeu et n'importe quelle action. La fenêtre d'achat native de Roblox n'est pas comptée : on ne peut pas la supprimer.
- **Deux niveaux au maximum** : un panneau, puis une fiche.
- **Un bouton = une icône + 1 ou 2 mots.**
- **Prix codés par couleur (Charte)** : Or #FFC933 pour les Pièces, Gemme cyan #33D6F0 pour les Gemmes, Crème #F6E7C1 avec le glyphe `utf8.char(0xE002)` pour les Robux.
- **Aucun achat en combat** : la Boutique Robux n'existe que dans la place Laboratoire. Sur la Prairie, seul l'Établi s'ouvre.
- **Une seule pop-up à la fois, et jamais pour vendre.** Pas de compte à rebours, pas de pastille rouge sur la Boutique.
- Le mot « inventaire » n'apparaît jamais à l'écran (canon §9). Les cosmétiques possédés sont rangés dans le **Vestiaire**. *Écart : c'est un nom nouveau, que Victor Lanoue doit valider.*

## 2. Arborescence

**Laboratoire (place lobby)**

HUD : Gemmes en haut à gauche, Réglages en haut à droite, et une colonne de 4 boutons de 72 × 72 px à droite.

- **Recherches** → fiche → « Lancer » (bouton à maintenir).
- **Vestiaire** → onglets Survivant / Blaster / Traînée / Alcôve → un tap équipe l'objet.
- **Boutique** → onglets Vedette / Survivant / Blaster / Traînée / Alcôve / Serveur privé → fiche → « Acheter ».
- **Défi du Jour** → les 2 modificateurs et les 150 gemmes → « Y aller » (une flèche au sol mène à la Capsule du Jour).

Hors HUD :

- **Capsule**, une fois assis : bandeau « Capsule Normale · 3/6 · départ 12 s » et bouton « Descendre ».
- **Galerie des Zbires** : un `ProximityPrompt` par figurine affiche la progression 10 / 100 / 1 000 et un bouton « Équiper » qui ouvre le Vestiaire.
- **Réglages** : Musique, Effets, Vibrations, Qualité, Taille des boutons (100 / 125 %).

**Prairie (place run)**

- HUD géré par le Designer HUD.
- **Établi** → 8 cartes → un tap achète.
- **Pause** → Réglages ou « Laboratoire » (avec confirmation).
- **Fin de run** → écran de récompense → Laboratoire.

## 3. Parcours en 3 taps

| Objectif | Tap 1 | Tap 2 | Tap 3 |
|---|---|---|---|
| Acheter une amélioration | *(à moins de 10 studs, le panneau s'ouvre seul)* | Carte | — |
| Poser un Muret | Emplacement Muret | Sol (silhouette orange si valide, rose-rouge sinon) | — |
| Envoyer un ping | Maintenir, glisser, relâcher | — | — |
| Lancer une recherche | Recherches | Nœud | Maintenir « Lancer » 0,5 s |
| Équiper une tenue | Vestiaire (rouvre le dernier onglet) | Tenue | — |
| Acheter un cosmétique | Boutique | Offre | « Acheter », puis la fenêtre Roblox |
| Récupérer la Foreuse | « Récupérer » | — | — |
| Quitter une run | Pause | Laboratoire | Confirmer |

Raccourcis PC :

- `B` Boutique, `V` Vestiaire, `R` Recherches ;
- `Q` Roue des Pings, `1` à `3` pour les défenses ;
- `Échap` ferme le panneau ouvert.

## 4. Établi (Prairie), écran de référence 844 × 390 px

- **Ouverture** : le panneau s'ouvre à 10 studs de `workspace.Etabli` au plus et se ferme au-delà de 12 studs (test client 5 fois par seconde). Le tir automatique continue pendant l'achat.
- **Panneau** :
  - `Frame` avec `Size` `UDim2.fromScale(0.6, 0.72)`, `AnchorPoint` (1, 0.5) et `Position` (0.98, 0.55) ;
  - fond Nuit labo #2A3263, `UIStroke` Encre de 4 px, coins carrés.
- **Grille** : `UIGridLayout` de 4 × 2 avec `CellSize` `UDim2.fromScale(0.24, 0.46)`, soit environ 118 × 124 px. Toute la carte sert de bouton.
- **Carte** : icône de 48 px, nom, « Niv 3/10 » et prix en Or. Un bandeau Crème « ÉQUIPE » marque Solidité, Réparation et Régénération.
- **États** :
  - abordable : Toit orange ;
  - trop cher : Ardoise #4A4560, avec « il manque 14 » ;
  - niveau maximum : Or, avec « MAX ».
- **Retours** :
  - achat réussi : écrasement × 0,8 puis étirement × 1,2 en 0,15 s, et un son de caisse 8-bit ;
  - refus : 3 secousses de 4 px et un son grave, sans texte d'erreur.
- **Achat d'équipe** : tous les Survivants voient « Léa a amélioré Solidité (Niv 4) » pendant 2 s.

## 5. Arbre des Recherches (Laboratoire)

- **Organisation** : `ScrollingFrame` horizontal en plein écran, avec 3 branches :
  - **Maison** : Tourelle de toit… ;
  - **Blaster** : Balles perforantes, Visée critique… ;
  - **Mine** : Foreuse….
- **Nœuds** : 96 × 96 px. Trois états :
  - verrouillé : Ardoise et cadenas ;
  - abordable : bord cyan qui pulse à 1 Hz ;
  - acquis : Crème et coche Or.
- **Fiche** à droite, sur 35 % de la largeur :
  - effet chiffré en une ligne et passage « Niv 1 → 2 » ;
  - prix en cyan ;
  - bouton « Lancer » de 280 × 72 px, **à maintenir 0,5 s**. Il protège les Gemmes permanentes sans ajouter d'écran.
- **Accès** : bouton du HUD ou `ProximityPrompt` de l'Arbre physique.

## 6. Boutique (Robux, Laboratoire uniquement)

- **Onglets** verticaux de 72 px. L'onglet Vedette présente 4 offres renouvelées chaque samedi à 17 h avec le Zbire de la Semaine, sans compte à rebours.
- **Grille** de 3 × 2 cartes de 150 × 130 px. La mention « Possédé » remplace le prix des objets déjà achetés.
- **Fiche** :
  - un `ViewportFrame` de 260 × 260 px, où le Survivant tourne sur lui-même ;
  - un seul `ViewportFrame` actif à la fois, pour tenir sur l'Android 3 Go ;
  - un bouton Crème « Acheter » de 280 × 72 px, qui devient « Équiper » si l'objet est possédé.
- **Serveur privé** : aucune API Roblox ne permet de déclencher cet achat. L'onglet montre un guide en 3 images (« Page du jeu → Serveurs → Créer »). C'est la seule exception assumée à la règle des 3 taps.
- **Interdits** : aucun objet aléatoire, aucun pack de Gemmes, aucune amélioration payante.
- **Déclenchement de l'achat** : le client envoie `DemandeAchatCosmetique`. Le serveur vérifie que le joueur ne possède pas déjà l'objet, puis appelle `PromptProductPurchase`.

## 7. Vestiaire (les cosmétiques possédés)

- **Mise en page** : un `ViewportFrame` à gauche (40 % de la largeur) et une grille de 4 colonnes de cartes de 96 px à droite.
- **Équiper** : un tap suffit. Le serveur vérifie la possession, puis réplique l'apparence.
- **États** :
  - possédé : Crème ;
  - à gagner à la Galerie : cadenas Violet horde, avec la progression (« 87/100 Rapides ») ;
  - en Boutique : prix en Robux. Un tap ouvre la fiche de la Boutique.
- **Variantes de la Galerie** : elles s'exposent dans l'Alcôve. *Interprétation du canon, à valider.*

## 8. Écrans de récompense

| Moment | Format | Durée | Action |
|---|---|---|---|
| Jour franchi | Bandeau « Jour 6 franchi ! +12 » en cyan | 2,5 s | aucune |
| Colosse vaincu | Bandeau et confettis en cubes (`Rate` 20) | 3 s | aucune |
| Arrivée au Labo | Carte « La Foreuse a creusé 64 gemmes » | jusqu'au tap | « Récupérer » |
| Recherche lancée | Travelling de caméra vers l'Alcôve, la machine apparaît avec l'effet élastique | 2 s | « Passer » |
| Palier de la Galerie | Petit message avec la nouvelle variante | 3 s | « Équiper » |
| Achat Robux | Carte « Merci ! » avec aperçu | jusqu'au tap | « Équiper » |

**Fin de run**, en trois temps :

1. **0 à 1 s** : la Maison éclate en cubes, sans écran noir.
2. **1 à 3,5 s** : panneau « La Maison a tenu 12 jours ! » (jamais « Défaite »), avec un badge Or « Nouveau record ! » le cas échéant.
   - Les gemmes sont détaillées par source : Mine, Dorés, Jours franchis, Défi du Jour.
   - Chaque compteur défile en 1,2 s.
   - La mention « Déjà sauvegardé » rassure le joueur.
3. **Ensuite** : les 3 barres de la Galerie les plus proches d'un palier, et un seul bouton « Laboratoire » de 320 × 80 px. Le retour est automatique au bout de 20 s.

**Données** : le serveur envoie le récapitulatif par le `RemoteEvent` `RecapRun`.

**Arrivée au Laboratoire** : les cartes passent dans une file stricte, Foreuse puis Défi du Jour.

## 9. Code serveur

```lua
-- ServerScriptService/Etabli.server.lua (place Prairie)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local demande = ReplicatedStorage.Remotes:WaitForChild("AcheterAmelioration") :: RemoteFunction
local etabli = workspace:WaitForChild("Etabli") :: Model

local PORTEE_MAX, DELAI_MIN, CROISSANCE = 14, 0.25, 1.45
local CATALOGUE = { -- prix provisoires, à valider par l'économie
	Degats = { base = 20, max = 10 }, Cadence = { base = 20, max = 10 },
	Portee = { base = 15, max = 8 }, Butin = { base = 25, max = 8 },
	BallesExplosives = { base = 60, max = 5 },
	Solidite = { base = 30, max = 10, equipe = true },
	Reparation = { base = 15, max = 10, equipe = true },
	Regeneration = { base = 35, max = 8, equipe = true },
}
local dernierAchat: { [Player]: number } = {}

demande.OnServerInvoke = function(joueur: Player, id: unknown)
	if typeof(id) ~= "string" or not CATALOGUE[id] then
		return false, "inconnu"
	end
	local maintenant = os.clock()
	if maintenant - (dernierAchat[joueur] or 0) < DELAI_MIN then
		return false, "trop_vite"
	end
	local perso = joueur.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not racine or (racine.Position - etabli:GetPivot().Position).Magnitude > PORTEE_MAX then
		return false, "trop_loin"
	end
	local fiche = CATALOGUE[id]
	local porteur: Instance = if fiche.equipe then workspace else joueur
	local niveau = porteur:GetAttribute("Niv_" .. id) or 0
	if niveau >= fiche.max then
		return false, "max"
	end
	local cout = math.floor(fiche.base * CROISSANCE ^ niveau + 0.5)
	local solde = joueur:GetAttribute("Pieces") or 0
	if solde < cout then
		return false, "pieces"
	end
	dernierAchat[joueur] = maintenant
	joueur:SetAttribute("Pieces", solde - cout)
	porteur:SetAttribute("Niv_" .. id, niveau + 1) -- lu par l'UI, le Blaster et la Maison
	return true, niveau + 1
end

Players.PlayerRemoving:Connect(function(joueur)
	dernierAchat[joueur] = nil
end)
```

```lua
-- ServerScriptService/Boutique.server.lua (place Laboratoire)
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local store = DataStoreService:GetDataStore("Cosmetiques_v1")
local demandeAchat = ReplicatedStorage.Remotes:WaitForChild("DemandeAchatCosmetique") :: RemoteEvent
local OFFRES = { Tenue_Apicultrice = 1111, Blaster_Arcade = 2222 } -- ProductId réels à saisir
local PRODUITS = {}
for offre, produitId in OFFRES do
	PRODUITS[produitId] = offre
end

demandeAchat.OnServerEvent:Connect(function(joueur: Player, offre: unknown)
	if typeof(offre) ~= "string" or not OFFRES[offre] then return end
	if joueur:GetAttribute("Possede_" .. offre) then return end
	MarketplaceService:PromptProductPurchase(joueur, OFFRES[offre])
end)

MarketplaceService.ProcessReceipt = function(recu)
	local offre = PRODUITS[recu.ProductId]
	if not offre then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok = pcall(function()
		store:UpdateAsync(tostring(recu.PlayerId), function(donnees)
			donnees = donnees or { possede = {}, recus = {} }
			if not donnees.recus[recu.PurchaseId] then -- idempotence
				donnees.recus[recu.PurchaseId] = true
				donnees.possede[offre] = true
			end
			return donnees
		end)
	end)
	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local joueur = Players:GetPlayerByUserId(recu.PlayerId)
	if joueur then
		joueur:SetAttribute("Possede_" .. offre, true)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

## 10. Réglages communs

- **`ScreenGui`** : `IgnoreGuiInset` true, `ResetOnSpawn` false, `ScreenInsets` `DeviceSafeInsets`.
- **Échelle** : `UIScale.Scale = math.clamp(ViewportSize.Y / 390, 1, 1.6)`.
- **Texte** : police `Enum.Font.FredokaOne`, taille de 16 px au minimum.
- **Boutons** : 60 px au minimum, 72 px sur les HUD.
- **Animations** : `TweenInfo.new(0.15, Enum.EasingStyle.Back)`.
- **Couleurs** : lues uniquement dans `ReplicatedStorage.Charte`.

### 🔷 Iconographe — Romane Cassel
## 1. Style commun « Pixel-bloc 16 »

- **Grille de 16 × 16 pixels.** Le pictogramme tient dans 14 × 14, sans anti-crénelage ni dégradé.
- **Contour :** 1 pixel Encre #1E1B2E, coins en escalier. Jamais de noir ni de blanc purs.
- **Volume :** la lumière vient d'en haut à gauche (base + 20 % de Crème) et l'ombre est en bas à droite (base × 0,8). Au plus 2 couleurs de la palette, plus l'Encre.
- **Code couleur du canon :** or = Pièces, cyan = Gemmes, violet = Zbires, orange et crème = à nous, Alerte #FF2E63 = danger. L'or et le cyan sont réservés aux icônes qui parlent d'argent.
- **Aucun texte ni chiffre dans l'image :** les quantités et les prix s'affichent dans des `TextLabel`.
- **La silhouette d'abord :** une icône doit rester reconnaissable remplie d'Encre unie. Deux icônes d'un même écran n'ont jamais la même silhouette.
- **La pastille indique la catégorie**, ce qui aide les joueurs daltoniens :

| Pastille | Forme et couleur | Catégorie |
|---|---|---|
| `PastilleAction` | Cercle Crème bordé d'Encre | Boutons |
| `PastilleEtabli` | Carré Toit orange | Améliorations |
| `PastilleRecherche` | Hexagone Nuit labo, liseré cyan | Recherches |
| `PastilleDefense` | Octogone Terre battue | Défenses |
| `PastilleAlerte` | Losange Alerte | Danger |
| `PastillePing` | Bulle Crème à pointe basse | Pings |

Le `BadgeEquipe` (2 têtes dans le coin bas gauche, à partir de 64 px) signale Solidité, Réparation et Régénération, qui profitent à toute l'équipe.

## 2. Tailles de déclinaison

Chaque taille est un **multiple de 16**, pour qu'un pixel de grille couvre un nombre entier de pixels écran. Réglage : `ResampleMode = Enum.ResamplerMode.Pixelated`.

| Taille | Usage |
|---|---|
| **32 px** | Compteurs du HUD, gains flottants, prix. **C'est la taille de validation** |
| 48 px | Pictogramme d'un bouton de 64 px, pings en monde |
| 64 px | Boutons secondaires (le canon impose 60 px au minimum), cartes de l'Établi |
| 96 px | Boutons Réparer, Défenses et Roue des Pings, nœuds de l'Arbre des Recherches |
| 128 px | Déblocages, fin de run |
| 256 px | Portraits de la Galerie des Zbires |

- **Bouton :** pour une pastille de N px, le pictogramme centré mesure N − 16 px.
- **Ping en monde :** `BillboardGui` de `Size` 48 × 48 (offset), `AlwaysOnTop` = true, `LightInfluence` = 0, `MaxDistance` = 150.
- **Livraison :**
  - `ico_atlas_a.png` : 1024 × 1024, 8 × 8 cellules de 128 px ;
  - `ico_atlas_b.png` : 4 × 4 cellules de 256 px, pour le bestiaire.

  Les deux atlas sont agrandis au plus proche voisin et occupent environ 8 Mo de mémoire au total.

## 3. Icônes de l'Atlas A (ordre des cellules)

### Ligne 0 · Monnaies et HUD
- `Piece` : disque or de 12 px avec un cube en relief et un reflet.
- `Gemme` : diamant cyan de 10 × 12, 3 facettes, éclat crème.
- `Jour` : soleil orange à 8 rayons crème.
- `Record` : drapeau orange sur un mât Ardoise, pour « Record : Jour X ».
- `Maison` : façade avec toit orange en triangle et murs crème, pour la barre de PV.
- `MaisonFissuree` : la même façade fissurée en zigzag, sous 33 % de PV.
- `Repit` : sablier crème au sable Terre battue, pour le chrono de 15 s.
- `Horde` : tête de Marcheur violette, pour les Zbires restants.

### Ligne 1 · Survivant et défenses
- `Blaster` : blaster blocky de profil, réservoir orange. Il clignote quand le tir auto trouve une cible à moins de 40 studs.
- `SacADos` : sac orange à 2 bretelles, ouvre le menu des défenses.
- `Reparer` : marteau à 45°, tête Ardoise.
- `Etourdi` : 3 étoiles crème en arc, affichées 2 s au-dessus du Survivant.
- `Muret` : 3 rangées de briques crème décalées.
- `MiniTourelle` : cube-canon orange sur un trépied Ardoise.
- `TapisCollant` : tapis rayé crème et orange, 3 fils qui s'étirent.
- `PoseInterdite` : cercle barré Alerte, quand l'emplacement est refusé ou que 3 défenses sont déjà posées.

### Ligne 2 · Établi (pictogrammes crème et Ardoise sur `PastilleEtabli`)
- `Degats` : éclat « pow » à 8 pointes.
- `Cadence` : 3 balles en file avec des traits de vitesse.
- `Portee` : 2 arcs concentriques dépassés par une flèche.
- `Solidite` : bouclier carré à 4 rivets, avec `BadgeEquipe`.
- `Reparation` : le marteau de `Reparer` posé sur une brique, avec `BadgeEquipe`.
- `Regeneration` : croix « + » et 2 bulles qui montent, avec `BadgeEquipe`.
- `Butin` : pyramide de 3 Pièces (exception : en or).
- `BallesExplosives` : balle ronde avec mèche et étincelle orange.

### Ligne 3 · Laboratoire
- `TourelleToit` : toit orange, canon qui sort du faîte.
- `BallesPerforantes` : balle pointue qui traverse 2 cubes violets.
- `ViseeCritique` : réticule crème avec un éclat orange au centre. Sert aussi pour le coup critique flottant.
- `Foreuse` : mèche hélicoïdale Ardoise, Gemme à la pointe. Sert aussi pour la collecte hors connexion.
- `ArbreRecherches` : fiole ronde au liquide cyan.
- `Capsule` : capsule ovale orange, hublot Nuit labo.
- `Galerie` : figurine violette sur un socle.
- `Boutique` : t-shirt crème à col orange, pour les cosmétiques en Robux.

### Ligne 4 · Boutons et rendez-vous
- `Etabli` : plateau sur 2 pieds, engrenage orange.
- `RouePings` : cercle en 4 quartiers, dont un orange.
- `Parametres` : 3 curseurs décalés.
- `Fermer` : X Encre épais.
- `Retour` : flèche vers la gauche.
- `Son` et `SonCoupe` : haut-parleur à 2 ondes, puis la même icône barrée d'Alerte.
- `DefiDuJour` : calendrier crème à 2 anneaux, soleil orange.

### Ligne 5 · Pings et marqueurs
- `PingColosse` (« Colosse ! ») : tête cornue violette, contour Alerte.
- `PingRepare` (« Répare ! ») : façade de la Maison, marteau dans le coin.
- `PingIci` (« Ici ! ») : épingle orange, pointe en bas.
- `PingMerci` (« Merci ! ») : cœur orange.
- `HorsEcranZbire` : chevron violet au bord de l'écran.
- `HorsEcranColosse` : chevron Alerte avec une mini-tête cornue.
- `Bloque` : casque Ardoise et étincelle, pour un coup non critique sur un Casqué.
- `ZbireSemaine` : calendrier crème, tête violette au centre.

**Ligne 6 :** les 6 pastilles, puis `BadgeEquipe`. **Ligne 7 :** réserve pour les événements et les cosmétiques.

## 4. Bestiaire de l'Atlas B

Chaque portrait montre la tête de face, sur un corps violet, avec **un seul trait distinctif** :
- Marcheur : cube, yeux ronds.
- Rapide : traits de vitesse.
- Costaud : 4 piquants Ardoise.
- Doré : corps or bordé de violet, Gemme dans le coin.
- Sauteur : ressort.
- Gluant : goutte à bulles.
- Mini-Gluant : goutte de 8 × 8.
- Volant : 2 ailes carrées.
- Casqué : casque Ardoise.
- Colosse : tête cornue, contour Alerte.

Tailles d'usage : 256 px dans la Galerie, 64 px pour les modificateurs du Défi du Jour.

## 5. Module `ReplicatedStorage.Icones`

Les clés de code n'ont pas d'accents. Les libellés affichés reprennent les noms du canon.

```lua
--!strict
-- Affichage seulement : un bouton n'envoie qu'une demande, le serveur décide.
local TweenService = game:GetService("TweenService")

type Atlas = { id: string, cellule: number, colonnes: number }
type Ref = { atlas: Atlas, index: number }

local ATLAS: { [string]: Atlas } = {
	A = { id = "rbxassetid://0", cellule = 128, colonnes = 8 }, -- ID à reporter après import
	B = { id = "rbxassetid://0", cellule = 256, colonnes = 4 },
}

local ORDRE: { [string]: { string } } = {
	A = {
		"Piece", "Gemme", "Jour", "Record", "Maison", "MaisonFissuree", "Repit", "Horde",
		"Blaster", "SacADos", "Reparer", "Etourdi", "Muret", "MiniTourelle", "TapisCollant", "PoseInterdite",
		"Degats", "Cadence", "Portee", "Solidite", "Reparation", "Regeneration", "Butin", "BallesExplosives",
		"TourelleToit", "BallesPerforantes", "ViseeCritique", "Foreuse", "ArbreRecherches", "Capsule", "Galerie", "Boutique",
		"Etabli", "RouePings", "Parametres", "Fermer", "Retour", "Son", "SonCoupe", "DefiDuJour",
		"PingColosse", "PingRepare", "PingIci", "PingMerci", "HorsEcranZbire", "HorsEcranColosse", "Bloque", "ZbireSemaine",
		"PastilleAction", "PastilleEtabli", "PastilleRecherche", "PastilleDefense", "PastilleAlerte", "PastillePing", "BadgeEquipe",
	},
	B = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" },
}

local INDEX: { [string]: Ref } = {}
for nom, cles in ORDRE do
	for i, cle in cles do
		assert(INDEX[cle] == nil, `Icône en double : {cle}`)
		INDEX[cle] = { atlas = ATLAS[nom], index = i - 1 }
	end
end

-- Effet élastique : aller-retour de 0,075 s, soit 0,15 s
local REBOND = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)

local Icones = {}

function Icones.appliquer(image: ImageLabel | ImageButton, cle: string)
	local ref = INDEX[cle]
	assert(ref, `Icône inconnue : {cle}`)
	local c = ref.atlas.cellule
	image.Image = ref.atlas.id
	image.ImageRectSize = Vector2.new(c, c)
	image.ImageRectOffset = Vector2.new(ref.index % ref.atlas.colonnes * c, ref.index // ref.atlas.colonnes * c)
	image.ResampleMode = Enum.ResamplerMode.Pixelated
	image.BackgroundTransparency = 1
end

function Icones.creer(cle: string, taille: number, parent: Instance?): ImageLabel
	assert(taille >= 32 and taille % 16 == 0, "Icône : multiple de 16, 32 px minimum")
	local image = Instance.new("ImageLabel")
	image.Name = "Ico_" .. cle
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromOffset(taille, taille)
	Icones.appliquer(image, cle)
	image.Parent = parent
	return image
end

function Icones.rebond(objet: GuiObject)
	local base = objet:GetAttribute("TailleBase")
	if typeof(base) ~= "UDim2" then
		base = objet.Size
		objet:SetAttribute("TailleBase", base)
	end
	local b = base :: UDim2
	objet.Size = b
	TweenService:Create(objet, REBOND, {
		Size = UDim2.new(b.X.Scale * 1.2, b.X.Offset * 1.2, b.Y.Scale * 0.8, b.Y.Offset * 0.8),
	}):Play()
end

function Icones.creerBouton(cle: string, pastille: string, taille: number, parent: Instance?): ImageButton
	assert(taille >= 64 and taille % 16 == 0, "Bouton mobile : multiple de 16, 64 px minimum")
	local bouton = Instance.new("ImageButton")
	bouton.Name = "Btn_" .. cle
	bouton.AnchorPoint = Vector2.new(0.5, 0.5)
	bouton.Size = UDim2.fromOffset(taille, taille)
	bouton.AutoButtonColor = false
	Icones.appliquer(bouton, pastille)
	local picto = Icones.creer(cle, taille - 16, bouton)
	local ratio = (taille - 16) / taille
	picto.Size = UDim2.fromScale(ratio, ratio) -- suit l'écrasement de la pastille
	bouton.Activated:Connect(function()
		Icones.rebond(bouton)
	end)
	bouton.Parent = parent
	return bouton
end

return Icones
```

Exemple : `Icones.creerBouton("Reparer", "PastilleAction", 96, hud)`.

## 6. Validation à 32 px

1. **Ombre chinoise :** on montre la silhouette Encre à 5 joueurs de 9 à 13 ans, qui doivent la nommer sans aide. En dessous de 4 bonnes réponses sur 5, on redessine l'icône.
2. **Daltonisme :** on vérifie en niveaux de gris et avec un filtre de deutéranopie. La Pièce et la Gemme doivent se distinguer par leur forme.
3. **Fonds :** on teste sur Prairie #6CC24A, Terre battue et Nuit labo, puis avec `ClockTime` à 17,5.
4. **Appareil :** Android d'entrée de gamme de 5,5 pouces, tenu à bout de bras.
5. **Paires à risque**, comparées côte à côte : `Degats` et `BallesExplosives`, `Reparer` et `Reparation`, `DefiDuJour` et `ZbireSemaine`.

### 📱 Expert UX mobile — Yanis Abadi
## 1. Cadre mobile

- **Orientation :** paysage imposé dans les deux places, `StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor` (retournement à 180° permis, portrait jamais).
- **Viewport de référence :** 800 × 360 pt (Android d'entrée de gamme 20:9), vérifié aussi à 667 × 375 (le plus étroit).
- **Zones sûres :** tout `ScreenGui` interactif a `ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets` et `ResetOnSpawn = false`.
- **Échelle :** `UIScale` = clamp(min(viewport) / 390 ; 1 ; 1,4). Jamais sous 1 : les 60 px du canon restent un plancher.
- **Saut :** désactivé sur la Prairie (`StarterPlayer.CharacterUseJumpPower = true`, `CharacterJumpPower = 0`), ce qui masque le bouton de saut Roblox et libère le coin du pouce droit. Conservé au Laboratoire. *Ajout au canon, soumis à Victor Lanoue.*

## 2. Checklist mobile

| # | Règle | Valeur |
|---|---|---|
| 1 | Taille visuelle d'un bouton | 64 px (canon : 60 minimum), action principale 96 px |
| 2 | Zone de touch | visuel + 6 px par côté (76 et 108 px) |
| 3 | Écart entre visuels | ≥ 12 px ; zones de touch jointives, jamais superposées |
| 4 | Marge aux bords | 24 px dans la zone sûre |
| 5 | Texte | ≥ 16 px, chiffres clés 24 px, `UIStroke` Encre 2 px |
| 6 | Haut de l'écran | lecture seule, sauf Paramètres |
| 7 | Zone du joystick | 40 % gauche × 60 % bas : aucun bouton |
| 8 | Retour d'appui | écrasement × 0,8, retour élastique en 0,15 s, bip 8-bit < 80 ms |
| 9 | Action de combat | 1 tap, 2 au maximum |
| 10 | Information | jamais par la couleur seule : icône + couleur |

## 3. Carte des pouces : HUD de la Prairie

Pouce gauche : joystick dynamique Roblox, rien d'autre. Pouce droit : la **Grappe**, un arc d'actions autour du coin bas-droit. Haut : informations.

| Élément | Ancrage (800 × 360) | Taille | Interaction |
|---|---|---|---|
| PV de la Maison, « Jour X », minuteur horde / Répit | `AnchorPoint (0.5, 0)`, `UDim2.new(0.5, 0, 0, 8)` | 280 × 40 | aucune |
| Pièces (Or) puis Gemmes (cyan) | `AnchorPoint (1, 0)`, `UDim2.new(1, -84, 0, 8)` | 2 × 110 × 40 | aucune |
| Paramètres | `UDim2.new(1, -12, 0, 8)` | 60 × 60 | tap |
| **Réparer** (principal) | Grappe, centre à 72 px du coin | 96 | maintenir |
| Muret, Mini-Tourelle, Tapis Collant | arc de 150 px à 180°, 210°, 240° | 64 | tap, compteur « 2/3 » |
| Roue des Pings | arc à 270° | 64 | tap, ou maintenir + glisser |
| Flèches hors écran (Colosse, Maison, cible) | bord de la zone sûre | 40 | aucune (`Active = false`) |

Réparer est grisé au-delà de 14 studs du centre de la Maison, avec une flèche vers elle. Les Pièces se ramassent au contact. Paramètres propose « Taille des boutons : 100 / 115 / 130 % ».

## 4. Gestes

| Geste | Usage |
|---|---|
| Tap | combat : à `InputBegan` ; menus : `Activated`, annulable en glissant hors du bouton |
| Maintenir | Réparer (le serveur répare par tranches de 0,5 s), Roue des Pings |
| Glisser | joystick, Roue des Pings, Arbre des Recherches ; jamais depuis un bord |
| Tap sur un Zbire | verrou de cible 3 s, tolérance de 48 px |
| Interdits | pincer, double tap, deux doigts, glisser la caméra (`Scriptable`), secouer |

**Pose d'une défense en 2 taps, sans glisser-déposer.** 1er tap : un fantôme translucide apparaît 6 studs devant le Survivant, calé sur la grille de 1 stud, crème s'il est valide, rose-rouge sinon. Le Muret s'oriente seul, tangent à la Maison, et le fantôme suit le Survivant. 2e tap sur le même bouton, devenu une coche : `DemandePose`. Annulé après 4 s d'inaction.

**Roue des Pings sans visée.** Le tap ouvre 4 secteurs de 84 px, orientés vers le centre de l'écran. « Ici ! » marque la position du Survivant, « Répare ! » la Maison, « Colosse ! » le Colosse ; « Merci ! » s'affiche au-dessus de la tête. Serveur : 1 ping toutes les 2 s par joueur.

## 5. Adaptation des écrans

- **Laboratoire :** `ProximityPrompt` en `Style = Custom` (bouton 72 px, `HoldDuration = 0`, `MaxActivationDistance = 10`), `ProximityPromptService.MaxPromptsVisible = 1`, 8 studs minimum entre deux prompts.
- **Quai des Capsules :** une fois assis, « Départ dans 15 s » et bouton « Descendre » 200 × 64 en bas au centre.
- **Arbre des Recherches :** plein écran ; fermeture en haut à droite (60 px) et « Retour » 200 × 64 en bas à gauche. Cartes 150 × 200 dans un `ScrollingFrame` horizontal (`ScrollingDirection = X`). Dépense de Gemmes en 2 taps : « Confirmer ? » et le prix pendant 3 s.
- **Galerie des Zbires :** tap sur une figurine = fiche, compteur « 37/100 » vers la variante suivante.
- **Établi :** panneau droit de 52 % qui remplace la Grappe, joystick actif. 8 tuiles de 88 × 88 (4 × 2) ; 1 tap = 1 achat en Pièces, anti double tap 0,3 s. Fermeture automatique à 12 studs.
- **Étourdi (2 s) :** boutons grisés avec décompte circulaire ; la Roue des Pings reste active.
- **Colosse :** bandeau « Colosse ! » 1,5 s et flèche au bord. Aucune fenêtre modale en combat.
- **Fin de run :** Gemmes gagnées, « Record : Jour X », « Retour au Laboratoire » 280 × 72 en bas au centre. Taps ignorés 0,8 s : les joueurs martèlent encore la Grappe quand la Maison tombe.
- **Défi du Jour, Zbire de la Semaine :** panneau au Laboratoire, jamais de fenêtre à la connexion.

## 6. Caméra et tir automatique

Avec le décalage (0, 45, 28) et `FieldOfView` 50 (vertical), la caméra est à 53 studs, inclinée à 58°. En 16:9, on voit environ 41 studs devant le Survivant, 22 derrière et 44 de chaque côté (55 en 20:9). Le tir automatique porte à 40 studs : un Zbire en bas de l'écran ou sous la Grappe peut être visé sans être vu.

Règle : le client propose d'abord le Zbire **visible hors de la Grappe** le plus proche ; le serveur revalide existence, distance ≤ 40 et cadence. La cible porte un anneau crème (`BillboardGui` 48 px, `AlwaysOnTop`), ou une flèche au bord si elle est hors écran.

## 7. Code Luau

```lua
-- StarterPlayerScripts/DispositionTactile (ModuleScript) : la Grappe du pouce droit
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charte = require(ReplicatedStorage.Charte) -- noms de champs à aligner sur la Charte

local TAILLE_MIN, PRINCIPAL, SECONDAIRE = 60, 96, 64
local MARGE_TOUCH, RAYON, COTE = 6, 150, 270
local EMPLACEMENTS = { Muret = 180, MiniTourelle = 210, TapisCollant = 240, Ping = 270 }
local camera = workspace.CurrentCamera

local function creerBouton(parent: GuiObject, nom: string, taille: number, centre: Vector2, image: string)
	assert(taille >= TAILLE_MIN, "Bouton sous 60 px : " .. nom)
	local zone = Instance.new("ImageButton") -- zone de touch invisible, plus large que le visuel
	zone.Name = nom
	zone.AnchorPoint = Vector2.new(0.5, 0.5)
	zone.Position = UDim2.fromOffset(centre.X, centre.Y)
	zone.Size = UDim2.fromOffset(taille + 2 * MARGE_TOUCH, taille + 2 * MARGE_TOUCH)
	zone.BackgroundTransparency, zone.ImageTransparency, zone.AutoButtonColor = 1, 1, false
	zone.Parent = parent

	local visuel = Instance.new("ImageLabel")
	visuel.AnchorPoint = Vector2.new(0.5, 0.5)
	visuel.Position = UDim2.fromScale(0.5, 0.5)
	visuel.Size = UDim2.fromOffset(taille, taille)
	visuel.BackgroundColor3, visuel.Image = Charte.Creme, image
	visuel.Parent = zone
	Instance.new("UICorner", visuel).CornerRadius = UDim.new(0, 12)
	local contour = Instance.new("UIStroke")
	contour.Thickness, contour.Color = 3, Charte.Encre
	contour.Parent = visuel
	return zone
end

local DispositionTactile = {}

function DispositionTactile.construire(images: { [string]: string }): Frame
	local gui = Instance.new("ScreenGui")
	gui.Name = "HUDTactile"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local grappe = Instance.new("Frame")
	grappe.Name = "Grappe"
	grappe.AnchorPoint = Vector2.new(1, 1)
	grappe.Position = UDim2.new(1, -24, 1, -24)
	grappe.Size = UDim2.fromOffset(COTE, COTE)
	grappe.BackgroundTransparency = 1
	grappe.Parent = gui
	local echelle = Instance.new("UIScale")
	echelle.Parent = grappe

	local centre = Vector2.new(COTE - PRINCIPAL / 2, COTE - PRINCIPAL / 2)
	creerBouton(grappe, "Reparer", PRINCIPAL, centre, images.Reparer)
	for nom, angle in EMPLACEMENTS do
		local a = math.rad(angle)
		creerBouton(grappe, nom, SECONDAIRE, centre + Vector2.new(math.cos(a), math.sin(a)) * RAYON, images[nom])
	end

	local function ajuster()
		local vp = camera.ViewportSize
		echelle.Scale = math.clamp(math.min(vp.X, vp.Y) / 390, 1, 1.4) -- jamais sous 1
	end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(ajuster)
	ajuster()
	return grappe
end

return DispositionTactile
```

```lua
-- LocalScript AutoTir (extrait) : le client propose une cible, le serveur décide
local camera = workspace.CurrentCamera
local PORTEE = 40

local function sousLaGrappe(ecran: Vector3, grappe: GuiObject): boolean
	local vp = camera.ViewportSize
	local zone = grappe.AbsoluteSize + Vector2.new(40, 40) -- marge + zone sûre
	return ecran.X > vp.X - zone.X and ecran.Y > vp.Y - zone.Y
end

local function choisirCible(racine: BasePart, grappe: GuiObject, verrou: Model?): Model?
	if verrou and verrou.Parent and (verrou:GetPivot().Position - racine.Position).Magnitude <= PORTEE then
		return verrou
	end
	local meilleure, meilleurScore = nil, math.huge
	for _, zbire in workspace.Zbires:GetChildren() do
		local position = zbire:GetPivot().Position
		local distance = (position - racine.Position).Magnitude
		if distance <= PORTEE then
			local ecran, visible = camera:WorldToViewportPoint(position)
			local score = if visible and not sousLaGrappe(ecran, grappe) then distance else distance + 1000
			if score < meilleurScore then
				meilleure, meilleurScore = zbire, score
			end
		end
	end
	return meilleure -- puis DemandeTir:FireServer(meilleure:GetAttribute("Id")) à la cadence du Blaster
end
```

La Grappe s'active quand `UserInputService.LastInputTypeChanged` renvoie `Touch` et se masque au clavier ou à la souris (PC tactiles).

## 8. Pièges à éviter

- **Bouton sous la barre Roblox ou dans l'encoche :** `CoreUISafeInsets`, jamais `IgnoreGuiInset` sur un bouton.
- **Bouton dans la zone du joystick :** le Survivant se fige dès qu'on le frôle.
- **Écran qui surgit sous le pouce :** verrou de 0,8 s, bouton hors de la Grappe.
- **Glisser-déposer des défenses :** conflit avec le joystick, doigt qui masque la pose.
- **`TextScaled` sans borne :** textes de 6 px sur iPhone SE ; `UITextSizeConstraint` (`MinTextSize` 16, `MaxTextSize` 32).
- **Info-bulles au survol (`MouseEnter`) :** inexistantes au doigt ; afficher l'info ou appui long de 0,4 s.
- **Gestes depuis les bords :** retour Android, accueil iOS ; rien à moins de 24 px.
- **`TextBox` :** le clavier couvre la moitié de l'écran ; aucun champ de saisie.
- **HUD recalculé à chaque image :** compteurs mis à jour sur changement, 80 `GuiObject` visibles au maximum, chiffres de dégâts réservés au joueur (pool de 20 `BillboardGui`).
- **Consignes par le chat :** beaucoup de 9-12 ans n'y ont pas accès ; Doc Boulon montre le geste avec une main animée.

## 9. Tests multi-écrans

| Appareil | Viewport paysage | Points critiques |
|---|---|---|
| Android 3 Go (réel, référence) | ≈ 800 × 360 | 30 FPS, 6 joueurs, 60 Zbires, < 800 Mo |
| iPhone SE | 667 × 375 | Grappe et compteurs sans chevauchement |
| iPhone à encoche | 844 × 390 | zones sûres dans les 2 sens de rotation |
| Android 20:9 grand format | 915 × 412 | échelle 1,06, flèches aux bords |
| iPad 10,2 pouces | 1080 × 810 | échelle 1,4, rien d'étiré |
| PC 1920 × 1080 | — | Grappe masquée, raccourcis clavier |

**Protocole :** émulateur de Studio (appareils personnalisés 800 × 360 et 915 × 412), 20 taps par bouton en marchant (19 réussis minimum), chaque défense posée, chaque ping envoyé, une run de 12 min sans tap involontaire. Puis 5 testeurs de 9 à 13 ans sur téléphone, en session encadrée avec accord parental : moins de 5 % de taps manqués.

## ✨ Lumière, VFX & Audio

### 💡 Lighting artist — Constance Rivoal (révisé)
## 1. Principes

- **Prairie : `ShadowMap`**, seul le soleil projette une ombre. **Laboratoire : `ShadowMap`** aussi, avec `Shadows = false` partout (§6). `Technology` se règle dans Studio, jamais par script.
- **Aucune information de jeu ne passe par une ombre ou un halo.** En qualité basse, Roblox coupe les ombres et le Bloom : la lisibilité repose sur la Charte et le contraste.
- **12 sources par place, tous types confondus.** *Écart assumé : le canon ne plafonne que les `PointLight`.* Aucun script ne crée de lumière en cours de partie.

## 2. Un seul écrivain : `AmbianceClient`

| Script (agent) | Rôle sur la Prairie |
|---|---|
| `AmbianceClient` (a36) | Seul à écrire dans `Lighting`, `Atmosphere`, `CCPrairie`, `Bloom` et `workspace.Lumieres`. Publie `Qualite` |
| `MeteoClient` (a18) | Lit `EtatRun.MeteoEtat` et appelle `definirMeteo(etat)` |
| `AmbianceBiomes` (a20) | Lit `EtatRun.EtatPrairie` et appelle `definirBiome(etat)` |
| `CycleCiel` (a19) | Retiré de la Prairie. La nuit express ne revient qu'en variante A/B, en vague 2 |
| VFX (a37) | Emprunte une réserve avec `flash(position, couleur, priorite)` |
| Musique (a40) | Lance l'intro de 8 s de la piste Colosse sur le même changement de `JourColosse` |

- **`ClockTime` 14 fixe, en horde comme au Répit.** Au début du Répit qui précède le Jour du Colosse, le serveur passe `JourColosse` à true : fondu sinusoïdal de 8 s vers 17,5. Au Répit suivant, le même fondu ramène à 14.
- `definirMeteo` et `definirBiome` reçoivent un `Modificateur` (écarts bornés, voir `BORNES`), ou nil pour revenir à la base. `ClockTime` n'en fait jamais partie.
- **0,2 ms au plus au MicroProfiler** (étiquette `AmbianceClient`). Le Heartbeat ne fait que compter les images. Tout le reste tourne à 10 Hz et n'écrit que les valeurs qui changent.
- **`Qualite`**, attribut du `LocalPlayer` lu par a18 et a37, suit la moyenne glissante des FPS sur 3 s. Il passe à `"Legere"` après 2 s sous 27 FPS et revient à `"Normale"` après 10 s au-dessus de 45. En mode léger : Bloom coupé, `Haze` à 0, 1 seule lumière animée, pas de pic de la Mine.

## 3. Prairie

La caméra ne voit jamais le ciel. Régler `GeographicLatitude` pour que `GetSunDirection().Z` soit ≥ 0,3 à 14 h et ≥ 0 à 17,5 h : le soleil vient du côté caméra.

| Propriété | Jour (horde, Répit) | Jour du Colosse |
|---|---|---|
| `ClockTime` / `Brightness` | 14 / 2,5 | 17,5 / 2 |
| `OutdoorAmbient` / `ColorShift_Top` | (150, 140, 165) / Crème | (140, 110, 170) / Toit orange |
| `Atmosphere` Density / Haze / Color | 0,25 / 0,5 / Crème | 0,32 / 1 / Toit orange |
| `CCPrairie` Saturation / TintColor | 0,15 / (255, 250, 240) | 0,2 / (255, 232, 215) |

Valeurs fixes, réglées dans Studio : `Ambient` (108, 101, 115), `ColorShift_Bottom` (83, 86, 118), `EnvironmentDiffuseScale` 0,4, `EnvironmentSpecularScale` 0,15, `ShadowSoftness` 0,15, `Contrast` 0,05, `Bloom` 0,4 / 16 / 1,4. Ni `SunRays`, ni `DepthOfField`, ni `Blur`.

### Les 12 sources de `workspace.Lumieres`

Chaque ancre est une Part `Anchored`, `Transparency` 1, avec `CanCollide`, `CanQuery`, `CanTouch` et `CastShadow` à false. Elle contient une lumière nommée `Lumiere`, `Shadows = false`. **Toute autre lumière sur la Prairie est un bug.**

| Ancre | Origine | Lumière | Brightness | Range |
|---|---|---|---|---|
| `MaisonInterieur` | lampe intérieure a22 | PointLight Crème ; Alerte sous 25 % des PV | 1,2 ; 0,8 sous 60 % ; de 0,6 à 1,6 à 1 Hz sous 25 % | 14 |
| `Porche` | lanterne a20, au-dessus de la porte | PointLight Toit orange lumière | 2 | 16 |
| `Mine` | a36 | PointLight Gemme cyan | 1,5 ; pic à 3 sur 0,3 s par gemme | 12 |
| `Etabli` | une des PointLight Or de a21 | PointLight Or | 1 ; 3 au Répit | 14 |
| `Portail1` à `Portail4` | kit de 4 PointLight a23 | PointLight Violet horde, à 2 studs du sol | 1 ; 3 dans les 3 s avant la horde | 16 |
| `Colosse` | a36, suit `Torse` | PointLight Alerte | 2 | 20 |
| `Reserve1` à `Reserve3` | a36 | PointLight, `Enabled` false | 3 puis 0 en 0,2 s | 10 |

- **Portails :** 8 modèles, `workspace.Portails.P1` à `P8`, à 80 studs du centre et espacés de 45°. Chaque jour, le serveur publie `EtatRun.PortailsActifs` (par exemple `"2,4,6,8"`, dans l'ordre d'ouverture). Les 4 halos vont aux 4 premiers portails de la liste. *L'hypothèse de 4 portails à 82 studs est retirée.*
- **Lumières animées :** 2 à la fois au plus, rafraîchies à 10 Hz. Priorité : Maison en alerte, puis Colosse (3), Balle explosive (2), Doré ou jour franchi (1), Mine (0). Un effet refusé joue sans lumière. Une source attend 0,35 s avant de repartir, ce qui interdit tout clignotement au-dessus de 3 Hz. L'Établi et les portails changent par paliers.
- **Zbires :** ni lumière ni Neon, sauf le Colosse (4 Neon).
- **150 Neon :** Maison 6, Mine 12, portails 32 (4 × 8), Établi 4, défenses 18, Tourelle de toit 2, Colosse 4, lanternes de chemin 16, réserve 56.

### Ombres et disques

- `CastShadow = false` sur **toutes** les Parts des 61 Zbires, Colosse compris. Idem pour les pièces, les gemmes, les cubes d'éclatement, les projectiles et le décor de moins de 2 studs. Dans la Lisière, seul le feuillage projette une ombre.
- **Disque `Sol`**, compté dans les 30 Parts du Volant et du Sauteur : Cylinder de `Size` (0,1 ; D ; D), D valant 80 % de l'emprise, tourné de 90° sur Z. Il est Encre, `SmoothPlastic`, opaque, sans ombre, collision ni requête, à 0,05 stud du sol. Celui du Volant reste sous lui. Celui du Sauteur glisse vers l'attribut serveur `Atterrissage`.

## 4. `AmbianceClient`

```lua
-- ModuleScript StarterPlayer.StarterPlayerScripts.AmbianceClient (place Prairie)
-- Démarré par le LocalScript voisin AmbianceDemarrage : require(script.Parent.AmbianceClient)
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local etat = ReplicatedStorage:WaitForChild("EtatRun")
local dossier = workspace:WaitForChild("Lumieres")
local portails = workspace:WaitForChild("Portails")
local zbires = workspace:WaitForChild("Zbires")
local atmo, cc = Lighting:WaitForChild("Atmosphere"), Lighting:WaitForChild("CCPrairie")
local bloom = Lighting:WaitForChild("Bloom")

export type Modificateur = { Brightness: number?, Density: number?, Haze: number?,
	Saturation: number?, TintColor: Color3?, duree: number? }

local AmbianceClient = {}
local CIBLES = { ClockTime = Lighting, Brightness = Lighting, ColorShift_Top = Lighting,
	OutdoorAmbient = Lighting, Density = atmo, Haze = atmo, Color = atmo, Saturation = cc, TintColor = cc }
local BASES = {
	Jour = { ClockTime = 14, Brightness = 2.5, ColorShift_Top = Charte.Creme,
		OutdoorAmbient = Color3.fromRGB(150, 140, 165), Density = 0.25, Haze = 0.5,
		Color = Charte.Creme, Saturation = 0.15, TintColor = Color3.fromRGB(255, 250, 240) },
	Colosse = { ClockTime = 17.5, Brightness = 2, ColorShift_Top = Charte.ToitOrange,
		OutdoorAmbient = Color3.fromRGB(140, 110, 170), Density = 0.32, Haze = 1,
		Color = Charte.ToitOrange, Saturation = 0.2, TintColor = Color3.fromRGB(255, 232, 215) },
}
-- Cumul météo + biome borné. ClockTime n'est jamais modifiable.
local BORNES = { Brightness = { -0.5, 0 }, Density = { 0, 0.1 }, Haze = { 0, 0.5 }, Saturation = { -0.1, 0.05 } }
local modifs: { [string]: Modificateur } = { meteo = {}, biome = {} }
local leger = false
local courant, debut, cible, t0, duree = {}, {}, {}, 0, -1

local function ecrire(objet: any, prop: string, valeur: any)
	if objet[prop] ~= valeur then
		objet[prop] = valeur
	end
end

local function calculerCible()
	local c = table.clone(BASES[if etat:GetAttribute("JourColosse") then "Colosse" else "Jour"])
	for cle, b in BORNES do
		c[cle] += math.clamp((modifs.meteo[cle] or 0) + (modifs.biome[cle] or 0), b[1], b[2])
	end
	for _, m in modifs do
		if m.TintColor then c.TintColor = c.TintColor:Lerp(m.TintColor, 0.3) end
	end
	return c
end

local function appliquer(v)
	for prop, objet in CIBLES do
		ecrire(objet, prop, if prop == "Haze" and leger then 0 else v[prop])
	end
	ecrire(bloom, "Enabled", not leger)
end

local function lancerFondu(d: number) -- ne raccourcit jamais un fondu en cours
	local restant = if duree > 0 then t0 + duree - os.clock() else 0
	debut, cible, t0, duree = table.clone(courant), calculerCible(), os.clock(), math.max(d, restant)
end

local function lumiere(nom: string): Light
	return dossier:WaitForChild(nom):WaitForChild("Lumiere")
end
local maison, mine, etabli = lumiere("MaisonInterieur"), lumiere("Mine"), lumiere("Etabli")
local ancreColosse = dossier:WaitForChild("Colosse")
local halos, reserves = {}, {}
for i = 1, 4 do halos[i] = dossier:WaitForChild("Portail" .. i) end
for i = 1, 3 do reserves[i] = lumiere("Reserve" .. i) end

local actives, departs = {}, {}

local function arreter(l: Light)
	local a = actives[l]
	actives[l] = nil
	if a.base == 0 then l.Enabled = false else l.Brightness = a.base end
end

local function animer(l: Light, priorite: number, d: number, pic: number, base: number): boolean
	local maintenant = os.clock()
	if maintenant - (departs[l] or 0) < 0.35 then return false end -- jamais plus de 3 Hz
	local n, pire = 0, nil
	for autre, a in actives do
		n += 1
		if not pire or a.priorite < actives[pire].priorite then pire = autre end
	end
	if n >= (if leger then 1 else 2) then
		if actives[pire].priorite >= priorite then return false end
		arreter(pire)
	end
	departs[l] = maintenant
	actives[l] = { priorite = priorite, debut = maintenant, fin = maintenant + d, pic = pic, base = base }
	l.Enabled, l.Brightness = true, pic
	return true
end

local function majMaison()
	local pv = etat:GetAttribute("PVMaison") or 1
	ecrire(maison, "Color", if pv < 0.25 then Charte.Alerte else Charte.Creme)
	if pv < 0.25 then
		if not actives[maison] then animer(maison, 4, math.huge, 1.1, 1.1) end
	else
		if actives[maison] then arreter(maison) end
		ecrire(maison, "Brightness", if pv < 0.6 then 0.8 else 1.2)
	end
end

local function placerHalos()
	local actifs = string.split(etat:GetAttribute("PortailsActifs") or "", ",")
	for i, ancre in halos do
		local modele = portails:FindFirstChild("P" .. (actifs[i] or ""))
		ancre.Lumiere.Enabled = modele ~= nil
		if modele then ancre.CFrame = modele:GetPivot() * CFrame.new(0, 2, 0) end
	end
end

local seaux, iSeau, images, cumul, sous, dessus = table.create(30, 6), 1, 0, 0, 0, 0

local function majQualite()
	seaux[iSeau] = images
	iSeau = iSeau % 30 + 1
	images = 0
	local total = 0
	for _, n in seaux do total += n end
	local fps = total / 3 -- 30 seaux de 0,1 s
	sous = if fps < 27 then sous + 1 else 0
	dessus = if fps > 45 then dessus + 1 else 0
	if (not leger and sous >= 20) or (leger and dessus >= 100) then
		leger = not leger
		Players.LocalPlayer:SetAttribute("Qualite", if leger then "Legere" else "Normale")
		appliquer(courant)
		for l, a in actives do
			if leger and a.priorite < 4 then arreter(l) end
		end
	end
end

local function tick()
	debug.profilebegin("AmbianceClient")
	local maintenant = os.clock()
	majQualite()
	if duree >= 0 then
		local p = if duree == 0 then 1 else math.min((maintenant - t0) / duree, 1)
		local x = (1 - math.cos(math.pi * p)) / 2
		for cle, v in cible do
			courant[cle] = if typeof(v) == "Color3" then debut[cle]:Lerp(v, x) else debut[cle] + (v - debut[cle]) * x
		end
		appliquer(courant)
		if p >= 1 then duree = -1 end
	end
	for l, a in actives do
		if maintenant >= a.fin then
			arreter(l)
		elseif a.priorite == 4 then -- Maison : pulsation douce à 1 Hz
			ecrire(l, "Brightness", a.base + 0.5 * math.sin((maintenant - a.debut) * 2 * math.pi))
		else -- flash : descente linéaire du pic vers la base
			ecrire(l, "Brightness", a.pic + (a.base - a.pic) * (maintenant - a.debut) / (a.fin - a.debut))
		end
	end
	local repit = etat:GetAttribute("Phase") == "Repit"
	local annonce = repit and (etat:GetAttribute("FinPhase") or 0) - workspace:GetServerTimeNow() <= 3
	ecrire(etabli, "Brightness", if repit then 3 else 1)
	for _, ancre in halos do ecrire(ancre.Lumiere, "Brightness", if annonce then 3 else 1) end
	local colosse = zbires:FindFirstChild("Colosse")
	local torse = colosse and colosse:FindFirstChild("Torse")
	ecrire(ancreColosse.Lumiere, "Enabled", torse ~= nil)
	if torse then ecrire(ancreColosse, "CFrame", torse.CFrame) end
	debug.profileend()
end

local function modifier(cle: string, m: Modificateur?)
	modifs[cle] = m or {}
	lancerFondu(if m and m.duree then m.duree else 4)
end
function AmbianceClient.definirMeteo(m: Modificateur?) modifier("meteo", m) end
function AmbianceClient.definirBiome(m: Modificateur?) modifier("biome", m) end

-- priorite : 3 Colosse, 2 Balle explosive, 1 Doré ou jour franchi. false : pas de lumière.
function AmbianceClient.flash(position: Vector3, couleur: Color3, priorite: number): boolean
	for _, l in reserves do
		if not actives[l] and animer(l, priorite, 0.2, 3, 0) then
			l.Color = couleur
			l.Parent.CFrame = CFrame.new(position)
			return true
		end
	end
	return false
end

etat:GetAttributeChangedSignal("JourColosse"):Connect(function() lancerFondu(8) end) -- intro a40 sur le même signal
etat:GetAttributeChangedSignal("PVMaison"):Connect(majMaison)
etat:GetAttributeChangedSignal("PortailsActifs"):Connect(placerHalos)
etat:GetAttributeChangedSignal("GemmesMine"):Connect(function()
	if not leger then animer(mine, 0, 0.3, 3, 1.5) end
end)
RunService.Heartbeat:Connect(function(dt)
	images += 1
	cumul += dt
	if cumul >= 0.1 then
		cumul = math.min(cumul - 0.1, 0.1)
		tick()
	end
end)

courant = calculerCible()
appliquer(courant)
majMaison()
placerHalos()
Players.LocalPlayer:SetAttribute("Qualite", "Normale")
return AmbianceClient
```

## 5. Tests de la Prairie

- **MicroProfiler** (Ctrl+F6) sur l'Android 3 Go : `AmbianceClient` à 0,2 ms au plus, fondu du Colosse compris. Au moins 30 FPS avec 6 joueurs, 60 Zbires et le Colosse, aux niveaux graphiques 1, 4 et 10.
- **Audit client** en Test à 6 joueurs : 0 `Light` hors de `workspace.Lumieres`, 0 `Shadows` à true, 0 Part de `workspace.Zbires` avec `CastShadow` à true, 150 Neon au plus.
- Brider à 20 FPS pendant 3 s doit faire passer `Qualite` à `"Legere"`. Le fondu du Colosse et l'intro de a40 démarrent avec moins de 0,1 s d'écart.
- Au niveau 1, capturer chaque Zbire, les disques `Sol` et les 3 états de la Maison. « Record : Jour X » a `LightInfluence` à 0.

## 6. Laboratoire

`ShadowMap`, `Shadows = false` sur les 12 sources, réglages statiques. Seul le LocalScript `LumieresLabo` anime, avec les mêmes règles : 10 Hz, 2 lumières à la fois, jamais plus de 3 Hz. **`Future`** seulement si un test à 12 joueurs sur l'Android 3 Go (60 s au Quai pendant un départ) mesure au moins 30 FPS. `Shadows` reste alors à false.

Réglages : `ClockTime` 21, `Brightness` 0,5, `Ambient` (83, 86, 118), `OutdoorAmbient` (42, 50, 99), `EnvironmentDiffuseScale` 0,2, `EnvironmentSpecularScale` 0,5, `Bloom` 0,8 / 24 / 1, `ColorCorrection` Saturation 0,2, Contrast 0,08, Tint (240, 250, 255). `Sky` : `StarCount` 800, `CelestialBodiesShown` false. Pas d'`Atmosphere`.

| Source | Nb | Ancre | Lumière | Réglages |
|---|---|---|---|---|
| Arbre des Recherches | 1 | a36 | PointLight Gemme cyan | 2, Range 24 |
| Doc Boulon | 1 | lampe de a22 | SpotLight zénithal Crème | 2, Range 16, 50° |
| Anneau des Alcôves | 4 | kit a23, 1 pour 3 Alcôves | PointLight Crème lumière | 1,2, Range 16 |
| Capsules | 3 | a36 | SpotLight : Toit orange (Normale), Alerte (Difficile), Gemme cyan (du Jour) | 2 ; 1 Hz au décompte, 2 Hz les 5 dernières s |
| Galerie des Zbires | 2 | a36 | SurfaceLight Crème | 1,5, Range 12, 90° |
| Réserve Foreuse | 1 | a36 | PointLight Gemme cyan, locale | flash de 0,3 s |

- *Écart : la fin du décompte des Capsules passe de 3 à 2 Hz, pour garder une marge sous le plafond.* Si les 3 Capsules décomptent en même temps, celle qui partira en dernier reste fixe.
- Les néons du Quai sont Crème : la Capsule du Jour, cyan, ressort.
- **150 Neon :** machines de recherche 48, bordures d'Alcôves 24, Arbre 16, Quai 12, Galerie 8, décor cyan 30, réserve 12.

### 🎆 Artiste VFX — Sacha Doln
# Zsurvie : effets visuels

## 1. Règles du style « Pixel-bloc »

- **Textures :** motif de 8 × 8 pixels agrandi × 8 (PNG 64 px, plus proche voisin), flipbooks de 128 px en `Grid2x2`. `Rotation` et `RotSpeed` à 0, sauf les étoiles (180°/s).
- **On rétrécit, on ne fond pas :** `Transparency` 0 et `Size` → 0 sur les 30 derniers % de vie. Seuls les nuages s'effacent.
- **`LightInfluence` 0 partout :** le code couleur tient au `ClockTime` 17,5 du Jour du Colosse. `LightEmission` 0 sur les cubes, de 0,5 à 1 sur étoiles, pièces et gemmes.
- **Taille minimale 0,5 stud**, sinon l'effet disparaît sur téléphone avec la caméra (0, 45, 28).
- **Couleurs :** Zbires = Violet horde + accent du type ; nous = Toit orange et Crème ; Or = pièces ; Gemme cyan = gemmes ; Alerte = télégraphes et Maison en danger, jamais sur un Zbire vaincu.
- **Public jeune :** ni sang ni corps qui reste, 3 flashs plein écran par seconde au plus, secousse caméra désactivable. Effets de combat ≤ 0,8 s, célébrations ≤ 2 s.

## 2. Budget (Android 3 Go, 30 FPS, 60 Zbires)

- **`Rate` ≤ 20** sur les émetteurs continus, 8 au plus dans le champ.
- **Salves `:Emit()` :** réservoir client de 300 particules/s sur mobile et 600 sur PC, × 0,5 sous 28 FPS pendant 2 s. *Précision du canon : `Rate` ne borne pas `:Emit()`, ce réservoir s'en charge.*
- **Culling :** tout effet à plus de 90 studs de la caméra est ignoré.
- **Lumière :** 0 Part `Neon` côté VFX, 3 `PointLight` sur 12, en pool.
- **Instances :** 1 Part d'ancrage client, 1 `Attachment` par effet, aucun émetteur par Zbire ni par pièce.

## 3. Textures

`cube` (carré, 1 px d'ombre), `etoile` (4 branches), `anneau` (cercle de 1 px), `nuage` (3 bosses), `plus` (croix), `trait` (dégradé en 4 marches), `piece` et `gemme` (flipbooks). Pour coucher un anneau au sol : `Orientation` `VelocityPerpendicular`, `EmissionDirection` `Top`, `Speed` 0,01.

## 4. Catalogue

P0 = lancement, P1 = bêta, P2 = après le lancement. « Emit n » = salve.

### Tir et impacts

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| C1 | Tir → flash du Blaster (prédit en local) | Emit 2, Lifetime 0,06, Speed 0, Size 1,2 → 0 | etoile · Crème, LightEmission 1 | P0 |
| C2 | Tir → traçante | `Beam` canon → impact, Width0 0,35, Width1 0,15, `FaceCamera`, 0,07 s | trait · Toit orange lumière → Crème | P0 |
| C3 | Touche → impact | Emit 5, Lifetime 0,2-0,35, Speed 10-16, Drag 8 ; modèle teinté Crème 0,06 s, écrasé × 0,8 | cube · Violet horde lumière | P0 |
| C4 | Casqué sans critique → ricochet | `VelocityParallel`, Emit 4, Lifetime 0,12, Speed 20-26, SpreadAngle 70 | trait · Ardoise lumière | P0 |
| C5 | Critique → étoile | Emit 1, Size 2,5 → 0, Lifetime 0,25, RotSpeed 180 ; + 1 anneau | etoile · Crème ; anneau Toit orange | P0 |
| C6 | Balle explosive | Emit 8 cubes, Speed 14-22, Acceleration (0, −50, 0) ; anneau Size 1 → 10 ; 3 nuages ; PointLight Range 12, 0,15 s | Toit orange, Crème ombre | P1 |
| C7 | Perforante, Mini-Tourelle | perforante : C2 avec Width0 0,5, C3 sur chaque Zbire traversé ; tourelle : C1 + C2 × 0,6 | trait · Crème | P1 |

### Zbires

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| Z1 | Mort → éclatement | étirement × 1,2 en 0,08 s, puis Emit 10 cubes, Speed 14-22, Acceleration (0, −60, 0), Lifetime 0,5-0,8 ; 2 nuages | Violet horde + accent : Doré Or, Casqué Ardoise, Gluant Violet lumière, Costaud Violet ombre | P0 |
| Z2 | Gluant → division | Z1 × 0,5 ; 2 Mini-Gluants jaillissent en arc (0,3 s), écrasés × 0,8 à l'atterrissage | Violet horde lumière | P0 |
| Z3 | Doré vaincu | Z1 teinté Or + gerbe de 6 gemmes, Speed 16 vers le haut | gemme · Gemme cyan | P0 |
| Z4 | Portail de la Lisière | Cylinder, Rate 6, Lifetime 1,2, Speed 2 ; apparition : Emit 8 cubes + anneau | Violet horde lumière | P1 |
| Z5 | Sauteur → télégraphe | disque au sol 0,6 s avant l'atterrissage (Part `Cylinder`, Transparency 0,6 → 0,2), puis Emit 6 nuages | Alerte ; Terre battue | P0 |
| Z6 | Colosse, arrivée et pas | 4 `Beam` depuis le portail géant, Width 2, `Wrap`, TextureSpeed 1, PointLight Range 30 ; chaque pas : 8 nuages + anneau Size 2 → 16, secousse 0,3 stud | Violet horde → Alerte ; Terre battue | P0 |
| Z7 | Colosse vaincu | Z1 × 4 en 3 salves espacées de 0,2 s + B3 | Violet horde, Or | P0 |

### Butin (visible du seul propriétaire)

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| B1 | Butin lâché → pièce au sol | Part 1 × 1 × 0,25 `SmoothPlastic`, rotation 180°/s, rebond élastique, sans émetteur | Or | P0 |
| B2 | Crédit serveur → aspiration | Tween 0,25 s `Quad` `In` vers le torse ; `Trail` Lifetime 0,12, WidthScale 1 → 0 ; à l'arrivée, Emit 3 étoiles | Or → Crème | P0 |
| B3 | Colosse vaincu → pluie d'or | Emit 20, Speed 18-26, SpreadAngle 30 vers le haut, Acceleration (0, −40, 0), Lifetime 1,2, `FlipbookMode` Loop | piece · Or | P0 |
| B4 | Crédit de gemmes | Emit 5, Speed 8-12, Lifetime 0,6, LightEmission 0,8 ; + anneau | gemme · Gemme cyan | P0 |
| B5 | Mine | Rate 4, Lifetime 1, Speed 1-3 ; chaque production : Emit 3 gemmes | Gemme cyan | P1 |

### Maison, défenses, Survivants

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| M1 | Maison touchée | Emit 4 cubes, Speed 8-12 ; `Highlight` unique, FillTransparency 0,6, 0,08 s | Crème, Toit orange ; Highlight Alerte | P0 |
| M2 | Réparation (bouton maintenu) | `Beam` Blaster → Maison, Width 0,6, `Wrap`, TextureSpeed 3 ; un « + » toutes les 0,25 s | Toit orange lumière | P0 |
| M3 | PV sous 66 % puis 33 % | Emit 16 cubes + 4 nuages ; ensuite fumée Rate 3, Lifetime 2 | Crème ombre ; Ardoise lumière | P1 |
| M4 | Chute de la Maison | Emit 40 cubes + 8 nuages ; anneau Size 4 → 30 ; secousse 0,6 stud, 0,5 s ; PointLight 0,3 s | Crème, Toit orange | P0 |
| M5 | Régénération | Emit 2 « + » par tick, Speed 3 | Crème | P2 |
| D1 | Pose de défense | écrasement × 0,8 puis étirement × 1,2 en 0,15 s ; Emit 8 cubes + anneau | Crème | P1 |
| D2 | Tapis Collant | Rate 2, Lifetime 0,8, Speed 1 | cube · Toit orange ombre | P1 |
| S1 | Étourdi 2 s | `LockedToPart` au-dessus de la tête, Cylinder de rayon 1,2, Rate 10, Lifetime 0,5, RotSpeed 360 | etoile · Crème | P0 |
| S2 | Achat à l'Établi | Emit 14 étoiles, Cylinder, Speed 6 vers le haut ; `Beam` colonne 1,2 s | Or → Crème | P1 |
| S3 | Roue des Pings | `Beam` vertical de 12 studs, Width 1, 4 s ; + anneau | « Colosse ! » Alerte, « Répare ! » Toit orange, « Ici ! » Crème, « Merci ! » Prairie | P1 |
| S4 | Jour franchi | Emit 20 confettis par Survivant + B4 | palette sans Alerte | P1 |

### Laboratoire

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| L1 | Capsule (3 dernières secondes, départ) | Rate 20 nuages ; départ : `Trail` Lifetime 0,5, large de 2 studs | Crème ; Gemme cyan | P1 |
| L2 | Recherche lancée | Emit 16 gemmes ; `Beam` Doc Boulon → Alcôve, 1 s | Gemme cyan | P1 |
| L3 | Récolte de la Foreuse | 3 salves de 10 gemmes, espacées de 0,3 s | Gemme cyan | P0 |

## 5. Code : du serveur à l'écran

Le serveur signale des effets **déjà validés**, par lots à 10 Hz. Seuls C1 et C2 du tireur local sont prédits, et ils ne rapportent rien.

```lua
--!strict
-- ServerScriptService/Vfx (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local vfxRapide = remotes:WaitForChild("VfxRapide") :: UnreliableRemoteEvent
local vfxImportant = remotes:WaitForChild("VfxImportant") :: RemoteEvent

local Vfx = {}
local lot: { { any } } = {}
local cumul = 0

-- code 0 : tir (arg = UserId, fin = impact) ; codes 1-11 : RAPIDES (arg = teinte)
function Vfx.signaler(code: number, position: Vector3, arg: number?, fin: Vector3?)
	if #lot < 120 then -- au-delà, on jette : c'est cosmétique
		table.insert(lot, { code, position, arg or 0, fin })
	end
end

function Vfx.important(code: number, position: Vector3)
	vfxImportant:FireAllClients(code, position)
end

RunService.Heartbeat:Connect(function(dt)
	cumul += dt
	if cumul < 0.1 then return end
	cumul = 0
	for i = 1, #lot, 20 do -- 20 par paquet : sous les 900 octets
		vfxRapide:FireAllClients(table.move(lot, i, math.min(i + 19, #lot), 1, {}))
	end
	table.clear(lot)
end)

return Vfx
```

```lua
--!strict
-- StarterPlayerScripts/VfxClient (ModuleScript) : affiche, ne décide jamais rien
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage:WaitForChild("Charte")) :: any
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local dossier = ReplicatedStorage:WaitForChild("VFX")

local function teinte(cle: string, hex: string): Color3
	return if typeof(Charte[cle]) == "Color3" then Charte[cle] else Color3.fromHex(hex)
end
-- 0 Violet horde, 1 Or (Doré), 2 Ardoise (Casqué), 3 Violet lumière (Gluant), 4 Violet ombre (Costaud)
local TEINTES = { [0] = teinte("VioletHorde", "9B5DE5"), teinte("Or", "FFC933"),
	teinte("Ardoise", "4A4560"), teinte("VioletHordeLumiere", "AD79DE"), teinte("VioletHordeOmbre", "7C4AB7") }
local RAPIDES = { "Impact", "Ricochet", "Critique", "Eclatement", "Explosion", "Division",
	"Atterrissage", "MaisonTouchee", "Apparition", "PasColosse", "GerbeGemmes" }
local IMPORTANTS = { "ArriveeColosse", "DefaiteColosse", "ChuteMaison", "JourFranchi" }
local SECOUSSES = { PasColosse = { 0.3, 0.2 }, ChuteMaison = { 0.6, 0.5 } }

local VfxClient = {}
VfxClient.secouer = nil :: ((number, number) -> ())? -- branché par le module caméra

local ancre = Instance.new("Part")
ancre.Anchored, ancre.CanCollide, ancre.CanQuery, ancre.CanTouch = true, false, false, false
ancre.Transparency, ancre.Name, ancre.Parent = 1, "AncreVFX", Workspace

local attaches: { [string]: Attachment } = {}
for _, g in dossier:WaitForChild("Emetteurs"):GetChildren() do
	local a = g:Clone() :: Attachment
	a.Parent = ancre
	attaches[a.Name] = a
end

local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local BUDGET = if mobile then 300 else 600 -- particules par seconde
local qualite, reserve, dtMoyen, lent, fluide = 1, BUDGET, 1 / 60, 0, 0
RunService.Heartbeat:Connect(function(dt)
	reserve = math.min(BUDGET * qualite, reserve + BUDGET * qualite * dt)
	dtMoyen += (dt - dtMoyen) * 0.1
	lent = if dtMoyen > 1 / 28 then lent + dt else 0
	fluide = if dtMoyen < 1 / 50 then fluide + dt else 0
	if lent > 2 then qualite = 0.5 elseif fluide > 5 then qualite = 1 end
end)

function VfxClient.emettre(nom: string, position: Vector3, couleur: Color3?, force: boolean?)
	local a, camera = attaches[nom], Workspace.CurrentCamera
	if not a or (not force and (position - camera.CFrame.Position).Magnitude > 90) then return end
	a.WorldPosition = position
	for _, e in a:GetChildren() do
		local n = math.max(1, math.floor(((e:GetAttribute("Nombre") :: number?) or 1) * qualite + 0.5))
		if e:IsA("ParticleEmitter") and (force or reserve >= n) then
			reserve -= n
			if couleur and e:GetAttribute("Teintable") then e.Color = ColorSequence.new(couleur) end
			e:Emit(n)
		end
	end
	local s = SECOUSSES[nom]
	if s and VfxClient.secouer then VfxClient.secouer(s[1], s[2]) end
end

local modele = dossier:WaitForChild("Tracante") :: Beam
local tracantes, prochaine = {}, 0
for i = 1, 8 do
	local a0, a1, b = Instance.new("Attachment"), Instance.new("Attachment"), modele:Clone()
	a0.Parent, a1.Parent = ancre, ancre
	b.Attachment0, b.Attachment1, b.Parent = a0, a1, ancre
	tracantes[i] = { b = b, a0 = a0, a1 = a1 }
end

function VfxClient.tracer(origine: Vector3, impact: Vector3)
	prochaine = prochaine % 8 + 1
	local t = tracantes[prochaine]
	t.a0.WorldPosition, t.a1.WorldPosition, t.b.Enabled = origine, impact, true
	task.delay(0.07, function() t.b.Enabled = false end)
end

local rapide = remotes:WaitForChild("VfxRapide") :: UnreliableRemoteEvent
rapide.OnClientEvent:Connect(function(lot: { { any } })
	for _, ev in lot do
		if ev[1] == 0 and ev[3] ~= Players.LocalPlayer.UserId then -- tir d'un coéquipier
			VfxClient.emettre("Flash", ev[2])
			VfxClient.tracer(ev[2], ev[4])
		elseif RAPIDES[ev[1]] then
			VfxClient.emettre(RAPIDES[ev[1]], ev[2], TEINTES[ev[3]])
		end
	end
end)

local important = remotes:WaitForChild("VfxImportant") :: RemoteEvent
important.OnClientEvent:Connect(function(code: number, position: Vector3)
	local nom = IMPORTANTS[code]
	if not nom then return end
	for i = 0, (if nom == "DefaiteColosse" then 2 else 0) do
		task.delay(i * 0.2, VfxClient.emettre, nom, position, nil, true)
	end
end)

return VfxClient
```

## 6. Montage dans Studio

1. `ReplicatedStorage.Remotes` : `UnreliableRemoteEvent` `VfxRapide`, `RemoteEvent` `VfxImportant`.
2. `ReplicatedStorage.VFX.Emetteurs` : un `Attachment` par nom de `RAPIDES`, `IMPORTANTS` et `Flash` ; ses `ParticleEmitter` ont `Enabled` false, `Rate` 0 et les attributs `Nombre` (l'Emit du catalogue) et `Teintable`. `VFX.Tracante` : le `Beam` C2, `Enabled` false.
3. Émetteurs continus (portails, Mine, Tapis Collant, fumée) posés dans la map ; S1 dans la tête de chaque Survivant, `Enabled` calé sur l'attribut serveur `Etourdi`.
4. Le Blaster joue `emettre("Flash", canon, nil, true)` et `tracer(canon, visee)`, puis envoie sa demande de tir.
5. Butin : `FireClient` au seul propriétaire ; B1 à B4 ne jouent qu'à ce signal.

## 7. Ordre de production

- **P0 (20 effets) :** C1-C5, Z1-Z3, Z5-Z7, B1-B4, M1, M2, M4, S1, L3.
- **Porte de validation :** Android 3 Go, 6 joueurs, 60 Zbires et le Colosse, tous les P0 actifs : ≥ 30 FPS. Sinon on baisse les attributs `Nombre` avant de toucher au gameplay.

### 🕺 Animatrice — Wanda Perrin
## Règles de timing Zsurvie

- **Lire depuis la caméra** (0, 45, 28), `FieldOfView` 50 : on voit le dessus des têtes. Rebonds verticaux et roulis latéral (±15°) se lisent, un balancement de bras avant-arrière non. On les exagère.
- **Élastique canon :** écrasement × 0,8, étirement × 1,2, repos, 0,05 s par étape (0,15 s), sur chaque impact, réception, pose ou achat.
- **Anticipation lisible à 9 ans :** 0,25 s minimum par attaque de Zbire, 1,0 s pour le Colosse. Impact en 2 images, récupération deux fois plus longue.
- **Pixel-bloc :** Animation Editor à 30 images/s, poses clés espacées d'au moins 2 images. Easing `Cubic` par défaut, `Bounce` sur les réceptions, `Constant` pour les clignements (échange de `Decal`).
- **Jamais d'horreur :** ni chute au sol ni ragdoll. Un Zbire gonfle puis éclate en cubes et en pièces. Un Survivant étourdi voit des étoiles.
- **Horde désynchronisée :** chaque boucle démarre à une phase aléatoire, à une vitesse de × 0,9 à × 1,1. 60 Zbires ne marchent jamais au pas.

## Rigs et pipeline

- **Survivant :** R15 standard (`StarterCharacter` pixel-bloc). Le Blaster est relié à `RightHand` par un `Motor6D` nommé `Grip_Blaster`, animé dans les clips. Le script `Animate` est forké dans `StarterCharacterScripts` (idle, walk, jump, fall et sit remplacés).
- **Zbires :** `AnimationController` + `Animator`, sans `Humanoid`. La `PrimaryPart` est ancrée et déplacée par `PivotTo` côté client. 6 `Motor6D` au maximum, aux noms imposés : `Corps`, `Tete`, `PiedG`, `PiedD`, `Accessoire`, `Accessoire2`. Les Parts animées sont en `Anchored` false, `Massless` true, `CanCollide`, `CanTouch` et `CanQuery` false.
- **Clips communs :** grâce aux noms de joints identiques, Apparition, Touché et Éclat sont 3 clips partagés par tous les Zbires. Le clip de locomotion s'appelle toujours `Marche` (battement du Volant, rebond du Gluant compris).
- **Écrasement sans échelle :** l'Animation Editor n'anime pas `Size`. On simule × 0,8 et × 1,2 en rapprochant ou en écartant les cubes (tête −20 % en Y, pieds +10 % en X). `Size` n'est tweené que sur les objets isolés (pièces, Muret).
- **Rangement :** `ReplicatedStorage.Animations.<Sujet>.<Emplacement>`, repli sur `Zbires.Communs`. Publication sous le groupe propriétaire de l'expérience, sinon rien ne charge.
- **KeyframeMarker :** `Impact`, `Pas`, `Pose`, `Eclat`. Ils ne déclenchent que les sons et les VFX côté client. `Pas` n'est sonore que sur le Costaud et le Colosse (plafond de 16 sons).
- **Autorité serveur :** le serveur applique dégâts et étourdissements selon `ReplicatedStorage.Config.Timings`, qui reprend les durées ci-dessous, jamais sur un marqueur client.
- **Préchargement :** `ContentProvider:PreloadAsync` sur toutes les `Animation` pendant l'écran de téléportation.

## Survivants

| Animation | Durée | Priorité | Boucle | Prod | Intention de timing |
|---|---|---|---|---|---|
| Idle | 2,4 s | Idle | Oui | P0 | Respiration sur 2 cubes, clignement à 1,8 s |
| Course | 0,5 s | Movement | Oui | P0 | Rebond de 0,4 stud à chaque pas, roulis ±10° |
| Saut / Chute | 0,3 s / 0,4 s | Movement | Non / Oui | P1 | Étirement × 1,2 au départ, bras levés |
| Visée | 0,6 s | Action | Oui | P0 | Haut du corps seul. Active dès qu'une cible est à 40 studs |
| Recul | 0,12 s | Action2 | Non | P0 | 2 images, puis retour. Au-delà de 8 tirs/s, joué 1 tir sur 2 |
| Réparation | 0,6 s | Action | Oui | P0 | Coup de clé à 0,3 s (`Impact`), bras très haut |
| Pose défense | 0,5 s | Action | Non | P1 | Accroupi 0,2 s, `Pose` à 0,3 s |
| Étourdi | 2,0 s (0,5 s × 4) | Action3 | Oui | P0 | Entrée écrasée en 0,1 s, tête qui tourne |
| Relevé | 0,3 s | Action3 | Non | P0 | Secoue la tête, étirement × 1,2 |
| Gestes de Pings | 0,8 s | Action4 | Non | P1 | Haut du corps. « Colosse ! » : pointe et saute. « Répare ! » : mime la clé. « Ici ! » : agite le bras. « Merci ! » : pouce levé. Aucun geste pendant l'étourdissement |
| Jour franchi | 1,0 s | Action2 | Non | P2 | Poing levé au début du Répit, si le Survivant ne tire pas |
| Maison tombée | 1,2 s | Action4 | Non | P1 | Mains sur la tête, genoux qui plient, rire gêné |
| Attente en Capsule | 1,6 s | Idle | Oui | P1 | Assis, les pieds qui battent |

**Viser en courant :** cible à portée, `Humanoid.AutoRotate` = false et un `AlignOrientation` (`Responsiveness` 40) tourne le Survivant vers elle. Déplacement opposé à la visée (produit scalaire < −0,3) : l'`Animate` forké joue la course à `AdjustSpeed(-0.8)`. L'orientation se réplique. **Étourdi :** l'attribut serveur `Etourdi` déclenche la piste chez le client propriétaire, qui la réplique.

## Zbires

| Zbire | Emplacement | Durée | Priorité | Boucle | Prod | Intention |
|---|---|---|---|---|---|---|
| Communs | Apparition | 0,5 s | Action | Non | P0 | Saut hors du portail, réception écrasée |
| Communs | Touche | 0,12 s | Action2 | Non | P0 | Recul de 0,2 stud, la marche continue |
| Communs | Eclat | 0,15 s | Action4 | Non | P0 | Gonfle (cubes écartés × 1,2), `Eclat` en fin de clip |
| Marcheur | Marche / Attaque | 0,8 s / 0,6 s | Movement / Action | Oui / Non | P0 | Dandinement ±15°. Recul 0,3 s, coup de tête 0,1 s |
| Rapide | Marche / Attaque | 0,4 s / 0,35 s | Movement / Action | Oui / Non | P1 | Penché à 20°. Anticipation 0,25 s |
| Costaud | Marche / Attaque | 1,2 s / 1,0 s | Movement / Action | Oui / Non | P1 | Pas lourds. Gratte le sol 0,4 s, piquants hérissés |
| Doré | Marche | 0,5 s | Movement | Oui | P1 | Zigzag sautillant, sac de gemmes qui ballotte |
| Sauteur | Marche / Attaque (bond) | 0,6 s / 1,0 s | Movement / Action | Oui / Non | P1 | Écrasement 0,25 s, vol 0,5 s calé sur l'horodatage serveur, réception 0,25 s |
| Gluant | Marche / Division | 0,7 s / 0,35 s | Movement / Action4 | Oui / Non | P1 | Étirement horizontal × 1,2, puis 2 Mini-Gluants jaillissent à ±90° |
| Mini-Gluant | Marche | 0,45 s | Movement | Oui | P1 | Rebond du Gluant, plus vif |
| Volant | Marche (battement) | 0,3 s | Movement | Oui | P1 | Ailes sur 2 images. Flottement sinusoïdal procédural ±0,5 stud sur 1,6 s |
| Casqué | Marche / Touche / CasqueEjecte | 1,0 s / 0,2 s / 0,4 s | Movement / Action2 / Action3 | Oui / Non / Non | P1 | Coup normal : « tink », le casque vibre et rien d'autre. Critique : le casque saute d'1 stud. L'enfant doit sentir la différence |
| Tous | Englué | — | — | — | P1 | Tapis Collant : `AdjustSpeed` de la marche au prorata de la vitesse serveur |

## Colosse

| Animation | Durée | Priorité | Boucle | Prod | Intention |
|---|---|---|---|---|---|
| Entrée | 3,0 s | Action | Non | P1 | Sort d'un portail, fait 3 pas, rugit. Pas de cinématique : les joueurs gardent le contrôle |
| Marche | 2,0 s | Movement | Oui | P1 | 2 pas par cycle. `Pas` déclenche une secousse de caméra de 0,15 s |
| Frappe Maison | 1,6 s | Action | Oui | P1 | Bras levé 0,8 s, frappe, recul |
| Frappe au sol | 2,2 s | Action2 | Non | P1 | Anticipation 1,0 s (cercle Alerte au sol), impact, récupération 1,0 s : la fenêtre de tir |
| Défaite | 2,5 s | Action4 | Non | P1 | Vacille, s'assoit, gonfle, éclate en pluie de cubes et de pièces |

## Objets de la run (TweenService ou boucle client)

| Objet | Animation | Durée | Boucle | Prod | Intention |
|---|---|---|---|---|---|
| Maison | Coup reçu | 0,2 s | Non | P0 | Tremble de ±0,3 stud, au plus 1 fois toutes les 0,3 s |
| Maison | Changement d'état | 0,4 s | Non | P0 | Élastique, cubes qui sautent du toit |
| Maison | Réparée / Effondrement | 0,25 s / 2,0 s | Non | P0 / P1 | Pulsation Crème. S'écrase comme un soufflé, le toit rebondit 2 fois |
| Pièces, Gemmes | Chute / Rotation / Aimant | 0,35 s / 1,5 s / 0,2 s | Non / Oui / Non | P0 | Arc en `Bounce`, 1 tour, aspiration vers le joueur |
| Mine | Extraction | 1,6 s | Oui | P1 | Pioche mécanique, une gemme saute à chaque production |
| Portail | Ouverture / Pulsation | 0,6 s / 1,2 s | Non / Oui | P1 | L'ouverture annonce le Zbire |
| Muret, Tapis Collant | Pose | 0,3 s | Non | P1 | Tombe du ciel, élastique |
| Mini-Tourelle | Pose / Tir | 0,4 s / 0,1 s | Non | P1 | Visée procédurale, 360°/s au maximum |
| Tourelle de toit | Déploiement | 0,8 s | Non | P2 | Sort du toit au début de la run |
| Capsule | Départ / Atterrissage | 1,2 s / 1,0 s | Non | P1 | Portes fermées en 0,4 s à T−1 s. À l'arrivée, les Survivants sautent dehors |

## Laboratoire

| Sujet | Animation | Durée | Priorité | Boucle | Prod | Intention |
|---|---|---|---|---|---|---|
| Doc Boulon | Bricole | 4,0 s | Idle | Oui | P1 | Tournevis en main, remonte ses lunettes à 3 s |
| Doc Boulon | Parle / Pointe / Accueil | 1,2 s / 1,0 s / 1,5 s | Action | Oui / Non / Non | P1 | Pointe : geste du tutoriel, tenu 0,4 s |
| Doc Boulon | Recherche lancée | 1,8 s | Action2 | Non | P2 | Saut de joie |
| Alcôve | Nouvelle machine | 1,2 s | Tween | Non | P1 | Descend du plafond avec l'élastique, visible par tous |
| Machines | Tourelle / Perforantes / Visée / Foreuse | 4,0 / 1,2 / 3,0 / 0,5 s | Procédural | Oui | P2 | Seules les 4 Alcôves les plus proches de la caméra sont animées |
| Galerie | Figurines | clips des Zbires | Movement | Oui | P2 | Jouées à moins de 30 studs. Une variante débloquée fait un tour sur elle-même en 1,0 s |

## Interface

| Élément | Durée | Intention | Prod |
|---|---|---|---|
| Bouton pressé | 0,15 s | `UIScale` 1 → 0,8 → 1,2 → 1 | P0 |
| Compteur de pièces | 0,12 s | +10 % puis retour, regroupé au-delà de 5 gains/s | P0 |
| Roue des Pings | 0,18 s | Ouverture en `Back`, 4 secteurs décalés de 0,03 s | P1 |
| Alerte « Colosse ! » | 1,0 s | 3 pulsations Alerte | P1 |
| Achat à l'Établi | 0,4 s | L'icône saute dans le Sac à dos | P1 |
| Bilan des gemmes | 1,5 s | Décompte, puis élastique final | P1 |

## Code : animation des Zbires côté client

```lua
-- StarterPlayer.StarterPlayerScripts.ZbireAnimateur (ModuleScript, client uniquement)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Timings = require(ReplicatedStorage.Config.Timings)
local ANIMS = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Zbires")
local COMMUNS = ANIMS:WaitForChild("Communs")

local PRIORITES = {
	Marche = Enum.AnimationPriority.Movement,
	Apparition = Enum.AnimationPriority.Action,
	Attaque = Enum.AnimationPriority.Action,
	Touche = Enum.AnimationPriority.Action2,
	CasqueEjecte = Enum.AnimationPriority.Action3,
	Division = Enum.AnimationPriority.Action4,
	Eclat = Enum.AnimationPriority.Action4,
}

local fiches = {} -- [id] = { modele, pistes, vitesseRef, visible }
local ZbireAnimateur = {}

function ZbireAnimateur.attacher(id: number, modele: Model, typeZbire: string)
	local controleur = Instance.new("AnimationController")
	local animator = Instance.new("Animator")
	animator.Parent = controleur
	controleur.Parent = modele

	local dossier = ANIMS:FindFirstChild(typeZbire)
	local pistes: { [string]: AnimationTrack } = {}
	for nom, priorite in PRIORITES do
		local anim = (dossier and dossier:FindFirstChild(nom)) or COMMUNS:FindFirstChild(nom)
		if anim then
			local piste = animator:LoadAnimation(anim)
			piste.Priority = priorite
			piste.Looped = nom == "Marche"
			pistes[nom] = piste
		end
	end

	local marche = pistes.Marche
	marche:Play(0, 1, 0.9 + math.random() * 0.2)
	marche.TimePosition = math.random() * marche.Length -- horde désynchronisée
	fiches[id] = { modele = modele, pistes = pistes, vitesseRef = Timings.VitesseRef[typeZbire], visible = true }
end

-- decalage : secondes écoulées depuis l'ordre serveur, pour rester calé sur l'impact serveur
function ZbireAnimateur.jouer(id: number, nom: string, decalage: number)
	local fiche = fiches[id]
	local piste = fiche and fiche.pistes[nom]
	if not piste or not fiche.visible then
		return
	end
	piste:Play(0.05)
	piste.TimePosition = math.clamp(decalage, 0, piste.Length * 0.5)
end

function ZbireAnimateur.majVitesse(id: number, vitesse: number)
	local fiche = fiches[id]
	if fiche and fiche.visible then
		fiche.pistes.Marche:AdjustSpeed(vitesse / fiche.vitesseRef) -- Tapis Collant compris
	end
end

function ZbireAnimateur.eclater(id: number, surEclat: () -> ())
	local fiche = fiches[id]
	if not fiche then
		return
	end
	fiches[id] = nil
	local eclat = fiche.pistes.Eclat
	eclat:GetMarkerReachedSignal("Eclat"):Once(surEclat) -- VFX cubes et pièces
	eclat:Play(0)
	task.delay(eclat.Length + 0.05, function()
		fiche.modele:Destroy()
	end)
end

-- LOD : hors champ, la marche est coupée (vérification 4 fois par seconde)
local cumul = 0
RunService.Heartbeat:Connect(function(dt)
	cumul += dt
	if cumul < 0.25 then
		return
	end
	cumul = 0
	local camera = workspace.CurrentCamera
	for _, fiche in fiches do
		local _, visible = camera:WorldToViewportPoint(fiche.modele:GetPivot().Position)
		if visible ~= fiche.visible then
			fiche.visible = visible
			if visible then
				fiche.pistes.Marche:Play(0.1)
			else
				fiche.pistes.Marche:Stop(0)
			end
		end
	end
end)

return ZbireAnimateur
```

### 🔊 Sound designer — Eliott Grange
# Zsurvie : sound design

## 1. Règles de son

- **Style :** chiptune 8-bit sec (carré, triangle, bruit), SFX de 0,05 à 0,4 s. Les Zbires font « pouic », « plop », « clank » : ni cri, ni râle, ni bruit d'os (label Léger).
- **Téléphone d'abord :** rien d'important sous 150 Hz, le poids du Costaud et du Colosse passe entre 200 et 800 Hz. Chaque son a un double visuel : le jeu reste jouable en muet.
- **Fichiers :** `.ogg` mono pour les sons spatialisés, stéréo pour la musique seule. SFX à -16 LUFS, musique à -20 LUFS, crêtes à -1 dBTP. Upload au nom du groupe du studio, sinon le son reste muet en jeu.
- **Autorité serveur :** aucun `Sound` côté serveur. Le tir sonne tout de suite chez le tireur (cosmétique). Pièces, Gemmes, achat et jour franchi ne sonnent qu'à réception de `ReplicatedStorage.Remotes.Retour`, envoyé par le serveur après crédit.
- **Budget :** 16 voix simultanées, réparties par SoundGroup. Aucune boucle par Zbire.
- **`SoundService` :** `RespectFilteringEnabled = true`, `DopplerScale = 0`, `AmbientReverb = NoReverb` (Prairie) ou `Room` (Laboratoire). `ReplicatedStorage.Sons` est préchargé par `ContentProvider:PreloadAsync` avant la première horde.

## 2. SoundGroup et mixage

Les volumes se multiplient du parent à l'enfant.

| SoundGroup | Parent | Volume | Voix | Traitement |
|---|---|---|---|---|
| `Musique` | SoundService | 0,35 | 1 | `CompressorSoundEffect`, SideChain `Alertes`, Threshold -26, Ratio 8, Attack 0,02, Release 0,6 : la musique s'efface sous chaque alerte |
| `Ambiance` | SoundService | 0,45 | 2 | — |
| `SFX` | SoundService | 0,8 | — | `CompressorSoundEffect`, Threshold -14, Ratio 4, Attack 0,005, Release 0,12 : pas de saturation avec 60 Zbires |
| `Joueur` | SFX | 1,0 | 3 | — |
| `Zbires` | SFX | 0,6 | 4 | — |
| `Monde` | SFX | 0,85 | 3 | — |
| `Interface` | SoundService | 0,7 | 2 | — |
| `Alertes` | SoundService | 1,0 | 1 | — |

- **Groupe plein :** sa voix ponctuelle la plus ancienne est coupée ; `Zbires` abandonne plutôt le nouveau son.
- **Musique :** fondu croisé de 1,5 s (`TweenService`) entre Jour (120 BPM), Répit (90 BPM) et Colosse (140 BPM) ; Laboratoire à 100 BPM.
- **Paramètres :** curseurs Musique (multiplie `Musique.Volume`) et Effets (`SFX.Volume`, `Interface.Volume`), de 0 à 100 %.

## 3. Spatialisation

La caméra `Scriptable` est à 53 studs du Survivant : avec l'écouteur par défaut, l'arène sonnerait lointaine et plate. L'écouteur est placé sur le `HumanoidRootPart`, orienté comme la caméra (gauche de l'écran = oreille gauche), via `SoundService:SetListener(Enum.ListenerType.CFrame, …)` à chaque image. Un son spatialisé est parenté à un `Attachment` de `workspace.Terrain`, un son « Plat » à `SoundService`. Hors de portée, il n'est pas joué et n'occupe aucune voix.

| Profil | RollOffMode | RollOffMinDistance | RollOffMaxDistance | Usage |
|---|---|---|---|---|
| Plat | — | — | — | ses propres actions, interface, alertes, musique |
| Proche | `Linear` | 6 | 45 | autres Survivants, défenses, Capsules |
| Horde | `InverseTapered` | 10 | 70 | impacts et éclatements des Zbires |
| Lisiere | `InverseTapered` | 20 | 130 | portails : on entend de quel côté la horde arrive |
| Maison | `InverseTapered` | 15 | 150 | coups reçus par la Maison |
| Colosse | `Linear` | 40 | 250 | pas du Colosse, audibles dans toute l'arène |
| Mine | `Linear` | 4 | 24 | bourdonnement de la Mine |

## 4. Catalogue de la Prairie

### Actions

| Clé | Déclencheur | Groupe | Profil | Vol. | Variation / limite |
|---|---|---|---|---|---|
| `Tir` | son propre Blaster (tir automatique à 40 studs sur mobile) | Joueur | Plat | 0,45 | ±6 %, 1 toutes les 0,08 s |
| `TirAllie` | Blaster d'un autre Survivant | Monde | Proche | 0,25 | ±6 %, 1 toutes les 0,15 s |
| `TirExplosif` | Balles explosives | Joueur | Plat | 0,55 | ±5 % |
| `Saut` | saut | Joueur | Plat | 0,35 | glissando montant |
| `Reparation` | boucle tant qu'on répare | Joueur | Plat | 0,5 | « tink » 4 fois par seconde |
| `Pose` | Muret, Mini-Tourelle, Tapis Collant | Monde | Proche | 0,6 | hauteur 0,8, 1,0 ou 1,2 selon la défense |
| `TirTourelle` | Mini-Tourelle, Tourelle de toit | Monde | Proche | 0,3 | 1 toutes les 0,2 s |
| `Etourdi` | coup reçu, 2 s | Joueur | Plat | 0,6 | « boing » et étoiles |
| `Ping` | Roue des Pings, pour toute l'équipe | Interface | Plat | 0,8 | « Colosse ! » 3 notes graves, « Répare ! » 2 « tink », « Ici ! » 1 bip, « Merci ! » arpège montant |

### Zbires : une signature par silhouette

Impacts et éclatements : groupe `Zbires`, profil Horde, ±8 %, un éclatement toutes les 0,025 s au plus, au même tick que l'explosion de cubes.

| Zbire | Signature | Impact | Éclatement | PlaybackSpeed |
|---|---|---|---|---|
| Marcheur | — | « tok » | « pop » | 1,0 |
| Rapide | — | « tik » | « pip » | 1,3 |
| Costaud | — | « tonk », plus « shing » sur les piquants | « bloump » | 0,75 |
| Doré | clochette à l'apparition | « ting » | « pop » et cascade de clochettes | 1,1 |
| Sauteur | « boing » à chaque bond, 1 sur 3 au-delà de 4 Sauteurs | « tok » | « pop » | 1,15 |
| Gluant | — | « splotch » | double « splotch », puis 2 « plip » de Mini-Gluants (1,4) | 0,9 |
| Volant | une seule boucle `Volants` (Zbires, Plat), volume = min(nbVolants / 6, 1) × 0,4 | « tik » | « pop » aigu | 1,2 |
| Casqué | — | « clank » métallique (demi-dégâts), `Critique` sinon | « clank-pop » | 0,95 |
| Colosse | « BOUM » toutes les 0,8 s (Monde, profil Colosse) | « GONG » | fanfare de 3 s (Alertes) | 0,6 |

Le « clank » du Casqué, opposé au « ding » du critique, apprend la règle à l'oreille.

### Retours et récompenses

| Clé | Déclencheur | Groupe | Profil | Vol. | Détail |
|---|---|---|---|---|---|
| `Critique` | coup critique du tireur | Joueur | Plat | 0,6 | « ding » aigu par-dessus l'impact |
| `Pieces` | Pièces créditées | Interface | Plat | 0,45 | hauteur +0,05 par pièce ramassée moins de 0,6 s après la précédente, plafond 1,5 |
| `Gemme` | Gemme créditée (Doré, Mine) | Interface | Plat | 0,55 | cristal de 2 notes |
| `Achat` / `Refus` | réponse de l'Établi | Interface | Plat | 0,7 / 0,5 | caisse 8-bit / « bzzt » doux |
| `MaisonTouchee` | coup sur la Maison | Monde | Maison | 0,55 | 1 toutes les 0,25 s |
| `MaisonEtat` | passage à l'état 2 ou 3 | Alertes | Plat | 0,9 | craquement et 2 bips |
| `MaisonTombe` | fin de run | Alertes | Plat | 0,9 | jingle descendant doux de 3 s |
| `JourFranchi` | après l'`UpdateAsync` des Gemmes | Alertes | Plat | 0,9 | fanfare de 2 s |
| `Repit` / `Horde` | début et fin du Répit | Alertes | Plat | 0,8 | cloche montante / roulement de tambour |
| `ColosseArrive` | 3 s avant le Colosse | Alertes | Plat | 1,0 | cor grave, puis musique Colosse |
| `Portail` | ouverture d'un portail de la Lisière | Monde | Lisiere | 0,5 | « vwoom » violet |

### Ambiance

- `Prairie` (Ambiance, Plat, 0,5) : oiseaux 8-bit et brise pendant le Répit. Fondu de 2 s vers `Grouillement` pendant la horde, sur la même voix.
- `Grouillement` : volume = 0,1 + 0,4 × nbZbires / 60.
- `Mine` (Ambiance, profil Mine, 0,6) : bourdonnement cristallin.

## 5. Catalogue du Laboratoire (place distincte, 16 voix)

- `Machine` (Ambiance, `Linear` 3 / 14, 0,4) : une boucle par recherche d'Alcôve, seules les 4 plus proches jouent.
- `DocBoulon` (Interface, Plat, 0,35) : un « blip » par caractère de dialogue, hauteur 1,1 à 1,3. Pas de voix humaine.
- `Recherche` (Alertes, Plat, 0,8) : jingle à la confirmation serveur, puis « clonk » (Monde, Proche) à l'apparition de la machine.
- `Capsule` (Monde, Proche, 0,6) : un bip par seconde sur les 5 dernières des 15 s, puis « fshhh » au départ.
- `Figurine` (Zbires, `Linear` 4 / 16, 0,5) : signature du Zbire à moins de 8 studs, dans la Galerie des Zbires.
- `Foreuse` (Interface, Plat, 0,6) : pluie de gemmes au retour (production hors connexion).
- `RendezVous` (Alertes, Plat, 0,8) : carillon du Défi du Jour ; cloche générale le samedi à 17 h (Zbire de la Semaine).

## 6. Module client `ReplicatedStorage.Son`

Le serveur appelle `Remotes.Retour:FireClient(joueur, "Pieces")` après `solde += montant`. L'affichage des Zbires appelle `Son.Jouer("Eclatement", position, "Horde", 1.3)` avec le PlaybackSpeed du §4.

```lua
-- ReplicatedStorage.Son (ModuleScript), requis par un LocalScript de StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Son = {}
local modeles = ReplicatedStorage:WaitForChild("Sons") -- un Sound par clé, SoundId réglé dans Studio

local GROUPES = { -- nom, parent, volume, voix
	{ "Musique", nil, 0.35, 1 }, { "Ambiance", nil, 0.45, 2 }, { "SFX", nil, 0.8, 0 },
	{ "Joueur", "SFX", 1, 3 }, { "Zbires", "SFX", 0.6, 4 }, { "Monde", "SFX", 0.85, 3 },
	{ "Interface", nil, 0.7, 2 }, { "Alertes", nil, 1, 1 },
}
local PROFILS = { -- RollOffMode, min, max
	Proche = { Enum.RollOffMode.Linear, 6, 45 },
	Horde = { Enum.RollOffMode.InverseTapered, 10, 70 },
	Lisiere = { Enum.RollOffMode.InverseTapered, 20, 130 },
	Maison = { Enum.RollOffMode.InverseTapered, 15, 150 },
	Colosse = { Enum.RollOffMode.Linear, 40, 250 },
	Mine = { Enum.RollOffMode.Linear, 4, 24 },
}
local CATALOGUE = { -- groupe, volume, variation, intervalle mini (s) ; compléter depuis le §4
	Tir = { "Joueur", 0.45, 0.06, 0.08 },
	TirAllie = { "Monde", 0.25, 0.06, 0.15 },
	Eclatement = { "Zbires", 0.5, 0.08, 0.025 },
	Pieces = { "Interface", 0.45, 0, 0.03 },
	MaisonTouchee = { "Monde", 0.55, 0.05, 0.25 },
	JourFranchi = { "Alertes", 0.9, 0, 1 },
}

local groupes, voixMax, actives, dernierJeu = {}, {}, {}, {}
for _, g in GROUPES do
	local sg = Instance.new("SoundGroup")
	sg.Name, sg.Volume = g[1], g[3]
	sg.Parent = if g[2] then groupes[g[2]] else SoundService
	groupes[g[1]], voixMax[g[1]], actives[g[1]] = sg, g[4], {}
end

local function compresseur(sg, seuil, ratio, attaque, relache, source)
	local c = Instance.new("CompressorSoundEffect")
	c.Threshold, c.Ratio, c.Attack, c.Release, c.SideChain = seuil, ratio, attaque, relache, source
	c.Parent = sg
end
compresseur(groupes.SFX, -14, 4, 0.005, 0.12, nil)
compresseur(groupes.Musique, -26, 8, 0.02, 0.6, groupes.Alertes) -- ducking

local function retirer(nom: string, son: Sound)
	local i = table.find(actives[nom], son)
	if i then table.remove(actives[nom], i) end
	local ancre = son.Parent
	son:Destroy()
	if ancre and ancre:IsA("Attachment") then ancre:Destroy() end
end

local function libererVoix(nom: string): boolean
	local liste = actives[nom]
	if #liste < voixMax[nom] then return true end
	if nom == "Zbires" then return false end -- la horde ne coupe jamais une voix
	for _, son in liste do
		if not son.Looped then
			retirer(nom, son)
			return true
		end
	end
	return false
end

local positionEcoute = Vector3.zero
RunService:BindToRenderStep("EcouteurSurvivant", Enum.RenderPriority.Camera.Value + 1, function()
	local perso = Players.LocalPlayer.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if racine and camera then
		positionEcoute = racine.Position
		SoundService:SetListener(Enum.ListenerType.CFrame, CFrame.new(positionEcoute) * camera.CFrame.Rotation)
	end
end)

function Son.Jouer(cle: string, position: Vector3?, profil: string?, hauteur: number?): Sound?
	local def, modele = CATALOGUE[cle], modeles:FindFirstChild(cle)
	if not def or not modele then return nil end
	local p = profil and PROFILS[profil]
	if p and position and (position - positionEcoute).Magnitude > p[3] then return nil end
	local maintenant = os.clock()
	if maintenant - (dernierJeu[cle] or -math.huge) < def[4] or not libererVoix(def[1]) then return nil end
	dernierJeu[cle] = maintenant

	local son = modele:Clone()
	son.SoundGroup, son.Volume = groupes[def[1]], def[2]
	son.PlaybackSpeed = (hauteur or 1) * (1 + (math.random() * 2 - 1) * def[3])
	if p and position then
		son.RollOffMode, son.RollOffMinDistance, son.RollOffMaxDistance = p[1], p[2], p[3]
		local ancre = Instance.new("Attachment")
		ancre.Parent = workspace.Terrain
		ancre.WorldPosition = position
		son.Parent = ancre
	else
		son.Parent = SoundService
	end
	table.insert(actives[def[1]], son)
	son.Ended:Once(function() retirer(def[1], son) end)
	son:Play()
	return son
end

function Son.Arreter(son: Sound) -- pour les boucles (Reparation, Volants...)
	for nom, liste in actives do
		if table.find(liste, son) then
			retirer(nom, son)
			return
		end
	end
end

local combo, dernierePiece = 0, -math.huge
ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Retour").OnClientEvent:Connect(function(genre: string)
	if genre == "Pieces" then -- le serveur a déjà crédité le butin
		combo = if os.clock() - dernierePiece < 0.6 then math.min(combo + 1, 10) else 0
		dernierePiece = os.clock()
		Son.Jouer("Pieces", nil, nil, 1 + combo * 0.05)
	elseif CATALOGUE[genre] then
		Son.Jouer(genre)
	end
end)

return Son
```

### 🎼 Compositrice — Perrine Vaillant
# Musique de Zsurvie

## 1. Règles musicales

- **Palette** : chiptune 4 canaux (2 pulses, triangle, bruit) + **1 pad triangle filtré** très doux, passe-bas à 8 kHz au mastering. **Écart au canon « chiptune 8-bit »** : ce 5e canal et ce filtre évitent la fatigue des ondes carrées après une heure. À valider par Victor Lanoue.
- **Motif Zsurvie** : Ré–La–Si–La (croche, croche, noire, blanche), transposé partout : fanfare au Laboratoire, ligne de basse dans la horde, tuba mineur pour le Colosse, berceuse au Bilan.
- **La musique est une horloge** : une horde dure 80 s, sa piste aussi. Aux mesures 37 à 40, une cloche sonne à chaque mesure : le Répit arrive dans 8 s.
- **Le danger ajoute des notes, il n'assombrit jamais** : ni drone grave, ni battement de cœur, ni silence brutal (label Léger).
- **Mobile d'abord** : un haut-parleur de téléphone ne rend rien sous 200 Hz, donc chaque basse est doublée à l'octave (pulse 25 %). Mélodie entre Do4 et Do6 ; au-dessus de 1,5 kHz, place aux pièces et aux gemmes. Sans le son, le chrono de l'UI double la cloche.
- **Budget** : 3 voix musicales au maximum (2 couches + 1 jingle) sur les 16 sons simultanés ; 13 restent aux effets.
- **Zones de run** : Prairie, Lisière, Maison et Mine partagent la piste de horde (la caméra voit toute l'arène) ; Mine et portails vivent par leurs sons 3D.

## 2. Catalogue des pistes

Tous les `Sound` sont dans `SoundService.Pistes`, `SoundGroup` = `SoundService.Musique`.

| Piste | Zone / état | BPM | Tonalité | Durée | Lecture | `Volume` |
|---|---|---|---|---|---|---|
| `Labo_Base` | Laboratoire, tout le lobby | 96 | Ré maj. | 80 s (32 mes.) | `Looped` | 0,45 |
| `Labo_Quai` | couche Quai des Capsules : arpèges de gare | 96 | Ré maj. | 80 s | calée sur la base | 0,30 |
| `Labo_Galerie` | couche Galerie des Zbires : boîte à musique | 96 | Ré maj. | 80 s | calée sur la base | 0,30 |
| `Capsule` | compte à rebours de 15 s | 128 | Ré → La | 15 s (8 mes.) | une fois | 0,50 |
| `HordeA_Base` / `_Tension` | jours 1-4, « Pique-nique » | 120 | Sol maj. | 80 s (40 mes.) | relancée chaque jour | 0,45 / 0,35 |
| `HordeB_…` | jours 6-9, « Grabuge » | 120 | Mi min. | 80 s | idem | 0,45 / 0,35 |
| `HordeC_…` | jours 11+, « Chaos », charley en doubles croches | 120 | Sol mixolydien | 80 s | idem | 0,45 / 0,35 |
| `Repit` | fanfare 2,5 s, accalmie, roulement « 3-2-1 » | 96 | Sol maj. | 15 s (6 mes.) | une fois | 0,40 |
| `Colosse` | Jour du Colosse : marche de tuba comique | 120 | Do min. | 68 s | `LoopRegion` 4–68 s | 0,50 |
| `Bilan` | gemmes gagnées | 96 | Ré maj. | 40 s (16 mes.) | `Looped` | 0,40 |
| `JIN_ColosseVaincu` | Colosse vaincu | 120 | Do maj. | 5 s | jingle | 0,60 |
| `JIN_Record` | nouveau « Record : Jour X » | 120 | Sol maj. | 3 s | jingle | 0,60 |
| `JIN_MaisonTombe` | « wah-wah » descendant, comique | 80 | Sol → Ré | 5 s | jingle | 0,55 |
| `MOT_<Zbire>` × 8 | signature de chaque Zbire, 3D mono | 96 | Ré maj. | 5 s (2 mes.) | ponctuel | 0,40 |

**Horde (40 mesures)** : A (8) – B (8) – A' (8) – Pont sans mélodie (8) – Final (8, motif en canon + cloche). `_Base` et `_Tension` ont la même longueur à l'échantillon près.

**Rendez-vous** :
- Jours 5, 10, 15… : `Colosse` remplace la horde ; son intro de 4 s accompagne le passage à `ClockTime` 17,5 (`PlaybackRegionsEnabled` true, `LoopRegion` `NumberRange.new(4, 68)`).
- Capsule du Jour : la variante est décalée de 5 jours (B dès le jour 1) pour que le Défi du Jour sonne neuf.
- Zbire de la Semaine : `MOT_<vedette>` ouvre le compte à rebours, puis sonne une fois par jour à sa première apparition.

**Export** : OGG Vorbis 44,1 kHz, stéréo (mono pour `MOT_`), -16 LUFS intégrés (jingles -14), crête -1 dBTP, boucles coupées à l'échantillon, queue de réverbération repliée au début. Upload au nom du groupe propriétaire de l'expérience, sinon l'audio reste muet en jeu. Mémoire audio visée < 15 Mo par place.

## 3. Tenir une heure sans lasser

- Aucune boucle n'est entendue plus de 4 fois de suite : A aux jours 1-4, Colosse, B, Colosse, puis C.
- Le pont sans mélodie laisse l'oreille respirer 16 s par jour.
- La couche Tension n'arrive que quand ça chauffe : deux jours ne sonnent jamais pareil.
- Laboratoire : toutes les 3 boucles (4 min), `Labo_Base` s'efface en 3 s pendant 30 s ; les néons et les machines des Alcôves prennent le relais.

## 4. Transitions

| De → vers | Méthode | Durée |
|---|---|---|
| Labo ↔ Quai / Galerie | fondu de la couche, calée sur `Labo_Base.TimePosition` | 1,5 s |
| Figurine à moins de 8 studs | `MOT_` 3D (`RollOffMinDistance` 4, `RollOffMaxDistance` 14), une fois toutes les 10 s | — |
| Entrée en Capsule | `Labo_Base` à 0,1, `Capsule` démarre au temps restant | 1 s |
| Répit → Horde | coupe franche sur le temps 1 après « 3-2-1 » | 0 s |
| Horde → Répit | cadence finale, fanfare du `Repit` | 0,3 s |
| Tension ON / OFF | fondu | 2 s / 4 s |
| Jingle | couches à × 0,45 puis retour | 0,1 s / 0,8 s |
| Maison tombée | silence, `JIN_MaisonTombe`, puis `Bilan` | 0,2 s + 5 s |
| Survivant étourdi | « tournis » local : `PitchShiftSoundEffect.Octave` 0,94 + `EqualizerSoundEffect.HighGain` -10 dB | 2 s |
| Retour au Laboratoire | `Labo_Base` en fondu d'entrée | 2 s |

## 5. Mixage

- `SoundService.Musique` : `Volume` 0,6 × réglage du joueur. Enfants : `Tournis` (`PitchShiftSoundEffect`, `Octave` 0,94, `Enabled` false) et `Etouffe` (`EqualizerSoundEffect`, `HighGain` -10, `Enabled` false).
- `SoundService.Effets` 0,8 et `SoundService.Interface` 0,7 : la musique reste environ 6 dB sous les tirs.
- Réglage « Musique » : 5 crans (0 à 100 %), boutons de 60 px. Le serveur borne la valeur entre 0 et 1 avant de la sauvegarder.
- Validation sur l'Android 3 Go de référence, haut-parleur à 50 % puis casque.

## 6. Pilotage : le serveur décide, le client joue

Le serveur pose l'état en attributs de `Workspace` ; chaque client se cale sur `GetServerTimeNow()`. Pour la Maison tombée : `phase("Silence")`, `jingle("JIN_MaisonTombe")`, puis `phase("Bilan")` 5 s plus tard.

```lua
-- ServerScriptService.Run.EtatMusical (ModuleScript, place Prairie)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EtatMusical = {}
local evenementJingle = Instance.new("RemoteEvent")
evenementJingle.Name = "Jingle"
evenementJingle.Parent = ReplicatedStorage
local tensionDepuis = 0

-- etat : "Horde" | "Repit" | "Colosse" | "Bilan" | "Silence" ; bonus = 5 pour la Capsule du Jour
function EtatMusical.phase(etat: string, jour: number, bonus: number?)
	local rang = jour + (bonus or 0)
	workspace:SetAttribute("Variante", if rang <= 4 then "A" elseif rang <= 9 then "B" else "C")
	workspace:SetAttribute("DebutPhase", workspace:GetServerTimeNow())
	workspace:SetAttribute("EtatMusique", etat) -- en dernier : c'est lui que les clients écoutent
end

-- Appelée 10 fois par seconde par la boucle des Zbires
function EtatMusical.tension(nbZbires: number, ratioPvMaison: number)
	local active = workspace:GetAttribute("Tension") == true
	if not active and (nbZbires >= 40 or ratioPvMaison < 0.35) then
		tensionDepuis = os.clock()
		workspace:SetAttribute("Tension", true)
	elseif active and nbZbires <= 25 and ratioPvMaison >= 0.45 and os.clock() - tensionDepuis >= 8 then
		workspace:SetAttribute("Tension", false)
	end
end

function EtatMusical.jingle(nom: string)
	evenementJingle:FireAllClients(nom)
end

return EtatMusical
```

```lua
-- StarterPlayer.StarterPlayerScripts.Musique (LocalScript, Laboratoire et Prairie)
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local joueur = Players.LocalPlayer
local groupe = SoundService:WaitForChild("Musique")
local pistes = SoundService:WaitForChild("Pistes")
local tournis = groupe:WaitForChild("Tournis") :: PitchShiftSoundEffect
local etouffe = groupe:WaitForChild("Etouffe") :: EqualizerSoundEffect
local VOLUME = { Base = 0.45, Tension = 0.35, Couche = 0.30, Repit = 0.40, Colosse = 0.50, Bilan = 0.40 }
local canaux, cibles, tweens = {}, {}, {}

task.spawn(ContentProvider.PreloadAsync, ContentProvider, pistes:GetChildren())

local function fondre(son: Sound, cible: number, duree: number, arreter: boolean?)
	if tweens[son] then tweens[son]:Cancel() end
	local tween = TweenService:Create(son, TweenInfo.new(duree, Enum.EasingStyle.Sine), { Volume = cible })
	tweens[son] = tween
	tween.Completed:Once(function(etat)
		if arreter and etat == Enum.PlaybackState.Completed then son:Stop() end
	end)
	tween:Play()
end

local function jouer(canal: string, nom: string?, volume: number, position: number, duree: number)
	local ancien = canaux[canal]
	local son = if nom then pistes:FindFirstChild(nom) :: Sound? else nil
	if son == ancien and (son == nil or son.IsPlaying) then return end
	if ancien then fondre(ancien, 0, duree, true) end
	canaux[canal], cibles[canal] = son, volume
	if not son then return end
	if son.TimeLength > 0 then
		son.TimePosition = if son.Looped then position % son.TimeLength else math.min(position, son.TimeLength)
	end
	if not son.IsPlaying then
		son.Volume = 0
		son:Play()
	end
	fondre(son, volume, duree)
end

local function majTension()
	local horde = workspace:GetAttribute("EtatMusique") == "Horde"
	local actif = horde and workspace:GetAttribute("Tension") == true
	local base = canaux.principal
	jouer("couche", if actif then `Horde{workspace:GetAttribute("Variante")}_Tension` else nil,
		VOLUME.Tension, if base then base.TimePosition else 0, if actif then 2 elseif horde then 4 else 0.3)
end

local function surEtat()
	local etat = workspace:GetAttribute("EtatMusique") or "Silence"
	local debut = workspace:GetAttribute("DebutPhase") or workspace:GetServerTimeNow()
	local nom = if etat == "Horde" then `Horde{workspace:GetAttribute("Variante")}_Base`
		elseif etat == "Silence" then nil
		else etat
	jouer("principal", nom, VOLUME[if etat == "Horde" then "Base" else etat] or 0,
		workspace:GetServerTimeNow() - debut, 0.3)
	majTension()
end

joueur:GetAttributeChangedSignal("Etourdi"):Connect(function()
	local etourdi = joueur:GetAttribute("Etourdi") == true
	tournis.Enabled = etourdi
	etouffe.Enabled = etourdi
end)

local zones = workspace:FindFirstChild("ZonesAudio") -- Parts invisibles « Quai » et « Galerie », Laboratoire seulement

local function zoneDuJoueur(): string?
	local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
	if not racine then return nil end
	for _, zone in zones:GetChildren() do
		local p, d = zone.CFrame:PointToObjectSpace(racine.Position), zone.Size / 2
		if math.abs(p.X) <= d.X and math.abs(p.Y) <= d.Y and math.abs(p.Z) <= d.Z then
			return `Labo_{zone.Name}`
		end
	end
	return nil
end

if zones then
	jouer("principal", "Labo_Base", VOLUME.Base, 0, 2)
	local base = canaux.principal
	local pauseJusqua, volumeBase = 0, VOLUME.Base
	base.DidLoop:Connect(function(_, boucles: number)
		if boucles % 3 == 0 then pauseJusqua = os.clock() + 33 end
	end)
	while true do
		task.wait(0.5)
		local depart = joueur:GetAttribute("DepartCapsule") -- heure serveur du départ, posée par le serveur
		local enPause = depart == nil and os.clock() < pauseJusqua
		local voulu = if depart then 0.1 elseif enPause then 0 else VOLUME.Base
		if voulu ~= volumeBase then
			volumeBase = voulu
			fondre(base, voulu, if depart then 1 else 3)
		end
		if depart then
			jouer("couche", "Capsule", 0.5, 15 - (depart - workspace:GetServerTimeNow()), 1)
		else
			jouer("couche", if enPause then nil else zoneDuJoueur(), VOLUME.Couche, base.TimePosition, 1.5)
		end
	end
else
	local evenementJingle = ReplicatedStorage:WaitForChild("Jingle") :: RemoteEvent
	evenementJingle.OnClientEvent:Connect(function(nom: string)
		local jingle = pistes:FindFirstChild(nom) :: Sound?
		if not jingle then return end
		for canal, son in canaux do fondre(son, cibles[canal] * 0.45, 0.1) end
		jingle:Play()
		task.delay(math.max(jingle.TimeLength, 1), function()
			for canal, son in canaux do fondre(son, cibles[canal], 0.8) end
		end)
	end)
	workspace:GetAttributeChangedSignal("EtatMusique"):Connect(surEtat)
	workspace:GetAttributeChangedSignal("Tension"):Connect(majTension)
	surEtat()
end
```

## 🚀 Live Ops & Publication

### 💎 Designer monétisation — Apolline Josse
## 1. Règle d'or : payer pour se montrer, jamais pour gagner

Canon §9 : les Robux n'achètent que des cosmétiques et des serveurs privés. Tout le reste en découle.

- **Jamais en vente** : Pièces, Gemmes, Recherches, améliorations d'Établi, temps de Foreuse, défense supplémentaire, PV, vitesse, réduction d'étourdissement, saut de jour, relance de run, accès aux Capsules Difficile et du Jour.
- **Rien d'aléatoire** : ni caisse, ni roue, ni œuf. On voit et on essaie exactement ce qu'on achète.
- **Rien d'intermédiaire** : prix affichés en Robux, aucune monnaie premium.
- **Aucune urgence** : ni minuteur, ni « dernière chance », ni promo limitée, ni pastille rouge sur le bouton Boutique.
- **Le mérite ne s'achète pas** : les variantes de la Galerie des Zbires (10, 100, 1 000 éliminations) et les récompenses du Défi du Jour ne sont jamais vendues.
- **Aucune pression** : ni « Tes amis l'ont déjà », ni « Demande à tes parents ». Doc Boulon ne parle jamais de la Boutique.

## 2. Catalogue de lancement

### Game passes (achat unique, permanent)

| Pass | Prix | Contenu | Justification |
|---|---|---|---|
| **Garde-robe Pixel-bloc** | 149 R$ | 4 tenues (Explorateur, Pompier, Astronaute, Pique-niqueur) et 4 teintes de Sac à dos | Premier achat type : 8 objets, soit environ 19 R$ l'objet |
| **Blasters de collection** | 199 R$ | 3 modèles : Pistolet à eau, Tromblon à confettis, Rayon rétro | Le Blaster reste à l'écran en permanence : c'est la plus forte valeur perçue |
| **Alcôve de Luxe** | 199 R$ | 3 thèmes (Serre, Garage, Observatoire) qui habillent le sol, les murs et les socles des machines de recherche | Pilier 3 : l'Alcôve est vue par les 11 autres joueurs du Laboratoire |
| **Emotes du Labo** | 99 R$ | 6 emotes : Salut, Bravo, Danse robot, Pas chassé, Bâillement, Pose héroïque | Petit prix social, jouables au Laboratoire et pendant le Répit |

### Developer products

| Produit | Prix | Contenu | Justification |
|---|---|---|---|
| **Feux d'artifice ×5** | 25 R$ | 5 tirs au-dessus de la Maison (pendant le Répit) ou de son Alcôve | Plus petit achat, plaisir collectif : toute l'équipe en profite |
| **Bonnet de Zbire** (9 produits : les 8 Zbires et le Colosse) | 49 R$ l'unité | Bonnet peluche en forme de tête de Zbire, recoloré Crème et Toit orange | Collection liée au Zbire de la Semaine : le samedi à 17 h, le mannequin de la Cabine porte le bonnet vedette. Les 9 restent en vente toute l'année |

### Serveur privé

**50 R$ par mois**, sur la place Laboratoire. Jouer seulement entre amis rassure les parents. Aucune différence de jeu : les Capsules partent vers les mêmes serveurs réservés, avec les mêmes gains.

### Bornes et chemin gratuit

- Aucun article au-dessus de 199 R$.
- Tout posséder au lancement : 646 R$ de passes + 441 R$ de bonnets = **1 087 R$** (hors Feux et serveur privé). Chaque ajout futur respecte ces bornes.
- **Chemin gratuit** dans chaque catégorie : 7 Défis du Jour réussis = 1 teinte de Sac à dos ; vaincre le 2e Colosse (Jour 10) = tenue « Vétéran » ; variantes de la Galerie.

## 3. Grille de lisibilité (tout cosmétique)

| Règle | Valeur |
|---|---|
| Stats | Le Blaster cosmétique garde les dégâts, la cadence, la portée, la hitbox et le son du Blaster de base. Seul le `Model` visuel change |
| Couleurs | `ReplicatedStorage.Charte` uniquement. Interdits sur un Survivant : Violet horde #9B5DE5, Alerte #FF2E63, Or #FFC933, Gemme cyan #33D6F0 |
| Tirs | Toujours Toit orange #EF7A2F et Crème #F6E7C1 |
| Taille | 40 cubes de 0,5 stud au maximum, 1 stud de dépassement de la silhouette au plus |
| Propriétés | `CanCollide`, `CanQuery` et `CanTouch` à false, `Massless` à true, aucune Part `Neon` |
| Thèmes d'Alcôve | 120 Parts au maximum, aucune `PointLight` ajoutée |
| Hors limites | Aucun cosmétique sur la Maison, les Zbires, le Muret, la Mini-Tourelle, le Tapis Collant ou la Roue des Pings |
| Feux d'artifice | `ParticleEmitter.Rate` 20, `Lifetime` 1,5 s, aucune `PointLight`, son chiptune `Volume` 0,4. 1 tir par joueur toutes les 15 s, jamais pendant la horde |
| Emotes | Demandées au serveur (même contrôle que `Equiper`), bloquées pendant la horde et l'étourdissement |

## 4. Placement

| Lieu | Dispositif | Règle |
|---|---|---|
| **Cabine d'Essayage** (Laboratoire) | Comptoir de 12 × 12 studs, mannequin portant le Bonnet de la Semaine, `ProximityPrompt` (`ActionText` « Essayer », `HoldDuration` 0, `MaxActivationDistance` 10) | Entre l'anneau des Alcôves et la Galerie, hors du trajet entre l'apparition et le Quai des Capsules |
| **Alcôve du joueur** | Pupitre « Thème » : aperçu gratuit des 3 thèmes sur place | Prompt visible par le seul propriétaire |
| **HUD du Laboratoire** | Bouton Boutique de 64 × 64 px, coin haut droit, icône cintre | Masqué tant que la première run n'est pas terminée |
| **Prairie** | Aucune boutique, aucun appel `Prompt…Purchase` | Seul bouton : « Feu d'artifice » (64 × 64 px) pendant le Répit, s'il reste du stock |
| **Fin de run** | Gemmes gagnées, bouton Recherches | Aucun lien vers la Boutique |

Parcours d'achat : essai gratuit et illimité sur son propre Survivant dans un `ViewportFrame`, puis bouton « Acheter » qui appelle `PromptGamePassPurchase` ou `PromptProductPurchase`. Aucun prompt automatique, jamais.

**Écart au canon :** la Cabine d'Essayage est un nouvel élément du Laboratoire, absent du §5. Elle est soumise à la validation de Victor Lanoue.

## 5. Code serveur

`ReplicatedStorage.Catalogue` (ModuleScript partagé avec l'UI) décrit passes, produits et cosmétiques. Roblox rejoue un reçu non traité à la prochaine connexion du joueur : ce script tourne donc dans **les deux places**. Le DataStore `Boutique_v1` est séparé de la sauvegarde des Gemmes.

```lua
-- ServerScriptService.Boutique (Script) : places Laboratoire ET Prairie
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalogue = require(ReplicatedStorage.Catalogue)
-- Catalogue.produits[ProductId] = { feux = 5 } ou { cosmetique = "BonnetCasque" }
-- Catalogue.passes[PassId] = { "TenueExplorateur", "SacCreme", ... }
-- Catalogue.cosmetiques[id] = { emplacement = "Tete", gratuit = false }
local store = DataStoreService:GetDataStore("Boutique_v1")
local remotes = ReplicatedStorage.Remotes
local sessions = {} -- [Player] = { possedes = {}, feux = 0 }
local dernierFeu = {}

local function modifier(userId, transformer)
	return pcall(store.UpdateAsync, store, "u_" .. userId, function(data)
		data = data or { possedes = {}, feux = 0, recus = {} }
		return transformer(data)
	end)
end

local function publier(joueur, session)
	remotes.BoutiqueMaj:FireClient(joueur, session.possedes, session.feux)
end

local function accorderPass(session, passId)
	for _, id in Catalogue.passes[passId] or {} do
		session.possedes[id] = true
	end
end

local function charger(joueur)
	local ok, data = pcall(store.GetAsync, store, "u_" .. joueur.UserId)
	data = (ok and data) or { possedes = {}, feux = 0 }
	local session = { possedes = table.clone(data.possedes), feux = data.feux }
	for passId in Catalogue.passes do
		local okPass, possede = pcall(MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService, joueur.UserId, passId)
		if okPass and possede then accorderPass(session, passId) end
	end
	if joueur.Parent then
		sessions[joueur] = session
		publier(joueur, session)
	end
end

MarketplaceService.ProcessReceipt = function(recu)
	local produit = Catalogue.produits[recu.ProductId]
	if not produit then
		warn("[Boutique] ProductId inconnu :", recu.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok, data = modifier(recu.PlayerId, function(data)
		if table.find(data.recus, recu.PurchaseId) then return data end -- déjà accordé
		if produit.feux then data.feux += produit.feux end
		if produit.cosmetique then data.possedes[produit.cosmetique] = true end
		table.insert(data.recus, recu.PurchaseId)
		if #data.recus > 50 then table.remove(data.recus, 1) end
		return data
	end)
	if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local joueur = Players:GetPlayerByUserId(recu.PlayerId)
	local session = joueur and sessions[joueur]
	if session then
		session.feux = data.feux
		for id in data.possedes do session.possedes[id] = true end
		publier(joueur, session)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(joueur, passId, achete)
	local session = sessions[joueur]
	if achete and session then
		accorderPass(session, passId)
		publier(joueur, session)
	end
end)

remotes.Equiper.OnServerEvent:Connect(function(joueur, id)
	if typeof(id) ~= "string" then return end
	local session, def = sessions[joueur], Catalogue.cosmetiques[id]
	if not session or not def then return end
	if not (def.gratuit or session.possedes[id]) then return end
	joueur:SetAttribute("Cosmetique_" .. def.emplacement, id) -- visuel seul, aucune stat
end)

remotes.LancerFeu.OnServerEvent:Connect(function(joueur)
	local session = sessions[joueur]
	if not session or session.feux <= 0 then return end
	if workspace:GetAttribute("Phase") == "Horde" then return end -- Répit ou Laboratoire
	local maintenant = os.clock()
	if maintenant - (dernierFeu[joueur] or -math.huge) < 15 then return end
	dernierFeu[joueur] = maintenant
	session.feux -= 1
	task.spawn(modifier, joueur.UserId, function(data)
		data.feux = math.max(0, data.feux - 1)
		return data
	end)
	remotes.FeuLance:FireAllClients(joueur) -- chaque client joue l'effet
end)

Players.PlayerAdded:Connect(charger)
for _, joueur in Players:GetPlayers() do task.spawn(charger, joueur) end
Players.PlayerRemoving:Connect(function(joueur)
	sessions[joueur] = nil
	dernierFeu[joueur] = nil
end)
```

## 6. Contrôle

- **Tests Studio** : achats simulés. Couper le serveur pendant `ProcessReceipt` : le reçu est rejoué sans doublon grâce au `PurchaseId`. DataStore en panne : `NotProcessedYet`, rien d'accordé ni de débité à tort.
- **Audit anti-pay-to-win à J+14** : à nombre de runs égal, l'écart du jour moyen atteint entre payeurs et non-payeurs doit rester sous 3 %. Au-delà, on cherche la fuite d'avantage.
- **Objectif** : 2 à 4 % d'acheteurs parmi les joueurs actifs du mois, zéro avis « pay-to-win ».
- **Revue** : tout nouvel article passe la grille du §3 et la validation du directeur créatif.

### 🖼️ Artiste thumbnail & icône — Baptiste Hervieu
## 1. Règles communes (mobile d'abord)

| Élément | Vignette | Icône |
|---|---|---|
| Format d'export | 1920 × 1080 PNG | 512 × 512 PNG |
| Taille réelle sur téléphone | ≈ 300 × 170 px (tuile d'accueil) | ≈ 90 × 90 px (recherche, favoris) |
| Zone sûre | 5 % de marge (96 px sur les côtés, 54 px en haut), 15 % en bas (162 px) | contenu clé dans le carré central de 410 px (coins arrondis) |
| Texte | 3 mots maximum, hauteur ≥ 12 % de l'image | aucun (le nom s'affiche dessous) |
| Masses lisibles | 3 au maximum | 1 personnage ou 1 objet |

- **Test du plissement :** chaque maquette est vérifiée à 256 × 144 (vignette) et à 64 × 64 (icône), puis en niveaux de gris. Si la silhouette violette ne ressort pas, on refait.
- **Vérité du jeu :** on ne capture que les vrais modèles, dans la place `Zsurvie_Vignettes`. Pas de Zbire inventé, pas d'échelle trichée, pas de « Jour 30 » : à 95 s par jour et 25 min au plus, une run plafonne vers le jour 15. Roblox interdit les images trompeuses.
- **Public 9-15 ans :** ni sang ni visage effrayant, ni Robux ni « GRATUIT », aucun accessoire UGC de marque. Les Survivants sont des avatars blocs R15 en Crème et Toit orange, avec le Blaster et le Sac à dos bien visibles.
- **Texte :** lettrage bloc du logo, remplissage Crème #F6E7C1, contour Encre #1E1B2E de 10 px, ombre Encre de 8 px. Les versions FR et EN passent par la localisation des images du Creator Hub.
- **Couleurs canon :** violet = Zbires ; orange et crème = Maison et Survivants ; or = pièces ; cyan = gemmes. L'Alerte #FF2E63 est réservée à la bulle « Colosse ! ».

## 2. Trois concepts de vignette

### V1 « Le Colosse arrive ! » (épique)
- **Composition :** caméra basse (6 studs) de 3/4, `FieldOfView` 40. Le Colosse occupe le tiers gauche sur 55 % de la hauteur, la tête au-dessus de l'horizon. La Maison se place dans le tiers droit, sur fond de Prairie : devant le ciel, son toit orange se noierait dans le couchant. Au premier plan, 4 Survivants vus de 3/4 dos tirent des traînées Or vers le Colosse.
- **Personnages :** le Colosse, bouche grande ouverte, rigolo sans être menaçant. 6 à 8 Marcheurs et Rapides éclatent en cubes violets et en pièces. Un Survivant répare la Maison dans une gerbe d'étincelles Or. Bouger, tirer, réparer : tout le jeu tient en une image.
- **Texte :** la bulle de la Roue des Pings « Colosse ! » en Alerte, au-dessus d'un Survivant. C'est 1 mot, tiré de la vraie UI du jeu. Logo ZSURVIE en haut à gauche.
- **Lumière :** `ClockTime` 17,5, l'état canon du Jour du Colosse. Ciel orange-crème, Colosse Violet horde #9B5DE5 à contre-jour avec un liseré Crème : une silhouette sombre sur un ciel clair.

### V2 « Défendez à 6 ! » (coopération)
- **Composition :** la vraie caméra du jeu (décalage 0, 45, 28, `FieldOfView` 50), avec la Maison au centre exact. Les 4 chemins en croix de Terre battue #C8894F servent de lignes de fuite. 4 flots de Zbires sortent des portails violets de la Lisière.
- **Personnages :** 6 Survivants en étoile autour de la Maison, avec un Muret, une Mini-Tourelle et un Tapis Collant couvert de Zbires englués. Un Volant passe au-dessus du Muret, un Gluant se divise en 2 Mini-Gluants. La Mine brille en cyan à 12 studs.
- **Texte :** « DÉFENDEZ À 6 ! » (EN : « 6-PLAYER CO-OP! ») en haut à droite, sur 14 % de la hauteur.
- **Couleurs :** fond Prairie #6CC24A, anneau violet en périphérie, cœur orange-crème. L'image se lit comme une cible.
- **Risque :** trop de petits éléments pour bien se lire à 300 px. V2 joue donc le challenger.

### V3 « Jour 1 → Jour 12 » (progression)
- **Composition :** l'écran est coupé en diagonale par une bande Or de 12 px. À gauche : Maison intacte, 1 Survivant, 3 Marcheurs, `ClockTime` 9. À droite, même cadrage : Tourelle de toit, Balles explosives, 3 Survivants, 20 Zbires et le panneau « Record : Jour 12 ».
- **Texte :** deux étiquettes, « JOUR 1 » et « JOUR 12 ».
- **Couleurs :** à gauche, `Saturation` −0,2 ; à droite, +0,3 avec une gerbe de gemmes cyan.
- **Usage :** V3 promet la progression du Laboratoire. Elle occupe la position 2 du carrousel, même si elle perd son test.

Positions 4 et 5 du carrousel : le Laboratoire (Alcôves, néons cyan) et la Galerie des Zbires.

## 3. Deux concepts d'icône

### I1 « Le Zbire gourmand »
- La tête d'un Marcheur remplit 65 % de l'icône, de 3/4 face : clin d'œil et grand sourire à une seule dent. La grille de 0,5 stud reste visible, c'est la signature Pixel-bloc. En bas à droite, il croque le coin d'un toit orange.
- Fond Prairie #6CC24A, halo central Prairie clair (+20 % de Crème) et liseré Encre de 6 px autour du Zbire.
- Aucun texte : le Zbire devient la mascotte que l'on reconnaît dans la recherche.

### I2 « La Maison assiégée »
- La Maison au centre, en plongée de 3/4. Un Survivant se tient sur le toit, Blaster levé. Un Casqué, un Gluant, un Volant et un Costaud s'agrippent aux 4 murs et forment un anneau violet.
- Fond Nuit labo #2A3263 pour ressortir sur le thème clair de Roblox, gerbe de pièces Or au-dessus du toit. Aucun texte.

## 4. Quoi tester en premier

| Ordre | Test | Pourquoi |
|---|---|---|
| 1 | **V1 (témoin) contre V2** | V1 a seulement 3 masses, le plus fort contraste de valeur et un effet d'échelle. L'accueil Roblox affiche surtout des vignettes 16:9. |
| 2 | I1 (témoin) contre I2 | La recherche et les favoris montrent l'icône. À 90 px, un visage bat presque toujours une scène. |
| 3 | Gagnant du test 1 contre V3 | On teste la promesse de progression une fois la base fixée. |

- **Outil :** le test A/B des vignettes et des icônes du Creator Hub. Chaque test dure au moins 7 jours, pour couvrir un samedi de Zbire de la Semaine.
- **Mesure :** le taux de clic (visites ÷ impressions) et la durée moyenne de session. Une image qui gagne des clics mais fait perdre plus de 5 % de durée de session est rejetée.
- **Règle :** un seul test à la fois, et aucune image modifiée pendant un test.

## 5. Mise en scène dans Studio

- **Place `Zsurvie_Vignettes` :** une copie de la Prairie construite, jamais publiée comme place jouable. `Lighting.Technology` y passe à `Future` à la main, dans le panneau Propriétés : c'est la seule place qui peut s'en permettre le coût.
- **Cadrage :** avec l'émulateur d'appareil réglé sur un appareil personnalisé de 1920 × 1080. Le texte s'ajoute hors de Studio.
- **Icônes :** posées sur un plateau à (300, 0, 0), en dehors de l'arène, puis recadrées en carré.

```lua
-- MiseEnScene : barre de commande de Studio, place Zsurvie_Vignettes uniquement
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))

local function couleur(nom: string, secours: string): Color3
	local valeur = Charte[nom]
	return if typeof(valeur) == "Color3" then valeur else Color3.fromHex(secours)
end

local MAISON = Vector3.new(0, 7, 0)
local PLATEAU = Vector3.new(300, 0, 0)

local PRESETS = {
	V1_Colosse = { heure = 17.5, cam = Vector3.new(-40, 6, 48), cible = Vector3.new(-4, 14, -10), fov = 40, sat = 0.3, bloom = 0.6 },
	V2_Horde = { heure = 14, cam = Vector3.new(0, 45, 28), cible = Vector3.zero, fov = 50, sat = 0.25, bloom = 0.3 },
	V3_Avant = { heure = 9, cam = Vector3.new(26, 14, 30), cible = MAISON, fov = 45, sat = -0.2, bloom = 0.2 },
	V3_Apres = { heure = 13, cam = Vector3.new(26, 14, 30), cible = MAISON, fov = 45, sat = 0.3, bloom = 0.5 },
	I1_Zbire = { heure = 13, cam = PLATEAU + Vector3.new(0, 4, 9), cible = PLATEAU + Vector3.new(0, 3, 0), fov = 30, sat = 0.3, bloom = 0.2, flou = true },
	I2_Maison = { heure = 13, cam = PLATEAU + Vector3.new(18, 26, 18), cible = PLATEAU + MAISON, fov = 35, sat = 0.3, bloom = 0.3 },
}

local function obtenir(classe: string, nom: string): any
	local existant = Lighting:FindFirstChild(nom)
	if existant and existant:IsA(classe) then
		return existant
	end
	local nouveau = Instance.new(classe)
	nouveau.Name = nom
	nouveau.Parent = Lighting
	return nouveau
end

local function afficherGuide(icone: boolean)
	local ancien = StarterGui:FindFirstChild("GuideCadrage")
	if ancien then
		ancien:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "GuideCadrage"
	gui.IgnoreGuiInset = true
	local zone = Instance.new("Frame")
	zone.BackgroundTransparency = 1
	zone.AnchorPoint = Vector2.new(0.5, 0.5)
	if icone then
		zone.Size = UDim2.fromScale(0.8, 0.8) -- 410 px utiles sur 512
		zone.Position = UDim2.fromScale(0.5, 0.5)
		local ratio = Instance.new("UIAspectRatioConstraint")
		ratio.AspectRatio = 1
		ratio.DominantAxis = Enum.DominantAxis.Height
		ratio.Parent = zone
		local coins = Instance.new("UICorner")
		coins.CornerRadius = UDim.new(0.18, 0)
		coins.Parent = zone
	else
		zone.Size = UDim2.fromScale(0.9, 0.8) -- marges de 5 %, 15 % en bas
		zone.Position = UDim2.fromScale(0.5, 0.45)
	end
	local trait = Instance.new("UIStroke")
	trait.Color = couleur("Alerte", "FF2E63")
	trait.Thickness = 2
	trait.Parent = zone
	zone.Parent = gui
	gui.Parent = StarterGui
end

local function appliquer(nomPreset: string)
	local p = PRESETS[nomPreset]
	assert(p, "Preset inconnu : " .. nomPreset)

	Lighting.ClockTime = p.heure
	Lighting.Brightness = 3
	Lighting.OutdoorAmbient = couleur("NuitLabo", "2A3263"):Lerp(couleur("Creme", "F6E7C1"), 0.6)

	local correction = obtenir("ColorCorrectionEffect", "VignetteCouleur")
	correction.Saturation = p.sat
	correction.Contrast = 0.12
	correction.TintColor = Color3.new(1, 1, 1):Lerp(couleur("Creme", "F6E7C1"), 0.2)

	local bloom = obtenir("BloomEffect", "VignetteBloom")
	bloom.Intensity = p.bloom
	bloom.Size = 24
	bloom.Threshold = 0.9

	local flou = obtenir("DepthOfFieldEffect", "VignetteFlou")
	flou.Enabled = p.flou == true
	flou.FocusDistance = (p.cam - p.cible).Magnitude
	flou.InFocusRadius = 6
	flou.NearIntensity = 0
	flou.FarIntensity = 0.5

	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = p.fov
	camera.CFrame = CFrame.lookAt(p.cam, p.cible)

	afficherGuide(string.sub(nomPreset, 1, 1) == "I")
end

appliquer("V1_Colosse") -- avant la capture : StarterGui.GuideCadrage:Destroy()
```

- **Particules :** lancer la simulation (F8, Exécuter), puis passer `ParticleEmitter.TimeScale` à 0 pour figer l'éclat des cubes et des pièces.
- **Caméras :** les valeurs ci-dessus sont un point de départ. Elles s'ajustent de ±5 studs une fois connue l'échelle finale du Colosse.

### ✍️ Rédactrice de fiche jeu — Zoé Quimper
# Zsurvie : fiche du jeu (page Roblox)

## 1. Titre : 5 propositions

Limite Roblox : 50 caractères. « Zsurvie » (nom officiel) ouvre toujours le titre ; le suffixe porte la requête de recherche. Titre EN saisi à la main dans Creator Hub > Localisation > Informations de l'expérience.

| # | Titre FR | Titre EN | Car. FR/EN | Requêtes | Usage |
|---|---|---|---|---|---|
| 1 | Zsurvie | Zsurvie | 7/7 | marque | Quand le nom sera connu |
| 2 | Zsurvie : Défends la Maison ! | Zsurvie: Defend the House! | 29/26 | maison, house | Test à J+21 |
| 3 | **Zsurvie : Défense en Coop** | **Zsurvie: Co-op Defense** | 25/22 | défense, coop, defense, co-op | **Lancement** |
| 4 | Zsurvie : Tower Defense en Mouvement | Zsurvie: Tower Defense on the Move | 36/34 | tower defense | Réserve (attire des fans de TD immobile) |
| 5 | Zsurvie : Survis à la Horde ! | Zsurvie: Survive the Horde! | 29/27 | survie, horde, survive | Réserve (temps fort Colosse) |

**Lancement : n° 3.** « Défense » et « coop » sont des requêtes courtes, tapées telles quelles par les 9-13 ans. À J+21, le n° 2 le remplace 2 semaines ; on garde le titre au meilleur taux de clic de la source « Recherche » (Analytics > Acquisition).

## 2. Description française (903 / 1 000 caractères)

Sur téléphone, 2 ou 3 lignes s'affichent avant « Voir plus » : la première phrase vend le jeu. Les 97 caractères libres accueillent la ligne de mise à jour (§ 7).

```text
Défends la Maison avec jusqu'à 6 amis ! Chaque jour, des hordes de Zbires, petits monstres rigolos, surgissent de la Lisière. Cours, tire au Blaster, répare et pose Murets, Mini-Tourelles et Tapis Collants.

- 8 Zbires à déjouer : le Gluant se divise, le Volant survole les Murets, le Casqué résiste sauf aux coups critiques.
- Tous les 5 jours, le boss Colosse attaque !
- Dépense tes Pièces en améliorations à l'Établi : Dégâts, Cadence, Portée, Balles explosives…
- Quand la Maison tombe, tes Gemmes deviennent des recherches permanentes au Laboratoire.
- Reviens chaque jour : Défi du Jour, Foreuse qui mine des Gemmes hors connexion, Zbire de la Semaine le samedi à 17 h (heure de Paris).

Défense en coop, jamais de PvP. On ne meurt jamais : un coup étourdit 2 secondes. Roue des Pings pour jouer sans chat. Tir automatique sur mobile.

Un tower defense de survie où l'arme principale, c'est toi !
```

## 3. Description anglaise (≈ 870 / 1 000 caractères)

```text
Defend the House with up to 6 friends! Every day, hordes of Zbires, silly little monsters, pour out of the Treeline. Run, shoot your Blaster, repair and place Low Walls, Mini-Turrets and Sticky Mats.

- 8 Zbires to outsmart: the Slime splits in two, the Flyer soars over Low Walls, the Helmet resists all but critical hits.
- Every 5 days, the Colossus boss attacks!
- Spend your Coins on upgrades at the Workbench: Damage, Fire Rate, Range, Explosive Rounds…
- When the House falls, your Gems become permanent research in the Lab.
- Come back every day: Daily Challenge, a Drill that mines Gems while you're offline, Zbire of the Week every Saturday at 5 PM (Paris time).

Co-op defense, never PvP. You never die: a hit stuns you for 2 seconds. Use the Ping Wheel to play without chat. Auto-shoot on mobile.

A survival tower defense where YOU are the main weapon!
```

## 4. Mots-clés de recherche

Roblox n'a pas de champ « mots-clés » : la recherche lit le titre et la description dans la langue du joueur, puis classe selon l'engagement. Chaque mot-clé apparaît une ou deux fois, dans une vraie phrase.

| Priorité | EN | FR | Placement |
|---|---|---|---|
| 1 | defense, co-op | défense, coop | Titre n° 3, description |
| 1 | tower defense | tower defense | Dernière ligne |
| 2 | survival, horde | survie, hordes | Ligne 1, dernière ligne |
| 2 | monsters, boss | monstres, boss | Ligne 1, puce Colosse |
| 3 | upgrades, house | améliorations, maison | Puce Établi, ligne 1 |
| 3 | Zsurvie, Zbires | Zsurvie, Zbires | Partout (marque) |

**Exclus :** « zombie » (les Zbires n'en sont pas, et le mot tire vers l'horreur interdite par le canon), « horror », « simulator », « idle », « tycoon », « free robux », tout nom d'une autre expérience. Pas de liste « Tags : … » en fin de description : c'est du bourrage de métadonnées, sanctionnable par la modération.

## 5. Genre et paramètres recommandés

| Paramètre (Creator Hub) | Valeur |
|---|---|
| Genre | Stratégie > Tower Defense ; vérifier après publication le couple affiché. Shooter > PvE Shooter écarté (public plus âgé) |
| Place de départ | Laboratoire, `MaxPlayers` 12 |
| Remplissage des serveurs | Laboratoire : personnalisé, 2 places réservées pour qu'un ami puisse toujours rejoindre |
| Place Prairie | `MaxPlayers` 6, via `TeleportService:ReserveServer` uniquement ; accès direct aux places secondaires désactivé |
| Appareils | Téléphone, Tablette, Ordinateur : oui. Console, VR : non |
| Maturité | Questionnaire rempli pour **Léger (Mild)** : violence cartoon, ni sang ni horreur |
| Langue source | Français ; nom et description EN saisis à la main |
| Chat vocal | Désactivé (la Roue des Pings suffit) |
| Serveurs privés | Activés, 100 Robux/mois proposé (à valider par la Monétisation) |
| Liens sociaux | Groupe Roblox du studio seul ; pas de Discord, masqué aux moins de 13 ans |
| Événements | « Zbire de la Semaine » : Événement d'expérience récurrent, samedi 17:00, Europe/Paris |

## 6. Localisation

- **Gardés tels quels en anglais :** Zsurvie, Zbires, Doc Boulon, Blaster (marques). **Écart à valider par Victor Lanoue :** les autres noms officiels sont traduits (table ci-dessous).
- **Visuels :** icône 512 × 512 sans texte ; toute vignette avec texte existe en FR et en EN (Localisation > Images).
- **ES et PT-BR :** nom et description saisis en v1.1 depuis ce glossaire ; prévoir 30 % de longueur en plus dans l'UI.
- **Une table pour la page et le jeu :** le joueur lit dans l'UI les mots de la fiche.

```lua
-- Barre de commande de Studio : une fois par place (Laboratoire, Prairie), puis publier.
-- Crée LocalizationService.Canon : noms officiels fr -> en.
local LocalizationService = game:GetService("LocalizationService")

local CANON: { { string } } = {
	-- { clé, source fr, traduction en }
	{ "jeu.nom", "Zsurvie", "Zsurvie" },
	{ "monnaie.pieces", "Pièces", "Coins" },
	{ "monnaie.gemmes", "Gemmes", "Gems" },
	{ "joueur.survivant", "Survivant", "Survivor" },
	{ "joueur.blaster", "Blaster", "Blaster" },
	{ "joueur.sac", "Sac à dos", "Backpack" },
	{ "pnj.doc", "Doc Boulon", "Doc Boulon" },
	{ "zone.laboratoire", "Laboratoire", "Lab" },
	{ "zone.quai", "Quai des Capsules", "Capsule Dock" },
	{ "zone.galerie", "Galerie des Zbires", "Zbire Gallery" },
	{ "zone.alcove", "Alcôve", "Alcove" },
	{ "zone.maison", "Maison", "House" },
	{ "zone.mine", "Mine", "Mine" },
	{ "zone.prairie", "Prairie", "Meadow" },
	{ "zone.lisiere", "Lisière", "Treeline" },
	{ "lieu.etabli", "Établi", "Workbench" },
	{ "zbire.marcheur", "Marcheur", "Walker" },
	{ "zbire.rapide", "Rapide", "Speedy" },
	{ "zbire.costaud", "Costaud", "Brute" },
	{ "zbire.dore", "Doré", "Golden" },
	{ "zbire.sauteur", "Sauteur", "Hopper" },
	{ "zbire.gluant", "Gluant", "Slime" },
	{ "zbire.minigluant", "Mini-Gluant", "Mini-Slime" },
	{ "zbire.volant", "Volant", "Flyer" },
	{ "zbire.casque", "Casqué", "Helmet" },
	{ "zbire.colosse", "Colosse", "Colossus" },
	{ "defense.muret", "Muret", "Low Wall" },
	{ "defense.tourelle", "Mini-Tourelle", "Mini-Turret" },
	{ "defense.tapis", "Tapis Collant", "Sticky Mat" },
	{ "amelio.degats", "Dégâts", "Damage" },
	{ "amelio.cadence", "Cadence", "Fire Rate" },
	{ "amelio.portee", "Portée", "Range" },
	{ "amelio.solidite", "Solidité", "Toughness" },
	{ "amelio.reparation", "Réparation", "Repair" },
	{ "amelio.regeneration", "Régénération", "Regen" },
	{ "amelio.butin", "Butin", "Loot" },
	{ "amelio.explosives", "Balles explosives", "Explosive Rounds" },
	{ "recherche.toit", "Tourelle de toit", "Roof Turret" },
	{ "recherche.perforantes", "Balles perforantes", "Piercing Rounds" },
	{ "recherche.critique", "Visée critique", "Critical Aim" },
	{ "recherche.foreuse", "Foreuse", "Drill" },
	{ "capsule.normale", "Capsule Normale", "Normal Capsule" },
	{ "capsule.difficile", "Capsule Difficile", "Hard Capsule" },
	{ "capsule.jour", "Capsule du Jour", "Daily Capsule" },
	{ "rdv.defi", "Défi du Jour", "Daily Challenge" },
	{ "rdv.semaine", "Zbire de la Semaine", "Zbire of the Week" },
	{ "ping.roue", "Roue des Pings", "Ping Wheel" },
	{ "ping.colosse", "Colosse !", "Colossus!" },
	{ "ping.repare", "Répare !", "Repair!" },
	{ "ping.ici", "Ici !", "Over here!" },
	{ "ping.merci", "Merci !", "Thanks!" },
	{ "maison.record", "Record : Jour {1}", "Record: Day {1}" },
}

local tableCanon = LocalizationService:FindFirstChild("Canon") or Instance.new("LocalizationTable")
tableCanon.Name = "Canon"
tableCanon.SourceLocaleId = "fr"

local entrees = table.create(#CANON)
for _, terme in CANON do
	table.insert(entrees, {
		Key = terme[1],
		Source = terme[2],
		Context = "",
		Example = "",
		Values = { en = terme[3] },
	})
end

tableCanon:SetEntries(entrees)
tableCanon.Parent = LocalizationService
print(`Canon : {#entrees} termes fr -> en`)
```

Les `TextLabel` en `AutoLocalize = true` se traduisent seuls. Les textes à paramètre passent par `LocalizationService:GetTranslatorForPlayerAsync(player)` puis `translator:FormatByKey("maison.record", { jour })`.

## 7. Textes des premières mises à jour

**Règle :** 7 jours de tag « [MAJ] » / « [UPDATE] » dans le titre (31 caractères avec le n° 3) et d'une ligne MAJ en tête de description, puis retrait. Le même texte s'affiche sur le panneau « Nouveautés » de Doc Boulon au Laboratoire.

| Version | Ligne de description FR / EN | Panneau Doc Boulon FR / EN |
|---|---|---|
| **v1.0 Lancement** (J0, sans tag) | Aucune | « Bienvenue, Survivant ! Monte dans la Capsule Normale. Tiens bon jusqu'au jour 5 : le Colosse arrive ! » / "Welcome, Survivor! Hop into the Normal Capsule. Hold on until day 5: the Colossus is coming!" |
| **v1.1 Premier Zbire de la Semaine** (1er samedi) | « MAJ : 1er Zbire de la Semaine, samedi 17 h ! » (44 car.) / "UPDATE: 1st Zbire of the Week, Saturday 5 PM!" | « Samedi 17 h (heure de Paris) : le Zbire de la Semaine débarque sur la Prairie ! Suis l'Événement sur la page du jeu. » / "Saturday 5 PM (Paris time): the Zbire of the Week lands on the Meadow! Follow the Event on the game page." |
| **v1.2 Nouveaux défis** (J+14) | « MAJ : nouveaux modificateurs pour le Défi du Jour ! » / "UPDATE: new modifiers for the Daily Challenge!" | « Doc Boulon invente de nouvelles règles : {modificateur A}, {modificateur B}. Toujours 150 Gemmes à gagner ! » / "Doc Boulon invented new rules: {modifier A}, {modifier B}. Still 150 Gems to win!" |

Les accolades sont remplies par le game design. Aucune nouveauté hors canon ne part sans l'accord du directeur créatif.

### 🎉 Designer d'événements — Ambroise Feld
## Cadre

- **Lancement de référence : vendredi 16 octobre 2026, 17 h (Paris)**, veille des vacances de la Toussaint. 13 semaines, du vendredi au jeudi, jusqu'au 14 janvier 2027.
- **Si le lancement glisse après le 23 octobre**, La Nuit des Citrouilles passe en réserve pour 2027 ; décembre garde ses vraies dates.
- **Publication le jeudi à 10 h**, jamais le vendredi. Les événements s'allument seuls par l'horloge serveur (`ReplicatedStorage.CalendrierLiveOps`), sans republier.
- **Gel du code du 17 déc. au 4 janv.** : correctifs critiques seulement.

## Calendrier des 13 semaines

| Sem. | Dates | Mise à jour (jeudi précédent) | Événement / week-end bonus | Zbire de la Semaine (sam. 17 h) |
|---|---|---|---|---|
| S1 | 16-22 oct. | **v1.0** (ven. 16) | x2 Gemmes de lancement | Gluant |
| S2 | 23-29 oct. | **v1.1** : correctifs + Halloween | **La Nuit des Citrouilles** | Volant |
| S3 | 30 oct.-5 nov. | — | Nuit des Citrouilles (fin lun. 2 nov.) | Colosse-Citrouille |
| S4 | 6-12 nov. | — | x2 Galerie | Casqué |
| S5 | 13-19 nov. | **v1.2 Les Inventions** | x2 Gemmes | Rapide |
| S6 | 20-26 nov. | — | aucun (semaine témoin) | Sauteur |
| S7 | 27 nov.-3 déc. | **v1.3** : paquet Noël | x2 Galerie ; **Avent** dès le 1er déc. | Costaud |
| S8 | 4-10 déc. | — | Avent | Doré |
| S9 | 11-17 déc. | v1.3.1 correctifs | Avent + x2 Gemmes | Marcheur |
| S10 | 18-24 déc. | gel | **Le Grand Givre** + Avent | Colosse de Neige |
| S11 | 25-31 déc. | gel | Grand Givre + Nouvel An | Gluant |
| S12 | 1-7 janv. | — | Grand Givre (fin lun. 4 janv.) | Volant |
| S13 | 8-14 janv. | **v1.4 Missions** | x2 Gemmes de rentrée | Casqué |

## Les événements

### Week-end de lancement (x2 Gemmes)
- **Contenu :** gemmes doublées (Mine, Doré, jours franchis), bannière sur le Quai des Capsules.
- **Durée :** ven. 16 oct. 17 h → lun. 19 oct. 0 h.
- **Objectif :** D1 ≥ 30 % ; 70 % des nouveaux lancent une recherche dès la 1re session.

### La Nuit des Citrouilles (Halloween)
- **Durée :** ven. 23 oct. 17 h → lun. 2 nov. 23 h 59 (10 jours de vacances).
- **Prairie de nuit, mystérieuse sans faire peur :** `Lighting.ClockTime` 19,5, `Ambient` #4A4560, `OutdoorAmbient` #535676 ; 8 lanternes-citrouilles orange autour de la Maison (16 Parts `Neon`, 4 `PointLight` `Range` 16, `Brightness` 1,2). Chiptune sautillante, ni cri ni brouillard noir.
- **Zbires coiffés d'une citrouille violette** (4 Parts de plus, 30 au total), règles inchangées ; Colosse-Citrouille le Jour du Colosse.
- **Citrouilles dorées :** 3 par horde (6 dans la Capsule du Jour), 3 × 3 × 3 studs, 40 PV × coefficient coop, entre 20 et 60 studs de la Maison. Éclatée : 15 pièces à chaque Survivant et +1 au compteur de toute l'équipe.
- **Paliers** (60 citrouilles comptées par jour au plus) : 20 titre « Chasseur de citrouilles », 60 Blaster-Citrouille, 120 costume « Épouvantail rigolo », 200 Citrouille géante d'Alcôve, 300 variantes Halloween de la Galerie.
- **Objectif :** 35 % des participants jouent au moins 3 jours distincts ; D7 de la cohorte de lancement ≥ 12 %.

### v1.2 Les Inventions
- **Contenu :** recherche « Aimant à Pièces » (+4 studs de ramassage par niveau, 3 niveaux : moins de course au doigt sur mobile) ; modificateurs du Défi du Jour « Pluie de Dorés », « Jour express » (hordes de 60 s), « Rebonds » (Sauteurs × 2), « Blindage » (Casqués × 2).
- **Objectif :** réactiver 10 % des inactifs depuis 7 jours, aidés par le x2 Gemmes du 13 au 15 nov.

### L'Avent de Doc Boulon
- **Durée :** mar. 1er déc. → lun. 4 janv.
- **Contenu :** mur de 24 cases de 4 × 4 studs derrière Doc Boulon. Une case par jour où l'on termine une run : on compte les jours joués, pas les dates, donc on rattrape jusqu'au 4 janvier. Récompenses fixes et affichées, jamais tirées au sort : 20 cases à 50 gemmes ; cases 6, 12 et 18 = écharpe, bonnet, Blaster « Canon à neige » ; case 24 = Sapin-bloc animé d'Alcôve.
- **Objectif :** 25 % des joueurs de décembre ouvrent au moins 12 cases ; DAU/MAU ≥ 18 %.

### Le Grand Givre (Noël)
- **Durée :** ven. 18 déc. 17 h → lun. 4 janv. 23 h 59 (17 jours).
- **Prairie enneigée :** les Parts taguées `SolPrairie` (`CollectionService`) passent de #6CC24A à Crème #F6E7C1 ; les chemins restent en Terre battue. Flocons : 1 `ParticleEmitter` client, `Rate` 12. Zbires en bonnet violet, Colosse de Neige.
- **Cadeaux perdus :** 2 par horde, entre 25 et 50 studs de la Maison. On les ramasse en passant à moins de 4 studs (aucun bouton), on les porte (vitesse × 0,85) jusqu'à 10 studs de la Maison : 25 pièces par Survivant, +1 au compteur d'équipe. Étourdi, on lâche le cadeau.
- **Paliers** (50 par jour au plus) : 20 titre « Lutin de la Prairie », 60 costume « Survivant Givré », 120 Traîneau-bloc d'Alcôve, 180 Blaster-Sucre d'orge, 250 variantes Hiver de la Galerie.
- **Nouvel An** (31 déc. 23 h → 1er janv. 1 h) : compte à rebours sur le Quai des Capsules et dans le HUD, 4 `ParticleEmitter` de feu d'artifice (`Rate` 20) au-dessus du Laboratoire.
- **Objectif :** joueurs quotidiens des vacances ≥ 1,5 × la moyenne de novembre ; 30 % des participants atteignent 250.

### v1.4 Les missions du Zbire de la Semaine
- **Contenu :** 3 missions renouvelées chaque samedi à 17 h (ex. « 150 Casqués éliminés par coup critique »), 100 gemmes chacune.
- **Objectif :** D30 de la cohorte d'octobre ≥ 5 %.

## Règles des week-ends bonus

- **Vendredi 17 h → lundi 0 h (Paris).** x2 Gemmes : Mine, Doré, jours franchis ; Foreuse, Défi du Jour et Avent restent fixes. x2 Galerie : chaque élimination compte double vers les paliers 10 / 100 / 1 000.
- **Jamais** pendant un événement saisonnier, jamais deux x2 Gemmes d'affilée, au moins un week-end sans bonus par mois.
- **Annonce :** bannière au Laboratoire dès le jeudi, « Événement de l'expérience » sur le Creator Hub, notification via `ExperienceNotificationService` (opt-in proposé après la 2e run si `CanPromptOptInAsync` le permet).

## Garde-fous 9-15 ans

- Plafonds journaliers : dernier palier en 5 jours de jeu, pas de session marathon.
- Aucun palier vendu en Robux ; 1 pack cosmétique Robux par événement au plus.
- Pas de compte à rebours alarmiste : #FF2E63 reste le danger en jeu. Widget d'événement : barre de 220 × 36 px en haut du HUD, bouton de 60 px.

## Implémentation

Les deux modules forment un Package (`AutoUpdate`) partagé par le Laboratoire et la Prairie. Les compteurs d'événement partent avec les gemmes, dans le même `UpdateAsync`, à chaque jour franchi ; paliers journalisés par `AnalyticsService:LogCustomEvent`. Le service de la Galerie lit `LiveOps_MultGalerie` côté serveur.

```lua
-- ReplicatedStorage.CalendrierLiveOps (ModuleScript) : dates saisies en heure de Paris
local EVENEMENTS = { -- { id, genre, début, fin }
	{ "Lancement", "DoubleGemmes", "2026-10-16T17", "2026-10-19T00" },
	{ "NuitDesCitrouilles", "Saison", "2026-10-23T17", "2026-11-03T00" },
	{ "Galerie1", "DoubleGalerie", "2026-11-06T17", "2026-11-09T00" },
	{ "Inventions", "DoubleGemmes", "2026-11-13T17", "2026-11-16T00" },
	{ "Galerie2", "DoubleGalerie", "2026-11-27T17", "2026-11-30T00" },
	{ "AventDocBoulon", "Avent", "2026-12-01T00", "2027-01-05T00" },
	{ "Decembre", "DoubleGemmes", "2026-12-11T17", "2026-12-14T00" },
	{ "GrandGivre", "Saison", "2026-12-18T17", "2027-01-05T00" },
	{ "NouvelAn", "Fete", "2026-12-31T23", "2027-01-01T01" },
	{ "Rentree", "DoubleGemmes", "2027-01-08T17", "2027-01-11T00" },
}

local function dernierDimanche(annee: number, mois: number): number
	local d = os.date("!*t", os.time({ year = annee, month = mois + 1, day = 1, hour = 12 }) - 86400)
	return d.day - (d.wday - 1) -- wday 1 = dimanche
end

-- "AAAA-MM-JJTHH" (Paris) -> horodatage UTC ; heure d'été du dernier dimanche de mars à celui d'octobre
local function versUtc(texte: string): number
	local a, m, j, h = texte:match("^(%d+)-(%d+)-(%d+)T(%d+)$")
	local annee, mois, jour, heure = tonumber(a), tonumber(m), tonumber(j), tonumber(h)
	assert(annee and mois and jour and heure, "Date invalide : " .. texte)
	local t = os.time({ year = annee, month = mois, day = jour, hour = heure })
	local ete = t >= os.time({ year = annee, month = 3, day = dernierDimanche(annee, 3), hour = 1 })
		and t < os.time({ year = annee, month = 10, day = dernierDimanche(annee, 10), hour = 1 })
	return t - (if ete then 7200 else 3600)
end

local calendrier = {}
for i, e in EVENEMENTS do
	calendrier[i] = { id = e[1], genre = e[2], debut = versUtc(e[3]), fin = versUtc(e[4]) }
end
return calendrier
```

```lua
-- ServerScriptService.LiveOps (ModuleScript) : seul le serveur applique les bonus
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Calendrier = require(ReplicatedStorage.CalendrierLiveOps)

local LiveOps = {}
local SOURCES_DOUBLEES = { Mine = true, Dore = true, Jour = true } -- ni Foreuse, ni Défi du Jour, ni Avent

local function actualiser()
	local t = os.time()
	if RunService:IsStudio() then
		t += workspace:GetAttribute("DecalageTest") or 0 -- QA : avance l'horloge (secondes)
	end
	local etat = { Saison = "", Fete = "", Avent = false, MultGemmes = 1, MultGalerie = 1 }
	for _, ev in Calendrier do
		if t >= ev.debut and t < ev.fin then
			if ev.genre == "Saison" or ev.genre == "Fete" then
				etat[ev.genre] = ev.id
			elseif ev.genre == "Avent" then
				etat.Avent = true
			elseif ev.genre == "DoubleGemmes" then
				etat.MultGemmes = 2
			elseif ev.genre == "DoubleGalerie" then
				etat.MultGalerie = 2
			end
		end
	end
	for nom, valeur in etat do
		workspace:SetAttribute("LiveOps_" .. nom, valeur) -- répliqué pour l'affichage client
	end
end

-- Appelé par le service d'économie avant chaque crédit de gemmes
function LiveOps.gemmesAvecBonus(base: number, source: string): number
	local mult = if SOURCES_DOUBLEES[source] then workspace:GetAttribute("LiveOps_MultGemmes") or 1 else 1
	return math.floor(base * mult)
end

actualiser()
task.spawn(function()
	while true do
		task.wait(30)
		actualiser()
	end
end)

return LiveOps
```

**QA :** régler `DecalageTest` pour franchir chaque bascule, dont le passage à l'heure d'hiver du 25 octobre ; chaque fin d'événement doit remettre les multiplicateurs à 1 en moins de 30 s.

## Écarts au canon (validation de Victor Lanoue requise)

- Ajouts : recherche « Aimant à Pièces » ; missions hebdomadaires rattachées au Zbire de la Semaine, sans nouveau rendez-vous.
- Nouveaux noms : La Nuit des Citrouilles, L'Avent de Doc Boulon, Le Grand Givre, Colosse-Citrouille, Colosse de Neige (skins aux règles inchangées). Les ambiances saisonnières sont des états de la Prairie, comme le Jour du Colosse.

### 📉 Analyste de données — Livia Roseau
# Zsurvie : données, rétention et entonnoirs

*Livia Roseau, analyste de données. Chaque vue se lit d'abord filtrée sur « Téléphone ».*

## 1. Indicateurs suivis

| Indicateur | Creator Dashboard | Question posée |
|---|---|---|
| Visites, nouveaux joueurs, DAU, pic de CCU | Acquisition, Engagement | Attire-t-on ? Pic du samedi 17 h = Zbire de la Semaine |
| QPTR, clics sur recommandations | Acquisition | Icône et vignettes efficaces ? |
| Rétention J1 / J7 / J30 | Retention | Revient-on chaque jour ? |
| Durée de session | Engagement | Tient-on 20 à 35 min ? |
| Conversion payeur, ARPDAU | Monetization | Cosmétiques et serveurs privés seulement |
| FPS, mémoire, crashs par appareil | Performance | 30 FPS, < 800 Mo sur Android 3 Go ? |
| Entonnoirs, économie, événements | Analytics | Où décroche-t-on ? |

## 2. Objectifs du premier mois

| Indicateur | Alerte | Cible M1 |
|---|---|---|
| Visites cumulées | < 100 000 | 300 000 |
| DAU moyen, semaines 3-4 | < 1 500 | 4 000 |
| Rétention J1 | < 15 % | 22 % |
| Rétention J7 | < 5 % | 8 % |
| Rétention J30 (cohortes semaine 1) | < 2 % | 3,5 % |
| Session moyenne (rebonds compris) | < 12 min | 18 min |
| Durée médiane d'une run | < 10 ou > 20 min | 12 à 18 min |
| Runs de plus de 25 min | > 5 % | ≤ 2 % |
| Premières runs qui voient le Colosse | < 55 % | 70 % |
| Runs à 2 Survivants ou plus | < 45 % | 60 % |
| Survivants qui quittent en cours de run | > 30 % | ≤ 18 % |
| Échecs de téléportation Capsule → Prairie | > 2 % | ≤ 0,5 % |
| DAU jouant le Défi du Jour | < 15 % | 25 % |
| Revenants J1 qui récoltent la Foreuse | < 40 % | 60 % |
| Conversion payeur | < 0,5 % | 1,2 % |

## 3. Entonnoirs à surveiller

### 3.1 Accueil : `LogOnboardingFunnelStepEvent`

La dernière étape franchie vit dans le profil (clé `accueilEtape`, exposée en attribut `AccueilEtape`) : aucune étape n'est relogguée et un saut d'étape ne bloque rien. Doc Boulon impose l'ordre : il demande la première défense au Répit du Jour 2.

| # | Étape | Place | Déclencheur serveur | Cible cumulée |
|---|---|---|---|---|
| 1 | ArriveeLabo | Laboratoire | `PlayerAdded`, profil neuf | 100 % |
| 2 | DocBoulonParle | Laboratoire | fin du dialogue d'accueil | 92 % |
| 3 | CapsuleMontee | Laboratoire | place validée dans une Capsule | 86 % |
| 4 | ArriveePrairie | Prairie | `PlayerAdded` du serveur réservé | 81 % |
| 5 | PremierZbire | Prairie | premier Zbire éliminé | 79 % |
| 6 | PremierAchatEtabli | Prairie | premier achat validé | 68 % |
| 7 | PremiereDefense | Prairie | Muret, Mini-Tourelle ou Tapis Collant posé | 62 % |
| 8 | ColosseVu | Prairie | début du Jour 5 | 57 % |
| 9 | MaisonTombee | Prairie | fin de la première run | 54 % |
| 10 | RetourLabo | Laboratoire | arrivée après une run | 50 % |
| 11 | PremiereRecherche | Laboratoire | première recherche payée | 43 % |
| 12 | DeuxiemeCapsule | Laboratoire | deuxième départ en Capsule | 36 % |

### 3.2 Visite du Laboratoire : `LogFunnelStepEvent("VisiteLabo", guid)`

Un `HttpService:GenerateGUID(false)` par arrivée. 1 Arrivée (champ provenance : `nouveau`, `fin_run`, `retour`) → 2 Arbre des Recherches ouvert → 3 Recherche lancée → 4 Capsule montée → 5 Capsule partie. Cible : 75 % de 1 à 5, entre 3 et 5 min au Laboratoire.

### 3.3 Run : `LogFunnelStepEvent("Run", game.JobId)`

1 Arrivée → 2 Jour 1 franchi → 3 Jour 3 → 4 Jour 5 (Colosse) → 5 Jour 6 (Colosse survécu) → 6 Jour 10 → 7 Jour 15. Lu par mode et par taille d'équipe. La plus grosse marche doit être 4 → 5 : le Colosse est le mur voulu. Plus de 25 % de perte entre 1 et 3 signale un début de run raté. Le mode est lu côté serveur (config de run en `MemoryStoreService`, clé `game.PrivateServerId`), jamais depuis la `TeleportData`.

### 3.4 Boutique : `LogFunnelStepEvent("Boutique", guid)`

1 Boutique ouverte → 2 Aperçu dans l'Alcôve → 3 Invite `MarketplaceService` → 4 Achat confirmé (`ProcessReceipt`, `PromptGamePassPurchaseFinished`). Les étapes 1-2 arrivent par un `RemoteEvent` limité à 1 requête par seconde ; aucune récompense n'en dépend.

## 4. Plan de marquage

Trois champs personnalisés au maximum, toujours en tranches : mode (`Normale`, `Difficile`, `Jour`), équipe (`solo`, `2-3`, `4-6`), jour (`J1-4`, `J5-9`, `J10-14`, `J15+`), durée (`<12`, `12-18`, `18-25`, `>25` min). Identifiants techniques sans accents.

| Événement | Valeur | Champs | Moment |
|---|---|---|---|
| `RunFin` | jour atteint | mode, équipe, durée | Maison tombée, par Survivant présent |
| `RunQuitte` | jour en cours | mode, jour, état de la Maison | `PlayerRemoving` avant la fin |
| `Colosse` | jour | `vaincu` / `maison_tombee`, équipe | fin de chaque combat |
| `PingsRun`, `DefensesRun`, `EtourdiRun` | nombre | équipe | fin de run (pilier 2) |
| `CapsulePartie` | secondes au Labo | mode, équipe | départ de Capsule |
| `TeleportEchec` | 1 | `Enum.TeleportResult` | `TeleportService.TeleportInitFailed` |
| `ForeuseRecolte` | gemmes | `<2h`, `2-8h`, `plafond` | récolte au Labo |
| `DefiDuJour`, `ZbireSemaine` | jour atteint | `reussi` / `echoue` | fin de run concernée |
| `GalerieVariante` | palier 10 / 100 / 1 000 | Zbire | déblocage |

Économie (`LogEconomyEvent`) :
- **Pièces**, source `Horde` cumulée par jour ; puits = amélioration achetée à l'Établi (`Degats`… `BallesExplosives`) ; reliquat perdu en fin de run (`PerteFinRun`), signe d'un Établi sous-utilisé.
- **Gemmes**, sources `Mine`, `Dore` (cumulées par jour), `JourFranchi`, `Foreuse` (`TimedReward`), `DefiDuJour` ; puits = recherche (`TourelleToit`, `BallesPerforantes`, `ViseeCritique`, `Foreuse`).

## 5. Module serveur `Telemetrie`

Seul point d'appel d'`AnalyticsService`, publié en Package dans les deux places. Le client n'émet rien.

```lua
--!strict
-- ServerScriptService.Telemetrie (ModuleScript, Package Laboratoire + Prairie)
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")

local CHAMPS = {
	Enum.AnalyticsCustomFieldKeys.CustomField01.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField02.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField03.Name,
}
local ACCUEIL = {
	"ArriveeLabo", "DocBoulonParle", "CapsuleMontee", "ArriveePrairie",
	"PremierZbire", "PremierAchatEtabli", "PremiereDefense", "ColosseVu",
	"MaisonTombee", "RetourLabo", "PremiereRecherche", "DeuxiemeCapsule",
}
local GAMEPLAY = Enum.AnalyticsEconomyTransactionType.Gameplay.Name
local BOUTIQUE = Enum.AnalyticsEconomyTransactionType.Shop.Name

local Telemetrie = {}
local cumuls: { [Player]: { [string]: number } } = {}

local function champs(valeurs: { string }?): { [string]: string }?
	if not valeurs then
		return nil
	end
	local t = {}
	for i = 1, math.min(#valeurs, 3) do
		t[CHAMPS[i]] = valeurs[i]
	end
	return t
end

local function appeler(methode: string, ...: any)
	local ok, err = pcall((AnalyticsService :: any)[methode], AnalyticsService, ...)
	if not ok then
		warn(`[Telemetrie] {methode} : {err}`)
	end
end

function Telemetrie.tranche(nature: "equipe" | "jour" | "duree", n: number): string
	if nature == "equipe" then
		return if n <= 1 then "solo" elseif n <= 3 then "2-3" else "4-6"
	elseif nature == "jour" then
		return if n < 5 then "J1-4" elseif n < 10 then "J5-9" elseif n < 15 then "J10-14" else "J15+"
	end
	local minutes = n / 60
	return if minutes < 12 then "<12" elseif minutes < 18 then "12-18" elseif minutes <= 25 then "18-25" else ">25"
end

function Telemetrie.accueil(player: Player, etape: number)
	local derniere = (player:GetAttribute("AccueilEtape") :: number?) or 0
	if etape <= derniere or etape > #ACCUEIL then
		return
	end
	player:SetAttribute("AccueilEtape", etape) -- resauvegardé par le module de profil
	appeler("LogOnboardingFunnelStepEvent", player, etape, ACCUEIL[etape])
end

function Telemetrie.etape(player: Player, entonnoir: string, session: string, etape: number, nom: string, valeurs: { string }?)
	appeler("LogFunnelStepEvent", player, entonnoir, session, etape, nom, champs(valeurs))
end

function Telemetrie.evenement(player: Player, nom: string, valeur: number?, valeurs: { string }?)
	appeler("LogCustomEvent", player, nom, valeur or 1, champs(valeurs))
end

function Telemetrie.source(player: Player, monnaie: string, montant: number, solde: number, sku: string, transaction: string?)
	appeler("LogEconomyEvent", player, Enum.AnalyticsEconomyFlowType.Source, monnaie, montant, solde, transaction or GAMEPLAY, sku)
end

function Telemetrie.depense(player: Player, monnaie: string, montant: number, solde: number, sku: string, transaction: string?)
	appeler("LogEconomyEvent", player, Enum.AnalyticsEconomyFlowType.Sink, monnaie, montant, solde, transaction or BOUTIQUE, sku)
end

-- Gains fréquents (Horde, Mine, Doré) : cumulés, un seul événement par jour.
function Telemetrie.cumuler(player: Player, monnaie: string, sku: string, montant: number)
	local t = cumuls[player] or {}
	cumuls[player] = t
	local cle = `{monnaie}|{sku}`
	t[cle] = (t[cle] or 0) + montant
end

function Telemetrie.fermerJour(player: Player, soldes: { [string]: number })
	local t = cumuls[player]
	if not t then
		return
	end
	cumuls[player] = nil
	for cle, montant in t do
		local monnaie, sku = string.match(cle, "^(%w+)|(%w+)$")
		if monnaie and sku and montant > 0 then
			Telemetrie.source(player, monnaie, montant, soldes[monnaie] or 0, sku)
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	task.delay(10, function()
		cumuls[player] = nil
	end)
end)

return Telemetrie
```

Fin de run sur la Prairie (extrait ; `Players`, `Telemetrie` et le type `EtatRun` sont déclarés en tête du script de run) :

```lua
local function journaliserFinDeRun(etat: EtatRun)
	local equipe = Telemetrie.tranche("equipe", etat.equipeDepart)
	local duree = Telemetrie.tranche("duree", workspace:GetServerTimeNow() - etat.debut)
	for player, s in etat.survivants do
		if player.Parent ~= Players then
			continue
		end
		Telemetrie.fermerJour(player, { Pieces = s.pieces, Gemmes = s.gemmes })
		if s.pieces > 0 then
			Telemetrie.depense(player, "Pieces", s.pieces, 0, "PerteFinRun", Enum.AnalyticsEconomyTransactionType.Gameplay.Name)
		end
		Telemetrie.evenement(player, "RunFin", etat.jour, { etat.mode, equipe, duree })
		Telemetrie.evenement(player, "PingsRun", s.pings, { equipe })
		Telemetrie.accueil(player, 9)
	end
end
```

## 6. Lire un décrochage

| Symptôme | Cause probable | Levier dans Studio |
|---|---|---|
| Perte 3 → 4 > 8 % | attente de 15 s, téléportation ratée | départ immédiat si Capsule pleine, 3 essais de `TeleportAsync` |
| Perte 4 → 5 > 5 % | tir auto ou caméra illisibles sur téléphone | vérifier rayon de 40 studs, boutons ≥ 60 px |
| Perte 5 → 6 > 15 % | Établi introuvable | flèche de Doc Boulon au premier Répit |
| `RunQuitte` concentré sur `J1-4` | début trop lent | horde du Jour 1 plus dense |
| `Colosse` perdu > 70 % en solo | PV mal réglés à 1 joueur | revoir les PV du Colosse en solo |
| `PerteFinRun` élevée | Établi trop loin ou trop cher | baisser le premier palier |
| J1 correct, J7 faible | Foreuse et Défi du Jour peu visibles | compteur de Foreuse dans l'Alcôve, Défi affiché sur la Capsule du Jour |

## 7. Rituel

- **Chaque matin (10 min) :** J1 de la veille, accueil sur téléphone, `TeleportEchec`, runs de plus de 25 min.
- **Chaque lundi :** les 3 plus grosses marches de décrochage, une recommandation chiffrée par marche, envoyées au gameplay et au Live Ops.
- **Règles :** on ne renumérote jamais une étape et on ne renomme aucun événement après le lancement. Le marquage se valide sur une version publiée privée. Prévoir environ un jour de délai d'affichage.

## 🧪 Revue QA

### 🎮 Testeur gameplay — Noé Charlier
# Relecture joueur : première session de Zsurvie

*Noé Charlier, QA & Équilibrage. Novice sur un Android 3 Go, en paysage : Laboratoire, run en solo, retour, puis run à 3. Bilan : 4 bloquants, 12 majeurs, 4 mineurs.*

## 1. Atterrissage et Jour 1

- **Bloquant, a10.** À 10 pièces, la main or désigne Dégâts, qui coûte 25 (a07) : la carte reste grise. Et l'Établi n'est pas « façade est » : il est à 35 studs de l'atterrissage. → Prix lu dans `Economie.prixEtabli` ; atterrissage sur le Parvis, près de l'Établi.
- **Bloquant, a06.** `BoucleDuJour` publie `Jour`, `Phase` et `FinPhase` sur `workspace`, mais le HUD lit `EtatRun` : il reste bloqué sur « JOUR 1 · 0:00 ». Le module verse aussi ses propres gemmes (`Gemmes_v1`) et un bonus de pièces qui s'efface. → Écrire dans `EtatRun` et faire tout passer par `Economie`.
- **Majeur, a10.** Le premier Marcheur arrive à A+3, pendant les 20 s d'Arrivée calme de a06 : le minuteur ment. → Compter `OUVERTURE` depuis le début de la horde et utiliser l'Arrivée pour montrer l'anneau et le joystick.
- **Majeur, a14.** En solo, dès le Jour 1, un paquet sur quatre vient du Sud, où l'écran ne montre que 22 studs. Les portails sont à 86 studs, contre 80 au Plan : les Zbires sortent des arbres. → Rampe de a06 (pas de Sud avant le Jour 4), portails placés par `Plan.positionPortail`.
- **Majeur, a09.** Selon le livrable, les pièces au sol sont perdues après 12, 15 ou 20 s, jamais, ou à 50 %, et la Mine est commune ou personnelle. → Règle unique : aimant de 8 studs, pièces au sol jusqu'au Répit puis 50 % aspirées ; Mine commune, 1 gemme toutes les 30 s, 4 au maximum.
- **Majeur, a11.** Les Zbires avancent en ligne droite (a26) : ceux du portail SE (135°) traversent la Mine et étourdissent le joueur qui la vide. Idem pour les Trois Rochers (axe NO). → Portail SE à 155°, aucun obstacle de palier C sur les 8 axes.

## 2. Premier Répit

- **Majeur, a33.** L'Établi s'ouvre seul à 10 studs, une zone qui chevauche celle de réparation. Son panneau remplace la Grappe : en réparant côté Sud-Ouest, Réparer disparaît et mon tap achète une carte. → Bouton contextuel de 72 px (F), ouverture automatique au Répit seulement, taps ignorés pendant 0,8 s.
- **Majeur, a33.** Le `CATALOGUE` contredit a07 (Dégâts à 20 au lieu de 25, Butin au niveau 8 max au lieu de 5) et oublie la cagnotte d'équipe. → Utiliser `Economie.prixEtabli` et ajouter une carte de cagnotte avec une jauge et les têtes des contributeurs.
- **Majeur, a09.** La 4e pose détruit la plus ancienne défense sans remboursement, même une Mini-Tourelle à 114 pièces. La zone de pose vaut 50, 60, 64 ou 66 studs selon le livrable : le fantôme est orange, mais la pose est refusée. → Refuser la 4e pose, reprise d'un tap (50 % rendus), `Plan.posePermise` partout.
- **Majeur, a09.** Sans saut sur la Prairie (a28, a32, a35), un Muret de 3 studs devient un mur : on peut murer la Maison ou un coéquipier. → Groupe de collision `Defenses` non collidable avec `Survivants`.
- **Majeur, a15.** Les buissons du Panier sont à 75-85 studs, derrière la barrière : les empreintes mènent à un mur invisible. `FilonQuiChante` attend `ReplicatedStorage.Partie`, qui n'existe pas. → Placer les buissons entre 58 et 66 studs et lire `EtatRun`.

## 3. Combat et HUD

- **Bloquant, a32.** Les maquettes du HUD sont incompatibles : Grappe (a35), rangée (a32), Ping en haut (a09), coin réservé au saut (a31). Le ping est sur Q, G ou T. Réparer envoie un seul `FireServer()` au lieu du maintien `(true/false)`. Le Sac à dos (a10) et le cadenas « Niv. X » (a08) manquent. → Une maquette unique : Grappe de a35, bandeau de a32, touches E / 1-2-3 / Q / F, `InputBegan`/`InputEnded`.
- **Mineur, a10.** Au premier Colosse, la Roue des Pings s'ouvre seule 2 s au centre de l'écran et cache le Colosse. → Faire pulser le bouton Ping à la place.
- **Mineur, a12.** Les Ressorts des diagonales sont sur la route des Zbires : un pas de travers me renvoie près de la Maison. Sans saut, les îlots de 3 studs bloquent le passage. → Ressort actif seulement quand on court vers la Maison ; îlots de 1 stud.
- **Mineur, a07.** L'anti-AFK retire des gemmes en silence, avec 3 seuils différents selon le livrable. → Un seuil unique, un « Zzz » et un bip à 45 s, et une ligne « inactif » en fin de run.

## 4. Chute, retour au Laboratoire, deuxième run

- **Bloquant, a08.** La Tourelle de toit n'est visible qu'au niveau 5. Tombé au Colosse du Jour 5 (≈ 1 100 XP, niveau 4), je ne vois que la Foreuse, à 100 gemmes, avec 74 en poche : rien à acheter. → Tourelle de toit visible dès le niveau 1.
- **Majeur, a10.** Au retour (`RunsTerminees = 1`), plus aucun guide, et les cartes d'arrivée parlent de la Foreuse et du Défi du Jour, que je n'ai pas. → Prolonger l'onboarding jusqu'à `PremiereRecherche` : dalles cyan vers l'Arbre des Recherches, main or sur la Tourelle de toit.
- **Majeur, a08.** Capsule Difficile : niveau 10 (a08) ou Record Jour 10 (a06). Capsule du Jour : niveau 3, mais Défi seulement après le premier Colosse (a07). → Une condition par Capsule, écrite sur son `SurfaceGui`.
- **Majeur, a13.** Les secrets rapportent jusqu'à 50 gemmes par jour, en dehors des 5 sources du canon. → Récompenser seulement en cosmétiques et en pièces de run.
- **Majeur, a13.** Le Colosse endormi est hors d'atteinte (87,7 studs), le Pique-nique empiète sur la Mine, et les Dalles chantantes occupent la place du Filon (a15). → Nez du Colosse à 78 studs, Pique-nique déplacé, Dalles sur le Quai des Capsules.

### ⚡ Analyste performance — Capucine Lam
# Relecture performance · Zsurvie

*Capucine Lam (a42), Analyste performance, QA & Équilibrage*

Cible du canon : Android 3 Go, 30 FPS avec 6 Survivants, 60 Zbires et le Colosse, sous 800 Mo. Rien n'est encore mesuré : les chiffres ci-dessous viennent des livrables. Les 3 bloquants fixent l'architecture. Ils sont à régler avant toute construction.

## Bloquants

**1. [a26] Zbires : quatre architectures de rendu.** a24 livre 2 à 5 MeshParts, a25 en veut 12, la Forge de a30 soude 29 cubes et a38 anime 6 `Motor6D` par `PivotTo`. Pire cas : 1 800 Parts et 60 `Animator` à chaque image.
→ `ZbiresRendu` : un pool de 70 modèles créé pendant l'Arrivée (Racine ancrée + 3 à 5 MeshParts a24). Un seul `workspace:BulkMoveTo(racines, cframes, Enum.BulkMoveMode.FireCFrameChanged)` par image, ombres et collisions coupées, ni `Instance.new` ni `Destroy` en combat. On passe de 1 800 à 360 Parts.

**2. [a11] Budget de Parts de la Prairie.** Il existe cinq plafonds, de 4 500 à 7 500. Les demandes additionnées donnent a16 400 + a17 1 200 + a18 205 + a20 6 000 + a23 2 500, soit ≈ 10 300 Parts statiques avant le premier Zbire. La Lisière est construite par quatre agents : a17, a20, a21 et a24.
→ Une seule table dans `ServerStorage.Outillage.Gabarit`, avec un statique ≤ 6 500 : sol 300, bâtiments 650, végétation 2 200 (a17 seul constructeur de la forêt), props 1 200, tramages 350, météo 150, POI 200, marge 1 450. Pic attendu : ≈ 7 900.

**3. [a19] Quatre scripts écrivent dans `Lighting`.** `CycleCiel` règle `ClockTime` et 11 propriétés à 20 Hz, nuit comprise. `MeteoClient` (a18), `AmbianceBiomes` (a20) et `AmbianceClient` (a36) y écrivent aussi. Chaque changement de `ClockTime` relance le calcul des ombres et de l'éclairage, et les scripts se contredisent.
→ Un seul écrivain, `AmbianceClient` : 14 h fixe, 17,5 le Jour du Colosse. `CycleCiel` quitte la Prairie. Si le soleil doit servir de chronomètre : 4 paliers par horde au plus, jamais 20 Hz.

## Majeurs

**4. [a18] Orage le Jour du Colosse, notre pic de charge.** Deux voiles transparents couvrent tout l'écran, soit une double surcouche alpha. Le mode léger ne mesure que les 5 premières secondes, quand il n'y a encore aucun Zbire.
→ Sur mobile : `VoileProche` seul, sur la moitié haute de l'écran. Mode léger calculé sur une moyenne glissante de 3 s (bascule sous 27 FPS pendant 2 s), partagé avec a37 par l'attribut `Qualite`. Pas de `Clouds` au Laboratoire.

**5. [a18] Douve et Bassin.** La Douve fait 160 Parts transparentes, avec `Reflectance` 0,1 et une texture défilante. Le `Terrain Water` du Bassin fait échouer l'audit « 0 cellule ».
→ Douve opaque en 16 segments MeshPart, texture fixe. Flaques sans `Reflectance`. Bassin en Eau-bloc.

**6. [a38] `ZbireAnimateur` alloue à chaque apparition** : `AnimationController`, `Animator`, 7 `LoadAnimation`, puis `Destroy` après l'éclat. Il ne coupe la marche que hors champ, alors que presque toute la horde est à l'écran.
→ Pistes chargées une seule fois sur le pool, `recycler(id)` au lieu de `Destroy`. `Animator` actif sur les 20 Zbires visibles les plus proches, rebond procédural pour les autres. Rendu et animation ≤ 3 ms par image.

**7. [a27] Chaque coup voyage trois fois** : par `Impact` et `Eclatement` (a28), par `VfxRapide` (a37) et par l'événement fiable de a26. `EtatZbires` existe en trois formats : 7, 9 et 10 octets. Un lot `VfxRapide` de 20 tables frôle la limite de 900 octets.
→ Dans `Reseau` : `EtatZbires` à 9 octets, et un seul `UnreliableRemoteEvent` `Evenements` à 10 Hz, en `buffer` de 8 octets par fait. Les VFX, les sons, l'animation et l'UI lisent ce flux.

**8. [a39] `Son.Jouer` clone un `Sound` et un `Attachment` pour chaque son**, puis les détruit. Les voix débordent aussi : a40 en veut 3 pour la musique, a18 prend l'ambiance, a20 ajoute 3 boucles et 4 bourdonnements.
→ Pool créé au démarrage, `Attachment` déplacé par `WorldPosition`. Répartition des 16 voix : Musique 3, Ambiance 2, Joueur 3, Zbires 4, Monde 2, Interface 1, Alertes 1. a20 ne garde qu'un bourdonnement, celui du portail le plus proche.

**9. [a36] Ombres et lumières.** `CastShadow` est actif sur le `Corps` des 61 Zbires : 61 volumes mobiles dans la passe d'ombre. Le Laboratoire est en `Future` avec 2 lumières `Shadows` true, contre l'audit de a25. `Brightness` est animée sur `Heartbeat`. a20, a21, a22 et a23 ajoutent leurs propres `PointLight` aux 12.
→ Zbires sans ombre, avec un disque plat sous le Volant et le Sauteur. Laboratoire en `ShadowMap`, `Shadows` false. Lumières animées rafraîchies à 10 Hz, 2 à la fois au plus. `workspace.Lumieres` devient la seule liste des 12 lumières.

**10. [a21] États de la Maison reparentés.** Chaque échange réplique 80 Parts vers les 6 clients. Sans hystérésis, une réparation autour de 60 % fait basculer l'état en boucle.
→ Les 3 états restent dans la place, affichés par le client depuis `Maison.Etat`. 5 points d'hystérésis. Seuils à 66 % et 33 %, comme a22 et a28.

**11. [a37] Trop d'émetteurs et d'éclatements.** Portails, Mine, fumée, D2 sur 18 Tapis Collants, étoiles, pluie, lucioles : on arrive à ≈ 40 émetteurs actifs pour 24 autorisés (a25). L'éclatement est codé trois fois, par a25, a28 et a37.
→ a37 devient seul propriétaire des émetteurs : D2 en `Texture` fixe, portails à `Rate` 6, Z1 seul éclatement (a28 retire ses 90 cubes).

## Mineurs

**12. [a16]** `CastShadow` est actif dès 2 studs sur la berge et les monts. Le soleil étant côté caméra, ces ombres tombent hors de l'arène. → `CastShadow` à false sur tout `Arene.Sol`.

**13. [a19]** Le Sky de la Prairie fait 6 × 1024² : ≈ 24 Mo, soit 40 % du plafond `GraphicsTexture`, pour 3 plans. → Passer en 256² : motif de 64 px agrandi × 4 au plus proche voisin.

**14. [a40]** Toutes les pistes sont préchargées dans les deux places. → Sur la Prairie : HordeA, `Repit` et `Colosse` au départ, B au Répit du jour 5, C à celui du jour 10. Couches `_Tension` en mono, `Sounds` ≤ 15 Mo.

**15. [a30]** La marge de 670 Parts oublie les 240 Parts d'avatars, et la Canopée de a16 (± 150) échoue au contrôle ± 110. → Statique à 6 500, pic compté avec avatars et pools, tag `HorsArene` pour la Canopée.

## Protocole de mesure

- Place Prairie privée, Android 3 Go, 6 comptes, Jour 5 forcé (`ModeTest`), 60 Zbires, Colosse, 18 défenses, Orage. Niveaux graphiques 1, 4, 10 et automatique, 5 min par passage.
- MicroProfiler du téléphone, lu depuis un PC (`http://<IP>:1338`). Chaque boucle client est encadrée par `debug.profilebegin("NomDuScript")` et `debug.profileend()`.
- Seuils (p95) : image ≤ 33,3 ms, scripts client ≤ 5 ms, tick de horde ≤ 2 ms, 500 draw calls, 120 000 triangles, `Stats:GetTotalMemoryUsageMb()` ≤ 720, `GraphicsTexture` ≤ 60 Mo, réception ≤ 30 Ko/s.
- On ajoute les couches une à une (décor, Zbires, VFX et sons, météo). Une couche qui coûte plus de 3 ms retourne à son auteur.

### 📊 Équilibreur — Stan Bogaert
# Relecture équilibrage : économie, progression, monétisation

*Stan Bogaert (a43), QA & Équilibrage. Barème de référence : a07, le seul chiffré de bout en bout.*

**Verdict.** La monétisation (a46) est saine : aucun pay-to-win, 1 087 R$ pour tout posséder, aucun article au-dessus de 199 R$, aucun Robux sur la Prairie. Les vignettes (a47) ne montrent rien au-delà du Jour 12. Le risque est ailleurs : trois barèmes de gemmes, trois courbes d'Établi, et aucune run n'a de fin garantie.

## Temps réels calculés

| Repère | Calcul | Résultat |
|---|---|---|
| Chute au jour N | 20 + (N − 1) × 95 + ≈ 40 s | J6 : 9 min, J8 : 12 min, J11 : 17 min |
| Colosse du J15 | 20 + 14 × 95 + 40 | entrée à 23 min 10, combat sans limite |
| Gemmes par run (a07) | jours + Mine + 75 % des Dorés | J6 : 111, J9 : 197, J11 : 294 |
| 1re heure | 4 runs, Défi débloqué dès la 2e | 607 gemmes et 7 recherches (a07 annonce 457 et 5) |
| Arbre complet | Σ base × 1,7^(n − 1) | 83 100 gemmes ≈ 65 h, dont 34 % pour la Foreuse |
| Niveau 30 (a08) | 116 310 XP à ≈ 3 300 XP/jour | 5e-6e semaine, conforme |

## Bloquants

1. **a06 : deux barèmes de gemmes.** `BoucleDuJour` crédite 2 + ⌊N ÷ 2⌋ dans `Gemmes_v1`, sans anti-AFK, en parallèle d'`Economie.franchirJour` (5 + 2 × min(N, 15)). Résultat : double crédit, ou gains ÷ 2,4 (≈ 97 gemmes contre 231 au J10). La Mine suit trois règles différentes (a06, a07, a09). → Supprimer `verserGemmes` et appeler `Economie.franchirJour(jour)`. Mine : 1 gemme / 20 s par Survivant actif, stock 6, vidée pour toute l'équipe au contact.
2. **a27 : quatre adresses pour les gemmes** (`Gemmes_v1`, `Zsurvie_Profils_v1` sous `Survivant_` puis `Joueur_`, `Zsurvie_Joueurs_v1`) : une gemme gagnée sur la Prairie n'arrive pas au Laboratoire. Le plafond « Jour 100 » rogne un J15 à 70 gemmes × 1,5 (Difficile) × 2 (week-end), soit 210. → Store unique `Zsurvie_Joueurs_v1`, clé `J_<UserId>`, écrit par `Donnees.AjouterGemmes` seul ; plafond Jour à 210 ; retirer la source ZbireSemaine.
3. **a26 : trois courbes pour l'Établi.** a07 vend 10 niveaux, mais a09 plafonne Portée au 4, Cadence au 5, Dégâts au 8 et Explosives au 3 : 9 800 des 20 000 Pièces n'achèteraient rien. Les Perforantes de a07 atteignent 140 % au niveau 10. À 45 % de Visée critique, le Casqué subit 1,18 × les dégâts normaux. → `BlasterStats` unique aux prix a07 : Dégâts 10 + 2/niv ; Cadence 4 + 0,2/niv ; Portée 40 + 1,2/niv, rayon du tir auto compris ; Explosives 5 %/niv (rayon 6, 50 % des dégâts) ; Visée critique 5 % + 2 points/niv (25 % au max, Casqué à 0,875) ; Perforantes 45 % + 5 points/niv (95 %). a07 et a09 reprennent ce tableau.
4. **a08 : recherches invisibles au premier retour.** Après la 1re run (≈ 840 XP, niveau 4), seule la Foreuse (100 gemmes) est visible. Le novice n'a que 74 gemmes, et la Tourelle de toit (40 gemmes, l'achat guidé) n'apparaît qu'au niveau 5. Deux verrous se doublent aussi : Difficile au niv 10 ou au Record Jour 10 (a06), Défi au niv 3 ou au 1er Colosse (a07). → Tourelle de toit visible au niv 1, Visée critique au 3, Perforantes au 4, Foreuse au 5 ; Difficile = Record Jour 10 ; Défi = 1er Colosse repoussé.

## Majeurs

5. **a06 : pas de fin garantie.** Le Jour du Colosse dure « tant qu'il est debout », `LIMITE_RUN` ne fait qu'un `warn`, et la Tension manque dans la formule de a26. → Colosse à 2 500 × 1,15^(jour − 1) PV avant coop (≈ 45 s de combat au J5 en solo), enragé 60 s après son entrée (vitesse × 1,5, dégâts × 3), fin forcée à 25:00 avec les gemmes normales, Tension × 1,3^cran sur les PV et les paquets.
6. **a07 : la coop n'est pas neutre.** À 6, le DPS est × 6 contre des PV × 2,75, soit une capacité × 2,18 et ≈ 3,5 jours de plus (331 à 371 gemmes au lieu de 197). → Multiplier le nombre de Zbires par jour par (1 + 0,2 × (actifs − 1)) : bonus coop ≈ +0,6 jour. Recalculer le §5 à 2,5 Survivants.
7. **a07 : les Pièces suivent quatre règles** (aimant 8 ou 10 studs ; 12, 15 ou 20 s au sol ; 50 ou 100 % au Répit ; Doré dès J2 ou J3). Le revenu réel varie donc de 50 à 100 % du §3. → Aimant serveur 8 studs, 20 s au sol, 50 % au Répit, Doré au J3, cumuls à 85 % (≈ 780 au J5, 2 700 au J10). a09, a14 et a28 s'alignent.
8. **a07 : la Foreuse est un mauvais placement.** Chaque niveau rapporte +16 gemmes par nuit et coûte de 170 à 11 860 : le niveau 10 se rentabilise en 741 jours. → 5 niveaux, 5/9/14/20/27 gemmes/h, prix de 100 à 835. L'arbre passe à ≈ 56 300 gemmes (≈ 45 h), aligné sur le niveau 30.
9. **a09 : réparation cumulable.** À 6 avec Réparation 5, la Maison regagne 20 %/s : elle est pleine en 5 s à chaque Répit. Les PV de la Maison et les dégâts des Zbires manquent aux livrables. → 1,5 % × (1 + 0,25 × niv) × (1 + 0,5 × (réparateurs − 1)), 3 réparateurs comptés au plus ; Maison 1 000 PV (Solidité +12 %/niv) ; Zbire au contact 4 × 1,15^(jour − 1) PV/s.
10. **a09 : défenses figées.** Mini-Tourelle (10 DPS) et Muret (150 PV) ne progressent pas, alors que leur prix monte de 15 % par jour : au J10, 141 Pièces pour 10 DPS contre des Zbires à × 3,5. → Mini-Tourelle à 50 % des dégâts du Blaster du poseur ; Muret à 150 × 1,15^(jour − 1).
11. **a10 : premier achat hors délai.** Le prix codé est 10, le prix réel 25 (13 Marcheurs). L'ouverture démarre à A+3 malgré les 20 s d'Arrivée de a06 : l'achat tombe vers T 95. La cadence est de 3 au lieu de 4. → Lire `Economie.prixEtabli("Degats", 1)`, envoyer 13 Marcheurs entre +3 et +30 s, sauter l'Arrivée si `aDesNovices()` (Colosse à 7:00) : achat vers T 75.
12. **a50 : mur mal placé.** Une « plus grosse marche J5 → J6 » donne une médiane de 8 min, contre 12-18 min visées. → Marche attendue entre J8 et J12 pour les runs de rang ≥ 4, perte J5 → J6 ≤ 20 % ; 3 premières runs analysées à part ; tranches J1-4, J5-7, J8-11, J12+.
13. **a49 : gemmes hors canon.** Avent : 1 000 ; missions : 300 par semaine. → Convertir en XP (a08), cosmétiques ou Foreuse Turbo, avec l'accord de Victor Lanoue.
14. **a49 : pack Robux d'événement.** Rien ne garantit qu'il reste en vente après l'événement : ce serait une offre limitée, que a46 interdit. → Le laisser en vente toute l'année après sa sortie, sans compte à rebours.
15. **a13 : secrets à 50 gemmes par jour.** C'est une source hors canon, contraire aux règles de a15 et de a22. → Récompenser en cosmétiques, badges, XP et Pièces de run.

## Mineurs

16. **a06 : Jour parfait à +10 Pièces fixes.** Le 2e achat promis est impossible dès le J3. → Bonus de 25 % des Pièces du jour.
17. **a07 : §5 incomplet.** Il omet le Défi en 1re heure, Difficile × 1,5, le Filon et le Panier (≈ +10 % au J10), et mélange jour UTC et jour de Paris. → Recalculer ; `Transactions.cleJourParis` partout.
18. **a48 : deux erreurs de fiche.** Serveur privé à 100 R$ (a46 : 50) ; « tir automatique sur mobile » alors qu'il est actif sur tous les appareils. → Corriger les deux.

### 🐞 Chasseuse de bugs — Margaux Deniel
# Relecture QA : bugs, cas limites et exploits

*Margaux Deniel, chasseuse de bugs (QA & Équilibrage). Relu : a11 à a15, a26 à a30, et le code de `scripts/a26` à `scripts/a30`.*

Chaque mécanique, prise seule, tient debout : horde à 10 Hz, verrou de session, seau à jetons. C'est l'intégration qui ne démarre pas. Quatre contrats divergent (remotes, DataStore, hiérarchie du Workspace, état de run), et ils bloquent la Prairie avant la première horde.

## Bloquants

1. **a27 · Contrat réseau éclaté.** a26, a27, a28 et a29 définissent quatre jeux de remotes différents. a27 et a29 créent chacun leur propre dossier `Remotes` : le client se bloque sur `WaitForChild`. `DemandeTir` peut recevoir deux connexions, et un tir compter double, dont une fois sans validation. → Un seul module `Reseau`, généré depuis `ReglesRemotes`, avec uniquement des RemoteEvent, et un `assert` qui vérifie qu'il n'existe qu'un dossier.
2. **a27 · Les gemmes sont réparties dans 3 stores.** `Zsurvie_Joueurs_v1` (a27), `Zsurvie_Profils_v1` (a29) et `Survivant_<id>` (a15). Les gains de run crédités par a29 n'apparaissent pas au Laboratoire. Un double versement est possible entre `Jour` et `FinDeRun`. → Un store unique, celui de a27, avec un `CrediterRun(runId, totalRun)` idempotent, et `SchemaJoueur` en v2.
3. **a29 · `Carte` est codé en dur.** a11 range tout dans `Workspace.Arene`. Sans `Carte`, le gardien ne se charge jamais et la protection anti-éjection disparaît. Quand le sol est introuvable, « Vol » coûte 6 points toutes les 0,75 s : chaque joueur est exclu en 5 s environ. → Lire la racine dans `Plan`. Un sol introuvable ne doit jamais compter comme une faute.
4. **a28 · Pas de contrôles sur mobile.** Rien ne crée `EtatRun`, `Workspace.Zbires` avec son attribut `Id`, ni les attributs `Portee` et `Cadence`. Soit `surLaPrairie()` renvoie false, soit `WaitForChild` bloque : pas de bouton RÉPARER, POSER ou PINGS, pas d'Établi. En plus, le tir automatique tourne deux fois. → Utiliser `ZbiresRendu` et `BlasterStats` (a26), garder une seule boucle de tir et reconnaître la place par `TypePlace`.

## Majeurs

5. **a26 · Un joueur peut être emmuré.** La réinitialisation est désactivée. `posePermise` ne teste que le centre de la défense : 3 Murets en (−13, ±4) et (−18, 0) ferment une poche contre le mur ouest. Sans saut, le joueur y reste jusqu'à 25 min. → Rediriger la réinitialisation vers `DemandeDeblocage` et `GardienMouvement.teleporter`. Rendre les défenses non collidables avec le groupe `Survivants`.
6. **a26 · Saut et vitesse ont deux maîtres.** `JumpHeight` 5 est réimposé à chaque apparition, ce qui ramène le bouton de saut sous RÉPARER. Le gardien ignore la vitesse 24 du Répit et compte sur 18 : il renvoie le joueur en arrière et lui donne 4 points. → `StatsSurvivant` délègue ces réglages à `GardienMouvement`.
7. **a29 · Faux positifs.** `RayonPlace` vaut 74, exactement comme la barrière : aucune marge. Avec 74 par défaut, le Quai (Z −88) et la Galerie (X −100) du Laboratoire sont hors zone. La Grimpe du Colosse et les Ressorts font monter au-delà de 14 studs. → Rayon de la barrière + 4 studs, aucun point quand un mur physique existe, des Parts `ZoneJouable` au Laboratoire, une tolérance pour `Climbing` et `accorderEnvol`.
8. **a12 · Boucle entre le filet et le gardien.** `PivotTo` contourne `teleporter` et conserve la vitesse de chute. Le gardien renvoie l'enfant sur le filet, jusqu'à 8 points par boucle. Si `reprise` vaut nil, rien ne ramène le joueur. `CHRONO_MIN` à 15 s est trop bas. → Passer par `teleporter`, revenir à CP0 par défaut et fixer un minimum par segment (22 s au total).
9. **a27 · Un double tap achète deux fois.** `LancerRecherche` et `DemandeAchat` ne précisent pas le niveau visé, et le seau laisse passer 2 jetons : l'enfant paie 40 puis 90 gemmes. → Ajouter un argument `niveauVise` et refuser sans débiter en cas d'écart.
10. **a27 · Déconnexion en pleine run.** Aucun retour vers la run n'est prévu, et la fiche `Capsules` expire au bout de 900 s alors qu'une run dure jusqu'à 25 min. Un `Liberer` raté n'empêche pas le téléport : le profil est rechargé sans les gains de fin de run. → Enregistrer `RunEnCours_<UserId>` et proposer « Rejoindre la run ». Téléporter seulement après la sauvegarde.
11. **a14 · Des paquets de Zbires se perdent.** `lancerPaquet` appelle `SetAttribute` sur ce que renvoie `creer`, qui vaut nil au plafond : le thread plante et le reste du paquet disparaît. `Ciblable` est ignoré par le serveur. → Passer par `ajouterALaFile(type, n, cframe)` et gérer `ciblableA` côté serveur.
12. **a15 · Le Filon ne peut pas fonctionner.** `Partie` et `Charte.Gemme` n'existent pas. Un coéquipier qui passe sur une plaque coûte un essai, et les Dalles de a13 sont au même endroit. Les Nids au-delà de 82 studs sont hors d'atteinte. → Lire les attributs du Workspace et `Charte.Couleurs`, ne compter que le joueur qui mène la suite, placer les Nids à 66 studs au plus.
13. **a13 · Les secrets rapportent des gemmes.** C'est une source hors canon §6, et l'écart n'est pas déclaré. Le `require` de `Donnees.Profils` plante, et le champ `secrets` manque au schéma. Le Pique-nique chevauche la Mine. Le Colosse endormi, à R 88, est hors de portée. Le Tableau noir reste figé à l'ordre du démarrage du serveur. → Récompenser en cosmétiques et en Pièces, écrire via `Donnees.Modifier`, placer les POI à 66 studs au plus et recalculer l'ordre à minuit.
14. **a30 · Des cubes provisoires en production.** La Forge écrit dans `ReplicatedStorage.Zbires`, mais a26 lit `Modeles.Zbires` et retombe sans alerte sur des cubes. → Un chemin unique, et un type manquant devient un bloquant de l'Auditeur.

## Mineurs

15. **a27 ·** `Reconcilier` remet à 0 un champ `Gemmes` de mauvais type. → Tenter `tonumber` ; en cas d'échec, refuser le chargement et restaurer via `ListVersionsAsync`.
16. **a28 ·** Une pièce reste 20 s à l'écran mais disparaît au bout de 15 s côté serveur. → Ajouter à `PiecesLachees` une heure d'expiration `expireA` fixée par le serveur.
17. **a14 ·** Le tir automatique compte comme une activité, donc un joueur absent n'est jamais retiré. La Mine en gradins sert de perchoir, hors d'atteinte du contact vertical de 4 studs. → Définir l'activité comme a07 et rendre le sommet de la Mine impossible à escalader.
18. **a11 ·** L'audit lit `arene.Maison`, qui n'existe nulle part ailleurs. La barrière est à 72 studs ici et à 74 chez a12 et a14, et les zones d'atterrissage des Ressorts restent posables. → Fixer une hiérarchie et des rayons uniques dans `Plan`.

## Scénarios à rejouer avant chaque build

- 6 clients, Jour 5, 60 Zbires : score anti-exploit à 0 et un seul dossier `Remotes`.
- Double tap sur une recherche : un seul niveau débité.
- Wi-Fi coupé au Jour 3, puis retour dans la run : les gemmes du Jour 2 sont présentes.
- 3 Murets autour d'un coéquipier : `DemandeDeblocage` le libère en moins de 2 s.
- 5 chutes dans la Tuyauterie : aucune exclusion.

### 👥 Coordinateur playtests — Félix Onana
# Plan de playtests : 8 hypothèses à risque

*Félix Onana, coordinateur playtests. Base : canon de Victor Lanoue et décisions a06 à a50.*

## Cadre commun

- **Testeurs :** 9-15 ans, dont deux tiers de 9-12 ans. Accord parental écrit, comptes de test, serveur privé, chat et voix coupés, capture d'écran sans visage.
- **Appareils :** 70 % téléphone (Android 3 Go de référence, iPhone SE), 20 % PC, 10 % iPad. FPS et `Stats:GetTotalMemoryUsageMb()` relevés ; une session sous 25 FPS part au test performance.
- **Build :** place privée, valeurs figées dans `ReplicatedStorage.Config`, télémétrie `ServerScriptService.Telemetrie` (a50).
- **Méthode :** observation muette, puis 5 questions au plus avec une échelle de 5 visages ; 45 min au plus par session.
- **Vagues :** V1 = H1 à H4 (12 enfants, solo et duo) ; V2 = H5 à H7 (24 enfants, groupes de 4 à 6) ; V3 = H8 (bêta fermée de 7 jours, 40 comptes).

## Les 8 hypothèses

### H1. Un novice comprend la run sans un mot (a10)
- **Profil :** 8 novices de 9-11 ans, sur téléphone.
- **Scénario :** SpawnNovice, Capsule Normale en solo, ouverture scriptée du Jour 1, arrêt après le Jour 3.
- **Questions :** « Qu'est-ce qui donne des pièces ? » « À quoi sert l'Établi ? » « Que protèges-tu ? »
- **Succès :** 7/8 éclatent un Zbire avant 45 s ; 6/8 achètent seuls avant 90 s ; aucun abandon avant le Jour 2.

### H2. Les contrôles mobiles tiennent sans saut (a28, a35)
- **Profil :** 10 joueurs de 9-15 ans sur téléphone 5,5" et iPhone SE, dont 3 habitués de Roblox.
- **Scénario :** A/B entre le saut à 0 avec la grappe de a28 et `JumpHeight` 5. Consigne : poser 3 Murets, puis courir à l'Établi.
- **Mesures :** taps hors cible, poses annulées, Survivant bloqué plus de 3 s.
- **Succès :** moins de 5 % de taps ratés ; aucun Survivant enfermé ; 8/10 posent en 2 taps du premier coup.

### H3. Avec le tir automatique, le Survivant reste l'arme (a09, a28)
- **Profil :** 12 joueurs, 6 sur téléphone et 6 sur PC.
- **Scénario :** une run jusqu'à la chute, tir auto actif partout.
- **Mesures :** temps immobile, taps de cible prioritaire, gemmes retenues par l'anti-AFK. Question : « Qui bat les Zbires, toi ou le jeu ? »
- **Succès :** immobile moins de 30 % de la horde ; 9/12 disent « moi » ; aucun joueur actif privé de gemmes.

### H4. La horde se lit en une seconde (pilier 1)
- **Profil :** 10 joueurs de 9-13 ans sur téléphone.
- **Scénario :** run jusqu'au Jour 9 (bestiaire complet), puis reconnaissance des 10 portraits à 32 px (a34).
- **Questions :** « Pourquoi le casqué résiste ? » « Que fait le gluant ? » « D'où venait le Zbire qui t'a étourdi ? »
- **Succès :** 8/10 énoncent les règles du Gluant et du Volant, 6/10 celle du Casqué ; moins de 20 % des étourdissements viennent d'un Zbire hors champ au sud.

### H5. On coopère sans chat (pilier 2)
- **Profil :** 2 groupes d'amis de 4 et 2 groupes d'inconnus de 6, appareils mêlés.
- **Scénario :** 2 runs par groupe, Roue des Pings seule.
- **Mesures :** pings par minute, contributions à la cagnotte commune, réparations par joueur.
- **Succès :** à chaque Colosse, un ping suivi d'effet en 5 s ; personne à 0 contribution ; jour atteint à 6 joueurs à ± 2 jours du solo (multiplicateur 0,35).

### H6. Le Répit de 15 s suffit (a06, a07, a15)
- **Profil :** les groupes de H5 et 6 solos.
- **Scénario :** mêmes runs ; on chronomètre achat, réparation, pose et énigme de chaque Répit.
- **Question :** « Le moment calme : trop court, bien, trop long ? »
- **Succès :** 80 % des Répits comptent au moins 1 achat ; « trop court » sous 25 % ; aucune énigme ne fait rater un achat.

### H7. La run dure ce que promet le canon (§4, §9)
- **Profil :** 30 runs en Capsule Normale, de 1 à 6 joueurs.
- **Scénario :** runs libres sur une seule table jour → PV et nombre de Zbires.
- **Succès :** 70 % des premières runs voient le Colosse (7 min 20) ; chute médiane entre J8 et J11 ; aucune run au-delà de 25 min.

### H8. Les gemmes font revenir (pilier 3)
- **Profil :** 40 comptes, dont 25 novices, 70 % sur téléphone.
- **Scénario :** bêta fermée de 7 jours, journal parent-enfant de 2 questions par jour.
- **Questions :** « Qu'as-tu lancé au Laboratoire, et qu'est-ce que ça change ? » « Pourquoi es-tu revenu ? »
- **Succès :** 100 % peuvent lancer une recherche après la 1re run ; 2e run ≥ 55 % ; J1 ≥ 22 % et J7 ≥ 8 % ; moins de 10 % de « j'étais obligé ».

## Préalables : aucune vague sur des valeurs contradictoires

| Gravité | Agent | Problème | Correction |
|---|---|---|---|
| Bloquant | a09 | Saut à 0, 4,5, 5 ou 7,2 selon les agents ; Muret « franchissable d'un saut » | `Config.Mouvement` unique, Murets non collidables pour les Survivants |
| Bloquant | a07 | Dégâts niv. 1 à 25 pièces pour 14 pièces gagnées à 70 s | Base de Dégâts à 10 pièces |
| Bloquant | a08 | Au retour, seule la Foreuse (100 gemmes) est visible | Tourelle de toit (40) visible dès le niveau 1 |
| Bloquant | a27 | 3 DataStores et 2 formats de clé pour les gemmes | `Zsurvie_Joueurs_v1`, clé `J_<UserId>`, schéma unique |
| Majeur | a07 | Barèmes de gemmes contradictoires (a06, a07, a09) | Une table dans `ReplicatedStorage.Catalogue` |
| Majeur | a06 | PV × 1,15 par jour puis +30 % dès J11 ; Zbires par jour non fixés | Table jour → PV, Zbires, paquets |
| Majeur | a13 | Secrets à 50 gemmes par jour, hors sources du canon | Cosmétiques et badges, ou écart soumis à Victor |
| Majeur | a10 | Entonnoir de 7 étapes contre 12 (a50) | Étapes de a50 via `Telemetrie` |
| Majeur | a11 | Mine au sud-est ou au nord-est, Établi au sud ou à l'est, portails de R 80 à 86 | `ReplicatedStorage.Plan` v1 figé, atterrissage à 10 studs de l'Établi |
| Majeur | a36 | 4 règles de `ClockTime`, dont une nuit pendant le Répit | Un seul script client, pas de nuit au Répit |
| Majeur | a07 | « Actif » vaut 4 studs, 20 studs ou 90 s selon l'agent | Un seul `Economie.marquerActif`, fenêtre de 90 s |
| Majeur | a09 | Pièces perdues à 15 s, à 20 s, rapatriées ou aspirées à 50 % | Aucune pièce perdue : aimant automatique à 20 s |
| Majeur | a35 | 5 maquettes de boutons, de 64 à 100 px | Maquette unique alignée sur a28 |
| Majeur | a27 | Jour qui change à minuit UTC ou à Paris | `Temps.cleJour()` en heure de Paris |

## 🤝 Coordination
# Zsurvie : note de coordination a03

*Marc Aubry, chef de projet, 26/09/2026. Ces arbitrages font foi pour le build de test H1 à H8. (V) = écart soumis à Victor Lanoue ; en attendant sa réponse, on construit avec l'option retenue.*

## 1. Arbitrages

1. **État de run.** Un seul `ReplicatedStorage.EtatRun`, créé par a27 et écrit par la BoucleDuJour de a06 : Jour, Phase (Arrivee, Horde, Repit), FinPhase, JourColosse, ColosseActif, PV de la Maison et du Colosse, MaisonEtat, Tension. Workspace ne garde que TypePlace, CentrePlace et RayonPlace.
2. **Réseau.** Un module `ReplicatedStorage.Reseau` (a27), généré depuis `ReglesRemotes` (a29) : RemoteEvent uniquement, refus par `Annonce`, `EtatZbires` en 9 octets à 10 Hz, un seul flux `Evenements` de 8 octets par fait. RemoteFunction, `Impact`, `Eclatement`, `VfxRapide` et `Retour` sont supprimés.
3. **Sauvegarde.** `Zsurvie_Joueurs_v1`, clé `J_<UserId>`, schéma v2, écrit par `Donnees.Modifier`, `AjouterGemmes` et `CrediterRun`. Tous les autres stores disparaissent. Le jour change à minuit heure de Paris (`Temps.cleJour()`), partout.
4. **Gemmes.** Les 5 sources du canon, barème a07 dans `ReplicatedStorage.Catalogue` : jour franchi 5 + 2 × min(N, 15), doublé aux J5, J10 et J15 ; Mine commune, 1 gemme toutes les 20 s, stock 6, versée à chaque Survivant actif au contact ; Doré 4 dès le J3 ; 1re recherche à 40. Secrets, Avent et missions : aucune gemme.
5. **Pièces.** Prix a07 (Dégâts niveau 1 = 25) ; le CATALOGUE de a33 est supprimé. Aimant serveur de 8 studs, 20 s au sol, puis 50 % crédités au Répit avec un « +X » gris (V). Jour parfait : 25 % des Pièces du jour (V).
6. **Survivant actif.** Un seul `Economie.marquerActif` (4 studs cumulés, réparation, pose, ping ou tap de ciblage ; fenêtre de 90 s ; « Zzz » à 75 s) pour les gemmes, l'XP et la coop (V).
7. **Combat.** `BlasterStats` unique sur 10 niveaux : Dégâts 10 → 30, Cadence 4 → 6, Portée 40 → 52, Visée critique 5 → 25 % (Casqué à 0,875), Perforantes 45 → 95 %, Explosives 5 → 50 %. Tir auto sur tous les appareils, rayon = Portée (V), une seule boucle chez a26.
8. **Difficulté.** `ZbiresDefs.JOURS` (a06) : PV × 1,15^(j−1) × 1,3^max(0, j−10) × coop ; (18 + 7j) × (1 + 0,2 × (actifs − 1)) Zbires par jour ; rampe de 1 chemin (J1-3, jamais le Sud), 2 portails (J4-8), puis 3 ou 4. Colosse à 2 500 × 1,15^(j−1), enragé 60 s après son entrée ; fin de run forcée à 25:00. Arrivée de 20 s gardée (V).
9. **Plan v1 (a11).** Mine X 20 → 32, Z 20 → 32 (V) ; 8 portails à R 80, le SE décalé de 20° vers le Sud ; barrière à R 72 ; pose jusqu'à R 66 via `Plan.posePermise`, client et serveur ; Établi (−12, 14) ; atterrissage (−3 ; 0,5 ; 16) ; aucun palier C sur les axes des portails.
10. **3C.** `Config.Mouvement` : Prairie 18, 24 au Répit, 8 en réparation, saut à 0 (V) ; Laboratoire 16 et 7,2. Seul `GardienMouvement` les applique. Les défenses ne bloquent pas les Survivants, la 4e pose est refusée, la reprise rend 50 %.
11. **HUD.** Maquette unique 800 × 360, codée par a28 seule (HudController de a32 retiré) : bandeau Maison en haut, Réparer 96 px dans le coin, Muret, Mini-Tourelle, Tapis Collant et Ping en 64 px sur l'arc, Établi en bouton contextuel de 72 px ; touches E, 1-2-3, Q, F. Variante B de H2 : la rangée Poser/Pings.
12. **Progression.** Recherches visibles aux niveaux 1 (Tourelle de toit), 3, 4 et 5 (Foreuse). Le niveau ne verrouille que les défenses et le Calendrier. Capsule Difficile : Record Jour 10. Capsule du Jour et Défi : premier Colosse repoussé.
13. **Lumière.** Un seul écrivain, `AmbianceClient` (a36) : ClockTime 14, puis 17,5 le Jour du Colosse après un fondu de 8 s au Répit précédent. `workspace.Lumieres` recense les 12 sources.
14. **Performance.** Statique de 6 500 Parts, pic ≈ 7 900. Zbires en pool de 70 (Racine + 3 à 5 MeshParts, un seul BulkMoveTo, ni ombre ni Neon). Seuls propriétaires : a17 (forêt), a37 (24 émetteurs), a39 (16 voix), a30 (`Charte.Couleurs` et `Charte.teinte`).

## 2. Révisions de la vague 1

Dans l'ordre du kanban. Le 29/09 : a30 (Charte, Forge, Auditeur), a11 (Plan, Gabarit), a27 (store, Reseau, Temps). Le 02/10 : a07 (Catalogue), a06 (table des jours), a09 (3C, défenses), a26 (horde, Blaster, rendu), a29 (gardien), a28 (HUD), a08 (visibilité), a10 (rythme, 1re recherche), a36 (lumière).

## 3. Vague 2

a13, a14, a15, a18, a19, a21, a32, a33, a37, a38, a39, a49 et a50 appliquent les arbitrages détaillés dans `a03-coordination.json`, sans consigne nominative.

## 4. Paquet pour Victor Lanoue (réponse souhaitée le 30/09)

Arrivée de 20 s, Jour parfait, Tension au J11, coop limitée aux actifs, aspiration de 50 %, tir auto sur tous les appareils, saut à 0, caméra (0, 52, 32) au Colosse, caméra Custom au Laboratoire, Mine bord à bord, StreamingEnabled au Laboratoire, Niveau de Survivant et Galons, Calendrier, Foreuse Turbo, glossaire EN, 5e canal pad, et les noms nouveaux (Parvis, Ronde, Grand Portail, Voie d'arrivée, quartiers, Tuyauterie, Ressorts, Douve, Vestiaire, Cabine d'Essayage, Pompon).

### Arbitrages
| Sujet | Agents | Arbitrage |
|---|---|---|
| Contrat d'état de run : EtatRun, attributs de Workspace ou ReplicatedStorage.Partie | a06, a15, a17, a19, a20, a27, a28, a32, a33, a36, a46 | Un seul ReplicatedStorage.EtatRun (Configuration), créé par a27 au démarrage de la Prairie seulement (il n'existe pas au Laboratoire) et écrit par la seule BoucleDuJour de a06 : Jour (pendant le Répit, le jour qui vient de finir), Phase (Arrivee, Horde, Repit), FinPhase (GetServerTimeNow), JourColosse (true dès le Répit qui précède un Jour du Colosse, false au Répit suivant), ColosseActif, ColossePV, ColossePVMax, MaisonPV, MaisonPVMax, MaisonEtat (1 à 3), Tension, ColosseAngle (posé 3 s avant l'entrée du Colosse, math.atan2(z, x)), Niv_Solidite, Niv_Reparation, Niv_Regeneration et les cagnottes d'équipe. Workspace ne porte que TypePlace, CentrePlace et RayonPlace dans les deux places. Supprimés : ReplicatedStorage.Partie (a15), workspace.EtatPrairie (a20), JourNumero, JourDebut et MaisonTombee (a19), Workspace.Jour (a17), workspace.Phase (a46), les Niv_<id> sur Workspace (a33). La chute de la Maison est annoncée par Annonce. |
| Contrat réseau : quatre jeux de remotes incompatibles | a26, a27, a28, a29, a31, a33, a35, a37, a38, a39, a40 | Un seul module ReplicatedStorage.Reseau, écrit par a27 et généré depuis ServerScriptService.Securite.ReglesRemotes (a29) ; au démarrage, un assert vérifie qu'il n'existe qu'un enfant Remotes. Montants, en RemoteEvent, une seule connexion chacun via Validation.brancher : DemandeTir(id), DemandeReparation(actif), DemandeAchat(cle, niveauVise), DemandePose(type, position), DemandeReprise(defenseId), DemandePing(nom), DemandeCapsule, DemandeRecherche(nom, niveauVise), DemandeForeuse, DemandeDeblocage, DemandeReglage(cle, valeur). Descendants : Annonce (refus avec action, raison, cle ; jingles ; jour franchi ; chute de la Maison ; Colosse), PingDiffuse, ProfilMaj (champs modifiés seulement), PiecesLachees (propriétaire seul, avec expireA), Butin. UnreliableRemoteEvent : EtatZbires à 10 Hz, 9 octets par Zbire (u16 id, u8 type, i16 X × 100, i16 Z × 100, u8 Y × 10, u8 PV sur 255) ; Evenements à 10 Hz, 8 octets par fait (u8 code, u16 id, i16 x, i16 z, u8 argument), 100 faits par paquet au plus, lu par VfxClient, Son, ZbireAnimateur et l'UI. Supprimés : toutes les RemoteFunction (a31, a33 : le bouton passe en Attente jusqu'à ProfilMaj ou Annonce, 3 s au plus), Impact et Eclatement (a28), VfxRapide et VfxImportant (a37), Retour (a39), Jingle (a40), le RemoteEvent fiable de a26 et les formats de 7 et 10 octets. |
| Persistance : quatre adresses de gemmes et deux heures de changement de jour | a06, a07, a08, a10, a13, a15, a22, a27, a29, a33, a40, a46, a50 | Store unique Zsurvie_Joueurs_v1, clé J_<UserId> (Studio : Zsurvie_Joueurs_Studio), schéma v2 publié par a27 avec les champs de a07, a08, a10, a13, a15, a22, a40, a46 et a50, écrit par UpdateAsync via Donnees.Modifier sous verrou de session. Gains : Donnees.AjouterGemmes(joueur, n, source) et Donnees.CrediterRun(joueur, runId, totalRun), idempotent sur un runId GUID créé par la Prairie (transformations de a29 intégrées). Supprimés : Gemmes_v1 (a06), Zsurvie_Profils_v1 et le store de Transactions (a07, a29), la clé Survivant_ (a15), PeluchesSecretes_v1 (a22), Cosmetiques_v1 (a33) et Boutique_v1 (a46) : les achats Robux vont dans Achats[PurchaseId] du profil via Donnees.EnregistrerAchat. Plafonds par appel : Jour 210, Mine 200, Dore 50, FinDeRun 1 500 (reliquat seulement) ; source ZbireSemaine supprimée. Changement de jour : Temps.cleJour() et Temps.SecondesAvantDemain() à minuit heure de Paris (heure d'été calculée côté serveur), comme le Zbire de la Semaine du canon, pour le Défi du Jour, le Calendrier, les secrets, les énigmes et le Record du Jour ; le 0 h UTC de a07, a08, a13 et a15 est abandonné. |
| Barème des gemmes, prix de l'Établi et valeurs de combat de la Maison | a06, a07, a09, a10, a27, a33 | Barème a07 unique, publié dans ReplicatedStorage.Catalogue et lu par Economie, Donnees, l'UI et l'onboarding. Jour franchi : 5 + 2 × min(jour, 15), doublé aux jours 5, 10 et 15 (le 2 + ⌊N ÷ 2⌋ et le +15 par Colosse de a06 sont retirés). Mine : commune, 1 gemme toutes les 20 s, stock 6 (2 min), versée à chaque Survivant actif dès qu'un Survivant la touche (le stock de 10 de a09 et le rythme de 30 s sont retirés). Doré : 4 gemmes par Survivant, dès le J3. Première recherche : Tourelle de toit à 40, plancher de 40 gemmes à la 1re run. Établi : base × 1,45^(niv − 1), 10 niveaux (Butin 5), bases Dégâts et Cadence 25, Portée et Réparation 20, Solidité et Butin 30, Régénération 40, Balles explosives 60 ; Solidité, Réparation et Régénération par cagnotte au prix × (0,5 + 0,5 × joueurs) ; défenses Muret 15, Tapis Collant 25, Mini-Tourelle 60, × (1 + 0,15 × (jour − 1)). Le niveau 1 de Dégâts reste à 25 : la base de 10 proposée par le Coordinateur playtests écraserait toute la courbe, c'est l'onboarding qui s'adapte. Economie est le seul handler de DemandeAchat ; le CATALOGUE et AcheterAmelioration de a33 sont supprimés. Foreuse en 5 niveaux : 5, 9, 14, 20 et 27 gemmes par heure sur 8 h, prix 100, 170, 290, 490 et 835 (a27 élargit sa plage à 5-27). Maison 1 000 PV (Solidité + 12 % par niveau) ; réparation = 1,5 % × (1 + 0,25 × niv) × (1 + 0,5 × (réparateurs − 1)) des PV max par seconde, 3 réparateurs comptés au plus ; Mini-Tourelle à 50 % des dégâts du Blaster de son poseur ; Muret 150 × 1,15^(jour − 1) PV. |
| Pièces au sol : durée, aimant et sort des pièces non ramassées | a06, a07, a09, a14, a28, a29 | Règle unique dans ReplicatedStorage.Catalogue : butin instancié par Survivant, aimant serveur de 8 studs, pièce visible 20 s (PiecesLachees porte expireA ; elle clignote 3 s avant), puis elle file vers la Maison ; au début du Répit, 50 % de la valeur des pièces expirées ou encore au sol est créditée, affichée en « +X » gris (écart soumis à Victor Lanoue). Aucune pièce ne disparaît sans retour visuel. Les durées de 12 s (a06) et 15 s (a14), l'aimant de 10 studs et le rapatriement à 100 % (a09) sont retirés. a07 recalcule les cumuls à 85 % de ramassage (≈ 780 Pièces au J5, ≈ 2 700 au J10). Jour parfait : 25 % des Pièces gagnées dans le jour, versées par Economie.ajouterPieces, jamais par un SetAttribute direct. |
| Définition du Survivant actif (gemmes, XP, multiplicateur coop) | a07, a08, a14, a26 | Un seul Economie.marquerActif et Economie.estActif : un déplacement cumulé de 4 studs, une réparation, une pose, un ping ou un tap de ciblage prioritaire marquent l'activité ; le tir automatique ne compte pas ; fenêtre de 90 s partout. À 75 s sans activité, « Zzz » au-dessus du Survivant et bip ; l'écran de fin affiche une ligne « inactif ». a08 (XP, seuil de 20 studs retiré), a14 et a26 (multiplicateur coop limité aux actifs, écart au canon §8 soumis à Victor Lanoue) l'appellent. |
| Stats du Blaster, plafonds de niveaux et effets des recherches | a07, a09, a10, a26, a28 | Un seul ReplicatedStorage.Partage.BlasterStats sur 10 niveaux, aux prix a07 : Dégâts 10 + 2 par niveau (30), Cadence 4 + 0,2 par niveau (6 tirs/s), Portée 40 + 1,2 par niveau (52), critique de base 5 % × 2, Visée critique + 2 points par niveau (25 % au maximum ; le Casqué subit alors 0,875, le pilier reste vrai), Casqué à 50 % hors critique, Balles perforantes 45 % + 5 points par niveau sur le 2e Zbire (95 %), Balles explosives 5 % de chance par niveau (50 %), rayon 6 studs, 50 % des dégâts, Butin + 10 % par niveau (niveau 5). Les plafonds de a09 (Portée 4, Cadence 5, Dégâts 8, Explosives 3), les + 25 % et + 8 % de a26 et la cadence de 3 tirs/s de a10 sont retirés. Tir automatique sur tous les appareils, rayon = Portée améliorée (écart au canon §8 soumis à Victor Lanoue), une seule boucle dans BlasterControleur (a26) ; a28 ne fait que désigner une cible prioritaire. Niveau maximal des recherches : 10, Foreuse 5 ; stades visuels des machines de a22 aux niveaux 1, 4 et 8 (Foreuse 1, 3 et 5). |
| Courbe de difficulté, Colosse et durée maximale de run | a06, a07, a14, a26, a40 | a06 publie ZbiresDefs.JOURS (jours 1 à 15), seule table ajustée en playtest et lue par HordeService. PV d'un Zbire = base × 1,15^(jour − 1) × 1,3^max(0, jour − 10) × (1 + 0,35 × (actifs − 1)) × modificateur du Défi du Jour. Zbires par jour = (18 + 7 × jour) × (1 + 0,2 × (actifs − 1)), en paquets de 3 à 5 du même type toutes les 10 s, apparitions stoppées à 72 s, restes éclatés sans butin à 80 s, plafond 60 plus le Colosse. Colosse aux jours 5, 10 et 15, par le Grand Portail Nord, 40 s après le début de la horde : PV 2 500 × 1,15^(jour − 1) × coop, enragé 60 s après son entrée (vitesse × 1,5, dégâts sur la Maison × 3) ; le Jour du Colosse dure jusqu'à sa chute. Zbire au contact de la Maison : 4 × 1,15^(jour − 1) PV/s (Costaud × 2). LIMITE_RUN à 25:00 déclenche une vraie fin de run avec les gemmes normales. L'Arrivée de 20 s est gardée pour tous et sert de décompte avant le Jour 1 (Colosse du J5 à 7:20, dans la 8e minute du canon) ; elle reste soumise à Victor Lanoue. |
| Plan de la Prairie : Mine, Établi, atterrissage, rayons et positions des POI | a10, a11, a12, a13, a14, a15, a16, a17, a18, a20, a21, a29, a36 | ReplicatedStorage.Plan v1 de a11 fait foi et tout le monde le lit. Repère : Maison centrée à l'origine, sol à Y 0, porte au Sud (+Z, côté caméra). Hiérarchie Workspace.Arene (Sol, Decor, Props, Maison, Mine, Etabli, Portails, Defenses) ; Workspace.Carte et Workspace.Maison ne sont plus attendus. Mine X 20 → 32, Z 20 → 32 (12 studs bord à bord, interprétation soumise à Victor Lanoue ; les positions (24, 0, −24), (26, −14) et (20, 0, 20) sont retirées), avec une coiffe invisible inclinée pour qu'on ne s'y perche pas. 8 portails à R 80 tagués PortailZbire (84, 85, 86 et 82 sont retirés), portail SE décalé de 20° vers le Sud pour que son axe évite la Mine, Grand Portail Nord en (0, 0, −80). Barrière à R 72 pour tous (70 et 74 sont retirés). Pose jusqu'à R 66 via Plan.posePermise, appelée par le fantôme client et par le serveur. Établi (−12, 14) sur le Parvis ; atterrissage sur le SpawnLocation (−3 ; 0,5 ; 16), à 10 studs au plus de l'Établi (le point x = +20 de a10 est retiré). Aucune Part de palier C à moins de 6 studs des 8 axes portail → Maison (les Trois Rochers de a14 sont déplacés). Îlots de 45 à 66 studs à 1 stud de haut au plus. POI et énigmes : Pique-nique en (−36, 0, 22), hors de la Mine ; Colosse endormi et Nid du Volant hors des axes et à 14 studs au moins de tout portail, interaction atteignable depuis R 72 (nez du Colosse endormi à 78 studs, tourné vers la Maison, prompt de 8 studs) ; 12 Nids du Panier renversé entre 58 et 66 studs, hors chemins ; Dalles chantantes déplacées sur le Quai des Capsules ; plaques du Filon espacées de 2 studs, seul le Survivant qui a touché la 1re plaque compte ; Douve entre 73 et 77 studs. |
| Ouverture des portails par jour | a06, a11, a14, a26, a36 | Rampe de a06 : jours 1 à 3, un seul portail de chemin par jour parmi Est, Ouest et Nord (jamais le Sud, où l'écran ne montre que 22 studs) ; jours 4 à 8, deux portails, Sud et diagonales permis ; dès le jour 9, trois ou quatre. La formule clamp(2 + 2 × Survivants, 4, 8) de a14 est retirée : la coop joue sur le nombre de Zbires. HordeService (a26) absorbe le module Portails de a14 (alerte 1,5 s, 4 s pour le Colosse, 0,8 s non ciblable stockée en ciblableA, tirage pondéré sans répéter le même portail) et trouve les portails par le tag PortailZbire et Plan.positionPortail. Le Colosse sort toujours du Grand Portail Nord. Les 4 PointLight de portail de a36 sont réattribuées chaque jour aux portails actifs. |
| Mouvement, saut et collision des défenses | a09, a12, a14, a26, a28, a29, a31, a32, a35 | ReplicatedStorage.Config.Mouvement, publié par a09 : Prairie WalkSpeed 18 en horde, 24 au Répit, 8 en réparation, CharacterUseJumpPower false et CharacterJumpHeight 0 (ajout au canon soumis à Victor Lanoue ; profil B de l'A/B de H2 : JumpHeight 5) ; Laboratoire WalkSpeed 16 et JumpHeight 7,2. Les valeurs 4,5 (a14), 5 (a09, a26) et 7,2 sur la Prairie (a12, a29) sont retirées. GardienMouvement (a29) est le seul à appliquer WalkSpeed et JumpHeight ; StatsSurvivant délègue. Défenses dans le CollisionGroup Defenses, non collidable avec Survivants : le Muret n'arrête que les Zbires simulés, et une pose dont l'emprise touche un Survivant est refusée. La 4e pose est refusée (icône PoseInterdite) ; toucher sa défense la reprend avec 50 % rendus. Grille de pose de 4 studs alignée sur le centre de la Maison, Mini-Tourelles espacées de 8 studs. Étourdissement : 2 s puis 2 s d'invulnérabilité (les 1,5 s de a14 sont retirées). Ressorts (a12) : déclenchés côté serveur, seulement si le Survivant court vers la Maison (produit scalaire > 0,7), avec GardienMouvement.accorderEnvol ; surChute passe par GardienMouvement.teleporter avec repli sur CP0 ; chrono minimal de la Tuyauterie : 22 s. DemandeDeblocage (1 toutes les 10 s) replace un joueur coincé sur le SpawnLocation libre le plus proche. |
| Maquette du HUD mobile et des menus | a09, a10, a28, a31, a32, a33, a34, a35 | Une seule maquette au gabarit 800 × 360 (UIScale = clamp(min(X/800, Y/360), 1, 1,4), CoreUISafeInsets, ResetOnSpawn false), codée par a28 seule ; le HudController de a32 est retiré, a32 garde la conception du bandeau Maison. En haut au centre, le bandeau Maison (Jour, PV, minuteur) ; Pièces en haut à gauche ; têtes des Survivants en haut à droite. En bas à droite, la Grappe de a35 : Réparer 96 px dans le coin, Muret, Mini-Tourelle, Tapis Collant et Ping en 64 px sur un arc de 150 px, 12 px d'écart, cadenas « Niv. X » sur les défenses verrouillées ; aucun bouton de saut, la zone réservée par a31 est libérée. Touches : E Réparer (InputBegan et InputEnded), 1-2-3 défenses, Q Ping, F et ButtonY Établi. Établi : bouton contextuel de 72 px à 10 studs au plus, ouverture automatique seulement au Répit, taps ignorés 0,8 s, panneau latéral droit de 55 % qui laisse Réparer visible (la zone de 60 % × 72 % de a33 est retirée). Recherches au Laboratoire : maintien de 0,5 s (a33), pas de « Confirmer ? » en 2 taps. Variante B de H2 : la rangée Poser 72 / Pings 72 de a28. Les tailles d'icônes de a34 s'alignent sur 96 et 64 px. |
| Visibilité des recherches et verrous des Capsules | a06, a07, a08, a10, a33 | Recherches visibles : Tourelle de toit au niveau 1, Visée critique au 3, Balles perforantes au 4, Foreuse au 5, dans l'ordre des prix. Doc Boulon désigne la Tourelle de toit (40 gemmes) au premier retour. Le niveau ne verrouille plus que les défenses (Muret 1, Tapis Collant 2, Mini-Tourelle 4) et le Calendrier (3). Capsule Difficile : Record Jour 10 en Normale, seule condition. Capsule du Jour et Défi du Jour : premier Colosse repoussé, seule condition. Chaque Capsule affiche sa condition sur son SurfaceGui. Aucune carte d'arrivée (a33) avant la première recherche. |
| Rythme de l'onboarding face à l'Arrivée et au prix du premier achat | a06, a10, a50 | L'Arrivée de 20 s est gardée et sert à l'anneau de portée et au joystick fantôme. Les t d'Onboarding.OUVERTURE partent du début de la horde : 13 Marcheurs entre H+3 et H+30 s, par le chemin Est puis le chemin Ouest, les 2 premiers avec ReservePour (écart soumis à Victor Lanoue). Premier éclatement avant T 60 s, premier achat (Economie.prixEtabli('Degats', 1) = 25) vers T 80 s. L'entonnoir est celui de a50 (12 étapes, via Telemetrie seulement) avec ses objectifs (J1 22 %, J7 8 %) ; l'entonnoir de 7 étapes de a10 est retiré. L'onboarding se prolonge jusqu'à l'étape PremiereRecherche. |
| Écriture de Lighting et de ClockTime sur la Prairie | a18, a19, a20, a36, a40 | AmbianceClient (a36) est le seul script qui écrit dans Lighting, Atmosphere et les ColorCorrection de la Prairie. ClockTime 14 fixe en horde et au Répit ; le Jour du Colosse, fondu de 8 s vers 17,5 au début du Répit qui le précède, synchronisé avec l'intro de la piste Colosse (a40). Pas de nuit express ni de soleil-chronomètre (variante A/B possible en vague 2, jamais à 20 Hz). CycleCiel (a19) est retiré de la Prairie ; Charte.Ambiances ne sert qu'au Laboratoire et aux plans de caméra levée ; Sky de la Prairie en faces de 256², StarCount 0. MeteoClient (a18) et AmbianceBiomes (a20) passent par AmbianceClient.definirMeteo et definirBiome. Laboratoire en ShadowMap, Shadows false ; Future seulement si 30 FPS sont mesurés à 12 joueurs sur l'Android 3 Go. Mode léger : attribut Qualite du LocalPlayer, calculé en continu par AmbianceClient (moyenne glissante de 3 s ; léger sous 27 FPS pendant 2 s, retour au-dessus de 45 FPS pendant 10 s). Sur mobile, VoileLoin est supprimé et VoileProche réduit à la moitié haute de l'écran ; aucun voile en mode léger ; aucun Clouds au Laboratoire. |
| Budgets de Parts, Neon, lumières, émetteurs et voix sur la Prairie | a11, a16, a17, a18, a20, a21, a22, a23, a24, a25, a30, a36, a37, a39 | Table unique dans ServerStorage.Outillage.Gabarit (a11), attribut Budget sur chaque dossier. Statique 6 500 Parts : sol 300 (a16), bâtiments et intérieur 650 (a21, a22), végétation Prairie et Lisière 2 200 (a17, seul constructeur de la forêt ; a20 fixe hauteurs et teintes, a21 et a24 ne posent plus d'arbres), props 1 200 (a23), tramages 350 (a20), météo 150 (a18), POI et énigmes 200, marge 1 450. Pic ≈ 6 500 + 360 Zbires + 30 Colosse + 450 défenses + 240 avatars + 300 pools ≈ 7 900. Neon (150) : Maison 16, Mine 12, portails 32, Mini-Tourelles 18, Établi 6, Colosse 4, Champignons 16, secrets 11, marge 35 ; Zbires, props et décor à 0. Lumières : workspace.Lumieres, 12 sources toutes classes (Maison 2, Mine 1, Établi 1, portails 4, Colosse 1, réserve VFX 3) ; aucune autre PointLight. Émetteurs : a37 seul propriétaire, 24 Enabled au plus (portails à Rate 6, une seule fumée, Tapis Collant en Texture fixe, lucioles comptées, Z1 seul éclatement ; le pool de cubes de a28 et la spécification de a25 sont retirés). Voix : pool de Sound créé au démarrage par a39, sans Clone ni Destroy en combat ; 16 voix = Musique 3, Ambiance 2, Joueur 3, Zbires 4, Monde 2, Interface 1, Alertes 1 ; a20 retire BoucleHorde, BoucleRepit et BoucleColosse et garde un seul bourdonnement de portail. Douve opaque en 16 MeshParts au même MeshId, flaques à Reflectance 0, Bassin de Doc Boulon en Eau-bloc de 1 stud (CountCells() = 0 dans les deux places). CastShadow false sur tout Workspace.Arene.Sol. Musique : sur la Prairie, préchargement de HordeA, Repit et Colosse seulement. |
| Rendu et animation des Zbires côté client | a24, a25, a26, a30, a36, a38 | Contrat figé dans ZbiresRendu (a26) : pool de 70 modèles créé pendant l'Arrivée depuis ReplicatedStorage.Modeles.Zbires (seul chemin), parentés à workspace.Zbires avec l'attribut Id ; Racine ancrée invisible + 3 à 5 MeshParts de a24 (700 triangles au plus ; Colosse 30 Parts), reliées par Motor6D aux noms de a38 ; un seul workspace:BulkMoveTo(racines, cframes, Enum.BulkMoveMode.FireCFrameChanged) par image ; CastShadow, CanCollide, CanQuery et CanTouch à false ; disque Encre de 0,1 stud sous le Volant et le Sauteur ; aucun Neon hors Colosse (4). a38 charge AnimationController et pistes une fois par modèle du pool, remplace Destroy par recycler(id), n'active l'Animator que sur les 20 Zbires visibles les plus proches et applique un rebond procédural au-delà. a25 retire sa demande de 12 MeshParts, a30 limite la Forge à 6 Parts. Budget : ZbiresRendu + ZbireAnimateur à 3 ms par image sur l'Android 3 Go. |
| Sources de gemmes hors canon : secrets, Avent, missions | a07, a13, a15, a22, a49 | Le canon §6 fixe 5 sources (Mine, Doré, jours franchis, Foreuse, Défi du Jour) et Donnees.AjouterGemmes refuse toute autre source. Secrets (a13) : cosmétiques, badges, XP (barème a08) et Pièces de run, aucune gemme ; écriture via Donnees.Modifier (champ Secrets du schéma v2), le module Donnees.Profils n'existe pas ; Tableau noir recalculé à chaque changement de Temps.cleJour. Avent (a49) : XP, cosmétiques ou Foreuse Turbo ; missions hebdomadaires : 500 XP et un cosmétique ; rien n'est codé sans l'accord de Victor Lanoue. Le Filon (Mine × 2 pendant 80 s) et le Panier (Doré bonus compté dans les 60) restent, car ils passent par des sources du canon ; a07 les intègre au §5 avec la Foreuse Turbo et les week-ends × 2. |
| API du module ReplicatedStorage.Charte | a15, a17, a18, a20, a23, a24, a28, a30, a31, a36, a37, a47 | a30 livre ReplicatedStorage.Charte avant la fin de la phase 1 : Charte.Couleurs.<Nom> avec 11 Color3 aux clés ASCII Encre, Prairie, TerreBattue, Creme, ToitOrange, Or, GemmeCyan, VioletHorde, Alerte, NuitLabo, Ardoise ; Charte.teinte(nom, 'Base' ∣ 'Ombre' ∣ 'Lumiere'), avec ombre = base × 0,8 et lumière = base:Lerp(Creme, 0.2) ; sous-tables Interface (a31) et Ambiances (Laboratoire et caméras levées). Aucune autre forme : Charte.Palette, Charte.couleur() et Charte.Gemme.Lumiere sont retirés, et les appelants passent par Couleurs ou teinte. |
| États de la Maison, seuils et affichage du Record | a11, a21, a22, a28, a36, a48 | Les 3 états restent dans la place (base commune et 120 Parts de dégâts au plus) ; le client les affiche selon EtatRun.MaisonEtat en jouant sur la Transparency des groupes de dégâts, sans échange de Models avec ServerStorage. Seuils communs de 66 % et 33 % avec 5 points d'hystérésis (retour à Intacte au-dessus de 71 %, à Abîmée au-dessus de 38 %). « Record : Jour X » en SurfaceGui sur le pan Sud du toit (12 × 3 studs, PixelsPerStud 50, LightInfluence 0), texte par translator:FormatByKey('maison.record') côté client ; le BillboardGui de a21 est retiré. |
| Plan, caméra et streaming du Laboratoire | a10, a11, a12, a21, a22, a25, a27, a29, a46 | Le plan de a11 fait foi : Arbre des Recherches au centre, 12 Alcôves à R 43 nommées Workspace.Laboratoire.Alcoves.Alcove_01 à Alcove_12, Quai des Capsules au Nord dans l'axe de l'Entrée, Galerie des Zbires à l'Ouest, SpawnLocation (0 ; 0,5 ; 64), Voie d'arrivée (0, −55). a21 recale sa Rotonde (Quai au Sud, Galerie au Nord et spawn à l'Est sont retirés) et garde des Alcôves de 12 × 16 × 16 ; plafond d'au moins 36 studs au-dessus de l'anneau pour la Tuyauterie (a12). Caméra Custom pour tous au Laboratoire, novices compris (écart soumis à Victor Lanoue). Zone jouable par Parts taguées ZoneJouable (a29). StreamingEnabled (a25) et Cabine d'Essayage (a46, 12 × 12 hors du trajet spawn → Quai) attendent Victor Lanoue ; les 12 sources de lumière du Laboratoire sont réparties par a36. |
| Fiche du jeu, serveurs privés, packs d'événement et tranches analytiques | a46, a48, a49, a50 | Serveur privé à 50 R$ par mois (a46). La fiche écrit « Tir automatique sur tous les appareils » (EN « Auto-shoot on every device »). Un pack cosmétique d'événement reste en vente toute l'année après sa sortie, sans compte à rebours ni annonce de fin. a50 attend la plus grosse marche de l'entonnoir entre J8 et J12 pour les runs de rang 4 et plus (perte J5 → J6 de 20 % au plus), analyse à part les 3 premières runs, découpe les jours en J1-4, J5-7, J8-11, J12+ et alerte si la médiane des runs de rang 4 et plus passe sous le J8. La date de lancement du 16 octobre 2026 reste à confirmer par le producteur. |

## 📋 Plan de production
# Zsurvie : plan de production

*Sonia Verne (a02), productrice. Version du 26/09/2026. Le détail des 45 tâches (T01 à T45) est dans `a02-plan-de-production.json`.*

## 1. Décisions de production

- **Lancement de la v1.0 : vendredi 20 novembre 2026.** Je ne confirme pas le 16 octobre. Les 473 tâches proposées représentent environ 1 170 jours-personne bruts (S = 1 j, M = 3 j, L = 6 j), soit environ 950 après dédoublonnage. Le chemin critique, du Plan à la performance, demande à lui seul 7 semaines.
- **Dédoublonnage :** les 7 greybox proposées pour la Prairie deviennent une seule (T09). Les tâches supprimées par les arbitrages ne sont pas planifiées : HudController (a32), Horde.Portails (a14), AcheterAmelioration (a33), CycleCiel sur la Prairie (a19), forêts de a20 et a21, boucles SoundService (a20), stores Boutique_v1 et Cosmetiques_v1.
- **Correction :** le tableur v2 de a07 prend Dégâts niveau 1 à 25 Pièces, et non 10.
- **Après le lancement :** la v1.1 sort le 01/12 avec l'Avent de Doc Boulon (sous réserve de l'accord de Victor Lanoue) et les peluches de a22. La v1.2 sort en janvier avec le Grand Givre et les traductions ES et PT-BR. La Nuit des Citrouilles tombe avant le lancement, elle est reportée à 2027.

## 2. Jalons

| Jalon | Date | Critères de validation |
|---|---|---|
| J0 Canon et contrats gelés | ven. 02/10 | Victor Lanoue a répondu par écrit à chaque écart bloquant. Plan v1 et Charte publiés le 29/09. Catalogue, ZbiresDefs.Jours, Config.Mouvement, Reseau, EtatRun et schéma v2 versionnés. Maquettes des 8 écrans validées |
| J1 Greybox jouable | ven. 09/10 | Aller-retour par Teleport entre les 2 places. Auditeur à 0 bloquant, 6 500 Parts statiques au plus, CountCells() = 0. Caméra (0, 45, 28) validée depuis 12 points. Playtest interne à 6 sur les jours 1 à 3 |
| J2 Alpha : run complète | ven. 23/10 | Arrivée → Horde → Répit jusqu'au Colosse du J5 à 7:20. 8 Zbires (modèles provisoires admis), Établi et 3 défenses. Gemmes créditées une seule fois. 1re recherche achetée au Laboratoire. Partie à 6 clients. 1re mesure sur l'Android 3 Go |
| Revue de coupe | ven. 30/10 | Tout contenu de T34 qui n'est pas jouable passe en v1.1 |
| J3 Contenu complet | ven. 06/11 | Phases 3 et 4 closes. 10 types de Zbires finaux. Onboarding jusqu'à PremiereRecherche. Défi du Jour, Foreuse, Capsules et boutique en place. Entonnoir de 12 étapes visible. Assets uploadés et modérés |
| J4 Gel et bêta fermée | ven. 13/11 | 30 FPS et moins de 800 Mo sur l'Android 3 Go avec 6 joueurs et 60 Zbires, sur 3 mesures consécutives. Tests enfants au seuil. 0 bug bloquant. Audits à 0 faute |
| J5 Lancement v1.0 | ven. 20/11 | Go/no-go le 18/11 à 17 h. Fiche FR/EN et label Léger. Premier Zbire de la Semaine le 21/11 à 17 h (heure de Paris) |
| J6 v1.1 et bilan | 01/12 et 20/12 | Avent en ligne. Bilan à J+30 : rétention J1 d'au moins 22 %, J7 d'au moins 8 % |

## 3. Fenêtres par phase

| Phase | Fenêtre | Tâches |
|---|---|---|
| 0 Concept | 28/09 → 02/10 | T01 à T07 |
| 1 Greybox | 29/09 → 09/10 | T08 à T11 |
| 2 Environnement | 12/10 → 23/10 | T12 à T15 |
| 3 Construction | 12/10 → 06/11 | T16 à T22 |
| 4 Scripting | 05/10 → 06/11 | T23 à T34 ; T35 du 16/11 au 27/11 |
| 5 UI, lumière, polish | 26/10 → 13/11 | T36 à T39 |
| 6 Tests, publication | 23/10 → 20/12 | T40 à T45 |

Le scripting démarre sur la greybox dès le 05/10, sans attendre les décors.

## 4. Dépendances critiques

**Chemin critique :** T02 (Plan v1, 29/09) → T09 (greybox de la Prairie) → T23 (Donnees et Passage), T24 (BoucleDuJour) et T25 (HordeService) → T17 (Zbires finaux, 30/10) → T40 (performance) → T44 (go/no-go). Chaque jour perdu sur cette chaîne décale le lancement d'autant.

- T04 bloque T23 à T33 : aucune remote en dehors de ReglesRemotes, aucune RemoteFunction.
- T03 bloque T27, T28, T30 et T41 : aucun prix en dur hors du Catalogue.
- T17 alimente le pool de 70 modèles de T25. Dès l'Alpha, les modèles provisoires respectent la structure Racine + MeshParts.
- T23 (Donnees.Modifier) passe avant T27, T28, T33 et T34.
- T31 (AmbianceClient) passe avant T37 : pas de passe de lumière avant que le seul script qui écrit dans Lighting existe.
- T01 débloque T26 (rayon du tir automatique), T29 (ReservePour), T20 (Cabine d'Essayage) et le StreamingEnabled du Laboratoire.

## 5. Risques de planning

| Risque | Parade |
|---|---|
| **5 profils surchargés** pour 40 jours ouvrés : a09 ≈ 47 j, a21 ≈ 46 j, a20 ≈ 46 j, a22 ≈ 42 j, a24 ≈ 41 j | Transferts actés : retours de collecte et liaisons ContextActionService à a28, pack de retours à a37, portails à a14 et a21 seuls, forêt à a17 seul, modules du Quai à a23, peluches de a22 en v1.1. a24 fait passer les Zbires avant tout le reste |
| **Victor Lanoue en goulot** : plus de 20 validations en attente | Séance unique le 29/09 et réponse sous 24 h. Sans réponse, la valeur du canon s'applique |
| **Performance sur l'Android 3 Go** (60 Zbires, VFX, Laboratoire à 12 joueurs) | Mesure chaque vendredi dès le 23/10. Leviers dans cet ordre : Animator sur 12 Zbires au lieu de 20, attribut Qualite, attributs Nombre des VFX, Touffes au pas de 6. Le plafond de 60 Zbires reste fixe |
| **Intégration réseau et données** | Contrat v2 versionné. Tout changement passe en revue devant a27 et a03. T43 démarre dès l'Alpha |
| **Dérive de périmètre** | Ordre de coupe au 30/10 : Circuit et Ombres, Tuyauterie, secrets du Laboratoire, météo Orage et Neige, Cabine d'Essayage |
| **Runs de plus de 25 min** | T41 démarre dès l'Alpha. Seuls ZbiresDefs.Jours et le Catalogue s'ajustent |
| **Passage à l'heure d'hiver le 25/10** | Test de Temps.cleJour le 26/10 (T43) |
| **Modération des assets** (atlas, sons, vignettes) | Tous les uploads au nom du groupe avant le 06/11 |

## 6. Règles de pilotage

- Une tâche est finie quand son critère chiffré est vérifié dans Studio ou sur l'Android 3 Go, pas quand le fichier existe.
- Revue de jalon chaque vendredi à 16 h (a01, a02, a03), et point quotidien de 15 min par pôle.
- Si un bug bloquant reste ouvert au go/no-go, le lancement recule d'une semaine, au 27/11.

### Tâches
| Phase | Tâche | Agents |
|---|---|---|
| Concept & document de design | T01 Faire trancher par Victor Lanoue les écarts au canon en attente | a01, a03, a02 |
| Concept & document de design | T02 Publier ReplicatedStorage.Plan v1 et ReplicatedStorage.Charte | a11, a30 |
| Concept & document de design | T03 Publier le Catalogue, ZbiresDefs.Jours et Config.Mouvement | a07, a06, a09 |
| Concept & document de design | T04 Figer et versionner le contrat technique v2 (réseau, état, données) | a27, a29, a28 |
| Concept & document de design | T05 Maquetter les 8 écrans clés au gabarit 800 × 360 | a31, a35, a33 |
| Concept & document de design | T06 Valider la fiche technique art et les budgets par zone | a04, a24, a25 |
| Concept & document de design | T07 Valider le storyboard d'accueil et le plan de marquage | a10, a50 |
| Blocking / greybox de la map | T08 Préparer les deux places et l'outillage | a30, a16, a27 |
| Blocking / greybox de la map | T09 Monter la greybox unique de la Prairie et la valider sur téléphone | a11, a14, a35 |
| Blocking / greybox de la map | T10 Monter la greybox du Laboratoire | a11, a21, a12 |
| Blocking / greybox de la map | T11 Rendre la greybox jouable : Marcheur, tir et horde des jours 1 à 3 | a24, a38, a09 |
| Terrain & environnement | T12 Poser le sol de la Prairie et le Socle du Laboratoire | a16, a20 |
| Terrain & environnement | T13 Planter la Lisière et la végétation (a17 seul constructeur) | a17, a20, a14 |
| Terrain & environnement | T14 Construire l'eau en Eau-bloc et l'atmosphère statique | a18, a19 |
| Terrain & environnement | T15 Réserver en blocs gris les emprises des POI et des énigmes | a11, a13, a15 |
| Construction & décors | T16 Construire la Maison, la Mine, l'Établi et la Tourelle de toit | a21, a22, a24 |
| Construction & décors | T17 Modéliser et forger les 8 Zbires, le Mini-Gluant et le Colosse | a24, a30, a38 |
| Construction & décors | T18 Construire les portails, les îlots et les repères de quartier | a14, a21 |
| Construction & décors | T19 Modéliser les défenses, le kit de props et les objets du Survivant | a23, a24 |
| Construction & décors | T20 Construire le Laboratoire : Rotonde, Arbre, Alcôves, Quai et Galerie | a21, a22, a20 |
| Construction & décors | T21 Produire les cosmétiques de progression et de boutique | a08, a46 |
| Construction & décors | T22 Composer la musique et les signatures des Zbires | a40, a39 |
| Scripting & mécaniques | T23 Livrer Donnees, Passage et Temps côté serveur | a27, a29 |
| Scripting & mécaniques | T24 Coder BoucleDuJour et l'orchestration de la Prairie | a06, a26 |
| Scripting & mécaniques | T25 Coder HordeService, ZbiresRendu et ZbireAnimateur | a26, a14, a38 |
| Scripting & mécaniques | T26 Coder le combat, les défenses et le mouvement | a09, a29, a28 |
| Scripting & mécaniques | T27 Coder Economie et le butin serveur | a07, a27 |
| Scripting & mécaniques | T28 Scripter le Laboratoire, la progression et les rendez-vous quotidiens | a08, a22, a33 |
| Scripting & mécaniques | T29 Intégrer l'onboarding de la première run | a10, a28 |
| Scripting & mécaniques | T30 Coder le client : HUD unique, Grappe, Établi et Roue des Pings | a28, a35, a32 |
| Scripting & mécaniques | T31 Brancher l'ambiance, les VFX et le son sur EtatRun et Evenements | a36, a37, a39 |
| Scripting & mécaniques | T32 Coder Telemetrie et instrumenter les deux places | a50 |
| Scripting & mécaniques | T33 Coder la boutique Robux | a46, a33 |
| Scripting & mécaniques | T34 Contenu de découverte : Tuyauterie, secrets et énigmes (coupable) | a12, a13, a15 |
| Scripting & mécaniques | T35 Préparer l'Avent de Doc Boulon pour la v1.1 | a49, a01 |
| UI, lumière & polish | T36 Habiller l'interface et les icônes | a31, a34, a33 |
| UI, lumière & polish | T37 Polir la lumière et les VFX aux moments clés | a36, a37, a19 |
| UI, lumière & polish | T38 Intégrer et mixer le son et la musique | a39, a40 |
| UI, lumière & polish | T39 Produire les vignettes, les icônes et la fiche du jeu | a47, a48 |
| Tests, équilibrage & publication | T40 Mener la campagne de performance sur l'Android 3 Go | a42, a25, a26 |
| Tests, équilibrage & publication | T41 Mener les playtests d'équilibrage chronométrés | a43, a06, a07 |
| Tests, équilibrage & publication | T42 Faire tester le jeu à l'aveugle par des enfants de 9 à 13 ans | a45, a10, a35 |
| Tests, équilibrage & publication | T43 Mener les tests d'exploit et d'intégrité des données | a29, a44, a27 |
| Tests, équilibrage & publication | T44 Mener la bêta fermée, les audits et le go/no-go | a41, a03, a02 |
| Tests, équilibrage & publication | T45 Publier la v1.0 et piloter les 30 premiers jours | a50, a48, a46 |

## 📜 Scripts Luau

### a26/BlasterControleur.lua
```lua
-- StarterPlayer/StarterPlayerScripts/Controleurs/BlasterControleur (ModuleScript)
-- LA boucle de tir auto du jeu (une seule connexion Heartbeat). Cible : la cible prioritaire posée par a28
-- (tap ou clic -> ZbiresRendu.chercher -> definirCiblePrioritaire), sinon le Zbire ciblable visible le plus
-- proche dans la portée, avec 0,4 s d'hystérésis. Aucune lecture d'entrée ici : a28 gère tap, clic et boutons.
-- Le client ne fait que DEMANDER un tir ; sa traçante est une prédiction visuelle.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local BlasterStats = require(Partage:WaitForChild("BlasterStats"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))
local ZbiresRendu = require(script.Parent:WaitForChild("ZbiresRendu"))

local moduleCharte = ReplicatedStorage:FindFirstChild("Charte")
local Charte = if moduleCharte and moduleCharte:IsA("ModuleScript") then require(moduleCharte) else {}
local OR = if typeof(Charte.Or) == "Color3" then Charte.Or else Color3.fromHex("#FFC933")
local ARDOISE = if typeof(Charte.Ardoise) == "Color3" then Charte.Ardoise else Color3.fromHex("#4A4560")

local NB_TRACANTES = 12 -- créées au démarrage, recyclées en rond
local DUREE_TRACANTE = 0.07
local EPAISSEUR = 0.35
local EPAISSEUR_CRITIQUE = 0.6
local PARKING = CFrame.new(0, -210, 0)

local joueur = Players.LocalPlayer

local BlasterControleur = {}

local cibleId: number? = nil
local prioritaire: number? = nil
local dernierChangement = 0
local prochainTir = 0
local tracantes: { Part } = {}
local finTracante: { number } = {}
local suivante = 1
local connexion: RBXScriptConnection? = nil

local function estEtourdi(): boolean
	local fin = joueur:GetAttribute("EtourdiJusqua")
	return typeof(fin) == "number" and fin > workspace:GetServerTimeNow()
end

local function tracante(depart: Vector3, arrivee: Vector3, epaisseur: number, teinte: Color3)
	local longueur = (arrivee - depart).Magnitude
	if longueur < 0.5 or #tracantes == 0 then
		return
	end
	local trait = tracantes[suivante]
	finTracante[suivante] = os.clock() + DUREE_TRACANTE
	suivante = suivante % NB_TRACANTES + 1
	trait.Color = teinte
	trait.Size = Vector3.new(epaisseur, epaisseur, longueur)
	trait.CFrame = CFrame.lookAt((depart + arrivee) / 2, arrivee)
end

local function choisirCible(origine: Vector3, portee: number): number?
	local maintenant = os.clock()

	-- Cible prioritaire (a28) : tant qu'elle existe ; hors portée, le tir auto prend le relais
	local p = prioritaire
	if p then
		if ZbiresRendu.estValide(p, origine, portee) then
			cibleId = p
			return p
		elseif ZbiresRendu.position(p) == nil then
			prioritaire = nil -- vaincue ou disparue
		end
	end

	-- Option du menu Réglages : tir automatique coupé
	if joueur:GetAttribute("OptionTirAuto") == false then
		return nil
	end

	-- Tir automatique avec hystérésis : on garde la cible tant qu'elle reste valide
	local plusProche = ZbiresRendu.plusProche(origine, portee)
	local courante = cibleId
	if courante == nil or not ZbiresRendu.estValide(courante, origine, portee) then
		cibleId = plusProche
		dernierChangement = maintenant
	elseif plusProche and plusProche ~= courante and maintenant - dernierChangement >= Config.HYSTERESIS_CIBLE then
		cibleId = plusProche
		dernierChangement = maintenant
	end
	return cibleId
end

local function boucle()
	local maintenant = os.clock()
	for i, fin in finTracante do
		if fin > 0 and maintenant >= fin then
			finTracante[i] = 0
			tracantes[i].CFrame = PARKING
		end
	end

	if maintenant < prochainTir or estEtourdi() then
		return
	end
	local perso = joueur.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart")
	if not racine or not racine:IsA("BasePart") then
		return
	end
	local origine = racine.Position
	local portee = BlasterStats.portee(joueur) -- 40 à 52 studs : rayon du tir auto
	local id = choisirCible(origine, portee)
	if not id then
		return
	end
	prochainTir = maintenant + 1 / BlasterStats.cadence(joueur)
	Reseau.DemandeTir:FireServer(id)
	local arrivee = ZbiresRendu.position(id)
	if arrivee then
		tracante(origine, arrivee, EPAISSEUR, OR)
	end
end

-- Tirs des coéquipiers (les miens sont prédits) : Ardoise sur un Casqué, trait épais sur un critique.
local function surTir(nom: string): (number, number, number, number) -> ()
	return function(userId: number, _id: number, x: number, z: number)
		if userId == joueur.UserId then
			return
		end
		local tireur = Players:GetPlayerByUserId(userId)
		local perso = tireur and tireur.Character
		local racine = perso and perso:FindFirstChild("HumanoidRootPart")
		if racine and racine:IsA("BasePart") then
			tracante(
				racine.Position,
				Vector3.new(x, Config.SOL_Y + 1.5, z),
				if nom == "critique" then EPAISSEUR_CRITIQUE else EPAISSEUR,
				if nom == "coupReduit" then ARDOISE else OR
			)
		end
	end
end

-- a28 : force la cible (nil pour revenir au tir auto). Gardée jusqu'à sa disparition.
function BlasterControleur.definirCiblePrioritaire(id: number?)
	prioritaire = id
end

function BlasterControleur.demarrer()
	if connexion then
		return
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "Tracantes"
	dossier.Parent = workspace
	for i = 1, NB_TRACANTES do
		local trait = Instance.new("Part")
		trait.Anchored = true
		trait.CanCollide = false
		trait.CanQuery = false
		trait.CanTouch = false
		trait.CastShadow = false
		trait.Material = Enum.Material.SmoothPlastic
		trait.CFrame = PARKING
		trait.Parent = dossier
		tracantes[i] = trait
		finTracante[i] = 0
	end

	for _, nom in { "impact", "critique", "coupReduit" } do
		Evenements.ecouter(nom, surTir(nom))
	end
	connexion = RunService.Heartbeat:Connect(boucle)
end

return BlasterControleur
```

### a26/BlasterService.lua
```lua
-- ServerScriptService/Services/BlasterService (ModuleScript)
-- Mécanique 2 : le Blaster des Survivants, en hitscan serveur.
-- DemandeTir est branché UNIQUEMENT par Validation.brancher (aucun OnServerEvent brut). Le client demande
-- un tir sur un identifiant ; le serveur vérifie état, cadence, cible, ciblableA et distance, puis décide seul
-- du critique, de la perforation et de l'explosion. Courbes : ReplicatedStorage.Partage.BlasterStats.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local BlasterStats = require(Partage:WaitForChild("BlasterStats"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))
local HordeService = require(script.Parent:WaitForChild("HordeService"))
local StatsSurvivant = require(script.Parent:WaitForChild("StatsSurvivant"))
local Validation = require(script.Parent:WaitForChild("Validation"))

type Seau = { jetons: number, t: number }

local BlasterService = {}

local seaux: { [Player]: Seau } = {}
local aleatoire = Random.new()

-- Balles perforantes : le Zbire ciblable le plus proche derrière la cible, dans un couloir de sa largeur.
local function secondZbireAligne(impact: Vector3, direction: Vector3, exclu: number): number?
	local meilleurId, meilleureAvance = nil, math.huge
	for _, z in HordeService.dansRayon(impact, Config.PERFORATION_LONGUEUR) do
		if z.id ~= exclu then
			local rel = Vector3.new(z.pos.X - impact.X, 0, z.pos.Z - impact.Z)
			local avance = rel:Dot(direction)
			local ecart = (rel - direction * avance).Magnitude
			if avance > 0 and ecart <= z.def.rayon + 0.5 and avance < meilleureAvance then
				meilleurId, meilleureAvance = z.id, avance
			end
		end
	end
	return meilleurId
end

local function surDemandeTir(joueur: Player, cibleId: number)
	-- 1. Forme (Validation a déjà vérifié le type) : un entier fini
	if cibleId ~= cibleId or cibleId % 1 ~= 0 then
		return
	end
	local seau = seaux[joueur]
	if not seau or StatsSurvivant.estEtourdi(joueur) then
		return
	end

	-- 2. Cadence : seau à jetons rempli à la cadence du joueur, 2 tirs d'avance au maximum
	local maintenant = os.clock()
	seau.jetons = math.min(Config.TIR_RAFALE, seau.jetons + (maintenant - seau.t) * BlasterStats.cadence(joueur))
	seau.t = maintenant
	if seau.jetons < 1 then
		return
	end

	-- 3. Cible vivante, sortie du portail depuis 0,8 s, à portée (distance au sol + tolérance de 4 studs)
	local racine = StatsSurvivant.racine(joueur)
	local cible = HordeService.obtenir(cibleId)
	if not racine or not cible or not HordeService.estCiblable(cible) then
		return
	end
	local vers = Vector3.new(cible.pos.X - racine.Position.X, 0, cible.pos.Z - racine.Position.Z)
	if vers.Magnitude > BlasterStats.portee(joueur) + cible.def.rayon + Config.TIR_TOLERANCE then
		return
	end
	seau.jetons -= 1

	-- 4. Dégâts : le serveur tire le critique ; HordeService applique la règle du Casqué
	local base = BlasterStats.degats(joueur)
	local critique = aleatoire:NextNumber() < BlasterStats.chanceCritique(joueur)
	local degats = if critique then base * BlasterStats.MULT_CRITIQUE else base
	local impact = cible.pos
	local _, _, reduit = HordeService.infligerDegats(cibleId, degats, critique, joueur)

	-- 5. Balles perforantes (Recherche) : le 2e Zbire aligné prend 50 % à 95 % du coup
	local partPerforation = BlasterStats.perforation(joueur)
	if partPerforation > 0 and vers.Magnitude > 0.01 then
		local second = secondZbireAligne(impact, vers.Unit, cibleId)
		if second then
			HordeService.infligerDegats(second, degats * partPerforation, critique, joueur)
		end
	end

	-- 6. Balles explosives (Établi) : 5 % de chance par niveau, 50 % des dégâts de base dans 6 studs
	local explose = aleatoire:NextNumber() < BlasterStats.chanceExplosion(joueur)
	if explose then
		HordeService.degatsZone(impact, BlasterStats.EXPLOSION_RAYON, base * BlasterStats.EXPLOSION_PART, joueur, cibleId)
	end

	-- 7. Flux Evenements : un seul message par tir, nommé d'après le coup principal
	local nom = if critique then "critique" elseif reduit then "coupReduit" else "impact"
	Evenements.publier(nom, joueur.UserId, cibleId, impact.X, impact.Z, explose)
end

function BlasterService.init()
	local function ajouter(joueur: Player)
		seaux[joueur] = { jetons = 1, t = os.clock() }
	end
	Players.PlayerAdded:Connect(ajouter)
	for _, joueur in Players:GetPlayers() do
		ajouter(joueur)
	end
	Players.PlayerRemoving:Connect(function(joueur)
		seaux[joueur] = nil
	end)
	Validation.brancher(Reseau.DemandeTir, { arguments = { "number" }, maxParSeconde = 10 }, surDemandeTir)
end

return BlasterService
```

### a26/BlasterStats.lua
```lua
-- ReplicatedStorage/Partage/BlasterStats (ModuleScript)
-- SOURCE UNIQUE des courbes du Blaster (Établi et Recherches), identique serveur et client.
-- a07 (prix des 10 niveaux) et a09 (UI de l'Établi) lisent ce module ; aucune autre courbe ne fait foi.
-- Niveaux lus dans les attributs du Player, écrits UNIQUEMENT par le serveur :
--   Établi (remis à 0 à chaque run) : NivDegats, NivCadence, NivPortee, NivExplosives, NivButin
--   Recherches (DataStore)          : RechViseeCritique, RechBallesPerforantes

local MAX = table.freeze({
	NivDegats = 10,
	NivCadence = 10,
	NivPortee = 10,
	NivExplosives = 10,
	NivButin = 5,
	RechViseeCritique = 10,
	RechBallesPerforantes = 10,
})

-- Valeur de chaque stat au niveau n (0 = rien acheté).
local COURBES: { [string]: (number) -> number } = {
	NivDegats = function(n) return 10 + 2 * n end, -- 10 -> 30
	NivCadence = function(n) return 4 + 0.2 * n end, -- tirs/s, 4 -> 6
	NivPortee = function(n) return 40 + 1.2 * n end, -- studs, 40 -> 52 = rayon du tir auto
	NivExplosives = function(n) return 0.05 * n end, -- chance par tir, 0 -> 50 %
	NivButin = function(n) return 1 + 0.1 * n end, -- Pièces, x 1 -> x 1,5
	RechViseeCritique = function(n) return 0.05 + 0.02 * n end, -- chance, 5 % -> 25 %
	RechBallesPerforantes = function(n) return if n > 0 then 0.45 + 0.05 * n else 0 end, -- 2e Zbire, 50 % -> 95 %
}

local BlasterStats = {
	MAX = MAX,
	MULT_CRITIQUE = 2,
	PART_CASQUE = 0.5, -- Casqué : 50 % des dégâts hors critique
	EXPLOSION_RAYON = 6, -- studs
	EXPLOSION_PART = 0.5, -- des dégâts de base, jamais critique
}

function BlasterStats.valeur(stat: string, n: number): number
	local courbe = COURBES[stat]
	assert(courbe, `Stat de Blaster inconnue : {stat}`)
	return courbe(math.clamp(math.floor(n), 0, MAX[stat]))
end

function BlasterStats.niveau(joueur: Player, stat: string): number
	local v = joueur:GetAttribute(stat)
	if typeof(v) ~= "number" or v ~= v then
		return 0
	end
	return math.clamp(math.floor(v), 0, MAX[stat])
end

local function lire(joueur: Player, stat: string): number
	return BlasterStats.valeur(stat, BlasterStats.niveau(joueur, stat))
end

function BlasterStats.degats(joueur: Player): number
	return lire(joueur, "NivDegats")
end

function BlasterStats.cadence(joueur: Player): number
	return lire(joueur, "NivCadence")
end

-- C'est aussi le rayon du tir automatique.
function BlasterStats.portee(joueur: Player): number
	return lire(joueur, "NivPortee")
end

function BlasterStats.chanceExplosion(joueur: Player): number
	return lire(joueur, "NivExplosives")
end

-- Multiplicateur des Pièces du butin instancié (lu par Economie).
function BlasterStats.butin(joueur: Player): number
	return lire(joueur, "NivButin")
end

function BlasterStats.chanceCritique(joueur: Player): number
	return lire(joueur, "RechViseeCritique")
end

-- Part des dégâts reçue par le 2e Zbire aligné (0 = pas de perforation).
function BlasterStats.perforation(joueur: Player): number
	return lire(joueur, "RechBallesPerforantes")
end

-- Dégâts moyens sur un Casqué, en fraction des dégâts de base : 0,5 x (1 - c) + 2 x c.
-- 0,875 à Visée critique 10 : le Casqué reste plus solide que les autres, le critique reste la réponse.
function BlasterStats.facteurMoyenCasque(nVisee: number): number
	local c = BlasterStats.valeur("RechViseeCritique", nVisee)
	return BlasterStats.PART_CASQUE * (1 - c) + BlasterStats.MULT_CRITIQUE * c
end

return table.freeze(BlasterStats)
```

### a26/ClientDemarrage.client.lua
```lua
-- StarterPlayer/StarterPlayerScripts/ClientDemarrage (LocalScript)
-- Point d'entrée client de la place Prairie : pool des Zbires (pendant l'Arrivée), tir auto, déblocage.

local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local Reseau = require(Partage:WaitForChild("Reseau"))

local Controleurs = script.Parent:WaitForChild("Controleurs")
local ZbiresRendu = require(Controleurs:WaitForChild("ZbiresRendu"))
local BlasterControleur = require(Controleurs:WaitForChild("BlasterControleur"))

-- On ne meurt jamais : le bouton « Réinitialiser » du menu Roblox sert à SE DÉBLOQUER.
-- Le client limite à 1 demande toutes les 10 s ; le serveur revérifie et choisit seul le SpawnLocation.
local deblocage = Instance.new("BindableEvent")
local derniereDemande = -math.huge
deblocage.Event:Connect(function()
	local maintenant = os.clock()
	if maintenant - derniereDemande < Config.DEBLOCAGE_INTERVALLE then
		return
	end
	derniereDemande = maintenant
	Reseau.DemandeDeblocage:FireServer()
end)

task.spawn(function()
	for _ = 1, 20 do
		if pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", deblocage) then
			return
		end
		task.wait(0.5)
	end
end)

ZbiresRendu.preparer() -- 70 modèles pendant l'Arrivée, 5 par image
ZbiresRendu.demarrer()
BlasterControleur.demarrer()
```

### a26/Config.lua
```lua
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
```

### a26/Demarrage.server.lua
```lua
-- ServerScriptService/Demarrage (Script)
-- Point d'entrée serveur de la place Prairie. Ordre : Survivants, Horde, Blaster, puis les autres services.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Partage"):WaitForChild("Config"))
local Services = ServerScriptService:WaitForChild("Services")
local StatsSurvivant = require(Services:WaitForChild("StatsSurvivant"))
local HordeService = require(Services:WaitForChild("HordeService"))
local BlasterService = require(Services:WaitForChild("BlasterService"))

-- Economie.estActif décide qui compte dans « actifs » (PV et effectifs). Sans Economie : tout le monde.
local moduleEconomie = Services:FindFirstChild("Economie")
local Economie = if moduleEconomie and moduleEconomie:IsA("ModuleScript") then require(moduleEconomie) else nil

StatsSurvivant.init()
HordeService.init(if Economie then Economie.estActif else nil)
BlasterService.init()

-- Branchements des services de l'équipe :
--   HordeService.on("maison", MaisonService.subir)               -- dégâts cumulés du tick
--   HordeService.on("vaincu", Economie.surZbireVaincu)           -- Pièces x BlasterStats.butin(tueur)
--   HordeService.on("vaincu", GalerieService.compterElimination) -- paliers 10 / 100 / 1 000
--   JourService : HordeService.demarrerJour(j) et StatsSurvivant.definirAllurePhase("Horde") au début des 80 s,
--                 StatsSurvivant.definirAllurePhase("Repit") pendant les 15 s

-- Mode test greybox : attribut booléen ModeTest = true sur Workspace ; JourTest = 5 pour le Colosse d'emblée.
if workspace:GetAttribute("ModeTest") == true then
	local degatsMaison = 0
	HordeService.on("maison", function(degats: number)
		degatsMaison += degats
		workspace:SetAttribute("TestDegatsMaison", math.round(degatsMaison))
	end)
	HordeService.on("vaincu", function(typeId: string, _position: Vector3, tueur: Player?)
		print(`[ModeTest] {typeId} vaincu par {if tueur then tueur.Name else "une défense"}`)
	end)

	HordeService.demarrer()
	local premier = workspace:GetAttribute("JourTest")
	local jour = if typeof(premier) == "number" then math.max(1, math.floor(premier)) else 1
	while workspace:GetAttribute("ModeTest") == true do
		workspace:SetAttribute("JourCourant", jour)
		StatsSurvivant.definirAllurePhase("Horde")
		HordeService.demarrerJour(jour)
		task.wait(Config.DUREE_HORDE)
		StatsSurvivant.definirAllurePhase("Repit")
		task.wait(Config.DUREE_REPIT)
		jour += 1
	end
end
```

### a26/HordeService.lua
```lua
-- ServerScriptService/Services/HordeService (ModuleScript)
-- Mécanique 1 : la Horde des Zbires. Simulation 100 % serveur : ni Part ni Humanoid.
-- Absorbe ServerScriptService.Horde.Portails (a14) : portails tagués, rampe de a06, alerte, tirage pondéré.
-- Le serveur calcule position, PV et cible 10 fois par seconde ; ZbiresRendu lisse l'affichage.
-- Toute source de dégâts (Blaster, Mini-Tourelle, Tourelle de toit) passe par HordeService.infligerDegats.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local ZbiresDefs = require(Partage:WaitForChild("ZbiresDefs"))
local BlasterStats = require(Partage:WaitForChild("BlasterStats"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))
local Plan = require(ReplicatedStorage:WaitForChild("Plan"))
local StatsSurvivant = require(script.Parent:WaitForChild("StatsSurvivant"))

export type Zbire = {
	id: number,
	type: string,
	def: ZbiresDefs.Def,
	pos: Vector3,
	cible: Vector3,
	pv: number,
	pvMax: number,
	sortA: number, -- os.clock de la sortie du portail (fin de l'alerte)
	ciblableA: number, -- sortA + 0,8 s : avant, ni tir, ni tourelle, ni coup aux Survivants
	enrageA: number, -- Colosse : sortA + 60 s ; math.huge pour les autres
	cap: number, -- radians ; CFrame.Angles(0, cap, 0) regarde vers la cible
	etat: number, -- drapeaux Config.ETAT_* du dernier tick
	prochainCoupSurvivant: number,
	prochaineOnde: number,
	ondeA: number?,
}

type Obstacle = { pos: Vector3, rayon: number, frapper: (degats: number) -> () }
type ZoneLente = { pos: Vector3, rayon: number, facteur: number }
type Entree = { type: string, cframe: CFrame? }
type Portail = { pos: Vector3, poids: number, index: number }

local TAU = 2 * math.pi

local HordeService = {}

local zbires: { [number]: Zbire } = {}
local compte: { [string]: number } = {} -- Zbires en jeu par type (quotas du pool client)
local nbDansPlafond = 0 -- Colosse exclu
local prochainId = 0
local file: { Entree } = {}
local programme: { string } = {} -- Zbires du jour, mélangés, lâchés selon la rampe
local liberes = 0
local debutJour = 0
local jour = 1
local tension = 0
local portailsOuverts = Config.NB_PORTAILS
local modificateurs = { pv = 1, vitesse = 1 }
local portails: { Portail } = {}
local dernierPortail = 0
local actifs = 1
local estActif: (Player) -> boolean = function(_joueur: Player): boolean
	return true
end
local obstacles: { [any]: Obstacle } = {}
local zonesLentes: { [any]: ZoneLente } = {}
local ecouteurs: { [string]: { (...any) -> () } } = { apparu = {}, vaincu = {}, maison = {}, enfui = {} }
local connexion: RBXScriptConnection? = nil
local accumulateur = 0
local aleatoire = Random.new()

--------------------------------------------------------------------------------
-- Outils
--------------------------------------------------------------------------------

local function plat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function auSol(v: Vector3): Vector3
	return Vector3.new(v.X, Config.SOL_Y, v.Z)
end

local function distancePlate(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

local function capVers(direction: Vector3): number
	return math.atan2(-direction.X, -direction.Z)
end

-- Les écouteurs tournent APRÈS le tick : ils peuvent appeler arreter() ou infligerDegats() sans risque.
local function emettre(nom: string, ...: any)
	for _, fn in ecouteurs[nom] do
		task.defer(fn, ...)
	end
end

local function nouvelId(): number
	repeat
		prochainId = prochainId % 65535 + 1 -- tient sur 2 octets dans EtatZbires
	until zbires[prochainId] == nil
	return prochainId
end

-- « actifs » = Survivants pour qui Economie.estActif renvoie vrai, entre 1 et 6.
local function compterActifs(): number
	local n = 0
	for _, joueur in Players:GetPlayers() do
		if estActif(joueur) then
			n += 1
		end
	end
	return math.clamp(n, 1, Config.JOUEURS_MAX)
end

--------------------------------------------------------------------------------
-- Portails (ex-ServerScriptService.Horde.Portails de a14)
--------------------------------------------------------------------------------

-- Tag PortailZbire ; position exacte = Plan.positionPortail(Index) si l'attribut Index existe.
-- Sans portail tagué (greybox) : Plan.positionPortail(1 à 8).
local function rafraichirPortails()
	table.clear(portails)
	for _, instance in CollectionService:GetTagged(Config.TAG_PORTAIL) do
		if instance:IsA("PVInstance") then
			local index = instance:GetAttribute("Index")
			local poids = instance:GetAttribute("Poids")
			local aIndex = typeof(index) == "number"
			table.insert(portails, {
				pos = auSol(if aIndex then Plan.positionPortail(index) else instance:GetPivot().Position),
				poids = if typeof(poids) == "number" and poids > 0 then poids else 1,
				index = if aIndex then index else math.huge,
			})
		end
	end
	if #portails == 0 then
		for i = 1, Config.NB_PORTAILS do
			table.insert(portails, { pos = auSol(Plan.positionPortail(i)), poids = 1, index = i })
		end
	end
	table.sort(portails, function(a: Portail, b: Portail): boolean
		return a.index < b.index
	end)
	dernierPortail = 0
end

-- Tirage pondéré (attribut Poids) parmi les portails ouverts ce jour, jamais deux fois de suite le même.
local function tirerPortail(): Vector3
	local n = math.min(portailsOuverts, #portails)
	local function eligible(i: number): boolean
		return n == 1 or i ~= dernierPortail
	end
	local total = 0
	for i = 1, n do
		if eligible(i) then
			total += portails[i].poids
		end
	end
	local tirage = aleatoire:NextNumber() * total
	local choisi = 0
	for i = 1, n do
		if eligible(i) then
			choisi = i
			tirage -= portails[i].poids
			if tirage <= 0 then
				break
			end
		end
	end
	dernierPortail = choisi
	local d = Config.PORTAIL_DISPERSION
	return portails[choisi].pos + Vector3.new(aleatoire:NextNumber(-d, d), 0, aleatoire:NextNumber(-d, d))
end

-- Le Doré coupe la Prairie en corde, sans passer par la Maison, et ressort de l'autre côté.
local function cibleFuite(depart: Vector3): Vector3
	local rel = depart - Config.CENTRE
	local sens = if aleatoire:NextNumber() < 0.5 then -1 else 1
	local angle = math.atan2(rel.Z, rel.X) + math.pi + sens * Config.DORE_DECALAGE
	return auSol(Config.CENTRE + Vector3.new(math.cos(angle), 0, math.sin(angle)) * Config.DORE_RAYON_FUITE)
end

local function contactMaison(pos: Vector3, rayon: number): boolean
	local d = pos - Config.CENTRE
	return math.max(math.abs(d.X), math.abs(d.Z)) <= Config.MAISON_DEMI + rayon
end

local function facteurSol(pos: Vector3): number
	local facteur = 1
	for _, zone in zonesLentes do
		if distancePlate(pos, zone.pos) <= zone.rayon then
			facteur = math.min(facteur, zone.facteur)
		end
	end
	return facteur
end

local function obstacleSur(pos: Vector3, rayon: number): any
	for cle, obstacle in obstacles do
		if distancePlate(pos, obstacle.pos) < obstacle.rayon + rayon then
			return cle
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Cycle de vie d'un Zbire
--------------------------------------------------------------------------------

local function creer(entree: Entree, maintenant: number)
	local typeId = entree.type
	local def = ZbiresDefs.Types[typeId]
	local depart: Vector3, alerte: number
	if entree.cframe then
		depart, alerte = auSol(entree.cframe.Position), 0 -- division du Gluant : sur place
	elseif def.boss then
		depart, alerte = auSol(Config.GRAND_PORTAIL), Config.ALERTE_COLOSSE
	else
		depart, alerte = tirerPortail(), Config.ALERTE_PORTAIL
	end
	local cible = if def.fuyard then cibleFuite(depart) else auSol(Config.CENTRE)
	local pvMax = ZbiresDefs.pvMax(typeId, jour, tension, actifs, modificateurs.pv)
	local sortA = maintenant + alerte
	local id = nouvelId()
	zbires[id] = {
		id = id,
		type = typeId,
		def = def,
		pos = depart,
		cible = cible,
		pv = pvMax,
		pvMax = pvMax,
		sortA = sortA,
		ciblableA = sortA + Config.DELAI_CIBLABLE,
		enrageA = if def.boss then sortA + Config.COLOSSE_ENRAGE_APRES else math.huge,
		cap = capVers(plat(cible - depart)),
		etat = 0,
		prochainCoupSurvivant = 0,
		prochaineOnde = if def.onde then sortA + def.onde.periode else math.huge,
		ondeA = nil,
	}
	compte[typeId] = (compte[typeId] or 0) + 1
	if def.boss then
		workspace:SetAttribute("PVColosse", 1) -- jauge du HUD
	else
		nbDansPlafond += 1
	end
	Evenements.publier("apparition", id, typeId, depart.X, depart.Z, alerte)
	emettre("apparu", typeId)
end

local function retirer(z: Zbire)
	zbires[z.id] = nil
	compte[z.type] -= 1
	if z.def.boss then
		workspace:SetAttribute("PVColosse", nil)
		workspace:SetAttribute("ColosseEnrage", nil)
	else
		nbDansPlafond -= 1
	end
end

local function vaincre(z: Zbire, tueur: Player?, critique: boolean)
	retirer(z)
	Evenements.publier("eclatement", z.id, z.type, z.pos.X, z.pos.Z, critique)
	local division = z.def.division
	if division then
		Evenements.publier("division", z.id, z.pos.X, z.pos.Z)
		local versMaison = plat(Config.CENTRE - z.pos)
		local cadre = if versMaison.Magnitude > 0.01 then CFrame.lookAt(z.pos, z.pos + versMaison) else CFrame.new(z.pos)
		HordeService.ajouterALaFile(division, 2, cadre)
	end
	emettre("vaincu", z.type, z.pos, tueur, critique)
end

-- 3 sorties par tick au plus. Une entrée ne sort que si le plafond de 60 (Colosse exclu) ET le quota
-- de rendu de son type (pool client de 70) ont une place ; sinon les entrées suivantes passent devant.
local function traiterFile(maintenant: number)
	local crees, i = 0, 1
	while i <= #file and crees < Config.APPARITIONS_PAR_TICK do
		local entree = file[i]
		local boss = ZbiresDefs.Types[entree.type].boss == true
		local quota = Config.QUOTAS_RENDU[entree.type] or 0
		if (compte[entree.type] or 0) < quota and (boss or nbDansPlafond < Config.MAX_ZBIRES) then
			table.remove(file, i)
			creer(entree, maintenant)
			crees += 1
		else
			i += 1
		end
	end
end

-- Rampe de a06 : part cumulée du programme du jour mise en file à l'instant t des 80 s.
local function libererProgramme(maintenant: number)
	local objectif = math.floor(#programme * ZbiresDefs.rampe((maintenant - debutJour) / Config.DUREE_HORDE) + 0.5)
	while liberes < objectif do
		liberes += 1
		table.insert(file, { type = programme[liberes] })
	end
end

--------------------------------------------------------------------------------
-- Tick serveur (10 Hz)
--------------------------------------------------------------------------------

-- 9 octets par Zbire : id u16, x i16 et z i16 au 1/10 de stud, PV u8, cap u8, type (4 bits) + état (4 bits).
local function diffuser(vivants: { Zbire })
	local n = #vivants
	if n == 0 then
		return
	end
	local taille = Config.OCTETS_PAR_ZBIRE
	local tampon = buffer.create(n * taille)
	for i, z in vivants do
		local o = (i - 1) * taille
		buffer.writeu16(tampon, o, z.id)
		buffer.writei16(tampon, o + 2, math.round((z.pos.X - Config.CENTRE.X) * 10))
		buffer.writei16(tampon, o + 4, math.round((z.pos.Z - Config.CENTRE.Z) * 10))
		buffer.writeu8(tampon, o + 6, math.clamp(math.ceil(z.pv / z.pvMax * 255), 0, 255))
		buffer.writeu8(tampon, o + 7, math.round(z.cap % TAU / TAU * 256) % 256)
		buffer.writeu8(tampon, o + 8, ZbiresDefs.INDEX[z.type] + z.etat * 16)
	end
	Reseau.EtatZbires:FireAllClients(tampon)
end

local function pas(dt: number)
	debug.profilebegin("HordeTick")
	local maintenant = os.clock()
	actifs = compterActifs()
	libererProgramme(maintenant)
	traiterFile(maintenant)

	local survivants = StatsSurvivant.positions()
	local vivants: { Zbire } = {}
	local degatsMaison = 0
	local degatsObstacles: { [any]: number } = {}
	local dpsJour = Config.DPS_MAISON * ZbiresDefs.facteurJour(jour)

	for id, z in zbires do
		if maintenant < z.sortA then
			continue -- encore dans le portail : alerte en cours
		end
		local def = z.def

		-- 0. Le Doré sort de la Prairie
		if def.fuyard and distancePlate(z.cible, z.pos) < 2 then
			retirer(z)
			emettre("enfui", z.type)
			continue
		end
		table.insert(vivants, z)

		local ciblable = maintenant >= z.ciblableA
		local enrage = maintenant >= z.enrageA
		local etat = if ciblable then Config.ETAT_CIBLABLE else 0
		if enrage then
			if bit32.band(z.etat, Config.ETAT_ENRAGE) == 0 then
				workspace:SetAttribute("ColosseEnrage", true)
			end
			etat += Config.ETAT_ENRAGE
		end
		local dps = dpsJour * def.multMaison * (if enrage then Config.COLOSSE_ENRAGE_MAISON else 1)

		-- 1. Coup au contact d'un Survivant : étourdi 2 s, jamais de dégâts
		if def.frappeSurvivants and ciblable and maintenant >= z.prochainCoupSurvivant then
			for _, s in survivants do
				if distancePlate(s.pos, z.pos) <= def.rayon + Config.PORTEE_COUP_ZBIRE and StatsSurvivant.etourdir(s.joueur) then
					z.prochainCoupSurvivant = maintenant + Config.RECHARGE_COUP_SURVIVANT
					break
				end
			end
		end

		-- 2. Onde du Colosse : annoncée au sol, puis étourdit tout le rayon ; immobile pendant l'annonce
		local onde = def.onde
		if onde then
			if z.ondeA == nil and maintenant >= z.prochaineOnde then
				z.ondeA = maintenant + onde.preavis
				Evenements.publier("onde", id, z.pos.X, z.pos.Z, onde.rayon, onde.preavis)
			elseif z.ondeA and maintenant >= z.ondeA then
				z.ondeA = nil
				z.prochaineOnde = maintenant + onde.periode
				for _, s in survivants do
					if distancePlate(s.pos, z.pos) <= onde.rayon then
						StatsSurvivant.etourdir(s.joueur)
					end
				end
			end
			if z.ondeA then
				z.etat = etat
				continue
			end
		end

		-- 3. Au contact de la Maison : débit continu, cumulé sur le tick
		if not def.fuyard and contactMaison(z.pos, def.rayon) then
			degatsMaison += dps * dt
			z.etat = etat + Config.ETAT_CONTACT
			continue
		end

		-- 4. Déplacement en ligne droite vers la cible
		local vers = plat(z.cible - z.pos)
		local distance = vers.Magnitude
		local vitesse = def.vitesse * modificateurs.vitesse * (if enrage then Config.COLOSSE_ENRAGE_VITESSE else 1)
		if def.bonds then
			-- Sauteur : immobile 55 % du temps, puis un bond de 0,45 s (même vitesse moyenne)
			if (maintenant - z.sortA) % def.bonds < def.bonds * 0.55 then
				vitesse = 0
			else
				vitesse /= 0.45
				if bit32.band(z.etat, Config.ETAT_BOND) == 0 then
					Evenements.publier("bond", id)
				end
				etat += Config.ETAT_BOND
			end
		end
		if not def.vole then
			vitesse *= facteurSol(z.pos) -- Tapis Collant
		end
		if vitesse > 0 and distance > 0 then
			z.cap = capVers(vers)
			local suivant = z.pos + vers.Unit * math.min(vitesse * dt, distance)
			local cle = if def.vole then nil else obstacleSur(suivant, def.rayon)
			if cle ~= nil then
				-- Muret : le Zbire s'arrête et le frappe au même débit que la Maison ; le Volant passe au-dessus
				if dps > 0 then
					degatsObstacles[cle] = (degatsObstacles[cle] or 0) + dps * dt
				end
			else
				z.pos = suivant
			end
		end
		z.etat = etat
	end

	-- 5. Séparation douce : aucune silhouette ne se cache sous une autre
	for i = 1, #vivants do
		local a = vivants[i]
		for j = i + 1, #vivants do
			local b = vivants[j]
			if (a.def.vole == true) == (b.def.vole == true) then
				local d = plat(b.pos - a.pos)
				local mini = a.def.rayon + b.def.rayon
				local m = d.Magnitude
				if m < mini and m > 0.01 then
					local correction = d.Unit * ((mini - m) * 0.5)
					local partA = b.def.rayon / mini -- le plus gros bouge le moins
					a.pos -= correction * partA
					b.pos += correction * (1 - partA)
				end
			end
		end
	end

	-- 6. Dégâts cumulés : un seul appel par tick pour la Maison et pour chaque Muret touché
	if degatsMaison > 0 then
		emettre("maison", degatsMaison)
	end
	for cle, degats in degatsObstacles do
		local obstacle = obstacles[cle]
		if obstacle then
			task.defer(obstacle.frapper, degats)
		end
	end

	-- 7. Diffusion compacte à tous les clients (un arrivant reconstruit la horde dès ce paquet)
	diffuser(vivants)
	debug.profileend()
end

--------------------------------------------------------------------------------
-- API publique
--------------------------------------------------------------------------------

-- JourService, au début des 80 s de horde. Lit ZbiresDefs.JOURS (a06) ; Colosse les jours multiples de 5.
function HordeService.demarrerJour(n: number)
	jour = math.max(1, math.floor(n))
	local programmeJour = ZbiresDefs.jour(jour)
	tension = programmeJour.tension or 0
	portailsOuverts = math.clamp(programmeJour.portails or Config.NB_PORTAILS, 1, math.max(#portails, 1))
	actifs = compterActifs()
	local facteur = 1 + Config.COOP_NOMBRE * (actifs - 1)
	table.clear(programme)
	for _, typeId in ZbiresDefs.ORDRE do
		local effectif = programmeJour.zbires[typeId]
		if effectif and not ZbiresDefs.Types[typeId].boss then
			for _ = 1, math.round(effectif * facteur) do
				table.insert(programme, typeId)
			end
		end
	end
	for i = #programme, 2, -1 do -- mélange de Fisher-Yates
		local j = aleatoire:NextInteger(1, i)
		programme[i], programme[j] = programme[j], programme[i]
	end
	liberes = 0
	debutJour = os.clock()
	if jour % Config.PERIODE_COLOSSE == 0 then
		table.insert(file, 1, { type = "Colosse" })
	end
end

-- Met des Zbires en file. Avec cframe : sortie sur place, en tête de file, sans alerte, écartés de 3 studs.
function HordeService.ajouterALaFile(typeId: string, nombre: number?, cframe: CFrame?)
	assert(ZbiresDefs.Types[typeId], `Zbire inconnu : {typeId}`)
	local n = nombre or 1
	for i = 1, n do
		if cframe then
			local decalage = cframe.RightVector * ((i - (n + 1) / 2) * 3)
			table.insert(file, i, { type = typeId, cframe = cframe + decalage })
		else
			table.insert(file, { type = typeId })
		end
	end
end

-- Défi du Jour et Zbire de la Semaine : { pv = 1.2, vitesse = 1.1 } par exemple.
function HordeService.definirModificateurs(m: { pv: number?, vitesse: number? })
	modificateurs = { pv = m.pv or 1, vitesse = m.vitesse or 1 }
end

function HordeService.estCiblable(z: Zbire): boolean
	return zbires[z.id] == z and os.clock() >= z.ciblableA
end

-- Seule porte d'entrée des dégâts. Renvoie (vaincu, dégâts réels, coup réduit par le casque).
function HordeService.infligerDegats(id: number, degats: number, critique: boolean, source: Player?): (boolean, number, boolean)
	local z = zbires[id]
	if not z or degats <= 0 or os.clock() < z.ciblableA then
		return false, 0, false
	end
	local reduit = z.def.blinde == true and not critique
	local reel = if reduit then degats * BlasterStats.PART_CASQUE else degats
	z.pv -= reel
	if z.def.boss then
		workspace:SetAttribute("PVColosse", math.max(z.pv, 0) / z.pvMax)
	end
	if z.pv <= 0 then
		vaincre(z, source, critique)
		return true, reel, reduit
	end
	return false, reel, reduit
end

-- Dégâts de zone (balles explosives, défenses) : jamais critiques. Renvoie le nombre de Zbires touchés.
function HordeService.degatsZone(centre: Vector3, rayon: number, degats: number, source: Player?, exclureId: number?): number
	local touches = 0
	for _, z in HordeService.dansRayon(centre, rayon) do
		if z.id ~= exclureId then
			HordeService.infligerDegats(z.id, degats, false, source)
			touches += 1
		end
	end
	return touches
end

-- Lecture seule par convention : ne jamais modifier la table renvoyée.
function HordeService.obtenir(id: number): Zbire?
	return zbires[id]
end

-- Zbires ciblables seulement (tourelles, explosions, perforation).
function HordeService.dansRayon(centre: Vector3, rayon: number): { Zbire }
	local maintenant = os.clock()
	local liste = {}
	for _, z in zbires do
		if maintenant >= z.ciblableA and distancePlate(z.pos, centre) <= rayon + z.def.rayon then
			table.insert(liste, z)
		end
	end
	return liste
end

function HordeService.plusProche(centre: Vector3, rayon: number): Zbire?
	local maintenant = os.clock()
	local meilleur, meilleureDistance = nil, math.huge
	for _, z in zbires do
		local d = distancePlate(z.pos, centre) - z.def.rayon
		if maintenant >= z.ciblableA and d <= rayon and d < meilleureDistance then
			meilleur, meilleureDistance = z, d
		end
	end
	return meilleur
end

function HordeService.nombreRestant(): number
	return nbDansPlafond + #file + (#programme - liberes)
end

-- Muret : bloque les Zbires au sol ; frapper(degats) reçoit le cumul du tick.
function HordeService.enregistrerObstacle(cle: any, pos: Vector3, rayon: number, frapper: (number) -> ())
	obstacles[cle] = { pos = auSol(pos), rayon = rayon, frapper = frapper }
end

function HordeService.retirerObstacle(cle: any)
	obstacles[cle] = nil
end

-- Tapis Collant : facteur de vitesse (0.5 = moitié), sans effet sur le Volant.
function HordeService.enregistrerZoneLente(cle: any, pos: Vector3, rayon: number, facteur: number)
	zonesLentes[cle] = { pos = auSol(pos), rayon = rayon, facteur = facteur }
end

function HordeService.retirerZoneLente(cle: any)
	zonesLentes[cle] = nil
end

-- "apparu" (type), "vaincu" (type, position, tueur?, critique), "maison" (dégâts du tick), "enfui" (type).
function HordeService.on(evenement: string, fn: (...any) -> ())
	local liste = ecouteurs[evenement]
	assert(liste, `Événement de horde inconnu : {evenement}`)
	table.insert(liste, fn)
end

function HordeService.demarrer()
	if connexion then
		return
	end
	accumulateur = 0
	connexion = RunService.Heartbeat:Connect(function(dt: number)
		accumulateur += dt
		if accumulateur < Config.TICK then
			return
		end
		local ecoule = math.min(accumulateur, Config.TICK * 3) -- pas de téléportation après un lag
		accumulateur = 0
		pas(ecoule)
	end)
end

-- Fin de run (Maison tombée) : plus de paquet EtatZbires, les clients rendent leurs modèles au pool en 0,5 s.
function HordeService.arreter()
	if connexion then
		connexion:Disconnect()
		connexion = nil
	end
	table.clear(zbires)
	table.clear(compte)
	table.clear(file)
	table.clear(programme)
	liberes = 0
	nbDansPlafond = 0
	workspace:SetAttribute("PVColosse", nil)
	workspace:SetAttribute("ColosseEnrage", nil)
end

-- estActifFn = Economie.estActif (nil en greybox : tout le monde compte).
function HordeService.init(estActifFn: ((Player) -> boolean)?)
	if estActifFn then
		estActif = estActifFn
	end
	rafraichirPortails()
	CollectionService:GetInstanceAddedSignal(Config.TAG_PORTAIL):Connect(rafraichirPortails)
	CollectionService:GetInstanceRemovedSignal(Config.TAG_PORTAIL):Connect(rafraichirPortails)
end

return HordeService
```

### a26/Reseau.lua
```lua
-- ReplicatedStorage/Partage/Reseau (ModuleScript)
-- RemoteEvents de la place Prairie. Le serveur les crée dans ReplicatedStorage.Remotes, le client les attend.
-- Règle du studio : le client n'envoie que des DEMANDES. Côté serveur, chaque Demande* est branchée
-- UNIQUEMENT par Validation.brancher (aucun OnServerEvent brut). Les événements visuels (impacts,
-- éclatements, ondes...) passent par le flux Evenements, pas par ce module.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DEFINITIONS = {
	-- a26
	EtatZbires = "UnreliableRemoteEvent", -- serveur -> clients : 9 octets par Zbire à 10 Hz (buffer, 549 octets au plus)
	DemandeTir = "RemoteEvent", -- client -> serveur : identifiant du Zbire visé
	DemandeDeblocage = "RemoteEvent", -- client -> serveur : bouton Réinitialiser, 1 toutes les 10 s
	-- Noms réservés pour les autres services de la run
	DemandeReparation = "RemoteEvent",
	DemandeAchat = "RemoteEvent",
	DemandePose = "RemoteEvent",
	DemandePing = "RemoteEvent",
}

local Reseau = {}

if RunService:IsServer() then
	local dossier = ReplicatedStorage:FindFirstChild("Remotes")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Remotes"
		dossier.Parent = ReplicatedStorage
	end
	for nom, classe in DEFINITIONS do
		local remote = dossier:FindFirstChild(nom)
		if not remote then
			remote = Instance.new(classe)
			remote.Name = nom
			remote.Parent = dossier
		end
		Reseau[nom] = remote
	end
else
	local dossier = ReplicatedStorage:WaitForChild("Remotes")
	for nom in DEFINITIONS do
		Reseau[nom] = dossier:WaitForChild(nom)
	end
end

return Reseau
```

### a26/StatsSurvivant.lua
```lua
-- ServerScriptService/Services/StatsSurvivant (ModuleScript)
-- États serveur du Survivant. On ne meurt jamais : un coup étourdit 2 s, puis 2 s de protection.
-- WalkSpeed et JumpHeight ont UN SEUL propriétaire, GardienMouvement : ce module ne les écrit jamais.
-- Il lui transmet les valeurs de ReplicatedStorage.Config.Mouvement (SAUT_SURVIVANT n'est lu que par lui).
-- Attributs du Player lus par l'UI : EtourdiJusqua, InvulnerableJusqua (heure de GetServerTimeNow).

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Mouvement = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Mouvement"))
local GardienMouvement = require(script.Parent:WaitForChild("GardienMouvement"))
local Validation = require(script.Parent:WaitForChild("Validation"))

export type Position = { joueur: Player, pos: Vector3 }
export type Allure = "Horde" | "Repit" | "Reparation"

local VITESSES: { [string]: number } = {
	Horde = Mouvement.VITESSE_HORDE, -- 18
	Repit = Mouvement.VITESSE_REPIT, -- 24
	Reparation = Mouvement.VITESSE_REPARATION, -- 8
}

local GROUPE_SURVIVANTS = "Survivants"
local GROUPE_DEFENSES = "Defenses"

local StatsSurvivant = {}

local allurePhase: Allure = "Horde"
local allurePerso: { [Player]: Allure } = {}
local dernierDeblocage: { [Player]: number } = {}
local spawns: { SpawnLocation } = {}

local function appliquerAllure(joueur: Player)
	GardienMouvement.definirVitesse(joueur, VITESSES[allurePerso[joueur] or allurePhase])
end

local function distancePlate(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

function StatsSurvivant.racine(joueur: Player): BasePart?
	local perso = joueur.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart")
	return if racine and racine:IsA("BasePart") then racine else nil
end

function StatsSurvivant.estEtourdi(joueur: Player): boolean
	local fin = joueur:GetAttribute("EtourdiJusqua")
	return typeof(fin) == "number" and fin > workspace:GetServerTimeNow()
end

-- Renvoie true si le Survivant vient d'être étourdi. GardienMouvement gèle puis rend la vitesse qu'il connaît.
function StatsSurvivant.etourdir(joueur: Player): boolean
	local maintenant = workspace:GetServerTimeNow()
	local invulnerable = joueur:GetAttribute("InvulnerableJusqua")
	if typeof(invulnerable) == "number" and invulnerable > maintenant then
		return false
	end
	if not StatsSurvivant.racine(joueur) then
		return false
	end
	local fin = maintenant + Mouvement.ETOURDI_DUREE
	joueur:SetAttribute("EtourdiJusqua", fin)
	joueur:SetAttribute("InvulnerableJusqua", fin + Config.ETOURDI_IMMUNITE)
	GardienMouvement.etourdir(joueur, Mouvement.ETOURDI_DUREE)
	return true
end

-- JourService : "Horde" au début des 80 s, "Repit" pendant les 15 s. S'applique aussi aux arrivants.
function StatsSurvivant.definirAllurePhase(allure: Allure)
	allurePhase = allure
	for _, joueur in Players:GetPlayers() do
		appliquerAllure(joueur)
	end
end

-- MaisonService : "Reparation" pendant une réparation, nil pour revenir à l'allure de la phase.
function StatsSurvivant.definirAllure(joueur: Player, allure: Allure?)
	allurePerso[joueur] = allure
	appliquerAllure(joueur)
end

function StatsSurvivant.positions(): { Position }
	local liste = {}
	for _, joueur in Players:GetPlayers() do
		local racine = StatsSurvivant.racine(joueur)
		if racine then
			table.insert(liste, { joueur = joueur, pos = racine.Position })
		end
	end
	return liste
end

--------------------------------------------------------------------------------
-- Déblocage (bouton Réinitialiser) : SpawnLocation libre le plus proche, via GardienMouvement.teleporter
--------------------------------------------------------------------------------

local function spawnLibre(joueur: Player, depuis: Vector3): SpawnLocation?
	local occupants = StatsSurvivant.positions()
	local libre, dLibre = nil, math.huge
	local secours, dSecours = nil, math.huge
	for _, spawn in spawns do
		if spawn.Parent then
			local d = distancePlate(spawn.Position, depuis)
			local occupe = false
			for _, s in occupants do
				if s.joueur ~= joueur and distancePlate(s.pos, spawn.Position) < Config.DEBLOCAGE_RAYON_LIBRE then
					occupe = true
					break
				end
			end
			if not occupe and d < dLibre then
				libre, dLibre = spawn, d
			end
			if d < dSecours then
				secours, dSecours = spawn, d
			end
		end
	end
	return libre or secours
end

local function surDemandeDeblocage(joueur: Player)
	local maintenant = os.clock()
	local dernier = dernierDeblocage[joueur]
	if dernier and maintenant - dernier < Config.DEBLOCAGE_INTERVALLE then
		return
	end
	local racine = StatsSurvivant.racine(joueur)
	if not racine then
		return
	end
	local spawn = spawnLibre(joueur, racine.Position)
	if not spawn then
		return
	end
	dernierDeblocage[joueur] = maintenant
	GardienMouvement.teleporter(joueur, CFrame.new(spawn.Position + Vector3.new(0, spawn.Size.Y / 2 + 3, 0)))
end

--------------------------------------------------------------------------------
-- Groupes de collision : les défenses ne bloquent jamais un Survivant
--------------------------------------------------------------------------------

local function preparerGroupes()
	for _, nom in { GROUPE_SURVIVANTS, GROUPE_DEFENSES } do
		if not PhysicsService:IsCollisionGroupRegistered(nom) then
			PhysicsService:RegisterCollisionGroup(nom)
		end
	end
	-- Les Zbires sont simulés par HordeService : une collision Muret/Survivant ne servirait qu'à piéger.
	PhysicsService:CollisionGroupSetCollidable(GROUPE_DEFENSES, GROUPE_SURVIVANTS, false)
end

local function rangerPart(d: Instance)
	if d:IsA("BasePart") then
		d.CollisionGroup = GROUPE_SURVIVANTS
	end
end

function StatsSurvivant.init()
	preparerGroupes()
	for _, d in workspace:GetDescendants() do
		if d:IsA("SpawnLocation") then
			table.insert(spawns, d)
		end
	end

	local function surPersonnage(joueur: Player, perso: Model)
		for _, d in perso:GetDescendants() do
			rangerPart(d)
		end
		perso.DescendantAdded:Connect(rangerPart)
		appliquerAllure(joueur) -- transmis à GardienMouvement ; aucune écriture de WalkSpeed ni JumpHeight ici
	end

	local function surJoueur(joueur: Player)
		joueur.CharacterAdded:Connect(function(perso)
			surPersonnage(joueur, perso)
		end)
		if joueur.Character then
			surPersonnage(joueur, joueur.Character)
		end
	end

	Players.PlayerAdded:Connect(surJoueur)
	for _, joueur in Players:GetPlayers() do
		surJoueur(joueur)
	end
	Players.PlayerRemoving:Connect(function(joueur)
		allurePerso[joueur] = nil
		dernierDeblocage[joueur] = nil
	end)

	Validation.brancher(
		Reseau.DemandeDeblocage,
		{ arguments = {}, intervalleMin = Config.DEBLOCAGE_INTERVALLE },
		surDemandeDeblocage
	)
end

return StatsSurvivant
```

### a26/ZbiresDefs.lua
```lua
-- ReplicatedStorage/Partage/ZbiresDefs (ModuleScript)
-- Bestiaire chiffré (a26) + programme des jours (a06). Les données de a06 vivent dans le sous-module
-- ZbiresDefs.Jours, qui renvoie { JOURS = { Jour }, RAMPE = { number } }. Sans lui : programme greybox.
-- Clés ASCII (Dore, Casque, MiniGluant) = noms des modèles de ReplicatedStorage.Modeles.Zbires.
-- Le champ « nom » garde le nom exact du canon pour l'affichage.

local Config = require(script.Parent:WaitForChild("Config"))

export type Onde = {
	rayon: number, -- studs
	preavis: number, -- s d'annonce au sol avant l'étourdissement
	periode: number, -- s entre deux ondes
}

export type Def = {
	nom: string,
	pv: number, -- Jour 1, solo, Tension 0
	vitesse: number, -- studs/s
	rayon: number, -- hitbox au sol, studs
	multMaison: number, -- x Config.DPS_MAISON au contact de la Maison ou d'un Muret
	pieces: number, -- par Survivant (butin instancié)
	gemmes: number, -- par Survivant
	frappeSurvivants: boolean, -- étourdit au contact
	blinde: boolean?, -- Casqué : 50 % des dégâts hors critique
	vole: boolean?, -- ignore Murets et Tapis Collants
	fuyard: boolean?, -- traverse la Prairie sans attaquer
	boss: boolean?, -- hors plafond de 60
	division: string?, -- type créé en 2 exemplaires à la mort
	bonds: number?, -- période d'un bond, s
	onde: Onde?,
}

export type Jour = {
	tension: number?, -- 0 par défaut
	portails: number?, -- portails ouverts (les N premiers par Index), tous par défaut
	zbires: { [string]: number }, -- effectifs en solo ; le Colosse est ajouté tous les 5 jours
}

local Types: { [string]: Def } = {
	Marcheur = {
		nom = "Marcheur", pv = 20, vitesse = 6, rayon = 1.5, multMaison = 1,
		pieces = 1, gemmes = 0, frappeSurvivants = true,
	},
	Rapide = {
		nom = "Rapide", pv = 12, vitesse = 11, rayon = 1.2, multMaison = 1,
		pieces = 1, gemmes = 0, frappeSurvivants = true,
	},
	Costaud = {
		nom = "Costaud", pv = 90, vitesse = 4, rayon = 2.5, multMaison = 2,
		pieces = 4, gemmes = 0, frappeSurvivants = true,
	},
	Dore = {
		nom = "Doré", pv = 40, vitesse = 9, rayon = 1.5, multMaison = 0,
		pieces = 5, gemmes = 4, frappeSurvivants = false, fuyard = true,
	},
	Sauteur = {
		nom = "Sauteur", pv = 25, vitesse = 6, rayon = 1.5, multMaison = 1,
		pieces = 2, gemmes = 0, frappeSurvivants = true, bonds = 1,
	},
	Gluant = {
		nom = "Gluant", pv = 40, vitesse = 5, rayon = 2, multMaison = 1,
		pieces = 2, gemmes = 0, frappeSurvivants = true, division = "MiniGluant",
	},
	MiniGluant = {
		nom = "Mini-Gluant", pv = 12, vitesse = 8, rayon = 1, multMaison = 1,
		pieces = 1, gemmes = 0, frappeSurvivants = true,
	},
	Volant = {
		nom = "Volant", pv = 18, vitesse = 7, rayon = 1.5, multMaison = 1,
		pieces = 2, gemmes = 0, frappeSurvivants = false, vole = true,
	},
	Casque = {
		nom = "Casqué", pv = 50, vitesse = 5, rayon = 1.8, multMaison = 1,
		pieces = 3, gemmes = 0, frappeSurvivants = true, blinde = true,
	},
	Colosse = {
		nom = "Colosse", pv = 2500, vitesse = 3.5, rayon = 5, multMaison = 3,
		pieces = 60, gemmes = 0, frappeSurvivants = true, boss = true,
		onde = table.freeze({ rayon = 12, preavis = 1.2, periode = 7 }),
	},
}

for _, def in Types do
	table.freeze(def)
end

-- Ordre fixe : l'index (1 à 10) voyage sur 4 bits dans EtatZbires.
local ORDRE = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local INDEX: { [string]: number } = {}
for i, typeId in ORDRE do
	INDEX[typeId] = i
end

-- Programme greybox, remplacé par ZbiresDefs.Jours (a06).
local JOURS_GREYBOX: { Jour } = {
	{ tension = 0, portails = 2, zbires = { Marcheur = 14, Rapide = 4 } },
	{ tension = 0, portails = 3, zbires = { Marcheur = 16, Rapide = 6, Casque = 3 } },
	{ tension = 0, portails = 4, zbires = { Marcheur = 16, Rapide = 8, Casque = 4, Gluant = 3, Dore = 1 } },
	{ tension = 1, portails = 6, zbires = { Marcheur = 18, Rapide = 8, Casque = 5, Gluant = 4, Sauteur = 4, Volant = 3 } },
	{ tension = 0, portails = 8, zbires = { Marcheur = 16, Rapide = 8, Casque = 5, Costaud = 2, Sauteur = 4, Volant = 4, Dore = 1 } },
}
local RAMPE_GREYBOX = { 0.15, 0.35, 0.6, 0.85, 1 }

local moduleJours = script:FindFirstChild("Jours")
local donnees = if moduleJours and moduleJours:IsA("ModuleScript") then require(moduleJours) else nil
if donnees == nil then
	warn("[ZbiresDefs] Sous-module Jours (a06) absent : programme greybox de 5 jours")
end

local ZbiresDefs = {
	Types = table.freeze(Types),
	ORDRE = table.freeze(ORDRE),
	INDEX = table.freeze(INDEX),
	JOURS = (if donnees then donnees.JOURS else nil) or JOURS_GREYBOX,
	RAMPE = (if donnees then donnees.RAMPE else nil) or RAMPE_GREYBOX,
}
assert(#ZbiresDefs.JOURS > 0 and #ZbiresDefs.RAMPE > 0, "[ZbiresDefs] JOURS et RAMPE ne doivent pas être vides")

-- Au-delà du dernier jour de a06, on rejoue le dernier : les PV continuent de monter de 15 % par jour.
function ZbiresDefs.jour(n: number): Jour
	return ZbiresDefs.JOURS[math.clamp(math.floor(n), 1, #ZbiresDefs.JOURS)]
end

function ZbiresDefs.facteurJour(jour: number): number
	return Config.CROISSANCE_JOUR ^ (math.max(jour, 1) - 1)
end

function ZbiresDefs.facteurCoop(actifs: number): number
	return 1 + Config.COOP_PV * (math.clamp(actifs, 1, Config.JOUEURS_MAX) - 1)
end

-- PV = base x 1,15^(jour - 1) x 1,3^Tension x coop x Défi. Colosse : 2 500 x 1,15^(jour - 1) x coop.
function ZbiresDefs.pvMax(typeId: string, jour: number, tension: number, actifs: number, defi: number): number
	local def = Types[typeId]
	local pv = def.pv * ZbiresDefs.facteurJour(jour) * ZbiresDefs.facteurCoop(actifs)
	if not def.boss then
		pv *= Config.FACTEUR_TENSION ^ tension * defi
	end
	return math.ceil(pv)
end

-- Part cumulée des Zbires du jour lâchée à la fraction f (0 à 1) des 80 s de horde.
-- RAMPE = parts cumulées à intervalles égaux ; interpolation linéaire, 0 au départ, 1 à la fin.
function ZbiresDefs.rampe(f: number): number
	local points = ZbiresDefs.RAMPE
	local n = #points
	local x = math.clamp(f, 0, 1) * n
	local i = math.floor(x)
	if i >= n then
		return 1
	end
	local avant = if i == 0 then 0 else points[i]
	return avant + (points[i + 1] - avant) * (x - i)
end

return table.freeze(ZbiresDefs)
```

### a26/ZbiresRendu.lua
```lua
-- StarterPlayer/StarterPlayerScripts/Controleurs/ZbiresRendu (ModuleScript)
-- Contrat de rendu des Zbires, FIGÉ (QA) : pool de 70 modèles créé pendant l'Arrivée, parentés à
-- workspace.Zbires avec l'attribut Id (0 = libre). Chaque modèle : Racine ancrée invisible + 3 à 5 MeshParts
-- (700 triangles au plus pour le Zbire) reliées par Motor6D (noms de a38). Un seul workspace:BulkMoveTo
-- par image. Aucun Instance.new, Clone ni Destroy après preparer(). Aucune décision de jeu ici.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local ZbiresDefs = require(Partage:WaitForChild("ZbiresDefs"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))

-- Couleurs : ReplicatedStorage.Charte fait foi ; valeurs de secours = palette du canon.
local moduleCharte = ReplicatedStorage:FindFirstChild("Charte")
local Charte = if moduleCharte and moduleCharte:IsA("ModuleScript") then require(moduleCharte) else {}

local function couleur(nom: string, secours: string): Color3
	local valeur = Charte[nom]
	return if typeof(valeur) == "Color3" then valeur else Color3.fromHex(secours)
end

local VIOLET = couleur("VioletHorde", "#9B5DE5")
local OR = couleur("Or", "#FFC933")
local ALERTE = couleur("Alerte", "#FF2E63")

local TAU = 2 * math.pi
local PARKING = CFrame.new(0, -200, 0) -- sous la Prairie, au-dessus de FallenPartsDestroyHeight
local PAR_IMAGE = 5 -- modèles créés par image pendant l'Arrivée (~14 images)
local HAUTEUR_BOND = 3

export type Entree = {
	id: number, -- 0 = libre
	type: string,
	def: ZbiresDefs.Def,
	modele: Model,
	racine: BasePart,
	hauteur: number, -- de la Racine au bas du modèle
	de: Vector3,
	vers: Vector3,
	actuel: Vector3, -- position au sol interpolée
	affiche: Vector3, -- position de la Racine à l'écran
	capDe: number,
	capVers: number,
	cap: number,
	t0: number,
	vu: number,
	pv: number, -- 0 à 1
	etat: number, -- drapeaux Config.ETAT_*
	debutBond: number?,
}

local ZbiresRendu = {}

local libres: { [string]: { Entree } } = {}
local actifs: { [number]: Entree } = {}
local aGarer: { Entree } = {}
local racines: { BasePart } = {}
local cadres: { CFrame } = {}
local manques: { [string]: boolean } = {}
local animateur: (({ [number]: Entree }, number) -> ())? = nil
local disqueOnde: Part? = nil
local ondeCadre: CFrame? = nil
local ondeDebut, ondeFin, ondeRayon = 0, 0, 0
local pret = false

--------------------------------------------------------------------------------
-- Préparation (pendant l'Arrivée uniquement)
--------------------------------------------------------------------------------

-- Greybox tant que a24 n'a pas livré le Model : Racine + 1 cube violet (or pour le Doré).
local function modeleGreybox(typeId: string, def: ZbiresDefs.Def): Model
	local modele = Instance.new("Model")
	modele.Name = typeId
	local racine = Instance.new("Part")
	racine.Name = "Racine"
	racine.Size = Vector3.one
	racine.Parent = modele
	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Size = Vector3.one * def.rayon * 2
	corps.Material = Enum.Material.SmoothPlastic
	corps.Color = if def.fuyard then OR else VIOLET
	corps.CFrame = racine.CFrame
	corps.Parent = modele
	local moteur = Instance.new("Motor6D")
	moteur.Name = "Corps"
	moteur.Part0 = racine
	moteur.Part1 = corps
	moteur.Parent = racine
	modele.PrimaryPart = racine
	return modele
end

-- Applique le contrat au modèle maître (les clones en héritent). Renvoie la hauteur Racine -> sol.
local function configurer(modele: Model, typeId: string, verifier: boolean): number
	local racine = modele:FindFirstChild("Racine")
	if not (racine and racine:IsA("BasePart")) then
		racine = modele.PrimaryPart
		warn(`[ZbiresRendu] {typeId} : pas de Part « Racine », PrimaryPart utilisée`)
	end
	assert(racine and racine:IsA("BasePart"), `[ZbiresRendu] {typeId} : modèle sans Racine`)
	modele.PrimaryPart = racine

	local relies: { [Instance]: boolean } = {}
	for _, d in modele:GetDescendants() do
		if d:IsA("Motor6D") then
			if d.Part0 then
				relies[d.Part0] = true
			end
			if d.Part1 then
				relies[d.Part1] = true
			end
		end
	end

	local meshes, sansMoteur = 0, 0
	for _, d in modele:GetDescendants() do
		if d:IsA("BasePart") then
			d.CastShadow = false
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			if d == racine then
				d.Anchored = true
				d.Transparency = 1
			else
				d.Anchored = false
				d.Massless = true
				if d:IsA("MeshPart") then
					meshes += 1
				end
				if not relies[d] then
					sansMoteur += 1
				end
			end
		end
	end
	if verifier and (meshes < 3 or meshes > 5 or sansMoteur > 0) then
		warn(`[ZbiresRendu] {typeId} hors contrat : {meshes} MeshParts (3 à 5), {sansMoteur} Part(s) sans Motor6D`)
	end

	local cadre, taille = modele:GetBoundingBox()
	return racine.Position.Y - (cadre.Position.Y - taille.Y / 2)
end

-- 70 modèles (Config.QUOTAS_RENDU), 5 par image, garés sous la carte avec Id = 0.
function ZbiresRendu.preparer()
	local dossier = workspace:FindFirstChild("Zbires")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Zbires"
		dossier.Parent = workspace
	end
	local modeles = ReplicatedStorage:WaitForChild("Modeles", 5)
	local gabarits = if modeles then modeles:FindFirstChild("Zbires") else nil

	local crees = 0
	for _, typeId in ZbiresDefs.ORDRE do
		local def = ZbiresDefs.Types[typeId]
		local gabarit = if gabarits then gabarits:FindFirstChild(typeId) else nil
		local reel = gabarit ~= nil and gabarit:IsA("Model")
		local maitre: Model
		if reel then
			maitre = (gabarit :: Model):Clone()
		else
			warn(`[ZbiresRendu] Pas de modèle {typeId} dans ReplicatedStorage.Modeles.Zbires : cube greybox`)
			maitre = modeleGreybox(typeId, def)
		end
		local hauteur = configurer(maitre, typeId, reel)

		local pile: { Entree } = {}
		libres[typeId] = pile
		for _ = 1, Config.QUOTAS_RENDU[typeId] or 0 do
			local modele = maitre:Clone()
			modele:SetAttribute("Id", 0)
			modele:PivotTo(PARKING)
			modele.Parent = dossier
			table.insert(pile, {
				id = 0,
				type = typeId,
				def = def,
				modele = modele,
				racine = modele.PrimaryPart :: BasePart,
				hauteur = hauteur,
				de = Vector3.zero,
				vers = Vector3.zero,
				actuel = Vector3.zero,
				affiche = Vector3.zero,
				capDe = 0,
				capVers = 0,
				cap = 0,
				t0 = 0,
				vu = 0,
				pv = 1,
				etat = 0,
				debutBond = nil,
			})
			crees += 1
			if crees % PAR_IMAGE == 0 then
				RunService.PreRender:Wait()
			end
		end
		maitre:Destroy()
	end

	-- Annonce au sol de l'onde du Colosse : 1 disque préparé ici, jamais recréé.
	local disque = Instance.new("Part")
	disque.Name = "OndeColosse"
	disque.Shape = Enum.PartType.Cylinder
	disque.Anchored = true
	disque.CanCollide = false
	disque.CanQuery = false
	disque.CanTouch = false
	disque.CastShadow = false
	disque.Material = Enum.Material.SmoothPlastic
	disque.Color = ALERTE
	disque.Transparency = 0.55
	disque.Size = Vector3.new(0.2, 1, 1)
	disque.CFrame = PARKING
	disque.Parent = dossier
	disqueOnde = disque
	pret = true
end

--------------------------------------------------------------------------------
-- Pool
--------------------------------------------------------------------------------

local function prendre(typeId: string, id: number): Entree?
	local pile = libres[typeId]
	local e = if pile then table.remove(pile) else nil
	if not e then
		if not manques[typeId] then
			manques[typeId] = true
			warn(`[ZbiresRendu] Pool {typeId} épuisé : le serveur doit respecter Config.QUOTAS_RENDU`)
		end
		return nil
	end
	e.id = id
	e.debutBond = nil
	e.modele:SetAttribute("Id", id)
	actifs[id] = e
	return e
end

local function liberer(e: Entree)
	actifs[e.id] = nil
	e.id = 0
	e.modele:SetAttribute("Id", 0)
	table.insert(libres[e.type], e)
	table.insert(aGarer, e)
end

--------------------------------------------------------------------------------
-- Réseau : EtatZbires (10 Hz) et flux Evenements
--------------------------------------------------------------------------------

local function surEtat(tampon: buffer)
	if not pret or typeof(tampon) ~= "buffer" then
		return
	end
	local maintenant = os.clock()
	local taille = Config.OCTETS_PAR_ZBIRE
	for o = 0, buffer.len(tampon) - taille, taille do
		local id = buffer.readu16(tampon, o)
		local octet = buffer.readu8(tampon, o + 8)
		local typeId = ZbiresDefs.ORDRE[octet % 16]
		local pos = Vector3.new(
			Config.CENTRE.X + buffer.readi16(tampon, o + 2) / 10,
			Config.SOL_Y,
			Config.CENTRE.Z + buffer.readi16(tampon, o + 4) / 10
		)
		local cap = buffer.readu8(tampon, o + 7) / 256 * TAU
		local e = actifs[id]
		if e and e.type ~= typeId then
			liberer(e) -- identifiant réutilisé par le serveur pour un autre type
			e = nil
		end
		if e then
			e.de, e.capDe = e.actuel, e.cap
		elseif typeId then
			e = prendre(typeId, id)
			if e then
				e.de, e.actuel, e.affiche = pos, pos, pos
				e.capDe, e.cap = cap, cap
			end
		end
		if e then
			e.vers, e.capVers = pos, cap
			e.pv = buffer.readu8(tampon, o + 6) / 255
			e.etat = octet // 16
			e.t0, e.vu = maintenant, maintenant
		end
	end
end

local function surEclatement(id: number)
	local e = actifs[id]
	if e then
		liberer(e) -- les cubes et les pièces sont dessinés par EffetsControleur
	end
end

local function surOnde(_id: number, x: number, z: number, rayon: number, preavis: number)
	ondeCadre = CFrame.new(x, Config.SOL_Y + 0.15, z) * CFrame.Angles(0, 0, math.rad(90))
	ondeDebut = os.clock()
	ondeFin = ondeDebut + preavis
	ondeRayon = rayon
end

--------------------------------------------------------------------------------
-- Image par image : un seul BulkMoveTo, puis l'animateur de a38
--------------------------------------------------------------------------------

local function mettreAJour(dt: number)
	debug.profilebegin("ZbiresRendu")
	local maintenant = os.clock()
	table.clear(racines)
	table.clear(cadres)

	for id, e in actifs do
		if maintenant - e.vu > Config.OUBLI_RENDU then
			liberer(e) -- absent de l'état serveur : Doré enfui, fin de run
			continue
		end
		local alpha = math.clamp((maintenant - e.t0) / Config.TICK, 0, 1)
		local pos = e.de:Lerp(e.vers, alpha)
		e.actuel = pos
		e.cap = e.capDe + ((e.capVers - e.capDe + math.pi) % TAU - math.pi) * alpha

		local y = pos.Y + e.hauteur
		local bonds = e.def.bonds
		if e.def.vole then
			y += Config.HAUTEUR_VOL + math.sin(maintenant * 4 + id) * 0.3
		elseif bonds and bit32.band(e.etat, Config.ETAT_BOND) ~= 0 then
			local debut = e.debutBond or maintenant
			e.debutBond = debut
			y += math.sin(math.clamp((maintenant - debut) / (bonds * 0.45), 0, 1) * math.pi) * HAUTEUR_BOND
		else
			e.debutBond = nil
		end
		e.affiche = Vector3.new(pos.X, y, pos.Z)
		table.insert(racines, e.racine)
		table.insert(cadres, CFrame.new(e.affiche) * CFrame.Angles(0, e.cap, 0))
	end

	local disque = disqueOnde
	if disque then
		if ondeCadre then
			table.insert(racines, disque)
			table.insert(cadres, ondeCadre)
			ondeCadre = nil
		end
		if ondeFin > 0 and maintenant >= ondeFin then
			ondeFin = 0
			table.insert(racines, disque)
			table.insert(cadres, PARKING)
		elseif ondeFin > 0 then
			local d = ondeRayon * 2 * math.clamp((maintenant - ondeDebut) / (ondeFin - ondeDebut), 0.05, 1)
			disque.Size = Vector3.new(0.2, d, d)
		end
	end

	for _, e in aGarer do
		if e.id == 0 then -- pas repris entre-temps
			table.insert(racines, e.racine)
			table.insert(cadres, PARKING)
		end
	end
	table.clear(aGarer)
	if #racines > 0 then
		workspace:BulkMoveTo(racines, cadres, Enum.BulkMoveMode.FireCFrameChanged)
	end
	if animateur then
		animateur(actifs, dt) -- ZbireAnimateur (a38) : Motor6D.Transform, même budget de 3 ms
	end
	debug.profileend()
end

--------------------------------------------------------------------------------
-- API publique (BlasterControleur, a28, a38)
--------------------------------------------------------------------------------

-- a28 : tap ou clic -> identifiant du Zbire ciblable le plus proche du point, à tolerancePx près
-- (bord de sa silhouette compris). positionEcran = InputObject.Position (inset GUI exclu).
function ZbiresRendu.chercher(positionEcran: Vector2, tolerancePx: number): number?
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local pixelsParStud = camera.ViewportSize.Y / (2 * math.tan(math.rad(camera.FieldOfView) / 2))
	local meilleurId, meilleureDistance = nil, math.huge
	for id, e in actifs do
		if bit32.band(e.etat, Config.ETAT_CIBLABLE) ~= 0 then
			local p, visible = camera:WorldToScreenPoint(e.affiche)
			if visible and p.Z > 0 then
				local d = (Vector2.new(p.X, p.Y) - positionEcran).Magnitude - e.def.rayon * pixelsParStud / p.Z
				if d <= tolerancePx and d < meilleureDistance then
					meilleurId, meilleureDistance = id, d
				end
			end
		end
	end
	return meilleurId
end

-- Tir auto : Zbire ciblable, visible à l'écran, le plus proche de l'origine dans la portée.
function ZbiresRendu.plusProche(origine: Vector3, portee: number): number?
	local camera = workspace.CurrentCamera
	local meilleurId, meilleureDistance = nil, math.huge
	for id, e in actifs do
		if bit32.band(e.etat, Config.ETAT_CIBLABLE) ~= 0 then
			local dx, dz = e.actuel.X - origine.X, e.actuel.Z - origine.Z
			local d = math.sqrt(dx * dx + dz * dz) - e.def.rayon
			if d <= portee and d < meilleureDistance then
				local visible = true
				if camera then
					local _, dansVue = camera:WorldToViewportPoint(e.affiche)
					visible = dansVue
				end
				if visible then
					meilleurId, meilleureDistance = id, d
				end
			end
		end
	end
	return meilleurId
end

function ZbiresRendu.estValide(id: number, origine: Vector3, portee: number): boolean
	local e = actifs[id]
	if not e or bit32.band(e.etat, Config.ETAT_CIBLABLE) == 0 then
		return false
	end
	local dx, dz = e.actuel.X - origine.X, e.actuel.Z - origine.Z
	return math.sqrt(dx * dx + dz * dz) - e.def.rayon <= portee
end

function ZbiresRendu.position(id: number): Vector3?
	local e = actifs[id]
	return if e then e.affiche else nil
end

-- a38 : appelé à chaque image juste après le BulkMoveTo, avec les entrées actives (lecture seule).
function ZbiresRendu.brancherAnimateur(fn: ({ [number]: Entree }, number) -> ())
	animateur = fn
end

function ZbiresRendu.demarrer()
	Reseau.EtatZbires.OnClientEvent:Connect(surEtat)
	Evenements.ecouter("eclatement", surEclatement)
	Evenements.ecouter("onde", surOnde)
	RunService.PreRender:Connect(mettreAJour)
end

return ZbiresRendu
```

### a27/Catalogue.lua
```lua
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
```

### a27/Donnees.lua
```lua
-- ServerScriptService.Modules.Donnees (ModuleScript) : la seule persistance des Survivants, dans les deux places
-- Store unique Zsurvie_Joueurs_v1, clé J_<UserId> (Studio : Zsurvie_Joueurs_Studio). UpdateAsync uniquement,
-- verrou de session, pcall et nouvelles tentatives, une écriture toutes les 7 s par clé au plus.
-- Toute hausse de Gemmes passe par verser() : AjouterGemmes, CrediterRun, RecompenseDefiDuJour, RecolterForeuse.
-- Gemmes_v1, Zsurvie_Profils_v1, Boutique_v1, Cosmetiques_v1 et PeluchesSecretes_v1 n'existent plus.

local AnalyticsService = game:GetService("AnalyticsService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SchemaJoueur = require(script.Parent.SchemaJoueur)
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Temps = require(ReplicatedStorage:WaitForChild("Temps"))

local NOM_STORE = if RunService:IsStudio() then "Zsurvie_Joueurs_Studio" else "Zsurvie_Joueurs_v1"
local store = DataStoreService:GetDataStore(NOM_STORE)

local ESSAIS_MAX = 5 -- tentatives par requête : attentes 1, 2, 4, 8 s
local ESSAIS_FERMETURE = 3 -- pendant BindToClose (30 s accordées par Roblox)
local ESSAIS_PASSAGE = 3 -- Liberer avant une téléportation
local ESSAIS_VERROU = 10 -- 10 x 3 s d'attente d'une session ouverte ailleurs, puis reprise forcée
local DELAI_VERROU = 3
local VERROU_EXPIRE = 180 -- s : un verrou non rafraîchi depuis 3 min appartient à un serveur mort
local ECART_ECRITURE = 7 -- s entre deux écritures d'une même clé (limite Roblox : 6 s)
local AUTO_MIN = 45 -- l'autosave saute un profil écrit il y a moins de 45 s
local FERMETURE_MAX = 27 -- s d'attente dans BindToClose
local VERSIONS_EXAMINEES = 10 -- versions relues pour restaurer un profil corrompu
local RUNS_TERMINEES_MAX = 20

-- Plafond par appel et par source. Aucune autre source de gemmes n'existe (ZbireSemaine supprimée).
local PLAFONDS_GEMMES: { [string]: number } = {
	Jour = 210, -- J15 : 70 x 1,5 (Difficile) x 2 (week-end bonus)
	Mine = 200,
	Dore = 50,
	FinDeRun = 1500,
	Foreuse = Catalogue.Foreuse.PlafondParHeure * Catalogue.Foreuse.HeuresMax, -- 27 x 8 = 216
	DefiDuJour = Catalogue.DefiDuJour.Gemmes, -- 150
}
-- Sources de la Prairie : runId obligatoire, cumulées dans RunsCreditees[runId].
local SOURCES_RUN = { Jour = true, Mine = true, Dore = true, FinDeRun = true }

type Profil = { [string]: any }
type Session = {
	Id: string,
	Donnees: Profil,
	Sale: boolean, -- modifié depuis la dernière écriture réussie
	EnCours: boolean, -- une écriture est en vol
	Planifiee: boolean, -- une boucle Planifier tourne
	Liberation: boolean, -- sauvegarde finale en cours : plus aucune modification
	Perdue: boolean, -- verrou repris par un autre serveur : on n'écrit plus jamais
	DerniereEcriture: number, -- os.clock()
}

local Donnees = {}

local sessions: { [Player]: Session } = {}
local deblocages: { [string]: (Player, any) -> boolean } = {}
local fermeture = false

local signalChange = Instance.new("BindableEvent")
Donnees.Change = signalChange.Event -- (joueur) après chaque modification du profil

local function cle(joueur: Player): string
	return "J_" .. joueur.UserId
end

local function attendreBudget()
	local debut = os.clock()
	while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) < 1
		and os.clock() - debut < 5
	do
		task.wait(0.5)
	end
end

-- Exécute fn sous pcall avec nouvelles tentatives et attente exponentielle.
local function avecEssais(etiquette: string, fn: () -> any, maximum: number?): (boolean, any)
	local essais = maximum or (if fermeture then ESSAIS_FERMETURE else ESSAIS_MAX)
	local erreur = nil
	for essai = 1, essais do
		attendreBudget()
		local ok, resultat = pcall(fn)
		if ok then
			return true, resultat
		end
		erreur = resultat
		warn(`[Donnees] {etiquette} : échec {essai}/{essais} ({resultat})`)
		if essai < essais then
			task.wait(2 ^ (essai - 1))
		end
	end
	return false, erreur
end

local function nouveauVerrou(id: string): { [string]: any }
	return { Id = id, JobId = game.JobId, PlaceId = game.PlaceId, Horodatage = os.time() }
end

-- Écrit le profil si et seulement si ce serveur tient encore le verrou.
local function ecrire(joueur: Player, session: Session, liberer: boolean, essais: number?): boolean
	while session.EnCours do
		task.wait(0.1)
	end
	if session.Perdue then
		return false
	end
	session.EnCours = true

	local attente = ECART_ECRITURE - (os.clock() - session.DerniereEcriture)
	if attente > 0 then
		task.wait(attente)
	end

	session.Sale = false
	local refuse = false
	local ok = avecEssais(`Sauvegarde {cle(joueur)}`, function()
		return store:UpdateAsync(cle(joueur), function(ancien)
			local verrou = if type(ancien) == "table" then ancien.Verrou else nil
			if type(verrou) ~= "table" or verrou.Id ~= session.Id then
				refuse = true
				return nil -- un autre serveur a repris la session : on n'écrase rien
			end
			refuse = false
			local profil = session.Donnees
			profil.Verrou = if liberer then nil else nouveauVerrou(session.Id)
			profil.DerniereSauvegarde = os.time()
			return profil, { joueur.UserId }
		end)
	end, essais)

	session.DerniereEcriture = os.clock()
	session.EnCours = false

	if ok and refuse then
		session.Perdue = true
		warn(`[Donnees] Session de {joueur.Name} reprise par un autre serveur : écriture annulée`)
		return false
	end
	if not ok then
		session.Sale = true
	end
	return ok
end

local function journaliser(joueur: Player, cleJ: string, chemin: string?)
	warn(`[Donnees] Profil {cleJ} refusé : champ {chemin or "?"} illisible. Aucune écriture, restauration par ListVersionsAsync.`)
	pcall(function()
		AnalyticsService:LogCustomEvent(joueur, "ProfilCorrompu")
	end)
end

-- Relit les 10 dernières versions et réécrit la plus récente qui se prépare sans erreur.
local function restaurer(joueur: Player, cleJ: string): boolean
	local ok, pages = avecEssais(`Versions {cleJ}`, function()
		return store:ListVersionsAsync(cleJ, Enum.SortDirection.Descending, 0, 0, VERSIONS_EXAMINEES)
	end)
	if not ok then
		return false
	end
	for _, info in pages:GetCurrentPage() do
		if not info.IsDeleted then
			local lu, ancienne = avecEssais(`Version {cleJ} {info.Version}`, function()
				return store:GetVersionAsync(cleJ, info.Version)
			end)
			if lu and type(ancienne) == "table" and SchemaJoueur.Preparer(SchemaJoueur.Copie(ancienne)) then
				ancienne.Verrou = nil
				local ecrit = avecEssais(`Restauration {cleJ}`, function()
					return store:UpdateAsync(cleJ, function()
						return ancienne, { joueur.UserId }
					end)
				end)
				if ecrit then
					warn(`[Donnees] {cleJ} restauré depuis la version {info.Version}`)
				end
				return ecrit
			end
		end
	end
	return false
end

-- Charge le profil et prend le verrou. Raisons d'échec : "DataStore", "Version", "Corrompu", "Parti", "Fermeture".
function Donnees.Charger(joueur: Player): (boolean, string?)
	if sessions[joueur] then
		return true, nil
	end
	if fermeture then
		return false, "Fermeture"
	end

	local cleJ = cle(joueur)
	local idSession = HttpService:GenerateGUID(false)
	local profil: Profil? = nil
	local restauration = false
	for tentative = 1, ESSAIS_VERROU do
		local bloque = false
		local raison: string? = nil
		local chemin: string? = nil
		local ok, valeur = avecEssais(`Chargement {cleJ}`, function()
			return store:UpdateAsync(cleJ, function(ancien)
				bloque, raison, chemin = false, nil, nil
				local verrou = if type(ancien) == "table" then ancien.Verrou else nil
				if type(verrou) == "table"
					and verrou.Id ~= idSession
					and os.time() - (tonumber(verrou.Horodatage) or 0) < VERROU_EXPIRE
					and tentative < ESSAIS_VERROU
				then
					bloque = true
					return nil -- session encore ouverte ailleurs (téléportation en cours) : on réessaie
				end
				local d, pourquoi, fautif = SchemaJoueur.Preparer(ancien)
				if not d then
					raison, chemin = pourquoi, fautif
					return nil -- profil refusé : rien n'est écrit
				end
				d.Verrou = nouveauVerrou(idSession)
				return d, { joueur.UserId }
			end)
		end)
		if not ok then
			return false, "DataStore"
		end
		if raison == "Corrompu" then
			journaliser(joueur, cleJ, chemin)
			if restauration or not restaurer(joueur, cleJ) then
				return false, "Corrompu"
			end
			restauration = true -- nouvel essai immédiat sur la version restaurée
		elseif raison then
			return false, raison
		elseif bloque then
			if not joueur.Parent then
				return false, "Parti"
			end
			task.wait(DELAI_VERROU)
		else
			profil = valeur
			break
		end
	end
	if type(profil) ~= "table" then
		return false, "DataStore"
	end

	local session: Session = {
		Id = idSession,
		Donnees = profil,
		Sale = false,
		EnCours = false,
		Planifiee = false,
		Liberation = false,
		Perdue = false,
		DerniereEcriture = os.clock(),
	}
	sessions[joueur] = session

	if not joueur.Parent then
		Donnees.Liberer(joueur)
		return false, "Parti"
	end

	joueur:SetAttribute("Gemmes", profil.Gemmes)
	joueur:SetAttribute("DonneesChargees", true)
	print(`[Solde] {cleJ} chargé (place {game.PlaceId}) : {profil.Gemmes} gemmes`)
	signalChange:Fire(joueur)
	return true, nil
end

-- Lecture seule. Toute écriture passe par Modifier.
function Donnees.Obtenir(joueur: Player): Profil?
	local session = sessions[joueur]
	if not session or session.Liberation or session.Perdue then
		return nil
	end
	return session.Donnees
end

-- fn(profil) ne cède jamais la main. Elle renvoie false si elle n'a rien changé (ni écriture, ni envoi).
function Donnees.Modifier(joueur: Player, fn: (Profil) -> boolean?): boolean
	local profil = Donnees.Obtenir(joueur)
	if not profil then
		return false
	end
	if fn(profil) == false then
		return false
	end
	sessions[joueur].Sale = true
	signalChange:Fire(joueur)
	return true
end

-- Seule ligne du jeu qui augmente Gemmes. À appeler dans Modifier.
local function verser(p: Profil, montant: number, source: string, runId: string?): number
	local plafond = PLAFONDS_GEMMES[source]
	assert(plafond, `Source de gemmes refusée : {tostring(source)}`)
	if montant ~= montant then
		return 0
	end
	local gain = math.clamp(math.floor(montant), 0, plafond)
	if gain == 0 then
		return 0
	end
	if SOURCES_RUN[source] then
		assert(type(runId) == "string", `{source} exige le runId de la Prairie`)
		if table.find(p.RunsTerminees, runId) then
			return 0
		end
		p.RunsCreditees[runId] = (p.RunsCreditees[runId] or 0) + gain
	end
	p.Gemmes += gain
	p.GemmesCumul += gain
	return gain
end

-- Production de la Foreuse depuis la dernière récolte (8 h au plus, turbo de a08 compris). Dans Modifier.
local function recolterDans(p: Profil, maintenant: number): number
	local foreuse = Catalogue.Foreuse
	local niveau = p.Recherches.Foreuse
	local debut = math.max(p.Foreuse.DerniereRecolte, maintenant - foreuse.HeuresMax * 3600) -- réservoir plein : surplus perdu
	p.Foreuse.DerniereRecolte = maintenant
	if niveau <= 0 or debut >= maintenant then
		return 0
	end
	local taux = foreuse.GemmesParHeure[math.min(niveau, #foreuse.GemmesParHeure)]
	local tauxTurbo = math.min(foreuse.PlafondParHeure, math.floor(taux * foreuse.MultiplicateurTurbo))
	local finTurbo = math.clamp(p.TurboForeuseFin, debut, maintenant)
	local exact = p.Foreuse.Reste + ((finTurbo - debut) * tauxTurbo + (maintenant - finTurbo) * taux) / 3600
	local gain = math.floor(exact)
	p.Foreuse.Reste = exact - gain -- la gemme entamée reste acquise
	return verser(p, gain, "Foreuse")
end

-- La porte des gemmes. Sources : Mine, Dore, Jour, FinDeRun (runId obligatoire), Foreuse, DefiDuJour.
function Donnees.AjouterGemmes(joueur: Player, montant: number, source: string, runId: string?): number
	assert(PLAFONDS_GEMMES[source], `Source de gemmes refusée : {tostring(source)}`)
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		verse = verser(p, montant, source, runId)
		return verse > 0
	end)
	return verse
end

-- Verse totalRun - RunsCreditees[runId], jamais plus. terminer = true clôt la run (fin ou fermeture de la Prairie).
function Donnees.CrediterRun(joueur: Player, runId: string, totalRun: number, terminer: boolean?): number
	assert(type(runId) == "string" and runId ~= "", "CrediterRun exige le runId de la Prairie")
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		if table.find(p.RunsTerminees, runId) then
			return false -- run déjà close : rien n'est versé deux fois
		end
		verse = verser(p, totalRun - (p.RunsCreditees[runId] or 0), "FinDeRun", runId)
		if terminer then
			p.RunsCreditees[runId] = nil
			table.insert(p.RunsTerminees, runId)
			if #p.RunsTerminees > RUNS_TERMINEES_MAX then
				table.remove(p.RunsTerminees, 1)
			end
			p.Records.Runs += 1
		end
		return verse > 0 or terminer == true
	end)
	return verse
end

-- Recherche au Laboratoire. Refus sans rien débiter si niveau + 1 ~= niveauVise (double tap).
function Donnees.AcheterRecherche(joueur: Player, nom: string, niveauVise: number): (boolean, string?)
	local fiche = Catalogue.Recherches[nom]
	if not fiche then
		return false, "Inconnue"
	end
	local refus: string? = "PasCharge"
	Donnees.Modifier(joueur, function(p)
		local niveau = p.Recherches[nom]
		if niveau + 1 ~= niveauVise then
			refus = "NiveauVise"
		elseif niveau >= fiche.NiveauMax then
			refus = "NiveauMax"
		elseif p.Gemmes < fiche.Couts[niveau + 1] then
			refus = "Solde"
		else
			refus = nil
			if nom == "Foreuse" then
				recolterDans(p, os.time()) -- solde la production à l'ancien taux
			end
			p.Gemmes -= fiche.Couts[niveau + 1]
			p.Recherches[nom] = niveau + 1
			return true
		end
		return false
	end)
	if refus then
		return false, refus
	end
	Donnees.Planifier(joueur)
	return true, nil
end

function Donnees.RecolterForeuse(joueur: Player): number
	local gain = 0
	Donnees.Modifier(joueur, function(p)
		gain = recolterDans(p, os.time())
		return true -- DerniereRecolte et Reste ont bougé
	end)
	if gain > 0 then
		Donnees.Planifier(joueur)
	end
	return gain
end

-- Turbo de la Foreuse (a08) : solde la production au taux courant, puis prolonge TurboForeuseFin.
function Donnees.ActiverTurboForeuse(joueur: Player, secondes: number): boolean
	local ok = Donnees.Modifier(joueur, function(p)
		local maintenant = os.time()
		recolterDans(p, maintenant)
		p.TurboForeuseFin = math.max(p.TurboForeuseFin, maintenant) + math.clamp(math.floor(secondes), 0, 8 * 3600)
		return true
	end)
	if ok then
		Donnees.Planifier(joueur)
	end
	return ok
end

-- Défi du Jour : 150 gemmes une fois par Temps.cleJour() (minuit, heure de Paris).
function Donnees.RecompenseDefiDuJour(joueur: Player): number
	local cleJour = Temps.cleJour()
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		if p.Quotidien.CleDefi == cleJour then
			return false
		end
		p.Quotidien.CleDefi = cleJour
		verse = verser(p, Catalogue.DefiDuJour.Gemmes, "DefiDuJour")
		return true
	end)
	if verse > 0 then
		Donnees.Planifier(joueur)
	end
	return verse
end

-- MarketplaceService.ProcessReceipt (a46) : true seulement une fois l'achat écrit dans le store.
function Donnees.EnregistrerAchat(joueur: Player, idAchat: string, appliquer: (Profil) -> ()): boolean
	local profil = Donnees.Obtenir(joueur)
	if not profil then
		return false
	end
	if not profil.Achats[idAchat] then
		Donnees.Modifier(joueur, function(p)
			appliquer(p)
			p.Achats[idAchat] = os.time()
			return true
		end)
	end
	return Donnees.Sauvegarder(joueur) -- reçu rejoué : on s'assure seulement qu'il est écrit
end

-- DemandeDeblocage(genre, id) : Accueil et Equiper (a27), Secret (a13), Chapeau et Tampon (a15), Peluche (a22).
-- fn(joueur, id) vérifie tout côté serveur et écrit par Modifier ; elle renvoie true si quelque chose a changé.
function Donnees.DefinirDeblocage(genre: string, fn: (Player, any) -> boolean)
	assert(not deblocages[genre], `Déblocage {genre} déjà défini`)
	deblocages[genre] = fn
end

function Donnees.Debloquer(joueur: Player, genre: string, id: any): boolean
	local fn = deblocages[genre]
	return fn ~= nil and fn(joueur, id) == true
end

-- Écriture synchrone (achats). Cède la main jusqu'à 7 s + tentatives.
function Donnees.Sauvegarder(joueur: Player): boolean
	local session = sessions[joueur]
	if not session or session.Liberation then
		return false
	end
	session.Sale = true
	return ecrire(joueur, session, false)
end

-- Écriture asynchrone regroupée : plusieurs demandes rapprochées = une seule écriture.
function Donnees.Planifier(joueur: Player)
	local session = sessions[joueur]
	if not session or session.Planifiee then
		return
	end
	session.Planifiee = true
	task.spawn(function()
		while session.Sale and not session.Liberation and not session.Perdue do
			if not ecrire(joueur, session, false) then
				break
			end
		end
		session.Planifiee = false
	end)
end

-- forcer = true à chaque jour franchi (canon) ; false pour l'autosave (rafraîchit aussi le verrou).
function Donnees.SauvegarderTous(forcer: boolean)
	for joueur, session in sessions do
		if forcer or os.clock() - session.DerniereEcriture >= AUTO_MIN then
			session.Sale = true
			Donnees.Planifier(joueur)
		end
	end
end

-- Sauvegarde finale et rend le verrou. garder = true avant une téléportation : après 3 essais ratés,
-- la session reste ouverte ici (rien n'est perdu) et la fonction renvoie false.
function Donnees.Liberer(joueur: Player, garder: boolean?): boolean
	local session = sessions[joueur]
	if not session then
		return true
	end
	if session.Liberation then
		while sessions[joueur] == session and session.Liberation do
			task.wait(0.1)
		end
		return sessions[joueur] ~= session
	end
	session.Liberation = true
	if joueur.Parent then
		joueur:SetAttribute("DonneesChargees", false)
	end
	local ok = ecrire(joueur, session, true, if garder then ESSAIS_PASSAGE else nil)
	if not ok and garder and not session.Perdue and joueur.Parent then
		session.Liberation = false
		joueur:SetAttribute("DonneesChargees", true)
		warn(`[Donnees] Libération de {joueur.Name} échouée : session gardée, téléportation suspendue`)
		return false
	end
	if sessions[joueur] == session then
		sessions[joueur] = nil
	end
	if ok then
		print(`[Solde] {cle(joueur)} libéré (place {game.PlaceId}) : {session.Donnees.Gemmes} gemmes`)
	else
		warn(`[Donnees] Libération de {joueur.Name} échouée : le verrou expirera dans {VERROU_EXPIRE} s`)
	end
	return ok
end

-- game:BindToClose : libère toutes les sessions en parallèle, 27 s maximum.
function Donnees.FermerTout()
	fermeture = true
	local liste = {}
	for joueur in sessions do
		table.insert(liste, joueur)
	end
	local restants = #liste
	for _, joueur in liste do
		task.spawn(function()
			Donnees.Liberer(joueur)
			restants -= 1
		end)
	end
	local debut = os.clock()
	while restants > 0 and os.clock() - debut < FERMETURE_MAX do
		task.wait(0.2)
	end
end

return Donnees
```

### a27/Passage.lua
```lua
-- ServerScriptService.Modules.Passage (ModuleScript) : Laboratoire <-> Prairie, dans les deux places
-- Règle : TeleportAsync seulement après un Donnees.Liberer réussi (3 essais). Sinon la session reste sur ce
-- serveur, l'UI affiche « Sauvegarde… » (Annonce "Sauvegarde") et on réessaie toutes les 15 s, 4 fois.
-- MemoryStore : Capsules[privateServerId] (fiche de run) et RunsEnCours["RunEnCours_<UserId>"], TTL 1 800 s.
-- Jamais de TeleportData : il transite par le client.

local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Temps = require(ReplicatedStorage:WaitForChild("Temps"))
local Donnees = require(script.Parent.Donnees)

local TTL = 1800 -- s : une run dure 25 min au plus (canon), plus le trajet
local ESSAIS_MEMOIRE = 3
local ATTENTE_SAUVEGARDE = 15
local TOURS_SAUVEGARDE = 4

local fiches = MemoryStoreService:GetHashMap("Capsules")
local runsEnCours = MemoryStoreService:GetHashMap("RunsEnCours")

export type Fiche = {
	Mode: string, -- "Normale" | "Difficile" | "DuJour"
	CleJour: string, -- Temps.cleJour() au départ : modificateurs du Défi du Jour
	UserIds: { number },
	Code: string?, -- ReservedServerAccessCode (nil en Studio)
	Terminee: boolean,
}

local Passage = {}

local enPassage: { [Player]: boolean } = {}

local function essayer(etiquette: string, fn: () -> any): (boolean, any)
	for essai = 1, ESSAIS_MEMOIRE do
		local ok, resultat = pcall(fn)
		if ok then
			return true, resultat
		end
		warn(`[Passage] {etiquette} : échec {essai}/{ESSAIS_MEMOIRE} ({resultat})`)
		task.wait(essai)
	end
	return false, nil
end

local function cleRun(userId: number): string
	return `RunEnCours_{userId}`
end

local function ficheLocale(): Fiche
	return { Mode = "Normale", CleJour = Temps.cleJour(), UserIds = {}, Code = nil, Terminee = false }
end

-- Téléport refusé ou avorté : le joueur est toujours ici, on reprend son profil.
local function recharger(joueur: Player)
	enPassage[joueur] = nil
	if not joueur.Parent then
		return
	end
	if Donnees.Charger(joueur) then
		Reseau.Annoncer(joueur, "PassageAnnule", { Raison = "Teleport" })
	elseif joueur.Parent then
		joueur:Kick("Le voyage a échoué. Tes gemmes sont sauvegardées : relance Zsurvie !")
	end
end

-- Envoie des joueurs déjà libérés.
local function envoyer(joueurs: { Player }, placeId: number, code: string?)
	local options = Instance.new("TeleportOptions")
	if code then
		options.ReservedServerAccessCode = code
	end
	local ok, erreur = pcall(function()
		TeleportService:TeleportAsync(placeId, joueurs, options)
	end)
	if not ok then
		warn(`[Passage] TeleportAsync : {erreur}`)
		for _, joueur in joueurs do
			task.spawn(recharger, joueur)
		end
	end
end

-- Libère en parallèle ; Donnees.Liberer(joueur, true) garde la session en cas d'échec.
local function liberer(joueurs: { Player }): ({ Player }, { Player })
	local prets, retenus = {}, {}
	local restants = #joueurs
	for _, joueur in joueurs do
		task.spawn(function()
			if Donnees.Liberer(joueur, true) then
				table.insert(prets, joueur)
			else
				table.insert(retenus, joueur)
			end
			restants -= 1
		end)
	end
	while restants > 0 do
		task.wait(0.1)
	end
	return prets, retenus
end

local function reessayer(joueur: Player, placeId: number, code: string?)
	for _ = 1, TOURS_SAUVEGARDE do
		Reseau.Annoncer(joueur, "Sauvegarde", { Echec = true, Prochain = ATTENTE_SAUVEGARDE })
		task.wait(ATTENTE_SAUVEGARDE)
		if not joueur.Parent then
			return
		end
		if Donnees.Liberer(joueur, true) then
			envoyer({ joueur }, placeId, code)
			return
		end
	end
	enPassage[joueur] = nil
	Reseau.Annoncer(joueur, "PassageAnnule", { Raison = "Sauvegarde" })
end

function Passage.Teleporter(joueurs: { Player }, placeId: number, code: string?)
	assert(placeId ~= 0, "Catalogue.Places : PlaceId à renseigner")
	local candidats = {}
	for _, joueur in joueurs do
		if joueur.Parent and not enPassage[joueur] then
			enPassage[joueur] = true
			Reseau.Annoncer(joueur, "Sauvegarde", { Echec = false })
			table.insert(candidats, joueur)
		end
	end
	if #candidats == 0 then
		return
	end
	local prets, retenus = liberer(candidats)
	local presents = {}
	for _, joueur in prets do
		if joueur.Parent then
			table.insert(presents, joueur)
		end
	end
	if #presents > 0 then
		envoyer(presents, placeId, code)
	end
	for _, joueur in retenus do
		task.spawn(reessayer, joueur, placeId, code)
	end
end

-- Laboratoire : réserve une Prairie, écrit la fiche, puis téléporte la Capsule. false = départ annulé.
function Passage.LancerRun(passagers: { Player }, mode: string): boolean
	local ok, code, idPrive = pcall(function()
		return TeleportService:ReserveServer(Catalogue.Places.Prairie)
	end)
	if not ok then
		warn(`[Passage] ReserveServer : {code}`)
		return false
	end
	local ids = {}
	for _, joueur in passagers do
		table.insert(ids, joueur.UserId)
	end
	local fiche: Fiche = { Mode = mode, CleJour = Temps.cleJour(), UserIds = ids, Code = code, Terminee = false }
	if not essayer("Fiche Capsules", function()
		fiches:SetAsync(idPrive, fiche, TTL)
	end) then
		return false
	end
	Passage.Teleporter(passagers, Catalogue.Places.Prairie, code)
	return true
end

-- Prairie : fiche écrite par le Laboratoire (fiche locale en Studio ou si elle a disparu).
function Passage.LireFiche(): Fiche
	if RunService:IsStudio() or game.PrivateServerId == "" then
		return ficheLocale()
	end
	for _ = 1, 5 do
		local ok, fiche = essayer("Lecture fiche", function()
			return fiches:GetAsync(game.PrivateServerId)
		end)
		if ok and type(fiche) == "table" then
			return fiche
		end
		task.wait(2)
	end
	warn("[Passage] Fiche Capsules introuvable : run Normale, sans « Rejoindre la run »")
	return ficheLocale()
end

function Passage.TerminerFiche()
	if game.PrivateServerId == "" then
		return
	end
	essayer("Fin de fiche", function()
		fiches:UpdateAsync(game.PrivateServerId, function(fiche)
			if type(fiche) ~= "table" then
				return nil
			end
			fiche.Terminee = true
			return fiche
		end, TTL)
	end)
end

-- Prairie : à l'arrivée et à chaque jour franchi (prolonge le TTL).
function Passage.NoterRunEnCours(userId: number, fiche: Fiche)
	if not fiche.Code then
		return
	end
	essayer("RunEnCours", function()
		runsEnCours:SetAsync(cleRun(userId), { Code = fiche.Code, Mode = fiche.Mode }, TTL)
	end)
end

function Passage.OublierRunEnCours(userId: number)
	essayer("Oubli RunEnCours", function()
		runsEnCours:RemoveAsync(cleRun(userId))
	end)
end

function Passage.LireRunEnCours(userId: number): { Code: string, Mode: string }?
	local ok, run = essayer("Lecture RunEnCours", function()
		return runsEnCours:GetAsync(cleRun(userId))
	end)
	return if ok and type(run) == "table" then run else nil
end

-- Laboratoire : « Rejoindre la run ». false si la run est finie ou introuvable.
function Passage.Rejoindre(joueur: Player): boolean
	local run = Passage.LireRunEnCours(joueur.UserId)
	if not run then
		return false
	end
	Passage.Teleporter({ joueur }, Catalogue.Places.Prairie, run.Code)
	return true
end

TeleportService.TeleportInitFailed:Connect(function(joueur: Player, resultat: Enum.TeleportResult, message: string)
	if enPassage[joueur] then
		warn(`[Passage] Téléport de {joueur.Name} échoué : {resultat.Name} ({message})`)
		recharger(joueur)
	end
end)

Players.PlayerRemoving:Connect(function(joueur)
	enPassage[joueur] = nil
end)

return Passage
```

### a27/Persistance.server.lua
```lua
-- ServerScriptService.Persistance (Script) : à placer dans les DEUX places (Laboratoire et Prairie)
-- Génère le réseau, charge et libère les profils, envoie ProfilMaj (champs modifiés seulement),
-- traite DemandeReglage et DemandeDeblocage, autosave 60 s, BindToClose.
-- Workspace porte TypePlace ("Laboratoire" | "Prairie"), CentrePlace (Vector3) et RayonPlace (number),
-- posés dans Studio (Workspace > Attributs). Aucun script n'y écrit autre chose.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Modules = ServerScriptService:WaitForChild("Modules")
local Donnees = require(Modules:WaitForChild("Donnees"))
local SchemaJoueur = require(Modules:WaitForChild("SchemaJoueur"))

local TYPE_PLACE = workspace:GetAttribute("TypePlace")
assert(TYPE_PLACE == "Laboratoire" or TYPE_PLACE == "Prairie", "Workspace.TypePlace doit valoir Laboratoire ou Prairie")

local INTERVALLE_AUTOSAVE = 60
local DELAI_ENVOI = 0.2 -- regroupe les mises à jour du profil envoyées au client

-- Messages de Kick : courts, rassurants, lisibles par un enfant de 9 ans.
local MESSAGES = {
	DataStore = "Tes gemmes n'ont pas pu être chargées. Rien n'est perdu : reviens dans une minute !",
	Version = "Zsurvie vient d'être mis à jour. Relance le jeu pour retrouver tes inventions !",
	Fermeture = "Ce serveur redémarre. Relance Zsurvie pour continuer !",
	Corrompu = "Doc Boulon répare ta sauvegarde. Tes gemmes sont à l'abri : reviens dans 5 minutes !",
}

-- Champs jamais envoyés au client.
local PRIVES = { Verrou = true, Achats = true, RunsCreditees = true, RunsTerminees = true, DerniereSauvegarde = true }

Reseau.Initialiser()

local Run = if TYPE_PLACE == "Prairie" then require(Modules:WaitForChild("Run")) else nil
if Run then
	task.spawn(Run.Demarrer) -- EtatRun est créé avant la première attente
end

local envoyes: { [Player]: { [string]: any } } = {}
local envoisPrevus: { [Player]: boolean } = {}

local function egal(a: any, b: any): boolean
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end
	for k, v in a do
		if not egal(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

-- ProfilMaj : seulement les champs de premier niveau modifiés depuis le dernier envoi (tout au premier).
local function envoyerProfil(joueur: Player)
	envoisPrevus[joueur] = nil
	local profil = Donnees.Obtenir(joueur)
	if not profil or not joueur.Parent then
		return
	end
	local precedent = envoyes[joueur] or {}
	envoyes[joueur] = precedent
	local modifies, nombre = {}, 0
	for champ, valeur in profil do
		if not PRIVES[champ] and not egal(valeur, precedent[champ]) then
			local copie = SchemaJoueur.Copie(valeur)
			modifies[champ] = copie
			precedent[champ] = copie
			nombre += 1
		end
	end
	joueur:SetAttribute("Gemmes", profil.Gemmes)
	if nombre > 0 then
		Reseau.Envoyer(joueur, "ProfilMaj", modifies)
	end
end

Donnees.Change:Connect(function(joueur: Player)
	if envoisPrevus[joueur] then
		return
	end
	envoisPrevus[joueur] = true
	task.delay(DELAI_ENVOI, envoyerProfil, joueur)
end)

local function surArrivee(joueur: Player)
	local ok, raison = Donnees.Charger(joueur)
	if not ok and raison ~= "Parti" and joueur.Parent then
		joueur:Kick(MESSAGES[raison] or MESSAGES.DataStore)
	end
end

Players.PlayerAdded:Connect(surArrivee)
for _, joueur in Players:GetPlayers() do
	task.spawn(surArrivee, joueur)
end

Players.PlayerRemoving:Connect(function(joueur: Player)
	envoisPrevus[joueur] = nil
	envoyes[joueur] = nil
	Donnees.Liberer(joueur)
end)

-- Réglages : liste blanche, modifiables depuis les deux places.
local function entre0et1(v: any): boolean
	return type(v) == "number" and v >= 0 and v <= 1
end
local function booleen(v: any): boolean
	return type(v) == "boolean"
end
local REGLAGES: { [string]: (any) -> boolean } = {
	VolumeMusique = entre0et1,
	VolumeEffets = entre0et1,
	EffetsReduits = booleen,
	Secousses = booleen,
	TirAuto = booleen,
}

Reseau.Brancher("DemandeReglage", function(joueur: Player, cleReglage: string, valeur: any)
	local valide = REGLAGES[cleReglage]
	if not valide or not valide(valeur) then
		Reseau.Refuser(joueur, "DemandeReglage", "Inconnue")
		return
	end
	local change = Donnees.Modifier(joueur, function(p)
		if p.Reglages[cleReglage] == valeur then
			return false
		end
		p.Reglages[cleReglage] = valeur
		return true
	end)
	if change then
		Donnees.Planifier(joueur)
	end
end)

-- Accueil de Doc Boulon (a50) : étape croissante, 1 à 12, sans aucune récompense.
Donnees.DefinirDeblocage("Accueil", function(joueur: Player, etape: any): boolean
	local numero = tonumber(etape)
	if not numero or numero ~= math.floor(numero) or numero > Catalogue.Accueil.Etapes then
		return false
	end
	return Donnees.Modifier(joueur, function(p)
		if numero <= p.AccueilEtape then
			return false
		end
		p.AccueilEtape = numero
		return true
	end)
end)

Reseau.Brancher("DemandeDeblocage", function(joueur: Player, genre: string, id: any)
	if Donnees.Debloquer(joueur, genre, id) then
		Donnees.Planifier(joueur)
	else
		Reseau.Refuser(joueur, "DemandeDeblocage", genre)
	end
end)

task.spawn(function()
	while true do
		task.wait(INTERVALLE_AUTOSAVE)
		Donnees.SauvegarderTous(false)
	end
end)

game:BindToClose(function()
	if Run then
		Run.Clore() -- reliquats de la run versés avant la libération des profils
	end
	Donnees.FermerTout()
end)
```

### a27/ReglesRemotes.lua
```lua
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
```

### a27/Reseau.lua
```lua
-- ReplicatedStorage.Reseau (ModuleScript) : le seul module réseau de Zsurvie, partagé serveur et client
-- Enfant obligatoire : ReplicatedStorage.Reseau.ReglesRemotes (table a29). Aucun autre script ne crée de remote.
-- Serveur : Reseau.Initialiser() génère ReplicatedStorage.Remotes ; Reseau.Brancher(nom, fn) pose l'unique
--           gestionnaire d'une demande derrière la garde. Validation.brancher (a29) délègue à Reseau.Brancher.
-- Client  : Reseau.Obtenir("DemandeTir"):FireServer(idZbire) ; Reseau.SurFait(fn) ; Reseau.LireEtatZbires(b, fn).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Regles = require(script:WaitForChild("ReglesRemotes"))

export type EtatZbire = { Id: number, Type: number, Position: Vector3, PV: number, PVMax: number }

local NOM_DOSSIER = "Remotes"
local LONGUEUR_MAX_CHAINE = 32
local NORME_MAX_VECTEUR = 100000
local REFUS_AVANT_ALERTE = 50

local OCTETS_ZBIRE = 9 -- u16 id, u8 type, i16 X x 100, i16 Z x 100, u8 Y x 10, u8 PV sur 255
local ZBIRES_MAX = 61 -- 60 Zbires + le Colosse = 549 octets
local OCTETS_FAIT = 8 -- u8 code, u16 id, i16 X x 100, i16 Z x 100, u8 argument
local FAITS_MAX = 100 -- 800 octets, sous les 900 octets d'un UnreliableRemoteEvent
local PERIODE_FAITS = 0.1 -- 10 Hz
local ECHELLE = 100 -- centièmes de stud, relatifs à Workspace.CentrePlace : ±327 studs (arène : ±110)

local Reseau = {}
Reseau.Regles = Regles

-- Codes partagés par EtatZbires (octet type) et Evenements (argument d'Apparition).
Reseau.TypesZbire = table.freeze({
	Marcheur = 1,
	Rapide = 2,
	Costaud = 3,
	Dore = 4,
	Sauteur = 5,
	Gluant = 6,
	MiniGluant = 7,
	Volant = 8,
	Casque = 9,
	Colosse = 10,
})

-- Codes du flux Evenements : fait (code, id, X, Z, argument).
Reseau.Faits = table.freeze({
	Apparition = 1, -- id Zbire, argument = TypesZbire
	Coup = 2, -- id Zbire, argument = dégâts (0-255)
	Critique = 3, -- id Zbire, argument = dégâts (0-255)
	Eclatement = 4, -- id Zbire vaincu (éclat en cubes), argument = pièces lâchées
	Division = 5, -- id Gluant, argument = Mini-Gluants créés (2)
	EtatZbire = 6, -- id Zbire, argument = état (a38, a39)
	Etourdi = 7, -- id = Player.Numero (1-6), argument = dixièmes de seconde (20)
	DefensePosee = 8, -- id défense, argument = 1 Muret, 2 Mini-Tourelle, 3 Tapis Collant
	DefenseRetiree = 9, -- id défense
	MaisonTouchee = 10, -- id 0, argument = PV de la Maison sur 255
	Reparation = 11, -- id = Player.Numero, argument = PV de la Maison sur 255
})

local dossier: Folder? = nil
local branches: { [string]: boolean } = {}
local seaux: { [Player]: { [string]: { jetons: number, t: number } } } = {}
local refus: { [Player]: number } = {}
local faits = buffer.create(FAITS_MAX * OCTETS_FAIT)
local nbFaits = 0
local ecouteurs: { (number, number, Vector3, number) -> () } = {}
local clientBranche = false

local function centrePlace(): Vector3
	local centre = workspace:GetAttribute("CentrePlace")
	return if typeof(centre) == "Vector3" then centre else Vector3.zero
end

local function borneI16(v: number): number
	return math.clamp(math.round(v), -32768, 32767)
end

local function borneU8(v: number): number
	return math.clamp(math.round(v), 0, 255)
end

-- Vérifie une valeur reçue du client contre le type attendu.
local function typeValide(valeur: any, attendu: string): boolean
	if string.sub(attendu, -1) == "?" then
		if valeur == nil then
			return true
		end
		attendu = string.sub(attendu, 1, -2)
	end
	local reel = typeof(valeur)
	for option in string.gmatch(attendu, "[^|]+") do
		if reel == option then
			if reel == "number" then
				return valeur == valeur and math.abs(valeur) ~= math.huge -- rejette NaN et ±inf
			elseif reel == "string" then
				return #valeur <= LONGUEUR_MAX_CHAINE
			elseif reel == "Vector3" then
				local norme = valeur.Magnitude
				return norme == norme and norme <= NORME_MAX_VECTEUR
			end
			return true
		end
	end
	return false
end

local function argumentsValides(regle, ...: any): boolean
	local types = regle.Types or {}
	if select("#", ...) > #types then
		return false
	end
	for index, attendu in types do
		if not typeValide((select(index, ...)), attendu) then
			return false
		end
	end
	return true
end

-- Seau de jetons par joueur et par demande.
local function autoriser(joueur: Player, nom: string, regle): boolean
	local parJoueur = seaux[joueur]
	if not parJoueur then
		parJoueur = {}
		seaux[joueur] = parJoueur
	end
	local debit = regle.ParSeconde or 1
	local capacite = regle.Rafale or math.max(1, debit)
	local maintenant = os.clock()
	local seau = parJoueur[nom]
	if not seau then
		seau = { jetons = capacite, t = maintenant }
		parJoueur[nom] = seau
	end
	seau.jetons = math.min(capacite, seau.jetons + (maintenant - seau.t) * debit)
	seau.t = maintenant
	if seau.jetons < 1 then
		return false
	end
	seau.jetons -= 1
	return true
end

local function noterRefus(joueur: Player, nom: string)
	local total = (refus[joueur] or 0) + 1
	refus[joueur] = total
	if total % REFUS_AVANT_ALERTE == 0 then
		warn(`[Reseau] {joueur.Name} ({joueur.UserId}) : {total} demandes refusées, dernière sur {nom}`)
	end
end

local function compterDossiers(): number
	local total = 0
	for _, enfant in ReplicatedStorage:GetChildren() do
		if enfant.Name == NOM_DOSSIER then
			total += 1
		end
	end
	return total
end

local function viderFaits()
	if nbFaits == 0 then
		return
	end
	local paquet = buffer.create(nbFaits * OCTETS_FAIT)
	buffer.copy(paquet, 0, faits, 0, nbFaits * OCTETS_FAIT)
	nbFaits = 0
	Reseau.Obtenir("Evenements"):FireAllClients(paquet)
end

function Reseau.Initialiser()
	assert(RunService:IsServer(), "Reseau.Initialiser est réservé au serveur")
	if dossier then
		return
	end
	assert(compterDossiers() == 0, "ReplicatedStorage.Remotes existe déjà : seul Reseau crée ce dossier")
	local nouveau = Instance.new("Folder")
	nouveau.Name = NOM_DOSSIER
	for nom, regle in Regles do
		local estDemande = regle.Sens == "C2S"
		assert(
			regle.Classe == "RemoteEvent" or (regle.Classe == "UnreliableRemoteEvent" and not estDemande),
			`{nom} : RemoteEvent uniquement (UnreliableRemoteEvent pour les flux serveur)`
		)
		assert(estDemande == (string.sub(nom, 1, 7) == "Demande"), `{nom} : seules les demandes client s'appellent Demande*`)
		local remote = Instance.new(regle.Classe)
		remote.Name = nom
		remote.Parent = nouveau
	end
	nouveau.Parent = ReplicatedStorage
	dossier = nouveau
	assert(compterDossiers() == 1, "Un seul enfant Remotes est permis dans ReplicatedStorage")
	task.delay(10, function()
		assert(compterDossiers() == 1, "Un second dossier Remotes est apparu : un script crée encore ses propres remotes")
	end)

	Players.PlayerRemoving:Connect(function(joueur)
		seaux[joueur] = nil
		refus[joueur] = nil
	end)

	local cumul = 0
	RunService.Heartbeat:Connect(function(dt)
		cumul += dt
		if cumul >= PERIODE_FAITS then
			cumul = 0
			viderFaits()
		end
	end)
end

function Reseau.Obtenir(nom: string): any
	assert(Regles[nom], `Remote inconnu : {nom}`)
	if RunService:IsServer() then
		Reseau.Initialiser()
		return (dossier :: Folder):FindFirstChild(nom)
	end
	return ReplicatedStorage:WaitForChild(NOM_DOSSIER):WaitForChild(nom)
end

-- Serveur : l'unique gestionnaire d'une demande. Garde : profil chargé, débit, nombre et types des arguments.
function Reseau.Brancher(nom: string, gestionnaire: (Player, ...any) -> ...any)
	local regle = Regles[nom]
	assert(regle and regle.Sens == "C2S", `{nom} n'est pas une demande client`)
	assert(not branches[nom], `{nom} a déjà un gestionnaire : une demande n'en a qu'un`)
	branches[nom] = true
	Reseau.Obtenir(nom).OnServerEvent:Connect(function(joueur: Player, ...: any)
		if joueur:GetAttribute("DonneesChargees") ~= true
			or not autoriser(joueur, nom, regle)
			or not argumentsValides(regle, ...)
		then
			noterRefus(joueur, nom)
			return
		end
		local ok, erreur = pcall(gestionnaire, joueur, ...)
		if not ok then
			warn(`[Reseau] {nom} : {erreur}`)
		end
	end)
end

function Reseau.Envoyer(joueur: Player, nom: string, ...: any)
	assert(Regles[nom] and Regles[nom].Sens == "S2C", `{nom} n'est pas un retour serveur`)
	Reseau.Obtenir(nom):FireClient(joueur, ...)
end

function Reseau.Diffuser(nom: string, ...: any)
	assert(Regles[nom] and Regles[nom].Sens == "S2C", `{nom} n'est pas un retour serveur`)
	Reseau.Obtenir(nom):FireAllClients(...)
end

-- Toutes les réponses aux demandes passent par Annonce.
function Reseau.Annoncer(joueur: Player, code: string, donnees: { [string]: any }?)
	Reseau.Envoyer(joueur, "Annonce", code, donnees)
end

function Reseau.Refuser(joueur: Player, demande: string, raison: string?)
	Reseau.Annoncer(joueur, "Refus", { Demande = demande, Raison = raison or "Refuse" })
end

-- Serveur, 10 Hz : l'état des Zbires en un seul buffer (a26).
function Reseau.DiffuserEtatZbires(zbires: { EtatZbire })
	local centre = centrePlace()
	local n = math.min(#zbires, ZBIRES_MAX)
	local b = buffer.create(n * OCTETS_ZBIRE)
	for i = 1, n do
		local z = zbires[i]
		local o = (i - 1) * OCTETS_ZBIRE
		local relatif = z.Position - centre
		buffer.writeu16(b, o, z.Id % 65536)
		buffer.writeu8(b, o + 2, z.Type)
		buffer.writei16(b, o + 3, borneI16(relatif.X * ECHELLE))
		buffer.writei16(b, o + 5, borneI16(relatif.Z * ECHELLE))
		buffer.writeu8(b, o + 7, borneU8(relatif.Y * 10))
		buffer.writeu8(b, o + 8, if z.PVMax > 0 then borneU8(z.PV / z.PVMax * 255) else 0)
	end
	Reseau.Obtenir("EtatZbires"):FireAllClients(b)
end

-- Client : fn(id, type, position, pv de 0 à 1) pour chaque Zbire du paquet.
function Reseau.LireEtatZbires(b: buffer, fn: (number, number, Vector3, number) -> ())
	local centre = centrePlace()
	for o = 0, buffer.len(b) - OCTETS_ZBIRE, OCTETS_ZBIRE do
		local position = centre
			+ Vector3.new(buffer.readi16(b, o + 3) / ECHELLE, buffer.readu8(b, o + 7) / 10, buffer.readi16(b, o + 5) / ECHELLE)
		fn(buffer.readu16(b, o), buffer.readu8(b, o + 2), position, buffer.readu8(b, o + 8) / 255)
	end
end

-- Serveur : ajoute un fait au paquet Evenements, envoyé toutes les 0,1 s (tout de suite si 100 faits attendent).
function Reseau.AjouterFait(code: number, id: number, position: Vector3?, argument: number?)
	assert(RunService:IsServer(), "Reseau.AjouterFait est réservé au serveur")
	if nbFaits >= FAITS_MAX then
		viderFaits()
	end
	local o = nbFaits * OCTETS_FAIT
	local relatif = if position then position - centrePlace() else Vector3.zero
	buffer.writeu8(faits, o, code)
	buffer.writeu16(faits, o + 1, id % 65536)
	buffer.writei16(faits, o + 3, borneI16(relatif.X * ECHELLE))
	buffer.writei16(faits, o + 5, borneI16(relatif.Z * ECHELLE))
	buffer.writeu8(faits, o + 7, borneU8(argument or 0))
	nbFaits += 1
end

-- Client : fn(code, id, position, argument). Un seul décodage par paquet, partagé par VfxClient, Son,
-- ZbireAnimateur et l'UI : chacun joue sa part (image, son, animation), jamais deux fois la même.
function Reseau.SurFait(fn: (number, number, Vector3, number) -> ())
	assert(RunService:IsClient(), "Reseau.SurFait est réservé au client")
	table.insert(ecouteurs, fn)
	if clientBranche then
		return
	end
	clientBranche = true
	Reseau.Obtenir("Evenements").OnClientEvent:Connect(function(paquet: buffer)
		local centre = centrePlace()
		for o = 0, buffer.len(paquet) - OCTETS_FAIT, OCTETS_FAIT do
			local code = buffer.readu8(paquet, o)
			local id = buffer.readu16(paquet, o + 1)
			local position = centre + Vector3.new(buffer.readi16(paquet, o + 3) / ECHELLE, 0, buffer.readi16(paquet, o + 5) / ECHELLE)
			local argument = buffer.readu8(paquet, o + 7)
			for _, ecouteur in ecouteurs do
				local ok, erreur = pcall(ecouteur, code, id, position, argument)
				if not ok then
					warn(`[Reseau] Écouteur Evenements : {erreur}`)
				end
			end
		end
	end)
end

return Reseau
```

### a27/Run.lua
```lua
-- ServerScriptService.Modules.Run (ModuleScript) : la run de la Prairie (serveur réservé, MaxPlayers 6)
-- Run.Demarrer() (appelé par Persistance) crée ReplicatedStorage.EtatRun, lit la fiche Capsules, puis écrit
-- RunEnCours_<UserId> à chaque arrivée. a29 appelle Run.JourFranchi(jour) et Run.Terminer(totaux, jour).
-- Workspace ne porte que TypePlace, CentrePlace et RayonPlace : l'état de la run vit dans EtatRun.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Donnees = require(script.Parent.Donnees)
local Passage = require(script.Parent.Passage)

local ECRAN_FIN = 12 -- s d'écran de fin avant le retour au Laboratoire
local ATTENTE_PROFIL = 40 -- s : chargement du profil à l'arrivée (verrou du Laboratoire compris)

-- Attributs de ReplicatedStorage.EtatRun. Phase : "Horde" | "Repit" | "Colosse" ; FinPhase : GetServerTimeNow().
-- Niv_* : niveaux d'Établi partagés par l'équipe ; Cagnotte_* : pièces versées vers le niveau suivant.
local ETAT_INITIAL = {
	Mode = "Normale",
	Jour = 0,
	Phase = "Repit",
	FinPhase = 0,
	Niv_Solidite = 0,
	Niv_Reparation = 0,
	Niv_Regeneration = 0,
	Cagnotte_Solidite = 0,
	Cagnotte_Reparation = 0,
	Cagnotte_Regeneration = 0,
}

local Run = {}
Run.Id = HttpService:GenerateGUID(false) -- runId : clé d'idempotence de Donnees.CrediterRun
Run.Fiche = nil :: Passage.Fiche?
Run.Etat = nil :: Configuration?
Run.Terminee = false
-- Fourni par a29 : totaux de gemmes de la run par UserId, lus si le serveur ferme avant la fin (Run.Clore).
Run.CalculerTotaux = nil :: (() -> { [number]: number })?

local participants: { [number]: boolean } = {}

local function attendreProfil(joueur: Player): boolean
	local debut = os.clock()
	while joueur.Parent and joueur:GetAttribute("DonneesChargees") ~= true do
		if os.clock() - debut > ATTENTE_PROFIL then
			return false
		end
		task.wait(0.5)
	end
	return joueur.Parent ~= nil
end

-- « Record : Jour X » au-dessus de la Maison : meilleur jour des Survivants présents.
local function afficherRecord()
	local maison = workspace:FindFirstChild("Maison")
	if not maison then
		return
	end
	local record = 0
	for _, joueur in Players:GetPlayers() do
		local profil = Donnees.Obtenir(joueur)
		if profil then
			record = math.max(record, profil.Records.MeilleurJour)
		end
	end
	maison:SetAttribute("Record", record)
end

local function accueillir(joueur: Player)
	participants[joueur.UserId] = true
	if not attendreProfil(joueur) then
		return
	end
	local fiche = Run.Fiche :: Passage.Fiche
	if Run.Terminee or fiche.Terminee then
		Passage.Teleporter({ joueur }, Catalogue.Places.Laboratoire) -- run finie : retour au Laboratoire
		return
	end
	Passage.NoterRunEnCours(joueur.UserId, fiche)
	afficherRecord()
end

local function oublierRun()
	task.spawn(Passage.TerminerFiche)
	for userId in participants do
		task.spawn(Passage.OublierRunEnCours, userId)
	end
end

function Run.Demarrer()
	assert(workspace:GetAttribute("TypePlace") == "Prairie", "Run.Demarrer : place Prairie uniquement")
	assert(not ReplicatedStorage:FindFirstChild("EtatRun"), "ReplicatedStorage.EtatRun existe déjà")
	local etat = Instance.new("Configuration")
	etat.Name = "EtatRun"
	for nom, valeur in ETAT_INITIAL do
		etat:SetAttribute(nom, valeur)
	end
	etat.Parent = ReplicatedStorage
	Run.Etat = etat

	local fiche = Passage.LireFiche()
	Run.Fiche = fiche
	etat:SetAttribute("Mode", fiche.Mode)

	Players.PlayerAdded:Connect(accueillir)
	for _, joueur in Players:GetPlayers() do
		task.spawn(accueillir, joueur)
	end
end

-- a29, à chaque jour franchi, après ses AjouterGemmes(joueur, n, "Jour", Run.Id) : sauvegarde (canon).
function Run.JourFranchi(jour: number)
	local etat = Run.Etat :: Configuration
	etat:SetAttribute("Jour", jour)
	Donnees.SauvegarderTous(true)
	for _, joueur in Players:GetPlayers() do
		task.spawn(Passage.NoterRunEnCours, joueur.UserId, Run.Fiche)
	end
end

-- a29, quand la Maison tombe. totaux[UserId] = gemmes totales de la run (jours, Mine, Doré, bonus de fin).
-- CrediterRun ne verse que le reliquat : les jours déjà payés ne le sont jamais deux fois.
function Run.Terminer(totaux: { [number]: number }, jour: number)
	if Run.Terminee then
		return
	end
	Run.Terminee = true
	for _, joueur in Players:GetPlayers() do
		Donnees.CrediterRun(joueur, Run.Id, totaux[joueur.UserId] or 0, true)
		Donnees.Modifier(joueur, function(p)
			if jour <= p.Records.MeilleurJour then
				return false
			end
			p.Records.MeilleurJour = jour
			return true
		end)
		Reseau.Annoncer(joueur, "FinDeRun", { Jour = jour, Gemmes = totaux[joueur.UserId] or 0 })
	end
	oublierRun()
	task.wait(ECRAN_FIN)
	Passage.Teleporter(Players:GetPlayers(), Catalogue.Places.Laboratoire)
end

-- BindToClose de la Prairie (via Persistance), avant Donnees.FermerTout : verse les reliquats et clôt la run.
function Run.Clore()
	if Run.Terminee then
		return
	end
	Run.Terminee = true
	local ok, totaux = pcall(function()
		return if Run.CalculerTotaux then Run.CalculerTotaux() else {}
	end)
	for _, joueur in Players:GetPlayers() do
		local total = if ok and type(totaux) == "table" then totaux[joueur.UserId] or 0 else 0
		Donnees.CrediterRun(joueur, Run.Id, total, true)
	end
	oublierRun()
end

return Run
```

### a27/SchemaJoueur.lua
```lua
-- ServerScriptService.Modules.SchemaJoueur (ModuleScript) : forme du profil unique d'un Survivant, version 2
-- Store Zsurvie_Joueurs_v1, clé J_<UserId>. Changement de forme = VERSION + 1 et une entrée dans MIGRATIONS.
-- Clés sans accents (identifiants de code) ; l'UI affiche les noms du canon (Casqué, Doré, Tourelle de toit...).
-- Fonctions pures et sans yield : Donnees les appelle dans le transform de UpdateAsync.

local SchemaJoueur = {}

SchemaJoueur.VERSION = 2

local RUNS_TERMINEES_MAX = 20
local DUREE_ACHATS = 90 * 86400 -- reçus Robux gardés 90 jours

function SchemaJoueur.Defaut(): { [string]: any }
	return {
		Version = SchemaJoueur.VERSION,
		Gemmes = 0,
		GemmesCumul = 0, -- total gagné à vie
		XP = 0,
		Recherches = {
			TourelleDeToit = 0,
			BallesPerforantes = 0,
			ViseeCritique = 0,
			Foreuse = 0,
		},
		Foreuse = {
			DerniereRecolte = 0, -- os.time() UTC ; production plafonnée à 8 h
			Reste = 0, -- fraction de gemme en cours (0 à 1)
		},
		TurboForeuseFin = 0, -- a08 : os.time() de fin du turbo
		Records = {
			MeilleurJour = 0,
			Runs = 0,
			ColossesVaincus = 0,
		},
		Eliminations = { -- paliers de la Galerie des Zbires (10, 100, 1 000) calculés, jamais stockés
			Marcheur = 0,
			Rapide = 0,
			Costaud = 0,
			Dore = 0,
			Sauteur = 0,
			Gluant = 0,
			MiniGluant = 0,
			Volant = 0,
			Casque = 0,
			Colosse = 0,
		},
		RunsCreditees = {}, -- [runId] = gemmes déjà versées pour cette run (idempotence de CrediterRun)
		RunsTerminees = {}, -- 20 derniers runId clos : plus rien n'y est versé
		AccueilEtape = 0, -- a50 : accueil de Doc Boulon (remplace Tutoriel et EtapeOnboarding de a10)
		DernierBonus = "", -- Temps.cleJour() du dernier bonus quotidien
		Calendrier = { Case = 0, CleJour = "" }, -- dernière case ouverte et son Temps.cleJour()
		Quotidien = { CleDefi = "" }, -- Temps.cleJour() du dernier Défi du Jour récompensé
		ZbireSemaine = { CleSemaine = "" }, -- Temps.cleSemaine() de la dernière participation (sans gemmes)
		Secrets = { trouves = {}, jour = "" }, -- a13 : [idSecret] = true ; Temps.cleJour() de l'énigme
		Chapeaux = {}, -- a15 : [idChapeau] = true
		JourChapeau = "", -- a15 : Temps.cleJour()
		Tampons = {}, -- a15 : [idTampon] = true
		JourTampon = "", -- a15 : Temps.cleJour()
		Peluches = {}, -- a22 : [idPeluche] = true
		Cosmetiques = {
			Possedes = {}, -- a46 : ["Blaster:ArcEnCiel"] = true
			Equipes = { Blaster = "Base", SacADos = "Base", Alcove = "Base" },
		},
		Achats = {}, -- a46 : [PurchaseId] = os.time() (ProcessReceipt idempotent)
		Reglages = {
			VolumeMusique = 0.6,
			VolumeEffets = 0.8,
			EffetsReduits = false,
			Secousses = true,
			TirAuto = true,
		},
		DerniereSauvegarde = 0,
		-- Verrou = { Id, JobId, PlaceId, Horodatage } : posé et retiré par Donnees, absent du défaut
	}
end

-- Champs de valeur : jamais remis à zéro. Mauvais type -> tonumber, sinon le chargement est refusé.
-- Gemmes et Recherches (consigne) ; Cosmetiques.Possedes et Achats, payés en Robux (a46).
local PROTEGES: { [string]: boolean } = {
	Gemmes = true,
	Recherches = true,
	Cosmetiques = true,
	["Cosmetiques.Possedes"] = true,
	Achats = true,
}
for nom in SchemaJoueur.Defaut().Recherches do
	PROTEGES[`Recherches.{nom}`] = true
end

-- MIGRATIONS[v] transforme un profil v en v + 1.
local MIGRATIONS: { [number]: ({ [string]: any }) -> () } = {
	[1] = function(d)
		-- Accueil de Doc Boulon (a50) : reprend Tutoriel.Etape (a27 v1) et EtapeOnboarding (a10).
		local tutoriel = if type(d.Tutoriel) == "table" then d.Tutoriel else {}
		d.AccueilEtape = math.max(tonumber(tutoriel.Etape) or 0, tonumber(d.EtapeOnboarding) or 0)
		d.Tutoriel = nil
		d.EtapeOnboarding = nil
		-- Réglages renommés ; les valeurs absentes sont posées par Reconcilier.
		local r = if type(d.Reglages) == "table" then d.Reglages else {}
		d.Reglages = {
			VolumeMusique = r.Musique,
			VolumeEffets = r.Effets,
			Secousses = r.Vibrations,
			TirAuto = r.TirAuto,
		}
		-- Achats : liste des 50 derniers PurchaseId -> dictionnaire [PurchaseId] = horodatage.
		local achats = {}
		if type(d.Achats) == "table" then
			for _, id in d.Achats do
				if type(id) == "string" then
					achats[id] = os.time()
				end
			end
		end
		d.Achats = achats
	end,
}

-- Renvoie false si le profil vient d'une version plus récente du jeu (serveur pas encore mis à jour).
function SchemaJoueur.Migrer(d: { [string]: any }): boolean
	local version = tonumber(d.Version) or 1
	if version > SchemaJoueur.VERSION then
		return false
	end
	while version < SchemaJoueur.VERSION do
		local migration = MIGRATIONS[version]
		assert(migration, `Migration manquante pour la version {version}`)
		migration(d)
		version += 1
	end
	d.Version = version
	return true
end

-- Pose les champs manquants et répare les types. Renvoie false et le chemin fautif si un champ
-- de valeur est illisible : l'appelant refuse alors le chargement sans rien écrire.
function SchemaJoueur.Reconcilier(cible: { [any]: any }, modele: { [any]: any }, chemin: string?): (boolean, string?)
	for cle, defaut in modele do
		local ici = if chemin then `{chemin}.{cle}` else tostring(cle)
		local valeur = cible[cle]
		if valeur == nil then
			cible[cle] = defaut
		elseif typeof(valeur) ~= typeof(defaut) then
			if PROTEGES[ici] then
				local nombre = if type(defaut) == "number" then tonumber(valeur) else nil
				if nombre == nil or nombre ~= nombre or math.abs(nombre) == math.huge then
					return false, ici
				end
				cible[cle] = nombre
			else
				warn(`[SchemaJoueur] Champ {ici} corrompu ({typeof(valeur)}), remis à sa valeur par défaut`)
				cible[cle] = defaut
			end
		elseif type(valeur) == "table" then
			local ok, fautif = SchemaJoueur.Reconcilier(valeur, defaut, ici)
			if not ok then
				return false, fautif
			end
		end
	end
	return true, nil
end

-- Bornes : aucun solde ni niveau négatif ou fractionnaire ; purge des listes qui grossissent.
function SchemaJoueur.Assainir(d: { [string]: any })
	d.Gemmes = math.max(0, math.floor(d.Gemmes))
	d.GemmesCumul = math.max(d.Gemmes, math.floor(d.GemmesCumul))
	d.XP = math.max(0, math.floor(d.XP))
	for _, groupe in { d.Recherches, d.Records, d.Eliminations } do
		for cle, valeur in groupe do
			if type(valeur) == "number" then
				groupe[cle] = math.max(0, math.floor(valeur))
			end
		end
	end
	d.Foreuse.Reste = math.clamp(d.Foreuse.Reste, 0, 0.999)
	for runId, total in d.RunsCreditees do
		if type(total) ~= "number" then
			d.RunsCreditees[runId] = nil
		end
	end
	while #d.RunsTerminees > RUNS_TERMINEES_MAX do
		table.remove(d.RunsTerminees, 1)
	end
	local limite = os.time() - DUREE_ACHATS
	for idAchat, quand in d.Achats do
		if type(quand) ~= "number" or quand < limite then
			d.Achats[idAchat] = nil
		end
	end
end

function SchemaJoueur.Copie(v: any): any
	if type(v) ~= "table" then
		return v
	end
	local copie = {}
	for cle, valeur in v do
		copie[cle] = SchemaJoueur.Copie(valeur)
	end
	return copie
end

-- Prépare un profil lu dans le store : (profil) ou (nil, "Version" | "Corrompu", chemin?).
function SchemaJoueur.Preparer(brut: any): ({ [string]: any }?, string?, string?)
	if brut == nil then
		return SchemaJoueur.Defaut(), nil, nil
	end
	if type(brut) ~= "table" then
		return nil, "Corrompu", "racine"
	end
	if not SchemaJoueur.Migrer(brut) then
		return nil, "Version", nil
	end
	local ok, chemin = SchemaJoueur.Reconcilier(brut, SchemaJoueur.Defaut())
	if not ok then
		return nil, "Corrompu", chemin
	end
	SchemaJoueur.Assainir(brut)
	return brut, nil, nil
end

return SchemaJoueur
```

### a27/ServicesLaboratoire.server.lua
```lua
-- ServerScriptService.ServicesLaboratoire (Script) : place Laboratoire uniquement
-- DemandeRecherche(nom, niveauVise), DemandeForeuse(), DemandeDeblocage("Equiper", "Emplacement:Id"),
-- DemandeCapsule("Monter", capsule | "Quitter" | "Rejoindre"). Toutes les réponses partent par Annonce.
-- Instances : Workspace.Laboratoire.ArbreDesRecherches (Model)
--             Workspace.Laboratoire.Alcoves.Alcove1 ... Alcove12 (Model)
--             Workspace.Laboratoire.QuaiDesCapsules.Normale / .Difficile / .DuJour (Model)
-- Attributs : Player.Alcove (1 à 12, posé par l'attribution des Alcôves) ; Player.RunEnCours (posé ici) ;
--             Capsule.Passagers (0 à 6) et Capsule.Depart (workspace:GetServerTimeNow(), 0 = à quai), posés ici.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Modules = ServerScriptService:WaitForChild("Modules")
local Donnees = require(Modules:WaitForChild("Donnees"))
local Passage = require(Modules:WaitForChild("Passage"))

local laboratoire = workspace:WaitForChild("Laboratoire")
local arbre = laboratoire:WaitForChild("ArbreDesRecherches")
local alcoves = laboratoire:WaitForChild("Alcoves")
local quai = laboratoire:WaitForChild("QuaiDesCapsules")

local RAYON_ARBRE = 18 -- studs
local RAYON_ALCOVE = 14 -- studs
local RAYON_QUAI = 12 -- studs

local function proche(joueur: Player, cible: Instance?, rayon: number): boolean
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if not racine or not cible or not cible:IsA("PVInstance") then
		return false
	end
	return (racine.Position - cible:GetPivot().Position).Magnitude <= rayon
end

local function alcoveDe(joueur: Player): Instance?
	local numero = joueur:GetAttribute("Alcove")
	if type(numero) ~= "number" then
		return nil
	end
	return alcoves:FindFirstChild(`Alcove{numero}`)
end

-- Recherches : un double tap envoie deux fois le même niveauVise, le second est refusé sans débit.
Reseau.Brancher("DemandeRecherche", function(joueur: Player, nom: string, niveauVise: number)
	if not proche(joueur, arbre, RAYON_ARBRE) then
		Reseau.Refuser(joueur, "DemandeRecherche", "TropLoin")
		return
	end
	local ok, raison = Donnees.AcheterRecherche(joueur, nom, niveauVise)
	if ok then
		Reseau.Annoncer(joueur, "Recherche", { Nom = nom, Niveau = niveauVise })
	else
		Reseau.Refuser(joueur, "DemandeRecherche", raison)
	end
end)

Reseau.Brancher("DemandeForeuse", function(joueur: Player)
	if not proche(joueur, alcoveDe(joueur), RAYON_ALCOVE) then
		Reseau.Refuser(joueur, "DemandeForeuse", "TropLoin")
		return
	end
	Reseau.Annoncer(joueur, "Foreuse", { Gain = Donnees.RecolterForeuse(joueur) })
end)

-- Équipement : "Base" toujours disponible, sinon Cosmetiques.Possedes["Emplacement:Id"] (a46).
local EMPLACEMENTS = {}
for _, emplacement in Catalogue.Emplacements do
	EMPLACEMENTS[emplacement] = true
end

Donnees.DefinirDeblocage("Equiper", function(joueur: Player, id: any): boolean
	if type(id) ~= "string" then
		return false
	end
	local emplacement, nom = string.match(id, "^(%a+):([%w_]+)$")
	if not emplacement or not EMPLACEMENTS[emplacement] then
		return false
	end
	return Donnees.Modifier(joueur, function(p)
		if nom ~= "Base" and p.Cosmetiques.Possedes[id] ~= true then
			return false
		end
		if p.Cosmetiques.Equipes[emplacement] == nom then
			return false
		end
		p.Cosmetiques.Equipes[emplacement] = nom
		return true
	end)
end)

-- Quai des Capsules
local capsules: { [string]: { Passagers: { Player }, Depart: number } } = {}
for _, mode in Catalogue.Capsules.Modes do
	capsules[mode] = { Passagers = {}, Depart = 0 }
end

local function publier(mode: string)
	local capsule = capsules[mode]
	local modele = quai:FindFirstChild(mode)
	if modele then
		modele:SetAttribute("Passagers", #capsule.Passagers)
		modele:SetAttribute("Depart", capsule.Depart)
	end
end

local function capsuleDe(joueur: Player): string?
	for mode, capsule in capsules do
		if table.find(capsule.Passagers, joueur) then
			return mode
		end
	end
	return nil
end

local function descendre(joueur: Player)
	local mode = capsuleDe(joueur)
	if not mode then
		return
	end
	local capsule = capsules[mode]
	table.remove(capsule.Passagers, table.find(capsule.Passagers, joueur) :: number)
	if #capsule.Passagers == 0 then
		capsule.Depart = 0
	end
	publier(mode)
end

local function partir(passagers: { Player }, mode: string)
	local presents = {}
	for _, joueur in passagers do
		if joueur.Parent then
			table.insert(presents, joueur)
		end
	end
	if #presents > 0 and not Passage.LancerRun(presents, mode) then
		for _, joueur in presents do
			Reseau.Annoncer(joueur, "PassageAnnule", { Raison = "Reseau" })
		end
	end
end

Reseau.Brancher("DemandeCapsule", function(joueur: Player, action: string, mode: string?)
	if action == "Quitter" then
		descendre(joueur)
	elseif action == "Rejoindre" then
		descendre(joueur)
		if not Passage.Rejoindre(joueur) then
			joueur:SetAttribute("RunEnCours", false)
			Reseau.Refuser(joueur, "DemandeCapsule", "RunTerminee")
		end
	elseif action == "Monter" then
		local capsule = if mode then capsules[mode] else nil
		if not capsule then
			Reseau.Refuser(joueur, "DemandeCapsule", "Inconnue")
		elseif capsuleDe(joueur) then
			Reseau.Refuser(joueur, "DemandeCapsule", "DejaAssis")
		elseif #capsule.Passagers >= Catalogue.Capsules.Places then
			Reseau.Refuser(joueur, "DemandeCapsule", "Complet")
		elseif not proche(joueur, quai:FindFirstChild(mode :: string), RAYON_QUAI) then
			Reseau.Refuser(joueur, "DemandeCapsule", "TropLoin")
		else
			table.insert(capsule.Passagers, joueur)
			if capsule.Depart == 0 then
				capsule.Depart = workspace:GetServerTimeNow() + Catalogue.Capsules.DelaiDepart
			end
			publier(mode :: string)
		end
	else
		Reseau.Refuser(joueur, "DemandeCapsule", "Inconnue")
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		local maintenant = workspace:GetServerTimeNow()
		for mode, capsule in capsules do
			if capsule.Depart > 0 and maintenant >= capsule.Depart then
				local passagers = capsule.Passagers
				capsule.Passagers = {}
				capsule.Depart = 0
				publier(mode)
				task.spawn(partir, passagers, mode)
			end
		end
	end
end)

-- « Rejoindre la run » : Player.RunEnCours = true si RunEnCours_<UserId> existe encore en MemoryStore.
local function verifierRunEnCours(joueur: Player)
	if joueur:GetAttribute("DonneesChargees") ~= true then
		return
	end
	local run = Passage.LireRunEnCours(joueur.UserId)
	if joueur.Parent then
		joueur:SetAttribute("RunEnCours", run ~= nil)
	end
end

local function surArrivee(joueur: Player)
	joueur:GetAttributeChangedSignal("DonneesChargees"):Connect(function()
		verifierRunEnCours(joueur)
	end)
	task.spawn(verifierRunEnCours, joueur)
end

Players.PlayerAdded:Connect(surArrivee)
for _, joueur in Players:GetPlayers() do
	surArrivee(joueur)
end

Players.PlayerRemoving:Connect(descendre)
```

### a27/Temps.lua
```lua
-- ReplicatedStorage.Temps (ModuleScript) : l'heure de Paris, seule horloge des rendez-vous de Zsurvie
-- Imposé au Défi du Jour, au Calendrier, aux secrets, aux énigmes, au Record du Jour et au Zbire de la Semaine.
-- Paris = UTC+1 en hiver, UTC+2 du dernier dimanche de mars au dernier dimanche d'octobre (bascule à 01:00 UTC).
-- L'heure vient toujours du serveur : os.time() côté serveur, workspace:GetServerTimeNow() côté client.
-- Roblox n'accepte que "*t" et "!*t" dans os.date.

local RunService = game:GetService("RunService")

local Temps = {}

local JOUR = 86400
local HEURE_ZBIRE_SEMAINE = 17 -- samedi 17 h, heure de Paris (canon)

function Temps.maintenant(): number
	if RunService:IsServer() then
		return os.time()
	end
	return math.floor(workspace:GetServerTimeNow()) -- jamais l'horloge du téléphone
end

-- Bascule d'heure : dernier dimanche de mars ou d'octobre, 01:00 UTC (ces deux mois ont 31 jours).
local function bascule(annee: number, mois: number): number
	local le31 = DateTime.fromUniversalTime(annee, mois, 31, 1, 0, 0, 0).UnixTimestamp
	return le31 - (os.date("!*t", le31).wday - 1) * JOUR -- wday : 1 = dimanche
end

function Temps.decalageParis(t: number): number
	local annee = os.date("!*t", t).year
	if t >= bascule(annee, 3) and t < bascule(annee, 10) then
		return 7200
	end
	return 3600
end

local function dateParis(t: number)
	return os.date("!*t", t + Temps.decalageParis(t))
end

-- "2026-09-26" : change à minuit, heure de Paris.
function Temps.cleJour(t: number?): string
	local d = dateParis(t or Temps.maintenant())
	return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

-- Secondes avant le prochain minuit de Paris (journées de 23 h et de 25 h comprises).
function Temps.SecondesAvantDemain(t: number?): number
	local maintenant = t or Temps.maintenant()
	local d = dateParis(maintenant)
	local minuitNaif = DateTime.fromUniversalTime(d.year, d.month, d.day, 0, 0, 0, 0).UnixTimestamp + JOUR
	-- Minuit à Paris tombe à 22 h ou 23 h UTC, avant toute bascule (01:00 UTC) : le décalage de 23 h UTC fait foi.
	return minuitNaif - Temps.decalageParis(minuitNaif - 3600) - maintenant
end

-- Date du samedi 17 h (Paris) qui a ouvert la semaine du Zbire de la Semaine en cours.
function Temps.cleSemaine(t: number?): string
	local maintenant = t or Temps.maintenant()
	local decale = maintenant + Temps.decalageParis(maintenant)
	local d = os.date("!*t", decale)
	local joursDepuisSamedi = d.wday % 7 -- samedi (7) -> 0, dimanche (1) -> 1 ... vendredi (6) -> 6
	if joursDepuisSamedi == 0 and d.hour < HEURE_ZBIRE_SEMAINE then
		joursDepuisSamedi = 7
	end
	local s = os.date("!*t", decale - joursDepuisSamedi * JOUR)
	return string.format("%04d-%02d-%02d", s.year, s.month, s.day)
end

return Temps
```

### a28/CameraPrairie.client.lua
```lua
-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > CameraPrairie (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Caméra de la Prairie (canon §8) : Scriptable, décalée de
-- (0, 45, 28) au-dessus du Survivant, FieldOfView 50, suivi lissé.
-- Les déplacements restent relatifs à la caméra (ControlModule par défaut) : haut du stick = vers -Z.
-- Secousses : ce script n'en calcule plus. Il les demande à UIKit.secouer → VfxClient.secouer (a37),
-- plafond 0,8 stud, coupé par le réglage Secousses. VfxClient applique son décalage APRÈS cette caméra
-- (BindToRenderStep à RenderPriority.Camera + 2) : la caméra repart d'une position propre à chaque frame.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 CameraPrairie] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local DECALAGE = Vector3.new(0, 45, 28) -- canon §8
local CHAMP = 50 -- FieldOfView, canon §8
local RAIDEUR = 10 -- lissage exponentiel du suivi

local joueur = Players.LocalPlayer
local focus: Vector3? = nil

RunService:BindToRenderStep("CameraPrairie", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end
	if camera.FieldOfView ~= CHAMP then
		camera.FieldOfView = CHAMP
	end
	local racine = UIKit.racineLocale()
	if not racine then
		return
	end
	local cible = racine.Position
	if not focus or (focus - cible).Magnitude > 60 then
		focus = cible -- apparition ou téléportation : pas de travelling
	else
		focus = focus:Lerp(cible, 1 - math.exp(-RAIDEUR * dt))
	end
	camera.CFrame = CFrame.lookAt(focus + DECALAGE, focus)
end)

-- Résolution anticipée (réglages du joueur, module de a37) : aucune attente au premier choc.
task.spawn(UIKit.reglages)
task.spawn(UIKit.module, "VfxClient", true)

-- Déclencheurs de secousse, tous lus dans l'état serveur.
UIKit.ecouter("Annonce", function(cle: string)
	if cle == "Colosse" then
		UIKit.secouer(0.8)
	end
end)

joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
	if UIKit.estEtourdi(joueur) then
		UIKit.secouer(0.6)
	end
end)

local etatRun = UIKit.etatRun()
if etatRun then
	local derniersPV = tonumber(etatRun:GetAttribute("MaisonPV"))
	etatRun:GetAttributeChangedSignal("MaisonPV"):Connect(function()
		local pv = tonumber(etatRun:GetAttribute("MaisonPV")) or 0
		local pvMax = math.max(1, tonumber(etatRun:GetAttribute("MaisonPVMax")) or 1)
		if derniersPV and (derniersPV - pv) / pvMax > 0.05 then
			UIKit.secouer(0.3)
		end
		derniersPV = pv
	end)
end
```

### a28/Controles.client.lua
```lua
-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Controles (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Contrôles du Survivant sur la Prairie.
-- Variante A (défaut) : RÉPARER 96 px dans le coin bas droit, puis Muret, Mini-Tourelle, Tapis Collant
-- et Ping (64 px) sur un arc de 150 px (180°, 210°, 240°, 270°) ; cadenas « Niv. X » si verrouillé.
-- Variante B du test H2 (Player.TestH2 = "B", écrit par le serveur) : RÉPARER 96 + POSER 72 / PINGS 72.
-- Touches : E (Réparer), 1-2-3 (défenses), Q (Ping) ; l'Établi (F, ButtonY) est géré par Etabli.
-- Le tir appartient à BlasterControleur (a26) : un tap ou un clic sur un Zbire le désigne comme cible
-- prioritaire. Le client n'envoie que des DEMANDES ; le serveur vérifie cible, distance, cadence, solde.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Controles] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
local etatRun = UIKit.etatRun()
if not (playerGui and etatRun) then
	return
end
local zbiresRendu = UIKit.module("ZbiresRendu", true)
local blaster = UIKit.module("BlasterControleur", true)
for _, nom in { "DemandeReparation", "DemandePose", "DemandePing" } do
	UIKit.remote(nom) -- résolution anticipée : aucune attente pendant le combat
end

local TOLERANCE_DESIGNATION = 56 -- px autour d'un Zbire (ZbiresRendu.chercher)
local DISTANCE_POSE = 5 -- studs devant le Survivant
local ATTENTE_PING = 2 -- s, identique au contrôle serveur
local DUREE_ROUE = 4 -- s avant fermeture automatique d'une roue
local COTE_GRAPPE = 230 -- px : RÉPARER 96 dans le coin + arc de 150 px + boutons de 64 px
local CENTRE_REPARER = Vector2.new(182, 182) -- 230 − 96 / 2
local RAYON_ARC = 150 -- px
local ANGLES_ARC = { 180, 210, 240, 270 } -- Muret, Mini-Tourelle, Tapis Collant, Ping
local RAPIDE = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PULSATION = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local clavier = UserInputService.KeyboardEnabled

local TOUCHES_CHOIX = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.KeypadOne] = 1,
	[Enum.KeyCode.KeypadTwo] = 2,
	[Enum.KeyCode.KeypadThree] = 3,
	[Enum.KeyCode.KeypadFour] = 4,
}

local TOUCHES_DEFENSE = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.KeypadOne] = 1,
	[Enum.KeyCode.KeypadTwo] = 2,
	[Enum.KeyCode.KeypadThree] = 3,
	[Enum.KeyCode.DPadLeft] = 1,
	[Enum.KeyCode.DPadDown] = 2,
	[Enum.KeyCode.DPadRight] = 3,
}

local MESSAGES_REFUS = {
	PasAssezDePieces = "Pas assez de pièces !",
	TropDeDefenses = "3 défenses posées au maximum !",
	TropLoin = "Trop loin !",
	Emplacement = "Impossible de poser ici !",
	Etourdi = "Tu es étourdi !",
	Attente = "Attends un peu !",
	Verrou = "Pas encore débloqué !",
}

-- Test H2 : attribut écrit par le serveur à l'arrivée ; sans valeur après 2 s, variante A.
local function lireVariante(): string
	local debut = os.clock()
	while joueur:GetAttribute("TestH2") == nil and os.clock() - debut < 2 do
		task.wait(0.1)
	end
	return if joueur:GetAttribute("TestH2") == "B" then "B" else "A"
end
local variante = lireVariante()

------------------------------------------------------------------------------------------
-- Grappe d'actions (bas droite, 230 × 230 px, 12 px de marge). Aucun bouton de saut.
------------------------------------------------------------------------------------------

local gui = UIKit.creer("ScreenGui", {
	Name = "ControlesZsurvie",
	DisplayOrder = 3, -- au-dessus de l'Établi (2) : RÉPARER reste visible et utilisable
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local grappe = UIKit.creer("Frame", {
	Name = "Actions",
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -12, 1, -12),
	Size = UDim2.fromOffset(COTE_GRAPPE, COTE_GRAPPE),
	Parent = gui,
})
UIKit.echelle(grappe)

local function creerAction(nom: string, texte: string, cote: number, centre: Vector2, couleur: Color3, touche: string)
	local bouton, label = UIKit.bouton(grappe, texte, UDim2.fromOffset(cote, cote), couleur, if cote >= 72 then 22 else 16)
	bouton.Name = nom
	bouton.AnchorPoint = Vector2.new(0.5, 0.5)
	bouton.Position = UDim2.fromOffset(centre.X, centre.Y)
	if clavier then
		local indice = UIKit.etiquette(bouton, touche, UDim2.fromOffset(24, 22), 16)
		indice.Position = UDim2.fromOffset(-6, -6)
		indice.BackgroundColor3 = C.Encre
		indice.BackgroundTransparency = 0
	end
	return { bouton = bouton, label = label, texte = texte, contour = bouton:FindFirstChildOfClass("UIStroke") }
end

local function surArc(index: number): Vector2
	local angle = math.rad(ANGLES_ARC[index])
	return CENTRE_REPARER + Vector2.new(math.cos(angle), math.sin(angle)) * RAYON_ARC
end

-- Cadenas « Niv. X » : Player.Verrou<Cle> = niveau requis, écrit par le serveur (0 ou absent = libre).
local function creerVerrou(bouton: GuiObject)
	local voile = UIKit.creer("Frame", {
		Name = "Verrou",
		BackgroundColor3 = C.Encre,
		BackgroundTransparency = 0.25,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 3,
		Parent = bouton,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 8), Parent = voile })
	local anse = UIKit.creer("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 7),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 4,
		Parent = voile,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = anse })
	UIKit.creer("UIStroke", { Color = C.Creme, Thickness = 3, Parent = anse })
	UIKit.creer("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = C.Creme,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 15),
		Size = UDim2.fromOffset(22, 16),
		ZIndex = 5,
		Parent = voile,
	})
	local texte = UIKit.etiquette(voile, "Niv. 1", UDim2.new(1, -6, 0, 20), 16)
	texte.AnchorPoint = Vector2.new(0.5, 1)
	texte.Position = UDim2.new(0.5, 0, 1, -4)
	texte.ZIndex = 5
	return { voile = voile, texte = texte }
end

local reparer = creerAction("Reparer", "RÉPARER", 96, CENTRE_REPARER, C.ToitOrange, "E")
reparer.bouton.BackgroundTransparency = 0.4

local boutonsDefense = {} -- [cle] = action (variante A)
local secondaires = {} -- boutons masqués quand l'Établi est ouvert
local actionPoser = nil -- variante B
local actionPing

if variante == "A" then
	for index, defense in UIKit.DEFENSES do
		local action = creerAction(defense.cle, defense.court, 64, surArc(index), defense.couleur, tostring(index))
		action.label.AnchorPoint = Vector2.new(0.5, 0)
		action.label.Position = UDim2.new(0.5, 0, 0, 4)
		action.label.Size = UDim2.new(1, -8, 0.62, -4)
		action.prix = UIKit.etiquette(action.bouton, "", UDim2.new(1, -8, 0.3, 0), 14)
		action.prix.AnchorPoint = Vector2.new(0.5, 1)
		action.prix.Position = UDim2.new(0.5, 0, 1, -3)
		action.prix.TextColor3 = C.Or
		action.verrou = creerVerrou(action.bouton)
		boutonsDefense[defense.cle] = action
		table.insert(secondaires, action.bouton)
	end
	actionPing = creerAction("Ping", "PING", 64, surArc(4), C.NuitLabo, "Q")
else
	actionPoser = creerAction("Poser", "POSER\n0/3", 72, Vector2.new(86, 194), C.TerreBattue, "1-3")
	actionPing = creerAction("Pings", "PINGS", 72, Vector2.new(194, 86), C.NuitLabo, "Q")
	table.insert(secondaires, actionPoser.bouton)
end
table.insert(secondaires, actionPing.bouton)

-- Icône du crochet a10 (Charte.Icones.PingColosse), affichée à la place du texte.
actionPing.icone = UIKit.creer("ImageLabel", {
	Name = "Icone",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.8, 0.8),
	Visible = false,
	Parent = actionPing.bouton,
})

-- Voile d'attente du bouton Ping (2 s).
local attentePing = UIKit.creer("Frame", {
	Name = "Attente",
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 1),
	Size = UDim2.fromScale(1, 0),
	ZIndex = 2,
	Parent = actionPing.bouton,
})

------------------------------------------------------------------------------------------
-- Roue (centre de l'écran) : 4 pings, ou 3 défenses en variante B ; options 96 × 64 px
------------------------------------------------------------------------------------------

local roue = UIKit.creer("Frame", {
	Name = "Roue",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.58),
	Size = UDim2.fromOffset(330, 240),
	Visible = false,
	Parent = gui,
})
UIKit.echelle(roue)

local POSITIONS = {
	[3] = { Vector2.new(-110, 0), Vector2.new(0, -84), Vector2.new(110, 0) },
	[4] = { Vector2.new(0, -84), Vector2.new(110, 0), Vector2.new(0, 84), Vector2.new(-110, 0) },
}
local roueOuverte: string? = nil
local optionsRoue = {}
local rappelsRoue = {}
local jetonRoue = 0

local function fermerRoue()
	if not roueOuverte then
		return
	end
	roueOuverte = nil
	ContextActionService:UnbindAction("ZsurvieChoix")
	for _, bouton in optionsRoue do
		bouton:Destroy()
	end
	table.clear(optionsRoue)
	table.clear(rappelsRoue)
	roue.Visible = false
end

local function choisir(index: number)
	local rappel = rappelsRoue[index]
	fermerRoue()
	if rappel then
		UIKit.son("Clic")
		rappel()
	end
end

local function actionChoix(_, etat: Enum.UserInputState, entree: InputObject)
	if etat ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local index = TOUCHES_CHOIX[entree.KeyCode]
	if index and rappelsRoue[index] then
		choisir(index)
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

-- options : { { texte, couleur, rappel, sousTexte?, couleurSous? } }
local function ouvrirRoue(nom: string, options)
	if roueOuverte == nom then
		fermerRoue()
		return
	end
	fermerRoue()
	roueOuverte = nom
	roue.Visible = true
	local positions = POSITIONS[#options] or POSITIONS[4]
	for index, option in options do
		local centre = positions[index]
		local bouton = UIKit.creer("TextButton", {
			Name = "Option" .. index,
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = option.couleur,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			Text = "",
			Parent = roue,
		})
		UIKit.habiller(bouton, 8, 3)
		local hauteurTitre = if option.sousTexte then 0.58 else 1
		local titre = UIKit.etiquette(bouton, option.texte, UDim2.new(1, -8, hauteurTitre, -6), 20)
		titre.AnchorPoint = Vector2.new(0.5, 0)
		titre.Position = UDim2.new(0.5, 0, 0, 3)
		if option.sousTexte then
			local sous = UIKit.etiquette(bouton, option.sousTexte, UDim2.new(1, -8, 0.42, -4), 16)
			sous.AnchorPoint = Vector2.new(0.5, 1)
			sous.Position = UDim2.new(0.5, 0, 1, -3)
			sous.TextColor3 = option.couleurSous or C.Or
		end
		if clavier then
			local indice = UIKit.etiquette(bouton, tostring(index), UDim2.fromOffset(20, 20), 14)
			indice.Position = UDim2.fromOffset(-6, -6)
			indice.BackgroundColor3 = C.Encre
			indice.BackgroundTransparency = 0
		end
		TweenService:Create(
			bouton,
			TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, (index - 1) * 0.03),
			{ Position = UDim2.new(0.5, centre.X, 0.5, centre.Y), Size = UDim2.fromOffset(96, 64) }
		):Play()
		bouton.Activated:Connect(function()
			choisir(index)
		end)
		optionsRoue[index] = bouton
		rappelsRoue[index] = option.rappel
	end
	ContextActionService:BindActionAtPriority(
		"ZsurvieChoix",
		actionChoix,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.KeypadOne,
		Enum.KeyCode.KeypadTwo,
		Enum.KeyCode.KeypadThree,
		Enum.KeyCode.KeypadFour
	)
	jetonRoue += 1
	local jeton = jetonRoue
	task.delay(DUREE_ROUE, function()
		if jeton == jetonRoue and roueOuverte == nom then
			fermerRoue()
		end
	end)
end

------------------------------------------------------------------------------------------
-- Défenses (Muret, Mini-Tourelle, Tapis Collant ; 3 posées au maximum)
------------------------------------------------------------------------------------------

local dernierePose: string? = nil

local function refuser(raison: string)
	UIKit.toast(MESSAGES_REFUS[raison] or "Action impossible !", C.Alerte)
	UIKit.son("Refus")
end

local function positionDePose(racine: BasePart): Vector3
	local devant = racine.Position + racine.CFrame.LookVector * DISTANCE_POSE
	-- Grille décor de 1 stud (canon §7). Y indicatif : le serveur le recalcule par raycast.
	return Vector3.new(math.round(devant.X), racine.Position.Y - 3, math.round(devant.Z))
end

local function poser(cle: string)
	local racine = UIKit.racineLocale()
	if not racine then
		return
	end
	if UIKit.estEtourdi(joueur) then
		refuser("Etourdi")
		return
	end
	local verrou = tonumber(joueur:GetAttribute("Verrou" .. cle)) or 0
	if verrou > 0 then
		UIKit.toast(`Débloqué au Niv. {verrou} !`, C.Alerte)
		UIKit.son("Refus")
		return
	end
	if (tonumber(joueur:GetAttribute("Defenses")) or 0) >= UIKit.DEFENSES_MAX then
		refuser("TropDeDefenses")
		return
	end
	local prix = UIKit.prix(cle)
	if prix and (tonumber(joueur:GetAttribute("Pieces")) or 0) < prix then
		refuser("PasAssezDePieces")
		return
	end
	dernierePose = cle
	UIKit.envoyer("DemandePose", cle, positionDePose(racine))
end

local function majDefenses()
	local pieces = tonumber(joueur:GetAttribute("Pieces")) or 0
	local posees = math.floor(tonumber(joueur:GetAttribute("Defenses")) or 0)
	local plein = posees >= UIKit.DEFENSES_MAX
	for cle, action in boutonsDefense do
		local verrou = tonumber(joueur:GetAttribute("Verrou" .. cle)) or 0
		local prix = UIKit.prix(cle)
		action.verrou.voile.Visible = verrou > 0
		action.verrou.texte.Text = "Niv. " .. verrou
		action.prix.Text = if plein then `{posees}/{UIKit.DEFENSES_MAX}` elseif prix then UIKit.formater(prix) else ""
		action.prix.TextColor3 = if plein or (prix and pieces < prix) then C.Alerte else C.Or
		action.bouton.BackgroundTransparency = if plein then 0.45 else 0
	end
	if actionPoser then
		actionPoser.label.Text = `POSER\n{posees}/{UIKit.DEFENSES_MAX}`
	end
end

-- Variante B : POSER ouvre la roue des 3 défenses.
local function ouvrirDefenses()
	if UIKit.estEtourdi(joueur) then
		refuser("Etourdi")
		return
	end
	local pieces = tonumber(joueur:GetAttribute("Pieces")) or 0
	local options = {}
	for index, defense in UIKit.DEFENSES do
		local verrou = tonumber(joueur:GetAttribute("Verrou" .. defense.cle)) or 0
		local prix = UIKit.prix(defense.cle)
		options[index] = {
			texte = defense.texte,
			couleur = defense.couleur,
			sousTexte = if verrou > 0 then `Niv. {verrou}` elseif prix then UIKit.formater(prix) else "-",
			couleurSous = if verrou > 0 or (prix and pieces < prix) then C.Alerte else C.Or,
			rappel = function()
				poser(defense.cle)
			end,
		}
	end
	ouvrirRoue("Poser", options)
end

local poseesAvant = math.floor(tonumber(joueur:GetAttribute("Defenses")) or 0)
joueur.AttributeChanged:Connect(function(nom: string)
	if nom == "Defenses" then
		local posees = math.floor(tonumber(joueur:GetAttribute("Defenses")) or 0)
		local action = if dernierePose then boutonsDefense[dernierePose] or actionPoser else nil
		if posees > poseesAvant and action then
			UIKit.rebond(action.bouton)
			UIKit.son("Pose")
		end
		poseesAvant = posees
	end
	if nom == "Pieces" or nom == "Defenses" or string.sub(nom, 1, 6) == "Verrou" then
		majDefenses()
	end
end)
majDefenses()

------------------------------------------------------------------------------------------
-- Roue des Pings (remplace le chat : 4 phrases fixes, aucun texte libre)
------------------------------------------------------------------------------------------

local prochainPing = 0

local function ouvrirPings()
	local options = {}
	for index, ping in UIKit.PINGS do
		options[index] = {
			texte = ping.texte,
			couleur = ping.couleur,
			rappel = function()
				local racine = UIKit.racineLocale()
				if not racine then
					return
				end
				if os.clock() < prochainPing then
					refuser("Attente")
					return
				end
				prochainPing = os.clock() + ATTENTE_PING
				attentePing.Size = UDim2.fromScale(1, 1)
				TweenService:Create(attentePing, TweenInfo.new(ATTENTE_PING, Enum.EasingStyle.Linear), {
					Size = UDim2.fromScale(1, 0),
				}):Play()
				UIKit.envoyer("DemandePing", ping.cle, racine.Position)
			end,
		}
	end
	ouvrirRoue("Pings", options)
end

------------------------------------------------------------------------------------------
-- Réparer : InputBegan → DemandeReparation(true), InputEnded → DemandeReparation(false)
------------------------------------------------------------------------------------------

local enReparation = false
local maintien: InputObject? = nil

local function commencerReparation()
	if enReparation or UIKit.estEtourdi(joueur) then
		return
	end
	enReparation = true
	UIKit.envoyer("DemandeReparation", true)
	TweenService:Create(reparer.bouton, RAPIDE, { BackgroundColor3 = UIKit.lumiere(C.ToitOrange) }):Play()
end

local function arreterReparation()
	if not enReparation then
		return
	end
	enReparation = false
	UIKit.envoyer("DemandeReparation", false)
	TweenService:Create(reparer.bouton, RAPIDE, { BackgroundColor3 = C.ToitOrange }):Play()
end

local function estMaintien(entree: InputObject): boolean
	if not maintien then
		return false
	end
	if entree.UserInputType == Enum.UserInputType.Touch then
		return entree == maintien
	end
	return entree.UserInputType == maintien.UserInputType
end

reparer.bouton.InputBegan:Connect(function(entree: InputObject)
	local genre = entree.UserInputType
	if genre == Enum.UserInputType.Touch or genre == Enum.UserInputType.MouseButton1 then
		maintien = entree
		UIKit.rebond(reparer.bouton)
		commencerReparation() -- DemandeReparation(true)
	end
end)

local function finMaintien(entree: InputObject)
	if estMaintien(entree) then
		maintien = nil
		arreterReparation() -- DemandeReparation(false)
	end
end
reparer.bouton.InputEnded:Connect(finMaintien)
-- Filet : un doigt qui glisse hors du bouton se lève ailleurs ; on le rattrape ici.
UserInputService.InputEnded:Connect(finMaintien)

------------------------------------------------------------------------------------------
-- Boutons tactiles et ContextActionService (clavier, manette) : mêmes fonctions
------------------------------------------------------------------------------------------

for _, defense in UIKit.DEFENSES do
	local action = boutonsDefense[defense.cle]
	if action then
		action.bouton.Activated:Connect(function()
			UIKit.rebond(action.bouton)
			UIKit.son("Clic")
			poser(defense.cle)
		end)
	end
end

if actionPoser then
	actionPoser.bouton.Activated:Connect(function()
		UIKit.rebond(actionPoser.bouton)
		UIKit.son("Clic")
		ouvrirDefenses()
	end)
end

actionPing.bouton.Activated:Connect(function()
	UIKit.rebond(actionPing.bouton)
	UIKit.son("Clic")
	ouvrirPings()
end)

local function actionReparer(_, etat: Enum.UserInputState)
	if etat == Enum.UserInputState.Begin then
		UIKit.rebond(reparer.bouton)
		commencerReparation()
	elseif etat == Enum.UserInputState.End or etat == Enum.UserInputState.Cancel then
		arreterReparation()
	end
	return Enum.ContextActionResult.Sink
end

local function actionDefense(_, etat: Enum.UserInputState, entree: InputObject)
	if etat ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local defense = UIKit.DEFENSES[TOUCHES_DEFENSE[entree.KeyCode]]
	if not defense then
		return Enum.ContextActionResult.Pass
	end
	local action = boutonsDefense[defense.cle] or actionPoser
	UIKit.rebond(action.bouton)
	poser(defense.cle)
	return Enum.ContextActionResult.Sink
end

local function actionPings(_, etat: Enum.UserInputState)
	if etat == Enum.UserInputState.Begin then
		UIKit.rebond(actionPing.bouton)
		ouvrirPings()
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ZsurvieReparer", actionReparer, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
ContextActionService:BindAction(
	"ZsurvieDefense",
	actionDefense,
	false,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.KeypadOne,
	Enum.KeyCode.KeypadTwo,
	Enum.KeyCode.KeypadThree,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadRight
)
ContextActionService:BindAction("ZsurviePing", actionPings, false, Enum.KeyCode.Q, Enum.KeyCode.DPadUp)

------------------------------------------------------------------------------------------
-- Désignation d'une cible prioritaire : tap ou clic → BlasterControleur (a26)
------------------------------------------------------------------------------------------

local cibleMarquee: any = nil

local ancreCible = UIKit.creer("Attachment", { Name = "AncreCible", Parent = Workspace.Terrain })
local marqueur = UIKit.creer("BillboardGui", {
	Name = "MarqueurCible",
	Adornee = ancreCible,
	AlwaysOnTop = true,
	Enabled = false,
	LightInfluence = 0,
	ResetOnSpawn = false,
	Size = UDim2.fromOffset(54, 54),
	Parent = playerGui,
})
local viseur = UIKit.creer("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.5),
	Rotation = 45,
	Size = UDim2.fromScale(0.7, 0.7),
	Parent = marqueur,
})
UIKit.creer("UIStroke", { Color = UIKit.lumiere(C.ToitOrange), Thickness = 4, Parent = viseur })
TweenService:Create(viseur, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
	Rotation = 405,
}):Play()

local function designer(ecran: Vector2)
	if not (zbiresRendu and blaster) then
		return
	end
	local trouve, id = pcall(zbiresRendu.chercher, ecran, TOLERANCE_DESIGNATION)
	if not trouve or id == nil then
		return
	end
	pcall(blaster.definirCiblePrioritaire, id)
	cibleMarquee = id
	UIKit.son("Clic")
end

UserInputService.TouchTapInWorld:Connect(function(position: Vector2, traiteParUI: boolean)
	if not traiteParUI then
		designer(position)
	end
end)

UserInputService.InputBegan:Connect(function(entree: InputObject, traite: boolean)
	if not traite and entree.UserInputType == Enum.UserInputType.MouseButton1 then
		designer(Vector2.new(entree.Position.X, entree.Position.Y))
	end
end)

-- Un seul appel par frame à ZbiresRendu.position : le marqueur suit le Zbire lissé par a26.
RunService.RenderStepped:Connect(function()
	if cibleMarquee == nil then
		return
	end
	local trouve, position = pcall(zbiresRendu.position, cibleMarquee)
	if trouve and typeof(position) == "Vector3" then
		ancreCible.WorldPosition = position
		marqueur.Enabled = true
	else
		cibleMarquee = nil
		marqueur.Enabled = false
	end
end)

------------------------------------------------------------------------------------------
-- RÉPARER contextuel (4 Hz) : opaque et pulsé si la Maison est abîmée et à ≤ 14 studs
------------------------------------------------------------------------------------------

local pulsationReparer = TweenService:Create(reparer.contour, PULSATION, { Color = C.Creme, Thickness = 5 })
local pointMaison = UIKit.point("MAISON")
local reparationPossible = false

task.spawn(function()
	while gui.Parent do
		local racine = UIKit.racineLocale()
		local pvMax = tonumber(etatRun:GetAttribute("MaisonPVMax")) or 1
		local abimee = (tonumber(etatRun:GetAttribute("MaisonPV")) or pvMax) < pvMax
		local possible = racine ~= nil
			and pointMaison ~= nil
			and abimee
			and UIKit.distancePlate(racine.Position, pointMaison) <= UIKit.PORTEE_REPARATION
		if possible ~= reparationPossible then
			reparationPossible = possible
			reparer.bouton.BackgroundTransparency = if possible then 0 else 0.4
			if possible then
				pulsationReparer:Play()
			else
				pulsationReparer:Cancel()
				reparer.contour.Color = C.Encre
				reparer.contour.Thickness = 3
			end
		end
		task.wait(0.25)
	end
end)

------------------------------------------------------------------------------------------
-- Crochets a10 : UIKit.pulser("Muret", …) et UIKit.pulser("Ping", …, "PingColosse")
------------------------------------------------------------------------------------------

local function brancherPulsation(nom: string, action)
	local pulsation = TweenService:Create(action.contour, PULSATION, { Color = C.Creme, Thickness = 5 })
	UIKit.surEtat("Pulse" .. nom, function(valeur: any)
		if valeur then
			pulsation:Play()
		else
			pulsation:Cancel()
			action.contour.Color = C.Encre
			action.contour.Thickness = 3
		end
		if action.icone then
			local image = if type(valeur) == "string" then UIKit.icone(valeur) else ""
			action.icone.Image = image
			action.icone.Visible = image ~= ""
			action.label.Visible = image == ""
		end
	end)
end
brancherPulsation("Muret", boutonsDefense.Muret or actionPoser)
brancherPulsation("Ping", actionPing)

-- Établi ouvert : l'arc se masque, RÉPARER reste.
UIKit.surEtat("EtabliOuvert", function(ouvert: any)
	for _, bouton in secondaires do
		bouton.Visible = not ouvert
	end
	if ouvert then
		fermerRoue()
	end
end)

------------------------------------------------------------------------------------------
-- Pas de saut sur la Prairie : couper l'état Jumping retire aussi le bouton de saut tactile
------------------------------------------------------------------------------------------

local function sansSaut(personnage: Model)
	local humanoide = personnage:WaitForChild("Humanoid", 10)
	if not (humanoide and humanoide:IsA("Humanoid")) then
		warn("[a28 Controles] Humanoid du Survivant introuvable après 10 s")
		return
	end
	humanoide.UseJumpPower = false
	humanoide.JumpHeight = 0
	humanoide:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end
if joueur.Character then
	task.spawn(sansSaut, joueur.Character)
end
joueur.CharacterAdded:Connect(sansSaut)

------------------------------------------------------------------------------------------
-- Réception serveur : refus et étourdissement
------------------------------------------------------------------------------------------

UIKit.ecouter("Annonce", function(cle: string, donnees: any)
	if cle == "Refus" and type(donnees) == "table" then
		refuser(tostring(donnees.raison))
	end
end)

joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
	if UIKit.estEtourdi(joueur) then
		maintien = nil
		arreterReparation()
		fermerRoue()
	end
end)

joueur.CharacterRemoving:Connect(function()
	maintien = nil
	arreterReparation()
end)
```

### a28/Effets.client.lua
```lua
-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Effets (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Retours visuels dans le monde : nombres de dégâts (flux Evenements),
-- pièces individuelles au sol (PiecesLachees + expireA), étoiles d'étourdissement, bulles de ping.
-- L'éclatement des Zbires est le Z1 de a37 : plus de remote Impact ni Eclatement, plus de cubes ici.
-- Tout est cosmétique : ramassage et crédit des pièces sont décidés par le serveur (a14), qui écrit
-- l'attribut Pieces puis envoie Butin(id, montant) pour l'animation.
-- Pools fixes, aucune création d'instance pendant le combat, zéro Neon, zéro lumière.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Effets] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local terrain = Workspace.Terrain
task.spawn(UIKit.reglages) -- EffetsReduits est ensuite lu sans attente

local CACHE = CFrame.new(0, -500, 0)
local TAILLE_PIECE = Vector3.new(1, 1, 0.25)
local CLIGNOTEMENT = 3 -- s avant expireA
local NB_NOMBRES, NB_PIECES, NB_PINGS = 20, 60, 6
local pointMaison = UIKit.point("MAISON")

local INFO_NOMBRE = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_POP = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local INFO_ASPIRE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local INFO_ENVOL = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local dossier = UIKit.creer("Folder", { Name = "EffetsZsurvie", Parent = Workspace.CurrentCamera })

local function creerBloc(nom: string, couleur: Color3, taille: Vector3): BasePart
	return UIKit.creer("Part", {
		Name = nom,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		CFrame = CACHE,
		Color = couleur,
		Material = Enum.Material.SmoothPlastic,
		Size = taille,
		Transparency = 1,
		Parent = dossier,
	})
end

------------------------------------------------------------------------------------------
-- Nombres flottants (dégâts, gains) : pool de 20 BillboardGui
------------------------------------------------------------------------------------------

local nombres = {}
local indexNombre = 0
for i = 1, NB_NOMBRES do
	local ancre = UIKit.creer("Attachment", { Name = "AncreNombre", Parent = terrain })
	local affichage = UIKit.creer("BillboardGui", {
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		Size = UDim2.fromOffset(80, 40),
		Parent = ancre,
	})
	local label = UIKit.etiquette(affichage, "", UDim2.fromScale(1, 1), 30)
	nombres[i] = {
		ancre = ancre,
		affichage = affichage,
		label = label,
		contour = label:FindFirstChildOfClass("UIStroke"),
	}
end

local function afficherNombre(position: Vector3, texte: string, couleur: Color3, gros: boolean)
	indexNombre = indexNombre % NB_NOMBRES + 1
	local n = nombres[indexNombre]
	n.ancre.WorldPosition = position + Vector3.new(math.random() - 0.5, 2, math.random() - 0.5)
	n.affichage.StudsOffset = Vector3.zero
	n.affichage.Size = if gros then UDim2.fromOffset(110, 52) else UDim2.fromOffset(80, 40)
	n.label.Text = texte
	n.label.TextColor3 = couleur
	n.label.TextTransparency = 0
	n.contour.Transparency = 0
	n.affichage.Enabled = true
	TweenService:Create(n.affichage, INFO_NOMBRE, { StudsOffset = Vector3.new(0, 3, 0) }):Play()
	TweenService:Create(n.label, INFO_NOMBRE, { TextTransparency = 1 }):Play()
	TweenService:Create(n.contour, INFO_NOMBRE, { Transparency = 1 }):Play()
end

-- Flux Evenements (UnreliableRemoteEvent, lots par tick serveur) : on ne lit que type = "Degats".
-- { type, position, valeur, critique, auteur (UserId), reduit (coup non critique sur un Casqué) }
local function afficherDegats(e)
	if typeof(e.position) ~= "Vector3" or type(e.valeur) ~= "number" then
		return
	end
	local deMoi = e.auteur == joueur.UserId
	if not deMoi and (e.critique ~= true or UIKit.reglage("EffetsReduits") == true) then
		return -- coéquipiers : seuls leurs critiques s'affichent, la horde reste lisible
	end
	local valeur = tostring(math.max(1, math.floor(e.valeur)))
	if e.critique == true then
		afficherNombre(e.position, valeur .. " !", C.ToitOrange, true)
	elseif e.reduit == true then
		afficherNombre(e.position, valeur, UIKit.lumiere(C.Ardoise), false)
		UIKit.son("Tink", 0.15) -- enseigne la règle du Casqué
	else
		afficherNombre(e.position, valeur, C.Creme, false)
	end
end

UIKit.ecouter("Evenements", function(lot: any)
	if type(lot) ~= "table" then
		return
	end
	for _, evenement in lot do
		if type(evenement) == "table" and evenement.type == "Degats" then
			afficherDegats(evenement)
		end
	end
end)

------------------------------------------------------------------------------------------
-- Pièces au sol : butin individuel, retiré à l'heure expireA fixée par le serveur
------------------------------------------------------------------------------------------

local libres = {}
for i = 1, NB_PIECES do
	libres[i] = creerBloc("Piece", C.Or, TAILLE_PIECE)
end
local pieces = {} -- [id] = { part, base, expireA, phase, etat = "Sol" | "Partie" }
local partsAnimees, cframesAnimees = {}, {}

local function liberer(id: any)
	local piece = pieces[id]
	if not piece then
		return
	end
	pieces[id] = nil
	piece.part.Transparency = 1
	piece.part.CFrame = CACHE
	table.insert(libres, piece.part)
end

-- La pièce quitte le sol : vers le Survivant (Butin) ou vers la Maison (expireA atteint).
local function partir(id: any, piece, cible: Vector3?, info: TweenInfo)
	piece.etat = "Partie"
	piece.part.Transparency = 0
	if not cible then
		liberer(id)
		return
	end
	local tween = TweenService:Create(piece.part, info, { CFrame = CFrame.new(cible), Size = TAILLE_PIECE * 0.3 })
	tween.Completed:Once(function()
		liberer(id)
	end)
	tween:Play()
end

-- PiecesLachees({ { id, position, montant, expireA }, ... }) : envoyé au seul propriétaire.
-- expireA = heure Workspace:GetServerTimeNow() à laquelle le serveur (a14) retire la pièce.
UIKit.ecouter("PiecesLachees", function(liste: any)
	if type(liste) ~= "table" then
		return
	end
	for _, d in liste do
		if
			type(d) == "table"
			and d.id ~= nil
			and typeof(d.position) == "Vector3"
			and type(d.expireA) == "number"
			and not pieces[d.id]
		then
			local part = table.remove(libres)
			if not part then
				break -- pool plein : la pièce existe côté serveur, elle n'est simplement pas dessinée
			end
			part.Transparency = 0
			part.Size = TAILLE_PIECE * 0.2
			part.CFrame = CFrame.new(d.position)
			TweenService:Create(part, INFO_POP, { Size = TAILLE_PIECE }):Play()
			pieces[d.id] = {
				part = part,
				base = d.position + Vector3.new(0, 1, 0),
				expireA = d.expireA,
				phase = math.random() * math.pi * 2,
				etat = "Sol",
			}
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	local serveur = Workspace:GetServerTimeNow()
	local reduits = UIKit.reglage("EffetsReduits") == true
	local eteinte = math.floor(t * 5) % 2 == 1 -- 2,5 clignotements par seconde (sous 3 flashs/s)
	table.clear(partsAnimees)
	table.clear(cframesAnimees)
	for id, piece in pieces do
		if piece.etat == "Sol" then
			if serveur >= piece.expireA then
				-- Heure fixée par le serveur : la pièce file vers la Maison (50 % rendus au Répit).
				partir(id, piece, if pointMaison then pointMaison + Vector3.new(0, 8, 0) else nil, INFO_ENVOL)
			else
				local transparence = if serveur >= piece.expireA - CLIGNOTEMENT and eteinte then 0.7 else 0
				if piece.part.Transparency ~= transparence then
					piece.part.Transparency = transparence
				end
				local hauteur = if reduits then 0 else 0.3 * math.sin(t * 4 + piece.phase)
				local rotation = if reduits then piece.phase else t * 3 + piece.phase
				table.insert(partsAnimees, piece.part)
				table.insert(
					cframesAnimees,
					CFrame.new(piece.base + Vector3.new(0, hauteur, 0)) * CFrame.Angles(0, rotation, 0)
				)
			end
		end
	end
	if #partsAnimees > 0 then
		Workspace:BulkMoveTo(partsAnimees, cframesAnimees, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

-- Butin(id, montant) : envoyé APRÈS que le serveur a crédité l'attribut Pieces.
UIKit.ecouter("Butin", function(id: any, montant: any)
	local racine = UIKit.racineLocale()
	local piece = pieces[id]
	if piece and piece.etat == "Sol" then
		partir(id, piece, if racine then racine.Position else nil, INFO_ASPIRE)
	end
	UIKit.son("Piece", 0.06)
	if racine and type(montant) == "number" and montant > 0 then
		afficherNombre(racine.Position, "+" .. math.floor(montant), C.Or, false)
	end
end)

------------------------------------------------------------------------------------------
-- Étoiles d'étourdissement (visibles par tous : on voit qui aider)
------------------------------------------------------------------------------------------

local etoiles = {} -- [Player] = { panneau, tournoiements, jeton }

local function creerEtoiles(tete: BasePart)
	local panneau = UIKit.creer("BillboardGui", {
		Name = "EtoilesEtourdi",
		Enabled = false,
		LightInfluence = 0,
		Size = UDim2.fromScale(3, 1.2),
		StudsOffset = Vector3.new(0, 1.8, 0),
		Parent = tete,
	})
	local tournoiements = {}
	for i = 1, 3 do
		local hauteur = if i == 2 then 0.3 else 0.65
		local etoile = UIKit.creer("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = C.Creme,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.2 + 0.3 * (i - 1), hauteur),
			Rotation = 45,
			Size = UDim2.fromScale(0.13, 0.33),
			Parent = panneau,
		})
		UIKit.creer("UIStroke", { Color = C.Encre, Thickness = 2, Parent = etoile })
		tournoiements[i] = TweenService:Create(
			etoile,
			TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
			{ Rotation = 405 }
		)
	end
	return { panneau = panneau, tournoiements = tournoiements, jeton = 0 }
end

local function montrerEtoiles(autre: Player)
	local reste = (tonumber(autre:GetAttribute("EtourdiJusqua")) or 0) - Workspace:GetServerTimeNow()
	local personnage = autre.Character
	local tete = personnage and personnage:FindFirstChild("Head")
	if reste <= 0 or not (tete and tete:IsA("BasePart")) then
		return
	end
	local etat = etoiles[autre]
	if not etat or etat.panneau.Parent ~= tete then
		if etat then
			etat.panneau:Destroy()
		end
		etat = creerEtoiles(tete)
		etoiles[autre] = etat
	end
	etat.jeton += 1
	local jeton = etat.jeton
	etat.panneau.Enabled = true
	for _, tween in etat.tournoiements do
		tween:Play()
	end
	task.delay(math.min(reste, 4), function()
		if etat.jeton ~= jeton then
			return
		end
		etat.panneau.Enabled = false
		for _, tween in etat.tournoiements do
			tween:Cancel()
		end
	end)
end

local function surveiller(autre: Player)
	autre:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
		montrerEtoiles(autre)
	end)
end

for _, autre in Players:GetPlayers() do
	surveiller(autre)
end
Players.PlayerAdded:Connect(surveiller)
Players.PlayerRemoving:Connect(function(autre: Player)
	local etat = etoiles[autre]
	if etat then
		etat.panneau:Destroy()
		etoiles[autre] = nil
	end
end)

------------------------------------------------------------------------------------------
-- Bulles de la Roue des Pings : « Léa : Répare ! » pendant 4 s
------------------------------------------------------------------------------------------

local bulles = {}
local indexBulle = 0
for i = 1, NB_PINGS do
	local ancre = UIKit.creer("Attachment", { Name = "AncrePing", Parent = terrain })
	local affichage = UIKit.creer("BillboardGui", {
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		Size = UDim2.fromOffset(170, 48),
		StudsOffset = Vector3.new(0, 5, 0),
		Parent = ancre,
	})
	local cadre = UIKit.creer("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.Prairie,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Parent = affichage,
	})
	UIKit.habiller(cadre, 8, 3)
	local label = UIKit.etiquette(cadre, "", UDim2.new(1, -12, 1, -8), 24)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	bulles[i] = { ancre = ancre, affichage = affichage, cadre = cadre, label = label, jeton = 0 }
end

-- PingDiffuse(auteur, cle, position) : le serveur a déjà vérifié la clé et la cadence.
UIKit.ecouter("PingDiffuse", function(auteur: any, cle: any, position: any)
	local info = UIKit.PINGS_PAR_CLE[cle]
	if not info or typeof(position) ~= "Vector3" then
		return
	end
	indexBulle = indexBulle % NB_PINGS + 1
	local bulle = bulles[indexBulle]
	local nom = if typeof(auteur) == "Instance" and auteur:IsA("Player") then auteur.DisplayName else "Survivant"
	bulle.ancre.WorldPosition = position
	bulle.cadre.BackgroundColor3 = info.couleur
	bulle.label.Text = nom .. " : " .. info.texte
	bulle.affichage.Enabled = true
	UIKit.rebond(bulle.cadre)
	UIKit.son(if cle == "Colosse" then "Alerte" else "Ping")
	bulle.jeton += 1
	local jeton = bulle.jeton
	task.delay(4, function()
		if bulle.jeton == jeton then
			bulle.affichage.Enabled = false
		end
	end)
end)
```

### a28/Etabli.client.lua
```lua
-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Etabli (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · L'Établi : 8 améliorations valables jusqu'à la fin de la run.
-- Bouton contextuel de 72 px à 10 studs au plus de Plan.ETABLI ; ouverture automatique seulement
-- pendant le Répit ; taps ignorés 0,8 s après l'ouverture ; panneau latéral droit de 55 % qui laisse
-- RÉPARER visible ; carte cagnotte d'équipe (jauge, têtes des contributeurs).
-- Prix lus dans ReplicatedStorage.Catalogue ; niveaux dans Niv<Cle> (Player, ou EtatRun pour les
-- améliorations d'équipe). Le client envoie DemandeAchat(cle, niveauVise) et reste en Attente
-- jusqu'à ProfilMaj ou Annonce. Solde, plafond et part versée à la cagnotte sont décidés par le serveur.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Etabli] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
local etatRun = UIKit.etatRun()
if not (playerGui and etatRun) then
	return
end
local pointEtabli = UIKit.point("ETABLI")
if not pointEtabli then
	warn("[a28 Etabli] Plan.ETABLI absent : pas de bouton contextuel")
end
local blasterStats = UIKit.module("BlasterStats")
UIKit.remote("DemandeAchat") -- résolution anticipée

local RAYON = 10 -- studs : le bouton apparaît à 10 studs au plus de Plan.ETABLI
local RAYON_SORTIE = 12 -- studs : hystérésis, le bouton ne clignote pas en bord de zone
local DELAI_TAPS = 0.8 -- s : taps ignorés juste après l'ouverture
local ATTENTE_MAX = 4 -- s : filet si ni ProfilMaj ni Annonce n'arrive
local RAPIDE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_TREMBLE = TweenInfo.new(0.04, Enum.EasingStyle.Linear)

-- Noms officiels du canon §6 ; equipe = profite à toute l'équipe, financée par la cagnotte.
local AMELIORATIONS = {
	{ cle = "Degats", nom = "Dégâts", aide = "Tirs plus forts" },
	{ cle = "Cadence", nom = "Cadence", aide = "Tirs plus rapides" },
	{ cle = "Portee", nom = "Portée", aide = "Vise plus loin" },
	{ cle = "Solidite", nom = "Solidité", aide = "Maison plus solide", equipe = true },
	{ cle = "Reparation", nom = "Réparation", aide = "Répare plus vite", equipe = true },
	{ cle = "Regeneration", nom = "Régénération", aide = "La Maison se soigne", equipe = true },
	{ cle = "Butin", nom = "Butin", aide = "Plus de pièces" },
	{ cle = "BallesExplosives", nom = "Balles explosives", aide = "Les tirs explosent" },
}

local cartes = {} -- [cle] = carte
local dansZone = false
local ouvertA = 0

------------------------------------------------------------------------------------------
-- Construction : bouton contextuel 72 px et panneau latéral droit (55 % de large)
------------------------------------------------------------------------------------------

local gui = UIKit.creer("ScreenGui", {
	Name = "EtabliZsurvie",
	DisplayOrder = 2, -- sous les contrôles (3) : RÉPARER passe toujours devant
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local boutonEtabli = UIKit.bouton(gui, "ÉTABLI", UDim2.fromOffset(72, 72), C.TerreBattue, 20)
boutonEtabli.Name = "BoutonEtabli"
boutonEtabli.AnchorPoint = Vector2.new(1, 1)
boutonEtabli.Visible = false
UIKit.echelle(boutonEtabli)
if UserInputService.KeyboardEnabled then
	local indice = UIKit.etiquette(boutonEtabli, "F", UDim2.fromOffset(22, 22), 16)
	indice.Position = UDim2.fromOffset(-6, -6)
	indice.BackgroundColor3 = C.Encre
	indice.BackgroundTransparency = 0
end

local panneau = UIKit.creer("Frame", {
	Name = "Panneau",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.05,
	Position = UDim2.new(1, -8, 0, 8),
	Visible = false,
	Parent = gui,
})
UIKit.habiller(panneau, 8, 4)

-- Le bouton se cale à 12 px à gauche de la grappe (12 + 230 px × échelle) ; le panneau s'arrête
-- 24 px au-dessus de RÉPARER (12 + 96 px × échelle depuis le bas).
UIKit.surEchelle(function(f: number)
	boutonEtabli.Position = UDim2.new(1, -(24 + 230 * f), 1, -12)
	panneau.Size = UDim2.new(0.55, 0, 1, -(8 + 12 + 96 * f + 24))
end)

local titre = UIKit.etiquette(panneau, "L'ÉTABLI", UDim2.new(0.4, 0, 0, 36), 30)
titre.Position = UDim2.fromOffset(12, 12)
titre.TextXAlignment = Enum.TextXAlignment.Left
titre.TextColor3 = C.ToitOrange

local solde = UIKit.etiquette(panneau, "0 pièces", UDim2.new(0.34, 0, 0, 30), 24)
solde.AnchorPoint = Vector2.new(0.5, 0)
solde.Position = UDim2.new(0.58, 0, 0, 15)
solde.TextColor3 = C.Or

local boutonFermer = UIKit.bouton(panneau, "X", UDim2.fromOffset(60, 60), C.Alerte, 30)
boutonFermer.AnchorPoint = Vector2.new(1, 0)
boutonFermer.Position = UDim2.new(1, -4, 0, 4)

------------------------------------------------------------------------------------------
-- Carte cagnotte (colonne gauche, 36 %) : EtatRun.CagnotteCle / Montant / Objectif / Contributeurs
------------------------------------------------------------------------------------------

local cagnotte = UIKit.creer("Frame", {
	Name = "Cagnotte",
	BackgroundColor3 = C.NuitLabo,
	Position = UDim2.fromOffset(8, 68),
	Size = UDim2.new(0.36, -12, 1, -76),
	Parent = panneau,
})
UIKit.habiller(cagnotte, 6, 3)

local titreCagnotte = UIKit.etiquette(cagnotte, "CAGNOTTE ÉQUIPE", UDim2.new(1, -12, 0, 20), 16)
titreCagnotte.Position = UDim2.fromOffset(6, 6)
titreCagnotte.TextColor3 = C.Prairie

local nomCagnotte = UIKit.etiquette(cagnotte, "", UDim2.new(1, -12, 0, 36), 16)
nomCagnotte.Position = UDim2.fromOffset(6, 28)

local fondJauge = UIKit.creer("Frame", {
	BackgroundColor3 = UIKit.ombre(C.Ardoise),
	ClipsDescendants = true,
	Position = UDim2.fromOffset(6, 70),
	Size = UDim2.new(1, -12, 0, 18),
	Parent = cagnotte,
})
UIKit.habiller(fondJauge, 0, 2)
local remplissage = UIKit.creer("Frame", {
	BackgroundColor3 = C.Or,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(0, 1),
	Parent = fondJauge,
})
local texteJauge = UIKit.etiquette(fondJauge, "", UDim2.fromScale(1, 1), 14)

local rangTetes = UIKit.creer("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(6, 94),
	Size = UDim2.new(1, -12, 0, 20),
	Parent = cagnotte,
})
UIKit.creer("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 2),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = rangTetes,
})
local tetesCagnotte = {}
for i = 1, 6 do
	local image = UIKit.creer("ImageLabel", {
		BackgroundColor3 = C.Encre,
		LayoutOrder = i,
		Size = UDim2.fromOffset(20, 20),
		Visible = false,
		Parent = rangTetes,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 4), Parent = image })
	UIKit.creer("UIStroke", { Color = C.Creme, Thickness = 1, Parent = image })
	tetesCagnotte[i] = image
end

------------------------------------------------------------------------------------------
-- Cartes (colonne droite, défilante) : 2 colonnes, 64 px de haut
------------------------------------------------------------------------------------------

local liste = UIKit.creer("ScrollingFrame", {
	Name = "Cartes",
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	Position = UDim2.new(0.36, 4, 0, 68),
	ScrollBarImageColor3 = C.Creme,
	ScrollBarThickness = 6,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Size = UDim2.new(0.64, -12, 1, -76),
	Parent = panneau,
})
UIKit.creer("UIGridLayout", {
	CellPadding = UDim2.fromOffset(6, 6),
	CellSize = UDim2.new(0.5, -9, 0, 64),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = liste,
})

local function soldePieces(): number
	return tonumber(joueur:GetAttribute("Pieces")) or 0
end

local function niveau(carte): number
	local source = if carte.equipe then etatRun else joueur
	return math.floor(tonumber(source:GetAttribute("Niv" .. carte.cle)) or 0)
end

-- Aperçu chiffré pour Portée et Cadence, lu dans BlasterStats (a26) : « 40 → 44 studs ».
local function apercu(carte, niv: number): string
	local fonction = if type(blasterStats) ~= "table" then nil
		elseif carte.cle == "Portee" then blasterStats.portee
		elseif carte.cle == "Cadence" then blasterStats.cadence
		else nil
	if type(fonction) ~= "function" then
		return carte.aide
	end
	local okA, actuel = pcall(fonction, niv)
	local okB, suivant = pcall(fonction, niv + 1)
	if not (okA and okB and type(actuel) == "number" and type(suivant) == "number") then
		return carte.aide
	end
	local unite = if carte.cle == "Portee" then "studs" else "tirs/s"
	return (string.format("%g → %g %s", actuel, suivant, unite):gsub("%.", ","))
end

local function trembler(carte)
	task.spawn(function()
		for _, angle in { -6, 6, -3, 0 } do
			local tween = TweenService:Create(carte.bouton, INFO_TREMBLE, { Rotation = angle })
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

local function mettreEnAttente(carte, actif: boolean)
	carte.attente = actif
	carte.voileAttente.Visible = actif
	carte.jeton += 1
	if actif then
		local jeton = carte.jeton
		task.delay(ATTENTE_MAX, function()
			if carte.jeton == jeton and carte.attente then
				mettreEnAttente(carte, false) -- filet : réponse perdue
			end
		end)
	end
end

local function majCarte(carte)
	local niv = niveau(carte)
	local prix = UIKit.prix(carte.cle, niv + 1)
	local pieces = soldePieces()
	local possible = prix ~= nil and (if carte.equipe then pieces > 0 else pieces >= prix)
	carte.texteNiveau.Text = if prix then `Niv. {niv} → {niv + 1}` else `Niv. {niv}`
	carte.prix.Text = if prix then UIKit.formater(prix) else "MAX"
	carte.prix.TextColor3 = if not prix then C.Creme elseif possible then C.Or else C.Alerte
	carte.piece.Visible = prix ~= nil
	carte.aideLabel.Text = apercu(carte, niv)
	carte.bouton.BackgroundColor3 = if possible then C.Ardoise else UIKit.ombre(C.Ardoise)
	if panneau.Visible and carte.niv ~= nil and niv > carte.niv then
		UIKit.rebond(carte.bouton)
		UIKit.son("Achat")
	end
	carte.niv = niv
end

local function majCagnotte()
	local cle = etatRun:GetAttribute("CagnotteCle")
	local carte = if type(cle) == "string" then cartes[cle] else nil
	if not (carte and carte.equipe) then
		nomCagnotte.Text = "Touche une carte ÉQUIPE pour la lancer !"
		remplissage.Size = UDim2.fromScale(0, 1)
		texteJauge.Text = ""
		for _, image in tetesCagnotte do
			image.Visible = false
		end
		return
	end
	local montant = math.max(0, tonumber(etatRun:GetAttribute("CagnotteMontant")) or 0)
	local objectif = math.max(1, tonumber(etatRun:GetAttribute("CagnotteObjectif")) or 1)
	nomCagnotte.Text = `{carte.nom} · Niv. {niveau(carte) + 1}`
	TweenService:Create(remplissage, RAPIDE, { Size = UDim2.fromScale(math.clamp(montant / objectif, 0, 1), 1) }):Play()
	texteJauge.Text = `{UIKit.formater(montant)} / {UIKit.formater(objectif)}`
	local index = 0
	for id in string.gmatch(tostring(etatRun:GetAttribute("CagnotteContributeurs") or ""), "%d+") do
		index += 1
		if index > #tetesCagnotte then
			break
		end
		tetesCagnotte[index].Visible = true
		UIKit.tete(tetesCagnotte[index], tonumber(id) :: number)
	end
	for i = index + 1, #tetesCagnotte do
		tetesCagnotte[i].Visible = false
	end
end

local function rafraichir()
	solde.Text = UIKit.formater(soldePieces()) .. " pièces"
	for _, carte in cartes do
		majCarte(carte)
	end
	majCagnotte()
end

local function acheter(carte)
	if os.clock() - ouvertA < DELAI_TAPS or carte.attente then
		return
	end
	local vise = niveau(carte) + 1
	local prix = UIKit.prix(carte.cle, vise)
	local pieces = soldePieces()
	if not prix or (if carte.equipe then pieces <= 0 else pieces < prix) then
		trembler(carte)
		UIKit.son("Refus")
		return
	end
	UIKit.son("Clic")
	mettreEnAttente(carte, true)
	UIKit.envoyer("DemandeAchat", carte.cle, vise)
end

for ordre, amelioration in AMELIORATIONS do
	local cellule = UIKit.creer("Frame", {
		Name = amelioration.cle,
		BackgroundTransparency = 1,
		LayoutOrder = ordre,
		Parent = liste,
	})
	-- Le bouton est dans une cellule : UIGridLayout impose la taille de la cellule, pas du bouton,
	-- ce qui laisse le rebond du canon fonctionner.
	local bouton = UIKit.creer("TextButton", {
		Name = "Carte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = C.Ardoise,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = cellule,
	})
	UIKit.habiller(bouton, 6, 3)

	local nom = UIKit.etiquette(bouton, amelioration.nom, UDim2.new(1, -12, 0, 20), 18)
	nom.Position = UDim2.fromOffset(6, 3)
	nom.TextXAlignment = Enum.TextXAlignment.Left

	local aide = UIKit.etiquette(bouton, amelioration.aide, UDim2.new(1, -12, 0, 16), 13)
	aide.Position = UDim2.fromOffset(6, 23)
	aide.TextXAlignment = Enum.TextXAlignment.Left

	local texteNiveau = UIKit.etiquette(bouton, "Niv. 0", UDim2.new(0.5, -6, 0, 18), 15)
	texteNiveau.Position = UDim2.new(0, 6, 1, -21)
	texteNiveau.TextXAlignment = Enum.TextXAlignment.Left

	local piece = UIKit.creer("Frame", {
		Name = "Piece",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = C.Or,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -8, 1, -12),
		Size = UDim2.fromOffset(12, 12),
		Parent = bouton,
	})
	UIKit.creer("UIStroke", { Color = UIKit.ombre(C.Or), Thickness = 2, Parent = piece })

	local prix = UIKit.etiquette(bouton, "-", UDim2.new(0.5, -28, 0, 18), 16)
	prix.AnchorPoint = Vector2.new(1, 0)
	prix.Position = UDim2.new(1, -24, 1, -21)
	prix.TextXAlignment = Enum.TextXAlignment.Right

	if amelioration.equipe then
		local badge = UIKit.creer("Frame", {
			Name = "Equipe",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = C.Prairie,
			Position = UDim2.new(1, -4, 0, -6),
			Size = UDim2.fromOffset(50, 16),
			ZIndex = 2,
			Parent = bouton,
		})
		UIKit.habiller(badge, 4, 2)
		UIKit.etiquette(badge, "ÉQUIPE", UDim2.fromScale(1, 1), 12).ZIndex = 2
	end

	local voileAttente = UIKit.creer("Frame", {
		Name = "Attente",
		BackgroundColor3 = C.Encre,
		BackgroundTransparency = 0.35,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 3,
		Parent = bouton,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 6), Parent = voileAttente })
	UIKit.etiquette(voileAttente, "…", UDim2.fromScale(1, 1), 30).ZIndex = 3

	local carte = {
		cle = amelioration.cle,
		nom = amelioration.nom,
		aide = amelioration.aide,
		equipe = amelioration.equipe == true,
		bouton = bouton,
		aideLabel = aide,
		texteNiveau = texteNiveau,
		prix = prix,
		piece = piece,
		voileAttente = voileAttente,
		attente = false,
		jeton = 0,
		niv = nil,
	}
	cartes[amelioration.cle] = carte
	bouton.Activated:Connect(function()
		acheter(carte)
	end)
end

------------------------------------------------------------------------------------------
-- Ouverture / fermeture
------------------------------------------------------------------------------------------

local function ouvrir()
	if panneau.Visible then
		return
	end
	ouvertA = os.clock()
	rafraichir()
	panneau.Visible = true
	boutonEtabli.Visible = false
	panneau.Position = UDim2.new(1, 40, 0, 8)
	TweenService:Create(panneau, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -8, 0, 8),
	}):Play()
	UIKit.son("Clic")
	UIKit.definirEtat("EtabliOuvert", true)
end

local function fermer()
	if not panneau.Visible then
		return
	end
	panneau.Visible = false
	boutonEtabli.Visible = dansZone
	UIKit.definirEtat("EtabliOuvert", false)
end

boutonEtabli.Activated:Connect(function()
	UIKit.rebond(boutonEtabli)
	ouvrir()
end)

boutonFermer.Activated:Connect(function()
	if os.clock() - ouvertA < DELAI_TAPS then
		return
	end
	UIKit.son("Clic")
	fermer()
end)

ContextActionService:BindAction("ZsurvieEtabli", function(_, etat: Enum.UserInputState)
	if etat ~= Enum.UserInputState.Begin or not dansZone then
		return Enum.ContextActionResult.Pass
	end
	if panneau.Visible then
		fermer()
	else
		ouvrir()
	end
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.F, Enum.KeyCode.ButtonY)

-- Zone de l'Établi (4 Hz) : bouton à ≤ 10 studs, ouverture automatique à l'entrée pendant le Répit,
-- fermeture au-delà de 12 studs. Le panneau n'est pas modal : on continue de bouger.
task.spawn(function()
	while gui.Parent do
		local racine = UIKit.racineLocale()
		local distance = if racine and pointEtabli then UIKit.distancePlate(racine.Position, pointEtabli) else math.huge
		local proche = distance <= (if dansZone then RAYON_SORTIE else RAYON)
		if proche ~= dansZone then
			dansZone = proche
			boutonEtabli.Visible = proche and not panneau.Visible
			if proche and etatRun:GetAttribute("Phase") == "Repit" then
				ouvrir()
			elseif not proche then
				fermer()
			end
		end
		task.wait(0.25)
	end
end)

------------------------------------------------------------------------------------------
-- Réception serveur
------------------------------------------------------------------------------------------

joueur.AttributeChanged:Connect(function(nomAttribut: string)
	if nomAttribut == "Pieces" then
		if panneau.Visible then
			rafraichir()
		end
		return
	end
	local cle = string.match(nomAttribut, "^Niv(.+)$")
	local carte = if cle then cartes[cle] else nil
	if carte and not carte.equipe then
		majCarte(carte)
	end
end)

etatRun.AttributeChanged:Connect(function(nomAttribut: string)
	if string.sub(nomAttribut, 1, 8) == "Cagnotte" then
		if panneau.Visible then
			majCagnotte()
		end
		return
	end
	local cle = string.match(nomAttribut, "^Niv(.+)$")
	local carte = if cle then cartes[cle] else nil
	if carte and carte.equipe then
		majCarte(carte)
	end
end)

-- ProfilMaj : le serveur a appliqué (ou refusé) l'achat ; toutes les cartes sortent de l'Attente.
UIKit.ecouter("ProfilMaj", function()
	for _, carte in cartes do
		if carte.attente then
			mettreEnAttente(carte, false)
		end
	end
	if panneau.Visible then
		rafraichir()
	end
end)

UIKit.ecouter("Annonce", function(cle: string, donnees: any)
	local d = if type(donnees) == "table" then donnees else {}
	local carte = if type(d.cle) == "string" then cartes[d.cle] else nil
	if not carte then
		return
	end
	if carte.attente then
		mettreEnAttente(carte, false)
	end
	if cle == "Refus" then
		trembler(carte)
	end
end)

rafraichir()
```

### a28/Hud.client.lua
```lua
-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Hud (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Maquette HUD unique (gabarit 800 × 360, CoreUISafeInsets).
-- Haut gauche : Pièces (Gemmes au Laboratoire) et « +X » gris rendu par la Maison au Répit.
-- Haut centre : bandeau Maison de a32 (Jour, minuteur depuis EtatRun.FinPhase, PV, Colosse).
-- Haut droite : têtes des Survivants. Centre : bannières. Plein écran : voile d'étourdissement.
-- Lecture seule : chaque valeur vient d'un attribut ou d'un RemoteEvent écrit par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Hud] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
local C = UIKit.Couleurs

local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
if not playerGui then
	return
end
local surPrairie = UIKit.surLaPrairie()

local RAPIDE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ROULEMENT = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TRAINEE = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local gui = UIKit.creer("ScreenGui", {
	Name = "HudZsurvie",
	DisplayOrder = 1,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local function suivre(instance: Instance, attribut: string, rappel: (any) -> ())
	instance:GetAttributeChangedSignal(attribut):Connect(function()
		rappel(instance:GetAttribute(attribut))
	end)
	rappel(instance:GetAttribute(attribut))
end

local function entier(valeur: any): number
	return math.floor(tonumber(valeur) or 0)
end

------------------------------------------------------------------------------------------
-- Haut gauche (8, 8), 140 × 44 px : Pièces (Or, carré) sur la Prairie, Gemmes (cyan, losange) au Labo
------------------------------------------------------------------------------------------

local attributCompteur = if surPrairie then "Pieces" else "Gemmes"
local couleurCompteur = if surPrairie then C.Or else C.GemmeCyan

local compteur = UIKit.creer("Frame", {
	Name = attributCompteur,
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.15,
	Position = UDim2.fromOffset(8, 8),
	Size = UDim2.fromOffset(140, 44),
	Parent = gui,
})
UIKit.habiller(compteur, 6, 3)
UIKit.echelle(compteur)

local icone = UIKit.creer("Frame", {
	Name = "Icone",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = couleurCompteur,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(22, 22),
	Rotation = if surPrairie then 0 else 45,
	Size = UDim2.fromOffset(20, 20),
	Parent = compteur,
})
UIKit.creer("UIStroke", { Color = UIKit.ombre(couleurCompteur), Thickness = 3, Parent = icone })

local texteCompteur = UIKit.etiquette(compteur, "0", UDim2.new(1, -50, 1, -8), 30)
texteCompteur.Position = UDim2.fromOffset(44, 4)
texteCompteur.TextXAlignment = Enum.TextXAlignment.Left
texteCompteur.TextColor3 = couleurCompteur

local valeurAffichee = UIKit.creer("NumberValue", { Name = "Affiche", Parent = compteur })
valeurAffichee.Changed:Connect(function(v: number)
	texteCompteur.Text = UIKit.formater(v)
end)

local cibleCompteur: number? = nil
suivre(joueur, attributCompteur, function(brut)
	local nouvelle = math.max(0, entier(brut))
	local ancienne = cibleCompteur
	cibleCompteur = nouvelle
	if ancienne == nil then
		valeurAffichee.Value = nouvelle
		texteCompteur.Text = UIKit.formater(nouvelle)
		return
	end
	TweenService:Create(valeurAffichee, ROULEMENT, { Value = nouvelle }):Play()
	if nouvelle > ancienne then
		UIKit.rebond(icone)
	end
end)

if not surPrairie then
	return -- Laboratoire : le reste du HUD appartient à la run.
end

local etatRun = UIKit.etatRun()
if not etatRun then
	return
end

-- « +X » gris sous le compteur (96 × 30 px) : part des pièces non ramassées rendue par la Maison
-- au Répit (50 %, crédit décidé par le serveur, annoncé par Annonce("PiecesMaison", { montant })).
local pastille = UIKit.creer("Frame", {
	Name = "GainMaison",
	BackgroundColor3 = UIKit.lumiere(C.Ardoise),
	Position = UDim2.fromOffset(0, 50),
	Size = UDim2.fromOffset(96, 30),
	Visible = false,
	Parent = compteur,
})
UIKit.habiller(pastille, 6, 3)
local texteGain = UIKit.etiquette(pastille, "", UDim2.new(1, -8, 1, -6), 22)
texteGain.AnchorPoint = Vector2.new(0.5, 0.5)
texteGain.Position = UDim2.fromScale(0.5, 0.5)
local jetonGain = 0

local function gainMaison(montant: number)
	jetonGain += 1
	local jeton = jetonGain
	texteGain.Text = "+" .. UIKit.formater(montant)
	pastille.Visible = true
	UIKit.rebond(pastille)
	UIKit.son("Piece")
	task.delay(2.5, function()
		if jeton == jetonGain then
			pastille.Visible = false
		end
	end)
end

------------------------------------------------------------------------------------------
-- Haut centre : bandeau Maison de a32 (280 × 66 px) = cartouche Jour + minuteur, PV, Colosse
------------------------------------------------------------------------------------------

local bandeau = UIKit.creer("Frame", {
	Name = "BandeauMaison",
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(280, 66),
	Parent = gui,
})
UIKit.echelle(bandeau)

local cartouche = UIKit.creer("Frame", {
	Name = "Cartouche",
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.15,
	Size = UDim2.new(1, 0, 0, 30),
	Parent = bandeau,
})
UIKit.habiller(cartouche, 6, 3)

local texteJour = UIKit.etiquette(cartouche, "JOUR 1", UDim2.new(0.42, -8, 1, -6), 24)
texteJour.AnchorPoint = Vector2.new(0, 0.5)
texteJour.Position = UDim2.new(0, 8, 0.5, 0)
texteJour.TextXAlignment = Enum.TextXAlignment.Left
texteJour.TextColor3 = C.ToitOrange

local minuteur = UIKit.etiquette(cartouche, "HORDE 1:20", UDim2.new(0.58, -8, 1, -6), 24)
minuteur.AnchorPoint = Vector2.new(1, 0.5)
minuteur.Position = UDim2.new(1, -8, 0.5, 0)
minuteur.TextXAlignment = Enum.TextXAlignment.Right

local function creerJauge(nom: string, y: number, hauteur: number, couleur: Color3, titre: string)
	local fond = UIKit.creer("Frame", {
		Name = nom,
		BackgroundColor3 = UIKit.ombre(C.Ardoise),
		ClipsDescendants = true,
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, hauteur),
		Parent = bandeau,
	})
	UIKit.habiller(fond, 0, 3)
	local trainee = UIKit.creer("Frame", {
		Name = "Trainee",
		BackgroundColor3 = C.Creme,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = fond,
	})
	local remplissage = UIKit.creer("Frame", {
		Name = "Remplissage",
		BackgroundColor3 = couleur,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = fond,
	})
	local label = UIKit.etiquette(fond, titre, UDim2.fromScale(1, 1), 14)
	return {
		fond = fond,
		trainee = trainee,
		remplissage = remplissage,
		label = label,
		contour = fond:FindFirstChildOfClass("UIStroke"),
		ratio = 1,
		jeton = 0,
	}
end

local jaugeMaison = creerJauge("Maison", 34, 20, C.ToitOrange, "MAISON")
local jaugeColosse = creerJauge("Colosse", 58, 8, C.VioletHorde, "")
jaugeColosse.fond.Visible = false

local pulsationMaison = TweenService:Create(
	jaugeMaison.contour,
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ Color = C.Alerte }
)

-- 3 paliers alignés sur les 3 états visuels de la Maison.
local function couleurMaison(ratio: number): Color3
	if ratio > 0.66 then
		return UIKit.lumiere(C.ToitOrange)
	elseif ratio > 0.33 then
		return C.ToitOrange
	end
	return C.Alerte
end

-- Remplissage immédiat (0,25 s) puis traînée Crème 0,4 s après le DERNIER coup.
local function majJauge(jauge, pv: number, pvMax: number, fonctionCouleur: ((number) -> Color3)?)
	local ratio = math.clamp(pv / math.max(1, pvMax), 0, 1)
	local cible = UDim2.fromScale(ratio, 1)
	local proprietes: { [string]: any } = { Size = cible }
	if fonctionCouleur then
		proprietes.BackgroundColor3 = fonctionCouleur(ratio)
	end
	TweenService:Create(jauge.remplissage, RAPIDE, proprietes):Play()
	jauge.jeton += 1
	if ratio < jauge.ratio then
		local jeton = jauge.jeton
		task.delay(0.4, function()
			if jauge.jeton == jeton then
				TweenService:Create(jauge.trainee, TRAINEE, { Size = cible }):Play()
			end
		end)
	else
		jauge.trainee.Size = cible
	end
	local baisse = jauge.ratio - ratio
	jauge.ratio = ratio
	return ratio, baisse
end

local maisonCritique = false
local function majMaison()
	local pvMax = math.max(1, entier(etatRun:GetAttribute("MaisonPVMax")))
	local pv = math.clamp(entier(etatRun:GetAttribute("MaisonPV")), 0, pvMax)
	local ratio, baisse = majJauge(jaugeMaison, pv, pvMax, couleurMaison)
	jaugeMaison.label.Text = `MAISON {UIKit.formater(pv)} / {UIKit.formater(pvMax)}`
	local critique = ratio <= 0.33
	if critique ~= maisonCritique then
		maisonCritique = critique
		if critique then
			pulsationMaison:Play()
		else
			pulsationMaison:Cancel()
			jaugeMaison.contour.Color = C.Encre
		end
	end
	if baisse > 0.05 then
		UIKit.rebond(jaugeMaison.fond)
	end
end

local function majColosse()
	local actif = etatRun:GetAttribute("Colosse") == true
	jaugeColosse.fond.Visible = actif
	if actif then
		majJauge(
			jaugeColosse,
			entier(etatRun:GetAttribute("ColossePV")),
			entier(etatRun:GetAttribute("ColossePVMax")),
			nil
		)
	end
end

etatRun:GetAttributeChangedSignal("MaisonPV"):Connect(majMaison)
etatRun:GetAttributeChangedSignal("MaisonPVMax"):Connect(majMaison)
etatRun:GetAttributeChangedSignal("ColossePV"):Connect(majColosse)
etatRun:GetAttributeChangedSignal("ColossePVMax"):Connect(majColosse)
majMaison()

------------------------------------------------------------------------------------------
-- Phase et minuteur : FinPhase − Workspace:GetServerTimeNow(), rafraîchi à 5 Hz
------------------------------------------------------------------------------------------

local PHASES = {
	Horde = { titre = "HORDE", couleur = UIKit.lumiere(C.VioletHorde) },
	Repit = { titre = "RÉPIT", couleur = C.Prairie },
}
local dernierBip = -1

local function phaseCourante(): (string, Color3)
	if etatRun:GetAttribute("Colosse") == true then
		return "COLOSSE", C.Alerte
	end
	local phase = PHASES[etatRun:GetAttribute("Phase")] or PHASES.Horde
	return phase.titre, phase.couleur
end

local function majPhase()
	local _, couleur = phaseCourante()
	minuteur.TextColor3 = couleur
	dernierBip = -1
	UIKit.rebond(cartouche)
end

suivre(etatRun, "Jour", function(jour)
	texteJour.Text = "JOUR " .. tostring(math.max(1, entier(jour)))
	UIKit.rebond(texteJour)
end)
etatRun:GetAttributeChangedSignal("Phase"):Connect(majPhase)
etatRun:GetAttributeChangedSignal("Colosse"):Connect(function()
	majPhase()
	majColosse()
end)
majPhase()
majColosse()

task.spawn(function()
	while gui.Parent do
		local titre = phaseCourante()
		local fin = tonumber(etatRun:GetAttribute("FinPhase")) or 0
		local reste = math.max(0, math.ceil(fin - Workspace:GetServerTimeNow()))
		minuteur.Text = string.format("%s %d:%02d", titre, reste // 60, reste % 60)
		if etatRun:GetAttribute("Phase") == "Repit" and reste > 0 and reste <= 5 and reste ~= dernierBip then
			dernierBip = reste
			UIKit.son("Bip")
			UIKit.rebond(minuteur)
		end
		task.wait(0.2)
	end
end)

------------------------------------------------------------------------------------------
-- Haut droite : têtes des Survivants (6 × 32 px, 4 px d'écart), contour Alerte si étourdi
------------------------------------------------------------------------------------------

local rangee = UIKit.creer("Frame", {
	Name = "Survivants",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -8, 0, 8),
	Size = UDim2.fromOffset(212, 32),
	Parent = gui,
})
UIKit.echelle(rangee)
UIKit.creer("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = rangee,
})

local vignettes = {} -- [Player] = { cellule, image, contour, connexion }
local ordreArrivee = 0

local function majVignette(autre: Player)
	local vignette = vignettes[autre]
	if not vignette then
		return
	end
	local etourdi = UIKit.estEtourdi(autre)
	vignette.contour.Color = if etourdi then C.Alerte elseif autre == joueur then C.ToitOrange else C.Creme
	vignette.image.ImageTransparency = if etourdi then 0.5 else 0
	if etourdi then
		UIKit.rebond(vignette.image)
		local reste = (tonumber(autre:GetAttribute("EtourdiJusqua")) or 0) - Workspace:GetServerTimeNow()
		task.delay(math.clamp(reste, 0, 4) + 0.05, majVignette, autre)
	end
end

local function ajouterVignette(autre: Player)
	if vignettes[autre] then
		return
	end
	ordreArrivee += 1
	local cellule = UIKit.creer("Frame", {
		Name = "Survivant" .. autre.UserId,
		BackgroundTransparency = 1,
		LayoutOrder = if autre == joueur then 0 else ordreArrivee,
		Size = UDim2.fromOffset(32, 32),
		Parent = rangee,
	})
	local image = UIKit.creer("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.NuitLabo,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(32, 32),
		Parent = cellule,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 6), Parent = image })
	local contour = UIKit.creer("UIStroke", { Color = C.Creme, Thickness = 3, Parent = image })
	UIKit.tete(image, autre.UserId)
	vignettes[autre] = {
		cellule = cellule,
		image = image,
		contour = contour,
		connexion = autre:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
			majVignette(autre)
		end),
	}
	majVignette(autre)
end

for _, autre in Players:GetPlayers() do
	ajouterVignette(autre)
end
Players.PlayerAdded:Connect(ajouterVignette)
Players.PlayerRemoving:Connect(function(autre: Player)
	local vignette = vignettes[autre]
	if vignette then
		vignette.connexion:Disconnect()
		vignette.cellule:Destroy()
		vignettes[autre] = nil
	end
end)

------------------------------------------------------------------------------------------
-- Bannières d'annonce (centre, 440 × 64 px)
------------------------------------------------------------------------------------------

local banniere = UIKit.creer("Frame", {
	Name = "Banniere",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.1,
	Position = UDim2.fromScale(0.5, 0.36),
	Size = UDim2.fromOffset(440, 64),
	Visible = false,
	Parent = gui,
})
UIKit.habiller(banniere, 8, 4)
UIKit.echelle(banniere)
local texteBanniere = UIKit.etiquette(banniere, "", UDim2.new(1, -20, 1, -12), 34)
texteBanniere.AnchorPoint = Vector2.new(0.5, 0.5)
texteBanniere.Position = UDim2.fromScale(0.5, 0.5)
local jetonBanniere = 0

local function annoncer(texte: string, couleur: Color3, duree: number)
	jetonBanniere += 1
	local jeton = jetonBanniere
	texteBanniere.Text = texte
	texteBanniere.TextColor3 = couleur
	banniere.Rotation = -4
	banniere.Visible = true
	UIKit.rebond(banniere)
	TweenService:Create(banniere, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0,
	}):Play()
	task.delay(duree, function()
		if jeton == jetonBanniere then
			banniere.Visible = false
		end
	end)
end

UIKit.ecouter("Annonce", function(cle: string, donnees: any)
	local d = if type(donnees) == "table" then donnees else {}
	if cle == "Colosse" then
		annoncer("LE COLOSSE ARRIVE !", C.Alerte, 3)
		UIKit.son("Alerte")
	elseif cle == "JourFranchi" then
		annoncer(string.format("JOUR %d FRANCHI !  +%d gemmes", entier(d.jour), entier(d.gemmes)), C.GemmeCyan, 2.5)
		UIKit.son("Achat")
	elseif cle == "Record" then
		annoncer(string.format("NOUVEAU RECORD : JOUR %d !", entier(d.jour)), UIKit.lumiere(C.ToitOrange), 3)
	elseif cle == "MaisonTombee" then
		annoncer(
			string.format("LA MAISON EST TOMBÉE ! Jour %d  +%d gemmes", entier(d.jour), entier(d.gemmes)),
			C.Creme,
			6
		)
	elseif cle == "PiecesMaison" then
		local montant = entier(d.montant)
		if montant > 0 then
			gainMaison(montant)
		end
	end
end)

------------------------------------------------------------------------------------------
-- Voile d'étourdissement (2 s) : lu dans l'attribut EtourdiJusqua écrit par le serveur
------------------------------------------------------------------------------------------

local voileGui = UIKit.creer("ScreenGui", {
	Name = "VoileEtourdi",
	DisplayOrder = 10,
	Enabled = false,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.None,
	Parent = playerGui,
})
local voile = UIKit.creer("Frame", {
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Parent = voileGui,
})
local blocEtourdi = UIKit.creer("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.4),
	Size = UDim2.fromOffset(260, 70),
	Parent = voile,
})
UIKit.echelle(blocEtourdi)
local texteEtourdi = UIKit.etiquette(blocEtourdi, "ÉTOURDI !", UDim2.new(1, 0, 0, 44), 40)
local fondJaugeEtourdi = UIKit.creer("Frame", {
	BackgroundColor3 = UIKit.ombre(C.Ardoise),
	ClipsDescendants = true,
	Position = UDim2.fromOffset(0, 54),
	Size = UDim2.new(1, 0, 0, 12),
	Parent = blocEtourdi,
})
UIKit.habiller(fondJaugeEtourdi, 0, 3)
local jaugeEtourdi = UIKit.creer("Frame", {
	BackgroundColor3 = C.Creme,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Parent = fondJaugeEtourdi,
})
local jetonEtourdi = 0

local function majEtourdi()
	local jusqua = tonumber(joueur:GetAttribute("EtourdiJusqua")) or 0
	local duree = math.min(jusqua - Workspace:GetServerTimeNow(), 4)
	if duree <= 0.05 then
		return
	end
	jetonEtourdi += 1
	local jeton = jetonEtourdi
	voileGui.Enabled = true
	voile.BackgroundTransparency = 1
	TweenService:Create(voile, TweenInfo.new(0.12), { BackgroundTransparency = 0.6 }):Play()
	jaugeEtourdi.Size = UDim2.fromScale(1, 1)
	TweenService:Create(jaugeEtourdi, TweenInfo.new(duree, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(0, 1),
	}):Play()
	UIKit.rebond(texteEtourdi)
	UIKit.son("Etourdi")
	task.delay(duree, function()
		if jeton ~= jetonEtourdi then
			return
		end
		local sortie = TweenService:Create(voile, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
		sortie.Completed:Once(function()
			if jeton == jetonEtourdi then
				voileGui.Enabled = false
			end
		end)
		sortie:Play()
	end)
end

joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(majEtourdi)
```

### a28/Reglages.client.lua
```lua
-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Reglages (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Réglages du Survivant (Laboratoire et Prairie) : Tir auto,
-- Secousses, Effets réduits, Musique, Effets sonores. Le client envoie DemandeReglage(cle, valeur) ;
-- le serveur valide, écrit l'attribut dans Player.Reglages et le sauvegarde avec le profil.
-- Un bouton n'affiche la nouvelle valeur qu'une fois écrite par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Reglages] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
if not playerGui then
	return
end
UIKit.remote("DemandeReglage") -- résolution anticipée

local ATTENTE_MAX = 3 -- s : filet si le serveur ne répond pas
local VOLUMES = { 1, 0.5, 0 } -- cycle Musique / Effets : 100 %, 50 %, 0 %
local REGLAGES = {
	{ cle = "TirAuto", nom = "Tir auto", genre = "bool" },
	{ cle = "Secousses", nom = "Secousses", genre = "bool" },
	{ cle = "EffetsReduits", nom = "Effets réduits", genre = "bool" },
	{ cle = "Musique", nom = "Musique", genre = "volume" },
	{ cle = "Effets", nom = "Effets sonores", genre = "volume" },
}

local gui = UIKit.creer("ScreenGui", {
	Name = "ReglagesZsurvie",
	DisplayOrder = 8,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

------------------------------------------------------------------------------------------
-- Bouton 60 px sous le compteur et sa pastille « +X » : Y = 8 + 88 px × échelle
------------------------------------------------------------------------------------------

local boutonOuvrir = UIKit.creer("TextButton", {
	Name = "BoutonReglages",
	AutoButtonColor = false,
	BackgroundColor3 = C.NuitLabo,
	Size = UDim2.fromOffset(60, 60),
	Text = "",
	Parent = gui,
})
UIKit.habiller(boutonOuvrir, 8, 3)
UIKit.echelle(boutonOuvrir)
UIKit.surEchelle(function(f: number)
	boutonOuvrir.Position = UDim2.fromOffset(8, 8 + 88 * f)
end)

local image = UIKit.icone("Reglages")
if image ~= "" then
	UIKit.creer("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = image,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		Parent = boutonOuvrir,
	})
else
	-- Repli sans icône : 3 barres Crème (menu), lisibles par tous les âges.
	for i = 1, 3 do
		UIKit.creer("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = C.Creme,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 16 + (i - 1) * 14),
			Size = UDim2.fromOffset(32, 6),
			Parent = boutonOuvrir,
		})
	end
end

------------------------------------------------------------------------------------------
-- Panneau central (540 × 290 px) : 5 boutons de 252 × 60 px sur 2 colonnes
------------------------------------------------------------------------------------------

local panneau = UIKit.creer("Frame", {
	Name = "Panneau",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.05,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(540, 290),
	Visible = false,
	Parent = gui,
})
UIKit.habiller(panneau, 8, 4)
UIKit.echelle(panneau)

local titre = UIKit.etiquette(panneau, "RÉGLAGES", UDim2.fromOffset(240, 40), 32)
titre.Position = UDim2.fromOffset(14, 14)
titre.TextXAlignment = Enum.TextXAlignment.Left
titre.TextColor3 = C.ToitOrange

local boutonFermer = UIKit.bouton(panneau, "X", UDim2.fromOffset(60, 60), C.Alerte, 30)
boutonFermer.AnchorPoint = Vector2.new(1, 0)
boutonFermer.Position = UDim2.new(1, -8, 0, 8)

local grille = UIKit.creer("Frame", {
	Name = "Grille",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 80),
	Size = UDim2.fromOffset(516, 196),
	Parent = panneau,
})
UIKit.creer("UIGridLayout", {
	CellPadding = UDim2.fromOffset(12, 8),
	CellSize = UDim2.fromOffset(252, 60),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = grille,
})

local function texteValeur(option, valeur: any): string
	if option.genre == "bool" then
		return if valeur == true then "OUI" else "NON"
	end
	return `{math.round((tonumber(valeur) or 0) * 100)} %`
end

local function suivante(option, valeur: any): any
	if option.genre == "bool" then
		return not (valeur == true)
	end
	local actuelle = tonumber(valeur) or 1
	for index, niveau in VOLUMES do
		if math.abs(niveau - actuelle) < 0.01 then
			return VOLUMES[index % #VOLUMES + 1]
		end
	end
	return VOLUMES[1]
end

local function afficher(option)
	local valeur = UIKit.reglage(option.cle)
	local etat = if option.attente then "…" else texteValeur(option, valeur)
	option.label.Text = `{option.nom} : {etat}`
	option.bouton.BackgroundColor3 = if option.genre == "volume" then C.NuitLabo
		elseif valeur == true then C.Prairie
		else UIKit.ombre(C.Ardoise)
end

-- Musique et Effets pilotent les SoundGroups SoundService.Musique et SoundService.Effets.
local function appliquerVolume(nomGroupe: string, valeur: any)
	local groupe = SoundService:FindFirstChild(nomGroupe)
	if not (groupe and groupe:IsA("SoundGroup")) then
		return
	end
	local base = groupe:GetAttribute("VolumeBase")
	if type(base) ~= "number" then
		base = groupe.Volume
		groupe:SetAttribute("VolumeBase", base)
	end
	groupe.Volume = base * math.clamp(tonumber(valeur) or 1, 0, 1)
end

local options = {}
for ordre, reglage in REGLAGES do
	local bouton, label = UIKit.bouton(grille, "", UDim2.fromOffset(252, 60), C.NuitLabo, 22)
	bouton.Name = reglage.cle
	bouton.LayoutOrder = ordre
	local option = {
		cle = reglage.cle,
		nom = reglage.nom,
		genre = reglage.genre,
		bouton = bouton,
		label = label,
		attente = false,
		jeton = 0,
	}
	options[ordre] = option
	afficher(option)
	bouton.Activated:Connect(function()
		if option.attente then
			return
		end
		local valeur = suivante(option, UIKit.reglage(option.cle))
		option.attente = true
		option.jeton += 1
		local jeton = option.jeton
		afficher(option)
		UIKit.son("Clic")
		UIKit.envoyer("DemandeReglage", option.cle, valeur)
		task.delay(ATTENTE_MAX, function()
			if option.jeton == jeton and option.attente then
				option.attente = false
				afficher(option)
			end
		end)
	end)
end

local function basculer(visible: boolean)
	panneau.Visible = visible
	if visible then
		UIKit.rebond(panneau)
	end
end

boutonOuvrir.Activated:Connect(function()
	UIKit.son("Clic")
	UIKit.rebond(boutonOuvrir)
	basculer(not panneau.Visible)
end)

boutonFermer.Activated:Connect(function()
	UIKit.son("Clic")
	basculer(false)
end)

------------------------------------------------------------------------------------------
-- Écriture serveur dans Player.Reglages : fin de l'attente, volumes appliqués
------------------------------------------------------------------------------------------

for _, option in options do
	UIKit.surReglage(option.cle, function(valeur: any)
		option.attente = false
		afficher(option)
		if option.cle == "Musique" or option.cle == "Effets" then
			appliquerVolume(option.cle, valeur)
		end
	end)
end
```

### a28/UIKit.lua
```lua
-- Emplacement Roblox : ReplicatedStorage > Client > UIKit (ModuleScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Boîte à outils partagée des LocalScripts de l'interface.
-- Palette (ReplicatedStorage.Charte + repli), rebond élastique du canon, sons bridés, toasts,
-- UIScale du gabarit 800 × 360, attentes bornées (10 s + warn), place (Workspace.TypePlace),
-- remotes, réglages, prix du Catalogue, points du Plan, têtes des Survivants, crochets pour a10.
-- Ce module ne décide de rien : il affiche ce que le serveur a écrit et transmet des demandes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local UIKit = {}

UIKit.POLICE = Enum.Font.FredokaOne
UIKit.DELAI = 10 -- s : délai de chaque WaitForChild, suivi d'un warn
UIKit.GABARIT = Vector2.new(800, 360) -- px : maquette HUD de référence
UIKit.ECHELLE_MAX = 1.4
UIKit.PORTEE_REPARATION = 14 -- studs depuis Plan.MAISON (affichage ; le serveur tranche)
UIKit.DEFENSES_MAX = 3 -- canon §6
UIKit.SECOUSSE_MAX = 0.8 -- stud
UIKit.REGLAGES_DEFAUT = { TirAuto = true, Secousses = true, EffetsReduits = false, Musique = 1, Effets = 1 }

------------------------------------------------------------------------------------------
-- Attentes bornées et modules
------------------------------------------------------------------------------------------

function UIKit.attendre(parent: Instance?, nom: string): Instance?
	if not parent then
		warn(`[a28] parent absent : {nom} ne peut pas être attendu`)
		return nil
	end
	local enfant = parent:WaitForChild(nom, UIKit.DELAI)
	if not enfant then
		warn(`[a28] {parent:GetFullName()}.{nom} introuvable après {UIKit.DELAI} s`)
	end
	return enfant
end

local cacheModules = {}

-- Modules partagés dans ReplicatedStorage (Charte, Catalogue, Plan, BlasterStats) ; modules client
-- à côté de UIKit, dans ReplicatedStorage.Client (ZbiresRendu, BlasterControleur, VfxClient).
function UIKit.module(nom: string, client: boolean?): any
	if cacheModules[nom] == nil then
		local instance = UIKit.attendre(if client then script.Parent else ReplicatedStorage, nom)
		local resultat: any = false
		if instance and instance:IsA("ModuleScript") then
			local ok, valeur = pcall(require, instance)
			if ok then
				resultat = valeur
			else
				warn(`[a28] require({nom}) a échoué : {valeur}`)
			end
		end
		cacheModules[nom] = resultat
	end
	return cacheModules[nom] or nil
end

------------------------------------------------------------------------------------------
-- Palette et icônes
------------------------------------------------------------------------------------------

-- Palette du canon §7. Sert uniquement de repli si ReplicatedStorage.Charte manque une clé.
local PALETTE_REPLI = {
	Encre = "#1E1B2E",
	Prairie = "#6CC24A",
	TerreBattue = "#C8894F",
	Creme = "#F6E7C1",
	ToitOrange = "#EF7A2F",
	Or = "#FFC933",
	GemmeCyan = "#33D6F0",
	VioletHorde = "#9B5DE5",
	Alerte = "#FF2E63",
	NuitLabo = "#2A3263",
	Ardoise = "#4A4560",
}

local charte = UIKit.module("Charte")

local function lireCharte(nom: string): Color3?
	if type(charte) ~= "table" then
		return nil
	end
	local couleurs = charte.Couleurs
	local valeur = if type(couleurs) == "table" and couleurs[nom] ~= nil then couleurs[nom] else charte[nom]
	return if typeof(valeur) == "Color3" then valeur else nil
end

UIKit.Couleurs = {}
for nom, hex in PALETTE_REPLI do
	UIKit.Couleurs[nom] = lireCharte(nom) or Color3.fromHex(hex)
end
local C = UIKit.Couleurs

-- Teintes du canon : ombre = base × 0,8 ; lumière = base + 20 % de Crème.
function UIKit.ombre(couleur: Color3): Color3
	return Color3.new(couleur.R * 0.8, couleur.G * 0.8, couleur.B * 0.8)
end

function UIKit.lumiere(couleur: Color3): Color3
	return couleur:Lerp(C.Creme, 0.2)
end

-- Charte.Icones.<Nom> = "rbxassetid://…" ; chaîne vide si absente : le texte du bouton prend le relais.
function UIKit.icone(nom: string): string
	local icones = type(charte) == "table" and charte.Icones or nil
	local valeur = type(icones) == "table" and icones[nom] or nil
	return if type(valeur) == "string" then valeur else ""
end

------------------------------------------------------------------------------------------
-- Listes partagées (noms officiels du canon)
------------------------------------------------------------------------------------------

UIKit.DEFENSES = {
	{ cle = "Muret", texte = "Muret", court = "MURET", couleur = C.Ardoise },
	{ cle = "MiniTourelle", texte = "Mini-Tourelle", court = "MINI-\nTOURELLE", couleur = C.ToitOrange },
	{ cle = "TapisCollant", texte = "Tapis Collant", court = "TAPIS\nCOLLANT", couleur = C.Prairie },
}

UIKit.PINGS = {
	{ cle = "Colosse", texte = "Colosse !", couleur = C.Alerte },
	{ cle = "Repare", texte = "Répare !", couleur = C.ToitOrange },
	{ cle = "Ici", texte = "Ici !", couleur = C.Prairie },
	{ cle = "Merci", texte = "Merci !", couleur = C.TerreBattue },
}
UIKit.PINGS_PAR_CLE = {}
for _, ping in UIKit.PINGS do
	UIKit.PINGS_PAR_CLE[ping.cle] = ping
end

------------------------------------------------------------------------------------------
-- Fabrique d'instances et habillage
------------------------------------------------------------------------------------------

function UIKit.creer(classe: string, proprietes: { [string]: any }, enfants: { Instance }?): any
	local instance: any = Instance.new(classe)
	for cle, valeur in proprietes do
		if cle ~= "Parent" then
			instance[cle] = valeur
		end
	end
	if enfants then
		for _, enfant in enfants do
			enfant.Parent = instance
		end
	end
	if proprietes.Parent then
		instance.Parent = proprietes.Parent
	end
	return instance
end

-- Coins légèrement arrondis (style Pixel-bloc) + contour Encre.
function UIKit.habiller(objet: GuiObject, rayon: number?, epaisseur: number?): GuiObject
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, rayon or 6), Parent = objet })
	UIKit.creer("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = C.Encre,
		Thickness = epaisseur or 3,
		Parent = objet,
	})
	return objet
end

function UIKit.etiquette(parent: Instance, texte: string, taille: UDim2, tailleMax: number?): TextLabel
	local label = UIKit.creer("TextLabel", {
		BackgroundTransparency = 1,
		Font = UIKit.POLICE,
		Size = taille,
		Text = texte,
		TextColor3 = C.Creme,
		TextScaled = true,
		Parent = parent,
	})
	UIKit.creer("UITextSizeConstraint", { MaxTextSize = tailleMax or 28, MinTextSize = 9, Parent = label })
	UIKit.creer("UIStroke", { Color = C.Encre, Thickness = 2, Parent = label })
	return label
end

function UIKit.bouton(parent: Instance, texte: string, taille: UDim2, couleur: Color3, tailleMax: number?)
	local bouton = UIKit.creer("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = couleur,
		Size = taille,
		Text = "",
		Parent = parent,
	})
	UIKit.habiller(bouton, 8, 3)
	local label = UIKit.etiquette(bouton, texte, UDim2.new(1, -10, 1, -10), tailleMax)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	return bouton, label
end

------------------------------------------------------------------------------------------
-- Rebond élastique du canon §7 : écrasement × 0,8, étirement × 1,2, 0,15 s au total
------------------------------------------------------------------------------------------

local taillesDeBase = setmetatable({}, { __mode = "k" })
local jetons = setmetatable({}, { __mode = "k" })
local ETAPE = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function multiplier(u: UDim2, fx: number, fy: number): UDim2
	return UDim2.new(u.X.Scale * fx, u.X.Offset * fx, u.Y.Scale * fy, u.Y.Offset * fy)
end

-- À n'utiliser que sur des objets dont la taille ne change pas par ailleurs
-- (hors UIGridLayout, qui impose la taille des cellules).
function UIKit.rebond(objet: GuiObject)
	local base = taillesDeBase[objet] or objet.Size
	taillesDeBase[objet] = base
	local jeton = (jetons[objet] or 0) + 1
	jetons[objet] = jeton
	task.spawn(function()
		for _, taille in { multiplier(base, 1.2, 0.8), multiplier(base, 0.8, 1.2), base } do
			if jetons[objet] ~= jeton then
				return
			end
			local tween = TweenService:Create(objet, ETAPE, { Size = taille })
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

------------------------------------------------------------------------------------------
-- Sons UI (SoundService.SonsUI, SoundGroup Effets), bridés pour rester sous 16 sons simultanés
------------------------------------------------------------------------------------------

local derniersSons = {}
function UIKit.son(nom: string, intervalleMin: number?)
	local dossier = SoundService:FindFirstChild("SonsUI")
	local son = dossier and dossier:FindFirstChild(nom)
	if not (son and son:IsA("Sound")) then
		return
	end
	local maintenant = os.clock()
	if maintenant - (derniersSons[nom] or 0) < (intervalleMin or 0.08) then
		return
	end
	derniersSons[nom] = maintenant
	SoundService:PlayLocalSound(son)
end

------------------------------------------------------------------------------------------
-- Échelle : UIScale = clamp(min(X / 800, Y / 360), 1, 1,4), partagée par tout le HUD
------------------------------------------------------------------------------------------

UIKit.facteur = 1
local uiScales = setmetatable({}, { __mode = "k" })
local rappelsEchelle = {}
local connexionVue: RBXScriptConnection? = nil

local function recalculer()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local vue = camera.ViewportSize
	local facteur = math.clamp(math.min(vue.X / UIKit.GABARIT.X, vue.Y / UIKit.GABARIT.Y), 1, UIKit.ECHELLE_MAX)
	if facteur == UIKit.facteur then
		return
	end
	UIKit.facteur = facteur
	for uiScale in uiScales do
		uiScale.Scale = facteur
	end
	for _, rappel in rappelsEchelle do
		task.spawn(rappel, facteur)
	end
end

local function brancherCamera()
	if connexionVue then
		connexionVue:Disconnect()
	end
	local camera = Workspace.CurrentCamera
	if camera then
		connexionVue = camera:GetPropertyChangedSignal("ViewportSize"):Connect(recalculer)
		recalculer()
	end
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(brancherCamera)
brancherCamera()

function UIKit.echelle(objet: GuiObject): UIScale
	local uiScale = UIKit.creer("UIScale", { Scale = UIKit.facteur, Parent = objet })
	uiScales[uiScale] = true
	return uiScale
end

-- Pour les positions qui dépendent de la taille d'un autre bloc mis à l'échelle.
function UIKit.surEchelle(rappel: (number) -> ())
	table.insert(rappelsEchelle, rappel)
	rappel(UIKit.facteur)
end

------------------------------------------------------------------------------------------
-- Toasts (refus, rappels courts)
------------------------------------------------------------------------------------------

local toast = nil
local jetonToast = 0

function UIKit.toast(texte: string, couleur: Color3?)
	if not toast then
		local playerGui = UIKit.attendre(Players.LocalPlayer, "PlayerGui")
		if not playerGui then
			return
		end
		local gui = UIKit.creer("ScreenGui", {
			Name = "ToastsZsurvie",
			DisplayOrder = 20,
			ResetOnSpawn = false,
			ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
			Parent = playerGui,
		})
		local cadre = UIKit.creer("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = C.Encre,
			BackgroundTransparency = 0.1,
			Position = UDim2.fromScale(0.5, 0.7),
			Size = UDim2.fromOffset(300, 44),
			Visible = false,
			Parent = gui,
		})
		UIKit.habiller(cadre, 6, 3)
		UIKit.echelle(cadre)
		local label = UIKit.etiquette(cadre, "", UDim2.new(1, -16, 1, -8), 24)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromScale(0.5, 0.5)
		toast = { cadre = cadre, label = label }
	end
	jetonToast += 1
	local jeton = jetonToast
	toast.label.Text = texte
	toast.label.TextColor3 = couleur or C.Creme
	toast.cadre.Visible = true
	UIKit.rebond(toast.cadre)
	task.delay(1.8, function()
		if jeton == jetonToast then
			toast.cadre.Visible = false
		end
	end)
end

------------------------------------------------------------------------------------------
-- Place, état de run et remotes
------------------------------------------------------------------------------------------

local typePlace: string? = nil

-- Workspace.TypePlace = "Laboratoire" ou "Prairie", posé dans Studio sur chaque place.
function UIKit.typePlace(): string
	if typePlace then
		return typePlace
	end
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	local debut = os.clock()
	local valeur = Workspace:GetAttribute("TypePlace")
	while valeur == nil and os.clock() - debut < UIKit.DELAI do
		task.wait(0.1)
		valeur = Workspace:GetAttribute("TypePlace")
	end
	if valeur ~= "Prairie" and valeur ~= "Laboratoire" then
		warn(`[a28] Workspace.TypePlace invalide ({tostring(valeur)}) après {UIKit.DELAI} s : interface du Laboratoire`)
		valeur = "Laboratoire"
	end
	typePlace = valeur
	return valeur
end

function UIKit.surLaPrairie(): boolean
	return UIKit.typePlace() == "Prairie"
end

local etatRun: Instance? = nil
function UIKit.etatRun(): Instance?
	etatRun = etatRun or UIKit.attendre(ReplicatedStorage, "EtatRun")
	return etatRun
end

local dossierRemotes: Instance? = nil
local cacheRemotes = {}

function UIKit.remote(nom: string): Instance?
	if cacheRemotes[nom] == nil then
		dossierRemotes = dossierRemotes or UIKit.attendre(ReplicatedStorage, "Remotes")
		local remote = UIKit.attendre(dossierRemotes, nom)
		cacheRemotes[nom] = if remote and remote:IsA("BaseRemoteEvent") then remote else false
	end
	return cacheRemotes[nom] or nil
end

function UIKit.envoyer(nom: string, ...: any)
	local remote: any = UIKit.remote(nom)
	if remote then
		remote:FireServer(...)
	end
end

function UIKit.ecouter(nom: string, rappel: (...any) -> ()): RBXScriptConnection?
	local remote: any = UIKit.remote(nom)
	return if remote then remote.OnClientEvent:Connect(rappel) else nil
end

------------------------------------------------------------------------------------------
-- Réglages (Player.Reglages, écrits par le serveur) et secousses
------------------------------------------------------------------------------------------

local dossierReglages: Instance? = nil
function UIKit.reglages(): Instance?
	dossierReglages = dossierReglages or UIKit.attendre(Players.LocalPlayer, "Reglages")
	return dossierReglages
end

-- Lecture sans attente : valeur par défaut tant que le serveur n'a rien écrit.
function UIKit.reglage(nom: string): any
	local valeur = if dossierReglages then dossierReglages:GetAttribute(nom) else nil
	if valeur == nil then
		return UIKit.REGLAGES_DEFAUT[nom]
	end
	return valeur
end

function UIKit.surReglage(nom: string, rappel: (any) -> ())
	local dossier = UIKit.reglages()
	if dossier then
		dossier:GetAttributeChangedSignal(nom):Connect(function()
			rappel(UIKit.reglage(nom))
		end)
	end
	rappel(UIKit.reglage(nom))
end

-- Toutes les secousses passent par VfxClient.secouer (a37), plafonnées à 0,8 stud.
function UIKit.secouer(amplitude: number)
	if UIKit.reglage("Secousses") == false then
		return
	end
	local vfx = UIKit.module("VfxClient", true)
	if type(vfx) == "table" and type(vfx.secouer) == "function" then
		vfx.secouer(math.min(amplitude, UIKit.SECOUSSE_MAX))
	end
end

------------------------------------------------------------------------------------------
-- Catalogue et Plan
------------------------------------------------------------------------------------------

-- Catalogue.prix(cle, niveauVise) -> pièces ; nil = niveau MAX ou clé inconnue.
function UIKit.prix(cle: string, niveauVise: number?): number?
	local catalogue = UIKit.module("Catalogue")
	if type(catalogue) ~= "table" or type(catalogue.prix) ~= "function" then
		return nil
	end
	local ok, prix = pcall(catalogue.prix, cle, niveauVise or 1)
	return if ok and type(prix) == "number" and prix >= 0 then prix else nil
end

-- Plan.<NOM> (Vector3 ou CFrame), par exemple Plan.ETABLI et Plan.MAISON.
function UIKit.point(nom: string): Vector3?
	local plan = UIKit.module("Plan")
	local valeur = if type(plan) == "table" then plan[nom] else nil
	if typeof(valeur) == "CFrame" then
		return valeur.Position
	end
	return if typeof(valeur) == "Vector3" then valeur else nil
end

------------------------------------------------------------------------------------------
-- État partagé entre scripts et crochets pour a10
------------------------------------------------------------------------------------------

local etats, abonnes = {}, {}

function UIKit.definirEtat(nom: string, valeur: any)
	if etats[nom] == valeur then
		return
	end
	etats[nom] = valeur
	for _, rappel in abonnes[nom] or {} do
		task.spawn(rappel, valeur)
	end
end

function UIKit.surEtat(nom: string, rappel: (any) -> ())
	abonnes[nom] = abonnes[nom] or {}
	table.insert(abonnes[nom], rappel)
	rappel(etats[nom])
end

-- Crochets a10 : UIKit.pulser("Muret", true) ; UIKit.pulser("Ping", true, "PingColosse") ;
-- UIKit.pulser(nom, false) arrête la pulsation et rend le texte du bouton.
function UIKit.pulser(bouton: string, actif: boolean, icone: string?)
	UIKit.definirEtat("Pulse" .. bouton, if actif then (icone or true) else false)
end

------------------------------------------------------------------------------------------
-- Têtes des Survivants (HeadShot 48 × 48, chargée une fois par Survivant)
------------------------------------------------------------------------------------------

local cacheTetes = {}

function UIKit.tete(image: ImageLabel, userId: number)
	image:SetAttribute("UserId", userId)
	image.Image = cacheTetes[userId] or ""
	if cacheTetes[userId] then
		return
	end
	task.spawn(function()
		local ok, contenu = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and type(contenu) == "string" then
			cacheTetes[userId] = contenu
			if image:GetAttribute("UserId") == userId then
				image.Image = contenu
			end
		end
	end)
end

------------------------------------------------------------------------------------------
-- Aides de lecture d'état (lecture seule)
------------------------------------------------------------------------------------------

function UIKit.formater(nombre: number): string
	local entier = tostring(math.max(0, math.floor(nombre)))
	local groupe = entier:reverse():gsub("(%d%d%d)", "%1 "):reverse()
	return (groupe:gsub("^%s+", ""))
end

function UIKit.distancePlate(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

function UIKit.racineLocale(): BasePart?
	local personnage = Players.LocalPlayer.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if racine and racine:IsA("BasePart") then
		return racine
	end
	return nil
end

-- EtourdiJusqua = Workspace:GetServerTimeNow() + 2, écrit par le serveur.
function UIKit.estEtourdi(qui: Player): boolean
	local jusqua = qui:GetAttribute("EtourdiJusqua")
	return type(jusqua) == "number" and jusqua > Workspace:GetServerTimeNow()
end

return UIKit
```

### a29/Demarrage.server.lua
```lua
-- ServerScriptService.Securite.Demarrage (Script)
--!strict
-- Point d'entrée anti-exploit, identique dans les places Laboratoire et Prairie. Rien ici ne bloque :
-- le groupe Survivants est enregistré avant tout require, la racine de la carte est attendue en tâche de fond.
-- Réglages Studio : Workspace.TypePlace, Workspace.CentrePlace, Workspace.RejectCharacterDeletions = Enabled.
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local GROUPE = "Survivants"

-- 1. Les Survivants ne se touchent pas : ni poussée ni fling (aucun PvP dans Zsurvie).
if not PhysicsService:IsCollisionGroupRegistered(GROUPE) then
	PhysicsService:RegisterCollisionGroup(GROUPE)
end
PhysicsService:CollisionGroupSetCollidable(GROUPE, GROUPE, false)

local function ranger(instance: Instance)
	if instance:IsA("BasePart") then
		instance.CollisionGroup = GROUPE
	end
end

local function surPersonnage(personnage: Model)
	for _, descendant in personnage:GetDescendants() do
		ranger(descendant)
	end
	personnage.DescendantAdded:Connect(ranger)
end

local function surJoueur(joueur: Player)
	joueur.CharacterAdded:Connect(surPersonnage)
	local personnage = joueur.Character
	if personnage then
		surPersonnage(personnage)
	end
end

Players.PlayerAdded:Connect(surJoueur)
for _, joueur in Players:GetPlayers() do
	surJoueur(joueur)
end

-- 2. Modules : Validation crée ReplicatedStorage.Remotes, GardienMouvement lance ses contrôles.
local Validation = require(script.Parent.Validation)
local GardienMouvement = require(script.Parent.GardienMouvement)

-- 3. Bouton « Je suis coincé » : 1 demande toutes les 10 s, filtrée par Validation.
Validation.brancher("DemandeDeblocage", function(joueur: Player)
	GardienMouvement.debloquer(joueur)
end)

-- 4. Carte 100 % ancrée : une Part libre proche d'un joueur lui est confiée par la physique et devient
--    une arme de fling. Les défenses posées vont dans <racine>.Defenses, donc dans le rayon de sol.
task.spawn(function()
	local carte = GardienMouvement.attendreRacine()
	if not carte then
		return -- GardienMouvement a déjà prévenu par un warn
	end
	local function verrouiller(instance: Instance)
		if instance:IsA("BasePart") and not instance.Anchored then
			warn("[AntiExploit] Part non ancrée dans la carte : " .. instance:GetFullName())
			if instance:CanSetNetworkOwnership() then
				instance:SetNetworkOwner(nil)
			end
		end
	end
	for _, descendant in carte:GetDescendants() do
		verrouiller(descendant)
	end
	carte.DescendantAdded:Connect(verrouiller)
	if workspace:GetAttribute("TypePlace") == "Prairie" and not carte:FindFirstChild("Defenses") then
		local defenses = Instance.new("Folder")
		defenses.Name = "Defenses"
		defenses.Parent = carte
	end
end)
```

### a29/GardienMouvement.lua
```lua
-- ServerScriptService.Securite.GardienMouvement (ModuleScript)
--!strict
-- Seul script qui écrit WalkSpeed et JumpHeight (valeurs de ReplicatedStorage.Config.Mouvement, a09).
-- Contrôle 4 fois par seconde la position répliquée de chaque Survivant : budget de distance, zone de jeu,
-- volumes interdits et vol. Corrige d'abord, signale ensuite. Le require ne bloque jamais : la racine de
-- la carte (ReplicatedStorage.Plan.RACINE, a11) se résout en tâche de fond, 10 s au plus.
-- Tags lus : ZoneInterdite, ZoneJouable (Laboratoire), ZoneGlisse, PointDeblocage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local CollectionService = game:GetService("CollectionService")

local Validation = require(script.Parent.Validation)

local PERIODE = 0.25 -- s entre deux contrôles
local MARGE = 1.2 -- tolérance de vitesse (latence mobile)
local BUDGET_S = 2.5 -- secondes de course accumulables (gel réseau)
local ETOURDI_S = 2 -- canon : un coup étourdit 2 s
local ETOURDI_BUDGET_S = 1 -- course tolérée le temps que WalkSpeed 0 aille au client et revienne
local TRANSITION_S = 1 -- une baisse de vitesse n'est exigée qu'après 1 s (réplication)
local LATENCE_S = 0.5 -- ajoutée à toute fenêtre d'envol
local ENVOL_MAX_S = 5
local VITESSE_LIBRE = 70 -- studs/s tolérés en envol et en ZoneGlisse
local SOL_MAX = 6 -- studs racine -> sol au-delà desquels on est « en l'air »
local MARGE_SAUT = 6 -- saut depuis un Muret : rien ne dépasse 6 studs près de la Maison
local AIR_MAX = 1.2 -- s en l'air, hors chute, avant correction
local RAYON_SOL = 160 -- rien touché = sol introuvable, jamais une faute
local ALTITUDE_MAX = 150 -- studs au-dessus de CentrePlace : vol, même sans sol
local MARGE_BARRIERE = 4 -- RayonPlace = Plan.RAYON_BARRIERE + 4 (76 sur la Prairie)
local RAYON_GRIMPE = 3 -- Climbing n'est cru qu'à 3 studs d'une Part collidable
local IMMOBILE_S = 2 -- DemandeDeblocage : immobile depuis 2 s

local function lireMouvement(): { [string]: any }
	local config = ReplicatedStorage:FindFirstChild("Config")
	local module = config and config:FindFirstChild("Mouvement")
	if module and module:IsA("ModuleScript") then
		local ok, valeurs = pcall(require, module)
		if ok and type(valeurs) == "table" then
			return valeurs
		end
	end
	warn("[AntiExploit] ReplicatedStorage.Config.Mouvement illisible : valeurs de StarterPlayer utilisées")
	return {}
end

local Mouvement = lireMouvement()
local VITESSE_BASE: number = tonumber(Mouvement.WalkSpeed) or StarterPlayer.CharacterWalkSpeed
local SAUT: number = tonumber(Mouvement.JumpHeight) or StarterPlayer.CharacterJumpHeight

type Suivi = {
	derniere: Vector3?,
	budget: number,
	vitesse: number,
	vitessePrecedente: number,
	transitionJusqua: number,
	grace: number,
	air: number,
	etourdiJusqua: number,
	envolJusqua: number,
	ancre: Vector3?,
	ancreT: number,
	corrections: number,
}

local GardienMouvement = {}
local suivis: { [Player]: Suivi } = {}
local vitesseCourante = VITESSE_BASE -- appliquée aux Survivants qui arrivent en cours de run

local typePlace = workspace:GetAttribute("TypePlace")
local centre: Vector3 = workspace:GetAttribute("CentrePlace") or Vector3.zero
local rayonPlace: number? = nil
local racineCarte: Instance? = nil
local racineResolue = false
local enAttente: { thread } = {}

local parametres = RaycastParams.new()
parametres.FilterType = Enum.RaycastFilterType.Include
local parametresGrimpe = OverlapParams.new()
parametresGrimpe.FilterType = Enum.RaycastFilterType.Exclude
parametresGrimpe.RespectCanCollide = true
parametresGrimpe.MaxParts = 1

local function suivi(joueur: Player): Suivi
	local s = suivis[joueur]
	if not s then
		s = {
			derniere = nil,
			budget = vitesseCourante * BUDGET_S,
			vitesse = vitesseCourante,
			vitessePrecedente = vitesseCourante,
			transitionJusqua = 0,
			grace = 0.5,
			air = 0,
			etourdiJusqua = 0,
			envolJusqua = 0,
			ancre = nil,
			ancreT = os.clock(),
			corrections = 0,
		}
		suivis[joueur] = s
	end
	return s
end

local function vitesseEffective(s: Suivi, t: number): number
	return if t < s.transitionJusqua then math.max(s.vitesse, s.vitessePrecedente) else s.vitesse
end

local function plafond(s: Suivi, v: number, t: number): number
	return if t < s.etourdiJusqua then v * ETOURDI_BUDGET_S else v * BUDGET_S
end

local function humanoideDe(joueur: Player): Humanoid?
	local personnage = joueur.Character
	return if personnage then personnage:FindFirstChildOfClass("Humanoid") else nil
end

-- Seule écriture de WalkSpeed et JumpHeight du jeu.
local function appliquer(joueur: Player, s: Suivi)
	local h = humanoideDe(joueur)
	if h then
		local etourdi = os.clock() < s.etourdiJusqua
		h.UseJumpPower = false
		h.WalkSpeed = if etourdi then 0 else s.vitesse
		h.JumpHeight = if etourdi then 0 else SAUT
	end
end

local function dansVolume(tag: string, pos: Vector3, marge: number, ignorerY: boolean): boolean
	for _, part in CollectionService:GetTagged(tag) do
		if part:IsA("BasePart") then
			local p = part.CFrame:PointToObjectSpace(pos)
			local demi = part.Size / 2 + Vector3.one * marge
			if math.abs(p.X) <= demi.X and math.abs(p.Z) <= demi.Z and (ignorerY or math.abs(p.Y) <= demi.Y) then
				return true
			end
		end
	end
	return false
end

-- Prairie : disque de RayonPlace (76). Laboratoire : union des Parts ZoneJouable (a11), 2 studs de marge.
local function horsZone(pos: Vector3): boolean
	if typePlace == "Laboratoire" then
		return #CollectionService:GetTagged("ZoneJouable") > 0 and not dansVolume("ZoneJouable", pos, 2, true)
	end
	local r = rayonPlace
	return r ~= nil and Vector3.new(pos.X - centre.X, 0, pos.Z - centre.Z).Magnitude > r
end

-- L'état Climbing vient du client : il n'est cru que contre une Part collidable (Grimpe du Colosse, échelle).
local function grimpe(h: Humanoid, personnage: Model, pos: Vector3): boolean
	if h:GetState() ~= Enum.HumanoidStateType.Climbing then
		return false
	end
	parametresGrimpe.FilterDescendantsInstances = { personnage }
	return #workspace:GetPartBoundsInRadius(pos, RAYON_GRIMPE, parametresGrimpe) > 0
end

local function corriger(joueur: Player, personnage: Model, racine: BasePart, s: Suivi, raison: string, points: number)
	local t = os.clock()
	racine.AssemblyLinearVelocity = Vector3.zero
	personnage:PivotTo(CFrame.new(s.derniere or racine.Position) * racine.CFrame.Rotation)
	s.budget = plafond(s, vitesseEffective(s, t), t)
	s.air = 0
	s.grace = 0.5 -- le temps que la correction atteigne le client
	s.corrections += 1
	Validation.signaler(joueur, points, raison) -- 0 point : correction seule
end

-- Seule téléportation serveur autorisée (arrivée, sauvetage, Capsule, déblocage) : sinon le gardien la corrige.
function GardienMouvement.teleporter(joueur: Player, cible: CFrame)
	local s = suivi(joueur)
	local t = os.clock()
	s.derniere = cible.Position
	s.budget = plafond(s, vitesseEffective(s, t), t)
	s.air = 0
	s.grace = 1
	s.ancre, s.ancreT = cible.Position, t
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if personnage and racine and racine:IsA("BasePart") then
		racine.AssemblyLinearVelocity = Vector3.zero
		personnage:PivotTo(cible)
	end
end

-- Ressorts, Tuyauterie (a12) et tout recul serveur : vol ignoré, 70 studs/s tolérés pendant duree + 0,5 s.
-- Appel serveur uniquement : aucun remote n'y mène.
function GardienMouvement.accorderEnvol(joueur: Player, duree: number)
	local s = suivi(joueur)
	local d = if duree == duree then math.clamp(duree, 0, ENVOL_MAX_S) else 0
	s.envolJusqua = math.max(s.envolJusqua, os.clock() + d + LATENCE_S)
	s.air = 0
end

local function controler(joueur: Player, s: Suivi, dt: number)
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	local h = personnage and personnage:FindFirstChildOfClass("Humanoid")
	if not personnage or not racine or not racine:IsA("BasePart") or not h then
		return
	end
	if s.grace > 0 then
		s.grace -= dt
		return
	end
	local pos, t = racine.Position, os.clock()
	local derniere = s.derniere
	if not derniere or h.SeatPart then -- assis dans une Capsule : le serveur déplace le siège
		s.derniere, s.air = pos, 0
		return
	end
	if pos.Y < centre.Y - 20 then -- chute sous la carte : sauvetage sans points
		GardienMouvement.teleporter(joueur, CFrame.new(derniere + Vector3.new(0, 3, 0)))
		return
	end
	local libre = t < s.envolJusqua or dansVolume("ZoneGlisse", pos, 2, false)

	-- 1. Budget de distance : absorbe les paquets groupés, épuise les hacks de vitesse
	local v = if libre then math.max(vitesseEffective(s, t), VITESSE_LIBRE) else vitesseEffective(s, t)
	local gain = if t < s.etourdiJusqua and not libre then 0 else v * dt * MARGE
	local deplacement = Vector3.new(pos.X - derniere.X, 0, pos.Z - derniere.Z).Magnitude
	s.budget = math.min(plafond(s, v, t), s.budget + gain) - deplacement
	if s.budget < 0 then
		return corriger(joueur, personnage, racine, s, "Vitesse", if deplacement > 30 then 8 else 4)
	end

	-- 2. Zone : une barrière physique arrête déjà les honnêtes, une sortie est corrigée sans points
	if horsZone(pos) then
		return corriger(joueur, personnage, racine, s, "HorsZone", 0)
	end
	if dansVolume("ZoneInterdite", pos, -1, false) then
		return corriger(joueur, personnage, racine, s, "Traversee", 6)
	end

	-- 3. Vol : ignoré en envol, en ZoneGlisse et en Climbing contre une Part ; sol introuvable = aucune faute
	if libre or grimpe(h, personnage, pos) then
		s.air = 0
	else
		local sol = if racineCarte then workspace:Raycast(pos, Vector3.new(0, -RAYON_SOL, 0), parametres) else nil
		local hauteur = if sol then pos.Y - sol.Position.Y else 0
		local chute = pos.Y < derniere.Y - 0.5
		local solAbsolu = h.HipHeight + racine.Size.Y / 2 + SAUT + MARGE_SAUT
		s.air = if hauteur > SOL_MAX and not chute then s.air + dt else 0
		if pos.Y - centre.Y > ALTITUDE_MAX or (hauteur > solAbsolu and not chute) or s.air > AIR_MAX then
			return corriger(joueur, personnage, racine, s, "Vol", 6)
		end
	end

	if not s.ancre or (pos - s.ancre).Magnitude > 3 then
		s.ancre, s.ancreT = pos, t
	end
	s.derniere = pos
end

-- Un coup de Zbire : 2 s à WalkSpeed 0 et JumpHeight 0, budget ramené à 1 s de course.
function GardienMouvement.etourdir(joueur: Player)
	local s = suivi(joueur)
	local t = os.clock()
	s.etourdiJusqua = t + ETOURDI_S
	s.budget = math.min(s.budget, vitesseEffective(s, t) * ETOURDI_BUDGET_S)
	appliquer(joueur, s)
	task.delay(ETOURDI_S, function()
		if suivis[joueur] == s and os.clock() >= s.etourdiJusqua then
			appliquer(joueur, s)
		end
	end)
end

function GardienMouvement.estEtourdi(joueur: Player): boolean
	local s = suivis[joueur]
	return s ~= nil and os.clock() < s.etourdiJusqua
end

-- Sans joueur : tous les Survivants et ceux qui arrivent (Répit : definirVitesse(24)).
-- Une baisse n'est exigée par le budget qu'après TRANSITION_S, le temps que le client la reçoive.
function GardienMouvement.definirVitesse(vitesse: number, joueur: Player?)
	assert(type(vitesse) == "number" and vitesse >= 0 and vitesse <= 100, "definirVitesse : vitesse invalide")
	if joueur == nil then
		vitesseCourante = vitesse
		for _, j in Players:GetPlayers() do
			GardienMouvement.definirVitesse(vitesse, j)
		end
		return
	end
	local s = suivi(joueur)
	local t = os.clock()
	s.vitessePrecedente = vitesseEffective(s, t)
	s.transitionJusqua = t + TRANSITION_S
	s.vitesse = vitesse
	appliquer(joueur, s)
end

-- DemandeDeblocage : accepté seulement si le Survivant est immobile depuis 2 s et non étourdi.
function GardienMouvement.debloquer(joueur: Player): boolean
	local s = suivis[joueur]
	local t = os.clock()
	local p = s and s.derniere
	if not s or not p or t < s.etourdiJusqua or t - s.ancreT < IMMOBILE_S then
		return false
	end
	local cible: BasePart? = nil
	for _, point in CollectionService:GetTagged("PointDeblocage") do
		if point:IsA("BasePart") and (cible == nil or (point.Position - p).Magnitude < (cible.Position - p).Magnitude) then
			cible = point
		end
	end
	GardienMouvement.teleporter(joueur, if cible then cible.CFrame + Vector3.new(0, 3, 0) else CFrame.new(p + Vector3.new(0, 4, 0)))
	return true
end

-- Dernière position validée : la seule à utiliser pour toute distance de gameplay.
function GardienMouvement.positionSure(joueur: Player): Vector3?
	local s = suivis[joueur]
	return if s then s.derniere else nil
end

function GardienMouvement.aPortee(joueur: Player, cible: Vector3, portee: number): boolean
	local p = GardienMouvement.positionSure(joueur)
	return p ~= nil and Vector3.new(cible.X - p.X, 0, cible.Z - p.Z).Magnitude <= portee
end

-- Tests d'acceptation : nombre de corrections depuis l'arrivée du Survivant.
function GardienMouvement.corrections(joueur: Player): number
	local s = suivis[joueur]
	return if s then s.corrections else 0
end

-- Dossier racine de la carte (nil si introuvable après 10 s). Peut céder : appeler depuis une tâche.
function GardienMouvement.attendreRacine(): Instance?
	if not racineResolue then
		table.insert(enAttente, coroutine.running())
		coroutine.yield()
	end
	return racineCarte
end

local function surPersonnage(joueur: Player, personnage: Model)
	local s = suivi(joueur)
	s.derniere, s.ancre = nil, nil
	s.grace, s.air, s.etourdiJusqua, s.envolJusqua = 0.5, 0, 0, 0
	s.budget = s.vitesse * BUDGET_S
	if personnage:WaitForChild("Humanoid", 5) then
		appliquer(joueur, s)
	end
end

local function surJoueur(joueur: Player)
	suivi(joueur)
	joueur.CharacterAdded:Connect(function(personnage)
		surPersonnage(joueur, personnage)
	end)
	local personnage = joueur.Character
	if personnage then
		task.spawn(surPersonnage, joueur, personnage)
	end
end

Players.PlayerAdded:Connect(surJoueur)
for _, joueur in Players:GetPlayers() do
	surJoueur(joueur)
end
Players.PlayerRemoving:Connect(function(joueur)
	suivis[joueur] = nil
end)

-- Racine de la carte et rayon de zone, lus dans ReplicatedStorage.Plan (a11) sans jamais bloquer le require.
task.spawn(function()
	local module = ReplicatedStorage:WaitForChild("Plan", 10)
	local ok: boolean, plan: any = false, nil
	if module and module:IsA("ModuleScript") then
		ok, plan = pcall(require, module)
	end
	if not ok or type(plan) ~= "table" then
		warn("[AntiExploit] ReplicatedStorage.Plan illisible : contrôles de sol et de rayon désactivés")
		plan = {}
	end
	if typePlace == "Prairie" then
		local barriere = tonumber(plan.RAYON_BARRIERE)
		if barriere then
			rayonPlace = barriere + MARGE_BARRIERE
		else
			warn("[AntiExploit] Plan.RAYON_BARRIERE absent : contrôle de zone désactivé")
		end
	end
	local nom = plan.RACINE
	local dossier = if type(nom) == "string" then workspace:WaitForChild(nom, 10) else nil
	if dossier then
		racineCarte = dossier
		parametres.FilterDescendantsInstances = { dossier }
	else
		warn(string.format("[AntiExploit] Workspace.%s introuvable : contrôle de sol désactivé", tostring(nom)))
	end
	racineResolue = true
	for _, fil in enAttente do
		task.spawn(fil)
	end
	table.clear(enAttente)
end)

task.spawn(function()
	while true do
		local dt = task.wait(PERIODE)
		for joueur, s in suivis do
			if joueur.Parent then
				controler(joueur, s, dt)
			else
				suivis[joueur] = nil -- entrée recréée après départ par un appel tardif du gameplay
			end
		end
	end
end)

return GardienMouvement
```

### a29/ReglesRemotes.lua
```lua
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
```

### a29/Validation.lua
```lua
-- ServerScriptService.Securite.Validation (ModuleScript)
--!strict
-- Seul créateur de remotes du jeu : construit ReplicatedStorage.Remotes depuis ReplicatedStorage.ReglesRemotes,
-- valide nombre, débit, format et cohérence de chaque demande, tient le score de suspicion de chaque Survivant.
-- Le contexte (distance, solde, cadence) reste chez le propriétaire du système.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = game:GetService("AnalyticsService")

local ReglesRemotes = require(ReplicatedStorage:WaitForChild("ReglesRemotes", 10) :: any) :: any

local SEUIL_EXCLUSION = 40
local DECROISSANCE = 1 / 3 -- points perdus par seconde
local TEXTE_MAX = 32
local MESSAGE = "Zsurvie a perdu la synchronisation avec ton appareil. Relance le jeu pour retrouver le Laboratoire !"

type Seau = { jetons: number, maj: number }
type Score = { points: number, maj: number, cumul: number }

local Validation = {}
local seaux: { [Player]: { [string]: Seau } } = {}
local scores: { [Player]: Score } = {}
local exclus: { [Player]: boolean } = {}
local branches: { [string]: boolean } = {}

local typePlace = workspace:GetAttribute("TypePlace")
assert(typePlace == "Prairie" or typePlace == "Laboratoire", "Attribut Workspace.TypePlace manquant")

local function fini(n: number): boolean
	return n == n and math.abs(n) ~= math.huge
end

local function verifier(v: any, arg: any): boolean
	if v == nil then
		return arg.optionnel == true
	elseif arg.type == "nombre" then
		return typeof(v) == "number" and fini(v) and (not arg.entier or v % 1 == 0)
			and v >= (arg.min or -math.huge) and v <= (arg.max or math.huge)
	elseif arg.type == "texte" then
		return typeof(v) == "string" and #v <= TEXTE_MAX and table.find(arg.valeurs or {}, v) ~= nil
	elseif arg.type == "booleen" then
		return typeof(v) == "boolean"
	elseif arg.type == "scalaire" then
		return typeof(v) == "boolean" or (typeof(v) == "number" and fini(v))
	elseif arg.type == "vecteur" then
		return typeof(v) == "Vector3" and fini(v.X) and fini(v.Y) and fini(v.Z)
			and Vector3.new(v.X, 0, v.Z).Magnitude <= (arg.rayon or 0) and math.abs(v.Y) <= 50
	end
	return false
end

function Validation.signaler(joueur: Player, points: number, raison: string)
	if exclus[joueur] or points <= 0 then
		return
	end
	local t = os.clock()
	local s = scores[joueur] or { points = 0, maj = t, cumul = 0 }
	s.points = math.max(0, s.points - (t - s.maj) * DECROISSANCE) + points
	s.maj = t
	s.cumul += points
	scores[joueur] = s
	if points >= 2 then
		warn(string.format("[AntiExploit] %s (%d) %s +%g = %.1f", joueur.Name, joueur.UserId, raison, points, s.points))
		pcall(function()
			AnalyticsService:LogCustomEvent(joueur, "AE_" .. raison, points)
		end)
	end
	if s.points >= SEUIL_EXCLUSION then
		exclus[joueur] = true
		joueur:Kick(MESSAGE)
	end
end

-- Tests d'acceptation : score courant (après décroissance) et total des points reçus depuis l'arrivée.
function Validation.bilan(joueur: Player): (number, number)
	local s = scores[joueur]
	if not s then
		return 0, 0
	end
	return math.max(0, s.points - (os.clock() - s.maj) * DECROISSANCE), s.cumul
end

function Validation.consommer(joueur: Player, cle: string, debit: number, rafale: number): boolean
	local parJoueur = seaux[joueur]
	if not parJoueur then
		parJoueur = {}
		seaux[joueur] = parJoueur
	end
	local t = os.clock()
	local seau = parJoueur[cle] or { jetons = rafale, maj = t }
	seau.jetons = math.min(rafale, seau.jetons + (t - seau.maj) * debit)
	seau.maj = t
	parJoueur[cle] = seau
	if seau.jetons < 1 then
		return false
	end
	seau.jetons -= 1
	return true
end

-- Création des remotes de la place ; les remotes descendantes deviennent des pièges.
local dossier = Instance.new("Folder")
dossier.Name = "Remotes"
for nom, regle in ReglesRemotes.remotes do
	if regle.place == typePlace or regle.place == "Toutes" then
		local remote: any = if regle.nonFiable then Instance.new("UnreliableRemoteEvent") else Instance.new("RemoteEvent")
		remote.Name = nom
		if regle.descendant then
			remote.OnServerEvent:Connect(function(joueur: Player)
				Validation.signaler(joueur, 20, "RemoteDescendante")
			end)
		end
		remote.Parent = dossier
	end
end
dossier.Parent = ReplicatedStorage

-- Seul point d'entrée des demandes client : une connexion par remote, sinon double effet.
function Validation.brancher(nom: string, traitement: (Player, ...any) -> ())
	local regle = ReglesRemotes.remotes[nom]
	assert(regle and not regle.descendant, "Remote montante inconnue : " .. nom)
	assert(not branches[nom], "Remote déjà branchée : " .. nom)
	local remote = dossier:FindFirstChild(nom)
	assert(remote and remote:IsA("RemoteEvent"), "Remote absente de cette place : " .. nom)
	branches[nom] = true
	local nbArgs = #regle.args
	remote.OnServerEvent:Connect(function(joueur: Player, ...: any)
		if exclus[joueur] then
			return
		end
		if select("#", ...) > nbArgs then
			Validation.signaler(joueur, 10, "ArgsEnTrop")
			return
		end
		if not Validation.consommer(joueur, nom, regle.debit, regle.rafale) then
			Validation.signaler(joueur, 0.5, "Flood")
			return
		end
		for i, arg in regle.args do
			if not verifier((select(i, ...)), arg) then
				Validation.signaler(joueur, 10, "Format")
				return
			end
		end
		if regle.coherence and not regle.coherence(...) then
			Validation.signaler(joueur, 10, "Format")
			return
		end
		traitement(joueur, ...)
	end)
end

-- Remote descendante pour Reseau (a27) : EtatHorde, PingDiffuse (FireClient, FireAllClients).
function Validation.remote(nom: string): Instance
	local regle = ReglesRemotes.remotes[nom]
	assert(regle and regle.descendant, "Remote descendante inconnue : " .. nom)
	local remote = dossier:FindFirstChild(nom)
	assert(remote, "Remote absente de cette place : " .. nom)
	return remote
end

Players.PlayerRemoving:Connect(function(joueur)
	seaux[joueur] = nil
	scores[joueur] = nil
	exclus[joueur] = nil
end)

return Validation
```

### a30/AuditeurPixelBloc.server.lua
```lua
-- Emplacement Roblox : plugin local Studio (dossier Plugins), Script « AuditeurPixelBloc »
-- Auditeur Pixel-bloc v2 (Zsurvie) : Charte, budgets du canon et Zbires ; « Corriger » recale couleurs et Rate.
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local B = { PartsPrairie = 6500, PartsLabo = 10000, PartsArene = 10000, Neon = 150, Lumieres = 12, Rate = 20,
	Emetteurs = 24, Smooth = 0.9, Hauteur = 6, Rayon = 60, DemiArene = 110, DemiCadre = 150, Horde = 60,
	PartsZbire = 6, PartsColosse = 30, NeonColosse = 4,
	Reserve = 30 + 450 + 240 + 300 } -- Colosse, défenses, avatars, pièces et effets
local TYPES = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local CANON = { Encre = "1E1B2E", Prairie = "6CC24A", TerreBattue = "C8894F", Creme = "F6E7C1", ToitOrange = "EF7A2F",
	Or = "FFC933", GemmeCyan = "33D6F0", VioletHorde = "9B5DE5", Alerte = "FF2E63", NuitLabo = "2A3263", Ardoise = "4A4560" }
local API = { Couleurs = "table", teinte = "function", Interface = "table", Ambiances = "table" }
local TOLERANCE = 0.0003 -- écart RVB² toléré (arrondi Color3uint8)
local CREME = Color3.fromHex(CANON.Creme)
local dernier = { couleurs = {}, emetteurs = {} }

local function ombre(c: Color3): Color3
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end

local TEINTES = {} -- 33 teintes autorisées : base, ombre (× 0,8), lumière (Lerp Crème 0,2)
for _, hex in CANON do
	local c = Color3.fromHex(hex)
	table.insert(TEINTES, c)
	table.insert(TEINTES, ombre(c))
	table.insert(TEINTES, c:Lerp(CREME, 0.2))
end

-- ReplicatedStorage.Charte : 4 clés exactement, 11 couleurs du canon, teinte() exacte
local function charteConforme(): boolean
	local module = ReplicatedStorage:FindFirstChild("Charte")
	if not (module and module:IsA("ModuleScript")) then return false end
	local copie = module:Clone() -- contourne le cache de require
	local ok, charte = pcall(require, copie)
	copie:Destroy()
	if not ok or type(charte) ~= "table" then return false end
	for cle, v in charte do
		if API[cle] ~= type(v) then return false end
	end
	for cle, attendu in API do
		if type(rawget(charte, cle)) ~= attendu then return false end
	end
	local nb = 0
	for nom, c in charte.Couleurs do
		nb += 1
		if typeof(c) ~= "Color3" or CANON[nom] ~= c:ToHex():upper() then return false end
	end
	local a = Color3.fromHex(CANON.Alerte)
	for variante, attendu in { Ombre = ombre(a), Lumiere = a:Lerp(CREME, 0.2) } do
		local okT, t = pcall(charte.teinte, "Alerte", variante)
		if not okT or typeof(t) ~= "Color3" or t:ToHex() ~= attendu:ToHex() then return false end
	end
	return nb == 11
end

local function sommetY(p: BasePart): number -- sommet de la boîte englobante, même pivotée
	local cf, d = p.CFrame, p.Size / 2
	return cf.Y + math.abs(cf.RightVector.Y) * d.X + math.abs(cf.UpVector.Y) * d.Y + math.abs(cf.LookVector.Y) * d.Z
end

local function horsArene(inst: Instance): boolean -- tag HorsArene sur la Part ou un ancêtre (Canopée de a16)
	local i: Instance? = inst
	while i and i ~= workspace do
		if i:HasTag("HorsArene") then return true end
		i = i.Parent
	end
	return false
end

local function auditer()
	if not RunService:IsEdit() then return warn("[Auditeur] Auditer : mode édition uniquement.") end
	local maison = workspace:FindFirstChild("Maison")
	local prairie = maison ~= nil and maison:IsA("Model")
	local centre, solY = Vector3.zero, 0
	if prairie then
		local cf, taille = (maison :: Model):GetBoundingBox()
		centre, solY = cf.Position, cf.Y - taille.Y / 2
	end
	local outillage = ServerStorage:FindFirstChild("Outillage")
	local gabarit = outillage and outillage:FindFirstChild("Gabarit")
	local n = { parts = 0, smooth = 0, neon = 0, lumieres = 0, actifs = 0, hauts = 0, hors = 0 }
	local neonZone, fautifs, couleurs, emetteurs = {}, {}, {}, {}

	local function controlerCouleur(p: BasePart)
		local c, cible, ecart = p.Color, nil, math.huge
		for _, t in TEINTES do
			local e = (c.R - t.R) ^ 2 + (c.G - t.G) ^ 2 + (c.B - t.B) ^ 2
			if e < ecart then cible, ecart = t, e end
		end
		if ecart > TOLERANCE then table.insert(couleurs, { p, cible }) end
	end

	-- Zone = enfant de Workspace ou de Workspace.Decor (Decor.Lisiere compte dans « Lisiere »)
	local racines = {}
	for _, enfant in workspace:GetChildren() do
		if enfant.Name == "Decor" then
			for _, z in enfant:GetChildren() do table.insert(racines, z) end
		elseif not (enfant:IsA("Terrain") or enfant:IsA("Camera")) then
			table.insert(racines, enfant)
		end
	end
	for _, racine in racines do
		local zone, liste, controle = racine.Name, racine:GetDescendants(), prairie and racine ~= maison
		table.insert(liste, racine)
		for _, inst in liste do
			if inst:IsA("BasePart") then
				n.parts += 1
				if inst.Material == Enum.Material.SmoothPlastic then n.smooth += 1 end
				if inst.Material == Enum.Material.Neon then
					n.neon += 1
					neonZone[zone] = (neonZone[zone] or 0) + 1
				end
				controlerCouleur(inst)
				if controle then
					local dx, dz = inst.Position.X - centre.X, inst.Position.Z - centre.Z
					local ecart = math.max(math.abs(dx), math.abs(dz))
					if math.sqrt(dx * dx + dz * dz) < B.Rayon and sommetY(inst) - solY > B.Hauteur then
						n.hauts += 1
						table.insert(fautifs, inst)
					elseif ecart > B.DemiArene and (ecart > B.DemiCadre or not horsArene(inst)) then
						n.hors += 1
						table.insert(fautifs, inst)
					end
				end
			elseif inst:IsA("Light") then -- PointLight, SpotLight et SurfaceLight
				n.lumieres += 1
			elseif inst:IsA("ParticleEmitter") then
				if inst.Enabled then n.actifs += 1 end
				if inst.Rate > B.Rate then
					table.insert(emetteurs, inst)
					table.insert(fautifs, inst)
				end
			end
		end
	end

	-- Zbires : chemin unique ReplicatedStorage.Modeles.Zbires, les 10 types obligatoires
	local modeles = ReplicatedStorage:FindFirstChild("Modeles")
	local dossier = modeles and modeles:FindFirstChild("Zbires")
	local manquants, zbiresKO, pireZbire = {}, {}, 0
	for _, nom in TYPES do
		local modele = dossier and dossier:FindFirstChild(nom)
		if not (modele and modele:IsA("Model")) then
			table.insert(manquants, nom)
			continue
		end
		local colosse, nb, mesh, neon, drapeaux, defauts = nom == "Colosse", 0, 0, 0, false, {}
		for _, d in modele:GetDescendants() do
			if d:IsA("BasePart") then
				nb += 1
				if d:IsA("MeshPart") then mesh += 1 end
				if d.Material == Enum.Material.Neon then neon += 1 end
				drapeaux = drapeaux or d.CastShadow or d.CanCollide or d.CanQuery or d.CanTouch
				controlerCouleur(d)
			elseif d:IsA("Humanoid") or d:IsA("Animator") or d:IsA("Light") or d:IsA("ParticleEmitter")
				or d:IsA("LuaSourceContainer") then
				table.insert(defauts, d.ClassName)
			end
		end
		local racine = modele.PrimaryPart
		if not (racine and racine.Name == "Racine" and racine.Anchored and racine.Transparency == 1) then
			table.insert(defauts, "Racine")
		end
		if nb > (if colosse then B.PartsColosse else B.PartsZbire) then table.insert(defauts, nb .. " Parts") end
		if mesh < 3 or (not colosse and mesh > 5) then table.insert(defauts, mesh .. " MeshParts") end
		if neon > (if colosse then B.NeonColosse else 0) then table.insert(defauts, neon .. " Neon") end
		if drapeaux then table.insert(defauts, "CastShadow/CanCollide/CanQuery/CanTouch") end
		if not colosse then pireZbire = math.max(pireZbire, nb) end
		if #defauts > 0 then
			table.insert(zbiresKO, ("%s (%s)"):format(nom, table.concat(defauts, ", ")))
			table.insert(fautifs, modele)
		end
	end
	local okLien, auto = pcall(function()
		return (dossier :: any):FindFirstChildWhichIsA("PackageLink").AutoUpdate
	end)

	local bloquants = 0
	local function regle(ok: boolean, bloquant: boolean, texte: string)
		if ok then return print("  OK     " .. texte) end
		if bloquant then bloquants += 1 end
		warn((if bloquant then "  KO     " else "  AVERT  ") .. texte)
	end
	local plafond = if prairie
		then math.min(gabarit and gabarit:GetAttribute("PartsStatiques") or B.PartsPrairie, B.PartsPrairie)
		else B.PartsLabo
	local smooth = if n.parts > 0 then n.smooth / n.parts else 1
	print(("[Auditeur Pixel-bloc v2] %s, profil %s"):format(game.Name, if prairie then "Prairie" else "Laboratoire"))
	regle(charteConforme(), true, "Charte : Couleurs (11 du canon), teinte(), Interface, Ambiances, rien d'autre")
	regle(gabarit ~= nil, true, "ServerStorage.Outillage.Gabarit présent")
	regle(n.parts <= plafond, true, ("Parts statiques %d / %d"):format(n.parts, plafond))
	regle(n.neon <= B.Neon, true, ("Neon %d / %d"):format(n.neon, B.Neon))
	for zone, nb in neonZone do
		local budget = gabarit and gabarit:GetAttribute("Neon_" .. zone) or 0
		regle(nb <= budget, true, ("Neon %s %d / %d (Gabarit)"):format(zone, nb, budget))
	end
	regle(n.lumieres <= B.Lumieres, true, ("Lumières toutes classes %d / %d"):format(n.lumieres, B.Lumieres))
	regle(n.actifs <= B.Emetteurs, true, ("ParticleEmitter Enabled %d / %d"):format(n.actifs, B.Emetteurs))
	regle(#emetteurs == 0, true, ("Rate > 20 : %d émetteur(s), corrigeable"):format(#emetteurs))
	regle(#couleurs == 0, true, ("Hors palette : %d Part(s), corrigeable"):format(#couleurs))
	regle(smooth >= B.Smooth, true, ("SmoothPlastic %d %%, minimum 90"):format(math.floor(smooth * 100)))
	regle(workspace.Terrain:CountCells() == 0, true, "Terrain:CountCells() = 0")
	regle(#manquants == 0, true, "Modeles.Zbires, types manquants : " .. table.concat(manquants, ", "))
	regle(#zbiresKO == 0, true, "Format Forge : " .. table.concat(zbiresKO, " ; "))
	regle(ReplicatedStorage:FindFirstChild("Zbires") == nil, true, "Ancien dossier ReplicatedStorage.Zbires supprimé")
	regle(okLien and auto == true, false, "Modeles.Zbires en Package AutoUpdate")
	if prairie then
		local pire = if pireZbire > 0 then pireZbire else B.PartsZbire
		local pic = n.parts + B.Horde * pire + B.Reserve
		regle(n.hauts == 0, true, ("Plus de 6 studs à moins de 60 de la Maison : %d"):format(n.hauts))
		regle(n.hors == 0, true, ("Hors arène ± 110 (HorsArene ± 150) : %d"):format(n.hors))
		regle(not workspace.StreamingEnabled, true, "StreamingEnabled désactivé")
		regle(pic <= B.PartsArene, true,
			("Pic %d / %d = statique + 60 × %d + 30 + 450 + 240 + 300"):format(pic, B.PartsArene, pire))
	end
	print(("[Auditeur] %d bloquant(s)%s"):format(bloquants, if bloquants == 0 then " : publiable." else ", fautifs sélectionnés."))
	Selection:Set(fautifs)
	dernier = { couleurs = couleurs, emetteurs = emetteurs }
end

local function corriger()
	if not RunService:IsEdit() then return warn("[Auditeur] Corriger : mode édition uniquement.") end
	local id = ChangeHistoryService:TryBeginRecording("Corriger Pixel-bloc")
	if not id then return warn("[Auditeur] Enregistrement impossible, réessaie.") end
	local total = 0
	for _, paire in dernier.couleurs do
		if paire[1].Parent then paire[1].Color, total = paire[2], total + 1 end
	end
	for _, emetteur in dernier.emetteurs do
		if emetteur.Parent then emetteur.Rate, total = B.Rate, total + 1 end
	end
	ChangeHistoryService:FinishRecording(id, Enum.FinishRecordingOperation.Commit)
	dernier = { couleurs = {}, emetteurs = {} }
	print(("[Auditeur] %d correction(s), Ctrl+Z pour annuler. Relance « Auditer »."):format(total))
end

local barre = plugin:CreateToolbar("Zsurvie Outillage")
for _, def in { { "Auditer", "Charte Pixel-bloc, budgets du canon et Zbires", auditer },
	{ "Corriger", "Couleurs sur les 33 teintes, Rate à 20", corriger } } do
	local bouton = barre:CreateButton(def[1], def[2], "")
	bouton.ClickableWhenViewportHidden = true
	bouton.Click:Connect(function()
		bouton:SetActive(false)
		def[3]()
	end)
end
```

### a30/Charte.lua
```lua
-- Emplacement Roblox : ReplicatedStorage > ModuleScript « Charte » (Package AutoUpdate, Laboratoire et Prairie)
-- Charte Pixel-bloc de Zsurvie : seule source des couleurs, de l'interface et des ambiances.
-- Chargement unique : require(game:GetService("ReplicatedStorage"):WaitForChild("Charte"))
export type Variante = "Base" | "Ombre" | "Lumiere"

local Couleurs = {
	Encre = Color3.fromHex("1E1B2E"),
	Prairie = Color3.fromHex("6CC24A"),
	TerreBattue = Color3.fromHex("C8894F"),
	Creme = Color3.fromHex("F6E7C1"),
	ToitOrange = Color3.fromHex("EF7A2F"),
	Or = Color3.fromHex("FFC933"),
	GemmeCyan = Color3.fromHex("33D6F0"),
	VioletHorde = Color3.fromHex("9B5DE5"),
	Alerte = Color3.fromHex("FF2E63"),
	NuitLabo = Color3.fromHex("2A3263"),
	Ardoise = Color3.fromHex("4A4560"),
}

-- 33 teintes : ombre = base × 0,8 ; lumière = base:Lerp(Creme, 0.2)
local teintes = {}
for nom, base in Couleurs do
	teintes[nom] = {
		Base = base,
		Ombre = Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8),
		Lumiere = base:Lerp(Couleurs.Creme, 0.2),
	}
end

local function teinte(nom: string, variante: Variante): Color3
	local c = teintes[nom] and teintes[nom][variante]
	if not c then
		error(("Charte.teinte : %s/%s inconnue"):format(tostring(nom), tostring(variante)), 2)
	end
	return c
end

-- Interface : valeurs tenues par a31
local Interface = {
	BoutonMin = 60, -- px, minimum canon sur téléphone
	Fond = teinte("NuitLabo", "Base"),
	Panneau = teinte("Creme", "Base"),
	Texte = teinte("Encre", "Base"),
	Action = teinte("ToitOrange", "Base"),
	ActionAppui = teinte("ToitOrange", "Ombre"),
	Pieces = teinte("Or", "Base"),
	Gemmes = teinte("GemmeCyan", "Base"),
	Danger = teinte("Alerte", "Base"),
}

-- Ambiances : propriétés de Lighting appliquées telles quelles ; caméras Scriptable levées
local Ambiances = {
	Laboratoire = {
		ClockTime = 0,
		Brightness = 1,
		Ambient = teinte("NuitLabo", "Lumiere"),
		OutdoorAmbient = teinte("NuitLabo", "Base"),
	},
	Cameras = {
		Prairie = { Decalage = Vector3.new(0, 45, 28), FieldOfView = 50 }, -- canon
		Colosse = { Decalage = Vector3.new(0, 56, 35), FieldOfView = 50 }, -- + 25 % le Jour du Colosse
	},
}

-- Gel récursif ; lire une clé absente (une ancienne API par exemple) lève une erreur explicite
local function geler(t: { [any]: any }, chemin: string)
	for cle, v in t do
		if type(v) == "table" then geler(v, chemin .. "." .. tostring(cle)) end
	end
	setmetatable(t, {
		__index = function(_, cle)
			error(("%s.%s n'existe pas"):format(chemin, tostring(cle)), 2)
		end,
	})
	return table.freeze(t)
end

return geler({ Couleurs = Couleurs, teinte = teinte, Interface = Interface, Ambiances = Ambiances }, "Charte")
```