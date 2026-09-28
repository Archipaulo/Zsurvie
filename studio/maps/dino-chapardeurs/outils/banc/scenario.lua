-- Banc d'essai Dino Chapardeurs : charge le projet, simule un joueur qui fait une partie complète, et produit un rapport.
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
	local etat = ReplicatedStorage:FindFirstChild("DinoEtat")
	local e = {
		nom = nom, t = banc.maintenant(),
		etat = etat and attributs(etat) or {},
		joueur = banc.joueurLocal and attributs(banc.joueurLocal) or {},
		dinos = 0,
		textes = {},
	}
	local racine = workspace:FindFirstChild("Dino")
	local horde = racine and racine:FindFirstChild("Dinos")
	if horde then e.dinos = #horde:GetChildren() end
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

-- ===== outils propres à Dino Chapardeurs =====
local PPS = game:GetService("ProximityPromptService")
local Reseau = function() return ReplicatedStorage:WaitForChild("DinoReseau") end
local E -- Equilibrage (côté serveur)
local busServeur

local function serveur(fn)
	banc.reprendre(banc.nouvelleCoroutine(fn, "serveur"))
end
local function demander(nom, ...)
	local args = table.pack(...)
	local res
	serveur(function() res = table.pack(busServeur.demander(nom, table.unpack(args, 1, args.n))) end)
	return res and res[1]
end
local function racineJeu() return workspace:FindFirstChild("Dino") end
local function dinosDe(j)
	local t = {}
	local d = racineJeu() and racineJeu():FindFirstChild("Dinos")
	if not d then return t end
	for _, m in ipairs(d:GetChildren()) do
		if m:GetAttribute("Proprietaire") == j.UserId then table.insert(t, m) end
	end
	return t
end
local function dinosEtat(etat)
	local t = {}
	local d = racineJeu() and racineJeu():FindFirstChild("Dinos")
	if not d then return t end
	for _, m in ipairs(d:GetChildren()) do
		if m:GetAttribute("Etat") == etat then table.insert(t, m) end
	end
	return t
end
local function baseModele(j)
	local b = racineJeu() and racineJeu():FindFirstChild("Bases")
	local i = j:GetAttribute("Base")
	return b and i and b:FindFirstChild("Base" .. tostring(i))
end
local function inviteSur(inst, nom)
	if not inst then return nil end
	for _, o in ipairs(inst:GetDescendants()) do
		if o:IsA("ProximityPrompt") and o.Name == nom then return o end
	end
	return nil
end
local function placer(j, pos, regard)
	local perso = j.Character
	if regard then perso:PivotTo(CFrame.lookAt(pos, regard)) else perso:PivotTo(CFrame.new(pos)) end
end
-- un joueur active une invite (le client local reçoit aussi l'événement s'il s'agit de lui)
local function activer(invite, j)
	if not invite then return end
	local part = invite.Parent
	if part and part:IsA("BasePart") then placer(j, part.Position + v3(0, 3, 4)) end
	banc.obtenirSignal(invite, "Triggered"):FireCote("serveur", j)
	banc.obtenirSignal(PPS, "PromptTriggered"):FireCote("serveur", invite, j)
	if j == banc.joueurLocal then
		banc.obtenirSignal(PPS, "PromptTriggered"):FireCote("client", invite, j)
	end
end
local function compteur(nom) return banc.compteurs["bus:" .. nom] or 0 end

-- ===== 1. démarrage du serveur =====
local sss = game:GetService("ServerScriptService")
local demarrage = sss:FindFirstChild("Dino") and sss.Dino:FindFirstChild("Demarrage")
if not demarrage then error("Demarrage introuvable") end
lancerScript(demarrage, "serveur")
avancer(3)
serveur(function()
	busServeur = require(ReplicatedStorage.Dino.Bus)
	E = require(ReplicatedStorage.Dino.Equilibrage)
end)
local emettre = busServeur.emettre
busServeur.emettre = function(nom, ...)
	banc.compter("bus:" .. tostring(nom))
	return emettre(nom, ...)
end

local racine = racineJeu()
controle("monde construit", racine and racine:GetAttribute("Construit"), "")
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
local stock = game:GetService("ServerStorage"):FindFirstChild("Dino")
local nbGabarits = 0
rapport.gabarits = {}
if stock and stock:FindFirstChild("Dinos") then
	for _, g in ipairs(stock.Dinos:GetChildren()) do
		nbGabarits = nbGabarits + 1
		local mn, mx = banc.boite(banc.partsDe(g))
		local ok, piv = pcall(function() return g:GetPivot() end)
		rapport.gabarits[g.Name] = { parts = #banc.partsDe(g), primaryPart = g.PrimaryPart and g.PrimaryPart.Name or "aucune",
			basY = mn and mn.Y, pivotY = ok and piv.Position.Y or nil, taille = mn and { mx.X - mn.X, mx.Y - mn.Y, mx.Z - mn.Z } }
	end
end
controle("20 gabarits de dinos", nbGabarits == 20, nbGabarits)
local bases = racine and racine:FindFirstChild("Bases")
local nbBasesOk = 0
if bases then
	for i = 1, 8 do
		local b = bases:FindFirstChild("Base" .. i)
		local ok = b ~= nil
		if b then
			for _, n in ipairs({ "Sol", "Zone", "Entree", "BoutonVerrou", "Collecte", "Emplacements", "Enseigne", "Apparition" }) do
				if not b:FindFirstChild(n) then ok = false end
			end
			if not (b:FindFirstChild("Emplacements") and b.Emplacements:FindFirstChild("E12")) then ok = false end
			if not inviteSur(b, "Verrouiller") then ok = false end
		end
		if ok then nbBasesOk = nbBasesOk + 1 end
	end
end
controle("8 bases conformes", nbBasesOk == 8, nbBasesOk)
local nbSpawn = 0
for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("SpawnLocation") then nbSpawn = nbSpawn + 1 end end
controle("une seule SpawnLocation", nbSpawn == 1, nbSpawn)
for _, n in ipairs({ "Boutique", "Renaissance", "Index" }) do
	controle("invite « " .. n .. " »", inviteSur(racine, n) ~= nil, "")
end
instantane("serveur démarré")

-- ===== 2. deux joueurs arrivent : Testeur (avec client) et Voleur (sans client) =====
local A = banc.creerJoueur("Testeur", 1)
local B = banc.creerJoueur("Voleur", 2)
for _, j in ipairs({ A, B }) do
	table.insert(banc.joueurs, j)
	j.Parent = Players
	j.Character.Parent = workspace
end
banc.joueurLocal = A
banc.obtenirSignal(Players, "PlayerAdded"):Fire(A)
banc.obtenirSignal(A, "CharacterAdded"):Fire(A.Character)
banc.obtenirSignal(Players, "PlayerAdded"):FireCote("serveur", B)
banc.obtenirSignal(B, "CharacterAdded"):FireCote("serveur", B.Character)
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
if sps then
	for _, e in ipairs(sps:GetChildren()) do e:Clone().Parent = A.PlayerScripts end
	for _, s in ipairs(A.PlayerScripts:GetDescendants()) do
		if s.ClassName == "LocalScript" then lancerScript(s, "client") end
	end
end
avancer(8)
local arrivee = instantane("joueurs arrivés")
controle("bases attribuées", A:GetAttribute("Base") and B:GetAttribute("Base") and A:GetAttribute("Base") ~= B:GetAttribute("Base"),
	tostring(A:GetAttribute("Base")) .. " / " .. tostring(B:GetAttribute("Base")))
controle("données chargées", A:GetAttribute("DonneesChargees") == true and B:GetAttribute("DonneesChargees") == true, "")
controle("argent de départ (+ bonus de connexion)", (A:GetAttribute("Argent") or 0) >= E.argentDepart, tostring(A:GetAttribute("Argent")))
controle("batte dans le sac", A.Backpack:FindFirstChild("Batte") ~= nil or A.Character:FindFirstChild("Batte") ~= nil, "")
local bA, bB = baseModele(A), baseModele(B)
controle("apparition dans sa base", bA and bA:FindFirstChild("Apparition") and (A.Character:GetPivot().Position - bA.Apparition.Position).Magnitude < 12,
	tostring(A.Character:GetPivot().Position))
controle("enseigne au nom du joueur", bA and bA:FindFirstChild("Enseigne") and bA.Enseigne:FindFirstChild("Titre", true)
	and string.find(bA.Enseigne:FindFirstChild("Titre", true).Text, "Testeur") ~= nil, "")
controle("interface créée", #arrivee.textes > 0, #arrivee.textes .. " textes")

-- ===== 3. le Tapis =====
avancer(10)
local surTapis = dinosEtat("Tapis")
controle("des dinos défilent sur le Tapis", #surTapis >= 3, #surTapis)
local xAvant = surTapis[1] and surTapis[1]:GetPivot().Position.X
avancer(1)
controle("les dinos avancent", surTapis[1] and surTapis[1].Parent and surTapis[1]:GetPivot().Position.X > xAvant, "")
controle("étiquette et invite Acheter", surTapis[1] and surTapis[1]:FindFirstChild("Etiquette", true) ~= nil and inviteSur(surTapis[1], "Acheter") ~= nil, "")

-- ===== 4. achats =====
demander("AjouterArgent", A, 1000000, "test")
local achetes = {}
for k = 1, 3 do
	local cible = nil
	for _, d in ipairs(dinosEtat("Tapis")) do
		if inviteSur(d, "Acheter") and d:GetPivot().Position.X < 60 then cible = d break end
	end
	if cible then
		activer(inviteSur(cible, "Acheter"), A)
		table.insert(achetes, cible)
	end
	avancer(0.5)
end
controle("achat : le dino part vers la base", achetes[1] and (achetes[1]:GetAttribute("Etat") == "EnRoute" or achetes[1]:GetAttribute("Etat") == "Enclos"), achetes[1] and achetes[1]:GetAttribute("Etat"))
avancer(25)
local enclos = 0
for _, d in ipairs(dinosDe(A)) do if d:GetAttribute("Etat") == "Enclos" then enclos = enclos + 1 end end
controle("3 dinos installés dans la base", enclos == 3, enclos)
controle("revenu par seconde", (A:GetAttribute("RevenuParSeconde") or 0) > 0, tostring(A:GetAttribute("RevenuParSeconde")))
controle("Dinodex : espèce découverte", achetes[1] and A:GetAttribute("Index_" .. tostring(achetes[1]:GetAttribute("Espece"))) == true, "")
-- pour les photos : quelques dinos de plus dans la base de Testeur (les deux rangées face à face)
for _, espece in ipairs({ "Rex", "Tricera", "Stego", "Raptor", "Ankylo" }) do
	serveur(function()
		local d = busServeur.demander("CreerDino", espece, "Normal")
		local n = busServeur.demander("ReserverEmplacement", A)
		if d and n then busServeur.demander("PlacerDino", d, A, n) end
	end)
end
avancer(0.5)
-- chaque dino de la base a les pieds posés sur son podium (bas du modèle au niveau du plateau, centre au-dessus)
do
	local malPoses, verifies = {}, 0
	for _, d in ipairs(dinosDe(A)) do
		if d:GetAttribute("Etat") == "Enclos" and bA then
			local plaque = bA.Emplacements:FindFirstChild("E" .. tostring(d:GetAttribute("Emplacement")))
			local mn, mx = banc.boite(banc.partsDe(d))
			if plaque and mn then
				verifies = verifies + 1
				local dessus = plaque.Position.Y + plaque.Size.Y / 2
				local centre = (mn + mx) / 2
				local l = plaque.CFrame:PointToObjectSpace(centre)
				local surLePlateau = math.abs(mn.Y - dessus) < 0.15
				local auDessus = math.abs(l.X) <= plaque.Size.X / 2 and math.abs(l.Z) <= plaque.Size.Z / 2
				if not (surLePlateau and auDessus) then
					table.insert(malPoses, d:GetAttribute("Espece") .. string.format(" (écart vertical %.2f)", mn.Y - dessus))
				end
			end
		end
	end
	controle("dinos posés sur leur podium", verifies > 0 and #malPoses == 0, verifies .. " vérifiés " .. table.concat(malPoses, ", "))
end
if EXPORTER then EXPORTER("pendant") end
-- vitrine (photos des modeleurs) : un exemplaire de chaque gabarit aligné en l'air (y = 60) au-dessus de la Place, par rareté
if EXPORTER and stock and stock:FindFirstChild("Dinos") then
	local vitrine = Instance.new("Folder")
	vitrine.Name = "Vitrine"
	vitrine.Parent = racineJeu()
	local liste = stock.Dinos:GetChildren()
	local ordre = { Commun = 1, Rare = 2, Epique = 3, Legendaire = 4, Mythique = 5, Divin = 6, Secret = 7 }
	table.sort(liste, function(a, b)
		local ea, eb = E.especes[a.Name], E.especes[b.Name]
		local ra, rb = ea and ordre[ea.rarete] or 9, eb and ordre[eb.rarete] or 9
		if ra ~= rb then return ra < rb end
		return a.Name < b.Name
	end)
	local socle = Instance.new("Part")
	socle.Name = "Socle"
	socle.Anchored = true
	socle.Size = Vector3.new(420, 1, 40)
	socle.CFrame = CFrame.new(100, 59.5, 100)
	socle.Color = Color3.fromRGB(110, 200, 90)
	socle.Parent = vitrine
	local x = -95
	for i, g in ipairs(liste) do
		local c = g:Clone()
		local ok, _, taille = pcall(function() return c:GetBoundingBox() end)
		local largeur = ok and math.max(taille.X, 4) or 8
		c.Parent = vitrine
		pcall(function() c:PivotTo(CFrame.new(x + largeur / 2, 60, 100) * CFrame.Angles(0, math.rad(180 + 55), 0)) end)
		x = x + largeur + 3
	end
	EXPORTER("vitrine")
	vitrine:Destroy()
end

-- ===== 5. collecte =====
avancer(8)
local stockAvant = 0
for _, d in ipairs(dinosDe(A)) do stockAvant = stockAvant + (d:GetAttribute("Stock") or 0) end
controle("l'argent s'accumule", stockAvant > 0, stockAvant)
local argentAvant = A:GetAttribute("Argent") or 0
if bA and bA:FindFirstChild("Collecte") then
	placer(A, bA.Collecte.Position + v3(0, 3, 0))
	banc.obtenirSignal(bA.Collecte, "Touched"):FireCote("serveur", A.Character.HumanoidRootPart)
end
avancer(1)
commeClient(function() Reseau().Collecter:FireServer() end)
avancer(1)
if EXPORTER_UI then EXPORTER_UI("hud") end
controle("collecte encaissée", (A:GetAttribute("Argent") or 0) > argentAvant, argentAvant .. " -> " .. tostring(A:GetAttribute("Argent")))

-- ===== 6. vol réussi =====
local proie = nil
for _, d in ipairs(dinosDe(A)) do if d:GetAttribute("Etat") == "Enclos" then proie = d break end end
if proie then
	placer(B, proie:GetPivot().Position + v3(0, 3, 3))
	activer(inviteSur(proie, "Voler"), B)
end
avancer(0.5)
if EXPORTER_UI then EXPORTER_UI("alerte-vol") end
controle("vol : le dino est porté", proie and proie:GetAttribute("Etat") == "Porte" and B:GetAttribute("Porte") == proie:GetAttribute("Id"),
	proie and tostring(proie:GetAttribute("Etat")))
local zoneB = bB and bB:FindFirstChild("Zone")
if zoneB then
	placer(B, (proie and proie:GetPivot().Position or zoneB.Position) + v3(0, 3, 0))
	avancer(0.5)
	placer(B, zoneB.Position + v3(0, -zoneB.Size.Y / 2 + 4, 0))
end
avancer(3)
controle("vol livré chez le voleur", proie and proie:GetAttribute("Proprietaire") == B.UserId and proie:GetAttribute("Etat") == "Enclos",
	proie and (tostring(proie:GetAttribute("Proprietaire")) .. " " .. tostring(proie:GetAttribute("Etat"))))
controle("compteur de vols", (B:GetAttribute("Vols") or 0) == 1, tostring(B:GetAttribute("Vols")))
controle("porteur libéré", (B:GetAttribute("Porte") or "") == "", tostring(B:GetAttribute("Porte")))

-- ===== 7. la batte fait lâcher le butin =====
local proie2 = nil
for _, d in ipairs(dinosDe(A)) do if d:GetAttribute("Etat") == "Enclos" then proie2 = d break end end
if proie2 then
	placer(B, proie2:GetPivot().Position + v3(0, 3, 3))
	activer(inviteSur(proie2, "Voler"), B)
	avancer(0.5)
	local pB = B.Character:GetPivot().Position
	placer(A, pB + v3(0, 0, 4), pB)
	avancer(0.2)
	commeClient(function() Reseau().Frapper:FireServer() end)
	avancer(2)
end
controle("frappe enregistrée", compteur("Frappe") > 0, compteur("Frappe"))
controle("vol raté : le dino rentre chez sa victime", proie2 and proie2:GetAttribute("Proprietaire") == A.UserId and proie2:GetAttribute("Etat") == "Enclos",
	proie2 and (tostring(proie2:GetAttribute("Proprietaire")) .. " " .. tostring(proie2:GetAttribute("Etat"))))
avancer(3)

-- ===== 8. le verrou protège la base =====
activer(bA and inviteSur(bA, "Verrouiller"), A)
avancer(0.5)
controle("base verrouillée", bA and bA:GetAttribute("Verrouillee") == true, "")
local proie3 = nil
for _, d in ipairs(dinosDe(A)) do if d:GetAttribute("Etat") == "Enclos" then proie3 = d break end end
if proie3 then
	placer(B, proie3:GetPivot().Position + v3(0, 3, 3))
	activer(inviteSur(proie3, "Voler"), B)
end
avancer(1.5)
controle("vol refusé quand la base est verrouillée", proie3 and proie3:GetAttribute("Etat") == "Enclos" and proie3:GetAttribute("Proprietaire") == A.UserId, "")
local dedans = demander("DansBase", B.Character:GetPivot().Position, A:GetAttribute("Base"))
controle("intrus expulsé de la base verrouillée", dedans == false, tostring(dedans))

-- ===== 9. boutique, vente, événement, panneaux =====
commeClient(function() Reseau().Acheter:FireServer("Bottes") end)
avancer(1)
controle("objet acheté (Bottes)", A:GetAttribute("Objet_Bottes") == true, "")
controle("bottes : vitesse augmentée", (A.Character.Humanoid.WalkSpeed or 0) > 16, tostring(A.Character.Humanoid.WalkSpeed))
local nAvant = #dinosDe(A)
local vendu = nil
for _, d in ipairs(dinosDe(A)) do if d:GetAttribute("Etat") == "Enclos" then vendu = d break end end
argentAvant = A:GetAttribute("Argent") or 0
activer(vendu and inviteSur(vendu, "Vendre"), A)
avancer(1)
controle("vente d'un dino", #dinosDe(A) == nAvant - 1 and (A:GetAttribute("Argent") or 0) > argentAvant, nAvant .. " -> " .. #dinosDe(A))
local lance = demander("LancerEvenement", "PluieDeMeteores")
avancer(6)
controle("événement lancé", ReplicatedStorage.DinoEtat:GetAttribute("Evenement") == "PluieDeMeteores", tostring(lance))
activer(inviteSur(racine, "Boutique"), A)
avancer(0.5)
local panneau = instantane("panneau Boutique ouvert")
if EXPORTER_UI then EXPORTER_UI("boutique") end
local vuBottes = false
for _, t in ipairs(panneau.textes) do if string.find(t, "Bottes") then vuBottes = true end end
controle("panneau Boutique affiché", vuBottes, #panneau.textes .. " textes")
activer(inviteSur(racine, "Index"), A)
avancer(0.5)
instantane("panneau Dinodex ouvert")
if EXPORTER_UI then EXPORTER_UI("dinodex") end
activer(inviteSur(racine, "Renaissance"), A)
avancer(0.5)
if EXPORTER_UI then EXPORTER_UI("renaissance") end

-- ===== 10. renaissance =====
demander("AjouterArgent", A, E.coutRenaissance(0) + 10, "test")
commeClient(function() Reseau().Renaissance:FireServer() end)
avancer(2)
controle("renaissance", A:GetAttribute("Renaissances") == 1, tostring(A:GetAttribute("Renaissances")))
controle("argent remis à zéro", A:GetAttribute("Argent") == E.argentDepart, tostring(A:GetAttribute("Argent")))
controle("base vidée", #dinosDe(A) == 0, #dinosDe(A))
if EXPORTER then EXPORTER("fin") end

-- ===== 11. départ d'un joueur =====
banc.obtenirSignal(Players, "PlayerRemoving"):FireCote("serveur", B)
for i, j in ipairs(banc.joueurs) do if j == B then table.remove(banc.joueurs, i) break end end
B.Parent = nil
avancer(4)
controle("base libérée au départ", bB and (bB:GetAttribute("Proprietaire") or 0) == 0, bB and tostring(bB:GetAttribute("Proprietaire")))
local sauvegardes = 0
for nom, contenu in pairs(banc.magasins) do for _ in pairs(contenu) do sauvegardes = sauvegardes + 1 end end
controle("progression sauvegardée", sauvegardes > 0, sauvegardes)
instantane("fin")

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
