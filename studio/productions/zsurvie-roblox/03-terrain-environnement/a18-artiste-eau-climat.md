## 1. Principes eau et climat

- **Pendant la run, le ciel reste hors champ.** Avec la caméra (0, 45, 28) et un `FieldOfView` de 50, le bord haut de l'écran reste 33° sous l'horizon. On ne consacre donc aucun budget à `Sky` ni à `Clouds` sur la Prairie : la météo se lit au sol, dans la teinte de l'image et au son.
- **La météo est cosmétique et c'est le serveur qui la décide.** Il publie des attributs sur `ReplicatedStorage` et le client dessine. Il n'y a aucun `RemoteEvent`, et la météo n'agit ni sur les PV, ni sur les pièces, ni sur les gemmes.
- **La lisibilité passe d'abord.** Un Zbire au bord haut de l'écran, à 82 studs de la caméra, doit rester net. D'où la règle : `Atmosphere.Density` ≤ 0,45.
- **La météo ne change que pendant le Répit**, avec un fondu de 8 s, jamais en pleine horde.
- **Style Pixel-bloc :** une goutte = 1 pixel étiré, un flocon = 1 cube de 0,5 stud, l'eau suit la grille de 4 studs.

## 2. L'eau

### Écart à faire valider par Victor Lanoue
Le canon interdit le Terrain lisse. **La Prairie n'a donc aucun voxel** : toute son eau est faite de Parts « Eau-bloc ». **Le Laboratoire a un seul volume de Terrain `Water`** : le Bassin de Doc Boulon, de 24 × 8 × 16 studs. Il est rempli par `Terrain:FillBlock` calé sur la grille de 4 studs, et ses bords sont cachés par des margelles `SmoothPlastic`. C'est le seul endroit du jeu où l'on nage. Si Victor refuse, le Bassin devient de l'Eau-bloc de 1 stud de fond où l'on patauge.

| `Workspace.Terrain` | Valeur | Effet |
|---|---|---|
| `WaterColor` | `Color3.fromRGB(41, 171, 192)` (ombre de Gemme cyan) | Raccord avec les néons cyan |
| `WaterTransparency` | 0,55 | On voit les 4 bandes `Neon` du fond |
| `WaterWaveSize` | 0,05 | Surface presque plane, qui garde une lecture « bloc » |
| `WaterWaveSpeed` | 6 | L'eau frémit, sans houle |
| `WaterReflectance` | 0,25 | Reflète les néons, sans effet miroir |

### La Douve de Lisière (Eau-bloc)
C'est un anneau d'eau entre 71 et 75 studs du centre, tracé en escalier pixel (160 Parts au maximum). 4 ponts-bloc de 8 studs de large le franchissent sur les chemins. La Douve marque la limite de la Prairie. Chaque Zbire au sol qui la traverse fait « plouf », alors que le Volant passe au-dessus sans éclabousser. C'est un décor de la Lisière, pas une nouvelle zone.

| Instance | Réglages |
|---|---|
| Surface | `SmoothPlastic`, #29ABC0, `Transparency` 0,35, `Reflectance` 0,1, `CastShadow`, `CanCollide` et `CanQuery` à false, posée à −0,5 stud |
| Lit | `SmoothPlastic` Nuit labo #2A3263 à −1,5 stud : il fonce l'eau sans ajouter de couleur |
| `Texture` vaguelettes (face `Top`) | 32 × 32 px, Crème, `Transparency` 0,6, `StudsPerTileU/V` 8, défilement côté client de 0,4 stud/s en diagonale |
| Plouf | Un seul `ParticleEmitter` partagé (`Rate` 0), `:Emit(5)` au franchissement, 6 ploufs par seconde au maximum, cubes Crème (`Size` 0,5 → 0, `Lifetime` 0,35) |
| Flaques | 16 Parts de 4 × 0,1 × 4 posées sur les chemins, tag `Flaque`, #29ABC0, `Reflectance` 0,2, `Transparency` 1 par défaut et 0,45 sous la pluie |

**L'eau ne doit pas ressembler aux gemmes.** Elle reste mate, n'est jamais en `Neon` et ne scintille jamais. Le cyan lumineux est réservé aux gemmes et à la Mine.

## 3. Météo dynamique

### Calendrier

| Jour | Météo |
|---|---|
| Jours 1 et 2 | Clair, pour que le tutoriel reste lisible |
| Veilles de Colosse (4, 9, 14…) | Clair, pour que l'orage marque le coup |
| Jour du Colosse (5, 10, 15…) | Orage |
| Autres jours | Tirage avec la graine de la run : Clair 50 %, Averse 30 %, Brume 20 %. Jamais 3 Averses ou 3 Brumes de suite |
| Défi du Jour, événement d'hiver | Peuvent imposer une météo, dont la Neige |
| Laboratoire | Ciel = météo du Défi du Jour (graine = date UTC), avec `Clouds` : `Cover` 0,5, `Density` 0,6, Crème. Au Quai des Capsules, un baromètre-bloc l'annonce |

### Cycle du jour
Le client calcule `ClockTime` 4 fois par seconde à partir de `JourDebut`, en temps serveur :
- pendant la horde (80 s), l'heure passe de 9 à 14,5 ;
- pendant le Répit (15 s), elle passe de 14,5 à 15,5, ou de 14,5 à 17,5 la veille d'un Colosse ;
- le Jour du Colosse, elle reste fixée à 17,5, comme le veut le canon ;
- au début d'un nouveau jour, elle repasse à 9 derrière un fondu d'aube : `Brightness` part de −0,3 et remonte en 0,6 s.

Hors Colosse, l'heure ne dépasse jamais 16 : le crépuscule appartient au Colosse.

### Profils (`Lighting.Atmosphere` + `ColorCorrectionEffect` « CorrectionMeteo »)
Quand un `Atmosphere` est présent, `FogStart` et `FogEnd` sont ignorés. `Glare` vaut 0 dans tous les états.

| État | `Density` | `Offset` | `Haze` | `Color` | `Decay` | `Saturation` | `Brightness` |
|---|---|---|---|---|---|---|---|
| Clair | 0,22 | 0,30 | 0,5 | Crème #F6E7C1 | Crème ombre #C5B99A | 0,10 | 0 |
| Averse | 0,34 | 0,20 | 1,2 | Ardoise lumière #6C6573 | Nuit labo #2A3263 | −0,05 | −0,04 |
| Brume | 0,42 | 0,10 | 2,0 | Crème | Ardoise lumière | −0,02 | 0,02 |
| Orage | 0,36 | 0,15 | 1,5 | Toit orange lumière #F0904C | Violet horde ombre #7C4AB7 | 0,05 | −0,06 |
| Neige | 0,30 | 0,25 | 1,0 | Crème | Nuit labo lumière #535676 | −0,08 | 0,04 |

### Effets (tous dans `ReplicatedStorage.KitMeteo`)
- **Voile de pluie** : il fait l'essentiel de la pluie pour un coût quasi nul. Ce sont 2 Parts côté client, dans `CurrentCamera`, placées à 12 et 24 studs devant l'objectif. Elles mesurent 32 × 16 et 60 × 28 studs, avec `Transparency` 1. Sur leur face `Back`, une `Texture` de traits pixel en 64 × 64 : `StudsPerTile` 6 et 10, `Transparency` 0,55 et 0,7, défilement à 30 et 18 studs/s pour créer de la parallaxe.
- **Gouttes** : 2 `ParticleEmitter` avec `Rate` 20, sur une Part de 60 × 1 × 60 placée 30 studs au-dessus du Survivant. Réglages : `Lifetime` 0,8, `Speed` 60, `Size` 0,5, `Squash` 2, `VelocityParallel`, `LightInfluence` 0, Crème.
- **Brume** : 24 Parts Crème de 8 × 2 × 8 (tag `BrumeCube`), `Transparency` 0,7, entre 78 et 96 studs du centre. Elles tournent autour de la Prairie à 2 studs/s. Les portails violets restent visibles à travers : l'ambiance est mystérieuse, sans jamais faire peur.
- **Neige** : 2 émetteurs avec `Rate` 18, `Lifetime` 3, `Speed` 8 et `RotSpeed` 90, qui lâchent des cubes Crème de 0,5 stud.
- **Éclairs** : ils sont espacés de 10 à 16 s. `Brightness` monte de 0,25 en 0,08 s, puis redescend en 0,35 s. Le tonnerre chiptune suit 1,2 s plus tard, avec un volume de 0,35 : pas de jump scare. L'attribut `EffetsReduits` du Player coupe les flashs.

**Budget par client (plafond du canon entre parenthèses) :**
- `Rate` : 20 (20) ;
- `Neon` : 0 sur la Prairie et 4 au Laboratoire (150) ;
- `PointLight` : 0 (12) ;
- sons : 2 dans le `SoundGroup` Ambiance (16) ;
- Parts : environ 205 (10 000).

**Mode léger** : si la moyenne tombe sous 27 FPS pendant les 5 premières secondes, le client coupe les gouttes, le voile lointain et un cube de brume sur deux.

## 4. Pseudo-code du système

```lua
-- ServerScriptService.MeteoServeur (ModuleScript), appelé par le Directeur de run
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MeteoServeur = {}
local TIRAGE = { { "Clair", 50 }, { "Averse", 30 }, { "Brume", 20 } }
local graineRun, forcee = 0, nil :: string?
local derniere, serie = "Clair", 0

local function publier(meteo: string, jour: number)
	serie = if meteo == derniere then serie + 1 else 1
	derniere = meteo
	ReplicatedStorage:SetAttribute("MeteoEtat", meteo)
	ReplicatedStorage:SetAttribute("MeteoGraine", graineRun * 1000 + jour)
	ReplicatedStorage:SetAttribute("MeteoDebut", workspace:GetServerTimeNow()) -- signal client
end

function MeteoServeur.debutJour(jour: number)
	ReplicatedStorage:SetAttribute("JourNumero", jour)
	ReplicatedStorage:SetAttribute("JourDebut", workspace:GetServerTimeNow())
end

function MeteoServeur.demarrerRun(graine: number, meteoForcee: string?)
	graineRun, forcee, derniere, serie = graine, meteoForcee, "Clair", 0
	MeteoServeur.debutJour(1)
	publier("Clair", 1)
end

-- Premier instant du Répit qui précède `jour`
function MeteoServeur.planifierJour(jour: number)
	local meteo = "Clair"
	if jour % 5 == 0 then
		meteo = "Orage" -- Jour du Colosse
	elseif jour > 2 and jour % 5 ~= 4 then
		if forcee then
			meteo = forcee
		else
			local n = Random.new(graineRun * 1000 + jour):NextInteger(1, 100)
			for _, e in TIRAGE do
				n -= e[2]
				if n <= 0 then meteo = e[1] break end
			end
			if meteo == derniere and serie >= 2 then meteo = "Clair" end
		end
	end
	publier(meteo, jour)
end

return MeteoServeur
```

```lua
-- StarterPlayerScripts.MeteoClient (LocalScript, Prairie ; centre de la Prairie = origine)
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local C = require(ReplicatedStorage.Charte)
local joueur, camera = Players.LocalPlayer, workspace.CurrentCamera
local atmo = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local cc = Lighting:WaitForChild("CorrectionMeteo") :: ColorCorrectionEffect
local kit = ReplicatedStorage:WaitForChild("KitMeteo")
local function attr(nom: string): any return ReplicatedStorage:GetAttribute(nom) end

-- Density, Offset, Haze, Color, Decay, Saturation, Brightness
local P = {
	Clair = { 0.22, 0.30, 0.5, C.Creme, C.CremeOmbre, 0.10, 0 },
	Averse = { 0.34, 0.20, 1.2, C.ArdoiseLumiere, C.NuitLabo, -0.05, -0.04, pluie = true },
	Brume = { 0.42, 0.10, 2.0, C.Creme, C.ArdoiseLumiere, -0.02, 0.02, brume = true },
	Orage = { 0.36, 0.15, 1.5, C.ToitOrangeLumiere, C.VioletHordeOmbre, 0.05, -0.06, pluie = true, eclairs = true },
	Neige = { 0.30, 0.25, 1.0, C.Creme, C.NuitLaboLumiere, -0.08, 0.04, neige = true },
}
local voiles = { kit.VoileProche:Clone(), kit.VoileLoin:Clone() }
local emetteurs = kit.Emetteurs:Clone() -- Pluie1, Pluie2, Neige1, Neige2
voiles[1].Parent, voiles[2].Parent, emetteurs.Parent = camera, camera, camera
local brume = {}
for _, cube in CollectionService:GetTagged("BrumeCube") do brume[cube] = cube.CFrame end
local etat, eclairs, leger = P.Clair, {} :: { number }, false

local function tween(obj: Instance, props: { [string]: any }, duree: number?)
	TweenService:Create(obj, TweenInfo.new(duree or 8, Enum.EasingStyle.Sine), props):Play()
end

local function appliquer()
	etat = P[attr("MeteoEtat")] or P.Clair
	tween(atmo, { Density = etat[1], Offset = etat[2], Haze = etat[3], Color = etat[4], Decay = etat[5] })
	tween(cc, { Saturation = etat[6], Brightness = etat[7] })
	for i, v in voiles do
		tween(v.Texture, { Transparency = if etat.pluie and not (leger and i == 2) then 0.4 + 0.15 * i else 1 })
	end
	for _, pe in emetteurs:GetChildren() do
		if pe:IsA("ParticleEmitter") then
			pe.Enabled = not leger and (if pe.Name:find("Pluie") then etat.pluie else etat.neige) == true
		end
	end
	for _, f in CollectionService:GetTagged("Flaque") do
		tween(f, { Transparency = if etat.pluie then 0.45 else 1 })
	end
	local n = 0
	for cube in brume do
		n += 1
		tween(cube, { Transparency = if etat.brume and not (leger and n % 2 == 0) then 0.7 else 1 })
	end
	table.clear(eclairs) -- même calendrier sur tous les clients, jamais d'éclair passé
	if etat.eclairs then
		local rng, t = Random.new(attr("MeteoGraine")), attr("MeteoDebut") + 10
		for _ = 1, 12 do
			t += rng:NextNumber(10, 16)
			if t > workspace:GetServerTimeNow() then table.insert(eclairs, t) end
		end
	end
end

local function eclair()
	local son = kit.Tonnerre:Clone() -- chiptune, Volume 0.35, SoundGroup Ambiance
	son.Parent = camera
	son.Ended:Once(function() son:Destroy() end)
	task.delay(1.2, son.Play, son)
	if joueur:GetAttribute("EffetsReduits") then return end
	tween(cc, { Brightness = etat[7] + 0.25 }, 0.08)
	task.delay(0.08, tween, cc, { Brightness = etat[7] }, 0.35)
end

local function heure(jour: number, t: number): number
	if jour % 5 == 0 then return 17.5 end -- Jour du Colosse (canon)
	if t <= 80 then return 9 + 5.5 * t / 80 end
	local fin = if jour % 5 == 4 then 17.5 else 15.5
	return 14.5 + (fin - 14.5) * math.min((t - 80) / 15, 1)
end

local accu, mesure, images = 0, 0, 0
RunService.Heartbeat:Connect(function(dt)
	local maintenant = workspace:GetServerTimeNow()
	for i, v in voiles do
		v.CFrame = camera.CFrame * CFrame.new(0, 0, -12 * i)
		v.Texture.OffsetStudsV = (v.Texture.OffsetStudsV + dt * (42 - 12 * i)) % v.Texture.StudsPerTileV
	end
	local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
	if racine then emetteurs.CFrame = CFrame.new(racine.Position + Vector3.yAxis * 30) end
	if etat.brume then
		local rot = CFrame.Angles(0, maintenant * 2 / 87, 0) -- 2 studs/s à 87 studs du centre
		for cube, base in brume do cube.CFrame = rot * base end
	end
	if eclairs[1] and maintenant >= eclairs[1] then
		table.remove(eclairs, 1)
		eclair()
	end
	accu += dt
	if accu >= 0.25 then
		accu = 0
		local cible = heure(attr("JourNumero") or 1, maintenant - (attr("JourDebut") or maintenant))
		if math.abs(cible - Lighting.ClockTime) > 1 then -- fondu d'aube
			cc.Brightness = etat[7] - 0.3
			tween(cc, { Brightness = etat[7] }, 0.6)
		end
		Lighting.ClockTime = cible
	end
	if mesure < 5 then
		mesure += dt
		images += 1
		if mesure >= 5 and images / mesure < 27 then
			leger = true
			appliquer()
		end
	end
end)

ReplicatedStorage:GetAttributeChangedSignal("MeteoDebut"):Connect(function() task.defer(appliquer) end)
appliquer()
```
