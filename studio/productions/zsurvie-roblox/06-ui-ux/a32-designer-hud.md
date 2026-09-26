## 1. Règles de composition

- **En haut on lit, en bas à droite on agit.** Sur tactile, seuls le groupe `BasDroite` et la Roue des Pings réagissent au toucher.
- **4 blocs permanents au maximum :** le Bandeau Maison, les Pièces, les têtes des Survivants et les boutons d'action. Le reste est contextuel ou replié.
- **Référence 1280 × 720, paysage forcé** (`StarterGui.ScreenOrientation = LandscapeSensor`). Chaque groupe ancré porte un `UIScale` tagué `HudScale`, réglé à `clamp(min(X/1280, Y/720), 0.6, 1.25)`. Un bouton de 100 réf. mesure donc toujours au moins 60 px.
- **ScreenGui `HUD` :** `ResetOnSpawn = false`, `IgnoreGuiInset = false`, `ScreenInsets = CoreUISafeInsets` (encoche et barre Roblox), `ZIndexBehavior = Sibling`, `DisplayOrder = 10`. Les CoreGui `Backpack`, `Health`, `PlayerList` et `EmotesMenu` sont désactivés pendant la run.
- **Zones interdites :** le coin bas-gauche sur 45 % × 55 % (joystick) et le centre, où se trouve le Survivant. Seules les annonces de 2,5 s y passent.
- **Saut :** hypothèse `JumpPower = 0`. Le bouton de saut natif se masque et libère le coin bas-droit.
- **Style Pixel-bloc :** panneaux Encre #1E1B2E en transparence 0,25, angles droits, `UIStroke` Encre 3 px, ombre décalée de (4, 4). Police `Enum.Font.FredokaOne` (`Arcade` réservée aux annonces). Texte Crème avec `UIStroke` 2 px. Libellés en 26 réf. (≈ 16 px sur téléphone), chiffres en 34 réf. (≈ 20 px).
- Le « Record : Jour X » reste un `BillboardGui` au-dessus de la Maison, comme le prévoit le canon. Le HUD ne le répète pas.

## 2. Maquette (téléphone en paysage)

```
┌────────────────────────────────────────────────────────────────┐
│[◎ 1 240]         [JOUR 7 ▓▓▓▓▓▓▓▓░░░ 0:42]         [☺☺☺☺☺☺] │
│[◆ +18]             [ COLOSSE ▓▓▓▓▓▓▓▓ ]                        │
│[☀][✦]                                                          │
│◄×9                   « JOUR 8 ! »                        ×4►  │
│                       (Survivant)                              │
│                                                        [PING]  │
│ (joystick)      ▼×3   [Tapis][Tour.][Muret][POSER 2/3][RÉPARE] │
└────────────────────────────────────────────────────────────────┘
```

## 3. Priorités d'information

| Rang | Information | Visibilité | Signal |
|---|---|---|---|
| 1 | PV de la Maison | Permanent | À 25 % ou moins : barre Alerte #FF2E63 qui pulse (0,5 s) et bip 8-bit |
| 2 | Colosse | Annonce 5 s avant, puis barre tant qu'il vit | Violet horde, flèche Alerte |
| 3 | Étourdi 2 s | Contextuel | Boutons grisés en Ardoise |
| 4 | Répare, Poser, Ping | Permanent (tactile) | Répare brille quand la Maison est abîmée |
| 5 | Jour et minuteur | Permanent | Crème pendant la horde, Prairie #6CC24A pendant le Répit |
| 6 | Pièces | Permanent | Or #FFC933, rebond à chaque gain |
| 7 | Zbires hors champ | Contextuel | Flèches de bord |
| 8 | Coéquipiers | Replié (têtes seules) | Tête grisée si étourdi, clignote quand il envoie un ping |
| 9 | Gemmes de la run | Pendant le Répit uniquement | Cyan #33D6F0 |
| 10 | Défi du Jour | Replié (2 icônes) | Texte en annonce au départ |

## 4. Placement

### Groupes ancrés

| Groupe | AnchorPoint | Position | Size | Adaptation |
|---|---|---|---|---|
| `HautGauche` | (0, 0) | `UDim2.new(0, 12, 0, 8)` | 220 × 170 | `UIScale` |
| `HautCentre` | (0.5, 0) | `UDim2.new(0.5, 0, 0, 8)` | 440 × 112 | `UIScale` |
| `HautDroite` | (1, 0) | `UDim2.new(1, -12, 0, 8)` | 270 × 40 | `UIScale` |
| `BasDroite` | (1, 1) | `UDim2.new(1, -16, 1, -16)` | 600 × 240 | `UIScale` |
| `AideClavier` (PC) | (0.5, 1) | `UDim2.new(0.5, 0, 1, -12)` | 560 × 36 | `UIScale` |
| `Annonces` | (0.5, 0.5) | `UDim2.fromScale(0.5, 0.28)` | `fromScale(0.6, 0.14)` | `UIAspectRatioConstraint` 5, `UITextSizeConstraint` 20–64 |
| `RouePings` | (0.5, 0.5) | `UDim2.fromScale(0.5, 0.5)` | `fromScale(0.55, 0.55)` | `UIAspectRatioConstraint` 1, `DominantAxis = Height` |
| `Indicateurs` | (0, 0) | `UDim2.fromScale(0, 0)` | `fromScale(1, 1)` | tailles en scale |

### Éléments (position dans leur groupe, taille de référence)

| Élément | AnchorPoint | Position | Taille | État |
|---|---|---|---|---|
| `Bandeau` | (0.5, 0) | `UDim2.new(0.5, 0, 0, 0)` | 440 × 64 | Permanent |
| · `Jour` | (0, 0.5) | `UDim2.new(0, 12, 0.5, 0)` | 100 × 40 | « JOUR 7 » |
| · `BarreMaison` | (0.5, 0.5) | `UDim2.fromScale(0.5, 0.5)` | 200 × 28 | Fond Ardoise, remplissage Toit orange #EF7A2F, crans tous les 25 % |
| · `Phase` | (1, 0.5) | `UDim2.new(1, -12, 0.5, 0)` | 100 × 40 | « 0:42 » ou « RÉPIT 12 » |
| `BarreColosse` | (0.5, 0) | `UDim2.new(0.5, 0, 0, 76)` | 360 × 28 | Contextuel |
| `Pieces` | (0, 0) | `UDim2.fromOffset(0, 0)` | 200 × 56 | Permanent |
| `GemmesRun` | (0, 0) | `UDim2.fromOffset(0, 64)` | 160 × 44 | Répit |
| `DefiDuJour` | (0, 0) | `UDim2.fromOffset(0, 116)` | 2 × 44 × 44 | Lecture seule |
| `Survivants` | (1, 0) | `UDim2.fromScale(1, 0)` | 6 têtes de 40 × 40, `UIListLayout` horizontal | Déplié sur PC avec Tab (une ligne de 220 × 44 par joueur) |
| `Repare` | (1, 1) | `UDim2.fromScale(1, 1)` | 120 × 120 | Permanent |
| `Poser` | (1, 1) | `UDim2.new(1, -136, 1, 0)` | 100 × 100 | Badge « 2/3 » |
| `ChoixDefense` | (1, 1) | `UDim2.new(1, -252, 1, 0)` | 332 × 100, `Padding` 16 | Replié : Muret, Mini-Tourelle, Tapis Collant |
| `Ping` | (1, 1) | `UDim2.new(1, 0, 1, -136)` | 100 × 100 | Permanent |
| Bulles de la Roue | (0.5, 0.5) | (0.5, 0.17), (0.17, 0.5), (0.5, 0.83), (0.83, 0.5) | `fromScale(0.33, 0.33)` | « Colosse ! », « Répare ! », « Ici ! », « Merci ! » ; fermeture après 3 s |

**Flèches de bord :** un pool de 8 `ImageLabel`, un par secteur de 45° non vide, plus une flèche pour le Colosse, une pour la Maison et une pour l'Établi.
- **Taille :** `fromScale(0, 0.1)` avec `UIAspectRatioConstraint` 1 et `DominantAxis = Height`.
- **Position :** sur une ellipse `fromScale(0.5 + 0.44·cos θ, 0.45 + 0.33·sin θ)`, avec `Rotation = θ` et une pastille « ×N ».
- **Couleurs :** Violet horde par défaut, Or si le secteur contient un Doré, Alerte pour le Colosse.
- **Comportement :** `Active = false` (aucun toucher capté), rafraîchies à 10 Hz.

## 5. Petits écrans

| Appareil (zone utile) | Échelle | Bouton de 100 réf. |
|---|---|---|
| Android d'entrée de gamme, 740 × 360 | 0,6 (plancher) | 60 px |
| iPhone, 844 × 390 | 0,6 | 60 px |
| iPad, 1024 × 768 | 0,8 | 80 px |
| PC, 1920 × 1080 | 1,25 (plafond) | 125 px |

Sur un écran de 740 px, les boutons d'action ouverts occupent 366 px à droite et le joystick 333 px à gauche : il reste 41 px de marge. Aucun `CanvasGroup`, trop gourmand en mémoire sur un appareil de 3 Go.

## 6. `HudController` (LocalScript)

```lua
-- StarterPlayer.StarterPlayerScripts.HudController (place Prairie)
-- Le HUD lit les attributs écrits par le serveur et n'envoie que des demandes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
for _, nom in { "DemandeReparation", "DemandePose", "DemandePing" } do
	Remotes:WaitForChild(nom)
end
local joueur = Players.LocalPlayer
local hud = joueur:WaitForChild("PlayerGui"):WaitForChild("HUD") :: ScreenGui
local etatRun = ReplicatedStorage:WaitForChild("EtatRun")
local maison = workspace:WaitForChild("Maison")
local camera = workspace.CurrentCamera

local function trouver(chemin: string): any
	local objet: Instance = hud
	for nom in string.gmatch(chemin, "[^%.]+") do
		objet = objet:WaitForChild(nom)
	end
	return objet
end

for _, t in { Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.EmotesMenu } do
	StarterGui:SetCoreGuiEnabled(t, false)
end

-- Échelle : plancher 0,6 → 60 px pour un bouton de 100 réf.
local function majEchelle()
	local vue = camera.ViewportSize
	local e = math.clamp(math.min(vue.X / 1280, vue.Y / 720), 0.6, 1.25)
	for _, s in CollectionService:GetTagged("HudScale") do
		if s:IsA("UIScale") and s:IsDescendantOf(hud) then s.Scale = e end
	end
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(majEchelle)
majEchelle()

local function rebond(objet: Instance) -- étirement × 1,2 puis retour en 0,15 s
	local s = objet:FindFirstChild("Rebond")
	if s and s:IsA("UIScale") then
		s.Scale = 1.2
		TweenService:Create(s, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
end

-- Bandeau Maison
local remplissage = trouver("HautCentre.Bandeau.BarreMaison.Remplissage")
local texteJour = trouver("HautCentre.Bandeau.Jour")
local textePhase = trouver("HautCentre.Bandeau.Phase")

local function majMaison()
	local ratio = math.clamp((maison:GetAttribute("PV") or 0) / math.max(maison:GetAttribute("PVMax") or 1, 1), 0, 1)
	TweenService:Create(remplissage, TweenInfo.new(0.15), { Size = UDim2.fromScale(ratio, 1) }):Play()
	remplissage.BackgroundColor3 = if ratio <= 0.25 then Charte.Alerte else Charte.ToitOrange
end
maison:GetAttributeChangedSignal("PV"):Connect(majMaison)
maison:GetAttributeChangedSignal("PVMax"):Connect(majMaison)
majMaison()

local function majJour()
	texteJour.Text = `JOUR {etatRun:GetAttribute("Jour") or 1}`
	rebond(texteJour)
end
etatRun:GetAttributeChangedSignal("Jour"):Connect(majJour)
majJour()

local cadreGemmes = trouver("HautGauche.GemmesRun")
task.spawn(function()
	while hud.Parent do
		local reste = math.max(0, math.ceil((etatRun:GetAttribute("FinPhase") or 0) - workspace:GetServerTimeNow()))
		local repit = etatRun:GetAttribute("Phase") == "Repit"
		textePhase.Text = if repit then `RÉPIT {reste}` else string.format("%d:%02d", reste // 60, reste % 60)
		textePhase.TextColor3 = if repit then Charte.Prairie
			elseif etatRun:GetAttribute("ColosseActif") then Charte.Alerte
			else Charte.Creme
		cadreGemmes.Visible = repit
		task.wait(0.25)
	end
end)

-- Pièces : affichage seul, le serveur décide du montant
local valeurPieces = trouver("HautGauche.Pieces.Valeur")
joueur:GetAttributeChangedSignal("Pieces"):Connect(function()
	valeurPieces.Text = tostring(joueur:GetAttribute("Pieces") or 0)
	rebond(valeurPieces)
end)

-- Actions : boutons sur tactile, E / 1-2-3 / Q sur PC
local basDroite = trouver("BasDroite")
local choix = trouver("BasDroite.ChoixDefense")
local roue = trouver("RouePings")

local function lier(nom: string, bouton: GuiButton, touche: Enum.KeyCode, action: () -> ())
	bouton.Activated:Connect(action)
	ContextActionService:BindAction(nom, function(_, etat)
		if etat == Enum.UserInputState.Begin then action() end
		return Enum.ContextActionResult.Sink
	end, false, touche)
end

lier("Reparer", trouver("BasDroite.Repare"), Enum.KeyCode.E, function()
	Remotes.DemandeReparation:FireServer() -- distance et cadence vérifiées par le serveur
end)
trouver("BasDroite.Poser").Activated:Connect(function() choix.Visible = not choix.Visible end)
local touches = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three }
for i, nom in { "Muret", "MiniTourelle", "TapisCollant" } do
	lier("Poser" .. nom, choix:WaitForChild(nom), touches[i], function()
		Remotes.DemandePose:FireServer(nom) -- emplacement et plafond de 3 validés par le serveur
		choix.Visible = false
	end)
end
lier("Pings", trouver("BasDroite.Ping"), Enum.KeyCode.Q, function() roue.Visible = not roue.Visible end)
for _, bulle in roue:GetChildren() do
	if bulle:IsA("GuiButton") then
		bulle.Activated:Connect(function()
			Remotes.DemandePing:FireServer(bulle.Name) -- "Colosse" | "Repare" | "Ici" | "Merci"
			roue.Visible = false
		end)
	end
end

joueur:GetAttributeChangedSignal("DefensesPosees"):Connect(function()
	trouver("BasDroite.Poser.Badge").Text = `{joueur:GetAttribute("DefensesPosees") or 0}/3`
end)

local tactile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
basDroite.Visible = tactile
trouver("AideClavier").Visible = not tactile

-- Étourdi : boutons grisés jusqu'à l'heure fixée par le serveur
local function griser(gris: boolean)
	for _, b in basDroite:GetDescendants() do
		if b:IsA("ImageButton") then
			b.ImageColor3 = if gris then Charte.Ardoise else Color3.new(1, 1, 1) -- teinte neutre
		end
	end
end
joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
	local reste = (joueur:GetAttribute("EtourdiJusqua") or 0) - workspace:GetServerTimeNow()
	if reste <= 0 then return end
	griser(true)
	task.delay(reste, function()
		if workspace:GetServerTimeNow() >= (joueur:GetAttribute("EtourdiJusqua") or 0) then griser(false) end
	end)
end)
```

## 7. HUD du Laboratoire (`HUDLabo`)

- **Gemmes :** en haut à gauche (`UDim2.new(0, 12, 0, 8)`), en Cyan. En dessous, la jauge de la Foreuse : « Foreuse 5 h 12 / 8 h ».
- **Capsule :** au centre en haut (`AnchorPoint (0.5, 0)`), 360 × 64, « Départ dans 12 · 4/6 ». Le bouton « Descendre » (160 × 100) est ancré en bas à droite.
- **Défi du Jour / Zbire de la Semaine :** bouton de 100 × 100 à `UDim2.new(1, -16, 1, -16)`, avec la pastille « ! » quand il est disponible.
