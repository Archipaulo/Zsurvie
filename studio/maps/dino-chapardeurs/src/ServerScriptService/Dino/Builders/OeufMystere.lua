-- Constructeur OeufMystere : le gabarit voxel de l'Œuf mystère ailé (ctx.stockage.Dinos.OeufMystere).
-- Un gros œuf crème à taches arc-en-ciel et points d'interrogation, deux grandes ailes de plumes blanches
-- et dorées (groupes AileG / AileD : elles battent grâce à Interface/AnimationsDinos), un petit halo doré.
-- Pivot au sol sous l'œuf, regard vers -Z (CONTRAT §4).
local M = {}

function M.construire(ctx)
	local Voxel = ctx.Voxel
	local Charte = ctx.Charte
	local stockage = ctx.stockage and ctx.stockage:FindFirstChild("Dinos")
	if not (Voxel and Charte and stockage) then return end
	local hex = Charte.hex

	local CREME = hex("FFF4DC")
	local CREME_OMBRE = hex("EAD7B0")
	local CREME_LUMIERE = hex("FFFDF5")
	local TACHES = { hex("FF4D6D"), hex("FFB020"), hex("5CFF5C"), hex("3DD6F5"), hex("A35DFF") }
	local PLUME = hex("FFFFFF")
	local PLUME_OMBRE = hex("DDE6F0")
	local OR = { couleur = hex("FFC933"), materiau = Enum.Material.Neon }
	local NOIR = hex("1B1A2E")

	local V = Voxel.nouveau()
	-- l'œuf : plus large en bas, pointe en haut (hauteur 11)
	local RX, RY = 4.5, 6.5
	V:ellipsoide(0, RY, 0, RX, RY, RX, CREME, "Corps")
	V:peindre(function(x, y, z)
		-- volume : haut plus clair, bas plus foncé
		if y >= 10 then return CREME_LUMIERE end
		if y <= 2 then return CREME_OMBRE end
		return nil
	end, "Corps")
	-- taches arc-en-ciel (graine fixe) : quelques cubes de la coquille repeints
	local alea = Random.new(7)
	V:peindre(function(x, y, z)
		if y >= 1 and y <= 12 and alea:NextNumber() < 0.07 then
			return TACHES[alea:NextInteger(1, #TACHES)]
		end
		return nil
	end, "Corps")

	-- ailes : plumes en éventail, côté droit (x > 0) puis symétrie
	for k = 0, 4 do
		local y = 10 - k
		local longueur = 6 - math.abs(k - 1)
		V:boite(5, y, -1, 4 + longueur, y, 1, (k % 2 == 0) and PLUME or PLUME_OMBRE, "AileD")
	end
	V:boite(5, 10, 0, 10, 10, 0, OR, "AileD") -- liseré doré
	V:symetriser()

	-- un « ? » violet posé sur la coquille, face avant (-Z) : chaque cube est collé à la surface
	local VIOLET = hex("7A3FD1")
	local POINT_Q = { { -1, 11 }, { 0, 12 }, { 1, 12 }, { 2, 11 }, { 2, 10 }, { 1, 9 }, { 0, 8 }, { 0, 7 }, { 0, 5 } }
	for _, p in ipairs(POINT_Q) do
		local x, y = p[1], p[2]
		local u = 1 - ((y - RY) / RY) ^ 2 - (x / RX) ^ 2
		if u > 0 then
			local z = -math.floor(RX * math.sqrt(u) + 0.5)
			V:mettre(x, y, z, VIOLET, "Corps")
		end
	end


	-- petit halo doré au-dessus
	for a = 0, 11 do
		local ang = a / 12 * math.pi * 2
		V:mettre(math.cos(ang) * 2.5, 15, math.sin(ang) * 2.5, OR, "Corps")
	end

	local ok, modele = pcall(function()
		return V:construire(stockage, { nom = "OeufMystere", origine = CFrame.new(), budget = 220 })
	end)
	if ok and modele then
		modele:SetAttribute("Espece", "OeufMystere")
		modele:SetAttribute("Rarete", "Mythique")
		modele:SetAttribute("Famille", "Oeuf")
		local corps = modele.PrimaryPart
		if corps then
			local lumiere = Instance.new("PointLight")
			lumiere.Name = "Halo"
			lumiere.Color = hex("FFE08A")
			lumiere.Range = 10
			lumiere.Brightness = 1.2
			lumiere.Parent = corps
		end
	else
		warn("[Dino] OeufMystere : " .. tostring(modele))
	end
end

return M
