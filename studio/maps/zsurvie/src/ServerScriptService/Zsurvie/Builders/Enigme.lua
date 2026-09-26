-- Constructeur Enigme : jeu de mémoire façon « Simon » sur l'île du Laboratoire.
-- Emprise 14 x 14 autour de Plan.lobby.enigme. Mur-écran au fond (côté -Z), 4 boutons au sol devant,
-- panneau d'énoncé sur le côté. Les joueurs arrivent par le côté +Z.
-- Un mur montre en boucle une séquence fixe de 4 couleurs ; chaque joueur la reproduit sur les boutons.
local M = {}

local BUDGET = 150

-- présentation de la séquence (secondes)
local CYCLE = 6
local DUREE_ALLUMEE = 0.7
local DUREE_PAUSE = 0.25
local DUREE_FLASH_BOUTON = 0.35
local ANTI_REBOND = 0.2

-- les 4 couleurs, dans l'ordre des colonnes (de gauche à droite vu depuis l'entrée)
local COULEURS = {
	{ cle = "prairie", nom = "Vert" },
	{ cle = "toit", nom = "Orange" },
	{ cle = "gemme", nom = "Cyan" },
	{ cle = "violet", nom = "Violet" },
}

-- séquence fixe à reproduire (indices dans COULEURS)
local SEQUENCE = { 3, 2, 4, 1 }

local ECART_COLONNES = 3.2

local function estJoueur(j)
	if typeof(j) ~= "Instance" then
		return false
	end
	local ok, res = pcall(function()
		return j:IsA("Player")
	end)
	return ok and res == true
end

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local dossier = ctx.dossier

	if not (Plan and Plan.lobby and Plan.lobby.enigme) then
		warn("[Zsurvie] Enigme : Plan.lobby.enigme introuvable")
		return
	end

	local partsAvant = Outils.nombreParts()
	local C = Plan.lobby.enigme
	local cx, cz = C.X, C.Z
	local y0 = C.Y

	local recompense = 0
	if E and type(E.gemmes) == "table" and type(E.gemmes.enigme) == "number" then
		recompense = E.gemmes.enigme
	end

	local Players = nil
	local okPlayers, servicePlayers = pcall(function()
		return game:GetService("Players")
	end)
	if okPlayers then
		Players = servicePlayers
	end

	-- ===== sol et bordures =====
	Outils.bloc(dossier, {
		Name = "Sol",
		Size = Vector3.new(14, 0.2, 14),
		CFrame = CFrame.new(cx, y0 + 0.1, cz),
		Color = Charte.nuitLabo,
	})
	local bordures = {
		{ Vector3.new(14, 0.4, 0.5), 0, -6.75 },
		{ Vector3.new(14, 0.4, 0.5), 0, 6.75 },
		{ Vector3.new(0.5, 0.4, 13), -6.75, 0 },
		{ Vector3.new(0.5, 0.4, 13), 6.75, 0 },
	}
	for i, b in ipairs(bordures) do
		local taille = b[1]
		-- ouverture côté entrée : la bordure +Z est plus basse
		local couleur = Charte.creme
		if i == 2 then
			couleur = Charte.toit
		end
		Outils.bloc(dossier, {
			Name = "Bordure",
			Size = taille,
			CFrame = CFrame.new(cx + b[2], y0 + taille.Y / 2, cz + b[3]),
			Color = couleur,
		})
	end

	-- ===== mur-écran =====
	local zMur = cz - 5.5
	local ecran = Outils.modele(dossier, "MurEcran")
	Outils.bloc(ecran, {
		Name = "Ecran",
		Size = Vector3.new(12, 7, 1),
		CFrame = CFrame.new(cx, y0 + 0.2 + 3.5, zMur),
		Color = Charte.encre,
	})
	for _, dx in ipairs({ -6.5, 6.5 }) do
		Outils.bloc(ecran, {
			Name = "Pilier",
			Size = Vector3.new(1, 8.5, 1.4),
			CFrame = CFrame.new(cx + dx, y0 + 0.2 + 4.25, zMur),
			Color = Charte.creme,
		})
	end
	local fronton = Outils.bloc(ecran, {
		Name = "Fronton",
		Size = Vector3.new(14, 1.6, 1.4),
		CFrame = CFrame.new(cx, y0 + 0.2 + 7 + 0.8, zMur),
		Color = Charte.toit,
	})
	-- face avant du mur : côté +Z, soit la face « Back » d'une part non tournée
	Outils.texte(fronton, "Back", "MÉMOIRE DES GEMMES", { couleur = Charte.creme })

	-- témoin de début de cycle
	local temoin = Outils.bloc(ecran, {
		Name = "Temoin",
		Size = Vector3.new(10, 0.3, 0.3),
		CFrame = CFrame.new(cx, y0 + 0.2 + 6.4, zMur + 0.6),
		Color = Charte.ombre(Charte.creme),
	})

	-- gemmes de l'écran, une par colonne
	local gemmes = {}
	for i, coul in ipairs(COULEURS) do
		local x = cx + (i - 2.5) * ECART_COLONNES
		local base = Charte[coul.cle] or Charte.creme
		Outils.bloc(ecran, {
			Name = "Cadre" .. coul.nom,
			Size = Vector3.new(2.8, 2.8, 0.3),
			CFrame = CFrame.new(x, y0 + 0.2 + 3.6, zMur + 0.65),
			Color = Charte.ardoise,
		})
		local g = Outils.boule(ecran, {
			Name = "Gemme" .. coul.nom,
			Size = Vector3.new(2.2, 2.2, 2.2),
			CFrame = CFrame.new(x, y0 + 0.2 + 3.6, zMur + 1),
			Color = Charte.ombre(base),
			CanCollide = false,
		})
		local l = Outils.lumiere(g, { Range = 10, Brightness = 2, Color = base })
		l.Enabled = false
		gemmes[i] = { part = g, lumiere = l, base = base }
	end

	local function allumerGemme(i, allumee)
		local g = gemmes[i]
		if not g or not g.part.Parent then
			return
		end
		if allumee then
			g.part.Material = Enum.Material.Neon
			g.part.Color = Charte.lumiere(g.base)
		else
			g.part.Material = Enum.Material.SmoothPlastic
			g.part.Color = Charte.ombre(g.base)
		end
		g.lumiere.Enabled = allumee
	end

	-- ===== boutons au sol =====
	local zBoutons = cz + 1.5
	local boutons = {}
	local jetonsFlash = {}
	for i, coul in ipairs(COULEURS) do
		local x = cx + (i - 2.5) * ECART_COLONNES
		local base = Charte[coul.cle] or Charte.creme
		local m = Outils.modele(dossier, "Bouton" .. coul.nom)
		-- l'axe d'un cylindre est X : on le couche pour qu'il soit vertical
		Outils.cylindre(m, {
			Name = "Socle",
			Size = Vector3.new(0.4, 3, 3),
			CFrame = CFrame.new(x, y0 + 0.2 + 0.2, zBoutons) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Charte.creme,
		})
		local chapeau = Outils.cylindre(m, {
			Name = "Chapeau",
			Size = Vector3.new(0.5, 2.4, 2.4),
			CFrame = CFrame.new(x, y0 + 0.2 + 0.4 + 0.25, zBoutons) * CFrame.Angles(0, 0, math.rad(90)),
			Color = base,
		})
		local l = Outils.lumiere(chapeau, { Range = 8, Brightness = 2, Color = base })
		l.Enabled = false
		boutons[i] = { part = chapeau, lumiere = l, base = base }
		jetonsFlash[i] = 0
	end

	local function flasherBouton(i)
		local b = boutons[i]
		if not b or not b.part.Parent then
			return
		end
		jetonsFlash[i] = jetonsFlash[i] + 1
		local jeton = jetonsFlash[i]
		b.part.Material = Enum.Material.Neon
		b.part.Color = Charte.lumiere(b.base)
		b.lumiere.Enabled = true
		task.delay(DUREE_FLASH_BOUTON, function()
			if jetonsFlash[i] ~= jeton or not b.part.Parent then
				return
			end
			b.part.Material = Enum.Material.SmoothPlastic
			b.part.Color = b.base
			b.lumiere.Enabled = false
		end)
	end

	-- ===== panneau d'énoncé (côté gauche, tourné vers l'entrée) =====
	local enonce = "ÉNIGME : regarde l'écran, 4 gemmes s'allument dans un ordre secret. "
		.. "Appuie sur les boutons dans le même ordre. Une erreur et tout recommence ! "
		.. "Récompense : " .. tostring(recompense) .. " gemmes (une seule fois)."
	local panneau = Outils.modele(dossier, "PanneauEnonce")
	local xPanneau = cx - 5.2
	local zPanneau = cz + 5
	for _, dz in ipairs({ -1.7, 1.7 }) do
		Outils.bloc(panneau, {
			Name = "Poteau",
			Size = Vector3.new(0.4, 3, 0.4),
			CFrame = CFrame.new(xPanneau, y0 + 0.2 + 1.5, zPanneau + dz),
			Color = Charte.terre,
		})
	end
	local planche = Outils.bloc(panneau, {
		Name = "Planche",
		Size = Vector3.new(0.3, 2.6, 4),
		CFrame = CFrame.new(xPanneau, y0 + 0.2 + 3.6, zPanneau),
		Color = Charte.creme,
	})
	-- face +X : vers le centre de l'emprise
	Outils.texte(planche, "Right", enonce, { couleur = Charte.encre, police = Charte.policeTexte })

	local partsUtilisees = Outils.nombreParts() - partsAvant
	if partsUtilisees > BUDGET then
		warn("[Zsurvie] Enigme : budget de parts dépassé (" .. partsUtilisees .. " / " .. BUDGET .. ")")
	end

	-- ===== boucle de présentation de la séquence =====
	task.spawn(function()
		while dossier.Parent do
			local debut = os.clock()
			temoin.Material = Enum.Material.Neon
			temoin.Color = Charte.creme
			task.wait(0.4)
			temoin.Material = Enum.Material.SmoothPlastic
			temoin.Color = Charte.ombre(Charte.creme)
			for _, indice in ipairs(SEQUENCE) do
				if not dossier.Parent then
					return
				end
				allumerGemme(indice, true)
				task.wait(DUREE_ALLUMEE)
				allumerGemme(indice, false)
				task.wait(DUREE_PAUSE)
			end
			local reste = CYCLE - (os.clock() - debut)
			if reste > 0 then
				task.wait(reste)
			else
				task.wait()
			end
		end
	end)

	-- ===== logique serveur : progression par joueur =====
	local progression = {}
	local dernierAppui = {}

	local function notifier(joueur, texte, genre)
		if not Reseau then
			return
		end
		local ev = Reseau.Notification
		if ev then
			pcall(function()
				ev:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function effetGemme(n)
		if not Reseau or not Reseau.Effet then
			return
		end
		pcall(function()
			Reseau.Effet:FireAllClients("Gemme", Vector3.new(cx, y0 + 4, zMur + 1.5), { n = n })
		end)
	end

	local function recompenser(joueur)
		if joueur:GetAttribute("EnigmeFaite") == true then
			notifier(joueur, "Bravo ! Énigme déjà résolue, la récompense a été touchée.", "info")
			return
		end
		if joueur:GetAttribute("DonneesChargees") ~= true then
			notifier(joueur, "Bravo ! Ta sauvegarde se charge encore, réessaie dans un instant.", "info")
			return
		end
		local total = Bus.demander("AjouterGemmes", joueur, recompense, "Enigme")
		if total == nil then
			notifier(joueur, "Bravo ! Les gemmes ne peuvent pas être données pour l'instant.", "info")
			return
		end
		joueur:SetAttribute("EnigmeFaite", true)
		notifier(joueur, "Énigme résolue ! +" .. tostring(recompense) .. " gemmes", "succes")
		effetGemme(recompense)
	end

	local function appuyer(joueur, indice)
		if not estJoueur(joueur) then
			return
		end
		if joueur.Parent == nil then
			return
		end
		local maintenant = os.clock()
		local dernier = dernierAppui[joueur]
		if dernier and maintenant - dernier < ANTI_REBOND then
			return
		end
		dernierAppui[joueur] = maintenant
		if Bus.demander("AutoriserAction", joueur, "Enigme", ANTI_REBOND) == false then
			return
		end

		local etape = progression[joueur] or 0
		local attendu = SEQUENCE[etape + 1]
		if attendu == indice then
			etape = etape + 1
			flasherBouton(indice)
			if etape >= #SEQUENCE then
				progression[joueur] = 0
				recompenser(joueur)
			else
				progression[joueur] = etape
			end
		else
			progression[joueur] = 0
			notifier(joueur, "Raté ! Regarde bien l'écran et recommence depuis le début.", "alerte")
		end
	end

	for i, coul in ipairs(COULEURS) do
		local indice = i
		Outils.invite(boutons[i].part, {
			nom = "BoutonEnigme",
			action = "Appuyer",
			objet = coul.nom,
			distance = 8,
		}, function(joueur)
			appuyer(joueur, indice)
		end)
	end

	if Players then
		Players.PlayerRemoving:Connect(function(joueur)
			progression[joueur] = nil
			dernierAppui[joueur] = nil
		end)
	end
end

return M
