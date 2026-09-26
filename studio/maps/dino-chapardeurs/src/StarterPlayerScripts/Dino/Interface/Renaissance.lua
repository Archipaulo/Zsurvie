-- Interface Renaissance : panneau ouvert depuis l'Autel (ou le HUD), au style « simulateur Roblox ».
-- Montre le niveau, le gros multiplicateur actuel ➜ suivant, une barre de progression argent / coût,
-- ce que l'on perd et ce que l'on gagne, et un gros bouton « RENAÎTRE » à confirmer en deux temps.
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
	local Style = ctx.Style
	local E = ctx.Equilibrage
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local couleurs = Style.couleurs
	local ROUGE = Style.boutons.rouge[1]
	local VERT = couleurs.argent

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
		return "$" .. tostring(math.floor(n))
	end

	-- ===== construction du panneau =====
	local fond = Instance.new("Frame")
	fond.Name = "RenaissanceFond"
	fond.Active = true
	fond.BackgroundColor3 = couleurs.ombre
	fond.BackgroundTransparency = 0.5
	fond.BorderSizePixel = 0
	fond.Size = UDim2.fromScale(1, 1)
	fond.ZIndex = 40
	fond.Visible = false
	fond.Parent = ctx.gui

	local panneau, contenu, boutonFermer = Style.panneau(fond, {
		Name = "Renaissance",
		titre = "RENAISSANCE",
		icone = "♻️",
		couleur = "violet",
		Size = UDim2.new(0.94, 0, 0.9, 0),
	})
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	local limite = panneau:FindFirstChildOfClass("UISizeConstraint")
	if limite then
		limite.MaxSize = Vector2.new(540, 600)
		limite.MinSize = Vector2.new(300, 380)
	end

	-- niveau actuel « RENAISSANCE 2 / 10 »
	local niveauTexte = Style.texte(contenu, {
		Name = "Niveau",
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 0.08),
		Text = "",
		contour = 3,
		tailleMax = 28,
	})

	-- gros multiplicateur « x1,5 ➜ x2 »
	local rangeeMult = Instance.new("Frame")
	rangeeMult.Name = "Multiplicateur"
	rangeeMult.BackgroundTransparency = 1
	rangeeMult.Position = UDim2.fromScale(0, 0.08)
	rangeeMult.Size = UDim2.fromScale(1, 0.17)
	rangeeMult.Parent = contenu
	local multActuel = Style.texte(rangeeMult, {
		Name = "Actuel",
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(0.4, 1),
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "x1",
		titre = true,
		contour = 4,
		tailleMax = 64,
	})
	local fleche = Style.texte(rangeeMult, {
		Name = "Fleche",
		Position = UDim2.fromScale(0.4, 0.15),
		Size = UDim2.fromScale(0.2, 0.7),
		Text = "➜",
		TextColor3 = couleurs.revenu,
		contour = 3,
		tailleMax = 48,
	})
	local multSuivant = Style.texte(rangeeMult, {
		Name = "Suivant",
		Position = UDim2.fromScale(0.6, 0),
		Size = UDim2.fromScale(0.4, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "x1",
		titre = true,
		contour = 4,
		tailleMax = 72,
	})
	Style.degradeRarete(multSuivant, "Divin")

	-- coût de la suivante (argent vert)
	local coutTexte = Style.texte(contenu, {
		Name = "Cout",
		Position = UDim2.fromScale(0, 0.26),
		Size = UDim2.fromScale(1, 0.07),
		Text = "",
		TextColor3 = VERT,
		contour = 3,
		tailleMax = 28,
	})

	-- barre de progression Argent / coût : épaisse, cernée de noir, remplissage vert en dégradé
	local barre = Instance.new("Frame")
	barre.Name = "Barre"
	barre.Position = UDim2.fromScale(0, 0.34)
	barre.Size = UDim2.fromScale(1, 0.1)
	barre.BackgroundColor3 = couleurs.carte
	barre.BorderSizePixel = 0
	barre.ClipsDescendants = true
	barre.Parent = contenu
	Style.coins(barre, 14)
	Style.bordure(barre, 4)
	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(0, 1)
	remplissage.BackgroundColor3 = Color3.new(1, 1, 1)
	remplissage.BorderSizePixel = 0
	remplissage.Parent = barre
	Style.coins(remplissage, 14)
	Style.degrade(remplissage, Style.boutons.vert[1], Style.boutons.vert[2])
	local barreTexte = Style.texte(barre, {
		Name = "Texte",
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.94, 0.78),
		Text = "",
		ZIndex = 3,
		contour = 3,
		tailleMax = 30,
	})

	-- cartes « Tu perds » / « Tu gagnes »
	local function colonne(nom, x, titre, couleur)
		local c = Style.carte(contenu, {
			Name = nom,
			Position = UDim2.fromScale(x, 0.47),
			Size = UDim2.fromScale(0.485, 0.27),
		})
		local bord = c:FindFirstChild("Bordure")
		if bord then
			bord.Color = couleur
		end
		Style.texte(c, {
			Name = "Titre",
			Position = UDim2.fromScale(0.05, 0.04),
			Size = UDim2.fromScale(0.9, 0.28),
			Text = titre,
			TextColor3 = couleur,
			titre = true,
			contour = 3,
			tailleMax = 30,
		})
		local lignes = {}
		for i = 1, 2 do
			lignes[i] = Style.texte(c, {
				Name = "Ligne" .. i,
				Position = UDim2.fromScale(0.06, 0.36 + (i - 1) * 0.31),
				Size = UDim2.fromScale(0.88, 0.27),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "",
				contour = 2.5,
				tailleMax = 22,
			})
		end
		return c, lignes
	end
	local colPerte, lignesPerte = colonne("Perte", 0, "❌ TU PERDS", ROUGE)
	local colGain, lignesGain = colonne("Gain", 0.515, "✅ TU GAGNES", VERT)

	-- « MAX » géant doré à la place des cartes
	local messageMax = Style.texte(contenu, {
		Name = "Max",
		Position = UDim2.fromScale(0, 0.47),
		Size = UDim2.fromScale(1, 0.27),
		Text = "👑 MAX 👑",
		Visible = false,
		titre = true,
		contour = 4,
		tailleMax = 90,
	})
	Style.degradeRarete(messageMax, "Legendaire")

	local raison = Style.texte(contenu, {
		Name = "Raison",
		Position = UDim2.fromScale(0, 0.76),
		Size = UDim2.fromScale(1, 0.06),
		Text = "",
		TextColor3 = couleurs.revenu,
		contour = 2.5,
		tailleMax = 22,
	})

	-- ===== état du bouton =====
	local confirmation = false  -- premier clic fait, en attente du second
	local jetonConfirmation = 0 -- invalide les délais périmés
	local finAttente = 0        -- os.clock() jusqu'auquel le bouton reste bloqué après envoi
	local ouvert = false

	local boutonRenaitre, libelleRenaitre

	local function styleBouton(texte, couleur)
		libelleRenaitre.Text = texte
		Style.couleurBouton(boutonRenaitre, couleur)
	end

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
			return false, "Il te manque " .. montant(cout - argent) .. " !"
		end
		return true, ""
	end

	local function rafraichir()
		local niveau = niveauActuel()
		local argent = argentActuel()
		local estMax = niveau >= MAX

		niveauTexte.Text = "NIVEAU " .. niveau .. " / " .. MAX
		multActuel.Text = "x" .. formaterMultiplicateur(multiplicateurDe(niveau))

		colPerte.Visible = not estMax
		colGain.Visible = not estMax
		messageMax.Visible = estMax
		fleche.Visible = not estMax
		multSuivant.Visible = not estMax
		if estMax then
			multActuel.Size = UDim2.fromScale(1, 1)
			multActuel.TextXAlignment = Enum.TextXAlignment.Center
		else
			multActuel.Size = UDim2.fromScale(0.4, 1)
			multActuel.TextXAlignment = Enum.TextXAlignment.Right
			multSuivant.Text = "x" .. formaterMultiplicateur(multiplicateurDe(niveau + 1))
		end

		local progression = 1
		if estMax then
			coutTexte.Text = "Renaissance maximale atteinte !"
			coutTexte.TextColor3 = couleurs.revenu
			barreTexte.Text = "MAX"
		else
			coutTexte.TextColor3 = VERT
			local cout = coutDe(niveau)
			if cout and cout > 0 then
				progression = math.clamp(argent / cout, 0, 1)
				coutTexte.Text = "Coût : " .. montant(cout)
				barreTexte.Text = montant(argent) .. " / " .. montant(cout)
			elseif cout then
				coutTexte.Text = "Coût : GRATUIT"
				barreTexte.Text = montant(argent)
			else
				progression = 0
				coutTexte.Text = "Coût : indisponible"
				barreTexte.Text = "..."
			end
			lignesPerte[1].Text = "💸 Ton argent (retour à " .. montant(ARGENT_DEPART) .. ")"
			lignesPerte[2].Text = "🦖 Tous les dinos de ta Base"
			lignesGain[1].Text = "💰 Revenus x" .. formaterMultiplicateur(multiplicateurDe(niveau + 1))
			if emplacementsDe(niveau + 1) > emplacementsDe(niveau) then
				lignesGain[2].Text = "🏠 +1 emplacement (" .. emplacementsDe(niveau + 1) .. ")"
			else
				lignesGain[2].Text = "🏠 Emplacements déjà au max"
			end
		end

		pcall(function()
			TweenService:Create(remplissage, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(progression, 1),
			}):Play()
		end)

		-- bouton
		local ok, pourquoi = possible()
		if estMax then
			confirmation = false
			styleBouton("👑 MAX", "gris")
			raison.Text = "Tu as atteint le sommet. Bravo !"
		elseif os.clock() < finAttente then
			styleBouton("...", "gris")
			raison.Text = ""
		elseif not ok then
			confirmation = false
			styleBouton("♻️ RENAÎTRE", "gris")
			raison.Text = pourquoi
		elseif confirmation then
			styleBouton("SÛR ? RECLIQUE !", "rouge")
			raison.Text = "Ton argent et tes dinos seront perdus."
		else
			styleBouton("♻️ RENAÎTRE", "violet")
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
			Style.pop(boutonRenaitre, 1.08)
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

	boutonRenaitre, libelleRenaitre = Style.bouton(contenu, {
		Name = "Renaitre",
		texte = "♻️ RENAÎTRE",
		couleur = "violet",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(0.8, 0.15),
		tailleMax = 40,
		rayon = 18,
	}, clicRenaitre)
	local tailleBouton = Instance.new("UISizeConstraint")
	tailleBouton.MinSize = Vector2.new(180, 56)
	tailleBouton.MaxSize = Vector2.new(420, 84)
	tailleBouton.Parent = boutonRenaitre

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
		Style.pop(panneau)
	end

	boutonFermer.Activated:Connect(function()
		Bus.emettre("Son", "clic")
		fermer()
	end)

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
