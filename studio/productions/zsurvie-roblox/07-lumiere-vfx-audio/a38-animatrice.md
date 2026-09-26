## Règles de timing Zsurvie

- **Lire depuis la caméra** (0, 45, 28), `FieldOfView` 50 : on voit le dessus des têtes. Rebonds verticaux et roulis latéral (±15°) se lisent, un balancement de bras avant-arrière non. On les exagère.
- **Élastique canon :** écrasement × 0,8, étirement × 1,2, repos, 0,05 s par étape (0,15 s), sur chaque impact, réception, pose ou achat.
- **Anticipation lisible à 9 ans :** 0,25 s minimum par attaque de Zbire, 1,0 s pour le Colosse. Impact en 2 images, récupération deux fois plus longue.
- **Pixel-bloc :** Animation Editor à 30 images/s, poses clés espacées d'au moins 2 images. Easing `Cubic` par défaut, `Bounce` sur les réceptions, `Constant` pour les clignements (échange de `Decal`).
- **Jamais d'horreur :** ni chute au sol ni ragdoll. Un Zbire gonfle puis éclate en cubes et en pièces. Un Survivant étourdi voit des étoiles.
- **Horde désynchronisée :** chaque boucle démarre à une phase aléatoire, à une vitesse de × 0,9 à × 1,1. 60 Zbires ne marchent jamais au pas.

## Rigs et pipeline

- **Survivant :** R15 standard (`StarterCharacter` pixel-bloc). Le Blaster est relié à `RightHand` par un `Motor6D` nommé `Grip_Blaster`, animé dans les clips. Le script `Animate` est forké dans `StarterCharacterScripts` (idle, walk, jump, fall et sit remplacés).
- **Zbires :** `AnimationController` + `Animator`, sans `Humanoid`. La `PrimaryPart` est ancrée et déplacée par `PivotTo` côté client. 6 `Motor6D` au maximum, aux noms imposés : `Corps`, `Tete`, `PiedG`, `PiedD`, `Accessoire`, `Accessoire2`. Les Parts animées sont en `Anchored` false, `Massless` true, `CanCollide`, `CanTouch` et `CanQuery` false.
- **Clips communs :** grâce aux noms de joints identiques, Apparition, Touché et Éclat sont 3 clips partagés par tous les Zbires. Le clip de locomotion s'appelle toujours `Marche` (battement du Volant, rebond du Gluant compris).
- **Écrasement sans échelle :** l'Animation Editor n'anime pas `Size`. On simule × 0,8 et × 1,2 en rapprochant ou en écartant les cubes (tête −20 % en Y, pieds +10 % en X). `Size` n'est tweené que sur les objets isolés (pièces, Muret).
- **Rangement :** `ReplicatedStorage.Animations.<Sujet>.<Emplacement>`, repli sur `Zbires.Communs`. Publication sous le groupe propriétaire de l'expérience, sinon rien ne charge.
- **KeyframeMarker :** `Impact`, `Pas`, `Pose`, `Eclat`. Ils ne déclenchent que les sons et les VFX côté client. `Pas` n'est sonore que sur le Costaud et le Colosse (plafond de 16 sons).
- **Autorité serveur :** le serveur applique dégâts et étourdissements selon `ReplicatedStorage.Config.Timings`, qui reprend les durées ci-dessous, jamais sur un marqueur client.
- **Préchargement :** `ContentProvider:PreloadAsync` sur toutes les `Animation` pendant l'écran de téléportation.

## Survivants

| Animation | Durée | Priorité | Boucle | Prod | Intention de timing |
|---|---|---|---|---|---|
| Idle | 2,4 s | Idle | Oui | P0 | Respiration sur 2 cubes, clignement à 1,8 s |
| Course | 0,5 s | Movement | Oui | P0 | Rebond de 0,4 stud à chaque pas, roulis ±10° |
| Saut / Chute | 0,3 s / 0,4 s | Movement | Non / Oui | P1 | Étirement × 1,2 au départ, bras levés |
| Visée | 0,6 s | Action | Oui | P0 | Haut du corps seul. Active dès qu'une cible est à 40 studs |
| Recul | 0,12 s | Action2 | Non | P0 | 2 images, puis retour. Au-delà de 8 tirs/s, joué 1 tir sur 2 |
| Réparation | 0,6 s | Action | Oui | P0 | Coup de clé à 0,3 s (`Impact`), bras très haut |
| Pose défense | 0,5 s | Action | Non | P1 | Accroupi 0,2 s, `Pose` à 0,3 s |
| Étourdi | 2,0 s (0,5 s × 4) | Action3 | Oui | P0 | Entrée écrasée en 0,1 s, tête qui tourne |
| Relevé | 0,3 s | Action3 | Non | P0 | Secoue la tête, étirement × 1,2 |
| Gestes de Pings | 0,8 s | Action4 | Non | P1 | Haut du corps. « Colosse ! » : pointe et saute. « Répare ! » : mime la clé. « Ici ! » : agite le bras. « Merci ! » : pouce levé. Aucun geste pendant l'étourdissement |
| Jour franchi | 1,0 s | Action2 | Non | P2 | Poing levé au début du Répit, si le Survivant ne tire pas |
| Maison tombée | 1,2 s | Action4 | Non | P1 | Mains sur la tête, genoux qui plient, rire gêné |
| Attente en Capsule | 1,6 s | Idle | Oui | P1 | Assis, les pieds qui battent |

**Viser en courant :** cible à portée, `Humanoid.AutoRotate` = false et un `AlignOrientation` (`Responsiveness` 40) tourne le Survivant vers elle. Déplacement opposé à la visée (produit scalaire < −0,3) : l'`Animate` forké joue la course à `AdjustSpeed(-0.8)`. L'orientation se réplique. **Étourdi :** l'attribut serveur `Etourdi` déclenche la piste chez le client propriétaire, qui la réplique.

## Zbires

| Zbire | Emplacement | Durée | Priorité | Boucle | Prod | Intention |
|---|---|---|---|---|---|---|
| Communs | Apparition | 0,5 s | Action | Non | P0 | Saut hors du portail, réception écrasée |
| Communs | Touche | 0,12 s | Action2 | Non | P0 | Recul de 0,2 stud, la marche continue |
| Communs | Eclat | 0,15 s | Action4 | Non | P0 | Gonfle (cubes écartés × 1,2), `Eclat` en fin de clip |
| Marcheur | Marche / Attaque | 0,8 s / 0,6 s | Movement / Action | Oui / Non | P0 | Dandinement ±15°. Recul 0,3 s, coup de tête 0,1 s |
| Rapide | Marche / Attaque | 0,4 s / 0,35 s | Movement / Action | Oui / Non | P1 | Penché à 20°. Anticipation 0,25 s |
| Costaud | Marche / Attaque | 1,2 s / 1,0 s | Movement / Action | Oui / Non | P1 | Pas lourds. Gratte le sol 0,4 s, piquants hérissés |
| Doré | Marche | 0,5 s | Movement | Oui | P1 | Zigzag sautillant, sac de gemmes qui ballotte |
| Sauteur | Marche / Attaque (bond) | 0,6 s / 1,0 s | Movement / Action | Oui / Non | P1 | Écrasement 0,25 s, vol 0,5 s calé sur l'horodatage serveur, réception 0,25 s |
| Gluant | Marche / Division | 0,7 s / 0,35 s | Movement / Action4 | Oui / Non | P1 | Étirement horizontal × 1,2, puis 2 Mini-Gluants jaillissent à ±90° |
| Mini-Gluant | Marche | 0,45 s | Movement | Oui | P1 | Rebond du Gluant, plus vif |
| Volant | Marche (battement) | 0,3 s | Movement | Oui | P1 | Ailes sur 2 images. Flottement sinusoïdal procédural ±0,5 stud sur 1,6 s |
| Casqué | Marche / Touche / CasqueEjecte | 1,0 s / 0,2 s / 0,4 s | Movement / Action2 / Action3 | Oui / Non / Non | P1 | Coup normal : « tink », le casque vibre et rien d'autre. Critique : le casque saute d'1 stud. L'enfant doit sentir la différence |
| Tous | Englué | — | — | — | P1 | Tapis Collant : `AdjustSpeed` de la marche au prorata de la vitesse serveur |

## Colosse

| Animation | Durée | Priorité | Boucle | Prod | Intention |
|---|---|---|---|---|---|
| Entrée | 3,0 s | Action | Non | P1 | Sort d'un portail, fait 3 pas, rugit. Pas de cinématique : les joueurs gardent le contrôle |
| Marche | 2,0 s | Movement | Oui | P1 | 2 pas par cycle. `Pas` déclenche une secousse de caméra de 0,15 s |
| Frappe Maison | 1,6 s | Action | Oui | P1 | Bras levé 0,8 s, frappe, recul |
| Frappe au sol | 2,2 s | Action2 | Non | P1 | Anticipation 1,0 s (cercle Alerte au sol), impact, récupération 1,0 s : la fenêtre de tir |
| Défaite | 2,5 s | Action4 | Non | P1 | Vacille, s'assoit, gonfle, éclate en pluie de cubes et de pièces |

## Objets de la run (TweenService ou boucle client)

| Objet | Animation | Durée | Boucle | Prod | Intention |
|---|---|---|---|---|---|
| Maison | Coup reçu | 0,2 s | Non | P0 | Tremble de ±0,3 stud, au plus 1 fois toutes les 0,3 s |
| Maison | Changement d'état | 0,4 s | Non | P0 | Élastique, cubes qui sautent du toit |
| Maison | Réparée / Effondrement | 0,25 s / 2,0 s | Non | P0 / P1 | Pulsation Crème. S'écrase comme un soufflé, le toit rebondit 2 fois |
| Pièces, Gemmes | Chute / Rotation / Aimant | 0,35 s / 1,5 s / 0,2 s | Non / Oui / Non | P0 | Arc en `Bounce`, 1 tour, aspiration vers le joueur |
| Mine | Extraction | 1,6 s | Oui | P1 | Pioche mécanique, une gemme saute à chaque production |
| Portail | Ouverture / Pulsation | 0,6 s / 1,2 s | Non / Oui | P1 | L'ouverture annonce le Zbire |
| Muret, Tapis Collant | Pose | 0,3 s | Non | P1 | Tombe du ciel, élastique |
| Mini-Tourelle | Pose / Tir | 0,4 s / 0,1 s | Non | P1 | Visée procédurale, 360°/s au maximum |
| Tourelle de toit | Déploiement | 0,8 s | Non | P2 | Sort du toit au début de la run |
| Capsule | Départ / Atterrissage | 1,2 s / 1,0 s | Non | P1 | Portes fermées en 0,4 s à T−1 s. À l'arrivée, les Survivants sautent dehors |

## Laboratoire

| Sujet | Animation | Durée | Priorité | Boucle | Prod | Intention |
|---|---|---|---|---|---|---|
| Doc Boulon | Bricole | 4,0 s | Idle | Oui | P1 | Tournevis en main, remonte ses lunettes à 3 s |
| Doc Boulon | Parle / Pointe / Accueil | 1,2 s / 1,0 s / 1,5 s | Action | Oui / Non / Non | P1 | Pointe : geste du tutoriel, tenu 0,4 s |
| Doc Boulon | Recherche lancée | 1,8 s | Action2 | Non | P2 | Saut de joie |
| Alcôve | Nouvelle machine | 1,2 s | Tween | Non | P1 | Descend du plafond avec l'élastique, visible par tous |
| Machines | Tourelle / Perforantes / Visée / Foreuse | 4,0 / 1,2 / 3,0 / 0,5 s | Procédural | Oui | P2 | Seules les 4 Alcôves les plus proches de la caméra sont animées |
| Galerie | Figurines | clips des Zbires | Movement | Oui | P2 | Jouées à moins de 30 studs. Une variante débloquée fait un tour sur elle-même en 1,0 s |

## Interface

| Élément | Durée | Intention | Prod |
|---|---|---|---|
| Bouton pressé | 0,15 s | `UIScale` 1 → 0,8 → 1,2 → 1 | P0 |
| Compteur de pièces | 0,12 s | +10 % puis retour, regroupé au-delà de 5 gains/s | P0 |
| Roue des Pings | 0,18 s | Ouverture en `Back`, 4 secteurs décalés de 0,03 s | P1 |
| Alerte « Colosse ! » | 1,0 s | 3 pulsations Alerte | P1 |
| Achat à l'Établi | 0,4 s | L'icône saute dans le Sac à dos | P1 |
| Bilan des gemmes | 1,5 s | Décompte, puis élastique final | P1 |

## Code : animation des Zbires côté client

```lua
-- StarterPlayer.StarterPlayerScripts.ZbireAnimateur (ModuleScript, client uniquement)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Timings = require(ReplicatedStorage.Config.Timings)
local ANIMS = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Zbires")
local COMMUNS = ANIMS:WaitForChild("Communs")

local PRIORITES = {
	Marche = Enum.AnimationPriority.Movement,
	Apparition = Enum.AnimationPriority.Action,
	Attaque = Enum.AnimationPriority.Action,
	Touche = Enum.AnimationPriority.Action2,
	CasqueEjecte = Enum.AnimationPriority.Action3,
	Division = Enum.AnimationPriority.Action4,
	Eclat = Enum.AnimationPriority.Action4,
}

local fiches = {} -- [id] = { modele, pistes, vitesseRef, visible }
local ZbireAnimateur = {}

function ZbireAnimateur.attacher(id: number, modele: Model, typeZbire: string)
	local controleur = Instance.new("AnimationController")
	local animator = Instance.new("Animator")
	animator.Parent = controleur
	controleur.Parent = modele

	local dossier = ANIMS:FindFirstChild(typeZbire)
	local pistes: { [string]: AnimationTrack } = {}
	for nom, priorite in PRIORITES do
		local anim = (dossier and dossier:FindFirstChild(nom)) or COMMUNS:FindFirstChild(nom)
		if anim then
			local piste = animator:LoadAnimation(anim)
			piste.Priority = priorite
			piste.Looped = nom == "Marche"
			pistes[nom] = piste
		end
	end

	local marche = pistes.Marche
	marche:Play(0, 1, 0.9 + math.random() * 0.2)
	marche.TimePosition = math.random() * marche.Length -- horde désynchronisée
	fiches[id] = { modele = modele, pistes = pistes, vitesseRef = Timings.VitesseRef[typeZbire], visible = true }
end

-- decalage : secondes écoulées depuis l'ordre serveur, pour rester calé sur l'impact serveur
function ZbireAnimateur.jouer(id: number, nom: string, decalage: number)
	local fiche = fiches[id]
	local piste = fiche and fiche.pistes[nom]
	if not piste or not fiche.visible then
		return
	end
	piste:Play(0.05)
	piste.TimePosition = math.clamp(decalage, 0, piste.Length * 0.5)
end

function ZbireAnimateur.majVitesse(id: number, vitesse: number)
	local fiche = fiches[id]
	if fiche and fiche.visible then
		fiche.pistes.Marche:AdjustSpeed(vitesse / fiche.vitesseRef) -- Tapis Collant compris
	end
end

function ZbireAnimateur.eclater(id: number, surEclat: () -> ())
	local fiche = fiches[id]
	if not fiche then
		return
	end
	fiches[id] = nil
	local eclat = fiche.pistes.Eclat
	eclat:GetMarkerReachedSignal("Eclat"):Once(surEclat) -- VFX cubes et pièces
	eclat:Play(0)
	task.delay(eclat.Length + 0.05, function()
		fiche.modele:Destroy()
	end)
end

-- LOD : hors champ, la marche est coupée (vérification 4 fois par seconde)
local cumul = 0
RunService.Heartbeat:Connect(function(dt)
	cumul += dt
	if cumul < 0.25 then
		return
	end
	cumul = 0
	local camera = workspace.CurrentCamera
	for _, fiche in fiches do
		local _, visible = camera:WorldToViewportPoint(fiche.modele:GetPivot().Position)
		if visible ~= fiche.visible then
			fiche.visible = visible
			if visible then
				fiche.pistes.Marche:Play(0.1)
			else
				fiche.pistes.Marche:Stop(0)
			end
		end
	end
end)

return ZbireAnimateur
```
