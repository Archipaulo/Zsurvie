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

	local function eclats(impact)
		for i = 1, 4 do
			local angle = alea:NextNumber(0, math.pi * 2)
			local dist = alea:NextNumber(1.5, 4)
			local taille = alea:NextNumber(0.8, 1.6)
			local couleur = Charte.pierre
			if i % 2 == 0 then
				couleur = Charte.lave
			end
			local materiau = Enum.Material.SmoothPlastic
			if couleur == Charte.lave then
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
			Debris:AddItem(eclat, 4)
		end
	end

	local function lancerMeteore()
		local impact = pointAleatoire()
		local depart = impact + Vector3.new(alea:NextNumber(-40, 40), HAUTEUR_CHUTE, alea:NextNumber(-40, 40))
		local rayon = alea:NextNumber(3, 5)
		local boule = nouvellePart({
			Name = "Meteore",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(rayon, rayon, rayon),
			Position = depart,
			Color = Charte.lave,
			Material = Enum.Material.Neon,
		})
		Debris:AddItem(boule, DUREE_CHUTE + 3)

		-- trainee de feu
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, rayon * 0.4, 0)
		a0.Parent = boule
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, -rayon * 0.4, 0)
		a1.Parent = boule
		local trainee = Instance.new("Trail")
		trainee.Attachment0 = a0
		trainee.Attachment1 = a1
		trainee.Lifetime = 0.6
		trainee.LightEmission = 1
		trainee.FaceCamera = true
		trainee.Color = ColorSequence.new(Charte.dore, Charte.lave)
		trainee.Transparency = NumberSequence.new(0, 1)
		trainee.WidthScale = NumberSequence.new(1, 0.2)
		trainee.Parent = boule
		local lueur = Instance.new("PointLight")
		lueur.Color = Charte.lave
		lueur.Range = 16
		lueur.Brightness = 2
		lueur.Parent = boule

		local tween = TweenService:Create(
			boule,
			TweenInfo.new(DUREE_CHUTE, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = impact + Vector3.new(0, rayon / 2, 0) }
		)
		tween.Completed:Connect(function()
			effetTous("Meteore", impact, {})
			pcall(eclats, impact)
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
