/* =========================================================================
   ATELIER ROBLOX — orchestrateur des productions complètes
   Un brief → les 50 agents travaillent ensemble via l'API Anthropic,
   directement depuis le navigateur (clé saisie dans les Réglages).
   Chaque résultat est sauvegardé dès qu'il arrive : une production
   interrompue reprend là où elle s'était arrêtée. Une étape ne démarre
   que lorsque la précédente est complète (ou que ses échecs ont été
   explicitement ignorés), pour que la bible reste cohérente.
   Utilise les globales d'app.js (state, save, toast, esc, verrou…) et de
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
    if (signal && signal.aborted) { ko(new DOMException("Interrompu", "AbortError")); return; }
    const t = setTimeout(ok, ms);
    if (signal) signal.addEventListener("abort", () => { clearTimeout(t); ko(new DOMException("Interrompu", "AbortError")); }, { once: true });
  });
}

/* lit un flux SSE de l'API Messages et reconstitue le texte final.
   En cas de coupure, l'erreur emporte le résultat partiel (e.partiel)
   pour que les jetons déjà consommés soient comptés. */
async function lireFlux(res, onProgres) {
  const lecteur = res.body.getReader();
  const dec = new TextDecoder();
  const r = { texte: "", caracteres: 0, stop: null, erreur: null, entree: 0, sortie: 0 };
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
          r.caracteres += ev.delta.text.length;   // compte aussi le texte abandonné lors d'un basculement
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
  try {
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
  } catch (e) {
    // l'erreur d'annulation est le même objet pour tous les flux d'un signal : on en crée une par flux
    const err = new Error((e && e.message) || "flux interrompu");
    err.name = (e && e.name) || "Error";
    err.partiel = r;
    throw err;
  }
  return r;
}

const CHAMPS_TEXTE = ["livrable", "rapport", "synthese", "plan", "bible", "canon"];

/* estimation des jetons de sortie d'un flux coupé avant son bilan */
const jetonsEstimes = caracteres => Math.ceil(caracteres / 3.5);

/* un appel complet, avec nouvelles tentatives sur les erreurs passagères */
async function appelClaude({ model, apiKey, system, user, schema, signal, onProgres, compter }) {
  const body = { model, max_tokens: 32000, stream: true, system, messages: [{ role: "user", content: user }] };
  if (schema) body.output_config = { format: { type: "json_schema", schema } };
  const headers = {
    "content-type": "application/json",
    "x-api-key": apiKey,
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
      if (e.partiel) compter(e.partiel.entree, e.partiel.sortie || jetonsEstimes(e.partiel.caracteres));
      if (signal && signal.aborted) throw new DOMException("Interrompu", "AbortError");
      derniere = new Error("flux interrompu");
      continue;
    }
    compter(r.entree, r.sortie || jetonsEstimes(r.caracteres));
    if (r.erreur) { derniere = new Error(r.erreur.message || r.erreur.type); continue; }
    if (r.stop === "refusal") throw new Error("demande déclinée par le modèle");
    if (r.stop === "max_tokens") throw new Error("réponse trop longue (limite de jetons atteinte)");
    if (!r.stop) { derniere = new Error("réponse incomplète"); continue; }
    if (!schema) {
      if (!r.texte.trim()) { derniere = new Error("réponse vide"); continue; }
      return r.texte.trim();
    }
    let obj;
    try { obj = JSON.parse(r.texte); }
    catch (e) { derniere = new Error("réponse JSON illisible"); continue; }
    // le texte principal d'un livrable ne peut pas être vide
    if (CHAMPS_TEXTE.some(c => c in obj && !String(obj[c] || "").trim())) { derniere = new Error("livrable vide"); continue; }
    return obj;
  }
  throw derniere || new Error("échec après plusieurs tentatives");
}

/* ========================= la production ========================= */

let run = null;   // production en cours dans cet onglet

function nouvelleProduction(brief) {
  return {
    id: uid(), source: "app", brief,
    modele: null, cree: Date.now(), statut: "prete",
    vision: { benchmark: null, da: null, canon: null, titre: null, pitch: null },
    contributions: {}, qa: {}, coordination: null, revisionsFaites: {},
    plan: null, bible: null, scripts: {}, echecs: {}, ignores: {},
    usages: {}, tachesImportees: false,
  };
}
function trouverProduction(prodId) {
  for (const p of state.projects)
    for (const pr of (p.productions || []))
      if (pr.id === prodId) return { projet: p, prod: pr };
  return null;
}
function coutProduction(prod) {
  const u = Object.entries(prod.usages || {});
  if (!u.length) return null;
  return u.reduce((total, [m, x]) => {
    const [pe, ps] = PRIX_MODELES[m] || PRIX_MODELES["claude-opus-5"];
    return total + (x.entree * pe + x.sortie * ps) / 1e6;
  }, 0);
}
function modelesUtilises(prod) {
  const m = Object.keys(prod.usages || {});
  return m.length ? m.map(nomModele).join(" + ") : nomModele(prod.modele);
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
    if (!aCle(prod.contributions, r.agent)) continue;
    out[r.agent] = aCle(out, r.agent) ? `${out[r.agent]}\n${r.consignes}` : r.consignes;
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
/* échecs d'une étape qui n'ont pas été explicitement ignorés */
function echecsBloquants(prod, prefixes) {
  return Object.keys(prod.echecs || {}).filter(k => prefixes.some(p => k.startsWith(p)) && !prod.ignores[k]);
}
function aFaire(prod, cle, fait) {
  return !fait && !prod.ignores[cle];
}

class ArretEtape extends Error {}

/* cette production est-elle tenue par un autre onglet ? (le verrou de cet onglet ne compte pas) */
function tenueAilleurs(prodId) {
  const v = verrouAutreOnglet();
  return !!v && v.prodId === prodId;
}

/* fin de l'exclusivité : battement arrêté, verrous levés */
function liberer() {
  if (!run) return;
  clearInterval(run.battement);
  run.battement = null;
  leverVerrou();
  if (run.libererVerrou) { run.libererVerrou(); run.libererVerrou = null; }
}

/* exclusivité stricte entre onglets (navigator.locks, libéré automatiquement si l'onglet se ferme) */
async function prendreVerrouExclusif() {
  for (let essai = 0; essai < 4; essai++) {
    const r = await tenterVerrouExclusif();
    if (r.ok) return r;
    await new Promise(ok => setTimeout(ok, 120));
  }
  return { ok: false };
}
function tenterVerrouExclusif() {
  if (!navigator.locks || !navigator.locks.request) return Promise.resolve({ ok: true, liberer: () => {} });
  return new Promise(resolve => {
    navigator.locks.request("atelier-roblox-production", { ifAvailable: true }, verrou => {
      if (!verrou) { resolve({ ok: false }); return undefined; }
      return new Promise(liberer => resolve({ ok: true, liberer }));
    }).catch(() => resolve({ ok: true, liberer: () => {} }));
  });
}
window.addEventListener("pagehide", () => { if (run && (run.actif || run.nonSauve)) leverVerrou(); });

async function lancerProduction(prodId) {
  const trouve = trouverProduction(prodId);
  if (!trouve) return;
  if (run && run.actif) { toast("Une production est déjà en cours dans cet onglet."); return; }
  if (verrouAutreOnglet()) { toast("Une production tourne déjà dans un autre onglet : attendez qu'elle se termine."); return; }
  if (!state.settings.apiKey) { toast("Ajoutez d'abord votre clé API dans les Réglages."); return; }
  const { projet, prod } = trouve;
  if (run && run.nonSauve && run.prodId !== prodId) {
    const autre = trouverProduction(run.prodId);
    toast(`La production « ${(autre && autre.prod.vision.titre) || "précédente"} » n'est pas enregistrée : exportez-la ou libérez de la place d'abord.`);
    return;
  }
  const ancien = run;
  const nonSauveAvant = !!(ancien && ancien.nonSauve);
  // même production non enregistrée : on garde le verrou qu'on tient déjà
  const verrouTenu = nonSauveAvant && ancien.prodId === prodId ? { battement: ancien.battement, libererVerrou: ancien.libererVerrou } : null;
  // le modèle et la clé sont figés pour toute la durée de cette exécution
  run = {
    prodId, actif: true, ctrl: new AbortController(), statuts: {}, progres: {}, journal: [],
    model: state.settings.model, apiKey: state.settings.apiKey, nonSauve: nonSauveAvant,
    battement: verrouTenu ? verrouTenu.battement : null, libererVerrou: verrouTenu ? verrouTenu.libererVerrou : null,
  };
  const signal = run.ctrl.signal;
  if (!verrouTenu) {
    const exclusif = await prendreVerrouExclusif();
    if (!exclusif.ok) {
      run.actif = false;
      toast("Une production tourne déjà dans un autre onglet : attendez qu'elle se termine.");
      return;
    }
    run.libererVerrou = exclusif.liberer;
  }
  poserVerrou(prodId);
  // on ne remet à zéro erreur et échecs que si l'état peut être enregistré
  const avant = { statut: prod.statut, echecs: prod.echecs, erreur: prod.erreur };
  if (!prod.modele) prod.modele = run.model;
  prod.statut = "en_cours";
  prod.echecs = {};
  delete prod.erreur;
  if (!save()) {
    Object.assign(prod, { statut: avant.statut === "en_cours" ? "interrompu" : avant.statut, echecs: avant.echecs });
    if (avant.erreur) prod.erreur = avant.erreur;
    run.actif = false;
    // des résultats de la tentative précédente restent-ils en mémoire seulement ? on les protège
    run.nonSauve = nonSauveAvant;
    if (nonSauveAvant) { if (!run.battement) run.battement = setInterval(() => poserVerrou(prodId), 4000); }
    else liberer();
    toast("Stockage du navigateur plein : exportez cette production, puis supprimez d'anciennes productions.");
    rendreProduction();
    return;
  }
  run.nonSauve = false;
  if (!run.battement) run.battement = setInterval(() => poserVerrou(prodId), 4000);
  if (currentView === "production" && prodAffichee === prodId) rendreProduction();
  noter(`🚀 Production lancée avec ${nomModele(run.model)}`);
  const parallele = Math.max(1, Math.min(8, Number(state.settings.parallele) || 3));
  const A = id => agentById[id];
  const compter = (entree, sortie) => {
    const u = prod.usages[run.model] || (prod.usages[run.model] = { entree: 0, sortie: 0 });
    u.entree += entree;
    u.sortie += sortie;
  };

  const appel = (cle, a, tache, schema) => appelClaude({
    model: run.model, apiKey: run.apiKey,
    system: `${personaPrompt(a)}\n\n${REGLES_STUDIO}`,
    user: tache, schema, signal, compter,
    onProgres: n => { run.progres[cle] = n; battement(prodId); planifierProgres(); },
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
      if (signal.aborted && !(e instanceof ErreurFatale)) { run.statuts[cle] = "attente"; return; }
      run.statuts[cle] = "echec";
      prod.echecs[cle] = e.message;
      const id = cle.split(":")[1];
      noter(`⚠️ ${A(id).nom} : ${e.message}`);
      if (e instanceof ErreurFatale) {
        prod.erreur = e.message;
        run.ctrl.abort();
      }
    } finally {
      battement(prodId);
      if (!save() && !run.nonSauve) {
        // plus rien ne peut être enregistré : on arrête de consommer l'API
        run.nonSauve = true;
        prod.erreur = "Stockage du navigateur plein : exportez cette production (bouton ⬇️ Exporter) avant de fermer l'onglet";
        run.ctrl.abort();
      }
      planifierRendu();
    }
  }
  async function enParallele(items, fn) {
    let i = 0;
    await Promise.all(Array.from({ length: Math.min(parallele, items.length) }, async () => {
      while (i < items.length && !signal.aborted) await fn(items[i++]);
    }));
  }
  /* fin d'étape : interruption, ou échecs non ignorés → on s'arrête ici */
  const cloturer = (nomEtape, prefixes) => {
    if (signal.aborted) throw new DOMException("Interrompu", "AbortError");
    const bloquants = echecsBloquants(prod, prefixes);
    if (bloquants.length) throw new ArretEtape(`${bloquants.length} échec(s) à l'étape « ${nomEtape} »`);
  };

  try {
    /* 1. Vision */
    const v = prod.vision;
    await Promise.all([
      aFaire(prod, "vision:a05", v.benchmark) && unite("vision:a05", async () => { v.benchmark = await appel("vision:a05", A("a05"), TACHES.benchmark(prod.brief)); }),
      aFaire(prod, "vision:a04", v.da) && unite("vision:a04", async () => { v.da = await appel("vision:a04", A("a04"), TACHES.da(prod.brief)); }),
    ].filter(Boolean));
    cloturer("Vision", ["vision:a05", "vision:a04"]);
    if (!v.canon) {
      await unite("vision:a01", async () => {
        const r = await appel("vision:a01", A("a01"), TACHES.canon(prod.brief, v.benchmark, v.da), SCHEMAS.canon(true));
        Object.assign(v, { canon: r.canon, titre: r.titre, pitch: r.pitch });
      });
    }
    if (signal.aborted) throw new DOMException("Interrompu", "AbortError");
    if (!v.canon) throw new ArretEtape("le canon n'a pas pu être écrit (il est indispensable)");
    noter(`🧭 Canon établi : « ${v.titre} »`);

    /* 2. Contributions */
    await enParallele(CREATEURS.filter(id => aFaire(prod, `contrib:${id}`, prod.contributions[id])), id => unite(`contrib:${id}`, async () => {
      prod.contributions[id] = await appel(`contrib:${id}`, A(id), TACHES.contribution(A(id), prod.brief, v.canon), SCHEMAS.contribution(true));
    }));
    cloturer("Contributions", ["contrib:"]);
    noter(`🛠️ ${Object.keys(prod.contributions).length}/${CREATEURS.length} contributions livrées`);

    /* 3. Revue QA */
    await enParallele(RELECTEURS_QA.filter(id => aFaire(prod, `qa:${id}`, prod.qa[id])), id => unite(`qa:${id}`, async () => {
      prod.qa[id] = await appel(`qa:${id}`, A(id), TACHES.qa(A(id), prod.brief, v.canon, dossierQA(prod, id)), SCHEMAS.qa(true));
    }));
    cloturer("Revue QA", ["qa:"]);

    /* 4. Coordination */
    if (aFaire(prod, "coord:a03", prod.coordination)) {
      await unite("coord:a03", async () => {
        prod.coordination = await appel("coord:a03", A("a03"),
          TACHES.coordination(prod.brief, v.canon, digestDecisions(prod.contributions), digestProblemes(prod.qa)),
          SCHEMAS.coordination(true));
      });
    }
    cloturer("Coordination", ["coord:"]);

    /* 5. Révisions */
    const aReviser = Object.entries(revisionsDemandees(prod))
      .filter(([id]) => aFaire(prod, `rev:${id}`, prod.revisionsFaites[id]));
    if (aReviser.length) noter(`✏️ ${aReviser.length} agents révisent leur livrable`);
    await enParallele(aReviser, ([id, consignes]) => unite(`rev:${id}`, async () => {
      const r = await appel(`rev:${id}`, A(id),
        TACHES.revision(A(id), v.canon, prod.contributions[id].livrable, consignes, problemesDe(prod, id)),
        SCHEMAS.contribution(true));
      prod.contributions[id] = Object.assign(r, { revise: true });
      prod.revisionsFaites[id] = true;
    }));
    cloturer("Révisions", ["rev:"]);

    /* 6. Plan & Bible */
    await Promise.all([
      aFaire(prod, "plan:a02", prod.plan) && unite("plan:a02", async () => {
        prod.plan = await appel("plan:a02", A("a02"),
          TACHES.plan(prod.brief, v.canon, digestTaches(prod.contributions), arbitragesTexte(prod)), SCHEMAS.plan(true));
      }),
      aFaire(prod, "bible:a01", prod.bible) && unite("bible:a01", async () => {
        prod.bible = await appel("bible:a01", A("a01"),
          TACHES.bible(prod.brief, v.canon, digestDecisions(prod.contributions), arbitragesTexte(prod),
            digestProblemes(prod.qa, ["bloquant", "majeur"])), SCHEMAS.bible(true));
      }),
    ].filter(Boolean));
    cloturer("Plan & Bible", ["plan:", "bible:"]);

    prod.statut = "termine";
    noter("🎉 Production terminée !");
  } catch (e) {
    if (prod.erreur) {
      prod.statut = "interrompu";
      noter(`⛔ Arrêt : ${prod.erreur}`);
    } else if (e instanceof ArretEtape) {
      prod.statut = "incomplet";
      noter(`⚠️ ${e.message} : réessayez, ou continuez sans ces agents`);
    } else if (e.name === "AbortError") {
      prod.statut = "interrompu";
      noter("⏸️ Production interrompue — elle reprendra là où elle s'est arrêtée");
    } else {
      prod.statut = "incomplet";
      noter(`⛔ ${e.message}`);
    }
  } finally {
    run.actif = false;
    if (!save() && !run.nonSauve) run.nonSauve = true;
    // tant que des résultats ne sont pas enregistrés, aucun autre onglet ne doit reprendre cette production
    if (!run.nonSauve) liberer();
    const titre = prod.vision.titre || projet.nom;
    logEvent(`🎬 Production « ${titre} » : ${libelleStatut(prod.statut).toLowerCase()} (<b>${projet.nom}</b>)`);
    // la vue affichée (production, fiche projet, tableau de bord…) reflète le statut final
    if (currentView === "production") rendreProduction(); else rafraichirVue();
  }
}

/* les échecs actuels ne bloquent plus : l'étape suivante se fera sans eux */
/* une production peut-elle démarrer maintenant dans cet onglet ? (message sinon) */
function lancementPossible(prodId) {
  if (run && run.actif) { toast("Une production est déjà en cours dans cet onglet."); return false; }
  if (run && run.nonSauve && run.prodId !== prodId) { toast("Une production n'est pas enregistrée : exportez-la ou libérez de la place d'abord."); return false; }
  if (verrouAutreOnglet()) { toast("Une production tourne déjà dans un autre onglet : attendez qu'elle se termine."); return false; }
  return true;
}

function ignorerEchecs(prodId) {
  const t = trouverProduction(prodId);
  if (!t || !lancementPossible(prodId)) return;
  const cles = Object.keys(t.prod.echecs || {}).filter(k => !t.prod.ignores[k]);
  if (cles.includes("vision:a01")) { toast("Le canon est indispensable : réessayez-le."); return; }
  for (const k of cles) t.prod.ignores[k] = true;
  save();
  lancerProduction(prodId);
}

function noter(msg) {
  if (!run) return;
  run.journal.unshift({ t: Date.now(), msg });
  planifierRendu();
}
function nomModele(m) {
  return { "claude-opus-5": "Claude Opus 5", "claude-sonnet-5": "Claude Sonnet 5", "claude-haiku-4-5": "Claude Haiku 4.5" }[m] || "modèle inconnu";
}
function libelleStatut(s) {
  return { prete: "Prête", en_cours: "En cours", termine: "Terminée", incomplet: "Incomplète", interrompu: "Interrompue" }[s] || "Inconnu";
}
/* une production « en cours » que plus aucun onglet ne fait tourner est en fait interrompue */
function statutAffiche(prod) {
  if (prod.statut !== "en_cours") return prod.statut;
  const ici = run && run.actif && run.prodId === prod.id;
  return ici || verrouFrais(prod.id) ? "en_cours" : "interrompu";
}

/* ========================= état des unités ========================= */

/* toutes les unités de travail d'une production, avec leur état actuel */
function unitesProduction(prod) {
  const vivant = run && run.prodId === prod.id ? run.statuts : {};
  const etat = (cle, fait) => vivant[cle] === "travail" ? "travail"
    : fait ? "fini" : prod.ignores[cle] ? "ignore" : prod.echecs[cle] ? "echec" : "attente";
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
let progresPlanifie = null;
let livresAuDernierRendu = -1;
let expirationVerrouPlanifiee = null;
let bibleNouveauxAffiches = 0;

/* changement d'état d'un agent : pendant une production, la page n'est pas
   reconstruite (les boutons restent cliquables), seuls les indicateurs bougent */
function planifierRendu() {
  if (renduPlanifie) return;
  renduPlanifie = setTimeout(() => {
    renduPlanifie = null;
    if (currentView !== "production") return;
    const t = prodAffichee && trouverProduction(prodAffichee);
    const affichee = document.querySelector(`#prod-wrap [data-prod-id]`);
    if (run && run.actif && (!t || t.prod.id !== run.prodId)) return;   // son affichage ne dépend pas de ce run
    const surPlace = t && run && run.actif && affichee && affichee.dataset.prodId === t.prod.id;
    if (!surPlace) { rendreProduction(); return; }
    if (ongletProd === "salle") majSalleSurPlace(t.prod);
    else majBibleSurPlace(t.prod);
  }, 1000);
}
/* progression du texte en streaming : on ne touche qu'aux étiquettes des tuiles */
function planifierProgres() {
  if (progresPlanifie) return;
  progresPlanifie = setTimeout(() => {
    progresPlanifie = null;
    if (!run || currentView !== "production" || prodAffichee !== run.prodId) return;
    for (const [cle, n] of Object.entries(run.progres)) {
      if (run.statuts[cle] !== "travail") continue;
      const el = document.querySelector(`.tuile[data-aid="${cle.split(":")[1]}"] .tuile-etat`);
      if (el) el.textContent = `🔨 ${Math.round(n / 100) / 10}k`;
    }
  }, 700);
}

function ouvrirProduction(prodId, onglet) {
  prodAffichee = prodId;
  ongletProd = onglet || "salle";
  livresAuDernierRendu = -1;
  showView("production");
}

function majEntete(prod, unites) {
  unites = unites || unitesProduction(prod);
  const finies = unites.filter(u => u.etat === "fini").length;
  const c = document.querySelector("#prod-compteur");
  if (c) c.textContent = `✅ ${finies}/${unites.length} étapes d'agents`;
  const barre = document.querySelector("#prod-barre");
  if (barre) barre.style.width = `${Math.round(100 * finies / unites.length)}%`;
  const cout = coutProduction(prod);
  const ce = document.querySelector("#prod-cout");
  if (ce && cout !== null) ce.textContent = `💶 ≈ ${cout.toFixed(2)} $ consommés`;
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
        <div class="project-card" data-prod="${esc(pr.id)}">
          <div class="pc-top"><div><div class="pc-nom">${esc(pr.vision.titre || p.nom)}</div>
          <div class="pc-type">${esc(p.nom)} · ${new Date(pr.cree).toLocaleDateString("fr-FR")}</div></div>
          <span class="badge ${classeStatut(statutAffiche(pr))}">${esc(libelleStatut(statutAffiche(pr)))}</span></div>
        </div>`).join("")}</div>` : ""}`;
    wrap.querySelectorAll("[data-prod]").forEach(el => el.addEventListener("click", () => ouvrirProduction(el.dataset.prod)));
    return;
  }
  const { projet, prod } = trouve;
  const enCours = !!(run && run.actif && run.prodId === prod.id);
  const ailleurs = !enCours && tenueAilleurs(prod.id);
  const statut = statutAffiche(prod);
  const unites = unitesProduction(prod);
  const finies = unites.filter(u => u.etat === "fini").length;
  livresAuDernierRendu = finies;
  const ignores = unites.filter(u => u.etat === "ignore").length;
  const echecs = unites.filter(u => u.etat === "echec").length;
  const cout = coutProduction(prod);
  const autreIci = !!(run && (run.actif || run.nonSauve) && run.prodId !== prod.id);
  const peutReprendre = !enCours && !ailleurs && !autreIci && statut !== "termine" && prod.source !== "claude-code";
  clearTimeout(expirationVerrouPlanifiee);
  if (ailleurs) expirationVerrouPlanifiee = setTimeout(() => { if (currentView === "production") rendreProduction(); },
    Math.max(1000, FRAICHEUR_VERROU - ageVerrou() + 500));

  wrap.innerHTML = `
    <span data-prod-id="${esc(prod.id)}" hidden></span>
    <button class="ghost-btn" id="btn-prod-retour">← ${esc(projet.nom)}</button>
    <div class="detail-head" style="margin-top:14px">
      <h1>🎬 ${esc(prod.vision.titre || "Production en préparation")}</h1>
      <span class="badge ${classeStatut(statut)}">${esc(libelleStatut(statut))}</span>
    </div>
    ${prod.vision.pitch ? `<p class="detail-desc">${esc(prod.vision.pitch)}</p>` : ""}
    <div class="prod-meta">
      <span>🤖 ${esc(prod.source === "claude-code" ? "Workflow Claude Code" : modelesUtilises(prod))}</span>
      <span id="prod-compteur">✅ ${finies}/${unites.length} étapes d'agents</span>
      ${ignores ? `<span>⏭️ ${ignores} ignorée${ignores > 1 ? "s" : ""}</span>` : ""}
      <span id="prod-cout">${cout !== null ? `💶 ≈ ${cout.toFixed(2)} $ consommés` : ""}</span>
      ${prod.erreur ? `<span class="txt-danger">⛔ ${esc(prod.erreur)}</span>` : ""}
      ${ailleurs ? `<span>🔒 En cours dans un autre onglet</span>` : ""}
      ${autreIci && statut !== "termine" ? `<span>⏳ Une autre production occupe cet onglet</span>` : ""}
    </div>
    <div class="progress big"><div id="prod-barre" style="width:${Math.round(100 * finies / unites.length)}%"></div></div>
    <div class="btn-row" style="margin:14px 0">
      ${enCours ? `<button class="danger-btn" id="btn-prod-stop">⏸️ Interrompre</button>` : ""}
      ${peutReprendre ? `<button class="primary-btn" id="btn-prod-go2">${statut === "prete" ? "🚀 Lancer" : echecs ? "🔁 Réessayer les échecs" : "▶️ Reprendre"}</button>` : ""}
      ${peutReprendre && echecs ? `<button class="ghost-btn" id="btn-prod-ignorer">⏭️ Continuer sans eux</button>` : ""}
      <button class="ghost-btn" id="btn-prod-md">⬇️ Télécharger la bible (.md)</button>
      <button class="ghost-btn" id="btn-prod-json">⬇️ Exporter (.json)</button>
      ${!enCours && !ailleurs ? `<button class="danger-btn" id="btn-prod-del">🗑️ Supprimer</button>` : ""}
    </div>
    <div class="tabs">
      <button class="tab ${ongletProd === "salle" ? "active" : ""}" data-tab="salle">🏭 Salle de production</button>
      <button class="tab ${ongletProd === "bible" ? "active" : ""}" data-tab="bible">📖 Bible de production</button>
    </div>
    <div id="prod-contenu"></div>`;

  // les boutons sont branchés avant le contenu : un contenu illisible ne doit pas les rendre inertes
  wrap.querySelector("#btn-prod-retour").addEventListener("click", () => openProject(projet.id));
  wrap.querySelectorAll(".tab").forEach(b => b.addEventListener("click", () => { ongletProd = b.dataset.tab; rendreProduction(); }));
  const stop = wrap.querySelector("#btn-prod-stop");
  if (stop) stop.addEventListener("click", () => { run.ctrl.abort(); toast("Interruption demandée…"); });
  const go = wrap.querySelector("#btn-prod-go2");
  if (go) go.addEventListener("click", () => lancerProduction(prod.id));
  const ign = wrap.querySelector("#btn-prod-ignorer");
  if (ign) ign.addEventListener("click", () => {
    if (confirm("Continuer sans les agents en échec ? Les étapes suivantes se feront sans leur travail.")) ignorerEchecs(prod.id);
  });
  wrap.querySelector("#btn-prod-md").addEventListener("click", () =>
    telecharger(`${slugProd(prod.vision.titre || projet.nom)}-bible.md`, markdownComplet(prod), "text/markdown"));
  wrap.querySelector("#btn-prod-json").addEventListener("click", () =>
    telecharger(`${slugProd(prod.vision.titre || projet.nom)}-production.json`, JSON.stringify(prod, null, 2), "application/json"));
  const del = wrap.querySelector("#btn-prod-del");
  if (del) del.addEventListener("click", () => {
    if (tenueAilleurs(prod.id) || (run && run.actif && run.prodId === prod.id)) { toast("Cette production est en cours : interrompez-la d'abord."); return; }
    const nonEnregistree = !!(run && run.nonSauve && run.prodId === prod.id);
    if (!confirm(nonEnregistree
      ? "Cette production n'est pas enregistrée dans le navigateur. Si vous l'avez exportée, la supprimer libère de la place ; sinon ses résultats seront perdus. Supprimer ?"
      : "Supprimer définitivement cette production ?")) return;
    projet.productions = projet.productions.filter(x => x.id !== prod.id);
    save();
    openProject(projet.id);
  });

  const contenu = wrap.querySelector("#prod-contenu");
  try {
    if (ongletProd === "salle") rendreSalle(contenu, prod, unites);
    else rendreBible(contenu, projet, prod);
  } catch (e) {
    contenu.innerHTML = `<p class="txt-danger">Affichage impossible : ${esc(e.message)}</p>`;
  }
}

function classeStatut(s) {
  return { termine: "termine", en_cours: "actif" }[s] || "pause";
}

const ICONES_ETAT = { attente: "⏳", travail: "🔨", fini: "✅", echec: "⚠️", ignore: "⏭️", partiel: "◐" };

function etatEtape(prod, unites, id) {
  const us = unites.filter(u => u.etape === id);
  if (!us.length) {
    if (id !== "revisions") return "attente";
    return prod.coordination ? "fini" : prod.ignores["coord:a03"] ? "ignore" : "attente";
  }
  if (us.some(u => u.etat === "travail")) return "travail";
  if (us.some(u => u.etat === "echec")) return "echec";
  if (us.every(u => u.etat === "fini" || u.etat === "ignore")) return "fini";
  return us.some(u => u.etat === "fini") ? "partiel" : "attente";
}
/* état agrégé par agent : au travail > échec > fini > ignoré > en attente */
function etatsAgents(unites) {
  const rang = { travail: 4, echec: 3, fini: 2, ignore: 1, attente: 0 };
  const out = {};
  for (const u of unites) {
    const id = u.cle.split(":")[1];
    if (out[id] === undefined || rang[u.etat] > rang[out[id]]) out[id] = u.etat;
  }
  return out;
}
function libelleTuile(prod, id, st) {
  const vivant = run && run.prodId === prod.id ? run : null;
  const cle = vivant ? Object.keys(vivant.statuts).find(k => k.endsWith(":" + id) && vivant.statuts[k] === "travail") : null;
  const car = cle ? vivant.progres[cle] || 0 : 0;
  return `${ICONES_ETAT[st]}${st === "travail" && car ? ` ${Math.round(car / 100) / 10}k` : ""}`;
}
function htmlTimeline(prod, unites) {
  return ETAPES_PROD.map(e => {
    const st = etatEtape(prod, unites, e.id);
    const us = unites.filter(u => u.etape === e.id);
    return `<div class="tl-step ${st}">
      <div class="tl-emoji">${e.emoji}</div>
      <div class="tl-nom">${e.nom}</div>
      <div class="tl-etat">${ICONES_ETAT[st]} ${us.filter(u => u.etat === "fini").length}/${us.length || "—"}</div>
    </div>`;
  }).join("");
}
function htmlEchecs(prod) {
  const e = Object.entries(prod.echecs || {});
  return e.length ? `<div class="echecs"><b>Échecs :</b> ${e.map(([k, m]) =>
    `${esc(k)}${prod.ignores[k] ? " (ignoré)" : ""} : ${esc(m)}`).join(" · ")}</div>` : "";
}
function htmlJournal(prod) {
  const vivant = run && run.prodId === prod.id ? run : null;
  return vivant && vivant.journal.length
    ? vivant.journal.slice(0, 30).map(j => `<div class="log-item">${esc(j.msg)} <span class="log-time">· ${timeAgo(j.t)}</span></div>`).join("")
    : `<p class="muted">${prod.statut === "prete" ? "Cliquez sur « 🚀 Lancer » pour mettre le studio au travail." : "Le journal détaillé s'affiche pendant l'exécution."}</p>`;
}

function rendreSalle(el, prod, unites) {
  const etatAgent = etatsAgents(unites);
  el.innerHTML = `
    <div class="timeline" id="salle-timeline">${htmlTimeline(prod, unites)}</div>
    <div class="salle">${DEPTS.map(d => `
      <div class="salle-dept">
        <div class="salle-dept-nom" style="color:${d.color}">${d.emoji} ${d.nom}</div>
        <div class="salle-agents">${AGENTS.filter(a => a.dept === d.id).map(a => {
          const st = etatAgent[a.id] || "attente";
          return `<div class="tuile ${st}" data-aid="${a.id}" title="${esc(a.nom)} — ${esc(a.role)}">
            <span class="tuile-emoji">${a.emoji}</span>
            <span class="tuile-nom">${esc(a.nom.split(" ")[0])}</span>
            <span class="tuile-etat">${libelleTuile(prod, a.id, st)}</span>
          </div>`;
        }).join("")}</div>
      </div>`).join("")}
    </div>
    <div id="salle-echecs">${htmlEchecs(prod)}</div>
    <h2>Journal</h2>
    <div class="log-list" id="salle-journal">${htmlJournal(prod)}</div>`;
  el.querySelectorAll(".tuile").forEach(t => t.addEventListener("click", () => ouvrirLivrables(prod, t.dataset.aid)));
}
/* mise à jour sans recréer boutons ni tuiles (les clics en cours ne sont jamais perdus) */
function majSalleSurPlace(prod) {
  const unites = unitesProduction(prod);
  majEntete(prod, unites);
  const tl = document.getElementById("salle-timeline");
  if (tl) tl.innerHTML = htmlTimeline(prod, unites);
  const etatAgent = etatsAgents(unites);
  document.querySelectorAll("#prod-contenu .tuile[data-aid]").forEach(t => {
    const st = etatAgent[t.dataset.aid] || "attente";
    t.className = `tuile ${st}`;
    const lib = t.querySelector(".tuile-etat");
    if (lib) lib.textContent = libelleTuile(prod, t.dataset.aid, st);
  });
  const ech = document.getElementById("salle-echecs");
  if (ech) ech.innerHTML = htmlEchecs(prod);
  const jr = document.getElementById("salle-journal");
  if (jr) jr.innerHTML = htmlJournal(prod);
}
/* onglet Bible pendant une production : on signale les nouveaux livrables sans tout recharger */
function majBibleSurPlace(prod) {
  const unites = unitesProduction(prod);
  majEntete(prod, unites);
  const nouveaux = unites.filter(u => u.etat === "fini").length - livresAuDernierRendu;
  const zone = document.getElementById("bible-maj");
  if (!zone || nouveaux <= 0 || nouveaux === bibleNouveauxAffiches) return;
  bibleNouveauxAffiches = nouveaux;
  zone.innerHTML = `<div class="import-bar">🆕 ${nouveaux} nouveau${nouveaux > 1 ? "x" : ""} livrable${nouveaux > 1 ? "s" : ""} depuis l'affichage
    <button class="ghost-btn" id="btn-bible-maj">🔄 Afficher</button></div>`;
  zone.querySelector("#btn-bible-maj").addEventListener("click", rendreProduction);
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
  if (!a) return;
  const d = deptById[a.dept];
  const parts = livrablesAgent(prod, id);
  const err = Object.entries(prod.echecs || {}).filter(([k]) => k.endsWith(":" + id));
  document.getElementById("livrable-head").innerHTML = `
    <div class="agent-profile"><span class="ap-emoji">${a.emoji}</span>
    <div><h2>${esc(a.nom)}</h2><div class="ap-role">${esc(a.role)} · ${d.emoji} ${d.nom}</div></div></div>`;
  let corps;
  try {
    corps = parts.length
      ? parts.map(([t, md]) => `<h2 class="md-section">${esc(t)}</h2>${mdVersHtml(md)}`).join("")
      : `<p class="muted">${err.length ? `⚠️ ${esc(err.map(([, m]) => m).join(" · "))}` : "Cet agent n'a encore rien livré pour cette production."}</p>`;
  } catch (e) {
    corps = `<p class="txt-danger">Affichage impossible : ${esc(e.message)}</p>`;
  }
  document.getElementById("livrable-body").innerHTML = corps;
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
  const relecteurs = AGENTS.filter(a => prod.qa[a.id]);
  if (relecteurs.length) {
    s.push({ id: "qa", titre: "🧪 Revue QA", md: relecteurs.map(a =>
      `## ${a.emoji} ${a.role} — ${a.nom}\n\n${prod.qa[a.id].rapport || ""}`).join("\n\n") });
  }
  if (prod.coordination) {
    const conflits = (prod.coordination.conflits || []).map(c =>
      `| ${cellule(c.sujet)} | ${cellule((c.agents || []).join(", "))} | ${cellule(c.arbitrage)} |`);
    s.push({ id: "coord", titre: "🤝 Coordination", md: (prod.coordination.synthese || "") +
      (conflits.length ? `\n\n## Arbitrages\n\n| Sujet | Agents | Arbitrage |\n|---|---|---|\n${conflits.join("\n")}` : "") });
  }
  if (prod.plan) {
    const lignes = (prod.plan.taches || []).map(t =>
      `| ${cellule(PHASES[t.phase] || t.phase)} | ${cellule(t.titre)} | ${cellule((t.agents || []).map(x => estAgentId(x) ? agentById[x].nom.split(" ")[0] : x).join(", "))} |`);
    s.push({ id: "plan", titre: "📋 Plan de production", md: (prod.plan.plan || "") +
      (lignes.length ? `\n\n## Tâches\n\n| Phase | Tâche | Agents |\n|---|---|---|\n${lignes.join("\n")}` : "") });
  }
  const scripts = Object.entries(prod.scripts || {});
  if (scripts.length) s.push({ id: "scripts", titre: "📜 Scripts Luau", md: scripts.map(([n, c]) => `## ${n}\n\n\`\`\`lua\n${c.trim()}\n\`\`\``).join("\n\n") });
  return s;
}
function rendreBible(el, projet, prod) {
  const sections = sectionsBible(prod);
  bibleNouveauxAffiches = 0;
  if (!sections.length) {
    el.innerHTML = `<div id="bible-maj"></div><p class="muted">La bible se remplit au fur et à mesure que les agents livrent.</p>`;
    return;
  }
  const nbTaches = prod.plan ? (prod.plan.taches || []).length : 0;
  const ailleurs = tenueAilleurs(prod.id);
  const nonEnregistree = !!(run && run.nonSauve && run.prodId === prod.id);
  el.innerHTML = `
    <div id="bible-maj"></div>
    ${nbTaches ? `<div class="import-bar">📋 Le plan contient ${nbTaches} tâches assignées aux agents.
      ${prod.tachesImportees ? `<span class="muted">✅ déjà ajoutées au tableau du projet</span>`
        : ailleurs ? `<span class="muted">🔒 disponible quand la production sera terminée dans l'autre onglet</span>`
        : nonEnregistree ? `<span class="muted">💾 disponible une fois la production enregistrée (libérez de la place)</span>`
        : `<button class="primary-btn" id="btn-import-taches">➕ Ajouter au tableau de « ${esc(projet.nom)} »</button>`}</div>` : ""}
    <div class="bible">
      <nav class="bible-toc">${sections.map(s => `<a href="#" data-sec="${s.id}">${esc(s.titre)}</a>`).join("")}</nav>
      <article class="bible-corps md">${sections.map(s => {
        let html;
        try { html = mdVersHtml(s.md); } catch (e) { html = `<pre>${esc(s.md)}</pre>`; }
        return `<section id="sec-${s.id}"><h1 class="bible-titre">${esc(s.titre)}</h1>${html}</section>`;
      }).join("")}</article>
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
  if (prod.tachesImportees || tenueAilleurs(prod.id) || (run && run.nonSauve && run.prodId === prod.id)) return;
  const avant = projet.tasks.length;
  for (const t of prod.plan.taches || []) {
    projet.tasks.push({
      id: uid(), titre: t.titre, statut: "todo",
      agents: (t.agents || []).filter(estAgentId),
      note: `Phase : ${PHASES[t.phase] || t.phase}${t.note ? " — " + t.note : ""}`,
      created: Date.now(),
    });
  }
  prod.tachesImportees = true;
  if (!save()) {
    projet.tasks.length = avant;
    prod.tachesImportees = false;
    toast("Stockage du navigateur plein : les tâches n'ont pas été ajoutées.");
    rendreProduction();
    return;
  }
  logEvent(`<b>${projet.nom}</b> : ${prod.plan.taches.length} tâches du plan de production ajoutées au tableau`);
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
      const corps = rangs.filter(r => !/^\s*\|[\s:|-]+\|\s*$/.test(r));
      if (!corps.length) {
        // uniquement des séparateurs (tableau mal formé, dessin ASCII) : texte brut
        out.push(`<pre><code>${rangs.join("\n")}</code></pre>`);
        continue;
      }
      const cellules = r => r.trim().replace(/^\||\|$/g, "").split("|").map(c => mdEnLigne(c.trim()));
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
        <div class="prod-item" data-prod="${esc(pr.id)}">
          <span>🎬 <b>${esc(pr.vision.titre || "Production")}</b>
          <span class="muted">· ${new Date(pr.cree).toLocaleDateString("fr-FR")} · ${esc(pr.source === "claude-code" ? "Claude Code" : modelesUtilises(pr))}</span></span>
          <span class="badge ${classeStatut(statutAffiche(pr))}">${esc(libelleStatut(statutAffiche(pr)))}</span>
        </div>`).join("")}</div>` : ""}
    </div>`;
}
function brancherProductionsProjet(racine, p) {
  racine.querySelector("#btn-brief-studio").addEventListener("click", () => ouvrirModaleBrief(p.id));
  racine.querySelector("#btn-import-prod").addEventListener("click", () => {
    const input = document.getElementById("import-prod-file");
    input.onchange = () => importerProductionFichier(p.id, input);
    input.click();
  });
  racine.querySelectorAll(".prod-item").forEach(el => el.addEventListener("click", () => ouvrirProduction(el.dataset.prod)));
}

function ouvrirModaleBrief(projetId) {
  const p = state.projects.find(x => x.id === projetId);
  if (!p) return;
  const brief = document.getElementById("prod-brief");
  brief.value = [p.nom, p.type !== "Autre" ? `Type de map : ${p.type}.` : "", p.desc].filter(Boolean).join("\n");
  const [bas, haut] = estimationCout(state.settings.model);
  const cle = !!state.settings.apiKey;
  document.getElementById("prod-estimation").innerHTML = cle
    ? `🤖 Modèle : <b>${esc(nomModele(state.settings.model))}</b> · ${Math.max(1, Math.min(8, Number(state.settings.parallele) || 3))} agents en parallèle<br>
       💶 Coût estimé : <b>≈ ${bas.toFixed(0)} à ${haut.toFixed(0)} $</b> pour ${NB_APPELS_PREVUS} à ${NB_APPELS_PREVUS + 12} appels selon le nombre de révisions (facturés sur votre compte Anthropic)<br>
       ⏱️ Durée : 20 à 60 minutes selon le modèle et vos limites de débit. Gardez cet onglet ouvert ; si vous le fermez, la production reprendra là où elle s'était arrêtée.`
    : `🔌 Aucune clé API : ajoutez-la dans ⚙️ Réglages pour lancer les 50 agents depuis l'application.
       Vous pouvez aussi faire tourner la production dans Claude Code (workflow « atelier-roblox ») puis l'importer ici.`;
  document.getElementById("btn-prod-go").disabled = !cle;
  document.getElementById("btn-prod-go").onclick = () => {
    const texte = brief.value.trim();
    if (texte.length < 20) { toast("Décrivez un peu plus votre idée (20 caractères minimum)."); return; }
    if (!lancementPossible(null)) return;
    const projet = state.projects.find(x => x.id === projetId);
    if (!projet) { toast("Ce projet n'existe plus."); closeModals(); return; }
    const prod = nouvelleProduction(texte);
    projet.productions.unshift(prod);
    if (!save()) {
      projet.productions.shift();
      toast("Stockage du navigateur plein : exportez puis supprimez d'anciennes productions.");
      return;
    }
    closeModals();
    ouvrirProduction(prod.id);
    lancerProduction(prod.id);
  };
  document.getElementById("modal-prod").classList.remove("hidden");
  brief.focus();
}

function importerProductionFichier(projetId, input) {
  const f = input.files[0];
  input.value = "";
  if (!f) return;
  const lecteur = new FileReader();
  lecteur.onload = () => {
    let prod;
    try {
      prod = normaliserProduction(JSON.parse(lecteur.result));
    } catch (e) {
      prod = null;
    }
    if (!prod) { toast("Import impossible : ce fichier n'est pas une production Atelier Roblox."); return; }
    const p = state.projects.find(x => x.id === projetId);
    if (!p) { toast("Ce projet n'existe plus."); return; }
    // une copie importée repart d'un état propre pour ce projet
    prod.id = uid();
    if (prod.statut === "en_cours") prod.statut = "interrompu";
    prod.tachesImportees = false;
    p.productions.unshift(prod);
    if (!save()) {
      p.productions.shift();
      toast("Import impossible : stockage du navigateur plein.");
      return;
    }
    logEvent(`<b>${p.nom}</b> : production « ${prod.vision.titre || "sans titre"} » importée 📥`);
    ouvrirProduction(prod.id, "bible");
  };
  lecteur.readAsText(f);
}

window.addEventListener("beforeunload", e => {
  if (run && (run.actif || run.nonSauve)) { e.preventDefault(); e.returnValue = ""; }
});
