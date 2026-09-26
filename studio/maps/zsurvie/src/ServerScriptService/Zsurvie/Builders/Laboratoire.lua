-- Builders/Laboratoire.lua : le Laboratoire du lobby (disque r22 autour de Plan.lobby.laboratoire).
-- Sol carrelé, Arbre des Recherches au centre (invite « ArbreRecherches », ouverte côté client),
-- 12 alcôves toutes différentes à r16, écran géant des recherches et Doc Boulon, le savant jouet.
local M = {}

local BUDGET = 700
local RAYON = 22
local RAYON_ALCOVES = 17.5
local SOL = 0.6 -- dessus du carrelage

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage or {}
	if not Plan or not Plan.lobby or not Plan.lobby.laboratoire then
		return
	end
	local C = Plan.lobby.laboratoire
	local dossier = ctx.dossier
	local rng = Outils.aleatoire(2222)
	local nbParts = 0

	-- couleurs, toutes issues de la Charte
	local ardoise = Charte.ardoise
	local ardoiseOmbre = Charte.ombre(Charte.ardoise)
	local metal = Charte.lumiere(Charte.ardoise)
	local nuit = Charte.nuitLabo
	local peau = Charte.lumiere(Charte.terre)
	local gris = Charte.lumiere(metal)
	local NEON = { Material = Enum.Material.Neon }

	-- ===== aides de construction (budget respecté) =====
	local function creer(fabrique, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return fabrique(parent, props)
	end

	local function fusion(props, extra)
		if extra then
			for cle, valeur in pairs(extra) do
				props[cle] = valeur
			end
		end
		return props
	end

	-- bloc en coordonnées locales de `base` ; y = bas du bloc
	local function P(m, base, x, y, z, sx, sy, sz, couleur, extra)
		return creer(Outils.bloc, m, fusion({
			Size = Vector3.new(sx, sy, sz),
			CFrame = base * CFrame.new(x, y + sy / 2, z),
			Color = couleur,
		}, extra))
	end

	-- cylindre vertical ; y = bas
	local function CV(m, base, x, y, z, h, d, couleur, extra)
		return creer(Outils.cylindre, m, fusion({
			Size = Vector3.new(h, d, d),
			CFrame = base * CFrame.new(x, y + h / 2, z) * CFrame.Angles(0, 0, math.rad(90)),
			Color = couleur,
		}, extra))
	end

	-- boule ; y = centre
	local function B(m, base, x, y, z, d, couleur, extra)
		return creer(Outils.boule, m, fusion({
			Size = Vector3.new(d, d, d),
			CFrame = base * CFrame.new(x, y, z),
			Color = couleur,
		}, extra))
	end

	-- bloc placé par un CFrame libre
	local function libre(m, cf, taille, couleur, extra)
		return creer(Outils.bloc, m, fusion({ Size = taille, CFrame = cf, Color = couleur }, extra))
	end

	local function animer(p, genre, vitesse)
		if p then
			Outils.animer(p, genre, vitesse)
		end
	end

	local function ecrire(p, face, texte, props)
		if p then
			local ok = pcall(Outils.texte, p, face, texte, props)
			return ok
		end
		return false
	end

	local function nommer(p, nom)
		if p then
			p.Name = nom
		end
		return p
	end

	-- ===== 1. sol carrelé =====
	local sol = Outils.modele(dossier, "Sol")
	creer(Outils.cylindre, sol, {
		Name = "Dalle",
		Size = Vector3.new(0.4, RAYON * 2, RAYON * 2),
		CFrame = CFrame.new(C.X, 0.2, C.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color = ardoiseOmbre,
	})
	for i = -5, 4 do
		for j = -5, 4 do
			local x = i * 4 + 2
			local z = j * 4 + 2
			if math.sqrt(x * x + z * z) + 2.9 <= RAYON - 0.8 then
				local couleur = nuit
				if (i + j) % 2 == 0 then
					couleur = ardoise
				end
				creer(Outils.bloc, sol, {
					Name = "Carreau",
					Size = Vector3.new(3.9, 0.2, 3.9),
					CFrame = CFrame.new(C.X + x, 0.5, C.Z + z),
					Color = couleur,
				})
			end
		end
	end
	-- liseré lumineux au bord du carrelage
	for k = 0, 23 do
		local a = math.rad(k * 15)
		local pos = Vector3.new(C.X + math.sin(a) * 21.2, 0.45, C.Z + math.cos(a) * 21.2)
		libre(sol, CFrame.lookAt(pos, Vector3.new(C.X, 0.45, C.Z)) * CFrame.Angles(0, math.rad(90), 0),
			Vector3.new(5.4, 0.3, 0.5), Charte.gemme, NEON)
	end

	-- ===== 2. l'Arbre des Recherches =====
	local arbre = Outils.modele(dossier, "ArbreRecherches")
	local baseArbre = CFrame.new(C.X, SOL, C.Z)
	CV(arbre, baseArbre, 0, 0, 0, 1, 7.5, metal, { Name = "Socle", Reflectance = 0.2 })
	CV(arbre, baseArbre, 0, 1, 0, 0.2, 6.5, Charte.gemme, { Name = "Anneau", Material = Enum.Material.Neon })

	-- tronc : 4 blocs empilés, tournés en alternance, cerclés de métal
	local tronc = nil
	for k = 0, 3 do
		local couleur = ardoise
		if k % 2 == 1 then
			couleur = ardoiseOmbre
		end
		local seg = libre(arbre,
			CFrame.new(C.X, SOL + 1 + 1.5 + k * 3, C.Z) * CFrame.Angles(0, math.rad((k % 2) * 45), 0),
			Vector3.new(3, 3, 3), couleur, { Name = "Tronc" .. (k + 1) })
		if k == 1 then
			tronc = seg
		end
		if k > 0 then
			libre(arbre, CFrame.new(C.X, SOL + 1 + k * 3, C.Z) * CFrame.Angles(0, math.rad(22.5), 0),
				Vector3.new(3.6, 0.4, 3.6), metal, { Name = "Cerclage", Reflectance = 0.3 })
		end
	end
	libre(arbre, CFrame.new(C.X, SOL + 13.2, C.Z), Vector3.new(3.4, 0.4, 3.4), metal, { Name = "Chapiteau", Reflectance = 0.3 })

	-- racines en coins
	for k = 0, 3 do
		local a = math.rad(k * 90 + 45)
		local d = Vector3.new(math.sin(a), 0, math.cos(a))
		local pos = Vector3.new(C.X, SOL + 2, C.Z) + d * 2.6
		creer(Outils.coin, arbre, {
			Name = "Racine",
			Size = Vector3.new(1.2, 2, 2.4),
			CFrame = CFrame.lookAt(pos, pos + d),
			Color = ardoiseOmbre,
		})
	end

	-- branches et grappes de cristaux
	local hauteurs = { 6.5, 8.5, 10.5 }
	for k = 0, 5 do
		local a = math.rad(k * 60 + 15)
		local d = Vector3.new(math.sin(a), 0, math.cos(a))
		local h = hauteurs[(k % 3) + 1]
		local debut = Vector3.new(C.X, SOL + h, C.Z) + d * 1.2
		local fin = debut + d * (6 * math.cos(math.rad(35))) + Vector3.new(0, 6 * math.sin(math.rad(35)), 0)
		local milieu = (debut + fin) / 2
		libre(arbre, CFrame.lookAt(milieu, fin), Vector3.new(1, 1, 6), metal, { Name = "Branche" })
		for n = 1, 3 do
			local decalage = Vector3.new(rng:NextNumber(-0.6, 0.6), rng:NextNumber(0.2, 1.2), rng:NextNumber(-0.6, 0.6))
			local cristal = libre(arbre,
				CFrame.new(fin + decalage) * CFrame.Angles(math.rad(rng:NextNumber(-25, 25)), math.rad(rng:NextNumber(0, 90)), math.rad(rng:NextNumber(-25, 25))),
				Vector3.new(0.8, rng:NextNumber(1.4, 2.2), 0.8), Charte.gemme, { Name = "Cristal", Material = Enum.Material.Neon })
			if n == 1 then
				animer(cristal, "pulse", 0.6 + k * 0.1)
			end
		end
	end

	-- couronne
	local couronne = libre(arbre, CFrame.new(C.X, SOL + 15.4, C.Z) * CFrame.Angles(0, math.rad(45), 0),
		Vector3.new(2, 4, 2), Charte.gemme, { Name = "Couronne", Material = Enum.Material.Neon })
	animer(couronne, "pulse", 0.5)
	if couronne then
		Outils.lumiere(couronne, { Range = 26, Brightness = 1.5, Color = Charte.gemme })
	end
	for k = 0, 3 do
		local a = math.rad(k * 90)
		local pos = Vector3.new(C.X + math.sin(a) * 1.3, SOL + 14.6, C.Z + math.cos(a) * 1.3)
		libre(arbre, CFrame.new(pos) * CFrame.Angles(0, a, math.rad(25)), Vector3.new(0.7, 2, 0.7),
			Charte.lumiere(Charte.gemme), { Name = "Cristal", Material = Enum.Material.Neon })
	end

	-- invite : ouverte côté client (panneau « Recherches »), aucun rappel serveur
	if tronc then
		Outils.invite(tronc, { nom = "ArbreRecherches", action = "Rechercher", objet = "Arbre des Recherches", distance = 14 })
	end

	-- ===== 3. l'écran géant des recherches (au nord, au-dessus de l'alcôve du tableau) =====
	local ecranModele = Outils.modele(dossier, "EcranRecherches")
	local posEcran = Vector3.new(C.X, SOL + 12, C.Z - 20.3)
	local ecran = libre(ecranModele, CFrame.lookAt(posEcran, posEcran + Vector3.new(0, 0, 1)),
		Vector3.new(14, 8, 0.4), Charte.encre, { Name = "Ecran" })
	for _, x in ipairs({ -6.2, 6.2 }) do
		P(ecranModele, CFrame.new(C.X, SOL, C.Z - 20.3), x, -0.2, 0, 0.8, 8.4, 0.6, ardoiseOmbre, { Name = "Pilier" })
	end
	P(ecranModele, CFrame.new(C.X, SOL, C.Z - 20.1), 0, 7.6, 0, 14, 0.3, 0.3, Charte.gemme, { Name = "Neon", Material = Enum.Material.Neon })

	-- liste triée par coût, puis par nom
	local liste = {}
	if type(E.recherches) == "table" then
		for nom, infos in pairs(E.recherches) do
			if type(infos) == "table" and type(infos.cout) == "number" then
				table.insert(liste, { nom = tostring(nom), cout = infos.cout, description = tostring(infos.description or "") })
			end
		end
	end
	table.sort(liste, function(a, b)
		if a.cout == b.cout then
			return a.nom < b.nom
		end
		return a.cout < b.cout
	end)

	local function joli(nom)
		local texte = string.gsub(nom, "(%l)(%u)", "%1 %2")
		return texte
	end

	if ecran then
		local ok, err = pcall(function()
			local gui = Instance.new("SurfaceGui")
			gui.Name = "Tableau"
			gui.Face = Enum.NormalId.Front
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 40
			gui.LightInfluence = 0
			gui.Parent = ecran

			local fond = Instance.new("Frame")
			fond.Size = UDim2.fromScale(1, 1)
			fond.BackgroundColor3 = nuit
			fond.BorderSizePixel = 0
			fond.Parent = gui
			local contour = Instance.new("UIStroke")
			contour.Color = Charte.gemme
			contour.Thickness = 6
			contour.Parent = fond

			local titre = Instance.new("TextLabel")
			titre.BackgroundTransparency = 1
			titre.Position = UDim2.fromScale(0.04, 0.03)
			titre.Size = UDim2.fromScale(0.92, 0.17)
			titre.Font = Charte.police
			titre.TextScaled = true
			titre.TextColor3 = Charte.dore
			titre.Text = "ARBRE DES RECHERCHES"
			titre.Parent = fond

			local zone = Instance.new("Frame")
			zone.BackgroundTransparency = 1
			zone.Position = UDim2.fromScale(0.04, 0.23)
			zone.Size = UDim2.fromScale(0.92, 0.72)
			zone.Parent = fond
			local disposition = Instance.new("UIListLayout")
			disposition.Padding = UDim.new(0, 6)
			disposition.SortOrder = Enum.SortOrder.LayoutOrder
			disposition.Parent = zone

			if #liste == 0 then
				local vide = Instance.new("TextLabel")
				vide.BackgroundTransparency = 1
				vide.Size = UDim2.fromScale(1, 0.3)
				vide.Font = Charte.policeTexte
				vide.TextScaled = true
				vide.TextColor3 = Charte.creme
				vide.Text = "Bientôt de nouvelles recherches !"
				vide.Parent = zone
			end
			for i, r in ipairs(liste) do
				local ligne = Instance.new("Frame")
				ligne.Name = r.nom
				ligne.LayoutOrder = i
				ligne.Size = UDim2.new(1, 0, 1 / #liste, -6)
				ligne.BackgroundColor3 = ardoise
				ligne.BorderSizePixel = 0
				ligne.Parent = zone
				local coin = Instance.new("UICorner")
				coin.CornerRadius = UDim.new(0, 8)
				coin.Parent = ligne

				local nomTexte = Instance.new("TextLabel")
				nomTexte.BackgroundTransparency = 1
				nomTexte.Position = UDim2.fromScale(0.03, 0.05)
				nomTexte.Size = UDim2.fromScale(0.62, 0.5)
				nomTexte.Font = Charte.police
				nomTexte.TextScaled = true
				nomTexte.TextXAlignment = Enum.TextXAlignment.Left
				nomTexte.TextColor3 = Charte.creme
				nomTexte.Text = joli(r.nom)
				nomTexte.Parent = ligne

				local desc = Instance.new("TextLabel")
				desc.BackgroundTransparency = 1
				desc.Position = UDim2.fromScale(0.03, 0.55)
				desc.Size = UDim2.fromScale(0.64, 0.4)
				desc.Font = Charte.policeTexte
				desc.TextScaled = true
				desc.TextXAlignment = Enum.TextXAlignment.Left
				desc.TextColor3 = Charte.lumiere(Charte.ardoise)
				desc.Text = r.description
				desc.Parent = ligne

				local cout = Instance.new("TextLabel")
				cout.BackgroundTransparency = 1
				cout.Position = UDim2.fromScale(0.7, 0.15)
				cout.Size = UDim2.fromScale(0.27, 0.7)
				cout.Font = Charte.police
				cout.TextScaled = true
				cout.TextXAlignment = Enum.TextXAlignment.Right
				cout.TextColor3 = Charte.gemme
				cout.Text = tostring(r.cout) .. " gemmes"
				cout.Parent = ligne
			end
		end)
		if not ok then
			warn("[Zsurvie] Laboratoire : écran des recherches incomplet : " .. tostring(err))
		end
	end

	-- ===== 4. Doc Boulon =====
	local doc = Outils.modele(dossier, "DocBoulon")
	local posDoc = Vector3.new(C.X + 5, SOL, C.Z + 6)
	local baseDoc = CFrame.lookAt(posDoc, posDoc + Vector3.new(-0.3, 0, 1))
	-- jambes et chaussures
	for _, x in ipairs({ -0.55, 0.55 }) do
		P(doc, baseDoc, x, 0, -0.15, 0.9, 0.5, 1.3, Charte.encre, { Name = "Chaussure" })
		P(doc, baseDoc, x, 0.5, 0, 0.8, 1.3, 0.8, ardoise, { Name = "Jambe" })
	end
	-- blouse
	P(doc, baseDoc, 0, 1.6, 0, 2.6, 1.2, 1.4, Charte.creme, { Name = "BasBlouse" })
	P(doc, baseDoc, 0, 2.6, 0, 2.4, 1.8, 1.3, Charte.creme, { Name = "Blouse" })
	P(doc, baseDoc, 0, 3.1, -0.67, 0.35, 1.2, 0.1, Charte.toit, { Name = "Cravate" })
	P(doc, baseDoc, 0.7, 3.0, -0.67, 0.6, 0.5, 0.06, Charte.ombre(Charte.creme), { Name = "Poche" })
	P(doc, baseDoc, 0.8, 3.3, -0.7, 0.1, 0.45, 0.1, Charte.dore, { Name = "Stylo" })
	for _, x in ipairs({ -1.55, 1.55 }) do
		P(doc, baseDoc, x, 2.4, 0, 0.7, 2, 0.8, Charte.creme, { Name = "Bras" })
		P(doc, baseDoc, x, 1.8, 0, 0.6, 0.6, 0.6, peau, { Name = "Main" })
	end
	-- tête
	local tete = P(doc, baseDoc, 0, 4.4, 0, 1.8, 1.7, 1.6, peau, { Name = "Tete" })
	P(doc, baseDoc, 0, 4.85, -0.9, 0.35, 0.35, 0.3, Charte.ombre(peau), { Name = "Nez" })
	P(doc, baseDoc, 0, 3.9, -0.7, 1.7, 1.0, 0.4, gris, { Name = "Barbe" })
	P(doc, baseDoc, 0, 3.4, -0.75, 1.0, 0.6, 0.3, gris, { Name = "PointeBarbe" })
	for _, x in ipairs({ -0.95, 0.95 }) do
		P(doc, baseDoc, x, 4.9, 0.1, 0.35, 0.9, 1.3, gris, { Name = "Cheveux" })
		P(doc, baseDoc, x * 0.44, 5.05, -0.83, 0.7, 0.6, 0.06, Charte.encre, { Name = "Monture" })
		P(doc, baseDoc, x * 0.44, 5.1, -0.87, 0.5, 0.45, 0.06, Charte.gemme, { Name = "Verre", Material = Enum.Material.Neon, Transparency = 0.25 })
	end
	P(doc, baseDoc, 0, 5.3, -0.85, 0.3, 0.1, 0.08, Charte.encre, { Name = "Pont" })
	-- le boulon sur le crâne
	CV(doc, baseDoc, 0, 6.1, 0, 0.4, 0.9, metal, { Name = "Ecrou", Reflectance = 0.3 })
	P(doc, baseDoc, 0, 6.5, 0, 0.3, 0.6, 0.3, metal, { Name = "Vis", Reflectance = 0.3 })

	if tete then
		local ok, err = pcall(function()
			local etiquette = Instance.new("BillboardGui")
			etiquette.Name = "Nom"
			etiquette.Size = UDim2.fromScale(6, 1.2)
			etiquette.StudsOffset = Vector3.new(0, 2.8, 0)
			etiquette.MaxDistance = 60
			etiquette.AlwaysOnTop = false
			etiquette.LightInfluence = 0
			etiquette.Parent = tete
			local nom = Instance.new("TextLabel")
			nom.BackgroundTransparency = 1
			nom.Size = UDim2.fromScale(1, 1)
			nom.Font = Charte.police
			nom.TextScaled = true
			nom.TextColor3 = Charte.dore
			nom.TextStrokeColor3 = Charte.encre
			nom.TextStrokeTransparency = 0
			nom.Text = "Doc Boulon"
			nom.Parent = etiquette

			local bulle = Instance.new("BillboardGui")
			bulle.Name = "Bulle"
			bulle.Size = UDim2.fromScale(10, 2.6)
			bulle.StudsOffset = Vector3.new(0, 5, 0)
			bulle.MaxDistance = 45
			bulle.LightInfluence = 0
			bulle.Parent = tete
			local cadre = Instance.new("Frame")
			cadre.Size = UDim2.fromScale(1, 1)
			cadre.BackgroundColor3 = Charte.creme
			cadre.BorderSizePixel = 0
			cadre.Parent = bulle
			local arrondi = Instance.new("UICorner")
			arrondi.CornerRadius = UDim.new(0.25, 0)
			arrondi.Parent = cadre
			local trait = Instance.new("UIStroke")
			trait.Color = Charte.encre
			trait.Thickness = 3
			trait.Parent = cadre
			local texte = Instance.new("TextLabel")
			texte.BackgroundTransparency = 1
			texte.Position = UDim2.fromScale(0.05, 0.1)
			texte.Size = UDim2.fromScale(0.9, 0.8)
			texte.Font = Charte.policeTexte
			texte.TextScaled = true
			texte.TextWrapped = true
			texte.TextColor3 = Charte.encre
			texte.Parent = cadre

			-- conseils (les chiffres viennent de l'Équilibrage)
			local conseils = {
				"Approche-toi de l'Arbre des Recherches pour dépenser tes gemmes !",
				"Les recherches sont permanentes : elles te suivent de run en run.",
				"Les gemmes cyan brillent dans la Mine de la Prairie. Creuse !",
				"Protège la Maison : si elle tombe, la run est finie.",
				"Un Zbire doré ? Vise-le vite, il vaut le détour !",
				"Monte dans une Capsule du Quai pour partir en run avec tes amis.",
			}
			if #liste > 0 then
				table.insert(conseils, 2, "La recherche la moins chère coûte " .. tostring(liste[1].cout) .. " gemmes.")
			end
			if type(E.gemmes) == "table" then
				if type(E.gemmes.parcours) == "number" then
					table.insert(conseils, "Le parcours de l'île rapporte " .. tostring(E.gemmes.parcours) .. " gemmes, une seule fois !")
				end
				if type(E.gemmes.enigme) == "number" then
					table.insert(conseils, "Résous l'énigme de l'île : " .. tostring(E.gemmes.enigme) .. " gemmes à la clé !")
				end
			end

			texte.Text = conseils[1]
			task.spawn(function()
				local i = 1
				while bulle.Parent and doc.Parent do
					task.wait(8)
					i = i % #conseils + 1
					if texte.Parent then
						texte.Text = conseils[i]
					end
				end
			end)
		end)
		if not ok then
			warn("[Zsurvie] Laboratoire : bulle de Doc Boulon incomplète : " .. tostring(err))
		end
	end

	-- ===== 5. les 12 alcôves =====
	local alcoves = Outils.dossier(dossier, "Alcoves")
	local accents = { Charte.gemme, Charte.toit, Charte.dore, Charte.prairie, Charte.creme }
	local teintes = { Charte.gemme, Charte.dore, Charte.toit, Charte.prairie, Charte.alerte }

	local function comptoir(m, base)
		P(m, base, 0, 0.1, 1.0, 4.4, 2.6, 1.4, ardoise, { Name = "Comptoir" })
		P(m, base, 0, 2.7, 1.0, 4.6, 0.3, 1.6, metal, { Name = "Plateau" })
	end

	local contenus = {}

	-- 1. chimie : fioles et brûleur
	contenus[1] = function(m, base)
		comptoir(m, base)
		B(m, base, -1.4, 3.6, 1.0, 1.2, Charte.gemme, { Name = "Fiole", Material = Enum.Material.Neon, Transparency = 0.2 })
		CV(m, base, -1.4, 4.1, 1.0, 0.6, 0.4, Charte.creme, { Name = "Col", Transparency = 0.3 })
		B(m, base, 0, 3.45, 1.1, 0.9, Charte.dore, { Name = "Fiole", Material = Enum.Material.Neon, Transparency = 0.2 })
		CV(m, base, 0, 3.8, 1.1, 0.5, 0.3, Charte.creme, { Name = "Col", Transparency = 0.3 })
		CV(m, base, 1.4, 3.0, 1.0, 0.5, 0.8, ardoiseOmbre, { Name = "Bruleur" })
		local flamme = B(m, base, 1.4, 3.75, 1.0, 0.45, Charte.toit, { Name = "Flamme", Material = Enum.Material.Neon })
		animer(flamme, "pulse", 2)
		P(m, base, -0.7, 4.3, 1.0, 1.4, 0.15, 0.15, Charte.creme, { Name = "Tuyau", Transparency = 0.3 })
	end

	-- 2. tubes à essai
	contenus[2] = function(m, base)
		comptoir(m, base)
		P(m, base, 0, 3.0, 1.0, 3.8, 0.3, 0.8, Charte.terre, { Name = "Support" })
		for n = 0, 4 do
			CV(m, base, -1.4 + n * 0.7, 3.3, 1.0, 1.4, 0.35, teintes[n + 1], { Name = "Tube", Material = Enum.Material.Neon, Transparency = 0.2 })
		end
		P(m, base, 0, 4.0, 1.0, 3.8, 0.15, 0.8, Charte.terre, { Name = "Traverse" })
		CV(m, base, 1.6, 0, -0.6, 1.6, 0.9, Charte.violet, { Name = "Bonbonne", Transparency = 0.3 })
	end

	-- 3. poste d'analyse avec écran
	contenus[3] = function(m, base)
		comptoir(m, base)
		P(m, base, 0, 3.0, 1.3, 0.4, 0.4, 0.4, ardoiseOmbre, { Name = "Pied" })
		local moniteur = P(m, base, 0, 3.4, 1.3, 3.2, 2, 0.3, Charte.encre, { Name = "Moniteur" })
		ecrire(moniteur, "Front", "ANALYSE ZBIRE", { couleur = Charte.gemme })
		P(m, base, 0, 3.0, 0.5, 2, 0.15, 0.7, ardoise, { Name = "Clavier" })
		CV(m, base, 1.7, 3.0, 0.6, 0.5, 0.45, Charte.toit, { Name = "Tasse" })
		local voyant = P(m, base, 0, 5.8, 1.7, 2.6, 1.0, 0.2, Charte.encre, { Name = "Voyant" })
		ecrire(voyant, "Front", "OK", { couleur = Charte.prairie })
	end

	-- 4. étagère à bocaux
	contenus[4] = function(m, base)
		for _, x in ipairs({ -2.1, 2.1 }) do
			P(m, base, x, 0, 1.2, 0.3, 5.6, 1.2, Charte.terre, { Name = "Montant" })
		end
		for n = 0, 2 do
			local y = 1 + n * 1.8
			P(m, base, 0, y, 1.2, 3.9, 0.25, 1.2, Charte.ombre(Charte.terre), { Name = "Rayon" })
			B(m, base, -1.2, y + 0.65, 1.2, 0.8, teintes[n + 1], { Name = "Bocal", Transparency = 0.2 })
			P(m, base, 0.2, y + 0.25, 1.2, 0.9, 0.7, 0.8, accents[n + 2], { Name = "Boite" })
		end
	end

	-- 5. grande cuve de gemme liquide
	contenus[5] = function(m, base)
		CV(m, base, 0, 0, 1.0, 0.6, 3.2, ardoiseOmbre, { Name = "Base" })
		local cuve = CV(m, base, 0, 0.6, 1.0, 4.4, 2.8, Charte.gemme, { Name = "Liquide", Material = Enum.Material.Neon, Transparency = 0.35 })
		animer(cuve, "pulse", 0.8)
		CV(m, base, 0, 5.0, 1.0, 0.4, 3.2, metal, { Name = "Couvercle", Reflectance = 0.3 })
		B(m, base, -0.5, 2, 1.0, 0.5, Charte.creme, { Name = "Bulle", Transparency = 0.3 })
		B(m, base, 0.4, 3.2, 1.0, 0.4, Charte.creme, { Name = "Bulle", Transparency = 0.3 })
		P(m, base, 1.8, 4.6, 1.0, 1.2, 0.4, 0.4, metal, { Name = "Tuyau" })
		P(m, base, 2.2, 0, 1.0, 0.4, 4.6, 0.4, metal, { Name = "Tuyau" })
	end

	-- 6. tableau noir (sous l'écran géant)
	contenus[6] = function(m, base)
		P(m, base, 0, 1.8, 1.7, 4.8, 3.6, 0.1, Charte.terre, { Name = "Cadre" })
		local tableau = P(m, base, 0, 2.0, 1.6, 4.4, 3.2, 0.2, Charte.encre, { Name = "Tableau" })
		ecrire(tableau, "Front", "Gemme + Idée = BOUM !", { couleur = Charte.creme, police = Charte.policeTexte })
		P(m, base, 0, 1.8, 1.35, 4.4, 0.2, 0.4, Charte.terre, { Name = "Rebord" })
		P(m, base, -1, 2.0, 1.35, 0.4, 0.15, 0.15, Charte.creme, { Name = "Craie" })
		CV(m, base, 1.2, 0, -0.2, 1.8, 1.2, Charte.toit, { Name = "Tabouret" })
	end

	-- 7. microscope
	contenus[7] = function(m, base)
		comptoir(m, base)
		P(m, base, 0, 3.0, 1.1, 1, 0.3, 1, Charte.creme, { Name = "Pied" })
		P(m, base, 0, 3.3, 1.4, 0.3, 1.5, 0.3, ardoise, { Name = "Bras" })
		P(m, base, 0, 3.6, 1.0, 0.8, 0.1, 0.8, metal, { Name = "Platine" })
		P(m, base, 0, 3.9, 1.1, 0.35, 1.1, 0.35, Charte.creme, { Name = "Tube" })
		P(m, base, 0, 5.0, 1.1, 0.25, 0.4, 0.25, Charte.encre, { Name = "Oculaire" })
		P(m, base, 1.4, 3.0, 0.8, 0.9, 0.05, 0.35, Charte.gemme, { Name = "Lame", Material = Enum.Material.Neon })
		P(m, base, -1.4, 3.0, 0.9, 1.1, 0.12, 0.8, Charte.creme, { Name = "Carnet" })
	end

	-- 8. bobine électrique
	contenus[8] = function(m, base)
		CV(m, base, 0, 0, 0.8, 1, 2.2, ardoiseOmbre, { Name = "Base" })
		CV(m, base, 0, 1, 0.8, 3.6, 0.8, Charte.terre, { Name = "Colonne" })
		for n = 0, 3 do
			CV(m, base, 0, 1.5 + n * 0.8, 0.8, 0.2, 1.3, Charte.dore, { Name = "Spire" })
		end
		local sphere = B(m, base, 0, 5.4, 0.8, 1.8, Charte.gemme, { Name = "Sphere", Material = Enum.Material.Neon })
		animer(sphere, "pulse", 1.5)
		if sphere then
			Outils.lumiere(sphere, { Range = 10, Brightness = 1, Color = Charte.gemme })
		end
		P(m, base, 0, 0.1, -0.9, 3.6, 0.8, 0.2, Charte.alerte, { Name = "Barriere" })
	end

	-- 9. serre de cristaux
	contenus[9] = function(m, base)
		P(m, base, 0, 0, 1.0, 4.4, 1.2, 1.4, Charte.terre, { Name = "Bac" })
		P(m, base, 0, 1.2, 1.0, 4.2, 0.1, 1.2, Charte.ombre(Charte.terre), { Name = "Terreau" })
		for n = 0, 4 do
			local h = 0.8 + (n % 3) * 0.5
			libre(m, base * CFrame.new(-1.6 + n * 0.8, 1.3 + h / 2, 1.0) * CFrame.Angles(0, math.rad(45), math.rad(-10 + n * 5)),
				Vector3.new(0.5, h, 0.5), Charte.gemme, { Name = "Pousse", Material = Enum.Material.Neon })
		end
		local lampe = P(m, base, 0, 5.8, 1.0, 3, 0.3, 0.6, Charte.dore, { Name = "Lampe", Material = Enum.Material.Neon })
		if lampe then
			Outils.lumiere(lampe, { genre = "Spot", Range = 8, Brightness = 1, Color = Charte.dore })
		end
	end

	-- 10. atelier mécanique
	contenus[10] = function(m, base)
		comptoir(m, base)
		CV(m, base, -1.2, 3.0, 1.0, 0.3, 1.4, metal, { Name = "Engrenage", Reflectance = 0.3 })
		CV(m, base, 0.6, 3.0, 1.0, 0.8, 0.5, metal, { Name = "Ecrou" })
		P(m, base, 1.3, 3.0, 0.7, 1.4, 0.15, 0.3, gris, { Name = "Cle" })
		for n, rayon in ipairs({ 2.2, 1.4 }) do
			local cf = base * CFrame.new(-1 + (n - 1) * 1.9, 4.5 + (n - 1) * 0.8, 1.6) * CFrame.Angles(0, math.rad(90), 0)
			local roue = creer(Outils.cylindre, m, { Name = "Rouage", Size = Vector3.new(0.3, rayon, rayon), CFrame = cf, Color = accents[n + 1] })
			animer(roue, "tourne", 0.5 * n)
		end
	end

	-- 11. bibliothèque
	contenus[11] = function(m, base)
		for _, x in ipairs({ -2.1, 2.1 }) do
			P(m, base, x, 0, 1.3, 0.3, 6, 1.0, Charte.ombre(Charte.terre), { Name = "Montant" })
		end
		for n = 0, 2 do
			local y = 0.6 + n * 1.9
			P(m, base, 0, y, 1.3, 3.9, 0.2, 1.0, Charte.terre, { Name = "Rayon" })
			for l = 0, 3 do
				local h = 1.0 + ((l + n) % 3) * 0.2
				P(m, base, -1.35 + l * 0.9, y + 0.2, 1.3, 0.6, h, 0.8, teintes[((l + n) % 5) + 1], { Name = "Livre" })
			end
		end
	end

	-- 12. spécimen de Zbire en bocal
	contenus[12] = function(m, base)
		CV(m, base, 0, 0, 0.9, 2.4, 1.8, ardoise, { Name = "Colonne" })
		local etiquette = P(m, base, 0, 0.9, 0.0, 1.4, 0.6, 0.1, Charte.alerte, { Name = "Etiquette" })
		ecrire(etiquette, "Front", "NE PAS NOURRIR", { couleur = Charte.creme })
		B(m, base, 0, 3.8, 0.9, 2.6, Charte.gemme, { Name = "Bocal", Transparency = 0.7 })
		local zbire = P(m, base, 0, 3.2, 0.9, 1, 1, 1, Charte.violet, { Name = "Specimen" })
		animer(zbire, "flotte", 0.5)
		P(m, base, -0.22, 3.9, 0.39, 0.2, 0.25, 0.05, Charte.creme, { Name = "Oeil", Material = Enum.Material.Neon })
		P(m, base, 0.22, 3.9, 0.39, 0.2, 0.25, 0.05, Charte.creme, { Name = "Oeil", Material = Enum.Material.Neon })
		CV(m, base, 0, 5.0, 0.9, 0.3, 1.4, metal, { Name = "Couvercle", Reflectance = 0.3 })
	end

	local noms = { "CHIMIE", "TUBES", "ANALYSE", "RESERVE", "CUVE", "IDEES", "OPTIQUE", "ENERGIE", "SERRE", "MECANIQUE", "ARCHIVES", "SPECIMEN" }

	-- index 6 = nord (le tableau sous l'écran)
	for i = 0, 11 do
		local a = math.rad(i * 30)
		local pos = Vector3.new(C.X + math.sin(a) * RAYON_ALCOVES, SOL, C.Z + math.cos(a) * RAYON_ALCOVES)
		local base = CFrame.lookAt(pos, Vector3.new(C.X, SOL, C.Z))
		local m = Outils.modele(alcoves, "Alcove" .. (i + 1))
		local accent = accents[(i % #accents) + 1]
		P(m, base, 0, -0.2, 2.0, 5.4, 7.2, 0.6, nuit, { Name = "Fond" })
		P(m, base, -2.5, -0.2, 0.5, 0.5, 7.2, 3.6, ardoise, { Name = "Cote" })
		P(m, base, 2.5, -0.2, 0.5, 0.5, 7.2, 3.6, ardoise, { Name = "Cote" })
		local linteau = P(m, base, 0, 7, 0.5, 5.6, 0.8, 3.6, accent, { Name = "Linteau" })
		ecrire(linteau, "Front", noms[i + 1], { couleur = Charte.encre })
		P(m, base, 0, -0.2, 0.5, 4.5, 0.3, 3.4, Charte.ombre(accent), { Name = "Tapis" })
		local fonction = contenus[i + 1]
		if fonction then
			local ok, err = pcall(fonction, m, base * CFrame.new(0, 0.1, 0))
			if not ok then
				warn("[Zsurvie] Laboratoire : alcôve " .. (i + 1) .. " incomplète : " .. tostring(err))
			end
		end
	end

	dossier:SetAttribute("Parts", nbParts)
end

return M
