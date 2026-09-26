## 1. Cadre mobile

- **Orientation :** paysage imposé dans les deux places, `StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor` (retournement à 180° permis, portrait jamais).
- **Viewport de référence :** 800 × 360 pt (Android d'entrée de gamme 20:9), vérifié aussi à 667 × 375 (le plus étroit).
- **Zones sûres :** tout `ScreenGui` interactif a `ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets` et `ResetOnSpawn = false`.
- **Échelle :** `UIScale` = clamp(min(viewport) / 390 ; 1 ; 1,4). Jamais sous 1 : les 60 px du canon restent un plancher.
- **Saut :** désactivé sur la Prairie (`StarterPlayer.CharacterUseJumpPower = true`, `CharacterJumpPower = 0`), ce qui masque le bouton de saut Roblox et libère le coin du pouce droit. Conservé au Laboratoire. *Ajout au canon, soumis à Victor Lanoue.*

## 2. Checklist mobile

| # | Règle | Valeur |
|---|---|---|
| 1 | Taille visuelle d'un bouton | 64 px (canon : 60 minimum), action principale 96 px |
| 2 | Zone de touch | visuel + 6 px par côté (76 et 108 px) |
| 3 | Écart entre visuels | ≥ 12 px ; zones de touch jointives, jamais superposées |
| 4 | Marge aux bords | 24 px dans la zone sûre |
| 5 | Texte | ≥ 16 px, chiffres clés 24 px, `UIStroke` Encre 2 px |
| 6 | Haut de l'écran | lecture seule, sauf Paramètres |
| 7 | Zone du joystick | 40 % gauche × 60 % bas : aucun bouton |
| 8 | Retour d'appui | écrasement × 0,8, retour élastique en 0,15 s, bip 8-bit < 80 ms |
| 9 | Action de combat | 1 tap, 2 au maximum |
| 10 | Information | jamais par la couleur seule : icône + couleur |

## 3. Carte des pouces : HUD de la Prairie

Pouce gauche : joystick dynamique Roblox, rien d'autre. Pouce droit : la **Grappe**, un arc d'actions autour du coin bas-droit. Haut : informations.

| Élément | Ancrage (800 × 360) | Taille | Interaction |
|---|---|---|---|
| PV de la Maison, « Jour X », minuteur horde / Répit | `AnchorPoint (0.5, 0)`, `UDim2.new(0.5, 0, 0, 8)` | 280 × 40 | aucune |
| Pièces (Or) puis Gemmes (cyan) | `AnchorPoint (1, 0)`, `UDim2.new(1, -84, 0, 8)` | 2 × 110 × 40 | aucune |
| Paramètres | `UDim2.new(1, -12, 0, 8)` | 60 × 60 | tap |
| **Réparer** (principal) | Grappe, centre à 72 px du coin | 96 | maintenir |
| Muret, Mini-Tourelle, Tapis Collant | arc de 150 px à 180°, 210°, 240° | 64 | tap, compteur « 2/3 » |
| Roue des Pings | arc à 270° | 64 | tap, ou maintenir + glisser |
| Flèches hors écran (Colosse, Maison, cible) | bord de la zone sûre | 40 | aucune (`Active = false`) |

Réparer est grisé au-delà de 14 studs du centre de la Maison, avec une flèche vers elle. Les Pièces se ramassent au contact. Paramètres propose « Taille des boutons : 100 / 115 / 130 % ».

## 4. Gestes

| Geste | Usage |
|---|---|
| Tap | combat : à `InputBegan` ; menus : `Activated`, annulable en glissant hors du bouton |
| Maintenir | Réparer (le serveur répare par tranches de 0,5 s), Roue des Pings |
| Glisser | joystick, Roue des Pings, Arbre des Recherches ; jamais depuis un bord |
| Tap sur un Zbire | verrou de cible 3 s, tolérance de 48 px |
| Interdits | pincer, double tap, deux doigts, glisser la caméra (`Scriptable`), secouer |

**Pose d'une défense en 2 taps, sans glisser-déposer.** 1er tap : un fantôme translucide apparaît 6 studs devant le Survivant, calé sur la grille de 1 stud, crème s'il est valide, rose-rouge sinon. Le Muret s'oriente seul, tangent à la Maison, et le fantôme suit le Survivant. 2e tap sur le même bouton, devenu une coche : `DemandePose`. Annulé après 4 s d'inaction.

**Roue des Pings sans visée.** Le tap ouvre 4 secteurs de 84 px, orientés vers le centre de l'écran. « Ici ! » marque la position du Survivant, « Répare ! » la Maison, « Colosse ! » le Colosse ; « Merci ! » s'affiche au-dessus de la tête. Serveur : 1 ping toutes les 2 s par joueur.

## 5. Adaptation des écrans

- **Laboratoire :** `ProximityPrompt` en `Style = Custom` (bouton 72 px, `HoldDuration = 0`, `MaxActivationDistance = 10`), `ProximityPromptService.MaxPromptsVisible = 1`, 8 studs minimum entre deux prompts.
- **Quai des Capsules :** une fois assis, « Départ dans 15 s » et bouton « Descendre » 200 × 64 en bas au centre.
- **Arbre des Recherches :** plein écran ; fermeture en haut à droite (60 px) et « Retour » 200 × 64 en bas à gauche. Cartes 150 × 200 dans un `ScrollingFrame` horizontal (`ScrollingDirection = X`). Dépense de Gemmes en 2 taps : « Confirmer ? » et le prix pendant 3 s.
- **Galerie des Zbires :** tap sur une figurine = fiche, compteur « 37/100 » vers la variante suivante.
- **Établi :** panneau droit de 52 % qui remplace la Grappe, joystick actif. 8 tuiles de 88 × 88 (4 × 2) ; 1 tap = 1 achat en Pièces, anti double tap 0,3 s. Fermeture automatique à 12 studs.
- **Étourdi (2 s) :** boutons grisés avec décompte circulaire ; la Roue des Pings reste active.
- **Colosse :** bandeau « Colosse ! » 1,5 s et flèche au bord. Aucune fenêtre modale en combat.
- **Fin de run :** Gemmes gagnées, « Record : Jour X », « Retour au Laboratoire » 280 × 72 en bas au centre. Taps ignorés 0,8 s : les joueurs martèlent encore la Grappe quand la Maison tombe.
- **Défi du Jour, Zbire de la Semaine :** panneau au Laboratoire, jamais de fenêtre à la connexion.

## 6. Caméra et tir automatique

Avec le décalage (0, 45, 28) et `FieldOfView` 50 (vertical), la caméra est à 53 studs, inclinée à 58°. En 16:9, on voit environ 41 studs devant le Survivant, 22 derrière et 44 de chaque côté (55 en 20:9). Le tir automatique porte à 40 studs : un Zbire en bas de l'écran ou sous la Grappe peut être visé sans être vu.

Règle : le client propose d'abord le Zbire **visible hors de la Grappe** le plus proche ; le serveur revalide existence, distance ≤ 40 et cadence. La cible porte un anneau crème (`BillboardGui` 48 px, `AlwaysOnTop`), ou une flèche au bord si elle est hors écran.

## 7. Code Luau

```lua
-- StarterPlayerScripts/DispositionTactile (ModuleScript) : la Grappe du pouce droit
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charte = require(ReplicatedStorage.Charte) -- noms de champs à aligner sur la Charte

local TAILLE_MIN, PRINCIPAL, SECONDAIRE = 60, 96, 64
local MARGE_TOUCH, RAYON, COTE = 6, 150, 270
local EMPLACEMENTS = { Muret = 180, MiniTourelle = 210, TapisCollant = 240, Ping = 270 }
local camera = workspace.CurrentCamera

local function creerBouton(parent: GuiObject, nom: string, taille: number, centre: Vector2, image: string)
	assert(taille >= TAILLE_MIN, "Bouton sous 60 px : " .. nom)
	local zone = Instance.new("ImageButton") -- zone de touch invisible, plus large que le visuel
	zone.Name = nom
	zone.AnchorPoint = Vector2.new(0.5, 0.5)
	zone.Position = UDim2.fromOffset(centre.X, centre.Y)
	zone.Size = UDim2.fromOffset(taille + 2 * MARGE_TOUCH, taille + 2 * MARGE_TOUCH)
	zone.BackgroundTransparency, zone.ImageTransparency, zone.AutoButtonColor = 1, 1, false
	zone.Parent = parent

	local visuel = Instance.new("ImageLabel")
	visuel.AnchorPoint = Vector2.new(0.5, 0.5)
	visuel.Position = UDim2.fromScale(0.5, 0.5)
	visuel.Size = UDim2.fromOffset(taille, taille)
	visuel.BackgroundColor3, visuel.Image = Charte.Creme, image
	visuel.Parent = zone
	Instance.new("UICorner", visuel).CornerRadius = UDim.new(0, 12)
	local contour = Instance.new("UIStroke")
	contour.Thickness, contour.Color = 3, Charte.Encre
	contour.Parent = visuel
	return zone
end

local DispositionTactile = {}

function DispositionTactile.construire(images: { [string]: string }): Frame
	local gui = Instance.new("ScreenGui")
	gui.Name = "HUDTactile"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local grappe = Instance.new("Frame")
	grappe.Name = "Grappe"
	grappe.AnchorPoint = Vector2.new(1, 1)
	grappe.Position = UDim2.new(1, -24, 1, -24)
	grappe.Size = UDim2.fromOffset(COTE, COTE)
	grappe.BackgroundTransparency = 1
	grappe.Parent = gui
	local echelle = Instance.new("UIScale")
	echelle.Parent = grappe

	local centre = Vector2.new(COTE - PRINCIPAL / 2, COTE - PRINCIPAL / 2)
	creerBouton(grappe, "Reparer", PRINCIPAL, centre, images.Reparer)
	for nom, angle in EMPLACEMENTS do
		local a = math.rad(angle)
		creerBouton(grappe, nom, SECONDAIRE, centre + Vector2.new(math.cos(a), math.sin(a)) * RAYON, images[nom])
	end

	local function ajuster()
		local vp = camera.ViewportSize
		echelle.Scale = math.clamp(math.min(vp.X, vp.Y) / 390, 1, 1.4) -- jamais sous 1
	end
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(ajuster)
	ajuster()
	return grappe
end

return DispositionTactile
```

```lua
-- LocalScript AutoTir (extrait) : le client propose une cible, le serveur décide
local camera = workspace.CurrentCamera
local PORTEE = 40

local function sousLaGrappe(ecran: Vector3, grappe: GuiObject): boolean
	local vp = camera.ViewportSize
	local zone = grappe.AbsoluteSize + Vector2.new(40, 40) -- marge + zone sûre
	return ecran.X > vp.X - zone.X and ecran.Y > vp.Y - zone.Y
end

local function choisirCible(racine: BasePart, grappe: GuiObject, verrou: Model?): Model?
	if verrou and verrou.Parent and (verrou:GetPivot().Position - racine.Position).Magnitude <= PORTEE then
		return verrou
	end
	local meilleure, meilleurScore = nil, math.huge
	for _, zbire in workspace.Zbires:GetChildren() do
		local position = zbire:GetPivot().Position
		local distance = (position - racine.Position).Magnitude
		if distance <= PORTEE then
			local ecran, visible = camera:WorldToViewportPoint(position)
			local score = if visible and not sousLaGrappe(ecran, grappe) then distance else distance + 1000
			if score < meilleurScore then
				meilleure, meilleurScore = zbire, score
			end
		end
	end
	return meilleure -- puis DemandeTir:FireServer(meilleure:GetAttribute("Id")) à la cadence du Blaster
end
```

La Grappe s'active quand `UserInputService.LastInputTypeChanged` renvoie `Touch` et se masque au clavier ou à la souris (PC tactiles).

## 8. Pièges à éviter

- **Bouton sous la barre Roblox ou dans l'encoche :** `CoreUISafeInsets`, jamais `IgnoreGuiInset` sur un bouton.
- **Bouton dans la zone du joystick :** le Survivant se fige dès qu'on le frôle.
- **Écran qui surgit sous le pouce :** verrou de 0,8 s, bouton hors de la Grappe.
- **Glisser-déposer des défenses :** conflit avec le joystick, doigt qui masque la pose.
- **`TextScaled` sans borne :** textes de 6 px sur iPhone SE ; `UITextSizeConstraint` (`MinTextSize` 16, `MaxTextSize` 32).
- **Info-bulles au survol (`MouseEnter`) :** inexistantes au doigt ; afficher l'info ou appui long de 0,4 s.
- **Gestes depuis les bords :** retour Android, accueil iOS ; rien à moins de 24 px.
- **`TextBox` :** le clavier couvre la moitié de l'écran ; aucun champ de saisie.
- **HUD recalculé à chaque image :** compteurs mis à jour sur changement, 80 `GuiObject` visibles au maximum, chiffres de dégâts réservés au joueur (pool de 20 `BillboardGui`).
- **Consignes par le chat :** beaucoup de 9-12 ans n'y ont pas accès ; Doc Boulon montre le geste avec une main animée.

## 9. Tests multi-écrans

| Appareil | Viewport paysage | Points critiques |
|---|---|---|
| Android 3 Go (réel, référence) | ≈ 800 × 360 | 30 FPS, 6 joueurs, 60 Zbires, < 800 Mo |
| iPhone SE | 667 × 375 | Grappe et compteurs sans chevauchement |
| iPhone à encoche | 844 × 390 | zones sûres dans les 2 sens de rotation |
| Android 20:9 grand format | 915 × 412 | échelle 1,06, flèches aux bords |
| iPad 10,2 pouces | 1080 × 810 | échelle 1,4, rien d'étiré |
| PC 1920 × 1080 | — | Grappe masquée, raccourcis clavier |

**Protocole :** émulateur de Studio (appareils personnalisés 800 × 360 et 915 × 412), 20 taps par bouton en marchant (19 réussis minimum), chaque défense posée, chaque ping envoyé, une run de 12 min sans tap involontaire. Puis 5 testeurs de 9 à 13 ans sur téléphone, en session encadrée avec accord parental : moins de 5 % de taps manqués.
