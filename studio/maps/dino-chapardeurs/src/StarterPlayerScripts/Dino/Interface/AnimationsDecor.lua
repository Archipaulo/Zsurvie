-- Interface/AnimationsDecor : anime localement le décor portant l'attribut « Anime ».
-- "tourne" : rotation autour de Y ; "flotte" : va-et-vient vertical ; "pulse" : pulsation de transparence.
-- Les animations sont purement visuelles (client) et ne concernent jamais les Zbires des Dinos.
local RunService = game:GetService("RunService")

local M = {}

local DISTANCE_MAX = 180 -- au-delà, l'objet n'est pas mis à jour
local AMPLITUDE_FLOTTE = 0.5 -- studs de part et d'autre de la position d'origine
local TRANSPARENCE_PULSE = 0.4 -- transparence ajoutée au plus fort de la pulsation
local INTERVALLE_RESCAN = 10 -- secondes entre deux balayages de secours
local GENRES = { tourne = true, flotte = true, pulse = true }

function M.demarrer(ctx)
	local racine = ctx.racine
	local horde = ctx.horde
	if not racine then
		return
	end

	-- inst -> fiche { genre, origine (CFrame ou nil), parts (pulse), phase }
	local fiches = {}

	local function dansHorde(inst)
		if not horde then
			return false
		end
		if inst == horde then
			return true
		end
		local ok, res = pcall(function()
			return inst:IsDescendantOf(horde)
		end)
		return ok and res
	end

	local function lireOrigine(inst)
		if inst:IsA("BasePart") then
			return inst.CFrame
		end
		if inst:IsA("Model") then
			local ok, cf = pcall(function()
				return inst:GetPivot()
			end)
			if ok then
				return cf
			end
		end
		return nil
	end

	local function ajouterPartPulse(fiche, part)
		if fiche.parts[part] == nil then
			fiche.parts[part] = part.Transparency
		end
	end

	-- restaure l'état d'origine d'un objet que l'on cesse d'animer
	local function restaurer(inst, fiche)
		pcall(function()
			if fiche.genre == "pulse" then
				for part, base in pairs(fiche.parts) do
					if part.Parent then
						part.Transparency = base
					end
				end
			elseif fiche.origine then
				if inst:IsA("BasePart") then
					inst.CFrame = fiche.origine
				elseif inst:IsA("Model") then
					inst:PivotTo(fiche.origine)
				end
			end
		end)
	end

	local function oublier(inst)
		local fiche = fiches[inst]
		if fiche then
			fiches[inst] = nil
			if inst.Parent then
				restaurer(inst, fiche)
			end
		end
	end

	local function enregistrer(inst)
		if fiches[inst] then
			return
		end
		if not (inst:IsA("BasePart") or inst:IsA("Model")) then
			return
		end
		local genre = inst:GetAttribute("Anime")
		if type(genre) ~= "string" or not GENRES[genre] then
			return
		end
		if dansHorde(inst) then
			return
		end
		local fiche = {
			genre = genre,
			origine = lireOrigine(inst),
			parts = {},
			phase = math.random() * math.pi * 2,
		}
		if genre == "pulse" then
			if inst:IsA("BasePart") then
				ajouterPartPulse(fiche, inst)
			else
				for _, d in ipairs(inst:GetDescendants()) do
					if d:IsA("BasePart") then
						ajouterPartPulse(fiche, d)
					end
				end
			end
		end
		fiches[inst] = fiche
	end

	-- une part ajoutée dans un modèle qui pulse rejoint la pulsation
	local function rattacherPulse(part)
		local parent = part.Parent
		while parent and parent ~= racine do
			local fiche = fiches[parent]
			if fiche and fiche.genre == "pulse" and parent:IsA("Model") then
				ajouterPartPulse(fiche, part)
				return
			end
			parent = parent.Parent
		end
	end

	local function balayer()
		for _, d in ipairs(racine:GetDescendants()) do
			if d:GetAttribute("Anime") ~= nil then
				enregistrer(d)
			end
		end
	end

	balayer()

	racine.DescendantAdded:Connect(function(d)
		if d:GetAttribute("Anime") ~= nil then
			enregistrer(d)
		end
		if d:IsA("BasePart") then
			rattacherPulse(d)
		end
	end)

	racine.DescendantRemoving:Connect(function(d)
		if fiches[d] then
			fiches[d] = nil
		end
	end)

	-- balayage de secours : attributs posés après coup, objets détruits
	task.spawn(function()
		while racine.Parent do
			task.wait(INTERVALLE_RESCAN)
			for inst, _ in pairs(fiches) do
				if not inst.Parent or not inst:IsDescendantOf(racine) then
					fiches[inst] = nil
				end
			end
			pcall(balayer)
		end
	end)

	local function positionDe(inst, fiche)
		if fiche.origine then
			return fiche.origine.Position
		end
		if inst:IsA("BasePart") then
			return inst.Position
		end
		return nil
	end

	local function animer(inst, fiche, t, camPos)
		-- l'attribut a pu être retiré ou changé par le serveur
		local genre = inst:GetAttribute("Anime")
		if genre ~= fiche.genre then
			-- le balayage de secours le reprendra avec son nouveau genre
			oublier(inst)
			return
		end
		if fiche.origine == nil and fiche.genre ~= "pulse" then
			fiche.origine = lireOrigine(inst)
			if fiche.origine == nil then
				return
			end
		end
		local pos = positionDe(inst, fiche)
		if pos == nil or (pos - camPos).Magnitude > DISTANCE_MAX then
			return
		end
		local vitesse = inst:GetAttribute("AnimeVitesse")
		if type(vitesse) ~= "number" then
			vitesse = 1
		end
		if fiche.genre == "tourne" then
			local cf = fiche.origine * CFrame.Angles(0, (t * vitesse) % (math.pi * 2), 0)
			if inst:IsA("BasePart") then
				inst.CFrame = cf
			else
				inst:PivotTo(cf)
			end
		elseif fiche.genre == "flotte" then
			local dy = math.sin(t * vitesse + fiche.phase) * AMPLITUDE_FLOTTE
			local cf = fiche.origine + Vector3.new(0, dy, 0)
			if inst:IsA("BasePart") then
				inst.CFrame = cf
			else
				inst:PivotTo(cf)
			end
		else
			local k = (0.5 - 0.5 * math.cos(t * vitesse + fiche.phase)) * TRANSPARENCE_PULSE
			for part, base in pairs(fiche.parts) do
				if part.Parent then
					if base < 1 then
						part.Transparency = math.min(1, base + k)
					end
				else
					fiche.parts[part] = nil
				end
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local camPos = camera.CFrame.Position
		local t = os.clock()
		local aOublier = {}
		for inst, fiche in pairs(fiches) do
			if inst.Parent == nil then
				table.insert(aOublier, inst)
			else
				local ok = pcall(animer, inst, fiche, t, camPos)
				if not ok then
					table.insert(aOublier, inst)
				end
			end
		end
		for _, inst in ipairs(aOublier) do
			fiches[inst] = nil
		end
	end)
end

return M
