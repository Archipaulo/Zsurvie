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
const html = fs.readFileSync(path.join(DIR, "index.html"), "utf8");
const inline = f => fs.readFileSync(path.join(DIR, f), "utf8").replace(/<\/script/gi, "<\\/script");
const single = html
  .replace('<link rel="stylesheet" href="style.css">', () => `<style>\n${inline("style.css")}\n</style>`)
  .replace('<script src="agents.js"></script>', () => `<script>\n${inline("agents.js")}\n</script>`)
  .replace('<script src="app.js"></script>', () => `<script>\n${inline("app.js")}\n</script>`);
if (/src="(agents|app)\.js"|href="style\.css"/.test(single)) throw new Error("inlining incomplet");
fs.writeFileSync(path.join(DIR, "Atelier-Roblox.html"), single);
console.log("✔ Application en un seul fichier : studio/Atelier-Roblox.html");
