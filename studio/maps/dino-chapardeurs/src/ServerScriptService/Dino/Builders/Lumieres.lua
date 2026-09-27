-- Constructeur Lumieres (version 2, STYLE.md §4) : torches tiki soignées qui balisent le Tapis
-- et entourent la Place.
-- Chaque torche (9 parts) : socle de pavés (Cobblestone), fût de bambou (Wood) à deux nœuds,
-- ligature de corde (Fabric), vasque de fer en deux étages (Metal), flamme Neon orange surmontée
-- d'une pointe jaune (animation « pulse » côté client), Fire et PointLight à ombres (Range 16).
-- SpotLight décoratifs : les torches de la Place éclairent le cœur de la Place, une torche sur deux
-- du Tapis éclaire la piste des dinos. Aucune part de plus : le projecteur est porté par la pointe,
-- orientée vers sa cible.
-- La nuit (Lighting.ClockTime < 6,5 ou > 18,5, vérifié toutes les 5 s), les torches brillent plus fort.
-- Emprise (CONTRAT §10) : le long du Tapis, en retrait dans le couloir entre les rebords (|z| ≤ 7)
-- et les entrées des Bases (|z| = 18) : z = ±12, tous les 32 studs de x = -88 à 104 (décalées d'un
-- demi-pas pour tomber hors des entrées). La flamme, basse (fût de 5,8), reste sous la ligne des
-- yeux du joueur qui achète : elle ne masque ni les dinos ni leurs étiquettes, et le projecteur
-- vise la bande (z = 0). Autour de la Place : r = 23, tous les 45°, décalées de 22,5° pour laisser
-- les allées libres.
local M = {}

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local BUDGET = 200 -- parts au maximum pour ce constructeur
local PARTS_PAR_TORCHE = 9 -- 22 torches x 9 = 198 parts

-- valeurs par défaut, remplaçables par Equilibrage.lumieres
local DEFAUTS = {
	tapisZ = 12,            -- distance des torches à l'axe du Tapis (couloir 7..18, derrière l'acheteur)
	tapisPas = 32,          -- écart entre deux torches le long du Tapis
	tapisDebutX = -88,      -- demi-pas de décalage : les torches évitent les entrées des Bases
	tapisFinX = 104,
	placeRayon = 23,        -- rayon du cercle de torches autour de la Place
	placePas = 45,          -- écart angulaire (degrés)
	placeDecalage = 22.5,   -- décalage angulaire : les allées (axes) restent dégagées
	hauteur = 5.8,          -- hauteur du fût de bambou (flamme sous la ligne des yeux)
	portee = 16,            -- portée de la lumière le jour
	porteeNuit = 16,        -- portée de la lumière la nuit
	eclat = 0.9,            -- intensité le jour
	eclatNuit = 2.4,        -- intensité la nuit
	feu = 2.2,              -- taille du feu le jour
	feuNuit = 3.4,          -- taille du feu la nuit
	spotPortee = 20,        -- portée des projecteurs décoratifs
	spotAngle = 55,         -- ouverture des projecteurs (degrés)
	spotEclat = 0.3,        -- intensité des projecteurs le jour
	spotEclatNuit = 1.6,    -- intensité des projecteurs la nuit
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
	local lumieres = {} -- { lumiere = PointLight, feu = Fire, spot = SpotLight ou nil }

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
		Outils.animer(flamme, "pulse", 1.5)
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
		Outils.animer(pointe, "pulse", 2)

		local feu = nil
		pcall(function()
			feu = Instance.new("Fire")
			feu.Color = FLAMME
			feu.SecondaryColor = POINTE
			feu.Size = R.feu
			feu.Heat = 7
			feu.Parent = flamme
		end)
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
		table.insert(lumieres, { lumiere = lumiere, feu = feu, spot = spot })
		return m
	end

	-- ===== 1. le long du Tapis =====
	local tapis = Outils.dossier(dossier, "Tapis")
	local zTapis = R.tapisZ
	local yPiste = 0.8
	if Plan.tapis and type(Plan.tapis.hauteur) == "number" then
		yPiste = Plan.tapis.hauteur
	end
	local x = R.tapisDebutX
	local n = 0
	while x <= R.tapisFinX + 0.01 do
		n = n + 1
		-- une torche sur deux éclaire la piste (en quinconce entre le nord et le sud)
		local cibleNord = nil
		local cibleSud = nil
		if n % 2 == 1 then
			cibleNord = Vector3.new(x + 6, yPiste, 0)
		else
			cibleSud = Vector3.new(x + 6, yPiste, 0)
		end
		torche(tapis, "TorcheNord" .. n, x, -zTapis, 0, cibleNord)
		torche(tapis, "TorcheSud" .. n, x, zTapis, 0, cibleSud)
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
		local cx, cz = math.cos(a), math.sin(a)
		-- chaque torche de la Place éclaire le pavage à mi-chemin du centre
		local cible = Vector3.new(centre.X + cx * 11, 0, centre.Z + cz * 11)
		torche(place, "Torche" .. k, centre.X + cx * R.placeRayon, centre.Z + cz * R.placeRayon, 0, cible)
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

	-- règle une lumière (fondu si possible, sinon directement)
	local function regler(l, info, range, eclat)
		if not l or not l.Parent then
			return
		end
		local fait = false
		if info then
			fait = pcall(function()
				TweenService:Create(l, info, { Range = range, Brightness = eclat }):Play()
			end)
		end
		if not fait then
			pcall(function()
				l.Range = range
				l.Brightness = eclat
			end)
		end
	end

	local function appliquer(nuit, instantane)
		local range, eclat, taille, eclatSpot = R.portee, R.eclat, R.feu, R.spotEclat
		if nuit then
			range, eclat, taille, eclatSpot = R.porteeNuit, R.eclatNuit, R.feuNuit, R.spotEclatNuit
		end
		local info = nil
		if not instantane then
			info = TweenInfo.new(R.transition, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		end
		for _, t in ipairs(lumieres) do
			regler(t.lumiere, info, range, eclat)
			regler(t.spot, info, R.spotPortee, eclatSpot)
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
