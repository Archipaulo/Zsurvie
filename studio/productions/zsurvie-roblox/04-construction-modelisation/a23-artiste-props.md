# Zsurvie : kit de props modulaires

## 1. Principes du kit

- **Grilles :** le pivot de chaque prop tombe sur la grille décor de 1 stud. Les modules qui se raccordent aux bâtiments (barrières, tuyaux, néons) font 4 studs de long. Les détails sont au demi-stud (0,5), comme le pixel des personnages. On tourne par pas de 90°, avec 45° toléré pour la végétation de la Lisière.
- **Pivot :** pas de Part racine. Le `WorldPivot` est au centre de la face inférieure, face avant vers −Z. Un `PivotTo` pose donc le prop au sol sans décalage.
- **Le dessus d'abord :** la caméra à (0, 45, 28) montre surtout le dessus des objets. La face supérieure est en teinte lumière, les côtés en base, le socle en ombre.
- **Code couleur sur la run :** les props utilisent Terre battue, Crème, Prairie et Ardoise. Violet horde, Or et Alerte leur sont interdits (Zbires, pièces, danger). Gemme cyan est réservé à la Mine. Jamais d'orange au sol : le Tapis Collant est le seul objet plat orange. Au Laboratoire, Gemme cyan et Nuit labo sont libres.
- **Matériaux :** `SmoothPlastic` partout, `Neon` seulement pour les ampoules, écrans et cristaux. Tout est construit en Parts. Une `MeshPart` n'est autorisée que si elle remplace au moins 5 Parts, avec `CollisionFidelity = Box`.

## 2. Catalogue (29 entrées)

| Prop | L × H × P (studs) | Parts | Variantes | Catégorie | Zones |
|---|---|---|---|---|---|
| `PRP_Caisse_S` | 2 × 2 × 2 | 3 | Bois, PiqueNique, Mine, Labo | Bloquant | Lisière, Mine, Quai, Labo |
| `PRP_Caisse_M` | 4 × 4 × 4 | 5 | Bois, Mine, Labo | Bloquant | Lisière, Quai, Labo |
| `PRP_Caisse_Pile` | 4 × 6 × 4 | 8 | Bois, Labo | Bloquant | Lisière, Quai |
| `PRP_Panier` | 2 × 2 × 1 | 4 | Osier, Creme | Décor | Prairie |
| `PRP_Nappe` | 8 × 0,2 × 8 | 1 + `Texture` damier (`StudsPerTileU/V` = 4) | Creme/TerreBattue | Sol | Prairie, 1 par quadrant |
| `PRP_Lampe_Borne` | 1 × 2 × 1 | 3 (1 Neon) | Prairie (Crème), Labo (cyan) | Décor | bords des chemins, Quai |
| `PRP_Lampe_Lampadaire` | 1 × 6 × 1, tête 2 × 1 × 2 | 5 (1 Neon) | Allume (`PointLight`), Eteint | Bloquant | chemins (8 max), Quai |
| `PRP_Lampe_Lanterne` | 1 × 1 × 1 | 2 (1 Neon) | Porche (Crème), Mine (cyan) | Décor | porche de la Maison, Mine |
| `PRP_Lampe_Neon` | 4 × 0,5 × 0,5 | 1 Neon | Cyan, Orange | Décor | Labo, Quai, Galerie |
| `PRP_Barriere` | Droit 4 × 2 × 1, Coin 1 × 2 × 1, Porte 4 × 2 × 1 (passage de 2) | 1 à 3 | Bois, Labo | Bloquant | Lisière, Quai, Alcôves |
| `PRP_Cordon` | 4 × 2 × 1 | 3 | Musee | Bloquant | Galerie |
| `PRP_Fleur` | 1 × 1 × 1 | 2 | Creme, Prairie | Décor | Prairie |
| `PRP_Buisson` | S 2 × 2 × 2, M 3 × 3 × 3 | 2 à 3 | Clair, Fonce | S Décor, M Bloquant | S Prairie, M Lisière |
| `PRP_Souche` | 2 × 1 × 2 | 2 | Bois | Décor | Prairie |
| `PRP_Rocher` | S 2 × 1 × 2, M 3 × 2 × 3, L 4 × 3 × 4 | 1 à 3 | Ardoise | Bloquant | Lisière |
| `PRP_Arbre` | S 3 × 5 × 3, M 4 × 8 × 4, L 6 × 12 × 6 | 3 à 6 | Vert, Fleuri | Bloquant (tronc) | S Quai et Lisière, M et L Lisière seulement |
| `PRP_Rail` | Droit 4 × 0,5 × 2, Courbe 4 × 0,5 × 4, Fin 2 × 1 × 2 | 3 | Ardoise | Sol | Mine |
| `PRP_Wagonnet` | 2 × 2 × 3 | 5 (+2 Neon) | Vide, Plein | Bloquant | empreinte de la Mine |
| `PRP_Cristal` | S 1 × 2 × 1, M 1 × 3 × 1 | 1 à 2 Neon | Cyan | Décor | Mine uniquement |
| `PRP_Etai` | 4 × 5 × 1 | 3 | Bois | Bloquant | entrée de la Mine |
| `PRP_Tuyau` | Droit 4 × 1 × 1, Coude 2 × 2 × 1, Te 2 × 2 × 1 | 1 à 3 | Ardoise | Décor | murs et plafonds du Labo et du Quai |
| `PRP_Console` | 2 × 3 × 1 | 4 (écran Neon) | Cyan, Orange | Bloquant | Labo, Alcôves |
| `PRP_Etagere` | 4 × 4 × 1 | 8 | Fioles cyan, vertes, orange | Bloquant | Labo |
| `PRP_Banc` | 4 × 1 × 2 | 3 | Labo, Quai | Bloquant | Quai, Galerie |
| `PRP_Socle` | 4 × 1 × 4 | 2 (+ plaque) | Creme | Bloquant | Galerie des Zbires |
| `PRP_Panneau` | 2 × 3 × 1 | 3 + `SurfaceGui` | Fleche, Info | Bloquant | Quai, Labo |
| `DEF_Muret` | 4 × 3 × 1 | 4 + `Fissure_1`, `Fissure_2` | attribut `Etat` de 1 à 3 | Bloquant | Prairie, posé en jeu |
| `DEF_MiniTourelle` | 2 × 3 × 2 | 8 | — | Bloquant | Prairie, posée en jeu |
| `DEF_TapisCollant` | 4 × 0,2 × 4 | 2 | — | Sol | Prairie, posé en jeu |

Les défenses sont en Crème et Toit orange (« à nous »). Je livre les modèles, la logique reste au scripting.

## 3. Convention de nommage

- **Maîtres :** `PRP_<Famille>_<Forme>_<Variante>`, par exemple `PRP_Caisse_S_PiqueNique`, `PRP_Lampe_Lampadaire_Eteint` ou `PRP_Rail_Courbe_Ardoise`. La forme vaut S, M, L ou le nom d'un module (Droit, Coin, Porte, Courbe).
- **Défenses :** `DEF_Muret`, `DEF_MiniTourelle` et `DEF_TapisCollant`. Leurs états passent par des attributs, pas par des modèles séparés.
- **Noms d'instances en ASCII PascalCase**, sans accents ni espaces, pour que `FindFirstChild` ne rate jamais. Les accents restent dans l'UI.
- **Parts :** `Corps` pour le volume principal, `Collision` pour la boîte invisible (facultative), `Ampoule` pour le Neon, `Detail_<Quoi>` pour le reste.
- **Copies placées :** elles gardent le nom du maître et sont rangées par zone.
- **Attributs du Model :** `Kit` (string), `Categorie` (`Bloquant`, `Decor` ou `Sol`) et `Version` (number).
- **Attributs des Parts :** `Couleur`, qui reprend une clé de `Charte.Palette` (par exemple `TerreBattue`), et `Teinte` (`base`, `ombre` ou `lumiere`). On ne saisit jamais `Color` à la main.
- **Tag `PropLumiere` :** il est posé automatiquement sur tout prop qui contient une `PointLight`.

## 4. Organisation des dossiers

```text
ServerStorage
└─ KitPropsMaitres        Contenants, Lumieres, Barrieres, Nature, Mine, Laboratoire
ReplicatedStorage
├─ Charte                 ModuleScript (canon)
└─ KitProps
   ├─ Regles              ModuleScript (section 7)
   └─ Defenses            DEF_Muret, DEF_MiniTourelle, DEF_TapisCollant
Workspace (place Prairie)
├─ Carte
│  ├─ Maison              département bâtiments
│  └─ Props               Maison, Prairie, Chemins, Mine, Lisiere
└─ Dynamique              vide dans Studio, rempli par le serveur : Zbires, Defenses, Pieces
Workspace (place Laboratoire)
└─ Carte
   └─ Props               Laboratoire, QuaiCapsules, GalerieZbires, Alcoves
```

- **Les maîtres de décor restent en `ServerStorage` :** ils ne sont jamais répliqués et ne prennent donc aucune mémoire sur les téléphones. Chaque maître est un Package. Les copies placées gardent le lien, si bien qu'un « Update All » propage une correction au Laboratoire et à la Prairie.
- **Les défenses sont en `ReplicatedStorage` :** le client en clone un fantôme pour l'aperçu de pose. Le serveur clone le vrai modèle une fois la demande validée (distance, solde, 3 par Survivant).

## 5. Ancrage et collisions

| Part | Anchored | CanCollide | CanQuery | CanTouch |
|---|---|---|---|---|
| `Collision` (à défaut `Corps`) d'un Bloquant | true | true | true | false |
| Autres Parts d'un Bloquant | true | false | false | false |
| Parts d'un Décor ou d'un Sol | true | false | false | false |
| Fantôme de pose côté client (`Transparency` ≥ 0,5) | true | false | false | false |

- **Tout est ancré, rien n'est soudé :** aucun `Weld`, aucune contrainte, aucun coût physique, et aucun joueur ne peut pousser un prop.
- **`CanTouch = false` partout :** on ne branche aucune logique sur `Touched`. Le serveur détecte le Tapis Collant par la distance.
- **`CanQuery` suit la collision :** le serveur refuse ainsi une défense posée sur un prop grâce à `GetPartBoundsInBox`. Le tir ne vise que `Workspace.Dynamique.Zbires` (`RaycastParams.FilterType = Include`). Aucun prop ne bloque donc une balle ni le tir automatique à 40 studs.
- **Couloir libre :** les Zbires n'ont pas de physique et traversent les obstacles. Dans la Prairie (rayon de 70 studs), on ne place donc que des props Décor ou Sol de 2 studs de haut au plus. Seules exceptions : 8 lampadaires, 2 par chemin à 1 stud du bord, et les props de l'empreinte de la Mine. Dans la Lisière, aucun prop Bloquant sur les chemins ni dans un couloir de 8 studs entre chaque portail et la Maison. Le Muret reste ainsi le seul mur de l'arène.
- **Hauteur :** 6 studs au maximum à moins de 60 studs de la Maison, Mine comprise.
- **`CastShadow` :** `true` uniquement sur un `Corps` de 2 studs ou plus, jamais sur un Sol.

## 6. Budgets du kit

| Place | Parts | Parts `Neon` | `PointLight` |
|---|---|---|---|
| Prairie | 2 500 sur 10 000 | 40 sur 150 | 4 sur 12 (2 au porche, 2 à la Mine) |
| Laboratoire | 3 000 | 60 sur 150 | 6 sur 12 |

Sur la Prairie, les lampadaires sont en variante `Eteint` : leur ampoule Neon suffit à les lire, et les autres `PointLight` vont aux effets. Les lanternes sont réglées ainsi : `Range` 12, `Brightness` 1,5, `Shadows = false`, couleur Crème au porche et Gemme cyan à la Mine.

## 7. Module `Regles`

```lua
--!strict
-- ReplicatedStorage.KitProps.Regles (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charte = require(ReplicatedStorage:WaitForChild("Charte"))

local Regles = {}

local HAUTEUR_MAX = 6 -- studs (canon)
local RAYON_BAS = 60 -- studs autour de la Maison

export type Budget = { parts: number, neon: number, lumieres: number }

local function teinte(nom: string, t: string?): Color3
	local base: Color3 = Charte.Palette[nom]
	assert(base, `Couleur absente de la Charte : {nom}`)
	if t == "ombre" then
		return Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8)
	elseif t == "lumiere" then
		return base:Lerp(Charte.Palette.Creme, 0.2)
	end
	return base
end

-- fantome = true : aperçu de pose côté client
function Regles.appliquer(model: Model, fantome: boolean?)
	local categorie = model:GetAttribute("Categorie")
	assert(categorie, `{model:GetFullName()} : attribut Categorie manquant`)
	local solide: Instance? = nil
	if categorie == "Bloquant" and not fantome then
		solide = model:FindFirstChild("Collision") or model:FindFirstChild("Corps")
	end
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			local couleur = d:GetAttribute("Couleur")
			if typeof(couleur) == "string" then
				d.Color = teinte(couleur, d:GetAttribute("Teinte"))
			end
			d.Anchored = true
			d.CanTouch = false
			d.CanCollide = d == solide
			d.CanQuery = d == solide
			local grand = math.max(d.Size.X, d.Size.Y, d.Size.Z) >= 2
			d.CastShadow = not fantome and categorie ~= "Sol" and d.Name == "Corps" and grand
			if d.Name == "Collision" then
				d.Transparency = 1
			end
			if fantome then
				d.Transparency = math.max(d.Transparency, 0.5)
			end
		end
	end
	if model:FindFirstChildWhichIsA("PointLight", true) then
		model:AddTag("PropLumiere")
	end
end

function Regles.auditer(racine: Instance, centreMaison: Vector3, budget: Budget): { string }
	local erreurs: { string } = {}
	local parts, neon, lumieres = 0, 0, 0
	for _, d in racine:GetDescendants() do
		if d:IsA("BasePart") then
			parts += 1
			if d.Material == Enum.Material.Neon then
				neon += 1
			elseif d.Material ~= Enum.Material.SmoothPlastic then
				table.insert(erreurs, `{d:GetFullName()} : matériau {d.Material.Name}`)
			end
			if not d.Anchored or d.CanTouch then
				table.insert(erreurs, `{d:GetFullName()} : Anchored ou CanTouch`)
			end
		elseif d:IsA("PointLight") then
			lumieres += 1
		elseif d:IsA("Model") and d:GetAttribute("Kit") then
			local cf, taille = d:GetBoundingBox()
			local ecart = cf.Position - centreMaison
			local distance = Vector2.new(ecart.X, ecart.Z).Magnitude
			if distance < RAYON_BAS and taille.Y > HAUTEUR_MAX + 0.01 then
				table.insert(erreurs, `{d:GetFullName()} : {taille.Y} studs à {math.floor(distance)} studs`)
			end
		end
	end
	if parts > budget.parts then table.insert(erreurs, `Parts {parts}/{budget.parts}`) end
	if neon > budget.neon then table.insert(erreurs, `Neon {neon}/{budget.neon}`) end
	if lumieres > budget.lumieres then table.insert(erreurs, `PointLight {lumieres}/{budget.lumieres}`) end
	return erreurs
end

return Regles
```

Avant chaque publication, on lance ceci dans la barre de commande de Studio :

```lua
local R = require(game.ReplicatedStorage.KitProps.Regles)
local props = workspace.Carte.Props
for _, m in props:GetDescendants() do
	if m:IsA("Model") and m:GetAttribute("Kit") then R.appliquer(m) end
end
print(R.auditer(props, workspace.Carte.Maison:GetPivot().Position, { parts = 2500, neon = 40, lumieres = 4 }))
```

## 8. Ajouter un prop

1. Le construire dans `ServerStorage.KitPropsMaitres`, pivot au centre de la base et face avant vers −Z.
2. Nommer les Parts, remplir les attributs, puis lancer `Regles.appliquer`.
3. Contrôler le dessus avec la caméra de jeu (0, 45, 28), `FieldOfView` 50, dans l'émulateur téléphone de Studio.
4. Le convertir en Package, le placer, puis relancer `auditer` jusqu'à zéro erreur.
