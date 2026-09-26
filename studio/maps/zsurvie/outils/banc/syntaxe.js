#!/usr/bin/env node
/* Vérifie la syntaxe d'un ou plusieurs scripts Luau (sous-ensemble Lua 5.1 du CONTRAT).
   Usage : node syntaxe.js fichier.lua [...]                                         */
"use strict";
const fs = require("fs");
const luaparse = require("luaparse");
let ok = true;
for (const f of process.argv.slice(2)) {
  const src = fs.readFileSync(f, "utf8");
  try {
    luaparse.parse(src, { luaVersion: "5.1" });
    console.log(`OK  ${f}`);
  } catch (e) {
    ok = false;
    console.log(`ERR ${f} : ${e.message}`);
  }
}
process.exit(ok ? 0 : 1);
