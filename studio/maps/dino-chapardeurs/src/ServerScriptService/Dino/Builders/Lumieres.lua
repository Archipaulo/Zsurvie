-- Constructeur Lumieres : torches tiki en bambou qui balisent le Tapis et entourent la Place.
-- Chaque torche : pied de pierre, fût de bambou ligaturé, coupe en bois,
-- flamme Neon qui palpite (animation « pulse » côté client), feu et lumière chaude.
-- La nuit (Lighting.ClockTime < 6,5 ou > 18,5, vérifié toutes les 5 s), les torches brillent plus fort.
-- Emprise (CONTRAT §10) : le long du Tapis (z = ±8, tous les 16 studs de x = -104 à 104)
-- et autour de la Place (r = 23, tous les 45°, décalées de 22,5° pour laisser les allées libres).
local M = {}

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local BUDGET = 200 -- parts au maximum pour ce constructeur
local PARTS_PAR_TORCHE = 5 -- 36 torches x 5 = 180 parts

-- valeurs par défaut, remplaçables par Equilibrage.lumieres
local DEFAUTS = {
	tapisZ = 8,             -- distance des torches à l'axe du Tapis
	tapisPas = 16,          -- écart entre deux torches le long du Tapis
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
	local dossier = ctx.dossier
	local R = lireReglages(ctx)

	local compte = 0
	local lumieres = {} -- { lumiere = PointLight, feu = Fire }

	-- couleurs
	local BAMBOU = Charte.lumiere(Charte.sable)
	local LIGATURE = Charte.bois
	local PIED = Charte.pierre
	local COUPE = Charte.ombre(Charte.bois)
	local FLAMME = Charte.lave
	local LUEUR = Charte.lumiere(Charte.dore)

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

		-- pied de pierre
		Outils.bloc(m, decor({
			Name = "Pied",
			Size = Vector3.new(1.8, 0.6, 1.8),
			CFrame = Outils.surSol(Vector3.new(1.8, 0.6, 1.8), x, z, 45, y0),
			Color = PIED,
		}))
		-- fût de bambou
		local fut = Outils.cylindre(m, decor({
			Name = "Bambou",
			Size = Vector3.new(h, 0.7, 0.7),
			CFrame = vertical(x, y0 + 0.6 + h / 2, z),
			Color = BAMBOU,
		}))
		m.PrimaryPart = fut
		-- ligature de corde sous la coupe
		Outils.cylindre(m, decor({
			Name = "Ligature",
			Size = Vector3.new(0.3, 0.85, 0.85),
			CFrame = vertical(x, y0 + 0.6 + h * 0.8, z),
			Color = LIGATURE,
		}))
		-- coupe en bois au sommet
		local yCoupe = y0 + 0.6 + h + 0.4
		Outils.cylindre(m, decor({
			Name = "Coupe",
			Size = Vector3.new(0.8, 1.6, 1.6),
			CFrame = vertical(x, yCoupe, z),
			Color = COUPE,
		}))
		-- flamme Neon
		local flamme = Outils.boule(m, decor({
			Name = "Flamme",
			Size = Vector3.new(1.3, 1.3, 1.3),
			CFrame = CFrame.new(x, yCoupe + 0.8, z),
			Color = FLAMME,
			Material = Enum.Material.Neon,
			CanQuery = false,
		}))
		Outils.animer(flamme, "pulse", 1.5)

		local feu = nil
		pcall(function()
			feu = Instance.new("Fire")
			feu.Color = Charte.lave
			feu.SecondaryColor = Charte.dore
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
