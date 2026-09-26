#!/usr/bin/env node
/* Rassemble une production écrite par le workflow Claude Code
   (studio/productions/<projet>/) en deux fichiers :
   - production.json : importable dans l'application (bouton « Importer une production »)
   - BIBLE-COMPLETE.md : toute la bible de production en un seul document
   Usage :
     node studio/assembler.js studio/productions/<projet> [--infos-stdin]
       --infos-stdin : lit sur l'entrée standard { brief, echecs } transmis par le workflow
     node studio/assembler.js --reserver studio/productions/<projet>
       crée et affiche un dossier neuf (<projet>, <projet>-2, …) pour une nouvelle production */
"use strict";
const fs = require("fs");
const path = require("path");

if (process.argv[2] === "--reserver") {
  const base = (process.argv[3] || "").replace(/\/+$/, "");
  if (!base.startsWith("studio/productions/")) {
    console.error("Usage : node studio/assembler.js --reserver studio/productions/<projet>");
    process.exit(1);
  }
  const libre = d => !fs.existsSync(d) || fs.readdirSync(d).length === 0;
  let dossier = base;
  for (let n = 2; !libre(dossier); n++) dossier = `${base}-${n}`;
  fs.mkdirSync(dossier, { recursive: true });
  console.log(dossier);
  process.exit(0);
}

const racine = process.argv[2];
if (!racine || !fs.existsSync(racine)) {
  console.error("Usage : node studio/assembler.js studio/productions/<projet> [--infos-stdin]");
  process.exit(1);
}
let infos = {};
if (process.argv.includes("--infos-stdin")) {
  try {
    const brut = JSON.parse(fs.readFileSync(0, "utf8"));
    if (brut && typeof brut === "object") infos = brut;
  } catch (e) {
    console.log(`- infos du workflow illisibles (${e.message}) : brief repris du canon`);
  }
}

const lib = n => fs.readFileSync(path.join(__dirname, n), "utf8");
const S = new Function(lib("agents.js") + "\n" + lib("production.js") + `
  return { DEPTS, AGENTS, PHASES, CREATEURS, RELECTEURS_QA, CHEMINS_SPECIAUX, cheminLivrable, productionEnMarkdown };`)();

const manquants = [];
const invalides = [];
function lireMd(chemin) {
  const f = path.join(racine, chemin + ".md");
  if (!fs.existsSync(f)) { manquants.push(chemin + ".md"); return null; }
  return fs.readFileSync(f, "utf8").trim();
}
function lireJson(chemin) {
  const f = path.join(racine, chemin + ".json");
  if (!fs.existsSync(f)) { manquants.push(chemin + ".json"); return null; }
  try { return JSON.parse(fs.readFileSync(f, "utf8")); }
  catch (e) { invalides.push(`${chemin}.json (${e.message})`); return null; }
}
const tableau = v => Array.isArray(v) ? v : [];
const idsValides = new Set(S.AGENTS.map(a => a.id));

/* ---------- vision ---------- */
const ficheCanon = lireJson(S.CHEMINS_SPECIAUX.canon) || {};
const vision = {
  benchmark: lireMd(S.CHEMINS_SPECIAUX.benchmark),
  da: lireMd(S.CHEMINS_SPECIAUX.da),
  canon: lireMd(S.CHEMINS_SPECIAUX.canon),
  titre: ficheCanon.titre || null,
  pitch: ficheCanon.pitch || null,
};

/* ---------- contributions et revues ---------- */
const contributions = {};
for (const id of S.CREATEURS) {
  const a = S.AGENTS.find(x => x.id === id);
  const md = lireMd(S.cheminLivrable(a));
  const fiche = lireJson(S.cheminLivrable(a));
  if (!md && !fiche) continue;
  contributions[id] = {
    livrable: md || "",
    decisions: tableau(fiche && fiche.decisions),
    besoins: tableau(fiche && fiche.besoins),
    taches: tableau(fiche && fiche.taches),
    revise: !!(fiche && fiche.revise),
  };
}
const qa = {};
for (const id of S.RELECTEURS_QA) {
  const a = S.AGENTS.find(x => x.id === id);
  const md = lireMd(S.cheminLivrable(a));
  const fiche = lireJson(S.cheminLivrable(a));
  if (!md && !fiche) continue;
  qa[id] = { rapport: md || "", problemes: tableau(fiche && fiche.problemes) };
}

/* ---------- coordination, plan, bible ---------- */
const ficheCoord = lireJson(S.CHEMINS_SPECIAUX.coordination);
const mdCoord = lireMd(S.CHEMINS_SPECIAUX.coordination);
const coordination = (ficheCoord || mdCoord) ? {
  synthese: mdCoord || "",
  conflits: tableau(ficheCoord && ficheCoord.conflits),
  revisions: tableau(ficheCoord && ficheCoord.revisions),
} : null;

const fichePlan = lireJson(S.CHEMINS_SPECIAUX.plan);
const mdPlan = lireMd(S.CHEMINS_SPECIAUX.plan);
const plan = (fichePlan || mdPlan) ? {
  plan: mdPlan || "",
  taches: tableau(fichePlan && fichePlan.taches).map(t => ({
    titre: String(t.titre || ""),
    phase: Number.isInteger(t.phase) ? Math.min(Math.max(t.phase, 0), S.PHASES.length - 1) : 0,
    agents: tableau(t.agents).filter(x => idsValides.has(x)),
    note: String(t.note || ""),
  })).filter(t => t.titre),
} : null;

const ficheBible = lireJson(S.CHEMINS_SPECIAUX.bible) || {};
const mdBible = lireMd(S.CHEMINS_SPECIAUX.bible);
const bible = mdBible ? {
  titre: ficheBible.titre || vision.titre || path.basename(racine),
  pitch: ficheBible.pitch || vision.pitch || "",
  bible: mdBible,
} : null;

/* ---------- scripts Luau écrits par le département scripting ---------- */
const scripts = {};
const dossierScripts = path.join(racine, "scripts");
if (fs.existsSync(dossierScripts)) {
  (function parcourir(dir, prefixe) {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const complet = path.join(dir, e.name);
      if (e.isDirectory()) parcourir(complet, prefixe + e.name + "/");
      else if (/\.(lua|luau)$/.test(e.name)) {
        const code = fs.readFileSync(complet, "utf8");
        if (!/^\s*--\s*SUPPRIM/i.test(code)) scripts[prefixe + e.name] = code;
      }
    }
  })(dossierScripts, "");
}

/* ---------- échecs, avec les mêmes clés d'étape que l'application ---------- */
const echecs = {};
const manque = (cle, raison) => { if (!echecs[cle]) echecs[cle] = raison; };
if (!vision.benchmark) manque("vision:a05", "analyse de marché absente");
if (!vision.da) manque("vision:a04", "direction artistique absente");
if (!vision.canon) manque("vision:a01", "canon absent");
for (const id of S.CREATEURS) if (!contributions[id]) manque(`contrib:${id}`, "livrable absent");
for (const id of S.RELECTEURS_QA) if (!qa[id]) manque(`qa:${id}`, "relecture absente");
if (!coordination) manque("coord:a03", "coordination absente");
for (const r of (coordination ? coordination.revisions : [])) {
  if (contributions[r.agent] && !contributions[r.agent].revise) manque(`rev:${r.agent}`, "révision demandée mais non livrée");
}
if (!plan) manque("plan:a02", "plan absent");
if (!bible) manque("bible:a01", "synthèse absente");
for (const cle of Array.isArray(infos.echecs) ? infos.echecs : []) {
  if (typeof cle === "string" && /^[a-z]+:a\d\d$/.test(cle)) manque(cle, "échec de l'agent pendant le workflow");
}

/* ---------- assemblage ---------- */
const production = {
  id: "cc-" + path.basename(racine),
  source: "claude-code",
  nom: vision.titre || path.basename(racine),
  brief: typeof infos.brief === "string" && infos.brief ? infos.brief : (ficheCanon.brief || ""),
  modele: null,
  cree: fs.statSync(racine).mtimeMs,
  statut: Object.keys(echecs).length ? "incomplet" : "termine",
  vision,
  contributions,
  qa,
  coordination,
  revisionsFaites: Object.fromEntries(Object.entries(contributions).filter(([, c]) => c.revise).map(([id]) => [id, true])),
  plan,
  bible,
  scripts,
  echecs,
  ignores: {},
  usages: {},
};

fs.writeFileSync(path.join(racine, "production.json"), JSON.stringify(production, null, 2));
let md = S.productionEnMarkdown(production);
if (Object.keys(scripts).length) {
  md += "\n\n## 📜 Scripts Luau\n\n" + Object.entries(scripts)
    .map(([nom, code]) => `### ${nom}\n\`\`\`lua\n${code.trim()}\n\`\`\``).join("\n\n");
}
fs.writeFileSync(path.join(racine, "BIBLE-COMPLETE.md"), md);

const nbProblemes = Object.values(qa).reduce((n, r) => n + r.problemes.length, 0);
console.log(`Production « ${production.nom} » assemblée dans ${racine}/`);
console.log(`- vision : ${["benchmark", "da", "canon"].filter(k => vision[k]).length}/3 documents`);
console.log(`- contributions : ${Object.keys(contributions).length}/${S.CREATEURS.length} (dont ${Object.keys(production.revisionsFaites).length} révisées)`);
console.log(`- revues QA : ${Object.keys(qa).length}/${S.RELECTEURS_QA.length} (${nbProblemes} problèmes signalés)`);
console.log(`- coordination : ${coordination ? coordination.conflits.length + " conflits arbitrés" : "absente"}`);
console.log(`- plan : ${plan ? plan.taches.length + " tâches" : "absent"} · bible : ${bible ? "oui" : "absente"} · scripts Luau : ${Object.keys(scripts).length}`);
if (manquants.length) console.log(`- fichiers manquants : ${manquants.join(", ")}`);
if (invalides.length) console.log(`- fichiers JSON invalides (livrable gardé, décisions perdues) : ${invalides.join(", ")}`);
console.log(`- statut : ${production.statut}${Object.keys(echecs).length ? ` (${Object.keys(echecs).join(", ")})` : ""}`);
console.log(`→ production.json (à importer dans l'application) et BIBLE-COMPLETE.md écrits.`);
