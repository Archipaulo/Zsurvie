/* =========================================================================
   ATELIER ROBLOX — logique de l'application
   Suivi de projets de maps Roblox par un studio virtuel de 50 agents IA.
   Données en localStorage. Consultation IA optionnelle via l'API Anthropic
   (clé fournie par l'utilisateur, appel direct depuis le navigateur).
   ========================================================================= */
"use strict";

/* ========================= ÉTAT & PERSISTANCE ========================= */

const STORE_KEY = "atelier_roblox_v1";
const VERROU_KEY = "atelier_roblox_verrou";
const MODELES = ["claude-opus-5", "claude-sonnet-5", "claude-haiku-4-5"];
const STATUTS_PROJET = ["actif", "pause", "termine"];
const STATUTS_TACHE = ["todo", "encours", "revision", "fini"];
const STATUTS_PROD = ["prete", "en_cours", "termine", "incomplet", "interrompu"];
const ID_SUR = /^[A-Za-z0-9_-]{1,40}$/;
const idSur = v => typeof v === "string" && ID_SUR.test(v);

const agentById = Object.fromEntries(AGENTS.map(a => [a.id, a]));
const deptById = Object.fromEntries(DEPTS.map(d => [d.id, d]));

function defaultState() {
  return {
    projects: [],
    log: [],
    settings: { apiKey: "", model: "claude-opus-5", parallele: 3 },
  };
}
function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2, 7); }

/* ------- validation : tout ce qui vient du stockage ou d'un fichier importé ------- */
const texte = (v, defaut = "") => typeof v === "string" ? v : defaut;
const texteOuNull = v => typeof v === "string" && v ? v : null;
const liste = v => Array.isArray(v) ? v : [];
const objetSimple = v => !!v && typeof v === "object" && !Array.isArray(v);
const entier = (v, min, max, defaut) => Number.isInteger(v) && v >= min && v <= max ? v : defaut;

function normaliser(brut) {
  const src = objetSimple(brut) ? brut : {};
  const s = defaultState();
  const r = objetSimple(src.settings) ? src.settings : {};
  s.settings.apiKey = texte(r.apiKey).trim();
  s.settings.model = MODELES.includes(r.model) ? r.model : s.settings.model;
  s.settings.parallele = [1, 2, 3, 4, 6, 8].includes(Number(r.parallele)) ? Number(r.parallele) : 3;
  s.log = liste(src.log).filter(e => objetSimple(e) && typeof e.msg === "string")
    .map(e => ({ t: Number(e.t) || 0, msg: e.v === 2 ? e.msg : decoderEntites(e.msg), v: 2 })).slice(0, 60);
  s.projects = liste(src.projects).filter(objetSimple).map((p, i) => normaliserProjet(p, i));
  return s;
}
/* un identifiant absent ou invalide est remplacé par un identifiant dérivé de la position :
   tous les onglets qui chargent les mêmes données obtiennent le même */
let idsRegeneres = false;
function idOu(v, deduit) {
  if (idSur(v)) return v;
  idsRegeneres = true;
  return deduit;
}
function normaliserProjet(p, i = 0) {
  const pid = idOu(p.id, `r-p${i}`);
  return {
    id: pid,
    nom: texte(p.nom, "Projet sans nom"),
    type: texte(p.type, "Autre"),
    desc: texte(p.desc),
    statut: STATUTS_PROJET.includes(p.statut) ? p.statut : "actif",
    phases: PHASES.map((_, i) => !!liste(p.phases)[i]),
    tasks: liste(p.tasks).filter(objetSimple).map((t, j) => ({
      id: idOu(t.id, `${pid}-t${j}`),
      titre: texte(t.titre, "Tâche"),
      statut: STATUTS_TACHE.includes(t.statut) ? t.statut : "todo",
      agents: liste(t.agents).filter(estAgentId),
      note: texte(t.note),
      created: Number(t.created) || 0,
    })),
    productions: liste(p.productions).map((pr, k) => normaliserProduction(pr, `${pid}-r${k}`)).filter(Boolean),
    created: Number(p.created) || 0,
  };
}
/* renvoie null si l'objet n'est pas une production exploitable */
function normaliserProduction(pr, idDeduit) {
  if (!objetSimple(pr) || !objetSimple(pr.vision) || !objetSimple(pr.contributions)) return null;
  const id = idOu(pr.id, idDeduit || uid());
  const parAgent = (obj, fn) => Object.fromEntries(Object.entries(objetSimple(obj) ? obj : {})
    .filter(([id, x]) => estAgentId(id) && objetSimple(x)).map(([id, x]) => [id, fn(x)]));
  const cles = obj => Object.keys(objetSimple(obj) ? obj : {});
  const v = pr.vision;
  const usages = {};
  for (const [m, u] of Object.entries(objetSimple(pr.usages) ? pr.usages : {})) {
    if (MODELES.includes(m) && objetSimple(u)) usages[m] = { entree: Number(u.entree) || 0, sortie: Number(u.sortie) || 0 };
  }
  // anciennes productions : un seul compteur, rattaché au modèle de lancement
  if (objetSimple(pr.usage) && MODELES.includes(pr.modele) && !usages[pr.modele]) {
    usages[pr.modele] = { entree: Number(pr.usage.entree) || 0, sortie: Number(pr.usage.sortie) || 0 };
  }
  let statut = STATUTS_PROD.includes(pr.statut) ? pr.statut : "incomplet";
  // « en cours » sans onglet vivant pour la faire tourner = coupée en route
  if (statut === "en_cours" && !verrouFrais(id)) statut = "interrompu";
  return {
    id,
    source: pr.source === "claude-code" ? "claude-code" : "app",
    brief: texte(pr.brief),
    modele: MODELES.includes(pr.modele) ? pr.modele : null,
    cree: Number(pr.cree) || Date.now(),
    statut,
    vision: { benchmark: texteOuNull(v.benchmark), da: texteOuNull(v.da), canon: texteOuNull(v.canon),
      titre: texteOuNull(v.titre), pitch: texteOuNull(v.pitch) },
    contributions: parAgent(pr.contributions, c => ({
      livrable: texte(c.livrable),
      decisions: liste(c.decisions).filter(d => typeof d === "string"),
      besoins: liste(c.besoins).filter(objetSimple).map(b => ({ de: texte(b.de), besoin: texte(b.besoin) })),
      taches: liste(c.taches).filter(objetSimple).map(t => ({
        titre: texte(t.titre), phase: entier(t.phase, 0, PHASES.length - 1, 0), charge: texte(t.charge, "M") })),
      revise: !!c.revise,
    })),
    qa: parAgent(pr.qa, r => ({
      rapport: texte(r.rapport),
      problemes: liste(r.problemes).filter(objetSimple).map(x => ({
        gravite: ["bloquant", "majeur", "mineur"].includes(x.gravite) ? x.gravite : "mineur",
        agent: texte(x.agent), probleme: texte(x.probleme), correction: texte(x.correction) })),
    })),
    coordination: objetSimple(pr.coordination) ? {
      synthese: texte(pr.coordination.synthese),
      conflits: liste(pr.coordination.conflits).filter(objetSimple).map(c => ({
        sujet: texte(c.sujet), agents: liste(c.agents).filter(a => typeof a === "string"), arbitrage: texte(c.arbitrage) })),
      revisions: liste(pr.coordination.revisions).filter(objetSimple).map(r => ({
        agent: texte(r.agent), consignes: texte(r.consignes) })),
    } : null,
    revisionsFaites: Object.fromEntries(cles(pr.revisionsFaites).filter(estAgentId).map(id => [id, true])),
    plan: objetSimple(pr.plan) ? {
      plan: texte(pr.plan.plan),
      taches: liste(pr.plan.taches).filter(objetSimple).map(t => ({
        titre: texte(t.titre), phase: entier(t.phase, 0, PHASES.length - 1, 0),
        agents: liste(t.agents).filter(estAgentId), note: texte(t.note) })).filter(t => t.titre),
    } : null,
    bible: objetSimple(pr.bible) ? { titre: texte(pr.bible.titre), pitch: texte(pr.bible.pitch), bible: texte(pr.bible.bible) } : null,
    scripts: Object.fromEntries(Object.entries(objetSimple(pr.scripts) ? pr.scripts : {}).filter(([, c]) => typeof c === "string")),
    echecs: Object.fromEntries(Object.entries(objetSimple(pr.echecs) ? pr.echecs : {}).map(([k, m]) => [k, texte(m, "échec")])),
    ignores: Object.fromEntries(cles(pr.ignores).map(k => [k, true])),
    usages,
    tachesImportees: !!pr.tachesImportees,
  };
}

/* ------- verrou entre onglets : un seul onglet fait tourner une production -------
   Le battement est renouvelé par le travail réseau de la production (que le
   navigateur ne bride pas dans un onglet en arrière-plan) et par un minuteur ;
   il reste valable 3 minutes et il est levé à la fermeture de l'onglet.
   L'exclusivité stricte au lancement passe par navigator.locks quand il existe. */
const FRAICHEUR_VERROU = 180000;
const ONGLET_ID = uid();
let dernierBattement = 0;
function lireVerrou() {
  try {
    const v = JSON.parse(localStorage.getItem(VERROU_KEY) || "null");
    return objetSimple(v) ? v : null;
  } catch (e) { return null; }
}
function ageVerrou() {
  const v = lireVerrou();
  return v ? Date.now() - (Number(v.t) || 0) : Infinity;
}
function verrouFrais(prodId) {
  const v = lireVerrou();
  return !!v && ageVerrou() < FRAICHEUR_VERROU && (!prodId || v.prodId === prodId);
}
function verrouAutreOnglet() {
  const v = lireVerrou();
  return verrouFrais() && v.onglet !== ONGLET_ID ? v : null;
}
function poserVerrou(prodId) {
  dernierBattement = Date.now();
  try { localStorage.setItem(VERROU_KEY, JSON.stringify({ onglet: ONGLET_ID, prodId, t: dernierBattement })); } catch (e) {}
}
function battement(prodId) {
  if (Date.now() - dernierBattement > 5000) poserVerrou(prodId);
}
function leverVerrou() {
  const v = lireVerrou();
  if (v && v.onglet === ONGLET_ID) try { localStorage.removeItem(VERROU_KEY); } catch (e) {}
}
/* une production de ce projet tourne-t-elle dans un autre onglet ? */
function projetOccupeAilleurs(p) {
  const v = verrouAutreOnglet();
  return !!v && (p.productions || []).some(pr => pr.id === v.prodId);
}

function load() {
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (!raw) return defaultState();
    return normaliser(JSON.parse(raw));
  } catch (e) { return defaultState(); }
}
let state = load();
// identifiants réparés : on les enregistre tout de suite pour que tous les onglets les partagent
if (idsRegeneres) { idsRegeneres = false; save(); }

function productionActive() {
  return typeof run !== "undefined" && run && run.actif;
}
let alerteStockage = false;
function save() {
  try {
    localStorage.setItem(STORE_KEY, JSON.stringify(state));
    alerteStockage = false;
    if (typeof run !== "undefined" && run && !run.actif && run.nonSauve) {
      run.nonSauve = false;
      const t = trouverProduction(run.prodId);
      if (t && /^Stockage du navigateur plein/.test(t.prod.erreur || "")) delete t.prod.erreur;
    }
    return true;
  } catch (e) {
    if (!alerteStockage) {
      alerteStockage = true;
      toast("⚠️ Stockage du navigateur plein : exportez vos données puis supprimez d'anciennes productions.");
    }
    return false;
  }
}

/* le journal contient du texte brut ; seul le gras <b>…</b> est interprété */
/* les anciennes entrées du journal étaient stockées déjà échappées */
function decoderEntites(s) {
  return s.replace(/&(amp|lt|gt|quot|#39);/g, (_, e) => ({ amp: "&", lt: "<", gt: ">", quot: '"', "#39": "'" }[e]));
}
function logEvent(msg) {
  state.log.unshift({ t: Date.now(), msg, v: 2 });
  state.log = state.log.slice(0, 60);
  save();
}
function logHtml(msg) {
  return esc(msg).replace(/&lt;(\/?)b&gt;/g, "<$1b>");
}
function timeAgo(t) {
  const s = (Date.now() - t) / 1000;
  if (s < 60) return "à l'instant";
  if (s < 3600) return `il y a ${Math.floor(s / 60)} min`;
  if (s < 86400) return `il y a ${Math.floor(s / 3600)} h`;
  return `il y a ${Math.floor(s / 86400)} j`;
}

function projectProgress(p) {
  const phases = p.phases.filter(Boolean).length / PHASES.length;
  const tasks = p.tasks.length ? p.tasks.filter(t => t.statut === "fini").length / p.tasks.length : 0;
  return Math.round(((phases + tasks) / (p.tasks.length ? 2 : 1)) * 100);
}
function agentTasks(agentId) {
  const out = [];
  for (const p of state.projects)
    for (const t of p.tasks)
      if (t.agents.includes(agentId) && t.statut !== "fini") out.push({ p, t });
  return out;
}

/* ------- un autre onglet a modifié les données : on suit ------- */
const lireJson = v => { try { return JSON.parse(v || "null"); } catch (e) { return null; } };
window.addEventListener("storage", e => {
  if (e.key === VERROU_KEY) {
    // un simple renouvellement (même onglet, même production) ne change rien à l'affichage
    const avant = lireJson(e.oldValue), apres = lireJson(e.newValue);
    const cle = v => v ? `${v.onglet}|${v.prodId}` : "";
    if (cle(avant) !== cle(apres)) planifierRafraichissement();
    return;
  }
  if (e.key !== null && e.key !== STORE_KEY) return;
  let autre;
  if (e.key === null || e.newValue === null) autre = defaultState();   // effacement fait ailleurs
  else {
    try { autre = normaliser(JSON.parse(e.newValue)); } catch (err) { return; }
  }
  // la production de cet onglet (en cours, ou pas encore enregistrée) fait foi
  const vivant = run && (run.actif || run.nonSauve) ? trouverProduction(run.prodId) : null;
  if (vivant) {
    const projet = autre.projects.find(p => p.id === vivant.projet.id);
    if (!projet) autre.projects.unshift(vivant.projet);
    else {
      const i = projet.productions.findIndex(x => x.id === run.prodId);
      if (i < 0) projet.productions.unshift(vivant.prod);
      else {
        if (projet.productions[i].tachesImportees) vivant.prod.tachesImportees = true;
        projet.productions[i] = vivant.prod;
      }
    }
  }
  state = autre;
  if (vivant && run.nonSauve && save()) toast("De la place s'est libérée : la production est enregistrée ✅");
  // immédiat : aucun bouton ne doit rester branché sur les anciens objets
  rafraichirVue();
});
let rafraichissementPlanifie = null;
function planifierRafraichissement() {
  clearTimeout(rafraichissementPlanifie);
  rafraichissementPlanifie = setTimeout(rafraichirVue, 250);
}
function rafraichirVue() {
  refreshApiStatus();
  if (currentView === "reglages") return;   // ne pas écraser une saisie en cours
  const detail = document.getElementById("projet-detail");
  if (currentView === "projets" && currentProjectId && !detail.classList.contains("hidden")) openProject(currentProjectId);
  else showView(currentView);
}

/* ========================= NAVIGATION ========================= */

let currentView = "dash";
let currentProjectId = null;

document.querySelectorAll(".nav-btn").forEach(btn => {
  btn.addEventListener("click", () => showView(btn.dataset.view));
});
function showView(view) {
  currentView = view;
  document.querySelectorAll(".nav-btn").forEach(b =>
    b.classList.toggle("active", b.dataset.view === view));
  document.querySelectorAll(".view").forEach(v => v.classList.add("hidden"));
  document.getElementById("view-" + view).classList.remove("hidden");
  if (view === "dash") renderDash();
  if (view === "projets") renderProjects();
  if (view === "equipe") renderTeam();
  if (view === "production") rendreProduction();
  if (view === "reglages") renderSettings();
}

/* ========================= TABLEAU DE BORD ========================= */

function renderDash() {
  const actifs = state.projects.filter(p => p.statut === "actif");
  const allTasks = state.projects.flatMap(p => p.tasks);
  const busy = new Set(allTasks.filter(t => t.statut !== "fini").flatMap(t => t.agents));
  const kpis = [
    { n: state.projects.length, l: "Projets au total" },
    { n: actifs.length, l: "Projets actifs" },
    { n: allTasks.filter(t => t.statut === "encours").length, l: "Tâches en cours" },
    { n: allTasks.filter(t => t.statut === "fini").length, l: "Tâches terminées" },
    { n: `${busy.size}/50`, l: "Agents mobilisés" },
  ];
  document.getElementById("kpis").innerHTML = kpis.map(k =>
    `<div class="kpi"><div class="kpi-num">${k.n}</div><div class="kpi-label">${k.l}</div></div>`).join("");

  const wrap = document.getElementById("dash-projects");
  wrap.innerHTML = state.projects.length ? "" :
    `<p class="muted">Aucun projet pour l'instant. Créez votre première map avec « ＋ Nouveau projet » !</p>`;
  for (const p of state.projects.slice(0, 6)) wrap.appendChild(projectCard(p));

  document.getElementById("dash-log").innerHTML =
    state.log.length
      ? state.log.slice(0, 12).map(e =>
          `<div class="log-item">${logHtml(e.msg)} <span class="log-time">· ${timeAgo(e.t)}</span></div>`).join("")
      : `<p class="muted">L'activité du studio apparaîtra ici.</p>`;
}

/* ========================= PROJETS ========================= */

function projectCard(p) {
  const el = document.createElement("div");
  el.className = "project-card";
  const prog = projectProgress(p);
  el.innerHTML = `
    <div class="pc-top">
      <div><div class="pc-nom">${esc(p.nom)}</div><div class="pc-type">${esc(p.type)}</div></div>
      <span class="badge ${esc(p.statut)}">${{ actif: "Actif", pause: "En pause", termine: "Terminé" }[p.statut] || ""}</span>
    </div>
    <div class="progress"><div style="width:${prog}%"></div></div>
    <div class="pc-meta"><span>${p.tasks.length} tâche${p.tasks.length > 1 ? "s" : ""}</span><span>${prog} %</span></div>`;
  el.addEventListener("click", () => openProject(p.id));
  return el;
}

function renderProjects() {
  document.getElementById("projet-detail").classList.add("hidden");
  document.getElementById("projets-list-wrap").classList.remove("hidden");
  const grid = document.getElementById("projects-grid");
  grid.innerHTML = state.projects.length ? "" :
    `<p class="muted">Aucun projet. Lancez la production avec « ＋ Nouveau projet » !</p>`;
  for (const p of state.projects) grid.appendChild(projectCard(p));
}

function openProject(id) {
  currentProjectId = id;
  showView("projets");
  const p = state.projects.find(x => x.id === id);
  if (!p) return;
  document.getElementById("projets-list-wrap").classList.add("hidden");
  const d = document.getElementById("projet-detail");
  d.classList.remove("hidden");

  const KB_COLS = [
    ["todo", "📋 À faire"], ["encours", "🔨 En cours"],
    ["revision", "🔍 Révision"], ["fini", "✅ Terminé"],
  ];
  d.innerHTML = `
    <button class="ghost-btn" id="btn-back">← Tous les projets</button>
    <div class="detail-head" style="margin-top:14px">
      <h1>${esc(p.nom)}</h1>
      <span class="badge ${esc(p.statut)}">${{ actif: "Actif", pause: "En pause", termine: "Terminé" }[p.statut] || ""}</span>
      <span class="muted">${esc(p.type)}</span>
    </div>
    <p class="detail-desc">${esc(p.desc || "")}</p>
    <div class="btn-row">
      <button class="ghost-btn" id="btn-cycle-status">🔁 Changer le statut</button>
      <button class="primary-btn" id="btn-add-task">＋ Nouvelle tâche</button>
      <button class="danger-btn" id="btn-del-project">🗑️ Supprimer le projet</button>
    </div>
    ${htmlProductionsProjet(p)}
    <h2>Pipeline de production</h2>
    <div class="phase-list">${PHASES.map((ph, i) => `
      <div class="phase-item ${p.phases[i] ? "done" : ""}" data-i="${i}">
        <span class="ph-check">${p.phases[i] ? "✅" : "⬜"}</span> ${i + 1}. ${ph}
      </div>`).join("")}
    </div>
    <h2>Tableau des tâches</h2>
    <div class="kanban">${KB_COLS.map(([st, label]) => `
      <div class="kb-col" data-st="${st}">
        <h3>${label} <span class="kb-count">${p.tasks.filter(t => t.statut === st).length}</span></h3>
        <div class="kb-body"></div>
      </div>`).join("")}
    </div>`;

  d.querySelector("#btn-back").addEventListener("click", renderProjects);
  d.querySelector("#btn-add-task").addEventListener("click", () => openTaskModal(p));
  brancherProductionsProjet(d, p);
  d.querySelector("#btn-cycle-status").addEventListener("click", () => {
    p.statut = { actif: "pause", pause: "termine", termine: "actif" }[p.statut];
    logEvent(`Projet <b>${p.nom}</b> passé en « ${p.statut} »`);
    save(); openProject(id);
  });
  d.querySelector("#btn-del-project").addEventListener("click", () => {
    if ((productionActive() && (p.productions || []).some(pr => pr.id === run.prodId)) || projetOccupeAilleurs(p)) {
      toast("Une production de ce projet est en cours : interrompez-la d'abord.");
      return;
    }
    if (!confirm(`Supprimer définitivement le projet « ${p.nom} » ?`)) return;
    state.projects = state.projects.filter(x => x.id !== id);
    logEvent(`Projet <b>${p.nom}</b> supprimé`);
    save(); renderProjects();
  });
  d.querySelectorAll(".phase-item").forEach(el => el.addEventListener("click", () => {
    const i = +el.dataset.i;
    p.phases[i] = !p.phases[i];
    if (p.phases[i]) logEvent(`<b>${p.nom}</b> : phase « ${PHASES[i]} » validée ✅`);
    save(); openProject(id);
  }));

  // cartes de tâches
  const ORDER = ["todo", "encours", "revision", "fini"];
  for (const t of p.tasks) {
    const col = d.querySelector(`.kb-col[data-st="${t.statut}"] .kb-body`);
    const card = document.createElement("div");
    card.className = "task-card";
    const idx = ORDER.indexOf(t.statut);
    card.innerHTML = `
      <div class="tc-title">${esc(t.titre)}</div>
      <div class="tc-agents">${t.agents.map(aid => {
        const a = agentById[aid];
        return a ? `<span class="mini-agent" data-aid="${aid}">${a.emoji} ${esc(a.nom.split(" ")[0])}</span>` : "";
      }).join("")}</div>
      ${t.note ? `<div class="tc-note">${esc(t.note)}</div>` : ""}
      <div class="tc-actions">
        ${idx > 0 ? `<button class="tc-btn" data-mv="-1">←</button>` : ""}
        ${idx < 3 ? `<button class="tc-btn" data-mv="1">→</button>` : ""}
        <button class="tc-btn" data-del="1">✕</button>
      </div>`;
    card.querySelectorAll("[data-mv]").forEach(b => b.addEventListener("click", () => {
      t.statut = ORDER[idx + (+b.dataset.mv)];
      if (t.statut === "fini") logEvent(`<b>${p.nom}</b> : tâche « ${t.titre} » terminée ✅`);
      save(); openProject(id);
    }));
    card.querySelector("[data-del]").addEventListener("click", () => {
      if (!confirm(`Supprimer la tâche « ${t.titre} » ?`)) return;
      p.tasks = p.tasks.filter(x => x.id !== t.id);
      save(); openProject(id);
    });
    card.querySelectorAll(".mini-agent").forEach(el =>
      el.addEventListener("click", () => openAgent(el.dataset.aid)));
    col.appendChild(card);
  }
}

/* ------- modale nouveau projet ------- */
const typeSel = document.getElementById("p-type");
typeSel.innerHTML = PROJECT_TYPES.map(t => `<option>${t}</option>`).join("");

document.getElementById("btn-new-project").addEventListener("click", () => {
  document.getElementById("p-nom").value = "";
  document.getElementById("p-desc").value = "";
  document.getElementById("modal-project").classList.remove("hidden");
  document.getElementById("p-nom").focus();
});
document.getElementById("btn-project-save").addEventListener("click", () => {
  const nom = document.getElementById("p-nom").value.trim();
  if (!nom) { toast("Donnez un nom au projet !"); return; }
  const p = {
    id: uid(), nom,
    type: typeSel.value,
    desc: document.getElementById("p-desc").value.trim(),
    statut: "actif",
    phases: PHASES.map(() => false),
    tasks: [],
    productions: [],
    created: Date.now(),
  };
  state.projects.unshift(p);
  logEvent(`Nouveau projet créé : <b>${nom}</b> 🎉`);
  save();
  closeModals();
  openProject(p.id);
});

/* ------- modale nouvelle tâche ------- */
let taskProject = null;
const tDept = document.getElementById("t-dept");
tDept.innerHTML = DEPTS.map(d => `<option value="${d.id}">${d.emoji} ${d.nom}</option>`).join("");
tDept.addEventListener("change", renderTaskAgentPicker);

function openTaskModal(p) {
  taskProject = p;
  document.getElementById("t-titre").value = "";
  document.getElementById("t-note").value = "";
  renderTaskAgentPicker();
  document.getElementById("modal-task").classList.remove("hidden");
  document.getElementById("t-titre").focus();
}
function renderTaskAgentPicker() {
  const wrap = document.getElementById("t-agents");
  wrap.innerHTML = "";
  for (const a of AGENTS.filter(a => a.dept === tDept.value)) {
    const el = document.createElement("span");
    el.className = "pick-agent";
    el.textContent = `${a.emoji} ${a.nom} — ${a.role}`;
    el.dataset.aid = a.id;
    el.addEventListener("click", () => el.classList.toggle("on"));
    wrap.appendChild(el);
  }
}
document.getElementById("btn-task-save").addEventListener("click", () => {
  const titre = document.getElementById("t-titre").value.trim();
  const projet = taskProject && state.projects.find(x => x.id === taskProject.id);
  if (!projet) { toast("Ce projet n'existe plus."); closeModals(); return; }
  if (!titre) { toast("Donnez un titre à la tâche !"); return; }
  const agents = [...document.querySelectorAll("#t-agents .pick-agent.on")].map(e => e.dataset.aid);
  projet.tasks.push({
    id: uid(), titre, statut: "todo", agents,
    note: document.getElementById("t-note").value.trim(),
    created: Date.now(),
  });
  logEvent(`<b>${projet.nom}</b> : tâche « ${titre} » ajoutée` +
    (agents.length ? ` (${agents.map(a => agentById[a].nom.split(" ")[0]).join(", ")})` : ""));
  save();
  closeModals();
  openProject(projet.id);
});

/* ========================= ÉQUIPE ========================= */

function renderTeam() {
  const wrap = document.getElementById("team-wrap");
  wrap.innerHTML = "";
  for (const d of DEPTS) {
    const block = document.createElement("div");
    block.className = "dept-block";
    block.innerHTML = `
      <div class="dept-head" style="border-color:${d.color}">
        <span class="dept-emoji">${d.emoji}</span><h2>${d.nom}</h2>
      </div>
      <div class="agent-grid"></div>`;
    const grid = block.querySelector(".agent-grid");
    for (const a of AGENTS.filter(a => a.dept === d.id)) {
      const load = agentTasks(a.id).length;
      const card = document.createElement("div");
      card.className = "agent-card";
      card.style.borderLeftColor = d.color;
      card.innerHTML = `
        <div class="ac-top">
          <span class="ac-emoji">${a.emoji}</span>
          <div><div class="ac-nom">${esc(a.nom)}</div><div class="ac-role">${esc(a.role)}</div></div>
        </div>
        <div class="ac-load">${load ? `🔨 ${load} tâche${load > 1 ? "s" : ""} en cours` : "💤 Disponible"}</div>`;
      card.addEventListener("click", () => openAgent(a.id));
      grid.appendChild(card);
    }
    wrap.appendChild(block);
  }
}

/* ------- fiche agent + consultation ------- */
let chatAgent = null;
let chatHistory = [];   // messages {role, content} de la conversation ouverte
let chatCtrl = null;    // requête en cours : une seule question à la fois

function annulerChat() {
  if (chatCtrl) { chatCtrl.abort(); chatCtrl = null; }
}

function agentSystemPrompt(a) {
  let ctx = "";
  const p = state.projects.find(x => x.id === currentProjectId);
  if (p) {
    ctx = `\n\nProjet en cours au studio : « ${p.nom} » (type : ${p.type}). ${p.desc || ""}` +
      `\nPhases validées : ${p.phases.map((v, i) => v ? PHASES[i] : null).filter(Boolean).join(", ") || "aucune"}.`;
  }
  return personaPrompt(a) +
    `\nRéponds en français, de façon concrète et directement actionnable dans Roblox Studio ` +
    `(noms d'instances, services, propriétés et valeurs précises quand c'est pertinent). ` +
    `Reste dans ton domaine d'expertise ; si la question relève d'un autre département, dis-le et donne quand même une piste.` + ctx;
}

function openAgent(aid) {
  const a = agentById[aid];
  if (!a) return;
  annulerChat();
  chatAgent = a;
  chatHistory = [];
  const d = deptById[a.dept];
  document.getElementById("agent-head").innerHTML = `
    <div class="agent-profile">
      <span class="ap-emoji">${a.emoji}</span>
      <div>
        <h2>${esc(a.nom)}</h2>
        <div class="ap-role">${esc(a.role)} · ${d.emoji} ${d.nom}</div>
      </div>
    </div>`;
  const tasks = agentTasks(aid);
  document.getElementById("agent-body").innerHTML = `
    <div class="skill-tags">${a.skills.map(s => `<span class="skill-tag">${esc(s)}</span>`).join("")}</div>
    <div class="agent-focus">${esc(a.focus)}</div>
    ${tasks.length ? `<p class="muted" style="font-size:13px">🔨 En charge de : ${tasks.map(x =>
      `« ${esc(x.t.titre)} » (${esc(x.p.nom)})`).join(" · ")}</p>` : ""}
    <div class="btn-row" style="margin:10px 0 4px">
      <button class="ghost-btn" id="btn-copy-prompt">📋 Copier le prompt expert</button>
    </div>`;
  document.getElementById("agent-body").querySelector("#btn-copy-prompt")
    .addEventListener("click", () => {
      navigator.clipboard.writeText(agentSystemPrompt(a) + "\n\nMa question : ")
        .then(() => toast("Prompt copié ! Collez-le dans n'importe quel chat IA."))
        .catch(() => toast("Impossible de copier automatiquement."));
    });
  const chat = document.getElementById("agent-chat");
  chat.classList.remove("hidden");
  document.getElementById("chat-messages").innerHTML = state.settings.apiKey
    ? `<div class="msg agent">${a.emoji} Bonjour ! Je suis ${esc(a.nom.split(" ")[0])}, votre ${esc(a.role.toLowerCase())}. Comment puis-je aider sur vos maps ?</div>`
    : `<div class="msg agent">💡 Ajoutez votre clé API Anthropic dans les Réglages pour discuter directement avec moi ici — ou copiez mon prompt expert ci-dessus.</div>`;
  document.getElementById("chat-input").value = "";
  document.getElementById("btn-chat-send").disabled = false;
  document.getElementById("modal-agent").classList.remove("hidden");
}

/* un appel de discussion, avec nouvelles tentatives sur les erreurs passagères */
async function appelChat(agent, messages, signal) {
  const headers = {
    "content-type": "application/json",
    "x-api-key": state.settings.apiKey,
    "anthropic-version": "2023-06-01",
    "anthropic-dangerous-direct-browser-access": "true",
  };
  const body = { model: state.settings.model, max_tokens: 16000, system: agentSystemPrompt(agent), messages };
  if (body.model === "claude-opus-5") {
    headers["anthropic-beta"] = "server-side-fallback-2026-07-01";
    body.fallbacks = "default";
  }
  let derniere = null;
  for (let essai = 0; essai < 4; essai++) {
    if (essai) await pause(2000 * 2 ** (essai - 1), signal);
    let res;
    try {
      res = await fetch("https://api.anthropic.com/v1/messages", { method: "POST", headers, body: JSON.stringify(body), signal });
    } catch (e) {
      if (signal.aborted) throw e;
      derniere = new Error("connexion impossible à l'API");
      continue;
    }
    let data = null;
    try { data = await res.json(); } catch (e) { /* réponse non JSON (passerelle) */ }
    if (res.ok && data) return data;
    const msg = (data && data.error && data.error.message) || `erreur HTTP ${res.status}`;
    if (res.status === 429 || res.status === 529 || res.status >= 500) { derniere = new Error(msg); continue; }
    if (res.status === 401 || res.status === 403) throw new Error(`${msg} — vérifiez la clé API dans les Réglages`);
    throw new Error(msg);
  }
  throw derniere || new Error("échec après plusieurs tentatives");
}

async function sendChat() {
  if (chatCtrl) return;
  const input = document.getElementById("chat-input");
  const question = input.value.trim();
  if (!question || !chatAgent) return;
  if (!state.settings.apiKey) { toast("Ajoutez d'abord une clé API dans les Réglages."); return; }
  const agent = chatAgent, hist = chatHistory;
  const ctrl = new AbortController();
  chatCtrl = ctrl;
  input.value = "";
  const box = document.getElementById("chat-messages");
  box.insertAdjacentHTML("beforeend", `<div class="msg user">${esc(question)}</div>`);
  const wait = document.createElement("div");
  wait.className = "msg agent wait";
  wait.textContent = `${agent.emoji} ${agent.nom.split(" ")[0]} réfléchit…`;
  box.appendChild(wait);
  box.scrollTop = box.scrollHeight;
  const sendBtn = document.getElementById("btn-chat-send");
  sendBtn.disabled = true;

  const msgUser = { role: "user", content: question };
  hist.push(msgUser);
  const encoreOuverte = () => !ctrl.signal.aborted && hist === chatHistory;
  try {
    const data = await appelChat(agent, hist.slice(), ctrl.signal);
    if (!encoreOuverte()) return;
    const text = data.stop_reason === "refusal"
      ? "Je préfère ne pas répondre à cette demande. Reformulez-la ou posez une autre question sur votre map !"
      : (data.content || []).filter(b => b.type === "text").map(b => b.text).join("\n").trim() || "(réponse vide)";
    hist.push({ role: "assistant", content: text });
    wait.classList.remove("wait");
    wait.textContent = `${agent.emoji} ${text}`;
  } catch (e) {
    const i = hist.indexOf(msgUser);   // la question n'a pas abouti : on la retire, elle seule
    if (i >= 0) hist.splice(i, 1);
    if (!encoreOuverte()) return;
    wait.classList.remove("wait");
    wait.textContent = `⚠️ ${e.message}`;
  } finally {
    if (chatCtrl === ctrl) chatCtrl = null;
    if (hist === chatHistory) {
      sendBtn.disabled = false;
      box.scrollTop = box.scrollHeight;
    }
  }
}
document.getElementById("btn-chat-send").addEventListener("click", sendChat);
document.getElementById("chat-input").addEventListener("keydown", e => {
  if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendChat(); }
});

/* ========================= RÉGLAGES ========================= */

function renderSettings() {
  document.getElementById("set-apikey").value = state.settings.apiKey;
  document.getElementById("set-model").value = state.settings.model;
  document.getElementById("set-parallele").value = String(state.settings.parallele || 3);
}
document.getElementById("btn-save-settings").addEventListener("click", () => {
  state.settings.apiKey = document.getElementById("set-apikey").value.trim();
  state.settings.model = document.getElementById("set-model").value;
  state.settings.parallele = Number(document.getElementById("set-parallele").value) || 3;
  save();
  refreshApiStatus();
  toast("Réglages enregistrés ✅");
});
function refreshApiStatus() {
  const el = document.getElementById("api-status");
  const on = !!state.settings.apiKey;
  el.className = "api-status " + (on ? "on" : "off");
  el.textContent = on ? "🤖 IA connectée — agents consultables" : "🔌 IA non connectée";
}

document.getElementById("btn-export").addEventListener("click", () => {
  // la clé API ne quitte jamais ce navigateur
  const copie = Object.assign({}, state, { settings: Object.assign({}, state.settings, { apiKey: "" }) });
  const blob = new Blob([JSON.stringify(copie, null, 2)], { type: "application/json" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = "atelier-roblox-sauvegarde.json";
  a.click();
  URL.revokeObjectURL(a.href);
});
document.getElementById("btn-import").addEventListener("click", () =>
  document.getElementById("import-file").click());
document.getElementById("import-file").addEventListener("change", e => {
  const f = e.target.files[0];
  if (!f) return;
  const r = new FileReader();
  r.onload = () => {
    try {
      const s = JSON.parse(r.result);
      if (!s || !Array.isArray(s.projects)) throw new Error("format invalide");
      if (productionActive() || verrouAutreOnglet()) throw new Error("une production est en cours, interrompez-la d'abord");
      const ancien = state;
      state = normaliser(s);
      state.settings.apiKey = ancien.settings.apiKey;   // on garde la clé de ce navigateur, jamais celle du fichier
      if (!save()) {
        state = ancien;
        throw new Error("stockage du navigateur plein, rien n'a été modifié");
      }
      toast("Sauvegarde importée ✅");
      showView("dash");
      refreshApiStatus();
    } catch (err) { toast("Fichier invalide : " + err.message); }
  };
  r.readAsText(f);
  e.target.value = "";
});
document.getElementById("btn-wipe").addEventListener("click", () => {
  if (productionActive() || verrouAutreOnglet()) { toast("Une production est en cours : interrompez-la d'abord."); return; }
  if (!confirm("Effacer TOUTES les données du studio (projets, tâches, réglages) ?")) return;
  state = defaultState();
  save();
  showView("dash");
  refreshApiStatus();
  toast("Studio réinitialisé.");
});

/* ========================= OUTILS UI ========================= */

function esc(s) {
  return String(s).replace(/[&<>"']/g, c =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}
let toastTimer = null;
function toast(msg) {
  const el = document.getElementById("toast");
  el.textContent = msg;
  el.classList.remove("hidden");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.add("hidden"), 2600);
}
function closeModals() {
  annulerChat();
  document.querySelectorAll(".overlay").forEach(o => o.classList.add("hidden"));
}
document.querySelectorAll(".modal-close").forEach(b => b.addEventListener("click", closeModals));
document.querySelectorAll(".overlay").forEach(o =>
  o.addEventListener("click", e => { if (e.target === o) closeModals(); }));

/* ========================= DÉMARRAGE ========================= */

refreshApiStatus();
showView("dash");
if (!state.log.length) logEvent("Le studio <b>Atelier Roblox</b> est ouvert : 50 agents prêts à travailler 🏗️");
