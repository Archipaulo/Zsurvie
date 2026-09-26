## 1. Règles communes (mobile d'abord)

| Élément | Vignette | Icône |
|---|---|---|
| Format d'export | 1920 × 1080 PNG | 512 × 512 PNG |
| Taille réelle sur téléphone | ≈ 300 × 170 px (tuile d'accueil) | ≈ 90 × 90 px (recherche, favoris) |
| Zone sûre | 5 % de marge (96 px sur les côtés, 54 px en haut), 15 % en bas (162 px) | contenu clé dans le carré central de 410 px (coins arrondis) |
| Texte | 3 mots maximum, hauteur ≥ 12 % de l'image | aucun (le nom s'affiche dessous) |
| Masses lisibles | 3 au maximum | 1 personnage ou 1 objet |

- **Test du plissement :** chaque maquette est vérifiée à 256 × 144 (vignette) et à 64 × 64 (icône), puis en niveaux de gris. Si la silhouette violette ne ressort pas, on refait.
- **Vérité du jeu :** on ne capture que les vrais modèles, dans la place `Zsurvie_Vignettes`. Pas de Zbire inventé, pas d'échelle trichée, pas de « Jour 30 » : à 95 s par jour et 25 min au plus, une run plafonne vers le jour 15. Roblox interdit les images trompeuses.
- **Public 9-15 ans :** ni sang ni visage effrayant, ni Robux ni « GRATUIT », aucun accessoire UGC de marque. Les Survivants sont des avatars blocs R15 en Crème et Toit orange, avec le Blaster et le Sac à dos bien visibles.
- **Texte :** lettrage bloc du logo, remplissage Crème #F6E7C1, contour Encre #1E1B2E de 10 px, ombre Encre de 8 px. Les versions FR et EN passent par la localisation des images du Creator Hub.
- **Couleurs canon :** violet = Zbires ; orange et crème = Maison et Survivants ; or = pièces ; cyan = gemmes. L'Alerte #FF2E63 est réservée à la bulle « Colosse ! ».

## 2. Trois concepts de vignette

### V1 « Le Colosse arrive ! » (épique)
- **Composition :** caméra basse (6 studs) de 3/4, `FieldOfView` 40. Le Colosse occupe le tiers gauche sur 55 % de la hauteur, la tête au-dessus de l'horizon. La Maison se place dans le tiers droit, sur fond de Prairie : devant le ciel, son toit orange se noierait dans le couchant. Au premier plan, 4 Survivants vus de 3/4 dos tirent des traînées Or vers le Colosse.
- **Personnages :** le Colosse, bouche grande ouverte, rigolo sans être menaçant. 6 à 8 Marcheurs et Rapides éclatent en cubes violets et en pièces. Un Survivant répare la Maison dans une gerbe d'étincelles Or. Bouger, tirer, réparer : tout le jeu tient en une image.
- **Texte :** la bulle de la Roue des Pings « Colosse ! » en Alerte, au-dessus d'un Survivant. C'est 1 mot, tiré de la vraie UI du jeu. Logo ZSURVIE en haut à gauche.
- **Lumière :** `ClockTime` 17,5, l'état canon du Jour du Colosse. Ciel orange-crème, Colosse Violet horde #9B5DE5 à contre-jour avec un liseré Crème : une silhouette sombre sur un ciel clair.

### V2 « Défendez à 6 ! » (coopération)
- **Composition :** la vraie caméra du jeu (décalage 0, 45, 28, `FieldOfView` 50), avec la Maison au centre exact. Les 4 chemins en croix de Terre battue #C8894F servent de lignes de fuite. 4 flots de Zbires sortent des portails violets de la Lisière.
- **Personnages :** 6 Survivants en étoile autour de la Maison, avec un Muret, une Mini-Tourelle et un Tapis Collant couvert de Zbires englués. Un Volant passe au-dessus du Muret, un Gluant se divise en 2 Mini-Gluants. La Mine brille en cyan à 12 studs.
- **Texte :** « DÉFENDEZ À 6 ! » (EN : « 6-PLAYER CO-OP! ») en haut à droite, sur 14 % de la hauteur.
- **Couleurs :** fond Prairie #6CC24A, anneau violet en périphérie, cœur orange-crème. L'image se lit comme une cible.
- **Risque :** trop de petits éléments pour bien se lire à 300 px. V2 joue donc le challenger.

### V3 « Jour 1 → Jour 12 » (progression)
- **Composition :** l'écran est coupé en diagonale par une bande Or de 12 px. À gauche : Maison intacte, 1 Survivant, 3 Marcheurs, `ClockTime` 9. À droite, même cadrage : Tourelle de toit, Balles explosives, 3 Survivants, 20 Zbires et le panneau « Record : Jour 12 ».
- **Texte :** deux étiquettes, « JOUR 1 » et « JOUR 12 ».
- **Couleurs :** à gauche, `Saturation` −0,2 ; à droite, +0,3 avec une gerbe de gemmes cyan.
- **Usage :** V3 promet la progression du Laboratoire. Elle occupe la position 2 du carrousel, même si elle perd son test.

Positions 4 et 5 du carrousel : le Laboratoire (Alcôves, néons cyan) et la Galerie des Zbires.

## 3. Deux concepts d'icône

### I1 « Le Zbire gourmand »
- La tête d'un Marcheur remplit 65 % de l'icône, de 3/4 face : clin d'œil et grand sourire à une seule dent. La grille de 0,5 stud reste visible, c'est la signature Pixel-bloc. En bas à droite, il croque le coin d'un toit orange.
- Fond Prairie #6CC24A, halo central Prairie clair (+20 % de Crème) et liseré Encre de 6 px autour du Zbire.
- Aucun texte : le Zbire devient la mascotte que l'on reconnaît dans la recherche.

### I2 « La Maison assiégée »
- La Maison au centre, en plongée de 3/4. Un Survivant se tient sur le toit, Blaster levé. Un Casqué, un Gluant, un Volant et un Costaud s'agrippent aux 4 murs et forment un anneau violet.
- Fond Nuit labo #2A3263 pour ressortir sur le thème clair de Roblox, gerbe de pièces Or au-dessus du toit. Aucun texte.

## 4. Quoi tester en premier

| Ordre | Test | Pourquoi |
|---|---|---|
| 1 | **V1 (témoin) contre V2** | V1 a seulement 3 masses, le plus fort contraste de valeur et un effet d'échelle. L'accueil Roblox affiche surtout des vignettes 16:9. |
| 2 | I1 (témoin) contre I2 | La recherche et les favoris montrent l'icône. À 90 px, un visage bat presque toujours une scène. |
| 3 | Gagnant du test 1 contre V3 | On teste la promesse de progression une fois la base fixée. |

- **Outil :** le test A/B des vignettes et des icônes du Creator Hub. Chaque test dure au moins 7 jours, pour couvrir un samedi de Zbire de la Semaine.
- **Mesure :** le taux de clic (visites ÷ impressions) et la durée moyenne de session. Une image qui gagne des clics mais fait perdre plus de 5 % de durée de session est rejetée.
- **Règle :** un seul test à la fois, et aucune image modifiée pendant un test.

## 5. Mise en scène dans Studio

- **Place `Zsurvie_Vignettes` :** une copie de la Prairie construite, jamais publiée comme place jouable. `Lighting.Technology` y passe à `Future` à la main, dans le panneau Propriétés : c'est la seule place qui peut s'en permettre le coût.
- **Cadrage :** avec l'émulateur d'appareil réglé sur un appareil personnalisé de 1920 × 1080. Le texte s'ajoute hors de Studio.
- **Icônes :** posées sur un plateau à (300, 0, 0), en dehors de l'arène, puis recadrées en carré.

```lua
-- MiseEnScene : barre de commande de Studio, place Zsurvie_Vignettes uniquement
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))

local function couleur(nom: string, secours: string): Color3
	local valeur = Charte[nom]
	return if typeof(valeur) == "Color3" then valeur else Color3.fromHex(secours)
end

local MAISON = Vector3.new(0, 7, 0)
local PLATEAU = Vector3.new(300, 0, 0)

local PRESETS = {
	V1_Colosse = { heure = 17.5, cam = Vector3.new(-40, 6, 48), cible = Vector3.new(-4, 14, -10), fov = 40, sat = 0.3, bloom = 0.6 },
	V2_Horde = { heure = 14, cam = Vector3.new(0, 45, 28), cible = Vector3.zero, fov = 50, sat = 0.25, bloom = 0.3 },
	V3_Avant = { heure = 9, cam = Vector3.new(26, 14, 30), cible = MAISON, fov = 45, sat = -0.2, bloom = 0.2 },
	V3_Apres = { heure = 13, cam = Vector3.new(26, 14, 30), cible = MAISON, fov = 45, sat = 0.3, bloom = 0.5 },
	I1_Zbire = { heure = 13, cam = PLATEAU + Vector3.new(0, 4, 9), cible = PLATEAU + Vector3.new(0, 3, 0), fov = 30, sat = 0.3, bloom = 0.2, flou = true },
	I2_Maison = { heure = 13, cam = PLATEAU + Vector3.new(18, 26, 18), cible = PLATEAU + MAISON, fov = 35, sat = 0.3, bloom = 0.3 },
}

local function obtenir(classe: string, nom: string): any
	local existant = Lighting:FindFirstChild(nom)
	if existant and existant:IsA(classe) then
		return existant
	end
	local nouveau = Instance.new(classe)
	nouveau.Name = nom
	nouveau.Parent = Lighting
	return nouveau
end

local function afficherGuide(icone: boolean)
	local ancien = StarterGui:FindFirstChild("GuideCadrage")
	if ancien then
		ancien:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "GuideCadrage"
	gui.IgnoreGuiInset = true
	local zone = Instance.new("Frame")
	zone.BackgroundTransparency = 1
	zone.AnchorPoint = Vector2.new(0.5, 0.5)
	if icone then
		zone.Size = UDim2.fromScale(0.8, 0.8) -- 410 px utiles sur 512
		zone.Position = UDim2.fromScale(0.5, 0.5)
		local ratio = Instance.new("UIAspectRatioConstraint")
		ratio.AspectRatio = 1
		ratio.DominantAxis = Enum.DominantAxis.Height
		ratio.Parent = zone
		local coins = Instance.new("UICorner")
		coins.CornerRadius = UDim.new(0.18, 0)
		coins.Parent = zone
	else
		zone.Size = UDim2.fromScale(0.9, 0.8) -- marges de 5 %, 15 % en bas
		zone.Position = UDim2.fromScale(0.5, 0.45)
	end
	local trait = Instance.new("UIStroke")
	trait.Color = couleur("Alerte", "FF2E63")
	trait.Thickness = 2
	trait.Parent = zone
	zone.Parent = gui
	gui.Parent = StarterGui
end

local function appliquer(nomPreset: string)
	local p = PRESETS[nomPreset]
	assert(p, "Preset inconnu : " .. nomPreset)

	Lighting.ClockTime = p.heure
	Lighting.Brightness = 3
	Lighting.OutdoorAmbient = couleur("NuitLabo", "2A3263"):Lerp(couleur("Creme", "F6E7C1"), 0.6)

	local correction = obtenir("ColorCorrectionEffect", "VignetteCouleur")
	correction.Saturation = p.sat
	correction.Contrast = 0.12
	correction.TintColor = Color3.new(1, 1, 1):Lerp(couleur("Creme", "F6E7C1"), 0.2)

	local bloom = obtenir("BloomEffect", "VignetteBloom")
	bloom.Intensity = p.bloom
	bloom.Size = 24
	bloom.Threshold = 0.9

	local flou = obtenir("DepthOfFieldEffect", "VignetteFlou")
	flou.Enabled = p.flou == true
	flou.FocusDistance = (p.cam - p.cible).Magnitude
	flou.InFocusRadius = 6
	flou.NearIntensity = 0
	flou.FarIntensity = 0.5

	local camera = Workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = p.fov
	camera.CFrame = CFrame.lookAt(p.cam, p.cible)

	afficherGuide(string.sub(nomPreset, 1, 1) == "I")
end

appliquer("V1_Colosse") -- avant la capture : StarterGui.GuideCadrage:Destroy()
```

- **Particules :** lancer la simulation (F8, Exécuter), puis passer `ParticleEmitter.TimeScale` à 0 pour figer l'éclat des cubes et des pièces.
- **Caméras :** les valeurs ci-dessus sont un point de départ. Elles s'ajustent de ±5 studs une fois connue l'échelle finale du Colosse.
