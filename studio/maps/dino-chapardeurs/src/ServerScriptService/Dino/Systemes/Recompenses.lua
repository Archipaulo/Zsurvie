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

	local function depart(joueur)
		jetons[joueur] = nil
		serieTraitee[joueur] = nil
		dernierEssai[joueur] = nil
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

	local function part(fabrique, props, estCouvercle)
		local p = fabrique(modele, props)
		p.CanCollide = props.CanCollide == true
		if estCouvercle then
			table.insert(couvercle, p)
		end
		return p
	end

	local function ici(x, y, z)
		return origine * CFrame.new(x, y, z)
	end

	-- caisse en bois
	local caisse = part(Outils.bloc, { Name = "Caisse", Size = Vector3.new(5, 2.4, 3.4), CFrame = ici(0, 1.2, 0), Color = Charte.bois, CanCollide = true })
	part(Outils.bloc, { Name = "Fond", Size = Vector3.new(4.6, 0.1, 3), CFrame = ici(0, 2.42, 0), Color = Charte.ombre(Charte.bois) })
	-- planches (rainures claires)
	for i = -1, 1, 2 do
		part(Outils.bloc, { Name = "Planche", Size = Vector3.new(4.9, 0.12, 0.05), CFrame = ici(0, 1.2 + i * 0.6, -1.71), Color = Charte.lumiere(Charte.bois) })
	end
	-- couvercle bombé
	part(Outils.cylindre, { Name = "Couvercle", Size = Vector3.new(5, 3.3, 3.3), CFrame = ici(0, 2.4, 0), Color = Charte.bois }, true)
	part(Outils.bloc, { Name = "CouvercleBas", Size = Vector3.new(5, 0.3, 3.4), CFrame = ici(0, 2.55, 0), Color = Charte.ombre(Charte.bois) }, true)

	-- ferrures dorées
	local matDore = Enum.Material.SmoothPlastic
	for _, x in ipairs({ -1.9, 1.9 }) do
		part(Outils.bloc, { Name = "Ferrure", Size = Vector3.new(0.4, 2.45, 3.5), CFrame = ici(x, 1.2, 0), Color = Charte.dore, Material = matDore })
		part(Outils.cylindre, { Name = "FerrureCouvercle", Size = Vector3.new(0.4, 3.45, 3.45), CFrame = ici(x, 2.4, 0), Color = Charte.dore, Material = matDore }, true)
	end
	part(Outils.bloc, { Name = "Plinthe", Size = Vector3.new(5.1, 0.3, 3.5), CFrame = ici(0, 0.15, 0), Color = Charte.dore })
	part(Outils.bloc, { Name = "Rebord", Size = Vector3.new(5.1, 0.25, 3.5), CFrame = ici(0, 2.3, 0), Color = Charte.dore })
	-- coins renforcés
	for _, x in ipairs({ -2.45, 2.45 }) do
		for _, z in ipairs({ -1.65, 1.65 }) do
			part(Outils.bloc, { Name = "Coin", Size = Vector3.new(0.3, 2.45, 0.3), CFrame = ici(x, 1.2, z), Color = Charte.ombre(Charte.dore) })
		end
	end
	-- serrure
	local serrure = part(Outils.bloc, { Name = "Serrure", Size = Vector3.new(0.9, 1.1, 0.3), CFrame = ici(0, 2.2, -1.8), Color = Charte.dore })
	part(Outils.bloc, { Name = "TrouSerrure", Size = Vector3.new(0.2, 0.45, 0.05), CFrame = ici(0, 2.1, -1.97), Color = Charte.encre })
	part(Outils.boule, { Name = "GemmeSerrure", Size = Vector3.new(0.35, 0.35, 0.35), CFrame = ici(0, 2.55, -1.97), Color = Charte.alerte, Material = Enum.Material.Neon })

	-- gemmes serties sur le couvercle
	local gemmes = { Charte.gemme, Charte.violet, Charte.gemme }
	for i, couleur in ipairs(gemmes) do
		local x = (i - 2) * 1.1
		part(Outils.boule, { Name = "Gemme", Size = Vector3.new(0.5, 0.5, 0.5), CFrame = ici(x, 4.05, 0), Color = couleur, Material = Enum.Material.Neon }, true)
	end

	-- trésor éparpillé devant le coffre
	local pieces = {
		{ -1.8, -2.6, 0 }, { -1.2, -2.9, 40 }, { 1.4, -2.5, 80 }, { 2.1, -3.1, 20 }, { 0.3, -3.4, 60 }, { 2.6, -1.6, 10 },
	}
	for _, p in ipairs(pieces) do
		part(Outils.cylindre, {
			Name = "Piece",
			Size = Vector3.new(0.12, 0.7, 0.7),
			CFrame = ici(p[1], 0.06, p[2]) * CFrame.Angles(0, math.rad(p[3]), math.rad(90)),
			Color = Charte.dore,
		})
	end
	local eclats = { { -2.6, -2, Charte.gemme }, { 1.8, -3.6, Charte.violet }, { -0.6, -3.8, Charte.alerte } }
	for _, g in ipairs(eclats) do
		part(Outils.boule, { Name = "Eclat", Size = Vector3.new(0.45, 0.45, 0.45), CFrame = ici(g[1], 0.22, g[2]), Color = g[3], Material = Enum.Material.Neon })
	end

	-- grosse gemme qui tourne au-dessus : repère visible de loin
	local phare = part(Outils.boule, { Name = "Phare", Size = Vector3.new(1.2, 1.2, 1.2), CFrame = ici(0, 6.5, 0), Color = Charte.gemme, Material = Enum.Material.Neon })
	pcall(Outils.animer, phare, "flotte", 1)
	pcall(Outils.lumiere, phare, { Range = 14, Brightness = 1.5, Color = Charte.gemme })
	pcall(Outils.lumiere, serrure, { Range = 8, Brightness = 1, Color = Charte.dore })
	pcall(function()
		local etincelles = Instance.new("Sparkles")
		etincelles.SparkleColor = Charte.dore
		etincelles.Parent = caisse
	end)

	pcall(function()
		modele.PrimaryPart = caisse
	end)

	local invite = Outils.invite(caisse, { nom = "Coffre", action = "Ouvrir", objet = "Coffre au trésor", duree = 0.5, distance = 10 })

	-- ouverture visible : le couvercle bascule vers l'arrière puis se referme
	local enAnimation = false
	local originesCouvercle = {}
	for i, p in ipairs(couvercle) do
		originesCouvercle[i] = p.CFrame
	end
	local charniere = ici(0, 2.4, 1.7)

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
		else
			-- l'argent n'a pas pu être versé : on rend le coffre disponible
			joueur:SetAttribute("CoffreOuvert", ouvert)
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
