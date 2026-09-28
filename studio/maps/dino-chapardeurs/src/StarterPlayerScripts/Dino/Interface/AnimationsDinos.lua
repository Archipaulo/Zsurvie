-- Interface/AnimationsDinos : anime localement les dinos voxel assemblés (attribut « Assemble »),
-- et fait vivre les dinos posés dans les Bases (rebond, balancement, lumières selon la rareté)
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

	-- ===== dans la Base : petit rebond, balancement et lumières selon la rareté =====
	-- (local : le serveur ne bouge pas les dinos posés, on repart toujours de leur pose au moment où ils sont posés)
	local RARETES = {
		Commun = { rebond = 0.25, vitesse = 2.0, balance = 3 },
		Rare = { rebond = 0.3, vitesse = 2.2, balance = 4, lumiere = Color3.fromRGB(80, 160, 255), portee = 8, eclat = 0.8 },
		Epique = { rebond = 0.35, vitesse = 2.4, balance = 4.5, lumiere = Color3.fromRGB(170, 90, 255), portee = 10, eclat = 1, etincelles = Color3.fromRGB(200, 140, 255) },
		Legendaire = { rebond = 0.4, vitesse = 2.6, balance = 5, lumiere = Color3.fromRGB(255, 190, 50), portee = 12, eclat = 1.3, etincelles = Color3.fromRGB(255, 220, 90), pulse = 1.5 },
		Mythique = { rebond = 0.45, vitesse = 2.8, balance = 5.5, lumiere = Color3.fromRGB(255, 70, 140), portee = 14, eclat = 1.6, etincelles = Color3.fromRGB(255, 120, 190), pulse = 2, anneau = true },
		Divin = { rebond = 0.5, vitesse = 3.0, balance = 6, lumiere = Color3.fromRGB(255, 255, 255), portee = 16, eclat = 2, etincelles = Color3.fromRGB(255, 240, 160), pulse = 2.5, anneau = true, arcEnCiel = true },
		Secret = { rebond = 0.55, vitesse = 3.2, balance = 6.5, lumiere = Color3.fromRGB(150, 90, 255), portee = 18, eclat = 2.2, etincelles = Color3.fromRGB(120, 255, 240), pulse = 3, anneau = true, arcEnCiel = true },
	}
	local exposes = {} -- dino -> { base = CFrame, profil, lumiere, effets = {}, phase }

	local function retirerEffets(fiche)
		for _, e in ipairs(fiche.effets) do pcall(function() e:Destroy() end) end
		fiche.effets = {}
		fiche.lumiere = nil
	end

	local function arreterExposition(dino)
		local fiche = exposes[dino]
		if not fiche then return end
		exposes[dino] = nil
		retirerEffets(fiche)
		-- pas de remise en place locale : le serveur repositionne lui-même le dino (vol, déplacement)
	end

	local function exposer(dino)
		if exposes[dino] or not dino.PrimaryPart then return end
		local profil = RARETES[dino:GetAttribute("Rarete")] or RARETES.Commun
		compteur = compteur + 1
		local fiche = { base = dino.PrimaryPart.CFrame, profil = profil, effets = {}, phase = (compteur * 2.3) % (2 * math.pi) }
		local corps = dino.PrimaryPart
		if profil.lumiere then
			local l = Instance.new("PointLight")
			l.Name = "LumiereRarete"
			l.Color = profil.lumiere
			l.Range = profil.portee
			l.Brightness = profil.eclat
			l.Shadows = false
			l.Parent = corps
			fiche.lumiere = l
			table.insert(fiche.effets, l)
		end
		if profil.etincelles then
			local a = Instance.new("Attachment")
			a.Name = "AuraRarete"
			a.Parent = corps
			local p = Instance.new("ParticleEmitter")
			p.Color = ColorSequence.new(profil.etincelles)
			p.LightEmission = 1
			p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
			p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
			p.Lifetime = NumberRange.new(1, 1.8)
			p.Speed = NumberRange.new(1, 2.5)
			p.SpreadAngle = Vector2.new(180, 180)
			p.Rate = 4 + 3 * (profil.pulse or 0)
			p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			p.Parent = a
			table.insert(fiche.effets, a)
		end
		if profil.anneau then
			-- anneau lumineux posé au sol sous le dino
			local ok, cf, taille = pcall(function() return dino:GetBoundingBox() end)
			if ok then
				local anneau = Instance.new("Part")
				anneau.Name = "AnneauRarete"
				anneau.Shape = Enum.PartType.Cylinder
				anneau.Anchored = true
				anneau.CanCollide = false
				anneau.CanQuery = false
				anneau.CanTouch = false
				anneau.CastShadow = false
				anneau.Material = Enum.Material.Neon
				anneau.Color = profil.lumiere
				anneau.Transparency = 0.55
				local d = math.min(math.max(taille.X, taille.Z) * 0.8, 7)
				anneau.Size = Vector3.new(0.12, d, d)
				anneau.CFrame = CFrame.new(cf.Position.X, cf.Position.Y - taille.Y / 2 + 0.08, cf.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
				anneau.Parent = workspace.CurrentCamera
				fiche.anneau = anneau
				table.insert(fiche.effets, anneau)
			end
		end
		exposes[dino] = fiche
	end

	local function suivreEtat(dino)
		if not dino:IsA("Model") then return end
		local function maj()
			arreterExposition(dino)
			if dino:GetAttribute("Etat") == "Enclos" then
				-- laisse le serveur finir de poser le dino avant de mémoriser sa pose
				task.delay(0.3, function()
					if dino.Parent and dino:GetAttribute("Etat") == "Enclos" then exposer(dino) end
				end)
			end
		end
		dino:GetAttributeChangedSignal("Etat"):Connect(maj)
		dino:GetAttributeChangedSignal("Emplacement"):Connect(maj)
		maj()
	end

	for _, d in ipairs(dinos:GetChildren()) do suivreEtat(d) end
	dinos.ChildAdded:Connect(suivreEtat)
	dinos.ChildRemoved:Connect(arreterExposition)

	RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		local oeil = camera and camera.CFrame.Position
		local t = os.clock()
		for dino, fiche in pairs(exposes) do
			local corps = dino.PrimaryPart
			if not dino.Parent or not corps then
				exposes[dino] = nil
				retirerEffets(fiche)
			elseif not oeil or (fiche.base.Position - oeil).Magnitude < DISTANCE_MAX then
				local p = fiche.profil
				local u = t * p.vitesse + fiche.phase
				local haut = math.abs(math.sin(u)) * p.rebond
				local roulis = math.sin(u * 0.5) * math.rad(p.balance)
				corps.CFrame = fiche.base * CFrame.new(0, haut, 0) * CFrame.Angles(0, 0, roulis)
				if fiche.lumiere and p.pulse then
					fiche.lumiere.Brightness = p.eclat * (0.75 + 0.35 * math.sin(t * p.pulse + fiche.phase))
				end
				if p.arcEnCiel and fiche.lumiere then
					local c = Color3.fromHSV((t * 0.15 + fiche.phase) % 1, 0.6, 1)
					fiche.lumiere.Color = c
					if fiche.anneau then fiche.anneau.Color = c end
				end
			end
		end
	end)

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
