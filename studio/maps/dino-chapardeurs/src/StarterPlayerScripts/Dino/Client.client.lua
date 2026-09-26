-- Point d'entrée du client : crée l'écran du joueur et démarre les modules d'interface.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Partage = ReplicatedStorage:WaitForChild("Dino")
local Charte = require(Partage.Charte)
local Outils = require(Partage.Outils)
local Plan = require(Partage.Plan)
local Equilibrage = require(Partage.Equilibrage)
local Bus = require(Partage.Bus)
local Reseau = require(Partage.Reseau)
local Style = require(Partage.Style)

local joueur = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "DinoGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = joueur:WaitForChild("PlayerGui")

local racine = workspace:WaitForChild("Dino")

local ctxBase = {
	Charte = Charte,
	Style = Style,
	Outils = Outils,
	Plan = Plan,
	Equilibrage = Equilibrage,
	Bus = Bus,
	Reseau = Reseau.client(),
	Etat = ReplicatedStorage:WaitForChild("DinoEtat"),
	joueur = joueur,
	gui = gui,
	racine = racine,
	dinos = racine:WaitForChild("Dinos"),
}

-- dégradés animés des raretés Divin et Secret (étiquettes du monde et interface)
Style.animerDegrades({ workspace, joueur:WaitForChild("PlayerGui") })

-- les invites du décor ouvrent les panneaux d'interface
local PANNEAUX = { Boutique = "Boutique", Renaissance = "Renaissance", Index = "Index" }
ProximityPromptService.PromptTriggered:Connect(function(invite, qui)
	if qui == joueur and PANNEAUX[invite.Name] then
		Bus.emettre("OuvrirPanneau", PANNEAUX[invite.Name])
	end
end)

local ORDRE = {
	"HUD", "Base", "Vol", "Batte", "Boutique", "Renaissance", "Index", "Mobile", "Effets", "AnimationsDecor",
	"Sons", "Musique", "Tutoriel",
}
local dossier = script.Parent:WaitForChild("Interface")
local vus = {}
local liste = {}
for _, nom in ipairs(ORDRE) do
	local m = dossier:FindFirstChild(nom)
	if m then
		table.insert(liste, m)
		vus[nom] = true
	end
end
for _, m in ipairs(dossier:GetChildren()) do
	if m:IsA("ModuleScript") and not vus[m.Name] then table.insert(liste, m) end
end

for _, module in ipairs(liste) do
	local ok, interface = pcall(require, module)
	if not ok then
		warn("[Dino] impossible de charger " .. module.Name .. " : " .. tostring(interface))
	elseif type(interface.demarrer) == "function" then
		local ctx = {}
		for cle, valeur in pairs(ctxBase) do ctx[cle] = valeur end
		ctx.horde = ctx.dinos -- AnimationsDecor (module partagé avec Zsurvie) ne touche jamais aux dinos
		task.spawn(function()
			local ok2, err = pcall(interface.demarrer, ctx)
			if not ok2 then warn("[Dino] interface « " .. module.Name .. " » : " .. tostring(err)) end
		end)
	end
end
