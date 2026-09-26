#!/usr/bin/env node
/* Fabrique « Apercu-3D.html » : la map telle que le banc d'essai l'a réellement
   construite (export des parts pendant une run), visible dans un navigateur.
   three.js est intégré au fichier : il s'ouvre hors ligne d'un double-clic.
   Usage : node outils/apercu.js [parts.json] [sortie.html]                     */
"use strict";
const fs = require("fs");
const path = require("path");

const PROJET = path.resolve(__dirname, "..");
const ENTREE = path.resolve(process.argv[2] || path.join(__dirname, "banc", "sortie", "parts-pendant.json"));
const SORTIE = path.resolve(process.argv[3] || path.join(PROJET, "Apercu-3D.html"));
const trouver = rel => {
  for (const base of [path.join(__dirname, "banc", "node_modules"), path.join(__dirname, "node_modules")]) {
    const p = path.join(base, rel);
    if (fs.existsSync(p)) return p;
  }
  throw new Error(`introuvable : ${rel} (lancez « npm install three » dans outils/banc)`);
};
const three = fs.readFileSync(trouver("three/build/three.module.min.js"), "utf8");
const orbit = fs.readFileSync(trouver("three/examples/jsm/controls/OrbitControls.js"), "utf8");
const donnees = fs.readFileSync(ENTREE, "utf8");
const sur = s => s.replace(/<\/script/gi, "<\\/script");

const html = `<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Zsurvie — aperçu 3D</title>
<style>
:root { --fond: #1e1b2e; --panneau: rgba(30,27,46,.86); --texte: #f6e7c1; --accent: #ef7a2f; --doux: #b9aede; --bord: rgba(246,231,193,.18); }
@media (prefers-color-scheme: light) { :root:not([data-theme="dark"]) { --panneau: rgba(246,231,193,.92); --texte: #1e1b2e; --doux: #4a4560; --bord: rgba(30,27,46,.18); } }
:root[data-theme="light"] { --panneau: rgba(246,231,193,.92); --texte: #1e1b2e; --doux: #4a4560; --bord: rgba(30,27,46,.18); }
* { box-sizing: border-box; }
html, body { margin: 0; height: 100%; background: var(--fond); color: var(--texte); font: 14px/1.4 system-ui, -apple-system, "Segoe UI", sans-serif; overflow: hidden; }
canvas { display: block; }
#ui { position: fixed; top: 12px; left: 12px; max-width: min(340px, calc(100vw - 24px)); background: var(--panneau); border: 1px solid var(--bord); border-radius: 14px; padding: 12px 14px; backdrop-filter: blur(6px); }
h1 { font-size: 17px; margin: 0 0 2px; letter-spacing: .5px; }
h1 b { color: var(--accent); }
p { margin: 0 0 8px; color: var(--doux); font-size: 12.5px; }
.rangee { display: flex; flex-wrap: wrap; gap: 6px; margin: 6px 0; }
button { font: inherit; font-size: 13px; cursor: pointer; border: 1px solid var(--bord); background: transparent; color: var(--texte); border-radius: 999px; padding: 5px 11px; }
button.actif, button:hover { background: var(--accent); border-color: var(--accent); color: #1e1b2e; }
#zones { max-height: 30vh; overflow: auto; margin-top: 4px; }
#zones button { font-size: 12px; padding: 3px 9px; }
#stats { font-size: 12px; color: var(--doux); }
#replier { position: absolute; top: 8px; right: 10px; border: 0; padding: 2px 6px; }
#ui.replie > :not(h1):not(#replier) { display: none; }
@media (max-width: 520px) { #ui { top: 8px; left: 8px; right: 8px; max-width: none; } #zones { max-height: 18vh; } }
</style>
</head>
<body>
<div id="ui">
  <button id="replier" title="Replier">–</button>
  <h1><b>ZSURVIE</b> · aperçu de la map Roblox</h1>
  <p>Chaque bloc a été construit par les scripts Luau des 50 agents, exécutés dans le banc d'essai (Roblox simulé), en pleine run. Glisser pour tourner, molette ou pincement pour zoomer.</p>
  <div class="rangee">
    <button data-vue="prairie" class="actif">🏠 La Prairie</button>
    <button data-vue="ile">🔬 L'île du Laboratoire</button>
    <button data-vue="haut">🛰️ Vue d'ensemble</button>
  </div>
  <div id="stats"></div>
  <div id="zones" class="rangee"></div>
</div>
<script type="text/plain" id="src-three">${sur(three)}</script>
<script type="text/plain" id="src-orbit">${sur(orbit)}</script>
<script type="application/json" id="donnees">${sur(donnees)}</script>
<script type="module">
const blob = (id, remplace) => {
  let s = document.getElementById(id).textContent;
  if (remplace) s = remplace(s);
  return URL.createObjectURL(new Blob([s], { type: "text/javascript" }));
};
const urlThree = blob("src-three");
const THREE = await import(urlThree);
const { OrbitControls } = await import(blob("src-orbit", s => s.replace(/from\\s*['"]three['"]/g, "from '" + urlThree + "'")));
const D = JSON.parse(document.getElementById("donnees").textContent);

const rendu = new THREE.WebGLRenderer({ antialias: true });
rendu.setPixelRatio(Math.min(devicePixelRatio, 2));
rendu.setSize(innerWidth, innerHeight);
rendu.outputColorSpace = THREE.SRGBColorSpace;
rendu.toneMapping = THREE.ACESFilmicToneMapping;
rendu.toneMappingExposure = 1.05;
document.body.appendChild(rendu.domElement);
const scene = new THREE.Scene();
scene.background = new THREE.Color("#9ed6ef");
scene.fog = new THREE.Fog("#9ed6ef", 350, 1100);
const camera = new THREE.PerspectiveCamera(50, innerWidth / innerHeight, 0.5, 4000);
const orbite = new OrbitControls(camera, rendu.domElement);
orbite.enableDamping = true;
orbite.maxPolarAngle = Math.PI * 0.49;

scene.add(new THREE.HemisphereLight("#fff6e0", "#5a6a3a", 1.4));
const soleil = new THREE.DirectionalLight("#fff1d6", 2.2);
soleil.position.set(120, 220, 90);
scene.add(soleil);

// géométries : dimensions unitaires, mises à l'échelle par la taille de la part
const geoBloc = new THREE.BoxGeometry(1, 1, 1);
const geoBoule = new THREE.SphereGeometry(0.5, 18, 12);
const geoCyl = new THREE.CylinderGeometry(0.5, 0.5, 1, 20); geoCyl.rotateZ(Math.PI / 2); // axe X comme Roblox
const geoCoin = (() => { // WedgePart : face verticale à l'arrière (+Z), pente vers l'avant (-Z)
  const g = new THREE.BufferGeometry();
  const v = [[-.5,-.5,-.5],[.5,-.5,-.5],[.5,-.5,.5],[-.5,-.5,.5],[-.5,.5,.5],[.5,.5,.5]];
  const f = [[0,2,1],[0,3,2],[3,5,2],[3,4,5],[0,1,5],[0,5,4],[0,4,3],[1,2,5]];
  const pos = [];
  for (const t of f) for (const i of t) pos.push(...v[i]);
  g.setAttribute("position", new THREE.Float32BufferAttribute(pos, 3));
  g.computeVertexNormals();
  return g;
})();
const GEOS = { Block: geoBloc, Ball: geoBoule, Cylinder: geoCyl, Wedge: geoCoin, CornerWedge: geoCoin };

const groupes = new Map(); // clé forme|matériau|transparence -> liste
const zones = new Map();
for (const p of D.parts) {
  const [x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, hex, tr, forme, mat, zone] = p;
  const neon = mat === "Neon", verre = tr > 0.02 || mat === "Glass";
  const cle = (GEOS[forme] ? forme : "Block") + "|" + (neon ? "n" : verre ? "v" : "o");
  if (!groupes.has(cle)) groupes.set(cle, []);
  groupes.get(cle).push(p);
  const zz = zones.get(zone) || { n: 0, min: [1e9,1e9,1e9], max: [-1e9,-1e9,-1e9] };
  zz.n++; for (const [k, val] of [[0,x],[1,y],[2,z]]) { zz.min[k] = Math.min(zz.min[k], val); zz.max[k] = Math.max(zz.max[k], val); }
  zones.set(zone, zz);
}
const m4 = new THREE.Matrix4(), s4 = new THREE.Matrix4(), coul = new THREE.Color();
for (const [cle, liste] of groupes) {
  const [forme, genre] = cle.split("|");
  const mat = genre === "n"
    ? new THREE.MeshBasicMaterial({ color: "#ffffff" })
    : new THREE.MeshStandardMaterial({ color: "#ffffff", roughness: 0.75, metalness: 0.02, transparent: genre === "v", opacity: genre === "v" ? 0.6 : 1, depthWrite: genre !== "v" });
  const inst = new THREE.InstancedMesh(GEOS[forme], mat, liste.length);
  liste.forEach((p, k) => {
    const [x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, hex] = p;
    m4.set(a,b,c,x, d,e,f,y, g,h,i,z, 0,0,0,1);
    s4.makeScale(Math.max(sx, .05), Math.max(sy, .05), Math.max(sz, .05));
    m4.multiply(s4);
    inst.setMatrixAt(k, m4);
    inst.setColorAt(k, coul.set("#" + hex));
  });
  if (genre === "v") inst.renderOrder = 2;
  scene.add(inst);
}
// remplissages de Terrain éventuels
const MAT_TERRAIN = { Grass: "#6cc24a", LeafyGrass: "#5aa83e", Water: "#3aa7c9", Rock: "#6d6878", Sand: "#e3c98f", Ground: "#8a6a45", Mud: "#6b4f35", Slate: "#55506a" };
for (const t of D.terrain || []) {
  const [genre, x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, mat] = t;
  const geo = genre === "boule" ? geoBoule : genre === "cylindre" ? new THREE.CylinderGeometry(.5,.5,1,24) : geoBloc;
  const m = new THREE.Mesh(geo, new THREE.MeshStandardMaterial({ color: MAT_TERRAIN[mat] || "#888", transparent: mat === "Water", opacity: mat === "Water" ? .7 : 1 }));
  m4.set(a,b,c,x, d,e,f,y, g,h,i,z, 0,0,0,1); s4.makeScale(sx, sy, sz); m4.multiply(s4);
  m.applyMatrix4(m4); scene.add(m);
}

const NOMS = { Horde: "👾 Horde (Zbires en jeu)", Maison: "🏠 Maison", Mine: "⛏️ Mine", Props: "🛠️ Établi & props", Prairie: "🌱 Prairie", Relief: "⛰️ Relief", Vegetation: "🌳 Végétation", Eau: "💧 Étang", PointsInteret: "📍 Points d'intérêt", Portails: "🌀 Portails", Lumieres: "💡 Lumières", Signaletique: "🪧 Signalétique", Fanions: "🎏 Fanions", IleLabo: "🏝️ Île", Laboratoire: "🔬 Laboratoire", QuaiCapsules: "🚀 Quai des capsules", Galerie: "🖼️ Galerie des Zbires", Parcours: "🏃 Parcours", Enigme: "🧩 Énigme", Records: "🏆 Records", Monument: "🗿 Monument", ScenePhoto: "📸 Scène photo", TourelleToit: "🗼 Tourelle", Pieces: "🪙 Pièces" };
const conteneur = document.getElementById("zones");
const viser = (cx, cy, cz, dist, haut = 0.55) => {
  orbite.target.set(cx, cy, cz);
  camera.position.set(cx + dist * 0.55, cy + dist * haut, cz + dist * 0.75);
  orbite.update();
};
[...zones.entries()].sort((a, b) => b[1].n - a[1].n).forEach(([nom, z]) => {
  const bt = document.createElement("button");
  bt.textContent = (NOMS[nom] || nom) + " · " + z.n;
  bt.onclick = () => {
    const c = z.min.map((v, k) => (v + z.max[k]) / 2);
    const taille = Math.max(z.max[0] - z.min[0], z.max[2] - z.min[2], 12);
    viser(c[0], c[1], c[2], taille * 1.3 + 14);
  };
  conteneur.appendChild(bt);
});
document.getElementById("stats").textContent = D.parts.length.toLocaleString("fr-FR") + " parts · " + zones.size + " zones construites";
const VUES = { prairie: () => viser(0, 4, 8, 120, 0.8), ile: () => viser(0, 0, 600, 130, 0.7), haut: () => viser(0, 0, 300, 620, 0.9) };
document.querySelectorAll("[data-vue]").forEach(b => b.onclick = () => {
  document.querySelectorAll("[data-vue]").forEach(x => x.classList.toggle("actif", x === b));
  VUES[b.dataset.vue]();
});
document.getElementById("replier").onclick = e => {
  const ui = document.getElementById("ui");
  ui.classList.toggle("replie");
  e.target.textContent = ui.classList.contains("replie") ? "+" : "–";
};
VUES.prairie();
addEventListener("resize", () => { camera.aspect = innerWidth / innerHeight; camera.updateProjectionMatrix(); rendu.setSize(innerWidth, innerHeight); });
rendu.setAnimationLoop(() => { orbite.update(); rendu.render(scene, camera); });
window.__pret = true;
</script>
</body>
</html>
`;
fs.writeFileSync(SORTIE, html);
console.log(`✔ ${path.relative(process.cwd(), SORTIE)} (${(html.length / 1024).toFixed(0)} Ko)`);
