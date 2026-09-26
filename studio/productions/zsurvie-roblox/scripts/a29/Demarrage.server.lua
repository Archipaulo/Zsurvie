-- ServerScriptService.Securite.Demarrage (Script)
--!strict
-- Point d'entrée anti-exploit, identique dans les places Laboratoire et Prairie. Rien ici ne bloque :
-- le groupe Survivants est enregistré avant tout require, la racine de la carte est attendue en tâche de fond.
-- Réglages Studio : Workspace.TypePlace, Workspace.CentrePlace, Workspace.RejectCharacterDeletions = Enabled.
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local GROUPE = "Survivants"

-- 1. Les Survivants ne se touchent pas : ni poussée ni fling (aucun PvP dans Zsurvie).
if not PhysicsService:IsCollisionGroupRegistered(GROUPE) then
	PhysicsService:RegisterCollisionGroup(GROUPE)
end
PhysicsService:CollisionGroupSetCollidable(GROUPE, GROUPE, false)

local function ranger(instance: Instance)
	if instance:IsA("BasePart") then
		instance.CollisionGroup = GROUPE
	end
end

local function surPersonnage(personnage: Model)
	for _, descendant in personnage:GetDescendants() do
		ranger(descendant)
	end
	personnage.DescendantAdded:Connect(ranger)
end

local function surJoueur(joueur: Player)
	joueur.CharacterAdded:Connect(surPersonnage)
	local personnage = joueur.Character
	if personnage then
		surPersonnage(personnage)
	end
end

Players.PlayerAdded:Connect(surJoueur)
for _, joueur in Players:GetPlayers() do
	surJoueur(joueur)
end

-- 2. Modules : Validation crée ReplicatedStorage.Remotes, GardienMouvement lance ses contrôles.
local Validation = require(script.Parent.Validation)
local GardienMouvement = require(script.Parent.GardienMouvement)

-- 3. Bouton « Je suis coincé » : 1 demande toutes les 10 s, filtrée par Validation.
Validation.brancher("DemandeDeblocage", function(joueur: Player)
	GardienMouvement.debloquer(joueur)
end)

-- 4. Carte 100 % ancrée : une Part libre proche d'un joueur lui est confiée par la physique et devient
--    une arme de fling. Les défenses posées vont dans <racine>.Defenses, donc dans le rayon de sol.
task.spawn(function()
	local carte = GardienMouvement.attendreRacine()
	if not carte then
		return -- GardienMouvement a déjà prévenu par un warn
	end
	local function verrouiller(instance: Instance)
		if instance:IsA("BasePart") and not instance.Anchored then
			warn("[AntiExploit] Part non ancrée dans la carte : " .. instance:GetFullName())
			if instance:CanSetNetworkOwnership() then
				instance:SetNetworkOwner(nil)
			end
		end
	end
	for _, descendant in carte:GetDescendants() do
		verrouiller(descendant)
	end
	carte.DescendantAdded:Connect(verrouiller)
	if workspace:GetAttribute("TypePlace") == "Prairie" and not carte:FindFirstChild("Defenses") then
		local defenses = Instance.new("Folder")
		defenses.Name = "Defenses"
		defenses.Parent = carte
	end
end)
