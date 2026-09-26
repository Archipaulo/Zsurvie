-- Emplacement Roblox : ReplicatedStorage > Client > UIKit (ModuleScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Boîte à outils partagée des LocalScripts de l'interface.
-- Palette (ReplicatedStorage.Charte + repli), rebond élastique du canon, sons bridés, toasts,
-- UIScale du gabarit 800 × 360, attentes bornées (10 s + warn), place (Workspace.TypePlace),
-- remotes, réglages, prix du Catalogue, points du Plan, têtes des Survivants, crochets pour a10.
-- Ce module ne décide de rien : il affiche ce que le serveur a écrit et transmet des demandes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local UIKit = {}

UIKit.POLICE = Enum.Font.FredokaOne
UIKit.DELAI = 10 -- s : délai de chaque WaitForChild, suivi d'un warn
UIKit.GABARIT = Vector2.new(800, 360) -- px : maquette HUD de référence
UIKit.ECHELLE_MAX = 1.4
UIKit.PORTEE_REPARATION = 14 -- studs depuis Plan.MAISON (affichage ; le serveur tranche)
UIKit.DEFENSES_MAX = 3 -- canon §6
UIKit.SECOUSSE_MAX = 0.8 -- stud
UIKit.REGLAGES_DEFAUT = { TirAuto = true, Secousses = true, EffetsReduits = false, Musique = 1, Effets = 1 }

------------------------------------------------------------------------------------------
-- Attentes bornées et modules
------------------------------------------------------------------------------------------

function UIKit.attendre(parent: Instance?, nom: string): Instance?
	if not parent then
		warn(`[a28] parent absent : {nom} ne peut pas être attendu`)
		return nil
	end
	local enfant = parent:WaitForChild(nom, UIKit.DELAI)
	if not enfant then
		warn(`[a28] {parent:GetFullName()}.{nom} introuvable après {UIKit.DELAI} s`)
	end
	return enfant
end

local cacheModules = {}

-- Modules partagés dans ReplicatedStorage (Charte, Catalogue, Plan, BlasterStats) ; modules client
-- à côté de UIKit, dans ReplicatedStorage.Client (ZbiresRendu, BlasterControleur, VfxClient).
function UIKit.module(nom: string, client: boolean?): any
	if cacheModules[nom] == nil then
		local instance = UIKit.attendre(if client then script.Parent else ReplicatedStorage, nom)
		local resultat: any = false
		if instance and instance:IsA("ModuleScript") then
			local ok, valeur = pcall(require, instance)
			if ok then
				resultat = valeur
			else
				warn(`[a28] require({nom}) a échoué : {valeur}`)
			end
		end
		cacheModules[nom] = resultat
	end
	return cacheModules[nom] or nil
end

------------------------------------------------------------------------------------------
-- Palette et icônes
------------------------------------------------------------------------------------------

-- Palette du canon §7. Sert uniquement de repli si ReplicatedStorage.Charte manque une clé.
local PALETTE_REPLI = {
	Encre = "#1E1B2E",
	Prairie = "#6CC24A",
	TerreBattue = "#C8894F",
	Creme = "#F6E7C1",
	ToitOrange = "#EF7A2F",
	Or = "#FFC933",
	GemmeCyan = "#33D6F0",
	VioletHorde = "#9B5DE5",
	Alerte = "#FF2E63",
	NuitLabo = "#2A3263",
	Ardoise = "#4A4560",
}

local charte = UIKit.module("Charte")

local function lireCharte(nom: string): Color3?
	if type(charte) ~= "table" then
		return nil
	end
	local couleurs = charte.Couleurs
	local valeur = if type(couleurs) == "table" and couleurs[nom] ~= nil then couleurs[nom] else charte[nom]
	return if typeof(valeur) == "Color3" then valeur else nil
end

UIKit.Couleurs = {}
for nom, hex in PALETTE_REPLI do
	UIKit.Couleurs[nom] = lireCharte(nom) or Color3.fromHex(hex)
end
local C = UIKit.Couleurs

-- Teintes du canon : ombre = base × 0,8 ; lumière = base + 20 % de Crème.
function UIKit.ombre(couleur: Color3): Color3
	return Color3.new(couleur.R * 0.8, couleur.G * 0.8, couleur.B * 0.8)
end

function UIKit.lumiere(couleur: Color3): Color3
	return couleur:Lerp(C.Creme, 0.2)
end

-- Charte.Icones.<Nom> = "rbxassetid://…" ; chaîne vide si absente : le texte du bouton prend le relais.
function UIKit.icone(nom: string): string
	local icones = type(charte) == "table" and charte.Icones or nil
	local valeur = type(icones) == "table" and icones[nom] or nil
	return if type(valeur) == "string" then valeur else ""
end

------------------------------------------------------------------------------------------
-- Listes partagées (noms officiels du canon)
------------------------------------------------------------------------------------------

UIKit.DEFENSES = {
	{ cle = "Muret", texte = "Muret", court = "MURET", couleur = C.Ardoise },
	{ cle = "MiniTourelle", texte = "Mini-Tourelle", court = "MINI-\nTOURELLE", couleur = C.ToitOrange },
	{ cle = "TapisCollant", texte = "Tapis Collant", court = "TAPIS\nCOLLANT", couleur = C.Prairie },
}

UIKit.PINGS = {
	{ cle = "Colosse", texte = "Colosse !", couleur = C.Alerte },
	{ cle = "Repare", texte = "Répare !", couleur = C.ToitOrange },
	{ cle = "Ici", texte = "Ici !", couleur = C.Prairie },
	{ cle = "Merci", texte = "Merci !", couleur = C.TerreBattue },
}
UIKit.PINGS_PAR_CLE = {}
for _, ping in UIKit.PINGS do
	UIKit.PINGS_PAR_CLE[ping.cle] = ping
end

------------------------------------------------------------------------------------------
-- Fabrique d'instances et habillage
------------------------------------------------------------------------------------------

function UIKit.creer(classe: string, proprietes: { [string]: any }, enfants: { Instance }?): any
	local instance: any = Instance.new(classe)
	for cle, valeur in proprietes do
		if cle ~= "Parent" then
			instance[cle] = valeur
		end
	end
	if enfants then
		for _, enfant in enfants do
			enfant.Parent = instance
		end
	end
	if proprietes.Parent then
		instance.Parent = proprietes.Parent
	end
	return instance
end

-- Coins légèrement arrondis (style Pixel-bloc) + contour Encre.
function UIKit.habiller(objet: GuiObject, rayon: number?, epaisseur: number?): GuiObject
	UIKit.creer("UICorner", { CornerRadius = UDim.new(0, rayon or 6), Parent = objet })
	UIKit.creer("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = C.Encre,
		Thickness = epaisseur or 3,
		Parent = objet,
	})
	return objet
end

function UIKit.etiquette(parent: Instance, texte: string, taille: UDim2, tailleMax: number?): TextLabel
	local label = UIKit.creer("TextLabel", {
		BackgroundTransparency = 1,
		Font = UIKit.POLICE,
		Size = taille,
		Text = texte,
		TextColor3 = C.Creme,
		TextScaled = true,
		Parent = parent,
	})
	UIKit.creer("UITextSizeConstraint", { MaxTextSize = tailleMax or 28, MinTextSize = 9, Parent = label })
	UIKit.creer("UIStroke", { Color = C.Encre, Thickness = 2, Parent = label })
	return label
end

function UIKit.bouton(parent: Instance, texte: string, taille: UDim2, couleur: Color3, tailleMax: number?)
	local bouton = UIKit.creer("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = couleur,
		Size = taille,
		Text = "",
		Parent = parent,
	})
	UIKit.habiller(bouton, 8, 3)
	local label = UIKit.etiquette(bouton, texte, UDim2.new(1, -10, 1, -10), tailleMax)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	return bouton, label
end

------------------------------------------------------------------------------------------
-- Rebond élastique du canon §7 : écrasement × 0,8, étirement × 1,2, 0,15 s au total
------------------------------------------------------------------------------------------

local taillesDeBase = setmetatable({}, { __mode = "k" })
local jetons = setmetatable({}, { __mode = "k" })
local ETAPE = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function multiplier(u: UDim2, fx: number, fy: number): UDim2
	return UDim2.new(u.X.Scale * fx, u.X.Offset * fx, u.Y.Scale * fy, u.Y.Offset * fy)
end

-- À n'utiliser que sur des objets dont la taille ne change pas par ailleurs
-- (hors UIGridLayout, qui impose la taille des cellules).
function UIKit.rebond(objet: GuiObject)
	local base = taillesDeBase[objet] or objet.Size
	taillesDeBase[objet] = base
	local jeton = (jetons[objet] or 0) + 1
	jetons[objet] = jeton
	task.spawn(function()
		for _, taille in { multiplier(base, 1.2, 0.8), multiplier(base, 0.8, 1.2), base } do
			if jetons[objet] ~= jeton then
				return
			end
			local tween = TweenService:Create(objet, ETAPE, { Size = taille })
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

------------------------------------------------------------------------------------------
-- Sons UI (SoundService.SonsUI, SoundGroup Effets), bridés pour rester sous 16 sons simultanés
------------------------------------------------------------------------------------------

local derniersSons = {}
function UIKit.son(nom: string, intervalleMin: number?)
	local dossier = SoundService:FindFirstChild("SonsUI")
	local son = dossier and dossier:FindFirstChild(nom)
	if not (son and son:IsA("Sound")) then
		return
	end
	local maintenant = os.clock()
	if maintenant - (derniersSons[nom] or 0) < (intervalleMin or 0.08) then
		return
	end
	derniersSons[nom] = maintenant
	SoundService:PlayLocalSound(son)
end

------------------------------------------------------------------------------------------
-- Échelle : UIScale = clamp(min(X / 800, Y / 360), 1, 1,4), partagée par tout le HUD
------------------------------------------------------------------------------------------

UIKit.facteur = 1
local uiScales = setmetatable({}, { __mode = "k" })
local rappelsEchelle = {}
local connexionVue: RBXScriptConnection? = nil

local function recalculer()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local vue = camera.ViewportSize
	local facteur = math.clamp(math.min(vue.X / UIKit.GABARIT.X, vue.Y / UIKit.GABARIT.Y), 1, UIKit.ECHELLE_MAX)
	if facteur == UIKit.facteur then
		return
	end
	UIKit.facteur = facteur
	for uiScale in uiScales do
		uiScale.Scale = facteur
	end
	for _, rappel in rappelsEchelle do
		task.spawn(rappel, facteur)
	end
end

local function brancherCamera()
	if connexionVue then
		connexionVue:Disconnect()
	end
	local camera = Workspace.CurrentCamera
	if camera then
		connexionVue = camera:GetPropertyChangedSignal("ViewportSize"):Connect(recalculer)
		recalculer()
	end
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(brancherCamera)
brancherCamera()

function UIKit.echelle(objet: GuiObject): UIScale
	local uiScale = UIKit.creer("UIScale", { Scale = UIKit.facteur, Parent = objet })
	uiScales[uiScale] = true
	return uiScale
end

-- Pour les positions qui dépendent de la taille d'un autre bloc mis à l'échelle.
function UIKit.surEchelle(rappel: (number) -> ())
	table.insert(rappelsEchelle, rappel)
	rappel(UIKit.facteur)
end

------------------------------------------------------------------------------------------
-- Toasts (refus, rappels courts)
------------------------------------------------------------------------------------------

local toast = nil
local jetonToast = 0

function UIKit.toast(texte: string, couleur: Color3?)
	if not toast then
		local playerGui = UIKit.attendre(Players.LocalPlayer, "PlayerGui")
		if not playerGui then
			return
		end
		local gui = UIKit.creer("ScreenGui", {
			Name = "ToastsZsurvie",
			DisplayOrder = 20,
			ResetOnSpawn = false,
			ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
			Parent = playerGui,
		})
		local cadre = UIKit.creer("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = C.Encre,
			BackgroundTransparency = 0.1,
			Position = UDim2.fromScale(0.5, 0.7),
			Size = UDim2.fromOffset(300, 44),
			Visible = false,
			Parent = gui,
		})
		UIKit.habiller(cadre, 6, 3)
		UIKit.echelle(cadre)
		local label = UIKit.etiquette(cadre, "", UDim2.new(1, -16, 1, -8), 24)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromScale(0.5, 0.5)
		toast = { cadre = cadre, label = label }
	end
	jetonToast += 1
	local jeton = jetonToast
	toast.label.Text = texte
	toast.label.TextColor3 = couleur or C.Creme
	toast.cadre.Visible = true
	UIKit.rebond(toast.cadre)
	task.delay(1.8, function()
		if jeton == jetonToast then
			toast.cadre.Visible = false
		end
	end)
end

------------------------------------------------------------------------------------------
-- Place, état de run et remotes
------------------------------------------------------------------------------------------

local typePlace: string? = nil

-- Workspace.TypePlace = "Laboratoire" ou "Prairie", posé dans Studio sur chaque place.
function UIKit.typePlace(): string
	if typePlace then
		return typePlace
	end
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	local debut = os.clock()
	local valeur = Workspace:GetAttribute("TypePlace")
	while valeur == nil and os.clock() - debut < UIKit.DELAI do
		task.wait(0.1)
		valeur = Workspace:GetAttribute("TypePlace")
	end
	if valeur ~= "Prairie" and valeur ~= "Laboratoire" then
		warn(`[a28] Workspace.TypePlace invalide ({tostring(valeur)}) après {UIKit.DELAI} s : interface du Laboratoire`)
		valeur = "Laboratoire"
	end
	typePlace = valeur
	return valeur
end

function UIKit.surLaPrairie(): boolean
	return UIKit.typePlace() == "Prairie"
end

local etatRun: Instance? = nil
function UIKit.etatRun(): Instance?
	etatRun = etatRun or UIKit.attendre(ReplicatedStorage, "EtatRun")
	return etatRun
end

local dossierRemotes: Instance? = nil
local cacheRemotes = {}

function UIKit.remote(nom: string): Instance?
	if cacheRemotes[nom] == nil then
		dossierRemotes = dossierRemotes or UIKit.attendre(ReplicatedStorage, "Remotes")
		local remote = UIKit.attendre(dossierRemotes, nom)
		cacheRemotes[nom] = if remote and remote:IsA("BaseRemoteEvent") then remote else false
	end
	return cacheRemotes[nom] or nil
end

function UIKit.envoyer(nom: string, ...: any)
	local remote: any = UIKit.remote(nom)
	if remote then
		remote:FireServer(...)
	end
end

function UIKit.ecouter(nom: string, rappel: (...any) -> ()): RBXScriptConnection?
	local remote: any = UIKit.remote(nom)
	return if remote then remote.OnClientEvent:Connect(rappel) else nil
end

------------------------------------------------------------------------------------------
-- Réglages (Player.Reglages, écrits par le serveur) et secousses
------------------------------------------------------------------------------------------

local dossierReglages: Instance? = nil
function UIKit.reglages(): Instance?
	dossierReglages = dossierReglages or UIKit.attendre(Players.LocalPlayer, "Reglages")
	return dossierReglages
end

-- Lecture sans attente : valeur par défaut tant que le serveur n'a rien écrit.
function UIKit.reglage(nom: string): any
	local valeur = if dossierReglages then dossierReglages:GetAttribute(nom) else nil
	if valeur == nil then
		return UIKit.REGLAGES_DEFAUT[nom]
	end
	return valeur
end

function UIKit.surReglage(nom: string, rappel: (any) -> ())
	local dossier = UIKit.reglages()
	if dossier then
		dossier:GetAttributeChangedSignal(nom):Connect(function()
			rappel(UIKit.reglage(nom))
		end)
	end
	rappel(UIKit.reglage(nom))
end

-- Toutes les secousses passent par VfxClient.secouer (a37), plafonnées à 0,8 stud.
function UIKit.secouer(amplitude: number)
	if UIKit.reglage("Secousses") == false then
		return
	end
	local vfx = UIKit.module("VfxClient", true)
	if type(vfx) == "table" and type(vfx.secouer) == "function" then
		vfx.secouer(math.min(amplitude, UIKit.SECOUSSE_MAX))
	end
end

------------------------------------------------------------------------------------------
-- Catalogue et Plan
------------------------------------------------------------------------------------------

-- Catalogue.prix(cle, niveauVise) -> pièces ; nil = niveau MAX ou clé inconnue.
function UIKit.prix(cle: string, niveauVise: number?): number?
	local catalogue = UIKit.module("Catalogue")
	if type(catalogue) ~= "table" or type(catalogue.prix) ~= "function" then
		return nil
	end
	local ok, prix = pcall(catalogue.prix, cle, niveauVise or 1)
	return if ok and type(prix) == "number" and prix >= 0 then prix else nil
end

-- Plan.<NOM> (Vector3 ou CFrame), par exemple Plan.ETABLI et Plan.MAISON.
function UIKit.point(nom: string): Vector3?
	local plan = UIKit.module("Plan")
	local valeur = if type(plan) == "table" then plan[nom] else nil
	if typeof(valeur) == "CFrame" then
		return valeur.Position
	end
	return if typeof(valeur) == "Vector3" then valeur else nil
end

------------------------------------------------------------------------------------------
-- État partagé entre scripts et crochets pour a10
------------------------------------------------------------------------------------------

local etats, abonnes = {}, {}

function UIKit.definirEtat(nom: string, valeur: any)
	if etats[nom] == valeur then
		return
	end
	etats[nom] = valeur
	for _, rappel in abonnes[nom] or {} do
		task.spawn(rappel, valeur)
	end
end

function UIKit.surEtat(nom: string, rappel: (any) -> ())
	abonnes[nom] = abonnes[nom] or {}
	table.insert(abonnes[nom], rappel)
	rappel(etats[nom])
end

-- Crochets a10 : UIKit.pulser("Muret", true) ; UIKit.pulser("Ping", true, "PingColosse") ;
-- UIKit.pulser(nom, false) arrête la pulsation et rend le texte du bouton.
function UIKit.pulser(bouton: string, actif: boolean, icone: string?)
	UIKit.definirEtat("Pulse" .. bouton, if actif then (icone or true) else false)
end

------------------------------------------------------------------------------------------
-- Têtes des Survivants (HeadShot 48 × 48, chargée une fois par Survivant)
------------------------------------------------------------------------------------------

local cacheTetes = {}

function UIKit.tete(image: ImageLabel, userId: number)
	image:SetAttribute("UserId", userId)
	image.Image = cacheTetes[userId] or ""
	if cacheTetes[userId] then
		return
	end
	task.spawn(function()
		local ok, contenu = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if ok and type(contenu) == "string" then
			cacheTetes[userId] = contenu
			if image:GetAttribute("UserId") == userId then
				image.Image = contenu
			end
		end
	end)
end

------------------------------------------------------------------------------------------
-- Aides de lecture d'état (lecture seule)
------------------------------------------------------------------------------------------

function UIKit.formater(nombre: number): string
	local entier = tostring(math.max(0, math.floor(nombre)))
	local groupe = entier:reverse():gsub("(%d%d%d)", "%1 "):reverse()
	return (groupe:gsub("^%s+", ""))
end

function UIKit.distancePlate(a: Vector3, b: Vector3): number
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

function UIKit.racineLocale(): BasePart?
	local personnage = Players.LocalPlayer.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if racine and racine:IsA("BasePart") then
		return racine
	end
	return nil
end

-- EtourdiJusqua = Workspace:GetServerTimeNow() + 2, écrit par le serveur.
function UIKit.estEtourdi(qui: Player): boolean
	local jusqua = qui:GetAttribute("EtourdiJusqua")
	return type(jusqua) == "number" and jusqua > Workspace:GetServerTimeNow()
end

return UIKit
