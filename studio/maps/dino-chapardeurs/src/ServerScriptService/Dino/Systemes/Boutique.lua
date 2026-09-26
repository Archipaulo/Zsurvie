-- Systemes/Boutique : achats d'objets payés en argent du jeu (Remote « Acheter ») et effets permanents.
-- Bottes : vitesse de marche de base relevée (attribut joueur « VitesseBase », lu aussi par les autres systèmes).
-- Aimant : collecte la Base à distance à intervalle régulier.
-- BatteOr et Radar : simples attributs Objet_<nom>, lus par Systemes/Batte et l'interface.
-- L'invite « Boutique » du Comptoir est ouverte côté client : aucune invite à traiter ici.
local Players = game:GetService("Players")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Charte = ctx.Charte
	local E = ctx.Equilibrage

	local CATALOGUE = E.boutique or {}
	local VITESSE_DEFAUT = 16
	local INTERVALLE_ACHAT = 0.5
	local INTERVALLE_AIMANT = 10
	if CATALOGUE.Aimant and tonumber(CATALOGUE.Aimant.intervalle) then
		INTERVALLE_AIMANT = math.max(1, tonumber(CATALOGUE.Aimant.intervalle))
	end

	local connexions = {}    -- [joueur] = liste de connexions
	local dernierAchat = {}  -- [joueur] = os.clock() du dernier achat tenté
	local enCours = {}       -- [joueur] = true pendant un achat (pas de double paiement)
	local derniereAimant = {} -- [joueur] = os.clock() de la dernière collecte à distance

	-- ===== utilitaires =====
	local function estJoueur(joueur)
		return typeof(joueur) == "Instance" and joueur:IsA("Player") and joueur.Parent ~= nil
	end

	local function nombre(valeur, defaut)
		if type(valeur) == "number" and valeur == valeur then return valeur end
		return defaut
	end

	local function notifier(joueur, texte, genre)
		if not estJoueur(joueur) then return end
		pcall(function()
			Reseau.Notification:FireClient(joueur, texte, genre)
		end)
	end

	-- montant au format du jeu (« $2K ») : la boîte à outils Style d'abord, la Charte en secours
	local Style = ctx.Style
	local function montantTexte(n)
		local formater = (Style and Style.argent) or Charte.argent
		local ok, texte = pcall(formater, n)
		if ok and type(texte) == "string" then return texte end
		return "$" .. tostring(math.floor(n))
	end

	-- accord du participe selon l'objet (« Bottes de course achetées ! », « Batte dorée achetée ! »)
	local ACCORDS = { Bottes = "achetées", BatteOr = "achetée" }
	local function participe(nom)
		local objet = CATALOGUE[nom]
		if type(objet) == "table" and type(objet.accord) == "string" then return objet.accord end
		return ACCORDS[nom] or "acheté"
	end

	-- ce qu'il manque au joueur pour s'offrir un prix (au moins 1)
	local function manque(joueur, prix)
		local argent = nombre(joueur:GetAttribute("Argent"), 0)
		return math.max(1, math.ceil(prix - argent))
	end

	local function possede(joueur, nom)
		return joueur:GetAttribute("Objet_" .. nom) == true
	end

	local function humanoidDe(joueur)
		local perso = joueur.Character
		if not perso or not perso.Parent then return nil end
		local humanoid = perso:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return nil end
		return humanoid
	end

	-- ===== Bottes : vitesse de base =====
	local function vitesseBase(joueur)
		local vitesse = VITESSE_DEFAUT
		if possede(joueur, "Bottes") and CATALOGUE.Bottes then
			vitesse = vitesse + nombre(tonumber(CATALOGUE.Bottes.vitesse), 0)
		end
		return vitesse
	end

	local function estNormal(joueur)
		local porte = joueur:GetAttribute("Porte")
		if porte ~= nil and porte ~= "" then return false end
		if joueur:GetAttribute("Etourdi") == true then return false end
		return true
	end

	-- pose l'attribut et applique la vitesse seulement si le joueur n'est ni porteur ni étourdi
	local function appliquerVitesse(joueur)
		if not estJoueur(joueur) then return end
		local vitesse = vitesseBase(joueur)
		pcall(function() joueur:SetAttribute("VitesseBase", vitesse) end)
		if not estNormal(joueur) then return end
		local humanoid = humanoidDe(joueur)
		if humanoid and humanoid.WalkSpeed ~= vitesse then
			pcall(function() humanoid.WalkSpeed = vitesse end)
		end
	end

	-- retour à la normale (fin de vol, fin d'étourdissement) : on laisse d'abord les autres systèmes
	-- rendre leur vitesse mémorisée, puis on remet la vitesse de base
	local function apresRetourNormal(joueur)
		task.delay(0.1, function()
			if estJoueur(joueur) and estNormal(joueur) then
				appliquerVitesse(joueur)
			end
		end)
	end

	-- ===== Aimant : collecte à distance =====
	local function collecterADistance(joueur)
		if not estJoueur(joueur) or not possede(joueur, "Aimant") then return end
		local liste = Bus.demander("DinosDe", joueur)
		if type(liste) ~= "table" then return end
		local uid = joueur.UserId
		local retenus = {}
		local somme = 0
		for _, dino in ipairs(liste) do
			if typeof(dino) == "Instance" and dino.Parent
				and dino:GetAttribute("Proprietaire") == uid and dino:GetAttribute("Etat") == "Enclos" then
				local stock = nombre(dino:GetAttribute("Stock"), 0)
				if stock > 0 then
					somme = somme + stock
					table.insert(retenus, { dino = dino, stock = stock })
				end
			end
		end
		local montant = math.floor(somme)
		if montant < 1 then return end
		for _, d in ipairs(retenus) do
			pcall(function() d.dino:SetAttribute("Stock", 0) end)
		end
		local total = Bus.demander("AjouterArgent", joueur, montant, "Aimant")
		if total == nil then
			-- l'économie n'a pas répondu : on rend les stocks
			for _, d in ipairs(retenus) do
				if d.dino.Parent then
					pcall(function()
						d.dino:SetAttribute("Stock", nombre(d.dino:GetAttribute("Stock"), 0) + d.stock)
					end)
				end
			end
			return
		end
		-- les centimes restent dans le premier dino
		local reste = somme - montant
		local premier = retenus[1].dino
		if reste > 0 and premier.Parent then
			pcall(function()
				premier:SetAttribute("Stock", nombre(premier:GetAttribute("Stock"), 0) + reste)
			end)
		end
		-- petit retour visuel pour le seul joueur concerné
		local perso = joueur.Character
		local racine = perso and perso:FindFirstChild("HumanoidRootPart")
		if racine then
			pcall(function()
				Reseau.Effet:FireClient(joueur, "Collecte", racine.Position, { montant = montant, aimant = true })
			end)
		end
	end

	-- ===== achat =====
	local function acheter(joueur, nom)
		if not estJoueur(joueur) then return end
		if type(nom) ~= "string" or #nom > 40 then return end
		local objet = CATALOGUE[nom]
		if type(objet) ~= "table" then return end
		if enCours[joueur] then return end

		local maintenant = os.clock()
		local dernier = dernierAchat[joueur]
		if dernier and maintenant - dernier < INTERVALLE_ACHAT then return end
		dernierAchat[joueur] = maintenant
		if Bus.demander("AutoriserAction", joueur, "Boutique", INTERVALLE_ACHAT) == false then return end

		local libelle = tostring(objet.nom or nom)
		if possede(joueur, nom) then
			notifier(joueur, "⭐ Tu as déjà : " .. libelle .. " !", "info")
			return
		end
		if joueur:GetAttribute("DonneesChargees") ~= true then
			notifier(joueur, "⏳ Chargement… réessaie vite !", "alerte")
			return
		end

		local prix = math.max(0, math.floor(nombre(tonumber(objet.prix), 0)))
		enCours[joueur] = true
		local paye = true
		if prix > 0 then
			paye = Bus.demander("DepenserArgent", joueur, prix) == true
		end
		if not paye then
			enCours[joueur] = nil
			notifier(joueur, "❌ Il te manque " .. montantTexte(manque(joueur, prix)) .. " !", "alerte")
			return
		end
		if not joueur.Parent then
			enCours[joueur] = nil
			return
		end

		pcall(function() joueur:SetAttribute("Objet_" .. nom, true) end)
		enCours[joueur] = nil
		Bus.emettre("ObjetAchete", joueur, nom)
		notifier(joueur, "✅ " .. libelle .. " " .. participe(nom) .. " !", "succes")

		if nom == "Bottes" then
			appliquerVitesse(joueur)
		elseif nom == "Aimant" then
			derniereAimant[joueur] = os.clock()
			task.spawn(function()
				local ok, err = pcall(collecterADistance, joueur)
				if not ok then warn("[Dino] Boutique (aimant) : " .. tostring(err)) end
			end)
		end
	end

	Reseau.Acheter.OnServerEvent:Connect(function(joueur, nom)
		local ok, err = pcall(acheter, joueur, nom)
		if not ok then
			enCours[joueur] = nil
			warn("[Dino] Boutique : " .. tostring(err))
		end
	end)

	-- ===== joueurs =====
	local function surPersonnage(joueur, perso)
		local humanoid = perso:FindFirstChildOfClass("Humanoid") or perso:WaitForChild("Humanoid", 10)
		if not humanoid or not joueur.Parent or joueur.Character ~= perso then return end
		appliquerVitesse(joueur)
	end

	local function preparer(joueur)
		if connexions[joueur] then return end
		local liste = {}
		connexions[joueur] = liste
		pcall(function() joueur:SetAttribute("VitesseBase", vitesseBase(joueur)) end)

		table.insert(liste, joueur.CharacterAdded:Connect(function(perso)
			task.spawn(function()
				local ok, err = pcall(surPersonnage, joueur, perso)
				if not ok then warn("[Dino] Boutique (personnage) : " .. tostring(err)) end
			end)
		end))
		-- objets restaurés par les sauvegardes ou achetés : la vitesse suit
		table.insert(liste, joueur:GetAttributeChangedSignal("Objet_Bottes"):Connect(function()
			appliquerVitesse(joueur)
		end))
		table.insert(liste, joueur:GetAttributeChangedSignal("Porte"):Connect(function()
			if estNormal(joueur) then apresRetourNormal(joueur) end
		end))
		table.insert(liste, joueur:GetAttributeChangedSignal("Etourdi"):Connect(function()
			if estNormal(joueur) then apresRetourNormal(joueur) end
		end))

		if joueur.Character then
			task.spawn(function()
				pcall(surPersonnage, joueur, joueur.Character)
			end)
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
		dernierAchat[joueur] = nil
		enCours[joueur] = nil
		derniereAimant[joueur] = nil
	end)

	-- ===== boucle de l'Aimant =====
	while true do
		task.wait(1)
		local maintenant = os.clock()
		for _, joueur in ipairs(Players:GetPlayers()) do
			if connexions[joueur] and possede(joueur, "Aimant") then
				local derniere = derniereAimant[joueur]
				if not derniere then
					derniereAimant[joueur] = maintenant
				elseif maintenant - derniere >= INTERVALLE_AIMANT then
					derniereAimant[joueur] = maintenant
					local ok, err = pcall(collecterADistance, joueur)
					if not ok then warn("[Dino] Boutique (aimant) : " .. tostring(err)) end
				end
			end
		end
	end
end

return M
