# Scripts de gameplay de Zsurvie : Horde, Blaster et rendu des Zbires

*Louise Fabre, scripteuse gameplay (Scripting Luau). Révision du 02/10. Code complet dans `scripts/a26/` (11 fichiers, emplacement Roblox en 1re ligne). Repère a11 : origine au centre de la Maison, sol à Y = 0.*

## 1. Fichiers

| Fichier | Emplacement | Rôle |
|---|---|---|
| `Config`, `ZbiresDefs`, `BlasterStats`, `Reseau` | `ReplicatedStorage.Partage` | Constantes, bestiaire (+ `ZbiresDefs.Jours` de a06), courbes du Blaster, remotes |
| `HordeService` | `ServerScriptService.Services` | Horde + portails (absorbe `ServerScriptService.Horde.Portails` de a14) |
| `BlasterService`, `StatsSurvivant` | idem | Tir serveur ; étourdissement, allures, déblocage, collisions |
| `Demarrage` | `ServerScriptService` | Branchements, `ModeTest` |
| `ZbiresRendu`, `BlasterControleur` | `StarterPlayerScripts.Controleurs` | Pool de 70 modèles ; la seule boucle de tir auto |
| `ClientDemarrage` | `StarterPlayerScripts` | Pool, contrôleurs, `ResetButtonCallback` |

**Supprimés :** le `RemoteEvent` fiable `EvenementsZbires`, `ImpactsTir` et l'échange « pret »/« liste ». Un joueur qui arrive reconstruit la horde dès le paquet `EtatZbires` suivant, qui porte le type de chaque Zbire.

## 2. Contrats

| API | Appelant | Rôle |
|---|---|---|
| `HordeService.demarrerJour(j)` | JourService, au début des 80 s | Lit `ZbiresDefs.jour(j)`, suit la rampe, ajoute le Colosse les jours 5, 10, 15… |
| `ajouterALaFile(type, n?, cframe?)` | Gluant, tests | Avec `cframe` : sortie sur place, en tête de file, sans alerte |
| `definirModificateurs({pv, vitesse})` | Défi du Jour, Zbire de la Semaine | Facteur « Défi » des PV |
| `infligerDegats(id, dmg, critique, joueur?)` → `(vaincu, reel, reduit)` | Blaster, tourelles | Seule porte des dégâts, refusée avant `ciblableA` |
| `plusProche`, `dansRayon`, `estCiblable` | Tourelles | Zbires ciblables seulement |
| `enregistrerObstacle(cle, pos, rayon, frapper(degats))`, `on("maison", fn(degats))` | DefensesService, MaisonService | Un seul appel par tick, dégâts cumulés |
| `on("vaincu", fn(type, pos, tueur?, critique))` | Economie, GalerieService | Pièces × `BlasterStats.butin(tueur)` |
| `StatsSurvivant.definirAllurePhase("Horde"/"Repit")`, `definirAllure(joueur, "Reparation"/nil)` | JourService, MaisonService | Transmis à `GardienMouvement.definirVitesse` |
| `ZbiresRendu.chercher(positionEcran, tolerancePx)`, `position(id)` | a28 | Tap vers identifiant ; position affichée |
| `BlasterControleur.definirCiblePrioritaire(id?)` | a28 | Cible forcée jusqu'à sa disparition |
| `ZbiresRendu.brancherAnimateur(fn(actifs, dt))` | ZbireAnimateur (a38) | Appelé juste après le `BulkMoveTo` |

**Flux `Evenements` (serveur vers clients) :** `apparition(id, type, x, z, alerte)` ; `impact`, `critique` ou `coupReduit(userId, id, x, z, explose)`, un message par tir ; `eclatement(id, type, x, z, critique)` ; `division(id, x, z)` ; `bond(id)` ; `onde(id, x, z, rayon, preavis)`.

## 3. BlasterStats : une seule courbe sur 10 niveaux

| Attribut du `Player` | Niv 0 | Par niveau | Maximum |
|---|---|---|---|
| `NivDegats` | 10 | + 2 | 30 (niv 10) |
| `NivCadence` | 4 tirs/s | + 0,2 | 6 tirs/s (niv 10) |
| `NivPortee` = rayon du tir auto | 40 studs | + 1,2 | 52 studs (niv 10) |
| `NivExplosives` | 0 % | + 5 % de chance | 50 % (niv 10), rayon 6 studs, 50 % des dégâts de base |
| `NivButin` | × 1 | + 10 % | × 1,5 (niv 5) |
| `RechViseeCritique` | 5 % | + 2 points | 25 % (niv 10), dégâts × 2 |
| `RechBallesPerforantes` | 0 | 45 % + 5 points | 95 % sur le 2e Zbire (niv 10) |

Le Casqué subit 50 % des dégâts hors critique. À Visée critique 10, son facteur moyen vaut 0,5 × 0,75 + 2 × 0,25 = **0,875** : le critique reste la réponse au Casqué. a07 et a09 lisent `BlasterStats.valeur(stat, niveau)` et `BlasterStats.MAX`.

## 4. HordeService

**Formules :**
- PV = base × 1,15^(jour − 1) × 1,3^Tension × (1 + 0,35 × (actifs − 1)) × Défi.
- Effectif = `JOURS[j].zbires` × (1 + 0,2 × (actifs − 1)), arrondi puis mélangé.
- `actifs` = Survivants pour qui `Economie.estActif` est vrai, entre 1 et 6.
- Colosse : 2 500 × 1,15^(jour − 1) × coop, sans Tension ni Défi. Enragé 60 s après sa sortie : vitesse × 1,5, dégâts sur la Maison × 3, attribut `workspace.ColosseEnrage`.
- Contact de la Maison : 4 × 1,15^(jour − 1) PV/s × `multMaison` (Costaud 2, Colosse 3, Doré 0, autres 1). Même débit contre un Muret.

**Portails (ex-a14) :**
- Parts taguées `PortailZbire`, placées par `Plan.positionPortail(Index)` (attribut `Index`), sinon par leur pivot. Sans tag : `Plan.positionPortail(1 à 8)`.
- `JOURS[j].portails` ouvre les N premiers. Tirage pondéré par l'attribut `Poids` (1 par défaut), jamais deux fois de suite le même portail.
- Alerte 1,5 s (Colosse : 4 s au Grand Portail), puis sortie. `ciblableA` = sortie + 0,8 s : avant, ni tir, ni tourelle, ni coup aux Survivants.
- `ZbiresDefs.rampe(t / 80)` donne la part cumulée du programme mise en file.

```lua
-- 3 sorties par tick au plus. Une entrée ne sort que si le plafond de 60 (Colosse exclu) ET le quota
-- de rendu de son type (pool client de 70) ont une place ; sinon les entrées suivantes passent devant.
local function traiterFile(maintenant: number)
	local crees, i = 0, 1
	while i <= #file and crees < Config.APPARITIONS_PAR_TICK do
		local entree = file[i]
		local boss = ZbiresDefs.Types[entree.type].boss == true
		local quota = Config.QUOTAS_RENDU[entree.type] or 0
		if (compte[entree.type] or 0) < quota and (boss or nbDansPlafond < Config.MAX_ZBIRES) then
			table.remove(file, i)
			creer(entree, maintenant)
			crees += 1
		else
			i += 1
		end
	end
end
```

**Réseau :** `EtatZbires` (`UnreliableRemoteEvent`), 9 octets par Zbire : 61 × 9 = 549 octets par tick, 5,5 Ko/s par client.

| Octets | 0-1 | 2-3 | 4-5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|
| Champ | id u16 | x i16 (1/10 stud) | z i16 | PV u8 | cap u8 | type (4 bits) + état : ciblable, bond, enragé, contact |

## 5. ZbiresRendu : le contrat figé

- **Pool :** `ZbiresRendu.preparer()` crée 70 modèles pendant l'Arrivée, 5 par image (~14 images). Ils sont parentés à `workspace.Zbires`, portent l'attribut `Id` (0 = libre) et attendent en (0, −200, 0).
- **Quotas** (`Config.QUOTAS_RENDU`) : Marcheur 18, Rapide 10, MiniGluant 10, Casque 8, Sauteur 6, Costaud 5, Gluant 5, Volant 5, Dore 2, Colosse 1.
- **Modèle** (`ReplicatedStorage.Modeles.Zbires.<Type>`, a24) : `Racine` ancrée de `Transparency` 1, plus 3 à 5 `MeshPart` (700 triangles au plus pour le Zbire) reliées par `Motor6D` aux noms de a38. `CastShadow`, `CanCollide`, `CanQuery` et `CanTouch` à false. Un `warn` par type sans modèle (cube greybox) ou hors contrat.
- **À chaque image** (`PreRender`) : interpolation du 10 Hz, un seul `BulkMoveTo` (Racines actives, modèles à garer, disque de l'onde), puis l'animateur de a38. Étiquette MicroProfiler : `ZbiresRendu`.
- **Retour au pool** sur `eclatement`, ou après 0,5 s sans nouvelle (Doré enfui, fin de run). Aucun `Instance.new`, `Clone` ni `Destroy` après `preparer()`.
- **Coût :** 61 Racines déplacées, 366 Parts au plus au lieu de 1 800.

```lua
	for _, e in aGarer do
		if e.id == 0 then -- pas repris entre-temps
			table.insert(racines, e.racine)
			table.insert(cadres, PARKING)
		end
	end
	table.clear(aGarer)
	if #racines > 0 then
		workspace:BulkMoveTo(racines, cadres, Enum.BulkMoveMode.FireCFrameChanged)
	end
	if animateur then
		animateur(actifs, dt) -- ZbireAnimateur (a38) : Motor6D.Transform, même budget de 3 ms
	end
	debug.profileend()
```

## 6. Tir, mouvement et déblocage

- **BlasterControleur :** une seule connexion `Heartbeat`. La cible prioritaire de a28 passe d'abord, sinon le Zbire ciblable et visible le plus proche, avec 0,4 s d'hystérésis. 12 traçantes recyclées : Ardoise sur un `coupReduit`, 0,6 stud d'épaisseur sur un `critique`.
- **BlasterService :** `Validation.brancher(Reseau.DemandeTir, { arguments = { "number" }, maxParSeconde = 10 }, surDemandeTir)`, puis seau à jetons (2 tirs d'avance), portée + rayon + 4 studs, `ciblableA`.
- **StatsSurvivant** n'écrit plus `WalkSpeed` ni `JumpHeight`. Il lit `ReplicatedStorage.Config.Mouvement` (`VITESSE_HORDE` 18, `VITESSE_REPIT` 24, `VITESSE_REPARATION` 8, `ETOURDI_DUREE` 2) et appelle `GardienMouvement.definirVitesse` et `etourdir`. Seul GardienMouvement lit `SAUT_SURVIVANT`.
- **Déblocage :** `ResetButtonCallback` reçoit un `BindableEvent` qui envoie `DemandeDeblocage` (1 toutes les 10 s). Le serveur revérifie (Validation + horodatage), puis appelle `GardienMouvement.teleporter` vers le `SpawnLocation` libre le plus proche (aucun autre Survivant à moins de 4 studs), 3 studs au-dessus.
- **Collisions :** groupes `Survivants` et `Defenses` non collidables entre eux. Les Murets bloquent toujours les Zbires, simulés côté serveur.

## 7. Tests dans Studio

1. Workspace : `ModeTest` = true, `JourTest` = 5 pour le Colosse d'emblée. Test > Clients and Servers, 2 joueurs.
2. Casqué, Visée critique 10, 1 000 tirs : dégâts moyens ≈ 0,875 × base (`BlasterStats.facteurMoyenCasque(10)`).
3. Tir dans les 0,8 s après la sortie : refusé, PV inchangés.
4. Gluant : 2 Mini-Gluants sur place, sans alerte. Volant au-dessus des Murets.
5. 3 Murets en (−13, 0, ±4) et (−18, 0, 0) : on les traverse. Échap > Réinitialiser : spawn libre ; 2e essai avant 10 s refusé.
6. 15 s de Répit à 24 et un Ressort : 0 correction de GardienMouvement.
7. Android 3 Go, 60 Zbires : `HordeTick` < 1 ms, `ZbiresRendu` (animateur compris) < 3 ms par image, `EtatZbires` ≈ 5,5 Ko/s (Developer Stats > Network).

## 8. Décisions et écarts

- **Quotas de rendu par type**, appliqués aussi par le serveur : un ajout au plafond de 60 du canon, cohérent avec « les suivants attendent leur tour ».
- **`multMaison` du Colosse à 3** (12 PV/s au jour 1, 36 enragé) : ma proposition, à valider par Victor Lanoue.
- **Volant à 3,5 studs du sol :** il survole un Muret de 3 studs, sommet vers 6 studs.
- **Le Colosse vient de `demarrerJour`**, plus de JourService.
- **Les entrées appartiennent à a28 :** BlasterControleur ne lit ni souris ni tap.
- **À valider par Victor Lanoue (inchangé) :** le Doré ne frappe pas la Maison ; le Colosse s'immobilise pendant l'annonce de son onde ; le Volant ne frappe pas les Survivants.
- **Identifiants ASCII** (`Dore`, `Casque`, `MiniGluant`), nom du canon dans `def.nom`. Les Recherches arrivent par le DataStore, jamais par `TeleportData`.
