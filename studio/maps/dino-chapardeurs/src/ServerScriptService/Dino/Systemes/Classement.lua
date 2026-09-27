-- Système Classement : leaderstats des joueurs, meilleur revenu du serveur et tableau d'honneur sur la Place.
-- Tableau d'honneur (version 2) : panneau en bois sombre à cadre de métal doré, écran lumineux éclairé
-- par deux lampes, fronton sculpté avec plaque gravée et trophée d'or, posé sur deux pieds de pierre.
local Players = game:GetService("Players")

local M = {}

local PERIODE_MEILLEUR = 2   -- secondes entre deux calculs de Etat.MeilleurRevenu
local PERIODE_TABLEAU = 5    -- secondes entre deux mises à jour du tableau d'honneur
local NB_LIGNES = 5          -- top 5 par revenu/s

-- dimensions du tableau (studs)
local LARGEUR = 12           -- largeur de l'écran
local HAUTEUR = 8            -- hauteur de l'écran
local EPAISSEUR = 0.2        -- épaisseur de l'écran
local HAUT_BAS = 2.4         -- hauteur du bas de l'écran au-dessus du sol
local CADRE = 0.45           -- largeur des baguettes du cadre doré
local ECART_POTEAU = 7.5     -- distance du centre à l'axe de chaque poteau
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

-- ===== tableau d'honneur : la structure =====
local function construireStructure(ctx, modele, local_)
	local C = ctx.Charte
	local O = ctx.Outils
	local rad = math.rad
	local VERTICAL = CFrame.Angles(0, 0, rad(90))   -- cylindre debout (axe X -> Y)

	local boisSombre = C.ombre(C.ombre(C.bois))
	local boisNoir = C.ombre(boisSombre)
	local pierreClaire = C.lumiere(C.pierre)
	local pierreSombre = C.ombre(C.pierre)
	local orClair = C.lumiere(C.dore)
	local orSombre = C.ombre(C.dore)

	local yBas = HAUT_BAS
	local yHaut = HAUT_BAS + HAUTEUR
	local yCentre = HAUT_BAS + HAUTEUR / 2
	local hautDos = HAUTEUR + 1.6
	local yDosHaut = yCentre + hautDos / 2
	local ySocle = 2.0                              -- dessus des pieds de pierre
	local yPoteauHaut = yDosHaut + 1.0

	local solides = {}
	local function solide(inst)
		if inst:IsA("BasePart") then
			solides[inst] = true
		else
			for _, p in ipairs(inst:GetDescendants()) do
				if p:IsA("BasePart") then solides[p] = true end
			end
		end
		return inst
	end

	-- pieds en pierre et poteaux en bois sombre cerclés d'or
	for _, cote in ipairs({ -1, 1 }) do
		local x = cote * ECART_POTEAU
		local suffixe = "G"
		if cote > 0 then suffixe = "D" end
		solide(O.bloc(modele, {
			Name = "Plinthe" .. suffixe,
			Size = Vector3.new(2.7, 0.35, 2.7),
			CFrame = local_(x, 0.175, 0.3),
			Color = pierreSombre,
			Material = Enum.Material.Slate,
		}))
		solide(O.blocArrondi(modele, {
			Name = "Pied" .. suffixe,
			Size = Vector3.new(2.2, 1.35, 2.2),
			CFrame = local_(x, 0.35 + 0.675, 0.3),
			Color = C.pierre,
			Material = Enum.Material.Cobblestone,
		}, 0.45))
		solide(O.bloc(modele, {
			Name = "Chapiteau" .. suffixe,
			Size = Vector3.new(2.45, 0.3, 2.45),
			CFrame = local_(x, ySocle - 0.15, 0.3),
			Color = pierreClaire,
			Material = Enum.Material.Slate,
		}))

		local hautPoteau = yPoteauHaut - ySocle
		solide(O.bloc(modele, {
			Name = "Poteau" .. suffixe,
			Size = Vector3.new(1.1, hautPoteau, 1.1),
			CFrame = local_(x, ySocle + hautPoteau / 2, 0.3),
			Color = boisSombre,
			Material = Enum.Material.Wood,
		}))
		for _, yBague in ipairs({ ySocle + 0.35, yDosHaut - 0.2 }) do
			O.bloc(modele, {
				Name = "Bague",
				Size = Vector3.new(1.26, 0.24, 1.26),
				CFrame = local_(x, yBague, 0.3),
				Color = C.dore,
				Material = Enum.Material.Metal,
			})
		end
		O.bloc(modele, {
			Name = "Coiffe",
			Size = Vector3.new(1.35, 0.3, 1.35),
			CFrame = local_(x, yPoteauHaut + 0.15, 0.3),
			Color = orSombre,
			Material = Enum.Material.Metal,
		})
		O.boule(modele, {
			Name = "Pommeau",
			Size = Vector3.new(0.95, 0.95, 0.95),
			CFrame = local_(x, yPoteauHaut + 0.3 + 0.42, 0.3),
			Color = orClair,
			Material = Enum.Material.Metal,
		})
	end

	-- dos du panneau en planches sombres, encastré dans les poteaux, avec traverses au revers
	solide(O.bloc(modele, {
		Name = "Dos",
		Size = Vector3.new(2 * ECART_POTEAU, hautDos, 0.5),
		CFrame = local_(0, yCentre, 0.35),
		Color = boisSombre,
		Material = Enum.Material.WoodPlanks,
	}))
	for _, yTraverse in ipairs({ yBas + 1, yHaut - 1 }) do
		O.bloc(modele, {
			Name = "Traverse",
			Size = Vector3.new(2 * ECART_POTEAU - 1.2, 0.6, 0.2),
			CFrame = local_(0, yTraverse, 0.7),
			Color = boisNoir,
			Material = Enum.Material.Wood,
		})
	end
	-- corniche sous le fronton et appui sous l'écran
	O.bloc(modele, {
		Name = "Corniche",
		Size = Vector3.new(2 * ECART_POTEAU - 0.8, 0.35, 0.85),
		CFrame = local_(0, yDosHaut + 0.175, 0.3),
		Color = boisNoir,
		Material = Enum.Material.Wood,
	})
	O.bloc(modele, {
		Name = "Appui",
		Size = Vector3.new(LARGEUR + 1.6, 0.3, 0.8),
		CFrame = local_(0, yBas - CADRE - 0.15, -0.05),
		Color = boisNoir,
		Material = Enum.Material.Wood,
	})

	-- écran (le SurfaceGui s'affiche sur sa face avant)
	local ecran = O.bloc(modele, {
		Name = "Panneau",
		Size = Vector3.new(LARGEUR, HAUTEUR, EPAISSEUR),
		CFrame = local_(0, yCentre, 0),
		Color = ctx.Style.couleurs.fond,
		Material = Enum.Material.SmoothPlastic,
	})
	local halo = O.lumiere(ecran, { genre = "Surface", Range = 10, Brightness = 0.6, Color = C.gemme })
	halo.Face = Enum.NormalId.Front
	halo.Angle = 110

	-- cadre en métal doré et rivets d'angle
	local zCadre = -0.05
	for _, cote in ipairs({ -1, 1 }) do
		O.bloc(modele, {
			Name = "CadreH",
			Size = Vector3.new(LARGEUR + 2 * CADRE, CADRE, 0.35),
			CFrame = local_(0, yCentre + cote * (HAUTEUR / 2 + CADRE / 2), zCadre),
			Color = C.dore,
			Material = Enum.Material.Metal,
		})
		O.bloc(modele, {
			Name = "CadreV",
			Size = Vector3.new(CADRE, HAUTEUR, 0.35),
			CFrame = local_(cote * (LARGEUR / 2 + CADRE / 2), yCentre, zCadre),
			Color = C.dore,
			Material = Enum.Material.Metal,
		})
	end
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			O.boule(modele, {
				Name = "Rivet",
				Size = Vector3.new(0.62, 0.62, 0.62),
				CFrame = local_(sx * (LARGEUR / 2 + CADRE / 2), yCentre + sy * (HAUTEUR / 2 + CADRE / 2), zCadre - 0.12),
				Color = orClair,
				Material = Enum.Material.Metal,
			})
		end
	end

	-- fronton sculpté : planche centrale + deux pentes, plaque gravée
	local yFronton = yDosHaut + 0.35 + 0.9
	local fronton = O.bloc(modele, {
		Name = "Fronton",
		Size = Vector3.new(8, 1.8, 0.6),
		CFrame = local_(0, yFronton, 0.3),
		Color = boisSombre,
		Material = Enum.Material.WoodPlanks,
	})
	for _, cote in ipairs({ -1, 1 }) do
		O.coin(modele, {
			Name = "Pente",
			Size = Vector3.new(0.6, 1.8, 2.6),
			CFrame = local_(cote * (4 + 1.3), yFronton, 0.3) * CFrame.Angles(0, rad(-90 * cote), 0),
			Color = boisSombre,
			Material = Enum.Material.WoodPlanks,
		})
	end
	O.bloc(modele, {
		Name = "Faite",
		Size = Vector3.new(8.2, 0.22, 0.75),
		CFrame = local_(0, yFronton + 0.9 + 0.11, 0.3),
		Color = C.dore,
		Material = Enum.Material.Metal,
	})
	local plaque = O.bloc(modele, {
		Name = "Plaque",
		Size = Vector3.new(6.6, 1.15, 0.12),
		CFrame = local_(0, yFronton - 0.05, 0.3 - 0.3 - 0.06),
		Color = C.dore,
		Material = Enum.Material.Metal,
	})
	O.texte(plaque, "Front", "TABLEAU D'HONNEUR", { couleur = C.encre, pixelsParStud = 40 })

	-- trophée d'or au sommet (lumière dorée)
	local ySommet = yFronton + 0.9 + 0.22
	O.bloc(modele, {
		Name = "SocleTrophee",
		Size = Vector3.new(1.7, 0.4, 1.2),
		CFrame = local_(0, ySommet + 0.2, 0.3),
		Color = pierreSombre,
		Material = Enum.Material.Marble,
	})
	O.cylindre(modele, {
		Name = "PiedTrophee",
		Size = Vector3.new(0.3, 1.15, 1.15),
		CFrame = local_(0, ySommet + 0.55, 0.3) * VERTICAL,
		Color = orSombre,
		Material = Enum.Material.Metal,
	})
	O.cylindre(modele, {
		Name = "Tige",
		Size = Vector3.new(0.7, 0.36, 0.36),
		CFrame = local_(0, ySommet + 1.05, 0.3) * VERTICAL,
		Color = C.dore,
		Material = Enum.Material.Metal,
	})
	local coupe = O.boule(modele, {
		Name = "Coupe",
		Size = Vector3.new(1.7, 1.7, 1.7),
		CFrame = local_(0, ySommet + 2.1, 0.3),
		Color = C.dore,
		Material = Enum.Material.Metal,
	})
	O.cylindre(modele, {
		Name = "Col",
		Size = Vector3.new(0.25, 1.6, 1.6),
		CFrame = local_(0, ySommet + 2.75, 0.3) * VERTICAL,
		Color = orClair,
		Material = Enum.Material.Metal,
	})
	for _, cote in ipairs({ -1, 1 }) do
		O.boule(modele, {
			Name = "Anse",
			Size = Vector3.new(0.55, 0.55, 0.55),
			CFrame = local_(cote * 0.95, ySommet + 2.25, 0.3),
			Color = orClair,
			Material = Enum.Material.Metal,
		})
	end
	O.lumiere(coupe, { Range = 12, Brightness = 0.9, Color = C.dore })

	-- deux lampes en col de cygne qui éclairent l'écran
	for _, cote in ipairs({ -1, 1 }) do
		local x = cote * 4.6
		O.cylindre(modele, {
			Name = "BrasLampe",
			Size = Vector3.new(1.5, 0.2, 0.2),
			CFrame = local_(x, yDosHaut - 0.1, -0.65) * CFrame.Angles(0, rad(90), 0),
			Color = C.dore,
			Material = Enum.Material.Metal,
		})
		local cfTete = local_(x, yDosHaut - 0.2, -1.45) * CFrame.Angles(rad(-30), 0, 0)
		O.bloc(modele, {
			Name = "Abat",
			Size = Vector3.new(1.5, 0.35, 0.6),
			CFrame = cfTete,
			Color = C.encre,
			Material = Enum.Material.Metal,
		})
		local ampoule = O.bloc(modele, {
			Name = "Ampoule",
			Size = Vector3.new(1.3, 0.08, 0.42),
			CFrame = cfTete * CFrame.new(0, -0.2, 0),
			Color = C.creme,
			Material = Enum.Material.Neon,
		})
		local spot = O.lumiere(ampoule, { genre = "Spot", Range = 12, Brightness = 1.2, Color = C.creme })
		spot.Face = Enum.NormalId.Bottom
		spot.Angle = 80
	end

	for _, p in ipairs(modele:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = solides[p] == true
		end
	end
	modele.PrimaryPart = ecran
	return ecran, fronton
end

-- ===== tableau d'honneur : l'écran =====
local function construireEcran(ctx, ecran)
	local C = ctx.Charte
	local S = ctx.Style

	local gui = Instance.new("SurfaceGui")
	gui.Name = "Affiche"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = PIXELS
	gui.LightInfluence = 0
	gui.Brightness = 1.3
	gui.Parent = ecran

	-- fond en dégradé nuit, liseré doré intérieur
	local fondGui = Instance.new("Frame")
	fondGui.Name = "Fond"
	fondGui.BorderSizePixel = 0
	fondGui.BackgroundColor3 = Color3.new(1, 1, 1)
	fondGui.Size = UDim2.fromScale(1, 1)
	S.degrade(fondGui, S.couleurs.fondHaut, S.couleurs.fond)
	fondGui.Parent = gui

	local lisere = Instance.new("Frame")
	lisere.Name = "Lisere"
	lisere.BackgroundTransparency = 1
	lisere.BorderSizePixel = 0
	lisere.Position = UDim2.fromOffset(8, 8)
	lisere.Size = UDim2.new(1, -16, 1, -16)
	S.coins(lisere, 18)
	S.bordure(lisere, 3, C.dore)
	lisere.Parent = gui

	-- bandeau de titre doré avec reflet
	local bandeau = Instance.new("Frame")
	bandeau.Name = "Bandeau"
	bandeau.BorderSizePixel = 0
	bandeau.BackgroundColor3 = Color3.new(1, 1, 1)
	bandeau.Position = UDim2.fromScale(0.04, 0.045)
	bandeau.Size = UDim2.fromScale(0.92, 0.16)
	S.coins(bandeau, 16)
	S.bordure(bandeau, 4)
	S.degrade(bandeau, S.boutons.jaune[1], S.boutons.jaune[2])
	bandeau.Parent = gui

	local reflet = Instance.new("Frame")
	reflet.Name = "Reflet"
	reflet.BackgroundColor3 = Color3.new(1, 1, 1)
	reflet.BackgroundTransparency = 0.7
	reflet.BorderSizePixel = 0
	reflet.Position = UDim2.new(0, 6, 0, 4)
	reflet.Size = UDim2.new(1, -12, 0.42, 0)
	S.coins(reflet, 12)
	local fonduReflet = Instance.new("UIGradient")
	fonduReflet.Rotation = 90
	fonduReflet.Transparency = NumberSequence.new(0.1, 1)
	fonduReflet.Parent = reflet
	reflet.Parent = bandeau

	S.texte(bandeau, {
		Name = "Titre",
		Position = UDim2.fromScale(0.03, 0.08),
		Size = UDim2.fromScale(0.94, 0.84),
		Text = "🏆 TOP REVENUS 🏆",
		titre = true,
		contour = 5,
		ZIndex = 2,
	})

	S.texte(gui, {
		Name = "SousTitre",
		Position = UDim2.fromScale(0.05, 0.215),
		Size = UDim2.fromScale(0.9, 0.065),
		Text = "Les meilleurs revenus par seconde du serveur",
		TextColor3 = S.couleurs.revenu,
		contour = 3,
	})

	-- lignes du classement : podium teinté or / argent / bronze
	local icones = { "🥇", "🥈", "🥉" }
	local couleursRang = { S.boutons.jaune, S.boutons.gris, S.boutons.orange }
	local liseresRang = { C.dore, S.boutons.gris[1], S.boutons.orange[2] }
	local lignes = {}
	local yDebut = 0.3
	local yFin = 0.915
	local hautLigne = (yFin - yDebut) / NB_LIGNES
	for i = 1, NB_LIGNES do
		local carteFond = S.couleurs.carte
		if i <= 3 then carteFond = S.couleurs.carteClaire end
		local fond = S.carte(gui, {
			Name = "Ligne" .. i,
			Position = UDim2.fromScale(0.04, yDebut + (i - 1) * hautLigne),
			Size = UDim2.new(0.92, 0, hautLigne, -7),
			BackgroundColor3 = carteFond,
		})
		local bord = fond:FindFirstChild("Bordure")
		if bord and liseresRang[i] then
			bord.Color = liseresRang[i]
		end

		-- pastille de rang : médaille pour le podium, numéro cerné sinon
		local pastille = Instance.new("Frame")
		pastille.Name = "Pastille"
		pastille.BorderSizePixel = 0
		pastille.BackgroundColor3 = Color3.new(1, 1, 1)
		pastille.AnchorPoint = Vector2.new(0, 0.5)
		pastille.Position = UDim2.new(0, 7, 0.5, 0)
		pastille.Size = UDim2.new(0.1, 0, 0.78, 0)
		S.coins(pastille, 12)
		S.bordure(pastille, 3)
		local palette = couleursRang[i] or S.boutons.bleu
		S.degrade(pastille, palette[1], palette[2])
		pastille.Parent = fond

		local texteRang = tostring(i)
		if icones[i] then texteRang = icones[i] end
		S.texte(fond, {
			Name = "Rang",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 7, 0.5, 0),
			Size = UDim2.new(0.1, 0, 0.78, 0),
			Text = texteRang,
			titre = true,
			contour = 3,
			ZIndex = 2,
		})

		local nom = S.texte(fond, {
			Name = "Nom",
			Position = UDim2.fromScale(0.15, 0.14),
			Size = UDim2.fromScale(0.5, 0.72),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "",
			contour = 3,
		})

		local revenu = S.texte(fond, {
			Name = "Revenu",
			Position = UDim2.fromScale(0.64, 0.14),
			Size = UDim2.fromScale(0.33, 0.72),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = S.couleurs.revenu,
			Text = "",
			titre = true,
			contour = 3,
		})

		lignes[i] = { nom = nom, revenu = revenu }
	end

	S.texte(gui, {
		Name = "Pied",
		Position = UDim2.fromScale(0.05, 0.925),
		Size = UDim2.fromScale(0.9, 0.045),
		Text = "Mis à jour toutes les " .. PERIODE_TABLEAU .. " secondes",
		TextColor3 = S.boutons.gris[1],
		contour = 2,
	})

	return lignes
end

local function construireTableau(ctx)
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

	local ecran = construireStructure(ctx, modele, local_)
	return construireEcran(ctx, ecran)
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
			ligne.nom.TextColor3 = ctx.Style.couleurs.texte
			ligne.revenu.Text = ctx.Style.revenu(entree.revenu)
		else
			ligne.nom.Text = "---"
			ligne.nom.TextColor3 = ctx.Style.boutons.gris[2]
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
