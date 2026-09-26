## 1. Style commun « Pixel-bloc 16 »

- **Grille de 16 × 16 pixels.** Le pictogramme tient dans 14 × 14, sans anti-crénelage ni dégradé.
- **Contour :** 1 pixel Encre #1E1B2E, coins en escalier. Jamais de noir ni de blanc purs.
- **Volume :** la lumière vient d'en haut à gauche (base + 20 % de Crème) et l'ombre est en bas à droite (base × 0,8). Au plus 2 couleurs de la palette, plus l'Encre.
- **Code couleur du canon :** or = Pièces, cyan = Gemmes, violet = Zbires, orange et crème = à nous, Alerte #FF2E63 = danger. L'or et le cyan sont réservés aux icônes qui parlent d'argent.
- **Aucun texte ni chiffre dans l'image :** les quantités et les prix s'affichent dans des `TextLabel`.
- **La silhouette d'abord :** une icône doit rester reconnaissable remplie d'Encre unie. Deux icônes d'un même écran n'ont jamais la même silhouette.
- **La pastille indique la catégorie**, ce qui aide les joueurs daltoniens :

| Pastille | Forme et couleur | Catégorie |
|---|---|---|
| `PastilleAction` | Cercle Crème bordé d'Encre | Boutons |
| `PastilleEtabli` | Carré Toit orange | Améliorations |
| `PastilleRecherche` | Hexagone Nuit labo, liseré cyan | Recherches |
| `PastilleDefense` | Octogone Terre battue | Défenses |
| `PastilleAlerte` | Losange Alerte | Danger |
| `PastillePing` | Bulle Crème à pointe basse | Pings |

Le `BadgeEquipe` (2 têtes dans le coin bas gauche, à partir de 64 px) signale Solidité, Réparation et Régénération, qui profitent à toute l'équipe.

## 2. Tailles de déclinaison

Chaque taille est un **multiple de 16**, pour qu'un pixel de grille couvre un nombre entier de pixels écran. Réglage : `ResampleMode = Enum.ResamplerMode.Pixelated`.

| Taille | Usage |
|---|---|
| **32 px** | Compteurs du HUD, gains flottants, prix. **C'est la taille de validation** |
| 48 px | Pictogramme d'un bouton de 64 px, pings en monde |
| 64 px | Boutons secondaires (le canon impose 60 px au minimum), cartes de l'Établi |
| 96 px | Boutons Réparer, Défenses et Roue des Pings, nœuds de l'Arbre des Recherches |
| 128 px | Déblocages, fin de run |
| 256 px | Portraits de la Galerie des Zbires |

- **Bouton :** pour une pastille de N px, le pictogramme centré mesure N − 16 px.
- **Ping en monde :** `BillboardGui` de `Size` 48 × 48 (offset), `AlwaysOnTop` = true, `LightInfluence` = 0, `MaxDistance` = 150.
- **Livraison :**
  - `ico_atlas_a.png` : 1024 × 1024, 8 × 8 cellules de 128 px ;
  - `ico_atlas_b.png` : 4 × 4 cellules de 256 px, pour le bestiaire.

  Les deux atlas sont agrandis au plus proche voisin et occupent environ 8 Mo de mémoire au total.

## 3. Icônes de l'Atlas A (ordre des cellules)

### Ligne 0 · Monnaies et HUD
- `Piece` : disque or de 12 px avec un cube en relief et un reflet.
- `Gemme` : diamant cyan de 10 × 12, 3 facettes, éclat crème.
- `Jour` : soleil orange à 8 rayons crème.
- `Record` : drapeau orange sur un mât Ardoise, pour « Record : Jour X ».
- `Maison` : façade avec toit orange en triangle et murs crème, pour la barre de PV.
- `MaisonFissuree` : la même façade fissurée en zigzag, sous 33 % de PV.
- `Repit` : sablier crème au sable Terre battue, pour le chrono de 15 s.
- `Horde` : tête de Marcheur violette, pour les Zbires restants.

### Ligne 1 · Survivant et défenses
- `Blaster` : blaster blocky de profil, réservoir orange. Il clignote quand le tir auto trouve une cible à moins de 40 studs.
- `SacADos` : sac orange à 2 bretelles, ouvre le menu des défenses.
- `Reparer` : marteau à 45°, tête Ardoise.
- `Etourdi` : 3 étoiles crème en arc, affichées 2 s au-dessus du Survivant.
- `Muret` : 3 rangées de briques crème décalées.
- `MiniTourelle` : cube-canon orange sur un trépied Ardoise.
- `TapisCollant` : tapis rayé crème et orange, 3 fils qui s'étirent.
- `PoseInterdite` : cercle barré Alerte, quand l'emplacement est refusé ou que 3 défenses sont déjà posées.

### Ligne 2 · Établi (pictogrammes crème et Ardoise sur `PastilleEtabli`)
- `Degats` : éclat « pow » à 8 pointes.
- `Cadence` : 3 balles en file avec des traits de vitesse.
- `Portee` : 2 arcs concentriques dépassés par une flèche.
- `Solidite` : bouclier carré à 4 rivets, avec `BadgeEquipe`.
- `Reparation` : le marteau de `Reparer` posé sur une brique, avec `BadgeEquipe`.
- `Regeneration` : croix « + » et 2 bulles qui montent, avec `BadgeEquipe`.
- `Butin` : pyramide de 3 Pièces (exception : en or).
- `BallesExplosives` : balle ronde avec mèche et étincelle orange.

### Ligne 3 · Laboratoire
- `TourelleToit` : toit orange, canon qui sort du faîte.
- `BallesPerforantes` : balle pointue qui traverse 2 cubes violets.
- `ViseeCritique` : réticule crème avec un éclat orange au centre. Sert aussi pour le coup critique flottant.
- `Foreuse` : mèche hélicoïdale Ardoise, Gemme à la pointe. Sert aussi pour la collecte hors connexion.
- `ArbreRecherches` : fiole ronde au liquide cyan.
- `Capsule` : capsule ovale orange, hublot Nuit labo.
- `Galerie` : figurine violette sur un socle.
- `Boutique` : t-shirt crème à col orange, pour les cosmétiques en Robux.

### Ligne 4 · Boutons et rendez-vous
- `Etabli` : plateau sur 2 pieds, engrenage orange.
- `RouePings` : cercle en 4 quartiers, dont un orange.
- `Parametres` : 3 curseurs décalés.
- `Fermer` : X Encre épais.
- `Retour` : flèche vers la gauche.
- `Son` et `SonCoupe` : haut-parleur à 2 ondes, puis la même icône barrée d'Alerte.
- `DefiDuJour` : calendrier crème à 2 anneaux, soleil orange.

### Ligne 5 · Pings et marqueurs
- `PingColosse` (« Colosse ! ») : tête cornue violette, contour Alerte.
- `PingRepare` (« Répare ! ») : façade de la Maison, marteau dans le coin.
- `PingIci` (« Ici ! ») : épingle orange, pointe en bas.
- `PingMerci` (« Merci ! ») : cœur orange.
- `HorsEcranZbire` : chevron violet au bord de l'écran.
- `HorsEcranColosse` : chevron Alerte avec une mini-tête cornue.
- `Bloque` : casque Ardoise et étincelle, pour un coup non critique sur un Casqué.
- `ZbireSemaine` : calendrier crème, tête violette au centre.

**Ligne 6 :** les 6 pastilles, puis `BadgeEquipe`. **Ligne 7 :** réserve pour les événements et les cosmétiques.

## 4. Bestiaire de l'Atlas B

Chaque portrait montre la tête de face, sur un corps violet, avec **un seul trait distinctif** :
- Marcheur : cube, yeux ronds.
- Rapide : traits de vitesse.
- Costaud : 4 piquants Ardoise.
- Doré : corps or bordé de violet, Gemme dans le coin.
- Sauteur : ressort.
- Gluant : goutte à bulles.
- Mini-Gluant : goutte de 8 × 8.
- Volant : 2 ailes carrées.
- Casqué : casque Ardoise.
- Colosse : tête cornue, contour Alerte.

Tailles d'usage : 256 px dans la Galerie, 64 px pour les modificateurs du Défi du Jour.

## 5. Module `ReplicatedStorage.Icones`

Les clés de code n'ont pas d'accents. Les libellés affichés reprennent les noms du canon.

```lua
--!strict
-- Affichage seulement : un bouton n'envoie qu'une demande, le serveur décide.
local TweenService = game:GetService("TweenService")

type Atlas = { id: string, cellule: number, colonnes: number }
type Ref = { atlas: Atlas, index: number }

local ATLAS: { [string]: Atlas } = {
	A = { id = "rbxassetid://0", cellule = 128, colonnes = 8 }, -- ID à reporter après import
	B = { id = "rbxassetid://0", cellule = 256, colonnes = 4 },
}

local ORDRE: { [string]: { string } } = {
	A = {
		"Piece", "Gemme", "Jour", "Record", "Maison", "MaisonFissuree", "Repit", "Horde",
		"Blaster", "SacADos", "Reparer", "Etourdi", "Muret", "MiniTourelle", "TapisCollant", "PoseInterdite",
		"Degats", "Cadence", "Portee", "Solidite", "Reparation", "Regeneration", "Butin", "BallesExplosives",
		"TourelleToit", "BallesPerforantes", "ViseeCritique", "Foreuse", "ArbreRecherches", "Capsule", "Galerie", "Boutique",
		"Etabli", "RouePings", "Parametres", "Fermer", "Retour", "Son", "SonCoupe", "DefiDuJour",
		"PingColosse", "PingRepare", "PingIci", "PingMerci", "HorsEcranZbire", "HorsEcranColosse", "Bloque", "ZbireSemaine",
		"PastilleAction", "PastilleEtabli", "PastilleRecherche", "PastilleDefense", "PastilleAlerte", "PastillePing", "BadgeEquipe",
	},
	B = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" },
}

local INDEX: { [string]: Ref } = {}
for nom, cles in ORDRE do
	for i, cle in cles do
		assert(INDEX[cle] == nil, `Icône en double : {cle}`)
		INDEX[cle] = { atlas = ATLAS[nom], index = i - 1 }
	end
end

-- Effet élastique : aller-retour de 0,075 s, soit 0,15 s
local REBOND = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)

local Icones = {}

function Icones.appliquer(image: ImageLabel | ImageButton, cle: string)
	local ref = INDEX[cle]
	assert(ref, `Icône inconnue : {cle}`)
	local c = ref.atlas.cellule
	image.Image = ref.atlas.id
	image.ImageRectSize = Vector2.new(c, c)
	image.ImageRectOffset = Vector2.new(ref.index % ref.atlas.colonnes * c, ref.index // ref.atlas.colonnes * c)
	image.ResampleMode = Enum.ResamplerMode.Pixelated
	image.BackgroundTransparency = 1
end

function Icones.creer(cle: string, taille: number, parent: Instance?): ImageLabel
	assert(taille >= 32 and taille % 16 == 0, "Icône : multiple de 16, 32 px minimum")
	local image = Instance.new("ImageLabel")
	image.Name = "Ico_" .. cle
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromOffset(taille, taille)
	Icones.appliquer(image, cle)
	image.Parent = parent
	return image
end

function Icones.rebond(objet: GuiObject)
	local base = objet:GetAttribute("TailleBase")
	if typeof(base) ~= "UDim2" then
		base = objet.Size
		objet:SetAttribute("TailleBase", base)
	end
	local b = base :: UDim2
	objet.Size = b
	TweenService:Create(objet, REBOND, {
		Size = UDim2.new(b.X.Scale * 1.2, b.X.Offset * 1.2, b.Y.Scale * 0.8, b.Y.Offset * 0.8),
	}):Play()
end

function Icones.creerBouton(cle: string, pastille: string, taille: number, parent: Instance?): ImageButton
	assert(taille >= 64 and taille % 16 == 0, "Bouton mobile : multiple de 16, 64 px minimum")
	local bouton = Instance.new("ImageButton")
	bouton.Name = "Btn_" .. cle
	bouton.AnchorPoint = Vector2.new(0.5, 0.5)
	bouton.Size = UDim2.fromOffset(taille, taille)
	bouton.AutoButtonColor = false
	Icones.appliquer(bouton, pastille)
	local picto = Icones.creer(cle, taille - 16, bouton)
	local ratio = (taille - 16) / taille
	picto.Size = UDim2.fromScale(ratio, ratio) -- suit l'écrasement de la pastille
	bouton.Activated:Connect(function()
		Icones.rebond(bouton)
	end)
	bouton.Parent = parent
	return bouton
end

return Icones
```

Exemple : `Icones.creerBouton("Reparer", "PastilleAction", 96, hud)`.

## 6. Validation à 32 px

1. **Ombre chinoise :** on montre la silhouette Encre à 5 joueurs de 9 à 13 ans, qui doivent la nommer sans aide. En dessous de 4 bonnes réponses sur 5, on redessine l'icône.
2. **Daltonisme :** on vérifie en niveaux de gris et avec un filtre de deutéranopie. La Pièce et la Gemme doivent se distinguer par leur forme.
3. **Fonds :** on teste sur Prairie #6CC24A, Terre battue et Nuit labo, puis avec `ClockTime` à 17,5.
4. **Appareil :** Android d'entrée de gamme de 5,5 pouces, tenu à bout de bras.
5. **Paires à risque**, comparées côte à côte : `Degats` et `BallesExplosives`, `Reparer` et `Reparation`, `DefiDuJour` et `ZbireSemaine`.
