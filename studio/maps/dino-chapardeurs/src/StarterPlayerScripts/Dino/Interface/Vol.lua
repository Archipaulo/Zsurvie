-- Interface Vol : guide du voleur (ruban rouge qui pulse avec médaillon 🦖, faisceau vers sa base, bords dorés)
-- et alerte de la victime (texte géant « ON TE VOLE ! » en relief qui tremble, plaque 🚨 avec le nom du voleur,
-- bords rouges, son, surbrillance du voleur).
-- Look « simulateur Roblox » soigné : ombres portées, reflets, entrée en pop, sortie en fondu (voir STYLE.md §4).
-- Tout est local à ce client : aucune part, seulement des Attachments, un Beam et des Highlights.
--
-- Place à l'écran (1280 x 720) : bandeau d'événement du HUD 10..84, barre de verrou 144..196,
-- ruban du porteur 198..264, notifications du HUD à partir de 270 (deux notifications : ..368),
-- alerte de la victime centrée (244..404, sur les notifications), bouton Collecter du HUD masqué pendant l'alerte.
-- L'alerte ne voile jamais l'écran : seuls les bords rouges clignotent, le HUD reste lisible.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local M = {}

local PERIODE = 0.25      -- rafraîchissement du suivi (faisceau, voleurs)
local DUREE_ALERTE = 2    -- durée de l'alerte (le texte tremble pendant tout ce temps)
local ANTI_DOUBLON = 1.5  -- deux signaux d'un même vol à moins de 1,5 s = une seule alerte
local HAUT_RUBAN = 198    -- sous l'argent, le bandeau d'événement (10..84) et la barre de verrou (144..196)
local HAUTEUR_RUBAN = 64  -- ombre comprise : la pile de notifications du HUD commence à 270
local OMBRE = 5           -- décalage des ombres portées (px, vers le bas)
local CENTRE_ALERTE = 0.45 -- centre vertical du bloc d'alerte (fraction de l'écran)
local HAUTEUR_ALERTE = 160
local ENTREE_RUBAN = 0.15 -- fondu d'entrée du ruban (s)
local SORTIE_RUBAN = 0.3  -- fondu de sortie du ruban (s)
local SORTIE_ALERTE = 0.45

function M.demarrer(ctx)
	local Style = ctx.Style
	local Bus = ctx.Bus
	local Reseau = ctx.Reseau
	local joueur = ctx.joueur
	local gui = ctx.gui
	local racine = ctx.racine
	local dinos = ctx.dinos
	local hex = ctx.Charte and ctx.Charte.hex

	local reglesVol = (ctx.Equilibrage and ctx.Equilibrage.vol) or {}
	local DELAI_MAX = tonumber(reglesVol.delaiMax) or 60

	local BLANC = Style.couleurs.texte
	local NOIR = Style.couleurs.ombre
	local JAUNE = Style.couleurs.revenu
	local ROUGE_VIF = Style.boutons.rouge[2]
	local ROUGE_CLAIR = Style.boutons.rouge[1]
	local OR_HAUT = Style.boutons.jaune[1]
	local OR_BAS = Style.boutons.jaune[2]
	local ROUGE_SOMBRE = ROUGE_VIF:Lerp(NOIR, 0.6)
	if hex then ROUGE_SOMBRE = hex("6A0A1C") end

	-- ===== briques visuelles =====
	local function cadre(parent, props)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		f.BorderSizePixel = 0
		for cle, valeur in pairs(props) do
			f[cle] = valeur
		end
		f.Parent = parent
		return f
	end

	-- ombre portée : cadre noir translucide, même forme, décalé vers le bas (à poser AVANT l'objet)
	local function ombrePortee(parent, props)
		local o = cadre(parent, {
			Name = props.Name or "Ombre",
			AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
			Position = props.Position,
			Size = props.Size,
			BackgroundColor3 = NOIR,
			BackgroundTransparency = props.transparence or 0.5,
			ZIndex = props.ZIndex or 1,
		})
		Style.coins(o, props.rayon or 14)
		return o
	end

	-- reflet brillant sur la moitié haute (effet « bonbon », comme les boutons)
	local function reflet(parent, rayon, zindex)
		local r = cadre(parent, {
			Name = "Reflet",
			Position = UDim2.new(0, 6, 0, 3),
			Size = UDim2.new(1, -12, 0.44, 0),
			BackgroundTransparency = 0.7,
			ZIndex = zindex,
		})
		Style.coins(r, rayon)
		local fondu = Instance.new("UIGradient")
		fondu.Rotation = 90
		fondu.Transparency = NumberSequence.new(0.1, 1)
		fondu.Parent = r
		return r
	end

	-- médaillon rond cerné de noir avec un gros emoji, et son ombre
	local function medaillon(parent, props)
		local taille = props.taille
		ombrePortee(parent, {
			Name = props.Name .. "Ombre",
			AnchorPoint = props.AnchorPoint,
			Position = props.Position + UDim2.fromOffset(0, OMBRE),
			Size = UDim2.fromOffset(taille, taille),
			rayon = math.floor(taille / 2),
			ZIndex = props.ZIndex,
		})
		local m = cadre(parent, {
			Name = props.Name,
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			Size = UDim2.fromOffset(taille, taille),
			ZIndex = props.ZIndex + 1,
		})
		Style.coins(m, math.floor(taille / 2))
		Style.bordure(m, 4)
		Style.degrade(m, props.haut, props.bas).Name = "Fond"
		reflet(m, math.floor(taille / 3), props.ZIndex + 1)
		local icone = Style.texte(m, {
			Name = "Icone",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.fromScale(0.72, 0.72),
			Text = props.icone,
			contour = 0,
			ZIndex = props.ZIndex + 2,
		})
		local c = icone:FindFirstChild("Contour")
		if c then c.Enabled = false end
		return m, icone
	end

	-- fondu : on mémorise les transparences d'origine, puis on les estompe toutes ensemble (0 = invisible)
	local function collecterFondu(racineFondu)
		local liste = {}
		local function noter(o)
			if o:IsA("TextLabel") then
				table.insert(liste, { o, "TextTransparency", o.TextTransparency })
				if o.BackgroundTransparency < 1 then
					table.insert(liste, { o, "BackgroundTransparency", o.BackgroundTransparency })
				end
			elseif o:IsA("Frame") then
				if o.BackgroundTransparency < 1 then
					table.insert(liste, { o, "BackgroundTransparency", o.BackgroundTransparency })
				end
			elseif o:IsA("UIStroke") then
				table.insert(liste, { o, "Transparency", o.Transparency })
			end
		end
		noter(racineFondu)
		for _, o in ipairs(racineFondu:GetDescendants()) do noter(o) end
		return liste
	end

	local function appliquerFondu(liste, opacite)
		for _, e in ipairs(liste) do
			e[1][e[2]] = 1 - (1 - e[3]) * opacite
		end
	end

	-- ===== écran : conteneur propre au module =====
	local ecran = Instance.new("Frame")
	ecran.Name = "Vol"
	ecran.Size = UDim2.fromScale(1, 1)
	ecran.BackgroundTransparency = 1
	ecran.BorderSizePixel = 0
	ecran.ZIndex = 20
	ecran.Parent = gui

	-- bords d'écran : quatre dégradés qui s'estompent vers le centre
	local function creerBords(parent, nom, couleur, epaisseur)
		local cadreBords = Instance.new("Frame")
		cadreBords.Name = nom
		cadreBords.Size = UDim2.fromScale(1, 1)
		cadreBords.BackgroundTransparency = 1
		cadreBords.Visible = false
		cadreBords.ZIndex = 20
		cadreBords.Parent = parent
		local liste = {}
		local function bord(n, taille, position, rotation)
			local f = Instance.new("Frame")
			f.Name = n
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Size = taille
			f.Position = position
			f.BackgroundColor3 = couleur
			f.BackgroundTransparency = 0
			f.BorderSizePixel = 0
			f.ZIndex = 20
			local degrade = Instance.new("UIGradient")
			degrade.Rotation = rotation
			degrade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.35, 0.45),
				NumberSequenceKeypoint.new(1, 1),
			})
			degrade.Parent = f
			f.Parent = cadreBords
			table.insert(liste, f)
		end
		bord("Haut", UDim2.fromScale(1, epaisseur), UDim2.fromScale(0.5, epaisseur / 2), 90)
		bord("Bas", UDim2.fromScale(1, epaisseur), UDim2.fromScale(0.5, 1 - epaisseur / 2), 270)
		bord("Gauche", UDim2.fromScale(epaisseur * 0.75, 1), UDim2.fromScale(epaisseur * 0.375, 0.5), 0)
		bord("Droite", UDim2.fromScale(epaisseur * 0.75, 1), UDim2.fromScale(1 - epaisseur * 0.375, 0.5), 180)
		return cadreBords, liste
	end

	-- bords dorés pendant qu'on porte un dino
	local vignette, bords = creerBords(ecran, "Vignette", OR_HAUT, 0.14)

	-- ===== ruban « RAPPORTE-LE CHEZ TOI ! » en haut au centre (198..264) =====
	-- conteneur (pop d'entrée, rétrécit à la sortie) > Corps (pulsation) > ombre, ruban, médaillon 🦖
	local bandeau = Instance.new("Frame")
	bandeau.Name = "Bandeau"
	bandeau.AnchorPoint = Vector2.new(0.5, 0)
	bandeau.Position = UDim2.new(0.5, 0, 0, HAUT_RUBAN)
	bandeau.Size = UDim2.new(0.5, 0, 0, HAUTEUR_RUBAN)
	bandeau.BackgroundTransparency = 1
	bandeau.BorderSizePixel = 0
	bandeau.Visible = false
	bandeau.ZIndex = 21
	bandeau.Parent = ecran
	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MinSize = Vector2.new(320, HAUTEUR_RUBAN)
	contrainte.MaxSize = Vector2.new(580, HAUTEUR_RUBAN)
	contrainte.Parent = bandeau

	local corps = cadre(bandeau, {
		Name = "Corps",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 21,
	})
	local pulsation = Instance.new("UIScale")
	pulsation.Name = "Pulsation"
	pulsation.Parent = corps

	local DEBUT_RUBAN = 30 -- le médaillon (62 px) chevauche le bord gauche du ruban
	local hauteurCorps = HAUTEUR_RUBAN - OMBRE - 1
	ombrePortee(corps, {
		Position = UDim2.fromOffset(DEBUT_RUBAN, OMBRE),
		Size = UDim2.new(1, -DEBUT_RUBAN, 0, hauteurCorps),
		rayon = 18,
		ZIndex = 21,
	})
	local ruban = cadre(corps, {
		Name = "Ruban",
		Position = UDim2.fromOffset(DEBUT_RUBAN, 0),
		Size = UDim2.new(1, -DEBUT_RUBAN, 0, hauteurCorps),
		ZIndex = 22,
	})
	Style.coins(ruban, 18)
	Style.bordure(ruban, 4)
	Style.degrade(ruban, ROUGE_CLAIR, ROUGE_VIF)
	reflet(ruban, 12, 22)

	local titreBandeau = Style.texte(ruban, {
		Name = "Titre",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 16, 0, 3),
		Size = UDim2.new(1, -52, 0, 30),
		Text = "RAPPORTE-LE CHEZ TOI !",
		titre = true,
		contour = 3.5,
		tailleMax = 30,
		ZIndex = 24,
	})
	-- capsule sombre sous le titre : espèce portée, distance et chrono
	local capsule = cadre(ruban, {
		Name = "Capsule",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 16, 1, -4),
		Size = UDim2.new(1, -60, 0, 21),
		BackgroundColor3 = Style.couleurs.fond,
		BackgroundTransparency = 0.25,
		ZIndex = 23,
	})
	Style.coins(capsule, 10)
	local infoBandeau = Style.texte(capsule, {
		Name = "Info",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -14, 1, -2),
		Text = "",
		TextColor3 = JAUNE,
		contour = 2,
		tailleMax = 18,
		ZIndex = 24,
	})
	local _, iconeRuban = medaillon(corps, {
		Name = "Medaillon",
		taille = 62,
		icone = "🦖",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0, math.floor(hauteurCorps / 2)),
		haut = Style.couleurs.fondHaut,
		bas = Style.couleurs.fond,
		ZIndex = 24,
	})
	local fonduRuban = collecterFondu(corps)
	local opaciteRuban = 0

	-- ===== alerte de la victime =====
	local alerte = Instance.new("Frame")
	alerte.Name = "Alerte"
	alerte.Size = UDim2.fromScale(1, 1)
	alerte.BackgroundTransparency = 1 -- jamais de voile plein écran : le HUD doit rester lisible
	alerte.BorderSizePixel = 0
	alerte.Visible = false
	alerte.ZIndex = 30
	alerte.Parent = ecran

	-- bords rouges (dans l'alerte : ils disparaissent avec elle), seuls à clignoter
	local bordsRouges, listeRouges = creerBords(alerte, "BordsRouges", ROUGE_VIF, 0.14)
	bordsRouges.Visible = true

	-- bloc : texte géant en relief qui tremble, puis plaque 🚨 avec le nom du voleur.
	-- Au centre de l'écran, bien loin du bouton Collecter (masqué pendant l'alerte).
	local blocAlerte = Instance.new("Frame")
	blocAlerte.Name = "Bloc"
	blocAlerte.AnchorPoint = Vector2.new(0.5, 0.5)
	blocAlerte.Position = UDim2.new(0.5, 0, CENTRE_ALERTE, 0)
	blocAlerte.Size = UDim2.new(0.9, 0, 0, HAUTEUR_ALERTE)
	blocAlerte.BackgroundTransparency = 1
	blocAlerte.ZIndex = 31
	blocAlerte.Parent = alerte
	local contrainteAlerte = Instance.new("UISizeConstraint")
	contrainteAlerte.MinSize = Vector2.new(300, HAUTEUR_ALERTE)
	contrainteAlerte.MaxSize = Vector2.new(900, HAUTEUR_ALERTE)
	contrainteAlerte.Parent = blocAlerte

	local HAUT_TEXTE = 110
	local RELIEF = 6
	-- relief : copie rouge sombre décalée vers le bas, sous le texte
	local reliefAlerte = Style.texte(blocAlerte, {
		Name = "Relief",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, RELIEF),
		Size = UDim2.new(1, 0, 0, HAUT_TEXTE),
		Text = "ON TE VOLE !",
		TextColor3 = ROUGE_SOMBRE,
		titre = true,
		contour = 5,
		tailleMax = 112,
		ZIndex = 32,
	})
	local texteAlerte = Style.texte(blocAlerte, {
		Name = "Texte",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, HAUT_TEXTE),
		Text = "ON TE VOLE !",
		TextColor3 = BLANC,
		titre = true,
		contour = 5,
		tailleMax = 112,
		ZIndex = 33,
	})
	-- texte clair (blanc -> jaune) cerné de rouge sombre : lisible sur n'importe quel décor
	Style.degrade(texteAlerte, BLANC, Style.boutons.jaune[1])
	local contourTexteAlerte = texteAlerte:FindFirstChild("Contour")
	if contourTexteAlerte then contourTexteAlerte.Color = ROUGE_SOMBRE end

	-- plaque du voleur : ombre, fond sombre en dégradé, bordure noire, médaillon 🚨 (52 px) posé dans son bout gauche
	local LARGEUR_PLAQUE = 0.62
	local HAUT_PLAQUE = 46
	local ombrePlaque = ombrePortee(blocAlerte, {
		Name = "OmbrePlaque",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -6 + OMBRE),
		Size = UDim2.new(LARGEUR_PLAQUE, 0, 0, HAUT_PLAQUE),
		rayon = 23,
		ZIndex = 32,
	})
	local plaque = cadre(blocAlerte, {
		Name = "Plaque",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -6),
		Size = UDim2.new(LARGEUR_PLAQUE, 0, 0, HAUT_PLAQUE),
		ZIndex = 33,
	})
	for _, p in ipairs({ plaque, ombrePlaque }) do
		local c = Instance.new("UISizeConstraint")
		c.MinSize = Vector2.new(300, HAUT_PLAQUE)
		c.MaxSize = Vector2.new(540, HAUT_PLAQUE)
		c.Parent = p
	end
	Style.coins(plaque, 23)
	Style.bordure(plaque, 3)
	Style.degrade(plaque, Style.couleurs.fondHaut, Style.couleurs.fond).Name = "Fond"
	reflet(plaque, 14, 33)
	local sousAlerte = Style.texte(plaque, {
		Name = "Voleur",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 24, 0.5, 0),
		Size = UDim2.new(1, -76, 1, -10),
		Text = "",
		TextColor3 = BLANC,
		contour = 3,
		tailleMax = 30,
		ZIndex = 35,
	})
	local _, iconeAlerte = medaillon(plaque, {
		Name = "Sirene",
		taille = 52,
		icone = "🚨",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 22, 0.5, 0),
		haut = ROUGE_CLAIR,
		bas = ROUGE_VIF,
		ZIndex = 34,
	})
	local fonduAlerte = collecterFondu(blocAlerte)

	-- ===== outils communs =====
	local function horloge()
		return os.clock()
	end

	local function valide(inst)
		return inst ~= nil and typeof(inst) == "Instance" and inst.Parent ~= nil
	end

	local function detruire(inst)
		if inst then pcall(function() inst:Destroy() end) end
	end

	local function racineDe(p)
		if not p then return nil end
		local perso = p.Character
		if not perso then return nil end
		return perso:FindFirstChild("HumanoidRootPart")
	end

	local function apparitionDeMaBase()
		local index = joueur:GetAttribute("Base")
		if type(index) ~= "number" or index <= 0 then return nil end
		local bases = racine:FindFirstChild("Bases")
		if not bases then return nil end
		local base = bases:FindFirstChild("Base" .. index)
		if not base then return nil end
		return base:FindFirstChild("Apparition") or base:FindFirstChild("Sol")
	end

	local function nomEspece(id)
		if type(id) ~= "string" or id == "" then return nil end
		for _, d in ipairs(dinos:GetChildren()) do
			if d:GetAttribute("Id") == id then
				local espece = d:GetAttribute("Espece")
				if type(espece) == "string" then return espece end
			end
		end
		return nil
	end

	local function echelleDe(gui2)
		local e = gui2:FindFirstChild("Pop")
		if e and e:IsA("UIScale") then return e end
		return nil
	end

	-- ===== partie voleur : guide vers la base =====
	local attacheJoueur = nil
	local attacheBase = nil
	local faisceau = nil
	local debutPort = 0
	local porte = false
	local especePortee = nil

	local function nettoyerGuide()
		detruire(faisceau)
		detruire(attacheJoueur)
		detruire(attacheBase)
		faisceau = nil
		attacheJoueur = nil
		attacheBase = nil
	end

	local function assurerGuide()
		local hrp = racineDe(joueur)
		local cible = apparitionDeMaBase()
		if not hrp or not cible or not cible:IsA("BasePart") then
			nettoyerGuide()
			return nil, nil
		end
		if not valide(attacheJoueur) or attacheJoueur.Parent ~= hrp then
			detruire(attacheJoueur)
			attacheJoueur = Instance.new("Attachment")
			attacheJoueur.Name = "VolGuideJoueur"
			attacheJoueur.Position = Vector3.new(0, -1.5, 0)
			attacheJoueur.Parent = hrp
		end
		if not valide(attacheBase) or attacheBase.Parent ~= cible then
			detruire(attacheBase)
			attacheBase = Instance.new("Attachment")
			attacheBase.Name = "VolGuideBase"
			attacheBase.Position = Vector3.new(0, 2, 0)
			attacheBase.Parent = cible
		end
		if not valide(faisceau) then
			faisceau = Instance.new("Beam")
			faisceau.Name = "VolGuide"
			faisceau.Color = ColorSequence.new(OR_HAUT, OR_BAS)
			faisceau.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(0.8, 0.25),
				NumberSequenceKeypoint.new(1, 0.6),
			})
			faisceau.Width0 = 1.6
			faisceau.Width1 = 0.7
			faisceau.FaceCamera = true
			faisceau.LightEmission = 1
			faisceau.LightInfluence = 0
			faisceau.Segments = 12
			faisceau.CurveSize0 = 0
			faisceau.CurveSize1 = 0
			faisceau.Parent = hrp
		end
		faisceau.Attachment0 = attacheJoueur
		faisceau.Attachment1 = attacheBase
		if faisceau.Parent ~= hrp then faisceau.Parent = hrp end
		return hrp, cible
	end

	local function majPort()
		local valeur = joueur:GetAttribute("Porte")
		local maintenant = type(valeur) == "string" and valeur ~= ""
		if maintenant and not porte then
			porte = true
			debutPort = horloge()
			especePortee = nomEspece(valeur)
			infoBandeau.Text = ""
			-- entrée : fondu rapide + pop du conteneur
			if not bandeau.Visible then
				opaciteRuban = 0
				appliquerFondu(fonduRuban, 0)
			end
			bandeau.Visible = true
			vignette.Visible = true
			Style.pop(bandeau, 1.15)
			assurerGuide()
		elseif not maintenant and porte then
			-- sortie : le ruban et les bords dorés s'estompent (voir l'animation), le guide disparaît tout de suite
			porte = false
			especePortee = nil
			nettoyerGuide()
		end
	end

	-- ===== partie victime : alerte et surbrillance des voleurs =====
	local surbrillances = {} -- UserId du voleur -> Highlight
	local connus = {}        -- UserId des voleurs déjà signalés pendant le vol en cours
	local derniereAlerte = -100
	local finAlerte = 0

	local function nomDe(p)
		if not p then return "Quelqu'un" end
		local ok, nom = pcall(function() return p.DisplayName end)
		if ok and type(nom) == "string" and nom ~= "" then return nom end
		return p.Name
	end

	-- bouton Collecter du HUD : masqué pendant l'alerte. On cache ses enfants (ombre, bouton), jamais
	-- ZoneCollecte elle-même, dont le HUD gère la visibilité (dans sa Base ou non).
	local collecteMasques = {} -- enfant de ZoneCollecte -> visibilité d'origine
	local function masquerCollecte()
		local hud = gui:FindFirstChild("HUD")
		local zone = hud and hud:FindFirstChild("ZoneCollecte")
		if not zone then return end
		for _, enfant in ipairs(zone:GetChildren()) do
			if enfant:IsA("GuiObject") and collecteMasques[enfant] == nil then
				collecteMasques[enfant] = enfant.Visible
				enfant.Visible = false
			end
		end
	end
	local function reafficherCollecte()
		for enfant, visible in pairs(collecteMasques) do
			if enfant.Parent then enfant.Visible = visible end
		end
		collecteMasques = {}
	end

	local function lancerAlerte(voleur)
		local t = horloge()
		if t - derniereAlerte < ANTI_DOUBLON then
			if voleur then sousAlerte.Text = nomDe(voleur) .. " embarque ton dino !" end
			return
		end
		derniereAlerte = t
		finAlerte = t + DUREE_ALERTE
		if voleur then
			sousAlerte.Text = nomDe(voleur) .. " embarque ton dino !"
		else
			sousAlerte.Text = "Défends ta base !"
		end
		appliquerFondu(fonduAlerte, 1)
		alerte.Visible = true
		masquerCollecte()
		Style.pop(blocAlerte, 1.2)
		Bus.emettre("Son", "alerte")
	end

	local function surligner(uid)
		local existant = surbrillances[uid]
		local voleur = Players:GetPlayerByUserId(uid)
		local perso = voleur and voleur.Character
		if not perso then
			if existant then
				detruire(existant)
				surbrillances[uid] = nil
			end
			return
		end
		if valide(existant) and existant.Adornee == perso then return end
		detruire(existant)
		local h = Instance.new("Highlight")
		h.Name = "VolVoleur"
		h.FillColor = ROUGE_VIF
		h.OutlineColor = BLANC
		h.FillTransparency = 0.4
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Adornee = perso
		h.Parent = perso -- instance locale : invisible pour les autres joueurs
		surbrillances[uid] = h
	end

	local function retirerSurbrillance(uid)
		detruire(surbrillances[uid])
		surbrillances[uid] = nil
	end

	-- voleurs en cours sur MES dinos, lus sur les attributs des dinos
	local function voleursActuels()
		local liste = {}
		for _, d in ipairs(dinos:GetChildren()) do
			if d:GetAttribute("Proprietaire") == joueur.UserId then
				local uid = d:GetAttribute("Voleur")
				if type(uid) == "number" and uid ~= 0 and uid ~= joueur.UserId then
					liste[uid] = true
				end
			end
		end
		return liste
	end

	local function majVoleurs()
		local liste = voleursActuels()
		for uid in pairs(liste) do
			if not connus[uid] then
				-- vol repéré sans signal réseau (message perdu) : on alerte quand même
				connus[uid] = true
				lancerAlerte(Players:GetPlayerByUserId(uid))
			end
			surligner(uid)
		end
		for uid in pairs(connus) do
			if not liste[uid] then connus[uid] = nil end
		end
		for uid in pairs(surbrillances) do
			if not liste[uid] then retirerSurbrillance(uid) end
		end
	end

	-- ===== signaux réseau =====
	if Reseau and Reseau.Effet then
		Reseau.Effet.OnClientEvent:Connect(function(genre, position, donnees)
			if genre ~= "VolDebut" or type(donnees) ~= "table" then return end
			if donnees.victime ~= joueur.UserId then return end
			local uid = donnees.voleur
			local voleur = nil
			if type(uid) == "number" then
				voleur = Players:GetPlayerByUserId(uid)
			end
			lancerAlerte(voleur)
			if type(uid) == "number" and uid ~= joueur.UserId then
				connus[uid] = true
				surligner(uid)
			end
		end)
	end

	if Reseau and Reseau.Notification then
		Reseau.Notification.OnClientEvent:Connect(function(texte, genre)
			if genre ~= "vol" then return end
			-- seul un vol en cours déclenche l'alerte (pas l'annonce d'un vol déjà terminé)
			local liste = voleursActuels()
			local premier = nil
			for uid in pairs(liste) do
				if not premier then premier = uid end
			end
			if premier then
				connus[premier] = true
				lancerAlerte(Players:GetPlayerByUserId(premier))
				surligner(premier)
			end
		end)
	end

	-- ===== joueurs qui partent =====
	Players.PlayerRemoving:Connect(function(p)
		if not p then return end
		connus[p.UserId] = nil
		if surbrillances[p.UserId] then retirerSurbrillance(p.UserId) end
	end)

	joueur:GetAttributeChangedSignal("Porte"):Connect(majPort)
	joueur:GetAttributeChangedSignal("Base"):Connect(function()
		if porte then
			nettoyerGuide()
			assurerGuide()
		end
	end)
	joueur.CharacterAdded:Connect(function()
		if porte then
			task.delay(0.5, function()
				if porte then assurerGuide() end
			end)
		end
	end)
	majPort()

	-- ===== animations : ruban (fondu, pulsation), bords dorés, tremblement de l'alerte =====
	local derniereImage = horloge()
	RunService.Heartbeat:Connect(function(pas)
		local t = horloge()
		local dt = t - derniereImage
		if type(pas) == "number" then dt = pas end
		dt = math.clamp(dt, 0, 0.1)
		derniereImage = t

		-- ruban du porteur : entrée en fondu rapide, sortie en fondu + léger rétrécissement
		if bandeau.Visible then
			local avant = opaciteRuban
			if porte then
				opaciteRuban = math.min(1, opaciteRuban + dt / ENTREE_RUBAN)
			else
				opaciteRuban = math.max(0, opaciteRuban - dt / SORTIE_RUBAN)
			end
			if opaciteRuban ~= avant then
				appliquerFondu(fonduRuban, opaciteRuban)
			end
			if not porte then
				local pop = echelleDe(bandeau)
				if pop then pop.Scale = 0.88 + 0.12 * opaciteRuban end
			end
			local pulse = 0.5 + 0.5 * math.sin(t * 6)
			if porte then
				pulsation.Scale = 1 + 0.04 * pulse
			end
			iconeRuban.Rotation = 10 * math.sin(t * 5)
			for _, f in ipairs(bords) do
				f.BackgroundTransparency = 1 - (0.65 - 0.4 * pulse) * opaciteRuban
			end
			if not porte and opaciteRuban <= 0 then
				bandeau.Visible = false
				vignette.Visible = false
				pulsation.Scale = 1
				local pop = echelleDe(bandeau)
				if pop then pop.Scale = 1 end
			end
		end

		if alerte.Visible then
			local reste = finAlerte - t
			if reste <= 0 then
				alerte.Visible = false
				reafficherCollecte()
				texteAlerte.Position = UDim2.new(0.5, 0, 0, 0)
				texteAlerte.Rotation = 0
				reliefAlerte.Position = UDim2.new(0.5, 0, 0, RELIEF)
				reliefAlerte.Rotation = 0
				local pop = echelleDe(blocAlerte)
				if pop then pop.Scale = 1 end
			else
				local clignote = 0.5 + 0.5 * math.sin(t * 16)
				local fondu = 1
				if reste < SORTIE_ALERTE then fondu = reste / SORTIE_ALERTE end
				-- seuls les bords clignotent (aucun voile sur le HUD) ; éclair d'entrée : bords pleins 0,3 s
				local eclair = math.max(0, 1 - (t - derniereAlerte) / 0.3)
				local force = math.min(1, 0.55 + 0.45 * math.max(clignote, eclair))
				for _, f in ipairs(listeRouges) do
					f.BackgroundTransparency = 1 - force * fondu
				end
				masquerCollecte() -- au cas où le HUD vient d'afficher la zone
				-- tremblement du texte géant (le relief suit)
				local secousse = 7 * fondu
				local dx = (math.random() * 2 - 1) * secousse
				local dy = (math.random() * 2 - 1) * secousse
				local angle = (math.random() * 2 - 1) * 4 * fondu
				texteAlerte.Position = UDim2.new(0.5, dx, 0, dy)
				texteAlerte.Rotation = angle
				reliefAlerte.Position = UDim2.new(0.5, dx, 0, dy + RELIEF)
				reliefAlerte.Rotation = angle
				-- la sirène se balance
				iconeAlerte.Rotation = 14 * math.sin(t * 14)
				-- sortie : tout le bloc s'estompe et rétrécit un peu
				if reste < SORTIE_ALERTE then
					appliquerFondu(fonduAlerte, fondu)
					local pop = echelleDe(blocAlerte)
					if pop then pop.Scale = 0.9 + 0.1 * fondu end
				end
			end
		end
	end)

	-- ===== boucle de suivi =====
	while ecran.Parent do
		local ok = pcall(function()
			if porte then
				local hrp, cible = assurerGuide()
				local reste = math.max(0, math.ceil(DELAI_MAX - (horloge() - debutPort)))
				local prefixe = ""
				if especePortee then prefixe = string.upper(especePortee) .. " · " end
				if hrp and cible then
					local d = (cible.Position - hrp.Position)
					local distance = math.floor(Vector3.new(d.X, 0, d.Z).Magnitude + 0.5)
					infoBandeau.Text = prefixe .. "Suis la lumière : " .. distance .. " m · ⏱ " .. reste .. " s"
				else
					infoBandeau.Text = prefixe .. "⏱ " .. reste .. " s avant qu'il ne s'échappe !"
				end
				if reste <= 10 then
					infoBandeau.TextColor3 = BLANC
				else
					infoBandeau.TextColor3 = JAUNE
				end
			end
			majVoleurs()
		end)
		if not ok then
			-- une erreur passagère ne doit pas figer l'interface : on repart proprement
			nettoyerGuide()
		end
		task.wait(PERIODE)
	end

	-- l'écran a disparu : on range tout
	nettoyerGuide()
	for uid in pairs(surbrillances) do retirerSurbrillance(uid) end
end

return M
