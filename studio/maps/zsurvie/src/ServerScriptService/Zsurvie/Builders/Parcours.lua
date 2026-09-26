-- Builders/Parcours : parcours d'obstacles de l'île du Laboratoire (20 x 30 autour de Plan.lobby.parcours).
-- Départ au sol, 16 plateformes qui montent en double boucle, 2 dalles « Etape » (points de passage,
-- repris grâce à la borne du départ), arrivée au sommet avec un trophée gemme.
-- Récompense unique : E.gemmes.parcours gemmes (attribut joueur « ParcoursFait », sauvegardé par Donnees).
local Players = game:GetService("Players")

local M = {}

-- demi-emprise : X de -10 à 10, Z de -15 à 15 (relatif au centre du parcours)
local DEMI_X = 10
local DEMI_Z = 15
local HAUTEUR_MAX = 30

-- plateformes : x, z (relatifs), dessus (Y), et genre ("Etape" pour un point de passage)
-- écarts horizontaux ≤ 7 entre centres, montée de 1,5 par saut
local PLATEFORMES = {
	{ x = 1, z = 12, y = 1.5 },
	{ x = 7, z = 10, y = 3 },
	{ x = 8, z = 3, y = 4.5 },
	{ x = 7, z = -4, y = 6 },
	{ x = 2, z = -10, y = 7.5 },
	{ x = -5, z = -11, y = 9, genre = "Etape" },
	{ x = -7, z = -4, y = 10.5 },
	{ x = -6, z = 3, y = 12 },
	{ x = -1, z = 7, y = 13.5 },
	{ x = 4, z = 3, y = 15 },
	{ x = 5, z = -3, y = 16.5 },
	{ x = 0, z = -7, y = 18, genre = "Etape" },
	{ x = -5, z = -3, y = 19.5 },
	{ x = -4, z = 3, y = 21 },
	{ x = 1, z = 5, y = 22.5 },
	{ x = 4, z = 0, y = 24 },
}
local ARRIVEE = { x = 7, z = -6, y = 25.5 }
local DEPART = { x = -5, z = 12 }

local ANTI_REBOND = 3

-- envoie une notification à un joueur, sans jamais planter
local function notifier(ctx, joueur, texte, genre)
	local reseau = ctx.Reseau
	if type(reseau) ~= "table" then return end
	local ev = reseau.Notification
	if ev == nil then return end
	pcall(function()
		ev:FireClient(joueur, texte, genre)
	end)
end

local function effet(ctx, joueur, genre, position, donnees)
	local reseau = ctx.Reseau
	if type(reseau) ~= "table" then return end
	local ev = reseau.Effet
	if ev == nil then return end
	pcall(function()
		ev:FireClient(joueur, genre, position, donnees)
	end)
end

-- joueur (Player) à partir de la part touchée, ou nil
local function joueurDe(hit)
	if hit == nil or hit.Parent == nil then return nil end
	local ok, joueur = pcall(function()
		return Players:GetPlayerFromCharacter(hit.Parent)
	end)
	if ok then return joueur end
	return nil
end

function M.construire(ctx)
	local C = ctx.Charte
	local O = ctx.Outils
	local P = ctx.Plan
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local dossier = ctx.dossier

	local centre = P.lobby and P.lobby.parcours
	if typeof(centre) ~= "Vector3" then
		warn("[Zsurvie] Parcours : Plan.lobby.parcours absent, parcours non construit")
		return
	end
	local cx, cz = centre.X, centre.Z
	local sol = centre.Y

	local function pos(x, y, z)
		return Vector3.new(cx + x, sol + y, cz + z)
	end

	-- couleurs des plateformes (à nous, or, gemme, prairie : jamais violet ni rose-rouge)
	local teintes = { C.toit, C.dore, C.prairie, C.gemme, C.creme, C.terre }

	-- ===== départ au sol =====
	local depart = O.modele(dossier, "Depart")
	O.bloc(depart, {
		Name = "Socle",
		Size = Vector3.new(8, 1, 5),
		CFrame = CFrame.new(pos(DEPART.x, 0.5, DEPART.z)),
		Color = C.creme,
	})
	O.bloc(depart, {
		Name = "Ligne",
		Size = Vector3.new(7, 0.1, 0.6),
		CFrame = CFrame.new(pos(DEPART.x, 1.05, DEPART.z - 1.6)),
		Color = C.dore,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	O.panneau(depart, {
		nom = "PanneauDepart",
		position = pos(DEPART.x, 0, DEPART.z + 2.7),
		texte = "Parcours : grimpe jusqu'au trophée !",
		largeur = 7,
		angle = 180,
		couleur = C.prairie,
		couleurTexte = C.creme,
	})

	-- ===== poteaux d'angle de l'emprise =====
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			local x = sx * (DEMI_X - 0.5)
			local z = sz * (DEMI_Z - 0.5)
			O.bloc(dossier, {
				Name = "Poteau",
				Size = Vector3.new(0.8, 3, 0.8),
				CFrame = CFrame.new(pos(x, 1.5, z)),
				Color = C.terre,
			})
			O.boule(dossier, {
				Name = "PommeauPoteau",
				Size = Vector3.new(1.2, 1.2, 1.2),
				CFrame = CFrame.new(pos(x, 3.4, z)),
				Color = C.dore,
			})
		end
	end

	-- ===== plateformes montantes =====
	local plateformes = O.modele(dossier, "Plateformes")
	local etapes = {}
	for i, p in ipairs(PLATEFORMES) do
		local cote = 4
		if p.genre == "Etape" then cote = 6 end
		local y = math.min(p.y, HAUTEUR_MAX - 4)
		local couleur = teintes[((i - 1) % #teintes) + 1]
		local nom = "Plateforme" .. i
		if p.genre == "Etape" then
			nom = "Etape"
			couleur = C.creme
		end
		local dalle = O.bloc(plateformes, {
			Name = nom,
			Size = Vector3.new(cote, 1, cote),
			CFrame = CFrame.new(pos(p.x, y - 0.5, p.z)),
			Color = couleur,
		})
		-- semelle plus sombre dessous : contour lisible vu d'en bas
		O.bloc(plateformes, {
			Name = "Semelle",
			Size = Vector3.new(cote - 0.8, 0.6, cote - 0.8),
			CFrame = CFrame.new(pos(p.x, y - 1.3, p.z)),
			Color = C.ombre(couleur),
		})
		if p.genre == "Etape" then
			table.insert(etapes, dalle)
			dalle:SetAttribute("NumeroEtape", #etapes)
			-- anneau lumineux et petit fanion
			O.bloc(plateformes, {
				Name = "RepereEtape",
				Size = Vector3.new(cote - 1.5, 0.1, cote - 1.5),
				CFrame = CFrame.new(pos(p.x, y + 0.05, p.z)),
				Color = C.gemme,
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			O.bloc(plateformes, {
				Name = "MatEtape",
				Size = Vector3.new(0.3, 3, 0.3),
				CFrame = CFrame.new(pos(p.x + cote / 2 - 0.4, y + 1.5, p.z + cote / 2 - 0.4)),
				Color = C.terre,
				CanCollide = false,
			})
			O.bloc(plateformes, {
				Name = "FanionEtape",
				Size = Vector3.new(0.1, 1, 1.4),
				CFrame = CFrame.new(pos(p.x + cote / 2 - 0.4, y + 2.5, p.z + cote / 2 - 1.1)),
				Color = C.gemme,
				CanCollide = false,
			})
		end
	end

	-- ===== arrivée et trophée =====
	local arrivee = O.modele(dossier, "Arrivee")
	local yA = math.min(ARRIVEE.y, HAUTEUR_MAX - 4.5)
	local dalleArrivee = O.bloc(arrivee, {
		Name = "DalleArrivee",
		Size = Vector3.new(6, 1, 6),
		CFrame = CFrame.new(pos(ARRIVEE.x, yA - 0.5, ARRIVEE.z)),
		Color = C.dore,
	})
	O.bloc(arrivee, {
		Name = "Semelle",
		Size = Vector3.new(5.2, 0.6, 5.2),
		CFrame = CFrame.new(pos(ARRIVEE.x, yA - 1.3, ARRIVEE.z)),
		Color = C.ombre(C.dore),
	})
	O.bloc(arrivee, {
		Name = "Piedestal",
		Size = Vector3.new(1.6, 1, 1.6),
		CFrame = CFrame.new(pos(ARRIVEE.x + 1.6, yA + 0.5, ARRIVEE.z - 1.6)),
		Color = C.creme,
	})
	local gemme = O.bloc(arrivee, {
		Name = "TropheeGemme",
		Size = Vector3.new(1.6, 1.6, 1.6),
		CFrame = CFrame.new(pos(ARRIVEE.x + 1.6, yA + 2.4, ARRIVEE.z - 1.6))
			* CFrame.Angles(math.rad(45), 0, math.rad(45)),
		Color = C.gemme,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	O.lumiere(gemme, { Range = 14, Brightness = 1.5, Color = C.gemme })
	O.animer(gemme, "tourne", 1)

	-- ===== borne de reprise au départ =====
	local borne = O.bloc(depart, {
		Name = "BorneReprise",
		Size = Vector3.new(1.2, 3, 1.2),
		CFrame = CFrame.new(pos(DEPART.x - 4.2, 1.5, DEPART.z - 4)),
		Color = C.gemme,
	})
	O.bloc(depart, {
		Name = "BorneTete",
		Size = Vector3.new(1.4, 0.3, 1.4),
		CFrame = CFrame.new(pos(DEPART.x - 4.2, 3.15, DEPART.z - 4)),
		Color = C.lumiere(C.gemme),
		Material = Enum.Material.Neon,
	})

	-- ===== logique : étapes, reprise, arrivée =====
	local derniereEtape = {} -- Player -> numéro d'étape
	local dernierContact = {} -- Player -> os.clock() du dernier contact d'arrivée
	local dernierNotifEtape = {} -- Player -> os.clock() de la dernière notification d'étape

	for _, dalle in ipairs(etapes) do
		local numero = dalle:GetAttribute("NumeroEtape")
		dalle.Touched:Connect(function(hit)
			local joueur = joueurDe(hit)
			if joueur == nil then return end
			local actuelle = derniereEtape[joueur] or 0
			if type(numero) == "number" and numero > actuelle then
				derniereEtape[joueur] = numero
				local maintenant = os.clock()
				if dernierNotifEtape[joueur] == nil or maintenant - dernierNotifEtape[joueur] > 1 then
					dernierNotifEtape[joueur] = maintenant
					notifier(ctx, joueur, "Point de passage " .. numero .. "/" .. #etapes .. " !", "info")
				end
			end
		end)
	end

	O.invite(borne, { nom = "RepriseParcours", action = "Reprendre", objet = "Parcours", distance = 8 }, function(joueur)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		local numero = derniereEtape[joueur]
		local dalle = nil
		if type(numero) == "number" then dalle = etapes[numero] end
		if dalle == nil then
			notifier(ctx, joueur, "Atteins un point de passage pour pouvoir reprendre ici.", "info")
			return
		end
		local perso = joueur.Character
		if perso == nil then return end
		local humanoide = perso:FindFirstChildOfClass("Humanoid")
		if humanoide == nil or humanoide.Health <= 0 then return end
		pcall(function()
			perso:PivotTo(CFrame.new(dalle.Position + Vector3.new(0, 4, 0)))
		end)
	end)

	dalleArrivee.Touched:Connect(function(hit)
		local joueur = joueurDe(hit)
		if joueur == nil then return end
		local maintenant = os.clock()
		if dernierContact[joueur] ~= nil and maintenant - dernierContact[joueur] < ANTI_REBOND then return end
		dernierContact[joueur] = maintenant
		derniereEtape[joueur] = nil

		if joueur:GetAttribute("ParcoursFait") ~= true and joueur:GetAttribute("DonneesChargees") == true then
			local n = 0
			if type(E.gemmes) == "table" and type(E.gemmes.parcours) == "number" then
				n = E.gemmes.parcours
			end
			local total = nil
			if Bus and type(Bus.demander) == "function" then
				total = Bus.demander("AjouterGemmes", joueur, n, "Parcours")
			end
			if total == nil then
				-- personne n'a répondu : on ne marque pas le parcours, le joueur pourra réessayer
				notifier(ctx, joueur, "Bravo ! Les gemmes ne sont pas disponibles, reviens plus tard.", "info")
				return
			end
			joueur:SetAttribute("ParcoursFait", true)
			notifier(ctx, joueur, "Parcours réussi ! +" .. n .. " gemmes", "succes")
			effet(ctx, joueur, "Gemme", gemme.Position, { n = n })
		elseif joueur:GetAttribute("ParcoursFait") == true then
			notifier(ctx, joueur, "Déjà réussi !", "info")
		else
			notifier(ctx, joueur, "Bravo ! Ta sauvegarde se charge, retouche la dalle dans un instant.", "info")
		end
	end)

	Players.PlayerRemoving:Connect(function(joueur)
		derniereEtape[joueur] = nil
		dernierContact[joueur] = nil
		dernierNotifEtape[joueur] = nil
	end)
end

return M
