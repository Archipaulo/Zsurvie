/* =========================================================================
   ATELIER ROBLOX — orchestrateur des productions complètes
   Un brief → les 50 agents travaillent ensemble via l'API Anthropic,
   directement depuis le navigateur (clé saisie dans les Réglages).
   Chaque résultat est sauvegardé dès qu'il arrive : une production
   interrompue reprend là où elle s'était arrêtée.
   Utilise les globales d'app.js (state, save, toast, esc…) et de
   production.js (TACHES, SCHEMAS, digest*…).
   ========================================================================= */
"use strict";

const API_URL = "https://api.anthropic.com/v1/messages";
const PRIX_MODELES = { "claude-opus-5": [5, 25], "claude-sonnet-5": [2, 10], "claude-haiku-4-5": [1, 5] };
const NB_APPELS_PREVUS = 3 + CREATEURS.length + RELECTEURS_QA.length + 1 + 2;

/* ========================= appels à l'API ========================= */

class ErreurFatale extends Error {}

function pause(ms, signal) {
  return new Promise((ok, ko) => {
    const t = setTimeout(ok, ms);
    if (signal) signal.addEventListener("abort", () => { clearTimeout(t); ko(new DOMException("Interrompu", "AbortError")); }, { once: true });
  });
}

/* lit un flux SSE de l'API Messages et reconstitue le texte final */
async function lireFlux(res, onProgres) {
  const lecteur = res.body.getReader();
  const dec = new TextDecoder();
  const r = { texte: "", stop: null, erreur: null, entree: 0, sortie: 0 };
  let tampon = "";
  const traiter = ev => {
    switch (ev.type) {
      case "message_start": {
        const u = (ev.message && ev.message.usage) || {};
        r.entree += (u.input_tokens || 0) + (u.cache_creation_input_tokens || 0) + (u.cache_read_input_tokens || 0);
        break;
      }
      case "content_block_start":
        // après un basculement vers le modèle de secours, le texte partiel précédent est caduc
        if (ev.content_block && ev.content_block.type === "fallback") r.texte = "";
        else if (ev.content_block && ev.content_block.type === "text" && ev.content_block.text) r.texte += ev.content_block.text;
        break;
      case "content_block_delta":
        if (ev.delta && ev.delta.type === "text_delta") {
          r.texte += ev.delta.text;
          if (onProgres) onProgres(r.texte.length);
        }
        break;
      case "message_delta":
        if (ev.delta && ev.delta.stop_reason) r.stop = ev.delta.stop_reason;
        if (ev.usage && ev.usage.output_tokens) r.sortie = ev.usage.output_tokens;
        break;
      case "error":
        r.erreur = ev.error || { type: "error", message: "erreur de flux" };
        break;
    }
  };
  for (;;) {
    const { done, value } = await lecteur.read();
    if (done) break;
    tampon += dec.decode(value, { stream: true }).replace(/\r\n/g, "\n");
    let i;
    while ((i = tampon.indexOf("\n\n")) >= 0) {
      const bloc = tampon.slice(0, i);
      tampon = tampon.slice(i + 2);
      const data = bloc.split("\n").filter(l => l.startsWith("data:")).map(l => l.slice(5).trim()).join("");
      if (!data) continue;
      try { traiter(JSON.parse(data)); } catch (e) { /* ligne incomplète ou ping : ignorée */ }
    }
  }
  return r;
}

/* un appel complet, avec nouvelles tentatives sur les erreurs passagères */
async function appelClaude({ system, user, schema, signal, onProgres, usage }) {
  const model = state.settings.model;
  const body = { model, max_tokens: 32000, stream: true, system, messages: [{ role: "user", content: user }] };
  if (schema) body.output_config = { format: { type: "json_schema", schema } };
  const headers = {
    "content-type": "application/json",
    "x-api-key": state.settings.apiKey,
    "anthropic-version": "2023-06-01",
    "anthropic-dangerous-direct-browser-access": "true",
  };
  if (model === "claude-opus-5") {
    headers["anthropic-beta"] = "server-side-fallback-2026-07-01";
    body.fallbacks = "default";
  }
  let derniere = null;
  for (let essai = 0; essai < 6; essai++) {
    if (essai) await pause(Math.min(60000, 3000 * 2 ** (essai - 1)), signal);
    let res;
    try {
      res = await fetch(API_URL, { method: "POST", headers, body: JSON.stringify(body), signal });
    } catch (e) {
      if (signal && signal.aborted) throw e;
      derniere = new Error("connexion impossible à l'API");
      continue;
    }
    if (!res.ok) {
      let msg = `erreur HTTP ${res.status}`;
      try { const d = await res.json(); if (d && d.error && d.error.message) msg = d.error.message; } catch (e) {}
      if (res.status === 429 || res.status === 529 || res.status >= 500) {
        derniere = new Error(msg);
        const attente = Number(res.headers.get("retry-after"));
        if (attente > 0) await pause(Math.min(attente, 90) * 1000, signal);
        continue;
      }
      // clé invalide, requête refusée… : inutile d'insister, toute la production s'arrête
      throw new ErreurFatale(msg);
    }
    let r;
    try {
      r = await lireFlux(res, onProgres);
    } catch (e) {
      if (signal && signal.aborted) throw e;
      derniere = new Error("flux interrompu");
      continue;
    }
    if (usage) { usage.entree += r.entree; usage.sortie += r.sortie; }
    if (r.erreur) { derniere = new Error(r.erreur.message || r.erreur.type); continue; }
    if (r.stop === "refusal") throw new Error("demande déclinée par le modèle");
    if (r.stop === "max_tokens") throw new Error("réponse trop longue (limite de jetons atteinte)");
    if (!r.stop) { derniere = new Error("réponse incomplète"); continue; }
    if (!schema) return r.texte.trim();
    try { return JSON.parse(r.texte); }
    catch (e) { derniere = new Error("réponse JSON illisible"); continue; }
  }
  throw derniere || new Error("échec après plusieurs tentatives");
}

/* ========================= la production ========================= */

let run = null;   // production en cours dans cet onglet

function nouvelleProduction(brief) {
  return {
    id: uid(), source: "app", brief,
    modele: state.settings.model, cree: Date.now(), statut: "prete",
    vision: { benchmark: null, da: null, canon: null, titre: null, pitch: null },
    contributions: {}, qa: {}, coordination: null, revisionsFaites: {},
    plan: null, bible: null, scripts: {}, echecs: {},
    usage: { entree: 0, sortie: 0 },
  };
}
function trouverProduction(prodId) {
  for (const p of state.projects)
    for (const pr of (p.productions || []))
      if (pr.id === prodId) return { projet: p, prod: pr };
  return null;
}
function coutProduction(prod) {
  if (!prod.usage) return null;
  const [pe, ps] = PRIX_MODELES[prod.modele] || PRIX_MODELES["claude-opus-5"];
  return (prod.usage.entree * pe + prod.usage.sortie * ps) / 1e6;
}
function estimationCout(model) {
  const [pe, ps] = PRIX_MODELES[model] || PRIX_MODELES["claude-opus-5"];
  return [(0.5e6 * pe + 0.25e6 * ps) / 1e6, (0.9e6 * pe + 0.45e6 * ps) / 1e6];
}

/* révisions demandées par la coordination, fusionnées par agent */
function revisionsDemandees(prod) {
  const out = {};
  if (!prod.coordination) return out;
  for (const r of prod.coordination.revisions || []) {
    if (!prod.contributions[r.agent]) continue;
    out[r.agent] = out[r.agent] ? `${out[r.agent]}\n${r.consignes}` : r.consignes;
  }
  return out;
}
function problemesDe(prod, id) {
  return Object.values(prod.qa).flatMap(r => r.problemes || [])
    .filter(p => p.agent === id)
    .map(p => `- [${p.gravite}] ${p.probleme} → ${p.correction}`).join("\n");
}
function dossierQA(prod, id) {
  const lus = AGENTS.filter(x => FOCUS_QA[id].includes(x.dept) && prod.contributions[x.id]);
  const parts = lus.map(x => `## ${x.id} — ${x.role} (${x.nom})\n${prod.contributions[x.id].livrable}`);
  parts.push(`## Les décisions de tout le studio\n${digestDecisions(prod.contributions)}`);
  return parts.join("\n\n");
}
function arbitragesTexte(prod) {
  if (!prod.coordination) return "";
  return (prod.coordination.conflits || [])
    .map(c => `- ${c.sujet} (${(c.agents || []).join(", ")}) → ${c.arbitrage}`).join("\n");
}

async function lancerProduction(prodId) {
  const trouve = trouverProduction(prodId);
  if (!trouve) return;
  if (run && run.actif) { toast("Une production est déjà en cours dans cet onglet."); return; }
  if (!state.settings.apiKey) { toast("Ajoutez d'abord votre clé API dans les Réglages."); return; }
  const { projet, prod } = trouve;
  run = { prodId, actif: true, ctrl: new AbortController(), statuts: {}, progres: {}, journal: [] };
  const signal = run.ctrl.signal;
  prod.modele = state.settings.model;
  prod.statut = "en_cours";
  prod.echecs = {};
  delete prod.erreur;
  if (!prod.usage) prod.usage = { entree: 0, sortie: 0 };
  save();
  noter(`🚀 Production lancée avec ${nomModele(prod.modele)}`);
  const parallele = Math.max(1, Math.min(8, Number(state.settings.parallele) || 3));
  const A = id => agentById[id];

  const appel = (cle, a, tache, schema) => appelClaude({
    system: `${personaPrompt(a)}\n\n${REGLES_STUDIO}`,
    user: tache, schema, signal, usage: prod.usage,
    onProgres: n => { run.progres[cle] = n; planifierRendu(); },
  });

  async function unite(cle, travail) {
    if (signal.aborted) return;
    run.statuts[cle] = "travail";
    planifierRendu();
    try {
      await travail();
      run.statuts[cle] = "fini";
      delete prod.echecs[cle];
    } catch (e) {
      if (signal.aborted) { run.statuts[cle] = "attente"; return; }
      run.statuts[cle] = "echec";
      prod.echecs[cle] = e.message;
      const [, id] = cle.split(":");
      noter(`⚠️ ${A(id).nom} : ${e.message}`);
      if (e instanceof ErreurFatale) {
        prod.erreur = e.message;
        run.ctrl.abort();
      }
    } finally {
      save();
      planifierRendu();
    }
  }
  async function enParallele(ids, fn) {
    let i = 0;
    await Promise.all(Array.from({ length: Math.min(parallele, ids.length) }, async () => {
      while (i < ids.length && !signal.aborted) await fn(ids[i++]);
    }));
  }
  const verifier = () => { if (signal.aborted) throw new DOMException("Interrompu", "AbortError"); };

  try {
    /* 1. Vision */
    const v = prod.vision;
    await Promise.all([
      !v.benchmark && unite("vision:a05", async () => { v.benchmark = await appel("vision:a05", A("a05"), TACHES.benchmark(prod.brief)); }),
      !v.da && unite("vision:a04", async () => { v.da = await appel("vision:a04", A("a04"), TACHES.da(prod.brief)); }),
    ].filter(Boolean));
    verifier();
    if (!v.canon) {
      await unite("vision:a01", async () => {
        const r = await appel("vision:a01", A("a01"), TACHES.canon(prod.brief, v.benchmark, v.da), SCHEMAS.canon(true));
        Object.assign(v, { canon: r.canon, titre: r.titre, pitch: r.pitch });
      });
    }
    verifier();
    if (!v.canon) throw new Error("le canon n'a pas pu être écrit, la production s'arrête");
    noter(`🧭 Canon établi : « ${v.titre} »`);

    /* 2. Contributions */
    await enParallele(CREATEURS.filter(id => !prod.contributions[id]), id => unite(`contrib:${id}`, async () => {
      prod.contributions[id] = await appel(`contrib:${id}`, A(id), TACHES.contribution(A(id), prod.brief, v.canon), SCHEMAS.contribution(true));
    }));
    verifier();
    noter(`🛠️ ${Object.keys(prod.contributions).length}/${CREATEURS.length} contributions livrées`);

    /* 3. Revue QA */
    await enParallele(RELECTEURS_QA.filter(id => !prod.qa[id]), id => unite(`qa:${id}`, async () => {
      prod.qa[id] = await appel(`qa:${id}`, A(id), TACHES.qa(A(id), prod.brief, v.canon, dossierQA(prod, id)), SCHEMAS.qa(true));
    }));
    verifier();

    /* 4. Coordination */
    if (!prod.coordination) {
      await unite("coord:a03", async () => {
        prod.coordination = await appel("coord:a03", A("a03"),
          TACHES.coordination(prod.brief, v.canon, digestDecisions(prod.contributions), digestProblemes(prod.qa)),
          SCHEMAS.coordination(true));
      });
    }
    verifier();

    /* 5. Révisions */
    const aReviser = Object.entries(revisionsDemandees(prod)).filter(([id]) => !prod.revisionsFaites[id]);
    if (aReviser.length) noter(`✏️ ${aReviser.length} agents révisent leur livrable`);
    await enParallele(aReviser, ([id, consignes]) => unite(`rev:${id}`, async () => {
      const r = await appel(`rev:${id}`, A(id),
        TACHES.revision(A(id), v.canon, prod.contributions[id].livrable, consignes, problemesDe(prod, id)),
        SCHEMAS.contribution(true));
      prod.contributions[id] = Object.assign(r, { revise: true });
      prod.revisionsFaites[id] = true;
    }));
    verifier();

    /* 6. Plan & Bible */
    await Promise.all([
      !prod.plan && unite("plan:a02", async () => {
        prod.plan = await appel("plan:a02", A("a02"),
          TACHES.plan(prod.brief, v.canon, digestTaches(prod.contributions), arbitragesTexte(prod)), SCHEMAS.plan(true));
      }),
      !prod.bible && unite("bible:a01", async () => {
        prod.bible = await appel("bible:a01", A("a01"),
          TACHES.bible(prod.brief, v.canon, digestDecisions(prod.contributions), arbitragesTexte(prod),
            digestProblemes(prod.qa, ["bloquant", "majeur"])), SCHEMAS.bible(true));
      }),
    ].filter(Boolean));
    verifier();

    prod.statut = Object.keys(prod.echecs).length ? "incomplet" : "termine";
    noter(prod.statut === "termine" ? "🎉 Production terminée !" : "⚠️ Production terminée avec des échecs : relancez pour les reprendre");
  } catch (e) {
    prod.statut = "interrompu";
    if (prod.erreur) noter(`⛔ Arrêt : ${prod.erreur}`);
    else if (e.name === "AbortError") noter("⏸️ Production interrompue — elle reprendra là où elle s'est arrêtée");
    else noter(`⛔ ${e.message}`);
  } finally {
    run.actif = false;
    save();
    const titre = prod.vision.titre || projet.nom;
    logEvent(`🎬 Production « ${esc(titre)} » : ${libelleStatut(prod.statut).toLowerCase()} (<b>${esc(projet.nom)}</b>)`);
    rendreProduction();
  }
}

function noter(msg) {
  if (!run) return;
  run.journal.unshift({ t: Date.now(), msg });
  planifierRendu();
}
function nomModele(m) {
  return { "claude-opus-5": "Claude Opus 5", "claude-sonnet-5": "Claude Sonnet 5", "claude-haiku-4-5": "Claude Haiku 4.5" }[m] || m;
}
function libelleStatut(s) {
  return { prete: "Prête", en_cours: "En cours", termine: "Terminée", incomplet: "Incomplète", interrompu: "Interrompue" }[s] || s;
}

/* ========================= état des unités ========================= */

/* toutes les unités de travail d'une production, avec leur état actuel */
function unitesProduction(prod) {
  const vivant = run && run.prodId === prod.id ? run.statuts : {};
  const etat = (cle, fait) => vivant[cle] === "travail" ? "travail"
    : fait ? "fini" : prod.echecs && prod.echecs[cle] ? "echec" : "attente";
  const u = [
    { cle: "vision:a05", etape: "vision", fait: !!prod.vision.benchmark },
    { cle: "vision:a04", etape: "vision", fait: !!prod.vision.da },
    { cle: "vision:a01", etape: "vision", fait: !!prod.vision.canon },
    ...CREATEURS.map(id => ({ cle: `contrib:${id}`, etape: "contributions", fait: !!prod.contributions[id] })),
    ...RELECTEURS_QA.map(id => ({ cle: `qa:${id}`, etape: "qa", fait: !!prod.qa[id] })),
    { cle: "coord:a03", etape: "coordination", fait: !!prod.coordination },
    ...Object.keys(revisionsDemandees(prod)).map(id => ({ cle: `rev:${id}`, etape: "revisions", fait: !!prod.revisionsFaites[id] })),
    { cle: "plan:a02", etape: "final", fait: !!prod.plan },
    { cle: "bible:a01", etape: "final", fait: !!prod.bible },
  ];
  for (const x of u) x.etat = etat(x.cle, x.fait);
  return u;
}

/* ========================= interface ========================= */

let prodAffichee = null;     // id de la production affichée
let ongletProd = "salle";
let renduPlanifie = null;

function planifierRendu() {
  if (renduPlanifie) return;
  renduPlanifie = setTimeout(() => {
    renduPlanifie = null;
    if (currentView === "production") rendreProduction();
  }, 500);
}

function ouvrirProduction(prodId, onglet) {
  prodAffichee = prodId;
  ongletProd = onglet || "salle";
  showView("production");
}

function rendreProduction() {
  const wrap = document.getElementById("prod-wrap");
  if (!wrap) return;
  const trouve = prodAffichee && trouverProduction(prodAffichee);
  if (!trouve) {
    const toutes = state.projects.flatMap(p => (p.productions || []).map(pr => ({ p, pr })));
    wrap.innerHTML = `<h1>🎬 Salle de production</h1>
      <p class="muted">Aucune production ouverte. Ouvrez un projet et cliquez sur « 🚀 Brief au studio » :
      les 50 agents travailleront ensemble à partir d'un seul brief.</p>
      ${toutes.length ? `<h2>Productions existantes</h2><div class="card-list">${toutes.map(({ p, pr }) => `
        <div class="project-card" data-prod="${pr.id}">
          <div class="pc-top"><div><div class="pc-nom">${esc(pr.vision.titre || p.nom)}</div>
          <div class="pc-type">${esc(p.nom)} · ${new Date(pr.cree).toLocaleDateString("fr-FR")}</div></div>
          <span class="badge ${classeStatut(pr.statut)}">${libelleStatut(pr.statut)}</span></div>
        </div>`).join("")}</div>` : ""}`;
    wrap.querySelectorAll("[data-prod]").forEach(el => el.addEventListener("click", () => ouvrirProduction(el.dataset.prod)));
    return;
  }
  const { projet, prod } = trouve;
  const enCours = run && run.actif && run.prodId === prod.id;
  const unites = unitesProduction(prod);
  const finies = unites.filter(u => u.etat === "fini").length;
  const cout = coutProduction(prod);
  const peutReprendre = !enCours && prod.statut !== "termine" && prod.source !== "claude-code";

  wrap.innerHTML = `
    <button class="ghost-btn" id="btn-prod-retour">← ${esc(projet.nom)}</button>
    <div class="detail-head" style="margin-top:14px">
      <h1>🎬 ${esc(prod.vision.titre || "Production en préparation")}</h1>
      <span class="badge ${classeStatut(prod.statut)}">${libelleStatut(prod.statut)}</span>
    </div>
    ${prod.vision.pitch ? `<p class="detail-desc">${esc(prod.vision.pitch)}</p>` : ""}
    <div class="prod-meta">
      <span>🤖 ${esc(prod.source === "claude-code" ? "Workflow Claude Code" : nomModele(prod.modele))}</span>
      <span>✅ ${finies}/${unites.length} étapes d'agents</span>
      ${cout !== null && prod.source !== "claude-code" ? `<span>💶 ≈ ${cout.toFixed(2)} $ consommés</span>` : ""}
      ${prod.erreur ? `<span class="txt-danger">⛔ ${esc(prod.erreur)}</span>` : ""}
    </div>
    <div class="progress big"><div style="width:${Math.round(100 * finies / unites.length)}%"></div></div>
    <div class="btn-row" style="margin:14px 0">
      ${enCours ? `<button class="danger-btn" id="btn-prod-stop">⏸️ Interrompre</button>` : ""}
      ${peutReprendre ? `<button class="primary-btn" id="btn-prod-go2">${prod.statut === "prete" ? "🚀 Lancer" : "▶️ Reprendre / relancer les échecs"}</button>` : ""}
      <button class="ghost-btn" id="btn-prod-md">⬇️ Télécharger la bible (.md)</button>
      <button class="ghost-btn" id="btn-prod-json">⬇️ Exporter (.json)</button>
      ${!enCours ? `<button class="danger-btn" id="btn-prod-del">🗑️ Supprimer</button>` : ""}
    </div>
    <div class="tabs">
      <button class="tab ${ongletProd === "salle" ? "active" : ""}" data-tab="salle">🏭 Salle de production</button>
      <button class="tab ${ongletProd === "bible" ? "active" : ""}" data-tab="bible">📖 Bible de production</button>
    </div>
    <div id="prod-contenu"></div>`;

  const contenu = wrap.querySelector("#prod-contenu");
  if (ongletProd === "salle") rendreSalle(contenu, prod, unites);
  else rendreBible(contenu, projet, prod);

  wrap.querySelector("#btn-prod-retour").addEventListener("click", () => openProject(projet.id));
  wrap.querySelectorAll(".tab").forEach(b => b.addEventListener("click", () => { ongletProd = b.dataset.tab; rendreProduction(); }));
  const stop = wrap.querySelector("#btn-prod-stop");
  if (stop) stop.addEventListener("click", () => { run.ctrl.abort(); toast("Interruption demandée…"); });
  const go = wrap.querySelector("#btn-prod-go2");
  if (go) go.addEventListener("click", () => lancerProduction(prod.id));
  wrap.querySelector("#btn-prod-md").addEventListener("click", () =>
    telecharger(`${slugProd(prod.vision.titre || projet.nom)}-bible.md`, markdownComplet(prod), "text/markdown"));
  wrap.querySelector("#btn-prod-json").addEventListener("click", () =>
    telecharger(`${slugProd(prod.vision.titre || projet.nom)}-production.json`, JSON.stringify(prod, null, 2), "application/json"));
  const del = wrap.querySelector("#btn-prod-del");
  if (del) del.addEventListener("click", () => {
    if (!confirm("Supprimer définitivement cette production ?")) return;
    projet.productions = projet.productions.filter(x => x.id !== prod.id);
    save();
    openProject(projet.id);
  });
}

function classeStatut(s) {
  return { termine: "termine", en_cours: "actif", prete: "pause", incomplet: "pause", interrompu: "pause" }[s] || "pause";
}

function rendreSalle(el, prod, unites) {
  const parEtape = id => unites.filter(u => u.etape === id);
  const etatEtape = id => {
    const us = parEtape(id);
    if (!us.length) return id === "revisions" && prod.coordination ? "fini" : "attente";
    if (us.some(u => u.etat === "travail")) return "travail";
    if (us.every(u => u.etat === "fini")) return "fini";
    if (us.some(u => u.etat === "echec")) return "echec";
    return us.some(u => u.etat === "fini") ? "travail" : "attente";
  };
  const icone = { attente: "⏳", travail: "🔨", fini: "✅", echec: "⚠️" };
  // état agrégé par agent : au travail > échec > fini > en attente
  const etatAgent = {};
  const rang = { travail: 3, echec: 2, fini: 1, attente: 0 };
  for (const u of unites) {
    const id = u.cle.split(":")[1];
    if (etatAgent[id] === undefined || rang[u.etat] > rang[etatAgent[id]]) etatAgent[id] = u.etat;
  }
  const vivant = run && run.prodId === prod.id ? run : null;

  el.innerHTML = `
    <div class="timeline">${ETAPES_PROD.map(e => {
      const st = etatEtape(e.id);
      const us = parEtape(e.id);
      return `<div class="tl-step ${st}">
        <div class="tl-emoji">${e.emoji}</div>
        <div class="tl-nom">${e.nom}</div>
        <div class="tl-etat">${icone[st]} ${us.filter(u => u.etat === "fini").length}/${us.length || "—"}</div>
      </div>`;
    }).join("")}</div>
    <div class="salle">${DEPTS.map(d => `
      <div class="salle-dept">
        <div class="salle-dept-nom" style="color:${d.color}">${d.emoji} ${d.nom}</div>
        <div class="salle-agents">${AGENTS.filter(a => a.dept === d.id).map(a => {
          const st = etatAgent[a.id] || "attente";
          const car = vivant ? Object.entries(vivant.progres).filter(([k]) => k.endsWith(":" + a.id) && vivant.statuts[k] === "travail").map(([, n]) => n)[0] : 0;
          return `<div class="tuile ${st}" data-aid="${a.id}" title="${esc(a.nom)} — ${esc(a.role)}">
            <span class="tuile-emoji">${a.emoji}</span>
            <span class="tuile-nom">${esc(a.nom.split(" ")[0])}</span>
            <span class="tuile-etat">${icone[st]}${st === "travail" && car ? ` ${Math.round(car / 100) / 10}k` : ""}</span>
          </div>`;
        }).join("")}</div>
      </div>`).join("")}
    </div>
    ${Object.keys(prod.echecs || {}).length ? `<div class="echecs"><b>Échecs à reprendre :</b> ${Object.entries(prod.echecs).map(([k, m]) => `${esc(k)} (${esc(m)})`).join(" · ")}</div>` : ""}
    <h2>Journal</h2>
    <div class="log-list">${vivant && vivant.journal.length
      ? vivant.journal.slice(0, 30).map(j => `<div class="log-item">${esc(j.msg)} <span class="log-time">· ${timeAgo(j.t)}</span></div>`).join("")
      : `<p class="muted">${prod.statut === "prete" ? "Cliquez sur « 🚀 Lancer » pour mettre le studio au travail." : "Le journal détaillé s'affiche pendant l'exécution."}</p>`}
    </div>`;
  el.querySelectorAll(".tuile").forEach(t => t.addEventListener("click", () => ouvrirLivrables(prod, t.dataset.aid)));
}

/* ------- ce qu'un agent a produit dans cette production ------- */
function livrablesAgent(prod, id) {
  const out = [];
  if (id === "a05" && prod.vision.benchmark) out.push(["Analyse de marché", prod.vision.benchmark]);
  if (id === "a04" && prod.vision.da) out.push(["Direction artistique", prod.vision.da]);
  if (id === "a01" && prod.vision.canon) out.push(["Canon", prod.vision.canon]);
  if (id === "a01" && prod.bible) out.push(["Synthèse de la bible", prod.bible.bible || "(voir le fichier de la production)"]);
  if (prod.contributions[id]) {
    const c = prod.contributions[id];
    out.push([c.revise ? "Livrable (révisé)" : "Livrable", c.livrable || ""]);
    if ((c.decisions || []).length) out.push(["Décisions clés", c.decisions.map(x => `- ${x}`).join("\n")]);
  }
  if (prod.qa[id]) {
    out.push(["Rapport de relecture", prod.qa[id].rapport || ""]);
    const pb = prod.qa[id].problemes || [];
    if (pb.length) out.push(["Problèmes signalés", pb.map(p => `- **${p.gravite}** (${p.agent}) ${p.probleme} → ${p.correction}`).join("\n")]);
  }
  if (id === "a03" && prod.coordination) out.push(["Note de coordination", prod.coordination.synthese || ""]);
  if (id === "a02" && prod.plan) out.push(["Plan de production", prod.plan.plan || ""]);
  return out;
}
function ouvrirLivrables(prod, id) {
  const a = agentById[id];
  const d = deptById[a.dept];
  const parts = livrablesAgent(prod, id);
  const err = Object.entries(prod.echecs || {}).filter(([k]) => k.endsWith(":" + id));
  document.getElementById("livrable-head").innerHTML = `
    <div class="agent-profile"><span class="ap-emoji">${a.emoji}</span>
    <div><h2>${esc(a.nom)}</h2><div class="ap-role">${esc(a.role)} · ${d.emoji} ${d.nom}</div></div></div>`;
  document.getElementById("livrable-body").innerHTML = parts.length
    ? parts.map(([t, md]) => `<h2 class="md-section">${esc(t)}</h2>${mdVersHtml(md)}`).join("")
    : `<p class="muted">${err.length ? `⚠️ ${esc(err.map(([, m]) => m).join(" · "))}` : "Cet agent n'a encore rien livré pour cette production."}</p>`;
  document.getElementById("modal-livrable").classList.remove("hidden");
}

/* ------- la bible ------- */
function sectionsBible(prod) {
  const s = [];
  if (prod.bible && prod.bible.bible) s.push({ id: "synthese", titre: "⭐ Synthèse du directeur créatif", md: prod.bible.bible });
  if (prod.vision.canon) s.push({ id: "canon", titre: "🧭 Le canon", md: prod.vision.canon });
  if (prod.vision.da) s.push({ id: "da", titre: "🖼️ Direction artistique", md: prod.vision.da });
  if (prod.vision.benchmark) s.push({ id: "marche", titre: "⚖️ Analyse de marché", md: prod.vision.benchmark });
  for (const d of DEPTS.filter(x => DEPTS_CREATEURS.includes(x.id))) {
    const membres = AGENTS.filter(a => a.dept === d.id && prod.contributions[a.id]);
    if (!membres.length) continue;
    s.push({ id: "dept-" + d.id, titre: `${d.emoji} ${d.nom}`, md: membres.map(a => {
      const c = prod.contributions[a.id];
      return `## ${a.emoji} ${a.role} — ${a.nom}${c.revise ? " ✏️ révisé" : ""}\n\n${c.livrable || ""}`;
    }).join("\n\n") });
  }
  if (Object.keys(prod.qa).length) {
    s.push({ id: "qa", titre: "🧪 Revue QA", md: Object.entries(prod.qa).map(([id, r]) =>
      `## ${agentById[id].emoji} ${agentById[id].role} — ${agentById[id].nom}\n\n${r.rapport || ""}`).join("\n\n") });
  }
  if (prod.coordination) {
    const conflits = (prod.coordination.conflits || []).map(c => `| ${c.sujet} | ${(c.agents || []).join(", ")} | ${c.arbitrage} |`);
    s.push({ id: "coord", titre: "🤝 Coordination", md: (prod.coordination.synthese || "") +
      (conflits.length ? `\n\n## Arbitrages\n\n| Sujet | Agents | Arbitrage |\n|---|---|---|\n${conflits.join("\n")}` : "") });
  }
  if (prod.plan) {
    const lignes = (prod.plan.taches || []).map(t =>
      `| ${esc(PHASES[t.phase] || String(t.phase))} | ${t.titre} | ${(t.agents || []).map(x => agentById[x] ? agentById[x].nom.split(" ")[0] : x).join(", ")} |`);
    s.push({ id: "plan", titre: "📋 Plan de production", md: (prod.plan.plan || "") +
      (lignes.length ? `\n\n## Tâches\n\n| Phase | Tâche | Agents |\n|---|---|---|\n${lignes.join("\n")}` : "") });
  }
  const scripts = Object.entries(prod.scripts || {});
  if (scripts.length) s.push({ id: "scripts", titre: "📜 Scripts Luau", md: scripts.map(([n, c]) => `## ${n}\n\n\`\`\`lua\n${c.trim()}\n\`\`\``).join("\n\n") });
  return s;
}
function rendreBible(el, projet, prod) {
  const sections = sectionsBible(prod);
  if (!sections.length) {
    el.innerHTML = `<p class="muted">La bible se remplit au fur et à mesure que les agents livrent.</p>`;
    return;
  }
  const nbTaches = prod.plan ? (prod.plan.taches || []).length : 0;
  el.innerHTML = `
    ${nbTaches ? `<div class="import-bar">📋 Le plan contient ${nbTaches} tâches assignées aux agents.
      ${prod.tachesImportees ? `<span class="muted">✅ déjà ajoutées au tableau du projet</span>`
        : `<button class="primary-btn" id="btn-import-taches">➕ Ajouter au tableau de « ${esc(projet.nom)} »</button>`}</div>` : ""}
    <div class="bible">
      <nav class="bible-toc">${sections.map(s => `<a href="#" data-sec="${s.id}">${esc(s.titre)}</a>`).join("")}</nav>
      <article class="bible-corps md">${sections.map(s =>
        `<section id="sec-${s.id}"><h1 class="bible-titre">${esc(s.titre)}</h1>${mdVersHtml(s.md)}</section>`).join("")}</article>
    </div>`;
  el.querySelectorAll(".bible-toc a").forEach(a => a.addEventListener("click", e => {
    e.preventDefault();
    const cible = el.querySelector("#sec-" + a.dataset.sec);
    if (cible) cible.scrollIntoView({ behavior: "smooth", block: "start" });
  }));
  const imp = el.querySelector("#btn-import-taches");
  if (imp) imp.addEventListener("click", () => importerTaches(projet, prod));
}
function importerTaches(projet, prod) {
  for (const t of prod.plan.taches || []) {
    projet.tasks.push({
      id: uid(), titre: t.titre, statut: "todo",
      agents: (t.agents || []).filter(x => agentById[x]),
      note: `Phase : ${PHASES[t.phase] || t.phase}${t.note ? " — " + t.note : ""}`,
      created: Date.now(),
    });
  }
  prod.tachesImportees = true;
  logEvent(`<b>${esc(projet.nom)}</b> : ${prod.plan.taches.length} tâches du plan de production ajoutées au tableau`);
  save();
  toast(`${prod.plan.taches.length} tâches ajoutées au tableau du projet ✅`);
  rendreProduction();
}
function markdownComplet(prod) {
  let md = productionEnMarkdown(prod);
  const scripts = Object.entries(prod.scripts || {});
  if (scripts.length) md += "\n\n## 📜 Scripts Luau\n\n" + scripts.map(([n, c]) => `### ${n}\n\`\`\`lua\n${c.trim()}\n\`\`\``).join("\n\n");
  return md;
}
function telecharger(nom, contenu, type) {
  const url = URL.createObjectURL(new Blob([contenu], { type }));
  const a = document.createElement("a");
  a.href = url;
  a.download = nom;
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

/* ------- rendu markdown minimal et sûr (tout est échappé d'abord) ------- */
function mdEnLigne(s) {
  return s
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/(^|[\s(])\*([^*\s][^*]*)\*/g, "$1<em>$2</em>")
    .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
}
function mdVersHtml(md) {
  const lignes = esc(md || "").replace(/\r\n/g, "\n").split("\n");
  const out = [];
  let para = [];
  const finPara = () => { if (para.length) { out.push(`<p>${mdEnLigne(para.join(" "))}</p>`); para = []; } };
  for (let i = 0; i < lignes.length; i++) {
    const l = lignes[i];
    if (/^\s*```/.test(l)) {
      finPara();
      const code = [];
      i++;
      while (i < lignes.length && !/^\s*```/.test(lignes[i])) code.push(lignes[i++]);
      out.push(`<pre><code>${code.join("\n")}</code></pre>`);
      continue;
    }
    if (/^\s*\|.*\|\s*$/.test(l)) {
      finPara();
      const rangs = [];
      while (i < lignes.length && /^\s*\|.*\|\s*$/.test(lignes[i])) rangs.push(lignes[i++]);
      i--;
      const cellules = r => r.trim().replace(/^\||\|$/g, "").split("|").map(c => mdEnLigne(c.trim()));
      const corps = rangs.filter(r => !/^\s*\|[\s:|-]+\|\s*$/.test(r));
      const [tete, ...reste] = corps;
      out.push(`<div class="table-wrap"><table><thead><tr>${cellules(tete).map(c => `<th>${c}</th>`).join("")}</tr></thead><tbody>${
        reste.map(r => `<tr>${cellules(r).map(c => `<td>${c}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`);
      continue;
    }
    const titre = l.match(/^(#{1,6})\s+(.*)$/);
    if (titre) {
      finPara();
      const niveau = Math.min(6, titre[1].length + 1);
      out.push(`<h${niveau}>${mdEnLigne(titre[2])}</h${niveau}>`);
      continue;
    }
    const puce = l.match(/^(\s*)([-*+]|\d+[.)])\s+(.*)$/);
    if (puce) {
      finPara();
      const retrait = Math.min(4, Math.floor(puce[1].length / 2));
      const num = /\d/.test(puce[2]) ? `<span class="md-num">${puce[2]}</span> ` : "";
      out.push(`<div class="md-li" style="margin-left:${retrait * 18}px">${num}${mdEnLigne(puce[3])}</div>`);
      continue;
    }
    if (/^\s*&gt;\s?/.test(l)) {
      finPara();
      out.push(`<blockquote>${mdEnLigne(l.replace(/^\s*&gt;\s?/, ""))}</blockquote>`);
      continue;
    }
    if (/^\s*(-{3,}|\*{3,})\s*$/.test(l)) { finPara(); out.push("<hr>"); continue; }
    if (!l.trim()) { finPara(); continue; }
    para.push(l.trim());
  }
  finPara();
  return out.join("\n");
}

/* ------- productions dans la fiche projet ------- */
function htmlProductionsProjet(p) {
  const prods = p.productions || [];
  return `
    <div class="prod-card">
      <div class="prod-card-head">
        <div>
          <h2 style="margin:0">🎬 Production complète — les 50 agents</h2>
          <p class="muted" style="margin-top:4px">Un seul brief : vision, 40 spécialistes, revue QA, arbitrages, révisions, plan et bible de production.</p>
        </div>
        <div class="btn-row">
          <button class="primary-btn" id="btn-brief-studio">🚀 Brief au studio</button>
          <button class="ghost-btn" id="btn-import-prod">📥 Importer une production</button>
        </div>
      </div>
      ${prods.length ? `<div class="prod-list">${prods.map(pr => `
        <div class="prod-item" data-prod="${pr.id}">
          <span>🎬 <b>${esc(pr.vision.titre || "Production")}</b>
          <span class="muted">· ${new Date(pr.cree).toLocaleDateString("fr-FR")} · ${pr.source === "claude-code" ? "Claude Code" : esc(nomModele(pr.modele))}</span></span>
          <span class="badge ${classeStatut(pr.statut)}">${libelleStatut(pr.statut)}</span>
        </div>`).join("")}</div>` : ""}
    </div>`;
}
function brancherProductionsProjet(racine, p) {
  racine.querySelector("#btn-brief-studio").addEventListener("click", () => ouvrirModaleBrief(p));
  racine.querySelector("#btn-import-prod").addEventListener("click", () => {
    const input = document.getElementById("import-prod-file");
    input.onchange = () => importerProductionFichier(p, input);
    input.click();
  });
  racine.querySelectorAll(".prod-item").forEach(el => el.addEventListener("click", () => ouvrirProduction(el.dataset.prod)));
}

function ouvrirModaleBrief(p) {
  const brief = document.getElementById("prod-brief");
  brief.value = [p.nom, p.type !== "Autre" ? `Type de map : ${p.type}.` : "", p.desc].filter(Boolean).join("\n");
  const [bas, haut] = estimationCout(state.settings.model);
  const cle = !!state.settings.apiKey;
  document.getElementById("prod-estimation").innerHTML = cle
    ? `🤖 Modèle : <b>${nomModele(state.settings.model)}</b> · ${Math.max(1, Math.min(8, Number(state.settings.parallele) || 3))} agents en parallèle<br>
       💶 Coût estimé : <b>≈ ${bas.toFixed(0)} à ${haut.toFixed(0)} $</b> pour ${NB_APPELS_PREVUS} à ${NB_APPELS_PREVUS + 12} appels selon le nombre de révisions (facturés sur votre compte Anthropic)<br>
       ⏱️ Durée : 20 à 60 minutes selon le modèle et vos limites de débit. Gardez cet onglet ouvert ; si vous le fermez, la production reprendra là où elle s'était arrêtée.`
    : `🔌 Aucune clé API : ajoutez-la dans ⚙️ Réglages pour lancer les 50 agents depuis l'application.
       Vous pouvez aussi faire tourner la production dans Claude Code (workflow « atelier-roblox ») puis l'importer ici.`;
  document.getElementById("btn-prod-go").disabled = !cle;
  document.getElementById("btn-prod-go").onclick = () => {
    const texte = brief.value.trim();
    if (texte.length < 20) { toast("Décrivez un peu plus votre idée (20 caractères minimum)."); return; }
    const prod = nouvelleProduction(texte);
    if (!p.productions) p.productions = [];
    p.productions.unshift(prod);
    save();
    closeModals();
    ouvrirProduction(prod.id);
    lancerProduction(prod.id);
  };
  document.getElementById("modal-prod").classList.remove("hidden");
  brief.focus();
}

function importerProductionFichier(p, input) {
  const f = input.files[0];
  input.value = "";
  if (!f) return;
  const lecteur = new FileReader();
  lecteur.onload = () => {
    try {
      const prod = JSON.parse(lecteur.result);
      if (!prod || typeof prod !== "object" || !prod.vision || typeof prod.contributions !== "object")
        throw new Error("ce fichier n'est pas une production Atelier Roblox");
      prod.id = uid();
      prod.qa = prod.qa || {};
      prod.revisionsFaites = prod.revisionsFaites || {};
      prod.echecs = prod.echecs || {};
      prod.scripts = prod.scripts || {};
      prod.cree = prod.cree || Date.now();
      if (!p.productions) p.productions = [];
      p.productions.unshift(prod);
      if (!save()) {
        p.productions.shift();
        throw new Error("stockage du navigateur plein");
      }
      logEvent(`<b>${esc(p.nom)}</b> : production « ${esc(prod.vision.titre || "sans titre")} » importée 📥`);
      ouvrirProduction(prod.id, "bible");
    } catch (e) { toast("Import impossible : " + e.message); }
  };
  lecteur.readAsText(f);
}

window.addEventListener("beforeunload", e => {
  if (run && run.actif) { e.preventDefault(); e.returnValue = ""; }
});
