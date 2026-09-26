-- Builders/QuaiCapsules : la SpawnLocation unique du lobby et le Quai des Capsules.
-- Les joueurs montent dans une Capsule ; après un compte à rebours, tous les embarqués
-- sont envoyés sur le parvis de la Prairie et la run commence (Bus « RunDebut »).
local Players = game:GetService("Players")

local M = {}

function M.construire(ctx)
	local C = ctx.Charte
	local O = ctx.Outils
	local P = ctx.Plan
	local E = ctx.Equilibrage
	local dossier = ctx.dossier

	local nbCapsules = math.max(1, math.floor(tonumber(E.joueursMax) or 1))
	local delai = math.max(1, math.floor(tonumber(E.delaiCapsule) or 5))

	-- ===== SpawnLocation unique (8 x 8 x 1, dessus à Y = 1) =====
	local posSpawn = P.lobby.spawn
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLobby"
	spawn.Anchored = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(posSpawn.X, 0.5, posSpawn.Z)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Color = C.toit
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.AllowTeamChangeOnTouch = false
	spawn.Parent = dossier
	-- liseré lumineux autour du point d'apparition
	O.bloc(dossier, {
		Name = "SpawnLisere",
		Size = Vector3.new(8.6, 0.8, 8.6),
		CFrame = CFrame.new(posSpawn.X, 0.4, posSpawn.Z),
		Color = C.lumiere(C.toit),
		Material = Enum.Material.Neon,
		CanCollide = false,
	})

	-- ===== le quai (36 x 12, dessus à Y = 1) =====
	local centre = P.lobby.quai
	local largeur, profondeur = 36, 12
	local quai = O.modele(dossier, "Quai")
	O.bloc(quai, {
		Name = "Plateforme",
		Size = Vector3.new(largeur, 1, profondeur),
		CFrame = CFrame.new(centre.X, 0.5, centre.Z),
		Color = C.creme,
	})
	-- bordures avant et arrière
	O.bloc(quai, {
		Name = "BordAvant",
		Size = Vector3.new(largeur, 1.2, 0.8),
		CFrame = CFrame.new(centre.X, 0.6, centre.Z + profondeur / 2 - 0.4),
		Color = C.toit,
	})
	O.bloc(quai, {
		Name = "BordArriere",
		Size = Vector3.new(largeur, 1.2, 0.8),
		CFrame = CFrame.new(centre.X, 0.6, centre.Z - profondeur / 2 + 0.4),
		Color = C.ombre(C.toit),
	})
	-- bande lumineuse d'embarquement
	O.bloc(quai, {
		Name = "BandeEmbarquement",
		Size = Vector3.new(largeur - 2, 0.1, 0.5),
		CFrame = CFrame.new(centre.X, 1.05, centre.Z + 4),
		Color = C.dore,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})

	-- ===== grand panneau du compte à rebours (au fond du quai) =====
	local zPanneau = centre.Z - profondeur / 2 + 1.2
	local hauteurPanneau = 13
	for _, dx in ipairs({ -15, 15 }) do
		O.bloc(quai, {
			Name = "PoteauPanneau",
			Size = Vector3.new(0.8, hauteurPanneau, 0.8),
			CFrame = CFrame.new(centre.X + dx, 1 + hauteurPanneau / 2, zPanneau),
			Color = C.ardoise,
		})
	end
	local planche = O.bloc(quai, {
		Name = "PanneauDepart",
		Size = Vector3.new(30, 5, 0.6),
		CFrame = CFrame.new(centre.X, 1 + hauteurPanneau - 2.5, zPanneau),
		Color = C.nuitLabo,
	})
	O.bloc(quai, {
		Name = "CadrePanneau",
		Size = Vector3.new(31, 0.4, 0.8),
		CFrame = CFrame.new(centre.X, 1 + hauteurPanneau + 0.2, zPanneau),
		Color = C.gemme,
		Material = Enum.Material.Neon,
	})
	-- le panneau regarde vers +Z (côté spawn) : face « Back » ; texte aussi au dos
	local texteAvant = O.texte(planche, "Back", "", { couleur = C.creme, pixelsParStud = 30 })
	local texteDos = O.texte(planche, "Front", "", { couleur = C.creme, pixelsParStud = 30 })

	local function afficher(texte, couleur)
		for _, etiquette in ipairs({ texteAvant, texteDos }) do
			if etiquette and etiquette.Parent then
				etiquette.Text = texte
				etiquette.TextColor3 = couleur or C.creme
			end
		end
	end

	-- ===== état d'embarquement =====
	local embarques = {}   -- liste ordonnée de Player
	local occupants = {}   -- index de capsule -> Player
	local capsules = {}    -- index -> { anneau, invite }
	local enDecompte = false
	local jeton = 0

	local function notifier(joueur, texte, genre)
		local ev = ctx.Reseau and ctx.Reseau.Notification
		if not ev then return end
		pcall(function()
			if joueur then
				ev:FireClient(joueur, texte, genre)
			else
				ev:FireAllClients(texte, genre)
			end
		end)
	end

	local function phase()
		local ok, valeur = pcall(function()
			return ctx.Etat:GetAttribute("Phase")
		end)
		if ok then return valeur end
		return nil
	end

	local function estConnecte(joueur)
		return joueur ~= nil and joueur.Parent == Players
	end

	local function indexEmbarque(joueur)
		for i, j in ipairs(embarques) do
			if j == joueur then return i end
		end
		return nil
	end

	local function majCapsule(i)
		local cap = capsules[i]
		if not cap then return end
		local occupant = occupants[i]
		if occupant then
			cap.anneau.Color = C.dore
			cap.invite.ActionText = "Occupée"
			cap.invite.ObjectText = occupant.Name
		else
			cap.anneau.Color = C.gemme
			cap.invite.ActionText = "Embarquer"
			cap.invite.ObjectText = "Capsule " .. i
		end
	end

	local function libererCapsulesDe(joueur)
		for i = 1, nbCapsules do
			if occupants[i] == joueur then
				occupants[i] = nil
				majCapsule(i)
			end
		end
	end

	local function toutVider()
		embarques = {}
		for i = 1, nbCapsules do
			occupants[i] = nil
			majCapsule(i)
		end
	end

	local function texteRepos()
		if phase() == "Lobby" then
			afficher("Montez dans une Capsule !", C.creme)
		else
			afficher("Run en cours...", C.alerte)
		end
	end

	-- retire les joueurs partis ; renvoie le nombre d'embarqués restants
	local function nettoyer()
		for i = #embarques, 1, -1 do
			local j = embarques[i]
			if not estConnecte(j) then
				table.remove(embarques, i)
				libererCapsulesDe(j)
			end
		end
		return #embarques
	end

	-- ===== départ de la run =====
	local function depart()
		nettoyer()
		local joueurs = {}
		for _, j in ipairs(embarques) do
			if estConnecte(j) then table.insert(joueurs, j) end
		end
		toutVider()
		if #joueurs == 0 then
			texteRepos()
			return
		end
		local n = #joueurs
		for i, joueur in ipairs(joueurs) do
			local decalageX = (i - (n + 1) / 2) * 3
			local perso = joueur.Character
			if perso then
				pcall(function()
					perso:PivotTo(CFrame.new(P.parvis.centre + Vector3.new(decalageX, 4, 0)))
				end)
			end
			joueur:SetAttribute("EnRun", true)
		end
		afficher("Bonne chance, Survivants !", C.dore)
		ctx.Bus.emettre("RunDebut", joueurs)
	end

	local function lancerDecompte()
		if enDecompte then return end
		enDecompte = true
		jeton = jeton + 1
		local monJeton = jeton
		task.spawn(function()
			local restant = delai
			local annule = false
			while restant > 0 and not annule do
				if monJeton ~= jeton then
					annule = true
				elseif phase() ~= "Lobby" or nettoyer() == 0 then
					annule = true
				else
					afficher("Départ dans " .. restant .. " s  (" .. #embarques .. "/" .. nbCapsules .. ")", C.dore)
					notifier(nil, "Départ des Capsules dans " .. restant .. " s", "info")
					task.wait(1)
					restant = restant - 1
				end
			end
			if monJeton ~= jeton then return end
			enDecompte = false
			if annule then
				toutVider()
				texteRepos()
				return
			end
			if phase() ~= "Lobby" then
				toutVider()
				texteRepos()
				return
			end
			notifier(nil, "Décollage !", "succes")
			depart()
		end)
	end

	-- ===== rappel serveur d'une capsule =====
	local function embarquer(i, joueur)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		if not estConnecte(joueur) then return end
		if ctx.Bus.demander("AutoriserAction", joueur, "Capsule", 0.5) == false then return end
		if phase() ~= "Lobby" then
			notifier(joueur, "Une run est déjà en cours", "alerte")
			return
		end
		if joueur:GetAttribute("EnRun") == true then return end
		if indexEmbarque(joueur) then
			notifier(joueur, "Tu es déjà à bord !", "info")
			return
		end
		nettoyer()
		if occupants[i] and occupants[i] ~= joueur then
			notifier(joueur, "Cette Capsule est occupée", "alerte")
			return
		end
		if #embarques >= nbCapsules then
			notifier(joueur, "Toutes les Capsules sont pleines", "alerte")
			return
		end
		table.insert(embarques, joueur)
		occupants[i] = joueur
		majCapsule(i)
		notifier(nil, joueur.Name .. " embarque dans la Capsule " .. i, "info")
		if not enDecompte then
			lancerDecompte()
		end
	end

	-- ===== les capsules, côte à côte =====
	local pas = largeur / nbCapsules
	local zCapsule = centre.Z + 1
	local hauteurCorps = 6
	local diametre = math.min(4.4, pas - 0.8)
	local yCorps = 1.4 + hauteurCorps / 2
	local yToit = 1.4 + hauteurCorps
	local vertical = CFrame.Angles(0, 0, math.rad(90))

	for i = 1, nbCapsules do
		local x = centre.X - largeur / 2 + pas * (i - 0.5)
		local modele = O.modele(dossier, "Capsule" .. i)
		O.cylindre(modele, {
			Name = "Socle",
			Size = Vector3.new(0.4, diametre + 0.8, diametre + 0.8),
			CFrame = CFrame.new(x, 1.2, zCapsule) * vertical,
			Color = C.ardoise,
		})
		local corps = O.cylindre(modele, {
			Name = "Corps",
			Size = Vector3.new(hauteurCorps, diametre, diametre),
			CFrame = CFrame.new(x, yCorps, zCapsule) * vertical,
			Color = C.creme,
		})
		O.bloc(modele, {
			Name = "Hublot",
			Size = Vector3.new(diametre * 0.4, hauteurCorps * 0.45, 0.3),
			CFrame = CFrame.new(x, yCorps + 0.4, zCapsule + diametre / 2 - 0.05),
			Color = C.gemme,
			Material = Enum.Material.Glass,
			Transparency = 0.3,
			CanCollide = false,
		})
		O.boule(modele, {
			Name = "Dome",
			Size = Vector3.new(diametre, diametre, diametre),
			CFrame = CFrame.new(x, yToit, zCapsule),
			Color = C.gemme,
			Material = Enum.Material.Glass,
			Transparency = 0.4,
		})
		local anneau = O.cylindre(modele, {
			Name = "Anneau",
			Size = Vector3.new(0.5, diametre + 0.4, diametre + 0.4),
			CFrame = CFrame.new(x, yToit, zCapsule) * vertical,
			Color = C.gemme,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		O.lumiere(anneau, { Range = 8, Brightness = 1, Color = C.gemme })
		modele.PrimaryPart = corps

		local index = i
		local invite = O.invite(corps, { nom = "Capsule", action = "Embarquer", objet = "Capsule " .. i, distance = 10 }, function(joueur)
			embarquer(index, joueur)
		end)
		capsules[i] = { anneau = anneau, invite = invite }
	end

	-- ===== suivi des départs et de la phase =====
	Players.PlayerRemoving:Connect(function(joueur)
		local idx = indexEmbarque(joueur)
		if idx then
			table.remove(embarques, idx)
			libererCapsulesDe(joueur)
		end
	end)

	pcall(function()
		ctx.Etat:GetAttributeChangedSignal("Phase"):Connect(function()
			if not enDecompte then
				texteRepos()
			end
		end)
	end)

	texteRepos()
end

return M
