-- Interface/Etabli : panneau des améliorations de run (pièces).
-- Ouvert par Bus « OuvrirPanneau » == "Etabli", fermé par « FermerPanneaux », le bouton ✕ ou Échap.
local M = {}

-- ordre d'affichage et libellés français
local ORDRE = {
	"Degats", "Cadence", "Portee", "Solidite", "Reparation", "Regeneration", "Butin", "BallesExplosives",
}
local LIBELLES = {
	Degats = "Dégâts",
	Cadence = "Cadence",
	Portee = "Portée",
	Solidite = "Solidité",
	Reparation = "Réparation",
	Regeneration = "Régénération",
	Butin = "Butin",
	BallesExplosives = "Balles explosives",
}

local DELAI_CLIC = 0.2 -- secondes minimum entre deux clics d'achat

local function pourcent(x)
	return tostring(math.floor(x * 100 + 0.5)) .. " %"
end

local function nombre(x)
	if x == math.floor(x) then return tostring(x) end
	return string.format("%.1f", x)
end

-- description de l'effet d'un niveau, à partir des chiffres d'Equilibrage
local function decrire(nom, def)
	local e = tonumber(def.effet) or 0
	local texte
	if nom == "Degats" then
		texte = "+" .. pourcent(e) .. " de dégâts par niveau"
	elseif nom == "Cadence" then
		texte = "+" .. pourcent(e) .. " de cadence de tir par niveau"
	elseif nom == "Portee" then
		texte = "+" .. nombre(e) .. " studs de portée par niveau"
	elseif nom == "Solidite" then
		texte = "+" .. pourcent(e) .. " de PV de la Maison par niveau"
	elseif nom == "Reparation" then
		texte = "+" .. pourcent(e) .. " de réparation par niveau"
	elseif nom == "Regeneration" then
		texte = "La Maison regagne +" .. nombre(e) .. " PV/s par niveau"
	elseif nom == "Butin" then
		texte = "+" .. pourcent(e) .. " de pièces gagnées par niveau"
	elseif nom == "BallesExplosives" then
		texte = "Les tirs explosent : rayon +" .. nombre(e) .. " studs par niveau"
	else
		if e < 1 then
			texte = "+" .. pourcent(e) .. " par niveau"
		else
			texte = "+" .. nombre(e) .. " par niveau"
		end
	end
	if def.equipe then
		texte = texte .. " (toute l'équipe)"
	end
	return texte
end

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau or {}
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local gui = ctx.gui
	if not (Charte and Outils and E and Bus and joueur and gui) then return end
	if type(E.ameliorations) ~= "table" or type(E.coutAmelioration) ~= "function" then return end

	local okUis, UserInputService = pcall(function() return game:GetService("UserInputService") end)
	if not okUis then UserInputService = nil end

	-- liste des améliorations : ordre connu d'abord, puis les éventuelles nouvelles
	local noms = {}
	local vus = {}
	for _, nom in ipairs(ORDRE) do
		if E.ameliorations[nom] then
			table.insert(noms, nom)
			vus[nom] = true
		end
	end
	local autres = {}
	for nom in pairs(E.ameliorations) do
		if not vus[nom] then table.insert(autres, nom) end
	end
	table.sort(autres)
	for _, nom in ipairs(autres) do table.insert(noms, nom) end

	local function son(nom)
		Bus.emettre("Son", nom)
	end

	local function pieces()
		local v = joueur:GetAttribute("Pieces")
		if type(v) ~= "number" then return 0 end
		return v
	end

	local function niveau(nom)
		local v = joueur:GetAttribute("Niv_" .. nom)
		if type(v) ~= "number" then return 0 end
		return v
	end

	local function enRun()
		if joueur:GetAttribute("EnRun") ~= true then return false end
		if Etat and Etat:GetAttribute("Phase") == "Lobby" then return false end
		return true
	end

	local function coutDe(nom, n)
		local ok, c = pcall(E.coutAmelioration, nom, n)
		if ok and type(c) == "number" then return c end
		return nil
	end

	-- ===== panneau =====
	local panneau = Outils.cadre(gui, {
		Name = "PanneauEtabli",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.8),
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0.05,
		Visible = false,
		ZIndex = 20,
		-- absorbe les clics : sinon un clic dans le panneau part en tir du Blaster
		Active = true,
	})
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MaxSize = Vector2.new(780, 480)
	contrainte.Parent = panneau
	local contour = Instance.new("UIStroke")
	contour.Color = Charte.toit
	contour.Thickness = 3
	contour.Parent = panneau

	Outils.etiquette(panneau, {
		Name = "Titre",
		Position = UDim2.new(0, 16, 0, 10),
		Size = UDim2.new(0.6, -16, 0, 36),
		Text = "🔧 Établi",
		TextColor3 = Charte.toit,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21,
	})

	local etiquettePieces = Outils.etiquette(panneau, {
		Name = "Pieces",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -64, 0, 14),
		Size = UDim2.new(0.35, -64, 0, 28),
		Text = "💰 0",
		TextColor3 = Charte.dore,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 21,
	})

	local fermerPanneau -- déclarée plus bas

	Outils.bouton(panneau, {
		Name = "Fermer",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.new(0, 40, 0, 40),
		BackgroundColor3 = Charte.alerte,
		Text = "✕",
		ZIndex = 22,
	}, function()
		son("clic")
		fermerPanneau()
	end)

	-- message hors run
	local messageHorsRun = Outils.etiquette(panneau, {
		Name = "HorsRun",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.new(0.8, 0, 0, 48),
		Text = "L'Établi sert pendant une run",
		TextColor3 = Charte.creme,
		Visible = false,
		ZIndex = 21,
	})

	-- grille des cartes
	local grille = Instance.new("Frame")
	grille.Name = "Grille"
	grille.BackgroundTransparency = 1
	grille.Position = UDim2.new(0, 12, 0, 56)
	grille.Size = UDim2.new(1, -24, 1, -68)
	grille.ZIndex = 21
	grille.Parent = panneau

	local colonnes = 4
	local lignes = math.max(1, math.ceil(#noms / colonnes))
	local disposition = Instance.new("UIGridLayout")
	disposition.CellPadding = UDim2.new(0, 8, 0, 8)
	disposition.CellSize = UDim2.new(1 / colonnes, -8, 1 / lignes, -8)
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.HorizontalAlignment = Enum.HorizontalAlignment.Center
	disposition.Parent = grille

	local cartes = {}
	local dernierClic = 0

	local function rafraichirCarte(carte)
		local def = E.ameliorations[carte.nom]
		local n = niveau(carte.nom)
		local max = tonumber(def.max) or 0
		carte.niveau.Text = "Niv. " .. tostring(n) .. "/" .. tostring(max)
		if n >= max then
			carte.bouton.Text = "MAX"
			carte.bouton.BackgroundColor3 = Charte.dore
			carte.bouton.TextColor3 = Charte.encre
			carte.bouton.AutoButtonColor = false
			return
		end
		local cout = coutDe(carte.nom, n)
		if not cout then
			carte.bouton.Text = "—"
			carte.bouton.BackgroundColor3 = Charte.ardoise
			carte.bouton.TextColor3 = Charte.creme
			carte.bouton.AutoButtonColor = false
			return
		end
		carte.bouton.Text = "💰 " .. tostring(cout)
		carte.bouton.TextColor3 = Charte.creme
		if pieces() >= cout then
			carte.bouton.BackgroundColor3 = Charte.prairie
			carte.bouton.AutoButtonColor = true
		else
			carte.bouton.BackgroundColor3 = Charte.ardoise
			carte.bouton.AutoButtonColor = false
		end
	end

	local function rafraichir()
		etiquettePieces.Text = "💰 " .. tostring(pieces())
		local actif = enRun()
		messageHorsRun.Visible = not actif
		grille.Visible = actif
		etiquettePieces.Visible = actif
		if actif then
			for _, carte in ipairs(cartes) do
				rafraichirCarte(carte)
			end
		end
	end

	local function acheter(nom)
		local maintenant = os.clock()
		if maintenant - dernierClic < DELAI_CLIC then return end
		dernierClic = maintenant
		if not enRun() then
			son("refus")
			return
		end
		local def = E.ameliorations[nom]
		local n = niveau(nom)
		if not def or n >= (tonumber(def.max) or 0) then
			son("refus")
			return
		end
		local cout = coutDe(nom, n)
		if not cout or pieces() < cout then
			son("refus")
			return
		end
		local ev = Reseau.Acheter
		if not ev then
			son("refus")
			return
		end
		local ok = pcall(function()
			ev:FireServer(nom)
		end)
		if ok then
			son("achat")
		else
			son("refus")
		end
	end

	for i, nom in ipairs(noms) do
		local def = E.ameliorations[nom]
		local carteCadre = Outils.cadre(grille, {
			Name = nom,
			LayoutOrder = i,
			BackgroundColor3 = Charte.nuitLabo,
			BackgroundTransparency = 0,
			ZIndex = 21,
		})
		local contourCarte = Instance.new("UIStroke")
		contourCarte.Color = Charte.ombre(Charte.nuitLabo)
		contourCarte.Thickness = 2
		contourCarte.Parent = carteCadre

		Outils.etiquette(carteCadre, {
			Name = "Nom",
			Position = UDim2.new(0, 6, 0.04, 0),
			Size = UDim2.new(1, -12, 0.2, 0),
			Text = LIBELLES[nom] or nom,
			TextColor3 = Charte.toit,
			ZIndex = 22,
		})
		Outils.etiquette(carteCadre, {
			Name = "Description",
			Position = UDim2.new(0, 6, 0.26, 0),
			Size = UDim2.new(1, -12, 0.3, 0),
			Font = Charte.policeTexte,
			Text = decrire(nom, def),
			TextColor3 = Charte.creme,
			TextWrapped = true,
			ZIndex = 22,
		})
		local etiquetteNiveau = Outils.etiquette(carteCadre, {
			Name = "Niveau",
			Position = UDim2.new(0, 6, 0.58, 0),
			Size = UDim2.new(1, -12, 0.14, 0),
			Text = "Niv. 0/0",
			TextColor3 = Charte.lumiere(Charte.gemme),
			ZIndex = 22,
		})
		local bouton = Outils.bouton(carteCadre, {
			Name = "Acheter",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0.96, 0),
			Size = UDim2.new(1, -16, 0.2, 0),
			BackgroundColor3 = Charte.ardoise,
			Text = "",
			ZIndex = 22,
		}, function()
			acheter(nom)
		end)

		table.insert(cartes, { nom = nom, niveau = etiquetteNiveau, bouton = bouton })
	end

	-- ===== ouverture / fermeture =====
	local function ouvrirPanneau()
		rafraichir()
		panneau.Visible = true
	end

	fermerPanneau = function()
		panneau.Visible = false
	end

	Bus.ecouter("OuvrirPanneau", function(nom)
		if nom == "Etabli" then
			if panneau.Visible then return end
			son("clic")
			ouvrirPanneau()
		else
			-- un seul panneau à la fois
			fermerPanneau()
		end
	end)

	Bus.ecouter("FermerPanneaux", function()
		fermerPanneau()
	end)

	if UserInputService then
		UserInputService.InputBegan:Connect(function(entree)
			if entree.KeyCode == Enum.KeyCode.Escape and panneau.Visible then
				fermerPanneau()
			end
		end)
	end

	-- ===== mises à jour en direct =====
	joueur.AttributeChanged:Connect(function(attribut)
		if attribut == "Pieces" or attribut == "EnRun" or string.sub(attribut, 1, 4) == "Niv_" then
			if attribut == "EnRun" and joueur:GetAttribute("EnRun") ~= true then
				fermerPanneau()
			end
			if panneau.Visible then rafraichir() end
		end
	end)

	if Etat then
		Etat:GetAttributeChangedSignal("Phase"):Connect(function()
			if Etat:GetAttribute("Phase") == "Lobby" then
				fermerPanneau()
			elseif panneau.Visible then
				rafraichir()
			end
		end)
	end

	rafraichir()
end

return M
