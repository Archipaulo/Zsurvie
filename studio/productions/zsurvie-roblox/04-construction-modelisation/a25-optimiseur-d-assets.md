# Zsurvie : budget performance et optimisation des assets

*Ilan Berthet, Optimiseur d'assets, Construction & Modélisation*

L'appareil de référence est un Android à 3 Go de RAM. Il doit tenir 30 FPS avec 6 Survivants, 60 Zbires et le Colosse, sous 800 Mo. Un asset qui dépasse son budget n'entre pas dans la place. Le script d'audit (§ 8) tranche avant chaque publication.

## 1. Budgets de la Prairie (place de run)

`StreamingEnabled` est désactivé (canon), donc toute la place reste en mémoire. Le plafond canon de 10 000 Parts s'applique au pic : Jour du Colosse et 60 Zbires.

| Poste | Parts | Triangles | Notes |
|---|---|---|---|
| Décor statique (Maison, Mine, Prairie, Lisière, Établi, portails) | ≤ 6 800 | ≤ 220 000 | tout en `Anchored` |
| Zbires (60 × 30 au maximum, cible 12) | ≤ 1 800 | ≤ 60 000 (1 000 chacun) | Mini-Gluants compris |
| Colosse | ≤ 30 | ≤ 5 000 | en MeshParts, règle des 30 Parts respectée |
| Défenses (6 × 3 × 25) | ≤ 450 | ≤ 14 400 | 800 triangles chacune |
| Survivants (avatars) | ≈ 240 | hors contrôle | comptés, jamais optimisés |
| Pools d'éclats et de pièces (client) | ≤ 300 | ≤ 15 000 | recyclés, jamais détruits |
| Marge | 380 | — | réservée aux correctifs, pas au décor |

| Autre budget | Plafond |
|---|---|
| Triangles à l'écran (mobile) | ≤ 120 000 |
| Draw calls à l'écran | ≤ 500 |
| Instances totales | ≤ 30 000 |
| Textures uniques | ≤ 20, `GraphicsTexture` ≤ 60 Mo |
| Sons | ≤ 40 assets, 16 simultanés |
| Parts `Neon` | ≤ 150 |
| Lumières (`PointLight`, `SpotLight`, `SurfaceLight`) | ≤ 12, toutes en `Shadows = false` |
| `ParticleEmitter` | `Rate` ≤ 20, ≤ 24 émetteurs actifs |
| `BillboardGui` actifs | ≤ 20, `MaxDistance` 60 |
| Mémoire | ≤ 800 Mo au total, dont `PlaceMemory` ≤ 350 Mo |
| Flux réseau des Zbires | ≈ 6 Ko/s par client |

Chaque zone reçoit une part fixe des Parts `Neon` et des lumières :

| Élément | Neon | Lumières |
|---|---|---|
| Maison (fenêtres) | 16 | 2 |
| Mine (cristaux) | 30 | 2 |
| Portails violets de la Lisière | 24 | 4 |
| Mini-Tourelles (1 voyant chacune) | 18 | 0 |
| Établi | 6 | 1 |
| Colosse (yeux) | 6 | 1 |
| Marge | 50 | 2 |

Les Zbires, les tirs et les pièces n'ont ni Neon ni lumière. Le flash du Blaster est un simple `ParticleEmitter:Emit(1)`.

## 2. Budgets du Laboratoire (lobby, 12 joueurs)

| Poste | Parts | Triangles |
|---|---|---|
| Hub, Arbre des Recherches et Doc Boulon | ≤ 4 000 | ≤ 90 000 |
| 12 Alcôves, machines comprises | 12 × ≤ 500 | 12 × ≤ 12 000 |
| Quai des Capsules | ≤ 1 500 | ≤ 40 000 |
| Galerie des Zbires | ≤ 1 500 | ≤ 40 000 |
| **Total** | **≤ 13 000** | **≤ 314 000** |

- Une machine de recherche compte 40 Parts et 1 000 triangles au maximum.
- Les plafonds de Neon (150) et de lumières (12) sont les mêmes qu'à la Prairie.
- Les figurines de la Galerie reprennent les `MeshId` des Zbires. On ne crée aucun nouvel asset, et les deux places partagent le cache de téléchargement.
- Doc Boulon est animée par un `AnimationController` et un `Animator`, sans `Humanoid`.
- Les machines portent le tag `MachineAnimee`. Un seul `LocalScript` les anime, et seulement à moins de 60 studs de la caméra.

## 3. StreamingEnabled

### Prairie : désactivé (canon)
L'arène mesure 220 × 220 studs. Sur un téléphone en paysage, la caméra (0, 45, 28) avec un `FieldOfView` de 50 voit environ 160 studs de large. Le streaming n'apporterait que des objets qui apparaissent en retard. En échange, le budget du § 1 est un plafond dur.

### Laboratoire : activé
Le canon ne dit rien du lobby. Je l'active parce que les 12 Alcôves se remplissent de machines au fil de la progression des joueurs. **Victor Lanoue doit valider ce choix.** L'empreinte du lobby est limitée à 240 × 240 studs.

| Propriété de `Workspace` | Valeur |
|---|---|
| `StreamingEnabled` | `true` |
| `ModelStreamingBehavior` | `Improved` |
| `StreamingIntegrityMode` | `MinimumRadiusPause` |
| `StreamingMinRadius` | 96 |
| `StreamingTargetRadius` | 256 |
| `StreamOutBehavior` | `Opportunistic` |

Sur PC, tout le lobby finit chargé. Sur l'Android de 3 Go, seul le rayon de 96 studs est garanti.

| Modèle | `ModelStreamingMode` | `LevelOfDetail` |
|---|---|---|
| Doc Boulon, les 3 Capsules, hub d'apparition | `Persistent` | `Disabled` |
| `Alcove_01` à `Alcove_12` | `PersistentPerPlayer` (pour le propriétaire) | `StreamingMesh` |
| Arbre des Recherches, figurines de la Galerie | `Atomic` | `StreamingMesh` |
| Décor d'ambiance | `Default` | `Disabled` |

Au Laboratoire, aucun `LocalScript` ne suppose qu'une instance est déjà chargée. Il passe par `WaitForChild` avec un délai, ou par `CollectionService:GetInstanceAddedSignal`.

```lua
-- ServerScriptService.StreamingLabo (ModuleScript, place Laboratoire)
-- Appelé par le système d'attribution des Alcôves et par le tutoriel de Doc Boulon.
local StreamingLabo = {}

function StreamingLabo.lierAlcove(player: Player, alcove: Model)
	-- L'Alcôve doit être en ModelStreamingMode = PersistentPerPlayer
	alcove:AddPersistentPlayer(player)
end

function StreamingLabo.delierAlcove(player: Player, alcove: Model)
	alcove:RemovePersistentPlayer(player)
end

-- À appeler avant chaque plan caméra scripté (tutoriel, nouvelle machine)
function StreamingLabo.precharger(player: Player, position: Vector3): boolean
	local ok, err = pcall(player.RequestStreamAroundAsync, player, position, 3)
	if not ok then
		warn(("[StreamingLabo] %s : %s"):format(player.Name, tostring(err)))
	end
	return ok
end

return StreamingLabo
```

## 4. LOD des Zbires dans la Prairie

Sans streaming, le LOD est géré par script.

- **Côté serveur :** il ne crée aucune Part de Zbire. Il garde position, PV et cible dans une table, à 10 Hz. Il diffuse un `buffer` par `UnreliableRemoteEvent`, soit 10 octets par Zbire : emplacement en `uint8`, x, y et z en `int16` au dixième de stud, PV en `uint16`, état en `uint8`. Les tirs sont validés sur ces données, avec une sphère de collision par type de Zbire.
- **Côté client :** chaque client clone ses Zbires depuis un pool (`ReplicatedStorage.ZbiresModeles`). Chaque Zbire a une racine en `Anchored` et des membres reliés par `Motor6D`. Toutes les parts sont en `CanCollide`, `CanTouch` et `CanQuery = false`.
- **Déplacement :** toutes les racines bougent en un seul appel, `workspace:BulkMoveTo(racines, cframes, Enum.BulkMoveMode.FireCFrameChanged)`.

| Palier (distance au Survivant local) | Rafraîchissement | Animation |
|---|---|---|
| Proche, moins de 50 studs | à chaque image, avec interpolation | écrasement et étirement en 0,15 s, membres animés |
| Moyen, de 50 à 100 studs | 20 Hz | rebond seul |
| Loin, plus de 100 studs | 5 Hz | figée |

- **Éclatement :** 6 cubes tirés du pool (120 cubes en vol au maximum) et un `ParticleEmitter:Emit(8)` à texture carrée, pendant 0,6 s.
- **Pièces :** seul leur propriétaire les voit, elles sont donc 100 % côté client. Au-delà de 40 pièces au sol, une nouvelle pièce fusionne à l'écran avec la plus proche. Seul le serveur crédite les pièces, après avoir vérifié la distance.
- **Maison :** un seul état est présent dans `Workspace`. Les états 2 et 3 reprennent la base commune et n'ajoutent ou ne retirent que 120 Parts de dégâts au maximum.

## 5. Textures légères

- **Palette unique `Charte_Palette` :** 128 × 128 px, en grille de 8 × 8 cases de 16 px. Elle contient les 33 teintes de `ReplicatedStorage.Charte` (11 couleurs × 3 teintes). Tout MeshPart de décor place ses UV au centre des cases. On obtient un seul `TextureID`, une instanciation maximale et environ 64 Ko de mémoire.
- **Pixel art net :** Roblox lisse les textures 3D (filtrage bilinéaire). Chaque motif est donc agrandi 4 fois au plus proche voisin avant l'import : un visage de 32 px devient 128 px.
- **Atlas des Zbires :** les 8 Zbires, le Mini-Gluant et le Colosse partagent une seule texture de 512 × 512.
- **Interface :** les icônes sont regroupées sur des planches de 1024 × 1024, lues avec `ImageRectOffset` et `ImageRectSize`, en `ResampleMode = Enum.ResamplerMode.Pixelated`.
- **Interdits :** `SurfaceAppearance`, textures de plus de 1024 px, `Decal` sur un objet répété, canal alpha sans usage.

## 6. Sons

- Le client utilise un pool de 16 `Sound`. Quand il est plein, le son le moins prioritaire est coupé. Ordre de priorité : Colosse, alerte de la Maison, tirs du joueur, tirs des autres, éclats, pièces.
- Trois `SoundGroup` : Musique, Effets et Interface.
- Les effets sont en mono et durent 1,5 s au maximum. Les musiques sont des boucles de 60 s au maximum.
- Réglage des sons 3D : `RollOffMode = InverseTapered`, `RollOffMaxDistance = 80`.
- Un même son joue au maximum 4 fois par 0,1 s.

## 7. Règles pour toute l'équipe

1. Un objet répété plus de 10 fois devient un `MeshPart` qui partage le même `MeshId`. Un arbre de la Lisière est un seul MeshPart de 300 triangles au maximum, pas 40 Parts. On garde 4 variantes d'arbre au maximum.
2. Avant l'import d'un maillage voxel, on supprime les faces internes et on fusionne les faces coplanaires (greedy meshing).
3. Pas d'`UnionOperation` dans la Prairie. Chaque Union a une géométrie unique et ne peut pas être instanciée. On l'exporte en MeshPart.
4. Réglage du décor :
   - `Anchored = true` et `CanTouch = false` ;
   - `CanQuery = false`, sauf sur le sol et les murs ;
   - `CastShadow = false` pour les objets de moins de 2 studs.
5. Réglage des `MeshPart` :
   - `CollisionFidelity = Box`, ou `Hull` pour la Maison ;
   - jamais `PreciseConvexDecomposition` ;
   - `RenderFidelity = Automatic`, sauf si la silhouette casse en dézoomant.
6. Pas de `Script` par objet. Un seul système par famille d'objets, via `CollectionService`.
7. Post-effets : ni `DepthOfFieldEffect` ni `SunRaysEffect`. `BloomEffect.Size` reste à 24 au maximum.
8. Le Terrain reste vide et aucun `Humanoid` n'est placé dans une place.

## 8. Script d'audit (barre de commande de Studio)

```lua
-- Audit budget Zsurvie : à lancer en édition, dans chacune des deux places
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local estPrairie = not workspace.StreamingEnabled
local BUDGET = {
	Parts = if estPrairie then 6800 else 13000, -- décor statique seul
	Neon = 150, Lumieres = 12, Textures = 20, Sons = 40, Instances = 30000,
}
local compte = { Parts = 0, Neon = 0, Lumieres = 0, Instances = 0, CanTouch = 0, Ombres = 0 }
local textures, sons, alertes = {}, {}, {}

local function alerte(motif: string, inst: Instance)
	table.insert(alertes, motif .. " : " .. inst:GetFullName())
end

local function taille(t: { [any]: boolean }): number
	local n = 0
	for _ in t do n += 1 end
	return n
end

for _, inst in workspace:GetDescendants() do
	compte.Instances += 1
	if inst:IsA("BasePart") then
		compte.Parts += 1
		if inst.Material == Enum.Material.Neon then compte.Neon += 1 end
		if inst.Anchored and inst.CanTouch and not CollectionService:HasTag(inst, "Interactif") then
			compte.CanTouch += 1
		end
		if inst.CastShadow and math.max(inst.Size.X, inst.Size.Y, inst.Size.Z) < 2 then
			compte.Ombres += 1
		end
		if inst:IsA("MeshPart") then
			if inst.TextureID ~= "" then textures[inst.TextureID] = true end
			if inst.CollisionFidelity == Enum.CollisionFidelity.PreciseConvexDecomposition then
				alerte("Collision précise", inst)
			end
		elseif inst:IsA("UnionOperation") and estPrairie then
			alerte("Union dans la Prairie", inst)
		end
	elseif inst:IsA("Light") then
		compte.Lumieres += 1
		if inst.Shadows then alerte("Lumière avec ombres", inst) end
	elseif inst:IsA("ParticleEmitter") and inst.Rate > 20 then
		alerte("Rate supérieur à 20", inst)
	elseif inst:IsA("Decal") then -- couvre aussi Texture
		textures[inst.Texture] = true
	elseif inst:IsA("SurfaceAppearance") or inst:IsA("Humanoid") then
		alerte(inst.ClassName .. " interdit", inst)
	end
end

for _, racine in { SoundService, ReplicatedStorage, workspace } do
	for _, inst in racine:GetDescendants() do
		if inst:IsA("Sound") then sons[inst.SoundId] = true end
	end
end

local cellules = workspace.Terrain:CountCells()
if cellules > 0 then table.insert(alertes, ("Terrain non vide : %d cellules"):format(cellules)) end

for _, m in {
	{ "Parts", compte.Parts, BUDGET.Parts }, { "Neon", compte.Neon, BUDGET.Neon },
	{ "Lumieres", compte.Lumieres, BUDGET.Lumieres }, { "Textures", taille(textures), BUDGET.Textures },
	{ "Sons", taille(sons), BUDGET.Sons }, { "Instances", compte.Instances, BUDGET.Instances },
} do
	print(("%-10s %6d / %-6d %s"):format(m[1], m[2], m[3], if m[2] <= m[3] then "OK" else "DÉPASSE"))
end
print(("CanTouch à couper : %d | Ombres de petits objets : %d"):format(compte.CanTouch, compte.Ombres))
for _, texte in alertes do warn(texte) end
print(("Audit terminé : %d alerte(s)"):format(#alertes))
```

## 9. Checklist avant publication

- [ ] L'audit du § 8 ne montre aucun « DÉPASSE » ni aucune alerte, dans les deux places.
- [ ] `Workspace.StreamingEnabled` vaut `false` sur la Prairie et `true` au Laboratoire.
- [ ] Test sur Android 3 Go avec 6 comptes, un Jour du Colosse et 60 Zbires : 30 FPS ou plus pendant 5 min, et `Stats:GetTotalMemoryUsageMb()` sous 800.
- [ ] Mémoire stable à ± 5 % entre le jour 5 et le jour 15. Au-delà, pools ou connexions fuient.
- [ ] Statistiques de rendu (Ctrl+Maj+F2) : 500 draw calls et 120 000 triangles à l'écran au maximum.
- [ ] Réseau (Ctrl+Maj+F3) : 50 Ko/s reçus par client au maximum.
- [ ] MicroProfiler côté serveur : boucle des Zbires à 4 ms par tick au maximum.
- [ ] Le compteur du pool ne dépasse jamais 16 sons simultanés.
- [ ] Laboratoire : Quai, Alcôve et Galerie s'affichent sans trou, et aucun `Infinite yield` n'apparaît en sortie.
- [ ] Téléportation vers la Prairie en 10 s au maximum sur l'Android de référence.
- [ ] Aucune texture de plus de 1024 px, aucun `SurfaceAppearance`, Terrain vide.
