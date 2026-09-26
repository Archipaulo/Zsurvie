-- Charte graphique de Zsurvie : toutes les couleurs du jeu passent par ici.
-- Violet = ennemi, orange et crème = à nous, or = pièces, cyan = gemmes, rose-rouge = danger.
local Charte = {}

local function hex(h)
	return Color3.fromRGB(tonumber(string.sub(h, 1, 2), 16), tonumber(string.sub(h, 3, 4), 16), tonumber(string.sub(h, 5, 6), 16))
end

Charte.encre = hex("1E1B2E")
Charte.prairie = hex("6CC24A")
Charte.terre = hex("C8894F")
Charte.creme = hex("F6E7C1")
Charte.toit = hex("EF7A2F")
Charte.dore = hex("FFC933")
Charte.gemme = hex("33D6F0")
Charte.violet = hex("9B5DE5")
Charte.alerte = hex("FF2E63")
Charte.nuitLabo = hex("2A3263")
Charte.ardoise = hex("4A4560")

-- les trois teintes d'une couleur : base, ombre (x 0,8) et lumière (+ 20 % de crème)
function Charte.ombre(c)
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end
function Charte.lumiere(c)
	return c:Lerp(Charte.creme, 0.2)
end

Charte.police = Enum.Font.FredokaOne
Charte.policeTexte = Enum.Font.GothamBold

return Charte
