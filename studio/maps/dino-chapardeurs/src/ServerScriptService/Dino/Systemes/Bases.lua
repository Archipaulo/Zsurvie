-- Système Bases : attribution des Bases aux joueurs, apparition, emplacements débloqués, verrou de l'entrée.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local EB = ctx.Equilibrage.base
	local Reseau = ctx.Reseau

	local NB_BASES = #Plan.bases
	local EMPLACEMENTS_MAX = Plan.base.emplacementsMax or 12
	local DUREE_VERROU = EB.dureeVerrou or 60
	local RECHARGE = EB.recharge or 5
	local PERIODE = 0.25

	local modeles = {}        -- index -> Model
	local proprietaires = {}  -- index -> Player
	local baseDe = {}         -- Player -> index
	local finVerrou = {}      -- index -> heure serveur de fin du verrou (0 si libre)
	local finRecharge = {}    -- index -> heure serveur de fin de recharge
	local apparenceEntree = {} -- index -> propriétés d'origine de l'Entree
	local apparenceE = {}     -- part E<n> -> { Color, Transparency, Material }
	local dernierAvis = {}    -- Player -> heure du dernier avertissement d'intrusion
	local connexions = {}     -- Player -> liste de connexions

	local function maintenant()
		return workspace:GetServerTimeNow()
	end

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

	local function estIndex(index)
		return type(index) == "number" and index >= 1 and index <= NB_BASES and index == math.floor(index)
	end

	local function estJoueur(joueur)
		return typeof(joueur) == "Instance" and joueur:IsA("Player")
	end

	-- ===== les modèles des Bases =====
	local dossier = ctx.racine:FindFirstChild("Bases") or ctx.racine:WaitForChild("Bases", 15)

	local function trouverModele(i)
		if modeles[i] and modeles[i].Parent then return modeles[i] end
		if not dossier then dossier = ctx.racine:FindFirstChild("Bases") end
		if not dossier then return nil end
		local m = dossier:FindFirstChild("Base" .. i)
		if not m then
			for _, enfant in ipairs(dossier:GetChildren()) do
				if enfant:IsA("Model") and enfant:GetAttribute("Index") == i then
					m = enfant
				end
			end
		end
		modeles[i] = m
		return m
	end

	local function partDe(index, nom)
		local m = trouverModele(index)
		if not m then return nil end
		local p = m:FindFirstChild(nom)
		if p and p:IsA("BasePart") then return p end
		return nil
	end

	local function versTapis(index)
		local b = Plan.bases[index]
		if b and b.versTapis then return b.versTapis end
		return 1
	end

	-- ===== zone et positions =====
	local function dansZone(index, position)
		local zone = partDe(index, "Zone")
		if not zone then return false end
		local l = zone.CFrame:PointToObjectSpace(position)
		local t = zone.Size
		return math.abs(l.X) <= t.X / 2 and math.abs(l.Y) <= t.Y / 2 and math.abs(l.Z) <= t.Z / 2
	end

	-- demi-hauteur d'une part dans le repère du monde (valable quelle que soit sa rotation)
	local function demiHauteur(part)
		local cf = part.CFrame
		local t = part.Size
		return (math.abs(cf.RightVector.Y) * t.X + math.abs(cf.UpVector.Y) * t.Y + math.abs(cf.LookVector.Y) * t.Z) / 2
	end

	local function cframeEmplacement(index, numero)
		local m = trouverModele(index)
		if not m then return nil end
		local dossierE = m:FindFirstChild("Emplacements")
		if not dossierE then return nil end
		local e = dossierE:FindFirstChild("E" .. numero)
		if not e or not e:IsA("BasePart") then return nil end
		local haut = e.Position + Vector3.new(0, demiHauteur(e), 0)
		return CFrame.lookAt(haut, haut + Vector3.new(0, 0, versTapis(index)))
	end

	-- juste devant l'entrée, côté Tapis
	local function devantEntree(index, xVoulu)
		local zone = partDe(index, "Zone")
		local sens = versTapis(index)
		local centre = Plan.bases[index].centre
		local zBord = centre.Z + sens * Plan.base.profondeur / 2
		local largeur = Plan.base.largeur
		if zone then
			local bord = zone.CFrame:PointToWorldSpace(Vector3.new(0, 0, 0))
			local demiZ = (math.abs(zone.CFrame.LookVector.Z) * zone.Size.Z + math.abs(zone.CFrame.RightVector.Z) * zone.Size.X) / 2
			zBord = bord.Z + sens * demiZ
			centre = Vector3.new(bord.X, 0, bord.Z)
		end
		local entree = partDe(index, "Entree")
		local xMin = centre.X - largeur / 2 + 3
		local xMax = centre.X + largeur / 2 - 3
		if entree then
			local demiX = (math.abs(entree.CFrame.RightVector.X) * entree.Size.X + math.abs(entree.CFrame.LookVector.X) * entree.Size.Z) / 2
			xMin = entree.Position.X - math.max(demiX - 2, 0)
			xMax = entree.Position.X + math.max(demiX - 2, 0)
		end
		local x = math.clamp(xVoulu or centre.X, math.min(xMin, xMax), math.max(xMin, xMax))
		local position = Vector3.new(x, 3, zBord + sens * 5)
		return CFrame.lookAt(position, position + Vector3.new(0, 0, sens))
	end

	-- ===== aspect =====
	local Style = ctx.Style
	local GRIS_LIBRE = Color3.fromRGB(201, 206, 216)
	if Style and Style.boutons and Style.boutons.gris then GRIS_LIBRE = Style.boutons.gris[1] end
	-- même ordre de teintes que Builders/Bases : une couleur dominante par base
	local TEINTES = { Charte.lave, Charte.gemme, Charte.violet, Charte.herbe, Charte.dore, Charte.alerte, Charte.sable, Charte.jungle }
	local etiquettes = {} -- index -> { nom = TextLabel, compteGui = BillboardGui, compte = TextLabel }

	local function couleurBase(index)
		local m = trouverModele(index)
		local c = m and m:GetAttribute("Couleur")
		if typeof(c) == "Color3" then return c end
		c = TEINTES[((index - 1) % #TEINTES) + 1]
		if typeof(c) == "Color3" then return c end
		return Color3.new(1, 1, 1)
	end

	-- crée (une seule fois) le nom géant et le compte à rebours flottants au-dessus de l'Entree
	local function etiquettesDe(index)
		local e = etiquettes[index]
		if e and e.nom.Parent and e.nom.Parent.Parent and e.compteGui.Parent then return e end
		if not Style or not Style.etiquette then return nil end
		local entree = partDe(index, "Entree")
		if not entree then return nil end
		local ancienNom = entree:FindFirstChild("NomGeant")
		if ancienNom then ancienNom:Destroy() end
		local ancienCompte = entree:FindFirstChild("CompteVerrou")
		if ancienCompte then ancienCompte:Destroy() end
		local haut = demiHauteur(entree)
		-- le nom flotte au-dessus de l'enseigne si elle existe, sinon au-dessus du portique
		local hauteurNom = haut + 7
		local enseigne = partDe(index, "Enseigne")
		if enseigne then
			hauteurNom = math.max(hauteurNom, enseigne.Position.Y + demiHauteur(enseigne) - entree.Position.Y + 5)
		end
		local _, lignesNom = Style.etiquette(entree, {
			{ texte = "BASE LIBRE", couleur = GRIS_LIBRE, titre = true, contour = 4, nom = "Nom" },
		}, {
			Name = "NomGeant",
			largeur = 32,
			hauteurLigne = 6,
			StudsOffset = Vector3.new(0, hauteurNom, 0),
			MaxDistance = 250,
		})
		local compteGui, lignesCompte = Style.etiquette(entree, {
			{ texte = "", titre = true, contour = 4, nom = "Compte" },
		}, {
			Name = "CompteVerrou",
			largeur = 12,
			hauteurLigne = 4,
			StudsOffset = Vector3.new(0, haut + 2.5, 0),
			MaxDistance = 150,
		})
		compteGui.Enabled = false
		e = { nom = lignesNom[1], compteGui = compteGui, compte = lignesCompte[1] }
		etiquettes[index] = e
		return e
	end

	local function titre(index, texte)
		local enseigne = trouverModele(index) and trouverModele(index):FindFirstChild("Enseigne")
		if enseigne then
			local affiche = enseigne:FindFirstChild("Affiche", true)
			local label = affiche and affiche:FindFirstChild("Titre", true)
			if label and label:IsA("TextLabel") then
				label.Text = texte
			end
		end
		-- nom géant flottant : « Base de <Nom> » dans la couleur de la base, « BASE LIBRE » en gris
		local e = etiquettesDe(index)
		if e then
			local gui = e.nom.Parent
			if proprietaires[index] then
				e.nom.Text = texte
				e.nom.TextColor3 = couleurBase(index)
				-- le nom du propriétaire est géant et visible de loin
				if gui and gui:IsA("BillboardGui") then
					gui.Size = UDim2.new(32, 0, 6, 0)
					gui.MaxDistance = 250
				end
			else
				e.nom.Text = "BASE LIBRE"
				e.nom.TextColor3 = GRIS_LIBRE
				-- une base libre reste discrète pour ne pas encombrer la vue
				if gui and gui:IsA("BillboardGui") then
					gui.Size = UDim2.new(12, 0, 2.2, 0)
					gui.MaxDistance = 90
				end
			end
		end
	end

	-- compte à rebours « 🔒 45 » au-dessus de l'Entree pendant le verrou
	local function majCompte(index)
		local e = etiquettesDe(index)
		if not e then return end
		local reste = (finVerrou[index] or 0) - maintenant()
		if reste > 0 then
			local texte = "🔒 " .. math.ceil(reste)
			if e.compte.Text ~= texte then e.compte.Text = texte end
			if not e.compteGui.Enabled then e.compteGui.Enabled = true end
		elseif e.compteGui.Enabled then
			e.compteGui.Enabled = false
			e.compte.Text = ""
		end
	end

	local function nombreEmplacements(joueur)
		local renaissances = 0
		if estJoueur(joueur) then
			renaissances = tonumber(joueur:GetAttribute("Renaissances")) or 0
		end
		local n = (EB.emplacementsDepart or 8) + math.floor(renaissances) * (EB.emplacementsParRenaissance or 1)
		return math.max(0, math.min(EMPLACEMENTS_MAX, n))
	end

	local function majEmplacements(index)
		local m = trouverModele(index)
		if not m then return end
		local dossierE = m:FindFirstChild("Emplacements")
		if not dossierE then return end
		local n = nombreEmplacements(proprietaires[index])
		for numero = 1, EMPLACEMENTS_MAX do
			local e = dossierE:FindFirstChild("E" .. numero)
			if e and e:IsA("BasePart") then
				if not apparenceE[e] then
					apparenceE[e] = { Color = e.Color, Transparency = e.Transparency, Material = e.Material }
				end
				local origine = apparenceE[e]
				local debloque = numero <= n
				e:SetAttribute("Debloque", debloque)
				if debloque then
					e.Color = origine.Color
					e.Transparency = origine.Transparency
					e.Material = origine.Material
				else
					e.Color = Charte.pierre
					e.Transparency = math.max(origine.Transparency, 0.6)
					e.Material = Enum.Material.SmoothPlastic
				end
			end
		end
	end

	local function aspectEntree(index, verrouillee)
		local entree = partDe(index, "Entree")
		if not entree then return end
		if not apparenceEntree[index] then
			apparenceEntree[index] = {
				Color = entree.Color, Material = entree.Material, Transparency = entree.Transparency,
			}
		end
		local o = apparenceEntree[index]
		if verrouillee then
			entree.Material = Enum.Material.Neon
			entree.Color = Charte.alerte
			entree.Transparency = 0.3
		else
			entree.Material = o.Material
			entree.Color = o.Color
			entree.Transparency = o.Transparency
		end
	end

	local function invitesVerrou(index)
		local m = trouverModele(index)
		local liste = {}
		if not m then return liste end
		local bouton = m:FindFirstChild("BoutonVerrou")
		if not bouton then return liste end
		for _, d in ipairs(bouton:GetDescendants()) do
			if d:IsA("ProximityPrompt") and d.Name == "Verrouiller" then
				table.insert(liste, d)
			end
		end
		if bouton:IsA("ProximityPrompt") and bouton.Name == "Verrouiller" then
			table.insert(liste, bouton)
		end
		return liste
	end

	-- texte de l'invite : temps restant du verrou ou de la recharge
	local function majInvite(index)
		local t = maintenant()
		local texte = "Verrouiller"
		local objet = "Base libre"
		if proprietaires[index] then
			objet = "Base de " .. proprietaires[index].DisplayName
		end
		if (finVerrou[index] or 0) > t then
			texte = "Verrouillée : " .. math.ceil(finVerrou[index] - t) .. " s"
		elseif (finRecharge[index] or 0) > t then
			texte = "Recharge : " .. math.ceil(finRecharge[index] - t) .. " s"
		end
		for _, invite in ipairs(invitesVerrou(index)) do
			if invite.ActionText ~= texte then invite.ActionText = texte end
			if invite.ObjectText ~= objet then invite.ObjectText = objet end
		end
		majCompte(index)
	end

	local function estVerrouillee(index)
		local m = trouverModele(index)
		return m ~= nil and m:GetAttribute("Verrouillee") == true and (finVerrou[index] or 0) > maintenant()
	end

	local function deverrouiller(index, avecRecharge)
		local m = trouverModele(index)
		local etaitVerrouillee = (finVerrou[index] or 0) > 0
		finVerrou[index] = 0
		if avecRecharge then
			finRecharge[index] = maintenant() + RECHARGE
		else
			finRecharge[index] = 0
		end
		if m then
			m:SetAttribute("Verrouillee", false)
			m:SetAttribute("FinVerrou", 0)
		end
		aspectEntree(index, false)
		majInvite(index)
		if etaitVerrouillee then
			local entree = partDe(index, "Entree")
			effet("Verrou", entree and entree.Position or Plan.bases[index].centre, { index = index, actif = false })
			if avecRecharge then
				notifier(proprietaires[index], "Ta base n'est plus verrouillée", "alerte")
			end
		end
	end

	local function verrouiller(index, joueur)
		local m = trouverModele(index)
		if not m then return end
		local fin = maintenant() + DUREE_VERROU
		finVerrou[index] = fin
		m:SetAttribute("Verrouillee", true)
		m:SetAttribute("FinVerrou", fin)
		aspectEntree(index, true)
		majInvite(index)
		Bus.emettre("BaseVerrouillee", index, joueur)
		local entree = partDe(index, "Entree")
		effet("Verrou", entree and entree.Position or Plan.bases[index].centre, { index = index, actif = true })
		notifier(joueur, "Base verrouillée pendant " .. DUREE_VERROU .. " s", "succes")
	end

	-- ===== apparition =====
	local function teleporter(joueur, personnage)
		local index = baseDe[joueur]
		if not index then return end
		local apparition = partDe(index, "Apparition")
		if not apparition then return end
		local position = apparition.Position + Vector3.new(0, 3, 0)
		local cf = CFrame.lookAt(position, position + Vector3.new(0, 0, versTapis(index)))
		pcall(function()
			personnage:PivotTo(cf)
		end)
	end

	local function surPersonnage(joueur, personnage)
		task.spawn(function()
			local racine = personnage:WaitForChild("HumanoidRootPart", 10)
			if not racine or not personnage.Parent or not joueur.Parent then return end
			teleporter(joueur, personnage)
			-- le moteur peut replacer le personnage sur la SpawnLocation juste après : on vérifie une fois
			task.wait(0.2)
			local index = baseDe[joueur]
			if index and personnage.Parent and racine.Parent and not dansZone(index, racine.Position) then
				teleporter(joueur, personnage)
			end
		end)
	end

	-- ===== attribution =====
	local function remiseAZero(index)
		local m = trouverModele(index)
		if m then
			m:SetAttribute("Proprietaire", 0)
			m:SetAttribute("NomProprietaire", "")
			m:SetAttribute("Verrouillee", false)
			m:SetAttribute("FinVerrou", 0)
		end
		finVerrou[index] = 0
		finRecharge[index] = 0
		aspectEntree(index, false)
		titre(index, "Base libre")
		majEmplacements(index)
		majInvite(index)
	end

	local function attribuer(joueur)
		if not joueur.Parent or baseDe[joueur] then return end
		local index = nil
		for i = 1, NB_BASES do
			if not index and not proprietaires[i] and trouverModele(i) then
				index = i
			end
		end
		if not index then
			notifier(joueur, "Aucune base libre pour le moment", "alerte")
			return
		end
		proprietaires[index] = joueur
		baseDe[joueur] = index
		local m = trouverModele(index)
		m:SetAttribute("Proprietaire", joueur.UserId)
		m:SetAttribute("NomProprietaire", joueur.DisplayName)
		m:SetAttribute("Verrouillee", false)
		m:SetAttribute("FinVerrou", 0)
		finVerrou[index] = 0
		finRecharge[index] = 0
		aspectEntree(index, false)
		titre(index, "Base de " .. joueur.DisplayName)
		majEmplacements(index)
		majInvite(index)
		joueur:SetAttribute("Base", index)
		Bus.emettre("BaseAttribuee", joueur, index)
		if joueur.Character then
			surPersonnage(joueur, joueur.Character)
		end
	end

	local function attribuerEnAttente()
		for _, j in ipairs(Players:GetPlayers()) do
			if not baseDe[j] then attribuer(j) end
		end
	end

	local function surArrivee(joueur)
		if connexions[joueur] then return end
		local liste = {}
		connexions[joueur] = liste
		table.insert(liste, joueur.CharacterAdded:Connect(function(personnage)
			surPersonnage(joueur, personnage)
		end))
		table.insert(liste, joueur:GetAttributeChangedSignal("Renaissances"):Connect(function()
			local index = baseDe[joueur]
			if index then majEmplacements(index) end
		end))
		attribuer(joueur)
	end

	local function surDepart(joueur)
		local liste = connexions[joueur]
		if liste then
			for _, c in ipairs(liste) do c:Disconnect() end
		end
		connexions[joueur] = nil
		dernierAvis[joueur] = nil
		local index = baseDe[joueur]
		if index then
			-- les écouteurs peuvent encore demander BaseDe pendant l'émission
			Bus.emettre("BaseLiberee", joueur, index)
			baseDe[joueur] = nil
			if proprietaires[index] == joueur then proprietaires[index] = nil end
			remiseAZero(index)
			task.defer(attribuerEnAttente)
		end
	end

	-- ===== répondeurs =====
	Bus.repondre("BaseDe", function(joueur)
		if not estJoueur(joueur) then return nil end
		return baseDe[joueur]
	end)
	Bus.repondre("ModeleBase", function(index)
		if not estIndex(index) then return nil end
		return trouverModele(index)
	end)
	Bus.repondre("JoueurDeBase", function(index)
		if not estIndex(index) then return nil end
		return proprietaires[index]
	end)
	Bus.repondre("DansBase", function(position, index)
		if typeof(position) ~= "Vector3" or not estIndex(index) then return false end
		return dansZone(index, position)
	end)
	Bus.repondre("BaseVerrouillee", function(index)
		if not estIndex(index) then return false end
		return estVerrouillee(index)
	end)
	Bus.repondre("NombreEmplacements", function(joueur)
		return nombreEmplacements(joueur)
	end)
	Bus.repondre("CFrameEmplacement", function(index, numero)
		if not estIndex(index) or type(numero) ~= "number" then return nil end
		numero = math.floor(numero)
		if numero < 1 or numero > EMPLACEMENTS_MAX then return nil end
		return cframeEmplacement(index, numero)
	end)

	Bus.ecouter("Renaissance", function(joueur)
		if not estJoueur(joueur) then return end
		local index = baseDe[joueur]
		if index then majEmplacements(index) end
	end)

	-- ===== invite « Verrouiller » =====
	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Verrouiller" then return end
		if not estJoueur(joueur) then return end
		local index = nil
		for i = 1, NB_BASES do
			local m = trouverModele(i)
			if not index and m and invite:IsDescendantOf(m) then index = i end
		end
		if not index then return end
		if proprietaires[index] ~= joueur then
			notifier(joueur, "Ce n'est pas ta base", "alerte")
			return
		end
		local t = maintenant()
		if (finVerrou[index] or 0) > t then
			notifier(joueur, "Ta base est déjà verrouillée", "info")
			return
		end
		if (finRecharge[index] or 0) > t then
			notifier(joueur, "Verrou en recharge : " .. math.ceil(finRecharge[index] - t) .. " s", "info")
			return
		end
		verrouiller(index, joueur)
	end)

	-- ===== joueurs =====
	for i = 1, NB_BASES do
		remiseAZero(i)
	end
	Players.PlayerAdded:Connect(surArrivee)
	Players.PlayerRemoving:Connect(surDepart)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(surArrivee, joueur)
	end

	-- ===== boucle du verrou : fin, texte de l'invite, expulsion des intrus =====
	local function repousserIntrus(index)
		local proprio = proprietaires[index]
		for _, j in ipairs(Players:GetPlayers()) do
			if j ~= proprio then
				local perso = j.Character
				local racine = perso and perso:FindFirstChild("HumanoidRootPart")
				if racine and racine:IsA("BasePart") and dansZone(index, racine.Position) then
					local cf = devantEntree(index, racine.Position.X)
					pcall(function()
						racine.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						perso:PivotTo(cf)
					end)
					local t = os.clock()
					if not dernierAvis[j] or t - dernierAvis[j] > 3 then
						dernierAvis[j] = t
						notifier(j, "Cette base est verrouillée !", "alerte")
					end
				end
			end
		end
	end

	while true do
		task.wait(PERIODE)
		local t = maintenant()
		for index = 1, NB_BASES do
			local ok, err = pcall(function()
				if (finVerrou[index] or 0) > 0 then
					if finVerrou[index] <= t then
						deverrouiller(index, true)
					else
						repousserIntrus(index)
						majInvite(index)
					end
				elseif (finRecharge[index] or 0) > 0 then
					if finRecharge[index] <= t then finRecharge[index] = 0 end
					majInvite(index)
				end
			end)
			if not ok then
				warn("[Dino] Bases, boucle du verrou : " .. tostring(err))
			end
		end
	end
end

return M
