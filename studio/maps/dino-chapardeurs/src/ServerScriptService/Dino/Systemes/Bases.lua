-- Système Bases : attribution des Bases aux joueurs, apparition, emplacements débloqués, verrou de l'entrée.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local M = {}

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Charte = ctx.Charte
	local Plan = ctx.Plan
	local EB = ctx.Equilibrage.base
	local Reseau = ctx.Reseau

	local NB_BASES = #Plan.bases
	local EMPLACEMENTS_MAX = Plan.base.emplacementsMax or 12
	local DUREE_VERROU = EB.dureeVerrou or 60
	local RECHARGE = EB.recharge or 5
	local PERIODE = 0.25

	local modeles = {}        -- index -> Model
	local proprietaires = {}  -- index -> Player
	local baseDe = {}         -- Player -> index
	local finVerrou = {}      -- index -> heure serveur de fin du verrou (0 si libre)
	local finRecharge = {}    -- index -> heure serveur de fin de recharge
	local apparenceEntree = {} -- index -> propriétés d'origine de l'Entree
	local apparenceE = {}     -- part E<n> -> { Color, Transparency, Material }
	local dernierAvis = {}    -- Player -> heure du dernier avertissement d'intrusion
	local connexions = {}     -- Player -> liste de connexions

	local function maintenant()
		return workspace:GetServerTimeNow()
	end

	local function notifier(joueur, texte, genre)
		if joueur and joueur.Parent then
			pcall(function()
				Reseau.Notification:FireClient(joueur, texte, genre)
			end)
		end
	end

	local function effet(genre, position, donnees)
		pcall(function()
			Reseau.Effet:FireAllClients(genre, position, donnees)
		end)
	end

	local function estIndex(index)
		return type(index) == "number" and index >= 1 and index <= NB_BASES and index == math.floor(index)
	end

	local function estJoueur(joueur)
		return typeof(joueur) == "Instance" and joueur:IsA("Player")
	end

	-- ===== les modèles des Bases =====
	local dossier = ctx.racine:FindFirstChild("Bases") or ctx.racine:WaitForChild("Bases", 15)

	local function trouverModele(i)
		if modeles[i] and modeles[i].Parent then return modeles[i] end
		if not dossier then dossier = ctx.racine:FindFirstChild("Bases") end
		if not dossier then return nil end
		local m = dossier:FindFirstChild("Base" .. i)
		if not m then
			for _, enfant in ipairs(dossier:GetChildren()) do
				if enfant:IsA("Model") and enfant:GetAttribute("Index") == i then
					m = enfant
				end
			end
		end
		modeles[i] = m
		return m
	end

	local function partDe(index, nom)
		local m = trouverModele(index)
		if not m then return nil end
		local p = m:FindFirstChild(nom)
		if p and p:IsA("BasePart") then return p end
		return nil
	end

	local function versTapis(index)
		local b = Plan.bases[index]
		if b and b.versTapis then return b.versTapis end
		return 1
	end

	-- ===== zone et positions =====
	local function dansZone(index, position)
		local zone = partDe(index, "Zone")
		if not zone then return false end
		local l = zone.CFrame:PointToObjectSpace(position)
		local t = zone.Size
		return math.abs(l.X) <= t.X / 2 and math.abs(l.Y) <= t.Y / 2 and math.abs(l.Z) <= t.Z / 2
	end

	-- demi-hauteur d'une part dans le repère du monde (valable quelle que soit sa rotation)
	local function demiHauteur(part)
		local cf = part.CFrame
		local t = part.Size
		return (math.abs(cf.RightVector.Y) * t.X + math.abs(cf.UpVector.Y) * t.Y + math.abs(cf.LookVector.Y) * t.Z) / 2
	end

	local function cframeEmplacement(index, numero)
		local m = trouverModele(index)
		if not m then return nil end
		local dossierE = m:FindFirstChild("Emplacements")
		if not dossierE then return nil end
		local e = dossierE:FindFirstChild("E" .. numero)
		if not e or not e:IsA("BasePart") then return nil end
		local haut = e.Position + Vector3.new(0, demiHauteur(e), 0)
		-- les deux rangées se font face : chaque dino regarde vers l'allée centrale de la base
		local centre = Plan.bases[index].centre
		local sens = 1
		if haut.X > centre.X then sens = -1 end
		return CFrame.lookAt(haut, haut + Vector3.new(sens, 0, 0))
	end

	-- juste devant l'entrée, côté Tapis
	local function devantEntree(index, xVoulu)
		local zone = partDe(index, "Zone")
		local sens = versTapis(index)
		local centre = Plan.bases[index].centre
		local zBord = centre.Z + sens * Plan.base.profondeur / 2
		local largeur = Plan.base.largeur
		if zone then
			local bord = zone.CFrame:PointToWorldSpace(Vector3.new(0, 0, 0))
			local demiZ = (math.abs(zone.CFrame.LookVector.Z) * zone.Size.Z + math.abs(zone.CFrame.RightVector.Z) * zone.Size.X) / 2
			zBord = bord.Z + sens * demiZ
			centre = Vector3.new(bord.X, 0, bord.Z)
		end
		local entree = partDe(index, "Entree")
		local xMin = centre.X - largeur / 2 + 3
		local xMax = centre.X + largeur / 2 - 3
		if entree then
			local demiX = (math.abs(entree.CFrame.RightVector.X) * entree.Size.X + math.abs(entree.CFrame.LookVector.X) * entree.Size.Z) / 2
			xMin = entree.Position.X - math.max(demiX - 2, 0)
			xMax = entree.Position.X + math.max(demiX - 2, 0)
		end
		local x = math.clamp(xVoulu or centre.X, math.min(xMin, xMax), math.max(xMin, xMax))
		local position = Vector3.new(x, 3, zBord + sens * 5)
		return CFrame.lookAt(position, position + Vector3.new(0, 0, sens))
	end

	-- ===== aspect =====
	local Style = ctx.Style
	local GRIS_LIBRE = Color3.fromRGB(201, 206, 216)
	if Style and Style.boutons and Style.boutons.gris then GRIS_LIBRE = Style.boutons.gris[1] end
	-- même ordre de teintes que Builders/Bases : une couleur dominante par base
	local TEINTES = { Charte.lave, Charte.gemme, Charte.violet, Charte.herbe, Charte.dore, Charte.alerte, Charte.sable, Charte.jungle }
	local etiquettes = {} -- index -> { nom = TextLabel, compteGui = BillboardGui, compte = TextLabel }

	local function couleurBase(index)
		local m = trouverModele(index)
		local c = m and m:GetAttribute("Couleur")
		if typeof(c) == "Color3" then return c end
		c = TEINTES[((index - 1) % #TEINTES) + 1]
		if typeof(c) == "Color3" then return c end
		return Color3.new(1, 1, 1)
	end

	-- dimensions du nom géant (studs) : nom du propriétaire et pastille 🏠 au-dessus
	local NOM_LARGEUR, NOM_HAUTEUR, ICONE_HAUTEUR = 32, 6, 2.8
	local LIBRE_LARGEUR, LIBRE_HAUTEUR = 12, 2.2
	local CONTOUR = (Style and Style.couleurs and Style.couleurs.contour) or Charte.encre

	-- pastille ronde dans la couleur de la base, bordée de noir, avec la petite maison
	local function creerIcone(gui)
		local icone = Instance.new("TextLabel")
		icone.Name = "Icone"
		icone.LayoutOrder = 0
		icone.Size = UDim2.new(1, 0, 0.3, 0)
		icone.BackgroundTransparency = 0
		icone.BackgroundColor3 = GRIS_LIBRE
		icone.BorderSizePixel = 0
		icone.Text = "🏠"
		icone.TextScaled = true
		icone.TextColor3 = Color3.new(1, 1, 1)
		icone.Font = (Style and Style.police) or Charte.police
		icone.Visible = false
		local carre = Instance.new("UIAspectRatioConstraint")
		carre.AspectRatio = 1
		carre.Parent = icone
		local rond = Instance.new("UICorner")
		rond.CornerRadius = UDim.new(0.5, 0)
		rond.Parent = icone
		local bord = Instance.new("UIStroke")
		bord.Name = "Bordure"
		bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bord.Thickness = 3
		bord.Color = CONTOUR
		bord.Parent = icone
		local marge = Instance.new("UIPadding")
		marge.PaddingTop = UDim.new(0.17, 0)
		marge.PaddingBottom = UDim.new(0.17, 0)
		marge.PaddingLeft = UDim.new(0.17, 0)
		marge.PaddingRight = UDim.new(0.17, 0)
		marge.Parent = icone
		icone.Parent = gui
		return icone
	end

	-- crée (une seule fois) le nom géant et le compte à rebours flottants au-dessus de l'Entree
	local function etiquettesDe(index)
		local e = etiquettes[index]
		if e and e.nom.Parent and e.nom.Parent.Parent and e.compteGui.Parent then return e end
		if not Style or not Style.etiquette then return nil end
		local entree = partDe(index, "Entree")
		if not entree then return nil end
		local ancienNom = entree:FindFirstChild("NomGeant")
		if ancienNom then ancienNom:Destroy() end
		local ancienCompte = entree:FindFirstChild("CompteVerrou")
		if ancienCompte then ancienCompte:Destroy() end
		local haut = demiHauteur(entree)
		-- le nom flotte au-dessus de l'enseigne si elle existe, sinon au-dessus du portique
		local hauteurNom = haut + 7
		local enseigne = partDe(index, "Enseigne")
		if enseigne then
			hauteurNom = math.max(hauteurNom, enseigne.Position.Y + demiHauteur(enseigne) - entree.Position.Y + 5)
		end
		local nomGui, lignesNom = Style.etiquette(entree, {
			{ texte = "BASE LIBRE", couleur = GRIS_LIBRE, titre = true, contour = 4, nom = "Nom" },
		}, {
			Name = "NomGeant",
			largeur = NOM_LARGEUR,
			hauteurLigne = NOM_HAUTEUR,
			StudsOffset = Vector3.new(0, hauteurNom, 0),
			MaxDistance = 250,
		})
		local icone = creerIcone(nomGui)
		-- le nom repasse après la pastille dans l'ordre des enfants (même ordre que l'affichage)
		lignesNom[1].Parent = nil
		lignesNom[1].Parent = nomGui
		-- dégradé vertical clair -> foncé sur le nom (texte blanc teinté)
		local degrade = Instance.new("UIGradient")
		degrade.Name = "Degrade"
		degrade.Rotation = 90
		degrade.Color = ColorSequence.new(Color3.new(1, 1, 1))
		degrade.Parent = lignesNom[1]
		local compteGui, lignesCompte = Style.etiquette(entree, {
			{ texte = "", titre = true, contour = 4, nom = "Compte" },
		}, {
			Name = "CompteVerrou",
			largeur = 12,
			hauteurLigne = 4,
			StudsOffset = Vector3.new(0, haut + 2.5, 0),
			MaxDistance = 150,
		})
		compteGui.Enabled = false
		e = {
			nom = lignesNom[1], icone = icone, degrade = degrade, hauteurNom = hauteurNom,
			compteGui = compteGui, compte = lignesCompte[1],
		}
		etiquettes[index] = e
		return e
	end

	local function titre(index, texte)
		local enseigne = trouverModele(index) and trouverModele(index):FindFirstChild("Enseigne")
		if enseigne then
			local affiche = enseigne:FindFirstChild("Affiche", true)
			local label = affiche and affiche:FindFirstChild("Titre", true)
			if label and label:IsA("TextLabel") then
				label.Text = texte
			end
		end
		-- nom géant flottant : « Base de <Nom> » dans la couleur de la base, « BASE LIBRE » en gris
		local e = etiquettesDe(index)
		if e then
			local gui = e.nom.Parent
			local estGui = gui and gui:IsA("BillboardGui")
			if proprietaires[index] then
				local couleur = couleurBase(index)
				e.nom.Text = texte
				-- texte blanc sous un dégradé lumière -> couleur de la base -> ombre : du volume, lisible de loin
				e.nom.TextColor3 = Color3.new(1, 1, 1)
				e.degrade.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Charte.lumiere(couleur)),
					ColorSequenceKeypoint.new(0.55, couleur),
					ColorSequenceKeypoint.new(1, Charte.ombre(couleur)),
				})
				e.icone.BackgroundColor3 = couleur
				e.icone.Visible = true
				-- le nom du propriétaire est géant et visible de loin, la pastille 🏠 posée au-dessus
				local total = NOM_HAUTEUR + ICONE_HAUTEUR
				e.icone.Size = UDim2.new(1, 0, ICONE_HAUTEUR / total, 0)
				e.nom.Size = UDim2.new(1, 0, NOM_HAUTEUR / total, 0)
				if estGui then
					gui.Size = UDim2.new(NOM_LARGEUR, 0, total, 0)
					gui.StudsOffset = Vector3.new(0, e.hauteurNom + ICONE_HAUTEUR / 2, 0)
					gui.MaxDistance = 250
				end
			else
				e.nom.Text = "BASE LIBRE"
				e.nom.TextColor3 = GRIS_LIBRE
				e.degrade.Color = ColorSequence.new(Color3.new(1, 1, 1))
				e.icone.Visible = false
				e.nom.Size = UDim2.new(1, 0, 1, 0)
				-- une base libre reste discrète pour ne pas encombrer la vue
				if estGui then
					gui.Size = UDim2.new(LIBRE_LARGEUR, 0, LIBRE_HAUTEUR, 0)
					gui.StudsOffset = Vector3.new(0, e.hauteurNom, 0)
					gui.MaxDistance = 90
				end
			end
		end
	end

	-- ===== laser de l'entrée : faisceaux rouges (Beam) tendus d'un poteau à l'autre =====
	local NB_FAISCEAUX = 6
	local ALERTE_FIN = 10 -- secondes restantes à partir desquelles le halo clignote
	local TEXTURE_LASER = "rbxasset://textures/particles/sparkles_main.dds"
	local ROUGE_LASER = Charte.alerte
	local COEUR_LASER = Charte.lumiere(Charte.alerte)
	local lasers = {} -- index -> { entree, coeurs = {Beam}, halos = {Beam}, etincelles = {ParticleEmitter}, lueur = PointLight }

	local function attache(part, nom, position)
		local a = Instance.new("Attachment")
		a.Name = nom
		a.Position = position
		a.Parent = part
		return a
	end

	local function faisceau(part, nom, a0, a1, props)
		local b = Instance.new("Beam")
		b.Name = nom
		b.Attachment0 = a0
		b.Attachment1 = a1
		b.FaceCamera = true
		b.Segments = 1
		b.LightEmission = 1
		b.LightInfluence = 0
		b.Enabled = false
		for cle, valeur in pairs(props) do b[cle] = valeur end
		b.Parent = part
		return b
	end

	-- crée (une seule fois) le laser dans l'Entree ; tout est éteint tant que la base n'est pas verrouillée
	local function laserDe(index)
		local l = lasers[index]
		if l and l.entree.Parent then return l end
		local entree = partDe(index, "Entree")
		if not entree then return nil end
		for _, enfant in ipairs(entree:GetChildren()) do
			if string.sub(enfant.Name, 1, 5) == "Laser" then enfant:Destroy() end
		end
		l = { entree = entree, coeurs = {}, halos = {}, etincelles = {} }
		local demiX = entree.Size.X / 2
		local demiY = entree.Size.Y / 2
		local bas, hautLaser = -demiY + 0.9, demiY - 1.5
		local pas = (hautLaser - bas) / (NB_FAISCEAUX - 1)
		local transparenceHalo = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.25),
			NumberSequenceKeypoint.new(0.5, 0.55),
			NumberSequenceKeypoint.new(1, 0.25),
		})
		for k = 1, NB_FAISCEAUX do
			local y = bas + (k - 1) * pas
			local a0 = attache(entree, "LaserG" .. k, Vector3.new(-demiX, y, 0))
			local a1 = attache(entree, "LaserD" .. k, Vector3.new(demiX, y, 0))
			-- cœur fin presque blanc, puis halo rouge pailleté qui défile (sens alterné d'une ligne à l'autre)
			table.insert(l.coeurs, faisceau(entree, "LaserCoeur" .. k, a0, a1, {
				Color = ColorSequence.new(COEUR_LASER),
				Transparency = NumberSequence.new(0.05),
				Width0 = 0.16,
				Width1 = 0.16,
				Brightness = 3,
			}))
			local sens = 1
			if k % 2 == 0 then sens = -1 end
			table.insert(l.halos, faisceau(entree, "LaserHalo" .. k, a0, a1, {
				Color = ColorSequence.new(ROUGE_LASER),
				Transparency = transparenceHalo,
				Width0 = 0.85,
				Width1 = 0.85,
				Texture = TEXTURE_LASER,
				TextureMode = Enum.TextureMode.Wrap,
				TextureLength = 1.6,
				TextureSpeed = 2.2 * sens,
				Brightness = 2,
			}))
		end
		-- étincelles aux deux émetteurs (à mi-hauteur, contre chaque poteau)
		for _, cote in ipairs({ -1, 1 }) do
			local source = attache(entree, "LaserSource" .. cote, Vector3.new(cote * demiX, (bas + hautLaser) / 2, 0))
			local p = Instance.new("ParticleEmitter")
			p.Name = "LaserEtincelles"
			p.Texture = TEXTURE_LASER
			p.Color = ColorSequence.new(COEUR_LASER, ROUGE_LASER)
			p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0) })
			p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
			p.Lifetime = NumberRange.new(0.3, 0.6)
			p.Speed = NumberRange.new(1, 3)
			p.SpreadAngle = Vector2.new(180, 180)
			p.Rate = 14
			p.LightEmission = 1
			p.LightInfluence = 0
			p.Enabled = false
			p.Parent = source
			table.insert(l.etincelles, p)
		end
		-- lueur rouge sur le sol et les poteaux
		local lueur = Instance.new("PointLight")
		lueur.Name = "LaserLueur"
		lueur.Range = 16
		lueur.Brightness = 3
		lueur.Color = ROUGE_LASER
		lueur.Shadows = false
		lueur.Enabled = false
		lueur.Parent = entree
		l.lueur = lueur
		lasers[index] = l
		return l
	end

	-- allume / éteint le laser ; dans les dernières secondes, le halo clignote pour prévenir
	local function majLaser(index, actif, reste)
		local l = laserDe(index)
		if not l then return end
		local halo = actif
		if actif and reste and reste <= ALERTE_FIN then
			halo = math.floor(reste * 2) % 2 == 0
		end
		for _, b in ipairs(l.coeurs) do
			if b.Enabled ~= actif then b.Enabled = actif end
		end
		for _, b in ipairs(l.halos) do
			if b.Enabled ~= halo then b.Enabled = halo end
		end
		for _, p in ipairs(l.etincelles) do
			if p.Enabled ~= actif then p.Enabled = actif end
		end
		if l.lueur.Enabled ~= halo then l.lueur.Enabled = halo end
	end

	-- compte à rebours « 🔒 45 » au-dessus de l'Entree pendant le verrou (rouge dans les dernières secondes)
	local function majCompte(index)
		local reste = (finVerrou[index] or 0) - maintenant()
		if reste > 0 then
			majLaser(index, true, reste)
		end
		local e = etiquettesDe(index)
		if not e then return end
		if reste > 0 then
			local texte = "🔒 " .. math.ceil(reste)
			if e.compte.Text ~= texte then e.compte.Text = texte end
			local couleur = Color3.new(1, 1, 1)
			if reste <= ALERTE_FIN then couleur = ROUGE_LASER end
			if e.compte.TextColor3 ~= couleur then e.compte.TextColor3 = couleur end
			if not e.compteGui.Enabled then e.compteGui.Enabled = true end
		elseif e.compteGui.Enabled then
			e.compteGui.Enabled = false
			e.compte.Text = ""
		end
	end

	local function nombreEmplacements(joueur)
		local renaissances = 0
		if estJoueur(joueur) then
			renaissances = tonumber(joueur:GetAttribute("Renaissances")) or 0
		end
		local n = (EB.emplacementsDepart or 8) + math.floor(renaissances) * (EB.emplacementsParRenaissance or 1)
		return math.max(0, math.min(EMPLACEMENTS_MAX, n))
	end

	-- ===== emplacements verrouillés : podium éteint, pierre opaque, cadenas sur le plateau =====
	local apparencePiece = {} -- BasePart (socle / anneau) -> { Color, Transparency, Material }
	local piecesE = {}        -- index -> { [numero] = { socles = {parts}, anneau = part|nil } }
	local PIERRE_SOCLE = Charte.ombre and Charte.ombre(Charte.pierre) or Charte.pierre

	local function partsDe(inst)
		local liste = {}
		if inst:IsA("BasePart") then
			table.insert(liste, inst)
		end
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then table.insert(liste, d) end
		end
		return liste
	end

	local function centreDe(inst)
		if inst:IsA("BasePart") then return inst.Position end
		if inst:IsA("Model") then return inst:GetPivot().Position end
		return nil
	end

	-- associe chaque Socle / Anneau du Decor à son E<n> (attribut Emplacement ; sinon le plus proche en XZ)
	local function piecesEmplacements(index, m, dossierE)
		if piecesE[index] then return piecesE[index] end
		local table_ = {}
		for numero = 1, EMPLACEMENTS_MAX do table_[numero] = { socles = {}, anneau = nil } end
		local decor = m:FindFirstChild("Decor")
		if decor then
			local centresE = {}
			for numero = 1, EMPLACEMENTS_MAX do
				local e = dossierE:FindFirstChild("E" .. numero)
				if e and e:IsA("BasePart") then centresE[numero] = e.Position end
			end
			for _, enfant in ipairs(decor:GetChildren()) do
				if enfant.Name == "Socle" or enfant.Name == "Anneau" then
					local numero = enfant:GetAttribute("Emplacement")
					if type(numero) ~= "number" or not table_[numero] then
						numero = nil
						local c = centreDe(enfant)
						if c then
							local meilleur = 1.5
							for n, ce in pairs(centresE) do
								local d = Vector2.new(c.X - ce.X, c.Z - ce.Z).Magnitude
								if d < meilleur then meilleur, numero = d, n end
							end
						end
						if numero then enfant:SetAttribute("Emplacement", numero) end
					end
					if numero then
						if enfant.Name == "Socle" then
							for _, p in ipairs(partsDe(enfant)) do table.insert(table_[numero].socles, p) end
						elseif enfant:IsA("BasePart") then
							table_[numero].anneau = enfant
						end
					end
				end
			end
		end
		piecesE[index] = table_
		return table_
	end

	local function memoriser(p)
		if not apparencePiece[p] then
			apparencePiece[p] = { Color = p.Color, Transparency = p.Transparency, Material = p.Material }
		end
		return apparencePiece[p]
	end

	local function restaurer(p)
		local o = apparencePiece[p]
		if o then
			p.Color = o.Color
			p.Transparency = o.Transparency
			p.Material = o.Material
		end
	end

	-- cadenas peint sur le dessus du plateau (créé une fois, activé / coupé ensuite)
	local function cadenas(e)
		local gui = e:FindFirstChild("Cadenas")
		if gui then return gui end
		if not Style or not Style.texte then return nil end
		gui = Instance.new("SurfaceGui")
		gui.Name = "Cadenas"
		gui.Face = Enum.NormalId.Top
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 50
		gui.LightInfluence = 0.4
		gui.ZOffset = 1
		gui.Enabled = false
		local fond = Instance.new("Frame")
		fond.Name = "Fond"
		fond.AnchorPoint = Vector2.new(0.5, 0.5)
		fond.Position = UDim2.fromScale(0.5, 0.5)
		fond.Size = UDim2.fromScale(0.78, 0.78)
		fond.BackgroundColor3 = Style.couleurs.fond or Charte.encre
		fond.BackgroundTransparency = 0.15
		fond.BorderSizePixel = 0
		fond.Parent = gui
		if Style.coins then Style.coins(fond, 36) end
		if Style.bordure then Style.bordure(fond, 6, Style.couleurs.contour) end
		Style.texte(fond, {
			Name = "Icone",
			Text = "🔒",
			titre = true,
			contour = 4,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.06),
			Size = UDim2.fromScale(0.8, 0.6),
		})
		Style.texte(fond, {
			Name = "Legende",
			Text = "VERROUILLÉ",
			titre = true,
			contour = 4,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.94),
			Size = UDim2.fromScale(0.9, 0.24),
		})
		gui.Parent = e
		return gui
	end

	local function majEmplacements(index)
		local m = trouverModele(index)
		if not m then return end
		local dossierE = m:FindFirstChild("Emplacements")
		if not dossierE then return end
		local pieces = piecesEmplacements(index, m, dossierE)
		local n = nombreEmplacements(proprietaires[index])
		for numero = 1, EMPLACEMENTS_MAX do
			local e = dossierE:FindFirstChild("E" .. numero)
			if e and e:IsA("BasePart") then
				if not apparenceE[e] then
					apparenceE[e] = { Color = e.Color, Transparency = e.Transparency, Material = e.Material }
				end
				local origine = apparenceE[e]
				local debloque = numero <= n
				e:SetAttribute("Debloque", debloque)
				local lot = pieces[numero]
				local anneau = lot and lot.anneau
				if anneau then memoriser(anneau) end
				if lot then for _, p in ipairs(lot.socles) do memoriser(p) end end
				local gui = cadenas(e)
				if debloque then
					e.Color = origine.Color
					e.Transparency = origine.Transparency
					e.Material = origine.Material
					if anneau then restaurer(anneau) end
					if lot then for _, p in ipairs(lot.socles) do restaurer(p) end end
					if gui then gui.Enabled = false end
				else
					-- plateau de pierre opaque, bandeau lumineux éteint, socle assombri : une place à acheter
					e.Color = Charte.pierre
					e.Transparency = origine.Transparency
					e.Material = Enum.Material.SmoothPlastic
					if anneau then
						anneau.Color = Charte.pierre
						anneau.Material = Enum.Material.SmoothPlastic
						anneau.Transparency = apparencePiece[anneau].Transparency
					end
					if lot then
						for _, p in ipairs(lot.socles) do p.Color = PIERRE_SOCLE end
					end
					if gui then gui.Enabled = true end
				end
			end
		end
	end

	local function aspectEntree(index, verrouillee)
		local entree = partDe(index, "Entree")
		if not entree then return end
		if not apparenceEntree[index] then
			apparenceEntree[index] = {
				Color = entree.Color, Material = entree.Material, Transparency = entree.Transparency,
			}
		end
		local o = apparenceEntree[index]
		if verrouillee then
			-- voile de champ de force rouge à peine visible : les faisceaux laser font l'essentiel
			entree.Material = Enum.Material.ForceField
			entree.Color = ROUGE_LASER
			entree.Transparency = 0.6
		else
			entree.Material = o.Material
			entree.Color = o.Color
			entree.Transparency = o.Transparency
		end
		majLaser(index, verrouillee, (finVerrou[index] or 0) - maintenant())
	end

	local function invitesVerrou(index)
		local m = trouverModele(index)
		local liste = {}
		if not m then return liste end
		local bouton = m:FindFirstChild("BoutonVerrou")
		if not bouton then return liste end
		for _, d in ipairs(bouton:GetDescendants()) do
			if d:IsA("ProximityPrompt") and d.Name == "Verrouiller" then
				table.insert(liste, d)
			end
		end
		if bouton:IsA("ProximityPrompt") and bouton.Name == "Verrouiller" then
			table.insert(liste, bouton)
		end
		return liste
	end

	-- texte de l'invite : temps restant du verrou ou de la recharge
	local function majInvite(index)
		local t = maintenant()
		local texte = "Verrouiller"
		local objet = "Base libre"
		if proprietaires[index] then
			objet = "Base de " .. proprietaires[index].DisplayName
		end
		if (finVerrou[index] or 0) > t then
			texte = "Verrouillée : " .. math.ceil(finVerrou[index] - t) .. " s"
		elseif (finRecharge[index] or 0) > t then
			texte = "Recharge : " .. math.ceil(finRecharge[index] - t) .. " s"
		end
		for _, invite in ipairs(invitesVerrou(index)) do
			if invite.ActionText ~= texte then invite.ActionText = texte end
			if invite.ObjectText ~= objet then invite.ObjectText = objet end
		end
		majCompte(index)
	end

	local function estVerrouillee(index)
		local m = trouverModele(index)
		return m ~= nil and m:GetAttribute("Verrouillee") == true and (finVerrou[index] or 0) > maintenant()
	end

	local function deverrouiller(index, avecRecharge)
		local m = trouverModele(index)
		local etaitVerrouillee = (finVerrou[index] or 0) > 0
		finVerrou[index] = 0
		if avecRecharge then
			finRecharge[index] = maintenant() + RECHARGE
		else
			finRecharge[index] = 0
		end
		if m then
			m:SetAttribute("Verrouillee", false)
			m:SetAttribute("FinVerrou", 0)
		end
		aspectEntree(index, false)
		majInvite(index)
		if etaitVerrouillee then
			local entree = partDe(index, "Entree")
			effet("Verrou", entree and entree.Position or Plan.bases[index].centre, { index = index, actif = false })
			if avecRecharge then
				notifier(proprietaires[index], "Ta base n'est plus verrouillée", "alerte")
			end
		end
	end

	local function verrouiller(index, joueur)
		local m = trouverModele(index)
		if not m then return end
		local fin = maintenant() + DUREE_VERROU
		finVerrou[index] = fin
		m:SetAttribute("Verrouillee", true)
		m:SetAttribute("FinVerrou", fin)
		aspectEntree(index, true)
		majInvite(index)
		Bus.emettre("BaseVerrouillee", index, joueur)
		local entree = partDe(index, "Entree")
		effet("Verrou", entree and entree.Position or Plan.bases[index].centre, { index = index, actif = true })
		notifier(joueur, "Base verrouillée pendant " .. DUREE_VERROU .. " s", "succes")
	end

	-- ===== apparition =====
	local function teleporter(joueur, personnage)
		local index = baseDe[joueur]
		if not index then return end
		local apparition = partDe(index, "Apparition")
		if not apparition then return end
		local position = apparition.Position + Vector3.new(0, 3, 0)
		local cf = CFrame.lookAt(position, position + Vector3.new(0, 0, versTapis(index)))
		pcall(function()
			personnage:PivotTo(cf)
		end)
	end

	local function surPersonnage(joueur, personnage)
		task.spawn(function()
			local racine = personnage:WaitForChild("HumanoidRootPart", 10)
			if not racine or not personnage.Parent or not joueur.Parent then return end
			teleporter(joueur, personnage)
			-- le moteur peut replacer le personnage sur la SpawnLocation juste après : on vérifie une fois
			task.wait(0.2)
			local index = baseDe[joueur]
			if index and personnage.Parent and racine.Parent and not dansZone(index, racine.Position) then
				teleporter(joueur, personnage)
			end
		end)
	end

	-- ===== attribution =====
	local function remiseAZero(index)
		local m = trouverModele(index)
		if m then
			m:SetAttribute("Proprietaire", 0)
			m:SetAttribute("NomProprietaire", "")
			m:SetAttribute("Verrouillee", false)
			m:SetAttribute("FinVerrou", 0)
		end
		finVerrou[index] = 0
		finRecharge[index] = 0
		aspectEntree(index, false)
		titre(index, "Base libre")
		majEmplacements(index)
		majInvite(index)
	end

	local function attribuer(joueur)
		if not joueur.Parent or baseDe[joueur] then return end
		local index = nil
		for i = 1, NB_BASES do
			if not index and not proprietaires[i] and trouverModele(i) then
				index = i
			end
		end
		if not index then
			notifier(joueur, "Aucune base libre pour le moment", "alerte")
			return
		end
		proprietaires[index] = joueur
		baseDe[joueur] = index
		local m = trouverModele(index)
		m:SetAttribute("Proprietaire", joueur.UserId)
		m:SetAttribute("NomProprietaire", joueur.DisplayName)
		m:SetAttribute("Verrouillee", false)
		m:SetAttribute("FinVerrou", 0)
		finVerrou[index] = 0
		finRecharge[index] = 0
		aspectEntree(index, false)
		titre(index, "Base de " .. joueur.DisplayName)
		majEmplacements(index)
		majInvite(index)
		joueur:SetAttribute("Base", index)
		Bus.emettre("BaseAttribuee", joueur, index)
		if joueur.Character then
			surPersonnage(joueur, joueur.Character)
		end
	end

	local function attribuerEnAttente()
		for _, j in ipairs(Players:GetPlayers()) do
			if not baseDe[j] then attribuer(j) end
		end
	end

	local function surArrivee(joueur)
		if connexions[joueur] then return end
		local liste = {}
		connexions[joueur] = liste
		table.insert(liste, joueur.CharacterAdded:Connect(function(personnage)
			surPersonnage(joueur, personnage)
		end))
		table.insert(liste, joueur:GetAttributeChangedSignal("Renaissances"):Connect(function()
			local index = baseDe[joueur]
			if index then majEmplacements(index) end
		end))
		attribuer(joueur)
	end

	local function surDepart(joueur)
		local liste = connexions[joueur]
		if liste then
			for _, c in ipairs(liste) do c:Disconnect() end
		end
		connexions[joueur] = nil
		dernierAvis[joueur] = nil
		local index = baseDe[joueur]
		if index then
			-- les écouteurs peuvent encore demander BaseDe pendant l'émission
			Bus.emettre("BaseLiberee", joueur, index)
			baseDe[joueur] = nil
			if proprietaires[index] == joueur then proprietaires[index] = nil end
			remiseAZero(index)
			task.defer(attribuerEnAttente)
		end
	end

	-- ===== répondeurs =====
	Bus.repondre("BaseDe", function(joueur)
		if not estJoueur(joueur) then return nil end
		return baseDe[joueur]
	end)
	Bus.repondre("ModeleBase", function(index)
		if not estIndex(index) then return nil end
		return trouverModele(index)
	end)
	Bus.repondre("JoueurDeBase", function(index)
		if not estIndex(index) then return nil end
		return proprietaires[index]
	end)
	Bus.repondre("DansBase", function(position, index)
		if typeof(position) ~= "Vector3" or not estIndex(index) then return false end
		return dansZone(index, position)
	end)
	Bus.repondre("BaseVerrouillee", function(index)
		if not estIndex(index) then return false end
		return estVerrouillee(index)
	end)
	Bus.repondre("NombreEmplacements", function(joueur)
		return nombreEmplacements(joueur)
	end)
	Bus.repondre("CFrameEmplacement", function(index, numero)
		if not estIndex(index) or type(numero) ~= "number" then return nil end
		numero = math.floor(numero)
		if numero < 1 or numero > EMPLACEMENTS_MAX then return nil end
		return cframeEmplacement(index, numero)
	end)

	Bus.ecouter("Renaissance", function(joueur)
		if not estJoueur(joueur) then return end
		local index = baseDe[joueur]
		if index then majEmplacements(index) end
	end)

	-- ===== invite « Verrouiller » =====
	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Verrouiller" then return end
		if not estJoueur(joueur) then return end
		local index = nil
		for i = 1, NB_BASES do
			local m = trouverModele(i)
			if not index and m and invite:IsDescendantOf(m) then index = i end
		end
		if not index then return end
		if proprietaires[index] ~= joueur then
			notifier(joueur, "Ce n'est pas ta base", "alerte")
			return
		end
		local t = maintenant()
		if (finVerrou[index] or 0) > t then
			notifier(joueur, "Ta base est déjà verrouillée", "info")
			return
		end
		if (finRecharge[index] or 0) > t then
			notifier(joueur, "Verrou en recharge : " .. math.ceil(finRecharge[index] - t) .. " s", "info")
			return
		end
		verrouiller(index, joueur)
	end)

	-- ===== joueurs =====
	for i = 1, NB_BASES do
		remiseAZero(i)
	end
	Players.PlayerAdded:Connect(surArrivee)
	Players.PlayerRemoving:Connect(surDepart)
	for _, joueur in ipairs(Players:GetPlayers()) do
		task.spawn(surArrivee, joueur)
	end

	-- ===== boucle du verrou : fin, texte de l'invite, expulsion des intrus =====
	local function repousserIntrus(index)
		local proprio = proprietaires[index]
		for _, j in ipairs(Players:GetPlayers()) do
			if j ~= proprio then
				local perso = j.Character
				local racine = perso and perso:FindFirstChild("HumanoidRootPart")
				if racine and racine:IsA("BasePart") and dansZone(index, racine.Position) then
					local cf = devantEntree(index, racine.Position.X)
					pcall(function()
						racine.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						perso:PivotTo(cf)
					end)
					local t = os.clock()
					if not dernierAvis[j] or t - dernierAvis[j] > 3 then
						dernierAvis[j] = t
						notifier(j, "Cette base est verrouillée !", "alerte")
					end
				end
			end
		end
	end

	while true do
		task.wait(PERIODE)
		local t = maintenant()
		for index = 1, NB_BASES do
			local ok, err = pcall(function()
				if (finVerrou[index] or 0) > 0 then
					if finVerrou[index] <= t then
						deverrouiller(index, true)
					else
						repousserIntrus(index)
						majInvite(index)
					end
				elseif (finRecharge[index] or 0) > 0 then
					if finRecharge[index] <= t then finRecharge[index] = 0 end
					majInvite(index)
				end
			end)
			if not ok then
				warn("[Dino] Bases, boucle du verrou : " .. tostring(err))
			end
		end
	end
end

return M
