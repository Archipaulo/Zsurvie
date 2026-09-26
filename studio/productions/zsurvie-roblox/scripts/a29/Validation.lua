-- ServerScriptService.Securite.Validation (ModuleScript)
--!strict
-- Seul créateur de remotes du jeu : construit ReplicatedStorage.Remotes depuis ReplicatedStorage.ReglesRemotes,
-- valide nombre, débit, format et cohérence de chaque demande, tient le score de suspicion de chaque Survivant.
-- Le contexte (distance, solde, cadence) reste chez le propriétaire du système.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsService = game:GetService("AnalyticsService")

local ReglesRemotes = require(ReplicatedStorage:WaitForChild("ReglesRemotes", 10) :: any) :: any

local SEUIL_EXCLUSION = 40
local DECROISSANCE = 1 / 3 -- points perdus par seconde
local TEXTE_MAX = 32
local MESSAGE = "Zsurvie a perdu la synchronisation avec ton appareil. Relance le jeu pour retrouver le Laboratoire !"

type Seau = { jetons: number, maj: number }
type Score = { points: number, maj: number, cumul: number }

local Validation = {}
local seaux: { [Player]: { [string]: Seau } } = {}
local scores: { [Player]: Score } = {}
local exclus: { [Player]: boolean } = {}
local branches: { [string]: boolean } = {}

local typePlace = workspace:GetAttribute("TypePlace")
assert(typePlace == "Prairie" or typePlace == "Laboratoire", "Attribut Workspace.TypePlace manquant")

local function fini(n: number): boolean
	return n == n and math.abs(n) ~= math.huge
end

local function verifier(v: any, arg: any): boolean
	if v == nil then
		return arg.optionnel == true
	elseif arg.type == "nombre" then
		return typeof(v) == "number" and fini(v) and (not arg.entier or v % 1 == 0)
			and v >= (arg.min or -math.huge) and v <= (arg.max or math.huge)
	elseif arg.type == "texte" then
		return typeof(v) == "string" and #v <= TEXTE_MAX and table.find(arg.valeurs or {}, v) ~= nil
	elseif arg.type == "booleen" then
		return typeof(v) == "boolean"
	elseif arg.type == "scalaire" then
		return typeof(v) == "boolean" or (typeof(v) == "number" and fini(v))
	elseif arg.type == "vecteur" then
		return typeof(v) == "Vector3" and fini(v.X) and fini(v.Y) and fini(v.Z)
			and Vector3.new(v.X, 0, v.Z).Magnitude <= (arg.rayon or 0) and math.abs(v.Y) <= 50
	end
	return false
end

function Validation.signaler(joueur: Player, points: number, raison: string)
	if exclus[joueur] or points <= 0 then
		return
	end
	local t = os.clock()
	local s = scores[joueur] or { points = 0, maj = t, cumul = 0 }
	s.points = math.max(0, s.points - (t - s.maj) * DECROISSANCE) + points
	s.maj = t
	s.cumul += points
	scores[joueur] = s
	if points >= 2 then
		warn(string.format("[AntiExploit] %s (%d) %s +%g = %.1f", joueur.Name, joueur.UserId, raison, points, s.points))
		pcall(function()
			AnalyticsService:LogCustomEvent(joueur, "AE_" .. raison, points)
		end)
	end
	if s.points >= SEUIL_EXCLUSION then
		exclus[joueur] = true
		joueur:Kick(MESSAGE)
	end
end

-- Tests d'acceptation : score courant (après décroissance) et total des points reçus depuis l'arrivée.
function Validation.bilan(joueur: Player): (number, number)
	local s = scores[joueur]
	if not s then
		return 0, 0
	end
	return math.max(0, s.points - (os.clock() - s.maj) * DECROISSANCE), s.cumul
end

function Validation.consommer(joueur: Player, cle: string, debit: number, rafale: number): boolean
	local parJoueur = seaux[joueur]
	if not parJoueur then
		parJoueur = {}
		seaux[joueur] = parJoueur
	end
	local t = os.clock()
	local seau = parJoueur[cle] or { jetons = rafale, maj = t }
	seau.jetons = math.min(rafale, seau.jetons + (t - seau.maj) * debit)
	seau.maj = t
	parJoueur[cle] = seau
	if seau.jetons < 1 then
		return false
	end
	seau.jetons -= 1
	return true
end

-- Création des remotes de la place ; les remotes descendantes deviennent des pièges.
local dossier = Instance.new("Folder")
dossier.Name = "Remotes"
for nom, regle in ReglesRemotes.remotes do
	if regle.place == typePlace or regle.place == "Toutes" then
		local remote: any = if regle.nonFiable then Instance.new("UnreliableRemoteEvent") else Instance.new("RemoteEvent")
		remote.Name = nom
		if regle.descendant then
			remote.OnServerEvent:Connect(function(joueur: Player)
				Validation.signaler(joueur, 20, "RemoteDescendante")
			end)
		end
		remote.Parent = dossier
	end
end
dossier.Parent = ReplicatedStorage

-- Seul point d'entrée des demandes client : une connexion par remote, sinon double effet.
function Validation.brancher(nom: string, traitement: (Player, ...any) -> ())
	local regle = ReglesRemotes.remotes[nom]
	assert(regle and not regle.descendant, "Remote montante inconnue : " .. nom)
	assert(not branches[nom], "Remote déjà branchée : " .. nom)
	local remote = dossier:FindFirstChild(nom)
	assert(remote and remote:IsA("RemoteEvent"), "Remote absente de cette place : " .. nom)
	branches[nom] = true
	local nbArgs = #regle.args
	remote.OnServerEvent:Connect(function(joueur: Player, ...: any)
		if exclus[joueur] then
			return
		end
		if select("#", ...) > nbArgs then
			Validation.signaler(joueur, 10, "ArgsEnTrop")
			return
		end
		if not Validation.consommer(joueur, nom, regle.debit, regle.rafale) then
			Validation.signaler(joueur, 0.5, "Flood")
			return
		end
		for i, arg in regle.args do
			if not verifier((select(i, ...)), arg) then
				Validation.signaler(joueur, 10, "Format")
				return
			end
		end
		if regle.coherence and not regle.coherence(...) then
			Validation.signaler(joueur, 10, "Format")
			return
		end
		traitement(joueur, ...)
	end)
end

-- Remote descendante pour Reseau (a27) : EtatHorde, PingDiffuse (FireClient, FireAllClients).
function Validation.remote(nom: string): Instance
	local regle = ReglesRemotes.remotes[nom]
	assert(regle and regle.descendant, "Remote descendante inconnue : " .. nom)
	local remote = dossier:FindFirstChild(nom)
	assert(remote, "Remote absente de cette place : " .. nom)
	return remote
end

Players.PlayerRemoving:Connect(function(joueur)
	seaux[joueur] = nil
	scores[joueur] = nil
	exclus[joueur] = nil
end)

return Validation
