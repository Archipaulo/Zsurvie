/* =========================================================================
   ZSURVIE — défense de barricade incrémentale
   Survivez le plus de jours possible face à la horde.
   Améliorations temporaires en partie (🪙) + recherches permanentes au
   Laboratoire (🧬), conservées entre les tentatives via localStorage.
   ========================================================================= */
"use strict";

const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");
const W = canvas.width, H = canvas.height;

const GROUND_Y = 600;        // sol
const WALL_X = 230;          // bord droit de la barricade
const SPAWN_X = W + 60;      // apparition des zombies

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
  { id: "wallhp",  icon: "🧱", name: "Barricade blindée",
    desc: "Renforce la structure de la barricade au début de chaque journée 1.",
    effect: l => `+${l * 20}% PV de barricade`,
    max: 25, baseCost: 3,  costMult: 1.45 },
  { id: "loot",    icon: "💰", name: "Fouille experte",
    desc: "Les zombies lâchent plus de pièces.",
    effect: l => `+${l * 10}% de pièces`,
    max: 20, baseCost: 4,  costMult: 1.5 },
  { id: "extract", icon: "🧪", name: "Extraction d'ADN",
    desc: "Vous récoltez davantage d'ADN sur les spécimens et en fin de journée.",
    effect: l => `+${l * 15}% d'ADN récolté`,
    max: 15, baseCost: 6,  costMult: 1.6 },
  { id: "start",   icon: "🎒", name: "Réserves de départ",
    desc: "Commencez chaque tentative avec un pécule de pièces.",
    effect: l => `+${l * 60} 🪙 au départ`,
    max: 15, baseCost: 3,  costMult: 1.5 },
  { id: "regen",   icon: "🔧", name: "Auto-réparation",
    desc: "Des nano-machines réparent la barricade en continu.",
    effect: l => `+${(l * 0.6).toFixed(1)} PV/s de régénération`,
    max: 15, baseCost: 5,  costMult: 1.55 },
  { id: "crit",    icon: "🎯", name: "Visée chirurgicale",
    desc: "Chance d'infliger un coup critique (dégâts x3).",
    effect: l => `${l * 3}% de chance critique`,
    max: 12, baseCost: 5,  costMult: 1.6 },
  { id: "turret",  icon: "🤖", name: "Tourelle automatique",
    desc: "Installe une tourelle sur la barricade. Chaque niveau la rend plus puissante.",
    effect: l => l === 0 ? "Non installée" : `Tourelle niv. ${l}`,
    max: 10, baseCost: 12, costMult: 1.7 },
  { id: "pierce",  icon: "🏹", name: "Balles perforantes",
    desc: "Vos balles traversent des zombies supplémentaires.",
    effect: l => `Traverse ${l} zombie${l > 1 ? "s" : ""} de plus`,
    max: 5,  baseCost: 15, costMult: 2.1 },
];

let meta = loadMeta();

function defaultMeta() {
  const lab = {};
  for (const u of LAB_UPGRADES) lab[u.id] = 0;
  return { adn: 0, lab, bestDay: 0, totalKills: 0, runs: 0 };
}
function loadMeta() {
  try {
    const raw = localStorage.getItem(SAVE_KEY);
    if (!raw) return defaultMeta();
    const m = Object.assign(defaultMeta(), JSON.parse(raw));
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

/* ========================= AMÉLIORATIONS EN PARTIE ========================= */

const RUN_UPGRADES = [
  { id: "dmg",   icon: "🗡️", name: "Dégâts",        baseCost: 20,  costMult: 1.55, max: 60,
    tip: "+35% de dégâts" },
  { id: "rate",  icon: "⚡", name: "Cadence",        baseCost: 25,  costMult: 1.6,  max: 40,
    tip: "+12% de vitesse de tir" },
  { id: "range", icon: "🔭", name: "Portée",         baseCost: 30,  costMult: 1.7,  max: 12,
    tip: "+45 de portée" },
  { id: "wallhp",icon: "🧱", name: "Barricade",      baseCost: 30,  costMult: 1.55, max: 50,
    tip: "+30% PV max et répare 40%" },
  { id: "repair",icon: "🔨", name: "Réparer",        baseCost: 15,  costMult: 1.35, max: 999,
    tip: "Répare 50% de la barricade" },
  { id: "regen", icon: "💚", name: "Régén",          baseCost: 40,  costMult: 1.65, max: 25,
    tip: "+1 PV/s de régénération" },
  { id: "loot",  icon: "💰", name: "Butin",          baseCost: 35,  costMult: 1.7,  max: 25,
    tip: "+20% de pièces" },
  { id: "explo", icon: "💥", name: "Explosifs",      baseCost: 120, costMult: 1.75, max: 15,
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

function newRun() {
  const lab = meta.lab;
  const wallMax = Math.round(150 * (1 + 0.20 * lab.wallhp));
  run = {
    day: 1,
    time: 0,
    money: lab.start * 60,
    kills: 0,
    adnEarned: 0,
    up: Object.fromEntries(RUN_UPGRADES.map(u => [u.id, 0])),
    wallHp: wallMax,
    wallMax,
    zombies: [],
    bullets: [],
    particles: [],
    texts: [],
    coins: [],
    // état de la vague du jour
    toSpawn: 0,
    spawnTimer: 0,
    dayActive: false,
    dayDelay: 1.2,          // pause avant le début du jour
    shootCd: 0,
    turretCd: 0,
    shake: 0,
  };
  startDay(1);
  meta.runs++;
  saveMeta();
  refreshHud();
  buildUpgradeBar();
}

/* ------- statistiques dérivées (labo + améliorations de partie) ------- */
const stats = {
  get dmg()    { return (10 + meta.lab.dmg * 4) * (1 + 0.35 * run.up.dmg); },
  get rate()   { return 1.1 * (1 + 0.08 * meta.lab.rate) * (1 + 0.12 * run.up.rate); },
  get range()  { return 430 + run.up.range * 45; },
  get regen()  { return meta.lab.regen * 0.6 + run.up.regen * 1.0; },
  get lootMul(){ return (1 + 0.10 * meta.lab.loot) * (1 + 0.20 * run.up.loot); },
  get adnMul() { return 1 + 0.15 * meta.lab.extract; },
  get crit()   { return meta.lab.crit * 0.03; },
  get pierce() { return meta.lab.pierce; },
  get exploR() { return run.up.explo > 0 ? 35 + run.up.explo * 14 : 0; },
  get turretDmg()  { return meta.lab.turret > 0 ? (6 + meta.lab.turret * 5) * (1 + 0.18 * run.up.dmg) : 0; },
  get turretRate() { return 0.8 + meta.lab.turret * 0.07; },
};

/* ========================= JOURS & APPARITIONS ========================= */

function dayZombieCount(day) { return Math.min(6 + Math.round(day * 2.5), 60); }
function dayHpMult(day)      { return Math.pow(1.23, day - 1); }
function daySpawnGap(day)    { return Math.max(0.4, 2.0 - day * 0.05); }
function isBossDay(day)      { return day % 5 === 0; }

function startDay(day) {
  run.day = day;
  run.toSpawn = dayZombieCount(day);
  run.spawnTimer = 0;
  run.dayActive = true;
  run.dayDelay = 1.2;
  showBanner(`☀️ Jour ${day}` + (isBossDay(day) ? "  —  ⚠️ COLOSSE ⚠️" : ""));
  if (day > meta.bestDay) { meta.bestDay = day; saveMeta(); }
}

function endDay() {
  run.dayActive = false;
  const gain = Math.max(1, Math.round((1 + run.day / 5) * stats.adnMul));
  gainAdn(gain, WALL_X + 60, 300);
  addText(`Jour ${run.day} survécu !`, W / 2, 250, "#ffd34d", 26);
  setTimeout(() => { if (!gameOver) startDay(run.day + 1); }, 1600 / speed);
}

/* ------- types de zombies ------- */
// poids d'apparition selon le jour
function pickZombieType(day) {
  const r = Math.random();
  if (day >= 6 && r < 0.07) return "dore";
  if (day >= 5 && r < 0.22) return "costaud";
  if (day >= 3 && r < 0.45) return "rapide";
  return "marcheur";
}

function spawnZombie(type) {
  const day = run.day;
  const hpBase = 22 * dayHpMult(day);
  const rewardBase = 5 + day * 1.6;
  const Z = {
    marcheur: { hp: hpBase,        spd: 48,  dmg: 6,  size: 1.0, reward: rewardBase,
                color: "#5d9b4a", color2: "#477a38" },
    rapide:   { hp: hpBase * 0.55, spd: 85,  dmg: 4,  size: 0.82, reward: rewardBase * 0.8,
                color: "#8fb84d", color2: "#6e9138" },
    costaud:  { hp: hpBase * 3.2,  spd: 26,  dmg: 14, size: 1.45, reward: rewardBase * 2.6,
                color: "#4a7a62", color2: "#365c49" },
    dore:     { hp: hpBase * 1.6,  spd: 60,  dmg: 5,  size: 1.0, reward: rewardBase * 1.5,
                color: "#d9b13b", color2: "#b08c22", adn: true },
    boss:     { hp: hpBase * 18,   spd: 18,  dmg: 45, size: 2.6, reward: rewardBase * 14,
                color: "#7a4a8f", color2: "#5c3370", boss: true },
  }[type];
  run.zombies.push({
    type, x: SPAWN_X + Math.random() * 80,
    y: GROUND_Y - 2 - Math.random() * 10,
    hp: Z.hp, maxHp: Z.hp, spd: Z.spd * (0.9 + Math.random() * 0.2),
    dmg: Z.dmg, size: Z.size, reward: Z.reward,
    color: Z.color, color2: Z.color2,
    adn: !!Z.adn, boss: !!Z.boss,
    attackCd: 0, walk: Math.random() * 10, hitFlash: 0,
  });
}

/* ========================= COMBAT ========================= */

function nearestZombie(maxDist) {
  let best = null, bd = maxDist;
  for (const z of run.zombies) {
    const d = z.x - WALL_X;
    if (d < bd) { bd = d; best = z; }
  }
  return best;
}

function fireBullet(fromY, dmg, target) {
  const fx = WALL_X - 14;
  const ang = Math.atan2((target.y - target.size * 30) - fromY, target.x - fx);
  const crit = Math.random() < stats.crit;
  run.bullets.push({
    x: fx, y: fromY,
    vx: Math.cos(ang) * 900, vy: Math.sin(ang) * 900,
    dmg: crit ? dmg * 3 : dmg, crit,
    pierce: stats.pierce, hit: new Set(),
  });
  // douille / flash
  addParticle(fx, fromY, 3, "#ffe27a", 0.15, 60);
}

function damageZombie(z, dmg, crit) {
  z.hp -= dmg;
  z.hitFlash = 0.1;
  addText(Math.round(dmg).toString(), z.x, z.y - z.size * 58,
          crit ? "#ffd34d" : "#fff", crit ? 22 : 15);
  if (z.hp <= 0) killZombie(z);
}

function killZombie(z) {
  const i = run.zombies.indexOf(z);
  if (i === -1) return;
  run.zombies.splice(i, 1);
  run.kills++; meta.totalKills++;
  const coins = Math.round(z.reward * stats.lootMul);
  run.money += coins;
  run.coins.push({ x: z.x, y: z.y - 30, t: 0, amount: coins });
  if (z.adn) gainAdn(Math.max(1, Math.round(2 * stats.adnMul)), z.x, z.y - 40);
  if (z.boss) gainAdn(Math.max(3, Math.round(5 * stats.adnMul)), z.x, z.y - 60);
  for (let k = 0; k < (z.boss ? 26 : 9); k++)
    addParticle(z.x, z.y - z.size * 30, 4 + Math.random() * 4, z.color, 0.6, 180);
  refreshHud();
  refreshUpgradeBar();
}

function explode(x, y, radius, dmg) {
  addParticle(x, y, radius, "rgba(255,160,40,0.55)", 0.25, 0, true);
  run.shake = Math.min(run.shake + 3, 8);
  for (const z of [...run.zombies]) {
    const d = Math.hypot(z.x - x, (z.y - z.size * 30) - y);
    if (d < radius + z.size * 22) damageZombie(z, dmg * 0.5, false);
  }
}

function gainAdn(n, x, y) {
  run.adnEarned += n;
  meta.adn += n;
  saveMeta();
  addText(`+${n} 🧬`, x, y, "#6df0c2", 20);
  refreshHud();
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
  if (!paused && !gameOver) {
    for (let i = 0; i < speed; i++) update(dt);
  }
  draw();
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
        spawnZombie(pickZombieType(run.day));
        run.toSpawn--;
        if (run.toSpawn === 0 && isBossDay(run.day)) spawnZombie("boss");
      }
    } else if (run.zombies.length === 0) {
      endDay();
    }
  }

  /* --- tir du survivant --- */
  run.shootCd -= dt;
  const target = nearestZombie(stats.range);
  if (target && run.shootCd <= 0) {
    run.shootCd = 1 / stats.rate;
    fireBullet(GROUND_Y - 195, stats.dmg, target);
  }
  /* --- tourelle --- */
  if (meta.lab.turret > 0) {
    run.turretCd -= dt;
    const t2 = nearestZombie(stats.range * 0.85);
    if (t2 && run.turretCd <= 0) {
      run.turretCd = 1 / stats.turretRate;
      fireBullet(GROUND_Y - 90, stats.turretDmg, t2);
    }
  }

  /* --- balles --- */
  for (const b of [...run.bullets]) {
    b.x += b.vx * dt; b.y += b.vy * dt;
    if (b.x > W + 50 || b.y > H || b.y < 0) {
      run.bullets.splice(run.bullets.indexOf(b), 1);
      continue;
    }
    for (const z of run.zombies) {
      if (b.hit.has(z)) continue;
      const zx = z.x, zy = z.y - z.size * 30;
      if (Math.abs(b.x - zx) < z.size * 20 && Math.abs(b.y - zy) < z.size * 34) {
        b.hit.add(z);
        damageZombie(z, b.dmg, b.crit);
        if (stats.exploR > 0) explode(b.x, b.y, stats.exploR, b.dmg);
        if (b.hit.size > b.pierce) {
          run.bullets.splice(run.bullets.indexOf(b), 1);
        }
        break;
      }
    }
  }

  /* --- zombies --- */
  for (const z of run.zombies) {
    z.hitFlash = Math.max(0, z.hitFlash - dt);
    if (z.x > WALL_X + z.size * 16 + 6) {
      z.x -= z.spd * dt;
      z.walk += dt * z.spd * 0.15;
    } else {
      z.attackCd -= dt;
      if (z.attackCd <= 0) {
        z.attackCd = 0.9;
        run.wallHp -= z.dmg;
        run.shake = Math.min(run.shake + 1.5, 8);
        addParticle(WALL_X + 8, z.y - z.size * 30, 5, "#c9a36a", 0.3, 120);
        if (run.wallHp <= 0) { run.wallHp = 0; die(); return; }
      }
    }
  }

  /* --- régénération --- */
  if (stats.regen > 0 && run.wallHp > 0)
    run.wallHp = Math.min(run.wallMax, run.wallHp + stats.regen * dt);

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
  meta.bestDay = Math.max(meta.bestDay, run.day);
  saveMeta();
  const s = document.getElementById("death-stats");
  s.innerHTML = `
    <div class="stat"><span class="label">Jours survécus</span>☀️ ${run.day}</div>
    <div class="stat"><span class="label">Zombies éliminés</span>💀 ${run.kills}</div>
    <div class="stat"><span class="label">ADN récolté</span>🧬 ${run.adnEarned}</div>
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
  document.getElementById("hud-day").textContent = `☀️ Jour ${run.day}`;
  document.getElementById("hud-best").textContent = `Record : Jour ${meta.bestDay}`;
  document.getElementById("hud-money").textContent = `🪙 ${fmt(run.money)}`;
  document.getElementById("hud-adn").textContent = `🧬 ${meta.adn}`;
  const labAdn = document.getElementById("lab-adn");
  if (labAdn) labAdn.textContent = `🧬 ${meta.adn}`;
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
    run.wallMax = Math.round(150 * (1 + 0.20 * meta.lab.wallhp) * (1 + 0.30 * run.up.wallhp));
    run.wallHp = Math.min(run.wallMax, run.wallHp + run.wallMax * 0.4);
  }
  if (u.id === "repair") {
    run.wallHp = Math.min(run.wallMax, run.wallHp + run.wallMax * 0.5);
  }
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
    btn.className = "lab-buy" + (maxed ? " maxed" : meta.adn >= cost ? " affordable" : "");
    btn.textContent = maxed ? "MAX" : `Rechercher — 🧬 ${cost}`;
    btn.addEventListener("click", () => {
      if (maxed || meta.adn < labCost(u)) return;
      meta.adn -= labCost(u);
      meta.lab[u.id]++;
      saveMeta();
      // les bonus de barricade s'appliquent immédiatement
      if (u.id === "wallhp" && run) {
        run.wallMax = Math.round(150 * (1 + 0.20 * meta.lab.wallhp) * (1 + 0.30 * run.up.wallhp));
      }
      refreshHud();
      buildLab();
      refreshUpgradeBar();
    });
    card.appendChild(btn);
    grid.appendChild(card);
  }
  refreshHud();
}

let labWasPaused = false;
function openLab() {
  buildLab();
  labWasPaused = paused;
  paused = true;
  document.getElementById("lab-screen").classList.remove("hidden");
}
function closeLab() {
  document.getElementById("lab-screen").classList.add("hidden");
  if (!gameOver) paused = labWasPaused;
}

/* ------- boutons ------- */
document.getElementById("btn-lab").addEventListener("click", openLab);
document.getElementById("btn-lab-close").addEventListener("click", closeLab);
document.getElementById("btn-death-lab").addEventListener("click", openLab);
document.getElementById("btn-restart").addEventListener("click", restart);
document.getElementById("btn-speed").addEventListener("click", () => {
  speed = speed >= 3 ? 1 : speed + 1;
  document.getElementById("btn-speed").textContent = `⏩ x${speed}`;
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
    paused = false;
    document.getElementById("pause-screen").classList.add("hidden");
    gameOver = false;
    document.getElementById("death-screen").classList.add("hidden");
    newRun();
  }
});

/* ========================= RENDU ========================= */

function draw() {
  ctx.save();
  if (run.shake > 0)
    ctx.translate((Math.random() - 0.5) * run.shake, (Math.random() - 0.5) * run.shake);

  drawBackground();
  drawWall();
  drawSurvivor();
  if (meta.lab.turret > 0) drawTurret();
  for (const z of run.zombies) drawZombie(z);
  drawBullets();
  drawParticles();
  drawCoinsAndTexts();
  drawWallHpBar();

  ctx.restore();
}

function drawBackground() {
  // ciel crépusculaire
  const sky = ctx.createLinearGradient(0, 0, 0, GROUND_Y);
  sky.addColorStop(0, "#1c2a45");
  sky.addColorStop(0.6, "#3d3354");
  sky.addColorStop(1, "#7a4a4a");
  ctx.fillStyle = sky;
  ctx.fillRect(0, 0, W, GROUND_Y);

  // lune
  ctx.fillStyle = "#e8e3c8";
  ctx.beginPath(); ctx.arc(1050, 110, 42, 0, Math.PI * 2); ctx.fill();
  ctx.fillStyle = "#d6d0b2";
  ctx.beginPath(); ctx.arc(1035, 100, 9, 0, Math.PI * 2); ctx.fill();
  ctx.beginPath(); ctx.arc(1065, 125, 6, 0, Math.PI * 2); ctx.fill();

  // ville en ruine au loin
  ctx.fillStyle = "#242b3d";
  for (let i = 0; i < 14; i++) {
    const bx = 80 + i * 95, bh = 60 + ((i * 73) % 130);
    ctx.fillRect(bx, GROUND_Y - 110 - bh, 56, bh + 110);
  }
  ctx.fillStyle = "#2e3850";
  for (let i = 0; i < 18; i++) {
    const bx = 30 + i * 75, bh = 30 + ((i * 47) % 80);
    ctx.fillRect(bx, GROUND_Y - 40 - bh, 44, bh + 40);
  }

  // sol
  ctx.fillStyle = "#4a4036";
  ctx.fillRect(0, GROUND_Y, W, H - GROUND_Y);
  ctx.fillStyle = "#5a5044";
  ctx.fillRect(0, GROUND_Y, W, 10);
  ctx.fillStyle = "#3c342c";
  for (let i = 0; i < 20; i++)
    ctx.fillRect((i * 137 + 40) % W, GROUND_Y + 25 + (i * 53) % 60, 26, 6);
}

function drawWall() {
  const left = WALL_X - 90;
  // corps de la barricade : planches
  for (let row = 0; row < 6; row++) {
    const y = GROUND_Y - 30 - row * 28;
    ctx.fillStyle = row % 2 ? "#8a6a42" : "#7a5c38";
    ctx.fillRect(left, y - 26, 90, 26);
    ctx.strokeStyle = "#5c452a";
    ctx.lineWidth = 2;
    ctx.strokeRect(left, y - 26, 90, 26);
  }
  // poutres verticales
  ctx.fillStyle = "#6a4f30";
  ctx.fillRect(left + 6, GROUND_Y - 198, 12, 198);
  ctx.fillRect(left + 72, GROUND_Y - 198, 12, 198);
  // plateforme du survivant
  ctx.fillStyle = "#5c452a";
  ctx.fillRect(left - 8, GROUND_Y - 204, 106, 10);
  // sacs de sable au pied
  ctx.fillStyle = "#9c8a5a";
  for (let i = 0; i < 3; i++) {
    ctx.beginPath();
    ctx.ellipse(WALL_X + 2, GROUND_Y - 10 - i * 16, 22, 10, 0, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.fillStyle = "#8a7a4e";
  ctx.beginPath();
  ctx.ellipse(WALL_X + 10, GROUND_Y - 8, 18, 9, 0, 0, Math.PI * 2);
  ctx.fill();
}

function drawSurvivor() {
  const x = WALL_X - 45, y = GROUND_Y - 204;
  const bob = Math.sin(run.time * 3) * 1.5;
  // jambes
  ctx.fillStyle = "#3a4a60";
  ctx.fillRect(x - 8, y - 22, 7, 22);
  ctx.fillRect(x + 2, y - 22, 7, 22);
  // corps
  ctx.fillStyle = "#7a3b2e";
  ctx.fillRect(x - 11, y - 48 + bob, 22, 28);
  // tête
  ctx.fillStyle = "#e8b88a";
  ctx.fillRect(x - 8, y - 66 + bob, 17, 17);
  // casquette
  ctx.fillStyle = "#314a31";
  ctx.fillRect(x - 9, y - 70 + bob, 19, 6);
  ctx.fillRect(x + 2, y - 66 + bob, 12, 4);
  // fusil pointé vers la droite
  ctx.fillStyle = "#2c2c2c";
  ctx.fillRect(x + 2, y - 44 + bob, 34, 6);
  ctx.fillRect(x + 8, y - 38 + bob, 6, 10);
  // flash de tir
  if (run.shootCd > 1 / stats.rate - 0.06) {
    ctx.fillStyle = "#ffe27a";
    ctx.beginPath();
    ctx.arc(x + 40, y - 41 + bob, 7, 0, Math.PI * 2);
    ctx.fill();
  }
}

function drawTurret() {
  const x = WALL_X - 28, y = GROUND_Y - 90;
  ctx.fillStyle = "#4a5566";
  ctx.fillRect(x - 12, y - 6, 24, 16);
  ctx.fillStyle = "#5d7396";
  ctx.beginPath(); ctx.arc(x, y - 8, 11, 0, Math.PI * 2); ctx.fill();
  ctx.fillStyle = "#2c2c2c";
  ctx.fillRect(x, y - 12, 26, 7);
  if (run.turretCd > 1 / stats.turretRate - 0.06) {
    ctx.fillStyle = "#ffe27a";
    ctx.beginPath(); ctx.arc(x + 30, y - 9, 6, 0, Math.PI * 2); ctx.fill();
  }
}

function drawZombie(z) {
  const s = z.size;
  const x = z.x, y = z.y;
  const lurch = Math.sin(z.walk) * 3 * s;
  const lean = Math.sin(z.walk * 0.5) * 0.06;

  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(-0.08 + lean);

  const body = z.hitFlash > 0 ? "#ffffff" : z.color;
  const dark = z.hitFlash > 0 ? "#dddddd" : z.color2;

  // jambes traînantes
  ctx.fillStyle = dark;
  ctx.fillRect(-9 * s, -20 * s, 7 * s, 20 * s);
  ctx.fillRect(2 * s + lurch * 0.4, -18 * s, 7 * s, 18 * s);
  // torse déchiré
  ctx.fillStyle = body;
  ctx.fillRect(-12 * s, -46 * s + lurch * 0.3, 24 * s, 28 * s);
  ctx.fillStyle = dark;
  ctx.fillRect(-12 * s, -28 * s + lurch * 0.3, 10 * s, 6 * s);
  // bras tendus vers la barricade
  ctx.fillStyle = body;
  ctx.fillRect(-30 * s, -42 * s + lurch, 20 * s, 6 * s);
  ctx.fillRect(-26 * s, -32 * s - lurch, 16 * s, 6 * s);
  // tête penchée
  ctx.fillStyle = body;
  ctx.fillRect(-14 * s, -64 * s + lurch * 0.5, 18 * s, 18 * s);
  // œil
  ctx.fillStyle = z.boss ? "#ff5b5b" : "#e8e84a";
  ctx.fillRect(-11 * s, -58 * s + lurch * 0.5, 5 * s, 5 * s);
  ctx.fillStyle = "#1a1a1a";
  ctx.fillRect(-10 * s, -57 * s + lurch * 0.5, 2.5 * s, 2.5 * s);
  // mâchoire
  ctx.fillStyle = dark;
  ctx.fillRect(-14 * s, -49 * s + lurch * 0.5, 12 * s, 3 * s);
  // couronne du zombie doré
  if (z.adn) {
    ctx.fillStyle = "#fff27a";
    ctx.fillRect(-13 * s, -69 * s + lurch * 0.5, 16 * s, 4 * s);
  }
  ctx.restore();

  // barre de vie
  if (z.hp < z.maxHp) {
    const w = 44 * s;
    ctx.fillStyle = "rgba(0,0,0,0.6)";
    ctx.fillRect(x - w / 2, y - 74 * s, w, 6);
    ctx.fillStyle = z.boss ? "#c75bff" : "#6dd96d";
    ctx.fillRect(x - w / 2, y - 74 * s, w * Math.max(0, z.hp / z.maxHp), 6);
  }
}

function drawBullets() {
  for (const b of run.bullets) {
    ctx.fillStyle = b.crit ? "#ffd34d" : "#ffe9a8";
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

function drawWallHpBar() {
  const x = WALL_X - 100, y = GROUND_Y - 305, w = 130, h = 16;
  const ratio = run.wallHp / run.wallMax;
  ctx.fillStyle = "rgba(0,0,0,0.65)";
  ctx.fillRect(x - 2, y - 2, w + 4, h + 4);
  ctx.fillStyle = ratio > 0.5 ? "#5fd35f" : ratio > 0.25 ? "#e8c84a" : "#e85b4a";
  ctx.fillRect(x, y, w * Math.max(0, ratio), h);
  ctx.strokeStyle = "#fff";
  ctx.lineWidth = 2;
  ctx.strokeRect(x - 2, y - 2, w + 4, h + 4);
  ctx.font = "bold 12px Trebuchet MS";
  ctx.fillStyle = "#fff";
  ctx.textAlign = "center";
  ctx.fillText(`${Math.ceil(run.wallHp)} / ${run.wallMax}`, x + w / 2, y + 12);
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
newRun();
requestAnimationFrame(loop);
