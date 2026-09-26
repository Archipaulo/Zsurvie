-- Système Classement : leaderstats des joueurs, meilleur revenu du serveur et tableau d'honneur sur la Place.
local Players = game:GetService("Players")

local M = {}

local PERIODE_MEILLEUR = 2   -- secondes entre deux calculs de Etat.MeilleurRevenu
local PERIODE_TABLEAU = 5    -- secondes entre deux mises à jour du tableau d'honneur
local NB_LIGNES = 5          -- top 5 par revenu/s

-- dimensions du tableau (studs)
local LARGEUR = 12
local HAUTEUR = 8
local EPAISSEUR = 0.6
local HAUT_BAS = 1.5         -- hauteur du bas du panneau au-dessus du sol
local PIXELS = 50            -- pixels par stud du SurfaceGui

local function nombre(v)
	local n = tonumber(v)
	if n == nil or n ~= n then return 0 end
	return n
end

-- Charte.argent sans le « $ » final
local function argentSansDollar(ctx, n)
	local texte = ctx.Charte.argent(nombre(n))
	texte = string.gsub(texte, "%s*%$$", "")
	return texte
end

-- ===== leaderstats =====
local connexions = {}

local function valeur(dossier, classe, nom)
	local v = dossier:FindFirstChild(nom)
	if v and not v:IsA(classe) then
		v:Destroy()
		v = nil
	end
	if not v then
		v = Instance.new(classe)
		v.Name = nom
		v.Parent = dossier
	end
	return v
end

local function deconnecter(joueur)
	local liste = connexions[joueur]
	if liste then
		for _, c in ipairs(liste) do
			pcall(function() c:Disconnect() end)
		end
	end
	connexions[joueur] = nil
end

local function preparerJoueur(ctx, joueur)
	if connexions[joueur] then return end
	local ok, err = pcall(function()
		local stats = joueur:FindFirstChild("leaderstats")
		if stats and not stats:IsA("Folder") then
			stats:Destroy()
			stats = nil
		end
		if not stats then
			stats = Instance.new("Folder")
			stats.Name = "leaderstats"
		end
		-- l'ordre de création fixe l'ordre des colonnes
		local argent = valeur(stats, "StringValue", "Argent")
		local vols = valeur(stats, "IntValue", "Vols")
		local renaissances = valeur(stats, "IntValue", "Renaissances")
		stats.Parent = joueur

		local function majArgent()
			argent.Value = argentSansDollar(ctx, joueur:GetAttribute("Argent"))
		end
		local function majVols()
			vols.Value = math.floor(nombre(joueur:GetAttribute("Vols")))
		end
		local function majRenaissances()
			renaissances.Value = math.floor(nombre(joueur:GetAttribute("Renaissances")))
		end
		majArgent()
		majVols()
		majRenaissances()

		local liste = {}
		table.insert(liste, joueur:GetAttributeChangedSignal("Argent"):Connect(function() pcall(majArgent) end))
		table.insert(liste, joueur:GetAttributeChangedSignal("Vols"):Connect(function() pcall(majVols) end))
		table.insert(liste, joueur:GetAttributeChangedSignal("Renaissances"):Connect(function() pcall(majRenaissances) end))
		connexions[joueur] = liste
	end)
	if not ok then
		warn("[Dino] Classement : leaderstats de " .. tostring(joueur.Name) .. " : " .. tostring(err))
	end
end

-- joueurs présents triés par revenu/s décroissant
local function joueursParRevenu()
	local liste = {}
	for _, joueur in ipairs(Players:GetPlayers()) do
		if joueur.Parent then
			table.insert(liste, { joueur = joueur, revenu = nombre(joueur:GetAttribute("RevenuParSeconde")) })
		end
	end
	table.sort(liste, function(a, b)
		if a.revenu ~= b.revenu then return a.revenu > b.revenu end
		return a.joueur.Name < b.joueur.Name
	end)
	return liste
end

local function majMeilleurRevenu(ctx)
	local meilleur = 0
	for _, joueur in ipairs(Players:GetPlayers()) do
		local r = nombre(joueur:GetAttribute("RevenuParSeconde"))
		if r > meilleur then meilleur = r end
	end
	if ctx.Etat:GetAttribute("MeilleurRevenu") ~= meilleur then
		ctx.Etat:SetAttribute("MeilleurRevenu", meilleur)
	end
end

-- ===== tableau d'honneur =====
local function construireTableau(ctx)
	local C = ctx.Charte
	local O = ctx.Outils
	local ancien = ctx.racine:FindFirstChild("Classement")
	if ancien then ancien:Destroy() end
	local dossier = O.dossier(ctx.racine, "Classement")
	local modele = O.modele(dossier, "TableauHonneur")

	-- au bord ouest de la Place, tourné vers le centre
	local centre = ctx.Plan.place.centre
	local pied = centre + Vector3.new(-17, 0, -6)
	local cible = Vector3.new(centre.X, pied.Y, centre.Z)
	-- léger recul vers le centre pour rester dans le disque de la Place (r20)
	local vers = cible - pied
	if vers.Magnitude > 0.01 then pied = pied + vers.Unit * 0.8 end
	local orientation = CFrame.lookAt(pied, cible)
	local function local_(x, y, z)
		return orientation * CFrame.new(x, y, z)
	end

	local yCentre = HAUT_BAS + HAUTEUR / 2
	local hautPoteau = HAUT_BAS + HAUTEUR + 0.5

	-- socle et poteaux
	O.bloc(modele, {
		Name = "Socle",
		Size = Vector3.new(LARGEUR + 1, 0.4, 1.2),
		CFrame = local_(0, 0.2, 0.4),
		Color = C.pierre,
	})
	O.bloc(modele, {
		Name = "PoteauG",
		Size = Vector3.new(0.8, hautPoteau, 0.8),
		CFrame = local_(-(LARGEUR / 2 + 0.2), hautPoteau / 2, 0.4),
		Color = C.bois,
	})
	O.bloc(modele, {
		Name = "PoteauD",
		Size = Vector3.new(0.8, hautPoteau, 0.8),
		CFrame = local_(LARGEUR / 2 + 0.2, hautPoteau / 2, 0.4),
		Color = C.bois,
	})
	-- cadre derrière le panneau
	O.bloc(modele, {
		Name = "Cadre",
		Size = Vector3.new(LARGEUR + 0.6, HAUTEUR + 0.6, 0.3),
		CFrame = local_(0, yCentre, 0.55),
		Color = C.terre,
	})
	local panneau = O.bloc(modele, {
		Name = "Panneau",
		Size = Vector3.new(LARGEUR, HAUTEUR, EPAISSEUR),
		CFrame = local_(0, yCentre, 0.1),
		Color = C.nuit,
	})
	-- fronton doré lumineux
	local fronton = O.bloc(modele, {
		Name = "Fronton",
		Size = Vector3.new(LARGEUR * 0.6, 0.8, 0.8),
		CFrame = local_(0, HAUT_BAS + HAUTEUR + 0.7, 0.4),
		Color = C.dore,
		Material = Enum.Material.Neon,
	})
	O.lumiere(fronton, { Range = 10, Brightness = 0.8, Color = C.dore })
	for _, p in ipairs(modele:GetChildren()) do
		if p:IsA("BasePart") then
			p.CanCollide = p.Name == "Socle" or p.Name == "PoteauG" or p.Name == "PoteauD"
		end
	end
	modele.PrimaryPart = panneau

	-- interface du panneau (face avant, vers la Place)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Affiche"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = PIXELS
	gui.LightInfluence = 0
	gui.Parent = panneau

	local titre = Instance.new("TextLabel")
	titre.Name = "Titre"
	titre.BackgroundTransparency = 1
	titre.Position = UDim2.fromScale(0.04, 0.03)
	titre.Size = UDim2.fromScale(0.92, 0.17)
	titre.Font = C.police
	titre.TextScaled = true
	titre.TextColor3 = C.dore
	titre.TextStrokeColor3 = C.encre
	titre.TextStrokeTransparency = 0.4
	titre.Text = "Tableau d'honneur"
	titre.Parent = gui

	local sousTitre = Instance.new("TextLabel")
	sousTitre.Name = "SousTitre"
	sousTitre.BackgroundTransparency = 1
	sousTitre.Position = UDim2.fromScale(0.04, 0.2)
	sousTitre.Size = UDim2.fromScale(0.92, 0.07)
	sousTitre.Font = C.policeTexte
	sousTitre.TextScaled = true
	sousTitre.TextColor3 = C.creme
	sousTitre.TextTransparency = 0.25
	sousTitre.Text = "Les meilleurs revenus par seconde"
	sousTitre.Parent = gui

	local couleursRang = { C.dore, C.gemme, C.lave }
	local lignes = {}
	local hautLigne = 0.7 / NB_LIGNES
	for i = 1, NB_LIGNES do
		local fond = Instance.new("Frame")
		fond.Name = "Ligne" .. i
		fond.BorderSizePixel = 0
		fond.BackgroundColor3 = C.encre
		fond.BackgroundTransparency = 0.35
		fond.Position = UDim2.fromScale(0.04, 0.28 + (i - 1) * hautLigne)
		fond.Size = UDim2.new(0.92, 0, hautLigne, -6)
		fond.Parent = gui
		local coin = Instance.new("UICorner")
		coin.CornerRadius = UDim.new(0, 10)
		coin.Parent = fond

		local couleur = couleursRang[i] or C.creme

		local rang = Instance.new("TextLabel")
		rang.Name = "Rang"
		rang.BackgroundTransparency = 1
		rang.Position = UDim2.fromScale(0.02, 0.1)
		rang.Size = UDim2.fromScale(0.1, 0.8)
		rang.Font = C.police
		rang.TextScaled = true
		rang.TextColor3 = couleur
		rang.Text = tostring(i)
		rang.Parent = fond

		local nom = Instance.new("TextLabel")
		nom.Name = "Nom"
		nom.BackgroundTransparency = 1
		nom.Position = UDim2.fromScale(0.14, 0.1)
		nom.Size = UDim2.fromScale(0.5, 0.8)
		nom.Font = C.policeTexte
		nom.TextScaled = true
		nom.TextXAlignment = Enum.TextXAlignment.Left
		nom.TextTruncate = Enum.TextTruncate.AtEnd
		nom.TextColor3 = C.creme
		nom.Text = ""
		nom.Parent = fond

		local revenu = Instance.new("TextLabel")
		revenu.Name = "Revenu"
		revenu.BackgroundTransparency = 1
		revenu.Position = UDim2.fromScale(0.64, 0.1)
		revenu.Size = UDim2.fromScale(0.34, 0.8)
		revenu.Font = C.police
		revenu.TextScaled = true
		revenu.TextXAlignment = Enum.TextXAlignment.Right
		revenu.TextColor3 = couleur
		revenu.Text = ""
		revenu.Parent = fond

		lignes[i] = { nom = nom, revenu = revenu }
	end

	return lignes
end

local function majTableau(ctx, lignes)
	local tri = joueursParRevenu()
	for i = 1, NB_LIGNES do
		local ligne = lignes[i]
		local entree = tri[i]
		if entree then
			local nom = entree.joueur.DisplayName
			if type(nom) ~= "string" or nom == "" then nom = entree.joueur.Name end
			ligne.nom.Text = nom
			ligne.nom.TextColor3 = ctx.Charte.creme
			ligne.revenu.Text = ctx.Charte.argent(entree.revenu) .. "/s"
		else
			ligne.nom.Text = "---"
			ligne.nom.TextColor3 = ctx.Charte.pierre
			ligne.revenu.Text = ""
		end
	end
end

function M.demarrer(ctx)
	-- joueurs présents et à venir
	Players.PlayerAdded:Connect(function(joueur)
		preparerJoueur(ctx, joueur)
	end)
	Players.PlayerRemoving:Connect(function(joueur)
		deconnecter(joueur)
	end)
	for _, joueur in ipairs(Players:GetPlayers()) do
		preparerJoueur(ctx, joueur)
	end

	-- meilleur revenu du serveur
	task.spawn(function()
		while true do
			local ok, err = pcall(majMeilleurRevenu, ctx)
			if not ok then warn("[Dino] Classement : meilleur revenu : " .. tostring(err)) end
			task.wait(PERIODE_MEILLEUR)
		end
	end)

	-- tableau d'honneur
	local ok, lignes = pcall(construireTableau, ctx)
	if not ok then
		warn("[Dino] Classement : tableau d'honneur : " .. tostring(lignes))
		return
	end
	task.spawn(function()
		while true do
			local reussi, err = pcall(majTableau, ctx, lignes)
			if not reussi then warn("[Dino] Classement : mise à jour du tableau : " .. tostring(err)) end
			task.wait(PERIODE_TABLEAU)
		end
	end)
end

return M
