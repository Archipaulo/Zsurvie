-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > Effets (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Retours visuels dans le monde : nombres de dégâts (flux Evenements),
-- pièces individuelles au sol (PiecesLachees + expireA), étoiles d'étourdissement, bulles de ping.
-- L'éclatement des Zbires est le Z1 de a37 : plus de remote Impact ni Eclatement, plus de cubes ici.
-- Tout est cosmétique : ramassage et crédit des pièces sont décidés par le serveur (a14), qui écrit
-- l'attribut Pieces puis envoie Butin(id, montant) pour l'animation.
-- Pools fixes, aucune création d'instance pendant le combat, zéro Neon, zéro lumière.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 Effets] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local C = UIKit.Couleurs
local joueur = Players.LocalPlayer
local terrain = Workspace.Terrain
task.spawn(UIKit.reglages) -- EffetsReduits est ensuite lu sans attente

local CACHE = CFrame.new(0, -500, 0)
local TAILLE_PIECE = Vector3.new(1, 1, 0.25)
local CLIGNOTEMENT = 3 -- s avant expireA
local NB_NOMBRES, NB_PIECES, NB_PINGS = 20, 60, 6
local pointMaison = UIKit.point("MAISON")

local INFO_NOMBRE = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INFO_POP = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local INFO_ASPIRE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local INFO_ENVOL = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local dossier = UIKit.creer("Folder", { Name = "EffetsZsurvie", Parent = Workspace.CurrentCamera })

local function creerBloc(nom: string, couleur: Color3, taille: Vector3): BasePart
	return UIKit.creer("Part", {
		Name = nom,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		CFrame = CACHE,
		Color = couleur,
		Material = Enum.Material.SmoothPlastic,
		Size = taille,
		Transparency = 1,
		Parent = dossier,
	})
end

------------------------------------------------------------------------------------------
-- Nombres flottants (dégâts, gains) : pool de 20 BillboardGui
------------------------------------------------------------------------------------------

local nombres = {}
local indexNombre = 0
for i = 1, NB_NOMBRES do
	local ancre = UIKit.creer("Attachment", { Name = "AncreNombre", Parent = terrain })
	local affichage = UIKit.creer("BillboardGui", {
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		Size = UDim2.fromOffset(80, 40),
		Parent = ancre,
	})
	local label = UIKit.etiquette(affichage, "", UDim2.fromScale(1, 1), 30)
	nombres[i] = {
		ancre = ancre,
		affichage = affichage,
		label = label,
		contour = label:FindFirstChildOfClass("UIStroke"),
	}
end

local function afficherNombre(position: Vector3, texte: string, couleur: Color3, gros: boolean)
	indexNombre = indexNombre % NB_NOMBRES + 1
	local n = nombres[indexNombre]
	n.ancre.WorldPosition = position + Vector3.new(math.random() - 0.5, 2, math.random() - 0.5)
	n.affichage.StudsOffset = Vector3.zero
	n.affichage.Size = if gros then UDim2.fromOffset(110, 52) else UDim2.fromOffset(80, 40)
	n.label.Text = texte
	n.label.TextColor3 = couleur
	n.label.TextTransparency = 0
	n.contour.Transparency = 0
	n.affichage.Enabled = true
	TweenService:Create(n.affichage, INFO_NOMBRE, { StudsOffset = Vector3.new(0, 3, 0) }):Play()
	TweenService:Create(n.label, INFO_NOMBRE, { TextTransparency = 1 }):Play()
	TweenService:Create(n.contour, INFO_NOMBRE, { Transparency = 1 }):Play()
end

-- Flux Evenements (UnreliableRemoteEvent, lots par tick serveur) : on ne lit que type = "Degats".
-- { type, position, valeur, critique, auteur (UserId), reduit (coup non critique sur un Casqué) }
local function afficherDegats(e)
	if typeof(e.position) ~= "Vector3" or type(e.valeur) ~= "number" then
		return
	end
	local deMoi = e.auteur == joueur.UserId
	if not deMoi and (e.critique ~= true or UIKit.reglage("EffetsReduits") == true) then
		return -- coéquipiers : seuls leurs critiques s'affichent, la horde reste lisible
	end
	local valeur = tostring(math.max(1, math.floor(e.valeur)))
	if e.critique == true then
		afficherNombre(e.position, valeur .. " !", C.ToitOrange, true)
	elseif e.reduit == true then
		afficherNombre(e.position, valeur, UIKit.lumiere(C.Ardoise), false)
		UIKit.son("Tink", 0.15) -- enseigne la règle du Casqué
	else
		afficherNombre(e.position, valeur, C.Creme, false)
	end
end

UIKit.ecouter("Evenements", function(lot: any)
	if type(lot) ~= "table" then
		return
	end
	for _, evenement in lot do
		if type(evenement) == "table" and evenement.type == "Degats" then
			afficherDegats(evenement)
		end
	end
end)

------------------------------------------------------------------------------------------
-- Pièces au sol : butin individuel, retiré à l'heure expireA fixée par le serveur
------------------------------------------------------------------------------------------

local libres = {}
for i = 1, NB_PIECES do
	libres[i] = creerBloc("Piece", C.Or, TAILLE_PIECE)
end
local pieces = {} -- [id] = { part, base, expireA, phase, etat = "Sol" | "Partie" }
local partsAnimees, cframesAnimees = {}, {}

local function liberer(id: any)
	local piece = pieces[id]
	if not piece then
		return
	end
	pieces[id] = nil
	piece.part.Transparency = 1
	piece.part.CFrame = CACHE
	table.insert(libres, piece.part)
end

-- La pièce quitte le sol : vers le Survivant (Butin) ou vers la Maison (expireA atteint).
local function partir(id: any, piece, cible: Vector3?, info: TweenInfo)
	piece.etat = "Partie"
	piece.part.Transparency = 0
	if not cible then
		liberer(id)
		return
	end
	local tween = TweenService:Create(piece.part, info, { CFrame = CFrame.new(cible), Size = TAILLE_PIECE * 0.3 })
	tween.Completed:Once(function()
		liberer(id)
	end)
	tween:Play()
end

-- PiecesLachees({ { id, position, montant, expireA }, ... }) : envoyé au seul propriétaire.
-- expireA = heure Workspace:GetServerTimeNow() à laquelle le serveur (a14) retire la pièce.
UIKit.ecouter("PiecesLachees", function(liste: any)
	if type(liste) ~= "table" then
		return
	end
	for _, d in liste do
		if
			type(d) == "table"
			and d.id ~= nil
			and typeof(d.position) == "Vector3"
			and type(d.expireA) == "number"
			and not pieces[d.id]
		then
			local part = table.remove(libres)
			if not part then
				break -- pool plein : la pièce existe côté serveur, elle n'est simplement pas dessinée
			end
			part.Transparency = 0
			part.Size = TAILLE_PIECE * 0.2
			part.CFrame = CFrame.new(d.position)
			TweenService:Create(part, INFO_POP, { Size = TAILLE_PIECE }):Play()
			pieces[d.id] = {
				part = part,
				base = d.position + Vector3.new(0, 1, 0),
				expireA = d.expireA,
				phase = math.random() * math.pi * 2,
				etat = "Sol",
			}
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	local serveur = Workspace:GetServerTimeNow()
	local reduits = UIKit.reglage("EffetsReduits") == true
	local eteinte = math.floor(t * 5) % 2 == 1 -- 2,5 clignotements par seconde (sous 3 flashs/s)
	table.clear(partsAnimees)
	table.clear(cframesAnimees)
	for id, piece in pieces do
		if piece.etat == "Sol" then
			if serveur >= piece.expireA then
				-- Heure fixée par le serveur : la pièce file vers la Maison (50 % rendus au Répit).
				partir(id, piece, if pointMaison then pointMaison + Vector3.new(0, 8, 0) else nil, INFO_ENVOL)
			else
				local transparence = if serveur >= piece.expireA - CLIGNOTEMENT and eteinte then 0.7 else 0
				if piece.part.Transparency ~= transparence then
					piece.part.Transparency = transparence
				end
				local hauteur = if reduits then 0 else 0.3 * math.sin(t * 4 + piece.phase)
				local rotation = if reduits then piece.phase else t * 3 + piece.phase
				table.insert(partsAnimees, piece.part)
				table.insert(
					cframesAnimees,
					CFrame.new(piece.base + Vector3.new(0, hauteur, 0)) * CFrame.Angles(0, rotation, 0)
				)
			end
		end
	end
	if #partsAnimees > 0 then
		Workspace:BulkMoveTo(partsAnimees, cframesAnimees, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

-- Butin(id, montant) : envoyé APRÈS que le serveur a crédité l'attribut Pieces.
UIKit.ecouter("Butin", function(id: any, montant: any)
	local racine = UIKit.racineLocale()
	local piece = pieces[id]
	if piece and piece.etat == "Sol" then
		partir(id, piece, if racine then racine.Position else nil, INFO_ASPIRE)
	end
	UIKit.son("Piece", 0.06)
	if racine and type(montant) == "number" and montant > 0 then
		afficherNombre(racine.Position, "+" .. math.floor(montant), C.Or, false)
	end
end)

------------------------------------------------------------------------------------------
-- Étoiles d'étourdissement (visibles par tous : on voit qui aider)
------------------------------------------------------------------------------------------

local etoiles = {} -- [Player] = { panneau, tournoiements, jeton }

local function creerEtoiles(tete: BasePart)
	local panneau = UIKit.creer("BillboardGui", {
		Name = "EtoilesEtourdi",
		Enabled = false,
		LightInfluence = 0,
		Size = UDim2.fromScale(3, 1.2),
		StudsOffset = Vector3.new(0, 1.8, 0),
		Parent = tete,
	})
	local tournoiements = {}
	for i = 1, 3 do
		local hauteur = if i == 2 then 0.3 else 0.65
		local etoile = UIKit.creer("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = C.Creme,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.2 + 0.3 * (i - 1), hauteur),
			Rotation = 45,
			Size = UDim2.fromScale(0.13, 0.33),
			Parent = panneau,
		})
		UIKit.creer("UIStroke", { Color = C.Encre, Thickness = 2, Parent = etoile })
		tournoiements[i] = TweenService:Create(
			etoile,
			TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
			{ Rotation = 405 }
		)
	end
	return { panneau = panneau, tournoiements = tournoiements, jeton = 0 }
end

local function montrerEtoiles(autre: Player)
	local reste = (tonumber(autre:GetAttribute("EtourdiJusqua")) or 0) - Workspace:GetServerTimeNow()
	local personnage = autre.Character
	local tete = personnage and personnage:FindFirstChild("Head")
	if reste <= 0 or not (tete and tete:IsA("BasePart")) then
		return
	end
	local etat = etoiles[autre]
	if not etat or etat.panneau.Parent ~= tete then
		if etat then
			etat.panneau:Destroy()
		end
		etat = creerEtoiles(tete)
		etoiles[autre] = etat
	end
	etat.jeton += 1
	local jeton = etat.jeton
	etat.panneau.Enabled = true
	for _, tween in etat.tournoiements do
		tween:Play()
	end
	task.delay(math.min(reste, 4), function()
		if etat.jeton ~= jeton then
			return
		end
		etat.panneau.Enabled = false
		for _, tween in etat.tournoiements do
			tween:Cancel()
		end
	end)
end

local function surveiller(autre: Player)
	autre:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
		montrerEtoiles(autre)
	end)
end

for _, autre in Players:GetPlayers() do
	surveiller(autre)
end
Players.PlayerAdded:Connect(surveiller)
Players.PlayerRemoving:Connect(function(autre: Player)
	local etat = etoiles[autre]
	if etat then
		etat.panneau:Destroy()
		etoiles[autre] = nil
	end
end)

------------------------------------------------------------------------------------------
-- Bulles de la Roue des Pings : « Léa : Répare ! » pendant 4 s
------------------------------------------------------------------------------------------

local bulles = {}
local indexBulle = 0
for i = 1, NB_PINGS do
	local ancre = UIKit.creer("Attachment", { Name = "AncrePing", Parent = terrain })
	local affichage = UIKit.creer("BillboardGui", {
		AlwaysOnTop = true,
		Enabled = false,
		LightInfluence = 0,
		Size = UDim2.fromOffset(170, 48),
		StudsOffset = Vector3.new(0, 5, 0),
		Parent = ancre,
	})
	local cadre = UIKit.creer("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.Prairie,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Parent = affichage,
	})
	UIKit.habiller(cadre, 8, 3)
	local label = UIKit.etiquette(cadre, "", UDim2.new(1, -12, 1, -8), 24)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	bulles[i] = { ancre = ancre, affichage = affichage, cadre = cadre, label = label, jeton = 0 }
end

-- PingDiffuse(auteur, cle, position) : le serveur a déjà vérifié la clé et la cadence.
UIKit.ecouter("PingDiffuse", function(auteur: any, cle: any, position: any)
	local info = UIKit.PINGS_PAR_CLE[cle]
	if not info or typeof(position) ~= "Vector3" then
		return
	end
	indexBulle = indexBulle % NB_PINGS + 1
	local bulle = bulles[indexBulle]
	local nom = if typeof(auteur) == "Instance" and auteur:IsA("Player") then auteur.DisplayName else "Survivant"
	bulle.ancre.WorldPosition = position
	bulle.cadre.BackgroundColor3 = info.couleur
	bulle.label.Text = nom .. " : " .. info.texte
	bulle.affichage.Enabled = true
	UIKit.rebond(bulle.cadre)
	UIKit.son(if cle == "Colosse" then "Alerte" else "Ping")
	bulle.jeton += 1
	local jeton = bulle.jeton
	task.delay(4, function()
		if bulle.jeton == jeton then
			bulle.affichage.Enabled = false
		end
	end)
end)
