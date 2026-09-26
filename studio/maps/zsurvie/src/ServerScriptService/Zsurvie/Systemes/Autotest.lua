-- Systemes/Autotest : contrôle automatique de la map quelques secondes après le démarrage.
-- Vérifie les dossiers de construction, les gabarits de Zbires, le réseau, le point
-- d'apparition, les invites indispensables et l'état partagé. Chaque échec est signalé
-- par un warn ; le bilan est affiché et publié dans l'attribut « AutotestOk » de la racine.
local M = {}

-- délai technique avant le contrôle (laisse les constructeurs finir leurs task.spawn)
local DELAI = 3

-- dossiers de construction attendus dans Workspace.Zsurvie
local DOSSIERS = {
	"Ciel", "IleLabo", "Prairie", "Relief", "Vegetation", "Eau", "Maison", "Mine", "Props",
	"PointsInteret", "Portails", "Lumieres", "Signaletique", "Fanions", "Laboratoire",
	"QuaiCapsules", "Galerie", "Parcours", "Enigme", "Records", "Monument", "ScenePhoto",
}

-- dossiers autorisés à rester vides (le Ciel agit sur Lighting)
local PEUT_ETRE_VIDE = { Ciel = true }

-- attributs de l'état partagé (CONTRAT §4)
local ATTRIBUTS_ETAT = {
	"Phase", "Jour", "TempsRestant", "PVMaison", "PVMaisonMax", "ZbiresRestants", "ColosseActif", "Record",
}

-- noms des RemoteEvents attendus (repli si Reseau.NOMS est inaccessible)
local NOMS_RESEAU = { "Tirer", "Acheter", "Rechercher", "Reparer", "Ping", "Effet", "Notification" }

-- noms des gabarits de Zbires (repli si Equilibrage.zbires est absent)
local TYPES_ZBIRES = {
	"Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse",
}

local function typesZbires(ctx)
	local liste = {}
	local E = ctx.Equilibrage
	if type(E) == "table" and type(E.zbires) == "table" then
		for nom, _ in pairs(E.zbires) do
			table.insert(liste, nom)
		end
	end
	if #liste == 0 then
		for _, nom in ipairs(TYPES_ZBIRES) do
			table.insert(liste, nom)
		end
	end
	table.sort(liste)
	return liste
end

local function executer(ctx)
	local total = 0
	local reussis = 0

	local function controle(ok, message)
		total = total + 1
		if ok then
			reussis = reussis + 1
		else
			warn("[Zsurvie][Autotest] " .. message)
		end
		return ok
	end

	-- 1. dossiers de construction
	local racine = ctx.racine
	if controle(racine ~= nil and racine.Parent ~= nil, "la racine Workspace.Zsurvie est introuvable") then
		for _, nom in ipairs(DOSSIERS) do
			local dossier = racine:FindFirstChild(nom)
			if controle(dossier ~= nil, "dossier de construction manquant : " .. nom) then
				if not PEUT_ETRE_VIDE[nom] then
					controle(#dossier:GetChildren() > 0, "dossier de construction vide : " .. nom)
				end
			end
		end
	end

	-- 2. gabarits de Zbires dans ServerStorage.Zsurvie.Zbires
	local stockage = ctx.stockage
	local zbires = nil
	if stockage then
		zbires = stockage:FindFirstChild("Zbires")
	end
	if controle(zbires ~= nil, "dossier ServerStorage.Zsurvie.Zbires introuvable") then
		local types = typesZbires(ctx)
		controle(#zbires:GetChildren() >= #types,
			string.format("gabarits de Zbires : %d trouvés, %d attendus", #zbires:GetChildren(), #types))
		for _, nom in ipairs(types) do
			local gabarit = zbires:FindFirstChild(nom)
			if controle(gabarit ~= nil and gabarit:IsA("Model"), "gabarit de Zbire manquant ou pas un Model : " .. nom) then
				controle(gabarit.PrimaryPart ~= nil, "gabarit « " .. nom .. " » sans PrimaryPart")
				local barre = gabarit:FindFirstChild("Barre", true)
				controle(barre ~= nil and barre:IsA("BillboardGui"), "gabarit « " .. nom .. " » sans BillboardGui « Barre »")
			end
		end
	end

	-- 3. RemoteEvents
	local noms = NOMS_RESEAU
	local okNoms, Reseau = pcall(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local partage = ReplicatedStorage:FindFirstChild("Zsurvie")
		local module = partage and partage:FindFirstChild("Reseau")
		if module then
			return require(module)
		end
		return nil
	end)
	if okNoms and type(Reseau) == "table" and type(Reseau.NOMS) == "table" and #Reseau.NOMS > 0 then
		noms = Reseau.NOMS
	end
	local reseau = ctx.Reseau
	if controle(type(reseau) == "table", "table ctx.Reseau absente") then
		for _, nom in ipairs(noms) do
			local ev = reseau[nom]
			controle(ev ~= nil and typeof(ev) == "Instance" and ev:IsA("RemoteEvent") and ev.Parent ~= nil,
				"RemoteEvent manquant : " .. nom)
		end
	end

	-- 4. SpawnLocation unique et invites, en un seul parcours de workspace
	local nbSpawns = 0
	local invites = { Etabli = 0, ArbreRecherches = 0, Capsule = 0 }
	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("SpawnLocation") then
			nbSpawns = nbSpawns + 1
		elseif inst:IsA("ProximityPrompt") then
			local nom = inst.Name
			if invites[nom] ~= nil then
				invites[nom] = invites[nom] + 1
			elseif string.sub(nom, 1, 7) == "Capsule" then
				invites.Capsule = invites.Capsule + 1
			end
		end
	end
	controle(nbSpawns == 1, string.format("%d SpawnLocation dans workspace (1 attendue)", nbSpawns))
	controle(invites.Etabli > 0, "ProximityPrompt « Etabli » introuvable")
	controle(invites.ArbreRecherches > 0, "ProximityPrompt « ArbreRecherches » introuvable")
	controle(invites.Capsule > 0, "aucun ProximityPrompt « Capsule »")

	-- 5. attributs de l'état partagé
	local Etat = ctx.Etat
	if controle(Etat ~= nil, "dossier d'état ZsurvieEtat introuvable") then
		for _, nom in ipairs(ATTRIBUTS_ETAT) do
			controle(Etat:GetAttribute(nom) ~= nil, "attribut d'état manquant : " .. nom)
		end
	end

	-- bilan
	local toutOk = reussis == total
	print(string.format("[Zsurvie] Autotest : %d/%d contrôles OK", reussis, total))
	if racine then
		pcall(function()
			racine:SetAttribute("AutotestOk", toutOk)
		end)
	end
	return toutOk
end

function M.demarrer(ctx)
	task.delay(DELAI, function()
		local ok, err = pcall(executer, ctx)
		if not ok then
			warn("[Zsurvie][Autotest] erreur pendant les contrôles : " .. tostring(err))
			if ctx.racine then
				pcall(function()
					ctx.racine:SetAttribute("AutotestOk", false)
				end)
			end
		end
	end)
end

return M
