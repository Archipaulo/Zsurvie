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
// modules de post-traitement (halo) et leurs dépendances relatives, chargés à l'exécution
const JSM = path.dirname(trouver("three/examples/jsm/postprocessing/EffectComposer.js")).replace(/postprocessing$/, "");
const modules = {};
const collecter = rel => {
  if (modules[rel]) return;
  const src = fs.readFileSync(path.join(JSM, rel), "utf8");
  modules[rel] = src;
  for (const m of src.matchAll(/from\s*['"](\.[^'"]+)['"]/g)) collecter(path.posix.normalize(path.posix.join(path.posix.dirname(rel), m[1])));
};
for (const e of ["postprocessing/EffectComposer.js", "postprocessing/RenderPass.js", "postprocessing/UnrealBloomPass.js", "postprocessing/OutputPass.js"]) collecter(e);
const donnees = fs.readFileSync(ENTREE, "utf8");
const sur = s => s.replace(/<\/script/gi, "<\\/script");

const html = `<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dino Chapardeurs — aperçu 3D</title>
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
#zones { max-height: 22vh; overflow: auto; margin-top: 4px; }
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
  <h1><b>DINO CHAPARDEURS</b> · aperçu du jeu Roblox</h1>
  <p>Chaque bloc a été construit par les scripts Luau des 50 agents, exécutés dans le banc d'essai (Roblox simulé), pendant une partie à deux joueurs. Glisser pour tourner, molette ou pincement pour zoomer.</p>
  <div class="rangee">
    <button data-vue="tapis" class="actif">🦖 Tapis & bases</button>
    <button data-vue="place">⛲ La Place</button>
    <button data-vue="volcan">🌋 Le Volcan</button>
    <button data-vue="haut">🛰️ Vue d'ensemble</button>
  </div>
  <div id="stats"></div>
  <div id="zones" class="rangee"></div>
</div>
<script type="text/plain" id="src-three">${sur(three)}</script>
<script type="text/plain" id="src-orbit">${sur(orbit)}</script>
<script type="application/json" id="src-modules">${sur(JSON.stringify(modules))}</script>
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

// ===== chargement des modules three (postprocessing) intégrés au fichier =====
const MODULES = JSON.parse(document.getElementById("src-modules").textContent);
const urlsModules = {};
const resoudre = (base, rel) => {
  const parts = base.split("/"); parts.pop();
  for (const seg of rel.split("/")) { if (seg === "..") parts.pop(); else if (seg !== ".") parts.push(seg); }
  return parts.join("/");
};
function urlModule(chemin) {
  if (urlsModules[chemin]) return urlsModules[chemin];
  let s = MODULES[chemin];
  s = s.replace(/from\\s*(['"])([^'"]+)\\1/g, (m, q, spec) => {
    if (spec === "three") return "from '" + urlThree + "'";
    return "from '" + urlModule(resoudre(chemin, spec)) + "'";
  });
  return (urlsModules[chemin] = URL.createObjectURL(new Blob([s], { type: "text/javascript" })));
}
const { EffectComposer } = await import(urlModule("postprocessing/EffectComposer.js"));
const { RenderPass } = await import(urlModule("postprocessing/RenderPass.js"));
const { UnrealBloomPass } = await import(urlModule("postprocessing/UnrealBloomPass.js"));
const { OutputPass } = await import(urlModule("postprocessing/OutputPass.js"));

const rendu = new THREE.WebGLRenderer({ antialias: true });
rendu.setPixelRatio(Math.min(devicePixelRatio, 2));
rendu.setSize(innerWidth, innerHeight);
rendu.outputColorSpace = THREE.SRGBColorSpace;
rendu.toneMapping = THREE.ACESFilmicToneMapping;
rendu.toneMappingExposure = 1.0;
rendu.shadowMap.enabled = true;
rendu.shadowMap.type = THREE.PCFSoftShadowMap;
document.body.appendChild(rendu.domElement);
const scene = new THREE.Scene();
const HORIZON = new THREE.Color("#cfe9ff");
scene.fog = new THREE.Fog(HORIZON, 350, 1100);
// ciel en dégradé
{
  const geo = new THREE.SphereGeometry(2500, 32, 16);
  const mat = new THREE.ShaderMaterial({
    side: THREE.BackSide, depthWrite: false, fog: false,
    uniforms: { haut: { value: new THREE.Color("#3f8ff0") }, bas: { value: HORIZON } },
    vertexShader: "varying vec3 vP; void main(){ vP = position; gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); }",
    fragmentShader: "uniform vec3 haut; uniform vec3 bas; varying vec3 vP; void main(){ float h = clamp(normalize(vP).y * 1.6, 0.0, 1.0); gl_FragColor = vec4(mix(bas, haut, pow(h, 0.7)), 1.0); }",
  });
  const ciel = new THREE.Mesh(geo, mat); ciel.renderOrder = -10; scene.add(ciel);
}
const camera = new THREE.PerspectiveCamera(50, innerWidth / innerHeight, 0.5, 6000);
const orbite = new OrbitControls(camera, rendu.domElement);
orbite.enableDamping = true;
orbite.maxPolarAngle = Math.PI * 0.49;

scene.add(new THREE.HemisphereLight("#dff1ff", "#6b7a45", 1.25));
const soleil = new THREE.DirectionalLight("#fff0d2", 3.0);
soleil.position.set(160, 260, 120);
soleil.castShadow = true;
soleil.shadow.mapSize.set(4096, 4096);
Object.assign(soleil.shadow.camera, { left: -240, right: 240, top: 240, bottom: -240, near: 10, far: 900 });
soleil.shadow.bias = -0.0004; soleil.shadow.normalBias = 0.25;
soleil.shadow.camera.updateProjectionMatrix();
scene.add(soleil); scene.add(soleil.target);

// ===== matériaux procéduraux (motif calculé en coordonnées monde) =====
const FAMILLES = {
  Grass: 1, LeafyGrass: 1, Wood: 2, WoodPlanks: 3, Slate: 4, Rock: 4, Basalt: 4, Granite: 4, Limestone: 4, Marble: 4, Sandstone: 4,
  Cobblestone: 5, Brick: 6, Pavement: 5, CeramicTiles: 6, ClayRoofTiles: 6, RoofShingles: 6, Fabric: 7, Carpet: 7, Leather: 7,
  Metal: 8, DiamondPlate: 8, CorrodedMetal: 8, Foil: 8, Sand: 9, Concrete: 9, Ground: 9, Mud: 9, Salt: 9, Snow: 9, Plaster: 9,
  Cardboard: 9, Pebble: 5, CrackedLava: 10, Asphalt: 9, Ice: 0, Glacier: 0,
};
const RUGOSITE = { 0: 0.55, 1: 0.95, 2: 0.8, 3: 0.75, 4: 0.9, 5: 0.9, 6: 0.85, 7: 0.95, 8: 0.35, 9: 0.95, 10: 0.8 };
const GLSL_BRUIT = \`
float h31(vec3 p){ p = fract(p * 0.3183099 + 0.1); p *= 17.0; return fract(p.x * p.y * p.z * (p.x + p.y + p.z)); }
float bruit(vec3 x){ vec3 i = floor(x); vec3 f = fract(x); f = f*f*(3.0-2.0*f);
  return mix(mix(mix(h31(i), h31(i+vec3(1,0,0)), f.x), mix(h31(i+vec3(0,1,0)), h31(i+vec3(1,1,0)), f.x), f.y),
             mix(mix(h31(i+vec3(0,0,1)), h31(i+vec3(1,0,1)), f.x), mix(h31(i+vec3(0,1,1)), h31(i+vec3(1,1,1)), f.x), f.y), f.z); }
float fbm(vec3 p){ return 0.5*bruit(p) + 0.25*bruit(p*2.03) + 0.125*bruit(p*4.01); }
vec2 plan(vec3 p, vec3 n){ vec3 a = abs(n); return a.y > a.x && a.y > a.z ? p.xz : (a.x > a.z ? p.zy : p.xy); }
float cellules(vec2 u, float taille, out float id){ vec2 g = u / taille; vec2 c = floor(g); id = h31(vec3(c, 3.1)); vec2 f = fract(g) - 0.5; return max(abs(f.x), abs(f.y)); }
float motif(int fam, vec3 p, vec3 n, out float emis){
  emis = 0.0; vec2 u = plan(p, n); float id;
  if (fam == 1) return 0.82 + 0.22*bruit(p*2.7) + 0.12*fbm(p*0.18) + 0.08*step(0.8, bruit(p*9.0));
  if (fam == 2) { float s = sin((u.x + fbm(p*0.8)*3.0) * 5.0); return 0.86 + 0.1*s + 0.05*bruit(p*6.0); }
  if (fam == 3) { float s = sin((u.x + fbm(p*0.8)*2.0) * 6.0); float joint = step(0.94, fract(u.y / 1.2)); return (0.88 + 0.08*s + 0.05*bruit(p*5.0)) * (1.0 - 0.35*joint); }
  if (fam == 4) return 0.72 + 0.34*fbm(p*0.45) + 0.06*bruit(p*5.0) - 0.18*step(0.965, bruit(p*1.3));
  if (fam == 5) { float d = cellules(u + 0.35*vec2(bruit(p*0.9), bruit(p*0.9+7.0)), 1.8, id); return (0.8 + 0.25*id) * (1.0 - 0.45*smoothstep(0.38, 0.5, d)); }
  if (fam == 6) { vec2 v = u; v.x += step(0.5, fract(v.y / 1.2)) * 0.9; float d = cellules(v * vec2(0.55, 1.0), 0.66, id); return (0.85 + 0.18*id) * (1.0 - 0.4*smoothstep(0.42, 0.5, d)); }
  if (fam == 7) return 0.9 + 0.07*sin(u.x*22.0)*sin(u.y*22.0) + 0.05*bruit(p*3.0);
  if (fam == 8) return 0.9 + 0.1*bruit(vec3(p.x*18.0, p.y*0.6, p.z*0.6));
  if (fam == 9) return 0.88 + 0.14*bruit(p*5.0) + 0.06*fbm(p*0.3);
  if (fam == 10) { float r = abs(fbm(p*0.35) - 0.5); emis = smoothstep(0.05, 0.0, r); return 0.35 + 0.15*bruit(p*3.0); }
  return 0.97 + 0.03*bruit(p*4.0);
}\`;
function materiauProcedural(fam, opts) {
  const m = new THREE.MeshStandardMaterial(Object.assign({ color: "#ffffff", roughness: RUGOSITE[fam] ?? 0.6, metalness: fam === 8 ? 0.55 : 0.0 }, opts || {}));
  m.onBeforeCompile = sh => {
    sh.vertexShader = sh.vertexShader
      .replace("#include <common>", "#include <common>\\nvarying vec3 vPm; varying vec3 vNm;")
      .replace("#include <begin_vertex>", \`#include <begin_vertex>
        mat4 mm = modelMatrix;
        #ifdef USE_INSTANCING
          mm = modelMatrix * instanceMatrix;
        #endif
        vPm = (mm * vec4(position, 1.0)).xyz; vNm = normalize(mat3(mm) * normal);\`);
    sh.fragmentShader = sh.fragmentShader
      .replace("#include <common>", "#include <common>\\nvarying vec3 vPm; varying vec3 vNm;\\n" + GLSL_BRUIT)
      .replace("#include <color_fragment>", \`#include <color_fragment>
        float emisM; float fM = motif(\${fam}, vPm, vNm, emisM);
        diffuseColor.rgb *= fM;\`)
      .replace("#include <emissivemap_fragment>", \`#include <emissivemap_fragment>
        totalEmissiveRadiance += vec3(1.0, 0.35, 0.05) * emisM * 2.5;\`);
  };
  m.customProgramCacheKey = () => "fam" + fam + (opts && opts.transparent ? "t" : "");
  return m;
}

// géométries : dimensions unitaires, mises à l'échelle par la taille de la part
const geoBloc = new THREE.BoxGeometry(1, 1, 1);
const geoBoule = new THREE.SphereGeometry(0.5, 24, 16);
const geoCyl = new THREE.CylinderGeometry(0.5, 0.5, 1, 28); geoCyl.rotateZ(Math.PI / 2); // axe X comme Roblox
const geoCylY = new THREE.CylinderGeometry(0.5, 0.5, 1, 40);
const geoCoin = (() => { // WedgePart : face verticale à l'arrière (+Z), pente vers l'avant (-Z)
  const g = new THREE.BufferGeometry();
  const v = [[-.5,-.5,-.5],[.5,-.5,-.5],[.5,-.5,.5],[-.5,-.5,.5],[-.5,.5,.5],[.5,.5,.5]];
  const f = [[0,2,1],[0,3,2],[3,5,2],[3,4,5],[0,1,5],[0,5,4],[0,4,3],[1,2,5]];
  const pos = [];
  for (const t of f) for (const i of t) pos.push(...v[i]);
  g.setAttribute("position", new THREE.Float32BufferAttribute(pos, 3));
  return g.toNonIndexed ? (g.computeVertexNormals(), g) : g;
})();
const geoCoinAngle = (() => { // CornerWedgePart : sommet au coin (+X, +Y, -Z)
  const g = new THREE.BufferGeometry();
  const v = [[-.5,-.5,-.5],[.5,-.5,-.5],[.5,-.5,.5],[-.5,-.5,.5],[.5,.5,-.5]];
  const f = [[0,2,1],[0,3,2],[0,1,4],[1,2,4],[2,3,4],[3,0,4]];
  const pos = []; for (const t of f) for (const i of t) pos.push(...v[i]);
  g.setAttribute("position", new THREE.Float32BufferAttribute(pos, 3)); g.computeVertexNormals(); return g;
})();
const GEOS = { Block: geoBloc, Ball: geoBoule, Cylinder: geoCyl, Wedge: geoCoin, CornerWedge: geoCoinAngle };

const groupes = new Map(); // clé forme|famille|genre -> liste
const zones = new Map();
for (const p of D.parts) {
  const [x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, hex, tr, forme, mat, zone] = p;
  const neon = mat === "Neon", verre = tr > 0.02 || mat === "Glass" || mat === "ForceField";
  const fam = FAMILLES[mat] ?? 0;
  const cle = (GEOS[forme] ? forme : "Block") + "|" + (neon ? "n" : fam) + "|" + (neon ? "n" : verre ? "v" : "o");
  if (!groupes.has(cle)) groupes.set(cle, []);
  groupes.get(cle).push(p);
  const zz = zones.get(zone) || { n: 0, min: [1e9,1e9,1e9], max: [-1e9,-1e9,-1e9] };
  zz.n++; for (const [k, val] of [[0,x],[1,y],[2,z]]) { zz.min[k] = Math.min(zz.min[k], val); zz.max[k] = Math.max(zz.max[k], val); }
  zones.set(zone, zz);
}
const m4 = new THREE.Matrix4(), s4 = new THREE.Matrix4(), coul = new THREE.Color();
for (const [cle, liste] of groupes) {
  const [forme, fam, genre] = cle.split("|");
  let mat;
  if (genre === "n") mat = new THREE.MeshBasicMaterial({ color: "#ffffff", toneMapped: false });
  else if (genre === "v") mat = materiauProcedural(+fam, { transparent: true, opacity: 0.55, depthWrite: false, roughness: 0.1, metalness: 0.1 });
  else mat = materiauProcedural(+fam);
  const inst = new THREE.InstancedMesh(GEOS[forme], mat, liste.length);
  liste.forEach((p, k) => {
    const [x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, hex, tr] = p;
    m4.set(a,b,c,x, d,e,f,y, g,h,i,z, 0,0,0,1);
    s4.makeScale(Math.max(sx, .05), Math.max(sy, .05), Math.max(sz, .05));
    m4.multiply(s4);
    inst.setMatrixAt(k, m4);
    coul.set("#" + hex);
    if (genre === "n") coul.multiplyScalar(3.2); // le Neon dépasse le seuil du halo
    inst.setColorAt(k, coul);
  });
  if (genre === "v") inst.renderOrder = 2;
  inst.castShadow = genre === "o"; inst.receiveShadow = genre !== "n";
  scene.add(inst);
}
// remplissages de Terrain (couleurs réglées par Terrain:SetMaterialColor si disponibles)
const MAT_TERRAIN = { Grass: "#6cc24a", LeafyGrass: "#5aa83e", Rock: "#77727f", Sand: "#e8d19a", Ground: "#8a6a45", Mud: "#6b4f35", Slate: "#5d5a6b",
  Basalt: "#3e3a44", CrackedLava: "#3a2a26", Snow: "#f2f6fa", Sandstone: "#d8a878", Limestone: "#d9d2c0", Pavement: "#9b9aa3", Cobblestone: "#8c8a90", Salt: "#eeeeea", Asphalt: "#444448", Glacier: "#bfe6ff", Ice: "#cfefff" };
const couleursTerrain = D.couleursTerrain || {};
const eau = [];
// Comme dans Roblox, un remplissage remplace ce qui était là avant lui : les remplissages Air (creuser)
// et Water (l'eau remplace l'herbe) « découpent » les remplissages plus anciens. Le fragment d'un
// remplissage est jeté s'il tombe dans une découpe plus récente (grille XZ pour ne tester que les voisines).
const TERRAIN = D.terrain || [];
const GENRES_DEC = { bloc: 0, boule: 1, cylindre: 2, coin: 3 };
const decoupes = [];
TERRAIN.forEach((t, ordre) => {
  const [genre, x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, mat] = t;
  if (mat !== "Air" && mat !== "Water") return;
  const mm = new THREE.Matrix4().set(a,b,c,x, d,e,f,y, g,h,i,z, 0,0,0,1).multiply(new THREE.Matrix4().makeScale(Math.max(sx, .01), Math.max(sy, .01), Math.max(sz, .01)));
  const boite = new THREE.Box3(new THREE.Vector3(-.5, -.5, -.5), new THREE.Vector3(.5, .5, .5)).applyMatrix4(mm);
  decoupes.push({ ordre, genre: GENRES_DEC[genre] ?? 0, inv: mm.clone().invert(), boite, eau: mat === "Water" });
});
let decoupe = null;
if (decoupes.length) {
  const CEL = 16, TW = 1024;
  const min = new THREE.Vector2(Infinity, Infinity), max = new THREE.Vector2(-Infinity, -Infinity);
  for (const q of decoupes) { min.x = Math.min(min.x, q.boite.min.x); min.y = Math.min(min.y, q.boite.min.z); max.x = Math.max(max.x, q.boite.max.x); max.y = Math.max(max.y, q.boite.max.z); }
  const GX = Math.max(1, Math.ceil((max.x - min.x) / CEL)), GZ = Math.max(1, Math.ceil((max.y - min.y) / CEL));
  const cellules = Array.from({ length: GX * GZ }, () => []);
  decoupes.forEach((q, k) => {
    const i0 = Math.max(0, Math.floor((q.boite.min.x - min.x) / CEL)), i1 = Math.min(GX - 1, Math.floor((q.boite.max.x - min.x) / CEL));
    const j0 = Math.max(0, Math.floor((q.boite.min.z - min.y) / CEL)), j1 = Math.min(GZ - 1, Math.floor((q.boite.max.z - min.y) / CEL));
    for (let j = j0; j <= j1; j++) for (let i = i0; i <= i1; i++) cellules[j * GX + i].push(k);
  });
  const HB = decoupes.length * 4, LB = HB + GX * GZ;
  const total = LB + cellules.reduce((s, l) => s + l.length, 0);
  const TH = Math.max(1, Math.ceil(total / TW));
  const px = new Float32Array(TW * TH * 4);
  const ecrire = (n, v0, v1 = 0, v2 = 0, v3 = 0) => { px.set([v0, v1, v2, v3], n * 4); };
  decoupes.forEach((q, k) => {
    const el = q.inv.elements; // colonnes
    ecrire(4 * k, q.genre, q.ordre, q.eau ? 1 : 0);
    for (let r = 0; r < 3; r++) ecrire(4 * k + 1 + r, el[r], el[4 + r], el[8 + r], el[12 + r]);
  });
  let pos = 0;
  cellules.forEach((l, c) => { ecrire(HB + c, pos, l.length); for (const k of l) ecrire(LB + pos++, k); });
  const tex = new THREE.DataTexture(px, TW, TH, THREE.RGBAFormat, THREE.FloatType);
  tex.needsUpdate = true;
  decoupe = { tex, grille: new THREE.Vector4(min.x, min.y, CEL, GX), bases: new THREE.Vector4(HB, LB, TW, GZ) };
}
const GLSL_DECOUPE = \`
uniform highp sampler2D decTex; uniform float decOrdre; uniform float decEau; uniform vec4 decGrille; uniform vec4 decBases;
varying vec3 vPd;
vec4 decLire(int k){ int tw = int(decBases.z); return texelFetch(decTex, ivec2(k - (k / tw) * tw, k / tw), 0); }
bool decDedans(vec3 p){
  vec2 g = floor((p.xz - decGrille.xy) / decGrille.z);
  if (g.x < 0.0 || g.y < 0.0 || g.x >= decGrille.w || g.y >= decBases.w) return false;
  vec4 cel = decLire(int(decBases.x) + int(g.y * decGrille.w + g.x));
  int debut = int(cel.x); int n = int(cel.y);
  for (int k = 0; k < 1024; k++) {
    if (k >= n) break;
    int c = int(decLire(int(decBases.y) + debut + k).x + 0.5);
    vec4 t0 = decLire(4 * c);
    // un remplissage plus récent découpe ; entre deux eaux, les parois intérieures disparaissent aussi
    // et la surface commune (même hauteur) n'est gardée qu'une fois
    bool recent = t0.y > decOrdre + 0.5;
    bool eaux = decEau > 0.5 && t0.z > 0.5;
    if (!recent && !(eaux && t0.y < decOrdre - 0.5)) continue;
    float E = (eaux && recent) ? 0.5005 : 0.4995;
    vec4 q = vec4(p, 1.0);
    vec3 l = vec3(dot(decLire(4 * c + 1), q), dot(decLire(4 * c + 2), q), dot(decLire(4 * c + 3), q));
    int genre = int(t0.x + 0.5);
    bool dans;
    if (genre == 1) dans = length(l) < E;
    else if (genre == 2) dans = length(l.xz) < E && abs(l.y) < E;
    else dans = all(lessThan(abs(l), vec3(E))) && (genre != 3 || l.y < l.z);
    if (dans) return true;
  }
  return false;
}\`;
// ajoute la découpe à un matériau (couleur ou ombre) du remplissage numéro « ordre »
function avecDecoupe(materiau, ordre, cle, estEau) {
  if (!decoupe) return materiau;
  const avant = materiau.onBeforeCompile;
  materiau.onBeforeCompile = (sh, r) => {
    if (avant) avant.call(materiau, sh, r);
    Object.assign(sh.uniforms, { decTex: { value: decoupe.tex }, decOrdre: { value: ordre }, decEau: { value: estEau ? 1 : 0 }, decGrille: { value: decoupe.grille }, decBases: { value: decoupe.bases } });
    sh.vertexShader = sh.vertexShader
      .replace("#include <common>", "#include <common>\\nvarying vec3 vPd;")
      .replace("#include <project_vertex>", "#include <project_vertex>\\nvPd = (modelMatrix * vec4(transformed, 1.0)).xyz;");
    sh.fragmentShader = sh.fragmentShader
      .replace("#include <common>", "#include <common>\\n" + GLSL_DECOUPE)
      .replace("#include <clipping_planes_fragment>", "#include <clipping_planes_fragment>\\nif (decDedans(vPd)) discard;");
  };
  materiau.customProgramCacheKey = () => "dec|" + cle;
  return materiau;
}
TERRAIN.forEach((t, ordre) => {
  const [genre, x,y,z, a,b,c, d,e,f, g,h,i, sx,sy,sz, mat] = t;
  if (mat === "Air") return; // l'air ne se dessine pas : il découpe
  const geo = genre === "boule" ? geoBoule : genre === "cylindre" ? geoCylY : genre === "coin" ? geoCoin : geoBloc;
  m4.set(a,b,c,x, d,e,f,y, g,h,i,z, 0,0,0,1); s4.makeScale(sx, sy, sz); m4.multiply(s4);
  // découpe seulement si une découpe plus récente touche ce remplissage (les autres gardent le shader simple)
  const boite = new THREE.Box3(new THREE.Vector3(-.5, -.5, -.5), new THREE.Vector3(.5, .5, .5)).applyMatrix4(m4);
  const decoupe_ = decoupes.some(q => (q.ordre > ordre || (mat === "Water" && q.eau && q.ordre !== ordre)) && q.boite.intersectsBox(boite));
  const decouper = (materiau, cle) => decoupe_ ? avecDecoupe(materiau, ordre, cle, mat === "Water") : materiau;
  let materiau;
  if (mat === "Water") {
    materiau = decouper(new THREE.MeshStandardMaterial({ color: D.eclairage && D.eclairage.Eau ? "#" + D.eclairage.Eau : "#2bb3c8", transparent: true, opacity: 0.72, roughness: 0.08, metalness: 0.1, depthWrite: false }), "eau");
  } else {
    const fam = FAMILLES[mat] ?? 9;
    materiau = decouper(materiauProcedural(fam, { color: couleursTerrain[mat] ? "#" + couleursTerrain[mat] : (MAT_TERRAIN[mat] || "#888") }), "fam" + fam);
  }
  const m = new THREE.Mesh(geo, materiau);
  m.applyMatrix4(m4);
  m.receiveShadow = true; m.castShadow = mat !== "Water"; // (ombres sans découpe : plus rapide, même rendu)
  if (mat === "Water") { m.renderOrder = 3; eau.push(m); }
  scene.add(m);
});

// post-traitement : halo lumineux sur le Neon
const composeur = new EffectComposer(rendu);
composeur.addPass(new RenderPass(scene, camera));
const halo = new UnrealBloomPass(new THREE.Vector2(innerWidth, innerHeight), 0.7, 0.45, 1.9);
composeur.addPass(halo);
composeur.addPass(new OutputPass());


// étiquettes flottantes (BillboardGui) : texte cerné dessiné sur un canvas, affiché en sprite
const etiquettes = D.etiquettes || [];
for (const [x, y, z, w, h, lignes] of etiquettes) {
  if (!(w > 0 && h > 0)) continue;
  const W = 512, H = Math.max(32, Math.min(1024, Math.round(W * h / w)));
  const cv = document.createElement("canvas"); cv.width = W; cv.height = H;
  const g = cv.getContext("2d");
  const total = lignes.reduce((a, l) => a + (l[2] || 1 / lignes.length), 0) || 1;
  let yCur = H;
  for (let k = lignes.length - 1; k >= 0; k--) {
    const [texte, couleur, frac, degrade, contour, police] = lignes[k];
    const hl = H * ((frac || 1 / lignes.length) / total);
    const titre = /Luckiest/.test(police || "");
    let fs = hl * 0.82;
    g.font = (titre ? "900 " : "800 ") + fs + "px 'Arial Black', system-ui, sans-serif";
    const larg = g.measureText(texte).width;
    if (larg > W * 0.96) { fs = fs * W * 0.96 / larg; g.font = (titre ? "900 " : "800 ") + fs + "px 'Arial Black', system-ui, sans-serif"; }
    g.textAlign = "center"; g.textBaseline = "middle";
    const ty = yCur - hl / 2;
    g.lineJoin = "round"; g.lineWidth = Math.max(3, fs * 0.2); g.strokeStyle = contour ? "#" + contour.replace("#", "") : "#000";
    g.strokeText(texte, W / 2, ty);
    if (degrade && degrade.length) {
      const lg = g.createLinearGradient(W * 0.2, 0, W * 0.8, 0);
      degrade.forEach((c, i) => lg.addColorStop(degrade.length === 1 ? 0 : i / (degrade.length - 1), "#" + String(c).replace("#", "")));
      g.fillStyle = lg;
    } else g.fillStyle = couleur ? "#" + String(couleur).replace("#", "") : "#fff";
    g.fillText(texte, W / 2, ty);
    yCur -= hl;
  }
  const tex = new THREE.CanvasTexture(cv); tex.colorSpace = THREE.SRGBColorSpace;
  const sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: tex, depthWrite: false, transparent: true }));
  sp.scale.set(w, h, 1); sp.position.set(x, y, z); sp.renderOrder = 5;
  scene.add(sp);
}

const NOMS = { Dinos: "🦖 Dinos en jeu", Bases: "🏠 Bases", Tapis: "🟥 Tapis roulant", Sol: "🌱 Sol", Falaises: "⛰️ Falaises", Jungle: "🌴 Jungle", Riviere: "💧 Rivière", Volcan: "🌋 Volcan", Nurserie: "🥚 Nurserie", FinTapis: "🚪 Grande Porte", Place: "⛲ Place", Comptoir: "🛒 Boutique", Autel: "♻️ Autel", Cratere: "☄️ Cratère", Fossiles: "🦴 Fossiles", Lumieres: "🔥 Torches", Signaletique: "🪧 Panneaux", Classement: "🏆 Classement", Coffre: "💰 Coffre caché" };
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
const VUES = { tapis: () => viser(0, 2, 10, 150, 0.75), place: () => viser(0, 2, 100, 70, 0.6), volcan: () => viser(0, 20, -135, 120, 0.45), haut: () => viser(0, 0, -10, 330, 1.1) };
document.querySelectorAll("[data-vue]").forEach(b => b.onclick = () => {
  document.querySelectorAll("[data-vue]").forEach(x => x.classList.toggle("actif", x === b));
  VUES[b.dataset.vue]();
});
document.getElementById("replier").onclick = e => {
  const ui = document.getElementById("ui");
  ui.classList.toggle("replie");
  e.target.textContent = ui.classList.contains("replie") ? "+" : "–";
};
// vue imposée par l'adresse : #cible=x,y,z&dist=80&haut=0.6 (utilisé par outils/photo.mjs)
const parametres = new URLSearchParams(location.hash.slice(1));
if (parametres.get("cible")) {
  const [cx, cy, cz] = parametres.get("cible").split(",").map(Number);
  viser(cx, cy, cz, Number(parametres.get("dist") || 80), Number(parametres.get("haut") || 0.6));
  document.getElementById("ui").style.display = "none";
} else VUES.tapis();
addEventListener("resize", () => { camera.aspect = innerWidth / innerHeight; camera.updateProjectionMatrix(); rendu.setSize(innerWidth, innerHeight); composeur.setSize(innerWidth, innerHeight); });
rendu.setAnimationLoop(() => {
  orbite.update();
  // le brouillard suit la distance de la caméra : lointain en vue d'ensemble, proche en vue de jeu
  const dist = camera.position.distanceTo(orbite.target);
  scene.fog.near = dist * 1.4 + 120; scene.fog.far = dist * 3.2 + 500;
  soleil.target.position.copy(orbite.target); soleil.position.copy(orbite.target).add(new THREE.Vector3(160, 260, 120));
  composeur.render();
});
window.__pret = true;
</script>
</body>
</html>
`;
fs.writeFileSync(SORTIE, html);
console.log(`✔ ${path.relative(process.cwd(), SORTIE)} (${(html.length / 1024).toFixed(0)} Ko)`);
