-- Constructeur Records : tableau d'honneur et petit podium sur l'île du Laboratoire.
-- Emprise 10 x 4 autour de Plan.lobby.records (10 le long de X, 4 le long de Z).
-- Le panneau est au fond (côté -Z) et regarde vers +Z (côté spawn) ; le podium est devant lui.
-- Le panneau affiche le record du serveur (Etat.Record) et le top 5 des joueurs présents (attribut RecordJour).
local M = {}

local BUDGET = 60
local INTERVALLE_RAFRAICHISSEMENT = 5 -- secondes entre deux mises à jour de sécurité
local NB_LIGNES = 5

-- dimensions du décor (studs)
local EPAISSEUR_DALLE = 0.3
local Z_PANNEAU = -1.5
local LARGEUR_PANNEAU = 9
local BAS_PANNEAU = 3.2
local HAUT_PANNEAU = 8
local HAUTEUR_POTEAU = 8.4
local Z_PODIUM = 0.8
local LARGEUR_MARCHE = 1.8
local PROFONDEUR_MARCHE = 1.8

-- lit un nombre de jour à partir d'un attribut (entier positif, 0 sinon)
local function jourDepuis(valeur)
	local n = tonumber(valeur)
	if not n or n ~= n then
		return 0
	end
	n = math.floor(n)
	if n < 0 then
		return 0
	end
	return n
end

local function nomAffiche(joueur)
	local ok, nom = pcall(function()
		return joueur.DisplayName
	end)
	if ok and type(nom) == "string" and nom ~= "" then
		return nom
	end
	return joueur.Name
end

-- étiquette de texte simple pour la SurfaceGui
local function etiquette(parent, ctx, props)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.BorderSizePixel = 0
	t.TextScaled = true
	t.Font = props.police or ctx.Charte.police
	t.TextColor3 = props.couleur or ctx.Charte.creme
	t.TextXAlignment = props.alignement or Enum.TextXAlignment.Center
	t.Position = props.position
	t.Size = props.taille
	t.Text = props.texte or ""
	t.Name = props.nom or "Texte"
	t.Parent = parent
	return t
end

-- coupe en 5 parts posée en (x, ySocle, z), mise à l'échelle par echelle
local function construireCoupe(ctx, parent, nom, x, ySocle, z, couleur, echelle)
	local Outils = ctx.Outils
	local Charte = ctx.Charte
	local m = Outils.modele(parent, nom)
	local vertical = CFrame.Angles(0, 0, math.rad(90))

	local hSocle = 0.25 * echelle
	Outils.bloc(m, {
		Name = "Socle",
		Size = Vector3.new(0.8 * echelle, hSocle, 0.8 * echelle),
		CFrame = CFrame.new(x, ySocle + hSocle / 2, z),
		Color = Charte.ombre(couleur),
		CanCollide = false,
	})
	local hTige = 0.5 * echelle
	Outils.cylindre(m, {
		Name = "Tige",
		Size = Vector3.new(hTige, 0.25 * echelle, 0.25 * echelle),
		CFrame = CFrame.new(x, ySocle + hSocle + hTige / 2, z) * vertical,
		Color = couleur,
		CanCollide = false,
	})
	local hCoupe = 0.7 * echelle
	local yCoupe = ySocle + hSocle + hTige + hCoupe / 2
	local coupe = Outils.cylindre(m, {
		Name = "Coupe",
		Size = Vector3.new(hCoupe, 0.8 * echelle, 0.8 * echelle),
		CFrame = CFrame.new(x, yCoupe, z) * vertical,
		Color = couleur,
		Reflectance = 0.15,
		CanCollide = false,
	})
	for _, cote in ipairs({ -1, 1 }) do
		Outils.bloc(m, {
			Name = "Anse",
			Size = Vector3.new(0.15 * echelle, 0.4 * echelle, 0.15 * echelle),
			CFrame = CFrame.new(x + cote * 0.47 * echelle, yCoupe, z),
			Color = Charte.lumiere(couleur),
			CanCollide = false,
		})
	end
	m.PrimaryPart = coupe
	return coupe
end

-- nom flottant au-dessus d'une coupe (aucune part)
local function etiquetteCoupe(ctx, coupe)
	local b = Instance.new("BillboardGui")
	b.Name = "NomPodium"
	b.Size = UDim2.new(5, 0, 0.9, 0)
	b.StudsOffset = Vector3.new(0, 1.1, 0)
	b.MaxDistance = 45
	b.LightInfluence = 0
	b.Parent = coupe
	local t = Instance.new("TextLabel")
	t.Name = "Nom"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.Font = ctx.Charte.police
	t.TextColor3 = ctx.Charte.creme
	t.TextStrokeColor3 = ctx.Charte.encre
	t.TextStrokeTransparency = 0
	t.Text = ""
	t.Parent = b
	return t
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local dossier = ctx.dossier
	local centre = ctx.Plan.lobby.records
	local partsAvant = Outils.nombreParts()

	-- couleurs du podium, dérivées de la charte
	local OR = Charte.dore
	local ARGENT = Charte.creme:Lerp(Charte.ardoise, 0.3)
	local BRONZE = Charte.ombre(Charte.terre)
	local COULEURS_RANG = { OR, ARGENT, BRONZE }

	local function pos(dx, y, dz)
		return Vector3.new(centre.X + dx, centre.Y + y, centre.Z + dz)
	end

	-- ===== dalle =====
	Outils.bloc(dossier, {
		Name = "Dalle",
		Size = Vector3.new(10, EPAISSEUR_DALLE, 4),
		CFrame = CFrame.new(pos(0, EPAISSEUR_DALLE / 2, 0)),
		Color = Charte.ardoise,
	})

	-- ===== panneau d'honneur =====
	local modelePanneau = Outils.modele(dossier, "PanneauHonneur")
	for _, cote in ipairs({ -1, 1 }) do
		Outils.bloc(modelePanneau, {
			Name = "Poteau",
			Size = Vector3.new(0.6, HAUTEUR_POTEAU, 0.6),
			CFrame = CFrame.new(pos(cote * 4.6, EPAISSEUR_DALLE + HAUTEUR_POTEAU / 2, Z_PANNEAU)),
			Color = Charte.toit,
		})
		local lampe = Outils.boule(modelePanneau, {
			Name = "Lampe",
			Size = Vector3.new(0.8, 0.8, 0.8),
			CFrame = CFrame.new(pos(cote * 4.6, EPAISSEUR_DALLE + HAUTEUR_POTEAU + 0.4, Z_PANNEAU)),
			Color = OR,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		Outils.lumiere(lampe, { Range = 8, Brightness = 0.8, Color = Charte.lumiere(OR) })
	end

	local hPanneau = HAUT_PANNEAU - BAS_PANNEAU
	-- rotation d'un demi-tour : la face Front de la part regarde vers +Z
	local planche = Outils.bloc(modelePanneau, {
		Name = "Planche",
		Size = Vector3.new(LARGEUR_PANNEAU, hPanneau, 0.4),
		CFrame = CFrame.new(pos(0, BAS_PANNEAU + hPanneau / 2, Z_PANNEAU)) * CFrame.Angles(0, math.pi, 0),
		Color = Charte.nuitLabo,
	})
	Outils.bloc(modelePanneau, {
		Name = "Fronton",
		Size = Vector3.new(LARGEUR_PANNEAU + 0.8, 0.5, 0.8),
		CFrame = CFrame.new(pos(0, HAUT_PANNEAU + 0.25, Z_PANNEAU)),
		Color = Charte.toit,
	})
	Outils.bloc(modelePanneau, {
		Name = "Appui",
		Size = Vector3.new(LARGEUR_PANNEAU + 0.8, 0.3, 0.7),
		CFrame = CFrame.new(pos(0, BAS_PANNEAU - 0.15, Z_PANNEAU)),
		Color = Charte.ombre(Charte.toit),
	})
	local etoile = Outils.boule(modelePanneau, {
		Name = "Etoile",
		Size = Vector3.new(1.1, 1.1, 1.1),
		CFrame = CFrame.new(pos(0, HAUT_PANNEAU + 1.05, Z_PANNEAU)),
		Color = OR,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	Outils.animer(etoile, "pulse", 0.6)
	modelePanneau.PrimaryPart = planche

	-- dos du panneau (côté Laboratoire)
	Outils.texte(planche, "Back", "Tableau des records", { couleur = Charte.dore, pixelsParStud = 30 })

	-- face avant : SurfaceGui détaillée
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Honneur"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = planche

	local titre = etiquette(gui, ctx, {
		nom = "Titre",
		position = UDim2.fromScale(0.03, 0.03),
		taille = UDim2.fromScale(0.94, 0.2),
		couleur = OR,
		texte = "Record du serveur : Jour 0",
	})
	etiquette(gui, ctx, {
		nom = "SousTitre",
		position = UDim2.fromScale(0.05, 0.24),
		taille = UDim2.fromScale(0.9, 0.09),
		police = Charte.policeTexte,
		couleur = Charte.creme,
		texte = "Meilleurs survivants présents",
	})
	local trait = Instance.new("Frame")
	trait.Name = "Trait"
	trait.BorderSizePixel = 0
	trait.BackgroundColor3 = OR
	trait.Position = UDim2.fromScale(0.08, 0.35)
	trait.Size = UDim2.fromScale(0.84, 0.01)
	trait.Parent = gui

	local lignes = {}
	for i = 1, NB_LIGNES do
		local cadre = Instance.new("Frame")
		cadre.Name = "Ligne" .. i
		cadre.BackgroundTransparency = 1
		cadre.BorderSizePixel = 0
		cadre.Position = UDim2.fromScale(0.05, 0.38 + (i - 1) * 0.12)
		cadre.Size = UDim2.fromScale(0.9, 0.105)
		cadre.Parent = gui
		local couleurRang = COULEURS_RANG[i] or Charte.creme
		local rang = etiquette(cadre, ctx, {
			nom = "Rang",
			position = UDim2.fromScale(0, 0),
			taille = UDim2.fromScale(0.1, 1),
			couleur = couleurRang,
			texte = i .. ".",
		})
		local nom = etiquette(cadre, ctx, {
			nom = "Nom",
			position = UDim2.fromScale(0.12, 0),
			taille = UDim2.fromScale(0.6, 1),
			police = Charte.policeTexte,
			couleur = Charte.creme,
			alignement = Enum.TextXAlignment.Left,
		})
		local jour = etiquette(cadre, ctx, {
			nom = "Jour",
			position = UDim2.fromScale(0.74, 0),
			taille = UDim2.fromScale(0.26, 1),
			couleur = couleurRang,
			alignement = Enum.TextXAlignment.Right,
		})
		lignes[i] = { rang = rang, nom = nom, jour = jour }
	end

	-- ===== podium à 3 marches : vu depuis +Z, la gauche de l'observateur est +X (2e), sa droite -X (3e) =====
	local modelePodium = Outils.modele(dossier, "Podium")
	local marches = {
		{ rang = 1, dx = 0, hauteur = 1.4, echelle = 1.2 },
		{ rang = 2, dx = LARGEUR_MARCHE, hauteur = 1.0, echelle = 1 },
		{ rang = 3, dx = -LARGEUR_MARCHE, hauteur = 0.7, echelle = 1 },
	}
	local nomsPodium = {}
	for _, marche in ipairs(marches) do
		local dx = marche.dx
		local bloc = Outils.bloc(modelePodium, {
			Name = "Marche" .. marche.rang,
			Size = Vector3.new(LARGEUR_MARCHE, marche.hauteur, PROFONDEUR_MARCHE),
			CFrame = CFrame.new(pos(dx, EPAISSEUR_DALLE + marche.hauteur / 2, Z_PODIUM)),
			Color = Charte.creme,
		})
		-- la face Back d'une part non tournée regarde vers +Z
		Outils.texte(bloc, "Back", tostring(marche.rang), { couleur = COULEURS_RANG[marche.rang], pixelsParStud = 30 })
		local ySommet = EPAISSEUR_DALLE + marche.hauteur
		Outils.bloc(modelePodium, {
			Name = "Lisere" .. marche.rang,
			Size = Vector3.new(LARGEUR_MARCHE + 0.1, 0.12, PROFONDEUR_MARCHE + 0.1),
			CFrame = CFrame.new(pos(dx, ySommet + 0.06, Z_PODIUM)),
			Color = Charte.toit,
		})
		local coupe = construireCoupe(ctx, modelePodium, "Coupe" .. marche.rang, centre.X + dx, centre.Y + ySommet + 0.12, centre.Z + Z_PODIUM, COULEURS_RANG[marche.rang], marche.echelle)
		nomsPodium[marche.rang] = etiquetteCoupe(ctx, coupe)
	end

	local utilisees = Outils.nombreParts() - partsAvant
	if utilisees > BUDGET then
		warn("[Zsurvie] Records : budget de parts dépassé (" .. utilisees .. " / " .. BUDGET .. ")")
	end

	-- ===== mise à jour de l'affichage =====
	local okPlayers, Players = pcall(function()
		return game:GetService("Players")
	end)
	if not okPlayers then
		Players = nil
	end

	local function recordServeur()
		if not ctx.Etat then
			return 0
		end
		return jourDepuis(ctx.Etat:GetAttribute("Record"))
	end

	-- exclu : joueur en train de partir (encore listé pendant PlayerRemoving)
	local function rafraichir(exclu)
		titre.Text = "Record du serveur : Jour " .. recordServeur()

		local classement = {}
		if Players then
			for _, joueur in ipairs(Players:GetPlayers()) do
				if joueur ~= exclu then
					table.insert(classement, {
						nom = nomAffiche(joueur),
						jour = jourDepuis(joueur:GetAttribute("RecordJour")),
					})
				end
			end
		end
		table.sort(classement, function(a, b)
			if a.jour ~= b.jour then
				return a.jour > b.jour
			end
			return a.nom < b.nom
		end)

		for i = 1, NB_LIGNES do
			local ligne = lignes[i]
			local entree = classement[i]
			if entree then
				ligne.nom.Text = entree.nom
				ligne.jour.Text = "Jour " .. entree.jour
				ligne.rang.TextTransparency = 0
			else
				ligne.jour.Text = ""
				if i == 1 then
					ligne.nom.Text = "En attente de survivants"
				else
					ligne.nom.Text = ""
				end
				ligne.rang.TextTransparency = 0.6
			end
		end

		for rang = 1, 3 do
			local entree = classement[rang]
			local etiquetteNom = nomsPodium[rang]
			if etiquetteNom then
				if entree then
					etiquetteNom.Text = entree.nom
				else
					etiquetteNom.Text = ""
				end
			end
		end
	end

	local function rafraichirProtege(exclu)
		local ok, err = pcall(rafraichir, exclu)
		if not ok then
			warn("[Zsurvie] Records : mise à jour impossible : " .. tostring(err))
		end
	end

	local connexions = {}
	local function suivre(joueur)
		if connexions[joueur] then
			return
		end
		local ok, connexion = pcall(function()
			return joueur:GetAttributeChangedSignal("RecordJour"):Connect(function()
				rafraichirProtege(nil)
			end)
		end)
		if ok then
			connexions[joueur] = connexion
		end
	end

	if ctx.Etat then
		ctx.Etat:GetAttributeChangedSignal("Record"):Connect(function()
			rafraichirProtege(nil)
		end)
	end

	if Players then
		Players.PlayerAdded:Connect(function(joueur)
			suivre(joueur)
			rafraichirProtege(nil)
		end)
		Players.PlayerRemoving:Connect(function(joueur)
			local connexion = connexions[joueur]
			if connexion then
				connexion:Disconnect()
				connexions[joueur] = nil
			end
			rafraichirProtege(joueur)
		end)
		for _, joueur in ipairs(Players:GetPlayers()) do
			suivre(joueur)
		end
	end

	rafraichirProtege(nil)

	-- filet de sécurité : mise à jour régulière tant que le panneau existe
	task.spawn(function()
		while planche.Parent do
			task.wait(INTERVALLE_RAFRAICHISSEMENT)
			if planche.Parent then
				rafraichirProtege(nil)
			end
		end
	end)
end

return M
