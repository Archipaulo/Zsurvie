## 1. Principes d'ambiance

- **Le ciel se lit au sol.** Caméra `Scriptable` à (0, 45, 28), `FieldOfView` 50 : plongée de 58°, le haut de l'écran vise 33° sous l'horizon. En run, le `Sky` n'est jamais à l'écran. L'humeur passe par la couleur du soleil, les ombres et l'`Atmosphere`. Le `Sky` se voit au Laboratoire et dans les plans de caméra levée : atterrissage de la Capsule, annonce du Colosse, chute de la Maison.
- **Le soleil est un chronomètre.** Sa course pendant les 80 s de horde indique le temps restant sans passer par l'UI.
- **Le code couleur reste lisible à toute heure.** Le violet, l'or, le cyan et le rose-rouge restent reconnaissables à chaque moment. Avec un `ColorShift_Bottom` froid et un `OutdoorAmbient` haut, les ombres sont bleutées et jamais noires.
- **Nuit douce.** Bleu Nuit labo, `ExposureCompensation` à 0,4 et jamais plus de 5 s de nuit.
- **Aucune lumière ne clignote à plus de 3 Hz** (risque de photosensibilité).
- Les couleurs de lumière sont des mélanges de la palette. Elles sont rangées dans `ReplicatedStorage.Charte.Ambiances`. Jamais de #000000 ni de #FFFFFF.

## 2. Réglages fixes

- `Technology` ShadowMap, `GlobalShadows` true, `ShadowSoftness` 0,1 (ombres nettes, style blocky), `GeographicLatitude` 20 (soleil haut, ombres courtes), `ColorShift_Bottom` #2A3263.
- `EnvironmentDiffuseScale` 0,25 et `EnvironmentSpecularScale` 0,1 sur la Prairie. Au Laboratoire, 0,4 et 0,3 pour que les néons se reflètent sur l'Ardoise.
- `ColorCorrectionEffect` nommé « ColorCorrection » :
  - Prairie : Saturation 0,12, Contrast 0,06, `TintColor` #FFF8EE ;
  - Laboratoire : Saturation 0,1, Contrast 0,08, `TintColor` propre à chaque zone (§ 6).
- `BloomEffect` : Intensity 0,35, Size 16, Threshold 1,6 sur la Prairie ; Intensity 0,6, Size 20, Threshold 1,3 au Laboratoire. Seules les Parts Neon rayonnent.
- Interdits : `SunRaysEffect`, `DepthOfFieldEffect` et `Clouds` (nuages réalistes, hors style). `PointLight.Shadows` est à false partout.

## 3. Réglages par moment

Dans ce tableau, « Exposure » désigne `ExposureCompensation`. Les colonnes Density à Glare sont les propriétés de `Lighting.Atmosphere`.

| Moment | ClockTime | Brightness | Ambient | OutdoorAmbient | ColorShift_Top | Exposure | Density | Offset | Color | Decay | Haze | Glare |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Aube | 5,5 | 1,8 | #4E4570 | #B08AAE | #F6B08A | 0,25 | 0,38 | 0,1 | #F4C6C0 | #8E6FB0 | 2,0 | 0 |
| Matin | 8,5 | 2,6 | #4E4A66 | #A6A2C0 | #F9DDB8 | 0,1 | 0,32 | 0,1 | #E6DDF0 | #8C7FB8 | 1,2 | 0 |
| Midi | 12 | 3,0 | #56526A | #B2ACA0 | #F6E7C1 | 0 | 0,26 | 0,1 | #D8EEF4 | #7FA7C9 | 0,8 | 0 |
| Après-midi | 15,5 | 2,8 | #5A4E5E | #B8A38F | #F8D39A | 0 | 0,30 | 0,1 | #F3E2C4 | #C8894F | 1,2 | 0 |
| Coucher | 18,6 | 1,8 | #4A3F5C | #AE808E | #EF7A2F | 0,2 | 0,36 | 0,1 | #F2B48A | #6B5A8E | 1,8 | 0,3 |
| Nuit | 21 → 3 | 1,2 | #3A3F6E | #6E76B0 | #8FA3E0 | 0,4 | 0,34 | 0,1 | #535676 | #2A3263 | 1,0 | 0 |
| Jour du Colosse | 17,5 | 2,4 | #5A3F58 | #C49494 | #F0904C | 0,1 | 0,40 | 0,05 | #F6A57A | #CC254F | 2,2 | 0,4 |
| Laboratoire | 19,4 fixe | 1,5 | #3C4478 | #5B64A0 | #9FB0E8 | 0,3 | 0,30 | 0 | #535676 | #2A3263 | 0,5 | 0 |

- **Midi** est le moment le plus saturé : c'est le pique-nique.
- **Jour du Colosse** : à 17,5, le soleil n'est qu'à 7° au-dessus de l'horizon et l'ombre de la Maison s'étire sur plus de 100 studs. L'`OutdoorAmbient` le plus clair du cycle garde les Zbires lisibles dans cette ombre. Leurs ombres immenses apportent le drame sans faire peur. Le `Decay` utilise l'ombre de l'Alerte, car le rose-rouge signale le danger.

## 4. Cycle jour / nuit : 95 s

| Temps du jour | Phase | `ClockTime` | Moment | Signal |
|---|---|---|---|---|
| 0 s | Horde | 8,5 | Matin | Portails : `Brightness` de 1 à 2,5 en 2 s |
| 40 s | Horde | 12 | Midi | — |
| 80 s | Répit | 15,5 | Après-midi | Les fenêtres de la Maison passent au Toit orange |
| 86 s | Répit | 18,6 | Coucher | — |
| 88 à 91 s | Nuit express | 21 → 3 | Nuit | Étoiles et Lune défilent, la Mine devient le phare |
| 93 s | Répit | 5,5 | Aube | — |
| 95 s = 0 s | Jour suivant | 8,5 | Matin | Bannière « Jour X », coq 8-bit |

- `ClockTime` évolue linéairement sur une horloge déroulée (8,5 → 32,5, modulo 24). Les couleurs et les autres valeurs suivent une courbe `smoothstep`.
- La horde se joue entre 8,5 et 15,5. Le soleil reste au-dessus de 35° et les ombres ne dépassent pas 1,5 fois la hauteur des objets.
- **Jour du Colosse** (jours 5, 10, 15…) : de 0 à 4 s, le soleil file de 8,5 à 17,5. Cette course annonce le Colosse, quel que soit son moment d'apparition. `ClockTime` reste ensuite à 17,5 jusqu'à 80 s, puis le Répit se déroule normalement. *Écart mineur avec le canon : la valeur 17,5 est atteinte à 4 s et non à 0 s.*
- **Chute de la Maison** : l'horloge se fige et la `Saturation` descend à -0,25 en 1,5 s, sans aller jusqu'au gris total.
- **Autorité** : le serveur publie la chronologie sous forme d'attributs, et chaque client calcule son éclairage 20 fois par seconde. Après le chargement, le serveur n'écrit plus dans `Lighting` : la réplication écraserait le calcul local.

## 5. Le Sky retenu : « Ciel Pixel-bloc »

Chaque place a une instance `Sky` dans `Lighting`. Roblox assombrit la skybox la nuit, donc un seul jeu de textures couvre tout le cycle.

- `SkyboxBk/Dn/Ft/Lf/Rt/Up` : 6 textures de 1024² peintes en pixels de 16 px.
  - Prairie : dégradé en 6 bandes, de la Crème à l'horizon au Gemme cyan clair (#5AD9E7) au zénith. Nuages cubiques en Crème et Crème ombre (#C5B99A).
  - Laboratoire (« Ciel Labo ») : dégradé du Nuit labo à l'Encre claire (#49444B), étoiles en croix de 3 × 3 pixels et une comète cyan.
- `SunTextureId` : soleil carré Or cerclé de Toit orange, `SunAngularSize` 18.
- `MoonTextureId` : Lune carrée Crème aux cratères Crème ombre, `MoonAngularSize` 14 (16 au Laboratoire).
- `StarCount` : 1200 sur la Prairie, 2000 au Laboratoire. `CelestialBodiesShown` : true.

## 6. Humeur par zone

| Zone | Humeur | Réglages |
|---|---|---|
| Laboratoire | Repaire de savant un soir de bricolage | Moment Laboratoire, `TintColor` #E8F6FA. Arbre des Recherches : `PointLight` #33D6F0, Range 20, Brightness 1,5. Doc Boulon : #5AD9E7, Range 12, Brightness 1. Une bande Neon cyan au sol par Alcôve. À la fin d'une recherche, sa machine flashe 2 fois en Or à 1 Hz |
| Quai des Capsules | Gare futuriste, départ imminent | `TintColor` #F6EEDC. Une `PointLight` par Capsule (Range 14, Brightness 1,2) : Normale #33D6F0, Difficile #FF2E63, du Jour #FFC933. Pendant les 15 s avant le départ, elle pulse de 0,5 à 2 Hz |
| Galerie des Zbires | Musée rigolo en visite nocturne | `TintColor` #F6EAF4. 3 `SpotLight` #FFC933 (Angle 45, Range 18, Brightness 2, `Face` Bottom) éclairent les socles : des figurines violettes sous un projecteur or |
| Maison | Cocon chaleureux | Fenêtres Neon Crème, en Toit orange pendant le Répit. `PointLight` intérieure #FFB36B (Range 16, Brightness 1,2), lampe de porche #F6E7C1 (Range 10). Sous 25 % de PV, le porche passe en #FF2E63 et pulse à 1 Hz |
| Mine | Trésor | `PointLight` #33D6F0, Range 12, Brightness 1,8. Elle gagne 30 % pendant 0,3 s à chaque gemme produite |
| Prairie | Pique-nique qui tourne au chaos | Midi saturé aux ombres courtes. Jour du Colosse orangé aux ombres immenses |
| Lisière | Forêt de cubes mystérieuse sans faire peur | L'`Atmosphere` adoucit l'anneau de 70 à 100 studs. 4 `PointLight` de portail #9B5DE5, Range 14, Brightness de 1 à 2,5 pendant 2 s à chaque début de horde. Le `ColorShift_Bottom` évite les ombres noires sous les arbres-cubes |

Le samedi de 16 h 45 à 17 h 15 (heure de Paris), le serveur du Laboratoire active l'attribut `ZbireDeLaSemaine`. La `TintColor` passe alors à #EFE3FB et les néons cyan virent au Violet horde.

## 7. Budget lumières

- **Prairie (12 lumières)** :
  - Maison : 2 ;
  - Mine : 1 ;
  - portails : 4 ;
  - Établi : 1 (#F0904C, Range 10) ;
  - Colosse : 1, les Jours du Colosse seulement ;
  - réserve : 3 éclats de 0,3 s maximum, recyclés.
- **Laboratoire (12 lumières)** :
  - Arbre des Recherches : 1 ;
  - Doc Boulon : 1 ;
  - Capsules : 3 ;
  - Galerie : 3 `SpotLight` ;
  - réserve : 4.
- **Neon d'ambiance sur la Prairie** : 32 Parts sur les 150 autorisées (6 fenêtres, 10 gemmes de la Mine, 16 pour les portails).

## 8. Code

```lua
-- ReplicatedStorage.Charte (extrait) : couleurs de lumière et cycle du jour
local hex = Color3.fromHex

local function moment(brightness, ambient, outdoor, top, exposure, density, offset, color, decay, haze, glare)
	return {
		Brightness = brightness, Ambient = hex(ambient), OutdoorAmbient = hex(outdoor),
		ColorShift_Top = hex(top), ExposureCompensation = exposure,
		Density = density, Offset = offset, Color = hex(color), Decay = hex(decay),
		Haze = haze, Glare = glare,
	}
end

Charte.Ambiances = {
	Aube = moment(1.8, "4E4570", "B08AAE", "F6B08A", 0.25, 0.38, 0.1, "F4C6C0", "8E6FB0", 2.0, 0),
	Matin = moment(2.6, "4E4A66", "A6A2C0", "F9DDB8", 0.1, 0.32, 0.1, "E6DDF0", "8C7FB8", 1.2, 0),
	Midi = moment(3.0, "56526A", "B2ACA0", "F6E7C1", 0, 0.26, 0.1, "D8EEF4", "7FA7C9", 0.8, 0),
	ApresMidi = moment(2.8, "5A4E5E", "B8A38F", "F8D39A", 0, 0.30, 0.1, "F3E2C4", "C8894F", 1.2, 0),
	Coucher = moment(1.8, "4A3F5C", "AE808E", "EF7A2F", 0.2, 0.36, 0.1, "F2B48A", "6B5A8E", 1.8, 0.3),
	Nuit = moment(1.2, "3A3F6E", "6E76B0", "8FA3E0", 0.4, 0.34, 0.1, "535676", "2A3263", 1.0, 0),
	Colosse = moment(2.4, "5A3F58", "C49494", "F0904C", 0.1, 0.40, 0.05, "F6A57A", "CC254F", 2.2, 0.4),
	Laboratoire = moment(1.5, "3C4478", "5B64A0", "9FB0E8", 0.3, 0.30, 0, "535676", "2A3263", 0.5, 0),
}

local FIN_DE_JOUR = {
	{ t = 86, clock = 18.6, moment = "Coucher" },
	{ t = 88, clock = 21, moment = "Nuit" },
	{ t = 91, clock = 27, moment = "Nuit" },
	{ t = 93, clock = 29.5, moment = "Aube" },
	{ t = 95, clock = 32.5, moment = "Matin" },
}

local function cycle(debut)
	local cles = table.clone(debut)
	for _, cle in FIN_DE_JOUR do
		table.insert(cles, cle)
	end
	return cles
end

Charte.DUREE_JOUR = 95
Charte.CycleJour = {
	Normal = cycle({ { t = 0, clock = 8.5, moment = "Matin" }, { t = 40, clock = 12, moment = "Midi" }, { t = 80, clock = 15.5, moment = "ApresMidi" } }),
	Colosse = cycle({ { t = 0, clock = 8.5, moment = "Matin" }, { t = 4, clock = 17.5, moment = "Colosse" }, { t = 80, clock = 17.5, moment = "Colosse" } }),
}
```

```lua
-- ServerScriptService.DirecteurDeRun (extrait) : le serveur possède le temps
local function commencerJour(numero: number)
	workspace:SetAttribute("JourNumero", numero)
	workspace:SetAttribute("JourColosse", numero % 5 == 0)
	workspace:SetAttribute("JourDebut", workspace:GetServerTimeNow())
end
-- À la chute de la Maison : workspace:SetAttribute("MaisonTombee", true)
```

```lua
-- StarterPlayer.StarterPlayerScripts.CycleCiel (LocalScript, place Prairie)
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local atmosphere = Lighting:WaitForChild("Atmosphere") :: Atmosphere
local correction = Lighting:WaitForChild("ColorCorrection") :: ColorCorrectionEffect

local PROPS_LIGHTING = { "Brightness", "Ambient", "OutdoorAmbient", "ColorShift_Top", "ExposureCompensation" }
local PROPS_ATMOSPHERE = { "Density", "Offset", "Color", "Decay", "Haze", "Glare" }
local PAS = 1 / 20

local function melange(a, b, k)
	if typeof(a) == "Color3" then
		return a:Lerp(b, k)
	end
	return a + (b - a) * k
end

local function appliquer(a, b, k)
	for _, nom in PROPS_LIGHTING do
		Lighting[nom] = melange(a[nom], b[nom], k)
	end
	for _, nom in PROPS_ATMOSPHERE do
		atmosphere[nom] = melange(a[nom], b[nom], k)
	end
end

local function mettreAJour()
	local debut = workspace:GetAttribute("JourDebut")
	if not debut or workspace:GetAttribute("MaisonTombee") then
		return
	end
	local t = math.clamp(workspace:GetServerTimeNow() - debut, 0, Charte.DUREE_JOUR)
	local cles = if workspace:GetAttribute("JourColosse") then Charte.CycleJour.Colosse else Charte.CycleJour.Normal
	for i = 1, #cles - 1 do
		local a, b = cles[i], cles[i + 1]
		if t <= b.t then
			local k = (t - a.t) / (b.t - a.t)
			Lighting.ClockTime = (a.clock + (b.clock - a.clock) * k) % 24
			appliquer(Charte.Ambiances[a.moment], Charte.Ambiances[b.moment], k * k * (3 - 2 * k))
			return
		end
	end
end

local cumul = 0
RunService.Heartbeat:Connect(function(dt)
	cumul += dt
	if cumul >= PAS then
		cumul = 0
		mettreAJour()
	end
end)

workspace:GetAttributeChangedSignal("MaisonTombee"):Connect(function()
	if workspace:GetAttribute("MaisonTombee") then
		TweenService:Create(correction, TweenInfo.new(1.5), { Saturation = -0.25 }):Play()
	end
end)

-- État d'attente avant le premier jour (atterrissage de la Capsule)
Lighting.ClockTime = 8.5
appliquer(Charte.Ambiances.Matin, Charte.Ambiances.Matin, 0)
```

## 9. Recette

- **Planche de contrôle** : les 8 Zbires, une pièce et une gemme posés sur la Prairie, capturés aux 7 moments. 5 testeurs de 9 à 13 ans doivent nommer chaque couleur codée sans erreur.
- **Performance** : sur Android 3 Go, avec 6 joueurs et 60 Zbires un Jour du Colosse, le jeu tient 30 FPS. Au MicroProfiler, `CycleCiel` prend moins de 0,2 ms par mise à jour. Si la cible n'est pas tenue, le Bloom est coupé en premier.
- **Sécurité visuelle** : chaque lumière qui pulse est mesurée et ne dépasse pas 3 Hz.
