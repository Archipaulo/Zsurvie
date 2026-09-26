-- Systeme Evenements : lance regulierement un evenement aleatoire (pluie de meteores, eruption, lune doree).
-- Etat.Evenement / EvenementFin / ProchainEvenement sont tenus a jour ; l'Eruption est jouee par le Volcan
-- et la Lune doree par le Ciel (ils lisent Etat.Evenement) ; ce module fait tomber les meteores.
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local M = {}

local PREMIER_DELAI = 120     -- secondes avant le premier evenement
local PERIODE_METEORE = 1.5   -- une meteorite toutes les 1,5 s
local HAUTEUR_CHUTE = 140     -- altitude de depart d'une meteorite
local DUREE_CHUTE = 1.6       -- temps de chute (s)
local MARGE_BASE = 4          -- marge autour des Bases ou rien ne tombe

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local reglages = ctx.Equilibrage.evenements or {}
	local liste = reglages.liste or {}
	local intervalle = tonumber(reglages.intervalle) or 300
	local duree = tonumber(reglages.duree) or 90
	local alea = Random.new()

	local function maintenant()
		return workspace:GetServerTimeNow()
	end

	local function notifierTous(texte, genre)
		pcall(function()
			Reseau.Notification:FireAllClients(texte, genre)
		end)
	end

	local function effetTous(genre, position, donnees)
		pcall(function()
			Reseau.Effet:FireAllClients(genre, position, donnees)
		end)
	end

	-- dossier des meteorites (objets passagers)
	local dossier = ctx.racine:FindFirstChild("Meteores")
	if not dossier then
		dossier = Instance.new("Folder")
		dossier.Name = "Meteores"
		dossier.Parent = ctx.racine
	end

	-- ===== titre flottant geant au-dessus du Cratere (style simulateur) =====
	local Style = ctx.Style
	local ICONES = {
		PluieDeMeteores = "☄️",
		Eruption = "🌋",
		LuneDoree = "🌕",
	}
	local titre = nil        -- BillboardGui
	local lignesTitre = nil  -- { icone, nom, chrono }
	pcall(function()
		if not Style then
			return
		end
		local scene = ctx.racine:FindFirstChild("TitreEvenement")
		if not scene then
			scene = Instance.new("Folder")
			scene.Name = "TitreEvenement"
			scene.Parent = ctx.racine
		end
		local ancre = Instance.new("Part")
		ancre.Name = "AncreTitre"
		ancre.Anchored = true
		ancre.CanCollide = false
		ancre.CanQuery = false
		ancre.CanTouch = false
		ancre.CastShadow = false
		ancre.Transparency = 1
		ancre.Size = Vector3.new(1, 1, 1)
		ancre.Position = Plan.cratere.centre + Vector3.new(0, 14, 0)
		ancre.Parent = scene
		local g, textes = Style.etiquette(ancre, {
			{ texte = "⭐", taille = 1.2, nom = "Icone" },
			{ texte = "", taille = 1.6, titre = true, rarete = "Divin", contour = 4, nom = "Nom" },
			{ texte = "", taille = 1, couleur = Style.couleurs.revenu, contour = 3.5, nom = "Chrono" },
		}, {
			Name = "TitreEvenement",
			largeur = 40,
			hauteurLigne = 3.4,
			StudsOffset = Vector3.new(0, 6, 0),
			MaxDistance = 400,
			AlwaysOnTop = false,
		})
		g.Enabled = false
		titre = g
		lignesTitre = textes
	end)

	local function chrono(secondes)
		secondes = math.max(0, math.floor(secondes))
		local m = math.floor(secondes / 60)
		local s = secondes % 60
		if s < 10 then
			return m .. ":0" .. s
		end
		return m .. ":" .. s
	end

	-- noms des evenements (tries pour un tirage stable)
	local noms = {}
	for cle in pairs(liste) do
		table.insert(noms, cle)
	end
	table.sort(noms)

	local function nomAffiche(cle)
		local infos = liste[cle]
		if infos and type(infos.nom) == "string" then
			return infos.nom
		end
		return cle
	end

	-- affiche le titre pendant un evenement (nom arc-en-ciel + compte a rebours), le masque sinon
	local function majTitre()
		if not titre or not lignesTitre then
			return
		end
		pcall(function()
			local nom = Etat:GetAttribute("Evenement")
			if type(nom) ~= "string" or nom == "" then
				if titre.Enabled then
					titre.Enabled = false
				end
				return
			end
			local fin = tonumber(Etat:GetAttribute("EvenementFin")) or 0
			local icone = ICONES[nom] or "⭐"
			local texteNom = string.upper(nomAffiche(nom))
			local texteChrono = "⏱ " .. chrono(fin - maintenant())
			if lignesTitre[1].Text ~= icone then
				lignesTitre[1].Text = icone
			end
			if lignesTitre[2].Text ~= texteNom then
				lignesTitre[2].Text = texteNom
			end
			if lignesTitre[3].Text ~= texteChrono then
				lignesTitre[3].Text = texteChrono
			end
			if not titre.Enabled then
				titre.Enabled = true
			end
		end)
	end

	-- ===== choix d'un point d'impact =====
	local function dansUneBase(x, z)
		local demiX = Plan.base.largeur / 2 + MARGE_BASE
		local demiZ = Plan.base.profondeur / 2 + MARGE_BASE
		for _, b in ipairs(Plan.bases) do
			if math.abs(x - b.centre.X) <= demiX and math.abs(z - b.centre.Z) <= demiZ then
				return true
			end
		end
		return false
	end

	local function pointInterdit(x, z)
		if dansUneBase(x, z) then
			return true
		end
		local p = Vector3.new(x, 0, z)
		-- ni dans le cone du volcan, ni sur l'apparition
		if Plan.volcan and ctx.Outils.distanceXZ(p, Plan.volcan.centre) <= Plan.volcan.rayon + 4 then
			return true
		end
		if Plan.place and ctx.Outils.distanceXZ(p, Plan.place.centre) <= 8 then
			return true
		end
		return false
	end

	local function hauteurSol(x, z)
		local y = 0
		pcall(function()
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { dossier, ctx.dinos }
			local resultat = workspace:Raycast(Vector3.new(x, 250, z), Vector3.new(0, -300, 0), params)
			if resultat then
				y = resultat.Position.Y
			end
		end)
		return y
	end

	local function pointAleatoire()
		local mini = Plan.monde.min
		local maxi = Plan.monde.max
		for _ = 1, 25 do
			local x = alea:NextNumber(mini.X + 12, maxi.X - 12)
			local z = alea:NextNumber(mini.Z + 12, maxi.Z - 12)
			if not pointInterdit(x, z) then
				return Vector3.new(x, hauteurSol(x, z), z)
			end
		end
		local c = Plan.cratere.centre
		return Vector3.new(c.X, hauteurSol(c.X, c.Z), c.Z)
	end

	-- ===== une meteorite =====
	local function nouvellePart(props)
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		for cle, valeur in pairs(props) do
			p[cle] = valeur
		end
		p.Parent = dossier
		return p
	end

	-- couleurs cartoon des meteorites (jaune -> orange -> rose, comme les degrades des boutons)
	local JAUNE = Charte.dore
	local ORANGE = Charte.lave
	local ROSE = Charte.alerte
	if Style then
		JAUNE = Style.couleurs.revenu
		ORANGE = Style.boutons.orange[2]
		ROSE = Style.boutons.rose[2]
	end
	local ROCHE = Charte.encre:Lerp(Charte.pierre, 0.45)

	-- fait disparaitre une part en douceur puis la detruit
	local function effacer(part, attente, duree)
		task.delay(attente, function()
			if part.Parent then
				TweenService:Create(part, TweenInfo.new(duree, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
			end
		end)
		Debris:AddItem(part, attente + duree + 0.2)
	end

	-- disque plat (cylindre couche) centre sur un point du sol
	local function disque(nom, centre, diametre, epaisseur, couleur, materiau)
		return nouvellePart({
			Name = nom,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(epaisseur, diametre, diametre),
			CFrame = CFrame.new(centre + Vector3.new(0, epaisseur / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
			Material = materiau,
		})
	end

	-- cratere cartoon : rebord sombre, coeur Neon qui brille puis s'eteint, gros eclats colores
	local function eclats(impact, rayon)
		local rebord = disque("CratereRebord", impact, rayon * 3.4, 0.5, ROCHE, Enum.Material.SmoothPlastic)
		effacer(rebord, 3.5, 1.2)
		local coeur = disque("CratereCoeur", impact, rayon * 2.1, 0.7, ORANGE, Enum.Material.Neon)
		effacer(coeur, 0.8, 2.5)
		local centre = disque("CratereCentre", impact, rayon * 1, 0.8, JAUNE, Enum.Material.Neon)
		effacer(centre, 0.4, 1.5)
		for i = 1, 6 do
			local angle = (i / 6) * math.pi * 2 + alea:NextNumber(-0.3, 0.3)
			local dist = rayon * 1.4 + alea:NextNumber(0, 1.5)
			local taille = alea:NextNumber(1.2, 2.2)
			local couleur = ROCHE
			local materiau = Enum.Material.SmoothPlastic
			if i % 3 == 0 then
				couleur = JAUNE
				materiau = Enum.Material.Neon
			elseif i % 3 == 1 then
				couleur = ORANGE
				materiau = Enum.Material.Neon
			end
			local eclat = nouvellePart({
				Name = "Debris",
				Size = Vector3.new(taille, taille, taille),
				CFrame = CFrame.new(impact + Vector3.new(math.cos(angle) * dist, taille / 2, math.sin(angle) * dist))
					* CFrame.Angles(alea:NextNumber(0, 3), alea:NextNumber(0, 3), 0),
				Color = couleur,
				Material = materiau,
			})
			effacer(eclat, 3, 1)
		end
	end

	local function lancerMeteore()
		local impact = pointAleatoire()
		local depart = impact + Vector3.new(alea:NextNumber(-40, 40), HAUTEUR_CHUTE, alea:NextNumber(-40, 40))
		local rayon = alea:NextNumber(5, 7.5)
		local boule = nouvellePart({
			Name = "Meteore",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(rayon, rayon, rayon),
			Position = depart,
			Color = ORANGE,
			Material = Enum.Material.Neon,
		})
		Debris:AddItem(boule, DUREE_CHUTE + 3)

		-- trainee coloree large (jaune -> orange -> rose)
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, rayon * 0.5, 0)
		a0.Parent = boule
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, -rayon * 0.5, 0)
		a1.Parent = boule
		local trainee = Instance.new("Trail")
		trainee.Attachment0 = a0
		trainee.Attachment1 = a1
		trainee.Lifetime = 0.9
		trainee.LightEmission = 1
		trainee.FaceCamera = true
		trainee.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, JAUNE),
			ColorSequenceKeypoint.new(0.45, ORANGE),
			ColorSequenceKeypoint.new(1, ROSE),
		})
		trainee.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.6, 0.35),
			NumberSequenceKeypoint.new(1, 1),
		})
		trainee.WidthScale = NumberSequence.new(1.2, 0.1)
		trainee.Parent = boule
		-- etincelles cartoon
		local etincelles = Instance.new("ParticleEmitter")
		etincelles.Color = ColorSequence.new(JAUNE, ORANGE)
		etincelles.LightEmission = 1
		etincelles.Rate = 30
		etincelles.Lifetime = NumberRange.new(0.4, 0.7)
		etincelles.Speed = NumberRange.new(4, 9)
		etincelles.SpreadAngle = Vector2.new(180, 180)
		etincelles.Size = NumberSequence.new(1.2, 0)
		etincelles.Parent = boule
		local lueur = Instance.new("PointLight")
		lueur.Color = ORANGE
		lueur.Range = 22
		lueur.Brightness = 3
		lueur.Parent = boule

		local tween = TweenService:Create(
			boule,
			TweenInfo.new(DUREE_CHUTE, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = impact + Vector3.new(0, rayon / 2, 0) }
		)
		tween.Completed:Connect(function()
			effetTous("Meteore", impact, {})
			pcall(eclats, impact, rayon)
			if boule.Parent then
				boule:Destroy()
			end
		end)
		tween:Play()
	end

	-- ===== deroulement =====
	local generation = 0 -- change a chaque debut : invalide les fins et pluies de l'evenement precedent

	local function terminer(gen)
		if gen ~= generation then
			return
		end
		local nom = Etat:GetAttribute("Evenement")
		if type(nom) ~= "string" or nom == "" then
			return
		end
		generation = generation + 1
		Etat:SetAttribute("Evenement", "")
		Etat:SetAttribute("EvenementFin", 0)
		majTitre()
		Bus.emettre("EvenementFin", nom)
		notifierTous(nomAffiche(nom) .. " : c'est fini !", "info")
	end

	local function pluie(gen)
		while gen == generation and Etat:GetAttribute("Evenement") == "PluieDeMeteores" do
			pcall(lancerMeteore)
			task.wait(PERIODE_METEORE)
		end
	end

	local function lancer(nom)
		if type(nom) ~= "string" or not liste[nom] then
			return false
		end
		-- un evenement deja en cours se termine proprement avant le nouveau
		local enCours = Etat:GetAttribute("Evenement")
		if type(enCours) == "string" and enCours ~= "" then
			terminer(generation)
		end
		generation = generation + 1
		local gen = generation
		local debut = maintenant()
		Etat:SetAttribute("Evenement", nom)
		Etat:SetAttribute("EvenementFin", debut + duree)
		Etat:SetAttribute("ProchainEvenement", debut + intervalle)
		majTitre()
		Bus.emettre("EvenementDebut", nom)
		notifierTous("Événement : " .. nomAffiche(nom) .. " !", "alerte")
		effetTous("Evenement", Plan.cratere.centre, { nom = nom })
		if nom == "PluieDeMeteores" then
			task.spawn(pluie, gen)
		end
		task.delay(duree, function()
			terminer(gen)
		end)
		return true
	end

	Bus.repondre("LancerEvenement", function(nom)
		return lancer(nom)
	end)

	-- ===== horloge =====
	Etat:SetAttribute("Evenement", "")
	Etat:SetAttribute("EvenementFin", 0)
	Etat:SetAttribute("ProchainEvenement", maintenant() + PREMIER_DELAI)

	-- compte a rebours du titre, rafraichi plus souvent que l'horloge
	task.spawn(function()
		while true do
			majTitre()
			task.wait(0.5)
		end
	end)

	while true do
		task.wait(1)
		local enCours = Etat:GetAttribute("Evenement")
		local libre = type(enCours) ~= "string" or enCours == ""
		local prochain = tonumber(Etat:GetAttribute("ProchainEvenement")) or 0
		if libre and #noms > 0 and maintenant() >= prochain then
			local ok = pcall(lancer, noms[alea:NextInteger(1, #noms)])
			if not ok then
				Etat:SetAttribute("ProchainEvenement", maintenant() + intervalle)
			end
		end
	end
end

return M
