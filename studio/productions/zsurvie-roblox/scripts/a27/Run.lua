-- ServerScriptService.Modules.Run (ModuleScript) : la run de la Prairie (serveur réservé, MaxPlayers 6)
-- Run.Demarrer() (appelé par Persistance) crée ReplicatedStorage.EtatRun, lit la fiche Capsules, puis écrit
-- RunEnCours_<UserId> à chaque arrivée. a29 appelle Run.JourFranchi(jour) et Run.Terminer(totaux, jour).
-- Workspace ne porte que TypePlace, CentrePlace et RayonPlace : l'état de la run vit dans EtatRun.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reseau = require(ReplicatedStorage:WaitForChild("Reseau"))
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Donnees = require(script.Parent.Donnees)
local Passage = require(script.Parent.Passage)

local ECRAN_FIN = 12 -- s d'écran de fin avant le retour au Laboratoire
local ATTENTE_PROFIL = 40 -- s : chargement du profil à l'arrivée (verrou du Laboratoire compris)

-- Attributs de ReplicatedStorage.EtatRun. Phase : "Horde" | "Repit" | "Colosse" ; FinPhase : GetServerTimeNow().
-- Niv_* : niveaux d'Établi partagés par l'équipe ; Cagnotte_* : pièces versées vers le niveau suivant.
local ETAT_INITIAL = {
	Mode = "Normale",
	Jour = 0,
	Phase = "Repit",
	FinPhase = 0,
	Niv_Solidite = 0,
	Niv_Reparation = 0,
	Niv_Regeneration = 0,
	Cagnotte_Solidite = 0,
	Cagnotte_Reparation = 0,
	Cagnotte_Regeneration = 0,
}

local Run = {}
Run.Id = HttpService:GenerateGUID(false) -- runId : clé d'idempotence de Donnees.CrediterRun
Run.Fiche = nil :: Passage.Fiche?
Run.Etat = nil :: Configuration?
Run.Terminee = false
-- Fourni par a29 : totaux de gemmes de la run par UserId, lus si le serveur ferme avant la fin (Run.Clore).
Run.CalculerTotaux = nil :: (() -> { [number]: number })?

local participants: { [number]: boolean } = {}

local function attendreProfil(joueur: Player): boolean
	local debut = os.clock()
	while joueur.Parent and joueur:GetAttribute("DonneesChargees") ~= true do
		if os.clock() - debut > ATTENTE_PROFIL then
			return false
		end
		task.wait(0.5)
	end
	return joueur.Parent ~= nil
end

-- « Record : Jour X » au-dessus de la Maison : meilleur jour des Survivants présents.
local function afficherRecord()
	local maison = workspace:FindFirstChild("Maison")
	if not maison then
		return
	end
	local record = 0
	for _, joueur in Players:GetPlayers() do
		local profil = Donnees.Obtenir(joueur)
		if profil then
			record = math.max(record, profil.Records.MeilleurJour)
		end
	end
	maison:SetAttribute("Record", record)
end

local function accueillir(joueur: Player)
	participants[joueur.UserId] = true
	if not attendreProfil(joueur) then
		return
	end
	local fiche = Run.Fiche :: Passage.Fiche
	if Run.Terminee or fiche.Terminee then
		Passage.Teleporter({ joueur }, Catalogue.Places.Laboratoire) -- run finie : retour au Laboratoire
		return
	end
	Passage.NoterRunEnCours(joueur.UserId, fiche)
	afficherRecord()
end

local function oublierRun()
	task.spawn(Passage.TerminerFiche)
	for userId in participants do
		task.spawn(Passage.OublierRunEnCours, userId)
	end
end

function Run.Demarrer()
	assert(workspace:GetAttribute("TypePlace") == "Prairie", "Run.Demarrer : place Prairie uniquement")
	assert(not ReplicatedStorage:FindFirstChild("EtatRun"), "ReplicatedStorage.EtatRun existe déjà")
	local etat = Instance.new("Configuration")
	etat.Name = "EtatRun"
	for nom, valeur in ETAT_INITIAL do
		etat:SetAttribute(nom, valeur)
	end
	etat.Parent = ReplicatedStorage
	Run.Etat = etat

	local fiche = Passage.LireFiche()
	Run.Fiche = fiche
	etat:SetAttribute("Mode", fiche.Mode)

	Players.PlayerAdded:Connect(accueillir)
	for _, joueur in Players:GetPlayers() do
		task.spawn(accueillir, joueur)
	end
end

-- a29, à chaque jour franchi, après ses AjouterGemmes(joueur, n, "Jour", Run.Id) : sauvegarde (canon).
function Run.JourFranchi(jour: number)
	local etat = Run.Etat :: Configuration
	etat:SetAttribute("Jour", jour)
	Donnees.SauvegarderTous(true)
	for _, joueur in Players:GetPlayers() do
		task.spawn(Passage.NoterRunEnCours, joueur.UserId, Run.Fiche)
	end
end

-- a29, quand la Maison tombe. totaux[UserId] = gemmes totales de la run (jours, Mine, Doré, bonus de fin).
-- CrediterRun ne verse que le reliquat : les jours déjà payés ne le sont jamais deux fois.
function Run.Terminer(totaux: { [number]: number }, jour: number)
	if Run.Terminee then
		return
	end
	Run.Terminee = true
	for _, joueur in Players:GetPlayers() do
		Donnees.CrediterRun(joueur, Run.Id, totaux[joueur.UserId] or 0, true)
		Donnees.Modifier(joueur, function(p)
			if jour <= p.Records.MeilleurJour then
				return false
			end
			p.Records.MeilleurJour = jour
			return true
		end)
		Reseau.Annoncer(joueur, "FinDeRun", { Jour = jour, Gemmes = totaux[joueur.UserId] or 0 })
	end
	oublierRun()
	task.wait(ECRAN_FIN)
	Passage.Teleporter(Players:GetPlayers(), Catalogue.Places.Laboratoire)
end

-- BindToClose de la Prairie (via Persistance), avant Donnees.FermerTout : verse les reliquats et clôt la run.
function Run.Clore()
	if Run.Terminee then
		return
	end
	Run.Terminee = true
	local ok, totaux = pcall(function()
		return if Run.CalculerTotaux then Run.CalculerTotaux() else {}
	end)
	for _, joueur in Players:GetPlayers() do
		local total = if ok and type(totaux) == "table" then totaux[joueur.UserId] or 0 else 0
		Donnees.CrediterRun(joueur, Run.Id, total, true)
	end
	oublierRun()
end

return Run
