# Direction artistique — « style simulateur Roblox »

Référence : le look des grands simulateurs Roblox de 2025-2026 du genre
« Steal a … » (Steal a Brainrot en tête). On reprend leur **grammaire
visuelle**, jamais leurs éléments (noms, logos, images, personnages) : tout
reste propre à Dino Chapardeurs.

La boîte à outils `ReplicatedStorage/Dino/Style.lua` (disponible dans
`ctx.Style`, serveur et client) applique ces règles : **l'utiliser partout**
plutôt que de refaire les réglages à la main.

## 1. Les 7 règles d'or

1. **Tout texte est blanc (ou coloré) et cerné de noir épais.**
   `Style.texte(...)` / `Style.contour(texte, 2.5 à 4)`. Police
   `Style.police` (FredokaOne) ; titres `Style.policeTitre` (LuckiestGuy).
   Jamais de texte fin, gris ou sans contour.
2. **L'argent est vert vif, le revenu jaune.** `Style.couleurs.argent`
   (#5CFF5C) et `Style.couleurs.revenu` (#FFE14D), format `Charte.argent(n)` →
   « $1,2K », `Style.revenu(n)` → « $26/s ». Toujours avec le « $ ».
3. **Les raretés sont des dégradés.** `Style.degradeRarete(texteBlanc, rarete)` :
   gris, bleu, violet, or, rose-rouge ; **Divin = arc-en-ciel animé**,
   **Secret = noir et blanc animé** (animés automatiquement côté client).
4. **Des étiquettes géantes flottent au-dessus du monde.** Chaque dino, chaque
   base, chaque lieu important a un BillboardGui lisible de loin, fait avec
   `Style.etiquette(part, lignes, props)`.
5. **Gros boutons cartoon.** `Style.bouton(parent, { texte, icone, couleur })` :
   dégradé vertical, bordure noire 3 px, coins ronds, grossit au survol,
   s'écrase au clic. Couleurs : vert = acheter/valider, rouge = fermer/danger,
   violet = renaissance, bleu = Dinodex/info, jaune = argent, orange = boutique.
6. **Ça rebondit.** Tout ce qui apparaît fait un `Style.pop(gui)` ; les
   compteurs d'argent sautent à chaque gain ; les notifications arrivent en
   « pop » au centre de l'écran.
7. **Le monde est simple, vif et lisible.** Herbe unie vert vif, allées nettes,
   tapis rouge bien contrasté ; le décor chargé (jungle, volcan) reste en
   périphérie, le centre de jeu reste dégagé. Lumière de plein jour, ciel bleu
   clair, pas de brume sombre.

## 2. Interface (client)

- **Argent** : en bas à gauche, énorme « $1,23M » vert cerné de noir, et
  dessous « +$26/s » jaune, qui saute à chaque gain.
- **Menu gauche** : colonne verticale de gros boutons carrés (≈ 76 x 76)
  avec un emoji géant et un petit libellé dessous : 🛒 Boutique (orange),
  ♻️ Renaissance (violet), 📖 Dinodex (bleu). Ils grossissent au survol.
- **Panneaux** : `Style.panneau(gui, { titre, icone, couleur })` : fenêtre
  centrale sombre (#1E2240) à bordure noire 5 px, bandeau de titre en dégradé,
  gros **X** rouge rond en haut à droite, cartes `Style.carte` à l'intérieur,
  boutons d'achat verts « ACHETER $5K » (gris si trop cher).
- **Notifications** : grand texte cerné au milieu-haut de l'écran, qui pop
  puis s'efface (vert succès, jaune info, rouge alerte, rouge clignotant vol).
- **Bouton Collecter** et actions de base : gros bouton vert en bas au centre
  quand on est chez soi.
- Mobile : les mêmes boutons, plus gros (≥ 64 px), hors du joystick.

## 3. Monde (serveur)

- **Dinos** : étiquette au-dessus de chaque dino (`Style.etiquette`,
  AlwaysOnTop false, MaxDistance ~90), de haut en bas :
  mutation (couleur de mutation, seulement si ≠ Normal) · **NOM** (gros, blanc)
  · rareté (dégradé de rareté) · prix vert « $250 » · revenu jaune « $9/s ».
- **Bases** : nom du propriétaire en ÉNORME texte flottant au-dessus de
  l'entrée (« Base de Testeur », couleur de la base) ; barrière laser Neon rouge
  translucide à l'entrée quand verrouillée, avec compte à rebours flottant
  « 🔒 45s » ; gros bouton rond rouge « VERROUILLER » au sol ; sur chaque podium
  occupé, le stock en vert flottant « $1,2K » ; dalle de collecte verte vif
  avec « 💰 COLLECTER » flottant.
- **Lieux** : titres flottants géants (« BOUTIQUE », « RENAISSANCE »,
  « DINODEX », « NURSERIE ») plutôt que de petits panneaux.
- **Tapis** : rouge vif lisse (#D7263D), rebords sombres, flèches blanches Neon.
- **Couleurs du monde** : herbe #6BD64A, allées sable #F2D49B, pierre claire
  pour les socles, couleurs de base saturées. SmoothPlastic partout, Neon
  seulement pour ce qui brille.

## 4. Version 2 — rendu professionnel

Le monde garde la lisibilité « simulateur » (étiquettes, couleurs de base,
tapis rouge) mais passe au niveau des jeux Roblox les plus soignés :

**Terrain Roblox** (fonctions `Outils.terrainBloc/Boule/Cylindre/Coin`,
`Outils.couleurTerrain`) pour tout ce qui est naturel : sol d'herbe
(`Grass`, avec `workspace.Terrain.Decoration = true`), chemins (`Ground`,
`Sand`), falaises et rochers (`Rock`, `Slate`), volcan (`Basalt`,
`CrackedLava`), rivière (`Water`, `Terrain.WaterColor` turquoise). Ordre des
remplissages : Sol d'abord, puis Falaises, Jungle, Rivière, Volcan (l'eau et la
roche remplacent l'herbe). Dessus du sol à Y = 0.

**Vrais matériaux** sur les parts (jamais tout en SmoothPlastic) :
bois (`Wood`, `WoodPlanks`) pour les structures, `Fabric` pour le tapis rouge,
`Slate`/`Cobblestone`/`Concrete` pour les sols bâtis et socles, `Metal`/
`DiamondPlate` pour les pièces mécaniques, `Brick`/`Plaster` pour les murs,
`Grass`/`LeafyGrass` pour les feuillages, `Glass` pour les vitres,
`Neon` seulement pour les lumières. Les dinos restent en SmoothPlastic (jouets).

**Finition** : bordures et plinthes en relief (`Outils.dalleBordee`), arêtes
arrondies sur piliers et socles (`Outils.blocArrondi`), boules et cylindres
pour les formes organiques, couleurs en trois teintes (base, `Charte.ombre`,
`Charte.lumiere`) pour donner du volume, petits détails (rivets, clous,
planches, mousse, cailloux) là où le regard se pose, jamais au milieu des
passages.

**Lumière** : `Lighting.Technology = Future`, ombres douces, reflets
(`EnvironmentDiffuseScale`/`EnvironmentSpecularScale` = 1), Atmosphere légère,
Bloom discret, SunRays, ColorCorrection vive ; lampes et torches avec
`PointLight`/`SpotLight` à ombres pour les coins importants.

**Ambiance** : particules d'ambiance (lucioles près de la jungle, feuilles,
fumée du volcan, éclaboussures de la cascade), animations douces
(`Outils.animer`).

**Interface** : même style qu'avant, en plus soigné : reflet brillant sur les
boutons (déjà dans `Style.bouton`), panneaux en dégradé avec ombre portée
(`Style.panneau`), cartes en dégradé (`Style.carte`), espacements réguliers
(UIPadding, UIListLayout), icônes plus grandes, transitions (ouverture en pop,
fermeture en fondu), compteurs qui défilent.
