-- Système Recompenses : série de connexion quotidienne, prime de temps de jeu et coffre caché des falaises.
-- Attributs joueur gérés ici : Serie, DerniereConnexion (jour UTC), CoffreOuvert (os.time de la dernière ouverture).
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

local ATTENTE_DONNEES = 20 -- secondes max d'attente du chargement des données
local ATTENTE_ARGENT = 10 -- secondes max d'attente de l'attribut Argent (posé par Economie)
local DISTANCE_COFFRE = 18 -- distance max (studs) entre le joueur et le coffre pour l'ouvrir
local ANTI_REBOND = 1 -- secondes entre deux essais d'ouverture d'un même joueur

-- nombre fini (ni NaN, ni infini)
local function estFini(n)
	return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

local function estJoueur(joueur)
	return typeof(joueur) == "Instance" and joueur:IsA("Player") and joueur.Parent == Players
end

local function lireNombre(joueur, nom, defaut)
	local v = joueur:GetAttribute(nom)
	if estFini(v) then
		return v
	end
	return defaut
end

local function reglage(valeur, defaut)
	if estFini(valeur) and valeur >= 0 then
		return valeur
	end
	return defaut
end

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local E = ctx.Equilibrage
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Reseau = ctx.Reseau

	-- ===== réglages =====
	local R = E.recompenses or {}
	local rConnexion = R.connexion or {}
	local rTemps = R.tempsDeJeu or {}
	local rCoffre = R.coffre or {}

	local CONNEXION_BASE = reglage(rConnexion.base, 500)
	local CONNEXION_PAR_JOUR = reglage(rConnexion.parJour, 500)
	local SERIE_MAX = math.max(1, math.floor(reglage(rConnexion.max, 7)))

	local TEMPS_INTERVALLE = math.max(10, reglage(rTemps.intervalle, 600))
	local TEMPS_GAIN = reglage(rTemps.gain, 0.25)

	local COFFRE_MINIMUM = reglage(rCoffre.gainMinimum, 1000)
	local COFFRE_SECONDES = reglage(rCoffre.secondesDeRevenu, 120)
	local COFFRE_RECHARGE = reglage(rCoffre.recharge, 86400)

	-- ===== outils =====
	local function montant(n)
		local ok, texte = pcall(Charte.argent, n)
		if ok and type(texte) == "string" then
			return texte
		end
		return tostring(math.floor(n)) .. " $"
	end

	local function notifier(joueur, texte, genre)
		if not Reseau or not Reseau.Notification then return end
		pcall(function()
			Reseau.Notification:FireClient(joueur, texte, genre or "info")
		end)
	end

	local function effet(genre, position, donnees)
		if not Reseau or not Reseau.Effet then return end
		pcall(function()
			Reseau.Effet:FireAllClients(genre, position, donnees)
		end)
	end

	local function donner(joueur, n, source)
		if not estJoueur(joueur) or not estFini(n) or n <= 0 then
			return false
		end
		local total = Bus.demander("AjouterArgent", joueur, math.floor(n + 0.5), source)
		return total ~= nil
	end

	local function revenuParSeconde(joueur)
		local r = lireNombre(joueur, "RevenuParSeconde", 0)
		if r < 0 then
			return 0
		end
		return r
	end

	local function dureeTexte(secondes)
		secondes = math.max(0, math.floor(secondes))
		local h = math.floor(secondes / 3600)
		local mn = math.floor((secondes % 3600) / 60)
		if h > 0 then
			return string.format("%d h %02d min", h, mn)
		end
		if mn > 0 then
			return string.format("%d min", mn)
		end
		return string.format("%d s", secondes)
	end

	-- attend que les données (et l'argent) du joueur soient prêtes ; renvoie true si c'est le cas
	local function attendreDonnees(joueur)
		local debut = os.clock()
		while estJoueur(joueur) and joueur:GetAttribute("DonneesChargees") ~= true do
			if os.clock() - debut >= ATTENTE_DONNEES then
				return false
			end
			task.wait(0.25)
		end
		if not estJoueur(joueur) then
			return false
		end
		debut = os.clock()
		while estJoueur(joueur) and not estFini(joueur:GetAttribute("Argent")) do
			if os.clock() - debut >= ATTENTE_ARGENT then
				break
			end
			task.wait(0.25)
		end
		return estJoueur(joueur)
	end

	-- ===== 1. série de connexion =====
	local serieTraitee = {} -- [joueur] = true

	local function traiterSerie(joueur)
		if serieTraitee[joueur] then return end
		serieTraitee[joueur] = true

		local jour = math.floor(os.time() / 86400)
		local derniere = math.floor(lireNombre(joueur, "DerniereConnexion", 0))
		local serie = math.floor(lireNombre(joueur, "Serie", 0))

		if derniere == jour then
			-- déjà récompensé aujourd'hui
			return
		end
		if derniere > jour then
			-- horloge incohérente : on ne touche à rien
			return
		end
		if derniere == jour - 1 then
			serie = math.min(math.max(serie, 0) + 1, SERIE_MAX)
		else
			serie = 1
		end
		if serie < 1 then
			serie = 1
		end

		joueur:SetAttribute("Serie", serie)
		joueur:SetAttribute("DerniereConnexion", jour)

		local gain = CONNEXION_BASE + CONNEXION_PAR_JOUR * (serie - 1)
		if donner(joueur, gain, "Connexion") then
			local texte
			if serie >= SERIE_MAX then
				texte = string.format("Série de connexion : jour %d (maximum) ! +%s", serie, montant(gain))
			elseif serie > 1 then
				texte = string.format("Série de connexion : jour %d ! +%s (reviens demain pour plus)", serie, montant(gain))
			else
				texte = string.format("Bonus de connexion du jour : +%s. Reviens demain pour lancer ta série !", montant(gain))
			end
			notifier(joueur, texte, "succes")
		end
	end

	-- ===== 2. prime de temps de jeu =====
	local jetons = {} -- [joueur] = table unique de la session en cours

	local function boucleTempsDeJeu(joueur, jeton)
		while estJoueur(joueur) and jetons[joueur] == jeton do
			task.wait(TEMPS_INTERVALLE)
			if not estJoueur(joueur) or jetons[joueur] ~= jeton then
				return
			end
			if joueur:GetAttribute("DonneesChargees") == true then
				local gain = math.max(100, revenuParSeconde(joueur) * 60 * TEMPS_GAIN)
				if donner(joueur, gain, "TempsDeJeu") then
					notifier(joueur, string.format("Merci de jouer ! Prime de présence : +%s", montant(gain)), "succes")
				end
			end
		end
	end

	-- ===== arrivée / départ =====
	local function arrivee(joueur)
		if jetons[joueur] then return end
		local jeton = {}
		jetons[joueur] = jeton
		task.spawn(boucleTempsDeJeu, joueur, jeton)
		task.spawn(function()
			if attendreDonnees(joueur) and joueur:GetAttribute("DonneesChargees") == true then
				local ok = pcall(traiterSerie, joueur)
				if not ok then
					serieTraitee[joueur] = nil
				end
			end
		end)
	end

	local dernierEssai = {} -- [joueur] = os.clock() du dernier essai d'ouverture
	local affichages = {} -- [joueur] = { gui, texte, dernier } : étiquette personnelle « Prêt ! » / minuteur

	local function depart(joueur)
		jetons[joueur] = nil
		serieTraitee[joueur] = nil
		dernierEssai[joueur] = nil
		local a = affichages[joueur]
		affichages[joueur] = nil
		if a and a.gui then
			pcall(function()
				a.gui:Destroy()
			end)
		end
	end

	-- ===== 3. le coffre caché =====
	local racine = ctx.racine
	local dossier = racine:FindFirstChild("Coffre")
	if dossier then
		dossier:ClearAllChildren()
	else
		dossier = Outils.dossier(racine, "Coffre")
	end

	local position = Plan.coffre or Vector3.new(160, 22, -158)
	-- le coffre regarde vers le centre du monde (face avant = -Z local)
	local cible = Vector3.new(0, position.Y, 0)
	local origine
	if (cible - position).Magnitude > 0.1 then
		origine = CFrame.lookAt(position, cible)
	else
		origine = CFrame.new(position)
	end

	local modele = Outils.modele(dossier, "CoffreTresor")
	local couvercle = {} -- parts du couvercle (animées à l'ouverture)

	local function part(fabrique, props, estCouvercle, parent)
		local p = fabrique(parent or modele, props)
		p.CanCollide = props.CanCollide == true
		if estCouvercle then
			table.insert(couvercle, p)
		end
		return p
	end

	local function ici(x, y, z)
		return origine * CFrame.new(x, y, z)
	end

	-- cylindre couché le long de X (axe natif Roblox) ou debout (axe Y)
	local DEBOUT = CFrame.Angles(0, 0, math.rad(90))
	-- cube tourné pour pointer un sommet vers le haut : gemme taillée
	local DIAMANT = CFrame.Angles(math.rad(35.26), 0, math.rad(45))

	-- palette : bois de coffre chaud en trois teintes, or métallique, pierre du socle
	local hex = Charte.hex
	local BOIS = hex("A0552A")
	local BOIS_CLAIR = Charte.lumiere(BOIS)
	local BOIS_SOMBRE = Charte.ombre(Charte.ombre(BOIS))
	local OR = Charte.dore
	local OR_CLAIR = Charte.lumiere(OR)
	local OR_SOMBRE = Charte.ombre(OR)
	local PIERRE = Charte.lumiere(Charte.pierre)

	local PLANCHES = Enum.Material.WoodPlanks
	local BOIS_MAT = Enum.Material.Wood
	local METAL = Enum.Material.Metal
	local VERRE = Enum.Material.Glass
	local NEON = Enum.Material.Neon

	-- dimensions de la caisse : bas à BAS, dessus (et axe du couvercle) à HAUT
	local BAS = 0.5
	local HAUT = 2.7
	local MI = (BAS + HAUT) / 2
	local RAYON = 1.7 -- rayon du couvercle bombé

	-- ===== socle de pierre cerclé d'or, halo doré =====
	local halo = part(Outils.cylindre, { Name = "Halo", Size = Vector3.new(0.06, 8.6, 8.6), CFrame = ici(0, 0.03, 0) * DEBOUT, Color = OR, Material = NEON, Transparency = 0.72, CastShadow = false })
	part(Outils.cylindre, { Name = "SocleBord", Size = Vector3.new(0.16, 7.5, 7.5), CFrame = ici(0, 0.08, 0) * DEBOUT, Color = OR_SOMBRE, Material = METAL })
	part(Outils.cylindre, { Name = "Socle", Size = Vector3.new(0.3, 7, 7), CFrame = ici(0, 0.15, 0) * DEBOUT, Color = PIERRE, Material = Enum.Material.Slate })

	-- pieds en boules dorées
	for _, x in ipairs({ -2.25, 2.25 }) do
		for _, z in ipairs({ -1.45, 1.45 }) do
			part(Outils.boule, { Name = "Pied", Size = Vector3.new(0.55, 0.55, 0.55), CFrame = ici(x, 0.42, z), Color = OR_SOMBRE, Material = METAL })
		end
	end

	-- ===== caisse en planches =====
	local caisse = part(Outils.bloc, { Name = "Caisse", Size = Vector3.new(5, HAUT - BAS, 3.4), CFrame = ici(0, MI, 0), Color = BOIS, Material = PLANCHES, CanCollide = true })
	-- intérieur sombre et lit de trésor lumineux, visibles quand le couvercle se lève
	part(Outils.bloc, { Name = "Fond", Size = Vector3.new(4.6, 0.06, 3), CFrame = ici(0, HAUT + 0.02, 0), Color = BOIS_SOMBRE, Material = BOIS_MAT })
	part(Outils.bloc, { Name = "Tresor", Size = Vector3.new(4.1, 0.1, 2.5), CFrame = ici(0, HAUT + 0.06, 0), Color = OR_CLAIR, Material = NEON, CastShadow = false })
	-- joints de planches devant et derrière
	for _, y in ipairs({ BAS + 0.75, BAS + 1.45 }) do
		for _, z in ipairs({ -1.71, 1.71 }) do
			part(Outils.bloc, { Name = "Joint", Size = Vector3.new(4.9, 0.07, 0.04), CFrame = ici(0, y, z), Color = BOIS_SOMBRE, Material = BOIS_MAT })
		end
		for _, x in ipairs({ -2.51, 2.51 }) do
			part(Outils.bloc, { Name = "Joint", Size = Vector3.new(0.04, 0.07, 3.3), CFrame = ici(x, y, 0), Color = BOIS_SOMBRE, Material = BOIS_MAT })
		end
	end

	-- ===== cerclage de métal doré =====
	part(Outils.bloc, { Name = "CercleBas", Size = Vector3.new(5.12, 0.3, 3.52), CFrame = ici(0, BAS + 0.15, 0), Color = OR_SOMBRE, Material = METAL })
	part(Outils.bloc, { Name = "CercleHaut", Size = Vector3.new(5.12, 0.22, 3.52), CFrame = ici(0, HAUT - 0.11, 0), Color = OR, Material = METAL })
	for _, x in ipairs({ -1.5, 1.5 }) do
		part(Outils.bloc, { Name = "Ferrure", Size = Vector3.new(0.4, HAUT - BAS, 3.5), CFrame = ici(x, MI, 0), Color = OR, Material = METAL })
		-- rivets sur la face avant
		for _, y in ipairs({ BAS + 0.55, BAS + 1.1, BAS + 1.65 }) do
			part(Outils.boule, { Name = "Rivet", Size = Vector3.new(0.17, 0.17, 0.17), CFrame = ici(x, y, -1.76), Color = OR_SOMBRE, Material = METAL })
		end
	end
	-- cornières d'angle
	for _, x in ipairs({ -2.47, 2.47 }) do
		for _, z in ipairs({ -1.67, 1.67 }) do
			part(Outils.bloc, { Name = "Corniere", Size = Vector3.new(0.3, HAUT - BAS + 0.04, 0.3), CFrame = ici(x, MI, z), Color = OR_SOMBRE, Material = METAL })
		end
	end
	-- poignées latérales
	for _, s in ipairs({ -1, 1 }) do
		part(Outils.bloc, { Name = "Poignee", Size = Vector3.new(0.14, 0.14, 1.1), CFrame = ici(s * 2.74, HAUT - 0.75, 0), Color = OR_SOMBRE, Material = METAL })
		for _, z in ipairs({ -0.48, 0.48 }) do
			part(Outils.bloc, { Name = "PoigneeAttache", Size = Vector3.new(0.3, 0.16, 0.16), CFrame = ici(s * 2.62, HAUT - 0.75, z), Color = OR, Material = METAL })
		end
	end

	-- ===== couvercle bombé (animé à l'ouverture) =====
	part(Outils.cylindre, { Name = "Couvercle", Size = Vector3.new(5, 2 * RAYON, 2 * RAYON), CFrame = ici(0, HAUT, 0), Color = BOIS_CLAIR, Material = PLANCHES }, true)
	part(Outils.bloc, { Name = "CouvercleBord", Size = Vector3.new(5.12, 0.2, 3.52), CFrame = ici(0, HAUT + 0.1, 0), Color = OR, Material = METAL }, true)
	for _, x in ipairs({ -2.35, -1.5, 1.5, 2.35 }) do
		part(Outils.cylindre, { Name = "FerrureCouvercle", Size = Vector3.new(0.3, 2 * RAYON + 0.12, 2 * RAYON + 0.12), CFrame = ici(x, HAUT, 0), Color = OR, Material = METAL }, true)
	end
	-- gemmes serties sur le dessus : une grosse au sommet, deux plus petites sur le devant
	local serties = {
		{ 0, HAUT + RAYON + 0.02, 0, 0.62, Charte.gemme, 1 },
		{ -0.75, HAUT + 1.22, -1.22, 0.42, Charte.violet, 0.8 },
		{ 0.75, HAUT + 1.22, -1.22, 0.42, Charte.violet, 0.8 },
	}
	for _, g in ipairs(serties) do
		local d = g[6]
		part(Outils.boule, { Name = "Chaton", Size = Vector3.new(0.62 * d, 0.62 * d, 0.62 * d), CFrame = ici(g[1], g[2], g[3]), Color = OR_SOMBRE, Material = METAL }, true)
		part(Outils.bloc, { Name = "Gemme", Size = Vector3.new(g[4], g[4], g[4]), CFrame = ici(g[1], g[2] + 0.18 * d, g[3] - 0.06 * (1 - d) * 5) * DIAMANT, Color = g[5], Material = VERRE, Transparency = 0.15, Reflectance = 0.2 }, true)
	end

	-- ===== serrure : platine dorée, moraillon avec rubis, trou de serrure =====
	local serrure = part(Outils.bloc, { Name = "Serrure", Size = Vector3.new(1, 1.2, 0.2), CFrame = ici(0, HAUT - 0.35, -1.8), Color = OR, Material = METAL })
	part(Outils.boule, { Name = "TrouSerrure", Size = Vector3.new(0.22, 0.22, 0.22), CFrame = ici(0, HAUT - 0.6, -1.9), Color = Charte.encre })
	part(Outils.bloc, { Name = "FenteSerrure", Size = Vector3.new(0.1, 0.26, 0.04), CFrame = ici(0, HAUT - 0.74, -1.91), Color = Charte.encre })
	part(Outils.cylindre, { Name = "Charniere", Size = Vector3.new(0.5, 0.26, 0.26), CFrame = ici(0, HAUT + 0.3, -1.78), Color = OR_SOMBRE, Material = METAL }, true)
	part(Outils.bloc, { Name = "Moraillon", Size = Vector3.new(0.46, 0.55, 0.1), CFrame = ici(0, HAUT - 0.05, -1.95), Color = OR_SOMBRE, Material = METAL }, true)
	part(Outils.bloc, { Name = "GemmeSerrure", Size = Vector3.new(0.26, 0.26, 0.12), CFrame = ici(0, HAUT - 0.05, -2.02) * CFrame.Angles(0, 0, math.rad(45)), Color = Charte.alerte, Material = VERRE, Transparency = 0.1, Reflectance = 0.2 }, true)

	-- ===== trésor éparpillé devant le coffre (sur le socle, hors du chemin) =====
	local SOL = 0.3 -- dessus du socle
	local pieces = {
		{ -1.7, -2.5, 0, 0 }, { -1.0, -2.9, 40, 0 }, { 1.3, -2.4, 80, 0 }, { 1.9, -2.7, 20, 12 },
		{ 0.3, -3.1, 60, 0 }, { -0.4, -2.4, 15, 0 }, { 2.7, -1.9, 10, 0 }, { -1.8, -2.85, 70, 18 },
	}
	for _, p in ipairs(pieces) do
		part(Outils.cylindre, {
			Name = "Piece",
			Size = Vector3.new(0.1, 0.62, 0.62),
			CFrame = ici(p[1], SOL + 0.05 + p[4] * 0.004, p[2]) * CFrame.Angles(math.rad(p[4]), math.rad(p[3]), 0) * DEBOUT,
			Color = OR,
			Material = METAL,
		})
	end
	-- piles de pièces
	part(Outils.cylindre, { Name = "PilePieces", Size = Vector3.new(0.5, 0.64, 0.64), CFrame = ici(-2.4, SOL + 0.25, -2.1) * DEBOUT, Color = OR, Material = METAL })
	part(Outils.cylindre, { Name = "PilePieces", Size = Vector3.new(0.8, 0.64, 0.64), CFrame = ici(-2.85, SOL + 0.4, -1.3) * DEBOUT, Color = OR_CLAIR, Material = METAL })
	-- lingots empilés en croix
	part(Outils.bloc, { Name = "Lingot", Size = Vector3.new(0.95, 0.3, 0.45), CFrame = ici(1.75, SOL + 0.15, -2.35) * CFrame.Angles(0, math.rad(-15), 0), Color = OR, Material = METAL })
	part(Outils.bloc, { Name = "Lingot", Size = Vector3.new(0.95, 0.3, 0.45), CFrame = ici(1.75, SOL + 0.45, -2.35) * CFrame.Angles(0, math.rad(35), 0), Color = OR_SOMBRE, Material = METAL })
	-- éclats de gemmes
	local eclats = { { -2.0, -2.55, Charte.gemme }, { 1.0, -3.1, Charte.violet }, { 0.5, -2.5, Charte.alerte } }
	for _, g in ipairs(eclats) do
		part(Outils.bloc, { Name = "Eclat", Size = Vector3.new(0.4, 0.4, 0.4), CFrame = ici(g[1], SOL + 0.3, g[2]) * DIAMANT, Color = g[3], Material = VERRE, Transparency = 0.15, Reflectance = 0.2 })
	end

	-- ===== grosse gemme flottante : repère visible de loin (verre taillé à cœur lumineux) =====
	local phareModele = Outils.modele(modele, "Phare")
	local phare = part(Outils.bloc, { Name = "Phare", Size = Vector3.new(1.2, 1.2, 1.2), CFrame = ici(0, 6.7, 0) * DIAMANT, Color = Charte.gemme, Material = VERRE, Transparency = 0.2, Reflectance = 0.25 }, false, phareModele)
	part(Outils.boule, { Name = "Coeur", Size = Vector3.new(0.8, 0.8, 0.8), CFrame = ici(0, 6.7, 0), Color = Charte.lumiere(Charte.gemme), Material = NEON, CastShadow = false }, false, phareModele)
	pcall(function()
		phareModele.PrimaryPart = phare
	end)
	pcall(Outils.animer, phareModele, "flotte", 1)
	pcall(Outils.lumiere, phare, { Range = 14, Brightness = 1.6, Color = Charte.gemme })

	-- halo doré du coffre et reflet de la serrure
	pcall(function()
		local l = Outils.lumiere(caisse, { Range = 14, Brightness = 1.4, Color = OR_CLAIR })
		l.Shadows = true
	end)
	pcall(Outils.lumiere, serrure, { Range = 8, Brightness = 1.2, Color = OR_CLAIR })

	-- étincelles dorées qui montent du halo
	local etincelles
	pcall(function()
		local p = Instance.new("ParticleEmitter")
		p.Name = "Etincelles"
		p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		p.Color = ColorSequence.new(OR_CLAIR, OR)
		p.LightEmission = 1
		p.Size = NumberSequence.new(0.35, 0)
		p.Transparency = NumberSequence.new(0.1, 1)
		p.Lifetime = NumberRange.new(1.2, 2.2)
		p.Rate = 8
		p.Speed = NumberRange.new(0.6, 1.4)
		p.SpreadAngle = Vector2.new(25, 25)
		p.Acceleration = Vector3.new(0, 1.2, 0)
		-- le halo est un cylindre debout : sa face Right regarde le ciel
		p.EmissionDirection = Enum.NormalId.Right
		p.Parent = halo
		etincelles = p
	end)

	pcall(function()
		modele.PrimaryPart = caisse
	end)

	local invite = Outils.invite(caisse, { nom = "Coffre", action = "Ouvrir", objet = "Coffre au trésor", duree = 0.5, distance = 10 })

	-- ===== étiquettes flottantes (style simulateur) =====
	local Style = ctx.Style

	-- titre commun à tous : « 🎁 COFFRE » doré, cerné de noir
	if Style then
		pcall(function()
			local _, lignes = Style.etiquette(caisse, {
				{ texte = "🎁 COFFRE", titre = true, contour = 4, nom = "Titre" },
			}, { Name = "EtiquetteCoffre", largeur = 12, hauteurLigne = 2.6, StudsOffset = Vector3.new(0, 9.4, 0), MaxDistance = 160 })
			if lignes and lignes[1] then
				local haut = Style.boutons.jaune[1]
				local bas = Style.boutons.jaune[2]
				Style.degrade(lignes[1], haut, bas)
			end
		end)
	end

	-- 3723 -> « 1:02:03 » ; 125 -> « 2:05 »
	local function minuteur(secondes)
		secondes = math.max(0, math.floor(secondes))
		local h = math.floor(secondes / 3600)
		local mn = math.floor((secondes % 3600) / 60)
		local s = secondes % 60
		if h > 0 then
			return string.format("%d:%02d:%02d", h, mn, s)
		end
		return string.format("%d:%02d", mn, s)
	end

	-- secondes avant que le coffre soit de nouveau prêt pour ce joueur (0 = prêt)
	local function resteCoffre(joueur)
		local instant = os.time()
		local ouvert = lireNombre(joueur, "CoffreOuvert", 0)
		if ouvert > instant then
			ouvert = instant
		end
		return math.max(0, COFFRE_RECHARGE - (instant - ouvert))
	end

	-- étiquette personnelle (dans le PlayerGui : chacun voit son propre état) « ✅ PRÊT ! » vert ou « ⏳ 3:12:45 »
	local function rafraichir(joueur)
		if not Style or not estJoueur(joueur) then return end
		if joueur:GetAttribute("DonneesChargees") ~= true then return end
		local a = affichages[joueur]
		if not a or not a.gui or not a.gui.Parent then
			local pg = joueur:FindFirstChild("PlayerGui")
			if not pg then return end
			local gui, lignes = Style.etiquette(caisse, {
				{ texte = "", contour = 3.5, nom = "Etat" },
			}, { Name = "EtatCoffre", largeur = 9, hauteurLigne = 1.8, StudsOffset = Vector3.new(0, 7.4, 0), MaxDistance = 90 })
			pcall(function()
				gui.ResetOnSpawn = false
			end)
			gui.Parent = pg
			a = { gui = gui, texte = lignes[1], dernier = nil }
			affichages[joueur] = a
		end
		local reste = resteCoffre(joueur)
		local texte
		local couleur
		if reste <= 0 then
			texte = "✅ PRÊT !"
			couleur = Style.couleurs.argent
		else
			texte = "⏳ " .. minuteur(reste)
			couleur = Style.couleurs.texte
		end
		if a.dernier ~= texte then
			a.dernier = texte
			a.texte.Text = texte
			a.texte.TextColor3 = couleur
		end
	end

	if Style then
		task.spawn(function()
			while true do
				for _, joueur in ipairs(Players:GetPlayers()) do
					pcall(rafraichir, joueur)
				end
				task.wait(1)
			end
		end)
	end

	-- ouverture visible : le couvercle bascule vers l'arrière puis se referme
	local enAnimation = false
	local originesCouvercle = {}
	for i, p in ipairs(couvercle) do
		originesCouvercle[i] = p.CFrame
	end
	local charniere = ici(0, HAUT, 1.7)

	local function poserCouvercle(angle)
		local rot = charniere * CFrame.Angles(math.rad(angle), 0, 0) * charniere:Inverse()
		for i, p in ipairs(couvercle) do
			if p.Parent then
				p.CFrame = rot * originesCouvercle[i]
			end
		end
	end

	local function animerOuverture()
		if enAnimation then return end
		enAnimation = true
		-- gerbe d'étincelles à l'ouverture
		if etincelles then
			pcall(function()
				etincelles:Emit(40)
			end)
		end
		task.spawn(function()
			pcall(function()
				for etape = 1, 10 do
					poserCouvercle(etape * 7)
					task.wait(0.03)
				end
				task.wait(1.5)
				for etape = 9, 0, -1 do
					poserCouvercle(etape * 7)
					task.wait(0.04)
				end
			end)
			enAnimation = false
		end)
	end

	local function ouvrir(joueur)
		if not estJoueur(joueur) then return end
		local maintenant = os.clock()
		if dernierEssai[joueur] and maintenant - dernierEssai[joueur] < ANTI_REBOND then return end
		dernierEssai[joueur] = maintenant

		if joueur:GetAttribute("DonneesChargees") ~= true then
			notifier(joueur, "Tes données sont en cours de chargement, réessaie dans un instant.", "info")
			return
		end
		local autorise = Bus.demander("AutoriserAction", joueur, "Coffre", ANTI_REBOND)
		if autorise == false then return end

		-- vérification de distance côté serveur
		local perso = joueur.Character
		local corps = perso and perso:FindFirstChild("HumanoidRootPart")
		if not corps or (corps.Position - caisse.Position).Magnitude > DISTANCE_COFFRE then
			return
		end

		local instant = os.time()
		local ouvert = lireNombre(joueur, "CoffreOuvert", 0)
		if ouvert > instant then
			-- horloge incohérente : on ramène la dernière ouverture à maintenant au plus
			ouvert = instant
		end
		local ecoule = instant - ouvert
		if ecoule < COFFRE_RECHARGE then
			notifier(joueur, "Le coffre est vide... Il se remplit à nouveau dans " .. dureeTexte(COFFRE_RECHARGE - ecoule) .. ".", "info")
			return
		end

		local gain = math.max(COFFRE_MINIMUM, revenuParSeconde(joueur) * COFFRE_SECONDES)
		joueur:SetAttribute("CoffreOuvert", instant)
		if donner(joueur, gain, "Coffre") then
			effet("Coffre", caisse.Position + Vector3.new(0, 3, 0), { montant = math.floor(gain + 0.5) })
			notifier(joueur, "Trésor trouvé ! +" .. montant(gain) .. ". Reviens demain !", "succes")
			animerOuverture()
			pcall(rafraichir, joueur)
		else
			-- l'argent n'a pas pu être versé : on rend le coffre disponible
			joueur:SetAttribute("CoffreOuvert", ouvert)
			pcall(rafraichir, joueur)
		end
	end

	ProximityPromptService.PromptTriggered:Connect(function(inviteDeclenchee, joueur)
		if not inviteDeclenchee or inviteDeclenchee.Name ~= "Coffre" then return end
		if inviteDeclenchee ~= invite and not inviteDeclenchee:IsDescendantOf(dossier) then return end
		local ok = pcall(ouvrir, joueur)
		if not ok then
			dernierEssai[joueur] = nil
		end
	end)

	-- ===== joueurs =====
	Players.PlayerAdded:Connect(arrivee)
	Players.PlayerRemoving:Connect(depart)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(arrivee, joueur)
	end
end

return M
