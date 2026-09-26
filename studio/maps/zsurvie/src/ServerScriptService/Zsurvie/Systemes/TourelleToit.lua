-- Systemes/TourelleToit : tourelle automatique posée sur le toit de la Maison.
-- Construite au début d'une run si un joueur en run a la recherche « TourelleToit »,
-- elle tire seule sur le Zbire le plus proche pendant la Horde, puis disparaît au retour au lobby.
local Players = game:GetService("Players")

local M = {}

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Bus = ctx.Bus
	local Etat = ctx.Etat
	local E = ctx.Equilibrage
	local reglages = E.tourelle or {}

	local HAUTEUR_TOIT = 14
	local HAUTEUR_TETE = 3.2 -- centre de la tête au-dessus de la base
	local LONGUEUR_CANON = 3.4
	local OFFSET_CANON = 1.1 + LONGUEUR_CANON / 2 -- centre du canon devant la tête

	local dossier = nil
	local tourelle = nil
	local tete, canon, bout = nil, nil, nil
	local centreTete = nil
	local generation = 0

	-- ===== construction =====
	local function detruire()
		generation = generation + 1
		if dossier then
			pcall(function() dossier:Destroy() end)
		end
		dossier, tourelle, tete, canon, bout, centreTete = nil, nil, nil, nil, nil, nil
	end

	-- oriente la tête (et ce qui y est fixé) selon une CFrame centrée sur centreTete
	local function orienter(cfTete)
		if not (tete and canon and bout) then return end
		tete.CFrame = cfTete
		canon.CFrame = cfTete * CFrame.new(0, 0, -OFFSET_CANON) * CFrame.Angles(0, math.rad(90), 0)
		bout.CFrame = cfTete * CFrame.new(0, 0, -(OFFSET_CANON + LONGUEUR_CANON / 2 + 0.2))
	end

	local function construire()
		detruire()
		local base = Plan.maison.centre + Vector3.new(0, HAUTEUR_TOIT, 0)
		dossier = Outils.dossier(ctx.racine, "TourelleToit")
		tourelle = Outils.modele(dossier, "Tourelle")

		-- socle ardoise et colonne
		local socle = Outils.bloc(tourelle, {
			Name = "Socle",
			Size = Vector3.new(4, 1, 4),
			CFrame = CFrame.new(base.X, base.Y + 0.5, base.Z),
			Color = Charte.ardoise,
		})
		Outils.cylindre(tourelle, {
			Name = "Colonne",
			Size = Vector3.new(1.4, 1.6, 1.6),
			CFrame = CFrame.new(base.X, base.Y + 1.7, base.Z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Charte.ombre(Charte.ardoise),
		})
		Outils.bloc(tourelle, {
			Name = "Liseré",
			Size = Vector3.new(4.2, 0.3, 4.2),
			CFrame = CFrame.new(base.X, base.Y + 1.1, base.Z),
			Color = Charte.lumiere(Charte.ardoise),
		})

		-- tête orientable, canon et bout lumineux
		centreTete = Vector3.new(base.X, base.Y + HAUTEUR_TETE, base.Z)
		tete = Outils.bloc(tourelle, {
			Name = "Tete",
			Size = Vector3.new(2.4, 1.8, 2.2),
			CFrame = CFrame.new(centreTete),
			Color = Charte.toit,
		})
		canon = Outils.cylindre(tourelle, {
			Name = "Canon",
			Size = Vector3.new(LONGUEUR_CANON, 0.7, 0.7),
			CFrame = CFrame.new(centreTete),
			Color = Charte.ardoise,
		})
		bout = Outils.bloc(tourelle, {
			Name = "Bout",
			Size = Vector3.new(0.8, 0.8, 0.4),
			CFrame = CFrame.new(centreTete),
			Color = Charte.gemme,
			Material = Enum.Material.Neon,
		})
		pcall(function()
			Outils.lumiere(bout, { Range = 10, Brightness = 1.5, Color = Charte.gemme })
		end)

		for _, p in ipairs(tourelle:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
		tourelle.PrimaryPart = socle
		orienter(CFrame.new(centreTete))
	end

	-- ===== conditions =====
	local function quelquunALaRecherche()
		for _, joueur in ipairs(Players:GetPlayers()) do
			if joueur:GetAttribute("EnRun") == true and joueur:GetAttribute("Rech_TourelleToit") == true then
				return true
			end
		end
		return false
	end

	-- ===== visée et tir =====
	local function positionZbire(modele)
		local corps = modele.PrimaryPart or modele:FindFirstChild("Corps")
		if corps and corps:IsA("BasePart") then
			return corps.Position
		end
		local ok, pivot = pcall(function() return modele:GetPivot() end)
		if ok and pivot then
			return pivot.Position + Vector3.new(0, 2, 0)
		end
		return nil
	end

	local function cibleLaPlusProche()
		local horde = ctx.horde
		if not (horde and horde.Parent and centreTete) then return nil, nil end
		local portee = reglages.portee or 0
		local meilleur, meilleurePos, meilleureDist = nil, nil, portee
		for _, modele in ipairs(horde:GetChildren()) do
			if modele:IsA("Model") then
				local pv = modele:GetAttribute("PV")
				if type(pv) ~= "number" or pv > 0 then
					local pos = positionZbire(modele)
					if pos then
						local d = (pos - centreTete).Magnitude
						if d < meilleureDist then
							meilleur, meilleurePos, meilleureDist = modele, pos, d
						end
					end
				end
			end
		end
		return meilleur, meilleurePos
	end

	local function tirer()
		if not (tourelle and tourelle.Parent and tete) then return end
		local cible, pos = cibleLaPlusProche()
		if not cible then return end
		if (pos - centreTete).Magnitude > 0.01 then
			orienter(CFrame.lookAt(centreTete, pos))
		end
		local origine = bout and bout.Position or centreTete
		Bus.emettre("DegatsZbire", cible, reglages.degats or 0, nil, false)
		local effet = ctx.Reseau and ctx.Reseau.Effet
		if effet then
			pcall(function()
				effet:FireAllClients("Tir", pos, { origine = origine, critique = false })
			end)
		end
	end

	local function boucle(maGeneration)
		local cadence = reglages.cadence or 1
		if cadence <= 0 then cadence = 1 end
		local intervalle = 1 / cadence
		while generation == maGeneration do
			task.wait(intervalle)
			if generation == maGeneration and Etat:GetAttribute("Phase") == "Horde" then
				local ok, err = pcall(tirer)
				if not ok then warn("[Zsurvie] TourelleToit : " .. tostring(err)) end
			end
		end
	end

	-- ===== abonnements =====
	Bus.ecouter("JourDebut", function(jour)
		if jour ~= 1 then return end
		if not quelquunALaRecherche() then
			detruire()
			return
		end
		construire()
		local maGeneration = generation
		task.spawn(boucle, maGeneration)
	end)

	Bus.ecouter("RetourLobby", function()
		detruire()
	end)

	Bus.ecouter("MaisonTombee", function()
		detruire()
	end)
end

return M
