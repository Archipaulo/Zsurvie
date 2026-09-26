## 1. Règles communes à tous les biomes

- **Aucun Terrain.** Parts ancrées en `SmoothPlastic`, décor sur grille de 1 stud, bâtiments sur grille de 4 studs. Décor non bloquant : `CanCollide`, `CanQuery`, `CanTouch` = `false` ; `CastShadow = false` sous 1 stud de haut.
- **Couleurs** tirées de `ReplicatedStorage.Charte` (base, ombre × 0,8, lumière + 20 % de Crème). Le décor ne prend jamais l'Or (réservé aux pièces). Le cyan reste à la Mine et au Laboratoire, le violet à la Lisière, l'Alerte aux dangers.
- **Fenêtre caméra.** Avec le décalage (0, 45, 28) et un `FieldOfView` de 50, un téléphone en paysage montre environ 88 studs de large, 41 studs devant le Survivant et 23 derrière. Chaque biome doit se reconnaître dans cette fenêtre : un repère au moins tous les 30 studs.
- **Les transitions se font par tramage.** Aucune frontière nette : un biome passe à l'autre par un motif de Bayer 4 × 4, en tuiles de 2 × 0,2 × 2 studs, sur 6 à 10 studs de large. On pose le disque du biome intérieur, puis des tuiles du biome extérieur, de plus en plus serrées. C'est la signature pixel art de Zsurvie (script au §6).

## 2. La run : une cible concentrique

La Maison est centrée sur l'origine, sol à Y = 0. Sa porte est au sud (+Z), face à la caméra.

| Bande (rayon) | Biome | Hauteur max | Parts |
|---|---|---|---|
| carré 16 × 16 | La Maison | 14 (canon) | 600 |
| 8 → 18 | Jardinet (transition) | 2 | 250 |
| centre (24, 0, −24) | La Mine et son carreau | 6 | 150 |
| 18 → 60 | La Prairie : 4 chemins de 8 studs, 4 quartiers | 6 | 1 900 |
| 60 → 70 | Orée (transition) | 8 | 400 |
| 70 → 100 | La Lisière et ses portails | 10 à 18 | 2 300 |
| 100 → bord | Fond | 20 | 400 |

Le décor prend 6 000 Parts. Les 4 000 restantes vont aux 60 Zbires (1 800), au Colosse, aux Survivants, aux 18 défenses et aux éclats. Budget du décor : 50 `Neon` sur 150, 6 `PointLight` sur 12, 6 sons sur 16.

**Lecture du canon.** Je lis « la Mine à 12 studs de la Maison » comme 12 studs de vide entre le mur et la Mine (8 × 8), soit un vrai couloir de course. Jardinet, Orée, Fond et les quartiers sont des noms de travail internes, jamais affichés au joueur.

## 3. Identité des biomes de la run

### La Maison et le Jardinet : « Je suis chez moi, je la protège »
- Sol en dalles Crème de 4 × 4, joints Crème ombre #C5B99A. L'herbe gagne sur les dalles par un tramage entre 12 et 18 studs.
- Pots de fleurs Toit orange de 1 × 1 × 1 et haie basse Prairie lumière #88C962. La Capsule d'arrivée (Toit orange, 6 studs) est posée au sud de la porte : le lien avec le Laboratoire se voit dès la première image.
- 6 fenêtres `Neon` Crème et une lanterne de porche : `PointLight` Crème, `Range` 14, `Brightness` 1,5. La lanterne ne s'allume qu'au Jour du Colosse.
- Pas de boucle sonore propre : le calme du centre tranche avec l'agitation de la périphérie.

### La Mine : « Un trésor qui brille, je veux le surveiller »
- Carreau d'Ardoise, avec un tramage d'herbe de 6 à 10 studs autour du centre. Rails Ardoise ombre #3B374D jusqu'à la porte, 2 wagonnets Terre battue.
- Rochers-cubes Ardoise et Ardoise lumière #6C6573, sommet à 6 studs au plus.
- 12 cubes `Neon` Gemme cyan, les seuls en cyan de la Prairie. Une `PointLight` cyan (`Range` 14, `Brightness` 1,2) et un `ParticleEmitter` d'étincelles (`Rate` 4).
- Carillon chiptune positionnel : `RollOffMaxDistance` 30, `Volume` 0,4.

### La Prairie : « Un pique-nique géant, on court partout »
- Sol Prairie parsemé d'environ 250 touffes Prairie lumière de 1 × 1 × 1.
- Chemins en Terre battue, bordés d'herbe tramée sur 1 stud. Au-delà de 50 studs, ils passent en Terre battue ombre #A06E3F. Dans l'Orée, des empreintes Violet horde ombre #7C4AB7 de 1 × 1 disent : « c'est par là qu'ils arrivent ».
- 4 quartiers d'orientation, pour que le ping « Ici ! » ait un sens sans chat :

| Quartier | Repère (6 studs au plus) | Accent |
|---|---|---|
| Nord-ouest : Verger | Pommiers-cubes de 5 studs (tronc 2, houppier 3 × 3 × 3) | Pommes Toit orange |
| Nord-est : Carreau | La Mine, les rails, les wagonnets | Gemme cyan |
| Sud-est : Potager | Sillons Terre battue, citrouilles de 2 × 2 × 2 | Toit orange ombre #BF6226 |
| Sud-ouest : Pique-nique | Nappes à carreaux de 6 × 6, paniers, parasols de 5 studs | Crème et Toit orange |

- **Le chaos progresse** avec les jours. Après chaque Colosse (jours 5, 10 et 15), le serveur renverse les props tagués `Chaos1`, `Chaos2` puis `Chaos3` (`CollectionService`) : nappes froissées, paniers retournés, pommes au sol. Il suffit d'environ 30 changements de `CFrame` par palier, sans ajouter de Part.

### L'Orée (60 → 70 studs) : « Le calme s'arrête ici »
- Tramage de la Prairie vers Prairie ombre #569B3B.
- Buissons-cubes de 2, 3 puis 4 studs, en escalier vers l'extérieur. Les premiers arbres (6 à 8 studs) apparaissent à 66 studs.
- Proposition : des murs invisibles fixent la limite jouable à 72 studs. Entre 70 et 74 studs, les troncs font un obstacle naturel.

### La Lisière (70 → 100 studs) : « Mystérieux, mais j'ai envie d'y jeter un œil »
- Environ 500 arbres-cubes de 4 Parts chacun. Tronc 2 × h × 2 en Terre battue ombre. Houppier de 2 ou 3 cubes de 4 × 4 × 4, en Prairie et Prairie ombre alternés. Le sol reste Prairie ombre, jamais Encre.
- **Décor de théâtre.** Au sud, côté caméra, les arbres font 10 studs au plus pour ne jamais masquer un Survivant. À l'est et à l'ouest : 14 studs au plus. Au nord, en fond d'image : 18 studs au plus.
- **Contamination douce.** À moins de 12 studs d'un portail, le cube du sommet des arbres passe en Violet horde ombre. Des champignons-cubes Violet horde lumière #AD79DE poussent au sol.
- **Portails.**
  - 4 grands dans l'axe des chemins, à r = 84 : arche Ardoise de 12 × 10, cœur `Neon` Violet horde lumière (5 `Neon`), `PointLight` de `Range` 16.
  - 4 petits en diagonale, à r = 80 : arche de 6 × 6, 3 `Neon`.
  - Chaque portail émet des cubes violets : `ParticleEmitter` avec `Rate` 12 et `Lifetime` 1,2.
  - Les 4 grands bourdonnent, en son positionnel avec `RollOffMaxDistance` 35.
- **Fond** (au-delà de 100 studs) : falaises-cubes Ardoise et Encre lumière #49444B de 12 à 20 studs, qui ferment l'horizon.

### Le Jour du Colosse : « Le grand moment, épique sans faire peur »
Ce n'est pas une zone, mais un état de la Prairie. `ClockTime` passe à 17,5 : lumière rasante orange, ombres violettes. Les fenêtres et la lanterne s'allument, et une basse chiptune lente remplace les oiseaux.

## 4. Les trois états de la Prairie

`Lighting.Ambient` reste fixé à Ardoise lumière. Le serveur se contente d'écrire `workspace:SetAttribute("EtatPrairie", ...)` avec la valeur `Horde`, `Repit` ou `Colosse`, et ne touche jamais à `Lighting`. Il passe à `Colosse` dès le Répit qui précède le Jour du Colosse.

| Propriété | Horde | Répit (15 s) | Colosse |
|---|---|---|---|
| Ressenti | Action joyeuse | On souffle, on répare | Tension épique |
| `ClockTime` | 14 | 14 | 17,5 |
| `Brightness` | 2,5 | 2,8 | 2 |
| `OutdoorAmbient` | Crème ombre | Crème ombre | Violet horde ombre |
| `ColorShift_Top` | Crème | Crème | Toit orange |
| `Atmosphere.Density` | 0,2 | 0,15 | 0,3 |
| `ColorCorrectionEffect.Saturation` | 0,15 | 0,25 | 0,2 |
| `Transparency` des `Neon` des portails | 0 | 0,6, particules coupées | 0 |
| Boucle d'ambiance | Tambours chiptune | Oiseaux 8-bit | Basse lente |

À préparer dans Studio :
- dans `SoundService`, 3 `Sound` en `Looped` : `BoucleHorde`, `BoucleRepit` et `BoucleColosse` ;
- dans `Lighting`, un `ColorCorrectionEffect` nommé `CorrectionBiome`.

```lua
-- StarterPlayerScripts > AmbianceBiomes (LocalScript, place Prairie). Purement cosmétique.
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local c = Charte.couleur -- c(nom, "base" | "ombre" | "lumiere") : Color3

local atmosphere = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local correction = Lighting:WaitForChild("CorrectionBiome") :: ColorCorrectionEffect
local portails = workspace:WaitForChild("Lisiere"):WaitForChild("Portails")
local NEUTRE = Color3.new(1, 1, 1)

local ETATS = {
	Horde = {
		duree = 2, son = "BoucleHorde", portail = 0,
		lighting = { ClockTime = 14, Brightness = 2.5, OutdoorAmbient = c("Creme", "ombre"), ColorShift_Top = c("Creme", "base") },
		atmo = { Density = 0.2, Color = c("Creme", "base"), Decay = c("Prairie", "lumiere") },
		cc = { Saturation = 0.15, Brightness = 0, TintColor = NEUTRE },
	},
	Repit = {
		duree = 1.5, son = "BoucleRepit", portail = 0.6,
		lighting = { ClockTime = 14, Brightness = 2.8, OutdoorAmbient = c("Creme", "ombre"), ColorShift_Top = c("Creme", "base") },
		atmo = { Density = 0.15, Color = c("Creme", "base"), Decay = c("Prairie", "lumiere") },
		cc = { Saturation = 0.25, Brightness = 0.05, TintColor = NEUTRE },
	},
	Colosse = {
		duree = 4, son = "BoucleColosse", portail = 0,
		lighting = { ClockTime = 17.5, Brightness = 2, OutdoorAmbient = c("VioletHorde", "ombre"), ColorShift_Top = c("ToitOrange", "base") },
		atmo = { Density = 0.3, Color = c("ToitOrange", "lumiere"), Decay = c("VioletHorde", "base") },
		cc = { Saturation = 0.2, Brightness = 0, TintColor = NEUTRE:Lerp(c("ToitOrange", "base"), 0.12) },
	},
}

local function tween(objet: Instance, duree: number, props: { [string]: any }): Tween
	local t = TweenService:Create(objet, TweenInfo.new(duree, Enum.EasingStyle.Sine), props)
	t:Play()
	return t
end

local boucleActive: Sound? = nil

local function appliquer(nom: any)
	local etat = ETATS[nom] or ETATS.Horde
	tween(Lighting, etat.duree, etat.lighting)
	tween(atmosphere, etat.duree, etat.atmo)
	tween(correction, etat.duree, etat.cc)
	for _, objet in portails:GetDescendants() do
		if objet:IsA("BasePart") and objet.Material == Enum.Material.Neon then
			tween(objet, etat.duree, { Transparency = etat.portail })
		elseif objet:IsA("ParticleEmitter") then
			objet.Enabled = etat.portail < 0.5
		end
	end
	local nouvelle = SoundService:FindFirstChild(etat.son) :: Sound?
	if nouvelle == boucleActive then return end
	local ancienne = boucleActive
	boucleActive = nouvelle
	if ancienne then
		tween(ancienne, 1.5, { Volume = 0 }).Completed:Once(function()
			if ancienne ~= boucleActive then ancienne:Stop() end
		end)
	end
	if nouvelle then
		nouvelle.Volume = 0
		nouvelle:Play()
		tween(nouvelle, 1.5, { Volume = 0.3 })
	end
end

appliquer(workspace:GetAttribute("EtatPrairie"))
workspace:GetAttributeChangedSignal("EtatPrairie"):Connect(function()
	appliquer(workspace:GetAttribute("EtatPrairie"))
end)
```

## 5. Le lobby : trois ambiances dans une seule place

Réglages communs de `Lighting` : `ClockTime` 0, `Sky.StarCount` 3000, `Ambient` et `OutdoorAmbient` en Nuit labo lumière #535676, `Brightness` 1. La rotonde du Laboratoire n'a pas de plafond (murs de 16 studs) : la caméra ne s'y coince jamais.

| Zone | Ressenti | Sol et murs | Accents et lumière | Son | Neon |
|---|---|---|---|---|---|
| Le Laboratoire | Fierté et curiosité : « mon Alcôve montre mes inventions » | Damier 4 × 4 Ardoise et Ardoise ombre, murs Nuit labo | Bandeau `Neon` cyan en haut des murs ; sol des Alcôves en Crème pour détacher les machines ; 6 `PointLight` cyan | Ronron de machines, bips | 70 |
| Le Quai des Capsules | Élan : « on part ensemble » | Quai Ardoise lumière, voies Encre lumière | Capsule Normale Toit orange, Difficile Alerte, du Jour Gemme cyan (elle rapporte des gemmes) ; 3 `PointLight` | Jingle de gare, 3 notes à chaque départ | 40 |
| La Galerie des Zbires | Rire et collection | Parquet Terre battue lumière #D19C66 en planches de 1 × 4, murs Crème | Socles Violet horde ombre ; liseré de palier Crème à 10 éliminations, Toit orange à 100, `Neon` cyan à 1 000 (jamais d'Or) ; 3 `PointLight` Crème | Boîte à musique 8-bit | 30 |

Il reste 10 `Neon` en réserve.

**Transitions du lobby.** Entre deux zones, un sas de 12 studs avec un sol tramé et une arche de 8 studs. Un dossier `ZonesLobby` contient 3 boîtes invisibles. Toutes les 0,25 s, le client compare `boite.CFrame:PointToObjectSpace(racine.Position)` à la moitié de `Size`. En changeant de zone, il fait glisser en 1,5 s le `TintColor` (Laboratoire : neutre + 8 % de cyan ; Galerie : neutre + 10 % de Crème) et fond les boucles d'ambiance.

**Du Laboratoire à la Prairie.** `TeleportService:SetTeleportGui` affiche un écran Nuit labo avec une Capsule en pixels. À l'arrivée, la même Capsule attend dans le Jardinet.

## 6. Générer les tramages (barre de commande Studio)

```lua
-- Mode édition. Tramage Bayer 4×4 en tuiles 2×2 : densité 0 % à rMin, 100 % à rMax.
-- Les chemins (|x| ou |z| < 4) restent nus.
local Charte = require(game:GetService("ReplicatedStorage").Charte)
local BAYER = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 }

local function tramer(nom: string, centre: Vector3, rMin: number, rMax: number, couleur: Color3, parent: Instance)
	local dossier = Instance.new("Folder")
	dossier.Name = nom
	local total = 0
	for gx = -rMax, rMax - 2, 2 do
		for gz = -rMax, rMax - 2, 2 do
			local x, z = centre.X + gx + 1, centre.Z + gz + 1
			local t = (math.sqrt((gx + 1) ^ 2 + (gz + 1) ^ 2) - rMin) / (rMax - rMin)
			local seuil = (BAYER[((gz // 2) % 4) * 4 + (gx // 2) % 4 + 1] + 0.5) / 16
			local surChemin = math.abs(x) < 4 or math.abs(z) < 4
			if t >= 0 and t < 1 and t > seuil and not surChemin then
				local tuile = Instance.new("Part")
				tuile.Anchored = true
				tuile.CanCollide, tuile.CanQuery, tuile.CanTouch, tuile.CastShadow = false, false, false, false
				tuile.Material = Enum.Material.SmoothPlastic
				tuile.Color = couleur
				tuile.Size = Vector3.new(2, 0.2, 2)
				tuile.Position = Vector3.new(x, centre.Y + 0.1, z)
				tuile.Parent = dossier
				total += 1
			end
		end
	end
	dossier.Parent = parent
	print(nom, total, "tuiles")
end

local decor = workspace:WaitForChild("Decor")
tramer("Tramage_Jardinet", Vector3.zero, 12, 18, Charte.couleur("Prairie", "base"), decor)
tramer("Tramage_Carreau", Vector3.new(24, 0, -24), 6, 10, Charte.couleur("Prairie", "base"), decor)
tramer("Tramage_Oree", Vector3.zero, 60, 70, Charte.couleur("Prairie", "ombre"), decor)
```

Les trois tramages doivent rester sous 350 tuiles au total (estimation : 70 pour le Jardinet, 25 pour le Carreau, 215 pour l'Orée).
