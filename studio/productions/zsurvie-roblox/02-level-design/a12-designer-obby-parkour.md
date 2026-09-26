## 1. Mouvement de référence (Laboratoire et Prairie)

Réglages identiques dans les deux places, jamais modifiés en cours de jeu : toutes les cotes de ce document en dépendent.

| Propriété | Valeur |
|---|---|
| `StarterPlayer.CharacterWalkSpeed` | 16 |
| `StarterPlayer.CharacterUseJumpPower` | false |
| `StarterPlayer.CharacterJumpHeight` | 7,2 |
| `Workspace.Gravity` | 196,2 |

Vitesse d'impulsion : √(2 × 196,2 × 7,2) = 53,2 studs/s. Temps de vol à plat : 0,54 s. Portée à plat : 8,7 studs.

**Portées bord à bord** (Δh = hauteur d'arrivée − hauteur de départ, en studs) :

| Δh | Portée théorique | Facile (60 %) | Moyen (75 %) | Expert (92 %) |
|---|---|---|---|---|
| +6 | 6,1 | interdit | interdit | 5,5 |
| +4 | 7,2 | 4 | 5,5 | 6,5 |
| +2 | 8,0 | 4,5 | 6 | 7,5 |
| 0 | 8,7 | 5 | 6,5 | 8 |
| −2 | 9,2 | 5,5 | 7 | 8,5 |
| −4 | 9,7 | 6 | 7 | 9 |

**Règles mobile d'abord**
- Un joystick incliné à moitié donne environ 10 studs/s : un saut obligatoire ne dépasse jamais la colonne « Moyen ». La colonne « Expert » est réservée aux raccourcis.
- Plateforme obligatoire : 3 × 3 studs minimum. Le 2 × 3 est réservé aux raccourcis.
- Les enchaînements restent dans un cône de ±30°. Les virages se font sur un palier de repos d'au moins 6 × 6, au plus tous les 3 sauts.
- Marche franchie sans sauter : 1 stud. Rebord grimpé d'un saut : 5 studs (6 en raccourci).
- Grimpe : `TrussPart` Ardoise #4A4560, 2 studs de large, 12 studs maximum d'un seul tenant.
- Lecture : dessus Crème #F6E7C1, flancs Ardoise, liseré d'appel Toit orange #EF7A2F de 0,5 stud, sur fond Nuit labo #2A3263.
- Ni `KillBrick` ni vide : on ne meurt jamais, lobby compris (pilier 2).

## 2. Le Laboratoire : la Tuyauterie de Doc Boulon

C'est un parcours facultatif d'environ 180 studs, qui s'enroule au-dessus de l'anneau des 12 Alcôves, de Y 0 à Y 28. En grimpant, on voit d'en haut les machines de recherche de tous les joueurs (pilier 3). Aucun saut n'est obligatoire pour aller du spawn aux Alcôves, à Doc Boulon ou au Quai des Capsules.

### Sections et courbe de difficulté

| Section | Y | Sauts | Écarts | Δh | Supports | Élément signature | Réussite visée au 1er essai |
|---|---|---|---|---|---|---|---|
| A. Les Paillasses (CP0 → CP1) | 0 → 10 | 7 | 4 → 5 (4,5 max en montée) | +1 / +2 | 6 × 6 puis 4 × 4 | `TrussPart` de 4 studs (apprend la grimpe) | 95 % |
| B. Les Tuyaux (CP1 → CP3) | 10 → 18 | 9 | 5,5 → 6,5 (6 max en montée) | ±2 | tuyaux carrés de 3 de large | 3 Clapets rythmés, puis `TrussPart` de 6 studs | 80 % |
| C. La Couronne des Néons (CP3 → CP5) | 18 → 28 | 8 | 6 → 7 (7 seulement en descente) | ±2 | caissons suspendus 3 × 3 | Ressort final vers la Passerelle de Doc Boulon | 60 % |

- **Clapets** : plateformes 4 × 4 présentes 1,5 s puis absentes 1,5 s. Elles clignotent en Alerte #FF2E63 pendant les 0,4 dernières secondes. Chaque client calcule la phase avec `workspace:GetServerTimeNow() % 3` et bascule `CanCollide` et `Transparency` en local : tout le monde voit le même rythme, sans latence.
- **Ressort final** (Y 18) : un LocalScript pose une `AssemblyLinearVelocity` verticale de 70 studs/s (apogée 12,5 studs). Le joueur se dirige en l'air vers la Passerelle, 10 studs plus haut.
- **Durées cibles** : 75 s au premier essai, 45 s ensuite, 24 s en expert.

### Checkpoints (un toutes les 15 s de jeu au premier essai)

| CP | Emplacement | Y |
|---|---|---|
| CP0 Départ | Pied de la Tuyauterie, à côté de Doc Boulon | 0 |
| CP1 | Fin des Paillasses | 10 |
| CP2 | Après les Clapets | 12 |
| CP3 | Sommet de la grimpe | 18 |
| CP4 | Milieu de la Couronne | 22 |
| CP5 Arrivée | Passerelle de Doc Boulon, face à l'Arbre des Recherches | 28 |

- **Instance** : une Part 6 × 1 × 6 `SmoothPlastic` Ardoise et un anneau `Neon` Gemme cyan #33D6F0, soit 6 Parts `Neon` sur le budget de 150. Tag `Checkpoint`, attribut `Index`.
- **Activation** : l'anneau passe au cyan pour ce joueur seulement (RemoteEvent `ParcoursRetour`), avec un bip chiptune.
- **Filets** : sous chaque support placé à plus de 8 studs du sol, un filet Crème tendu 6 à 8 studs plus bas, tagué `ZoneChute`. Le toucher ramène au dernier checkpoint. Une chute coûte au pire 15 s. Plus bas, le sol du Laboratoire sert de filet.

### Raccourcis experts (aucun ne saute un checkpoint)

| Raccourci | Où | Geste | Gain |
|---|---|---|---|
| R1 « Le Coup de rein » | A, avant CP1 | Rebord de 6 studs grimpé d'un saut | −4 s |
| R2 « Le Coude » | B, avant CP2 | 8 studs à plat depuis une console 2 × 3 | −6 s |
| R3 « La Lampe » | C, entre CP4 et l'Arrivée | 9 studs en Δh −4 depuis CP4 jusqu'à la lampe de Doc Boulon, puis 5 studs à plat vers le Ressort final | −10 s |

### Sortie rapide : la règle des 11 secondes

Une Capsule part 15 s après le premier embarquement. Depuis n'importe quel point de la Tuyauterie, le Quai des Capsules doit être à 11 s au plus :
- Toboggan de l'Arrivée → Quai des Capsules : 4 s.
- Trappes de sortie 4 × 4 à CP2 et CP4, hors de l'aplomb des filets : chute libre jusqu'au sol en moins de 0,6 s.
- Sol → Quai : 112 studs au plus, soit 7 s de marche.

### Revenir chaque jour

- Tableau « Record du Jour » sur la Passerelle : les 10 meilleurs chronos du jour (`OrderedDataStore` daté), remis à zéro chaque nuit.
- Badge « Tuyauterie » au premier passage. Le parcours ne donne aucune gemme : le canon fixe leurs sources, et il n'en fait pas partie.

## 3. Galerie des Zbires et Quai des Capsules

- **Sauteur-trampoline** : la figurine du Sauteur (socle à Y 4) renvoie vers le haut à 60 studs/s (apogée Y 13). Elle donne accès à la mezzanine (Y 10), d'où l'on voit toutes les figurines et leurs variantes.
- **Grimpe du Colosse** : figurine de 24 studs de haut. Son dos est fait de 2 `TrussPart` de 12 studs séparées par un palier d'épaule 4 × 4. La tête est un belvédère 6 × 6 tagué `ZoneBadge`, qui donne le badge « Sur la tête du Colosse ».
- **Quai des Capsules** : sol plat, aucun obstacle, un accès de 10 studs de large devant chacune des 3 Capsules.

## 4. La Prairie : courir vite, lire le terrain

Avec la caméra `Scriptable` décalée de (0, 45, 28), il n'y a pas de plateformes : la traversée se joue sur la fluidité. À 16 studs/s, on va de la Maison à la Haie de Lisière en 4,6 s et on traverse toute la Prairie en 9,2 s.

| Rayon depuis la Maison (studs) | Règle |
|---|---|
| 0 à 20 | Maison et Mine. Sol plat, aucun décor collidable |
| 20 à 45 | Décor de 1 stud maximum en `CanCollide` false (fleurs, nappes de pique-nique) |
| 45 à 66 | Îlots de 3 studs maximum (sautables), espacés de 12 studs minimum, jamais sur un chemin |
| 66 à 74 | Décor de 6 studs maximum, premiers cubes de la Lisière |
| 74 | Haie de Lisière : 5 studs visibles et un mur invisible de 16 studs (collision avec le groupe `Survivants` seulement). Les portails violets restent entre 85 et 95 studs |

- **Chemins en croix** : 8 studs de large, Terre battue #C8894F, aucun décor. Ce sont des repères de direction lisibles depuis la caméra.
- **Relief** : toute la Prairie est à Y 0, sans aucune marche de plus de 1 stud. Sur téléphone, un saut raté en pleine horde est une frustration gratuite.
- **Muret** : 3 studs de haut, pour qu'un Survivant le franchisse d'un saut. La pose est interdite à moins de 6 studs de la porte de la Maison et sur les zones d'atterrissage : personne ne peut enfermer un coéquipier.
- **Ressorts de retour** (raccourci de run) : 4 Parts 4 × 1 × 4 à 58 studs, sur les diagonales. Chacun lance vers le rayon 22 : D = 36 studs et t = 0,75 s, soit 48 studs/s à l'horizontale et 73,6 studs/s à la verticale (apogée 13,8 studs). Recharge : 3 s par joueur. Zone d'atterrissage 6 × 6 laissée libre. Si la Mine tombe sur la diagonale d'un Ressort, on décale ce Ressort de 15°.
- **Colosse** : si son attaque produit une onde au sol, elle fait au plus 1,5 stud de haut et avance au plus à 30 studs/s. Elle reste ainsi sautable (0,54 s en l'air).

## 5. Script serveur du parcours

Tags posés dans Studio : `Checkpoint` (attribut `Index` de 0 à 5), `ZoneChute` (filets), `ZoneBadge` (attribut `BadgeId`). Le client ne fait qu'afficher. Son chrono HUD est indicatif : seul le temps serveur est enregistré.

```lua
-- ServerScriptService/Laboratoire/Parcours.server.lua
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local BadgeService = game:GetService("BadgeService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BADGE_TUYAUTERIE = 0 -- ID du badge publié (0 = désactivé)
local INDEX_ARRIVEE = 5
local CHRONO_MIN = 15 -- s : un chrono plus court est rejeté
local ECART_MIN = 2 -- s minimum entre deux checkpoints

local retour = Instance.new("RemoteEvent")
retour.Name = "ParcoursRetour"
retour.Parent = ReplicatedStorage

type Etat = {
	index: number,
	depart: number?,
	dernier: number,
	reprise: BasePart?,
	badges: { [number]: boolean },
}
local etats: { [Player]: Etat } = {}

local function joueurDe(hit: BasePart): Player?
	local modele = hit:FindFirstAncestorOfClass("Model")
	return if modele then Players:GetPlayerFromCharacter(modele) else nil
end

local function attribuerBadge(joueur: Player, etat: Etat, id: number)
	if id == 0 or etat.badges[id] then return end
	etat.badges[id] = true
	task.spawn(function()
		pcall(BadgeService.AwardBadge, BadgeService, joueur.UserId, id)
	end)
end

local function enregistrerChrono(joueur: Player, duree: number)
	local centiemes = math.floor(duree * 100)
	-- Clé de jour à aligner sur celle du Défi du Jour.
	local store = DataStoreService:GetOrderedDataStore("Tuyauterie_" .. os.date("!%Y%m%d"))
	local ok, err = pcall(store.UpdateAsync, store, tostring(joueur.UserId), function(ancien: number?)
		if ancien and ancien <= centiemes then return nil end
		return centiemes
	end)
	if not ok then warn("[Parcours] chrono non enregistré :", err) end
end

local function surCheckpoint(cp: BasePart, hit: BasePart)
	local joueur = joueurDe(hit)
	local etat = joueur and etats[joueur]
	local index = cp:GetAttribute("Index")
	if not (joueur and etat and typeof(index) == "number") then return end
	local t = os.clock()
	if index == 0 then -- Départ : le chrono part au dernier contact
		etat.index, etat.depart, etat.dernier, etat.reprise = 0, t, t, cp
		return
	end
	local depart = etat.depart
	if index ~= etat.index + 1 or not depart or t - etat.dernier < ECART_MIN then return end
	etat.index, etat.dernier, etat.reprise = index, t, cp
	retour:FireClient(joueur, "Checkpoint", index)
	if index == INDEX_ARRIVEE then
		etat.depart = nil
		local duree = t - depart
		if duree < CHRONO_MIN then return end
		retour:FireClient(joueur, "Arrivee", duree)
		attribuerBadge(joueur, etat, BADGE_TUYAUTERIE)
		task.spawn(enregistrerChrono, joueur, duree)
	end
end

local function surChute(_zone: BasePart, hit: BasePart)
	local joueur = joueurDe(hit)
	local etat = joueur and etats[joueur]
	local perso = joueur and joueur.Character
	if etat and etat.reprise and perso then
		perso:PivotTo(etat.reprise.CFrame + Vector3.new(0, 4, 0))
	end
end

local function surZoneBadge(zone: BasePart, hit: BasePart)
	local joueur = joueurDe(hit)
	local etat = joueur and etats[joueur]
	local id = zone:GetAttribute("BadgeId")
	if joueur and etat and typeof(id) == "number" then
		attribuerBadge(joueur, etat, id)
	end
end

local function lier(tag: string, rappel: (BasePart, BasePart) -> ())
	local function brancher(inst: Instance)
		if inst:IsA("BasePart") then
			inst.Touched:Connect(function(hit) rappel(inst, hit) end)
		end
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(brancher)
	for _, inst in CollectionService:GetTagged(tag) do brancher(inst) end
end

local function initialiser(joueur: Player)
	etats[joueur] = { index = 0, dernier = 0, badges = {} }
end

Players.PlayerAdded:Connect(initialiser)
Players.PlayerRemoving:Connect(function(joueur) etats[joueur] = nil end)
for _, joueur in Players:GetPlayers() do initialiser(joueur) end

lier("Checkpoint", surCheckpoint)
lier("ZoneChute", surChute)
lier("ZoneBadge", surZoneBadge)
```
