-- Constructeur Falaises : falaises de terrain Roblox (Rock, Slate, dessus Grass) sculptées en terrasses irrégulières
-- sur les bords du monde, et un sentier d'escalade en parts (rochers d'ardoise arrondis, marches en planches)
-- jusqu'à la plateforme du coffre caché (le coffre est posé par Systemes/Recompenses).
-- Plan v2 (CONTRAT §10) : les 4 bandes Plan.falaises (est, ouest, nord, sud), plus le sentier et la plateforme dont le
-- dessus est exactement à Plan.coffre. La falaise la plus proche du coffre se creuse en une anse (sol d'herbe, paroi
-- haute au fond) où grimpe le sentier, à l'abri des rondeurs de roche. Au-delà des murs invisibles, un arrière-pays de
-- collines (terrain seulement, aucune part) ferme l'horizon. Aucune coordonnée en dur : tout vient de Plan.
local M = {}

local BUDGET = 350 -- parts au maximum pour ce constructeur (le terrain ne compte pas)

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	local hex = Charte.hex
	local Mat = Enum.Material

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
	local HAUTEUR_MIN = math.max(15, reglage("hauteurMin", 20))
	local HAUTEUR_MAX = math.min(35, reglage("hauteurMax", 34))
	if HAUTEUR_MAX < HAUTEUR_MIN then
		HAUTEUR_MAX = HAUTEUR_MIN
	end
	local LONGUEUR_SEGMENT = math.max(16, reglage("longueurSegment", 34))
	local MONTEE = math.min(4, math.max(1, reglage("montee", 3))) -- hauteur max entre deux marches
	local ECART = math.min(6, math.max(1, reglage("ecart", 2)))   -- vide horizontal entre deux marches
	local HERBE_T = 2 -- épaisseur du dessus d'herbe (terrain)
	local PLAFOND = 36 -- rien ne dépasse cette hauteur (sauf l'arrière-pays lointain, ≤ 50, hors des murs)

	local rng = Outils.aleatoire(reglage("graine", 1968))

	-- ===== palette : roche chaude, bois miel, feuillages en trois teintes =====
	local ROCHE_T = hex("C49B74")       -- Rock du terrain : grès chaud
	local ARDOISE_T = hex("9F7C62")     -- Slate du terrain : strates plus sombres
	local PIERRE = hex("A99682")        -- rochers du sentier (parts Slate)
	local PIERRE_CLAIRE = Charte.lumiere(PIERRE)
	local PLANCHE = hex("C98E55")       -- WoodPlanks
	local POUTRE = hex("7E5431")        -- Wood sombre (poteaux, poutres)
	local LIANE = hex("3B8C3A")
	local FEUILLE = hex("4DAE45")
	local FEUILLE_CLAIRE = hex("72C653")
	local MOUSSE = hex("86C24B")
	local FLAMME = hex("FFA53A")

	Outils.couleurTerrain(Mat.Rock, ROCHE_T)
	Outils.couleurTerrain(Mat.Slate, ARDOISE_T)

	-- ===== compteur de parts : on s'arrête net au budget =====
	local compteur = 0
	local function part(fabrique, parent, props)
		if compteur >= BUDGET then
			return nil
		end
		compteur = compteur + 1
		return fabrique(parent, props)
	end
	local function reserver(n)
		if compteur + n > BUDGET then
			return false
		end
		compteur = compteur + n
		return true
	end
	local function arrondi(parent, props, rayon)
		if not reserver(6) then
			return nil
		end
		return Outils.blocArrondi(parent, props, rayon)
	end
	local function bordee(parent, props, bord, couleurBord)
		if not reserver(2) then
			return nil
		end
		return Outils.dalleBordee(parent, props, bord, couleurBord)
	end

	-- décor léger, sans collision (lianes, feuillages, mousse)
	local function decor(p)
		if p then
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
		end
		return p
	end

	-- petites particules d'ambiance (peu nombreuses : effets légers), jamais bloquantes
	local function particules(p, props)
		if not p then
			return
		end
		pcall(function()
			local e = Instance.new("ParticleEmitter")
			e.Name = props.nom or "Particules"
			e.Rate = props.rate or 2
			e.Lifetime = NumberRange.new(props.vie[1], props.vie[2])
			e.Speed = NumberRange.new(props.vitesse[1], props.vitesse[2])
			e.SpreadAngle = props.angle or Vector2.new(20, 20)
			e.Color = ColorSequence.new(props.couleur, props.couleur2 or props.couleur)
			e.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, props.taille),
				NumberSequenceKeypoint.new(1, props.taille * 0.2),
			})
			e.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(1, 1),
			})
			e.LightEmission = props.lueur or 0.8
			e.Acceleration = props.acceleration or Vector3.new(0, 0, 0)
			e.Parent = p
		end)
	end

	local function signe(v)
		if v < 0 then
			return -1
		end
		return 1
	end

	local coffre = Plan.coffre
	local SX = 1   -- côté de la falaise la plus proche (est si x > 0)
	local SENS = 1 -- le sentier descend vers le centre du monde (en z)
	if coffre then
		SX = signe(coffre.X)
		if coffre.Z > 0 then
			SENS = -1
		end
	end
	local DEMI = 6    -- demi-côté de la plateforme
	local COTE = 4.5  -- côté d'une marche du sentier

	-- tracé du sentier (calculé d'avance : la falaise se creuse autour de lui)
	local marches = {}
	if coffre then
		local nb = math.ceil(coffre.Y / MONTEE) - 1
		if nb >= 1 then
			local montee = coffre.Y / (nb + 1)
			local pas = COTE + ECART
			for k = 1, nb do
				local rang = nb - k -- 0 pour la marche la plus haute (au bord de la plateforme)
				local z = coffre.Z + SENS * (DEMI + ECART + COTE / 2 + rang * pas)
				-- zigzag léger vers la falaise pour un air naturel
				local x = coffre.X + SX * 0.5
				if rang % 2 == 1 then
					x = coffre.X + SX * 3
				end
				marches[k] = { x = x, z = z, dessus = k * montee }
			end
		end
	end

	-- l'anse du sentier (monde) : de la face de la falaise jusqu'à xFond (côté extérieur), de zMin à zMax
	local CREUX = nil
	if coffre then
		local fond = coffre.X * SX + DEMI + 2.5
		local zA = coffre.Z - SENS * (DEMI + 2.5)
		local zB = coffre.Z + SENS * (DEMI + 2.5)
		for _, mk in ipairs(marches) do
			fond = math.max(fond, mk.x * SX + COTE / 2 + 2.5)
		end
		if marches[1] then
			zB = marches[1].z + SENS * (COTE / 2 + 7) -- place pour le panneau et les torches du pied
		end
		CREUX = { fond = fond, zMin = math.min(zA, zB), zMax = math.max(zA, zB) }
	end
	local RAMPE = 12 -- la paroi de l'anse rejoint la falaise normale sur 12 studs

	-- ===== 1. plateforme du coffre (dessus exactement à Plan.coffre.Y) =====
	local function construirePlateforme()
		if not coffre then
			return
		end
		local m = Outils.modele(dossier, "PlateformeCoffre")
		local cx, cz, haut = coffre.X, coffre.Z, coffre.Y

		-- éperon rocheux en terrain sous la plateforme, adossé à la falaise (son dessus reste sous les poutres)
		local hRoche = haut - 3.5
		if hRoche > 4 then
			local x0, x1 = cx - SX * 5, cx + SX * 9
			Outils.terrainBloc(CFrame.new((x0 + x1) / 2, (hRoche - 2) / 2, cz), Vector3.new(math.abs(x1 - x0), hRoche + 2, 10), Mat.Rock)
			local r1 = math.min(5, hRoche / 2)
			Outils.terrainBoule(Vector3.new(cx - SX * 3, r1 * 0.8, cz + SENS * 1.5), r1, Mat.Slate)
			local r2 = math.min(4, hRoche / 3)
			Outils.terrainBoule(Vector3.new(cx - SX * 2, hRoche - r2 - 0.3, cz - SENS * 2), r2, Mat.Rock)
			Outils.terrainBoule(Vector3.new(cx + SX * 3, hRoche - 3.2, cz + SENS * 2.5), 3, Mat.Slate)
			Outils.terrainBoule(Vector3.new(cx - SX * 4, 1, cz - SENS * 4), 3.5, Mat.Rock)
		end

		-- plancher en planches sur un liseré de bois sombre
		local dalle = bordee(m, {
			Name = "Dalle",
			Size = Vector3.new(2 * DEMI, 1, 2 * DEMI),
			CFrame = CFrame.new(cx, haut - 0.5, cz),
			Color = PLANCHE,
			Material = Mat.WoodPlanks,
			MaterialBord = Mat.Wood,
		}, 0.4, POUTRE)
		if dalle then
			m.PrimaryPart = dalle
			-- quelques paillettes dorées qui montent de la plateforme : on la repère d'en bas
			particules(dalle, {
				nom = "Paillettes", rate = 3, vie = { 1.5, 2.5 }, vitesse = { 1.5, 3 },
				angle = Vector2.new(40, 40), couleur = Charte.dore, couleur2 = Charte.gemme, taille = 0.35,
				acceleration = Vector3.new(0, 0.6, 0),
			})
			-- étiquette géante flottante, lisible de loin (et sur mobile)
			if Style and Style.etiquette then
				Style.etiquette(dalle, {
					{ texte = "???", couleur = Charte.dore, taille = 1.6, titre = true, nom = "Titre" },
					{ texte = "Grimpe si tu l'oses !", taille = 0.9, nom = "Invite" },
				}, {
					Name = "EtiquetteMystere",
					largeur = 12,
					hauteurLigne = 1.6,
					StudsOffset = Vector3.new(0, 6, 0),
					MaxDistance = 160,
				})
			end
		end

		-- poutres posées sur la roche, sous le plancher
		if hRoche > 4 then
			local y0, y1 = hRoche - 0.4, haut - 1.1
			for _, dz in ipairs({ -4.6, 0, 4.6 }) do
				part(Outils.bloc, m, {
					Name = "Poutre",
					Size = Vector3.new(2 * DEMI + 0.6, y1 - y0, 1.2),
					CFrame = CFrame.new(cx, (y0 + y1) / 2, cz + dz),
					Color = POUTRE,
					Material = Mat.Wood,
				})
			end
		end

		-- garde-corps sur trois côtés (le côté du sentier reste ouvert), poteaux coiffés d'une gemme
		local P = DEMI - 0.5
		local coins = { { -P, -P }, { P, -P }, { -P, P }, { P, P } }
		for i, c in ipairs(coins) do
			part(Outils.bloc, m, {
				Name = "Poteau" .. i,
				Size = Vector3.new(0.8, 2.8, 0.8),
				CFrame = CFrame.new(cx + c[1], haut + 1.4, cz + c[2]),
				Color = POUTRE,
				Material = Mat.Wood,
			})
			local gemme = decor(part(Outils.boule, m, {
				Name = "Gemme" .. i,
				Size = Vector3.new(0.9, 0.9, 0.9),
				CFrame = CFrame.new(cx + c[1], haut + 3.25, cz + c[2]),
				Color = Charte.gemme,
				Material = Mat.Neon,
			}))
			if gemme then
				Outils.animer(gemme, "pulse", 0.6 + i * 0.1)
				if c[2] * SENS > 0 then
					Outils.lumiere(gemme, { Range = 12, Brightness = 1.2, Color = Charte.gemme })
				end
			end
		end
		local rails = {
			{ Vector3.new(0, 0, -SENS * P), Vector3.new(2 * P, 0.35, 0.35) },
			{ Vector3.new(-P, 0, 0), Vector3.new(0.35, 0.35, 2 * P) },
			{ Vector3.new(P, 0, 0), Vector3.new(0.35, 0.35, 2 * P) },
		}
		for _, r in ipairs(rails) do
			for _, y in ipairs({ 2.3, 1.1 }) do
				part(Outils.bloc, m, {
					Name = "Rambarde",
					Size = r[2],
					CFrame = CFrame.new(cx + r[1].X, haut + y, cz + r[1].Z),
					Color = PLANCHE,
					Material = Mat.Wood,
				})
			end
		end

		-- lianes qui pendent sous le plancher (côté monde et côté sentier)
		local bords = {
			{ -DEMI - 0.3, -3 }, { -DEMI - 0.3, 1.5 },
			{ -3.5, SENS * (DEMI + 0.3) }, { 3.8, SENS * (DEMI + 0.3) },
		}
		for i, b in ipairs(bords) do
			local x = cx + SX * b[1]
			if i > 2 then
				x = cx + b[1]
			end
			local longueur = math.min(rng:NextNumber(5, 9), math.max(1, haut - 3))
			decor(part(Outils.bloc, m, {
				Name = "Liane" .. i,
				Size = Vector3.new(0.3, longueur, 0.3),
				CFrame = CFrame.new(x, haut - 1 - longueur / 2, cz + b[2]),
				Color = LIANE,
				Material = Mat.LeafyGrass,
			}))
			decor(part(Outils.boule, m, {
				Name = "Feuilles" .. i,
				Size = Vector3.new(1.3, 1.1, 1.3),
				CFrame = CFrame.new(x, haut - 1 - longueur, cz + b[2]),
				Color = FEUILLE,
				Material = Mat.LeafyGrass,
			}))
		end
	end

	-- ===== 2. sentier d'escalade : rochers d'ardoise et marches en planches, montées <= MONTEE, écarts <= ECART =====
	local premiereMarche = nil
	local function construireSentier()
		if not coffre then
			return
		end
		local m = Outils.modele(dossier, "Sentier")
		if #marches < 1 then
			premiereMarche = Vector3.new(coffre.X, 0, coffre.Z + SENS * (DEMI + 4))
			return
		end
		local cote = COTE
		for k, mk in ipairs(marches) do
			local x, z, dessus = mk.x, mk.z, mk.dessus
			local rot = CFrame.Angles(0, math.rad(rng:NextNumber(-6, 6)), 0)
			if k % 2 == 1 then
				-- rocher d'ardoise aux arêtes arrondies, mousse qui déborde côté falaise
				local teinte = PIERRE:Lerp(PIERRE_CLAIRE, rng:NextNumber(0, 0.6))
				arrondi(m, {
					Name = "Marche" .. k,
					Size = Vector3.new(cote, dessus, cote),
					CFrame = CFrame.new(x, dessus / 2, z) * rot,
					Color = teinte,
					Material = Mat.Slate,
				}, 1.1)
				decor(part(Outils.boule, m, {
					Name = "Mousse",
					Size = Vector3.new(1.4, 1.2, 3.4),
					CFrame = CFrame.new(x + SX * (cote / 2), dessus - 0.3, z) * rot,
					Color = MOUSSE,
					Material = Mat.Grass,
				}))
				if dessus > 5 then
					local chute = math.min(dessus - 1.5, rng:NextNumber(4, 7))
					decor(part(Outils.bloc, m, {
						Name = "Liane",
						Size = Vector3.new(0.3, chute, 0.3),
						CFrame = CFrame.new(x - SX * (cote / 2 + 0.1), dessus - chute / 2, z + rng:NextNumber(-1.2, 1.2)),
						Color = LIANE,
						Material = Mat.LeafyGrass,
					}))
				end
				Outils.terrainBoule(Vector3.new(x + SX * 3.4, 0.2, z + rng:NextNumber(-1, 1)), rng:NextNumber(1.8, 2.4), Mat.Slate)
			else
				-- marche en planches sur quatre poteaux, traverses quand c'est haut
				local plancher = part(Outils.bloc, m, {
					Name = "Marche" .. k,
					Size = Vector3.new(cote + 0.4, 0.8, cote),
					CFrame = CFrame.new(x, dessus - 0.4, z) * rot,
					Color = PLANCHE,
					Material = Mat.WoodPlanks,
				})
				local hPoteau = dessus - 0.8
				if plancher and hPoteau > 0.3 then
					local e = cote / 2 - 0.5
					for _, c in ipairs({ { -e, -e }, { e, -e }, { -e, e }, { e, e } }) do
						part(Outils.bloc, m, {
							Name = "Poteau",
							Size = Vector3.new(0.7, hPoteau, 0.7),
							CFrame = CFrame.new(x, 0, z) * rot * CFrame.new(c[1], hPoteau / 2, c[2]),
							Color = POUTRE,
							Material = Mat.Wood,
						})
					end
					if hPoteau > 6 then
						for _, sx in ipairs({ -e, e }) do
							part(Outils.bloc, m, {
								Name = "Traverse",
								Size = Vector3.new(0.5, 0.6, cote - 0.4),
								CFrame = CFrame.new(x, 0, z) * rot * CFrame.new(sx, hPoteau * 0.5, 0),
								Color = POUTRE,
								Material = Mat.Wood,
							})
						end
					end
				end
				Outils.terrainBoule(Vector3.new(x, -0.4, z), math.min(2.2, math.max(1, dessus - 2.4)), Mat.Slate)
			end
			if k == 1 then
				premiereMarche = Vector3.new(x, 0, z)
			end
		end
	end

	-- panneau « ??? » et deux torches au pied du sentier
	local function construirePanneau()
		if not premiereMarche or compteur + 2 > BUDGET then
			return
		end
		local x0, z0 = premiereMarche.X, premiereMarche.Z
		local panneau = Outils.panneau(dossier, {
			nom = "PanneauMystere",
			position = Vector3.new(x0 - SX * 6, 0, z0 + SENS * 5),
			texte = "???",
			angle = 90,
			largeur = 4,
			couleur = PLANCHE,
			couleurTexte = Charte.dore,
		})
		compteur = compteur + 2 -- poteau et planche
		local planche = panneau and panneau:FindFirstChild("Planche")
		local poteau = panneau and panneau:FindFirstChild("Poteau")
		if poteau then
			poteau.Material = Mat.Wood
			poteau.Color = POUTRE
		end
		if planche then
			planche.Material = Mat.WoodPlanks
			if Style and Style.etiquette then
				Style.etiquette(planche, {
					{ texte = "SENTIER", titre = true, nom = "Titre" },
				}, {
					Name = "EtiquetteSentier",
					largeur = 8,
					hauteurLigne = 1.8,
					StudsOffset = Vector3.new(0, 2.5, 0),
					MaxDistance = 90,
				})
			end
		end
		-- torches de part et d'autre de l'entrée du sentier
		local t = Outils.modele(dossier, "Torches")
		for i, dx in ipairs({ -3.4, 3.4 }) do
			local x, z = x0 + dx, z0 + SENS * 3.6
			part(Outils.bloc, t, {
				Name = "Manche" .. i,
				Size = Vector3.new(0.5, 4, 0.5),
				CFrame = CFrame.new(x, 2, z),
				Color = POUTRE,
				Material = Mat.Wood,
			})
			local flamme = decor(part(Outils.boule, t, {
				Name = "Flamme" .. i,
				Size = Vector3.new(0.9, 1.1, 0.9),
				CFrame = CFrame.new(x, 4.45, z),
				Color = FLAMME,
				Material = Mat.Neon,
			}))
			if flamme then
				Outils.animer(flamme, "pulse", 1.4 + i * 0.2)
				Outils.lumiere(flamme, { Range = 14, Brightness = 1.4, Color = FLAMME })
				-- quelques braises qui s'envolent
				particules(flamme, {
					nom = "Braises", rate = 4, vie = { 0.6, 1.2 }, vitesse = { 1.5, 3 },
					angle = Vector2.new(15, 15), couleur = FLAMME, couleur2 = Charte.dore, taille = 0.25,
					acceleration = Vector3.new(0, 2, 0),
				})
			end
		end
	end

	-- ===== 3. les falaises en terrain =====
	-- une bande : axe = direction de sa longueur ("x" ou "z"), avant = coordonnée de la face tournée vers le monde,
	-- sens = direction de la profondeur (vers l'extérieur), profondeur = épaisseur, a0..a1 = étendue,
	-- arriere = profondeur où la crête commence à redescendre (vers l'extérieur, sans face verticale).
	local function point(bande, a, d, y)
		local p = bande.avant + bande.sens * d
		if bande.axe == "z" then
			return Vector3.new(p, y, a)
		end
		return Vector3.new(a, y, p)
	end
	-- taille orientée : long (le long de la bande), haut, prof (en profondeur)
	local function tailleBande(bande, long, haut, prof)
		if bande.axe == "z" then
			return Vector3.new(prof, haut, long)
		end
		return Vector3.new(long, haut, prof)
	end
	-- décalage dans le repère de la bande (non tourné) : dd en profondeur, dy en hauteur
	local function decalage(bande, dd, dy)
		local v = point(bande, 0, dd, dy) - point(bande, 0, 0, 0)
		return CFrame.new(v.X, v.Y, v.Z)
	end
	-- vecteur horizontal tourné vers le monde (face avant de la bande)
	local function versMonde(bande)
		return point(bande, 0, -1, 0) - point(bande, 0, 0, 0)
	end
	-- bloc de terrain d'une tranche, tourné de `angle` (radians) autour d'un axe vertical posé en (a, dPivot)
	local function blocT(bande, a, larg, dPivot, d0, d1, y0, y1, angle, materiau)
		if larg < 0.5 or d1 - d0 < 0.5 or y1 - y0 < 0.5 then
			return
		end
		local cf = CFrame.new(point(bande, a, dPivot, 0)) * CFrame.Angles(0, angle, 0)
			* decalage(bande, (d0 + d1) / 2 - dPivot, (y0 + y1) / 2)
		Outils.terrainBloc(cf, tailleBande(bande, larg, y1 - y0, d1 - d0), materiau)
	end
	-- pente de terrain (FillWedge) : bas côté monde (d0), haut en d1 ; `inverse` : haut en d0, bas vers l'extérieur (d1)
	local function penteT(bande, a, larg, dPivot, d0, d1, y0, y1, angle, materiau, inverse)
		if larg < 1 or d1 - d0 < 1 or y1 - y0 < 1 then
			return
		end
		local dir = versMonde(bande)
		if inverse then
			dir = -dir
		end
		local cf = CFrame.new(point(bande, a, dPivot, 0)) * CFrame.Angles(0, angle, 0)
			* decalage(bande, (d0 + d1) / 2 - dPivot, (y0 + y1) / 2) * CFrame.lookAt(Vector3.new(0, 0, 0), dir)
		Outils.terrainCoin(cf, Vector3.new(larg, y1 - y0, d1 - d0), materiau)
	end

	-- bruit lissé (somme de deux sinus) : les avancées et les hauteurs ondulent sans à-coups d'un segment à l'autre
	local DEUX_PI = 2 * math.pi
	local function nouveauBruit(amplitude, periode1, periode2)
		local ph1, ph2 = rng:NextNumber(0, DEUX_PI), rng:NextNumber(0, DEUX_PI)
		return function(a)
			return amplitude * (0.75 * math.sin(a * DEUX_PI / periode1 + ph1) + 0.25 * math.sin(a * DEUX_PI / periode2 + ph2))
		end
	end

	-- le Volcan s'adosse au nord : les tranches reculent pour rester hors de son disque (rayon + 2)
	local volcan = Plan.volcan
	local VOLCAN_OK = volcan ~= nil and volcan.centre ~= nil and type(volcan.rayon) == "number"
	-- profondeur minimale d'une tranche [s0, s1] pour rester hors du disque du volcan
	local function horsVolcan(bande, s0, s1, marge)
		if not VOLCAN_OK then
			return 0
		end
		local c = volcan.centre
		local ca, cp = c.X, c.Z
		if bande.axe == "z" then
			ca, cp = c.Z, c.X
		end
		local da = 0
		if ca < s0 then
			da = s0 - ca
		elseif ca > s1 then
			da = ca - s1
		end
		local R = volcan.rayon + 2 + (marge or 0)
		if da >= R then
			return 0
		end
		local dc = (cp - bande.avant) * bande.sens
		return math.max(0, dc + math.sqrt(R * R - da * da))
	end
	-- profondeur minimale d'une tranche [s0, s1] pour laisser libre l'anse du sentier (falaise du côté du coffre),
	-- avec un raccord progressif (RAMPE) de part et d'autre
	local function creux(bande, s0, s1)
		if not CREUX or bande.axe ~= "z" or bande.sens ~= SX then
			return 0
		end
		local da = 0
		if s1 < CREUX.zMin then
			da = CREUX.zMin - s1
		elseif s0 > CREUX.zMax then
			da = s0 - CREUX.zMax
		end
		if da >= RAMPE then
			return 0
		end
		local plein = CREUX.fond - bande.avant * bande.sens
		local k = 1 - da / RAMPE
		return math.max(0, plein * k * k * (3 - 2 * k))
	end
	-- une boule de rayon r posée en pos reste-t-elle hors du disque du volcan et de l'anse du sentier ?
	local function libre(pos, r)
		if CREUX then
			local xIn = pos.X * SX
			local xMin = CREUX.fond - 40
			local dx = math.max(0, xMin - xIn, xIn - CREUX.fond)
			local dz = math.max(0, CREUX.zMin - pos.Z, pos.Z - CREUX.zMax)
			if math.sqrt(dx * dx + dz * dz) < r + 3 then
				return false
			end
		end
		if not VOLCAN_OK then
			return true
		end
		local dx, dz = pos.X - volcan.centre.X, pos.Z - volcan.centre.Z
		return math.sqrt(dx * dx + dz * dz) >= volcan.rayon + 2 + r
	end

	-- la tranche d'une terrasse qui couvre la position a
	local function morceauEn(morceaux, a)
		for _, mc in ipairs(morceaux) do
			if a >= mc.a0 and a <= mc.a1 then
				return mc
			end
		end
		if a > morceaux[#morceaux].a1 then
			return morceaux[#morceaux]
		end
		return morceaux[1]
	end
	-- position (en profondeur) de la pente avant d'une tranche à la hauteur yy
	local function surface(mc, yy)
		local k = (yy - mc.yBas) / math.max(0.5, mc.y - mc.yBas)
		k = math.max(0, math.min(1, k))
		return mc.pied + (mc.d - mc.pied) * k
	end

	-- tranches de 4 studs communes aux trois gradins d'un segment
	local TRANCHE = 4
	local RECOUVRE = 1.2 -- chevauchement des tranches tournées (pas de fente entre deux tranches)
	local function tranches(bande, a0, a1)
		local n = math.max(1, math.floor((a1 - a0) / TRANCHE + 0.5))
		local l = (a1 - a0) / n
		local liste = {}
		for i = 1, n do
			local s0 = a0 + (i - 1) * l
			local c = creux(bande, s0 - 1, s0 + l + 1)
			local vmin = math.max(horsVolcan(bande, s0 - 1, s0 + l + 1, 0.5), c)
			-- fond : profondeur où s'arrête le gradin (reculé quand la face recule, sans sortir de la bande)
			local fond = bande.arriere
			if vmin > 0 then
				fond = math.min(bande.profondeur - 1, math.max(bande.arriere, vmin + 7))
			end
			liste[i] = { a0 = s0, a1 = s0 + l, a = s0 + l / 2, l = l, vmin = vmin, creux = c, fond = fond }
		end
		return liste
	end

	-- un gradin : une rangée de tranches. Devant, une pente de roche (FillWedge) de 3 à 5 studs tournée de ±8° ;
	-- derrière, la roche jusqu'à bande.arriere ; dessus, l'herbe posée 1 stud en retrait de l'arête.
	-- o : hauteur (fonction de a, continue d'un segment à l'autre), dBase, dMin, dMax, bruitD, materiau,
	-- dos (redescente arrière)
	local function terrasse(bande, tr, prec, o)
		local herbe = Mat.Grass
		if rng:NextNumber() < 0.3 then
			herbe = Mat.LeafyGrass
		end
		local AR = bande.arriere
		local res = {}
		for i, s in ipairs(tr) do
			local yPied, dMin = 0, o.dMin or 0.3
			if prec then
				yPied = prec[i].y
				dMin = prec[i].d + 2.5 -- une corniche d'au moins 2,5 studs sur le gradin du dessous
			end
			local y = math.max(yPied + 4, o.hauteur(s.a))
			y = math.min(PLAFOND, y)
			local fond = s.fond or AR
			local dMax = math.max(o.dMax, s.vmin)
			local pied = math.max(s.vmin, math.min(dMax, math.max(dMin, o.dBase + o.bruitD(s.a))))
			local arete = math.max(pied + 1, math.min(pied + rng:NextNumber(3, 5), fond - 1))
			local yBas = yPied - 4
			local angle = rng:NextNumber(-0.14, 0.14)
			if s.creux > 0 then
				angle = angle * 0.4 -- paroi de l'anse : presque droite, rien ne déborde sur le sentier
			end
			-- pente avant et premier mètre de roche : tournés autour de l'arête
			penteT(bande, s.a, s.l + RECOUVRE, arete, pied, arete, yBas, y, angle, o.materiau)
			blocT(bande, s.a, s.l + RECOUVRE, arete, arete, arete + 4, yBas, y, angle, o.materiau)
			-- le reste du gradin, droit (aucune fente entre tranches), puis l'herbe en retrait de l'arête
			blocT(bande, s.a, s.l + 0.1, 0, arete + 3, fond, yBas, y, 0, o.materiau)
			blocT(bande, s.a, s.l + 0.1, 0, arete + 1, fond, y - HERBE_T, y + 0.1, 0, herbe)
			res[i] = { a0 = s.a0, a1 = s.a1, d = arete, pied = pied, y = y, yBas = yBas, yPied = yPied, angle = angle }
		end

		if o.dos then
			-- la crête redescend en pente vers l'extérieur jusqu'au bord de l'herbe (pas de face arrière verticale) :
			-- une pente par groupe de 3 tranches, à la hauteur de la plus basse (dos lisse, sans dents de scie)
			local D = bande.profondeur
			for g = 1, #tr, 3 do
				local g1 = math.min(#tr, g + 2)
				local yMin = math.huge
				local dDos = AR - 0.5
				for i = g, g1 do
					yMin = math.min(yMin, res[i].y)
					dDos = math.max(dDos, tr[i].vmin + 1) -- jamais devant la paroi de l'anse
				end
				local aC = (tr[g].a0 + tr[g1].a1) / 2
				local larg = tr[g1].a1 - tr[g].a0 + 0.1
				local yDos = math.max(6, math.min(yMin - 3, 17)) -- rejoint le pied de l'arrière-pays (≈ 17)
				if D - dDos >= 1 then
					blocT(bande, aC, larg, 0, dDos, D, -4, yDos, 0, o.materiau)
					penteT(bande, aC, larg, 0, dDos, D, yDos - 0.5, yMin, 0, o.materiau, true)
				end
			end
		end

		return res
	end

	local decorsParBande = {}
	local FACADE = 26 -- profondeur de la façade en gradins (au-delà : dessus de la crête puis redescente)

	local function construireSegment(m, bande, a0, a1, numero, h, hG, hD)
		local AR = bande.arriere
		local B = bande.bruits
		-- hauteur de crête continue : hG au bord gauche, h au milieu, hD au bord droit (raccord en douceur)
		local milieu = (a0 + a1) / 2
		local function lisse(t)
			t = math.max(0, math.min(1, t))
			return t * t * (3 - 2 * t)
		end
		local function hLin(a)
			if a < milieu then
				return hG + (h - hG) * lisse((a - a0) / (milieu - a0))
			end
			return h + (hD - h) * lisse((a - milieu) / (a1 - milieu))
		end
		local function H1(a)
			return math.max(6, hLin(a) * (0.35 + B[7](a))) + B[4](a)
		end
		local function H2(a)
			local v = hLin(a) * (0.65 + B[8](a)) + B[5](a)
			return math.min(hLin(a) - 5, math.max(H1(a) + 6, v))
		end
		local function H3(a)
			return math.min(PLAFOND, hLin(a) + B[6](a))
		end

		local tr = tranches(bande, a0, a1)
		local proche = false
		for _, s in ipairs(tr) do
			if s.vmin > 0 then
				proche = true
			end
			-- sol d'herbe de l'anse (au-delà de l'herbe du Sol), posé avant la roche
			if s.creux > 0 then
				blocT(bande, s.a, s.l + 0.1, 0, 0, s.creux + 1, -4, 0, 0, Mat.Grass)
			end
		end

		-- terrasse basse (roche), terrasse du milieu (strates d'ardoise), sommet (roche) : avancées qui ondulent
		local T1 = terrasse(bande, tr, nil, {
			hauteur = H1, dBase = 1.5, dMin = 0.3, dMax = 3,
			bruitD = B[1], materiau = Mat.Rock,
		})
		local T2 = terrasse(bande, tr, T1, {
			hauteur = H2, dBase = FACADE * 0.33, dMax = AR - 9,
			bruitD = B[2], materiau = Mat.Slate,
		})
		local T3 = terrasse(bande, tr, T2, {
			hauteur = H3, dBase = FACADE * 0.58, dMax = AR - 4,
			bruitD = B[3], materiau = Mat.Rock, dos = true,
		})
		local h1 = H1(milieu)

		-- éboulis au pied (tranche par tranche) et sur la terrasse du milieu, sauf contre le volcan
		if not proche then
			local nb = math.max(2, math.floor(#tr * rng:NextNumber(0.35, 0.7)))
			nb = math.min(nb, #tr)
			local i0 = rng:NextInteger(1, #tr - nb + 1)
			local hE = h1 * rng:NextNumber(0.4, 0.6)
			for i = i0, i0 + nb - 1 do
				local mc = T1[i]
				local hh = hE * rng:NextNumber(0.85, 1.1)
				if i == i0 or i == i0 + nb - 1 then
					hh = hE * 0.6
				end
				local fond = mc.pied + (mc.d - mc.pied) * 0.8
				penteT(bande, tr[i].a, tr[i].l + RECOUVRE, fond, math.max(0, mc.pied - rng:NextNumber(2, 3.5)), fond, -1, hh, mc.angle, Mat.Rock)
			end
			if rng:NextNumber() < 0.45 and #tr >= 4 then
				local nb2 = math.min(#tr, rng:NextInteger(3, 5))
				local j0 = rng:NextInteger(1, #tr - nb2 + 1)
				for i = j0, j0 + nb2 - 1 do
					local bas, mc = T1[i], T2[i]
					local fond = mc.pied + (mc.d - mc.pied) * 0.8
					local d0 = math.max(bas.d + 0.5, mc.pied - rng:NextNumber(2, 3.5))
					penteT(bande, tr[i].a, tr[i].l + RECOUVRE, fond, d0, fond, bas.y - 1, bas.y + (mc.y - bas.y) * rng:NextNumber(0.45, 0.6), mc.angle, Mat.Slate)
				end
			end
		end

		-- 1 ou 2 grosses rondeurs à moitié enfoncées dans les faces du milieu et du sommet
		for k = 1, rng:NextInteger(1, 2) do
			local T = T2
			if rng:NextNumber() < 0.5 then
				T = T3
			end
			local aB = rng:NextNumber(a0 + 3, a1 - 3)
			local mc = morceauEn(T, aB)
			local Y = (mc.yPied + mc.y) / 2
			local dS = surface(mc, Y)
			local r = math.min(rng:NextNumber(5, 8), dS + 0.5, PLAFOND - Y)
			if r >= 3 then
				local materiau = Mat.Rock
				if k == 2 then
					materiau = Mat.Slate
				end
				local p = point(bande, aB, dS + r * 0.5, Y)
				if libre(p, r) then
					Outils.terrainBoule(p, r, materiau)
				end
			end
		end

		-- dessus de crête large (falaise sud) : quelques bosses d'herbe et de roche pour casser le plat
		for i = 1, #tr, 3 do
			local mc = T3[i]
			if AR - mc.d > 10 then
				local r = rng:NextNumber(4.5, 7)
				local dP = rng:NextNumber(mc.d + r + 1, AR - 1)
				local p = point(bande, tr[i].a + rng:NextNumber(-1, 1), dP, mc.y - r * 0.55)
				if p.Y + r <= PLAFOND and libre(p, r) then
					local materiau = Mat.Grass
					if rng:NextNumber() < 0.35 then
						materiau = Mat.Rock
					end
					Outils.terrainBoule(p, r, materiau)
				end
			end
		end

		-- de temps en temps, un affleurement anguleux sur la crête : 1 ou 2 arêtes de roche (deux coins dos à dos,
		-- en toit) inclinées de 15 à 30°, à moitié enfoncées : une silhouette de roc, pas de boules empilées
		if rng:NextNumber() < 0.4 then
			local aA = rng:NextNumber(a0 + 6, a1 - 6)
			local cote = 1
			if rng:NextNumber() < 0.5 then
				cote = -1
			end
			for k = 1, rng:NextInteger(1, 2) do
				local L = rng:NextNumber(6, 8)
				local H = rng:NextNumber(6, 8)
				local P = rng:NextNumber(6, 8)
				local aK = aA + cote * (k - 1) * rng:NextNumber(4, 6)
				local mK = morceauEn(T3, aK)
				local incl = math.rad(rng:NextNumber(15, 30))
				if rng:NextNumber() < 0.5 then
					incl = -incl
				end
				local yC = mK.y + H * 0.15
				local demiHaut = (H * math.cos(incl) + P * math.abs(math.sin(incl))) / 2
				local centre = point(bande, aK, math.min(AR - 1, mK.d + rng:NextNumber(2, 4)), yC)
				if yC + demiHaut <= PLAFOND + 0.5 and libre(centre, 6) then
					local cf = CFrame.new(centre) * CFrame.Angles(0, rng:NextNumber(0, DEUX_PI), 0)
						* CFrame.Angles(incl, 0, math.rad(rng:NextNumber(-12, 12)))
					local materiau = Mat.Rock
					if k == 2 then
						materiau = Mat.Slate
					end
					Outils.terrainCoin(cf * CFrame.new(0, 0, -P / 4), Vector3.new(L, H, P / 2), materiau)
					Outils.terrainCoin(cf * CFrame.new(0, 0, P / 4) * CFrame.Angles(0, math.pi, 0), Vector3.new(L, H, P / 2), materiau)
				end
			end
		end

		-- décor (ajouté après toutes les falaises : la structure passe d'abord)
		local liste = decorsParBande[bande.nom]
		local s = m
		local function auHasard(marge)
			return rng:NextNumber(a0 + marge, a1 - marge)
		end

		-- mousse qui déborde de la terrasse basse
		local aM = auHasard(3)
		local mM = morceauEn(T1, aM)
		local posM = point(bande, aM, mM.d + 0.7, mM.y + 0.05)
		local lM = rng:NextNumber(4, 6.5)
		table.insert(liste, function()
			decor(part(Outils.boule, s, {
				Name = "Mousse",
				Size = tailleBande(bande, lM, 1.3, 3),
				CFrame = CFrame.new(posM),
				Color = MOUSSE,
				Material = Mat.Grass,
			}))
		end)
		if numero % 2 == 0 then
			local aM2 = auHasard(3)
			local mM2 = morceauEn(T2, aM2)
			local posM2 = point(bande, aM2, mM2.d + 0.6, mM2.y + 0.05)
			local lM2 = rng:NextNumber(4, 6)
			table.insert(liste, function()
				decor(part(Outils.boule, s, {
					Name = "Mousse",
					Size = tailleBande(bande, lM2, 1.2, 2.6),
					CFrame = CFrame.new(posM2),
					Color = FEUILLE_CLAIRE,
					Material = Mat.Grass,
				}))
			end)
		end

		local variante = numero % 3
		if variante ~= 2 then
			-- touffe au bord de la crête
			local aT = auHasard(3)
			local mT = morceauEn(T3, aT)
			local tT = rng:NextNumber(2.4, 3.6)
			local posT = point(bande, aT, mT.d + tT * 0.4, mT.y + tT * 0.15)
			table.insert(liste, function()
				decor(part(Outils.boule, s, {
					Name = "Buisson",
					Size = Vector3.new(tT, tT * 0.75, tT),
					CFrame = CFrame.new(posT),
					Color = FEUILLE,
					Material = Mat.LeafyGrass,
				}))
			end)
		end
		if variante == 1 then
			-- une liane qui suit la pente du sommet
			local aV = auHasard(2)
			local mV = morceauEn(T3, aV)
			local basV = morceauEn(T2, aV).y
			local chuteV = math.max(2, (mV.y - basV) * rng:NextNumber(0.5, 0.8))
			local posV = point(bande, aV, surface(mV, mV.y - chuteV / 2) - 0.3, mV.y - chuteV / 2)
			local posVF = point(bande, aV, surface(mV, mV.y - chuteV) - 0.5, mV.y - chuteV)
			table.insert(liste, function()
				decor(part(Outils.bloc, s, {
					Name = "Liane",
					Size = Vector3.new(0.3, chuteV, 0.3),
					CFrame = CFrame.new(posV),
					Color = LIANE,
					Material = Mat.LeafyGrass,
				}))
				decor(part(Outils.boule, s, {
					Name = "Feuilles",
					Size = Vector3.new(1.2, 1, 1.2),
					CFrame = CFrame.new(posVF),
					Color = FEUILLE_CLAIRE,
					Material = Mat.LeafyGrass,
				}))
			end)
		end
		if variante == 0 then
			-- deux lianes sur la face du milieu
			for _ = 1, 2 do
				local a = auHasard(2)
				local mc = morceauEn(T2, a)
				local bas = morceauEn(T1, a).y
				local chute = math.max(2, (mc.y - bas) * rng:NextNumber(0.5, 0.85))
				local posL = point(bande, a, surface(mc, mc.y - chute / 2) - 0.3, mc.y - chute / 2)
				local posF = point(bande, a, surface(mc, mc.y - chute) - 0.5, mc.y - chute)
				table.insert(liste, function()
					decor(part(Outils.bloc, s, {
						Name = "Liane",
						Size = Vector3.new(0.3, chute, 0.3),
						CFrame = CFrame.new(posL),
						Color = LIANE,
						Material = Mat.LeafyGrass,
					}))
					decor(part(Outils.boule, s, {
						Name = "Feuilles",
						Size = Vector3.new(1.3, 1.1, 1.3),
						CFrame = CFrame.new(posF),
						Color = FEUILLE,
						Material = Mat.LeafyGrass,
					}))
				end)
			end
		elseif variante == 1 then
			-- petite cascade de feuillage qui coule d'une corniche en suivant la pente
			local a = auHasard(3)
			local haute, basse = T3, T2
			if rng:NextNumber() < 0.5 then
				haute, basse = T2, T1
			end
			local mc = morceauEn(haute, a)
			local yHaut, yBas = mc.y, morceauEn(basse, a).y
			local morceaux = {
				{ 0, 0.3, -0.1, 5, 2, 3, FEUILLE_CLAIRE, true },
				{ 0.3, -0.4, -2.3, 4, 3.4, 1.1, FEUILLE, false },
				{ -0.4, -0.5, -5, 3, 3.2, 1, FEUILLE, false },
				{ 0.2, -0.6, -7.2, 2.2, 2, 1.3, LIANE, true },
			}
			table.insert(liste, function()
				for _, fm in ipairs(morceaux) do
					local y = yHaut + fm[3]
					if y - fm[5] / 2 > yBas - 0.5 then
						local fabrique = Outils.bloc
						if fm[8] then
							fabrique = Outils.boule
						end
						decor(part(fabrique, s, {
							Name = "Feuillage",
							Size = tailleBande(bande, fm[4], fm[5], fm[6]),
							CFrame = CFrame.new(point(bande, a + fm[1], surface(mc, y) + fm[2], y)),
							Color = fm[7],
							Material = Mat.LeafyGrass,
						}))
					end
				end
			end)
		else
			-- buisson au sommet et liane sur la terrasse basse
			local a = auHasard(3)
			local mc = morceauEn(T3, a)
			local t = rng:NextNumber(3.5, 5)
			local dB = math.max(mc.d + 1.5, (mc.d + AR) / 2)
			local posB = point(bande, a, dB, mc.y + t * 0.25)
			local posB2 = point(bande, a + t * 0.6, dB + 1, mc.y + t * 0.1)
			local aL = auHasard(2)
			local mL = morceauEn(T1, aL)
			local chute = mL.y * rng:NextNumber(0.4, 0.6)
			local posL = point(bande, aL, surface(mL, mL.y - chute / 2) - 0.3, mL.y - chute / 2)
			table.insert(liste, function()
				decor(part(Outils.boule, s, {
					Name = "Buisson",
					Size = Vector3.new(t, t * 0.85, t),
					CFrame = CFrame.new(posB),
					Color = FEUILLE,
					Material = Mat.LeafyGrass,
				}))
				decor(part(Outils.boule, s, {
					Name = "Buisson",
					Size = Vector3.new(t * 0.7, t * 0.6, t * 0.7),
					CFrame = CFrame.new(posB2),
					Color = FEUILLE_CLAIRE,
					Material = Mat.LeafyGrass,
				}))
				decor(part(Outils.bloc, s, {
					Name = "Liane",
					Size = Vector3.new(0.3, chute, 0.3),
					CFrame = CFrame.new(posL),
					Color = LIANE,
					Material = Mat.LeafyGrass,
				}))
			end)
		end
	end

	-- les 4 bandes de Plan.falaises : face tournée vers le monde, profondeur jusqu'aux murs invisibles.
	-- Est/Ouest couvrent toute leur longueur (coins compris) ; Nord/Sud débordent de 4 studs dans Est/Ouest
	-- pour fermer les coins sans fente.
	local F = Plan.falaises or {}
	local BANDES = {}
	if F.est then
		table.insert(BANDES, { nom = "FalaiseEst", axe = "z", avant = F.est.xMin, sens = 1, profondeur = F.est.xMax - F.est.xMin,
			a0 = F.est.zMin, a1 = F.est.zMax, hMin = HAUTEUR_MIN + 2, hMax = HAUTEUR_MAX })
	end
	if F.ouest then
		table.insert(BANDES, { nom = "FalaiseOuest", axe = "z", avant = F.ouest.xMax, sens = -1, profondeur = F.ouest.xMax - F.ouest.xMin,
			a0 = F.ouest.zMin, a1 = F.ouest.zMax, hMin = HAUTEUR_MIN + 2, hMax = HAUTEUR_MAX })
	end
	local function etendueX(b)
		local x0, x1 = b.xMin, b.xMax
		if F.ouest then
			x0 = math.max(x0, F.ouest.xMax - 4)
		end
		if F.est then
			x1 = math.min(x1, F.est.xMin + 4)
		end
		return x0, x1
	end
	if F.nord then
		local x0, x1 = etendueX(F.nord)
		table.insert(BANDES, { nom = "FalaiseNord", axe = "x", avant = F.nord.zMax, sens = -1, profondeur = F.nord.zMax - F.nord.zMin,
			a0 = x0, a1 = x1, hMin = HAUTEUR_MIN + 4, hMax = HAUTEUR_MAX })
	end
	if F.sud then
		local x0, x1 = etendueX(F.sud)
		table.insert(BANDES, { nom = "FalaiseSud", axe = "x", avant = F.sud.zMin, sens = 1, profondeur = F.sud.zMax - F.sud.zMin,
			a0 = x0, a1 = x1, hMin = HAUTEUR_MIN, hMax = math.max(HAUTEUR_MIN, HAUTEUR_MAX - 6) })
	end
	for _, bande in ipairs(BANDES) do
		bande.arriere = math.max(14, bande.profondeur - 8)
	end

	local function construireBande(bande)
		local m = Outils.modele(dossier, bande.nom)
		decorsParBande[bande.nom] = decorsParBande[bande.nom] or {}
		-- bruits continus sur toute la bande : avancées (amplitude 3, périodes 23 et 9) puis hauteurs
		bande.bruits = {
			nouveauBruit(3, 23, 9), nouveauBruit(3, 23, 9), nouveauBruit(3, 23, 9),
			nouveauBruit(1.5, 29, 13), nouveauBruit(2, 31, 13), nouveauBruit(2.5, 37, 15),
			nouveauBruit(0.05, 67, 29), nouveauBruit(0.05, 59, 31),
		}
		local longueur = bande.a1 - bande.a0
		local n = math.max(1, math.floor(longueur / LONGUEUR_SEGMENT + 0.5))
		local pas = longueur / n
		-- hauteurs tirées puis lissées avec les voisines : une ligne de crête qui ondule
		local brut = {}
		for i = 1, n do
			brut[i] = rng:NextNumber(bande.hMin, math.max(bande.hMin, bande.hMax))
		end
		local hs, force = {}, {}
		for i = 1, n do
			local a0 = bande.a0 + (i - 1) * pas
			local a1 = a0 + pas
			local g = brut[math.max(1, i - 1)]
			local d = brut[math.min(n, i + 1)]
			local h = math.floor(brut[i] * 0.5 + (g + d) * 0.25 + 0.5)
			local h0 = h
			-- falaise haute derrière la plateforme du coffre, et assez haute pour la cascade de la rivière
			if coffre and bande.axe == "z" and bande.sens == SX and a1 > coffre.Z - 16 and a0 < coffre.Z + 16 then
				h = math.max(h, math.floor(coffre.Y + 10))
			end
			local riv = Plan.riviere
			if riv and bande.nom == "FalaiseEst" and riv.zMin and a1 > riv.zMin - 4 and a0 < riv.zMax + 4 then
				h = math.max(h, 27)
			end
			-- derrière le Volcan : un mur de roche haut (30 studs et plus) qui ferme l'horizon
			if horsVolcan(bande, a0, a1, 0.5) > 0 then
				h = math.max(h, 30)
			end
			hs[i] = math.min(PLAFOND - 3, math.max(15, h))
			force[i] = h > h0 -- hauteur imposée (coffre, cascade, volcan) : tenue jusqu'aux jointures
		end
		-- aux jointures, la crête passe par la moyenne des deux segments voisins : pas de marche d'un segment à l'autre
		for i = 1, n do
			local a0 = bande.a0 + (i - 1) * pas
			local function jointure(j)
				if force[i] or force[j] then
					return math.max(hs[i], hs[j])
				end
				return (hs[i] + hs[j]) / 2
			end
			local hG = jointure(math.max(1, i - 1))
			local hD = jointure(math.min(n, i + 1))
			construireSegment(m, bande, a0, a0 + pas, i, hs[i], hG, hD)
		end
	end

	-- ===== 4. arrière-pays : collines de roche derrière les murs invisibles (40 studs), l'horizon est toujours de la roche =====
	local function construireArrierePays()
		local PROF = 40
		if not (F.est and F.ouest and F.nord and F.sud) then
			return
		end
		local xE, xO, zN, zS = F.est.xMax, F.ouest.xMin, F.nord.zMin, F.sud.zMax
		local cotes = {
			{ axe = "z", avant = xE, sens = 1, a0 = zN - PROF, a1 = zS + PROF },
			{ axe = "z", avant = xO, sens = -1, a0 = zN - PROF, a1 = zS + PROF },
			{ axe = "x", avant = zN, sens = -1, a0 = xO, a1 = xE },
			{ axe = "x", avant = zS, sens = 1, a0 = xO, a1 = xE },
		}
		for _, bande in ipairs(cotes) do
			-- une seule rampe de roche par côté (pas de marches ni de dents de scie), de 18 à 42 studs vers l'extérieur
			local aC, L = (bande.a0 + bande.a1) / 2, bande.a1 - bande.a0
			local BASE, SOMMET = 18, 42
			blocT(bande, aC, L, 0, -1, PROF, -12, BASE, 0, Mat.Rock)
			penteT(bande, aC, L, 0, -1, PROF, BASE - 0.5, SOMMET, 0, Mat.Rock)
			-- bosses espacées irrégulièrement : croupes d'herbe sur la pente, têtes de roche sur la ligne de crête
			local a = bande.a0 + rng:NextNumber(5, 25)
			while a < bande.a1 - 5 do
				if rng:NextNumber() < 0.55 then
					local r = rng:NextNumber(12, 18)
					local dG = rng:NextNumber(8, 22)
					local ySurf = BASE + (SOMMET - BASE) * (dG / PROF)
					Outils.terrainBoule(point(bande, a, dG, math.min(ySurf - r * 0.7, 50 - r)), r, Mat.Grass)
				else
					-- tête de roche enfoncée dans la rampe (rien ne dépasse l'arrière ni 50 studs de haut)
					local r = rng:NextNumber(8, 12)
					local dR = PROF - r - rng:NextNumber(0, 3)
					local ySurf = BASE + (SOMMET - BASE) * (dR / PROF)
					Outils.terrainBoule(point(bande, a, dR, math.min(ySurf - r * 0.65, 50 - r)), r, Mat.Rock)
				end
				a = a + rng:NextNumber(26, 48)
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
	table.insert(etapes, { "arrierePays", construireArrierePays })
	table.insert(etapes, { "decor", function()
		-- une pièce de décor par bande à tour de rôle : le budget se répartit sur toutes les falaises
		local i = 1
		local reste = true
		while reste and compteur < BUDGET do
			reste = false
			for _, bande in ipairs(BANDES) do
				local liste = decorsParBande[bande.nom]
				local f = liste and liste[i]
				if f then
					reste = true
					if compteur < BUDGET then
						local ok, err = pcall(f)
						if not ok then
							warn("[Dino] Falaises (décor) : " .. tostring(err))
						end
					end
				end
			end
			i = i + 1
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
