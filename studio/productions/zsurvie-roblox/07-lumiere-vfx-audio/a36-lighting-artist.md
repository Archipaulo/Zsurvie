## 1. Principes

- **Prairie : `ShadowMap`**, seul le soleil projette une ombre. **Laboratoire : `ShadowMap`** aussi, avec `Shadows = false` partout (§6). `Technology` se règle dans Studio, jamais par script.
- **Aucune information de jeu ne passe par une ombre ou un halo.** En qualité basse, Roblox coupe les ombres et le Bloom : la lisibilité repose sur la Charte et le contraste.
- **12 sources par place, tous types confondus.** *Écart assumé : le canon ne plafonne que les `PointLight`.* Aucun script ne crée de lumière en cours de partie.

## 2. Un seul écrivain : `AmbianceClient`

| Script (agent) | Rôle sur la Prairie |
|---|---|
| `AmbianceClient` (a36) | Seul à écrire dans `Lighting`, `Atmosphere`, `CCPrairie`, `Bloom` et `workspace.Lumieres`. Publie `Qualite` |
| `MeteoClient` (a18) | Lit `EtatRun.MeteoEtat` et appelle `definirMeteo(etat)` |
| `AmbianceBiomes` (a20) | Lit `EtatRun.EtatPrairie` et appelle `definirBiome(etat)` |
| `CycleCiel` (a19) | Retiré de la Prairie. La nuit express ne revient qu'en variante A/B, en vague 2 |
| VFX (a37) | Emprunte une réserve avec `flash(position, couleur, priorite)` |
| Musique (a40) | Lance l'intro de 8 s de la piste Colosse sur le même changement de `JourColosse` |

- **`ClockTime` 14 fixe, en horde comme au Répit.** Au début du Répit qui précède le Jour du Colosse, le serveur passe `JourColosse` à true : fondu sinusoïdal de 8 s vers 17,5. Au Répit suivant, le même fondu ramène à 14.
- `definirMeteo` et `definirBiome` reçoivent un `Modificateur` (écarts bornés, voir `BORNES`), ou nil pour revenir à la base. `ClockTime` n'en fait jamais partie.
- **0,2 ms au plus au MicroProfiler** (étiquette `AmbianceClient`). Le Heartbeat ne fait que compter les images. Tout le reste tourne à 10 Hz et n'écrit que les valeurs qui changent.
- **`Qualite`**, attribut du `LocalPlayer` lu par a18 et a37, suit la moyenne glissante des FPS sur 3 s. Il passe à `"Legere"` après 2 s sous 27 FPS et revient à `"Normale"` après 10 s au-dessus de 45. En mode léger : Bloom coupé, `Haze` à 0, 1 seule lumière animée, pas de pic de la Mine.

## 3. Prairie

La caméra ne voit jamais le ciel. Régler `GeographicLatitude` pour que `GetSunDirection().Z` soit ≥ 0,3 à 14 h et ≥ 0 à 17,5 h : le soleil vient du côté caméra.

| Propriété | Jour (horde, Répit) | Jour du Colosse |
|---|---|---|
| `ClockTime` / `Brightness` | 14 / 2,5 | 17,5 / 2 |
| `OutdoorAmbient` / `ColorShift_Top` | (150, 140, 165) / Crème | (140, 110, 170) / Toit orange |
| `Atmosphere` Density / Haze / Color | 0,25 / 0,5 / Crème | 0,32 / 1 / Toit orange |
| `CCPrairie` Saturation / TintColor | 0,15 / (255, 250, 240) | 0,2 / (255, 232, 215) |

Valeurs fixes, réglées dans Studio : `Ambient` (108, 101, 115), `ColorShift_Bottom` (83, 86, 118), `EnvironmentDiffuseScale` 0,4, `EnvironmentSpecularScale` 0,15, `ShadowSoftness` 0,15, `Contrast` 0,05, `Bloom` 0,4 / 16 / 1,4. Ni `SunRays`, ni `DepthOfField`, ni `Blur`.

### Les 12 sources de `workspace.Lumieres`

Chaque ancre est une Part `Anchored`, `Transparency` 1, avec `CanCollide`, `CanQuery`, `CanTouch` et `CastShadow` à false. Elle contient une lumière nommée `Lumiere`, `Shadows = false`. **Toute autre lumière sur la Prairie est un bug.**

| Ancre | Origine | Lumière | Brightness | Range |
|---|---|---|---|---|
| `MaisonInterieur` | lampe intérieure a22 | PointLight Crème ; Alerte sous 25 % des PV | 1,2 ; 0,8 sous 60 % ; de 0,6 à 1,6 à 1 Hz sous 25 % | 14 |
| `Porche` | lanterne a20, au-dessus de la porte | PointLight Toit orange lumière | 2 | 16 |
| `Mine` | a36 | PointLight Gemme cyan | 1,5 ; pic à 3 sur 0,3 s par gemme | 12 |
| `Etabli` | une des PointLight Or de a21 | PointLight Or | 1 ; 3 au Répit | 14 |
| `Portail1` à `Portail4` | kit de 4 PointLight a23 | PointLight Violet horde, à 2 studs du sol | 1 ; 3 dans les 3 s avant la horde | 16 |
| `Colosse` | a36, suit `Torse` | PointLight Alerte | 2 | 20 |
| `Reserve1` à `Reserve3` | a36 | PointLight, `Enabled` false | 3 puis 0 en 0,2 s | 10 |

- **Portails :** 8 modèles, `workspace.Portails.P1` à `P8`, à 80 studs du centre et espacés de 45°. Chaque jour, le serveur publie `EtatRun.PortailsActifs` (par exemple `"2,4,6,8"`, dans l'ordre d'ouverture). Les 4 halos vont aux 4 premiers portails de la liste. *L'hypothèse de 4 portails à 82 studs est retirée.*
- **Lumières animées :** 2 à la fois au plus, rafraîchies à 10 Hz. Priorité : Maison en alerte, puis Colosse (3), Balle explosive (2), Doré ou jour franchi (1), Mine (0). Un effet refusé joue sans lumière. Une source attend 0,35 s avant de repartir, ce qui interdit tout clignotement au-dessus de 3 Hz. L'Établi et les portails changent par paliers.
- **Zbires :** ni lumière ni Neon, sauf le Colosse (4 Neon).
- **150 Neon :** Maison 6, Mine 12, portails 32 (4 × 8), Établi 4, défenses 18, Tourelle de toit 2, Colosse 4, lanternes de chemin 16, réserve 56.

### Ombres et disques

- `CastShadow = false` sur **toutes** les Parts des 61 Zbires, Colosse compris. Idem pour les pièces, les gemmes, les cubes d'éclatement, les projectiles et le décor de moins de 2 studs. Dans la Lisière, seul le feuillage projette une ombre.
- **Disque `Sol`**, compté dans les 30 Parts du Volant et du Sauteur : Cylinder de `Size` (0,1 ; D ; D), D valant 80 % de l'emprise, tourné de 90° sur Z. Il est Encre, `SmoothPlastic`, opaque, sans ombre, collision ni requête, à 0,05 stud du sol. Celui du Volant reste sous lui. Celui du Sauteur glisse vers l'attribut serveur `Atterrissage`.

## 4. `AmbianceClient`

```lua
-- ModuleScript StarterPlayer.StarterPlayerScripts.AmbianceClient (place Prairie)
-- Démarré par le LocalScript voisin AmbianceDemarrage : require(script.Parent.AmbianceClient)
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Charte = require(ReplicatedStorage:WaitForChild("Charte"))
local etat = ReplicatedStorage:WaitForChild("EtatRun")
local dossier = workspace:WaitForChild("Lumieres")
local portails = workspace:WaitForChild("Portails")
local zbires = workspace:WaitForChild("Zbires")
local atmo, cc = Lighting:WaitForChild("Atmosphere"), Lighting:WaitForChild("CCPrairie")
local bloom = Lighting:WaitForChild("Bloom")

export type Modificateur = { Brightness: number?, Density: number?, Haze: number?,
	Saturation: number?, TintColor: Color3?, duree: number? }

local AmbianceClient = {}
local CIBLES = { ClockTime = Lighting, Brightness = Lighting, ColorShift_Top = Lighting,
	OutdoorAmbient = Lighting, Density = atmo, Haze = atmo, Color = atmo, Saturation = cc, TintColor = cc }
local BASES = {
	Jour = { ClockTime = 14, Brightness = 2.5, ColorShift_Top = Charte.Creme,
		OutdoorAmbient = Color3.fromRGB(150, 140, 165), Density = 0.25, Haze = 0.5,
		Color = Charte.Creme, Saturation = 0.15, TintColor = Color3.fromRGB(255, 250, 240) },
	Colosse = { ClockTime = 17.5, Brightness = 2, ColorShift_Top = Charte.ToitOrange,
		OutdoorAmbient = Color3.fromRGB(140, 110, 170), Density = 0.32, Haze = 1,
		Color = Charte.ToitOrange, Saturation = 0.2, TintColor = Color3.fromRGB(255, 232, 215) },
}
-- Cumul météo + biome borné. ClockTime n'est jamais modifiable.
local BORNES = { Brightness = { -0.5, 0 }, Density = { 0, 0.1 }, Haze = { 0, 0.5 }, Saturation = { -0.1, 0.05 } }
local modifs: { [string]: Modificateur } = { meteo = {}, biome = {} }
local leger = false
local courant, debut, cible, t0, duree = {}, {}, {}, 0, -1

local function ecrire(objet: any, prop: string, valeur: any)
	if objet[prop] ~= valeur then
		objet[prop] = valeur
	end
end

local function calculerCible()
	local c = table.clone(BASES[if etat:GetAttribute("JourColosse") then "Colosse" else "Jour"])
	for cle, b in BORNES do
		c[cle] += math.clamp((modifs.meteo[cle] or 0) + (modifs.biome[cle] or 0), b[1], b[2])
	end
	for _, m in modifs do
		if m.TintColor then c.TintColor = c.TintColor:Lerp(m.TintColor, 0.3) end
	end
	return c
end

local function appliquer(v)
	for prop, objet in CIBLES do
		ecrire(objet, prop, if prop == "Haze" and leger then 0 else v[prop])
	end
	ecrire(bloom, "Enabled", not leger)
end

local function lancerFondu(d: number) -- ne raccourcit jamais un fondu en cours
	local restant = if duree > 0 then t0 + duree - os.clock() else 0
	debut, cible, t0, duree = table.clone(courant), calculerCible(), os.clock(), math.max(d, restant)
end

local function lumiere(nom: string): Light
	return dossier:WaitForChild(nom):WaitForChild("Lumiere")
end
local maison, mine, etabli = lumiere("MaisonInterieur"), lumiere("Mine"), lumiere("Etabli")
local ancreColosse = dossier:WaitForChild("Colosse")
local halos, reserves = {}, {}
for i = 1, 4 do halos[i] = dossier:WaitForChild("Portail" .. i) end
for i = 1, 3 do reserves[i] = lumiere("Reserve" .. i) end

local actives, departs = {}, {}

local function arreter(l: Light)
	local a = actives[l]
	actives[l] = nil
	if a.base == 0 then l.Enabled = false else l.Brightness = a.base end
end

local function animer(l: Light, priorite: number, d: number, pic: number, base: number): boolean
	local maintenant = os.clock()
	if maintenant - (departs[l] or 0) < 0.35 then return false end -- jamais plus de 3 Hz
	local n, pire = 0, nil
	for autre, a in actives do
		n += 1
		if not pire or a.priorite < actives[pire].priorite then pire = autre end
	end
	if n >= (if leger then 1 else 2) then
		if actives[pire].priorite >= priorite then return false end
		arreter(pire)
	end
	departs[l] = maintenant
	actives[l] = { priorite = priorite, debut = maintenant, fin = maintenant + d, pic = pic, base = base }
	l.Enabled, l.Brightness = true, pic
	return true
end

local function majMaison()
	local pv = etat:GetAttribute("PVMaison") or 1
	ecrire(maison, "Color", if pv < 0.25 then Charte.Alerte else Charte.Creme)
	if pv < 0.25 then
		if not actives[maison] then animer(maison, 4, math.huge, 1.1, 1.1) end
	else
		if actives[maison] then arreter(maison) end
		ecrire(maison, "Brightness", if pv < 0.6 then 0.8 else 1.2)
	end
end

local function placerHalos()
	local actifs = string.split(etat:GetAttribute("PortailsActifs") or "", ",")
	for i, ancre in halos do
		local modele = portails:FindFirstChild("P" .. (actifs[i] or ""))
		ancre.Lumiere.Enabled = modele ~= nil
		if modele then ancre.CFrame = modele:GetPivot() * CFrame.new(0, 2, 0) end
	end
end

local seaux, iSeau, images, cumul, sous, dessus = table.create(30, 6), 1, 0, 0, 0, 0

local function majQualite()
	seaux[iSeau] = images
	iSeau = iSeau % 30 + 1
	images = 0
	local total = 0
	for _, n in seaux do total += n end
	local fps = total / 3 -- 30 seaux de 0,1 s
	sous = if fps < 27 then sous + 1 else 0
	dessus = if fps > 45 then dessus + 1 else 0
	if (not leger and sous >= 20) or (leger and dessus >= 100) then
		leger = not leger
		Players.LocalPlayer:SetAttribute("Qualite", if leger then "Legere" else "Normale")
		appliquer(courant)
		for l, a in actives do
			if leger and a.priorite < 4 then arreter(l) end
		end
	end
end

local function tick()
	debug.profilebegin("AmbianceClient")
	local maintenant = os.clock()
	majQualite()
	if duree >= 0 then
		local p = if duree == 0 then 1 else math.min((maintenant - t0) / duree, 1)
		local x = (1 - math.cos(math.pi * p)) / 2
		for cle, v in cible do
			courant[cle] = if typeof(v) == "Color3" then debut[cle]:Lerp(v, x) else debut[cle] + (v - debut[cle]) * x
		end
		appliquer(courant)
		if p >= 1 then duree = -1 end
	end
	for l, a in actives do
		if maintenant >= a.fin then
			arreter(l)
		elseif a.priorite == 4 then -- Maison : pulsation douce à 1 Hz
			ecrire(l, "Brightness", a.base + 0.5 * math.sin((maintenant - a.debut) * 2 * math.pi))
		else -- flash : descente linéaire du pic vers la base
			ecrire(l, "Brightness", a.pic + (a.base - a.pic) * (maintenant - a.debut) / (a.fin - a.debut))
		end
	end
	local repit = etat:GetAttribute("Phase") == "Repit"
	local annonce = repit and (etat:GetAttribute("FinPhase") or 0) - workspace:GetServerTimeNow() <= 3
	ecrire(etabli, "Brightness", if repit then 3 else 1)
	for _, ancre in halos do ecrire(ancre.Lumiere, "Brightness", if annonce then 3 else 1) end
	local colosse = zbires:FindFirstChild("Colosse")
	local torse = colosse and colosse:FindFirstChild("Torse")
	ecrire(ancreColosse.Lumiere, "Enabled", torse ~= nil)
	if torse then ecrire(ancreColosse, "CFrame", torse.CFrame) end
	debug.profileend()
end

local function modifier(cle: string, m: Modificateur?)
	modifs[cle] = m or {}
	lancerFondu(if m and m.duree then m.duree else 4)
end
function AmbianceClient.definirMeteo(m: Modificateur?) modifier("meteo", m) end
function AmbianceClient.definirBiome(m: Modificateur?) modifier("biome", m) end

-- priorite : 3 Colosse, 2 Balle explosive, 1 Doré ou jour franchi. false : pas de lumière.
function AmbianceClient.flash(position: Vector3, couleur: Color3, priorite: number): boolean
	for _, l in reserves do
		if not actives[l] and animer(l, priorite, 0.2, 3, 0) then
			l.Color = couleur
			l.Parent.CFrame = CFrame.new(position)
			return true
		end
	end
	return false
end

etat:GetAttributeChangedSignal("JourColosse"):Connect(function() lancerFondu(8) end) -- intro a40 sur le même signal
etat:GetAttributeChangedSignal("PVMaison"):Connect(majMaison)
etat:GetAttributeChangedSignal("PortailsActifs"):Connect(placerHalos)
etat:GetAttributeChangedSignal("GemmesMine"):Connect(function()
	if not leger then animer(mine, 0, 0.3, 3, 1.5) end
end)
RunService.Heartbeat:Connect(function(dt)
	images += 1
	cumul += dt
	if cumul >= 0.1 then
		cumul = math.min(cumul - 0.1, 0.1)
		tick()
	end
end)

courant = calculerCible()
appliquer(courant)
majMaison()
placerHalos()
Players.LocalPlayer:SetAttribute("Qualite", "Normale")
return AmbianceClient
```

## 5. Tests de la Prairie

- **MicroProfiler** (Ctrl+F6) sur l'Android 3 Go : `AmbianceClient` à 0,2 ms au plus, fondu du Colosse compris. Au moins 30 FPS avec 6 joueurs, 60 Zbires et le Colosse, aux niveaux graphiques 1, 4 et 10.
- **Audit client** en Test à 6 joueurs : 0 `Light` hors de `workspace.Lumieres`, 0 `Shadows` à true, 0 Part de `workspace.Zbires` avec `CastShadow` à true, 150 Neon au plus.
- Brider à 20 FPS pendant 3 s doit faire passer `Qualite` à `"Legere"`. Le fondu du Colosse et l'intro de a40 démarrent avec moins de 0,1 s d'écart.
- Au niveau 1, capturer chaque Zbire, les disques `Sol` et les 3 états de la Maison. « Record : Jour X » a `LightInfluence` à 0.

## 6. Laboratoire

`ShadowMap`, `Shadows = false` sur les 12 sources, réglages statiques. Seul le LocalScript `LumieresLabo` anime, avec les mêmes règles : 10 Hz, 2 lumières à la fois, jamais plus de 3 Hz. **`Future`** seulement si un test à 12 joueurs sur l'Android 3 Go (60 s au Quai pendant un départ) mesure au moins 30 FPS. `Shadows` reste alors à false.

Réglages : `ClockTime` 21, `Brightness` 0,5, `Ambient` (83, 86, 118), `OutdoorAmbient` (42, 50, 99), `EnvironmentDiffuseScale` 0,2, `EnvironmentSpecularScale` 0,5, `Bloom` 0,8 / 24 / 1, `ColorCorrection` Saturation 0,2, Contrast 0,08, Tint (240, 250, 255). `Sky` : `StarCount` 800, `CelestialBodiesShown` false. Pas d'`Atmosphere`.

| Source | Nb | Ancre | Lumière | Réglages |
|---|---|---|---|---|
| Arbre des Recherches | 1 | a36 | PointLight Gemme cyan | 2, Range 24 |
| Doc Boulon | 1 | lampe de a22 | SpotLight zénithal Crème | 2, Range 16, 50° |
| Anneau des Alcôves | 4 | kit a23, 1 pour 3 Alcôves | PointLight Crème lumière | 1,2, Range 16 |
| Capsules | 3 | a36 | SpotLight : Toit orange (Normale), Alerte (Difficile), Gemme cyan (du Jour) | 2 ; 1 Hz au décompte, 2 Hz les 5 dernières s |
| Galerie des Zbires | 2 | a36 | SurfaceLight Crème | 1,5, Range 12, 90° |
| Réserve Foreuse | 1 | a36 | PointLight Gemme cyan, locale | flash de 0,3 s |

- *Écart : la fin du décompte des Capsules passe de 3 à 2 Hz, pour garder une marge sous le plafond.* Si les 3 Capsules décomptent en même temps, celle qui partira en dernier reste fixe.
- Les néons du Quai sont Crème : la Capsule du Jour, cyan, ressort.
- **150 Neon :** machines de recherche 48, bordures d'Alcôves 24, Arbre 16, Quai 12, Galerie 8, décor cyan 30, réserve 12.
