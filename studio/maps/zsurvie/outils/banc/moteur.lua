-- Banc d'essai Zsurvie : horloge simulée, coroutines (task), signaux et bibliothèque standard Luau.
local banc = BANC

-- ===== journal =====
banc.erreurs = {}      -- { source, message }
banc.avertissements = {}
banc.sorties = {}
banc.inconnus = {}     -- "Classe.membre" -> nombre
banc.attentes = {}     -- WaitForChild sans fin

local function sourceDe(msg)
	local s = string.match(msg or "", "([%w_/]+%.lua):%d+") or string.match(msg or "", "%[string \"([^\"]+)\"%]")
	return s or "?"
end
banc.sourceDe = sourceDe

function banc.erreur(msg, trace)
	msg = tostring(msg)
	table.insert(banc.erreurs, { source = sourceDe(msg .. "\n" .. (trace or "")), message = msg, trace = trace or "", t = banc.maintenant() })
end

-- ===== horloge et ordonnanceur =====
local horloge = 0
function banc.maintenant() return horloge end
local file = {}        -- { t, co, args }
local cotes = setmetatable({}, { __mode = "k" }) -- coroutine -> "serveur" | "client"
local annulees = setmetatable({}, { __mode = "k" })
banc.coteParDefaut = "serveur"

function banc.cote()
	local co = coroutine.running()
	return cotes[co] or banc.coteParDefaut
end

local function reprendre(co, ...)
	if annulees[co] or coroutine.status(co) ~= "suspended" then return end
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		banc.erreur(err, debug.traceback(co, tostring(err)))
	end
end
banc.reprendre = reprendre

function banc.nouvelleCoroutine(fn, cote)
	local co = coroutine.create(fn)
	cotes[co] = cote or banc.cote()
	return co
end

local function planifier(t, co, args)
	table.insert(file, { t = t, co = co, args = args, n = #file })
end

-- attend d secondes (au moins une image)
local function attendre(d)
	local co, principal = coroutine.running()
	if principal or not co then error("task.wait appelé hors coroutine", 2) end
	local debut = horloge
	planifier(horloge + math.max(tonumber(d) or 0, 1 / 60), co, nil)
	coroutine.yield()
	return horloge - debut
end
banc.attendre = attendre

-- avance l'horloge jusqu'à t, en exécutant ce qui est dû
function banc.avancerJusqua(t)
	while true do
		local meilleur, idx = nil, nil
		for i, e in ipairs(file) do
			if e.t <= t and (not meilleur or e.t < meilleur.t or (e.t == meilleur.t and e.n < meilleur.n)) then
				meilleur, idx = e, i
			end
		end
		if not meilleur then break end
		table.remove(file, idx)
		if meilleur.t > horloge then horloge = meilleur.t end
		if meilleur.args then
			reprendre(meilleur.co, table.unpack(meilleur.args, 1, meilleur.args.n))
		else
			reprendre(meilleur.co, horloge - (meilleur.debut or horloge))
		end
	end
	horloge = t
end

task = {}
function task.wait(d) return attendre(d) end
function task.spawn(f, ...)
	local co = f
	if type(f) == "function" then co = banc.nouvelleCoroutine(f) elseif type(f) ~= "thread" then error("task.spawn : fonction attendue", 2) end
	reprendre(co, ...)
	return co
end
function task.defer(f, ...)
	local co = f
	if type(f) == "function" then co = banc.nouvelleCoroutine(f) end
	planifier(horloge, co, table.pack(...))
	return co
end
function task.delay(d, f, ...)
	local co = f
	if type(f) == "function" then co = banc.nouvelleCoroutine(f) end
	planifier(horloge + math.max(tonumber(d) or 0, 0), co, table.pack(...))
	return co
end
function task.cancel(co) annulees[co] = true end
function task.synchronize() end
function task.desynchronize() end
wait = function() error("wait() est déprécié : utiliser task.wait", 2) end
spawn = function() error("spawn() est déprécié : utiliser task.spawn", 2) end
delay = function() error("delay() est déprécié : utiliser task.delay", 2) end

function tick() return horloge + 1790000000 end
function time() return horloge end
function elapsedTime() return horloge end
os.clock = function() return horloge end
os.time = function(t) if t then return 1790000000 end return math.floor(horloge) + 1790000000 end

-- ===== signaux =====
local Signalmt = { __typeof = "RBXScriptSignal" }
local Connexionmt = { __typeof = "RBXScriptConnection" }
Connexionmt.__index = {
	Disconnect = function(c) c.Connected = false end,
}
local SignalM = {}
Signalmt.__index = SignalM
function banc.signal(nom)
	return setmetatable({ nom = nom, connexions = {}, attentes = {} }, Signalmt)
end
function SignalM.Connect(s, fn)
	if type(fn) ~= "function" then error("Connect : fonction attendue", 2) end
	local c = setmetatable({ Connected = true, fn = fn, cote = banc.cote() }, Connexionmt)
	table.insert(s.connexions, c)
	return c
end
function SignalM.Once(s, fn)
	local c
	c = s:Connect(function(...)
		c.Connected = false
		fn(...)
	end)
	return c
end
SignalM.ConnectParallel = SignalM.Connect
function SignalM.Wait(s)
	local co = coroutine.running()
	table.insert(s.attentes, co)
	return coroutine.yield()
end
function SignalM.Fire(s, ...)
	local liste = {}
	for _, c in ipairs(s.connexions) do
		if c.Connected then table.insert(liste, c) end
	end
	local vivantes = {}
	for _, c in ipairs(s.connexions) do if c.Connected then table.insert(vivantes, c) end end
	s.connexions = vivantes
	for _, c in ipairs(liste) do
		if c.Connected then
			reprendre(banc.nouvelleCoroutine(c.fn, c.cote), ...)
		end
	end
	local attentes = s.attentes
	s.attentes = {}
	for _, co in ipairs(attentes) do reprendre(co, ...) end
end
banc.Signal = SignalM

-- ===== bibliothèque standard Luau =====
function math.clamp(x, a, b)
	if a > b then error("math.clamp : max < min", 2) end
	return math.max(a, math.min(b, x))
end
function math.sign(x) if x > 0 then return 1 elseif x < 0 then return -1 end return 0 end
function math.round(x) if x >= 0 then return math.floor(x + 0.5) end return math.ceil(x - 0.5) end
function math.pow(a, b) return a ^ b end
math.log10 = function(x) return math.log(x, 10) end
function math.noise(x, y, z)
	x, y, z = x or 0, y or 0, z or 0
	local v = math.sin(x * 12.9898 + y * 78.233 + z * 37.719) * 43758.5453
	return (v - math.floor(v)) * 2 - 1
end
math.randomseed(42)
unpack = table.unpack
function string.split(s, sep)
	sep = sep or ","
	local t = {}
	if sep == "" then for i = 1, #s do t[i] = string.sub(s, i, i) end return t end
	local debut = 1
	while true do
		local i, j = string.find(s, sep, debut, true)
		if not i then table.insert(t, string.sub(s, debut)) break end
		table.insert(t, string.sub(s, debut, i - 1))
		debut = j + 1
	end
	return t
end
function table.find(t, v, init)
	for i = init or 1, #t do if t[i] == v then return i end end
	return nil
end
function table.clear(t) for k in pairs(t) do t[k] = nil end end
function table.create(n, v) local t = {} for i = 1, n do t[i] = v end return t end
function table.freeze(t) return t end
function table.isfrozen() return false end
function table.clone(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end
table.getn = function(t) return #t end
function table.maxn(t) local m = 0 for k in pairs(t) do if type(k) == "number" and k > m then m = k end end return m end
function table.foreach() error("table.foreach n'existe pas en Luau", 2) end
debug.profilebegin = function() end
debug.profileend = function() end
debug.setmemorycategory = function() end
bit32 = {
	band = function(a, b) return a & b end, bor = function(a, b) return a | b end, bxor = function(a, b) return a ~ b end,
	bnot = function(a) return (~a) & 0xFFFFFFFF end, lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
	rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
	extract = function(a, f, w) return (a >> f) & ((1 << (w or 1)) - 1) end,
}
loadstring = function() error("loadstring est désactivé", 2) end
getfenv = function() error("getfenv est interdit", 2) end
setfenv = function() error("setfenv est interdit", 2) end
collectgarbage = function(opt) if opt == "count" then return 1024 end return 0 end
shared = {}

local function formater(...)
	local n = select("#", ...)
	local t = {}
	for i = 1, n do t[i] = tostring((select(i, ...))) end
	return table.concat(t, " ")
end
function print(...)
	table.insert(banc.sorties, { t = horloge, cote = banc.cote(), texte = formater(...) })
end
function warn(...)
	local texte = formater(...)
	table.insert(banc.avertissements, { t = horloge, cote = banc.cote(), texte = texte, source = sourceDe(texte) })
end
settings = function() return banc.mockAny("settings()") end
UserSettings = function() return banc.mockAny("UserSettings()") end

-- ===== valeur « joker » pour les membres inconnus =====
local Anymt = { __typeof = "MockAny" }
local any = setmetatable({}, Anymt)
Anymt.__index = function(_, k) if type(k) == "number" then return nil end return any end
Anymt.__newindex = function() end
Anymt.__call = function() return any end
Anymt.__tostring = function() return "MockAny" end
Anymt.__concat = function(a, b) return tostring(a) .. tostring(b) end
Anymt.__len = function() return 0 end
Anymt.__eq = function() return false end
for _, op in ipairs({ "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm" }) do
	Anymt[op] = function() return 0 end
end
function banc.mockAny(ou)
	if ou then banc.inconnus[ou] = (banc.inconnus[ou] or 0) + 1 end
	return any
end
