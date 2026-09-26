-- ReplicatedStorage/Partage/Reseau (ModuleScript)
-- RemoteEvents de la place Prairie. Le serveur les crée dans ReplicatedStorage.Remotes, le client les attend.
-- Règle du studio : le client n'envoie que des DEMANDES. Côté serveur, chaque Demande* est branchée
-- UNIQUEMENT par Validation.brancher (aucun OnServerEvent brut). Les événements visuels (impacts,
-- éclatements, ondes...) passent par le flux Evenements, pas par ce module.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DEFINITIONS = {
	-- a26
	EtatZbires = "UnreliableRemoteEvent", -- serveur -> clients : 9 octets par Zbire à 10 Hz (buffer, 549 octets au plus)
	DemandeTir = "RemoteEvent", -- client -> serveur : identifiant du Zbire visé
	DemandeDeblocage = "RemoteEvent", -- client -> serveur : bouton Réinitialiser, 1 toutes les 10 s
	-- Noms réservés pour les autres services de la run
	DemandeReparation = "RemoteEvent",
	DemandeAchat = "RemoteEvent",
	DemandePose = "RemoteEvent",
	DemandePing = "RemoteEvent",
}

local Reseau = {}

if RunService:IsServer() then
	local dossier = ReplicatedStorage:FindFirstChild("Remotes")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Remotes"
		dossier.Parent = ReplicatedStorage
	end
	for nom, classe in DEFINITIONS do
		local remote = dossier:FindFirstChild(nom)
		if not remote then
			remote = Instance.new(classe)
			remote.Name = nom
			remote.Parent = dossier
		end
		Reseau[nom] = remote
	end
else
	local dossier = ReplicatedStorage:WaitForChild("Remotes")
	for nom in DEFINITIONS do
		Reseau[nom] = dossier:WaitForChild(nom)
	end
end

return Reseau
