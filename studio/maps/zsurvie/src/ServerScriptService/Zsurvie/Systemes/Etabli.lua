-- Système Etabli : achat des améliorations de run (pièces), niveaux Niv_<nom> sur les joueurs.
local Players = game:GetService("Players")

local M = {}

local INTERVALLE_LIMITEUR = 0.15 -- secondes minimum entre deux demandes d'un même joueur

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Plan = ctx.Plan

	local derniereDemande = {}

	-- position de l'effet : au-dessus de la Maison
	local positionMaison = Vector3.new(0, 14, 0)
	if Plan and Plan.maison and Plan.maison.centre then
		local hauteur = 14
		if Plan.maison.taille then hauteur = Plan.maison.taille.Y end
		positionMaison = Plan.maison.centre + Vector3.new(0, hauteur, 0)
	end

	local function notifier(joueur, texte, genre)
		local ev = Reseau and Reseau.Notification
		if ev and joueur and joueur.Parent then
			pcall(function()
				ev:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function effet(nom)
		local ev = Reseau and Reseau.Effet
		if ev then
			pcall(function()
				ev:FireAllClients("Amelioration", positionMaison, { nom = nom })
			end)
		end
	end

	local function niveauDe(joueur, nom)
		local v = joueur:GetAttribute("Niv_" .. nom)
		if type(v) ~= "number" then return 0 end
		return v
	end

	local function initialiser(joueur)
		if not joueur then return end
		for nom in pairs(E.ameliorations) do
			joueur:SetAttribute("Niv_" .. nom, 0)
		end
	end

	local function joueursEnRun()
		local liste = {}
		for _, j in ipairs(Players:GetPlayers()) do
			if j:GetAttribute("EnRun") == true then
				table.insert(liste, j)
			end
		end
		return liste
	end

	local function limiteurOk(joueur)
		local maintenant = os.clock()
		local dernier = derniereDemande[joueur]
		if dernier and maintenant - dernier < INTERVALLE_LIMITEUR then
			return false
		end
		derniereDemande[joueur] = maintenant
		return true
	end

	local function acheter(joueur, nom)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		if not limiteurOk(joueur) then return end
		if type(nom) ~= "string" or #nom > 64 then return end
		local def = E.ameliorations[nom]
		if not def then return end
		if joueur:GetAttribute("EnRun") ~= true then return end

		-- niveau de référence : celui de l'acheteur, ou le plus haut de l'équipe si partagé
		local cibles
		local niveau = niveauDe(joueur, nom)
		if def.equipe then
			cibles = joueursEnRun()
			for _, j in ipairs(cibles) do
				local n = niveauDe(j, nom)
				if n > niveau then niveau = n end
			end
		else
			cibles = { joueur }
		end

		if niveau >= def.max then
			notifier(joueur, "Niveau max", "alerte")
			return
		end

		local cout = E.coutAmelioration(nom, niveau)
		if Bus.demander("DepenserPieces", joueur, cout) ~= true then
			notifier(joueur, "Pas assez de pièces", "alerte")
			return
		end

		local nouveau = niveau + 1
		local acheteurInclus = false
		for _, j in ipairs(cibles) do
			if j.Parent then
				j:SetAttribute("Niv_" .. nom, nouveau)
			end
			if j == joueur then acheteurInclus = true end
		end
		if not acheteurInclus then
			joueur:SetAttribute("Niv_" .. nom, nouveau)
		end

		Bus.emettre("AmeliorationAchetee", joueur, nom, nouveau)
		effet(nom)
		local texte = nom .. " niveau " .. nouveau
		if def.equipe then texte = texte .. " (toute l'équipe)" end
		notifier(joueur, texte, "succes")
	end

	-- joueurs présents et à venir
	for _, j in ipairs(Players:GetPlayers()) do
		initialiser(j)
	end
	Players.PlayerAdded:Connect(initialiser)
	Players.PlayerRemoving:Connect(function(joueur)
		derniereDemande[joueur] = nil
	end)

	-- remise à zéro au début de chaque run
	Bus.ecouter("RunDebut", function(joueurs)
		if type(joueurs) ~= "table" then return end
		for _, j in ipairs(joueurs) do
			if typeof(j) == "Instance" and j:IsA("Player") then
				initialiser(j)
			end
		end
	end)

	local ev = Reseau and Reseau.Acheter
	if ev then
		ev.OnServerEvent:Connect(function(joueur, nom)
			local ok, err = pcall(acheter, joueur, nom)
			if not ok then
				warn("[Zsurvie] Etabli : " .. tostring(err))
			end
		end)
	else
		warn("[Zsurvie] Etabli : RemoteEvent « Acheter » introuvable")
	end
end

return M
