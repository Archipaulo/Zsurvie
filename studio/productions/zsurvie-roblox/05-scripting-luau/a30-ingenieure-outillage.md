## Livré le 29/09, avant tout le reste

| Livrable | Emplacement Roblox | Fichier |
|---|---|---|
| Module **Charte** | `ReplicatedStorage.Charte`, Package `AutoUpdate` dans les 2 places | `scripts/a30/Charte.lua` |
| **Auditeur Pixel-bloc v2** | Plugin local, barre **Zsurvie Outillage** | `scripts/a30/AuditeurPixelBloc.server.lua` |
| **Forge à Zbires**, **Semeur de Prairie** | Même barre | Spécifiés ci-dessous |

## Écart déclaré à Victor Lanoue : noms d'instances sans accents

Les noms d'**instances** sont en ASCII, sans accent ni espace, car ils sont tapés dans le code (`FindFirstChild`, attributs, tags) : `Lisiere`, `Etabli`, `Dore`, `Casque`, `MiniGluant`, `GalerieZbires`, `TerreBattue`, `Creme`, `Lumiere`. Tout texte vu par le joueur (`TextLabel`, `BillboardGui`, Roue des Pings) garde l'orthographe du canon : « Lisière », « Doré », « Casqué », « Mini-Gluant ».

## Conventions communes

- **Nommage** `Zone_Objet_NN` : `Prairie_Botte_07`, `Lisiere_Portail_03`.
- **Place Prairie** : `Workspace.Maison` (Model), `Mine`, `Prairie`, `Lisiere`, `Decor.<Zone>`, `Runtime` (vide en édition) ; `ReplicatedStorage.Charte`, `ReplicatedStorage.Modeles.Zbires` ; `ServerStorage.Prefabs.Decor`, `ServerStorage.Outillage.Gabarit`.
- **Gabarit** (`Configuration` tenue par a11, dans les 2 places) : attribut `PartsStatiques` (6 500 en Prairie) et un attribut `Neon_<Zone>` par zone (`Neon_Lisiere`, `Neon_Mine`…), total ≤ 150. Une zone est un enfant de `Workspace` ou de `Workspace.Decor` ; une zone sans attribut a droit à 0 Neon.

## Module `ReplicatedStorage.Charte`

- **API complète et figée** : `Charte.Couleurs.<Nom>` (11 `Color3`), `Charte.teinte(nom, "Base" | "Ombre" | "Lumiere")`, `Charte.Interface`, `Charte.Ambiances`. Rien d'autre : `Palette`, `couleur()` ou `Gemme.Lumiere` lèvent « Charte.Palette n'existe pas » dès le premier test.
- **Un seul chargement** : `require(ReplicatedStorage:WaitForChild("Charte"))`, jamais de `require` relatif.
- **Propriétaires** : a31 règle les valeurs d'`Interface`, l'éclairage celles d'`Ambiances`. Toute nouvelle clé passe par moi, car l'Auditeur vérifie la forme exacte du module.

```lua
-- Emplacement Roblox : ReplicatedStorage > ModuleScript « Charte » (Package AutoUpdate, Laboratoire et Prairie)
-- Charte Pixel-bloc de Zsurvie : seule source des couleurs, de l'interface et des ambiances.
-- Chargement unique : require(game:GetService("ReplicatedStorage"):WaitForChild("Charte"))
export type Variante = "Base" | "Ombre" | "Lumiere"

local Couleurs = {
	Encre = Color3.fromHex("1E1B2E"),
	Prairie = Color3.fromHex("6CC24A"),
	TerreBattue = Color3.fromHex("C8894F"),
	Creme = Color3.fromHex("F6E7C1"),
	ToitOrange = Color3.fromHex("EF7A2F"),
	Or = Color3.fromHex("FFC933"),
	GemmeCyan = Color3.fromHex("33D6F0"),
	VioletHorde = Color3.fromHex("9B5DE5"),
	Alerte = Color3.fromHex("FF2E63"),
	NuitLabo = Color3.fromHex("2A3263"),
	Ardoise = Color3.fromHex("4A4560"),
}

-- 33 teintes : ombre = base × 0,8 ; lumière = base:Lerp(Creme, 0.2)
local teintes = {}
for nom, base in Couleurs do
	teintes[nom] = {
		Base = base,
		Ombre = Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8),
		Lumiere = base:Lerp(Couleurs.Creme, 0.2),
	}
end

local function teinte(nom: string, variante: Variante): Color3
	local c = teintes[nom] and teintes[nom][variante]
	if not c then
		error(("Charte.teinte : %s/%s inconnue"):format(tostring(nom), tostring(variante)), 2)
	end
	return c
end

-- Interface : valeurs tenues par a31
local Interface = {
	BoutonMin = 60, -- px, minimum canon sur téléphone
	Fond = teinte("NuitLabo", "Base"),
	Panneau = teinte("Creme", "Base"),
	Texte = teinte("Encre", "Base"),
	Action = teinte("ToitOrange", "Base"),
	ActionAppui = teinte("ToitOrange", "Ombre"),
	Pieces = teinte("Or", "Base"),
	Gemmes = teinte("GemmeCyan", "Base"),
	Danger = teinte("Alerte", "Base"),
}

-- Ambiances : propriétés de Lighting appliquées telles quelles ; caméras Scriptable levées
local Ambiances = {
	Laboratoire = {
		ClockTime = 0,
		Brightness = 1,
		Ambient = teinte("NuitLabo", "Lumiere"),
		OutdoorAmbient = teinte("NuitLabo", "Base"),
	},
	Cameras = {
		Prairie = { Decalage = Vector3.new(0, 45, 28), FieldOfView = 50 }, -- canon
		Colosse = { Decalage = Vector3.new(0, 56, 35), FieldOfView = 50 }, -- + 25 % le Jour du Colosse
	},
}

-- Gel récursif ; lire une clé absente (une ancienne API par exemple) lève une erreur explicite
local function geler(t: { [any]: any }, chemin: string)
	for cle, v in t do
		if type(v) == "table" then geler(v, chemin .. "." .. tostring(cle)) end
	end
	setmetatable(t, {
		__index = function(_, cle)
			error(("%s.%s n'existe pas"):format(chemin, tostring(cle)), 2)
		end,
	})
	return table.freeze(t)
end

return geler({ Couleurs = Couleurs, teinte = teinte, Interface = Interface, Ambiances = Ambiances }, "Charte")
```

## Outil 1 : Auditeur Pixel-bloc v2 (le plus utile)

Il protège les 30 FPS de l'Android 3 Go dès la phase 1 : un Neon de trop, un arbre de 9 studs devant la Maison ou un Zbire manquant (qui sortirait en cube provisoire) sont repérés le jour même.

| Contrôle bloquant | Seuil | Place |
|---|---|---|
| Charte | 4 clés, 11 couleurs du canon, `teinte` exacte | Les 2 |
| Parts statiques | 6 500 (Gabarit de a11, jamais relevé) ; Laboratoire 10 000 | Les 2 |
| Pic de horde | statique + 60 × pire Zbire + 30 (Colosse) + 450 (défenses) + 240 (avatars) + 300 (pièces, effets) ≤ 10 000 | Prairie |
| Neon | 150 au total et `Neon_<Zone>` du Gabarit | Les 2 |
| Lumières | 12, toutes classes (`PointLight`, `SpotLight`, `SurfaceLight`) | Les 2 |
| `ParticleEmitter` | 24 `Enabled` au plus ; `Rate` ≤ 20 (corrigeable) | Les 2 |
| Terrain | `workspace.Terrain:CountCells()` = 0 | Les 2 |
| Couleurs, matériaux | 33 teintes (corrigeable) ; `SmoothPlastic` ≥ 90 % | Les 2 |
| Zbires | 10 types dans `ReplicatedStorage.Modeles.Zbires`, format Forge ; ancien `ReplicatedStorage.Zbires` absent | Les 2 |
| Lisibilité | rien au-dessus de 6 studs à moins de 60 studs de la Maison (Maison exemptée) | Prairie |
| Arène | ± 110 studs ; Parts taguées `HorsArene`, sur elles ou un ancêtre (Canopée de a16) : ± 150 | Prairie |
| Streaming | `StreamingEnabled` = false | Prairie |

Seul avertissement : `Modeles.Zbires` en Package `AutoUpdate`. **Pic attendu** : 6 500 + 60 × 6 + 1 020 = **7 880 Parts**, 2 120 de marge (l'ancienne version, à 7 500 statiques, dépassait 10 000 avec les avatars). **Profil** : `Workspace.Maison` présent = Prairie, sinon Laboratoire.

**Usage**
1. **Auditer** (mode édition) : rapport dans l'Output, KO en orange, fautifs sélectionnés (`F` pour cadrer).
2. **Corriger** : couleurs et `Rate` du dernier audit, une étape annulable (`Ctrl+Z`).
3. Relancer jusqu'à « 0 bloquant », coller le rapport dans le message de commit.

**Installation** : coller le script dans un `Script` de `ServerStorage`, clic droit > *Save as Local Plugin…*

```lua
-- Emplacement Roblox : plugin local Studio (dossier Plugins), Script « AuditeurPixelBloc »
-- Auditeur Pixel-bloc v2 (Zsurvie) : Charte, budgets du canon et Zbires ; « Corriger » recale couleurs et Rate.
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local B = { PartsPrairie = 6500, PartsLabo = 10000, PartsArene = 10000, Neon = 150, Lumieres = 12, Rate = 20,
	Emetteurs = 24, Smooth = 0.9, Hauteur = 6, Rayon = 60, DemiArene = 110, DemiCadre = 150, Horde = 60,
	PartsZbire = 6, PartsColosse = 30, NeonColosse = 4,
	Reserve = 30 + 450 + 240 + 300 } -- Colosse, défenses, avatars, pièces et effets
local TYPES = { "Marcheur", "Rapide", "Costaud", "Dore", "Sauteur", "Gluant", "MiniGluant", "Volant", "Casque", "Colosse" }
local CANON = { Encre = "1E1B2E", Prairie = "6CC24A", TerreBattue = "C8894F", Creme = "F6E7C1", ToitOrange = "EF7A2F",
	Or = "FFC933", GemmeCyan = "33D6F0", VioletHorde = "9B5DE5", Alerte = "FF2E63", NuitLabo = "2A3263", Ardoise = "4A4560" }
local API = { Couleurs = "table", teinte = "function", Interface = "table", Ambiances = "table" }
local TOLERANCE = 0.0003 -- écart RVB² toléré (arrondi Color3uint8)
local CREME = Color3.fromHex(CANON.Creme)
local dernier = { couleurs = {}, emetteurs = {} }

local function ombre(c: Color3): Color3
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end

local TEINTES = {} -- 33 teintes autorisées : base, ombre (× 0,8), lumière (Lerp Crème 0,2)
for _, hex in CANON do
	local c = Color3.fromHex(hex)
	table.insert(TEINTES, c)
	table.insert(TEINTES, ombre(c))
	table.insert(TEINTES, c:Lerp(CREME, 0.2))
end

-- ReplicatedStorage.Charte : 4 clés exactement, 11 couleurs du canon, teinte() exacte
local function charteConforme(): boolean
	local module = ReplicatedStorage:FindFirstChild("Charte")
	if not (module and module:IsA("ModuleScript")) then return false end
	local copie = module:Clone() -- contourne le cache de require
	local ok, charte = pcall(require, copie)
	copie:Destroy()
	if not ok or type(charte) ~= "table" then return false end
	for cle, v in charte do
		if API[cle] ~= type(v) then return false end
	end
	for cle, attendu in API do
		if type(rawget(charte, cle)) ~= attendu then return false end
	end
	local nb = 0
	for nom, c in charte.Couleurs do
		nb += 1
		if typeof(c) ~= "Color3" or CANON[nom] ~= c:ToHex():upper() then return false end
	end
	local a = Color3.fromHex(CANON.Alerte)
	for variante, attendu in { Ombre = ombre(a), Lumiere = a:Lerp(CREME, 0.2) } do
		local okT, t = pcall(charte.teinte, "Alerte", variante)
		if not okT or typeof(t) ~= "Color3" or t:ToHex() ~= attendu:ToHex() then return false end
	end
	return nb == 11
end

local function sommetY(p: BasePart): number -- sommet de la boîte englobante, même pivotée
	local cf, d = p.CFrame, p.Size / 2
	return cf.Y + math.abs(cf.RightVector.Y) * d.X + math.abs(cf.UpVector.Y) * d.Y + math.abs(cf.LookVector.Y) * d.Z
end

local function horsArene(inst: Instance): boolean -- tag HorsArene sur la Part ou un ancêtre (Canopée de a16)
	local i: Instance? = inst
	while i and i ~= workspace do
		if i:HasTag("HorsArene") then return true end
		i = i.Parent
	end
	return false
end

local function auditer()
	if not RunService:IsEdit() then return warn("[Auditeur] Auditer : mode édition uniquement.") end
	local maison = workspace:FindFirstChild("Maison")
	local prairie = maison ~= nil and maison:IsA("Model")
	local centre, solY = Vector3.zero, 0
	if prairie then
		local cf, taille = (maison :: Model):GetBoundingBox()
		centre, solY = cf.Position, cf.Y - taille.Y / 2
	end
	local outillage = ServerStorage:FindFirstChild("Outillage")
	local gabarit = outillage and outillage:FindFirstChild("Gabarit")
	local n = { parts = 0, smooth = 0, neon = 0, lumieres = 0, actifs = 0, hauts = 0, hors = 0 }
	local neonZone, fautifs, couleurs, emetteurs = {}, {}, {}, {}

	local function controlerCouleur(p: BasePart)
		local c, cible, ecart = p.Color, nil, math.huge
		for _, t in TEINTES do
			local e = (c.R - t.R) ^ 2 + (c.G - t.G) ^ 2 + (c.B - t.B) ^ 2
			if e < ecart then cible, ecart = t, e end
		end
		if ecart > TOLERANCE then table.insert(couleurs, { p, cible }) end
	end

	-- Zone = enfant de Workspace ou de Workspace.Decor (Decor.Lisiere compte dans « Lisiere »)
	local racines = {}
	for _, enfant in workspace:GetChildren() do
		if enfant.Name == "Decor" then
			for _, z in enfant:GetChildren() do table.insert(racines, z) end
		elseif not (enfant:IsA("Terrain") or enfant:IsA("Camera")) then
			table.insert(racines, enfant)
		end
	end
	for _, racine in racines do
		local zone, liste, controle = racine.Name, racine:GetDescendants(), prairie and racine ~= maison
		table.insert(liste, racine)
		for _, inst in liste do
			if inst:IsA("BasePart") then
				n.parts += 1
				if inst.Material == Enum.Material.SmoothPlastic then n.smooth += 1 end
				if inst.Material == Enum.Material.Neon then
					n.neon += 1
					neonZone[zone] = (neonZone[zone] or 0) + 1
				end
				controlerCouleur(inst)
				if controle then
					local dx, dz = inst.Position.X - centre.X, inst.Position.Z - centre.Z
					local ecart = math.max(math.abs(dx), math.abs(dz))
					if math.sqrt(dx * dx + dz * dz) < B.Rayon and sommetY(inst) - solY > B.Hauteur then
						n.hauts += 1
						table.insert(fautifs, inst)
					elseif ecart > B.DemiArene and (ecart > B.DemiCadre or not horsArene(inst)) then
						n.hors += 1
						table.insert(fautifs, inst)
					end
				end
			elseif inst:IsA("Light") then -- PointLight, SpotLight et SurfaceLight
				n.lumieres += 1
			elseif inst:IsA("ParticleEmitter") then
				if inst.Enabled then n.actifs += 1 end
				if inst.Rate > B.Rate then
					table.insert(emetteurs, inst)
					table.insert(fautifs, inst)
				end
			end
		end
	end

	-- Zbires : chemin unique ReplicatedStorage.Modeles.Zbires, les 10 types obligatoires
	local modeles = ReplicatedStorage:FindFirstChild("Modeles")
	local dossier = modeles and modeles:FindFirstChild("Zbires")
	local manquants, zbiresKO, pireZbire = {}, {}, 0
	for _, nom in TYPES do
		local modele = dossier and dossier:FindFirstChild(nom)
		if not (modele and modele:IsA("Model")) then
			table.insert(manquants, nom)
			continue
		end
		local colosse, nb, mesh, neon, drapeaux, defauts = nom == "Colosse", 0, 0, 0, false, {}
		for _, d in modele:GetDescendants() do
			if d:IsA("BasePart") then
				nb += 1
				if d:IsA("MeshPart") then mesh += 1 end
				if d.Material == Enum.Material.Neon then neon += 1 end
				drapeaux = drapeaux or d.CastShadow or d.CanCollide or d.CanQuery or d.CanTouch
				controlerCouleur(d)
			elseif d:IsA("Humanoid") or d:IsA("Animator") or d:IsA("Light") or d:IsA("ParticleEmitter")
				or d:IsA("LuaSourceContainer") then
				table.insert(defauts, d.ClassName)
			end
		end
		local racine = modele.PrimaryPart
		if not (racine and racine.Name == "Racine" and racine.Anchored and racine.Transparency == 1) then
			table.insert(defauts, "Racine")
		end
		if nb > (if colosse then B.PartsColosse else B.PartsZbire) then table.insert(defauts, nb .. " Parts") end
		if mesh < 3 or (not colosse and mesh > 5) then table.insert(defauts, mesh .. " MeshParts") end
		if neon > (if colosse then B.NeonColosse else 0) then table.insert(defauts, neon .. " Neon") end
		if drapeaux then table.insert(defauts, "CastShadow/CanCollide/CanQuery/CanTouch") end
		if not colosse then pireZbire = math.max(pireZbire, nb) end
		if #defauts > 0 then
			table.insert(zbiresKO, ("%s (%s)"):format(nom, table.concat(defauts, ", ")))
			table.insert(fautifs, modele)
		end
	end
	local okLien, auto = pcall(function()
		return (dossier :: any):FindFirstChildWhichIsA("PackageLink").AutoUpdate
	end)

	local bloquants = 0
	local function regle(ok: boolean, bloquant: boolean, texte: string)
		if ok then return print("  OK     " .. texte) end
		if bloquant then bloquants += 1 end
		warn((if bloquant then "  KO     " else "  AVERT  ") .. texte)
	end
	local plafond = if prairie
		then math.min(gabarit and gabarit:GetAttribute("PartsStatiques") or B.PartsPrairie, B.PartsPrairie)
		else B.PartsLabo
	local smooth = if n.parts > 0 then n.smooth / n.parts else 1
	print(("[Auditeur Pixel-bloc v2] %s, profil %s"):format(game.Name, if prairie then "Prairie" else "Laboratoire"))
	regle(charteConforme(), true, "Charte : Couleurs (11 du canon), teinte(), Interface, Ambiances, rien d'autre")
	regle(gabarit ~= nil, true, "ServerStorage.Outillage.Gabarit présent")
	regle(n.parts <= plafond, true, ("Parts statiques %d / %d"):format(n.parts, plafond))
	regle(n.neon <= B.Neon, true, ("Neon %d / %d"):format(n.neon, B.Neon))
	for zone, nb in neonZone do
		local budget = gabarit and gabarit:GetAttribute("Neon_" .. zone) or 0
		regle(nb <= budget, true, ("Neon %s %d / %d (Gabarit)"):format(zone, nb, budget))
	end
	regle(n.lumieres <= B.Lumieres, true, ("Lumières toutes classes %d / %d"):format(n.lumieres, B.Lumieres))
	regle(n.actifs <= B.Emetteurs, true, ("ParticleEmitter Enabled %d / %d"):format(n.actifs, B.Emetteurs))
	regle(#emetteurs == 0, true, ("Rate > 20 : %d émetteur(s), corrigeable"):format(#emetteurs))
	regle(#couleurs == 0, true, ("Hors palette : %d Part(s), corrigeable"):format(#couleurs))
	regle(smooth >= B.Smooth, true, ("SmoothPlastic %d %%, minimum 90"):format(math.floor(smooth * 100)))
	regle(workspace.Terrain:CountCells() == 0, true, "Terrain:CountCells() = 0")
	regle(#manquants == 0, true, "Modeles.Zbires, types manquants : " .. table.concat(manquants, ", "))
	regle(#zbiresKO == 0, true, "Format Forge : " .. table.concat(zbiresKO, " ; "))
	regle(ReplicatedStorage:FindFirstChild("Zbires") == nil, true, "Ancien dossier ReplicatedStorage.Zbires supprimé")
	regle(okLien and auto == true, false, "Modeles.Zbires en Package AutoUpdate")
	if prairie then
		local pire = if pireZbire > 0 then pireZbire else B.PartsZbire
		local pic = n.parts + B.Horde * pire + B.Reserve
		regle(n.hauts == 0, true, ("Plus de 6 studs à moins de 60 de la Maison : %d"):format(n.hauts))
		regle(n.hors == 0, true, ("Hors arène ± 110 (HorsArene ± 150) : %d"):format(n.hors))
		regle(not workspace.StreamingEnabled, true, "StreamingEnabled désactivé")
		regle(pic <= B.PartsArene, true,
			("Pic %d / %d = statique + 60 × %d + 30 + 450 + 240 + 300"):format(pic, B.PartsArene, pire))
	end
	print(("[Auditeur] %d bloquant(s)%s"):format(bloquants, if bloquants == 0 then " : publiable." else ", fautifs sélectionnés."))
	Selection:Set(fautifs)
	dernier = { couleurs = couleurs, emetteurs = emetteurs }
end

local function corriger()
	if not RunService:IsEdit() then return warn("[Auditeur] Corriger : mode édition uniquement.") end
	local id = ChangeHistoryService:TryBeginRecording("Corriger Pixel-bloc")
	if not id then return warn("[Auditeur] Enregistrement impossible, réessaie.") end
	local total = 0
	for _, paire in dernier.couleurs do
		if paire[1].Parent then paire[1].Color, total = paire[2], total + 1 end
	end
	for _, emetteur in dernier.emetteurs do
		if emetteur.Parent then emetteur.Rate, total = B.Rate, total + 1 end
	end
	ChangeHistoryService:FinishRecording(id, Enum.FinishRecordingOperation.Commit)
	dernier = { couleurs = {}, emetteurs = {} }
	print(("[Auditeur] %d correction(s), Ctrl+Z pour annuler. Relance « Auditer »."):format(total))
end

local barre = plugin:CreateToolbar("Zsurvie Outillage")
for _, def in { { "Auditer", "Charte Pixel-bloc, budgets du canon et Zbires", auditer },
	{ "Corriger", "Couleurs sur les 33 teintes, Rate à 20", corriger } } do
	local bouton = barre:CreateButton(def[1], def[2], "")
	bouton.ClickableWhenViewportHidden = true
	bouton.Click:Connect(function()
		bouton:SetActive(false)
		def[3]()
	end)
end
```

## Outil 2 : Semeur de Prairie

- **Greybox** (lit le Gabarit) : `Prairie_Sol` 220 × 1 × 220 en Prairie ; 4 chemins en croix en Terre battue, 8 studs de large ; `Maison` 16 × 16 × 14 en (0, 0, 0) ; `Mine` à 12 studs, hors des chemins ; repère à 70 studs ; 8 `Lisiere_Portail_NN` à 85 studs tous les 45° en Violet horde, chacun avec une `Attachment` `Apparition` lue par le serveur. Couleurs tirées de `Charte.teinte`.
- **Semis** : panneau `DockWidgetPluginGui` des prefabs de `ServerStorage.Prefabs.Decor` (attributs `Zone`, `Grille` = 1 ou 4) ; raycast sous la souris, arrondi à la grille, rotation de 90° (`R`), pinceau de 4 à 16 studs pour la Lisière.
- **Garde-fous** : fantôme en Alerte, pose refusée au-dessus de 6 studs à moins de 60 studs de la Maison, sur un chemin, à moins de 4 studs de la Maison ou de la Mine, au-delà de ± 110 studs (± 150 pour un prefab portant l'attribut `HorsArene`, tagué `HorsArene` à la pose).
- **Nommage** `Decor.<Zone>.<Zone>_<Prefab>_NNN`, une étape `ChangeHistoryService` par pose.

## Outil 3 : Forge à Zbires

**Chemin unique : `ReplicatedStorage.Modeles.Zbires`.** La Forge y range, l'Auditeur y contrôle, le Package `AutoUpdate` le partage entre les 2 places, la Galerie et `ZbiresRendu` (a26) y lisent. Aucune copie ailleurs.

| Types | Parts (Racine comprise) | MeshParts | Neon |
|---|---|---|---|
| Marcheur, Rapide, Costaud, Dore, Sauteur, Gluant, MiniGluant, Volant, Casque | 6 au plus | 3 à 5 | 0 |
| Colosse | 30 au plus | 3 au moins | 4 au plus |

- **Forger** (Models sélectionnés, une étape annulable) : supprime `Humanoid`, `Animator`, `Light`, `ParticleEmitter` et scripts ; arrondit à 0,5 stud ; crée `Racine` (Part 2 × 0,5 × 2, `Anchored`, `Transparency` 1, `PrimaryPart`) ; soude le reste par `WeldConstraint`, `Massless` ; met `CastShadow`, `CanCollide`, `CanQuery` et `CanTouch` à false partout ; recale les couleurs sur les 33 teintes ; renomme selon les 10 types et pose l'attribut `Type`. Tout modèle hors format est refusé : le modeleur fusionne ses cubes de 0,5 stud en 3 à 5 MeshParts avant l'import.
- Aucune stat dans les modèles : PV, vitesse et butin restent côté serveur. Le client déplace les Racines d'un seul `workspace:BulkMoveTo`.
- **Galerie** (Laboratoire) : par Zbire, un socle 6 × 6 `Galerie_Socle_NN`, la figurine × 1,5 (`Model:ScaleTo`) et 3 emplacements de variantes (attribut `Seuil` = 10, 100, 1 000).
