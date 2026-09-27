-- Banc d'essai Dino Chapardeurs : game, workspace et services Roblox simulés.
local banc = BANC
local donnees = banc.donnees
local methode, lecture = banc.methode, banc.lecture
local v3 = banc.v3

banc.compteurs = {}
function banc.compter(cle) banc.compteurs[cle] = (banc.compteurs[cle] or 0) + 1 end

-- livraison réseau avec une petite latence, dans une coroutine du côté destinataire
function banc.envoyer(fn, cote, ...)
	local args = table.pack(...)
	local co = banc.nouvelleCoroutine(function() fn(table.unpack(args, 1, args.n)) end, cote)
	task.delay(0.03, co)
end

local function ajouterClasse(nom, parent)
	banc.PARENTS[nom] = parent or "Instance"
end

-- ===== DataModel =====
game = banc.nouvelleInstance("DataModel")
donnees[game].props.Name = "Game"
local services = {}
local CLASSES_SERVICES = {
	Workspace = "Workspace", Players = "Players", ReplicatedStorage = "ReplicatedStorage", ServerStorage = "ServerStorage",
	ServerScriptService = "ServerScriptService", Lighting = "Lighting", RunService = "RunService",
	TweenService = "TweenService", Debris = "Debris", DataStoreService = "DataStoreService",
	MarketplaceService = "MarketplaceService", SoundService = "SoundService", CollectionService = "CollectionService",
	HttpService = "HttpService", UserInputService = "UserInputService", ContextActionService = "ContextActionService",
	ProximityPromptService = "ProximityPromptService", StarterGui = "StarterGui", StarterPlayer = "StarterPlayer",
	StarterPack = "StarterPack", TextChatService = "TextChatService", Chat = "Chat", PhysicsService = "PhysicsService",
	AnalyticsService = "AnalyticsService", TeleportService = "TeleportService", BadgeService = "BadgeService",
	GuiService = "GuiService", Teams = "Teams", LocalizationService = "LocalizationService", PolicyService = "PolicyService",
	PathfindingService = "PathfindingService", Stats = "Stats", MessagingService = "MessagingService",
	MemoryStoreService = "MemoryStoreService", VRService = "VRService", HapticService = "HapticService",
	GroupService = "GroupService", SocialService = "SocialService", AvatarEditorService = "AvatarEditorService",
	TextService = "TextService", ReplicatedFirst = "ReplicatedFirst", LogService = "LogService", ScriptContext = "ScriptContext",
	ContentProvider = "ContentProvider", GamePassService = "GamePassService", AssetService = "AssetService",
}
for nom in pairs(CLASSES_SERVICES) do if nom ~= "Workspace" then ajouterClasse(nom) end end

function banc.service(nom, silencieux)
	if services[nom] then return services[nom] end
	if not CLASSES_SERVICES[nom] then
		if silencieux then return nil end
		error("'" .. tostring(nom) .. "' is not a valid Service name", 3)
	end
	local s = banc.nouvelleInstance(CLASSES_SERVICES[nom])
	donnees[s].props.Name = nom
	donnees[s].parent = game
	table.insert(donnees[game].enfants, s)
	services[nom] = s
	if banc.initService[nom] then banc.initService[nom](s) end
	return s
end
banc.initService = {}
methode("DataModel", "GetService", function(self, nom) return banc.service(nom) end)
methode("DataModel", "FindService", function(self, nom) return banc.service(nom, true) end)
methode("DataModel", "IsLoaded", function() return true end)
methode("DataModel", "BindToClose", function(self, fn) banc.fermeture = banc.fermeture or {} table.insert(banc.fermeture, fn) end)
methode("DataModel", "GetJobsInfo", function() return {} end)
donnees[game].props.PlaceId = 0
donnees[game].props.GameId = 0
donnees[game].props.JobId = ""
donnees[game].props.CreatorId = 0
donnees[game].props.PlaceVersion = 1
donnees[game].props.PrivateServerId = ""
donnees[game].props.PrivateServerOwnerId = 0

-- ===== Workspace =====
workspace = banc.service("Workspace")
Workspace = workspace
local camera = banc.nouvelleInstance("Camera")
donnees[camera].props.Name = "Camera"
camera.Parent = workspace
donnees[workspace].props.CurrentCamera = camera
local terrain = banc.nouvelleInstance("Terrain")
donnees[terrain].props.Name = "Terrain"
donnees[terrain].props.Anchored = true
terrain.Parent = workspace
donnees[workspace].props.Terrain = terrain
banc.remplissages = {}
local function remplir(genre, cf_, taille, materiau)
	if typeof(materiau) ~= "EnumItem" then error("Terrain : matériau Enum.Material attendu", 3) end
	table.insert(banc.remplissages, { genre = genre, cf = cf_, taille = taille, materiau = materiau.Name })
end
methode("Terrain", "FillBlock", function(self, c, s, m) remplir("bloc", c, s, m) end)
methode("Terrain", "FillBall", function(self, p, r, m) remplir("boule", CFrame.new(p), v3(r * 2, r * 2, r * 2), m) end)
methode("Terrain", "FillCylinder", function(self, c, h, r, m) remplir("cylindre", c, v3(r * 2, h, r * 2), m) end)
methode("Terrain", "FillWedge", function(self, c, s, m) remplir("coin", c, s, m) end)
methode("Terrain", "FillRegion", function(self, reg, res, m) remplir("bloc", reg.CFrame, reg.Size, m) end)
methode("Terrain", "Clear", function() banc.remplissages = {} end)
banc.couleursTerrain = {}
methode("Terrain", "SetMaterialColor", function(self, m, c)
	if typeof(m) ~= "EnumItem" or typeof(c) ~= "Color3" then error("SetMaterialColor : Enum.Material et Color3 attendus", 2) end
	banc.couleursTerrain[m.Name] = c
end)
methode("Terrain", "GetMaterialColor", function(self, m) return banc.couleursTerrain[m.Name] or Color3.new(0.5, 0.5, 0.5) end)
methode("Terrain", "ReadVoxels", function() return {}, {} end)
methode("Terrain", "WriteVoxels", function() end)
methode("Terrain", "ReplaceMaterial", function() end)
donnees[terrain].props.WaterColor = Color3.new(0.05, 0.33, 0.36)
donnees[terrain].props.WaterTransparency = 0.3
donnees[terrain].props.WaterWaveSize = 0.15
donnees[terrain].props.WaterWaveSpeed = 10
donnees[terrain].props.WaterReflectance = 1
donnees[terrain].props.Decoration = false

-- lancer de rayon : boîtes orientées de toutes les parts du Workspace
local function filtrer(params)
	if not params then return function() return true end end
	local liste = params.FilterDescendantsInstances or {}
	local inclure = params.FilterType == Enum.RaycastFilterType.Include or params.FilterType == Enum.RaycastFilterType.Whitelist
	return function(p)
		local dedans = false
		for _, f in ipairs(liste) do
			if p == f or p:IsDescendantOf(f) then dedans = true break end
		end
		if inclure then return dedans end
		return not dedans
	end
end
local function rayonBoite(p, origine, dir)
	local inv = p.CFrame:Inverse()
	local o = inv * origine
	local d = inv:VectorToWorldSpace(dir)
	local s = p.Size / 2
	local tmin, tmax = 0, 1
	local oo, dd, ss = { o.X, o.Y, o.Z }, { d.X, d.Y, d.Z }, { s.X, s.Y, s.Z }
	local normale = 0
	for i = 1, 3 do
		if math.abs(dd[i]) < 1e-12 then
			if oo[i] < -ss[i] or oo[i] > ss[i] then return nil end
		else
			local t1, t2 = (-ss[i] - oo[i]) / dd[i], (ss[i] - oo[i]) / dd[i]
			if t1 > t2 then t1, t2 = t2, t1 end
			if t1 > tmin then tmin = t1 normale = i end
			if t2 < tmax then tmax = t2 end
			if tmin > tmax then return nil end
		end
	end
	return tmin, normale
end
local toutesLesParts = {}
banc.toutesLesParts = toutesLesParts
banc.surAjout = function(inst)
	if inst:IsA("BasePart") then toutesLesParts[inst] = true end
	for _, e in ipairs(banc.descendants(inst)) do
		if e:IsA("BasePart") then toutesLesParts[e] = true end
	end
end
banc.surDestruction = function(inst) toutesLesParts[inst] = nil end
methode("Workspace", "Raycast", function(self, origine, dir, params)
	if typeof(origine) ~= "Vector3" or typeof(dir) ~= "Vector3" then error("Raycast : deux Vector3 attendus", 2) end
	banc.compter("raycast")
	local ok = filtrer(params)
	local meilleur, tm
	for p in pairs(toutesLesParts) do
		if p.Parent and p:IsDescendantOf(workspace) and p.CanQuery and ok(p) then
			local t = rayonBoite(p, origine, dir)
			if t and (not tm or t < tm) then meilleur, tm = p, t end
		end
	end
	if not meilleur then return nil end
	return { Instance = meilleur, Position = origine + dir * tm, Normal = v3(0, 1, 0), Material = meilleur.Material, Distance = dir.Magnitude * tm }
end)
local function dansBoite(p, centre, rayon)
	return (p.Position - centre).Magnitude <= rayon + p.Size.Magnitude / 2
end
methode("Workspace", "GetPartBoundsInRadius", function(self, centre, rayon, params)
	local ok = filtrer(params)
	local t = {}
	for p in pairs(toutesLesParts) do
		if p.Parent and p:IsDescendantOf(workspace) and ok(p) and dansBoite(p, centre, rayon) then table.insert(t, p) end
	end
	return t
end)
methode("Workspace", "GetPartBoundsInBox", function(self, c, taille, params)
	return self:GetPartBoundsInRadius(c.Position, taille.Magnitude / 2, params)
end)
methode("Workspace", "GetPartsInPart", function(self, part, params)
	return self:GetPartBoundsInRadius(part.Position, part.Size.Magnitude / 2, params)
end)
methode("Workspace", "Spherecast", function(self, o, r, d, params) return self:Raycast(o, d, params) end)
methode("Workspace", "Blockcast", function(self, c, s, d, params) return self:Raycast(c.Position, d, params) end)
methode("Workspace", "GetServerTimeNow", function() return banc.maintenant() + 1790000000 end)
methode("Workspace", "GetRealPhysicsFPS", function() return 60 end)
methode("Workspace", "FindPartOnRay", function(self, ray)
	local r = self:Raycast(ray.Origin, ray.Direction)
	if r then return r.Instance, r.Position, r.Normal, r.Material end
	return nil, ray.Origin + ray.Direction
end)

-- caméra
local function rayonCamera(self, x, y, profondeur)
	local c = self.CFrame
	local vp = self.ViewportSize
	local fov = math.rad(self.FieldOfView)
	local h = math.tan(fov / 2)
	local nx = (x / vp.X * 2 - 1) * h * vp.X / vp.Y
	local ny = -(y / vp.Y * 2 - 1) * h
	local dir = c:VectorToWorldSpace(v3(nx, ny, -1)).Unit
	return Ray.new(c.Position, dir * (profondeur or 1))
end
methode("Camera", "ScreenPointToRay", rayonCamera)
methode("Camera", "ViewportPointToRay", rayonCamera)
local function projeter(self, p)
	local l = self.CFrame:PointToObjectSpace(p)
	local vp = self.ViewportSize
	local h = math.tan(math.rad(self.FieldOfView) / 2)
	if l.Z >= 0 then return v3(0, 0, l.Z), false end
	local x = (l.X / -l.Z) / (h * vp.X / vp.Y)
	local y = (l.Y / -l.Z) / h
	local sx, sy = (x + 1) / 2 * vp.X, (1 - y) / 2 * vp.Y
	return v3(sx, sy, -l.Z), sx >= 0 and sx <= vp.X and sy >= 0 and sy <= vp.Y
end
methode("Camera", "WorldToScreenPoint", projeter)
methode("Camera", "WorldToViewportPoint", projeter)

-- ===== Players =====
ajouterClasse("Players")
banc.joueurs = {}
methode("Players", "GetPlayers", function() local t = {} for i, j in ipairs(banc.joueurs) do t[i] = j end return t end)
methode("Players", "GetPlayerFromCharacter", function(self, c)
	for _, j in ipairs(banc.joueurs) do if j.Character == c then return j end end
	return nil
end)
methode("Players", "GetPlayerByUserId", function(self, id)
	for _, j in ipairs(banc.joueurs) do if j.UserId == id then return j end end
	return nil
end)
methode("Players", "GetUserThumbnailAsync", function() return "rbxasset://textures/ui/GuiImagePlaceholder.png", true end)
methode("Players", "GetNameFromUserIdAsync", function() return "Testeur" end)
methode("Players", "GetUserIdFromNameAsync", function() return 1 end)
methode("Players", "GetHumanoidDescriptionFromUserId", function() return Instance.new("HumanoidDescription") end)
banc.initService.Players = function(s)
	donnees[s].props.MaxPlayers = 6
	donnees[s].props.RespawnTime = 5
	donnees[s].props.CharacterAutoLoads = true
end
lecture("Players", "LocalPlayer", function()
	if banc.cote() == "client" then return banc.joueurLocal end
	return nil
end)
methode("Player", "Kick", function(self, raison) banc.compter("kick") table.insert(banc.avertissements, { t = banc.maintenant(), cote = "serveur", texte = "joueur expulsé : " .. tostring(raison), source = "?" }) end)
methode("Player", "LoadCharacter", function(self) end)
methode("Player", "IsFriendsWith", function() return false end)
methode("Player", "GetRankInGroup", function() return 0 end)
methode("Player", "GetRoleInGroup", function() return "Guest" end)
methode("Player", "IsInGroup", function() return false end)
methode("Player", "DistanceFromCharacter", function(self, p)
	local c = self.Character
	local r = c and c:FindFirstChild("HumanoidRootPart")
	if not r then return 0 end
	return (r.Position - p).Magnitude
end)
methode("Player", "GetMouse", function(self)
	if banc.cote() ~= "client" then error("GetMouse ne fonctionne que côté client", 2) end
	return banc.souris
end)
methode("Player", "GetNetworkPing", function() return 0.05 end)
methode("Player", "GetJoinData", function() return {} end)
methode("Player", "RequestStreamAroundAsync", function() end)

-- ===== RunService =====
banc.initService.RunService = function(s) end
methode("RunService", "IsServer", function() return banc.cote() == "serveur" end)
methode("RunService", "IsClient", function() return banc.cote() == "client" end)
methode("RunService", "IsStudio", function() return true end)
methode("RunService", "IsRunning", function() return true end)
methode("RunService", "IsRunMode", function() return false end)
methode("RunService", "BindToRenderStep", function(self, nom, prio, fn)
	if banc.cote() ~= "client" then error("BindToRenderStep : client uniquement", 2) end
	banc.rendus = banc.rendus or {}
	banc.rendus[nom] = { fn = fn, cote = "client" }
end)
methode("RunService", "UnbindFromRenderStep", function(self, nom) if banc.rendus then banc.rendus[nom] = nil end end)

-- ===== TweenService =====
local Tweenmt = { __typeof = "Instance" }
methode("TweenService", "Create", function(self, inst, info, buts)
	if typeof(inst) ~= "Instance" then error("TweenService:Create : Instance attendue", 2) end
	if typeof(info) ~= "TweenInfo" then error("TweenService:Create : TweenInfo attendu", 2) end
	if type(buts) ~= "table" then error("TweenService:Create : table de propriétés attendue", 2) end
	for k, v in pairs(buts) do
		local actuel = inst[k]
		if typeof(actuel) ~= typeof(v) and not (type(actuel) == "number" and type(v) == "number") then
			error("TweenService:Create : propriété " .. tostring(k) .. " incompatible (" .. typeof(actuel) .. " / " .. typeof(v) .. ")", 2)
		end
	end
	local tw = banc.nouvelleInstance("Tween")
	local d = donnees[tw]
	d.props.Name = "Tween"
	d.props.PlaybackState = Enum.PlaybackState.Begin
	d.cible, d.info, d.buts = inst, info, buts
	return tw
end)
ajouterClasse("Tween")
methode("Tween", "Play", function(self)
	local d = donnees[self]
	d.props.PlaybackState = Enum.PlaybackState.Playing
	d.jeton = (d.jeton or 0) + 1
	local jeton = d.jeton
	banc.compter("tween")
	local infini = d.info.RepeatCount < 0
	task.delay(d.info.Time + d.info.DelayTime, function()
		if d.jeton ~= jeton then return end
		if not donnees[d.cible].detruite then
			for k, v in pairs(d.buts) do d.cible[k] = v end
		end
		if not infini then
			d.props.PlaybackState = Enum.PlaybackState.Completed
			banc.obtenirSignal(self, "Completed"):Fire(Enum.PlaybackState.Completed)
		end
	end)
end)
methode("Tween", "Cancel", function(self)
	local d = donnees[self]
	d.jeton = (d.jeton or 0) + 1
	d.props.PlaybackState = Enum.PlaybackState.Cancelled
	banc.obtenirSignal(self, "Completed"):Fire(Enum.PlaybackState.Cancelled)
end)
methode("Tween", "Pause", function(self) local d = donnees[self] d.jeton = (d.jeton or 0) + 1 d.props.PlaybackState = Enum.PlaybackState.Paused end)
methode("TweenService", "GetValue", function(self, a) return a end)
methode("TweenService", "SmoothDamp", function(self, a, b) return b end)

-- ===== Debris =====
methode("Debris", "AddItem", function(self, inst, duree)
	task.delay(duree or 10, function() if inst.Parent then inst:Destroy() end end)
end)

-- ===== CollectionService =====
methode("CollectionService", "AddTag", function(self, i, t) i:AddTag(t) end)
methode("CollectionService", "RemoveTag", function(self, i, t) i:RemoveTag(t) end)
methode("CollectionService", "HasTag", function(self, i, t) return i:HasTag(t) end)
methode("CollectionService", "GetTags", function(self, i) return i:GetTags() end)
methode("CollectionService", "GetTagged", function(self, t)
	local l = {}
	for _, e in ipairs(banc.descendants(game)) do if e:HasTag(t) then table.insert(l, e) end end
	return l
end)
methode("CollectionService", "GetInstanceAddedSignal", function(self, t) return banc.signal("TagAjout:" .. t) end)
methode("CollectionService", "GetInstanceRemovedSignal", function(self, t) return banc.signal("TagRetrait:" .. t) end)
methode("CollectionService", "GetAllTags", function() return {} end)

-- ===== DataStoreService =====
banc.magasins = {}
local function magasin(nom)
	banc.magasins[nom] = banc.magasins[nom] or {}
	local contenu = banc.magasins[nom]
	local m = {}
	local function latence() banc.compter("datastore") task.wait(0.05) end
	function m.GetAsync(self, cle) latence() return contenu[cle] end
	function m.SetAsync(self, cle, v) latence() contenu[cle] = v return v end
	function m.UpdateAsync(self, cle, fn) latence() local r = fn(contenu[cle]) if r ~= nil then contenu[cle] = r end return contenu[cle] end
	function m.RemoveAsync(self, cle) latence() local v = contenu[cle] contenu[cle] = nil return v end
	function m.IncrementAsync(self, cle, n) latence() contenu[cle] = (contenu[cle] or 0) + (n or 1) return contenu[cle] end
	function m.GetSortedAsync(self)
		latence()
		return { IsFinished = true, GetCurrentPage = function() return {} end, AdvanceToNextPageAsync = function() end }
	end
	return m
end
methode("DataStoreService", "GetDataStore", function(self, nom, portee) return magasin(nom .. "/" .. tostring(portee or "")) end)
methode("DataStoreService", "GetOrderedDataStore", function(self, nom, portee) return magasin("ordonne:" .. nom) end)
methode("DataStoreService", "GetGlobalDataStore", function() return magasin("global") end)
methode("DataStoreService", "GetRequestBudgetForRequestType", function() return 100 end)

-- ===== HttpService =====
local function encoder(v)
	local t = type(v)
	if t == "nil" then return "null" end
	if t == "boolean" then return tostring(v) end
	if t == "number" then
		if v ~= v or v == math.huge or v == -math.huge then return "null" end
		if math.type(v) == "integer" then return tostring(v) end
		local texte = string.gsub(string.format("%.4f", v), "0+$", "")
		texte = string.gsub(texte, "%.$", "")
		return texte
	end
	if t == "string" then return "\"" .. string.gsub(v, "[%c\"\\]", function(c) return string.format("\\u%04x", string.byte(c)) end) .. "\"" end
	if t ~= "table" or typeof(v) ~= "table" then return encoder(tostring(v)) end
	if t == "table" then
		if #v > 0 or next(v) == nil then
			local p = {}
			for i, x in ipairs(v) do p[i] = encoder(x) end
			return "[" .. table.concat(p, ",") .. "]"
		end
		local p = {}
		for k, x in pairs(v) do table.insert(p, encoder(tostring(k)) .. ":" .. encoder(x)) end
		table.sort(p)
		return "{" .. table.concat(p, ",") .. "}"
	end
	error("JSONEncode : type non pris en charge " .. typeof(v), 3)
end
banc.json = encoder
methode("HttpService", "JSONEncode", function(self, v) return encoder(v) end)
methode("HttpService", "JSONDecode", function(self, s) return banc.jsonDecoder(s) end)
local guid = 0
methode("HttpService", "GenerateGUID", function(self, accolades)
	guid = guid + 1
	local s = string.format("%08X-0000-4000-8000-%012X", guid, guid)
	if accolades == false then return s end
	return "{" .. s .. "}"
end)
methode("HttpService", "UrlEncode", function(self, s) return s end)
methode("HttpService", "GetAsync", function() error("HTTP désactivé", 2) end)
methode("HttpService", "PostAsync", function() error("HTTP désactivé", 2) end)
methode("HttpService", "RequestAsync", function() error("HTTP désactivé", 2) end)

-- ===== MarketplaceService =====
methode("MarketplaceService", "UserOwnsGamePassAsync", function() return false end)
methode("MarketplaceService", "PlayerOwnsAsset", function() return false end)
methode("MarketplaceService", "PromptGamePassPurchase", function() banc.compter("achat") end)
methode("MarketplaceService", "PromptProductPurchase", function() banc.compter("achat") end)
methode("MarketplaceService", "PromptPurchase", function() banc.compter("achat") end)
methode("MarketplaceService", "GetProductInfo", function() return { Name = "Article", PriceInRobux = 0, IsForSale = false, Description = "" } end)

-- ===== UserInputService =====
banc.initService.UserInputService = function(s)
	local p = donnees[s].props
	p.TouchEnabled = false
	p.KeyboardEnabled = true
	p.MouseEnabled = true
	p.GamepadEnabled = false
	p.AccelerometerEnabled = false
	p.GyroscopeEnabled = false
	p.VREnabled = false
	p.MouseBehavior = Enum.MouseBehavior.Default
	p.MouseIconEnabled = true
	p.MouseIcon = ""
	p.MouseDeltaSensitivity = 1
	p.PreferredInput = Enum.UserInputType.Keyboard
end
methode("UserInputService", "GetMouseLocation", function() return Vector2.new(640, 360) end)
methode("UserInputService", "IsKeyDown", function() return false end)
methode("UserInputService", "IsMouseButtonPressed", function() return false end)
methode("UserInputService", "GetLastInputType", function() return Enum.UserInputType.MouseButton1 end)
methode("UserInputService", "GetKeysPressed", function() return {} end)
methode("UserInputService", "GetFocusedTextBox", function() return nil end)
methode("UserInputService", "GetConnectedGamepads", function() return {} end)
methode("UserInputService", "GetGamepadConnected", function() return false end)
methode("UserInputService", "GetMouseDelta", function() return Vector2.new() end)

-- ===== ContextActionService =====
banc.actions = {}
methode("ContextActionService", "BindAction", function(self, nom, fn, bouton, ...)
	if type(fn) ~= "function" then error("BindAction : fonction attendue", 2) end
	banc.actions[nom] = { fn = fn, cote = banc.cote() }
end)
methode("ContextActionService", "BindActionAtPriority", function(self, nom, fn, bouton, prio, ...)
	banc.actions[nom] = { fn = fn, cote = banc.cote() }
end)
methode("ContextActionService", "UnbindAction", function(self, nom) banc.actions[nom] = nil end)
methode("ContextActionService", "UnbindAllActions", function() banc.actions = {} end)
methode("ContextActionService", "SetTitle", function() end)
methode("ContextActionService", "SetImage", function() end)
methode("ContextActionService", "SetDescription", function() end)
methode("ContextActionService", "SetPosition", function() end)
methode("ContextActionService", "GetButton", function() return nil end)

-- ===== divers =====
methode("GuiService", "GetGuiInset", function() return Vector2.new(0, 36), Vector2.new(0, 0) end)
methode("GuiService", "IsTenFootInterface", function() return false end)
methode("StarterGui", "SetCore", function() end)
methode("StarterGui", "GetCore", function() return nil end)
methode("StarterGui", "SetCoreGuiEnabled", function() end)
methode("StarterGui", "GetCoreGuiEnabled", function() return true end)
methode("SoundService", "PlayLocalSound", function() banc.sons = (banc.sons or 0) + 1 end)
methode("SoundService", "SetListener", function() end)
methode("PhysicsService", "RegisterCollisionGroup", function() end)
methode("PhysicsService", "CollisionGroupSetCollidable", function() end)
methode("PhysicsService", "IsCollisionGroupRegistered", function() return false end)
methode("PhysicsService", "CreateCollisionGroup", function() end)
methode("PhysicsService", "SetPartCollisionGroup", function() end)
banc.analytique = {}
for _, n in ipairs({ "LogCustomEvent", "LogEconomyEvent", "LogProgressionEvent", "LogOnboardingFunnelStepEvent", "LogFunnelStepEvent", "FireEvent", "FireLogEvent", "FireCustomEvent" }) do
	methode("AnalyticsService", n, function(self, joueur, ...) table.insert(banc.analytique, n) end)
end
methode("BadgeService", "AwardBadge", function() return true end)
methode("BadgeService", "UserHasBadgeAsync", function() return false end)
methode("BadgeService", "GetBadgeInfoAsync", function() return { IsEnabled = false, Name = "Badge" } end)
methode("TeleportService", "TeleportAsync", function() error("téléportation entre places désactivée dans le banc", 2) end)
methode("PolicyService", "GetPolicyInfoForPlayerAsync", function() return { ArePaidRandomItemsRestricted = false, AllowedExternalLinkReferences = {}, IsSubjectToChinaPolicies = false, IsPaidItemTradingAllowed = true, AreAdsAllowed = false } end)
methode("LocalizationService", "GetCountryRegionForPlayerAsync", function() return "FR" end)
methode("TextService", "GetTextSize", function(self, t, taille) return Vector2.new(#tostring(t) * (taille or 14) * 0.5, taille or 14) end)
methode("TextService", "FilterStringAsync", function(self, t) return { GetNonChatStringForBroadcastAsync = function() return t end, GetChatForUserAsync = function() return t end, GetNonChatStringForUserAsync = function() return t end } end)
methode("ContentProvider", "PreloadAsync", function() end)
methode("MessagingService", "PublishAsync", function() end)
methode("MessagingService", "SubscribeAsync", function() return { Disconnect = function() end } end)
methode("PathfindingService", "CreatePath", function()
	return { ComputeAsync = function() end, GetWaypoints = function() return {} end, Status = Enum.PathStatus.NoPath, Blocked = banc.signal("Blocked"), Destroy = function() end }
end)
banc.initService.Lighting = function(s)
	local p = donnees[s].props
	p.Ambient = Color3.new(0.27, 0.27, 0.27)
	p.Brightness = 2
	p.ClockTime = 14
	p.TimeOfDay = "14:00:00"
	p.GeographicLatitude = 0
	p.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
	p.ColorShift_Top = Color3.new(0, 0, 0)
	p.ColorShift_Bottom = Color3.new(0, 0, 0)
	p.EnvironmentDiffuseScale = 0
	p.EnvironmentSpecularScale = 0
	p.ExposureCompensation = 0
	p.FogColor = Color3.new(0.75, 0.75, 0.75)
	p.FogEnd = 100000
	p.FogStart = 0
	p.GlobalShadows = true
	p.ShadowSoftness = 0.2
	p.Technology = Enum.Technology.Future
	p.LightingStyle = 0
end
methode("Lighting", "GetMinutesAfterMidnight", function(self) return self.ClockTime * 60 end)
methode("Lighting", "SetMinutesAfterMidnight", function(self, m) self.ClockTime = m / 60 end)
methode("Lighting", "GetSunDirection", function() return v3(0.3, 0.9, 0.3).Unit end)
methode("Lighting", "GetMoonDirection", function() return v3(-0.3, 0.9, -0.3).Unit end)
banc.initService.StarterPlayer = function(s)
	local p = donnees[s].props
	p.CharacterWalkSpeed = 16
	p.CharacterJumpPower = 50
	p.CharacterJumpHeight = 7.2
	p.CameraMaxZoomDistance = 128
	p.CameraMinZoomDistance = 0.5
	p.CharacterUseJumpPower = false
	p.AutoJumpEnabled = true
	p.EnableMouseLockOption = true
	p.LoadCharacterAppearance = true
	p.HealthDisplayDistance = 100
	p.NameDisplayDistance = 100
end
banc.initService.ProximityPromptService = function(s)
	donnees[s].props.Enabled = true
	donnees[s].props.MaxPromptsVisible = 16
end
methode("Stats", "GetTotalMemoryUsageMb", function() return 400 end)
methode("Stats", "GetMemoryUsageMbForTag", function() return 10 end)
banc.initService.Stats = function(s)
	donnees[s].props.DataReceiveKbps = 10
	donnees[s].props.DataSendKbps = 10
	donnees[s].props.HeartbeatTimeMs = 5
	donnees[s].props.PhysicsStepTimeMs = 2
	donnees[s].props.InstanceCount = 10000
	donnees[s].props.PrimitivesCount = 5000
	donnees[s].props.MovingPrimitivesCount = 20
end

-- la souris du joueur local
banc.souris = {
	Hit = CFrame.new(0, 0, 0), Target = nil, X = 640, Y = 360, UnitRay = Ray.new(Vector3.zero, v3(0, -1, 0)),
	Icon = "", TargetFilter = nil, ViewSizeX = 1280, ViewSizeY = 720, Origin = CFrame.new(0, 80, 90),
	Button1Down = banc.signal("Button1Down"), Button1Up = banc.signal("Button1Up"),
	Button2Down = banc.signal("Button2Down"), Button2Up = banc.signal("Button2Up"),
	Move = banc.signal("Move"), Idle = banc.signal("Idle"), WheelForward = banc.signal("WheelForward"),
	WheelBackward = banc.signal("WheelBackward"), KeyDown = banc.signal("KeyDown"), KeyUp = banc.signal("KeyUp"),
}

-- création d'un joueur de test
function banc.creerJoueur(nom, id)
	local j = banc.nouvelleInstance("Player")
	local p = donnees[j].props
	p.Name = nom
	p.DisplayName = nom
	p.UserId = id
	p.AccountAge = 100
	p.MembershipType = Enum.MembershipType.None
	p.Neutral = true
	p.CameraMaxZoomDistance = 128
	p.CameraMinZoomDistance = 0.5
	p.HasVerifiedBadge = false
	p.LocaleId = "fr-fr"
	p.FollowUserId = 0
	local gui = banc.nouvelleInstance("PlayerGui")
	donnees[gui].props.Name = "PlayerGui"
	gui.Parent = j
	local sac = banc.nouvelleInstance("Backpack")
	donnees[sac].props.Name = "Backpack"
	sac.Parent = j
	local ps = banc.nouvelleInstance("PlayerScripts")
	donnees[ps].props.Name = "PlayerScripts"
	ps.Parent = j
	-- personnage
	local perso = banc.nouvelleInstance("Model")
	donnees[perso].props.Name = nom
	local racine = Instance.new("Part")
	racine.Name = "HumanoidRootPart"
	racine.Size = v3(2, 2, 1)
	racine.CFrame = CFrame.new(0, 3, 648)
	racine.Transparency = 1
	racine.CanCollide = false
	racine.Parent = perso
	local tete = Instance.new("Part")
	tete.Name = "Head"
	tete.Size = v3(1, 1, 1)
	tete.CFrame = CFrame.new(0, 4.5, 648)
	tete.Parent = perso
	local h = Instance.new("Humanoid")
	h.Parent = perso
	donnees[h].props.RootPart = racine
	perso.PrimaryPart = racine
	p.Character = perso
	return j
end
