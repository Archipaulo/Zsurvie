## Principes de l'accueil

- **L'accueil** court du premier spawn jusqu'à l'étape **PremiereRecherche**. Le serveur lit deux champs du profil, écrits par `Donnees.Modifier` : `RunsTerminees` (fin de run, a06) et `AccueilEtape` (module Onboarding).
  - `RunsTerminees == 0` : **novice de run**. Il a droit à l'ouverture scriptée et aux indices de la Prairie.
  - `AccueilEtape` < PremiereRecherche : `Player.AccueilActif` vaut true, et a33 n'affiche **aucune carte d'arrivée**.
- **3 gestes en 90 s : bouger, ramasser, acheter.** Le tir est automatique (40 studs). On apprend à réparer, poser un Muret et pinguer au premier besoin.
- **Zéro mot** : pictogrammes, couleurs de `ReplicatedStorage.Charte`, sons 8-bit. Les chiffres restent permis.
- **Caméras** : au Laboratoire, `Custom` pour tous (arbitrage a11, **à valider par Victor Lanoue**) ; les dalles et l'hologramme de Doc Boulon guident. Sur la Prairie, caméra de run : `Scriptable`, (0, 45, 28), `FieldOfView` 50.
- **Écran de la Prairie** (téléphone en paysage) : bord haut ≈ 41 studs devant le Survivant, bord bas ≈ 22 derrière, côtés ≈ 44-49. Depuis le Parvis, la Maison masque le chemin Nord et le Sud tombe sous le bord bas. Les premiers Zbires viennent donc **par l'Est, puis par l'Ouest**.

## Les 90 premières secondes

T = apparition au Laboratoire. A = atterrissage (≈ T 28, T 30 au pire). H = A + 20 : début de la horde du Jour 1 (a06). Le Marcheur avance à 8 studs/s et tombe en 3 tirs. Avec la cadence de `ReplicatedStorage.Partage.BlasterStats` (4 tirs/s), il éclate 0,5 s après être entré dans l'anneau.

| T | Ce que vit le novice | Mise en œuvre |
|---|---|---|
| 0 | Il apparaît sur `SpawnNovice`, face à la Capsule Normale, à 12 studs. L'hologramme cyan de Doc Boulon salue, une bulle montre le picto « Capsule », jingle de 1 s | `CharacterAutoLoads` = false. `Onboarding.enregistrer` règle `RespawnLocation`, puis le chargeur appelle `LoadCharacter()` |
| 1-5 | 6 dalles cyan s'allument en cascade jusqu'à la porte. S'il est immobile à T 3 : joystick fantôme | Parts `Neon` 4 × 0,2 × 4, `Transparency` 1 par défaut, décalage de 0,15 s |
| 5-20 | Il monte, la porte se ferme en élastique. 15 LED s'éteignent ; l'écran boucle 3 pictos de 4 s : courir ; un Zbire entre dans le cercle et éclate en pièces ; pièces → Établi → Blaster plus gros | `MonteeCapsule`. `SurfaceGui`. S'il n'est pas monté à T 15 : Doc Boulon pointe, dalles 2 × plus lumineuses |
| 20-28 | Secousse de 0,5 s (0,3 stud au plus), tunnel cyan | `TeleportService:SetTeleportGui`, repris dans le `ReplicatedFirst` de la Prairie jusqu'à `game:IsLoaded()`. 10 s au plus sur Android 3 Go |
| A | La Capsule se pose sur le SpawnLocation du Parvis (Plan v1 : (−3 ; 0,5 ; 16)) et redécolle (règle des 6 studs). La Maison est en haut de l'écran, l'Établi à 9 studs à gauche. À A+1, un anneau crème de 40 studs montre la portée. À A+3, joystick fantôme s'il est immobile depuis 2 s | `ArriveePrairie`. Le HUD affiche la phase Arrivée (a06) |
| A+17 | Le portail Est (x = +72) s'illumine ; chevron violet au bord droit, « bloup » | Client |
| H+3 ≈ T 51 | Le Marcheur 1, réservé, sort du portail Est | `Onboarding.OUVERTURE`, `Onboarding.reserver` |
| H+8 ≈ T 56 | Il entre dans l'anneau vers x = +34 : réticule, 3 tirs. **Il éclate en cubes violets et lâche 2 Pièces : première récompense avant T 60** (T 58 au pire) | Serveur → `PremierZbire` |
| H+8-27 | Les Pièces rebondissent puis, à 8 studs, volent vers le compteur (× 1,2), avec un « ding » qui monte d'un demi-ton. Les Marcheurs 2 à 6 viennent de l'Est, les Marcheurs 7 à 13 de l'Ouest : les chevrons de gauche ramènent le novice près de l'Établi | `PlaybackSpeed` × 1,06 par pièce |
| ≈ T 79 | 25e Pièce (13e Marcheur) : balise or sur l'Établi, flèche or au bord de l'écran s'il est hors champ | Serveur : `solde >= Economie.prixEtabli('Degats', 1)` |
| ≈ T 81 | À 10 studs de l'Établi (`Plan.ETABLI`, (−12 ; 14)), un panneau s'ouvre en bas de l'écran, main or sur la carte Dégâts. Après l'achat : Blaster × 1,2, balles × 1,3, fanfare de 1,5 s, l'anneau s'efface en 3 s | L'Établi vérifie le solde et la distance → `PremierAchatEtabli` |

Le Jour 1 continue jusqu'à H+80, puis vient le Répit. Le 13e Marcheur part à H+27, et non à H+30, pour que l'achat tombe vers T 80. En groupe, les 11 Marcheurs non réservés se partagent : l'achat peut glisser après T 90, et la balise attend simplement le solde.

**Écart soumis à Victor Lanoue** : les 2 Marcheurs `ReservePour` échappent au multiplicateur coopératif de PV. Ni les Mini-Tourelles, ni la Tourelle de toit, ni les autres Survivants ne les visent. S'ils ne sont pas éliminés 20 s après leur apparition, l'attribut tombe : la Maison n'est jamais sacrifiée.

## Indices sans texte

| Indice | Message | Disparaît |
|---|---|---|
| Dalles cyan en cascade (Quai, puis Voie d'arrivée → pupitre) | « Va là. » | À la montée ; à la 1re recherche |
| Hologramme de Doc Boulon, bulle picto | « C'est ici. » | Au départ ; à la 1re recherche |
| Joystick fantôme (main de 80 px, aller-retour en 0,8 s) | « Glisse ton pouce. » | Au premier `MoveDirection` non nul |
| Anneau crème, `Transparency` 0,6 | « Ta portée. » | Au premier achat, ou à H+45 |
| Chevron violet de 60 px au bord de l'écran | « Un Zbire arrive par là. » | Jamais (visible par tous) |
| Réticule crème 3 × 3, 90° par seconde ; Pièces qui rebondissent (0,6 s) | « Je tire. » ; « Ramasse. » | Jamais |
| Balise et flèche or de l'Établi | « Dépense ici. » | Au premier achat |
| Main or de 72 px sur l'élément nommé par `AccueilCible` | « Celle-là. » | Au premier achat ; à la 1re recherche |

**Après les 90 s**, un seul indice à la fois :
- **Maison touchée** (seulement après le premier achat) : icône clé au-dessus de la façade, le bouton Réparer (96 px) pulse.
- **Premier Répit** : fantôme de Muret au sol, **le bouton Muret pulse**.
- **Premier Colosse** : **le bouton Ping pulse 2 s avec l'icône `PingColosse`**. La Roue des Pings ne s'ouvre jamais seule, et le ping « Colosse ! » part déjà automatiquement (a14).
- **Chaque étourdissement** : 3 étoiles or tournent pendant 2 s (Combat), pour montrer qu'on ne meurt jamais.

## Retour au Laboratoire : jusqu'à PremiereRecherche

1. Le joueur arrive sur la Voie d'arrivée (0, −55). `AccueilActif` vaut true : aucune carte d'arrivée de a33.
2. 10 dalles cyan s'allument en cascade jusqu'au pupitre de l'Arbre des Recherches et restent allumées. L'hologramme de Doc Boulon attend au pupitre et pointe l'arbre.
3. Dans l'arbre, seul le nœud Tourelle de toit est allumé, et la main or le pointe (`AccueilCible` = "TourelleDeToit").
4. Une fois la recherche validée par le serveur → `PremiereRecherche`. Dalles et hologramme s'éteignent, la machine apparaît dans l'Alcôve, puis les dalles du Quai guident 10 s vers la Capsule Normale. Les cartes de a33 reviennent à l'arrivée suivante.

Condition : la Tourelle de toit doit coûter moins que les gemmes d'une première run perdue au Jour 1 (a07).

## Accessibilité

- Chaque couleur a sa forme : pièce = disque, gemme = losange, danger = triangle, ennemi = contour violet.
- Chaque son a un équivalent visuel, car beaucoup d'enfants jouent téléphone en silencieux.
- Un seul bouton contextuel de 96 px à la fois, sous le pouce droit. Partout ailleurs, 60 px minimum.
- 3 flashs par seconde au maximum (pulse de 0,5 s) ; les secousses ne dépassent pas 0,3 stud.

## Serveur : module `Onboarding`

`ServerScriptService.Onboarding` est commun au Laboratoire et à la Prairie. Il n'accorde rien et n'appelle jamais `AnalyticsService` : ses jalons portent les noms de l'entonnoir de a50, et c'est `Telemetrie` qui les numérote.

```lua
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Donnees = require(ServerScriptService:WaitForChild("Donnees"))
local Telemetrie = require(ServerScriptService:WaitForChild("Telemetrie"))
local Economie = require(ReplicatedStorage:WaitForChild("Partage"):WaitForChild("Economie"))
local IndiceOnboarding = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("IndiceOnboarding") :: RemoteEvent

local PRIX_PREMIER_ACHAT: number = Economie.prixEtabli("Degats", 1) -- 25 Pièces (a07)
local DELAI_RESERVE = 20 -- s, puis le Marcheur redevient une cible pour tous
local PARCOURS = { "Laboratoire", "MonteeCapsule", "ArriveePrairie", "PremierZbire",
	"PremierAchatEtabli", "FinJour1", "PremiereRecherche" } -- étapes a50
local RANG: { [string]: number } = {}
for i, nom in PARCOURS do RANG[nom] = i end
local FIN = RANG.PremiereRecherche

type Profil = { RunsTerminees: number, AccueilEtape: number? }
type Etat = { runs: number, rang: number, vus: { [string]: boolean } }

local Onboarding = {}
local suivis: { [Player]: Etat } = {}
local tour = 0

-- t = secondes après H (début de la horde du Jour 1), joué par le Directeur si aDesNovices()
Onboarding.OUVERTURE = table.freeze({
	{ t = 3, chemin = "Est", reserve = true }, { t = 5, chemin = "Est", reserve = true },
	{ t = 7, chemin = "Est" }, { t = 9, chemin = "Est" }, { t = 11, chemin = "Est" }, { t = 13, chemin = "Est" },
	{ t = 15, chemin = "Ouest" }, { t = 17, chemin = "Ouest" }, { t = 19, chemin = "Ouest" },
	{ t = 21, chemin = "Ouest" }, { t = 23, chemin = "Ouest" }, { t = 25, chemin = "Ouest" },
	{ t = 27, chemin = "Ouest" },
})

local function franchir(joueur: Player, nom: string)
	local etat, rang = suivis[joueur], RANG[nom]
	if not etat or rang <= etat.rang then return end -- une fois, jamais en arrière
	etat.rang = rang
	Donnees.Modifier(joueur, "AccueilEtape", function(ancien: number?): number
		return math.max(ancien or 0, rang)
	end)
	Telemetrie.Etape(joueur, nom)
end

local function novice(joueur: Player): Etat?
	local etat = suivis[joueur]
	return if etat and etat.runs == 0 then etat else nil
end

function Onboarding.enregistrer(joueur: Player, profil: Profil, place: "Laboratoire" | "Prairie")
	local rang = profil.AccueilEtape or 0 -- appelé avant LoadCharacter()
	joueur:SetAttribute("AccueilActif", rang < FIN) -- a33 : aucune carte tant que vrai
	if rang >= FIN then return end
	suivis[joueur] = { runs = profil.RunsTerminees, rang = rang, vus = {} }
	if place == "Prairie" then
		if profil.RunsTerminees > 0 then return end
		franchir(joueur, "ArriveePrairie")
		IndiceOnboarding:FireClient(joueur, "Arrivee")
	elseif profil.RunsTerminees == 0 then
		joueur.RespawnLocation = workspace:FindFirstChild("SpawnNovice") :: SpawnLocation?
		franchir(joueur, "Laboratoire")
		IndiceOnboarding:FireClient(joueur, "Quai")
	else
		joueur:SetAttribute("AccueilCible", "TourelleDeToit")
		IndiceOnboarding:FireClient(joueur, "Recherche")
	end
end

function Onboarding.aDesNovices(): boolean
	for joueur in suivis do
		if novice(joueur) then return true end
	end
	return false
end

function Onboarding.reserver(zbire: Model) -- Directeur, entrées reserve = true
	local ids = {}
	for joueur in suivis do
		if novice(joueur) then table.insert(ids, joueur.UserId) end
	end
	if #ids == 0 then return end
	table.sort(ids)
	tour += 1
	zbire:SetAttribute("ReservePour", ids[(tour - 1) % #ids + 1]) -- à tour de rôle
	task.delay(DELAI_RESERVE, function()
		if zbire.Parent then zbire:SetAttribute("ReservePour", nil) end
	end)
end

function Onboarding.surMontee(joueur: Player) -- Quai : montée validée
	if novice(joueur) then franchir(joueur, "MonteeCapsule") end
end

function Onboarding.surElimination(joueur: Player) -- Combat : élimination validée
	if novice(joueur) then franchir(joueur, "PremierZbire") end
end

function Onboarding.surSolde(joueur: Player, solde: number) -- Économie : après chaque gain
	local etat = novice(joueur)
	if etat and not etat.vus.Etabli and solde >= PRIX_PREMIER_ACHAT then
		etat.vus.Etabli = true
		joueur:SetAttribute("AccueilCible", "Degats")
		IndiceOnboarding:FireClient(joueur, "Etabli")
	end
end

function Onboarding.surAchat(joueur: Player) -- Établi : débit validé
	local etat = novice(joueur)
	if not etat or etat.vus.Achat then return end
	etat.vus.Achat, etat.vus.Etabli = true, true
	franchir(joueur, "PremierAchatEtabli")
	joueur:SetAttribute("AccueilCible", nil)
	IndiceOnboarding:FireClient(joueur, "Fin")
end

function Onboarding.surJourFranchi(jour: number) -- a06
	if jour ~= 1 then return end
	for joueur in suivis do
		if novice(joueur) then franchir(joueur, "FinJour1") end
	end
end

function Onboarding.surEvenementRun(evenement: string) -- a06 : "MaisonTouchee", "Repit", "Colosse"
	for joueur, etat in suivis do
		local pret = evenement ~= "MaisonTouchee" or etat.vus.Achat == true -- la clé attend l'achat
		if etat.runs == 0 and pret and not etat.vus[evenement] then
			etat.vus[evenement] = true
			IndiceOnboarding:FireClient(joueur, evenement)
		end
	end
end

function Onboarding.surRecherche(joueur: Player) -- Recherches : recherche validée et payée
	if not suivis[joueur] then return end
	franchir(joueur, "PremiereRecherche")
	joueur:SetAttribute("AccueilCible", nil)
	joueur:SetAttribute("AccueilActif", false)
	IndiceOnboarding:FireClient(joueur, "FinAccueil")
	suivis[joueur] = nil
end

Players.PlayerRemoving:Connect(function(joueur)
	suivis[joueur] = nil
end)

return Onboarding
```

## Client : `StarterPlayerScripts.IndicesOnboarding`

Ce LocalScript ne fait que de l'affichage. La main or et la flèche hors champ relèvent du HUD.

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Charte = require(ReplicatedStorage:WaitForChild("Charte"))

local joueur = Players.LocalPlayer
local IndiceOnboarding = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("IndiceOnboarding")
local ICONE_PING_COLOSSE = "rbxassetid://0" -- PingColosse, livrée par l'UI
local PORTEE = 40 -- tir automatique (canon)
local anneau, suivi

local function hud(nom)
	local gui = joueur.PlayerGui:FindFirstChild("HUD")
	return gui and gui:FindFirstChild(nom, true)
end

local function dalles(dossier, allumer)
	local liste = workspace:WaitForChild("DallesAccueil"):WaitForChild(dossier):GetChildren()
	table.sort(liste, function(a, b) return tonumber(a.Name) < tonumber(b.Name) end)
	for i, dalle in liste do
		task.delay(if allumer then 0.15 * i else 0, function()
			dalle.Transparency = if allumer then 0 else 1
		end)
	end
end

local function joystickFantome()
	local humanoide = (joueur.Character or joueur.CharacterAdded:Wait()):WaitForChild("Humanoid")
	task.wait(2)
	local main = hud("JoystickFantome")
	if not main or humanoide.MoveDirection.Magnitude > 0 then return end
	main.Visible = true
	humanoide:GetPropertyChangedSignal("MoveDirection"):Once(function() main.Visible = false end)
end

local function balise(actif)
	local b = workspace:FindFirstChild("Etabli") and workspace.Etabli:FindFirstChild("Balise")
	for _, objet in (b and b:GetDescendants() or {}) do
		if objet:IsA("ParticleEmitter") or objet:IsA("BillboardGui") then objet.Enabled = actif end
	end
end

local function pulser(nom, duree, icone)
	local bouton = hud(nom)
	if not bouton then return end
	local echelle = bouton:FindFirstChildOfClass("UIScale")
	if not echelle then
		echelle = Instance.new("UIScale")
		echelle.Parent = bouton
	end
	local image = bouton.Icone.Image
	bouton.Icone.Image = icone or image
	local info = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(echelle, info, { Scale = 1.15 })
	tween:Play()
	task.delay(duree, function()
		tween:Cancel()
		echelle.Scale = 1
		bouton.Icone.Image = image
	end)
end

local function effacerAnneau()
	local p = anneau
	if not p then return end
	anneau = nil
	local tween = TweenService:Create(p.Decal, TweenInfo.new(3), { Transparency = 1 })
	tween.Completed:Once(function()
		suivi:Disconnect()
		p:Destroy()
	end)
	tween:Play()
end

local function montrerAnneau()
	local p = Instance.new("Part")
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.Transparency = true, false, false, false, 1
	p.Size = Vector3.new(PORTEE * 2, 0.1, PORTEE * 2)
	local d = Instance.new("Decal")
	d.Face, d.Color3, d.Transparency = Enum.NormalId.Top, Charte.Creme, 0.6
	d.Texture = "rbxassetid://0" -- anneau de 512 px, livré par l'UI
	d.Parent = p
	p.Parent = workspace
	anneau = p
	suivi = RunService.RenderStepped:Connect(function()
		local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
		if racine then p.CFrame = CFrame.new(racine.Position.X, 0.06, racine.Position.Z) end
	end)
	task.delay(65, effacerAnneau) -- A+65 = H+45 au plus tard
end

local ACTIONS = {
	Quai = function() dalles("Quai", true); joystickFantome() end,
	Recherche = function() dalles("Recherches", true) end,
	FinAccueil = function()
		dalles("Recherches", false)
		dalles("Quai", true)
		task.delay(10, dalles, "Quai", false)
	end,
	Arrivee = function() montrerAnneau(); joystickFantome() end,
	Etabli = function() balise(true) end,
	Fin = function() balise(false); effacerAnneau() end,
	MaisonTouchee = function() pulser("Reparer", 4) end,
	Repit = function() pulser("Muret", 4) end,
	Colosse = function() pulser("Ping", 2, ICONE_PING_COLOSSE) end,
}

IndiceOnboarding.OnClientEvent:Connect(function(indice)
	local action = ACTIONS[indice]
	if action then task.spawn(action) end
end)
```

## Les 3 mesures

| Mesure | Source | Cible | Alerte |
|---|---|---|---|
| **Entonnoir d'accueil** | Les 12 étapes de a50 via `Telemetrie`, dont les 7 jalons ci-dessus | Parmi les joueurs arrivés sur la Prairie : ≥ 85 % atteignent PremierZbire (80 % avant T 60), ≥ 65 % PremierAchatEtabli, ≥ 50 % PremiereRecherche | Plus de 10 points perdus entre deux jalons |
| **Taux de 2e run** | Joueurs qui remontent en Capsule dans la même session, après PremiereRecherche (a50) | ≥ 55 % | Sous 45 % : revoir le retour au Laboratoire |
| **Rétention J1 et J7** | Objectifs de a50, nouveaux joueurs, par plateforme | J1 ≥ 22 %, J7 ≥ 8 % | Téléphone 5 points sous le PC : problème de lisibilité mobile |
