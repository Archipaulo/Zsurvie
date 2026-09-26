-- StarterPlayer/StarterPlayerScripts/Controleurs/ZbiresRendu (ModuleScript)
-- Contrat de rendu des Zbires, FIGÉ (QA) : pool de 70 modèles créé pendant l'Arrivée, parentés à
-- workspace.Zbires avec l'attribut Id (0 = libre). Chaque modèle : Racine ancrée invisible + 3 à 5 MeshParts
-- (700 triangles au plus pour le Zbire) reliées par Motor6D (noms de a38). Un seul workspace:BulkMoveTo
-- par image. Aucun Instance.new, Clone ni Destroy après preparer(). Aucune décision de jeu ici.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local ZbiresDefs = require(Partage:WaitForChild("ZbiresDefs"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))

-- Couleurs : ReplicatedStorage.Charte fait foi ; valeurs de secours = palette du canon.
local moduleCharte = ReplicatedStorage:FindFirstChild("Charte")
local Charte = if moduleCharte and moduleCharte:IsA("ModuleScript") then require(moduleCharte) else {}

local function couleur(nom: string, secours: string): Color3
	local valeur = Charte[nom]
	return if typeof(valeur) == "Color3" then valeur else Color3.fromHex(secours)
end

local VIOLET = couleur("VioletHorde", "#9B5DE5")
local OR = couleur("Or", "#FFC933")
local ALERTE = couleur("Alerte", "#FF2E63")

local TAU = 2 * math.pi
local PARKING = CFrame.new(0, -200, 0) -- sous la Prairie, au-dessus de FallenPartsDestroyHeight
local PAR_IMAGE = 5 -- modèles créés par image pendant l'Arrivée (~14 images)
local HAUTEUR_BOND = 3

export type Entree = {
	id: number, -- 0 = libre
	type: string,
	def: ZbiresDefs.Def,
	modele: Model,
	racine: BasePart,
	hauteur: number, -- de la Racine au bas du modèle
	de: Vector3,
	vers: Vector3,
	actuel: Vector3, -- position au sol interpolée
	affiche: Vector3, -- position de la Racine à l'écran
	capDe: number,
	capVers: number,
	cap: number,
	t0: number,
	vu: number,
	pv: number, -- 0 à 1
	etat: number, -- drapeaux Config.ETAT_*
	debutBond: number?,
}

local ZbiresRendu = {}

local libres: { [string]: { Entree } } = {}
local actifs: { [number]: Entree } = {}
local aGarer: { Entree } = {}
local racines: { BasePart } = {}
local cadres: { CFrame } = {}
local manques: { [string]: boolean } = {}
local animateur: (({ [number]: Entree }, number) -> ())? = nil
local disqueOnde: Part? = nil
local ondeCadre: CFrame? = nil
local ondeDebut, ondeFin, ondeRayon = 0, 0, 0
local pret = false

--------------------------------------------------------------------------------
-- Préparation (pendant l'Arrivée uniquement)
--------------------------------------------------------------------------------

-- Greybox tant que a24 n'a pas livré le Model : Racine + 1 cube violet (or pour le Doré).
local function modeleGreybox(typeId: string, def: ZbiresDefs.Def): Model
	local modele = Instance.new("Model")
	modele.Name = typeId
	local racine = Instance.new("Part")
	racine.Name = "Racine"
	racine.Size = Vector3.one
	racine.Parent = modele
	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Size = Vector3.one * def.rayon * 2
	corps.Material = Enum.Material.SmoothPlastic
	corps.Color = if def.fuyard then OR else VIOLET
	corps.CFrame = racine.CFrame
	corps.Parent = modele
	local moteur = Instance.new("Motor6D")
	moteur.Name = "Corps"
	moteur.Part0 = racine
	moteur.Part1 = corps
	moteur.Parent = racine
	modele.PrimaryPart = racine
	return modele
end

-- Applique le contrat au modèle maître (les clones en héritent). Renvoie la hauteur Racine -> sol.
local function configurer(modele: Model, typeId: string, verifier: boolean): number
	local racine = modele:FindFirstChild("Racine")
	if not (racine and racine:IsA("BasePart")) then
		racine = modele.PrimaryPart
		warn(`[ZbiresRendu] {typeId} : pas de Part « Racine », PrimaryPart utilisée`)
	end
	assert(racine and racine:IsA("BasePart"), `[ZbiresRendu] {typeId} : modèle sans Racine`)
	modele.PrimaryPart = racine

	local relies: { [Instance]: boolean } = {}
	for _, d in modele:GetDescendants() do
		if d:IsA("Motor6D") then
			if d.Part0 then
				relies[d.Part0] = true
			end
			if d.Part1 then
				relies[d.Part1] = true
			end
		end
	end

	local meshes, sansMoteur = 0, 0
	for _, d in modele:GetDescendants() do
		if d:IsA("BasePart") then
			d.CastShadow = false
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			if d == racine then
				d.Anchored = true
				d.Transparency = 1
			else
				d.Anchored = false
				d.Massless = true
				if d:IsA("MeshPart") then
					meshes += 1
				end
				if not relies[d] then
					sansMoteur += 1
				end
			end
		end
	end
	if verifier and (meshes < 3 or meshes > 5 or sansMoteur > 0) then
		warn(`[ZbiresRendu] {typeId} hors contrat : {meshes} MeshParts (3 à 5), {sansMoteur} Part(s) sans Motor6D`)
	end

	local cadre, taille = modele:GetBoundingBox()
	return racine.Position.Y - (cadre.Position.Y - taille.Y / 2)
end

-- 70 modèles (Config.QUOTAS_RENDU), 5 par image, garés sous la carte avec Id = 0.
function ZbiresRendu.preparer()
	local dossier = workspace:FindFirstChild("Zbires")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Zbires"
		dossier.Parent = workspace
	end
	local modeles = ReplicatedStorage:WaitForChild("Modeles", 5)
	local gabarits = if modeles then modeles:FindFirstChild("Zbires") else nil

	local crees = 0
	for _, typeId in ZbiresDefs.ORDRE do
		local def = ZbiresDefs.Types[typeId]
		local gabarit = if gabarits then gabarits:FindFirstChild(typeId) else nil
		local reel = gabarit ~= nil and gabarit:IsA("Model")
		local maitre: Model
		if reel then
			maitre = (gabarit :: Model):Clone()
		else
			warn(`[ZbiresRendu] Pas de modèle {typeId} dans ReplicatedStorage.Modeles.Zbires : cube greybox`)
			maitre = modeleGreybox(typeId, def)
		end
		local hauteur = configurer(maitre, typeId, reel)

		local pile: { Entree } = {}
		libres[typeId] = pile
		for _ = 1, Config.QUOTAS_RENDU[typeId] or 0 do
			local modele = maitre:Clone()
			modele:SetAttribute("Id", 0)
			modele:PivotTo(PARKING)
			modele.Parent = dossier
			table.insert(pile, {
				id = 0,
				type = typeId,
				def = def,
				modele = modele,
				racine = modele.PrimaryPart :: BasePart,
				hauteur = hauteur,
				de = Vector3.zero,
				vers = Vector3.zero,
				actuel = Vector3.zero,
				affiche = Vector3.zero,
				capDe = 0,
				capVers = 0,
				cap = 0,
				t0 = 0,
				vu = 0,
				pv = 1,
				etat = 0,
				debutBond = nil,
			})
			crees += 1
			if crees % PAR_IMAGE == 0 then
				RunService.PreRender:Wait()
			end
		end
		maitre:Destroy()
	end

	-- Annonce au sol de l'onde du Colosse : 1 disque préparé ici, jamais recréé.
	local disque = Instance.new("Part")
	disque.Name = "OndeColosse"
	disque.Shape = Enum.PartType.Cylinder
	disque.Anchored = true
	disque.CanCollide = false
	disque.CanQuery = false
	disque.CanTouch = false
	disque.CastShadow = false
	disque.Material = Enum.Material.SmoothPlastic
	disque.Color = ALERTE
	disque.Transparency = 0.55
	disque.Size = Vector3.new(0.2, 1, 1)
	disque.CFrame = PARKING
	disque.Parent = dossier
	disqueOnde = disque
	pret = true
end

--------------------------------------------------------------------------------
-- Pool
--------------------------------------------------------------------------------

local function prendre(typeId: string, id: number): Entree?
	local pile = libres[typeId]
	local e = if pile then table.remove(pile) else nil
	if not e then
		if not manques[typeId] then
			manques[typeId] = true
			warn(`[ZbiresRendu] Pool {typeId} épuisé : le serveur doit respecter Config.QUOTAS_RENDU`)
		end
		return nil
	end
	e.id = id
	e.debutBond = nil
	e.modele:SetAttribute("Id", id)
	actifs[id] = e
	return e
end

local function liberer(e: Entree)
	actifs[e.id] = nil
	e.id = 0
	e.modele:SetAttribute("Id", 0)
	table.insert(libres[e.type], e)
	table.insert(aGarer, e)
end

--------------------------------------------------------------------------------
-- Réseau : EtatZbires (10 Hz) et flux Evenements
--------------------------------------------------------------------------------

local function surEtat(tampon: buffer)
	if not pret or typeof(tampon) ~= "buffer" then
		return
	end
	local maintenant = os.clock()
	local taille = Config.OCTETS_PAR_ZBIRE
	for o = 0, buffer.len(tampon) - taille, taille do
		local id = buffer.readu16(tampon, o)
		local octet = buffer.readu8(tampon, o + 8)
		local typeId = ZbiresDefs.ORDRE[octet % 16]
		local pos = Vector3.new(
			Config.CENTRE.X + buffer.readi16(tampon, o + 2) / 10,
			Config.SOL_Y,
			Config.CENTRE.Z + buffer.readi16(tampon, o + 4) / 10
		)
		local cap = buffer.readu8(tampon, o + 7) / 256 * TAU
		local e = actifs[id]
		if e and e.type ~= typeId then
			liberer(e) -- identifiant réutilisé par le serveur pour un autre type
			e = nil
		end
		if e then
			e.de, e.capDe = e.actuel, e.cap
		elseif typeId then
			e = prendre(typeId, id)
			if e then
				e.de, e.actuel, e.affiche = pos, pos, pos
				e.capDe, e.cap = cap, cap
			end
		end
		if e then
			e.vers, e.capVers = pos, cap
			e.pv = buffer.readu8(tampon, o + 6) / 255
			e.etat = octet // 16
			e.t0, e.vu = maintenant, maintenant
		end
	end
end

local function surEclatement(id: number)
	local e = actifs[id]
	if e then
		liberer(e) -- les cubes et les pièces sont dessinés par EffetsControleur
	end
end

local function surOnde(_id: number, x: number, z: number, rayon: number, preavis: number)
	ondeCadre = CFrame.new(x, Config.SOL_Y + 0.15, z) * CFrame.Angles(0, 0, math.rad(90))
	ondeDebut = os.clock()
	ondeFin = ondeDebut + preavis
	ondeRayon = rayon
end

--------------------------------------------------------------------------------
-- Image par image : un seul BulkMoveTo, puis l'animateur de a38
--------------------------------------------------------------------------------

local function mettreAJour(dt: number)
	debug.profilebegin("ZbiresRendu")
	local maintenant = os.clock()
	table.clear(racines)
	table.clear(cadres)

	for id, e in actifs do
		if maintenant - e.vu > Config.OUBLI_RENDU then
			liberer(e) -- absent de l'état serveur : Doré enfui, fin de run
			continue
		end
		local alpha = math.clamp((maintenant - e.t0) / Config.TICK, 0, 1)
		local pos = e.de:Lerp(e.vers, alpha)
		e.actuel = pos
		e.cap = e.capDe + ((e.capVers - e.capDe + math.pi) % TAU - math.pi) * alpha

		local y = pos.Y + e.hauteur
		local bonds = e.def.bonds
		if e.def.vole then
			y += Config.HAUTEUR_VOL + math.sin(maintenant * 4 + id) * 0.3
		elseif bonds and bit32.band(e.etat, Config.ETAT_BOND) ~= 0 then
			local debut = e.debutBond or maintenant
			e.debutBond = debut
			y += math.sin(math.clamp((maintenant - debut) / (bonds * 0.45), 0, 1) * math.pi) * HAUTEUR_BOND
		else
			e.debutBond = nil
		end
		e.affiche = Vector3.new(pos.X, y, pos.Z)
		table.insert(racines, e.racine)
		table.insert(cadres, CFrame.new(e.affiche) * CFrame.Angles(0, e.cap, 0))
	end

	local disque = disqueOnde
	if disque then
		if ondeCadre then
			table.insert(racines, disque)
			table.insert(cadres, ondeCadre)
			ondeCadre = nil
		end
		if ondeFin > 0 and maintenant >= ondeFin then
			ondeFin = 0
			table.insert(racines, disque)
			table.insert(cadres, PARKING)
		elseif ondeFin > 0 then
			local d = ondeRayon * 2 * math.clamp((maintenant - ondeDebut) / (ondeFin - ondeDebut), 0.05, 1)
			disque.Size = Vector3.new(0.2, d, d)
		end
	end

	for _, e in aGarer do
		if e.id == 0 then -- pas repris entre-temps
			table.insert(racines, e.racine)
			table.insert(cadres, PARKING)
		end
	end
	table.clear(aGarer)
	if #racines > 0 then
		workspace:BulkMoveTo(racines, cadres, Enum.BulkMoveMode.FireCFrameChanged)
	end
	if animateur then
		animateur(actifs, dt) -- ZbireAnimateur (a38) : Motor6D.Transform, même budget de 3 ms
	end
	debug.profileend()
end

--------------------------------------------------------------------------------
-- API publique (BlasterControleur, a28, a38)
--------------------------------------------------------------------------------

-- a28 : tap ou clic -> identifiant du Zbire ciblable le plus proche du point, à tolerancePx près
-- (bord de sa silhouette compris). positionEcran = InputObject.Position (inset GUI exclu).
function ZbiresRendu.chercher(positionEcran: Vector2, tolerancePx: number): number?
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local pixelsParStud = camera.ViewportSize.Y / (2 * math.tan(math.rad(camera.FieldOfView) / 2))
	local meilleurId, meilleureDistance = nil, math.huge
	for id, e in actifs do
		if bit32.band(e.etat, Config.ETAT_CIBLABLE) ~= 0 then
			local p, visible = camera:WorldToScreenPoint(e.affiche)
			if visible and p.Z > 0 then
				local d = (Vector2.new(p.X, p.Y) - positionEcran).Magnitude - e.def.rayon * pixelsParStud / p.Z
				if d <= tolerancePx and d < meilleureDistance then
					meilleurId, meilleureDistance = id, d
				end
			end
		end
	end
	return meilleurId
end

-- Tir auto : Zbire ciblable, visible à l'écran, le plus proche de l'origine dans la portée.
function ZbiresRendu.plusProche(origine: Vector3, portee: number): number?
	local camera = workspace.CurrentCamera
	local meilleurId, meilleureDistance = nil, math.huge
	for id, e in actifs do
		if bit32.band(e.etat, Config.ETAT_CIBLABLE) ~= 0 then
			local dx, dz = e.actuel.X - origine.X, e.actuel.Z - origine.Z
			local d = math.sqrt(dx * dx + dz * dz) - e.def.rayon
			if d <= portee and d < meilleureDistance then
				local visible = true
				if camera then
					local _, dansVue = camera:WorldToViewportPoint(e.affiche)
					visible = dansVue
				end
				if visible then
					meilleurId, meilleureDistance = id, d
				end
			end
		end
	end
	return meilleurId
end

function ZbiresRendu.estValide(id: number, origine: Vector3, portee: number): boolean
	local e = actifs[id]
	if not e or bit32.band(e.etat, Config.ETAT_CIBLABLE) == 0 then
		return false
	end
	local dx, dz = e.actuel.X - origine.X, e.actuel.Z - origine.Z
	return math.sqrt(dx * dx + dz * dz) - e.def.rayon <= portee
end

function ZbiresRendu.position(id: number): Vector3?
	local e = actifs[id]
	return if e then e.affiche else nil
end

-- a38 : appelé à chaque image juste après le BulkMoveTo, avec les entrées actives (lecture seule).
function ZbiresRendu.brancherAnimateur(fn: ({ [number]: Entree }, number) -> ())
	animateur = fn
end

function ZbiresRendu.demarrer()
	Reseau.EtatZbires.OnClientEvent:Connect(surEtat)
	Evenements.ecouter("eclatement", surEclatement)
	Evenements.ecouter("onde", surOnde)
	RunService.PreRender:Connect(mettreAJour)
end

return ZbiresRendu
