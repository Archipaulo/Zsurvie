-- Systemes/Tapis : fabrique tous les dinos vivants (répondeur CreerDino), fait apparaître
-- des dinos au début du Tapis roulant et les fait avancer jusqu'à la Fin du tapis.
local RunService = game:GetService("RunService")

local M = {}

local ANGLE_REGARD = -math.pi / 2 -- le regard (-Z local) tourné vers +X
local DANDINEMENT_ANGLE = 0.07    -- radians de roulis
local DANDINEMENT_HAUTEUR = 0.15  -- studs de sautillement
local DANDINEMENT_FREQUENCE = 7   -- radians par seconde
local INTERVALLE_ADOPTION = 1     -- secondes entre deux recherches de dinos « Tapis » inconnus

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Etat = ctx.Etat

	local alea = Random.new()
	local compteur = 0

	-- ===== outils internes =====

	-- somme lisible, avec une décimale pour les petits revenus non entiers
	local function argentFin(n)
		n = tonumber(n) or 0
		if n < 100 and math.abs(n - math.floor(n)) > 0.01 then
			local texte = string.format("%.1f", n)
			texte = string.gsub(texte, "%.", ",")
			return texte .. " $"
		end
		return Charte.argent(n)
	end

	local function partsDe(modele)
		local liste = {}
		for _, d in ipairs(modele:GetDescendants()) do
			if d:IsA("BasePart") then
				table.insert(liste, d)
			end
		end
		return liste
	end

	-- nom affiché : espèce + mutation éventuelle
	local function nomAffiche(espece, mutation)
		local infos = E.especes[espece]
		local nom = (infos and infos.nom) or espece
		local mut = E.mutations[mutation]
		if mut and mut.nom and mut.nom ~= "" then
			nom = nom .. " " .. mut.nom
		end
		return nom
	end

	-- modèle de secours quand le gabarit de l'espèce manque
	local function modeleSecours(espece, rarete)
		local m = Instance.new("Model")
		m.Name = espece
		local taille = Vector3.new(3, 2, 4)
		local corps = Outils.bloc(m, {
			Name = "Corps",
			Size = taille,
			CFrame = CFrame.new(0, taille.Y / 2, 0),
			Color = Charte.raretes[rarete] or Charte.creme,
			CanCollide = false,
			CanQuery = true,
		})
		corps.PivotOffset = CFrame.new(0, -taille.Y / 2, 0)
		m.PrimaryPart = corps
		m:SetAttribute("Espece", espece)
		return m
	end

	-- aspect visuel de la mutation
	local function appliquerMutation(modele, corps, mutation)
		if mutation == "Normal" then
			return
		end
		local teinte = Charte.mutations[mutation]
		if not teinte then
			return
		end
		local parts = partsDe(modele)
		for i, p in ipairs(parts) do
			if p.Transparency < 1 then
				if mutation == "Or" then
					p.Color = p.Color:Lerp(teinte, 0.75)
					p.Material = Enum.Material.Metal
				elseif mutation == "Diamant" then
					p.Color = p.Color:Lerp(teinte, 0.65)
					p.Material = Enum.Material.Glass
					p.Reflectance = 0.15
				elseif mutation == "ArcEnCiel" then
					p.Color = p.Color:Lerp(teinte, 0.5)
				elseif mutation == "Lave" then
					if i % 3 == 1 then
						p.Color = teinte
						p.Material = Enum.Material.Neon
					else
						p.Color = p.Color:Lerp(Charte.pierre, 0.35)
					end
				elseif mutation == "Meteore" then
					p.Color = p.Color:Lerp(teinte, 0.65)
				end
			end
		end
		if mutation == "ArcEnCiel" then
			Outils.animer(modele, "pulse", 1.5)
		elseif mutation == "Meteore" then
			Outils.lumiere(corps, { genre = "Point", Range = 12, Brightness = 2, Color = Charte.violet })
		elseif mutation == "Lave" then
			Outils.lumiere(corps, { genre = "Point", Range = 8, Brightness = 1, Color = Charte.lave })
		end
	end

	-- hauteur du haut du modèle au-dessus du centre du Corps
	local function hauteurAuDessus(modele, corps)
		local haut = corps.Size.Y / 2
		for _, p in ipairs(partsDe(modele)) do
			local h = p.Position.Y + p.Size.Y / 2 - corps.Position.Y
			if h > haut then
				haut = h
			end
		end
		return haut
	end

	-- étiquette flottante : nom, rareté, prix, revenu
	local function poserEtiquette(modele, corps, espece, rarete, mutation, prix, revenu)
		local ancienne = corps:FindFirstChild("Etiquette")
		if ancienne then
			ancienne:Destroy()
		end
		local gui = Instance.new("BillboardGui")
		gui.Name = "Etiquette"
		gui.Adornee = corps
		gui.AlwaysOnTop = false
		gui.MaxDistance = 80
		gui.LightInfluence = 0
		gui.Size = UDim2.new(7, 0, 3.2, 0)
		gui.StudsOffset = Vector3.new(0, hauteurAuDessus(modele, corps) + 2, 0)
		gui.Parent = corps

		local liste = Instance.new("UIListLayout")
		liste.FillDirection = Enum.FillDirection.Vertical
		liste.HorizontalAlignment = Enum.HorizontalAlignment.Center
		liste.SortOrder = Enum.SortOrder.LayoutOrder
		liste.Parent = gui

		local function ligne(nom, ordre, texte, couleur, hauteur, police)
			local t = Instance.new("TextLabel")
			t.Name = nom
			t.LayoutOrder = ordre
			t.Size = UDim2.new(1, 0, hauteur, 0)
			t.BackgroundTransparency = 1
			t.Text = texte
			t.TextScaled = true
			t.Font = police or Charte.police
			t.TextColor3 = couleur
			t.TextStrokeColor3 = Charte.encre
			t.TextStrokeTransparency = 0.2
			t.Parent = gui
			return t
		end

		local couleurNom = Charte.creme
		if mutation ~= "Normal" and Charte.mutations[mutation] then
			couleurNom = Charte.mutations[mutation]
			if mutation == "Meteore" then
				couleurNom = Charte.violet
			end
		end
		local infosRarete = E.raretes[rarete]
		ligne("Nom", 1, nomAffiche(espece, mutation), couleurNom, 0.3)
		ligne("Rarete", 2, (infosRarete and infosRarete.nom) or rarete, Charte.raretes[rarete] or Charte.creme, 0.24)
		ligne("Prix", 3, Charte.argent(prix), Charte.dore, 0.24)
		ligne("Revenu", 4, "+" .. argentFin(revenu) .. "/s", Charte.herbe, 0.22, Charte.policeTexte)
		return gui
	end

	-- ===== répondeur CreerDino =====
	local function creerDino(espece, mutation)
		if type(espece) ~= "string" then
			return nil
		end
		local infos = E.especes[espece]
		if not infos then
			return nil
		end
		if type(mutation) ~= "string" or not E.mutations[mutation] then
			mutation = "Normal"
		end
		local rarete = infos.rarete
		local mult = E.mutations[mutation].multiplicateur or 1

		-- clone du gabarit, ou modèle de secours
		local modele = nil
		local gabarits = ctx.stockage and ctx.stockage:FindFirstChild("Dinos")
		local gabarit = gabarits and gabarits:FindFirstChild(espece)
		if gabarit and gabarit:IsA("Model") then
			local ok, copie = pcall(function()
				return gabarit:Clone()
			end)
			if ok and copie then
				modele = copie
			end
		end
		if not modele then
			modele = modeleSecours(espece, rarete)
		end

		local corps = modele:FindFirstChild("Corps")
		if not (corps and corps:IsA("BasePart")) then
			corps = modele.PrimaryPart
		end
		if not corps then
			for _, p in ipairs(partsDe(modele)) do
				corps = p
				break
			end
		end
		if not corps then
			modele:Destroy()
			modele = modeleSecours(espece, rarete)
			corps = modele.PrimaryPart
		end
		if not modele.PrimaryPart then
			modele.PrimaryPart = corps
		end
		for _, p in ipairs(partsDe(modele)) do
			p.Anchored = true
			p.CanCollide = false
		end

		compteur = compteur + 1
		local prix = math.floor(infos.prix * mult)
		local revenu = infos.revenu * mult
		modele.Name = espece
		modele:SetAttribute("Id", "D" .. compteur)
		modele:SetAttribute("Espece", espece)
		modele:SetAttribute("Rarete", rarete)
		modele:SetAttribute("Mutation", mutation)
		modele:SetAttribute("Prix", prix)
		modele:SetAttribute("Revenu", revenu)
		modele:SetAttribute("Etat", "Tapis")
		modele:SetAttribute("Proprietaire", 0)
		modele:SetAttribute("Base", 0)
		modele:SetAttribute("Emplacement", 0)
		modele:SetAttribute("Voleur", 0)
		modele:SetAttribute("Stock", 0)

		pcall(appliquerMutation, modele, corps, mutation)
		pcall(poserEtiquette, modele, corps, espece, rarete, mutation, prix, revenu)

		modele.Parent = ctx.dinos
		return modele
	end
	Bus.repondre("CreerDino", creerDino)

	-- ===== tirages =====
	local especesParRarete = {}
	for cle, infos in pairs(E.especes) do
		especesParRarete[infos.rarete] = especesParRarete[infos.rarete] or {}
		table.insert(especesParRarete[infos.rarete], cle)
	end
	for _, liste in pairs(especesParRarete) do
		table.sort(liste)
	end

	local function tirer(poids)
		local total = 0
		for _, entree in ipairs(poids) do
			total = total + entree.poids
		end
		if total <= 0 then
			return nil
		end
		local r = alea:NextNumber() * total
		for _, entree in ipairs(poids) do
			r = r - entree.poids
			if r <= 0 and entree.poids > 0 then
				return entree.cle
			end
		end
		for i = #poids, 1, -1 do
			if poids[i].poids > 0 then
				return poids[i].cle
			end
		end
		return nil
	end

	local function evenementCourant()
		local nom = Etat:GetAttribute("Evenement")
		if type(nom) ~= "string" or nom == "" then
			return "", nil
		end
		return nom, E.evenements.liste[nom]
	end

	local function tirerRarete(evenement)
		local seuil = E.raretes.Epique.ordre
		local bonus = 1
		if evenement and type(evenement.bonusRarete) == "number" then
			bonus = evenement.bonusRarete
		end
		local poids = {}
		for cle, infos in pairs(E.raretes) do
			if especesParRarete[cle] then
				local p = infos.poids
				if infos.ordre >= seuil then
					p = p * bonus
				end
				table.insert(poids, { cle = cle, poids = p, ordre = infos.ordre })
			end
		end
		table.sort(poids, function(a, b) return a.ordre < b.ordre end)
		return tirer(poids) or "Commun"
	end

	local function tirerMutation(nomEvenement, evenement)
		local bonusMutation = (evenement and evenement.bonusMutation) or {}
		local poids = {}
		for cle, infos in pairs(E.mutations) do
			local p = infos.poids + (bonusMutation[cle] or 0)
			if infos.evenement and infos.evenement ~= nomEvenement then
				p = 0
			end
			table.insert(poids, { cle = cle, poids = p })
		end
		table.sort(poids, function(a, b) return a.cle < b.cle end)
		return tirer(poids) or "Normal"
	end

	-- ===== suivi des dinos sur le Tapis =====
	-- dino -> { x, phase }
	local surTapis = {}
	local nombreSurTapis = 0

	local function cadreTapis(x, t, phase)
		local oscillation = math.sin(t * DANDINEMENT_FREQUENCE + phase)
		local y = Plan.tapis.hauteur + math.abs(oscillation) * DANDINEMENT_HAUTEUR
		return CFrame.new(x, y, Plan.tapis.debut.Z)
			* CFrame.Angles(0, ANGLE_REGARD, 0)
			* CFrame.Angles(0, 0, oscillation * DANDINEMENT_ANGLE)
	end

	local function suivre(dino, x)
		if surTapis[dino] then
			return
		end
		surTapis[dino] = { x = x, phase = alea:NextNumber() * math.pi * 2 }
		nombreSurTapis = nombreSurTapis + 1
	end

	local function oublier(dino)
		if surTapis[dino] then
			surTapis[dino] = nil
			nombreSurTapis = nombreSurTapis - 1
		end
	end

	-- ===== apparition d'un dino =====
	local function apparaitre()
		if nombreSurTapis >= E.tapis.maxDinos then
			return
		end
		local nomEvenement, evenement = evenementCourant()
		local rarete = tirerRarete(evenement)
		local liste = especesParRarete[rarete]
		if not liste or #liste == 0 then
			return
		end
		local espece = liste[alea:NextInteger(1, #liste)]
		local mutation = tirerMutation(nomEvenement, evenement)

		local dino = creerDino(espece, mutation)
		if not dino then
			return
		end
		mutation = dino:GetAttribute("Mutation")
		local prix = dino:GetAttribute("Prix")
		local depart = Plan.tapis.debut
		dino:PivotTo(cadreTapis(depart.X, 0, 0))
		suivre(dino, depart.X)

		local corps = dino:FindFirstChild("Corps") or dino.PrimaryPart
		if corps then
			Outils.invite(corps, {
				nom = "Acheter",
				action = "Acheter",
				objet = nomAffiche(espece, mutation) .. " — " .. Charte.argent(prix),
				duree = 0.25,
				distance = 12,
			})
		end

		Bus.emettre("DinoApparu", dino)

		local infosRarete = E.raretes[rarete]
		if (infosRarete and infosRarete.ordre >= E.raretes.Legendaire.ordre) or mutation ~= "Normal" then
			local position = dino:GetPivot().Position
			pcall(function()
				ctx.Reseau.Effet:FireAllClients("Apparition", position, {
					rarete = rarete,
					mutation = mutation,
					espece = espece,
				})
			end)
		end
	end

	task.spawn(function()
		while true do
			task.wait(E.tapis.intervalle)
			local ok, err = pcall(apparaitre)
			if not ok then
				warn("[Dino] Tapis, apparition : " .. tostring(err))
			end
		end
	end)

	-- adopte les dinos mis à l'Etat « Tapis » par un autre système, s'ils sont bien sur le tapis
	local function adopter()
		local debut, fin = Plan.tapis.debut, Plan.tapis.fin
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if not surTapis[dino] and dino:IsA("Model") and dino:GetAttribute("Etat") == "Tapis" then
				local ok, pivot = pcall(function()
					return dino:GetPivot()
				end)
				if ok and pivot then
					local p = pivot.Position
					if p.X >= debut.X - 1 and p.X <= fin.X and math.abs(p.Z - debut.Z) <= Plan.tapis.largeur / 2 then
						suivre(dino, p.X)
					end
				end
			end
		end
	end

	-- ===== UNE boucle Heartbeat : avance, dandinement, fin du tapis =====
	local tempsAdoption = 0
	local dernierCompte = -1
	RunService.Heartbeat:Connect(function(dt)
		local t = os.clock()
		tempsAdoption = tempsAdoption + dt
		if tempsAdoption >= INTERVALLE_ADOPTION then
			tempsAdoption = 0
			pcall(adopter)
		end

		local aDetruire = {}
		local aOublier = {}
		for dino, fiche in pairs(surTapis) do
			if dino.Parent == nil or dino:GetAttribute("Etat") ~= "Tapis" then
				table.insert(aOublier, dino)
			else
				fiche.x = fiche.x + E.tapis.vitesse * dt
				if fiche.x > Plan.tapis.fin.X then
					table.insert(aDetruire, dino)
				else
					local ok = pcall(function()
						dino:PivotTo(cadreTapis(fiche.x, t, fiche.phase))
					end)
					if not ok then
						table.insert(aOublier, dino)
					end
				end
			end
		end
		for _, dino in ipairs(aOublier) do
			oublier(dino)
		end
		for _, dino in ipairs(aDetruire) do
			oublier(dino)
			pcall(function()
				dino:Destroy()
			end)
		end

		if nombreSurTapis ~= dernierCompte then
			dernierCompte = nombreSurTapis
			Etat:SetAttribute("DinosSurTapis", nombreSurTapis)
		end
	end)
end

return M
