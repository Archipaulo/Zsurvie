-- Constructeur DinosHerbivores : gabarits des espèces de la famille « Herbivore »,
-- rangés dans ServerStorage.Dino.Dinos (clonés ensuite par Systemes/Tapis).
-- Style « chibi » de simulateur Roblox : grosse tête ronde, très gros yeux brillants
-- (blanc + pupille noire + reflet), couleurs saturées, formes arrondies, pattes courtes.
-- Regard vers -Z local, pivot au sol sous le dino.
local M = {}

local BUDGET = 30 -- parts maximum par gabarit
local V = Vector3.new

-- fabrique d'un gabarit : renvoie un petit outil de construction à l'échelle s
local function nouvelOutil(ctx, modele, s)
	local Outils = ctx.Outils
	local Charte = ctx.Charte
	local Style = ctx.Style
	local hex = Charte.hex
	local g = { n = 0, s = s, modele = modele }

	-- teintes communes du style chibi
	g.blanc = hex("FFFFFF")
	g.noir = (Style and Style.couleurs and Style.couleurs.contour) or Charte.encre
	g.rose = hex("FF8FB1")
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

	-- forme : "bloc", "coin", "boule" ou "cyl" ; t et pos à l'échelle 1 ; rot en degrés
	function g.p(forme, nom, t, pos, couleur, rot, neon)
		if g.n >= BUDGET then
			return nil
		end
		local cf = CFrame.new(pos * s)
		if rot then
			cf = cf * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
		end
		local props = {
			Name = nom,
			Size = t * s,
			CFrame = cf,
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

	-- boule de diamètre d
	function g.boule(nom, d, pos, couleur, neon)
		return g.p("boule", nom, V(d, d, d), pos, couleur, nil, neon)
	end

	-- une paire symétrique (G à -X, D à +X) ; rotY et rotZ inversées côté droit
	function g.paire(forme, nom, t, pos, couleur, rot, neon)
		local rotG, rotD = rot, rot
		if rot then
			rotG = V(rot.X, rot.Y, rot.Z)
			rotD = V(rot.X, -rot.Y, -rot.Z)
		end
		g.p(forme, nom .. "G", t, V(-pos.X, pos.Y, pos.Z), couleur, rotG, neon)
		g.p(forme, nom .. "D", t, V(pos.X, pos.Y, pos.Z), couleur, rotD, neon)
	end

	-- paire de pattes cylindriques verticales posées au sol (h = hauteur, d = épaisseur)
	function g.pattes(nom, h, d, x, z, couleur)
		g.paire("cyl", nom, V(h, d, d), V(x, h / 2, z), couleur, V(0, 0, 90))
	end

	-- très gros yeux chibi sur l'avant de la tête : blanc, grosse pupille noire, reflet brillant
	-- (x = demi-écart, z = centre du blanc, d = diamètre du blanc)
	function g.yeux(x, y, z, d)
		local cotes = { { "G", -1 }, { "D", 1 } }
		for _, c in ipairs(cotes) do
			local sens = c[2]
			g.boule("Oeil" .. c[1], d, V(sens * x, y, z), g.blanc)
			g.boule("Pupille" .. c[1], d * 0.62, V(sens * (x + d * 0.04), y - d * 0.04, z - d * 0.28), g.noir)
			g.boule("Reflet" .. c[1], d * 0.24, V(sens * (x - d * 0.08), y + d * 0.18, z - d * 0.5), g.blanc, true)
		end
	end

	-- petites joues roses
	function g.joues(x, y, z, d)
		g.paire("boule", "Joue", V(d, d, d), V(x, y, z), g.rose)
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
-- les yeux sont posés juste après la tête pour ne jamais sortir du budget de parts
local ESPECES = {}

-- Galli : petit coureur bipède jaune-orangé, crête rouge, bec
ESPECES.Galli = function(g, C)
	local base = g.hex("FFB23F")
	local ombre = C.ombre(base)
	local rouge = g.hex("FF4F5E")
	local corps = g.boule("Corps", 2.0, V(0, 2.2, 0.2), base)
	g.boule("Ventre", 1.5, V(0, 2.0, -0.35), C.creme)
	g.p("cyl", "Cou", V(1.0, 0.7, 0.7), V(0, 3.2, -0.5), base, V(0, 0, 90))
	g.boule("Tete", 2.2, V(0, 4.3, -0.8), base)
	g.yeux(0.5, 4.5, -1.62, 0.85)
	g.p("coin", "Bec", V(0.8, 0.45, 0.8), V(0, 4.0, -2.0), g.hex("FF8A1F"))
	g.boule("Crete1", 0.6, V(0, 5.4, -1.0), rouge)
	g.boule("Crete2", 0.5, V(0, 5.35, -0.45), rouge)
	g.p("coin", "Queue", V(0.9, 0.9, 1.8), V(0, 2.3, 1.6), base, V(0, 180, 0))
	g.boule("QueueBout", 0.55, V(0, 2.25, 2.4), rouge)
	g.pattes("PatteAr", 1.4, 0.55, 0.5, 0.3, ombre)
	g.paire("boule", "Pied", V(0.7, 0.7, 0.7), V(0.5, 0.25, -0.05), g.hex("FF8A1F"))
	g.paire("boule", "PatteAv", V(0.45, 0.45, 0.45), V(0.85, 2.4, -0.7), base)
	g.joues(0.8, 4.0, -1.5, 0.35)
	return corps
end

-- Pachy : bipède trapu bleu ciel au gros dôme crème
ESPECES.Pachy = function(g, C)
	local base = g.hex("5BC0FF")
	local ombre = C.ombre(base)
	local bosse = g.hex("B15CFF")
	local corps = g.boule("Corps", 2.6, V(0, 2.5, 0.3), base)
	g.boule("Ventre", 2.0, V(0, 2.3, -0.25), C.creme)
	g.boule("Tete", 2.4, V(0, 4.3, -0.6), base)
	g.yeux(0.55, 4.55, -1.5, 0.85)
	g.boule("Dome", 2.0, V(0, 5.15, -0.5), g.hex("FFD166"))
	g.paire("boule", "Bosse", V(0.5, 0.5, 0.5), V(0.95, 5.0, -0.4), bosse)
	g.boule("BosseHaut", 0.5, V(0, 5.95, 0.2), bosse)
	g.boule("Museau", 1.2, V(0, 3.8, -1.65), C.lumiere(base))
	g.p("coin", "Queue", V(1.0, 1.0, 1.8), V(0, 2.4, 1.8), base, V(0, 180, 0))
	g.boule("QueueBout", 0.6, V(0, 2.3, 2.7), ombre)
	g.pattes("PatteAr", 1.3, 0.8, 0.65, 0.4, ombre)
	g.paire("boule", "Pied", V(0.9, 0.9, 0.9), V(0.65, 0.3, 0.0), ombre)
	g.paire("boule", "PatteAv", V(0.55, 0.55, 0.55), V(1.15, 2.6, -0.7), base)
	g.joues(0.85, 4.0, -1.35, 0.4)
	return corps
end

-- Tricera : quadrupède vert vif, grande collerette orange, trois cornes
ESPECES.Tricera = function(g, C)
	local base = g.hex("6BD64A")
	local ombre = C.ombre(base)
	local corps = g.boule("Corps", 3.0, V(0, 2.4, 0.6), base)
	g.boule("Arriere", 2.6, V(0, 2.3, 1.6), base)
	g.boule("Tete", 2.8, V(0, 3.0, -1.3), base)
	g.yeux(0.6, 3.35, -2.35, 0.95)
	g.p("cyl", "Collerette", V(0.35, 4.2, 4.2), V(0, 3.6, -0.4), g.hex("FF8C42"), V(0, 90, 0))
	g.p("cyl", "Bordure", V(0.3, 4.7, 4.7), V(0, 3.6, -0.25), g.hex("FFE14D"), V(0, 90, 0))
	g.paire("bloc", "Corne", V(0.35, 0.35, 1.5), V(0.6, 4.0, -2.2), C.creme, V(35, 0, 0))
	g.boule("Museau", 1.3, V(0, 2.5, -2.3), C.lumiere(base))
	g.p("bloc", "CorneNez", V(0.35, 0.35, 0.7), V(0, 3.1, -2.75), C.creme, V(40, 0, 0))
	g.p("coin", "Queue", V(0.9, 0.9, 1.6), V(0, 2.3, 3.2), base, V(0, 180, 0))
	g.paire("boule", "Tache", V(0.8, 0.8, 0.8), V(0.9, 3.3, 1.0), C.jungle)
	g.pattes("PatteAv", 1.2, 0.95, 0.9, -0.4, ombre)
	g.pattes("PatteAr", 1.2, 0.95, 0.9, 1.9, ombre)
	g.joues(0.85, 2.7, -2.4, 0.4)
	return corps
end

-- Stego : quadrupède turquoise, rangée de plaques orange et jaunes, queue à piques
ESPECES.Stego = function(g, C)
	local base = g.hex("2EC4B6")
	local ombre = C.ombre(base)
	local corps = g.boule("Corps", 3.2, V(0, 2.6, 0.6), base)
	g.boule("Arriere", 2.8, V(0, 2.6, 1.8), base)
	g.boule("Tete", 2.6, V(0, 2.8, -1.7), base)
	g.yeux(0.6, 3.05, -2.7, 0.9)
	local plaques = { { 0.0, 1.1, 4.3 }, { 0.8, 1.4, 4.5 }, { 1.6, 1.3, 4.4 }, { 2.4, 1.0, 4.1 }, { 3.1, 0.7, 3.6 } }
	for i, pl in ipairs(plaques) do
		local couleur = g.hex("FF8C42")
		if i % 2 == 0 then
			couleur = g.hex("FFE14D")
		end
		g.p("bloc", "Plaque" .. i, V(0.3, pl[2], pl[2]), V(0, pl[3], pl[1]), couleur, V(45, 0, 0))
	end
	g.p("coin", "Queue", V(1.0, 1.0, 2.0), V(0, 2.5, 3.6), base, V(0, 180, 0))
	g.paire("bloc", "Pique", V(1.0, 0.25, 0.25), V(0.6, 2.7, 4.2), C.creme, V(0, 0, -25))
	g.pattes("PatteAv", 1.3, 1.0, 0.95, -0.2, ombre)
	g.pattes("PatteAr", 1.3, 1.0, 0.95, 2.0, ombre)
	g.joues(0.85, 2.5, -2.55, 0.4)
	return corps
end

-- Parasaure : bipède bleu roi, bec de canard, longue crête tubulaire rose
ESPECES.Parasaure = function(g, C)
	local base = g.hex("4D96FF")
	local ombre = C.ombre(base)
	local rose = g.hex("FF5CA8")
	local corps = g.boule("Corps", 2.8, V(0, 2.6, 0.4), base)
	g.boule("Ventre", 2.0, V(0, 2.4, -0.3), C.creme)
	g.boule("Tete", 2.4, V(0, 4.4, -0.9), base)
	g.yeux(0.55, 4.6, -1.8, 0.85)
	g.boule("Bec", 1.1, V(0, 3.9, -1.9), g.hex("FFD166"))
	g.p("bloc", "Crete", V(0.5, 0.5, 2.6), V(0, 5.8, 0.2), rose, V(-30, 0, 0))
	g.boule("CreteBout", 0.7, V(0, 6.45, 1.33), C.lumiere(rose))
	g.paire("boule", "Tache", V(0.7, 0.7, 0.7), V(1.1, 3.2, 0.8), ombre)
	g.p("coin", "Queue", V(1.0, 1.1, 2.0), V(0, 2.5, 2.2), base, V(0, 180, 0))
	g.boule("QueueBout", 0.6, V(0, 2.3, 3.1), rose)
	g.pattes("PatteAr", 1.3, 0.8, 0.7, 0.6, ombre)
	g.paire("boule", "Pied", V(0.9, 0.9, 0.9), V(0.7, 0.3, 0.25), ombre)
	g.paire("boule", "PatteAv", V(0.55, 0.55, 0.55), V(1.2, 2.5, -0.6), base)
	g.joues(0.85, 4.1, -1.65, 0.4)
	return corps
end

-- Ankylo : quadrupède orange, carapace ronde à bosses violettes, piques, queue massue
ESPECES.Ankylo = function(g, C)
	local base = g.hex("F4A259")
	local ombre = C.ombre(base)
	local epique = g.accent("Epique")
	local corps = g.boule("Corps", 3.4, V(0, 2.4, 0.6), base)
	g.boule("Carapace", 3.6, V(0, 2.9, 0.7), g.hex("A0522D"))
	g.boule("Tete", 2.6, V(0, 2.5, -1.6), C.lumiere(base))
	g.yeux(0.6, 2.75, -2.6, 0.9)
	g.boule("BosseHaut", 0.7, V(0, 4.6, 0.2), epique)
	g.paire("boule", "Bosse", V(0.7, 0.7, 0.7), V(1.2, 4.2, 0.9), epique)
	g.paire("bloc", "PiqueAv", V(0.9, 0.35, 0.35), V(1.9, 2.6, -0.1), C.creme, V(0, 0, -20))
	g.paire("bloc", "PiqueAr", V(0.9, 0.35, 0.35), V(1.9, 2.6, 1.4), C.creme, V(0, 0, -20))
	g.paire("bloc", "Corne", V(0.35, 0.35, 0.8), V(0.9, 3.4, -1.4), C.creme, V(0, 45, 0))
	g.p("bloc", "Queue", V(0.8, 0.7, 2.2), V(0, 2.0, 3.2), base)
	g.boule("Massue", 1.4, V(0, 2.0, 4.4), g.hex("A0522D"))
	g.paire("boule", "MassueCote", V(0.8, 0.8, 0.8), V(0.6, 2.0, 4.4), epique)
	g.pattes("PatteAv", 1.2, 1.0, 1.1, -0.4, ombre)
	g.pattes("PatteAr", 1.2, 1.0, 1.1, 1.8, ombre)
	g.joues(0.85, 2.3, -2.55, 0.4)
	return corps
end

-- Iguano : bipède vert émeraude, crête violette, pouces dorés
ESPECES.Iguano = function(g, C)
	local base = g.hex("3CCB7F")
	local ombre = C.ombre(base)
	local epique = g.accent("Epique")
	local corps = g.boule("Corps", 3.0, V(0, 2.9, 0.4), base)
	g.boule("Ventre", 2.2, V(0, 2.7, -0.3), C.creme)
	g.boule("Tete", 2.6, V(0, 4.9, -0.7), base)
	g.yeux(0.6, 5.15, -1.7, 0.95)
	g.boule("Museau", 1.3, V(0, 4.4, -1.7), C.lumiere(base))
	g.p("coin", "Crete1", V(0.3, 0.7, 0.9), V(0, 6.2, -0.5), epique)
	g.p("coin", "Crete2", V(0.3, 0.7, 0.9), V(0, 4.5, 0.8), epique)
	g.p("coin", "Crete3", V(0.3, 0.6, 0.9), V(0, 4.1, 1.6), epique)
	g.p("coin", "Queue", V(1.2, 1.2, 2.2), V(0, 2.6, 2.4), base, V(0, 180, 0))
	g.pattes("PatteAr", 1.5, 1.0, 0.8, 0.6, ombre)
	g.paire("boule", "Pied", V(1.1, 1.1, 1.1), V(0.8, 0.35, 0.2), ombre)
	g.paire("boule", "PatteAv", V(0.7, 0.7, 0.7), V(1.35, 3.1, -0.6), base)
	g.paire("bloc", "Pouce", V(0.2, 0.7, 0.2), V(1.5, 3.4, -0.9), C.dore, V(-25, 0, 0))
	g.joues(0.9, 4.6, -1.55, 0.45)
	g.lueur(corps, epique, 8, 0.6)
	return corps
end

-- Brachio : grand cou dressé, tête ronde à crête dorée, collier d'or, taches orange
ESPECES.Brachio = function(g, C)
	local base = g.hex("FFD23F")
	local ombre = C.ombre(base)
	local orange = g.hex("FF9F1C")
	local legendaire = g.accent("Legendaire")
	local corps = g.boule("Corps", 3.4, V(0, 3.2, 0.6), base)
	g.boule("Ventre", 2.4, V(0, 2.9, 0.0), C.creme)
	g.p("cyl", "Cou", V(2.6, 1.2, 1.2), V(0, 5.3, -0.6), base, V(0, 0, 90))
	g.p("cyl", "Collier", V(0.35, 1.45, 1.45), V(0, 4.6, -0.6), C.dore, V(0, 0, 90))
	g.boule("Tete", 2.6, V(0, 7.3, -0.9), base)
	g.yeux(0.6, 7.55, -1.9, 0.95)
	g.boule("Crete", 0.9, V(0, 8.55, -0.6), legendaire)
	g.boule("Museau", 1.3, V(0, 6.9, -1.85), C.lumiere(base))
	g.boule("Tache1", 0.9, V(-1.0, 4.2, 0.3), orange)
	g.boule("Tache2", 0.9, V(1.0, 4.3, 1.2), orange)
	g.boule("Tache3", 0.9, V(0, 4.8, 0.9), orange)
	g.p("coin", "Queue", V(1.0, 1.1, 2.4), V(0, 3.0, 2.8), base, V(0, 180, 0))
	g.pattes("PatteAv", 1.8, 1.0, 0.95, -0.2, ombre)
	g.pattes("PatteAr", 1.8, 1.0, 0.95, 1.5, ombre)
	g.joues(0.9, 7.0, -1.8, 0.45)
	g.lueur(corps, legendaire, 10, 0.8)
	return corps
end

-- Diplodo : violet vif, cou en perles vers l'avant, longue queue, épines néon
ESPECES.Diplodo = function(g, C)
	local base = g.hex("B15CFF")
	local ombre = C.ombre(base)
	local mythique = g.accent("Mythique")
	local corps = g.boule("Corps", 3.4, V(0, 3.0, 0.8), base)
	g.boule("Ventre", 2.4, V(0, 2.7, 0.2), C.lumiere(C.lumiere(base)))
	g.boule("Cou1", 1.3, V(0, 4.0, -1.0), base)
	g.boule("Cou2", 1.1, V(0, 4.8, -1.8), base)
	g.boule("Cou3", 1.0, V(0, 5.6, -2.4), base)
	g.boule("Tete", 2.4, V(0, 6.6, -3.2), C.lumiere(base))
	g.yeux(0.55, 6.85, -4.1, 0.9)
	g.boule("Queue", 1.3, V(0, 3.2, 2.6), base)
	g.boule("QueueMilieu", 1.0, V(0, 2.9, 3.5), base)
	g.p("coin", "QueueBout", V(0.5, 0.5, 1.6), V(0, 2.7, 4.6), mythique, V(0, 180, 0), true)
	local epines = { { -0.1, 4.6 }, { 0.6, 4.85 }, { 1.3, 4.75 }, { 2.0, 4.35 } }
	for i, ep in ipairs(epines) do
		g.p("coin", "Epine" .. i, V(0.25, 0.6, 0.7), V(0, ep[2], ep[1]), mythique, nil, true)
	end
	g.paire("boule", "Tache", V(0.8, 0.8, 0.8), V(1.2, 3.8, 1.2), ombre)
	g.pattes("PatteAv", 1.6, 1.0, 0.95, -0.1, ombre)
	g.pattes("PatteAr", 1.6, 1.0, 0.95, 1.8, ombre)
	g.joues(0.85, 6.3, -4.0, 0.4)
	g.lueur(corps, mythique, 12, 1.2)
	return corps
end

-- Therizino : ventre tout rond, griffes géantes néon, auréole et aura divines
ESPECES.Therizino = function(g, C)
	local divin = C.raretes.Divin or C.gemme
	local base = g.hex("5CE1E6")
	local ombre = C.ombre(base)
	local corps = g.boule("Corps", 3.2, V(0, 3.4, 0.4), base)
	g.boule("Ventre", 2.6, V(0, 3.1, -0.3), C.creme)
	g.p("cyl", "Cou", V(1.2, 0.9, 0.9), V(0, 5.1, -0.4), base, V(0, 0, 90))
	g.boule("Tete", 2.4, V(0, 6.3, -0.6), base)
	g.yeux(0.55, 6.55, -1.5, 0.9)
	g.p("coin", "Bec", V(0.7, 0.45, 0.7), V(0, 5.9, -1.9), C.dore)
	g.p("coin", "Plumes", V(0.3, 0.9, 1.0), V(0, 7.5, -0.2), g.hex("FF5CE1"))
	g.pattes("PatteAr", 1.6, 1.0, 0.8, 0.6, ombre)
	g.paire("boule", "Pied", V(1.1, 1.1, 1.1), V(0.8, 0.35, 0.2), ombre)
	g.paire("boule", "PatteAv", V(0.8, 0.8, 0.8), V(1.6, 4.0, -0.5), base)
	for i = 1, 3 do
		local dx = (i - 2) * 0.25
		g.p("bloc", "GriffeG" .. i, V(0.2, 0.2, 1.4), V(-1.6 + dx, 3.5, -1.3), divin, V(-30, 0, 0), true)
		g.p("bloc", "GriffeD" .. i, V(0.2, 0.2, 1.4), V(1.6 + dx, 3.5, -1.3), divin, V(-30, 0, 0), true)
	end
	g.p("coin", "Queue", V(1.1, 1.2, 2.0), V(0, 3.0, 2.2), base, V(0, 180, 0))
	local halo = g.p("cyl", "Aureole", V(0.15, 1.6, 1.6), V(0, 8.2, -0.6), C.dore, V(0, 0, 90), true)
	if halo then
		halo.Transparency = 0.2
		halo.CastShadow = false
	end
	local aura = g.boule("Aura", 6.0, V(0, 4.0, 0.2), divin, true)
	if aura then
		aura.Transparency = 0.85
		aura.CastShadow = false
	end
	g.joues(0.85, 6.0, -1.4, 0.4)
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
