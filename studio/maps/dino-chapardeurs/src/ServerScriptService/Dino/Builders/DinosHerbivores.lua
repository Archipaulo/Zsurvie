-- Constructeur DinosHerbivores : gabarits des espèces de la famille « Herbivore »,
-- rangés dans ServerStorage.Dino.Dinos (clonés ensuite par Systemes/Tapis).
-- Style jouet en blocs, regard vers -Z local, pivot au sol sous le dino.
local M = {}

local BUDGET = 30 -- parts maximum par gabarit
local V = Vector3.new

-- fabrique d'un gabarit : renvoie un petit outil de construction à l'échelle s
local function nouvelOutil(ctx, modele, s)
	local Outils = ctx.Outils
	local Charte = ctx.Charte
	local g = { n = 0, s = s, modele = modele }

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

	-- une paire de gros yeux sur les côtés de la tête (x = demi-écart)
	function g.yeux(x, y, z, r)
		local cotes = { { "G", -1 }, { "D", 1 } }
		for _, c in ipairs(cotes) do
			local sens = c[2]
			g.p("boule", "Oeil" .. c[1], V(r, r, r), V(sens * x, y, z), Charte.creme)
			g.p("boule", "Pupille" .. c[1], V(r * 0.55, r * 0.55, r * 0.55), V(sens * (x + r * 0.28), y + r * 0.06, z - r * 0.22), Charte.encre)
		end
	end

	-- une paire symétrique (G à -X, D à +X) ; rotZ inversée côté droit
	function g.paire(forme, nom, t, pos, couleur, rot, neon)
		local rotG, rotD = rot, rot
		if rot then
			rotG = V(rot.X, rot.Y, rot.Z)
			rotD = V(rot.X, -rot.Y, -rot.Z)
		end
		g.p(forme, nom .. "G", t, V(-pos.X, pos.Y, pos.Z), couleur, rotG, neon)
		g.p(forme, nom .. "D", t, V(pos.X, pos.Y, pos.Z), couleur, rotD, neon)
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

-- Galli : petit coureur bipède, long cou, bec
ESPECES.Galli = function(g, C)
	local base = C.sable
	local dos = C.terre
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(1.6, 1.4, 2.2), V(0, 2.6, 0.1), base)
	g.p("bloc", "Dos", V(1.2, 0.3, 1.8), V(0, 3.4, 0.2), dos)
	g.p("bloc", "Ventre", V(1.3, 0.3, 1.6), V(0, 1.85, 0.1), C.creme)
	g.p("bloc", "Cou", V(0.6, 1.8, 0.6), V(0, 3.9, -1.0), C.lumiere(base), V(-25, 0, 0))
	g.p("bloc", "Tete", V(0.9, 0.8, 1.1), V(0, 4.9, -1.55), base)
	g.p("coin", "Bec", V(0.7, 0.4, 0.8), V(0, 4.7, -2.45), C.ombre(dos))
	g.p("bloc", "Crete", V(0.2, 0.4, 0.8), V(0, 5.45, -1.5), C.herbe)
	g.p("coin", "Queue", V(0.9, 1.0, 2.4), V(0, 2.8, 2.4), base, V(0, 180, 0))
	g.p("coin", "QueueBout", V(0.5, 0.5, 1.2), V(0, 2.9, 4.1), dos, V(0, 180, 0))
	g.paire("bloc", "PatteAr", V(0.45, 2.0, 0.5), V(0.5, 1.0, 0.4), ombre)
	g.paire("bloc", "Pied", V(0.6, 0.25, 0.9), V(0.5, 0.125, 0.2), dos)
	g.paire("bloc", "PatteAv", V(0.25, 0.7, 0.25), V(0.8, 2.3, -0.9), base, V(30, 0, 0))
	g.yeux(0.45, 5.0, -1.7, 0.5)
	return corps
end

-- Pachy : bipède trapu au gros dôme
ESPECES.Pachy = function(g, C)
	local base = C.terre
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(2.0, 1.8, 2.4), V(0, 2.5, 0.2), base)
	g.p("bloc", "Ventre", V(1.6, 0.4, 2.0), V(0, 1.65, 0.1), C.sable)
	g.p("bloc", "Tete", V(1.4, 1.2, 1.4), V(0, 3.6, -1.4), base)
	g.p("boule", "Dome", V(1.6, 1.6, 1.6), V(0, 4.35, -1.35), C.lumiere(C.sable))
	g.paire("boule", "Bosse", V(0.45, 0.45, 0.45), V(0.75, 4.0, -0.8), C.violet)
	g.p("boule", "BosseHaut", V(0.45, 0.45, 0.45), V(0, 4.3, -0.5), C.violet)
	g.p("bloc", "Museau", V(1.0, 0.7, 0.6), V(0, 3.3, -2.2), C.lumiere(base))
	g.p("bloc", "Rayure1", V(1.2, 0.2, 0.6), V(0, 3.45, 0.0), C.ombre(C.violet))
	g.p("bloc", "Rayure2", V(1.2, 0.2, 0.6), V(0, 3.45, 1.0), C.ombre(C.violet))
	g.p("coin", "Queue", V(1.2, 1.2, 2.6), V(0, 2.7, 2.6), base, V(0, 180, 0))
	g.p("coin", "QueueBout", V(0.6, 0.6, 1.4), V(0, 2.8, 4.5), ombre, V(0, 180, 0))
	g.paire("bloc", "PatteAr", V(0.7, 1.8, 0.8), V(0.6, 0.9, 0.5), ombre)
	g.paire("bloc", "Pied", V(0.9, 0.3, 1.1), V(0.6, 0.15, 0.3), C.ombre(ombre))
	g.paire("bloc", "PatteAv", V(0.3, 0.8, 0.3), V(1.0, 2.3, -0.9), base, V(30, 0, 0))
	g.yeux(0.65, 3.75, -1.9, 0.55)
	return corps
end

-- Tricera : collerette, trois cornes, bec
ESPECES.Tricera = function(g, C)
	local base = C.herbe
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(2.6, 2.0, 3.6), V(0, 2.4, 0.4), base)
	g.p("bloc", "Ventre", V(2.2, 0.4, 3.0), V(0, 1.35, 0.4), C.sable)
	g.p("bloc", "Dos", V(2.0, 0.4, 2.8), V(0, 3.55, 0.5), C.jungle)
	g.p("bloc", "Tete", V(1.8, 1.5, 1.6), V(0, 2.6, -2.1), base)
	g.p("coin", "Bec", V(1.2, 0.8, 0.8), V(0, 2.2, -3.3), C.ombre(C.sable))
	g.p("bloc", "Collerette", V(3.4, 2.6, 0.4), V(0, 3.4, -1.3), C.jungle, V(20, 0, 0))
	g.p("bloc", "Bordure", V(3.8, 3.0, 0.3), V(0, 3.45, -1.1), C.sable, V(20, 0, 0))
	g.paire("bloc", "Corne", V(0.3, 0.3, 1.6), V(0.5, 3.4, -2.8), C.creme, V(35, 0, 0))
	g.p("bloc", "CorneNez", V(0.3, 0.3, 0.7), V(0, 2.95, -3.05), C.creme, V(40, 0, 0))
	g.paire("bloc", "PatteAv", V(0.8, 1.5, 0.8), V(0.8, 0.75, -0.8), ombre)
	g.paire("bloc", "PatteAr", V(0.8, 1.5, 0.8), V(0.8, 0.75, 1.6), ombre)
	g.p("coin", "Queue", V(1.2, 1.2, 2.4), V(0, 2.5, 3.4), base, V(0, 180, 0))
	g.yeux(0.85, 3.0, -2.4, 0.55)
	return corps
end

-- Stego : rangée de plaques et queue à piques
ESPECES.Stego = function(g, C)
	local base = C.jungle
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(2.4, 2.2, 4.0), V(0, 2.8, 0.3), base)
	g.p("bloc", "Ventre", V(2.0, 0.4, 3.4), V(0, 1.65, 0.3), C.sable)
	g.p("bloc", "Cou", V(1.2, 1.1, 1.0), V(0, 2.3, -1.9), ombre)
	g.p("bloc", "Tete", V(1.2, 1.0, 1.4), V(0, 2.0, -2.7), base)
	local plaques = { { -1.2, 1.0 }, { -0.3, 1.5 }, { 0.6, 1.7 }, { 1.5, 1.4 }, { 2.4, 1.0 } }
	for i, pl in ipairs(plaques) do
		local couleur = C.lave
		if i % 2 == 0 then
			couleur = C.dore
		end
		g.p("bloc", "Plaque" .. i, V(0.25, pl[2], pl[2]), V(0, 3.9 + pl[2] * 0.25, pl[1]), couleur, V(45, 0, 0))
	end
	g.p("coin", "Queue", V(1.2, 1.2, 3.0), V(0, 2.8, 3.8), base, V(0, 180, 0))
	g.paire("bloc", "Pique", V(1.2, 0.2, 0.2), V(0.8, 3.0, 4.3), C.creme, V(0, 0, -25))
	g.paire("bloc", "PiqueBout", V(1.0, 0.2, 0.2), V(0.6, 2.9, 5.0), C.creme, V(0, 0, -25))
	g.paire("bloc", "PatteAv", V(0.8, 1.6, 0.8), V(0.8, 0.8, -0.9), ombre)
	g.paire("bloc", "PatteAr", V(0.9, 2.0, 1.0), V(0.8, 1.0, 1.5), ombre)
	g.yeux(0.55, 2.3, -2.9, 0.5)
	return corps
end

-- Parasaure : longue crête tubulaire vers l'arrière
ESPECES.Parasaure = function(g, C)
	local base = C.gemme:Lerp(C.jungle, 0.4)
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(2.2, 2.0, 3.2), V(0, 2.8, 0.3), base)
	g.p("bloc", "Ventre", V(1.8, 0.4, 2.6), V(0, 1.75, 0.3), C.creme)
	g.p("bloc", "Cou", V(0.9, 1.6, 0.9), V(0, 3.9, -1.3), base, V(-25, 0, 0))
	g.p("bloc", "Tete", V(1.0, 1.0, 1.6), V(0, 4.7, -1.9), base)
	g.p("coin", "Bec", V(0.9, 0.5, 0.8), V(0, 4.45, -3.0), C.sable)
	g.p("bloc", "Crete", V(0.4, 0.45, 2.6), V(0, 5.6, -0.9), C.violet, V(-30, 0, 0))
	g.p("boule", "CreteBout", V(0.55, 0.55, 0.55), V(0, 6.2, 0.2), C.lumiere(C.violet))
	for i = 1, 3 do
		g.p("bloc", "Rayure" .. i, V(2.25, 0.3, 0.4), V(0, 3.7, -0.4 + (i - 1) * 0.8), C.ombre(C.violet))
	end
	g.p("coin", "Queue", V(1.2, 1.4, 3.0), V(0, 2.9, 3.3), base, V(0, 180, 0))
	g.paire("bloc", "PatteAr", V(0.8, 2.0, 0.9), V(0.7, 1.0, 0.8), ombre)
	g.paire("bloc", "PatteAv", V(0.5, 1.4, 0.5), V(0.7, 0.7, -0.9), ombre)
	g.yeux(0.5, 4.85, -2.2, 0.5)
	return corps
end

-- Ankylo : large carapace, piques latérales, queue massue
ESPECES.Ankylo = function(g, C)
	local base = C.pierre
	local ombre = C.ombre(base)
	local epique = C.raretes.Epique or C.violet
	local corps = g.p("bloc", "Corps", V(3.2, 1.6, 4.0), V(0, 2.0, 0.3), base)
	g.p("bloc", "Carapace", V(3.6, 0.6, 3.6), V(0, 3.0, 0.3), C.terre)
	g.p("bloc", "Ventre", V(2.8, 0.3, 3.4), V(0, 1.15, 0.3), C.sable)
	g.p("bloc", "Tete", V(1.6, 1.1, 1.3), V(0, 1.9, -2.2), C.lumiere(base))
	g.paire("bloc", "Corne", V(0.35, 0.35, 0.9), V(0.8, 2.35, -1.9), C.creme, V(0, 45, 0))
	g.paire("bloc", "PiqueAv", V(1.0, 0.3, 0.3), V(2.0, 2.6, -0.6), C.lumiere(C.sable), V(0, 0, -20))
	g.paire("bloc", "PiqueAr", V(1.0, 0.3, 0.3), V(2.0, 2.6, 1.2), C.lumiere(C.sable), V(0, 0, -20))
	g.paire("boule", "Bosse", V(0.7, 0.7, 0.7), V(0.9, 3.35, 0.3), C.ombre(C.sable))
	g.p("boule", "BosseAv", V(0.7, 0.7, 0.7), V(0, 3.35, -0.8), C.ombre(C.sable))
	g.p("bloc", "Queue", V(0.9, 0.8, 3.0), V(0, 2.1, 3.6), base)
	g.p("boule", "Massue", V(1.3, 1.3, 1.3), V(0, 2.1, 5.4), C.ombre(C.terre))
	g.paire("boule", "MassueCote", V(0.9, 0.9, 0.9), V(0.7, 2.1, 5.4), epique)
	g.paire("bloc", "PatteAv", V(0.9, 1.3, 0.9), V(1.1, 0.65, -0.9), ombre)
	g.paire("bloc", "PatteAr", V(0.9, 1.3, 0.9), V(1.1, 0.65, 1.5), ombre)
	g.yeux(0.8, 2.2, -2.6, 0.5)
	return corps
end

-- Iguano : crête dorsale et pouces-piques dorés
ESPECES.Iguano = function(g, C)
	local base = C.gemme:Lerp(C.nuit, 0.35)
	local ombre = C.ombre(base)
	local epique = C.raretes.Epique or C.violet
	local corps = g.p("bloc", "Corps", V(2.4, 2.4, 3.4), V(0, 3.2, 0.3), base)
	g.p("bloc", "Ventre", V(2.0, 0.4, 2.8), V(0, 1.95, 0.2), C.sable)
	g.p("bloc", "Cou", V(1.1, 1.4, 1.1), V(0, 4.3, -1.5), base, V(-30, 0, 0))
	g.p("bloc", "Tete", V(1.2, 1.1, 1.9), V(0, 4.9, -2.3), base)
	g.p("bloc", "Museau", V(1.0, 0.7, 0.6), V(0, 4.7, -3.45), C.lumiere(base))
	g.p("coin", "Crete1", V(0.3, 0.6, 1.0), V(0, 4.7, -0.6), epique)
	g.p("coin", "Crete2", V(0.3, 0.7, 1.0), V(0, 4.75, 0.5), epique)
	g.p("coin", "Crete3", V(0.3, 0.6, 1.0), V(0, 4.7, 1.5), epique)
	g.p("coin", "Queue", V(1.4, 1.6, 3.6), V(0, 3.2, 3.8), base, V(0, 180, 0))
	g.paire("bloc", "PatteAr", V(1.0, 2.4, 1.2), V(0.8, 1.2, 1.0), ombre)
	g.paire("bloc", "PatteAv", V(0.6, 1.8, 0.6), V(1.0, 0.9, -1.2), ombre)
	g.paire("bloc", "Pouce", V(0.25, 0.9, 0.25), V(1.35, 2.0, -1.4), C.dore, V(-25, 0, 0))
	g.yeux(0.6, 5.1, -2.7, 0.55)
	g.lueur(corps, epique, 8, 0.6)
	return corps
end

-- Brachio : pattes avant hautes, cou dressé, collier d'or
ESPECES.Brachio = function(g, C)
	local base = C.sable:Lerp(C.dore, 0.5)
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(2.6, 2.4, 3.6), V(0, 3.6, 0.4), base)
	g.p("bloc", "Ventre", V(2.2, 0.4, 3.0), V(0, 2.35, 0.4), C.creme)
	g.paire("bloc", "PatteAv", V(0.9, 2.8, 0.9), V(0.9, 1.4, -0.8), ombre)
	g.paire("bloc", "PatteAr", V(0.9, 2.4, 1.0), V(0.9, 1.2, 1.6), ombre)
	g.p("bloc", "Cou", V(1.0, 4.6, 1.0), V(0, 6.6, -1.5), base, V(-12, 0, 0))
	g.p("bloc", "Collier", V(1.25, 0.35, 1.25), V(0, 5.0, -1.3), C.dore, V(-12, 0, 0))
	g.p("bloc", "TacheCou1", V(1.05, 0.4, 1.05), V(0, 6.2, -1.45), C.terre, V(-12, 0, 0))
	g.p("bloc", "TacheCou2", V(1.05, 0.4, 1.05), V(0, 7.4, -1.7), C.terre, V(-12, 0, 0))
	g.p("bloc", "Tete", V(1.2, 1.0, 1.6), V(0, 9.1, -2.3), base)
	g.p("boule", "Crete", V(0.9, 0.9, 0.9), V(0, 9.6, -2.0), C.dore)
	g.p("bloc", "Museau", V(1.0, 0.6, 0.6), V(0, 8.95, -3.3), C.lumiere(base))
	g.p("coin", "Queue", V(1.3, 1.4, 3.6), V(0, 3.8, 4.0), base, V(0, 180, 0))
	g.p("boule", "Tache1", V(0.8, 0.8, 0.8), V(-0.9, 4.6, 0.0), C.terre)
	g.p("boule", "Tache2", V(0.8, 0.8, 0.8), V(0.8, 4.7, 0.9), C.terre)
	g.p("boule", "Tache3", V(0.8, 0.8, 0.8), V(0, 4.8, 1.8), C.terre)
	g.yeux(0.6, 9.3, -2.6, 0.5)
	g.lueur(corps, C.raretes.Legendaire or C.dore, 10, 0.8)
	return corps
end

-- Diplodo : cou et queue immenses à l'horizontale, épines néon
ESPECES.Diplodo = function(g, C)
	local base = C.violet
	local ombre = C.ombre(base)
	local mythique = C.raretes.Mythique or C.alerte
	local corps = g.p("bloc", "Corps", V(2.6, 2.2, 3.6), V(0, 3.3, 0.6), base)
	g.p("bloc", "Ventre", V(2.2, 0.4, 3.0), V(0, 2.15, 0.6), C.lumiere(C.lumiere(base)))
	g.p("bloc", "Rayure1", V(2.65, 0.3, 0.4), V(0, 3.6, 0.0), ombre)
	g.p("bloc", "Rayure2", V(2.65, 0.3, 0.4), V(0, 3.6, 1.2), ombre)
	g.paire("bloc", "PatteAv", V(0.9, 2.2, 0.9), V(0.9, 1.1, -0.6), ombre)
	g.paire("bloc", "PatteAr", V(0.9, 2.2, 0.9), V(0.9, 1.1, 1.8), ombre)
	g.p("bloc", "Cou", V(1.1, 1.1, 2.4), V(0, 4.0, -1.9), base, V(20, 0, 0))
	g.p("bloc", "CouHaut", V(0.9, 0.9, 2.2), V(0, 5.0, -3.6), base, V(30, 0, 0))
	g.p("bloc", "Tete", V(1.0, 0.9, 1.4), V(0, 5.8, -4.9), C.lumiere(base))
	g.p("bloc", "Queue", V(1.2, 1.2, 2.6), V(0, 3.3, 3.4), base, V(10, 0, 0))
	g.p("bloc", "QueueMilieu", V(0.7, 0.7, 2.6), V(0, 2.8, 5.8), base, V(8, 0, 0))
	g.p("coin", "QueueBout", V(0.4, 0.4, 2.4), V(0, 2.5, 8.0), mythique, V(0, 180, 0), true)
	for i = 1, 4 do
		g.p("coin", "Epine" .. i, V(0.25, 0.6, 0.7), V(0, 4.6, -0.6 + (i - 1) * 1.0), mythique, nil, true)
	end
	g.yeux(0.5, 6.0, -5.2, 0.5)
	g.lueur(corps, mythique, 12, 1.2)
	return corps
end

-- Therizino : ventre rond, griffes géantes néon, aura et auréole divines
ESPECES.Therizino = function(g, C)
	local divin = C.raretes.Divin or C.gemme
	local base = C.creme:Lerp(C.gemme, 0.35)
	local ombre = C.ombre(base)
	local corps = g.p("bloc", "Corps", V(2.6, 3.0, 2.8), V(0, 3.6, 0.4), base)
	g.p("boule", "Ventre", V(2.6, 2.6, 2.6), V(0, 3.0, 0.0), C.creme)
	g.p("bloc", "Cou", V(0.9, 2.4, 0.9), V(0, 5.6, -0.9), base, V(-15, 0, 0))
	g.p("bloc", "Tete", V(1.0, 1.0, 1.4), V(0, 6.9, -1.5), base)
	g.p("coin", "Bec", V(0.8, 0.5, 0.7), V(0, 6.7, -2.5), C.dore)
	g.p("coin", "Plumes", V(0.3, 0.9, 1.2), V(0, 7.6, -1.2), C.gemme)
	g.paire("bloc", "PatteAr", V(1.0, 2.2, 1.1), V(0.8, 1.1, 0.8), ombre)
	g.paire("bloc", "Pied", V(1.2, 0.3, 1.4), V(0.8, 0.15, 0.6), C.ombre(ombre))
	g.paire("bloc", "PatteAv", V(0.5, 1.6, 0.5), V(1.5, 4.0, -0.9), C.gemme, V(30, 0, 0))
	for i = 1, 3 do
		local dx = (i - 2) * 0.25
		g.p("bloc", "GriffeG" .. i, V(0.2, 0.2, 1.8), V(-1.5 + dx, 3.2, -2.2), divin, V(-30, 0, 0), true)
		g.p("bloc", "GriffeD" .. i, V(0.2, 0.2, 1.8), V(1.5 + dx, 3.2, -2.2), divin, V(-30, 0, 0), true)
	end
	g.p("coin", "Queue", V(1.2, 1.4, 2.6), V(0, 3.6, 2.9), C.gemme, V(0, 180, 0))
	local halo = g.p("cyl", "Aureole", V(0.15, 1.6, 1.6), V(0, 8.3, -1.5), C.dore, V(0, 0, 90), true)
	if halo then
		halo.Transparency = 0.2
		halo.CastShadow = false
	end
	local aura = g.p("boule", "Aura", V(5.5, 5.5, 5.5), V(0, 4.0, 0.2), divin, nil, true)
	if aura then
		aura.Transparency = 0.85
		aura.CastShadow = false
	end
	g.yeux(0.5, 7.1, -1.8, 0.5)
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
