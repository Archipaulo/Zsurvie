-- Système Autotest : 3 s après le démarrage, vérifie que la map et les systèmes respectent le CONTRAT.
-- Chaque échec est signalé par un warn ; le bilan est affiché et posé sur Workspace.Dino (attribut « AutotestOk »).
local M = {}

local DELAI = 3

-- dossiers de construction qui doivent contenir quelque chose (Ciel peut rester vide)
local DOSSIERS = {
	"Sol", "Falaises", "Jungle", "Riviere", "Volcan", "Tapis", "Nurserie", "FinTapis", "Bases",
	"Place", "Comptoir", "Autel", "Cratere", "Fossiles", "Lumieres", "Signaletique",
}

-- enfants obligatoires d'une Base (CONTRAT §5)
local ENFANTS_BASE = {
	"Sol", "Zone", "Entree", "BoutonVerrou", "Collecte", "Emplacements", "Enseigne", "Apparition",
}

local NOMBRE_EMPLACEMENTS = 12

-- attributs de ReplicatedStorage.DinoEtat (CONTRAT §6)
local ATTRIBUTS_ETAT = {
	Evenement = "string",
	EvenementFin = "number",
	ProchainEvenement = "number",
	DinosSurTapis = "number",
	MeilleurRevenu = "number",
}

local NOMS_REMOTES = { "Acheter", "Renaissance", "Frapper", "Collecter", "Effet", "Notification" }

function M.demarrer(ctx)
	task.wait(DELAI)

	local total = 0
	local reussis = 0

	local function controle(ok, message)
		total = total + 1
		if ok then
			reussis = reussis + 1
		else
			warn("[Dino][Autotest] " .. message)
		end
		return ok
	end

	-- exécute une série de contrôles ; une erreur inattendue compte comme un échec
	local function protege(nom, fn)
		local ok, err = pcall(fn)
		if not ok then
			controle(false, "erreur pendant « " .. nom .. " » : " .. tostring(err))
		end
	end

	local racine = ctx.racine

	-- 1. dossiers de construction non vides
	protege("dossiers", function()
		for _, nom in ipairs(DOSSIERS) do
			local dossier = racine:FindFirstChild(nom)
			if not dossier then
				controle(false, "dossier de construction « " .. nom .. " » absent")
			else
				controle(#dossier:GetChildren() > 0, "dossier de construction « " .. nom .. " » vide")
			end
		end
	end)

	-- 2. gabarits des espèces
	protege("gabarits", function()
		local gabarits = ctx.stockage and ctx.stockage:FindFirstChild("Dinos")
		if not controle(gabarits ~= nil, "dossier ServerStorage.Dino.Dinos absent") then
			return
		end
		local attendus = 0
		for espece in pairs(ctx.Equilibrage.especes) do
			attendus = attendus + 1
			local modele = gabarits:FindFirstChild(espece)
			if not modele then
				controle(false, "gabarit « " .. espece .. " » absent")
			elseif not modele:IsA("Model") then
				controle(false, "gabarit « " .. espece .. " » n'est pas un Model")
			else
				controle(modele.PrimaryPart ~= nil, "gabarit « " .. espece .. " » sans PrimaryPart")
			end
		end
		local presents = 0
		for _, enfant in ipairs(gabarits:GetChildren()) do
			if enfant:IsA("Model") then
				presents = presents + 1
			end
		end
		controle(presents == attendus, string.format("%d gabarits trouvés pour %d espèces", presents, attendus))
	end)

	-- 3. les Bases
	protege("bases", function()
		local bases = racine:FindFirstChild("Bases")
		if not bases then
			controle(false, "dossier Bases absent : bases non vérifiées")
			return
		end
		local nombre = #ctx.Plan.bases
		for i = 1, nombre do
			local base = bases:FindFirstChild("Base" .. i)
			if not base then
				controle(false, "Base" .. i .. " absente")
			else
				local manquants = {}
				for _, nom in ipairs(ENFANTS_BASE) do
					if not base:FindFirstChild(nom) then
						table.insert(manquants, nom)
					end
				end
				controle(#manquants == 0, "Base" .. i .. " : enfants manquants " .. table.concat(manquants, ", "))

				local emplacements = base:FindFirstChild("Emplacements")
				if emplacements then
					local absents = {}
					for n = 1, NOMBRE_EMPLACEMENTS do
						local e = emplacements:FindFirstChild("E" .. n)
						if not e or not e:IsA("BasePart") then
							table.insert(absents, "E" .. n)
						end
					end
					controle(#absents == 0, "Base" .. i .. " : emplacements manquants " .. table.concat(absents, ", "))
				end

				local zone = base:FindFirstChild("Zone")
				if zone and zone:IsA("BasePart") then
					controle(zone.Transparency >= 1 and not zone.CanCollide,
						"Base" .. i .. " : la Zone doit être invisible et traversable")
				end

				local enseigne = base:FindFirstChild("Enseigne")
				if enseigne then
					local affiche = enseigne:FindFirstChild("Affiche", true)
					local titre = affiche and affiche:FindFirstChild("Titre", true)
					controle(titre ~= nil, "Base" .. i .. " : Enseigne sans Affiche > Titre")
				end

				local bouton = base:FindFirstChild("BoutonVerrou")
				if bouton then
					local invite = bouton:FindFirstChild("Verrouiller", true)
					controle(invite ~= nil and invite:IsA("ProximityPrompt"),
						"Base" .. i .. " : BoutonVerrou sans invite « Verrouiller »")
				end
			end
		end
	end)

	-- 4. une seule SpawnLocation dans le Workspace
	protege("apparition", function()
		local nombre = 0
		for _, objet in ipairs(workspace:GetDescendants()) do
			if objet:IsA("SpawnLocation") then
				nombre = nombre + 1
			end
		end
		controle(nombre == 1, string.format("%d SpawnLocation trouvée(s), 1 attendue", nombre))
	end)

	-- 5. invites de la map (les dinos vivants sont ignorés)
	protege("invites", function()
		local compte = { Boutique = 0, Renaissance = 0, Index = 0, Verrouiller = 0 }
		for _, objet in ipairs(racine:GetDescendants()) do
			if objet:IsA("ProximityPrompt") and compte[objet.Name] ~= nil then
				if not (ctx.dinos and objet:IsDescendantOf(ctx.dinos)) then
					compte[objet.Name] = compte[objet.Name] + 1
				end
			end
		end
		controle(compte.Boutique >= 1, "aucune invite « Boutique »")
		controle(compte.Renaissance >= 1, "aucune invite « Renaissance »")
		controle(compte.Index >= 1, "aucune invite « Index »")
		local bases = #ctx.Plan.bases
		controle(compte.Verrouiller == bases,
			string.format("%d invites « Verrouiller » trouvées, %d attendues", compte.Verrouiller, bases))
	end)

	-- 6. les RemoteEvents
	protege("remotes", function()
		for _, nom in ipairs(NOMS_REMOTES) do
			local ev = ctx.Reseau and ctx.Reseau[nom]
			controle(typeof(ev) == "Instance" and ev:IsA("RemoteEvent"), "RemoteEvent « " .. nom .. " » absent")
		end
	end)

	-- 7. les attributs d'état partagés
	protege("etat", function()
		for nom, genre in pairs(ATTRIBUTS_ETAT) do
			local valeur = ctx.Etat:GetAttribute(nom)
			controle(type(valeur) == genre, "attribut DinoEtat « " .. nom .. " » absent ou mal typé")
		end
	end)

	local ok = total > 0 and reussis == total
	print(string.format("[Dino] Autotest : %d/%d contrôles OK", reussis, total))
	pcall(function()
		racine:SetAttribute("AutotestOk", ok)
	end)
end

return M
