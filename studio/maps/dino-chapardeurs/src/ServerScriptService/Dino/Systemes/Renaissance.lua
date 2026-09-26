-- Système Renaissance : échange une grosse somme contre un multiplicateur de revenu permanent.
-- La Base du joueur est vidée (Enclos écoute « Renaissance ») et son argent repart de zéro.
local Players = game:GetService("Players")

local M = {}

local INTERVALLE = 1        -- secondes minimum entre deux demandes d'un même joueur
local ATTENTE_DONNEES = 15  -- secondes max d'attente du chargement des données

-- nombre fini (ni NaN, ni infini)
local function estFini(n)
	return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

-- 1.5 -> "1,5" ; 2 -> "2"
local function formaterMultiplicateur(x)
	local texte = string.format("%.2f", x)
	texte = string.gsub(texte, "0+$", "")
	texte = string.gsub(texte, "%.$", "")
	texte = string.gsub(texte, "%.", ",")
	return texte
end

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local E = ctx.Equilibrage
	local Plan = ctx.Plan
	local Charte = ctx.Charte
	local Reseau = ctx.Reseau

	local MAX = 10
	if estFini(E.renaissanceMax) and E.renaissanceMax >= 0 then
		MAX = math.floor(E.renaissanceMax)
	end
	local ARGENT_DEPART = 100
	if estFini(E.argentDepart) and E.argentDepart >= 0 then
		ARGENT_DEPART = math.floor(E.argentDepart + 0.5)
	end

	local derniereDemande = {} -- [joueur] = os.clock() de la dernière demande
	local enCours = {}         -- [joueur] = true pendant le traitement

	local function estJoueur(joueur)
		return typeof(joueur) == "Instance" and joueur:IsA("Player") and joueur.Parent == Players
	end

	local function montant(n)
		local ok, texte = pcall(Charte.argent, n)
		if ok and type(texte) == "string" then
			return texte
		end
		return tostring(math.floor(n))
	end

	local function notifier(joueur, texte, genre)
		pcall(function()
			Reseau.Notification:FireClient(joueur, texte, genre)
		end)
	end

	local function niveauDe(joueur)
		local n = joueur:GetAttribute("Renaissances")
		if not estFini(n) or n < 0 then
			return 0
		end
		return math.floor(n)
	end

	local function coutDe(niveau)
		if type(E.coutRenaissance) ~= "function" then
			return nil
		end
		local ok, cout = pcall(E.coutRenaissance, niveau)
		if ok and estFini(cout) and cout >= 0 then
			return math.ceil(cout)
		end
		return nil
	end

	local function multiplicateurDe(niveau)
		if type(E.multiplicateurRenaissance) == "function" then
			local ok, x = pcall(E.multiplicateurRenaissance, niveau)
			if ok and estFini(x) and x > 0 then
				return x
			end
		end
		return 1
	end

	local function porteUnDino(joueur)
		local porte = joueur:GetAttribute("Porte")
		return type(porte) == "string" and porte ~= ""
	end

	-- lit l'argent sans jamais échouer
	local function argentDe(joueur)
		local a = joueur:GetAttribute("Argent")
		if not estFini(a) or a < 0 then
			return 0
		end
		return a
	end

	local function effectuer(joueur)
		if joueur:GetAttribute("DonneesChargees") ~= true then
			notifier(joueur, "Tes données chargent encore, réessaie dans un instant.", "alerte")
			return
		end
		local niveau = niveauDe(joueur)
		if niveau >= MAX then
			notifier(joueur, "Tu as atteint la renaissance maximale (" .. MAX .. ") !", "info")
			return
		end
		if porteUnDino(joueur) then
			notifier(joueur, "Pose d'abord le dino que tu portes !", "alerte")
			return
		end
		local cout = coutDe(niveau)
		if not cout then
			notifier(joueur, "Renaissance indisponible pour le moment.", "alerte")
			return
		end
		local argent = argentDe(joueur)
		if argent < cout then
			notifier(joueur, "Il te manque " .. montant(cout - argent) .. " $ pour renaître.", "alerte")
			return
		end

		-- validation faite : on applique
		local nouveau = niveau + 1
		local ok = pcall(function()
			joueur:SetAttribute("Renaissances", nouveau)
			joueur:SetAttribute("Argent", ARGENT_DEPART)
		end)
		if not ok then
			notifier(joueur, "La renaissance a échoué, réessaie.", "alerte")
			return
		end

		Bus.emettre("Renaissance", joueur, nouveau)

		local texte = "Renaissance " .. nouveau .. " ! Revenus x" .. formaterMultiplicateur(multiplicateurDe(nouveau))
		notifier(joueur, texte, "succes")

		local position = Vector3.new(0, 0, 0)
		if Plan.autel and typeof(Plan.autel.centre) == "Vector3" then
			position = Plan.autel.centre
		end
		pcall(function()
			Reseau.Effet:FireAllClients("Renaissance", position, { niveau = nouveau })
		end)
	end

	-- ===== demande du client =====
	Reseau.Renaissance.OnServerEvent:Connect(function(joueur)
		if not estJoueur(joueur) then
			return
		end
		-- anti-spam local, puis Securite si présente (nil = pas de répondeur)
		local maintenant = os.clock()
		local derniere = derniereDemande[joueur]
		if derniere and maintenant - derniere < INTERVALLE then
			return
		end
		derniereDemande[joueur] = maintenant
		local autorise = Bus.demander("AutoriserAction", joueur, "Renaissance", INTERVALLE)
		if autorise == false then
			return
		end
		if enCours[joueur] then
			return
		end
		enCours[joueur] = true
		local ok = pcall(effectuer, joueur)
		enCours[joueur] = nil
		if not ok then
			notifier(joueur, "La renaissance a échoué, réessaie.", "alerte")
		end
	end)

	-- ===== joueurs =====
	-- garantit l'attribut Renaissances une fois les données chargées
	local function preparer(joueur)
		local debut = os.clock()
		while joueur.Parent == Players and joueur:GetAttribute("DonneesChargees") ~= true do
			if os.clock() - debut >= ATTENTE_DONNEES then
				break
			end
			task.wait(0.25)
		end
		if joueur.Parent ~= Players then
			return
		end
		local n = joueur:GetAttribute("Renaissances")
		if not estFini(n) or n < 0 then
			pcall(function()
				joueur:SetAttribute("Renaissances", 0)
			end)
		elseif n > MAX or n ~= math.floor(n) then
			pcall(function()
				joueur:SetAttribute("Renaissances", math.min(MAX, math.floor(n)))
			end)
		end
	end

	Players.PlayerAdded:Connect(function(joueur)
		preparer(joueur)
	end)
	Players.PlayerRemoving:Connect(function(joueur)
		derniereDemande[joueur] = nil
		enCours[joueur] = nil
	end)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(preparer, joueur)
	end
end

return M
