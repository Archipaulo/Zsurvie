## 1. Déplacement et caméra (3C)

Valeurs publiées dans `ReplicatedStorage.Config.Mouvement` (§8). **`GardienMouvement` (a29) est le seul script qui écrit `WalkSpeed`, `JumpHeight` et les états du `Humanoid`.** Le combat, la réparation et le Répit n'écrivent qu'un état dans `StatsSurvivant`. Le Gardien en déduit la vitesse, avec cette priorité : étourdi > réparation > Répit > horde.

| Réglage | Laboratoire | Prairie | Dans Roblox Studio |
|---|---|---|---|
| Vitesse | 16 | 18 en horde, 24 au Répit, 8 en réparation, 0 étourdi | `StarterPlayer.CharacterWalkSpeed` 16 / 18 ; le reste est appliqué par le Gardien |
| Saut | 7,2 studs | 0 (profil A) ou 5 (profil B, A/B de H2) | `CharacterUseJumpPower = false`, `CharacterJumpHeight` 7,2 / 0 ; en profil A, le Gardien désactive aussi `HumanoidStateType.Jumping` |
| Orientation | `AutoRotate = true` | face à la cible | `Humanoid.AutoRotate = false` ; le client tourne le `HumanoidRootPart` (lissage 0,08 s) |
| Mort | impossible | impossible | `BreakJointsOnDeath = false`, `SetStateEnabled(Enum.HumanoidStateType.Dead, false)` |
| Stick mobile | dynamique | dynamique | `DevTouchMovementMode = DynamicThumbstick` |
| Caméra | `Classic` | `Scriptable`, (0, 45, 28), `FieldOfView` 50 | `BindToRenderStep` à `Enum.RenderPriority.Camera.Value + 1`, lissage `1 - math.exp(-12 * dt)` |

- **A/B de H2 :** un profil par serveur réservé, jamais par joueur. Le serveur de la Prairie le tire à son démarrage (parité d'un hachage de `game.PrivateServerId`) et le journalise. Quand `JumpHeight = 0`, le bouton Saut tactile de Roblox disparaît de lui-même. Le profil gagnant est soumis à Victor Lanoue.
- **Repères à 18 studs/s :** de la Maison à la Lisière (70 studs) en 3,9 s ; le tour de la Maison à 2 studs des murs (80 studs) en 4,4 s. Aucun obstacle n'oblige à sauter, car les défenses se traversent (§6).
- **Ni sprint ni roulade :** c'est un bouton de moins sur téléphone. Le passage à 24 studs/s au Répit crée le « rush » vers l'Établi.
- **Champ visible (16:9) :** 41 studs devant, 22 derrière, 44 de chaque côté. Des chevrons au bord de l'écran signalent le hors-champ : violets pour un groupe de 3 Zbires ou plus à moins de 30 studs de la Maison, couleur Alerte pour le Colosse.
- **Écart soumis à Victor Lanoue :** tant que le Colosse est sur la Prairie, la caméra passe en 1 s à (0, 52, 32), puis revient à (0, 45, 28). Sans son accord, elle reste à (0, 45, 28).

## 2. Tir : le Blaster

| Statistique | Base | Par niveau | Plafond proposé |
|---|---|---|---|
| Dégâts | 10 | +2,5 (Établi) | 30 (niv. 8) |
| Cadence | 4 tirs/s | +0,4 (Établi) | 6 tirs/s (niv. 5) |
| Portée | 40 studs | +3 (Établi) | 52 studs (niv. 4) |
| Critique | 5 %, dégâts × 2 | +4 % (Visée critique) | 25 % |
| Balles explosives | — | 1 tir sur 4, puis 1 sur 3, puis 1 sur 2 | rayon 6 studs, 50 % des dégâts |
| Balles perforantes | — | +1 Zbire traversé, à 70 % des dégâts | 3 Zbires |

- **Autorité serveur :** le client envoie `DemandeTir(zbireId)`. Le serveur vérifie la cible, la distance horizontale (portée + 4 studs de tolérance réseau), la cadence (90 % de l'intervalle) et l'état : pas de tir si le Survivant est étourdi ou en train de réparer. Le projectile est cosmétique : cube Crème de 0,5 stud, 120 studs/s, pool de 40 par client, en `SmoothPlastic` pour ménager le quota de `Neon`.
- **Casqué :** il ne prend que la moitié des dégâts, sauf sur un critique. Le critique fait sauter son casque (effet visuel seul).
- **Tir automatique sur toutes les plateformes, activé par défaut :** il vise le Zbire *visible à l'écran* le plus proche dans le rayon. La cible change au plus toutes les 0,4 s, et un anneau orange au sol la marque.
- **Écart soumis à Victor Lanoue :** je propose que le rayon du tir auto suive la Portée (de 40 à 52 studs), sinon l'amélioration ne sert à rien sur téléphone. Sans son accord, le rayon reste fixé à 40 studs.

| Événement | Visuel | Son (chiptune) |
|---|---|---|
| Tir | flash Crème de 0,05 s, recul du Blaster (écrasement × 0,8 en 0,15 s) | « pew », pitch 0,95 à 1,05 ; tirs alliés à volume 0,2 |
| Impact | le Zbire vire au Crème 0,06 s et recule de 0,3 stud | « tic » |
| Critique | chiffre Or « CRIT ! », étirement × 1,2 | « ding » aigu |
| Casqué sans critique | étincelles Ardoise, « ½ » gris | « tonk » métallique |
| Élimination | éclatement en 8 cubes violets (0,6 s) puis pièces | « pop » puis « tling » |
| Explosion | sphère orange translucide de 6 studs pendant 0,2 s | « boum » court |

Chaque joueur ne voit les chiffres de dégâts que pour ses propres tirs (pool de 10 `BillboardGui`). Le `SoundGroup` « Tirs » est plafonné à 6 voix sur les 16 autorisées.

## 3. Étourdissement : on ne meurt jamais

- **Contact (vérifié par le serveur à 10 Hz) :** distance horizontale ≤ rayon du Zbire + 2 studs **et** écart vertical ≤ 4 studs. Un Volant qui passe plus haut n'étourdit pas.
- **Onde du Colosse :** rayon de 12 studs, annoncée 1,2 s avant par un disque Alerte au sol qui se remplit du centre vers le bord.
- **Effet :** pendant 2 s, le Survivant ne peut ni bouger, ni tirer, ni réparer, ni poser. Suivent 2 s d'invulnérabilité : au plus un étourdissement toutes les 4 s. `ServiceCombat.etourdir` n'écrit plus `WalkSpeed`. Il remplit seulement `etourdiJusqua`, `invulnerableJusqua` et `repare = false`, et le Gardien applique la vitesse 0.
- **Recul :** 6 studs à l'opposé de la source, appliqué par le client (`ApplyImpulse` sur le `HumanoidRootPart`), qui possède son personnage sur le réseau.
- **Retour :** 3 étoiles Or tournent au-dessus de la tête, avec un « boing » descendant. Le joueur touché, et lui seul, ressent une secousse caméra de 0,4 stud et une vibration manette (`HapticService:SetMotor`, `Enum.VibrationMotor.Large`, 0,4 pendant 0,15 s). Pendant l'invulnérabilité, il clignote (`Transparency` 0 ↔ 0,5 toutes les 0,1 s).

## 4. Collecte

Les règles et les chiffres viennent de `ReplicatedStorage.Partage` (a07, Mine commune de a06). Je retire mon stock de 10 gemmes, ma cadence de 30 s et le rapatriement de 100 % des pièces. Cette section ne fixe que le ressenti.

**Pièces (butin instancié)**
- Chaque Zbire vaincu lâche des pièces pour chaque Survivant : même valeur pour tous, aucun bonus au dernier coup, aucun vol possible. Chaque client ne voit que les siennes.
- 1 à 5 cubes Or de 0,8 stud sont éjectés dans un rayon de 3 studs, avec un rebond élastique.
- **Aimant serveur (8 studs, Partage) :** le client n'envoie rien. Il anime seulement le vol des pièces vers le joueur, en 0,2 s. L'amélioration Butin augmente la valeur, pas le rayon.
- **Début du Répit :** le reliquat crédité par Partage file en ruban vers le joueur (0,6 s). Le compteur affiche alors « +X » en gris, pour le distinguer de l'Or du ramassage à la main : l'enfant voit que courir rapporte plus. Les pièces non créditées rapetissent et s'effacent en 0,3 s, sans son de perte.
- **Retour :** le compteur pulse (× 1,2). Le « tling » monte d'un demi-ton par pièce enchaînée en moins de 0,5 s (+8 au maximum).
- Au-delà du pool client de 60 cubes (a28), 5 pièces fusionnent à l'écran en une grosse pièce. La valeur côté serveur reste exacte.

**Gemmes**
- **Mine commune :** dès qu'un Survivant la touche, le serveur crédite toute l'équipe. Chaque client voit les gemmes jaillir de la Mine vers son propre compteur, sous le `DisplayName` de celui qui l'a touchée : un geste d'équipe, sans chat.
- **Retour :** son « cristal », compteur cyan dans le HUD.

## 5. Réparation

- Possible à 14 studs au plus du centre de la Maison, mesurés à l'horizontale (6 studs devant les murs), sauf pendant un étourdissement. Vitesse de 8 studs/s tant que l'on répare.
- Le client envoie `DemandeReparation(true)`, puis `(false)`. Le serveur compte des tranches de 0,5 s tenues sans interruption et crédite chacune au débit d'équipe de a07 (Partage). Une tranche interrompue (bouton lâché, sortie du rayon, étourdissement) ne rapporte rien. Le cumul illimité par Survivant est supprimé.
- **Retour :** un marteau Crème frappe une fois par tranche (toutes les 0,5 s, en phase avec le serveur), avec 3 étincelles. Un anneau de maintien se remplit sur le bouton. Le « tok » a un pitch qui suit les PV (0,8 à 1,2), et une barre de PV verte s'affiche au-dessus de la porte. La Maison change d'état visuel à 66 % et à 33 %.

## 6. Défenses

| Défense | Taille (studs) | PV | Règle |
|---|---|---|---|
| Muret | 8 × 3 × 2 | 150 × 1,15^(jour − 1) | Arrête les Zbires au sol, qui le frappent. Le Volant le survole et le Sauteur le franchit |
| Mini-Tourelle | 2 × 4 × 2 | 80 × 1,15^(jour − 1) | 50 % des dégâts du Blaster de son poseur (niveau de Dégâts compris, relu à chaque tir), 2 tirs/s, portée 25 studs, vise le Zbire le plus proche de la Maison, jamais de critique |
| Tapis Collant | 8 × 0,2 × 8 | indestructible | Zbires au sol ralentis de 50 %, Colosse de 20 %, Volant non affecté |

Les PV sont relevés au début de chaque jour, en gardant la même proportion. Les prix sont fixés par `Economie` (a07).

- **Collisions :** toutes les défenses sont dans le `CollisionGroup` `Defenses`, rendu non collidable avec `Survivants` (`PhysicsService:CollisionGroupSetCollidable`). Le Muret n'arrête que les Zbires simulés, par une règle du `Registre` et non par la physique : impossible de murer la Maison ou d'enfermer un coéquipier. **Retour :** quand un Survivant traverse un Muret, celui-ci passe à `Transparency` 0,4 pour ce joueur et ondule (× 0,8).
- **Quota de 3 :** la 4e pose est refusée. L'icône `PoseInterdite` s'affiche sur le fantôme avec un « bzzt » doux, et les 3 défenses du joueur clignotent en orange pendant 1 s pour montrer quoi reprendre. Rien n'est détruit. Le bouton Défenses affiche « 3/3 ».
- **Reprise :** maintenir le doigt 0,5 s sur une de ses défenses (un anneau Crème se remplit) envoie `DemandeReprise`. Le serveur vérifie que la défense appartient au joueur, puis `Economie` rend 50 % du prix payé (a07). La défense s'envole vers le Sac à dos en 0,3 s, avec un « +X » Or. *J'ai choisi un maintien de 0,5 s plutôt qu'un simple toucher : ainsi, un tap destiné à un Zbire ne reprend jamais une Mini-Tourelle.*
- **Fantôme :** il se place 6 studs devant le Survivant, dans sa dernière direction de déplacement (et non de visée, car la cible change), sur la grille de 4 studs alignée sur le centre de la Maison. Le Muret s'oriente tout seul tangent à la Maison : le bouton Pivoter disparaît. Le fantôme est orange à `Transparency` 0,5 si la pose est valide ; sinon il passe en couleur Alerte avec l'icône de la raison.
- **Un seul verdict :** le fantôme et le serveur appellent tous deux `Placement.verifier`. Cette fonction combine `Plan.posePermise` (a11 : zones interdites, distance maximale, chevauchement ; je ne fixe plus aucune de ces limites) et le refus de toute emprise qui touche un Survivant.
- La pose prend 0,5 s, avec une recharge de 3 s. Le serveur recalcule la cellule et l'orientation, puis revérifie le solde et le quota.
- **Retour de pose :** la défense tombe de 4 studs et s'écrase (× 0,8) à l'atterrissage, avec un « clonk » et une bouffée de 6 cubes Terre battue.

## 7. Contrôles

| Action | Mobile | PC | Manette (sur PC) |
|---|---|---|---|
| Se déplacer | stick dynamique | WASD (ZQSD en AZERTY), flèches | stick gauche |
| Sauter (Laboratoire ; Prairie en profil B) | bouton Saut de Roblox | Espace | `ButtonA` |
| Tirer | auto ; taper un Zbire le verrouille 3 s | auto ; clic gauche maintenu = Zbire le plus proche du curseur (5 studs) | auto ; stick droit (cône de 15°) + `ButtonR2` |
| Réparer | bouton contextuel maintenu | E maintenu | `ButtonX` maintenu |
| Défenses | bouton Défenses → 3 icônes → « Poser » ou « X » | 1 / 2 / 3, clic gauche pour poser, Échap pour annuler | croix gauche/haut/droite, `ButtonR2` pour poser, `ButtonB` pour annuler |
| Reprendre | maintien de 0,5 s sur sa défense | survol + R maintenu 0,5 s | `ButtonB` maintenu 0,5 s à moins de 8 studs, hors mode pose |
| Établi (< 8 studs) | bouton contextuel | F | `ButtonY` |
| Roue des Pings | bouton, puis glisser vers le secteur | G maintenu + souris | `ButtonL1` maintenu + stick droit |

- Les tailles, positions et espacements suivent la **maquette unique codée par a28** (60 px minimum, selon le canon). Mes tailles de boutons sont retirées.
- Les actions sont liées par `ContextActionService:BindAction` avec `createTouchButton = false` : les boutons tactiles sont les `ImageButton` de a28.
- **Roue des Pings :** « Colosse ! » (Alerte), « Répare ! » (Crème, marqueur sur la Maison), « Ici ! » (orange, aux pieds du joueur), « Merci ! » (Or, au-dessus de la tête). Chaque ping affiche un marqueur `BillboardGui` `AlwaysOnTop` pendant 6 s, avec un jingle de 3 notes. Anti-spam serveur : 3 pings en 5 s, puis 5 s de recharge.

## 8. Code

```lua
-- ReplicatedStorage.Config.Mouvement (ModuleScript)
-- Lu par GardienMouvement (a29), seul script qui écrit WalkSpeed et JumpHeight.
export type EtatSurvivant = { etourdi: boolean, repare: boolean, repit: boolean }

local Mouvement = {
	Laboratoire = table.freeze({ WalkSpeed = 16, UseJumpPower = false, JumpHeight = 7.2 }),
	Prairie = table.freeze({
		WalkSpeedHorde = 18,
		WalkSpeedRepit = 24,
		WalkSpeedReparation = 8,
		WalkSpeedEtourdi = 0,
		UseJumpPower = false,
		JumpHeight = 0, -- StarterPlayer.CharacterJumpHeight de la place Prairie
	}),
	-- A/B de H2 : un profil par serveur réservé, jamais par joueur
	ProfilsH2 = table.freeze({
		A = table.freeze({ JumpHeight = 0 }),
		B = table.freeze({ JumpHeight = 5 }),
	}),
}

-- Priorité : étourdi > réparation > Répit > horde
function Mouvement.vitessePrairie(etat: EtatSurvivant): number
	local p = Mouvement.Prairie
	if etat.etourdi then
		return p.WalkSpeedEtourdi
	elseif etat.repare then
		return p.WalkSpeedReparation
	elseif etat.repit then
		return p.WalkSpeedRepit
	end
	return p.WalkSpeedHorde
end

function Mouvement.sautPrairie(profil: string?): number
	local choix = Mouvement.ProfilsH2[profil or "A"] or Mouvement.ProfilsH2.A
	return choix.JumpHeight
end

return table.freeze(Mouvement)
```

```lua
-- ReplicatedStorage.Defenses.Placement (ModuleScript) : même code pour le fantôme et le serveur
local Players = game:GetService("Players")
local Plan = require(game:GetService("ReplicatedStorage").Plan) -- a11

local GRILLE, AVANCE = 4, 6
local Placement = {}
Placement.TAILLES = table.freeze({
	Muret = Vector3.new(8, 3, 2),
	MiniTourelle = Vector3.new(2, 4, 2),
	TapisCollant = Vector3.new(8, 0.2, 8),
})

-- Point visé : 6 studs devant, dans la dernière direction de déplacement
function Placement.devant(racine: Vector3, direction: Vector3): Vector3
	local plat = direction * Vector3.new(1, 0, 1)
	return racine + (if plat.Magnitude > 1e-3 then plat.Unit else Vector3.zAxis) * AVANCE
end

-- Cellule de la grille centrée sur la Maison ; LookVector vers l'extérieur, donc l'axe X (8 studs) du Muret est tangent
function Placement.cadre(position: Vector3): CFrame
	local centre = Plan.CENTRE_MAISON -- au niveau du sol
	local rel = position - centre
	local radial = Vector3.new(math.round(rel.X / GRILLE) * GRILLE, 0, math.round(rel.Z / GRILLE) * GRILLE)
	local p = centre + radial
	return if radial.Magnitude > 0 then CFrame.lookAt(p, p + radial) else CFrame.new(p)
end

function Placement.verifier(typeDefense: string, cadre: CFrame): (boolean, string?)
	local taille = Placement.TAILLES[typeDefense]
	if not taille then
		return false, "PoseInterdite"
	end
	local ok, raison = Plan.posePermise(typeDefense, cadre)
	if not ok then
		return false, raison
	end
	local persos = {}
	for _, joueur in Players:GetPlayers() do
		if joueur.Character then
			table.insert(persos, joueur.Character)
		end
	end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = persos
	local boite = Vector3.new(taille.X, 6, taille.Z)
	if #workspace:GetPartBoundsInBox(cadre + Vector3.new(0, 3, 0), boite, params) > 0 then
		return false, "SurvivantDessous"
	end
	return true, nil
end

return table.freeze(Placement)
```

```lua
-- ServerScriptService.Defenses.ServiceDefenses (ModuleScript, démarré par le Script de run)
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Placement = require(ReplicatedStorage.Defenses.Placement)
local Economie = require(ServerScriptService.Run.Economie) -- a07 : prix, débit, 50 % rendus
local Stats = require(ServerScriptService.Run.StatsSurvivant)
local Remotes = ReplicatedStorage.Remotes

local QUOTA, RECHARGE, TOLERANCE = 3, 3, 12 -- tolérance : 6 d'avance + 1 case + latence
local PV_BASE = { Muret = 150, MiniTourelle = 80 }
type Pose = { modele: Model, prix: number }
local poses: { [Player]: { Pose } } = {}
local dernierePose: { [Player]: number } = {}

local function grouper(racine: Instance, nom: string)
	for _, d in racine:GetDescendants() do
		if d:IsA("BasePart") then
			d.CollisionGroup = nom
		end
	end
end

local function retirer(liste: { Pose }, modele: Instance): Pose?
	for i, pose in liste do
		if pose.modele == modele then
			return table.remove(liste, i)
		end
	end
	return nil
end

local function surDemandePose(joueur: Player, typeDefense: unknown, position: unknown)
	if typeof(typeDefense) ~= "string" or typeof(position) ~= "Vector3" then return end
	local s, liste, t = Stats.obtenir(joueur), poses[joueur], os.clock()
	local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not s or not liste or not racine or t < s.etourdiJusqua then return end
	if t - (dernierePose[joueur] or 0) < RECHARGE then return end
	if #liste >= QUOTA then
		Remotes.PoseRefusee:FireClient(joueur, "PoseInterdite") -- rien n'est détruit
		return
	end
	local cadre = Placement.cadre(position)
	if ((cadre.Position - racine.Position) * Vector3.new(1, 0, 1)).Magnitude > TOLERANCE then return end
	local ok, raison = Placement.verifier(typeDefense, cadre)
	if not ok then
		Remotes.PoseRefusee:FireClient(joueur, raison)
		return
	end
	local prix = Economie.prixDefense(typeDefense)
	if not Economie.debiter(joueur, prix) then
		Remotes.PoseRefusee:FireClient(joueur, "SoldeInsuffisant")
		return
	end
	dernierePose[joueur] = t
	local modele = ServerStorage.Defenses[typeDefense]:Clone() :: Model
	modele:PivotTo(cadre)
	grouper(modele, "Defenses")
	modele:SetAttribute("Proprietaire", joueur.UserId)
	local base = PV_BASE[typeDefense]
	if base then
		modele:SetAttribute("PVMax", base * 1.15 ^ ((workspace:GetAttribute("Jour") or 1) - 1))
	end
	modele.Destroying:Once(function()
		retirer(liste, modele) -- Muret détruit par les Zbires : la place se libère
	end)
	table.insert(liste, { modele = modele, prix = prix })
	modele.Parent = workspace.Defenses
end

local function surDemandeReprise(joueur: Player, modele: unknown)
	local liste = poses[joueur]
	if not liste or typeof(modele) ~= "Instance" then return end
	local pose = retirer(liste, modele) -- nil si ce n'est pas l'une de ses défenses
	if not pose then return end
	local rendu = Economie.reprendreDefense(joueur, pose.prix) -- 50 % du prix payé (a07)
	Remotes.DefenseReprise:FireAllClients(joueur, pose.modele:GetPivot(), rendu)
	pose.modele:Destroy()
end

local ServiceDefenses = {}

function ServiceDefenses.demarrer()
	for _, nom in { "Survivants", "Defenses" } do
		if not PhysicsService:IsCollisionGroupRegistered(nom) then
			PhysicsService:RegisterCollisionGroup(nom)
		end
	end
	PhysicsService:CollisionGroupSetCollidable("Survivants", "Defenses", false)

	local function marquer(perso: Model)
		grouper(perso, "Survivants")
		perso.DescendantAdded:Connect(function(d)
			if d:IsA("BasePart") then
				d.CollisionGroup = "Survivants"
			end
		end)
	end
	local function suivre(joueur: Player)
		poses[joueur] = {}
		if joueur.Character then
			marquer(joueur.Character)
		end
		joueur.CharacterAdded:Connect(marquer)
	end
	Players.PlayerAdded:Connect(suivre)
	for _, joueur in Players:GetPlayers() do
		suivre(joueur)
	end
	Players.PlayerRemoving:Connect(function(joueur)
		local liste = poses[joueur] or {}
		poses[joueur], dernierePose[joueur] = nil, nil
		for _, pose in table.clone(liste) do
			pose.modele:Destroy()
		end
	end)
	Remotes.DemandePose.OnServerEvent:Connect(surDemandePose)
	Remotes.DemandeReprise.OnServerEvent:Connect(surDemandeReprise)
end

return ServiceDefenses
```
