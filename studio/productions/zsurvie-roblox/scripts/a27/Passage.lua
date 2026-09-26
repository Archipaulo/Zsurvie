-- ServerScriptService.Modules.Passage (ModuleScript) : Laboratoire <-> Prairie, dans les deux places
-- Règle : TeleportAsync seulement après un Donnees.Liberer réussi (3 essais). Sinon la session reste sur ce
-- serveur, l'UI affiche « Sauvegarde… » (Annonce "Sauvegarde") et on réessaie toutes les 15 s, 4 fois.
-- MemoryStore : Capsules[privateServerId] (fiche de run) et RunsEnCours["RunEnCours_<UserId>"], TTL 1 800 s.
-- Jamais de TeleportData : il transite par le client.

local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Temps = require(ReplicatedStorage:WaitForChild("Temps"))
local Donnees = require(script.Parent.Donnees)

local TTL = 1800 -- s : une run dure 25 min au plus (canon), plus le trajet
local ESSAIS_MEMOIRE = 3
local ATTENTE_SAUVEGARDE = 15
local TOURS_SAUVEGARDE = 4

local fiches = MemoryStoreService:GetHashMap("Capsules")
local runsEnCours = MemoryStoreService:GetHashMap("RunsEnCours")

export type Fiche = {
	Mode: string, -- "Normale" | "Difficile" | "DuJour"
	CleJour: string, -- Temps.cleJour() au départ : modificateurs du Défi du Jour
	UserIds: { number },
	Code: string?, -- ReservedServerAccessCode (nil en Studio)
	Terminee: boolean,
}

local Passage = {}

local enPassage: { [Player]: boolean } = {}

local function essayer(etiquette: string, fn: () -> any): (boolean, any)
	for essai = 1, ESSAIS_MEMOIRE do
		local ok, resultat = pcall(fn)
		if ok then
			return true, resultat
		end
		warn(`[Passage] {etiquette} : échec {essai}/{ESSAIS_MEMOIRE} ({resultat})`)
		task.wait(essai)
	end
	return false, nil
end

local function cleRun(userId: number): string
	return `RunEnCours_{userId}`
end

local function ficheLocale(): Fiche
	return { Mode = "Normale", CleJour = Temps.cleJour(), UserIds = {}, Code = nil, Terminee = false }
end

-- Téléport refusé ou avorté : le joueur est toujours ici, on reprend son profil.
local function recharger(joueur: Player)
	enPassage[joueur] = nil
	if not joueur.Parent then
		return
	end
	if Donnees.Charger(joueur) then
		Reseau.Annoncer(joueur, "PassageAnnule", { Raison = "Teleport" })
	elseif joueur.Parent then
		joueur:Kick("Le voyage a échoué. Tes gemmes sont sauvegardées : relance Zsurvie !")
	end
end

-- Envoie des joueurs déjà libérés.
local function envoyer(joueurs: { Player }, placeId: number, code: string?)
	local options = Instance.new("TeleportOptions")
	if code then
		options.ReservedServerAccessCode = code
	end
	local ok, erreur = pcall(function()
		TeleportService:TeleportAsync(placeId, joueurs, options)
	end)
	if not ok then
		warn(`[Passage] TeleportAsync : {erreur}`)
		for _, joueur in joueurs do
			task.spawn(recharger, joueur)
		end
	end
end

-- Libère en parallèle ; Donnees.Liberer(joueur, true) garde la session en cas d'échec.
local function liberer(joueurs: { Player }): ({ Player }, { Player })
	local prets, retenus = {}, {}
	local restants = #joueurs
	for _, joueur in joueurs do
		task.spawn(function()
			if Donnees.Liberer(joueur, true) then
				table.insert(prets, joueur)
			else
				table.insert(retenus, joueur)
			end
			restants -= 1
		end)
	end
	while restants > 0 do
		task.wait(0.1)
	end
	return prets, retenus
end

local function reessayer(joueur: Player, placeId: number, code: string?)
	for _ = 1, TOURS_SAUVEGARDE do
		Reseau.Annoncer(joueur, "Sauvegarde", { Echec = true, Prochain = ATTENTE_SAUVEGARDE })
		task.wait(ATTENTE_SAUVEGARDE)
		if not joueur.Parent then
			return
		end
		if Donnees.Liberer(joueur, true) then
			envoyer({ joueur }, placeId, code)
			return
		end
	end
	enPassage[joueur] = nil
	Reseau.Annoncer(joueur, "PassageAnnule", { Raison = "Sauvegarde" })
end

function Passage.Teleporter(joueurs: { Player }, placeId: number, code: string?)
	assert(placeId ~= 0, "Catalogue.Places : PlaceId à renseigner")
	local candidats = {}
	for _, joueur in joueurs do
		if joueur.Parent and not enPassage[joueur] then
			enPassage[joueur] = true
			Reseau.Annoncer(joueur, "Sauvegarde", { Echec = false })
			table.insert(candidats, joueur)
		end
	end
	if #candidats == 0 then
		return
	end
	local prets, retenus = liberer(candidats)
	local presents = {}
	for _, joueur in prets do
		if joueur.Parent then
			table.insert(presents, joueur)
		end
	end
	if #presents > 0 then
		envoyer(presents, placeId, code)
	end
	for _, joueur in retenus do
		task.spawn(reessayer, joueur, placeId, code)
	end
end

-- Laboratoire : réserve une Prairie, écrit la fiche, puis téléporte la Capsule. false = départ annulé.
function Passage.LancerRun(passagers: { Player }, mode: string): boolean
	local ok, code, idPrive = pcall(function()
		return TeleportService:ReserveServer(Catalogue.Places.Prairie)
	end)
	if not ok then
		warn(`[Passage] ReserveServer : {code}`)
		return false
	end
	local ids = {}
	for _, joueur in passagers do
		table.insert(ids, joueur.UserId)
	end
	local fiche: Fiche = { Mode = mode, CleJour = Temps.cleJour(), UserIds = ids, Code = code, Terminee = false }
	if not essayer("Fiche Capsules", function()
		fiches:SetAsync(idPrive, fiche, TTL)
	end) then
		return false
	end
	Passage.Teleporter(passagers, Catalogue.Places.Prairie, code)
	return true
end

-- Prairie : fiche écrite par le Laboratoire (fiche locale en Studio ou si elle a disparu).
function Passage.LireFiche(): Fiche
	if RunService:IsStudio() or game.PrivateServerId == "" then
		return ficheLocale()
	end
	for _ = 1, 5 do
		local ok, fiche = essayer("Lecture fiche", function()
			return fiches:GetAsync(game.PrivateServerId)
		end)
		if ok and type(fiche) == "table" then
			return fiche
		end
		task.wait(2)
	end
	warn("[Passage] Fiche Capsules introuvable : run Normale, sans « Rejoindre la run »")
	return ficheLocale()
end

function Passage.TerminerFiche()
	if game.PrivateServerId == "" then
		return
	end
	essayer("Fin de fiche", function()
		fiches:UpdateAsync(game.PrivateServerId, function(fiche)
			if type(fiche) ~= "table" then
				return nil
			end
			fiche.Terminee = true
			return fiche
		end, TTL)
	end)
end

-- Prairie : à l'arrivée et à chaque jour franchi (prolonge le TTL).
function Passage.NoterRunEnCours(userId: number, fiche: Fiche)
	if not fiche.Code then
		return
	end
	essayer("RunEnCours", function()
		runsEnCours:SetAsync(cleRun(userId), { Code = fiche.Code, Mode = fiche.Mode }, TTL)
	end)
end

function Passage.OublierRunEnCours(userId: number)
	essayer("Oubli RunEnCours", function()
		runsEnCours:RemoveAsync(cleRun(userId))
	end)
end

function Passage.LireRunEnCours(userId: number): { Code: string, Mode: string }?
	local ok, run = essayer("Lecture RunEnCours", function()
		return runsEnCours:GetAsync(cleRun(userId))
	end)
	return if ok and type(run) == "table" then run else nil
end

-- Laboratoire : « Rejoindre la run ». false si la run est finie ou introuvable.
function Passage.Rejoindre(joueur: Player): boolean
	local run = Passage.LireRunEnCours(joueur.UserId)
	if not run then
		return false
	end
	Passage.Teleporter({ joueur }, Catalogue.Places.Prairie, run.Code)
	return true
end

TeleportService.TeleportInitFailed:Connect(function(joueur: Player, resultat: Enum.TeleportResult, message: string)
	if enPassage[joueur] then
		warn(`[Passage] Téléport de {joueur.Name} échoué : {resultat.Name} ({message})`)
		recharger(joueur)
	end
end)

Players.PlayerRemoving:Connect(function(joueur)
	enPassage[joueur] = nil
end)

return Passage
