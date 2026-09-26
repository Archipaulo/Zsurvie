-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Reglages (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Réglages du Survivant (Laboratoire et Prairie) : Tir auto,
-- Secousses, Effets réduits, Musique, Effets sonores. Le client envoie DemandeReglage(cle, valeur) ;
-- le serveur valide, écrit l'attribut dans Player.Reglages et le sauvegarde avec le profil.
-- Un bouton n'affiche la nouvelle valeur qu'une fois écrite par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Reglages] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local playerGui = UIKit.attendre(joueur, "PlayerGui")
if not playerGui then
	return
end
UIKit.remote("DemandeReglage") -- résolution anticipée

local ATTENTE_MAX = 3 -- s : filet si le serveur ne répond pas
local VOLUMES = { 1, 0.5, 0 } -- cycle Musique / Effets : 100 %, 50 %, 0 %
local REGLAGES = {
	{ cle = "TirAuto", nom = "Tir auto", genre = "bool" },
	{ cle = "Secousses", nom = "Secousses", genre = "bool" },
	{ cle = "EffetsReduits", nom = "Effets réduits", genre = "bool" },
	{ cle = "Musique", nom = "Musique", genre = "volume" },
	{ cle = "Effets", nom = "Effets sonores", genre = "volume" },
}

local gui = UIKit.creer("ScreenGui", {
	Name = "ReglagesZsurvie",
	DisplayOrder = 8,
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

------------------------------------------------------------------------------------------
-- Bouton 60 px sous le compteur et sa pastille « +X » : Y = 8 + 88 px × échelle
------------------------------------------------------------------------------------------

local boutonOuvrir = UIKit.creer("TextButton", {
	Name = "BoutonReglages",
	AutoButtonColor = false,
	BackgroundColor3 = C.NuitLabo,
	Size = UDim2.fromOffset(60, 60),
	Text = "",
	Parent = gui,
})
UIKit.habiller(boutonOuvrir, 8, 3)
UIKit.echelle(boutonOuvrir)
UIKit.surEchelle(function(f: number)
	boutonOuvrir.Position = UDim2.fromOffset(8, 8 + 88 * f)
end)

local image = UIKit.icone("Reglages")
if image ~= "" then
	UIKit.creer("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = image,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.7),
		Parent = boutonOuvrir,
	})
else
	-- Repli sans icône : 3 barres Crème (menu), lisibles par tous les âges.
	for i = 1, 3 do
		UIKit.creer("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = C.Creme,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 16 + (i - 1) * 14),
			Size = UDim2.fromOffset(32, 6),
			Parent = boutonOuvrir,
		})
	end
end

------------------------------------------------------------------------------------------
-- Panneau central (540 × 290 px) : 5 boutons de 252 × 60 px sur 2 colonnes
------------------------------------------------------------------------------------------

local panneau = UIKit.creer("Frame", {
	Name = "Panneau",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = C.Encre,
	BackgroundTransparency = 0.05,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(540, 290),
	Visible = false,
	Parent = gui,
})
UIKit.habiller(panneau, 8, 4)
UIKit.echelle(panneau)

local titre = UIKit.etiquette(panneau, "RÉGLAGES", UDim2.fromOffset(240, 40), 32)
titre.Position = UDim2.fromOffset(14, 14)
titre.TextXAlignment = Enum.TextXAlignment.Left
titre.TextColor3 = C.ToitOrange

local boutonFermer = UIKit.bouton(panneau, "X", UDim2.fromOffset(60, 60), C.Alerte, 30)
boutonFermer.AnchorPoint = Vector2.new(1, 0)
boutonFermer.Position = UDim2.new(1, -8, 0, 8)

local grille = UIKit.creer("Frame", {
	Name = "Grille",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(12, 80),
	Size = UDim2.fromOffset(516, 196),
	Parent = panneau,
})
UIKit.creer("UIGridLayout", {
	CellPadding = UDim2.fromOffset(12, 8),
	CellSize = UDim2.fromOffset(252, 60),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = grille,
})

local function texteValeur(option, valeur: any): string
	if option.genre == "bool" then
		return if valeur == true then "OUI" else "NON"
	end
	return `{math.round((tonumber(valeur) or 0) * 100)} %`
end

local function suivante(option, valeur: any): any
	if option.genre == "bool" then
		return not (valeur == true)
	end
	local actuelle = tonumber(valeur) or 1
	for index, niveau in VOLUMES do
		if math.abs(niveau - actuelle) < 0.01 then
			return VOLUMES[index % #VOLUMES + 1]
		end
	end
	return VOLUMES[1]
end

local function afficher(option)
	local valeur = UIKit.reglage(option.cle)
	local etat = if option.attente then "…" else texteValeur(option, valeur)
	option.label.Text = `{option.nom} : {etat}`
	option.bouton.BackgroundColor3 = if option.genre == "volume" then C.NuitLabo
		elseif valeur == true then C.Prairie
		else UIKit.ombre(C.Ardoise)
end

-- Musique et Effets pilotent les SoundGroups SoundService.Musique et SoundService.Effets.
local function appliquerVolume(nomGroupe: string, valeur: any)
	local groupe = SoundService:FindFirstChild(nomGroupe)
	if not (groupe and groupe:IsA("SoundGroup")) then
		return
	end
	local base = groupe:GetAttribute("VolumeBase")
	if type(base) ~= "number" then
		base = groupe.Volume
		groupe:SetAttribute("VolumeBase", base)
	end
	groupe.Volume = base * math.clamp(tonumber(valeur) or 1, 0, 1)
end

local options = {}
for ordre, reglage in REGLAGES do
	local bouton, label = UIKit.bouton(grille, "", UDim2.fromOffset(252, 60), C.NuitLabo, 22)
	bouton.Name = reglage.cle
	bouton.LayoutOrder = ordre
	local option = {
		cle = reglage.cle,
		nom = reglage.nom,
		genre = reglage.genre,
		bouton = bouton,
		label = label,
		attente = false,
		jeton = 0,
	}
	options[ordre] = option
	afficher(option)
	bouton.Activated:Connect(function()
		if option.attente then
			return
		end
		local valeur = suivante(option, UIKit.reglage(option.cle))
		option.attente = true
		option.jeton += 1
		local jeton = option.jeton
		afficher(option)
		UIKit.son("Clic")
		UIKit.envoyer("DemandeReglage", option.cle, valeur)
		task.delay(ATTENTE_MAX, function()
			if option.jeton == jeton and option.attente then
				option.attente = false
				afficher(option)
			end
		end)
	end)
end

local function basculer(visible: boolean)
	panneau.Visible = visible
	if visible then
		UIKit.rebond(panneau)
	end
end

boutonOuvrir.Activated:Connect(function()
	UIKit.son("Clic")
	UIKit.rebond(boutonOuvrir)
	basculer(not panneau.Visible)
end)

boutonFermer.Activated:Connect(function()
	UIKit.son("Clic")
	basculer(false)
end)

------------------------------------------------------------------------------------------
-- Écriture serveur dans Player.Reglages : fin de l'attente, volumes appliqués
------------------------------------------------------------------------------------------

for _, option in options do
	UIKit.surReglage(option.cle, function(valeur: any)
		option.attente = false
		afficher(option)
		if option.cle == "Musique" or option.cle == "Effets" then
			appliquerVolume(option.cle, valeur)
		end
	end)
end
