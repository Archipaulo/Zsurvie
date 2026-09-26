-- Système Vol : invite « Voler » sur les dinos des Bases, transport sur la tête du voleur, livraison ou retour chez la victime.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local E = ctx.Equilibrage
	local Reseau = ctx.Reseau

	local REGLES = E.vol or {}
	local VITESSE_VOLEUR = REGLES.vitesseVoleur or 11
	local DELAI_MAX = REGLES.delaiMax or 60
	local HAUTEUR_TETE = 2        -- studs au-dessus du haut de la tête
	local MARGE_DISTANCE = 6      -- tolérance au-delà de la portée de l'invite

	local vols = {}      -- [dino] = { dino, voleur, victime, ... } : vols en cours
	local enCours = {}   -- [dino] = true pendant le traitement d'une invite

	-- ===== utilitaires =====
	local function notifier(joueur, texte, genre)
		if joueur and joueur.Parent then
			pcall(function()
				Reseau.Notification:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function effet(genre, position, donnees)
		pcall(function()
			Reseau.Effet:FireAllClients(genre, position, donnees)
		end)
	end

	local function dinoDe(inst)
		local courant = inst
		while courant and courant.Parent do
			if courant.Parent == ctx.dinos then
				if courant:IsA("Model") then return courant end
				return nil
			end
			courant = courant.Parent
		end
		return nil
	end

	local function vivant(dino)
		return dino ~= nil and dino.Parent == ctx.dinos
	end

	local function pivotDe(dino)
		local ok, cf = pcall(function() return dino:GetPivot() end)
		if ok then return cf end
		return nil
	end

	local function positionDe(dino)
		local cf = pivotDe(dino)
		if cf then return cf.Position end
		return Vector3.new(0, 0, 0)
	end

	local function nomEspece(dino)
		local espece = dino:GetAttribute("Espece")
		local fiche = E.especes and E.especes[espece]
		if fiche and fiche.nom then return fiche.nom end
		return tostring(espece or "dino")
	end

	local function nomJoueur(joueur)
		if joueur then
			local ok, nom = pcall(function() return joueur.DisplayName end)
			if ok and type(nom) == "string" and nom ~= "" then return nom end
			return joueur.Name
		end
		return "Quelqu'un"
	end

	local function joueurPresent(joueur)
		return joueur ~= nil and joueur.Parent == Players
	end

	-- personnage vivant d'un joueur : perso, humanoid, racine, tête
	local function corpsDe(joueur)
		local perso = joueur and joueur.Character
		if not perso or not perso.Parent then return nil end
		local humanoid = perso:FindFirstChildOfClass("Humanoid")
		local racine = perso:FindFirstChild("HumanoidRootPart")
		if not humanoid or not racine or humanoid.Health <= 0 then return nil end
		return perso, humanoid, racine, perso:FindFirstChild("Head")
	end

	local function retirerInvites(dino)
		for _, d in ipairs(dino:GetDescendants()) do
			if d:IsA("ProximityPrompt") and (d.Name == "Voler" or d.Name == "Vendre") then
				pcall(function() d:Destroy() end)
			end
		end
	end

	local function porteQuelqueChose(joueur)
		local porte = joueur:GetAttribute("Porte")
		return porte ~= nil and porte ~= ""
	end

	-- rétablit la vitesse et l'attribut Porte du voleur (toujours appelé à la fin d'un vol)
	local function retablirVoleur(v)
		if v.humanoid and v.humanoid.Parent then
			pcall(function() v.humanoid.WalkSpeed = v.ancienneVitesse end)
		end
		if v.voleur then
			pcall(function() v.voleur:SetAttribute("Porte", "") end)
		end
	end

	-- ===== fin d'un vol =====
	local function terminer(v)
		if v.fini then return false end
		v.fini = true
		vols[v.dino] = nil
		retablirVoleur(v)
		return true
	end

	-- le dino rentre chez sa victime (ou disparaît si elle est partie)
	local function echouer(v, raison)
		if not terminer(v) then return end
		local dino = v.dino
		local position = positionDe(dino)

		if joueurPresent(v.voleur) then
			Bus.demander("LibererEmplacement", v.voleur, v.numero)
		end

		if vivant(dino) then
			pcall(function() dino:SetAttribute("Voleur", 0) end)
			if joueurPresent(v.victime) then
				local place = Bus.demander("PlacerDino", dino, v.victime, v.ancienEmplacement)
				if place ~= true and vivant(dino) then
					-- pose impossible : on remet le dino sur son podium tel quel
					local cf = Bus.demander("CFrameEmplacement", v.ancienneBase, v.ancienEmplacement)
					if typeof(cf) == "CFrame" then
						pcall(function() dino:PivotTo(cf) end)
					end
					pcall(function() dino:SetAttribute("Etat", "Enclos") end)
				end
			else
				pcall(function() dino:Destroy() end)
			end
		end

		Bus.emettre("VolRate", dino, v.voleur, v.victime, raison)
		effet("VolRate", position, { raison = raison })

		if raison == "frappe" then
			notifier(v.voleur, "Assommé ! Le " .. v.nom .. " t'a échappé.", "alerte")
		elseif raison == "delai" then
			notifier(v.voleur, "Trop lent ! Le " .. v.nom .. " rentre chez lui.", "alerte")
		elseif raison ~= "depart" then
			notifier(v.voleur, "Vol raté : le " .. v.nom .. " rentre chez lui.", "alerte")
		end
		if vivant(dino) then
			notifier(v.victime, "Ton " .. v.nom .. " est revenu dans ta base !", "succes")
		end
	end

	-- le voleur est rentré chez lui avec le dino
	local function livrer(v)
		local dino = v.dino
		if not vivant(dino) then
			echouer(v, "disparu")
			return
		end
		if not terminer(v) then return end

		if joueurPresent(v.victime) then
			Bus.demander("LibererEmplacement", v.victime, v.ancienEmplacement)
		end
		pcall(function() dino:SetAttribute("Voleur", 0) end)

		local place = Bus.demander("PlacerDino", dino, v.voleur, v.numero)
		if place ~= true then
			-- pose impossible : le dino rentre chez sa victime
			v.fini = false
			vols[dino] = v
			if joueurPresent(v.victime) then
				local reserve = Bus.demander("ReserverEmplacement", v.victime)
				if type(reserve) == "number" then v.ancienEmplacement = reserve end
			end
			echouer(v, "pose")
			return
		end

		local vols_ = v.voleur:GetAttribute("Vols")
		if type(vols_) ~= "number" then vols_ = 0 end
		v.voleur:SetAttribute("Vols", vols_ + 1)

		Bus.emettre("DinoVole", dino, v.voleur, v.victime)
		notifier(v.voleur, "Vol réussi ! Le " .. v.nom .. " est à toi.", "succes")
		notifier(v.victime, nomJoueur(v.voleur) .. " t'a volé ton " .. v.nom .. " !", "vol")
		effet("VolReussi", positionDe(dino), { voleur = v.voleur.UserId })
	end

	-- ===== début d'un vol =====
	local function voler(dino, voleur, invite)
		if dino:GetAttribute("Etat") ~= "Enclos" then return end
		if vols[dino] then return end

		local proprietaire = dino:GetAttribute("Proprietaire")
		if type(proprietaire) ~= "number" or proprietaire == 0 then return end
		if proprietaire == voleur.UserId then return end
		local victime = Players:GetPlayerByUserId(proprietaire)
		if not victime then return end

		local baseDino = dino:GetAttribute("Base")
		local ancienEmplacement = dino:GetAttribute("Emplacement")
		if type(baseDino) ~= "number" or type(ancienEmplacement) ~= "number" or ancienEmplacement <= 0 then return end

		local _, humanoid, racine = corpsDe(voleur)
		if not humanoid then return end

		-- distance : portée de l'invite plus une marge
		local pos = pivotDe(dino)
		if not pos then return end
		local portee = 10
		if invite and invite:IsA("ProximityPrompt") then portee = invite.MaxActivationDistance end
		local rayon = 0
		pcall(function() rayon = dino:GetExtentsSize().Magnitude / 2 end)
		if (racine.Position - pos.Position).Magnitude > portee + MARGE_DISTANCE + rayon then return end

		if Bus.demander("AutoriserAction", voleur, "Vol", 0.5) == false then return end

		local baseVoleur = Bus.demander("BaseDe", voleur)
		if type(baseVoleur) ~= "number" then
			notifier(voleur, "Ta base n'est pas encore prête.", "alerte")
			return
		end
		if porteQuelqueChose(voleur) then
			notifier(voleur, "Tu portes déjà un dino !", "alerte")
			return
		end
		if voleur:GetAttribute("Etourdi") == true then return end

		if Bus.demander("BaseVerrouillee", baseDino) == true then
			notifier(voleur, "Base verrouillée !", "alerte")
			return
		end

		local numero = Bus.demander("ReserverEmplacement", voleur)
		if type(numero) ~= "number" then
			notifier(voleur, "Ta base est pleine !", "alerte")
			return
		end

		-- l'état a pu changer pendant les questions
		local _, humanoid2, racine2 = corpsDe(voleur)
		if not vivant(dino) or dino:GetAttribute("Etat") ~= "Enclos" or not joueurPresent(voleur)
			or not humanoid2 or porteQuelqueChose(voleur) then
			if joueurPresent(voleur) then
				Bus.demander("LibererEmplacement", voleur, numero)
			end
			return
		end
		humanoid = humanoid2
		racine = racine2

		local v = {
			dino = dino,
			voleur = voleur,
			victime = victime,
			numero = numero,
			baseVoleur = baseVoleur,
			ancienneBase = baseDino,
			ancienEmplacement = ancienEmplacement,
			personnage = voleur.Character,
			humanoid = humanoid,
			ancienneVitesse = humanoid.WalkSpeed,
			debut = os.clock(),
			nom = nomEspece(dino),
			fini = false,
		}
		vols[dino] = v

		dino:SetAttribute("Etat", "Porte")
		dino:SetAttribute("Voleur", voleur.UserId)
		voleur:SetAttribute("Porte", tostring(dino:GetAttribute("Id") or ""))
		humanoid.WalkSpeed = VITESSE_VOLEUR
		retirerInvites(dino)

		Bus.emettre("VolDebut", dino, voleur, victime)
		notifier(victime, nomJoueur(voleur) .. " vole ton " .. v.nom .. " !", "vol")
		notifier(voleur, "Rapporte le " .. v.nom .. " dans ta base !", "info")
		effet("VolDebut", pos.Position, { voleur = voleur.UserId, victime = victime.UserId })
	end

	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Voler" then return end
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") or not joueur.Parent then return end
		local dino = dinoDe(invite)
		if not dino or enCours[dino] then return end
		enCours[dino] = true
		pcall(voler, dino, joueur, invite)
		enCours[dino] = nil
	end)

	-- ===== suivi des dinos portés =====
	local function suivre(v)
		if v.fini then return end
		if not vivant(v.dino) then
			echouer(v, "disparu")
			return
		end
		if not joueurPresent(v.voleur) then
			echouer(v, "depart")
			return
		end
		local perso, humanoid, racine, tete = corpsDe(v.voleur)
		if not perso or perso ~= v.personnage or humanoid ~= v.humanoid then
			echouer(v, "mort")
			return
		end
		if os.clock() - v.debut > DELAI_MAX then
			echouer(v, "delai")
			return
		end

		-- le dino flotte au-dessus de la tête, tourné comme le voleur
		local haut
		if tete then
			haut = tete.Position + Vector3.new(0, tete.Size.Y / 2 + HAUTEUR_TETE, 0)
		else
			haut = racine.Position + Vector3.new(0, 3 + HAUTEUR_TETE, 0)
		end
		local regard = racine.CFrame.LookVector
		local plat = Vector3.new(regard.X, 0, regard.Z)
		if plat.Magnitude < 0.05 then plat = Vector3.new(0, 0, -1) end
		v.dino:PivotTo(CFrame.lookAt(haut, haut + plat.Unit))

		if Bus.demander("DansBase", racine.Position, v.baseVoleur) == true then
			livrer(v)
		end
	end

	RunService.Heartbeat:Connect(function()
		if next(vols) == nil then return end
		local liste = {}
		for _, v in pairs(vols) do table.insert(liste, v) end
		for _, v in ipairs(liste) do
			local ok = pcall(suivre, v)
			if not ok and not v.fini then
				pcall(echouer, v, "erreur")
			end
		end
	end)

	-- ===== interruptions =====
	local function joueurDe(cible)
		if typeof(cible) ~= "Instance" then return nil end
		if cible:IsA("Player") then return cible end
		if cible:IsA("Model") then return Players:GetPlayerFromCharacter(cible) end
		return nil
	end

	local function volDe(joueur)
		for _, v in pairs(vols) do
			if v.voleur == joueur and not v.fini then return v end
		end
		return nil
	end

	Bus.ecouter("Frappe", function(cible)
		local joueur = joueurDe(cible)
		if not joueur then return end
		local v = volDe(joueur)
		if v then echouer(v, "frappe") end
	end)

	local function preparer(joueur)
		pcall(function() joueur:SetAttribute("Porte", "") end)
		if joueur:GetAttribute("Vols") == nil then
			pcall(function() joueur:SetAttribute("Vols", 0) end)
		end
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		preparer(joueur)
	end
	Players.PlayerAdded:Connect(preparer)

	Players.PlayerRemoving:Connect(function(joueur)
		local liste = {}
		for _, v in pairs(vols) do table.insert(liste, v) end
		for _, v in ipairs(liste) do
			if not v.fini then
				-- si c'est la victime qui part, le voleur peut encore livrer le dino
				if v.voleur == joueur then
					pcall(echouer, v, "depart")
				end
			end
		end
	end)
end

return M
