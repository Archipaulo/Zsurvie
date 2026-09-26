-- ServerScriptService/Services/StatsSurvivant (ModuleScript)
-- États serveur du Survivant. On ne meurt jamais : un coup étourdit 2 s, puis 2 s de protection.
-- WalkSpeed et JumpHeight ont UN SEUL propriétaire, GardienMouvement : ce module ne les écrit jamais.
-- Il lui transmet les valeurs de ReplicatedStorage.Config.Mouvement (SAUT_SURVIVANT n'est lu que par lui).
-- Attributs du Player lus par l'UI : EtourdiJusqua, InvulnerableJusqua (heure de GetServerTimeNow).

local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Mouvement = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Mouvement"))
local GardienMouvement = require(script.Parent:WaitForChild("GardienMouvement"))
local Validation = require(script.Parent:WaitForChild("Validation"))

export type Position = { joueur: Player, pos: Vector3 }
export type Allure = "Horde" | "Repit" | "Reparation"

local VITESSES: { [string]: number } = {
	Horde = Mouvement.VITESSE_HORDE, -- 18
	Repit = Mouvement.VITESSE_REPIT, -- 24
	Reparation = Mouvement.VITESSE_REPARATION, -- 8
}

local GROUPE_SURVIVANTS = "Survivants"
local GROUPE_DEFENSES = "Defenses"

local StatsSurvivant = {}

local allurePhase: Allure = "Horde"
local allurePerso: { [Player]: Allure } = {}
local dernierDeblocage: { [Player]: number } = {}
local spawns: { SpawnLocation } = {}

local function appliquerAllure(joueur: Player)
	GardienMouvement.definirVitesse(joueur, VITESSES[allurePerso[joueur] or allurePhase])
end

local function distancePlate(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

function StatsSurvivant.racine(joueur: Player): BasePart?
	local perso = joueur.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart")
	return if racine and racine:IsA("BasePart") then racine else nil
end

function StatsSurvivant.estEtourdi(joueur: Player): boolean
	local fin = joueur:GetAttribute("EtourdiJusqua")
	return typeof(fin) == "number" and fin > workspace:GetServerTimeNow()
end

-- Renvoie true si le Survivant vient d'être étourdi. GardienMouvement gèle puis rend la vitesse qu'il connaît.
function StatsSurvivant.etourdir(joueur: Player): boolean
	local maintenant = workspace:GetServerTimeNow()
	local invulnerable = joueur:GetAttribute("InvulnerableJusqua")
	if typeof(invulnerable) == "number" and invulnerable > maintenant then
		return false
	end
	if not StatsSurvivant.racine(joueur) then
		return false
	end
	local fin = maintenant + Mouvement.ETOURDI_DUREE
	joueur:SetAttribute("EtourdiJusqua", fin)
	joueur:SetAttribute("InvulnerableJusqua", fin + Config.ETOURDI_IMMUNITE)
	GardienMouvement.etourdir(joueur, Mouvement.ETOURDI_DUREE)
	return true
end

-- JourService : "Horde" au début des 80 s, "Repit" pendant les 15 s. S'applique aussi aux arrivants.
function StatsSurvivant.definirAllurePhase(allure: Allure)
	allurePhase = allure
	for _, joueur in Players:GetPlayers() do
		appliquerAllure(joueur)
	end
end

-- MaisonService : "Reparation" pendant une réparation, nil pour revenir à l'allure de la phase.
function StatsSurvivant.definirAllure(joueur: Player, allure: Allure?)
	allurePerso[joueur] = allure
	appliquerAllure(joueur)
end

function StatsSurvivant.positions(): { Position }
	local liste = {}
	for _, joueur in Players:GetPlayers() do
		local racine = StatsSurvivant.racine(joueur)
		if racine then
			table.insert(liste, { joueur = joueur, pos = racine.Position })
		end
	end
	return liste
end

--------------------------------------------------------------------------------
-- Déblocage (bouton Réinitialiser) : SpawnLocation libre le plus proche, via GardienMouvement.teleporter
--------------------------------------------------------------------------------

local function spawnLibre(joueur: Player, depuis: Vector3): SpawnLocation?
	local occupants = StatsSurvivant.positions()
	local libre, dLibre = nil, math.huge
	local secours, dSecours = nil, math.huge
	for _, spawn in spawns do
		if spawn.Parent then
			local d = distancePlate(spawn.Position, depuis)
			local occupe = false
			for _, s in occupants do
				if s.joueur ~= joueur and distancePlate(s.pos, spawn.Position) < Config.DEBLOCAGE_RAYON_LIBRE then
					occupe = true
					break
				end
			end
			if not occupe and d < dLibre then
				libre, dLibre = spawn, d
			end
			if d < dSecours then
				secours, dSecours = spawn, d
			end
		end
	end
	return libre or secours
end

local function surDemandeDeblocage(joueur: Player)
	local maintenant = os.clock()
	local dernier = dernierDeblocage[joueur]
	if dernier and maintenant - dernier < Config.DEBLOCAGE_INTERVALLE then
		return
	end
	local racine = StatsSurvivant.racine(joueur)
	if not racine then
		return
	end
	local spawn = spawnLibre(joueur, racine.Position)
	if not spawn then
		return
	end
	dernierDeblocage[joueur] = maintenant
	GardienMouvement.teleporter(joueur, CFrame.new(spawn.Position + Vector3.new(0, spawn.Size.Y / 2 + 3, 0)))
end

--------------------------------------------------------------------------------
-- Groupes de collision : les défenses ne bloquent jamais un Survivant
--------------------------------------------------------------------------------

local function preparerGroupes()
	for _, nom in { GROUPE_SURVIVANTS, GROUPE_DEFENSES } do
		if not PhysicsService:IsCollisionGroupRegistered(nom) then
			PhysicsService:RegisterCollisionGroup(nom)
		end
	end
	-- Les Zbires sont simulés par HordeService : une collision Muret/Survivant ne servirait qu'à piéger.
	PhysicsService:CollisionGroupSetCollidable(GROUPE_DEFENSES, GROUPE_SURVIVANTS, false)
end

local function rangerPart(d: Instance)
	if d:IsA("BasePart") then
		d.CollisionGroup = GROUPE_SURVIVANTS
	end
end

function StatsSurvivant.init()
	preparerGroupes()
	for _, d in workspace:GetDescendants() do
		if d:IsA("SpawnLocation") then
			table.insert(spawns, d)
		end
	end

	local function surPersonnage(joueur: Player, perso: Model)
		for _, d in perso:GetDescendants() do
			rangerPart(d)
		end
		perso.DescendantAdded:Connect(rangerPart)
		appliquerAllure(joueur) -- transmis à GardienMouvement ; aucune écriture de WalkSpeed ni JumpHeight ici
	end

	local function surJoueur(joueur: Player)
		joueur.CharacterAdded:Connect(function(perso)
			surPersonnage(joueur, perso)
		end)
		if joueur.Character then
			surPersonnage(joueur, joueur.Character)
		end
	end

	Players.PlayerAdded:Connect(surJoueur)
	for _, joueur in Players:GetPlayers() do
		surJoueur(joueur)
	end
	Players.PlayerRemoving:Connect(function(joueur)
		allurePerso[joueur] = nil
		dernierDeblocage[joueur] = nil
	end)

	Validation.brancher(
		Reseau.DemandeDeblocage,
		{ arguments = {}, intervalleMin = Config.DEBLOCAGE_INTERVALLE },
		surDemandeDeblocage
	)
end

return StatsSurvivant
