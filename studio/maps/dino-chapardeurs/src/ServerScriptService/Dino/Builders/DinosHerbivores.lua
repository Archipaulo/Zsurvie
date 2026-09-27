-- Constructeur DinosHerbivores : gabarits des espèces de la famille « Herbivore »,
-- rangés dans ServerStorage.Dino.Dinos (clonés ensuite par Systemes/Tapis).
-- Style « chibi » de simulateur Roblox, version 2 : formes organiques en boules et cylindres
-- (corps ovale en deux boules, cou et queue en segments dégressifs), grosse tête ronde,
-- yeux brillants (blanc + iris + reflets Neon), museau et ventre plus clairs, joues roses,
-- motifs (taches, rayures), trois teintes par couleur (base, ombre, lumière).
-- Regard vers -Z local, pivot au sol sous le dino. Au plus 40 parts par gabarit.
local M = {}

local BUDGET = 40 -- parts maximum par gabarit
local V = Vector3.new

-- vecteur unitaire (jamais nul)
local function unite(v)
	local m = math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
	if m < 1e-6 then
		return V(0, 1, 0)
	end
	return V(v.X / m, v.Y / m, v.Z / m)
end

-- fabrique d'un gabarit : renvoie un petit outil de construction à l'échelle s
local function nouvelOutil(ctx, modele, s)
	local Outils = ctx.Outils
	local Charte = ctx.Charte
	local Style = ctx.Style
	local hex = Charte.hex
	local g = { n = 0, s = s, modele = modele }

	-- teintes communes du style chibi
	g.blanc = hex("FFFFFF")
	g.iris = hex("2A1B3D")
	g.rose = hex("FF8FB1")
	g.narine = hex("3A2A3F")
	g.hex = hex

	-- couleur d'accent d'une rareté, prise dans les dégradés de Style (bas du dégradé = plus saturé)
	function g.accent(rarete, clair)
		local def = Style and Style.raretes and Style.raretes[rarete]
		if def and def[1] and def[2] then
			if clair then
				return def[1]
			end
			return def[2]
		end
		return Charte.raretes[rarete] or Charte.violet
	end

	-- ventre : crème teinté de la couleur du dino (plus clair que le corps)
	function g.ventre(base)
		return base:Lerp(g.blanc, 0.55)
	end

	-- pose une part ; t et cf à l'échelle 1 (la position est mise à l'échelle, pas la rotation)
	function g.poser(forme, nom, t, cf, couleur, neon)
		if g.n >= BUDGET then
			return nil
		end
		local props = {
			Name = nom,
			Size = t * s,
			CFrame = CFrame.new(cf.Position * s) * cf.Rotation,
			Color = couleur or Charte.creme,
			CanCollide = false,
			CanQuery = true,
			CanTouch = false,
		}
		if neon then
			props.Material = Enum.Material.Neon
		end
		local fabrique = Outils.bloc
		if forme == "coin" then
			fabrique = Outils.coin
		elseif forme == "boule" then
			fabrique = Outils.boule
		elseif forme == "cyl" then
			fabrique = Outils.cylindre
		end
		local ok, part = pcall(fabrique, modele, props)
		if ok and part then
			g.n = g.n + 1
			return part
		end
		return nil
	end

	-- forme : "bloc", "coin", "boule" ou "cyl" ; pos à l'échelle 1 ; rot en degrés
	function g.p(forme, nom, t, pos, couleur, rot, neon)
		local cf = CFrame.new(pos)
		if rot then
			cf = cf * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
		return g.poser(forme, nom, t, cf, couleur, neon)
	end

	-- boule de diamètre d
	function g.boule(nom, d, pos, couleur, neon)
		return g.poser("boule", nom, V(d, d, d), CFrame.new(pos), couleur, neon)
	end

	-- cylindre de diamètre d tendu entre les points a et b
	function g.os(nom, a, b, d, couleur, neon)
		local dir = b - a
		local long = dir.Magnitude
		if long < 0.01 then
			return nil
		end
		local haut = V(0, 1, 0)
		if math.abs(dir.Y) > long * 0.95 then
			haut = V(0, 0, -1)
		end
		local cf = CFrame.lookAt(a + dir * 0.5, b, haut) * CFrame.Angles(0, math.rad(90), 0)
		return g.poser("cyl", nom, V(long, d, d), cf, couleur, neon)
	end

	-- chaîne de boules dégressives (cou, queue, crête) ; la dernière peut avoir sa propre couleur
	function g.chaine(nom, points, diametres, couleur, couleurBout, neonBout)
		local premiere
		for i, pt in ipairs(points) do
			local c = couleur
			local neon = false
			if i == #points and couleurBout then
				c = couleurBout
				neon = neonBout
			end
			local suffixe = ""
			if i > 1 then
				suffixe = tostring(i)
			end
			local part = g.boule(nom .. suffixe, diametres[i], pt, c, neon)
			if i == 1 then
				premiere = part
			end
		end
		return premiere
	end

	-- tube dégressif (queue, cou) : cylindres de plus en plus fins reliés par des rotules en boule,
	-- terminé par une boule (dBout, couleurBout) sauf si sansBout ; renvoie le premier segment et le bout
	function g.queue(nom, points, diametres, couleur, couleurBout, neonBout, dBout, sansBout)
		local k = 0
		local function nomSuivant()
			k = k + 1
			if k == 1 then
				return nom
			end
			return nom .. k
		end
		local premiere
		for i = 1, #points - 1 do
			local part = g.os(nomSuivant(), points[i], points[i + 1], diametres[i], couleur)
			if i == 1 then
				premiere = part
			end
			if i < #points - 1 then
				g.boule(nomSuivant(), diametres[i], points[i + 1], couleur)
			end
		end
		local bout
		if not sansBout then
			bout = g.boule(nom .. "Bout", dBout or diametres[#diametres], points[#points], couleurBout or couleur, neonBout)
		end
		return premiere, bout
	end

	-- yeux brillants sur une tête ronde (centre c, rayon R) : blanc, gros iris sombre, deux reflets Neon.
	-- d = diamètre du blanc ; ecart et haut orientent les yeux (vers l'avant et un peu sur les côtés)
	function g.yeux(c, R, d, ecart, haut)
		for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
			local sens = cote[2]
			local dir = unite(V(sens * ecart, haut, -1))
			local regard = unite(V(sens * ecart * 0.75, haut * 0.6, -1))
			local pBlanc = c + dir * (R - 0.24 * d)
			g.boule("Oeil" .. cote[1], d, pBlanc, g.blanc)
			local pIris = pBlanc + regard * (0.12 * d)
			g.boule("Iris" .. cote[1], d * 0.84, pIris, g.iris)
			local dirReflet = unite(regard + V(-sens * 0.35, 0.6, 0))
			g.boule("Reflet" .. cote[1], d * 0.22, pIris + dirReflet * (0.37 * d), g.blanc, true)
			local dirPetit = unite(regard + V(sens * 0.3, -0.5, 0))
			g.boule("Eclat" .. cote[1], d * 0.11, pIris + dirPetit * (0.4 * d), g.blanc)
		end
	end

	-- joues roses posées sur la tête (sous les yeux, un peu sur les côtés)
	function g.joues(c, R, d, ecart, haut)
		for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
			local dir = unite(V(cote[2] * ecart, haut, -1))
			g.boule("Joue" .. cote[1], d, c + dir * (R - 0.2 * d), g.rose)
		end
	end

	-- deux narines sombres sur le bout du museau (centre c, rayon R)
	function g.narines(c, R, d)
		for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
			local dir = unite(V(cote[2] * 0.32, 0.35, -1))
			g.boule("Narine" .. cote[1], d, c + dir * (R - 0.15 * d), g.narine)
		end
	end

	-- tache ronde affleurant une boule (centre c, rayon R) dans la direction dir
	function g.tache(nom, c, R, dir, d, couleur)
		return g.boule(nom, d, c + unite(dir) * (R - 0.32 * d), couleur)
	end

	-- rayure : anneau autour d'une boule (centre c, diamètre D), décalé de dz le long de Z
	function g.rayure(nom, c, D, dz, ep, couleur)
		local r = D / 2
		local corde = 2 * math.sqrt(math.max(r * r - dz * dz, 0.01)) + 0.06
		local cf = CFrame.new(c + V(0, 0, dz)) * CFrame.Angles(0, math.rad(90), 0)
		return g.poser("cyl", nom, V(ep, corde, corde), cf, couleur)
	end

	-- paire de pattes posées au sol : jambe (cylindre) de la hanche au pied, pied en boule.
	-- suffixe : "Av" ou "Ar" ; x, z : position du pied ; yHanche : hauteur de la hanche
	function g.pattes(suffixe, x, yHanche, z, d, dPied, couleur, couleurPied, zHanche)
		for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
			local sens = cote[2]
			local pied = V(sens * x, dPied / 2, z)
			g.os("Patte" .. suffixe .. cote[1], V(sens * x * 1.04, yHanche, zHanche or (z + 0.2)), pied, d, couleur)
			g.boule("Pied" .. suffixe .. cote[1], dPied, pied - V(0, 0, 0.12), couleurPied or couleur)
		end
	end

	-- cuisses rondes des bipèdes
	function g.cuisses(x, y, z, d, couleur)
		for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
			g.boule("Cuisse" .. cote[1], d, V(cote[2] * x, y, z), couleur)
		end
	end

	-- petits bras des bipèdes (PatteAvG/D) : de l'épaule à la main (boule)
	function g.bras(epaule, main, d, dMain, couleur)
		for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
			local sens = cote[2]
			local a = V(sens * epaule.X, epaule.Y, epaule.Z)
			local b = V(sens * main.X, main.Y, main.Z)
			g.os("PatteAv" .. cote[1], a, b, d, couleur)
			g.boule("Main" .. cote[1], dMain, b, couleur)
		end
	end

	-- lumière douce attachée au corps (raretés hautes)
	function g.lueur(corps, couleur, portee, intensite)
		if not corps then
			return
		end
		pcall(function()
			Outils.lumiere(corps, { genre = "Point", Range = portee * s, Brightness = intensite, Color = couleur })
		end)
	end

	return g
end

-- ===== les espèces =====
-- chaque fonction construit le dino à l'échelle 1 (le sol est à Y = 0) et renvoie la part « Corps »
local ESPECES = {}

-- Galli : petit coureur bipède jaune-orangé, crête rouge, bec orange, taches brunes (36 parts)
ESPECES.Galli = function(g, C)
	local base = g.hex("FFB23F")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local rouge = g.hex("FF4F5E")
	local orange = g.hex("FF8A1F")
	local cCorps = V(0, 2.3, 0.3)
	local corps = g.boule("Corps", 2.3, cCorps, base)
	g.boule("Ventre", 1.8, V(0, 2.1, -0.2), g.ventre(base))
	g.boule("Cou", 1.3, V(0, 3.35, -0.45), base)
	local cTete = V(0, 4.5, -0.8)
	g.boule("Tete", 2.4, cTete, base)
	g.boule("Museau", 1.2, V(0, 4.0, -1.7), clair)
	g.boule("Bec", 0.75, V(0, 3.95, -2.25), orange)
	g.yeux(cTete, 1.2, 0.95, 0.62, 0.22)
	g.joues(cTete, 1.2, 0.42, 0.85, -0.3)
	g.chaine("Crete", { V(0, 5.75, -0.95), V(0, 5.62, -0.35), V(0, 5.35, 0.15) }, { 0.75, 0.6, 0.45 }, rouge)
	g.queue("Queue", { V(0, 2.45, 1.0), V(0, 2.85, 2.2), V(0, 3.35, 3.2) }, { 1.0, 0.72 }, base, rouge, false, 0.8)
	g.tache("Tache1", cCorps, 1.15, V(-0.6, 0.7, 0.4), 0.6, ombre)
	g.tache("Tache2", cCorps, 1.15, V(0.6, 0.7, 0.4), 0.6, ombre)
	g.tache("Tache3", cCorps, 1.15, V(0, 0.8, 0.7), 0.5, ombre)
	g.cuisses(0.7, 1.75, 0.45, 1.1, base)
	g.pattes("Ar", 0.6, 1.6, 0.05, 0.45, 0.66, orange, orange, 0.4)
	g.bras(V(0.85, 2.6, -0.5), V(1.05, 2.2, -1.0), 0.35, 0.45, base)
	return corps
end

-- Pachy : bipède trapu bleu ciel, gros dôme jaune cerclé de bosses violettes, taches (39 parts)
ESPECES.Pachy = function(g, C)
	local base = g.hex("5BC0FF")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local dome = g.hex("FFD166")
	local bosse = g.hex("B15CFF")
	local cCorps = V(0, 2.5, 0.3)
	local corps = g.boule("Corps", 2.8, cCorps, base)
	g.boule("Ventre", 2.1, V(0, 2.3, -0.3), g.ventre(base))
	local cTete = V(0, 4.45, -0.55)
	g.boule("Tete", 2.5, cTete, base)
	local cDome = V(0, 5.3, -0.4)
	g.boule("Dome", 2.2, cDome, dome)
	local dirs = { V(-0.9, -0.3, -0.4), V(0.9, -0.3, -0.4), V(-0.8, -0.3, 0.6), V(0.8, -0.3, 0.6), V(0, -0.2, 1) }
	for i, dir in ipairs(dirs) do
		g.tache("Bosse" .. i, cDome, 1.1, dir, 0.5, bosse)
	end
	local cMuseau = V(0, 3.95, -1.55)
	g.boule("Museau", 1.35, cMuseau, clair)
	g.narines(cMuseau, 0.675, 0.16)
	g.yeux(cTete, 1.25, 0.95, 0.6, 0.12)
	g.joues(cTete, 1.25, 0.45, 0.85, -0.35)
	g.queue("Queue", { V(0, 2.4, 1.2), V(0, 2.5, 2.4), V(0, 2.75, 3.35) }, { 1.05, 0.75 }, base, ombre)
	g.tache("Tache1", cCorps, 1.4, V(-0.6, 0.75, 0.35), 0.7, ombre)
	g.tache("Tache2", cCorps, 1.4, V(0.6, 0.75, 0.35), 0.7, ombre)
	g.tache("Tache3", cCorps, 1.4, V(0, 0.7, 0.75), 0.6, ombre)
	g.cuisses(0.8, 1.75, 0.5, 1.25, base)
	g.pattes("Ar", 0.72, 1.5, 0.1, 0.7, 0.9, ombre, ombre, 0.45)
	g.bras(V(1.0, 2.8, -0.55), V(1.25, 2.4, -1.05), 0.4, 0.5, base)
	return corps
end

-- Tricera : quadrupède vert vif, grande collerette orange bordée de jaune, trois cornes, taches (40 parts)
ESPECES.Tricera = function(g, C)
	local base = g.hex("6BD64A")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local orange = g.hex("FF8C42")
	local jaune = g.hex("FFE14D")
	local cCorps = V(0, 2.45, 0.5)
	local corps = g.boule("Corps", 3.0, cCorps, base)
	g.boule("Arriere", 2.7, V(0, 2.4, 1.55), base)
	g.boule("Ventre", 2.3, V(0, 2.0, 0.3), g.ventre(base))
	local cTete = V(0, 2.95, -1.35)
	g.boule("Tete", 2.7, cTete, base)
	g.boule("Museau", 1.5, V(0, 2.4, -2.3), clair)
	-- collerette inclinée vers l'arrière, avec une bordure et des picots
	local inclinaison = CFrame.Angles(math.rad(20), 0, 0)
	local cCol = V(0, 3.75, -0.4)
	g.poser("cyl", "Collerette", V(0.35, 4.4, 4.4), CFrame.new(cCol) * inclinaison * CFrame.Angles(0, math.rad(90), 0), orange)
	g.poser("cyl", "Bordure", V(0.3, 4.9, 4.9), CFrame.new(cCol + V(0, 0.05, 0.15)) * inclinaison * CFrame.Angles(0, math.rad(90), 0), jaune)
	for i, angle in ipairs({ -50, 0, 50 }) do
		local a = math.rad(angle)
		local local3 = V(math.sin(a) * 2.45, math.cos(a) * 2.45, 0.12)
		local pos = (CFrame.new(cCol) * inclinaison) * local3
		g.boule("Picot" .. i, 0.55, pos, C.creme)
	end
	g.yeux(cTete, 1.35, 1.0, 0.62, 0.2)
	g.joues(cTete, 1.35, 0.45, 0.85, -0.3)
	g.chaine("CorneG", { V(-0.55, 3.9, -2.05), V(-0.62, 4.35, -2.5) }, { 0.52, 0.34 }, C.creme)
	g.chaine("CorneD", { V(0.55, 3.9, -2.05), V(0.62, 4.35, -2.5) }, { 0.52, 0.34 }, C.creme)
	g.chaine("CorneNez", { V(0, 2.95, -2.8), V(0, 3.3, -3.0) }, { 0.45, 0.3 }, C.creme)
	g.queue("Queue", { V(0, 2.35, 2.3), V(0, 2.2, 3.35), V(0, 2.0, 4.1) }, { 0.95, 0.65 }, base)
	g.tache("Tache1", cCorps, 1.5, V(-0.7, 0.8, 0.3), 0.8, C.jungle)
	g.tache("Tache2", cCorps, 1.5, V(0.7, 0.8, 0.3), 0.8, C.jungle)
	g.pattes("Av", 0.95, 1.8, -0.3, 0.95, 1.1, ombre)
	g.pattes("Ar", 0.95, 1.8, 1.7, 0.95, 1.1, ombre)
	return corps
end

-- Stego : quadrupède turquoise, plaques rondes orange et jaunes sur le dos, queue à piques (39 parts)
ESPECES.Stego = function(g, C)
	local base = g.hex("2EC4B6")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local orange = g.hex("FF8C42")
	local jaune = g.hex("FFE14D")
	local corps = g.boule("Corps", 3.2, V(0, 2.6, 0.4), base)
	g.boule("Arriere", 3.0, V(0, 2.85, 1.5), base)
	g.boule("Ventre", 2.4, V(0, 2.1, 0.2), g.ventre(base))
	g.boule("Cou", 1.6, V(0, 2.45, -1.15), base)
	local cTete = V(0, 2.6, -2.0)
	g.boule("Tete", 2.4, cTete, base)
	local cMuseau = V(0, 2.15, -2.9)
	g.boule("Museau", 1.25, cMuseau, clair)
	g.narines(cMuseau, 0.625, 0.15)
	g.yeux(cTete, 1.2, 0.9, 0.62, 0.22)
	g.joues(cTete, 1.2, 0.42, 0.85, -0.3)
	-- plaques dorsales : disques fins, alternés de part et d'autre de l'échine
	local plaques = { { -0.55, 4.15, 1.05 }, { 0.2, 4.5, 1.45 }, { 0.95, 4.65, 1.65 }, { 1.75, 4.65, 1.55 }, { 2.5, 4.3, 1.2 } }
	for i, pl in ipairs(plaques) do
		local couleur = orange
		local sens = -1
		if i % 2 == 0 then
			couleur = jaune
			sens = 1
		end
		g.p("cyl", "Plaque" .. i, V(0.28, pl[3], pl[3]), V(sens * 0.18, pl[2], pl[1]), couleur, V(0, 0, sens * 8))
	end
	g.queue("Queue", { V(0, 2.75, 2.4), V(0, 2.6, 3.6), V(0, 2.45, 4.75) }, { 1.1, 0.75 }, base)
	g.os("PiqueG1", V(-0.25, 2.6, 4.2), V(-0.9, 3.3, 4.5), 0.22, C.creme)
	g.os("PiqueD1", V(0.25, 2.6, 4.2), V(0.9, 3.3, 4.5), 0.22, C.creme)
	g.os("PiqueG2", V(-0.2, 2.5, 4.7), V(-0.8, 3.1, 5.1), 0.2, C.creme)
	g.os("PiqueD2", V(0.2, 2.5, 4.7), V(0.8, 3.1, 5.1), 0.2, C.creme)
	g.pattes("Av", 1.0, 1.9, -0.3, 1.0, 1.15, ombre)
	g.pattes("Ar", 1.0, 1.9, 1.7, 1.05, 1.2, ombre)
	return corps
end

-- Parasaure : bipède bleu roi rayé, bec de canard jaune, longue crête tubulaire rose (36 parts)
ESPECES.Parasaure = function(g, C)
	local base = g.hex("4D96FF")
	local ombre = C.ombre(base)
	local rose = g.hex("FF5CA8")
	local jaune = g.hex("FFD166")
	local cCorps = V(0, 2.7, 0.4)
	local corps = g.boule("Corps", 2.9, cCorps, base)
	g.boule("Ventre", 2.15, V(0, 2.5, -0.25), g.ventre(base))
	g.boule("Cou", 1.45, V(0, 3.85, -0.5), base)
	local cTete = V(0, 4.85, -0.85)
	g.boule("Tete", 2.5, cTete, base)
	g.boule("Bec", 1.25, V(0, 4.25, -1.9), jaune)
	g.boule("BecBout", 1.0, V(0, 4.12, -2.45), jaune)
	g.boule("CreteBase", 0.75, V(0, 5.75, -0.9), rose)
	g.os("Crete", V(0, 5.75, -0.9), V(0, 6.75, 0.9), 0.7, rose)
	g.boule("CreteBout", 0.85, V(0, 6.75, 0.9), C.lumiere(rose))
	g.yeux(cTete, 1.25, 0.9, 0.62, 0.2)
	g.joues(cTete, 1.25, 0.42, 0.85, -0.25)
	g.rayure("Rayure1", cCorps, 2.9, 0.25, 0.26, ombre)
	g.rayure("Rayure2", cCorps, 2.9, 0.7, 0.26, ombre)
	g.rayure("Rayure3", cCorps, 2.9, 1.1, 0.24, ombre)
	g.queue("Queue", { V(0, 2.6, 1.3), V(0, 2.7, 2.5), V(0, 2.85, 3.5) }, { 1.05, 0.75 }, base, rose, false, 0.8)
	g.cuisses(0.8, 1.9, 0.55, 1.3, base)
	g.pattes("Ar", 0.72, 1.7, 0.15, 0.7, 0.9, ombre, ombre, 0.5)
	g.bras(V(1.05, 3.0, -0.45), V(1.3, 2.55, -0.95), 0.4, 0.5, base)
	return corps
end

-- Ankylo : quadrupède orange, carapace ronde à bosses violettes, piques crème, queue massue (38 parts)
ESPECES.Ankylo = function(g, C)
	local base = g.hex("F4A259")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local brun = g.hex("A0522D")
	local epique = g.accent("Epique")
	local corps = g.boule("Corps", 3.2, V(0, 2.2, 0.6), base)
	local cCarapace = V(0, 2.95, 0.75)
	g.boule("Carapace", 3.6, cCarapace, brun)
	g.boule("Ventre", 2.4, V(0, 1.85, 0.1), g.ventre(base))
	g.tache("BosseHaut", cCarapace, 1.8, V(0, 1, 0), 0.8, epique)
	g.tache("BosseG", cCarapace, 1.8, V(-0.75, 0.6, 0.1), 0.75, epique)
	g.tache("BosseD", cCarapace, 1.8, V(0.75, 0.6, 0.1), 0.75, epique)
	g.os("PiqueAvG", V(-1.5, 2.4, 0.1), V(-2.3, 2.6, 0.0), 0.35, C.creme)
	g.os("PiqueAvD", V(1.5, 2.4, 0.1), V(2.3, 2.6, 0.0), 0.35, C.creme)
	g.os("PiqueArG", V(-1.5, 2.4, 1.35), V(-2.3, 2.55, 1.5), 0.35, C.creme)
	g.os("PiqueArD", V(1.5, 2.4, 1.35), V(2.3, 2.55, 1.5), 0.35, C.creme)
	local cTete = V(0, 2.35, -1.55)
	g.boule("Tete", 2.5, cTete, clair)
	g.boule("Museau", 1.3, V(0, 1.95, -2.45), C.lumiere(clair))
	g.boule("CorneG", 0.5, V(-0.95, 3.2, -1.2), C.creme)
	g.boule("CorneD", 0.5, V(0.95, 3.2, -1.2), C.creme)
	g.yeux(cTete, 1.25, 0.9, 0.62, 0.22)
	g.joues(cTete, 1.25, 0.42, 0.85, -0.3)
	local _, massue = g.queue("Queue", { V(0, 2.0, 1.6), V(0, 1.85, 3.1), V(0, 1.75, 4.5) }, { 0.85, 0.6 }, base, brun, false, 1.5)
	if massue then
		massue.Name = "Massue"
	end
	g.boule("MassueG", 0.75, V(-0.65, 1.75, 4.5), epique)
	g.boule("MassueD", 0.75, V(0.65, 1.75, 4.5), epique)
	g.pattes("Av", 1.05, 1.6, -0.3, 1.0, 1.1, ombre)
	g.pattes("Ar", 1.05, 1.6, 1.6, 1.0, 1.1, ombre)
	return corps
end

-- Iguano : bipède vert émeraude rayé, crête de boules violettes, pouces dorés (39 parts)
ESPECES.Iguano = function(g, C)
	local base = g.hex("3CCB7F")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local epique = g.accent("Epique")
	local cCorps = V(0, 2.9, 0.4)
	local corps = g.boule("Corps", 3.0, cCorps, base)
	g.boule("Ventre", 2.3, V(0, 2.7, -0.25), g.ventre(base))
	g.boule("Cou", 1.55, V(0, 4.05, -0.45), base)
	local cTete = V(0, 5.05, -0.75)
	g.boule("Tete", 2.6, cTete, base)
	local cMuseau = V(0, 4.5, -1.75)
	g.boule("Museau", 1.4, cMuseau, clair)
	g.narines(cMuseau, 0.7, 0.16)
	g.yeux(cTete, 1.3, 0.95, 0.62, 0.2)
	g.joues(cTete, 1.3, 0.45, 0.85, -0.3)
	g.chaine("Crete", { V(0, 6.3, -0.5), V(0, 5.85, 0.35), V(0, 4.45, 0.75), V(0, 4.15, 1.35) }, { 0.62, 0.55, 0.5, 0.45 }, epique)
	g.rayure("Rayure1", cCorps, 3.0, 0.5, 0.28, ombre)
	g.rayure("Rayure2", cCorps, 3.0, 0.95, 0.26, ombre)
	g.queue("Queue", { V(0, 2.75, 1.3), V(0, 2.85, 2.6), V(0, 3.0, 3.7) }, { 1.1, 0.78 }, base, epique, false, 0.72)
	g.cuisses(0.85, 2.0, 0.55, 1.35, base)
	g.pattes("Ar", 0.78, 1.8, 0.15, 0.75, 1.0, ombre, ombre, 0.5)
	g.bras(V(1.1, 3.3, -0.4), V(1.4, 2.8, -0.95), 0.45, 0.55, base)
	g.os("PouceG", V(-1.4, 2.8, -0.95), V(-1.45, 3.35, -1.2), 0.2, C.dore)
	g.os("PouceD", V(1.4, 2.8, -0.95), V(1.45, 3.35, -1.2), 0.2, C.dore)
	g.lueur(corps, epique, 8, 0.6)
	return corps
end

-- Brachio : long cou dressé en segments dégressifs, collier d'or à gemme, crête, taches orange (40 parts)
ESPECES.Brachio = function(g, C)
	local base = g.hex("FFD23F")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local orange = g.hex("FF9F1C")
	local legendaire = g.accent("Legendaire")
	local cCorps = V(0, 3.2, 0.6)
	local corps = g.boule("Corps", 3.5, cCorps, base)
	local cArriere = V(0, 3.1, 1.6)
	g.boule("Arriere", 3.1, cArriere, base)
	g.boule("Ventre", 2.7, V(0, 2.75, 0.15), g.ventre(base))
	local epaule, milieu, sommet = V(0, 4.2, -0.6), V(0, 5.7, -0.95), V(0, 7.0, -1.15)
	g.os("Cou", epaule, milieu, 1.6, base)
	g.boule("CouMilieu", 1.5, milieu, base)
	g.os("Cou2", milieu, sommet, 1.3, base)
	g.os("Collier", V(0, 4.55, -0.69), V(0, 4.85, -0.76), 1.85, C.dore)
	g.boule("Gemme", 0.45, V(0, 4.72, -1.6), legendaire, true)
	local cTete = V(0, 7.85, -1.25)
	g.boule("Tete", 2.7, cTete, base)
	local cMuseau = V(0, 7.35, -2.25)
	g.boule("Museau", 1.45, cMuseau, clair)
	g.narines(cMuseau, 0.725, 0.16)
	g.chaine("Crete", { V(0, 9.15, -1.05), V(0, 9.0, -0.45) }, { 0.95, 0.65 }, legendaire)
	g.yeux(cTete, 1.35, 1.0, 0.62, 0.2)
	g.joues(cTete, 1.35, 0.45, 0.85, -0.3)
	g.tache("Tache1", cCorps, 1.75, V(-0.6, 0.8, -0.1), 0.9, orange)
	g.tache("Tache2", cCorps, 1.75, V(0.7, 0.7, 0.2), 0.8, orange)
	g.tache("Tache3", cArriere, 1.55, V(-0.4, 0.9, 0.5), 0.75, orange)
	g.tache("Tache4", cArriere, 1.55, V(0.5, 0.8, 0.6), 0.9, orange)
	g.queue("Queue", { V(0, 3.0, 2.5), V(0, 2.8, 3.7), V(0, 2.55, 4.7) }, { 1.05, 0.7 }, base)
	g.pattes("Av", 1.0, 2.2, -0.2, 1.05, 1.2, ombre)
	g.pattes("Ar", 1.0, 2.2, 1.8, 1.05, 1.2, ombre)
	g.lueur(corps, legendaire, 10, 0.8)
	return corps
end

-- Diplodo : violet vif, cou et queue en tubes dégressifs, épines néon, taches (39 parts)
ESPECES.Diplodo = function(g, C)
	local base = g.hex("B15CFF")
	local ombre = C.ombre(base)
	local clair = C.lumiere(base)
	local mythique = g.accent("Mythique")
	local cCorps = V(0, 3.0, 0.8)
	local corps = g.boule("Corps", 3.5, cCorps, base)
	g.boule("Arriere", 3.1, V(0, 3.05, 1.9), base)
	g.boule("Ventre", 2.6, V(0, 2.55, 0.45), g.ventre(base))
	g.queue("Cou", { V(0, 3.7, -0.5), V(0, 4.75, -1.75), V(0, 5.95, -3.0) }, { 1.5, 1.2 }, base, nil, false, nil, true)
	local cTete = V(0, 6.45, -3.45)
	g.boule("Tete", 2.4, cTete, base)
	g.boule("Museau", 1.3, V(0, 6.0, -4.35), clair)
	g.yeux(cTete, 1.2, 0.9, 0.62, 0.2)
	g.joues(cTete, 1.2, 0.42, 0.85, -0.3)
	g.queue("Queue", { V(0, 3.05, 2.8), V(0, 2.95, 4.1), V(0, 2.75, 5.2), V(0, 2.55, 6.1) }, { 1.35, 1.0, 0.65 }, base, mythique, true, 0.6)
	local epines = { { 0.3, 4.72, 0.55 }, { 0.95, 4.85, 0.62 }, { 1.6, 4.67, 0.62 }, { 2.35, 4.45, 0.55 }, { 3.2, 3.95, 0.48 } }
	for i, ep in ipairs(epines) do
		g.boule("Epine" .. i, ep[3], V(0, ep[2], ep[1]), mythique, true)
	end
	g.tache("TacheG", cCorps, 1.75, V(-1, 0.3, 0.2), 0.9, ombre)
	g.tache("TacheD", cCorps, 1.75, V(1, 0.3, 0.2), 0.9, ombre)
	g.pattes("Av", 1.0, 2.2, 0.0, 1.05, 1.2, ombre)
	g.pattes("Ar", 1.0, 2.2, 2.0, 1.05, 1.2, ombre)
	g.lueur(corps, mythique, 12, 1.2)
	return corps
end

-- Therizino : ventre tout rond, griffes géantes néon, plumes roses, auréole et aura divines (40 parts)
ESPECES.Therizino = function(g, C)
	local divin = C.raretes.Divin or C.gemme
	local base = g.hex("5CE1E6")
	local ombre = C.ombre(base)
	local rose = g.hex("FF5CE1")
	local corps = g.boule("Corps", 3.3, V(0, 3.4, 0.4), base)
	g.boule("Ventre", 2.8, V(0, 3.1, -0.3), g.ventre(base))
	g.boule("Cou", 1.4, V(0, 5.0, -0.4), base)
	local cTete = V(0, 6.15, -0.6)
	g.boule("Tete", 2.4, cTete, base)
	g.boule("Bec", 0.9, V(0, 5.65, -1.6), C.dore)
	g.chaine("Plumes", { V(0, 7.4, -0.55), V(0, 7.3, -0.05), V(0, 7.05, 0.35) }, { 0.6, 0.5, 0.4 }, rose)
	g.yeux(cTete, 1.2, 0.9, 0.62, 0.2)
	g.joues(cTete, 1.2, 0.42, 0.85, -0.3)
	g.cuisses(0.85, 2.2, 0.55, 1.35, base)
	g.pattes("Ar", 0.8, 2.0, 0.2, 0.75, 1.0, ombre, ombre, 0.55)
	g.bras(V(1.35, 4.3, -0.4), V(1.8, 3.7, -1.05), 0.6, 0.7, base)
	for _, cote in ipairs({ { "G", -1 }, { "D", 1 } }) do
		local sens = cote[2]
		local main = V(sens * 1.8, 3.7, -1.05)
		for i = 1, 3 do
			local debut = main + V(sens * (i - 2) * 0.22, -0.1, -0.1)
			local fin = debut + V(sens * (i - 2) * 0.1, -0.55, -1.2)
			g.os("Griffe" .. cote[1] .. i, debut, fin, 0.2, divin, true)
		end
	end
	g.queue("Queue", { V(0, 3.2, 1.4), V(0, 3.05, 2.5), V(0, 2.95, 3.4) }, { 1.05, 0.72 }, base, rose, false, 0.8)
	local halo = g.p("cyl", "Aureole", V(0.15, 1.7, 1.7), V(0, 8.3, -0.55), C.dore, V(0, 0, 90), true)
	if halo then
		halo.Transparency = 0.2
		halo.CastShadow = false
	end
	-- aura en champ de force (reflet irisé discret, ne cache pas le dino)
	local aura = g.boule("Aura", 6.4, V(0, 4.0, 0.2), divin)
	if aura then
		aura.Material = Enum.Material.ForceField
		aura.Transparency = 0.35
		aura.CastShadow = false
	end
	g.lueur(corps, divin, 16, 2)
	return corps
end

-- ===== construction =====
local function construireEspece(ctx, dossier, cle, infos)
	local fonction = ESPECES[cle]
	if not fonction then
		return false
	end
	local ancien = dossier:FindFirstChild(cle)
	if ancien then
		ancien:Destroy()
	end
	local s = tonumber(infos.taille) or 1
	local modele = Instance.new("Model")
	modele.Name = cle
	local g = nouvelOutil(ctx, modele, s)
	local ok, corps = pcall(fonction, g, ctx.Charte)
	if not ok or not corps then
		modele:Destroy()
		if not ok then
			warn("[Dino] gabarit « " .. cle .. " » : " .. tostring(corps))
		end
		return false
	end
	-- pivot au sol sous le dino (origine du modèle), regard vers -Z
	corps.PivotOffset = corps.CFrame:Inverse()
	modele.PrimaryPart = corps
	modele:SetAttribute("Espece", cle)
	modele:SetAttribute("Rarete", infos.rarete or "Commun")
	modele:SetAttribute("Famille", "Herbivore")
	modele.Parent = dossier
	return true
end

function M.construire(ctx)
	local E = ctx.Equilibrage
	local stockage = ctx.stockage
	if not stockage or not E or type(E.especes) ~= "table" then
		return
	end
	local dossier = stockage:FindFirstChild("Dinos")
	if not dossier then
		dossier = ctx.Outils.dossier(stockage, "Dinos")
	end
	for cle, infos in pairs(E.especes) do
		if type(infos) == "table" and infos.famille == "Herbivore" then
			construireEspece(ctx, dossier, cle, infos)
		end
	end
end

return M
