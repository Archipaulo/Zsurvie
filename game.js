/* =========================================================================
   ZSURVIE — défense de base incrémentale en vue surélevée
   Les monstres arrivent de tous les côtés : protégez la petite maison !
   Améliorations temporaires en partie (🪙) + recherches permanentes au
   Laboratoire (💎), payées avec les gemmes produites par la mine et
   conservées entre les tentatives via localStorage.
   ========================================================================= */
"use strict";

const canvas = document.getElementById("game");
const mainCtx = canvas.getContext("2d");
const W = canvas.width, H = canvas.height;

// rendu pixel art : le monde est dessiné en basse résolution puis agrandi
// sans lissage (gros pixels), l'interface reste nette en pleine résolution
const PIX = 4;
const pixCanvas = document.createElement("canvas");
pixCanvas.width = W / PIX;
pixCanvas.height = H / PIX;
const pixCtx = pixCanvas.getContext("2d");
let ctx = mainCtx; // contexte courant utilisé par les fonctions de dessin

const HORIZON = 110;          // ligne d'horizon de la vue surélevée
const CX = 640, CY = 420;     // centre de la maison (sur le plan du sol)
const HOUSE_R = 86;           // rayon de collision de la maison
const MINE_X = CX + 215, MINE_Y = CY + 115;

// facteur de profondeur : plus c'est haut à l'écran, plus c'est loin (petit)
function depth(y) {
  return 0.62 + 0.55 * Math.min(1, Math.max(0, (y - HORIZON) / (H - HORIZON)));
}

/* ========================= SAUVEGARDE / MÉTA ========================= */

const SAVE_KEY = "zsurvie_save_v1";

const LAB_UPGRADES = [
  { id: "dmg",     icon: "🗡️", name: "Munitions renforcées",
    desc: "Augmente définitivement les dégâts de base de votre arme.",
    effect: l => `+${l * 4} dégâts de base`,
    max: 25, baseCost: 3,  costMult: 1.45 },
  { id: "rate",    icon: "⚡", name: "Mécanisme huilé",
    desc: "Votre arme tire plus vite, pour toujours.",
    effect: l => `+${l * 8}% cadence de tir`,
    max: 20, baseCost: 4,  costMult: 1.5 },
  { id: "wallhp",  icon: "🏠", name: "Maison fortifiée",
    desc: "Renforce les murs de la maison pour toutes les parties futures.",
    effect: l => `+${l * 20}% PV de la maison`,
    max: 25, baseCost: 3,  costMult: 1.45 },
  { id: "loot",    icon: "💰", name: "Fouille experte",
    desc: "Les monstres lâchent plus de pièces.",
    effect: l => `+${l * 10}% de pièces`,
    max: 20, baseCost: 4,  costMult: 1.5 },
  { id: "extract", icon: "⛏️", name: "Foreuse améliorée",
    desc: "La mine produit ses gemmes plus vite et les monstres rares en lâchent plus.",
    effect: l => `+${l * 15}% de gemmes`,
    max: 15, baseCost: 6,  costMult: 1.6 },
  { id: "start",   icon: "🎒", name: "Réserves de départ",
    desc: "Commencez chaque tentative avec un pécule de pièces.",
    effect: l => `+${l * 60} 🪙 au départ`,
    max: 15, baseCost: 3,  costMult: 1.5 },
  { id: "regen",   icon: "🔧", name: "Auto-réparation",
    desc: "Des nano-machines réparent la maison en continu.",
    effect: l => `+${(l * 0.6).toFixed(1)} PV/s de régénération`,
    max: 15, baseCost: 5,  costMult: 1.55 },
  { id: "crit",    icon: "🎯", name: "Visée chirurgicale",
    desc: "Chance d'infliger un coup critique (dégâts x3).",
    effect: l => `${l * 3}% de chance critique`,
    max: 12, baseCost: 5,  costMult: 1.6 },
  { id: "turret",  icon: "🤖", name: "Tourelle de toit",
    desc: "Installe une tourelle sur le toit. Chaque niveau la rend plus puissante.",
    effect: l => l === 0 ? "Non installée" : `Tourelle niv. ${l}`,
    max: 10, baseCost: 12, costMult: 1.7 },
  { id: "pierce",  icon: "🏹", name: "Balles perforantes",
    desc: "Vos balles traversent des monstres supplémentaires.",
    effect: l => `Traverse ${l} monstre${l > 1 ? "s" : ""} de plus`,
    max: 5,  baseCost: 15, costMult: 2.1 },
];

let meta = loadMeta();

function defaultMeta() {
  const lab = {};
  for (const u of LAB_UPGRADES) lab[u.id] = 0;
  return { gems: 0, lab, bestDay: 0, totalKills: 0, runs: 0, muted: false };
}
function loadMeta() {
  try {
    const raw = localStorage.getItem(SAVE_KEY);
    if (!raw) return defaultMeta();
    const m = Object.assign(defaultMeta(), JSON.parse(raw));
    if (m.adn != null && !m.gems) m.gems = m.adn; // anciennes sauvegardes
    m.lab = Object.assign(defaultMeta().lab, m.lab || {});
    return m;
  } catch (e) { return defaultMeta(); }
}
function saveMeta() {
  try { localStorage.setItem(SAVE_KEY, JSON.stringify(meta)); } catch (e) {}
}
function labCost(u) {
  return Math.round(u.baseCost * Math.pow(u.costMult, meta.lab[u.id]));
}

/* ========================= SONS RÉTRO 8-BIT ========================= */
/* Tout est synthétisé avec la Web Audio API : aucun fichier audio.      */

const SFX = (() => {
  let ac = null;
  let muted = !!meta.muted;
  const last = {};

  function audio() {
    if (!ac) ac = new (window.AudioContext || window.webkitAudioContext)();
    if (ac.state === "suspended") ac.resume();
    return ac;
  }
  function throttle(name, ms) {
    const t = performance.now();
    if (last[name] && t - last[name] < ms) return false;
    last[name] = t;
    return true;
  }
  // bip carré/triangle avec glissando — la brique de base du son 8-bit
  function tone({ f = 440, f2 = 0, dur = 0.1, type = "square", vol = 0.12, delay = 0 }) {
    if (muted) return;
    let a; try { a = audio(); } catch (e) { return; }
    const t0 = a.currentTime + delay;
    const o = a.createOscillator(), g = a.createGain();
    o.type = type;
    o.frequency.setValueAtTime(f, t0);
    if (f2) o.frequency.exponentialRampToValueAtTime(f2, t0 + dur);
    g.gain.setValueAtTime(vol, t0);
    g.gain.exponentialRampToValueAtTime(0.001, t0 + dur);
    o.connect(g); g.connect(a.destination);
    o.start(t0); o.stop(t0 + dur + 0.02);
  }
  // souffle de bruit blanc filtré — impacts et explosions
  function blast({ dur = 0.15, vol = 0.18, freq = 1200, delay = 0 }) {
    if (muted) return;
    let a; try { a = audio(); } catch (e) { return; }
    const t0 = a.currentTime + delay;
    const len = Math.max(1, Math.floor(a.sampleRate * dur));
    const buf = a.createBuffer(1, len, a.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < len; i++) data[i] = Math.random() * 2 - 1;
    const src = a.createBufferSource(); src.buffer = buf;
    const fl = a.createBiquadFilter(); fl.type = "lowpass"; fl.frequency.value = freq;
    const g = a.createGain();
    g.gain.setValueAtTime(vol, t0);
    g.gain.exponentialRampToValueAtTime(0.001, t0 + dur);
    src.connect(fl); fl.connect(g); g.connect(a.destination);
    src.start(t0);
  }

  return {
    shoot()  { if (throttle("shoot", 50)) tone({ f: 880, f2: 240, dur: 0.06, vol: 0.045 }); },
    hit()    { if (throttle("hit", 50)) blast({ dur: 0.04, vol: 0.05, freq: 2600 }); },
    kill()   { if (throttle("kill", 70)) {
                 tone({ f: 620, f2: 110, dur: 0.16, type: "sawtooth", vol: 0.07 });
                 tone({ f: 1318, dur: 0.05, vol: 0.05, delay: 0.03 });
               } },
    explo()  { if (throttle("explo", 90)) blast({ dur: 0.3, vol: 0.22, freq: 650 }); },
    gem()    { tone({ f: 1047, dur: 0.07, vol: 0.07 });
               tone({ f: 1568, dur: 0.1, vol: 0.07, delay: 0.07 }); },
    houseHit() { if (throttle("hh", 110)) {
                   tone({ f: 130, f2: 55, dur: 0.14, type: "triangle", vol: 0.2 });
                   blast({ dur: 0.07, vol: 0.09, freq: 500 });
                 } },
    buy()    { tone({ f: 523, dur: 0.06, vol: 0.09 });
               tone({ f: 784, dur: 0.09, vol: 0.09, delay: 0.06 }); },
    research() { [523, 659, 784, 1047].forEach((f, i) =>
                   tone({ f, dur: 0.1, vol: 0.08, delay: i * 0.08 })); },
    day()    { [392, 523, 659].forEach((f, i) =>
                 tone({ f, dur: 0.1, vol: 0.07, delay: i * 0.09 })); },
    death()  { [392, 330, 262, 196].forEach((f, i) =>
                 tone({ f, dur: 0.24, type: "triangle", vol: 0.12, delay: i * 0.18 })); },
    toggle() {
      muted = !muted;
      meta.muted = muted;
      saveMeta();
      return muted;
    },
    get muted() { return muted; },
  };
})();

/* ========================= AMÉLIORATIONS EN PARTIE ========================= */

const RUN_UPGRADES = [
  { id: "dmg",   icon: "🗡️", name: "Dégâts",   baseCost: 20,  costMult: 1.55, max: 60,
    tip: "+35% de dégâts" },
  { id: "rate",  icon: "⚡", name: "Cadence",   baseCost: 25,  costMult: 1.6,  max: 40,
    tip: "+12% de vitesse de tir" },
  { id: "range", icon: "🔭", name: "Portée",    baseCost: 30,  costMult: 1.7,  max: 12,
    tip: "+45 de portée" },
  { id: "wallhp",icon: "🏠", name: "Maison",    baseCost: 30,  costMult: 1.55, max: 50,
    tip: "+30% PV max et répare 40%" },
  { id: "repair",icon: "🔨", name: "Réparer",   baseCost: 15,  costMult: 1.35, max: 999,
    tip: "Répare 50% de la maison" },
  { id: "regen", icon: "💚", name: "Régén",     baseCost: 40,  costMult: 1.65, max: 25,
    tip: "+1 PV/s de régénération" },
  { id: "loot",  icon: "💰", name: "Butin",     baseCost: 35,  costMult: 1.7,  max: 25,
    tip: "+20% de pièces" },
  { id: "explo", icon: "💥", name: "Explosifs", baseCost: 120, costMult: 1.75, max: 15,
    tip: "Balles explosives : zone +" },
];

function runCost(u, lvl) {
  return Math.round(u.baseCost * Math.pow(u.costMult, lvl));
}

/* ========================= ÉTAT DE LA PARTIE ========================= */

let run = null;
let speed = 1;
let paused = false;
let gameOver = false;

function baseHouseMax() {
  return Math.round(150 * (1 + 0.20 * meta.lab.wallhp) * (1 + 0.30 * (run ? run.up.wallhp : 0)));
}

function newRun() {
  run = {
    day: 1,
    time: 0,
    money: meta.lab.start * 60,
    kills: 0,
    gemsEarned: 0,
    up: Object.fromEntries(RUN_UPGRADES.map(u => [u.id, 0])),
    houseHp: 0,
    houseMax: 0,
    monsters: [],
    bullets: [],
    particles: [],
    texts: [],
    coins: [],
    gems: [],
    toSpawn: 0,
    spawnTimer: 0,
    dayActive: false,
    dayDelay: 1.2,
    shootCd: 0,
    turretCd: 0,
    gunAngle: 0,
    turretAngle: Math.PI,
    mineTimer: 4,           // première gemme rapide pour montrer la mine
    shake: 0,
  };
  run.houseMax = baseHouseMax();
  run.houseHp = run.houseMax;
  startDay(1);
  meta.runs++;
  saveMeta();
  refreshHud();
  buildUpgradeBar();
}

/* ------- statistiques dérivées (labo + améliorations de partie) ------- */
const stats = {
  get dmg()    { return (10 + meta.lab.dmg * 4) * (1 + 0.35 * run.up.dmg); },
  get rate()   { return 1.3 * (1 + 0.08 * meta.lab.rate) * (1 + 0.12 * run.up.rate); },
  get range()  { return 360 + run.up.range * 45; },
  get regen()  { return meta.lab.regen * 0.6 + run.up.regen * 1.0; },
  get lootMul(){ return (1 + 0.10 * meta.lab.loot) * (1 + 0.20 * run.up.loot); },
  get gemMul() { return 1 + 0.15 * meta.lab.extract; },
  get mineDelay() { return 13 / this.gemMul; },
  get crit()   { return meta.lab.crit * 0.03; },
  get pierce() { return meta.lab.pierce; },
  get exploR() { return run.up.explo > 0 ? 35 + run.up.explo * 14 : 0; },
  get turretDmg()  { return meta.lab.turret > 0 ? (6 + meta.lab.turret * 5) * (1 + 0.18 * run.up.dmg) : 0; },
  get turretRate() { return 0.8 + meta.lab.turret * 0.07; },
};

/* ========================= JOURS & APPARITIONS ========================= */

function dayMonsterCount(day) { return Math.min(5 + day * 2, 60); }
function dayHpMult(day)       { return Math.pow(1.23, day - 1); }
function daySpawnGap(day)     { return Math.max(0.4, 2.0 - day * 0.05); }
function isBossDay(day)       { return day % 5 === 0; }

function startDay(day) {
  run.day = day;
  run.toSpawn = dayMonsterCount(day);
  run.spawnTimer = 0;
  run.dayActive = true;
  run.dayDelay = 1.2;
  showBanner(`☀️ Jour ${day}` + (isBossDay(day) ? "  —  ⚠️ COLOSSE ⚠️" : ""));
  SFX.day();
  if (day > meta.bestDay) { meta.bestDay = day; saveMeta(); }
}

function endDay() {
  run.dayActive = false;
  const gain = Math.max(1, Math.round((1 + run.day / 5) * stats.gemMul));
  gainGems(gain, CX, CY - 160);
  addText(`Jour ${run.day} survécu !`, W / 2, 220, "#ffd34d", 26);
  setTimeout(() => { if (!gameOver) startDay(run.day + 1); }, 1600 / speed);
}

/* ------- types de monstres ------- */
// tirage pondéré : le bestiaire s'enrichit au fil des jours
function pickMonsterType(day) {
  const pool = [["marcheur", 10]];
  if (day >= 3)  pool.push(["rapide", 6]);
  if (day >= 5)  pool.push(["costaud", 4]);
  if (day >= 6)  pool.push(["dore", 1.3]);
  if (day >= 7)  pool.push(["sauteur", 4]);
  if (day >= 8)  pool.push(["gluant", 3.5]);
  if (day >= 10) pool.push(["volant", 3.5]);
  if (day >= 12) pool.push(["casque", 3]);
  let total = 0;
  for (const [, w] of pool) total += w;
  let r = Math.random() * total;
  for (const [type, w] of pool) {
    r -= w;
    if (r <= 0) return type;
  }
  return "marcheur";
}

// point d'apparition hors écran, tout autour de la base
function spawnPoint() {
  const a = Math.random() * Math.PI * 2;
  const x = CX + Math.cos(a) * 820;
  const y = CY + Math.sin(a) * 470;
  return { x, y: Math.max(HORIZON + 28, y) };
}

function spawnMonster(type, at) {
  const day = run.day;
  const hpBase = 22 * dayHpMult(day);
  const rewardBase = 5 + day * 1.6;
  const T = {
    marcheur: { hp: hpBase,        spd: 46,  dmg: 6,  size: 1.0,  reward: rewardBase,
                color: "#6abf4b", color2: "#4e9637", belly: "#a8e08a" },
    rapide:   { hp: hpBase * 0.55, spd: 88,  dmg: 4,  size: 0.78, reward: rewardBase * 0.8,
                color: "#e8c33c", color2: "#bf9c22", belly: "#ffe89a" },
    costaud:  { hp: hpBase * 3.2,  spd: 26,  dmg: 14, size: 1.5,  reward: rewardBase * 2.6,
                color: "#3f8f8f", color2: "#2d6b6b", belly: "#8accc9", spikes: true },
    dore:     { hp: hpBase * 1.6,  spd: 62,  dmg: 5,  size: 1.0,  reward: rewardBase * 1.5,
                color: "#f0c93c", color2: "#c79e1d", belly: "#fff0b0", gem: true },
    // grenouille bondissante : rapide et nerveuse
    sauteur:  { hp: hpBase * 0.85, spd: 68,  dmg: 6,  size: 0.9,  reward: rewardBase * 1.1,
                color: "#e8833c", color2: "#b35f24", belly: "#ffc08a" },
    // se divise en deux gluants miniatures à sa mort
    gluant:   { hp: hpBase * 1.5,  spd: 36,  dmg: 8,  size: 1.2,  reward: rewardBase * 1.4,
                color: "#d667b8", color2: "#a8478f", belly: "#f0a8dd", slime: true, split: true },
    mini:     { hp: hpBase * 0.3,  spd: 74,  dmg: 3,  size: 0.55, reward: rewardBase * 0.35,
                color: "#d667b8", color2: "#a8478f", belly: "#f0a8dd", slime: true },
    // vole au-dessus du sol en battant des ailes
    volant:   { hp: hpBase * 0.7,  spd: 76,  dmg: 5,  size: 0.85, reward: rewardBase * 1.2,
                color: "#5fa8e0", color2: "#3f7fb3", belly: "#a8d4f0", fly: true },
    // casque d'acier : moitié moins de dégâts subis (sauf critiques)
    casque:   { hp: hpBase * 1.3,  spd: 40,  dmg: 10, size: 1.1,  reward: rewardBase * 1.8,
                color: "#8a9b6a", color2: "#6a7a4e", belly: "#c0cf9a", armor: 0.5 },
    boss:     { hp: hpBase * 18,   spd: 17,  dmg: 45, size: 2.7,  reward: rewardBase * 14,
                color: "#9656b8", color2: "#6e3a8c", belly: "#cfa0e8", boss: true, spikes: true },
  }[type];
  const p = at || spawnPoint();
  run.monsters.push({
    type, x: p.x, y: p.y,
    hp: T.hp, maxHp: T.hp, spd: T.spd * (0.9 + Math.random() * 0.2),
    dmg: T.dmg, size: T.size, reward: T.reward,
    color: T.color, color2: T.color2, belly: T.belly,
    gem: !!T.gem, boss: !!T.boss, spikes: !!T.spikes,
    fly: !!T.fly, slime: !!T.slime, split: !!T.split, armor: T.armor || 0,
    attackCd: 0, walk: Math.random() * 10, hitFlash: 0,
    blink: 1 + Math.random() * 3, wobbleSeed: Math.random() * 10,
  });
}

/* ========================= COMBAT ========================= */

function distToHouse(m) { return Math.hypot(m.x - CX, m.y - CY); }

function nearestMonster(maxDist) {
  let best = null, bd = maxDist;
  for (const m of run.monsters) {
    const d = distToHouse(m);
    if (d < bd) { bd = d; best = m; }
  }
  return best;
}

function fireBullet(fx, fy, dmg, target) {
  const tx = target.x, ty = target.y - target.size * 18 * depth(target.y);
  const ang = Math.atan2(ty - fy, tx - fx);
  const crit = Math.random() < stats.crit;
  run.bullets.push({
    x: fx, y: fy,
    vx: Math.cos(ang) * 760, vy: Math.sin(ang) * 760,
    dmg: crit ? dmg * 3 : dmg, crit,
    pierce: stats.pierce, hit: new Set(), life: 1.4,
  });
  addParticle(fx, fy, 3, "#ffe27a", 0.12, 50);
  SFX.shoot();
  return ang;
}

function damageMonster(m, dmg, crit) {
  if (m.armor > 0 && !crit) dmg *= 1 - m.armor;   // les critiques percent le casque
  m.hp -= dmg;
  m.hitFlash = 0.1;
  SFX.hit();
  addText(Math.round(dmg).toString(), m.x, m.y - m.size * 52 * depth(m.y),
          crit ? "#ffd34d" : "#fff", crit ? 22 : 15);
  if (m.hp <= 0) killMonster(m);
}

function killMonster(m) {
  const i = run.monsters.indexOf(m);
  if (i === -1) return;
  run.monsters.splice(i, 1);
  run.kills++; meta.totalKills++;
  const coins = Math.round(m.reward * stats.lootMul);
  run.money += coins;
  run.coins.push({ x: m.x, y: m.y - 30, t: 0, amount: coins });
  if (m.gem) gainGems(Math.max(1, Math.round(2 * stats.gemMul)), m.x, m.y - 40);
  if (m.boss) gainGems(Math.max(3, Math.round(5 * stats.gemMul)), m.x, m.y - 60);
  if (m.split) {  // le gluant se divise en deux miniatures
    spawnMonster("mini", { x: m.x - 16, y: m.y - 6 });
    spawnMonster("mini", { x: m.x + 16, y: m.y + 6 });
  }
  for (let k = 0; k < (m.boss ? 26 : 9); k++)
    addParticle(m.x, m.y - m.size * 18, 4 + Math.random() * 4, m.color, 0.6, 180);
  SFX.kill();
  refreshHud();
  refreshUpgradeBar();
}

function explode(x, y, radius, dmg) {
  addParticle(x, y, radius, "rgba(255,160,40,0.55)", 0.25, 0, true);
  run.shake = Math.min(run.shake + 3, 8);
  SFX.explo();
  for (const m of [...run.monsters]) {
    const d = Math.hypot(m.x - x, (m.y - m.size * 18) - y);
    if (d < radius + m.size * 18) damageMonster(m, dmg * 0.5, false);
  }
}

function gainGems(n, x, y) {
  run.gemsEarned += n;
  meta.gems += n;
  saveMeta();
  addText(`+${n} 💎`, x, y, "#6df0c2", 20);
  SFX.gem();
  refreshHud();
}

/* ========================= DÉCOR DU TERRAIN ========================= */

// générateur pseudo-aléatoire à graine fixe : le décor est identique
// à chaque partie, sans stocker la moindre image
function mulberry32(a) {
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const DECOR = (() => {
  const rnd = mulberry32(20260611);
  const items = [];
  const isClear = (x, y) =>
    Math.hypot(x - CX, (y - CY) * 1.7) > 255 &&
    Math.hypot(x - MINE_X, (y - MINE_Y) * 1.5) > 125 &&
    y > HORIZON + 42 && y < 645;
  const place = (type, count, extra) => {
    for (let i = 0; i < count; i++) {
      for (let tries = 0; tries < 50; tries++) {
        const x = 30 + rnd() * (W - 60);
        const y = HORIZON + 42 + rnd() * (645 - HORIZON - 42);
        if (!isClear(x, y)) continue;
        items.push({ type, x, y, v: rnd(), ...(extra ? extra(rnd) : {}) });
        break;
      }
    }
  };
  place("tree", 13);
  place("rock", 8);
  place("bush", 9);
  place("fence", 5, r => ({ n: 3 + Math.floor(r() * 3) }));
  return items;
})();

function drawDecor(it) {
  const d = depth(it.y);
  const x = it.x, y = it.y;
  if (it.type === "tree") {
    const tall = 1 + it.v * 0.4;
    const leaf = it.v > 0.55 ? ["#3e7a33", "#549642", "#6ab354"] : ["#2e6e44", "#3f8a58", "#55a86e"];
    ctx.fillStyle = "rgba(0,0,0,0.2)";
    ctx.beginPath(); ctx.ellipse(x, y + 2, 20 * d, 7 * d, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#6b4a2a";
    ctx.fillRect(x - 4 * d, y - 26 * d * tall, 8 * d, 26 * d * tall);
    ctx.fillStyle = leaf[0];
    ctx.beginPath(); ctx.ellipse(x, y - 32 * d * tall, 22 * d, 16 * d, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = leaf[1];
    ctx.beginPath(); ctx.ellipse(x - 4 * d, y - 44 * d * tall, 17 * d, 13 * d, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = leaf[2];
    ctx.beginPath(); ctx.ellipse(x + 3 * d, y - 53 * d * tall, 11 * d, 9 * d, 0, 0, Math.PI * 2); ctx.fill();
  } else if (it.type === "rock") {
    const r = (6 + it.v * 9) * d;
    ctx.fillStyle = "rgba(0,0,0,0.18)";
    ctx.beginPath(); ctx.ellipse(x, y + 2, r * 1.5, r * 0.5, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#8a8f99";
    ctx.beginPath(); ctx.ellipse(x, y - r * 0.6, r * 1.3, r, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#a3a8b3";
    ctx.beginPath(); ctx.ellipse(x - r * 0.4, y - r * 0.9, r * 0.6, r * 0.45, 0, 0, Math.PI * 2); ctx.fill();
    if (it.v > 0.6) {
      ctx.fillStyle = "#777d87";
      ctx.beginPath(); ctx.ellipse(x + r * 1.1, y - r * 0.25, r * 0.5, r * 0.4, 0, 0, Math.PI * 2); ctx.fill();
    }
  } else if (it.type === "bush") {
    const r = (8 + it.v * 6) * d;
    ctx.fillStyle = "rgba(0,0,0,0.16)";
    ctx.beginPath(); ctx.ellipse(x, y + 1, r * 1.4, r * 0.45, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#4e8a3a";
    ctx.beginPath(); ctx.ellipse(x, y - r * 0.5, r * 1.4, r * 0.8, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#63a64c";
    ctx.beginPath(); ctx.ellipse(x - r * 0.4, y - r * 0.8, r * 0.8, r * 0.5, 0, 0, Math.PI * 2); ctx.fill();
    if (it.v > 0.5) {       // quelques baies rouges
      ctx.fillStyle = "#d94f4f";
      for (const [bx, by] of [[-0.6, -0.5], [0.3, -0.9], [0.8, -0.4]])
        ctx.fillRect(x + bx * r - 1.5 * d, y + by * r - 1.5 * d, 3 * d, 3 * d);
    }
  } else if (it.type === "fence") {
    const gap = 24 * d;
    const h = 20 * d;
    ctx.fillStyle = "#7a5836";
    for (let i = 0; i < it.n; i++) {     // rails puis poteaux
      ctx.fillRect(x + i * gap, y - h * 0.75, gap, 3.5 * d);
      ctx.fillRect(x + i * gap, y - h * 0.35, gap, 3.5 * d);
    }
    ctx.fillStyle = "#8d6a42";
    for (let i = 0; i <= it.n; i++) {
      ctx.fillRect(x + i * gap - 2.5 * d, y - h, 5 * d, h);
      ctx.fillStyle = "rgba(0,0,0,0.16)";
      ctx.fillRect(x + i * gap - 3 * d, y - 1, 6 * d, 3 * d);
      ctx.fillStyle = "#8d6a42";
    }
  }
}

/* ========================= EFFETS VISUELS ========================= */

function addParticle(x, y, size, color, life, spread, ring) {
  run.particles.push({
    x, y, size, color, life, maxLife: life, ring: !!ring,
    vx: (Math.random() - 0.5) * spread,
    vy: -Math.random() * spread * 0.8,
  });
}
function addText(txt, x, y, color, size) {
  run.texts.push({ txt, x, y, color, size, life: 0.9 });
}
function showBanner(txt) {
  const b = document.getElementById("day-banner");
  b.textContent = txt;
  b.classList.remove("hidden");
  b.style.animation = "none";
  void b.offsetWidth; // relance l'animation
  b.style.animation = "";
}

/* ========================= BOUCLE DE JEU ========================= */

let lastT = performance.now();
function loop(now) {
  let dt = Math.min((now - lastT) / 1000, 0.05);
  lastT = now;
  if (run && !paused && !gameOver) {
    for (let i = 0; i < speed; i++) update(dt);
  }
  if (run) draw();
  requestAnimationFrame(loop);
}

function update(dt) {
  run.time += dt;

  /* --- apparitions --- */
  if (run.dayActive) {
    if (run.dayDelay > 0) {
      run.dayDelay -= dt;
    } else if (run.toSpawn > 0) {
      run.spawnTimer -= dt;
      if (run.spawnTimer <= 0) {
        run.spawnTimer = daySpawnGap(run.day) * (0.6 + Math.random() * 0.8);
        spawnMonster(pickMonsterType(run.day));
        run.toSpawn--;
        if (run.toSpawn === 0 && isBossDay(run.day)) spawnMonster("boss");
      }
    } else if (run.monsters.length === 0) {
      endDay();
    }
  }

  /* --- la mine produit des gemmes --- */
  run.mineTimer -= dt;
  if (run.mineTimer <= 0) {
    run.mineTimer = stats.mineDelay;
    run.gems.push({ x: MINE_X, y: MINE_Y - 30, vy: -120, t: 0, amount: 1 });
  }
  for (const g of [...run.gems]) {
    g.t += dt;
    if (g.t < 0.8) {                 // petit bond hors de la mine
      g.y += g.vy * dt; g.vy += 360 * dt;
    } else if (g.t < 1.5) {          // vol vers le compteur en haut
      const k = (g.t - 0.8) / 0.7;
      g.x += (640 - g.x) * k * 0.25;
      g.y += (30 - g.y) * k * 0.25;
    } else {
      run.gems.splice(run.gems.indexOf(g), 1);
      gainGems(g.amount, 640, 60);
    }
  }

  /* --- tir du survivant (sur le toit) --- */
  run.shootCd -= dt;
  const gunX = CX - 16, gunY = CY - 168;
  const target = nearestMonster(stats.range);
  if (target) run.gunAngle = Math.atan2(target.y - 60 - gunY, target.x - gunX);
  if (target && run.shootCd <= 0) {
    run.shootCd = 1 / stats.rate;
    fireBullet(gunX, gunY, stats.dmg, target);
  }
  /* --- tourelle de toit --- */
  if (meta.lab.turret > 0) {
    run.turretCd -= dt;
    const tx = CX + 34, ty = CY - 135;
    const t2 = nearestMonster(stats.range * 0.85);
    if (t2) run.turretAngle = Math.atan2(t2.y - 60 - ty, t2.x - tx);
    if (t2 && run.turretCd <= 0) {
      run.turretCd = 1 / stats.turretRate;
      fireBullet(tx, ty, stats.turretDmg, t2);
    }
  }

  /* --- balles --- */
  for (const b of [...run.bullets]) {
    b.x += b.vx * dt; b.y += b.vy * dt; b.life -= dt;
    if (b.life <= 0 || b.x < -50 || b.x > W + 50 || b.y < HORIZON - 40 || b.y > H + 50) {
      run.bullets.splice(run.bullets.indexOf(b), 1);
      continue;
    }
    for (const m of run.monsters) {
      if (b.hit.has(m)) continue;
      const d = depth(m.y);
      const mx = m.x, my = m.y - m.size * 18 * d;
      if (Math.abs(b.x - mx) < m.size * 20 * d && Math.abs(b.y - my) < m.size * 26 * d) {
        b.hit.add(m);
        damageMonster(m, b.dmg, b.crit);
        if (stats.exploR > 0) explode(b.x, b.y, stats.exploR, b.dmg);
        if (b.hit.size > b.pierce) {
          run.bullets.splice(run.bullets.indexOf(b), 1);
        }
        break;
      }
    }
  }

  /* --- monstres : convergent vers la maison de tous les côtés --- */
  for (const m of run.monsters) {
    m.hitFlash = Math.max(0, m.hitFlash - dt);
    m.blink -= dt;
    if (m.blink < -0.12) m.blink = 1.5 + Math.random() * 3;
    const d = distToHouse(m);
    const stopAt = HOUSE_R + m.size * 10;
    if (d > stopAt) {
      const wob = Math.sin(run.time * 2.2 + m.wobbleSeed) * 0.35;
      const ang = Math.atan2(CY - m.y, CX - m.x) + wob * 0.3;
      const dep = depth(m.y);   // les monstres lointains paraissent plus lents
      m.x += Math.cos(ang) * m.spd * dt * dep;
      m.y += Math.sin(ang) * m.spd * dt * dep;
      m.y = Math.max(HORIZON + 24, m.y);
      m.walk += dt * (m.type === "rapide" ? 14 : m.type === "costaud" || m.boss ? 5 : 9);
    } else {
      m.walk += dt * 3;
      m.attackCd -= dt;
      if (m.attackCd <= 0) {
        m.attackCd = 0.9;
        run.houseHp -= m.dmg;
        run.shake = Math.min(run.shake + 1.5, 8);
        SFX.houseHit();
        addParticle(CX + (m.x - CX) * 0.5, CY - 40 + (m.y - CY) * 0.3, 5, "#d9c08a", 0.3, 120);
        if (run.houseHp <= 0) { run.houseHp = 0; die(); return; }
      }
    }
  }

  /* --- régénération --- */
  if (stats.regen > 0 && run.houseHp > 0)
    run.houseHp = Math.min(run.houseMax, run.houseHp + stats.regen * dt);

  /* --- particules / textes / pièces --- */
  for (const p of [...run.particles]) {
    p.life -= dt;
    p.x += p.vx * dt; p.y += p.vy * dt; p.vy += 300 * dt;
    if (p.life <= 0) run.particles.splice(run.particles.indexOf(p), 1);
  }
  for (const t of [...run.texts]) {
    t.life -= dt; t.y -= 40 * dt;
    if (t.life <= 0) run.texts.splice(run.texts.indexOf(t), 1);
  }
  for (const c of [...run.coins]) {
    c.t += dt;
    if (c.t > 0.7) run.coins.splice(run.coins.indexOf(c), 1);
  }
  run.shake = Math.max(0, run.shake - dt * 14);
}

/* ========================= MORT / RECOMMENCER ========================= */

function die() {
  gameOver = true;
  SFX.death();
  meta.bestDay = Math.max(meta.bestDay, run.day);
  saveMeta();
  const s = document.getElementById("death-stats");
  s.innerHTML = `
    <div class="stat"><span class="label">Jours survécus</span>☀️ ${run.day}</div>
    <div class="stat"><span class="label">Monstres éliminés</span>💀 ${run.kills}</div>
    <div class="stat"><span class="label">Gemmes récoltées</span>💎 ${run.gemsEarned}</div>
    <div class="stat"><span class="label">Record</span>🏆 Jour ${meta.bestDay}</div>`;
  document.getElementById("death-screen").classList.remove("hidden");
}

function restart() {
  document.getElementById("death-screen").classList.add("hidden");
  gameOver = false;
  newRun();
}

/* ========================= INTERFACE ========================= */

function fmt(n) {
  if (n >= 1e6) return (n / 1e6).toFixed(1) + "M";
  if (n >= 1e4) return (n / 1e3).toFixed(1) + "k";
  return Math.floor(n).toString();
}

function refreshHud() {
  if (run) {
    document.getElementById("hud-day").textContent = `☀️ Jour ${run.day}`;
    document.getElementById("hud-money").textContent = `🪙 ${fmt(run.money)}`;
  }
  document.getElementById("hud-best").textContent = `Record : Jour ${meta.bestDay}`;
  document.getElementById("hud-adn").textContent = `💎 ${meta.gems}`;
  document.getElementById("lab-adn").textContent = `💎 ${meta.gems}`;
}

/* ------- barre d'améliorations en jeu ------- */
const upBtnEls = {};
function buildUpgradeBar() {
  const bar = document.getElementById("upgrade-bar");
  bar.innerHTML = "";
  for (const u of RUN_UPGRADES) {
    const btn = document.createElement("button");
    btn.className = "up-btn";
    btn.title = u.tip;
    btn.addEventListener("click", () => buyRunUpgrade(u));
    bar.appendChild(btn);
    upBtnEls[u.id] = btn;
  }
  refreshUpgradeBar();
}
function refreshUpgradeBar() {
  for (const u of RUN_UPGRADES) {
    const lvl = run.up[u.id];
    const btn = upBtnEls[u.id];
    if (!btn) continue;
    const maxed = lvl >= u.max;
    const cost = runCost(u, lvl);
    btn.classList.toggle("maxed", maxed);
    btn.classList.toggle("affordable", !maxed && run.money >= cost);
    btn.innerHTML = `
      <div class="up-icon">${u.icon}</div>
      <div class="up-name">${u.name}</div>
      <div class="up-lvl">${u.id === "repair" ? "" : "niv. " + lvl}</div>
      <div class="up-cost">${maxed ? "MAX" : "🪙 " + fmt(cost)}</div>`;
  }
}
function buyRunUpgrade(u) {
  const lvl = run.up[u.id];
  if (lvl >= u.max) return;
  const cost = runCost(u, lvl);
  if (run.money < cost || gameOver) return;
  run.money -= cost;
  run.up[u.id]++;
  if (u.id === "wallhp") {
    run.houseMax = baseHouseMax();
    run.houseHp = Math.min(run.houseMax, run.houseHp + run.houseMax * 0.4);
  }
  if (u.id === "repair") {
    run.houseHp = Math.min(run.houseMax, run.houseHp + run.houseMax * 0.5);
  }
  SFX.buy();
  refreshHud();
  refreshUpgradeBar();
}

/* ------- laboratoire ------- */
function buildLab() {
  const grid = document.getElementById("lab-grid");
  grid.innerHTML = "";
  for (const u of LAB_UPGRADES) {
    const lvl = meta.lab[u.id];
    const maxed = lvl >= u.max;
    const cost = labCost(u);
    const card = document.createElement("div");
    card.className = "lab-card";
    card.innerHTML = `
      <div class="lc-top">
        <span class="lc-icon">${u.icon}</span>
        <span class="lc-name">${u.name}</span>
        <span class="lc-lvl">niv. ${lvl}/${u.max}</span>
      </div>
      <div class="lc-desc">${u.desc}</div>
      <div class="lc-effect">${u.effect(lvl)}</div>`;
    const btn = document.createElement("button");
    btn.className = "lab-buy" + (maxed ? " maxed" : meta.gems >= cost ? " affordable" : "");
    btn.textContent = maxed ? "MAX" : `Rechercher — 💎 ${cost}`;
    btn.addEventListener("click", () => {
      if (maxed || meta.gems < labCost(u)) return;
      meta.gems -= labCost(u);
      meta.lab[u.id]++;
      saveMeta();
      SFX.research();
      if (u.id === "wallhp" && run) run.houseMax = baseHouseMax();
      refreshHud();
      buildLab();
      refreshUpgradeBar();
    });
    card.appendChild(btn);
    grid.appendChild(card);
  }
  refreshHud();
}

/* ------- lobby du laboratoire ------- */
function openLobby() {
  buildLab();
  paused = true;
  document.getElementById("lobby-best").textContent = `🏆 Record : Jour ${meta.bestDay}`;
  document.getElementById("lobby-runs").textContent = `⚔️ Parties : ${meta.runs}`;
  document.getElementById("lobby-kills").textContent = `💀 Monstres : ${fmt(meta.totalKills)}`;
  document.getElementById("btn-lobby-start").textContent =
    run && !gameOver ? "▶️ Reprendre la partie" : "⚔️ Lancer l'assaut";
  document.getElementById("lobby").classList.remove("hidden");
}
function leaveLobby() {
  document.getElementById("lobby").classList.add("hidden");
  if (run && !gameOver) {
    paused = false;            // on reprend la partie en cours
  } else {
    gameOver = false;
    paused = false;
    newRun();                  // nouvelle tentative
  }
}

/* ------- boutons ------- */
document.getElementById("btn-lab").addEventListener("click", openLobby);
document.getElementById("btn-lobby-start").addEventListener("click", leaveLobby);
document.getElementById("btn-death-lab").addEventListener("click", () => {
  document.getElementById("death-screen").classList.add("hidden");
  openLobby();
});
document.getElementById("btn-restart").addEventListener("click", restart);
document.getElementById("btn-speed").addEventListener("click", () => {
  speed = speed >= 3 ? 1 : speed + 1;
  document.getElementById("btn-speed").textContent = `⏩ x${speed}`;
});
const soundBtn = document.getElementById("btn-sound");
soundBtn.textContent = SFX.muted ? "🔇" : "🔊";
soundBtn.addEventListener("click", () => {
  soundBtn.textContent = SFX.toggle() ? "🔇" : "🔊";
});
document.getElementById("btn-pause").addEventListener("click", () => {
  paused = true;
  document.getElementById("pause-screen").classList.remove("hidden");
});
document.getElementById("btn-resume").addEventListener("click", () => {
  paused = false;
  document.getElementById("pause-screen").classList.add("hidden");
});
document.getElementById("btn-reset-save").addEventListener("click", () => {
  if (confirm("Effacer définitivement toute la progression (laboratoire compris) ?")) {
    localStorage.removeItem(SAVE_KEY);
    meta = loadMeta();
    paused = true;
    document.getElementById("pause-screen").classList.add("hidden");
    gameOver = false;
    run = null;
    document.getElementById("death-screen").classList.add("hidden");
    ctx.clearRect(0, 0, W, H);
    refreshHud();
    openLobby();
  }
});

/* ========================= RENDU ========================= */

function draw() {
  /* ---- passe 1 : le monde, en basse résolution (pixel art) ---- */
  ctx = pixCtx;
  ctx.save();
  ctx.setTransform(1 / PIX, 0, 0, 1 / PIX, 0, 0);
  if (run.shake > 0)
    ctx.translate((Math.random() - 0.5) * run.shake, (Math.random() - 0.5) * run.shake);

  drawGround();
  drawRangeRing();

  // entités triées par profondeur (y croissant) pour la superposition
  const drawables = [
    { y: CY, fn: drawHouse },
    { y: MINE_Y, fn: drawMine },
    ...DECOR.map(it => ({ y: it.y, fn: () => drawDecor(it) })),
    ...run.monsters.map(m => ({ y: m.y, fn: () => drawMonster(m) })),
  ];
  drawables.sort((a, b) => a.y - b.y);
  for (const d of drawables) d.fn();

  drawBullets();
  drawParticles();
  drawGems();
  ctx.restore();

  /* ---- passe 2 : agrandissement x4 sans lissage ---- */
  ctx = mainCtx;
  ctx.imageSmoothingEnabled = false;
  ctx.drawImage(pixCanvas, 0, 0, W, H);

  /* ---- passe 3 : textes et barres d'interface, nets ---- */
  ctx.save();
  if (run.shake > 0)
    ctx.translate((Math.random() - 0.5) * run.shake, (Math.random() - 0.5) * run.shake);
  drawCoinsAndTexts();
  drawHouseHpBar();
  ctx.restore();
}

function drawGround() {
  // ciel et horizon
  const sky = ctx.createLinearGradient(0, 0, 0, HORIZON);
  sky.addColorStop(0, "#6db5e8");
  sky.addColorStop(1, "#bfe3f5");
  ctx.fillStyle = sky;
  ctx.fillRect(0, 0, W, HORIZON);

  // nuages qui dérivent lentement
  ctx.fillStyle = "rgba(255,255,255,0.85)";
  for (let i = 0; i < 4; i++) {
    const cx2 = ((i * 390 + run.time * 7 + i * 60) % (W + 240)) - 120;
    const cy2 = 22 + (i * 37) % 50;
    ctx.beginPath();
    ctx.ellipse(cx2, cy2, 34, 11, 0, 0, Math.PI * 2);
    ctx.ellipse(cx2 - 22, cy2 + 5, 22, 9, 0, 0, Math.PI * 2);
    ctx.ellipse(cx2 + 24, cy2 + 4, 24, 9, 0, 0, Math.PI * 2);
    ctx.fill();
  }

  // collines lointaines
  ctx.fillStyle = "#7fb56a";
  ctx.beginPath();
  ctx.moveTo(0, HORIZON);
  for (let x = 0; x <= W; x += 80)
    ctx.lineTo(x, HORIZON - 14 - 16 * Math.abs(Math.sin(x * 0.013 + 2)));
  ctx.lineTo(W, HORIZON);
  ctx.closePath();
  ctx.fill();
  // rangée de sapins à l'horizon
  ctx.fillStyle = "#4e7a42";
  for (let i = 0; i < 32; i++) {
    const tx = i * 41 + ((i * 53) % 17);
    const th = 10 + ((i * 29) % 12);
    ctx.beginPath();
    ctx.moveTo(tx - 7, HORIZON);
    ctx.lineTo(tx, HORIZON - th);
    ctx.lineTo(tx + 7, HORIZON);
    ctx.closePath();
    ctx.fill();
  }

  // grande prairie en dégradé (effet de profondeur)
  const grass = ctx.createLinearGradient(0, HORIZON, 0, H);
  grass.addColorStop(0, "#8fcf6e");
  grass.addColorStop(1, "#5fa844");
  ctx.fillStyle = grass;
  ctx.fillRect(0, HORIZON, W, H - HORIZON);

  // touffes d'herbe et cailloux (fixes, pseudo-aléatoires)
  for (let i = 0; i < 60; i++) {
    const gx = (i * 211 + 37) % W;
    const gy = HORIZON + 30 + ((i * 127 + 51) % (H - HORIZON - 60));
    const d = depth(gy);
    ctx.fillStyle = i % 3 ? "rgba(60,130,45,0.5)" : "rgba(255,255,255,0.25)";
    ctx.fillRect(gx, gy, 7 * d, 3 * d);
  }
  // petites fleurs des champs
  const petals = ["#ffffff", "#ffd34d", "#ff8fa8", "#b8a0ff"];
  for (let i = 0; i < 26; i++) {
    const fx = (i * 173 + 89) % W;
    const fy = HORIZON + 40 + ((i * 229 + 17) % (H - HORIZON - 90));
    if (Math.hypot(fx - CX, (fy - CY) * 1.7) < 200) continue;
    const d = depth(fy);
    ctx.fillStyle = "#3c7a2e";
    ctx.fillRect(fx + 1.5 * d, fy, 2 * d, 5 * d);
    ctx.fillStyle = petals[i % 4];
    ctx.fillRect(fx, fy - 4 * d, 5 * d, 5 * d);
    ctx.fillStyle = "#e8a23c";
    ctx.fillRect(fx + 1.5 * d, fy - 2.5 * d, 2 * d, 2 * d);
  }

  // terre battue autour de la maison
  ctx.fillStyle = "#c9a76a";
  ctx.beginPath();
  ctx.ellipse(CX, CY + 8, 150, 64, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#d9b87c";
  ctx.beginPath();
  ctx.ellipse(CX, CY + 8, 122, 50, 0, 0, Math.PI * 2);
  ctx.fill();
  // petit chemin vers la mine
  ctx.strokeStyle = "#c9a76a";
  ctx.lineWidth = 18;
  ctx.beginPath();
  ctx.moveTo(CX + 70, CY + 40);
  ctx.quadraticCurveTo(CX + 150, CY + 60, MINE_X - 20, MINE_Y + 6);
  ctx.stroke();
}

function drawRangeRing() {
  ctx.strokeStyle = "rgba(255,255,255,0.22)";
  ctx.lineWidth = 5;
  ctx.setLineDash([14, 16]);
  ctx.beginPath();
  ctx.ellipse(CX, CY, stats.range, stats.range * 0.55, 0, 0, Math.PI * 2);
  ctx.stroke();
  ctx.setLineDash([]);
}

/* ------- la petite maison ------- */
function drawHouse() {
  const x = CX, y = CY;

  // ombre au sol
  ctx.fillStyle = "rgba(0,0,0,0.2)";
  ctx.beginPath();
  ctx.ellipse(x + 6, y + 26, 96, 34, 0, 0, Math.PI * 2);
  ctx.fill();

  // mur latéral droit (perspective)
  ctx.fillStyle = "#d9b88a";
  ctx.beginPath();
  ctx.moveTo(x + 58, y - 88);
  ctx.lineTo(x + 92, y - 102);
  ctx.lineTo(x + 92, y - 6);
  ctx.lineTo(x + 58, y + 22);
  ctx.closePath();
  ctx.fill();

  // mur avant
  ctx.fillStyle = "#f0d6a8";
  ctx.fillRect(x - 62, y - 88, 120, 110);
  ctx.strokeStyle = "#b3905c";
  ctx.lineWidth = 3;
  ctx.strokeRect(x - 62, y - 88, 120, 110);

  // porte
  ctx.fillStyle = "#8a5c30";
  ctx.fillRect(x - 18, y - 24, 32, 46);
  ctx.strokeStyle = "#6b4522";
  ctx.strokeRect(x - 18, y - 24, 32, 46);
  ctx.fillStyle = "#e8c84a";
  ctx.beginPath(); ctx.arc(x + 7, y - 2, 3, 0, Math.PI * 2); ctx.fill();

  // fenêtre
  ctx.fillStyle = "#9adcf0";
  ctx.fillRect(x - 50, y - 64, 26, 24);
  ctx.strokeStyle = "#6b4522";
  ctx.lineWidth = 2.5;
  ctx.strokeRect(x - 50, y - 64, 26, 24);
  ctx.beginPath();
  ctx.moveTo(x - 37, y - 64); ctx.lineTo(x - 37, y - 40);
  ctx.moveTo(x - 50, y - 52); ctx.lineTo(x - 24, y - 52);
  ctx.stroke();

  // toit : pan avant + pan latéral
  ctx.fillStyle = "#c0563c";
  ctx.beginPath();
  ctx.moveTo(x - 74, y - 86);
  ctx.lineTo(x - 2, y - 142);
  ctx.lineTo(x + 70, y - 86);
  ctx.closePath();
  ctx.fill();
  ctx.strokeStyle = "#8e3a26";
  ctx.lineWidth = 3;
  ctx.stroke();
  ctx.fillStyle = "#a8462f";
  ctx.beginPath();
  ctx.moveTo(x - 2, y - 142);
  ctx.lineTo(x + 38, y - 152);
  ctx.lineTo(x + 98, y - 100);
  ctx.lineTo(x + 70, y - 86);
  ctx.closePath();
  ctx.fill();

  // cheminée
  ctx.fillStyle = "#9c6b48";
  ctx.fillRect(x + 42, y - 146, 16, 26);
  ctx.fillStyle = "#7a4f33";
  ctx.fillRect(x + 40, y - 150, 20, 6);
  // fumée
  ctx.fillStyle = "rgba(255,255,255,0.45)";
  for (let i = 0; i < 3; i++) {
    const t = (run.time * 0.5 + i * 0.33) % 1;
    ctx.beginPath();
    ctx.arc(x + 50 + Math.sin(t * 6) * 5, y - 156 - t * 34, 4 + t * 6, 0, Math.PI * 2);
    ctx.fill();
  }

  drawGunner(x - 16, y - 138, run.gunAngle, run.shootCd > 1 / stats.rate - 0.06);
  if (meta.lab.turret > 0)
    drawTurret(x + 34, y - 126, run.turretAngle, run.turretCd > 1 / stats.turretRate - 0.06);
}

function drawGunner(x, y, ang, flash) {
  const bob = Math.sin(run.time * 3) * 1.5;
  // jambes
  ctx.fillStyle = "#3a4a60";
  ctx.fillRect(x - 7, y - 14, 6, 14);
  ctx.fillRect(x + 2, y - 14, 6, 14);
  // corps
  ctx.fillStyle = "#7a3b2e";
  ctx.fillRect(x - 9, y - 36 + bob, 19, 23);
  // tête + casquette
  ctx.fillStyle = "#e8b88a";
  ctx.fillRect(x - 7, y - 51 + bob, 15, 15);
  ctx.fillStyle = "#314a31";
  ctx.fillRect(x - 8, y - 55 + bob, 17, 6);
  // fusil orienté vers la cible
  ctx.save();
  ctx.translate(x, y - 30 + bob);
  ctx.rotate(ang);
  ctx.fillStyle = "#2c2c2c";
  ctx.fillRect(2, -3, 30, 6);
  ctx.fillRect(8, 3, 6, 8);
  if (flash) {
    ctx.fillStyle = "#ffe27a";
    ctx.beginPath(); ctx.arc(36, 0, 7, 0, Math.PI * 2); ctx.fill();
  }
  ctx.restore();
}

function drawTurret(x, y, ang, flash) {
  ctx.fillStyle = "#4a5566";
  ctx.fillRect(x - 11, y - 6, 22, 12);
  ctx.fillStyle = "#5d7396";
  ctx.beginPath(); ctx.arc(x, y - 8, 10, 0, Math.PI * 2); ctx.fill();
  ctx.save();
  ctx.translate(x, y - 9);
  ctx.rotate(ang);
  ctx.fillStyle = "#2c2c2c";
  ctx.fillRect(4, -3, 24, 6);
  if (flash) {
    ctx.fillStyle = "#ffe27a";
    ctx.beginPath(); ctx.arc(32, 0, 6, 0, Math.PI * 2); ctx.fill();
  }
  ctx.restore();
}

/* ------- la mine à gemmes ------- */
function drawMine() {
  const x = MINE_X, y = MINE_Y;
  // ombre
  ctx.fillStyle = "rgba(0,0,0,0.18)";
  ctx.beginPath();
  ctx.ellipse(x, y + 10, 62, 20, 0, 0, Math.PI * 2);
  ctx.fill();
  // monticule rocheux
  ctx.fillStyle = "#8a8f99";
  ctx.beginPath();
  ctx.ellipse(x, y - 22, 56, 42, 0, Math.PI, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#a3a8b3";
  ctx.beginPath();
  ctx.ellipse(x - 12, y - 30, 34, 28, 0, Math.PI, Math.PI * 2);
  ctx.fill();
  // entrée et étais en bois
  ctx.fillStyle = "#2b2b33";
  ctx.beginPath();
  ctx.ellipse(x, y + 2, 22, 26, 0, Math.PI, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#8a5c30";
  ctx.fillRect(x - 27, y - 26, 8, 32);
  ctx.fillRect(x + 19, y - 26, 8, 32);
  ctx.fillRect(x - 31, y - 32, 62, 8);
  // cristaux qui scintillent
  const tw = (Math.sin(run.time * 4) + 1) / 2;
  drawCrystal(x - 38, y - 2, 9, tw);
  drawCrystal(x + 40, y - 8, 11, 1 - tw);
  drawCrystal(x + 26, y + 8, 7, tw);
  // pancarte
  ctx.fillStyle = "#8a5c30";
  ctx.fillRect(x - 58, y - 4, 5, 18);
  ctx.fillStyle = "#b3905c";
  ctx.fillRect(x - 70, y - 16, 29, 15);
  ctx.font = "bold 11px Trebuchet MS";
  ctx.textAlign = "center";
  ctx.fillStyle = "#4a2f16";
  ctx.fillText("💎", x - 55, y - 4);
}

function drawCrystal(x, y, s, glow) {
  ctx.fillStyle = `rgba(109,240,194,${0.75 + glow * 0.25})`;
  ctx.beginPath();
  ctx.moveTo(x, y - s * 1.6);
  ctx.lineTo(x + s * 0.8, y - s * 0.4);
  ctx.lineTo(x + s * 0.4, y);
  ctx.lineTo(x - s * 0.4, y);
  ctx.lineTo(x - s * 0.8, y - s * 0.4);
  ctx.closePath();
  ctx.fill();
  ctx.fillStyle = `rgba(255,255,255,${0.3 + glow * 0.4})`;
  ctx.fillRect(x - s * 0.25, y - s * 1.2, s * 0.3, s * 0.7);
}

/* ------- petits monstres animés ------- */
function drawMonster(m) {
  const d = depth(m.y);
  const s = m.size * d;
  const x = m.x, y = m.y;
  const hopH = m.type === "sauteur" ? 15 : m.type === "rapide" ? 9 :
               (m.boss || m.slime || m.type === "costaud" || m.type === "casque") ? 3 : 5;
  // les volants planent au-dessus du sol, les autres sautillent
  const hop = m.fly ? 28 * s + Math.sin(m.walk * 0.8) * 6 * s
                    : Math.abs(Math.sin(m.walk)) * hopH * s;
  const squash = 1 + Math.sin(m.walk * 2) * 0.07;       // rebond pâte à modeler
  const toHouse = Math.atan2(CY - y, CX - x);
  const lookX = Math.cos(toHouse) * 2.5 * s;
  const lookY = Math.sin(toHouse) * 1.5 * s;

  const body = m.hitFlash > 0 ? "#ffffff" : m.color;
  const dark = m.hitFlash > 0 ? "#dddddd" : m.color2;
  const belly = m.hitFlash > 0 ? "#ffffff" : m.belly;

  // ombre au sol
  ctx.fillStyle = m.fly ? "rgba(0,0,0,0.13)" : "rgba(0,0,0,0.22)";
  ctx.beginPath();
  ctx.ellipse(x, y + 2, 16 * s * (1 - hop / 60), 6 * s, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.save();
  ctx.translate(x, y - hop);
  ctx.scale(squash, 2 - squash);

  if (m.fly) {
    // ailes battantes
    const flap = Math.sin(m.walk * 3) * 0.9;
    ctx.fillStyle = "rgba(220,240,255,0.85)";
    for (const side of [-1, 1]) {
      ctx.save();
      ctx.translate(side * 12 * s, -24 * s);
      ctx.rotate(side * (0.5 + flap));
      ctx.beginPath();
      ctx.ellipse(side * 8 * s, 0, 11 * s, 4.5 * s, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }
    // petites pattes pendantes
    ctx.fillStyle = dark;
    ctx.fillRect(-6 * s, -4 * s, 3 * s, 6 * s);
    ctx.fillRect(3 * s, -4 * s, 3 * s, 6 * s);
  } else if (m.slime) {
    // flaque gluante qui goutte
    ctx.fillStyle = dark;
    ctx.beginPath(); ctx.ellipse(0, -1 * s, 16 * s, 5 * s, 0, 0, Math.PI * 2); ctx.fill();
    const drip = (m.walk * 0.7) % 1;
    ctx.beginPath();
    ctx.ellipse(-11 * s, -1 * s + drip * 5 * s, 2.2 * s, 3 * s, 0, 0, Math.PI * 2);
    ctx.fill();
  } else if (m.type === "sauteur") {
    // longues pattes de grenouille repliées
    const step = Math.sin(m.walk) * 4 * s;
    ctx.fillStyle = dark;
    for (const side of [-1, 1]) {
      ctx.save();
      ctx.translate(side * 10 * s, -6 * s);
      ctx.rotate(side * (0.5 - step / (10 * s)));
      ctx.beginPath(); ctx.ellipse(0, 4 * s, 4 * s, 8 * s, 0, 0, Math.PI * 2); ctx.fill();
      ctx.restore();
    }
  } else {
    // pieds qui trottinent
    const step = Math.sin(m.walk) * 5 * s;
    ctx.fillStyle = dark;
    ctx.beginPath(); ctx.ellipse(-7 * s + step, 0, 5.5 * s, 3.5 * s, 0, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.ellipse(7 * s - step, 0, 5.5 * s, 3.5 * s, 0, 0, Math.PI * 2); ctx.fill();
  }

  // corps patate
  ctx.fillStyle = body;
  ctx.beginPath();
  ctx.ellipse(0, -17 * s, 15 * s, 17 * s, 0, 0, Math.PI * 2);
  ctx.fill();
  // ventre clair
  ctx.fillStyle = belly;
  ctx.beginPath();
  ctx.ellipse(lookX * 0.8, -13 * s, 8 * s, 9 * s, 0, 0, Math.PI * 2);
  ctx.fill();

  // petits bras ballants
  const wave = Math.sin(m.walk + 1) * 0.5;
  ctx.fillStyle = dark;
  ctx.save();
  ctx.translate(-14 * s, -18 * s); ctx.rotate(-0.6 + wave);
  ctx.beginPath(); ctx.ellipse(0, 4 * s, 3 * s, 6 * s, 0, 0, Math.PI * 2); ctx.fill();
  ctx.restore();
  ctx.save();
  ctx.translate(14 * s, -18 * s); ctx.rotate(0.6 - wave);
  ctx.beginPath(); ctx.ellipse(0, 4 * s, 3 * s, 6 * s, 0, 0, Math.PI * 2); ctx.fill();
  ctx.restore();

  // piquants du costaud / cornes du colosse
  if (m.spikes) {
    ctx.fillStyle = dark;
    for (const [sx, sy, r] of [[-8, -30, -0.5], [0, -33, 0], [8, -30, 0.5]]) {
      ctx.save();
      ctx.translate(sx * s, sy * s); ctx.rotate(r);
      ctx.beginPath();
      ctx.moveTo(-3 * s, 0); ctx.lineTo(0, -7 * s); ctx.lineTo(3 * s, 0);
      ctx.closePath(); ctx.fill();
      ctx.restore();
    }
  }
  // casque d'acier du monstre blindé
  if (m.armor > 0) {
    ctx.fillStyle = m.hitFlash > 0 ? "#eeeeee" : "#6a7280";
    ctx.beginPath();
    ctx.ellipse(0, -26 * s, 15 * s, 10 * s, 0, Math.PI, Math.PI * 2);
    ctx.fill();
    ctx.fillRect(-15 * s, -27 * s, 30 * s, 3.5 * s);
    ctx.fillStyle = m.hitFlash > 0 ? "#dddddd" : "#8a92a3";
    ctx.fillRect(-3 * s, -36 * s, 6 * s, 7 * s);   // pointe du casque
  }
  // couronne du monstre doré
  if (m.gem) {
    ctx.fillStyle = "#fff27a";
    ctx.beginPath();
    ctx.moveTo(-7 * s, -31 * s); ctx.lineTo(-7 * s, -38 * s); ctx.lineTo(-3 * s, -33 * s);
    ctx.lineTo(0, -39 * s); ctx.lineTo(3 * s, -33 * s); ctx.lineTo(7 * s, -38 * s);
    ctx.lineTo(7 * s, -31 * s);
    ctx.closePath(); ctx.fill();
  }

  // yeux qui regardent la maison, avec clignement
  const blink = m.blink < 0 ? 0.15 : 1;
  for (const ex of [-5.5, 5.5]) {
    ctx.fillStyle = "#fff";
    ctx.beginPath();
    ctx.ellipse(ex * s + lookX * 0.4, -23 * s, 4.2 * s, 4.6 * s * blink, 0, 0, Math.PI * 2);
    ctx.fill();
    if (blink === 1) {
      ctx.fillStyle = m.boss ? "#c01818" : "#1a1a1a";
      ctx.beginPath();
      ctx.arc(ex * s + lookX, -23 * s + lookY, 2.4 * s, 0, Math.PI * 2);
      ctx.fill();
    }
  }
  // bouche
  ctx.strokeStyle = "#1a1a1a";
  ctx.lineWidth = 4 * s;
  ctx.beginPath();
  ctx.arc(lookX * 0.6, -15 * s, 3.5 * s, 0.15 * Math.PI, 0.85 * Math.PI);
  ctx.stroke();
  if (m.boss) { // crocs du colosse
    ctx.fillStyle = "#fff";
    ctx.beginPath();
    ctx.moveTo(-3 * s, -13 * s); ctx.lineTo(-1.6 * s, -9.5 * s); ctx.lineTo(-0.2 * s, -13 * s);
    ctx.moveTo(3 * s, -13 * s); ctx.lineTo(1.6 * s, -9.5 * s); ctx.lineTo(0.2 * s, -13 * s);
    ctx.fill();
  }

  ctx.restore();

  // barre de vie
  if (m.hp < m.maxHp) {
    const w = 36 * s;
    ctx.fillStyle = "rgba(0,0,0,0.6)";
    ctx.fillRect(x - w / 2, y - 48 * s - hop, w, 5);
    ctx.fillStyle = m.boss ? "#c75bff" : "#6dd96d";
    ctx.fillRect(x - w / 2, y - 48 * s - hop, w * Math.max(0, m.hp / m.maxHp), 5);
  }
}

function drawBullets() {
  for (const b of run.bullets) {
    ctx.fillStyle = b.crit ? "#ffd34d" : "#fff3c0";
    ctx.save();
    ctx.translate(b.x, b.y);
    ctx.rotate(Math.atan2(b.vy, b.vx));
    ctx.fillRect(-8, -2, 14, 4);
    ctx.restore();
  }
}

function drawParticles() {
  for (const p of run.particles) {
    const a = Math.max(0, p.life / p.maxLife);
    if (p.ring) {
      ctx.strokeStyle = p.color;
      ctx.globalAlpha = a;
      ctx.lineWidth = 6;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size * (1.4 - a * 0.6), 0, Math.PI * 2);
      ctx.stroke();
    } else {
      ctx.globalAlpha = a;
      ctx.fillStyle = p.color;
      ctx.fillRect(p.x - p.size / 2, p.y - p.size / 2, p.size, p.size);
    }
    ctx.globalAlpha = 1;
  }
}

function drawGems() {
  for (const g of run.gems) {
    drawCrystal(g.x, g.y, 9, (Math.sin(run.time * 8 + g.t * 5) + 1) / 2);
  }
}

function drawCoinsAndTexts() {
  ctx.textAlign = "center";
  for (const c of run.coins) {
    const a = 1 - c.t / 0.7;
    ctx.globalAlpha = a;
    ctx.font = "bold 16px Trebuchet MS";
    ctx.fillStyle = "#ffd34d";
    ctx.fillText(`+${fmt(c.amount)} 🪙`, c.x, c.y - c.t * 50);
    ctx.globalAlpha = 1;
  }
  for (const t of run.texts) {
    ctx.globalAlpha = Math.max(0, t.life / 0.9);
    ctx.font = `bold ${t.size}px Trebuchet MS`;
    ctx.strokeStyle = "rgba(0,0,0,0.8)";
    ctx.lineWidth = 3;
    ctx.strokeText(t.txt, t.x, t.y);
    ctx.fillStyle = t.color;
    ctx.fillText(t.txt, t.x, t.y);
    ctx.globalAlpha = 1;
  }
}

function drawHouseHpBar() {
  const w = 140, h = 14;
  const x = CX - w / 2, y = CY - 232;
  const ratio = run.houseHp / run.houseMax;
  ctx.fillStyle = "rgba(0,0,0,0.65)";
  ctx.fillRect(x - 2, y - 2, w + 4, h + 4);
  ctx.fillStyle = ratio > 0.5 ? "#5fd35f" : ratio > 0.25 ? "#e8c84a" : "#e85b4a";
  ctx.fillRect(x, y, w * Math.max(0, ratio), h);
  ctx.strokeStyle = "#fff";
  ctx.lineWidth = 2;
  ctx.strokeRect(x - 2, y - 2, w + 4, h + 4);
  ctx.font = "bold 11px Trebuchet MS";
  ctx.fillStyle = "#fff";
  ctx.textAlign = "center";
  ctx.fillText(`${Math.ceil(run.houseHp)} / ${run.houseMax}`, CX, y + 11);
}

/* ========================= MISE À L'ÉCHELLE ========================= */

function fitToWindow() {
  const wrap = document.getElementById("game-wrap");
  const scale = Math.min(window.innerWidth / 1280, window.innerHeight / 720);
  wrap.style.transform = `scale(${scale})`;
  wrap.style.marginLeft = `${Math.max(0, (window.innerWidth - 1280 * scale) / 2)}px`;
}
window.addEventListener("resize", fitToWindow);

/* ========================= DÉMARRAGE ========================= */

fitToWindow();
refreshHud();
openLobby();               // le jeu démarre dans le lobby du laboratoire
requestAnimationFrame(loop);
