-- ServerScriptService/Services/HordeService (ModuleScript)
-- Mécanique 1 : la Horde des Zbires. Simulation 100 % serveur : ni Part ni Humanoid.
-- Absorbe ServerScriptService.Horde.Portails (a14) : portails tagués, rampe de a06, alerte, tirage pondéré.
-- Le serveur calcule position, PV et cible 10 fois par seconde ; ZbiresRendu lisse l'affichage.
-- Toute source de dégâts (Blaster, Mini-Tourelle, Tourelle de toit) passe par HordeService.infligerDegats.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local ZbiresDefs = require(Partage:WaitForChild("ZbiresDefs"))
local BlasterStats = require(Partage:WaitForChild("BlasterStats"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))
local Plan = require(ReplicatedStorage:WaitForChild("Plan"))
local StatsSurvivant = require(script.Parent:WaitForChild("StatsSurvivant"))

export type Zbire = {
	id: number,
	type: string,
	def: ZbiresDefs.Def,
	pos: Vector3,
	cible: Vector3,
	pv: number,
	pvMax: number,
	sortA: number, -- os.clock de la sortie du portail (fin de l'alerte)
	ciblableA: number, -- sortA + 0,8 s : avant, ni tir, ni tourelle, ni coup aux Survivants
	enrageA: number, -- Colosse : sortA + 60 s ; math.huge pour les autres
	cap: number, -- radians ; CFrame.Angles(0, cap, 0) regarde vers la cible
	etat: number, -- drapeaux Config.ETAT_* du dernier tick
	prochainCoupSurvivant: number,
	prochaineOnde: number,
	ondeA: number?,
}

type Obstacle = { pos: Vector3, rayon: number, frapper: (degats: number) -> () }
type ZoneLente = { pos: Vector3, rayon: number, facteur: number }
type Entree = { type: string, cframe: CFrame? }
type Portail = { pos: Vector3, poids: number, index: number }

local TAU = 2 * math.pi

local HordeService = {}

local zbires: { [number]: Zbire } = {}
local compte: { [string]: number } = {} -- Zbires en jeu par type (quotas du pool client)
local nbDansPlafond = 0 -- Colosse exclu
local prochainId = 0
local file: { Entree } = {}
local programme: { string } = {} -- Zbires du jour, mélangés, lâchés selon la rampe
local liberes = 0
local debutJour = 0
local jour = 1
local tension = 0
local portailsOuverts = Config.NB_PORTAILS
local modificateurs = { pv = 1, vitesse = 1 }
local portails: { Portail } = {}
local dernierPortail = 0
local actifs = 1
local estActif: (Player) -> boolean = function(_joueur: Player): boolean
	return true
end
local obstacles: { [any]: Obstacle } = {}
local zonesLentes: { [any]: ZoneLente } = {}
local ecouteurs: { [string]: { (...any) -> () } } = { apparu = {}, vaincu = {}, maison = {}, enfui = {} }
local connexion: RBXScriptConnection? = nil
local accumulateur = 0
local aleatoire = Random.new()

--------------------------------------------------------------------------------
-- Outils
--------------------------------------------------------------------------------

local function plat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

local function auSol(v: Vector3): Vector3
	return Vector3.new(v.X, Config.SOL_Y, v.Z)
end

local function distancePlate(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

local function capVers(direction: Vector3): number
	return math.atan2(-direction.X, -direction.Z)
end

-- Les écouteurs tournent APRÈS le tick : ils peuvent appeler arreter() ou infligerDegats() sans risque.
local function emettre(nom: string, ...: any)
	for _, fn in ecouteurs[nom] do
		task.defer(fn, ...)
	end
end

local function nouvelId(): number
	repeat
		prochainId = prochainId % 65535 + 1 -- tient sur 2 octets dans EtatZbires
	until zbires[prochainId] == nil
	return prochainId
end

-- « actifs » = Survivants pour qui Economie.estActif renvoie vrai, entre 1 et 6.
local function compterActifs(): number
	local n = 0
	for _, joueur in Players:GetPlayers() do
		if estActif(joueur) then
			n += 1
		end
	end
	return math.clamp(n, 1, Config.JOUEURS_MAX)
end

--------------------------------------------------------------------------------
-- Portails (ex-ServerScriptService.Horde.Portails de a14)
--------------------------------------------------------------------------------

-- Tag PortailZbire ; position exacte = Plan.positionPortail(Index) si l'attribut Index existe.
-- Sans portail tagué (greybox) : Plan.positionPortail(1 à 8).
local function rafraichirPortails()
	table.clear(portails)
	for _, instance in CollectionService:GetTagged(Config.TAG_PORTAIL) do
		if instance:IsA("PVInstance") then
			local index = instance:GetAttribute("Index")
			local poids = instance:GetAttribute("Poids")
			local aIndex = typeof(index) == "number"
			table.insert(portails, {
				pos = auSol(if aIndex then Plan.positionPortail(index) else instance:GetPivot().Position),
				poids = if typeof(poids) == "number" and poids > 0 then poids else 1,
				index = if aIndex then index else math.huge,
			})
		end
	end
	if #portails == 0 then
		for i = 1, Config.NB_PORTAILS do
			table.insert(portails, { pos = auSol(Plan.positionPortail(i)), poids = 1, index = i })
		end
	end
	table.sort(portails, function(a: Portail, b: Portail): boolean
		return a.index < b.index
	end)
	dernierPortail = 0
end

-- Tirage pondéré (attribut Poids) parmi les portails ouverts ce jour, jamais deux fois de suite le même.
local function tirerPortail(): Vector3
	local n = math.min(portailsOuverts, #portails)
	local function eligible(i: number): boolean
		return n == 1 or i ~= dernierPortail
	end
	local total = 0
	for i = 1, n do
		if eligible(i) then
			total += portails[i].poids
		end
	end
	local tirage = aleatoire:NextNumber() * total
	local choisi = 0
	for i = 1, n do
		if eligible(i) then
			choisi = i
			tirage -= portails[i].poids
			if tirage <= 0 then
				break
			end
		end
	end
	dernierPortail = choisi
	local d = Config.PORTAIL_DISPERSION
	return portails[choisi].pos + Vector3.new(aleatoire:NextNumber(-d, d), 0, aleatoire:NextNumber(-d, d))
end

-- Le Doré coupe la Prairie en corde, sans passer par la Maison, et ressort de l'autre côté.
local function cibleFuite(depart: Vector3): Vector3
	local rel = depart - Config.CENTRE
	local sens = if aleatoire:NextNumber() < 0.5 then -1 else 1
	local angle = math.atan2(rel.Z, rel.X) + math.pi + sens * Config.DORE_DECALAGE
	return auSol(Config.CENTRE + Vector3.new(math.cos(angle), 0, math.sin(angle)) * Config.DORE_RAYON_FUITE)
end

local function contactMaison(pos: Vector3, rayon: number): boolean
	local d = pos - Config.CENTRE
	return math.max(math.abs(d.X), math.abs(d.Z)) <= Config.MAISON_DEMI + rayon
end

local function facteurSol(pos: Vector3): number
	local facteur = 1
	for _, zone in zonesLentes do
		if distancePlate(pos, zone.pos) <= zone.rayon then
			facteur = math.min(facteur, zone.facteur)
		end
	end
	return facteur
end

local function obstacleSur(pos: Vector3, rayon: number): any
	for cle, obstacle in obstacles do
		if distancePlate(pos, obstacle.pos) < obstacle.rayon + rayon then
			return cle
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Cycle de vie d'un Zbire
--------------------------------------------------------------------------------

local function creer(entree: Entree, maintenant: number)
	local typeId = entree.type
	local def = ZbiresDefs.Types[typeId]
	local depart: Vector3, alerte: number
	if entree.cframe then
		depart, alerte = auSol(entree.cframe.Position), 0 -- division du Gluant : sur place
	elseif def.boss then
		depart, alerte = auSol(Config.GRAND_PORTAIL), Config.ALERTE_COLOSSE
	else
		depart, alerte = tirerPortail(), Config.ALERTE_PORTAIL
	end
	local cible = if def.fuyard then cibleFuite(depart) else auSol(Config.CENTRE)
	local pvMax = ZbiresDefs.pvMax(typeId, jour, tension, actifs, modificateurs.pv)
	local sortA = maintenant + alerte
	local id = nouvelId()
	zbires[id] = {
		id = id,
		type = typeId,
		def = def,
		pos = depart,
		cible = cible,
		pv = pvMax,
		pvMax = pvMax,
		sortA = sortA,
		ciblableA = sortA + Config.DELAI_CIBLABLE,
		enrageA = if def.boss then sortA + Config.COLOSSE_ENRAGE_APRES else math.huge,
		cap = capVers(plat(cible - depart)),
		etat = 0,
		prochainCoupSurvivant = 0,
		prochaineOnde = if def.onde then sortA + def.onde.periode else math.huge,
		ondeA = nil,
	}
	compte[typeId] = (compte[typeId] or 0) + 1
	if def.boss then
		workspace:SetAttribute("PVColosse", 1) -- jauge du HUD
	else
		nbDansPlafond += 1
	end
	Evenements.publier("apparition", id, typeId, depart.X, depart.Z, alerte)
	emettre("apparu", typeId)
end

local function retirer(z: Zbire)
	zbires[z.id] = nil
	compte[z.type] -= 1
	if z.def.boss then
		workspace:SetAttribute("PVColosse", nil)
		workspace:SetAttribute("ColosseEnrage", nil)
	else
		nbDansPlafond -= 1
	end
end

local function vaincre(z: Zbire, tueur: Player?, critique: boolean)
	retirer(z)
	Evenements.publier("eclatement", z.id, z.type, z.pos.X, z.pos.Z, critique)
	local division = z.def.division
	if division then
		Evenements.publier("division", z.id, z.pos.X, z.pos.Z)
		local versMaison = plat(Config.CENTRE - z.pos)
		local cadre = if versMaison.Magnitude > 0.01 then CFrame.lookAt(z.pos, z.pos + versMaison) else CFrame.new(z.pos)
		HordeService.ajouterALaFile(division, 2, cadre)
	end
	emettre("vaincu", z.type, z.pos, tueur, critique)
end

-- 3 sorties par tick au plus. Une entrée ne sort que si le plafond de 60 (Colosse exclu) ET le quota
-- de rendu de son type (pool client de 70) ont une place ; sinon les entrées suivantes passent devant.
local function traiterFile(maintenant: number)
	local crees, i = 0, 1
	while i <= #file and crees < Config.APPARITIONS_PAR_TICK do
		local entree = file[i]
		local boss = ZbiresDefs.Types[entree.type].boss == true
		local quota = Config.QUOTAS_RENDU[entree.type] or 0
		if (compte[entree.type] or 0) < quota and (boss or nbDansPlafond < Config.MAX_ZBIRES) then
			table.remove(file, i)
			creer(entree, maintenant)
			crees += 1
		else
			i += 1
		end
	end
end

-- Rampe de a06 : part cumulée du programme du jour mise en file à l'instant t des 80 s.
local function libererProgramme(maintenant: number)
	local objectif = math.floor(#programme * ZbiresDefs.rampe((maintenant - debutJour) / Config.DUREE_HORDE) + 0.5)
	while liberes < objectif do
		liberes += 1
		table.insert(file, { type = programme[liberes] })
	end
end

--------------------------------------------------------------------------------
-- Tick serveur (10 Hz)
--------------------------------------------------------------------------------

-- 9 octets par Zbire : id u16, x i16 et z i16 au 1/10 de stud, PV u8, cap u8, type (4 bits) + état (4 bits).
local function diffuser(vivants: { Zbire })
	local n = #vivants
	if n == 0 then
		return
	end
	local taille = Config.OCTETS_PAR_ZBIRE
	local tampon = buffer.create(n * taille)
	for i, z in vivants do
		local o = (i - 1) * taille
		buffer.writeu16(tampon, o, z.id)
		buffer.writei16(tampon, o + 2, math.round((z.pos.X - Config.CENTRE.X) * 10))
		buffer.writei16(tampon, o + 4, math.round((z.pos.Z - Config.CENTRE.Z) * 10))
		buffer.writeu8(tampon, o + 6, math.clamp(math.ceil(z.pv / z.pvMax * 255), 0, 255))
		buffer.writeu8(tampon, o + 7, math.round(z.cap % TAU / TAU * 256) % 256)
		buffer.writeu8(tampon, o + 8, ZbiresDefs.INDEX[z.type] + z.etat * 16)
	end
	Reseau.EtatZbires:FireAllClients(tampon)
end

local function pas(dt: number)
	debug.profilebegin("HordeTick")
	local maintenant = os.clock()
	actifs = compterActifs()
	libererProgramme(maintenant)
	traiterFile(maintenant)

	local survivants = StatsSurvivant.positions()
	local vivants: { Zbire } = {}
	local degatsMaison = 0
	local degatsObstacles: { [any]: number } = {}
	local dpsJour = Config.DPS_MAISON * ZbiresDefs.facteurJour(jour)

	for id, z in zbires do
		if maintenant < z.sortA then
			continue -- encore dans le portail : alerte en cours
		end
		local def = z.def

		-- 0. Le Doré sort de la Prairie
		if def.fuyard and distancePlate(z.cible, z.pos) < 2 then
			retirer(z)
			emettre("enfui", z.type)
			continue
		end
		table.insert(vivants, z)

		local ciblable = maintenant >= z.ciblableA
		local enrage = maintenant >= z.enrageA
		local etat = if ciblable then Config.ETAT_CIBLABLE else 0
		if enrage then
			if bit32.band(z.etat, Config.ETAT_ENRAGE) == 0 then
				workspace:SetAttribute("ColosseEnrage", true)
			end
			etat += Config.ETAT_ENRAGE
		end
		local dps = dpsJour * def.multMaison * (if enrage then Config.COLOSSE_ENRAGE_MAISON else 1)

		-- 1. Coup au contact d'un Survivant : étourdi 2 s, jamais de dégâts
		if def.frappeSurvivants and ciblable and maintenant >= z.prochainCoupSurvivant then
			for _, s in survivants do
				if distancePlate(s.pos, z.pos) <= def.rayon + Config.PORTEE_COUP_ZBIRE and StatsSurvivant.etourdir(s.joueur) then
					z.prochainCoupSurvivant = maintenant + Config.RECHARGE_COUP_SURVIVANT
					break
				end
			end
		end

		-- 2. Onde du Colosse : annoncée au sol, puis étourdit tout le rayon ; immobile pendant l'annonce
		local onde = def.onde
		if onde then
			if z.ondeA == nil and maintenant >= z.prochaineOnde then
				z.ondeA = maintenant + onde.preavis
				Evenements.publier("onde", id, z.pos.X, z.pos.Z, onde.rayon, onde.preavis)
			elseif z.ondeA and maintenant >= z.ondeA then
				z.ondeA = nil
				z.prochaineOnde = maintenant + onde.periode
				for _, s in survivants do
					if distancePlate(s.pos, z.pos) <= onde.rayon then
						StatsSurvivant.etourdir(s.joueur)
					end
				end
			end
			if z.ondeA then
				z.etat = etat
				continue
			end
		end

		-- 3. Au contact de la Maison : débit continu, cumulé sur le tick
		if not def.fuyard and contactMaison(z.pos, def.rayon) then
			degatsMaison += dps * dt
			z.etat = etat + Config.ETAT_CONTACT
			continue
		end

		-- 4. Déplacement en ligne droite vers la cible
		local vers = plat(z.cible - z.pos)
		local distance = vers.Magnitude
		local vitesse = def.vitesse * modificateurs.vitesse * (if enrage then Config.COLOSSE_ENRAGE_VITESSE else 1)
		if def.bonds then
			-- Sauteur : immobile 55 % du temps, puis un bond de 0,45 s (même vitesse moyenne)
			if (maintenant - z.sortA) % def.bonds < def.bonds * 0.55 then
				vitesse = 0
			else
				vitesse /= 0.45
				if bit32.band(z.etat, Config.ETAT_BOND) == 0 then
					Evenements.publier("bond", id)
				end
				etat += Config.ETAT_BOND
			end
		end
		if not def.vole then
			vitesse *= facteurSol(z.pos) -- Tapis Collant
		end
		if vitesse > 0 and distance > 0 then
			z.cap = capVers(vers)
			local suivant = z.pos + vers.Unit * math.min(vitesse * dt, distance)
			local cle = if def.vole then nil else obstacleSur(suivant, def.rayon)
			if cle ~= nil then
				-- Muret : le Zbire s'arrête et le frappe au même débit que la Maison ; le Volant passe au-dessus
				if dps > 0 then
					degatsObstacles[cle] = (degatsObstacles[cle] or 0) + dps * dt
				end
			else
				z.pos = suivant
			end
		end
		z.etat = etat
	end

	-- 5. Séparation douce : aucune silhouette ne se cache sous une autre
	for i = 1, #vivants do
		local a = vivants[i]
		for j = i + 1, #vivants do
			local b = vivants[j]
			if (a.def.vole == true) == (b.def.vole == true) then
				local d = plat(b.pos - a.pos)
				local mini = a.def.rayon + b.def.rayon
				local m = d.Magnitude
				if m < mini and m > 0.01 then
					local correction = d.Unit * ((mini - m) * 0.5)
					local partA = b.def.rayon / mini -- le plus gros bouge le moins
					a.pos -= correction * partA
					b.pos += correction * (1 - partA)
				end
			end
		end
	end

	-- 6. Dégâts cumulés : un seul appel par tick pour la Maison et pour chaque Muret touché
	if degatsMaison > 0 then
		emettre("maison", degatsMaison)
	end
	for cle, degats in degatsObstacles do
		local obstacle = obstacles[cle]
		if obstacle then
			task.defer(obstacle.frapper, degats)
		end
	end

	-- 7. Diffusion compacte à tous les clients (un arrivant reconstruit la horde dès ce paquet)
	diffuser(vivants)
	debug.profileend()
end

--------------------------------------------------------------------------------
-- API publique
--------------------------------------------------------------------------------

-- JourService, au début des 80 s de horde. Lit ZbiresDefs.JOURS (a06) ; Colosse les jours multiples de 5.
function HordeService.demarrerJour(n: number)
	jour = math.max(1, math.floor(n))
	local programmeJour = ZbiresDefs.jour(jour)
	tension = programmeJour.tension or 0
	portailsOuverts = math.clamp(programmeJour.portails or Config.NB_PORTAILS, 1, math.max(#portails, 1))
	actifs = compterActifs()
	local facteur = 1 + Config.COOP_NOMBRE * (actifs - 1)
	table.clear(programme)
	for _, typeId in ZbiresDefs.ORDRE do
		local effectif = programmeJour.zbires[typeId]
		if effectif and not ZbiresDefs.Types[typeId].boss then
			for _ = 1, math.round(effectif * facteur) do
				table.insert(programme, typeId)
			end
		end
	end
	for i = #programme, 2, -1 do -- mélange de Fisher-Yates
		local j = aleatoire:NextInteger(1, i)
		programme[i], programme[j] = programme[j], programme[i]
	end
	liberes = 0
	debutJour = os.clock()
	if jour % Config.PERIODE_COLOSSE == 0 then
		table.insert(file, 1, { type = "Colosse" })
	end
end

-- Met des Zbires en file. Avec cframe : sortie sur place, en tête de file, sans alerte, écartés de 3 studs.
function HordeService.ajouterALaFile(typeId: string, nombre: number?, cframe: CFrame?)
	assert(ZbiresDefs.Types[typeId], `Zbire inconnu : {typeId}`)
	local n = nombre or 1
	for i = 1, n do
		if cframe then
			local decalage = cframe.RightVector * ((i - (n + 1) / 2) * 3)
			table.insert(file, i, { type = typeId, cframe = cframe + decalage })
		else
			table.insert(file, { type = typeId })
		end
	end
end

-- Défi du Jour et Zbire de la Semaine : { pv = 1.2, vitesse = 1.1 } par exemple.
function HordeService.definirModificateurs(m: { pv: number?, vitesse: number? })
	modificateurs = { pv = m.pv or 1, vitesse = m.vitesse or 1 }
end

function HordeService.estCiblable(z: Zbire): boolean
	return zbires[z.id] == z and os.clock() >= z.ciblableA
end

-- Seule porte d'entrée des dégâts. Renvoie (vaincu, dégâts réels, coup réduit par le casque).
function HordeService.infligerDegats(id: number, degats: number, critique: boolean, source: Player?): (boolean, number, boolean)
	local z = zbires[id]
	if not z or degats <= 0 or os.clock() < z.ciblableA then
		return false, 0, false
	end
	local reduit = z.def.blinde == true and not critique
	local reel = if reduit then degats * BlasterStats.PART_CASQUE else degats
	z.pv -= reel
	if z.def.boss then
		workspace:SetAttribute("PVColosse", math.max(z.pv, 0) / z.pvMax)
	end
	if z.pv <= 0 then
		vaincre(z, source, critique)
		return true, reel, reduit
	end
	return false, reel, reduit
end

-- Dégâts de zone (balles explosives, défenses) : jamais critiques. Renvoie le nombre de Zbires touchés.
function HordeService.degatsZone(centre: Vector3, rayon: number, degats: number, source: Player?, exclureId: number?): number
	local touches = 0
	for _, z in HordeService.dansRayon(centre, rayon) do
		if z.id ~= exclureId then
			HordeService.infligerDegats(z.id, degats, false, source)
			touches += 1
		end
	end
	return touches
end

-- Lecture seule par convention : ne jamais modifier la table renvoyée.
function HordeService.obtenir(id: number): Zbire?
	return zbires[id]
end

-- Zbires ciblables seulement (tourelles, explosions, perforation).
function HordeService.dansRayon(centre: Vector3, rayon: number): { Zbire }
	local maintenant = os.clock()
	local liste = {}
	for _, z in zbires do
		if maintenant >= z.ciblableA and distancePlate(z.pos, centre) <= rayon + z.def.rayon then
			table.insert(liste, z)
		end
	end
	return liste
end

function HordeService.plusProche(centre: Vector3, rayon: number): Zbire?
	local maintenant = os.clock()
	local meilleur, meilleureDistance = nil, math.huge
	for _, z in zbires do
		local d = distancePlate(z.pos, centre) - z.def.rayon
		if maintenant >= z.ciblableA and d <= rayon and d < meilleureDistance then
			meilleur, meilleureDistance = z, d
		end
	end
	return meilleur
end

function HordeService.nombreRestant(): number
	return nbDansPlafond + #file + (#programme - liberes)
end

-- Muret : bloque les Zbires au sol ; frapper(degats) reçoit le cumul du tick.
function HordeService.enregistrerObstacle(cle: any, pos: Vector3, rayon: number, frapper: (number) -> ())
	obstacles[cle] = { pos = auSol(pos), rayon = rayon, frapper = frapper }
end

function HordeService.retirerObstacle(cle: any)
	obstacles[cle] = nil
end

-- Tapis Collant : facteur de vitesse (0.5 = moitié), sans effet sur le Volant.
function HordeService.enregistrerZoneLente(cle: any, pos: Vector3, rayon: number, facteur: number)
	zonesLentes[cle] = { pos = auSol(pos), rayon = rayon, facteur = facteur }
end

function HordeService.retirerZoneLente(cle: any)
	zonesLentes[cle] = nil
end

-- "apparu" (type), "vaincu" (type, position, tueur?, critique), "maison" (dégâts du tick), "enfui" (type).
function HordeService.on(evenement: string, fn: (...any) -> ())
	local liste = ecouteurs[evenement]
	assert(liste, `Événement de horde inconnu : {evenement}`)
	table.insert(liste, fn)
end

function HordeService.demarrer()
	if connexion then
		return
	end
	accumulateur = 0
	connexion = RunService.Heartbeat:Connect(function(dt: number)
		accumulateur += dt
		if accumulateur < Config.TICK then
			return
		end
		local ecoule = math.min(accumulateur, Config.TICK * 3) -- pas de téléportation après un lag
		accumulateur = 0
		pas(ecoule)
	end)
end

-- Fin de run (Maison tombée) : plus de paquet EtatZbires, les clients rendent leurs modèles au pool en 0,5 s.
function HordeService.arreter()
	if connexion then
		connexion:Disconnect()
		connexion = nil
	end
	table.clear(zbires)
	table.clear(compte)
	table.clear(file)
	table.clear(programme)
	liberes = 0
	nbDansPlafond = 0
	workspace:SetAttribute("PVColosse", nil)
	workspace:SetAttribute("ColosseEnrage", nil)
end

-- estActifFn = Economie.estActif (nil en greybox : tout le monde compte).
function HordeService.init(estActifFn: ((Player) -> boolean)?)
	if estActifFn then
		estActif = estActifFn
	end
	rafraichirPortails()
	CollectionService:GetInstanceAddedSignal(Config.TAG_PORTAIL):Connect(rafraichirPortails)
	CollectionService:GetInstanceRemovedSignal(Config.TAG_PORTAIL):Connect(rafraichirPortails)
end

return HordeService
