## 1. Règles communes

- **Écart assumé par rapport à la mission : pas de Terrain Decoration.** On règle `Workspace.Terrain.Decoration = false` et on ne pose aucun voxel. Trois raisons : le canon interdit le Terrain lisse, l'herbe animée ne s'affiche que près de la caméra (la nôtre est à 53 studs du Survivant) et elle disparaît aux niveaux graphiques bas des Android d'entrée de gamme. L'herbe devient des Touffes-cubes en MeshPart instanciées.
- **Toute pièce végétale** : `Anchored = true` ; `CanCollide`, `CanQuery` et `CanTouch` à `false` ; matériau `SmoothPlastic`. Elle n'arrête ni un tir, ni un Zbire, ni une pose de défense. La limite de l'arène est un mur invisible, pas une haie.
- **Ombres** : `CastShadow = false`, sauf sur les houppiers d'arbres de 4 studs de haut ou plus.
- **MeshParts** : `RenderFidelity = Performance`, `CollisionFidelity = Box`, pas de `TextureID`. On utilise un seul MeshId par objet pour que toutes ses copies partent dans un seul lot de rendu ; seule la `Color` change d'une copie à l'autre.
- **Grille** : positions arrondies au stud, rotations par quarts de tour uniquement.
- **Couleurs** : seulement Prairie, Terre battue, Crème et Ardoise. Jamais d'or (on le confondrait avec les pièces au sol), de cyan (gemmes), de violet (Zbires, portails) ni de rose-rouge (danger).

## 2. Palette et kit (`ServerStorage.KitVegetation`)

| Couleur | Base | Ombre (× 0,8) | Lumière (+20 % Crème) |
|---|---|---|---|
| Prairie | #6CC24A | #569B3B | #88C962 |
| Terre battue | #C8894F | #A06E3F | #D19C66 |
| Crème | #F6E7C1 | #C5B99A | #F6E7C1 |
| Ardoise | #4A4560 | #3B374D | #6C6573 |

Chaque gabarit est un `Model` dont le `PrimaryPart` touche le sol. Les parties de feuillage s'appellent `Houppier` et prennent Prairie ombre (70 % des objets) ou Prairie base (30 %), tiré objet par objet. Le sommet s'appelle `Cime` et prend Prairie lumière.

| Gabarit | Construction (studs) | Hauteur | Parts | Tronc ou corps |
|---|---|---|---|---|
| `Touffe` | MeshPart, 3 brins de 0,5 × 1 × 0,5 | 1 | 1 | Prairie lumière |
| `Fleur` | MeshPart, croix de 5 cubes de 0,5 sur une tige | 1 | 1 | Crème |
| `BuissonBas` | Houppier 4 × 1,5 × 4, Cime 2 × 0,5 × 2 | 2 | 2 | — |
| `Fougere` | MeshPart, 4 feuilles en escalier | 2 | 1 | Prairie base |
| `Souche` | Block 2 × 1,5 × 2 | 1,5 | 1 | Terre battue ombre |
| `Champignon` | pied 1 × 2 × 1, chapeau 3 × 1 × 3 | 3 | 2 | Crème, chapeau Terre battue |
| `BuissonHaut` | Houppier 6 × 3 × 6, Cime 3 × 1 × 3 | 4 | 2 | — |
| `CheneNain` | tronc 2 × 3 × 2, Houppier 7 × 5 × 7, Cime 4 × 1 × 4 | 9 | 3 | Terre battue ombre |
| `Chene` | tronc 2 × 5 × 2, Houppier 10 × 6 × 10, Cime 6 × 3 × 6 | 14 | 3 | Terre battue ombre |
| `Bouleau` | tronc 1,5 × 9 × 1,5, Houppier 6 × 5 × 6 | 14 | 2 | Crème |
| `Pin` | tronc 2 × 4 × 2, Houppiers 8 × 3 × 8, 6 × 3 × 6 et 4 × 3 × 4, Cime 2 × 2 × 2 | 15 | 5 | Ardoise |
| `MasseFeuillage` | Block `Masse` 14 × 10 × 14, sans ombre | 10 | 1 | Prairie ombre |

## 3. Composition par zone

### La Prairie (rayon de 0 à 70 studs) : le pique-nique

| Anneau | Végétation | Hauteur max |
|---|---|---|
| 0 à 20 | Aucune (Maison, Mine, zone de pose). Sur le sol nu, pièces et gemmes restent lisibles | 0 |
| 20 à 45 | Touffes clairsemées (pas de 10), Fleurs à partir de 30 | 1 |
| 45 à 70 | Touffes denses (pas de 5), Fleurs, BuissonBas en petits groupes | 2 |

- **Chemins** : 6 studs libres de chaque côté de l'axe. Une bordure de Fleurs est posée tous les 6 studs, à 7 studs de l'axe, de 24 à 66 studs du centre : on lit les 4 directions sans flèche.
- **Lisibilité** : la caméra (0, 45, 28) plonge à 58°. Vu de là, un buisson de 2 studs ne cache aucun Zbire.
- **Floraison** : au jour 1, les bordures et 40 % des autres Fleurs sont ouvertes. Les autres éclosent entre le jour 1 et le jour 10. En fleurissant, la Prairie montre l'avancée de la run.

### La Lisière (de 70 à 100 studs) : la forêt de cubes

- **Orée irrégulière** : les premiers troncs se placent entre 72 et 80 studs, selon un bruit calculé sur l'angle. Dès 70 studs, le sous-bois (Fougere, Souche, Champignon, BuissonHaut) assure la transition.
- **Bosquets** : un bruit de période 24 studs regroupe les arbres par 3 à 5 et laisse des trouées entre les groupes.
- **Amphithéâtre** : la caméra est toujours au sud (+Z) du Survivant, donc les arbres montent en hauteur vers le nord.
  - Côté caméra (± 60° autour du sud) : `CheneNain` seulement. Il reste sous la ligne de visée même quand le Survivant touche la limite de l'arène.
  - Flancs : `Chene` et `Bouleau`.
  - Nord : `Pin`, `Chene` et `Bouleau`. C'est la toile de fond de toute la run.
- **Clairières des portails** (hypothèse : 8 portails à 85 studs, un tous les 45°) :
  - aucun arbre à moins de 14 studs d'un portail, aucun sous-bois à moins de 8 ;
  - à poser à la main : un rond de 4 Champignons par clairière, dont 2 portent un cube `Neon` Crème de 0,5 stud, soit 16 Neon en tout. Mystérieux, jamais effrayant.
- **Couloirs** : les chemins traversent la Lisière jusqu'aux portails situés sur leur axe. Derrière ces portails, la forêt se referme.
- **Interdits** : branches crochues, troncs noirs, yeux dans les buissons.

### Le fond (de 100 studs jusqu'aux bords)

Des `MasseFeuillage` au pas de 14 bouchent les coins de l'arène carrée : la caméra ne voit jamais le vide.

### Laboratoire, Quai des Capsules, Galerie des Zbires (150 BaseParts au maximum)

- **Laboratoire** :
  - un bac Ardoise 2 × 2 × 2 avec une `Fougere`, à gauche de chaque Alcôve, jamais devant les machines ;
  - du lierre en cubes (1 × 1 × 0,5, Prairie ombre), en coulées de 6 cubes sur 8 piliers ;
  - 3 bocaux-serres près de Doc Boulon (matériau `Glass`, `Transparency` 0,6).
- **Quai des Capsules** : 6 jardinières Ardoise de 8 × 2 × 2, coiffées d'une haie-cube Prairie.
- **Galerie des Zbires** : chaque vitrine a pour fond une Lisière miniature (`CheneNain`, `Touffe`, `Souche`), avec les mêmes MeshId qu'en run.

## 4. Budget d'instances (Prairie)

| Couche, par ordre de priorité | Rayon (studs) | Pas | Objets (≈) | BaseParts (≈) |
|---|---|---|---|---|
| Bordures de Fleurs | le long des chemins | 6 | 64 | 64 |
| Arbres | 72 à 100 | 7 | 70 | 230 |
| MasseFeuillage | 100 aux bords | 14 | 75 | 75 |
| Sous-bois | 70 à 100 | 6 | 100 | 150 |
| BuissonBas | 50 à 70 | 9 | 40 | 80 |
| Fleurs | 30 à 70 | 8 | 60 | 60 |
| Touffes | 20 à 70 | 10, puis 5 | 340 | 340 |
| Ronds de Champignons (à la main) | clairières | — | 32 | 80 |
| **Total** | | | **≈ 780** | **≈ 1 080** |

- **Plafond : 1 200 BaseParts**, soit 12 % des 10 000 Parts autorisées dans l'arène. Le générateur s'arrête à 1 120 pour laisser 80 Parts à la pose manuelle. Les Touffes sont en fin de liste : si le plafond est atteint, ce sont elles qui sautent.
- **Rendu** : les quelque 500 Touffes, Fleurs et Fougeres ne demandent que 3 MeshId. Tout le reste est statique, sans physique et hors des requêtes spatiales.
- **Pas de LOD** : `StreamingEnabled` est désactivé, donc `LevelOfDetail` ne sert à rien. On économise sur le nombre d'instances.
- **Critère de validation** : sur un Android de 3 Go, avec 6 joueurs et 60 Zbires, masquer `Workspace.Decor.Vegetation` doit faire gagner 2 FPS au plus. Au-delà, on passe les Touffes au pas de 6.

## 5. Générateur (outil Studio, le résultat est enregistré dans la place)

```lua
-- ServerStorage.Outils.GenerateurVegetation (ModuleScript), à lancer depuis la barre de commande :
-- require(game.ServerStorage.Outils.GenerateurVegetation).generer(2026)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage.Charte)
local KIT = ServerStorage.KitVegetation
local PLAFOND = 1120 -- + 80 Parts posées à la main = 1 200
local R_PORTAIL, NB_PORTAILS, DEMI_CHEMIN = 85, 8, 6
local P = Charte.Prairie
local OMBRE = Color3.new(P.R * 0.8, P.G * 0.8, P.B * 0.8)
local LUMIERE = P:Lerp(Charte.Creme, 0.2)

-- Ordre = priorité : au plafond, les Touffes sautent en premier.
local COUCHES = {
	{ nom = "Arbres", rMin = 76, rMax = 100, pas = 7, p = 0.35, tag = "ArbreLisiere", clair = 14 },
	{ nom = "MasseFeuillage", rMin = 100, rMax = 160, pas = 14, p = 0.9, tag = "Fond", clair = 0 },
	{ nom = "SousBois", rMin = 70, rMax = 100, pas = 6, p = 0.3, tag = "SousBois", clair = 8 },
	{ nom = "BuissonBas", rMin = 50, rMax = 70, pas = 9, p = 0.5, tag = "Buisson", clair = 0 },
	{ nom = "Fleur", rMin = 30, rMax = 70, pas = 8, p = 0.4, tag = "Fleur", clair = 0 },
	{ nom = "Touffe", rMin = 20, rMax = 45, pas = 10, p = 1, tag = "Touffe", clair = 0 },
	{ nom = "Touffe", rMin = 45, rMax = 70, pas = 5, p = 0.95, tag = "Touffe", clair = 0 },
}
local SOUS_BOIS = { "Fougere", "Fougere", "Souche", "Champignon", "BuissonHaut" }

local function choisir(nom: string, z: number, r: number, rng: Random): string
	if nom == "SousBois" then return SOUS_BOIS[rng:NextInteger(1, #SOUS_BOIS)] end
	if nom ~= "Arbres" then return nom end
	local cote = z / r -- 1 = plein côté caméra (+Z)
	if cote > 0.5 then return "CheneNain" end
	local liste = if cote < -0.5 then { "Pin", "Chene", "Bouleau" } else { "Chene", "Bouleau" }
	return liste[rng:NextInteger(1, #liste)]
end

local function exclu(x: number, z: number, r: number, clair: number): boolean
	if r < R_PORTAIL + 4 and (math.abs(x) < DEMI_CHEMIN or math.abs(z) < DEMI_CHEMIN) then
		return true -- les 4 chemins en croix, jusqu'aux portails d'axe
	end
	for i = 0, NB_PORTAILS - 1 do
		local a = i * 2 * math.pi / NB_PORTAILS
		local dx, dz = x - math.cos(a) * R_PORTAIL, z - math.sin(a) * R_PORTAIL
		if dx * dx + dz * dz < clair * clair then return true end
	end
	return false
end

local M = {}

function M.generer(graine: number): number
	local rng = Random.new(graine)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Workspace.Carte.Sol }
	local ancien = Workspace.Decor:FindFirstChild("Vegetation")
	if ancien then ancien:Destroy() end
	local racine = Instance.new("Folder")
	racine.Name = "Vegetation"
	racine.Parent = Workspace.Decor
	local total = 0

	local function poser(nom: string, tag: string, x: number, z: number, jourFixe: number?): boolean
		local sol = Workspace:Raycast(Vector3.new(x, 60, z), Vector3.new(0, -120, 0), params)
		if not sol then return true end
		local modele = (KIT:FindFirstChild(nom) :: Model):Clone()
		local teinte = if rng:NextNumber() < 0.7 then OMBRE else P
		local n = 0
		for _, part in modele:GetDescendants() do
			if part:IsA("BasePart") then
				n += 1
				part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
				part.CastShadow = part.Name == "Houppier" and part.Size.Y >= 4
				if part.Name == "Houppier" then part.Color = teinte end
				if part.Name == "Cime" then part.Color = LUMIERE end
			end
		end
		if total + n > PLAFOND then
			modele:Destroy()
			return false
		end
		total += n
		modele:PivotTo(CFrame.new(x, sol.Position.Y, z) * CFrame.Angles(0, rng:NextInteger(0, 3) * math.pi / 2, 0))
		if tag == "ArbreLisiere" then modele:SetAttribute("Angle", math.atan2(z, x)) end
		if tag == "Fleur" then
			local jour = jourFixe or (if rng:NextNumber() < 0.4 then 0 else rng:NextInteger(1, 10))
			modele:SetAttribute("Jour", jour)
			if jour > 0 then (modele.PrimaryPart :: BasePart).Transparency = 1 end
		end
		CollectionService:AddTag(modele, tag)
		modele.Parent = racine
		return true
	end

	-- Bordures fleuries des 4 chemins, ouvertes dès le jour 1
	for _, dir in { Vector3.xAxis, -Vector3.xAxis, Vector3.zAxis, -Vector3.zAxis } do
		local lateral = Vector3.new(dir.Z, 0, dir.X)
		for d = 24, 66, 6 do
			for _, s in { -7, 7 } do
				local pos = dir * d + lateral * s
				poser("Fleur", "Fleur", pos.X, pos.Z, 0)
			end
		end
	end

	-- Couches sur grille décalée au hasard, regroupées en bosquets par un bruit
	for _, c in COUCHES do
		for gx = -110, 110 - c.pas, c.pas do
			for gz = -110, 110 - c.pas, c.pas do
				local x = math.round(gx + rng:NextNumber() * c.pas)
				local z = math.round(gz + rng:NextNumber() * c.pas)
				local r = math.sqrt(x * x + z * z)
				local a = math.atan2(z, x)
				local bord = c.rMin
				if c.nom == "Arbres" then
					bord += 8 * math.noise(math.cos(a) * 2, math.sin(a) * 2, graine % 97 + 0.5)
				end
				local amas = math.clamp(math.noise(x / 24, z / 24, graine % 89 + 0.5) + 0.5, 0, 1)
				if r >= bord and r < c.rMax and math.abs(x) <= 108 and math.abs(z) <= 108
					and not exclu(x, z, r, c.clair) and rng:NextNumber() < c.p * 2 * amas then
					if not poser(choisir(c.nom, z, r, rng), c.tag, x, z) then
						warn(`Plafond de {PLAFOND} atteint dans la couche {c.nom}`)
						return total
					end
				end
			end
		end
	end
	return total
end

return M
```

Une même graine redonne toujours la même forêt. La méthode : on génère une fois, on retouche les bosquets à la main, puis on ne relance plus le générateur.

## 6. Végétation vivante (client, purement cosmétique)

Le serveur pose deux attributs sur `Workspace` : `Jour`, mis à jour à chaque jour franchi, et `ColosseAngle`, en radians, 3 s avant l'arrivée du Colosse. Le client lit ces attributs mais n'envoie rien au serveur.

```lua
-- StarterPlayer.StarterPlayerScripts.VegetationVivante (LocalScript)
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local POP = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local FRISSON = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 5, true)
local origines: { [BasePart]: CFrame } = {}

local function pieces(modele: Instance): { BasePart }
	local liste = {}
	for _, p in modele:GetDescendants() do
		if p:IsA("BasePart") then table.insert(liste, p) end
	end
	return liste
end

-- Floraison : étirement × 1,2 puis retour élastique en 0,15 s, en cascade
local function fleurir()
	local jour = Workspace:GetAttribute("Jour") or 0
	for _, fleur in CollectionService:GetTagged("Fleur") do
		local j = fleur:GetAttribute("Jour") or 0
		if j > 0 and j <= jour and fleur.PrimaryPart and fleur.PrimaryPart.Transparency == 1 then
			for _, p in pieces(fleur) do
				local taille = p.Size
				p.Size = taille * Vector3.new(0.8, 1.2, 0.8)
				p.Transparency = 0
				TweenService:Create(p, POP, { Size = taille }):Play()
			end
			task.wait(0.03)
		end
	end
end
Workspace:GetAttributeChangedSignal("Jour"):Connect(function() task.spawn(fleurir) end)
task.spawn(fleurir)

-- Frisson : les arbres du secteur (± 30°) d'où surgit le Colosse tremblent pour l'annoncer
Workspace:GetAttributeChangedSignal("ColosseAngle"):Connect(function()
	local cible = Workspace:GetAttribute("ColosseAngle")
	if typeof(cible) ~= "number" then return end
	for _, arbre in CollectionService:GetTagged("ArbreLisiere") do
		local a = arbre:GetAttribute("Angle")
		if typeof(a) == "number" and math.abs((a - cible + math.pi) % (2 * math.pi) - math.pi) < math.rad(30) then
			for _, p in pieces(arbre) do
				if p.Name == "Houppier" or p.Name == "Cime" then
					origines[p] = origines[p] or p.CFrame
					p.CFrame = origines[p]
					TweenService:Create(p, FRISSON, { CFrame = origines[p] * CFrame.Angles(0, 0, math.rad(6)) }):Play()
				end
			end
		end
	end
end)

-- Herbe écrasée : Touffes et Fleurs masquées sous chaque défense posée, jusqu'à la fin de la run
CollectionService:GetInstanceAddedSignal("Defense"):Connect(function(defense)
	if not defense:IsA("Model") then return end
	local centre = defense:GetPivot().Position
	local demi = defense:GetExtentsSize() / 2 + Vector3.new(0.5, 0, 0.5)
	for _, tag in { "Touffe", "Fleur" } do
		for _, veg in CollectionService:GetTagged(tag) do
			local d = veg:GetPivot().Position - centre
			if math.abs(d.X) < demi.X and math.abs(d.Z) < demi.Z then
				for _, p in pieces(veg) do p.LocalTransparencyModifier = 1 end
			end
		end
	end
end)
```
