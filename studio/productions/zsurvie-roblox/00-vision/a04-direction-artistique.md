## Décisions

- **Canon** : aucun document du directeur créatif n'existait encore dans `00-vision/`. Je reprends donc à la lettre les noms du brief : **Zsurvie**, **la maison**, **la mine**, **le Laboratoire**, **pièces**, **gemmes**, **colosse** et les 8 monstres. **Écart signalé** : « la Prairie » (zone de combat) et « la Lisière » (anneau d'apparition des hordes) sont des noms de travail, à aligner sur le canon.
- **Style retenu : « Pixel-bloc »**, c'est-à-dire le pixel art de Zsurvie traduit en voxels 3D : blocs pleins, aplats, faces ombrées à la main, aucune texture réaliste.
  - *Fidélité* : 1 pixel du sprite d'origine = 1 cube de 0,5 stud sur les personnages. Le décor suit une grille de 1 stud et les bâtiments des modules de 4 studs.
  - *Lisibilité mobile* : avec des aplats et des silhouettes franches, on distingue 40 monstres sur un écran de 6 pouces.
  - *Performance* : `SmoothPlastic` et Parts simples. Cible : 30 FPS sur un téléphone d'entrée de gamme, avec 6 joueurs et 60 monstres.
  - *Écartés* : le réaliste (trop lourd et trop sombre), le low-poly lisse (perd l'ADN pixel), le 8-bit plat en 3D (réservé à l'UI).

## Palette

| # | Nom | Hex | `Color3.fromRGB` | Usage | Jamais sur |
|---|---|---|---|---|---|
| 1 | Encre | #1E1B2E | 30, 27, 46 | Pupilles, piquants, contours UI | Grandes surfaces |
| 2 | Prairie | #6CC24A | 108, 194, 74 | Sol de la Prairie, feuillages | Monstres |
| 3 | Terre battue | #C8894F | 200, 137, 79 | Chemins d'arrivée, sol de la mine | UI |
| 4 | Crème | #F6E7C1 | 246, 231, 193 | Murs de la maison, planches, yeux, texte UI | Corps des monstres |
| 5 | Toit orange | #EF7A2F | 239, 122, 47 | Toit de la maison, kit des survivants, défenses | Monstres |
| 6 | Or | #FFC933 | 255, 201, 51 | Pièces, monstre doré, boutons d'achat | Décor |
| 7 | Gemme cyan | #33D6F0 | 51, 214, 240 | Gemmes, cristaux de la mine, recherches | Décor de la Prairie |
| 8 | Violet horde | #9B5DE5 | 155, 93, 229 | Corps des monstres, portails de la Lisière | Joueurs, objets amis |
| 9 | Alerte | #FF2E63 | 255, 46, 99 | Dégâts, PV bas, télégraphes, yeux du colosse | Décor |
| 10 | Nuit labo | #2A3263 | 42, 50, 99 | Laboratoire, ciel du jour du colosse | Prairie en jeu normal |

**Nuances** : 3 valeurs par couleur, pas une de plus :
- la *base* sur les faces avant ;
- l'*ombre* (base × 0,8) sur les côtés et le dessous ;
- la *lumière* (base mêlée à 20 % de Crème) sur le dessus.

Seule exception : **Ardoise #4A4560** (Encre éclairci), pour le métal, la roche et les casques. Jamais de #000000 ni de #FFFFFF.

**Code couleur de jeu** : violet = ennemi, orange/crème = à nous, or = pièces, cyan = gemmes, rose-rouge = danger. On doit comprendre la scène en 1 seconde, sans lire de texte.

## Formes et silhouettes

- **Formes autorisées** : `Part` Block, `WedgePart` et `CornerWedgePart`, en rotations de 90° (45° pour les toits). Un rond se construit en escalier de cubes. Un `MeshPart` n'est accepté que s'il est voxelisé.
- **Détail minimum** : 0,5 stud sur au moins deux dimensions. En dessous, le détail disparaît sur téléphone.
- **Monstres** : la tête fait 50 % de la hauteur, avec des yeux en 2×2 cubes Crème et une pupille Encre.
  - Chaque monstre doit rester reconnaissable en ombre chinoise à 40 studs, avec la caméra de jeu.
  - Le volant et le sauteur projettent une ombre au sol en cubes Encre (`Transparency` 0,6).

| Monstre | Hauteur (studs) | Clé de silhouette |
|---|---|---|
| marcheur | 3 | Cube sur deux pattes : la référence |
| rapide | 2,5 | Allongé, penché de 30° en avant, oreilles rabattues |
| costaud à piquants | 5 (4 de large) | Carré massif, piquants `WedgePart` Encre sur le dos |
| doré | 3 | Marcheur entièrement Or, étincelles (`ParticleEmitter` avec `Rate` 4) |
| sauteur bondissant | 3,5 | Pattes-ressorts deux fois plus longues, s'écrase avant chaque bond |
| gluant | 2,5 (4 de large) | Dôme plat en escalier, `Transparency` 0,2. À sa mort, il se divise en deux gluants de 1,5 |
| volant | 2, à 8 du sol | Ailes de 3 studs qui battent |
| casqué blindé | 3,5 | Casque-seau Ardoise sur les yeux. Coup normal : étincelles Ardoise. Coup critique : flash Crème |
| colosse | 18 | Marcheur × 6 avec un dos de piquants, yeux Alerte `Neon`. Seul monstre avec un `Highlight` |

- **La maison** : 16 × 16 studs au sol, 14 de haut.
  - **Rien d'autre ne dépasse 6 studs dans un rayon de 60 studs**, pour qu'aucune horde ne soit masquée.
  - 3 états visuels : intacte ; fissurée sous 60 % de PV ; en ruine sous 25 % de PV (trous, `Smoke` Encre).
  - Les planches réparées restent visibles.
- **Les survivants** : chaque joueur garde son avatar et porte un kit commun (sac à dos et blaster blocky) en Toit orange et Crème.
  - Les alliés restent visibles à travers les murs grâce à un `Highlight` : `FillTransparency` 1, `OutlineColor` Crème, `DepthMode` AlwaysOnTop.

## Matériaux Roblox

- **`SmoothPlastic`** : 90 % des surfaces. C'est notre pixel.
- **`Neon`** : gemmes, cristaux, yeux du colosse, télégraphes et écrans du Laboratoire. Plafond : 150 Parts.
- **`Glass`** : uniquement pour les vitrines du Laboratoire.
- **`ForceField`** : uniquement pour les effets temporaires.
- **Textures pixel** : peintes en 16×16 puis exportées en 256×256 au plus proche voisin. Dans l'UI : `ImageLabel.ResampleMode = Enum.ResamplerMode.Pixelated`.
- **Sol de la Prairie** : pas de Terrain lisse. On pose des dalles de 8×8 studs qui alternent Prairie base et Prairie lumière, avec `CastShadow = false`.
- **Lighting** :
  - `Technology` ShadowMap ;
  - `EnvironmentalSpecularScale` 0 et `EnvironmentalDiffuseScale` 0,3 ;
  - `ColorCorrectionEffect` : Saturation 0,15, Contrast 0,1 ;
  - `BloomEffect` : Intensity 0,4, Size 18, Threshold 1,5.

## Ambiance des zones

| Zone | Ambiance | Lumière | Signature mémorable |
|---|---|---|---|
| **La maison** | Cocon chaleureux | `PointLight` Or, `Range` 16 | Cheminée qui fume, drapeau orange |
| **La Prairie** | Pique-nique joyeux qui tourne au chaos | `ClockTime` 14, `Ambient` (110,106,128) | 4 chemins de Terre battue en croix. Des fleurs-cubes s'écrasent sous les hordes puis repoussent |
| **La Lisière** | Forêt de cubes, mystérieuse sans faire peur | `Atmosphere` Density 0,35 | Des portails violets gonflent 2 s avant chaque vague |
| **La mine** | Trésor | `PointLight` cyan, `Range` 12 | Un wagonnet déverse des gemmes. La foreuse apparaît une fois débloquée |
| **Le Laboratoire** | Repaire de savant sympa | Nuit labo, néons cyan | Arbre de recherches en tubes qui s'allument, vitrines du bestiaire, portail de départ |
| **Jour du colosse** | Boss de fête foraine | `ClockTime` 17,5, `TintColor` (255,214,194) | Son ombre géante traverse la Prairie 5 s avant son arrivée |

Chaque recherche permanente ajoute un objet visible dans le Laboratoire (tourelle de toit sur la maquette de la maison, foreuse miniature…). Le joueur voit ce qu'il a construit, et c'est ce qui le fait revenir le lendemain.

## Références visuelles

1. **Crossy Road** : voxels en aplats, 3 valeurs par face, décor bas. *On prend* la règle des nuances.
2. **Minecraft Dungeons** : vue surélevée, hordes lisibles de loin, butin qui brille au sol. *On prend* la lecture des hordes. *On laisse* l'obscurité.
3. **Le Zsurvie d'origine** : animations élastiques. *On prend* le squash & stretch (× 0,8 / × 1,2, en 0,15 s) et le « pouf » de disparition. *On refuse* les sprites 2D sur `BillboardGui`.

## Charte vérifiable dans Studio

Placer ce ModuleScript dans `ReplicatedStorage.Charte`. C'est la source unique des couleurs, aussi pour l'UI et les VFX.

```lua
local Charte = {}

Charte.Couleurs = {
	Encre = Color3.fromRGB(30, 27, 46),
	Ardoise = Color3.fromRGB(74, 69, 96),
	Prairie = Color3.fromRGB(108, 194, 74),
	TerreBattue = Color3.fromRGB(200, 137, 79),
	Creme = Color3.fromRGB(246, 231, 193),
	ToitOrange = Color3.fromRGB(239, 122, 47),
	OrPieces = Color3.fromRGB(255, 201, 51),
	GemmeCyan = Color3.fromRGB(51, 214, 240),
	VioletHorde = Color3.fromRGB(155, 93, 229),
	Alerte = Color3.fromRGB(255, 46, 99),
	NuitLabo = Color3.fromRGB(42, 50, 99),
}

Charte.MateriauxAutorises = {
	[Enum.Material.SmoothPlastic] = true,
	[Enum.Material.Neon] = true,
	[Enum.Material.Glass] = true,
	[Enum.Material.ForceField] = true,
}

Charte.MAX_NEON = 150
Charte.DETAIL_MIN = 0.5

function Charte.Ombre(c: Color3): Color3
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end

function Charte.Lumiere(c: Color3): Color3
	return c:Lerp(Charte.Couleurs.Creme, 0.2)
end

local TOLERANCE = 3 / 255
local function proche(a: Color3, b: Color3): boolean
	return math.abs(a.R - b.R) <= TOLERANCE
		and math.abs(a.G - b.G) <= TOLERANCE
		and math.abs(a.B - b.B) <= TOLERANCE
end

function Charte.CouleurValide(c: Color3): boolean
	for _, base in Charte.Couleurs do
		if proche(c, base) or proche(c, Charte.Ombre(base)) or proche(c, Charte.Lumiere(base)) then
			return true
		end
	end
	return false
end

return Charte
```

Lancer cet audit dans la barre de commande avant chaque livraison d'asset. Il doit renvoyer 0 écart.

```lua
local Charte = require(game:GetService("ReplicatedStorage").Charte)
local racines = { workspace:FindFirstChild("Map"), game:GetService("ServerStorage"):FindFirstChild("Monstres") }
local ecarts, neon = 0, 0

for _, racine in racines do
	for _, inst in racine:GetDescendants() do
		if inst:IsA("SurfaceAppearance") then
			ecarts += 1
			warn("[Charte] SurfaceAppearance interdite : " .. inst:GetFullName())
		elseif inst:IsA("BasePart") and not inst:IsA("Terrain") then
			local nom = inst:GetFullName()
			if not Charte.CouleurValide(inst.Color) then
				ecarts += 1
				warn(("[Charte] Couleur #%s hors palette : %s"):format(inst.Color:ToHex(), nom))
			end
			if not Charte.MateriauxAutorises[inst.Material] then
				ecarts += 1
				warn(("[Charte] Matériau %s interdit : %s"):format(inst.Material.Name, nom))
			end
			local d = { inst.Size.X, inst.Size.Y, inst.Size.Z }
			table.sort(d)
			if d[2] < Charte.DETAIL_MIN then
				ecarts += 1
				warn("[Charte] Détail trop fin pour mobile : " .. nom)
			end
			if inst.Material == Enum.Material.Neon then
				neon += 1
			end
		end
	end
end

if neon > Charte.MAX_NEON then
	ecarts += 1
	warn(("[Charte] %d Parts Neon (max %d)"):format(neon, Charte.MAX_NEON))
end
print(("[Charte] Audit terminé : %d écart(s), %d Neon"):format(ecarts, neon))
```

## À ne jamais faire

- Du sang ou des cadavres. Un monstre vaincu éclate en cubes violets et en pièces.
- Un monstre effrayant : pas de dents réalistes, pas de jump scare.
- Une couleur hors palette, du violet sur un objet ami ou de l'orange sur un ennemi.
- Des matériaux réalistes (`Brick`, `Granite`, `WoodPlanks`…) ou une `SurfaceAppearance`.
- Du `Neon` dans le décor.
- Un objet de plus de 6 studs dans un rayon de 60 studs autour de la maison.
- Une sphère, un mesh lisse ou un détail de moins de 0,5 stud.
- Plus de 3 flashs par seconde, ou des particules plein écran (`ParticleEmitter.Rate` ≤ 20).
- Du texte peint dans le décor.
- Deux monstres avec la même silhouette.
