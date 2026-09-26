-- Constructeur FinTapis : la « Grande Porte » par où partent les dinos invendus.
-- Porte de parc en pierre et bois avec torches, tunnel sombre creusé dans un rocher couvert de lianes,
-- enseigne « Au revoir ! » et légère brume. Le couloir du tapis (|z| <= 6) reste libre jusqu'à 12,5 de haut.
-- Emprise (CONTRAT §10) : disque r14 autour de Plan.finTapis.centre. Budget : 180 parts (gros blocs fusionnés).
local M = {}

local BUDGET = 180
local COULOIR = 6           -- demi-largeur du couloir du tapis à laisser libre
local PLAFOND_COULOIR = 12.5 -- rien sous cette hauteur au-dessus du couloir

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
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

	-- ===== couleurs =====
	local pierre = Charte.pierre
	local pierreSombre = Charte.ombre(Charte.pierre)
	local pierreClaire = Charte.lumiere(Charte.pierre)
	local bois = Charte.bois
	local boisSombre = Charte.ombre(Charte.bois)
	local noir = Charte.encre
	local liane = Charte.jungle
	local feuille = Charte.herbe
	local flamme = Charte.lave
	local or_ = Charte.dore

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
		-- une part invisible, sans collision ni requête (source de brume, de lumière) ne gêne pas
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

	-- ===== dalle pavée (sol sous la porte, ne dépasse pas 0,3) =====
	bloc(dossier, "Dalle", -1, 0.1, 0, 20, 0.2, 12, pierreClaire, true)
	bloc(dossier, "BordureN", -4, 0.1, -8, 8, 0.2, 4, pierreSombre, true)
	bloc(dossier, "BordureS", -4, 0.1, 8, 8, 0.2, 4, pierreSombre, true)

	-- ===== le rocher et son tunnel (x local de -3 à 10) =====
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		-- parois épaisses de part et d'autre du couloir
		bloc(modeleRocher, "Paroi" .. suffixe, 1.5, 6.5, s * 9.25, 9, 13, 5.5, pierre, true)
		bloc(modeleRocher, "ParoiFond" .. suffixe, 8, 6.5, s * 8, 4, 13, 3, pierreSombre, true)
		-- doublure intérieure sombre (le tunnel paraît profond)
		bloc(modeleRocher, "Ombre" .. suffixe, 3.5, 6, s * 6.35, 13, 12, 0.3, noir, false)
		-- éboulis et bosses sur les flancs
		boule(modeleRocher, "Bosse" .. suffixe, 1.5, 12, s * 9.5, 6, pierreClaire, true)
		boule(modeleRocher, "Eboulis" .. suffixe, -2.5, 1.2, s * 11.5, 2.6, pierreSombre, true)
		bloc(modeleRocher, "Saillie" .. suffixe, 4.5, 3, s * 11.5, 4, 6, 1.4, pierreSombre, true)
	end
	-- voûte (au-dessus du couloir, à partir de 13)
	bloc(modeleRocher, "Voute", 2, 14.5, 0, 10, 3, 22, pierre, true)
	bloc(modeleRocher, "VouteFond", 8.5, 14.5, 0, 3, 3, 18, pierreSombre, true)
	bloc(modeleRocher, "Sommet", 3.5, 17, 0, 9, 2, 18, pierreClaire, true)
	boule(modeleRocher, "Crete", 4, 18, 0, 8, pierre, true)
	bloc(modeleRocher, "OmbreVoute", 3.5, 12.85, 0, 13, 0.3, 12.4, noir, false)

	-- ===== la Grande Porte (x local de -6 à -3) =====
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		-- pilier de pierre (socle, fût, chapiteau, pommeau doré)
		bloc(modelePorte, "Socle" .. suffixe, -4.5, 1.25, s * 8.75, 4, 2.5, 4, pierreSombre, true)
		bloc(modelePorte, "Pilier" .. suffixe, -4.5, 9.5, s * 8.75, 3, 14, 3, pierre, true)
		bloc(modelePorte, "Bague" .. suffixe, -4.5, 8, s * 8.75, 3.4, 0.6, 3.4, pierreClaire, true)
		bloc(modelePorte, "Chapiteau" .. suffixe, -4.5, 17, s * 8.75, 4, 1, 4, pierreClaire, true)
		boule(modelePorte, "Pommeau" .. suffixe, -4.5, 18.4, s * 8.75, 1.8, or_, false)

		-- battant de bois ouvert vers l'extérieur (contre le bord du couloir, hors couloir)
		local z = s * 7.3
		bloc(modelePorte, "Battant" .. suffixe, -8.8, 4.8, z, 5.4, 9, 0.6, bois, true)
		bloc(modelePorte, "TraverseHaut" .. suffixe, -8.8, 8, z + s * 0.35, 5.4, 0.7, 0.2, boisSombre, false)
		bloc(modelePorte, "TraverseBas" .. suffixe, -8.8, 2, z + s * 0.35, 5.4, 0.7, 0.2, boisSombre, false)
		bloc(modelePorte, "Montant" .. suffixe, -11.2, 4.8, z + s * 0.35, 0.6, 9, 0.2, boisSombre, false)
		boule(modelePorte, "Anneau" .. suffixe, -10.8, 5, z + s * 0.6, 0.6, or_, false)
		-- pointes de palissade sur le battant
		for i = 0, 3 do
			bloc(modelePorte, "Pointe" .. suffixe .. i, -10.7 + i * 1.3, 9.6, z, 0.8, 0.8, 0.6, boisSombre, false)
		end
	end

	-- linteau de bois au-dessus du couloir, poutres de pierre, enseigne
	bloc(modelePorte, "Linteau", -4.5, 15.5, 0, 2, 2, 20.5, bois, true)
	bloc(modelePorte, "LinteauBas", -4.5, 14.2, 0, 2.4, 0.6, 16, boisSombre, true)
	bloc(modelePorte, "Fronton", -4.5, 17.2, 0, 1.6, 1.4, 10, pierreClaire, true)
	boule(modelePorte, "Embleme", -5.4, 17.3, 0, 2.2, or_, false)

	-- enseigne tournée vers le tapis (-X) : texte sur la face Left
	local enseigne = bloc(modelePorte, "Enseigne", -6, 13.85, 0, 0.4, 2.2, 11, Charte.creme, false)
	if enseigne then
		pcall(Outils.texte, enseigne, "Left", "Au revoir !", { couleur = Charte.encre })
		bloc(modelePorte, "CadreEnseigne", -5.65, 13.8, 0, 0.3, 2.6, 11.8, bois, false)
	end
	-- chaînes qui retiennent l'enseigne
	bloc(modelePorte, "ChaineN", -6, 14.8, -4.5, 0.2, 0.6, 0.2, pierreSombre, false)
	bloc(modelePorte, "ChaineS", -6, 14.8, 4.5, 0.2, 0.6, 0.2, pierreSombre, false)

	-- ===== torches (bois, flamme Neon, feu et lumière) =====
	local function torche(nom, dx, y, dz)
		local manche = bloc(modeleTorches, nom .. "Manche", dx, y, dz, 0.5, 2.2, 0.5, boisSombre, false)
		local coupe = bloc(modeleTorches, nom .. "Coupe", dx, y + 1.3, dz, 0.9, 0.5, 0.9, pierreSombre, false)
		local feu = bloc(modeleTorches, nom .. "Flamme", dx, y + 2, dz, 0.7, 1, 0.7, flamme, false, {
			Material = Enum.Material.Neon,
			CastShadow = false,
		})
		if feu then
			pcall(function()
				local f = Instance.new("Fire")
				f.Size = 2
				f.Heat = 6
				f.Color = Charte.lave
				f.SecondaryColor = Charte.dore
				f.Parent = feu
			end)
			pcall(Outils.lumiere, feu, { Range = 16, Brightness = 1.6, Color = Charte.dore })
			pcall(Outils.animer, feu, "pulse", 1.2)
		end
		return manche, coupe
	end
	for _, s in ipairs({ -1, 1 }) do
		local suffixe = (s < 0) and "N" or "S"
		-- sur la face avant des piliers
		bloc(modeleTorches, "Support" .. suffixe, -6.3, 10.5, s * 8.75, 0.6, 0.4, 0.6, pierreSombre, false)
		torche("TorchePilier" .. suffixe, -6.3, 11.8, s * 8.75)
		-- sur la face extérieure des piliers
		bloc(modeleTorches, "SupportExt" .. suffixe, -4.5, 10.5, s * 10.55, 0.6, 0.4, 0.6, pierreSombre, false)
		torche("TorcheExt" .. suffixe, -4.5, 11.8, s * 10.7)
	end

	-- ===== lianes qui tombent de la voûte et des parois =====
	local alea = Outils.aleatoire(128)
	local lianes = {
		{ -3.2, -11.3 }, { -3.2, -6.8 }, { -3.2, -4 }, { -3.2, -1.5 },
		{ -3.2, 1.2 }, { -3.2, 3.8 }, { -3.2, 6.8 }, { -3.2, 11.3 },
		{ 1, -12.2 }, { 4, -12.2 }, { 1, 12.2 }, { 4, 12.2 },
	}
	for i, l in ipairs(lianes) do
		local dx, dz = l[1], l[2]
		local haut = 16
		local bas
		if math.abs(dz) < COULOIR + 0.5 then
			-- au-dessus du couloir : lianes courtes qui restent hautes
			bas = PLAFOND_COULOIR + alea:NextNumber(0.2, 1.2)
		else
			bas = alea:NextNumber(2.5, 8)
		end
		local longueur = haut - bas
		local brin = bloc(modeleLianes, "Liane" .. i, dx, bas + longueur / 2, dz, 0.35, longueur, 0.35, liane, false, { CastShadow = false })
		if brin then
			bloc(modeleLianes, "Feuille" .. i, dx - 0.1, bas + 0.4, dz, 0.9, 0.8, 0.9, feuille, false, { CastShadow = false })
			if longueur > 5 then
				bloc(modeleLianes, "FeuilleMi" .. i, dx - 0.1, bas + longueur * 0.55, dz + 0.3, 0.8, 0.7, 0.8, feuille, false, { CastShadow = false })
			end
		end
	end
	-- touffes de feuillage sur le sommet du rocher
	boule(modeleLianes, "TouffeN", 0, 17.5, -7, 4, liane, false)
	boule(modeleLianes, "TouffeS", 1, 17.5, 7.5, 3.6, feuille, false)
	boule(modeleLianes, "TouffeC", -1, 17.2, 2, 3, liane, false)
	boule(modeleLianes, "TouffeArriere", 7.5, 17.5, -3, 3.2, feuille, false)

	-- ===== brume légère (dans le tunnel et devant la porte) =====
	local function brume(nom, dx, y, dz, opacite, taille)
		local source = bloc(dossier, nom, dx, y, dz, 1, 0.2, 1, noir, false, {
			Transparency = 1,
			CastShadow = false,
		})
		if not source then
			return
		end
		pcall(function()
			local fumee = Instance.new("Smoke")
			fumee.Color = Charte.creme
			fumee.Opacity = opacite
			fumee.Size = taille
			fumee.RiseVelocity = 0.6
			fumee.Parent = source
		end)
	end
	brume("BrumeTunnel", 5, 0.4, 0, 0.12, 7)
	brume("BrumeFond", 9, 0.4, 0, 0.18, 6)
	brume("BrumePorte", -6, 0.4, 0, 0.05, 5)

	-- lueur froide au fond du tunnel pour la profondeur
	local lueur = bloc(dossier, "LueurFond", 10.2, 3, 0, 0.2, 0.2, 0.2, noir, false, { Transparency = 1, CastShadow = false })
	if lueur then
		pcall(Outils.lumiere, lueur, { Range = 10, Brightness = 0.6, Color = Charte.violet })
	end

	dossier:SetAttribute("Parts", nombre)
end

return M
