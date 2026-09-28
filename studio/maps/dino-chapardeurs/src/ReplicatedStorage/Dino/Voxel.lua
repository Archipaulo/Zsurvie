-- Voxel : modélisation en petits cubes, style « voxel » des grands simulateurs Roblox.
-- On remplit une grille (1 case = 1 stud par défaut) avec des formes simples, puis construire()
-- fusionne les cubes voisins de même couleur en quelques parts (maillage glouton) dont les faces
-- portent la texture Roblox « Studs » : chaque case de 1 stud reste visible comme un petit cube.
--
-- Repère : x = gauche/droite, y = haut (y = 0 : première couche, posée sur le sol), z = longueur ;
-- l'avant du modèle est vers -Z. Chaque voxel appartient à un « groupe » qui devient le nom des parts
-- (« Corps », « Tete », « PatteAvG », « Queue »…), ce qui permet d'animer les membres.
--
-- local V = Voxel.nouveau()
-- V:ellipsoide(0, 5, 0, 3, 3, 4, couleur, "Corps")
-- V:boite(-1, 0, -2, 0, 3, -1, couleur, "PatteAvG")
-- local modele = V:construire(parent, { nom = "Rex", origine = CFrame.new(0, 0, 0) })
local Voxel = {}
Voxel.__index = Voxel

local function cle(x, y, z)
	return x .. "," .. y .. "," .. z
end

function Voxel.nouveau()
	return setmetatable({ grille = {}, nombre = 0 }, Voxel)
end

-- couleur : Color3, ou table { couleur = Color3, materiau = Enum.Material } (ex. yeux en Neon)
local function normaliser(couleur)
	if couleur == nil then return nil end
	if typeof(couleur) == "Color3" then return { couleur = couleur, materiau = nil } end
	return { couleur = couleur.couleur or couleur[1], materiau = couleur.materiau or couleur[2] }
end

function Voxel:mettre(x, y, z, couleur, groupe)
	x, y, z = math.floor(x + 0.5), math.floor(y + 0.5), math.floor(z + 0.5)
	local k = cle(x, y, z)
	local ancien = self.grille[k]
	if couleur == nil then
		if ancien then
			self.grille[k] = nil
			self.nombre = self.nombre - 1
		end
		return
	end
	if not ancien then self.nombre = self.nombre + 1 end
	self.grille[k] = { x = x, y = y, z = z, c = normaliser(couleur), g = groupe or (ancien and ancien.g) or "Corps" }
end

function Voxel:lire(x, y, z)
	return self.grille[cle(math.floor(x + 0.5), math.floor(y + 0.5), math.floor(z + 0.5))]
end

-- pavé plein entre deux coins inclus
function Voxel:boite(x1, y1, z1, x2, y2, z2, couleur, groupe)
	for x = math.min(x1, x2), math.max(x1, x2) do
		for y = math.min(y1, y2), math.max(y1, y2) do
			for z = math.min(z1, z2), math.max(z1, z2) do
				self:mettre(x, y, z, couleur, groupe)
			end
		end
	end
end

-- ellipsoïde plein de centre (cx, cy, cz) et de rayons (rx, ry, rz)
function Voxel:ellipsoide(cx, cy, cz, rx, ry, rz, couleur, groupe)
	for x = math.floor(cx - rx), math.ceil(cx + rx) do
		for y = math.floor(cy - ry), math.ceil(cy + ry) do
			for z = math.floor(cz - rz), math.ceil(cz + rz) do
				local dx, dy, dz = (x - cx) / rx, (y - cy) / ry, (z - cz) / rz
				if dx * dx + dy * dy + dz * dz <= 1.05 then
					self:mettre(x, y, z, couleur, groupe)
				end
			end
		end
	end
end

-- tube plein de rayon r entre deux points (cou, queue, pattes…) ; r2 : rayon au bout (effilé)
function Voxel:tube(ax, ay, az, bx, by, bz, r, couleur, groupe, r2)
	r2 = r2 or r
	local lx, ly, lz = bx - ax, by - ay, bz - az
	local l2 = lx * lx + ly * ly + lz * lz
	local rmax = math.max(r, r2)
	for x = math.floor(math.min(ax, bx) - rmax), math.ceil(math.max(ax, bx) + rmax) do
		for y = math.floor(math.min(ay, by) - rmax), math.ceil(math.max(ay, by) + rmax) do
			for z = math.floor(math.min(az, bz) - rmax), math.ceil(math.max(az, bz) + rmax) do
				local t = 0
				if l2 > 0 then
					t = math.max(0, math.min(1, ((x - ax) * lx + (y - ay) * ly + (z - az) * lz) / l2))
				end
				local px, py, pz = ax + lx * t - x, ay + ly * t - y, az + lz * t - z
				local rt = r + (r2 - r) * t
				if px * px + py * py + pz * pz <= rt * rt + 0.25 then
					self:mettre(x, y, z, couleur, groupe)
				end
			end
		end
	end
end

-- repeint les voxels existants : fn(x, y, z, voxel) renvoie une nouvelle couleur (ou nil pour ne rien changer)
function Voxel:peindre(fn, groupe)
	for _, v in pairs(self.grille) do
		if not groupe or v.g == groupe then
			local c = fn(v.x, v.y, v.z, v)
			if c then v.c = normaliser(c) end
		end
	end
end

-- symétrie gauche/droite : recopie en -x tout ce qui est en x > 0 (« G » <-> « D » dans les groupes)
function Voxel:symetriser()
	local copies = {}
	for _, v in pairs(self.grille) do
		if v.x > 0 then table.insert(copies, v) end
	end
	for _, v in ipairs(copies) do
		local g = v.g
		local fin = string.sub(g, -1)
		if fin == "G" then g = string.sub(g, 1, -2) .. "D" elseif fin == "D" then g = string.sub(g, 1, -2) .. "G" end
		self:mettre(-v.x, v.y, v.z, { couleur = v.c.couleur, materiau = v.c.materiau }, g)
	end
end

function Voxel:taille()
	local mn, mx
	for _, v in pairs(self.grille) do
		if not mn then
			mn = { v.x, v.y, v.z }
			mx = { v.x, v.y, v.z }
		else
			mn = { math.min(mn[1], v.x), math.min(mn[2], v.y), math.min(mn[3], v.z) }
			mx = { math.max(mx[1], v.x), math.max(mx[2], v.y), math.max(mx[3], v.z) }
		end
	end
	return mn, mx
end

local function memeCouleur(a, b)
	return a.couleur == b.couleur and a.materiau == b.materiau
end

-- construit le modèle : parts fusionnées par groupe et par couleur, faces « Studs ».
-- props : nom, origine (CFrame du point (0, 0, 0) au sol, défaut CFrame.new()), taille (studs par voxel, défaut 1),
--         surface (Enum.SurfaceType, défaut Studs), primaire (groupe de la PrimaryPart, défaut « Corps »), budget (parts max)
function Voxel:construire(parent, props)
	props = props or {}
	local t = props.taille or 1
	local origine = props.origine or CFrame.new()
	local surface = props.surface or Enum.SurfaceType.Studs
	local modele = Instance.new("Model")
	modele.Name = props.nom or "Voxel"
	local grille = self.grille

	-- un voxel entièrement entouré est invisible : il peut prendre n'importe quelle couleur (fusion plus large)
	local function interieur(v)
		return grille[cle(v.x + 1, v.y, v.z)] and grille[cle(v.x - 1, v.y, v.z)]
			and grille[cle(v.x, v.y + 1, v.z)] and grille[cle(v.x, v.y - 1, v.z)]
			and grille[cle(v.x, v.y, v.z + 1)] and grille[cle(v.x, v.y, v.z - 1)]
	end
	local cache = {}
	local function cache_interieur(v)
		local r = cache[v]
		if r == nil then
			r = interieur(v) and true or false
			cache[v] = r
		end
		return r
	end

	local parGroupe = {}
	for _, v in pairs(grille) do
		parGroupe[v.g] = parGroupe[v.g] or {}
		table.insert(parGroupe[v.g], v)
	end
	local nomsGroupes = {}
	for g in pairs(parGroupe) do table.insert(nomsGroupes, g) end
	table.sort(nomsGroupes)

	local nbParts = 0
	local plusGrande = nil
	local primaire = props.primaire or "Corps"
	for _, g in ipairs(nomsGroupes) do
		local liste = parGroupe[g]
		-- les voxels visibles servent de graines en premier ; les intérieurs se laissent absorber
		table.sort(liste, function(a, b)
			local ia, ib = cache_interieur(a), cache_interieur(b)
			if ia ~= ib then return ib end
			if a.z ~= b.z then return a.z < b.z end
			if a.y ~= b.y then return a.y < b.y end
			return a.x < b.x
		end)
		local pris = {}
		local function libre(x, y, z, c)
			local v = grille[cle(x, y, z)]
			if not v or v.g ~= g or pris[v] then return false end
			return memeCouleur(v.c, c) or cache_interieur(v)
		end
		for _, graine in ipairs(liste) do
			if not pris[graine] then
				local c = graine.c
				local x0, y0, z0 = graine.x, graine.y, graine.z
				local x1 = x0
				while libre(x1 + 1, y0, z0, c) do x1 = x1 + 1 end
				local y1 = y0
				local ok = true
				while ok do
					for x = x0, x1 do
						if not libre(x, y1 + 1, z0, c) then ok = false break end
					end
					if ok then y1 = y1 + 1 end
				end
				local z1 = z0
				ok = true
				while ok do
					for x = x0, x1 do
						for y = y0, y1 do
							if not libre(x, y, z1 + 1, c) then ok = false break end
						end
						if not ok then break end
					end
					if ok then z1 = z1 + 1 end
				end
				for x = x0, x1 do
					for y = y0, y1 do
						for z = z0, z1 do
							pris[grille[cle(x, y, z)]] = true
						end
					end
				end
				local dx, dy, dz = x1 - x0 + 1, y1 - y0 + 1, z1 - z0 + 1
				local p = Instance.new("Part")
				p.Name = g
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = true
				p.CastShadow = true
				p.Material = c.materiau or Enum.Material.Plastic
				p.Color = c.couleur
				p.Size = Vector3.new(dx * t, dy * t, dz * t)
				p.CFrame = origine * CFrame.new((x0 + dx / 2 - 0.5) * t, (y0 + dy / 2) * t, (z0 + dz / 2 - 0.5) * t)
				if p.Material ~= Enum.Material.Neon and p.Material ~= Enum.Material.Glass then
					p.TopSurface = surface
					p.BottomSurface = surface
					p.FrontSurface = surface
					p.BackSurface = surface
					p.LeftSurface = surface
					p.RightSurface = surface
				end
				p.Parent = modele
				nbParts = nbParts + 1
				if g == primaire and (not plusGrande or dx * dy * dz > plusGrande.Size.X * plusGrande.Size.Y * plusGrande.Size.Z / (t * t * t)) then
					plusGrande = p
				end
			end
		end
	end

	-- PrimaryPart « Corps » (la plus grande part du groupe primaire) ; pivot au sol, à l'origine
	if not plusGrande then
		for _, p in ipairs(modele:GetChildren()) do
			if p:IsA("BasePart") then plusGrande = p break end
		end
	end
	if plusGrande then
		plusGrande.Name = "Corps"
		modele.PrimaryPart = plusGrande
		plusGrande.PivotOffset = plusGrande.CFrame:ToObjectSpace(origine)
	end
	if props.budget and nbParts > props.budget then
		warn("[Dino] Voxel « " .. modele.Name .. " » : " .. nbParts .. " parts (budget " .. props.budget .. ")")
	end
	modele:SetAttribute("Voxels", self.nombre)
	modele:SetAttribute("Parts", nbParts)
	modele.Parent = parent
	return modele, nbParts
end

return Voxel
