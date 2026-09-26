# Zsurvie · Bâtiments et structures clés

*Armand Solère, Construction & Modélisation. Cotes en studs, sol à Y = 0, nord = −Z.*

## 1. Règles d'échelle

| Règle | Valeur |
|---|---|
| Survivant (R15) | ≈ 5 studs, référence de toutes les cotes |
| Grille des bâtiments | 4 studs : les bords des socles tombent sur des multiples de 4 |
| Portes | 4 × 8 au lobby, 4 × 6 sur la Maison (décor) |
| Lobby | Hauteur libre ≥ 16 pour la caméra `Classic`, passages de 12 |
| Façades | Tournées vers +Z, car la caméra de run (0, 45, 28) regarde vers −Z |
| Règle des 6 studs | Mesurée depuis le centre de la Maison. La Maison (14 studs, canon) est la seule exception |
| « À 12 studs de la Maison » | 12 studs libres entre le mur est et la Mine |

## 2. La Prairie : plan de masse

L'origine est le centre de la Maison. L'arène fait 220 × 220.

| Structure | Centre (X, Z) | Emprise | Haut. max | Fonction |
|---|---|---|---|---|
| Maison | (0, 0) | 16 × 16 | 14 | Cible des Zbires |
| Parvis | (0, 0) | 24 × 24 | 0,2 | Zone de réparation visible |
| Mine | (26, −14) | 12 × 12 | 6 | Gemmes en continu |
| Établi | (−22, 16) | 12 × 8 | 6 | Améliorations |
| Apparition | (0, 20) | 8 × 8 | 0,5 | `SpawnLocation`, `Neutral` = true |
| 4 chemins | Axes X et Z, de r = 12 à 72 | 8 de large | 0,2 | Terre battue |
| 3 pique-niques | (−40, −30), (38, 32), (−36, 44) | 8 × 8 | 3 | Décor, `CanCollide` false |
| Barrière | Cercle r = 72 | 24 segments | 12 | Invisible, `CanQuery` false |
| 8 portails violets | r = 86, tous les 45° | 12 × 2 | 14 | Apparition des Zbires |
| Portail nord | (0, −86) | 20 × 4 | 24 | Agrandi pour le Colosse |
| Lisière | Anneau 72 → 100 | — | 6 à 20 | Forêt de cubes |
| Fond | Anneau 100 → 110 | — | 24 au nord, 4 au sud | Horizon |

### La Maison · « Cocon chaleureux »

- **Volumes :**
  - socle Ardoise 16 × 1 × 16 ;
  - murs Crème de Y 1 à 8, avec des chaînages orange aux angles ;
  - toit Toit orange en 4 gradins de 1 stud (16, 12, 8 et 4 de côté), de Y 8 à 12 ;
  - cheminée 2 × 2 × 2 de Y 12 à 14.
- **Silhouette :** vue d'en haut, une cible de carrés orange emboîtés, lisible même au zoom minimum.
- **Façade :** porte 4 × 6 face à +Z, 4 fenêtres 4 × 3 en `Neon` Or et 1 `PointLight` Or (`Range` 14). La lueur chaude porte le Jour du Colosse.
- **Tourelle de toit :** une tourelle 4 × 2 × 4 remplace la cheminée. Le sommet reste à Y 14.
- **Record :** la Part `AncreRecord` (invisible, dans le Model) en (0, 18, 0) porte le `BillboardGui` « Record : Jour X ».
- **3 états**, sur des seuils proposés de > 60 %, 31 à 60 % et ≤ 30 % des PV :
  - *Intacte* ;
  - *Abîmée* : planches clouées, 2 blocs de toit tombés ;
  - *Critique* : moitié du toit en cubes au sol, fumée de cubes Ardoise (`Rate` 8).
- **Échange des états :** chaque état est un Model de 80 Parts au plus. Un seul est dans `Workspace`, les autres attendent dans `ServerStorage.EtatsMaison`.

### La Mine · « Trésor, lueur cyan »

- **Butte :** Ardoise en 3 gradins de 1 stud (12, 8 et 4 de côté). L'entrée de galerie 4 × 3, étayée, fait face à +Z.
- **Cristaux :** 8 cristaux `Neon` Gemme cyan 1 × 2,5 × 1, inclinés de 15°. 1 `PointLight` cyan (`Range` 16, `Brightness` 1,5).
- **Abords :** un wagonnet sur 8 studs de rails tournés vers la Maison.
- **Foreuse :** si un Survivant l'a recherchée, une tête 2 × 3 × 2 tourne au sommet, jusqu'à Y 6.
- **Silhouette :** une montagne grise hérissée de cyan, seule structure cyan de la Prairie.

### L'Établi · « À nous »

- **Structure :** comptoir Terre battue 12 × 3 × 4, à hauteur de coude, sous un auvent rayé orange et crème (de Y 5 à 6). Enseigne en forme de clé à molette 3 × 3 en Or.
- **Casiers :** 8 casiers d'icônes, un par amélioration. 1 `PointLight` Or (`Range` 12).
- **Usage :** un bouton de 60 px apparaît à moins de 10 studs. Le serveur revérifie la distance (≤ 12) et le solde.
- **Silhouette :** le seul toit plat de la Prairie.

### Portails et Lisière · « Mystérieuse sans faire peur »

- **Portail :** 2 piliers Ardoise 2 × 14 × 2, un linteau et un voile `Neon` Violet horde 8 × 10 × 0,4. Un `ParticleEmitter` lâche des cubes violets (`Rate` 10). Seuls les 4 portails cardinaux ont une `PointLight`.
- **Portail nord :** voile 16 × 20, à `Transparency` 1 sauf le Jour du Colosse.
- **Arbres-cubes :** tronc 2 × 4 × 2, surmonté de 1 à 3 cubes de feuillage de 6 en Prairie ombre ou lumière. Quelques champignons cubes violets.
- **Plafond sud :** vue de la caméra, la ligne vers les pieds d'un Survivant monte de 1,6 stud par stud.
  - Au sud (Z > 0), un objet respecte hauteur ≤ 1,6 × d, où d est l'écart en Z entre sa face nord et la barrière. Pour d = 4, 8 et 12 : 6, 12 et 20 studs.
  - Au nord, les arbres font de 10 à 20 studs, sans contrainte.

### Défenses posables

| Défense | Dimensions | Parts max | Lecture |
|---|---|---|---|
| Muret | 8 × 3 × 2 | 12 | Plus bas qu'un Survivant, le Volant le survole |
| Mini-Tourelle | 4 × 5 × 4 | 20 | Tête crème pivotante |
| Tapis Collant | 8 × 0,2 × 8 | 4 | Crème à pois orange |

Le serveur valide chaque pose : entre le parvis et r = 64, à plus de 4 studs de la Mine, de l'Établi et de l'apparition.

## 3. Le Laboratoire : plan de masse (`MaxPlayers` 12)

L'origine est le centre de la Rotonde.

| Structure | Centre (X, Z) | Emprise | Haut. | Fonction |
|---|---|---|---|---|
| Rotonde | (0, 0) | Ø 80 intérieur, 112 extérieur | Murs 16, dôme 34 | Cœur du lobby |
| Arbre des Recherches | (0, 0) | 12 × 12 | 30, antenne 44 | Interface des recherches |
| Podium de Doc Boulon | (12, 0) | 8 × 8 × 1 | — | Tutoriel, face à l'est |
| 12 Alcôves | Anneau r 40 → 56 | 12 × 16 | 16 | Machines de recherche |
| Sas d'arrivée* (est) | (48, 0) | 12 de large | 16 | `SpawnLocation` face au centre |
| Quai des Capsules (sud) | (0, 86) | 64 × 28 | Tubes 40 | Départ des runs |
| Galerie des Zbires (nord) | (0, −88) | 48 × 32 | 16 | Musée |
| Balcon des Rendez-vous* (ouest) | (−64, 0) | 16 × 16 | 16 | Défi du Jour, Zbire de la Semaine |

\* Noms de travail hors canon, à valider par Victor Lanoue.

### Rotonde et Arbre des Recherches · « Repaire de savant »

- **Travées :** 16 travées de 22,5°, soit 12 Alcôves (3 par quart) et 4 passages cardinaux. Chaque pilier Ardoise 4 × 16 × 4 porte un filet `Neon` cyan.
- **Dôme :** Nuit labo, en 5 anneaux-gradins de 4 studs, avec un oculus de Ø 16. Sa silhouette pixelisée se reconnaît depuis le Quai.
- **Arbre :**
  - tronc 8 × 30 × 8 et jusqu'à 24 nœuds cubes 2 × 2 × 2, un par recherche ;
  - un nœud passe en `Neon` cyan côté client quand le joueur possède la recherche (visuel seul) ;
  - une antenne coiffée d'une boule `Neon` à Y 44 se voit dans l'oculus.
- **Accès :** 4 `ProximityPrompt`, une par face, avec `MaxActivationDistance` 12 et `HoldDuration` 0.

### Les Alcôves · « Visibles par tous »

- **Volume :** 12 × 16 × 16, sol surélevé de 1 stud.
- **Socles :** 6 socles 3 × 3 au pas de 4 : Tourelle de toit, Balles perforantes, Visée critique, Foreuse, et 2 en réserve.
- **Machines :** 30 Parts et 10 studs au plus, animation élastique côté client.
- **Attribution :** le serveur attribue l'Alcôve au `PlayerAdded` (attribut `Proprietaire` = UserId). Une plaque `SurfaceGui` affiche le nom du joueur.

### Le Quai des Capsules · « Gare futuriste »

- **Capsules :** 3 Capsules octogonales Ø 12 × 16, en X = −20, 0 et 20 (Z = 90), chacune avec 6 sièges.
  - Normale : Crème et Toit orange.
  - Difficile : Alerte.
  - du Jour : Gemme cyan.
- **Départ :** chaque Capsule monte dans un tube transparent de Ø 14 qui s'élève jusqu'à Y 40 (tween client), pendant que le serveur téléporte.
- **Embarquement :** une dalle 8 × 8 devant chaque porte, testée par le serveur toutes les 0,5 s avec `workspace:GetPartBoundsInBox`. Il n'y a aucun bouton à viser.
- **Panneau :** un `SurfaceGui` affiche « 3/6 · départ 12 s ».

### La Galerie des Zbires · « Musée rigolo »

- **Entrée :** une arche Violet horde, seul violet du lobby.
- **Piédestaux :** 8 de 6 × 6 × 2 portent des figurines à l'échelle 1,5. Les Mini-Gluants partagent le piédestal du Gluant. Au fond, le Colosse se dresse sur un piédestal 12 × 12 × 2.
- **Cartels :** chaque piédestal affiche le compteur d'éliminations et les variantes à 10, 100 et 1 000.

## 4. Budgets

| | Prairie | Laboratoire |
|---|---|---|
| Parts | 10 000 : décor fixe 5 000 (dont Lisière et Fond 4 000), dynamique 2 860 (Zbires 1 800, éclats 550, défenses 360, Colosse 150), réserve 2 140 | 8 000 (proposition) |
| `Neon` | 150 : structures 30, Zbires et Colosse 70, réserve 50 | 150, dont Arbre 25 et piliers 16 |
| `PointLight` | 12 : Maison, Mine, Établi, 4 portails, Colosse, réserve 4 | 12 |

## 5. Vérificateur d'architecture

Les bâtiments sont rangés dans `Workspace.Carte.Batiments`, avec `PrimaryPart` = Socle non pivoté. Ce ModuleScript d'édition se lance depuis la barre de commande avant chaque livraison.

```lua
-- ServerStorage.OutilsArchi.Verificateur (ModuleScript)
-- require(game.ServerStorage.OutilsArchi.Verificateur).verifierPrairie()
local Verificateur = {}

local HAUTEUR_MAX, RAYON, GRILLE = 6, 60, 4
local LIMITES = { Parts = 5000, Neon = 80, PointLight = 11 } -- décor fixe

local function sommet(part: BasePart): number
	local cf, d = part.CFrame, part.Size / 2
	return cf.Position.Y + math.abs(cf.RightVector.Y) * d.X
		+ math.abs(cf.UpVector.Y) * d.Y + math.abs(cf.LookVector.Y) * d.Z
end

local function surGrille(v: number): boolean
	return math.abs(v - math.round(v / GRILLE) * GRILLE) < 0.01
end

function Verificateur.verifierPrairie(): boolean
	local batiments = workspace.Carte.Batiments
	local maison: Model = batiments.Maison
	local centre = maison:GetPivot().Position
	local n = { Parts = 0, Neon = 0, PointLight = 0, Lisse = 0 }
	local erreurs = 0
	local function signaler(message: string)
		warn(message)
		erreurs += 1
	end

	for _, objet in workspace:GetDescendants() do
		if objet:IsA("PointLight") then
			n.PointLight += 1
		elseif objet:IsA("BasePart") and not objet:IsA("Terrain") then
			n.Parts += 1
			if objet.Material == Enum.Material.Neon then n.Neon += 1 end
			if objet.Material == Enum.Material.SmoothPlastic then n.Lisse += 1 end
			local ecart = Vector2.new(objet.Position.X - centre.X, objet.Position.Z - centre.Z).Magnitude
			local haut = sommet(objet)
			if ecart < RAYON and haut > HAUTEUR_MAX + 0.01 and not objet:IsDescendantOf(maison) then
				signaler(("[Hauteur] %s : %.1f studs à %.0f de la Maison"):format(objet:GetFullName(), haut, ecart))
			end
		end
	end

	for _, modele in batiments:GetChildren() do
		local socle = modele:IsA("Model") and modele.PrimaryPart
		if socle then
			local p, d = socle.Position, socle.Size / 2
			for _, bord in { p.X - d.X, p.X + d.X, p.Z - d.Z, p.Z + d.Z } do
				if not surGrille(bord) then
					signaler(("[Grille] %s : bord à %.2f"):format(modele.Name, bord))
					break
				end
			end
		end
	end

	for nom, plafond in LIMITES do
		if n[nom] > plafond then
			signaler(("[Budget] %s : %d / %d"):format(nom, n[nom], plafond))
		end
	end
	if n.Lisse < 0.9 * n.Parts then
		signaler(("[Matériaux] SmoothPlastic : %d / %d Parts"):format(n.Lisse, n.Parts))
	end
	print(("[Vérificateur] %d Parts, %d Neon, %d erreur(s)"):format(n.Parts, n.Neon, erreurs))
	return erreurs == 0
end

return Verificateur
```
