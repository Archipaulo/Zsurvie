-- Systemes/Classement : leaderstats (Jour, Record) de chaque joueur et record du serveur.
local Players = game:GetService("Players")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Etat = ctx.Etat

	local fiches = {} -- joueur -> { jour = IntValue, record = IntValue, connexions = {...} }

	-- lecture sûre d'un nombre entier positif
	local function entier(valeur)
		if type(valeur) ~= "number" or valeur ~= valeur then
			return 0
		end
		return math.max(0, math.floor(valeur))
	end

	local function jourEnCours()
		return entier(Etat:GetAttribute("Jour"))
	end

	local function enRun(joueur)
		return joueur ~= nil and joueur.Parent == Players and joueur:GetAttribute("EnRun") == true
	end

	-- record du serveur : ne fait que monter
	local function noterRecordServeur(valeur)
		local v = entier(valeur)
		if v > entier(Etat:GetAttribute("Record")) then
			Etat:SetAttribute("Record", v)
		end
	end

	-- recopie l'attribut RecordJour dans l'IntValue « Record »
	local function synchroniserRecord(joueur)
		local fiche = fiches[joueur]
		local record = entier(joueur:GetAttribute("RecordJour"))
		if fiche and fiche.record and fiche.record.Parent then
			fiche.record.Value = record
		end
		noterRecordServeur(record)
	end

	local function definirJour(joueur, jour)
		local fiche = fiches[joueur]
		if fiche and fiche.jour and fiche.jour.Parent then
			fiche.jour.Value = entier(jour)
		end
	end

	local function valeurEntiere(parent, nom)
		local v = parent:FindFirstChild(nom)
		if v and not v:IsA("IntValue") then
			v:Destroy()
			v = nil
		end
		if not v then
			v = Instance.new("IntValue")
			v.Name = nom
			v.Parent = parent
		end
		return v
	end

	local function preparer(joueur)
		if fiches[joueur] then return end
		local stats = joueur:FindFirstChild("leaderstats")
		if stats and not stats:IsA("Folder") then
			stats:Destroy()
			stats = nil
		end
		if not stats then
			stats = Instance.new("Folder")
			stats.Name = "leaderstats"
			stats.Parent = joueur
		end
		local fiche = {
			jour = valeurEntiere(stats, "Jour"),
			record = valeurEntiere(stats, "Record"),
			connexions = {},
		}
		fiches[joueur] = fiche

		-- jour affiché : celui de la run si le joueur y participe
		if enRun(joueur) then
			fiche.jour.Value = jourEnCours()
		else
			fiche.jour.Value = 0
		end
		synchroniserRecord(joueur)

		-- le record arrive avec la sauvegarde (Donnees) ou quand il est battu
		table.insert(fiche.connexions, joueur:GetAttributeChangedSignal("RecordJour"):Connect(function()
			synchroniserRecord(joueur)
		end))
		table.insert(fiche.connexions, joueur:GetAttributeChangedSignal("DonneesChargees"):Connect(function()
			if joueur:GetAttribute("DonneesChargees") == true then
				synchroniserRecord(joueur)
			end
		end))
		-- sortie de run : le jour affiché retombe à 0
		table.insert(fiche.connexions, joueur:GetAttributeChangedSignal("EnRun"):Connect(function()
			if joueur:GetAttribute("EnRun") ~= true then
				definirJour(joueur, 0)
			end
		end))
	end

	local function oublier(joueur)
		local fiche = fiches[joueur]
		if not fiche then return end
		for _, c in ipairs(fiche.connexions) do
			pcall(function() c:Disconnect() end)
		end
		fiches[joueur] = nil
	end

	Players.PlayerAdded:Connect(function(joueur)
		local ok, err = pcall(preparer, joueur)
		if not ok then
			warn("[Zsurvie] Classement : préparation de " .. joueur.Name .. " : " .. tostring(err))
		end
	end)
	Players.PlayerRemoving:Connect(oublier)
	for _, joueur in ipairs(Players:GetPlayers()) do
		local ok, err = pcall(preparer, joueur)
		if not ok then
			warn("[Zsurvie] Classement : préparation de " .. joueur.Name .. " : " .. tostring(err))
		end
	end

	-- nouveau jour : mise à jour du jour affiché et des records
	Bus.ecouter("JourDebut", function(jour)
		if type(jour) ~= "number" then return end
		local j = entier(jour)
		for _, joueur in ipairs(Players:GetPlayers()) do
			if enRun(joueur) then
				if not fiches[joueur] then
					pcall(preparer, joueur)
				end
				definirJour(joueur, j)
				local record = entier(joueur:GetAttribute("RecordJour"))
				if j > record then
					record = j
					joueur:SetAttribute("RecordJour", record)
				end
				local fiche = fiches[joueur]
				if fiche and fiche.record and fiche.record.Parent then
					fiche.record.Value = record
				end
				noterRecordServeur(record)
			end
		end
	end)

	-- retour au lobby : plus personne n'est en run
	Bus.ecouter("RetourLobby", function()
		for _, joueur in ipairs(Players:GetPlayers()) do
			definirJour(joueur, 0)
		end
	end)
end

return M
