# Zsurvie : effets visuels

## 1. Règles du style « Pixel-bloc »

- **Textures :** motif de 8 × 8 pixels agrandi × 8 (PNG 64 px, plus proche voisin), flipbooks de 128 px en `Grid2x2`. `Rotation` et `RotSpeed` à 0, sauf les étoiles (180°/s).
- **On rétrécit, on ne fond pas :** `Transparency` 0 et `Size` → 0 sur les 30 derniers % de vie. Seuls les nuages s'effacent.
- **`LightInfluence` 0 partout :** le code couleur tient au `ClockTime` 17,5 du Jour du Colosse. `LightEmission` 0 sur les cubes, de 0,5 à 1 sur étoiles, pièces et gemmes.
- **Taille minimale 0,5 stud**, sinon l'effet disparaît sur téléphone avec la caméra (0, 45, 28).
- **Couleurs :** Zbires = Violet horde + accent du type ; nous = Toit orange et Crème ; Or = pièces ; Gemme cyan = gemmes ; Alerte = télégraphes et Maison en danger, jamais sur un Zbire vaincu.
- **Public jeune :** ni sang ni corps qui reste, 3 flashs plein écran par seconde au plus, secousse caméra désactivable. Effets de combat ≤ 0,8 s, célébrations ≤ 2 s.

## 2. Budget (Android 3 Go, 30 FPS, 60 Zbires)

- **`Rate` ≤ 20** sur les émetteurs continus, 8 au plus dans le champ.
- **Salves `:Emit()` :** réservoir client de 300 particules/s sur mobile et 600 sur PC, × 0,5 sous 28 FPS pendant 2 s. *Précision du canon : `Rate` ne borne pas `:Emit()`, ce réservoir s'en charge.*
- **Culling :** tout effet à plus de 90 studs de la caméra est ignoré.
- **Lumière :** 0 Part `Neon` côté VFX, 3 `PointLight` sur 12, en pool.
- **Instances :** 1 Part d'ancrage client, 1 `Attachment` par effet, aucun émetteur par Zbire ni par pièce.

## 3. Textures

`cube` (carré, 1 px d'ombre), `etoile` (4 branches), `anneau` (cercle de 1 px), `nuage` (3 bosses), `plus` (croix), `trait` (dégradé en 4 marches), `piece` et `gemme` (flipbooks). Pour coucher un anneau au sol : `Orientation` `VelocityPerpendicular`, `EmissionDirection` `Top`, `Speed` 0,01.

## 4. Catalogue

P0 = lancement, P1 = bêta, P2 = après le lancement. « Emit n » = salve.

### Tir et impacts

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| C1 | Tir → flash du Blaster (prédit en local) | Emit 2, Lifetime 0,06, Speed 0, Size 1,2 → 0 | etoile · Crème, LightEmission 1 | P0 |
| C2 | Tir → traçante | `Beam` canon → impact, Width0 0,35, Width1 0,15, `FaceCamera`, 0,07 s | trait · Toit orange lumière → Crème | P0 |
| C3 | Touche → impact | Emit 5, Lifetime 0,2-0,35, Speed 10-16, Drag 8 ; modèle teinté Crème 0,06 s, écrasé × 0,8 | cube · Violet horde lumière | P0 |
| C4 | Casqué sans critique → ricochet | `VelocityParallel`, Emit 4, Lifetime 0,12, Speed 20-26, SpreadAngle 70 | trait · Ardoise lumière | P0 |
| C5 | Critique → étoile | Emit 1, Size 2,5 → 0, Lifetime 0,25, RotSpeed 180 ; + 1 anneau | etoile · Crème ; anneau Toit orange | P0 |
| C6 | Balle explosive | Emit 8 cubes, Speed 14-22, Acceleration (0, −50, 0) ; anneau Size 1 → 10 ; 3 nuages ; PointLight Range 12, 0,15 s | Toit orange, Crème ombre | P1 |
| C7 | Perforante, Mini-Tourelle | perforante : C2 avec Width0 0,5, C3 sur chaque Zbire traversé ; tourelle : C1 + C2 × 0,6 | trait · Crème | P1 |

### Zbires

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| Z1 | Mort → éclatement | étirement × 1,2 en 0,08 s, puis Emit 10 cubes, Speed 14-22, Acceleration (0, −60, 0), Lifetime 0,5-0,8 ; 2 nuages | Violet horde + accent : Doré Or, Casqué Ardoise, Gluant Violet lumière, Costaud Violet ombre | P0 |
| Z2 | Gluant → division | Z1 × 0,5 ; 2 Mini-Gluants jaillissent en arc (0,3 s), écrasés × 0,8 à l'atterrissage | Violet horde lumière | P0 |
| Z3 | Doré vaincu | Z1 teinté Or + gerbe de 6 gemmes, Speed 16 vers le haut | gemme · Gemme cyan | P0 |
| Z4 | Portail de la Lisière | Cylinder, Rate 6, Lifetime 1,2, Speed 2 ; apparition : Emit 8 cubes + anneau | Violet horde lumière | P1 |
| Z5 | Sauteur → télégraphe | disque au sol 0,6 s avant l'atterrissage (Part `Cylinder`, Transparency 0,6 → 0,2), puis Emit 6 nuages | Alerte ; Terre battue | P0 |
| Z6 | Colosse, arrivée et pas | 4 `Beam` depuis le portail géant, Width 2, `Wrap`, TextureSpeed 1, PointLight Range 30 ; chaque pas : 8 nuages + anneau Size 2 → 16, secousse 0,3 stud | Violet horde → Alerte ; Terre battue | P0 |
| Z7 | Colosse vaincu | Z1 × 4 en 3 salves espacées de 0,2 s + B3 | Violet horde, Or | P0 |

### Butin (visible du seul propriétaire)

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| B1 | Butin lâché → pièce au sol | Part 1 × 1 × 0,25 `SmoothPlastic`, rotation 180°/s, rebond élastique, sans émetteur | Or | P0 |
| B2 | Crédit serveur → aspiration | Tween 0,25 s `Quad` `In` vers le torse ; `Trail` Lifetime 0,12, WidthScale 1 → 0 ; à l'arrivée, Emit 3 étoiles | Or → Crème | P0 |
| B3 | Colosse vaincu → pluie d'or | Emit 20, Speed 18-26, SpreadAngle 30 vers le haut, Acceleration (0, −40, 0), Lifetime 1,2, `FlipbookMode` Loop | piece · Or | P0 |
| B4 | Crédit de gemmes | Emit 5, Speed 8-12, Lifetime 0,6, LightEmission 0,8 ; + anneau | gemme · Gemme cyan | P0 |
| B5 | Mine | Rate 4, Lifetime 1, Speed 1-3 ; chaque production : Emit 3 gemmes | Gemme cyan | P1 |

### Maison, défenses, Survivants

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| M1 | Maison touchée | Emit 4 cubes, Speed 8-12 ; `Highlight` unique, FillTransparency 0,6, 0,08 s | Crème, Toit orange ; Highlight Alerte | P0 |
| M2 | Réparation (bouton maintenu) | `Beam` Blaster → Maison, Width 0,6, `Wrap`, TextureSpeed 3 ; un « + » toutes les 0,25 s | Toit orange lumière | P0 |
| M3 | PV sous 66 % puis 33 % | Emit 16 cubes + 4 nuages ; ensuite fumée Rate 3, Lifetime 2 | Crème ombre ; Ardoise lumière | P1 |
| M4 | Chute de la Maison | Emit 40 cubes + 8 nuages ; anneau Size 4 → 30 ; secousse 0,6 stud, 0,5 s ; PointLight 0,3 s | Crème, Toit orange | P0 |
| M5 | Régénération | Emit 2 « + » par tick, Speed 3 | Crème | P2 |
| D1 | Pose de défense | écrasement × 0,8 puis étirement × 1,2 en 0,15 s ; Emit 8 cubes + anneau | Crème | P1 |
| D2 | Tapis Collant | Rate 2, Lifetime 0,8, Speed 1 | cube · Toit orange ombre | P1 |
| S1 | Étourdi 2 s | `LockedToPart` au-dessus de la tête, Cylinder de rayon 1,2, Rate 10, Lifetime 0,5, RotSpeed 360 | etoile · Crème | P0 |
| S2 | Achat à l'Établi | Emit 14 étoiles, Cylinder, Speed 6 vers le haut ; `Beam` colonne 1,2 s | Or → Crème | P1 |
| S3 | Roue des Pings | `Beam` vertical de 12 studs, Width 1, 4 s ; + anneau | « Colosse ! » Alerte, « Répare ! » Toit orange, « Ici ! » Crème, « Merci ! » Prairie | P1 |
| S4 | Jour franchi | Emit 20 confettis par Survivant + B4 | palette sans Alerte | P1 |

### Laboratoire

| # | Action → effet | Réglages | Texture · couleur | P |
|---|---|---|---|---|
| L1 | Capsule (3 dernières secondes, départ) | Rate 20 nuages ; départ : `Trail` Lifetime 0,5, large de 2 studs | Crème ; Gemme cyan | P1 |
| L2 | Recherche lancée | Emit 16 gemmes ; `Beam` Doc Boulon → Alcôve, 1 s | Gemme cyan | P1 |
| L3 | Récolte de la Foreuse | 3 salves de 10 gemmes, espacées de 0,3 s | Gemme cyan | P0 |

## 5. Code : du serveur à l'écran

Le serveur signale des effets **déjà validés**, par lots à 10 Hz. Seuls C1 et C2 du tireur local sont prédits, et ils ne rapportent rien.

```lua
--!strict
-- ServerScriptService/Vfx (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local vfxRapide = remotes:WaitForChild("VfxRapide") :: UnreliableRemoteEvent
local vfxImportant = remotes:WaitForChild("VfxImportant") :: RemoteEvent

local Vfx = {}
local lot: { { any } } = {}
local cumul = 0

-- code 0 : tir (arg = UserId, fin = impact) ; codes 1-11 : RAPIDES (arg = teinte)
function Vfx.signaler(code: number, position: Vector3, arg: number?, fin: Vector3?)
	if #lot < 120 then -- au-delà, on jette : c'est cosmétique
		table.insert(lot, { code, position, arg or 0, fin })
	end
end

function Vfx.important(code: number, position: Vector3)
	vfxImportant:FireAllClients(code, position)
end

RunService.Heartbeat:Connect(function(dt)
	cumul += dt
	if cumul < 0.1 then return end
	cumul = 0
	for i = 1, #lot, 20 do -- 20 par paquet : sous les 900 octets
		vfxRapide:FireAllClients(table.move(lot, i, math.min(i + 19, #lot), 1, {}))
	end
	table.clear(lot)
end)

return Vfx
```

```lua
--!strict
-- StarterPlayerScripts/VfxClient (ModuleScript) : affiche, ne décide jamais rien
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Charte = require(ReplicatedStorage:WaitForChild("Charte")) :: any
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local dossier = ReplicatedStorage:WaitForChild("VFX")

local function teinte(cle: string, hex: string): Color3
	return if typeof(Charte[cle]) == "Color3" then Charte[cle] else Color3.fromHex(hex)
end
-- 0 Violet horde, 1 Or (Doré), 2 Ardoise (Casqué), 3 Violet lumière (Gluant), 4 Violet ombre (Costaud)
local TEINTES = { [0] = teinte("VioletHorde", "9B5DE5"), teinte("Or", "FFC933"),
	teinte("Ardoise", "4A4560"), teinte("VioletHordeLumiere", "AD79DE"), teinte("VioletHordeOmbre", "7C4AB7") }
local RAPIDES = { "Impact", "Ricochet", "Critique", "Eclatement", "Explosion", "Division",
	"Atterrissage", "MaisonTouchee", "Apparition", "PasColosse", "GerbeGemmes" }
local IMPORTANTS = { "ArriveeColosse", "DefaiteColosse", "ChuteMaison", "JourFranchi" }
local SECOUSSES = { PasColosse = { 0.3, 0.2 }, ChuteMaison = { 0.6, 0.5 } }

local VfxClient = {}
VfxClient.secouer = nil :: ((number, number) -> ())? -- branché par le module caméra

local ancre = Instance.new("Part")
ancre.Anchored, ancre.CanCollide, ancre.CanQuery, ancre.CanTouch = true, false, false, false
ancre.Transparency, ancre.Name, ancre.Parent = 1, "AncreVFX", Workspace

local attaches: { [string]: Attachment } = {}
for _, g in dossier:WaitForChild("Emetteurs"):GetChildren() do
	local a = g:Clone() :: Attachment
	a.Parent = ancre
	attaches[a.Name] = a
end

local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local BUDGET = if mobile then 300 else 600 -- particules par seconde
local qualite, reserve, dtMoyen, lent, fluide = 1, BUDGET, 1 / 60, 0, 0
RunService.Heartbeat:Connect(function(dt)
	reserve = math.min(BUDGET * qualite, reserve + BUDGET * qualite * dt)
	dtMoyen += (dt - dtMoyen) * 0.1
	lent = if dtMoyen > 1 / 28 then lent + dt else 0
	fluide = if dtMoyen < 1 / 50 then fluide + dt else 0
	if lent > 2 then qualite = 0.5 elseif fluide > 5 then qualite = 1 end
end)

function VfxClient.emettre(nom: string, position: Vector3, couleur: Color3?, force: boolean?)
	local a, camera = attaches[nom], Workspace.CurrentCamera
	if not a or (not force and (position - camera.CFrame.Position).Magnitude > 90) then return end
	a.WorldPosition = position
	for _, e in a:GetChildren() do
		local n = math.max(1, math.floor(((e:GetAttribute("Nombre") :: number?) or 1) * qualite + 0.5))
		if e:IsA("ParticleEmitter") and (force or reserve >= n) then
			reserve -= n
			if couleur and e:GetAttribute("Teintable") then e.Color = ColorSequence.new(couleur) end
			e:Emit(n)
		end
	end
	local s = SECOUSSES[nom]
	if s and VfxClient.secouer then VfxClient.secouer(s[1], s[2]) end
end

local modele = dossier:WaitForChild("Tracante") :: Beam
local tracantes, prochaine = {}, 0
for i = 1, 8 do
	local a0, a1, b = Instance.new("Attachment"), Instance.new("Attachment"), modele:Clone()
	a0.Parent, a1.Parent = ancre, ancre
	b.Attachment0, b.Attachment1, b.Parent = a0, a1, ancre
	tracantes[i] = { b = b, a0 = a0, a1 = a1 }
end

function VfxClient.tracer(origine: Vector3, impact: Vector3)
	prochaine = prochaine % 8 + 1
	local t = tracantes[prochaine]
	t.a0.WorldPosition, t.a1.WorldPosition, t.b.Enabled = origine, impact, true
	task.delay(0.07, function() t.b.Enabled = false end)
end

local rapide = remotes:WaitForChild("VfxRapide") :: UnreliableRemoteEvent
rapide.OnClientEvent:Connect(function(lot: { { any } })
	for _, ev in lot do
		if ev[1] == 0 and ev[3] ~= Players.LocalPlayer.UserId then -- tir d'un coéquipier
			VfxClient.emettre("Flash", ev[2])
			VfxClient.tracer(ev[2], ev[4])
		elseif RAPIDES[ev[1]] then
			VfxClient.emettre(RAPIDES[ev[1]], ev[2], TEINTES[ev[3]])
		end
	end
end)

local important = remotes:WaitForChild("VfxImportant") :: RemoteEvent
important.OnClientEvent:Connect(function(code: number, position: Vector3)
	local nom = IMPORTANTS[code]
	if not nom then return end
	for i = 0, (if nom == "DefaiteColosse" then 2 else 0) do
		task.delay(i * 0.2, VfxClient.emettre, nom, position, nil, true)
	end
end)

return VfxClient
```

## 6. Montage dans Studio

1. `ReplicatedStorage.Remotes` : `UnreliableRemoteEvent` `VfxRapide`, `RemoteEvent` `VfxImportant`.
2. `ReplicatedStorage.VFX.Emetteurs` : un `Attachment` par nom de `RAPIDES`, `IMPORTANTS` et `Flash` ; ses `ParticleEmitter` ont `Enabled` false, `Rate` 0 et les attributs `Nombre` (l'Emit du catalogue) et `Teintable`. `VFX.Tracante` : le `Beam` C2, `Enabled` false.
3. Émetteurs continus (portails, Mine, Tapis Collant, fumée) posés dans la map ; S1 dans la tête de chaque Survivant, `Enabled` calé sur l'attribut serveur `Etourdi`.
4. Le Blaster joue `emettre("Flash", canon, nil, true)` et `tracer(canon, visee)`, puis envoie sa demande de tir.
5. Butin : `FireClient` au seul propriétaire ; B1 à B4 ne jouent qu'à ce signal.

## 7. Ordre de production

- **P0 (20 effets) :** C1-C5, Z1-Z3, Z5-Z7, B1-B4, M1, M2, M4, S1, L3.
- **Porte de validation :** Android 3 Go, 6 joueurs, 60 Zbires et le Colosse, tous les P0 actifs : ≥ 30 FPS. Sinon on baisse les attributs `Nombre` avant de toucher au gameplay.
