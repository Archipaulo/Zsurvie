-- Système Achat : achat des dinos sur le Tapis (invite « Acheter »), puis marche du dino jusqu'à la Base de son acheteur.
-- Version 2 : pendant la marche, le dino s'anime comme sur le Tapis (pattes en diagonale, queue,
-- ailes, petit sautillement), se tourne en douceur dans les virages, et laisse derrière lui
-- de petites empreintes et un nuage de poussière (ParticleEmitter, retirés à l'arrivée).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Debris = game:GetService("Debris")

local M = {}

-- même grammaire de marche que Systemes/Tapis
local MARCHE_ANGLE = 0.42          -- radians de balancement des pattes
local QUEUE_ANGLE = 0.2            -- radians de balancement de la queue
local QUEUE_RETARD = 0.9           -- la queue suit le pas avec un léger retard
local AILE_ANGLE = 0.3             -- radians de battement des ailes
local AILE_RYTHME = 1.5            -- battements plus rapides que les pas
local DANDINEMENT_ANGLE = 0.07     -- radians de roulis
local DANDINEMENT_HAUTEUR = 0.15   -- studs de sautillement (pour une patte de 2 studs)
local FREQUENCE_MIN = 8            -- radians par seconde (grands dinos : pas lents)
local FREQUENCE_MAX = 15           -- radians par seconde (petits dinos : pas rapides)
local VIRAGE = 9                   -- vitesse de rotation dans les virages (plus grand = plus sec)
local PATTES = {
	PatteAvG = { cote = "G", decal = 0 },
	PatteArD = { cote = "D", decal = 0 },
	PatteAvD = { cote = "D", decal = math.pi },
	PatteArG = { cote = "G", decal = math.pi },
}
-- parts rattachées à la patte la plus proche du même côté (nom terminé par G ou D)
local ACCESSOIRES = { "Pied", "Main", "Griffe", "Pouce", "Cuisse", "Sabot", "Orteil", "Ongle" }
local TEXTURE_POUSSIERE = "rbxasset://textures/particles/smoke_main.dds"
local DUREE_TRACES = 2             -- secondes laissées aux dernières particules pour s'effacer

function M.demarrer(ctx)
	local Bus = ctx.Bus
	local Plan = ctx.Plan
	local E = ctx.Equilibrage
	local Reseau = ctx.Reseau

	local VITESSE = (E.tapis and E.tapis.vitesseMarche) or 14
	local MARGE_DISTANCE = 6 -- tolérance (studs) au-delà de la portée de l'invite

	local enAchat = {}   -- [dino] = true pendant la transaction (le premier gagne)
	local marcheurs = {} -- liste des dinos en route vers leur Base

	-- ===== utilitaires =====
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

	-- remonte jusqu'au Model posé directement dans ctx.dinos
	local function dinoDe(inst)
		local courant = inst
		while courant and courant.Parent do
			if courant.Parent == ctx.dinos then
				if courant:IsA("Model") then return courant end
				return nil
			end
			courant = courant.Parent
		end
		return nil
	end

	local function vivant(dino)
		return dino ~= nil and dino.Parent == ctx.dinos
	end

	local function pivotDe(dino)
		local ok, cf = pcall(function() return dino:GetPivot() end)
		if ok then return cf end
		return nil
	end

	local function liberer(joueur, numero)
		if joueur and numero then
			Bus.demander("LibererEmplacement", joueur, numero)
		end
	end

	local function nomEspece(dino)
		local espece = dino:GetAttribute("Espece")
		local fiche = E.especes and E.especes[espece]
		if fiche and fiche.nom then return fiche.nom end
		return tostring(espece or "dino")
	end

	-- point d'entrée d'une Base : centre décalé vers le Tapis d'une demi-profondeur
	local function entreeBase(index)
		local b = Plan.bases[index]
		if not b then return nil end
		local sens = b.versTapis or 1
		local profondeur = (Plan.base and Plan.base.profondeur) or 50
		local ySol = (Plan.base and Plan.base.hauteurSol) or 1
		return Vector3.new(b.centre.X, ySol, b.centre.Z + sens * profondeur / 2)
	end

	-- ===== ligne « ➜ Joueur » sur l'étiquette pendant la marche (STYLE.md §3) =====
	local LIGNE_ACHETEUR = 1.1 -- hauteur de la ligne, en studs

	-- ajoute la ligne verte en tête de l'étiquette ; l'étiquette grandit vers le haut
	local function marquerAcheteur(dino, joueur)
		local Style = ctx.Style
		if not Style or not vivant(dino) then return end
		local gui = dino:FindFirstChild("Etiquette", true)
		if not gui or not gui:IsA("BillboardGui") or gui:FindFirstChild("Acheteur") then return end
		local hauteur = gui.Size.Y.Scale
		if hauteur <= 0 then return end
		local nouvelle = hauteur + LIGNE_ACHETEUR
		local facteur = hauteur / nouvelle
		for _, enfant in ipairs(gui:GetChildren()) do
			if enfant:IsA("GuiObject") then
				local s = enfant.Size
				enfant.Size = UDim2.new(s.X.Scale, s.X.Offset, s.Y.Scale * facteur, s.Y.Offset)
			end
		end
		gui.Size = UDim2.new(gui.Size.X.Scale, gui.Size.X.Offset, nouvelle, gui.Size.Y.Offset)
		gui.StudsOffset = gui.StudsOffset + Vector3.new(0, LIGNE_ACHETEUR / 2, 0)
		local ligne = Style.texte(gui, {
			Name = "Acheteur",
			LayoutOrder = -1,
			Size = UDim2.new(1, 0, LIGNE_ACHETEUR / nouvelle, 0),
			Text = "➜ " .. joueur.Name,
			TextColor3 = Style.couleurs.argent,
			contour = 3,
		})
		ligne:SetAttribute("Hauteur", LIGNE_ACHETEUR)
	end

	-- retire la ligne et rend à l'étiquette sa taille d'origine
	local function demarquerAcheteur(dino)
		if not dino then return end
		local gui = dino:FindFirstChild("Etiquette", true)
		if not gui or not gui:IsA("BillboardGui") then return end
		local ligne = gui:FindFirstChild("Acheteur")
		if not ligne then return end
		local retrait = ligne:GetAttribute("Hauteur") or LIGNE_ACHETEUR
		ligne:Destroy()
		local hauteur = gui.Size.Y.Scale
		local ancienne = hauteur - retrait
		if ancienne <= 0 then return end
		local facteur = hauteur / ancienne
		for _, enfant in ipairs(gui:GetChildren()) do
			if enfant:IsA("GuiObject") then
				local s = enfant.Size
				enfant.Size = UDim2.new(s.X.Scale, s.X.Offset, s.Y.Scale * facteur, s.Y.Offset)
			end
		end
		gui.Size = UDim2.new(gui.Size.X.Scale, gui.Size.X.Offset, ancienne, gui.Size.Y.Offset)
		gui.StudsOffset = gui.StudsOffset - Vector3.new(0, retrait / 2, 0)
	end

	-- ===== animation de marche (repère du pivot : sol sous le dino, regard vers -Z) =====
	local Charte = ctx.Charte
	local reposGabarits = {} -- espece -> { [chemin] = { CFrame, ... } } ou false

	local function commencePar(nom, prefixe)
		return string.sub(nom, 1, #prefixe) == prefixe
	end

	local function coteDe(nom)
		local c = string.sub(nom, -1)
		if c == "G" or c == "D" then return c end
		return nil
	end

	local function partsDe(modele)
		local liste = {}
		for _, d in ipairs(modele:GetDescendants()) do
			if d:IsA("BasePart") then table.insert(liste, d) end
		end
		return liste
	end

	local function cheminDans(modele, inst)
		local noms = {}
		local courant = inst
		while courant and courant ~= modele do
			table.insert(noms, 1, courant.Name)
			courant = courant.Parent
		end
		return table.concat(noms, "/")
	end

	-- pivot calculé comme GetPivot() d'un dino vivant (PrimaryPart = Corps)
	local function pivotModele(modele)
		local pp = modele.PrimaryPart or modele:FindFirstChild("Corps")
		if pp and pp:IsA("BasePart") then
			return pp.CFrame * pp.PivotOffset
		end
		return nil
	end

	-- poses de repos lues sur le gabarit de l'espèce (le dino acheté peut être en plein pas)
	local function reposGabarit(espece)
		if type(espece) ~= "string" then return nil end
		local connu = reposGabarits[espece]
		if connu ~= nil then
			if connu == false then return nil end
			return connu
		end
		local resultat = false
		local dossier = ctx.stockage and ctx.stockage:FindFirstChild("Dinos")
		local gabarit = dossier and dossier:FindFirstChild(espece)
		local pivot = gabarit and gabarit:IsA("Model") and pivotModele(gabarit)
		if pivot then
			resultat = {}
			for _, p in ipairs(partsDe(gabarit)) do
				local cle = cheminDans(gabarit, p)
				resultat[cle] = resultat[cle] or {}
				table.insert(resultat[cle], pivot:ToObjectSpace(p.CFrame))
			end
		end
		reposGabarits[espece] = resultat
		if resultat == false then return nil end
		return resultat
	end

	-- part -> pose de repos dans le repère du pivot
	local function posesDeRepos(dino, pivot, parts)
		local poses = {}
		for _, p in ipairs(parts) do
			poses[p] = pivot:ToObjectSpace(p.CFrame)
		end
		local gabarit = reposGabarit(dino:GetAttribute("Espece"))
		if not gabarit then return poses end
		local rangs = {}
		local depuisGabarit = {}
		for _, p in ipairs(parts) do
			local cle = cheminDans(dino, p)
			local liste = gabarit[cle]
			local rang = (rangs[cle] or 0) + 1
			rangs[cle] = rang
			if not liste or not liste[rang] then return poses end
			depuisGabarit[p] = liste[rang]
		end
		-- contrôle : les parts non animées doivent coïncider (sinon le modèle a été retouché)
		for _, p in ipairs(parts) do
			local nom = p.Name
			if not PATTES[nom] and not coteDe(nom) and not string.find(nom, "Queue", 1, true) and not commencePar(nom, "Massue") then
				if (depuisGabarit[p].Position - poses[p].Position).Magnitude > 0.05 then
					return poses
				end
			end
		end
		return depuisGabarit
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
		if l2 < 0.000001 then return (p - a).Magnitude end
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

	-- repère pattes (+ accessoires), queue et ailes ; renvoie la fiche d'animation ou nil
	local function analyserMembres(dino)
		-- dino voxel assemblé : les membres sont animés côté client (Interface/AnimationsDinos)
		if dino:GetAttribute("Assemble") then return nil end
		local pivot = pivotDe(dino)
		if not pivot then return nil end
		local parts = partsDe(dino)
		local poses = posesDeRepos(dino, pivot, parts)
		local groupes = {}
		local pattes = {}
		local queue = {}
		local ailes = { G = {}, D = {} }
		local hauteurPatte = 0
		local ecartPattes = 0
		local nombrePattes = 0
		for _, p in ipairs(parts) do
			local nom = p.Name
			local repos = poses[p]
			local infoPatte = PATTES[nom]
			if infoPatte and pattes[nom] then
				-- patte voxel en plusieurs parts : toutes suivent le même groupe
				table.insert(pattes[nom].membres, { part = p, repos = repos })
			elseif infoPatte then
				local a, b = extremites(repos, p.Size)
				local haut, bas = a, b
				if b.Y > a.Y then haut, bas = b, a end
				local g = nouveauGroupe("patte", haut, infoPatte.decal, infoPatte.cote)
				g.haut = haut
				g.bas = bas
				g.portee = math.max(p.Size.X, p.Size.Y, p.Size.Z) * 0.8 + 0.8
				table.insert(g.membres, { part = p, repos = repos })
				pattes[nom] = g
				table.insert(groupes, g)
				hauteurPatte = math.max(hauteurPatte, haut.Y)
				ecartPattes = ecartPattes + math.abs(repos.Position.X)
				nombrePattes = nombrePattes + 1
			elseif string.find(nom, "Queue", 1, true) or commencePar(nom, "Massue") then
				table.insert(queue, { part = p, repos = repos })
			elseif commencePar(nom, "Aile") and coteDe(nom) then
				table.insert(ailes[coteDe(nom)], { part = p, repos = repos })
			end
		end

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
					local repos = poses[p]
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

		if #queue > 0 then
			local racine = queue[1]
			for _, q in ipairs(queue) do
				if q.part.Name == "Queue" then
					racine = q
					break
				end
				if q.repos.Position.Z < racine.repos.Position.Z then racine = q end
			end
			local a, b = extremites(racine.repos, racine.part.Size)
			local point = a
			if b.Z < a.Z then point = b end
			local g = nouveauGroupe("queue", point)
			g.membres = queue
			table.insert(groupes, g)
		end

		for _, cote in ipairs({ "G", "D" }) do
			local liste = ailes[cote]
			if #liste > 0 then
				local racine = liste[1]
				for _, a in ipairs(liste) do
					if a.part.Name == "Aile" .. cote then
						racine = a
						break
					end
				end
				local a, b = extremites(racine.repos, racine.part.Size)
				local point = a
				if math.abs(b.X) < math.abs(a.X) then point = b end
				local g = nouveauGroupe("aile", point, 0, cote)
				g.membres = liste
				table.insert(groupes, g)
			end
		end

		-- cadence : les grands dinos font de grands pas lents, les petits trottinent
		local corps = dino.PrimaryPart or dino:FindFirstChild("Corps")
		if hauteurPatte <= 0 then
			hauteurPatte = (corps and corps:IsA("BasePart") and corps.Size.Y) or 2
		end
		hauteurPatte = math.max(0.8, hauteurPatte)
		local frequence = math.max(FREQUENCE_MIN, math.min(FREQUENCE_MAX, VITESSE / (hauteurPatte * 0.55)))
		local ecart = 0
		if nombrePattes > 0 then
			ecart = ecartPattes / nombrePattes
		elseif corps and corps:IsA("BasePart") then
			ecart = corps.Size.X / 4
		end
		return {
			groupes = groupes,
			frequence = frequence,
			echelle = math.max(0.6, math.min(2.5, hauteurPatte / 2)),
			ecart = math.max(0.35, ecart),
			phase = 0,
		}
	end

	-- pose les membres autour du pivot cf
	local function animerMembres(cf, anim)
		local base = anim.phase
		for _, g in ipairs(anim.groupes) do
			local rotation
			if g.genre == "patte" then
				rotation = CFrame.Angles(math.sin(base + g.decal) * MARCHE_ANGLE, 0, 0)
			elseif g.genre == "queue" then
				rotation = CFrame.Angles(0, math.sin(base - QUEUE_RETARD) * QUEUE_ANGLE, 0)
			else
				local battement = math.sin(base * AILE_RYTHME) * AILE_ANGLE
				if g.cote == "G" then battement = -battement end
				rotation = CFrame.Angles(0, 0, battement)
			end
			local m = cf * g.avant * rotation * g.apres
			for _, membre in ipairs(g.membres) do
				membre.part.CFrame = m * membre.repos
			end
		end
	end

	-- remet les membres au repos autour du pivot actuel
	local function reposerMembres(dino, anim)
		if not anim or not anim.groupes or not vivant(dino) then return end
		local cf = pivotDe(dino)
		if not cf then return end
		for _, g in ipairs(anim.groupes) do
			for _, membre in ipairs(g.membres) do
				if membre.part.Parent then
					membre.part.CFrame = cf * membre.repos
				end
			end
		end
	end

	-- ===== traces de pas : empreintes au sol et poussière =====
	local function sequence(points)
		local cles = {}
		for _, pt in ipairs(points) do
			table.insert(cles, NumberSequenceKeypoint.new(pt[1], pt[2]))
		end
		return NumberSequence.new(cles)
	end

	local function nouvelleAttache(corps, nom, cfLocal)
		local a = Instance.new("Attachment")
		a.Name = nom
		a.CFrame = cfLocal
		a.Parent = corps
		return a
	end

	local function poserTraces(dino, anim)
		local corps = dino.PrimaryPart or dino:FindFirstChild("Corps")
		local pivot = pivotDe(dino)
		if not corps or not corps:IsA("BasePart") or not pivot then return nil end
		local k = anim.echelle
		local attaches = {}

		-- poussière : petits nuages sable qui montent derrière le dino
		local sol = nouvelleAttache(corps, "PoussiereMarche", corps.CFrame:ToObjectSpace(pivot * CFrame.new(0, 0.15, 0)))
		table.insert(attaches, sol)
		local poussiere = Instance.new("ParticleEmitter")
		poussiere.Name = "Poussiere"
		poussiere.Texture = TEXTURE_POUSSIERE
		poussiere.Color = ColorSequence.new(Charte.sable, Charte.creme)
		poussiere.LightInfluence = 0.8
		poussiere.LightEmission = 0
		poussiere.Size = sequence({ { 0, 0.35 * k }, { 0.3, 0.95 * k }, { 1, 1.6 * k } })
		poussiere.Transparency = sequence({ { 0, 0.55 }, { 0.25, 0.45 }, { 1, 1 } })
		poussiere.Lifetime = NumberRange.new(0.45, 0.8)
		poussiere.Rate = 7 + 3 * k
		poussiere.Speed = NumberRange.new(1.2, 2.8)
		poussiere.SpreadAngle = Vector2.new(70, 70)
		poussiere.Acceleration = Vector3.new(0, 1.5, 0)
		poussiere.Drag = 3
		poussiere.Rotation = NumberRange.new(0, 360)
		poussiere.RotSpeed = NumberRange.new(-40, 40)
		poussiere.Parent = sol

		-- empreintes : taches sombres posées à plat, une ligne par côté, qui s'effacent
		local pasParSeconde = anim.frequence / math.pi
		for _, sx in ipairs({ -1, 1 }) do
			local cote = "G"
			if sx > 0 then cote = "D" end
			local pied = nouvelleAttache(corps, "EmpreintesMarche" .. cote, corps.CFrame:ToObjectSpace(pivot * CFrame.new(sx * anim.ecart, 0.06, 0)))
			table.insert(attaches, pied)
			local e = Instance.new("ParticleEmitter")
			e.Name = "Empreintes"
			e.Texture = TEXTURE_POUSSIERE
			e.Color = ColorSequence.new(Charte.ombre(Charte.terre))
			e.LightInfluence = 1
			e.LightEmission = 0
			e.Size = NumberSequence.new(0.5 * k)
			e.Transparency = sequence({ { 0, 0.3 }, { 0.6, 0.45 }, { 1, 1 } })
			e.Lifetime = NumberRange.new(1.3, 1.7)
			e.Rate = pasParSeconde / 2
			e.Speed = NumberRange.new(0.01)
			e.EmissionDirection = Enum.NormalId.Bottom
			e.SpreadAngle = Vector2.new(0, 0)
			e.Rotation = NumberRange.new(0, 360)
			pcall(function()
				-- perpendiculaire à la vitesse (vers le bas) : la tache reste couchée sur le sol
				e.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
			end)
			e.Parent = pied
		end
		return attaches
	end

	-- coupe l'émission et laisse les dernières particules s'effacer
	local function retirerTraces(anim)
		if not anim or not anim.traces then return end
		for _, a in ipairs(anim.traces) do
			for _, e in ipairs(a:GetChildren()) do
				if e:IsA("ParticleEmitter") then e.Enabled = false end
			end
			Debris:AddItem(a, DUREE_TRACES)
		end
		anim.traces = nil
	end

	local function preparerAnimation(dino)
		local ok, anim = pcall(analyserMembres, dino)
		if not ok or not anim then return nil end
		local okTraces, traces = pcall(poserTraces, dino, anim)
		if okTraces then anim.traces = traces end		return anim
	end

	-- ===== la marche vers la Base =====
	local function arreterMarche(m)
		m.fini = true
		if m.anim then
			pcall(reposerMembres, m.dino, m.anim)
			pcall(retirerTraces, m.anim)
			m.anim = nil
		end
		pcall(demarquerAcheteur, m.dino)
	end

	-- abandon en route : libère l'emplacement ; détruit le dino s'il reste orphelin
	local function abandonner(m)
		arreterMarche(m)
		liberer(m.joueur, m.numero)
		if vivant(m.dino) and not (m.joueur and m.joueur.Parent) then
			pcall(function() m.dino:Destroy() end)
		end
	end

	local function arriver(m)
		arreterMarche(m)
		task.spawn(function()
			if not vivant(m.dino) or not m.joueur.Parent then
				abandonner(m)
				return
			end
			local place = Bus.demander("PlacerDino", m.dino, m.joueur, m.numero)
			if place ~= true then
				-- la pose a échoué : on rend l'argent plutôt que de laisser un dino perdu
				liberer(m.joueur, m.numero)
				local prix = m.dino:GetAttribute("Prix")
				if type(prix) == "number" and prix > 0 and m.joueur.Parent then
					Bus.demander("AjouterArgent", m.joueur, prix, "Remboursement")
					notifier(m.joueur, "Ton dino n'a pas pu entrer dans ta base : tu es remboursé.", "alerte")
				end
				if vivant(m.dino) then
					pcall(function() m.dino:Destroy() end)
				end
			end
		end)
	end

	local function lancerMarche(dino, joueur, index, numero)
		local depart = pivotDe(dino)
		local entree = entreeBase(index)
		local cfFin = Bus.demander("CFrameEmplacement", index, numero)
		if not depart or not entree or typeof(cfFin) ~= "CFrame" then
			return false
		end
		local m = {
			dino = dino,
			joueur = joueur,
			index = index,
			numero = numero,
			position = depart.Position,
			etapes = { entree, cfFin.Position },
			etape = 1,
			cfFin = cfFin,
			regard = Vector3.new(depart.LookVector.X, 0, depart.LookVector.Z),
			fini = false,
		}
		if m.regard.Magnitude < 0.05 then
			m.regard = Vector3.new(0, 0, -1)
		else
			m.regard = m.regard.Unit
		end
		m.anim = preparerAnimation(dino)
		table.insert(marcheurs, m)
		pcall(marquerAcheteur, dino, joueur)
		return true
	end

	-- oriente le regard vers le cap en douceur (virage à l'entrée de la Base)
	local function tourner(m, cap, dt)
		local t = math.min(1, dt * VIRAGE)
		local r = m.regard + (cap - m.regard) * t
		if r.Magnitude < 0.05 then
			-- demi-tour exact : on pivote d'un quart vers la droite pour ne pas s'arrêter
			r = m.regard:Cross(Vector3.new(0, 1, 0))
		end
		m.regard = r.Unit
	end

	-- cadre du pivot pendant la marche : sautillement et roulis au rythme des pas
	local function cadreMarche(m)
		local anim = m.anim
		if not anim then
			return CFrame.lookAt(m.position, m.position + m.regard)
		end
		local oscillation = math.sin(anim.phase)
		local hauteur = math.abs(oscillation) * DANDINEMENT_HAUTEUR * anim.echelle
		local p = m.position + Vector3.new(0, hauteur, 0)
		return CFrame.lookAt(p, p + m.regard) * CFrame.Angles(0, 0, oscillation * DANDINEMENT_ANGLE)
	end

	local function avancer(m, dt)
		if m.fini then return end
		if not vivant(m.dino) or not m.joueur.Parent then
			abandonner(m)
			return
		end
		if m.dino:GetAttribute("Etat") ~= "EnRoute" then
			-- un autre système a repris la main sur ce dino
			arreterMarche(m)
			return
		end
		local reste = VITESSE * dt
		local cap = nil
		while reste > 0 and not m.fini do
			local cible = m.etapes[m.etape]
			local ecart = cible - m.position
			local distance = ecart.Magnitude
			local plat = Vector3.new(ecart.X, 0, ecart.Z)
			if plat.Magnitude > 0.05 then
				cap = plat.Unit
			end
			if distance <= reste then
				m.position = cible
				reste = reste - distance
				m.etape = m.etape + 1
				if m.etape > #m.etapes then
					pcall(function() m.dino:PivotTo(m.cfFin) end)
					arriver(m)
					return
				end
			else
				m.position = m.position + ecart.Unit * reste
				reste = 0
			end
		end
		if cap then tourner(m, cap, dt) end
		if m.anim then
			m.anim.phase = (m.anim.phase + dt * m.anim.frequence) % (math.pi * 4)
		end
		local cf = cadreMarche(m)
		pcall(function() m.dino:PivotTo(cf) end)
		if m.anim and #m.anim.groupes > 0 then
			local ok = pcall(animerMembres, cf, m.anim)
			if not ok then
				-- animation impossible : le dino finit sa route sans bouger les membres
				pcall(reposerMembres, m.dino, m.anim)
				m.anim.groupes = {}
			end
		end
	end

	RunService.Heartbeat:Connect(function(dt)
		if #marcheurs == 0 then return end
		for _, m in ipairs(marcheurs) do
			local ok = pcall(avancer, m, dt)
			if not ok then
				abandonner(m)
			end
		end
		for i = #marcheurs, 1, -1 do
			if marcheurs[i].fini then table.remove(marcheurs, i) end
		end
	end)

	Players.PlayerRemoving:Connect(function(joueur)
		for _, m in ipairs(marcheurs) do
			if m.joueur == joueur and not m.fini then
				abandonner(m)
			end
		end
	end)

	-- ===== l'achat =====
	local function acheter(dino, joueur, invite)
		if dino:GetAttribute("Etat") ~= "Tapis" then return end

		-- distance : l'invite a sa portée, on ajoute une petite marge
		local perso = joueur.Character
		local racine = perso and perso:FindFirstChild("HumanoidRootPart")
		local pos = pivotDe(dino)
		if not racine or not pos then return end
		local portee = 10
		if invite and invite:IsA("ProximityPrompt") then portee = invite.MaxActivationDistance end
		if (racine.Position - pos.Position).Magnitude > portee + MARGE_DISTANCE + dino:GetExtentsSize().Magnitude / 2 then
			return
		end

		if Bus.demander("AutoriserAction", joueur, "Achat", 0.25) == false then return end

		local index = Bus.demander("BaseDe", joueur)
		if type(index) ~= "number" or not Plan.bases[index] then
			notifier(joueur, "Ta base n'est pas encore prête.", "alerte")
			return
		end

		local prix = dino:GetAttribute("Prix")
		if type(prix) ~= "number" or prix < 0 then return end

		local numero = Bus.demander("ReserverEmplacement", joueur)
		if type(numero) ~= "number" then
			notifier(joueur, "Ta base est pleine !", "alerte")
			return
		end

		-- le dino a pu quitter le Tapis pendant la réservation
		if not vivant(dino) or dino:GetAttribute("Etat") ~= "Tapis" then
			liberer(joueur, numero)
			return
		end

		if Bus.demander("DepenserArgent", joueur, prix) ~= true then
			liberer(joueur, numero)
			notifier(joueur, "Pas assez d'argent", "alerte")
			return
		end

		-- payé : si le dino a disparu entre-temps, on rembourse
		if not vivant(dino) or dino:GetAttribute("Etat") ~= "Tapis" or not joueur.Parent then
			liberer(joueur, numero)
			if joueur.Parent and prix > 0 then
				Bus.demander("AjouterArgent", joueur, prix, "Remboursement")
			end
			return
		end

		dino:SetAttribute("Etat", "EnRoute")
		dino:SetAttribute("Proprietaire", joueur.UserId)
		dino:SetAttribute("Base", index)
		dino:SetAttribute("Emplacement", numero)

		-- retire l'invite Acheter
		for _, d in ipairs(dino:GetDescendants()) do
			if d:IsA("ProximityPrompt") and d.Name == "Acheter" then
				pcall(function() d:Destroy() end)
			end
		end

		Bus.emettre("DinoAchete", dino, joueur)
		local position = pivotDe(dino)
		effet("Achat", position and position.Position or pos.Position, { rarete = dino:GetAttribute("Rarete") })
		notifier(joueur, nomEspece(dino) .. " rejoint ta base !", "succes")

		if not lancerMarche(dino, joueur, index, numero) then
			-- pas de trajet possible : on pose directement
			arriver({ dino = dino, joueur = joueur, index = index, numero = numero })
		end
	end

	ProximityPromptService.PromptTriggered:Connect(function(invite, joueur)
		if not invite or invite.Name ~= "Acheter" then return end
		if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") or not joueur.Parent then return end
		local dino = dinoDe(invite)
		if not dino then return end
		if enAchat[dino] then return end
		enAchat[dino] = true
		local ok = pcall(acheter, dino, joueur, invite)
		enAchat[dino] = nil
		if not ok then
			-- en cas d'erreur imprévue, rien n'est laissé à moitié : le dino reste sur le Tapis
			return
		end
	end)
end

return M
