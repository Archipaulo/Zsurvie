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
