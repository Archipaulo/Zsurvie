-- Système Laboratoire : recherches permanentes payées en gemmes, débloquées au lobby (attributs Rech_<nom>).
local Players = game:GetService("Players")

local M = {}

local INTERVALLE_LIMITEUR = 0.3 -- secondes minimum entre deux demandes d'un même joueur

function M.demarrer(ctx)
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local Plan = ctx.Plan

	local derniereDemande = {}

	-- position de l'effet : au-dessus de l'Arbre des Recherches
	local positionLabo = Vector3.new(0, 8, 575)
	if Plan and Plan.lobby and typeof(Plan.lobby.laboratoire) == "Vector3" then
		positionLabo = Plan.lobby.laboratoire + Vector3.new(0, 8, 0)
	end

	local function notifier(joueur, texte, genre)
		local ev = Reseau and Reseau.Notification
		if ev and joueur and joueur.Parent then
			pcall(function()
				ev:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function effet(nom)
		local ev = Reseau and Reseau.Effet
		if ev then
			pcall(function()
				ev:FireAllClients("Recherche", positionLabo, { nom = nom })
			end)
		end
	end

	local function limiteurOk(joueur)
		local maintenant = os.clock()
		local dernier = derniereDemande[joueur]
		if dernier and maintenant - dernier < INTERVALLE_LIMITEUR then
			return false
		end
		derniereDemande[joueur] = maintenant
		return true
	end

	local function rechercher(joueur, nom)
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then return end
		if not limiteurOk(joueur) then return end
		if type(nom) ~= "string" or #nom == 0 or #nom > 64 then return end

		local recherches = E and E.recherches
		if type(recherches) ~= "table" then return end
		local def = recherches[nom]
		if type(def) ~= "table" then
			notifier(joueur, "Recherche inconnue", "alerte")
			return
		end

		if joueur:GetAttribute("EnRun") == true then
			notifier(joueur, "Les recherches se font au Laboratoire, pas pendant une run", "alerte")
			return
		end
		if joueur:GetAttribute("DonneesChargees") ~= true then
			notifier(joueur, "Ta sauvegarde n'est pas encore chargée, réessaie dans un instant", "alerte")
			return
		end
		if joueur:GetAttribute("Rech_" .. nom) == true then
			notifier(joueur, nom .. " est déjà débloquée", "alerte")
			return
		end

		local cout = def.cout
		if type(cout) ~= "number" or cout < 0 then return end

		local paye = Bus.demander("DepenserGemmes", joueur, cout)
		if paye ~= true then
			if paye == nil then
				notifier(joueur, "Le Laboratoire est fermé pour l'instant, réessaie plus tard", "alerte")
			else
				local gemmes = joueur:GetAttribute("Gemmes")
				if type(gemmes) == "number" and gemmes < cout then
					notifier(joueur, "Pas assez de gemmes : " .. cout .. " nécessaires (il en manque " .. (cout - gemmes) .. ")", "alerte")
				else
					notifier(joueur, "Paiement refusé : " .. cout .. " gemmes nécessaires", "alerte")
				end
			end
			return
		end

		joueur:SetAttribute("Rech_" .. nom, true)
		Bus.emettre("RechercheDebloquee", joueur, nom)
		notifier(joueur, "Recherche débloquée : " .. nom, "succes")
		effet(nom)
	end

	Players.PlayerRemoving:Connect(function(joueur)
		derniereDemande[joueur] = nil
	end)

	local ev = Reseau and Reseau.Rechercher
	if ev then
		ev.OnServerEvent:Connect(function(joueur, nom)
			local ok, err = pcall(rechercher, joueur, nom)
			if not ok then
				warn("[Zsurvie] Laboratoire : " .. tostring(err))
			end
		end)
	else
		warn("[Zsurvie] Laboratoire : RemoteEvent « Rechercher » introuvable")
	end
end

return M
