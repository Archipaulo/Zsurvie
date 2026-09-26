/* =========================================================================
   Corps du workflow Claude Code « atelier-roblox ».
   Ce fichier n'est pas exécuté tel quel : generer.js le concatène après
   le bloc meta, agents.js et production.js pour produire
   .claude/workflows/atelier-roblox.js.
   Chaque agent écrit son livrable (markdown + fiche JSON) dans
   studio/productions/<projet>/ avec l'outil Write uniquement : les agents
   d'un workflow tournent sans surveillance et ne peuvent pas faire
   approuver de commandes. Le workflow renvoie la commande d'assemblage
   (assembler.js → production.json) que la session appelante exécute.
   ========================================================================= */

const entree = typeof args === "string" ? { brief: args } : (args || {})
const BRIEF = String(entree.brief || "").trim()
if (!BRIEF) {
  throw new Error('Brief manquant. Exemple : Workflow({ name: "atelier-roblox", args: { nom: "Île du Volcan", brief: "Une île tropicale..." } })')
}
const NOM = String(entree.nom || BRIEF.split(/\s+/).slice(0, 6).join(" ")).trim()
const par = id => AGENTS.find(a => a.id === id)
const etiquette = a => `${a.emoji} ${a.nom.split(" ")[0]} · ${a.role}`

/* consignes de livraison ajoutées à chaque tâche */
function livraison(chemin, fiche, extra) {
  const md = `${RACINE}/${chemin}.md`
  const json = `${RACINE}/${chemin}.json`
  const etapes = [`Écris ton livrable complet en markdown dans \`${md}\` avec l'outil Write (il crée les dossiers manquants).`]
  if (extra) etapes.push(extra)
  if (fiche) etapes.push(`Écris dans \`${json}\`, avec l'outil Write, ${fiche}. Ce fichier doit être du JSON strictement valide (guillemets doubles, aucune virgule finale, aucun commentaire).`)
  etapes.push(fiche ? "Termine par ta réponse structurée." : "Termine en répondant simplement « livré ».")
  return `\n\n# Livraison (obligatoire)\n${etapes.map((e, i) => `${i + 1}. ${e}`).join("\n")}\nN'utilise jamais l'outil Bash (aucune commande ne peut être approuvée pendant la production). Pour remplacer un fichier existant, lis-le d'abord avec l'outil Read : Write l'exige. N'explore pas le reste du dépôt et n'écris nulle part ailleurs que dans ${RACINE}/.`
}
const FICHE_IDENTIQUE = "exactement le même objet JSON que ta réponse structurée"
const prompt = (a, tache, liv) => `${personaPrompt(a)}\n\n${REGLES_STUDIO}\n\n${tache}${liv}`

/* ======================= 1. Vision ======================= */
phase("Vision")
/* un dossier neuf par lancement : jamais de mélange avec une production précédente */
const BASE = `studio/productions/${slugProd(NOM)}`
let RACINE = typeof entree.dossier === "string" && entree.dossier.startsWith("studio/productions/") ? entree.dossier : null
if (!RACINE) {
  const reserve = await agent(
    `N'utilise pas l'outil Bash. Avec l'outil Glob, cherche les fichiers correspondant au motif \`${BASE}*/**/*\`, puis renvoie le premier dossier sans aucun fichier parmi : ${BASE}, ${BASE}-2, ${BASE}-3, ${BASE}-4… Ne crée rien.`,
    { label: "📁 Réservation du dossier", phase: "Vision", effort: "low",
      schema: objet({ dossier: { type: "string", description: "Le premier dossier libre, par exemple studio/productions/mon-jeu-2" } }) })
  const d = reserve && String(reserve.dossier || "").trim().replace(/\/+$/, "")
  RACINE = d && d.startsWith(BASE) && !d.includes("..") ? d : BASE
}
const echecs = []
log(`Brief reçu pour « ${NOM} ». Livrables dans ${RACINE}/`)
const bench = par(ROLES_PROD.benchmark), da = par(ROLES_PROD.da), directeur = par(ROLES_PROD.canon)
const [okBench, okDa] = await parallel([
  () => agent(prompt(bench, TACHES.benchmark(BRIEF), livraison(CHEMINS_SPECIAUX.benchmark)),
    { label: etiquette(bench), phase: "Vision" }),
  () => agent(prompt(da, TACHES.da(BRIEF), livraison(CHEMINS_SPECIAUX.da)),
    { label: etiquette(da), phase: "Vision" }),
])
if (!okBench) echecs.push("vision:a05")
if (!okDa) echecs.push("vision:a04")
const lire = chemin => `(lis en entier le fichier \`${RACINE}/${chemin}.md\` ; s'il n'existe pas, fais sans)`
const canon = await agent(
  prompt(directeur,
    TACHES.canon(BRIEF, lire(CHEMINS_SPECIAUX.benchmark), lire(CHEMINS_SPECIAUX.da)),
    livraison(CHEMINS_SPECIAUX.canon,
      "l'objet JSON { \"titre\", \"pitch\" } avec les mêmes valeurs que ta réponse structurée")),
  { label: `${etiquette(directeur)} (canon)`, phase: "Vision", schema: SCHEMAS.canon(true) })
if (!canon || !canon.canon) throw new Error(`Le directeur créatif n'a pas pu écrire le canon : production arrêtée (dossier ${RACINE}).`)
log(`Canon établi : « ${canon.titre} » — ${canon.pitch}`)

/* ======================= 2. Contributions ======================= */
phase("Contributions")
const contributions = {}
/* chaque scripteur a son propre dossier de scripts : pas d'écrasement entre agents */
const consigneScripts = a => `Écris aussi chaque script complet dans \`${RACINE}/scripts/${a.id}/\` avec la convention Rojo (NomDuScript.server.lua, .client.lua ou .lua pour un ModuleScript) et indique son emplacement Roblox en première ligne de commentaire.`
const resultats = await parallel(CREATEURS.map(id => () => {
  const a = par(id)
  const extra = a.dept === "code" ? consigneScripts(a) : ""
  return agent(prompt(a, TACHES.contribution(a, BRIEF, canon.canon), livraison(cheminLivrable(a), FICHE_IDENTIQUE, extra)),
    { label: etiquette(a), phase: "Contributions", schema: SCHEMAS.contribution(false) })
    .then(r => ({ id, r }))
}))
for (const [i, res] of resultats.entries()) {
  if (res && res.r) contributions[res.id] = res.r
  else echecs.push(`contrib:${CREATEURS[i]}`)
}
log(`${Object.keys(contributions).length}/${CREATEURS.length} contributions livrées` +
  (echecs.length ? ` — manquantes : ${echecs.join(", ")}` : ""))

/* ======================= 3. Revue QA ======================= */
phase("Revue QA")
const qa = {}
const retoursQA = await parallel(RELECTEURS_QA.map(id => () => {
  const a = par(id)
  const fichiers = AGENTS
    .filter(x => FOCUS_QA[id].includes(x.dept) && contributions[x.id])
    .map(x => `- ${x.id} ${x.role} : \`${RACINE}/${cheminLivrable(x)}.md\``)
  const dossier = fichiers.length
    ? `Lis en entier ces livrables :\n${fichiers.join("\n")}\n\nEt voici les décisions de tout le studio :\n${digestDecisions(contributions)}`
    : `Les décisions de tout le studio :\n${digestDecisions(contributions)}`
  return agent(prompt(a, TACHES.qa(a, BRIEF, canon.canon, dossier), livraison(cheminLivrable(a), FICHE_IDENTIQUE)),
    { label: etiquette(a), phase: "Revue QA", schema: SCHEMAS.qa(false) })
    .then(r => ({ id, r }))
}))
for (const [i, res] of retoursQA.entries()) {
  if (res && res.r) qa[res.id] = res.r
  else echecs.push(`qa:${RELECTEURS_QA[i]}`)
}
const nbProblemes = Object.values(qa).reduce((n, r) => n + (r.problemes || []).length, 0)
log(`${nbProblemes} problèmes signalés par la QA`)

/* ======================= 4. Coordination ======================= */
phase("Coordination")
const chef = par(ROLES_PROD.coordination)
const coordination = await agent(
  prompt(chef, TACHES.coordination(BRIEF, canon.canon, digestDecisions(contributions), digestProblemes(qa)),
    livraison(CHEMINS_SPECIAUX.coordination, FICHE_IDENTIQUE)),
  { label: etiquette(chef), phase: "Coordination", schema: SCHEMAS.coordination(false) })
if (!coordination) echecs.push("coord:a03")
const arbitrages = coordination
  ? coordination.conflits.map(c => `- ${c.sujet} (${c.agents.join(", ")}) → ${c.arbitrage}`).join("\n")
  : ""

/* ======================= 5. Révisions ======================= */
phase("Révisions")
const aReviser = {}
for (const r of (coordination ? coordination.revisions : [])) {
  if (!contributions[r.agent]) continue
  aReviser[r.agent] = aReviser[r.agent] ? `${aReviser[r.agent]}\n${r.consignes}` : r.consignes
}
const ignorees = coordination ? coordination.revisions.filter(r => !contributions[r.agent]).length : 0
log(`${Object.keys(aReviser).length} agents révisent leur livrable` + (ignorees ? ` (${ignorees} demandes ignorées : agent inconnu ou sans livrable)` : ""))
await parallel(Object.entries(aReviser).map(([id, consignes]) => () => {
  const a = par(id)
  const problemes = Object.values(qa).flatMap(r => r.problemes || [])
    .filter(p => p.agent === id)
    .map(p => `- [${p.gravite}] ${p.probleme} → ${p.correction}`).join("\n")
  return agent(
    prompt(a, TACHES.revision(a, canon.canon, lire(cheminLivrable(a)), consignes, problemes),
      livraison(cheminLivrable(a), `${FICHE_IDENTIQUE}, avec en plus le champ "revise": true`,
        "Remplace le fichier existant par la version révisée complète." + (a.dept === "code"
          ? ` Réécris aussi tes scripts dans \`${RACINE}/scripts/${a.id}/\` pour qu'ils restent identiques au code de ton livrable : remplace chaque fichier par sa version corrigée, et remplace le contenu d'un script devenu inutile par la seule ligne « -- SUPPRIMÉ ».`
          : ""))),
    { label: `${etiquette(a)} (révision)`, phase: "Révisions", schema: SCHEMAS.contribution(false) })
    .then(r => {
      if (r) contributions[id] = Object.assign({ revise: true }, r)
      else echecs.push(`rev:${id}`)
    })
}))

/* ======================= 6. Plan & Bible ======================= */
phase("Plan & Bible")
const productrice = par(ROLES_PROD.plan)
const [plan, bible] = await parallel([
  () => agent(
    prompt(productrice, TACHES.plan(BRIEF, canon.canon, digestTaches(contributions), arbitrages),
      livraison(CHEMINS_SPECIAUX.plan, FICHE_IDENTIQUE)),
    { label: etiquette(productrice), phase: "Plan & Bible", schema: SCHEMAS.plan(false) }),
  () => agent(
    prompt(directeur, TACHES.bible(BRIEF, canon.canon, digestDecisions(contributions), arbitrages,
      digestProblemes(qa, ["bloquant", "majeur"])),
      livraison(CHEMINS_SPECIAUX.bible, FICHE_IDENTIQUE)),
    { label: `${etiquette(directeur)} (bible)`, phase: "Plan & Bible", schema: SCHEMAS.bible(false) }),
])
if (!plan) echecs.push("plan:a02")
if (!bible) echecs.push("bible:a01")

/* ======================= 7. Assemblage ======================= */
/* le brief exact et les échecs passent par l'entrée standard : rien à recopier à la main dans le JSON */
const ASSEMBLAGE = `node studio/assembler.js ${RACINE} --infos-stdin <<'FIN_INFOS_ATELIER'\n${JSON.stringify({ brief: BRIEF, echecs })}\nFIN_INFOS_ATELIER`
log(`Production terminée. Pour produire production.json et BIBLE-COMPLETE.md, exécuter la commande renvoyée dans « assemblage ».`)

return {
  dossier: RACINE,
  titre: (bible && bible.titre) || canon.titre,
  pitch: (bible && bible.pitch) || canon.pitch,
  contributions: `${Object.keys(contributions).length}/${CREATEURS.length}`,
  revues_qa: Object.keys(qa).length,
  problemes_qa: nbProblemes,
  conflits: coordination ? coordination.conflits.length : 0,
  revisions: Object.keys(aReviser).length,
  taches_planifiees: plan ? plan.taches.length : 0,
  echecs,
  a_faire: "Exécuter la commande « assemblage » ci-dessous depuis la racine du dépôt, puis importer production.json dans l'application.",
  assemblage: ASSEMBLAGE,
}
