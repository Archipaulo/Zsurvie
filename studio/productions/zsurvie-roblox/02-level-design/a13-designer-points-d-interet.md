## Règles communes aux 11 POI

- **Repère :** la Maison est au centre (0, 0, 0), le sol à Y = 0 et le Nord vers −Z. Toutes les valeurs sont en studs.
- **Vu d'en haut :** en run, la caméra canon (0, 45, 28), `FieldOfView` 50, montre surtout le dessus des objets. Chaque secret de la Prairie porte donc son signal sur sa face supérieure.
- **Lisibilité :** aucun élément de secret ne dépasse 6 studs de haut à moins de 60 studs de la Maison.
- **Mobile :** on utilise un `ProximityPrompt` (`HoldDuration` 0,4, `MaxActivationDistance` 8, `RequiresLineOfSight` false) ou un simple passage (`Touched` lu par le serveur). Aucun secret ne demande de tir de précision.
- **Récompenses :** l'ensemble des secrets rapporte au plus 50 gemmes par jour et par joueur. Le Défi du Jour reste la grosse prise, à 150. Le reste se gagne en cosmétiques, en badges et en pièces de run. Aucun bonus de combat ne survit à la run.
- **Budget :** 11 Parts `Neon` sur la Prairie, 8 au Laboratoire, aucune `PointLight`, `ParticleEmitter.Rate` ≤ 20.
- **Collection :** dans la Galerie des Zbires, le **Mur des Curiosités** montre 11 cadres gris. Chaque cadre prend ses couleurs quand le joueur trouve le secret : c'est sa carte au trésor.

## Vue d'ensemble

| # | POI | Zone et repère | Récompense | Fréquence |
|---|---|---|---|---|
| 1 | Le Mini-Gluant fugueur | Laboratoire, 1 cache sur 8 | 15 gemmes | 1/jour |
| 2 | L'Atelier secret de Doc Boulon | Bibliothèque derrière l'Arbre des Recherches | Badge + Lunettes de Doc | 1 fois |
| 3 | L'Alcôve 13 | Anneau des Alcôves, entre la 12 et la 1 | Badge « Curieux » + 10 gemmes | 1 par mise à jour |
| 4 | La Capsule Zéro | Bout du Quai des Capsules | Casque de pilote d'essai | 1 fois |
| 5 | Pompon, le chat de la Maison | Paillasson sud (0 ; 0,5 ; 9,5) | Oreilles de Pompon à 50 caresses | 1 caresse par Répit |
| 6 | La Girouette-Zbire | Faîtage de la Maison, sommet à Y = 14 | Annonce le portail du prochain Doré | Permanent |
| 7 | Le Pique-nique abandonné | Prairie sud-est (32, 0, 30) | Butin +50 % jusqu'à la fin du jour | 1/run/joueur |
| 8 | Les Bornes des 4 Vents | Bout des 4 chemins, à 68 studs | 40 pièces + 20 gemmes par joueur | 1/run |
| 9 | Les Dalles chantantes | Entrée de la Mine | 10 gemmes | 1/jour |
| 10 | Le Nid du Volant | Lisière nord-est (55, 0, −55) | 3 × 15 pièces | 1/run/joueur |
| 11 | Le Colosse endormi | Lisière sud-ouest (−62, 0, 62) | Bonnet de nuit du Colosse après 5 runs | 1/run |

## Au Laboratoire

### 1. Le Mini-Gluant fugueur
- **Ce qui attire l'œil :** dans la Galerie, le socle du Mini-Gluant est vide, avec une plaque « ??? ». Trois traces de gelée cyan (`Decal`) filent vers une grille d'aération. La figurine se cache dans l'une des 8 Parts taguées `CacheMiniGluant` : sous le bureau de Doc Boulon, dans un tuyau du Quai, derrière la Capsule du Jour… Le tirage donne la même cache sur tous les serveurs du jour.
- **Indice :** la figurine gigote (écrasement élastique toutes les 4 s) et couine en 8-bit. On l'entend jusqu'à 20 studs (`RollOffMaxDistance` 20).
- **Histoire :** c'est un vrai Mini-Gluant, apprivoisé par Doc Boulon. La preuve que les Zbires ne sont pas méchants.

### 2. L'Atelier secret de Doc Boulon
- **Ce qui attire l'œil :** un seul livre dépasse de la bibliothèque. Son dos est Or et porte le titre « Zbirologie T.1 ». L'action « Tirer le livre » fait glisser la bibliothèque de 8 studs en 1,2 s (`TweenService`, `EasingStyle.Back`) et ouvre une salle de 16 × 12 studs. On y trouve le Tableau noir, qui donne l'ordre du jour des Bornes et les notes des Dalles, une photo de Doc Boulon tenant un bébé Colosse et le premier Blaster, bricolé à partir d'un sèche-cheveux.
- **Indice :** à la fin du tutoriel, Doc Boulon lance : « Et ne touche pas à ma Zbirologie ! »
- **Histoire :** c'est ici que Doc Boulon a compris que les Zbires sont attirés par la Mine.

### 3. L'Alcôve 13
- **Ce qui attire l'œil :** entre l'Alcôve 12 et l'Alcôve 1 se dresse un mur de briques Ardoise fendu. Une lueur cyan filtre par la fente (1 Part `Neon` de 0,2 × 3). L'action « Regarder par la fente » cadre la caméra locale 3 s sur une machine bâchée : la silhouette de la prochaine recherche. La bâche change à chaque mise à jour.
- **Indice :** l'anneau du sol compte 13 dalles numérotées pour 12 Alcôves.
- **Histoire :** c'est l'invention que Doc Boulon n'a pas finie. Chaque mise à jour relance les rumeurs.

### 4. La Capsule Zéro
- **Ce qui attire l'œil :** au bout du Quai, hors des rails, attend une Capsule rouillée (Ardoise, Toit orange délavé) sous un panneau « PROTOTYPE, NE PAS MONTER ». Elle a 6 `Seat` et 6 ampoules `Neon`, qui s'allument une par passager. À 4 passagers, elle tremble 3 s, bondit de 6 studs, lâche des confettis (`Rate` 20 pendant 1 s) puis retombe.
- **Indice :** les ampoules allumées se voient de tout le Quai et attirent les autres joueurs sans passer par le chat.
- **Histoire :** c'est la toute première Capsule. Elle n'a jamais atteint la Prairie.

## Pendant la run

### 5. Pompon, le chat de la Maison
- **Ce qui attire l'œil :** un chat pixel Crème et Toit orange (30 Parts au maximum, 1,5 stud de haut) dort sur le paillasson, face à la caméra. À l'état 3 de la Maison, il file sous le perron. Quand elle tombe, il saute dans la Capsule du retour. L'action « Caresser » n'est active que pendant le Répit : il ronronne et fait jaillir un cœur de particules. Les Zbires l'ignorent et il ne subit jamais de dégâts.
- **Indice :** Pompon est visible dès la première seconde. Le vrai secret, c'est le compteur de caresses.
- **Histoire :** on ne défend pas une maison, on défend Pompon.

### 6. La Girouette-Zbire
- **Ce qui attire l'œil :** une girouette Ardoise en forme de Marcheur grince sur le faîtage, sans dépasser le gabarit canon de la Maison. 5 s avant l'apparition d'un Doré, elle pivote vers son portail (tween de 0,6 s) et son ventre `Neon` Or s'allume.
- **Indice :** un conseil de l'écran de chargement : « Ma girouette ne suit pas le vent… »
- **Histoire :** c'est un gadget de Doc Boulon qui flaire l'or.

### 7. Le Pique-nique abandonné
- **Ce qui attire l'œil :** une nappe de 6 × 6 studs à carreaux Toit orange et Crème, un panier de 1,5 stud et une tarte entamée. L'action « Goûter la tarte » donne le bonus de Butin.
- **Indice :** des miettes (`Decal`) sont semées le long du chemin Sud.
- **Histoire :** une famille pique-niquait ici. Elle a fui la première horde en laissant la Maison… et Pompon.

### 8. Les Bornes des 4 Vents
- **Ce qui attire l'œil :** 4 bornes Crème de 2 × 4 × 2 studs portent chacune un symbole sur le dessus : Soleil, Lune, Éclair ou Cœur. Le symbole est Ardoise quand la borne est éteinte, `Neon` Or quand elle est allumée. Il faut toucher les bornes dans l'ordre du jour en 20 s au plus. Une erreur éteint tout. En solo, le tour prend environ 18 s au pas de course ; à 4, c'est une fête.
- **Indice :** l'ordre est écrit sur le Tableau noir du POI 2. Les joueurs se le transmettront : c'est le secret qui fera parler du jeu.
- **Histoire :** ce sont les restes d'une vieille barrière anti-Zbires, bâtie avant la Maison.

### 9. Les Dalles chantantes
- **Ce qui attire l'œil :** 5 dalles de cristal de 2 × 0,2 × 2 studs, dans les 3 teintes de Gemme cyan. Chacune joue une note quand on marche dessus : Do, Ré, Mi, Sol, La. Si l'on joue les 5 premières notes du jingle de départ des Capsules, la Mine crache une gerbe de gemmes.
- **Indice :** on entend le jingle à chaque départ, et ses notes colorées figurent sur le Tableau noir.
- **Histoire :** la Mine chante, et c'est son chant qui attire les Zbires.

### 10. Le Nid du Volant
- **Ce qui attire l'œil :** un arbre de cubes de 12 studs porte à sa cime un nid garni de 3 pièces géantes : le seul point doré de la canopée vu d'en haut. L'action « Secouer l'arbre », au pied du tronc, fait tomber les 3 pièces, qui éclatent en 15 pièces chacune.
- **Indice :** avant de fondre sur la Maison, les Volants font un crochet par cet arbre.
- **Histoire :** les Volants sont des pies : ils chipent tout ce qui brille.

### 11. Le Colosse endormi
- **Ce qui attire l'œil :** dans une clairière de 20 studs, un Colosse couvert de mousse (Ardoise et Prairie, 20 × 5 × 10 studs) ronfle en 8-bit sous des bulles de sommeil (`Rate` 2). L'action « Chatouiller le nez » le fait éternuer : souffle de particules et secousse de caméra de 0,3 s. Le Jour du Colosse, la clairière est vide.
- **Indice :** après chaque Jour du Colosse, des empreintes géantes (`Decal` de 4 × 6) relient la clairière à la Prairie.
- **Histoire :** le Colosse attaque tous les 5 jours parce qu'il dort les 4 autres.

## Code serveur : `ServerScriptService.Secrets`

Ce script est publié en Package dans les deux places. Chaque bloc ne fait rien si ses instances taguées sont absentes.

```lua
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

-- Équipe Données : get(player) -> profil?, ajouterGemmes(player, n, raison) via UpdateAsync
local Profils = require(ServerScriptService.Donnees.Profils)
local SecretTrouve = ReplicatedStorage.Remotes.SecretTrouve :: RemoteEvent

local PLAFOND_JOUR, VERSION_MAJ = 50, 1 -- incrémenter VERSION_MAJ quand la bâche de l'Alcôve 13 change
local SECRETS = {
	MiniGluant = { gemmes = 15, mode = "jour" },
	Alcove13 = { gemmes = 10, mode = "maj" },
	Dalles = { gemmes = 10, mode = "jour" },
	Bornes = { gemmes = 20, mode = "run" },
}
local faitsIci: { [Player]: { [string]: boolean } } = {}

local function jourUTC(): number
	return os.time() // 86400
end

local function aleaDuJour(sel: number): Random
	return Random.new(jourUTC() * 7919 + sel) -- même tirage sur tous les serveurs
end

local function aPortee(player: Player, cible: BasePart, portee: number): boolean
	local racine = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return racine ~= nil and racine:IsA("BasePart") and (racine.Position - cible.Position).Magnitude <= portee
end

local function reclamer(player: Player, id: string): boolean
	local def, profil, faits = SECRETS[id], Profils.get(player), faitsIci[player]
	if not (def and profil and faits) then return false end
	local s, jour = profil.secrets, jourUTC() -- { trouves = {}, jour = 0, gemmesDuJour = 0 }
	if s.jour ~= jour then s.jour, s.gemmesDuJour = jour, 0 end
	local marque = if def.mode == "jour" then jour elseif def.mode == "maj" then VERSION_MAJ else true
	if def.mode == "run" then
		if faits[id] then return false end
	elseif s.trouves[id] == marque then
		return false
	end
	faits[id], s.trouves[id] = true, marque
	local gain = math.min(def.gemmes, PLAFOND_JOUR - s.gemmesDuJour)
	if gain > 0 then
		s.gemmesDuJour += gain
		Profils.ajouterGemmes(player, gain, "secret:" .. id)
	end
	SecretTrouve:FireClient(player, id, gain)
	return true
end

local function placerMiniGluant()
	local caches = CollectionService:GetTagged("CacheMiniGluant")
	if #caches == 0 then return end
	table.sort(caches, function(a, b) return a.Name < b.Name end)
	local figurine = ServerStorage.Secrets.MiniGluant:Clone() -- Model, PrimaryPart = Corps
	local corps = figurine.PrimaryPart :: BasePart
	local prompt = corps:FindFirstChildOfClass("ProximityPrompt") :: ProximityPrompt
	figurine:PivotTo(caches[aleaDuJour(1):NextInteger(1, #caches)].CFrame)
	figurine.Parent = workspace
	prompt.Triggered:Connect(function(player)
		if aPortee(player, corps, prompt.MaxActivationDistance + 3) then reclamer(player, "MiniGluant") end
	end)
end

local function ordreDesBornes(): { string }
	local ordre, alea = { "Soleil", "Lune", "Eclair", "Coeur" }, aleaDuJour(2)
	for i = #ordre, 2, -1 do
		local j = alea:NextInteger(1, i)
		ordre[i], ordre[j] = ordre[j], ordre[i]
	end
	return ordre
end

local function preparerTableau() -- Laboratoire : SurfaceGui.Case1..4 contient 4 Frames masquées
	local tableau = workspace:FindFirstChild("TableauNoir", true)
	if not tableau then return end
	for rang, symbole in ordreDesBornes() do
		tableau.SurfaceGui["Case" .. rang][symbole].Visible = true
	end
end

local function preparerBornes() -- Prairie
	local bornes = CollectionService:GetTagged("BorneDesVents")
	if #bornes == 0 then return end
	local ordre, etape, essai, gagne = ordreDesBornes(), 0, 0, false
	local function eclairer()
		for _, borne in bornes do
			local rang = table.find(ordre, borne:GetAttribute("Symbole"))
			borne.Symbole.Material = if rang and rang <= etape then Enum.Material.Neon else Enum.Material.SmoothPlastic
		end
	end
	for _, borne in bornes do
		borne.Touched:Connect(function(touche)
			local player = Players:GetPlayerFromCharacter(touche.Parent)
			if gagne or not player or not aPortee(player, borne, 8) then return end
			local symbole = borne:GetAttribute("Symbole")
			if symbole == ordre[etape + 1] then
				if etape == 0 then
					essai += 1
					local ceTour = essai
					task.delay(20, function()
						if ceTour == essai and not gagne then etape = 0; eclairer() end
					end)
				end
				etape += 1
			elseif symbole ~= ordre[etape] then
				etape = 0 -- mauvais ordre : tout s'éteint
			end
			eclairer()
			if etape == 4 then
				gagne = true
				for _, p in Players:GetPlayers() do reclamer(p, "Bornes") end
				local pluie = ServerStorage.Evenements.PluieDePieces :: BindableEvent
				pluie:Fire(40) -- l'économie de run verse 40 pièces à chaque joueur
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(p) faitsIci[p] = {} end)
Players.PlayerRemoving:Connect(function(p) faitsIci[p] = nil end)
for _, p in Players:GetPlayers() do faitsIci[p] = {} end

preparerTableau()
preparerBornes()
placerMiniGluant()
```

Les autres POI suivent le même schéma : `Triggered` ou `Touched`, puis `aPortee`, puis `reclamer` ou un appel à l'économie de run.

**À valider par Victor Lanoue :** les noms Pompon, Capsule Zéro, Alcôve 13 et Mur des Curiosités, et le lore proposé : la Mine chante, et le Colosse dort 4 jours sur 5.
