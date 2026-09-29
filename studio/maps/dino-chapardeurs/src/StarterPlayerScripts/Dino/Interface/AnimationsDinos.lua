-- Interface/AnimationsDinos : anime localement les dinos voxel assemblés (attribut « Assemble »),
-- et fait vivre les dinos posés dans les Bases (rebond, balancement, lumières selon la rareté)
-- en jouant sur Motor6D.Transform : pattes qui marchent, queue qui se balance, ailes qui battent.
-- Sur le Tapis et en route : pas levés (chaque patte se soulève pendant qu'elle revient vers l'avant),
-- uniquement par Motor6D.Transform : la PrimaryPart que le serveur déplace (PivotTo) n'est JAMAIS écrite ici.
-- Dans la Base : tête qui se balance (articulation de cou locale, créée seulement pour les dinos posés),
-- saut de joie à l'arrivée ; puis, de temps en temps, une petite action au hasard
-- (regarder à gauche et à droite, sautiller, tourner sur soi).
-- Rien n'est répliqué : tout ce qui est fait ici reste local et ne touche que les dinos à moins de
-- DISTANCE_MAX de la caméra.
local RunService = game:GetService("RunService")

local M = {}

local DISTANCE_MAX = 150
local ETATS_MARCHE = { Tapis = true, EnRoute = true }
local PHASES = { PatteAvG = 0, PatteArD = 0, PatteAvD = math.pi, PatteArG = math.pi }
local DEUX_PI = math.pi * 2
local PAS = 8                 -- pulsation des pattes en marche (rad/s)
local DUREE_JOIE = 1.2        -- saut de joie à l'arrivée dans la Base (s)
local ACTION_MIN, ACTION_MAX = 6, 15 -- intervalle entre deux petites actions d'un dino posé (s)
local DUREES = { regard = 2.4, sautille = 1.3, tourne = 0.8 }
local ACTIONS = { "regard", "sautille", "tourne" }

local function lisse(k)
	if k <= 0 then return 0 end
	if k >= 1 then return 1 end
	return k * k * (3 - 2 * k)
end

local function borne(v, a, b)
	if v < a then return a end
	if v > b then return b end
	return v
end

-- la CFrame a-t-elle été changée par quelqu'un d'autre (le serveur) depuis notre dernière écriture ?
local function differente(a, b)
	return (a.Position - b.Position).Magnitude > 1e-3
		or (a.LookVector - b.LookVector).Magnitude > 1e-4
		or (a.UpVector - b.UpVector).Magnitude > 1e-4
end

local function echelleDe(dino)
	local ok, e = pcall(function() return dino:GetScale() end)
	if ok and type(e) == "number" and e > 0 then return e end
	return 1
end

function M.demarrer(ctx)
	local dinos = ctx.dinos
	if not dinos then return end
	local Charte = ctx.Charte
	local E = ctx.Equilibrage
	local alea = Random.new()

	local function couleurRarete(rarete)
		if Charte and Charte.raretes and Charte.raretes[rarete] then return Charte.raretes[rarete] end
		return Color3.fromRGB(255, 255, 255)
	end
	local function eclaircir(c)
		if Charte and Charte.lumiere then return Charte.lumiere(c) end
		return c:Lerp(Color3.fromRGB(255, 244, 220), 0.2)
	end
	local VIOLET = (Charte and Charte.violet) or Color3.fromRGB(155, 93, 229)
	local BLANC = Color3.fromRGB(255, 255, 255)

	local function estOeuf(dino)
		local infos = E and E.especes and E.especes[dino:GetAttribute("Espece")]
		return infos ~= nil and infos.special == true
	end

	-- ===== articulations : pattes, queue, ailes (Motor6D du Voxel) =====
	-- dino -> { moteurs = { {moteur, genre, phase, cote, avant} }, decalage, volant, amp, echelle }
	local suivis = {}
	local compteur = 0

	-- ===== cou local (dinos posés dans les Bases SEULEMENT) =====
	-- la tête voxel est soudée (WeldConstraint) au corps : pour un dino posé (que le serveur ne déplace pas),
	-- on remplace localement la soudure par un Motor6D pour pouvoir la faire balancer. Jamais sur le Tapis,
	-- en route ou porté : dès que le dino quitte la Base, le cou est désactivé et la soudure rendue.
	local function creerCou(dino, corps)
		local tete, soudure
		for _, p in ipairs(dino:GetChildren()) do
			if p:IsA("BasePart") and p.Name == "Tete" and p ~= corps then
				for _, w in ipairs(p:GetChildren()) do
					if w:IsA("WeldConstraint") and w.Enabled and w.Part1 == p and w.Part0 and w.Part0.Name ~= "Tete" then
						tete, soudure = p, w
						break
					end
				end
			end
			if tete then break end
		end
		if not tete then return nil end
		local ok, cou = pcall(function()
			local support = soudure.Part0
			-- point d'articulation : entre la tête et le corps (la base du cou), orienté comme le corps
			local point = tete.Position:Lerp(corps.Position, 0.3)
			local articulation = CFrame.new(point) * corps.CFrame.Rotation
			local c0 = support.CFrame:ToObjectSpace(articulation)
			local c1 = tete.CFrame:ToObjectSpace(articulation)
			local m = Instance.new("Motor6D")
			m.Name = "CouLocal"
			m.C0 = c0
			m.C1 = c1
			m.Part0 = support
			m.Part1 = tete
			soudure.Enabled = false
			m.Parent = tete
			return { moteur = m, soudure = soudure, echelle = echelleDe(dino) }
		end)
		if ok then return cou end
		return nil
	end

	-- désactive le cou local et rend la soudure du serveur. La tête est d'abord remise au repos
	-- (Transform neutre) ; la soudure n'est réactivée qu'une fois la tête revenue, pour qu'elle
	-- se referme sur la pose de repos et pas sur une tête tournée.
	local function rendreCou(cou)
		if not cou or cou.rendu then return end
		cou.rendu = true
		local m, soudure = cou.moteur, cou.soudure
		pcall(function() m.Transform = CFrame.new() end)
		task.delay(0.05, function()
			pcall(function() m.Enabled = false end)
			pcall(function()
				if soudure.Parent then soudure.Enabled = true end
			end)
			pcall(function() m:Destroy() end)
		end)
	end

	local function inscrire(dino)
		if suivis[dino] or not dino:IsA("Model") or dino:GetAttribute("Assemble") ~= true then return end
		local corps = dino.PrimaryPart
		if not corps then return end
		local moteurs = {}
		local volant = false
		for _, o in ipairs(dino:GetDescendants()) do
			if o:IsA("Motor6D") and o.Name ~= "CouLocal" then
				local nom = o.Name
				local genre
				if string.sub(nom, 1, 5) == "Patte" then genre = "patte"
				elseif string.sub(nom, 1, 5) == "Queue" then genre = "queue"
				elseif string.sub(nom, 1, 4) == "Aile" then genre = "aile" end
				if genre then
					local cote = 1
					if string.sub(nom, -1) == "D" then cote = -1 end
					if genre == "aile" then volant = true end
					table.insert(moteurs, {
						moteur = o, genre = genre, phase = PHASES[nom] or 0, cote = cote,
						avant = string.sub(nom, 6, 7) == "Av",
					})
				end
			end
		end
		if #moteurs > 0 then
			compteur = compteur + 1
			local hauteur = 8
			local okB, _, taille = pcall(function() return dino:GetBoundingBox() end)
			if okB and taille then hauteur = taille.Y end
			suivis[dino] = {
				moteurs = moteurs,
				decalage = (compteur * 1.7) % DEUX_PI,
				volant = volant or estOeuf(dino),
				-- hauteur du pas levé (studs), pour l'échelle du modèle au moment de l'inscription
				amp = borne(hauteur * 0.035, 0.1, 0.45),
				echelle = echelleDe(dino),
			}
		end
	end

	local function retirer(dino)
		suivis[dino] = nil
	end

	-- ===== dans la Base : rebond, balancement, saut de joie, petites actions, lumières selon la rareté =====
	-- (local : le serveur ne bouge pas les dinos posés, on repart toujours de leur pose au moment où ils sont posés)
	local RARETES = {
		Commun = { rebond = 0.25, vitesse = 2.0, balance = 3 },
		Rare = { rebond = 0.3, vitesse = 2.2, balance = 4, lumiere = true, portee = 9, eclat = 0.9, respire = 0.9 },
		Epique = { rebond = 0.35, vitesse = 2.4, balance = 4.5, lumiere = true, portee = 11, eclat = 1.1, respire = 1.1, etincelles = 4 },
		Legendaire = { rebond = 0.4, vitesse = 2.6, balance = 5, lumiere = true, portee = 13, eclat = 1.4, respire = 1.5, etincelles = 6, anneau = 0.62, montee = 3 },
		Mythique = { rebond = 0.45, vitesse = 2.8, balance = 5.5, lumiere = true, portee = 15, eclat = 1.7, respire = 2, etincelles = 8, anneau = 0.52, montee = 5, onde = true },
		Divin = { rebond = 0.5, vitesse = 3.0, balance = 6, lumiere = true, portee = 17, eclat = 2, respire = 2.5, etincelles = 10, anneau = 0.48, montee = 6, onde = true, arcEnCiel = true },
		Secret = { rebond = 0.55, vitesse = 3.2, balance = 6.5, lumiere = true, portee = 19, eclat = 2.2, respire = 3, etincelles = 12, anneau = 0.48, montee = 7, onde = true, bicolore = true },
	}
	local exposes = {} -- dino -> fiche (voir exposer)
	local joies = {}   -- dino -> heure de l'arrivée dans la Base (le saut de joie attend la pose)

	local function retirerEffets(fiche)
		for _, e in ipairs(fiche.effets) do pcall(function() e:Destroy() end) end
		fiche.effets = {}
		fiche.lumiere = nil
		fiche.anneau = nil
		fiche.onde = nil
		fiche.emetteurs = {}
	end

	local function arreterExposition(dino)
		local fiche = exposes[dino]
		if not fiche then return end
		exposes[dino] = nil
		retirerEffets(fiche)
		rendreCou(fiche.cou)
		fiche.cou = nil
		-- le dino n'est plus posé : si personne ne l'a bougé depuis notre dernière image, on lui rend
		-- exactement la pose du serveur (sinon c'est le serveur qui l'a déjà repositionné : on n'y touche pas)
		local corps = dino.PrimaryPart
		if corps and fiche.applique and not differente(corps.CFrame, fiche.applique) then
			corps.CFrame = fiche.base
		end
		fiche.applique = nil
	end

	local function sequenceArcEnCiel()
		local points = {}
		for i = 0, 5 do
			table.insert(points, ColorSequenceKeypoint.new(i / 5, Color3.fromHSV(i / 6, 0.55, 1)))
		end
		return ColorSequence.new(points)
	end

	local function nouvelEmetteur(parent, props)
		local p = Instance.new("ParticleEmitter")
		p.LightEmission = 1
		p.LightInfluence = 0
		p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		for k, v in pairs(props) do p[k] = v end
		p.Parent = parent
		return p
	end

	local function disque(nom, couleur, d, transparence, position)
		local anneau = Instance.new("Part")
		anneau.Name = nom
		anneau.Shape = Enum.PartType.Cylinder
		anneau.Anchored = true
		anneau.CanCollide = false
		anneau.CanQuery = false
		anneau.CanTouch = false
		anneau.CastShadow = false
		anneau.Material = Enum.Material.Neon
		anneau.Color = couleur
		anneau.Transparency = transparence
		anneau.Size = Vector3.new(0.12, d, d)
		anneau.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
		anneau.Parent = workspace.CurrentCamera
		return anneau
	end

	local function exposer(dino)
		if exposes[dino] or not dino.PrimaryPart then return end
		local rarete = dino:GetAttribute("Rarete")
		local profil = RARETES[rarete] or RARETES.Commun
		local corps = dino.PrimaryPart
		local t = os.clock()
		compteur = compteur + 1

		-- repère au sol, sous le centre du dino : les sauts et les tours se font autour de lui
		local pivot = corps.CFrame
		pcall(function() pivot = dino:GetPivot() end)
		local centreBoite, taille = corps.Position, corps.Size
		local okB, cfB, tB = pcall(function() return dino:GetBoundingBox() end)
		if okB and cfB and tB then
			centreBoite, taille = cfB.Position, tB
		end
		local sol = Vector3.new(centreBoite.X, centreBoite.Y - taille.Y / 2, centreBoite.Z)
		local centre = CFrame.new(sol) * pivot.Rotation

		local couleur = couleurRarete(rarete)
		local fiche = {
			base = corps.CFrame, centre = centre, decal = centre:ToObjectSpace(corps.CFrame),
			profil = profil, effets = {}, emetteurs = {}, phase = (compteur * 2.3) % DEUX_PI,
			echelle = borne(taille.Y / 10, 0.5, 1.6), taille = taille, couleur = couleur,
			oeuf = estOeuf(dino), regard = 0, saut = 0, proche = true,
			prochaine = t + alea:NextNumber(ACTION_MIN, ACTION_MAX),
		}
		local arrivee = joies[dino]
		joies[dino] = nil
		if arrivee and t - arrivee < 3 then fiche.joie = t end

		-- lumière douce posée au-dessus du dino (éclaire son dos et le podium)
		if profil.lumiere then
			local a = Instance.new("Attachment")
			a.Name = "LumiereRarete"
			a.Position = corps.CFrame:PointToObjectSpace(sol + Vector3.new(0, taille.Y * 0.8 + 1, 0))
			a.Parent = corps
			local l = Instance.new("PointLight")
			l.Color = couleur
			l.Range = profil.portee
			l.Brightness = profil.eclat
			l.Shadows = false
			l.Parent = a
			fiche.lumiere = l
			table.insert(fiche.effets, a)
		end
		-- aura d'étincelles autour du corps
		if profil.etincelles then
			local a = Instance.new("Attachment")
			a.Name = "AuraRarete"
			a.Position = corps.CFrame:PointToObjectSpace(centreBoite)
			a.Parent = corps
			local seq = ColorSequence.new(eclaircir(couleur), couleur)
			if profil.arcEnCiel then seq = sequenceArcEnCiel() end
			if profil.bicolore then seq = ColorSequence.new(BLANC, VIOLET) end
			local rayon = math.min(math.max(taille.X, taille.Z), 10)
			local p = nouvelEmetteur(a, {
				Color = seq,
				Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.25, 0.45),
					NumberSequenceKeypoint.new(1, 0),
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Lifetime = NumberRange.new(1.2, 2),
				Speed = NumberRange.new(rayon * 0.15, rayon * 0.3),
				Drag = 1.5,
				RotSpeed = NumberRange.new(-90, 90),
				SpreadAngle = Vector2.new(180, 180),
				Rate = profil.etincelles,
			})
			fiche.etincelles = p
			table.insert(fiche.emetteurs, p)
			table.insert(fiche.effets, a)
		end
		-- anneau lumineux au sol, poussières de lumière qui montent, onde qui s'élargit
		if profil.anneau then
			local d = math.min(math.max(taille.X, taille.Z) * 0.8, 7.5)
			fiche.diametre = d
			local anneau = disque("AnneauRarete", couleur, d, profil.anneau, sol + Vector3.new(0, 0.08, 0))
			fiche.anneau = anneau
			table.insert(fiche.effets, anneau)
			if profil.montee then
				local socle = Instance.new("Part")
				socle.Name = "SocleLueur"
				socle.Anchored = true
				socle.CanCollide = false
				socle.CanQuery = false
				socle.CanTouch = false
				socle.CastShadow = false
				socle.Transparency = 1
				socle.Size = Vector3.new(d * 0.8, 0.2, d * 0.8)
				socle.CFrame = CFrame.new(sol + Vector3.new(0, 0.2, 0))
				socle.Parent = workspace.CurrentCamera
				local seq = ColorSequence.new(eclaircir(couleur), couleur)
				if profil.arcEnCiel then seq = sequenceArcEnCiel() end
				if profil.bicolore then seq = ColorSequence.new(BLANC, VIOLET) end
				local p = nouvelEmetteur(socle, {
					Color = seq,
					Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.25),
						NumberSequenceKeypoint.new(1, 0),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.3),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Lifetime = NumberRange.new(1.4, 2.2),
					Speed = NumberRange.new(2, 3.5),
					Drag = 0.8,
					SpreadAngle = Vector2.new(8, 8),
					Rate = profil.montee,
				})
				table.insert(fiche.emetteurs, p)
				table.insert(fiche.effets, socle)
			end
			if profil.onde then
				local onde = disque("OndeRarete", couleur, d, 1, sol + Vector3.new(0, 0.1, 0))
				fiche.onde = onde
				table.insert(fiche.effets, onde)
			end
		end
		-- le cou local n'existe que pour les dinos posés (créé à partir des CFrames du moment)
		fiche.cou = creerCou(dino, corps)
		exposes[dino] = fiche
		if fiche.joie and fiche.etincelles then
			pcall(function() fiche.etincelles:Emit(14) end)
		end
	end

	local function suivreEtat(dino)
		if not dino:IsA("Model") then return end
		local ancien = dino:GetAttribute("Etat")
		local function maj()
			arreterExposition(dino)
			if dino:GetAttribute("Etat") == "Enclos" then
				-- laisse le serveur finir de poser le dino avant de mémoriser sa pose
				task.delay(0.3, function()
					if dino.Parent and dino:GetAttribute("Etat") == "Enclos" then exposer(dino) end
				end)
			end
		end
		dino:GetAttributeChangedSignal("Etat"):Connect(function()
			local nouveau = dino:GetAttribute("Etat")
			-- arrivée dans une Base (achat livré, vol réussi ou dino rendu) : saut de joie
			if nouveau == "Enclos" and ancien ~= nil and ancien ~= "Enclos" then
				joies[dino] = os.clock()
			end
			ancien = nouveau
			maj()
		end)
		dino:GetAttributeChangedSignal("Emplacement"):Connect(maj)
		maj()
	end

	for _, d in ipairs(dinos:GetChildren()) do suivreEtat(d) end
	dinos.ChildAdded:Connect(suivreEtat)
	dinos.ChildRemoved:Connect(function(d)
		arreterExposition(d)
		joies[d] = nil
	end)

	-- choisit et joue les petites actions d'un dino posé ; renvoie hauteur et lacet en plus du rebond
	local function actionEnCours(fiche, t)
		local haut, lacet = 0, 0
		fiche.regard = 0
		fiche.saut = 0
		-- saut de joie : un grand bond avec un tour complet, puis un petit rebond
		if fiche.joie then
			local k = (t - fiche.joie) / DUREE_JOIE
			if k >= 1 then
				fiche.joie = nil
			elseif k < 0.65 then
				local q = k / 0.65
				local s = math.sin(math.pi * q)
				haut = s * 2.4 * fiche.echelle
				if not fiche.oeuf then lacet = lisse(q) * DEUX_PI end
				fiche.saut = s
			else
				local q = (k - 0.65) / 0.35
				local s = math.sin(math.pi * q)
				haut = s * 0.7 * fiche.echelle
				fiche.saut = s * 0.5
			end
			return haut, lacet
		end
		local action = fiche.action
		if not action then
			if t >= fiche.prochaine then
				local genre = ACTIONS[alea:NextInteger(1, #ACTIONS)]
				if fiche.oeuf then genre = "sautille" end
				local sens = 1
				if alea:NextNumber() < 0.5 then sens = -1 end
				fiche.action = { genre = genre, debut = t, duree = DUREES[genre], sens = sens }
			end
			return 0, 0
		end
		local k = (t - action.debut) / action.duree
		if k >= 1 then
			fiche.action = nil
			fiche.prochaine = t + alea:NextNumber(ACTION_MIN, ACTION_MAX)
			return 0, 0
		end
		if action.genre == "regard" then
			-- tourne la tête d'un côté, puis de l'autre, puis revient
			fiche.regard = math.sin(DEUX_PI * k) * 0.6 * action.sens
			lacet = fiche.regard * 0.25
		elseif action.genre == "sautille" then
			local s = math.abs(math.sin(3 * math.pi * k))
			haut = s * 0.9 * fiche.echelle
			fiche.saut = s * 0.7
		else
			lacet = lisse(k) * DEUX_PI * action.sens
			haut = math.sin(math.pi * k) * 0.35 * fiche.echelle
		end
		return haut, lacet
	end

	-- renvoie false si le serveur a déplacé le dino entre-temps (on n'anime alors plus rien par-dessus)
	local function animerExpose(dino, fiche, t)
		local corps = dino.PrimaryPart
		if fiche.applique and differente(corps.CFrame, fiche.applique) then return false end
		local p = fiche.profil
		local u = t * p.vitesse + fiche.phase
		local plus, lacet = actionEnCours(fiche, t)
		local haut = math.abs(math.sin(u)) * p.rebond + plus
		local roulis = math.sin(u * 0.5) * math.rad(p.balance)
		if fiche.saut > 0 then roulis = roulis * 0.3 end
		-- (dino posé : le serveur ne déplace pas sa PrimaryPart tant qu'il est dans la Base)
		corps.CFrame = fiche.centre * CFrame.new(0, haut, 0) * CFrame.Angles(0, lacet, roulis) * fiche.decal
		fiche.applique = corps.CFrame

		-- lumières : respiration douce, sursaut pendant la joie, couleurs animées pour Divin et Secret
		local respire = 0.5 + 0.5 * math.sin(t * (p.respire or 1) + fiche.phase)
		local couleur
		if p.arcEnCiel then
			couleur = Color3.fromHSV((t * 0.12 + fiche.phase / DEUX_PI) % 1, 0.55, 1)
		elseif p.bicolore then
			couleur = BLANC:Lerp(VIOLET, 0.5 + 0.5 * math.sin(t * 1.7 + fiche.phase))
		end
		if fiche.lumiere then
			local joie = 0
			if fiche.joie then joie = fiche.saut * 0.8 end
			fiche.lumiere.Brightness = p.eclat * (0.7 + 0.45 * respire + joie)
			fiche.lumiere.Range = p.portee * (0.9 + 0.12 * respire)
			if couleur then fiche.lumiere.Color = couleur end
		end
		if fiche.anneau then
			fiche.anneau.Transparency = p.anneau + 0.18 * (1 - respire)
			if couleur then fiche.anneau.Color = couleur end
		end
		if fiche.onde then
			local k = ((t + fiche.phase) % 2.4) / 2.4
			local d = fiche.diametre * (1 + 0.8 * k)
			fiche.onde.Size = Vector3.new(0.1, d, d)
			fiche.onde.Transparency = 0.45 + 0.55 * k
			if couleur then fiche.onde.Color = couleur end
		end
		return true
	end

	-- ===== une seule boucle : Bases (chaque image), membres et cou (40 fois/s) =====
	for _, d in ipairs(dinos:GetChildren()) do inscrire(d) end
	dinos.ChildAdded:Connect(function(d)
		-- les parts et les articulations arrivent juste après le modèle
		task.delay(0.2, function() inscrire(d) end)
	end)
	dinos.ChildRemoved:Connect(retirer)

	local cumul = 0
	RunService.RenderStepped:Connect(function(dt)
		local camera = workspace.CurrentCamera
		local oeil = camera and camera.CFrame.Position
		local t = os.clock()

		-- dinos posés dans les Bases
		for dino, fiche in pairs(exposes) do
			local corps = dino.PrimaryPart
			if not dino.Parent or not corps then
				exposes[dino] = nil
				retirerEffets(fiche)
				rendreCou(fiche.cou)
				fiche.cou = nil
			else
				local proche = not oeil or (fiche.centre.Position - oeil).Magnitude < DISTANCE_MAX
				if proche ~= fiche.proche then
					fiche.proche = proche
					for _, e in ipairs(fiche.emetteurs) do e.Enabled = proche end
				end
				if proche and not animerExpose(dino, fiche, t) then
					-- le serveur l'a déplacé sans changer son Etat : on reprend depuis sa nouvelle pose
					exposes[dino] = nil
					retirerEffets(fiche)
					rendreCou(fiche.cou)
					fiche.cou = nil
					task.delay(0.3, function()
						if dino.Parent and dino:GetAttribute("Etat") == "Enclos" then exposer(dino) end
					end)
				end
			end
		end

		-- membres (pattes, queue, ailes) et cou : 40 fois par seconde, uniquement par Motor6D.Transform.
		-- La PrimaryPart des dinos qui marchent (Tapis, en route) appartient au serveur : on n'y touche pas.
		cumul = cumul + dt
		if cumul < 1 / 40 then return end
		cumul = 0
		for dino, fiche in pairs(suivis) do
			if not dino.Parent then
				suivis[dino] = nil
			else
				local proche = true
				if oeil and dino.PrimaryPart then
					proche = (dino.PrimaryPart.Position - oeil).Magnitude < DISTANCE_MAX
				end
				if proche then
					local etat = dino:GetAttribute("Etat")
					local marche = ETATS_MARCHE[etat] == true
					local porte = etat == "Porte"
					local expose = exposes[dino]
					local saut = 0
					local joie = false
					if expose then
						saut = expose.saut or 0
						joie = expose.joie ~= nil
					end
					local u = t + fiche.decalage
					local appui = math.abs(math.sin(u * PAS))
					-- pas levé : la patte se soulève pendant qu'elle revient vers l'avant (jamais sous sa pose de repos)
					local leveMax = 0
					if marche and not fiche.volant then
						leveMax = fiche.amp * echelleDe(dino) / fiche.echelle
					end
					for _, m in ipairs(fiche.moteurs) do
						local cf
						if m.genre == "patte" then
							if marche then
								local a = u * PAS + m.phase
								local leve = leveMax * math.max(0, math.cos(a))
								cf = CFrame.new(0, leve, 0) * CFrame.Angles(math.sin(a) * 0.5, 0, 0)
							elseif porte then
								cf = CFrame.Angles(math.sin(u * 14 + m.phase) * 0.7, 0, 0) -- il gigote sur la tête du voleur
							elseif saut > 0 then
								-- en l'air : pattes avant tendues vers l'avant, pattes arrière vers l'arrière
								local sens = -1
								if m.avant then sens = 1 end
								cf = CFrame.Angles(sens * 0.45 * saut, 0, 0)
							else
								cf = CFrame.new()
							end
						elseif m.genre == "queue" then
							local amplitude, vitesse = 0.12, 1.6
							if marche then amplitude, vitesse = 0.28, 5 end
							if joie or saut > 0 then amplitude, vitesse = 0.4, 11 end -- remue de joie
							local leve = 0
							if marche then leve = 0.08 * appui end
							cf = CFrame.Angles(leve, math.sin(u * vitesse) * amplitude, 0)
						else
							local vitesse = 2
							if marche or porte or saut > 0 then vitesse = 9 end
							cf = CFrame.Angles(0, 0, math.sin(u * vitesse) * 0.5 * m.cote)
						end
						m.moteur.Transform = cf
					end
				end
			end
		end

		-- la tête des dinos posés : se balance doucement, suit les actions (regard, saut de joie)
		for dino, fiche in pairs(exposes) do
			local cou = fiche.cou
			if cou and not cou.rendu and fiche.proche and dino.Parent then
				if not cou.moteur.Parent then
					fiche.cou = nil
				elseif math.abs(echelleDe(dino) - cou.echelle) > 1e-4 then
					-- le serveur a changé l'échelle du modèle : on rend la soudure (qui suit ScaleTo),
					-- puis on recrée le cou à partir des CFrames du moment
					rendreCou(cou)
					fiche.cou = nil
					task.delay(0.15, function()
						if exposes[dino] == fiche and not fiche.cou and dino.PrimaryPart then
							fiche.cou = creerCou(dino, dino.PrimaryPart)
						end
					end)
				else
					local u = t + fiche.phase
					local saut = fiche.saut or 0
					local tangage = math.sin(u * 0.7) * 0.04 + 0.15 * saut
					local lacet = math.sin(u * 0.9) * 0.08 + (fiche.regard or 0)
					local roulis = math.sin(u * 0.6) * 0.03
					cou.moteur.Transform = CFrame.Angles(tangage, lacet, roulis)
				end
			end
		end
	end)
end

return M
