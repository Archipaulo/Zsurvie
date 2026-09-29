-- Système Etages : l'étage de la Base, acheté amélioration par amélioration.
-- Amélioration 1 : l'étage apparaît avec 1 podium ; amélioration 2 : 2 podiums… jusqu'à 12 (E.etages.max).
-- Les podiums de l'étage s'appellent E13 à E24 (dans le dossier Emplacements de la Base) : Systemes/Bases
-- les oriente comme ceux du rez-de-chaussée, Systemes/Enclos y pose les dinos. Le niveau (attribut joueur
-- « Etage ») est sauvegardé par Systemes/Donnees et garde sa valeur après une renaissance.
-- Achat : borne « Etage » à l'entrée de chaque Base (invite réservée au propriétaire).
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Outils = ctx.Outils
	local Charte = ctx.Charte
	local Style = ctx.Style
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Reseau = ctx.Reseau
	local EE = E.etages or { max = 12, hauteur = 12 }
	local MAX = EE.max or 12
	local HAUTEUR = EE.hauteur or 12
	local H = Plan.base.hauteurSol or 1
	local BASE_MAX = Plan.base.emplacementsMax or 12
	local DEMI_L = (Plan.base.largeur or 44) / 2
	local Mat = Enum.Material

	-- plan de l'étage (repère local d'une Base : x en travers, z positif vers le Tapis)
	local SOL = H + HAUTEUR          -- dessus du plancher
	local Z_AVANT, Z_FOND = 15, -24.5 -- le plancher couvre le fond de la Base, l'entrée reste à ciel ouvert
	local TREMIE = 4                 -- demi-largeur de la trémie de l'escalier (au fond de l'allée)
	local Z_TREMIE = -4              -- la trémie va du fond jusqu'ici
	local X_RANGEE = DEMI_L - 9       -- mêmes rangées qu'au rez-de-chaussée
	local Z_RANGEES = { 11, 4.8, -1.4, -7.6, -13.8, -20 }
	local HAUT_SOCLE = 1.3
	-- borne d'achat : coin avant droit, derrière le bouton de verrou (hors de l'axe de l'entrée)
	local X_BORNE = DEMI_L - 2.8 -- contre le muret latéral, devant la 1re rangée de podiums
	local Z_BORNE = (Plan.base.profondeur or 50) / 2 - 4

	local BOIS = Charte.hex("A8733F")
	local BOIS_SOMBRE = Charte.hex("6E4A2A")
	local METAL = Charte.hex("C3C9D3")
	local VERRE = Charte.hex("BFEFFF")

	local etats = {} -- index -> { dossier, niveau, podiums = { [i] = { plaque, parts } } }

	local function nombre(v, defaut)
		if type(v) == "number" and v == v then return v end
		return defaut
	end

	local function modeleBase(index)
		local m = Bus.demander("ModeleBase", index)
		if typeof(m) == "Instance" then return m end
		local dossier = ctx.racine:FindFirstChild("Bases")
		return dossier and dossier:FindFirstChild("Base" .. index)
	end

	local function repere(index)
		local b = Plan.bases[index]
		local sens = 1
		if b.versTapis < 0 then sens = -1 end
		return CFrame.new(b.centre.X, b.centre.Y, b.centre.Z, sens, 0, 0, 0, 1, 0, 0, 0, sens)
	end

	local function couleurs(index)
		local m = modeleBase(index)
		local c = m and m:GetAttribute("Couleur")
		if typeof(c) ~= "Color3" then c = Charte.lave end
		return c, Charte.lumiere(c), Charte.ombre(c)
	end

	local function notifier(joueur, texte, genre)
		pcall(function() Reseau.Notification:FireClient(joueur, texte, genre or "info") end)
	end

	-- ===== la structure (plancher, piliers, escalier, garde-corps) =====
	local function construireStructure(index)
		local etat = etats[index]
		if etat and etat.dossier and etat.dossier.Parent then return etat end
		local m = modeleBase(index)
		if not m then return nil end
		local r = repere(index)
		local function ici(x, y, z) return r * CFrame.new(x, y, z) end
		local couleur, claire = couleurs(index)
		local dossier = Instance.new("Folder")
		dossier.Name = "Etage"
		dossier.Parent = m
		local function bloc(props)
			props.Anchored = true
			return Outils.bloc(dossier, props)
		end

		-- plancher : deux grandes dalles latérales et une dalle au-dessus de l'allée, devant la trémie
		local largeurCote = DEMI_L - 1 - TREMIE
		for _, s in ipairs({ -1, 1 }) do
			bloc({ Name = "Plancher", Size = Vector3.new(largeurCote, 1, Z_AVANT - Z_FOND), CFrame = ici(s * (TREMIE + largeurCote / 2), SOL - 0.5, (Z_AVANT + Z_FOND) / 2), Color = claire, Material = Mat.WoodPlanks })
		end
		bloc({ Name = "Plancher", Size = Vector3.new(TREMIE * 2, 1, Z_AVANT - Z_TREMIE), CFrame = ici(0, SOL - 0.5, (Z_AVANT + Z_TREMIE) / 2), Color = claire, Material = Mat.WoodPlanks })
		-- poutre de rive, dans la couleur de la base
		bloc({ Name = "Rive", Size = Vector3.new(DEMI_L * 2 - 2, 1.2, 0.8), CFrame = ici(0, SOL - 0.9, Z_AVANT - 0.4), Color = couleur, Material = Mat.SmoothPlastic })
		-- piliers
		for _, x in ipairs({ -(DEMI_L - 2), -TREMIE - 0.6, TREMIE + 0.6, DEMI_L - 2 }) do
			for _, z in ipairs({ Z_AVANT - 1, (Z_AVANT + Z_FOND) / 2, Z_FOND + 1 }) do
				bloc({ Name = "Pilier", Size = Vector3.new(1.2, HAUTEUR - 1, 1.2), CFrame = ici(x, H + (HAUTEUR - 1) / 2, z), Color = BOIS_SOMBRE, Material = Mat.Wood })
			end
		end
		-- escalier dans la trémie : 12 marches de 1 de haut, montée vers le fond
		local nbMarches = HAUTEUR
		local giron = (Z_TREMIE - Z_FOND - 1.2) / nbMarches
		for k = 1, nbMarches do
			local zMilieu = Z_TREMIE - (k - 0.5) * giron
			bloc({ Name = "Marche", Size = Vector3.new(TREMIE * 2 - 0.4, k, giron), CFrame = ici(0, H + k / 2, zMilieu), Color = (k % 2 == 0) and BOIS or claire, Material = Mat.WoodPlanks })
		end
		bloc({ Name = "Palier", Size = Vector3.new(TREMIE * 2 - 0.4, HAUTEUR, 1.2), CFrame = ici(0, H + HAUTEUR / 2, Z_FOND + 0.6), Color = BOIS, Material = Mat.WoodPlanks })
		-- garde-corps en verre : avant, côtés, fond, et bords de la trémie (ouverts au palier)
		local function rambarde(x, z, sx, sz)
			bloc({ Name = "GardeCorps", Size = Vector3.new(sx, 2.4, sz), CFrame = ici(x, SOL + 1.2, z), Color = VERRE, Material = Mat.Glass, Transparency = 0.55 })
			bloc({ Name = "MainCourante", Size = Vector3.new(math.max(sx, 0.3), 0.3, math.max(sz, 0.3)), CFrame = ici(x, SOL + 2.5, z), Color = METAL, Material = Mat.Metal })
		end
		rambarde(0, Z_AVANT - 0.2, DEMI_L * 2 - 2, 0.3)
		rambarde(0, Z_FOND + 0.2, DEMI_L * 2 - 2, 0.3)
		for _, s in ipairs({ -1, 1 }) do
			rambarde(s * (DEMI_L - 1.2), (Z_AVANT + Z_FOND) / 2, 0.3, Z_AVANT - Z_FOND)
			rambarde(s * TREMIE, (Z_TREMIE + Z_FOND + 3) / 2, 0.3, Z_TREMIE - Z_FOND - 3)
		end

		etat = { dossier = dossier, niveau = 0, podiums = {} }
		etats[index] = etat
		return etat
	end

	-- ===== un podium de l'étage (E13 à E24) =====
	local function ajouterPodium(index, i)
		local etat = etats[index]
		if not etat or etat.podiums[i] then return end
		local m = modeleBase(index)
		local emplacements = m and m:FindFirstChild("Emplacements")
		if not emplacements then return end
		local r = repere(index)
		local couleur, claire, sombre = couleurs(index)
		local col = (i - 1) % 2
		local rang = math.floor((i - 1) / 2) + 1
		local x = (col == 0) and -X_RANGEE or X_RANGEE
		local z = Z_RANGEES[rang] or Z_RANGEES[#Z_RANGEES]
		local socle = Outils.bloc(etat.dossier, { Name = "Socle", Anchored = true, Size = Vector3.new(12.4, HAUT_SOCLE, 6.2), CFrame = r * CFrame.new(x, SOL + HAUT_SOCLE / 2, z), Color = sombre, Material = Mat.Slate })
		local anneau = Outils.bloc(etat.dossier, { Name = "Anneau", Anchored = true, Size = Vector3.new(12.6, 0.28, 6.4), CFrame = r * CFrame.new(x, SOL + HAUT_SOCLE - 0.19, z), Color = couleur, Material = Mat.Neon, CanCollide = false, CastShadow = false })
		local plaque = Outils.bloc(emplacements, { Name = "E" .. (BASE_MAX + i), Anchored = true, Size = Vector3.new(12, 0.3, 5.8), CFrame = r * CFrame.new(x, SOL + HAUT_SOCLE + 0.15, z), Color = claire, Material = Mat.Metal })
		plaque:SetAttribute("Debloque", true)
		plaque:SetAttribute("Etage", true)
		etat.podiums[i] = { plaque = plaque, parts = { socle, anneau } }
	end

	local function retirerPodium(index, i)
		local etat = etats[index]
		local p = etat and etat.podiums[i]
		if not p then return end
		pcall(function() p.plaque:Destroy() end)
		for _, part in ipairs(p.parts) do pcall(function() part:Destroy() end) end
		etat.podiums[i] = nil
	end

	local function detruire(index)
		local etat = etats[index]
		if not etat then return end
		for i = 1, MAX do retirerPodium(index, i) end
		pcall(function() etat.dossier:Destroy() end)
		etats[index] = nil
	end

	-- ===== la borne d'achat, près de l'entrée de chaque Base =====
	local bornes = {} -- index -> { invite, texte }
	local function majBorne(index)
		local b = bornes[index]
		if not b then return end
		local joueur = Bus.demander("JoueurDeBase", index)
		local niveau = 0
		if typeof(joueur) == "Instance" then niveau = math.floor(nombre(joueur:GetAttribute("Etage"), 0)) end
		local texte
		if niveau >= MAX then
			texte = "⬆️ ÉTAGE COMPLET (" .. MAX .. "/" .. MAX .. ")"
			b.invite.ObjectText = "Étage complet"
			b.invite.Enabled = false
		else
			texte = "⬆️ ÉTAGE " .. niveau .. "/" .. MAX .. "\n+1 podium : " .. Charte.argent(E.coutEtage(niveau + 1))
			b.invite.ObjectText = "Podium " .. (niveau + 1) .. " de l'étage — " .. Charte.argent(E.coutEtage(niveau + 1))
			b.invite.Enabled = true
		end
		if b.texte then b.texte.Text = texte end
	end

	local function construireBorne(index)
		local m = modeleBase(index)
		if not m then return end
		local r = repere(index)
		local dossier = Instance.new("Folder")
		dossier.Name = "BorneEtage"
		dossier.Parent = m
		Outils.bloc(dossier, { Name = "SocleBorne", Anchored = true, Size = Vector3.new(2.4, 0.6, 2.4), CFrame = r * CFrame.new(X_BORNE, H + 0.3, Z_BORNE), Color = Charte.hex("383D48"), Material = Mat.Metal })
		local fut = Outils.bloc(dossier, { Name = "Borne", Anchored = true, Size = Vector3.new(1.6, 3, 1.2), CFrame = r * CFrame.new(X_BORNE, H + 2.1, Z_BORNE), Color = Charte.hex("C3C9D3"), Material = Mat.Metal })
		Outils.bloc(dossier, { Name = "Ecran", Anchored = true, Size = Vector3.new(1.3, 1.2, 0.2), CFrame = r * CFrame.new(X_BORNE, H + 2.9, Z_BORNE + 0.6), Color = Charte.gemme, Material = Mat.Neon })
		local invite = Outils.invite(fut, { nom = "Etage", action = "Construire", objet = "Étage", duree = 0.4, distance = 10 })
		local texte = nil
		if Style and Style.etiquette then
			local _, lignes = Style.etiquette(fut, {
				{ texte = "⬆️ ÉTAGE", titre = true, contour = 3, nom = "Titre" },
			}, { Name = "EtiquetteEtage", largeur = 9, hauteurLigne = 1.4, StudsOffset = Vector3.new(0, 3.4, 0), MaxDistance = 60 })
			texte = lignes and lignes[1]
			if texte then texte.TextColor3 = Style.couleurs.revenu end
		end
		bornes[index] = { invite = invite, texte = texte }
		majBorne(index)
	end

	-- ===== met l'étage d'une Base au niveau de son propriétaire =====
	local function majBase(index)
		local joueur = Bus.demander("JoueurDeBase", index)
		local niveau = 0
		if typeof(joueur) == "Instance" and joueur.Parent then
			niveau = math.floor(nombre(joueur:GetAttribute("Etage"), 0))
		end
		if niveau > MAX then niveau = MAX end
		if niveau <= 0 then
			detruire(index)
		else
			local etat = construireStructure(index)
			if etat then
				for i = 1, MAX do
					if i <= niveau then ajouterPodium(index, i) else retirerPodium(index, i) end
				end
				etat.niveau = niveau
			end
		end
		majBorne(index)
	end

	for index = 1, #Plan.bases do
		pcall(construireBorne, index)
	end

	local suivis = {}
	local function suivre(joueur)
		if suivis[joueur] then return end
		suivis[joueur] = joueur:GetAttributeChangedSignal("Etage"):Connect(function()
			local index = Bus.demander("BaseDe", joueur)
			if type(index) == "number" then pcall(majBase, index) end
		end)
	end
	Bus.ecouter("BaseAttribuee", function(joueur, index)
		if typeof(joueur) == "Instance" then suivre(joueur) end
		if type(index) == "number" then pcall(majBase, index) end
	end)
	Bus.ecouter("BaseLiberee", function(joueur, index)
		if type(index) == "number" then
			task.defer(function() pcall(majBase, index) end)
		end
	end)
	for _, joueur in ipairs(Players:GetPlayers()) do
		suivre(joueur)
		local index = Bus.demander("BaseDe", joueur)
		if type(index) == "number" then pcall(majBase, index) end
	end
	Players.PlayerRemoving:Connect(function(joueur)
		local c = suivis[joueur]
		if c then c:Disconnect() end
		suivis[joueur] = nil
	end)

	-- ===== achat d'une amélioration =====
	local enCours = {}
	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Etage" then return end
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") or enCours[joueur] then return end
		local index = nil
		for i = 1, #Plan.bases do
			local m = modeleBase(i)
			if not index and m and invite:IsDescendantOf(m) then index = i end
		end
		if not index then return end
		if Bus.demander("JoueurDeBase", index) ~= joueur then
			notifier(joueur, "❌ Ce n'est pas ta base", "alerte")
			return
		end
		if joueur:GetAttribute("DonneesChargees") ~= true then return end
		local niveau = math.floor(nombre(joueur:GetAttribute("Etage"), 0))
		if niveau >= MAX then
			notifier(joueur, "⬆️ Ton étage est complet !", "info")
			return
		end
		enCours[joueur] = true
		local cout = E.coutEtage(niveau + 1)
		local paye = Bus.demander("DepenserArgent", joueur, cout)
		if paye == true then
			joueur:SetAttribute("Etage", niveau + 1)
			Bus.emettre("EtageAchete", joueur, niveau + 1)
			if niveau == 0 then
				notifier(joueur, "⬆️ ÉTAGE CONSTRUIT ! Premier podium en haut de l'escalier", "succes")
			else
				notifier(joueur, "⬆️ Podium " .. (niveau + 1) .. " ajouté à ton étage !", "succes")
			end
			pcall(function()
				Reseau.Effet:FireAllClients("Achat", invite.Parent.Position, { rarete = "Legendaire" })
			end)
		else
			local argent = nombre(joueur:GetAttribute("Argent"), 0)
			notifier(joueur, "❌ Il te manque " .. Charte.argent(math.max(0, cout - argent)), "alerte")
		end
		enCours[joueur] = nil
	end)
end

return M
