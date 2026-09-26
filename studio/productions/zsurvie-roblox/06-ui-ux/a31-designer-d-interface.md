## 1. Principes

- **Pixel-bloc** : grille de 4 px, petits arrondis, contour Encre épais et socle 3D sous chaque bouton, comme les cubes du décor.
- **Code couleur du canon** : orange et crème = à nous, or = pièces, cyan = gemmes, violet = Zbires, rose-rouge = danger. Ajout : vert Prairie = réussite.
- **Jamais la couleur seule** (daltonisme) : toujours une icône ou un mot. **Ni noir ni blanc purs** : Crème et Encre les remplacent.
- **Le serveur décide** : les compteurs ne lisent que les attributs `Pieces` et `Gemmes` posés par le serveur sur le `Player`. Un bouton d'achat attend la réponse du serveur.

## 2. Couleurs de l'interface

Ombre = base × 0,8 ; lumière = `base:Lerp(Creme, 0.2)`.

| Jeton | Base | Ombre | Lumière | Usage |
|---|---|---|---|---|
| Principal | #EF7A2F | #BF6226 | #F0904C | Bouton principal, PV de la Maison |
| Secondaire | #4A4560 | #3B374D | #6C6573 | Bouton secondaire, onglet inactif, verrouillé |
| Panneau | #F6E7C1 | #C5B99A | #F6E7C1 | Fond des panneaux de run, texte clair |
| PanneauLabo | #2A3263 | #22284F | #535676 | Fond des panneaux du Laboratoire |
| Contour | #1E1B2E | #181625 | #49444B | Contours, texte sur fond clair, pastilles HUD (transparence 0,2) |
| Pieces | #FFC933 | #CCA129 | #FDCF4F | Montants en pièces |
| Gemmes | #33D6F0 | #29ABC0 | #5AD9E7 | Montants en gemmes, contour des panneaux Labo |
| Ennemi | #9B5DE5 | #7C4AB7 | #AD79DE | Barre du Colosse, phase de horde |
| Danger | #FF2E63 | #CC254F | #FD5376 | Alertes, Maison sous 30 %, solde insuffisant |
| Succes | #6CC24A | #569B3B | #88C962 | Achat confirmé, Répit, « Merci ! » |

Contrastes : Encre sur Crème 13,7:1, sur Prairie 7,5:1, sur orange 6:1. Crème sur orange plafonne à 2,3:1 : tout libellé Crème posé sur une couleur porte un contour de texte Encre de 2 px.

## 3. Typographie

| Rôle | `Enum.Font` | `TextSize` | Usage |
|---|---|---|---|
| Affiche | `LuckiestGuy` | 40 | « JOUR 7 », « LE COLOSSE ARRIVE ! » (contour Encre 3 px) |
| Titre | `LuckiestGuy` | 28 | Bandeaux de panneaux |
| Bouton | `FredokaOne` | 22 / 18 | Principal / secondaire et onglets |
| Chiffres | `Arcade` | 16, 24, 32 | Pièces, gemmes, chronos |
| Corps | `BuilderSansBold` | 16 | Descriptions, notifications |
| Légende | `BuilderSansBold` | 14 | Niveaux, légendes d'icônes |

- `Arcade` est une police bitmap : multiples de 8 uniquement, sinon elle devient floue.
- Plancher 14 px. `TextScaled` seulement avec `UITextSizeConstraint` (`MinTextSize` 14).
- 2 mots par bouton, 10 par notification : beaucoup de 9 ans lisent encore lentement.

## 4. Grille, échelle et zones mobiles

- **Référence 780 × 360 px en paysage** (`StarterGui.ScreenOrientation = LandscapeSensor`). Toutes les valeurs sont à l'échelle 1.
- **Échelle** : chaque zone (enfant direct d'un `ScreenGui`, `AnchorPoint` sur son coin) porte un `UIScale` = `math.clamp(ViewportSize.Y / 360, 1, 1.5)`, recalculé sur `ViewportSize`.
- **Espacements** : 4 / 8 / 12 / 16 / 24 px ; marge d'écran 16 px.
- **Cibles** : 60 × 60 px minimum, 72 × 72 pour les actions de run, 16 px entre deux cibles.
- **Zones interdites** : 220 × 180 px en bas à gauche (joystick), 110 × 110 px en bas à droite (saut).
- `ScreenInsets = CoreUISafeInsets` partout, sauf `Transition` (`None`).
- `UICorner` 4 px (boutons, onglets), 8 px (panneaux) ; `UIStroke` Encre 2 px (boutons), 3 px (panneaux).

## 5. Composants et états

### Bouton principal

`Frame` « Socle » (Ombre, `UIStroke` Border) contenant un `TextButton` « Face » (Base, `AutoButtonColor = false`, 6 px moins haute, libellé avec `UIStroke` Contextual). 200 × 60 dans un panneau ; 72 × 72 en action HUD (icône 40 px + légende 14 px).

| État | Rendu | Déclencheur |
|---|---|---|
| Repos | Face Base, socle visible sur 6 px | — |
| Survol (PC) | Face Lumière | `MouseEnter` |
| Appuyé | Face descendue de 4 px | `InputBegan` |
| Attente | « … », `TextTransparency` 0,4, appuis ignorés | Demande envoyée |
| Validé | Ressort : hauteur × 0,8, largeur × 1,2, 0,15 s | Serveur : `true` |
| Refusé | Tremblement 4 px sur 0,2 s + notification « Il te manque 35 pièces » | Solde répliqué insuffisant ou serveur : `false` |
| Verrouillé | Face #6C6573, libellé #C5B99A + cadenas | Recherche prérequise absente |

### Bouton secondaire

Mêmes structure et états en Ardoise, 160 × 60, `FredokaOne` 18. Un seul bouton principal par écran. « Fermer » : secondaire 60 × 60, croix Crème, en haut à droite du panneau.

### Panneau

- **Run** : fond Crème, contour Encre 3 px. **Labo** : fond Nuit labo, contour #29ABC0, texte Crème.
- Bandeau de titre de 56 px : Établi orange, Arbre des Recherches cyan, Galerie des Zbires violet, Défi du Jour or.
- `UIPadding` 16 px, `UISizeConstraint.MaxSize` 640 × 320, ombre = `Frame` Encre, transparence 0,5, décalée de (0, 6).
- En run, l'Établi est un **panneau latéral droit de 55 %** : le Survivant reste visible, le tir automatique continue.
- États : Fermé (`Visible = false`) → Ouverture (`UIScale` 0,8 → 1, `Back`, 0,15 s) → Ouvert → Fermeture (0,1 s). Un seul panneau à la fois ; il masque les actions du HUD, jamais la barre de la Maison.

### Onglet

60 px de haut, 96 px de large minimum, `UIListLayout` horizontal (`Padding` 4).

| État | Rendu |
|---|---|
| Inactif | Face Ardoise, libellé Crème |
| Actif | Face couleur du fond, soudée au panneau, libellé Encre (Crème au Labo), trait de 4 px couleur du bandeau |
| Nouveau | Pastille Alerte de 16 px avec « ! » |
| Verrouillé | Ardoise lumière + cadenas ; l'appui affiche le prérequis |

### Notification

Toast 360 × 56 px centré sous les barres du haut ; `UIListLayout` vertical, 3 visibles, les suivantes attendent. Fond Crème, bande gauche de 8 px et icône 40 px à la couleur du type.

| Type | Couleur | Durée | Exemple |
|---|---|---|---|
| Info | Ardoise | 3 s | « Muret posé (2/3) » |
| Butin | Or ou Cyan | 2 s | « +150 gemmes » |
| Succès | Prairie | 3 s | « Cadence niveau 3 ! » |
| Danger | Fond Alerte, texte Crème contouré | 4 s | « La Maison est à 30 % ! » |
| Annonce | Bandeau violet pleine largeur, 72 px, `LuckiestGuy` 40 | 3 s | « LE COLOSSE ARRIVE ! » |

États : Entrée (glissé de 20 px + ressort 0,15 s), Affichée, Sortie (fondu 0,2 s), Fusion (même message en moins de 2 s : « × 3 » au lieu d'un nouveau toast).

## 6. Arborescence des ScreenGui

Tous : `ResetOnSpawn = false`, `ZIndexBehavior = Sibling`. Les composants vivent dans le Package `ReplicatedStorage.Interface`, partagé par les deux places. Le nombre après le nom est le `DisplayOrder`.

```text
StarterGui (place Prairie)
├─ HUD            10   HautGauche : Jour (Arcade 24) + barre horde violette / Répit verte
│                      HautCentre : BarreMaison (orange), BarreColosse (violette)
│                      HautDroite : Pieces, Gemmes, Menu
│                      BasDroite  : Reparer, Poser (Muret, Mini-Tourelle, Tapis Collant, x/3), Ping
├─ RouePings      20   4 quartiers : Colosse ! violet, Répare ! orange, Ici ! crème, Merci ! vert
├─ Panneaux       30   Etabli
├─ Notifications  40   File, Annonce
├─ FinDeRun       50   Jour atteint, gemmes gagnées, Retour au Laboratoire
└─ Transition     100  IgnoreGuiInset, passé à TeleportService:SetTeleportGui

StarterGui (place Laboratoire)
├─ HUD            10   Gemmes, DefiDuJour, Foreuse
├─ Capsule        20   Départ dans 15 s (Arcade 32), places x/6, Descendre
├─ Panneaux       30   ArbreRecherches, Galerie, DefiDuJour
├─ Notifications  40   File
├─ Tutoriel       60   Bulles de Doc Boulon
└─ Transition     100
```

Hors écran : `BillboardGui` « Record : Jour X » sur la Maison (`LuckiestGuy` 28) et `ProximityPrompt` en `Style = Custom`, dessinés au gabarit du bouton secondaire.

## 7. Code

```lua
-- ReplicatedStorage.Charte.Interface (ModuleScript enfant de Charte)
local Palette = require(script.Parent).Palette -- Color3 aux noms du canon, sans accents

local function teintes(base: Color3)
	return table.freeze({
		Base = base,
		Ombre = Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8),
		Lumiere = base:Lerp(Palette.Creme, 0.2),
	})
end

return table.freeze({
	Couleurs = table.freeze({
		Principal = teintes(Palette.ToitOrange), Secondaire = teintes(Palette.Ardoise),
		Panneau = teintes(Palette.Creme), PanneauLabo = teintes(Palette.NuitLabo),
		Pieces = teintes(Palette.Or), Gemmes = teintes(Palette.GemmeCyan),
		Ennemi = teintes(Palette.VioletHorde), Danger = teintes(Palette.Alerte),
		Succes = teintes(Palette.Prairie),
		Contour = Palette.Encre, TexteSurClair = Palette.Encre, TexteSurSombre = Palette.Creme,
	}),
	Polices = table.freeze({
		Affiche = Enum.Font.LuckiestGuy, Titre = Enum.Font.LuckiestGuy, Bouton = Enum.Font.FredokaOne,
		Chiffres = Enum.Font.Arcade, Corps = Enum.Font.BuilderSansBold,
	}),
	Tailles = table.freeze({
		Affiche = 40, Titre = 28, BoutonPrincipal = 22, BoutonSecondaire = 18,
		ChiffresGrands = 24, ChiffresPetits = 16, Corps = 16, Legende = 14,
	}),
	Rayons = table.freeze({ Bouton = UDim.new(0, 4), Panneau = UDim.new(0, 8) }),
	Contours = table.freeze({ Bouton = 2, Panneau = 3, Texte = 2 }),
	Socle = 6,
	CibleMin = 60,
	Ressort = table.freeze({ Duree = 0.15, Ecrasement = 0.8, Etirement = 1.2, EtirementLarge = 1.05 }),
	Reference = Vector2.new(780, 360),
})
```

```lua
-- ReplicatedStorage.Interface.Bouton (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UI = require(ReplicatedStorage.Charte.Interface)

local POSE = UDim2.new(0.5, 0, 1, -UI.Socle)
local APPUYE = UDim2.new(0.5, 0, 1, -2)
local CLICS = { [Enum.UserInputType.Touch] = true, [Enum.UserInputType.MouseButton1] = true }

local Bouton = {}
Bouton.__index = Bouton

local function habiller(objet: GuiObject, mode: Enum.ApplyStrokeMode)
	local coin = Instance.new("UICorner")
	coin.CornerRadius = UI.Rayons.Bouton
	coin.Parent = objet
	local contour = Instance.new("UIStroke")
	contour.Color = UI.Couleurs.Contour
	contour.Thickness = UI.Contours.Bouton
	contour.ApplyStrokeMode = mode
	contour.Parent = objet
end

function Bouton.new(parent: Instance, libelle: string, variante: string, taille: UDim2)
	local self = setmetatable({ libelle = libelle, variante = variante, etat = "Repos" }, Bouton)
	local socle = Instance.new("Frame")
	socle.Name = "Bouton" .. variante
	socle.Size = taille
	habiller(socle, Enum.ApplyStrokeMode.Border)

	local face = Instance.new("TextButton")
	face.Name = "Face"
	face.AutoButtonColor = false
	face.AnchorPoint = Vector2.new(0.5, 1)
	face.Position = POSE
	face.Size = UDim2.new(1, 0, 1, -UI.Socle)
	face.Font = UI.Polices.Bouton
	face.TextSize = if variante == "Principal" then UI.Tailles.BoutonPrincipal else UI.Tailles.BoutonSecondaire
	habiller(face, Enum.ApplyStrokeMode.Contextual)
	face.Parent = socle
	self.socle, self.face = socle, face
	self:definirEtat("Repos")

	face.MouseEnter:Connect(function()
		if self.etat == "Repos" then face.BackgroundColor3 = UI.Couleurs[variante].Lumiere end
	end)
	face.MouseLeave:Connect(function()
		if self.etat == "Repos" then face.BackgroundColor3 = UI.Couleurs[variante].Base end
	end)
	face.InputBegan:Connect(function(entree: InputObject)
		if self.etat == "Repos" and CLICS[entree.UserInputType] then face.Position = APPUYE end
	end)
	face.InputEnded:Connect(function() face.Position = POSE end)
	socle.Parent = parent
	return self
end

function Bouton:definirEtat(etat: string)
	self.etat = etat
	local verrouille = etat == "Verrouille"
	local teinte = if verrouille then UI.Couleurs.Secondaire else UI.Couleurs[self.variante]
	self.face.BackgroundColor3 = if verrouille then teinte.Lumiere else teinte.Base
	self.socle.BackgroundColor3 = teinte.Ombre
	self.face.TextColor3 = if verrouille then UI.Couleurs.Panneau.Ombre else UI.Couleurs.TexteSurSombre
	self.face.TextTransparency = if etat == "Attente" then 0.4 else 0
	self.face.Text = if etat == "Attente" then "…" else self.libelle
end

function Bouton:ressort()
	local a = self.socle.AbsoluteSize
	local etirement = if a.X > a.Y * 2 then UI.Ressort.EtirementLarge else UI.Ressort.Etirement
	local info = TweenInfo.new(UI.Ressort.Duree / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
	TweenService:Create(self.face, info, { Size = UDim2.new(etirement, 0, UI.Ressort.Ecrasement, -UI.Socle) }):Play()
end

function Bouton:refus()
	local info = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 1, true)
	TweenService:Create(self.face, info, { Position = POSE + UDim2.fromOffset(4, 0) }):Play()
end

-- Le client demande ; le serveur vérifie solde, distance, cadence et renvoie (accepte, raison).
-- estAbordable lit un attribut posé par le serveur : il évite un aller-retour, il ne décide rien.
function Bouton:lierDemande(remote: RemoteFunction, estAbordable: () -> boolean, ...: any)
	local arguments = table.pack(...)
	self.face.Activated:Connect(function()
		if self.etat ~= "Repos" then return end
		if not estAbordable() then
			self:refus()
			return
		end
		self:definirEtat("Attente")
		local ok, accepte = pcall(remote.InvokeServer, remote, table.unpack(arguments, 1, arguments.n))
		self:definirEtat("Repos")
		if ok and accepte then self:ressort() else self:refus() end
	end)
end

return Bouton
```

## 8. Écarts et ajouts à valider par Victor Lanoue

- **Écart, ressort** : sur un bouton plus de 2 fois plus large que haut, l'étirement passe de × 1,2 à × 1,05 pour ne pas chevaucher ses voisins.
- **Ajouts au code couleur** : vert Prairie = réussite ; contour cyan des panneaux du Labo, car l'Encre disparaît sur Nuit labo.
