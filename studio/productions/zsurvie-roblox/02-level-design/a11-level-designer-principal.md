## 1. Règles de la carte

- **Repère :** l'origine est le centre de la Maison, sol à Y 0. **Nord = −Z = haut de l'écran.** La caméra `Scriptable` du canon est fixe et plonge à 58° : on voit environ 41 studs au Nord et 22 au Sud.
- **Source unique :** `ReplicatedStorage.Plan` v1 (§8) donne toutes les coordonnées. Greybox, scripts, audit et fantôme de pose le lisent. Aucune valeur en dur.
- **Hiérarchie :** `Workspace.Arene.{Sol, Decor, Props, Maison, Mine, Etabli, Portails, Defenses}`. `Decor` contient `Vegetation`, `Tramages`, `Meteo` et `POI`.
- **Paliers :**
  - A : sol plat.
  - B : décor de 1,5 stud au plus, avec `CanCollide`, `CanQuery` et `CanTouch` à false.
  - C : tout le reste.
- **Règle des axes :** aucun palier C à moins de 6 studs des 8 axes portail → Maison, tant que les Zbires avancent en ligne droite. `Sol`, `Maison`, `Portails` et `Defenses` sont exemptés.
- **Hauteurs maximales :**
  - 6 studs sous R 60 ;
  - **1 stud de R 45 à R 66 (îlots)** ;
  - 8 studs en Lisière Sud.
  - Les Parts à `Transparency` 1 sont exemptées.

## 2. Plan de la Prairie

```
1 colonne = 5 studs (X −110 → 110), 1 ligne = 10 studs (Z). Nord en haut.
 -90 %%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%
 -80 %%%%%%%%%%^^^^^^^^^^^^G^^^^^^^^^^^^%%%%%%%%%%
 -70 %%%%%%%%^^^^^^^^^^^...#...^^^^^^^^^^^%%%%%%%%
 -60 %%%%%%^^^^^@^^^n...n..#..n...n^^^@^^^^^%%%%%%
 -50 %%%%%^^^^^^^:.........#.........:^^^^^^^%%%%%
 -40 %%%%^^^^^^^...:.......x.......:...^^^^^^^%%%%
 -30 %%%^^^^^^.......:.....#.....:...n...^^V^^^%%%
 -20 %%%^^^^^^...n.....:ooo#ooo:..2....n.^^^^^^%%%
 -10 %%%^^^^^.......1.oo...#...oo.........^^^^^%%%
   0 %%^^^^@#######x######MMM######x#######@^^^^%%
  10 %%%^^^^^........:ooEESS,,,oo.........^^^^^%%%
  20 %%%^^^^^^..:...3...ooo#ooommm4....n.^^^^^^%%%
  30 %%%^^^^@^.............#.:.mmm.......^^^^^^%%%
  40 %%%%^^^^^^^...n.......x..:....n...^^^^^^^%%%%
  50 %%%%%^^^^^^^..........#...:......^^^^^^^%%%%%
  60 %%%%%%^^^^^^^^^..n....#.n.:...^^^^^^^^^%%%%%%
  70 %%%%%%%%^^^^^^^^C^^...#...^^^^^^^^^^^%%%%%%%%
  80 %%%%%%%%%%^^^^^^^^^^^^@^^^^@^^^^^^^%%%%%%%%%%
  90 %%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%
```

Légende :

- **Terrain :** `%` Bord · `^` Lisière (Douve non dessinée) · `.` Prairie · `#` chemin · `:` axe diagonal · `o` Ronde · `,` Parvis.
- **Bâtiments :** `M` Maison · `E` Établi · `S` atterrissage · `m` Mine.
- **Portails :** `G` Grand Portail · `@` portail · `x` Ressort.
- **POI :** `n` Nid du Panier · `C` Colosse endormi · `V` Nid du Volant · `1` à `4` repères de quartier.

## 3. Zones et circulation

| Zone | Emprise et position | Règle |
|---|---|---|
| **La Maison** | 16 × 16 × 14, centre (0, 7, 0) | Porte au Sud, en (0, 0, 8) |
| Parvis | X −16 → 16, Z 8 → 20 | Pose interdite |
| Établi | 6 × 3 × 5, centre (−12, 14) | Achat à 10 studs, vérifié par le serveur |
| Atterrissage | `SpawnLocation` 8 × 1 × 8 en (−3 ; 0,5 ; 16) | À 9,2 studs de l'Établi, soit 0,6 s de course |
| **La Mine** | 12 × 12 × 6, X 20 → 32, Z 20 → 32 | Coiffe invisible (voir sous le tableau) |
| Barrière | 48 Parts de 10 × 24 × 1, à R 72 | Invisible, franchissable seulement par les Zbires (voir sous le tableau) |
| Douve (a18) | R 73 → 77 | 4 ponts de 8 studs sur les chemins, 4 gués en sol plein sur les diagonales |
| **La Lisière** | R 70 → 100 | Couloirs de 12 studs, clairière de Ø 16 à chaque portail |

- **Coiffe de la Mine :** 4 `WedgePart` de 12 × 8 × 6 en pyramide (pente 53°). Elles ont `Transparency` 1, `CanCollide` true et `CanQuery` false. Avec `Humanoid.MaxSlopeAngle` à 45, le Survivant glisse et ne peut pas s'y percher.
- **Barrière :** les Parts ont `CanQuery` false et sont dans le groupe `LimiteSurvivants`, qui ne bloque que `Survivants`. Un voile `ForceField` violet de 12 × 6 marque chacun des 8 couloirs.
- **Chemins :** 4 chemins N, E, S et O de 8 studs de large (R 8 → 80), en Terre battue #C8894F. Des chevrons Crème, tous les 16 studs, pointent vers la Maison.
- **Ronde :** cercle de R 24, 4 studs de large, en #A06E3F. Elle relie le Parvis, l'Établi et la Mine.
- **Sol :** socle Ardoise de 220 × 220, puis 3 disques : Ø 200 en #569B3B, Ø 140 en #6CC24A, Ø 60 en #88C962.
- **Répit :** l'aller-retour entre l'Établi et le point de pose le plus lointain (84 studs) prend 10,6 s, dans les 15 s de Répit.

## 4. Portails et axes

- **Portails :** 8 Models, `Portail_N` à `Portail_NO`, dans `Arene.Portails`. Ils sont tagués `PortailZbire`, portent les attributs `Index` et `Angle`, et sont placés par `Plan.positionPortail(i)`.
- **Grand Portail Nord :** c'est l'index 1, en (0, 0, −80). Le Colosse en sort toujours.
- **Écart SE : 160° au lieu de 155°.** À 155°, l'axe passe à 4,6 studs du coin (20, 32) de la Mine, sous la marge de 6. À 160°, il passe à 7,9 studs.
- **Écart SO : 250° au lieu de 225°.** L'axe à 225° traverse l'Établi imposé (à 2,8 studs). À 250°, avec un Établi de 6 × 3, il passe à 6,6 studs.
- **Marges vérifiées :**

| Élément | Distance à l'axe le plus proche |
|---|---|
| Mine | 7,9 studs |
| Établi | 6,6 studs |
| Gâteau du Pique-nique | 6,4 studs |
| Trois Rochers de a14, déplacés de (−34, −34) à (−33, −14) | 10 studs |
| Autres POI | plus de 13 studs |

## 5. Repères et POI (`Plan.POI`)

| Élément | Position | Rôle |
|---|---|---|
| Toit de la Maison | (0, 0) | Le seul aplat Toit orange. Porte le panneau du Record (voir sous le tableau) |
| Mine | (26, 26) | Le seul cyan : 12 cristaux `Neon` et 1 `PointLight` de `Range` 16 |
| Établi | (−12, 14) | Enseigne en forme de pièce Or de 3 × 3. Un anneau au sol clignote pendant le Répit |
| Grand Portail | (0, −80) | Arche violette de 16 × 18. Passe en Alerte #FF2E63 10 s avant le Colosse (`PointLight` de `Range` 24) |
| 7 autres portails | R 80 | Arches violettes de 10 × 12, `ParticleEmitter.Rate` 8 |
| Repères de quartier | 1 Trois Rochers (−33, −14) · 2 Potager (37, −15) · 3 Pique-nique (−36, 22) · 4 Wagonnet (36, 22) | 6 studs de haut au plus, à R < 45. Ils situent le ping « Ici ! ». Le Verger est supprimé |
| Colosse endormi | Nez en (−29, 0, 72), `CFrame.lookAt(nez, Vector3.zero)` | 8 studs de haut, à 30 studs du portail S. `ProximityPrompt` de `MaxActivationDistance` 8 et `RequiresLineOfSight` false |
| Nid du Volant | (78, 0, −32) | À 32 studs des portails NE et E |
| 12 Nids du Panier (a15) | R 58 → 66, hors chemins | 1 stud de haut |
| Zones d'atterrissage des Ressorts (a12) | 4 zones de 6 × 6 en (0, ±40) et (±40, 0) | Pose interdite |

- **Panneau du Record :** `PanneauRecord` de 12 × 0,2 × 3, sur le pan Sud du toit incliné à 32°. Il porte un `SurfaceGui` (`Face` Top, `PixelsPerStud` 50, `LightInfluence` 0). Le serveur y écrit « Record : Jour X ».
- **Ombre de la Maison :** quand `Plan.estDansOmbreMaison` est vrai, `OmbreMaison` règle `LocalTransparencyModifier` à 0,7 sur les Parts taguées `Occultable`.

## 6. Budget : `ServerStorage.Outillage.Gabarit`

Le Gabarit est un jeu de dossiers vides qui reproduit `Arene`. Chaque dossier porte les attributs `Budget` et `BudgetNeon`. Toute greybox part d'un clone du Gabarit. La racine est plafonnée à 6 500 Parts et 128 Neon statiques.

| Dossier | Parts | Neon | Seul constructeur |
|---|---|---|---|
| Sol (chemins, Douve, barrière) | 300 | 0 | a16 (Douve : a18) |
| Maison · Mine · Etabli · Portails | 360 · 80 · 50 · 160 | 16 · 12 · 6 · 32 | a21/a22 |
| Decor.Vegetation | 2 200 | 16 (Champignons) | a17. a20 fixe les hauteurs et les teintes |
| Decor.Tramages · Meteo · POI | 350 · 150 · 200 | 0 · 0 · 11 (secrets) | a20 · a18 · a11 |
| Props | 1 200 | 0 | a23 |
| Marge | 1 450 | 35 | a11 |
| Dynamique : Defenses · Colosse | 450 · 30 | 18 · 4 | serveur |

- **Pic attendu :** environ 7 900 Parts, soit 6 500 statiques + 360 Zbires + 30 Colosse + 450 défenses + 240 avatars + 300 pools.
- **`PointLight` :** 2 pour la map.
- **Arbres :** a21 et a24 n'en posent plus.

## 7. Laboratoire (`MaxPlayers` 12)

| Élément | Position | Règle |
|---|---|---|
| Hall | Disque de R 52. Plafond : cylindre de 1 × 104 × 104 à Y 40 | Au moins 36 studs libres au-dessus de l'anneau |
| Arbre des Recherches | (0, 0), hologramme de 32 studs | 4 pupitres à R 10 |
| **Doc Boulon** | (0, 16) | — |
| Alcôves | `Alcove_01` à `Alcove_12`, 12 × 10 × 12, pivot au centre, R 43 | Caméra pour a33 : `Plan.LABO.cameraAlcove(k)` |
| **Quai des Capsules** | Z −88 → −58. Capsules en X −24, 0 et 24, à Z −76 | 7 Dalles chantantes de 4 × 4 derrière, à Z −84 |
| `SpawnNovice` | (0 ; 0,5 ; −64) | À 12 studs de la Capsule Normale. Assigné par `Player.RespawnLocation` tant que le joueur n'a fait aucune run |
| Voie d'arrivée · Entrée | (0, −55) · (0 ; 0,5 ; 64) | Retour de run via `TeleportData` (position uniquement) |
| **Galerie des Zbires** | X −100 → −60 | Le Colosse est dans l'axe du passage O |
| Cabine d'Essayage | 12 × 12 réservés, X 12 → 24, Z 58 → 70 | Construite seulement si Victor Lanoue la valide |

- **Sols :** tous tagués `ZoneJouable`.
- **Écart soumis à Victor Lanoue :** caméra `Custom` (`CameraMaxZoomDistance` 30) au Laboratoire. Elle reste sous le plafond.

## 8. Code Luau

```lua
-- ReplicatedStorage.Plan (ModuleScript) v1. Origine = centre de la Maison, Nord = -Z.
local Plan = { VERSION = 1, RACINE = "Arene" }
Plan.HIERARCHIE = { "Sol", "Decor", "Props", "Maison", "Mine", "Etabli", "Portails", "Defenses" }
Plan.MAISON = { centre = Vector3.new(0, 7, 0), taille = Vector3.new(16, 14, 16), porte = Vector3.new(0, 0, 8) }
Plan.MINE = { centre = Vector3.new(26, 3, 26), taille = Vector3.new(12, 6, 12) }
Plan.ETABLI = { centre = Vector3.new(-12, 2.5, 14), taille = Vector3.new(6, 5, 3), rayonAchat = 10 }
Plan.ATTERRISSAGE = CFrame.new(-3, 0.5, 16)
Plan.RAYON_BARRIERE, Plan.RAYON_PORTAIL, Plan.RAYON_POSE, Plan.MARGE_AXE = 72, 80, 66, 6
Plan.RAYON_BAS, Plan.HAUTEUR_MAX, Plan.ILOTS = 60, 6, { rMin = 45, rMax = 66, hauteur = 1 }
Plan.ANGLES_PORTAILS = { 0, 90, 180, 270, 45, 160, 250, 315 } -- sens horaire depuis le Nord
Plan.NOMS_PORTAILS = { "N", "E", "S", "O", "NE", "SE", "SO", "NO" }

function Plan.dossier(nom: string): Instance?
	local racine = workspace:FindFirstChild(Plan.RACINE)
	return racine and racine:FindFirstChild(nom)
end

function Plan.polaire(angle: number, rayon: number): Vector3
	local a = math.rad(angle)
	return Vector3.new(math.sin(a) * rayon, 0, -math.cos(a) * rayon)
end

function Plan.positionPortail(i: number): Vector3
	return Plan.polaire(Plan.ANGLES_PORTAILS[i], Plan.RAYON_PORTAIL)
end

-- Distance d'une emprise (centre, demi-largeurs X et Z) à l'axe portail -> Maison le plus proche
function Plan.distanceAxe(c: Vector3, dx: number, dz: number): number
	local mini = math.huge
	for _, angle in Plan.ANGLES_PORTAILS do
		for r = 8, Plan.RAYON_PORTAIL do
			local p = Plan.polaire(angle, r)
			local ex, ez = math.max(math.abs(p.X - c.X) - dx, 0), math.max(math.abs(p.Z - c.Z) - dz, 0)
			mini = math.min(mini, math.sqrt(ex * ex + ez * ez))
		end
	end
	return mini
end

-- { nom, centre X, centre Z, demi X, demi Z }
Plan.ZONES_SANS_POSE = {
	{ "Maison", 0, 0, 12, 12 }, -- bande de réparation
	{ "Porte", 0, 11, 4, 3 }, -- 6 studs devant la porte
	{ "Parvis", 0, 14, 16, 6 },
	{ "Mine", 26, 26, 10, 10 }, -- Mine + 4 studs
	{ "Ressort", 0, -40, 3, 3 }, { "Ressort", 40, 0, 3, 3 }, { "Ressort", 0, 40, 3, 3 }, { "Ressort", -40, 0, 3, 3 },
}
local EMPRISE = { Muret = 4, MiniTourelle = 1.5, TapisCollant = 3 }

-- Même fonction pour le fantôme client et la validation serveur
function Plan.posePermise(typeDefense: string, cf: CFrame): (boolean, string?)
	local m, p = EMPRISE[typeDefense], cf.Position
	if not m or p.X ~= p.X or p.Z ~= p.Z then return false, "invalide" end
	if Vector2.new(p.X, p.Z).Magnitude + m > Plan.RAYON_POSE then return false, "trop loin" end
	for _, z in Plan.ZONES_SANS_POSE do
		if math.abs(p.X - z[2]) <= z[4] + m and math.abs(p.Z - z[3]) <= z[5] + m then return false, z[1] end
	end
	local defenses = Plan.dossier("Defenses")
	if typeDefense == "MiniTourelle" and defenses then
		for _, d in defenses:GetChildren() do
			if d:IsA("PVInstance") and d:GetAttribute("Type") == "MiniTourelle" then
				local q = d:GetPivot().Position
				if Vector2.new(q.X - p.X, q.Z - p.Z).Magnitude < 8 then return false, "tourelle proche" end
			end
		end
	end
	return true
end

Plan.POI = {
	PiqueNique = Vector3.new(-36, 0, 22),
	TroisRochers = Vector3.new(-33, 0, -14),
	Potager = Vector3.new(37, 0, -15),
	Wagonnet = Vector3.new(36, 0, 22),
	ColosseEndormi = { nez = Vector3.new(-29, 0, 72), prompt = 8 },
	NidVolant = Vector3.new(78, 0, -32),
	Douve = { rMin = 73, rMax = 77, largeurPont = 8 },
	NidsPanier = {},
}
for i, angle in { 15, 30, 60, 75, 110, 135, 170, 202.5, 225, 292.5, 330, 345 } do
	Plan.POI.NidsPanier[i] = Plan.polaire(angle, 58 + (i % 3) * 4) -- R 58 à 66
end

function Plan.estDansOmbreMaison(p: Vector3): boolean
	return math.abs(p.X) <= 11 and p.Z >= -20 and p.Z <= -8
end

Plan.LABO = {
	PLAFOND_Y = 40,
	SPAWN_NOVICE = Vector3.new(0, 0.5, -64),
	VOIE_ARRIVEE = Vector3.new(0, 0.5, -55),
	CAPSULES = { Jour = Vector3.new(-24, 7, -76), Normale = Vector3.new(0, 7, -76), Difficile = Vector3.new(24, 7, -76) },
	CABINE = { centre = Vector3.new(18, 0, 64), taille = Vector3.new(12, 0, 12) },
}

function Plan.LABO.pivotAlcove(k: number): CFrame -- Alcove_01 à Alcove_12
	local pos = Plan.polaire(15 + 30 * (k - 1), 43) + Vector3.new(0, 5, 0)
	return CFrame.lookAt(pos, Vector3.new(0, 5, 0))
end

function Plan.LABO.cameraAlcove(k: number): CFrame -- pour a33
	local pivot = Plan.LABO.pivotAlcove(k)
	return CFrame.lookAt(pivot.Position + pivot.LookVector * 20 + Vector3.new(0, 9, 0), pivot.Position)
end

return Plan
```

```lua
-- Barre de commande de Studio, avant chaque publication
local Plan = require(game.ReplicatedStorage.Plan)
local arene = assert(workspace:FindFirstChild(Plan.RACINE), "Arene manquante : cloner ServerStorage.Outillage.Gabarit")
local EXEMPTS = { Sol = true, Maison = true, Portails = true, Defenses = true }
local fautes = 0
local function faute(modele: string, ...: any)
	fautes += 1
	warn(modele:format(...))
end

local function budget(dossier: Instance)
	local max, maxNeon = dossier:GetAttribute("Budget"), dossier:GetAttribute("BudgetNeon") or 0
	if not max then return faute("%s : attribut Budget manquant", dossier:GetFullName()) end
	local n, neon = 0, 0
	for _, d in dossier:GetDescendants() do
		if d:IsA("BasePart") then
			n += 1
			neon += if d.Material == Enum.Material.Neon then 1 else 0
		end
	end
	if n > max or neon > maxNeon then faute("%s : %d/%d Parts, %d/%d Neon", dossier:GetFullName(), n, max, neon, maxNeon) end
end

budget(arene)
for _, nom in Plan.HIERARCHIE do
	local dossier = arene:FindFirstChild(nom)
	if not dossier then faute("Arene.%s manquant", nom) continue end
	budget(dossier)
	for _, d in dossier:GetDescendants() do
		if d:IsA("Folder") and d:GetAttribute("Budget") then budget(d) end
		if not d:IsA("BasePart") or d.Transparency >= 1 or nom == "Maison" then continue end
		local cf, s = d.CFrame, d.Size / 2
		local function ext(a: Vector3): number
			return math.abs(cf.RightVector:Dot(a)) * s.X + math.abs(cf.UpVector:Dot(a)) * s.Y + math.abs(cf.LookVector:Dot(a)) * s.Z
		end
		local sommet, r = cf.Y + ext(Vector3.yAxis), Vector2.new(cf.X, cf.Z).Magnitude
		local plafond = if r >= Plan.ILOTS.rMin and r <= Plan.ILOTS.rMax then Plan.ILOTS.hauteur
			elseif r < Plan.RAYON_BAS then Plan.HAUTEUR_MAX else math.huge
		if nom ~= "Defenses" and sommet > plafond then faute("%s : %.1f studs à R %.0f", d:GetFullName(), sommet, r) end
		if not EXEMPTS[nom] and (d.CanCollide or sommet > 1.5)
			and Plan.distanceAxe(cf.Position, ext(Vector3.xAxis), ext(Vector3.zAxis)) < Plan.MARGE_AXE then
			faute("%s : palier C à moins de 6 studs d'un axe", d:GetFullName())
		end
	end
end
print(("Audit Plan v%d : %d faute(s)"):format(Plan.VERSION, fautes))
```
