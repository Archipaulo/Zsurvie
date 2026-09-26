# Zsurvie · Scripts client & UI (a28, Fanny Roux-Vidal) · révision du 02/10

## 1. Architecture client

| Fichier (`scripts/a28/`) | Emplacement Roblox | Rôle | Place |
|---|---|---|---|
| `UIKit.lua` | ReplicatedStorage › Client | Boîte à outils partagée : palette, rebond, `UIScale`, attentes, remotes, réglages, prix, crochets a10 | Les deux |
| `Hud.client.lua` | StarterPlayerScripts | Maquette HUD, bannières, voile d'étourdissement | Labo : Gemmes seules |
| `Controles.client.lua` | StarterPlayerScripts | Réparer, défenses, Ping, désignation, variante B de H2 | Prairie |
| `Etabli.client.lua` | StarterPlayerScripts | Bouton contextuel, panneau latéral, cagnotte | Prairie |
| `Effets.client.lua` | StarterPlayerScripts | Nombres de dégâts, pièces, étoiles, bulles de ping | Prairie |
| `CameraPrairie.client.lua` | StarterPlayerScripts | `Scriptable` (0, 45, 28), `FieldOfView` 50 | Prairie |
| `Reglages.client.lua` | StarterPlayerScripts | 5 réglages | Les deux |

- La place se reconnaît à `Workspace:GetAttribute("TypePlace")` (`"Laboratoire"` ou `"Prairie"`), lu après `game.Loaded`.
- Chaque `WaitForChild` attend 10 s au plus puis émet un `warn`. En cas d'échec, le script s'arrête proprement :

```lua
function UIKit.attendre(parent: Instance?, nom: string): Instance?
	if not parent then
		warn(`[a28] parent absent : {nom} ne peut pas être attendu`)
		return nil
	end
	local enfant = parent:WaitForChild(nom, UIKit.DELAI)
	if not enfant then
		warn(`[a28] {parent:GetFullName()}.{nom} introuvable après {UIKit.DELAI} s`)
	end
	return enfant
end
```

- **Supprimés** : ma boucle de tir, les traceurs, les remotes `Impact` et `Eclatement`, le pool de 90 cubes. Le tir revient à `BlasterControleur` (a26), l'éclatement au Z1 de a37.

## 2. Contrat serveur → client

| Source | Données lues | Usage |
|---|---|---|
| `ReplicatedStorage.EtatRun` | `Jour`, `Phase` (`Horde`/`Repit`), `FinPhase`, `Colosse`, `MaisonPV(Max)`, `ColossePV(Max)` | Bandeau, minuteur |
| `ReplicatedStorage.EtatRun` | `NivSolidite`, `NivReparation`, `NivRegeneration`, `CagnotteCle`, `CagnotteMontant`, `CagnotteObjectif`, `CagnotteContributeurs` (`"id,id"`) | Établi |
| Player | `Pieces`, `Gemmes`, `Defenses`, `EtourdiJusqua`, `Niv<Cle>` (dont `NivPortee`, `NivCadence`), `Verrou<Cle>`, `TestH2` | HUD, défenses |
| `Player.Reglages` | `TirAuto`, `Secousses`, `EffetsReduits`, `Musique`, `Effets` | Réglages |
| Modules | `Catalogue.prix(cle, niveauVise)`, `Plan.ETABLI`, `Plan.MAISON`, `BlasterStats.portee/cadence(niv)`, `ZbiresRendu.chercher/position`, `BlasterControleur.definirCiblePrioritaire`, `VfxClient.secouer` | — |

| Remote | Sens | Arguments |
|---|---|---|
| `DemandeReparation` | C→S | `true` à l'appui, `false` au relâchement |
| `DemandePose`, `DemandePing` | C→S | `cle`, `Vector3` |
| `DemandeAchat` | C→S | `cle`, `niveauVise` |
| `DemandeReglage` | C→S | `cle`, booléen ou 0 / 0,5 / 1 |
| `Annonce` | S→C | `Colosse`, `JourFranchi`, `Record`, `MaisonTombee`, `PiecesMaison {montant}`, `Refus {action, raison, cle}` |
| `ProfilMaj` | S→C | Fin de l'état Attente de l'Établi |
| `PiecesLachees` | S→propriétaire | `{ {id, position, montant, expireA} }` |
| `Butin` | S→propriétaire | `id, montant`, après le crédit |
| `PingDiffuse` | S→tous | `auteur, cle, position` |
| `Evenements` (Unreliable) | S→tous | Lots `{type = "Degats", position, valeur, critique, auteur, reduit}` |

Aucune demande ne porte de montant : le serveur fixe les prix, la part versée à la cagnotte et les crédits.

## 3. Maquette HUD unique (gabarit 800 × 360)

`UIScale` = clamp(min(X / 800, Y / 360), 1, 1,4), partagé via `UIKit.echelle`. `ScreenInsets` = `CoreUISafeInsets`, police `FredokaOne`, `UIStroke` Encre de 3 px.

| Zone | Élément | Taille (px) | Détail |
|---|---|---|---|
| Haut gauche (8, 8) | Pièces | 140 × 44 | Or, compteur roulant en 0,35 s (Gemmes cyan au Labo) |
| Sous le compteur | « +X » gris | 96 × 30 | Pastille Ardoise lumière, visible 2,5 s |
| Y = 8 + 88 × échelle | Réglages | 60 × 60 | Icône de la Charte, sinon 3 barres |
| Haut centre | Bandeau Maison (a32) | 280 × 66 | « JOUR X », minuteur `FinPhase − GetServerTimeNow()` (5 Hz), « MAISON 850 / 1 000 », jauge Colosse de 8 px |
| Haut droite | Têtes des Survivants | 6 × 32 | Contour Toit orange pour soi, Crème pour les autres, Alerte si étourdi |
| Bas droite | Grappe | 230 × 230, marge 12 | §4 |
| À gauche de la grappe | Établi | 72 | Écart de 12 px |

À 800 px de large, les zones ne se touchent pas : Pièces de 8 à 148, bandeau de 260 à 540, têtes de 580 à 792.

## 4. Contrôles

**Variante A (par défaut).** RÉPARER (96 px) occupe le coin. Muret, Mini-Tourelle, Tapis Collant et Ping (64 px) sont placés sur un arc de 150 px, avec 13,6 px entre deux boutons. **Aucun bouton de saut** : l'état `Jumping` est coupé sur l'Humanoid local, ce qui retire le bouton tactile.

```lua
local function surArc(index: number): Vector2
	local angle = math.rad(ANGLES_ARC[index])
	return CENTRE_REPARER + Vector2.new(math.cos(angle), math.sin(angle)) * RAYON_ARC
end
```

| Action | Tactile | Clavier | Manette |
|---|---|---|---|
| Tirer | Automatique ; un tap sur un Zbire le désigne comme cible prioritaire | Clic | — |
| Réparer | Maintenir RÉPARER | E | X |
| Défenses | Trois boutons de l'arc | 1, 2, 3 | Croix gauche, bas, droite |
| Ping | PING ouvre la Roue des Pings | Q, puis 1 à 4 | Croix haut |
| Établi | Bouton de 72 px | F | Y |

- Chaque défense affiche son prix `Catalogue.prix` en Or, ou en Alerte si le solde ne suffit pas. À la limite, elle se grise et affiche « 3/3 ». Si `Verrou<Cle>` > 0, un voile Encre la couvre avec un cadenas Crème et « Niv. X ».

```lua
reparer.bouton.InputBegan:Connect(function(entree: InputObject)
	local genre = entree.UserInputType
	if genre == Enum.UserInputType.Touch or genre == Enum.UserInputType.MouseButton1 then
		maintien = entree
		UIKit.rebond(reparer.bouton)
		commencerReparation() -- DemandeReparation(true)
	end
end)

local function finMaintien(entree: InputObject)
	if estMaintien(entree) then
		maintien = nil
		arreterReparation() -- DemandeReparation(false)
	end
end
reparer.bouton.InputEnded:Connect(finMaintien)
-- Filet : un doigt qui glisse hors du bouton se lève ailleurs ; on le rattrape ici.
UserInputService.InputEnded:Connect(finMaintien)
```

- Désignation : le marqueur suit la cible grâce à un seul appel par frame à `ZbiresRendu.position`.

```lua
local function designer(ecran: Vector2)
	if not (zbiresRendu and blaster) then
		return
	end
	local trouve, id = pcall(zbiresRendu.chercher, ecran, TOLERANCE_DESIGNATION)
	if not trouve or id == nil then
		return
	end
	pcall(blaster.definirCiblePrioritaire, id)
	cibleMarquee = id
	UIKit.son("Clic")
end
```

- **Variante B de H2**, activée si `Player.TestH2 == "B"`, sinon variante A au bout de 2 s : RÉPARER 96 px, POSER 72 px (roue des 3 défenses) et PINGS 72 px, avec 12 px d'écart. Les touches restent les mêmes.

## 5. Établi

- **Bouton** : le bouton contextuel de 72 px apparaît à 10 studs au plus de `Plan.ETABLI` et disparaît au-delà de 12 studs (contrôle à 4 Hz).
- **Ouverture** : automatique à l'entrée dans la zone **seulement si `Phase == "Repit"`**, sinon par le bouton, F ou ButtonY. Les taps sont ignorés pendant 0,8 s après l'ouverture.
- **Panneau** : latéral droit, 55 % de la largeur. Il s'arrête 24 px au-dessus de RÉPARER, qui reste utilisable (`DisplayOrder` 3 contre 2). L'arc est masqué pendant l'ouverture.
- **Cartes** : 2 colonnes, 64 px de haut, avec défilement. Chacune affiche le nom, l'aperçu `BlasterStats` pour Portée et Cadence (« 40 → 44 studs »), « Niv. 2 → 3 » et `Catalogue.prix(cle, niveauVise)`.
- **Achat** : `DemandeAchat(cle, niv + 1)` fait passer la carte en Attente (voile « … ») jusqu'à `ProfilMaj` ou une `Annonce` portant sa clé, avec un filet de 4 s. En cas de refus, la carte tremble de ±6°.
- **Cagnotte** (colonne de 36 %) : amélioration et niveau visé, jauge Or « montant / objectif », 6 têtes de contributeurs au plus. Toucher une carte ÉQUIPE revient à contribuer ; le serveur prélève min(solde, reste).

## 6. Retours visuels

| Déclencheur | Retour |
|---|---|
| Appui, gain, annonce | Rebond du canon (× 0,8 / × 1,2), 3 × 0,05 s |
| `PiecesLachees` | La pièce apparaît en 0,15 s, flotte et tourne (un seul `BulkMoveTo` ; immobile avec `EffetsReduits`) |
| `expireA` − 3 s | Clignote à 2,5 Hz, sous le seuil de 3 flashs/s |
| `expireA` | File vers `Plan.MAISON` + 8 studs en 0,6 s |
| `Butin` | Aspirée vers le Survivant en 0,2 s, « +N » en Or |
| `PiecesMaison` (Répit) | « +X » gris sous le compteur |
| `Degats` | Crème ; critique en Toit orange ; Casqué sans critique en gris avec « Tink » ; des coéquipiers, seuls les critiques s'affichent |
| Colosse, étourdissement, Maison −5 % | `UIKit.secouer` de 0,8, 0,6 et 0,3 stud (plafond 0,8) |

## 7. Réglages et crochets

- **Réglages** : boutons de 252 × 60 px. Un tap envoie `DemandeReglage`, mais l'affichage ne change qu'une fois que le serveur a écrit `Player.Reglages` (filet de 3 s). Effets de chaque réglage :
  - `Musique` et `Effets` : cycle 100 / 50 / 0 % sur les `SoundGroup` du même nom ;
  - `Secousses` : coupe `UIKit.secouer` ;
  - `TirAuto` : lu par `BlasterControleur` ;
  - `EffetsReduits` : immobilise les pièces et masque les critiques des coéquipiers.
- **Crochets a10** : `UIKit.pulser("Muret", true)`, `UIKit.pulser("Ping", true, "PingColosse")`, puis `UIKit.pulser(nom, false)` pour arrêter. Le contour pulse en Crème (5 px, 0,4 s). L'icône vient de `Charte.Icones` ; en son absence, le bouton garde son texte. En variante B, c'est POSER qui pulse.

## 8. Performance et sécurité

- Pools fixes : 20 nombres, 60 pièces, 6 bulles. Rien n'est créé pendant le combat. Aucune Part `Neon` ni `PointLight`.
- `Heartbeat` ne sert qu'aux pièces et `RenderStepped` qu'au marqueur. Le minuteur tourne à 5 Hz, RÉPARER et l'Établi à 4 Hz.
- Sons UI espacés d'au moins 80 ms. Pings limités à 4 phrases fixes.

## 9. Écarts et points à valider

- **Pas de saut sur la Prairie** : ajout au canon, confirmé par le chef de projet. Reste à valider par Victor Lanoue.
- **`TirAuto` actif par défaut sur tous les appareils** : le canon §8 le prévoit seulement sur mobile. Le réglage permet de le couper.
- Les attributs `Verrou<Cle>` et `Cagnotte*` sont des noms proposés, encore à confirmer.
