-- Système Horde : fait apparaître les Zbires de chaque jour, les déplace vers la Maison,
-- encaisse leurs dégâts et annonce la fin de la horde.
local M = {}

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Plan = ctx.Plan
	local Charte = ctx.Charte
	local Bus = ctx.Bus
	local Etat = ctx.Etat
	local horde = ctx.horde

	local okRun, RunService = pcall(function() return game:GetService("RunService") end)
	local okJoueurs, Players = pcall(function() return game:GetService("Players") end)
	if not okRun then RunService = nil end
	if not okJoueurs then Players = nil end

	local alea = Random.new()
	local centreMaison = Plan.maison.centre
	local portee = E.porteeAttaqueZbire

	-- état interne
	local vivants = {}      -- modele -> infos de déplacement
	local nbVivants = 0
	local aVenir = 0
	local generation = 0
	local apparitionFinie = true
	local finAnnoncee = true
	local jourCourant = 0
	local compteurId = 0
	local dernierEffetMaison = 0

	-- ===== utilitaires =====
	local function effet(genre, position, donnees)
		local ev = ctx.Reseau and ctx.Reseau.Effet
		if not ev then return end
		pcall(function() ev:FireAllClients(genre, position, donnees) end)
	end

	local function majRestants()
		local n = nbVivants + aVenir
		if n < 0 then n = 0 end
		Etat:SetAttribute("ZbiresRestants", n)
	end

	local function plafond()
		local m = nil
		pcall(function() m = ctx.racine:GetAttribute("MaxZbires") end)
		if type(m) ~= "number" or m < 1 then m = 60 end
		return m
	end

	local function nbJoueursEnRun()
		local n = 0
		if Players then
			for _, j in ipairs(Players:GetPlayers()) do
				if j:GetAttribute("EnRun") == true then n = n + 1 end
			end
		end
		if n < 1 then n = 1 end
		return n
	end

	local function positionDe(modele)
		local ok, cf = pcall(function() return modele:GetPivot() end)
		if ok and cf then return cf.Position end
		return centreMaison
	end

	local function majBarre(modele, pv, pvMax)
		local barre = modele:FindFirstChild("Barre", true)
		if not barre then return end
		local fond = barre:FindFirstChild("Fond")
		if not fond then return end
		local remplissage = fond:FindFirstChild("Remplissage")
		if not remplissage then return end
		local ratio = 0
		if pvMax > 0 then ratio = math.clamp(pv / pvMax, 0, 1) end
		pcall(function() remplissage.Size = UDim2.fromScale(ratio, 1) end)
	end

	-- vérifie si la horde du jour est terminée
	local function verifierFin(gen)
		if gen ~= generation then return end
		if finAnnoncee then return end
		if apparitionFinie and nbVivants <= 0 and aVenir <= 0 then
			finAnnoncee = true
			Etat:SetAttribute("ZbiresRestants", 0)
			Bus.emettre("HordeTerminee", jourCourant)
		end
	end

	-- modèle de secours si le gabarit est absent
	local function modeleSecours(typeZ)
		local m = Instance.new("Model")
		m.Name = typeZ
		local corps = Instance.new("Part")
		corps.Name = "Corps"
		corps.Size = Vector3.new(2, 3, 2)
		corps.Anchored = true
		corps.CanCollide = false
		corps.Material = Enum.Material.SmoothPlastic
		corps.TopSurface = Enum.SurfaceType.Smooth
		corps.BottomSurface = Enum.SurfaceType.Smooth
		corps.Color = Charte.violet
		corps.CFrame = CFrame.new(0, 1.5, 0)
		corps.Parent = m
		m.PrimaryPart = corps
		pcall(function() m.WorldPivot = CFrame.new(0, 0, 0) end)
		return m
	end

	local function gabarit(typeZ)
		local dossier = ctx.stockage and ctx.stockage:FindFirstChild("Zbires")
		local g = dossier and dossier:FindFirstChild(typeZ)
		local m = nil
		if g then
			local ok, clone = pcall(function() return g:Clone() end)
			if ok and clone then m = clone end
		end
		if not m or not m:IsA("Model") then
			if m then m:Destroy() end
			m = modeleSecours(typeZ)
		end
		if not m.PrimaryPart then
			local corps = m:FindFirstChild("Corps", true)
			if not (corps and corps:IsA("BasePart")) then
				corps = m:FindFirstChildWhichIsA("BasePart", true)
			end
			if corps then m.PrimaryPart = corps end
		end
		return m
	end

	-- position d'apparition : près d'un portail une fois sur deux, sinon sur la lisière
	local function pointApparition()
		if alea:NextNumber() < 0.5 then
			local liste = {}
			for _, p in pairs(Plan.portails) do table.insert(liste, p) end
			if #liste > 0 then
				local p = liste[alea:NextInteger(1, #liste)]
				return Vector3.new(p.X + alea:NextNumber(-6, 6), 0, p.Z + alea:NextNumber(-6, 6))
			end
		end
		local angle = alea:NextNumber(0, math.pi * 2)
		local r = alea:NextNumber(75, 90)
		return Vector3.new(centreMaison.X + math.cos(angle) * r, 0, centreMaison.Z + math.sin(angle) * r)
	end

	local function tirerType(jour)
		local compo = E.compositionDuJour(jour)
		local total = 0
		for _, c in ipairs(compo) do total = total + c[2] end
		if total <= 0 then return "Marcheur" end
		local tirage = alea:NextNumber(0, total)
		for _, c in ipairs(compo) do
			tirage = tirage - c[2]
			if tirage <= 0 then return c[1] end
		end
		return compo[#compo][1]
	end

	-- fait apparaître un Zbire à la position donnée (sol)
	local function apparaitre(typeZ, position, jour)
		local stats = E.zbires[typeZ]
		if not stats then return nil end
		local modele = gabarit(typeZ)
		compteurId = compteurId + 1
		local pv = stats.pv * E.jour.multiplicateurPv ^ (math.max(jour, 1) - 1)
		pv = math.floor(pv + 0.5)
		if pv < 1 then pv = 1 end
		modele.Name = typeZ
		modele:SetAttribute("Type", typeZ)
		modele:SetAttribute("Id", "Z" .. compteurId)
		modele:SetAttribute("PV", pv)
		modele:SetAttribute("PVMax", pv)

		local y = 0
		if typeZ == "Volant" and stats.altitude then y = stats.altitude end
		local depart = Vector3.new(position.X, y, position.Z)
		local cible = Vector3.new(centreMaison.X, y, centreMaison.Z)
		pcall(function()
			if (cible - depart).Magnitude > 0.01 then
				modele:PivotTo(CFrame.lookAt(depart, cible))
			else
				modele:PivotTo(CFrame.new(depart))
			end
		end)
		majBarre(modele, pv, pv)
		modele.Parent = horde

		vivants[modele] = {
			type = typeZ,
			stats = stats,
			x = position.X,
			z = position.Z,
			phase = alea:NextNumber(0, math.pi * 2),
			attente = 0,
		}
		nbVivants = nbVivants + 1
		majRestants()

		Bus.emettre("ZbireApparu", modele, typeZ)
		if typeZ == "Colosse" then
			Etat:SetAttribute("ColosseActif", true)
			Bus.emettre("ColosseApparu", modele)
			effet("Colosse", depart, nil)
		end
		return modele
	end

	-- retire un Zbire du suivi et le détruit
	local function retirer(modele)
		if vivants[modele] then
			vivants[modele] = nil
			nbVivants = nbVivants - 1
			if nbVivants < 0 then nbVivants = 0 end
		end
		pcall(function() modele:Destroy() end)
	end

	-- ===== nettoyage =====
	local function nettoyer()
		generation = generation + 1
		aVenir = 0
		apparitionFinie = true
		finAnnoncee = true
		local liste = {}
		for modele in pairs(vivants) do table.insert(liste, modele) end
		for _, modele in ipairs(liste) do retirer(modele) end
		vivants = {}
		nbVivants = 0
		for _, enfant in ipairs(horde:GetChildren()) do
			if enfant:GetAttribute("Type") ~= nil then
				pcall(function() enfant:Destroy() end)
			end
		end
		Etat:SetAttribute("ZbiresRestants", 0)
		Etat:SetAttribute("ColosseActif", false)
	end

	Bus.ecouter("NettoyerHorde", nettoyer)
	Bus.ecouter("MaisonTombee", nettoyer)
	Bus.ecouter("RetourLobby", nettoyer)

	-- ===== début d'un jour =====
	Bus.ecouter("JourDebut", function(jour)
		if type(jour) ~= "number" then return end
		generation = generation + 1
		local gen = generation
		jourCourant = jour

		local total = math.ceil(E.zbiresDuJour(jour) * (1 + E.jour.multiplicateurCoop * (nbJoueursEnRun() - 1)))
		local colosse = (jour % E.jour.colosseTousLes == 0)
		local liste = {}
		for i = 1, total do liste[i] = tirerType(jour) end
		if colosse then
			-- le Colosse arrive au milieu de la vague
			table.insert(liste, math.floor(#liste / 2) + 1, "Colosse")
		end

		aVenir = #liste
		apparitionFinie = false
		finAnnoncee = false
		majRestants()

		task.spawn(function()
			local fenetre = E.jour.dureeHorde * 0.6
			local intervalle = 0
			if #liste > 1 then intervalle = fenetre / (#liste - 1) end
			for i, typeZ in ipairs(liste) do
				if gen ~= generation then return end
				-- attend qu'il y ait de la place sous le plafond
				while nbVivants >= plafond() do
					task.wait(0.5)
					if gen ~= generation then return end
				end
				aVenir = aVenir - 1
				local ok, err = pcall(apparaitre, typeZ, pointApparition(), jour)
				if not ok then
					warn("[Zsurvie] Horde : apparition impossible (" .. tostring(typeZ) .. ") : " .. tostring(err))
					majRestants()
				end
				if i < #liste and intervalle > 0 then
					task.wait(intervalle)
				end
			end
			if gen ~= generation then return end
			aVenir = 0
			apparitionFinie = true
			majRestants()
			verifierFin(gen)
		end)
	end)

	-- ===== dégâts reçus =====
	Bus.ecouter("DegatsZbire", function(modele, degats, joueur, critique)
		if typeof(modele) ~= "Instance" then return end
		if type(degats) ~= "number" or degats ~= degats or degats <= 0 then return end
		if modele.Parent ~= horde then return end
		local infos = vivants[modele]
		local pv = modele:GetAttribute("PV")
		if type(pv) ~= "number" or pv <= 0 then return end
		local typeZ = modele:GetAttribute("Type")
		local stats = (infos and infos.stats) or E.zbires[typeZ]

		if stats and stats.armure and critique ~= true then
			degats = degats * (1 - stats.armure)
		end
		pv = pv - degats
		if pv < 0 then pv = 0 end
		local pvMax = modele:GetAttribute("PVMax")
		if type(pvMax) ~= "number" or pvMax <= 0 then pvMax = math.max(pv, 1) end
		modele:SetAttribute("PV", pv)
		majBarre(modele, pv, pvMax)

		local position = positionDe(modele)
		effet("Impact", position, { critique = (critique == true) })

		if pv > 0 then return end

		-- vaincu
		local tueur = nil
		if typeof(joueur) == "Instance" and joueur:IsA("Player") then tueur = joueur end
		local gen = generation
		Bus.emettre("ZbireVaincu", modele, typeZ, position, tueur)
		effet("Vaincu", position, { type = typeZ })

		retirer(modele)

		if typeZ == "Colosse" then
			Etat:SetAttribute("ColosseActif", false)
		end
		if typeZ == "Gluant" and gen == generation then
			local n = (E.zbires.Gluant and E.zbires.Gluant.division) or 0
			for i = 1, n do
				local angle = (i / math.max(n, 1)) * math.pi * 2 + alea:NextNumber(0, 1)
				local p = Vector3.new(position.X + math.cos(angle) * 2.5, 0, position.Z + math.sin(angle) * 2.5)
				pcall(apparaitre, "MiniGluant", p, math.max(jourCourant, 1))
			end
		end
		majRestants()
		verifierFin(gen)
	end)

	-- ===== déplacement et attaques : une seule boucle pour tous =====
	local temps = 0
	local function pas(dt)
		temps = temps + dt
		local liste = {}
		for modele in pairs(vivants) do table.insert(liste, modele) end
		for _, modele in ipairs(liste) do
			local infos = vivants[modele]
			if infos then
				if modele.Parent ~= horde then
					-- détruit par quelqu'un d'autre
					vivants[modele] = nil
					nbVivants = nbVivants - 1
					if nbVivants < 0 then nbVivants = 0 end
					majRestants()
					verifierFin(generation)
				else
					local stats = infos.stats
					local dx = centreMaison.X - infos.x
					local dz = centreMaison.Z - infos.z
					local distance = math.sqrt(dx * dx + dz * dz)
					local enMarche = distance > portee + 0.05 -- marge : l'arrivée pile à la portée ne doit pas bloquer l'attaque
					if enMarche then
						local avance = math.min(stats.vitesse * dt, distance - portee)
						infos.x = infos.x + dx / distance * avance
						infos.z = infos.z + dz / distance * avance
					else
						infos.attente = infos.attente + dt
						if infos.attente >= stats.cadence then
							infos.attente = 0
							Bus.emettre("DegatsMaison", stats.degats)
							if temps - dernierEffetMaison >= 0.5 then
								dernierEffetMaison = temps
								effet("DegatsMaison", Vector3.new(infos.x, 2, infos.z), nil)
							end
						end
					end

					-- dandinement
					local t = temps * 6 + infos.phase
					local y = math.abs(math.sin(t)) * 0.35
					local roulis = math.sin(t) * 0.08
					if infos.type == "Sauteur" then
						y = math.abs(math.sin(temps * 3.5 + infos.phase)) * 3
						roulis = 0
					elseif infos.type == "Volant" then
						y = (stats.altitude or 6) + math.sin(temps * 2 + infos.phase) * 0.6
					end
					if not enMarche and infos.type ~= "Volant" then
						y = y * 0.5
					end

					if vivants[modele] and modele.Parent == horde then
						local pos = Vector3.new(infos.x, y, infos.z)
						local regard = Vector3.new(centreMaison.X, y, centreMaison.Z)
						local cf
						if (regard - pos).Magnitude > 0.01 then
							cf = CFrame.lookAt(pos, regard) * CFrame.Angles(0, 0, roulis)
						else
							cf = CFrame.new(pos)
						end
						pcall(function() modele:PivotTo(cf) end)
					end
				end
			end
		end
	end

	if RunService then
		RunService.Heartbeat:Connect(function(dt)
			local ok, err = pcall(pas, dt)
			if not ok then warn("[Zsurvie] Horde : boucle de déplacement : " .. tostring(err)) end
		end)
	else
		task.spawn(function()
			while true do
				local dt = task.wait(1 / 30)
				pcall(pas, dt)
			end
		end)
	end

	majRestants()
end

return M
