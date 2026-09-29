-- Constructeur Lumieres (plan v2 « plus d'air », STYLE.md §4) : torches tiki qui balisent la promenade
-- du Tapis et entourent la Place.
-- Chaque torche (9 parts) : socle de pavés (Cobblestone), fût de bambou (Wood) à deux nœuds,
-- ligature de corde (Fabric), vasque de fer en deux étages (Metal), flamme Neon orange surmontée
-- d'une pointe jaune (animation « pulse » côté client), Fire, quelques braises (ParticleEmitter
-- très léger) et PointLight à ombres qui vacille doucement (serveur, 4 fois par seconde, ±10 %).
-- SpotLight décoratifs : les torches de la Place éclairent le pavage, une torche sur deux de la
-- promenade éclaire la piste des dinos (le projecteur est porté par la pointe, tournée vers sa cible).
-- La nuit (Lighting.ClockTime < 6,5 ou > 18,5), les torches brillent plus fort (fondu de 2 s).
-- Emprise (CONTRAT §10) — tout vient de Plan.lua, aucune coordonnée en dur :
--   * promenade du Tapis : |z| = Plan.promenade.zMin + 2,5 (≈ 12), du côté de chaque Base ; deux torches
--     par Base, de part et d'autre de son entrée (entre le portique et le coin de la Base), jamais
--     devant une entrée ni dans le prolongement d'une allée (Plan.allees) ; plus une torche à chaque
--     bout de la rangée, entre la dernière Base et les panneaux des bouts du Tapis ;
--   * Place : cercle r = Plan.place.rayon + 1, tous les 45°, décalé de 22,5° (axes libres) ; une torche
--     qui tomberait sur le lien de sable du Comptoir ou de l'Autel (z = leur centre ± 6, + 1,5 de garde)
--     est reportée de 22,5° vers le sud (22,5° → 45°, 157,5° → 135°) ; le secteur du tableau d'honneur
--     (Systemes/Classement, 215° ± 15°) reste vide (pas de torche à 202,5°) : 7 torches.
local M = {}

local Lighting = game:GetService("Lighting")

local BUDGET = 300 -- parts au maximum pour ce constructeur
local PARTS_PAR_TORCHE = 9 -- 20 torches de promenade + 7 de la Place = 27 x 9 = 243 parts

-- valeurs par défaut, remplaçables par Equilibrage.lumieres
local DEFAUTS = {
	retraitPromenade = 2.5, -- distance entre le bord intérieur de la promenade (rebord du Tapis) et les torches
	gardeEntree = 9,        -- demi-largeur laissée libre devant l'entrée d'une Base (portique compris)
	gardeAllee = 2,         -- marge ajoutée à la demi-largeur des allées
	reculBout = 6,          -- torche de bout de rangée : distance au coin extérieur de la dernière Base
	gardeBout = 10,         -- ... et au moins cette distance aux bouts du Tapis (panneaux)
	placeRayon = 0,         -- rayon du cercle de la Place (0 = Plan.place.rayon + 1)
	placePas = 45,          -- écart angulaire (degrés)
	placeDecalage = 22.5,   -- décalage angulaire : les allées (axes) restent dégagées
	demiLien = 6,           -- demi-largeur (en z) des liens de sable Place ↔ Comptoir / Autel (z 112 à 124)
	gardeLien = 1.5,        -- marge ajoutée à cette demi-largeur (le socle fait 2 de diamètre)
	retraitLien = 4,        -- le lien ne commence qu'au-delà de |x - centre.X| > rayon - retraitLien
	angleClassement = 215,  -- secteur du tableau d'honneur (Systemes/Classement, ANGLE_TABLEAU)
	demiClassement = 15,    -- demi-ouverture de ce secteur (degrés) : pas de torche à 202,5°
	hauteur = 5.8,          -- hauteur du fût de bambou (flamme sous la ligne des yeux)
	portee = 16,            -- portée de la lumière le jour
	porteeNuit = 18,        -- portée de la lumière la nuit
	eclat = 0.9,            -- intensité le jour
	eclatNuit = 2.4,        -- intensité la nuit
	feu = 2.2,              -- taille du feu le jour
	feuNuit = 3.4,          -- taille du feu la nuit
	spotPortee = 20,        -- portée des projecteurs décoratifs
	spotAngle = 55,         -- ouverture des projecteurs (degrés)
	spotEclat = 0.3,        -- intensité des projecteurs le jour
	spotEclatNuit = 1.6,    -- intensité des projecteurs la nuit
	vacille = 0.1,          -- amplitude du vacillement des lumières (fraction de l'intensité)
	pasVacille = 0.25,      -- secondes entre deux mises à jour du vacillement
	braises = 1.5,          -- braises par seconde et par torche
	debutNuit = 18.5,       -- ClockTime après lequel il fait nuit
	finNuit = 6.5,          -- ClockTime avant lequel il fait encore nuit
	intervalle = 5,         -- secondes entre deux vérifications de l'heure
	transition = 2,         -- durée du passage jour / nuit (secondes)
}

local function lireReglages(ctx)
	local source = nil
	if ctx.Equilibrage and type(ctx.Equilibrage.lumieres) == "table" then
		source = ctx.Equilibrage.lumieres
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
	if r.placePas < 1 then
		r.placePas = DEFAUTS.placePas
	end
	if r.intervalle < 1 then
		r.intervalle = DEFAUTS.intervalle
	end
	if r.pasVacille < 0.1 then
		r.pasVacille = DEFAUTS.pasVacille
	end
	if r.transition < 0.1 then
		r.transition = 0.1
	end
	return r
end

-- CFrame d'un cylindre vertical (l'axe d'un cylindre Roblox est X)
local function vertical(x, y, z)
	return CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90))
end

-- heure partagée (secondes), sans jamais échouer
local function maintenant()
	local ok, t = pcall(function()
		return workspace:GetServerTimeNow()
	end)
	if ok and type(t) == "number" then
		return t
	end
	return os.clock()
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	local compte = 0
	local lumieres = {} -- { lumiere = PointLight, feu = Fire, spot = SpotLight ou nil, p1, p2, v1, v2 }
	local alea = Outils.aleatoire(1907)

	-- teintes (palette de Style : orange et jaune des boutons, jaune des revenus)
	local orange = { Charte.lave, Charte.dore }
	local teinteRevenu = Charte.dore
	if Style and Style.boutons and Style.boutons.orange then
		orange = Style.boutons.orange
	end
	if Style and Style.couleurs and Style.couleurs.revenu then
		teinteRevenu = Style.couleurs.revenu
	end

	-- trois teintes par matière (base, ombre, lumière) pour donner du volume
	local BAMBOU = Charte.sable:Lerp(Charte.dore, 0.35):Lerp(Charte.terre, 0.15) -- bambou blond
	local NOEUD = Charte.ombre(Charte.ombre(BAMBOU))                               -- nœuds plus sombres
	local CORDE = Charte.ombre(Charte.sable:Lerp(Charte.terre, 0.4))               -- corde de chanvre
	local SOCLE = Charte.lumiere(Charte.pierre)                                    -- pavés clairs
	local FER = Charte.encre:Lerp(Charte.pierre, 0.45)                              -- fer forgé
	local FER_CLAIR = Charte.lumiere(FER)                                          -- rebord de la vasque
	local FLAMME = Charte.lave:Lerp(orange[2], 0.15)                                -- orange vif
	local POINTE = teinteRevenu                                                    -- cœur jaune
	local LUEUR = Charte.lave:Lerp(Charte.dore, 0.55):Lerp(Charte.creme, 0.25)     -- lumière chaude
	local LUEUR_SPOT = Charte.dore:Lerp(Charte.creme, 0.4)

	-- propriétés communes des parts de décor (rien ne gêne les joueurs ni les dinos)
	local function decor(props, ombre)
		props.CanCollide = false
		props.CanTouch = false
		props.CastShadow = ombre == true
		return props
	end

	-- quelques braises qui montent de la vasque (effet très léger)
	local function braises(flamme)
		if R.braises <= 0 then
			return
		end
		pcall(function()
			local e = Instance.new("ParticleEmitter")
			e.Name = "Braises"
			e.Rate = R.braises
			e.Lifetime = NumberRange.new(0.8, 1.6)
			e.Speed = NumberRange.new(2, 4)
			e.SpreadAngle = Vector2.new(18, 18)
			e.EmissionDirection = Enum.NormalId.Top
			e.Acceleration = Vector3.new(0, 1.5, 0)
			e.Drag = 1.5
			e.Color = ColorSequence.new(POINTE, FLAMME)
			e.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.16),
				NumberSequenceKeypoint.new(1, 0),
			})
			e.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.6),
			})
			e.LightEmission = 1
			e.LightInfluence = 0
			e.Parent = flamme
		end)
	end

	-- torche en (x, z) ; cible : point (Vector3) éclairé par un projecteur décoratif, ou nil
	local function torche(parent, nom, x, z, ySol, cible)
		if compte + PARTS_PAR_TORCHE > BUDGET then
			return nil
		end
		compte = compte + PARTS_PAR_TORCHE
		local y0 = ySol or 0
		local h = R.hauteur
		local m = Outils.modele(parent, nom)

		-- socle rond de pavés, bas et large
		Outils.cylindre(m, decor({
			Name = "Pied",
			Size = Vector3.new(0.7, 2, 2),
			CFrame = vertical(x, y0 + 0.35, z),
			Color = SOCLE,
			Material = Enum.Material.Cobblestone,
		}, true))
		-- fût de bambou
		local yBas = y0 + 0.6
		local fut = Outils.cylindre(m, decor({
			Name = "Bambou",
			Size = Vector3.new(h, 0.72, 0.72),
			CFrame = vertical(x, yBas + h / 2, z),
			Color = BAMBOU,
			Material = Enum.Material.Wood,
		}, true))
		m.PrimaryPart = fut
		-- deux nœuds du bambou
		Outils.cylindre(m, decor({
			Name = "Noeud",
			Size = Vector3.new(0.2, 0.86, 0.86),
			CFrame = vertical(x, yBas + h * 0.3, z),
			Color = NOEUD,
			Material = Enum.Material.Wood,
		}, true))
		Outils.cylindre(m, decor({
			Name = "Noeud",
			Size = Vector3.new(0.2, 0.86, 0.86),
			CFrame = vertical(x, yBas + h * 0.62, z),
			Color = NOEUD,
			Material = Enum.Material.Wood,
		}, true))
		-- ligature de corde sous la vasque
		Outils.cylindre(m, decor({
			Name = "Ligature",
			Size = Vector3.new(0.6, 0.9, 0.9),
			CFrame = vertical(x, yBas + h - 0.45, z),
			Color = CORDE,
			Material = Enum.Material.Fabric,
		}, true))
		-- vasque de fer : pied étroit puis coupe évasée (sans ombre : la flamme éclaire le sol)
		local yHaut = yBas + h
		Outils.cylindre(m, decor({
			Name = "VasquePied",
			Size = Vector3.new(0.55, 1.3, 1.3),
			CFrame = vertical(x, yHaut + 0.2, z),
			Color = FER,
			Material = Enum.Material.Metal,
		}))
		local yCoupe = yHaut + 0.8
		Outils.cylindre(m, decor({
			Name = "Vasque",
			Size = Vector3.new(0.85, 2.2, 2.2),
			CFrame = vertical(x, yCoupe, z),
			Color = FER_CLAIR,
			Material = Enum.Material.Metal,
		}))
		-- flamme Neon orange, à moitié dans la vasque
		local flamme = Outils.boule(m, decor({
			Name = "Flamme",
			Size = Vector3.new(1.6, 1.6, 1.6),
			CFrame = CFrame.new(x, yCoupe + 0.6, z),
			Color = FLAMME,
			Material = Enum.Material.Neon,
			CanQuery = false,
		}))
		-- vitesses légèrement différentes d'une torche à l'autre : les flammes ne battent pas ensemble
		Outils.animer(flamme, "pulse", 1.3 + alea:NextNumber() * 0.5)
		-- cœur jaune au-dessus (flamme en deux tons) ; tourné vers la cible du projecteur
		local posPointe = Vector3.new(x, yCoupe + 1.5, z)
		local cfPointe = CFrame.new(posPointe)
		if cible then
			cfPointe = CFrame.lookAt(posPointe, cible)
		end
		local pointe = Outils.boule(m, decor({
			Name = "Pointe",
			Size = Vector3.new(0.9, 0.9, 0.9),
			CFrame = cfPointe,
			Color = POINTE,
			Material = Enum.Material.Neon,
			CanQuery = false,
		}))
		Outils.animer(pointe, "pulse", 1.8 + alea:NextNumber() * 0.6)

		local feu = nil
		pcall(function()
			feu = Instance.new("Fire")
			feu.Color = FLAMME
			feu.SecondaryColor = POINTE
			feu.Size = R.feu
			feu.Heat = 7
			feu.Parent = flamme
		end)
		braises(flamme)
		local lumiere = nil
		pcall(function()
			lumiere = Outils.lumiere(flamme, { genre = "Point", Range = R.portee, Brightness = R.eclat, Color = LUEUR })
			lumiere.Shadows = true
		end)
		local spot = nil
		if cible then
			pcall(function()
				spot = Outils.lumiere(pointe, { genre = "Spot", Range = R.spotPortee, Brightness = R.spotEclat, Color = LUEUR_SPOT })
				spot.Face = Enum.NormalId.Front
				spot.Angle = R.spotAngle
				spot.Shadows = false
			end)
		end
		table.insert(lumieres, {
			lumiere = lumiere,
			feu = feu,
			spot = spot,
			p1 = alea:NextNumber() * math.pi * 2,
			p2 = alea:NextNumber() * math.pi * 2,
			v1 = 1.6 + alea:NextNumber() * 1.2, -- respiration lente
			v2 = 4.5 + alea:NextNumber() * 2.5, -- frémissement
		})
		return m
	end

	-- ===== 1. la promenade du Tapis =====
	local infoTapis = Plan.tapis
	if type(infoTapis) == "table" and typeof(infoTapis.debut) == "Vector3" and typeof(infoTapis.fin) == "Vector3"
		and type(Plan.bases) == "table" and type(Plan.base) == "table" then
		local dossierTapis = Outils.dossier(dossier, "Tapis")
		local yPiste = 0.8
		if type(infoTapis.hauteur) == "number" then
			yPiste = infoTapis.hauteur
		end
		local zBord = infoTapis.emprise or 9.5
		if type(Plan.promenade) == "table" and type(Plan.promenade.zMin) == "number" then
			zBord = Plan.promenade.zMin
		end
		local zTorche = zBord + R.retraitPromenade
		local xDebut = math.min(infoTapis.debut.X, infoTapis.fin.X)
		local xFin = math.max(infoTapis.debut.X, infoTapis.fin.X)
		local zAxe = (infoTapis.debut.Z + infoTapis.fin.Z) / 2
		local demiBase = (Plan.base.largeur or 44) / 2
		local decalage = (R.gardeEntree + demiBase) / 2 -- à mi-chemin entre le portique et le coin de la Base

		-- libre : ni dans le prolongement d'une allée, ni hors du Tapis (panneaux des bouts)
		local function libre(x)
			if x < xDebut + R.gardeBout or x > xFin - R.gardeBout then
				return false
			end
			if type(Plan.allees) == "table" and type(Plan.allees.x) == "table" then
				local demiAllee = (Plan.allees.largeur or 22) / 2 + R.gardeAllee
				for _, xa in ipairs(Plan.allees.x) do
					if math.abs(x - xa) < demiAllee then
						return false
					end
				end
			end
			for _, b in ipairs(Plan.bases) do
				if typeof(b.centre) == "Vector3" and math.abs(x - b.centre.X) < R.gardeEntree then
					return false
				end
			end
			return true
		end

		-- positions des torches de chaque côté (côté = signe de z des Bases)
		local cotes = { [-1] = {}, [1] = {} }
		local bords = { [-1] = { min = nil, max = nil }, [1] = { min = nil, max = nil } }
		for _, b in ipairs(Plan.bases) do
			if typeof(b.centre) == "Vector3" then
				local s = 1
				if b.centre.Z < zAxe then
					s = -1
				end
				table.insert(cotes[s], b.centre.X - decalage)
				table.insert(cotes[s], b.centre.X + decalage)
				local bd = bords[s]
				if bd.min == nil or b.centre.X - demiBase < bd.min then
					bd.min = b.centre.X - demiBase
				end
				if bd.max == nil or b.centre.X + demiBase > bd.max then
					bd.max = b.centre.X + demiBase
				end
			end
		end
		-- torches de bout de rangée, vers la Nurserie et la Grande Porte
		for s, bd in pairs(bords) do
			if bd.min then
				table.insert(cotes[s], math.max(bd.min - R.reculBout, xDebut + R.gardeBout))
				table.insert(cotes[s], math.min(bd.max + R.reculBout, xFin - R.gardeBout))
			end
		end

		for s, liste in pairs(cotes) do
			table.sort(liste)
			local nomCote = "Sud"
			if s < 0 then
				nomCote = "Nord"
			end
			local n = 0
			local dernier = nil
			for _, x in ipairs(liste) do
				-- pas de doublon (deux torches à moins de 4 studs) et rien sur un passage
				if libre(x) and (dernier == nil or x - dernier >= 4) then
					n = n + 1
					dernier = x
					-- une torche sur deux éclaire la piste (en quinconce entre le nord et le sud)
					local cible = nil
					if (n + (s > 0 and 1 or 0)) % 2 == 1 then
						cible = Vector3.new(x, yPiste, zAxe)
					end
					torche(dossierTapis, "Torche" .. nomCote .. n, x, zAxe + s * zTorche, 0, cible)
				end
			end
		end
	end

	-- ===== 2. autour de la Place =====
	local infoPlace = Plan.place
	if type(infoPlace) == "table" and typeof(infoPlace.centre) == "Vector3" and type(infoPlace.rayon) == "number" then
		local centre = infoPlace.centre
		local rayon = R.placeRayon
		if rayon <= 0 then
			rayon = infoPlace.rayon + 1
		end
		local dossierPlace = Outils.dossier(dossier, "Place")

		-- z des liens de sable vers le Comptoir (ouest) et l'Autel (est)
		local zLiens = {}
		for _, info in ipairs({ Plan.comptoir, Plan.autel }) do
			if type(info) == "table" and typeof(info.centre) == "Vector3" then
				table.insert(zLiens, info.centre.Z)
			end
		end
		-- vrai si une torche en (x, z) tomberait sur l'un de ces liens
		local function surLien(x, z)
			if math.abs(x - centre.X) <= rayon - R.retraitLien then
				return false
			end
			for _, zl in ipairs(zLiens) do
				if math.abs(z - zl) < R.demiLien + R.gardeLien then
					return true
				end
			end
			return false
		end
		-- écart angulaire (degrés, 0..180) entre deux directions
		local function ecart(a, b)
			local d = (a - b) % 360
			if d > 180 then
				d = 360 - d
			end
			return d
		end

		local angle = 0
		local k = 0
		local dejaPris = {}
		while angle < 360 - 0.01 do
			local deg = (angle + R.placeDecalage) % 360
			local pose = ecart(deg, R.angleClassement) >= R.demiClassement -- secteur du tableau d'honneur
			if pose and surLien(centre.X + math.cos(math.rad(deg)) * rayon, centre.Z + math.sin(math.rad(deg)) * rayon) then
				-- reportée vers le sud (90°) : 22,5° → 45°, 157,5° → 135°
				if math.sin(math.rad(deg)) >= 0 then
					if math.cos(math.rad(deg)) >= 0 then
						deg = deg + R.placeDecalage
					else
						deg = deg - R.placeDecalage
					end
				else
					if math.cos(math.rad(deg)) >= 0 then
						deg = deg - R.placeDecalage
					else
						deg = deg + R.placeDecalage
					end
				end
				deg = deg % 360
				pose = not surLien(centre.X + math.cos(math.rad(deg)) * rayon, centre.Z + math.sin(math.rad(deg)) * rayon)
					and ecart(deg, R.angleClassement) >= R.demiClassement
			end
			-- pas deux torches au même angle
			if pose then
				for _, d in ipairs(dejaPris) do
					if ecart(deg, d) < 5 then
						pose = false
					end
				end
			end
			if pose then
				table.insert(dejaPris, deg)
				k = k + 1
				local a = math.rad(deg)
				local cx, cz = math.cos(a), math.sin(a)
				-- chaque torche de la Place éclaire le pavage à mi-chemin du centre
				local cible = Vector3.new(centre.X + cx * rayon * 0.48, 0, centre.Z + cz * rayon * 0.48)
				torche(dossierPlace, "Torche" .. k, centre.X + cx * rayon, centre.Z + cz * rayon, 0, cible)
			end
			angle = angle + R.placePas
		end
	end

	dossier:SetAttribute("Parts", compte)
	dossier:SetAttribute("Torches", #lumieres)

	-- ===== 3. jour / nuit et vacillement =====
	local function estNuit()
		local ok, heure = pcall(function()
			return Lighting.ClockTime
		end)
		if not ok or type(heure) ~= "number" then
			return false
		end
		return heure < R.finNuit or heure > R.debutNuit
	end

	local nuit = estNuit()
	local eclat, eclatSpot = R.eclat, R.spotEclat
	if nuit then
		eclat, eclatSpot = R.eclatNuit, R.spotEclatNuit
	end

	-- portée et taille du feu : changées d'un coup (le feu grandit de lui-même) ; l'intensité suit en fondu
	local function appliquerNuit()
		local range, taille = R.portee, R.feu
		if nuit then
			range, taille = R.porteeNuit, R.feuNuit
		end
		for _, t in ipairs(lumieres) do
			if t.lumiere and t.lumiere.Parent then
				pcall(function()
					t.lumiere.Range = range
				end)
			end
			if t.feu and t.feu.Parent then
				pcall(function()
					t.feu.Size = taille
				end)
			end
		end
		dossier:SetAttribute("Nuit", nuit)
	end

	-- lumière qui vacille doucement : deux sinus décalés par torche (respiration + frémissement)
	local function vaciller(t, dt)
		local cible, cibleSpot = R.eclat, R.spotEclat
		if nuit then
			cible, cibleSpot = R.eclatNuit, R.spotEclatNuit
		end
		local k = math.min(1, dt / R.transition)
		eclat = eclat + (cible - eclat) * k
		eclatSpot = eclatSpot + (cibleSpot - eclatSpot) * k
		for _, l in ipairs(lumieres) do
			local f = 1 + R.vacille * (0.65 * math.sin(t * l.v1 + l.p1) + 0.35 * math.sin(t * l.v2 + l.p2))
			if l.lumiere and l.lumiere.Parent then
				l.lumiere.Brightness = eclat * f
			end
			if l.spot and l.spot.Parent then
				l.spot.Brightness = eclatSpot * (0.5 + 0.5 * f)
			end
		end
	end

	appliquerNuit()
	pcall(vaciller, maintenant(), R.transition)

	if #lumieres > 0 then
		task.spawn(function()
			local avant = maintenant()
			local depuisHeure = 0
			while dossier.Parent do
				task.wait(R.pasVacille)
				if not dossier.Parent then
					break
				end
				local t = maintenant()
				local dt = math.max(0, math.min(1, t - avant))
				avant = t
				depuisHeure = depuisHeure + dt
				if depuisHeure >= R.intervalle then
					depuisHeure = 0
					local n = estNuit()
					if n ~= nuit then
						nuit = n
						appliquerNuit()
					end
				end
				pcall(vaciller, t, dt)
			end
		end)
	end
end

return M
