-- ServerScriptService.Modules.Donnees (ModuleScript) : la seule persistance des Survivants, dans les deux places
-- Store unique Zsurvie_Joueurs_v1, clé J_<UserId> (Studio : Zsurvie_Joueurs_Studio). UpdateAsync uniquement,
-- verrou de session, pcall et nouvelles tentatives, une écriture toutes les 7 s par clé au plus.
-- Toute hausse de Gemmes passe par verser() : AjouterGemmes, CrediterRun, RecompenseDefiDuJour, RecolterForeuse.
-- Gemmes_v1, Zsurvie_Profils_v1, Boutique_v1, Cosmetiques_v1 et PeluchesSecretes_v1 n'existent plus.

local AnalyticsService = game:GetService("AnalyticsService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SchemaJoueur = require(script.Parent.SchemaJoueur)
local Catalogue = require(ReplicatedStorage:WaitForChild("Catalogue"))
local Temps = require(ReplicatedStorage:WaitForChild("Temps"))

local NOM_STORE = if RunService:IsStudio() then "Zsurvie_Joueurs_Studio" else "Zsurvie_Joueurs_v1"
local store = DataStoreService:GetDataStore(NOM_STORE)

local ESSAIS_MAX = 5 -- tentatives par requête : attentes 1, 2, 4, 8 s
local ESSAIS_FERMETURE = 3 -- pendant BindToClose (30 s accordées par Roblox)
local ESSAIS_PASSAGE = 3 -- Liberer avant une téléportation
local ESSAIS_VERROU = 10 -- 10 x 3 s d'attente d'une session ouverte ailleurs, puis reprise forcée
local DELAI_VERROU = 3
local VERROU_EXPIRE = 180 -- s : un verrou non rafraîchi depuis 3 min appartient à un serveur mort
local ECART_ECRITURE = 7 -- s entre deux écritures d'une même clé (limite Roblox : 6 s)
local AUTO_MIN = 45 -- l'autosave saute un profil écrit il y a moins de 45 s
local FERMETURE_MAX = 27 -- s d'attente dans BindToClose
local VERSIONS_EXAMINEES = 10 -- versions relues pour restaurer un profil corrompu
local RUNS_TERMINEES_MAX = 20

-- Plafond par appel et par source. Aucune autre source de gemmes n'existe (ZbireSemaine supprimée).
local PLAFONDS_GEMMES: { [string]: number } = {
	Jour = 210, -- J15 : 70 x 1,5 (Difficile) x 2 (week-end bonus)
	Mine = 200,
	Dore = 50,
	FinDeRun = 1500,
	Foreuse = Catalogue.Foreuse.PlafondParHeure * Catalogue.Foreuse.HeuresMax, -- 27 x 8 = 216
	DefiDuJour = Catalogue.DefiDuJour.Gemmes, -- 150
}
-- Sources de la Prairie : runId obligatoire, cumulées dans RunsCreditees[runId].
local SOURCES_RUN = { Jour = true, Mine = true, Dore = true, FinDeRun = true }

type Profil = { [string]: any }
type Session = {
	Id: string,
	Donnees: Profil,
	Sale: boolean, -- modifié depuis la dernière écriture réussie
	EnCours: boolean, -- une écriture est en vol
	Planifiee: boolean, -- une boucle Planifier tourne
	Liberation: boolean, -- sauvegarde finale en cours : plus aucune modification
	Perdue: boolean, -- verrou repris par un autre serveur : on n'écrit plus jamais
	DerniereEcriture: number, -- os.clock()
}

local Donnees = {}

local sessions: { [Player]: Session } = {}
local deblocages: { [string]: (Player, any) -> boolean } = {}
local fermeture = false

local signalChange = Instance.new("BindableEvent")
Donnees.Change = signalChange.Event -- (joueur) après chaque modification du profil

local function cle(joueur: Player): string
	return "J_" .. joueur.UserId
end

local function attendreBudget()
	local debut = os.clock()
	while DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) < 1
		and os.clock() - debut < 5
	do
		task.wait(0.5)
	end
end

-- Exécute fn sous pcall avec nouvelles tentatives et attente exponentielle.
local function avecEssais(etiquette: string, fn: () -> any, maximum: number?): (boolean, any)
	local essais = maximum or (if fermeture then ESSAIS_FERMETURE else ESSAIS_MAX)
	local erreur = nil
	for essai = 1, essais do
		attendreBudget()
		local ok, resultat = pcall(fn)
		if ok then
			return true, resultat
		end
		erreur = resultat
		warn(`[Donnees] {etiquette} : échec {essai}/{essais} ({resultat})`)
		if essai < essais then
			task.wait(2 ^ (essai - 1))
		end
	end
	return false, erreur
end

local function nouveauVerrou(id: string): { [string]: any }
	return { Id = id, JobId = game.JobId, PlaceId = game.PlaceId, Horodatage = os.time() }
end

-- Écrit le profil si et seulement si ce serveur tient encore le verrou.
local function ecrire(joueur: Player, session: Session, liberer: boolean, essais: number?): boolean
	while session.EnCours do
		task.wait(0.1)
	end
	if session.Perdue then
		return false
	end
	session.EnCours = true

	local attente = ECART_ECRITURE - (os.clock() - session.DerniereEcriture)
	if attente > 0 then
		task.wait(attente)
	end

	session.Sale = false
	local refuse = false
	local ok = avecEssais(`Sauvegarde {cle(joueur)}`, function()
		return store:UpdateAsync(cle(joueur), function(ancien)
			local verrou = if type(ancien) == "table" then ancien.Verrou else nil
			if type(verrou) ~= "table" or verrou.Id ~= session.Id then
				refuse = true
				return nil -- un autre serveur a repris la session : on n'écrase rien
			end
			refuse = false
			local profil = session.Donnees
			profil.Verrou = if liberer then nil else nouveauVerrou(session.Id)
			profil.DerniereSauvegarde = os.time()
			return profil, { joueur.UserId }
		end)
	end, essais)

	session.DerniereEcriture = os.clock()
	session.EnCours = false

	if ok and refuse then
		session.Perdue = true
		warn(`[Donnees] Session de {joueur.Name} reprise par un autre serveur : écriture annulée`)
		return false
	end
	if not ok then
		session.Sale = true
	end
	return ok
end

local function journaliser(joueur: Player, cleJ: string, chemin: string?)
	warn(`[Donnees] Profil {cleJ} refusé : champ {chemin or "?"} illisible. Aucune écriture, restauration par ListVersionsAsync.`)
	pcall(function()
		AnalyticsService:LogCustomEvent(joueur, "ProfilCorrompu")
	end)
end

-- Relit les 10 dernières versions et réécrit la plus récente qui se prépare sans erreur.
local function restaurer(joueur: Player, cleJ: string): boolean
	local ok, pages = avecEssais(`Versions {cleJ}`, function()
		return store:ListVersionsAsync(cleJ, Enum.SortDirection.Descending, 0, 0, VERSIONS_EXAMINEES)
	end)
	if not ok then
		return false
	end
	for _, info in pages:GetCurrentPage() do
		if not info.IsDeleted then
			local lu, ancienne = avecEssais(`Version {cleJ} {info.Version}`, function()
				return store:GetVersionAsync(cleJ, info.Version)
			end)
			if lu and type(ancienne) == "table" and SchemaJoueur.Preparer(SchemaJoueur.Copie(ancienne)) then
				ancienne.Verrou = nil
				local ecrit = avecEssais(`Restauration {cleJ}`, function()
					return store:UpdateAsync(cleJ, function()
						return ancienne, { joueur.UserId }
					end)
				end)
				if ecrit then
					warn(`[Donnees] {cleJ} restauré depuis la version {info.Version}`)
				end
				return ecrit
			end
		end
	end
	return false
end

-- Charge le profil et prend le verrou. Raisons d'échec : "DataStore", "Version", "Corrompu", "Parti", "Fermeture".
function Donnees.Charger(joueur: Player): (boolean, string?)
	if sessions[joueur] then
		return true, nil
	end
	if fermeture then
		return false, "Fermeture"
	end

	local cleJ = cle(joueur)
	local idSession = HttpService:GenerateGUID(false)
	local profil: Profil? = nil
	local restauration = false
	for tentative = 1, ESSAIS_VERROU do
		local bloque = false
		local raison: string? = nil
		local chemin: string? = nil
		local ok, valeur = avecEssais(`Chargement {cleJ}`, function()
			return store:UpdateAsync(cleJ, function(ancien)
				bloque, raison, chemin = false, nil, nil
				local verrou = if type(ancien) == "table" then ancien.Verrou else nil
				if type(verrou) == "table"
					and verrou.Id ~= idSession
					and os.time() - (tonumber(verrou.Horodatage) or 0) < VERROU_EXPIRE
					and tentative < ESSAIS_VERROU
				then
					bloque = true
					return nil -- session encore ouverte ailleurs (téléportation en cours) : on réessaie
				end
				local d, pourquoi, fautif = SchemaJoueur.Preparer(ancien)
				if not d then
					raison, chemin = pourquoi, fautif
					return nil -- profil refusé : rien n'est écrit
				end
				d.Verrou = nouveauVerrou(idSession)
				return d, { joueur.UserId }
			end)
		end)
		if not ok then
			return false, "DataStore"
		end
		if raison == "Corrompu" then
			journaliser(joueur, cleJ, chemin)
			if restauration or not restaurer(joueur, cleJ) then
				return false, "Corrompu"
			end
			restauration = true -- nouvel essai immédiat sur la version restaurée
		elseif raison then
			return false, raison
		elseif bloque then
			if not joueur.Parent then
				return false, "Parti"
			end
			task.wait(DELAI_VERROU)
		else
			profil = valeur
			break
		end
	end
	if type(profil) ~= "table" then
		return false, "DataStore"
	end

	local session: Session = {
		Id = idSession,
		Donnees = profil,
		Sale = false,
		EnCours = false,
		Planifiee = false,
		Liberation = false,
		Perdue = false,
		DerniereEcriture = os.clock(),
	}
	sessions[joueur] = session

	if not joueur.Parent then
		Donnees.Liberer(joueur)
		return false, "Parti"
	end

	joueur:SetAttribute("Gemmes", profil.Gemmes)
	joueur:SetAttribute("DonneesChargees", true)
	print(`[Solde] {cleJ} chargé (place {game.PlaceId}) : {profil.Gemmes} gemmes`)
	signalChange:Fire(joueur)
	return true, nil
end

-- Lecture seule. Toute écriture passe par Modifier.
function Donnees.Obtenir(joueur: Player): Profil?
	local session = sessions[joueur]
	if not session or session.Liberation or session.Perdue then
		return nil
	end
	return session.Donnees
end

-- fn(profil) ne cède jamais la main. Elle renvoie false si elle n'a rien changé (ni écriture, ni envoi).
function Donnees.Modifier(joueur: Player, fn: (Profil) -> boolean?): boolean
	local profil = Donnees.Obtenir(joueur)
	if not profil then
		return false
	end
	if fn(profil) == false then
		return false
	end
	sessions[joueur].Sale = true
	signalChange:Fire(joueur)
	return true
end

-- Seule ligne du jeu qui augmente Gemmes. À appeler dans Modifier.
local function verser(p: Profil, montant: number, source: string, runId: string?): number
	local plafond = PLAFONDS_GEMMES[source]
	assert(plafond, `Source de gemmes refusée : {tostring(source)}`)
	if montant ~= montant then
		return 0
	end
	local gain = math.clamp(math.floor(montant), 0, plafond)
	if gain == 0 then
		return 0
	end
	if SOURCES_RUN[source] then
		assert(type(runId) == "string", `{source} exige le runId de la Prairie`)
		if table.find(p.RunsTerminees, runId) then
			return 0
		end
		p.RunsCreditees[runId] = (p.RunsCreditees[runId] or 0) + gain
	end
	p.Gemmes += gain
	p.GemmesCumul += gain
	return gain
end

-- Production de la Foreuse depuis la dernière récolte (8 h au plus, turbo de a08 compris). Dans Modifier.
local function recolterDans(p: Profil, maintenant: number): number
	local foreuse = Catalogue.Foreuse
	local niveau = p.Recherches.Foreuse
	local debut = math.max(p.Foreuse.DerniereRecolte, maintenant - foreuse.HeuresMax * 3600) -- réservoir plein : surplus perdu
	p.Foreuse.DerniereRecolte = maintenant
	if niveau <= 0 or debut >= maintenant then
		return 0
	end
	local taux = foreuse.GemmesParHeure[math.min(niveau, #foreuse.GemmesParHeure)]
	local tauxTurbo = math.min(foreuse.PlafondParHeure, math.floor(taux * foreuse.MultiplicateurTurbo))
	local finTurbo = math.clamp(p.TurboForeuseFin, debut, maintenant)
	local exact = p.Foreuse.Reste + ((finTurbo - debut) * tauxTurbo + (maintenant - finTurbo) * taux) / 3600
	local gain = math.floor(exact)
	p.Foreuse.Reste = exact - gain -- la gemme entamée reste acquise
	return verser(p, gain, "Foreuse")
end

-- La porte des gemmes. Sources : Mine, Dore, Jour, FinDeRun (runId obligatoire), Foreuse, DefiDuJour.
function Donnees.AjouterGemmes(joueur: Player, montant: number, source: string, runId: string?): number
	assert(PLAFONDS_GEMMES[source], `Source de gemmes refusée : {tostring(source)}`)
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		verse = verser(p, montant, source, runId)
		return verse > 0
	end)
	return verse
end

-- Verse totalRun - RunsCreditees[runId], jamais plus. terminer = true clôt la run (fin ou fermeture de la Prairie).
function Donnees.CrediterRun(joueur: Player, runId: string, totalRun: number, terminer: boolean?): number
	assert(type(runId) == "string" and runId ~= "", "CrediterRun exige le runId de la Prairie")
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		if table.find(p.RunsTerminees, runId) then
			return false -- run déjà close : rien n'est versé deux fois
		end
		verse = verser(p, totalRun - (p.RunsCreditees[runId] or 0), "FinDeRun", runId)
		if terminer then
			p.RunsCreditees[runId] = nil
			table.insert(p.RunsTerminees, runId)
			if #p.RunsTerminees > RUNS_TERMINEES_MAX then
				table.remove(p.RunsTerminees, 1)
			end
			p.Records.Runs += 1
		end
		return verse > 0 or terminer == true
	end)
	return verse
end

-- Recherche au Laboratoire. Refus sans rien débiter si niveau + 1 ~= niveauVise (double tap).
function Donnees.AcheterRecherche(joueur: Player, nom: string, niveauVise: number): (boolean, string?)
	local fiche = Catalogue.Recherches[nom]
	if not fiche then
		return false, "Inconnue"
	end
	local refus: string? = "PasCharge"
	Donnees.Modifier(joueur, function(p)
		local niveau = p.Recherches[nom]
		if niveau + 1 ~= niveauVise then
			refus = "NiveauVise"
		elseif niveau >= fiche.NiveauMax then
			refus = "NiveauMax"
		elseif p.Gemmes < fiche.Couts[niveau + 1] then
			refus = "Solde"
		else
			refus = nil
			if nom == "Foreuse" then
				recolterDans(p, os.time()) -- solde la production à l'ancien taux
			end
			p.Gemmes -= fiche.Couts[niveau + 1]
			p.Recherches[nom] = niveau + 1
			return true
		end
		return false
	end)
	if refus then
		return false, refus
	end
	Donnees.Planifier(joueur)
	return true, nil
end

function Donnees.RecolterForeuse(joueur: Player): number
	local gain = 0
	Donnees.Modifier(joueur, function(p)
		gain = recolterDans(p, os.time())
		return true -- DerniereRecolte et Reste ont bougé
	end)
	if gain > 0 then
		Donnees.Planifier(joueur)
	end
	return gain
end

-- Turbo de la Foreuse (a08) : solde la production au taux courant, puis prolonge TurboForeuseFin.
function Donnees.ActiverTurboForeuse(joueur: Player, secondes: number): boolean
	local ok = Donnees.Modifier(joueur, function(p)
		local maintenant = os.time()
		recolterDans(p, maintenant)
		p.TurboForeuseFin = math.max(p.TurboForeuseFin, maintenant) + math.clamp(math.floor(secondes), 0, 8 * 3600)
		return true
	end)
	if ok then
		Donnees.Planifier(joueur)
	end
	return ok
end

-- Défi du Jour : 150 gemmes une fois par Temps.cleJour() (minuit, heure de Paris).
function Donnees.RecompenseDefiDuJour(joueur: Player): number
	local cleJour = Temps.cleJour()
	local verse = 0
	Donnees.Modifier(joueur, function(p)
		if p.Quotidien.CleDefi == cleJour then
			return false
		end
		p.Quotidien.CleDefi = cleJour
		verse = verser(p, Catalogue.DefiDuJour.Gemmes, "DefiDuJour")
		return true
	end)
	if verse > 0 then
		Donnees.Planifier(joueur)
	end
	return verse
end

-- MarketplaceService.ProcessReceipt (a46) : true seulement une fois l'achat écrit dans le store.
function Donnees.EnregistrerAchat(joueur: Player, idAchat: string, appliquer: (Profil) -> ()): boolean
	local profil = Donnees.Obtenir(joueur)
	if not profil then
		return false
	end
	if not profil.Achats[idAchat] then
		Donnees.Modifier(joueur, function(p)
			appliquer(p)
			p.Achats[idAchat] = os.time()
			return true
		end)
	end
	return Donnees.Sauvegarder(joueur) -- reçu rejoué : on s'assure seulement qu'il est écrit
end

-- DemandeDeblocage(genre, id) : Accueil et Equiper (a27), Secret (a13), Chapeau et Tampon (a15), Peluche (a22).
-- fn(joueur, id) vérifie tout côté serveur et écrit par Modifier ; elle renvoie true si quelque chose a changé.
function Donnees.DefinirDeblocage(genre: string, fn: (Player, any) -> boolean)
	assert(not deblocages[genre], `Déblocage {genre} déjà défini`)
	deblocages[genre] = fn
end

function Donnees.Debloquer(joueur: Player, genre: string, id: any): boolean
	local fn = deblocages[genre]
	return fn ~= nil and fn(joueur, id) == true
end

-- Écriture synchrone (achats). Cède la main jusqu'à 7 s + tentatives.
function Donnees.Sauvegarder(joueur: Player): boolean
	local session = sessions[joueur]
	if not session or session.Liberation then
		return false
	end
	session.Sale = true
	return ecrire(joueur, session, false)
end

-- Écriture asynchrone regroupée : plusieurs demandes rapprochées = une seule écriture.
function Donnees.Planifier(joueur: Player)
	local session = sessions[joueur]
	if not session or session.Planifiee then
		return
	end
	session.Planifiee = true
	task.spawn(function()
		while session.Sale and not session.Liberation and not session.Perdue do
			if not ecrire(joueur, session, false) then
				break
			end
		end
		session.Planifiee = false
	end)
end

-- forcer = true à chaque jour franchi (canon) ; false pour l'autosave (rafraîchit aussi le verrou).
function Donnees.SauvegarderTous(forcer: boolean)
	for joueur, session in sessions do
		if forcer or os.clock() - session.DerniereEcriture >= AUTO_MIN then
			session.Sale = true
			Donnees.Planifier(joueur)
		end
	end
end

-- Sauvegarde finale et rend le verrou. garder = true avant une téléportation : après 3 essais ratés,
-- la session reste ouverte ici (rien n'est perdu) et la fonction renvoie false.
function Donnees.Liberer(joueur: Player, garder: boolean?): boolean
	local session = sessions[joueur]
	if not session then
		return true
	end
	if session.Liberation then
		while sessions[joueur] == session and session.Liberation do
			task.wait(0.1)
		end
		return sessions[joueur] ~= session
	end
	session.Liberation = true
	if joueur.Parent then
		joueur:SetAttribute("DonneesChargees", false)
	end
	local ok = ecrire(joueur, session, true, if garder then ESSAIS_PASSAGE else nil)
	if not ok and garder and not session.Perdue and joueur.Parent then
		session.Liberation = false
		joueur:SetAttribute("DonneesChargees", true)
		warn(`[Donnees] Libération de {joueur.Name} échouée : session gardée, téléportation suspendue`)
		return false
	end
	if sessions[joueur] == session then
		sessions[joueur] = nil
	end
	if ok then
		print(`[Solde] {cle(joueur)} libéré (place {game.PlaceId}) : {session.Donnees.Gemmes} gemmes`)
	else
		warn(`[Donnees] Libération de {joueur.Name} échouée : le verrou expirera dans {VERROU_EXPIRE} s`)
	end
	return ok
end

-- game:BindToClose : libère toutes les sessions en parallèle, 27 s maximum.
function Donnees.FermerTout()
	fermeture = true
	local liste = {}
	for joueur in sessions do
		table.insert(liste, joueur)
	end
	local restants = #liste
	for _, joueur in liste do
		task.spawn(function()
			Donnees.Liberer(joueur)
			restants -= 1
		end)
	end
	local debut = os.clock()
	while restants > 0 and os.clock() - debut < FERMETURE_MAX do
		task.wait(0.2)
	end
end

return Donnees
