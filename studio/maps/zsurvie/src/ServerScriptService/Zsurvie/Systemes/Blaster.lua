-- Systemes/Blaster : tir serveur-autoritaire (cadence, portée, cible, dégâts, critiques, balles spéciales).
local Players = game:GetService("Players")

local M = {}

local TOLERANCE_PORTEE = 5 -- marge de latence sur la portée
local RAYON_VISEE = 4 -- rayon de recherche autour du point visé
local RAYON_PERFORANT = 8 -- rayon de la balle perforante autour de la cible
local PART_PERFORANTE = 0.6
local PART_EXPLOSION = 0.4
local BONUS_VISEE_CRITIQUE = 0.10
local MARGE_CADENCE = 0.8 -- tolérance sur l'intervalle minimal (gigue réseau)

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Etat = ctx.Etat
	local horde = ctx.horde
	local tirage = Random.new()
	local dernierTir = {}

	local remoteTirer = Reseau and Reseau.Tirer
	local remoteEffet = Reseau and Reseau.Effet
	if not remoteTirer then
		warn("[Zsurvie] Blaster : RemoteEvent « Tirer » introuvable")
		return
	end

	-- niveau d'amélioration (nombre valide, 0 sinon)
	local function niveau(joueur, nom)
		local v = joueur:GetAttribute("Niv_" .. nom)
		if type(v) ~= "number" or v ~= v then return 0 end
		if v < 0 then return 0 end
		return v
	end

	local function effetAmelioration(nom)
		local a = E.ameliorations and E.ameliorations[nom]
		if a and type(a.effet) == "number" then return a.effet end
		return 0
	end

	-- position de référence d'un Zbire (Corps, sinon pivot)
	local function positionZbire(modele)
		local corps = modele.PrimaryPart or modele:FindFirstChild("Corps")
		if corps and corps:IsA("BasePart") then return corps.Position end
		local ok, cf = pcall(function() return modele:GetPivot() end)
		if ok and cf then return cf.Position end
		return nil
	end

	local function estVivant(modele)
		if not modele or not modele.Parent or not modele:IsA("Model") then return false end
		local pv = modele:GetAttribute("PV")
		return type(pv) == "number" and pv > 0
	end

	-- liste des Zbires vivants avec leur position
	local function zbiresVivants()
		local liste = {}
		if not horde or not horde.Parent then return liste end
		for _, enfant in ipairs(horde:GetChildren()) do
			if estVivant(enfant) then
				local pos = positionZbire(enfant)
				if pos then table.insert(liste, { modele = enfant, position = pos }) end
			end
		end
		return liste
	end

	local function trouverCible(liste, position, idZbire)
		if idZbire then
			for _, z in ipairs(liste) do
				if z.modele:GetAttribute("Id") == idZbire then return z end
			end
		end
		local meilleure, meilleureDist = nil, RAYON_VISEE
		for _, z in ipairs(liste) do
			local d = (z.position - position).Magnitude
			if d < meilleureDist then
				meilleure = z
				meilleureDist = d
			end
		end
		return meilleure
	end

	local function envoyerEffet(genre, position, donnees)
		if not remoteEffet then return end
		pcall(function() remoteEffet:FireAllClients(genre, position, donnees) end)
	end

	local function traiterTir(joueur, position, idZbire)
		-- validation des arguments
		if typeof(position) ~= "Vector3" then return end
		if position.X ~= position.X or position.Y ~= position.Y or position.Z ~= position.Z then return end
		if idZbire ~= nil and type(idZbire) ~= "string" then return end
		if type(idZbire) == "string" and #idZbire > 32 then return end

		-- état du joueur et de la partie
		if joueur:GetAttribute("EnRun") ~= true then return end
		local phase = Etat and Etat:GetAttribute("Phase")
		if phase ~= "Horde" and phase ~= "Repit" then return end
		local perso = joueur.Character
		if not perso then return end
		local hrp = perso:FindFirstChild("HumanoidRootPart")
		if not hrp or not hrp:IsA("BasePart") then return end

		-- cadence
		local cadence = E.blaster.cadence * (1 + niveau(joueur, "Cadence") * effetAmelioration("Cadence"))
		if cadence <= 0 then return end
		local intervalle = 1 / cadence * MARGE_CADENCE
		local maintenant = os.clock()
		local precedent = dernierTir[joueur]
		if precedent and maintenant - precedent < intervalle then return end
		if Bus.demander("AutoriserAction", joueur, "Tirer", intervalle) == false then return end

		-- cible
		local liste = zbiresVivants()
		local cible = trouverCible(liste, position, idZbire)
		if not cible then return end
		local portee = E.blaster.portee + niveau(joueur, "Portee") * effetAmelioration("Portee")
		local origine = hrp.Position
		if (cible.position - origine).Magnitude > portee + TOLERANCE_PORTEE then return end
		dernierTir[joueur] = maintenant

		-- dégâts et critique
		local degats = E.blaster.degats * (1 + niveau(joueur, "Degats") * effetAmelioration("Degats"))
		local chance = E.blaster.chanceCritique
		if joueur:GetAttribute("Rech_ViseeCritique") == true then
			chance = chance + BONUS_VISEE_CRITIQUE
		end
		local critique = tirage:NextNumber() < chance
		if critique then
			degats = degats * E.blaster.multiplicateurCritique
		end

		-- cibles secondaires, calculées avant d'appliquer les dégâts
		local perforee = nil
		if joueur:GetAttribute("Rech_BallesPerforantes") == true then
			local meilleureDist = RAYON_PERFORANT
			for _, z in ipairs(liste) do
				if z.modele ~= cible.modele then
					local d = (z.position - cible.position).Magnitude
					if d < meilleureDist then
						perforee = z
						meilleureDist = d
					end
				end
			end
		end

		local nivExplosion = niveau(joueur, "BallesExplosives")
		local souffles = {}
		local rayonExplosion = 0
		if nivExplosion > 0 then
			rayonExplosion = 3 + nivExplosion
			for _, z in ipairs(liste) do
				if z.modele ~= cible.modele and (z.position - cible.position).Magnitude <= rayonExplosion then
					table.insert(souffles, z.modele)
				end
			end
		end

		-- effet visuel du tir
		envoyerEffet("Tir", cible.position, { origine = origine + Vector3.new(0, 2, 0), critique = critique })

		-- application des dégâts
		Bus.emettre("DegatsZbire", cible.modele, degats, joueur, critique)
		if perforee and estVivant(perforee.modele) then
			Bus.emettre("DegatsZbire", perforee.modele, degats * PART_PERFORANTE, joueur, critique)
		end
		if nivExplosion > 0 then
			envoyerEffet("Explosion", cible.position, { rayon = rayonExplosion })
			for _, modele in ipairs(souffles) do
				if estVivant(modele) then
					Bus.emettre("DegatsZbire", modele, degats * PART_EXPLOSION, joueur, false)
				end
			end
		end
	end

	remoteTirer.OnServerEvent:Connect(function(joueur, position, idZbire)
		local ok, err = pcall(traiterTir, joueur, position, idZbire)
		if not ok then warn("[Zsurvie] Blaster : " .. tostring(err)) end
	end)

	-- nettoyage de la cadence au départ d'un joueur
	local function surDepart(joueur)
		dernierTir[joueur] = nil
	end
	Players.PlayerRemoving:Connect(surDepart)
	for _, joueur in ipairs(Players:GetPlayers()) do
		dernierTir[joueur] = nil
	end
	Players.PlayerAdded:Connect(function(joueur)
		dernierTir[joueur] = nil
	end)
end

return M
