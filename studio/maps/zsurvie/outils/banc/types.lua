-- Banc d'essai Zsurvie : types de données Roblox simulés (Vector3, CFrame, Color3, UDim2, Enum...).
-- Exécuté par fengari (Lua 5.3). Définit des globales, comme dans Roblox.
local banc = BANC

local function typer(mt, nom)
	mt.__typeof = nom
	mt.__metatable = nil
	return mt
end

local function estType(x, nom)
	local mt = type(x) == "table" and getmetatable(x)
	return mt and mt.__typeof == nom
end
banc.estType = estType

function typeof(x)
	if type(x) == "table" then
		local mt = getmetatable(x)
		if type(mt) == "table" and mt.__typeof then return mt.__typeof end
	end
	return type(x)
end

local function verifierNombre(x, quoi)
	if type(x) ~= "number" then error((quoi or "argument") .. " : nombre attendu, reçu " .. typeof(x), 3) end
	return x
end

-- ===== Vector3 =====
local V3 = {}
local V3mt = typer({}, "Vector3")
local function v3(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, V3mt) end
V3mt.__index = function(v, k)
	if k == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) end
	if k == "Unit" then
		local m = math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
		if m == 0 then return v3(0 / 0, 0 / 0, 0 / 0) end
		return v3(v.X / m, v.Y / m, v.Z / m)
	end
	if k == "x" then return v.X end
	if k == "y" then return v.Y end
	if k == "z" then return v.Z end
	local f = V3[k]
	if f then return f end
	error(tostring(k) .. " is not a valid member of Vector3", 2)
end
V3mt.__newindex = function() error("Vector3 est immuable", 2) end
local function vOuN(a, b, op)
	if type(a) == "number" then return op(v3(a, a, a), b) end
	if type(b) == "number" then return op(a, v3(b, b, b)) end
	if not estType(a, "Vector3") or not estType(b, "Vector3") then
		error("opération arithmétique invalide entre " .. typeof(a) .. " et " .. typeof(b), 3)
	end
	return op(a, b)
end
V3mt.__add = function(a, b)
	if not estType(a, "Vector3") or not estType(b, "Vector3") then error("addition invalide entre " .. typeof(a) .. " et " .. typeof(b), 2) end
	return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end
V3mt.__sub = function(a, b)
	if not estType(a, "Vector3") or not estType(b, "Vector3") then error("soustraction invalide entre " .. typeof(a) .. " et " .. typeof(b), 2) end
	return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end
V3mt.__mul = function(a, b) return vOuN(a, b, function(p, q) return v3(p.X * q.X, p.Y * q.Y, p.Z * q.Z) end) end
V3mt.__div = function(a, b) return vOuN(a, b, function(p, q) return v3(p.X / q.X, p.Y / q.Y, p.Z / q.Z) end) end
V3mt.__unm = function(a) return v3(-a.X, -a.Y, -a.Z) end
V3mt.__eq = function(a, b) return a.X == b.X and a.Y == b.Y and a.Z == b.Z end
V3mt.__tostring = function(v) return string.format("%g, %g, %g", v.X, v.Y, v.Z) end
function V3.Dot(a, b) return a.X * b.X + a.Y * b.Y + a.Z * b.Z end
function V3.Cross(a, b) return v3(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X) end
function V3.Lerp(a, b, t) return v3(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t, a.Z + (b.Z - a.Z) * t) end
function V3.FuzzyEq(a, b, e) e = e or 1e-5 return (a - b).Magnitude <= e end
function V3.Min(a, b) return v3(math.min(a.X, b.X), math.min(a.Y, b.Y), math.min(a.Z, b.Z)) end
function V3.Max(a, b) return v3(math.max(a.X, b.X), math.max(a.Y, b.Y), math.max(a.Z, b.Z)) end
function V3.Abs(a) return v3(math.abs(a.X), math.abs(a.Y), math.abs(a.Z)) end
function V3.Floor(a) return v3(math.floor(a.X), math.floor(a.Y), math.floor(a.Z)) end
function V3.Ceil(a) return v3(math.ceil(a.X), math.ceil(a.Y), math.ceil(a.Z)) end
function V3.Sign(a) return v3(math.sign(a.X), math.sign(a.Y), math.sign(a.Z)) end
function V3.Angle(a, b) return math.acos(math.max(-1, math.min(1, a.Unit:Dot(b.Unit)))) end
Vector3 = {
	new = function(x, y, z)
		if x ~= nil then verifierNombre(x, "Vector3.new") end
		if y ~= nil then verifierNombre(y, "Vector3.new") end
		if z ~= nil then verifierNombre(z, "Vector3.new") end
		return v3(x or 0, y or 0, z or 0)
	end,
	zero = v3(0, 0, 0), one = v3(1, 1, 1),
	xAxis = v3(1, 0, 0), yAxis = v3(0, 1, 0), zAxis = v3(0, 0, 1),
	FromNormalId = function(n)
		local t = { Top = v3(0, 1, 0), Bottom = v3(0, -1, 0), Front = v3(0, 0, -1), Back = v3(0, 0, 1), Right = v3(1, 0, 0), Left = v3(-1, 0, 0) }
		return t[n.Name]
	end,
}
banc.v3 = v3

-- ===== Vector2 =====
local V2 = {}
local V2mt = typer({}, "Vector2")
local function v2(x, y) return setmetatable({ X = x, Y = y }, V2mt) end
V2mt.__index = function(v, k)
	if k == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y) end
	if k == "Unit" then local m = math.sqrt(v.X * v.X + v.Y * v.Y) return v2(v.X / m, v.Y / m) end
	local f = V2[k]
	if f then return f end
	error(tostring(k) .. " is not a valid member of Vector2", 2)
end
V2mt.__newindex = function() error("Vector2 est immuable", 2) end
local function v2op(a, b, op)
	if type(a) == "number" then a = v2(a, a) end
	if type(b) == "number" then b = v2(b, b) end
	return v2(op(a.X, b.X), op(a.Y, b.Y))
end
V2mt.__add = function(a, b) return v2op(a, b, function(p, q) return p + q end) end
V2mt.__sub = function(a, b) return v2op(a, b, function(p, q) return p - q end) end
V2mt.__mul = function(a, b) return v2op(a, b, function(p, q) return p * q end) end
V2mt.__div = function(a, b) return v2op(a, b, function(p, q) return p / q end) end
V2mt.__unm = function(a) return v2(-a.X, -a.Y) end
V2mt.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
V2mt.__tostring = function(v) return v.X .. ", " .. v.Y end
function V2.Dot(a, b) return a.X * b.X + a.Y * b.Y end
function V2.Lerp(a, b, t) return v2(a.X + (b.X - a.X) * t, a.Y + (b.Y - a.Y) * t) end
function V2.Cross(a, b) return a.X * b.Y - a.Y * b.X end
Vector2 = { new = function(x, y) return v2(x or 0, y or 0) end, zero = v2(0, 0), one = v2(1, 1), xAxis = v2(1, 0), yAxis = v2(0, 1) }

-- ===== CFrame =====
local CF = {}
local CFmt = typer({}, "CFrame")
-- r = matrice 3x3 en lignes : { r00, r01, r02, r10, r11, r12, r20, r21, r22 }
local function cf(x, y, z, r)
	return setmetatable({ x = x, y = y, z = z, r = r }, CFmt)
end
local ID = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }
local function mulR(a, b)
	local r = {}
	for i = 0, 2 do
		for j = 0, 2 do
			r[i * 3 + j + 1] = a[i * 3 + 1] * b[j + 1] + a[i * 3 + 2] * b[3 + j + 1] + a[i * 3 + 3] * b[6 + j + 1]
		end
	end
	return r
end
local function appliquerR(r, x, y, z)
	return r[1] * x + r[2] * y + r[3] * z, r[4] * x + r[5] * y + r[6] * z, r[7] * x + r[8] * y + r[9] * z
end
local function transposer(r) return { r[1], r[4], r[7], r[2], r[5], r[8], r[3], r[6], r[9] } end
local function rotX(a) local c, s = math.cos(a), math.sin(a) return { 1, 0, 0, 0, c, -s, 0, s, c } end
local function rotY(a) local c, s = math.cos(a), math.sin(a) return { c, 0, s, 0, 1, 0, -s, 0, c } end
local function rotZ(a) local c, s = math.cos(a), math.sin(a) return { c, -s, 0, s, c, 0, 0, 0, 1 } end

local function versQuat(r)
	local tr = r[1] + r[5] + r[9]
	local w, x, y, z
	if tr > 0 then
		local s = math.sqrt(tr + 1) * 2
		w = 0.25 * s; x = (r[8] - r[6]) / s; y = (r[3] - r[7]) / s; z = (r[4] - r[2]) / s
	elseif r[1] > r[5] and r[1] > r[9] then
		local s = math.sqrt(1 + r[1] - r[5] - r[9]) * 2
		w = (r[8] - r[6]) / s; x = 0.25 * s; y = (r[2] + r[4]) / s; z = (r[3] + r[7]) / s
	elseif r[5] > r[9] then
		local s = math.sqrt(1 + r[5] - r[1] - r[9]) * 2
		w = (r[3] - r[7]) / s; x = (r[2] + r[4]) / s; y = 0.25 * s; z = (r[6] + r[8]) / s
	else
		local s = math.sqrt(1 + r[9] - r[1] - r[5]) * 2
		w = (r[4] - r[2]) / s; x = (r[3] + r[7]) / s; y = (r[6] + r[8]) / s; z = 0.25 * s
	end
	return x, y, z, w
end
local function depuisQuat(x, y, z, w)
	local n = math.sqrt(x * x + y * y + z * z + w * w)
	if n == 0 then return { 1, 0, 0, 0, 1, 0, 0, 0, 1 } end
	x, y, z, w = x / n, y / n, z / n, w / n
	return {
		1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w),
		2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w),
		2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y),
	}
end

local function regarder(px, py, pz, cible, haut)
	haut = haut or v3(0, 1, 0)
	local dx, dy, dz = cible.X - px, cible.Y - py, cible.Z - pz
	local m = math.sqrt(dx * dx + dy * dy + dz * dz)
	if m < 1e-9 then return cf(px, py, pz, ID) end
	local l = v3(dx / m, dy / m, dz / m)
	local droite = l:Cross(haut)
	if droite.Magnitude < 1e-6 then droite = l:Cross(v3(0, 0, 1)) end
	droite = droite.Unit
	local h = droite:Cross(l)
	return cf(px, py, pz, { droite.X, h.X, -l.X, droite.Y, h.Y, -l.Y, droite.Z, h.Z, -l.Z })
end

CFmt.__index = function(c, k)
	if k == "Position" or k == "p" then return v3(c.x, c.y, c.z) end
	if k == "X" then return c.x end
	if k == "Y" then return c.y end
	if k == "Z" then return c.z end
	local r = c.r
	if k == "LookVector" then return v3(-r[3], -r[6], -r[9]) end
	if k == "RightVector" or k == "XVector" then return v3(r[1], r[4], r[7]) end
	if k == "UpVector" or k == "YVector" then return v3(r[2], r[5], r[8]) end
	if k == "ZVector" then return v3(r[3], r[6], r[9]) end
	if k == "Rotation" then return cf(0, 0, 0, r) end
	local f = CF[k]
	if f then return f end
	error(tostring(k) .. " is not a valid member of CFrame", 2)
end
CFmt.__newindex = function() error("CFrame est immuable", 2) end
CFmt.__mul = function(a, b)
	if not estType(a, "CFrame") then error("multiplication invalide : " .. typeof(a) .. " * " .. typeof(b), 2) end
	if estType(b, "CFrame") then
		local x, y, z = appliquerR(a.r, b.x, b.y, b.z)
		return cf(a.x + x, a.y + y, a.z + z, mulR(a.r, b.r))
	elseif estType(b, "Vector3") then
		local x, y, z = appliquerR(a.r, b.X, b.Y, b.Z)
		return v3(a.x + x, a.y + y, a.z + z)
	end
	error("multiplication invalide : CFrame * " .. typeof(b), 2)
end
CFmt.__add = function(a, b)
	if not estType(a, "CFrame") or not estType(b, "Vector3") then error("addition invalide : " .. typeof(a) .. " + " .. typeof(b), 2) end
	return cf(a.x + b.X, a.y + b.Y, a.z + b.Z, a.r)
end
CFmt.__sub = function(a, b)
	if not estType(a, "CFrame") or not estType(b, "Vector3") then error("soustraction invalide : " .. typeof(a) .. " - " .. typeof(b), 2) end
	return cf(a.x - b.X, a.y - b.Y, a.z - b.Z, a.r)
end
CFmt.__eq = function(a, b)
	if a.x ~= b.x or a.y ~= b.y or a.z ~= b.z then return false end
	for i = 1, 9 do if a.r[i] ~= b.r[i] then return false end end
	return true
end
CFmt.__tostring = function(c)
	return string.format("%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g, %g", c.x, c.y, c.z, table.unpack(c.r))
end
function CF.Inverse(c)
	local t = transposer(c.r)
	local x, y, z = appliquerR(t, c.x, c.y, c.z)
	return cf(-x, -y, -z, t)
end
function CF.ToWorldSpace(a, b) return a * b end
function CF.ToObjectSpace(a, b) return a:Inverse() * b end
function CF.PointToWorldSpace(a, v) return a * v end
function CF.PointToObjectSpace(a, v) return a:Inverse() * v end
function CF.VectorToWorldSpace(a, v) local x, y, z = appliquerR(a.r, v.X, v.Y, v.Z) return v3(x, y, z) end
function CF.VectorToObjectSpace(a, v) local x, y, z = appliquerR(transposer(a.r), v.X, v.Y, v.Z) return v3(x, y, z) end
function CF.GetComponents(c) return c.x, c.y, c.z, table.unpack(c.r) end
CF.components = CF.GetComponents
function CF.ToEulerAnglesXYZ(c)
	local r = c.r
	local ry = math.asin(math.max(-1, math.min(1, r[3])))
	return math.atan(-r[6], r[9]), ry, math.atan(-r[2], r[1])
end
function CF.ToEulerAnglesYXZ(c)
	local r = c.r
	local rx = math.asin(math.max(-1, math.min(1, -r[6])))
	return rx, math.atan(r[3], r[9]), math.atan(r[4], r[5])
end
CF.ToOrientation = CF.ToEulerAnglesYXZ
function CF.ToAxisAngle(c)
	local x, y, z, w = versQuat(c.r)
	local ang = 2 * math.acos(math.max(-1, math.min(1, w)))
	local s = math.sqrt(1 - w * w)
	if s < 1e-6 then return v3(1, 0, 0), 0 end
	return v3(x / s, y / s, z / s), ang
end
function CF.Lerp(a, b, t)
	local ax, ay, az, aw = versQuat(a.r)
	local bx, by, bz, bw = versQuat(b.r)
	if ax * bx + ay * by + az * bz + aw * bw < 0 then bx, by, bz, bw = -bx, -by, -bz, -bw end
	local r = depuisQuat(ax + (bx - ax) * t, ay + (by - ay) * t, az + (bz - az) * t, aw + (bw - aw) * t)
	return cf(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t, r)
end
function CF.Orthonormalize(c) return c end
function CF.FuzzyEq(a, b, e) return (a.Position - b.Position).Magnitude < (e or 1e-5) end

CFrame = {}
function CFrame.new(a, b, c, ...)
	if a == nil then return cf(0, 0, 0, ID) end
	if estType(a, "Vector3") then
		if b ~= nil then return regarder(a.X, a.Y, a.Z, b) end
		return cf(a.X, a.Y, a.Z, ID)
	end
	verifierNombre(a, "CFrame.new")
	verifierNombre(b, "CFrame.new")
	verifierNombre(c, "CFrame.new")
	local reste = { ... }
	if #reste == 4 then
		return cf(a, b, c, depuisQuat(reste[1], reste[2], reste[3], reste[4]))
	elseif #reste == 9 then
		return cf(a, b, c, reste)
	end
	return cf(a, b, c, ID)
end
function CFrame.lookAt(p, cible, haut) return regarder(p.X, p.Y, p.Z, cible, haut) end
function CFrame.Angles(rx, ry, rz)
	verifierNombre(rx, "CFrame.Angles"); verifierNombre(ry, "CFrame.Angles"); verifierNombre(rz, "CFrame.Angles")
	return cf(0, 0, 0, mulR(mulR(rotX(rx), rotY(ry)), rotZ(rz)))
end
CFrame.fromEulerAnglesXYZ = CFrame.Angles
function CFrame.fromEulerAnglesYXZ(rx, ry, rz) return cf(0, 0, 0, mulR(mulR(rotY(ry), rotX(rx)), rotZ(rz))) end
CFrame.fromOrientation = CFrame.fromEulerAnglesYXZ
function CFrame.fromEulerAngles(rx, ry, rz) return CFrame.Angles(rx, ry, rz) end
function CFrame.fromAxisAngle(axe, ang)
	local u = axe.Unit
	local s = math.sin(ang / 2)
	return cf(0, 0, 0, depuisQuat(u.X * s, u.Y * s, u.Z * s, math.cos(ang / 2)))
end
function CFrame.fromMatrix(p, vx, vy, vz)
	vz = vz or vx:Cross(vy)
	return cf(p.X, p.Y, p.Z, { vx.X, vy.X, vz.X, vx.Y, vy.Y, vz.Y, vx.Z, vy.Z, vz.Z })
end
CFrame.identity = cf(0, 0, 0, ID)
banc.cf = cf

-- ===== Color3 =====
local C3 = {}
local C3mt = typer({}, "Color3")
local function c3(r, g, b) return setmetatable({ R = r, G = g, B = b }, C3mt) end
C3mt.__index = function(c, k)
	if k == "r" then return c.R end
	if k == "g" then return c.G end
	if k == "b" then return c.B end
	local f = C3[k]
	if f then return f end
	error(tostring(k) .. " is not a valid member of Color3", 2)
end
C3mt.__newindex = function() error("Color3 est immuable", 2) end
C3mt.__eq = function(a, b) return a.R == b.R and a.G == b.G and a.B == b.B end
C3mt.__tostring = function(c) return string.format("%g, %g, %g", c.R, c.G, c.B) end
function C3.Lerp(a, b, t) return c3(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t) end
function C3.ToHSV(c)
	local r, g, b = c.R, c.G, c.B
	local mx, mn = math.max(r, g, b), math.min(r, g, b)
	local d = mx - mn
	local h = 0
	if d > 0 then
		if mx == r then h = ((g - b) / d) % 6 elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
		h = h / 6
	end
	local s = 0
	if mx > 0 then s = d / mx end
	return h, s, mx
end
function C3.ToHex(c)
	local function o(x) return math.floor(math.max(0, math.min(1, x)) * 255 + 0.5) end
	return string.format("%02X%02X%02X", o(c.R), o(c.G), o(c.B))
end
Color3 = {
	new = function(r, g, b) return c3(r or 0, g or 0, b or 0) end,
	fromRGB = function(r, g, b)
		verifierNombre(r, "Color3.fromRGB"); verifierNombre(g, "Color3.fromRGB"); verifierNombre(b, "Color3.fromRGB")
		return c3(r / 255, g / 255, b / 255)
	end,
	fromHSV = function(h, s, v)
		local i = math.floor(h * 6)
		local f = h * 6 - i
		local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
		i = i % 6
		if i == 0 then return c3(v, t, p) elseif i == 1 then return c3(q, v, p) elseif i == 2 then return c3(p, v, t)
		elseif i == 3 then return c3(p, q, v) elseif i == 4 then return c3(t, p, v) else return c3(v, p, q) end
	end,
	fromHex = function(h)
		h = string.gsub(h, "#", "")
		return c3(tonumber(string.sub(h, 1, 2), 16) / 255, tonumber(string.sub(h, 3, 4), 16) / 255, tonumber(string.sub(h, 5, 6), 16) / 255)
	end,
}

local BCmt = typer({}, "BrickColor")
BCmt.__index = function(b, k) if k == "r" then return b.Color.R end return nil end
BrickColor = {
	new = function(x, y, z)
		if type(x) == "number" and y then return setmetatable({ Color = c3(x, y, z), Name = "Custom" }, BCmt) end
		if estType(x, "Color3") then return setmetatable({ Color = x, Name = "Custom" }, BCmt) end
		return setmetatable({ Color = c3(0.6, 0.6, 0.6), Name = tostring(x) }, BCmt)
	end,
}
for _, nom in ipairs({ "Random", "White", "Gray", "DarkGray", "Black", "Red", "Yellow", "Green", "Blue" }) do
	BrickColor[nom] = function() return BrickColor.new(nom) end
end

-- ===== UDim / UDim2 / Rect =====
local UDmt = typer({}, "UDim")
local function udim(s, o) return setmetatable({ Scale = s, Offset = o }, UDmt) end
UDmt.__add = function(a, b) return udim(a.Scale + b.Scale, a.Offset + b.Offset) end
UDmt.__sub = function(a, b) return udim(a.Scale - b.Scale, a.Offset - b.Offset) end
UDmt.__eq = function(a, b) return a.Scale == b.Scale and a.Offset == b.Offset end
UDmt.__index = function(_, k) error(tostring(k) .. " is not a valid member of UDim", 2) end
UDim = { new = function(s, o) return udim(s or 0, o or 0) end }

local U2 = {}
local U2mt = typer({}, "UDim2")
local function udim2(xs, xo, ys, yo) return setmetatable({ X = udim(xs, xo), Y = udim(ys, yo) }, U2mt) end
U2mt.__index = function(u, k)
	if k == "Width" then return u.X end
	if k == "Height" then return u.Y end
	local f = U2[k]
	if f then return f end
	error(tostring(k) .. " is not a valid member of UDim2", 2)
end
U2mt.__add = function(a, b) return udim2(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset) end
U2mt.__sub = function(a, b) return udim2(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset) end
U2mt.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
U2mt.__tostring = function(u) return string.format("{%g, %g}, {%g, %g}", u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset) end
function U2.Lerp(a, b, t)
	return udim2(a.X.Scale + (b.X.Scale - a.X.Scale) * t, a.X.Offset + (b.X.Offset - a.X.Offset) * t,
		a.Y.Scale + (b.Y.Scale - a.Y.Scale) * t, a.Y.Offset + (b.Y.Offset - a.Y.Offset) * t)
end
UDim2 = {
	new = function(xs, xo, ys, yo)
		if estType(xs, "UDim") then return setmetatable({ X = xs, Y = xo }, U2mt) end
		for _, n in ipairs({ xs or 0, xo or 0, ys or 0, yo or 0 }) do verifierNombre(n, "UDim2.new") end
		return udim2(xs or 0, xo or 0, ys or 0, yo or 0)
	end,
	fromScale = function(x, y) verifierNombre(x, "UDim2.fromScale") verifierNombre(y, "UDim2.fromScale") return udim2(x, 0, y, 0) end,
	fromOffset = function(x, y) verifierNombre(x, "UDim2.fromOffset") verifierNombre(y, "UDim2.fromOffset") return udim2(0, x, 0, y) end,
}
local Rmt = typer({}, "Rect")
Rect = { new = function(a, b, c, d)
	if estType(a, "Vector2") then return setmetatable({ Min = a, Max = b, Width = b.X - a.X, Height = b.Y - a.Y }, Rmt) end
	return setmetatable({ Min = v2(a or 0, b or 0), Max = v2(c or 0, d or 0), Width = (c or 0) - (a or 0), Height = (d or 0) - (b or 0) }, Rmt)
end }

-- ===== séquences, plages, tweens, rayons =====
local NRmt = typer({}, "NumberRange")
NumberRange = { new = function(a, b) return setmetatable({ Min = a, Max = b or a }, NRmt) end }
local NSKmt = typer({}, "NumberSequenceKeypoint")
NumberSequenceKeypoint = { new = function(t, v, e) return setmetatable({ Time = t, Value = v, Envelope = e or 0 }, NSKmt) end }
local NSmt = typer({}, "NumberSequence")
NumberSequence = { new = function(a, b)
	if type(a) == "table" then return setmetatable({ Keypoints = a }, NSmt) end
	return setmetatable({ Keypoints = { NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(1, b or a) } }, NSmt)
end }
local CSKmt = typer({}, "ColorSequenceKeypoint")
ColorSequenceKeypoint = { new = function(t, c) return setmetatable({ Time = t, Value = c }, CSKmt) end }
local CSmt = typer({}, "ColorSequence")
ColorSequence = { new = function(a, b)
	if estType(a, "Color3") then
		return setmetatable({ Keypoints = { ColorSequenceKeypoint.new(0, a), ColorSequenceKeypoint.new(1, b or a) } }, CSmt)
	end
	if type(a) ~= "table" then error("ColorSequence.new : argument invalide", 2) end
	return setmetatable({ Keypoints = a }, CSmt)
end }
local TImt = typer({}, "TweenInfo")
TweenInfo = { new = function(t, style, dir, rep, inv, delai)
	return setmetatable({ Time = t or 1, EasingStyle = style, EasingDirection = dir, RepeatCount = rep or 0, Reverses = inv or false, DelayTime = delai or 0 }, TImt)
end }
local Raymt = typer({}, "Ray")
Raymt.__index = function(r, k)
	if k == "Unit" then return Ray.new(r.Origin, r.Direction.Unit) end
	if k == "ClosestPoint" then return function(self, p) local d = self.Direction.Unit return self.Origin + d * math.max(0, (p - self.Origin):Dot(d)) end end
	if k == "Distance" then return function(self, p) return (self:ClosestPoint(p) - p).Magnitude end end
	return nil
end
Ray = { new = function(o, d) return setmetatable({ Origin = o, Direction = d }, Raymt) end }
local RPmt = typer({}, "RaycastParams")
RPmt.__index = { AddToFilter = function(self, x)
	if typeof(x) == "Instance" then table.insert(self.FilterDescendantsInstances, x) else for _, i in ipairs(x) do table.insert(self.FilterDescendantsInstances, i) end end
end }
local function nouveauxParams()
	return setmetatable({ FilterDescendantsInstances = {}, FilterType = Enum.RaycastFilterType.Exclude, IgnoreWater = false, CollisionGroup = "Default", RespectCanCollide = false, MaxParts = 0, BruteForceAllSlow = false }, RPmt)
end
RaycastParams = { new = nouveauxParams }
OverlapParams = { new = nouveauxParams }
local PPmt = typer({}, "PhysicalProperties")
PhysicalProperties = { new = function(d, f, e, fw, ew) return setmetatable({ Density = d, Friction = f, Elasticity = e }, PPmt) end }
local R3mt = typer({}, "Region3")
Region3 = { new = function(a, b) return setmetatable({ CFrame = CFrame.new((a + b) / 2), Size = b - a }, R3mt) end }
local Fontmt = typer({}, "Font")
Font = {
	new = function(famille, poids, style) return setmetatable({ Family = famille, Weight = poids, Style = style, Bold = false }, Fontmt) end,
	fromEnum = function(e) return setmetatable({ Family = "rbxasset://fonts/families/" .. e.Name .. ".json" }, Fontmt) end,
	fromName = function(n) return setmetatable({ Family = n }, Fontmt) end,
	fromId = function(n) return setmetatable({ Family = tostring(n) }, Fontmt) end,
}
DateTime = {
	now = function()
		local t = banc.maintenant() + 1790000000
		return { UnixTimestamp = math.floor(t), UnixTimestampMillis = math.floor(t * 1000),
			FormatLocalTime = function() return "" end, FormatUniversalTime = function() return "" end,
			ToIsoDate = function() return "2026-09-26T00:00:00Z" end }
	end,
	fromUnixTimestamp = function(t) return { UnixTimestamp = t } end,
}

-- ===== Random (déterministe) =====
local RDmt = typer({}, "Random")
local RD = {}
RDmt.__index = RD
local function suivant(g)
	-- LCG 48 bits (comme drand48)
	g.etat = (g.etat * 25214903917 + 11) % 281474976710656
	return g.etat / 281474976710656
end
function RD.NextNumber(g, a, b)
	a, b = a or 0, b or 1
	return a + (b - a) * suivant(g)
end
function RD.NextInteger(g, a, b)
	if type(a) ~= "number" or type(b) ~= "number" then error("Random:NextInteger : deux entiers attendus", 2) end
	if b < a then error("Random:NextInteger : max < min", 2) end
	return math.floor(a + (b - a + 1) * suivant(g))
end
function RD.NextUnitVector(g)
	local t, u = suivant(g) * 2 * math.pi, suivant(g) * 2 - 1
	local s = math.sqrt(1 - u * u)
	return v3(s * math.cos(t), u, s * math.sin(t))
end
function RD.Shuffle(g, t)
	for i = #t, 2, -1 do
		local j = RD.NextInteger(g, 1, i)
		t[i], t[j] = t[j], t[i]
	end
end
function RD.Clone(g) return setmetatable({ etat = g.etat }, RDmt) end
Random = { new = function(graine)
	graine = math.floor(graine or 12345)
	return setmetatable({ etat = (graine * 7919 + 104729) % 281474976710656 }, RDmt)
end }

-- ===== Enum =====
local LISTES = {
	Material = "Plastic SmoothPlastic Neon Wood WoodPlanks Marble Slate Concrete Granite Brick Pebble Cobblestone Rock Sandstone Basalt CrackedLava Limestone Pavement Asphalt LeafyGrass Salt Snow Mud Ground Grass Sand Water Ice Glacier Glass ForceField Foil DiamondPlate Metal CorrodedMetal Fabric Cardboard Carpet CeramicTiles ClayRoofTiles RoofShingles Leather Plaster Rubber Air",
	Font = "Legacy Arial ArialBold SourceSans SourceSansBold SourceSansSemibold SourceSansLight SourceSansItalic Bodoni Garamond Cartoon Code Highway SciFi Arcade Fantasy Antique Gotham GothamMedium GothamBold GothamBlack GothamSemibold AmaticSC Bangers Creepster DenkOne Fondamento FredokaOne GrenzeGotisch IndieFlower JosefinSans Jura Kalam LuckiestGuy Merriweather Michroma Nunito Oswald PatrickHand PermanentMarker Roboto RobotoCondensed RobotoMono Sarpanch SpecialElite TitilliumWeb Ubuntu BuilderSans BuilderSansMedium BuilderSansBold BuilderSansExtraBold Arimo ArimoBold Unknown",
	PartType = "Ball Block Cylinder Wedge CornerWedge",
	SurfaceType = "Smooth Glue Weld Studs Inlet Universal Hinge Motor SteppingMotor SmoothNoOutlines",
	NormalId = "Right Top Back Left Bottom Front",
	EasingStyle = "Linear Sine Back Quad Quart Quint Bounce Elastic Exponential Circular Cubic",
	EasingDirection = "In Out InOut",
	SurfaceGuiSizingMode = "FixedSize PixelsPerStud",
	TextXAlignment = "Left Right Center",
	TextYAlignment = "Top Center Bottom",
	FillDirection = "Horizontal Vertical",
	HorizontalAlignment = "Center Left Right",
	VerticalAlignment = "Center Top Bottom",
	SortOrder = "Name Custom LayoutOrder",
	ZIndexBehavior = "Global Sibling",
	AutomaticSize = "None X Y XY",
	ScaleType = "Stretch Slice Tile Fit Crop",
	ApplyStrokeMode = "Contextual Border",
	UserInputType = "MouseButton1 MouseButton2 MouseButton3 MouseWheel MouseMovement Touch Keyboard Focus Accelerometer Gyro Gamepad1 Gamepad2 TextInput InputMethod None",
	UserInputState = "Begin Change End Cancel None",
	RaycastFilterType = "Exclude Include Blacklist Whitelist",
	HumanoidStateType = "FallingDown Running RunningNoPhysics Climbing StrafingNoPhysics Ragdoll GettingUp Jumping Landed Flying Freefall Seated PlatformStanding Dead Swimming Physics None",
	PlaybackState = "Begin Delayed Playing Paused Completed Cancelled",
	CameraType = "Fixed Attach Watch Track Follow Custom Scriptable Orbital",
	ParticleEmitterShape = "Box Sphere Cylinder Disc",
	ParticleEmitterShapeStyle = "Volume Surface",
	ParticleEmitterShapeInOut = "Outward Inward InAndOut",
	ProximityPromptStyle = "Default Custom",
	ProximityPromptExclusivity = "OnePerButton OneGlobally AlwaysShow",
	ContextActionResult = "Pass Sink",
	Technology = "Legacy Voxel Compatibility ShadowMap Future Unified",
	HighlightDepthMode = "AlwaysOnTop Occluded",
	TextTruncate = "None AtEnd SplitWord",
	LineJoinMode = "Round Bevel Miter",
	RollOffMode = "Inverse Linear InverseTapered LinearSquare",
	AspectType = "FitWithinMaxSize ScaleWithParentSize",
	DominantAxis = "Width Height",
	ScrollingDirection = "X Y XY",
	SizeConstraint = "RelativeXY RelativeXX RelativeYY",
	MeshType = "Head Torso Wedge Prism Pyramid ParallelRamp RightAngleRamp CornerWedge Brick Sphere Cylinder FileMesh",
	CoreGuiType = "PlayerList Health Backpack Chat All EmotesMenu SelfView Captures",
	HumanoidDisplayDistanceType = "Viewer Subject None",
	ExplosionType = "NoCraters Craters",
	FontWeight = "Thin ExtraLight Light Regular Medium SemiBold Bold ExtraBold Heavy",
	FontStyle = "Normal Italic",
	ModelStreamingMode = "Default Atomic Persistent PersistentPerPlayer Nonatomic",
	AnalyticsEconomyFlowType = "Sink Source",
	AnalyticsEconomyTransactionType = "IAP Shop Gameplay ContextualPurchase TimedReward Onboarding",
	AnalyticsLogLevel = "Trace Debug Information Warning Error Fatal",
	AnalyticsProgressionType = "Custom Start Fail Complete",
	ProductPurchaseDecision = "NotProcessedYet PurchaseGranted",
	InfoType = "Asset Product GamePass Subscription Bundle",
	MouseBehavior = "Default LockCenter LockCurrentPosition",
	ResamplerMode = "Default Pixelated",
	TrailTextureMode = "Stretch Wrap Static",
	TextureMode = "Stretch Wrap Static",
	FrameStyle = "Custom ChatBlue RobloxSquare RobloxRound ChatGreen ChatRed DropShadow",
	ButtonStyle = "Custom RobloxButtonDefault RobloxButton RobloxRoundButton RobloxRoundDefaultButton RobloxRoundDropdownButton",
	BorderMode = "Outline Middle Inset",
	ElasticBehavior = "WhenScrollable Always Never",
	ScrollBarInset = "None ScrollBar Always",
	VerticalScrollBarPosition = "Right Left",
	ActuatorRelativeTo = "Attachment0 Attachment1 World",
	PathStatus = "Success ClosestNoPath ClosestOutOfRange FailStartNotEmpty FailFinishNotEmpty NoPath",
	AnimationPriority = "Idle Movement Action Action2 Action3 Action4 Core",
	DevComputerMovementMode = "UserChoice KeyboardMouse ClickToMove Scriptable",
	DevTouchMovementMode = "UserChoice Thumbstick DPad Thumbpad ClickToMove Scriptable DynamicThumbstick",
	CameraMode = "Classic LockFirstPerson",
	DevCameraOcclusionMode = "Zoom Invisicam",
	NameOcclusion = "NoOcclusion EnemyOcclusion OccludeAll",
	RenderPriority = "First Input Camera Character Last",
	SoundType = "NoSound Boing Bomb Break Click Clock Slingshot Page Ping Snap Splat Step StepOn Swoosh Victory",
	GuiType = "Gui",
	ChatStyle = "Classic Bubble ClassicAndBubble",
	BodyPart = "Head Torso LeftArm RightArm LeftLeg RightLeg",
}
local EnumItemmt = typer({}, "EnumItem")
EnumItemmt.__tostring = function(e) return "Enum." .. e.EnumType.nom .. "." .. e.Name end
EnumItemmt.__index = function(e, k)
	if k == "IsA" then return function(self, n) return self.EnumType.nom == n end end
	error(tostring(k) .. " is not a valid member of EnumItem", 2)
end
local Enummt = typer({}, "Enum")
Enummt.__tostring = function(e) return e.nom end
local enums = {}
Enummt.__index = function(e, k)
	if k == "GetEnumItems" then
		return function(self)
			local l = {}
			for _, it in pairs(self.items) do table.insert(l, it) end
			table.sort(l, function(a, b) return a.Value < b.Value end)
			return l
		end
	end
	if k == "FromName" then return function(self, n) return rawget(self.items, n) end end
	if k == "FromValue" then return function(self, v) for _, it in pairs(self.items) do if it.Value == v then return it end end return nil end end
	local it = e.items[k]
	if it then return it end
	if e.ferme then error(tostring(k) .. " is not a valid EnumItem of Enum." .. e.nom, 2) end
	it = setmetatable({ Name = k, Value = e.suivant, EnumType = e }, EnumItemmt)
	e.suivant = e.suivant + 1
	e.items[k] = it
	return it
end
local function enumPour(nom)
	local e = enums[nom]
	if e then return e end
	e = setmetatable({ nom = nom, items = {}, suivant = 0, ferme = LISTES[nom] ~= nil }, Enummt)
	enums[nom] = e
	if LISTES[nom] then
		for n in string.gmatch(LISTES[nom], "%S+") do
			e.items[n] = setmetatable({ Name = n, Value = e.suivant, EnumType = e }, EnumItemmt)
			e.suivant = e.suivant + 1
		end
	end
	return e
end
Enum = setmetatable({}, typer({ __index = function(_, k) return enumPour(k) end }, "Enums"))
