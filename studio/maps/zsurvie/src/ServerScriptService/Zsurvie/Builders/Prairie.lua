-- Builders/Prairie.lua : sol de la Prairie (damier), chemins de terre en croix,
-- bordures en pavés, parvis d'atterrissage, touffes d'herbe et murs invisibles du bord du monde.
-- Budget : 600 parts.
local M = {}

local BUDGET = 600
local COTE_SOL = 240         -- sol carré de 240 x 240
local COTE_DALLE = 40        -- grandes dalles du damier
local EPAISSEUR_SOL = 2
local DEBUT_CHEMIN = 9
local FIN_CHEMIN = 100
local EPAISSEUR_CHEMIN = 0.2
local PAS_PAVES = 4
local HAUTEUR_PAVE = 0.4
local COTE_DALLE_PARVIS = 4
local EPAISSEUR_PARVIS = 0.4 -- dessus à Y = 0.4 (≤ 0.5)
local HAUTEUR_MUR = 40
local EPAISSEUR_MUR = 2
local TOUFFES_VISEES = 300
local ESSAIS_TOUFFES = 4000
local GRAINE = 4242

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end

	local prairie = Plan.prairie or {}
	local largeurChemin = prairie.largeurChemin or 6
	local bordMonde = prairie.bordMonde or 115
	local centre = prairie.centre or Vector3.new(0, 0, 0)
	local cx, cz = centre.X, centre.Z

	local nbParts = 0
	local function place()
		return nbParts < BUDGET
	end
	local function bloc(parent, props)
		if nbParts >= BUDGET then
			return nil
		end
		nbParts = nbParts + 1
		return Outils.bloc(parent, props)
	end

	local couleurPrairie = Charte.prairie
	local couleurPrairieClaire = Charte.lumiere(Charte.prairie)
	local couleurCreme = Charte.creme
	local couleurCremeOmbre = Charte.ombre(Charte.creme)

	-- ===== sol en damier =====
	local sol = Outils.dossier(dossier, "Sol")
	local nbDalles = math.floor(COTE_SOL / COTE_DALLE)
	local depart = -COTE_SOL / 2 + COTE_DALLE / 2
	for i = 0, nbDalles - 1 do
		for j = 0, nbDalles - 1 do
			local couleur = couleurPrairie
			if (i + j) % 2 == 1 then
				couleur = couleurPrairieClaire
			end
			bloc(sol, {
				Name = "Dalle",
				Size = Vector3.new(COTE_DALLE, EPAISSEUR_SOL, COTE_DALLE),
				CFrame = CFrame.new(cx + depart + i * COTE_DALLE, -EPAISSEUR_SOL / 2, cz + depart + j * COTE_DALLE),
				Color = couleur,
			})
		end
	end

	-- ===== parvis (utile pour éviter d'y poser des pavés) =====
	local parvis = Plan.parvis
	local function dansParvis(x, z, marge)
		if not parvis then
			return false
		end
		local demiX = parvis.taille.X / 2 + marge
		local demiZ = parvis.taille.Z / 2 + marge
		return math.abs(x - parvis.centre.X) <= demiX and math.abs(z - parvis.centre.Z) <= demiZ
	end

	-- ===== chemins de terre en croix =====
	local chemins = Outils.dossier(dossier, "Chemins")
	local longueur = FIN_CHEMIN - DEBUT_CHEMIN
	local milieu = (DEBUT_CHEMIN + FIN_CHEMIN) / 2
	-- directions : dx, dz (axe du chemin)
	local directions = {
		{ nom = "Nord", dx = 0, dz = -1 },
		{ nom = "Sud", dx = 0, dz = 1 },
		{ nom = "Est", dx = 1, dz = 0 },
		{ nom = "Ouest", dx = -1, dz = 0 },
	}
	for _, d in ipairs(directions) do
		local taille
		if d.dx == 0 then
			taille = Vector3.new(largeurChemin, EPAISSEUR_CHEMIN, longueur)
		else
			taille = Vector3.new(longueur, EPAISSEUR_CHEMIN, largeurChemin)
		end
		bloc(chemins, {
			Name = "Chemin" .. d.nom,
			Size = taille,
			CFrame = CFrame.new(cx + d.dx * milieu, EPAISSEUR_CHEMIN / 2, cz + d.dz * milieu),
			Color = Charte.terre,
		})
	end

	-- ===== parvis en dalles crème =====
	if parvis then
		local dossierParvis = Outils.dossier(dossier, "Parvis")
		local nx = math.max(1, math.floor(parvis.taille.X / COTE_DALLE_PARVIS + 0.5))
		local nz = math.max(1, math.floor(parvis.taille.Z / COTE_DALLE_PARVIS + 0.5))
		local tx = parvis.taille.X / nx
		local tz = parvis.taille.Z / nz
		local x0 = parvis.centre.X - parvis.taille.X / 2 + tx / 2
		local z0 = parvis.centre.Z - parvis.taille.Z / 2 + tz / 2
		for i = 0, nx - 1 do
			for j = 0, nz - 1 do
				local couleur = couleurCreme
				if (i + j) % 2 == 1 then
					couleur = Charte.lumiere(Charte.creme)
				end
				bloc(dossierParvis, {
					Name = "DalleParvis",
					Size = Vector3.new(tx - 0.1, EPAISSEUR_PARVIS, tz - 0.1),
					CFrame = CFrame.new(x0 + i * tx, EPAISSEUR_PARVIS / 2, z0 + j * tz),
					Color = couleur,
				})
			end
		end
	end

	-- ===== bordures de chemin en pavés =====
	local bordures = Outils.dossier(dossier, "Bordures")
	local ecart = largeurChemin / 2 + 0.6
	local rang = 0
	for _, d in ipairs(directions) do
		-- premiers pavés au-delà des sacs de sable et du perron de la Maison (jusqu'à ~11,6)
		local t = DEBUT_CHEMIN + 4
		while t <= FIN_CHEMIN - 1 and place() do
			rang = rang + 1
			local couleur = couleurCreme
			if rang % 2 == 0 then
				couleur = couleurCremeOmbre
			end
			for cote = -1, 1, 2 do
				local x, z, taille
				if d.dx == 0 then
					x = cx + cote * ecart
					z = cz + d.dz * t
					taille = Vector3.new(1.2, HAUTEUR_PAVE, 2)
				else
					x = cx + d.dx * t
					z = cz + cote * ecart
					taille = Vector3.new(2, HAUTEUR_PAVE, 1.2)
				end
				if not dansParvis(x, z, 0.5) then
					bloc(bordures, {
						Name = "Pave",
						Size = taille,
						CFrame = CFrame.new(x, HAUTEUR_PAVE / 2, z),
						Color = couleur,
					})
				end
			end
			t = t + PAS_PAVES
		end
	end

	-- ===== murs invisibles du bord du monde (réservés avant les touffes) =====
	local function murs()
		local dossierMurs = Outils.dossier(dossier, "BordMonde")
		local long = 2 * bordMonde + 2 * EPAISSEUR_MUR
		local decal = bordMonde + EPAISSEUR_MUR / 2
		local y = HAUTEUR_MUR / 2
		local defs = {
			{ "MurNord", Vector3.new(long, HAUTEUR_MUR, EPAISSEUR_MUR), Vector3.new(cx, y, cz - decal) },
			{ "MurSud", Vector3.new(long, HAUTEUR_MUR, EPAISSEUR_MUR), Vector3.new(cx, y, cz + decal) },
			{ "MurEst", Vector3.new(EPAISSEUR_MUR, HAUTEUR_MUR, long), Vector3.new(cx + decal, y, cz) },
			{ "MurOuest", Vector3.new(EPAISSEUR_MUR, HAUTEUR_MUR, long), Vector3.new(cx - decal, y, cz) },
		}
		for _, def in ipairs(defs) do
			nbParts = nbParts + 1
			Outils.bloc(dossierMurs, {
				Name = def[1],
				Size = def[2],
				CFrame = CFrame.new(def[3]),
				Transparency = 1,
				CanCollide = true,
				CastShadow = false,
				Color = couleurCreme,
			})
		end
	end
	-- 4 parts gardées pour les murs
	local reserveMurs = 4

	-- ===== touffes d'herbe (graine fixe) =====
	local zonesRondes = {}
	local function ajouterZone(p, r)
		if p and r then
			table.insert(zonesRondes, { centre = p, rayon = r })
		end
	end
	if Plan.mine then
		ajouterZone(Plan.mine.centre, (Plan.mine.rayon or 7) + 1.5)
	end
	if Plan.etabli then
		ajouterZone(Plan.etabli.centre, (Plan.etabli.rayon or 6) + 1.5)
	end
	if Plan.etang then
		ajouterZone(Plan.etang.centre, (Plan.etang.rayon or 8) + 1.5)
	end
	if Plan.pointsInteret then
		for _, p in ipairs(Plan.pointsInteret) do
			ajouterZone(p, (Plan.rayonPointInteret or 8) + 1.5)
		end
	end
	local demiMaisonX = 10
	local demiMaisonZ = 10
	if Plan.maison and Plan.maison.taille then
		demiMaisonX = Plan.maison.taille.X / 2 + 2
		demiMaisonZ = Plan.maison.taille.Z / 2 + 2
	end
	local couloir = largeurChemin / 2 + 2

	local function libre(x, z)
		local rx, rz = x - cx, z - cz
		-- couloirs des chemins (et de leurs pavés)
		if math.abs(rx) <= couloir or math.abs(rz) <= couloir then
			return false
		end
		-- Maison
		if math.abs(rx) <= demiMaisonX and math.abs(rz) <= demiMaisonZ then
			return false
		end
		if dansParvis(x, z, 1.5) then
			return false
		end
		local pos = Vector3.new(x, 0, z)
		for _, zone in ipairs(zonesRondes) do
			if Outils.distanceXZ(pos, zone.centre) <= zone.rayon then
				return false
			end
		end
		return true
	end

	local touffes = Outils.dossier(dossier, "Touffes")
	local alea = Outils.aleatoire(GRAINE)
	local limite = bordMonde - 3
	local posees = 0
	local essais = 0
	while posees < TOUFFES_VISEES and essais < ESSAIS_TOUFFES and nbParts < BUDGET - reserveMurs do
		essais = essais + 1
		local x = cx + alea:NextNumber(-limite, limite)
		local z = cz + alea:NextNumber(-limite, limite)
		if libre(x, z) then
			local taille = Vector3.new(alea:NextNumber(0.6, 1.3), alea:NextNumber(0.5, 1.2), alea:NextNumber(0.6, 1.3))
			local couleur = Charte.ombre(Charte.prairie)
			if alea:NextNumber() < 0.4 then
				couleur = couleurPrairieClaire
			end
			local p = bloc(touffes, {
				Name = "Touffe",
				Size = taille,
				CFrame = Outils.surSol(taille, x, z, alea:NextNumber(0, 90)),
				Color = couleur,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
			})
			if p then
				posees = posees + 1
			end
		end
	end

	murs()
end

return M
