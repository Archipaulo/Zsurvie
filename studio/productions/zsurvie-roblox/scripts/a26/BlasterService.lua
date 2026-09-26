-- ServerScriptService/Services/BlasterService (ModuleScript)
-- Mécanique 2 : le Blaster des Survivants, en hitscan serveur.
-- DemandeTir est branché UNIQUEMENT par Validation.brancher (aucun OnServerEvent brut). Le client demande
-- un tir sur un identifiant ; le serveur vérifie état, cadence, cible, ciblableA et distance, puis décide seul
-- du critique, de la perforation et de l'explosion. Courbes : ReplicatedStorage.Partage.BlasterStats.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local BlasterStats = require(Partage:WaitForChild("BlasterStats"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))
local HordeService = require(script.Parent:WaitForChild("HordeService"))
local StatsSurvivant = require(script.Parent:WaitForChild("StatsSurvivant"))
local Validation = require(script.Parent:WaitForChild("Validation"))

type Seau = { jetons: number, t: number }

local BlasterService = {}

local seaux: { [Player]: Seau } = {}
local aleatoire = Random.new()

-- Balles perforantes : le Zbire ciblable le plus proche derrière la cible, dans un couloir de sa largeur.
local function secondZbireAligne(impact: Vector3, direction: Vector3, exclu: number): number?
	local meilleurId, meilleureAvance = nil, math.huge
	for _, z in HordeService.dansRayon(impact, Config.PERFORATION_LONGUEUR) do
		if z.id ~= exclu then
			local rel = Vector3.new(z.pos.X - impact.X, 0, z.pos.Z - impact.Z)
			local avance = rel:Dot(direction)
			local ecart = (rel - direction * avance).Magnitude
			if avance > 0 and ecart <= z.def.rayon + 0.5 and avance < meilleureAvance then
				meilleurId, meilleureAvance = z.id, avance
			end
		end
	end
	return meilleurId
end

local function surDemandeTir(joueur: Player, cibleId: number)
	-- 1. Forme (Validation a déjà vérifié le type) : un entier fini
	if cibleId ~= cibleId or cibleId % 1 ~= 0 then
		return
	end
	local seau = seaux[joueur]
	if not seau or StatsSurvivant.estEtourdi(joueur) then
		return
	end

	-- 2. Cadence : seau à jetons rempli à la cadence du joueur, 2 tirs d'avance au maximum
	local maintenant = os.clock()
	seau.jetons = math.min(Config.TIR_RAFALE, seau.jetons + (maintenant - seau.t) * BlasterStats.cadence(joueur))
	seau.t = maintenant
	if seau.jetons < 1 then
		return
	end

	-- 3. Cible vivante, sortie du portail depuis 0,8 s, à portée (distance au sol + tolérance de 4 studs)
	local racine = StatsSurvivant.racine(joueur)
	local cible = HordeService.obtenir(cibleId)
	if not racine or not cible or not HordeService.estCiblable(cible) then
		return
	end
	local vers = Vector3.new(cible.pos.X - racine.Position.X, 0, cible.pos.Z - racine.Position.Z)
	if vers.Magnitude > BlasterStats.portee(joueur) + cible.def.rayon + Config.TIR_TOLERANCE then
		return
	end
	seau.jetons -= 1

	-- 4. Dégâts : le serveur tire le critique ; HordeService applique la règle du Casqué
	local base = BlasterStats.degats(joueur)
	local critique = aleatoire:NextNumber() < BlasterStats.chanceCritique(joueur)
	local degats = if critique then base * BlasterStats.MULT_CRITIQUE else base
	local impact = cible.pos
	local _, _, reduit = HordeService.infligerDegats(cibleId, degats, critique, joueur)

	-- 5. Balles perforantes (Recherche) : le 2e Zbire aligné prend 50 % à 95 % du coup
	local partPerforation = BlasterStats.perforation(joueur)
	if partPerforation > 0 and vers.Magnitude > 0.01 then
		local second = secondZbireAligne(impact, vers.Unit, cibleId)
		if second then
			HordeService.infligerDegats(second, degats * partPerforation, critique, joueur)
		end
	end

	-- 6. Balles explosives (Établi) : 5 % de chance par niveau, 50 % des dégâts de base dans 6 studs
	local explose = aleatoire:NextNumber() < BlasterStats.chanceExplosion(joueur)
	if explose then
		HordeService.degatsZone(impact, BlasterStats.EXPLOSION_RAYON, base * BlasterStats.EXPLOSION_PART, joueur, cibleId)
	end

	-- 7. Flux Evenements : un seul message par tir, nommé d'après le coup principal
	local nom = if critique then "critique" elseif reduit then "coupReduit" else "impact"
	Evenements.publier(nom, joueur.UserId, cibleId, impact.X, impact.Z, explose)
end

function BlasterService.init()
	local function ajouter(joueur: Player)
		seaux[joueur] = { jetons = 1, t = os.clock() }
	end
	Players.PlayerAdded:Connect(ajouter)
	for _, joueur in Players:GetPlayers() do
		ajouter(joueur)
	end
	Players.PlayerRemoving:Connect(function(joueur)
		seaux[joueur] = nil
	end)
	Validation.brancher(Reseau.DemandeTir, { arguments = { "number" }, maxParSeconde = 10 }, surDemandeTir)
end

return BlasterService
