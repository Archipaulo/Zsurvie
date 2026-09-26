-- Constructeur Galerie : salle d'exposition des Zbires sur l'île du Laboratoire.
-- Emprise 16 x 24 autour de Plan.lobby.galerie, entrée côté +X (vers le centre de l'île).
-- 10 socles, chacun avec un clone figé du gabarit (ou une statuette violette) et une plaque descriptive.
local M = {}

local BUDGET = 400
local ORDRE = { "Marcheur", "Rapide", "Sauteur", "Costaud", "Dore", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local NOMS = {
	Marcheur = "Marcheur",
	Rapide = "Rapide",
	Sauteur = "Sauteur",
	Costaud = "Costaud",
	Dore = "Doré",
	Gluant = "Gluant",
	MiniGluant = "Mini-Gluant",
	Volant = "Volant",
	Casque = "Casqué",
	Colosse = "Colosse",
}

-- dimensions de la salle (demi-largeur en X, demi-longueur en Z)
local DEMI_X = 8
local DEMI_Z = 12
local EPAISSEUR_SOL = 0.2
local HAUT_SOCLE = 2.6       -- dessus du socle (Y)
local EMPRISE_ZBIRE = 3      -- encombrement horizontal maximal d'un Zbire exposé
local HAUTEUR_ZBIRE = 4.5    -- hauteur maximale d'un Zbire exposé

-- ===== outils locaux =====

local function nombrePartsDans(inst)
	local n = 0
	if inst:IsA("BasePart") then
		n = 1
	end
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("BasePart") then
			n = n + 1
		end
	end
	return n
end

local function affecter(inst, propriete, valeur)
	pcall(function()
		inst[propriete] = valeur
	end)
end

-- premier jour où le type apparaît dans la composition (nil si jamais)
local function jourMinimal(E, nomType)
	if type(E.compositionDuJour) ~= "function" then
		return nil
	end
	for jour = 1, 100 do
		local ok, compo = pcall(E.compositionDuJour, jour)
		if ok and type(compo) == "table" then
			for _, entree in ipairs(compo) do
				if type(entree) == "table" and entree[1] == nomType then
					return jour
				end
			end
		end
	end
	return nil
end

local function texteApparition(E, nomType)
	if nomType == "Colosse" then
		local n = 5
		if type(E.jour) == "table" and type(E.jour.colosseTousLes) == "number" then
			n = E.jour.colosseTousLes
		end
		return "Tous les " .. tostring(n) .. " jours"
	end
	if nomType == "MiniGluant" then
		return "Naît d'un Gluant"
	end
	local j = jourMinimal(E, nomType)
	if j then
		return "Dès le jour " .. tostring(j)
	end
	return "Rarement vu"
end

local function formatNombre(v)
	if type(v) ~= "number" then
		return "?"
	end
	if v == math.floor(v) then
		return tostring(v)
	end
	return string.format("%.1f", v)
end

-- ===== plaque descriptive =====

local function ligne(gui, texte, y, h, police, couleur)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.fromScale(0.05, y)
	t.Size = UDim2.fromScale(0.9, h)
	t.Text = texte
	t.TextScaled = true
	t.Font = police
	t.TextColor3 = couleur
	t.Parent = gui
	return t
end

local function plaque(ctx, parent, position, direction, nomType)
	local C, O, E = ctx.Charte, ctx.Outils, ctx.Equilibrage
	local p = O.bloc(parent, {
		Name = "Plaque",
		Size = Vector3.new(2.6, 1.5, 0.2),
		CFrame = CFrame.lookAt(position, position + direction),
		Color = C.creme,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Fiche"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	gui.LightInfluence = 0
	gui.Parent = p

	local stats = nil
	if type(E.zbires) == "table" then
		stats = E.zbires[nomType]
	end
	local pv, vitesse = nil, nil
	if type(stats) == "table" then
		pv = stats.pv
		vitesse = stats.vitesse
	end
	ligne(gui, NOMS[nomType] or nomType, 0.03, 0.3, C.police, C.violet)
	ligne(gui, "PV : " .. formatNombre(pv), 0.36, 0.19, C.policeTexte, C.encre)
	ligne(gui, "Vitesse : " .. formatNombre(vitesse), 0.56, 0.19, C.policeTexte, C.encre)
	ligne(gui, texteApparition(E, nomType), 0.77, 0.2, C.policeTexte, C.ombre(C.toit))
	return p
end

-- ===== statuette de remplacement (3 parts) =====

local function statuette(ctx, parent, nomType)
	local C, O = ctx.Charte, ctx.Outils
	local m = O.modele(parent, nomType)
	local corps = O.bloc(m, {
		Name = "Corps",
		Size = Vector3.new(1.6, 2, 1.2),
		CFrame = CFrame.new(0, 1, 0),
		Color = C.violet,
		CanCollide = false,
	})
	O.boule(m, {
		Name = "Tete",
		Size = Vector3.new(1.4, 1.4, 1.4),
		CFrame = CFrame.new(0, 2.6, 0),
		Color = C.lumiere(C.violet),
		CanCollide = false,
	})
	O.bloc(m, {
		Name = "Yeux",
		Size = Vector3.new(0.9, 0.25, 0.1),
		CFrame = CFrame.new(0, 2.7, -0.68),
		Color = C.alerte,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	m.PrimaryPart = corps
	affecter(m, "WorldPivot", CFrame.new())
	return m
end

-- ===== clone figé d'un gabarit =====

local function figer(modele)
	-- retire barres de vie et scripts éventuels, puis immobilise toutes les parts
	for _, d in ipairs(modele:GetDescendants()) do
		if d:IsA("BillboardGui") and d.Name == "Barre" then
			d:Destroy()
		elseif d:IsA("BaseScript") then
			d:Destroy()
		end
	end
	for _, d in ipairs(modele:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			affecter(d, "CanTouch", false)
			affecter(d, "CanQuery", false)
		end
	end
	-- ce n'est pas un Zbire en jeu : pas d'attribut Type
	modele:SetAttribute("Type", nil)
	modele:SetAttribute("Expose", true)
end

-- réduit un clone trop grand pour tenir sur son socle
local function ajuster(modele)
	local ok, taille = pcall(function()
		return modele:GetExtentsSize()
	end)
	if not ok or typeof(taille) ~= "Vector3" then
		return
	end
	local facteur = 1
	local horizontal = math.max(taille.X, taille.Z)
	if horizontal > EMPRISE_ZBIRE then
		facteur = math.min(facteur, EMPRISE_ZBIRE / horizontal)
	end
	if taille.Y > HAUTEUR_ZBIRE then
		facteur = math.min(facteur, HAUTEUR_ZBIRE / taille.Y)
	end
	if facteur < 1 then
		pcall(function()
			modele:ScaleTo(modele:GetScale() * facteur)
		end)
	end
end

local function cloneGabarit(ctx, nomType)
	local stock = ctx.stockage
	if not stock then
		return nil
	end
	local dossier = stock:FindFirstChild("Zbires")
	if not dossier then
		return nil
	end
	local gabarit = dossier:FindFirstChild(nomType)
	if not gabarit or not gabarit:IsA("Model") then
		return nil
	end
	local ok, clone = pcall(function()
		return gabarit:Clone()
	end)
	if not ok or not clone then
		return nil
	end
	return clone
end

-- ===== construction =====

function M.construire(ctx)
	local C, O, P = ctx.Charte, ctx.Outils, ctx.Plan
	if type(P.lobby) ~= "table" or typeof(P.lobby.galerie) ~= "Vector3" then
		warn("[Zsurvie] Galerie : Plan.lobby.galerie introuvable")
		return
	end
	local G = P.lobby.galerie
	local dossier = ctx.dossier
	local partsDepart = O.nombreParts()
	local partsClones = 0

	local function utilisees()
		return O.nombreParts() - partsDepart + partsClones
	end

	-- repère local : x, y, z relatifs au centre de la galerie
	local function cf(x, y, z)
		return CFrame.new(G.X + x, G.Y + y, G.Z + z)
	end

	-- ===== salle =====
	local salle = O.modele(dossier, "Salle")
	O.bloc(salle, {
		Name = "Dallage",
		Size = Vector3.new(DEMI_X * 2, EPAISSEUR_SOL, DEMI_Z * 2),
		CFrame = cf(0, EPAISSEUR_SOL / 2, 0),
		Color = C.lumiere(C.nuitLabo),
	})
	O.bloc(salle, {
		Name = "Tapis",
		Size = Vector3.new(3, 0.1, DEMI_Z * 2 - 2),
		CFrame = cf(0, EPAISSEUR_SOL + 0.05, 0),
		Color = C.ombre(C.violet),
	})

	-- murets : fond (-X), deux bouts (±Z), façade (+X) ouverte au milieu
	local hMuret = 1.6
	local eMuret = 0.8
	local function muret(nom, x, z, sx, sz)
		O.bloc(salle, {
			Name = nom,
			Size = Vector3.new(sx, hMuret, sz),
			CFrame = cf(x, EPAISSEUR_SOL + hMuret / 2, z),
			Color = C.creme,
		})
		O.bloc(salle, {
			Name = nom .. "Chaperon",
			Size = Vector3.new(sx, 0.3, sz),
			CFrame = cf(x, EPAISSEUR_SOL + hMuret + 0.15, z),
			Color = C.toit,
		})
	end
	local xMur = DEMI_X - eMuret / 2
	local zMur = DEMI_Z - eMuret / 2
	muret("MuretFond", -xMur, 0, eMuret, DEMI_Z * 2 - 0.4)
	muret("MuretNord", 0, -zMur, DEMI_X * 2 - 2 * eMuret - 0.4, eMuret)
	muret("MuretSud", 0, zMur, DEMI_X * 2 - 2 * eMuret - 0.4, eMuret)
	local demiEntree = 3
	local longFacade = DEMI_Z - demiEntree - 0.2
	muret("FacadeNord", xMur, -(demiEntree + longFacade / 2), eMuret, longFacade)
	muret("FacadeSud", xMur, demiEntree + longFacade / 2, eMuret, longFacade)

	-- colonnes avec lanterne
	local hColonne = 6
	local colonnes = {
		{ -xMur + 0.2, -zMur + 0.2, true },
		{ -xMur + 0.2, zMur - 0.2, true },
		{ -xMur + 0.2, 0, false },
		{ xMur - 0.2, -zMur + 0.2, false },
		{ xMur - 0.2, zMur - 0.2, false },
		{ xMur - 0.2, -demiEntree - 0.6, true },
		{ xMur - 0.2, demiEntree + 0.6, true },
	}
	for i, c in ipairs(colonnes) do
		local h = hColonne
		if i >= 6 then
			h = hColonne + 1.5
		end
		O.bloc(salle, {
			Name = "Colonne",
			Size = Vector3.new(1.2, h, 1.2),
			CFrame = cf(c[1], EPAISSEUR_SOL + h / 2, c[2]),
			Color = C.lumiere(C.creme),
		})
		local lanterne = O.boule(salle, {
			Name = "Lanterne",
			Size = Vector3.new(1.1, 1.1, 1.1),
			CFrame = cf(c[1], EPAISSEUR_SOL + h + 0.5, c[2]),
			Color = C.dore,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		if c[3] then
			O.lumiere(lanterne, { Range = 14, Brightness = 1.2, Color = C.lumiere(C.dore) })
		end
	end

	-- bannière d'entrée entre les deux grandes colonnes
	local hPoutre = EPAISSEUR_SOL + hColonne + 1.5 - 0.6
	local largeurBanniere = (demiEntree + 0.6) * 2 + 1.2
	O.bloc(salle, {
		Name = "Poutre",
		Size = Vector3.new(0.8, 0.5, largeurBanniere),
		CFrame = cf(xMur, hPoutre, 0),
		Color = C.toit,
	})
	local banniere = O.bloc(salle, {
		Name = "Banniere",
		Size = Vector3.new(0.3, 1.8, largeurBanniere - 1.4),
		CFrame = cf(xMur, hPoutre - 1.25, 0),
		Color = C.violet,
		CanCollide = false,
	})
	O.texte(banniere, "Right", "Galerie des Zbires", { couleur = C.creme, pixelsParStud = 30 })
	O.texte(banniere, "Left", "Galerie des Zbires", { couleur = C.creme, pixelsParStud = 30 })

	-- ===== socles =====
	local listeTypes = ORDRE

	-- 6 socles contre le fond, 4 côté façade (l'entrée centrale reste dégagée)
	local xRangee = 4.3
	local emplacements = {
		{ -1, -9.25 }, { -1, -5.55 }, { -1, -1.85 }, { -1, 1.85 }, { -1, 5.55 }, { -1, 9.25 },
		{ 1, -9.25 }, { 1, -5 }, { 1, 5 }, { 1, 9.25 },
	}
	for i, nomType in ipairs(listeTypes) do
		local place = emplacements[i]
		if place then
			local cote = place[1]
			local x = cote * xRangee
			local z = place[2]
			local versAllee = Vector3.new(-cote, 0, 0)

			local socle = O.modele(dossier, "Socle_" .. nomType)
			O.bloc(socle, {
				Name = "Base",
				Size = Vector3.new(3.4, 0.5, 3.4),
				CFrame = cf(x, EPAISSEUR_SOL + 0.25, z),
				Color = C.ardoise,
			})
			O.bloc(socle, {
				Name = "Fut",
				Size = Vector3.new(2.8, 1.6, 2.8),
				CFrame = cf(x, EPAISSEUR_SOL + 0.5 + 0.8, z),
				Color = C.creme,
			})
			O.bloc(socle, {
				Name = "Dessus",
				Size = Vector3.new(3.2, HAUT_SOCLE - EPAISSEUR_SOL - 2.1, 3.2),
				CFrame = cf(x, (EPAISSEUR_SOL + 2.1 + HAUT_SOCLE) / 2, z),
				Color = C.violet,
			})

			-- plaque posée sur la base, contre le fût, côté allée
			local posPlaque = Vector3.new(G.X + x - cote * 1.52, G.Y + EPAISSEUR_SOL + 0.5 + 0.75, G.Z + z)
			plaque(ctx, socle, posPlaque, versAllee, nomType)

			-- Zbire exposé : clone du gabarit si le budget le permet, sinon statuette
			local pose = CFrame.lookAt(
				Vector3.new(G.X + x, G.Y + HAUT_SOCLE, G.Z + z),
				Vector3.new(G.X + x, G.Y + HAUT_SOCLE, G.Z + z) + versAllee
			)
			local modele = cloneGabarit(ctx, nomType)
			if modele then
				local n = nombrePartsDans(modele)
				if utilisees() + n + 3 * (10 - i) > BUDGET then
					modele:Destroy()
					modele = nil
				else
					partsClones = partsClones + n
					figer(modele)
					ajuster(modele)
					modele.Name = nomType
					modele.Parent = socle
				end
			end
			if not modele then
				modele = statuette(ctx, socle, nomType)
				modele:SetAttribute("Expose", true)
			end
			local ok = pcall(function()
				modele:PivotTo(pose)
			end)
			if ok then
				O.animer(modele, "tourne", 0.5)
			end
		end
	end

	dossier:SetAttribute("Parts", utilisees())
end

return M
