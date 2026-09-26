-- Point d'entrée du serveur : construit toute la map, puis démarre les systèmes de jeu.
-- Chaque module est isolé : si l'un plante, les autres continuent (l'erreur est affichée dans la sortie).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Partage = ReplicatedStorage:WaitForChild("Zsurvie")
local Charte = require(Partage.Charte)
local Outils = require(Partage.Outils)
local Plan = require(Partage.Plan)
local Equilibrage = require(Partage.Equilibrage)
local Bus = require(Partage.Bus)
local Reseau = require(Partage.Reseau)

-- ===== les dossiers communs =====
local ancienne = workspace:FindFirstChild("Zsurvie")
if ancienne then ancienne:Destroy() end
local racine = Outils.dossier(workspace, "Zsurvie")
local horde = Outils.dossier(racine, "Horde")

local stockage = ServerStorage:FindFirstChild("Zsurvie") or Outils.dossier(ServerStorage, "Zsurvie")
if not stockage:FindFirstChild("Zbires") then Outils.dossier(stockage, "Zbires") end

local Etat = ReplicatedStorage:FindFirstChild("ZsurvieEtat") or Outils.dossier(ReplicatedStorage, "ZsurvieEtat")
local ETAT_INITIAL = {
	Phase = "Lobby", -- "Lobby", "Horde", "Repit" ou "Defaite"
	Jour = 0,
	TempsRestant = 0,
	PVMaison = Equilibrage.maison.pv,
	PVMaisonMax = Equilibrage.maison.pv,
	ColosseActif = false,
	Record = 0,
	ZbiresRestants = 0,
}
for cle, valeur in pairs(ETAT_INITIAL) do
	Etat:SetAttribute(cle, valeur)
end

local ctxBase = {
	Charte = Charte,
	Outils = Outils,
	Plan = Plan,
	Equilibrage = Equilibrage,
	Bus = Bus,
	Reseau = Reseau.serveur(),
	Etat = Etat,
	racine = racine,
	horde = horde,
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
		warn("[Zsurvie] impossible de charger " .. module:GetFullName() .. " : " .. tostring(resultat))
		return nil
	end
	return resultat
end

-- modules d'un dossier dans l'ordre donné, puis ceux qui n'y figurent pas (par ordre alphabétique)
local function modulesDans(dossier, ordre)
	local liste, vus = {}, {}
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
	"Zbires", "Ciel", "IleLabo", "Prairie", "Relief", "Vegetation", "Eau", "Maison", "Mine", "Props",
	"PointsInteret", "Portails", "Lumieres", "Signaletique", "Fanions", "Laboratoire", "QuaiCapsules",
	"Galerie", "Parcours", "Enigme", "Records", "Monument", "ScenePhoto",
}

local debut = os.clock()
for _, module in ipairs(modulesDans(script.Parent.Builders, ORDRE_CONSTRUCTION)) do
	local constructeur = charger(module)
	if constructeur and type(constructeur.construire) == "function" then
		local dossier = Outils.dossier(racine, module.Name)
		local ok, err = pcall(constructeur.construire, contexte(dossier))
		if not ok then warn("[Zsurvie] construction « " .. module.Name .. " » : " .. tostring(err)) end
	end
end
racine:SetAttribute("Construit", true)
print(string.format("[Zsurvie] map construite : %d parts en %.2f s", Outils.nombreParts(), os.clock() - debut))

-- ===== 2. démarrage des systèmes =====
local ORDRE_SYSTEMES = {
	"Donnees", "Economie", "Classement", "Etabli", "Laboratoire", "Blaster", "Horde", "Jour", "TourelleToit",
	"Securite", "GardeFou", "Boutique", "Analytique", "Performance", "Autotest", "ModeTest",
}

for _, module in ipairs(modulesDans(script.Parent.Systemes, ORDRE_SYSTEMES)) do
	local systeme = charger(module)
	if systeme and type(systeme.demarrer) == "function" then
		local ctx = contexte(nil)
		task.spawn(function()
			local ok, err = pcall(systeme.demarrer, ctx)
			if not ok then warn("[Zsurvie] système « " .. module.Name .. " » : " .. tostring(err)) end
		end)
	end
end
racine:SetAttribute("Pret", true)
