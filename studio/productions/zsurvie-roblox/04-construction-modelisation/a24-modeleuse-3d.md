## 1. Principes Pixel-bloc pour les meshes

- **Une MeshPart = une couleur de la Charte.** `TextureID` reste vide et le `Material` est `SmoothPlastic`, sauf `Neon` quand le nom finit par `__Neon`. Les textures ne coûtent donc aucune mémoire. La couleur vient de `ReplicatedStorage.Charte` : flash de dégâts, Capsules et variantes de la Galerie se font par recoloration.
- **Grilles** (snap Increment dans Blender) : 0,5 stud pour les personnages, le Blaster et le Sac à dos ; 1 stud pour le décor ; 4 studs pour la Maison, les Alcôves et le Quai.
- **Topologie** : faces internes supprimées, faces coplanaires de même couleur dissoutes, ombrage plat, maillage triangulé, aucune arête non-manifold.
- **Réutilisation** : un seul `MeshId` par forme. La Galerie, la Tourelle de toit et la Foreuse de l'Alcôve reprennent les meshes de la run. Roblox regroupe au rendu les MeshParts qui ont le même `MeshId` et le même `Material`.
- **Lisibilité** : à part la Maison, rien ne dépasse 6 studs de haut à moins de 60 studs de la Maison. Le Colosse est compris dans la règle.
- **Animation** : un Zbire, ce sont 2 à 5 MeshParts rigides que le client déplace par CFrame, sans skinning ni `Humanoid`. Seuls le Colosse et Doc Boulon ont un rig `Motor6D` avec un `AnimationController`.

## 2. MeshParts à produire

### Run (place Prairie)

| Asset | L × H × P (studs) | MeshParts | Tris max | Point clé |
|---|---|---|---|---|
| Marcheur | 2 × 2,5 × 2 | 4 | 400 | Mesh étalon du bestiaire |
| Rapide | 1,5 × 2 × 2,5 | 4 | 350 | Penché, silhouette en flèche |
| Costaud | 3,5 × 3,5 × 3 | 5 | 700 | Piquants séparés en `VioletHorde_Lumiere` |
| Doré | 2 × 2,5 × 2 | 4 | 450 | Corps `Or` |
| Sauteur | 2 × 2 × 2 | 4 | 400 | Ressorts séparés pour l'étirement × 1,2 |
| Gluant | 3 × 2 × 3 | 3 | 350 | Goutte en escalier |
| Mini-Gluant | 1,5 × 1 × 1,5 | 2 | 150 | Mesh à part, qui garde le pixel de 0,5 stud |
| Volant | 2,5 × 1,5 × 2 | 4 | 450 | Ailes séparées, corps à +4 studs, au-dessus du Muret |
| Casqué | 2,5 × 3 × 2,5 | 5 | 600 | Casque `Ardoise` séparé |
| Colosse | 9 × 6 × 9 | 12 | 3 000 | Trapu : il respecte les 6 studs et ne masque pas la Maison |
| Pièce | 1 × 1 × 0,25 | 1 | 60 | Pool de 200 |
| Gemme | 0,8 × 1 × 0,8 | 1 | 40 | Pool de 60 |
| Maison (3 états) | 16 × 14 × 16 | 8 à 12 | 3 500 par état | Socle commun aux 3 états, `Attache_TourelleToit` |
| Tourelle de toit | 3 × 3 × 3 | 4 | 600 | Canon pivotant |
| Mine | 8 × 5 × 8 | 6 | 1 500 | 4 cristaux `__Neon`, `Attache_Foreuse` |
| Foreuse | 3 × 5 × 3 | 3 | 500 | Mèche tournante |
| Établi | 6 × 4 × 4 | 5 | 1 200 | `Creme` et `ToitOrange` |
| Muret | 4 × 3 × 1 | 2 | 150 | Grille de 1 stud |
| Mini-Tourelle | 2 × 3 × 2 | 3 | 500 | Tête pivotante |
| Tapis Collant | 4 × 0,2 × 4 | 1 | 80 | Bulles en relief |
| Blaster | 1 × 1 × 2,5 | 3 | 300 | `Tool.Handle`, `Attache_Canon` |
| Sac à dos | 2 × 2 × 1 | 2 | 250 | `Accessory` sur `BodyBackAttachment` |
| Portail violet | 8 × 10 × 2 | 2 | 400 | 8 exemplaires, voile `__Neon` |
| Arbre-cube (3 variantes) | 6 × 10 à 16 × 6 | 2 | 200 | Lisière seulement, à plus de 70 studs |
| Kit Prairie (15 meshes) | 6 de haut au maximum | 1 à 3 | 30 à 300 | Nappe, panier, rochers, buissons, fleurs, clôture, borne |

**Budget de la Prairie** : 90 000 triangles visibles au maximum au pic (60 Zbires ≈ 27 000, décor ≈ 45 000, bâtiments ≈ 8 000, Colosse 3 000) et 70 meshes uniques au maximum.

### Lobby (place Laboratoire)

| Asset | L × H × P (studs) | MeshParts | Tris max | Point clé |
|---|---|---|---|---|
| Doc Boulon | 2 × 5 × 1,5 | 10 | 2 500 | Rig `Motor6D`, pivot aux pieds |
| Arbre des Recherches | 16 × 20 × 16 | 10 | 6 000 | Branches `__Neon` cyan |
| Alcôve | 12 × 12 × 12 | 4 | 1 500 | 12 exemplaires en anneau, même `MeshId` |
| Machines : Balles perforantes, Visée critique | 4 × 6 × 4 au maximum | 3 à 5 | 1 000 | Tourelle de toit et Foreuse : meshes de la run sur un socle |
| Capsule | 8 × 12 × 8 | 5 | 2 500 | 1 mesh en 3 couleurs : Normale `Creme`, Difficile `Alerte`, du Jour `Or` |
| Quai (6 modules) | 4 à 8 de côté | 1 à 3 | 400 | Kit modulaire sur la grille de 4 studs |
| Socle de la Galerie | 4 × 2 × 4 | 1 | 100 | Figurines = meshes des Zbires à l'échelle 1 |
| Accessoires de variantes | 1,5 au maximum | 1 | 150 | 16 meshes : à 10 éliminations, recoloration ; à 100 et 1 000, un accessoire sur `Attache_Tete` |

**Budget du Laboratoire** : 120 000 triangles et 60 meshes uniques au maximum.

## 3. Pipeline Blender → Roblox

**Scène Blender**
1. Dans `Scene Properties > Units`, régler `Unit System` sur `None` : 1 unité Blender = 1 stud.
2. Origine : le centre de l'emprise au sol, placé en (0, 0, 0). La face avant regarde vers -Y (vue Front, pavé 1).
3. Nommer les objets `Asset_Piece__CleCharte[__Neon]`, par exemple `Casque_Casque__Ardoise_Ombre` ou `Mine_Cristal__GemmeCyan__Neon`.
4. Nettoyer dans cet ordre : Apply All Transforms, Merge by Distance 0,001, Select Interior Faces puis Delete, Dissolve Limited à 1° (Delimit : Material), Triangulate (Beauty), Shade Flat, Recalculate Outside.

**Export FBX** (preset `Zsurvie_Roblox`) : Selected Objects, types Mesh et Empty, Scale 1,00, Apply Scalings `FBX All`, Forward `-Z`, Up `Y`, Apply Transform coché, Smoothing `Face`.

**Étalonnage** : le cube `Etalon` de 1 × 1 × 1 doit arriver avec une `Size` de (1, 1, 1). Sinon, on corrige `Scale Unit` dans l'importeur, jamais en redimensionnant dans Studio.

**3D Importer** : cocher `Anchored`, décocher `Merge Meshes` (une MeshPart par couleur), cocher le pivot sur l'origine de la scène et décocher `Insert Using Scene Position`. Si le `LookVector` du pivot ne sort pas par la face avant, changer `World Forward`.

**Après l'import**
- Régler le `PivotOffset` des pièces mobiles sur leur axe : tête de la Mini-Tourelle, canon de la Tourelle de toit, mèche de la Foreuse, ailes du Volant.
- Poser les `Attachment` : `Attache_TourelleToit`, `Attache_Foreuse`, `Attache_Canon` et `Attache_Tete`.
- Ranger les assets dans `ReplicatedStorage.Assets.Zbires`, `.Butin`, `.Defenses` et `.Equipement`. Le décor fixe va dans `Workspace.Prairie.Decor` et dans `Workspace.Laboratoire`.
- Poser un tag `CollectionService` sur le `Model`, puis lancer le script d'audit.
- Sources : `Zsurvie/Meshes/<Categorie>/<Asset>_v##.blend`.

## 4. Collisions et rendu

| Tag | Assets | `CollisionFidelity` | `RenderFidelity` | `CanCollide` / `CanQuery` | `CastShadow` |
|---|---|---|---|---|---|
| `Mesh_Zbire` | Zbires, Colosse, Pièce, Gemme | `Box` | `Precise` | false / false | Pièces `_Corps` seulement |
| `Mesh_Batiment` | Maison, Mine, Établi, Capsule, Alcôve, Arbre des Recherches | `Box` | `Precise` | false / false | true |
| `Mesh_Solide` | Muret, Mini-Tourelle, clôture | `Box` | `Automatic` | true / true | true |
| `Mesh_Rocher` | Rochers de la Prairie | `Hull` | `Automatic` | true / true | true |
| `Mesh_Decor` | Fleurs, nappe, Tapis Collant, buissons | `Box` | `Automatic` | false / false | false |
| `Mesh_Lointain` | Arbres-cubes, portails | `Box` | `Performance` | false / false | false |

- `Default` et `PreciseConvexDecomposition` sont interdits : sur mobile, ils coûtent de la mémoire physique et du temps de chargement.
- Les bâtiments ne collisionnent pas par leur mesh mais par des Parts invisibles, rangées dans un dossier `Collisions` (`Transparency` à 1, `CanCollide` à true) : un bloc de 16 × 14 × 16 pour la Maison, un bloc de 8 × 5 × 8 pour la Mine, et pour la Capsule le sol, 3 murs et le seuil.
- Chaque Zbire a une Part invisible `Hitbox` (`CanQuery` à true) pour le clic sur PC. Le tir automatique sur mobile et les validations passent par les positions calculées par le serveur. `CanTouch` est à false partout : l'effet du Tapis Collant est aussi calculé par le serveur.
- Avec la caméra en (0, 45, 28), tout reste à moins de 250 studs : `Automatic` donne donc le même rendu que `Precise`. On force `Precise` pour protéger les silhouettes et `Performance` pour la Lisière.
- `CollisionFidelity` et `RenderFidelity` ne se modifient pas en jeu. On les règle en mode édition avec le script ci-dessous.

## 5. Script d'audit (barre de commande de Studio)

```lua
-- Mode édition, après chaque import. Règle les MeshParts taguées Mesh_* et signale les écarts.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charte = require(ReplicatedStorage.Charte)
local palette = Charte.Couleurs or Charte
local CREME = palette.Creme or Color3.fromHex("F6E7C1")
local CF, RF = Enum.CollisionFidelity, Enum.RenderFidelity

local PRESETS = {
	Mesh_Zbire = { collision = CF.Box, rendu = RF.Precise, solide = false, ombre = false },
	Mesh_Batiment = { collision = CF.Box, rendu = RF.Precise, solide = false, ombre = true, grille = 4 },
	Mesh_Solide = { collision = CF.Box, rendu = RF.Automatic, solide = true, ombre = true, grille = 1 },
	Mesh_Rocher = { collision = CF.Hull, rendu = RF.Automatic, solide = true, ombre = true, grille = 1 },
	Mesh_Decor = { collision = CF.Box, rendu = RF.Automatic, solide = false, ombre = false, grille = 1 },
	Mesh_Lointain = { collision = CF.Box, rendu = RF.Performance, solide = false, ombre = false, grille = 1 },
}

local function couleur(cle: string): Color3?
	if typeof(palette[cle]) == "Color3" then
		return palette[cle]
	end
	local base, teinte = string.match(cle, "^(%w+)_(%a+)$")
	local c = base and palette[base]
	if typeof(c) ~= "Color3" then
		return nil
	elseif teinte == "Ombre" then
		return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
	elseif teinte == "Lumiere" then
		return c:Lerp(CREME, 0.2)
	end
	return nil
end

local function horsGrille(v: number, pas: number): boolean
	local r = v % pas
	return math.min(r, pas - r) > 0.01
end

local reglees, neons, alertes = 0, 0, 0
local function alerte(objet: Instance, message: string)
	alertes += 1
	warn(("[Audit] %s : %s"):format(objet:GetFullName(), message))
end

for tag, p in PRESETS do
	for _, racine in CollectionService:GetTagged(tag) do
		if not racine:IsA("PVInstance") then
			alerte(racine, "tag posé sur autre chose qu'un Model ou une Part")
			continue
		end
		local pivot = racine:GetPivot().Position
		if p.grille and (horsGrille(pivot.X, p.grille) or horsGrille(pivot.Z, p.grille)) then
			alerte(racine, ("pivot hors de la grille de %d studs"):format(p.grille))
		end
		local pieces = racine:GetDescendants()
		table.insert(pieces, racine)
		for _, part in pieces do
			if not part:IsA("MeshPart") then
				continue
			end
			local segments = string.split(part.Name, "__")
			local teinte = segments[2] and couleur(segments[2])
			if teinte then
				part.Color = teinte
			else
				alerte(part, "clé de Charte absente ou inconnue dans le nom")
			end
			if (part.Size - part.MeshSize).Magnitude > 0.01 then
				alerte(part, "Size différente de MeshSize : corriger l'échelle dans Blender")
			end
			local neon = segments[3] == "Neon"
			part.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
			part.TextureID = ""
			part.CollisionFidelity = p.collision
			part.RenderFidelity = p.rendu
			part.Anchored = true
			part.CanCollide = p.solide
			part.CanQuery = p.solide
			part.CanTouch = false
			part.CastShadow = p.ombre or string.find(part.Name, "_Corps", 1, true) ~= nil
			reglees += 1
			if neon and part:IsDescendantOf(workspace) then
				neons += 1
			end
		end
	end
end

print(("[Audit] %d MeshParts réglées, %d alertes, %d Neon dans Workspace (plafond : 150)"):format(reglees, alertes, neons))
```

## 6. Ordre de production

| Priorité | Phase | Assets | Objectif |
|---|---|---|---|
| P0 | 1 | Cube étalon, Marcheur, Pièce, Gemme, proxys de collision de la Maison, de la Mine et de l'Établi | Valider le pipeline, l'échelle et la lisibilité sur mobile |
| P1 | 3 | Les 7 autres Zbires, le Mini-Gluant, la Maison (3 états), la Mine, l'Établi, le Muret, la Mini-Tourelle, le Tapis Collant, le Blaster, le Sac à dos | Une run jouable |
| P2 | 2 et 3 | Colosse, Tourelle de toit, Foreuse, portail, arbres-cubes, kit Prairie | Le Jour du Colosse et l'ambiance |
| P3 | 3 | Capsule, Quai, Alcôve, Arbre des Recherches, 2 machines, Doc Boulon, socle | Le Laboratoire |
| P4 | 5 | 16 accessoires de variantes | Donner envie de revenir |
| P5 | 6 | Audit des deux places, profilage sur l'Android 3 Go | `GraphicsMeshParts` ≤ 40 Mo dans la Developer Console avec 60 Zbires |
