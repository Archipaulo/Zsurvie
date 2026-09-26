-- ReplicatedStorage.Reseau (ModuleScript) : le seul module réseau de Zsurvie, partagé serveur et client
-- Enfant obligatoire : ReplicatedStorage.Reseau.ReglesRemotes (table a29). Aucun autre script ne crée de remote.
-- Serveur : Reseau.Initialiser() génère ReplicatedStorage.Remotes ; Reseau.Brancher(nom, fn) pose l'unique
--           gestionnaire d'une demande derrière la garde. Validation.brancher (a29) délègue à Reseau.Brancher.
-- Client  : Reseau.Obtenir("DemandeTir"):FireServer(idZbire) ; Reseau.SurFait(fn) ; Reseau.LireEtatZbires(b, fn).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Regles = require(script:WaitForChild("ReglesRemotes"))

export type EtatZbire = { Id: number, Type: number, Position: Vector3, PV: number, PVMax: number }

local NOM_DOSSIER = "Remotes"
local LONGUEUR_MAX_CHAINE = 32
local NORME_MAX_VECTEUR = 100000
local REFUS_AVANT_ALERTE = 50

local OCTETS_ZBIRE = 9 -- u16 id, u8 type, i16 X x 100, i16 Z x 100, u8 Y x 10, u8 PV sur 255
local ZBIRES_MAX = 61 -- 60 Zbires + le Colosse = 549 octets
local OCTETS_FAIT = 8 -- u8 code, u16 id, i16 X x 100, i16 Z x 100, u8 argument
local FAITS_MAX = 100 -- 800 octets, sous les 900 octets d'un UnreliableRemoteEvent
local PERIODE_FAITS = 0.1 -- 10 Hz
local ECHELLE = 100 -- centièmes de stud, relatifs à Workspace.CentrePlace : ±327 studs (arène : ±110)

local Reseau = {}
Reseau.Regles = Regles

-- Codes partagés par EtatZbires (octet type) et Evenements (argument d'Apparition).
Reseau.TypesZbire = table.freeze({
	Marcheur = 1,
	Rapide = 2,
	Costaud = 3,
	Dore = 4,
	Sauteur = 5,
	Gluant = 6,
	MiniGluant = 7,
	Volant = 8,
	Casque = 9,
	Colosse = 10,
})

-- Codes du flux Evenements : fait (code, id, X, Z, argument).
Reseau.Faits = table.freeze({
	Apparition = 1, -- id Zbire, argument = TypesZbire
	Coup = 2, -- id Zbire, argument = dégâts (0-255)
	Critique = 3, -- id Zbire, argument = dégâts (0-255)
	Eclatement = 4, -- id Zbire vaincu (éclat en cubes), argument = pièces lâchées
	Division = 5, -- id Gluant, argument = Mini-Gluants créés (2)
	EtatZbire = 6, -- id Zbire, argument = état (a38, a39)
	Etourdi = 7, -- id = Player.Numero (1-6), argument = dixièmes de seconde (20)
	DefensePosee = 8, -- id défense, argument = 1 Muret, 2 Mini-Tourelle, 3 Tapis Collant
	DefenseRetiree = 9, -- id défense
	MaisonTouchee = 10, -- id 0, argument = PV de la Maison sur 255
	Reparation = 11, -- id = Player.Numero, argument = PV de la Maison sur 255
})

local dossier: Folder? = nil
local branches: { [string]: boolean } = {}
local seaux: { [Player]: { [string]: { jetons: number, t: number } } } = {}
local refus: { [Player]: number } = {}
local faits = buffer.create(FAITS_MAX * OCTETS_FAIT)
local nbFaits = 0
local ecouteurs: { (number, number, Vector3, number) -> () } = {}
local clientBranche = false

local function centrePlace(): Vector3
	local centre = workspace:GetAttribute("CentrePlace")
	return if typeof(centre) == "Vector3" then centre else Vector3.zero
end

local function borneI16(v: number): number
	return math.clamp(math.round(v), -32768, 32767)
end

local function borneU8(v: number): number
	return math.clamp(math.round(v), 0, 255)
end

-- Vérifie une valeur reçue du client contre le type attendu.
local function typeValide(valeur: any, attendu: string): boolean
	if string.sub(attendu, -1) == "?" then
		if valeur == nil then
			return true
		end
		attendu = string.sub(attendu, 1, -2)
	end
	local reel = typeof(valeur)
	for option in string.gmatch(attendu, "[^|]+") do
		if reel == option then
			if reel == "number" then
				return valeur == valeur and math.abs(valeur) ~= math.huge -- rejette NaN et ±inf
			elseif reel == "string" then
				return #valeur <= LONGUEUR_MAX_CHAINE
			elseif reel == "Vector3" then
				local norme = valeur.Magnitude
				return norme == norme and norme <= NORME_MAX_VECTEUR
			end
			return true
		end
	end
	return false
end

local function argumentsValides(regle, ...: any): boolean
	local types = regle.Types or {}
	if select("#", ...) > #types then
		return false
	end
	for index, attendu in types do
		if not typeValide((select(index, ...)), attendu) then
			return false
		end
	end
	return true
end

-- Seau de jetons par joueur et par demande.
local function autoriser(joueur: Player, nom: string, regle): boolean
	local parJoueur = seaux[joueur]
	if not parJoueur then
		parJoueur = {}
		seaux[joueur] = parJoueur
	end
	local debit = regle.ParSeconde or 1
	local capacite = regle.Rafale or math.max(1, debit)
	local maintenant = os.clock()
	local seau = parJoueur[nom]
	if not seau then
		seau = { jetons = capacite, t = maintenant }
		parJoueur[nom] = seau
	end
	seau.jetons = math.min(capacite, seau.jetons + (maintenant - seau.t) * debit)
	seau.t = maintenant
	if seau.jetons < 1 then
		return false
	end
	seau.jetons -= 1
	return true
end

local function noterRefus(joueur: Player, nom: string)
	local total = (refus[joueur] or 0) + 1
	refus[joueur] = total
	if total % REFUS_AVANT_ALERTE == 0 then
		warn(`[Reseau] {joueur.Name} ({joueur.UserId}) : {total} demandes refusées, dernière sur {nom}`)
	end
end

local function compterDossiers(): number
	local total = 0
	for _, enfant in ReplicatedStorage:GetChildren() do
		if enfant.Name == NOM_DOSSIER then
			total += 1
		end
	end
	return total
end

local function viderFaits()
	if nbFaits == 0 then
		return
	end
	local paquet = buffer.create(nbFaits * OCTETS_FAIT)
	buffer.copy(paquet, 0, faits, 0, nbFaits * OCTETS_FAIT)
	nbFaits = 0
	Reseau.Obtenir("Evenements"):FireAllClients(paquet)
end

function Reseau.Initialiser()
	assert(RunService:IsServer(), "Reseau.Initialiser est réservé au serveur")
	if dossier then
		return
	end
	assert(compterDossiers() == 0, "ReplicatedStorage.Remotes existe déjà : seul Reseau crée ce dossier")
	local nouveau = Instance.new("Folder")
	nouveau.Name = NOM_DOSSIER
	for nom, regle in Regles do
		local estDemande = regle.Sens == "C2S"
		assert(
			regle.Classe == "RemoteEvent" or (regle.Classe == "UnreliableRemoteEvent" and not estDemande),
			`{nom} : RemoteEvent uniquement (UnreliableRemoteEvent pour les flux serveur)`
		)
		assert(estDemande == (string.sub(nom, 1, 7) == "Demande"), `{nom} : seules les demandes client s'appellent Demande*`)
		local remote = Instance.new(regle.Classe)
		remote.Name = nom
		remote.Parent = nouveau
	end
	nouveau.Parent = ReplicatedStorage
	dossier = nouveau
	assert(compterDossiers() == 1, "Un seul enfant Remotes est permis dans ReplicatedStorage")
	task.delay(10, function()
		assert(compterDossiers() == 1, "Un second dossier Remotes est apparu : un script crée encore ses propres remotes")
	end)

	Players.PlayerRemoving:Connect(function(joueur)
		seaux[joueur] = nil
		refus[joueur] = nil
	end)

	local cumul = 0
	RunService.Heartbeat:Connect(function(dt)
		cumul += dt
		if cumul >= PERIODE_FAITS then
			cumul = 0
			viderFaits()
		end
	end)
end

function Reseau.Obtenir(nom: string): any
	assert(Regles[nom], `Remote inconnu : {nom}`)
	if RunService:IsServer() then
		Reseau.Initialiser()
		return (dossier :: Folder):FindFirstChild(nom)
	end
	return ReplicatedStorage:WaitForChild(NOM_DOSSIER):WaitForChild(nom)
end

-- Serveur : l'unique gestionnaire d'une demande. Garde : profil chargé, débit, nombre et types des arguments.
function Reseau.Brancher(nom: string, gestionnaire: (Player, ...any) -> ...any)
	local regle = Regles[nom]
	assert(regle and regle.Sens == "C2S", `{nom} n'est pas une demande client`)
	assert(not branches[nom], `{nom} a déjà un gestionnaire : une demande n'en a qu'un`)
	branches[nom] = true
	Reseau.Obtenir(nom).OnServerEvent:Connect(function(joueur: Player, ...: any)
		if joueur:GetAttribute("DonneesChargees") ~= true
			or not autoriser(joueur, nom, regle)
			or not argumentsValides(regle, ...)
		then
			noterRefus(joueur, nom)
			return
		end
		local ok, erreur = pcall(gestionnaire, joueur, ...)
		if not ok then
			warn(`[Reseau] {nom} : {erreur}`)
		end
	end)
end

function Reseau.Envoyer(joueur: Player, nom: string, ...: any)
	assert(Regles[nom] and Regles[nom].Sens == "S2C", `{nom} n'est pas un retour serveur`)
	Reseau.Obtenir(nom):FireClient(joueur, ...)
end

function Reseau.Diffuser(nom: string, ...: any)
	assert(Regles[nom] and Regles[nom].Sens == "S2C", `{nom} n'est pas un retour serveur`)
	Reseau.Obtenir(nom):FireAllClients(...)
end

-- Toutes les réponses aux demandes passent par Annonce.
function Reseau.Annoncer(joueur: Player, code: string, donnees: { [string]: any }?)
	Reseau.Envoyer(joueur, "Annonce", code, donnees)
end

function Reseau.Refuser(joueur: Player, demande: string, raison: string?)
	Reseau.Annoncer(joueur, "Refus", { Demande = demande, Raison = raison or "Refuse" })
end

-- Serveur, 10 Hz : l'état des Zbires en un seul buffer (a26).
function Reseau.DiffuserEtatZbires(zbires: { EtatZbire })
	local centre = centrePlace()
	local n = math.min(#zbires, ZBIRES_MAX)
	local b = buffer.create(n * OCTETS_ZBIRE)
	for i = 1, n do
		local z = zbires[i]
		local o = (i - 1) * OCTETS_ZBIRE
		local relatif = z.Position - centre
		buffer.writeu16(b, o, z.Id % 65536)
		buffer.writeu8(b, o + 2, z.Type)
		buffer.writei16(b, o + 3, borneI16(relatif.X * ECHELLE))
		buffer.writei16(b, o + 5, borneI16(relatif.Z * ECHELLE))
		buffer.writeu8(b, o + 7, borneU8(relatif.Y * 10))
		buffer.writeu8(b, o + 8, if z.PVMax > 0 then borneU8(z.PV / z.PVMax * 255) else 0)
	end
	Reseau.Obtenir("EtatZbires"):FireAllClients(b)
end

-- Client : fn(id, type, position, pv de 0 à 1) pour chaque Zbire du paquet.
function Reseau.LireEtatZbires(b: buffer, fn: (number, number, Vector3, number) -> ())
	local centre = centrePlace()
	for o = 0, buffer.len(b) - OCTETS_ZBIRE, OCTETS_ZBIRE do
		local position = centre
			+ Vector3.new(buffer.readi16(b, o + 3) / ECHELLE, buffer.readu8(b, o + 7) / 10, buffer.readi16(b, o + 5) / ECHELLE)
		fn(buffer.readu16(b, o), buffer.readu8(b, o + 2), position, buffer.readu8(b, o + 8) / 255)
	end
end

-- Serveur : ajoute un fait au paquet Evenements, envoyé toutes les 0,1 s (tout de suite si 100 faits attendent).
function Reseau.AjouterFait(code: number, id: number, position: Vector3?, argument: number?)
	assert(RunService:IsServer(), "Reseau.AjouterFait est réservé au serveur")
	if nbFaits >= FAITS_MAX then
		viderFaits()
	end
	local o = nbFaits * OCTETS_FAIT
	local relatif = if position then position - centrePlace() else Vector3.zero
	buffer.writeu8(faits, o, code)
	buffer.writeu16(faits, o + 1, id % 65536)
	buffer.writei16(faits, o + 3, borneI16(relatif.X * ECHELLE))
	buffer.writei16(faits, o + 5, borneI16(relatif.Z * ECHELLE))
	buffer.writeu8(faits, o + 7, borneU8(argument or 0))
	nbFaits += 1
end

-- Client : fn(code, id, position, argument). Un seul décodage par paquet, partagé par VfxClient, Son,
-- ZbireAnimateur et l'UI : chacun joue sa part (image, son, animation), jamais deux fois la même.
function Reseau.SurFait(fn: (number, number, Vector3, number) -> ())
	assert(RunService:IsClient(), "Reseau.SurFait est réservé au client")
	table.insert(ecouteurs, fn)
	if clientBranche then
		return
	end
	clientBranche = true
	Reseau.Obtenir("Evenements").OnClientEvent:Connect(function(paquet: buffer)
		local centre = centrePlace()
		for o = 0, buffer.len(paquet) - OCTETS_FAIT, OCTETS_FAIT do
			local code = buffer.readu8(paquet, o)
			local id = buffer.readu16(paquet, o + 1)
			local position = centre + Vector3.new(buffer.readi16(paquet, o + 3) / ECHELLE, 0, buffer.readi16(paquet, o + 5) / ECHELLE)
			local argument = buffer.readu8(paquet, o + 7)
			for _, ecouteur in ecouteurs do
				local ok, erreur = pcall(ecouteur, code, id, position, argument)
				if not ok then
					warn(`[Reseau] Écouteur Evenements : {erreur}`)
				end
			end
		end
	end)
end

return Reseau
