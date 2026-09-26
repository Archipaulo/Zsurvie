-- Systemes/Boutique : achats Robux strictement cosmétiques (aucun avantage de jeu).
-- Chaque article a un id Roblox. Tant que id == 0, l'article est inactif :
-- remplacer les 0 par les vrais ids créés sur le tableau de bord Créateur
-- (GamePass : page « Passes » de l'expérience ; Produit : « Developer Products »).
local Players = game:GetService("Players")

local M = {}

-- genre = "GamePass" (acheté une fois, vérifié à chaque arrivée) ou "Produit" (achat consommable)
-- attribut / valeur : attribut cosmétique posé sur le joueur quand l'article s'applique
local ARTICLES = {
	{ nom = "Blaster doré", genre = "GamePass", id = 0, attribut = "Cosmetique_Blaster", valeur = "Dore" },
	{ nom = "Traînée arc-en-ciel", genre = "GamePass", id = 0, attribut = "Cosmetique_Trainee", valeur = "ArcEnCiel" },
	{ nom = "Capsule dorée", genre = "Produit", id = 0, attribut = "Cosmetique_Capsule", valeur = "Doree" },
}

-- valeurs par défaut posées à l'arrivée de chaque joueur
local VALEURS_DEFAUT = {
	Cosmetique_Blaster = "Standard",
	Cosmetique_Trainee = "Aucune",
	Cosmetique_Capsule = "Standard",
}

function M.demarrer(ctx)
	local Reseau = ctx.Reseau or {}

	local okService, Marketplace = pcall(function()
		return game:GetService("MarketplaceService")
	end)
	if not okService then
		Marketplace = nil
	end

	-- index des articles actifs (id ~= 0) par genre et par id
	local passesActifs = {}
	local produitsActifs = {}
	for _, article in ipairs(ARTICLES) do
		if type(article.id) == "number" and article.id ~= 0 then
			if article.genre == "GamePass" then
				passesActifs[article.id] = article
			elseif article.genre == "Produit" then
				produitsActifs[article.id] = article
			end
		end
	end

	local function notifier(joueur, texte, genre)
		local ev = Reseau.Notification
		if ev and joueur and joueur.Parent then
			pcall(function()
				ev:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function appliquer(joueur, article)
		if joueur and joueur.Parent and article.attribut then
			joueur:SetAttribute(article.attribut, article.valeur)
		end
	end

	local function possedePass(joueur, idPass)
		if not Marketplace then
			return false
		end
		local ok, resultat = pcall(function()
			return Marketplace:UserOwnsGamePassAsync(joueur.UserId, idPass)
		end)
		return ok and resultat == true
	end

	-- ===== arrivée d'un joueur =====
	local function preparerJoueur(joueur)
		for attribut, valeur in pairs(VALEURS_DEFAUT) do
			if joueur:GetAttribute(attribut) == nil then
				joueur:SetAttribute(attribut, valeur)
			end
		end
		for idPass, article in pairs(passesActifs) do
			if joueur.Parent and possedePass(joueur, idPass) then
				appliquer(joueur, article)
			end
		end
	end

	-- ===== reçus des produits (achats consommables) =====
	-- reçus déjà accordés pendant cette session (évite une double application)
	local recusTraites = {}

	local function traiterRecu(recu)
		if type(recu) ~= "table" then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local article = produitsActifs[recu.ProductId]
		if not article then
			-- produit inconnu : Roblox reproposera le reçu plus tard
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if recu.PurchaseId and recusTraites[recu.PurchaseId] then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		local joueur = Players:GetPlayerByUserId(recu.PlayerId)
		if not joueur then
			-- joueur parti : le reçu sera redonné à sa prochaine venue
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		appliquer(joueur, article)
		if recu.PurchaseId then
			recusTraites[recu.PurchaseId] = true
		end
		notifier(joueur, "Merci ! " .. article.nom .. " activé.", "succes")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	if Marketplace then
		pcall(function()
			Marketplace.ProcessReceipt = traiterRecu
		end)

		-- ===== fin d'un achat de GamePass en jeu =====
		pcall(function()
			Marketplace.PromptGamePassPurchaseFinished:Connect(function(joueur, idPass, achete)
				if achete ~= true or typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
					return
				end
				local article = passesActifs[idPass]
				if article then
					appliquer(joueur, article)
					notifier(joueur, "Merci ! " .. article.nom .. " activé.", "succes")
				end
			end)
		end)
	end

	-- ===== joueurs présents et à venir =====
	Players.PlayerAdded:Connect(function(joueur)
		preparerJoueur(joueur)
	end)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(preparerJoueur, joueur)
	end
end

return M
