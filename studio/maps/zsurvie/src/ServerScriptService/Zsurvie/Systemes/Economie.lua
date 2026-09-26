-- Systemes/Economie : pièces de la run, butin des Zbires et réparation de la Maison.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local M = {}

local MAX_PIECES_VISIBLES = 40 -- plafond de pièces volantes simultanées (visuel uniquement)

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local Etat = ctx.Etat

	-- dossier des pièces volantes
	local dossierPieces = nil
	if ctx.racine then
		dossierPieces = ctx.racine:FindFirstChild("Pieces")
		if not dossierPieces then
			dossierPieces = Instance.new("Folder")
			dossierPieces.Name = "Pieces"
			dossierPieces.Parent = ctx.racine
		end
	end
	local piecesVisibles = 0

	local derniereReparation = {}

	-- ===== utilitaires =====
	local function estJoueur(j)
		return typeof(j) == "Instance" and j:IsA("Player") and j.Parent == Players
	end

	local function lirePieces(j)
		local v = j:GetAttribute("Pieces")
		if type(v) ~= "number" then return 0 end
		return v
	end

	local function niveau(j, nom)
		local v = j:GetAttribute("Niv_" .. nom)
		if type(v) ~= "number" then return 0 end
		return v
	end

	local function effet(genre, position, donnees)
		local ev = Reseau.Effet
		if ev then
			pcall(function()
				ev:FireAllClients(genre, position, donnees)
			end)
		end
	end

	local function entierPositif(n)
		if type(n) ~= "number" or n ~= n or n == math.huge then return nil end
		n = math.floor(n)
		if n <= 0 then return nil end
		return n
	end

	-- ===== répondeurs =====
	local function ajouterPieces(j, n)
		if not estJoueur(j) then return nil end
		local total = lirePieces(j)
		n = entierPositif(n)
		if not n then return total end
		total = total + n
		j:SetAttribute("Pieces", total)
		Bus.emettre("PiecesGagnees", j, n)
		return total
	end

	local function depenserPieces(j, n)
		if not estJoueur(j) then return false end
		if type(n) ~= "number" or n ~= n or n < 0 or n == math.huge then return false end
		n = math.floor(n)
		local total = lirePieces(j)
		if total < n then return false end
		j:SetAttribute("Pieces", total - n)
		return true
	end

	Bus.repondre("AjouterPieces", ajouterPieces)
	Bus.repondre("DepenserPieces", depenserPieces)

	-- ===== joueurs =====
	local function initialiser(j)
		if j:GetAttribute("Pieces") == nil then
			j:SetAttribute("Pieces", 0)
		end
	end
	for _, j in ipairs(Players:GetPlayers()) do
		initialiser(j)
	end
	Players.PlayerAdded:Connect(initialiser)
	Players.PlayerRemoving:Connect(function(j)
		derniereReparation[j] = nil
	end)

	Bus.ecouter("RunDebut", function(joueurs)
		if type(joueurs) ~= "table" then return end
		for _, j in ipairs(joueurs) do
			if estJoueur(j) then
				j:SetAttribute("Pieces", 0)
			end
		end
	end)

	-- ===== visuel : pièce qui vole vers le personnage =====
	local function pieceVolante(position, j)
		if not dossierPieces or typeof(position) ~= "Vector3" then return end
		if piecesVisibles >= MAX_PIECES_VISIBLES then return end
		local personnage = j and j.Character
		local cible = personnage and personnage:FindFirstChild("HumanoidRootPart")
		if not cible then return end
		local ok, piece = pcall(function()
			local p = Instance.new("Part")
			p.Name = "Piece"
			p.Shape = Enum.PartType.Cylinder
			p.Size = Vector3.new(0.3, 1.2, 1.2)
			p.Material = Enum.Material.Neon
			p.Color = Charte.dore
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.CastShadow = false
			p.CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
			p.Parent = dossierPieces
			return p
		end)
		if not ok or not piece then return end
		piecesVisibles = piecesVisibles + 1
		task.spawn(function()
			-- petit saut sur place
			local haut = TweenService:Create(piece, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = piece.CFrame + Vector3.new(0, 2.5, 0) })
			haut:Play()
			task.wait(0.25)
			-- vol vers le personnage
			local destination = piece.CFrame
			if cible.Parent then
				destination = CFrame.new(cible.Position) * CFrame.Angles(0, 0, math.rad(90))
			end
			local vol = TweenService:Create(piece, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ CFrame = destination, Size = Vector3.new(0.15, 0.6, 0.6) })
			vol:Play()
			task.wait(0.45)
			piece:Destroy()
			piecesVisibles = piecesVisibles - 1
		end)
	end

	-- ===== butin des Zbires =====
	local function joueursEnRun()
		local liste = {}
		for _, j in ipairs(Players:GetPlayers()) do
			if j:GetAttribute("EnRun") == true then
				table.insert(liste, j)
			end
		end
		return liste
	end

	Bus.ecouter("ZbireVaincu", function(modele, typeZbire, position, tueur)
		local fiche = E.zbires[typeZbire]
		if not fiche then return end
		if typeof(position) ~= "Vector3" then
			if typeof(modele) == "Instance" and modele:IsA("Model") then
				local okPivot, pivot = pcall(function() return modele:GetPivot() end)
				if okPivot and pivot then position = pivot.Position end
			end
		end
		if typeof(position) ~= "Vector3" then position = nil end

		local effetButin = E.ameliorations.Butin.effet
		if estJoueur(tueur) then
			local butin = math.floor(fiche.pieces * (1 + niveau(tueur, "Butin") * effetButin) + 0.5)
			if butin > 0 then
				ajouterPieces(tueur, butin)
				if position then
					pieceVolante(position, tueur)
					effet("Piece", position, { n = butin })
				end
			end
			if (fiche.gemmes or 0) > 0 then
				Bus.demander("AjouterGemmes", tueur, fiche.gemmes, "Zbire")
			end
		else
			local liste = joueursEnRun()
			local nb = #liste
			if nb == 0 then return end
			for _, j in ipairs(liste) do
				local butin = math.floor(fiche.pieces * (1 + niveau(j, "Butin") * effetButin) + 0.5)
				local part = math.max(1, math.floor(butin / nb + 0.5))
				ajouterPieces(j, part)
				if position then
					pieceVolante(position, j)
				end
				if (fiche.gemmes or 0) > 0 then
					Bus.demander("AjouterGemmes", j, math.max(1, math.floor(fiche.gemmes / nb + 0.5)), "Zbire")
				end
			end
			if position then
				local base = math.floor(fiche.pieces + 0.5)
				effet("Piece", position, { n = math.max(1, base) })
			end
		end
	end)

	-- ===== réparation de la Maison =====
	local evReparer = Reseau.Reparer
	if evReparer then
		evReparer.OnServerEvent:Connect(function(j)
			if not estJoueur(j) then return end
			if j:GetAttribute("EnRun") ~= true then return end
			local phase = Etat and Etat:GetAttribute("Phase")
			if phase ~= "Horde" and phase ~= "Repit" then return end
			local personnage = j.Character
			local racinePerso = personnage and personnage:FindFirstChild("HumanoidRootPart")
			if not racinePerso then return end
			local centre = Plan.maison.centre
			local dx = racinePerso.Position.X - centre.X
			local dz = racinePerso.Position.Z - centre.Z
			if math.sqrt(dx * dx + dz * dz) > E.maison.distanceReparation then return end

			local delai = E.maison.delaiReparation
			local maintenant = os.clock()
			local dernier = derniereReparation[j]
			if dernier and maintenant - dernier < delai then return end
			if Bus.demander("AutoriserAction", j, "Reparer", delai) == false then return end
			derniereReparation[j] = maintenant

			local montant = E.maison.reparationParAction * (1 + niveau(j, "Reparation") * E.ameliorations.Reparation.effet)
			Bus.emettre("SoinMaison", montant)
			effet("Reparation", racinePerso.Position, nil)
		end)
	end
end

return M
