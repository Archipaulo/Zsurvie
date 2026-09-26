-- Emplacement Roblox : ReplicatedStorage > ModuleScript « Charte » (Package AutoUpdate, Laboratoire et Prairie)
-- Charte Pixel-bloc de Zsurvie : seule source des couleurs, de l'interface et des ambiances.
-- Chargement unique : require(game:GetService("ReplicatedStorage"):WaitForChild("Charte"))
export type Variante = "Base" | "Ombre" | "Lumiere"

local Couleurs = {
	Encre = Color3.fromHex("1E1B2E"),
	Prairie = Color3.fromHex("6CC24A"),
	TerreBattue = Color3.fromHex("C8894F"),
	Creme = Color3.fromHex("F6E7C1"),
	ToitOrange = Color3.fromHex("EF7A2F"),
	Or = Color3.fromHex("FFC933"),
	GemmeCyan = Color3.fromHex("33D6F0"),
	VioletHorde = Color3.fromHex("9B5DE5"),
	Alerte = Color3.fromHex("FF2E63"),
	NuitLabo = Color3.fromHex("2A3263"),
	Ardoise = Color3.fromHex("4A4560"),
}

-- 33 teintes : ombre = base × 0,8 ; lumière = base:Lerp(Creme, 0.2)
local teintes = {}
for nom, base in Couleurs do
	teintes[nom] = {
		Base = base,
		Ombre = Color3.new(base.R * 0.8, base.G * 0.8, base.B * 0.8),
		Lumiere = base:Lerp(Couleurs.Creme, 0.2),
	}
end

local function teinte(nom: string, variante: Variante): Color3
	local c = teintes[nom] and teintes[nom][variante]
	if not c then
		error(("Charte.teinte : %s/%s inconnue"):format(tostring(nom), tostring(variante)), 2)
	end
	return c
end

-- Interface : valeurs tenues par a31
local Interface = {
	BoutonMin = 60, -- px, minimum canon sur téléphone
	Fond = teinte("NuitLabo", "Base"),
	Panneau = teinte("Creme", "Base"),
	Texte = teinte("Encre", "Base"),
	Action = teinte("ToitOrange", "Base"),
	ActionAppui = teinte("ToitOrange", "Ombre"),
	Pieces = teinte("Or", "Base"),
	Gemmes = teinte("GemmeCyan", "Base"),
	Danger = teinte("Alerte", "Base"),
}

-- Ambiances : propriétés de Lighting appliquées telles quelles ; caméras Scriptable levées
local Ambiances = {
	Laboratoire = {
		ClockTime = 0,
		Brightness = 1,
		Ambient = teinte("NuitLabo", "Lumiere"),
		OutdoorAmbient = teinte("NuitLabo", "Base"),
	},
	Cameras = {
		Prairie = { Decalage = Vector3.new(0, 45, 28), FieldOfView = 50 }, -- canon
		Colosse = { Decalage = Vector3.new(0, 56, 35), FieldOfView = 50 }, -- + 25 % le Jour du Colosse
	},
}

-- Gel récursif ; lire une clé absente (une ancienne API par exemple) lève une erreur explicite
local function geler(t: { [any]: any }, chemin: string)
	for cle, v in t do
		if type(v) == "table" then geler(v, chemin .. "." .. tostring(cle)) end
	end
	setmetatable(t, {
		__index = function(_, cle)
			error(("%s.%s n'existe pas"):format(chemin, tostring(cle)), 2)
		end,
	})
	return table.freeze(t)
end

return geler({ Couleurs = Couleurs, teinte = teinte, Interface = Interface, Ambiances = Ambiances }, "Charte")
