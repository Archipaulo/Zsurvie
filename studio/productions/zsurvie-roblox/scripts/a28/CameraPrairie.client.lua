-- Emplacement Roblox : StarterPlayer > StarterPlayerScripts > CameraPrairie (LocalScript)
-- Zsurvie · a28 Fanny Roux-Vidal · Caméra de la Prairie (canon §8) : Scriptable, décalée de
-- (0, 45, 28) au-dessus du Survivant, FieldOfView 50, suivi lissé.
-- Les déplacements restent relatifs à la caméra (ControlModule par défaut) : haut du stick = vers -Z.
-- Secousses : ce script n'en calcule plus. Il les demande à UIKit.secouer → VfxClient.secouer (a37),
-- plafond 0,8 stud, coupé par le réglage Secousses. VfxClient applique son décalage APRÈS cette caméra
-- (BindToRenderStep à RenderPriority.Camera + 2) : la caméra repart d'une position propre à chaque frame.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local dossierClient = ReplicatedStorage:WaitForChild("Client", 10)
local moduleUIKit = dossierClient and dossierClient:WaitForChild("UIKit", 10)
if not moduleUIKit then
	warn("[a28 CameraPrairie] ReplicatedStorage.Client.UIKit introuvable après 10 s")
	return
end
local UIKit = require(moduleUIKit)
if not UIKit.surLaPrairie() then
	return
end

local DECALAGE = Vector3.new(0, 45, 28) -- canon §8
local CHAMP = 50 -- FieldOfView, canon §8
local RAIDEUR = 10 -- lissage exponentiel du suivi

local joueur = Players.LocalPlayer
local focus: Vector3? = nil

RunService:BindToRenderStep("CameraPrairie", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end
	if camera.FieldOfView ~= CHAMP then
		camera.FieldOfView = CHAMP
	end
	local racine = UIKit.racineLocale()
	if not racine then
		return
	end
	local cible = racine.Position
	if not focus or (focus - cible).Magnitude > 60 then
		focus = cible -- apparition ou téléportation : pas de travelling
	else
		focus = focus:Lerp(cible, 1 - math.exp(-RAIDEUR * dt))
	end
	camera.CFrame = CFrame.lookAt(focus + DECALAGE, focus)
end)

-- Résolution anticipée (réglages du joueur, module de a37) : aucune attente au premier choc.
task.spawn(UIKit.reglages)
task.spawn(UIKit.module, "VfxClient", true)

-- Déclencheurs de secousse, tous lus dans l'état serveur.
UIKit.ecouter("Annonce", function(cle: string)
	if cle == "Colosse" then
		UIKit.secouer(0.8)
	end
end)

joueur:GetAttributeChangedSignal("EtourdiJusqua"):Connect(function()
	if UIKit.estEtourdi(joueur) then
		UIKit.secouer(0.6)
	end
end)

local etatRun = UIKit.etatRun()
if etatRun then
	local derniersPV = tonumber(etatRun:GetAttribute("MaisonPV"))
	etatRun:GetAttributeChangedSignal("MaisonPV"):Connect(function()
		local pv = tonumber(etatRun:GetAttribute("MaisonPV")) or 0
		local pvMax = math.max(1, tonumber(etatRun:GetAttribute("MaisonPVMax")) or 1)
		if derniersPV and (derniersPV - pv) / pvMax > 0.05 then
			UIKit.secouer(0.3)
		end
		derniersPV = pv
	end)
end
