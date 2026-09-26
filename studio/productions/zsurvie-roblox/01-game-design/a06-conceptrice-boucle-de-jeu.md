## 1. Les trois horloges

| Échelle | Durée | Unité | Question du joueur | Récompense |
|---|---|---|---|---|
| Micro | 30 s | 3 salves | « Où je cours ? » | Pops, Pièces |
| Moyenne | ≈ 5 min | 3 jours de 95 s | « J'achète quoi avant le Colosse ? » | Améliorations, nouveau Zbire |
| Session | 20-35 min | 1 ou 2 runs + Laboratoire | « Quelle recherche ? » | Gemmes, machine d'Alcôve, Record |

- **Arrivée :** 20 s pour toutes les runs (Doc Boulon à la radio, premières défenses). *Ajout au canon, soumis à Victor Lanoue.*
- **Jour N :** 80 s de horde + 15 s de Répit. La horde du jour N part à 20 + (N − 1) × 95 s, plus les prolongations des Jours du Colosse.
- **Colosse (J5, J10, J15) :** il sort du Grand Portail Nord 40 s après le début de la horde (7:20 au J5). 60 s après son entrée, il entre en colère : vitesse × 1,5, dégâts sur la Maison × 3. Le jour finit à sa chute.
- **Chute visée en Capsule Normale :** J8 à J11, soit 12 à 18 min.
- **Fin garantie :** Colosse du J15 abattu = victoire ; à 25:00 (`LIMITE_RUN`), fin de run forcée. Gemmes normales dans les deux cas.

## 2. Boucle de 30 secondes : repérer, se placer, tirer, ramasser, décider

| Temps | Action | Map et UI |
|---|---|---|
| 0-2 s | Repérer | Portail de la Lisière en Violet horde 2 s avant la salve, flèche de bord d'écran, son 8-bit |
| 2-6 s | Se placer | Maison → Lisière en moins de 5 s par les 4 chemins en Terre battue |
| 6-20 s | Tirer | Tir auto à 40 studs sur mobile ; le Zbire éclate en cubes et en Pièces (élastique 0,15 s) |
| 20-26 s | Ramasser | Pièces personnelles, aimant de 10 studs, disparition à 12 s : on ne campe pas au centre |
| 26-30 s | Décider | Maison sous 70 % → réparer ; Mine pleine → la vider ; défense libre → poser |

- Un pop toutes les 2 à 4 s pour chaque Survivant. Touché = étourdi 2 s, jamais éliminé.
- **Mine (règle a06, codée par a09) :** 1 gemme toutes les 20 s par Survivant actif, stock 6 (2 min), lueur cyan pulsée quand elle est pleine. Le premier qui la touche la vide pour toute l'équipe : y aller rend service.
- **Rythme des 80 s :** Marcheurs aux salves de 0 et 10 s, croisière jusqu'à 50 s, vedette du jour à 60 et 70 s, arrêt des apparitions à 72 s, éclatement **sans butin** à 80 s.
- **Jour parfait** *(soumis à Victor)* : tout vaincre avant 80 s ou, au Jour du Colosse, l'abattre avant sa colère. Bonus : 25 % des Pièces gagnées dans le jour, versées par `Economie.ajouterPieces` (≈ 12 au J1, 60 au J5, 140 au J9), et bannière Or. Il paie un 2e achat au Répit, quel que soit le jour.

## 3. Table des jours : `ZbiresDefs.JOURS`

Seule cette table bouge en playtest. HordeService (a26) la lit ainsi :
- **PV** = base × `pv` × coop du canon, avec `pv` = 1,15^(jour − 1) × 1,3^max(0, jour − 10). La Tension y est déjà : HordeService ne la réapplique pas et elle ne grossit pas les paquets. L'attribut `Tension` sert au HUD et à la Météo.
- **Salves** toutes les 10 s, de 0 à 70 s. Quota cumulé = `zbires` ÷ 8 par salve, découpé en paquets de 3 à 5 Zbires du même type, au plus un par portail actif. Le reste passe à la salve suivante.
- **Portails** tirés au début du jour : J1-3, un parmi Est, Ouest et Nord (jamais le Sud) ; J4-8, deux ; J9-11, trois ; J12-15, quatre, parmi les 8 (Sud et diagonales permis).
- **Dorés** seuls, à la salve de 40 s. Dorés et Mini-Gluants hors quota. Au-delà de 60 Zbires, les suivants attendent ; ceux qui ne sont pas sortis à 72 s sont annulés.
- **Colosse :** 2 500 × 1,15^(jour − 1) PV avant coop, sans Tension (≈ 45 s de combat en solo au J5).

```lua
--!strict
-- ReplicatedStorage.ZbiresDefs.Jours (ModuleScript). Dans ZbiresDefs : JOURS = require(script.Jours)
export type Jour = {
	pv: number, zbires: number, portails: number, choix: { string },
	vedette: string, dores: number, colosse: number?,
}

local CHEMINS = { "Est", "Ouest", "Nord" }
local TOUS = { "Nord", "Sud", "Est", "Ouest", "NordEst", "NordOuest", "SudEst", "SudOuest" }

-- { pv (Tension comprise), zbires avant coop, portails, vedette, dorés, PV du Colosse }
local BRUT: { { any } } = {
	{ 1.00, 25, 1, "Marcheur", 0 },
	{ 1.15, 32, 1, "Rapide", 0 },
	{ 1.32, 39, 1, "Rapide", 1 },
	{ 1.52, 46, 2, "Costaud", 1 },
	{ 1.75, 53, 2, "Costaud", 1, 4373 },
	{ 2.01, 60, 2, "Sauteur", 1 },
	{ 2.31, 67, 2, "Gluant", 1 },
	{ 2.66, 74, 2, "Volant", 1 },
	{ 3.06, 81, 3, "Casqué", 1 },
	{ 3.52, 88, 3, "Gluant", 2, 8795 },
	{ 5.26, 95, 3, "Volant", 2 },
	{ 7.86, 102, 4, "Casqué", 2 },
	{ 11.75, 109, 4, "Sauteur", 2 },
	{ 17.57, 116, 4, "Costaud", 2 },
	{ 26.27, 123, 4, "Casqué", 2, 17689 },
}

local JOURS: { Jour } = {}
for jour, l in BRUT do
	JOURS[jour] = {
		pv = l[1], zbires = l[2], portails = l[3], vedette = l[4], dores = l[5], colosse = l[6],
		choix = if jour <= 3 then CHEMINS else TOUS,
	}
end
return table.freeze(JOURS)
```

## 4. Boucle de 5 minutes : 3 jours, 3 achats, 1 menace

1. **Répit (15 s) :** l'Établi, collé à la façade de la Maison, s'ouvre par `ProximityPrompt` (`MaxActivationDistance` 14, `HoldDuration` 0). Cible : 1 achat par Répit, 2 après un Jour parfait. Les 3 défenses se reprennent gratuitement.
2. **Menace :** bandeau « Colosse dans X jours ». Dès le Répit qui précède (`JourColosse`), MeteoServeur passe au couchant (`ClockTime` 17,5) ; 3 s avant l'entrée, une flèche Alerte pointe vers `ColosseAngle`.
3. **Sans chat :** au Répit, un `BillboardGui` montre les 3 meilleures améliorations de chaque Survivant.
4. **Découverte :** carte de 2 s (silhouette + règle) à la première apparition d'un type dans la run.

| Jour | Nouveau | Leçon → recherche désirée |
|---|---|---|
| 1 | Marcheur | tirer, ramasser |
| 2 | Rapide | se placer tôt |
| 3 | Doré | le chasser → Foreuse |
| 4 | Costaud | Dégâts, Mini-Tourelle → Balles perforantes |
| 5 | **Colosse** | ping « Colosse ! » → Tourelle de toit |
| 6 | Sauteur | anticiper ses bonds |
| 7 | Gluant | finir les Mini-Gluants → Balles perforantes |
| 8 | Volant | survole les Murets : Portée → Tourelle de toit |
| 9 | Casqué | seuls les critiques percent → Visée critique |

## 5. Session et retour du lendemain

- **Parcours :** Laboratoire (Foreuse, Défi du Jour, Alcôves voisines) → Capsule (départ 15 s) → run 1 → 4 min au Laboratoire (recherche, machine animée, Galerie) → run 2, souvent Capsule du Jour → panneau « Demain ».
- **Écran de fin (8 s, passable) :** « La Maison est tombée au Jour X », « Victoire : 15 jours tenus ! » ou « Temps écoulé : la Maison tient toujours ! ». Puis Record, gemmes (déjà sauvegardées), Zbire qui a le plus abîmé la Maison → recherche conseillée, « Plus que N gemmes ».
- **Gemmes : barème unique a07**, via `Economie.franchirJour(jour)` : 5 + 2 × min(N, 15), doublé aux J5, J10 et J15, anti-AFK compris. S'y ajoutent Mine, Doré, Foreuse et Défi du Jour. 1re recherche à 40 gemmes : acquise dès le J4 franchi (7 + 9 + 11 + 13).
- **Sans marathon :** Capsule Difficile ouverte au Record Jour 10 en Normale, seule condition. Les J11 à J15 font un mur sous les 25 min.
- **Objectifs :** la run (Jour parfait, Colosse, Record), la semaine (4 recherches, paliers 10 et 100 de la Galerie, Difficile), le mois (paliers 1 000, Alcôve complète, Zbire de la Semaine).
- **Demain :** Foreuse pleine en 8 h, Défi du Jour (150 gemmes, minuit heure de Paris), panneau « Demain » (écart vers la recherche, heure de Foreuse pleine, samedi 17 h). Aucune série punitive, aucun minuteur payant, aucun message culpabilisant.

## 6. Contrat `EtatRun` et code serveur

`BoucleDuJour` n'écrit que dans le `Folder` `ReplicatedStorage.EtatRun` (contrat a28, lu par le HUD a32). Le ciel revient à MeteoServeur (a18).

| Attribut | Valeur |
|---|---|
| `Jour` | 1 dès l'Arrivée, puis à chaque horde |
| `Phase`, `FinPhase` | `Arrivee`, `Horde`, `Repit` ; fin en `GetServerTimeNow` (Jour du Colosse : sa colère, puis « COLÈRE ! ») |
| `JourColosse` | du Répit qui précède J5, J10 ou J15 jusqu'à sa chute |
| `ColosseActif` | de l'entrée à la chute |
| `Tension` | max(0, jour − 10) |
| `ColosseAngle` | 3 s avant l'entrée ; degrés depuis la Maison, 0 = Nord (−Z), 90 = Est (+X) |
| `JourParfait` | fin de chaque jour *(ajout au contrat a28)* |

```lua
--!strict
-- ServerScriptService.Run.BoucleDuJour (ModuleScript, place Prairie)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JOURS = require(ReplicatedStorage.ZbiresDefs).JOURS
local EtatRun = ReplicatedStorage:WaitForChild("EtatRun") :: Folder

export type Horde = {
	demarrer: (jour: number) -> (), -- lit JOURS[jour]
	stopperApparitions: () -> (),
	toutVaincu: () -> boolean, -- file d'attente comprise
	lancerColosse: (pv: number) -> (), -- Grand Portail Nord, coop appliquée par a26
	colosseVivant: () -> boolean,
	enragerColosse: () -> (), -- vitesse × 1,5, dégâts sur la Maison × 3
	vider: () -> (), -- stoppe tout, éclatement sans butin
}
export type Deps = {
	Economie: {
		franchirJour: (jour: number) -> (),
		ajouterPieces: (joueur: Player, montant: number) -> (),
		piecesGagnees: (joueur: Player) -> number, -- cumul de run, achats non déduits
	},
	Meteo: {
		demarrerRun: () -> (),
		planifierJour: (jour: number, colosse: boolean) -> (),
		debutJour: (jour: number, colosse: boolean) -> (),
	},
	Telemetrie: { fermerJour: (jour: number, bilan: { [string]: any }) -> () },
}

local ARRIVEE, HORDE, FIN_APPARITIONS, REPIT = 20, 80, 72, 15
local ENTREE_COLOSSE, ALERTE, COLERE = 40, 3, 60
local LIMITE_RUN, PART_PARFAIT, DEBUT_TENSION = 25 * 60, 0.25, 10

local function phase(nom: string, duree: number)
	EtatRun:SetAttribute("Phase", nom)
	EtatRun:SetAttribute("FinPhase", workspace:GetServerTimeNow() + duree)
end

local function colosseParti()
	EtatRun:SetAttribute("ColosseActif", false)
	EtatRun:SetAttribute("ColosseAngle", nil)
end

local BoucleDuJour = {}

-- Renvoie le jour atteint et l'issue : "Maison", "Limite" ou "Victoire".
function BoucleDuJour.lancer(maison: Model, grandPortail: PVInstance, horde: Horde, deps: Deps): (number, string)
	local limite = os.clock() + LIMITE_RUN
	local debout = true
	local connexion = maison:GetAttributeChangedSignal("PV"):Connect(function()
		if (maison:GetAttribute("PV") or 0) <= 0 then
			debout = false
		end
	end)
	local function actif(): boolean
		return debout and os.clock() < limite
	end
	local function attendre(duree: number)
		local t = 0
		while actif() and t < duree do
			t += task.wait(0.1)
		end
	end
	local avant: { [Player]: number } = {}
	local function photographier()
		table.clear(avant)
		for _, joueur in Players:GetPlayers() do
			avant[joueur] = deps.Economie.piecesGagnees(joueur)
		end
	end
	local d = grandPortail:GetPivot().Position - maison:GetPivot().Position
	local angle = math.deg(math.atan2(d.X, -d.Z))

	deps.Meteo.demarrerRun()
	EtatRun:SetAttribute("Jour", 1)
	EtatRun:SetAttribute("Tension", 0)
	EtatRun:SetAttribute("JourColosse", false)
	EtatRun:SetAttribute("JourParfait", false)
	colosseParti()
	deps.Meteo.planifierJour(1, false)
	phase("Arrivee", ARRIVEE)
	photographier()
	attendre(ARRIVEE)

	local jour, ouvert, victoire = 0, false, false
	while actif() do
		jour += 1
		local pvColosse = JOURS[jour].colosse
		local colosse = pvColosse ~= nil
		EtatRun:SetAttribute("Jour", jour)
		EtatRun:SetAttribute("Tension", math.max(0, jour - DEBUT_TENSION))
		EtatRun:SetAttribute("JourColosse", colosse)
		EtatRun:SetAttribute("JourParfait", false)
		deps.Meteo.debutJour(jour, colosse)
		phase("Horde", if colosse then ENTREE_COLOSSE + COLERE else HORDE)
		horde.demarrer(jour)
		ouvert = true

		local t, arrete, entre, enrage = 0, false, false, false
		while actif() do
			if not arrete and t >= FIN_APPARITIONS then
				horde.stopperApparitions()
				arrete = true
			end
			if pvColosse and not entre and t >= ENTREE_COLOSSE - ALERTE then
				EtatRun:SetAttribute("ColosseAngle", angle)
				if t >= ENTREE_COLOSSE then
					horde.lancerColosse(pvColosse)
					EtatRun:SetAttribute("ColosseActif", true)
					entre = true
				end
			end
			if entre and not enrage and t >= ENTREE_COLOSSE + COLERE then
				horde.enragerColosse()
				enrage = true
			end
			if (entre and not horde.colosseVivant()) or (not colosse and t >= HORDE) then
				break
			end
			t += task.wait(0.1)
		end
		if not actif() then
			break
		end

		local parfait = if colosse then not enrage else horde.toutVaincu()
		horde.vider()
		colosseParti()
		deps.Economie.franchirJour(jour)
		if parfait then
			for _, joueur in Players:GetPlayers() do
				local base = avant[joueur]
				local bonus = if base then math.floor((deps.Economie.piecesGagnees(joueur) - base) * PART_PARFAIT) else 0
				if bonus > 0 then
					deps.Economie.ajouterPieces(joueur, bonus)
				end
			end
		end
		photographier()
		EtatRun:SetAttribute("JourParfait", parfait)
		deps.Telemetrie.fermerJour(jour, { issue = "franchi", parfait = parfait, duree = t })
		ouvert = false
		if jour >= #JOURS then
			victoire = true
			break
		end
		local suivant = JOURS[jour + 1].colosse ~= nil
		EtatRun:SetAttribute("JourColosse", suivant)
		deps.Meteo.planifierJour(jour + 1, suivant)
		phase("Repit", REPIT)
		attendre(REPIT)
	end

	connexion:Disconnect()
	horde.vider()
	colosseParti()
	local issue = if victoire then "Victoire" elseif debout then "Limite" else "Maison"
	if ouvert then
		deps.Telemetrie.fermerJour(jour, { issue = issue, parfait = false })
	end
	return jour, issue
end

return BoucleDuJour
```

Un `Script` de `ServerScriptService` appelle `BoucleDuJour.lancer(workspace.Maison, workspace.Lisiere.GrandPortailNord, Horde, { Economie = Economie, Meteo = MeteoServeur, Telemetrie = Telemetrie })` quand tous les Survivants sont arrivés, affiche l'écran de fin selon l'issue, met à jour le Record Normale, puis renvoie au Laboratoire. Les clients lisent `EtatRun` et n'envoient que des demandes.
