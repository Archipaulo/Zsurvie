-- Builders/Signaletique.lua
-- Panneaux de la Prairie (bords du parvis) et panneaux indicateurs de l'île du Laboratoire
-- (anneau 6..10 autour du point d'apparition, chacun pointé vers sa zone).
-- Budget : 120 parts (utilisé : 3 x 2 sur la Prairie + 7 x 3 sur l'île = 27).
local M = {}

local BUDGET = 120

-- écart maximal (degrés) entre l'orientation idéale d'une flèche et la face tournée vers le parvis
local ECART_MAX_FLECHE = 35
-- écart angulaire minimal (degrés) entre deux panneaux voisins de l'île
local ECART_MIN_ILE = 22
-- rayons alternés dans l'anneau 6..10 autour du spawn
local RAYONS_ILE = { 6.5, 8 }
local LONGUEUR_PLANCHE_ILE = 4.5
local HAUTEUR_PLANCHE = 5

-- ramène un angle en degrés dans ]-180, 180]
local function normaliser(a)
	local r = a % 360
	if r > 180 then
		r = r - 360
	end
	return r
end

-- angle (degrés, autour de Y) pour que l'axe X local de la part pointe dans la direction (dx, dz)
local function angleAxeX(dx, dz)
	return math.deg(math.atan2(-dz, dx))
end

-- angle (degrés) pour que la face avant (-Z local) regarde dans la direction (dx, dz)
local function angleFace(dx, dz)
	return math.deg(math.atan2(-dx, -dz))
end

-- limite l'angle à ± ecart autour de l'angle de base
local function borner(angle, base, ecart)
	local d = normaliser(angle - base)
	if d > ecart then
		d = ecart
	elseif d < -ecart then
		d = -ecart
	end
	return base + d
end

-- remplace le texte affiché sur la face arrière d'une planche (flèche inversée vue de dos)
local function texteArriere(modele, texte)
	local planche = modele:FindFirstChild("Planche")
	if not planche then
		return
	end
	for _, enfant in ipairs(planche:GetChildren()) do
		if enfant:IsA("SurfaceGui") and enfant.Face == Enum.NormalId.Back then
			local etiquette = enfant:FindFirstChildOfClass("TextLabel")
			if etiquette then
				etiquette.Text = texte
			end
		end
	end
end

-- couleur de texte lisible sur un fond donné
local function texteSur(C, fond)
	local clair = 0.299 * fond.R + 0.587 * fond.G + 0.114 * fond.B
	if clair > 0.55 then
		return C.encre
	end
	return C.creme
end

-- ===== Prairie : 3 panneaux au bord du parvis =====
local function construirePrairie(ctx, dossier, compteur)
	local C, O, P = ctx.Charte, ctx.Outils, ctx.Plan
	local parvis = P.parvis
	if not parvis or not parvis.centre or not parvis.taille then
		warn("[Zsurvie] Signaletique : Plan.parvis absent, panneaux de la Prairie ignorés")
		return
	end
	local c, t = parvis.centre, parvis.taille
	local ySol = c.Y
	local bordNord = c.Z - t.Z / 2 - 0.5
	local bordEst = c.X + t.X / 2 + 0.5

	-- les survivants sur le parvis regardent la Maison (vers -Z) : les panneaux leur font face
	local baseFace = angleFace(0, 1)

	-- « ← Établi » : coin nord-ouest, la flèche (axe +X local vu de face) vise l'Établi
	if P.etabli and P.etabli.centre then
		local pos = Vector3.new(c.X - 6.5, ySol, bordNord)
		local cible = P.etabli.centre
		local angle = borner(angleAxeX(cible.X - pos.X, cible.Z - pos.Z), baseFace, ECART_MAX_FLECHE)
		local ok, m = pcall(O.panneau, dossier, {
			nom = "PanneauEtabli",
			position = pos,
			texte = "← Établi",
			angle = angle,
			largeur = 6,
			couleur = C.creme,
			couleurTexte = C.encre,
		})
		if ok and m then
			texteArriere(m, "Établi →")
			compteur.n = compteur.n + 2
		end
	end

	-- « Mine → » : coin nord-est, la flèche (axe -X local vu de face) vise la Mine
	if P.mine and P.mine.centre then
		local pos = Vector3.new(c.X + 6.5, ySol, bordNord)
		local cible = P.mine.centre
		local angle = borner(angleAxeX(pos.X - cible.X, pos.Z - cible.Z), baseFace, ECART_MAX_FLECHE)
		local ok, m = pcall(O.panneau, dossier, {
			nom = "PanneauMine",
			position = pos,
			texte = "Mine →",
			angle = angle,
			largeur = 6,
			couleur = C.lumiere(C.gemme),
			couleurTexte = C.encre,
		})
		if ok and m then
			texteArriere(m, "← Mine")
			compteur.n = compteur.n + 2
		end
	end

	-- « Protégez la Maison ! » : bord est, face tournée vers le centre du parvis
	local pos = Vector3.new(bordEst, ySol, c.Z + 1)
	local ok, m = pcall(O.panneau, dossier, {
		nom = "PanneauMaison",
		position = pos,
		texte = "Protégez la Maison !",
		angle = angleFace(c.X - pos.X, c.Z - pos.Z),
		largeur = 7,
		couleur = C.toit,
		couleurTexte = C.creme,
	})
	if ok and m then
		compteur.n = compteur.n + 2
	end
end

-- ===== Île : un panneau indicateur par zone autour du spawn =====
local function construireIle(ctx, dossier, compteur)
	local C, O, P = ctx.Charte, ctx.Outils, ctx.Plan
	local lobby = P.lobby
	if not lobby or not lobby.spawn then
		warn("[Zsurvie] Signaletique : Plan.lobby.spawn absent, panneaux de l'île ignorés")
		return
	end
	local spawn = lobby.spawn

	local zones = {
		{ cle = "laboratoire", texte = "🔬 Laboratoire", couleur = C.gemme },
		{ cle = "quai", texte = "🚀 Capsules", couleur = C.toit },
		{ cle = "galerie", texte = "👾 Galerie", couleur = C.violet },
		{ cle = "parcours", texte = "🏃 Parcours", couleur = C.prairie },
		{ cle = "enigme", texte = "🧩 Énigme", couleur = C.nuitLabo },
		{ cle = "records", texte = "🏆 Records", couleur = C.dore },
		{ cle = "scenePhoto", texte = "📸 Photo", couleur = C.alerte },
	}

	-- cap (degrés, dans le plan XZ) de chaque zone vue depuis le spawn
	local liste = {}
	for _, z in ipairs(zones) do
		local cible = lobby[z.cle]
		if typeof(cible) == "Vector3" then
			local dx, dz = cible.X - spawn.X, cible.Z - spawn.Z
			if dx * dx + dz * dz > 0.01 then
				z.cible = cible
				z.cap = math.deg(math.atan2(dz, dx))
				table.insert(liste, z)
			end
		end
	end
	if #liste == 0 then
		return
	end

	-- écarte les panneaux voisins, puis recentre l'ensemble sur les caps d'origine
	table.sort(liste, function(a, b)
		if a.cap == b.cap then
			return a.cle < b.cle
		end
		return a.cap < b.cap
	end)
	for i, z in ipairs(liste) do
		z.capPose = z.cap
		if i > 1 and z.capPose - liste[i - 1].capPose < ECART_MIN_ILE then
			z.capPose = liste[i - 1].capPose + ECART_MIN_ILE
		end
	end
	local decalage = 0
	for _, z in ipairs(liste) do
		decalage = decalage + (z.capPose - z.cap)
	end
	decalage = decalage / #liste

	for i, z in ipairs(liste) do
		if compteur.n + 3 > BUDGET then
			break
		end
		local cap = math.rad(z.capPose - decalage)
		local rayon = RAYONS_ILE[((i - 1) % #RAYONS_ILE) + 1]
		local pos = Vector3.new(spawn.X + math.cos(cap) * rayon, spawn.Y, spawn.Z + math.sin(cap) * rayon)

		-- direction réelle du poteau vers la zone
		local dx, dz = z.cible.X - pos.X, z.cible.Z - pos.Z
		local longueur = math.sqrt(dx * dx + dz * dz)
		if longueur < 0.01 then
			dx, dz, longueur = math.cos(cap), math.sin(cap), 1
		end
		local ux, uz = dx / longueur, dz / longueur
		local angle = angleAxeX(ux, uz)
		local rotation = CFrame.Angles(0, math.rad(angle), 0)

		local ok, m = pcall(O.panneau, dossier, {
			nom = "Indicateur_" .. z.cle,
			position = pos,
			texte = z.texte,
			angle = angle,
			largeur = LONGUEUR_PLANCHE_ILE,
			couleur = z.couleur,
			couleurTexte = texteSur(C, z.couleur),
		})
		if ok and m then
			compteur.n = compteur.n + 2
			local y = pos.Y + HAUTEUR_PLANCHE
			local decal = LONGUEUR_PLANCHE_ILE / 2 + 0.3
			local planche = m:FindFirstChild("Planche")
			if planche and planche:IsA("BasePart") then
				-- la planche part du poteau et s'étend vers la zone, comme un poteau indicateur
				planche.CFrame = CFrame.new(pos.X + ux * decal, y, pos.Z + uz * decal) * rotation
				planche.CanCollide = false
			end
			-- pointe en losange au bout de la planche
			local bout = LONGUEUR_PLANCHE_ILE + 0.3
			local okP, pointe = pcall(O.bloc, m, {
				Name = "Pointe",
				Size = Vector3.new(1.4, 1.4, 0.4),
				CFrame = CFrame.new(pos.X + ux * bout, y, pos.Z + uz * bout) * rotation * CFrame.Angles(0, 0, math.rad(45)),
				Color = C.ombre(z.couleur),
				CanCollide = false,
			})
			if okP and pointe then
				compteur.n = compteur.n + 1
			end
		end
	end
end

function M.construire(ctx)
	if not ctx or not ctx.Outils or not ctx.Charte or not ctx.Plan or not ctx.dossier then
		warn("[Zsurvie] Signaletique : contexte incomplet")
		return
	end
	local compteur = { n = 0 }

	local prairie = ctx.Outils.dossier(ctx.dossier, "Prairie")
	local ok, err = pcall(construirePrairie, ctx, prairie, compteur)
	if not ok then
		warn("[Zsurvie] Signaletique (Prairie) : " .. tostring(err))
	end

	local ile = ctx.Outils.dossier(ctx.dossier, "Ile")
	ok, err = pcall(construireIle, ctx, ile, compteur)
	if not ok then
		warn("[Zsurvie] Signaletique (île) : " .. tostring(err))
	end

	ctx.dossier:SetAttribute("Parts", compteur.n)
end

return M
