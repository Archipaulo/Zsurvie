#!/usr/bin/env node
/* Photographie une zone du jeu : exécute le banc d'essai, fabrique l'aperçu 3D et prend un cliché.
   Usage : node outils/photo.mjs --cible x,y,z [--dist 80] [--haut 0.6] --sortie /chemin/photo.png [--sans-banc] [--vitrine]
   --vitrine : tous les gabarits de dinos alignés en l'air (y = 60, z = 100), de x = -95 vers l'est, par rareté ; ex. --cible -40,66,100 --dist 70 --haut 0.15
   (chaque appel utilise son propre dossier temporaire : plusieurs agents peuvent l'utiliser en même temps) */
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
const ICI = path.dirname(fileURLToPath(import.meta.url));
const arg = (n, d) => { const i = process.argv.indexOf("--" + n); return i > 0 ? process.argv[i + 1] : d; };
const cible = arg("cible", "0,2,10"), dist = arg("dist", "80"), haut = arg("haut", "0.6");
const sortie = path.resolve(arg("sortie", "photo.png"));
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "photo-dino-"));
if (!process.argv.includes("--sans-banc")) {
  try { execFileSync("node", [path.join(ICI, "banc", "banc.js"), "--sortie", tmp], { stdio: "pipe", timeout: 400000 }); }
  catch (e) { console.log((e.stdout || "").toString().split("\n").filter(l => /❌|•|💥/.test(l)).slice(0, 12).join("\n")); }
}
if (process.argv.includes("--interface")) {
  // photos de l'interface : un PNG par écran (hud, alerte-vol, boutique, dinodex, renaissance)
  const dossierBanc = fs.existsSync(path.join(tmp, "ui-hud.json")) ? tmp : path.join(ICI, "banc", "sortie");
  const htmlUi = path.join(tmp, "interface.html");
  execFileSync("node", [path.join(ICI, "apercu-interface.js"), dossierBanc, htmlUi], { stdio: "pipe" });
  const { chromium } = await import("/opt/node22/lib/node_modules/playwright/index.mjs");
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1320, height: 900 } });
  await p.goto("file://" + htmlUi);
  await p.waitForFunction(() => window.__pret, null, { timeout: 60000 });
  await p.waitForTimeout(800);
  const ecrans = await p.$$eval("nav button", bs => bs.map(x => x.dataset.n));
  for (const e of ecrans) {
    await p.click('nav button[data-n="' + e + '"]');
    await p.waitForTimeout(250);
    const f = sortie.replace(/\.png$/, "") + "-" + e + ".png";
    await (await p.$("#vue")).screenshot({ path: f });
    console.log("photo : " + f);
  }
  await b.close();
  fs.rmSync(tmp, { recursive: true, force: true });
  process.exit(0);
}
const fichierParts = process.argv.includes("--vitrine") ? "parts-vitrine.json" : "parts-pendant.json";
const parts = fs.existsSync(path.join(tmp, fichierParts)) ? path.join(tmp, fichierParts) : path.join(ICI, "banc", "sortie", fichierParts);
const html = path.join(tmp, "apercu.html");
execFileSync("node", [path.join(ICI, "apercu.js"), parts, html], { stdio: "pipe" });
const { chromium } = await import("/opt/node22/lib/node_modules/playwright/index.mjs");
const b = await chromium.launch({ args: ["--use-gl=swiftshader", "--enable-webgl", "--ignore-gpu-blocklist", "--enable-unsafe-swiftshader"] });
const p = await b.newPage({ viewport: { width: 1280, height: 800 } });
await p.goto("file://" + html + "#cible=" + cible + "&dist=" + dist + "&haut=" + haut);
await p.waitForFunction(() => window.__pret, null, { timeout: 120000 });
await p.waitForTimeout(2500);
await p.screenshot({ path: sortie });
await b.close();
fs.rmSync(tmp, { recursive: true, force: true });
console.log("photo : " + sortie);
