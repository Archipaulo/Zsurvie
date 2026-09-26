-- Les RemoteEvents du jeu, rangés dans ReplicatedStorage.DinoReseau.
-- Client -> serveur : Acheter(nomObjet), Renaissance(), Frapper(), Collecter()
-- Serveur -> client : Effet(genre, position, donnees), Notification(texte, genre)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reseau = {}
Reseau.NOMS = { "Acheter", "Renaissance", "Frapper", "Collecter", "Effet", "Notification" }

function Reseau.serveur()
	local dossier = ReplicatedStorage:FindFirstChild("DinoReseau")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "DinoReseau"
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
	local dossier = ReplicatedStorage:WaitForChild("DinoReseau")
	local r = {}
	for _, nom in ipairs(Reseau.NOMS) do
		r[nom] = dossier:WaitForChild(nom)
	end
	return r
end

return Reseau
