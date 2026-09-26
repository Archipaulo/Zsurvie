-- ServerScriptService.Securite.GardienMouvement (ModuleScript)
--!strict
-- Seul script qui écrit WalkSpeed et JumpHeight (valeurs de ReplicatedStorage.Config.Mouvement, a09).
-- Contrôle 4 fois par seconde la position répliquée de chaque Survivant : budget de distance, zone de jeu,
-- volumes interdits et vol. Corrige d'abord, signale ensuite. Le require ne bloque jamais : la racine de
-- la carte (ReplicatedStorage.Plan.RACINE, a11) se résout en tâche de fond, 10 s au plus.
-- Tags lus : ZoneInterdite, ZoneJouable (Laboratoire), ZoneGlisse, PointDeblocage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local CollectionService = game:GetService("CollectionService")

local Validation = require(script.Parent.Validation)

local PERIODE = 0.25 -- s entre deux contrôles
local MARGE = 1.2 -- tolérance de vitesse (latence mobile)
local BUDGET_S = 2.5 -- secondes de course accumulables (gel réseau)
local ETOURDI_S = 2 -- canon : un coup étourdit 2 s
local ETOURDI_BUDGET_S = 1 -- course tolérée le temps que WalkSpeed 0 aille au client et revienne
local TRANSITION_S = 1 -- une baisse de vitesse n'est exigée qu'après 1 s (réplication)
local LATENCE_S = 0.5 -- ajoutée à toute fenêtre d'envol
local ENVOL_MAX_S = 5
local VITESSE_LIBRE = 70 -- studs/s tolérés en envol et en ZoneGlisse
local SOL_MAX = 6 -- studs racine -> sol au-delà desquels on est « en l'air »
local MARGE_SAUT = 6 -- saut depuis un Muret : rien ne dépasse 6 studs près de la Maison
local AIR_MAX = 1.2 -- s en l'air, hors chute, avant correction
local RAYON_SOL = 160 -- rien touché = sol introuvable, jamais une faute
local ALTITUDE_MAX = 150 -- studs au-dessus de CentrePlace : vol, même sans sol
local MARGE_BARRIERE = 4 -- RayonPlace = Plan.RAYON_BARRIERE + 4 (76 sur la Prairie)
local RAYON_GRIMPE = 3 -- Climbing n'est cru qu'à 3 studs d'une Part collidable
local IMMOBILE_S = 2 -- DemandeDeblocage : immobile depuis 2 s

local function lireMouvement(): { [string]: any }
	local config = ReplicatedStorage:FindFirstChild("Config")
	local module = config and config:FindFirstChild("Mouvement")
	if module and module:IsA("ModuleScript") then
		local ok, valeurs = pcall(require, module)
		if ok and type(valeurs) == "table" then
			return valeurs
		end
	end
	warn("[AntiExploit] ReplicatedStorage.Config.Mouvement illisible : valeurs de StarterPlayer utilisées")
	return {}
end

local Mouvement = lireMouvement()
local VITESSE_BASE: number = tonumber(Mouvement.WalkSpeed) or StarterPlayer.CharacterWalkSpeed
local SAUT: number = tonumber(Mouvement.JumpHeight) or StarterPlayer.CharacterJumpHeight

type Suivi = {
	derniere: Vector3?,
	budget: number,
	vitesse: number,
	vitessePrecedente: number,
	transitionJusqua: number,
	grace: number,
	air: number,
	etourdiJusqua: number,
	envolJusqua: number,
	ancre: Vector3?,
	ancreT: number,
	corrections: number,
}

local GardienMouvement = {}
local suivis: { [Player]: Suivi } = {}
local vitesseCourante = VITESSE_BASE -- appliquée aux Survivants qui arrivent en cours de run

local typePlace = workspace:GetAttribute("TypePlace")
local centre: Vector3 = workspace:GetAttribute("CentrePlace") or Vector3.zero
local rayonPlace: number? = nil
local racineCarte: Instance? = nil
local racineResolue = false
local enAttente: { thread } = {}

local parametres = RaycastParams.new()
parametres.FilterType = Enum.RaycastFilterType.Include
local parametresGrimpe = OverlapParams.new()
parametresGrimpe.FilterType = Enum.RaycastFilterType.Exclude
parametresGrimpe.RespectCanCollide = true
parametresGrimpe.MaxParts = 1

local function suivi(joueur: Player): Suivi
	local s = suivis[joueur]
	if not s then
		s = {
			derniere = nil,
			budget = vitesseCourante * BUDGET_S,
			vitesse = vitesseCourante,
			vitessePrecedente = vitesseCourante,
			transitionJusqua = 0,
			grace = 0.5,
			air = 0,
			etourdiJusqua = 0,
			envolJusqua = 0,
			ancre = nil,
			ancreT = os.clock(),
			corrections = 0,
		}
		suivis[joueur] = s
	end
	return s
end

local function vitesseEffective(s: Suivi, t: number): number
	return if t < s.transitionJusqua then math.max(s.vitesse, s.vitessePrecedente) else s.vitesse
end

local function plafond(s: Suivi, v: number, t: number): number
	return if t < s.etourdiJusqua then v * ETOURDI_BUDGET_S else v * BUDGET_S
end

local function humanoideDe(joueur: Player): Humanoid?
	local personnage = joueur.Character
	return if personnage then personnage:FindFirstChildOfClass("Humanoid") else nil
end

-- Seule écriture de WalkSpeed et JumpHeight du jeu.
local function appliquer(joueur: Player, s: Suivi)
	local h = humanoideDe(joueur)
	if h then
		local etourdi = os.clock() < s.etourdiJusqua
		h.UseJumpPower = false
		h.WalkSpeed = if etourdi then 0 else s.vitesse
		h.JumpHeight = if etourdi then 0 else SAUT
	end
end

local function dansVolume(tag: string, pos: Vector3, marge: number, ignorerY: boolean): boolean
	for _, part in CollectionService:GetTagged(tag) do
		if part:IsA("BasePart") then
			local p = part.CFrame:PointToObjectSpace(pos)
			local demi = part.Size / 2 + Vector3.one * marge
			if math.abs(p.X) <= demi.X and math.abs(p.Z) <= demi.Z and (ignorerY or math.abs(p.Y) <= demi.Y) then
				return true
			end
		end
	end
	return false
end

-- Prairie : disque de RayonPlace (76). Laboratoire : union des Parts ZoneJouable (a11), 2 studs de marge.
local function horsZone(pos: Vector3): boolean
	if typePlace == "Laboratoire" then
		return #CollectionService:GetTagged("ZoneJouable") > 0 and not dansVolume("ZoneJouable", pos, 2, true)
	end
	local r = rayonPlace
	return r ~= nil and Vector3.new(pos.X - centre.X, 0, pos.Z - centre.Z).Magnitude > r
end

-- L'état Climbing vient du client : il n'est cru que contre une Part collidable (Grimpe du Colosse, échelle).
local function grimpe(h: Humanoid, personnage: Model, pos: Vector3): boolean
	if h:GetState() ~= Enum.HumanoidStateType.Climbing then
		return false
	end
	parametresGrimpe.FilterDescendantsInstances = { personnage }
	return #workspace:GetPartBoundsInRadius(pos, RAYON_GRIMPE, parametresGrimpe) > 0
end

local function corriger(joueur: Player, personnage: Model, racine: BasePart, s: Suivi, raison: string, points: number)
	local t = os.clock()
	racine.AssemblyLinearVelocity = Vector3.zero
	personnage:PivotTo(CFrame.new(s.derniere or racine.Position) * racine.CFrame.Rotation)
	s.budget = plafond(s, vitesseEffective(s, t), t)
	s.air = 0
	s.grace = 0.5 -- le temps que la correction atteigne le client
	s.corrections += 1
	Validation.signaler(joueur, points, raison) -- 0 point : correction seule
end

-- Seule téléportation serveur autorisée (arrivée, sauvetage, Capsule, déblocage) : sinon le gardien la corrige.
function GardienMouvement.teleporter(joueur: Player, cible: CFrame)
	local s = suivi(joueur)
	local t = os.clock()
	s.derniere = cible.Position
	s.budget = plafond(s, vitesseEffective(s, t), t)
	s.air = 0
	s.grace = 1
	s.ancre, s.ancreT = cible.Position, t
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if personnage and racine and racine:IsA("BasePart") then
		racine.AssemblyLinearVelocity = Vector3.zero
		personnage:PivotTo(cible)
	end
end

-- Ressorts, Tuyauterie (a12) et tout recul serveur : vol ignoré, 70 studs/s tolérés pendant duree + 0,5 s.
-- Appel serveur uniquement : aucun remote n'y mène.
function GardienMouvement.accorderEnvol(joueur: Player, duree: number)
	local s = suivi(joueur)
	local d = if duree == duree then math.clamp(duree, 0, ENVOL_MAX_S) else 0
	s.envolJusqua = math.max(s.envolJusqua, os.clock() + d + LATENCE_S)
	s.air = 0
end

local function controler(joueur: Player, s: Suivi, dt: number)
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	local h = personnage and personnage:FindFirstChildOfClass("Humanoid")
	if not personnage or not racine or not racine:IsA("BasePart") or not h then
		return
	end
	if s.grace > 0 then
		s.grace -= dt
		return
	end
	local pos, t = racine.Position, os.clock()
	local derniere = s.derniere
	if not derniere or h.SeatPart then -- assis dans une Capsule : le serveur déplace le siège
		s.derniere, s.air = pos, 0
		return
	end
	if pos.Y < centre.Y - 20 then -- chute sous la carte : sauvetage sans points
		GardienMouvement.teleporter(joueur, CFrame.new(derniere + Vector3.new(0, 3, 0)))
		return
	end
	local libre = t < s.envolJusqua or dansVolume("ZoneGlisse", pos, 2, false)

	-- 1. Budget de distance : absorbe les paquets groupés, épuise les hacks de vitesse
	local v = if libre then math.max(vitesseEffective(s, t), VITESSE_LIBRE) else vitesseEffective(s, t)
	local gain = if t < s.etourdiJusqua and not libre then 0 else v * dt * MARGE
	local deplacement = Vector3.new(pos.X - derniere.X, 0, pos.Z - derniere.Z).Magnitude
	s.budget = math.min(plafond(s, v, t), s.budget + gain) - deplacement
	if s.budget < 0 then
		return corriger(joueur, personnage, racine, s, "Vitesse", if deplacement > 30 then 8 else 4)
	end

	-- 2. Zone : une barrière physique arrête déjà les honnêtes, une sortie est corrigée sans points
	if horsZone(pos) then
		return corriger(joueur, personnage, racine, s, "HorsZone", 0)
	end
	if dansVolume("ZoneInterdite", pos, -1, false) then
		return corriger(joueur, personnage, racine, s, "Traversee", 6)
	end

	-- 3. Vol : ignoré en envol, en ZoneGlisse et en Climbing contre une Part ; sol introuvable = aucune faute
	if libre or grimpe(h, personnage, pos) then
		s.air = 0
	else
		local sol = if racineCarte then workspace:Raycast(pos, Vector3.new(0, -RAYON_SOL, 0), parametres) else nil
		local hauteur = if sol then pos.Y - sol.Position.Y else 0
		local chute = pos.Y < derniere.Y - 0.5
		local solAbsolu = h.HipHeight + racine.Size.Y / 2 + SAUT + MARGE_SAUT
		s.air = if hauteur > SOL_MAX and not chute then s.air + dt else 0
		if pos.Y - centre.Y > ALTITUDE_MAX or (hauteur > solAbsolu and not chute) or s.air > AIR_MAX then
			return corriger(joueur, personnage, racine, s, "Vol", 6)
		end
	end

	if not s.ancre or (pos - s.ancre).Magnitude > 3 then
		s.ancre, s.ancreT = pos, t
	end
	s.derniere = pos
end

-- Un coup de Zbire : 2 s à WalkSpeed 0 et JumpHeight 0, budget ramené à 1 s de course.
function GardienMouvement.etourdir(joueur: Player)
	local s = suivi(joueur)
	local t = os.clock()
	s.etourdiJusqua = t + ETOURDI_S
	s.budget = math.min(s.budget, vitesseEffective(s, t) * ETOURDI_BUDGET_S)
	appliquer(joueur, s)
	task.delay(ETOURDI_S, function()
		if suivis[joueur] == s and os.clock() >= s.etourdiJusqua then
			appliquer(joueur, s)
		end
	end)
end

function GardienMouvement.estEtourdi(joueur: Player): boolean
	local s = suivis[joueur]
	return s ~= nil and os.clock() < s.etourdiJusqua
end

-- Sans joueur : tous les Survivants et ceux qui arrivent (Répit : definirVitesse(24)).
-- Une baisse n'est exigée par le budget qu'après TRANSITION_S, le temps que le client la reçoive.
function GardienMouvement.definirVitesse(vitesse: number, joueur: Player?)
	assert(type(vitesse) == "number" and vitesse >= 0 and vitesse <= 100, "definirVitesse : vitesse invalide")
	if joueur == nil then
		vitesseCourante = vitesse
		for _, j in Players:GetPlayers() do
			GardienMouvement.definirVitesse(vitesse, j)
		end
		return
	end
	local s = suivi(joueur)
	local t = os.clock()
	s.vitessePrecedente = vitesseEffective(s, t)
	s.transitionJusqua = t + TRANSITION_S
	s.vitesse = vitesse
	appliquer(joueur, s)
end

-- DemandeDeblocage : accepté seulement si le Survivant est immobile depuis 2 s et non étourdi.
function GardienMouvement.debloquer(joueur: Player): boolean
	local s = suivis[joueur]
	local t = os.clock()
	local p = s and s.derniere
	if not s or not p or t < s.etourdiJusqua or t - s.ancreT < IMMOBILE_S then
		return false
	end
	local cible: BasePart? = nil
	for _, point in CollectionService:GetTagged("PointDeblocage") do
		if point:IsA("BasePart") and (cible == nil or (point.Position - p).Magnitude < (cible.Position - p).Magnitude) then
			cible = point
		end
	end
	GardienMouvement.teleporter(joueur, if cible then cible.CFrame + Vector3.new(0, 3, 0) else CFrame.new(p + Vector3.new(0, 4, 0)))
	return true
end

-- Dernière position validée : la seule à utiliser pour toute distance de gameplay.
function GardienMouvement.positionSure(joueur: Player): Vector3?
	local s = suivis[joueur]
	return if s then s.derniere else nil
end

function GardienMouvement.aPortee(joueur: Player, cible: Vector3, portee: number): boolean
	local p = GardienMouvement.positionSure(joueur)
	return p ~= nil and Vector3.new(cible.X - p.X, 0, cible.Z - p.Z).Magnitude <= portee
end

-- Tests d'acceptation : nombre de corrections depuis l'arrivée du Survivant.
function GardienMouvement.corrections(joueur: Player): number
	local s = suivis[joueur]
	return if s then s.corrections else 0
end

-- Dossier racine de la carte (nil si introuvable après 10 s). Peut céder : appeler depuis une tâche.
function GardienMouvement.attendreRacine(): Instance?
	if not racineResolue then
		table.insert(enAttente, coroutine.running())
		coroutine.yield()
	end
	return racineCarte
end

local function surPersonnage(joueur: Player, personnage: Model)
	local s = suivi(joueur)
	s.derniere, s.ancre = nil, nil
	s.grace, s.air, s.etourdiJusqua, s.envolJusqua = 0.5, 0, 0, 0
	s.budget = s.vitesse * BUDGET_S
	if personnage:WaitForChild("Humanoid", 5) then
		appliquer(joueur, s)
	end
end

local function surJoueur(joueur: Player)
	suivi(joueur)
	joueur.CharacterAdded:Connect(function(personnage)
		surPersonnage(joueur, personnage)
	end)
	local personnage = joueur.Character
	if personnage then
		task.spawn(surPersonnage, joueur, personnage)
	end
end

Players.PlayerAdded:Connect(surJoueur)
for _, joueur in Players:GetPlayers() do
	surJoueur(joueur)
end
Players.PlayerRemoving:Connect(function(joueur)
	suivis[joueur] = nil
end)

-- Racine de la carte et rayon de zone, lus dans ReplicatedStorage.Plan (a11) sans jamais bloquer le require.
task.spawn(function()
	local module = ReplicatedStorage:WaitForChild("Plan", 10)
	local ok: boolean, plan: any = false, nil
	if module and module:IsA("ModuleScript") then
		ok, plan = pcall(require, module)
	end
	if not ok or type(plan) ~= "table" then
		warn("[AntiExploit] ReplicatedStorage.Plan illisible : contrôles de sol et de rayon désactivés")
		plan = {}
	end
	if typePlace == "Prairie" then
		local barriere = tonumber(plan.RAYON_BARRIERE)
		if barriere then
			rayonPlace = barriere + MARGE_BARRIERE
		else
			warn("[AntiExploit] Plan.RAYON_BARRIERE absent : contrôle de zone désactivé")
		end
	end
	local nom = plan.RACINE
	local dossier = if type(nom) == "string" then workspace:WaitForChild(nom, 10) else nil
	if dossier then
		racineCarte = dossier
		parametres.FilterDescendantsInstances = { dossier }
	else
		warn(string.format("[AntiExploit] Workspace.%s introuvable : contrôle de sol désactivé", tostring(nom)))
	end
	racineResolue = true
	for _, fil in enAttente do
		task.spawn(fil)
	end
	table.clear(enAttente)
end)

task.spawn(function()
	while true do
		local dt = task.wait(PERIODE)
		for joueur, s in suivis do
			if joueur.Parent then
				controler(joueur, s, dt)
			else
				suivis[joueur] = nil -- entrée recréée après départ par un appel tardif du gameplay
			end
		end
	end
end)

return GardienMouvement
