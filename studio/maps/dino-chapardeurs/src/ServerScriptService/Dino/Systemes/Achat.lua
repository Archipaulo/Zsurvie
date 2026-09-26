-- Système Achat : achat des dinos sur le Tapis (invite « Acheter »), puis marche du dino jusqu'à la Base de son acheteur.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Reseau = ctx.Reseau

	local VITESSE = (E.tapis and E.tapis.vitesseMarche) or 14
	local MARGE_DISTANCE = 6 -- tolérance (studs) au-delà de la portée de l'invite

	local enAchat = {}   -- [dino] = true pendant la transaction (le premier gagne)
	local marcheurs = {} -- liste des dinos en route vers leur Base

	-- ===== utilitaires =====
	local function notifier(joueur, texte, genre)
		if joueur and joueur.Parent then
			pcall(function()
				Reseau.Notification:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function effet(genre, position, donnees)
		pcall(function()
			Reseau.Effet:FireAllClients(genre, position, donnees)
		end)
	end

	-- remonte jusqu'au Model posé directement dans ctx.dinos
	local function dinoDe(inst)
		local courant = inst
		while courant and courant.Parent do
			if courant.Parent == ctx.dinos then
				if courant:IsA("Model") then return courant end
				return nil
			end
			courant = courant.Parent
		end
		return nil
	end

	local function vivant(dino)
		return dino ~= nil and dino.Parent == ctx.dinos
	end

	local function pivotDe(dino)
		local ok, cf = pcall(function() return dino:GetPivot() end)
		if ok then return cf end
		return nil
	end

	local function liberer(joueur, numero)
		if joueur and numero then
			Bus.demander("LibererEmplacement", joueur, numero)
		end
	end

	local function nomEspece(dino)
		local espece = dino:GetAttribute("Espece")
		local fiche = E.especes and E.especes[espece]
		if fiche and fiche.nom then return fiche.nom end
		return tostring(espece or "dino")
	end

	-- point d'entrée d'une Base : centre décalé vers le Tapis d'une demi-profondeur
	local function entreeBase(index)
		local b = Plan.bases[index]
		if not b then return nil end
		local sens = b.versTapis or 1
		local profondeur = (Plan.base and Plan.base.profondeur) or 50
		local ySol = (Plan.base and Plan.base.hauteurSol) or 1
		return Vector3.new(b.centre.X, ySol, b.centre.Z + sens * profondeur / 2)
	end

	-- ===== la marche vers la Base =====
	local function arreterMarche(m)
		m.fini = true
	end

	-- abandon en route : libère l'emplacement ; détruit le dino s'il reste orphelin
	local function abandonner(m)
		arreterMarche(m)
		liberer(m.joueur, m.numero)
		if vivant(m.dino) and not (m.joueur and m.joueur.Parent) then
			pcall(function() m.dino:Destroy() end)
		end
	end

	local function arriver(m)
		arreterMarche(m)
		task.spawn(function()
			if not vivant(m.dino) or not m.joueur.Parent then
				abandonner(m)
				return
			end
			local place = Bus.demander("PlacerDino", m.dino, m.joueur, m.numero)
			if place ~= true then
				-- la pose a échoué : on rend l'argent plutôt que de laisser un dino perdu
				liberer(m.joueur, m.numero)
				local prix = m.dino:GetAttribute("Prix")
				if type(prix) == "number" and prix > 0 and m.joueur.Parent then
					Bus.demander("AjouterArgent", m.joueur, prix, "Remboursement")
					notifier(m.joueur, "Ton dino n'a pas pu entrer dans ta base : tu es remboursé.", "alerte")
				end
				if vivant(m.dino) then
					pcall(function() m.dino:Destroy() end)
				end
			end
		end)
	end

	local function lancerMarche(dino, joueur, index, numero)
		local depart = pivotDe(dino)
		local entree = entreeBase(index)
		local cfFin = Bus.demander("CFrameEmplacement", index, numero)
		if not depart or not entree or typeof(cfFin) ~= "CFrame" then
			return false
		end
		local m = {
			dino = dino,
			joueur = joueur,
			index = index,
			numero = numero,
			position = depart.Position,
			etapes = { entree, cfFin.Position },
			etape = 1,
			cfFin = cfFin,
			regard = depart.LookVector,
			fini = false,
		}
		table.insert(marcheurs, m)
		return true
	end

	local function avancer(m, dt)
		if m.fini then return end
		if not vivant(m.dino) or not m.joueur.Parent then
			abandonner(m)
			return
		end
		if m.dino:GetAttribute("Etat") ~= "EnRoute" then
			-- un autre système a repris la main sur ce dino
			arreterMarche(m)
			return
		end
		local reste = VITESSE * dt
		while reste > 0 and not m.fini do
			local cible = m.etapes[m.etape]
			local ecart = cible - m.position
			local distance = ecart.Magnitude
			local plat = Vector3.new(ecart.X, 0, ecart.Z)
			if plat.Magnitude > 0.05 then
				m.regard = plat.Unit
			end
			if distance <= reste then
				m.position = cible
				reste = reste - distance
				m.etape = m.etape + 1
				if m.etape > #m.etapes then
					pcall(function() m.dino:PivotTo(m.cfFin) end)
					arriver(m)
					return
				end
			else
				m.position = m.position + ecart.Unit * reste
				reste = 0
			end
		end
		local cf = CFrame.lookAt(m.position, m.position + m.regard)
		pcall(function() m.dino:PivotTo(cf) end)
	end

	RunService.Heartbeat:Connect(function(dt)
		if #marcheurs == 0 then return end
		for _, m in ipairs(marcheurs) do
			local ok = pcall(avancer, m, dt)
			if not ok then
				abandonner(m)
			end
		end
		for i = #marcheurs, 1, -1 do
			if marcheurs[i].fini then table.remove(marcheurs, i) end
		end
	end)

	Players.PlayerRemoving:Connect(function(joueur)
		for _, m in ipairs(marcheurs) do
			if m.joueur == joueur and not m.fini then
				abandonner(m)
			end
		end
	end)

	-- ===== l'achat =====
	local function acheter(dino, joueur, invite)
		if dino:GetAttribute("Etat") ~= "Tapis" then return end

		-- distance : l'invite a sa portée, on ajoute une petite marge
		local perso = joueur.Character
		local racine = perso and perso:FindFirstChild("HumanoidRootPart")
		local pos = pivotDe(dino)
		if not racine or not pos then return end
		local portee = 10
		if invite and invite:IsA("ProximityPrompt") then portee = invite.MaxActivationDistance end
		if (racine.Position - pos.Position).Magnitude > portee + MARGE_DISTANCE + dino:GetExtentsSize().Magnitude / 2 then
			return
		end

		if Bus.demander("AutoriserAction", joueur, "Achat", 0.25) == false then return end

		local index = Bus.demander("BaseDe", joueur)
		if type(index) ~= "number" or not Plan.bases[index] then
			notifier(joueur, "Ta base n'est pas encore prête.", "alerte")
			return
		end

		local prix = dino:GetAttribute("Prix")
		if type(prix) ~= "number" or prix < 0 then return end

		local numero = Bus.demander("ReserverEmplacement", joueur)
		if type(numero) ~= "number" then
			notifier(joueur, "Ta base est pleine !", "alerte")
			return
		end

		-- le dino a pu quitter le Tapis pendant la réservation
		if not vivant(dino) or dino:GetAttribute("Etat") ~= "Tapis" then
			liberer(joueur, numero)
			return
		end

		if Bus.demander("DepenserArgent", joueur, prix) ~= true then
			liberer(joueur, numero)
			notifier(joueur, "Pas assez d'argent", "alerte")
			return
		end

		-- payé : si le dino a disparu entre-temps, on rembourse
		if not vivant(dino) or dino:GetAttribute("Etat") ~= "Tapis" or not joueur.Parent then
			liberer(joueur, numero)
			if joueur.Parent and prix > 0 then
				Bus.demander("AjouterArgent", joueur, prix, "Remboursement")
			end
			return
		end

		dino:SetAttribute("Etat", "EnRoute")
		dino:SetAttribute("Proprietaire", joueur.UserId)
		dino:SetAttribute("Base", index)
		dino:SetAttribute("Emplacement", numero)

		-- retire l'invite Acheter
		for _, d in ipairs(dino:GetDescendants()) do
			if d:IsA("ProximityPrompt") and d.Name == "Acheter" then
				pcall(function() d:Destroy() end)
			end
		end

		Bus.emettre("DinoAchete", dino, joueur)
		local position = pivotDe(dino)
		effet("Achat", position and position.Position or pos.Position, { rarete = dino:GetAttribute("Rarete") })
		notifier(joueur, nomEspece(dino) .. " rejoint ta base !", "succes")

		if not lancerMarche(dino, joueur, index, numero) then
			-- pas de trajet possible : on pose directement
			arriver({ dino = dino, joueur = joueur, index = index, numero = numero })
		end
	end

	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Acheter" then return end
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") or not joueur.Parent then return end
		local dino = dinoDe(invite)
		if not dino then return end
		if enAchat[dino] then return end
		enAchat[dino] = true
		local ok = pcall(acheter, dino, joueur, invite)
		enAchat[dino] = nil
		if not ok then
			-- en cas d'erreur imprévue, rien n'est laissé à moitié : le dino reste sur le Tapis
			return
		end
	end)
end

return M
