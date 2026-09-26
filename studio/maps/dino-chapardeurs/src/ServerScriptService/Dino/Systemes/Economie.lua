-- Système Economie : attribut Argent des joueurs, gains, dépenses et multiplicateur de revenu.
local Players = game:GetService("Players")

local M = {}

local ATTENTE_DONNEES = 10 -- secondes max d'attente du chargement des données
local ARGENT_MAX = 1e300   -- garde-fou contre l'infini

-- nombre fini (ni NaN, ni infini)
local function estFini(n)
	return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

local function arrondir(n)
	return math.floor(n + 0.5)
end

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local E = ctx.Equilibrage

	local ARGENT_DEPART = 100
	if estFini(E.argentDepart) and E.argentDepart >= 0 then
		ARGENT_DEPART = arrondir(E.argentDepart)
	end

	local surveilles = {} -- [joueur] = connexion de surveillance de l'attribut Argent

	local function estJoueur(joueur)
		return typeof(joueur) == "Instance" and joueur:IsA("Player") and joueur.Parent == Players
	end

	-- lit l'argent actuel, toujours un nombre fini et positif
	local function lireArgent(joueur)
		local ok, valeur = pcall(function()
			return joueur:GetAttribute("Argent")
		end)
		if not ok or not estFini(valeur) or valeur < 0 then
			return 0
		end
		return valeur
	end

	local function ecrireArgent(joueur, valeur)
		if not estFini(valeur) or valeur < 0 then
			valeur = 0
		end
		if valeur > ARGENT_MAX then
			valeur = ARGENT_MAX
		end
		valeur = arrondir(valeur)
		pcall(function()
			joueur:SetAttribute("Argent", valeur)
		end)
		return valeur
	end

	-- corrige toute valeur invalide posée par ailleurs (NaN, négative, non numérique)
	local function assainir(joueur)
		local valeur = joueur:GetAttribute("Argent")
		if valeur == nil then
			return
		end
		if not estFini(valeur) or valeur < 0 or valeur > ARGENT_MAX then
			ecrireArgent(joueur, lireArgent(joueur))
		end
	end

	local function preparer(joueur)
		if surveilles[joueur] then
			return
		end
		local ok, connexion = pcall(function()
			return joueur:GetAttributeChangedSignal("Argent"):Connect(function()
				assainir(joueur)
			end)
		end)
		if ok then
			surveilles[joueur] = connexion
		else
			surveilles[joueur] = true
		end

		-- attend le chargement des données (au plus ATTENTE_DONNEES secondes)
		local debut = os.clock()
		while joueur.Parent == Players and joueur:GetAttribute("DonneesChargees") ~= true do
			if os.clock() - debut >= ATTENTE_DONNEES then
				break
			end
			task.wait(0.2)
		end
		if joueur.Parent ~= Players then
			return
		end
		if joueur:GetAttribute("Argent") == nil then
			ecrireArgent(joueur, ARGENT_DEPART)
		else
			assainir(joueur)
		end
	end

	local function oublier(joueur)
		local connexion = surveilles[joueur]
		if connexion and connexion ~= true then
			pcall(function()
				connexion:Disconnect()
			end)
		end
		surveilles[joueur] = nil
	end

	-- ===== répondeurs =====
	Bus.repondre("AjouterArgent", function(joueur, n, source)
		if not estJoueur(joueur) then
			return nil
		end
		if not estFini(n) or n <= 0 then
			return lireArgent(joueur)
		end
		local gain = arrondir(n)
		if gain <= 0 then
			return lireArgent(joueur)
		end
		local avant = lireArgent(joueur)
		local total = ecrireArgent(joueur, avant + gain)
		local reel = total - avant
		if reel > 0 then
			if type(source) ~= "string" then
				source = "Inconnue"
			end
			Bus.emettre("ArgentGagne", joueur, reel, source)
		end
		return total
	end)

	Bus.repondre("DepenserArgent", function(joueur, n)
		if not estJoueur(joueur) then
			return false
		end
		if not estFini(n) or n < 0 then
			return false
		end
		local cout = math.ceil(n)
		local argent = lireArgent(joueur)
		if argent < cout then
			return false
		end
		if cout > 0 then
			ecrireArgent(joueur, argent - cout)
		end
		return true
	end)

	Bus.repondre("MultiplicateurRevenu", function(joueur)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
			return 1
		end
		local renaissances = joueur:GetAttribute("Renaissances")
		if not estFini(renaissances) or renaissances < 0 then
			renaissances = 0
		end
		local bonus = joueur:GetAttribute("BonusIndex")
		if not estFini(bonus) or bonus < 0 then
			bonus = 0
		end
		local base = 1
		if type(E.multiplicateurRenaissance) == "function" then
			local ok, valeur = pcall(E.multiplicateurRenaissance, renaissances)
			if ok and estFini(valeur) and valeur > 0 then
				base = valeur
			end
		end
		local resultat = base * (1 + bonus)
		if not estFini(resultat) or resultat <= 0 then
			return 1
		end
		return resultat
	end)

	-- ===== joueurs =====
	Players.PlayerAdded:Connect(function(joueur)
		preparer(joueur)
	end)
	Players.PlayerRemoving:Connect(oublier)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(preparer, joueur)
	end
end

return M
