-- Constructeur FinTapis : la « Grande Porte » par où partent les dinos invendus.
-- Style simulateur (STYLE.md) : porte cartoon aux couleurs vives (piliers crème, bagues dorées,
-- linteau rouge tapis, battants orange), rocher clair et arrondi, tunnel qui s'ouvre sur un portail
-- Neon violet, et un grand titre flottant « 👋 AU REVOIR ! » cerné de noir, lisible de loin.
-- Le couloir du tapis (|z| <= 6) reste libre jusqu'à 12,5 de haut.
-- Emprise (CONTRAT §10) : disque r14 autour de Plan.finTapis.centre. Budget : 140 parts (gros blocs, pas de fumée ni de feu).
local M = {}

local BUDGET = 140
local COULOIR = 6            -- demi-largeur du couloir du tapis à laisser libre
local PLAFOND_COULOIR = 12.5 -- rien sous cette hauteur au-dessus du couloir

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local Style = ctx.Style
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	-- ===== repère (Plan.finTapis, avec valeurs de secours) =====
	local reglage = Plan.finTapis or {}
	local centre = reglage.centre
	if typeof(centre) ~= "Vector3" then
		centre = Vector3.new(128, 0, 0)
	end
	local rayon = 14
	if type(reglage.rayon) == "number" and reglage.rayon > 0 then
		rayon = reglage.rayon
	end
	local cx, cz = centre.X, centre.Z
	local ySol = centre.Y

	-- ===== palette vive (monde simple et lisible) =====
	local hex = Charte.hex
	local roche = hex("B8B0CC")          -- pierre claire lavande
	local rocheClaire = hex("D9D3E8")
	local rocheOmbre = hex("8F86A8")
	local cremePilier = Charte.creme
	local or_ = Charte.dore
	local orSombre = hex("F29B00")
	local rouge = Charte.tapis
	local rougeSombre = Charte.ombre(Charte.tapis)
	local bois = hex("F0802A")           -- battants orange vif
	local boisSombre = hex("B8531A")
	local tunnel = hex("2A1F5C")         -- fond du tunnel : violet profond, pas noir
	local portail = hex("B07CFF")        -- lueur Neon au fond
	local liane = hex("3FC34A")
	local feuille = hex("6BD64A")
	local flamme = hex("FF9A1F")

	-- ===== création protégée, comptée, limitée à l'emprise =====
	local nombre = 0

	-- vrai si une boîte (dx, z locaux, demi-tailles hx, hz) tient dans le disque
	local function dansDisque(dx, dz, hx, hz)
		local ax = math.abs(dx) + hx
		local az = math.abs(dz) + hz
		return ax * ax + az * az <= rayon * rayon
	end

	-- vrai si la boîte gêne le couloir du tapis (hors dalle de sol)
	local function gene(dz, hz, yBas, yHaut)
		if yHaut <= 0.3 then
			return false -- dalle au ras du sol : on marche dessus
		end
		if math.abs(dz) - hz >= COULOIR then
			return false
		end
		return yBas < PLAFOND_COULOIR
	end

	-- props communs : décor ancré ; collision seulement pour la roche et la pierre
	local function preparer(props, solide)
		props.Anchored = true
		props.CanCollide = solide and true or false
		props.CanQuery = solide and true or false
		props.CanTouch = false
		props.CastShadow = props.CastShadow ~= false
		return props
	end

	-- bloc aligné : centre local (dx, y, dz), taille (sx, sy, sz)
	local function bloc(parent, nom, dx, y, dz, sx, sy, sz, couleur, solide, extra)
		if nombre >= BUDGET then
			return nil
		end
		if not dansDisque(dx, dz, sx / 2, sz / 2) then
			return nil
		end
		local props = extra or {}
		-- une part invisible, sans collision ni requête (ancre d'étiquette, de lumière) ne gêne pas
		if props.Transparency ~= 1 and gene(dz, sz / 2, y - sy / 2, y + sy / 2) then
			return nil
		end
		props.Name = nom
		props.Size = Vector3.new(sx, sy, sz)
		props.CFrame = CFrame.new(cx + dx, ySol + y, cz + dz)
		props.Color = couleur
		preparer(props, solide)
		local ok, part = pcall(Outils.bloc, parent, props)
		if ok and part then
			nombre = nombre + 1
			return part
		end
		return nil
	end

	-- boule : centre local (dx, y, dz), diamètre d
	local function boule(parent, nom, dx, y, dz, d, couleur, solide)
		if nombre >= BUDGET then
			return nil
		end
		if not dansDisque(dx, dz, d / 2, d / 2) then
			return nil
		end
		if gene(dz, d / 2, y - d / 2, y + d / 2) then
			return nil
		end
		local props = preparer({
			Name = nom,
			Size = Vector3.new(d, d, d),
			CFrame = CFrame.new(cx + dx, ySol + y, cz + dz),
			Color = couleur,
		}, solide)
		local ok, part = pcall(Outils.boule, parent, props)
		if ok and part then
			nombre = nombre + 1
			return part
		end
		return nil
	end

	local modelePorte = Outils.modele(dossier, "GrandePorte")
	local modeleRocher = Outils.modele(dossier, "Rocher")
	local modeleLianes = Outils.modele(dossier, "Lianes")
	local modeleTorches = Outils.modele(dossier, "Torches")

	-- ===== dalle (sol sous la porte, ne dépasse pas 0,3) : sable clair bordé de rouge =====
	bloc(dossier, "Dalle", -1, 0.1, 0, 20, 0.2, 12, Charte.sable, true)
	bloc(dossier, "BordureN", -4, 0.1, -8, 8, 0.2, 4, rouge, true)
	bloc(dossier, "BordureS", -4, 0.1, 8, 8, 0.2, 4, rouge, true)

	-- ===== le rocher et son tunnel (x local de -3 à 10) =====
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		-- parois épaisses de part et d'autre du couloir
		bloc(modeleRocher, "Paroi" .. suffixe, 1.5, 6.5, s * 9.25, 9, 13, 5.5, roche, true)
		bloc(modeleRocher, "ParoiFond" .. suffixe, 8, 6.5, s * 8, 4, 13, 3, rocheOmbre, true)
		-- doublure intérieure violette (le tunnel paraît profond sans être noir)
		bloc(modeleRocher, "Ombre" .. suffixe, 3.5, 6, s * 6.35, 13, 12, 0.3, tunnel, false)
		-- bosses arrondies et éboulis cartoon
		boule(modeleRocher, "Bosse" .. suffixe, 1.5, 12, s * 9.5, 6, rocheClaire, true)
		boule(modeleRocher, "Eboulis" .. suffixe, -2.5, 1.2, s * 11.5, 2.6, rocheOmbre, true)
		bloc(modeleRocher, "Saillie" .. suffixe, 4.5, 3, s * 11.5, 4, 6, 1.4, rocheOmbre, true)
	end
	-- voûte (au-dessus du couloir, à partir de 13)
	bloc(modeleRocher, "Voute", 2, 14.5, 0, 10, 3, 22, roche, true)
	bloc(modeleRocher, "VouteFond", 8.5, 14.5, 0, 3, 3, 18, rocheOmbre, true)
	bloc(modeleRocher, "Sommet", 3.5, 17, 0, 9, 2, 18, rocheClaire, true)
	boule(modeleRocher, "Crete", 4, 18, 0, 8, roche, true)
	bloc(modeleRocher, "OmbreVoute", 3.5, 12.85, 0, 13, 0.3, 12.4, tunnel, false)

	-- cadre de portail Neon au fond du tunnel (hors couloir : flancs et plafond) : là où « disparaissent » les dinos
	local neon = { Material = Enum.Material.Neon, CastShadow = false }
	bloc(modeleRocher, "PortailN", 8.5, 6.3, -6.1, 3, 12.4, 0.18, portail, false, { Material = neon.Material, CastShadow = false })
	bloc(modeleRocher, "PortailS", 8.5, 6.3, 6.1, 3, 12.4, 0.18, portail, false, { Material = neon.Material, CastShadow = false })
	local fond = bloc(modeleRocher, "PortailHaut", 8.5, 12.62, 0, 3, 0.16, 12.4, portail, false, neon)
	if fond then
		pcall(Outils.lumiere, fond, { Range = 14, Brightness = 1.4, Color = portail })
		pcall(Outils.animer, fond, "pulse", 0.8)
	end

	-- ===== la Grande Porte (x local de -6 à -3) =====
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		-- pilier crème : socle rouge, bague et chapiteau dorés, pommeau doré
		bloc(modelePorte, "Socle" .. suffixe, -4.5, 1.25, s * 8.75, 4, 2.5, 4, rougeSombre, true)
		bloc(modelePorte, "Pilier" .. suffixe, -4.5, 9.5, s * 8.75, 3, 14, 3, cremePilier, true)
		bloc(modelePorte, "Bague" .. suffixe, -4.5, 8, s * 8.75, 3.4, 0.8, 3.4, or_, true)
		bloc(modelePorte, "Chapiteau" .. suffixe, -4.5, 17, s * 8.75, 4, 1, 4, or_, true)
		boule(modelePorte, "Pommeau" .. suffixe, -4.5, 18.4, s * 8.75, 1.8, orSombre, false)

		-- battant orange ouvert vers l'extérieur (contre le bord du couloir, hors couloir)
		local z = s * 7.3
		bloc(modelePorte, "Battant" .. suffixe, -8.8, 4.8, z, 5.4, 9, 0.6, bois, true)
		bloc(modelePorte, "TraverseHaut" .. suffixe, -8.8, 8, z + s * 0.35, 5.4, 0.7, 0.2, boisSombre, false)
		bloc(modelePorte, "TraverseBas" .. suffixe, -8.8, 2, z + s * 0.35, 5.4, 0.7, 0.2, boisSombre, false)
		boule(modelePorte, "Anneau" .. suffixe, -10.8, 5, z + s * 0.6, 0.7, or_, false)
		-- pointes jaunes sur le battant
		for i = 0, 3 do
			bloc(modelePorte, "Pointe" .. suffixe .. i, -10.7 + i * 1.3, 9.6, z, 0.8, 0.8, 0.6, or_, false)
		end
	end

	-- linteau rouge vif au-dessus du couloir, liseré doré, fronton crème
	bloc(modelePorte, "Linteau", -4.5, 15.5, 0, 2, 2, 20.5, rouge, true)
	bloc(modelePorte, "LinteauBas", -4.5, 14.2, 0, 2.4, 0.6, 16, or_, true)
	local fronton = bloc(modelePorte, "Fronton", -4.5, 17.2, 0, 1.6, 1.4, 10, cremePilier, true)
	boule(modelePorte, "Embleme", -5.4, 17.3, 0, 2.2, or_, false)

	-- enseigne jaune tournée vers le tapis (-X) : texte blanc cerné sur la face Left
	local enseigne = bloc(modelePorte, "Enseigne", -6, 13.85, 0, 0.4, 2.2, 11, or_, false)
	if enseigne then
		local ok, etiquette = pcall(Outils.texte, enseigne, "Left", "AU REVOIR !", { couleur = Color3.new(1, 1, 1) })
		if ok and etiquette and Style then
			pcall(function()
				etiquette.Font = Style.policeTitre
				Style.contour(etiquette, 4)
			end)
		end
		bloc(modelePorte, "CadreEnseigne", -5.65, 13.8, 0, 0.3, 2.6, 11.8, rouge, false)
	end

	-- ===== grand titre flottant « 👋 AU REVOIR ! » (Style.etiquette, lisible de loin et sur mobile) =====
	local support = fronton or enseigne
	if support and Style then
		pcall(function()
			local _, textes = Style.etiquette(support, {
				{ texte = "👋 AU REVOIR !", titre = true, taille = 1.5, contour = 4, nom = "Titre" },
				{ texte = "Les dinos invendus partent ici", taille = 0.6, couleur = Style.couleurs.revenu, nom = "SousTitre" },
			}, {
				Name = "TitreGrandePorte",
				largeur = 24,
				hauteurLigne = 3,
				StudsOffset = Vector3.new(0, 4.5, 0),
				MaxDistance = 260,
			})
			if textes and textes[1] then
				local jaune = Style.boutons.jaune
				Style.degrade(textes[1], Color3.new(1, 1, 1), jaune[1])
			end
		end)
	end

	-- ===== torches (flamme Neon qui pulse, une lumière chaude ; pas d'effet Fire) =====
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		local dx, y, dz = -6.3, 11.8, s * 8.75
		bloc(modeleTorches, "Support" .. suffixe, dx, 10.5, dz, 0.6, 0.4, 0.6, boisSombre, false)
		bloc(modeleTorches, "TorchePilier" .. suffixe .. "Manche", dx, y, dz, 0.5, 2.2, 0.5, boisSombre, false)
		bloc(modeleTorches, "TorchePilier" .. suffixe .. "Coupe", dx, y + 1.3, dz, 0.9, 0.5, 0.9, or_, false)
		local feu = bloc(modeleTorches, "TorchePilier" .. suffixe .. "Flamme", dx, y + 2, dz, 0.8, 1.1, 0.8, flamme, false, {
			Material = Enum.Material.Neon,
			CastShadow = false,
		})
		if feu then
			pcall(Outils.lumiere, feu, { Range = 14, Brightness = 1.3, Color = or_ })
			pcall(Outils.animer, feu, "pulse", 1.2)
		end
	end

	-- ===== lianes vertes vives qui tombent de la voûte (moins nombreuses, plus lisibles) =====
	local alea = Outils.aleatoire(128)
	local lianes = {
		{ -3.2, -11.3 }, { -3.2, -4 }, { -3.2, 3.8 }, { -3.2, 11.3 },
		{ 1, -12.2 }, { 4, 12.2 },
	}
	for i, l in ipairs(lianes) do
		local dx, dz = l[1], l[2]
		local haut = 16
		local bas
		if math.abs(dz) < COULOIR + 0.5 then
			-- au-dessus du couloir : lianes courtes qui restent hautes
			bas = PLAFOND_COULOIR + alea:NextNumber(0.2, 1.2)
		else
			bas = alea:NextNumber(3, 8)
		end
		local longueur = haut - bas
		local brin = bloc(modeleLianes, "Liane" .. i, dx, bas + longueur / 2, dz, 0.4, longueur, 0.4, liane, false, { CastShadow = false })
		if brin then
			bloc(modeleLianes, "Feuille" .. i, dx - 0.1, bas + 0.4, dz, 1, 0.9, 1, feuille, false, { CastShadow = false })
		end
	end
	-- touffes de feuillage rondes sur le sommet du rocher
	boule(modeleLianes, "TouffeN", 0, 17.5, -7, 4, liane, false)
	boule(modeleLianes, "TouffeS", 1, 17.5, 7.5, 3.6, feuille, false)
	boule(modeleLianes, "TouffeArriere", 7.5, 17.5, -3, 3.2, feuille, false)

	dossier:SetAttribute("Parts", nombre)
end

return M
