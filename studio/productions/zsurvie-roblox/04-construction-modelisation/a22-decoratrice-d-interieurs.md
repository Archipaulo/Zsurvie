# Intérieurs de Zsurvie : pièce par pièce

## 0. Règles communes

- **Grilles :** murs sur 4 studs ; mobilier sur 1 stud (Studio : Move 1, Rotate 90°) ; aucun prop sous 1 stud.
- **Matériaux :** `SmoothPlastic` ; parquet en lattes de 1 stud, 2 teintes alternées. `Glass` seulement pour les hublots et le bocal.
- **Teintes** (base / ombre / lumière) :

  | Couleur | Base | Ombre | Lumière |
  |---|---|---|---|
  | Terre battue | #C8894F | #A06E3F | #D19C66 |
  | Nuit labo | #2A3263 | #22284F | #535676 |
  | Ardoise | #4A4560 | #3B374D | #6C6573 |
  | Crème | #F6E7C1 | #C5B99A | — |

- **Props :**
  - `Anchored` true ; `CastShadow`, `CanTouch` et `CanQuery` false.
  - `CanCollide` false sous 2 studs de haut : aucun Survivant coincé sur mobile.
- **Textes :** `SurfaceGui` (`PixelsPerStud` 25, `TextScaled`, `Enum.Font.FredokaOne`), lettres de 1 stud minimum.
- **Prompts :** `MaxActivationDistance` 8, `RequiresLineOfSight` false. Le client n'accorde jamais rien.
- **Budget lobby :**
  - 150 `Neon` : Cabinet 8, Alcôves 60, Quai 24, Galerie 20, Arbre des Recherches 38.
  - 12 `PointLight` : 3 chacun pour le Cabinet, le Quai, la Galerie et l'Arbre.

## 1. Cabinet de Doc Boulon (Laboratoire)

**Emprise :** 16 × 12 studs, au nord de l'Arbre des Recherches, face à l'apparition.

**Histoire :** Doc Boulon étudie les Zbires depuis bien avant vous et ne rentre jamais chez elle.

| Meuble | Studs | Couleurs | Indice |
|---|---|---|---|
| Bureau en L | 8 × 3 × 4 | Ardoise, plateau Crème | Plans « Maison v12 » : elle rebâtit la Maison après chaque chute |
| Tableau « Fiches Zbires » | 8 × 5, à 4 de haut | liège Terre battue, flèches Alerte | « Casqué : critique ! », « Gluant : × 2 ! », « Volant : passe les Murets ! » |
| Lit de camp | 6 × 3 × 2 | Toit orange | Elle dort ici |
| Bocal d'étude | 3 × 3 × 4 (`Glass`, `Transparency` 0,4) | Gluant Violet horde | Elle étudie la division |
| Bouton sous cloche | 2 × 2 × 2 | Alerte | Pancarte « NE PAS APPUYER » |
| 8 tubes au plafond | 6 × 1 × 1 (`Neon`) | Gemme cyan | Repaire de savant |

**Interactifs**

- **Doc Boulon :** prompt « Parler », qui lance le tutoriel.
- **Bocal :** prompt « Tapoter ». Animation locale :
  - le Gluant s'écrase (× 0,8) ;
  - il se divise en 2 Mini-Gluants pendant 2 s ;
  - puis il se reforme.

  La règle est enseignée sans texte.
- **Bouton :** prompt « Appuyer ». Il lance `ParticleEmitter:Emit(15)` (des cubes cyan) et Doc Boulon crie « Qui a appuyé ?! ». Effet local, 5 s de recharge, aucune récompense.

## 2. Les 12 Alcôves

**Gabarit :** `Laboratoire.Alcoves.Alcove01` à `Alcove12`.

- **Volume :** ouverture 12 studs, profondeur 10, hauteur 12, sol à +1 stud.
- **Finitions :** murs Nuit labo, seuil `Neon` cyan de 12 × 1 × 1.
- **Dossiers :** `Slots` (4 Parts invisibles), `Machines`, `Bache`, `Cartons`, `Tapis`, `Plaque` (avec `SurfaceGui.Nom`).
- **Budget :** 350 Parts au maximum, Alcôve équipée.

| État | Condition | Décor | Ce que ça raconte |
|---|---|---|---|
| Libre | sans propriétaire | bâches Crème ombre, plaque « Libre » | Place à prendre |
| Emménagement | moins de 2 recherches | 4 cartons, lit de camp, Sac à dos au crochet | « Je viens d'arriver » |
| Installé | 2 recherches ou plus | tapis Toit orange | « Ici, c'est chez moi » |

| Recherche | Slot | Stades 1 → 2 → 3 | Animation (client) |
|---|---|---|---|
| Tourelle de toit | fond gauche, sur un établi 4 × 3 × 3 | maquette de la Maison avec mini-tourelle → 2 canons → 3 canons et radar | pivote de 90° toutes les 3 s |
| Balles perforantes | fond droit | cible trouée → 3 cibles percées d'un même trou → banc de tir avec une plaque de Casqué | la cible oscille |
| Visée critique | mur du fond, à 7 studs | lunette sur trépied → mire Alerte → grande lunette | balaie ±30° |
| Foreuse | avant gauche, au seuil | foret de 3 studs → réservoir → double foret de 6 studs | des cubes cyan montent selon `ForeuseStock` |

**Machines :** 40 Parts au maximum par machine et par stade. Au stade 3, 1 Part `Neon`.

**Foreuse :** prompt « Récolter » (`HoldDuration` 0,5).

- Le client le masque chez les autres joueurs.
- Le serveur vérifie `Proprietaire == player.UserId`.

```lua
-- ServerScriptService/Alcoves (Script, place Laboratoire)
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local alcoves = workspace:WaitForChild("Laboratoire"):WaitForChild("Alcoves"):GetChildren()
table.sort(alcoves, function(a, b) return a.Name < b.Name end)
local gabarits = ServerStorage:WaitForChild("MachinesRecherche") -- <Recherche>/Stade1..3
local RECHERCHES = { "TourelleDeToit", "BallesPerforantes", "ViseeCritique", "Foreuse" }
local SEUILS = { 1, 3, 5 } -- niveau minimal des stades 1, 2, 3 (provisoire)
local alcoveDe: { [Player]: Model } = {}

local function montrer(dossier: Instance, visible: boolean)
	for _, p in dossier:GetDescendants() do
		if p:IsA("BasePart") then
			p.Transparency = if visible then 0 else 1
			p.CanCollide = visible and p.Size.Y >= 2
		end
	end
end

local function poser(alcove: Model, nom: string, niveau: number)
	local s = 0
	for i, seuil in SEUILS do
		if niveau >= seuil then s = i end
	end
	local actuelle = alcove.Machines:FindFirstChild(nom)
	if actuelle and actuelle:GetAttribute("Stade") == s then return end
	if actuelle then actuelle:Destroy() end
	if s == 0 then return end
	local machine = gabarits[nom]["Stade" .. s]:Clone()
	machine.Name = nom
	machine:SetAttribute("Stade", s)
	machine:PivotTo(alcove.Slots[nom].CFrame)
	machine.Parent = alcove.Machines -- le client joue le « pop » élastique sur ChildAdded
end

local function amenager(alcove: Model, player: Player?)
	local nb = 0
	for _, nom in RECHERCHES do
		local niveau = if player then (player:GetAttribute("Recherche_" .. nom) or 0) else 0
		poser(alcove, nom, niveau)
		if niveau > 0 then nb += 1 end
	end
	montrer(alcove.Bache, player == nil)
	montrer(alcove.Cartons, player ~= nil and nb < 2)
	montrer(alcove.Tapis, player ~= nil and nb >= 2)
	alcove.Plaque.SurfaceGui.Nom.Text = if player then player.DisplayName else "Libre"
	alcove:SetAttribute("Proprietaire", if player then player.UserId else 0)
end

local function arrivee(player: Player)
	if alcoveDe[player] then return end
	for _, alcove in alcoves do
		if alcove:GetAttribute("Proprietaire") == 0 then
			alcoveDe[player] = alcove
			amenager(alcove, player)
			player.AttributeChanged:Connect(function(attr)
				if string.sub(attr, 1, 10) == "Recherche_" and alcoveDe[player] == alcove then
					amenager(alcove, player)
				end
			end)
			return
		end
	end
end

for _, alcove in alcoves do amenager(alcove, nil) end
Players.PlayerAdded:Connect(arrivee)
for _, p in Players:GetPlayers() do arrivee(p) end
Players.PlayerRemoving:Connect(function(player)
	local alcove = alcoveDe[player]
	alcoveDe[player] = nil
	if alcove then amenager(alcove, nil) end
end)
```

## 3. Intérieur des Capsules (Quai des Capsules)

- **Cabine :** 12 × 8 × 8 studs, hublot `Glass` de 8 × 4.
- **Sièges :** 6 `Seat` de 2 × 1 × 2, en 2 rangées de 3, espacés de 3 studs.
- **Compte à rebours :** 15 s sur le panneau avant, calculées avec l'attribut `Depart` et `workspace:GetServerTimeNow()`.
- **Départ :** à 3 s, une barre de sécurité Crème descend (0,15 s, effet élastique).

| Capsule | Palette | Indice |
|---|---|---|
| Normale | Crème, Toit orange | Panier de pique-nique sous les sièges |
| Difficile | Ardoise, bandes Alerte | Casques cabossés suspendus : beaucoup de Casqués en vue |
| du Jour | Or, Gemme cyan | 2 panneaux 3 × 3 pour les 2 modificateurs, « 150 gemmes » |

## 4. La Galerie des Zbires

**La salle :** 40 × 24 studs, damier Crème et Crème ombre.

**Les socles :** 8 socles Ardoise de 4 × 4 × 1, dans l'ordre du bestiaire (Marcheur, Rapide, Costaud, Doré, Sauteur, Gluant, Volant, Casqué). Au fond, la niche du Colosse : socle 8 × 8, cordon Alerte, plaque « Tous les 5 jours ».

- **Figurine :** le modèle du jeu (30 Parts au maximum), avec une animation d'attente élastique en local.
- **Cartel :** le nom, la règle en une ligne et un compteur personnel « 57 / 100 » (attribut joueur `Elim_<Zbire>`).
- **Variantes :** à 10, 100 et 1 000 éliminations, le client affiche la variante débloquée. Chacun voit sa propre collection.
- **Détails :** pancarte « Ne pas nourrir les Zbires », un banc, une silhouette en carton de Doc Boulon au guichet.

## 5. La Maison (place Prairie)

**Volume :** 16 × 16 × 14 studs, 14 × 14 à l'intérieur, rez-de-chaussée de 8 studs, combles vides.

**Accès :** personne n'entre. La porte est barricadée (planches Terre battue) et les murs sont en `CanCollide`.

**Ce que voit la caméra :**

- Des baies de 4 × 5 studs : 2 au sud (côté caméra), 1 à l'est.
- À 45° de plongée, seule une bande de 5 studs derrière chaque baie est lisible. Les objets clés y sont placés.

**Budget :** 200 Parts au maximum, 0 `Neon`. Un seul `PointLight` (Range 14, Brightness 1,2, couleur Crème, `Shadows` false) : il fait briller les baies au Jour du Colosse (`ClockTime` 17,5).

**Histoire :** six Survivants vivent dans l'ancienne maison d'enfance de Doc Boulon. C'est un ajout au canon, à valider par Victor Lanoue.

| Objet | Place | Indice |
|---|---|---|
| Table et 6 bols | derrière la baie sud gauche | 6 = l'équipe complète |
| Calendrier 3 × 2 | sur la table, tourné vers la baie | « Jour X » (attribut `Jour`), un jour sur 5 entouré en Alerte : le Colosse |
| 3 lits superposés 6 × 3 × 6 | mur nord | 6 couvertures de couleurs différentes |
| Bocal de gemmes | rebord de la baie est | La Mine fait vivre la maison |
| Dessins de Zbires souriants | mur est | Rigolos, pas effrayants |

| `Etat` | PV (proposition) | Intérieur |
|---|---|---|
| 1 : Intacte | plus de 66 % | Rangé, bouquet sur la table |
| 2 : Abîmée | de 33 à 66 % | Cadres penchés de 8°, livres au sol, planche clouée sur la baie est, seau sous une fuite |
| 3 : Critique | moins de 33 % | Cadres à 16°, bols au sol, lumière Toit orange |

**Réglage dans Studio :** sur les Parts de `Maison.Interieur`, les attributs `EtatMin` et `EtatMax` règlent la visibilité, et l'attribut `Penche` l'inclinaison en degrés.

```lua
-- StarterPlayerScripts/InterieurMaison (LocalScript, place Prairie) : visuel seulement
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local maison = workspace:WaitForChild("Maison")
local interieur = maison:WaitForChild("Interieur")
local lampe = interieur:WaitForChild("Lampe"):WaitForChild("PointLight") :: PointLight
local ELASTIQUE = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local origines: { [BasePart]: CFrame } = {}

local function appliquer()
	local etat = maison:GetAttribute("Etat") or 1
	for _, p in interieur:GetDescendants() do
		if not p:IsA("BasePart") then continue end
		local mini, maxi = p:GetAttribute("EtatMin"), p:GetAttribute("EtatMax")
		if mini or maxi then
			p.Transparency = if etat >= (mini or 1) and etat <= (maxi or 3) then 0 else 1
		end
		local angle = p:GetAttribute("Penche")
		if angle then
			origines[p] = origines[p] or p.CFrame
			local cible = origines[p] * CFrame.Angles(0, 0, math.rad(angle * (etat - 1)))
			TweenService:Create(p, ELASTIQUE, { CFrame = cible }):Play()
		end
	end
	lampe.Color = if etat == 3 then Charte.ToitOrange else Charte.Creme
end

maison:GetAttributeChangedSignal("Etat"):Connect(appliquer)
appliquer()
```

**Chute de la Maison :** le toit se soulève de 6 studs en 0,6 s (`Back`) et la caméra plonge à la verticale pendant 3 s. C'est le seul moment où l'on voit tout l'intérieur, y compris l'œuf de Pâques du mur nord : une photo de Doc Boulon enfant devant la Maison.

## 6. Secrets

| Secret | Lieu | Récompense |
|---|---|---|
| 5 peluches Mini-Gluant (tag `PelucheSecrete`, attribut `Id` de 1 à 5) | sous le lit de camp, dans le tiroir du bureau, sous un siège de la Capsule Difficile, derrière le Colosse, au guichet de la Galerie | Badge « Chasseur de peluches » et peluche gratuite pour le Sac à dos |
| Bâche Violet horde, 9e socle | Galerie | Se lève le samedi à 17 h (heure de Paris) sur le Zbire de la Semaine |
| Photo de Doc Boulon enfant | Maison | Visible lors de la chute |

**Règle serveur des peluches :**

- Déclenchement : prompt « Câliner ».
- Vérifications :
  - le personnage est à 12 studs au plus ;
  - la peluche n'est pas déjà dans le masque.
- Sauvegarde : `UpdateAsync` sur un masque de 5 bits (DataStore `PeluchesSecretes_v1`).
- Récompense : à 5 peluches sur 5, `BadgeService:AwardBadge` et attribut `CosmetiquePeluche`.
- Un secret ne rapporte jamais de gemmes ni de pièces.
