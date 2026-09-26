# Zsurvie : 4 énigmes environnementales

## Règles communes

- **Sans texte :** la forme, le code couleur du canon (violet = ennemi, or = pièces, cyan = gemmes, rose-rouge = danger), une note 8-bit et l'effet élastique (× 0,8 / × 1,2 en 0,15 s) portent toute l'information.
- **Rythme :** en run, une énigme n'existe que pendant le Répit de 15 s et se résout en 6 à 12 s. Il n'y en a aucune dans le Répit qui précède un Jour du Colosse (après les jours 4, 9, 14…) : ce Répit sert à se préparer.
- **Solo possible, coop plus rapide :** aucune plaque n'exige deux joueurs en même temps. Toutes les énigmes sont facultatives et n'ont jamais de pénalité pour l'équipe.
- **Économie :** aucune nouvelle source de gemmes. Les bonus de gemmes passent par la Mine et le Doré, deux sources du canon. Le lobby ne donne que des cosmétiques.
- **Autorité serveur :** chaque énigme porte un attribut `Etat` (`Inactive`, `Annonce`, `Ouverte`, `Resolue`, `Echec`). Le client lit cet attribut et anime, le serveur valide et récompense.
- **Mobile :** en run, avec la caméra `Scriptable` (0, 45, 28), on marche sur des plaques ou on tape un prompt. `ClickDetector` est réservé au lobby.

## Vue d'ensemble

| # | Énigme | Zone | Moment | Durée | Interaction | Récompense |
|---|---|---|---|---|---|---|
| 1 | Le Circuit du Réacteur | Laboratoire | Entre deux runs | 30 à 90 s | `ProximityPrompt` | Chapeau pixel, 1 par jour |
| 2 | Les Ombres de la Galerie | Galerie des Zbires | Entre deux runs | 20 à 60 s | `ClickDetector` | Tampon, 1 par jour |
| 3 | Le Filon qui chante | Mine | Répit après un jour impair | 8 à 12 s | `Touched` | Production de la Mine × 2 le jour suivant |
| 4 | Le Panier renversé | Prairie → Lisière | Répit après un jour pair | 10 à 14 s | `ProximityPrompt` maintenu | 1 Doré de plus le jour suivant |

## 1. Le Circuit du Réacteur (Laboratoire)

**Principe.** Entre le bureau de Doc Boulon et l'Arbre des Recherches, une grille de 3 × 3 dalles de 4 × 4 studs porte des tuyaux droits, coudés ou en T. D'un côté se trouve le Réacteur à gemmes, de l'autre la Machine à Chapeaux, éteinte.

**Solution.** Tourner les dalles d'un quart de tour jusqu'à relier le Réacteur à la Machine. La disposition change chaque jour UTC, avec 4 à 6 dalles à tourner.

**Indices progressifs.**
1. Immédiat : chaque tuyau relié au Réacteur s'allume en Gemme cyan. Une extrémité ouverte crache des étincelles Alerte #FF2E63 (`Rate` 8).
2. À 45 s : la Machine souffle des cubes Crème vers la grille, ce qui montre par quel côté le flux doit arriver.
3. À 90 s : Doc Boulon vient pointer la première dalle mal orientée. Celle-ci fait l'effet élastique toutes les 2 s.

**Récompense.** La Machine éjecte un chapeau pixel (collection permanente de 12) pour chaque Survivant à moins de 30 studs, une fois par jour et par joueur. Les résolutions suivantes ne donnent que des confettis. La grille se remélange 60 s après chaque résolution.

**Mise en œuvre.**
- Les dalles sont des Models `Workspace.Laboratoire.Circuit.Dalle1` à `Dalle9`, avec les attributs `Forme` (`Droit`, `Coude`, `T`) et `Rot` (0 à 3).
- Chaque dalle a un `ProximityPrompt` : `Style = Custom`, `HoldDuration = 0`, `MaxActivationDistance = 6`, `Exclusivity = OnePerButton`, `RequiresLineOfSight = false`. Le client affiche une icône ↻ de 80 px, sans texte.
- Sur `Triggered`, le serveur ignore une dalle tournée il y a moins de 0,4 s (le lobby compte 12 joueurs). Il fait ensuite `Rot = (Rot + 1) % 4`, tourne le tuyau de 90° en 0,15 s (`CanCollide = false`) et lance un parcours en largeur depuis le Réacteur. Les tuyaux atteints reçoivent `Alimente = true` et passent en `Neon` (9 Parts au plus).
- Les chapeaux sont enregistrés avec `DataStoreService`, clé `Survivant_<UserId>`, champs `chapeaux` et `jourChapeau`, écrits par `UpdateAsync`.

## 2. Les Ombres de la Galerie (Galerie des Zbires)

**Principe.** Au fond de la Galerie, une frise Crème rétroéclairée montre 4 silhouettes Encre #1E1B2E. Il faut réveiller, dans le même ordre, les figurines correspondantes parmi les 9 exposées (les 8 Zbires et le Mini-Gluant). L'énigme entraîne le pilier 1 : reconnaître un Zbire à sa silhouette.

**Solution.** Toucher les 4 figurines dans l'ordre de la frise, qui est tirée au sort chaque jour UTC. À partir du 3e Tampon, la frise glisse des paires pièges : Gluant et Mini-Gluant (la taille), Marcheur et Casqué (le casque), Rapide et Sauteur (la posture).

**Indices progressifs.**
1. La frise elle-même : chaque bonne figurine allume sa case en Or.
2. Après 2 erreurs : la prochaine silhouette pulse, pour ce joueur seulement.
3. Après 4 erreurs : 3 dalles du sol s'allument en pas japonais jusqu'à la bonne figurine.

**Récompense.** Un Tampon par jour. À 7 Tampons, consécutifs ou non, le joueur reçoit le skin de Blaster « Figurine ». À 30 Tampons, il reçoit le costume « Gardien de la Galerie ». Les variantes du canon (à 10, 100 et 1 000 éliminations) ne changent pas.

**Mise en œuvre.**
- Chaque figurine a un `ClickDetector` avec `MaxActivationDistance = 24`. Elle mesure au moins 3 × 3 studs pour qu'un doigt la touche sur téléphone.
- Le serveur garde l'état par joueur, `progression[joueur]` et `erreurs[joueur]`, effacés à `PlayerRemoving`.
- Une bonne figurine joue son animation signature pour tous (le Gluant se divise, le Sauteur bondit). Sur une erreur, la figurine secoue la tête en Alerte, pour ce joueur seul, via le `RemoteEvent` `GalerieRetour:FireClient`.
- En cas de réussite, les 4 figurines défilent 3 s sur leurs socles et le Tampon est écrit par `UpdateAsync`.

## 3. Le Filon qui chante (Mine)

**Principe.** Devant la Mine se dressent 4 cristaux Gemme cyan de 1, 2, 3 et 4 cubes de haut (4 studs au plus, sous la limite de 6). Chacun se trouve sur une plaque Terre battue de 4 × 4 studs. Au début du Répit, la Mine joue une suite : chaque cristal s'allume et chante sa note (Do, Mi, Sol, Do aigu).

**Solution.** Marcher sur les plaques dans le même ordre. La suite compte 3 notes, plus 1 tous les 5 jours, 5 au maximum, et jamais deux fois la même note d'affilée. L'équipe a 3 essais.

**Indices progressifs.**
1. La hauteur du cristal double la note : la suite se lit aussi sans le son.
2. Au premier échec, la suite est rejouée à mi-vitesse (0,6 s par note).
3. Au deuxième échec, le prochain cristal à toucher pulse (attribut `Prochain`, animé par le client).

**Récompense.** Le Filon : la Mine produit deux fois plus pendant les 80 s du jour suivant et crache des éclats cyan. Ce sont des gemmes de la Mine, une source du canon. Le service de la Mine lit `Mine.Filon` au passage en horde et le remet à `false` à la fin du jour.

**Mise en œuvre.** Script serveur complet, dans `ServerScriptService.Enigmes.FilonQuiChante` :

```lua
-- Hypothèse : Charte.Gemme = { Base, Ombre, Lumiere } (Color3)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local Partie = ReplicatedStorage:WaitForChild("Partie") -- attributs Phase ("Horde" | "Repit") et Jour
local mine = Workspace:WaitForChild("Mine")
local filon = mine:WaitForChild("Filon")
local fanfare = filon:WaitForChild("Fanfare") :: Sound
local buzz = filon:WaitForChild("Buzz") :: Sound

local cristaux, plaques, notes = {}, {}, {}
for i = 1, 4 do
	cristaux[i] = filon:WaitForChild("Cristal" .. i)
	plaques[i] = filon:WaitForChild("Plaque" .. i)
	notes[i] = cristaux[i]:WaitForChild("Note")
end

local rng = Random.new()
local sequence: { number } = {}
local progression, essais, generation = 0, 0, 0
local ouverte = false
local dernierPas: { [Player]: number } = {}

local function allumer(i: number, duree: number)
	local cristal = cristaux[i]
	cristal.Color = Charte.Gemme.Lumiere
	cristal.Material = Enum.Material.Neon
	notes[i]:Play()
	task.delay(duree, function()
		cristal.Color = Charte.Gemme.Base
		cristal.Material = Enum.Material.SmoothPlastic
	end)
end

local function annoncer(gen: number, duree: number)
	ouverte = false
	task.wait(0.8)
	if gen ~= generation then return end
	filon:SetAttribute("Etat", "Annonce")
	filon:SetAttribute("Prochain", 0)
	for _, i in sequence do
		if gen ~= generation then return end
		allumer(i, duree)
		task.wait(duree + 0.15)
	end
	if gen ~= generation then return end
	progression = 0
	ouverte = true
	filon:SetAttribute("Etat", "Ouverte")
	if essais >= 2 then
		filon:SetAttribute("Prochain", sequence[1]) -- indice 3
	end
end

local function demarrer(jour: number)
	generation += 1
	essais = 0
	table.clear(sequence)
	for n = 1, math.min(3 + jour // 5, 5) do
		local i
		repeat
			i = rng:NextInteger(1, 4)
		until i ~= sequence[n - 1]
		sequence[n] = i
	end
	task.spawn(annoncer, generation, 0.4)
end

local function fermer()
	generation += 1
	ouverte = false
	filon:SetAttribute("Etat", "Inactive")
	filon:SetAttribute("Prochain", 0)
end

local function surPas(i: number, hit: BasePart)
	if not ouverte then return end
	local joueur = Players:GetPlayerFromCharacter(hit.Parent)
	local racine = joueur and joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
	if not joueur or not racine then return end
	if (racine.Position - plaques[i].Position).Magnitude > 6 then return end
	local maintenant = os.clock()
	if maintenant - (dernierPas[joueur] or 0) < 0.3 then return end
	dernierPas[joueur] = maintenant
	if i == sequence[progression] then return end -- pieds encore sur la plaque validée

	if i == sequence[progression + 1] then
		progression += 1
		allumer(i, 0.25)
		if progression == #sequence then
			ouverte = false
			filon:SetAttribute("Etat", "Resolue")
			filon:SetAttribute("Prochain", 0)
			mine:SetAttribute("Filon", true) -- lu par le service de la Mine
			fanfare:Play()
		elseif essais >= 2 then
			filon:SetAttribute("Prochain", sequence[progression + 1])
		end
	else
		ouverte = false
		essais += 1
		filon:SetAttribute("Etat", "Echec")
		buzz:Play()
		if essais < 3 then
			task.spawn(annoncer, generation, 0.6) -- indice 2 : mi-vitesse
		end
	end
end

for i, plaque in plaques do
	plaque.Touched:Connect(function(hit)
		surPas(i, hit)
	end)
end

Partie:GetAttributeChangedSignal("Phase"):Connect(function()
	local jour = Partie:GetAttribute("Jour") or 1 -- pendant le Répit : le jour qui vient de finir
	if Partie:GetAttribute("Phase") == "Repit" and jour % 2 == 1 and jour % 5 ~= 4 then
		demarrer(jour)
	else
		fermer()
	end
end)

Players.PlayerRemoving:Connect(function(joueur)
	dernierPas[joueur] = nil
end)

fermer()
```

## 4. Le Panier renversé (Prairie → Lisière)

**Principe.** Au début du Répit, un panier de pique-nique se renverse à 35 studs de la Maison, sur l'un des 4 chemins. Il lance une gerbe de cubes Or (`Rate` 20 pendant 0,5 s) et un « hoquet » 8-bit spatialisé. Trois pistes d'empreintes en partent vers la Lisière : celles du Marcheur (larges et plates), du Sauteur (par paires espacées de 6 studs) et du Doré (petites, à 3 orteils). Seule la piste du Doré mène à son Nid, un buisson de cubes situé entre 75 et 85 studs de la Maison.

**Solution.** Suivre les empreintes du Doré, puis maintenir 1 s le prompt du bon buisson. Les Survivants peuvent se répartir les pistes et se guider avec « Ici ! » dans la Roue des Pings.

**Indices progressifs.**
1. La forme des empreintes, qui rappelle les silhouettes de la Galerie : les deux énigmes se répondent.
2. À 4 s : les empreintes du Doré scintillent (`ParticleEmitter` Or, `Rate` 4).
3. À 8 s : le bon buisson fait l'effet élastique et crache un cube Or toutes les 2 s.

**Récompense.** Le jour suivant, un Doré de plus sort du portail violet le plus proche du Nid, 5 s après le début de la horde. Il compte dans le plafond de 60 Zbires. Le risque est voulu : quand la horde repart, le Survivant qui a trouvé le Nid est à 80 studs de la Maison, soit 5 s de course.

**Mise en œuvre.**
- Les empreintes viennent de 3 gabarits rangés dans `ServerStorage.Enigmes.Empreintes` : des Parts de 1 × 0,1 × 1, avec `Anchored` à `true` et `CanCollide`, `CanQuery` et `CanTouch` à `false`. Le serveur en clone 10 par piste, soit 30 Parts, détruites à la fin du Répit.
- Chaque chemin a 3 buissons Nid (12 au total), dont un seul est actif par Répit. Chaque buisson porte un `ProximityPrompt` : `Style = Custom`, `HoldDuration = 1`, `MaxActivationDistance = 10`.
- Sur `Triggered`, le serveur vérifie que `Phase` vaut `"Repit"`, que `Etat` vaut `"Ouverte"` et que le `HumanoidRootPart` est à 12 studs au plus. Sur le bon buisson, il passe `Etat` à `"Resolue"` et appelle `Partie:SetAttribute("DoreBonus", indexPortail)`, que le service d'apparition consomme. Un mauvais buisson lâche une bouffée de cubes violets : la seule pénalité est le temps perdu.
- Au passage en horde, `Etat` repasse à `"Inactive"` et les prompts sont désactivés.

## Écart déclaré

Réacteur à gemmes, Machine à Chapeaux, Tampon, Filon, Nid du Doré et Panier renversé sont des noms de décor de travail, hors canon. Ils doivent être validés par Victor Lanoue.
