-- ReplicatedStorage/Partage/ZbiresDefs (ModuleScript)
-- Bestiaire chiffré (a26) + programme des jours (a06). Les données de a06 vivent dans le sous-module
-- ZbiresDefs.Jours, qui renvoie { JOURS = { Jour }, RAMPE = { number } }. Sans lui : programme greybox.
-- Clés ASCII (Dore, Casque, MiniGluant) = noms des modèles de ReplicatedStorage.Modeles.Zbires.
-- Le champ « nom » garde le nom exact du canon pour l'affichage.

local Config = require(script.Parent:WaitForChild("Config"))

export type Onde = {
	rayon: number, -- studs
	preavis: number, -- s d'annonce au sol avant l'étourdissement
	periode: number, -- s entre deux ondes
}

export type Def = {
	nom: string,
	pv: number, -- Jour 1, solo, Tension 0
	vitesse: number, -- studs/s
	rayon: number, -- hitbox au sol, studs
	multMaison: number, -- x Config.DPS_MAISON au contact de la Maison ou d'un Muret
	pieces: number, -- par Survivant (butin instancié)
	gemmes: number, -- par Survivant
	frappeSurvivants: boolean, -- étourdit au contact
	blinde: boolean?, -- Casqué : 50 % des dégâts hors critique
	vole: boolean?, -- ignore Murets et Tapis Collants
	fuyard: boolean?, -- traverse la Prairie sans attaquer
	boss: boolean?, -- hors plafond de 60
	division: string?, -- type créé en 2 exemplaires à la mort
	bonds: number?, -- période d'un bond, s
	onde: Onde?,
}

export type Jour = {
	tension: number?, -- 0 par défaut
	portails: number?, -- portails ouverts (les N premiers par Index), tous par défaut
	zbires: { [string]: number }, -- effectifs en solo ; le Colosse est ajouté tous les 5 jours
}

local Types: { [string]: Def } = {
	Marcheur = {
		nom = "Marcheur", pv = 20, vitesse = 6, rayon = 1.5, multMaison = 1,
		pieces = 1, gemmes = 0, frappeSurvivants = true,
	},
	Rapide = {
		nom = "Rapide", pv = 12, vitesse = 11, rayon = 1.2, multMaison = 1,
		pieces = 1, gemmes = 0, frappeSurvivants = true,
	},
	Costaud = {
		nom = "Costaud", pv = 90, vitesse = 4, rayon = 2.5, multMaison = 2,
		pieces = 4, gemmes = 0, frappeSurvivants = true,
	},
	Dore = {
		nom = "Doré", pv = 40, vitesse = 9, rayon = 1.5, multMaison = 0,
		pieces = 5, gemmes = 4, frappeSurvivants = false, fuyard = true,
	},
	Sauteur = {
		nom = "Sauteur", pv = 25, vitesse = 6, rayon = 1.5, multMaison = 1,
		pieces = 2, gemmes = 0, frappeSurvivants = true, bonds = 1,
	},
	Gluant = {
		nom = "Gluant", pv = 40, vitesse = 5, rayon = 2, multMaison = 1,
		pieces = 2, gemmes = 0, frappeSurvivants = true, division = "MiniGluant",
	},
	MiniGluant = {
		nom = "Mini-Gluant", pv = 12, vitesse = 8, rayon = 1, multMaison = 1,
		pieces = 1, gemmes = 0, frappeSurvivants = true,
	},
	Volant = {
		nom = "Volant", pv = 18, vitesse = 7, rayon = 1.5, multMaison = 1,
		pieces = 2, gemmes = 0, frappeSurvivants = false, vole = true,
	},
	Casque = {
		nom = "Casqué", pv = 50, vitesse = 5, rayon = 1.8, multMaison = 1,
		pieces = 3, gemmes = 0, frappeSurvivants = true, blinde = true,
	},
	Colosse = {
		nom = "Colosse", pv = 2500, vitesse = 3.5, rayon = 5, multMaison = 3,
		pieces = 60, gemmes = 0, frappeSurvivants = true, boss = true,
		onde = table.freeze({ rayon = 12, preavis = 1.2, periode = 7 }),
	},
}

for _, def in Types do
	table.freeze(def)
end

-- Ordre fixe : l'index (1 à 10) voyage sur 4 bits dans EtatZbires.
local ORDRE = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local INDEX: { [string]: number } = {}
for i, typeId in ORDRE do
	INDEX[typeId] = i
end

-- Programme greybox, remplacé par ZbiresDefs.Jours (a06).
local JOURS_GREYBOX: { Jour } = {
	{ tension = 0, portails = 2, zbires = { Marcheur = 14, Rapide = 4 } },
	{ tension = 0, portails = 3, zbires = { Marcheur = 16, Rapide = 6, Casque = 3 } },
	{ tension = 0, portails = 4, zbires = { Marcheur = 16, Rapide = 8, Casque = 4, Gluant = 3, Dore = 1 } },
	{ tension = 1, portails = 6, zbires = { Marcheur = 18, Rapide = 8, Casque = 5, Gluant = 4, Sauteur = 4, Volant = 3 } },
	{ tension = 0, portails = 8, zbires = { Marcheur = 16, Rapide = 8, Casque = 5, Costaud = 2, Sauteur = 4, Volant = 4, Dore = 1 } },
}
local RAMPE_GREYBOX = { 0.15, 0.35, 0.6, 0.85, 1 }

local moduleJours = script:FindFirstChild("Jours")
local donnees = if moduleJours and moduleJours:IsA("ModuleScript") then require(moduleJours) else nil
if donnees == nil then
	warn("[ZbiresDefs] Sous-module Jours (a06) absent : programme greybox de 5 jours")
end

local ZbiresDefs = {
	Types = table.freeze(Types),
	ORDRE = table.freeze(ORDRE),
	INDEX = table.freeze(INDEX),
	JOURS = (if donnees then donnees.JOURS else nil) or JOURS_GREYBOX,
	RAMPE = (if donnees then donnees.RAMPE else nil) or RAMPE_GREYBOX,
}
assert(#ZbiresDefs.JOURS > 0 and #ZbiresDefs.RAMPE > 0, "[ZbiresDefs] JOURS et RAMPE ne doivent pas être vides")

-- Au-delà du dernier jour de a06, on rejoue le dernier : les PV continuent de monter de 15 % par jour.
function ZbiresDefs.jour(n: number): Jour
	return ZbiresDefs.JOURS[math.clamp(math.floor(n), 1, #ZbiresDefs.JOURS)]
end

function ZbiresDefs.facteurJour(jour: number): number
	return Config.CROISSANCE_JOUR ^ (math.max(jour, 1) - 1)
end

function ZbiresDefs.facteurCoop(actifs: number): number
	return 1 + Config.COOP_PV * (math.clamp(actifs, 1, Config.JOUEURS_MAX) - 1)
end

-- PV = base x 1,15^(jour - 1) x 1,3^Tension x coop x Défi. Colosse : 2 500 x 1,15^(jour - 1) x coop.
function ZbiresDefs.pvMax(typeId: string, jour: number, tension: number, actifs: number, defi: number): number
	local def = Types[typeId]
	local pv = def.pv * ZbiresDefs.facteurJour(jour) * ZbiresDefs.facteurCoop(actifs)
	if not def.boss then
		pv *= Config.FACTEUR_TENSION ^ tension * defi
	end
	return math.ceil(pv)
end

-- Part cumulée des Zbires du jour lâchée à la fraction f (0 à 1) des 80 s de horde.
-- RAMPE = parts cumulées à intervalles égaux ; interpolation linéaire, 0 au départ, 1 à la fin.
function ZbiresDefs.rampe(f: number): number
	local points = ZbiresDefs.RAMPE
	local n = #points
	local x = math.clamp(f, 0, 1) * n
	local i = math.floor(x)
	if i >= n then
		return 1
	end
	local avant = if i == 0 then 0 else points[i]
	return avant + (points[i + 1] - avant) * (x - i)
end

return table.freeze(ZbiresDefs)
