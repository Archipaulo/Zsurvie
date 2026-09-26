## 1. Principe : zéro voxel, relief en blocs

Le Terrain Roblox est lisse par nature, et le canon l'interdit. Il n'y a donc **aucune cellule de Terrain** dans les deux places. Sol et relief sont des `Part` Block en `SmoothPlastic`, rangées dans `Workspace.Arene.Sol` et colorées avec `ReplicatedStorage.Charte`.

| Outil du Terrain Editor | Sur Zsurvie |
|---|---|
| Create > Clear | Seul outil utilisé : vider le Terrain des 2 places |
| Generate, Import | `SculpteurBloc` (§5), cellules de 8 studs |
| Draw, Sculpt, Add, Subtract | Parts posées à la main, Move snap 4, Rotate 90° |
| Flatten, Smooth, Sea Level | Inutiles ou interdits : sol à Y = 0, gradins nets, aucune eau |
| Paint | `Charte.Couleurs`, `Charte.Ombre` et `Charte.Lumiere` |

Terrain > `Decoration` = false. Contrôle QA : `print(workspace.Terrain:CountCells())` doit afficher `0`.

## 2. Plan de la Prairie

Repère a11 : origine au centre de la Maison, Nord = −Z. Les dalles de 8 × 8 sont centrées sur l'axe des chemins (bords à ±4, ±12…) : chaque chemin couvre une colonne de dalles.

| Élément | Emprise (studs) | Dessus Y | Teinte |
|---|---|---|---|
| Sol de base (`CanQuery` : cible du raycast de pose) | 220 × 2 × 220 | 0 | Prairie #6CC24A |
| Cœur en damier (spec a04) | r < 30 | 0,05 | Prairie base / lumière #88C962 |
| Champ en damier | r < 70 | 0,05 | Prairie base / ombre #569B3B |
| Lisière, puis trouées (axes) et alcôves (diagonales, r < 116) de 24 studs | 70 ≤ r < 100 | 0,05 | Prairie ombre |
| Couloir de réparation (a14) et Parvis (a11) | 24 × 24 ; 32 × 12, Z 8 → 20 | 0,2 | Terre battue lumière #D19C66 |
| 4 chemins | 8 de large, R 8 → 80 | 0,15 | Terre battue #C8894F |
| 8 pads de portail (Nord en 24 × 12 pour le cadre du Colosse) | 12 × 12 à R 80 | 0,1 | Violet horde ombre #7C4AB7 |
| Mine (a11) sur déblais 20 × 20 à 0,1 | 12 × 12 × 3 + 8 × 8 × 3, X 20 → 32, Z 20 → 32 | 6 | Ardoise ombre #3B374D et Ardoise ; déblais en Terre battue ombre #A06E3F |
| Berge nord | gradins de 4 (r < 116) et de 8 (r < 128), puis monts d'angle de 12 ou 18 | 4 → 18 | Dessus Prairie puis Prairie lumière ; flancs Terre battue ombre puis Ardoise |
| Berge sud (z > 20, plafond a11, hors champ) | r ≥ 100 | 4 ou 8 | Prairie |
| Canopée (4 Parts hors arène) | cadre ±108 → ±150 | 12, 8 au sud | Prairie ombre |

- **Lisibilité** : rien ne dépasse 6 studs sous r = 60, et le relief ne commence qu'à r = 100.
- **Occlusion** : la caméra regarde toujours vers −Z. Au sud, tout décor doit rester sous **1,6 × (r − 74)** studs, sinon il masque le Survivant arrêté à la barrière.

## 3. Transitions

- **Jamais deux teintes coplanaires** : chaque couche monte de 0,05 (Ronde à 0,15, chevrons a11 à 0,25). Deux Parts de même teinte peuvent se chevaucher.
- **Cœur → Champ → Lisière** : la dalle claire du damier devient sombre, puis tout le sol devient sombre. L'escalier de 8 studs dessine le cercle.
- **Prairie → chemin** : Terre battue franche, sans liseré. Le contraste tient sous `ClockTime` 17,5.
- **Lisière → berge** : on passe du vivant à la roche en montant (flancs Prairie, puis Terre battue ombre, puis Ardoise). Les dessus s'éclaircissent avec l'altitude.
- **Flancs au nord seulement** : la caméra ne voit que les faces tournées vers +Z. Au nord de z = 20 : corps (flanc) + chapeau de 1 stud. Au sud : une seule Part.

## 4. Performance

- **Terrain** : 0 cellule. **Eau** : aucune (reflets coûteux, bleu-cyan réservé aux gemmes).
- **Emprise** : 220 × 220 studs, de Y = −2 à Y = 18. Seule la Canopée dépasse (±150) : depuis la barrière, la caméra (0, 45, 28) en `FieldOfView` 50 voit environ 41 studs devant et 70 sur les côtés. Sans elle, on verrait le vide.
- **Budget : 400 Parts au plus** (environ 300 prévues), pris sur les 4 500 Parts décor de a11. Si on dépasse : un seul damier.
- **Physique** : tout est `Anchored`. Hors sol de base et Mine, `CanCollide`, `CanQuery` et `CanTouch` sont à false (ni physique ni raycast du Blaster).
- **Ombres** : `CastShadow` à false sous 2 studs d'épaisseur.
- **Batching** : 9 teintes, uniquement des Blocks, ni `UnionOperation` ni `MeshPart`.
- **Serveur** : tout sol foulé est à Y = 0, donc aucun raycast de sol pour les 60 Zbires à 10 Hz.

## 5. `SculpteurBloc`

ModuleScript `ServerStorage.OutilsMap.SculpteurBloc`, outil d'édition jamais requis en jeu : il génère dalles et berge. Les couches fixes du tableau se posent à la main.

```lua
-- Barre de commande : print(require(game.ServerStorage.OutilsMap.SculpteurBloc).construire())
local Charte = require(game:GetService("ReplicatedStorage").Charte)
local C, O, L = Charte.Couleurs, Charte.Ombre, Charte.Lumiere

local CELLULE, N = 8, 13 -- cellules -13..13, bords à ±108
local Z_SUD = 20 -- au sud, la caméra ne voit aucun flanc

type Rect = { i0: number, i1: number, j0: number, j1: number, genre: string }

local GENRES = {
	clair = { dessus = 0.05, couleur = L(C.Prairie) },
	sombre = { dessus = 0.05, couleur = O(C.Prairie) },
	gradin1 = { h = 4, couleur = C.Prairie },
	gradin2 = { h = 8, couleur = C.Prairie, flanc = O(C.TerreBattue) },
	gradin3 = { h = 12, couleur = L(C.Prairie), flanc = C.Ardoise },
	sommet = { h = 18, couleur = L(C.Prairie), flanc = C.Ardoise },
}

local function genreDe(i: number, j: number): string?
	local x, z = i * CELLULE, j * CELLULE
	local ax, az, r = math.abs(x), math.abs(z), math.sqrt(x * x + z * z)
	if (ax < 4 or az < 4) and r < 84 then
		return nil -- sous les chemins
	elseif r < 70 then
		if (i + j) % 2 == 0 then
			return nil -- dalle base : le sol de base reste visible
		end
		return if r < 30 then "clair" else "sombre"
	elseif r < 100 or ax < 12 or az < 12 or (r < 116 and math.abs(ax - az) < 12) then
		return "sombre" -- Lisière, trouées, alcôves
	elseif z > Z_SUD then
		return if r < 116 then "gradin1" else "gradin2"
	elseif r < 116 then
		return "gradin1"
	elseif r < 128 then
		return "gradin2"
	end
	return if math.noise(x / 40, z / 40, 7.3) > 0.1 then "sommet" else "gradin3"
end

local function poser(parent: Instance, taille: Vector3, centre: Vector3, couleur: Color3)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.CanCollide, p.CanQuery, p.CanTouch = false, false, false
	p.CastShadow = taille.Y >= 2
	p.Color = couleur
	p.Size = taille
	p.Position = centre
	p.Parent = parent
end

local function fermer(dossier: Folder, rect: Rect): number
	local g = GENRES[rect.genre]
	local sx, sz = (rect.i1 - rect.i0 + 1) * CELLULE, (rect.j1 - rect.j0 + 1) * CELLULE
	local cx, cz = (rect.i0 + rect.i1) / 2 * CELLULE, (rect.j0 + rect.j1) / 2 * CELLULE
	if g.dessus then
		poser(dossier, Vector3.new(sx, 0.2, sz), Vector3.new(cx, g.dessus - 0.1, cz), g.couleur)
		return 1
	elseif g.flanc and rect.j0 * CELLULE < Z_SUD then
		poser(dossier, Vector3.new(sx, g.h - 1, sz), Vector3.new(cx, (g.h - 1) / 2, cz), g.flanc)
		poser(dossier, Vector3.new(sx, 1, sz), Vector3.new(cx, g.h - 0.5, cz), g.couleur)
		return 2
	end
	poser(dossier, Vector3.new(sx, g.h, sz), Vector3.new(cx, g.h / 2, cz), g.couleur)
	return 1
end

local SculpteurBloc = {}

function SculpteurBloc.construire(): number
	local arene = workspace:FindFirstChild("Arene") or Instance.new("Folder")
	arene.Name, arene.Parent = "Arene", workspace
	local ancien = arene:FindFirstChild("Sol")
	if ancien then
		ancien:Destroy()
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "Sol"

	-- Fusion gloutonne : bandes par rangée, prolongées vers le sud si identiques
	local total = 0
	local ouverts: { [string]: Rect } = {}
	for j = -N, N do
		local courants: { [string]: Rect } = {}
		local i = -N
		while i <= N do
			local g, i0 = genreDe(i, j), i
			while i < N and genreDe(i + 1, j) == g do
				i += 1
			end
			if g then
				local cle = `{i0}:{i}:{g}`
				local rect = ouverts[cle] or { i0 = i0, i1 = i, j0 = j, j1 = j, genre = g }
				rect.j1 = j
				courants[cle] = rect
			end
			i += 1
		end
		for cle, rect in ouverts do
			if courants[cle] ~= rect then
				total += fermer(dossier, rect)
			end
		end
		ouverts = courants
	end
	for _, rect in ouverts do
		total += fermer(dossier, rect)
	end
	dossier.Parent = arene
	return total
end

return SculpteurBloc
```

## 6. Socle du Laboratoire (proposition)

La caméra Custom de a11 montre l'extérieur du lobby, absent du canon. À valider :

- Plateau en dalles de 8, qui déborde de 16 studs l'emprise a11 (hall R 52, Galerie, Quai, Spawn). Dessus à Y = 0, en Ardoise lumière #6C6573.
- 3 falaises de 8 studs, chacune en retrait de 8 : l'île flotte. Flancs en Ardoise, puis Ardoise ombre, puis Nuit labo.
- Quai des Capsules en surplomb de 16 studs, au-dessus d'une mer de nuages (8 dalles Crème de 64 × 4 × 64 vers Y = −44).
- 60 Parts au plus, aucun Terrain.
