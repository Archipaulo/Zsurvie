-- Systemes/Batte : donne une batte à chaque apparition et traite les frappes (Remote « Frapper »).
-- Une frappe réussie repousse la cible, l'étourdit un court instant et lui fait lâcher son butin (via Bus « Frappe »).
local Players = game:GetService("Players")

local M = {}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local E = ctx.Equilibrage

	local REGLES = E.batte or {}
	local RECHARGE = tonumber(REGLES.recharge) or 1.2
	local PORTEE = tonumber(REGLES.portee) or 8
	local RECUL = tonumber(REGLES.recul) or 60
	local ETOURDISSEMENT = tonumber(REGLES.etourdissement) or 1.6
	local OR = (E.boutique and E.boutique.BatteOr) or {}
	local FACTEUR_RECHARGE_OR = tonumber(OR.recharge) or 1
	local FACTEUR_RECUL_OR = tonumber(OR.recul) or 1
	local VITESSE_DEFAUT = 16

	local derniereFrappe = {} -- [joueur] = os.clock() de la dernière frappe
	local etourdis = {} -- [joueur] = { jeton, humanoid, vitesse }

	-- ===== utilitaires =====
	local function personnageVivant(joueur)
		if not joueur or not joueur.Parent then return nil end
		local perso = joueur.Character
		if not perso or not perso.Parent then return nil end
		local humanoid = perso:FindFirstChildOfClass("Humanoid")
		local racine = perso:FindFirstChild("HumanoidRootPart")
		if not humanoid or not racine or humanoid.Health <= 0 then return nil end
		return perso, humanoid, racine
	end

	local function aBatteOr(joueur)
		return joueur:GetAttribute("Objet_BatteOr") == true
	end

	local function effet(position, donnees)
		pcall(function()
			Reseau.Effet:FireAllClients("Frappe", position, donnees)
		end)
	end

	-- ===== fabrication de la batte =====
	local function nouvellePart(nom, taille, couleur, parent)
		local p = Instance.new("Part")
		p.Name = nom
		p.Size = taille
		p.Color = couleur
		p.Material = Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Anchored = false
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Massless = true
		p.Parent = parent
		return p
	end

	local function souder(part, handle, decalage)
		part.CFrame = handle.CFrame * decalage
		local soudure = Instance.new("WeldConstraint")
		soudure.Part0 = handle
		soudure.Part1 = part
		soudure.Parent = part
	end

	-- palette cartoon (STYLE.md §3 : couleurs saturées, SmoothPlastic, Neon seulement pour ce qui brille)
	local Style = ctx.Style
	local BOIS_CLAIR = Charte.hex and Charte.hex("F2C27B") or Color3.fromRGB(242, 194, 123)
	local BANDE = (Style and Style.boutons and Style.boutons.rouge and Style.boutons.rouge[2]) or Charte.tapis
	local ENCRE = (Style and Style.couleurs and Style.couleurs.contour) or Charte.encre

	-- couleur du bout : bois clair, ou or brillant avec la Batte dorée
	local function colorerBout(outil, dore)
		local bout = outil:FindFirstChild("Bout")
		if not bout then return end
		if dore then
			bout.Color = Charte.dore
			bout.Material = Enum.Material.Neon
		else
			bout.Color = BOIS_CLAIR
			bout.Material = Enum.Material.SmoothPlastic
		end
	end

	local function fabriquerBatte(joueur)
		local outil = Instance.new("Tool")
		outil.Name = "Batte"
		outil.RequiresHandle = true
		outil.CanBeDropped = false
		outil.ToolTip = "Frappe un voleur pour lui faire lâcher son dino"
		-- tenue par le manche, bout épais vers le haut
		outil.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

		-- corps en bois clair, bout nettement plus gros (silhouette cartoon lisible de loin)
		local handle = nouvellePart("Handle", Vector3.new(0.6, 0.6, 4), BOIS_CLAIR, outil)
		local bout = nouvellePart("Bout", Vector3.new(1.15, 1.15, 1.7), BOIS_CLAIR, outil)
		souder(bout, handle, CFrame.new(0, 0, 1.5))
		-- bande rouge vif entre le corps et le bout
		local bande = nouvellePart("Bande", Vector3.new(0.78, 0.78, 0.35), BANDE, outil)
		souder(bande, handle, CFrame.new(0, 0, 0.45))
		-- manche encre (grip) et pommeau épais au bout
		local manche = nouvellePart("Manche", Vector3.new(0.72, 0.72, 0.9), ENCRE, outil)
		souder(manche, handle, CFrame.new(0, 0, -1.55))
		local pommeau = nouvellePart("Pommeau", Vector3.new(0.95, 0.95, 0.3), ENCRE, outil)
		souder(pommeau, handle, CFrame.new(0, 0, -2.1))

		colorerBout(outil, aBatteOr(joueur))
		return outil
	end

	local function retirerBattes(conteneur)
		if not conteneur then return end
		for _, enfant in ipairs(conteneur:GetChildren()) do
			if enfant:IsA("Tool") and enfant.Name == "Batte" then
				pcall(function() enfant:Destroy() end)
			end
		end
	end

	local function donnerBatte(joueur, perso)
		local sac = joueur:FindFirstChildOfClass("Backpack") or joueur:WaitForChild("Backpack", 10)
		if not sac or not joueur.Parent or joueur.Character ~= perso then return end
		retirerBattes(sac)
		retirerBattes(perso)
		local ok, outil = pcall(fabriquerBatte, joueur)
		if ok and outil then
			outil.Parent = sac
		end
	end

	-- ===== étourdissement =====
	local function finEtourdissement(joueur, jeton)
		local etat = etourdis[joueur]
		if not etat or etat.jeton ~= jeton then return end
		etourdis[joueur] = nil
		local humanoid = etat.humanoid
		-- on ne rend la vitesse que si personne d'autre ne l'a changée entre-temps
		if humanoid and humanoid.Parent and humanoid.WalkSpeed == 0 then
			pcall(function() humanoid.WalkSpeed = etat.vitesse end)
		end
		if joueur.Parent then
			pcall(function() joueur:SetAttribute("Etourdi", false) end)
		end
	end

	local function etourdir(joueur, humanoid)
		local etat = etourdis[joueur]
		local vitesse
		if etat and etat.humanoid == humanoid then
			-- déjà étourdi : on garde la vitesse mémorisée au premier coup
			vitesse = etat.vitesse
		else
			vitesse = humanoid.WalkSpeed
			if vitesse <= 0 then vitesse = VITESSE_DEFAUT end
		end
		local jeton = {}
		etourdis[joueur] = { jeton = jeton, humanoid = humanoid, vitesse = vitesse }
		pcall(function() humanoid.WalkSpeed = 0 end)
		task.delay(ETOURDISSEMENT, function()
			finEtourdissement(joueur, jeton)
		end)
	end

	-- ===== recul =====
	local function repousser(racine, vitesse)
		pcall(function()
			racine.AssemblyLinearVelocity = vitesse
		end)
		-- la racine appartient au client de la cible : une contrainte brève garantit le recul chez lui
		pcall(function()
			local attache = Instance.new("Attachment")
			attache.Name = "ReculBatte"
			attache.Parent = racine
			local elan = Instance.new("LinearVelocity")
			elan.Name = "ReculBatte"
			elan.Attachment0 = attache
			elan.MaxForce = 1000000
			elan.VectorVelocity = vitesse
			elan.RelativeTo = Enum.ActuatorRelativeTo.World
			elan.Parent = racine
			task.delay(0.18, function()
				pcall(function() elan:Destroy() end)
				pcall(function() attache:Destroy() end)
			end)
		end)
	end

	-- ===== frappe =====
	local function chercherCible(attaquant, racineA)
		local regard = racineA.CFrame.LookVector
		local meilleure, meilleureDistance = nil, PORTEE
		for _, autre in ipairs(Players:GetPlayers()) do
			if autre ~= attaquant then
				local _, humanoidB, racineB = personnageVivant(autre)
				if humanoidB then
					local ecart = racineB.Position - racineA.Position
					local distance = ecart.Magnitude
					if distance < meilleureDistance and ecart:Dot(regard) > 0 then
						meilleure = autre
						meilleureDistance = distance
					end
				end
			end
		end
		return meilleure
	end

	local function frapper(joueur)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		local _, _, racineA = personnageVivant(joueur)
		if not racineA then return end
		if joueur:GetAttribute("Etourdi") == true then return end

		local recharge = RECHARGE
		if aBatteOr(joueur) then recharge = recharge * FACTEUR_RECHARGE_OR end
		local maintenant = os.clock()
		local derniere = derniereFrappe[joueur]
		if derniere and maintenant - derniere < recharge then return end
		derniereFrappe[joueur] = maintenant

		local cible = chercherCible(joueur, racineA)
		if not cible then
			-- coup dans le vide : simple souffle
			effet(racineA.Position + racineA.CFrame.LookVector * 3, { leger = true, attaquant = joueur.UserId })
			return
		end
		local _, humanoidB, racineB = personnageVivant(cible)
		if not humanoidB then return end

		local ecart = racineB.Position - racineA.Position
		local plat = Vector3.new(ecart.X, 0, ecart.Z)
		local direction
		if plat.Magnitude > 0.01 then
			direction = plat.Unit
		else
			local regard = racineA.CFrame.LookVector
			direction = Vector3.new(regard.X, 0, regard.Z)
			if direction.Magnitude > 0.01 then
				direction = direction.Unit
			else
				direction = Vector3.new(0, 0, -1)
			end
		end
		local force = RECUL
		if aBatteOr(joueur) then force = force * FACTEUR_RECUL_OR end

		pcall(function() cible:SetAttribute("Etourdi", true) end)
		-- d'abord le Bus : Vol termine le vol et rend sa vitesse normale au voleur...
		Bus.emettre("Frappe", cible, joueur)
		-- ...puis on mémorise cette vitesse et on immobilise
		if humanoidB.Parent then
			etourdir(cible, humanoidB)
		end
		repousser(racineB, direction * force + Vector3.new(0, 25, 0))
		effet(racineB.Position, { attaquant = joueur.UserId, cible = cible.UserId })
	end

	Reseau.Frapper.OnServerEvent:Connect(function(joueur)
		local ok, err = pcall(frapper, joueur)
		if not ok then warn("[Dino] Batte : " .. tostring(err)) end
	end)

	-- ===== joueurs =====
	local connexions = {} -- [joueur] = liste de connexions

	local function surPersonnage(joueur, perso)
		-- nouvelle vie : plus d'étourdissement en cours
		etourdis[joueur] = nil
		pcall(function() joueur:SetAttribute("Etourdi", false) end)
		task.spawn(function()
			local ok, err = pcall(donnerBatte, joueur, perso)
			if not ok then warn("[Dino] Batte (don) : " .. tostring(err)) end
		end)
	end

	local function preparer(joueur)
		if connexions[joueur] then return end
		pcall(function() joueur:SetAttribute("Etourdi", false) end)
		local liste = {}
		connexions[joueur] = liste
		table.insert(liste, joueur.CharacterAdded:Connect(function(perso)
			surPersonnage(joueur, perso)
		end))
		-- achat de la Batte dorée : la batte actuelle change d'aspect tout de suite
		table.insert(liste, joueur:GetAttributeChangedSignal("Objet_BatteOr"):Connect(function()
			local dore = aBatteOr(joueur)
			local sac = joueur:FindFirstChildOfClass("Backpack")
			for _, conteneur in ipairs({ sac, joueur.Character }) do
				if conteneur then
					local outil = conteneur:FindFirstChild("Batte")
					if outil and outil:IsA("Tool") then
						pcall(colorerBout, outil, dore)
					end
				end
			end
		end))
		if joueur.Character then
			surPersonnage(joueur, joueur.Character)
		end
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		preparer(joueur)
	end
	Players.PlayerAdded:Connect(preparer)

	Players.PlayerRemoving:Connect(function(joueur)
		local liste = connexions[joueur]
		if liste then
			for _, c in ipairs(liste) do
				pcall(function() c:Disconnect() end)
			end
		end
		connexions[joueur] = nil
		derniereFrappe[joueur] = nil
		etourdis[joueur] = nil
	end)
end

return M
