-- Système Enclos : les dinos posés dans les Bases (emplacements, revenu, collecte, vente, restauration).
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Plan = ctx.Plan
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local E = ctx.Equilibrage
	local Reseau = ctx.Reseau
	local Style = ctx.Style

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

	-- ===== étiquette du dino : compacte en enclos, taille d'origine ailleurs =====
	-- En base, les podiums ne sont espacés que de 9 studs : l'étiquette du tapis (10 studs, 5 lignes,
	-- ~6,5 studs de haut) chevauchait ses voisines. En enclos : 7 studs de large, 1 stud par unité de
	-- ligne, sans le prix (inutile une fois acheté), visible à 50 studs. Tout est recalculé depuis les
	-- mesures d'origine (relevées une fois), donc les passages Enclos <-> Porte se composent sans dérive ;
	-- une ligne ajoutée par un autre système (« VOLÉ ! ») garde sa hauteur et pousse vers le haut.
	local LARGEUR_COMPACTE = 7
	local ECHELLE_COMPACTE = 1 / 1.3 -- hauteur de ligne 1.3 -> 1.0 stud par unité
	local DISTANCE_COMPACTE = 50
	local origines = setmetatable({}, { __mode = "k" }) -- [BillboardGui] = mesures d'origine
	local suivisEtat = {} -- [dino] = connexion Etat

	local function etiquetteDe(dino)
		local corps = corpsDe(dino)
		local gui = corps and corps:FindFirstChild("Etiquette")
		if not gui then gui = dino:FindFirstChild("Etiquette", true) end
		if gui and gui:IsA("BillboardGui") then return gui end
		return nil
	end

	local function origineDe(gui)
		local o = origines[gui]
		if o then return o end
		if gui.Size.Y.Scale <= 0 then return nil end
		o = { taille = gui.Size, decalage = gui.StudsOffset, distance = gui.MaxDistance, lignes = {} }
		for _, enfant in ipairs(gui:GetChildren()) do
			if enfant:IsA("GuiObject") and enfant.Name ~= "Vole" and enfant.Name ~= "Acheteur" then
				o.lignes[enfant] = enfant.Size
			end
		end
		origines[gui] = o
		return o
	end

	-- compact = true : format enclos ; false : format d'origine (tapis, porté par un voleur)
	local function formerEtiquette(dino, compact)
		local gui = etiquetteDe(dino)
		if not gui then return end
		if not compact and not origines[gui] then return end -- jamais compactée : rien à rendre
		local o = origineDe(gui)
		if not o then return end
		local hauteurActuelle = gui.Size.Y.Scale
		local hauteur0 = o.taille.Y.Scale
		-- hauteurs en studs : lignes d'origine (mises à l'échelle) et lignes ajoutées (inchangées)
		local hauteurs = {}
		local somme = 0
		local ajout = 0
		for _, enfant in ipairs(gui:GetChildren()) do
			if enfant:IsA("GuiObject") then
				local s = o.lignes[enfant]
				if s then
					local visible = not (compact and enfant.Name == "Prix")
					if enfant.Visible ~= visible then enfant.Visible = visible end
					if visible then
						local h = s.Y.Scale * hauteur0
						if compact then h = h * ECHELLE_COMPACTE end
						hauteurs[enfant] = h
						somme = somme + h
					end
				elseif enfant.Size.Y.Scale > 0 and hauteurActuelle > 0 then
					local h = enfant.Size.Y.Scale * hauteurActuelle
					hauteurs[enfant] = h
					somme = somme + h
					ajout = ajout + h
				end
			end
		end
		if somme <= 0 then return end
		for enfant, h in pairs(hauteurs) do
			local s = enfant.Size
			enfant.Size = UDim2.new(s.X.Scale, s.X.Offset, h / somme, s.Y.Offset)
		end
		-- le bas de l'étiquette reste où il était : elle rétrécit / grandit vers le haut
		local bas = o.decalage.Y - hauteur0 / 2
		local largeur = o.taille.X.Scale
		if compact then largeur = LARGEUR_COMPACTE end
		gui.Size = UDim2.new(largeur, o.taille.X.Offset, somme, o.taille.Y.Offset)
		gui.StudsOffset = Vector3.new(o.decalage.X, bas + somme / 2, o.decalage.Z)
		if compact then
			gui.MaxDistance = DISTANCE_COMPACTE
		else
			gui.MaxDistance = o.distance
		end
		gui:SetAttribute("Compacte", compact)
	end

	-- suit l'état : compacte en « Enclos », taille d'origine dès qu'il repasse « Porte » ou « Tapis »
	local function suivreEtat(dino)
		if suivisEtat[dino] then return end
		local ok, connexion = pcall(function()
			return dino:GetAttributeChangedSignal("Etat"):Connect(function()
				local etat = dino:GetAttribute("Etat")
				if etat == "Enclos" then
					pcall(formerEtiquette, dino, true)
				elseif etat == "Porte" or etat == "Tapis" or etat == "EnRoute" then
					pcall(formerEtiquette, dino, false)
				end
			end)
		end)
		if ok and connexion then suivisEtat[dino] = connexion end
	end

	local function surveiller(dino)
		suivreEtat(dino)
		if surveilles[dino] then return end
		local ok, connexion = pcall(function()
			return dino.Destroying:Connect(function()
				oublier(dino)
				local c = suivisEtat[dino]
				if c then
					pcall(function() c:Disconnect() end)
					suivisEtat[dino] = nil
				end
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

	local ajusterEmplacement
	-- ===== un dino tient sur son podium : centré dessus, tourné vers l'allée, réduit une fois s'il est trop grand =====
	local LARGEUR_EMPLACEMENT = 6.4  -- largeur d'une place dans la rangée (pas : 6,8) : seule vraie contrainte
	local LONGUEUR_EMPLACEMENT = 13  -- plateau de 12 de long : les pattes avant et arrière restent dessus

	local function boiteLocale(dino)
		local pivot = dino:GetPivot()
		local mn, mx
		for _, p in ipairs(dino:GetDescendants()) do
			if p:IsA("BasePart") and p.Transparency < 1 then
				local cfp = pivot:ToObjectSpace(p.CFrame)
				local d = p.Size / 2
				for _, sx in ipairs({ -1, 1 }) do
					for _, sy in ipairs({ -1, 1 }) do
						for _, sz in ipairs({ -1, 1 }) do
							local c = cfp * Vector3.new(sx * d.X, sy * d.Y, sz * d.Z)
							if mn then
								mn = Vector3.new(math.min(mn.X, c.X), math.min(mn.Y, c.Y), math.min(mn.Z, c.Z))
								mx = Vector3.new(math.max(mx.X, c.X), math.max(mx.Y, c.Y), math.max(mx.Z, c.Z))
							else
								mn, mx = c, c
							end
						end
					end
				end
			end
		end
		return mn, mx
	end

	-- renvoie la CFrame du pivot : le dino (qui regarde vers -Z local) est centré sur le plateau du podium
	ajusterEmplacement = function(dino, cf)
		local mn, mx = boiteLocale(dino)
		if not mn then return cf end
		local largeur, longueur = mx.X - mn.X, mx.Z - mn.Z
		local f = math.min(1, LARGEUR_EMPLACEMENT / math.max(largeur, 0.1), LONGUEUR_EMPLACEMENT / math.max(longueur, 0.1))
		if f < 0.999 then
			local okE = pcall(function() dino:ScaleTo(dino:GetScale() * f) end)
			if okE then
				-- remesure après la mise à l'échelle (le pivot peut bouger selon la façon dont elle est appliquée)
				local mn2, mx2 = boiteLocale(dino)
				if mn2 then mn, mx = mn2, mx2 end
			end
		end
		-- centré sur le podium (le centre de sa boîte, pas son pivot, tombe au milieu du plateau)
		local centreX = (mn.X + mx.X) / 2
		local centreZ = (mn.Z + mx.Z) / 2
		-- pieds posés exactement sur le plateau (le bas de la boîte au niveau du dessus du podium)
		return cf * CFrame.new(-centreX, -mn.Y, -centreZ)
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
		local okAjuste, cfAjuste = pcall(ajusterEmplacement, dino, cf)
		if okAjuste and cfAjuste then cf = cfAjuste end
		local ok = pcall(function() dino:PivotTo(cf) end)
		if not ok then return false end
		pcall(formerEtiquette, dino, true)

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

	-- ===== étiquettes flottantes (style simulateur soigné) =====
	-- pastilles sombres en dégradé, liseré vert, reflet brillant, médaillon doré « 💰 » ;
	-- elles rebondissent quand le montant grossit (au plus une fois toutes les ECART_ANIMATION secondes)
	local VERT = Style.couleurs.argent
	local VERT_CLAIR = Charte.lumiere(VERT)
	local VERT_FONCE = Charte.ombre(Charte.ombre(VERT))
	local OR = Style.boutons.jaune
	local ECART_ANIMATION = 2.5
	local HALO_REPOS = 0.5  -- halo de la dalle de collecte quand il n'y a rien à encaisser
	local HALO_PLEIN = 1.2  -- quand de l'argent attend
	local SAUT = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local RETOUR = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local FONDU_HALO = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local animations = {} -- [BillboardGui] = { echelle, trait, medaillon, texte, dernier }

	local function arrondir(gui)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0.5, 0)
		c.Parent = gui
		return c
	end

	-- construit dans `gui` un conteneur (props.Position, props.Size, props.AnchorPoint) avec la pastille ;
	-- props.icone : médaillon doré 💰 à gauche ; props.nom : nom du TextLabel du montant. Renvoie la fiche d'animation.
	local function pastille(gui, props)
		local conteneur = Instance.new("Frame")
		conteneur.Name = "Contenu"
		conteneur.BackgroundTransparency = 1
		conteneur.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
		conteneur.Position = props.Position or UDim2.fromScale(0.5, 0.5)
		conteneur.Size = props.Size or UDim2.fromScale(1, 1)
		local echelle = Instance.new("UIScale")
		echelle.Name = "Echelle"
		echelle.Parent = conteneur

		local gauche = 0
		if props.icone then gauche = 0.13 end
		local fond = Instance.new("Frame")
		fond.Name = "Pastille"
		fond.AnchorPoint = Vector2.new(1, 0.5)
		fond.Position = UDim2.fromScale(1, 0.5)
		fond.Size = UDim2.fromScale(1 - gauche, 0.8)
		fond.BackgroundColor3 = Color3.new(1, 1, 1)
		fond.BorderSizePixel = 0
		arrondir(fond)
		Style.degrade(fond, Style.couleurs.fondHaut, Style.couleurs.fond).Name = "Fond"
		local trait = Style.bordure(fond, 3, VERT_FONCE)

		-- reflet brillant sur la moitié haute
		local reflet = Instance.new("Frame")
		reflet.Name = "Reflet"
		reflet.AnchorPoint = Vector2.new(0.5, 0)
		reflet.Position = UDim2.fromScale(0.5, 0.08)
		reflet.Size = UDim2.fromScale(0.9, 0.42)
		reflet.BackgroundColor3 = Color3.new(1, 1, 1)
		reflet.BackgroundTransparency = 0.8
		reflet.BorderSizePixel = 0
		arrondir(reflet)
		local fonduReflet = Instance.new("UIGradient")
		fonduReflet.Rotation = 90
		fonduReflet.Transparency = NumberSequence.new(0.15, 1)
		fonduReflet.Parent = reflet
		reflet.Parent = fond

		-- montant : vert vif, léger dégradé clair -> vert, cerné de noir
		local debut = 0.05
		if props.icone then debut = 0.25 end
		local texte = Style.texte(fond, {
			Name = props.nom or "Texte",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(debut, 0.5),
			Size = UDim2.fromScale(0.95 - debut, 0.84),
			Text = Charte.argent(0),
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			contour = 3,
		})
		Style.degrade(texte, VERT_CLAIR, VERT).Name = "Teinte"

		local medaillon = nil
		if props.icone then
			medaillon = Instance.new("Frame")
			medaillon.Name = "Medaillon"
			medaillon.AnchorPoint = Vector2.new(0.5, 0.5)
			medaillon.Position = UDim2.fromScale(0.155, 0.5)
			medaillon.Size = UDim2.fromScale(1, 1)
			medaillon.SizeConstraint = Enum.SizeConstraint.RelativeYY
			medaillon.BackgroundColor3 = Color3.new(1, 1, 1)
			medaillon.BorderSizePixel = 0
			medaillon.ZIndex = 3
			arrondir(medaillon)
			Style.degrade(medaillon, OR[1], OR[2]).Name = "Fond"
			Style.bordure(medaillon, 3)
			Style.texte(medaillon, {
				Name = "Icone",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.52),
				Size = UDim2.fromScale(0.72, 0.72),
				Text = "💰",
				ZIndex = 4,
				contour = 1.5,
			})
			medaillon.Parent = conteneur
		end
		-- la pastille passe sous le médaillon (ZIndex), mais après lui dans l'arbre : icône lue en premier
		fond.Parent = conteneur

		conteneur.Parent = gui
		local fiche = { echelle = echelle, trait = trait, medaillon = medaillon, texte = texte, dernier = 0 }
		animations[gui] = fiche
		return fiche
	end

	-- rebond de la pastille, éclair vert du liseré, médaillon qui bascule (répliqué aux clients)
	local function animer(fiche, force, toujours)
		if not fiche then return end
		local maintenant = os.clock()
		if not toujours and maintenant - fiche.dernier < ECART_ANIMATION then return end
		fiche.dernier = maintenant
		pcall(function()
			fiche.echelle.Scale = force or 1.15
			TweenService:Create(fiche.echelle, SAUT, { Scale = 1 }):Play()
			fiche.trait.Color = VERT_CLAIR
			TweenService:Create(fiche.trait, RETOUR, { Color = VERT_FONCE }):Play()
			if fiche.medaillon then
				fiche.medaillon.Rotation = -16
				TweenService:Create(fiche.medaillon, SAUT, { Rotation = 0 }):Play()
			end
		end)
	end

	-- au-dessus de la dalle Collecte : « 💰 COLLECTER » + total à encaisser dans une pastille ; halo vert sur la dalle
	local etiquettesCollecte = {} -- [index de Base] = { gui, total = TextLabel, fiche, halo = PointLight, valeur = n }

	local function etiquetterCollecte(index, dalle)
		for _, nom in ipairs({ "EtiquetteCollecte", "Halo" }) do
			local ancien = dalle:FindFirstChild(nom)
			if ancien then pcall(function() ancien:Destroy() end) end
		end
		local gui = Instance.new("BillboardGui")
		gui.Name = "EtiquetteCollecte"
		gui.Size = UDim2.new(9, 0, 3.6, 0)
		gui.StudsOffset = Vector3.new(0, 4.5, 0)
		gui.MaxDistance = 110
		gui.LightInfluence = 0
		gui.ClipsDescendants = false
		local titre = Style.texte(gui, {
			Name = "Titre",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.48),
			Text = "💰 COLLECTER",
			TextColor3 = Color3.new(1, 1, 1),
			titre = true,
			contour = 4,
		})
		Style.degrade(titre, VERT_CLAIR, VERT).Name = "Teinte"
		local fiche = pastille(gui, {
			nom = "Total",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.62, 0.5),
		})
		gui.Adornee = dalle
		gui.Parent = dalle

		-- halo discret : plus vif quand de l'argent attend, éclair à la collecte
		local halo = Instance.new("PointLight")
		halo.Name = "Halo"
		halo.Color = VERT
		halo.Range = 10
		halo.Brightness = HALO_REPOS
		halo.Shadows = false
		halo.Parent = dalle

		etiquettesCollecte[index] = { gui = gui, total = fiche.texte, fiche = fiche, halo = halo, valeur = 0 }
	end

	local function regleHalo(e, cible)
		if not e.halo or not e.halo.Parent or e.cibleHalo == cible then return end
		e.cibleHalo = cible
		pcall(function()
			TweenService:Create(e.halo, FONDU_HALO, { Brightness = cible }):Play()
		end)
	end

	local function afficherTotaux(totaux)
		for index, e in pairs(etiquettesCollecte) do
			if not e.gui.Parent then
				etiquettesCollecte[index] = nil
				animations[e.gui] = nil
			else
				local entier = math.floor(totaux[index] or 0)
				if entier ~= e.valeur then
					local precedent = e.valeur
					e.valeur = entier
					e.total.Text = Charte.argent(entier)
					if entier > precedent then animer(e.fiche, 1.12) end
				end
				if entier > 0 then regleHalo(e, HALO_PLEIN) else regleHalo(e, HALO_REPOS) end
			end
		end
	end

	-- juste après une collecte : total remis à zéro tout de suite, rebond et éclair du halo
	local function saluerCollecte(index)
		local e = etiquettesCollecte[index]
		if not e or not e.gui.Parent then return end
		e.valeur = 0
		e.total.Text = Charte.argent(0)
		animer(e.fiche, 1.22, true)
		if e.halo and e.halo.Parent then
			e.cibleHalo = HALO_REPOS
			e.halo.Brightness = 3
			TweenService:Create(e.halo, FONDU_HALO, { Brightness = HALO_REPOS }):Play()
		end
	end

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
		local index = Bus.demander("BaseDe", joueur)
		if type(index) == "number" then pcall(saluerCollecte, index) end
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
		pcall(etiquetterCollecte, index, dalle)
		-- une base libre n'affiche que son statut : ni « COLLECTER », ni « VERROUILLER », ni halo
		local function majOccupation()
			local occupee = nombre(modele:GetAttribute("Proprietaire"), 0) ~= 0
			local e = etiquettesCollecte[index]
			if e then
				if e.gui.Parent and e.gui.Enabled ~= occupee then e.gui.Enabled = occupee end
				if e.halo and e.halo.Parent and e.halo.Enabled ~= occupee then e.halo.Enabled = occupee end
			end
			local bouton = modele:FindFirstChild("BoutonVerrou")
			local verrou = bouton and bouton:FindFirstChild("EtiquetteVerrou")
			if not verrou then verrou = modele:FindFirstChild("EtiquetteVerrou", true) end
			if verrou and verrou:IsA("BillboardGui") and verrou.Enabled ~= occupee then
				verrou.Enabled = occupee
			end
		end
		pcall(majOccupation)
		modele:GetAttributeChangedSignal("Proprietaire"):Connect(function()
			pcall(majOccupation)
		end)
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

	-- ===== stock au-dessus des podiums : pastille « 💰 $1,2K » (médaillon doré + montant vert cerné) =====
	local function panneauDe(podium)
		local gui = panneaux[podium]
		if gui and gui.Parent == podium and animations[gui] then return gui end
		if gui then
			animations[gui] = nil
			pcall(function() gui:Destroy() end)
		end
		local ancien = podium:FindFirstChild("Stock")
		if ancien then pcall(function() ancien:Destroy() end) end
		-- petite pastille posée devant le plateau (pas à travers les murs : AlwaysOnTop = false)
		gui = Instance.new("BillboardGui")
		gui.Name = "Stock"
		gui.Size = UDim2.new(4.2, 0, 1.3, 0)
		gui.StudsOffset = Vector3.new(0, 0, 0)
		gui.MaxDistance = 40
		gui.AlwaysOnTop = false
		gui.LightInfluence = 0
		gui.ClipsDescendants = false
		gui.Enabled = false
		local fiche = pastille(gui, { icone = true, nom = "Texte" })
		fiche.texte.Text = ""
		fiche.texte:SetAttribute("Valeur", 0)
		gui.Adornee = podium
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
		-- devant le podium (côté regard du dino), à hauteur du plateau : ne masque jamais le dino exposé
		local cf = pivotDe(dino)
		local avant = Vector3.new(0, 0, 0)
		if cf then
			local regard = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
			if regard.Magnitude > 0.01 then
				avant = regard.Unit * (math.max(podium.Size.X, podium.Size.Z) / 2)
			end
		end
		gui.StudsOffsetWorldSpace = avant * 1.15 + Vector3.new(0, podium.Size.Y / 2 + 0.2, 0)
		gui.Enabled = true
		local fiche = animations[gui]
		local texte = fiche and fiche.texte
		if texte then
			local entier = math.floor(stock)
			local valeur = Charte.argent(entier)
			if texte.Text ~= valeur then
				local precedent = nombre(texte:GetAttribute("Valeur"), 0)
				texte.Text = valeur
				texte:SetAttribute("Valeur", entier)
				if entier > precedent then animer(fiche, 1.15) end
			end
		end
		return podium
	end

	-- ===== revenu : boucle d'une seconde =====
	local function tour(dt)
		local multiplicateurs = {}
		local revenus = {}
		local modeles = {}
		local actifs = {}
		local totaux = {} -- [index de Base] = stock total à encaisser
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
					local base = dino:GetAttribute("Base")
					if type(base) == "number" then totaux[base] = (totaux[base] or 0) + stock end
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
		pcall(afficherTotaux, totaux)
		-- podiums vides : on cache leur panneau
		for podium, gui in pairs(panneaux) do
			if not podium.Parent or gui.Parent ~= podium then
				panneaux[podium] = nil
				animations[gui] = nil
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
