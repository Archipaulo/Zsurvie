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
