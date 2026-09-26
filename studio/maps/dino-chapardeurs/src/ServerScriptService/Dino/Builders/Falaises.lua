-- Constructeur Falaises : falaises en terrasses (pierre, terre, dessus herbe) sur les bords du monde,
-- et un sentier d'escalade vers la plateforme du coffre caché (le coffre est posé par Systemes/Recompenses).
-- Emprise (CONTRAT §10) : bandes |x| 168..190, z -190..-168 et z 150..165, plus le sentier et la plateforme.
local M = {}

local BUDGET = 450 -- parts au maximum pour ce constructeur

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier

	-- réglages facultatifs (Equilibrage.falaises), sinon valeurs par défaut
	local reglages = {}
	if ctx.Equilibrage and type(ctx.Equilibrage.falaises) == "table" then
		reglages = ctx.Equilibrage.falaises
	end
	local function reglage(cle, defaut)
		local v = reglages[cle]
		if type(v) == "number" then
			return v
		end
		return defaut
	end
	local HAUTEUR_MIN = math.max(15, reglage("hauteurMin", 16))
	local HAUTEUR_MAX = math.min(35, reglage("hauteurMax", 34))
	if HAUTEUR_MAX < HAUTEUR_MIN then
		HAUTEUR_MAX = HAUTEUR_MIN
	end
	local LONGUEUR_SEGMENT = math.max(12, reglage("longueurSegment", 28))
	local MONTEE = math.min(4, math.max(1, reglage("montee", 3)))  -- hauteur max entre deux marches
	local ECART = math.min(6, math.max(1, reglage("ecart", 2)))    -- vide horizontal entre deux marches
	local EPAISSEUR_HERBE = 0.8

	local rng = Outils.aleatoire(reglage("graine", 1968))

	-- couleurs
	local PIERRE = Charte.pierre
	local PIERRE_OMBRE = Charte.ombre(Charte.pierre)
	local PIERRE_CLAIRE = Charte.lumiere(Charte.pierre)
	local TERRE = Charte.terre
	local HERBE = Charte.herbe
	local FEUILLAGE = Charte.jungle

	-- compteur de parts : on s'arrête net au budget
	local compteur = 0
	local function part(fabrique, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		compteur = compteur + 1
		return fabrique(parent, props)
	end

	-- décor léger, sans collision (lianes, feuillages)
	local function decor(p)
		if p then
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
		end
		return p
	end

	local coffre = Plan.coffre or Vector3.new(160, 22, -158)

	-- ===== 1. plateforme du coffre (dessus exactement à Plan.coffre.Y) =====
	local function construirePlateforme()
		local m = Outils.modele(dossier, "PlateformeCoffre")
		local cx, cz, haut = coffre.X, coffre.Z, coffre.Y

		local dalle = part(Outils.bloc, m, {
			Name = "Dalle",
			Size = Vector3.new(8, 1, 8),
			CFrame = CFrame.new(cx, haut - 0.5, cz),
			Color = Charte.bois,
		})
		if dalle then
			m.PrimaryPart = dalle
		end

		local hPilier = haut - 1
		if hPilier > 0.5 then
			part(Outils.bloc, m, {
				Name = "Pilier",
				Size = Vector3.new(5, hPilier, 5),
				CFrame = CFrame.new(cx, hPilier / 2, cz),
				Color = PIERRE,
			})
			local hSocle = math.min(3, hPilier)
			part(Outils.bloc, m, {
				Name = "Socle",
				Size = Vector3.new(7, hSocle, 7),
				CFrame = CFrame.new(cx, hSocle / 2, cz),
				Color = PIERRE_OMBRE,
			})
			if hPilier > 4 then
				part(Outils.bloc, m, {
					Name = "Collier",
					Size = Vector3.new(6, 1, 6),
					CFrame = CFrame.new(cx, haut - 1.5, cz),
					Color = TERRE,
				})
			end
		end

		-- poteaux aux coins, surmontés d'une gemme qui attire l'œil de loin
		local coins = { { -3.6, -3.6 }, { 3.6, -3.6 }, { -3.6, 3.6 }, { 3.6, 3.6 } }
		for i, c in ipairs(coins) do
			part(Outils.bloc, m, {
				Name = "Poteau" .. i,
				Size = Vector3.new(0.8, 2.5, 0.8),
				CFrame = CFrame.new(cx + c[1], haut + 1.25, cz + c[2]),
				Color = Charte.ombre(Charte.bois),
			})
			local gemme = decor(part(Outils.boule, m, {
				Name = "Gemme" .. i,
				Size = Vector3.new(0.9, 0.9, 0.9),
				CFrame = CFrame.new(cx + c[1], haut + 2.95, cz + c[2]),
				Color = Charte.gemme,
				Material = Enum.Material.Neon,
			}))
			if gemme then
				Outils.animer(gemme, "pulse", 0.6 + i * 0.1)
			end
		end

		-- lianes qui pendent sous la dalle
		local bords = { { -4.2, -1.5 }, { 4.2, 2 }, { 1, -4.2 }, { -2, 4.2 } }
		for i, b in ipairs(bords) do
			local longueur = rng:NextNumber(6, 10)
			if longueur > haut - 2 then
				longueur = math.max(1, haut - 2)
			end
			decor(part(Outils.bloc, m, {
				Name = "Liane" .. i,
				Size = Vector3.new(0.35, longueur, 0.35),
				CFrame = CFrame.new(cx + b[1], haut - longueur / 2, cz + b[2]),
				Color = FEUILLAGE,
			}))
			decor(part(Outils.boule, m, {
				Name = "Feuilles" .. i,
				Size = Vector3.new(1.2, 1.2, 1.2),
				CFrame = CFrame.new(cx + b[1], haut - longueur, cz + b[2]),
				Color = HERBE,
			}))
		end
	end

	-- ===== 2. sentier d'escalade : rochers en colonnes, montées <= MONTEE, écarts <= ECART =====
	local premiereMarche = nil
	local function construireSentier()
		local m = Outils.modele(dossier, "Sentier")
		local cx, cz, haut = coffre.X, coffre.Z, coffre.Y
		-- le sentier part vers le centre du monde (en z)
		local sens = 1
		if cz > 0 then
			sens = -1
		end
		local nbMarches = math.ceil(haut / MONTEE) - 1
		if nbMarches < 1 then
			premiereMarche = Vector3.new(cx, 0, cz + sens * 8)
			return
		end
		local montee = haut / (nbMarches + 1)
		local cote = 4
		local pas = cote + ECART
		for k = 1, nbMarches do
			local rang = nbMarches - k -- 0 pour la marche la plus haute (au bord de la plateforme)
			local z = cz + sens * (4 + ECART + cote / 2 + rang * pas)
			-- zigzag léger pour un air naturel ; la dernière marche est face au milieu du bord
			local x = cx + 1
			if rang % 2 == 1 then
				x = cx + 4.5
			end
			local dessus = k * montee
			local angle = math.rad(rng:NextNumber(-10, 10))
			local couleur = PIERRE
			if k % 2 == 0 then
				couleur = PIERRE_CLAIRE
			end
			local hColonne = dessus - EPAISSEUR_HERBE
			if hColonne > 0.2 then
				part(Outils.bloc, m, {
					Name = "Marche" .. k,
					Size = Vector3.new(cote, hColonne, cote),
					CFrame = CFrame.new(x, hColonne / 2, z) * CFrame.Angles(0, angle, 0),
					Color = couleur,
				})
				part(Outils.bloc, m, {
					Name = "Herbe" .. k,
					Size = Vector3.new(cote, EPAISSEUR_HERBE, cote),
					CFrame = CFrame.new(x, dessus - EPAISSEUR_HERBE / 2, z) * CFrame.Angles(0, angle, 0),
					Color = HERBE,
				})
			else
				part(Outils.bloc, m, {
					Name = "Marche" .. k,
					Size = Vector3.new(cote, dessus, cote),
					CFrame = CFrame.new(x, dessus / 2, z) * CFrame.Angles(0, angle, 0),
					Color = couleur,
				})
			end
			if k == 1 then
				premiereMarche = Vector3.new(x, 0, z)
			end
		end
	end

	-- panneau « ??? » au pied du sentier
	local function construirePanneau()
		if not premiereMarche or compteur + 2 > BUDGET then
			return
		end
		local sens = 1
		if coffre.Z > 0 then
			sens = -1
		end
		Outils.panneau(dossier, {
			nom = "PanneauMystere",
			position = Vector3.new(premiereMarche.X - 4.5, 0, premiereMarche.Z + sens * 4),
			texte = "???",
			angle = 90,
			largeur = 4,
			couleur = Charte.bois,
			couleurTexte = Charte.dore,
		})
		compteur = compteur + 2 -- poteau et planche
	end

	-- ===== 3. les falaises en terrasses =====
	-- une bande : axe = direction de sa longueur ("x" ou "z"), avant = coordonnée de la face tournée vers le monde,
	-- sens = direction de la profondeur (vers l'extérieur), profondeur = épaisseur de la bande, a0..a1 = étendue.
	local function boite(bande, a0, a1, d0, d1, y0, y1)
		local p0 = bande.avant + bande.sens * d0
		local p1 = bande.avant + bande.sens * d1
		local pMil = (p0 + p1) / 2
		local pTaille = math.abs(p1 - p0)
		local aMil = (a0 + a1) / 2
		local aTaille = a1 - a0
		if bande.axe == "z" then
			return CFrame.new(pMil, (y0 + y1) / 2, aMil), Vector3.new(pTaille, y1 - y0, aTaille)
		end
		return CFrame.new(aMil, (y0 + y1) / 2, pMil), Vector3.new(aTaille, y1 - y0, pTaille)
	end

	local function point(bande, a, d, y)
		local p = bande.avant + bande.sens * d
		if bande.axe == "z" then
			return Vector3.new(p, y, a)
		end
		return Vector3.new(a, y, p)
	end

	local decorsDiffere = {} -- décor ajouté après toutes les falaises (priorité à la structure)

	local function couche(m, nom, bande, a0, a1, d0, d1, y0, y1, couleur)
		if y1 - y0 < 0.05 then
			return nil
		end
		local cf, taille = boite(bande, a0, a1, d0, d1, y0, y1)
		return part(Outils.bloc, m, { Name = nom, Size = taille, CFrame = cf, Color = couleur })
	end

	local function construireSegment(m, bande, a0, a1, numero)
		local h = rng:NextInteger(HAUTEUR_MIN, HAUTEUR_MAX)
		local h1 = math.max(6, math.floor(h * 0.4 + 0.5))
		local h2 = math.max(h1 + 4, math.floor(h * 0.7 + 0.5))
		if h2 > h - 3 then
			h2 = h - 3
		end
		local D = bande.profondeur
		local d2 = D * 0.3
		local d3 = D * 0.62
		local E = EPAISSEUR_HERBE
		local pierre = PIERRE:Lerp(PIERRE_OMBRE, rng:NextNumber(0, 0.7))
		local pierreHaut = PIERRE:Lerp(PIERRE_CLAIRE, rng:NextNumber(0, 0.8))
		local herbe = HERBE:Lerp(FEUILLAGE, rng:NextNumber(0, 0.25))
		local s = Outils.modele(m, "Segment" .. numero)

		-- terrasse basse : pierre, dessus herbe
		couche(s, "Pierre", bande, a0, a1, 0, D, 0, h1 - E, pierre)
		couche(s, "Herbe1", bande, a0, a1, 0, D, h1 - E, h1, herbe)
		-- terrasse du milieu : terre, dessus herbe
		couche(s, "Terre", bande, a0, a1, d2, D, h1, h2 - E, TERRE)
		couche(s, "Herbe2", bande, a0, a1, d2, D, h2 - E, h2, herbe)
		-- sommet : pierre claire, dessus herbe
		couche(s, "Sommet", bande, a0, a1, d3, D, h2, h - E, pierreHaut)
		couche(s, "Herbe3", bande, a0, a1, d3, D, h - E, h, herbe)

		local longueur = a1 - a0
		-- rocher posé sur la terrasse basse
		if rng:NextNumber() < 0.45 and longueur > 8 then
			local taille = rng:NextNumber(2, 3.5)
			local a = rng:NextNumber(a0 + 4, a1 - 4)
			local d = rng:NextNumber(taille / 2 + 0.6, math.max(taille / 2 + 0.6, d2 - taille / 2 - 0.3))
			local pos = point(bande, a, d, h1 + taille / 2 - 0.3)
			local rot = CFrame.Angles(0, rng:NextNumber(0, math.pi), rng:NextNumber(-0.2, 0.2))
			table.insert(decorsDiffere, function()
				part(Outils.bloc, s, {
					Name = "Rocher",
					Size = Vector3.new(taille, taille * 0.8, taille * 1.1),
					CFrame = CFrame.new(pos) * rot,
					Color = PIERRE_CLAIRE,
				})
			end)
		end
		-- buisson au sommet
		if rng:NextNumber() < 0.25 and longueur > 8 then
			local taille = rng:NextNumber(3, 5)
			local a = rng:NextNumber(a0 + 3, a1 - 3)
			local d = (d3 + D) / 2
			local pos = point(bande, a, d, h + taille * 0.3)
			table.insert(decorsDiffere, function()
				decor(part(Outils.boule, s, {
					Name = "Buisson",
					Size = Vector3.new(taille, taille, taille),
					CFrame = CFrame.new(pos),
					Color = FEUILLAGE,
				}))
			end)
		end
		-- lianes le long de la terre, qui tombent sur la terrasse basse
		if numero % 3 == 1 and longueur > 8 then
			for j = 1, 2 do
				local a = rng:NextNumber(a0 + 2, a1 - 2)
				local chute = (h2 - h1) * rng:NextNumber(0.55, 0.9)
				local haut = h2
				local posLiane = point(bande, a, d2 - 0.25, haut - chute / 2)
				local posFeuilles = point(bande, a, d2 - 0.5, haut - chute)
				table.insert(decorsDiffere, function()
					decor(part(Outils.bloc, s, {
						Name = "Liane",
						Size = Vector3.new(0.35, chute, 0.35),
						CFrame = CFrame.new(posLiane),
						Color = FEUILLAGE,
					}))
					decor(part(Outils.boule, s, {
						Name = "Feuilles",
						Size = Vector3.new(1, 1, 1),
						CFrame = CFrame.new(posFeuilles),
						Color = HERBE,
					}))
				end)
			end
		end
	end

	-- le Volcan s'adosse au nord : on laisse un passage (rayon + 6)
	local volcan = Plan.volcan
	local function toucheVolcan(bande, a0, a1)
		if not volcan or not volcan.centre or type(volcan.rayon) ~= "number" then
			return false
		end
		local c = volcan.centre
		local p0 = bande.avant
		local p1 = bande.avant + bande.sens * bande.profondeur
		local pMin, pMax = math.min(p0, p1), math.max(p0, p1)
		local px, pz
		if bande.axe == "x" then
			px = math.clamp(c.X, a0, a1)
			pz = math.clamp(c.Z, pMin, pMax)
		else
			px = math.clamp(c.X, pMin, pMax)
			pz = math.clamp(c.Z, a0, a1)
		end
		local dx, dz = px - c.X, pz - c.Z
		return math.sqrt(dx * dx + dz * dz) < volcan.rayon + 6
	end

	local BANDES = {
		{ nom = "FalaiseEst", axe = "z", avant = 168, sens = 1, profondeur = 22, a0 = -190, a1 = 165 },
		{ nom = "FalaiseOuest", axe = "z", avant = -168, sens = -1, profondeur = 22, a0 = -190, a1 = 165 },
		{ nom = "FalaiseNord", axe = "x", avant = -168, sens = -1, profondeur = 22, a0 = -168, a1 = 168 },
		{ nom = "FalaiseSud", axe = "x", avant = 150, sens = 1, profondeur = 15, a0 = -168, a1 = 168 },
	}

	local function construireBande(bande)
		local m = Outils.modele(dossier, bande.nom)
		local longueur = bande.a1 - bande.a0
		local n = math.max(1, math.floor(longueur / LONGUEUR_SEGMENT + 0.5))
		local pas = longueur / n
		for i = 1, n do
			local a0 = bande.a0 + (i - 1) * pas
			local a1 = a0 + pas
			if not toucheVolcan(bande, a0, a1) then
				construireSegment(m, bande, a0, a1, i)
			end
		end
	end

	-- ===== ordre : l'essentiel d'abord (plateforme, sentier), puis falaises, puis décor =====
	local etapes = {
		{ "plateforme", construirePlateforme },
		{ "sentier", construireSentier },
		{ "panneau", construirePanneau },
	}
	for _, bande in ipairs(BANDES) do
		table.insert(etapes, { bande.nom, function()
			construireBande(bande)
		end })
	end
	table.insert(etapes, { "decor", function()
		for _, f in ipairs(decorsDiffere) do
			if compteur >= BUDGET then
				break
			end
			local ok, err = pcall(f)
			if not ok then
				warn("[Dino] Falaises (décor) : " .. tostring(err))
			end
		end
	end })

	for _, etape in ipairs(etapes) do
		local ok, err = pcall(etape[2])
		if not ok then
			warn("[Dino] Falaises (" .. etape[1] .. ") : " .. tostring(err))
		end
	end

	dossier:SetAttribute("Parts", compteur)
end

return M
