-- Constructeur Tapis : le grand tapis roulant rouge qui traverse le monde de la Nurserie à la Fin du tapis.
-- Style simulateur (STYLE.md §3) : bande rouge vif lisse (Charte.tapis) en segments de 16,
-- liserés et rebords sombres bien nets, grosses flèches blanches Neon qui pulsent vers la Fin du tapis.
-- Décor épuré : ni bois, ni rouleaux latéraux, ni bandes transversales.
-- Emprise (CONTRAT §10) : de Plan.tapis.debut à Plan.tapis.fin, |z| <= 7 autour de l'axe. Budget : 300 parts.
local M = {}

local BUDGET = 300           -- parts au maximum pour ce constructeur
local LONGUEUR_SEGMENT = 16  -- longueur d'un segment de bande
local PAS_FLECHE = 8         -- une flèche tous les 8 studs
local EMPRISE_LATERALE = 7   -- rien au-delà de |z| = 7
local HAUTEUR_REBORD = 1.2   -- hauteur des rebords sombres
local LARGEUR_REBORD = 1     -- épaisseur des rebords
local LARGEUR_LISERE = 0.4   -- liseré sombre sur les bords du dessus de la bande

function M.construire(ctx)
	local Charte = ctx.Charte
	local Outils = ctx.Outils
	local Plan = ctx.Plan
	local dossier = ctx.dossier
	if not (Charte and Outils and Plan and dossier) then
		return
	end
	local Style = ctx.Style

	-- ===== géométrie (Plan.tapis, avec valeurs de secours) =====
	local reglage = Plan.tapis or {}
	local debut = reglage.debut
	local fin = reglage.fin
	if typeof(debut) ~= "Vector3" then
		debut = Vector3.new(-112, 0, 0)
	end
	if typeof(fin) ~= "Vector3" then
		fin = Vector3.new(112, 0, 0)
	end
	local largeur = 10
	if type(reglage.largeur) == "number" and reglage.largeur > 0 then
		largeur = reglage.largeur
	end
	local hauteur = 0.8
	if type(reglage.hauteur) == "number" and reglage.hauteur > 0 then
		hauteur = reglage.hauteur
	end
	-- la bande et ses rebords doivent tenir dans l'emprise latérale
	largeur = math.min(largeur, (EMPRISE_LATERALE - LARGEUR_REBORD - 1) * 2)

	-- repère local : u le long du tapis (de debut vers fin), y vertical, w latéral
	local a = Vector3.new(debut.X, 0, debut.Z)
	local b = Vector3.new(fin.X, 0, fin.Z)
	local longueur = (b - a).Magnitude
	if longueur < 1 then
		return
	end
	local axe = (b - a).Unit
	local haut = Vector3.new(0, 1, 0)
	local cote = axe:Cross(haut)
	local repere = CFrame.fromMatrix(a, axe, haut, cote)
	local function cadre(u, y, w)
		return repere * CFrame.new(u, y, w)
	end

	-- ===== couleurs (charte + boîte à outils Style) =====
	local rouge = Charte.tapis
	local sombre = Charte.encre
	if Style and Style.couleurs and Style.couleurs.contour then
		sombre = Style.couleurs.contour -- même noir que les contours de l'interface
	end
	local couleurLisere = Charte.ombre(Charte.ombre(Charte.tapis))
	local blanc = Color3.new(1, 1, 1)
	if Style and Style.couleurs and Style.couleurs.texte then
		blanc = Style.couleurs.texte
	end

	-- ===== création protégée et comptée =====
	local nombre = 0
	local function creer(fabrique, parent, props)
		if nombre >= BUDGET then
			return nil
		end
		local ok, part = pcall(fabrique, parent, props)
		if ok and part then
			nombre = nombre + 1
			return part
		end
		return nil
	end
	-- décor pur : ni collision, ni requête, ni contact
	local function decor(props)
		props.CanCollide = false
		props.CanQuery = false
		props.CanTouch = false
		props.CastShadow = false
		return props
	end

	local modele = Outils.modele(dossier, "TapisRoulant")
	local bande = Outils.dossier(modele, "Bande")
	local fleches = Outils.dossier(modele, "Fleches")
	local rebords = Outils.dossier(modele, "Rebords")

	local nbSegments = math.max(1, math.ceil(longueur / LONGUEUR_SEGMENT - 0.001))
	local function bornes(i)
		local u0 = (i - 1) * LONGUEUR_SEGMENT
		local u1 = math.min(longueur, u0 + LONGUEUR_SEGMENT)
		return u0, u1 - u0
	end

	-- ===== 1. la bande rouge vif lisse, en segments de 16 =====
	for i = 1, nbSegments do
		local u0, l = bornes(i)
		if l > 0.05 then
			local segment = creer(Outils.bloc, bande, {
				Name = "Segment" .. i,
				Size = Vector3.new(l, hauteur, largeur),
				CFrame = cadre(u0 + l / 2, hauteur / 2, 0),
				Color = rouge,
				Material = Enum.Material.SmoothPlastic,
				CanCollide = true,
				CanQuery = true,
				CanTouch = false,
			})
			if segment then
				segment:SetAttribute("Segment", i)
			end
		end
	end

	-- ===== 2. bordures sombres nettes : liseré sur le dessus + rebord de chaque côté =====
	local wLisere = largeur / 2 - LARGEUR_LISERE / 2
	local wRebord = largeur / 2 + LARGEUR_REBORD / 2
	for i = 1, nbSegments do
		local u0, l = bornes(i)
		if l > 0.05 then
			for _, signe in ipairs({ 1, -1 }) do
				creer(Outils.bloc, bande, decor({
					Name = "Lisere",
					Size = Vector3.new(l, 0.04, LARGEUR_LISERE),
					CFrame = cadre(u0 + l / 2, hauteur + 0.01, signe * wLisere),
					Color = couleurLisere,
				}))
				creer(Outils.bloc, rebords, decor({
					Name = "Rebord",
					Size = Vector3.new(l, HAUTEUR_REBORD, LARGEUR_REBORD),
					CFrame = cadre(u0 + l / 2, HAUTEUR_REBORD / 2, signe * wRebord),
					Color = sombre,
				}))
			end
		end
	end

	-- butées sombres aux deux bouts, dans l'emprise (ferment proprement la bande)
	local largeurTotale = largeur + LARGEUR_REBORD * 2
	for _, u in ipairs({ 0.25, longueur - 0.25 }) do
		creer(Outils.bloc, rebords, decor({
			Name = "Butee",
			Size = Vector3.new(0.5, hauteur + 0.1, largeurTotale),
			CFrame = cadre(u, (hauteur + 0.1) / 2, 0),
			Color = sombre,
		}))
	end

	-- ===== 3. grosses flèches blanches Neon tous les 8 studs, pointant vers la Fin du tapis =====
	local nbFleches = math.floor(longueur / PAS_FLECHE)
	local demiEnvergure = math.min(2.6, largeur / 2 - LARGEUR_LISERE - 1)
	local recul = demiEnvergure * 0.9
	local epaisseurBras = 0.8
	local longueurBras = math.sqrt(recul * recul + demiEnvergure * demiEnvergure) + epaisseurBras * 0.6
	local angleBras = math.atan2(demiEnvergure, recul)
	for k = 0, nbFleches - 1 do
		local u = PAS_FLECHE / 2 + k * PAS_FLECHE
		local fleche = Outils.modele(fleches, "Fleche" .. (k + 1))
		for _, signe in ipairs({ 1, -1 }) do
			-- chaque bras relie la pointe (sur l'axe, en avant) à un coin arrière
			creer(Outils.bloc, fleche, decor({
				Name = "Bras",
				Size = Vector3.new(longueurBras, 0.08, epaisseurBras),
				CFrame = cadre(u, hauteur + 0.03, signe * demiEnvergure / 2) * CFrame.Angles(0, signe * angleBras, 0),
				Color = blanc,
				Material = Enum.Material.Neon,
			}))
		end
		pcall(Outils.animer, fleche, "pulse", 1.5)
	end

	modele:SetAttribute("Parts", nombre)
end

return M
