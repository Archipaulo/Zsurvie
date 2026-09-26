-- Builders/Lumieres.lua : réverbères jouets (socle et poteau ardoise, lanterne Neon crème,
-- chapeau ardoise, pointe orange, PointLight chaude).
-- Prairie : le long des 4 chemins à 20, 40 et 60 du centre, décalés de 5 studs, côtés alternés.
-- Île du Laboratoire : à r58 autour de Plan.lobby.origine tous les 30°, sauf près d'une zone.
-- La lumière suit la Phase : Horde -> plus forte et orangée, Lobby -> cyan, sinon chaude.
-- Budget : 300 parts (5 par réverbère).
local M = {}

local BUDGET = 300

-- réglages visuels (décor, pas des chiffres de jeu)
local DISTANCES_CHEMIN = { 20, 40, 60 }
local DECALAGE_CHEMIN = 5
local RAYON_ILE = 58
local PAS_ANGLE_ILE = 30
local ECART_ZONES_ILE = 14
local MARGE_PARVIS = 1.5
local HAUTEUR_PRAIRIE = 6
local HAUTEUR_ILE = 9

local HAUT_SOCLE = 0.4
local COTE_LANTERNE = 1.1
local HAUT_CHAPEAU = 0.3
local TAILLE_POINTE = 0.4

local CALME = { luminosite = 1.2, portee = 14 }
local HORDE = { luminosite = 1.9, portee = 17 }
local DUREE_TRANSITION = 1.5

local ZONES_ILE = { "spawn", "laboratoire", "quai", "galerie", "parcours", "enigme", "records", "monument", "scenePhoto" }

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	local couleurPoteau = Charte.ardoise
	local couleurSocle = Charte.ombre(Charte.ardoise)
	local couleurLanterne = Charte.creme
	local couleurPointe = Charte.toit
	local teinteChaude = Charte.lumiere(Charte.dore)
	local teinteHorde = Charte.toit
	local teinteLobby = Charte.gemme

	-- compteur de parts propre au module
	local nbParts = 0
	local function creer(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return fabrique(parent, props)
	end

	local lumieres = {}

	-- un réverbère complet (5 parts) posé en (x, z) sur un sol à ySol, de hauteur totale `hauteur`
	local function reverbere(parent, nom, x, z, ySol, hauteur)
		if nbParts + 5 > BUDGET then
			return nil
		end
		local m = Outils.modele(parent, nom)
		local hautPoteau = hauteur - HAUT_SOCLE - COTE_LANTERNE - HAUT_CHAPEAU - TAILLE_POINTE
		if hautPoteau < 1 then
			hautPoteau = 1
		end
		local y = ySol

		creer(Outils.bloc, m, {
			Name = "Socle",
			Size = Vector3.new(1.4, HAUT_SOCLE, 1.4),
			CFrame = CFrame.new(x, y + HAUT_SOCLE / 2, z),
			Color = couleurSocle,
		})
		y = y + HAUT_SOCLE

		-- l'axe d'un cylindre est X : on le redresse
		creer(Outils.cylindre, m, {
			Name = "Poteau",
			Size = Vector3.new(hautPoteau, 0.5, 0.5),
			CFrame = CFrame.new(x, y + hautPoteau / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleurPoteau,
		})
		y = y + hautPoteau

		local lanterne = creer(Outils.bloc, m, {
			Name = "Lanterne",
			Size = Vector3.new(COTE_LANTERNE, COTE_LANTERNE, COTE_LANTERNE),
			CFrame = CFrame.new(x, y + COTE_LANTERNE / 2, z),
			Color = couleurLanterne,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		y = y + COTE_LANTERNE

		creer(Outils.bloc, m, {
			Name = "Chapeau",
			Size = Vector3.new(1.6, HAUT_CHAPEAU, 1.6),
			CFrame = CFrame.new(x, y + HAUT_CHAPEAU / 2, z),
			Color = couleurPoteau,
		})
		y = y + HAUT_CHAPEAU

		creer(Outils.boule, m, {
			Name = "Pointe",
			Size = Vector3.new(TAILLE_POINTE, TAILLE_POINTE, TAILLE_POINTE),
			CFrame = CFrame.new(x, y + TAILLE_POINTE / 2, z),
			Color = couleurPointe,
			CanCollide = false,
		})

		if lanterne then
			local ok, lumiere = pcall(Outils.lumiere, lanterne, {
				genre = "Point",
				Range = CALME.portee,
				Brightness = CALME.luminosite,
				Color = teinteChaude,
			})
			if ok and lumiere then
				lumiere.Shadows = false
				table.insert(lumieres, lumiere)
			end
		end
		return m
	end

	-- ===== Prairie : les 4 chemins =====
	local centre = Vector3.new(0, 0, 0)
	if Plan.prairie and typeof(Plan.prairie.centre) == "Vector3" then
		centre = Plan.prairie.centre
	end
	local hauteurPrairie = HAUTEUR_PRAIRIE
	if type(Plan.hauteurMaxPres) == "number" and Plan.hauteurMaxPres < hauteurPrairie then
		hauteurPrairie = Plan.hauteurMaxPres
	end

	-- le parvis ne doit pas porter de réverbère : on repousse le long du chemin
	local parvis = nil
	if Plan.parvis and typeof(Plan.parvis.centre) == "Vector3" and typeof(Plan.parvis.taille) == "Vector3" then
		parvis = Plan.parvis
	end
	local function surParvis(x, z)
		if not parvis then
			return false
		end
		local demiX = parvis.taille.X / 2 + MARGE_PARVIS
		local demiZ = parvis.taille.Z / 2 + MARGE_PARVIS
		return math.abs(x - parvis.centre.X) <= demiX and math.abs(z - parvis.centre.Z) <= demiZ
	end

	local chemins = {
		{ nom = "Nord", dir = Vector3.new(0, 0, -1) },
		{ nom = "Est", dir = Vector3.new(1, 0, 0) },
		{ nom = "Sud", dir = Vector3.new(0, 0, 1) },
		{ nom = "Ouest", dir = Vector3.new(-1, 0, 0) },
	}

	local dossierPrairie = Outils.dossier(dossier, "Prairie")
	for iChemin, chemin in ipairs(chemins) do
		-- perpendiculaire au chemin, dans le plan du sol
		local cote = Vector3.new(-chemin.dir.Z, 0, chemin.dir.X)
		for iDist, distance in ipairs(DISTANCES_CHEMIN) do
			local signe = 1
			if (iChemin + iDist) % 2 == 0 then
				signe = -1
			end
			local d = distance
			local pos = centre + chemin.dir * d + cote * (DECALAGE_CHEMIN * signe)
			local essais = 0
			while surParvis(pos.X, pos.Z) and essais < 30 do
				d = d + 1
				pos = centre + chemin.dir * d + cote * (DECALAGE_CHEMIN * signe)
				essais = essais + 1
			end
			reverbere(dossierPrairie, "Reverbere_" .. chemin.nom .. "_" .. distance, pos.X, pos.Z, centre.Y, hauteurPrairie)
		end
	end

	-- ===== Île du Laboratoire : anneau r58 =====
	local lobby = Plan.lobby
	if type(lobby) == "table" and typeof(lobby.origine) == "Vector3" then
		local origine = lobby.origine
		local dossierIle = Outils.dossier(dossier, "Ile")
		local angle = 0
		while angle < 360 do
			local rad = math.rad(angle)
			local pos = origine + Vector3.new(math.sin(rad) * RAYON_ILE, 0, math.cos(rad) * RAYON_ILE)
			local libre = true
			for _, cle in ipairs(ZONES_ILE) do
				local zone = lobby[cle]
				if typeof(zone) == "Vector3" and Outils.distanceXZ(pos, zone) < ECART_ZONES_ILE then
					libre = false
				end
			end
			if libre then
				reverbere(dossierIle, "Lampadaire_" .. angle, pos.X, pos.Z, origine.Y, HAUTEUR_ILE)
			end
			angle = angle + PAS_ANGLE_ILE
		end
	end

	-- ===== ambiance selon la Phase =====
	local TweenService = nil
	local okT, service = pcall(function() return game:GetService("TweenService") end)
	if okT and service then
		TweenService = service
	end

	local function appliquer(lumiere, buts)
		if TweenService then
			local ok = pcall(function()
				local info = TweenInfo.new(DUREE_TRANSITION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				TweenService:Create(lumiere, info, buts):Play()
			end)
			if ok then
				return
			end
		end
		pcall(function()
			for cle, valeur in pairs(buts) do
				lumiere[cle] = valeur
			end
		end)
	end

	local Etat = ctx.Etat
	local function majPhase()
		local phase = nil
		if Etat then
			local ok, valeur = pcall(function() return Etat:GetAttribute("Phase") end)
			if ok then
				phase = valeur
			end
		end
		local reglage = CALME
		local teinte = teinteChaude
		if phase == "Horde" then
			reglage = HORDE
			teinte = teinteHorde
		elseif phase == "Lobby" then
			teinte = teinteLobby
		end
		for _, lumiere in ipairs(lumieres) do
			if lumiere.Parent then
				appliquer(lumiere, { Brightness = reglage.luminosite, Range = reglage.portee, Color = teinte })
			end
		end
	end

	majPhase()
	if Etat then
		pcall(function()
			Etat:GetAttributeChangedSignal("Phase"):Connect(majPhase)
		end)
	end
end

return M
