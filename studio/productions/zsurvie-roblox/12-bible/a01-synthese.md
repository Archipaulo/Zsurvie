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
