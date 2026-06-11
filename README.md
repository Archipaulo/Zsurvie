# 🧟 Zsurvie

Jeu de défense incrémental en **voxel art**, vue surélevée. Les petits
monstres arrivent de **tous les côtés** : protégez la petite maison,
améliorez votre équipement en pleine partie, et investissez les gemmes
produites par la **mine** dans le **Laboratoire** pour des recherches
**permanentes** qui vous rendent plus fort à chaque tentative.

## ▶️ Jouer

Aucune installation, aucune dépendance : ouvrez simplement `index.html` dans
un navigateur, ou servez le dossier :

```bash
npx serve .
```

## 🎮 Boucle de jeu

1. **Le lobby du Laboratoire 🔬** — le jeu démarre dans le laboratoire :
   dépensez vos gemmes en recherches permanentes puis lancez l'assaut.
2. **Survivez aux journées** — chaque jour, une vague de monstres converge
   vers la maison depuis toutes les directions. Votre survivant sur le toit
   (et la tourelle, une fois débloquée) tire automatiquement.
3. **Ramassez les pièces 🪙** — chaque monstre éliminé rapporte des pièces, à
   dépenser immédiatement dans la barre d'améliorations en bas de l'écran
   (dégâts, cadence, portée, maison, réparation, régénération, butin, balles
   explosives). Ces améliorations sont perdues à la mort.
4. **Récoltez les gemmes 💎** — la **mine** à côté de la maison en produit en
   continu ; vous en gagnez aussi en finissant une journée, sur les monstres
   dorés et sur les colosses (tous les 5 jours). **Les gemmes sont conservées
   pour toujours**, même quand la maison tombe.
5. **Recommencez** — la maison est tombée ? Retour au laboratoire : dépensez
   vos gemmes parmi les 10 recherches permanentes (munitions, cadence, maison
   fortifiée, butin, foreuse, réserves de départ, auto-réparation, critiques,
   tourelle de toit, balles perforantes) et repartez au Jour 1, plus fort
   qu'avant. Jusqu'où tiendrez-vous ?

## ⌨️ Commandes

- Tout se joue à la souris : cliquez sur les améliorations (vertes = achetables).
- **⏩** accélère le jeu (x1 / x2 / x3), **⏸️** met en pause.
- Le bouton **🔬 Laboratoire** en jeu met la partie en pause et ouvre le lobby.
- La progression (gemmes, laboratoire, record) est sauvegardée automatiquement
  dans le navigateur (`localStorage`).

## 🛠️ Technique

- HTML5 Canvas + JavaScript pur, sans aucune dépendance.
- **Voxel art procédural** : maison, mine et monstres sont des modèles 3D en
  petits cubes (grilles de voxels générées par code) projetés en vue oblique
  — faces du dessus éclaircies, faces avant ombrées — puis pré-rendus en
  sprites pour rester fluide même avec 60 monstres à l'écran.
- Animations voxel : 2 frames de marche (pieds et bras), clignement des yeux,
  flash blanc à l'impact, écrasement « pâte à modeler » au rebond.
- Vue surélevée avec profondeur : tri des entités par plan, ombres au sol,
  taille et vitesse modulées par l'éloignement.
- Fichiers : `index.html` (structure), `style.css` (interface et lobby),
  `game.js` (logique du jeu, rendu, équilibrage).
