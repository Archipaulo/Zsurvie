-- Interface Renaissance : panneau ouvert depuis l'Autel (ou le HUD), au style « simulateur Roblox ».
-- Montre le niveau, le gros multiplicateur actuel ➜ suivant, une barre de progression argent / coût
-- (reflet, repères, pourcentage, éclat qui balaie quand on peut renaître), ce que l'on perd et ce que
-- l'on gagne, et un gros bouton « RENAÎTRE » à confirmer en deux temps.
-- Ouverture : fond qui s'assombrit, panneau qui apparaît en fondu et rebondit ; fermeture en fondu.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local M = {}

local DELAI_CONFIRMATION = 4 -- secondes pour confirmer après le premier clic
local ATTENTE_ENVOI = 1.5    -- secondes de blocage après l'envoi au serveur
local DUREE_OUVERTURE = 0.28
local DUREE_FERMETURE = 0.16
local OPACITE_FOND = 0.45    -- transparence du voile sombre une fois ouvert
local ESPACE_INSECABLE = string.char(0xC2, 0xA0) -- garde « TU PERDS » / « TU GAGNES » sur une ligne

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

-- lance un tween sans jamais faire planter l'interface
local function animer(objet, duree, style, direction, buts)
	local ok, tween = pcall(function()
		return TweenService:Create(objet, TweenInfo.new(duree, style, direction), buts)
	end)
	if ok and tween then
		tween:Play()
		return tween
	end
	for cle, valeur in pairs(buts) do
		objet[cle] = valeur
	end
	return nil
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
	local BLANC = Color3.new(1, 1, 1)
	local NOIR = Color3.new(0, 0, 0)

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

	-- reflet brillant (moitié haute, fondu vers le bas) sur un cadre coloré
	local function reflet(parent, rayon, opacite)
		local r = Instance.new("Frame")
		r.Name = "Reflet"
		r.BackgroundColor3 = BLANC
		r.BackgroundTransparency = 1 - (opacite or 0.4)
		r.BorderSizePixel = 0
		r.Position = UDim2.new(0, 5, 0, 3)
		r.Size = UDim2.new(1, -10, 0.42, 0)
		r.ZIndex = 2
		Style.coins(r, rayon or 8)
		local fondu = Instance.new("UIGradient")
		fondu.Rotation = 90
		fondu.Transparency = NumberSequence.new(0.05, 1)
		fondu.Parent = r
		r.Parent = parent
		return r
	end

	-- ===== construction du panneau =====
	-- voile sombre plein écran (bloque les clics derrière)
	local fond = Instance.new("Frame")
	fond.Name = "RenaissanceFond"
	fond.Active = true
	fond.BackgroundColor3 = couleurs.ombre
	fond.BackgroundTransparency = OPACITE_FOND
	fond.BorderSizePixel = 0
	fond.Size = UDim2.fromScale(1, 1)
	fond.ZIndex = 40
	fond.Visible = false
	fond.Parent = ctx.gui

	-- groupe transparent : permet le fondu de tout le panneau (et de son ombre) d'un coup
	local groupe = Instance.new("CanvasGroup")
	groupe.Name = "Groupe"
	groupe.BackgroundTransparency = 1
	groupe.BorderSizePixel = 0
	groupe.Size = UDim2.fromScale(1, 1)
	groupe.GroupTransparency = 0
	groupe.Parent = fond

	local panneau, contenu, boutonFermer = Style.panneau(groupe, {
		Name = "Renaissance",
		titre = "RENAISSANCE",
		icone = "♻️",
		couleur = "violet",
		Size = UDim2.new(0.94, 0, 0.9, 0),
	})
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	-- même limite pour le panneau et pour son ombre portée (cadre frère « RenaissanceOmbre »)
	local ombrePanneau = groupe:FindFirstChild("RenaissanceOmbre")
	for _, cadre in ipairs({ panneau, ombrePanneau }) do
		local limite = cadre and cadre:FindFirstChildOfClass("UISizeConstraint")
		if limite then
			limite.MaxSize = Vector2.new(540, 600)
			limite.MinSize = Vector2.new(300, 380)
		end
	end
	-- échelle d'ouverture / fermeture (rebond)
	local echellePanneau = Instance.new("UIScale")
	echellePanneau.Name = "Ouverture"
	echellePanneau.Scale = 1
	echellePanneau.Parent = panneau

	-- pastille du niveau « NIVEAU 2 / 10 »
	local pastille = Instance.new("Frame")
	pastille.Name = "Pastille"
	pastille.AnchorPoint = Vector2.new(0.5, 0)
	pastille.Position = UDim2.fromScale(0.5, 0)
	pastille.Size = UDim2.fromScale(0.5, 0.072)
	pastille.BackgroundColor3 = BLANC
	pastille.BorderSizePixel = 0
	pastille.Parent = contenu
	Style.coins(pastille, 999)
	Style.bordure(pastille, 3)
	Style.degrade(pastille, Style.boutons.violet[2]:Lerp(couleurs.fond, 0.35), Style.boutons.violet[2]:Lerp(couleurs.fond, 0.7))
	local niveauTexte = Style.texte(pastille, {
		Name = "Niveau",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -20, 0.8, 0),
		Text = "",
		contour = 3,
		tailleMax = 26,
	})

	-- gros multiplicateur « x1,5 ➜ x2 » sur une carte violette
	local rangeeMult = Style.carte(contenu, {
		Name = "Multiplicateur",
		BackgroundColor3 = Style.boutons.violet[2]:Lerp(couleurs.fond, 0.62),
		Position = UDim2.fromScale(0, 0.088),
		Size = UDim2.fromScale(1, 0.172),
	})
	reflet(rangeeMult, 12, 0.12)
	local multActuel = Style.texte(rangeeMult, {
		Name = "Actuel",
		Position = UDim2.fromScale(0, 0.06),
		Size = UDim2.fromScale(0.4, 0.88),
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "x1",
		ZIndex = 3,
		titre = true,
		contour = 4,
		tailleMax = 60,
	})
	local fleche = Style.texte(rangeeMult, {
		Name = "Fleche",
		Position = UDim2.fromScale(0.4, 0.18),
		Size = UDim2.fromScale(0.2, 0.64),
		Text = "➜",
		TextColor3 = couleurs.revenu,
		ZIndex = 3,
		contour = 3,
		tailleMax = 46,
	})
	local multSuivant = Style.texte(rangeeMult, {
		Name = "Suivant",
		Position = UDim2.fromScale(0.6, 0.02),
		Size = UDim2.fromScale(0.4, 0.96),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "x1",
		ZIndex = 3,
		titre = true,
		contour = 4,
		tailleMax = 70,
	})
	Style.degradeRarete(multSuivant, "Divin")

	-- coût de la suivante (argent vert)
	local coutTexte = Style.texte(contenu, {
		Name = "Cout",
		Position = UDim2.fromScale(0, 0.272),
		Size = UDim2.fromScale(1, 0.062),
		Text = "",
		TextColor3 = VERT,
		contour = 3,
		tailleMax = 28,
	})

	-- barre de progression Argent / coût : rail creusé, remplissage vert brillant, repères, pourcentage
	local barre = Instance.new("Frame")
	barre.Name = "Barre"
	barre.Position = UDim2.fromScale(0, 0.344)
	barre.Size = UDim2.fromScale(1, 0.1)
	barre.BackgroundColor3 = BLANC
	barre.BorderSizePixel = 0
	barre.ClipsDescendants = true
	barre.Parent = contenu
	Style.coins(barre, 14)
	Style.bordure(barre, 4)
	Style.degrade(barre, couleurs.fond:Lerp(NOIR, 0.35), couleurs.carte)

	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(0, 1)
	remplissage.BackgroundColor3 = BLANC
	remplissage.BorderSizePixel = 0
	remplissage.ClipsDescendants = true
	remplissage.ZIndex = 1
	remplissage.Parent = barre
	Style.coins(remplissage, 14)
	local degradeRemplissage = Style.degrade(remplissage, Style.boutons.vert[1], Style.boutons.vert[2])
	reflet(remplissage, 8, 0.55)

	-- éclat qui balaie la barre quand la renaissance est possible
	local balayage = Instance.new("Frame")
	balayage.Name = "Balayage"
	balayage.BackgroundColor3 = BLANC
	balayage.BorderSizePixel = 0
	balayage.Position = UDim2.fromScale(-0.35, 0.1)
	balayage.Size = UDim2.fromScale(0.22, 0.8)
	balayage.ZIndex = 3
	balayage.Visible = false
	balayage.Parent = remplissage
	Style.coins(balayage, 8)
	local fonduBalayage = Instance.new("UIGradient")
	fonduBalayage.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	fonduBalayage.Parent = balayage

	-- repères à 25 / 50 / 75 %
	for i = 1, 3 do
		local repere = Instance.new("Frame")
		repere.Name = "Repere" .. i
		repere.AnchorPoint = Vector2.new(0.5, 0.5)
		repere.Position = UDim2.fromScale(i * 0.25, 0.5)
		repere.Size = UDim2.new(0, 3, 0.46, 0)
		repere.BackgroundColor3 = couleurs.contour
		repere.BackgroundTransparency = 0.55
		repere.BorderSizePixel = 0
		repere.ZIndex = 2
		repere.Parent = barre
		Style.coins(repere, 2)
	end

	local barreTexte = Style.texte(barre, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.new(0.74, -14, 0.72, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 4,
		contour = 3,
		tailleMax = 28,
	})
	local pourcentTexte = Style.texte(barre, {
		Name = "Pourcent",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0.24, -8, 0.72, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
		ZIndex = 4,
		titre = true,
		contour = 3,
		tailleMax = 30,
	})

	-- cartes « Tu perds » / « Tu gagnes » : bandeau de titre coloré sur une ligne, deux lignes dessous
	local function colonne(nom, x, titre, couleur, palette)
		local c = Style.carte(contenu, {
			Name = nom,
			Position = UDim2.fromScale(x, 0.468),
			Size = UDim2.fromScale(0.485, 0.278),
		})
		local bord = c:FindFirstChild("Bordure")
		if bord then
			bord.Color = couleur
		end
		local entete = Instance.new("Frame")
		entete.Name = "Entete"
		entete.AnchorPoint = Vector2.new(0.5, 0)
		entete.Position = UDim2.new(0.5, 0, 0, 8)
		entete.Size = UDim2.new(1, -16, 0.26, 0)
		entete.BackgroundColor3 = BLANC
		entete.BorderSizePixel = 0
		entete.Parent = c
		Style.coins(entete, 10)
		Style.bordure(entete, 3)
		Style.degrade(entete, palette[1], palette[2])
		reflet(entete, 6, 0.35)
		Style.texte(entete, {
			Name = "Titre",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.new(1, -12, 0.8, 0),
			Text = titre,
			ZIndex = 3,
			titre = true,
			contour = 3,
			tailleMax = 26,
		})
		local lignes = {}
		for i = 1, 2 do
			lignes[i] = Style.texte(c, {
				Name = "Ligne" .. i,
				Position = UDim2.fromScale(0.06, 0.38 + (i - 1) * 0.3),
				Size = UDim2.fromScale(0.88, 0.26),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "",
				contour = 2.5,
				tailleMax = 22,
			})
		end
		-- fin séparateur entre les deux lignes
		local separateur = Instance.new("Frame")
		separateur.Name = "Separateur"
		separateur.AnchorPoint = Vector2.new(0.5, 0.5)
		separateur.Position = UDim2.fromScale(0.5, 0.665)
		separateur.Size = UDim2.new(0.88, 0, 0, 2)
		separateur.BackgroundColor3 = BLANC
		separateur.BackgroundTransparency = 0.85
		separateur.BorderSizePixel = 0
		separateur.Parent = c
		return c, lignes
	end
	local colPerte, lignesPerte = colonne("Perte", 0, "TU" .. ESPACE_INSECABLE .. "PERDS", ROUGE, Style.boutons.rouge)
	local colGain, lignesGain = colonne("Gain", 0.515, "TU" .. ESPACE_INSECABLE .. "GAGNES", VERT, Style.boutons.vert)

	-- « MAX » géant doré à la place des cartes
	local messageMax = Style.texte(contenu, {
		Name = "Max",
		Position = UDim2.fromScale(0, 0.468),
		Size = UDim2.fromScale(1, 0.278),
		Text = "👑 MAX 👑",
		Visible = false,
		titre = true,
		contour = 4,
		tailleMax = 90,
	})
	Style.degradeRarete(messageMax, "Legendaire")

	local raison = Style.texte(contenu, {
		Name = "Raison",
		Position = UDim2.fromScale(0, 0.762),
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
	local jetonAnimation = 0    -- invalide les fins d'animation périmées (ouvrir / fermer)
	local tweenBalayage = nil

	local boutonRenaitre, libelleRenaitre

	local function styleBouton(texte, couleur)
		libelleRenaitre.Text = texte
		Style.couleurBouton(boutonRenaitre, couleur)
	end

	-- éclat de la barre : actif seulement quand le panneau est ouvert et la renaissance possible
	local function eclat(actif)
		if actif and ouvert then
			if tweenBalayage then
				return
			end
			balayage.Position = UDim2.fromScale(-0.35, 0.1)
			balayage.Visible = true
			local ok, tween = pcall(function()
				return TweenService:Create(balayage, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 1.1), {
					Position = UDim2.fromScale(1.15, 0.1),
				})
			end)
			if ok and tween then
				tweenBalayage = tween
				tween:Play()
			end
		else
			if tweenBalayage then
				pcall(function()
					tweenBalayage:Cancel()
				end)
				tweenBalayage = nil
			end
			balayage.Visible = false
		end
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
			multActuel.Size = UDim2.fromScale(1, 0.88)
			multActuel.TextXAlignment = Enum.TextXAlignment.Center
		else
			multActuel.Size = UDim2.fromScale(0.4, 0.88)
			multActuel.TextXAlignment = Enum.TextXAlignment.Right
			multSuivant.Text = "x" .. formaterMultiplicateur(multiplicateurDe(niveau + 1))
		end

		local progression = 1
		local pourcent = ""
		if estMax then
			coutTexte.Text = "Renaissance maximale atteinte !"
			coutTexte.TextColor3 = couleurs.revenu
			barreTexte.Text = "👑 MAX"
			pourcent = "100%"
		else
			coutTexte.TextColor3 = VERT
			local cout = coutDe(niveau)
			if cout and cout > 0 then
				progression = math.clamp(argent / cout, 0, 1)
				coutTexte.Text = "Coût : " .. montant(cout)
				barreTexte.Text = montant(argent) .. " / " .. montant(cout)
				-- arrondi vers le bas : « 100% » seulement quand on a vraiment la somme
				pourcent = math.floor(progression * 100) .. "%"
			elseif cout then
				coutTexte.Text = "Coût : GRATUIT"
				barreTexte.Text = montant(argent)
				pourcent = "100%"
			else
				progression = 0
				coutTexte.Text = "Coût : indisponible"
				barreTexte.Text = "..."
				pourcent = "--"
			end
			-- textes courts et de même longueur que ceux de « TU GAGNES » : même taille de police
			lignesPerte[1].Text = "💸 Argent remis à " .. montant(ARGENT_DEPART)
			lignesPerte[2].Text = "🦖 Dinos de ta Base"
			lignesGain[1].Text = "💰 Revenus x" .. formaterMultiplicateur(multiplicateurDe(niveau + 1))
			if emplacementsDe(niveau + 1) > emplacementsDe(niveau) then
				lignesGain[2].Text = "🏠 +1 emplacement (" .. emplacementsDe(niveau + 1) .. ")"
			else
				lignesGain[2].Text = "🏠 Emplacements déjà au max"
			end
		end

		-- barre : or au maximum, vert sinon ; pourcentage jaune quand la barre est pleine
		local palette = Style.boutons.vert
		if estMax then
			palette = Style.boutons.jaune
		end
		degradeRemplissage.Color = ColorSequence.new(palette[1], palette[2])
		pourcentTexte.Text = pourcent
		if progression >= 1 then
			pourcentTexte.TextColor3 = couleurs.revenu
		else
			pourcentTexte.TextColor3 = couleurs.texte
		end
		animer(remplissage, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			Size = UDim2.fromScale(progression, 1),
		})

		-- bouton
		local ok, pourquoi = possible()
		eclat(ok and not estMax)
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
		if not ouvert or os.clock() < finAttente then
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

	-- ===== ouverture (fondu + rebond) / fermeture (fondu + léger rétrécissement) =====
	local function fermer()
		if not ouvert then
			return
		end
		ouvert = false
		annulerConfirmation()
		eclat(false)
		jetonAnimation = jetonAnimation + 1
		local jeton = jetonAnimation
		animer(fond, DUREE_FERMETURE, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { BackgroundTransparency = 1 })
		animer(groupe, DUREE_FERMETURE, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { GroupTransparency = 1 })
		animer(echellePanneau, DUREE_FERMETURE, Enum.EasingStyle.Quad, Enum.EasingDirection.In, { Scale = 0.88 })
		task.delay(DUREE_FERMETURE + 0.02, function()
			if jetonAnimation == jeton and not ouvert then
				fond.Visible = false
			end
		end)
	end

	local function ouvrir()
		annulerConfirmation()
		ouvert = true
		jetonAnimation = jetonAnimation + 1
		-- départ : voile clair, panneau transparent et réduit, barre vide (elle se remplit à l'ouverture)
		fond.BackgroundTransparency = 1
		groupe.GroupTransparency = 1
		echellePanneau.Scale = 0.8
		remplissage.Size = UDim2.fromScale(0, 1)
		fond.Visible = true
		rafraichir()
		animer(fond, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = OPACITE_FOND })
		animer(groupe, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { GroupTransparency = 0 })
		animer(echellePanneau, DUREE_OUVERTURE, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
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
