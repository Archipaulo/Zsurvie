-- Banc d'essai Zsurvie : charge le projet, simule un joueur qui fait une partie complète, et produit un rapport.
local banc = BANC
local donnees = banc.donnees
local v3 = banc.v3

-- ===== petit décodeur JSON (pour HttpService:JSONDecode) =====
function banc.jsonDecoder(s)
	local i = 1
	local function espaces() i = string.find(s, "[^%s]", i) or #s + 1 end
	local valeur
	local function chaine()
		i = i + 1
		local t = {}
		while true do
			local c = string.sub(s, i, i)
			if c == "\"" then i = i + 1 break end
			if c == "\\" then
				local n = string.sub(s, i + 1, i + 1)
				if n == "u" then
					table.insert(t, utf8.char(tonumber(string.sub(s, i + 2, i + 5), 16)))
					i = i + 6
				else
					local map = { n = "\n", t = "\t", r = "\r", b = "\b", f = "\f" }
					table.insert(t, map[n] or n)
					i = i + 2
				end
			else
				table.insert(t, c)
				i = i + 1
			end
			if i > #s then error("JSONDecode : chaîne non terminée") end
		end
		return table.concat(t)
	end
	valeur = function()
		espaces()
		local c = string.sub(s, i, i)
		if c == "{" then
			i = i + 1
			local t = {}
			espaces()
			if string.sub(s, i, i) == "}" then i = i + 1 return t end
			while true do
				espaces()
				local k = chaine()
				espaces()
				i = i + 1 -- :
				t[k] = valeur()
				espaces()
				local c2 = string.sub(s, i, i)
				i = i + 1
				if c2 == "}" then return t end
			end
		elseif c == "[" then
			i = i + 1
			local t = {}
			espaces()
			if string.sub(s, i, i) == "]" then i = i + 1 return t end
			while true do
				table.insert(t, valeur())
				espaces()
				local c2 = string.sub(s, i, i)
				i = i + 1
				if c2 == "]" then return t end
			end
		elseif c == "\"" then
			return chaine()
		elseif string.sub(s, i, i + 3) == "true" then i = i + 4 return true
		elseif string.sub(s, i, i + 4) == "false" then i = i + 5 return false
		elseif string.sub(s, i, i + 3) == "null" then i = i + 4 return nil
		else
			local n = string.match(s, "^-?[%d%.eE+-]+", i)
			if not n then error("JSONDecode : JSON invalide") end
			i = i + #n
			return tonumber(n)
		end
	end
	return valeur()
end

-- ===== chargement du projet =====
local sources = {}
local caches = { serveur = {}, client = {} }
local enCours = { serveur = {}, client = {} }

local function executer(chemin, script_)
	local env = setmetatable({ script = script_ }, { __index = _G, __newindex = function(t, k, v) rawset(t, k, v) end })
	local f, err = load(sources[chemin], "@" .. chemin, "t", env)
	if not f then error(err, 0) end
	return f
end

function require(module)
	if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
		error("require : ModuleScript attendu, reçu " .. typeof(module), 2)
	end
	local cote = banc.cote()
	local cache = caches[cote]
	if cache[module] ~= nil then return cache[module].valeur end
	local chemin = donnees[module].source
	if not chemin then error("module sans source : " .. module:GetFullName(), 2) end
	if enCours[cote][chemin] then error("require circulaire : " .. chemin, 2) end
	enCours[cote][chemin] = true
	local f = executer(chemin, module)
	local r = table.pack(pcall(f))
	enCours[cote][chemin] = nil
	if not r[1] then error(r[2], 0) end
	if r.n ~= 2 then error("Module code did not return exactly one value : " .. chemin, 2) end
	cache[module] = { valeur = r[2] }
	return r[2]
end

local function lancerScript(inst, cote)
	local chemin = donnees[inst].source
	local co = banc.nouvelleCoroutine(function()
		local f = executer(chemin, inst)
		f()
	end, cote)
	banc.reprendre(co)
end

-- FICHIERS : { { chemin, classe, service, noms = {...} }, ... } fourni par banc.js
for _, f in ipairs(FICHIERS) do
	sources[f.chemin] = f.source
	local parent = banc.service(f.service)
	for i = 1, #f.noms - 1 do
		local n = f.noms[i]
		local e = parent:FindFirstChild(n)
		if not e then
			e = Instance.new("Folder")
			e.Name = n
			e.Parent = parent
		end
		parent = e
	end
	local s = banc.nouvelleInstance(f.classe)
	donnees[s].props.Name = f.noms[#f.noms]
	donnees[s].source = f.chemin
	s.Parent = parent
end

-- ===== outils du scénario =====
local rapport = { etapes = {}, controles = {} }
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local PPS = game:GetService("ProximityPromptService")

local function avancer(duree, chaque)
	__trace(string.format("t=%.1f avancer %.1f", banc.maintenant(), duree))
	local fin = banc.maintenant() + duree
	local dt = 0.1
	while banc.maintenant() < fin - 1e-9 do
		local t = banc.maintenant() + dt
		banc.obtenirSignal(RunService, "Stepped"):Fire(banc.maintenant(), dt)
		banc.obtenirSignal(RunService, "Heartbeat"):Fire(dt)
		if banc.joueurLocal then
			banc.obtenirSignal(RunService, "RenderStepped"):Fire(dt)
			banc.obtenirSignal(RunService, "PreRender"):Fire(dt)
			if banc.rendus then
				for _, r in pairs(banc.rendus) do
					banc.reprendre(banc.nouvelleCoroutine(r.fn, "client"), dt)
				end
			end
		end
		if chaque then chaque() end
		banc.avancerJusqua(t)
	end
end

local function controle(nom, ok, detail)
	table.insert(rapport.controles, { nom = nom, ok = ok and true or false, detail = detail and tostring(detail) or "" })
end

local function attributs(inst)
	local t = {}
	for k, v in pairs(inst:GetAttributes()) do
		if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then t[k] = v else t[k] = tostring(v) end
	end
	return t
end

local function textesVisibles(gui)
	local t = {}
	local function visible(o)
		local p = o
		while p and p ~= gui do
			if p:IsA("GuiObject") and not p.Visible then return false end
			if p:IsA("LayerCollector") and not p.Enabled then return false end
			p = p.Parent
		end
		return true
	end
	for _, o in ipairs(gui:GetDescendants()) do
		if (o:IsA("TextLabel") or o:IsA("TextButton")) and o.Text ~= "" and visible(o) then
			local texte = o.Text
			local fin = utf8.offset(texte, 61)
			if fin then texte = string.sub(texte, 1, fin - 1) end
			table.insert(t, o.Name .. "=" .. texte)
		end
	end
	return t
end

local function instantane(nom)
	local etat = ReplicatedStorage:FindFirstChild("ZsurvieEtat")
	local e = {
		nom = nom, t = banc.maintenant(),
		etat = etat and attributs(etat) or {},
		joueur = banc.joueurLocal and attributs(banc.joueurLocal) or {},
		zbires = 0,
		textes = {},
	}
	local racine = workspace:FindFirstChild("Zsurvie")
	local horde = racine and racine:FindFirstChild("Horde")
	if horde then e.zbires = #horde:GetChildren() end
	if banc.joueurLocal then
		local pg = banc.joueurLocal:FindFirstChild("PlayerGui")
		if pg then e.textes = textesVisibles(pg) end
		local ls = banc.joueurLocal:FindFirstChild("leaderstats")
		if ls then
			e.leaderstats = {}
			for _, v in ipairs(ls:GetChildren()) do e.leaderstats[v.Name] = tostring(v.Value) end
		end
	end
	table.insert(rapport.etapes, e)
	return e
end

local function commeClient(fn)
	banc.reprendre(banc.nouvelleCoroutine(fn, "client"))
end

local function zbirePlusProche(p)
	local racine = workspace:FindFirstChild("Zsurvie")
	local horde = racine and racine:FindFirstChild("Horde")
	if not horde then return nil end
	local meilleur, dm
	for _, z in ipairs(horde:GetChildren()) do
		if z:IsA("Model") then
			local ok, piv = pcall(function() return z:GetPivot() end)
			if ok then
				local d = (piv.Position - p).Magnitude
				if not dm or d < dm then meilleur, dm = z, d end
			end
		end
	end
	return meilleur, dm
end

local function deplacer(pos)
	local perso = banc.joueurLocal.Character
	perso:PivotTo(CFrame.new(pos))
end

local function invites(dossierNom, nomInvite)
	local racine = workspace:FindFirstChild("Zsurvie")
	local t = {}
	if not racine then return t end
	for _, o in ipairs(racine:GetDescendants()) do
		if o:IsA("ProximityPrompt") and (not nomInvite or o.Name == nomInvite) then
			if not dossierNom or o:IsDescendantOf(racine:FindFirstChild(dossierNom) or game) then table.insert(t, o) end
		end
	end
	return t
end

local function declencher(invite)
	local j = banc.joueurLocal
	local part = invite.Parent
	if part and part:IsA("BasePart") then deplacer(part.Position + v3(0, 3, 3)) end
	banc.obtenirSignal(invite, "Triggered"):Fire(j)
	commeClient(function() banc.obtenirSignal(PPS, "PromptTriggered"):Fire(invite, j) end)
end

-- ===== 1. démarrage du serveur =====
local sss = game:GetService("ServerScriptService")
local demarrage = sss:FindFirstChild("Zsurvie") and sss.Zsurvie:FindFirstChild("Demarrage")
if not demarrage then error("Demarrage introuvable") end
lancerScript(demarrage, "serveur")
avancer(3)

-- espionne le bus du serveur
local busServeur
do
	local modBus = ReplicatedStorage.Zsurvie:FindFirstChild("Bus")
	local co = banc.nouvelleCoroutine(function() busServeur = require(modBus) end, "serveur")
	banc.reprendre(co)
	if busServeur then
		local emettre = busServeur.emettre
		busServeur.emettre = function(nom, ...)
			banc.compter("bus:" .. tostring(nom))
			return emettre(nom, ...)
		end
	end
end
local function demanderServeur(nom, ...)
	local args = table.pack(...)
	local res
	banc.reprendre(banc.nouvelleCoroutine(function() res = table.pack(busServeur.demander(nom, table.unpack(args, 1, args.n))) end, "serveur"))
	return res and res[1]
end

local racine = workspace:FindFirstChild("Zsurvie")
controle("map construite", racine and racine:GetAttribute("Construit"), "")
rapport.parts = 0
rapport.dossiers = {}
if racine then
	for _, d in ipairs(racine:GetChildren()) do
		local parts = banc.partsDe(d)
		local info = { parts = #parts, instances = #d:GetDescendants() }
		local mn, mx = banc.boite(parts)
		if mn then info.min = { mn.X, mn.Y, mn.Z } info.max = { mx.X, mx.Y, mx.Z } end
		rapport.dossiers[d.Name] = info
		rapport.parts = rapport.parts + #parts
	end
end
local stockage = game:GetService("ServerStorage"):FindFirstChild("Zsurvie")
rapport.gabarits = {}
if stockage and stockage:FindFirstChild("Zbires") then
	for _, z in ipairs(stockage.Zbires:GetChildren()) do
		local info = { classe = z.ClassName, parts = #banc.partsDe(z) }
		if z:IsA("Model") then
			info.primaryPart = z.PrimaryPart and z.PrimaryPart.Name or "aucune"
			local ok, piv = pcall(function() return z:GetPivot() end)
			local mn, mx = banc.boite(banc.partsDe(z))
			if ok and mn then info.pivotY = piv.Position.Y info.basY = mn.Y info.hauteur = mx.Y - mn.Y end
			info.barre = z:FindFirstChild("Barre", true) ~= nil
		end
		rapport.gabarits[z.Name] = info
	end
end
instantane("serveur démarré")

-- ===== 2. un joueur rejoint =====
local j = banc.creerJoueur("Testeur", 1)
table.insert(banc.joueurs, j)
banc.joueurLocal = j
j.Parent = Players
local perso = j.Character
local spawn = nil
for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("SpawnLocation") then spawn = o break end end
controle("une SpawnLocation existe", spawn ~= nil, spawn and tostring(spawn.Position) or "")
if spawn then perso:PivotTo(CFrame.new(spawn.Position + v3(0, 4, 0))) end
perso.Parent = workspace
banc.obtenirSignal(Players, "PlayerAdded"):Fire(j)
banc.obtenirSignal(j, "CharacterAdded"):Fire(perso)
-- les scripts du joueur (copie de StarterPlayerScripts)
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
if sps then
	for _, e in ipairs(sps:GetChildren()) do
		local c = e:Clone()
		c.Parent = j.PlayerScripts
	end
	for _, s in ipairs(j.PlayerScripts:GetDescendants()) do
		if s.ClassName == "LocalScript" then lancerScript(s, "client") end
	end
end
avancer(6)
local lobby = instantane("joueur au lobby")
controle("données chargées", j:GetAttribute("DonneesChargees") == true, "")
controle("phase Lobby", lobby.etat.Phase == "Lobby", lobby.etat.Phase)
controle("interface créée", #lobby.textes > 0, #lobby.textes .. " textes visibles")

-- ===== 3. départ en capsule =====
local capsules = invites("QuaiCapsules")
controle("invites de capsule", #capsules > 0, #capsules)
if capsules[1] then declencher(capsules[1]) end
avancer(12)
local depart = instantane("départ de la run")
controle("run lancée (phase Horde)", depart.etat.Phase == "Horde", depart.etat.Phase)
controle("joueur EnRun", j:GetAttribute("EnRun") == true, tostring(j:GetAttribute("EnRun")))
local posDepart = perso:GetPivot().Position
controle("joueur téléporté sur la Prairie", posDepart.Magnitude < 150, tostring(posDepart))

-- ===== 4. combat =====
local camera = workspace.CurrentCamera
local tirs = 0
local function viser()
	local z = zbirePlusProche(perso:GetPivot().Position)
	if z then
		local cible = z:GetPivot().Position + v3(0, 1.5, 0)
		banc.souris.Hit = CFrame.new(cible)
		banc.souris.Target = z.PrimaryPart or z:FindFirstChildWhichIsA("BasePart")
		local pos = select(1, camera:WorldToViewportPoint(cible))
		banc.souris.X, banc.souris.Y = pos.X, pos.Y
		banc.souris.UnitRay = Ray.new(camera.CFrame.Position, (cible - camera.CFrame.Position).Unit)
	end
	return z
end
local function clic()
	local z = viser()
	if not z then return end
	commeClient(function()
		local entree = { UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.Begin,
			KeyCode = Enum.KeyCode.Unknown, Position = v3(banc.souris.X, banc.souris.Y, 0), Delta = Vector3.zero }
		banc.obtenirSignal(UIS, "InputBegan"):Fire(entree, false)
		banc.souris.Button1Down:Fire()
		for _, a in pairs(banc.actions) do
			banc.reprendre(banc.nouvelleCoroutine(a.fn, "client"), "action", Enum.UserInputState.Begin, entree)
		end
		local fin = { UserInputType = Enum.UserInputType.MouseButton1, UserInputState = Enum.UserInputState.End,
			KeyCode = Enum.KeyCode.Unknown, Position = v3(banc.souris.X, banc.souris.Y, 0), Delta = Vector3.zero }
		banc.obtenirSignal(UIS, "InputEnded"):Fire(fin, false)
		banc.souris.Button1Up:Fire()
	end)
end
local function tirDirect()
	local z = viser()
	if not z then return end
	tirs = tirs + 1
	local id = z:GetAttribute("Id")
	local cible = z:GetPivot().Position + v3(0, 1.5, 0)
	commeClient(function() ReplicatedStorage.ZsurvieReseau.Tirer:FireServer(cible, id) end)
end

-- 4a. 20 s de clics « réels » (teste Interface/Blaster)
deplacer(v3(0, 3, 30))
local avantClics = banc.compteurs["remote:Tirer"] or 0
local tc = 0
avancer(20, function()
	tc = tc + 1
	if tc % 3 == 0 then clic() end
end)
local tirsClient = (banc.compteurs["remote:Tirer"] or 0) - avantClics
controle("le Blaster client envoie des tirs", tirsClient > 0, tirsClient .. " tirs")

-- 4b. tirs directs + achats + réparation
local etabli = invites(nil, "Etabli")
controle("invite Etabli", #etabli > 0, #etabli)
avancer(10, function()
	tc = tc + 1
	if tc % 3 == 0 then tirDirect() end
end)
demanderServeur("AjouterPieces", j, 500)
if etabli[1] then declencher(etabli[1]) end
avancer(1)
local panneauEtabli = instantane("panneau Établi ouvert")
commeClient(function() ReplicatedStorage.ZsurvieReseau.Acheter:FireServer("Degats") end)
commeClient(function() ReplicatedStorage.ZsurvieReseau.Acheter:FireServer("Solidite") end)
avancer(1)
controle("achat Degats", (j:GetAttribute("Niv_Degats") or 0) >= 1, tostring(j:GetAttribute("Niv_Degats")))
controle("achat Solidite (PV max)", (ReplicatedStorage.ZsurvieEtat:GetAttribute("PVMaisonMax") or 0) > 400, tostring(ReplicatedStorage.ZsurvieEtat:GetAttribute("PVMaisonMax")))
commeClient(function() banc.obtenirSignal(game:GetService("UserInputService"), "InputBegan"):Fire({ UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.Escape, UserInputState = Enum.UserInputState.Begin, Position = Vector3.zero }, false) end)
deplacer(v3(0, 3, 12))
local pvAvant = ReplicatedStorage.ZsurvieEtat:GetAttribute("PVMaison")
for _ = 1, 3 do
	commeClient(function() ReplicatedStorage.ZsurvieReseau.Reparer:FireServer() end)
	avancer(0.5)
end
commeClient(function() ReplicatedStorage.ZsurvieReseau.Ping:FireServer("Aide !") end)
deplacer(v3(0, 3, 30))
local texteMilieu
avancer(90, function()
	tc = tc + 1
	if tc % 3 == 0 then tirDirect() end
	if not texteMilieu and banc.maintenant() > 90 then
		texteMilieu = instantane("milieu de run")
		if EXPORTER then EXPORTER("pendant") end
	end
end)
local combat = instantane("après 2 minutes de combat")
controle("des Zbires sont apparus", (banc.compteurs["bus:ZbireApparu"] or 0) > 0, banc.compteurs["bus:ZbireApparu"] or 0)
controle("des Zbires ont été vaincus", (banc.compteurs["bus:ZbireVaincu"] or 0) > 0, banc.compteurs["bus:ZbireVaincu"] or 0)
controle("le joueur gagne des pièces", (banc.compteurs["bus:PiecesGagnees"] or 0) > 0, banc.compteurs["bus:PiecesGagnees"] or 0)
controle("la Maison subit des dégâts", (banc.compteurs["bus:DegatsMaison"] or 0) > 0, banc.compteurs["bus:DegatsMaison"] or 0)
controle("au moins un jour passé", (combat.etat.Jour or 0) >= 2, combat.etat.Jour)
controle("la Mine produit des gemmes", (banc.compteurs["bus:GemmesGagnees"] or 0) > 0, banc.compteurs["bus:GemmesGagnees"] or 0)
controle("réparation (SoinMaison)", (banc.compteurs["bus:SoinMaison"] or 0) > 0, pvAvant)

-- ===== 5. défaite =====
local gemmesAvant = j:GetAttribute("Gemmes") or 0
banc.reprendre(banc.nouvelleCoroutine(function() busServeur.emettre("DegatsMaison", 100000) end, "serveur"))
avancer(15)
local defaite = instantane("après la chute de la Maison")
controle("MaisonTombee émis", (banc.compteurs["bus:MaisonTombee"] or 0) > 0, "")
controle("retour au Lobby", defaite.etat.Phase == "Lobby", defaite.etat.Phase)
controle("joueur plus EnRun", j:GetAttribute("EnRun") ~= true, "")
controle("gemmes de fin de run", (j:GetAttribute("Gemmes") or 0) > gemmesAvant, gemmesAvant .. " -> " .. tostring(j:GetAttribute("Gemmes")))
controle("joueur revenu sur l'île", (perso:GetPivot().Position - v3(0, 0, 600)).Magnitude < 90, tostring(perso:GetPivot().Position))
controle("Horde vidée", defaite.zbires == 0, defaite.zbires)

-- ===== 6. recherche au Laboratoire =====
demanderServeur("AjouterGemmes", j, 200, "test")
local arbre = invites(nil, "ArbreRecherches")
controle("invite ArbreRecherches", #arbre > 0, #arbre)
if arbre[1] then declencher(arbre[1]) end
avancer(1)
instantane("panneau Recherches ouvert")
commeClient(function() ReplicatedStorage.ZsurvieReseau.Rechercher:FireServer("TourelleToit") end)
avancer(1)
controle("recherche TourelleToit", j:GetAttribute("Rech_TourelleToit") == true, tostring(j:GetAttribute("Rech_TourelleToit")))

-- ===== 7. deuxième run avec la tourelle =====
capsules = invites("QuaiCapsules")
if capsules[1] then declencher(capsules[1]) end
local degatsAvant = banc.compteurs["bus:DegatsZbire"] or 0
avancer(45)
local run2 = instantane("deuxième run")
controle("deuxième run lancée", run2.etat.Phase == "Horde" or run2.etat.Phase == "Repit", run2.etat.Phase)
controle("dégâts sans tir du joueur (tourelle)", (banc.compteurs["bus:DegatsZbire"] or 0) > degatsAvant, (banc.compteurs["bus:DegatsZbire"] or 0) - degatsAvant)
if EXPORTER then EXPORTER("fin") end

-- ===== rapport =====
rapport.erreurs = banc.erreurs
rapport.avertissements = banc.avertissements
rapport.sorties = banc.sorties
rapport.attentes = banc.attentes
rapport.inconnus = banc.inconnus
rapport.compteurs = banc.compteurs
rapport.sons = banc.sons or 0
rapport.particules = banc.particules or 0
rapport.tempsSimule = banc.maintenant()
rapport.remplissagesTerrain = #banc.remplissages
return banc.json(rapport)
