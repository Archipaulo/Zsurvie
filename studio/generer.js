#!/usr/bin/env node
/* Génère les 50 agents du studio au format « subagent » de Claude Code
   (un fichier .md par agent) à partir de agents.js, ainsi que la version
   « fichier unique » de l'application (Atelier-Roblox.html).
   Usage : node studio/generer.js                                          */
"use strict";
const fs = require("fs");
const path = require("path");

const DIR = __dirname;
const src = fs.readFileSync(path.join(DIR, "agents.js"), "utf8");
const { DEPTS, AGENTS } = new Function(src + "; return { DEPTS, AGENTS };")();

const slug = s => s.normalize("NFD").replace(/[̀-ͯ]/g, "")
  .toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

/* ---------- 1. agents Claude Code ---------- */
const outDir = path.join(DIR, "agents-claude-code");
fs.rmSync(outDir, { recursive: true, force: true });
fs.mkdirSync(outDir);

for (const a of AGENTS) {
  const d = DEPTS.find(x => x.id === a.dept);
  const name = "roblox-" + slug(a.role);
  const colleagues = AGENTS.filter(x => x.dept === a.dept && x.id !== a.id)
    .map(x => `roblox-${slug(x.role)} (${x.role})`).join(", ");
  const md = `---
name: ${name}
description: ${a.role} du studio Atelier Roblox (${d.nom}). À utiliser pour : ${a.skills.join(", ")} sur une map ou une expérience Roblox. ${a.focus}
---

Tu es ${a.nom}, ${a.role} au sein du département « ${d.nom} » d'Atelier Roblox, un studio de 50 experts spécialisé dans la création de maps et d'expériences Roblox.

## Ton expertise
${a.skills.map(s => `- ${s}`).join("\n")}

${a.focus}

## Ta façon de travailler
- Tu réponds en français, de façon concrète et directement applicable dans Roblox Studio : noms d'instances, services, propriétés et valeurs précises quand c'est pertinent.
- Quand tu produis du code, c'est du Luau idiomatique et commenté avec parcimonie, en respectant la séparation serveur / client (Script, LocalScript, ModuleScript) et en ne faisant jamais confiance au client.
- Tu gardes en tête les contraintes de la plateforme : performances sur mobile, public jeune, règles communautaires de Roblox.
- Tu restes dans ton domaine. Si une demande relève d'un autre métier, tu le signales et tu recommandes le bon collègue.
- Tu termines par les prochaines étapes concrètes quand la demande s'y prête.

## Tes collègues directs (${d.nom})
${colleagues}
`;
  fs.writeFileSync(path.join(outDir, `${name}.md`), md);
}
console.log(`✔ ${AGENTS.length} agents Claude Code générés dans ${path.relative(process.cwd(), outDir)}/`);

/* ---------- 2. application en un seul fichier ---------- */
const SCRIPTS_APP = ["agents.js", "production.js", "app.js", "orchestrateur.js"];
const html = fs.readFileSync(path.join(DIR, "index.html"), "utf8");
const inline = f => fs.readFileSync(path.join(DIR, f), "utf8").replace(/<\/script/gi, "<\\/script");
let single = html.replace('<link rel="stylesheet" href="style.css">', () => `<style>\n${inline("style.css")}\n</style>`);
for (const f of SCRIPTS_APP) {
  single = single.replace(`<script src="${f}"></script>`, () => `<script>\n${inline(f)}\n</script>`);
}
if (/<script src=|href="style\.css"/.test(single)) throw new Error("inlining incomplet");
fs.writeFileSync(path.join(DIR, "Atelier-Roblox.html"), single);
console.log("✔ Application en un seul fichier : studio/Atelier-Roblox.html");

/* ---------- 3. workflow Claude Code « atelier-roblox » ---------- */
const META = `export const meta = {
  name: 'atelier-roblox',
  description: 'Les 50 agents du studio Atelier Roblox transforment un seul brief en bible de production complète pour une map Roblox',
  whenToUse: 'Quand on veut que tout le studio (vision, 40 spécialistes, QA, coordination, plan) travaille ensemble sur une idée de map. args : { nom, brief } ou simplement le brief en texte.',
  phases: [
    { title: 'Vision', detail: 'Analyse de marché et direction artistique, puis canon du directeur créatif' },
    { title: 'Contributions', detail: '40 spécialistes livrent leur partie en respectant le canon' },
    { title: 'Revue QA', detail: '5 experts QA relisent les livrables et signalent les problèmes' },
    { title: 'Coordination', detail: 'Le chef de projet arbitre les conflits entre départements' },
    { title: 'Révisions', detail: 'Les agents concernés corrigent leur livrable' },
    { title: 'Plan & Bible', detail: 'Plan de production et synthèse du directeur créatif' },
    { title: 'Archivage', detail: 'Assemblage de production.json et de la bible complète' },
  ],
}
`;
const workflow = [
  META,
  "/* ===== Fichier généré par studio/generer.js — modifiez studio/agents.js, studio/production.js ou studio/workflow-template.js puis relancez « node studio/generer.js » ===== */",
  fs.readFileSync(path.join(DIR, "agents.js"), "utf8").replace(/^"use strict";$/m, ""),
  fs.readFileSync(path.join(DIR, "production.js"), "utf8"),
  fs.readFileSync(path.join(DIR, "workflow-template.js"), "utf8"),
].join("\n\n");
const dossierWf = path.join(DIR, "..", ".claude", "workflows");
fs.mkdirSync(dossierWf, { recursive: true });
fs.writeFileSync(path.join(dossierWf, "atelier-roblox.js"), workflow);
console.log("✔ Workflow Claude Code : .claude/workflows/atelier-roblox.js");
