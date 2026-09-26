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
const lireInfos = (texte, origine) => {
  try {
    const v = JSON.parse(texte);
    if (v && typeof v === "object" && !Array.isArray(v)) return v;
  } catch (e) {
    console.log(`- infos du workflow illisibles (${origine} : ${e.message})`);
  }
  return null;
};
if (process.argv.includes("--infos-stdin")) infos = lireInfos(fs.readFileSync(0, "utf8"), "entrée standard") || {};
let origineInfos = Object.keys(infos).length ? "entrée standard" : null;
if (!Object.keys(infos).length && fs.existsSync(path.join(racine, "infos.json"))) {
  infos = lireInfos(fs.readFileSync(path.join(racine, "infos.json"), "utf8"), "infos.json") || {};
  if (Object.keys(infos).length) origineInfos = "infos.json";
}

const lib = n => fs.readFileSync(path.join(__dirname, n), "utf8");
const S = new Function(lib("agents.js") + "\n" + lib("production.js") + `
  return { DEPTS, AGENTS, PHASES, CREATEURS, RELECTEURS_QA, CHEMINS_SPECIAUX, cheminLivrable, productionEnMarkdown, estAgentId };`)();

const manquants = [];
const invalides = [];
const fichesInvalides = new Set();   // chemins dont la fiche JSON est absente ou illisible
function lireTexte(nom) {
  const f = path.join(racine, nom);
  return fs.existsSync(f) ? fs.readFileSync(f, "utf8").trim() : "";
}
function lireMd(chemin) {
  const f = path.join(racine, chemin + ".md");
  if (!fs.existsSync(f)) { manquants.push(chemin + ".md"); return null; }
  return fs.readFileSync(f, "utf8").trim();
}
function lireJson(chemin) {
  const f = path.join(racine, chemin + ".json");
  if (!fs.existsSync(f)) { manquants.push(chemin + ".json"); fichesInvalides.add(chemin); return null; }
  try {
    const v = JSON.parse(fs.readFileSync(f, "utf8"));
    if (v && typeof v === "object" && !Array.isArray(v)) return v;
    throw new Error("un objet JSON est attendu");
  } catch (e) { invalides.push(`${chemin}.json (${e.message})`); fichesInvalides.add(chemin); return null; }
}
const tableau = v => Array.isArray(v) ? v : [];
const objets = v => tableau(v).filter(x => x && typeof x === "object" && !Array.isArray(x));
const chaine = v => typeof v === "string" ? v : "";
const chaines = v => tableau(v).filter(x => typeof x === "string");

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
    decisions: chaines(fiche && fiche.decisions),
    besoins: objets(fiche && fiche.besoins).map(b => ({ de: chaine(b.de), besoin: chaine(b.besoin) })),
    taches: objets(fiche && fiche.taches).map(t => ({ titre: chaine(t.titre), phase: Number.isInteger(t.phase) ? t.phase : 0, charge: chaine(t.charge) || "M" })),
    revise: !!(fiche && fiche.revise),
  };
}
const qa = {};
for (const id of S.RELECTEURS_QA) {
  const a = S.AGENTS.find(x => x.id === id);
  const md = lireMd(S.cheminLivrable(a));
  const fiche = lireJson(S.cheminLivrable(a));
  if (!md && !fiche) continue;
  qa[id] = { rapport: md || "", problemes: objets(fiche && fiche.problemes).map(p => ({
    gravite: ["bloquant", "majeur", "mineur"].includes(p.gravite) ? p.gravite : "mineur",
    agent: chaine(p.agent), probleme: chaine(p.probleme), correction: chaine(p.correction) })) };
}

/* ---------- coordination, plan, bible ---------- */
const ficheCoord = lireJson(S.CHEMINS_SPECIAUX.coordination);
const mdCoord = lireMd(S.CHEMINS_SPECIAUX.coordination);
const coordination = (ficheCoord || mdCoord) ? {
  synthese: mdCoord || "",
  conflits: objets(ficheCoord && ficheCoord.conflits).map(c => ({ sujet: chaine(c.sujet), agents: chaines(c.agents), arbitrage: chaine(c.arbitrage) })),
  revisions: objets(ficheCoord && ficheCoord.revisions).map(r => ({ agent: chaine(r.agent), consignes: chaine(r.consignes) })),
} : null;

const fichePlan = lireJson(S.CHEMINS_SPECIAUX.plan);
const mdPlan = lireMd(S.CHEMINS_SPECIAUX.plan);
const plan = (fichePlan || mdPlan) ? {
  plan: mdPlan || "",
  taches: objets(fichePlan && fichePlan.taches).map(t => ({
    titre: chaine(t.titre),
    phase: Number.isInteger(t.phase) ? Math.min(Math.max(t.phase, 0), S.PHASES.length - 1) : 0,
    agents: chaines(t.agents).filter(S.estAgentId),
    note: chaine(t.note),
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
        if (code.trim() !== "-- SUPPRIMÉ") scripts[prefixe + e.name] = code;
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
  if (S.estAgentId(r.agent) && Object.prototype.hasOwnProperty.call(contributions, r.agent) && !contributions[r.agent].revise) manque(`rev:${r.agent}`, "révision demandée mais non livrée");
}
if (!plan) manque("plan:a02", "plan absent");
if (!bible) manque("bible:a01", "synthèse absente");
const fiche = (cle, chemin) => { if (fichesInvalides.has(chemin)) manque(cle, "fiche JSON absente ou illisible : décisions, tâches ou arbitrages perdus"); };
const texteVide = v => !v || !String(v).trim();
for (const id of S.CREATEURS) if (contributions[id] && texteVide(contributions[id].livrable)) manque(`contrib:${id}`, "livrable markdown absent ou vide");
for (const id of S.RELECTEURS_QA) if (qa[id] && texteVide(qa[id].rapport)) manque(`qa:${id}`, "rapport markdown absent ou vide");
if (coordination && texteVide(coordination.synthese)) manque("coord:a03", "note de coordination absente ou vide");
if (plan && texteVide(plan.plan)) manque("plan:a02", "plan markdown absent ou vide");
fiche("vision:a01", S.CHEMINS_SPECIAUX.canon);
for (const id of S.CREATEURS) if (contributions[id]) fiche(`contrib:${id}`, S.cheminLivrable(S.AGENTS.find(x => x.id === id)));
for (const id of S.RELECTEURS_QA) if (qa[id]) fiche(`qa:${id}`, S.cheminLivrable(S.AGENTS.find(x => x.id === id)));
if (coordination) fiche("coord:a03", S.CHEMINS_SPECIAUX.coordination);
if (plan) fiche("plan:a02", S.CHEMINS_SPECIAUX.plan);
if (bible) fiche("bible:a01", S.CHEMINS_SPECIAUX.bible);
for (const cle of Array.isArray(infos.echecs) ? infos.echecs : []) {
  if (typeof cle === "string" && /^[a-z]+:a\d\d$/.test(cle)) manque(cle, "échec de l'agent pendant le workflow");
}

// sans les infos du workflow, ses échecs sont inconnus : on ne peut pas conclure « terminée »
if (!origineInfos) manque("infos:echecs", "liste des échecs du workflow introuvable : relancez avec la commande d'assemblage renvoyée par le workflow");

/* ---------- assemblage ---------- */
const production = {
  id: "cc-" + path.basename(racine),
  source: "claude-code",
  nom: vision.titre || path.basename(racine),
  brief: typeof infos.brief === "string" && infos.brief ? infos.brief : (lireTexte("brief.md") || ficheCanon.brief || ""),
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

if (!production.brief) { manque("infos:brief", "brief introuvable (entrée standard, infos.json, brief.md)"); production.statut = "incomplet"; }
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
