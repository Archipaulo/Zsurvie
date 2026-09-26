## Cadre

- **Lancement de référence : vendredi 16 octobre 2026, 17 h (Paris)**, veille des vacances de la Toussaint. 13 semaines, du vendredi au jeudi, jusqu'au 14 janvier 2027.
- **Si le lancement glisse après le 23 octobre**, La Nuit des Citrouilles passe en réserve pour 2027 ; décembre garde ses vraies dates.
- **Publication le jeudi à 10 h**, jamais le vendredi. Les événements s'allument seuls par l'horloge serveur (`ReplicatedStorage.CalendrierLiveOps`), sans republier.
- **Gel du code du 17 déc. au 4 janv.** : correctifs critiques seulement.

## Calendrier des 13 semaines

| Sem. | Dates | Mise à jour (jeudi précédent) | Événement / week-end bonus | Zbire de la Semaine (sam. 17 h) |
|---|---|---|---|---|
| S1 | 16-22 oct. | **v1.0** (ven. 16) | x2 Gemmes de lancement | Gluant |
| S2 | 23-29 oct. | **v1.1** : correctifs + Halloween | **La Nuit des Citrouilles** | Volant |
| S3 | 30 oct.-5 nov. | — | Nuit des Citrouilles (fin lun. 2 nov.) | Colosse-Citrouille |
| S4 | 6-12 nov. | — | x2 Galerie | Casqué |
| S5 | 13-19 nov. | **v1.2 Les Inventions** | x2 Gemmes | Rapide |
| S6 | 20-26 nov. | — | aucun (semaine témoin) | Sauteur |
| S7 | 27 nov.-3 déc. | **v1.3** : paquet Noël | x2 Galerie ; **Avent** dès le 1er déc. | Costaud |
| S8 | 4-10 déc. | — | Avent | Doré |
| S9 | 11-17 déc. | v1.3.1 correctifs | Avent + x2 Gemmes | Marcheur |
| S10 | 18-24 déc. | gel | **Le Grand Givre** + Avent | Colosse de Neige |
| S11 | 25-31 déc. | gel | Grand Givre + Nouvel An | Gluant |
| S12 | 1-7 janv. | — | Grand Givre (fin lun. 4 janv.) | Volant |
| S13 | 8-14 janv. | **v1.4 Missions** | x2 Gemmes de rentrée | Casqué |

## Les événements

### Week-end de lancement (x2 Gemmes)
- **Contenu :** gemmes doublées (Mine, Doré, jours franchis), bannière sur le Quai des Capsules.
- **Durée :** ven. 16 oct. 17 h → lun. 19 oct. 0 h.
- **Objectif :** D1 ≥ 30 % ; 70 % des nouveaux lancent une recherche dès la 1re session.

### La Nuit des Citrouilles (Halloween)
- **Durée :** ven. 23 oct. 17 h → lun. 2 nov. 23 h 59 (10 jours de vacances).
- **Prairie de nuit, mystérieuse sans faire peur :** `Lighting.ClockTime` 19,5, `Ambient` #4A4560, `OutdoorAmbient` #535676 ; 8 lanternes-citrouilles orange autour de la Maison (16 Parts `Neon`, 4 `PointLight` `Range` 16, `Brightness` 1,2). Chiptune sautillante, ni cri ni brouillard noir.
- **Zbires coiffés d'une citrouille violette** (4 Parts de plus, 30 au total), règles inchangées ; Colosse-Citrouille le Jour du Colosse.
- **Citrouilles dorées :** 3 par horde (6 dans la Capsule du Jour), 3 × 3 × 3 studs, 40 PV × coefficient coop, entre 20 et 60 studs de la Maison. Éclatée : 15 pièces à chaque Survivant et +1 au compteur de toute l'équipe.
- **Paliers** (60 citrouilles comptées par jour au plus) : 20 titre « Chasseur de citrouilles », 60 Blaster-Citrouille, 120 costume « Épouvantail rigolo », 200 Citrouille géante d'Alcôve, 300 variantes Halloween de la Galerie.
- **Objectif :** 35 % des participants jouent au moins 3 jours distincts ; D7 de la cohorte de lancement ≥ 12 %.

### v1.2 Les Inventions
- **Contenu :** recherche « Aimant à Pièces » (+4 studs de ramassage par niveau, 3 niveaux : moins de course au doigt sur mobile) ; modificateurs du Défi du Jour « Pluie de Dorés », « Jour express » (hordes de 60 s), « Rebonds » (Sauteurs × 2), « Blindage » (Casqués × 2).
- **Objectif :** réactiver 10 % des inactifs depuis 7 jours, aidés par le x2 Gemmes du 13 au 15 nov.

### L'Avent de Doc Boulon
- **Durée :** mar. 1er déc. → lun. 4 janv.
- **Contenu :** mur de 24 cases de 4 × 4 studs derrière Doc Boulon. Une case par jour où l'on termine une run : on compte les jours joués, pas les dates, donc on rattrape jusqu'au 4 janvier. Récompenses fixes et affichées, jamais tirées au sort : 20 cases à 50 gemmes ; cases 6, 12 et 18 = écharpe, bonnet, Blaster « Canon à neige » ; case 24 = Sapin-bloc animé d'Alcôve.
- **Objectif :** 25 % des joueurs de décembre ouvrent au moins 12 cases ; DAU/MAU ≥ 18 %.

### Le Grand Givre (Noël)
- **Durée :** ven. 18 déc. 17 h → lun. 4 janv. 23 h 59 (17 jours).
- **Prairie enneigée :** les Parts taguées `SolPrairie` (`CollectionService`) passent de #6CC24A à Crème #F6E7C1 ; les chemins restent en Terre battue. Flocons : 1 `ParticleEmitter` client, `Rate` 12. Zbires en bonnet violet, Colosse de Neige.
- **Cadeaux perdus :** 2 par horde, entre 25 et 50 studs de la Maison. On les ramasse en passant à moins de 4 studs (aucun bouton), on les porte (vitesse × 0,85) jusqu'à 10 studs de la Maison : 25 pièces par Survivant, +1 au compteur d'équipe. Étourdi, on lâche le cadeau.
- **Paliers** (50 par jour au plus) : 20 titre « Lutin de la Prairie », 60 costume « Survivant Givré », 120 Traîneau-bloc d'Alcôve, 180 Blaster-Sucre d'orge, 250 variantes Hiver de la Galerie.
- **Nouvel An** (31 déc. 23 h → 1er janv. 1 h) : compte à rebours sur le Quai des Capsules et dans le HUD, 4 `ParticleEmitter` de feu d'artifice (`Rate` 20) au-dessus du Laboratoire.
- **Objectif :** joueurs quotidiens des vacances ≥ 1,5 × la moyenne de novembre ; 30 % des participants atteignent 250.

### v1.4 Les missions du Zbire de la Semaine
- **Contenu :** 3 missions renouvelées chaque samedi à 17 h (ex. « 150 Casqués éliminés par coup critique »), 100 gemmes chacune.
- **Objectif :** D30 de la cohorte d'octobre ≥ 5 %.

## Règles des week-ends bonus

- **Vendredi 17 h → lundi 0 h (Paris).** x2 Gemmes : Mine, Doré, jours franchis ; Foreuse, Défi du Jour et Avent restent fixes. x2 Galerie : chaque élimination compte double vers les paliers 10 / 100 / 1 000.
- **Jamais** pendant un événement saisonnier, jamais deux x2 Gemmes d'affilée, au moins un week-end sans bonus par mois.
- **Annonce :** bannière au Laboratoire dès le jeudi, « Événement de l'expérience » sur le Creator Hub, notification via `ExperienceNotificationService` (opt-in proposé après la 2e run si `CanPromptOptInAsync` le permet).

## Garde-fous 9-15 ans

- Plafonds journaliers : dernier palier en 5 jours de jeu, pas de session marathon.
- Aucun palier vendu en Robux ; 1 pack cosmétique Robux par événement au plus.
- Pas de compte à rebours alarmiste : #FF2E63 reste le danger en jeu. Widget d'événement : barre de 220 × 36 px en haut du HUD, bouton de 60 px.

## Implémentation

Les deux modules forment un Package (`AutoUpdate`) partagé par le Laboratoire et la Prairie. Les compteurs d'événement partent avec les gemmes, dans le même `UpdateAsync`, à chaque jour franchi ; paliers journalisés par `AnalyticsService:LogCustomEvent`. Le service de la Galerie lit `LiveOps_MultGalerie` côté serveur.

```lua
-- ReplicatedStorage.CalendrierLiveOps (ModuleScript) : dates saisies en heure de Paris
local EVENEMENTS = { -- { id, genre, début, fin }
	{ "Lancement", "DoubleGemmes", "2026-10-16T17", "2026-10-19T00" },
	{ "NuitDesCitrouilles", "Saison", "2026-10-23T17", "2026-11-03T00" },
	{ "Galerie1", "DoubleGalerie", "2026-11-06T17", "2026-11-09T00" },
	{ "Inventions", "DoubleGemmes", "2026-11-13T17", "2026-11-16T00" },
	{ "Galerie2", "DoubleGalerie", "2026-11-27T17", "2026-11-30T00" },
	{ "AventDocBoulon", "Avent", "2026-12-01T00", "2027-01-05T00" },
	{ "Decembre", "DoubleGemmes", "2026-12-11T17", "2026-12-14T00" },
	{ "GrandGivre", "Saison", "2026-12-18T17", "2027-01-05T00" },
	{ "NouvelAn", "Fete", "2026-12-31T23", "2027-01-01T01" },
	{ "Rentree", "DoubleGemmes", "2027-01-08T17", "2027-01-11T00" },
}

local function dernierDimanche(annee: number, mois: number): number
	local d = os.date("!*t", os.time({ year = annee, month = mois + 1, day = 1, hour = 12 }) - 86400)
	return d.day - (d.wday - 1) -- wday 1 = dimanche
end

-- "AAAA-MM-JJTHH" (Paris) -> horodatage UTC ; heure d'été du dernier dimanche de mars à celui d'octobre
local function versUtc(texte: string): number
	local a, m, j, h = texte:match("^(%d+)-(%d+)-(%d+)T(%d+)$")
	local annee, mois, jour, heure = tonumber(a), tonumber(m), tonumber(j), tonumber(h)
	assert(annee and mois and jour and heure, "Date invalide : " .. texte)
	local t = os.time({ year = annee, month = mois, day = jour, hour = heure })
	local ete = t >= os.time({ year = annee, month = 3, day = dernierDimanche(annee, 3), hour = 1 })
		and t < os.time({ year = annee, month = 10, day = dernierDimanche(annee, 10), hour = 1 })
	return t - (if ete then 7200 else 3600)
end

local calendrier = {}
for i, e in EVENEMENTS do
	calendrier[i] = { id = e[1], genre = e[2], debut = versUtc(e[3]), fin = versUtc(e[4]) }
end
return calendrier
```

```lua
-- ServerScriptService.LiveOps (ModuleScript) : seul le serveur applique les bonus
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Calendrier = require(ReplicatedStorage.CalendrierLiveOps)

local LiveOps = {}
local SOURCES_DOUBLEES = { Mine = true, Dore = true, Jour = true } -- ni Foreuse, ni Défi du Jour, ni Avent

local function actualiser()
	local t = os.time()
	if RunService:IsStudio() then
		t += workspace:GetAttribute("DecalageTest") or 0 -- QA : avance l'horloge (secondes)
	end
	local etat = { Saison = "", Fete = "", Avent = false, MultGemmes = 1, MultGalerie = 1 }
	for _, ev in Calendrier do
		if t >= ev.debut and t < ev.fin then
			if ev.genre == "Saison" or ev.genre == "Fete" then
				etat[ev.genre] = ev.id
			elseif ev.genre == "Avent" then
				etat.Avent = true
			elseif ev.genre == "DoubleGemmes" then
				etat.MultGemmes = 2
			elseif ev.genre == "DoubleGalerie" then
				etat.MultGalerie = 2
			end
		end
	end
	for nom, valeur in etat do
		workspace:SetAttribute("LiveOps_" .. nom, valeur) -- répliqué pour l'affichage client
	end
end

-- Appelé par le service d'économie avant chaque crédit de gemmes
function LiveOps.gemmesAvecBonus(base: number, source: string): number
	local mult = if SOURCES_DOUBLEES[source] then workspace:GetAttribute("LiveOps_MultGemmes") or 1 else 1
	return math.floor(base * mult)
end

actualiser()
task.spawn(function()
	while true do
		task.wait(30)
		actualiser()
	end
end)

return LiveOps
```

**QA :** régler `DecalageTest` pour franchir chaque bascule, dont le passage à l'heure d'hiver du 25 octobre ; chaque fin d'événement doit remettre les multiplicateurs à 1 en moins de 30 s.

## Écarts au canon (validation de Victor Lanoue requise)

- Ajouts : recherche « Aimant à Pièces » ; missions hebdomadaires rattachées au Zbire de la Semaine, sans nouveau rendez-vous.
- Nouveaux noms : La Nuit des Citrouilles, L'Avent de Doc Boulon, Le Grand Givre, Colosse-Citrouille, Colosse de Neige (skins aux règles inchangées). Les ambiances saisonnières sont des états de la Prairie, comme le Jour du Colosse.
