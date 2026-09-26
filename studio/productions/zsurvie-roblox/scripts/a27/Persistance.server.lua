-- ServerScriptService.Persistance (Script) : à placer dans les DEUX places (Laboratoire et Prairie)
-- Génère le réseau, charge et libère les profils, envoie ProfilMaj (champs modifiés seulement),
-- traite DemandeReglage et DemandeDeblocage, autosave 60 s, BindToClose.
-- Workspace porte TypePlace ("Laboratoire" | "Prairie"), CentrePlace (Vector3) et RayonPlace (number),
-- posés dans Studio (Workspace > Attributs). Aucun script n'y écrit autre chose.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Modules = ServerScriptService:WaitForChild("Modules")
local Donnees = require(Modules:WaitForChild("Donnees"))
local SchemaJoueur = require(Modules:WaitForChild("SchemaJoueur"))

local TYPE_PLACE = workspace:GetAttribute("TypePlace")
assert(TYPE_PLACE == "Laboratoire" or TYPE_PLACE == "Prairie", "Workspace.TypePlace doit valoir Laboratoire ou Prairie")

local INTERVALLE_AUTOSAVE = 60
local DELAI_ENVOI = 0.2 -- regroupe les mises à jour du profil envoyées au client

-- Messages de Kick : courts, rassurants, lisibles par un enfant de 9 ans.
local MESSAGES = {
	DataStore = "Tes gemmes n'ont pas pu être chargées. Rien n'est perdu : reviens dans une minute !",
	Version = "Zsurvie vient d'être mis à jour. Relance le jeu pour retrouver tes inventions !",
	Fermeture = "Ce serveur redémarre. Relance Zsurvie pour continuer !",
	Corrompu = "Doc Boulon répare ta sauvegarde. Tes gemmes sont à l'abri : reviens dans 5 minutes !",
}

-- Champs jamais envoyés au client.
local PRIVES = { Verrou = true, Achats = true, RunsCreditees = true, RunsTerminees = true, DerniereSauvegarde = true }

Reseau.Initialiser()

local Run = if TYPE_PLACE == "Prairie" then require(Modules:WaitForChild("Run")) else nil
if Run then
	task.spawn(Run.Demarrer) -- EtatRun est créé avant la première attente
end

local envoyes: { [Player]: { [string]: any } } = {}
local envoisPrevus: { [Player]: boolean } = {}

local function egal(a: any, b: any): boolean
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end
	for k, v in a do
		if not egal(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

-- ProfilMaj : seulement les champs de premier niveau modifiés depuis le dernier envoi (tout au premier).
local function envoyerProfil(joueur: Player)
	envoisPrevus[joueur] = nil
	local profil = Donnees.Obtenir(joueur)
	if not profil or not joueur.Parent then
		return
	end
	local precedent = envoyes[joueur] or {}
	envoyes[joueur] = precedent
	local modifies, nombre = {}, 0
	for champ, valeur in profil do
		if not PRIVES[champ] and not egal(valeur, precedent[champ]) then
			local copie = SchemaJoueur.Copie(valeur)
			modifies[champ] = copie
			precedent[champ] = copie
			nombre += 1
		end
	end
	joueur:SetAttribute("Gemmes", profil.Gemmes)
	if nombre > 0 then
		Reseau.Envoyer(joueur, "ProfilMaj", modifies)
	end
end

Donnees.Change:Connect(function(joueur: Player)
	if envoisPrevus[joueur] then
		return
	end
	envoisPrevus[joueur] = true
	task.delay(DELAI_ENVOI, envoyerProfil, joueur)
end)

local function surArrivee(joueur: Player)
	local ok, raison = Donnees.Charger(joueur)
	if not ok and raison ~= "Parti" and joueur.Parent then
		joueur:Kick(MESSAGES[raison] or MESSAGES.DataStore)
	end
end

Players.PlayerAdded:Connect(surArrivee)
for _, joueur in Players:GetPlayers() do
	task.spawn(surArrivee, joueur)
end

Players.PlayerRemoving:Connect(function(joueur: Player)
	envoisPrevus[joueur] = nil
	envoyes[joueur] = nil
	Donnees.Liberer(joueur)
end)

-- Réglages : liste blanche, modifiables depuis les deux places.
local function entre0et1(v: any): boolean
	return type(v) == "number" and v >= 0 and v <= 1
end
local function booleen(v: any): boolean
	return type(v) == "boolean"
end
local REGLAGES: { [string]: (any) -> boolean } = {
	VolumeMusique = entre0et1,
	VolumeEffets = entre0et1,
	EffetsReduits = booleen,
	Secousses = booleen,
	TirAuto = booleen,
}

Reseau.Brancher("DemandeReglage", function(joueur: Player, cleReglage: string, valeur: any)
	local valide = REGLAGES[cleReglage]
	if not valide or not valide(valeur) then
		Reseau.Refuser(joueur, "DemandeReglage", "Inconnue")
		return
	end
	local change = Donnees.Modifier(joueur, function(p)
		if p.Reglages[cleReglage] == valeur then
			return false
		end
		p.Reglages[cleReglage] = valeur
		return true
	end)
	if change then
		Donnees.Planifier(joueur)
	end
end)

-- Accueil de Doc Boulon (a50) : étape croissante, 1 à 12, sans aucune récompense.
Donnees.DefinirDeblocage("Accueil", function(joueur: Player, etape: any): boolean
	local numero = tonumber(etape)
	if not numero or numero ~= math.floor(numero) or numero > Catalogue.Accueil.Etapes then
		return false
	end
	return Donnees.Modifier(joueur, function(p)
		if numero <= p.AccueilEtape then
			return false
		end
		p.AccueilEtape = numero
		return true
	end)
end)

Reseau.Brancher("DemandeDeblocage", function(joueur: Player, genre: string, id: any)
	if Donnees.Debloquer(joueur, genre, id) then
		Donnees.Planifier(joueur)
	else
		Reseau.Refuser(joueur, "DemandeDeblocage", genre)
	end
end)

task.spawn(function()
	while true do
		task.wait(INTERVALLE_AUTOSAVE)
		Donnees.SauvegarderTous(false)
	end
end)

game:BindToClose(function()
	if Run then
		Run.Clore() -- reliquats de la run versés avant la libération des profils
	end
	Donnees.FermerTout()
end)
