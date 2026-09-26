-- Constructeur Autel : l'Autel des Renaissances, à l'est de la Place.
-- Une dalle ronde cerclée de Neon violet, un autel de pierre ancienne en trois gradins,
-- un œuf fossile doré géant qui flotte et pulse au-dessus, six colonnes gravées de runes,
-- deux braseros et un fronton « RENAISSANCE » tourné vers la Place (-X).
-- L'invite « Renaissance » est posée sans rappel : le client ouvre le panneau (Client.client.lua)
-- et Systemes/Renaissance traite la demande réseau.
-- Emprise (CONTRAT §10) : disque r11 autour de Plan.autel.centre.
local M = {}

local BUDGET = 180 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.autel
local DEFAUTS = {
	rayon = 11,              -- rayon de la dalle (emprise)
	hauteurGradin = 0.9,     -- hauteur d'une marche de l'autel
	hauteurOeuf = 10.3,      -- hauteur du centre de l'œuf
	vitesseFlotte = 1.2,     -- vitesse du va-et-vient de l'œuf
	vitessePulse = 2,        -- vitesse de pulsation des Neon
	distanceInvite = 12,     -- portée de l'invite « Renaissance »
	graine = 1104,           -- graine du hasard (pierres éboulées)
}

local function lireReglages(ctx)
	local source = nil
	if ctx.Equilibrage and type(ctx.Equilibrage.autel) == "table" then
		source = ctx.Equilibrage.autel
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
	-- l'emprise ne dépasse jamais Plan.autel.rayon
	if ctx.Plan and ctx.Plan.autel and type(ctx.Plan.autel.rayon) == "number" then
		r.rayon = math.min(r.rayon, ctx.Plan.autel.rayon)
	end
	return r
end

-- texte du bonus de revenu d'une renaissance, lu dans Equilibrage (ou "" si indisponible)
local function texteBonus(Equilibrage)
	if not Equilibrage or type(Equilibrage.multiplicateurRenaissance) ~= "function" then
		return ""
	end
	local ok, a, b = pcall(function()
		return Equilibrage.multiplicateurRenaissance(0), Equilibrage.multiplicateurRenaissance(1)
	end)
	if not ok or type(a) ~= "number" or type(b) ~= "number" or b <= a then
		return ""
	end
	local pourcent = math.floor((b / a - 1) * 100 + 0.5)
	return "+" .. pourcent .. " % de revenus"
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	if not (Charte and Outils and Plan and ctx.dossier) then
		return
	end
	if not (Plan.autel and typeof(Plan.autel.centre) == "Vector3") then
		return
	end

	local R = lireReglages(ctx)
	local C = Vector3.new(Plan.autel.centre.X, 0, Plan.autel.centre.Z)
	-- repère local : -Z local = vers la Place (-X monde), Y vers le haut
	local repere = CFrame.lookAt(C, C + Vector3.new(-1, 0, 0))

	local PIERRE = Charte.pierre
	local PIERRE_OMBRE = Charte.ombre(Charte.pierre)
	local PIERRE_CLAIRE = Charte.lumiere(Charte.pierre)
	local NEON = Enum.Material.Neon

	local modele = Outils.modele(ctx.dossier, "AutelDesRenaissances")

	-- ===== création avec respect du budget =====
	local compte = 0
	local function creer(fabrique, parent, props)
		if compte >= BUDGET then
			return nil
		end
		local ok, part = pcall(fabrique, parent, props)
		if ok and part then
			compte = compte + 1
			return part
		end
		return nil
	end
	local function bloc(parent, props) return creer(Outils.bloc, parent, props) end
	local function cylindre(parent, props) return creer(Outils.cylindre, parent, props) end
	local function boule(parent, props) return creer(Outils.boule, parent, props) end

	-- CFrame dans le repère de l'autel
	local function loc(x, y, z)
		return repere * CFrame.new(x, y, z)
	end
	-- cylindre vertical (l'axe d'un cylindre Roblox est X)
	local function vertical(cf)
		return cf * CFrame.Angles(0, 0, math.rad(90))
	end

	-- ===== 1. dalle ronde cerclée de Neon =====
	pcall(function()
		local diametre = R.rayon * 2
		cylindre(modele, {
			Name = "Cercle",
			Size = Vector3.new(0.24, diametre, diametre),
			CFrame = vertical(loc(0, 0.12, 0)),
			Color = Charte.violet,
			Material = NEON,
		})
		cylindre(modele, {
			Name = "Dalle",
			Size = Vector3.new(0.3, diametre - 1, diametre - 1),
			CFrame = vertical(loc(0, 0.15, 0)),
			Color = PIERRE_OMBRE,
		})
		-- runes gravées dans la dalle, sur le chemin qui vient de la Place
		local runes = Outils.modele(modele, "RunesDalle")
		for i = 1, 3 do
			local z = -6.2 - (i - 1) * 1.4
			local couleur = Charte.gemme
			if i == 2 then
				couleur = Charte.violet
			end
			bloc(runes, {
				Name = "Rune" .. i,
				Size = Vector3.new(0.8, 0.06, 0.8),
				CFrame = loc(0, 0.32, z) * CFrame.Angles(0, math.rad(45), 0),
				Color = couleur,
				Material = NEON,
				CanCollide = false,
			})
		end
		for _, cote in ipairs({ -1, 1 }) do
			for i = 1, 2 do
				bloc(runes, {
					Name = "Trait",
					Size = Vector3.new(0.2, 0.06, 1.6),
					CFrame = loc(cote * 1.4, 0.32, -6.6 - (i - 1) * 2),
					Color = Charte.violet,
					Material = NEON,
					CanCollide = false,
				})
			end
		end
		Outils.animer(runes, "pulse", R.vitessePulse * 0.5)
	end)

	-- ===== 2. autel en escalier de pierre ancienne =====
	local hautAutel = 0.3
	local partAutel = nil
	pcall(function()
		local cotes = { 12, 9, 6 }
		local couleurs = { PIERRE_OMBRE, PIERRE, PIERRE_CLAIRE }
		for i, cote in ipairs(cotes) do
			local y = hautAutel + R.hauteurGradin / 2
			bloc(modele, {
				Name = "Gradin" .. i,
				Size = Vector3.new(cote, R.hauteurGradin, cote),
				CFrame = loc(0, y, 0),
				Color = couleurs[i],
			})
			hautAutel = hautAutel + R.hauteurGradin
			-- liseré doré sur le nez de chaque marche, côté Place
			bloc(modele, {
				Name = "Nez" .. i,
				Size = Vector3.new(cote - 0.4, 0.12, 0.3),
				CFrame = loc(0, hautAutel + 0.06, -cote / 2 + 0.15),
				Color = Charte.dore,
				CanCollide = false,
			})
		end

		-- pierres usées sur les angles des gradins (aspect ancien)
		local hasard = Outils.aleatoire(R.graine)
		for i = 1, 2 do
			local cote = cotes[i]
			local y = 0.3 + (i - 0.5) * R.hauteurGradin
			for _, coin in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
				local t = hasard:NextNumber(0.5, 0.8)
				bloc(modele, {
					Name = "PierreUsee",
					Size = Vector3.new(t, R.hauteurGradin + 0.1, t),
					CFrame = loc(coin[1] * (cote / 2 - t / 2 + 0.05), y + 0.05, coin[2] * (cote / 2 - t / 2 + 0.05)),
					Color = Charte.ombre(PIERRE_OMBRE),
				})
			end
		end

		-- la table de l'autel, qui porte l'invite
		partAutel = bloc(modele, {
			Name = "Autel",
			Size = Vector3.new(4.4, 1.6, 4.4),
			CFrame = loc(0, hautAutel + 0.8, 0),
			Color = PIERRE,
		})
		bloc(modele, {
			Name = "Plateau",
			Size = Vector3.new(4.8, 0.2, 4.8),
			CFrame = loc(0, hautAutel + 1.7, 0),
			Color = Charte.dore,
		})
		local socle = cylindre(modele, {
			Name = "Sceau",
			Size = Vector3.new(0.15, 3, 3),
			CFrame = vertical(loc(0, hautAutel + 1.875, 0)),
			Color = Charte.violet,
			Material = NEON,
			CanCollide = false,
		})
		if socle then
			Outils.animer(socle, "pulse", R.vitessePulse)
			Outils.lumiere(socle, { Range = 14, Brightness = 1.5, Color = Charte.violet })
		end
		-- griffes fossiles qui montent vers l'œuf
		for i = 0, 3 do
			local a = math.rad(45 + i * 90)
			bloc(modele, {
				Name = "Griffe",
				Size = Vector3.new(0.4, 2, 0.4),
				CFrame = loc(math.cos(a) * 1.9, hautAutel + 2.6, math.sin(a) * 1.9)
					* CFrame.Angles(0, -a, 0) * CFrame.Angles(0, 0, math.rad(20)),
				Color = Charte.creme,
				CanCollide = false,
			})
		end
		if partAutel then
			-- bonus affiché sur la face de l'autel tournée vers la Place
			local bonus = texteBonus(ctx.Equilibrage)
			if bonus ~= "" then
				Outils.texte(partAutel, "Front", bonus, { couleur = Charte.dore, pixelsParStud = 30 })
			end
		end
	end)

	-- ===== 3. l'œuf fossile doré, qui flotte et pulse =====
	pcall(function()
		local oeuf = Outils.modele(modele, "OeufFossile")
		local yc = R.hauteurOeuf
		local bas = boule(oeuf, {
			Name = "Coque",
			Size = Vector3.new(5, 5, 5),
			CFrame = loc(0, yc - 1.3, 0),
			Color = Charte.dore,
			Reflectance = 0.15,
			CanCollide = false,
		})
		local milieu = boule(oeuf, {
			Name = "Ventre",
			Size = Vector3.new(4.4, 4.4, 4.4),
			CFrame = loc(0, yc, 0),
			Color = Charte.dore,
			Reflectance = 0.15,
			CanCollide = false,
		})
		boule(oeuf, {
			Name = "Pointe",
			Size = Vector3.new(3.2, 3.2, 3.2),
			CFrame = loc(0, yc + 1.4, 0),
			Color = Charte.lumiere(Charte.dore),
			Reflectance = 0.15,
			CanCollide = false,
		})
		-- fissures lumineuses du fossile
		local fissures = Outils.modele(oeuf, "Fissures")
		for i = 0, 5 do
			local a = math.rad(i * 60 + 15)
			local dy = 0.35
			if i % 2 == 1 then
				dy = -0.25
			end
			local dir = Vector3.new(math.cos(a), dy, math.sin(a)).Unit
			local pos = (repere * CFrame.new(dir * 2.12)).Position + Vector3.new(0, yc, 0)
			local sens = 1
			if i % 2 == 1 then
				sens = -1
			end
			local couleur = Charte.gemme
			if i % 3 == 0 then
				couleur = Charte.violet
			end
			bloc(fissures, {
				Name = "Fissure",
				Size = Vector3.new(0.22, 1.5, 0.2),
				CFrame = CFrame.lookAt(pos, pos + (pos - Vector3.new(C.X, yc, C.Z)))
					* CFrame.Angles(0, 0, math.rad(25 * sens)),
				Color = couleur,
				Material = NEON,
				CanCollide = false,
			})
		end
		Outils.animer(fissures, "pulse", R.vitessePulse)

		-- halo doré autour de l'œuf
		local halo = boule(oeuf, {
			Name = "Halo",
			Size = Vector3.new(7, 7, 7),
			CFrame = loc(0, yc, 0),
			Color = Charte.lumiere(Charte.dore),
			Material = NEON,
			Transparency = 0.82,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
		})
		if halo then
			Outils.animer(halo, "pulse", R.vitessePulse)
			pcall(function()
				local etincelles = Instance.new("ParticleEmitter")
				etincelles.Name = "Etincelles"
				etincelles.Color = ColorSequence.new(Charte.dore, Charte.violet)
				etincelles.LightEmission = 1
				etincelles.Size = NumberSequence.new(0.35, 0)
				etincelles.Transparency = NumberSequence.new(0.1, 1)
				etincelles.Lifetime = NumberRange.new(1.5, 2.5)
				etincelles.Rate = 8
				etincelles.Speed = NumberRange.new(0.8, 1.6)
				etincelles.SpreadAngle = Vector2.new(180, 180)
				etincelles.Parent = halo
			end)
		end
		if milieu then
			Outils.lumiere(milieu, { Range = 18, Brightness = 2, Color = Charte.dore })
			oeuf.PrimaryPart = milieu
		elseif bas then
			oeuf.PrimaryPart = bas
		end
		Outils.animer(oeuf, "flotte", R.vitesseFlotte)
	end)

	-- ===== 4. colonnes gravées de runes =====
	-- { x, z, hauteur du fût, porte le fronton }
	local COLONNES = {
		{ -5, 7.8, 12.2, true },
		{ 5, 7.8, 12.2, true },
		{ -8.6, 1.5, 8, false },
		{ 8.6, 1.5, 8, false },
		{ -7.8, -4.6, 8, false },
		{ 7.8, -4.6, 8, false },
	}
	local hautFronton = 0
	for n, c in ipairs(COLONNES) do
		pcall(function()
			local colonne = Outils.modele(modele, "Colonne" .. n)
			local p = (repere * CFrame.new(c[1], 0, c[2])).Position
			-- chaque colonne regarde le centre de l'autel
			local base = CFrame.lookAt(Vector3.new(p.X, 0, p.Z), C)
			local y = 0.3
			bloc(colonne, {
				Name = "Socle",
				Size = Vector3.new(2.2, 0.8, 2.2),
				CFrame = base * CFrame.new(0, y + 0.4, 0),
				Color = PIERRE_OMBRE,
			})
			y = y + 0.8
			bloc(colonne, {
				Name = "Fut",
				Size = Vector3.new(1.6, c[3], 1.6),
				CFrame = base * CFrame.new(0, y + c[3] / 2, 0),
				Color = PIERRE,
			})
			-- runes Neon sur la face tournée vers l'autel
			local runes = Outils.modele(colonne, "Runes")
			local nb = 3
			if c[4] then
				nb = 4
			end
			for i = 1, nb do
				local couleur = Charte.violet
				if (i + n) % 2 == 0 then
					couleur = Charte.gemme
				end
				bloc(runes, {
					Name = "Rune" .. i,
					Size = Vector3.new(0.7, 0.7, 0.1),
					CFrame = base * CFrame.new(0, y + i * (c[3] / (nb + 1)), -0.82) * CFrame.Angles(0, 0, math.rad(45)),
					Color = couleur,
					Material = NEON,
					CanCollide = false,
				})
			end
			Outils.animer(runes, "pulse", R.vitessePulse * 0.8)
			y = y + c[3]
			bloc(colonne, {
				Name = "Chapiteau",
				Size = Vector3.new(2.4, 0.8, 2.4),
				CFrame = base * CFrame.new(0, y + 0.4, 0),
				Color = PIERRE_CLAIRE,
			})
			y = y + 0.8
			if c[4] then
				hautFronton = math.max(hautFronton, y)
			else
				-- cristal de gemme qui tourne au sommet
				local cristal = bloc(colonne, {
					Name = "Cristal",
					Size = Vector3.new(0.9, 1.6, 0.9),
					CFrame = base * CFrame.new(0, y + 1.3, 0) * CFrame.Angles(0, math.rad(45), 0),
					Color = Charte.gemme,
					Material = NEON,
					CanCollide = false,
				})
				if cristal then
					Outils.animer(cristal, "tourne", 0.8)
					Outils.lumiere(cristal, { Range = 8, Brightness = 1, Color = Charte.gemme })
				end
			end
		end)
	end

	-- ===== 5. fronton « RENAISSANCE » tourné vers la Place =====
	pcall(function()
		if hautFronton <= 0 then
			hautFronton = 14.1
		end
		local fronton = bloc(modele, {
			Name = "Fronton",
			Size = Vector3.new(12, 3, 0.8),
			CFrame = loc(0, hautFronton + 1.5, 7.8),
			Color = Charte.ombre(Charte.violet),
		})
		bloc(modele, {
			Name = "Corniche",
			Size = Vector3.new(12.4, 0.4, 1),
			CFrame = loc(0, hautFronton + 3.2, 7.8),
			Color = Charte.dore,
		})
		bloc(modele, {
			Name = "Architrave",
			Size = Vector3.new(12.4, 0.3, 1),
			CFrame = loc(0, hautFronton - 0.15 + 0.3, 7.8),
			Color = Charte.dore,
			CanCollide = false,
		})
		if fronton then
			for _, face in ipairs({ "Front", "Back" }) do
				local etiquette = Outils.texte(fronton, face, "RENAISSANCE", { couleur = Charte.dore, pixelsParStud = 40 })
				if etiquette then
					pcall(function()
						etiquette.Parent.Name = "Affiche"
						etiquette.Name = "Titre"
						local contour = Instance.new("UIStroke")
						contour.Color = Charte.encre
						contour.Thickness = 2
						contour.Parent = etiquette
						local marge = Instance.new("UIPadding")
						marge.PaddingLeft = UDim.new(0.04, 0)
						marge.PaddingRight = UDim.new(0.04, 0)
						marge.PaddingTop = UDim.new(0.1, 0)
						marge.PaddingBottom = UDim.new(0.1, 0)
						marge.Parent = etiquette
					end)
				end
			end
		end
	end)

	-- ===== 6. braseros de part et d'autre de l'escalier =====
	for _, cote in ipairs({ -1, 1 }) do
		pcall(function()
			local brasero = Outils.modele(modele, "Brasero")
			bloc(brasero, {
				Name = "Pied",
				Size = Vector3.new(0.8, 2.6, 0.8),
				CFrame = loc(cote * 4.6, 0.3 + 1.3, -8.4),
				Color = PIERRE_OMBRE,
			})
			bloc(brasero, {
				Name = "Coupe",
				Size = Vector3.new(1.8, 0.6, 1.8),
				CFrame = loc(cote * 4.6, 0.3 + 2.9, -8.4),
				Color = Charte.dore,
			})
			local flamme = bloc(brasero, {
				Name = "Flamme",
				Size = Vector3.new(1, 1, 1),
				CFrame = loc(cote * 4.6, 0.3 + 3.8, -8.4) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
				Color = Charte.violet,
				Material = NEON,
				CanCollide = false,
			})
			if flamme then
				Outils.animer(flamme, "pulse", R.vitessePulse * 1.5)
				Outils.lumiere(flamme, { Range = 12, Brightness = 1.5, Color = Charte.violet })
				pcall(function()
					local feu = Instance.new("Fire")
					feu.Color = Charte.violet
					feu.SecondaryColor = Charte.gemme
					feu.Size = 3
					feu.Heat = 6
					feu.Parent = flamme
				end)
			end
		end)
	end

	-- ===== 7. l'invite (sans rappel : le client ouvre le panneau Renaissance) =====
	if partAutel then
		pcall(function()
			Outils.invite(partAutel, {
				nom = "Renaissance",
				action = "Renaître",
				objet = "Autel des Renaissances",
				distance = R.distanceInvite,
			})
		end)
	end

	modele:SetAttribute("Parts", compte)
end

return M
