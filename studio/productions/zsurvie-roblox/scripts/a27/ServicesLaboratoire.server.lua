-- ServerScriptService.ServicesLaboratoire (Script) : place Laboratoire uniquement
-- DemandeRecherche(nom, niveauVise), DemandeForeuse(), DemandeDeblocage("Equiper", "Emplacement:Id"),
-- DemandeCapsule("Monter", capsule | "Quitter" | "Rejoindre"). Toutes les réponses partent par Annonce.
-- Instances : Workspace.Laboratoire.ArbreDesRecherches (Model)
--             Workspace.Laboratoire.Alcoves.Alcove1 ... Alcove12 (Model)
--             Workspace.Laboratoire.QuaiDesCapsules.Normale / .Difficile / .DuJour (Model)
-- Attributs : Player.Alcove (1 à 12, posé par l'attribution des Alcôves) ; Player.RunEnCours (posé ici) ;
--             Capsule.Passagers (0 à 6) et Capsule.Depart (workspace:GetServerTimeNow(), 0 = à quai), posés ici.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Modules = ServerScriptService:WaitForChild("Modules")
local Donnees = require(Modules:WaitForChild("Donnees"))
local Passage = require(Modules:WaitForChild("Passage"))

local laboratoire = workspace:WaitForChild("Laboratoire")
local arbre = laboratoire:WaitForChild("ArbreDesRecherches")
local alcoves = laboratoire:WaitForChild("Alcoves")
local quai = laboratoire:WaitForChild("QuaiDesCapsules")

local RAYON_ARBRE = 18 -- studs
local RAYON_ALCOVE = 14 -- studs
local RAYON_QUAI = 12 -- studs

local function proche(joueur: Player, cible: Instance?, rayon: number): boolean
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if not racine or not cible or not cible:IsA("PVInstance") then
		return false
	end
	return (racine.Position - cible:GetPivot().Position).Magnitude <= rayon
end

local function alcoveDe(joueur: Player): Instance?
	local numero = joueur:GetAttribute("Alcove")
	if type(numero) ~= "number" then
		return nil
	end
	return alcoves:FindFirstChild(`Alcove{numero}`)
end

-- Recherches : un double tap envoie deux fois le même niveauVise, le second est refusé sans débit.
Reseau.Brancher("DemandeRecherche", function(joueur: Player, nom: string, niveauVise: number)
	if not proche(joueur, arbre, RAYON_ARBRE) then
		Reseau.Refuser(joueur, "DemandeRecherche", "TropLoin")
		return
	end
	local ok, raison = Donnees.AcheterRecherche(joueur, nom, niveauVise)
	if ok then
		Reseau.Annoncer(joueur, "Recherche", { Nom = nom, Niveau = niveauVise })
	else
		Reseau.Refuser(joueur, "DemandeRecherche", raison)
	end
end)

Reseau.Brancher("DemandeForeuse", function(joueur: Player)
	if not proche(joueur, alcoveDe(joueur), RAYON_ALCOVE) then
		Reseau.Refuser(joueur, "DemandeForeuse", "TropLoin")
		return
	end
	Reseau.Annoncer(joueur, "Foreuse", { Gain = Donnees.RecolterForeuse(joueur) })
end)

-- Équipement : "Base" toujours disponible, sinon Cosmetiques.Possedes["Emplacement:Id"] (a46).
local EMPLACEMENTS = {}
for _, emplacement in Catalogue.Emplacements do
	EMPLACEMENTS[emplacement] = true
end

Donnees.DefinirDeblocage("Equiper", function(joueur: Player, id: any): boolean
	if type(id) ~= "string" then
		return false
	end
	local emplacement, nom = string.match(id, "^(%a+):([%w_]+)$")
	if not emplacement or not EMPLACEMENTS[emplacement] then
		return false
	end
	return Donnees.Modifier(joueur, function(p)
		if nom ~= "Base" and p.Cosmetiques.Possedes[id] ~= true then
			return false
		end
		if p.Cosmetiques.Equipes[emplacement] == nom then
			return false
		end
		p.Cosmetiques.Equipes[emplacement] = nom
		return true
	end)
end)

-- Quai des Capsules
local capsules: { [string]: { Passagers: { Player }, Depart: number } } = {}
for _, mode in Catalogue.Capsules.Modes do
	capsules[mode] = { Passagers = {}, Depart = 0 }
end

local function publier(mode: string)
	local capsule = capsules[mode]
	local modele = quai:FindFirstChild(mode)
	if modele then
		modele:SetAttribute("Passagers", #capsule.Passagers)
		modele:SetAttribute("Depart", capsule.Depart)
	end
end

local function capsuleDe(joueur: Player): string?
	for mode, capsule in capsules do
		if table.find(capsule.Passagers, joueur) then
			return mode
		end
	end
	return nil
end

local function descendre(joueur: Player)
	local mode = capsuleDe(joueur)
	if not mode then
		return
	end
	local capsule = capsules[mode]
	table.remove(capsule.Passagers, table.find(capsule.Passagers, joueur) :: number)
	if #capsule.Passagers == 0 then
		capsule.Depart = 0
	end
	publier(mode)
end

local function partir(passagers: { Player }, mode: string)
	local presents = {}
	for _, joueur in passagers do
		if joueur.Parent then
			table.insert(presents, joueur)
		end
	end
	if #presents > 0 and not Passage.LancerRun(presents, mode) then
		for _, joueur in presents do
			Reseau.Annoncer(joueur, "PassageAnnule", { Raison = "Reseau" })
		end
	end
end

Reseau.Brancher("DemandeCapsule", function(joueur: Player, action: string, mode: string?)
	if action == "Quitter" then
		descendre(joueur)
	elseif action == "Rejoindre" then
		descendre(joueur)
		if not Passage.Rejoindre(joueur) then
			joueur:SetAttribute("RunEnCours", false)
			Reseau.Refuser(joueur, "DemandeCapsule", "RunTerminee")
		end
	elseif action == "Monter" then
		local capsule = if mode then capsules[mode] else nil
		if not capsule then
			Reseau.Refuser(joueur, "DemandeCapsule", "Inconnue")
		elseif capsuleDe(joueur) then
			Reseau.Refuser(joueur, "DemandeCapsule", "DejaAssis")
		elseif #capsule.Passagers >= Catalogue.Capsules.Places then
			Reseau.Refuser(joueur, "DemandeCapsule", "Complet")
		elseif not proche(joueur, quai:FindFirstChild(mode :: string), RAYON_QUAI) then
			Reseau.Refuser(joueur, "DemandeCapsule", "TropLoin")
		else
			table.insert(capsule.Passagers, joueur)
			if capsule.Depart == 0 then
				capsule.Depart = workspace:GetServerTimeNow() + Catalogue.Capsules.DelaiDepart
			end
			publier(mode :: string)
		end
	else
		Reseau.Refuser(joueur, "DemandeCapsule", "Inconnue")
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		local maintenant = workspace:GetServerTimeNow()
		for mode, capsule in capsules do
			if capsule.Depart > 0 and maintenant >= capsule.Depart then
				local passagers = capsule.Passagers
				capsule.Passagers = {}
				capsule.Depart = 0
				publier(mode)
				task.spawn(partir, passagers, mode)
			end
		end
	end
end)

-- « Rejoindre la run » : Player.RunEnCours = true si RunEnCours_<UserId> existe encore en MemoryStore.
local function verifierRunEnCours(joueur: Player)
	if joueur:GetAttribute("DonneesChargees") ~= true then
		return
	end
	local run = Passage.LireRunEnCours(joueur.UserId)
	if joueur.Parent then
		joueur:SetAttribute("RunEnCours", run ~= nil)
	end
end

local function surArrivee(joueur: Player)
	joueur:GetAttributeChangedSignal("DonneesChargees"):Connect(function()
		verifierRunEnCours(joueur)
	end)
	task.spawn(verifierRunEnCours, joueur)
end

Players.PlayerAdded:Connect(surArrivee)
for _, joueur in Players:GetPlayers() do
	surArrivee(joueur)
end

Players.PlayerRemoving:Connect(descendre)
