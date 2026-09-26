-- Builders/Maison.lua : la petite maison à défendre, au centre de la Prairie.
-- Murs crème à colombages, toit orange en coins avec plateforme 4 x 4 à Y = 14 (tourelle),
-- porte, fenêtres éclairées, cheminée, perron vers le parvis, sacs de sable et planches.
-- États visuels selon PVMaison / PVMaisonMax : planches clouées et fissures (< 66 %),
-- fumée et flammes (< 33 %), clignotement rouge des murs à chaque perte de PV.
-- Budget : 250 parts.
local M = {}

local BUDGET = 250
local DEMI = 8                -- demi-côté des murs (16 x 16)
local Y_BAS_MUR = 1           -- dessus des fondations
local Y_HAUT_MUR = 8          -- haut des murs, bas du toit
local Y_FAITE = 13            -- haut des pentes du toit
local Y_PLATEFORME = 14       -- dessus de la plateforme de la tourelle
local DEBORD = 9              -- débord du toit
local D_FACE = 8              -- face extérieure des murs
local Y_FENETRE = 4.6
local T_FENETRE = 5.2
local SEUIL_ABIME = 0.66
local SEUIL_CRITIQUE = 0.33
local DUREE_CLIGNOTEMENT = 0.35
local GRAINE = 1616

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	local infoMaison = Plan.maison or {}
	local centre = infoMaison.centre or Vector3.new(0, 0, 0)
	local cx, cy, cz = centre.X, centre.Y, centre.Z
	local rng = Outils.aleatoire(GRAINE)

	-- ===== compteur de parts =====
	local nbParts = 0
	local function creer(genre, parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return Outils[genre](parent, props)
	end

	-- ===== repères =====
	-- les 4 faces : 1 = avant (+Z, vers le parvis), puis +X, -Z, -X
	local HAUT = Vector3.new(0, 1, 0)
	local normales = {
		Vector3.new(0, 0, 1),
		Vector3.new(1, 0, 0),
		Vector3.new(0, 0, -1),
		Vector3.new(-1, 0, 0),
	}
	-- repère d'une face : X le long du mur, Y vers le haut, Z vers l'extérieur
	local function surFace(k, t, y, d)
		local n = normales[k]
		local tangente = Vector3.new(n.Z, 0, -n.X)
		local pos = Vector3.new(cx, cy, cz) + n * d + tangente * t + HAUT * y
		return CFrame.fromMatrix(pos, tangente, HAUT, n)
	end
	local function point(x, y, z)
		return CFrame.new(cx + x, cy + y, cz + z)
	end

	-- couleurs
	local cCreme = Charte.creme
	local cTerre = Charte.terre
	local cTerreSombre = Charte.ombre(Charte.terre)
	local cToit = Charte.toit
	local cToitSombre = Charte.ombre(Charte.toit)
	local cToitClair = Charte.lumiere(Charte.toit)
	local cVitre = Charte.lumiere(Charte.dore)
	local cPierre = Charte.lumiere(Charte.ardoise)
	local cSable = Charte.lumiere(Charte.terre)
	local cSableSombre = Charte.ombre(cSable)

	local structure = Outils.modele(dossier, "Structure")
	local decor = Outils.modele(dossier, "Abords")
	local degats = Outils.dossier(dossier, "Degats")

	-- ===== fondations et murs =====
	creer("bloc", structure, {
		Name = "Fondations",
		Size = Vector3.new(17, 1, 17),
		CFrame = point(0, 0.5, 0),
		Color = cPierre,
	})

	local murs = {}
	local hauteurMur = Y_HAUT_MUR - Y_BAS_MUR
	for k = 1, 4 do
		local mur = creer("bloc", structure, {
			Name = "Mur",
			Size = Vector3.new(16, hauteurMur, 1),
			CFrame = surFace(k, 0, Y_BAS_MUR + hauteurMur / 2, D_FACE - 0.5),
			Color = cCreme,
		})
		if mur then
			table.insert(murs, mur)
		end
	end
	-- poteaux d'angle
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			creer("bloc", structure, {
				Name = "PoteauAngle",
				Size = Vector3.new(1.2, hauteurMur, 1.2),
				CFrame = point(sx * 7.9, Y_BAS_MUR + hauteurMur / 2, sz * 7.9),
				Color = cTerre,
			})
		end
	end

	-- ===== colombages =====
	local yBasPoutre, yHautPoutre = 1.35, 7.65
	local longueurDiag = math.sqrt(4.4 * 4.4 + 6.3 * 6.3)
	local angleDiag = math.asin(4.4 / longueurDiag)
	for k = 1, 4 do
		-- sablière haute
		creer("bloc", structure, {
			Name = "Colombage",
			Size = Vector3.new(16, 0.35, 0.3),
			CFrame = surFace(k, 0, yHautPoutre, D_FACE + 0.1),
			Color = cTerre,
		})
		-- sablière basse (coupée par la porte à l'avant)
		if k == 1 then
			for _, s in ipairs({ -1, 1 }) do
				creer("bloc", structure, {
					Name = "Colombage",
					Size = Vector3.new(6.5, 0.35, 0.3),
					CFrame = surFace(k, s * 4.75, yBasPoutre, D_FACE + 0.1),
					Color = cTerre,
				})
			end
		else
			creer("bloc", structure, {
				Name = "Colombage",
				Size = Vector3.new(16, 0.35, 0.3),
				CFrame = surFace(k, 0, yBasPoutre, D_FACE + 0.1),
				Color = cTerre,
			})
		end
		-- montants
		for _, s in ipairs({ -1, 1 }) do
			creer("bloc", structure, {
				Name = "Colombage",
				Size = Vector3.new(0.35, yHautPoutre - yBasPoutre, 0.3),
				CFrame = surFace(k, s * 2.2, (yHautPoutre + yBasPoutre) / 2, D_FACE + 0.1),
				Color = cTerre,
			})
		end
		-- croix de Saint-André au milieu (sauf à l'avant, où est la porte)
		if k ~= 1 then
			for _, s in ipairs({ -1, 1 }) do
				creer("bloc", structure, {
					Name = "Colombage",
					Size = Vector3.new(0.3, longueurDiag, 0.25),
					CFrame = surFace(k, 0, (yHautPoutre + yBasPoutre) / 2, D_FACE + 0.08) * CFrame.Angles(0, 0, s * angleDiag),
					Color = cTerre,
				})
			end
		end
	end

	-- ===== fenêtres éclairées =====
	local fenetres = Outils.modele(dossier, "Fenetres")
	for k = 1, 4 do
		for _, s in ipairs({ -1, 1 }) do
			local t = s * T_FENETRE
			local vitre = creer("bloc", fenetres, {
				Name = "Vitre",
				Size = Vector3.new(2.4, 2.4, 0.3),
				CFrame = surFace(k, t, Y_FENETRE, D_FACE),
				Color = cVitre,
				Material = Enum.Material.Neon,
			})
			if vitre then
				pcall(function()
					Outils.lumiere(vitre, { Range = 9, Brightness = 1.2, Color = cVitre })
				end)
			end
			creer("bloc", fenetres, {
				Name = "Meneau",
				Size = Vector3.new(0.2, 2.4, 0.2),
				CFrame = surFace(k, t, Y_FENETRE, D_FACE + 0.2),
				Color = cTerre,
			})
			creer("bloc", fenetres, {
				Name = "Linteau",
				Size = Vector3.new(3, 0.4, 0.4),
				CFrame = surFace(k, t, Y_FENETRE + 1.4, D_FACE + 0.15),
				Color = cTerre,
			})
			creer("bloc", fenetres, {
				Name = "Appui",
				Size = Vector3.new(3.2, 0.3, 0.6),
				CFrame = surFace(k, t, Y_FENETRE - 1.35, D_FACE + 0.25),
				Color = cTerreSombre,
			})
			for _, c in ipairs({ -1, 1 }) do
				creer("bloc", fenetres, {
					Name = "Volet",
					Size = Vector3.new(1.1, 2.6, 0.2),
					CFrame = surFace(k, t + c * 1.9, Y_FENETRE, D_FACE + 0.1),
					Color = cToit,
				})
			end
		end
	end

	-- ===== porte =====
	creer("bloc", structure, {
		Name = "Porte",
		Size = Vector3.new(2.8, 5, 0.3),
		CFrame = surFace(1, 0, Y_BAS_MUR + 2.5, D_FACE + 0.05),
		Color = cTerreSombre,
	})
	creer("boule", structure, {
		Name = "Poignee",
		Size = Vector3.new(0.4, 0.4, 0.4),
		CFrame = surFace(1, 0.9, Y_BAS_MUR + 2.5, D_FACE + 0.3),
		Color = Charte.dore,
	})
	creer("bloc", structure, {
		Name = "LinteauPorte",
		Size = Vector3.new(3.6, 0.5, 0.5),
		CFrame = surFace(1, 0, Y_BAS_MUR + 5.25, D_FACE + 0.1),
		Color = cTerre,
	})
	creer("bloc", structure, {
		Name = "Auvent",
		Size = Vector3.new(4, 0.3, 1.6),
		CFrame = surFace(1, 0, Y_HAUT_MUR - 1, D_FACE + 0.8) * CFrame.Angles(math.rad(12), 0, 0),
		Color = cToit,
	})

	-- ===== toit en coins =====
	local toit = Outils.modele(dossier, "Toit")
	local largeurPente = DEBORD - 2
	local hauteurPente = Y_FAITE - Y_HAUT_MUR
	for _, s in ipairs({ -1, 1 }) do
		for i = 0, 2 do
			local z = -6 + i * 6
			local couleur = cToit
			if i == 1 then
				couleur = cToitClair
			end
			-- le coin monte vers +Z local : on l'oriente pour que la pente descende vers l'extérieur
			creer("coin", toit, {
				Name = "Pente",
				Size = Vector3.new(6, hauteurPente, largeurPente),
				CFrame = point(s * (2 + largeurPente / 2), Y_HAUT_MUR + hauteurPente / 2, z) * CFrame.Angles(0, math.rad(-90 * s), 0),
				Color = couleur,
			})
		end
		creer("bloc", toit, {
			Name = "Rive",
			Size = Vector3.new(0.5, 0.4, 18.4),
			CFrame = point(s * DEBORD, Y_HAUT_MUR, 0),
			Color = cToitSombre,
		})
		-- oeil-de-boeuf sur chaque pignon
		creer("cylindre", toit, {
			Name = "OeilDeBoeuf",
			Size = Vector3.new(0.3, 1.8, 1.8),
			CFrame = point(0, 10.5, s * 9.05) * CFrame.Angles(0, math.rad(90), 0),
			Color = cVitre,
			Material = Enum.Material.Neon,
		})
	end
	creer("bloc", toit, {
		Name = "Faite",
		Size = Vector3.new(4, hauteurPente, 18),
		CFrame = point(0, Y_HAUT_MUR + hauteurPente / 2, 0),
		Color = cToitSombre,
	})
	local plateforme = creer("bloc", toit, {
		Name = "PlateformeTourelle",
		Size = Vector3.new(4, Y_PLATEFORME - Y_FAITE, 4),
		CFrame = point(0, (Y_PLATEFORME + Y_FAITE) / 2, 0),
		Color = cToitClair,
	})
	if plateforme then
		plateforme:SetAttribute("HauteurDessus", cy + Y_PLATEFORME)
	end

	-- ===== cheminée =====
	local xChem, zChem = -5.5, -4.5
	creer("bloc", toit, {
		Name = "Cheminee",
		Size = Vector3.new(1.8, 4.5, 1.8),
		CFrame = point(xChem, 11.25, zChem),
		Color = Charte.ardoise,
	})
	local chapeau = creer("bloc", toit, {
		Name = "ChapeauCheminee",
		Size = Vector3.new(2.2, 0.5, 2.2),
		CFrame = point(xChem, Y_PLATEFORME - 0.25, zChem),
		Color = cPierre,
	})

	-- ===== perron vers le parvis =====
	creer("bloc", decor, {
		Name = "Perron",
		Size = Vector3.new(6, 1, 1.8),
		CFrame = surFace(1, 0, 0.5, 9.4),
		Color = cPierre,
	})
	creer("bloc", decor, {
		Name = "Marche",
		Size = Vector3.new(6.4, 0.5, 1),
		CFrame = surFace(1, 0, 0.25, 10.8),
		Color = Charte.ombre(cPierre),
	})
	for _, s in ipairs({ -1, 1 }) do
		creer("bloc", decor, {
			Name = "PoteauPerron",
			Size = Vector3.new(0.4, 2.2, 0.4),
			CFrame = surFace(1, s * 2.8, 2.1, 9.9),
			Color = cTerre,
		})
		local lanterne = creer("bloc", decor, {
			Name = "Lanterne",
			Size = Vector3.new(0.7, 0.7, 0.7),
			CFrame = surFace(1, s * 2.8, 3.55, 9.9),
			Color = cVitre,
			Material = Enum.Material.Neon,
		})
		if lanterne then
			pcall(function()
				Outils.lumiere(lanterne, { Range = 8, Brightness = 1, Color = cVitre })
			end)
		end
	end

	-- ===== panneau « Maison » =====
	if nbParts + 2 <= BUDGET then
		local ok = pcall(function()
			Outils.panneau(decor, {
				nom = "PanneauMaison",
				position = Vector3.new(cx + 4.4, cy, cz + 11.3),
				texte = "Maison",
				largeur = 3.6,
				couleur = cCreme,
				couleurTexte = Charte.encre,
			})
		end)
		if ok then
			nbParts = nbParts + 2
		end
	end

	-- ===== sacs de sable =====
	local sacs = Outils.modele(dossier, "SacsDeSable")
	local tailleSac = Vector3.new(1.4, 0.7, 0.9)
	local indiceSac = 0
	local function sac(cf)
		indiceSac = indiceSac + 1
		local couleur = cSable
		if indiceSac % 2 == 0 then
			couleur = cSableSombre
		end
		creer("bloc", sacs, {
			Name = "Sac",
			Size = tailleSac,
			CFrame = cf * CFrame.Angles(0, math.rad(rng:NextNumber(-6, 6)), 0),
			Color = couleur,
		})
	end
	for k = 1, 4 do
		for _, s in ipairs({ -1, 1 }) do
			for i = 0, 3 do
				sac(surFace(k, s * (4.2 + i * 1.5), 0.35, 10))
			end
			for i = 0, 2 do
				sac(surFace(k, s * (4.95 + i * 1.5), 1.05, 10))
			end
		end
	end
	for _, sx in ipairs({ -1, 1 }) do
		for _, sz in ipairs({ -1, 1 }) do
			sac(point(sx * 9.95, 0.35, sz * 9.95) * CFrame.Angles(0, math.rad(45), 0))
		end
	end

	-- ===== planches appuyées et piles de planches =====
	local planches = Outils.modele(dossier, "Planches")
	local inclinaison = math.rad(12)
	for k = 2, 4 do
		for _, t in ipairs({ -3.0, 3.1 }) do
			creer("bloc", planches, {
				Name = "Planche",
				Size = Vector3.new(0.9, 5, 0.2),
				CFrame = surFace(k, t, 2.5 * math.cos(inclinaison), D_FACE + 0.3 + 2.5 * math.sin(inclinaison)) * CFrame.Angles(-inclinaison, 0, 0),
				Color = cTerre,
			})
		end
	end
	for _, k in ipairs({ 2, 4 }) do
		for i = 0, 2 do
			local couleur = cTerre
			if i == 1 then
				couleur = cTerreSombre
			end
			creer("bloc", planches, {
				Name = "PilePlanches",
				Size = Vector3.new(3.5, 0.2, 0.8),
				CFrame = surFace(k, -6, 0.1 + i * 0.2, 9) * CFrame.Angles(0, math.rad(rng:NextNumber(-5, 5)), 0),
				Color = couleur,
			})
		end
	end

	-- ===== éléments de dégâts (cachés au départ) =====
	local elementsAbimes = {}
	local function cacher(part)
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end
	-- planches clouées sur les fenêtres
	for k = 1, 4 do
		for _, s in ipairs({ -1, 1 }) do
			for _, a in ipairs({ -25, 25 }) do
				local p = creer("bloc", degats, {
					Name = "PlancheClouee",
					Size = Vector3.new(3.2, 0.45, 0.15),
					CFrame = surFace(k, s * T_FENETRE, Y_FENETRE, D_FACE + 0.45) * CFrame.Angles(0, 0, math.rad(a)),
					Color = cTerre,
				})
				if p then
					cacher(p)
					table.insert(elementsAbimes, p)
				end
			end
		end
	end
	-- fissures sombres sur les murs
	local fissures = {
		{ t = -3.1, y = 6.6, a = 20, l = 1.4 },
		{ t = 5.5, y = 2.4, a = -35, l = 1.6 },
		{ t = -6, y = 6.8, a = 70, l = 1.2 },
	}
	for k = 1, 4 do
		for _, f in ipairs(fissures) do
			local p = creer("bloc", degats, {
				Name = "Fissure",
				Size = Vector3.new(0.12, f.l, 0.05),
				CFrame = surFace(k, f.t, f.y, D_FACE + 0.03) * CFrame.Angles(0, 0, math.rad(f.a)),
				Color = Charte.encre,
			})
			if p then
				cacher(p)
				table.insert(elementsAbimes, p)
			end
		end
	end

	-- fumée et flammes (désactivées au départ)
	local effetsCritiques = {}
	local function ajouterEffet(classe, parent, props)
		if not parent then
			return
		end
		local ok, effet = pcall(function()
			local e = Instance.new(classe)
			for cle, valeur in pairs(props) do
				e[cle] = valeur
			end
			e.Enabled = false
			e.Parent = parent
			return e
		end)
		if ok and effet then
			table.insert(effetsCritiques, effet)
		end
	end
	local proprietesFumee = {
		Color = Charte.ardoise,
		Opacity = 0.45,
		RiseVelocity = 5,
		Size = 2.5,
	}
	ajouterEffet("Smoke", chapeau, proprietesFumee)
	local foyers = {
		{ x = 5, z = 3 },
		{ x = -4, z = -2 },
		{ x = 6, z = -5 },
	}
	for _, f in ipairs(foyers) do
		local yToit = Y_HAUT_MUR + (DEBORD - math.abs(f.x)) * hauteurPente / largeurPente
		local foyer = creer("bloc", degats, {
			Name = "Foyer",
			Size = Vector3.new(0.5, 0.5, 0.5),
			CFrame = point(f.x, yToit + 0.3, f.z),
			Color = cToit,
		})
		if foyer then
			cacher(foyer)
			ajouterEffet("Fire", foyer, {
				Color = cToit,
				SecondaryColor = Charte.dore,
				Size = 3,
				Heat = 6,
			})
			ajouterEffet("Smoke", foyer, proprietesFumee)
		end
	end

	-- ===== états visuels =====
	local Etat = ctx.Etat
	if not Etat then
		return
	end

	local TweenService = nil
	pcall(function()
		TweenService = game:GetService("TweenService")
	end)

	local couleursMurs = {}
	for i, mur in ipairs(murs) do
		couleursMurs[i] = mur.Color
	end
	local tweensMurs = {}

	local function remettreMurs()
		for i, mur in ipairs(murs) do
			if tweensMurs[i] then
				pcall(function()
					tweensMurs[i]:Cancel()
				end)
				tweensMurs[i] = nil
			end
			if mur.Parent then
				mur.Color = couleursMurs[i]
			end
		end
	end

	local function clignoter()
		for i, mur in ipairs(murs) do
			if mur.Parent then
				if tweensMurs[i] then
					pcall(function()
						tweensMurs[i]:Cancel()
					end)
					tweensMurs[i] = nil
				end
				mur.Color = Charte.alerte
				local tween = nil
				if TweenService then
					pcall(function()
						tween = TweenService:Create(mur, TweenInfo.new(DUREE_CLIGNOTEMENT, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = couleursMurs[i] })
						tween:Play()
					end)
				end
				if tween then
					tweensMurs[i] = tween
				else
					local base = couleursMurs[i]
					task.delay(DUREE_CLIGNOTEMENT, function()
						if mur.Parent then
							mur.Color = base
						end
					end)
				end
			end
		end
	end

	local niveauActuel = -1
	local function appliquerNiveau(niveau)
		if niveau == niveauActuel then
			return
		end
		niveauActuel = niveau
		for _, p in ipairs(elementsAbimes) do
			if p.Parent then
				if niveau >= 1 then
					p.Transparency = 0
				else
					p.Transparency = 1
				end
			end
		end
		for _, e in ipairs(effetsCritiques) do
			if e.Parent then
				e.Enabled = niveau >= 2
			end
		end
	end

	local function lireNombre(nom, defaut)
		local v = Etat:GetAttribute(nom)
		if type(v) == "number" then
			return v
		end
		return defaut
	end

	local function niveauSelonPV()
		if Etat:GetAttribute("Phase") == "Lobby" then
			return 0
		end
		local max = lireNombre("PVMaisonMax", 0)
		if max <= 0 then
			return 0
		end
		local ratio = lireNombre("PVMaison", max) / max
		if ratio < SEUIL_CRITIQUE then
			return 2
		elseif ratio < SEUIL_ABIME then
			return 1
		end
		return 0
	end

	local pvPrecedent = lireNombre("PVMaison", 0)

	local function surPV()
		local pv = lireNombre("PVMaison", 0)
		if pv < pvPrecedent and Etat:GetAttribute("Phase") ~= "Lobby" then
			clignoter()
		end
		pvPrecedent = pv
		appliquerNiveau(niveauSelonPV())
	end

	local function retourNormal()
		remettreMurs()
		pvPrecedent = lireNombre("PVMaison", 0)
		appliquerNiveau(niveauSelonPV())
	end

	Etat:GetAttributeChangedSignal("PVMaison"):Connect(surPV)
	Etat:GetAttributeChangedSignal("PVMaisonMax"):Connect(function()
		appliquerNiveau(niveauSelonPV())
	end)
	Etat:GetAttributeChangedSignal("Phase"):Connect(function()
		if Etat:GetAttribute("Phase") == "Lobby" then
			retourNormal()
		else
			appliquerNiveau(niveauSelonPV())
		end
	end)
	if ctx.Bus and type(ctx.Bus.ecouter) == "function" then
		ctx.Bus.ecouter("RetourLobby", retourNormal)
	end

	appliquerNiveau(niveauSelonPV())
end

return M
