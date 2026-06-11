# 🧟 Zsurvie

Jeu de défense incrémental dans un thème **survie zombie**. Défendez votre
barricade contre des hordes de plus en plus nombreuses, améliorez votre
équipement en pleine partie, et investissez votre ADN au **Laboratoire** pour
des recherches **permanentes** qui vous rendent plus fort à chaque tentative.

## ▶️ Jouer

Aucune installation, aucune dépendance : ouvrez simplement `index.html` dans
un navigateur, ou servez le dossier :

```bash
npx serve .
```

## 🎮 Boucle de jeu

1. **Survivez aux journées** — chaque jour, une vague de zombies attaque votre
   barricade. Votre survivant (et votre tourelle, une fois débloquée) tire
   automatiquement.
2. **Ramassez les pièces 🪙** — chaque zombie éliminé rapporte des pièces, à
   dépenser immédiatement dans la barre d'améliorations en bas de l'écran
   (dégâts, cadence, portée, barricade, réparation, régénération, butin,
   balles explosives). Ces améliorations sont perdues à la mort.
3. **Récoltez l'ADN 🧬** — gagné en finissant une journée, sur les zombies
   dorés et sur les colosses (tous les 5 jours). **L'ADN est conservé pour
   toujours**, même quand la barricade tombe.
4. **Recherchez au Laboratoire 🔬** — 10 recherches permanentes (munitions,
   cadence, barricade blindée, butin, extraction d'ADN, réserves de départ,
   auto-réparation, critiques, tourelle automatique, balles perforantes).
5. **Recommencez** — la barricade est tombée ? Dépensez votre ADN et repartez
   au Jour 1, plus fort qu'avant. Jusqu'où tiendrez-vous ?

## ⌨️ Commandes

- Tout se joue à la souris : cliquez sur les améliorations (vertes = achetables).
- **⏩** accélère le jeu (x1 / x2 / x3), **⏸️** met en pause.
- La progression (ADN, laboratoire, record) est sauvegardée automatiquement
  dans le navigateur (`localStorage`).

## 🛠️ Technique

- HTML5 Canvas + JavaScript pur, sans aucune dépendance.
- Tous les graphismes sont dessinés au code (style cartoon « blocs »).
- Fichiers : `index.html` (structure), `style.css` (interface), `game.js`
  (logique du jeu, rendu, équilibrage).
