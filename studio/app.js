/* =========================================================================
   ATELIER ROBLOX — logique de l'application
   Suivi de projets de maps Roblox par un studio virtuel de 50 agents IA.
   Données en localStorage. Consultation IA optionnelle via l'API Anthropic
   (clé fournie par l'utilisateur, appel direct depuis le navigateur).
   ========================================================================= */
"use strict";

/* ========================= ÉTAT & PERSISTANCE ========================= */

const STORE_KEY = "atelier_roblox_v1";

let state = load();

function defaultState() {
  return {
    projects: [],
    log: [],
    settings: { apiKey: "", model: "claude-opus-5" },
  };
}
function load() {
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (!raw) return defaultState();
    const s = Object.assign(defaultState(), JSON.parse(raw));
    s.settings = Object.assign(defaultState().settings, s.settings || {});
    return s;
  } catch (e) { return defaultState(); }
}
function save() {
  try { localStorage.setItem(STORE_KEY, JSON.stringify(state)); } catch (e) {}
}
function uid() { return Date.now().toString(36) + Math.random().toString(36).slice(2, 7); }

function logEvent(msg) {
  state.log.unshift({ t: Date.now(), msg });
  state.log = state.log.slice(0, 60);
  save();
}
function timeAgo(t) {
  const s = (Date.now() - t) / 1000;
  if (s < 60) return "à l'instant";
  if (s < 3600) return `il y a ${Math.floor(s / 60)} min`;
  if (s < 86400) return `il y a ${Math.floor(s / 3600)} h`;
  return `il y a ${Math.floor(s / 86400)} j`;
}

const agentById = Object.fromEntries(AGENTS.map(a => [a.id, a]));
const deptById = Object.fromEntries(DEPTS.map(d => [d.id, d]));

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
          `<div class="log-item">${e.msg} <span class="log-time">· ${timeAgo(e.t)}</span></div>`).join("")
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
      <span class="badge ${p.statut}">${{ actif: "Actif", pause: "En pause", termine: "Terminé" }[p.statut]}</span>
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
      <span class="badge ${p.statut}">${{ actif: "Actif", pause: "En pause", termine: "Terminé" }[p.statut]}</span>
      <span class="muted">${esc(p.type)}</span>
    </div>
    <p class="detail-desc">${esc(p.desc || "")}</p>
    <div class="btn-row">
      <button class="ghost-btn" id="btn-cycle-status">🔁 Changer le statut</button>
      <button class="primary-btn" id="btn-add-task">＋ Nouvelle tâche</button>
      <button class="danger-btn" id="btn-del-project">🗑️ Supprimer le projet</button>
    </div>
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
  d.querySelector("#btn-cycle-status").addEventListener("click", () => {
    p.statut = { actif: "pause", pause: "termine", termine: "actif" }[p.statut];
    logEvent(`Projet <b>${esc(p.nom)}</b> passé en « ${p.statut} »`);
    save(); openProject(id);
  });
  d.querySelector("#btn-del-project").addEventListener("click", () => {
    if (!confirm(`Supprimer définitivement le projet « ${p.nom} » ?`)) return;
    state.projects = state.projects.filter(x => x.id !== id);
    logEvent(`Projet <b>${esc(p.nom)}</b> supprimé`);
    save(); renderProjects();
  });
  d.querySelectorAll(".phase-item").forEach(el => el.addEventListener("click", () => {
    const i = +el.dataset.i;
    p.phases[i] = !p.phases[i];
    if (p.phases[i]) logEvent(`<b>${esc(p.nom)}</b> : phase « ${PHASES[i]} » validée ✅`);
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
      if (t.statut === "fini") logEvent(`<b>${esc(p.nom)}</b> : tâche « ${esc(t.titre)} » terminée ✅`);
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
    created: Date.now(),
  };
  state.projects.unshift(p);
  logEvent(`Nouveau projet créé : <b>${esc(nom)}</b> 🎉`);
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
  if (!titre || !taskProject) { toast("Donnez un titre à la tâche !"); return; }
  const agents = [...document.querySelectorAll("#t-agents .pick-agent.on")].map(e => e.dataset.aid);
  taskProject.tasks.push({
    id: uid(), titre, statut: "todo", agents,
    note: document.getElementById("t-note").value.trim(),
    created: Date.now(),
  });
  logEvent(`<b>${esc(taskProject.nom)}</b> : tâche « ${esc(titre)} » ajoutée` +
    (agents.length ? ` (${agents.map(a => agentById[a].nom.split(" ")[0]).join(", ")})` : ""));
  save();
  closeModals();
  openProject(taskProject.id);
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
let chatHistory = [];   // messages {role, content} de la conversation en cours

function agentSystemPrompt(a) {
  const d = deptById[a.dept];
  let ctx = "";
  const p = state.projects.find(x => x.id === currentProjectId);
  if (p) {
    ctx = `\n\nProjet en cours au studio : « ${p.nom} » (type : ${p.type}). ${p.desc || ""}` +
      `\nPhases validées : ${p.phases.map((v, i) => v ? PHASES[i] : null).filter(Boolean).join(", ") || "aucune"}.`;
  }
  return `Tu es ${a.nom}, ${a.role} au sein du département ${d.nom} d'un studio expert en création de maps et d'expériences Roblox. ` +
    `Tes spécialités : ${a.skills.join(", ")}. ${a.focus}` +
    `\nRéponds en français, de façon concrète et directement actionnable dans Roblox Studio ` +
    `(noms d'instances, services, propriétés et valeurs précises quand c'est pertinent). ` +
    `Reste dans ton domaine d'expertise ; si la question relève d'un autre département, dis-le et donne quand même une piste.` + ctx;
}

function openAgent(aid) {
  const a = agentById[aid];
  if (!a) return;
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
  document.getElementById("modal-agent").classList.remove("hidden");
}

async function sendChat() {
  const input = document.getElementById("chat-input");
  const question = input.value.trim();
  if (!question || !chatAgent) return;
  if (!state.settings.apiKey) { toast("Ajoutez d'abord une clé API dans les Réglages."); return; }
  input.value = "";
  const box = document.getElementById("chat-messages");
  box.insertAdjacentHTML("beforeend", `<div class="msg user">${esc(question)}</div>`);
  const wait = document.createElement("div");
  wait.className = "msg agent wait";
  wait.textContent = `${chatAgent.emoji} ${chatAgent.nom.split(" ")[0]} réfléchit…`;
  box.appendChild(wait);
  box.scrollTop = box.scrollHeight;
  const sendBtn = document.getElementById("btn-chat-send");
  sendBtn.disabled = true;

  chatHistory.push({ role: "user", content: question });
  try {
    const res = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": state.settings.apiKey,
        "anthropic-version": "2023-06-01",
        "anthropic-dangerous-direct-browser-access": "true",
      },
      body: JSON.stringify({
        model: state.settings.model,
        max_tokens: 4096,
        system: agentSystemPrompt(chatAgent),
        messages: chatHistory,
      }),
    });
    const data = await res.json();
    if (!res.ok) {
      const msg = data && data.error && data.error.message ? data.error.message : `Erreur HTTP ${res.status}`;
      throw new Error(msg);
    }
    let text;
    if (data.stop_reason === "refusal") {
      text = "Je préfère ne pas répondre à cette demande. Reformulez-la ou posez une autre question sur votre map !";
    } else {
      text = (data.content || []).filter(b => b.type === "text").map(b => b.text).join("\n").trim()
        || "(réponse vide)";
    }
    chatHistory.push({ role: "assistant", content: text });
    wait.classList.remove("wait");
    wait.textContent = "";
    wait.insertAdjacentText("beforeend", `${chatAgent.emoji} ${text}`);
  } catch (e) {
    chatHistory.pop();  // la question n'a pas abouti, on la retire de l'historique
    wait.classList.remove("wait");
    wait.textContent = `⚠️ Erreur : ${e.message}. Vérifiez la clé API dans les Réglages.`;
  }
  sendBtn.disabled = false;
  box.scrollTop = box.scrollHeight;
}
document.getElementById("btn-chat-send").addEventListener("click", sendChat);
document.getElementById("chat-input").addEventListener("keydown", e => {
  if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendChat(); }
});

/* ========================= RÉGLAGES ========================= */

function renderSettings() {
  document.getElementById("set-apikey").value = state.settings.apiKey;
  document.getElementById("set-model").value = state.settings.model;
}
document.getElementById("btn-save-settings").addEventListener("click", () => {
  state.settings.apiKey = document.getElementById("set-apikey").value.trim();
  state.settings.model = document.getElementById("set-model").value;
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
  const blob = new Blob([JSON.stringify(state, null, 2)], { type: "application/json" });
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
      if (!Array.isArray(s.projects)) throw new Error("format invalide");
      state = Object.assign(defaultState(), s);
      save();
      toast("Sauvegarde importée ✅");
      showView("dash");
      refreshApiStatus();
    } catch (err) { toast("Fichier invalide : " + err.message); }
  };
  r.readAsText(f);
  e.target.value = "";
});
document.getElementById("btn-wipe").addEventListener("click", () => {
  if (!confirm("Effacer TOUTES les données du studio (projets, tâches, réglages) ?")) return;
  localStorage.removeItem(STORE_KEY);
  state = defaultState();
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
  document.querySelectorAll(".overlay").forEach(o => o.classList.add("hidden"));
}
document.querySelectorAll(".modal-close").forEach(b => b.addEventListener("click", closeModals));
document.querySelectorAll(".overlay").forEach(o =>
  o.addEventListener("click", e => { if (e.target === o) closeModals(); }));

/* ========================= DÉMARRAGE ========================= */

refreshApiStatus();
showView("dash");
if (!state.log.length) logEvent("Le studio <b>Atelier Roblox</b> est ouvert : 50 agents prêts à travailler 🏗️");
