#!/usr/bin/env node
/* Fabrique « Apercu-Interface.html » : l'interface du jeu telle que les scripts l'ont
   réellement construite dans le banc d'essai (HUD, panneaux, alertes), redessinée en HTML
   à 1280 x 720 d'après les ScreenGui exportés (outils/banc/sortie/ui-*.json).
   Usage : node outils/apercu-interface.js                                              */
"use strict";
const fs = require("fs");
const path = require("path");
const PROJET = path.resolve(__dirname, "..");
const SORTIE_BANC = path.resolve(process.argv[2] || path.join(__dirname, "banc", "sortie"));
const SORTIE = path.resolve(process.argv[3] || path.join(PROJET, "Apercu-Interface.html"));
const ETATS = [
  ["hud", "🏠 Dans sa base"], ["alerte-vol", "🚨 On me vole !"], ["boutique", "🛒 Boutique"],
  ["dinodex", "📖 Dinodex"], ["renaissance", "♻️ Renaissance"], ["reglages", "⚙️ Réglages"],
].filter(([n]) => fs.existsSync(path.join(SORTIE_BANC, `ui-${n}.json`)));
const donnees = {};
for (const [n] of ETATS) donnees[n] = JSON.parse(fs.readFileSync(path.join(SORTIE_BANC, `ui-${n}.json`), "utf8"));

const html = `<!doctype html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dino Chapardeurs — interface</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@600;700&family=Luckiest+Guy&family=Montserrat:wght@700;800&display=swap" rel="stylesheet">
<style>
:root { --fond: #12131f; --texte: #f4f1ff; --doux: #a9a6c4; --accent: #5cff5c; }
* { box-sizing: border-box; }
body { margin: 0; background: var(--fond); color: var(--texte); font: 14px/1.4 system-ui, sans-serif; }
header { padding: 14px 16px 6px; }
h1 { margin: 0; font: 26px 'Luckiest Guy', 'Fredoka', sans-serif; letter-spacing: 1px; color: #fff; text-shadow: 0 3px 0 #000, 2px 0 0 #000, -2px 0 0 #000, 0 -2px 0 #000; }
p { margin: 4px 0 0; color: var(--doux); max-width: 900px; }
nav { display: flex; flex-wrap: wrap; gap: 8px; padding: 10px 16px; }
nav button { font: 600 15px 'Fredoka', sans-serif; border: 3px solid #000; border-radius: 12px; padding: 6px 14px; cursor: pointer; color: #fff; background: linear-gradient(#62d0ff, #1f6fe0); text-shadow: 0 2px 0 #000; }
nav button.actif { background: linear-gradient(#7cff6b, #1faf3a); }
#cadre { padding: 0 16px 24px; }
#vue { width: 1280px; height: 720px; position: relative; overflow: hidden; border-radius: 14px; border: 3px solid #000; transform-origin: top left;
  background: radial-gradient(ellipse at 50% 120%, #3e9f3a 0 35%, transparent 36%), linear-gradient(#8fd3ff 0 55%, #6bd64a 55% 100%); }
#vue::after { content: ""; position: absolute; inset: 0; background: rgba(0,0,0,.08); pointer-events: none; }
.n { position: absolute; }
.t { position: absolute; inset: 0; display: flex; padding: 0 2px; white-space: pre-wrap; line-height: 1.05; overflow: visible; }
</style></head><body>
<header><h1>DINO CHAPARDEURS · l'interface en jeu</h1>
<p>Redessinée à partir de ce que les scripts Luau ont réellement créé dans le banc d'essai (ScreenGui exportés, mise en page recalculée à 1280 × 720). Le décor derrière est un simple fond : le jeu en 3D est dans Apercu-3D.html.</p></header>
<nav id="onglets"></nav>
<div id="cadre"><div id="vue"></div></div>
<script>
const D = ${JSON.stringify(donnees)};
const ETATS = ${JSON.stringify(ETATS)};
const POLICES = { FredokaOne: "'Fredoka', sans-serif", LuckiestGuy: "'Luckiest Guy', 'Fredoka', sans-serif", GothamBold: "'Montserrat', sans-serif", GothamBlack: "'Montserrat', sans-serif", Gotham: "'Montserrat', sans-serif", GothamMedium: "'Montserrat', sans-serif", GothamSemibold: "'Montserrat', sans-serif" };
const alphaA = (g, t) => { const tr = g.transp || []; if (!tr.length) return 1; if (t <= tr[0][0]) return 1 - tr[0][1]; for (let i = 1; i < tr.length; i++) if (t <= tr[i][0]) { const [t0, v0] = tr[i-1], [t1, v1] = tr[i]; return 1 - (v0 + (v1 - v0) * (t - t0) / Math.max(t1 - t0, 1e-6)); } return 1 - tr[tr.length-1][1]; };
const rgba = (c, a) => "rgba(" + parseInt(c.slice(1,3),16) + "," + parseInt(c.slice(3,5),16) + "," + parseInt(c.slice(5,7),16) + "," + a.toFixed(2) + ")";
const couleurA = (g, t) => { const p = g.points; if (t <= p[0][0]) return p[0][1]; for (let i = 1; i < p.length; i++) if (t <= p[i][0]) return p[i][1]; return p[p.length-1][1]; };
const deg = (g, base) => { const ts = new Set([0, 1]); g.points.forEach(p => ts.add(p[0])); (g.transp || []).forEach(p => ts.add(p[0])); const stops = [...ts].sort((a, b) => a - b).map(t => { let c = couleurA(g, t); if (base) { const m = (x, y) => Math.round(parseInt(x, 16) * parseInt(y, 16) / 255).toString(16).padStart(2, "0"); c = "#" + m(c.slice(1,3), base.slice(1,3)) + m(c.slice(3,5), base.slice(3,5)) + m(c.slice(5,7), base.slice(5,7)); } return rgba(c, alphaA(g, t) * (base && base.a !== undefined ? base.a : 1)) + " " + (t * 100).toFixed(1) + "%"; }); return "linear-gradient(" + (g.rotation + 90) + "deg, " + stops.join(", ") + ")"; };
const ombreTexte = (c, e) => { e = Math.max(1, Math.round(e)); const l = []; for (let a = 0; a < 16; a++) { const r = a * Math.PI / 8; l.push((Math.cos(r) * e).toFixed(1) + "px " + (Math.sin(r) * e).toFixed(1) + "px 0 " + c); } return l.join(","); };
function dessiner(d, parent, ox, oy) {
  const el = document.createElement("div");
  el.className = "n";
  el.style.left = (d.x - ox) + "px"; el.style.top = (d.y - oy) + "px";
  el.style.width = Math.max(0, d.w) + "px"; el.style.height = Math.max(0, d.h) + "px";
  el.style.zIndex = d.z || 1;
  const texteSeul = d.texte !== undefined && (d.bgT === undefined || d.bgT >= 1);
  if (d.bg && d.bgT < 1 && d.grad && !texteSeul) {
    const base = d.bg; const b = Object.assign(new String(base), {}); 
    el.style.background = deg(d.grad, null).replace(/rgba\\((\\d+),(\\d+),(\\d+),([\\d.]+)\\)/g, (m, r, g2, bl, a) => "rgba(" + Math.round(r * parseInt(base.slice(1,3),16) / 255) + "," + Math.round(g2 * parseInt(base.slice(3,5),16) / 255) + "," + Math.round(bl * parseInt(base.slice(5,7),16) / 255) + "," + (a * (1 - d.bgT)).toFixed(2) + ")");
  } else if (d.bg && d.bgT < 1) {
    el.style.background = d.grad && !texteSeul ? deg(d.grad) : d.bg;
    if (d.grad && !texteSeul) el.style.backgroundColor = d.bg;
    el.style.opacity = "";
    if (d.bgT > 0) el.style.background = d.grad ? deg(d.grad) : d.bg, el.style.setProperty("--a", 1 - d.bgT), el.style.backgroundColor = d.bg, el.style.filter = "";
    if (d.bgT > 0) { const c = d.bg; el.style.background = d.grad ? deg(d.grad) : "rgba(" + parseInt(c.slice(1,3),16) + "," + parseInt(c.slice(3,5),16) + "," + parseInt(c.slice(5,7),16) + "," + (1 - d.bgT).toFixed(2) + ")"; }
  }
  if (d.image && d.image !== "" && (!d.bg || d.bgT >= 1)) { el.style.background = "rgba(255,255,255,.08)"; }
  if (d.rayon) el.style.borderRadius = d.rayon + "px";
  if (d.bordure && (d.bordure.transparence || 0) < 1) el.style.boxShadow = "0 0 0 " + d.bordure.epaisseur + "px " + d.bordure.couleur;
  if (d.clip) el.style.overflow = "hidden";
  if (d.texte !== undefined && d.texte !== "" && (d.tt === undefined || d.tt < 1)) {
    const t = document.createElement("div");
    t.className = "t";
    t.innerHTML = d.texte.replace(/&/g, "&amp;").replace(/<(?!\\/?(b|i|u|br|font)\\b)[^>]*>/g, "").replace(/<font color="([^"]+)">/g, '<span style="color:$1">').replace(/<\\/font>/g, "</span>");
    t.style.fontFamily = POLICES[d.police] || "'Fredoka', sans-serif";
    t.style.fontWeight = /Gotham|Bold|Fredoka/.test(d.police) ? "700" : "600";
    t.style.fontSize = d.taille.toFixed(1) + "px";
    t.style.color = d.couleurTexte;
    t.style.justifyContent = d.ax === "Left" ? "flex-start" : d.ax === "Right" ? "flex-end" : "center";
    t.style.alignItems = d.ay === "Top" ? "flex-start" : d.ay === "Bottom" ? "flex-end" : "center";
    t.style.textAlign = d.ax === "Left" ? "left" : d.ax === "Right" ? "right" : "center";
    if (d.contourTexte) t.style.textShadow = ombreTexte(d.contourTexte.couleur, d.contourTexte.epaisseur);
    if (d.grad && texteSeul) {
      const span = document.createElement("span");
      span.innerHTML = t.innerHTML; t.innerHTML = "";
      span.style.background = deg(d.grad); span.style.webkitBackgroundClip = "text"; span.style.backgroundClip = "text"; span.style.color = "transparent";
      if (d.contourTexte) { t.style.textShadow = "none"; span.style.webkitTextStroke = Math.max(1, d.contourTexte.epaisseur) + "px " + d.contourTexte.couleur; span.style.paintOrder = "stroke fill"; }
      t.appendChild(span);
    }
    el.appendChild(t);
  }
  parent.appendChild(el);
  for (const e of (d.e || []).slice().sort((a, b) => (a.z || 1) - (b.z || 1))) dessiner(e, el, d.x, d.y);
}
function montrer(nom) {
  const vue = document.getElementById("vue"); vue.innerHTML = "";
  for (const g of D[nom].e) dessiner(g, vue, 0, 0);
  document.querySelectorAll("nav button").forEach(b => b.classList.toggle("actif", b.dataset.n === nom));
}
const nav = document.getElementById("onglets");
for (const [n, l] of ETATS) { const b = document.createElement("button"); b.textContent = l; b.dataset.n = n; b.onclick = () => montrer(n); nav.appendChild(b); }
function ajuster() { const v = document.getElementById("vue"); const s = Math.min(1, (innerWidth - 32) / 1280); v.style.transform = "scale(" + s + ")"; document.getElementById("cadre").style.height = (720 * s + 24) + "px"; }
addEventListener("resize", ajuster); ajuster();
if (ETATS.length) montrer(ETATS[0][0]);
window.__pret = true;
</script></body></html>`;
fs.writeFileSync(SORTIE, html);
console.log(`✔ ${path.relative(process.cwd(), SORTIE)} (${ETATS.length} écrans)`);
