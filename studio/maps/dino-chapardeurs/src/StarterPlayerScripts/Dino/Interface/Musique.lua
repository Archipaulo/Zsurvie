-- Interface Musique : trois ambiances en boucle (Jungle, Evenement, Vol) avec fondu enchaîné,
-- et un bouton rond « 🎵 » (style simulateur) en haut à droite pour couper la musique (attribut local MusiqueCoupee).
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local M = {}

-- pistes des ambiances : laissées vides, rien ne joue tant qu'aucun id n'est renseigné
local PISTES = {
	Jungle = "", -- mettez ici l'id de votre piste (ex. "rbxassetid://123456789")
	Evenement = "", -- mettez ici l'id de votre piste
	Vol = "", -- mettez ici l'id de votre piste
}

local function nombre(t, cle, defaut)
	if type(t) == "table" and type(t[cle]) == "number" then
		return t[cle]
	end
	return defaut
end

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local joueur = ctx.joueur
	local Etat = ctx.Etat

	-- réglages (surchargés par Equilibrage.musique s'il existe)
	local reglages = ctx.Equilibrage and ctx.Equilibrage.musique
	local DUREE_FONDU = nombre(reglages, "fondu", 1.5)
	local VOLUME = nombre(reglages, "volume", 0.35)
	local PERIODE_CONTROLE = nombre(reglages, "controle", 2)

	-- dossier local des sons (côté client : entendu par ce joueur seulement)
	local ancien = SoundService:FindFirstChild("DinoMusique")
	if ancien then
		pcall(function() ancien:Destroy() end)
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "DinoMusique"
	dossier.Parent = SoundService

	local pistes = {}
	for nom, id in pairs(PISTES) do
		local son = Instance.new("Sound")
		son.Name = nom
		son.SoundId = id
		son.Looped = true
		son.Volume = 0
		son.Parent = dossier
		pistes[nom] = { son = son, generation = 0, tween = nil }
	end

	local actuelle = nil
	local coupee = joueur:GetAttribute("MusiqueCoupee") == true

	-- fondu d'une piste vers un volume ; met la piste en pause une fois silencieuse
	local function fondre(piste, cible)
		piste.generation = piste.generation + 1
		local generation = piste.generation
		local son = piste.son
		if piste.tween then
			pcall(function() piste.tween:Cancel() end)
			piste.tween = nil
		end
		if cible > 0 then
			if son.SoundId == "" then
				return
			end
			if not son.IsPlaying then
				pcall(function() son:Play() end)
			end
		elseif not son.IsPlaying then
			son.Volume = 0
			return
		end
		local ok, tween = pcall(function()
			return TweenService:Create(son, TweenInfo.new(DUREE_FONDU, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Volume = cible })
		end)
		if not ok or not tween then
			son.Volume = cible
			if cible <= 0 then
				pcall(function() son:Pause() end)
			end
			return
		end
		piste.tween = tween
		tween.Completed:Connect(function()
			if piste.generation ~= generation then
				return
			end
			piste.tween = nil
			if cible <= 0 then
				pcall(function() son:Pause() end)
			end
		end)
		tween:Play()
	end

	-- quelle ambiance doit jouer maintenant
	local function ambianceVoulue()
		local porte = joueur:GetAttribute("Porte")
		if type(porte) == "string" and porte ~= "" then
			return "Vol"
		end
		local evenement = Etat and Etat:GetAttribute("Evenement")
		if type(evenement) == "string" and evenement ~= "" then
			return "Evenement"
		end
		return "Jungle"
	end

	local function actualiser(force)
		local voulue = ambianceVoulue()
		if coupee then
			voulue = nil
		end
		if voulue == actuelle and not force then
			return
		end
		actuelle = voulue
		for nom, piste in pairs(pistes) do
			if nom == voulue then
				fondre(piste, VOLUME)
			else
				fondre(piste, 0)
			end
		end
	end

	-- bouton rond « 🎵 » bleu en haut à droite (sous la barre Roblox), « 🔇 » barré quand coupé
	local Style = ctx.Style
	local bouton
	local libelle
	local barre

	local function majBouton()
		if not bouton then
			return
		end
		if coupee then
			if Style then
				Style.couleurBouton(bouton, "gris")
			else
				bouton.BackgroundColor3 = Charte.pierre
			end
			if libelle then libelle.Text = "🔇" end
			if barre then barre.Visible = true end
		else
			if Style then
				Style.couleurBouton(bouton, "bleu")
			else
				bouton.BackgroundColor3 = Charte.jungle
			end
			if libelle then libelle.Text = "🎵" end
			if barre then barre.Visible = false end
		end
	end

	local function basculer()
		joueur:SetAttribute("MusiqueCoupee", not coupee)
	end

	local ok = pcall(function()
		if Style then
			bouton, libelle = Style.bouton(ctx.gui, {
				Name = "BoutonMusique",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 64),
				Size = UDim2.fromOffset(56, 56),
				couleur = "bleu",
				icone = "🎵",
				rayon = 28,
				tailleMax = 30,
				ZIndex = 5,
			}, basculer)
		else
			bouton = Outils.bouton(ctx.gui, {
				Name = "BoutonMusique",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 64),
				Size = UDim2.new(0, 56, 0, 56),
				Text = "🎵",
				BackgroundColor3 = Charte.jungle,
				TextColor3 = Charte.creme,
				ZIndex = 5,
			}, basculer)
			libelle = bouton
		end
		-- trait rouge en diagonale, cerné de noir, quand la musique est coupée
		barre = Instance.new("Frame")
		barre.Name = "Barre"
		barre.AnchorPoint = Vector2.new(0.5, 0.5)
		barre.Position = UDim2.new(0.5, 0, 0.5, 0)
		barre.Size = UDim2.new(0.82, 0, 0, 6)
		barre.Rotation = -45
		barre.BorderSizePixel = 0
		barre.BackgroundColor3 = Charte.alerte
		barre.ZIndex = 7
		barre.Visible = false
		if Style then
			Style.coins(barre, 3)
			Style.bordure(barre, 2)
		end
		barre.Parent = bouton
	end)
	if not ok then
		bouton = nil
		libelle = nil
		barre = nil
	end
	majBouton()

	-- écoute des changements
	joueur:GetAttributeChangedSignal("MusiqueCoupee"):Connect(function()
		coupee = joueur:GetAttribute("MusiqueCoupee") == true
		majBouton()
		actualiser(false)
	end)
	joueur:GetAttributeChangedSignal("Porte"):Connect(function()
		actualiser(false)
	end)
	if Etat then
		Etat:GetAttributeChangedSignal("Evenement"):Connect(function()
			actualiser(false)
		end)
	end

	actualiser(true)

	-- contrôle périodique de secours (id de piste renseigné en cours de partie, son arrêté…)
	while dossier.Parent do
		task.wait(PERIODE_CONTROLE)
		local voulue = actuelle
		if voulue and pistes[voulue] then
			local piste = pistes[voulue]
			if piste.son.SoundId ~= "" and not piste.son.IsPlaying then
				actualiser(true)
			end
		end
		if ambianceVoulue() ~= voulue and not coupee then
			actualiser(false)
		end
	end
end

return M
