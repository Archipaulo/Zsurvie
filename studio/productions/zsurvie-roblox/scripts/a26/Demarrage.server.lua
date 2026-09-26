-- ServerScriptService/Demarrage (Script)
-- Point d'entrée serveur de la place Prairie. Ordre : Survivants, Horde, Blaster, puis les autres services.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Partage"):WaitForChild("Config"))
local Services = ServerScriptService:WaitForChild("Services")
local StatsSurvivant = require(Services:WaitForChild("StatsSurvivant"))
local HordeService = require(Services:WaitForChild("HordeService"))
local BlasterService = require(Services:WaitForChild("BlasterService"))

-- Economie.estActif décide qui compte dans « actifs » (PV et effectifs). Sans Economie : tout le monde.
local moduleEconomie = Services:FindFirstChild("Economie")
local Economie = if moduleEconomie and moduleEconomie:IsA("ModuleScript") then require(moduleEconomie) else nil

StatsSurvivant.init()
HordeService.init(if Economie then Economie.estActif else nil)
BlasterService.init()

-- Branchements des services de l'équipe :
--   HordeService.on("maison", MaisonService.subir)               -- dégâts cumulés du tick
--   HordeService.on("vaincu", Economie.surZbireVaincu)           -- Pièces x BlasterStats.butin(tueur)
--   HordeService.on("vaincu", GalerieService.compterElimination) -- paliers 10 / 100 / 1 000
--   JourService : HordeService.demarrerJour(j) et StatsSurvivant.definirAllurePhase("Horde") au début des 80 s,
--                 StatsSurvivant.definirAllurePhase("Repit") pendant les 15 s

-- Mode test greybox : attribut booléen ModeTest = true sur Workspace ; JourTest = 5 pour le Colosse d'emblée.
if workspace:GetAttribute("ModeTest") == true then
	local degatsMaison = 0
	HordeService.on("maison", function(degats: number)
		degatsMaison += degats
		workspace:SetAttribute("TestDegatsMaison", math.round(degatsMaison))
	end)
	HordeService.on("vaincu", function(typeId: string, _position: Vector3, tueur: Player?)
		print(`[ModeTest] {typeId} vaincu par {if tueur then tueur.Name else "une défense"}`)
	end)

	HordeService.demarrer()
	local premier = workspace:GetAttribute("JourTest")
	local jour = if typeof(premier) == "number" then math.max(1, math.floor(premier)) else 1
	while workspace:GetAttribute("ModeTest") == true do
		workspace:SetAttribute("JourCourant", jour)
		StatsSurvivant.definirAllurePhase("Horde")
		HordeService.demarrerJour(jour)
		task.wait(Config.DUREE_HORDE)
		StatsSurvivant.definirAllurePhase("Repit")
		task.wait(Config.DUREE_REPIT)
		jour += 1
	end
end
