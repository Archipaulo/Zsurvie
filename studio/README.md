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
  n'importe quel chat IA. La clé reste stockée uniquement dans votre navigateur.

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

L'effectif est défini dans `agents.js`. Après une modification, régénérez les
agents Claude Code et la version fichier unique :

```bash
node generer.js
```
