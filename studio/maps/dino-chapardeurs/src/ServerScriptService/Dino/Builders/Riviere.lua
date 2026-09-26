-- Constructeur Riviere : rivière d'ouest en est au sud de la Place.
-- Lit sombre, eau Glass translucide teinte gemme, berges de sable et de galets, rochers,
-- nénuphars qui flottent, deux petits ponts de bois décoratifs et une cascade qui sort des falaises de l'est.
-- Emprise (CONTRAT §10) : bande z 131..145 sur x -166..166 (cascade comprise, x 160..166).
local M = {}

local BUDGET = 300 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier

	-- réglages facultatifs (Equilibrage.riviere), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.riviere) == "table" then
		reglages = ctx.Equilibrage.riviere
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	-- ===== géométrie de la bande =====
	local zCentre = 138
	local largeur = 14
	if Plan and type(Plan.riviere) == "table" then
		if type(Plan.riviere.z) == "number" then
			zCentre = Plan.riviere.z
		end
		if type(Plan.riviere.largeur) == "number" then
			largeur = Plan.riviere.largeur
		end
	end
	-- on reste dans l'emprise du contrat quoi qu'il arrive
	local Z_MIN = math.max(131, zCentre - largeur / 2)
	local Z_MAX = math.min(145, zCentre + largeur / 2)
	if Z_MAX - Z_MIN < 6 then
		Z_MIN = 131
		Z_MAX = 145
	end
	zCentre = (Z_MIN + Z_MAX) / 2
	local X_MIN = -166
	local X_MAX = 166

	local LARGEUR_BERGE = 1.6
	local zLitMin = Z_MIN + LARGEUR_BERGE
	local zLitMax = Z_MAX - LARGEUR_BERGE
	local largeurLit = zLitMax - zLitMin

	local HAUT_LIT = 0.12       -- dessus du lit sombre
	local HAUT_EAU = 0.45       -- dessus de l'eau
	local HAUT_BERGE = 0.55     -- dessus des berges
	local X_MUR_CASCADE = 164.5 -- face ouest de la roche de la cascade
	local HAUT_CASCADE = math.min(24, math.max(12, reglage("hauteurCascade", 20)))

	local X_PONTS = { reglage("pontOuest", -92), reglage("pontEst", 92) }
	local LARGEUR_PONT = 6

	local rng = Outils.aleatoire(reglage("graine", 1138))

	-- ===== couleurs =====
	local LIT = Charte.ombre(Charte.nuit)
	local EAU = Charte.gemme:Lerp(Charte.nuit, 0.3)
	local EAU_CLAIRE = Charte.lumiere(Charte.gemme)
	local SABLE_MOUILLE = Charte.ombre(Charte.sable)
	local GALETS = Charte.lumiere(Charte.pierre)
	local PIERRE = Charte.pierre
	local PIERRE_OMBRE = Charte.ombre(Charte.pierre)
	local BOIS = Charte.bois
	local BOIS_OMBRE = Charte.ombre(Charte.bois)
	local FEUILLE = Charte.herbe
	local FEUILLE_OMBRE = Charte.jungle
	local FLEURS = { Charte.raretes.Mythique, Charte.creme, Charte.violet, Charte.dore }

	-- ===== création sous budget =====
	local compte = 0
	local function reste()
		return BUDGET - compte
	end
	local function creer(fabrique, parent, props)
		if compte >= BUDGET then
			return nil
		end
		local ok, part = pcall(fabrique, parent, props)
		if not ok or not part then
			return nil
		end
		compte = compte + 1
		return part
	end
	local function bloc(parent, props) return creer(Outils.bloc, parent, props) end
	local function boule(parent, props) return creer(Outils.boule, parent, props) end
	local function cylindre(parent, props) return creer(Outils.cylindre, parent, props) end

	-- décor pur : ni collision, ni requête, ni contact
	local function decor(props)
		props.CanCollide = false
		props.CanQuery = false
		props.CanTouch = false
		return props
	end

	-- les zones à ne pas encombrer (ponts, cascade) pour les petits objets
	local function surPont(x, marge)
		for _, xp in ipairs(X_PONTS) do
			if math.abs(x - xp) <= LARGEUR_PONT / 2 + marge then
				return true
			end
		end
		return false
	end
	local occupes = {}
	local function libre(x, z, rayon)
		if surPont(x, rayon + 0.5) then
			return false
		end
		if x > 154 then
			return false
		end
		for _, o in ipairs(occupes) do
			local dx, dz = x - o[1], z - o[2]
			local r = rayon + o[3]
			if dx * dx + dz * dz < r * r then
				return false
			end
		end
		return true
	end
	local function occuper(x, z, rayon)
		table.insert(occupes, { x, z, rayon })
	end

	local dLit = Outils.dossier(dossier, "Lit")
	local dEau = Outils.dossier(dossier, "Eau")
	local dBerges = Outils.dossier(dossier, "Berges")
	local dRochers = Outils.dossier(dossier, "Rochers")
	local dNenuphars = Outils.dossier(dossier, "Nenuphars")
	local dPonts = Outils.dossier(dossier, "Ponts")

	local SEGMENTS = math.max(6, math.min(16, math.floor(reglage("segments", 14))))
	local longueurSeg = (X_MUR_CASCADE - X_MIN) / SEGMENTS

	-- ===== 1. lit et eau =====
	local function construireLitEtEau()
		for i = 1, SEGMENTS do
			local x0 = X_MIN + (i - 1) * longueurSeg
			local xc = x0 + longueurSeg / 2
			-- le lit : une dalle sombre posée sur le sol
			bloc(dLit, {
				Name = "Lit" .. i,
				Size = Vector3.new(longueurSeg, HAUT_LIT, largeurLit),
				CFrame = CFrame.new(xc, HAUT_LIT / 2, zCentre),
				Color = LIT,
				CanTouch = false,
			})
			-- l'eau : translucide, on la traverse
			local eau = bloc(dEau, decor({
				Name = "Eau" .. i,
				Size = Vector3.new(longueurSeg, HAUT_EAU - HAUT_LIT, largeurLit),
				CFrame = CFrame.new(xc, (HAUT_LIT + HAUT_EAU) / 2, zCentre),
				Color = EAU,
				Material = Enum.Material.Glass,
				Transparency = 0.35,
				Reflectance = 0.12,
				CastShadow = false,
			}))
			if eau then
				eau:SetAttribute("Eau", true)
			end
		end
	end

	-- ===== 2. berges : sable mouillé et bancs de galets en alternance =====
	local function construireBerges()
		for i = 1, SEGMENTS do
			local x0 = X_MIN + (i - 1) * longueurSeg
			local xc = x0 + longueurSeg / 2
			for cote = 1, 2 do
				local zc = Z_MIN + LARGEUR_BERGE / 2
				if cote == 2 then
					zc = Z_MAX - LARGEUR_BERGE / 2
				end
				local galets = ((i + cote) % 2) == 0
				local couleur = SABLE_MOUILLE
				local nom = "Sable"
				if galets then
					couleur = GALETS
					nom = "Galets"
				end
				bloc(dBerges, {
					Name = nom .. i .. "_" .. cote,
					Size = Vector3.new(longueurSeg, HAUT_BERGE, LARGEUR_BERGE),
					CFrame = CFrame.new(xc, HAUT_BERGE / 2, zc),
					Color = couleur,
					CanTouch = false,
				})
			end
		end
	end

	-- petits galets semés sur les berges (en dernier, selon le budget restant)
	local function semerGalets(nombre)
		for _ = 1, nombre do
			if reste() <= 0 then
				return
			end
			local x = rng:NextNumber(X_MIN + 1, 160)
			if not surPont(x, 0.5) then
				local cote = rng:NextInteger(1, 2)
				local d = rng:NextNumber(0.35, 0.8)
				local z = rng:NextNumber(Z_MIN + d / 2 + 0.1, Z_MIN + LARGEUR_BERGE - d / 2)
				if cote == 2 then
					z = rng:NextNumber(Z_MAX - LARGEUR_BERGE + d / 2, Z_MAX - d / 2 - 0.1)
				end
				local teintes = { PIERRE, GALETS, PIERRE_OMBRE, Charte.creme }
				boule(dBerges, decor({
					Name = "Galet",
					Size = Vector3.new(d, d, d),
					CFrame = CFrame.new(x, HAUT_BERGE + d * 0.15, z),
					Color = teintes[rng:NextInteger(1, #teintes)],
				}))
			end
		end
	end

	-- ===== 3. ponts de bois =====
	local function construirePont(index, xp)
		local m = Outils.modele(dPonts, "Pont" .. index)
		local nPlanches = 7
		local pas = (Z_MAX - Z_MIN) / nPlanches
		local demi = LARGEUR_PONT / 2
		local hauteurMilieu = 0
		for k = 1, nPlanches do
			local zk = Z_MIN + (k - 0.5) * pas
			local dessus = HAUT_BERGE + 1.4 * math.sin(math.pi * (k - 0.5) / nPlanches)
			if dessus > hauteurMilieu then
				hauteurMilieu = dessus
			end
			local couleur = BOIS
			if k % 2 == 0 then
				couleur = Charte.lumiere(BOIS)
			end
			bloc(m, {
				Name = "Planche" .. k,
				Size = Vector3.new(LARGEUR_PONT, 0.5, pas),
				CFrame = CFrame.new(xp, dessus - 0.25, zk),
				Color = couleur,
			})
		end
		-- poteaux aux quatre coins et au milieu, puis rambardes
		local hautRambarde = hauteurMilieu + 1.6
		local zPoteaux = { Z_MIN + 0.4, Z_MAX - 0.4 }
		for _, sx in ipairs({ -1, 1 }) do
			local xPoteau = xp + sx * (demi - 0.25)
			for _, zq in ipairs(zPoteaux) do
				local h = hautRambarde - HAUT_BERGE + 0.3
				bloc(m, {
					Name = "Poteau",
					Size = Vector3.new(0.5, h, 0.5),
					CFrame = CFrame.new(xPoteau, HAUT_BERGE + h / 2, zq),
					Color = BOIS_OMBRE,
				})
			end
			local hMil = hautRambarde - hauteurMilieu + 0.3
			bloc(m, {
				Name = "PoteauMilieu",
				Size = Vector3.new(0.5, hMil, 0.5),
				CFrame = CFrame.new(xPoteau, hauteurMilieu + hMil / 2, zCentre),
				Color = BOIS_OMBRE,
			})
			bloc(m, {
				Name = "Rambarde",
				Size = Vector3.new(0.4, 0.4, Z_MAX - Z_MIN - 0.4),
				CFrame = CFrame.new(xPoteau, hautRambarde, zCentre),
				Color = BOIS,
			})
			-- pilotis dans l'eau, sous le milieu du pont
			local hPil = hauteurMilieu - 0.5
			bloc(m, {
				Name = "Pilotis",
				Size = Vector3.new(0.7, hPil, 0.7),
				CFrame = CFrame.new(xp + sx * (demi - 1), hPil / 2, zCentre),
				Color = BOIS_OMBRE,
				CanTouch = false,
			})
		end
	end

	local function construirePonts()
		for index, xp in ipairs(X_PONTS) do
			if xp - LARGEUR_PONT / 2 > X_MIN + 2 and xp + LARGEUR_PONT / 2 < 154 then
				construirePont(index, xp)
			end
		end
	end

	-- ===== 4. cascade =====
	local function construireCascade()
		local m = Outils.modele(dossier, "Cascade")
		local largeurChute = math.min(6, largeurLit - 2)
		-- la roche adossée à la falaise
		local epaisseur = X_MAX - X_MUR_CASCADE
		bloc(m, {
			Name = "Roche",
			Size = Vector3.new(epaisseur, HAUT_CASCADE + 2, Z_MAX - Z_MIN),
			CFrame = CFrame.new(X_MUR_CASCADE + epaisseur / 2, (HAUT_CASCADE + 2) / 2, zCentre),
			Color = PIERRE,
		})
		-- rebord d'où tombe l'eau
		local xLevre0 = 161
		bloc(m, {
			Name = "Levre",
			Size = Vector3.new(X_MUR_CASCADE - xLevre0, 1.4, largeurChute + 2),
			CFrame = CFrame.new((xLevre0 + X_MUR_CASCADE) / 2, HAUT_CASCADE - 0.7, zCentre),
			Color = PIERRE_OMBRE,
		})
		bloc(m, decor({
			Name = "Mousse",
			Size = Vector3.new(epaisseur, 0.4, Z_MAX - Z_MIN),
			CFrame = CFrame.new(X_MUR_CASCADE + epaisseur / 2, HAUT_CASCADE + 2.2, zCentre),
			Color = FEUILLE_OMBRE,
		}))
		-- blocs de roche qui encadrent la chute
		for _, sz in ipairs({ -1, 1 }) do
			local zb = zCentre + sz * (largeurChute / 2 + 1.6)
			local h = HAUT_CASCADE * rng:NextNumber(0.45, 0.7)
			bloc(m, {
				Name = "Pilier",
				Size = Vector3.new(3, h, 2.4),
				CFrame = CFrame.new(X_MUR_CASCADE - 1.5, h / 2, zb),
				Color = PIERRE_OMBRE,
			})
			bloc(m, {
				Name = "Eboulis",
				Size = Vector3.new(2.2, 1.6, 2),
				CFrame = CFrame.new(X_MUR_CASCADE - 4, 0.8, zb) * CFrame.Angles(0, math.rad(rng:NextNumber(-30, 30)), 0),
				Color = PIERRE,
			})
		end
		-- l'eau qui coule sur le rebord puis tombe
		bloc(m, decor({
			Name = "EauRebord",
			Size = Vector3.new(X_MUR_CASCADE - xLevre0, 0.3, largeurChute),
			CFrame = CFrame.new((xLevre0 + X_MUR_CASCADE) / 2, HAUT_CASCADE + 0.15, zCentre),
			Color = EAU_CLAIRE,
			Material = Enum.Material.Glass,
			Transparency = 0.3,
			CastShadow = false,
		}))
		local hChute = HAUT_CASCADE - HAUT_EAU + 0.3
		local xChute = xLevre0 + 0.4
		bloc(m, decor({
			Name = "Chute",
			Size = Vector3.new(0.8, hChute, largeurChute),
			CFrame = CFrame.new(xChute, HAUT_EAU + hChute / 2 - 0.1, zCentre),
			Color = EAU,
			Material = Enum.Material.Glass,
			Transparency = 0.3,
			Reflectance = 0.1,
			CastShadow = false,
		}))
		local reflet = bloc(m, decor({
			Name = "RefletChute",
			Size = Vector3.new(0.3, hChute, largeurChute * 0.6),
			CFrame = CFrame.new(xChute - 0.5, HAUT_EAU + hChute / 2 - 0.1, zCentre),
			Color = EAU_CLAIRE,
			Material = Enum.Material.Neon,
			Transparency = 0.55,
			CastShadow = false,
		}))
		if reflet then
			Outils.animer(reflet, "pulse", 3)
		end
		-- écume au pied de la chute
		local ecume = bloc(m, decor({
			Name = "Ecume",
			Size = Vector3.new(3, 0.2, largeurChute + 1),
			CFrame = CFrame.new(xChute - 1.2, HAUT_EAU + 0.05, zCentre),
			Color = Charte.creme,
			Transparency = 0.25,
			CastShadow = false,
		}))
		if ecume then
			Outils.animer(ecume, "pulse", 2)
			pcall(function()
				local p = Instance.new("ParticleEmitter")
				p.Name = "Ecume"
				p.Texture = "rbxasset://textures/particles/smoke_main.dds"
				p.Color = ColorSequence.new(Charte.creme)
				p.LightEmission = 0.3
				p.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1.2),
					NumberSequenceKeypoint.new(1, 3),
				})
				p.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.3),
					NumberSequenceKeypoint.new(1, 1),
				})
				p.Lifetime = NumberRange.new(0.8, 1.6)
				p.Rate = 30
				p.Speed = NumberRange.new(3, 6)
				p.SpreadAngle = Vector2.new(35, 60)
				p.Acceleration = Vector3.new(0, -6, 0)
				p.EmissionDirection = Enum.NormalId.Top
				p.Parent = ecume
			end)
			pcall(function()
				local p = Instance.new("ParticleEmitter")
				p.Name = "Embruns"
				p.Texture = "rbxasset://textures/particles/smoke_main.dds"
				p.Color = ColorSequence.new(EAU_CLAIRE)
				p.LightEmission = 0.2
				p.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 2),
					NumberSequenceKeypoint.new(1, 5),
				})
				p.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.6),
					NumberSequenceKeypoint.new(1, 1),
				})
				p.Lifetime = NumberRange.new(1.5, 2.5)
				p.Rate = 8
				p.Speed = NumberRange.new(1, 2.5)
				p.SpreadAngle = Vector2.new(60, 60)
				p.EmissionDirection = Enum.NormalId.Top
				p.Parent = ecume
			end)
			pcall(function()
				Outils.lumiere(ecume, { Range = 14, Brightness = 0.8, Color = EAU_CLAIRE })
			end)
		end
		-- gouttes qui jaillissent du haut de la chute
		local levreEau = m:FindFirstChild("EauRebord")
		if levreEau then
			pcall(function()
				local p = Instance.new("ParticleEmitter")
				p.Name = "Gouttes"
				p.Color = ColorSequence.new(EAU_CLAIRE)
				p.LightEmission = 0.4
				p.Size = NumberSequence.new(0.25)
				p.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1),
				})
				p.Lifetime = NumberRange.new(1, 1.6)
				p.Rate = 12
				p.Speed = NumberRange.new(1, 3)
				p.SpreadAngle = Vector2.new(20, 40)
				p.Acceleration = Vector3.new(0, -30, 0)
				p.EmissionDirection = Enum.NormalId.Left
				p.Parent = levreEau
			end)
		end
		occuper(xChute - 2, zCentre, 5)
	end

	-- ===== 5. rochers =====
	local function rocher(x, z, taille, dansEau)
		local base = HAUT_LIT + 0.1
		if not dansEau then
			base = HAUT_BERGE - 0.2
		end
		local h = taille * rng:NextNumber(0.55, 0.85)
		local r = bloc(dRochers, {
			Name = "Rocher",
			Size = Vector3.new(taille, h, taille * rng:NextNumber(0.7, 1)),
			CFrame = CFrame.new(x, base + h / 2, z) * CFrame.Angles(math.rad(rng:NextNumber(-8, 8)), math.rad(rng:NextNumber(0, 90)), math.rad(rng:NextNumber(-8, 8))),
			Color = PIERRE,
			CanTouch = false,
		})
		if r and taille > 1.8 and reste() > 40 then
			local t2 = taille * 0.5
			bloc(dRochers, {
				Name = "Caillou",
				Size = Vector3.new(t2, t2 * 0.6, t2),
				CFrame = CFrame.new(x + rng:NextNumber(-0.3, 0.3), base + h + t2 * 0.25, z + rng:NextNumber(-0.3, 0.3)) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 90)), 0),
				Color = PIERRE_OMBRE,
				CanTouch = false,
			})
		end
		occuper(x, z, taille * 0.75)
	end

	local function construireRochers()
		-- la source à l'ouest : quelques gros rochers où la rivière sort de la falaise
		rocher(X_MIN + 1.6, zLitMin + 1.5, 2.4, true)
		rocher(X_MIN + 2.2, zLitMax - 1.4, 2.2, true)
		rocher(X_MIN + 4.5, zCentre + 0.5, 1.6, true)
		local n = math.max(0, math.floor(reglage("rochers", 18)))
		local essais = 0
		local poses = 0
		while poses < n and essais < n * 6 and reste() > 30 do
			essais = essais + 1
			local taille = rng:NextNumber(1.2, 2.4)
			local x = rng:NextNumber(X_MIN + 8, 152)
			local dansEau = rng:NextNumber() < 0.6
			local z
			local demiDiag = taille * 0.75
			if dansEau then
				z = rng:NextNumber(zLitMin + demiDiag, zLitMax - demiDiag)
			else
				-- à cheval sur la berge, sans sortir de la bande
				if rng:NextInteger(1, 2) == 1 then
					z = Z_MIN + demiDiag + 0.1
				else
					z = Z_MAX - demiDiag - 0.1
				end
			end
			if libre(x, z, demiDiag) then
				rocher(x, z, taille, dansEau)
				poses = poses + 1
			end
		end
	end

	-- ===== 6. nénuphars =====
	local function construireNenuphars()
		local n = math.max(0, math.floor(reglage("nenuphars", 16)))
		local essais = 0
		local poses = 0
		while poses < n and essais < n * 8 and reste() > 22 do
			essais = essais + 1
			local d = rng:NextNumber(1.6, 2.6)
			local x = rng:NextNumber(X_MIN + 8, 150)
			local z = rng:NextNumber(zLitMin + d / 2 + 0.2, zLitMax - d / 2 - 0.2)
			if libre(x, z, d / 2 + 0.2) then
				local m = Outils.modele(dNenuphars, "Nenuphar")
				local feuille = cylindre(m, decor({
					Name = "Feuille",
					Size = Vector3.new(0.12, d, d),
					CFrame = CFrame.new(x, HAUT_EAU + 0.08, z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), math.rad(90)),
					Color = FEUILLE,
				}))
				if feuille then
					m.PrimaryPart = feuille
					if rng:NextNumber() < 0.5 then
						boule(m, decor({
							Name = "Fleur",
							Size = Vector3.new(0.6, 0.45, 0.6),
							CFrame = CFrame.new(x + rng:NextNumber(-0.3, 0.3), HAUT_EAU + 0.3, z + rng:NextNumber(-0.3, 0.3)),
							Color = FLEURS[rng:NextInteger(1, #FLEURS)],
						}))
					else
						cylindre(m, decor({
							Name = "Bord",
							Size = Vector3.new(0.14, d * 0.45, d * 0.45),
							CFrame = CFrame.new(x + d * 0.2, HAUT_EAU + 0.1, z) * CFrame.Angles(0, 0, math.rad(90)),
							Color = FEUILLE_OMBRE,
						}))
					end
					Outils.animer(m, "flotte", rng:NextNumber(0.6, 1.1))
					occuper(x, z, d / 2)
					poses = poses + 1
				else
					m:Destroy()
				end
			end
		end
	end

	-- ===== 7. reflets de courant sur l'eau =====
	local function construireReflets(n)
		for _ = 1, n do
			if reste() <= 0 then
				return
			end
			local long = rng:NextNumber(2.5, 6)
			local x = rng:NextNumber(X_MIN + 4, 150)
			local z = rng:NextNumber(zLitMin + 0.8, zLitMax - 0.8)
			if not surPont(x, long / 2) then
				local r = bloc(dEau, decor({
					Name = "Reflet",
					Size = Vector3.new(long, 0.05, 0.25),
					CFrame = CFrame.new(x, HAUT_EAU + 0.03, z),
					Color = EAU_CLAIRE,
					Material = Enum.Material.Neon,
					Transparency = 0.45,
					CastShadow = false,
				}))
				if r then
					Outils.animer(r, "pulse", rng:NextNumber(1, 2))
				end
			end
		end
	end

	-- ===== ordre : l'essentiel d'abord, le décor fin selon le budget restant =====
	local etapes = {
		{ "lit et eau", construireLitEtEau },
		{ "berges", construireBerges },
		{ "ponts", construirePonts },
		{ "cascade", construireCascade },
		{ "rochers", construireRochers },
		{ "nenuphars", construireNenuphars },
		{ "reflets", function() construireReflets(math.min(14, math.max(0, reste() - 40))) end },
		{ "galets", function() semerGalets(math.min(70, math.max(0, reste() - 2))) end },
	}
	for _, etape in ipairs(etapes) do
		local ok, err = pcall(etape[2])
		if not ok then
			warn("[Dino] Riviere, " .. etape[1] .. " : " .. tostring(err))
		end
	end
	dossier:SetAttribute("Parts", compte)
end

return M
