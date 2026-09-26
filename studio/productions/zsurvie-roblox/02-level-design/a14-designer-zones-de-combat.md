# Zones de tension : la Prairie

*Olga Brandt, Level Design.* Repère commun : la Maison est centrée en (0, 0, 0) et Y pointe vers le haut. **Nord = −Z = haut de l'écran** : la caméra est décalée de (0, 45, 28), donc au sud du Survivant. Les noms d'anneaux et d'îlots ci-dessous servent seulement en interne et ne sont jamais affichés aux joueurs.

## 1. Anneaux de la Prairie

| Anneau | Étendue | Rôle | Règles |
|---|---|---|---|
| Couloir | 4 studs autour des murs (carré 24 × 24) | Réparer | Ni pose ni décor. 6 `SpawnLocation` 4 × 1 × 4 (`Neutral` true, `Duration` 0, `Transparency` 1) : 2 au nord, 2 au sud, 1 à l'est, 1 à l'ouest |
| Pré carré | Du Couloir au rayon 30 | Défense rapprochée, Mine | Poses autorisées, décor ≤ 3 studs sauf la Mine |
| Champ de tir | Rayon 30 → 55 | Zone de tuerie, îlots | Poses jusqu'au rayon 50, décor ≤ 6 studs |
| Bordure | Rayon 55 → 70 | Entrée des paquets | Décor ≤ 1 stud : on voit tout ce qui entre |
| Lisière | Rayon 70 → 100 | 8 portails au rayon 86 | Survivants arrêtés au rayon 74 |

Le tir automatique porte à 40 studs. Depuis le Couloir, un Survivant couvre donc jusqu'au rayon 50 environ. Rester près de la Maison la protège, sortir rapporte les pièces : c'est la tension de base du jeu.

## 2. Trois paliers de hauteur, trois règles

| Palier | Hauteur | Exemples | Zbires bloqués | Tirs |
|---|---|---|---|---|
| A, Enjambable | ≤ 1 stud | nappes à carreaux, fleurs-cubes, Tapis Collant | aucun | passent |
| B, Muret | 3 studs | Muret, bancs, tables, haies de cubes | tous ceux au sol, sauf le Sauteur (bond de 4 studs) | passent |
| C, Rocher | 6 studs | 3 rochers Ardoise, la Mine | tous, sauf le Volant (vol à 8 studs) | bloqués |

- **Saut des Survivants :** `Humanoid.JumpHeight` 4,5. On peut sauter sur un banc, jamais sur un rocher.
- **Contact d'un Zbire :** distance horizontale ≤ 3 studs **et** écart vertical ≤ 4 studs. Monter sur une table ne met pas à l'abri.
- **Tir automatique :** il ne vise qu'une cible visible, avec un raycast filtré sur le dossier `BloqueTir` (Maison, rochers, Mine). Les Trois Rochers créent le seul angle mort de la Prairie : il faut se déplacer pour viser derrière.
- **Budget des îlots :** 400 Parts au total, 0 Neon, 0 `PointLight`.

## 3. Îlots de couverture et flanking

Les 4 chemins (Terre battue #C8894F, 8 studs de large) mènent aux portails N, E, S et O. On n'y met rien de fixe : c'est là que l'équipe pose ses Murets et ses Tapis. Chaque portail diagonal fait face à un îlot, qui partage son flux entre les deux chemins voisins. Ces Zbires arrivent donc sur le côté des défenses posées sur les chemins.

| Quadrant | Îlot (centre) | Composition | Effet |
|---|---|---|---|
| NE | Pique-nique renversé (32, 0, −32) | 2 nappes (A), 1 table 6 × 3 × 4 et 2 bancs (B) en arc de 12 studs | Partage le flux, le Sauteur passe par-dessus |
| NO | Les Trois Rochers (−34, 0, −34) | 3 rochers (C) 4 × 6 × 4 en V ouvert vers la Lisière, espacés de 3 studs | Angle mort et entonnoir |
| SO | La Haie en L (−30, 0, 30) | 2 haies (B) 12 × 3 × 2 | Couloir d'attaque sur le côté |
| SE | La Mine (20, 0, 20) | Mine (C) et 1 haie (B) 8 × 3 × 2 | Coupe le flux près de la Maison |

- **Pas de rocher au sud :** aucun palier C au sud, sauf la Mine. Côté caméra, il cacherait les Survivants.
- **Pas d'escalier :** aucun décor B à moins de 5 studs d'un décor C, pour qu'on ne puisse pas atteindre un perchoir.
- **Proposition à valider :** le Rapide contourne les Murets, grâce à un second champ de flux recalculé à chaque pose. Les autres Zbires au sol les frappent. S'il ne reste aucun passage, le Rapide frappe aussi.

## 4. Portails équitables

Les 8 portails sont au rayon 86 (N, NE, E, SE, S, SO, O, NO), dans des trouées de 22 studs. Chacun a un cadre carré de 4 barres Neon 12 × 1 × 1. Cela fait 32 Parts Neon sur les 150 autorisées, sans aucune lumière.

1. **Personne ne campe un portail.** 32 murs invisibles au rayon 74 : `Transparency` 1, `CanCollide` true, `CanQuery` false, `CanTouch` false, groupe de collision `LimiteSurvivants`, qui ne heurte que les Survivants. Au moins 12 studs séparent toujours un Survivant d'une sortie : personne n'est étourdi quand un Zbire apparaît.
2. **Alerte de 1,5 s avant chaque paquet.** Le cadre passe de Violet horde #9B5DE5 à Alerte #FF2E63, avec un « wouip » 8-bit. Une flèche en bord d'écran signale le portail s'il est hors champ.
3. **Sortie protégée de 0,8 s.** L'attribut `Ciblable` reste à false : on voit sortir tout le paquet avant de tirer.
4. **Paquets de 3 à 5 Zbires du même type**, espacés de 3 studs, pour lire la horde en une seconde.
5. **Portails actifs.** Les jours 1 et 2, seuls les 4 portails des chemins s'ouvrent. Ensuite, le nombre de portails ouverts vaut `clamp(2 + 2 × Survivants, 4, 8)`, et les portails ouverts changent chaque jour. Un joueur seul ne défend jamais 8 directions.
6. **Équité.** Chaque portail est tiré avec un poids de 1 / (1 + retard)², et le même portail ne lance jamais deux paquets de suite.
7. **Butin.** Un Zbire vaincu dans la Lisière lâche ses pièces au plus au rayon 68.

```lua
--!strict
-- ServerScriptService.Horde.Portails (ModuleScript, serveur uniquement)
-- Tirage équitable des portails, alerte et sortie protégée des paquets.
-- Horde.Zbires fournit creer() et gère la file du plafond de 60 Zbires.
local Workspace = game:GetService("Workspace")

local RAYON_PORTAIL = 86
local RAYON_BUTIN = 68 -- limite des Survivants : 74
local TELEGRAPHE = 1.5
local TELEGRAPHE_COLOSSE = 4
local SORTIE = 0.8
local ECART_PAQUET = 3
local NOMS = { "N", "NE", "E", "SE", "S", "SO", "O", "NO" }
local CHEMINS = { 1, 3, 5, 7 }
local PORTAILS_COLOSSE = { 1, 2, 3, 7, 8 } -- jamais par le sud (caméra)

type Portail = { nom: string, cframe: CFrame, compte: number, modele: Model? }
type Createur = (typeZbire: string, cframe: CFrame) -> Model

local dossier = Workspace:WaitForChild("Prairie"):WaitForChild("Portails")
local rng = Random.new()
local portails: { Portail } = {}
local actifs: { Portail } = {}
local dernier: Portail? = nil

for i, nom in NOMS do
	local angle = math.rad((i - 1) * 45)
	local position = Vector3.new(math.sin(angle), 0, -math.cos(angle)) * RAYON_PORTAIL
	portails[i] = {
		nom = nom,
		cframe = CFrame.lookAt(position, Vector3.zero), -- face à la Maison
		compte = 0,
		modele = dossier:FindFirstChild(nom) :: Model?,
	}
end

local function signaler(p: Portail, attribut: string, valeur: boolean)
	local modele = p.modele
	if modele then
		modele:SetAttribute(attribut, valeur) -- le client anime le cadre Neon
	end
end

local function choisir(): Portail
	local minimum = math.huge
	for _, p in actifs do
		minimum = math.min(minimum, p.compte)
	end
	local poids: { number } = {}
	local total = 0
	for i, p in actifs do
		local w = if p == dernier and #actifs > 1 then 0 else 1 / (1 + p.compte - minimum) ^ 2
		poids[i] = w
		total += w
	end
	local tirage = rng:NextNumber() * total
	for i, p in actifs do
		tirage -= poids[i]
		if tirage <= 0 and poids[i] > 0 then
			return p
		end
	end
	return actifs[1]
end

local Portails = {}

function Portails.nouveauJour(jour: number, nbSurvivants: number)
	table.clear(actifs)
	dernier = nil
	if jour <= 2 then
		for _, i in CHEMINS do
			table.insert(actifs, portails[i])
		end
	else
		local nb = math.clamp(2 + 2 * nbSurvivants, 4, 8)
		for k = 0, nb - 1 do
			table.insert(actifs, portails[(math.floor(k * 8 / nb) + jour) % 8 + 1])
		end
	end
	for _, p in portails do
		p.compte = 0
		signaler(p, "Ouvert", table.find(actifs, p) ~= nil)
	end
end

function Portails.lancerPaquet(typeZbire: string, taille: number, creer: Createur)
	if #actifs == 0 then
		return
	end
	local p = choisir()
	dernier = p
	p.compte += taille
	signaler(p, "Alerte", true)
	task.delay(TELEGRAPHE, function()
		signaler(p, "Alerte", false)
		for n = 1, taille do
			local decalage = (n - (taille + 1) / 2) * ECART_PAQUET
			local zbire = creer(typeZbire, p.cframe * CFrame.new(decalage, 0, 0))
			zbire:SetAttribute("Ciblable", false) -- ni tir auto ni dégâts
			task.delay(SORTIE, function()
				if zbire.Parent then
					zbire:SetAttribute("Ciblable", true)
				end
			end)
		end
	end)
end

function Portails.lancerColosse(jour: number, creer: Createur)
	local i = if jour == 5 then 1 else PORTAILS_COLOSSE[rng:NextInteger(1, #PORTAILS_COLOSSE)]
	local p = portails[i]
	signaler(p, "AlerteColosse", true) -- cadre 22 × 22, ping « Colosse ! »
	task.delay(TELEGRAPHE_COLOSSE, function()
		signaler(p, "AlerteColosse", false)
		creer("Colosse", p.cframe)
	end)
end

-- À 75 s : les portails s'éteignent un par un pendant `duree` secondes.
function Portails.fermer(duree: number)
	for k, p in actifs do
		task.delay((k - 1) * duree / #actifs, signaler, p, "Ouvert", false)
	end
	table.clear(actifs)
end

-- Point de chute des pièces : toujours à portée des Survivants.
function Portails.limiterAuPre(position: Vector3): Vector3
	local plat = Vector3.new(position.X, 0, position.Z)
	if plat.Magnitude <= RAYON_BUTIN then
		return position
	end
	return plat.Unit * RAYON_BUTIN + Vector3.yAxis * position.Y
end

return Portails
```

## 5. La caméra oriente la menace

Avec la caméra (0, 45, 28), un `FieldOfView` de 50 et un écran 16:9, un Survivant voit environ 41 studs devant lui (nord) et 44 sur les côtés, **mais seulement 22 derrière lui (sud)**.

- **Colosse.** Au Jour 5, il sort du portail N à t = 40 s, soit 7 min de run, au début de la 8e minute prévue par le canon. Ensuite, il sort de N, NE, E, O ou NO, jamais du sud. Son alerte dure 4 s : le cadre grandit à 22 × 22 et le ping « Colosse ! » part automatiquement.
- **Zbires hors champ.** Un chevron Alerte signale tout Zbire à 40 studs ou moins qui n'est pas à l'écran.
- **Lisière sud.** Les arbres font au plus 8 studs jusqu'au rayon 80, 20 studs jusqu'au rayon 90 et 30 studs au-delà.
- **Maison.** Elle cache le Survivant jusqu'à 9 studs derrière son mur nord. Tant qu'il s'y trouve, toutes ses Parts passent en `LocalTransparencyModifier` 0,6. Si une face attaquée est hors de vue, un chevron Alerte s'affiche au-dessus (`BillboardGui`, `AlwaysOnTop`).

## 6. Courbe de pression d'un jour

| Moment | Part des Zbires du jour | Déroulé |
|---|---|---|
| 0 à 15 s | 15 % | Paquets de 3, mise en place |
| 15 à 60 s | 55 % | Paquets de 4, les attaques de côté commencent |
| 60 à 75 s | 30 % | Paquets de 5, rush final, musique accélérée de 10 % |
| 75 à 80 s | 0 % | Les portails s'éteignent un par un (Neon → `SmoothPlastic` Ardoise #4A4560) |
| Répit, 15 s | 0 % | Réparer, passer à l'Établi, reposer ses défenses |

- **Jour du Colosse :** 50 % de paquets en moins. L'équipe se partage : 1 ou 2 Survivants sur le Colosse, les autres sur la horde.
- **Proposition à valider, la Course au Doré :** le Doré ignore la Maison et file vers le portail opposé en 14 s. Tout le monde quitte sa position pour le poursuivre. Le serveur verse ses gemmes à tous les Survivants.

## 7. Anti-camping

- **Maison :** fermée pendant la run (porte décorative). Son toit, à 14 studs, reste hors d'atteinte.
- **Poses :** entre le Couloir et le rayon 50, à 4 studs minimum d'un palier C, de la Mine et de la Maison. Les Mini-Tourelles sont espacées d'au moins 8 studs. 3 défenses au maximum par Survivant.
- **Enceinte de Murets :** elle ne suffit pas à tout arrêter. Les Zbires au sol la frappent, le Sauteur saute par-dessus et le Volant la survole.
- **Pièces :** elles disparaissent au bout de 15 s et clignotent pendant les 3 dernières. Il faut sortir les ramasser.
- **Étourdissement :** 2 s, puis 1,5 s d'immunité pendant lesquelles aucun Zbire ne cible le Survivant. On n'enchaîne jamais deux étourdissements.
- **Inactivité :** après 90 s sans aucune demande (déplacement, tir, pose), le Survivant ne compte plus dans le multiplicateur coop des nouveaux Zbires. Un « Zzz » s'affiche au-dessus de lui.
- **Réinitialisation :** désactivée côté client avec `StarterGui:SetCore("ResetButtonCallback", false)`.
