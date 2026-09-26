-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Controles (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Contrôles du Survivant sur la Prairie.
-- Variante A (défaut) : RÉPARER 96 px dans le coin bas droit, puis Muret, Mini-Tourelle, Tapis Collant
-- et Ping (64 px) sur un arc de 150 px (180°, 210°, 240°, 270°) ; cadenas « Niv. X » si verrouillé.
-- Variante B du test H2 (Player.TestH2 = "B", écrit par le serveur) : RÉPARER 96 + POSER 72 / PINGS 72.
-- Touches : E (Réparer), 1-2-3 (défenses), Q (Ping) ; l'Établi (F, ButtonY) est géré par Etabli.
-- Le tir appartient à BlasterControleur (a26) : un tap ou un clic sur un Zbire le désigne comme cible
-- prioritaire. Le client n'envoie que des DEMANDES ; le serveur vérifie cible, distance, cadence, solde.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Controles] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
local etatRun = UIKit.etatRun()
if not (playerGui and etatRun) then
	return
end
local zbiresRendu = UIKit.module("ZbiresRendu", true)
local blaster = UIKit.module("BlasterControleur", true)
for _, nom in { "DemandeReparation", "DemandePose", "DemandePing" } do
	UIKit.remote(nom) -- résolution anticipée : aucune attente pendant le combat
end

local TOLERANCE_DESIGNATION = 56 -- px autour d'un Zbire (ZbiresRendu.chercher)
local DISTANCE_POSE = 5 -- studs devant le Survivant
local ATTENTE_PING = 2 -- s, identique au contrôle serveur
local DUREE_ROUE = 4 -- s avant fermeture automatique d'une roue
local COTE_GRAPPE = 230 -- px : RÉPARER 96 dans le coin + arc de 150 px + boutons de 64 px
local CENTRE_REPARER = Vector2.new(182, 182) -- 230 − 96 / 2
local RAYON_ARC = 150 -- px
local ANGLES_ARC = { 180, 210, 240, 270 } -- Muret, Mini-Tourelle, Tapis Collant, Ping
local RAPIDE = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PULSATION = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local clavier = UserInputService.KeyboardEnabled

local TOUCHES_CHOIX = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.KeypadOne] = 1,
	[Enum.KeyCode.KeypadTwo] = 2,
	[Enum.KeyCode.KeypadThree] = 3,
	[Enum.KeyCode.KeypadFour] = 4,
}

local TOUCHES_DEFENSE = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.KeypadOne] = 1,
	[Enum.KeyCode.KeypadTwo] = 2,
	[Enum.KeyCode.KeypadThree] = 3,
	[Enum.KeyCode.DPadLeft] = 1,
	[Enum.KeyCode.DPadDown] = 2,
	[Enum.KeyCode.DPadRight] = 3,
}

local MESSAGES_REFUS = {
	PasAssezDePieces = "Pas assez de pièces !",
	TropDeDefenses = "3 défenses posées au maximum !",
	TropLoin = "Trop loin !",
	Emplacement = "Impossible de poser ici !",
	Etourdi = "Tu es étourdi !",
	Attente = "Attends un peu !",
	Verrou = "Pas encore débloqué !",
}

-- Test H2 : attribut écrit par le serveur à l'arrivée ; sans valeur après 2 s, variante A.
local function lireVariante(): string
	local debut = os.clock()
	while joueur:GetAttribute("TestH2") == nil and os.clock() - debut < 2 do
		task.wait(0.1)
	end
	return if joueur:GetAttribute("TestH2") == "B" then "B" else "A"
end
local variante = lireVariante()

------------------------------------------------------------------------------------------
-- Grappe d'actions (bas droite, 230 × 230 px, 12 px de marge). Aucun bouton de saut.
------------------------------------------------------------------------------------------

local gui = UIKit.creer("ScreenGui", {
	Name = "ControlesZsurvie",
	DisplayOrder = 3, -- au-dessus de l'Établi (2) : RÉPARER reste visible et utilisable
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local grappe = UIKit.creer("Frame", {
	Name = "Actions",
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -12, 1, -12),
	Size = UDim2.fromOffset(COTE_GRAPPE, COTE_GRAPPE),
	Parent = gui,
})
UIKit.echelle(grappe)

local function creerAction(nom: string, texte: string, cote: number, centre: Vector2, couleur: Color3, touche: string)
	local bouton, label = UIKit.bouton(grappe, texte, UDim2.fromOffset(cote, cote), couleur, if cote >= 72 then 22 else 16)
	bouton.Name = nom
	bouton.AnchorPoint = Vector2.new(0.5, 0.5)
	bouton.Position = UDim2.fromOffset(centre.X, centre.Y)
	if clavier then
		local indice = UIKit.etiquette(bouton, touche, UDim2.fromOffset(24, 22), 16)
		indice.Position = UDim2.fromOffset(-6, -6)
		indice.BackgroundColor3 = C.Encre
		indice.BackgroundTransparency = 0
	end
	return { bouton = bouton, label = label, texte = texte, contour = bouton:FindFirstChildOfClass("UIStroke") }
end

local function surArc(index: number): Vector2
	local angle = math.rad(ANGLES_ARC[index])
	return CENTRE_REPARER + Vector2.new(math.cos(angle), math.sin(angle)) * RAYON_ARC
end

-- Cadenas « Niv. X » : Player.Verrou<Cle> = niveau requis, écrit par le serveur (0 ou absent = libre).
local function creerVerrou(bouton: GuiObject)
	local voile = UIKit.creer("Frame", {
		Name = "Verrou",
		BackgroundColor3 = C.Encre,
		BackgroundTransparency = 0.25,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 3,
		Parent = bouton,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 8), Parent = voile })
	local anse = UIKit.creer("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 7),
		Size = UDim2.fromOffset(14, 14),
		ZIndex = 4,
		Parent = voile,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = anse })
	UIKit.creer("UIStroke", { Color = C.Creme, Thickness = 3, Parent = anse })
	UIKit.creer("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = C.Creme,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 15),
		Size = UDim2.fromOffset(22, 16),
		ZIndex = 5,
		Parent = voile,
	})
	local texte = UIKit.etiquette(voile, "Niv. 1", UDim2.new(1, -6, 0, 20), 16)
	texte.AnchorPoint = Vector2.new(0.5, 1)
	texte.Position = UDim2.new(0.5, 0, 1, -4)
	texte.ZIndex = 5
	return { voile = voile, texte = texte }
end

local reparer = creerAction("Reparer", "RÉPARER", 96, CENTRE_REPARER, C.ToitOrange, "E")
reparer.bouton.BackgroundTransparency = 0.4

local boutonsDefense = {} -- [cle] = action (variante A)
local secondaires = {} -- boutons masqués quand l'Établi est ouvert
local actionPoser = nil -- variante B
local actionPing

if variante == "A" then
	for index, defense in UIKit.DEFENSES do
		local action = creerAction(defense.cle, defense.court, 64, surArc(index), defense.couleur, tostring(index))
		action.label.AnchorPoint = Vector2.new(0.5, 0)
		action.label.Position = UDim2.new(0.5, 0, 0, 4)
		action.label.Size = UDim2.new(1, -8, 0.62, -4)
		action.prix = UIKit.etiquette(action.bouton, "", UDim2.new(1, -8, 0.3, 0), 14)
		action.prix.AnchorPoint = Vector2.new(0.5, 1)
		action.prix.Position = UDim2.new(0.5, 0, 1, -3)
		action.prix.TextColor3 = C.Or
		action.verrou = creerVerrou(action.bouton)
		boutonsDefense[defense.cle] = action
		table.insert(secondaires, action.bouton)
	end
	actionPing = creerAction("Ping", "PING", 64, surArc(4), C.NuitLabo, "Q")
else
	actionPoser = creerAction("Poser", "POSER\n0/3", 72, Vector2.new(86, 194), C.TerreBattue, "1-3")
	actionPing = creerAction("Pings", "PINGS", 72, Vector2.new(194, 86), C.NuitLabo, "Q")
	table.insert(secondaires, actionPoser.bouton)
end
table.insert(secondaires, actionPing.bouton)

-- Icône du crochet a10 (Charte.Icones.PingColosse), affichée à la place du texte.
actionPing.icone = UIKit.creer("ImageLabel", {
	Name = "Icone",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.8, 0.8),
	Visible = false,
	Parent = actionPing.bouton,
})

-- Voile d'attente du bouton Ping (2 s).
local attentePing = UIKit.creer("Frame", {
	Name = "Attente",
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 1),
	Size = UDim2.fromScale(1, 0),
	ZIndex = 2,
	Parent = actionPing.bouton,
})

------------------------------------------------------------------------------------------
-- Roue (centre de l'écran) : 4 pings, ou 3 défenses en variante B ; options 96 × 64 px
------------------------------------------------------------------------------------------

local roue = UIKit.creer("Frame", {
	Name = "Roue",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.58),
	Size = UDim2.fromOffset(330, 240),
	Visible = false,
	Parent = gui,
})
UIKit.echelle(roue)

local POSITIONS = {
	[3] = { Vector2.new(-110, 0), Vector2.new(0, -84), Vector2.new(110, 0) },
	[4] = { Vector2.new(0, -84), Vector2.new(110, 0), Vector2.new(0, 84), Vector2.new(-110, 0) },
}
local roueOuverte: string? = nil
local optionsRoue = {}
local rappelsRoue = {}
local jetonRoue = 0

local function fermerRoue()
	if not roueOuverte then
		return
	end
	roueOuverte = nil
	ContextActionService:UnbindAction("ZsurvieChoix")
	for _, bouton in optionsRoue do
		bouton:Destroy()
	end
	table.clear(optionsRoue)
	table.clear(rappelsRoue)
	roue.Visible = false
end

local function choisir(index: number)
	local rappel = rappelsRoue[index]
	fermerRoue()
	if rappel then
		UIKit.son("Clic")
		rappel()
	end
end

local function actionChoix(_, etat: Enum.UserInputState, entree: InputObject)
	if etat ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local index = TOUCHES_CHOIX[entree.KeyCode]
	if index and rappelsRoue[index] then
		choisir(index)
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

-- options : { { texte, couleur, rappel, sousTexte?, couleurSous? } }
local function ouvrirRoue(nom: string, options)
	if roueOuverte == nom then
		fermerRoue()
		return
	end
	fermerRoue()
	roueOuverte = nom
	roue.Visible = true
	local positions = POSITIONS[#options] or POSITIONS[4]
	for index, option in options do
		local centre = positions[index]
		local bouton = UIKit.creer("TextButton", {
			Name = "Option" .. index,
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = option.couleur,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			Text = "",
			Parent = roue,
		})
		UIKit.habiller(bouton, 8, 3)
		local hauteurTitre = if option.sousTexte then 0.58 else 1
		local titre = UIKit.etiquette(bouton, option.texte, UDim2.new(1, -8, hauteurTitre, -6), 20)
		titre.AnchorPoint = Vector2.new(0.5, 0)
		titre.Position = UDim2.new(0.5, 0, 0, 3)
		if option.sousTexte then
			local sous = UIKit.etiquette(bouton, option.sousTexte, UDim2.new(1, -8, 0.42, -4), 16)
			sous.AnchorPoint = Vector2.new(0.5, 1)
			sous.Position = UDim2.new(0.5, 0, 1, -3)
			sous.TextColor3 = option.couleurSous or C.Or
		end
		if clavier then
			local indice = UIKit.etiquette(bouton, tostring(index), UDim2.fromOffset(20, 20), 14)
			indice.Position = UDim2.fromOffset(-6, -6)
			indice.BackgroundColor3 = C.Encre
			indice.BackgroundTransparency = 0
		end
		TweenService:Create(
			bouton,
			TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, (index - 1) * 0.03),
			{ Position = UDim2.new(0.5, centre.X, 0.5, centre.Y), Size = UDim2.fromOffset(96, 64) }
		):Play()
		bouton.Activated:Connect(function()
			choisir(index)
		end)
		optionsRoue[index] = bouton
		rappelsRoue[index] = option.rappel
	end
	ContextActionService:BindActionAtPriority(
		"ZsurvieChoix",
		actionChoix,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.KeypadOne,
		Enum.KeyCode.KeypadTwo,
		Enum.KeyCode.KeypadThree,
		Enum.KeyCode.KeypadFour
	)
	jetonRoue += 1
	local jeton = jetonRoue
	task.delay(DUREE_ROUE, function()
		if jeton == jetonRoue and roueOuverte == nom then
			fermerRoue()
		end
	end)
end

------------------------------------------------------------------------------------------
-- Défenses (Muret, Mini-Tourelle, Tapis Collant ; 3 posées au maximum)
------------------------------------------------------------------------------------------

local dernierePose: string? = nil

local function refuser(raison: string)
	UIKit.toast(MESSAGES_REFUS[raison] or "Action impossible !", C.Alerte)
	UIKit.son("Refus")
end

local function positionDePose(racine: BasePart): Vector3
	local devant = racine.Position + racine.CFrame.LookVector * DISTANCE_POSE
	-- Grille décor de 1 stud (canon §7). Y indicatif : le serveur le recalcule par raycast.
	return Vector3.new(math.round(devant.X), racine.Position.Y - 3, math.round(devant.Z))
end

local function poser(cle: string)
	local racine = UIKit.racineLocale()
	if not racine then
		return
	end
	if UIKit.estEtourdi(joueur) then
		refuser("Etourdi")
		return
	end
	local verrou = tonumber(joueur:GetAttribute("Verrou" .. cle)) or 0
	if verrou > 0 then
		UIKit.toast(`Débloqué au Niv. {verrou} !`, C.Alerte)
		UIKit.son("Refus")
		return
	end
	if (tonumber(joueur:GetAttribute("Defenses")) or 0) >= UIKit.DEFENSES_MAX then
		refuser("TropDeDefenses")
		return
	end
	local prix = UIKit.prix(cle)
	if prix and (tonumber(joueur:GetAttribute("Pieces")) or 0) < prix then
		refuser("PasAssezDePieces")
		return
	end
	dernierePose = cle
	UIKit.envoyer("DemandePose", cle, positionDePose(racine))
end

local function majDefenses()
	local pieces = tonumber(joueur:GetAttribute("Pieces")) or 0
	local posees = math.floor(tonumber(joueur:GetAttribute("Defenses")) or 0)
	local plein = posees >= UIKit.DEFENSES_MAX
	for cle, action in boutonsDefense do
		local verrou = tonumber(joueur:GetAttribute("Verrou" .. cle)) or 0
		local prix = UIKit.prix(cle)
		action.verrou.voile.Visible = verrou > 0
		action.verrou.texte.Text = "Niv. " .. verrou
		action.prix.Text = if plein then `{posees}/{UIKit.DEFENSES_MAX}` elseif prix then UIKit.formater(prix) else ""
		action.prix.TextColor3 = if plein or (prix and pieces < prix) then C.Alerte else C.Or
		action.bouton.BackgroundTransparency = if plein then 0.45 else 0
	end
	if actionPoser then
		actionPoser.label.Text = `POSER\n{posees}/{UIKit.DEFENSES_MAX}`
	end
end

-- Variante B : POSER ouvre la roue des 3 défenses.
local function ouvrirDefenses()
	if UIKit.estEtourdi(joueur) then
		refuser("Etourdi")
		return
	end
	local pieces = tonumber(joueur:GetAttribute("Pieces")) or 0
	local options = {}
	for index, defense in UIKit.DEFENSES do
		local verrou = tonumber(joueur:GetAttribute("Verrou" .. defense.cle)) or 0
		local prix = UIKit.prix(defense.cle)
		options[index] = {
			texte = defense.texte,
			couleur = defense.couleur,
			sousTexte = if verrou > 0 then `Niv. {verrou}` elseif prix then UIKit.formater(prix) else "-",
			couleurSous = if verrou > 0 or (prix and pieces < prix) then C.Alerte else C.Or,
			rappel = function()
				poser(defense.cle)
			end,
		}
	end
	ouvrirRoue("Poser", options)
end

local poseesAvant = math.floor(tonumber(joueur:GetAttribute("Defenses")) or 0)
joueur.AttributeChanged:Connect(function(nom: string)
	if nom == "Defenses" then
		local posees = math.floor(tonumber(joueur:GetAttribute("Defenses")) or 0)
		local action = if dernierePose then boutonsDefense[dernierePose] or actionPoser else nil
		if posees > poseesAvant and action then
			UIKit.rebond(action.bouton)
			UIKit.son("Pose")
		end
		poseesAvant = posees
	end
	if nom == "Pieces" or nom == "Defenses" or string.sub(nom, 1, 6) == "Verrou" then
		majDefenses()
	end
end)
majDefenses()

------------------------------------------------------------------------------------------
-- Roue des Pings (remplace le chat : 4 phrases fixes, aucun texte libre)
------------------------------------------------------------------------------------------

local prochainPing = 0

local function ouvrirPings()
	local options = {}
	for index, ping in UIKit.PINGS do
		options[index] = {
			texte = ping.texte,
			couleur = ping.couleur,
			rappel = function()
				local racine = UIKit.racineLocale()
				if not racine then
					return
				end
				if os.clock() < prochainPing then
					refuser("Attente")
					return
				end
				prochainPing = os.clock() + ATTENTE_PING
				attentePing.Size = UDim2.fromScale(1, 1)
				TweenService:Create(attentePing, TweenInfo.new(ATTENTE_PING, Enum.EasingStyle.Linear), {
					Size = UDim2.fromScale(1, 0),
				}):Play()
				UIKit.envoyer("DemandePing", ping.cle, racine.Position)
			end,
		}
	end
	ouvrirRoue("Pings", options)
end

------------------------------------------------------------------------------------------
-- Réparer : InputBegan → DemandeReparation(true), InputEnded → DemandeReparation(false)
------------------------------------------------------------------------------------------

local enReparation = false
local maintien: InputObject? = nil

local function commencerReparation()
	if enReparation or UIKit.estEtourdi(joueur) then
		return
	end
	enReparation = true
	UIKit.envoyer("DemandeReparation", true)
	TweenService:Create(reparer.bouton, RAPIDE, { BackgroundColor3 = UIKit.lumiere(C.ToitOrange) }):Play()
end

local function arreterReparation()
	if not enReparation then
		return
	end
	enReparation = false
	UIKit.envoyer("DemandeReparation", false)
	TweenService:Create(reparer.bouton, RAPIDE, { BackgroundColor3 = C.ToitOrange }):Play()
end

local function estMaintien(entree: InputObject): boolean
	if not maintien then
		return false
	end
	if entree.UserInputType == Enum.UserInputType.Touch then
		return entree == maintien
	end
	return entree.UserInputType == maintien.UserInputType
end

reparer.bouton.InputBegan:Connect(function(entree: InputObject)
	local genre = entree.UserInputType
	if genre == Enum.UserInputType.Touch or genre == Enum.UserInputType.MouseButton1 then
		maintien = entree
		UIKit.rebond(reparer.bouton)
		commencerReparation() -- DemandeReparation(true)
	end
end)

local function finMaintien(entree: InputObject)
	if estMaintien(entree) then
		maintien = nil
		arreterReparation() -- DemandeReparation(false)
	end
end
reparer.bouton.InputEnded:Connect(finMaintien)
-- Filet : un doigt qui glisse hors du bouton se lève ailleurs ; on le rattrape ici.
UserInputService.InputEnded:Connect(finMaintien)

------------------------------------------------------------------------------------------
-- Boutons tactiles et ContextActionService (clavier, manette) : mêmes fonctions
------------------------------------------------------------------------------------------

for _, defense in UIKit.DEFENSES do
	local action = boutonsDefense[defense.cle]
	if action then
		action.bouton.Activated:Connect(function()
			UIKit.rebond(action.bouton)
			UIKit.son("Clic")
			poser(defense.cle)
		end)
	end
end

if actionPoser then
	actionPoser.bouton.Activated:Connect(function()
		UIKit.rebond(actionPoser.bouton)
		UIKit.son("Clic")
		ouvrirDefenses()
	end)
end

actionPing.bouton.Activated:Connect(function()
	UIKit.rebond(actionPing.bouton)
	UIKit.son("Clic")
	ouvrirPings()
end)

local function actionReparer(_, etat: Enum.UserInputState)
	if etat == Enum.UserInputState.Begin then
		UIKit.rebond(reparer.bouton)
		commencerReparation()
	elseif etat == Enum.UserInputState.End or etat == Enum.UserInputState.Cancel then
		arreterReparation()
	end
	return Enum.ContextActionResult.Sink
end

local function actionDefense(_, etat: Enum.UserInputState, entree: InputObject)
	if etat ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local defense = UIKit.DEFENSES[TOUCHES_DEFENSE[entree.KeyCode]]
	if not defense then
		return Enum.ContextActionResult.Pass
	end
	local action = boutonsDefense[defense.cle] or actionPoser
	UIKit.rebond(action.bouton)
	poser(defense.cle)
	return Enum.ContextActionResult.Sink
end

local function actionPings(_, etat: Enum.UserInputState)
	if etat == Enum.UserInputState.Begin then
		UIKit.rebond(actionPing.bouton)
		ouvrirPings()
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("ZsurvieReparer", actionReparer, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
ContextActionService:BindAction(
	"ZsurvieDefense",
	actionDefense,
	false,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.KeypadOne,
	Enum.KeyCode.KeypadTwo,
	Enum.KeyCode.KeypadThree,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadRight
)
ContextActionService:BindAction("ZsurviePing", actionPings, false, Enum.KeyCode.Q, Enum.KeyCode.DPadUp)

------------------------------------------------------------------------------------------
-- Désignation d'une cible prioritaire : tap ou clic → BlasterControleur (a26)
------------------------------------------------------------------------------------------

local cibleMarquee: any = nil

local ancreCible = UIKit.creer("Attachment", { Name = "AncreCible", Parent = Workspace.Terrain })
local marqueur = UIKit.creer("BillboardGui", {
	Name = "MarqueurCible",
	Adornee = ancreCible,
	AlwaysOnTop = true,
	Enabled = false,
	LightInfluence = 0,
	ResetOnSpawn = false,
	Size = UDim2.fromOffset(54, 54),
	Parent = playerGui,
})
local viseur = UIKit.creer("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.5),
	Rotation = 45,
	Size = UDim2.fromScale(0.7, 0.7),
	Parent = marqueur,
})
UIKit.creer("UIStroke", { Color = UIKit.lumiere(C.ToitOrange), Thickness = 4, Parent = viseur })
TweenService:Create(viseur, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
	Rotation = 405,
}):Play()

local function designer(ecran: Vector2)
	if not (zbiresRendu and blaster) then
		return
	end
	local trouve, id = pcall(zbiresRendu.chercher, ecran, TOLERANCE_DESIGNATION)
	if not trouve or id == nil then
		return
	end
	pcall(blaster.definirCiblePrioritaire, id)
	cibleMarquee = id
	UIKit.son("Clic")
end

UserInputService.TouchTapInWorld:Connect(function(position: Vector2, traiteParUI: boolean)
	if not traiteParUI then
		designer(position)
	end
end)

UserInputService.InputBegan:Connect(function(entree: InputObject, traite: boolean)
	if not traite and entree.UserInputType == Enum.UserInputType.MouseButton1 then
		designer(Vector2.new(entree.Position.X, entree.Position.Y))
	end
end)

-- Un seul appel par frame à ZbiresRendu.position : le marqueur suit le Zbire lissé par a26.
RunService.RenderStepped:Connect(function()
	if cibleMarquee == nil then
		return
	end
	local trouve, position = pcall(zbiresRendu.position, cibleMarquee)
	if trouve and typeof(position) == "Vector3" then
		ancreCible.WorldPosition = position
		marqueur.Enabled = true
	else
		cibleMarquee = nil
		marqueur.Enabled = false
	end
end)

------------------------------------------------------------------------------------------
-- RÉPARER contextuel (4 Hz) : opaque et pulsé si la Maison est abîmée et à ≤ 14 studs
------------------------------------------------------------------------------------------

local pulsationReparer = TweenService:Create(reparer.contour, PULSATION, { Color = C.Creme, Thickness = 5 })
local pointMaison = UIKit.point("MAISON")
local reparationPossible = false

task.spawn(function()
	while gui.Parent do
		local racine = UIKit.racineLocale()
		local pvMax = tonumber(etatRun:GetAttribute("MaisonPVMax")) or 1
		local abimee = (tonumber(etatRun:GetAttribute("MaisonPV")) or pvMax) < pvMax
		local possible = racine ~= nil
			and pointMaison ~= nil
			and abimee
			and UIKit.distancePlate(racine.Position, pointMaison) <= UIKit.PORTEE_REPARATION
		if possible ~= reparationPossible then
			reparationPossible = possible
			reparer.bouton.BackgroundTransparency = if possible then 0 else 0.4
			if possible then
				pulsationReparer:Play()
			else
				pulsationReparer:Cancel()
				reparer.contour.Color = C.Encre
				reparer.contour.Thickness = 3
			end
		end
		task.wait(0.25)
	end
end)

------------------------------------------------------------------------------------------
-- Crochets a10 : UIKit.pulser("Muret", …) et UIKit.pulser("Ping", …, "PingColosse")
------------------------------------------------------------------------------------------

local function brancherPulsation(nom: string, action)
	local pulsation = TweenService:Create(action.contour, PULSATION, { Color = C.Creme, Thickness = 5 })
	UIKit.surEtat("Pulse" .. nom, function(valeur: any)
		if valeur then
			pulsation:Play()
		else
			pulsation:Cancel()
			action.contour.Color = C.Encre
			action.contour.Thickness = 3
		end
		if action.icone then
			local image = if type(valeur) == "string" then UIKit.icone(valeur) else ""
			action.icone.Image = image
			action.icone.Visible = image ~= ""
			action.label.Visible = image == ""
		end
	end)
end
brancherPulsation("Muret", boutonsDefense.Muret or actionPoser)
brancherPulsation("Ping", actionPing)

-- Établi ouvert : l'arc se masque, RÉPARER reste.
UIKit.surEtat("EtabliOuvert", function(ouvert: any)
	for _, bouton in secondaires do
		bouton.Visible = not ouvert
	end
	if ouvert then
		fermerRoue()
	end
end)

------------------------------------------------------------------------------------------
-- Pas de saut sur la Prairie : couper l'état Jumping retire aussi le bouton de saut tactile
------------------------------------------------------------------------------------------

local function sansSaut(personnage: Model)
	local humanoide = personnage:WaitForChild("Humanoid", 10)
	if not (humanoide and humanoide:IsA("Humanoid")) then
		warn("[a28 Controles] Humanoid du Survivant introuvable après 10 s")
		return
	end
	humanoide.UseJumpPower = false
	humanoide.JumpHeight = 0
	humanoide:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end
if joueur.Character then
	task.spawn(sansSaut, joueur.Character)
end
joueur.CharacterAdded:Connect(sansSaut)

------------------------------------------------------------------------------------------
-- Réception serveur : refus et étourdissement
------------------------------------------------------------------------------------------

UIKit.ecouter("Annonce", function(cle: string, donnees: any)
	if cle == "Refus" and type(donnees) == "table" then
		refuser(tostring(donnees.raison))
	end
end)

joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
	if UIKit.estEtourdi(joueur) then
		maintien = nil
		arreterReparation()
		fermerRoue()
	end
end)

joueur.CharacterRemoving:Connect(function()
	maintien = nil
	arreterReparation()
end)
