-- Système Oeufs : l'éclosion des Œufs mystères posés dans les Bases.
-- Un œuf commence à couver à sa première pose (attribut EclosionFin = os.time() + incubation, posé par Enclos ;
-- il est sauvegardé, donc le compte continue même hors ligne). À l'heure dite, l'œuf éclot sur son podium :
-- rareté tirée dans E.oeuf.raretes (du plus nul au plus rare), espèce au hasard dans cette rareté,
-- mutation possible. Au-dessus de l'œuf, un compte à rebours « 🐣 12:34 ».
local Players = game:GetService("Players")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local E = ctx.Equilibrage
	local Charte = ctx.Charte
	local Style = ctx.Style
	local Reseau = ctx.Reseau
	local O = E.oeuf or { raretes = { Commun = 1 }, incubation = 900, chanceMutation = 0 }
	local alea = Random.new()

	-- espèces normales par rareté
	local parRarete = {}
	for cle, fiche in pairs(E.especes) do
		if not fiche.special then
			parRarete[fiche.rarete] = parRarete[fiche.rarete] or {}
			table.insert(parRarete[fiche.rarete], cle)
		end
	end
	for _, l in pairs(parRarete) do table.sort(l) end

	local function tirer(poids)
		local total = 0
		for _, p in pairs(poids) do total = total + p end
		local r = alea:NextNumber() * total
		local ordre = {}
		for k in pairs(poids) do table.insert(ordre, k) end
		table.sort(ordre)
		for _, k in ipairs(ordre) do
			r = r - poids[k]
			if r <= 0 then return k end
		end
		return ordre[#ordre]
	end

	local function tirerEspece()
		local rarete = tirer(O.raretes)
		local liste = parRarete[rarete]
		if not liste or #liste == 0 then liste = parRarete.Commun end
		local espece = liste[alea:NextInteger(1, #liste)]
		local mutation = "Normal"
		if alea:NextNumber() < (O.chanceMutation or 0) then
			local poids = {}
			for nom, m in pairs(E.mutations) do
				if nom ~= "Normal" and not m.evenement and (m.poids or 0) > 0 then poids[nom] = m.poids end
			end
			if next(poids) then mutation = tirer(poids) end
		end
		return espece, rarete, mutation
	end

	local function format(secondes)
		secondes = math.max(0, math.floor(secondes))
		return string.format("%d:%02d", math.floor(secondes / 60), secondes % 60)
	end

	-- compte à rebours au-dessus de l'œuf
	local minuteurs = {}
	local function minuteur(oeuf)
		local m = minuteurs[oeuf]
		if m and m.Parent then return m end
		local corps = oeuf.PrimaryPart
		if not corps or not Style then return nil end
		local _, lignes = Style.etiquette(corps, {
			{ texte = "🐣 ÉCLOSION", titre = true, contour = 3, nom = "Titre", taille = 0.9 },
			{ texte = "15:00", titre = true, contour = 3.5, nom = "Temps", taille = 1.2 },
		}, { Name = "Eclosion", largeur = 7, hauteurLigne = 1.3, StudsOffset = Vector3.new(0, 15, 0), MaxDistance = 80 })
		m = lignes and lignes[2]
		if m then m.TextColor3 = Style.couleurs.revenu end
		minuteurs[oeuf] = m
		return m
	end

	local enCours = {}
	local function eclore(oeuf)
		if enCours[oeuf] then return end
		enCours[oeuf] = true
		local uid = oeuf:GetAttribute("Proprietaire")
		local joueur = type(uid) == "number" and Players:GetPlayerByUserId(uid) or nil
		local numero = oeuf:GetAttribute("Emplacement")
		if not joueur or type(numero) ~= "number" then
			enCours[oeuf] = nil
			return
		end
		local position = oeuf:GetPivot().Position
		local espece, rarete, mutation = tirerEspece()
		local dino = Bus.demander("CreerDino", espece, mutation)
		if not dino then
			enCours[oeuf] = nil
			return
		end
		oeuf:Destroy()
		minuteurs[oeuf] = nil
		dino:SetAttribute("Etat", "Enclos")
		local ok = Bus.demander("PlacerDino", dino, joueur, numero)
		if ok ~= true then
			local autre = Bus.demander("ReserverEmplacement", joueur)
			if not autre or Bus.demander("PlacerDino", dino, joueur, autre) ~= true then
				dino:Destroy()
				enCours[oeuf] = nil
				return
			end
		end
		local nom = (E.especes[espece] and E.especes[espece].nom) or espece
		local nomRarete = (E.raretes[rarete] and E.raretes[rarete].nom) or rarete
		local mut = ""
		if mutation ~= "Normal" and E.mutations[mutation] then mut = E.mutations[mutation].nom .. " " end
		pcall(function()
			Reseau.Notification:FireClient(joueur, "🐣 TON ŒUF A ÉCLOS : " .. mut .. nom .. " (" .. nomRarete .. ") !", "succes")
			Reseau.Effet:FireAllClients("Eclosion", position, { rarete = rarete, mutation = mutation, espece = espece })
		end)
		Bus.emettre("OeufEclos", joueur, dino, espece, rarete)
		enCours[oeuf] = nil
	end

	task.spawn(function()
		while true do
			local maintenant = os.time()
			for _, d in ipairs(ctx.dinos:GetChildren()) do
				if d:IsA("Model") and d:GetAttribute("Espece") == "OeufMystere" then
					local fin = d:GetAttribute("EclosionFin")
					if d:GetAttribute("Etat") == "Enclos" and type(fin) == "number" then
						local texte = minuteur(d)
						if texte then texte.Text = format(fin - maintenant) end
						if maintenant >= fin then pcall(eclore, d) end
					end
				end
			end
			task.wait(1)
		end
	end)

	-- ModeTest et banc d'essai : faire éclore tout de suite les œufs d'un joueur
	Bus.repondre("EclorOeufs", function(joueur)
		local n = 0
		for _, d in ipairs(ctx.dinos:GetChildren()) do
			if d:IsA("Model") and d:GetAttribute("Espece") == "OeufMystere" and d:GetAttribute("Proprietaire") == joueur.UserId then
				d:SetAttribute("EclosionFin", os.time())
				n = n + 1
			end
		end
		return n
	end)
end

return M
