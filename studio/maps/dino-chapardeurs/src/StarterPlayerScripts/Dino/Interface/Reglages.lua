-- Interface Reglages : bouton « ⚙️ » en haut à droite qui ouvre le panneau RÉGLAGES :
-- un curseur pour le volume de la MUSIQUE et un pour les EFFETS SONORES (0 à 100 %), chacun avec un bouton muet.
-- Les valeurs sont appliquées tout de suite en local (attributs VolumeMusique / VolumeEffets du joueur,
-- lus par Interface/Musique et Interface/Sons) puis envoyées au serveur, qui les sauvegarde (Systemes/Donnees).
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local M = {}

function M.demarrer(ctx)
	local Style = ctx.Style
	local Bus = ctx.Bus
	local joueur = ctx.joueur
	local Reseau = ctx.Reseau
	if not Style then return end
	local C = Style.couleurs

	local function lire(nom)
		local v = joueur:GetAttribute(nom)
		if type(v) ~= "number" then return 1 end
		return math.clamp(v, 0, 1)
	end

	-- envoi au serveur, regroupé (pas à chaque pixel du glisser)
	local aEnvoyer = false
	local function envoyer()
		if aEnvoyer then return end
		aEnvoyer = true
		task.delay(0.4, function()
			aEnvoyer = false
			pcall(function()
				Reseau.Reglages:FireServer({ musique = lire("VolumeMusique"), effets = lire("VolumeEffets") })
			end)
		end)
	end

	-- ===== bouton ⚙️ (à gauche du bouton 🎵) =====
	Style.bouton(ctx.gui, {
		Name = "BoutonReglages",
		Size = UDim2.fromOffset(56, 56),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -76, 0, 64),
		couleur = "gris",
		texte = "⚙️",
		rayon = 28,
	}, function()
		Bus.emettre("OuvrirPanneau", "Reglages")
	end)

	-- ===== le panneau =====
	local panneau, contenu, fermer = Style.panneau(ctx.gui, {
		Name = "PanneauReglages",
		titre = "RÉGLAGES",
		icone = "⚙️",
		couleur = "bleu",
		Size = UDim2.new(0.5, 0, 0.5, 0),
	})
	local contrainte = panneau:FindFirstChildOfClass("UISizeConstraint")
	if contrainte then
		contrainte.MaxSize = Vector2.new(560, 340)
		contrainte.MinSize = Vector2.new(320, 300)
	end
	panneau.Visible = false
	panneau.ZIndex = 20

	local liste = Instance.new("UIListLayout")
	liste.Padding = UDim.new(0, 18)
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.HorizontalAlignment = Enum.HorizontalAlignment.Center
	liste.VerticalAlignment = Enum.VerticalAlignment.Center
	liste.Parent = contenu

	-- une ligne : icône + titre + pourcentage, puis curseur + bouton muet
	local function ligne(ordre, icone, titre, attribut)
		local carte = Style.carte(contenu, { Name = attribut, LayoutOrder = ordre, Size = UDim2.new(1, 0, 0, 96) })
		Style.texte(carte, {
			Name = "Titre",
			Position = UDim2.fromOffset(16, 8),
			Size = UDim2.new(0.6, 0, 0, 32),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = icone .. " " .. titre,
			tailleMax = 26,
		})
		local pourcent = Style.texte(carte, {
			Name = "Pourcent",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -86, 0, 8),
			Size = UDim2.fromOffset(90, 32),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = C.argent,
			Text = "100 %",
			tailleMax = 26,
		})
		-- rail du curseur
		local rail = Instance.new("Frame")
		rail.Name = "Rail"
		rail.Active = true
		rail.Position = UDim2.new(0, 20, 0, 58)
		rail.Size = UDim2.new(1, -130, 0, 14)
		rail.BackgroundColor3 = C.fond
		rail.BorderSizePixel = 0
		Style.coins(rail, 7)
		Style.bordure(rail, 2)
		rail.Parent = carte
		local rempli = Instance.new("Frame")
		rempli.Name = "Rempli"
		rempli.Size = UDim2.fromScale(1, 1)
		rempli.BackgroundColor3 = Color3.new(1, 1, 1)
		rempli.BorderSizePixel = 0
		Style.coins(rempli, 7)
		Style.degrade(rempli, Style.boutons.vert[1], Style.boutons.vert[2], 0)
		rempli.Parent = rail
		local poignee = Instance.new("Frame")
		poignee.Name = "Poignee"
		poignee.AnchorPoint = Vector2.new(0.5, 0.5)
		poignee.Size = UDim2.fromOffset(28, 28)
		poignee.Position = UDim2.fromScale(1, 0.5)
		poignee.BackgroundColor3 = Color3.new(1, 1, 1)
		poignee.BorderSizePixel = 0
		poignee.ZIndex = 3
		Style.coins(poignee, 14)
		Style.bordure(poignee, 3)
		poignee.Parent = rail

		local memoire = 1 -- volume avant la mise en sourdine
		local muet
		local function afficher(v)
			rempli.Size = UDim2.fromScale(v, 1)
			poignee.Position = UDim2.fromScale(v, 0.5)
			pourcent.Text = math.floor(v * 100 + 0.5) .. " %"
			if muet then
				local lib = muet:FindFirstChild("Libelle")
				if lib then lib.Text = (v <= 0) and "🔇" or "🔊" end
				Style.couleurBouton(muet, (v <= 0) and "rouge" or "vert")
			end
		end
		local function regler(v)
			v = math.clamp(v, 0, 1)
			joueur:SetAttribute(attribut, v) -- effet immédiat en local
			afficher(v)
			envoyer()
		end
		muet = Style.bouton(carte, {
			Name = "Muet",
			Size = UDim2.fromOffset(56, 44),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 44),
			couleur = "vert",
			texte = "🔊",
			rayon = 12,
		}, function()
			local v = lire(attribut)
			if v > 0 then
				memoire = v
				regler(0)
			else
				regler(memoire > 0 and memoire or 1)
			end
			Bus.emettre("Son", "clic")
		end)

		-- glisser sur le rail (souris et tactile)
		local glisse = false
		local function depuisEcran(x)
			local debut, largeur = rail.AbsolutePosition.X, rail.AbsoluteSize.X
			if largeur <= 0 then return end
			regler((x - debut) / largeur)
		end
		rail.InputBegan:Connect(function(entree)
			if entree.UserInputType == Enum.UserInputType.MouseButton1 or entree.UserInputType == Enum.UserInputType.Touch then
				glisse = true
				depuisEcran(entree.Position.X)
			end
		end)
		UserInputService.InputChanged:Connect(function(entree)
			if glisse and (entree.UserInputType == Enum.UserInputType.MouseMovement or entree.UserInputType == Enum.UserInputType.Touch) then
				depuisEcran(entree.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(entree)
			if entree.UserInputType == Enum.UserInputType.MouseButton1 or entree.UserInputType == Enum.UserInputType.Touch then
				if glisse then
					glisse = false
					-- petit « ping » pour entendre le nouveau volume des effets
					if attribut == "VolumeEffets" then Bus.emettre("Son", "argent") end
				end
			end
		end)

		joueur:GetAttributeChangedSignal(attribut):Connect(function()
			if not glisse then afficher(lire(attribut)) end
		end)
		afficher(lire(attribut))
	end

	ligne(1, "🎹", "MUSIQUE", "VolumeMusique")
	ligne(2, "🔔", "EFFETS SONORES", "VolumeEffets")

	-- ===== ouverture / fermeture =====
	local function ouvrir()
		panneau.Visible = true
		Style.pop(panneau)
	end
	local function fermerPanneau()
		panneau.Visible = false
	end
	fermer.Activated:Connect(fermerPanneau)
	Bus.ecouter("OuvrirPanneau", function(nom)
		if nom == "Reglages" then
			if panneau.Visible then fermerPanneau() else ouvrir() end
		else
			fermerPanneau()
		end
	end)
	Bus.ecouter("FermerPanneaux", fermerPanneau)
	UserInputService.InputBegan:Connect(function(entree, traite)
		if not traite and entree.KeyCode == Enum.KeyCode.Escape then fermerPanneau() end
	end)
end

return M
