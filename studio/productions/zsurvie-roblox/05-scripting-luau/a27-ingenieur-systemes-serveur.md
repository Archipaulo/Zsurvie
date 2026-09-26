## 1. Un store, un profil

- **Store unique** : `DataStoreService:GetDataStore("Zsurvie_Joueurs_v1")`, clé `J_<UserId>`, dans les deux places. En Studio, `Zsurvie_Joueurs_Studio` (*Game Settings > Security > Enable Studio Access to API Services*).
- **Supprimés** : `Gemmes_v1`, `Zsurvie_Profils_v1` (clés `Survivant_` et `Joueur_`), `Boutique_v1`, `Cosmetiques_v1`, `PeluchesSecretes_v1` et le store de `Transactions`. a06, a07, a13, a15, a22, a29 et a46 retirent leurs `GetDataStore` et passent par `Donnees`.
- **`UpdateAsync` seulement**, sous `pcall`, 5 essais (attentes 1, 2, 4, 8 s), budget vérifié, `{UserId}` joint à chaque écriture.
- **Verrou de session** `{Id, JobId, PlaceId, Horodatage}` : attente 10 × 3 s, verrou mort après 180 s. Un serveur dépossédé n'écrit plus jamais. Une écriture toutes les 7 s par clé au plus.

| Déclencheur | Appel |
|---|---|
| Jour franchi (Prairie) | `Run.JourFranchi` → `SauvegarderTous(true)` |
| Recherche, Foreuse, réglage, déblocage | `Planifier` (écritures regroupées) |
| Achat Robux | `EnregistrerAchat`, synchrone avant `PurchaseGranted` |
| Autosave | toutes les 60 s, rafraîchit le verrou |
| Départ, téléport | `Liberer` |
| `BindToClose` | `Run.Clore` (Prairie), puis `FermerTout` (27 s) |

## 2. `SchemaJoueur` version 2

| Champ | Défaut | Règle |
|---|---|---|
| `Gemmes`, `GemmesCumul`, `XP` | 0 | écrits par `Donnees` seul |
| `Recherches.TourelleDeToit`, `.BallesPerforantes`, `.ViseeCritique`, `.Foreuse` | 0 | niveaux 0 à 5 |
| `Foreuse = {DerniereRecolte, Reste}`, `TurboForeuseFin` | 0 | a08 ; `Reste` garde la gemme entamée |
| `RunsCreditees` | `{}` | `[runId] = gemmes déjà versées` |
| `RunsTerminees` | `{}` | 20 derniers `runId` clos |
| `AccueilEtape` | 0 | a50, remplace `Tutoriel` et `EtapeOnboarding` (a10) |
| `DernierBonus`, `Calendrier = {Case, CleJour}` | `""`, `{0, ""}` | clés `Temps.cleJour()` |
| `Secrets = {trouves, jour}` | `{{}, ""}` | a13 |
| `Chapeaux`, `JourChapeau`, `Tampons`, `JourTampon` | `{}`, `""` | a15 |
| `Peluches` | `{}` | a22 |
| `Cosmetiques.Possedes`, `.Equipes`, `Achats[PurchaseId]` | `{}`, `"Base"`, `{}` | a46 ; `Achats` = `os.time()`, purgé à 90 jours |
| `Reglages` | `VolumeMusique` 0,6, `VolumeEffets` 0,8, `EffetsReduits` false, `Secousses` true, `TirAuto` true | liste blanche |
| `Records`, `Eliminations`, `Quotidien.CleDefi`, `ZbireSemaine.CleSemaine` | 0, `""` | inchangés |

- **Migration v1 → v2** : `AccueilEtape = max(Tutoriel.Etape, EtapeOnboarding)`. `Musique`, `Effets` et `Vibrations` deviennent `VolumeMusique`, `VolumeEffets` et `Secousses`. La liste `Achats` devient un dictionnaire. `Reconcilier` pose les nouveaux champs. Environ 2,5 Ko par profil.
- **Jamais sauvegardés** : Pièces, niveaux d'Établi, défenses, étourdissement.
- **Profil illisible** : tout se joue dans le transform d'`UpdateAsync`. `Reconcilier` tente `tonumber` sur `Gemmes` et `Recherches.*`. En cas d'échec, le chargement est refusé (`return nil`, donc rien n'est écrit). L'incident part en `warn` et en `AnalyticsService:LogCustomEvent("ProfilCorrompu")`. `restaurer` relit ensuite les 10 dernières versions (`ListVersionsAsync`, `GetVersionAsync`) et réécrit la plus récente qui passe `Preparer`. Sinon, `Kick` rassurant, store intact. **Écart assumé** : même protection pour `Cosmetiques.Possedes` et `Achats`, payés en Robux.

## 3. Gemmes : une seule porte

| Source | Plafond par appel | Place | `runId` |
|---|---|---|---|
| `Jour` | 210 (J15 : 70 × 1,5 × 2) | Prairie | oui |
| `Mine` | 200 | Prairie | oui |
| `Dore` | 50 | Prairie | oui |
| `FinDeRun` | 1 500 | Prairie | oui |
| `Foreuse` | 216 (27 × 8 h) | Laboratoire | non |
| `DefiDuJour` | 150 | Prairie | non |

Toute autre source lève une erreur : `ZbireSemaine` n'existe plus. La Prairie crée `Run.Id = HttpService:GenerateGUID(false)` au démarrage. Chaque `AjouterGemmes(joueur, n, source, Run.Id)` ajoute aussi `n` à `RunsCreditees[runId]`. Quand la Maison tombe, `Run.Terminer(totaux, jour)` appelle :

```lua
function Donnees.CrediterRun(joueur: Player, runId: string, totalRun: number, terminer: boolean?): number
	assert(type(runId) == "string" and runId ~= "", "CrediterRun exige le runId de la Prairie")
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		if table.find(p.RunsTerminees, runId) then
			return false -- run déjà close : rien n'est versé deux fois
		end
		verse = verser(p, totalRun - (p.RunsCreditees[runId] or 0), "FinDeRun", runId)
		if terminer then
			p.RunsCreditees[runId] = nil
			table.insert(p.RunsTerminees, runId)
			if #p.RunsTerminees > RUNS_TERMINEES_MAX then
				table.remove(p.RunsTerminees, 1)
			end
			p.Records.Runs += 1
		end
		return verse > 0 or terminer == true
	end)
	return verse
end
```

Un `FinDeRun` rejoué, un double appel ou une reconnexion ne versent rien de plus.

- **Foreuse** : 5, 8, 12, 16 puis 20 gemmes/h selon le niveau, 8 h au plus. Le turbo multiplie par 1,35, plafonné à 27 (a08 appelle `ActiverTurboForeuse`).
- **Recherche** : `AcheterRecherche(joueur, nom, niveauVise)` refuse sans débit si `niveau + 1 ~= niveauVise`. Un double tap ne paie qu'un niveau.

## 4. Réseau : `ReplicatedStorage.Reseau`

Le module est généré depuis son enfant `ReglesRemotes` (table a29) : un seul dossier `Remotes`, vérifié par `assert` au démarrage puis 10 s plus tard. RemoteEvent uniquement, aucune RemoteFunction. `Reseau.Brancher` refuse une seconde connexion sur une même demande. `Validation.brancher` (a29) y délègue, et a26 y branche `DemandeTir`.

| Demande | Arguments | Débit (rafale) |
|---|---|---|
| `DemandeTir` | `idZbire` | 15/s |
| `DemandeReparation` | `actif` | 4/s |
| `DemandeAchat` | `cle, niveauVise` | 4/s |
| `DemandePose` | `defense, position, rotationY` | 2/s |
| `DemandeReprise` | `idDefense` | 2/s |
| `DemandePing` | `type, position?` | 0,67/s (2) |
| `DemandeCapsule` | `"Monter", capsule` / `"Quitter"` / `"Rejoindre"` | 1/s (2) |
| `DemandeRecherche` | `nom, niveauVise` | 2/s (2) |
| `DemandeForeuse` | — | 0,5/s (1) |
| `DemandeDeblocage` | `genre, id` | 2/s (4) |
| `DemandeReglage` | `cle, valeur` | 2/s (5) |

- **Garde**, dans l'ordre : `DonneesChargees`, seau de jetons, nombre et `typeof` des arguments (NaN, ±inf, chaînes de plus de 32 caractères et `Vector3` au-delà de 100 000 refusés), puis gestionnaire sous `pcall`. Toute réponse part par `Annonce(code, donnees)`. Un refus prend la forme `Annonce("Refus", {Demande, Raison})`.
- **`DemandeDeblocage`** passe par le routeur `Donnees.DefinirDeblocage(genre, fn)`. Genres : `Accueil` et `Equiper` (fournis), `Secret` (a13), `Chapeau` et `Tampon` (a15), `Peluche` (a22).
- **Retours** : `Annonce`, `PingDiffuse`, `ProfilMaj`, `PiecesLachees` et `Butin(idsRamasses, pieces)`. `ProfilMaj` ne contient que les champs modifiés (diff toutes les 0,2 s), jamais `Verrou`, `Achats`, `RunsCreditees` ni `RunsTerminees`.
- **`EtatZbires`** (UnreliableRemoteEvent, 10 Hz, `Reseau.DiffuserEtatZbires`) : 9 octets par Zbire. Format : `u16` id, `u8` type, `i16` X × 100, `i16` Z × 100, `u8` Y × 10, `u8` PV/255, positions relatives à `Workspace.CentrePlace`. 61 Zbires = 549 octets.
- **`Evenements`** (UnreliableRemoteEvent, 10 Hz, `Reseau.AjouterFait`) : 8 octets par fait (`u8` code, `u16` id, `i16` x, `i16` z, `u8` argument), soit 800 octets pour 100 faits.
  - Codes : 1 Apparition, 2 Coup, 3 Critique, 4 Éclatement, 5 Division, 6 ÉtatZbire, 7 Étourdi, 8 DéfensePosée, 9 DéfenseRetirée, 10 MaisonTouchée, 11 Réparation.
  - Côté client, `Reseau.SurFait(fn)` décode chaque paquet une seule fois. VfxClient, Son, ZbireAnimateur et l'UI s'y abonnent.
  - `Impact`, `Eclatement`, `VfxRapide`, `ZbireApparu`, `ZbireVaincu`, `Notification` et le remote `FinDeRun` disparaissent.

**Attributs**

- `Workspace` : `TypePlace`, `CentrePlace` et `RayonPlace` (70 sur la Prairie), posés dans Studio.
- `ReplicatedStorage.EtatRun` (`Configuration` créée par `Run.Demarrer`, Prairie seulement) : `Mode`, `Jour`, `Phase`, `FinPhase`, `Niv_Solidite`, `Niv_Reparation`, `Niv_Regeneration`, `Cagnotte_Solidite`, `Cagnotte_Reparation`, `Cagnotte_Regeneration`.
- `Player` : `DonneesChargees`, `Gemmes`, `RunEnCours`.

## 5. `Temps` : minuit à Paris

`Temps.cleJour()` et `Temps.SecondesAvantDemain()` pilotent le Défi du Jour, le Calendrier, les secrets, les énigmes et le Record du Jour. `Temps.cleSemaine()` pilote le Zbire de la Semaine. L'heure vient toujours du serveur : `os.time()`, ou `workspace:GetServerTimeNow()` sur le client.

```lua
function Temps.SecondesAvantDemain(t: number?): number
	local maintenant = t or Temps.maintenant()
	local d = dateParis(maintenant)
	local minuitNaif = DateTime.fromUniversalTime(d.year, d.month, d.day, 0, 0, 0, 0).UnixTimestamp + JOUR
	-- Minuit à Paris tombe à 22 h ou 23 h UTC, avant toute bascule (01:00 UTC) : le décalage de 23 h UTC fait foi.
	return minuitNaif - Temps.decalageParis(minuitNaif - 3600) - maintenant
end
```

## 6. Laboratoire ↔ Prairie

1. **Capsule** : 6 places, départ 15 s après le premier passager. Les attributs `Passagers` et `Depart` sont posés sur le modèle.
2. **Fiche** : `ReserveServer`, puis écriture en MemoryStore de `Capsules[privateServerId] = {Mode, CleJour, UserIds, Code, Terminee}`, TTL 1 800 s.
3. **Téléport** : `Passage.Teleporter` lance `Donnees.Liberer(joueur, true)` en parallèle (3 essais).
   - Réussi : `TeleportAsync` avec `ReservedServerAccessCode`.
   - Échoué : session gardée, `Annonce("Sauvegarde")` affiche « Sauvegarde… », nouvel essai toutes les 15 s (4 fois), puis `PassageAnnule`.
   - Téléport refusé par Roblox : `Donnees.Charger` à nouveau.
4. **Arrivée sur la Prairie** : une fois le profil chargé, écriture de `RunsEnCours["RunEnCours_<UserId>"] = {Code, Mode}`, TTL 1 800 s, prolongé à chaque jour.
5. **Reprise** : au Laboratoire, `Player.RunEnCours = true` affiche « Rejoindre la run », qui envoie `DemandeCapsule("Rejoindre")`.
6. **Fin** : `CrediterRun(…, true)`, fiche marquée `Terminee`, entrées `RunEnCours` effacées, 12 s d'écran, retour au Laboratoire. Une Prairie rouverte sur une fiche `Terminee` renvoie les joueurs au Laboratoire.

## 7. Fichiers (`scripts/a27/`)

| Fichier | Emplacement |
|---|---|
| `Reseau.lua`, `ReglesRemotes.lua` | `ReplicatedStorage.Reseau` et son enfant |
| `Catalogue.lua`, `Temps.lua` | `ReplicatedStorage` |
| `SchemaJoueur.lua`, `Donnees.lua`, `Passage.lua`, `Run.lua` | `ServerScriptService.Modules` |
| `Persistance.server.lua` | `ServerScriptService`, deux places |
| `ServicesLaboratoire.server.lua` | `ServerScriptService`, Laboratoire |

## 8. Tests d'acceptation

- **20 allers-retours** Laboratoire → Prairie → Laboratoire, sur le serveur de bêta avec 3 comptes. Chaque passage journalise `[Solde] J_<UserId>` au chargement et à la libération. Écart toléré : 0, gains de run annoncés compris.
- **Double tap**, depuis la console du client :
  ```lua
  local r = game.ReplicatedStorage.Remotes.DemandeRecherche
  r:FireServer("Foreuse", 1)
  r:FireServer("Foreuse", 1)
  ```
  Attendu : `Recherches.Foreuse = 1`, 60 gemmes débitées une seule fois, second retour `Refus` / `NiveauVise`. Même test sur `DemandeAchat`.
- **Corruption** : écrire `Gemmes = "abc"` dans le store Studio. Attendu : chargement refusé, version précédente restaurée, aucune écriture intermédiaire.
- **Heure** : `SecondesAvantDemain(1792843200)` vaut 36 000 (heure d'été) et `SecondesAvantDemain(1792929600)` vaut 39 600 (lendemain de la bascule).
