-- Banc d'essai Dino Chapardeurs : export des parts du Workspace (pour l'aperçu 3D).
local banc = BANC
local donnees = banc.donnees

local function hex(c)
	if typeof(c) ~= "Color3" then return "CCCCCC" end
	return c:ToHex()
end
local function r3(x) return math.floor(x * 1000 + 0.5) / 1000 end

function EXPORTER(nom)
	local racine = workspace:FindFirstChild("Dino")
	local parts = {}
	if racine then
		for _, p in ipairs(banc.partsDe(racine)) do
			if p.Transparency < 1 then
				local c = p.CFrame
				local zone = p
				while zone.Parent and zone.Parent ~= racine do zone = zone.Parent end
				local forme = "Block"
				if p.ClassName == "WedgePart" then forme = "Wedge"
				elseif p.ClassName == "CornerWedgePart" then forme = "CornerWedge"
				elseif p.ClassName == "Part" or p.ClassName == "SpawnLocation" or p.ClassName == "Seat" then forme = p.Shape.Name end
				local m = p.Material.Name
				local lum = 0
				for _, e in ipairs(p:GetChildren()) do
					if e:IsA("Light") and e.Enabled then lum = 1 end
				end
				local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = c:GetComponents()
				table.insert(parts, { r3(x), r3(y), r3(z), r3(r00), r3(r01), r3(r02), r3(r10), r3(r11), r3(r12), r3(r20), r3(r21), r3(r22),
					r3(p.Size.X), r3(p.Size.Y), r3(p.Size.Z), hex(p.Color), r3(p.Transparency), forme, m, zone.Name, lum })
			end
		end
	end
	local terrain = {}
	for _, f in ipairs(banc.remplissages) do
		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = f.cf:GetComponents()
		table.insert(terrain, { f.genre, r3(x), r3(y), r3(z), r3(r00), r3(r01), r3(r02), r3(r10), r3(r11), r3(r12), r3(r20), r3(r21), r3(r22), r3(f.taille.X), r3(f.taille.Y), r3(f.taille.Z), f.materiau })
	end
	local L = game:GetService("Lighting")
	local eclairage = { ClockTime = L.ClockTime, Ambient = hex(L.Ambient), OutdoorAmbient = hex(L.OutdoorAmbient), FogColor = hex(L.FogColor), FogEnd = L.FogEnd, Brightness = L.Brightness }
	local atmo = L:FindFirstChildOfClass("Atmosphere")
	if atmo then eclairage.Atmosphere = { Density = atmo.Density, Color = hex(atmo.Color) } end
	-- étiquettes flottantes (BillboardGui) : position, taille en studs et lignes de texte
	local etiquettes = {}
	if racine then
		for _, g in ipairs(racine:GetDescendants()) do
			if g.ClassName == "BillboardGui" and g.Enabled ~= false and #etiquettes < 600 then
				local support = g.Adornee or g.Parent
				if support and support:IsA("BasePart") then
					local p = support.Position + g.StudsOffset + g.StudsOffsetWorldSpace
					local lignes = {}
					for _, t in ipairs(g:GetDescendants()) do
						if (t:IsA("TextLabel") or t:IsA("TextButton")) and t.Text ~= "" then
							local visible = true
							local a = t
							while a and a ~= g do
								if a:IsA("GuiObject") and not a.Visible then visible = false end
								a = a.Parent
							end
							if visible then
								local couleur = hex(t.TextColor3)
								local grad = t:FindFirstChildOfClass("UIGradient")
								local degrade = nil
								if grad then
									degrade = {}
									for _, k in ipairs(grad.Color.Keypoints) do table.insert(degrade, hex(k.Value)) end
								end
								local contour = t:FindFirstChildOfClass("UIStroke")
								table.insert(lignes, { t.Text, couleur, t.Size.Y.Scale, degrade, contour and hex(contour.Color) or nil, t.Font and t.Font.Name or "" })
							end
						end
					end
					if #lignes > 0 then
						table.insert(etiquettes, { r3(p.X), r3(p.Y), r3(p.Z), r3(g.Size.X.Scale), r3(g.Size.Y.Scale), lignes })
					end
				end
			end
		end
	end
	local couleursTerrain = {}
	for k, c in pairs(banc.couleursTerrain or {}) do couleursTerrain[k] = hex(c) end
	local t = workspace.Terrain
	eclairage.Eau = hex(t.WaterColor)
	__ecrire("parts-" .. nom, banc.json({ parts = parts, terrain = terrain, eclairage = eclairage, etiquettes = etiquettes, couleursTerrain = couleursTerrain }))
end
