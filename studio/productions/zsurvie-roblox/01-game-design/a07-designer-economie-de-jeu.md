## 1. Règles de base

- **Deux monnaies (canon).** Les **Pièces** sont propres à chaque Survivant. Elles vivent en mémoire serveur et s'affichent par l'attribut `Pieces` du `Player`. Elles sont perdues quand la Maison tombe. Les **Gemmes** sont permanentes et passent uniquement par `Donnees.AjouterGemmes` et `Donnees.CrediterRun` (`UpdateAsync` à chaque jour franchi).
- **Une seule table de chiffres :** `ReplicatedStorage.Catalogue` (§7), lue par `Economie`, `Donnees`, l'UI et l'onboarding. Le `CATALOGUE` et `AcheterAmelioration` de a33 sont supprimés. a06 et a09 retirent leurs chiffres.
- **Un seul handler :** `Economie` (§8) traite `DemandeAchat(cle, niveauVise)`, la cagnotte, ainsi que le paiement et la reprise des défenses.
- **Interdit :** une 3e monnaie, toute conversion de Pièces en Gemmes, la vente de Gemmes en Robux.

## 2. Sources et puits

| Flux | Règle | Valeur (Catalogue) |
|---|---|---|
| + Pièces | Zbire éliminé, butin instancié | `PIECES_PAR_ZBIRE` × (1 + 0,12 × (jour − 1)) × (1 + 0,10 × Butin) ÷ (1 + 0,2 × (actifs − 1)) |
| + Pièces | Aimant serveur de 8 studs, 20 s au sol. Ce qui n'est pas ramassé est versé au début du Répit (« +X » gris) | 50 %, soit ≈ 85 % du butin encaissé |
| + Pièces | Jour parfait, via `ajouterPieces` | 25 % des Pièces du jour |
| + Pièces | Reprise d'une défense | 50 % du prix payé |
| − Pièces | Établi individuel : Dégâts, Cadence, Portée, Butin (niv. 5 max), Balles explosives | base × 1,45^(niv − 1), niv. 10 max |
| − Pièces | Cagnotte d'équipe : Solidité, Réparation, Régénération | même prix × (0,5 + 0,5 × joueurs) |
| − Pièces | Défenses (3 posées max) : Muret 15, Tapis Collant 25, Mini-Tourelle 60 | × (1 + 0,15 × (jour − 1)) |
| + Gemmes | Jour franchi | 5 + 2 × min(jour, 15), doublé aux J5, J10 et J15 |
| + Gemmes | Mine commune : 1 gemme toutes les 20 s, stock de 6. Au contact d'un Survivant, le stock est versé à chaque Survivant actif | ≈ 3 par minute |
| + Gemmes | Doré : 1 par jour dès le J3, 2 par jour dès le J8 | 4 par Survivant (+ 10 Pièces) |
| + Gemmes | Foreuse hors connexion, 8 h max | 5, 9, 14, 20, 27 par heure |
| + Gemmes | Défi du Jour, après le 1er Colosse repoussé, clé `Transactions.cleJourParis` | 150 |
| + Gemmes | Plancher de la 1re run terminée | 40 minimum |
| − Gemmes | Recherches | base × 1,7^(niv − 1) |

Pièces par Zbire : Marcheur 2, Rapide 2, Sauteur 3, Volant 3, Gluant 3, Mini-Gluant 1, Costaud 5, Casqué 5, Doré 10, Colosse 150. Le Colosse repoussé n'a pas de bonus propre : son jour franchi est doublé. Le Zbire de la Semaine n'a pas de source de gemmes propre.

## 3. Établi, défenses et Maison

| Ligne (base) | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 10 |
|---|---|---|---|---|---|---|---|---|
| Dégâts (10) | 10 | 15 | 20 | 30 | 45 | 65 | 135 | 285 |
| Portée, Réparation (20) | 20 | 30 | 40 | 60 | 90 | 130 | 270 | 565 |
| Cadence (25) | 25 | 35 | 55 | 75 | 110 | 160 | 335 | 710 |
| Solidité, Butin (30) | 30 | 45 | 65 | 90 | 135 | 190 | 405 | 850 |
| Régénération (40) | 40 | 60 | 85 | 120 | 175 | 255 | 540 | 1 135 |
| Balles explosives (60) | 60 | 85 | 125 | 185 | 265 | 385 | 810 | 1 700 |

- **Premier achat :** Dégâts 1 coûte 10 Pièces, soit 5 Marcheurs (6 à 85 % de ramassage). L'achat tient avant T 70 s (a10). *Écart à la consigne (base 25), qui lève le bloquant QA.*
- **Cumuls par Survivant** à 85 % de ramassage, hors Butin et Jour parfait : 780 au J5, 1 275 au J7, 2 700 au J10, 3 740 au J12 et 6 200 au J15, identiques de 1 à 6 joueurs. Tout l'Établi coûte ≈ 18 600 en solo. On en finance un tiers au J15, ce qui pousse à se spécialiser.
- **Cagnotte :** chacun paie 70 % du prix à 2,5 joueurs et 58 % à 6. Un tap verse ce qui manque, dans la limite du solde. Le niveau monte dès que la cagnotte atteint le prix, et le surplus reste pour le niveau suivant.
- **Défenses :** le prix est arrondi à l'unité et stocké dans l'attribut `PrixPaye`. Muret : 150 × 1,15^(jour − 1) PV (262 au J5, 528 au J10). Mini-Tourelle : 50 % des dégâts du Blaster de son poseur.
- **Maison :** 1 000 PV × (1 + 0,12 × Solidité). La réparation rend 1,5 % × (1 + 0,25 × niv) × (1 + 0,5 × (réparateurs − 1)) des PV max par seconde, avec 3 réparateurs comptés au plus : 15 PV/s seul au niveau 0, 30 PV/s à trois.
- L'Établi est à moins de 6 s de course de la Maison, pour tenir dans le Répit de 15 s.

## 4. Recherches (Gemmes)

| Ligne | Niv. 1 à 5 | Niv. 10 | Total | Effet (à caler avec le combat) |
|---|---|---|---|---|
| Tourelle de toit | 40, 70, 115, 195, 335 | 4 745 | 11 465 | Portée 35 studs, puis + 25 % de dégâts par niveau |
| Visée critique | 70, 120, 200, 345, 585 | 8 300 | 20 060 | 9 % de critiques (× 2), + 4 points par niveau |
| Balles perforantes | 80, 135, 230, 395, 670 | 9 485 | 22 925 | Traversent 1 Zbire : 50 % au 2e, + 10 points par niveau |
| Foreuse (5 niv.) | 100, 170, 290, 490, 835 | — | 1 885 | 5, 9, 14, 20, 27 gemmes/h (40 à 216 par nuit) |

L'arbre coûte ≈ 56 300 gemmes (≈ 45 h), soit la 6e semaine, comme le niveau 30 de a08. La Tourelle de toit 1 coûte 40 gemmes, le plancher : Doc Boulon peut toujours la faire acheter. Règle de réglage : la recherche la moins chère coûte entre 0,8 et 1,5 session de gains.

## 5. Courbe de gains (5 premières heures)

**Hypothèses :**
- **Coop :** 2,5 Survivants en moyenne. La horde (× 1,3 Zbires, × 1,525 PV) pèse × 1,98 face à un DPS × 2,5 : on tient ≈ 1 jour de plus qu'en solo.
- **Rythme :** 1 h par jour en 2 sessions. On ramasse 90 % de la Mine et on élimine 75 % des Dorés.
- **Défi du Jour :** débloqué dès la 1re run.
- **Bonus de run :**
  - Filon et Panier (a15) : + 10 % des gemmes de run.
  - Capsule Difficile : + 50 %. Hypothèse : ouverte au Record J10, chute 2 jours plus tôt.
  - Week-end (a49) : + 100 % sur les gemmes de run.
  - Ces bonus s'additionnent : × 2,5 au plus.
- **Foreuse :** pleine 1 fois par jour. Hypothèse : Turbo (a08) × 1,25 en moyenne.

| Chute au | J5 | J6 | J7 | J8 | J9 | J10 | J11 | J12 |
|---|---|---|---|---|---|---|---|---|
| Jours franchis | 40 | 70 | 87 | 106 | 127 | 150 | 200 | 227 |
| Mine + Dorés | 25 | 32 | 39 | 47 | 57 | 67 | 78 | 88 |
| **Gemmes par Survivant** | 65 | 102 | 126 | 153 | 184 | 217 | 278 | 315 |

**Cible publiée d'une 1re run au J6 : 112 gemmes**, soit 102 + ≈ 10 de a15. La fourchette H7/H8 va de 95 à 130 gemmes. Un week-end, la cible passe à 224, et jamais moins de 40. Doc Boulon fait acheter la Tourelle de toit 1 et la Visée critique 1 (110).

| Heure | Runs (chute) | Run + a15 | Défi | Foreuse | Total | Si week-end | Cumul | Recherches |
|---|---|---|---|---|---|---|---|---|
| 1 | J6, J7, J7, J8 | 558 | 150 | — | 708 | 1 266 | 708 | 7 |
| 2 | J8, J9, J9 | 573 | 150 | 50 | 773 | 1 346 | 1 481 | 11 |
| 3 | J9, J10, J10 | 680 | 150 | 90 | 920 | 1 600 | 2 401 | 14 |
| 4 | J10, J11, Difficile J9 | 848 | 150 | 140 | 1 138 | 1 885 | 3 539 | 17 |
| 5 | J11, J11, Difficile J10 | 970 | 150 | 200 | 1 320 | 2 170 | 4 859 | 19 |

Les gains par heure sont multipliés par 1,86, le prix de la prochaine recherche par 17 (de 40 à 670). On passe de 7 achats la 1re heure à 1 achat par session. Un joueur qui enchaîne 5 h d'affilée gagne 3 780 gemmes, soit 22 % de moins : revenir chaque jour rapporte plus, sans pénaliser les longues sessions.

## 6. Garde-fous

1. **Remise à zéro :** les Pièces sont perdues à chaque run. Les prix montent de 45 % par niveau, les gains de 12 % par jour.
2. **Fin de run garantie :** la Maison tombe entre J11 et J15, soit 22,8 min au plus. Si la médiane dépasse J15, on corrige les PV des Zbires, jamais les gains.
3. **Plafond :** les gemmes du jour franchi n'augmentent plus après J15. Une run rapporte ≈ 520 gemmes de base au maximum, bonus additifs compris.
4. **Coop bornée (correction QA) :**
   - HordeService multiplie les Zbires par jour par (1 + 0,2 × (actifs − 1)).
   - Les Pièces par Zbire sont divisées par ce même facteur. La fraction est conservée côté serveur, donc le revenu par Survivant est identique à tout effectif.
   - Bonus : ≈ + 1 jour à 2 ou 3 joueurs, + 0,6 jour à 6.
5. **Activité unique :**
   - `Economie.marquerActif` et `Economie.estActif`, aussi appelés par a08 (XP) et a14 (coop).
   - Ce qui compte : 4 studs de déplacement cumulé, une réparation, une pose, un ping ou un tap de ciblage. Le tir automatique est exclu.
   - Fenêtre de 90 s. À 75 s, l'attribut `Inactif` déclenche un « Zzz » et un bip.
   - Les gemmes refusées alimentent `GemmesInactif`. L'écran de fin affiche la ligne « Inactif : X gemmes non versées ».
   - H3 vérifie qu'aucun joueur réellement actif n'est pénalisé.
6. **Horloges serveur :**
   - La Foreuse lit `os.time()` et reste plafonnée à 8 h.
   - Le Défi du Jour, le Calendrier et les secrets se remettent à zéro sur `Transactions.cleJourParis`, à minuit heure de Paris. Le 0 h UTC est abandonné.
7. **Idempotence :** `CrediterRun` écrit le cumul de la run, avec `runId` = `game.JobId`.
8. **Robux :** ils n'achètent que des cosmétiques et des serveurs privés, où les gains sont les mêmes.
9. **Suivi :** `AnalyticsService:LogEconomyEvent` est appelé à chaque achat (Economie) et à chaque crédit de gemmes (Donnees). Alerte si le stock médian dépasse 2 fois le prochain prix.

## 7. `ReplicatedStorage.Catalogue`

```lua
--!strict
-- ReplicatedStorage > Catalogue (ModuleScript). Seule table de chiffres de Zsurvie.
local Catalogue = {}

Catalogue.ETABLI = {
	CROISSANCE = 1.45, RAYON_ACHAT = 14,
	BASES = { Degats = 10, Cadence = 25, Portee = 20, Reparation = 20, Solidite = 30,
		Butin = 30, Regeneration = 40, BallesExplosives = 60 } :: { [string]: number },
	NIVEAU_MAX = { Butin = 5 } :: { [string]: number }, -- 10 sinon
	PARTAGEES = { Solidite = true, Reparation = true, Regeneration = true } :: { [string]: boolean },
}
Catalogue.DEFENSES = {
	PRIX = { Muret = 15, TapisCollant = 25, MiniTourelle = 60 } :: { [string]: number },
	HAUSSE_JOUR = 0.15, REPRISE = 0.5, MAX_POSEES = 3,
	MURET_PV = 150, MURET_CROISSANCE = 1.15, TOURELLE_PART_BLASTER = 0.5,
}
Catalogue.PIECES_PAR_ZBIRE = { Marcheur = 2, Rapide = 2, Sauteur = 3, Volant = 3, Gluant = 3,
	MiniGluant = 1, Costaud = 5, Casque = 5, Dore = 10, Colosse = 150 } :: { [string]: number }
Catalogue.PIECES = { HAUSSE_JOUR = 0.12, BUTIN_NIVEAU = 0.10, AIMANT = 8, DUREE_SOL = 20,
	ASPIRATION_REPIT = 0.5, JOUR_PARFAIT = 0.25 }
Catalogue.GEMMES = { JOUR_BASE = 5, JOUR_PENTE = 2, JOUR_PLAFOND = 15, MINE_PERIODE = 20,
	MINE_STOCK = 6, MINE_CONTACT = 7, DORE = 4, DORE_DES_JOUR = 3, DORE_DOUBLE_DES_JOUR = 8,
	PLANCHER_PREMIERE_RUN = 40, DEFI_DU_JOUR = 150, BONUS_DIFFICILE = 0.5, BONUS_WEEKEND = 1 }
Catalogue.RECHERCHES = {
	CROISSANCE = 1.7, FOREUSE_PAR_HEURE = { 5, 9, 14, 20, 27 }, FOREUSE_HEURES_MAX = 8,
	LIGNES = { TourelleDeToit = { base = 40, max = 10 }, ViseeCritique = { base = 70, max = 10 },
		BallesPerforantes = { base = 80, max = 10 }, Foreuse = { base = 100, max = 5 },
	} :: { [string]: { base: number, max: number } },
}
Catalogue.MAISON = { PV = 1000, SOLIDITE_NIVEAU = 0.12, REPARATION = 0.015,
	REPARATION_NIVEAU = 0.25, REPARATEUR_EN_PLUS = 0.5, REPARATEURS_MAX = 3 }
Catalogue.COOP = { PV_ZBIRE = 0.35, ZBIRES_JOUR = 0.2 }
Catalogue.ACTIVITE = { FENETRE = 90, ALERTE = 75, DEPLACEMENT = 4 }

local function arrondi5(x: number): number
	return math.floor(x / 5 + 0.5) * 5
end

function Catalogue.prixEtabli(cle: string, niveau: number, joueurs: number): number?
	local base = Catalogue.ETABLI.BASES[cle]
	if base == nil or niveau < 1 or niveau % 1 ~= 0 or niveau > (Catalogue.ETABLI.NIVEAU_MAX[cle] or 10) then
		return nil
	end
	local prix = arrondi5(base * Catalogue.ETABLI.CROISSANCE ^ (niveau - 1))
	return if Catalogue.ETABLI.PARTAGEES[cle] then arrondi5(prix * (0.5 + 0.5 * math.max(joueurs, 1))) else prix
end

function Catalogue.prixDefense(cle: string, jour: number): number?
	local base = Catalogue.DEFENSES.PRIX[cle]
	return if base then math.floor(base * (1 + Catalogue.DEFENSES.HAUSSE_JOUR * (jour - 1)) + 0.5) else nil
end

function Catalogue.prixRecherche(cle: string, niveau: number): number?
	local ligne = Catalogue.RECHERCHES.LIGNES[cle]
	if ligne == nil or niveau < 1 or niveau > ligne.max then
		return nil
	end
	return arrondi5(ligne.base * Catalogue.RECHERCHES.CROISSANCE ^ (niveau - 1))
end

function Catalogue.gemmesJour(jour: number): number
	local g = Catalogue.GEMMES
	local gain = g.JOUR_BASE + g.JOUR_PENTE * math.min(jour, g.JOUR_PLAFOND)
	return if jour % 5 == 0 and jour <= g.JOUR_PLAFOND then gain * 2 else gain
end

function Catalogue.facteurHorde(actifs: number): number
	return 1 + Catalogue.COOP.ZBIRES_JOUR * (math.max(actifs, 1) - 1)
end

function Catalogue.pvMaison(solidite: number): number
	return Catalogue.MAISON.PV * (1 + Catalogue.MAISON.SOLIDITE_NIVEAU * solidite)
end

function Catalogue.reparationParSeconde(niveau: number, reparateurs: number, pvMax: number): number
	local m = Catalogue.MAISON
	local n = math.clamp(reparateurs, 1, m.REPARATEURS_MAX)
	return pvMax * m.REPARATION * (1 + m.REPARATION_NIVEAU * niveau) * (1 + m.REPARATEUR_EN_PLUS * (n - 1))
end

function Catalogue.pvMuret(jour: number): number
	return math.floor(Catalogue.DEFENSES.MURET_PV * Catalogue.DEFENSES.MURET_CROISSANCE ^ (jour - 1) + 0.5)
end

return table.freeze(Catalogue)
```

## 8. `ServerScriptService.Economie` (place Prairie)

**Appels attendus :**
- Directeur de run : `debutJour` (renvoie le facteur de horde à HordeService), `debutRepit(jourParfait)`, `franchirJour(jour)`, `finDeRun`.
- HordeService : `lacherButin`.
- Handlers de réparation, de pose, de ping et de ciblage : `marquerActif`.
- DemandePose : `payerDefense` et `reprendreDefense`.

```lua
--!strict
-- Seul script qui crédite ou débite des Pièces. Toute gemme de run passe par Donnees.
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local C = require(ReplicatedStorage.Catalogue)
local Donnees = require(ServerScriptService.Donnees)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DemandeAchat = Remotes:WaitForChild("DemandeAchat") :: RemoteEvent
local GainPieces = Remotes:WaitForChild("GainPieces") :: RemoteEvent
local Butin = Remotes:WaitForChild("Butin") :: RemoteEvent
local ButinRetire = Remotes:WaitForChild("ButinRetire") :: RemoteEvent
local Mine = workspace:WaitForChild("Mine") :: Model
local Etabli = workspace:WaitForChild("Etabli") :: Model

type Piece = { valeur: number, pos: Vector3, ne: number }
type Etat = { pieces: number, piecesJour: number, reliquat: number, fraction: number, perdues: number,
	niveaux: { [string]: number }, sol: { [number]: Piece }, derniereAction: number,
	derniereDemande: number, dernierePos: Vector3?, cumul: number }

local etats: { [Player]: Etat } = {}
local niveauxEquipe: { [string]: number } = {}
local cagnotte: { [string]: number } = {}
local EtatEquipe = Instance.new("Folder")
EtatEquipe.Name = "EtatEquipe"
EtatEquipe.Parent = ReplicatedStorage
local enRun, facteurHorde, stockMine, horlogeMine, prochainId = false, 1, 0, 0, 0
local Economie = {}

local function racine(joueur: Player): BasePart?
	local perso = joueur.Character
	return if perso then perso:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
end

local function crediter(joueur: Player, e: Etat, montant: number, gain: boolean, gris: boolean)
	if montant <= 0 then return end
	e.pieces += montant
	if gain then e.piecesJour += montant end
	joueur:SetAttribute("Pieces", e.pieces)
	GainPieces:FireClient(joueur, montant, gris)
end

local function debiter(joueur: Player, e: Etat, montant: number, article: string)
	e.pieces -= montant
	joueur:SetAttribute("Pieces", e.pieces)
	AnalyticsService:LogEconomyEvent(joueur, Enum.AnalyticsEconomyFlowType.Sink, "Pieces",
		montant, e.pieces, Enum.AnalyticsEconomyTransactionType.Shop.Name, article)
end

-- Seule définition de « Survivant actif » (a07, a08, a14). Jamais appelé par le tir automatique.
function Economie.marquerActif(joueur: Player)
	local e = etats[joueur]
	if e then
		e.derniereAction, e.cumul = os.clock(), 0
		if joueur:GetAttribute("Inactif") then joueur:SetAttribute("Inactif", false) end
	end
end

function Economie.estActif(joueur: Player): boolean
	local e = etats[joueur]
	return e ~= nil and os.clock() - e.derniereAction < C.ACTIVITE.FENETRE
end

function Economie.nombreActifs(): number
	local n = 0
	for joueur in etats do
		if Economie.estActif(joueur) then n += 1 end
	end
	return math.max(n, 1)
end

function Economie.gagnerGemmes(joueur: Player, montant: number, source: string)
	local e = etats[joueur]
	if e == nil or montant <= 0 then return end
	if Economie.estActif(joueur) then
		Donnees.AjouterGemmes(joueur, montant, source)
	else
		e.perdues += montant
		joueur:SetAttribute("GemmesInactif", e.perdues) -- ligne « inactif » de l'écran de fin
	end
end

function Economie.prixEtabli(cle: string, niveau: number): number?
	return C.prixEtabli(cle, niveau, #Players:GetPlayers())
end

function Economie.ajouterPieces(joueur: Player, montant: number)
	local e = etats[joueur]
	if e then crediter(joueur, e, math.floor(montant), false, false) end
end

-- Butin instancié. Plus de Zbires en coop, chacun vaut moins : revenu par Survivant constant.
function Economie.lacherButin(typeZbire: string, position: Vector3, jour: number)
	local base = C.PIECES_PAR_ZBIRE[typeZbire]
	if base == nil or not enRun then return end
	for joueur, e in etats do
		local butin = math.min(e.niveaux.Butin or 0, 5)
		e.fraction += base * (1 + C.PIECES.HAUSSE_JOUR * (jour - 1)) * (1 + C.PIECES.BUTIN_NIVEAU * butin) / facteurHorde
		local valeur = math.floor(e.fraction)
		if valeur >= 1 then
			e.fraction -= valeur
			prochainId += 1
			e.sol[prochainId] = { valeur = valeur, pos = position, ne = os.clock() }
			Butin:FireClient(joueur, prochainId, position, valeur)
		end
		if typeZbire == "Dore" then Economie.gagnerGemmes(joueur, C.GEMMES.DORE, "Dore") end
	end
end

function Economie.payerDefense(joueur: Player, cle: string, jour: number): number?
	local e = etats[joueur]
	local prix = C.prixDefense(cle, jour)
	if e == nil or prix == nil or e.pieces < prix then return nil end
	debiter(joueur, e, prix, cle)
	return prix -- à écrire dans l'attribut PrixPaye de la défense
end

function Economie.reprendreDefense(joueur: Player, prixPaye: number)
	local e = etats[joueur]
	if e then crediter(joueur, e, math.floor(prixPaye * C.DEFENSES.REPRISE), false, false) end
end

local function acheter(joueur: Player, cle: unknown, niveauVise: unknown)
	local e = etats[joueur]
	local maintenant = os.clock()
	if e == nil or typeof(cle) ~= "string" or typeof(niveauVise) ~= "number"
		or maintenant - e.derniereDemande < 0.2 then return end
	e.derniereDemande = maintenant
	local r = racine(joueur)
	if r == nil or (r.Position - Etabli:GetPivot().Position).Magnitude > C.ETABLI.RAYON_ACHAT then return end
	local partagee = C.ETABLI.PARTAGEES[cle] == true
	local niveaux = if partagee then niveauxEquipe else e.niveaux
	if niveauVise ~= (niveaux[cle] or 0) + 1 then return end -- un double tap n'achète pas 2 fois
	local prix = Economie.prixEtabli(cle, niveauVise)
	if prix == nil then return end
	if not partagee then
		if e.pieces < prix then return end
		debiter(joueur, e, prix, cle)
		e.niveaux[cle] = niveauVise
		joueur:SetAttribute("Niv_" .. cle, niveauVise)
		return
	end
	-- Cagnotte : un tap verse ce qui manque, dans la limite du solde.
	local verse = math.min(math.max(prix - (cagnotte[cle] or 0), 0), e.pieces)
	if verse > 0 then debiter(joueur, e, verse, cle) end
	local total = (cagnotte[cle] or 0) + verse
	if total >= prix then
		total -= prix
		niveauxEquipe[cle] = niveauVise
		EtatEquipe:SetAttribute("Niv_" .. cle, niveauVise)
	end
	cagnotte[cle] = total
	EtatEquipe:SetAttribute("Cagnotte_" .. cle, total)
end

local function suivreActivite(joueur: Player, e: Etat, maintenant: number)
	local r = racine(joueur)
	if r then
		local d = if e.dernierePos then (r.Position - e.dernierePos).Magnitude else 0
		e.dernierePos = r.Position
		if d >= 0.1 then e.cumul += math.min(d, 10) end -- ignore le tremblement, borne la téléportation
		if e.cumul >= C.ACTIVITE.DEPLACEMENT then Economie.marquerActif(joueur) end
	end
	local alerte = maintenant - e.derniereAction >= C.ACTIVITE.ALERTE -- « Zzz » + bip côté client
	if joueur:GetAttribute("Inactif") ~= alerte then joueur:SetAttribute("Inactif", alerte) end
end

local function balayerSol(joueur: Player, e: Etat, maintenant: number)
	local r = racine(joueur)
	for id, p in e.sol do
		local ramassee = r ~= nil and (r.Position - p.pos).Magnitude <= C.PIECES.AIMANT
		if ramassee or maintenant - p.ne >= C.PIECES.DUREE_SOL then
			e.sol[id] = nil
			if ramassee then crediter(joueur, e, p.valeur, true, false) else e.reliquat += p.valeur end
			ButinRetire:FireClient(joueur, id, ramassee)
		end
	end
end

local function tickMine(pas: number)
	horlogeMine += pas
	while horlogeMine >= C.GEMMES.MINE_PERIODE do
		horlogeMine -= C.GEMMES.MINE_PERIODE
		stockMine = math.min(stockMine + 1, C.GEMMES.MINE_STOCK)
	end
	Mine:SetAttribute("Stock", stockMine)
	if stockMine == 0 then return end
	local centre = Mine:GetPivot().Position
	for joueur in etats do
		local r = racine(joueur)
		if r and (r.Position - centre).Magnitude <= C.GEMMES.MINE_CONTACT then
			local verse = stockMine
			stockMine = 0
			for survivant in etats do Economie.gagnerGemmes(survivant, verse, "Mine") end
			return
		end
	end
end

function Economie.debutJour(): number
	enRun = true
	facteurHorde = C.facteurHorde(Economie.nombreActifs())
	for _, e in etats do e.piecesJour = 0 end
	return facteurHorde -- HordeService : Zbires du jour × facteurHorde
end

function Economie.debutRepit(jourParfait: boolean)
	for joueur, e in etats do
		for _, p in e.sol do e.reliquat += p.valeur end
		table.clear(e.sol)
		ButinRetire:FireClient(joueur, 0, false) -- 0 : tout retirer
		crediter(joueur, e, math.floor(e.reliquat * C.PIECES.ASPIRATION_REPIT), true, true)
		e.reliquat = 0
		if jourParfait then Economie.ajouterPieces(joueur, e.piecesJour * C.PIECES.JOUR_PARFAIT) end
	end
end

function Economie.franchirJour(jour: number)
	for joueur in etats do
		Economie.gagnerGemmes(joueur, C.gemmesJour(jour), "Jour")
		task.spawn(Donnees.CrediterRun, joueur, false)
	end
end

function Economie.finDeRun()
	enRun = false
	for joueur in etats do
		task.spawn(Donnees.CrediterRun, joueur, true) -- Donnees applique le plancher de 40
	end
end

local function initialiser(joueur: Player)
	etats[joueur] = { pieces = 0, piecesJour = 0, reliquat = 0, fraction = 0, perdues = 0, niveaux = {},
		sol = {}, derniereAction = os.clock(), derniereDemande = 0, dernierePos = nil, cumul = 0 }
	joueur:SetAttribute("Pieces", 0)
	joueur:SetAttribute("GemmesInactif", 0)
end

Players.PlayerAdded:Connect(initialiser)
for _, joueur in Players:GetPlayers() do initialiser(joueur) end
Players.PlayerRemoving:Connect(function(joueur)
	Donnees.CrediterRun(joueur, false)
	etats[joueur] = nil -- les Pièces disparaissent avec la run (canon)
end)
DemandeAchat.OnServerEvent:Connect(acheter)

local accumule = 0
RunService.Heartbeat:Connect(function(dt)
	accumule += dt
	if accumule < 0.2 then return end
	local maintenant = os.clock()
	for joueur, e in etats do
		suivreActivite(joueur, e, maintenant)
		balayerSol(joueur, e, maintenant)
	end
	if enRun then tickMine(accumule) end
	accumule = 0
end)

return Economie
```

## 9. Soumis à Victor Lanoue

1. **Aspiration à 50 %.** Les Pièces non ramassées (après 20 s au sol, ou encore au sol au début du Répit) sont versées à moitié, avec un « +X » gris. Un enfant sur téléphone tire à 40 studs mais ne ramasse qu'à 8 : sans cette règle, on perd ≈ 30 % du butin. À 50 %, courir reste payant (pilier : l'arme, c'est le Survivant). En cas de refus, le ramassage tombe à ≈ 70 % et tous les prix de l'Établi passent à × 0,82 dans le Catalogue.
2. **Puits cosmétique.** Une fois l'arbre terminé (≈ 45 h), des teintes d'Alcôve de 500 à 2 000 gemmes, prises dans la palette de `Charte`. Rien n'est codé sans ton accord. À défaut, on ajoute des niveaux de recherche par mise à jour.
3. **Pour information :** le nombre de Zbires par jour est multiplié par (1 + 0,2 × (actifs − 1)). Le canon ne fixe que les PV : aucun écart.
