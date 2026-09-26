-- StarterPlayer/StarterPlayerScripts/ClientDemarrage (LocalScript)
-- Point d'entrée client de la place Prairie : pool des Zbires (pendant l'Arrivée), tir auto, déblocage.

local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local Reseau = require(Partage:WaitForChild("Reseau"))

local Controleurs = script.Parent:WaitForChild("Controleurs")
local ZbiresRendu = require(Controleurs:WaitForChild("ZbiresRendu"))
local BlasterControleur = require(Controleurs:WaitForChild("BlasterControleur"))

-- On ne meurt jamais : le bouton « Réinitialiser » du menu Roblox sert à SE DÉBLOQUER.
-- Le client limite à 1 demande toutes les 10 s ; le serveur revérifie et choisit seul le SpawnLocation.
local deblocage = Instance.new("BindableEvent")
local derniereDemande = -math.huge
deblocage.Event:Connect(function()
	local maintenant = os.clock()
	if maintenant - derniereDemande < Config.DEBLOCAGE_INTERVALLE then
		return
	end
	derniereDemande = maintenant
	Reseau.DemandeDeblocage:FireServer()
end)

task.spawn(function()
	for _ = 1, 20 do
		if pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", deblocage) then
			return
		end
		task.wait(0.5)
	end
end)

ZbiresRendu.preparer() -- 70 modèles pendant l'Arrivée, 5 par image
ZbiresRendu.demarrer()
BlasterControleur.demarrer()
