-- Constructeur Autel : l'Autel des Renaissances, à l'est de la Place (plan v2 « plus d'air »).
-- Un temple ancien : parvis rond en ardoise cerclé de Neon violet et de runes, trois gradins de marbre
-- à plinthes d'ardoise, un tapis violet qui monte vers la table de l'autel, un œuf fossile en or
-- (métal réfléchissant) qui flotte dans un halo au milieu de cristaux en orbite, six colonnes
-- de marbre aux arêtes arrondies gravées de runes Neon, un fronton « RENAISSANCE » à pignon
-- tourné vers la Place, des bannières et deux braseros à flammes violettes.
-- Animations (client, Interface/AnimationsDecor) : l'œuf flotte, deux anneaux d'éclats tournent en sens
-- contraires, les runes pulsent en vagues ; le serveur fait « battre » l'œuf de loin en loin (gerbe
-- d'étincelles et éclair violet, quelques dixièmes de seconde toutes les 9 à 15 s).
-- L'invite « Renaissance » est posée sans rappel : le client ouvre le panneau (Client.client.lua)
-- et Systemes/Renaissance traite la demande réseau.
-- Emprise (CONTRAT §10) : disque r11 autour de Plan.autel.centre ; l'orientation (façade vers la Place)
-- se déduit de Plan.place.centre, aucune coordonnée en dur.
local M = {}

local BUDGET = 250 -- parts au maximum pour ce constructeur

-- valeurs par défaut, remplaçables par Equilibrage.autel
local DEFAUTS = {
	rayon = 11,              -- rayon du parvis (emprise)
	hauteurGradin = 0.9,     -- hauteur d'une marche de l'autel
	hauteurOeuf = 10.3,      -- hauteur du centre de l'œuf
	vitesseFlotte = 1.2,     -- vitesse du va-et-vient de l'œuf
	vitessePulse = 2,        -- vitesse de pulsation des Neon
	distanceInvite = 12,     -- portée de l'invite « Renaissance »
	graine = 1104,           -- graine du hasard (légères variations des runes)
	pouls = 12,              -- secondes (en moyenne) entre deux battements de l'œuf
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
	-- repère local : -Z local = vers la Place, Y vers le haut. La direction suit l'axe principal
	-- (X ou Z) qui mène à la Place : la façade reste alignée sur le chemin qui y conduit (Builders/Sol).
	local versPlace = Vector3.new(-1, 0, 0)
	if Plan.place and typeof(Plan.place.centre) == "Vector3" then
		local dx = Plan.place.centre.X - C.X
		local dz = Plan.place.centre.Z - C.Z
		local function signe(v)
			if v < 0 then
				return -1
			end
			return 1
		end
		if math.abs(dx) >= math.abs(dz) and math.abs(dx) > 0.5 then
			versPlace = Vector3.new(signe(dx), 0, 0)
		elseif math.abs(dz) > 0.5 then
			versPlace = Vector3.new(0, 0, signe(dz))
		end
	end
	local repere = CFrame.lookAt(C, C + versPlace)

	local Style = ctx.Style
	local M_NEON = Enum.Material.Neon
	local M_MARBRE = Enum.Material.Marble
	local M_ARDOISE = Enum.Material.Slate
	local M_METAL = Enum.Material.Metal
	local M_TISSU = Enum.Material.Fabric
	local M_BASALTE = Enum.Material.Basalt

	-- trois teintes de pierre : marbre crème (structure), ardoise (plinthes, socles), ardoise sombre
	local MARBRE = Charte.creme
	local MARBRE_OMBRE = Charte.ombre(Charte.creme)
	local ARDOISE = Charte.pierre
	local ARDOISE_OMBRE = Charte.ombre(Charte.pierre)
	local ARDOISE_CLAIRE = Charte.lumiere(Charte.pierre)
	local OR = Charte.dore
	local OR_CLAIR = Charte.lumiere(Charte.dore)
	local OR_OMBRE = Charte.ombre(Charte.dore)
	-- violet « renaissance » vif du style simulateur (bouton violet de Style), sinon Charte
	local VIOLET_VIF = Charte.violet
	local VIOLET_CLAIR = Charte.lumiere(Charte.violet)
	if Style and Style.boutons and Style.boutons.violet then
		VIOLET_CLAIR = Style.boutons.violet[1]
		VIOLET_VIF = Style.boutons.violet[2]
	end
	local VIOLET_SOMBRE = Charte.ombre(Charte.ombre(Charte.violet))

	local modele = Outils.modele(ctx.dossier, "AutelDesRenaissances")

	-- ===== création avec respect du budget (les formes composées comptent toutes leurs parts) =====
	local compte = 0
	local function creer(fabrique, cout, parent, props, extra)
		if compte + cout > BUDGET then
			return nil
		end
		local ok, res, res2 = pcall(fabrique, parent, props, extra)
		if ok and res then
			compte = compte + cout
			return res, res2
		end
		return nil
	end
	local function bloc(parent, props) return creer(Outils.bloc, 1, parent, props) end
	local function coin(parent, props) return creer(Outils.coin, 1, parent, props) end
	local function cylindre(parent, props) return creer(Outils.cylindre, 1, parent, props) end
	local function boule(parent, props) return creer(Outils.boule, 1, parent, props) end
	-- bloc aux arêtes verticales arrondies : 6 parts
	local function arrondi(parent, props, rayon) return creer(Outils.blocArrondi, 6, parent, props, rayon) end

	-- CFrame dans le repère de l'autel
	local function loc(x, y, z)
		return repere * CFrame.new(x, y, z)
	end
	-- cylindre vertical (l'axe d'un cylindre Roblox est X)
	local function vertical(cf)
		return cf * CFrame.Angles(0, 0, math.rad(90))
	end
	-- dalle de marbre sur plinthe d'ardoise (2 parts, cf. Outils.dalleBordee)
	local function dalle(parent, props, bord, couleurBord)
		if compte + 2 > BUDGET then
			return nil
		end
		local ok, d = pcall(Outils.dalleBordee, parent, props, bord, couleurBord)
		if ok and d then
			compte = compte + 2
			return d
		end
		return nil
	end

	-- positions des colonnes : { x, z, hauteur du fût, porte le fronton }
	local COLONNES = {
		{ -5, 7.8, 12.2, true },
		{ 5, 7.8, 12.2, true },
		{ -8.6, 1.5, 8, false },
		{ 8.6, 1.5, 8, false },
		{ -7.9, -4.2, 8, false },
		{ 7.9, -4.2, 8, false },
	}
	local Y_PARVIS = 0.4 -- dessus du parvis

	-- ===== 1. parvis rond en ardoise, cerclé de Neon et de runes =====
	pcall(function()
		local diametre = R.rayon * 2
		local cercle = cylindre(modele, {
			Name = "Cercle",
			Size = Vector3.new(0.2, diametre, diametre),
			CFrame = vertical(loc(0, 0.1, 0)),
			Color = VIOLET_VIF,
			Material = M_NEON,
			CastShadow = false,
		})
		if cercle then
			Outils.animer(cercle, "pulse", R.vitessePulse * 0.5)
		end
		cylindre(modele, {
			Name = "Dalle",
			Size = Vector3.new(Y_PARVIS, diametre - 0.9, diametre - 0.9),
			CFrame = vertical(loc(0, Y_PARVIS / 2, 0)),
			Color = ARDOISE_OMBRE,
			Material = M_ARDOISE,
		})
		cylindre(modele, {
			Name = "Rosace",
			Size = Vector3.new(0.06, diametre - 3.4, diametre - 3.4),
			CFrame = vertical(loc(0, Y_PARVIS + 0.03, 0)),
			Color = ARDOISE,
			Material = M_MARBRE,
			CanCollide = false,
		})
		-- couronne de runes incrustées, hors du chemin d'accès et des socles de colonnes
		local runes = Outils.modele(modele, "RunesDalle")
		local rayonRunes = R.rayon - 1.1
		local hasard = Outils.aleatoire(R.graine)
		for i = 0, 11 do
			local a = math.rad(i * 30 + 15)
			local x, z = math.cos(a) * rayonRunes, math.sin(a) * rayonRunes
			local libre = not (z < 0 and math.abs(x) < 5.8)
			for _, c in ipairs(COLONNES) do
				if math.abs(x - c[1]) < 2 and math.abs(z - c[2]) < 2 then
					libre = false
				end
			end
			if libre then
				local couleur = VIOLET_CLAIR
				if hasard:NextNumber() < 0.35 then
					couleur = Charte.gemme
				end
				bloc(runes, {
					Name = "Rune",
					Size = Vector3.new(0.7, 0.05, 0.7),
					CFrame = loc(x, Y_PARVIS + 0.06, z) * CFrame.Angles(0, -a + math.rad(45), 0),
					Color = couleur,
					Material = M_NEON,
					CanCollide = false,
					CastShadow = false,
				})
			end
		end
		Outils.animer(runes, "pulse", R.vitessePulse * 0.5)
	end)

	-- ===== 2. trois gradins de marbre à plinthes d'ardoise =====
	local hautAutel = Y_PARVIS
	local partAutel = nil
	local cotes = { 12, 9, 6 }
	pcall(function()
		local teintes = { MARBRE_OMBRE, MARBRE, Charte.lumiere(MARBRE) }
		for i, cote in ipairs(cotes) do
			local h = R.hauteurGradin
			local yc = hautAutel + h / 2
			dalle(modele, {
				Name = "Gradin" .. i,
				Size = Vector3.new(cote, h, cote),
				CFrame = loc(0, yc, 0),
				Color = teintes[i],
				Material = M_MARBRE,
				MaterialBord = M_ARDOISE,
			}, 0.3, ARDOISE)
			-- rainure Neon violette sur la contremarche, côté Place (visible de loin)
			local nez = bloc(modele, {
				Name = "Nez" .. i,
				Size = Vector3.new(cote - 0.8, 0.12, 0.08),
				CFrame = loc(0, yc + h * 0.33, -cote / 2 - 0.03),
				Color = VIOLET_CLAIR,
				Material = M_NEON,
				CanCollide = false,
				CastShadow = false,
			})
			if nez then
				-- vitesses décalées d'une marche à l'autre : la lumière semble monter vers l'œuf
				Outils.animer(nez, "pulse", R.vitessePulse * (0.8 + 0.25 * i))
			end
			hautAutel = hautAutel + h
		end

		-- tapis violet qui monte du parvis jusqu'à l'autel
		local tapis = Outils.modele(modele, "Tapis")
		local troncons = {
			{ Y_PARVIS, -R.rayon + 0.9, -cotes[1] / 2 - 0.3 },
			{ Y_PARVIS + R.hauteurGradin, -cotes[1] / 2, -cotes[2] / 2 },
			{ Y_PARVIS + 2 * R.hauteurGradin, -cotes[2] / 2, -cotes[3] / 2 },
			{ Y_PARVIS + 3 * R.hauteurGradin, -cotes[3] / 2, -2.5 },
		}
		for i, t in ipairs(troncons) do
			local longueur = t[3] - t[2]
			if longueur > 0.1 then
				bloc(tapis, {
					Name = "Tapis" .. i,
					Size = Vector3.new(3.2, 0.06, longueur),
					CFrame = loc(0, t[1] + 0.03, (t[2] + t[3]) / 2),
					Color = VIOLET_SOMBRE,
					Material = M_TISSU,
					CanCollide = false,
				})
			end
		end

		-- bornes d'ardoise coiffées d'or aux quatre angles du premier gradin
		local yBorne = Y_PARVIS + R.hauteurGradin
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local x, z = sx * (cotes[1] / 2 - 0.6), sz * (cotes[1] / 2 - 0.6)
				bloc(modele, {
					Name = "Borne",
					Size = Vector3.new(0.9, 0.8, 0.9),
					CFrame = loc(x, yBorne + 0.4, z),
					Color = ARDOISE,
					Material = M_ARDOISE,
				})
				bloc(modele, {
					Name = "BorneOr",
					Size = Vector3.new(1.05, 0.18, 1.05),
					CFrame = loc(x, yBorne + 0.89, z),
					Color = OR,
					Material = M_METAL,
					Reflectance = 0.2,
				})
			end
		end

		-- la table de l'autel : socle d'ardoise, bloc de marbre arrondi (porte l'invite), plateau d'or
		bloc(modele, {
			Name = "SocleAutel",
			Size = Vector3.new(5, 0.4, 5),
			CFrame = loc(0, hautAutel + 0.2, 0),
			Color = ARDOISE_OMBRE,
			Material = M_ARDOISE,
		})
		local table_ = arrondi(modele, {
			Name = "TableAutel",
			Size = Vector3.new(4.4, 1.6, 4.4),
			CFrame = loc(0, hautAutel + 0.4 + 0.8, 0),
			Color = MARBRE,
			Material = M_MARBRE,
		}, 0.6)
		if table_ then
			partAutel = table_:FindFirstChild("CoeurX")
			if partAutel then
				partAutel.Name = "Autel"
			end
		end
		arrondi(modele, {
			Name = "Plateau",
			Size = Vector3.new(4.9, 0.3, 4.9),
			CFrame = loc(0, hautAutel + 2.15, 0),
			Color = OR,
			Material = M_METAL,
			Reflectance = 0.25,
		}, 0.7)
		-- runes gravées sur les trois faces non tournées vers la Place
		local runesAutel = Outils.modele(modele, "RunesAutel")
		for _, a in ipairs({ 90, 180, 270 }) do
			bloc(runesAutel, {
				Name = "Rune",
				Size = Vector3.new(0.8, 0.8, 0.08),
				CFrame = loc(0, hautAutel + 1.2, 0) * CFrame.Angles(0, math.rad(a), 0)
					* CFrame.new(0, 0, -2.22) * CFrame.Angles(0, 0, math.rad(45)),
				Color = VIOLET_CLAIR,
				Material = M_NEON,
				CanCollide = false,
				CastShadow = false,
			})
		end
		Outils.animer(runesAutel, "pulse", R.vitessePulse)
		local sceau = cylindre(modele, {
			Name = "Sceau",
			Size = Vector3.new(0.12, 3.4, 3.4),
			CFrame = vertical(loc(0, hautAutel + 2.35, 0)),
			Color = VIOLET_CLAIR,
			Material = M_NEON,
			CanCollide = false,
			CastShadow = false,
		})
		if sceau then
			Outils.animer(sceau, "pulse", R.vitessePulse)
			Outils.lumiere(sceau, { Range = 20, Brightness = 3, Color = VIOLET_VIF })
		end
		-- griffes fossiles qui montent vers l'œuf
		for i = 0, 3 do
			local a = math.rad(45 + i * 90)
			bloc(modele, {
				Name = "Griffe",
				Size = Vector3.new(0.35, 2.2, 0.35),
				CFrame = loc(math.cos(a) * 1.9, hautAutel + 3.3, math.sin(a) * 1.9)
					* CFrame.Angles(0, -a, 0) * CFrame.Angles(0, 0, math.rad(22)),
				Color = Charte.lumiere(MARBRE),
				Material = Enum.Material.Sandstone,
				CanCollide = false,
			})
		end
		if partAutel then
			-- bonus affiché sur la face de l'autel tournée vers la Place
			local bonus = texteBonus(ctx.Equilibrage)
			if bonus ~= "" then
				local etiquetteBonus = Outils.texte(partAutel, "Front", bonus, { couleur = OR, pixelsParStud = 30 })
				if etiquetteBonus and Style then
					pcall(function()
						etiquetteBonus.Font = Style.police
						etiquetteBonus.TextColor3 = Style.couleurs.revenu
						Style.contour(etiquetteBonus, 3)
					end)
				end
			end
		end
	end)

	-- ===== 3. l'œuf fossile en or, qui flotte dans son halo =====
	local yOeuf = math.max(R.hauteurOeuf, hautAutel + 6.5)
	pcall(function()
		local oeuf = Outils.modele(modele, "OeufFossile")
		local yc = yOeuf
		local proprietesOr = function(nom, taille, dy, couleur)
			return {
				Name = nom,
				Size = Vector3.new(taille, taille, taille),
				CFrame = loc(0, yc + dy, 0),
				Color = couleur,
				Material = M_METAL,
				Reflectance = 0.35,
				CanCollide = false,
			}
		end
		local bas = boule(oeuf, proprietesOr("Coque", 5, -1.3, OR))
		local milieu = boule(oeuf, proprietesOr("Ventre", 4.4, 0, OR))
		boule(oeuf, proprietesOr("Pointe", 3.2, 1.4, OR_CLAIR))
		-- fissures lumineuses du fossile
		local fissures = Outils.modele(oeuf, "Fissures")
		for i = 0, 5 do
			local a = math.rad(i * 60 + 15)
			local dy = 0.35
			local sens = 1
			if i % 2 == 1 then
				dy = -0.25
				sens = -1
			end
			local dir = Vector3.new(math.cos(a), dy, math.sin(a)).Unit
			local pos = (repere * CFrame.new(dir * 2.14)).Position + Vector3.new(0, yc, 0)
			local couleur = VIOLET_CLAIR
			if i % 3 == 0 then
				couleur = Charte.gemme
			end
			bloc(fissures, {
				Name = "Fissure",
				Size = Vector3.new(0.2, 1.6, 0.2),
				CFrame = CFrame.lookAt(pos, pos + (pos - Vector3.new(C.X, yc, C.Z)))
					* CFrame.Angles(0, 0, math.rad(25 * sens)),
				Color = couleur,
				Material = M_NEON,
				CanCollide = false,
				CastShadow = false,
			})
		end
		Outils.animer(fissures, "pulse", R.vitessePulse)

		-- halo doré autour de l'œuf
		local halo = boule(oeuf, {
			Name = "Halo",
			Size = Vector3.new(7, 7, 7),
			CFrame = loc(0, yc, 0),
			Color = OR_CLAIR,
			Material = Enum.Material.ForceField,
			Transparency = 0.2,
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
				etincelles.Color = ColorSequence.new(OR, Charte.violet)
				etincelles.LightEmission = 1
				etincelles.Size = NumberSequence.new(0.35, 0)
				etincelles.Transparency = NumberSequence.new(0.1, 1)
				etincelles.Lifetime = NumberRange.new(1.5, 2.5)
				etincelles.Rate = 10
				etincelles.Speed = NumberRange.new(0.8, 1.6)
				etincelles.SpreadAngle = Vector2.new(180, 180)
				etincelles.Parent = halo
			end)
		end
		if milieu then
			Outils.lumiere(milieu, { Range = 18, Brightness = 2, Color = OR })
			oeuf.PrimaryPart = milieu
		elseif bas then
			oeuf.PrimaryPart = bas
		end
		Outils.animer(oeuf, "flotte", R.vitesseFlotte)

		-- cristaux de gemme en orbite autour de l'œuf (modèle à part : il tourne pendant que l'œuf flotte)
		local orbite = Outils.modele(modele, "Orbite")
		for i = 0, 5 do
			local a = math.rad(i * 60)
			local dy = 0.6
			if i % 2 == 1 then
				dy = -0.6
			end
			local couleur = Charte.gemme
			if i % 2 == 1 then
				couleur = VIOLET_CLAIR
			end
			bloc(orbite, {
				Name = "Eclat",
				Size = Vector3.new(0.5, 1.1, 0.5),
				CFrame = loc(math.cos(a) * 4.4, yc + dy, math.sin(a) * 4.4)
					* CFrame.Angles(0, -a, 0) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
				Color = couleur,
				Material = M_NEON,
				CanCollide = false,
				CanQuery = false,
				CastShadow = false,
			})
		end
		pcall(function()
			orbite.WorldPivot = loc(0, yc, 0)
		end)
		Outils.animer(orbite, "tourne", 0.5)

		-- second anneau : poussière d'or plus serrée, qui tourne en sens contraire, un peu plus bas
		local poussiere = Outils.modele(modele, "OrbitePoussiere")
		for i = 0, 7 do
			local a = math.rad(i * 45 + 22.5)
			bloc(poussiere, {
				Name = "Paillette",
				Size = Vector3.new(0.35, 0.35, 0.35),
				CFrame = loc(math.cos(a) * 3.3, yc - 2.4, math.sin(a) * 3.3) * CFrame.Angles(math.rad(45), a, math.rad(45)),
				Color = OR_CLAIR,
				Material = M_NEON,
				CanCollide = false,
				CanQuery = false,
				CastShadow = false,
			})
		end
		pcall(function()
			poussiere.WorldPivot = loc(0, yc - 2.4, 0)
		end)
		Outils.animer(poussiere, "tourne", -0.9)

		-- taches violettes de l'œuf (un vrai œuf de dino), elles suivent l'œuf qui flotte
		for i = 0, 3 do
			local a = math.rad(i * 90 + 40)
			-- en haut sur le ventre (rayon 2,2), en bas sur la coque (rayon 2,5) ; la tache dépasse un peu
			local dy, r = 0.6, 1.95
			if i % 2 == 1 then
				dy, r = -1.2, 2.25
			end
			local pos = loc(math.cos(a) * r, yc + dy, math.sin(a) * r).Position
			boule(oeuf, {
				Name = "Tache",
				Size = Vector3.new(1.1, 1.1, 1.1),
				CFrame = CFrame.new(pos),
				Color = VIOLET_CLAIR,
				Material = Enum.Material.SmoothPlastic,
				CanCollide = false,
				CanQuery = false,
			})
		end

		-- colonne de lumière douce entre le sceau de l'autel et l'œuf
		local bas_ = hautAutel + 2.4
		local haut_ = yc - 2.2
		if haut_ - bas_ > 0.5 then
			local rayonLumiere = cylindre(modele, {
				Name = "RayonLumiere",
				Size = Vector3.new(haut_ - bas_, 1.3, 1.3),
				CFrame = vertical(loc(0, (bas_ + haut_) / 2, 0)),
				Color = VIOLET_CLAIR,
				Material = M_NEON,
				Transparency = 0.55,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
			if rayonLumiere then
				Outils.animer(rayonLumiere, "pulse", R.vitessePulse * 1.3)
				-- particules qui montent doucement vers l'œuf
				pcall(function()
					local monte = Instance.new("ParticleEmitter")
					monte.Name = "Montee"
					monte.Color = ColorSequence.new(VIOLET_CLAIR, OR_CLAIR)
					monte.LightEmission = 1
					monte.Size = NumberSequence.new(0.25, 0)
					monte.Transparency = NumberSequence.new(0.2, 1)
					monte.Lifetime = NumberRange.new(1.2, 1.8)
					monte.Rate = 6
					monte.Speed = NumberRange.new(1.5, 2.5)
					monte.SpreadAngle = Vector2.new(8, 8)
					monte.EmissionDirection = Enum.NormalId.Right -- axe du cylindre = vers le haut
					monte.Parent = rayonLumiere
				end)
			end
		end

		-- battement : de loin en loin, une gerbe d'étincelles et un éclair violet (quelques dixièmes de seconde)
		if halo then
			pcall(function()
				local gerbe = Instance.new("ParticleEmitter")
				gerbe.Name = "Battement"
				gerbe.Color = ColorSequence.new(VIOLET_CLAIR, Charte.gemme)
				gerbe.LightEmission = 1
				gerbe.Size = NumberSequence.new(0.6, 0)
				gerbe.Transparency = NumberSequence.new(0, 1)
				gerbe.Lifetime = NumberRange.new(0.8, 1.4)
				gerbe.Rate = 70
				gerbe.Speed = NumberRange.new(6, 10)
				gerbe.Drag = 3
				gerbe.SpreadAngle = Vector2.new(180, 180)
				gerbe.Enabled = false
				gerbe.Parent = halo
				local eclair = Outils.lumiere(halo, { Range = 26, Brightness = 0, Color = VIOLET_VIF })
				local hasardPouls = Outils.aleatoire(R.graine + 7)
				task.spawn(function()
					while modele.Parent and halo.Parent do
						task.wait(R.pouls * (0.75 + 0.5 * hasardPouls:NextNumber()))
						if not (modele.Parent and halo.Parent) then
							break
						end
						gerbe.Enabled = true
						if eclair then
							eclair.Brightness = 4
						end
						task.wait(0.35)
						gerbe.Enabled = false
						if eclair then
							eclair.Brightness = 0
						end
					end
				end)
			end)
		end
	end)

	-- ===== 4. colonnes de marbre arrondies, gravées de runes =====
	local hautFronton = 0
	for n, c in ipairs(COLONNES) do
		pcall(function()
			local colonne = Outils.modele(modele, "Colonne" .. n)
			local p = (repere * CFrame.new(c[1], 0, c[2])).Position
			-- chaque colonne regarde le centre de l'autel (-Z local vers le centre)
			local base = CFrame.lookAt(Vector3.new(p.X, 0, p.Z), C)
			local y = Y_PARVIS
			bloc(colonne, {
				Name = "Socle",
				Size = Vector3.new(2.5, 0.5, 2.5),
				CFrame = base * CFrame.new(0, y + 0.25, 0),
				Color = ARDOISE,
				Material = M_ARDOISE,
			})
			y = y + 0.5
			cylindre(colonne, {
				Name = "Tore",
				Size = Vector3.new(0.4, 2.2, 2.2),
				CFrame = vertical(base * CFrame.new(0, y + 0.2, 0)),
				Color = MARBRE_OMBRE,
				Material = M_MARBRE,
			})
			y = y + 0.4
			cylindre(colonne, {
				Name = "BagueBas",
				Size = Vector3.new(0.25, 2.05, 2.05),
				CFrame = vertical(base * CFrame.new(0, y + 0.125, 0)),
				Color = OR,
				Material = M_METAL,
				Reflectance = 0.2,
			})
			arrondi(colonne, {
				Name = "Fut",
				Size = Vector3.new(1.7, c[3], 1.7),
				CFrame = base * CFrame.new(0, y + c[3] / 2, 0),
				Color = MARBRE,
				Material = M_MARBRE,
			}, 0.5)
			-- runes Neon gravées sur la face tournée vers l'autel
			local runes = Outils.modele(colonne, "Runes")
			local nb = 3
			if c[4] then
				nb = 4
			end
			for i = 1, nb do
				local couleur = VIOLET_CLAIR
				if (i + n) % 3 == 0 then
					couleur = Charte.gemme
				end
				bloc(runes, {
					Name = "Rune" .. i,
					Size = Vector3.new(0.5, 0.5, 0.08),
					CFrame = base * CFrame.new(0, y + i * (c[3] / (nb + 1)), -0.86) * CFrame.Angles(0, 0, math.rad(45)),
					Color = couleur,
					Material = M_NEON,
					CanCollide = false,
					CastShadow = false,
				})
			end
			Outils.animer(runes, "pulse", R.vitessePulse * 0.8)
			y = y + c[3]
			cylindre(colonne, {
				Name = "BagueHaut",
				Size = Vector3.new(0.25, 2.05, 2.05),
				CFrame = vertical(base * CFrame.new(0, y - 0.3, 0)),
				Color = OR,
				Material = M_METAL,
				Reflectance = 0.2,
			})
			cylindre(colonne, {
				Name = "Chapiteau",
				Size = Vector3.new(0.5, 2.3, 2.3),
				CFrame = vertical(base * CFrame.new(0, y + 0.25, 0)),
				Color = MARBRE_OMBRE,
				Material = M_MARBRE,
			})
			y = y + 0.5
			bloc(colonne, {
				Name = "Abaque",
				Size = Vector3.new(2.6, 0.4, 2.6),
				CFrame = base * CFrame.new(0, y + 0.2, 0),
				Color = ARDOISE,
				Material = M_ARDOISE,
			})
			y = y + 0.4
			if c[4] then
				hautFronton = math.max(hautFronton, y)
			else
				-- cristal de gemme qui tourne au sommet
				local cristal = bloc(colonne, {
					Name = "Cristal",
					Size = Vector3.new(0.9, 1.6, 0.9),
					CFrame = base * CFrame.new(0, y + 1.3, 0) * CFrame.Angles(0, math.rad(45), 0),
					Color = Charte.gemme,
					Material = M_NEON,
					CanCollide = false,
					CastShadow = false,
				})
				if cristal then
					Outils.animer(cristal, "tourne", 0.8)
					Outils.lumiere(cristal, { Range = 8, Brightness = 1, Color = Charte.gemme })
				end
			end
		end)
	end

	-- ===== 5. fronton « RENAISSANCE » à pignon, tourné vers la Place =====
	pcall(function()
		if hautFronton <= 0 then
			hautFronton = 14.4
		end
		local zF = COLONNES[1][2]
		local architrave = bloc(modele, {
			Name = "Architrave",
			Size = Vector3.new(12.6, 0.35, 1.3),
			CFrame = loc(0, hautFronton + 0.175, zF),
			Color = OR,
			Material = M_METAL,
			Reflectance = 0.2,
		})
		if architrave then
			-- projecteur doux qui tombe du fronton sur l'œuf
			pcall(function()
				local spot = Outils.lumiere(architrave, { genre = "Spot", Range = 18, Brightness = 2, Color = OR_CLAIR })
				spot.Face = Enum.NormalId.Front
				spot.Angle = 70
			end)
		end
		local fronton = bloc(modele, {
			Name = "Fronton",
			Size = Vector3.new(12, 3, 0.9),
			CFrame = loc(0, hautFronton + 0.35 + 1.5, zF),
			Color = ARDOISE_OMBRE,
			Material = M_ARDOISE,
		})
		local yCorniche = hautFronton + 0.35 + 3
		bloc(modele, {
			Name = "Corniche",
			Size = Vector3.new(13, 0.4, 1.5),
			CFrame = loc(0, yCorniche + 0.2, zF),
			Color = OR,
			Material = M_METAL,
			Reflectance = 0.2,
		})
		-- pignon triangulaire en marbre (deux coins qui montent vers le centre)
		for _, cote in ipairs({ -1, 1 }) do
			coin(modele, {
				Name = "Pignon",
				Size = Vector3.new(1.1, 2.2, 6.4),
				CFrame = loc(cote * 3.2, yCorniche + 0.4 + 1.1, zF) * CFrame.Angles(0, math.rad(-90 * cote), 0),
				Color = MARBRE,
				Material = M_MARBRE,
			})
		end
		-- gemme au sommet du pignon
		local acrotere = bloc(modele, {
			Name = "Acrotere",
			Size = Vector3.new(0.9, 0.9, 0.9),
			CFrame = loc(0, yCorniche + 0.4 + 2.6, zF) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
			Color = VIOLET_CLAIR,
			Material = M_NEON,
			CanCollide = false,
			CastShadow = false,
		})
		if acrotere then
			Outils.animer(acrotere, "pulse", R.vitessePulse)
		end
		if fronton then
			for _, face in ipairs({ "Front", "Back" }) do
				local etiquette = Outils.texte(fronton, face, "RENAISSANCE", { couleur = OR, pixelsParStud = 40 })
				if etiquette then
					pcall(function()
						etiquette.Parent.Name = "Affiche"
						etiquette.Name = "Titre"
						if Style then
							-- texte blanc cerné de noir épais, teinté d'un dégradé violet
							etiquette.Font = Style.policeTitre
							etiquette.TextColor3 = Style.couleurs.texte
							Style.contour(etiquette, 4)
							Style.degrade(etiquette, VIOLET_CLAIR, VIOLET_VIF)
						else
							local contour = Instance.new("UIStroke")
							contour.Color = Charte.encre
							contour.Thickness = 2
							contour.Parent = etiquette
						end
						local marge = Instance.new("UIPadding")
						marge.PaddingLeft = UDim.new(0.04, 0)
						marge.PaddingRight = UDim.new(0.04, 0)
						marge.PaddingTop = UDim.new(0.12, 0)
						marge.PaddingBottom = UDim.new(0.12, 0)
						marge.Parent = etiquette
					end)
				end
			end
		end

		-- bannières violettes suspendues sous l'architrave, de part et d'autre de l'œuf
		for _, cote in ipairs({ -1, 1 }) do
			local banniere = Outils.modele(modele, "Banniere")
			local x = cote * 2.9
			local hB = 5.5
			bloc(banniere, {
				Name = "Toile",
				Size = Vector3.new(2, hB, 0.12),
				CFrame = loc(x, hautFronton - hB / 2, zF),
				Color = VIOLET_VIF,
				Material = M_TISSU,
				CanCollide = false,
			})
			bloc(banniere, {
				Name = "Frange",
				Size = Vector3.new(2.1, 0.3, 0.2),
				CFrame = loc(x, hautFronton - hB, zF),
				Color = OR_OMBRE,
				Material = M_METAL,
				CanCollide = false,
			})
			local embleme = bloc(banniere, {
				Name = "Embleme",
				Size = Vector3.new(0.8, 0.8, 0.06),
				CFrame = loc(x, hautFronton - hB * 0.4, zF - 0.1) * CFrame.Angles(0, 0, math.rad(45)),
				Color = OR_CLAIR,
				Material = M_NEON,
				CanCollide = false,
				CastShadow = false,
			})
			if embleme then
				Outils.animer(embleme, "pulse", R.vitessePulse * 0.7)
			end
		end
	end)

	-- ===== 6. braseros de part et d'autre du tapis =====
	for _, cote in ipairs({ -1, 1 }) do
		pcall(function()
			local brasero = Outils.modele(modele, "Brasero")
			local x, z = cote * 5.2, -8
			bloc(brasero, {
				Name = "Socle",
				Size = Vector3.new(1.5, 0.4, 1.5),
				CFrame = loc(x, Y_PARVIS + 0.2, z),
				Color = ARDOISE,
				Material = M_ARDOISE,
			})
			cylindre(brasero, {
				Name = "Pied",
				Size = Vector3.new(2, 0.8, 0.8),
				CFrame = vertical(loc(x, Y_PARVIS + 0.4 + 1, z)),
				Color = MARBRE,
				Material = M_MARBRE,
			})
			cylindre(brasero, {
				Name = "Col",
				Size = Vector3.new(0.35, 1.3, 1.3),
				CFrame = vertical(loc(x, Y_PARVIS + 2.55, z)),
				Color = OR_OMBRE,
				Material = M_METAL,
				Reflectance = 0.2,
			})
			cylindre(brasero, {
				Name = "Coupe",
				Size = Vector3.new(0.55, 2, 2),
				CFrame = vertical(loc(x, Y_PARVIS + 2.95, z)),
				Color = OR,
				Material = M_METAL,
				Reflectance = 0.25,
			})
			cylindre(brasero, {
				Name = "Braises",
				Size = Vector3.new(0.12, 1.6, 1.6),
				CFrame = vertical(loc(x, Y_PARVIS + 3.25, z)),
				Color = Charte.encre,
				Material = M_BASALTE,
				CanCollide = false,
			})
			local flamme = bloc(brasero, {
				Name = "Flamme",
				Size = Vector3.new(0.9, 0.9, 0.9),
				CFrame = loc(x, Y_PARVIS + 3.9, z) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
				Color = VIOLET_CLAIR,
				Material = M_NEON,
				CanCollide = false,
				CastShadow = false,
			})
			if flamme then
				Outils.animer(flamme, "pulse", R.vitessePulse * 1.5)
				Outils.lumiere(flamme, { Range = 14, Brightness = 2, Color = Charte.violet })
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

	-- ===== 6 bis. titre flottant géant « ♻️ RENAISSANCE » (style simulateur) =====
	if Style and type(Style.etiquette) == "function" then
		pcall(function()
			local hautTitre = hautFronton
			if hautTitre <= 0 then
				hautTitre = 14.4
			end
			-- ancre invisible au-dessus du pignon : le titre se voit depuis toute la Place
			local ancre = bloc(modele, {
				Name = "AncreTitre",
				Size = Vector3.new(1, 1, 1),
				CFrame = loc(0, hautTitre + 7, 4),
				Transparency = 1,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
			if not ancre then
				return
			end
			local lignes = {
				{ texte = "♻️ RENAISSANCE", titre = true, taille = 1.6, contour = 4, rarete = "Divin", nom = "Titre" },
				{ texte = "Renais plus fort !", taille = 0.8, contour = 3, nom = "SousTitre" },
			}
			local bonus = texteBonus(ctx.Equilibrage)
			if bonus ~= "" then
				table.insert(lignes, { texte = bonus, couleur = Style.couleurs.revenu, taille = 0.8, contour = 3, nom = "Bonus" })
			end
			local _, textes = Style.etiquette(ancre, lignes, {
				Name = "TitreRenaissance",
				largeur = 24,
				hauteurLigne = 2.4,
				StudsOffset = Vector3.new(0, 2, 0),
				MaxDistance = 260,
				AlwaysOnTop = false,
			})
			-- sous-titre en dégradé violet (texte blanc teinté)
			if textes and textes[2] then
				Style.degrade(textes[2], VIOLET_CLAIR, VIOLET_VIF)
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
