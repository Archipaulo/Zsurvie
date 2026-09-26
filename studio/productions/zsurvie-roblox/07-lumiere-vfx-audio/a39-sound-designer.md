# Zsurvie : sound design

## 1. Règles de son

- **Style :** chiptune 8-bit sec (carré, triangle, bruit), SFX de 0,05 à 0,4 s. Les Zbires font « pouic », « plop », « clank » : ni cri, ni râle, ni bruit d'os (label Léger).
- **Téléphone d'abord :** rien d'important sous 150 Hz, le poids du Costaud et du Colosse passe entre 200 et 800 Hz. Chaque son a un double visuel : le jeu reste jouable en muet.
- **Fichiers :** `.ogg` mono pour les sons spatialisés, stéréo pour la musique seule. SFX à -16 LUFS, musique à -20 LUFS, crêtes à -1 dBTP. Upload au nom du groupe du studio, sinon le son reste muet en jeu.
- **Autorité serveur :** aucun `Sound` côté serveur. Le tir sonne tout de suite chez le tireur (cosmétique). Pièces, Gemmes, achat et jour franchi ne sonnent qu'à réception de `ReplicatedStorage.Remotes.Retour`, envoyé par le serveur après crédit.
- **Budget :** 16 voix simultanées, réparties par SoundGroup. Aucune boucle par Zbire.
- **`SoundService` :** `RespectFilteringEnabled = true`, `DopplerScale = 0`, `AmbientReverb = NoReverb` (Prairie) ou `Room` (Laboratoire). `ReplicatedStorage.Sons` est préchargé par `ContentProvider:PreloadAsync` avant la première horde.

## 2. SoundGroup et mixage

Les volumes se multiplient du parent à l'enfant.

| SoundGroup | Parent | Volume | Voix | Traitement |
|---|---|---|---|---|
| `Musique` | SoundService | 0,35 | 1 | `CompressorSoundEffect`, SideChain `Alertes`, Threshold -26, Ratio 8, Attack 0,02, Release 0,6 : la musique s'efface sous chaque alerte |
| `Ambiance` | SoundService | 0,45 | 2 | — |
| `SFX` | SoundService | 0,8 | — | `CompressorSoundEffect`, Threshold -14, Ratio 4, Attack 0,005, Release 0,12 : pas de saturation avec 60 Zbires |
| `Joueur` | SFX | 1,0 | 3 | — |
| `Zbires` | SFX | 0,6 | 4 | — |
| `Monde` | SFX | 0,85 | 3 | — |
| `Interface` | SoundService | 0,7 | 2 | — |
| `Alertes` | SoundService | 1,0 | 1 | — |

- **Groupe plein :** sa voix ponctuelle la plus ancienne est coupée ; `Zbires` abandonne plutôt le nouveau son.
- **Musique :** fondu croisé de 1,5 s (`TweenService`) entre Jour (120 BPM), Répit (90 BPM) et Colosse (140 BPM) ; Laboratoire à 100 BPM.
- **Paramètres :** curseurs Musique (multiplie `Musique.Volume`) et Effets (`SFX.Volume`, `Interface.Volume`), de 0 à 100 %.

## 3. Spatialisation

La caméra `Scriptable` est à 53 studs du Survivant : avec l'écouteur par défaut, l'arène sonnerait lointaine et plate. L'écouteur est placé sur le `HumanoidRootPart`, orienté comme la caméra (gauche de l'écran = oreille gauche), via `SoundService:SetListener(Enum.ListenerType.CFrame, …)` à chaque image. Un son spatialisé est parenté à un `Attachment` de `workspace.Terrain`, un son « Plat » à `SoundService`. Hors de portée, il n'est pas joué et n'occupe aucune voix.

| Profil | RollOffMode | RollOffMinDistance | RollOffMaxDistance | Usage |
|---|---|---|---|---|
| Plat | — | — | — | ses propres actions, interface, alertes, musique |
| Proche | `Linear` | 6 | 45 | autres Survivants, défenses, Capsules |
| Horde | `InverseTapered` | 10 | 70 | impacts et éclatements des Zbires |
| Lisiere | `InverseTapered` | 20 | 130 | portails : on entend de quel côté la horde arrive |
| Maison | `InverseTapered` | 15 | 150 | coups reçus par la Maison |
| Colosse | `Linear` | 40 | 250 | pas du Colosse, audibles dans toute l'arène |
| Mine | `Linear` | 4 | 24 | bourdonnement de la Mine |

## 4. Catalogue de la Prairie

### Actions

| Clé | Déclencheur | Groupe | Profil | Vol. | Variation / limite |
|---|---|---|---|---|---|
| `Tir` | son propre Blaster (tir automatique à 40 studs sur mobile) | Joueur | Plat | 0,45 | ±6 %, 1 toutes les 0,08 s |
| `TirAllie` | Blaster d'un autre Survivant | Monde | Proche | 0,25 | ±6 %, 1 toutes les 0,15 s |
| `TirExplosif` | Balles explosives | Joueur | Plat | 0,55 | ±5 % |
| `Saut` | saut | Joueur | Plat | 0,35 | glissando montant |
| `Reparation` | boucle tant qu'on répare | Joueur | Plat | 0,5 | « tink » 4 fois par seconde |
| `Pose` | Muret, Mini-Tourelle, Tapis Collant | Monde | Proche | 0,6 | hauteur 0,8, 1,0 ou 1,2 selon la défense |
| `TirTourelle` | Mini-Tourelle, Tourelle de toit | Monde | Proche | 0,3 | 1 toutes les 0,2 s |
| `Etourdi` | coup reçu, 2 s | Joueur | Plat | 0,6 | « boing » et étoiles |
| `Ping` | Roue des Pings, pour toute l'équipe | Interface | Plat | 0,8 | « Colosse ! » 3 notes graves, « Répare ! » 2 « tink », « Ici ! » 1 bip, « Merci ! » arpège montant |

### Zbires : une signature par silhouette

Impacts et éclatements : groupe `Zbires`, profil Horde, ±8 %, un éclatement toutes les 0,025 s au plus, au même tick que l'explosion de cubes.

| Zbire | Signature | Impact | Éclatement | PlaybackSpeed |
|---|---|---|---|---|
| Marcheur | — | « tok » | « pop » | 1,0 |
| Rapide | — | « tik » | « pip » | 1,3 |
| Costaud | — | « tonk », plus « shing » sur les piquants | « bloump » | 0,75 |
| Doré | clochette à l'apparition | « ting » | « pop » et cascade de clochettes | 1,1 |
| Sauteur | « boing » à chaque bond, 1 sur 3 au-delà de 4 Sauteurs | « tok » | « pop » | 1,15 |
| Gluant | — | « splotch » | double « splotch », puis 2 « plip » de Mini-Gluants (1,4) | 0,9 |
| Volant | une seule boucle `Volants` (Zbires, Plat), volume = min(nbVolants / 6, 1) × 0,4 | « tik » | « pop » aigu | 1,2 |
| Casqué | — | « clank » métallique (demi-dégâts), `Critique` sinon | « clank-pop » | 0,95 |
| Colosse | « BOUM » toutes les 0,8 s (Monde, profil Colosse) | « GONG » | fanfare de 3 s (Alertes) | 0,6 |

Le « clank » du Casqué, opposé au « ding » du critique, apprend la règle à l'oreille.

### Retours et récompenses

| Clé | Déclencheur | Groupe | Profil | Vol. | Détail |
|---|---|---|---|---|---|
| `Critique` | coup critique du tireur | Joueur | Plat | 0,6 | « ding » aigu par-dessus l'impact |
| `Pieces` | Pièces créditées | Interface | Plat | 0,45 | hauteur +0,05 par pièce ramassée moins de 0,6 s après la précédente, plafond 1,5 |
| `Gemme` | Gemme créditée (Doré, Mine) | Interface | Plat | 0,55 | cristal de 2 notes |
| `Achat` / `Refus` | réponse de l'Établi | Interface | Plat | 0,7 / 0,5 | caisse 8-bit / « bzzt » doux |
| `MaisonTouchee` | coup sur la Maison | Monde | Maison | 0,55 | 1 toutes les 0,25 s |
| `MaisonEtat` | passage à l'état 2 ou 3 | Alertes | Plat | 0,9 | craquement et 2 bips |
| `MaisonTombe` | fin de run | Alertes | Plat | 0,9 | jingle descendant doux de 3 s |
| `JourFranchi` | après l'`UpdateAsync` des Gemmes | Alertes | Plat | 0,9 | fanfare de 2 s |
| `Repit` / `Horde` | début et fin du Répit | Alertes | Plat | 0,8 | cloche montante / roulement de tambour |
| `ColosseArrive` | 3 s avant le Colosse | Alertes | Plat | 1,0 | cor grave, puis musique Colosse |
| `Portail` | ouverture d'un portail de la Lisière | Monde | Lisiere | 0,5 | « vwoom » violet |

### Ambiance

- `Prairie` (Ambiance, Plat, 0,5) : oiseaux 8-bit et brise pendant le Répit. Fondu de 2 s vers `Grouillement` pendant la horde, sur la même voix.
- `Grouillement` : volume = 0,1 + 0,4 × nbZbires / 60.
- `Mine` (Ambiance, profil Mine, 0,6) : bourdonnement cristallin.

## 5. Catalogue du Laboratoire (place distincte, 16 voix)

- `Machine` (Ambiance, `Linear` 3 / 14, 0,4) : une boucle par recherche d'Alcôve, seules les 4 plus proches jouent.
- `DocBoulon` (Interface, Plat, 0,35) : un « blip » par caractère de dialogue, hauteur 1,1 à 1,3. Pas de voix humaine.
- `Recherche` (Alertes, Plat, 0,8) : jingle à la confirmation serveur, puis « clonk » (Monde, Proche) à l'apparition de la machine.
- `Capsule` (Monde, Proche, 0,6) : un bip par seconde sur les 5 dernières des 15 s, puis « fshhh » au départ.
- `Figurine` (Zbires, `Linear` 4 / 16, 0,5) : signature du Zbire à moins de 8 studs, dans la Galerie des Zbires.
- `Foreuse` (Interface, Plat, 0,6) : pluie de gemmes au retour (production hors connexion).
- `RendezVous` (Alertes, Plat, 0,8) : carillon du Défi du Jour ; cloche générale le samedi à 17 h (Zbire de la Semaine).

## 6. Module client `ReplicatedStorage.Son`

Le serveur appelle `Remotes.Retour:FireClient(joueur, "Pieces")` après `solde += montant`. L'affichage des Zbires appelle `Son.Jouer("Eclatement", position, "Horde", 1.3)` avec le PlaybackSpeed du §4.

```lua
-- ReplicatedStorage.Son (ModuleScript), requis par un LocalScript de StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Son = {}
local modeles = ReplicatedStorage:WaitForChild("Sons") -- un Sound par clé, SoundId réglé dans Studio

local GROUPES = { -- nom, parent, volume, voix
	{ "Musique", nil, 0.35, 1 }, { "Ambiance", nil, 0.45, 2 }, { "SFX", nil, 0.8, 0 },
	{ "Joueur", "SFX", 1, 3 }, { "Zbires", "SFX", 0.6, 4 }, { "Monde", "SFX", 0.85, 3 },
	{ "Interface", nil, 0.7, 2 }, { "Alertes", nil, 1, 1 },
}
local PROFILS = { -- RollOffMode, min, max
	Proche = { Enum.RollOffMode.Linear, 6, 45 },
	Horde = { Enum.RollOffMode.InverseTapered, 10, 70 },
	Lisiere = { Enum.RollOffMode.InverseTapered, 20, 130 },
	Maison = { Enum.RollOffMode.InverseTapered, 15, 150 },
	Colosse = { Enum.RollOffMode.Linear, 40, 250 },
	Mine = { Enum.RollOffMode.Linear, 4, 24 },
}
local CATALOGUE = { -- groupe, volume, variation, intervalle mini (s) ; compléter depuis le §4
	Tir = { "Joueur", 0.45, 0.06, 0.08 },
	TirAllie = { "Monde", 0.25, 0.06, 0.15 },
	Eclatement = { "Zbires", 0.5, 0.08, 0.025 },
	Pieces = { "Interface", 0.45, 0, 0.03 },
	MaisonTouchee = { "Monde", 0.55, 0.05, 0.25 },
	JourFranchi = { "Alertes", 0.9, 0, 1 },
}

local groupes, voixMax, actives, dernierJeu = {}, {}, {}, {}
for _, g in GROUPES do
	local sg = Instance.new("SoundGroup")
	sg.Name, sg.Volume = g[1], g[3]
	sg.Parent = if g[2] then groupes[g[2]] else SoundService
	groupes[g[1]], voixMax[g[1]], actives[g[1]] = sg, g[4], {}
end

local function compresseur(sg, seuil, ratio, attaque, relache, source)
	local c = Instance.new("CompressorSoundEffect")
	c.Threshold, c.Ratio, c.Attack, c.Release, c.SideChain = seuil, ratio, attaque, relache, source
	c.Parent = sg
end
compresseur(groupes.SFX, -14, 4, 0.005, 0.12, nil)
compresseur(groupes.Musique, -26, 8, 0.02, 0.6, groupes.Alertes) -- ducking

local function retirer(nom: string, son: Sound)
	local i = table.find(actives[nom], son)
	if i then table.remove(actives[nom], i) end
	local ancre = son.Parent
	son:Destroy()
	if ancre and ancre:IsA("Attachment") then ancre:Destroy() end
end

local function libererVoix(nom: string): boolean
	local liste = actives[nom]
	if #liste < voixMax[nom] then return true end
	if nom == "Zbires" then return false end -- la horde ne coupe jamais une voix
	for _, son in liste do
		if not son.Looped then
			retirer(nom, son)
			return true
		end
	end
	return false
end

local positionEcoute = Vector3.zero
RunService:BindToRenderStep("EcouteurSurvivant", Enum.RenderPriority.Camera.Value + 1, function()
	local perso = Players.LocalPlayer.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if racine and camera then
		positionEcoute = racine.Position
		SoundService:SetListener(Enum.ListenerType.CFrame, CFrame.new(positionEcoute) * camera.CFrame.Rotation)
	end
end)

function Son.Jouer(cle: string, position: Vector3?, profil: string?, hauteur: number?): Sound?
	local def, modele = CATALOGUE[cle], modeles:FindFirstChild(cle)
	if not def or not modele then return nil end
	local p = profil and PROFILS[profil]
	if p and position and (position - positionEcoute).Magnitude > p[3] then return nil end
	local maintenant = os.clock()
	if maintenant - (dernierJeu[cle] or -math.huge) < def[4] or not libererVoix(def[1]) then return nil end
	dernierJeu[cle] = maintenant

	local son = modele:Clone()
	son.SoundGroup, son.Volume = groupes[def[1]], def[2]
	son.PlaybackSpeed = (hauteur or 1) * (1 + (math.random() * 2 - 1) * def[3])
	if p and position then
		son.RollOffMode, son.RollOffMinDistance, son.RollOffMaxDistance = p[1], p[2], p[3]
		local ancre = Instance.new("Attachment")
		ancre.Parent = workspace.Terrain
		ancre.WorldPosition = position
		son.Parent = ancre
	else
		son.Parent = SoundService
	end
	table.insert(actives[def[1]], son)
	son.Ended:Once(function() retirer(def[1], son) end)
	son:Play()
	return son
end

function Son.Arreter(son: Sound) -- pour les boucles (Reparation, Volants...)
	for nom, liste in actives do
		if table.find(liste, son) then
			retirer(nom, son)
			return
		end
	end
end

local combo, dernierePiece = 0, -math.huge
ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Retour").OnClientEvent:Connect(function(genre: string)
	if genre == "Pieces" then -- le serveur a déjà crédité le butin
		combo = if os.clock() - dernierePiece < 0.6 then math.min(combo + 1, 10) else 0
		dernierePiece = os.clock()
		Son.Jouer("Pieces", nil, nil, 1 + combo * 0.05)
	elseif CATALOGUE[genre] then
		Son.Jouer(genre)
	end
end)

return Son
```
