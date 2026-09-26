-- ServerScriptService.Modules.SchemaJoueur (ModuleScript) : forme du profil unique d'un Survivant, version 2
-- Store Zsurvie_Joueurs_v1, clé J_<UserId>. Changement de forme = VERSION + 1 et une entrée dans MIGRATIONS.
-- Clés sans accents (identifiants de code) ; l'UI affiche les noms du canon (Casqué, Doré, Tourelle de toit...).
-- Fonctions pures et sans yield : Donnees les appelle dans le transform de UpdateAsync.

local SchemaJoueur = {}

SchemaJoueur.VERSION = 2

local RUNS_TERMINEES_MAX = 20
local DUREE_ACHATS = 90 * 86400 -- reçus Robux gardés 90 jours

function SchemaJoueur.Defaut(): { [string]: any }
	return {
		Version = SchemaJoueur.VERSION,
		Gemmes = 0,
		GemmesCumul = 0, -- total gagné à vie
		XP = 0,
		Recherches = {
			TourelleDeToit = 0,
			BallesPerforantes = 0,
			ViseeCritique = 0,
			Foreuse = 0,
		},
		Foreuse = {
			DerniereRecolte = 0, -- os.time() UTC ; production plafonnée à 8 h
			Reste = 0, -- fraction de gemme en cours (0 à 1)
		},
		TurboForeuseFin = 0, -- a08 : os.time() de fin du turbo
		Records = {
			MeilleurJour = 0,
			Runs = 0,
			ColossesVaincus = 0,
		},
		Eliminations = { -- paliers de la Galerie des Zbires (10, 100, 1 000) calculés, jamais stockés
			Marcheur = 0,
			Rapide = 0,
			Costaud = 0,
			Dore = 0,
			Sauteur = 0,
			Gluant = 0,
			MiniGluant = 0,
			Volant = 0,
			Casque = 0,
			Colosse = 0,
		},
		RunsCreditees = {}, -- [runId] = gemmes déjà versées pour cette run (idempotence de CrediterRun)
		RunsTerminees = {}, -- 20 derniers runId clos : plus rien n'y est versé
		AccueilEtape = 0, -- a50 : accueil de Doc Boulon (remplace Tutoriel et EtapeOnboarding de a10)
		DernierBonus = "", -- Temps.cleJour() du dernier bonus quotidien
		Calendrier = { Case = 0, CleJour = "" }, -- dernière case ouverte et son Temps.cleJour()
		Quotidien = { CleDefi = "" }, -- Temps.cleJour() du dernier Défi du Jour récompensé
		ZbireSemaine = { CleSemaine = "" }, -- Temps.cleSemaine() de la dernière participation (sans gemmes)
		Secrets = { trouves = {}, jour = "" }, -- a13 : [idSecret] = true ; Temps.cleJour() de l'énigme
		Chapeaux = {}, -- a15 : [idChapeau] = true
		JourChapeau = "", -- a15 : Temps.cleJour()
		Tampons = {}, -- a15 : [idTampon] = true
		JourTampon = "", -- a15 : Temps.cleJour()
		Peluches = {}, -- a22 : [idPeluche] = true
		Cosmetiques = {
			Possedes = {}, -- a46 : ["Blaster:ArcEnCiel"] = true
			Equipes = { Blaster = "Base", SacADos = "Base", Alcove = "Base" },
		},
		Achats = {}, -- a46 : [PurchaseId] = os.time() (ProcessReceipt idempotent)
		Reglages = {
			VolumeMusique = 0.6,
			VolumeEffets = 0.8,
			EffetsReduits = false,
			Secousses = true,
			TirAuto = true,
		},
		DerniereSauvegarde = 0,
		-- Verrou = { Id, JobId, PlaceId, Horodatage } : posé et retiré par Donnees, absent du défaut
	}
end

-- Champs de valeur : jamais remis à zéro. Mauvais type -> tonumber, sinon le chargement est refusé.
-- Gemmes et Recherches (consigne) ; Cosmetiques.Possedes et Achats, payés en Robux (a46).
local PROTEGES: { [string]: boolean } = {
	Gemmes = true,
	Recherches = true,
	Cosmetiques = true,
	["Cosmetiques.Possedes"] = true,
	Achats = true,
}
for nom in SchemaJoueur.Defaut().Recherches do
	PROTEGES[`Recherches.{nom}`] = true
end

-- MIGRATIONS[v] transforme un profil v en v + 1.
local MIGRATIONS: { [number]: ({ [string]: any }) -> () } = {
	[1] = function(d)
		-- Accueil de Doc Boulon (a50) : reprend Tutoriel.Etape (a27 v1) et EtapeOnboarding (a10).
		local tutoriel = if type(d.Tutoriel) == "table" then d.Tutoriel else {}
		d.AccueilEtape = math.max(tonumber(tutoriel.Etape) or 0, tonumber(d.EtapeOnboarding) or 0)
		d.Tutoriel = nil
		d.EtapeOnboarding = nil
		-- Réglages renommés ; les valeurs absentes sont posées par Reconcilier.
		local r = if type(d.Reglages) == "table" then d.Reglages else {}
		d.Reglages = {
			VolumeMusique = r.Musique,
			VolumeEffets = r.Effets,
			Secousses = r.Vibrations,
			TirAuto = r.TirAuto,
		}
		-- Achats : liste des 50 derniers PurchaseId -> dictionnaire [PurchaseId] = horodatage.
		local achats = {}
		if type(d.Achats) == "table" then
			for _, id in d.Achats do
				if type(id) == "string" then
					achats[id] = os.time()
				end
			end
		end
		d.Achats = achats
	end,
}

-- Renvoie false si le profil vient d'une version plus récente du jeu (serveur pas encore mis à jour).
function SchemaJoueur.Migrer(d: { [string]: any }): boolean
	local version = tonumber(d.Version) or 1
	if version > SchemaJoueur.VERSION then
		return false
	end
	while version < SchemaJoueur.VERSION do
		local migration = MIGRATIONS[version]
		assert(migration, `Migration manquante pour la version {version}`)
		migration(d)
		version += 1
	end
	d.Version = version
	return true
end

-- Pose les champs manquants et répare les types. Renvoie false et le chemin fautif si un champ
-- de valeur est illisible : l'appelant refuse alors le chargement sans rien écrire.
function SchemaJoueur.Reconcilier(cible: { [any]: any }, modele: { [any]: any }, chemin: string?): (boolean, string?)
	for cle, defaut in modele do
		local ici = if chemin then `{chemin}.{cle}` else tostring(cle)
		local valeur = cible[cle]
		if valeur == nil then
			cible[cle] = defaut
		elseif typeof(valeur) ~= typeof(defaut) then
			if PROTEGES[ici] then
				local nombre = if type(defaut) == "number" then tonumber(valeur) else nil
				if nombre == nil or nombre ~= nombre or math.abs(nombre) == math.huge then
					return false, ici
				end
				cible[cle] = nombre
			else
				warn(`[SchemaJoueur] Champ {ici} corrompu ({typeof(valeur)}), remis à sa valeur par défaut`)
				cible[cle] = defaut
			end
		elseif type(valeur) == "table" then
			local ok, fautif = SchemaJoueur.Reconcilier(valeur, defaut, ici)
			if not ok then
				return false, fautif
			end
		end
	end
	return true, nil
end

-- Bornes : aucun solde ni niveau négatif ou fractionnaire ; purge des listes qui grossissent.
function SchemaJoueur.Assainir(d: { [string]: any })
	d.Gemmes = math.max(0, math.floor(d.Gemmes))
	d.GemmesCumul = math.max(d.Gemmes, math.floor(d.GemmesCumul))
	d.XP = math.max(0, math.floor(d.XP))
	for _, groupe in { d.Recherches, d.Records, d.Eliminations } do
		for cle, valeur in groupe do
			if type(valeur) == "number" then
				groupe[cle] = math.max(0, math.floor(valeur))
			end
		end
	end
	d.Foreuse.Reste = math.clamp(d.Foreuse.Reste, 0, 0.999)
	for runId, total in d.RunsCreditees do
		if type(total) ~= "number" then
			d.RunsCreditees[runId] = nil
		end
	end
	while #d.RunsTerminees > RUNS_TERMINEES_MAX do
		table.remove(d.RunsTerminees, 1)
	end
	local limite = os.time() - DUREE_ACHATS
	for idAchat, quand in d.Achats do
		if type(quand) ~= "number" or quand < limite then
			d.Achats[idAchat] = nil
		end
	end
end

function SchemaJoueur.Copie(v: any): any
	if type(v) ~= "table" then
		return v
	end
	local copie = {}
	for cle, valeur in v do
		copie[cle] = SchemaJoueur.Copie(valeur)
	end
	return copie
end

-- Prépare un profil lu dans le store : (profil) ou (nil, "Version" | "Corrompu", chemin?).
function SchemaJoueur.Preparer(brut: any): ({ [string]: any }?, string?, string?)
	if brut == nil then
		return SchemaJoueur.Defaut(), nil, nil
	end
	if type(brut) ~= "table" then
		return nil, "Corrompu", "racine"
	end
	if not SchemaJoueur.Migrer(brut) then
		return nil, "Version", nil
	end
	local ok, chemin = SchemaJoueur.Reconcilier(brut, SchemaJoueur.Defaut())
	if not ok then
		return nil, "Corrompu", chemin
	end
	SchemaJoueur.Assainir(brut)
	return brut, nil, nil
end

return SchemaJoueur
