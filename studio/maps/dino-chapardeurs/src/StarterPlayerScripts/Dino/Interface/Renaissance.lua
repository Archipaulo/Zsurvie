-- Interface Renaissance : panneau ouvert depuis l'Autel (ou le HUD).
-- Montre le niveau, le coût de la suivante avec une barre de progression,
-- ce que l'on perd et ce que l'on gagne, et un bouton « Renaître » à confirmer en deux temps.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local DELAI_CONFIRMATION = 4 -- secondes pour confirmer après le premier clic
local ATTENTE_ENVOI = 1.5    -- secondes de blocage après l'envoi au serveur

-- nombre fini (ni NaN, ni infini)
local function estFini(n)
	return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

-- 1.5 -> "1,5" ; 2 -> "2"
local function formaterMultiplicateur(x)
	local texte = string.format("%.2f", x)
	texte = string.gsub(texte, "0+$", "")
	texte = string.gsub(texte, "%.$", "")
	texte = string.gsub(texte, "%.", ",")
	return texte
end

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local E = ctx.Equilibrage
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur

	-- ===== chiffres (toujours via Equilibrage, avec repli sûr) =====
	local MAX = 10
	if estFini(E.renaissanceMax) and E.renaissanceMax >= 0 then
		MAX = math.floor(E.renaissanceMax)
	end
	local EMPL_DEPART = 8
	local EMPL_PAR_RENAISSANCE = 1
	if type(E.base) == "table" then
		if estFini(E.base.emplacementsDepart) then
			EMPL_DEPART = E.base.emplacementsDepart
		end
		if estFini(E.base.emplacementsParRenaissance) then
			EMPL_PAR_RENAISSANCE = E.base.emplacementsParRenaissance
		end
	end
	local EMPL_MAX = 12
	if type(Plan.base) == "table" and estFini(Plan.base.emplacementsMax) then
		EMPL_MAX = Plan.base.emplacementsMax
	end
	local ARGENT_DEPART = 100
	if estFini(E.argentDepart) then
		ARGENT_DEPART = E.argentDepart
	end

	local function niveauActuel()
		local n = joueur:GetAttribute("Renaissances")
		if not estFini(n) or n < 0 then
			return 0
		end
		return math.floor(n)
	end

	local function argentActuel()
		local a = joueur:GetAttribute("Argent")
		if not estFini(a) or a < 0 then
			return 0
		end
		return a
	end

	local function coutDe(niveau)
		if type(E.coutRenaissance) ~= "function" then
			return nil
		end
		local ok, cout = pcall(E.coutRenaissance, niveau)
		if ok and estFini(cout) and cout >= 0 then
			return math.ceil(cout)
		end
		return nil
	end

	local function multiplicateurDe(niveau)
		if type(E.multiplicateurRenaissance) == "function" then
			local ok, x = pcall(E.multiplicateurRenaissance, niveau)
			if ok and estFini(x) and x > 0 then
				return x
			end
		end
		return 1
	end

	local function emplacementsDe(niveau)
		return math.min(EMPL_MAX, EMPL_DEPART + EMPL_PAR_RENAISSANCE * niveau)
	end

	local function montant(n)
		local ok, texte = pcall(Charte.argent, n)
		if ok and type(texte) == "string" then
			return texte
		end
		return tostring(math.floor(n)) .. " $"
	end

	-- ===== construction du panneau =====
	local fond = Instance.new("Frame")
	fond.Name = "RenaissanceFond"
	fond.Active = true
	fond.BackgroundColor3 = Charte.encre
	fond.BackgroundTransparency = 0.5
	fond.BorderSizePixel = 0
	fond.Size = UDim2.fromScale(1, 1)
	fond.ZIndex = 40
	fond.Visible = false
	fond.Parent = ctx.gui

	local panneau = Outils.cadre(fond, {
		Name = "Renaissance",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.8),
		BackgroundColor3 = Charte.nuit,
		BackgroundTransparency = 0.05,
		ZIndex = 41,
	})
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(480, 440)
	limite.Parent = panneau
	local contour = Instance.new("UIStroke")
	contour.Color = Charte.violet
	contour.Thickness = 3
	contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contour.Parent = panneau
	local echelle = Instance.new("UIScale")
	echelle.Scale = 1
	echelle.Parent = panneau

	Outils.etiquette(panneau, {
		Name = "Titre",
		Text = "Renaissance",
		TextColor3 = Charte.dore,
		Position = UDim2.new(0.05, 0, 0.03, 0),
		Size = UDim2.new(0.75, 0, 0.11, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 42,
	})

	local boutonFermer

	local niveauTexte = Outils.etiquette(panneau, {
		Name = "Niveau",
		Text = "",
		Font = Charte.policeTexte,
		TextColor3 = Charte.creme,
		Position = UDim2.new(0.05, 0, 0.15, 0),
		Size = UDim2.new(0.9, 0, 0.07, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 42,
	})

	local coutTexte = Outils.etiquette(panneau, {
		Name = "Cout",
		Text = "",
		Font = Charte.policeTexte,
		TextColor3 = Charte.creme,
		Position = UDim2.new(0.05, 0, 0.24, 0),
		Size = UDim2.new(0.9, 0, 0.06, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 42,
	})

	-- barre de progression Argent / coût
	local barre = Outils.cadre(panneau, {
		Name = "Barre",
		Position = UDim2.new(0.05, 0, 0.32, 0),
		Size = UDim2.new(0.9, 0, 0.08, 0),
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 42,
	})
	local remplissage = Outils.cadre(barre, {
		Name = "Remplissage",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Charte.dore,
		BackgroundTransparency = 0,
		ZIndex = 43,
	})
	local barreTexte = Outils.etiquette(barre, {
		Name = "Texte",
		Text = "",
		TextColor3 = Charte.creme,
		TextStrokeTransparency = 0.4,
		TextStrokeColor3 = Charte.encre,
		Position = UDim2.fromScale(0.02, 0.1),
		Size = UDim2.fromScale(0.96, 0.8),
		ZIndex = 44,
	})

	-- colonnes « Tu perds » / « Tu gagnes »
	local function colonne(nom, x, titre, couleur)
		local c = Outils.cadre(panneau, {
			Name = nom,
			Position = UDim2.new(x, 0, 0.44, 0),
			Size = UDim2.new(0.43, 0, 0.3, 0),
			BackgroundColor3 = Charte.encre,
			BackgroundTransparency = 0.3,
			ZIndex = 42,
		})
		local bord = Instance.new("UIStroke")
		bord.Color = couleur
		bord.Thickness = 2
		bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bord.Parent = c
		Outils.etiquette(c, {
			Name = "Titre",
			Text = titre,
			TextColor3 = couleur,
			Position = UDim2.fromScale(0.06, 0.05),
			Size = UDim2.fromScale(0.88, 0.24),
			ZIndex = 43,
		})
		local lignes = {}
		for i = 1, 2 do
			lignes[i] = Outils.etiquette(c, {
				Name = "Ligne" .. i,
				Text = "",
				Font = Charte.policeTexte,
				TextColor3 = Charte.creme,
				Position = UDim2.new(0.06, 0, 0.33 + (i - 1) * 0.32, 0),
				Size = UDim2.new(0.88, 0, 0.27, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 43,
			})
		end
		return c, lignes
	end
	local colPerte, lignesPerte = colonne("Perte", 0.05, "Tu perds", Charte.alerte)
	local colGain, lignesGain = colonne("Gain", 0.52, "Tu gagnes", Charte.herbe)

	local messageMax = Outils.etiquette(panneau, {
		Name = "Max",
		Text = "MAX",
		TextColor3 = Charte.dore,
		Position = UDim2.new(0.05, 0, 0.44, 0),
		Size = UDim2.new(0.9, 0, 0.3, 0),
		Visible = false,
		ZIndex = 42,
	})

	local raison = Outils.etiquette(panneau, {
		Name = "Raison",
		Text = "",
		Font = Charte.policeTexte,
		TextColor3 = Charte.sable,
		Position = UDim2.new(0.05, 0, 0.76, 0),
		Size = UDim2.new(0.9, 0, 0.05, 0),
		ZIndex = 42,
	})

	-- ===== état du bouton =====
	local confirmation = false  -- premier clic fait, en attente du second
	local jetonConfirmation = 0 -- invalide les délais périmés
	local finAttente = 0        -- os.clock() jusqu'auquel le bouton reste bloqué après envoi
	local ouvert = false

	local boutonRenaitre

	-- vrai si la renaissance est possible, sinon faux et la raison
	local function possible()
		local niveau = niveauActuel()
		if niveau >= MAX then
			return false, ""
		end
		if joueur:GetAttribute("DonneesChargees") == false then
			return false, "Tes données chargent encore..."
		end
		local cout = coutDe(niveau)
		if not cout then
			return false, "Renaissance indisponible pour le moment."
		end
		local porte = joueur:GetAttribute("Porte")
		if type(porte) == "string" and porte ~= "" then
			return false, "Pose d'abord le dino que tu portes !"
		end
		local argent = argentActuel()
		if argent < cout then
			return false, "Il te manque " .. montant(cout - argent) .. "."
		end
		return true, ""
	end

	local function rafraichir()
		local niveau = niveauActuel()
		local argent = argentActuel()
		local estMax = niveau >= MAX

		niveauTexte.Text = "Niveau actuel : " .. niveau .. " / " .. MAX .. "   (revenus x" .. formaterMultiplicateur(multiplicateurDe(niveau)) .. ")"

		colPerte.Visible = not estMax
		colGain.Visible = not estMax
		messageMax.Visible = estMax

		local progression = 1
		if estMax then
			coutTexte.Text = "Renaissance maximale atteinte !"
			barreTexte.Text = "MAX"
		else
			local cout = coutDe(niveau)
			if cout and cout > 0 then
				progression = math.clamp(argent / cout, 0, 1)
				coutTexte.Text = "Prochaine renaissance : " .. montant(cout)
				barreTexte.Text = montant(argent) .. " / " .. montant(cout)
			elseif cout then
				coutTexte.Text = "Prochaine renaissance : gratuite"
				barreTexte.Text = montant(argent)
			else
				progression = 0
				coutTexte.Text = "Prochaine renaissance : indisponible"
				barreTexte.Text = "..."
			end
			lignesPerte[1].Text = "Tout ton argent (retour à " .. montant(ARGENT_DEPART) .. ")"
			lignesPerte[2].Text = "Tous les dinos de ta Base"
			lignesGain[1].Text = "Revenus x" .. formaterMultiplicateur(multiplicateurDe(niveau + 1))
			if emplacementsDe(niveau + 1) > emplacementsDe(niveau) then
				lignesGain[2].Text = "+1 emplacement (" .. emplacementsDe(niveau + 1) .. " au total)"
			else
				lignesGain[2].Text = "Emplacements déjà au maximum"
			end
		end

		local couleurBarre = Charte.dore
		if progression >= 1 then
			couleurBarre = Charte.herbe
		end
		pcall(function()
			TweenService:Create(remplissage, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(progression, 1),
				BackgroundColor3 = couleurBarre,
			}):Play()
		end)

		-- bouton
		local ok, pourquoi = possible()
		if estMax then
			confirmation = false
			boutonRenaitre.Text = "MAX"
			boutonRenaitre.BackgroundColor3 = Charte.pierre
			boutonRenaitre.AutoButtonColor = false
			raison.Text = "Tu as atteint le sommet. Bravo !"
		elseif os.clock() < finAttente then
			boutonRenaitre.Text = "..."
			boutonRenaitre.BackgroundColor3 = Charte.pierre
			boutonRenaitre.AutoButtonColor = false
			raison.Text = ""
		elseif not ok then
			confirmation = false
			boutonRenaitre.Text = "Renaître"
			boutonRenaitre.BackgroundColor3 = Charte.pierre
			boutonRenaitre.AutoButtonColor = false
			raison.Text = pourquoi
		elseif confirmation then
			boutonRenaitre.Text = "Sûr ? Clique encore"
			boutonRenaitre.BackgroundColor3 = Charte.alerte
			boutonRenaitre.AutoButtonColor = true
			raison.Text = "Ton argent et tes dinos seront perdus."
		else
			boutonRenaitre.Text = "Renaître"
			boutonRenaitre.BackgroundColor3 = Charte.violet
			boutonRenaitre.AutoButtonColor = true
			raison.Text = ""
		end
	end

	local function annulerConfirmation()
		confirmation = false
		jetonConfirmation = jetonConfirmation + 1
	end

	local function clicRenaitre()
		if os.clock() < finAttente then
			return
		end
		local ok = possible()
		if not ok then
			annulerConfirmation()
			Bus.emettre("Son", "refus")
			rafraichir()
			return
		end
		if not confirmation then
			-- premier temps : demander confirmation
			confirmation = true
			jetonConfirmation = jetonConfirmation + 1
			local jeton = jetonConfirmation
			Bus.emettre("Son", "clic")
			rafraichir()
			task.delay(DELAI_CONFIRMATION, function()
				if jetonConfirmation == jeton and confirmation then
					confirmation = false
					if ouvert then
						rafraichir()
					end
				end
			end)
			return
		end
		-- second temps : on envoie
		annulerConfirmation()
		finAttente = os.clock() + ATTENTE_ENVOI
		Bus.emettre("Son", "clic")
		pcall(function()
			Reseau.Renaissance:FireServer()
		end)
		rafraichir()
		task.delay(ATTENTE_ENVOI + 0.05, function()
			if ouvert then
				rafraichir()
			end
		end)
	end

	boutonRenaitre = Outils.bouton(panneau, {
		Name = "Renaitre",
		Text = "Renaître",
		BackgroundColor3 = Charte.violet,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.83, 0),
		Size = UDim2.new(0.6, 0, 0.13, 0),
		ZIndex = 42,
	}, clicRenaitre)

	-- ===== ouverture / fermeture =====
	local function fermer()
		if not ouvert then
			return
		end
		ouvert = false
		annulerConfirmation()
		fond.Visible = false
	end

	local function ouvrir()
		annulerConfirmation()
		ouvert = true
		fond.Visible = true
		rafraichir()
		echelle.Scale = 0.85
		pcall(function()
			TweenService:Create(echelle, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		end)
	end

	boutonFermer = Outils.bouton(panneau, {
		Name = "Fermer",
		Text = "X",
		BackgroundColor3 = Charte.alerte,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0.96, 0, 0.03, 0),
		Size = UDim2.new(0.11, 0, 0.11, 0),
		ZIndex = 43,
	}, function()
		Bus.emettre("Son", "clic")
		fermer()
	end)
	local carre = Instance.new("UIAspectRatioConstraint")
	carre.AspectRatio = 1
	carre.Parent = boutonFermer

	Bus.ecouter("OuvrirPanneau", function(nom)
		if nom == "Renaissance" then
			if ouvert then
				rafraichir()
			else
				ouvrir()
			end
		else
			fermer()
		end
	end)
	Bus.ecouter("FermerPanneaux", fermer)

	-- Échap ou bouton B de la manette
	UserInputService.InputBegan:Connect(function(entree)
		if not ouvert then
			return
		end
		if entree.KeyCode == Enum.KeyCode.Escape or entree.KeyCode == Enum.KeyCode.ButtonB then
			fermer()
		end
	end)

	-- mise à jour en direct
	local function surChangement()
		if ouvert then
			rafraichir()
		end
	end
	joueur:GetAttributeChangedSignal("Argent"):Connect(surChangement)
	joueur:GetAttributeChangedSignal("Porte"):Connect(surChangement)
	joueur:GetAttributeChangedSignal("DonneesChargees"):Connect(surChangement)
	joueur:GetAttributeChangedSignal("Renaissances"):Connect(function()
		finAttente = 0
		annulerConfirmation()
		surChangement()
	end)
end

return M
