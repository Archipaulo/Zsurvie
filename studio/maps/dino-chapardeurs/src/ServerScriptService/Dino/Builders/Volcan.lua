-- Constructeur Volcan : pièce maîtresse du nord. Cône en couches de pierre sombre de plus en plus étroites,
-- cratère au sommet avec lac de lave, coulées sur les flancs, rochers, fumée et lueur orange.
-- Pendant l'événement « Eruption » (ctx.Etat.Evenement) : projections de lave, lumière vive, lave qui pulse vite.
-- Emprise (CONTRAT §10) : disque de rayon 34 autour de Plan.volcan.centre, hauteur ≤ 70.
local M = {}

local BUDGET = 350 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier

	-- réglages facultatifs (Equilibrage.volcan), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.volcan) == "table" then
		reglages = ctx.Equilibrage.volcan
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	-- position et limites de l'emprise
	local infoVolcan = Plan.volcan or {}
	local CENTRE = infoVolcan.centre or Vector3.new(0, 0, -150)
	local RAYON_MAX = infoVolcan.rayon or 34
	local HAUTEUR_MAX = infoVolcan.hauteur or 70
	local CX, CZ = CENTRE.X, CENTRE.Z

	local COUCHES = math.floor(math.max(6, math.min(14, reglage("couches", 10))))
	local HAUTEUR_COUCHE = math.max(3, reglage("hauteurCouche", 6))
	-- le sommet du cône laisse la place au rebord du cratère (5 studs) sous la hauteur maximale
	if COUCHES * HAUTEUR_COUCHE > HAUTEUR_MAX - 6 then
		HAUTEUR_COUCHE = (HAUTEUR_MAX - 6) / COUCHES
	end
	local SOMMET = COUCHES * HAUTEUR_COUCHE
	local RAYON_BAS = math.min(RAYON_MAX - 3, reglage("rayonBas", 31))
	local RAYON_HAUT = math.max(8, math.min(RAYON_BAS - 6, reglage("rayonHaut", 11)))
	local RAYON_LAC = RAYON_HAUT - 2.5
	local NB_COULEES = math.floor(math.max(2, math.min(6, reglage("coulees", 5))))
	local VITESSE_PULSE_CALME = reglage("pulseCalme", 0.7)
	local VITESSE_PULSE_ERUPTION = reglage("pulseEruption", 4)

	local rng = Outils.aleatoire(reglage("graine", 2026))

	-- couleurs (toutes dérivées de la Charte)
	local PIERRE = Charte.pierre
	local PIERRE_OMBRE = Charte.ombre(Charte.pierre)
	local ENCRE = Charte.encre
	local LAVE = Charte.lave
	local LAVE_VIVE = Charte.lumiere(Charte.lave)
	local BRAISE = Charte.dore

	-- compteur de parts : on s'arrête net au budget
	local compteur = 0
	local function part(fabrique, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		compteur = compteur + 1
		return fabrique(parent, props)
	end

	local modele = Outils.modele(dossier, "Volcan")
	local cone = Outils.modele(modele, "Cone")
	local rochers = Outils.modele(modele, "Rochers")
	local lave = Outils.modele(modele, "Lave") -- tout ce qui brille et pulse

	-- rayon d'une couche : profil légèrement concave (plus raide vers le sommet)
	local function rayonCouche(i)
		local t = (i - 1) / (COUCHES - 1)
		return RAYON_HAUT + (RAYON_BAS - RAYON_HAUT) * math.pow(1 - t, 1.25)
	end

	-- direction horizontale d'un angle (radians)
	local function direction(a)
		return Vector3.new(math.cos(a), 0, math.sin(a))
	end

	-- CFrame orientée vers l'extérieur du volcan (regard = direction a)
	local function versExterieur(rayon, y, a)
		local d = direction(a)
		local pos = Vector3.new(CX, y, CZ) + d * rayon
		return CFrame.lookAt(pos, pos + d)
	end

	-- angles des coulées de lave (réparties tout autour, légèrement irrégulières)
	local anglesCoulees = {}
	for k = 1, NB_COULEES do
		local a = (k - 1) / NB_COULEES * math.pi * 2 + math.rad(rng:NextNumber(-12, 12)) + math.rad(25)
		table.insert(anglesCoulees, a)
	end
	local function presDUneCoulee(a, marge)
		for _, ac in ipairs(anglesCoulees) do
			local ecart = math.abs(((a - ac + math.pi) % (math.pi * 2)) - math.pi)
			if ecart < marge then
				return true
			end
		end
		return false
	end

	-- ===== le cône : couches de pierre de plus en plus étroites =====
	for i = 1, COUCHES do
		local r = rayonCouche(i)
		local yBas = (i - 1) * HAUTEUR_COUCHE
		local t = (i - 1) / (COUCHES - 1)
		local couleur = PIERRE:Lerp(ENCRE, 0.15 + 0.55 * t)
		if i % 2 == 0 then
			couleur = Charte.ombre(couleur)
		end
		part(Outils.cylindre, cone, {
			Name = "Couche" .. i,
			Size = Vector3.new(HAUTEUR_COUCHE, r * 2, r * 2),
			CFrame = CFrame.new(CX, yBas + HAUTEUR_COUCHE / 2, CZ) * CFrame.Angles(0, 0, math.pi / 2),
			Color = couleur,
		})

		-- blocs saillants sur le bord de la couche : silhouette rocailleuse
		local nbBlocs = math.max(4, math.floor(r / 4.5))
		for b = 1, nbBlocs do
			local a = (b - 1) / nbBlocs * math.pi * 2 + rng:NextNumber(-0.2, 0.2) + i * 0.7
			if not presDUneCoulee(a, math.rad(14)) then
				local largeur = rng:NextNumber(3, 5)
				local profondeur = rng:NextNumber(2.5, 4)
				local haut = HAUTEUR_COUCHE * rng:NextNumber(0.6, 1)
				local demiDiag = math.sqrt(largeur * largeur + profondeur * profondeur) / 2
				-- le bloc ne dépasse jamais l'emprise
				local rb = math.min(r - 0.8, RAYON_MAX - 0.5 - demiDiag)
				local cf = versExterieur(rb, yBas + haut / 2, a) * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0)
				local teinte = couleur
				if rng:NextNumber() < 0.4 then
					teinte = PIERRE_OMBRE:Lerp(ENCRE, rng:NextNumber(0.2, 0.6))
				end
				part(Outils.bloc, cone, {
					Name = "Saillie",
					Size = Vector3.new(largeur, haut, profondeur),
					CFrame = cf,
					Color = teinte,
				})
			end
		end
	end

	-- ===== le cratère : fond sombre, lac de lave, rebord déchiqueté =====
	part(Outils.cylindre, cone, {
		Name = "FondCratere",
		Size = Vector3.new(0.4, RAYON_HAUT * 2 - 1, RAYON_HAUT * 2 - 1),
		CFrame = CFrame.new(CX, SOMMET + 0.2, CZ) * CFrame.Angles(0, 0, math.pi / 2),
		Color = ENCRE,
	})
	local lac = part(Outils.cylindre, lave, {
		Name = "LacDeLave",
		Size = Vector3.new(0.6, RAYON_LAC * 2, RAYON_LAC * 2),
		CFrame = CFrame.new(CX, SOMMET + 0.5, CZ) * CFrame.Angles(0, 0, math.pi / 2),
		Color = LAVE,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CanQuery = false,
		CastShadow = false,
	})

	local NB_REBORD = reglage("blocsRebord", 14)
	for b = 1, NB_REBORD do
		local a = (b - 1) / NB_REBORD * math.pi * 2 + rng:NextNumber(-0.08, 0.08)
		local haut = math.min(HAUTEUR_MAX - SOMMET - 0.5, rng:NextNumber(3, 5.5))
		-- échancrure là où la lave déborde du cratère
		if presDUneCoulee(a, math.rad(12)) then
			haut = 1
		end
		local largeur = 2 * math.pi * (RAYON_HAUT - 1.2) / NB_REBORD + 0.8
		part(Outils.bloc, cone, {
			Name = "Rebord",
			Size = Vector3.new(largeur, haut, 2.6),
			CFrame = versExterieur(RAYON_HAUT - 1.2, SOMMET + haut / 2, a) * CFrame.Angles(math.rad(rng:NextNumber(-8, 4)), 0, 0),
			Color = PIERRE_OMBRE:Lerp(ENCRE, rng:NextNumber(0.3, 0.7)),
		})
	end

	-- bulles de lave qui flottent dans le lac
	for b = 1, 4 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(1, RAYON_LAC - 2)
		local taille = rng:NextNumber(1.2, 2.2)
		local bulle = part(Outils.boule, lave, {
			Name = "Bulle",
			Size = Vector3.new(taille, taille, taille),
			CFrame = CFrame.new(CX, SOMMET + 0.7, CZ) + direction(a) * d,
			Color = LAVE_VIVE,
			Material = Enum.Material.Neon,
			CanCollide = false,
			CanQuery = false,
			CastShadow = false,
		})
		if bulle then
			Outils.animer(bulle, "flotte", rng:NextNumber(1.2, 2.2))
		end
	end

	-- ===== les coulées de lave sur les flancs =====
	local coulees = {} -- parts de lave (pour les changer de teinte pendant l'éruption)
	if lac then
		table.insert(coulees, lac)
	end
	local lueursPied = {}
	for k, a in ipairs(anglesCoulees) do
		local coulee = Outils.modele(lave, "Coulee" .. k)
		for i = COUCHES, 1, -1 do
			local r = rayonCouche(i)
			local yBas = (i - 1) * HAUTEUR_COUCHE
			-- la coulée s'élargit en descendant
			local largeur = 1.8 + (COUCHES - i) / COUCHES * 2.4 + rng:NextNumber(-0.3, 0.3)
			-- chute verticale sur le flanc de la couche
			local chute = part(Outils.bloc, coulee, {
				Name = "Chute",
				Size = Vector3.new(largeur, HAUTEUR_COUCHE + 0.1, 0.4),
				CFrame = versExterieur(r + 0.1, yBas + HAUTEUR_COUCHE / 2, a),
				Color = LAVE,
				Material = Enum.Material.Neon,
				CanCollide = false,
				CanQuery = false,
				CastShadow = false,
			})
			if chute then
				table.insert(coulees, chute)
			end
			-- ruisseau sur la terrasse du dessous (du bord de la couche i au bord de la couche i - 1)
			if i > 1 then
				local rDessous = rayonCouche(i - 1)
				local longueur = rDessous - r + 0.2
				local ruisseau = part(Outils.bloc, coulee, {
					Name = "Ruisseau",
					Size = Vector3.new(largeur + 0.2, 0.3, longueur),
					CFrame = versExterieur(r + longueur / 2, yBas + 0.15, a),
					Color = LAVE,
					Material = Enum.Material.Neon,
					CanCollide = false,
					CanQuery = false,
					CastShadow = false,
				})
				if ruisseau then
					table.insert(coulees, ruisseau)
				end
			end
		end
		-- mare de lave au pied de la coulée (dans l'emprise)
		local rayonMare = 2.2
		local mare = part(Outils.cylindre, coulee, {
			Name = "Mare",
			Size = Vector3.new(0.3, rayonMare * 2, rayonMare * 2),
			CFrame = CFrame.new(CX, 0.15, CZ) + direction(a) * math.min(RAYON_BAS + 0.5, RAYON_MAX - rayonMare - 0.3),
			Color = LAVE,
			Material = Enum.Material.Neon,
			CanCollide = false,
			CanQuery = false,
			CastShadow = false,
		})
		if mare then
			mare.CFrame = mare.CFrame * CFrame.Angles(0, 0, math.pi / 2)
			table.insert(coulees, mare)
			table.insert(lueursPied, Outils.lumiere(mare, { Range = 12, Brightness = 1.2, Color = LAVE }))
		end
	end

	-- ===== rochers au pied du volcan =====
	local NB_ROCHERS = reglage("rochers", 14)
	for n = 1, NB_ROCHERS do
		local a = (n - 1) / NB_ROCHERS * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
		if not presDUneCoulee(a, math.rad(10)) then
			local taille = Vector3.new(rng:NextNumber(1.8, 3), rng:NextNumber(1.2, 2.6), rng:NextNumber(1.8, 3))
			local demiDiag = math.sqrt(taille.X * taille.X + taille.Z * taille.Z) / 2
			local rr = math.min(RAYON_BAS + 1, RAYON_MAX - 0.3 - demiDiag)
			local pos = direction(a) * rr
			part(Outils.bloc, rochers, {
				Name = "Rocher",
				Size = taille,
				CFrame = Outils.surSol(taille, CX + pos.X, CZ + pos.Z, rng:NextNumber(0, 360)),
				Color = PIERRE:Lerp(ENCRE, rng:NextNumber(0.2, 0.6)),
			})
		end
	end

	-- ===== la bouche : fumée, lueur et projections =====
	local bouche = part(Outils.bloc, modele, {
		Name = "Bouche",
		Size = Vector3.new(4, 1, 4),
		CFrame = CFrame.new(CX, SOMMET + 1.5, CZ),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
	})

	local fumee, lumiere, projections
	if bouche then
		pcall(function()
			fumee = Instance.new("Smoke")
			fumee.Name = "Fumee"
			fumee.Color = PIERRE_OMBRE
			fumee.Opacity = 0.25
			fumee.RiseVelocity = 6
			fumee.Size = 12
			fumee.Parent = bouche
		end)

		lumiere = Outils.lumiere(bouche, { Range = 40, Brightness = 2, Color = LAVE })
		lumiere.Name = "Lueur"
		lumiere.Shadows = false

		pcall(function()
			projections = Instance.new("ParticleEmitter")
			projections.Name = "Projections"
			projections.EmissionDirection = Enum.NormalId.Top
			projections.Color = ColorSequence.new(BRAISE, LAVE)
			projections.LightEmission = 1
			projections.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.6),
				NumberSequenceKeypoint.new(1, 0.4),
			})
			projections.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.8, 0.1),
				NumberSequenceKeypoint.new(1, 1),
			})
			projections.Speed = NumberRange.new(35, 55)
			projections.SpreadAngle = Vector2.new(35, 35)
			projections.Acceleration = Vector3.new(0, -40, 0)
			projections.Lifetime = NumberRange.new(2.2, 3.4)
			projections.Rotation = NumberRange.new(0, 360)
			projections.RotSpeed = NumberRange.new(-120, 120)
			projections.Rate = reglage("projectionsParSeconde", 45)
			projections.Enabled = false
			projections.Parent = bouche
		end)
	end

	-- la lave pulse doucement au calme
	Outils.animer(lave, "pulse", VITESSE_PULSE_CALME)

	-- ===== réaction à l'éruption =====
	local Etat = ctx.Etat
	local generation = 0 -- change à chaque bascule : arrête l'ancienne boucle de scintillement

	local function appliquer(enEruption)
		generation = generation + 1
		local maGeneration = generation
		local couleurLave = LAVE
		if enEruption then
			couleurLave = LAVE_VIVE
		end
		pcall(function()
			for _, p in ipairs(coulees) do
				if p.Parent then
					p.Color = couleurLave
				end
			end
			for _, l in ipairs(lueursPied) do
				if l.Parent then
					if enEruption then
						l.Brightness = 2.5
						l.Range = 16
					else
						l.Brightness = 1.2
						l.Range = 12
					end
				end
			end
		end)
		pcall(function()
			if enEruption then
				Outils.animer(lave, "pulse", VITESSE_PULSE_ERUPTION)
			else
				Outils.animer(lave, "pulse", VITESSE_PULSE_CALME)
			end
		end)
		pcall(function()
			if projections then
				projections.Enabled = enEruption
			end
			if fumee then
				if enEruption then
					fumee.Color = ENCRE
					fumee.Opacity = 0.6
					fumee.RiseVelocity = 14
					fumee.Size = 22
				else
					fumee.Color = PIERRE_OMBRE
					fumee.Opacity = 0.25
					fumee.RiseVelocity = 6
					fumee.Size = 12
				end
			end
			if lumiere then
				if enEruption then
					lumiere.Range = 60
					lumiere.Brightness = 6
				else
					lumiere.Range = 40
					lumiere.Brightness = 2
				end
			end
		end)
		-- scintillement de la lueur pendant l'éruption
		if enEruption and lumiere then
			task.spawn(function()
				local alea = Random.new()
				while generation == maGeneration and lumiere.Parent and dossier.Parent do
					lumiere.Brightness = alea:NextNumber(4.5, 7.5)
					task.wait(0.15)
				end
			end)
		end
	end

	local etatCourant = false
	local function verifier()
		local evenement = ""
		if Etat then
			local ok, valeur = pcall(function()
				return Etat:GetAttribute("Evenement")
			end)
			if ok and type(valeur) == "string" then
				evenement = valeur
			end
		end
		local enEruption = evenement == "Eruption"
		if enEruption ~= etatCourant then
			etatCourant = enEruption
			appliquer(enEruption)
		end
	end

	if Etat then
		local ok, signal = pcall(function()
			return Etat:GetAttributeChangedSignal("Evenement")
		end)
		if ok and signal then
			local connexion
			connexion = signal:Connect(function()
				if not dossier.Parent then
					connexion:Disconnect()
					return
				end
				verifier()
			end)
		end
	end
	verifier()
end

return M
