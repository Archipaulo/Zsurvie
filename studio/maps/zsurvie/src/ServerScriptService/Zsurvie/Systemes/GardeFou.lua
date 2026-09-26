-- Système GardeFou : filets de sécurité passifs, vérifiés toutes les 2 secondes.
-- Zbires perdus, joueurs tombés dans le vide, PV de la Maison invalides, chrono figé.
-- N'écrit que PVMaison (en cas de valeur invalide) et ne signale rien par warn.
local Players = game:GetService("Players")

local M = {}

local PERIODE = 2          -- secondes entre deux vérifications
local Y_CHUTE = -40        -- sous cette hauteur, le joueur est replacé
local DELAI_CHRONO = 10    -- secondes sans changement de TempsRestant avant diagnostic

-- vrai si le nombre est NaN ou infini
local function invalide(n)
	if type(n) ~= "number" then
		return true
	end
	if n ~= n then
		return true
	end
	if n == math.huge or n == -math.huge then
		return true
	end
	return false
end

local function vecteurInvalide(v)
	return invalide(v.X) or invalide(v.Y) or invalide(v.Z)
end

function M.demarrer(ctx)
	local Plan = ctx.Plan
	local Etat = ctx.Etat
	local horde = ctx.horde
	local Equilibrage = ctx.Equilibrage

	local centre = Plan.prairie.centre
	local bordMonde = Plan.prairie.bordMonde
	local hausse = Vector3.new(0, 4, 0)

	-- ===== Zbires égarés =====
	local function verifierZbires()
		if not horde or not horde.Parent then
			return
		end
		local aDetruire = {}
		for _, modele in ipairs(horde:GetChildren()) do
			if modele:IsA("Model") then
				local corps = modele.PrimaryPart
				if not corps then
					table.insert(aDetruire, modele)
				else
					local p = corps.Position
					if vecteurInvalide(p) then
						table.insert(aDetruire, modele)
					else
						local dx = p.X - centre.X
						local dz = p.Z - centre.Z
						if math.sqrt(dx * dx + dz * dz) > bordMonde then
							table.insert(aDetruire, modele)
						end
					end
				end
			end
		end
		for _, modele in ipairs(aDetruire) do
			pcall(function()
				modele:Destroy()
			end)
		end
		if #aDetruire > 0 then
			print("[GardeFou] " .. #aDetruire .. " Zbire(s) hors du monde retiré(s)")
		end
	end

	-- ===== joueurs tombés =====
	local function replacer(joueur, racineHumanoide)
		local cible
		if joueur:GetAttribute("EnRun") == true then
			cible = Plan.parvis.centre + hausse
		else
			cible = Plan.lobby.spawn + hausse
		end
		local personnage = joueur.Character
		if personnage then
			pcall(function()
				racineHumanoide.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end)
			local ok = pcall(function()
				personnage:PivotTo(CFrame.new(cible))
			end)
			if not ok then
				pcall(function()
					racineHumanoide.CFrame = CFrame.new(cible)
				end)
			end
			print("[GardeFou] " .. joueur.Name .. " replacé après une chute")
		end
	end

	local function verifierJoueurs()
		for _, joueur in ipairs(Players:GetPlayers()) do
			local personnage = joueur.Character
			if personnage then
				local racineHumanoide = personnage:FindFirstChild("HumanoidRootPart")
				if racineHumanoide and racineHumanoide:IsA("BasePart") then
					local y = racineHumanoide.Position.Y
					if invalide(y) or y < Y_CHUTE then
						replacer(joueur, racineHumanoide)
					end
				end
			end
		end
	end

	-- ===== PV de la Maison =====
	local function verifierMaison()
		local pv = Etat:GetAttribute("PVMaison")
		if type(pv) == "number" and not invalide(pv) and pv >= 0 then
			return
		end
		local max = Etat:GetAttribute("PVMaisonMax")
		if invalide(max) or max <= 0 then
			max = Equilibrage.maison.pv
		end
		Etat:SetAttribute("PVMaison", max)
		print("[GardeFou] PVMaison invalide (" .. tostring(pv) .. "), remis à " .. tostring(max))
	end

	-- ===== chrono figé en Horde =====
	local dernierTemps = Etat:GetAttribute("TempsRestant")
	local dernierChangement = os.clock()
	local dejaSignale = false

	local function verifierChrono()
		local phase = Etat:GetAttribute("Phase")
		local temps = Etat:GetAttribute("TempsRestant")
		local maintenant = os.clock()
		if phase ~= "Horde" or temps ~= dernierTemps then
			dernierTemps = temps
			dernierChangement = maintenant
			dejaSignale = false
			return
		end
		if not dejaSignale and maintenant - dernierChangement >= DELAI_CHRONO then
			dejaSignale = true
			print(string.format(
				"[GardeFou] diagnostic : TempsRestant bloqué à %s depuis %d s (Phase = Horde, Jour = %s, ZbiresRestants = %s, PVMaison = %s)",
				tostring(temps),
				math.floor(maintenant - dernierChangement),
				tostring(Etat:GetAttribute("Jour")),
				tostring(Etat:GetAttribute("ZbiresRestants")),
				tostring(Etat:GetAttribute("PVMaison"))
			))
		end
	end

	-- ===== boucle principale =====
	local verifications = { verifierZbires, verifierJoueurs, verifierMaison, verifierChrono }
	task.spawn(function()
		while true do
			task.wait(PERIODE)
			for _, verifier in ipairs(verifications) do
				local ok, err = pcall(verifier)
				if not ok then
					print("[GardeFou] vérification interrompue : " .. tostring(err))
				end
			end
		end
	end)
end

return M
