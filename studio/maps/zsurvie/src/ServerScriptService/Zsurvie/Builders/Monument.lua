-- Builders/Monument.lua
-- Le mot « ZSURVIE » en grandes lettres de blocs sur un socle, face à l'île.
-- Le joueur au spawn regarde vers +Z : sa droite est -X, donc les lettres progressent vers -X
-- et leur face lisible est la face -Z.
local M = {}

-- police pixel 5 x 7 (ligne 1 = haut). Le I est étroit : son point (ligne 1) est une gemme.
local POLICE = {
	Z = { "11111", "00001", "00010", "00100", "01000", "10000", "11111" },
	S = { "01111", "10000", "10000", "01110", "00001", "00001", "11110" },
	U = { "10001", "10001", "10001", "10001", "10001", "10001", "01110" },
	R = { "11110", "10001", "10001", "11110", "10100", "10010", "10001" },
	V = { "10001", "10001", "10001", "10001", "10001", "01010", "00100" },
	I = { "2", "0", "1", "1", "1", "1", "1" },
	E = { "11111", "10000", "10000", "11110", "10000", "10000", "11111" },
}
local MOT = { "Z", "S", "U", "R", "V", "I", "E" }

local BUDGET = 350
local LARGEUR_EMPRISE = 30
local PROFONDEUR_EMPRISE = 6
local CELLULE_MAX = 0.9
local PROFONDEUR_LETTRE = 1.2
local HAUTEUR_SOCLE = 1.2
local HAUTEUR_MAX = 10
local LISERE = 0.12 -- débord du liseré crème autour des lettres

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	if not (Charte and Outils and Plan and ctx.dossier) then return end
	if not (Plan.lobby and Plan.lobby.monument) then return end

	local centre = Plan.lobby.monument
	local cx, cy, cz = centre.X, centre.Y, centre.Z
	local modele = Outils.modele(ctx.dossier, "MonumentZsurvie")

	-- compteur local de parts pour respecter le budget
	local nbParts = 0
	local function bloc(props)
		if nbParts >= BUDGET then return nil end
		nbParts = nbParts + 1
		return Outils.bloc(modele, props)
	end

	-- ===== dimensions : largeur du mot en cellules (lettres + espaces d'une cellule) =====
	local colonnes = 0
	for i, lettre in ipairs(MOT) do
		colonnes = colonnes + string.len(POLICE[lettre][1])
		if i < #MOT then colonnes = colonnes + 1 end
	end
	local largeurDispo = LARGEUR_EMPRISE - 1.6
	local cellule = math.min(CELLULE_MAX, largeurDispo / colonnes)
	-- la hauteur totale (socle + 7 lignes + marge du liseré) reste sous HAUTEUR_MAX
	local celluleMaxHauteur = (HAUTEUR_MAX - HAUTEUR_SOCLE - 0.6) / 7
	if cellule > celluleMaxHauteur then cellule = celluleMaxHauteur end
	local largeurMot = colonnes * cellule

	-- ===== socle ardoise avec liseré crème =====
	local largeurSocle = math.min(LARGEUR_EMPRISE, largeurMot + 1.4)
	local profondeurSocle = PROFONDEUR_EMPRISE - 0.4
	bloc({
		Name = "Socle",
		Size = Vector3.new(largeurSocle, HAUTEUR_SOCLE - 0.2, profondeurSocle),
		CFrame = CFrame.new(cx, cy + (HAUTEUR_SOCLE - 0.2) / 2, cz),
		Color = Charte.ardoise,
	})
	bloc({
		Name = "SocleDessus",
		Size = Vector3.new(largeurSocle - 0.4, 0.2, profondeurSocle - 0.4),
		CFrame = CFrame.new(cx, cy + HAUTEUR_SOCLE - 0.1, cz),
		Color = Charte.ombre(Charte.ardoise),
	})
	-- bandes crème sur l'arête avant et l'arête arrière du socle
	local zAvantSocle = cz - profondeurSocle / 2
	local zArriereSocle = cz + profondeurSocle / 2
	bloc({
		Name = "LisereAvant",
		Size = Vector3.new(largeurSocle + 0.1, 0.25, 0.25),
		CFrame = CFrame.new(cx, cy + HAUTEUR_SOCLE - 0.2, zAvantSocle),
		Color = Charte.creme,
	})
	bloc({
		Name = "LisereArriere",
		Size = Vector3.new(largeurSocle + 0.1, 0.25, 0.25),
		CFrame = CFrame.new(cx, cy + HAUTEUR_SOCLE - 0.2, zArriereSocle),
		Color = Charte.creme,
	})

	-- ===== les lettres =====
	local zLettre = cz + 0.6 -- centre des lettres, un peu en retrait pour laisser la place aux spots
	local yBase = cy + HAUTEUR_SOCLE
	-- colonne 1 du mot (la plus à gauche pour le joueur) = X le plus grand
	local xDepart = cx + largeurMot / 2 - cellule / 2
	local couleurLettre = Charte.toit
	local gemme = nil

	-- X du centre de la colonne globale k (0 = première colonne)
	local function xColonne(k)
		return xDepart - k * cellule
	end
	-- Y du centre de la ligne r (1 = haut)
	local function yLigne(r)
		return yBase + (7 - r) * cellule + cellule / 2
	end

	local colonneMot = 0
	for _, lettre in ipairs(MOT) do
		local motif = POLICE[lettre]
		local largeurLettre = string.len(motif[1])
		local dossierLettre = Outils.modele(modele, "Lettre_" .. lettre)
		for r = 1, 7 do
			local ligne = motif[r]
			local c = 1
			while c <= largeurLettre do
				local car = string.sub(ligne, c, c)
				if car == "1" then
					-- fusionne les pixels alignés de la ligne
					local fin = c
					while fin < largeurLettre and string.sub(ligne, fin + 1, fin + 1) == "1" do
						fin = fin + 1
					end
					local n = fin - c + 1
					local x = (xColonne(colonneMot + c - 1) + xColonne(colonneMot + fin - 1)) / 2
					local y = yLigne(r)
					if nbParts + 2 <= BUDGET then
						local p = Outils.bloc(dossierLettre, {
							Name = "Pixel",
							Size = Vector3.new(n * cellule, cellule, PROFONDEUR_LETTRE),
							CFrame = CFrame.new(x, y, zLettre),
							Color = couleurLettre,
						})
						local l = Outils.bloc(dossierLettre, {
							Name = "Lisere",
							Size = Vector3.new(n * cellule + 2 * LISERE, cellule + 2 * LISERE, PROFONDEUR_LETTRE - 0.2),
							CFrame = CFrame.new(x, y, zLettre + 0.2),
							Color = Charte.creme,
						})
						p.CanCollide = true
						l.CanCollide = false
						nbParts = nbParts + 2
					end
					c = fin + 1
				elseif car == "2" then
					-- point du I : gemme néon
					if nbParts < BUDGET then
						local x = xColonne(colonneMot + c - 1)
						gemme = Outils.bloc(dossierLettre, {
							Name = "PointGemme",
							Size = Vector3.new(cellule * 1.1, cellule * 1.1, cellule * 1.1),
							CFrame = CFrame.new(x, yLigne(r), zLettre) * CFrame.Angles(0, 0, math.rad(45)),
							Color = Charte.gemme,
							Material = Enum.Material.Neon,
							CanCollide = false,
						})
						nbParts = nbParts + 1
					end
					c = c + 1
				else
					c = c + 1
				end
			end
		end
		colonneMot = colonneMot + largeurLettre + 1
	end

	if gemme then
		Outils.lumiere(gemme, { genre = "Point", Range = 8, Brightness = 1.5, Color = Charte.gemme })
		Outils.animer(gemme, "pulse", 1)
	end

	-- ===== spots lumineux posés à l'avant du socle, braqués vers les lettres =====
	local nbSpots = 5
	local cibleY = yBase + 3.5 * cellule
	for i = 1, nbSpots do
		if nbParts + 2 <= BUDGET then
			local x = cx + largeurMot / 2 - (i - 0.5) * largeurMot / nbSpots
			local base = bloc({
				Name = "SpotSocle",
				Size = Vector3.new(0.8, 0.3, 0.8),
				CFrame = CFrame.new(x, yBase + 0.15, zAvantSocle + 0.8),
				Color = Charte.encre,
			})
			local posTete = Vector3.new(x, yBase + 0.6, zAvantSocle + 0.8)
			local tete = bloc({
				Name = "SpotTete",
				Size = Vector3.new(0.5, 0.5, 0.6),
				CFrame = CFrame.lookAt(posTete, Vector3.new(x, cibleY, zLettre)),
				Color = Charte.lumiere(Charte.dore),
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
			if base and tete then
				local spot = Outils.lumiere(tete, { genre = "Spot", Range = 12, Brightness = 2, Color = Charte.lumiere(Charte.creme) })
				pcall(function()
					spot.Face = Enum.NormalId.Front
					spot.Angle = 70
				end)
			end
		end
	end

	-- pivot du modèle au centre du socle, au sol
	pcall(function()
		modele.WorldPivot = CFrame.new(cx, cy, cz)
	end)
	modele:SetAttribute("Parts", nbParts)
end

return M
