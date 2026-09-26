-- Système Enclos : les dinos posés dans les Bases (emplacements, revenu, collecte, vente, restauration).
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Plan = ctx.Plan
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local E = ctx.Equilibrage
	local Reseau = ctx.Reseau

	local PART_VENTE = (E.vente and E.vente.part) or 0.5
	local DUREE_VOL = (E.vol and E.vol.dureeAppui) or 1.2
	local EMPLACEMENTS_MAX = (Plan.base and Plan.base.emplacementsMax) or 12
	local EMPLACEMENTS_DEPART = (E.base and E.base.emplacementsDepart) or 8
	local DISTANCE_INVITE = 10
	local MARGE_DISTANCE = 6
	local ANTI_REBOND = 0.5

	local occupation = {}   -- [UserId] = { [numero] = true (réservé) ou dino }
	local placeDe = {}      -- [dino] = { uid = UserId, numero = n }
	local surveilles = {}   -- [dino] = connexion Destroying
	local dernierContact = {} -- [UserId] = os.clock() de la dernière collecte
	local enVente = {}      -- [dino] = true pendant la vente
	local panneaux = {}     -- [podium] = BillboardGui « Stock »

	-- ===== utilitaires =====
	local function estJoueur(j)
		return typeof(j) == "Instance" and j:IsA("Player")
	end

	local function vivant(dino)
		return typeof(dino) == "Instance" and dino:IsA("Model") and dino.Parent == ctx.dinos
	end

	local function notifier(joueur, texte, genre)
		if estJoueur(joueur) and joueur.Parent then
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

	local function pivotDe(inst)
		local ok, cf = pcall(function() return inst:GetPivot() end)
		if ok and typeof(cf) == "CFrame" then return cf end
		return nil
	end

	local function nombre(valeur, defaut)
		if type(valeur) == "number" and valeur == valeur then return valeur end
		return defaut
	end

	local function nomEspece(dino)
		local espece = dino:GetAttribute("Espece")
		local fiche = E.especes and E.especes[espece]
		if fiche and fiche.nom then return fiche.nom end
		return tostring(espece or "Dino")
	end

	-- remonte jusqu'au Model posé directement dans ctx.dinos
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

	local function corpsDe(dino)
		if dino.PrimaryPart then return dino.PrimaryPart end
		local corps = dino:FindFirstChild("Corps", true)
		if corps and corps:IsA("BasePart") then return corps end
		return dino:FindFirstChildWhichIsA("BasePart", true)
	end

	local function racineDe(joueur)
		local perso = joueur.Character
		if not perso then return nil end
		local racine = perso:FindFirstChild("HumanoidRootPart")
		if racine and racine:IsA("BasePart") then return racine end
		return nil
	end

	local function modeleBase(index)
		if type(index) ~= "number" then return nil end
		local m = Bus.demander("ModeleBase", index)
		if typeof(m) == "Instance" then return m end
		local dossier = ctx.racine:FindFirstChild("Bases")
		if dossier then return dossier:FindFirstChild("Base" .. index) end
		return nil
	end

	local function nombreEmplacements(joueur)
		local n = nombre(Bus.demander("NombreEmplacements", joueur), EMPLACEMENTS_DEPART)
		n = math.floor(n)
		if n > EMPLACEMENTS_MAX then n = EMPLACEMENTS_MAX end
		if n < 0 then n = 0 end
		return n
	end

	-- ===== les emplacements =====
	local function tableDe(uid)
		local t = occupation[uid]
		if not t then
			t = {}
			occupation[uid] = t
		end
		return t
	end

	-- un emplacement est pris s'il est réservé ou occupé par un dino vivant qui y est bien posé
	local function estPris(uid, numero)
		local t = occupation[uid]
		if not t then return false end
		local entree = t[numero]
		if entree == nil then return false end
		if entree == true then return true end
		if vivant(entree) and entree:GetAttribute("Proprietaire") == uid and entree:GetAttribute("Emplacement") == numero then
			return true
		end
		t[numero] = nil
		if placeDe[entree] and placeDe[entree].uid == uid and placeDe[entree].numero == numero then
			placeDe[entree] = nil
		end
		return false
	end

	local function premierLibre(joueur)
		local uid = joueur.UserId
		local n = nombreEmplacements(joueur)
		for numero = 1, n do
			if not estPris(uid, numero) then return numero end
		end
		return nil
	end

	local function reserver(joueur)
		if not estJoueur(joueur) or not joueur.Parent then return nil end
		local numero = premierLibre(joueur)
		if numero then
			tableDe(joueur.UserId)[numero] = true
		end
		return numero
	end

	local function liberer(joueur, numero)
		if not estJoueur(joueur) or type(numero) ~= "number" then return end
		local t = occupation[joueur.UserId]
		if not t then return end
		local entree = t[numero]
		t[numero] = nil
		if entree ~= nil and entree ~= true then
			local p = placeDe[entree]
			if p and p.uid == joueur.UserId and p.numero == numero then
				placeDe[entree] = nil
			end
		end
	end

	-- oublie la place d'un dino (détruit, vendu, déplacé)
	local function oublier(dino)
		local p = placeDe[dino]
		if p then
			local t = occupation[p.uid]
			if t and t[p.numero] == dino then t[p.numero] = nil end
			placeDe[dino] = nil
		end
		local c = surveilles[dino]
		if c then
			pcall(function() c:Disconnect() end)
			surveilles[dino] = nil
		end
		enVente[dino] = nil
	end

	local function surveiller(dino)
		if surveilles[dino] then return end
		local ok, connexion = pcall(function()
			return dino.Destroying:Connect(function()
				oublier(dino)
			end)
		end)
		if ok and connexion then surveilles[dino] = connexion end
	end

	-- ===== pose d'un dino =====
	local function poserInvites(dino)
		for _, d in ipairs(dino:GetDescendants()) do
			if d:IsA("ProximityPrompt") and d.Name == "Acheter" then
				pcall(function() d:Destroy() end)
			end
		end
		local corps = corpsDe(dino)
		if not corps then return end
		local nom = nomEspece(dino)
		if not corps:FindFirstChild("Voler") then
			Outils.invite(corps, { nom = "Voler", action = "Voler", objet = nom, duree = DUREE_VOL, distance = DISTANCE_INVITE })
		end
		local prix = nombre(dino:GetAttribute("Prix"), 0)
		local texte = "Vendre " .. Charte.argent(math.floor(prix * PART_VENTE))
		local vendre = corps:FindFirstChild("Vendre")
		if vendre and vendre:IsA("ProximityPrompt") then
			vendre.ActionText = texte
		elseif not vendre then
			Outils.invite(corps, { nom = "Vendre", action = texte, objet = nom, duree = 0.6, distance = DISTANCE_INVITE })
		end
	end

	local function placer(dino, joueur, numero)
		if not vivant(dino) or not estJoueur(joueur) or not joueur.Parent then return false end
		if type(numero) ~= "number" then return false end
		numero = math.floor(numero)
		if numero < 1 or numero > EMPLACEMENTS_MAX then return false end
		local index = Bus.demander("BaseDe", joueur)
		if type(index) ~= "number" then return false end
		local uid = joueur.UserId

		-- l'emplacement demandé est tenu par un autre dino : on en cherche un autre
		local t = tableDe(uid)
		local entree = t[numero]
		if entree ~= nil and entree ~= true and entree ~= dino and estPris(uid, numero) then
			numero = premierLibre(joueur)
			if not numero then return false end
		end

		local cf = Bus.demander("CFrameEmplacement", index, numero)
		if typeof(cf) ~= "CFrame" then return false end

		-- l'ancienne place du dino (chez un autre joueur ou ailleurs) se libère
		local ancienne = placeDe[dino]
		if ancienne and (ancienne.uid ~= uid or ancienne.numero ~= numero) then
			local ta = occupation[ancienne.uid]
			if ta and ta[ancienne.numero] == dino then ta[ancienne.numero] = nil end
		end

		dino:SetAttribute("Etat", "Enclos")
		dino:SetAttribute("Proprietaire", uid)
		dino:SetAttribute("Base", index)
		dino:SetAttribute("Emplacement", numero)
		dino:SetAttribute("Voleur", 0)
		if type(dino:GetAttribute("Stock")) ~= "number" then
			dino:SetAttribute("Stock", 0)
		end
		local ok = pcall(function() dino:PivotTo(cf) end)
		if not ok then return false end

		t[numero] = dino
		placeDe[dino] = { uid = uid, numero = numero }
		surveiller(dino)
		pcall(poserInvites, dino)

		Bus.emettre("DinoPlace", dino, joueur, numero)
		return true
	end

	local function dinosDe(joueur)
		local liste = {}
		if not estJoueur(joueur) then return liste end
		local uid = joueur.UserId
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:IsA("Model") and dino:GetAttribute("Proprietaire") == uid then
				local etat = dino:GetAttribute("Etat")
				if etat == "Enclos" or etat == "EnRoute" then
					table.insert(liste, dino)
				end
			end
		end
		return liste
	end

	Bus.repondre("ReserverEmplacement", reserver)
	Bus.repondre("LibererEmplacement", liberer)
	Bus.repondre("PlacerDino", placer)
	Bus.repondre("DinosDe", dinosDe)

	-- ===== vider une Base (renaissance, départ) =====
	local function vider(joueur)
		if not estJoueur(joueur) then return end
		local uid = joueur.UserId
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:IsA("Model") and dino:GetAttribute("Proprietaire") == uid then
				local porte = dino:GetAttribute("Etat") == "Porte" and nombre(dino:GetAttribute("Voleur"), 0) ~= 0
				if not porte then
					oublier(dino)
					pcall(function() dino:Destroy() end)
				end
			end
		end
		local t = occupation[uid]
		if t then
			for numero, entree in pairs(t) do
				if entree ~= true then placeDe[entree] = nil end
				t[numero] = nil
			end
		end
		occupation[uid] = nil
		if joueur.Parent then
			joueur:SetAttribute("RevenuParSeconde", 0)
		end
	end

	Bus.ecouter("Renaissance", function(joueur)
		vider(joueur)
	end)

	Bus.ecouter("BaseLiberee", function(joueur)
		vider(joueur)
	end)

	-- ===== restauration des dinos sauvegardés =====
	Bus.ecouter("RestaurerDinos", function(joueur, liste)
		if not estJoueur(joueur) or type(liste) ~= "table" then return end
		for _, fiche in ipairs(liste) do
			if not joueur.Parent then return end
			if type(fiche) == "table" and type(fiche.Espece) == "string" and E.especes[fiche.Espece] then
				local mutation = fiche.Mutation
				if type(mutation) ~= "string" or not E.mutations[mutation] then mutation = "Normal" end
				local numero = reserver(joueur)
				if not numero then
					notifier(joueur, "Ta base est pleine : certains dinos n'ont pas pu revenir.", "alerte")
					return
				end
				local dino = Bus.demander("CreerDino", fiche.Espece, mutation)
				if vivant(dino) then
					dino:SetAttribute("Etat", "Enclos")
					if placer(dino, joueur, numero) ~= true then
						liberer(joueur, numero)
						oublier(dino)
						pcall(function() dino:Destroy() end)
					end
				else
					liberer(joueur, numero)
				end
			end
		end
	end)

	-- ===== collecte =====
	local function collecter(joueur, position)
		if not estJoueur(joueur) or not joueur.Parent then return end
		local uid = joueur.UserId
		local dinos = {}
		local somme = 0
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:IsA("Model") and dino:GetAttribute("Proprietaire") == uid and dino:GetAttribute("Etat") == "Enclos" then
				local stock = nombre(dino:GetAttribute("Stock"), 0)
				if stock > 0 then
					somme = somme + stock
					table.insert(dinos, { dino = dino, stock = stock })
				end
			end
		end
		local montant = math.floor(somme)
		if montant < 1 then return end
		for _, d in ipairs(dinos) do
			d.dino:SetAttribute("Stock", 0)
		end
		local total = Bus.demander("AjouterArgent", joueur, montant, "Collecte")
		if total == nil then
			-- l'économie n'a pas répondu : on rend les stocks
			for _, d in ipairs(dinos) do
				if vivant(d.dino) then
					d.dino:SetAttribute("Stock", nombre(d.dino:GetAttribute("Stock"), 0) + d.stock)
				end
			end
			return
		end
		-- les centimes restent dans le premier dino
		local reste = somme - montant
		if reste > 0 and vivant(dinos[1].dino) then
			dinos[1].dino:SetAttribute("Stock", nombre(dinos[1].dino:GetAttribute("Stock"), 0) + reste)
		end
		if not position then
			local racine = racineDe(joueur)
			if racine then position = racine.Position end
		end
		effet("Collecte", position, { montant = montant })
	end

	local function joueurDuContact(partie)
		local modele = partie and partie.Parent
		if not modele then return nil end
		local joueur = Players:GetPlayerFromCharacter(modele)
		if not joueur and modele.Parent then
			joueur = Players:GetPlayerFromCharacter(modele.Parent)
		end
		return joueur
	end

	local function brancherCollecte(index, modele)
		local dalle = modele:FindFirstChild("Collecte")
		if not dalle or not dalle:IsA("BasePart") then return false end
		dalle.Touched:Connect(function(partie)
			local joueur = joueurDuContact(partie)
			if not joueur then return end
			if Bus.demander("BaseDe", joueur) ~= index then return end
			local humanoide = joueur.Character and joueur.Character:FindFirstChildOfClass("Humanoid")
			if not humanoide or humanoide.Health <= 0 then return end
			local maintenant = os.clock()
			local dernier = dernierContact[joueur.UserId]
			if dernier and maintenant - dernier < ANTI_REBOND then return end
			dernierContact[joueur.UserId] = maintenant
			pcall(collecter, joueur, dalle.Position)
		end)
		return true
	end

	task.spawn(function()
		local branchees = {}
		local essais = 0
		local restantes = #Plan.bases
		while restantes > 0 and essais < 40 do
			for index = 1, #Plan.bases do
				if not branchees[index] then
					local modele = modeleBase(index)
					if modele and brancherCollecte(index, modele) then
						branchees[index] = true
						restantes = restantes - 1
					end
				end
			end
			if restantes > 0 then
				essais = essais + 1
				task.wait(0.5)
			end
		end
	end)

	Reseau.Collecter.OnServerEvent:Connect(function(joueur)
		if not estJoueur(joueur) or not joueur.Parent then return end
		local maintenant = os.clock()
		local dernier = dernierContact[joueur.UserId]
		if dernier and maintenant - dernier < ANTI_REBOND then return end
		if Bus.demander("AutoriserAction", joueur, "Collecter", ANTI_REBOND) == false then return end
		dernierContact[joueur.UserId] = maintenant
		local index = Bus.demander("BaseDe", joueur)
		if type(index) ~= "number" then return end
		local racine = racineDe(joueur)
		if not racine then return end
		if Bus.demander("DansBase", racine.Position, index) ~= true then return end
		pcall(collecter, joueur, racine.Position)
	end)

	-- ===== vente =====
	local function vendre(dino, joueur, invite)
		if dino:GetAttribute("Etat") ~= "Enclos" then return end
		if dino:GetAttribute("Proprietaire") ~= joueur.UserId then return end
		local racine = racineDe(joueur)
		local corps = corpsDe(dino)
		if not racine or not corps then return end
		local portee = invite.MaxActivationDistance
		if (racine.Position - corps.Position).Magnitude > portee + MARGE_DISTANCE + corps.Size.Magnitude / 2 then return end
		if Bus.demander("AutoriserAction", joueur, "Vente", 0.3) == false then return end

		local prix = nombre(dino:GetAttribute("Prix"), 0)
		local montant = math.floor(prix * PART_VENTE)
		local stock = math.floor(nombre(dino:GetAttribute("Stock"), 0))
		local espece = dino:GetAttribute("Espece")
		local nom = nomEspece(dino)
		local position = corps.Position
		local numero = dino:GetAttribute("Emplacement")

		-- le dino quitte l'enclos avant le paiement : pas de double vente
		dino:SetAttribute("Etat", "Vendu")
		dino:SetAttribute("Stock", 0)
		if montant > 0 then
			Bus.demander("AjouterArgent", joueur, montant, "Vente")
		end
		if stock > 0 then
			Bus.demander("AjouterArgent", joueur, stock, "Collecte")
		end
		liberer(joueur, numero)
		oublier(dino)
		pcall(function() dino:Destroy() end)

		Bus.emettre("DinoVendu", joueur, espece, montant)
		effet("Vente", position, { montant = montant })
		notifier(joueur, nom .. " vendu pour " .. Charte.argent(montant), "succes")
	end

	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Vendre" then return end
		if not estJoueur(joueur) or not joueur.Parent then return end
		local dino = dinoDe(invite)
		if not dino or enVente[dino] then return end
		enVente[dino] = true
		pcall(vendre, dino, joueur, invite)
		enVente[dino] = nil
	end)

	-- ===== affichage du stock au-dessus des podiums =====
	local function panneauDe(podium)
		local gui = panneaux[podium]
		if gui and gui.Parent == podium then return gui end
		gui = Instance.new("BillboardGui")
		gui.Name = "Stock"
		gui.Size = UDim2.fromOffset(110, 30)
		gui.MaxDistance = 45
		gui.LightInfluence = 0
		gui.AlwaysOnTop = true
		gui.Adornee = podium
		local etiquette = Instance.new("TextLabel")
		etiquette.Name = "Texte"
		etiquette.Size = UDim2.fromScale(1, 1)
		etiquette.BackgroundColor3 = Charte.encre
		etiquette.BackgroundTransparency = 0.35
		etiquette.BorderSizePixel = 0
		etiquette.Font = Charte.police
		etiquette.TextColor3 = Charte.dore
		etiquette.TextScaled = true
		etiquette.Text = ""
		etiquette.Parent = gui
		local coins = Instance.new("UICorner")
		coins.CornerRadius = UDim.new(0.5, 0)
		coins.Parent = etiquette
		local marge = Instance.new("UIPadding")
		marge.PaddingLeft = UDim.new(0, 6)
		marge.PaddingRight = UDim.new(0, 6)
		marge.PaddingTop = UDim.new(0, 3)
		marge.PaddingBottom = UDim.new(0, 3)
		marge.Parent = etiquette
		gui.Parent = podium
		panneaux[podium] = gui
		return gui
	end

	local function afficherStock(dino, stock, modeles)
		local index = dino:GetAttribute("Base")
		local numero = dino:GetAttribute("Emplacement")
		if type(index) ~= "number" or type(numero) ~= "number" then return nil end
		local modele = modeles[index]
		if modele == nil then
			modele = modeleBase(index) or false
			modeles[index] = modele
		end
		if not modele then return nil end
		local dossier = modele:FindFirstChild("Emplacements")
		local podium = dossier and dossier:FindFirstChild("E" .. numero)
		if not podium or not podium:IsA("BasePart") then return nil end
		local gui = panneauDe(podium)
		-- au bord avant du podium (côté regard du dino), au-dessus du dessus
		local cf = pivotDe(dino)
		local avant = Vector3.new(0, 0, 0)
		if cf then
			local regard = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
			if regard.Magnitude > 0.01 then
				avant = regard.Unit * (math.max(podium.Size.X, podium.Size.Z) / 2)
			end
		end
		gui.StudsOffsetWorldSpace = avant + Vector3.new(0, podium.Size.Y / 2 + 1.2, 0)
		gui.Enabled = true
		local texte = gui:FindFirstChild("Texte")
		if texte then
			local valeur = Charte.argent(math.floor(stock))
			if texte.Text ~= valeur then texte.Text = valeur end
		end
		return podium
	end

	-- ===== revenu : boucle d'une seconde =====
	local function tour(dt)
		local multiplicateurs = {}
		local revenus = {}
		local modeles = {}
		local actifs = {}
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if dino:IsA("Model") and dino:GetAttribute("Etat") == "Enclos" then
				local uid = nombre(dino:GetAttribute("Proprietaire"), 0)
				local joueur = nil
				if uid ~= 0 then joueur = Players:GetPlayerByUserId(uid) end
				if joueur then
					local mult = multiplicateurs[uid]
					if mult == nil then
						mult = nombre(Bus.demander("MultiplicateurRevenu", joueur), 1)
						multiplicateurs[uid] = mult
					end
					local revenu = nombre(dino:GetAttribute("Revenu"), 0) * mult
					local stock = nombre(dino:GetAttribute("Stock"), 0) + revenu * dt
					dino:SetAttribute("Stock", stock)
					revenus[uid] = (revenus[uid] or 0) + revenu
					local ok, podium = pcall(afficherStock, dino, stock, modeles)
					if ok and podium then actifs[podium] = true end
				end
			end
		end
		for _, joueur in ipairs(Players:GetPlayers()) do
			local valeur = revenus[joueur.UserId] or 0
			if joueur:GetAttribute("RevenuParSeconde") ~= valeur then
				joueur:SetAttribute("RevenuParSeconde", valeur)
			end
		end
		-- podiums vides : on cache leur panneau
		for podium, gui in pairs(panneaux) do
			if not podium.Parent or gui.Parent ~= podium then
				panneaux[podium] = nil
			elseif not actifs[podium] and gui.Enabled then
				gui.Enabled = false
			end
		end
		-- ménage des places de dinos disparus
		for dino, _ in pairs(placeDe) do
			if not vivant(dino) then oublier(dino) end
		end
	end

	task.spawn(function()
		local avant = os.clock()
		while true do
			task.wait(1)
			local maintenant = os.clock()
			local dt = maintenant - avant
			avant = maintenant
			if dt > 3 then dt = 3 end
			if dt < 0 then dt = 0 end
			pcall(tour, dt)
		end
	end)

	-- ===== joueurs =====
	local function arrivee(joueur)
		if joueur:GetAttribute("RevenuParSeconde") == nil then
			joueur:SetAttribute("RevenuParSeconde", 0)
		end
	end
	for _, joueur in ipairs(Players:GetPlayers()) do
		arrivee(joueur)
	end
	Players.PlayerAdded:Connect(arrivee)

	Players.PlayerRemoving:Connect(function(joueur)
		dernierContact[joueur.UserId] = nil
		-- filet de sécurité si la Base n'a pas été libérée (laisse le temps à la sauvegarde)
		task.delay(5, function()
			if not joueur.Parent and not Players:GetPlayerByUserId(joueur.UserId) then
				pcall(vider, joueur)
			end
		end)
	end)
end

return M
