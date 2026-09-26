-- Charte graphique de Dino Chapardeurs : toutes les couleurs du jeu passent par ici.
-- Jungle vive et jouet : vert = nature, orange lave = danger du volcan, or = argent, couleurs de rareté pour les dinos.
local Charte = {}

local function hex(h)
	return Color3.fromRGB(tonumber(string.sub(h, 1, 2), 16), tonumber(string.sub(h, 3, 4), 16), tonumber(string.sub(h, 5, 6), 16))
end
Charte.hex = hex

Charte.encre = hex("1B1A2E")
Charte.herbe = hex("7BC950")
Charte.jungle = hex("2F9E44")
Charte.terre = hex("C98B4F")
Charte.sable = hex("F2D49B")
Charte.creme = hex("FFF4DC")
Charte.bois = hex("8B5A2B")
Charte.pierre = hex("6B6478")
Charte.lave = hex("FF5A1F")
Charte.dore = hex("FFC933")
Charte.gemme = hex("3DD6F5")
Charte.violet = hex("9B5DE5")
Charte.alerte = hex("FF2E63")
Charte.nuit = hex("23304F")
Charte.tapis = hex("D7263D")

-- couleur de chaque rareté (étiquettes, lueurs, interface)
Charte.raretes = {
	Commun = hex("B8C0CC"),
	Rare = hex("3D9BFF"),
	Epique = hex("A35DFF"),
	Legendaire = hex("FFB020"),
	Mythique = hex("FF3D7F"),
	Divin = hex("59FFE0"),
	Secret = hex("FFFFFF"),
}
-- couleur de chaque mutation (Normal = pas de teinte)
Charte.mutations = {
	Or = hex("FFC933"),
	Diamant = hex("9FF3FF"),
	ArcEnCiel = hex("FF7AF5"),
	Lave = hex("FF5A1F"),
	Meteore = hex("3B2F5C"),
}

-- les trois teintes d'une couleur : base, ombre (x 0,8) et lumière (+ 20 % de crème)
function Charte.ombre(c)
	return Color3.new(c.R * 0.8, c.G * 0.8, c.B * 0.8)
end
function Charte.lumiere(c)
	return c:Lerp(Charte.creme, 0.2)
end

-- 1234567 -> "$1,23M" ; 950 -> "$950" (style simulateur)
local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi" }
function Charte.argent(n)
	n = tonumber(n) or 0
	local i = 1
	while math.abs(n) >= 1000 and i < #SUFFIXES do
		n = n / 1000
		i = i + 1
	end
	local texte
	if i == 1 then
		texte = tostring(math.floor(n + 0.5))
	elseif math.abs(n) >= 100 then
		texte = string.format("%d", math.floor(n))
	else
		texte = string.gsub(string.format("%.2f", n), "%.?0+$", "")
	end
	texte = string.gsub(texte, "%.", ",")
	if n < 0 then return "-$" .. string.sub(texte, 2) .. SUFFIXES[i] end
	return "$" .. texte .. SUFFIXES[i]
end

Charte.police = Enum.Font.FredokaOne
Charte.policeTexte = Enum.Font.GothamBold

return Charte
