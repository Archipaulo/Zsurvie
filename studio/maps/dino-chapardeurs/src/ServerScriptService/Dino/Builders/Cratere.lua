-- Constructeur Cratere : scène des événements au nord de la Place.
-- Cratère d'impact (fond brûlé, talus intérieur, rebord de roches ouvert au sud), météorite géante fumante
-- au centre (pierre sombre veinée de Neon violet), fissures lumineuses, grappes de cristaux et panneau
-- « Zone des événements » avec une plaque qui annonce l'événement en cours ou le prochain.
-- Pendant un événement (ctx.Etat.Evenement ~= "") : veines, cristaux et lumières s'illuminent fort.
-- Emprise (CONTRAT §10) : disque de rayon 16 autour de Plan.cratere.centre. Budget : 180 parts.
local TweenService = game:GetService("TweenService")

local M = {}

local BUDGET = 180

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	local Etat = ctx.Etat

	-- réglages facultatifs (Equilibrage.cratere), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.cratere) == "table" then
		reglages = ctx.Equilibrage.cratere
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	local infoCratere = Plan.cratere or {}
	local CENTRE = infoCratere.centre or Vector3.new(0, 0, -96)
	local RAYON = infoCratere.rayon or 16
	local CX, CZ = CENTRE.X, CENTRE.Z
	local rng = Outils.aleatoire(reglage("graine", 1996))

	-- géométrie (tout reste à l'intérieur du disque RAYON)
	local RAYON_FOND = RAYON - 3
	local RAYON_TALUS = RAYON - 4.2
	local RAYON_REBORD = RAYON - 2.5
	local OUVERTURE = math.rad(22) -- demi-angle de l'ouverture du rebord, côté sud (+Z, vers la Place)
	local RAYON_METEORITE = 4
	local Y_METEORITE = 3.3
	local HAUT_FOND = 0.2

	-- couleurs « simulateur » : pierre lilas claire et saturée, fond violet profond, Neon bien visible
	-- même au repos (plus vif encore pendant un événement)
	local hex = Charte.hex
	local Style = ctx.Style
	local PIERRE = hex("A596D6")        -- roches claires du rebord
	local PIERRE_OMBRE = hex("8171C2")  -- talus et roches moyennes
	local PIERRE_SOMBRE = hex("5B4A9E") -- socles, éclats, cailloux
	local ROCHE_METEORE = hex("46287F") -- corps de la météorite
	local FOND = hex("33245E")
	local BRULE = hex("241848")
	local VIOLET = Charte.violet
	local VIOLET_VIF = hex("E0A3FF")
	local VIOLET_FAIBLE = hex("A45CFF")
	local GEMME = Charte.gemme
	local GEMME_FAIBLE = hex("2BB8E0")
	local TRANSP_REPOS = 0.15
	local FUMEE = hex("D9D2F2")

	-- teinte des lumières selon l'événement en cours
	local COULEURS_EVENEMENT = {
		PluieDeMeteores = Charte.violet,
		Eruption = Charte.lave,
		LuneDoree = Charte.dore,
	}

	-- ===== création avec compteur : on s'arrête net au budget =====
	local compteur = 0
	local function creer(fabrique, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		compteur = compteur + 1
		return fabrique(parent, props)
	end
	local function bloc(parent, props)
		return creer(Outils.bloc, parent, props)
	end
	local function coin(parent, props)
		return creer(Outils.coin, parent, props)
	end
	local function boule(parent, props)
		return creer(Outils.boule, parent, props)
	end
	local function cylindre(parent, props)
		return creer(Outils.cylindre, parent, props)
	end

	local function point(angle, rayon, y)
		return Vector3.new(CX + math.sin(angle) * rayon, y, CZ + math.cos(angle) * rayon)
	end
	local function dansOuverture(angle)
		local a = math.atan2(math.sin(angle), math.cos(angle))
		return math.abs(a) < OUVERTURE
	end

	-- éléments qui réagissent aux événements
	local veines = {}   -- parts Neon violettes (météorite et fissures)
	local cristaux = {} -- { part, vif, faible }
	local lumieres = {} -- PointLight
	local fumees = {}   -- Smoke

	local modele = Outils.modele(dossier, "Cratere")

	-- ===== le fond du cratère =====
	local fond = Outils.modele(modele, "Fond")
	cylindre(fond, {
		Name = "Fond",
		Size = Vector3.new(HAUT_FOND, RAYON_FOND * 2, RAYON_FOND * 2),
		CFrame = CFrame.new(CX, HAUT_FOND / 2, CZ) * CFrame.Angles(0, 0, math.rad(90)),
		Color = FOND,
		CanTouch = false,
	})
	cylindre(fond, {
		Name = "Brulure",
		Size = Vector3.new(0.1, 16, 16),
		CFrame = CFrame.new(CX, HAUT_FOND + 0.05, CZ) * CFrame.Angles(0, 0, math.rad(90)),
		Color = BRULE,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	-- fissures lumineuses qui rayonnent depuis la météorite
	local NB_FISSURES = 8
	for i = 1, NB_FISSURES do
		local a = (i - 1) * (2 * math.pi / NB_FISSURES) + rng:NextNumber(-0.15, 0.15)
		local longueur = rng:NextNumber(4, 5.5)
		local milieu = 5 + longueur / 2
		local p = point(a, milieu, HAUT_FOND + 0.1)
		local f = bloc(fond, {
			Name = "Fissure",
			Size = Vector3.new(0.4, 0.12, longueur),
			CFrame = CFrame.new(p) * CFrame.Angles(0, a, 0),
			Color = VIOLET_FAIBLE,
			Material = Enum.Material.Neon,
			Transparency = TRANSP_REPOS,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,
		})
		if f then
			table.insert(veines, f)
		end
	end

	-- cailloux éparpillés sur le fond
	for _ = 1, 14 do
		local a = rng:NextNumber(0, 2 * math.pi)
		local r = rng:NextNumber(5.5, 9.5)
		local t = rng:NextNumber(0.5, 1.1)
		local taille = Vector3.new(t, t * 0.7, t * rng:NextNumber(0.8, 1.2))
		local p = point(a, r, HAUT_FOND + taille.Y / 2 - 0.05)
		bloc(fond, {
			Name = "Caillou",
			Size = taille,
			CFrame = CFrame.new(p) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6.28), rng:NextNumber(-0.3, 0.3)),
			Color = PIERRE_SOMBRE,
			CanCollide = false,
			CanTouch = false,
		})
	end

	-- ===== talus intérieur (coins qui montent vers le rebord) =====
	local talus = Outils.modele(modele, "Talus")
	local NB_TALUS = 20
	for i = 0, NB_TALUS - 1 do
		local a = i * (2 * math.pi / NB_TALUS)
		if not dansOuverture(a) then
			local hauteur = rng:NextNumber(1.3, 1.9)
			local p = point(a, RAYON_TALUS, hauteur / 2)
			-- la pente d'un WedgePart monte vers +Z local : on tourne +Z vers l'extérieur
			coin(talus, {
				Name = "Talus",
				Size = Vector3.new(3.9, hauteur, 3),
				CFrame = CFrame.new(p) * CFrame.Angles(0, a, 0),
				Color = PIERRE_OMBRE,
				CanTouch = false,
			})
		end
	end

	-- ===== rebord de roches (ouvert au sud) =====
	local rebord = Outils.modele(modele, "Rebord")
	local NB_ROCHES = 26
	local roches = {}
	for i = 0, NB_ROCHES - 1 do
		local a = i * (2 * math.pi / NB_ROCHES) + rng:NextNumber(-0.06, 0.06)
		if not dansOuverture(a) then
			local taille = Vector3.new(rng:NextNumber(2.2, 3), rng:NextNumber(1.8, 3.2), rng:NextNumber(2, 2.8))
			local p = point(a, RAYON_REBORD, taille.Y / 2 - 0.2)
			local couleur = PIERRE
			local tirage = rng:NextInteger(1, 3)
			if tirage == 2 then
				couleur = PIERRE_OMBRE
			elseif tirage == 3 then
				couleur = PIERRE_SOMBRE
			end
			local roche = bloc(rebord, {
				Name = "Roche",
				Size = taille,
				CFrame = CFrame.new(p) * CFrame.Angles(0, a + rng:NextNumber(-0.4, 0.4), 0) * CFrame.Angles(rng:NextNumber(-0.12, 0.12), 0, rng:NextNumber(-0.12, 0.12)),
				Color = couleur,
				CanTouch = false,
			})
			if roche then
				table.insert(roches, { roche = roche, angle = a, hauteur = taille.Y })
			end
		end
	end
	-- une roche sur deux reçoit un petit bloc au sommet
	for i, fiche in ipairs(roches) do
		if i % 2 == 0 then
			local t = rng:NextNumber(1.2, 1.8)
			local p = point(fiche.angle, RAYON_REBORD - 0.2, fiche.hauteur - 0.2 + t * 0.35)
			bloc(rebord, {
				Name = "RocheHaut",
				Size = Vector3.new(t, t * 0.8, t),
				CFrame = CFrame.new(p) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6.28), rng:NextNumber(-0.3, 0.3)),
				Color = PIERRE,
				CanTouch = false,
			})
		end
	end

	-- ===== la météorite géante =====
	local meteorite = Outils.modele(modele, "Meteorite")
	local centreMeteorite = Vector3.new(CX, Y_METEORITE, CZ)
	local corps = boule(meteorite, {
		Name = "Corps",
		Size = Vector3.new(RAYON_METEORITE * 2, RAYON_METEORITE * 2, RAYON_METEORITE * 2),
		CFrame = CFrame.new(centreMeteorite),
		Color = ROCHE_METEORE,
	})
	if corps then
		meteorite.PrimaryPart = corps
	end

	-- direction aléatoire au-dessus du sol (y minimal donné)
	local function directionHaute(yMin)
		local d = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(yMin, 1), rng:NextNumber(-1, 1))
		if d.Magnitude < 0.05 then
			d = Vector3.new(0, 1, 0)
		end
		return d.Unit
	end

	-- éclats rocheux qui cassent la rondeur
	local eclats = {}
	for _ = 1, 8 do
		local d = directionHaute(-0.1)
		local t = rng:NextNumber(2.4, 3.6)
		local e = bloc(meteorite, {
			Name = "Eclat",
			Size = Vector3.new(t, t * rng:NextNumber(0.7, 1), t * rng:NextNumber(0.8, 1.1)),
			CFrame = CFrame.new(centreMeteorite + d * (RAYON_METEORITE - 0.9)) * CFrame.Angles(rng:NextNumber(0, 6.28), rng:NextNumber(0, 6.28), rng:NextNumber(0, 6.28)),
			Color = PIERRE_SOMBRE,
		})
		if e then
			table.insert(eclats, e)
		end
	end

	-- veines Neon violettes posées à la surface
	for _ = 1, 14 do
		local d = directionHaute(0)
		local p = centreMeteorite + d * (RAYON_METEORITE + 0.05)
		local v = bloc(meteorite, {
			Name = "Veine",
			Size = Vector3.new(rng:NextNumber(2.2, 3.6), 0.3, 0.35),
			CFrame = CFrame.lookAt(p, p + d) * CFrame.Angles(0, 0, rng:NextNumber(0, 6.28)),
			Color = VIOLET_FAIBLE,
			Material = Enum.Material.Neon,
			Transparency = TRANSP_REPOS,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,
		})
		if v then
			table.insert(veines, v)
		end
	end

	-- coeur incandescent au sommet (lumière et fumée principales)
	local coeur = boule(meteorite, {
		Name = "Coeur",
		Size = Vector3.new(2.4, 2.4, 2.4),
		CFrame = CFrame.new(centreMeteorite + Vector3.new(0, RAYON_METEORITE - 0.6, 0)),
		Color = VIOLET_FAIBLE,
		Material = Enum.Material.Neon,
		Transparency = 0.1,
		CanCollide = false,
		CanTouch = false,
		CastShadow = false,
	})
	if coeur then
		table.insert(veines, coeur)
		local l = Outils.lumiere(coeur, { Range = 12, Brightness = 0.6, Color = VIOLET })
		l.Shadows = false
		table.insert(lumieres, l)
	end

	-- fumée : le coeur et deux éclats
	local function fumer(part, taille)
		if not part then
			return
		end
		local ok, fumee = pcall(function()
			local s = Instance.new("Smoke")
			s.Color = FUMEE
			s.Opacity = 0.12
			s.RiseVelocity = 3
			s.Size = taille
			s.Parent = part
			return s
		end)
		if ok and fumee then
			table.insert(fumees, fumee)
		end
	end
	fumer(coeur, 3)
	fumer(eclats[1], 2)
	fumer(eclats[3], 2)

	-- éclat de cristal qui flotte au-dessus de la météorite
	local flottant = bloc(meteorite, {
		Name = "CristalFlottant",
		Size = Vector3.new(1.3, 3, 1.3),
		CFrame = CFrame.new(CX, Y_METEORITE + RAYON_METEORITE + 4, CZ) * CFrame.Angles(0, math.rad(45), math.rad(12)),
		Color = VIOLET_FAIBLE,
		Material = Enum.Material.Neon,
		Transparency = TRANSP_REPOS,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		CastShadow = false,
	})
	if flottant then
		table.insert(cristaux, { part = flottant, vif = VIOLET_VIF, faible = VIOLET_FAIBLE })
		pcall(Outils.animer, flottant, "flotte", 0.6)
	end

	-- ===== grappes de cristaux =====
	local grappes = Outils.modele(modele, "Cristaux")
	local NB_GRAPPES = 6
	for g = 1, NB_GRAPPES do
		local a = math.rad(30 + (g - 1) * 60)
		local base = point(a, 8.8, 0)
		local socle = bloc(grappes, {
			Name = "Socle",
			Size = Vector3.new(2.2, 0.8, 2.2),
			CFrame = CFrame.new(base.X, HAUT_FOND + 0.3, base.Z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0),
			Color = PIERRE_SOMBRE,
			CanTouch = false,
		})
		local vif, faible = VIOLET_VIF, VIOLET_FAIBLE
		if g % 2 == 0 then
			vif, faible = Charte.lumiere(GEMME), GEMME_FAIBLE
		end
		for c = 1, 3 do
			local h = rng:NextNumber(2.6, 5)
			if c == 1 then
				h = rng:NextNumber(4.5, 5.5)
			end
			local largeur = rng:NextNumber(0.8, 1.2)
			local inclinaison = 0.1
			if c > 1 then
				inclinaison = rng:NextNumber(0.25, 0.5)
			end
			local cf = CFrame.new(base.X + rng:NextNumber(-0.4, 0.4), HAUT_FOND + 0.4, base.Z + rng:NextNumber(-0.4, 0.4))
				* CFrame.Angles(0, rng:NextNumber(0, 6.28), 0)
				* CFrame.Angles(inclinaison, 0, 0)
				* CFrame.new(0, h / 2 - 0.3, 0)
				* CFrame.Angles(0, math.rad(45), 0)
			local cristal = bloc(grappes, {
				Name = "Cristal",
				Size = Vector3.new(largeur, h, largeur),
				CFrame = cf,
				Color = faible,
				Material = Enum.Material.Neon,
				Transparency = TRANSP_REPOS,
				CanCollide = false,
				CanTouch = false,
				CastShadow = false,
			})
			if cristal then
				table.insert(cristaux, { part = cristal, vif = vif, faible = faible })
			end
		end
		if socle then
			local l = Outils.lumiere(socle, { Range = 8, Brightness = 0.8, Color = vif })
			l.Shadows = false
			table.insert(lumieres, l)
		end
	end

	-- ===== panneau « Zone des événements » dans l'ouverture sud =====
	local plaqueTextes = {}
	local ligneEtat = nil -- ligne jaune sous le titre flottant

	-- texte de SurfaceGui au look simulateur : blanc (ou coloré), police du jeu, cerné de noir épais
	local function styliserTexte(etiquette, couleur)
		if not etiquette then
			return
		end
		etiquette.TextColor3 = couleur or Color3.new(1, 1, 1)
		if Style then
			etiquette.Font = Style.police
			Style.contour(etiquette, 3)
		end
	end

	if compteur + 3 <= BUDGET then
		local posPanneau = Vector3.new(CX, 0, CZ + RAYON - 1.8)
		local panneau = Outils.panneau(modele, {
			nom = "PanneauEvenements",
			position = posPanneau,
			texte = "ZONE DES ÉVÉNEMENTS",
			largeur = 9,
			angle = 0,
			couleur = Charte.violet,
			couleurTexte = Color3.new(1, 1, 1),
		})
		compteur = compteur + 2
		local planche = panneau:FindFirstChild("Planche")
		if planche then
			for _, d in ipairs(planche:GetDescendants()) do
				if d:IsA("TextLabel") then
					styliserTexte(d, Color3.new(1, 1, 1))
				end
			end
		end
		local poteau = panneau:FindFirstChild("Poteau")
		if poteau then
			poteau.Color = PIERRE_SOMBRE
		end
		local plaque = bloc(panneau, {
			Name = "Plaque",
			-- plus épaisse que le poteau (0,6) : sinon il traverse la plaque et masque le milieu du texte
			Size = Vector3.new(7, 0.9, 0.8),
			CFrame = CFrame.new(posPanneau.X, 3.45, posPanneau.Z),
			Color = Style and Style.couleurs.fond or Charte.encre,
			CanCollide = false,
			CanTouch = false,
		})
		if plaque then
			local avant = Outils.texte(plaque, "Front", "", { couleur = Charte.dore })
			local arriere = Outils.texte(plaque, "Back", "", { couleur = Charte.dore })
			styliserTexte(avant, Style and Style.couleurs.revenu or Charte.dore)
			styliserTexte(arriere, Style and Style.couleurs.revenu or Charte.dore)
			table.insert(plaqueTextes, avant)
			table.insert(plaqueTextes, arriere)
		end

		-- titre géant flottant « ☄️ ÉVÉNEMENTS » au-dessus du panneau, lisible de loin (et sur mobile) ;
		-- le titre de l'événement en cours, lui, flotte au-dessus de la météorite (Systemes/Evenements)
		if Style and planche then
			pcall(function()
				local _, textes = Style.etiquette(planche, {
					{ texte = "☄️ ÉVÉNEMENTS", taille = 1.5, titre = true, rarete = "Epique", contour = 4, nom = "Titre" },
					{ texte = "", taille = 1, couleur = Style.couleurs.revenu, contour = 3.5, nom = "Etat" },
				}, {
					Name = "EtiquetteCratere",
					largeur = 16,
					hauteurLigne = 2,
					StudsOffset = Vector3.new(0, 4.6, 0),
					MaxDistance = 220,
					AlwaysOnTop = false,
				})
				ligneEtat = textes[2]
			end)
		end
	end

	-- ===== réaction aux événements =====
	local function lireAttribut(nom)
		if not Etat then
			return nil
		end
		local ok, valeur = pcall(function()
			return Etat:GetAttribute(nom)
		end)
		if ok then
			return valeur
		end
		return nil
	end

	local function lireEvenement()
		local v = lireAttribut("Evenement")
		if type(v) == "string" then
			return v
		end
		return ""
	end

	local function nomEvenement(cle)
		local E = ctx.Equilibrage
		if E and type(E.evenements) == "table" and type(E.evenements.liste) == "table" then
			local fiche = E.evenements.liste[cle]
			if type(fiche) == "table" and type(fiche.nom) == "string" then
				return fiche.nom
			end
		end
		return cle
	end

	local function ecrirePlaque(texte)
		for _, etiquette in ipairs(plaqueTextes) do
			if etiquette.Parent and etiquette.Text ~= texte then
				etiquette.Text = texte
			end
		end
	end

	local function texteAttente()
		local prochain = lireAttribut("ProchainEvenement")
		if type(prochain) ~= "number" or prochain <= 0 then
			return "Prochain événement bientôt"
		end
		local reste = math.floor(prochain - workspace:GetServerTimeNow())
		if reste <= 0 then
			return "Prochain événement imminent !"
		end
		local minutes = math.floor(reste / 60)
		local secondes = reste % 60
		if minutes > 0 then
			return string.format("Prochain événement : %d min %02d s", minutes, secondes)
		end
		return string.format("Prochain événement : %d s", secondes)
	end

	local function texteEnCours(cle)
		local texte = nomEvenement(cle) .. " en cours !"
		local fin = lireAttribut("EvenementFin")
		if type(fin) == "number" and fin > 0 then
			local reste = math.floor(fin - workspace:GetServerTimeNow())
			if reste > 0 then
				texte = string.format("%s : %d s", nomEvenement(cle), reste)
			end
		end
		return texte
	end

	-- ligne courte sous le titre flottant : compte à rebours jaune, ou « EN COURS ! » rouge vif
	local function ecrireLigneEtat(cle)
		if not ligneEtat or not ligneEtat.Parent then
			return
		end
		local texte = "⏳ BIENTÔT"
		local couleur = Charte.dore
		if Style then
			couleur = Style.couleurs.revenu
		end
		if cle ~= "" then
			texte = "🔥 EN COURS !"
			couleur = Charte.alerte
		else
			local prochain = lireAttribut("ProchainEvenement")
			if type(prochain) == "number" and prochain > 0 then
				local reste = math.floor(prochain - workspace:GetServerTimeNow())
				if reste > 0 then
					texte = string.format("⏳ %d:%02d", math.floor(reste / 60), reste % 60)
				else
					texte = "⏳ IMMINENT !"
				end
			end
		end
		if ligneEtat.Text ~= texte then
			ligneEtat.Text = texte
		end
		if ligneEtat.TextColor3 ~= couleur then
			ligneEtat.TextColor3 = couleur
		end
	end

	local function animerVers(inst, props, duree)
		local ok = pcall(function()
			local info = TweenInfo.new(duree, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			TweenService:Create(inst, info, props):Play()
		end)
		if not ok then
			for cle, valeur in pairs(props) do
				pcall(function()
					inst[cle] = valeur
				end)
			end
		end
	end

	local generation = 0
	local actifCourant = nil
	local cleCourante = nil

	local function appliquer(cle)
		local actif = cle ~= ""
		if actif == actifCourant and cle == cleCourante then
			return
		end
		actifCourant = actif
		cleCourante = cle
		generation = generation + 1
		local maGeneration = generation
		local teinte = COULEURS_EVENEMENT[cle] or VIOLET
		local duree = 1.2

		for _, v in ipairs(veines) do
			if v.Parent then
				if actif then
					animerVers(v, { Color = VIOLET_VIF, Transparency = 0 }, duree)
				else
					animerVers(v, { Color = VIOLET_FAIBLE, Transparency = TRANSP_REPOS }, duree)
				end
			end
		end
		for _, fiche in ipairs(cristaux) do
			if fiche.part.Parent then
				if actif then
					animerVers(fiche.part, { Color = fiche.vif, Transparency = 0.05 }, duree)
				else
					animerVers(fiche.part, { Color = fiche.faible, Transparency = TRANSP_REPOS }, duree)
				end
			end
		end
		for i, l in ipairs(lumieres) do
			if l.Parent then
				if actif then
					local couleur = teinte
					if i > 1 then
						couleur = teinte:Lerp(Charte.creme, 0.25)
					end
					if i == 1 then
						animerVers(l, { Brightness = 4, Range = 24, Color = couleur }, duree)
					else
						animerVers(l, { Brightness = 2.5, Range = 14, Color = couleur }, duree)
					end
				else
					if i == 1 then
						animerVers(l, { Brightness = 0.6, Range = 12, Color = VIOLET }, duree)
					else
						animerVers(l, { Brightness = 0.8, Range = 8 }, duree)
					end
				end
			end
		end
		for _, s in ipairs(fumees) do
			if s.Parent then
				if actif then
					animerVers(s, { Opacity = 0.3, Color = FUMEE:Lerp(teinte, 0.4) }, duree)
					s.RiseVelocity = 6
				else
					animerVers(s, { Opacity = 0.12, Color = FUMEE }, duree)
					s.RiseVelocity = 3
				end
			end
		end

		-- pendant l'événement, la lumière du coeur palpite doucement
		if actif and lumieres[1] then
			local lumiereCoeur = lumieres[1]
			task.spawn(function()
				task.wait(duree)
				local t = 0
				while generation == maGeneration and lumiereCoeur.Parent and dossier.Parent do
					t = t + 0.1
					lumiereCoeur.Brightness = 3.5 + math.sin(t * 3) * 1.2
					task.wait(0.1)
				end
			end)
		end
	end

	local function verifier()
		local ok = pcall(appliquer, lireEvenement())
		return ok
	end

	if Etat then
		local ok, signal = pcall(function()
			return Etat:GetAttributeChangedSignal("Evenement")
		end)
		if ok and signal then
			local connexion
			connexion = signal:Connect(function()
				if not dossier.Parent then
					if connexion then
						connexion:Disconnect()
					end
					return
				end
				verifier()
			end)
		end
	end
	verifier()

	-- plaque d'annonce : rafraîchie chaque seconde tant que la map existe
	if #plaqueTextes > 0 or ligneEtat then
		task.spawn(function()
			while dossier.Parent do
				pcall(function()
					local cle = lireEvenement()
					if cle ~= "" then
						ecrirePlaque(texteEnCours(cle))
					else
						ecrirePlaque(texteAttente())
					end
					ecrireLigneEtat(cle)
				end)
				task.wait(1)
			end
		end)
	end

	dossier:SetAttribute("Parts", compteur)
end

return M
