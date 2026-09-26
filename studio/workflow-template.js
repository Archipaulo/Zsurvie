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
if (entree.jeton !== undefined && !(typeof entree.jeton === "string" && /^[A-Za-z0-9_-]{4,64}$/.test(entree.jeton))) {
  throw new Error("args.jeton invalide : 4 à 64 caractères parmi lettres, chiffres, - et _.")
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
const FORME_DOSSIER = new RegExp(`^${BASE.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}(-\\d+)?$`)
let RACINE = null
if (typeof entree.dossier === "string") {
  if (!/^studio\/productions\/[a-z0-9-]+$/.test(entree.dossier)) throw new Error(`Dossier invalide : ${entree.dossier} (attendu : studio/productions/<nom>)`)
  RACINE = entree.dossier
} else {
  const reserve = await agent(
    `N'utilise pas l'outil Bash et ne crée rien. Trouve le premier dossier libre dans cette suite : ${BASE}, ${BASE}-2, ${BASE}-3, ${BASE}-4, ${BASE}-5…
Pour chaque candidat, dans l'ordre, fais un appel séparé à l'outil Glob avec le motif « <candidat>/**/* » (par exemple ${BASE}-2/**/*) : si l'appel ne renvoie aucun fichier, ce candidat est libre, arrête-toi et renvoie-le. Ne te fie jamais à un seul Glob pour plusieurs dossiers : ses résultats sont tronqués à 100 fichiers.`,
    { label: "📁 Réservation du dossier", phase: "Vision", effort: "low",
      schema: objet({ dossier: { type: "string", description: `Le premier dossier libre, de la forme ${BASE} ou ${BASE}-<n>` } }) })
  const brut = reserve && String(reserve.dossier || "")
  const d = brut && brut.replace(/[`'"]/g, "").trim().replace(/^.*?(studio\/productions\/)/, "$1").replace(/^\.\//, "").replace(/\/+$/, "")
  if (!d || !FORME_DOSSIER.test(d)) {
    throw new Error(`Réservation du dossier impossible (réponse : ${brut || "aucune"}). Relancez en précisant args.dossier avec un dossier vide de la forme ${BASE}-<n>.`)
  }
  RACINE = d
}
/* contrôle indépendant : le dossier retenu doit être vide (une production ne réutilise jamais un dossier) */
{
  const controle = await agent(
    `N'utilise pas l'outil Bash et ne crée rien. Fais un seul appel à l'outil Glob avec le motif \`${RACINE}/**/*\` et indique combien de fichiers il renvoie (0 si aucun).`,
    { label: "🔎 Contrôle du dossier", phase: "Vision", effort: "low",
      schema: objet({ fichiers: { type: "integer", description: "Nombre de fichiers trouvés" } }) })
  if (!controle || !Number.isInteger(controle.fichiers)) throw new Error(`Impossible de vérifier que ${RACINE} est vide : production arrêtée.`)
  if (controle.fichiers > 0) {
    throw new Error(`${RACINE} contient déjà ${controle.fichiers} fichier(s) : une production s'écrit toujours dans un dossier vide. Relancez sans args.dossier, ou avec un dossier vide.`)
  }
}
/* réservation exclusive : Write refuse de remplacer un fichier que l'agent n'a pas lu,
   donc un seul lancement peut créer le marqueur (deux lancements simultanés du même nom).
   args.jeton (facultatif) identifie le lancement : une reprise après interruption reconnaît son marqueur. */
const JETON = entree.jeton || ""
// uniquement des caractères sûrs : la relecture compare sans ambiguïté d'échappement
const CONTENU_MARQUEUR = `${slugProd(NOM)}|${JETON}`
const normaliserMarqueur = v => String(v || "").replace(/["'`]/g, "").trim()
const marqueur = await agent(
  `N'utilise pas l'outil Bash et surtout ne lis PAS le fichier avant. Avec l'outil Write, crée le fichier \`${RACINE}/.reservation\` contenant exactement : ${JSON.stringify(CONTENU_MARQUEUR)}
Si l'outil Write échoue (par exemple parce que le fichier existe déjà), n'insiste pas et réponds cree = false ; s'il réussit, réponds cree = true.`,
  { label: "🔐 Réservation exclusive", phase: "Vision", effort: "low", schema: objet({ cree: { type: "boolean" } }) })
let reserve = !!marqueur && marqueur.cree === true
if (!reserve && JETON) {
  // reprise d'une exécution interrompue : le marqueur est peut-être le nôtre
  const relu = await agent(
    `N'utilise pas l'outil Bash. Lis le fichier \`${RACINE}/.reservation\` avec l'outil Read et renvoie son contenu exact (sans les numéros de ligne).`,
    { label: "🔐 Vérification du marqueur", phase: "Vision", effort: "low", schema: objet({ contenu: { type: "string" } }) })
  reserve = !!relu && normaliserMarqueur(relu.contenu) === CONTENU_MARQUEUR
}
if (!reserve) {
  if (!marqueur) throw new Error("La réservation exclusive n'a pas pu être faite (agent en échec) : relancez le workflow.")
  // sans jeton, impossible de distinguer un autre lancement d'une reprise de celui-ci ; rien n'est encore produit
  const cause = JETON ? "par un autre lancement" : "par un autre lancement, ou par une exécution interrompue de celui-ci"
  throw new Error(typeof entree.dossier === "string"
    ? `${RACINE} est déjà réservé ${cause} : choisissez un autre dossier vide, ou relancez sans args.dossier. Aucun livrable n'a encore été produit.`
    : `${RACINE} est déjà réservé ${cause} : relancez, un nouveau dossier sera réservé. Aucun livrable n'a encore été produit.`)
}
const echecs = []
log(`Brief reçu pour « ${NOM} ». Livrables dans ${RACINE}/`)
const bench = par(ROLES_PROD.benchmark), da = par(ROLES_PROD.da), directeur = par(ROLES_PROD.canon)
const [okBrief, okBench, okDa] = await parallel([
  () => agent(`N'utilise pas l'outil Bash. Avec l'outil Write :
1. écris dans \`${RACINE}/brief.md\` exactement le texte suivant, caractère pour caractère, sans rien ajouter ni reformuler (il est entre les deux lignes de tirets) :
-----
${BRIEF}
-----
2. écris dans \`${RACINE}/infos.json\` exactement le texte suivant (entre les deux lignes de tirets) :
-----
${JSON.stringify({ brief: BRIEF, provisoire: true })}
-----
Puis réponds « livré ».`,
    { label: "📝 Archivage du brief", phase: "Vision", effort: "low" }),
  () => agent(prompt(bench, TACHES.benchmark(BRIEF), livraison(CHEMINS_SPECIAUX.benchmark)),
    { label: etiquette(bench), phase: "Vision" }),
  () => agent(prompt(da, TACHES.da(BRIEF), livraison(CHEMINS_SPECIAUX.da)),
    { label: etiquette(da), phase: "Vision" }),
])
if (!okBrief) log("brief.md n'a pas pu être écrit : la commande d'assemblage transmet de toute façon le brief exact.")
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
  if (!aCle(contributions, r.agent)) continue
  aReviser[r.agent] = aCle(aReviser, r.agent) ? `${aReviser[r.agent]}\n${r.consignes}` : r.consignes
}
const ignorees = coordination ? coordination.revisions.filter(r => !aCle(contributions, r.agent)).length : 0
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
/* le brief exact et les échecs passent par l'entrée standard ; une copie reste sur disque (infos.json)
   pour que l'assembleur puisse être relancé plus tard sans cette commande */
const INFOS = JSON.stringify({ brief: BRIEF, echecs })
const okInfos = await agent(
  `N'utilise pas l'outil Bash. Lis d'abord \`${RACINE}/infos.json\` avec Read s'il existe, puis, avec l'outil Write, remplace-le par exactement le texte suivant, caractère pour caractère (il est entre les deux lignes de tirets), puis réponds « livré » :\n-----\n${INFOS}\n-----`,
  { label: "📝 Archivage des infos", phase: "Plan & Bible", effort: "low" })
if (!okInfos) log("infos.json n'a pas pu être écrit : utilisez la commande d'assemblage renvoyée, qui transmet le brief et les échecs.")
const ASSEMBLAGE = `node studio/assembler.js ${RACINE} --infos-stdin <<'FIN_INFOS_ATELIER'\n${INFOS}\nFIN_INFOS_ATELIER`
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
