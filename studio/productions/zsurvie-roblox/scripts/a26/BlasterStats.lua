-- ReplicatedStorage/Partage/BlasterStats (ModuleScript)
-- SOURCE UNIQUE des courbes du Blaster (Établi et Recherches), identique serveur et client.
-- a07 (prix des 10 niveaux) et a09 (UI de l'Établi) lisent ce module ; aucune autre courbe ne fait foi.
-- Niveaux lus dans les attributs du Player, écrits UNIQUEMENT par le serveur :
--   Établi (remis à 0 à chaque run) : NivDegats, NivCadence, NivPortee, NivExplosives, NivButin
--   Recherches (DataStore)          : RechViseeCritique, RechBallesPerforantes

local MAX = table.freeze({
	NivDegats = 10,
	NivCadence = 10,
	NivPortee = 10,
	NivExplosives = 10,
	NivButin = 5,
	RechViseeCritique = 10,
	RechBallesPerforantes = 10,
})

-- Valeur de chaque stat au niveau n (0 = rien acheté).
local COURBES: { [string]: (number) -> number } = {
	NivDegats = function(n) return 10 + 2 * n end, -- 10 -> 30
	NivCadence = function(n) return 4 + 0.2 * n end, -- tirs/s, 4 -> 6
	NivPortee = function(n) return 40 + 1.2 * n end, -- studs, 40 -> 52 = rayon du tir auto
	NivExplosives = function(n) return 0.05 * n end, -- chance par tir, 0 -> 50 %
	NivButin = function(n) return 1 + 0.1 * n end, -- Pièces, x 1 -> x 1,5
	RechViseeCritique = function(n) return 0.05 + 0.02 * n end, -- chance, 5 % -> 25 %
	RechBallesPerforantes = function(n) return if n > 0 then 0.45 + 0.05 * n else 0 end, -- 2e Zbire, 50 % -> 95 %
}

local BlasterStats = {
	MAX = MAX,
	MULT_CRITIQUE = 2,
	PART_CASQUE = 0.5, -- Casqué : 50 % des dégâts hors critique
	EXPLOSION_RAYON = 6, -- studs
	EXPLOSION_PART = 0.5, -- des dégâts de base, jamais critique
}

function BlasterStats.valeur(stat: string, n: number): number
	local courbe = COURBES[stat]
	assert(courbe, `Stat de Blaster inconnue : {stat}`)
	return courbe(math.clamp(math.floor(n), 0, MAX[stat]))
end

function BlasterStats.niveau(joueur: Player, stat: string): number
	local v = joueur:GetAttribute(stat)
	if typeof(v) ~= "number" or v ~= v then
		return 0
	end
	return math.clamp(math.floor(v), 0, MAX[stat])
end

local function lire(joueur: Player, stat: string): number
	return BlasterStats.valeur(stat, BlasterStats.niveau(joueur, stat))
end

function BlasterStats.degats(joueur: Player): number
	return lire(joueur, "NivDegats")
end

function BlasterStats.cadence(joueur: Player): number
	return lire(joueur, "NivCadence")
end

-- C'est aussi le rayon du tir automatique.
function BlasterStats.portee(joueur: Player): number
	return lire(joueur, "NivPortee")
end

function BlasterStats.chanceExplosion(joueur: Player): number
	return lire(joueur, "NivExplosives")
end

-- Multiplicateur des Pièces du butin instancié (lu par Economie).
function BlasterStats.butin(joueur: Player): number
	return lire(joueur, "NivButin")
end

function BlasterStats.chanceCritique(joueur: Player): number
	return lire(joueur, "RechViseeCritique")
end

-- Part des dégâts reçue par le 2e Zbire aligné (0 = pas de perforation).
function BlasterStats.perforation(joueur: Player): number
	return lire(joueur, "RechBallesPerforantes")
end

-- Dégâts moyens sur un Casqué, en fraction des dégâts de base : 0,5 x (1 - c) + 2 x c.
-- 0,875 à Visée critique 10 : le Casqué reste plus solide que les autres, le critique reste la réponse.
function BlasterStats.facteurMoyenCasque(nVisee: number): number
	local c = BlasterStats.valeur("RechViseeCritique", nVisee)
	return BlasterStats.PART_CASQUE * (1 - c) + BlasterStats.MULT_CRITIQUE * c
end

return table.freeze(BlasterStats)
