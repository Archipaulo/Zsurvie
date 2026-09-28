-- Interface/AnimationsDinos : anime localement les dinos voxel assemblés (attribut « Assemble »)
-- en jouant sur Motor6D.Transform : pattes qui marchent, queue qui se balance, ailes qui battent.
-- Rien n'est répliqué : le serveur ne déplace que la PrimaryPart de chaque dino.
local RunService = game:GetService("RunService")

local M = {}

local DISTANCE_MAX = 150
local ETATS_MARCHE = { Tapis = true, EnRoute = true }
local PHASES = { PatteAvG = 0, PatteArD = 0, PatteAvD = math.pi, PatteArG = math.pi }

function M.demarrer(ctx)
	local dinos = ctx.dinos
	if not dinos then return end

	-- dino -> { moteurs = { {moteur, genre, phase, cote} }, decalage }
	local suivis = {}
	local compteur = 0

	local function inscrire(dino)
		if suivis[dino] or not dino:IsA("Model") or dino:GetAttribute("Assemble") ~= true then return end
		local moteurs = {}
		for _, o in ipairs(dino:GetDescendants()) do
			if o:IsA("Motor6D") then
				local nom = o.Name
				local genre
				if string.sub(nom, 1, 5) == "Patte" then genre = "patte"
				elseif string.sub(nom, 1, 5) == "Queue" then genre = "queue"
				elseif string.sub(nom, 1, 4) == "Aile" then genre = "aile" end
				if genre then
					local cote = 1
					if string.sub(nom, -1) == "D" then cote = -1 end
					table.insert(moteurs, { moteur = o, genre = genre, phase = PHASES[nom] or 0, cote = cote })
				end
			end
		end
		if #moteurs > 0 then
			compteur = compteur + 1
			suivis[dino] = { moteurs = moteurs, decalage = (compteur * 1.7) % (2 * math.pi) }
		end
	end

	local function retirer(dino)
		suivis[dino] = nil
	end

	for _, d in ipairs(dinos:GetChildren()) do inscrire(d) end
	dinos.ChildAdded:Connect(function(d)
		-- les parts et les articulations arrivent juste après le modèle
		task.delay(0.2, function() inscrire(d) end)
	end)
	dinos.ChildRemoved:Connect(retirer)

	local cumul = 0
	RunService.RenderStepped:Connect(function(dt)
		cumul = cumul + dt
		if cumul < 1 / 40 then return end
		cumul = 0
		local camera = workspace.CurrentCamera
		local oeil = camera and camera.CFrame.Position
		local t = os.clock()
		for dino, fiche in pairs(suivis) do
			if not dino.Parent then
				suivis[dino] = nil
			else
				local proche = true
				if oeil and dino.PrimaryPart then
					proche = (dino.PrimaryPart.Position - oeil).Magnitude < DISTANCE_MAX
				end
				if proche then
					local marche = ETATS_MARCHE[dino:GetAttribute("Etat")] == true
					local porte = dino:GetAttribute("Etat") == "Porte"
					local u = t + fiche.decalage
					for _, m in ipairs(fiche.moteurs) do
						local cf
						if m.genre == "patte" then
							if marche then
								cf = CFrame.Angles(math.sin(u * 8 + m.phase) * 0.5, 0, 0)
							elseif porte then
								cf = CFrame.Angles(math.sin(u * 14 + m.phase) * 0.7, 0, 0) -- il gigote sur la tête du voleur
							else
								cf = CFrame.new()
							end
						elseif m.genre == "queue" then
							local amplitude = 0.12
							if marche then amplitude = 0.28 end
							cf = CFrame.Angles(0, math.sin(u * (marche and 5 or 1.6)) * amplitude, 0)
						else
							local vitesse = 2
							if marche or porte then vitesse = 9 end
							cf = CFrame.Angles(0, 0, math.sin(u * vitesse) * 0.5 * m.cote)
						end
						m.moteur.Transform = cf
					end
				end
			end
		end
	end)
end

return M
