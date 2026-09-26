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
