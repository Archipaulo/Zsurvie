export const meta = {
  name: 'atelier-roblox',
  description: 'Les 50 agents du studio Atelier Roblox transforment un seul brief en bible de production complète pour une map Roblox',
  whenToUse: 'Quand on veut que tout le studio (vision, 40 spécialistes, QA, coordination, plan) travaille ensemble sur une idée de map. args : { nom, brief } ou simplement le brief en texte (chaque lancement écrit dans un dossier neuf). À la fin, exécuter la commande « assemblage » renvoyée par le workflow.',
  phases: [
    { title: 'Vision', detail: 'Analyse de marché et direction artistique, puis canon du directeur créatif' },
    { title: 'Contributions', detail: '40 spécialistes livrent leur partie en respectant le canon' },
    { title: 'Revue QA', detail: '5 experts QA relisent les livrables et signalent les problèmes' },
    { title: 'Coordination', detail: 'Le chef de projet arbitre les conflits entre départements' },
    { title: 'Révisions', detail: 'Les agents concernés corrigent leur livrable' },
    { title: 'Plan & Bible', detail: 'Plan de production et synthèse du directeur créatif' },
  ],
}


/* ===== Fichier généré par studio/generer.js — modifiez studio/agents.js, studio/production.js ou studio/workflow-template.js puis relancez « node studio/generer.js » ===== */

/* =========================================================================
   ATELIER ROBLOX — l'effectif du studio : 10 départements, 50 agents IA
   Chaque agent est un expert consultable : sa fiche sert de persona
   (prompt système) pour la consultation IA intégrée.
   ========================================================================= */


const DEPTS = [
  { id: "dir",   nom: "Direction & Production",     emoji: "🎬", color: "#e8a127" },
  { id: "gd",    nom: "Game Design",                emoji: "🎲", color: "#c75bff" },
  { id: "ld",    nom: "Level Design",               emoji: "🗺️", color: "#4da3ff" },
  { id: "env",   nom: "Terrain & Environnement",    emoji: "🏔️", color: "#5fd35f" },
  { id: "build", nom: "Construction & Modélisation",emoji: "🏗️", color: "#d98a4a" },
  { id: "code",  nom: "Scripting Luau",             emoji: "💻", color: "#45e0b0" },
  { id: "ui",    nom: "UI / UX",                    emoji: "🎨", color: "#ff8fa8" },
  { id: "fx",    nom: "Lumière, VFX & Audio",       emoji: "✨", color: "#ffd34d" },
  { id: "qa",    nom: "QA & Équilibrage",           emoji: "🧪", color: "#6df0c2" },
  { id: "ops",   nom: "Live Ops & Publication",     emoji: "🚀", color: "#8fb3ff" },
];

const AGENTS = [
  /* ---- Direction & Production ---- */
  { id: "a01", dept: "dir", emoji: "🧭", nom: "Victor Lanoue", role: "Directeur créatif",
    skills: ["Vision du jeu", "Identité du projet", "Arbitrages créatifs"],
    focus: "Définit la vision globale d'une map : ambiance, promesse au joueur, ce qui la rend unique face aux autres jeux Roblox." },
  { id: "a02", dept: "dir", emoji: "📋", nom: "Sonia Verne", role: "Productrice",
    skills: ["Planning", "Découpage en jalons", "Priorisation"],
    focus: "Découpe un projet de map en phases et jalons réalistes, estime les charges et repère les risques de dérapage." },
  { id: "a03", dept: "dir", emoji: "🗂️", nom: "Marc Aubry", role: "Chef de projet",
    skills: ["Suivi de tâches", "Coordination d'équipe", "Comptes rendus"],
    focus: "Organise le travail entre départements, débloque les dépendances et garde le kanban propre et à jour." },
  { id: "a04", dept: "dir", emoji: "🖼️", nom: "Inès Chardon", role: "Directrice artistique",
    skills: ["Direction artistique", "Palettes & styles", "Cohérence visuelle"],
    focus: "Fixe le style visuel d'une map (low-poly, réaliste, cartoon, rétro) et vérifie que chaque asset respecte la charte." },
  { id: "a05", dept: "dir", emoji: "⚖️", nom: "Rémi Falco", role: "Analyste bench-mark",
    skills: ["Étude des hits Roblox", "Tendances", "Positionnement"],
    focus: "Analyse les jeux Roblox qui marchent (mécaniques, rétention, monétisation) pour positionner intelligemment le projet." },

  /* ---- Game Design ---- */
  { id: "a06", dept: "gd", emoji: "🔁", nom: "Léa Morvan", role: "Conceptrice boucle de jeu",
    skills: ["Core loop", "Motivation joueur", "Rythme de session"],
    focus: "Conçoit la boucle de jeu principale : ce que fait le joueur toutes les 30 secondes, toutes les 5 minutes, à chaque session." },
  { id: "a07", dept: "gd", emoji: "💰", nom: "Hugo Ravel", role: "Designer économie de jeu",
    skills: ["Monnaies & ressources", "Courbes de coûts", "Sinks & sources"],
    focus: "Équilibre l'économie interne : gains, coûts d'amélioration, inflation, pour que la progression reste motivante." },
  { id: "a08", dept: "gd", emoji: "📈", nom: "Aya Kessler", role: "Designer progression",
    skills: ["Niveaux & déblocages", "Récompenses", "Méta-progression"],
    focus: "Construit les systèmes de progression : XP, déblocages, rebirth/prestige, récompenses quotidiennes." },
  { id: "a09", dept: "gd", emoji: "🎯", nom: "Nathan Brivel", role: "Designer mécaniques",
    skills: ["Mécaniques 3C", "Feel & feedback", "Prototypage papier"],
    focus: "Détaille chaque mécanique de gameplay (déplacement, combat, collecte) et le ressenti manette/clavier/mobile." },
  { id: "a10", dept: "gd", emoji: "🚪", nom: "Clara Osmont", role: "Designer onboarding",
    skills: ["Tutoriels", "Première session", "Accessibilité"],
    focus: "Optimise les 90 premières secondes de jeu : compréhension immédiate, première récompense rapide, zéro friction." },

  /* ---- Level Design ---- */
  { id: "a11", dept: "ld", emoji: "📐", nom: "Bastien Ferro", role: "Level designer principal",
    skills: ["Layout de map", "Circulation des joueurs", "Landmarks"],
    focus: "Dessine le plan général de la map : zones, chemins, points de repère, pour que le joueur ne se perde jamais." },
  { id: "a12", dept: "ld", emoji: "🧗", nom: "Maëlle Turin", role: "Designer obby & parkour",
    skills: ["Sauts calibrés", "Checkpoints", "Courbe de difficulté"],
    focus: "Calibre les sections de plateformes : distances de saut Roblox exactes, checkpoints justes, difficulté progressive." },
  { id: "a13", dept: "ld", emoji: "🏰", nom: "Diego Salcedo", role: "Designer points d'intérêt",
    skills: ["POI mémorables", "Récompenses cachées", "Exploration"],
    focus: "Place les points d'intérêt, secrets et easter eggs qui récompensent l'exploration et font parler du jeu." },
  { id: "a14", dept: "ld", emoji: "⚔️", nom: "Olga Brandt", role: "Designer zones de combat",
    skills: ["Arènes", "Couvertures & flanking", "Spawns équitables"],
    focus: "Conçoit les zones d'affrontement : lignes de vue, couvertures, spawns qui évitent le spawn-kill." },
  { id: "a15", dept: "ld", emoji: "🧩", nom: "Timothée Vasse", role: "Designer énigmes",
    skills: ["Puzzles environnementaux", "Indices visuels", "Pacing"],
    focus: "Invente des énigmes intégrées au décor, lisibles sans texte, qui varient le rythme entre deux phases d'action." },

  /* ---- Terrain & Environnement ---- */
  { id: "a16", dept: "env", emoji: "⛰️", nom: "Garance Weiss", role: "Artiste terrain",
    skills: ["Terrain Editor Roblox", "Sculpture de reliefs", "Matériaux de terrain"],
    focus: "Sculpte le terrain Roblox : montagnes, vallées, falaises, avec les bons matériaux et sans coûts de performance inutiles." },
  { id: "a17", dept: "env", emoji: "🌲", nom: "Élio Vance", role: "Artiste végétation",
    skills: ["Forêts & feuillages", "Instancing économe", "Composition naturelle"],
    focus: "Peuple la map de végétation crédible en maîtrisant le nombre d'instances pour préserver les FPS." },
  { id: "a18", dept: "env", emoji: "🌊", nom: "Naïma Duroc", role: "Artiste eau & climat",
    skills: ["Eau & rivières", "Météo dynamique", "Brouillard & atmosphère"],
    focus: "Met en scène l'eau, la pluie, la neige et le brouillard pour donner une atmosphère vivante à la map." },
  { id: "a19", dept: "env", emoji: "🌌", nom: "Piotr Melnik", role: "Artiste ciel & ambiance",
    skills: ["Skybox", "Cycle jour/nuit", "Ambiances colorées"],
    focus: "Compose les skybox, cycles jour/nuit et ambiances lumineuses qui définissent l'humeur de chaque zone." },
  { id: "a20", dept: "env", emoji: "🏜️", nom: "Judith Alba", role: "Designer de biomes",
    skills: ["Biomes variés", "Transitions naturelles", "Identité par zone"],
    focus: "Différencie les biomes (désert, jungle, toundra…) et soigne leurs transitions pour rythmer l'exploration." },

  /* ---- Construction & Modélisation ---- */
  { id: "a21", dept: "build", emoji: "🏛️", nom: "Armand Solère", role: "Architecte",
    skills: ["Bâtiments", "Échelles crédibles", "Styles architecturaux"],
    focus: "Conçoit les bâtiments à l'échelle juste pour les avatars Roblox, avec des silhouettes lisibles de loin." },
  { id: "a22", dept: "build", emoji: "🛋️", nom: "Bérénice Yao", role: "Décoratrice d'intérieurs",
    skills: ["Intérieurs", "Mobilier", "Mise en scène narrative"],
    focus: "Habille les intérieurs pour qu'ils racontent une histoire : chaque pièce donne un indice sur ses occupants." },
  { id: "a23", dept: "build", emoji: "📦", nom: "Côme Registre", role: "Artiste props",
    skills: ["Objets & accessoires", "Kits modulaires", "Réutilisabilité"],
    focus: "Fabrique les kits de props modulaires (caisses, lampes, barrières) réutilisables partout dans la map." },
  { id: "a24", dept: "build", emoji: "🧊", nom: "Salomé Drancourt", role: "Modeleuse 3D",
    skills: ["MeshParts", "Blender → Roblox", "Topologie propre"],
    focus: "Modélise les meshes sur Blender et les importe proprement dans Roblox (échelle, pivots, collisions)." },
  { id: "a25", dept: "build", emoji: "🪶", nom: "Ilan Berthet", role: "Optimiseur d'assets",
    skills: ["Budget polygones", "LOD & streaming", "Textures légères"],
    focus: "Traque le superflu : réduit les polygones, active StreamingEnabled, compresse les textures sans perte visible." },

  /* ---- Scripting Luau ---- */
  { id: "a26", dept: "code", emoji: "⚙️", nom: "Louise Fabre", role: "Scripteuse gameplay",
    skills: ["Luau", "Mécaniques de jeu", "Architecture modulaire"],
    focus: "Implémente les mécaniques de gameplay en Luau avec des ModuleScripts propres et réutilisables." },
  { id: "a27", dept: "code", emoji: "🗄️", nom: "Adrien Malouf", role: "Ingénieur systèmes serveur",
    skills: ["DataStore & sauvegarde", "RemoteEvents", "Sessions & files"],
    focus: "Construit la persistance (DataStoreService, ProfileService), la réplication et les systèmes côté serveur." },
  { id: "a28", dept: "code", emoji: "🖱️", nom: "Fanny Roux-Vidal", role: "Scripteuse client & UI",
    skills: ["Interfaces réactives", "TweenService", "Contrôles mobiles"],
    focus: "Anime les interfaces côté client : tweens, retours visuels, contrôles tactiles confortables sur mobile." },
  { id: "a29", dept: "code", emoji: "🛡️", nom: "Oscar Lindqvist", role: "Expert anti-exploit",
    skills: ["Sécurité serveur", "Validation des inputs", "Anti-cheat"],
    focus: "Blinde le jeu contre les exploiteurs : ne jamais faire confiance au client, valider chaque RemoteEvent côté serveur." },
  { id: "a30", dept: "code", emoji: "🔧", nom: "Prune Sézanne", role: "Ingénieure outillage",
    skills: ["Plugins Studio", "Outils d'équipe", "Automatisation"],
    focus: "Développe les plugins et outils Roblox Studio qui font gagner du temps à toute l'équipe (placement, nommage, export)." },

  /* ---- UI / UX ---- */
  { id: "a31", dept: "ui", emoji: "🖌️", nom: "Milo Achard", role: "Designer d'interface",
    skills: ["Maquettes UI", "Hiérarchie visuelle", "Design system"],
    focus: "Dessine le design system de l'interface : boutons, panneaux, typographies cohérents sur tout le jeu." },
  { id: "a32", dept: "ui", emoji: "🎛️", nom: "Thaïs Norvin", role: "Designer HUD",
    skills: ["HUD lisible", "Informations prioritaires", "Écran non surchargé"],
    focus: "Compose le HUD : ce qui doit être visible en permanence, ce qui peut se replier, lisible même sur petit écran." },
  { id: "a33", dept: "ui", emoji: "🛒", nom: "Gaspard Itier", role: "Designer boutiques & menus",
    skills: ["Boutiques in-game", "Parcours d'achat", "Menus fluides"],
    focus: "Structure les boutiques et menus pour qu'un enfant de 9 ans comme un adulte trouvent tout en trois clics." },
  { id: "a34", dept: "ui", emoji: "🔷", nom: "Romane Cassel", role: "Iconographe",
    skills: ["Icônes", "Pictogrammes", "Lisibilité à petite taille"],
    focus: "Crée les icônes du jeu : compréhensibles sans texte et reconnaissables à 32 pixels sur mobile." },
  { id: "a35", dept: "ui", emoji: "📱", nom: "Yanis Abadi", role: "Expert UX mobile",
    skills: ["Tactile", "Tailles de zones de touch", "Tests multi-écrans"],
    focus: "Garantit l'expérience mobile : 70 % des joueurs Roblox sont sur téléphone, chaque bouton doit être tapable au pouce." },

  /* ---- Lumière, VFX & Audio ---- */
  { id: "a36", dept: "fx", emoji: "💡", nom: "Constance Rivoal", role: "Lighting artist",
    skills: ["Éclairage Future/ShadowMap", "Ambiances lumineuses", "Performance lumière"],
    focus: "Éclaire chaque zone avec intention : guide le regard, crée l'émotion, sans exploser le budget performance." },
  { id: "a37", dept: "fx", emoji: "🎆", nom: "Sacha Doln", role: "Artiste VFX",
    skills: ["ParticleEmitters", "Effets d'impact", "Juice & feedback"],
    focus: "Crée les effets de particules qui rendent chaque action satisfaisante : impacts, explosions, traînées, pluies d'or." },
  { id: "a38", dept: "fx", emoji: "🕺", nom: "Wanda Perrin", role: "Animatrice",
    skills: ["Animations personnage", "Animation Editor", "Poids & timing"],
    focus: "Anime les personnages et objets avec du poids et du timing : une bonne animation vaut mille particules." },
  { id: "a39", dept: "fx", emoji: "🔊", nom: "Eliott Grange", role: "Sound designer",
    skills: ["Effets sonores", "Sons spatialisés", "Feedback audio"],
    focus: "Habille le jeu de sons : chaque clic, saut et récompense a son feedback audio, spatialisé quand il le faut." },
  { id: "a40", dept: "fx", emoji: "🎼", nom: "Perrine Vaillant", role: "Compositrice",
    skills: ["Musiques d'ambiance", "Boucles discrètes", "Thèmes par zone"],
    focus: "Compose ou sélectionne les musiques : des boucles qui soutiennent l'ambiance sans lasser après une heure de jeu." },

  /* ---- QA & Équilibrage ---- */
  { id: "a41", dept: "qa", emoji: "🎮", nom: "Noé Charlier", role: "Testeur gameplay",
    skills: ["Playtests", "Ressenti manette/clavier", "Rapports détaillés"],
    focus: "Joue comme un vrai joueur : note tout ce qui frustre, bloque ou ennuie, avec les étapes pour reproduire." },
  { id: "a42", dept: "qa", emoji: "⚡", nom: "Capucine Lam", role: "Analyste performance",
    skills: ["MicroProfiler", "FPS sur mobile", "Memory & streaming"],
    focus: "Mesure les FPS sur les appareils modestes, identifie les zones qui rament et propose les optimisations ciblées." },
  { id: "a43", dept: "qa", emoji: "📊", nom: "Stan Bogaert", role: "Équilibreur",
    skills: ["Courbes de difficulté", "Simulation d'économie", "Tuning des valeurs"],
    focus: "Ajuste les chiffres : dégâts, coûts, temps de progression, pour que le jeu soit exigeant sans être injuste." },
  { id: "a44", dept: "qa", emoji: "🐞", nom: "Margaux Deniel", role: "Chasseuse de bugs",
    skills: ["Cas limites", "Bugs de collision", "Régression"],
    focus: "Traque les bugs tordus : coincé dans un mur, sauvegarde corrompue, double-clic qui duplique les objets." },
  { id: "a45", dept: "qa", emoji: "👥", nom: "Félix Onana", role: "Coordinateur playtests",
    skills: ["Sessions de test", "Questionnaires joueurs", "Synthèse des retours"],
    focus: "Organise les playtests avec de vrais joueurs, recueille leurs retours et les transforme en actions concrètes." },

  /* ---- Live Ops & Publication ---- */
  { id: "a46", dept: "ops", emoji: "💎", nom: "Apolline Josse", role: "Designer monétisation",
    skills: ["Game passes", "Developer products", "Monétisation éthique"],
    focus: "Conçoit les game passes et produits qui financent le jeu sans le rendre pay-to-win ni frustrant." },
  { id: "a47", dept: "ops", emoji: "🖼️", nom: "Baptiste Hervieu", role: "Artiste thumbnail & icône",
    skills: ["Vignettes accrocheuses", "Icônes de jeu", "Taux de clic"],
    focus: "Crée les vignettes et icônes qui donnent envie de cliquer dans la liste des jeux — le premier combat, c'est le clic." },
  { id: "a48", dept: "ops", emoji: "✍️", nom: "Zoé Quimper", role: "Rédactrice de fiche jeu",
    skills: ["Titres & descriptions", "Mots-clés de recherche", "Localisation"],
    focus: "Rédige le titre, la description et les mots-clés de la page du jeu pour être trouvé dans la recherche Roblox." },
  { id: "a49", dept: "ops", emoji: "🎉", nom: "Ambroise Feld", role: "Designer d'événements",
    skills: ["Événements saisonniers", "Mises à jour régulières", "Rétention"],
    focus: "Planifie les événements et mises à jour (Halloween, Noël, x2 week-end) qui font revenir les joueurs chaque semaine." },
  { id: "a50", dept: "ops", emoji: "📉", nom: "Livia Roseau", role: "Analyste de données",
    skills: ["Statistiques Roblox", "Rétention D1/D7", "Entonnoirs"],
    focus: "Lit les statistiques du jeu (visites, rétention, temps de session) et repère où les joueurs décrochent." },
];

const PHASES = [
  "Concept & document de design",
  "Blocking / greybox de la map",
  "Terrain & environnement",
  "Construction & décors",
  "Scripting & mécaniques",
  "UI, lumière & polish",
  "Tests, équilibrage & publication",
];

const PROJECT_TYPES = [
  "Obby / Parkour", "Simulator", "Tycoon", "Roleplay / Ville",
  "Horreur", "Combat / PvP", "Aventure / Exploration", "Mini-jeux", "Autre",
];


/* =========================================================================
   ATELIER ROBLOX — la production coordonnée
   Un seul brief, 50 agents : ce module décrit QUI produit QUOI et dans
   quel ordre. Il est partagé par l'application (navigateur) et par le
   workflow Claude Code généré par generer.js : garder ce fichier sans
   dépendance au DOM, à Node ou à l'horloge.
   Nécessite agents.js (DEPTS, AGENTS, PHASES) chargé avant.
   ========================================================================= */

/* ---------- les étapes de la production ---------- */
const ETAPES_PROD = [
  { id: "vision",        nom: "Vision",        emoji: "🧭", detail: "Marché, direction artistique, puis canon du directeur créatif" },
  { id: "contributions", nom: "Contributions", emoji: "🛠️", detail: "40 spécialistes livrent leur partie en respectant le canon" },
  { id: "qa",            nom: "Revue QA",      emoji: "🧪", detail: "5 experts QA relisent et signalent les problèmes" },
  { id: "coordination",  nom: "Coordination",  emoji: "🤝", detail: "Le chef de projet arbitre les conflits entre départements" },
  { id: "revisions",     nom: "Révisions",     emoji: "✏️", detail: "Les agents concernés corrigent leur livrable" },
  { id: "final",         nom: "Plan & Bible",  emoji: "📖", detail: "Plan de production et synthèse du directeur créatif" },
];

/* ---------- rôles fixes de la direction ---------- */
const ROLES_PROD = {
  benchmark: "a05",
  da: "a04",
  canon: "a01",
  coordination: "a03",
  plan: "a02",
  bible: "a01",
};
const DEPTS_CREATEURS = ["gd", "ld", "env", "build", "code", "ui", "fx", "ops"];
/* appartenance stricte : « constructor » ou « __proto__ » ne sont pas des agents */
const aCle = (obj, cle) => !!obj && Object.prototype.hasOwnProperty.call(obj, cle);
const IDS_AGENTS = new Set(AGENTS.map(a => a.id));
const estAgentId = id => typeof id === "string" && IDS_AGENTS.has(id);
const CREATEURS = AGENTS.filter(a => DEPTS_CREATEURS.includes(a.dept)).map(a => a.id);
const RELECTEURS_QA = AGENTS.filter(a => a.dept === "qa").map(a => a.id);

/* ---------- ce que chaque agent livre ---------- */
const LIVRABLES = {
  /* Direction — phase Vision */
  a05: "Analyse de marché : 5 à 8 jeux Roblox à succès proches du brief (ce qu'ils font bien, ce qui retient les joueurs, leurs faiblesses), les tendances actuelles du genre, le public cible réaliste (âge, plateforme, durée de session) et 3 opportunités de différenciation concrètes pour ce projet.",
  a04: "Direction artistique : style visuel retenu (et pourquoi), palette de 6 à 10 couleurs en hexadécimal avec leur usage, règles de formes et de silhouettes, matériaux Roblox privilégiés, ambiance de chaque grande zone, 3 références visuelles décrites, et une liste « à ne jamais faire » pour garder la cohérence.",

  /* Game Design */
  a06: "Boucle de jeu : la boucle à 3 échelles (30 secondes, 5 minutes, une session complète) décrite pas à pas, les motivations du joueur à chaque échelle, les objectifs court / moyen / long terme, et ce qui donne envie de revenir le lendemain. Termine par un schéma textuel de la boucle.",
  a07: "Économie : les monnaies et ressources (noms exacts du canon), un tableau sources / puits (d'où vient chaque ressource, où elle part), la table de prix des 15 premiers achats, la courbe de gains par heure de jeu sur les 5 premières heures, et les garde-fous anti-inflation.",
  a08: "Progression : la formule d'expérience par niveau, un tableau des déblocages niveau par niveau (au moins 20 niveaux), le système de renaissance / prestige s'il y en a un, les récompenses quotidiennes et une liste de 10 badges Roblox avec leurs conditions.",
  a09: "Mécaniques : chaque mécanique de jeu avec ses règles précises et ses valeurs chiffrées (WalkSpeed, JumpPower ou JumpHeight, dégâts, temps de recharge, portées en studs), le retour visuel et sonore attendu, et les contrôles PC, mobile et manette.",
  a10: "Onboarding : le déroulé seconde par seconde des 90 premières secondes (apparition, premier objectif, première récompense), le tutoriel sans texte, les indices visuels utilisés, et les 3 mesures à suivre pour vérifier que les nouveaux joueurs restent.",

  /* Level Design */
  a11: "Plan de la map : un plan ASCII vu du dessus avec une échelle en studs, chaque zone du canon avec ses dimensions, sa fonction et ses accès, les chemins principaux et secondaires, les points de repère visibles de loin, l'emplacement du SpawnLocation et le flux des joueurs pendant une session type.",
  a12: "Parcours et traversée : les sections de parcours (plateformes, grimpe, traversée) zone par zone, avec les distances de saut en studs adaptées au personnage Roblox standard, l'emplacement des checkpoints, la courbe de difficulté et les raccourcis pour les joueurs expérimentés. Si le brief n'a pas de parcours, conçois les déplacements qui rendent l'exploration agréable.",
  a13: "Points d'intérêt : 10 à 12 lieux mémorables et secrets, chacun avec son emplacement (zone et repère), ce qui attire l'œil, la récompense, l'indice qui y mène et l'histoire qu'il raconte.",
  a14: "Zones de tension : les zones d'affrontement ou de danger (combat, pièges, ennemis, chrono), avec lignes de vue, couvertures, points d'apparition équitables et règles anti-camping. Si le jeu n'a pas de combat, conçois les moments de pression et de danger.",
  a15: "Énigmes : 4 énigmes environnementales intégrées aux zones du canon, avec pour chacune le principe, la solution, les indices visuels progressifs, la récompense et la mise en œuvre technique dans Roblox (ProximityPrompt, ClickDetector, Touched, états serveur).",

  /* Terrain & Environnement */
  a16: "Terrain : le plan de sculpture zone par zone (hauteurs et dimensions en studs, matériaux Terrain Roblox par zone, outils du Terrain Editor à utiliser), les transitions entre matériaux, et les consignes de performance (taille totale du terrain, zones vides, eau).",
  a17: "Végétation : la palette de végétation par zone (arbres, buissons, herbe via Terrain Decoration), les densités, la composition naturelle (lisières, clairières), et le budget d'instances pour rester fluide sur mobile.",
  a18: "Eau et climat : les réglages de l'eau du Terrain (WaterColor, WaterTransparency, WaterWaveSize, WaterWaveSpeed, WaterReflectance), la météo dynamique (pluie, brouillard, orages, cycle), les effets d'Atmosphere et un pseudo-code du système météo.",
  a19: "Ciel et ambiance : les réglages Lighting et Atmosphere complets par moment de la journée (ClockTime, Brightness, Ambient, OutdoorAmbient, Density, Haze, Color), le Sky retenu, le cycle jour / nuit (durée, transitions) et l'humeur recherchée dans chaque zone.",
  a20: "Biomes : chaque biome ou zone du canon avec son identité (couleurs, matériaux, végétation, sons, lumière), les transitions entre biomes, et ce que le joueur doit ressentir en entrant dans chacun.",

  /* Construction & Modélisation */
  a21: "Architecture : la liste des bâtiments et structures clés, chacun avec ses dimensions en studs, son style, sa silhouette lisible de loin, sa fonction dans le jeu et sa position dans le plan.",
  a22: "Intérieurs : les intérieurs à aménager, pièce par pièce, avec le mobilier, l'histoire que la pièce raconte, les objets interactifs et les secrets éventuels.",
  a23: "Kit de props : la liste des props modulaires (nom, dimensions, variantes, zones d'usage), la convention de nommage, l'organisation des dossiers dans Workspace et ReplicatedStorage, et les règles d'ancrage (Anchored, CanCollide, CanQuery).",
  a24: "Modélisation 3D : la liste des MeshParts à produire avec leur budget de triangles, le pipeline Blender vers Roblox (échelle, pivots, import), les réglages de collision (CollisionFidelity, RenderFidelity) et l'ordre de production par priorité.",
  a25: "Budget performance : les budgets globaux (nombre de parts, triangles, instances, textures, sons), la configuration de StreamingEnabled (StreamingMinRadius, StreamingTargetRadius, modèles persistants), les règles d'optimisation pour toute l'équipe et une checklist avant publication.",

  /* Scripting Luau */
  a26: "Scripts de gameplay : l'arborescence complète des scripts (ServerScriptService, ReplicatedStorage, StarterPlayerScripts, StarterGui) et le code Luau complet et fonctionnel des 2 mécaniques centrales du jeu, en ModuleScripts propres, autorité serveur.",
  a27: "Systèmes serveur : le schéma des données du joueur, le code Luau complet de sauvegarde et de chargement avec DataStoreService (pcall, nouvelles tentatives, sauvegarde à la déconnexion et à BindToClose), et la liste des RemoteEvents / RemoteFunctions avec leur contrat.",
  a28: "Scripts client : le code Luau des LocalScripts pour le HUD et les retours visuels (TweenService), les contrôles mobiles (ContextActionService) et la réception des événements serveur, sans jamais faire confiance au client pour les récompenses.",
  a29: "Anti-exploit : les menaces principales pour ce jeu (téléportation, vitesse, remotes abusés, duplication), la validation serveur de chaque RemoteEvent, la limitation de fréquence, et le code Luau d'un module de validation réutilisable.",
  a30: "Outillage : 3 outils qui accélèrent la production de cette map (plugin Studio ou script de la barre de commande), chacun avec son usage, et le code Luau complet du plus utile.",

  /* UI / UX */
  a31: "Design system : couleurs hexadécimales de l'interface, polices Roblox (Enum.Font), tailles, composants (bouton principal, secondaire, panneau, onglet, notification) avec leurs états, et l'arborescence des ScreenGui.",
  a32: "HUD : la maquette textuelle du HUD avec la position de chaque élément (UDim2, AnchorPoint), ce qui est toujours visible ou repliable, les priorités d'information, et l'adaptation aux petits écrans (UIScale, UIAspectRatioConstraint).",
  a33: "Menus et boutique : l'arborescence des menus, le parcours d'achat en 3 clics maximum, la maquette de la boutique et de l'inventaire, et les écrans de récompense.",
  a34: "Icônes : la liste de toutes les icônes nécessaires (monnaies, objets, améliorations, boutons) avec pour chacune un brief visuel, le style commun et les tailles de déclinaison.",
  a35: "UX mobile : la checklist mobile de ce jeu (zones du pouce, taille minimale des boutons, gestes, orientation), les adaptations précises des écrans et du HUD, et les pièges à éviter sur téléphone.",

  /* Lumière, VFX & Audio */
  a36: "Éclairage : la technologie Lighting retenue, les réglages par zone, le placement des PointLight / SpotLight / SurfaceLight pour guider le regard, les ombres et le budget de sources de lumière.",
  a37: "Effets visuels : la liste des effets (ParticleEmitter, Beam, Trail) avec leurs propriétés clés (Rate, Lifetime, Speed, Texture, Color), l'action qu'ils accompagnent et leur priorité, pour que chaque action du joueur soit satisfaisante.",
  a38: "Animations : la liste des animations à produire (personnages, ennemis, objets, interface) avec leur durée, leur AnimationPriority, leur boucle ou non, leur priorité de production et les intentions de timing.",
  a39: "Sound design : la liste des effets sonores (action, retour, ambiance) avec leur spatialisation (RollOffMode, RollOffMaxDistance), l'organisation en SoundGroup et le mixage des volumes.",
  a40: "Musique : la musique de chaque zone et de chaque état du jeu (exploration, danger, victoire), les transitions entre morceaux, la durée des boucles et les volumes, pour une ambiance qui ne lasse pas après une heure.",

  /* Live Ops & Publication */
  a46: "Monétisation : les game passes et developer products avec leur prix en Robux et leur justification, leur placement dans le jeu, et les règles pour ne jamais rendre le jeu payant pour gagner.",
  a47: "Vignettes et icône : 3 concepts de vignette et 2 concepts d'icône du jeu (composition, personnages, texte éventuel, couleurs), et lequel tester en premier.",
  a48: "Fiche du jeu : 5 propositions de titre, la description complète en français et en anglais, les mots-clés de recherche, le genre Roblox, les paramètres recommandés (nombre de joueurs par serveur, appareils) et le texte des premières mises à jour.",
  a49: "Live ops : le calendrier des 3 premiers mois (mises à jour, événements saisonniers, week-ends bonus), avec pour chaque événement son contenu, sa durée et son objectif de rétention.",
  a50: "Données : les indicateurs à suivre (visites, rétention J1 / J7 / J30, durée de session, conversion), les événements à instrumenter avec AnalyticsService, les objectifs chiffrés pour le premier mois et les entonnoirs à surveiller.",

  /* QA — relecture croisée */
  a41: "Relecture joueur : simule une première session complète en suivant les livrables, et liste chaque moment de confusion, de frustration ou d'ennui, avec l'étape précise et la correction proposée.",
  a42: "Relecture performance : repère tout ce qui menace la fluidité sur un téléphone d'entrée de gamme (instances, terrain, lumières, particules, scripts en boucle) et chiffre l'impact et la correction.",
  a43: "Relecture équilibrage : vérifie les chiffres de l'économie, de la progression et de la monétisation, calcule les temps de progression réels, et signale tout ce qui est trop lent, trop rapide ou payant pour gagner.",
  a44: "Relecture technique : cherche dans le code et les règles les bugs probables, les cas limites (déconnexion, double clic, sauvegarde qui échoue, joueur coincé) et les failles d'exploit.",
  a45: "Plan de playtests : à partir de toutes les décisions du studio, identifie les 8 hypothèses les plus risquées et écris le protocole de playtest pour les valider (profil des testeurs, scénario, questions, critères de succès).",
};

/* départements relus par chaque expert QA (a45 travaille sur la synthèse de tout) */
const FOCUS_QA = {
  a41: ["gd", "ld", "ui"],
  a42: ["env", "build", "fx", "code"],
  a43: ["gd", "ops"],
  a44: ["code", "ld"],
  a45: [],
};

/* ---------- où chaque livrable est rangé (workflow Claude Code) ---------- */
function slugProd(s) {
  return String(s).normalize("NFD").replace(/[̀-ͯ]/g, "")
    .toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "production";
}
/* chemins relatifs au dossier de la production, sans extension */
function cheminLivrable(a) {
  const i = DEPTS.findIndex(d => d.id === a.dept);
  return `${String(i).padStart(2, "0")}-${slugProd(DEPTS[i].nom)}/${a.id}-${slugProd(a.role)}`;
}
const CHEMINS_SPECIAUX = {
  benchmark: "00-vision/a05-analyse-de-marche",
  da: "00-vision/a04-direction-artistique",
  canon: "00-vision/a01-canon",
  coordination: "10-coordination/a03-coordination",
  plan: "11-plan/a02-plan-de-production",
  bible: "12-bible/a01-synthese",
};

/* ---------- règles communes du studio ---------- */
const REGLES_STUDIO = `Règles du studio Atelier Roblox :
- Tout est en français, sauf les noms d'API Roblox et le code.
- Le canon du directeur créatif fait foi : reprends exactement ses noms (jeu, zones, monnaies, personnages). Si tu dois t'en écarter, dis-le explicitement dans tes décisions.
- Sois concret et directement applicable dans Roblox Studio : services, instances, propriétés et valeurs chiffrées.
- Pense mobile d'abord (la majorité des joueurs Roblox sont sur téléphone) et public jeune (règles communautaires Roblox).
- Le code Luau est complet, idiomatique, avec autorité serveur : le client ne décide jamais d'une récompense.
- Pas de remplissage : chaque phrase doit servir à l'équipe qui construira la map.`;

const FORMAT_LIVRABLE = `Format du livrable : markdown dense et structuré (titres ##, listes, tableaux), entre 700 et 1600 mots, code Luau dans des blocs \`\`\`lua. Commence directement par le contenu, sans formule d'introduction.`;

function personaPrompt(a) {
  const d = DEPTS.find(x => x.id === a.dept);
  return `Tu es ${a.nom}, ${a.role} au sein du département « ${d.nom} » d'Atelier Roblox, un studio de 50 experts spécialisé dans la création de maps et d'expériences Roblox. Tes spécialités : ${a.skills.join(", ")}. ${a.focus}`;
}

/* ---------- schémas des sorties structurées ---------- */
function objet(props, requis) {
  return { type: "object", additionalProperties: false, properties: props, required: requis || Object.keys(props) };
}
const S_TEXTE = { type: "string" };
const S_LISTE_TEXTE = { type: "array", items: { type: "string" } };
const S_TACHES_PROPOSEES = {
  type: "array",
  items: objet({
    titre: { type: "string", description: "Tâche concrète et vérifiable" },
    phase: { type: "integer", description: "Index de la phase de production, de 0 à 6" },
    charge: { type: "string", enum: ["S", "M", "L"] },
  }),
};

/* avecTexte = true : le texte long voyage dans la réponse (application).
   avecTexte = false : l'agent l'écrit dans un fichier (workflow Claude Code). */
const SCHEMAS = {
  canon: avecTexte => objet(Object.assign(
    { titre: { type: "string", description: "Titre définitif du jeu" },
      pitch: { type: "string", description: "Le pitch en une ou deux phrases" } },
    avecTexte ? { canon: { type: "string", description: "Le canon complet en markdown" } } : {})),
  contribution: avecTexte => objet(Object.assign(
    avecTexte ? { livrable: { type: "string", description: "Le livrable complet en markdown" } } : {},
    { decisions: Object.assign({ description: "3 à 6 décisions clés que les autres départements doivent connaître" }, S_LISTE_TEXTE),
      besoins: { type: "array", description: "Ce dont tu as besoin des autres départements", items: objet({
        de: { type: "string", description: "Rôle du collègue concerné" }, besoin: S_TEXTE }) },
      taches: S_TACHES_PROPOSEES })),
  qa: avecTexte => objet(Object.assign(
    avecTexte ? { rapport: { type: "string", description: "Le rapport de relecture en markdown" } } : {},
    { problemes: { type: "array", items: objet({
        gravite: { type: "string", enum: ["bloquant", "majeur", "mineur"] },
        agent: { type: "string", description: "Identifiant de l'agent concerné (ex. a26), ou « studio » si transverse" },
        probleme: S_TEXTE,
        correction: S_TEXTE }) } })),
  coordination: avecTexte => objet(Object.assign(
    avecTexte ? { synthese: { type: "string", description: "La note de coordination en markdown" } } : {},
    { conflits: { type: "array", items: objet({
        sujet: S_TEXTE,
        agents: Object.assign({ description: "Identifiants des agents concernés" }, S_LISTE_TEXTE),
        arbitrage: S_TEXTE }) },
      revisions: { type: "array", description: "12 révisions au maximum, les plus importantes", items: objet({
        agent: { type: "string", description: "Identifiant de l'agent qui doit réviser (ex. a07)" },
        consignes: S_TEXTE }) } })),
  plan: avecTexte => objet(Object.assign(
    avecTexte ? { plan: { type: "string", description: "Le plan de production en markdown" } } : {},
    { taches: { type: "array", items: objet({
        titre: S_TEXTE,
        phase: { type: "integer", description: "Index de la phase de production, de 0 à 6" },
        agents: Object.assign({ description: "Identifiants des agents assignés (ex. a16)" }, S_LISTE_TEXTE),
        note: S_TEXTE }) } })),
  bible: avecTexte => objet(Object.assign(
    { titre: S_TEXTE, pitch: S_TEXTE },
    avecTexte ? { bible: { type: "string", description: "La synthèse du directeur créatif en markdown" } } : {})),
};

/* ---------- résumés partagés entre agents ---------- */
function listePhases() {
  return PHASES.map((p, i) => `${i} = ${p}`).join(" ; ");
}
function annuaire(ids) {
  return ids.map(id => {
    const a = AGENTS.find(x => x.id === id);
    return `${a.id} ${a.role} (${a.nom})`;
  }).join(" ; ");
}
/* contributions : { a06: { decisions, besoins, taches, ... }, ... } */
function digestDecisions(contributions) {
  const lignes = [];
  for (const d of DEPTS.filter(x => DEPTS_CREATEURS.includes(x.id))) {
    const membres = AGENTS.filter(a => a.dept === d.id && contributions[a.id]);
    if (!membres.length) continue;
    lignes.push(`## ${d.emoji} ${d.nom}`);
    for (const a of membres) {
      const c = contributions[a.id];
      lignes.push(`### ${a.id} — ${a.role} (${a.nom})`);
      for (const dec of c.decisions || []) lignes.push(`- ${dec}`);
      for (const b of c.besoins || []) lignes.push(`- Besoin auprès de ${b.de} : ${b.besoin}`);
    }
  }
  return lignes.join("\n");
}
function digestProblemes(qa, gravites) {
  const lignes = [];
  for (const [id, r] of Object.entries(qa)) {
    const a = AGENTS.find(x => x.id === id);
    for (const p of r.problemes || []) {
      if (gravites && !gravites.includes(p.gravite)) continue;
      lignes.push(`- [${p.gravite}] signalé par ${a.role}, concerne ${p.agent} : ${p.probleme} → correction proposée : ${p.correction}`);
    }
  }
  return lignes.join("\n");
}
function digestTaches(contributions) {
  const lignes = [];
  for (const [id, c] of Object.entries(contributions)) {
    for (const t of c.taches || []) lignes.push(`- ${id} | phase ${t.phase} | charge ${t.charge} | ${t.titre}`);
  }
  return lignes.join("\n");
}

/* ---------- les consignes de chaque étape ---------- */
function blocBrief(brief) {
  return `# Le brief du client\n${brief}`;
}
function blocCanon(canon) {
  return `# Le canon du directeur créatif (fait foi)\n${canon}`;
}

const TACHES = {
  benchmark: brief => `${blocBrief(brief)}

# Ta mission
${LIVRABLES.a05}

${FORMAT_LIVRABLE}`,

  da: brief => `${blocBrief(brief)}

# Ta mission
${LIVRABLES.a04}

${FORMAT_LIVRABLE}`,

  canon: (brief, benchmark, da) => `${blocBrief(brief)}

# L'analyse de marché de ${AGENTS.find(a => a.id === "a05").nom}
${benchmark || "(indisponible)"}

# La direction artistique de ${AGENTS.find(a => a.id === "a04").nom}
${da || "(indisponible)"}

# Ta mission
Écris le CANON du projet : le document court que les 49 autres membres du studio respecteront à la lettre. Il contient obligatoirement ces sections :
1. Titre et pitch.
2. Les 3 piliers du jeu (ce qui doit être incroyable).
3. Le public visé et la plateforme prioritaire.
4. La boucle de jeu en 5 lignes.
5. Les zones de la map : un nom officiel pour chacune (5 à 8 zones), sa fonction et son ambiance.
6. Les noms officiels : monnaies, ressources, personnages, objets clés.
7. La direction artistique résumée (reprends la palette hexadécimale retenue).
8. Les contraintes techniques (appareils, nombre de joueurs par serveur, budget de performance global).
9. Ce que le jeu n'est PAS (pour éviter les dérives).
Le canon fait entre 600 et 1100 mots, en markdown. Intègre le meilleur de l'analyse de marché et de la direction artistique, et tranche : pas d'alternatives, des décisions.`,

  contribution: (a, brief, canon) => `${blocBrief(brief)}

${blocCanon(canon)}

# Ta mission
${LIVRABLES[a.id]}

${FORMAT_LIVRABLE}

Pour tes tâches proposées, utilise ces phases de production : ${listePhases()}.`,

  qa: (a, brief, canon, dossier) => `${blocBrief(brief)}

${blocCanon(canon)}

# Ta mission de relecture
${LIVRABLES[a.id]}

# Ce que tu relis
${dossier}

# Consignes
Pour chaque problème, indique l'identifiant de l'agent qui doit corriger (annuaire : ${annuaire(CREATEURS)}), sa gravité (bloquant, majeur, mineur) et une correction concrète. Sois exigeant mais juste : ne signale que des problèmes réels. Ton rapport est un markdown de 400 à 1000 mots.`,

  coordination: (brief, canon, decisions, problemes) => `${blocBrief(brief)}

${blocCanon(canon)}

# Les décisions et besoins de chaque spécialiste
${decisions}

# Les problèmes signalés par la QA
${problemes || "(aucun problème signalé)"}

# Ta mission
Tu coordonnes le studio. Repère les contradictions entre départements (deux agents qui décident des choses incompatibles), les besoins restés sans réponse et les écarts au canon, puis tranche. Liste ensuite les révisions à faire : au maximum 12, les plus importantes, chacune adressée à un seul agent (annuaire : ${annuaire(CREATEURS)}) avec des consignes précises qui intègrent tes arbitrages et les problèmes QA bloquants ou majeurs qui le concernent. Ta note de coordination est un markdown de 400 à 900 mots.`,

  revision: (a, canon, livrable, consignes, problemes) => `${blocCanon(canon)}

# Ton livrable actuel
${livrable}

# Consignes du chef de projet
${consignes}

# Problèmes QA te concernant
${problemes || "(aucun)"}

# Ta mission
Réécris ton livrable complet en appliquant les consignes et en corrigeant les problèmes, sans perdre ce qui était bon. Mets à jour tes décisions, besoins et tâches.

${FORMAT_LIVRABLE}

Pour tes tâches proposées, utilise ces phases de production : ${listePhases()}.`,

  plan: (brief, canon, taches, arbitrages) => `${blocBrief(brief)}

${blocCanon(canon)}

# Les tâches proposées par les spécialistes (agent | phase | charge | tâche)
${taches}

# Les arbitrages du chef de projet
${arbitrages || "(aucun)"}

# Ta mission
Construis le plan de production : regroupe et dédoublonne les tâches, ordonne-les par phase (${listePhases()}), assigne chacune à 1 à 3 agents (annuaire : ${annuaire(AGENTS.map(x => x.id))}), et fixe les jalons avec leurs critères de validation. Vise 25 à 45 tâches concrètes et vérifiables. Ton plan est un markdown de 500 à 1100 mots (jalons, dépendances critiques, risques de planning).`,

  bible: (brief, canon, decisions, arbitrages, problemes) => `${blocBrief(brief)}

${blocCanon(canon)}

# Les décisions finales du studio
${decisions}

# Les arbitrages de coordination
${arbitrages || "(aucun)"}

# Les problèmes QA bloquants et majeurs
${problemes || "(aucun)"}

# Ta mission
Le studio a terminé ses livrables et la productrice rédige en parallèle le plan de production détaillé. Écris la synthèse de la bible de production, celle que lit en premier toute personne qui rejoint le projet. Sections obligatoires :
1. Le jeu en une page (pitch, piliers, public).
2. L'expérience du joueur : les 10 moments clés d'une première session, dans l'ordre.
3. Ce qui rend cette map incroyable (la promesse, et comment chaque département y contribue).
4. Les décisions structurantes, département par département.
5. Les 5 risques principaux et leur parade.
6. Les prochaines étapes immédiates.
Markdown de 1000 à 1800 mots, inspirant et précis.`,
};

/* ---------- export de la bible complète en markdown ---------- */
/* une valeur prête à entrer dans une cellule de tableau markdown */
function cellule(v) {
  return String(v == null ? "" : v).replace(/\r?\n+/g, " ").replace(/\|/g, "∣").trim();
}
function productionEnMarkdown(prod) {
  const out = [];
  const titre = (prod.bible && prod.bible.titre) || (prod.vision && prod.vision.titre) || "Production";
  out.push(`# 📖 ${titre} — Bible de production`);
  out.push(`*Atelier Roblox · ${AGENTS.length} agents · ${prod.source === "claude-code" ? "workflow Claude Code" : "application"}*`);
  if (prod.bible && prod.bible.pitch) out.push(`> ${prod.bible.pitch}`);
  out.push(`## Le brief\n${prod.brief}`);
  if (prod.bible && prod.bible.bible) out.push(`## ⭐ Synthèse du directeur créatif\n${prod.bible.bible}`);
  if (prod.vision) {
    if (prod.vision.canon) out.push(`## 🧭 Le canon\n${prod.vision.canon}`);
    if (prod.vision.da) out.push(`## 🖼️ Direction artistique\n${prod.vision.da}`);
    if (prod.vision.benchmark) out.push(`## ⚖️ Analyse de marché\n${prod.vision.benchmark}`);
  }
  for (const d of DEPTS.filter(x => DEPTS_CREATEURS.includes(x.id))) {
    const membres = AGENTS.filter(a => a.dept === d.id && prod.contributions && prod.contributions[a.id]);
    if (!membres.length) continue;
    out.push(`## ${d.emoji} ${d.nom}`);
    for (const a of membres) {
      const c = prod.contributions[a.id];
      out.push(`### ${a.emoji} ${a.role} — ${a.nom}${c.revise ? " (révisé)" : ""}\n${c.livrable || ""}`);
    }
  }
  if (prod.qa && Object.keys(prod.qa).length) {
    out.push(`## 🧪 Revue QA`);
    for (const a of AGENTS.filter(x => prod.qa[x.id])) {
      out.push(`### ${a.emoji} ${a.role} — ${a.nom}\n${prod.qa[a.id].rapport || ""}`);
    }
  }
  if (prod.coordination) {
    out.push(`## 🤝 Coordination\n${prod.coordination.synthese || ""}`);
    const conflits = (prod.coordination.conflits || []).map(c =>
      `| ${cellule(c.sujet)} | ${cellule((c.agents || []).join(", "))} | ${cellule(c.arbitrage)} |`);
    if (conflits.length) out.push(`### Arbitrages\n| Sujet | Agents | Arbitrage |\n|---|---|---|\n${conflits.join("\n")}`);
  }
  if (prod.plan) {
    out.push(`## 📋 Plan de production\n${prod.plan.plan || ""}`);
    const lignes = (prod.plan.taches || []).map(t =>
      `| ${cellule(PHASES[t.phase] || t.phase)} | ${cellule(t.titre)} | ${cellule((t.agents || []).join(", "))} |`);
    if (lignes.length) out.push(`### Tâches\n| Phase | Tâche | Agents |\n|---|---|---|\n${lignes.join("\n")}`);
  }
  return out.join("\n\n");
}


/* =========================================================================
   Corps du workflow Claude Code « atelier-roblox ».
   Ce fichier n'est pas exécuté tel quel : generer.js le concatène après
   le bloc meta, agents.js et production.js pour produire
   .claude/workflows/atelier-roblox.js.
   Chaque agent écrit son livrable (markdown + fiche JSON) dans
   studio/productions/<projet>/ avec l'outil Write uniquement : les agents
   d'un workflow tournent sans surveillance et ne peuvent pas faire
   approuver de commandes. Le workflow renvoie la commande d'assemblage
   (assembler.js → production.json) que la session appelante exécute.
   ========================================================================= */

const entree = typeof args === "string" ? { brief: args } : (args || {})
const BRIEF = String(entree.brief || "").trim()
if (!BRIEF) {
  throw new Error('Brief manquant. Exemple : Workflow({ name: "atelier-roblox", args: { nom: "Île du Volcan", brief: "Une île tropicale..." } })')
}
const NOM = String(entree.nom || BRIEF.split(/\s+/).slice(0, 6).join(" ")).trim()
const par = id => AGENTS.find(a => a.id === id)
const etiquette = a => `${a.emoji} ${a.nom.split(" ")[0]} · ${a.role}`

/* consignes de livraison ajoutées à chaque tâche */
function livraison(chemin, fiche, extra) {
  const md = `${RACINE}/${chemin}.md`
  const json = `${RACINE}/${chemin}.json`
  const etapes = [`Écris ton livrable complet en markdown dans \`${md}\` avec l'outil Write (il crée les dossiers manquants).`]
  if (extra) etapes.push(extra)
  if (fiche) etapes.push(`Écris dans \`${json}\`, avec l'outil Write, ${fiche}. Ce fichier doit être du JSON strictement valide (guillemets doubles, aucune virgule finale, aucun commentaire).`)
  etapes.push(fiche ? "Termine par ta réponse structurée." : "Termine en répondant simplement « livré ».")
  return `\n\n# Livraison (obligatoire)\n${etapes.map((e, i) => `${i + 1}. ${e}`).join("\n")}\nN'utilise jamais l'outil Bash (aucune commande ne peut être approuvée pendant la production). Pour remplacer un fichier existant, lis-le d'abord avec l'outil Read : Write l'exige. N'explore pas le reste du dépôt et n'écris nulle part ailleurs que dans ${RACINE}/.`
}
const FICHE_IDENTIQUE = "exactement le même objet JSON que ta réponse structurée"
const prompt = (a, tache, liv) => `${personaPrompt(a)}\n\n${REGLES_STUDIO}\n\n${tache}${liv}`

/* ======================= 1. Vision ======================= */
phase("Vision")
/* un dossier neuf par lancement : jamais de mélange avec une production précédente */
const BASE = `studio/productions/${slugProd(NOM)}`
const FORME_DOSSIER = new RegExp(`^${BASE.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}(-\\d+)?$`)
let RACINE = null
if (typeof entree.dossier === "string") {
  if (!/^studio\/productions\/[a-z0-9-]+$/.test(entree.dossier)) throw new Error(`Dossier invalide : ${entree.dossier} (attendu : studio/productions/<nom>)`)
  RACINE = entree.dossier
} else {
  const reserve = await agent(
    `N'utilise pas l'outil Bash et ne crée rien. Trouve le premier dossier libre dans cette suite : ${BASE}, ${BASE}-2, ${BASE}-3, ${BASE}-4, ${BASE}-5…
Pour chaque candidat, dans l'ordre, fais un appel séparé à l'outil Glob avec le motif « <candidat>/**/* » (par exemple ${BASE}-2/**/*) : si l'appel ne renvoie aucun fichier, ce candidat est libre, arrête-toi et renvoie-le. Ne te fie jamais à un seul Glob pour plusieurs dossiers : ses résultats sont tronqués à 100 fichiers.`,
    { label: "📁 Réservation du dossier", phase: "Vision", effort: "low",
      schema: objet({ dossier: { type: "string", description: `Le premier dossier libre, de la forme ${BASE} ou ${BASE}-<n>` } }) })
  const brut = reserve && String(reserve.dossier || "")
  const d = brut && brut.replace(/[`'"]/g, "").trim().replace(/^.*?(studio\/productions\/)/, "$1").replace(/^\.\//, "").replace(/\/+$/, "")
  if (!d || !FORME_DOSSIER.test(d)) {
    throw new Error(`Réservation du dossier impossible (réponse : ${brut || "aucune"}). Relancez en précisant args.dossier avec un dossier vide de la forme ${BASE}-<n>.`)
  }
  RACINE = d
}
/* contrôle indépendant : le dossier retenu doit être vide (une production ne réutilise jamais un dossier) */
{
  const controle = await agent(
    `N'utilise pas l'outil Bash et ne crée rien. Fais un seul appel à l'outil Glob avec le motif \`${RACINE}/**/*\` et indique combien de fichiers il renvoie (0 si aucun).`,
    { label: "🔎 Contrôle du dossier", phase: "Vision", effort: "low",
      schema: objet({ fichiers: { type: "integer", description: "Nombre de fichiers trouvés" } }) })
  if (!controle || !Number.isInteger(controle.fichiers)) throw new Error(`Impossible de vérifier que ${RACINE} est vide : production arrêtée.`)
  if (controle.fichiers > 0) {
    throw new Error(`${RACINE} contient déjà ${controle.fichiers} fichier(s) : une production s'écrit toujours dans un dossier vide. Relancez sans args.dossier, ou avec un dossier vide.`)
  }
}
/* réservation exclusive : Write refuse de remplacer un fichier que l'agent n'a pas lu,
   donc un seul lancement peut créer le marqueur (deux lancements simultanés du même nom) */
const marqueur = await agent(
  `N'utilise pas l'outil Bash et surtout ne lis PAS le fichier avant. Avec l'outil Write, crée le fichier \`${RACINE}/.reservation\` contenant exactement : ${JSON.stringify(NOM)}
Si l'outil Write échoue (par exemple parce que le fichier existe déjà), n'insiste pas et réponds cree = false ; s'il réussit, réponds cree = true.`,
  { label: "🔐 Réservation exclusive", phase: "Vision", effort: "low", schema: objet({ cree: { type: "boolean" } }) })
if (!marqueur || marqueur.cree !== true) {
  throw new Error(`${RACINE} vient d'être pris par un autre lancement : relancez, un nouveau dossier sera réservé.`)
}
const echecs = []
log(`Brief reçu pour « ${NOM} ». Livrables dans ${RACINE}/`)
const bench = par(ROLES_PROD.benchmark), da = par(ROLES_PROD.da), directeur = par(ROLES_PROD.canon)
const [okBrief, okBench, okDa] = await parallel([
  () => agent(`N'utilise pas l'outil Bash. Avec l'outil Write :
1. écris dans \`${RACINE}/brief.md\` exactement le texte suivant, caractère pour caractère, sans rien ajouter ni reformuler (il est entre les deux lignes de tirets) :
-----
${BRIEF}
-----
2. écris dans \`${RACINE}/infos.json\` exactement le texte suivant (entre les deux lignes de tirets) :
-----
${JSON.stringify({ brief: BRIEF, provisoire: true })}
-----
Puis réponds « livré ».`,
    { label: "📝 Archivage du brief", phase: "Vision", effort: "low" }),
  () => agent(prompt(bench, TACHES.benchmark(BRIEF), livraison(CHEMINS_SPECIAUX.benchmark)),
    { label: etiquette(bench), phase: "Vision" }),
  () => agent(prompt(da, TACHES.da(BRIEF), livraison(CHEMINS_SPECIAUX.da)),
    { label: etiquette(da), phase: "Vision" }),
])
if (!okBrief) log("brief.md n'a pas pu être écrit : la commande d'assemblage transmet de toute façon le brief exact.")
if (!okBench) echecs.push("vision:a05")
if (!okDa) echecs.push("vision:a04")
const lire = chemin => `(lis en entier le fichier \`${RACINE}/${chemin}.md\` ; s'il n'existe pas, fais sans)`
const canon = await agent(
  prompt(directeur,
    TACHES.canon(BRIEF, lire(CHEMINS_SPECIAUX.benchmark), lire(CHEMINS_SPECIAUX.da)),
    livraison(CHEMINS_SPECIAUX.canon,
      "l'objet JSON { \"titre\", \"pitch\" } avec les mêmes valeurs que ta réponse structurée")),
  { label: `${etiquette(directeur)} (canon)`, phase: "Vision", schema: SCHEMAS.canon(true) })
if (!canon || !canon.canon) throw new Error(`Le directeur créatif n'a pas pu écrire le canon : production arrêtée (dossier ${RACINE}).`)
log(`Canon établi : « ${canon.titre} » — ${canon.pitch}`)

/* ======================= 2. Contributions ======================= */
phase("Contributions")
const contributions = {}
/* chaque scripteur a son propre dossier de scripts : pas d'écrasement entre agents */
const consigneScripts = a => `Écris aussi chaque script complet dans \`${RACINE}/scripts/${a.id}/\` avec la convention Rojo (NomDuScript.server.lua, .client.lua ou .lua pour un ModuleScript) et indique son emplacement Roblox en première ligne de commentaire.`
const resultats = await parallel(CREATEURS.map(id => () => {
  const a = par(id)
  const extra = a.dept === "code" ? consigneScripts(a) : ""
  return agent(prompt(a, TACHES.contribution(a, BRIEF, canon.canon), livraison(cheminLivrable(a), FICHE_IDENTIQUE, extra)),
    { label: etiquette(a), phase: "Contributions", schema: SCHEMAS.contribution(false) })
    .then(r => ({ id, r }))
}))
for (const [i, res] of resultats.entries()) {
  if (res && res.r) contributions[res.id] = res.r
  else echecs.push(`contrib:${CREATEURS[i]}`)
}
log(`${Object.keys(contributions).length}/${CREATEURS.length} contributions livrées` +
  (echecs.length ? ` — manquantes : ${echecs.join(", ")}` : ""))

/* ======================= 3. Revue QA ======================= */
phase("Revue QA")
const qa = {}
const retoursQA = await parallel(RELECTEURS_QA.map(id => () => {
  const a = par(id)
  const fichiers = AGENTS
    .filter(x => FOCUS_QA[id].includes(x.dept) && contributions[x.id])
    .map(x => `- ${x.id} ${x.role} : \`${RACINE}/${cheminLivrable(x)}.md\``)
  const dossier = fichiers.length
    ? `Lis en entier ces livrables :\n${fichiers.join("\n")}\n\nEt voici les décisions de tout le studio :\n${digestDecisions(contributions)}`
    : `Les décisions de tout le studio :\n${digestDecisions(contributions)}`
  return agent(prompt(a, TACHES.qa(a, BRIEF, canon.canon, dossier), livraison(cheminLivrable(a), FICHE_IDENTIQUE)),
    { label: etiquette(a), phase: "Revue QA", schema: SCHEMAS.qa(false) })
    .then(r => ({ id, r }))
}))
for (const [i, res] of retoursQA.entries()) {
  if (res && res.r) qa[res.id] = res.r
  else echecs.push(`qa:${RELECTEURS_QA[i]}`)
}
const nbProblemes = Object.values(qa).reduce((n, r) => n + (r.problemes || []).length, 0)
log(`${nbProblemes} problèmes signalés par la QA`)

/* ======================= 4. Coordination ======================= */
phase("Coordination")
const chef = par(ROLES_PROD.coordination)
const coordination = await agent(
  prompt(chef, TACHES.coordination(BRIEF, canon.canon, digestDecisions(contributions), digestProblemes(qa)),
    livraison(CHEMINS_SPECIAUX.coordination, FICHE_IDENTIQUE)),
  { label: etiquette(chef), phase: "Coordination", schema: SCHEMAS.coordination(false) })
if (!coordination) echecs.push("coord:a03")
const arbitrages = coordination
  ? coordination.conflits.map(c => `- ${c.sujet} (${c.agents.join(", ")}) → ${c.arbitrage}`).join("\n")
  : ""

/* ======================= 5. Révisions ======================= */
phase("Révisions")
const aReviser = {}
for (const r of (coordination ? coordination.revisions : [])) {
  if (!aCle(contributions, r.agent)) continue
  aReviser[r.agent] = aCle(aReviser, r.agent) ? `${aReviser[r.agent]}\n${r.consignes}` : r.consignes
}
const ignorees = coordination ? coordination.revisions.filter(r => !aCle(contributions, r.agent)).length : 0
log(`${Object.keys(aReviser).length} agents révisent leur livrable` + (ignorees ? ` (${ignorees} demandes ignorées : agent inconnu ou sans livrable)` : ""))
await parallel(Object.entries(aReviser).map(([id, consignes]) => () => {
  const a = par(id)
  const problemes = Object.values(qa).flatMap(r => r.problemes || [])
    .filter(p => p.agent === id)
    .map(p => `- [${p.gravite}] ${p.probleme} → ${p.correction}`).join("\n")
  return agent(
    prompt(a, TACHES.revision(a, canon.canon, lire(cheminLivrable(a)), consignes, problemes),
      livraison(cheminLivrable(a), `${FICHE_IDENTIQUE}, avec en plus le champ "revise": true`,
        "Remplace le fichier existant par la version révisée complète." + (a.dept === "code"
          ? ` Réécris aussi tes scripts dans \`${RACINE}/scripts/${a.id}/\` pour qu'ils restent identiques au code de ton livrable : remplace chaque fichier par sa version corrigée, et remplace le contenu d'un script devenu inutile par la seule ligne « -- SUPPRIMÉ ».`
          : ""))),
    { label: `${etiquette(a)} (révision)`, phase: "Révisions", schema: SCHEMAS.contribution(false) })
    .then(r => {
      if (r) contributions[id] = Object.assign({ revise: true }, r)
      else echecs.push(`rev:${id}`)
    })
}))

/* ======================= 6. Plan & Bible ======================= */
phase("Plan & Bible")
const productrice = par(ROLES_PROD.plan)
const [plan, bible] = await parallel([
  () => agent(
    prompt(productrice, TACHES.plan(BRIEF, canon.canon, digestTaches(contributions), arbitrages),
      livraison(CHEMINS_SPECIAUX.plan, FICHE_IDENTIQUE)),
    { label: etiquette(productrice), phase: "Plan & Bible", schema: SCHEMAS.plan(false) }),
  () => agent(
    prompt(directeur, TACHES.bible(BRIEF, canon.canon, digestDecisions(contributions), arbitrages,
      digestProblemes(qa, ["bloquant", "majeur"])),
      livraison(CHEMINS_SPECIAUX.bible, FICHE_IDENTIQUE)),
    { label: `${etiquette(directeur)} (bible)`, phase: "Plan & Bible", schema: SCHEMAS.bible(false) }),
])
if (!plan) echecs.push("plan:a02")
if (!bible) echecs.push("bible:a01")

/* ======================= 7. Assemblage ======================= */
/* le brief exact et les échecs passent par l'entrée standard ; une copie reste sur disque (infos.json)
   pour que l'assembleur puisse être relancé plus tard sans cette commande */
const INFOS = JSON.stringify({ brief: BRIEF, echecs })
const okInfos = await agent(
  `N'utilise pas l'outil Bash. Lis d'abord \`${RACINE}/infos.json\` avec Read s'il existe, puis, avec l'outil Write, remplace-le par exactement le texte suivant, caractère pour caractère (il est entre les deux lignes de tirets), puis réponds « livré » :\n-----\n${INFOS}\n-----`,
  { label: "📝 Archivage des infos", phase: "Plan & Bible", effort: "low" })
if (!okInfos) log("infos.json n'a pas pu être écrit : utilisez la commande d'assemblage renvoyée, qui transmet le brief et les échecs.")
const ASSEMBLAGE = `node studio/assembler.js ${RACINE} --infos-stdin <<'FIN_INFOS_ATELIER'\n${INFOS}\nFIN_INFOS_ATELIER`
log(`Production terminée. Pour produire production.json et BIBLE-COMPLETE.md, exécuter la commande renvoyée dans « assemblage ».`)

return {
  dossier: RACINE,
  titre: (bible && bible.titre) || canon.titre,
  pitch: (bible && bible.pitch) || canon.pitch,
  contributions: `${Object.keys(contributions).length}/${CREATEURS.length}`,
  revues_qa: Object.keys(qa).length,
  problemes_qa: nbProblemes,
  conflits: coordination ? coordination.conflits.length : 0,
  revisions: Object.keys(aReviser).length,
  taches_planifiees: plan ? plan.taches.length : 0,
  echecs,
  a_faire: "Exécuter la commande « assemblage » ci-dessous depuis la racine du dépôt, puis importer production.json dans l'application.",
  assemblage: ASSEMBLAGE,
}
