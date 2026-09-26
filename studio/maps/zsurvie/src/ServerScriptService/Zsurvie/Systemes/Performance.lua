-- Systemes/Performance : surveille le nombre de parts et de Zbires, ajuste le plafond
-- de Zbires selon la charge du serveur et nettoie les pièces volantes oubliées.
local M = {}

-- réglages techniques (surchargeables par Equilibrage.performance s'il existe)
local DEFAUTS = {
	intervalle = 5, -- secondes entre deux mesures
	maxZbires = 60, -- plafond normal de Zbires simultanés
	maxZbiresReduit = 40, -- plafond quand le serveur rame
	seuilHeartbeatMs = 20, -- au-delà, le serveur est considéré comme chargé
	dureeViePiece = 10, -- secondes avant de détruire une pièce oubliée
	alertePartsMax = 12000, -- au-delà, on prévient (warn)
}

local function reglages(E)
	local r = {}
	for cle, valeur in pairs(DEFAUTS) do
		r[cle] = valeur
	end
	local perf = nil
	if type(E) == "table" then
		perf = E.performance
	end
	if type(perf) == "table" then
		for cle, valeur in pairs(perf) do
			if type(valeur) == "number" and DEFAUTS[cle] ~= nil then
				r[cle] = valeur
			end
		end
	end
	return r
end

-- nombre de BasePart dans une instance (elle comprise)
local function compterParts(instance)
	if not instance then return 0 end
	local n = 0
	if instance:IsA("BasePart") then
		n = 1
	end
	local ok, descendants = pcall(function()
		return instance:GetDescendants()
	end)
	if ok and type(descendants) == "table" then
		for _, d in ipairs(descendants) do
			if d:IsA("BasePart") then
				n = n + 1
			end
		end
	end
	return n
end

-- nombre de Zbires vivants dans la Horde
local function compterZbires(horde)
	if not horde then return 0 end
	local n = 0
	for _, enfant in ipairs(horde:GetChildren()) do
		if enfant:IsA("Model") then
			n = n + 1
		end
	end
	return n
end

-- temps d'un battement serveur en millisecondes (nil si indisponible)
local function lireHeartbeat()
	local ok, valeur = pcall(function()
		local Stats = game:GetService("Stats")
		return Stats.HeartbeatTimeMs
	end)
	if ok and type(valeur) == "number" then
		return valeur
	end
	return nil
end

function M.demarrer(ctx)
	local racine = ctx.racine
	if not racine then return end
	local R = reglages(ctx.Equilibrage)

	-- ===== bilan de démarrage : parts par dossier =====
	local total = 0
	local lignes = {}
	for _, enfant in ipairs(racine:GetChildren()) do
		local n = compterParts(enfant)
		total = total + n
		table.insert(lignes, { nom = enfant.Name, n = n })
	end
	table.sort(lignes, function(a, b) return a.n > b.n end)
	print(string.format("[Zsurvie] Performance : %d parts dans %s", total, racine.Name))
	for _, ligne in ipairs(lignes) do
		print(string.format("[Zsurvie]   %-16s %6d parts", ligne.nom, ligne.n))
	end

	-- ===== plafond de Zbires =====
	local plafond = R.maxZbires
	racine:SetAttribute("MaxZbires", plafond)

	local function ajusterPlafond()
		local hb = lireHeartbeat()
		local voulu = R.maxZbires
		if hb and hb > R.seuilHeartbeatMs then
			voulu = R.maxZbiresReduit
		end
		if voulu ~= plafond then
			plafond = voulu
			racine:SetAttribute("MaxZbires", plafond)
			print(string.format("[Zsurvie] Performance : plafond de Zbires à %d (battement %.1f ms)", plafond, hb or 0))
		end
	end

	-- ===== nettoyage des pièces oubliées =====
	local function nettoyerPieces()
		local dossier = racine:FindFirstChild("Pieces")
		if not dossier then return 0 end
		local maintenant = os.clock()
		local detruites = 0
		for _, piece in ipairs(dossier:GetChildren()) do
			if piece:IsA("BasePart") or piece:IsA("Model") then
				local ne = piece:GetAttribute("Ne")
				if type(ne) ~= "number" then
					piece:SetAttribute("Ne", maintenant)
				elseif maintenant - ne > R.dureeViePiece then
					local ok = pcall(function()
						piece:Destroy()
					end)
					if ok then
						detruites = detruites + 1
					end
				end
			end
		end
		return detruites
	end

	-- ===== boucle de surveillance =====
	local enAlerte = false
	while racine.Parent do
		task.wait(R.intervalle)
		if not racine.Parent then break end

		local zbires = compterZbires(ctx.horde or racine:FindFirstChild("Horde"))
		local parts = compterParts(racine)
		racine:SetAttribute("NbZbires", zbires)
		racine:SetAttribute("NbParts", parts)

		ajusterPlafond()
		nettoyerPieces()

		if parts > R.alertePartsMax then
			if not enAlerte then
				enAlerte = true
				warn(string.format("[Zsurvie] Performance : %d parts dans la map (seuil %d), %d Zbires", parts, R.alertePartsMax, zbires))
			end
		else
			enAlerte = false
		end
	end
end

return M
