-- Systemes/Tapis : fabrique tous les dinos vivants (répondeur CreerDino), fait apparaître
-- des dinos au début du Tapis roulant et les fait avancer jusqu'à la Fin du tapis.
-- Version 2 : sur le Tapis, les dinos marchent (pattes, queue et ailes animées par rotation
-- locale dans la boucle Heartbeat) ; les raretés Épique et plus portent une aura d'étincelles.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local M = {}

local ANGLE_REGARD = -math.pi / 2 -- le regard (-Z local) tourné vers +X
local MARGE_TAPIS = 1              -- chaque dino tient dans la largeur du tapis moins 1 stud de chaque côté
local ECART_TAPIS = 6              -- espace libre minimal (studs) entre deux dinos : on voit le tapis entre eux
local DANDINEMENT_ANGLE = 0.07    -- radians de roulis
local DANDINEMENT_HAUTEUR = 0.15  -- studs de sautillement
local DANDINEMENT_FREQUENCE = 7   -- radians par seconde
local INTERVALLE_ADOPTION = 1     -- secondes entre deux recherches de dinos « Tapis » inconnus

-- marche : un pas par sautillement, pattes en diagonale (AvG avec ArD, AvD avec ArG)
local MARCHE_ANGLE = 0.42         -- radians de balancement des pattes
local QUEUE_ANGLE = 0.2           -- radians de balancement de la queue (de gauche à droite)
local QUEUE_RETARD = 0.9          -- la queue suit le pas avec un léger retard
local AILE_ANGLE = 0.3            -- radians de battement des ailes
local AILE_RYTHME = 1.5           -- battements plus rapides que les pas
local DISTANCE_ANIMATION = 160    -- au-delà de tout joueur, les membres ne sont plus animés
local PATTES = {
	PatteAvG = { cote = "G", decal = 0 },
	PatteArD = { cote = "D", decal = 0 },
	PatteAvD = { cote = "D", decal = math.pi },
	PatteArG = { cote = "G", decal = math.pi },
}
-- parts rattachées à la patte la plus proche du même côté (nom terminé par G ou D)
local ACCESSOIRES = { "Pied", "Main", "Griffe", "Pouce", "Cuisse", "Sabot", "Orteil", "Ongle" }
local TEXTURE_AURA = "rbxasset://textures/particles/sparkles_main.dds"
-- parts du visage : jamais recolorées par une mutation (le dino garde un regard lisible)
local VISAGE = { "Oeil", "Iris", "Pupille", "Reflet", "Eclat", "Narine", "Joue", "Sourcil", "Bouche", "Dent" }
-- mutation Lave : parts qui deviennent des coulées de lave (Neon), le reste vire à la pierre
local LAVE_DEBUT = { "Tache", "Bosse", "Crete", "Pied" }
-- capitales accentuées (string.upper ne traite pas les lettres UTF-8)
local ACCENTS_MAJ = {
	["é"] = "É", ["è"] = "È", ["ê"] = "Ê", ["ë"] = "Ë", ["à"] = "À", ["â"] = "Â",
	["î"] = "Î", ["ï"] = "Ï", ["ô"] = "Ô", ["û"] = "Û", ["ù"] = "Ù", ["ç"] = "Ç",
}

local function commencePar(nom, liste)
	for _, prefixe in ipairs(liste) do
		if string.sub(nom, 1, #prefixe) == prefixe then
			return true
		end
	end
	return false
end

local function majuscules(s)
	s = string.upper(tostring(s or ""))
	for min, maj in pairs(ACCENTS_MAJ) do
		s = string.gsub(s, min, maj)
	end
	return s
end

function M.demarrer(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Bus = ctx.Bus
	local Etat = ctx.Etat

	local alea = Random.new()
	local compteur = 0

	-- ===== outils internes =====

	local function partsDe(modele)
		local liste = {}
		for _, d in ipairs(modele:GetDescendants()) do
			if d:IsA("BasePart") then
				table.insert(liste, d)
			end
		end
		return liste
	end

	-- nom affiché : espèce + mutation éventuelle
	local function nomAffiche(espece, mutation)
		local infos = E.especes[espece]
		local nom = (infos and infos.nom) or espece
		local mut = E.mutations[mutation]
		if mut and mut.nom and mut.nom ~= "" then
			nom = nom .. " " .. mut.nom
		end
		return nom
	end

	-- modèle de secours quand le gabarit de l'espèce manque
	local function modeleSecours(espece, rarete)
		local m = Instance.new("Model")
		m.Name = espece
		local taille = Vector3.new(3, 2, 4)
		local corps = Outils.bloc(m, {
			Name = "Corps",
			Size = taille,
			CFrame = CFrame.new(0, taille.Y / 2, 0),
			Color = Charte.raretes[rarete] or Charte.creme,
			CanCollide = false,
			CanQuery = true,
		})
		corps.PivotOffset = CFrame.new(0, -taille.Y / 2, 0)
		m.PrimaryPart = corps
		m:SetAttribute("Espece", espece)
		return m
	end

	-- aspect visuel de la mutation
	local function appliquerMutation(modele, corps, mutation)
		if mutation == "Normal" then
			return
		end
		local teinte = Charte.mutations[mutation]
		if not teinte then
			return
		end
		local parts = partsDe(modele)
		local teinteArc = 0
		for _, p in ipairs(parts) do
			if p.Transparency < 1 and not commencePar(p.Name, VISAGE) then
				if mutation == "Or" then
					p.Color = p.Color:Lerp(teinte, 0.75)
					p.Material = Enum.Material.Metal
				elseif mutation == "Diamant" then
					p.Color = p.Color:Lerp(teinte, 0.65)
					p.Material = Enum.Material.Glass
					p.Reflectance = 0.15
				elseif mutation == "ArcEnCiel" then
					-- chaque part prend sa propre teinte (angle d'or) : un vrai dino arc-en-ciel
					teinteArc = teinteArc + 1
					local h = (teinteArc * 0.137) % 1
					p.Color = Color3.fromHSV(h, 0.55, 1)
					p:SetAttribute("TeinteArc", h) -- teinte de départ, que le client peut faire défiler
				elseif mutation == "Lave" then
					if commencePar(p.Name, LAVE_DEBUT) or string.sub(p.Name, -4) == "Bout" then
						p.Color = teinte
						p.Material = Enum.Material.Neon
					else
						p.Color = p.Color:Lerp(Charte.pierre, 0.35)
					end
				elseif mutation == "Meteore" then
					p.Color = p.Color:Lerp(teinte, 0.65)
				end
			end
		end
		if mutation == "ArcEnCiel" then
			-- aura de particules qui passe par toutes les couleurs
			if not corps:FindFirstChild("AuraArcEnCiel") then
				local points = {}
				for k = 0, 6 do
					table.insert(points, ColorSequenceKeypoint.new(k / 6, Color3.fromHSV((k / 6) % 1, 0.7, 1)))
				end
				local k = math.max(0.8, math.min(2, corps.Size.Y / 2.6))
				local e = Instance.new("ParticleEmitter")
				e.Name = "AuraArcEnCiel"
				e.Texture = TEXTURE_AURA
				e.Color = ColorSequence.new(points)
				e.LightEmission = 0.9
				e.LightInfluence = 0
				e.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.25, 0.5 * k),
					NumberSequenceKeypoint.new(1, 0),
				})
				e.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.15),
					NumberSequenceKeypoint.new(1, 1),
				})
				e.Lifetime = NumberRange.new(1.2, 2)
				e.Rate = 9
				e.Speed = NumberRange.new(0.8, 1.8)
				e.SpreadAngle = Vector2.new(180, 180)
				e.Acceleration = Vector3.new(0, 2, 0)
				e.Drag = 1.5
				e.Rotation = NumberRange.new(0, 360)
				e.RotSpeed = NumberRange.new(-90, 90)
				e.Parent = corps
			end
			Outils.lumiere(corps, { genre = "Point", Range = 10, Brightness = 1.2, Color = Color3.fromHSV(0.83, 0.4, 1) })
		elseif mutation == "Meteore" then
			Outils.lumiere(corps, { genre = "Point", Range = 12, Brightness = 2, Color = Charte.violet })
		elseif mutation == "Lave" then
			Outils.lumiere(corps, { genre = "Point", Range = 8, Brightness = 1, Color = Charte.lave })
		end
	end

	-- aura discrète d'étincelles de la couleur de rareté (Épique et plus), plus dense aux raretés hautes
	local function poserAura(corps, rarete)
		local infos = E.raretes[rarete]
		local seuil = E.raretes.Epique
		local couleur = Charte.raretes[rarete]
		if not (infos and seuil and couleur) or infos.ordre < seuil.ordre then
			return
		end
		if corps:FindFirstChild("AuraRarete") then
			return
		end
		local rang = infos.ordre - seuil.ordre
		local k = math.max(0.8, math.min(2, corps.Size.Y / 2.6))
		local e = Instance.new("ParticleEmitter")
		e.Name = "AuraRarete"
		e.Texture = TEXTURE_AURA
		e.Color = ColorSequence.new(Charte.lumiere(couleur), couleur)
		e.LightEmission = 0.8
		e.LightInfluence = 0
		e.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.25, 0.42 * k),
			NumberSequenceKeypoint.new(1, 0),
		})
		e.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.2, 0.25),
			NumberSequenceKeypoint.new(1, 1),
		})
		e.Lifetime = NumberRange.new(1.1, 1.8)
		e.Rate = 3 + rang * 1.5
		e.Speed = NumberRange.new(0.6, 1.4)
		e.SpreadAngle = Vector2.new(180, 180)
		e.Acceleration = Vector3.new(0, 1.5, 0)
		e.Drag = 1.5
		e.Rotation = NumberRange.new(0, 360)
		e.RotSpeed = NumberRange.new(-60, 60)
		e.Parent = corps
	end

	-- hauteur du haut du modèle au-dessus du centre du Corps
	local function hauteurAuDessus(modele, corps)
		local haut = corps.Size.Y / 2
		for _, p in ipairs(partsDe(modele)) do
			local h = p.Position.Y + p.Size.Y / 2 - corps.Position.Y
			if h > haut then
				haut = h
			end
		end
		return haut
	end

	-- étiquette flottante « style simulateur » (STYLE.md §3) :
	-- mutation · NOM · rareté (dégradé) · prix vert · revenu jaune
	local function poserEtiquette(modele, corps, espece, rarete, mutation, prix, revenu)
		local ancienne = corps:FindFirstChild("Etiquette")
		if ancienne then
			ancienne:Destroy()
		end
		local Style = ctx.Style
		local infosEspece = E.especes[espece]
		local infosRarete = E.raretes[rarete]
		local lignes = {}

		local mut = E.mutations[mutation]
		if mutation ~= "Normal" and mut then
			local couleurMut = Charte.mutations[mutation] or Style.couleurs.texte
			if mutation == "Meteore" then
				couleurMut = Charte.violet -- la teinte Météore est trop sombre pour être lue
			end
			local nomMut = (mut.nom and mut.nom ~= "" and mut.nom) or mutation
			table.insert(lignes, { nom = "Mutation", texte = majuscules(nomMut), couleur = couleurMut, taille = 0.8 })
		end
		table.insert(lignes, {
			nom = "Nom",
			texte = majuscules((infosEspece and infosEspece.nom) or espece),
			titre = true,
			taille = 1.4,
			contour = 3.5,
		})
		if infosEspece and infosEspece.special then
			-- Œuf mystère : rareté inconnue (arc-en-ciel), prix, promesse d'éclosion
			local minutes = math.floor(((E.oeuf and E.oeuf.incubation) or 900) / 60 + 0.5)
			table.insert(lignes, { nom = "Rarete", texte = "??? DU PLUS NUL AU PLUS RARE ???", rarete = "Divin", taille = 0.8 })
			table.insert(lignes, { nom = "Prix", texte = Charte.argent(prix), couleur = Style.couleurs.argent, taille = 1 })
			table.insert(lignes, { nom = "Revenu", texte = "🐣 Éclot en " .. minutes .. " min", couleur = Style.couleurs.revenu, taille = 0.9 })
		else
		table.insert(lignes, { nom = "Rarete", texte = (infosRarete and infosRarete.nom) or rarete, rarete = rarete, taille = 0.9 })
		table.insert(lignes, { nom = "Prix", texte = Charte.argent(prix), couleur = Style.couleurs.argent, taille = 1 })
		table.insert(lignes, { nom = "Revenu", texte = Style.revenu(revenu), couleur = Style.couleurs.revenu, taille = 0.9 })
		end

		local gui = Style.etiquette(corps, lignes, {
			Name = "Etiquette",
			largeur = 10,
			StudsOffset = Vector3.new(0, hauteurAuDessus(modele, corps) + 3, 0),
			MaxDistance = 90,
		})
		return gui
	end

	-- ===== répondeur CreerDino =====
	local function creerDino(espece, mutation)
		if type(espece) ~= "string" then
			return nil
		end
		local infos = E.especes[espece]
		if not infos then
			return nil
		end
		if type(mutation) ~= "string" or not E.mutations[mutation] then
			mutation = "Normal"
		end
		local rarete = infos.rarete
		local mult = E.mutations[mutation].multiplicateur or 1

		-- clone du gabarit, ou modèle de secours
		local modele = nil
		local gabarits = ctx.stockage and ctx.stockage:FindFirstChild("Dinos")
		local gabarit = gabarits and gabarits:FindFirstChild(espece)
		if gabarit and gabarit:IsA("Model") then
			local ok, copie = pcall(function()
				return gabarit:Clone()
			end)
			if ok and copie then
				modele = copie
			end
		end
		if not modele then
			modele = modeleSecours(espece, rarete)
		end

		local corps = modele:FindFirstChild("Corps")
		if not (corps and corps:IsA("BasePart")) then
			corps = modele.PrimaryPart
		end
		if not corps then
			for _, p in ipairs(partsDe(modele)) do
				corps = p
				break
			end
		end
		if not corps then
			modele:Destroy()
			modele = modeleSecours(espece, rarete)
			corps = modele.PrimaryPart
		end
		if not modele.PrimaryPart then
			modele.PrimaryPart = corps
		end
		-- dino voxel assemblé : seule la PrimaryPart est ancrée, le reste suit par soudures et articulations
		local assemble = modele:GetAttribute("Assemble") == true
		for _, p in ipairs(partsDe(modele)) do
			p.Anchored = (not assemble) or p == corps
			p.CanCollide = false
		end
		-- trop large pour le tapis : réduit (pivot au sol, proportions gardées)
		local okBoite, mnB, mxB = pcall(boiteLocale, modele)
		-- ce qui vole (Œuf mystère) plane au-dessus des rebords : pas besoin de le réduire
		if infos.vol then okBoite = false end
		if okBoite then
			local f = facteurLargeur(mnB, mxB)
			if f < 1 then
				pcall(function() modele:ScaleTo(modele:GetScale() * f) end)
			end
		end

		compteur = compteur + 1
		local prix = math.floor(infos.prix * mult)
		local revenu = infos.revenu * mult
		modele.Name = espece
		modele:SetAttribute("Id", "D" .. compteur)
		modele:SetAttribute("Espece", espece)
		modele:SetAttribute("Rarete", rarete)
		modele:SetAttribute("Mutation", mutation)
		modele:SetAttribute("Prix", prix)
		modele:SetAttribute("Revenu", revenu)
		modele:SetAttribute("Etat", "Tapis")
		modele:SetAttribute("Proprietaire", 0)
		modele:SetAttribute("Base", 0)
		modele:SetAttribute("Emplacement", 0)
		modele:SetAttribute("Voleur", 0)
		modele:SetAttribute("Stock", 0)

		pcall(appliquerMutation, modele, corps, mutation)
		pcall(poserEtiquette, modele, corps, espece, rarete, mutation, prix, revenu)
		pcall(poserAura, corps, rarete)

		modele.Parent = ctx.dinos
		return modele
	end
	Bus.repondre("CreerDino", creerDino)

	-- ===== tirages =====
	local especesParRarete = {}
	for cle, infos in pairs(E.especes) do
		if infos.special then
			-- l'Œuf mystère a son propre tirage (voir apparaitre)
		else
		especesParRarete[infos.rarete] = especesParRarete[infos.rarete] or {}
		table.insert(especesParRarete[infos.rarete], cle)
		end
	end
	for _, liste in pairs(especesParRarete) do
		table.sort(liste)
	end

	local function tirer(poids)
		local total = 0
		for _, entree in ipairs(poids) do
			total = total + entree.poids
		end
		if total <= 0 then
			return nil
		end
		local r = alea:NextNumber() * total
		for _, entree in ipairs(poids) do
			r = r - entree.poids
			if r <= 0 and entree.poids > 0 then
				return entree.cle
			end
		end
		for i = #poids, 1, -1 do
			if poids[i].poids > 0 then
				return poids[i].cle
			end
		end
		return nil
	end

	local function evenementCourant()
		local nom = Etat:GetAttribute("Evenement")
		if type(nom) ~= "string" or nom == "" then
			return "", nil
		end
		return nom, E.evenements.liste[nom]
	end

	local function tirerRarete(evenement)
		local seuil = E.raretes.Epique.ordre
		local bonus = 1
		if evenement and type(evenement.bonusRarete) == "number" then
			bonus = evenement.bonusRarete
		end
		local poids = {}
		for cle, infos in pairs(E.raretes) do
			if especesParRarete[cle] then
				local p = infos.poids
				if infos.ordre >= seuil then
					p = p * bonus
				end
				table.insert(poids, { cle = cle, poids = p, ordre = infos.ordre })
			end
		end
		table.sort(poids, function(a, b) return a.ordre < b.ordre end)
		return tirer(poids) or "Commun"
	end

	local function tirerMutation(nomEvenement, evenement)
		local bonusMutation = (evenement and evenement.bonusMutation) or {}
		local poids = {}
		for cle, infos in pairs(E.mutations) do
			local p = infos.poids + (bonusMutation[cle] or 0)
			if infos.evenement and infos.evenement ~= nomEvenement then
				p = 0
			end
			table.insert(poids, { cle = cle, poids = p })
		end
		table.sort(poids, function(a, b) return a.cle < b.cle end)
		return tirer(poids) or "Normal"
	end

	-- ===== suivi des dinos sur le Tapis =====
	-- dino -> { x, phase, groupes (membres animés), anime (un joueur est assez près) }
	local surTapis = {}
	local nombreSurTapis = 0
	local positionsJoueurs = {}

	-- boîte englobante d'un modèle dans le repère de son pivot (min, max)
	local function boiteLocale(modele)
		local pivot = modele:GetPivot()
		local mn, mx
		for _, p in ipairs(modele:GetDescendants()) do
			if p:IsA("BasePart") and p.Transparency < 1 then
				local cf = pivot:ToObjectSpace(p.CFrame)
				local d = p.Size / 2
				for _, sx in ipairs({ -1, 1 }) do
					for _, sy in ipairs({ -1, 1 }) do
						for _, sz in ipairs({ -1, 1 }) do
							local c = cf * Vector3.new(sx * d.X, sy * d.Y, sz * d.Z)
							if mn then
								mn = Vector3.new(math.min(mn.X, c.X), math.min(mn.Y, c.Y), math.min(mn.Z, c.Z))
								mx = Vector3.new(math.max(mx.X, c.X), math.max(mx.Y, c.Y), math.max(mx.Z, c.Z))
							else
								mn, mx = c, c
							end
						end
					end
				end
			end
		end
		return mn or Vector3.new(-1, 0, -1), mx or Vector3.new(1, 1, 1)
	end

	-- facteur de réduction pour qu'un dino tienne dans la largeur du tapis
	local function facteurLargeur(mn, mx)
		local largeurMax = Plan.tapis.largeur - 2 * MARGE_TAPIS
		local largeur = mx.X - mn.X
		if largeur > largeurMax then
			return largeurMax / largeur
		end
		return 1
	end

	-- encombrement sur le tapis (dino tourné vers +X) : avant, arrière, décalage latéral à corriger ; mis en cache par espèce
	local encombrements = {}
	local function encombrement(espece, modele)
		local e = encombrements[espece]
		if e then return e end
		local source = modele or (ctx.stockage:FindFirstChild("Dinos") and ctx.stockage.Dinos:FindFirstChild(espece))
		if not source then
			return { avant = 6, arriere = 6, decal = 0, echelle = 1 }
		end
		local mn, mx = boiteLocale(source)
		local echelle = modele and 1 or facteurLargeur(mn, mx)
		local rot = CFrame.Angles(0, ANGLE_REGARD, 0)
		local wmn, wmx
		for _, sx in ipairs({ mn.X, mx.X }) do
			for _, sz in ipairs({ mn.Z, mx.Z }) do
				local w = rot * Vector3.new(sx * echelle, 0, sz * echelle)
				if wmn then
					wmn = Vector3.new(math.min(wmn.X, w.X), 0, math.min(wmn.Z, w.Z))
					wmx = Vector3.new(math.max(wmx.X, w.X), 0, math.max(wmx.Z, w.Z))
				else
					wmn, wmx = w, w
				end
			end
		end
		e = { avant = wmx.X, arriere = -wmn.X, decal = -(wmn.Z + wmx.Z) / 2, echelle = echelle }
		if not modele then encombrements[espece] = e end
		return e
	end

	local function cadreTapis(x, t, phase, decal, vol)
		local oscillation = math.sin(t * DANDINEMENT_FREQUENCE + phase)
		local y = Plan.tapis.hauteur + math.abs(oscillation) * DANDINEMENT_HAUTEUR
		if vol then
			-- en vol : plane au-dessus du Tapis, à hauteur des dinos, et monte et descend doucement
			y = Plan.tapis.hauteur + vol + math.sin(t * 1.6 + phase) * 0.8
			oscillation = oscillation * 0.3
		end
		return CFrame.new(x, y, Plan.tapis.debut.Z + (decal or 0))
			* CFrame.Angles(0, ANGLE_REGARD, 0)
			* CFrame.Angles(0, 0, oscillation * DANDINEMENT_ANGLE)
	end

	-- ===== membres animés (repère du pivot : sol sous le dino, regard vers -Z) =====

	local function commencePar(nom, prefixe)
		return string.sub(nom, 1, #prefixe) == prefixe
	end

	local function coteDe(nom)
		local c = string.sub(nom, -1)
		if c == "G" or c == "D" then
			return c
		end
		return nil
	end

	-- deux bouts d'une part allongée le long de son plus grand axe (le centre deux fois sinon)
	local function extremites(repos, taille)
		local axes = {
			{ repos.RightVector, taille.X },
			{ repos.UpVector, taille.Y },
			{ -repos.LookVector, taille.Z },
		}
		table.sort(axes, function(a, b) return a[2] > b[2] end)
		if axes[1][2] > axes[2][2] * 1.3 then
			local demi = axes[1][1] * (axes[1][2] / 2)
			return repos.Position + demi, repos.Position - demi
		end
		return repos.Position, repos.Position
	end

	local function distanceSegment(p, a, b)
		local ab = b - a
		local l2 = ab:Dot(ab)
		if l2 < 0.000001 then
			return (p - a).Magnitude
		end
		local u = math.max(0, math.min(1, (p - a):Dot(ab) / l2))
		return (p - (a + ab * u)).Magnitude
	end

	local function nouveauGroupe(genre, point, decal, cote)
		return {
			genre = genre,
			avant = CFrame.new(point),
			apres = CFrame.new(-point),
			decal = decal or 0,
			cote = cote,
			membres = {},
		}
	end

	-- repère les pattes (+ pieds, mains, griffes), la queue et les ailes ; mémorise leur pose de repos
	local function analyserMembres(dino)
		-- dino voxel assemblé (soudures + articulations) : les membres sont animés côté client (Interface/AnimationsDinos)
		if dino:GetAttribute("Assemble") then return {} end
		local pivot = dino:GetPivot()
		local parts = partsDe(dino)
		local groupes = {}
		local pattes = {}
		local queue = {}
		local ailes = { G = {}, D = {} }
		for _, p in ipairs(parts) do
			local nom = p.Name
			local repos = pivot:ToObjectSpace(p.CFrame)
			local infoPatte = PATTES[nom]
			if infoPatte and pattes[nom] then
				-- patte voxel en plusieurs parts : toutes suivent le même groupe
				table.insert(pattes[nom].membres, { part = p, repos = repos })
			elseif infoPatte then
				local a, b = extremites(repos, p.Size)
				local haut, bas = a, b
				if b.Y > a.Y then
					haut, bas = b, a
				end
				local g = nouveauGroupe("patte", haut, infoPatte.decal, infoPatte.cote)
				g.haut = haut
				g.bas = bas
				g.portee = math.max(p.Size.X, p.Size.Y, p.Size.Z) * 0.8 + 0.8
				table.insert(g.membres, { part = p, repos = repos })
				pattes[nom] = g
				table.insert(groupes, g)
			elseif string.find(nom, "Queue", 1, true) or commencePar(nom, "Massue") then
				table.insert(queue, { part = p, repos = repos })
			elseif commencePar(nom, "Aile") and coteDe(nom) then
				table.insert(ailes[coteDe(nom)], { part = p, repos = repos })
			end
		end

		-- accessoires : rattachés à la patte du même côté dont le segment est le plus proche
		-- patte en plusieurs parts : l'articulation est en haut de l'ensemble (hanche), au centre
		for _, g in pairs(pattes) do
			if #g.membres > 1 then
				local hautY, basY, sx, sz = -math.huge, math.huge, 0, 0
				for _, m in ipairs(g.membres) do
					local a, b = extremites(m.repos, m.part.Size)
					hautY = math.max(hautY, a.Y, b.Y)
					basY = math.min(basY, a.Y, b.Y)
					sx = sx + m.repos.Position.X
					sz = sz + m.repos.Position.Z
				end
				local n = #g.membres
				g.haut = Vector3.new(sx / n, hautY, sz / n)
				g.bas = Vector3.new(sx / n, basY, sz / n)
				g.avant = CFrame.new(g.haut)
				g.apres = CFrame.new(-g.haut)
				g.portee = (hautY - basY) * 0.8 + 0.8
			end
		end

		for _, p in ipairs(parts) do
			local cote = coteDe(p.Name)
			if cote and not PATTES[p.Name] then
				local accessoire = false
				for _, prefixe in ipairs(ACCESSOIRES) do
					if commencePar(p.Name, prefixe) then
						accessoire = true
						break
					end
				end
				if accessoire then
					local repos = pivot:ToObjectSpace(p.CFrame)
					local meilleur, meilleureDistance = nil, math.huge
					for _, g in pairs(pattes) do
						if g.cote == cote then
							local d = distanceSegment(repos.Position, g.haut, g.bas)
							if d <= g.portee and d < meilleureDistance then
								meilleur, meilleureDistance = g, d
							end
						end
					end
					if meilleur then
						table.insert(meilleur.membres, { part = p, repos = repos })
					end
				end
			end
		end

		-- queue : pivote autour de sa racine (le bout du premier segment le plus proche du corps)
		if #queue > 0 then
			local racine = queue[1]
			for _, m in ipairs(queue) do
				if m.repos.Position.Z < racine.repos.Position.Z then
					racine = m
				end
			end
			local a, b = extremites(racine.repos, racine.part.Size)
			local point = a
			if b.Z < a.Z then
				point = b
			end
			local g = nouveauGroupe("queue", point)
			g.membres = queue
			table.insert(groupes, g)
		end

		-- ailes : battent autour de leur attache (le bout le plus proche de l'axe du corps)
		for _, cote in ipairs({ "G", "D" }) do
			local liste = ailes[cote]
			if #liste > 0 then
				local racine = liste[1]
				for _, m in ipairs(liste) do
					if m.part.Name == "Aile" .. cote then
						racine = m
						break
					end
				end
				local a, b = extremites(racine.repos, racine.part.Size)
				local point = a
				if math.abs(b.X) < math.abs(a.X) then
					point = b
				end
				local g = nouveauGroupe("aile", point, 0, cote)
				g.membres = liste
				table.insert(groupes, g)
			end
		end

		if #groupes == 0 then
			return nil
		end
		return groupes
	end

	-- pose les membres autour du pivot cf à l'instant t
	local function animerMembres(cf, fiche, t)
		local base = t * DANDINEMENT_FREQUENCE + fiche.phase
		for _, g in ipairs(fiche.groupes) do
			local rotation
			if g.genre == "patte" then
				rotation = CFrame.Angles(math.sin(base + g.decal) * MARCHE_ANGLE, 0, 0)
			elseif g.genre == "queue" then
				rotation = CFrame.Angles(0, math.sin(base - QUEUE_RETARD) * QUEUE_ANGLE, 0)
			else
				local battement = math.sin(base * AILE_RYTHME) * AILE_ANGLE
				if g.cote == "G" then
					battement = -battement
				end
				rotation = CFrame.Angles(0, 0, battement)
			end
			local m = cf * g.avant * rotation * g.apres
			for _, membre in ipairs(g.membres) do
				membre.part.CFrame = m * membre.repos
			end
		end
	end

	-- remet les membres au repos (le dino quitte le Tapis : achat, vol, autre système)
	local function reposerMembres(dino, fiche)
		if not fiche.groupes then
			return
		end
		local cf = dino:GetPivot()
		for _, g in ipairs(fiche.groupes) do
			for _, membre in ipairs(g.membres) do
				if membre.part.Parent then
					membre.part.CFrame = cf * membre.repos
				end
			end
		end
	end

	-- un joueur est-il assez près de ce point du Tapis pour voir les membres bouger ?
	local function joueurProche(x)
		local z = Plan.tapis.debut.Z
		local limite = DISTANCE_ANIMATION * DISTANCE_ANIMATION
		for _, p in ipairs(positionsJoueurs) do
			local dx, dz = p.X - x, p.Z - z
			if dx * dx + dz * dz <= limite then
				return true
			end
		end
		return false
	end

	local function releverJoueurs()
		local liste = {}
		for _, joueur in ipairs(Players:GetPlayers()) do
			local perso = joueur.Character
			local racine = perso and (perso.PrimaryPart or perso:FindFirstChild("HumanoidRootPart"))
			if racine and racine:IsA("BasePart") then
				table.insert(liste, racine.Position)
			end
		end
		positionsJoueurs = liste
	end

	local function suivre(dino, x)
		if surTapis[dino] then
			return
		end
		local espece = dino:GetAttribute("Espece")
		local okE, e = pcall(encombrement, espece or "?", nil)
		if not okE or not e or not espece then
			local okM, em = pcall(encombrement, "?", dino)
			e = okM and em or { avant = 6, arriere = 6, decal = 0 }
		end
		local infosVol = espece and E.especes[espece]
		local fiche = { x = x, phase = alea:NextNumber() * math.pi * 2, avant = e.avant, arriere = e.arriere, decal = e.decal, vol = infosVol and infosVol.vol }
		local ok, groupes = pcall(analyserMembres, dino)
		if ok then
			fiche.groupes = groupes
		end
		fiche.anime = joueurProche(x)
		surTapis[dino] = fiche
		nombreSurTapis = nombreSurTapis + 1
	end

	local function oublier(dino, sansRepos)
		local fiche = surTapis[dino]
		if fiche then
			surTapis[dino] = nil
			nombreSurTapis = nombreSurTapis - 1
			if not sansRepos and dino.Parent then
				pcall(reposerMembres, dino, fiche)
			end
		end
	end

	-- ===== apparition d'un dino =====
	local dernierSorti = nil
	local function apparaitre()
		if nombreSurTapis >= E.tapis.maxDinos then
			return
		end
		local nomEvenement, evenement = evenementCourant()
		local rarete = tirerRarete(evenement)
		local liste = especesParRarete[rarete]
		if not liste or #liste == 0 then
			return
		end
		local espece = liste[alea:NextInteger(1, #liste)]
		local mutation = tirerMutation(nomEvenement, evenement)
		-- de temps en temps, un Œuf mystère ailé à la place
		if E.oeuf and E.especes.OeufMystere and alea:NextNumber() < (E.oeuf.chance or 0) then
			espece = "OeufMystere"
			mutation = "Normal"
		end

		-- attend qu'il y ait assez de place derrière le dernier dino (on voit le tapis entre eux)
		local e = encombrement(espece, nil)
		local attente = 0
		while attente < 60 do
			local fiche = dernierSorti and surTapis[dernierSorti]
			if not fiche then break end
			local arriereDernier = fiche.x - (fiche.arriere or 6)
			if arriereDernier - (Plan.tapis.debut.X + e.avant) >= ECART_TAPIS then break end
			task.wait(0.2)
			attente = attente + 0.2
		end

		local dino = creerDino(espece, mutation)
		if not dino then
			return
		end
		mutation = dino:GetAttribute("Mutation")
		local prix = dino:GetAttribute("Prix")
		local depart = Plan.tapis.debut
		suivre(dino, depart.X)
		local fiche = surTapis[dino]
		dino:PivotTo(cadreTapis(depart.X, 0, 0, fiche and fiche.decal or 0, fiche and fiche.vol))
		dernierSorti = dino

		local corps = dino:FindFirstChild("Corps") or dino.PrimaryPart
		if corps then
			Outils.invite(corps, {
				nom = "Acheter",
				action = "Acheter",
				objet = nomAffiche(espece, mutation) .. " — " .. Charte.argent(prix),
				duree = 0.25,
				distance = 12,
			})
		end

		Bus.emettre("DinoApparu", dino)

		local infosRarete = E.raretes[rarete]
		if (infosRarete and infosRarete.ordre >= E.raretes.Legendaire.ordre) or mutation ~= "Normal" then
			local position = dino:GetPivot().Position
			pcall(function()
				ctx.Reseau.Effet:FireAllClients("Apparition", position, {
					rarete = rarete,
					mutation = mutation,
					espece = espece,
				})
			end)
		end
	end

	task.spawn(function()
		while true do
			task.wait(E.tapis.intervalle)
			local ok, err = pcall(apparaitre)
			if not ok then
				warn("[Dino] Tapis, apparition : " .. tostring(err))
			end
		end
	end)

	-- adopte les dinos mis à l'Etat « Tapis » par un autre système, s'ils sont bien sur le tapis
	local function adopter()
		local debut, fin = Plan.tapis.debut, Plan.tapis.fin
		for _, dino in ipairs(ctx.dinos:GetChildren()) do
			if not surTapis[dino] and dino:IsA("Model") and dino:GetAttribute("Etat") == "Tapis" then
				local ok, pivot = pcall(function()
					return dino:GetPivot()
				end)
				if ok and pivot then
					local p = pivot.Position
					if p.X >= debut.X - 1 and p.X <= fin.X and math.abs(p.Z - debut.Z) <= Plan.tapis.largeur / 2 then
						suivre(dino, p.X)
					end
				end
			end
		end
	end

	-- ===== UNE boucle Heartbeat : avance, dandinement, fin du tapis =====
	local tempsAdoption = 0
	local dernierCompte = -1
	RunService.Heartbeat:Connect(function(dt)
		local t = os.clock()
		tempsAdoption = tempsAdoption + dt
		if tempsAdoption >= INTERVALLE_ADOPTION then
			tempsAdoption = 0
			pcall(adopter)
			if pcall(releverJoueurs) then
				for _, fiche in pairs(surTapis) do
					fiche.anime = joueurProche(fiche.x)
				end
			end
		end

		local aDetruire = {}
		local aOublier = {}
		for dino, fiche in pairs(surTapis) do
			if dino.Parent == nil or dino:GetAttribute("Etat") ~= "Tapis" then
				table.insert(aOublier, dino)
			else
				fiche.x = fiche.x + E.tapis.vitesse * dt
				if fiche.x > Plan.tapis.fin.X then
					table.insert(aDetruire, dino)
				else
					local ok = pcall(function()
						local cf = cadreTapis(fiche.x, t, fiche.phase, fiche.decal, fiche.vol)
						dino:PivotTo(cf)
						if fiche.anime and fiche.groupes then
							animerMembres(cf, fiche, t)
						end
					end)
					if not ok then
						table.insert(aOublier, dino)
					end
				end
			end
		end
		for _, dino in ipairs(aOublier) do
			oublier(dino)
		end
		for _, dino in ipairs(aDetruire) do
			oublier(dino, true)
			pcall(function()
				dino:Destroy()
			end)
		end

		if nombreSurTapis ~= dernierCompte then
			dernierCompte = nombreSurTapis
			Etat:SetAttribute("DinosSurTapis", nombreSurTapis)
		end
	end)
end

return M
