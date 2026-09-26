# Zsurvie : données, rétention et entonnoirs

*Livia Roseau, analyste de données. Chaque vue se lit d'abord filtrée sur « Téléphone ».*

## 1. Indicateurs suivis

| Indicateur | Creator Dashboard | Question posée |
|---|---|---|
| Visites, nouveaux joueurs, DAU, pic de CCU | Acquisition, Engagement | Attire-t-on ? Pic du samedi 17 h = Zbire de la Semaine |
| QPTR, clics sur recommandations | Acquisition | Icône et vignettes efficaces ? |
| Rétention J1 / J7 / J30 | Retention | Revient-on chaque jour ? |
| Durée de session | Engagement | Tient-on 20 à 35 min ? |
| Conversion payeur, ARPDAU | Monetization | Cosmétiques et serveurs privés seulement |
| FPS, mémoire, crashs par appareil | Performance | 30 FPS, < 800 Mo sur Android 3 Go ? |
| Entonnoirs, économie, événements | Analytics | Où décroche-t-on ? |

## 2. Objectifs du premier mois

| Indicateur | Alerte | Cible M1 |
|---|---|---|
| Visites cumulées | < 100 000 | 300 000 |
| DAU moyen, semaines 3-4 | < 1 500 | 4 000 |
| Rétention J1 | < 15 % | 22 % |
| Rétention J7 | < 5 % | 8 % |
| Rétention J30 (cohortes semaine 1) | < 2 % | 3,5 % |
| Session moyenne (rebonds compris) | < 12 min | 18 min |
| Durée médiane d'une run | < 10 ou > 20 min | 12 à 18 min |
| Runs de plus de 25 min | > 5 % | ≤ 2 % |
| Premières runs qui voient le Colosse | < 55 % | 70 % |
| Runs à 2 Survivants ou plus | < 45 % | 60 % |
| Survivants qui quittent en cours de run | > 30 % | ≤ 18 % |
| Échecs de téléportation Capsule → Prairie | > 2 % | ≤ 0,5 % |
| DAU jouant le Défi du Jour | < 15 % | 25 % |
| Revenants J1 qui récoltent la Foreuse | < 40 % | 60 % |
| Conversion payeur | < 0,5 % | 1,2 % |

## 3. Entonnoirs à surveiller

### 3.1 Accueil : `LogOnboardingFunnelStepEvent`

La dernière étape franchie vit dans le profil (clé `accueilEtape`, exposée en attribut `AccueilEtape`) : aucune étape n'est relogguée et un saut d'étape ne bloque rien. Doc Boulon impose l'ordre : il demande la première défense au Répit du Jour 2.

| # | Étape | Place | Déclencheur serveur | Cible cumulée |
|---|---|---|---|---|
| 1 | ArriveeLabo | Laboratoire | `PlayerAdded`, profil neuf | 100 % |
| 2 | DocBoulonParle | Laboratoire | fin du dialogue d'accueil | 92 % |
| 3 | CapsuleMontee | Laboratoire | place validée dans une Capsule | 86 % |
| 4 | ArriveePrairie | Prairie | `PlayerAdded` du serveur réservé | 81 % |
| 5 | PremierZbire | Prairie | premier Zbire éliminé | 79 % |
| 6 | PremierAchatEtabli | Prairie | premier achat validé | 68 % |
| 7 | PremiereDefense | Prairie | Muret, Mini-Tourelle ou Tapis Collant posé | 62 % |
| 8 | ColosseVu | Prairie | début du Jour 5 | 57 % |
| 9 | MaisonTombee | Prairie | fin de la première run | 54 % |
| 10 | RetourLabo | Laboratoire | arrivée après une run | 50 % |
| 11 | PremiereRecherche | Laboratoire | première recherche payée | 43 % |
| 12 | DeuxiemeCapsule | Laboratoire | deuxième départ en Capsule | 36 % |

### 3.2 Visite du Laboratoire : `LogFunnelStepEvent("VisiteLabo", guid)`

Un `HttpService:GenerateGUID(false)` par arrivée. 1 Arrivée (champ provenance : `nouveau`, `fin_run`, `retour`) → 2 Arbre des Recherches ouvert → 3 Recherche lancée → 4 Capsule montée → 5 Capsule partie. Cible : 75 % de 1 à 5, entre 3 et 5 min au Laboratoire.

### 3.3 Run : `LogFunnelStepEvent("Run", game.JobId)`

1 Arrivée → 2 Jour 1 franchi → 3 Jour 3 → 4 Jour 5 (Colosse) → 5 Jour 6 (Colosse survécu) → 6 Jour 10 → 7 Jour 15. Lu par mode et par taille d'équipe. La plus grosse marche doit être 4 → 5 : le Colosse est le mur voulu. Plus de 25 % de perte entre 1 et 3 signale un début de run raté. Le mode est lu côté serveur (config de run en `MemoryStoreService`, clé `game.PrivateServerId`), jamais depuis la `TeleportData`.

### 3.4 Boutique : `LogFunnelStepEvent("Boutique", guid)`

1 Boutique ouverte → 2 Aperçu dans l'Alcôve → 3 Invite `MarketplaceService` → 4 Achat confirmé (`ProcessReceipt`, `PromptGamePassPurchaseFinished`). Les étapes 1-2 arrivent par un `RemoteEvent` limité à 1 requête par seconde ; aucune récompense n'en dépend.

## 4. Plan de marquage

Trois champs personnalisés au maximum, toujours en tranches : mode (`Normale`, `Difficile`, `Jour`), équipe (`solo`, `2-3`, `4-6`), jour (`J1-4`, `J5-9`, `J10-14`, `J15+`), durée (`<12`, `12-18`, `18-25`, `>25` min). Identifiants techniques sans accents.

| Événement | Valeur | Champs | Moment |
|---|---|---|---|
| `RunFin` | jour atteint | mode, équipe, durée | Maison tombée, par Survivant présent |
| `RunQuitte` | jour en cours | mode, jour, état de la Maison | `PlayerRemoving` avant la fin |
| `Colosse` | jour | `vaincu` / `maison_tombee`, équipe | fin de chaque combat |
| `PingsRun`, `DefensesRun`, `EtourdiRun` | nombre | équipe | fin de run (pilier 2) |
| `CapsulePartie` | secondes au Labo | mode, équipe | départ de Capsule |
| `TeleportEchec` | 1 | `Enum.TeleportResult` | `TeleportService.TeleportInitFailed` |
| `ForeuseRecolte` | gemmes | `<2h`, `2-8h`, `plafond` | récolte au Labo |
| `DefiDuJour`, `ZbireSemaine` | jour atteint | `reussi` / `echoue` | fin de run concernée |
| `GalerieVariante` | palier 10 / 100 / 1 000 | Zbire | déblocage |

Économie (`LogEconomyEvent`) :
- **Pièces**, source `Horde` cumulée par jour ; puits = amélioration achetée à l'Établi (`Degats`… `BallesExplosives`) ; reliquat perdu en fin de run (`PerteFinRun`), signe d'un Établi sous-utilisé.
- **Gemmes**, sources `Mine`, `Dore` (cumulées par jour), `JourFranchi`, `Foreuse` (`TimedReward`), `DefiDuJour` ; puits = recherche (`TourelleToit`, `BallesPerforantes`, `ViseeCritique`, `Foreuse`).

## 5. Module serveur `Telemetrie`

Seul point d'appel d'`AnalyticsService`, publié en Package dans les deux places. Le client n'émet rien.

```lua
--!strict
-- ServerScriptService.Telemetrie (ModuleScript, Package Laboratoire + Prairie)
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")

local CHAMPS = {
	Enum.AnalyticsCustomFieldKeys.CustomField01.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField02.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField03.Name,
}
local ACCUEIL = {
	"ArriveeLabo", "DocBoulonParle", "CapsuleMontee", "ArriveePrairie",
	"PremierZbire", "PremierAchatEtabli", "PremiereDefense", "ColosseVu",
	"MaisonTombee", "RetourLabo", "PremiereRecherche", "DeuxiemeCapsule",
}
local GAMEPLAY = Enum.AnalyticsEconomyTransactionType.Gameplay.Name
local BOUTIQUE = Enum.AnalyticsEconomyTransactionType.Shop.Name

local Telemetrie = {}
local cumuls: { [Player]: { [string]: number } } = {}

local function champs(valeurs: { string }?): { [string]: string }?
	if not valeurs then
		return nil
	end
	local t = {}
	for i = 1, math.min(#valeurs, 3) do
		t[CHAMPS[i]] = valeurs[i]
	end
	return t
end

local function appeler(methode: string, ...: any)
	local ok, err = pcall((AnalyticsService :: any)[methode], AnalyticsService, ...)
	if not ok then
		warn(`[Telemetrie] {methode} : {err}`)
	end
end

function Telemetrie.tranche(nature: "equipe" | "jour" | "duree", n: number): string
	if nature == "equipe" then
		return if n <= 1 then "solo" elseif n <= 3 then "2-3" else "4-6"
	elseif nature == "jour" then
		return if n < 5 then "J1-4" elseif n < 10 then "J5-9" elseif n < 15 then "J10-14" else "J15+"
	end
	local minutes = n / 60
	return if minutes < 12 then "<12" elseif minutes < 18 then "12-18" elseif minutes <= 25 then "18-25" else ">25"
end

function Telemetrie.accueil(player: Player, etape: number)
	local derniere = (player:GetAttribute("AccueilEtape") :: number?) or 0
	if etape <= derniere or etape > #ACCUEIL then
		return
	end
	player:SetAttribute("AccueilEtape", etape) -- resauvegardé par le module de profil
	appeler("LogOnboardingFunnelStepEvent", player, etape, ACCUEIL[etape])
end

function Telemetrie.etape(player: Player, entonnoir: string, session: string, etape: number, nom: string, valeurs: { string }?)
	appeler("LogFunnelStepEvent", player, entonnoir, session, etape, nom, champs(valeurs))
end

function Telemetrie.evenement(player: Player, nom: string, valeur: number?, valeurs: { string }?)
	appeler("LogCustomEvent", player, nom, valeur or 1, champs(valeurs))
end

function Telemetrie.source(player: Player, monnaie: string, montant: number, solde: number, sku: string, transaction: string?)
	appeler("LogEconomyEvent", player, Enum.AnalyticsEconomyFlowType.Source, monnaie, montant, solde, transaction or GAMEPLAY, sku)
end

function Telemetrie.depense(player: Player, monnaie: string, montant: number, solde: number, sku: string, transaction: string?)
	appeler("LogEconomyEvent", player, Enum.AnalyticsEconomyFlowType.Sink, monnaie, montant, solde, transaction or BOUTIQUE, sku)
end

-- Gains fréquents (Horde, Mine, Doré) : cumulés, un seul événement par jour.
function Telemetrie.cumuler(player: Player, monnaie: string, sku: string, montant: number)
	local t = cumuls[player] or {}
	cumuls[player] = t
	local cle = `{monnaie}|{sku}`
	t[cle] = (t[cle] or 0) + montant
end

function Telemetrie.fermerJour(player: Player, soldes: { [string]: number })
	local t = cumuls[player]
	if not t then
		return
	end
	cumuls[player] = nil
	for cle, montant in t do
		local monnaie, sku = string.match(cle, "^(%w+)|(%w+)$")
		if monnaie and sku and montant > 0 then
			Telemetrie.source(player, monnaie, montant, soldes[monnaie] or 0, sku)
		end
	end
end

Players.PlayerRemoving:Connect(function(player)
	task.delay(10, function()
		cumuls[player] = nil
	end)
end)

return Telemetrie
```

Fin de run sur la Prairie (extrait ; `Players`, `Telemetrie` et le type `EtatRun` sont déclarés en tête du script de run) :

```lua
local function journaliserFinDeRun(etat: EtatRun)
	local equipe = Telemetrie.tranche("equipe", etat.equipeDepart)
	local duree = Telemetrie.tranche("duree", workspace:GetServerTimeNow() - etat.debut)
	for player, s in etat.survivants do
		if player.Parent ~= Players then
			continue
		end
		Telemetrie.fermerJour(player, { Pieces = s.pieces, Gemmes = s.gemmes })
		if s.pieces > 0 then
			Telemetrie.depense(player, "Pieces", s.pieces, 0, "PerteFinRun", Enum.AnalyticsEconomyTransactionType.Gameplay.Name)
		end
		Telemetrie.evenement(player, "RunFin", etat.jour, { etat.mode, equipe, duree })
		Telemetrie.evenement(player, "PingsRun", s.pings, { equipe })
		Telemetrie.accueil(player, 9)
	end
end
```

## 6. Lire un décrochage

| Symptôme | Cause probable | Levier dans Studio |
|---|---|---|
| Perte 3 → 4 > 8 % | attente de 15 s, téléportation ratée | départ immédiat si Capsule pleine, 3 essais de `TeleportAsync` |
| Perte 4 → 5 > 5 % | tir auto ou caméra illisibles sur téléphone | vérifier rayon de 40 studs, boutons ≥ 60 px |
| Perte 5 → 6 > 15 % | Établi introuvable | flèche de Doc Boulon au premier Répit |
| `RunQuitte` concentré sur `J1-4` | début trop lent | horde du Jour 1 plus dense |
| `Colosse` perdu > 70 % en solo | PV mal réglés à 1 joueur | revoir les PV du Colosse en solo |
| `PerteFinRun` élevée | Établi trop loin ou trop cher | baisser le premier palier |
| J1 correct, J7 faible | Foreuse et Défi du Jour peu visibles | compteur de Foreuse dans l'Alcôve, Défi affiché sur la Capsule du Jour |

## 7. Rituel

- **Chaque matin (10 min) :** J1 de la veille, accueil sur téléphone, `TeleportEchec`, runs de plus de 25 min.
- **Chaque lundi :** les 3 plus grosses marches de décrochage, une recommandation chiffrée par marche, envoyées au gameplay et au Live Ops.
- **Règles :** on ne renumérote jamais une étape et on ne renomme aucun événement après le lancement. Le marquage se valide sur une version publiée privée. Prévoir environ un jour de délai d'affichage.
