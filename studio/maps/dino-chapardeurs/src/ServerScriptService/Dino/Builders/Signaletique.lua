-- Constructeur Signaletique : panneaux en bois de jungle qui guident les joueurs.
-- Sur la Place, quatre panneaux-flèches (planche orientée vers la destination, pointe colorée) :
-- Boutique (Comptoir, ouest), Renaissance (Autel, est), Dinos à vendre (Tapis, nord), Dinodex (borne, sud).
-- Au début du Tapis « NURSERIE → », à la fin « → GRANDE PORTE », de chaque côté du Tapis.
-- Au nord de la Place, face aux joueurs qui apparaissent, un grand panneau de règles.
-- Les flèches du texte sont recalculées pour chaque face : elles pointent toujours dans la bonne direction.
-- Emprise (CONTRAT §10) : Place (hors secteur du tableau d'honneur) et bouts du Tapis.
local M = {}

local BUDGET = 100 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.signaletique
local DEFAUTS = {
	largeurFleche = 9,      -- largeur d'une planche indicatrice
	reculBoutPlace = 17,    -- distance des panneaux Boutique / Renaissance au centre (sur l'axe est-ouest)
	decalageAllee = 3.5,    -- décalage vers le sud pour laisser les allées libres
	tapisX = 4.5,           -- panneau vers le Tapis : décalage est
	tapisRecul = 17.5,      -- ... et distance au nord du centre
	dinodexX = -4.5,        -- panneau vers le Dinodex : décalage ouest
	dinodexRecul = 8.5,     -- ... et distance au sud du centre
	distanceBorne = 16.5,   -- position de la borne si elle est introuvable
	bordTapis = 6,          -- écart entre le rebord du Tapis et les panneaux des bouts
	retraitTapis = 3,       -- retrait des panneaux vers l'intérieur du Tapis
	reglesX = 16,           -- grand panneau des règles : décalage est
	reglesRecul = 29,       -- ... et distance au nord du centre (entre la Place et les Bases)
	reglesLargeur = 12,
	reglesHauteur = 6,
	reglesBas = 3,          -- hauteur du bas du panneau
}

local function lireReglages(ctx)
	local source = nil
	if ctx.Equilibrage and type(ctx.Equilibrage.signaletique) == "table" then
		source = ctx.Equilibrage.signaletique
	end
	local r = {}
	for cle, defaut in pairs(DEFAUTS) do
		local v = nil
		if source then
			v = source[cle]
		end
		if type(v) == "number" then
			r[cle] = v
		else
			r[cle] = defaut
		end
	end
	return r
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	local infoPlace = Plan.place or {}
	local CENTRE = infoPlace.centre or Vector3.new(0, 0, 100)
	local CX, CZ = CENTRE.X, CENTRE.Z

	-- bois de jungle
	local BOIS = Charte.bois
	local BOIS_SOMBRE = Charte.ombre(Charte.bois)
	local FEUILLE = Charte.jungle

	-- ===== compteur de parts : on s'arrête net au budget =====
	local nbParts = 0
	local function reserver(n)
		if nbParts + n > BUDGET then
			return false
		end
		nbParts = nbParts + n
		return true
	end
	local function bloc(parent, props)
		if not reserver(1) then return nil end
		return Outils.bloc(parent, props)
	end
	local function boule(parent, props)
		if not reserver(1) then return nil end
		return Outils.boule(parent, props)
	end

	-- lance une étape sans que son échec empêche les autres
	local function etape(nom, fn)
		local ok, err = pcall(fn)
		if not ok then
			warn("[Dino] Signaletique / " .. nom .. " : " .. tostring(err))
		end
	end

	-- texte d'une face selon le sens de la flèche vu depuis cette face
	-- versDroite : la destination est à droite du lecteur
	local function libelle(info, versDroite)
		if versDroite then
			return info.droite
		end
		return info.gauche
	end

	-- panneau-flèche : planche orientée vers la destination, pointe colorée au bout, touffe de feuilles
	-- info : { nom, droite, gauche, accent }
	local function fleche(parent, info, position, direction)
		local d = Vector3.new(direction.X, 0, direction.Z)
		if d.Magnitude < 0.01 then
			d = Vector3.new(1, 0, 0)
		end
		d = d.Unit
		-- l'axe X local de la planche pointe vers la destination
		local angle = math.deg(math.atan2(-d.Z, d.X))
		local largeur = R.largeurFleche
		if not reserver(2) then return nil end
		local m = Outils.panneau(parent, {
			nom = info.nom,
			position = position,
			angle = angle,
			largeur = largeur,
			couleur = BOIS,
			couleurTexte = Charte.creme,
			texte = info.droite,
		})
		local poteau = m:FindFirstChild("Poteau")
		if poteau then
			poteau.Color = BOIS_SOMBRE
		end
		local planche = m:FindFirstChild("Planche")
		if not planche then
			return m
		end
		planche.CanCollide = false
		m.PrimaryPart = planche

		-- flèches du texte : face arrière lue vers +X local, face avant vers -X local
		for _, gui in ipairs(planche:GetChildren()) do
			if gui:IsA("SurfaceGui") then
				local etiquette = gui:FindFirstChildOfClass("TextLabel")
				if etiquette then
					local droite = planche.CFrame.RightVector
					if gui.Face == Enum.NormalId.Front then
						droite = -droite
					end
					etiquette.Text = libelle(info, droite:Dot(d) > 0)
					etiquette.Font = Charte.police
				end
			end
		end

		-- pointe en losange à moitié engagée dans la planche
		bloc(m, {
			Name = "Pointe",
			Size = Vector3.new(1.42, 1.42, 0.5),
			CFrame = planche.CFrame * CFrame.new(largeur / 2, 0, 0) * CFrame.Angles(0, 0, math.rad(45)),
			Color = info.accent or Charte.dore,
			CanCollide = false,
		})
		-- talon du côté opposé, même couleur que la planche en plus sombre
		bloc(m, {
			Name = "Talon",
			Size = Vector3.new(0.4, 2.2, 0.5),
			CFrame = planche.CFrame * CFrame.new(-largeur / 2 - 0.2, 0, 0),
			Color = BOIS_SOMBRE,
			CanCollide = false,
		})
		-- touffe de feuilles sur la planche, au-dessus du poteau
		bloc(m, {
			Name = "Feuilles",
			Size = Vector3.new(1.8, 0.5, 0.8),
			CFrame = planche.CFrame * CFrame.new(0, 1.25, 0),
			Color = FEUILLE,
			CanCollide = false,
		})
		-- pied de pierre
		bloc(m, {
			Name = "Pied",
			Size = Vector3.new(1.4, 0.5, 1.4),
			CFrame = Outils.surSol(Vector3.new(1.4, 0.5, 1.4), position.X, position.Z, angle, position.Y),
			Color = Charte.pierre,
		})
		return m
	end

	-- ===== 1. panneaux-flèches sur la Place =====
	etape("place", function()
		local m = Outils.modele(dossier, "Place")

		-- Boutique : façade du Comptoir, ouverte vers la Place (+X)
		local cibleComptoir = Vector3.new(CX - 50, 0, CZ + 4)
		if Plan.comptoir and Plan.comptoir.centre then
			local demiLargeur = 13
			if Plan.comptoir.taille then
				demiLargeur = Plan.comptoir.taille.X / 2
			end
			cibleComptoir = Plan.comptoir.centre + Vector3.new(demiLargeur, 0, 0)
		end
		local posBoutique = Vector3.new(CX - R.reculBoutPlace, 0, CZ + R.decalageAllee)
		fleche(m, {
			nom = "VersBoutique",
			droite = "🛒 Boutique →",
			gauche = "← 🛒 Boutique",
			accent = Charte.dore,
		}, posBoutique, cibleComptoir - posBoutique)

		-- Renaissance : l'Autel, à l'est
		local cibleAutel = Vector3.new(CX + 50, 0, CZ + 4)
		if Plan.autel and Plan.autel.centre then
			cibleAutel = Plan.autel.centre
		end
		local posAutel = Vector3.new(CX + R.reculBoutPlace, 0, CZ + R.decalageAllee)
		fleche(m, {
			nom = "VersRenaissance",
			droite = "♻️ Renaissance →",
			gauche = "← ♻️ Renaissance",
			accent = Charte.violet,
		}, posAutel, cibleAutel - posAutel)

		-- Tapis : vers le nord, par l'allée centrale
		local cibleTapis = Vector3.new(CX, 0, 0)
		if Plan.tapis and Plan.tapis.debut and Plan.tapis.fin then
			local milieu = (Plan.tapis.debut + Plan.tapis.fin) / 2
			cibleTapis = Vector3.new(CX, 0, milieu.Z)
		end
		local posTapis = Vector3.new(CX + R.tapisX, 0, CZ - R.tapisRecul)
		fleche(m, {
			nom = "VersTapis",
			droite = "🦖 Dinos à vendre ! →",
			gauche = "← 🦖 Dinos à vendre !",
			accent = Charte.tapis,
		}, posTapis, cibleTapis - posTapis)

		-- Dinodex : la borne au bord sud de la Place (position réelle si elle existe)
		local cibleBorne = Vector3.new(CX, 0, CZ + R.distanceBorne)
		local place = ctx.racine and ctx.racine:FindFirstChild("Place")
		local borne = place and place:FindFirstChild("Dinodex")
		if borne and borne:IsA("Model") then
			local ok, pivot = pcall(function()
				return borne:GetPivot()
			end)
			if ok and pivot then
				cibleBorne = Vector3.new(pivot.Position.X, 0, pivot.Position.Z)
			end
		end
		local posDinodex = Vector3.new(CX + R.dinodexX, 0, CZ + R.dinodexRecul)
		fleche(m, {
			nom = "VersDinodex",
			droite = "📖 Dinodex →",
			gauche = "← 📖 Dinodex",
			accent = Charte.gemme,
		}, posDinodex, cibleBorne - posDinodex)
	end)

	-- ===== 2. les deux bouts du Tapis (des deux côtés) =====
	etape("tapis", function()
		local m = Outils.modele(dossier, "Tapis")
		local tapis = Plan.tapis or {}
		local debut = tapis.debut or Vector3.new(-112, 0, 0)
		local fin = tapis.fin or Vector3.new(112, 0, 0)
		local sens = fin - debut
		if sens.Magnitude < 0.01 then
			sens = Vector3.new(1, 0, 0)
		end
		sens = Vector3.new(sens.X, 0, sens.Z).Unit
		local cote = Vector3.new(-sens.Z, 0, sens.X) -- perpendiculaire au Tapis, dans le plan
		local ecart = (tapis.largeur or 10) / 2 + R.bordTapis

		for _, s in ipairs({ 1, -1 }) do
			-- début : les dinos sortent de la Nurserie et partent dans le sens du Tapis
			local posDebut = debut + sens * R.retraitTapis + cote * (ecart * s)
			fleche(m, {
				nom = "Nurserie",
				droite = "NURSERIE →",
				gauche = "← NURSERIE",
				accent = Charte.herbe,
			}, Vector3.new(posDebut.X, 0, posDebut.Z), sens)

			-- fin : les dinos invendus passent la Grande Porte
			local posFin = fin - sens * R.retraitTapis + cote * (ecart * s)
			fleche(m, {
				nom = "GrandePorte",
				droite = "→ GRANDE PORTE",
				gauche = "GRANDE PORTE ←",
				accent = Charte.lave,
			}, Vector3.new(posFin.X, 0, posFin.Z), sens)
		end
	end)

	-- ===== 3. grand panneau des règles, face à la Place =====
	-- entre la Place et l'arrière des Bases du sud, visible dès l'apparition (on regarde vers le nord)
	etape("regles", function()
		local m = Outils.modele(dossier, "Regles")
		local L = R.reglesLargeur
		local H = R.reglesHauteur
		local bas = R.reglesBas
		local px, pz = CX + R.reglesX, CZ - R.reglesRecul
		-- repère au sol, face avant du panneau (-Z local) tournée vers la Place (plein sud),
		-- parallèle à l'arrière des Bases pour ne pas déborder sur elles
		local repere = CFrame.lookAt(Vector3.new(px, 0, pz), Vector3.new(px, 0, CZ))
		local function ici(x, y, z)
			return repere * CFrame.new(x, y, z)
		end
		local yMilieu = bas + H / 2
		local hPoteau = bas + H + 0.6

		for _, s in ipairs({ -1, 1 }) do
			bloc(m, {
				Name = "Poteau",
				Size = Vector3.new(0.8, hPoteau, 0.8),
				CFrame = ici(s * (L / 2 + 0.9), hPoteau / 2, 0.2),
				Color = BOIS_SOMBRE,
			})
			bloc(m, {
				Name = "Pied",
				Size = Vector3.new(1.6, 0.6, 1.6),
				CFrame = ici(s * (L / 2 + 0.9), 0.3, 0.2),
				Color = Charte.pierre,
			})
		end
		local planche = bloc(m, {
			Name = "Planche",
			Size = Vector3.new(L, H, 0.5),
			CFrame = ici(0, yMilieu, 0),
			Color = BOIS,
		})
		-- cadre en bambou vert
		bloc(m, { Name = "Cadre", Size = Vector3.new(L + 1, 0.5, 0.7), CFrame = ici(0, bas + H + 0.25, 0), Color = FEUILLE })
		bloc(m, { Name = "Cadre", Size = Vector3.new(L + 1, 0.5, 0.7), CFrame = ici(0, bas - 0.25, 0), Color = FEUILLE })
		bloc(m, { Name = "Cadre", Size = Vector3.new(0.5, H, 0.7), CFrame = ici(-L / 2 - 0.25, yMilieu, 0), Color = FEUILLE })
		bloc(m, { Name = "Cadre", Size = Vector3.new(0.5, H, 0.7), CFrame = ici(L / 2 + 0.25, yMilieu, 0), Color = FEUILLE })
		-- toit de feuilles
		bloc(m, {
			Name = "Toit",
			Size = Vector3.new(L + 3, 0.6, 2),
			CFrame = ici(0, hPoteau + 0.3, 0.2),
			Color = Charte.ombre(FEUILLE),
		})
		for _, s in ipairs({ -1, 1 }) do
			boule(m, {
				Name = "Feuillage",
				Size = Vector3.new(2.2, 1.4, 2.2),
				CFrame = ici(s * (L / 2 + 1), hPoteau + 0.8, 0.2),
				Color = FEUILLE,
				CanCollide = false,
			})
		end
		-- œuf doré qui flotte au-dessus
		local oeuf = boule(m, {
			Name = "Oeuf",
			Size = Vector3.new(1.4, 1.8, 1.4),
			CFrame = ici(0, hPoteau + 1.8, 0.2),
			Color = Charte.dore,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		if oeuf then
			Outils.animer(oeuf, "flotte", 0.7)
			Outils.lumiere(oeuf, { Range = 14, Brightness = 1, Color = Charte.dore })
		end
		if not planche then
			return
		end
		m.PrimaryPart = planche

		-- chiffres du jeu pour la ligne du bas
		local depart = 100
		if type(E.argentDepart) == "number" then
			depart = E.argentDepart
		end
		local dureeVerrou = 60
		if type(E.base) == "table" and type(E.base.dureeVerrou) == "number" then
			dureeVerrou = E.base.dureeVerrou
		end
		local pied = "Départ : " .. Charte.argent(depart) .. "   •   Verrou : " .. tostring(math.floor(dureeVerrou + 0.5)) .. " s"

		local lignes = {
			{ texte = "🦖 Achète des dinos, ils gagnent de l'argent dans ta base.", couleur = Charte.creme },
			{ texte = "😈 Vole ceux des autres !", couleur = Charte.dore },
			{ texte = "Verrouille ta base 🔒", couleur = Charte.gemme },
		}

		-- affiche sur une face de la planche
		local function affiche(face)
			local gui = Instance.new("SurfaceGui")
			gui.Name = "Affiche"
			gui.Face = face
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 50
			gui.LightInfluence = 0
			gui.Parent = planche

			local fond = Instance.new("Frame")
			fond.Name = "Fond"
			fond.Size = UDim2.fromScale(1, 1)
			fond.BackgroundTransparency = 1
			fond.Parent = gui

			local titre = Instance.new("TextLabel")
			titre.Name = "Titre"
			titre.BackgroundTransparency = 1
			titre.Position = UDim2.fromScale(0.05, 0.04)
			titre.Size = UDim2.fromScale(0.9, 0.22)
			titre.Font = Charte.police
			titre.Text = "📜 LES RÈGLES"
			titre.TextScaled = true
			titre.TextColor3 = Charte.dore
			titre.TextStrokeColor3 = Charte.encre
			titre.TextStrokeTransparency = 0.4
			titre.Parent = fond

			local trait = Instance.new("Frame")
			trait.Name = "Trait"
			trait.BorderSizePixel = 0
			trait.BackgroundColor3 = Charte.dore
			trait.Position = UDim2.fromScale(0.2, 0.275)
			trait.Size = UDim2.fromScale(0.6, 0.012)
			trait.Parent = fond

			for i, ligne in ipairs(lignes) do
				local t = Instance.new("TextLabel")
				t.Name = "Ligne" .. i
				t.BackgroundTransparency = 1
				t.Position = UDim2.fromScale(0.05, 0.31 + (i - 1) * 0.175)
				t.Size = UDim2.fromScale(0.9, 0.16)
				t.Font = Charte.police
				t.Text = ligne.texte
				t.TextScaled = true
				t.TextWrapped = true
				t.TextColor3 = ligne.couleur
				t.TextStrokeColor3 = Charte.encre
				t.TextStrokeTransparency = 0.5
				t.Parent = fond
			end

			local bas_ = Instance.new("TextLabel")
			bas_.Name = "Pied"
			bas_.BackgroundTransparency = 1
			bas_.Position = UDim2.fromScale(0.1, 0.86)
			bas_.Size = UDim2.fromScale(0.8, 0.1)
			bas_.Font = Charte.policeTexte or Charte.police
			bas_.Text = pied
			bas_.TextScaled = true
			bas_.TextColor3 = Charte.sable
			bas_.Parent = fond
		end

		local ok, err = pcall(function()
			affiche(Enum.NormalId.Front) -- côté Place
			affiche(Enum.NormalId.Back)  -- côté Bases
		end)
		if not ok then
			warn("[Dino] Signaletique / affiche des règles : " .. tostring(err))
		end
	end)

	dossier:SetAttribute("Parts", nbParts)
end

return M
