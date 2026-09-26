-- StarterPlayer/StarterPlayerScripts/Controleurs/BlasterControleur (ModuleScript)
-- LA boucle de tir auto du jeu (une seule connexion Heartbeat). Cible : la cible prioritaire posée par a28
-- (tap ou clic -> ZbiresRendu.chercher -> definirCiblePrioritaire), sinon le Zbire ciblable visible le plus
-- proche dans la portée, avec 0,4 s d'hystérésis. Aucune lecture d'entrée ici : a28 gère tap, clic et boutons.
-- Le client ne fait que DEMANDER un tir ; sa traçante est une prédiction visuelle.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Partage = ReplicatedStorage:WaitForChild("Partage")
local Config = require(Partage:WaitForChild("Config"))
local BlasterStats = require(Partage:WaitForChild("BlasterStats"))
local Reseau = require(Partage:WaitForChild("Reseau"))
local Evenements = require(Partage:WaitForChild("Evenements"))
local ZbiresRendu = require(script.Parent:WaitForChild("ZbiresRendu"))

local moduleCharte = ReplicatedStorage:FindFirstChild("Charte")
local Charte = if moduleCharte and moduleCharte:IsA("ModuleScript") then require(moduleCharte) else {}
local OR = if typeof(Charte.Or) == "Color3" then Charte.Or else Color3.fromHex("#FFC933")
local ARDOISE = if typeof(Charte.Ardoise) == "Color3" then Charte.Ardoise else Color3.fromHex("#4A4560")

local NB_TRACANTES = 12 -- créées au démarrage, recyclées en rond
local DUREE_TRACANTE = 0.07
local EPAISSEUR = 0.35
local EPAISSEUR_CRITIQUE = 0.6
local PARKING = CFrame.new(0, -210, 0)

local joueur = Players.LocalPlayer

local BlasterControleur = {}

local cibleId: number? = nil
local prioritaire: number? = nil
local dernierChangement = 0
local prochainTir = 0
local tracantes: { Part } = {}
local finTracante: { number } = {}
local suivante = 1
local connexion: RBXScriptConnection? = nil

local function estEtourdi(): boolean
	local fin = joueur:GetAttribute("EtourdiJusqua")
	return typeof(fin) == "number" and fin > workspace:GetServerTimeNow()
end

local function tracante(depart: Vector3, arrivee: Vector3, epaisseur: number, teinte: Color3)
	local longueur = (arrivee - depart).Magnitude
	if longueur < 0.5 or #tracantes == 0 then
		return
	end
	local trait = tracantes[suivante]
	finTracante[suivante] = os.clock() + DUREE_TRACANTE
	suivante = suivante % NB_TRACANTES + 1
	trait.Color = teinte
	trait.Size = Vector3.new(epaisseur, epaisseur, longueur)
	trait.CFrame = CFrame.lookAt((depart + arrivee) / 2, arrivee)
end

local function choisirCible(origine: Vector3, portee: number): number?
	local maintenant = os.clock()

	-- Cible prioritaire (a28) : tant qu'elle existe ; hors portée, le tir auto prend le relais
	local p = prioritaire
	if p then
		if ZbiresRendu.estValide(p, origine, portee) then
			cibleId = p
			return p
		elseif ZbiresRendu.position(p) == nil then
			prioritaire = nil -- vaincue ou disparue
		end
	end

	-- Option du menu Réglages : tir automatique coupé
	if joueur:GetAttribute("OptionTirAuto") == false then
		return nil
	end

	-- Tir automatique avec hystérésis : on garde la cible tant qu'elle reste valide
	local plusProche = ZbiresRendu.plusProche(origine, portee)
	local courante = cibleId
	if courante == nil or not ZbiresRendu.estValide(courante, origine, portee) then
		cibleId = plusProche
		dernierChangement = maintenant
	elseif plusProche and plusProche ~= courante and maintenant - dernierChangement >= Config.HYSTERESIS_CIBLE then
		cibleId = plusProche
		dernierChangement = maintenant
	end
	return cibleId
end

local function boucle()
	local maintenant = os.clock()
	for i, fin in finTracante do
		if fin > 0 and maintenant >= fin then
			finTracante[i] = 0
			tracantes[i].CFrame = PARKING
		end
	end

	if maintenant < prochainTir or estEtourdi() then
		return
	end
	local perso = joueur.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart")
	if not racine or not racine:IsA("BasePart") then
		return
	end
	local origine = racine.Position
	local portee = BlasterStats.portee(joueur) -- 40 à 52 studs : rayon du tir auto
	local id = choisirCible(origine, portee)
	if not id then
		return
	end
	prochainTir = maintenant + 1 / BlasterStats.cadence(joueur)
	Reseau.DemandeTir:FireServer(id)
	local arrivee = ZbiresRendu.position(id)
	if arrivee then
		tracante(origine, arrivee, EPAISSEUR, OR)
	end
end

-- Tirs des coéquipiers (les miens sont prédits) : Ardoise sur un Casqué, trait épais sur un critique.
local function surTir(nom: string): (number, number, number, number) -> ()
	return function(userId: number, _id: number, x: number, z: number)
		if userId == joueur.UserId then
			return
		end
		local tireur = Players:GetPlayerByUserId(userId)
		local perso = tireur and tireur.Character
		local racine = perso and perso:FindFirstChild("HumanoidRootPart")
		if racine and racine:IsA("BasePart") then
			tracante(
				racine.Position,
				Vector3.new(x, Config.SOL_Y + 1.5, z),
				if nom == "critique" then EPAISSEUR_CRITIQUE else EPAISSEUR,
				if nom == "coupReduit" then ARDOISE else OR
			)
		end
	end
end

-- a28 : force la cible (nil pour revenir au tir auto). Gardée jusqu'à sa disparition.
function BlasterControleur.definirCiblePrioritaire(id: number?)
	prioritaire = id
end

function BlasterControleur.demarrer()
	if connexion then
		return
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "Tracantes"
	dossier.Parent = workspace
	for i = 1, NB_TRACANTES do
		local trait = Instance.new("Part")
		trait.Anchored = true
		trait.CanCollide = false
		trait.CanQuery = false
		trait.CanTouch = false
		trait.CastShadow = false
		trait.Material = Enum.Material.SmoothPlastic
		trait.CFrame = PARKING
		trait.Parent = dossier
		tracantes[i] = trait
		finTracante[i] = 0
	end

	for _, nom in { "impact", "critique", "coupReduit" } do
		Evenements.ecouter(nom, surTir(nom))
	end
	connexion = RunService.Heartbeat:Connect(boucle)
end

return BlasterControleur
