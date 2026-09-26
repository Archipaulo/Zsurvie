-- Interface/Musique : trois ambiances en boucle (Lobby, Horde, Colosse) choisies selon l'état du jeu,
-- avec fondu enchaîné, et un petit bouton « 🎵 » en haut à droite pour couper ou remettre la musique.
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local M = {}

local DUREE_FONDU = 1.5 -- secondes du fondu enchaîné
local ATTRIBUT_COUPEE = "MusiqueCoupee"

-- Pistes d'ambiance : mettez ici l'id de votre piste (Creator Store), par exemple "rbxassetid://1234567890".
-- Tant qu'un SoundId reste vide, l'ambiance correspondante ne joue rien.
local PISTES = {
	Lobby = { soundId = "", volume = 0.35 }, -- mettez ici l'id de votre piste (Creator Store)
	Horde = { soundId = "", volume = 0.4 }, -- mettez ici l'id de votre piste (Creator Store)
	Colosse = { soundId = "", volume = 0.45 }, -- mettez ici l'id de votre piste (Creator Store)
}

local ORDRE_PISTES = { "Lobby", "Horde", "Colosse" }

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Etat = ctx.Etat
	local joueur = ctx.joueur
	local Bus = ctx.Bus

	-- dossier des pistes : SoundService si possible, sinon l'écran du joueur
	local parent = ctx.gui
	local okService = pcall(function()
		local _ = SoundService.Name
	end)
	if okService and SoundService then
		parent = SoundService
	end
	local ancien = parent:FindFirstChild("ZsurvieMusique")
	if ancien then
		ancien:Destroy()
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "ZsurvieMusique"
	dossier.Parent = parent

	-- création des sons (volume nul au départ)
	local sons = {}
	for _, nom in ipairs(ORDRE_PISTES) do
		local def = PISTES[nom]
		local ok, son = pcall(function()
			local s = Instance.new("Sound")
			s.Name = "Ambiance" .. nom
			s.Looped = true
			s.Volume = 0
			s.SoundId = def.soundId
			s.Parent = dossier
			return s
		end)
		if ok and son then
			sons[nom] = son
		end
	end

	-- une piste n'est jouable que si son SoundId est renseigné
	local function jouable(nom)
		local def = PISTES[nom]
		if not def or not sons[nom] then
			return false
		end
		return type(def.soundId) == "string" and def.soundId ~= ""
	end

	local fondus = {}

	local function annulerFondu(nom)
		local t = fondus[nom]
		if t then
			pcall(function()
				t:Cancel()
			end)
			fondus[nom] = nil
		end
	end

	-- fondu du volume d'une piste vers une cible ; à zéro, la piste est arrêtée
	local function fondre(nom, cible)
		local son = sons[nom]
		if not son then
			return
		end
		annulerFondu(nom)
		local ok, tween = pcall(function()
			return TweenService:Create(son, TweenInfo.new(DUREE_FONDU, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Volume = cible })
		end)
		if not ok or not tween then
			son.Volume = cible
			if cible <= 0 then
				pcall(function()
					son:Stop()
				end)
			end
			return
		end
		fondus[nom] = tween
		tween.Completed:Connect(function(etat)
			if fondus[nom] == tween then
				fondus[nom] = nil
			end
			if etat == Enum.PlaybackState.Completed and cible <= 0 then
				pcall(function()
					son:Stop()
				end)
			end
		end)
		tween:Play()
	end

	local function estCoupee()
		return joueur:GetAttribute(ATTRIBUT_COUPEE) == true
	end

	-- ambiance voulue selon la phase et la présence d'un Colosse
	local function ambianceVoulue()
		if estCoupee() then
			return nil
		end
		local phase = Etat:GetAttribute("Phase")
		local colosse = Etat:GetAttribute("ColosseActif") == true
		local nom = nil
		if phase == "Horde" then
			if colosse then
				nom = "Colosse"
			else
				nom = "Horde"
			end
		elseif phase == "Lobby" or phase == "Repit" or phase == nil then
			nom = "Lobby"
		end
		-- repli : Colosse sans piste -> Horde
		if nom == "Colosse" and not jouable("Colosse") then
			nom = "Horde"
		end
		if nom and not jouable(nom) then
			return nil
		end
		return nom
	end

	local actuelle = nil

	local function actualiser()
		local voulue = ambianceVoulue()
		if voulue == actuelle then
			return
		end
		if actuelle then
			fondre(actuelle, 0)
		end
		actuelle = voulue
		if voulue then
			local son = sons[voulue]
			if son and not son.IsPlaying then
				son.Volume = 0
				pcall(function()
					son:Play()
				end)
			end
			fondre(voulue, PISTES[voulue].volume)
		end
	end

	-- bouton « 🎵 » en haut à droite (sous la barre Roblox)
	local bouton = Outils.bouton(ctx.gui, {
		Name = "BoutonMusique",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 60),
		Size = UDim2.new(0, 40, 0, 40),
		Text = "🎵",
		Font = Charte.policeTexte,
		BackgroundColor3 = Charte.encre,
		BackgroundTransparency = 0.2,
		TextColor3 = Charte.creme,
		ZIndex = 5,
	})
	local contour = Instance.new("UIStroke")
	contour.Thickness = 2
	contour.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contour.Color = Charte.toit
	contour.Parent = bouton

	local function majBouton()
		if estCoupee() then
			bouton.TextTransparency = 0.6
			contour.Color = Charte.ardoise
		else
			bouton.TextTransparency = 0
			contour.Color = Charte.toit
		end
	end

	bouton.Activated:Connect(function()
		joueur:SetAttribute(ATTRIBUT_COUPEE, not estCoupee())
		if Bus and Bus.emettre then
			Bus.emettre("Son", "clic")
		end
	end)

	joueur:GetAttributeChangedSignal(ATTRIBUT_COUPEE):Connect(function()
		majBouton()
		actualiser()
	end)
	Etat:GetAttributeChangedSignal("Phase"):Connect(actualiser)
	Etat:GetAttributeChangedSignal("ColosseActif"):Connect(actualiser)

	majBouton()
	actualiser()
end

return M
