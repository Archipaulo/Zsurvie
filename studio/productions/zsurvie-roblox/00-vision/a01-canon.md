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
