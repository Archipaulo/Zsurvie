-- Builders/Portails.lua : les 4 portails d'où surgissent les Zbires, sur les chemins (Plan.portails).
-- Chaque portail regarde le centre : petite plateforme, arche de pierre (~12 de haut),
-- disque Neon violet pulsant, particules, lumière et runes. Pendant la Horde, tout s'intensifie.
-- Budget : 160 parts (28 par portail).
local M = {}

local BUDGET = 160

-- réglages visuels (décor, pas des chiffres de jeu)
local ECART_PILIERS = 4.5      -- demi-écart latéral entre les axes des piliers
local LARGEUR_PILIER = 2.4
local HAUT_PLATEFORME = 1.1
local HAUT_PILIERS = 10.2      -- sommet des piliers (base du linteau)
local DIAMETRE_DISQUE = 6.4
local CENTRE_DISQUE = 5.6      -- hauteur du centre du disque

-- ambiance calme / ambiance Horde
local CALME = { luminosite = 1.2, portee = 14, debit = 6, vitesseAnime = 0.6, vitesseParticules = 2 }
local HORDE = { luminosite = 3.5, portee = 26, debit = 30, vitesseAnime = 1.8, vitesseParticules = 6 }
local DUREE_TRANSITION = 1.5

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end
	if type(Plan.portails) ~= "table" then
		return
	end

	local centre = Vector3.new(0, 0, 0)
	if Plan.prairie and typeof(Plan.prairie.centre) == "Vector3" then
		centre = Plan.prairie.centre
	end

	local pierre = Charte.ardoise
	local pierreOmbre = Charte.ombre(Charte.ardoise)
	local pierreClaire = Charte.lumiere(Charte.ardoise)
	local terre = Charte.terre
	local violet = Charte.violet
	local violetClair = Charte.lumiere(Charte.violet)
	local violetOmbre = Charte.ombre(Charte.violet)

	-- compteur de parts propre au module
	local nbParts = 0
	local function creer(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return fabrique(parent, props)
	end
	local function bloc(parent, props) return creer(Outils.bloc, parent, props) end
	local function coin(parent, props) return creer(Outils.coin, parent, props) end
	local function cylindre(parent, props) return creer(Outils.cylindre, parent, props) end

	-- éléments animés selon la phase
	local lumieres = {}
	local emetteurs = {}
	local disques = {}
	local runes = {}

	local function construirePortail(nom, position)
		local modele = Outils.modele(dossier, "Portail" .. nom)
		local sol = Vector3.new(position.X, 0, position.Z)
		local cible = Vector3.new(centre.X, 0, centre.Z)
		if (cible - sol).Magnitude < 0.01 then
			cible = sol + Vector3.new(0, 0, -1)
		end
		-- repère local : X latéral, Y vertical, -Z vers le centre
		local repere = CFrame.lookAt(sol, cible)
		local function ici(x, y, z)
			return repere * CFrame.new(x, y, z)
		end

		-- plateforme au sol
		bloc(modele, { Name = "Socle", Size = Vector3.new(12, 0.8, 7), CFrame = ici(0, 0.4, 0), Color = pierreOmbre })
		bloc(modele, { Name = "Dalle", Size = Vector3.new(10, 0.3, 5), CFrame = ici(0, 0.95, 0), Color = terre })
		bloc(modele, { Name = "Marche", Size = Vector3.new(8, 0.4, 1.6), CFrame = ici(0, 0.2, -4.3), Color = pierre })

		-- piliers : plinthe + trois pierres empilées, teintes alternées
		local hautPierre = (HAUT_PILIERS - (HAUT_PLATEFORME + 0.7)) / 3
		for _, cote in ipairs({ -1, 1 }) do
			local x = cote * ECART_PILIERS
			bloc(modele, { Name = "Plinthe", Size = Vector3.new(3, 1, 3), CFrame = ici(x, 0.8 + 0.5, 0), Color = pierreOmbre })
			local y = HAUT_PLATEFORME + 0.7
			for i = 1, 3 do
				local teinte = pierre
				if i == 2 then
					teinte = pierreClaire
				end
				bloc(modele, {
					Name = "Pierre",
					Size = Vector3.new(LARGEUR_PILIER, hautPierre - 0.05, LARGEUR_PILIER),
					CFrame = ici(x, y + hautPierre / 2, 0),
					Color = teinte,
				})
				-- rune lumineuse sur la face tournée vers le centre
				local rune = bloc(modele, {
					Name = "Rune",
					Size = Vector3.new(0.9, 0.9, 0.2),
					CFrame = ici(x, y + hautPierre / 2, -LARGEUR_PILIER / 2 - 0.05) * CFrame.Angles(0, 0, math.rad(45)),
					Color = violetClair,
					Material = Enum.Material.Neon,
					CanCollide = false,
				})
				if rune then
					table.insert(runes, rune)
				end
				y = y + hautPierre
			end

			-- congé de pierre dans l'angle intérieur, sous le linteau
			local interieur = ECART_PILIERS - LARGEUR_PILIER / 2
			coin(modele, {
				Name = "Conge",
				Size = Vector3.new(2.2, 1.6, 1.6),
				CFrame = ici(cote * (interieur - 0.8), HAUT_PILIERS - 0.8, 0)
					* CFrame.Angles(0, math.rad(90 * cote), 0) * CFrame.Angles(0, 0, math.pi),
				Color = pierre,
			})
		end

		-- linteau, chapeau et clé de voûte
		bloc(modele, { Name = "Linteau", Size = Vector3.new(12, 1.4, 3), CFrame = ici(0, HAUT_PILIERS + 0.7, 0), Color = pierre })
		bloc(modele, { Name = "Chapeau", Size = Vector3.new(13, 0.5, 3.4), CFrame = ici(0, HAUT_PILIERS + 1.65, 0), Color = pierreOmbre })
		bloc(modele, { Name = "Cle", Size = Vector3.new(1.8, 2.2, 3.4), CFrame = ici(0, HAUT_PILIERS + 0.8, 0), Color = terre })
		-- deux runes sur le linteau, de part et d'autre de la clé
		for _, cote in ipairs({ -1, 1 }) do
			local rune = bloc(modele, {
				Name = "Rune",
				Size = Vector3.new(1.4, 0.5, 0.2),
				CFrame = ici(cote * 3.2, HAUT_PILIERS + 0.7, -1.55),
				Color = violetClair,
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			if rune then
				table.insert(runes, rune)
			end
		end

		-- disque du portail (l'axe d'un cylindre est son X : on le tourne vers le centre)
		local disque = cylindre(modele, {
			Name = "Disque",
			Size = Vector3.new(0.4, DIAMETRE_DISQUE, DIAMETRE_DISQUE),
			CFrame = ici(0, CENTRE_DISQUE, 0) * CFrame.Angles(0, math.rad(90), 0),
			Color = violet,
			Material = Enum.Material.Neon,
			Transparency = 0.15,
			CanCollide = false,
		})
		cylindre(modele, {
			Name = "Coeur",
			Size = Vector3.new(0.5, DIAMETRE_DISQUE * 0.55, DIAMETRE_DISQUE * 0.55),
			CFrame = ici(0, CENTRE_DISQUE, 0) * CFrame.Angles(0, math.rad(90), 0),
			Color = violetOmbre,
			Material = Enum.Material.Neon,
			Transparency = 0.3,
			CanCollide = false,
		})

		-- deux cristaux aux coins avant de la plateforme
		for _, cote in ipairs({ -1, 1 }) do
			local cristal = bloc(modele, {
				Name = "Cristal",
				Size = Vector3.new(0.8, 1.6, 0.8),
				CFrame = ici(cote * 4.4, HAUT_PLATEFORME + 0.8, -2) * CFrame.Angles(0, math.rad(45), math.rad(12 * cote)),
				Color = violet,
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			if cristal then
				table.insert(runes, cristal)
			end
		end

		if disque then
			Outils.animer(disque, "pulse", CALME.vitesseAnime)
			table.insert(disques, disque)

			local ok, lumiere = pcall(Outils.lumiere, disque, {
				genre = "Point",
				Range = CALME.portee,
				Brightness = CALME.luminosite,
				Color = violet,
			})
			if ok and lumiere then
				lumiere.Name = "LumierePortail"
				table.insert(lumieres, lumiere)
			end

			local okE, emetteur = pcall(function()
				local e = Instance.new("ParticleEmitter")
				e.Name = "Brume"
				e.Color = ColorSequence.new(violetClair, violet)
				e.LightEmission = 0.8
				e.Size = NumberSequence.new(0.6, 0.1)
				e.Transparency = NumberSequence.new(0.2, 1)
				e.Lifetime = NumberRange.new(1.2, 2.2)
				e.Speed = NumberRange.new(CALME.vitesseParticules)
				e.Rate = CALME.debit
				e.SpreadAngle = Vector2.new(25, 25)
				e.Parent = disque
				return e
			end)
			if okE and emetteur then
				table.insert(emetteurs, emetteur)
			end
		end

		modele:SetAttribute("Portail", nom)
		return modele
	end

	-- ordre fixe pour un résultat identique à chaque démarrage
	local ordre = { "Nord", "Est", "Sud", "Ouest" }
	local faits = {}
	for _, nom in ipairs(ordre) do
		local p = Plan.portails[nom]
		if typeof(p) == "Vector3" then
			construirePortail(nom, p)
			faits[nom] = true
		end
	end
	for nom, p in pairs(Plan.portails) do
		if not faits[nom] and typeof(p) == "Vector3" then
			construirePortail(tostring(nom), p)
		end
	end

	-- ===== ambiance selon la phase =====
	local TweenService = nil
	local okT, service = pcall(function() return game:GetService("TweenService") end)
	if okT then
		TweenService = service
	end

	local function vers(inst, buts)
		local fait = false
		if TweenService then
			local ok = pcall(function()
				local info = TweenInfo.new(DUREE_TRANSITION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				TweenService:Create(inst, info, buts):Play()
			end)
			fait = ok
		end
		if not fait then
			pcall(function()
				for cle, valeur in pairs(buts) do
					inst[cle] = valeur
				end
			end)
		end
	end

	local function appliquer(reglage)
		for _, l in ipairs(lumieres) do
			if l.Parent then
				vers(l, { Brightness = reglage.luminosite, Range = reglage.portee })
			end
		end
		for _, e in ipairs(emetteurs) do
			if e.Parent then
				pcall(function()
					e.Rate = reglage.debit
					e.Speed = NumberRange.new(reglage.vitesseParticules)
				end)
			end
		end
		for _, d in ipairs(disques) do
			if d.Parent then
				Outils.animer(d, "pulse", reglage.vitesseAnime)
			end
		end
		for _, r in ipairs(runes) do
			if r.Parent then
				local teinte = violet
				if reglage == HORDE then
					teinte = violetClair
				end
				vers(r, { Color = teinte })
			end
		end
	end

	local Etat = ctx.Etat
	local enHorde = nil
	local function majPhase()
		local phase = nil
		if Etat then
			local ok, valeur = pcall(function() return Etat:GetAttribute("Phase") end)
			if ok then
				phase = valeur
			end
		end
		local horde = phase == "Horde"
		if horde == enHorde then
			return
		end
		enHorde = horde
		if horde then
			appliquer(HORDE)
		else
			appliquer(CALME)
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
