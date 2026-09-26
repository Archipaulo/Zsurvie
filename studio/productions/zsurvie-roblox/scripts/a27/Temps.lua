-- ReplicatedStorage.Temps (ModuleScript) : l'heure de Paris, seule horloge des rendez-vous de Zsurvie
-- Imposé au Défi du Jour, au Calendrier, aux secrets, aux énigmes, au Record du Jour et au Zbire de la Semaine.
-- Paris = UTC+1 en hiver, UTC+2 du dernier dimanche de mars au dernier dimanche d'octobre (bascule à 01:00 UTC).
-- L'heure vient toujours du serveur : os.time() côté serveur, workspace:GetServerTimeNow() côté client.
-- Roblox n'accepte que "*t" et "!*t" dans os.date.

local RunService = game:GetService("RunService")

local Temps = {}

local JOUR = 86400
local HEURE_ZBIRE_SEMAINE = 17 -- samedi 17 h, heure de Paris (canon)

function Temps.maintenant(): number
	if RunService:IsServer() then
		return os.time()
	end
	return math.floor(workspace:GetServerTimeNow()) -- jamais l'horloge du téléphone
end

-- Bascule d'heure : dernier dimanche de mars ou d'octobre, 01:00 UTC (ces deux mois ont 31 jours).
local function bascule(annee: number, mois: number): number
	local le31 = DateTime.fromUniversalTime(annee, mois, 31, 1, 0, 0, 0).UnixTimestamp
	return le31 - (os.date("!*t", le31).wday - 1) * JOUR -- wday : 1 = dimanche
end

function Temps.decalageParis(t: number): number
	local annee = os.date("!*t", t).year
	if t >= bascule(annee, 3) and t < bascule(annee, 10) then
		return 7200
	end
	return 3600
end

local function dateParis(t: number)
	return os.date("!*t", t + Temps.decalageParis(t))
end

-- "2026-09-26" : change à minuit, heure de Paris.
function Temps.cleJour(t: number?): string
	local d = dateParis(t or Temps.maintenant())
	return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

-- Secondes avant le prochain minuit de Paris (journées de 23 h et de 25 h comprises).
function Temps.SecondesAvantDemain(t: number?): number
	local maintenant = t or Temps.maintenant()
	local d = dateParis(maintenant)
	local minuitNaif = DateTime.fromUniversalTime(d.year, d.month, d.day, 0, 0, 0, 0).UnixTimestamp + JOUR
	-- Minuit à Paris tombe à 22 h ou 23 h UTC, avant toute bascule (01:00 UTC) : le décalage de 23 h UTC fait foi.
	return minuitNaif - Temps.decalageParis(minuitNaif - 3600) - maintenant
end

-- Date du samedi 17 h (Paris) qui a ouvert la semaine du Zbire de la Semaine en cours.
function Temps.cleSemaine(t: number?): string
	local maintenant = t or Temps.maintenant()
	local decale = maintenant + Temps.decalageParis(maintenant)
	local d = os.date("!*t", decale)
	local joursDepuisSamedi = d.wday % 7 -- samedi (7) -> 0, dimanche (1) -> 1 ... vendredi (6) -> 6
	if joursDepuisSamedi == 0 and d.hour < HEURE_ZBIRE_SEMAINE then
		joursDepuisSamedi = 7
	end
	local s = os.date("!*t", decale - joursDepuisSamedi * JOUR)
	return string.format("%04d-%02d-%02d", s.year, s.month, s.day)
end

return Temps
