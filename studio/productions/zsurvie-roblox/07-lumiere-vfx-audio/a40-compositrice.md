# Musique de Zsurvie

## 1. Règles musicales

- **Palette** : chiptune 4 canaux (2 pulses, triangle, bruit) + **1 pad triangle filtré** très doux, passe-bas à 8 kHz au mastering. **Écart au canon « chiptune 8-bit »** : ce 5e canal et ce filtre évitent la fatigue des ondes carrées après une heure. À valider par Victor Lanoue.
- **Motif Zsurvie** : Ré–La–Si–La (croche, croche, noire, blanche), transposé partout : fanfare au Laboratoire, ligne de basse dans la horde, tuba mineur pour le Colosse, berceuse au Bilan.
- **La musique est une horloge** : une horde dure 80 s, sa piste aussi. Aux mesures 37 à 40, une cloche sonne à chaque mesure : le Répit arrive dans 8 s.
- **Le danger ajoute des notes, il n'assombrit jamais** : ni drone grave, ni battement de cœur, ni silence brutal (label Léger).
- **Mobile d'abord** : un haut-parleur de téléphone ne rend rien sous 200 Hz, donc chaque basse est doublée à l'octave (pulse 25 %). Mélodie entre Do4 et Do6 ; au-dessus de 1,5 kHz, place aux pièces et aux gemmes. Sans le son, le chrono de l'UI double la cloche.
- **Budget** : 3 voix musicales au maximum (2 couches + 1 jingle) sur les 16 sons simultanés ; 13 restent aux effets.
- **Zones de run** : Prairie, Lisière, Maison et Mine partagent la piste de horde (la caméra voit toute l'arène) ; Mine et portails vivent par leurs sons 3D.

## 2. Catalogue des pistes

Tous les `Sound` sont dans `SoundService.Pistes`, `SoundGroup` = `SoundService.Musique`.

| Piste | Zone / état | BPM | Tonalité | Durée | Lecture | `Volume` |
|---|---|---|---|---|---|---|
| `Labo_Base` | Laboratoire, tout le lobby | 96 | Ré maj. | 80 s (32 mes.) | `Looped` | 0,45 |
| `Labo_Quai` | couche Quai des Capsules : arpèges de gare | 96 | Ré maj. | 80 s | calée sur la base | 0,30 |
| `Labo_Galerie` | couche Galerie des Zbires : boîte à musique | 96 | Ré maj. | 80 s | calée sur la base | 0,30 |
| `Capsule` | compte à rebours de 15 s | 128 | Ré → La | 15 s (8 mes.) | une fois | 0,50 |
| `HordeA_Base` / `_Tension` | jours 1-4, « Pique-nique » | 120 | Sol maj. | 80 s (40 mes.) | relancée chaque jour | 0,45 / 0,35 |
| `HordeB_…` | jours 6-9, « Grabuge » | 120 | Mi min. | 80 s | idem | 0,45 / 0,35 |
| `HordeC_…` | jours 11+, « Chaos », charley en doubles croches | 120 | Sol mixolydien | 80 s | idem | 0,45 / 0,35 |
| `Repit` | fanfare 2,5 s, accalmie, roulement « 3-2-1 » | 96 | Sol maj. | 15 s (6 mes.) | une fois | 0,40 |
| `Colosse` | Jour du Colosse : marche de tuba comique | 120 | Do min. | 68 s | `LoopRegion` 4–68 s | 0,50 |
| `Bilan` | gemmes gagnées | 96 | Ré maj. | 40 s (16 mes.) | `Looped` | 0,40 |
| `JIN_ColosseVaincu` | Colosse vaincu | 120 | Do maj. | 5 s | jingle | 0,60 |
| `JIN_Record` | nouveau « Record : Jour X » | 120 | Sol maj. | 3 s | jingle | 0,60 |
| `JIN_MaisonTombe` | « wah-wah » descendant, comique | 80 | Sol → Ré | 5 s | jingle | 0,55 |
| `MOT_<Zbire>` × 8 | signature de chaque Zbire, 3D mono | 96 | Ré maj. | 5 s (2 mes.) | ponctuel | 0,40 |

**Horde (40 mesures)** : A (8) – B (8) – A' (8) – Pont sans mélodie (8) – Final (8, motif en canon + cloche). `_Base` et `_Tension` ont la même longueur à l'échantillon près.

**Rendez-vous** :
- Jours 5, 10, 15… : `Colosse` remplace la horde ; son intro de 4 s accompagne le passage à `ClockTime` 17,5 (`PlaybackRegionsEnabled` true, `LoopRegion` `NumberRange.new(4, 68)`).
- Capsule du Jour : la variante est décalée de 5 jours (B dès le jour 1) pour que le Défi du Jour sonne neuf.
- Zbire de la Semaine : `MOT_<vedette>` ouvre le compte à rebours, puis sonne une fois par jour à sa première apparition.

**Export** : OGG Vorbis 44,1 kHz, stéréo (mono pour `MOT_`), -16 LUFS intégrés (jingles -14), crête -1 dBTP, boucles coupées à l'échantillon, queue de réverbération repliée au début. Upload au nom du groupe propriétaire de l'expérience, sinon l'audio reste muet en jeu. Mémoire audio visée < 15 Mo par place.

## 3. Tenir une heure sans lasser

- Aucune boucle n'est entendue plus de 4 fois de suite : A aux jours 1-4, Colosse, B, Colosse, puis C.
- Le pont sans mélodie laisse l'oreille respirer 16 s par jour.
- La couche Tension n'arrive que quand ça chauffe : deux jours ne sonnent jamais pareil.
- Laboratoire : toutes les 3 boucles (4 min), `Labo_Base` s'efface en 3 s pendant 30 s ; les néons et les machines des Alcôves prennent le relais.

## 4. Transitions

| De → vers | Méthode | Durée |
|---|---|---|
| Labo ↔ Quai / Galerie | fondu de la couche, calée sur `Labo_Base.TimePosition` | 1,5 s |
| Figurine à moins de 8 studs | `MOT_` 3D (`RollOffMinDistance` 4, `RollOffMaxDistance` 14), une fois toutes les 10 s | — |
| Entrée en Capsule | `Labo_Base` à 0,1, `Capsule` démarre au temps restant | 1 s |
| Répit → Horde | coupe franche sur le temps 1 après « 3-2-1 » | 0 s |
| Horde → Répit | cadence finale, fanfare du `Repit` | 0,3 s |
| Tension ON / OFF | fondu | 2 s / 4 s |
| Jingle | couches à × 0,45 puis retour | 0,1 s / 0,8 s |
| Maison tombée | silence, `JIN_MaisonTombe`, puis `Bilan` | 0,2 s + 5 s |
| Survivant étourdi | « tournis » local : `PitchShiftSoundEffect.Octave` 0,94 + `EqualizerSoundEffect.HighGain` -10 dB | 2 s |
| Retour au Laboratoire | `Labo_Base` en fondu d'entrée | 2 s |

## 5. Mixage

- `SoundService.Musique` : `Volume` 0,6 × réglage du joueur. Enfants : `Tournis` (`PitchShiftSoundEffect`, `Octave` 0,94, `Enabled` false) et `Etouffe` (`EqualizerSoundEffect`, `HighGain` -10, `Enabled` false).
- `SoundService.Effets` 0,8 et `SoundService.Interface` 0,7 : la musique reste environ 6 dB sous les tirs.
- Réglage « Musique » : 5 crans (0 à 100 %), boutons de 60 px. Le serveur borne la valeur entre 0 et 1 avant de la sauvegarder.
- Validation sur l'Android 3 Go de référence, haut-parleur à 50 % puis casque.

## 6. Pilotage : le serveur décide, le client joue

Le serveur pose l'état en attributs de `Workspace` ; chaque client se cale sur `GetServerTimeNow()`. Pour la Maison tombée : `phase("Silence")`, `jingle("JIN_MaisonTombe")`, puis `phase("Bilan")` 5 s plus tard.

```lua
-- ServerScriptService.Run.EtatMusical (ModuleScript, place Prairie)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EtatMusical = {}
local evenementJingle = Instance.new("RemoteEvent")
evenementJingle.Name = "Jingle"
evenementJingle.Parent = ReplicatedStorage
local tensionDepuis = 0

-- etat : "Horde" | "Repit" | "Colosse" | "Bilan" | "Silence" ; bonus = 5 pour la Capsule du Jour
function EtatMusical.phase(etat: string, jour: number, bonus: number?)
	local rang = jour + (bonus or 0)
	workspace:SetAttribute("Variante", if rang <= 4 then "A" elseif rang <= 9 then "B" else "C")
	workspace:SetAttribute("DebutPhase", workspace:GetServerTimeNow())
	workspace:SetAttribute("EtatMusique", etat) -- en dernier : c'est lui que les clients écoutent
end

-- Appelée 10 fois par seconde par la boucle des Zbires
function EtatMusical.tension(nbZbires: number, ratioPvMaison: number)
	local active = workspace:GetAttribute("Tension") == true
	if not active and (nbZbires >= 40 or ratioPvMaison < 0.35) then
		tensionDepuis = os.clock()
		workspace:SetAttribute("Tension", true)
	elseif active and nbZbires <= 25 and ratioPvMaison >= 0.45 and os.clock() - tensionDepuis >= 8 then
		workspace:SetAttribute("Tension", false)
	end
end

function EtatMusical.jingle(nom: string)
	evenementJingle:FireAllClients(nom)
end

return EtatMusical
```

```lua
-- StarterPlayer.StarterPlayerScripts.Musique (LocalScript, Laboratoire et Prairie)
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local joueur = Players.LocalPlayer
local groupe = SoundService:WaitForChild("Musique")
local pistes = SoundService:WaitForChild("Pistes")
local tournis = groupe:WaitForChild("Tournis") :: PitchShiftSoundEffect
local etouffe = groupe:WaitForChild("Etouffe") :: EqualizerSoundEffect
local VOLUME = { Base = 0.45, Tension = 0.35, Couche = 0.30, Repit = 0.40, Colosse = 0.50, Bilan = 0.40 }
local canaux, cibles, tweens = {}, {}, {}

task.spawn(ContentProvider.PreloadAsync, ContentProvider, pistes:GetChildren())

local function fondre(son: Sound, cible: number, duree: number, arreter: boolean?)
	if tweens[son] then tweens[son]:Cancel() end
	local tween = TweenService:Create(son, TweenInfo.new(duree, Enum.EasingStyle.Sine), { Volume = cible })
	tweens[son] = tween
	tween.Completed:Once(function(etat)
		if arreter and etat == Enum.PlaybackState.Completed then son:Stop() end
	end)
	tween:Play()
end

local function jouer(canal: string, nom: string?, volume: number, position: number, duree: number)
	local ancien = canaux[canal]
	local son = if nom then pistes:FindFirstChild(nom) :: Sound? else nil
	if son == ancien and (son == nil or son.IsPlaying) then return end
	if ancien then fondre(ancien, 0, duree, true) end
	canaux[canal], cibles[canal] = son, volume
	if not son then return end
	if son.TimeLength > 0 then
		son.TimePosition = if son.Looped then position % son.TimeLength else math.min(position, son.TimeLength)
	end
	if not son.IsPlaying then
		son.Volume = 0
		son:Play()
	end
	fondre(son, volume, duree)
end

local function majTension()
	local horde = workspace:GetAttribute("EtatMusique") == "Horde"
	local actif = horde and workspace:GetAttribute("Tension") == true
	local base = canaux.principal
	jouer("couche", if actif then `Horde{workspace:GetAttribute("Variante")}_Tension` else nil,
		VOLUME.Tension, if base then base.TimePosition else 0, if actif then 2 elseif horde then 4 else 0.3)
end

local function surEtat()
	local etat = workspace:GetAttribute("EtatMusique") or "Silence"
	local debut = workspace:GetAttribute("DebutPhase") or workspace:GetServerTimeNow()
	local nom = if etat == "Horde" then `Horde{workspace:GetAttribute("Variante")}_Base`
		elseif etat == "Silence" then nil
		else etat
	jouer("principal", nom, VOLUME[if etat == "Horde" then "Base" else etat] or 0,
		workspace:GetServerTimeNow() - debut, 0.3)
	majTension()
end

joueur:GetAttributeChangedSignal("Etourdi"):Connect(function()
	local etourdi = joueur:GetAttribute("Etourdi") == true
	tournis.Enabled = etourdi
	etouffe.Enabled = etourdi
end)

local zones = workspace:FindFirstChild("ZonesAudio") -- Parts invisibles « Quai » et « Galerie », Laboratoire seulement

local function zoneDuJoueur(): string?
	local racine = joueur.Character and joueur.Character:FindFirstChild("HumanoidRootPart")
	if not racine then return nil end
	for _, zone in zones:GetChildren() do
		local p, d = zone.CFrame:PointToObjectSpace(racine.Position), zone.Size / 2
		if math.abs(p.X) <= d.X and math.abs(p.Y) <= d.Y and math.abs(p.Z) <= d.Z then
			return `Labo_{zone.Name}`
		end
	end
	return nil
end

if zones then
	jouer("principal", "Labo_Base", VOLUME.Base, 0, 2)
	local base = canaux.principal
	local pauseJusqua, volumeBase = 0, VOLUME.Base
	base.DidLoop:Connect(function(_, boucles: number)
		if boucles % 3 == 0 then pauseJusqua = os.clock() + 33 end
	end)
	while true do
		task.wait(0.5)
		local depart = joueur:GetAttribute("DepartCapsule") -- heure serveur du départ, posée par le serveur
		local enPause = depart == nil and os.clock() < pauseJusqua
		local voulu = if depart then 0.1 elseif enPause then 0 else VOLUME.Base
		if voulu ~= volumeBase then
			volumeBase = voulu
			fondre(base, voulu, if depart then 1 else 3)
		end
		if depart then
			jouer("couche", "Capsule", 0.5, 15 - (depart - workspace:GetServerTimeNow()), 1)
		else
			jouer("couche", if enPause then nil else zoneDuJoueur(), VOLUME.Couche, base.TimePosition, 1.5)
		end
	end
else
	local evenementJingle = ReplicatedStorage:WaitForChild("Jingle") :: RemoteEvent
	evenementJingle.OnClientEvent:Connect(function(nom: string)
		local jingle = pistes:FindFirstChild(nom) :: Sound?
		if not jingle then return end
		for canal, son in canaux do fondre(son, cibles[canal] * 0.45, 0.1) end
		jingle:Play()
		task.delay(math.max(jingle.TimeLength, 1), function()
			for canal, son in canaux do fondre(son, cibles[canal], 0.8) end
		end)
	end)
	workspace:GetAttributeChangedSignal("EtatMusique"):Connect(surEtat)
	workspace:GetAttributeChangedSignal("Tension"):Connect(majTension)
	surEtat()
end
```
