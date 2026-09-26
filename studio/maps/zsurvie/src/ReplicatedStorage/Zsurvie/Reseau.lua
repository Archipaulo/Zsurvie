-- Les RemoteEvents du jeu, rangés dans ReplicatedStorage.ZsurvieReseau.
-- Client -> serveur : Tirer(position: Vector3, idZbire: string?), Acheter(nom), Rechercher(nom), Reparer(), Ping(texte)
-- Serveur -> client : Effet(genre, position, donnees), Notification(texte, genre)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reseau = {}
Reseau.NOMS = { "Tirer", "Acheter", "Rechercher", "Reparer", "Ping", "Effet", "Notification" }

function Reseau.serveur()
	local dossier = ReplicatedStorage:FindFirstChild("ZsurvieReseau")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "ZsurvieReseau"
		dossier.Parent = ReplicatedStorage
	end
	local r = {}
	for _, nom in ipairs(Reseau.NOMS) do
		local ev = dossier:FindFirstChild(nom)
		if not ev then
			ev = Instance.new("RemoteEvent")
			ev.Name = nom
			ev.Parent = dossier
		end
		r[nom] = ev
	end
	return r
end

function Reseau.client()
	local dossier = ReplicatedStorage:WaitForChild("ZsurvieReseau")
	local r = {}
	for _, nom in ipairs(Reseau.NOMS) do
		r[nom] = dossier:WaitForChild(nom)
	end
	return r
end

return Reseau
