-- Builders/Mine : entrée de mine dans un monticule rocheux, rails et wagonnet de gemmes.
-- Pendant une run (Horde ou Répit), la Mine donne des gemmes à chaque Survivant à intervalle régulier.
local M = {}

function M.construire(ctx)
	local C = ctx.Charte
	local O = ctx.Outils
	local P = ctx.Plan
	local E = ctx.Equilibrage

	local centre = P.mine.centre
	-- repère local : -Z regarde vers la Maison (centre de la Prairie)
	local cible = Vector3.new(P.maison.centre.X, centre.Y, P.maison.centre.Z)
	local base = CFrame.lookAt(centre, cible)
	local _, lacet = base:ToOrientation()

	local modele = O.modele(ctx.dossier, "Mine")

	local function bloc(nom, taille, cfLocal, couleur, materiau)
		return O.bloc(modele, { Name = nom, Size = taille, CFrame = base * cfLocal, Color = couleur, Material = materiau })
	end
	local function coin(nom, taille, cfLocal, couleur)
		return O.coin(modele, { Name = nom, Size = taille, CFrame = base * cfLocal, Color = couleur })
	end
	local function incline(x, y, z, rx, ry, rz)
		return CFrame.new(x, y, z) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
	end

	local roche = C.ardoise
	local rocheSombre = C.ombre(C.ardoise)
	local rocheClaire = C.lumiere(C.ardoise)
	local bois = C.terre
	local boisSombre = C.ombre(C.terre)
	local neon = Enum.Material.Neon

	-- sol de terre battue sous la mine (disque plat)
	O.cylindre(modele, {
		Name = "Sol",
		Size = Vector3.new(0.1, 13.6, 13.6),
		CFrame = CFrame.new(centre.X, centre.Y + 0.05, centre.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color = C.ombre(C.terre),
	})

	-- monticule rocheux (hauteur maximale 6)
	bloc("Socle", Vector3.new(9, 4, 5), CFrame.new(0, 2, 1.5), roche)
	bloc("Sommet", Vector3.new(6, 2, 3.6), CFrame.new(0, 5, 1.8), rocheClaire)
	coin("FlancGauche", Vector3.new(3.5, 3, 1.5), CFrame.new(-5.25, 1.5, 0.75) * CFrame.Angles(0, math.rad(90), 0), rocheSombre)
	coin("FlancDroit", Vector3.new(3.5, 3, 1.5), CFrame.new(5.25, 1.5, 0.75) * CFrame.Angles(0, math.rad(-90), 0), rocheSombre)
	coin("PenteArriere", Vector3.new(7, 3, 1.5), CFrame.new(0, 1.5, 4.75) * CFrame.Angles(0, math.rad(180), 0), rocheSombre)
	O.boule(modele, { Name = "Rocher", Size = Vector3.new(2.4, 2.4, 2.4), CFrame = base * CFrame.new(-4.8, 1, -2.2), Color = rocheSombre })
	O.boule(modele, { Name = "Rocher", Size = Vector3.new(2, 2, 2), CFrame = base * CFrame.new(4.8, 0.8, -2.4), Color = roche })

	-- entrée : ouverture sombre et cadre de poutres
	bloc("Ouverture", Vector3.new(3, 3.2, 0.2), CFrame.new(0, 1.6, -1.1), C.encre)
	bloc("Poutre", Vector3.new(0.6, 3.8, 0.6), CFrame.new(-1.8, 1.9, -1.4), bois)
	bloc("Poutre", Vector3.new(0.6, 3.8, 0.6), CFrame.new(1.8, 1.9, -1.4), bois)
	bloc("Linteau", Vector3.new(4.8, 0.6, 0.8), CFrame.new(0, 4.1, -1.4), boisSombre)

	-- rails et traverses
	bloc("Rail", Vector3.new(0.25, 0.25, 5.5), CFrame.new(-0.8, 0.325, -3.85), rocheSombre)
	bloc("Rail", Vector3.new(0.25, 0.25, 5.5), CFrame.new(0.8, 0.325, -3.85), rocheSombre)
	local traverses = { -1.8, -3.3, -4.8, -6.2 }
	for _, z in ipairs(traverses) do
		bloc("Traverse", Vector3.new(2.4, 0.2, 0.5), CFrame.new(0, 0.1, z), boisSombre)
	end

	-- wagonnet plein de gemmes (un essieu par paire de roues)
	O.cylindre(modele, { Name = "Essieu", Size = Vector3.new(2.2, 0.7, 0.7), CFrame = base * CFrame.new(0, 0.8, -3.6), Color = C.encre })
	O.cylindre(modele, { Name = "Essieu", Size = Vector3.new(2.2, 0.7, 0.7), CFrame = base * CFrame.new(0, 0.8, -4.8), Color = C.encre })
	bloc("Wagonnet", Vector3.new(2.2, 1.2, 2), CFrame.new(0, 1.75, -4.2), C.toit)
	bloc("TasDeGemmes", Vector3.new(1.8, 0.5, 1.6), CFrame.new(0, 2.6, -4.2), C.gemme, neon)
	bloc("Gemme", Vector3.new(0.6, 0.9, 0.6), incline(-0.4, 3, -4.4, 0, 25, 15), C.lumiere(C.gemme), neon)
	bloc("Gemme", Vector3.new(0.5, 0.8, 0.5), incline(0.45, 3, -3.9, 10, -20, -15), C.gemme, neon)
	bloc("Gemme", Vector3.new(0.5, 0.7, 0.5), incline(0.1, 3, -4.8, -15, 40, 5), C.lumiere(C.gemme), neon)

	-- cristaux qui sortent de la roche
	local cristal = bloc("CristalPulse", Vector3.new(0.9, 1.8, 0.9), incline(-3.4, 4.85, 0.6, 0, 20, 12), C.gemme, neon)
	bloc("Cristal", Vector3.new(0.7, 1.3, 0.7), incline(-4, 4.55, 1.8, 15, 0, 20), C.lumiere(C.gemme), neon)
	bloc("Cristal", Vector3.new(0.8, 1.6, 0.8), incline(3.7, 4.7, 0.4, 0, -30, -15), C.gemme, neon)
	bloc("Cristal", Vector3.new(0.8, 1.8, 0.8), incline(-2.8, 0.85, -1.7, -10, 30, 15), C.gemme, neon)
	bloc("Cristal", Vector3.new(0.6, 1.2, 0.6), incline(2.9, 0.55, -1.9, 10, 10, -18), C.lumiere(C.gemme), neon)
	O.lumiere(cristal, { Range = 10, Brightness = 1, Color = C.gemme })
	O.animer(cristal, "pulse", 1)

	-- lanterne accrochée au cadre
	bloc("Crochet", Vector3.new(0.9, 0.15, 0.15), CFrame.new(2.2, 3.7, -1.5), C.encre)
	local lanterne = bloc("Lanterne", Vector3.new(0.6, 0.8, 0.6), CFrame.new(2.55, 3.2, -1.6), C.dore, neon)
	O.lumiere(lanterne, { Range = 14, Brightness = 1.2, Color = C.dore })

	-- panneau « Mine »
	local posPanneau = base * Vector3.new(-3.6, 0, -4.4)
	O.panneau(modele, {
		nom = "PanneauMine",
		position = Vector3.new(posPanneau.X, centre.Y, posPanneau.Z),
		texte = "Mine",
		angle = math.deg(lacet),
		largeur = 3.2,
		couleur = C.creme,
	})

	-- ===== production de gemmes =====
	local intervalle = E.gemmes and E.gemmes.mineIntervalle
	if type(intervalle) ~= "number" or intervalle <= 0 then
		warn("[Zsurvie] Mine : Equilibrage.gemmes.mineIntervalle invalide, production désactivée")
		return
	end

	local okJ, Players = pcall(function()
		return game:GetService("Players")
	end)
	if not okJ or not Players then
		warn("[Zsurvie] Mine : service Players indisponible, production désactivée")
		return
	end

	local positionEffet = (base * CFrame.new(0, 2.8, -4.2)).Position

	local function produire()
		local phase = ctx.Etat and ctx.Etat:GetAttribute("Phase")
		if phase ~= "Horde" and phase ~= "Repit" then
			return
		end
		local total = 0
		for _, joueur in ipairs(Players:GetPlayers()) do
			if joueur:GetAttribute("EnRun") == true then
				local n = 1
				if joueur:GetAttribute("Rech_Foreuse") == true then
					n = 2
				end
				ctx.Bus.demander("AjouterGemmes", joueur, n, "Mine")
				total = total + n
			end
		end
		if total > 0 then
			local effet = ctx.Reseau and ctx.Reseau.Effet
			if effet then
				effet:FireAllClients("Gemme", positionEffet, { n = total })
			end
			-- le cristal pulse plus vite un instant
			if cristal.Parent then
				O.animer(cristal, "pulse", 3)
				task.delay(1.5, function()
					if cristal.Parent then
						O.animer(cristal, "pulse", 1)
					end
				end)
			end
		end
	end

	task.spawn(function()
		while modele.Parent do
			task.wait(intervalle)
			if modele.Parent then
				local ok, err = pcall(produire)
				if not ok then
					warn("[Zsurvie] Mine : " .. tostring(err))
				end
			end
		end
	end)
end

return M
