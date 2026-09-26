-- Système Jour : seul maître de Phase, Jour, TempsRestant, PVMaison et PVMaisonMax.
-- Enchaîne Horde -> Répit -> jour suivant, gère la défaite et le retour au lobby.
local Players = game:GetService("Players")

local M = {}

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Etat = ctx.Etat
	local Reseau = ctx.Reseau

	-- jeton de run : toute boucle ou attente dont le jeton ne correspond plus s'arrête
	local jeton = 0

	-- ===== utilitaires =====
	local function nombre(nom, defaut)
		local v = Etat:GetAttribute(nom)
		if type(v) ~= "number" then return defaut end
		return v
	end

	local function phase()
		local p = Etat:GetAttribute("Phase")
		if type(p) ~= "string" then return "Lobby" end
		return p
	end

	local function notifierTous(texte, genre)
		local ev = Reseau and Reseau.Notification
		if ev then
			pcall(function() ev:FireAllClients(texte, genre) end)
		end
	end

	local function notifier(joueur, texte, genre)
		local ev = Reseau and Reseau.Notification
		if ev then
			pcall(function() ev:FireClient(joueur, texte, genre) end)
		end
	end

	local function effetTous(genre, position, donnees)
		local ev = Reseau and Reseau.Effet
		if ev then
			pcall(function() ev:FireAllClients(genre, position, donnees) end)
		end
	end

	local function estEnRun(joueur)
		return joueur and joueur.Parent == Players and joueur:GetAttribute("EnRun") == true
	end

	local function joueursEnRun(exclu)
		local liste = {}
		for _, joueur in ipairs(Players:GetPlayers()) do
			if joueur ~= exclu and estEnRun(joueur) then
				table.insert(liste, joueur)
			end
		end
		return liste
	end

	local function pvBase()
		return E.maison.pv
	end

	local function fixerPV(valeur)
		local max = nombre("PVMaisonMax", pvBase())
		if valeur > max then valeur = max end
		if valeur < 0 then valeur = 0 end
		Etat:SetAttribute("PVMaison", valeur)
	end

	local function positionMaison()
		if Plan.maison and Plan.maison.centre then
			return Plan.maison.centre
		end
		return Vector3.new(0, 0, 0)
	end

	-- ===== retour au lobby =====
	local function retourLobby(nettoyer)
		jeton = jeton + 1
		if nettoyer then
			Bus.emettre("NettoyerHorde")
		end
		local cible = CFrame.new(Plan.lobby.spawn + Vector3.new(0, 4, 0))
		for _, joueur in ipairs(Players:GetPlayers()) do
			if joueur:GetAttribute("EnRun") == true then
				local personnage = joueur.Character
				if personnage then
					pcall(function() personnage:PivotTo(cible) end)
				end
				joueur:SetAttribute("EnRun", false)
			end
		end
		Etat:SetAttribute("Phase", "Lobby")
		Etat:SetAttribute("Jour", 0)
		Etat:SetAttribute("TempsRestant", 0)
		Etat:SetAttribute("PVMaisonMax", pvBase())
		Etat:SetAttribute("PVMaison", pvBase())
		Bus.emettre("RetourLobby")
	end

	-- ===== enchaînement des phases =====
	local function debutJour(jour)
		Etat:SetAttribute("Jour", jour)
		Etat:SetAttribute("Phase", "Horde")
		Etat:SetAttribute("TempsRestant", E.jour.dureeHorde)
		Bus.emettre("JourDebut", jour)
		notifierTous("Jour " .. tostring(jour), "succes")
		effetTous("JourDebut", positionMaison(), { jour = jour })
	end

	local function finJour()
		if phase() ~= "Horde" then return end
		local jour = nombre("Jour", 1)
		Etat:SetAttribute("Phase", "Repit")
		Etat:SetAttribute("TempsRestant", E.jour.dureeRepit)
		Bus.emettre("RepitDebut", jour)
		notifierTous("Jour " .. tostring(jour) .. " survécu ! Répit de " .. tostring(E.jour.dureeRepit) .. " s", "info")
	end

	local function regeneration()
		local niveauMax = 0
		for _, joueur in ipairs(joueursEnRun(nil)) do
			local niv = joueur:GetAttribute("Niv_Regeneration")
			if type(niv) == "number" and niv > niveauMax then
				niveauMax = niv
			end
		end
		if niveauMax > 0 then
			local effet = E.ameliorations.Regeneration.effet
			local pv = nombre("PVMaison", 0)
			local max = nombre("PVMaisonMax", pvBase())
			if pv > 0 and pv < max then
				fixerPV(pv + niveauMax * effet)
			end
		end
	end

	local function boucle(monJeton)
		while jeton == monJeton do
			task.wait(1)
			if jeton ~= monJeton then break end
			local p = phase()
			if p == "Horde" or p == "Repit" then
				regeneration()
				local t = nombre("TempsRestant", 0) - 1
				if t < 0 then t = 0 end
				Etat:SetAttribute("TempsRestant", t)
				if t <= 0 then
					if p == "Horde" then
						Bus.emettre("NettoyerHorde")
						if jeton == monJeton then finJour() end
					else
						if jeton == monJeton then debutJour(nombre("Jour", 0) + 1) end
					end
				end
			end
		end
	end

	-- ===== défaite =====
	local function defaite()
		jeton = jeton + 1
		local monJeton = jeton
		local jour = nombre("Jour", 1)
		Etat:SetAttribute("Phase", "Defaite")
		Etat:SetAttribute("TempsRestant", 0)
		Bus.emettre("MaisonTombee", jour)
		local gemmes = E.gemmesFinDeRun(jour)
		for _, joueur in ipairs(joueursEnRun(nil)) do
			Bus.demander("AjouterGemmes", joueur, gemmes, "FinDeRun")
			notifier(joueur, "La Maison est tombée au jour " .. tostring(jour) .. " : +" .. tostring(gemmes) .. " gemmes", "alerte")
		end
		task.delay(5, function()
			if jeton == monJeton then
				retourLobby(true)
			end
		end)
	end

	-- ===== écoutes du Bus =====
	Bus.ecouter("RunDebut", function(joueurs)
		if phase() ~= "Lobby" then return end
		jeton = jeton + 1
		local monJeton = jeton
		Etat:SetAttribute("PVMaisonMax", pvBase())
		Etat:SetAttribute("PVMaison", pvBase())
		debutJour(1)
		task.spawn(boucle, monJeton)
	end)

	Bus.ecouter("HordeTerminee", function(jour)
		if phase() ~= "Horde" then return end
		if type(jour) == "number" and jour ~= nombre("Jour", 0) then return end
		finJour()
	end)

	Bus.ecouter("DegatsMaison", function(montant)
		if type(montant) ~= "number" or montant ~= montant or montant <= 0 then return end
		local p = phase()
		if p ~= "Horde" and p ~= "Repit" then return end
		local pv = nombre("PVMaison", 0) - montant
		if pv <= 0 then
			Etat:SetAttribute("PVMaison", 0)
			defaite()
		else
			fixerPV(pv)
		end
	end)

	Bus.ecouter("SoinMaison", function(montant)
		if type(montant) ~= "number" or montant ~= montant or montant <= 0 then return end
		local p = phase()
		if p == "Defaite" then return end
		local max = nombre("PVMaisonMax", pvBase())
		fixerPV(math.min(max, nombre("PVMaison", 0) + montant))
	end)

	Bus.ecouter("AmeliorationAchetee", function(joueur, nom, niveau)
		if nom ~= "Solidite" or type(niveau) ~= "number" then return end
		local p = phase()
		if p ~= "Horde" and p ~= "Repit" then return end
		local ancienMax = nombre("PVMaisonMax", pvBase())
		local nouveauMax = pvBase() * (1 + niveau * E.ameliorations.Solidite.effet)
		if nouveauMax <= ancienMax then return end
		Etat:SetAttribute("PVMaisonMax", nouveauMax)
		fixerPV(nombre("PVMaison", 0) + (nouveauMax - ancienMax))
	end)

	-- ===== départ des joueurs =====
	Players.PlayerRemoving:Connect(function(joueur)
		if phase() == "Lobby" then return end
		if #joueursEnRun(joueur) == 0 then
			retourLobby(true)
		end
	end)
end

return M
