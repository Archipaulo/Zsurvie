-- Point d'entrée du serveur : construit toute la map, puis démarre les systèmes de jeu.
-- Chaque module est isolé : si l'un plante, les autres continuent (l'erreur est affichée dans la sortie).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Partage = ReplicatedStorage:WaitForChild("Dino")
local Charte = require(Partage.Charte)
local Outils = require(Partage.Outils)
local Plan = require(Partage.Plan)
local Equilibrage = require(Partage.Equilibrage)
local Bus = require(Partage.Bus)
local Reseau = require(Partage.Reseau)
local Style = require(Partage.Style)
local Voxel = require(Partage.Voxel)

-- ===== les dossiers communs =====
local ancienne = workspace:FindFirstChild("Dino")
if ancienne then ancienne:Destroy() end
local racine = Outils.dossier(workspace, "Dino")
local dinos = Outils.dossier(racine, "Dinos") -- tous les dinos vivants : sur le Tapis, en route, dans les Bases, portés

local stockage = ServerStorage:FindFirstChild("Dino") or Outils.dossier(ServerStorage, "Dino")
if not stockage:FindFirstChild("Dinos") then Outils.dossier(stockage, "Dinos") end -- gabarits des espèces

local Etat = ReplicatedStorage:FindFirstChild("DinoEtat") or Outils.dossier(ReplicatedStorage, "DinoEtat")
local ETAT_INITIAL = {
	Evenement = "",          -- nom de l'événement en cours (clé de Equilibrage.evenements.liste) ou ""
	EvenementFin = 0,        -- workspace:GetServerTimeNow() de fin de l'événement
	ProchainEvenement = 0,   -- workspace:GetServerTimeNow() du prochain événement
	DinosSurTapis = 0,
	MeilleurRevenu = 0,      -- meilleur revenu par seconde du serveur (Classement)
}
for cle, valeur in pairs(ETAT_INITIAL) do
	Etat:SetAttribute(cle, valeur)
end

local ctxBase = {
	Charte = Charte,
	Style = Style,
	Voxel = Voxel,
	Outils = Outils,
	Plan = Plan,
	Equilibrage = Equilibrage,
	Bus = Bus,
	Reseau = Reseau.serveur(),
	Etat = Etat,
	racine = racine,
	dinos = dinos,
	stockage = stockage,
}

local function contexte(dossier)
	local ctx = {}
	for cle, valeur in pairs(ctxBase) do ctx[cle] = valeur end
	ctx.dossier = dossier
	return ctx
end

local function charger(module)
	local ok, resultat = pcall(require, module)
	if not ok then
		warn("[Dino] impossible de charger " .. module:GetFullName() .. " : " .. tostring(resultat))
		return nil
	end
	return resultat
end

-- modules d'un dossier dans l'ordre donné, puis ceux qui n'y figurent pas (par ordre alphabétique)
local function modulesDans(dossier, ordre)
	local liste, vus = {}, {}
	if not dossier then return liste end
	for _, nom in ipairs(ordre) do
		local m = dossier:FindFirstChild(nom)
		if m and m:IsA("ModuleScript") then
			table.insert(liste, m)
			vus[nom] = true
		end
	end
	local autres = {}
	for _, m in ipairs(dossier:GetChildren()) do
		if m:IsA("ModuleScript") and not vus[m.Name] then table.insert(autres, m) end
	end
	table.sort(autres, function(a, b) return a.Name < b.Name end)
	for _, m in ipairs(autres) do table.insert(liste, m) end
	return liste
end

-- ===== 1. construction de la map =====
local ORDRE_CONSTRUCTION = {
	"DinosHerbivores", "DinosCarnivores", "OeufMystere", "Ciel", "Sol", "Falaises", "Jungle", "Riviere", "Volcan", "Tapis",
	"Nurserie", "FinTapis", "Bases", "Place", "Comptoir", "Autel", "Cratere", "Fossiles", "Lumieres", "Signaletique",
}

local debut = os.clock()
for _, module in ipairs(modulesDans(script.Parent:FindFirstChild("Builders"), ORDRE_CONSTRUCTION)) do
	local constructeur = charger(module)
	if constructeur and type(constructeur.construire) == "function" then
		local dossier = Outils.dossier(racine, module.Name)
		local ok, err = pcall(constructeur.construire, contexte(dossier))
		if not ok then warn("[Dino] construction « " .. module.Name .. " » : " .. tostring(err)) end
	end
end
racine:SetAttribute("Construit", true)
print(string.format("[Dino] map construite : %d parts en %.2f s", Outils.nombreParts(), os.clock() - debut))

-- ===== 2. démarrage des systèmes =====
local ORDRE_SYSTEMES = {
	"Donnees", "Economie", "Bases", "Tapis", "Enclos", "Achat", "Vol", "Batte", "Renaissance", "Boutique",
	"Index", "Oeufs", "Evenements", "Classement", "Recompenses", "Securite", "GardeFou", "Autotest", "ModeTest",
}

for _, module in ipairs(modulesDans(script.Parent:FindFirstChild("Systemes"), ORDRE_SYSTEMES)) do
	local systeme = charger(module)
	if systeme and type(systeme.demarrer) == "function" then
		local ctx = contexte(nil)
		task.spawn(function()
			local ok, err = pcall(systeme.demarrer, ctx)
			if not ok then warn("[Dino] système « " .. module.Name .. " » : " .. tostring(err)) end
		end)
	end
end
racine:SetAttribute("Pret", true)
