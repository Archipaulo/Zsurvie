# 🏗️ Atelier Roblox — studio de 50 agents IA

Un studio virtuel de **50 experts IA** spécialisés dans la création de maps
Roblox, avec une **application locale** pour suivre tous vos projets.

## ▶️ Lancer l'application

Aucune installation : **double-cliquez sur `Atelier-Roblox.html`**. L'application
s'ouvre dans votre navigateur et fonctionne hors ligne. Vos projets sont
sauvegardés automatiquement dans ce navigateur (pensez à « Exporter » dans les
Réglages pour faire une copie de sauvegarde ou changer d'ordinateur).

## 🧭 Ce que fait l'application

- **📊 Tableau de bord** : nombre de projets, tâches en cours et terminées,
  agents mobilisés, journal d'activité du studio.
- **🗂️ Projets** : chaque map a son pipeline de production en 7 phases
  (concept → greybox → terrain → construction → scripting → polish → publication)
  et son tableau de tâches (À faire / En cours / Révision / Terminé).
- **👥 Équipe** : les 50 agents rangés en 10 départements, avec leur charge de
  travail. Cliquez sur un agent pour voir sa fiche et le consulter.
- **🤖 Consultation IA** : ajoutez une clé API Anthropic dans ⚙️ Réglages et
  discutez directement avec chaque expert (il connaît le projet ouvert). Sans
  clé, le bouton « 📋 Copier le prompt expert » permet de l'interroger dans
  n'importe quel chat IA. La clé reste stockée uniquement dans votre navigateur :
  elle n'est jamais incluse dans les exports, et un import ne la remplace pas.

## 🎬 Un seul brief, les 50 agents ensemble

C'est le cœur du studio : vous écrivez **un seul brief** (votre idée de map) et
les 50 agents se coordonnent pour produire une **bible de production complète**.

| Étape | Qui | Ce qui se passe |
|---|---|---|
| 🧭 Vision | Analyste de marché, directrice artistique, puis directeur créatif | Étude des jeux Roblox similaires, direction artistique, puis le **canon** : titre, piliers, zones et noms officiels que tout le monde respectera |
| 🛠️ Contributions | 40 spécialistes | Chacun livre sa partie à partir du canon : boucle de jeu, économie, plan de la map en studs, terrain, bâtiments, scripts Luau complets, HUD, lumière, sons, monétisation… |
| 🧪 Revue QA | 5 experts QA | Relecture croisée : session joueur simulée, performance mobile, équilibrage chiffré, bugs et exploits, plan de playtests |
| 🤝 Coordination | Chef de projet | Détecte les contradictions entre départements, tranche, et demande jusqu'à 12 révisions |
| ✏️ Révisions | Agents concernés | Réécrivent leur livrable en appliquant les arbitrages et les corrections QA |
| 📖 Plan & Bible | Productrice + directeur créatif | Plan de production (tâches assignées aux agents, importables dans le kanban) et synthèse de la bible |

Deux façons de lancer une production :

**1. Dans l'application** — ouvrez un projet, cliquez sur **🚀 Brief au studio**.
Il faut une clé API Anthropic (⚙️ Réglages). La salle de production montre les
50 agents au travail en direct ; la bible se remplit au fur et à mesure.
Comptez 20 à 60 minutes et environ 9 à 16 $ avec Claude Opus 5 (3 à 6 $ avec
Sonnet 5). Si l'onglet est fermé, la production reprend là où elle s'était
arrêtée : rien de ce qui est déjà livré n'est refait ni refacturé.

**2. Dans Claude Code** — demandez simplement :
« lance le workflow atelier-roblox avec le brief : … ». Le workflow
`.claude/workflows/atelier-roblox.js` réserve un dossier neuf
`studio/productions/<projet>/` (jamais de mélange avec une production
précédente), fait travailler les 50 agents qui y écrivent tous leurs livrables
(et les scripts Luau au format Rojo, dans `scripts/<agent>/`), puis renvoie une
commande d'assemblage que Claude exécute pour produire `production.json` et
`BIBLE-COMPLETE.md`. Importez `production.json` dans l'application avec
**📥 Importer une production**. Pour pouvoir reprendre une exécution
interrompue, lancez-la avec un identifiant unique :
`{ nom, brief, jeton: "zsurvie-01" }`.

En cas d'échec d'un agent, l'application ne passe pas à l'étape suivante avec
des données incomplètes : elle propose **🔁 Réessayer les échecs** ou
**⏭️ Continuer sans eux**. Une seule production tourne à la fois, même avec
plusieurs onglets ouverts, et les onglets restent synchronisés.

## 👥 L'équipe (10 départements × 5 experts)

| Département | Experts |
|---|---|
| 🎬 Direction & Production | Directeur créatif, Productrice, Chef de projet, Directrice artistique, Analyste bench-mark |
| 🎲 Game Design | Boucle de jeu, Économie, Progression, Mécaniques, Onboarding |
| 🗺️ Level Design | Level designer principal, Obby & parkour, Points d'intérêt, Zones de combat, Énigmes |
| 🏔️ Terrain & Environnement | Terrain, Végétation, Eau & climat, Ciel & ambiance, Biomes |
| 🏗️ Construction & Modélisation | Architecte, Intérieurs, Props, Modeleuse 3D, Optimiseur d'assets |
| 💻 Scripting Luau | Gameplay, Systèmes serveur, Client & UI, Anti-exploit, Outillage |
| 🎨 UI / UX | Interface, HUD, Boutiques & menus, Iconographe, UX mobile |
| ✨ Lumière, VFX & Audio | Lighting, VFX, Animation, Sound design, Composition |
| 🧪 QA & Équilibrage | Testeur gameplay, Performance, Équilibreur, Chasseuse de bugs, Playtests |
| 🚀 Live Ops & Publication | Monétisation, Thumbnails, Fiche du jeu, Événements, Données |

## 🤖 Utiliser les agents dans Claude Code

Le dossier `agents-claude-code/` contient les 50 agents au format *subagent*
de Claude Code. Pour les rendre disponibles dans tous vos projets, copiez-les
dans votre dossier personnel :

```bash
mkdir -p ~/.claude/agents
cp agents-claude-code/*.md ~/.claude/agents/
```

Claude Code choisira alors automatiquement le bon expert selon la demande, ou
vous pouvez l'appeler par son nom (par exemple « demande à
roblox-designer-obby-parkour de calibrer mes sauts »).

## 🛠️ Modifier l'équipe

L'effectif est défini dans `agents.js`, et ce que chacun livre pendant une
production dans `production.js`. Après une modification, régénérez les agents
Claude Code, le workflow et la version fichier unique :

```bash
node generer.js
```
