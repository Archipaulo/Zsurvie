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
