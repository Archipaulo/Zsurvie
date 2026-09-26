-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Hud (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Maquette HUD unique (gabarit 800 × 360, CoreUISafeInsets).
-- Haut gauche : Pièces (Gemmes au Laboratoire) et « +X » gris rendu par la Maison au Répit.
-- Haut centre : bandeau Maison de a32 (Jour, minuteur depuis EtatRun.FinPhase, PV, Colosse).
-- Haut droite : têtes des Survivants. Centre : bannières. Plein écran : voile d'étourdissement.
-- Lecture seule : chaque valeur vient d'un attribut ou d'un RemoteEvent écrit par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Hud] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
local C = UIKit.Couleurs

local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
if not playerGui then
	return
end
local surPrairie = UIKit.surLaPrairie()

local RAPIDE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ROULEMENT = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TRAINEE = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local gui = UIKit.creer("ScreenGui", {
	Name = "HudZsurvie",
	DisplayOrder = 1,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local function suivre(instance: Instance, attribut: string, rappel: (any) -> ())
	instance:GetAttributeChangedSignal(attribut):Connect(function()
		rappel(instance:GetAttribute(attribut))
	end)
	rappel(instance:GetAttribute(attribut))
end

local function entier(valeur: any): number
	return math.floor(tonumber(valeur) or 0)
end

------------------------------------------------------------------------------------------
-- Haut gauche (8, 8), 140 × 44 px : Pièces (Or, carré) sur la Prairie, Gemmes (cyan, losange) au Labo
------------------------------------------------------------------------------------------

local attributCompteur = if surPrairie then "Pieces" else "Gemmes"
local couleurCompteur = if surPrairie then C.Or else C.GemmeCyan

local compteur = UIKit.creer("Frame", {
	Name = attributCompteur,
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.15,
	Position = UDim2.fromOffset(8, 8),
	Size = UDim2.fromOffset(140, 44),
	Parent = gui,
})
UIKit.habiller(compteur, 6, 3)
UIKit.echelle(compteur)

local icone = UIKit.creer("Frame", {
	Name = "Icone",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = couleurCompteur,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(22, 22),
	Rotation = if surPrairie then 0 else 45,
	Size = UDim2.fromOffset(20, 20),
	Parent = compteur,
})
UIKit.creer("UIStroke", { Color = UIKit.ombre(couleurCompteur), Thickness = 3, Parent = icone })

local texteCompteur = UIKit.etiquette(compteur, "0", UDim2.new(1, -50, 1, -8), 30)
texteCompteur.Position = UDim2.fromOffset(44, 4)
texteCompteur.TextXAlignment = Enum.TextXAlignment.Left
texteCompteur.TextColor3 = couleurCompteur

local valeurAffichee = UIKit.creer("NumberValue", { Name = "Affiche", Parent = compteur })
valeurAffichee.Changed:Connect(function(v: number)
	texteCompteur.Text = UIKit.formater(v)
end)

local cibleCompteur: number? = nil
suivre(joueur, attributCompteur, function(brut)
	local nouvelle = math.max(0, entier(brut))
	local ancienne = cibleCompteur
	cibleCompteur = nouvelle
	if ancienne == nil then
		valeurAffichee.Value = nouvelle
		texteCompteur.Text = UIKit.formater(nouvelle)
		return
	end
	TweenService:Create(valeurAffichee, ROULEMENT, { Value = nouvelle }):Play()
	if nouvelle > ancienne then
		UIKit.rebond(icone)
	end
end)

if not surPrairie then
	return -- Laboratoire : le reste du HUD appartient à la run.
end

local etatRun = UIKit.etatRun()
if not etatRun then
	return
end

-- « +X » gris sous le compteur (96 × 30 px) : part des pièces non ramassées rendue par la Maison
-- au Répit (50 %, crédit décidé par le serveur, annoncé par Annonce("PiecesMaison", { montant })).
local pastille = UIKit.creer("Frame", {
	Name = "GainMaison",
	BackgroundColor3 = UIKit.lumiere(C.Ardoise),
	Position = UDim2.fromOffset(0, 50),
	Size = UDim2.fromOffset(96, 30),
	Visible = false,
	Parent = compteur,
})
UIKit.habiller(pastille, 6, 3)
local texteGain = UIKit.etiquette(pastille, "", UDim2.new(1, -8, 1, -6), 22)
texteGain.AnchorPoint = Vector2.new(0.5, 0.5)
texteGain.Position = UDim2.fromScale(0.5, 0.5)
local jetonGain = 0

local function gainMaison(montant: number)
	jetonGain += 1
	local jeton = jetonGain
	texteGain.Text = "+" .. UIKit.formater(montant)
	pastille.Visible = true
	UIKit.rebond(pastille)
	UIKit.son("Piece")
	task.delay(2.5, function()
		if jeton == jetonGain then
			pastille.Visible = false
		end
	end)
end

------------------------------------------------------------------------------------------
-- Haut centre : bandeau Maison de a32 (280 × 66 px) = cartouche Jour + minuteur, PV, Colosse
------------------------------------------------------------------------------------------

local bandeau = UIKit.creer("Frame", {
	Name = "BandeauMaison",
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(280, 66),
	Parent = gui,
})
UIKit.echelle(bandeau)

local cartouche = UIKit.creer("Frame", {
	Name = "Cartouche",
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.15,
	Size = UDim2.new(1, 0, 0, 30),
	Parent = bandeau,
})
UIKit.habiller(cartouche, 6, 3)

local texteJour = UIKit.etiquette(cartouche, "JOUR 1", UDim2.new(0.42, -8, 1, -6), 24)
texteJour.AnchorPoint = Vector2.new(0, 0.5)
texteJour.Position = UDim2.new(0, 8, 0.5, 0)
texteJour.TextXAlignment = Enum.TextXAlignment.Left
texteJour.TextColor3 = C.ToitOrange

local minuteur = UIKit.etiquette(cartouche, "HORDE 1:20", UDim2.new(0.58, -8, 1, -6), 24)
minuteur.AnchorPoint = Vector2.new(1, 0.5)
minuteur.Position = UDim2.new(1, -8, 0.5, 0)
minuteur.TextXAlignment = Enum.TextXAlignment.Right

local function creerJauge(nom: string, y: number, hauteur: number, couleur: Color3, titre: string)
	local fond = UIKit.creer("Frame", {
		Name = nom,
		BackgroundColor3 = UIKit.ombre(C.Ardoise),
		ClipsDescendants = true,
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, hauteur),
		Parent = bandeau,
	})
	UIKit.habiller(fond, 0, 3)
	local trainee = UIKit.creer("Frame", {
		Name = "Trainee",
		BackgroundColor3 = C.Creme,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = fond,
	})
	local remplissage = UIKit.creer("Frame", {
		Name = "Remplissage",
		BackgroundColor3 = couleur,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = fond,
	})
	local label = UIKit.etiquette(fond, titre, UDim2.fromScale(1, 1), 14)
	return {
		fond = fond,
		trainee = trainee,
		remplissage = remplissage,
		label = label,
		contour = fond:FindFirstChildOfClass("UIStroke"),
		ratio = 1,
		jeton = 0,
	}
end

local jaugeMaison = creerJauge("Maison", 34, 20, C.ToitOrange, "MAISON")
local jaugeColosse = creerJauge("Colosse", 58, 8, C.VioletHorde, "")
jaugeColosse.fond.Visible = false

local pulsationMaison = TweenService:Create(
	jaugeMaison.contour,
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
	{ Color = C.Alerte }
)

-- 3 paliers alignés sur les 3 états visuels de la Maison.
local function couleurMaison(ratio: number): Color3
	if ratio > 0.66 then
		return UIKit.lumiere(C.ToitOrange)
	elseif ratio > 0.33 then
		return C.ToitOrange
	end
	return C.Alerte
end

-- Remplissage immédiat (0,25 s) puis traînée Crème 0,4 s après le DERNIER coup.
local function majJauge(jauge, pv: number, pvMax: number, fonctionCouleur: ((number) -> Color3)?)
	local ratio = math.clamp(pv / math.max(1, pvMax), 0, 1)
	local cible = UDim2.fromScale(ratio, 1)
	local proprietes: { [string]: any } = { Size = cible }
	if fonctionCouleur then
		proprietes.BackgroundColor3 = fonctionCouleur(ratio)
	end
	TweenService:Create(jauge.remplissage, RAPIDE, proprietes):Play()
	jauge.jeton += 1
	if ratio < jauge.ratio then
		local jeton = jauge.jeton
		task.delay(0.4, function()
			if jauge.jeton == jeton then
				TweenService:Create(jauge.trainee, TRAINEE, { Size = cible }):Play()
			end
		end)
	else
		jauge.trainee.Size = cible
	end
	local baisse = jauge.ratio - ratio
	jauge.ratio = ratio
	return ratio, baisse
end

local maisonCritique = false
local function majMaison()
	local pvMax = math.max(1, entier(etatRun:GetAttribute("MaisonPVMax")))
	local pv = math.clamp(entier(etatRun:GetAttribute("MaisonPV")), 0, pvMax)
	local ratio, baisse = majJauge(jaugeMaison, pv, pvMax, couleurMaison)
	jaugeMaison.label.Text = `MAISON {UIKit.formater(pv)} / {UIKit.formater(pvMax)}`
	local critique = ratio <= 0.33
	if critique ~= maisonCritique then
		maisonCritique = critique
		if critique then
			pulsationMaison:Play()
		else
			pulsationMaison:Cancel()
			jaugeMaison.contour.Color = C.Encre
		end
	end
	if baisse > 0.05 then
		UIKit.rebond(jaugeMaison.fond)
	end
end

local function majColosse()
	local actif = etatRun:GetAttribute("Colosse") == true
	jaugeColosse.fond.Visible = actif
	if actif then
		majJauge(
			jaugeColosse,
			entier(etatRun:GetAttribute("ColossePV")),
			entier(etatRun:GetAttribute("ColossePVMax")),
			nil
		)
	end
end

etatRun:GetAttributeChangedSignal("MaisonPV"):Connect(majMaison)
etatRun:GetAttributeChangedSignal("MaisonPVMax"):Connect(majMaison)
etatRun:GetAttributeChangedSignal("ColossePV"):Connect(majColosse)
etatRun:GetAttributeChangedSignal("ColossePVMax"):Connect(majColosse)
majMaison()

------------------------------------------------------------------------------------------
-- Phase et minuteur : FinPhase − Workspace:GetServerTimeNow(), rafraîchi à 5 Hz
------------------------------------------------------------------------------------------

local PHASES = {
	Horde = { titre = "HORDE", couleur = UIKit.lumiere(C.VioletHorde) },
	Repit = { titre = "RÉPIT", couleur = C.Prairie },
}
local dernierBip = -1

local function phaseCourante(): (string, Color3)
	if etatRun:GetAttribute("Colosse") == true then
		return "COLOSSE", C.Alerte
	end
	local phase = PHASES[etatRun:GetAttribute("Phase")] or PHASES.Horde
	return phase.titre, phase.couleur
end

local function majPhase()
	local _, couleur = phaseCourante()
	minuteur.TextColor3 = couleur
	dernierBip = -1
	UIKit.rebond(cartouche)
end

suivre(etatRun, "Jour", function(jour)
	texteJour.Text = "JOUR " .. tostring(math.max(1, entier(jour)))
	UIKit.rebond(texteJour)
end)
etatRun:GetAttributeChangedSignal("Phase"):Connect(majPhase)
etatRun:GetAttributeChangedSignal("Colosse"):Connect(function()
	majPhase()
	majColosse()
end)
majPhase()
majColosse()

task.spawn(function()
	while gui.Parent do
		local titre = phaseCourante()
		local fin = tonumber(etatRun:GetAttribute("FinPhase")) or 0
		local reste = math.max(0, math.ceil(fin - Workspace:GetServerTimeNow()))
		minuteur.Text = string.format("%s %d:%02d", titre, reste // 60, reste % 60)
		if etatRun:GetAttribute("Phase") == "Repit" and reste > 0 and reste <= 5 and reste ~= dernierBip then
			dernierBip = reste
			UIKit.son("Bip")
			UIKit.rebond(minuteur)
		end
		task.wait(0.2)
	end
end)

------------------------------------------------------------------------------------------
-- Haut droite : têtes des Survivants (6 × 32 px, 4 px d'écart), contour Alerte si étourdi
------------------------------------------------------------------------------------------

local rangee = UIKit.creer("Frame", {
	Name = "Survivants",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -8, 0, 8),
	Size = UDim2.fromOffset(212, 32),
	Parent = gui,
})
UIKit.echelle(rangee)
UIKit.creer("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = rangee,
})

local vignettes = {} -- [Player] = { cellule, image, contour, connexion }
local ordreArrivee = 0

local function majVignette(autre: Player)
	local vignette = vignettes[autre]
	if not vignette then
		return
	end
	local etourdi = UIKit.estEtourdi(autre)
	vignette.contour.Color = if etourdi then C.Alerte elseif autre == joueur then C.ToitOrange else C.Creme
	vignette.image.ImageTransparency = if etourdi then 0.5 else 0
	if etourdi then
		UIKit.rebond(vignette.image)
		local reste = (tonumber(autre:GetAttribute("EtourdiJusqua")) or 0) - Workspace:GetServerTimeNow()
		task.delay(math.clamp(reste, 0, 4) + 0.05, majVignette, autre)
	end
end

local function ajouterVignette(autre: Player)
	if vignettes[autre] then
		return
	end
	ordreArrivee += 1
	local cellule = UIKit.creer("Frame", {
		Name = "Survivant" .. autre.UserId,
		BackgroundTransparency = 1,
		LayoutOrder = if autre == joueur then 0 else ordreArrivee,
		Size = UDim2.fromOffset(32, 32),
		Parent = rangee,
	})
	local image = UIKit.creer("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.NuitLabo,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(32, 32),
		Parent = cellule,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 6), Parent = image })
	local contour = UIKit.creer("UIStroke", { Color = C.Creme, Thickness = 3, Parent = image })
	UIKit.tete(image, autre.UserId)
	vignettes[autre] = {
		cellule = cellule,
		image = image,
		contour = contour,
		connexion = autre:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
			majVignette(autre)
		end),
	}
	majVignette(autre)
end

for _, autre in Players:GetPlayers() do
	ajouterVignette(autre)
end
Players.PlayerAdded:Connect(ajouterVignette)
Players.PlayerRemoving:Connect(function(autre: Player)
	local vignette = vignettes[autre]
	if vignette then
		vignette.connexion:Disconnect()
		vignette.cellule:Destroy()
		vignettes[autre] = nil
	end
end)

------------------------------------------------------------------------------------------
-- Bannières d'annonce (centre, 440 × 64 px)
------------------------------------------------------------------------------------------

local banniere = UIKit.creer("Frame", {
	Name = "Banniere",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.1,
	Position = UDim2.fromScale(0.5, 0.36),
	Size = UDim2.fromOffset(440, 64),
	Visible = false,
	Parent = gui,
})
UIKit.habiller(banniere, 8, 4)
UIKit.echelle(banniere)
local texteBanniere = UIKit.etiquette(banniere, "", UDim2.new(1, -20, 1, -12), 34)
texteBanniere.AnchorPoint = Vector2.new(0.5, 0.5)
texteBanniere.Position = UDim2.fromScale(0.5, 0.5)
local jetonBanniere = 0

local function annoncer(texte: string, couleur: Color3, duree: number)
	jetonBanniere += 1
	local jeton = jetonBanniere
	texteBanniere.Text = texte
	texteBanniere.TextColor3 = couleur
	banniere.Rotation = -4
	banniere.Visible = true
	UIKit.rebond(banniere)
	TweenService:Create(banniere, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0,
	}):Play()
	task.delay(duree, function()
		if jeton == jetonBanniere then
			banniere.Visible = false
		end
	end)
end

UIKit.ecouter("Annonce", function(cle: string, donnees: any)
	local d = if type(donnees) == "table" then donnees else {}
	if cle == "Colosse" then
		annoncer("LE COLOSSE ARRIVE !", C.Alerte, 3)
		UIKit.son("Alerte")
	elseif cle == "JourFranchi" then
		annoncer(string.format("JOUR %d FRANCHI !  +%d gemmes", entier(d.jour), entier(d.gemmes)), C.GemmeCyan, 2.5)
		UIKit.son("Achat")
	elseif cle == "Record" then
		annoncer(string.format("NOUVEAU RECORD : JOUR %d !", entier(d.jour)), UIKit.lumiere(C.ToitOrange), 3)
	elseif cle == "MaisonTombee" then
		annoncer(
			string.format("LA MAISON EST TOMBÉE ! Jour %d  +%d gemmes", entier(d.jour), entier(d.gemmes)),
			C.Creme,
			6
		)
	elseif cle == "PiecesMaison" then
		local montant = entier(d.montant)
		if montant > 0 then
			gainMaison(montant)
		end
	end
end)

------------------------------------------------------------------------------------------
-- Voile d'étourdissement (2 s) : lu dans l'attribut EtourdiJusqua écrit par le serveur
------------------------------------------------------------------------------------------

local voileGui = UIKit.creer("ScreenGui", {
	Name = "VoileEtourdi",
	DisplayOrder = 10,
	Enabled = false,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.None,
	Parent = playerGui,
})
local voile = UIKit.creer("Frame", {
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Parent = voileGui,
})
local blocEtourdi = UIKit.creer("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(0.5, 0.4),
	Size = UDim2.fromOffset(260, 70),
	Parent = voile,
})
UIKit.echelle(blocEtourdi)
local texteEtourdi = UIKit.etiquette(blocEtourdi, "ÉTOURDI !", UDim2.new(1, 0, 0, 44), 40)
local fondJaugeEtourdi = UIKit.creer("Frame", {
	BackgroundColor3 = UIKit.ombre(C.Ardoise),
	ClipsDescendants = true,
	Position = UDim2.fromOffset(0, 54),
	Size = UDim2.new(1, 0, 0, 12),
	Parent = blocEtourdi,
})
UIKit.habiller(fondJaugeEtourdi, 0, 3)
local jaugeEtourdi = UIKit.creer("Frame", {
	BackgroundColor3 = C.Creme,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Parent = fondJaugeEtourdi,
})
local jetonEtourdi = 0

local function majEtourdi()
	local jusqua = tonumber(joueur:GetAttribute("EtourdiJusqua")) or 0
	local duree = math.min(jusqua - Workspace:GetServerTimeNow(), 4)
	if duree <= 0.05 then
		return
	end
	jetonEtourdi += 1
	local jeton = jetonEtourdi
	voileGui.Enabled = true
	voile.BackgroundTransparency = 1
	TweenService:Create(voile, TweenInfo.new(0.12), { BackgroundTransparency = 0.6 }):Play()
	jaugeEtourdi.Size = UDim2.fromScale(1, 1)
	TweenService:Create(jaugeEtourdi, TweenInfo.new(duree, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(0, 1),
	}):Play()
	UIKit.rebond(texteEtourdi)
	UIKit.son("Etourdi")
	task.delay(duree, function()
		if jeton ~= jetonEtourdi then
			return
		end
		local sortie = TweenService:Create(voile, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
		sortie.Completed:Once(function()
			if jeton == jetonEtourdi then
				voileGui.Enabled = false
			end
		end)
		sortie:Play()
	end)
end

joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(majEtourdi)
