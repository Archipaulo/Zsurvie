-- Constructeur Lumieres : torches cartoon (style simulateur, voir STYLE.md) qui balisent le Tapis
-- et entourent la Place. Formes simples et nettes, couleurs franches, SmoothPlastic partout,
-- Neon seulement pour la flamme.
-- Chaque torche : socle de pierre claire, fût de bambou vif, anneau sombre, coupe en bois,
-- flamme Neon orange vif surmontée d'une pointe jaune (animation « pulse » côté client),
-- feu et lumière chaude.
-- La nuit (Lighting.ClockTime < 6,5 ou > 18,5, vérifié toutes les 5 s), les torches brillent plus fort.
-- Emprise (CONTRAT §10) : le long du Tapis (z = ±8, tous les 32 studs de x = -104 à 104,
-- soit une position sur deux de la grille de 16) et autour de la Place (r = 23, tous les 45°,
-- décalées de 22,5° pour laisser les allées libres).
local M = {}

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local BUDGET = 200 -- parts au maximum pour ce constructeur
local PARTS_PAR_TORCHE = 6 -- 22 torches x 6 = 132 parts

-- valeurs par défaut, remplaçables par Equilibrage.lumieres
local DEFAUTS = {
	tapisZ = 8,             -- distance des torches à l'axe du Tapis
	tapisPas = 32,          -- écart entre deux torches le long du Tapis (moins nombreuses, plus lisibles)
	tapisDebutX = -104,
	tapisFinX = 104,
	placeRayon = 23,        -- rayon du cercle de torches autour de la Place
	placePas = 45,          -- écart angulaire (degrés)
	placeDecalage = 22.5,   -- décalage angulaire : les allées (axes) restent dégagées
	hauteur = 7,            -- hauteur du fût de bambou
	portee = 16,            -- portée de la lumière le jour
	porteeNuit = 26,        -- portée de la lumière la nuit
	eclat = 1.2,            -- intensité le jour
	eclatNuit = 3,          -- intensité la nuit
	feu = 2.5,              -- taille du feu le jour
	feuNuit = 4,            -- taille du feu la nuit
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
	if r.tapisPas < 1 then
		r.tapisPas = DEFAUTS.tapisPas
	end
	if r.placePas < 1 then
		r.placePas = DEFAUTS.placePas
	end
	if r.intervalle < 1 then
		r.intervalle = DEFAUTS.intervalle
	end
	return r
end

-- CFrame d'un cylindre vertical (l'axe d'un cylindre Roblox est X)
local function vertical(x, y, z)
	return CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.rad(90))
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	local compte = 0
	local lumieres = {} -- { lumiere = PointLight, feu = Fire }

	-- couleurs franches (palette de Style : orange et jaune des boutons, jaune des revenus)
	local orange = { Charte.lave, Charte.dore }
	local jaune = { Charte.dore, Charte.dore }
	local teinteRevenu = Charte.dore
	if Style and Style.boutons then
		orange = Style.boutons.orange or orange
		jaune = Style.boutons.jaune or jaune
	end
	if Style and Style.couleurs and Style.couleurs.revenu then
		teinteRevenu = Style.couleurs.revenu
	end
	local BAMBOU = jaune[1]:Lerp(Charte.sable, 0.45) -- bambou vif, bien lisible sur l'herbe
	local ANNEAU = Charte.ombre(Charte.bois)
	local PIED = Charte.lumiere(Charte.pierre) -- pierre claire pour les socles
	local COUPE = Charte.bois
	local FLAMME = Charte.lave:Lerp(orange[2], 0.35) -- orange vif
	local POINTE = teinteRevenu -- pointe jaune de la flamme
	local LUEUR = orange[1]:Lerp(teinteRevenu, 0.5)

	-- propriétés communes des parts de décor (rien ne gêne les joueurs ni les dinos)
	local function decor(props)
		props.CanCollide = false
		props.CanTouch = false
		props.CastShadow = false
		return props
	end

	local function torche(parent, nom, x, z, ySol)
		if compte + PARTS_PAR_TORCHE > BUDGET then
			return nil
		end
		compte = compte + PARTS_PAR_TORCHE
		local y0 = ySol or 0
		local h = R.hauteur
		local m = Outils.modele(parent, nom)

		-- socle rond de pierre claire (large et bas : silhouette « jouet »)
		Outils.cylindre(m, decor({
			Name = "Pied",
			Size = Vector3.new(0.8, 2.4, 2.4),
			CFrame = vertical(x, y0 + 0.4, z),
			Color = PIED,
		}))
		-- fût de bambou épais
		local fut = Outils.cylindre(m, decor({
			Name = "Bambou",
			Size = Vector3.new(h, 0.9, 0.9),
			CFrame = vertical(x, y0 + 0.8 + h / 2, z),
			Color = BAMBOU,
		}))
		m.PrimaryPart = fut
		-- anneau sombre sous la coupe (contour net, comme un trait noir de dessin animé)
		Outils.cylindre(m, decor({
			Name = "Ligature",
			Size = Vector3.new(0.45, 1.15, 1.15),
			CFrame = vertical(x, y0 + 0.8 + h * 0.82, z),
			Color = ANNEAU,
		}))
		-- coupe en bois au sommet, large
		local yCoupe = y0 + 0.8 + h + 0.45
		Outils.cylindre(m, decor({
			Name = "Coupe",
			Size = Vector3.new(0.9, 2.2, 2.2),
			CFrame = vertical(x, yCoupe, z),
			Color = COUPE,
		}))
		-- flamme Neon orange vif
		local flamme = Outils.boule(m, decor({
			Name = "Flamme",
			Size = Vector3.new(1.9, 1.9, 1.9),
			CFrame = CFrame.new(x, yCoupe + 1.05, z),
			Color = FLAMME,
			Material = Enum.Material.Neon,
			CanQuery = false,
		}))
		Outils.animer(flamme, "pulse", 1.5)
		-- pointe jaune au-dessus : flamme en deux tons, lisible de loin
		local pointe = Outils.boule(m, decor({
			Name = "Pointe",
			Size = Vector3.new(1.05, 1.05, 1.05),
			CFrame = CFrame.new(x, yCoupe + 2.2, z),
			Color = POINTE,
			Material = Enum.Material.Neon,
			CanQuery = false,
		}))
		Outils.animer(pointe, "pulse", 2)

		local feu = nil
		pcall(function()
			feu = Instance.new("Fire")
			feu.Color = FLAMME
			feu.SecondaryColor = POINTE
			feu.Size = R.feu
			feu.Heat = 6
			feu.Parent = flamme
		end)
		local lumiere = nil
		pcall(function()
			lumiere = Outils.lumiere(flamme, { genre = "Point", Range = R.portee, Brightness = R.eclat, Color = LUEUR })
			lumiere.Shadows = false
		end)
		table.insert(lumieres, { lumiere = lumiere, feu = feu })
		return m
	end

	-- ===== 1. le long du Tapis =====
	local tapis = Outils.dossier(dossier, "Tapis")
	local zTapis = R.tapisZ
	local x = R.tapisDebutX
	local n = 0
	while x <= R.tapisFinX + 0.01 do
		n = n + 1
		torche(tapis, "TorcheNord" .. n, x, -zTapis, 0)
		torche(tapis, "TorcheSud" .. n, x, zTapis, 0)
		x = x + R.tapisPas
	end

	-- ===== 2. autour de la Place =====
	local infoPlace = Plan.place or {}
	local centre = infoPlace.centre or Vector3.new(0, 0, 100)
	local place = Outils.dossier(dossier, "Place")
	local angle = 0
	local k = 0
	while angle < 360 - 0.01 do
		k = k + 1
		local a = math.rad(angle + R.placeDecalage)
		torche(place, "Torche" .. k, centre.X + math.cos(a) * R.placeRayon, centre.Z + math.sin(a) * R.placeRayon, 0)
		angle = angle + R.placePas
	end

	dossier:SetAttribute("Parts", compte)

	-- ===== 3. jour / nuit =====
	local function estNuit()
		local ok, heure = pcall(function()
			return Lighting.ClockTime
		end)
		if not ok or type(heure) ~= "number" then
			return false
		end
		return heure < R.finNuit or heure > R.debutNuit
	end

	local function appliquer(nuit, instantane)
		local range, eclat, taille = R.portee, R.eclat, R.feu
		if nuit then
			range, eclat, taille = R.porteeNuit, R.eclatNuit, R.feuNuit
		end
		local info = TweenInfo.new(R.transition, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		for _, t in ipairs(lumieres) do
			if t.lumiere and t.lumiere.Parent then
				local fait = false
				if not instantane then
					fait = pcall(function()
						TweenService:Create(t.lumiere, info, { Range = range, Brightness = eclat }):Play()
					end)
				end
				if not fait then
					pcall(function()
						t.lumiere.Range = range
						t.lumiere.Brightness = eclat
					end)
				end
			end
			if t.feu and t.feu.Parent then
				pcall(function()
					t.feu.Size = taille
				end)
			end
		end
		dossier:SetAttribute("Nuit", nuit)
	end

	local nuitActuelle = estNuit()
	appliquer(nuitActuelle, true)

	task.spawn(function()
		while dossier.Parent do
			task.wait(R.intervalle)
			if not dossier.Parent then
				break
			end
			local nuit = estNuit()
			if nuit ~= nuitActuelle then
				nuitActuelle = nuit
				appliquer(nuit, false)
			end
		end
	end)
end

return M
