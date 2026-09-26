-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Etabli (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · L'Établi : 8 améliorations valables jusqu'à la fin de la run.
-- Bouton contextuel de 72 px à 10 studs au plus de Plan.ETABLI ; ouverture automatique seulement
-- pendant le Répit ; taps ignorés 0,8 s après l'ouverture ; panneau latéral droit de 55 % qui laisse
-- RÉPARER visible ; carte cagnotte d'équipe (jauge, têtes des contributeurs).
-- Prix lus dans ReplicatedStorage.Catalogue ; niveaux dans Niv<Cle> (Player, ou EtatRun pour les
-- améliorations d'équipe). Le client envoie DemandeAchat(cle, niveauVise) et reste en Attente
-- jusqu'à ProfilMaj ou Annonce. Solde, plafond et part versée à la cagnotte sont décidés par le serveur.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Etabli] ReplicatedStorage.Client.UIKit introuvable après 10 s")
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
local pointEtabli = UIKit.point("ETABLI")
if not pointEtabli then
	warn("[a28 Etabli] Plan.ETABLI absent : pas de bouton contextuel")
end
local blasterStats = UIKit.module("BlasterStats")
UIKit.remote("DemandeAchat") -- résolution anticipée

local RAYON = 10 -- studs : le bouton apparaît à 10 studs au plus de Plan.ETABLI
local RAYON_SORTIE = 12 -- studs : hystérésis, le bouton ne clignote pas en bord de zone
local DELAI_TAPS = 0.8 -- s : taps ignorés juste après l'ouverture
local ATTENTE_MAX = 4 -- s : filet si ni ProfilMaj ni Annonce n'arrive
local RAPIDE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_TREMBLE = TweenInfo.new(0.04, Enum.EasingStyle.Linear)

-- Noms officiels du canon §6 ; equipe = profite à toute l'équipe, financée par la cagnotte.
local AMELIORATIONS = {
	{ cle = "Degats", nom = "Dégâts", aide = "Tirs plus forts" },
	{ cle = "Cadence", nom = "Cadence", aide = "Tirs plus rapides" },
	{ cle = "Portee", nom = "Portée", aide = "Vise plus loin" },
	{ cle = "Solidite", nom = "Solidité", aide = "Maison plus solide", equipe = true },
	{ cle = "Reparation", nom = "Réparation", aide = "Répare plus vite", equipe = true },
	{ cle = "Regeneration", nom = "Régénération", aide = "La Maison se soigne", equipe = true },
	{ cle = "Butin", nom = "Butin", aide = "Plus de pièces" },
	{ cle = "BallesExplosives", nom = "Balles explosives", aide = "Les tirs explosent" },
}

local cartes = {} -- [cle] = carte
local dansZone = false
local ouvertA = 0

------------------------------------------------------------------------------------------
-- Construction : bouton contextuel 72 px et panneau latéral droit (55 % de large)
------------------------------------------------------------------------------------------

local gui = UIKit.creer("ScreenGui", {
	Name = "EtabliZsurvie",
	DisplayOrder = 2, -- sous les contrôles (3) : RÉPARER passe toujours devant
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

local boutonEtabli = UIKit.bouton(gui, "ÉTABLI", UDim2.fromOffset(72, 72), C.TerreBattue, 20)
boutonEtabli.Name = "BoutonEtabli"
boutonEtabli.AnchorPoint = Vector2.new(1, 1)
boutonEtabli.Visible = false
UIKit.echelle(boutonEtabli)
if UserInputService.KeyboardEnabled then
	local indice = UIKit.etiquette(boutonEtabli, "F", UDim2.fromOffset(22, 22), 16)
	indice.Position = UDim2.fromOffset(-6, -6)
	indice.BackgroundColor3 = C.Encre
	indice.BackgroundTransparency = 0
end

local panneau = UIKit.creer("Frame", {
	Name = "Panneau",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.05,
	Position = UDim2.new(1, -8, 0, 8),
	Visible = false,
	Parent = gui,
})
UIKit.habiller(panneau, 8, 4)

-- Le bouton se cale à 12 px à gauche de la grappe (12 + 230 px × échelle) ; le panneau s'arrête
-- 24 px au-dessus de RÉPARER (12 + 96 px × échelle depuis le bas).
UIKit.surEchelle(function(f: number)
	boutonEtabli.Position = UDim2.new(1, -(24 + 230 * f), 1, -12)
	panneau.Size = UDim2.new(0.55, 0, 1, -(8 + 12 + 96 * f + 24))
end)

local titre = UIKit.etiquette(panneau, "L'ÉTABLI", UDim2.new(0.4, 0, 0, 36), 30)
titre.Position = UDim2.fromOffset(12, 12)
titre.TextXAlignment = Enum.TextXAlignment.Left
titre.TextColor3 = C.ToitOrange

local solde = UIKit.etiquette(panneau, "0 pièces", UDim2.new(0.34, 0, 0, 30), 24)
solde.AnchorPoint = Vector2.new(0.5, 0)
solde.Position = UDim2.new(0.58, 0, 0, 15)
solde.TextColor3 = C.Or

local boutonFermer = UIKit.bouton(panneau, "X", UDim2.fromOffset(60, 60), C.Alerte, 30)
boutonFermer.AnchorPoint = Vector2.new(1, 0)
boutonFermer.Position = UDim2.new(1, -4, 0, 4)

------------------------------------------------------------------------------------------
-- Carte cagnotte (colonne gauche, 36 %) : EtatRun.CagnotteCle / Montant / Objectif / Contributeurs
------------------------------------------------------------------------------------------

local cagnotte = UIKit.creer("Frame", {
	Name = "Cagnotte",
	BackgroundColor3 = C.NuitLabo,
	Position = UDim2.fromOffset(8, 68),
	Size = UDim2.new(0.36, -12, 1, -76),
	Parent = panneau,
})
UIKit.habiller(cagnotte, 6, 3)

local titreCagnotte = UIKit.etiquette(cagnotte, "CAGNOTTE ÉQUIPE", UDim2.new(1, -12, 0, 20), 16)
titreCagnotte.Position = UDim2.fromOffset(6, 6)
titreCagnotte.TextColor3 = C.Prairie

local nomCagnotte = UIKit.etiquette(cagnotte, "", UDim2.new(1, -12, 0, 36), 16)
nomCagnotte.Position = UDim2.fromOffset(6, 28)

local fondJauge = UIKit.creer("Frame", {
	BackgroundColor3 = UIKit.ombre(C.Ardoise),
	ClipsDescendants = true,
	Position = UDim2.fromOffset(6, 70),
	Size = UDim2.new(1, -12, 0, 18),
	Parent = cagnotte,
})
UIKit.habiller(fondJauge, 0, 2)
local remplissage = UIKit.creer("Frame", {
	BackgroundColor3 = C.Or,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(0, 1),
	Parent = fondJauge,
})
local texteJauge = UIKit.etiquette(fondJauge, "", UDim2.fromScale(1, 1), 14)

local rangTetes = UIKit.creer("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(6, 94),
	Size = UDim2.new(1, -12, 0, 20),
	Parent = cagnotte,
})
UIKit.creer("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 2),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = rangTetes,
})
local tetesCagnotte = {}
for i = 1, 6 do
	local image = UIKit.creer("ImageLabel", {
		BackgroundColor3 = C.Encre,
		LayoutOrder = i,
		Size = UDim2.fromOffset(20, 20),
		Visible = false,
		Parent = rangTetes,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 4), Parent = image })
	UIKit.creer("UIStroke", { Color = C.Creme, Thickness = 1, Parent = image })
	tetesCagnotte[i] = image
end

------------------------------------------------------------------------------------------
-- Cartes (colonne droite, défilante) : 2 colonnes, 64 px de haut
------------------------------------------------------------------------------------------

local liste = UIKit.creer("ScrollingFrame", {
	Name = "Cartes",
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	Position = UDim2.new(0.36, 4, 0, 68),
	ScrollBarImageColor3 = C.Creme,
	ScrollBarThickness = 6,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Size = UDim2.new(0.64, -12, 1, -76),
	Parent = panneau,
})
UIKit.creer("UIGridLayout", {
	CellPadding = UDim2.fromOffset(6, 6),
	CellSize = UDim2.new(0.5, -9, 0, 64),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = liste,
})

local function soldePieces(): number
	return tonumber(joueur:GetAttribute("Pieces")) or 0
end

local function niveau(carte): number
	local source = if carte.equipe then etatRun else joueur
	return math.floor(tonumber(source:GetAttribute("Niv" .. carte.cle)) or 0)
end

-- Aperçu chiffré pour Portée et Cadence, lu dans BlasterStats (a26) : « 40 → 44 studs ».
local function apercu(carte, niv: number): string
	local fonction = if type(blasterStats) ~= "table" then nil
		elseif carte.cle == "Portee" then blasterStats.portee
		elseif carte.cle == "Cadence" then blasterStats.cadence
		else nil
	if type(fonction) ~= "function" then
		return carte.aide
	end
	local okA, actuel = pcall(fonction, niv)
	local okB, suivant = pcall(fonction, niv + 1)
	if not (okA and okB and type(actuel) == "number" and type(suivant) == "number") then
		return carte.aide
	end
	local unite = if carte.cle == "Portee" then "studs" else "tirs/s"
	return (string.format("%g → %g %s", actuel, suivant, unite):gsub("%.", ","))
end

local function trembler(carte)
	task.spawn(function()
		for _, angle in { -6, 6, -3, 0 } do
			local tween = TweenService:Create(carte.bouton, INFO_TREMBLE, { Rotation = angle })
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

local function mettreEnAttente(carte, actif: boolean)
	carte.attente = actif
	carte.voileAttente.Visible = actif
	carte.jeton += 1
	if actif then
		local jeton = carte.jeton
		task.delay(ATTENTE_MAX, function()
			if carte.jeton == jeton and carte.attente then
				mettreEnAttente(carte, false) -- filet : réponse perdue
			end
		end)
	end
end

local function majCarte(carte)
	local niv = niveau(carte)
	local prix = UIKit.prix(carte.cle, niv + 1)
	local pieces = soldePieces()
	local possible = prix ~= nil and (if carte.equipe then pieces > 0 else pieces >= prix)
	carte.texteNiveau.Text = if prix then `Niv. {niv} → {niv + 1}` else `Niv. {niv}`
	carte.prix.Text = if prix then UIKit.formater(prix) else "MAX"
	carte.prix.TextColor3 = if not prix then C.Creme elseif possible then C.Or else C.Alerte
	carte.piece.Visible = prix ~= nil
	carte.aideLabel.Text = apercu(carte, niv)
	carte.bouton.BackgroundColor3 = if possible then C.Ardoise else UIKit.ombre(C.Ardoise)
	if panneau.Visible and carte.niv ~= nil and niv > carte.niv then
		UIKit.rebond(carte.bouton)
		UIKit.son("Achat")
	end
	carte.niv = niv
end

local function majCagnotte()
	local cle = etatRun:GetAttribute("CagnotteCle")
	local carte = if type(cle) == "string" then cartes[cle] else nil
	if not (carte and carte.equipe) then
		nomCagnotte.Text = "Touche une carte ÉQUIPE pour la lancer !"
		remplissage.Size = UDim2.fromScale(0, 1)
		texteJauge.Text = ""
		for _, image in tetesCagnotte do
			image.Visible = false
		end
		return
	end
	local montant = math.max(0, tonumber(etatRun:GetAttribute("CagnotteMontant")) or 0)
	local objectif = math.max(1, tonumber(etatRun:GetAttribute("CagnotteObjectif")) or 1)
	nomCagnotte.Text = `{carte.nom} · Niv. {niveau(carte) + 1}`
	TweenService:Create(remplissage, RAPIDE, { Size = UDim2.fromScale(math.clamp(montant / objectif, 0, 1), 1) }):Play()
	texteJauge.Text = `{UIKit.formater(montant)} / {UIKit.formater(objectif)}`
	local index = 0
	for id in string.gmatch(tostring(etatRun:GetAttribute("CagnotteContributeurs") or ""), "%d+") do
		index += 1
		if index > #tetesCagnotte then
			break
		end
		tetesCagnotte[index].Visible = true
		UIKit.tete(tetesCagnotte[index], tonumber(id) :: number)
	end
	for i = index + 1, #tetesCagnotte do
		tetesCagnotte[i].Visible = false
	end
end

local function rafraichir()
	solde.Text = UIKit.formater(soldePieces()) .. " pièces"
	for _, carte in cartes do
		majCarte(carte)
	end
	majCagnotte()
end

local function acheter(carte)
	if os.clock() - ouvertA < DELAI_TAPS or carte.attente then
		return
	end
	local vise = niveau(carte) + 1
	local prix = UIKit.prix(carte.cle, vise)
	local pieces = soldePieces()
	if not prix or (if carte.equipe then pieces <= 0 else pieces < prix) then
		trembler(carte)
		UIKit.son("Refus")
		return
	end
	UIKit.son("Clic")
	mettreEnAttente(carte, true)
	UIKit.envoyer("DemandeAchat", carte.cle, vise)
end

for ordre, amelioration in AMELIORATIONS do
	local cellule = UIKit.creer("Frame", {
		Name = amelioration.cle,
		BackgroundTransparency = 1,
		LayoutOrder = ordre,
		Parent = liste,
	})
	-- Le bouton est dans une cellule : UIGridLayout impose la taille de la cellule, pas du bouton,
	-- ce qui laisse le rebond du canon fonctionner.
	local bouton = UIKit.creer("TextButton", {
		Name = "Carte",
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = C.Ardoise,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = cellule,
	})
	UIKit.habiller(bouton, 6, 3)

	local nom = UIKit.etiquette(bouton, amelioration.nom, UDim2.new(1, -12, 0, 20), 18)
	nom.Position = UDim2.fromOffset(6, 3)
	nom.TextXAlignment = Enum.TextXAlignment.Left

	local aide = UIKit.etiquette(bouton, amelioration.aide, UDim2.new(1, -12, 0, 16), 13)
	aide.Position = UDim2.fromOffset(6, 23)
	aide.TextXAlignment = Enum.TextXAlignment.Left

	local texteNiveau = UIKit.etiquette(bouton, "Niv. 0", UDim2.new(0.5, -6, 0, 18), 15)
	texteNiveau.Position = UDim2.new(0, 6, 1, -21)
	texteNiveau.TextXAlignment = Enum.TextXAlignment.Left

	local piece = UIKit.creer("Frame", {
		Name = "Piece",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = C.Or,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -8, 1, -12),
		Size = UDim2.fromOffset(12, 12),
		Parent = bouton,
	})
	UIKit.creer("UIStroke", { Color = UIKit.ombre(C.Or), Thickness = 2, Parent = piece })

	local prix = UIKit.etiquette(bouton, "-", UDim2.new(0.5, -28, 0, 18), 16)
	prix.AnchorPoint = Vector2.new(1, 0)
	prix.Position = UDim2.new(1, -24, 1, -21)
	prix.TextXAlignment = Enum.TextXAlignment.Right

	if amelioration.equipe then
		local badge = UIKit.creer("Frame", {
			Name = "Equipe",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = C.Prairie,
			Position = UDim2.new(1, -4, 0, -6),
			Size = UDim2.fromOffset(50, 16),
			ZIndex = 2,
			Parent = bouton,
		})
		UIKit.habiller(badge, 4, 2)
		UIKit.etiquette(badge, "ÉQUIPE", UDim2.fromScale(1, 1), 12).ZIndex = 2
	end

	local voileAttente = UIKit.creer("Frame", {
		Name = "Attente",
		BackgroundColor3 = C.Encre,
		BackgroundTransparency = 0.35,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 3,
		Parent = bouton,
	})
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, 6), Parent = voileAttente })
	UIKit.etiquette(voileAttente, "…", UDim2.fromScale(1, 1), 30).ZIndex = 3

	local carte = {
		cle = amelioration.cle,
		nom = amelioration.nom,
		aide = amelioration.aide,
		equipe = amelioration.equipe == true,
		bouton = bouton,
		aideLabel = aide,
		texteNiveau = texteNiveau,
		prix = prix,
		piece = piece,
		voileAttente = voileAttente,
		attente = false,
		jeton = 0,
		niv = nil,
	}
	cartes[amelioration.cle] = carte
	bouton.Activated:Connect(function()
		acheter(carte)
	end)
end

------------------------------------------------------------------------------------------
-- Ouverture / fermeture
------------------------------------------------------------------------------------------

local function ouvrir()
	if panneau.Visible then
		return
	end
	ouvertA = os.clock()
	rafraichir()
	panneau.Visible = true
	boutonEtabli.Visible = false
	panneau.Position = UDim2.new(1, 40, 0, 8)
	TweenService:Create(panneau, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -8, 0, 8),
	}):Play()
	UIKit.son("Clic")
	UIKit.definirEtat("EtabliOuvert", true)
end

local function fermer()
	if not panneau.Visible then
		return
	end
	panneau.Visible = false
	boutonEtabli.Visible = dansZone
	UIKit.definirEtat("EtabliOuvert", false)
end

boutonEtabli.Activated:Connect(function()
	UIKit.rebond(boutonEtabli)
	ouvrir()
end)

boutonFermer.Activated:Connect(function()
	if os.clock() - ouvertA < DELAI_TAPS then
		return
	end
	UIKit.son("Clic")
	fermer()
end)

ContextActionService:BindAction("ZsurvieEtabli", function(_, etat: Enum.UserInputState)
	if etat ~= Enum.UserInputState.Begin or not dansZone then
		return Enum.ContextActionResult.Pass
	end
	if panneau.Visible then
		fermer()
	else
		ouvrir()
	end
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.F, Enum.KeyCode.ButtonY)

-- Zone de l'Établi (4 Hz) : bouton à ≤ 10 studs, ouverture automatique à l'entrée pendant le Répit,
-- fermeture au-delà de 12 studs. Le panneau n'est pas modal : on continue de bouger.
task.spawn(function()
	while gui.Parent do
		local racine = UIKit.racineLocale()
		local distance = if racine and pointEtabli then UIKit.distancePlate(racine.Position, pointEtabli) else math.huge
		local proche = distance <= (if dansZone then RAYON_SORTIE else RAYON)
		if proche ~= dansZone then
			dansZone = proche
			boutonEtabli.Visible = proche and not panneau.Visible
			if proche and etatRun:GetAttribute("Phase") == "Repit" then
				ouvrir()
			elseif not proche then
				fermer()
			end
		end
		task.wait(0.25)
	end
end)

------------------------------------------------------------------------------------------
-- Réception serveur
------------------------------------------------------------------------------------------

joueur.AttributeChanged:Connect(function(nomAttribut: string)
	if nomAttribut == "Pieces" then
		if panneau.Visible then
			rafraichir()
		end
		return
	end
	local cle = string.match(nomAttribut, "^Niv(.+)$")
	local carte = if cle then cartes[cle] else nil
	if carte and not carte.equipe then
		majCarte(carte)
	end
end)

etatRun.AttributeChanged:Connect(function(nomAttribut: string)
	if string.sub(nomAttribut, 1, 8) == "Cagnotte" then
		if panneau.Visible then
			majCagnotte()
		end
		return
	end
	local cle = string.match(nomAttribut, "^Niv(.+)$")
	local carte = if cle then cartes[cle] else nil
	if carte and carte.equipe then
		majCarte(carte)
	end
end)

-- ProfilMaj : le serveur a appliqué (ou refusé) l'achat ; toutes les cartes sortent de l'Attente.
UIKit.ecouter("ProfilMaj", function()
	for _, carte in cartes do
		if carte.attente then
			mettreEnAttente(carte, false)
		end
	end
	if panneau.Visible then
		rafraichir()
	end
end)

UIKit.ecouter("Annonce", function(cle: string, donnees: any)
	local d = if type(donnees) == "table" then donnees else {}
	local carte = if type(d.cle) == "string" then cartes[d.cle] else nil
	if not carte then
		return
	end
	if carte.attente then
		mettreEnAttente(carte, false)
	end
	if cle == "Refus" then
		trembler(carte)
	end
end)

rafraichir()
