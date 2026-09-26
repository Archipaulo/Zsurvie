-- Système Index (Dinodex) : première rencontre d'une espèce = récompense, notification et effet.
-- Une rareté entièrement découverte augmente le bonus de revenu permanent (BonusIndex).
-- BonusIndex est toujours recalculé depuis les attributs Index_* : le calcul reste idempotent.
local Players = game:GetService("Players")

local M = {}

local ATTENTE_DONNEES = 15 -- secondes max d'attente du chargement des données

-- nombre fini (ni NaN, ni infini)
local function estFini(n)
	return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

local function estJoueur(joueur)
	return typeof(joueur) == "Instance" and joueur:IsA("Player") and joueur.Parent == Players
end

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local E = ctx.Equilibrage
	local Charte = ctx.Charte
	local Reseau = ctx.Reseau

	local reglages = E.index or {}
	local RECOMPENSE = 250
	if estFini(reglages.recompenseParEspece) and reglages.recompenseParEspece >= 0 then
		RECOMPENSE = reglages.recompenseParEspece
	end
	local BONUS_RARETE = 0.1
	if estFini(reglages.bonusCompletRarete) and reglages.bonusCompletRarete >= 0 then
		BONUS_RARETE = reglages.bonusCompletRarete
	end

	-- espèces regroupées par rareté (seulement les raretés connues)
	local especesParRarete = {} -- [rarete] = { espece, ... }
	for espece, fiche in pairs(E.especes or {}) do
		if type(fiche) == "table" and type(fiche.rarete) == "string" and E.raretes and E.raretes[fiche.rarete] then
			local liste = especesParRarete[fiche.rarete]
			if not liste then
				liste = {}
				especesParRarete[fiche.rarete] = liste
			end
			table.insert(liste, espece)
		end
	end

	local function nomEspece(espece)
		local fiche = E.especes[espece]
		if fiche and type(fiche.nom) == "string" then
			return fiche.nom
		end
		return espece
	end

	local function nomRarete(rarete)
		local fiche = E.raretes[rarete]
		if fiche and type(fiche.nom) == "string" then
			return fiche.nom
		end
		return rarete
	end

	local function ordreRarete(rarete)
		local fiche = E.raretes[rarete]
		if fiche and estFini(fiche.ordre) and fiche.ordre > 0 then
			return fiche.ordre
		end
		return 1
	end

	-- montant au format du jeu (« $1,2K »), via la boîte à outils Style quand elle est là
	local formatArgent = Charte.argent
	if ctx.Style and type(ctx.Style.argent) == "function" then
		formatArgent = ctx.Style.argent
	end

	local function montant(n)
		local ok, texte = pcall(formatArgent, n)
		if ok and type(texte) == "string" then
			return texte
		end
		return tostring(math.floor(n))
	end

	local function notifier(joueur, texte, genre)
		pcall(function()
			Reseau.Notification:FireClient(joueur, texte, genre)
		end)
	end

	local function rareteComplete(joueur, rarete)
		local liste = especesParRarete[rarete]
		if not liste or #liste == 0 then
			return false
		end
		for _, espece in ipairs(liste) do
			if joueur:GetAttribute("Index_" .. espece) ~= true then
				return false
			end
		end
		return true
	end

	-- nombre de raretés complètes x bonus, recalculé depuis les attributs
	local function recalculerBonus(joueur)
		local complets = 0
		for rarete in pairs(especesParRarete) do
			if rareteComplete(joueur, rarete) then
				complets = complets + 1
			end
		end
		local bonus = math.floor(complets * BONUS_RARETE * 1000 + 0.5) / 1000
		if joueur:GetAttribute("BonusIndex") ~= bonus then
			joueur:SetAttribute("BonusIndex", bonus)
		end
		return bonus
	end

	-- attend le chargement des données (sinon la sauvegarde écraserait la découverte)
	local function attendreDonnees(joueur)
		local debut = os.clock()
		while estJoueur(joueur) and joueur:GetAttribute("DonneesChargees") ~= true do
			if os.clock() - debut > ATTENTE_DONNEES then
				break
			end
			task.wait(0.25)
		end
		return estJoueur(joueur)
	end

	local function positionDe(dino)
		local ok, position = pcall(function()
			return dino:GetPivot().Position
		end)
		if ok and typeof(position) == "Vector3" then
			return position
		end
		return nil
	end

	local function decouvrir(dino, joueur)
		if not estJoueur(joueur) then
			return
		end
		if typeof(dino) ~= "Instance" then
			return
		end
		local espece = dino:GetAttribute("Espece")
		if type(espece) ~= "string" or not E.especes[espece] then
			return
		end
		local position = positionDe(dino)
		if not attendreDonnees(joueur) then
			return
		end
		local cle = "Index_" .. espece
		if joueur:GetAttribute(cle) == true then
			return
		end
		-- vérification et marquage sans pause : aucune double récompense possible
		joueur:SetAttribute(cle, true)

		local rarete = E.especes[espece].rarete
		local gain = RECOMPENSE * ordreRarete(rarete)
		if gain > 0 then
			Bus.demander("AjouterArgent", joueur, gain, "Index")
		end
		Bus.emettre("EspeceDecouverte", joueur, espece)
		-- notification courte et percutante (lisible sur mobile) : « 📖 NOUVELLE ESPÈCE : Rex ! +$1K »
		local message = "📖 NOUVELLE ESPÈCE : " .. nomEspece(espece) .. " !"
		if gain > 0 then
			message = message .. " +" .. montant(gain)
		end
		notifier(joueur, message, "succes")
		pcall(function()
			Reseau.Effet:FireClient(joueur, "Decouverte", position, { espece = espece })
		end)

		local avant = joueur:GetAttribute("BonusIndex")
		local apres = recalculerBonus(joueur)
		if rareteComplete(joueur, rarete) and (not estFini(avant) or apres > avant) then
			local pourcent = math.floor(BONUS_RARETE * 100 + 0.5)
			notifier(joueur, "🌈 Rareté complète : " .. nomRarete(rarete) .. " ! Revenus +" .. pourcent .. " %", "succes")
		end
	end

	Bus.ecouter("DinoPlace", function(dino, joueur)
		task.spawn(decouvrir, dino, joueur)
	end)

	Bus.ecouter("DinoVole", function(dino, voleur)
		task.spawn(decouvrir, dino, voleur)
	end)

	-- remise en cohérence du bonus dès que les données sont chargées
	local connexions = {} -- [joueur] = connexion sur DonneesChargees
	local function suivre(joueur)
		if connexions[joueur] then
			return
		end
		local function verifier()
			if estJoueur(joueur) and joueur:GetAttribute("DonneesChargees") == true then
				pcall(recalculerBonus, joueur)
			end
		end
		connexions[joueur] = joueur:GetAttributeChangedSignal("DonneesChargees"):Connect(verifier)
		verifier()
	end

	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(suivre, joueur)
	end
	Players.PlayerAdded:Connect(suivre)
	-- le Player n'est pas détruit à son départ : on coupe la connexion pour ne pas le retenir en mémoire
	Players.PlayerRemoving:Connect(function(joueur)
		local c = connexions[joueur]
		connexions[joueur] = nil
		if c then
			pcall(function()
				c:Disconnect()
			end)
		end
	end)
end

return M
