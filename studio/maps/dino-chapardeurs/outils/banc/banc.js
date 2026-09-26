#!/usr/bin/env node
/* Banc d'essai du jeu Dino Chapardeurs : vérifie la syntaxe de tous les scripts Luau,
   puis exécute réellement le jeu dans un Roblox simulé (fengari, Lua 5.3) :
   construction de la map, arrivée d'un joueur, départ en capsule, combat,
   achats, défaite, recherche, deuxième run.
   Usage : node banc.js [--sortie dossier] [--json]                           */
"use strict";
const fs = require("fs");
const path = require("path");
const luaparse = require("luaparse");
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require("fengari");

const ICI = __dirname;
const PROJET = path.resolve(ICI, "..", "..");
const args = process.argv.slice(2);
const SORTIE = args.includes("--sortie") ? path.resolve(args[args.indexOf("--sortie") + 1]) : path.join(ICI, "sortie");
fs.mkdirSync(SORTIE, { recursive: true });

/* ---------- 1. fichiers du projet (format Rojo) ---------- */
function fichiersDuProjet() {
  const projet = JSON.parse(fs.readFileSync(path.join(PROJET, "default.project.json"), "utf8"));
  const liste = [];
  const parcourir = (noeud, chemin) => {
    for (const [cle, val] of Object.entries(noeud)) {
      if (cle.startsWith("$")) continue;
      if (val && val.$path) {
        const racine = path.join(PROJET, val.$path);
        const service = chemin[0];
        const lire = (dossier, noms) => {
          for (const e of fs.readdirSync(dossier, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
            const complet = path.join(dossier, e.name);
            if (e.isDirectory()) lire(complet, [...noms, e.name]);
            else if (e.name.endsWith(".lua") || e.name.endsWith(".luau")) {
              const base = e.name.replace(/\.luau?$/, "");
              let classe = "ModuleScript", nom = base;
              if (base.endsWith(".server")) { classe = "Script"; nom = base.slice(0, -7); }
              else if (base.endsWith(".client")) { classe = "LocalScript"; nom = base.slice(0, -7); }
              liste.push({
                chemin: path.relative(path.join(PROJET, "src"), complet).split(path.sep).join("/"),
                complet, classe, service, noms: [...chemin.slice(1), cle, ...noms, nom],
              });
            }
          }
        };
        lire(racine, []);
      } else if (val && typeof val === "object") {
        parcourir(val, [...chemin, cle]);
      }
    }
  };
  parcourir(projet.tree, []);
  // les chemins de service imbriqués (StarterPlayer.StarterPlayerScripts)
  for (const f of liste) {
    if (!f.service) { f.service = f.noms.shift(); }
  }
  return liste;
}

/* ---------- 2. vérification syntaxique (sous-ensemble Lua 5.1 du contrat) ---------- */
function verifierSyntaxe(f, source) {
  const problemes = [];
  try {
    luaparse.parse(source, { luaVersion: "5.1", comments: false });
  } catch (e) {
    problemes.push(`syntaxe : ${e.message}`);
  }
  const lignes = source.split("\n");
  lignes.forEach((l, i) => {
    const code = l.replace(/--.*$/, "").replace(/"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'/g, '""');
    if (/(^|[^.:\w])(wait|spawn|delay)\s*\(/.test(code)) problemes.push(`ligne ${i + 1} : ${RegExp.$2}() déprécié, utiliser task.${RegExp.$2}`);
    if (/\bgame\.Workspace\b/.test(code)) problemes.push(`ligne ${i + 1} : utiliser workspace plutôt que game.Workspace`);
    if (/\b(getfenv|setfenv|loadstring)\b/.test(code)) problemes.push(`ligne ${i + 1} : ${RegExp.$1} interdit`);
  });
  return problemes;
}

/* ---------- 3. exécution dans fengari ---------- */
function pousser(L, v) {
  if (v === null || v === undefined) lua.lua_pushnil(L);
  else if (typeof v === "boolean") lua.lua_pushboolean(L, v);
  else if (typeof v === "number") lua.lua_pushnumber(L, v);
  else if (typeof v === "string") lua.lua_pushstring(L, to_luastring(v));
  else if (Array.isArray(v)) {
    lua.lua_createtable(L, v.length, 0);
    v.forEach((x, i) => { pousser(L, x); lua.lua_rawseti(L, -2, i + 1); });
  } else {
    lua.lua_createtable(L, 0, 0);
    for (const [k, x] of Object.entries(v)) { pousser(L, x); lua.lua_setfield(L, -2, to_luastring(k)); }
  }
}

function executer(fichiers) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  lua.lua_newtable(L);
  lua.lua_setglobal(L, to_luastring("BANC"));
  pousser(L, fichiers.map(f => ({ chemin: f.chemin, classe: f.classe, service: f.service, noms: f.noms, source: f.source })));
  lua.lua_setglobal(L, to_luastring("FICHIERS"));
  lua.lua_pushjsfunction(L, L2 => {
    const nom = to_jsstring(lauxlib.luaL_checkstring(L2, 1));
    const texte = to_jsstring(lauxlib.luaL_checkstring(L2, 2));
    fs.writeFileSync(path.join(SORTIE, `parts-${nom}.json`), texte);
    return 0;
  });
  lua.lua_setglobal(L, to_luastring("__ecrire"));
  lua.lua_pushjsfunction(L, L2 => {
    if (process.env.BANC_DEBUG) process.stderr.write(`[banc] ${to_jsstring(lauxlib.luaL_checkstring(L2, 1))}\n`);
    return 0;
  });
  lua.lua_setglobal(L, to_luastring("__trace"));
  // gestionnaire d'erreur avec trace
  lua.lua_pushjsfunction(L, L2 => {
    const msg = lua.lua_tojsstring(L2, 1);
    lauxlib.luaL_traceback(L2, L2, to_luastring(msg), 1);
    return 1;
  });
  const gestionnaire = lua.lua_gettop(L);
  let resultat = null;
  for (const f of ["moteur.lua", "types.lua", "instances.lua", "services.lua", "export.lua", "scenario.lua"]) {
    if (process.env.BANC_DEBUG) process.stderr.write(`[banc] charge ${f}\n`);
    const code = fs.readFileSync(path.join(ICI, f), "utf8");
    if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring("@banc/" + f)) !== lua.LUA_OK) {
      throw new Error(lua.lua_tojsstring(L, -1));
    }
    if (lua.lua_pcall(L, 0, 1, gestionnaire) !== lua.LUA_OK) {
      throw new Error(`banc/${f} : ${lua.lua_tojsstring(L, -1)}`);
    }
    if (f === "scenario.lua") resultat = lua.lua_tojsstring(L, -1);
    lua.lua_pop(L, 1);
  }
  fs.writeFileSync(path.join(SORTIE, "brut.json"), resultat);
  return JSON.parse(resultat);
}

/* ---------- 4. rapport ---------- */
if (process.env.BANC_DEBUG) process.stderr.write("[banc] fichiers\n");
const fichiers = fichiersDuProjet();
const parFichier = {};
const noter = (chemin, genre, texte) => {
  const cle = chemin in parFichier ? chemin : (Object.keys(parFichier).find(c => chemin && c.endsWith(chemin)) || chemin || "?");
  (parFichier[cle] = parFichier[cle] || { syntaxe: [], erreurs: [], avertissements: [], attentes: [] })[genre].push(texte);
};
let syntaxeOk = true;
for (const f of fichiers) {
  f.source = fs.readFileSync(f.complet, "utf8");
  parFichier[f.chemin] = { syntaxe: [], erreurs: [], avertissements: [], attentes: [] };
  for (const p of verifierSyntaxe(f, f.source)) { noter(f.chemin, "syntaxe", p); if (p.startsWith("syntaxe")) syntaxeOk = false; }
}

let rapport = null, crash = null;
const debut = Date.now();
try {
  rapport = executer(fichiers.filter(f => !parFichier[f.chemin].syntaxe.some(p => p.startsWith("syntaxe"))));
} catch (e) {
  crash = String(e.message || e);
}
const duree = ((Date.now() - debut) / 1000).toFixed(1);

if (rapport) {
  for (const e of rapport.erreurs) noter(e.source, "erreurs", `${e.message}`.split("\n")[0]);
  for (const w of rapport.avertissements) if (/\[Dino\]|\.lua:\d+/.test(w.texte) && !/map construite|Autotest :/.test(w.texte)) noter(w.source, "avertissements", w.texte.split("\n")[0]);
  for (const a of rapport.attentes) noter(a.source, "attentes", `attente infinie possible : ${a.chemin}`);
}
const resume = {
  duree, crash,
  controles: rapport ? rapport.controles : [],
  fichiers: parFichier,
  parts: rapport && rapport.parts, dossiers: rapport && rapport.dossiers, gabarits: rapport && rapport.gabarits,
  inconnus: rapport && rapport.inconnus, etapes: rapport && rapport.etapes, compteurs: rapport && rapport.compteurs,
  sorties: rapport && rapport.sorties.slice(0, 200), sons: rapport && rapport.sons, particules: rapport && rapport.particules,
};
fs.writeFileSync(path.join(SORTIE, "rapport.json"), JSON.stringify(resume, null, 1));

if (args.includes("--json")) { console.log(JSON.stringify(resume)); process.exit(0); }
console.log(`Banc d'essai Dino Chapardeurs — ${fichiers.length} scripts, ${duree} s`);
if (crash) console.log(`\n💥 le banc a planté : ${crash}`);
if (rapport) {
  console.log(`\nMap : ${rapport.parts} parts, ${Object.keys(rapport.dossiers).length} zones, temps simulé ${Math.round(rapport.tempsSimule)} s`);
  console.log("\nContrôles :");
  for (const c of rapport.controles) console.log(`  ${c.ok ? "✅" : "❌"} ${c.nom}${c.detail ? ` (${c.detail})` : ""}`);
}
const fautifs = Object.entries(parFichier).filter(([, v]) => v.syntaxe.length + v.erreurs.length + v.avertissements.length + v.attentes.length);
console.log(`\nFichiers avec problèmes : ${fautifs.length}`);
for (const [c, v] of fautifs) {
  console.log(`  • ${c}`);
  const uniques = [...new Set([...v.syntaxe, ...v.erreurs, ...v.avertissements, ...v.attentes])];
  for (const p of uniques.slice(0, 6)) console.log(`      ${p.slice(0, 220)}`);
  if (uniques.length > 6) console.log(`      … ${uniques.length - 6} autres`);
}
if (rapport) {
  const inconnus = Object.entries(rapport.inconnus).sort((a, b) => b[1] - a[1]);
  if (inconnus.length) console.log(`\nMembres inconnus du simulateur (à vérifier) : ${inconnus.slice(0, 40).map(([k, n]) => `${k}×${n}`).join(", ")}`);
}
const echecs = (rapport ? rapport.controles.filter(c => !c.ok).length : 1) + fautifs.length + (crash ? 1 : 0);
process.exit(echecs ? 1 : 0);
