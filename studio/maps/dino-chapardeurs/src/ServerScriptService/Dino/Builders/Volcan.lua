-- Constructeur Volcan : pièce maîtresse du nord, version cartoon « simulateur ».
-- Cône arrondi en couches de pierre brun-gris claire (chaque terrasse soulignée d'un liseré clair),
-- bosses rondes sur les flancs, rebord du cratère en boules, lac et coulées de lave orange vif,
-- rochers ronds au pied, fumée claire et titre géant flottant « VOLCAN » cerné de noir.
-- Pendant l'événement « Eruption » (ctx.Etat.Evenement) : projections de lave, lumière vive,
-- lave jaune-orange qui pulse vite, fumée plus sombre et alerte flottante « ÉRUPTION ! ».
-- Emprise (CONTRAT §10) : disque de rayon 34 autour de Plan.volcan.centre, hauteur ≤ 70.
local M = {}

local BUDGET = 350 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
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
	-- le sommet du cône laisse la place au rebord du cratère sous la hauteur maximale
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
	local LISERE = 0.6 -- débord du liseré clair de chaque terrasse
	local DECALAGE_COULEE = LISERE + 0.25 -- la lave coule devant le liseré

	local rng = Outils.aleatoire(reglage("graine", 2026))

	-- ===== couleurs : pierre brun-gris claire, lave orange vif (palette du Style) =====
	local hex = Charte.hex
	local PIERRE = hex("A48E7E")
	local PIERRE_HAUT = hex("8C7666") -- un peu plus chaude et plus sombre vers le sommet
	local PIERRE_CLAIRE = Charte.lumiere(hex("BCA898"))
	local PIERRE_OMBRE = Charte.ombre(PIERRE)
	local FOND_CRATERE = hex("5A4136")
	local LAVE = Charte.lave
	local LAVE_VIVE = Charte.lumiere(Charte.lave)
	local BRAISE = Charte.dore
	local CONTOUR = Charte.encre
	local BLANC = Color3.new(1, 1, 1)
	local ALERTE = Charte.lave
	local TITRE_HAUT, TITRE_BAS = BRAISE, LAVE
	if Style and Style.boutons and Style.couleurs then
		local orange = Style.boutons.orange
		local jaune = Style.boutons.jaune
		if orange and jaune then
			LAVE = orange[2]:Lerp(orange[1], 0.3) -- orange vif
			LAVE_VIVE = jaune[1]:Lerp(orange[1], 0.4) -- jaune-orange éclatant pendant l'éruption
			TITRE_HAUT, TITRE_BAS = jaune[1], orange[2]
		end
		if Style.couleurs.revenu then
			BRAISE = Style.couleurs.revenu
		end
		if Style.couleurs.contour then
			CONTOUR = Style.couleurs.contour
		end
		if Style.couleurs.texte then
			BLANC = Style.couleurs.texte
		end
		if Style.boutons.rouge then
			ALERTE = Style.boutons.rouge[1]
		end
	end
	local FUMEE_CALME = hex("E4DED8")
	local FUMEE_ERUPTION = hex("6E6470")

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

	-- rayon d'une couche : profil bombé (épaules rondes, sommet net), silhouette de gros bonbon
	local function rayonCouche(i)
		local t = (i - 1) / (COUCHES - 1)
		return RAYON_HAUT + (RAYON_BAS - RAYON_HAUT) * (1 - math.pow(t, 1.5))
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

	-- disque horizontal (cylindre couché : l'axe d'un cylindre Roblox est son axe X)
	local function disque(y, rayon, epaisseur)
		return Vector3.new(epaisseur, rayon * 2, rayon * 2), CFrame.new(CX, y, CZ) * CFrame.Angles(0, 0, math.pi / 2)
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

	-- ===== le cône : couches de pierre claire, liseré clair, bosses rondes =====
	for i = 1, COUCHES do
		local r = rayonCouche(i)
		local yBas = (i - 1) * HAUTEUR_COUCHE
		local t = (i - 1) / (COUCHES - 1)
		local couleur = PIERRE:Lerp(PIERRE_HAUT, t)
		if i % 2 == 0 then
			-- alternance très douce : on lit les terrasses sans assombrir le volcan
			couleur = couleur:Lerp(PIERRE_OMBRE, 0.25)
		end
		local taille, cf = disque(yBas + HAUTEUR_COUCHE / 2, r, HAUTEUR_COUCHE)
		part(Outils.cylindre, cone, {
			Name = "Couche" .. i,
			Size = taille,
			CFrame = cf,
			Color = couleur,
		})

		-- liseré clair en haut de la couche : le bord de terrasse se lit de loin (style jouet)
		local tailleL, cfL = disque(yBas + HAUTEUR_COUCHE - 0.4, r + LISERE, 0.8)
		part(Outils.cylindre, cone, {
			Name = "Lisere" .. i,
			Size = tailleL,
			CFrame = cfL,
			Color = PIERRE_CLAIRE:Lerp(couleur, 0.3 * t),
		})

		-- bosses rondes sur le flanc de la couche : silhouette douce et cartoon
		local nbBosses = math.max(3, math.floor(r / 6))
		for b = 1, nbBosses do
			local a = (b - 1) / nbBosses * math.pi * 2 + rng:NextNumber(-0.2, 0.2) + i * 0.7
			if not presDUneCoulee(a, math.rad(16)) then
				local d = math.min(HAUTEUR_COUCHE * 0.9, rng:NextNumber(3.4, 5))
				-- la bosse ne dépasse jamais l'emprise
				local rb = math.min(r - 0.4, RAYON_MAX - 0.5 - d / 2)
				local teinte = couleur:Lerp(PIERRE_CLAIRE, rng:NextNumber(0.1, 0.35))
				if rng:NextNumber() < 0.35 then
					teinte = couleur:Lerp(PIERRE_OMBRE, rng:NextNumber(0.3, 0.6))
				end
				part(Outils.boule, cone, {
					Name = "Bosse",
					Size = Vector3.new(d, d, d),
					CFrame = CFrame.new(CX, yBas + HAUTEUR_COUCHE * 0.45, CZ) + direction(a) * rb,
					Color = teinte,
				})
			end
		end
	end

	-- ===== le cratère : fond brun chaud, lac de lave, rebord en boules =====
	local tailleF, cfF = disque(SOMMET + 0.2, RAYON_HAUT - 0.5, 0.4)
	part(Outils.cylindre, cone, {
		Name = "FondCratere",
		Size = tailleF,
		CFrame = cfF,
		Color = FOND_CRATERE,
	})
	local tailleLac, cfLac = disque(SOMMET + 0.5, RAYON_LAC, 0.6)
	local lac = part(Outils.cylindre, lave, {
		Name = "LacDeLave",
		Size = tailleLac,
		CFrame = cfLac,
		Color = LAVE,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CanQuery = false,
		CastShadow = false,
	})

	local NB_REBORD = reglage("blocsRebord", 14)
	local rayonRebord = RAYON_HAUT - 1.2
	local dRebord = math.min(2 * math.pi * rayonRebord / NB_REBORD + 1, 5.5)
	for b = 1, NB_REBORD do
		local a = (b - 1) / NB_REBORD * math.pi * 2 + rng:NextNumber(-0.06, 0.06)
		local d = dRebord * rng:NextNumber(0.9, 1.05)
		-- échancrure là où la lave déborde du cratère : boule plus petite
		if presDUneCoulee(a, math.rad(12)) then
			d = 1.8
		end
		d = math.min(d, HAUTEUR_MAX - SOMMET)
		part(Outils.boule, cone, {
			Name = "Rebord",
			Size = Vector3.new(d, d, d),
			CFrame = CFrame.new(CX, SOMMET + d / 2 - 0.6, CZ) + direction(a) * rayonRebord,
			Color = PIERRE_HAUT:Lerp(PIERRE_CLAIRE, rng:NextNumber(0.1, 0.4)),
		})
	end

	-- bulles de lave qui flottent dans le lac
	for b = 1, 4 do
		local a = rng:NextNumber(0, math.pi * 2)
		local d = rng:NextNumber(1, RAYON_LAC - 2)
		local taille = rng:NextNumber(1.4, 2.4)
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
			local largeur = 2.2 + (COUCHES - i) / COUCHES * 2.6 + rng:NextNumber(-0.3, 0.3)
			-- chute verticale devant le flanc et le liseré de la couche
			local chute = part(Outils.bloc, coulee, {
				Name = "Chute",
				Size = Vector3.new(largeur, HAUTEUR_COUCHE + 0.1, 0.5),
				CFrame = versExterieur(r + DECALAGE_COULEE, yBas + HAUTEUR_COUCHE / 2, a),
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
				local rDessous = rayonCouche(i - 1) + DECALAGE_COULEE
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
		local rayonMare = 2.4
		local tailleM = Vector3.new(0.3, rayonMare * 2, rayonMare * 2)
		local posMare = Vector3.new(CX, 0.15, CZ) + direction(a) * math.min(RAYON_BAS + 1.2, RAYON_MAX - rayonMare - 0.3)
		local mare = part(Outils.cylindre, coulee, {
			Name = "Mare",
			Size = tailleM,
			CFrame = CFrame.new(posMare) * CFrame.Angles(0, 0, math.pi / 2),
			Color = LAVE,
			Material = Enum.Material.Neon,
			CanCollide = false,
			CanQuery = false,
			CastShadow = false,
		})
		if mare then
			table.insert(coulees, mare)
			table.insert(lueursPied, Outils.lumiere(mare, { Range = 12, Brightness = 1.2, Color = LAVE }))
		end
	end

	-- ===== rochers ronds au pied du volcan =====
	local NB_ROCHERS = reglage("rochers", 14)
	for n = 1, NB_ROCHERS do
		local a = (n - 1) / NB_ROCHERS * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
		if not presDUneCoulee(a, math.rad(10)) then
			local d = rng:NextNumber(2, 3.4)
			local rr = math.min(RAYON_BAS + 1, RAYON_MAX - 0.3 - d / 2)
			local pos = direction(a) * rr
			part(Outils.boule, rochers, {
				Name = "Rocher",
				Size = Vector3.new(d, d, d),
				CFrame = CFrame.new(CX + pos.X, d * 0.35, CZ + pos.Z), -- à moitié enfoncé dans le sol
				Color = PIERRE:Lerp(PIERRE_CLAIRE, rng:NextNumber(0, 0.4)),
			})
		end
	end

	-- ===== la bouche : fumée, lueur, projections et titre flottant =====
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

	local fumee, lumiere, projections, alerte
	if bouche then
		pcall(function()
			fumee = Instance.new("Smoke")
			fumee.Name = "Fumee"
			fumee.Color = FUMEE_CALME
			fumee.Opacity = 0.2
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
				NumberSequenceKeypoint.new(0, 1.8),
				NumberSequenceKeypoint.new(1, 0.5),
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

		-- titre géant flottant au-dessus du cratère (grammaire des lieux : texte cerné, dégradé orange)
		if Style and type(Style.etiquette) == "function" then
			pcall(function()
				local _, textes = Style.etiquette(bouche, {
					{ texte = "", nom = "Alerte", couleur = ALERTE, taille = 0.7 },
					{ texte = "🌋 VOLCAN", nom = "Titre", couleur = BLANC, titre = true, contour = 4 },
				}, {
					Name = "EtiquetteVolcan",
					largeur = 34,
					hauteurLigne = 7,
					StudsOffset = Vector3.new(0, 16, 0),
					MaxDistance = 500,
					AlwaysOnTop = false,
				})
				if textes then
					alerte = textes[1]
					if textes[2] and type(Style.degrade) == "function" then
						Style.degrade(textes[2], TITRE_HAUT, TITRE_BAS)
					end
					if textes[1] and type(Style.contour) == "function" then
						local c = textes[1]:FindFirstChild("Contour")
						if c then
							c.Thickness = 4
							c.Color = CONTOUR
						end
					end
				end
			end)
		end
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
					fumee.Color = FUMEE_ERUPTION
					fumee.Opacity = 0.5
					fumee.RiseVelocity = 14
					fumee.Size = 22
				else
					fumee.Color = FUMEE_CALME
					fumee.Opacity = 0.2
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
			if alerte then
				if enEruption then
					alerte.Text = "⚠️ ÉRUPTION ! ⚠️"
				else
					alerte.Text = ""
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
