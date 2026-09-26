#!/usr/bin/env node
/* Assemble tous les scripts du projet (format Rojo) en une place Roblox
   « DinoChapardeurs.rbxlx » à ouvrir directement dans Roblox Studio (Fichier > Ouvrir).
   Usage : node outils/rbxlx.js [sortie.rbxlx]                                 */
"use strict";
const fs = require("fs");
const path = require("path");

const PROJET = path.resolve(__dirname, "..");
const SORTIE = path.resolve(process.argv[2] || path.join(PROJET, "DinoChapardeurs.rbxlx"));
const projet = JSON.parse(fs.readFileSync(path.join(PROJET, "default.project.json"), "utf8"));

let ref = 0;
const nouvelleRef = () => `RBX${(++ref).toString(16).toUpperCase().padStart(8, "0")}`;
const echapper = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
const cdata = s => `<![CDATA[${s.replace(/]]>/g, "]]]]><![CDATA[>")}]]>`;

// arbre : { classe, nom, source?, enfants: [] }
function depuisDossier(dossier, nom) {
  const noeud = { classe: "Folder", nom, enfants: [] };
  const entrees = fs.readdirSync(dossier, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name));
  // un fichier init.lua transforme le dossier en script (convention Rojo)
  for (const e of entrees) {
    const complet = path.join(dossier, e.name);
    if (e.isDirectory()) { noeud.enfants.push(depuisDossier(complet, e.name)); continue; }
    if (!/\.luau?$/.test(e.name)) continue;
    const base = e.name.replace(/\.luau?$/, "");
    let classe = "ModuleScript", n = base;
    if (base.endsWith(".server")) { classe = "Script"; n = base.slice(0, -7); }
    else if (base.endsWith(".client")) { classe = "LocalScript"; n = base.slice(0, -7); }
    noeud.enfants.push({ classe, nom: n, source: fs.readFileSync(complet, "utf8"), enfants: [] });
  }
  return noeud;
}

function depuisProjet(nom, def) {
  if (def.$path) return depuisDossier(path.join(PROJET, def.$path), nom);
  const noeud = { classe: def.$className || nom, nom, enfants: [] };
  for (const [cle, val] of Object.entries(def)) {
    if (!cle.startsWith("$")) noeud.enfants.push(depuisProjet(cle, val));
  }
  return noeud;
}

function xml(noeud, indent) {
  const pad = "\t".repeat(indent);
  const props = [`${pad}\t\t<string name="Name">${echapper(noeud.nom)}</string>`];
  if (noeud.source !== undefined) {
    props.push(`${pad}\t\t<ProtectedString name="Source">${cdata(noeud.source)}</ProtectedString>`);
    if (noeud.classe !== "ModuleScript") props.push(`${pad}\t\t<bool name="Disabled">false</bool>`);
  }
  const enfants = noeud.enfants.map(e => xml(e, indent + 1)).join("\n");
  return `${pad}<Item class="${noeud.classe}" referent="${nouvelleRef()}">
${pad}\t<Properties>
${props.join("\n")}
${pad}\t</Properties>${enfants ? "\n" + enfants : ""}
${pad}</Item>`;
}

const services = Object.entries(projet.tree).filter(([k]) => !k.startsWith("$")).map(([k, v]) => depuisProjet(k, v));
// les services sont fusionnés par Studio avec les siens : on les déclare avec leur classe
for (const s of services) s.classe = s.nom;
const corps = services.map(s => xml(s, 1)).join("\n");
const doc = `<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
\t<Meta name="ExplicitAutoJoints">true</Meta>
${corps}
</roblox>
`;
fs.writeFileSync(SORTIE, doc);
let scripts = 0;
const compter = n => { if (n.source !== undefined) scripts++; n.enfants.forEach(compter); };
services.forEach(compter);
console.log(`✔ ${path.relative(process.cwd(), SORTIE)} : ${scripts} scripts, ${(doc.length / 1024).toFixed(0)} Ko`);
