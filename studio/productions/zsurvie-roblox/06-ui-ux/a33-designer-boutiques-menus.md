## 1. Règles de navigation

- **Trois taps au maximum** entre l'écran de jeu et n'importe quelle action. La fenêtre d'achat native de Roblox n'est pas comptée : on ne peut pas la supprimer.
- **Deux niveaux au maximum** : un panneau, puis une fiche.
- **Un bouton = une icône + 1 ou 2 mots.**
- **Prix codés par couleur (Charte)** : Or #FFC933 pour les Pièces, Gemme cyan #33D6F0 pour les Gemmes, Crème #F6E7C1 avec le glyphe `utf8.char(0xE002)` pour les Robux.
- **Aucun achat en combat** : la Boutique Robux n'existe que dans la place Laboratoire. Sur la Prairie, seul l'Établi s'ouvre.
- **Une seule pop-up à la fois, et jamais pour vendre.** Pas de compte à rebours, pas de pastille rouge sur la Boutique.
- Le mot « inventaire » n'apparaît jamais à l'écran (canon §9). Les cosmétiques possédés sont rangés dans le **Vestiaire**. *Écart : c'est un nom nouveau, que Victor Lanoue doit valider.*

## 2. Arborescence

**Laboratoire (place lobby)**

HUD : Gemmes en haut à gauche, Réglages en haut à droite, et une colonne de 4 boutons de 72 × 72 px à droite.

- **Recherches** → fiche → « Lancer » (bouton à maintenir).
- **Vestiaire** → onglets Survivant / Blaster / Traînée / Alcôve → un tap équipe l'objet.
- **Boutique** → onglets Vedette / Survivant / Blaster / Traînée / Alcôve / Serveur privé → fiche → « Acheter ».
- **Défi du Jour** → les 2 modificateurs et les 150 gemmes → « Y aller » (une flèche au sol mène à la Capsule du Jour).

Hors HUD :

- **Capsule**, une fois assis : bandeau « Capsule Normale · 3/6 · départ 12 s » et bouton « Descendre ».
- **Galerie des Zbires** : un `ProximityPrompt` par figurine affiche la progression 10 / 100 / 1 000 et un bouton « Équiper » qui ouvre le Vestiaire.
- **Réglages** : Musique, Effets, Vibrations, Qualité, Taille des boutons (100 / 125 %).

**Prairie (place run)**

- HUD géré par le Designer HUD.
- **Établi** → 8 cartes → un tap achète.
- **Pause** → Réglages ou « Laboratoire » (avec confirmation).
- **Fin de run** → écran de récompense → Laboratoire.

## 3. Parcours en 3 taps

| Objectif | Tap 1 | Tap 2 | Tap 3 |
|---|---|---|---|
| Acheter une amélioration | *(à moins de 10 studs, le panneau s'ouvre seul)* | Carte | — |
| Poser un Muret | Emplacement Muret | Sol (silhouette orange si valide, rose-rouge sinon) | — |
| Envoyer un ping | Maintenir, glisser, relâcher | — | — |
| Lancer une recherche | Recherches | Nœud | Maintenir « Lancer » 0,5 s |
| Équiper une tenue | Vestiaire (rouvre le dernier onglet) | Tenue | — |
| Acheter un cosmétique | Boutique | Offre | « Acheter », puis la fenêtre Roblox |
| Récupérer la Foreuse | « Récupérer » | — | — |
| Quitter une run | Pause | Laboratoire | Confirmer |

Raccourcis PC :

- `B` Boutique, `V` Vestiaire, `R` Recherches ;
- `Q` Roue des Pings, `1` à `3` pour les défenses ;
- `Échap` ferme le panneau ouvert.

## 4. Établi (Prairie), écran de référence 844 × 390 px

- **Ouverture** : le panneau s'ouvre à 10 studs de `workspace.Etabli` au plus et se ferme au-delà de 12 studs (test client 5 fois par seconde). Le tir automatique continue pendant l'achat.
- **Panneau** :
  - `Frame` avec `Size` `UDim2.fromScale(0.6, 0.72)`, `AnchorPoint` (1, 0.5) et `Position` (0.98, 0.55) ;
  - fond Nuit labo #2A3263, `UIStroke` Encre de 4 px, coins carrés.
- **Grille** : `UIGridLayout` de 4 × 2 avec `CellSize` `UDim2.fromScale(0.24, 0.46)`, soit environ 118 × 124 px. Toute la carte sert de bouton.
- **Carte** : icône de 48 px, nom, « Niv 3/10 » et prix en Or. Un bandeau Crème « ÉQUIPE » marque Solidité, Réparation et Régénération.
- **États** :
  - abordable : Toit orange ;
  - trop cher : Ardoise #4A4560, avec « il manque 14 » ;
  - niveau maximum : Or, avec « MAX ».
- **Retours** :
  - achat réussi : écrasement × 0,8 puis étirement × 1,2 en 0,15 s, et un son de caisse 8-bit ;
  - refus : 3 secousses de 4 px et un son grave, sans texte d'erreur.
- **Achat d'équipe** : tous les Survivants voient « Léa a amélioré Solidité (Niv 4) » pendant 2 s.

## 5. Arbre des Recherches (Laboratoire)

- **Organisation** : `ScrollingFrame` horizontal en plein écran, avec 3 branches :
  - **Maison** : Tourelle de toit… ;
  - **Blaster** : Balles perforantes, Visée critique… ;
  - **Mine** : Foreuse….
- **Nœuds** : 96 × 96 px. Trois états :
  - verrouillé : Ardoise et cadenas ;
  - abordable : bord cyan qui pulse à 1 Hz ;
  - acquis : Crème et coche Or.
- **Fiche** à droite, sur 35 % de la largeur :
  - effet chiffré en une ligne et passage « Niv 1 → 2 » ;
  - prix en cyan ;
  - bouton « Lancer » de 280 × 72 px, **à maintenir 0,5 s**. Il protège les Gemmes permanentes sans ajouter d'écran.
- **Accès** : bouton du HUD ou `ProximityPrompt` de l'Arbre physique.

## 6. Boutique (Robux, Laboratoire uniquement)

- **Onglets** verticaux de 72 px. L'onglet Vedette présente 4 offres renouvelées chaque samedi à 17 h avec le Zbire de la Semaine, sans compte à rebours.
- **Grille** de 3 × 2 cartes de 150 × 130 px. La mention « Possédé » remplace le prix des objets déjà achetés.
- **Fiche** :
  - un `ViewportFrame` de 260 × 260 px, où le Survivant tourne sur lui-même ;
  - un seul `ViewportFrame` actif à la fois, pour tenir sur l'Android 3 Go ;
  - un bouton Crème « Acheter » de 280 × 72 px, qui devient « Équiper » si l'objet est possédé.
- **Serveur privé** : aucune API Roblox ne permet de déclencher cet achat. L'onglet montre un guide en 3 images (« Page du jeu → Serveurs → Créer »). C'est la seule exception assumée à la règle des 3 taps.
- **Interdits** : aucun objet aléatoire, aucun pack de Gemmes, aucune amélioration payante.
- **Déclenchement de l'achat** : le client envoie `DemandeAchatCosmetique`. Le serveur vérifie que le joueur ne possède pas déjà l'objet, puis appelle `PromptProductPurchase`.

## 7. Vestiaire (les cosmétiques possédés)

- **Mise en page** : un `ViewportFrame` à gauche (40 % de la largeur) et une grille de 4 colonnes de cartes de 96 px à droite.
- **Équiper** : un tap suffit. Le serveur vérifie la possession, puis réplique l'apparence.
- **États** :
  - possédé : Crème ;
  - à gagner à la Galerie : cadenas Violet horde, avec la progression (« 87/100 Rapides ») ;
  - en Boutique : prix en Robux. Un tap ouvre la fiche de la Boutique.
- **Variantes de la Galerie** : elles s'exposent dans l'Alcôve. *Interprétation du canon, à valider.*

## 8. Écrans de récompense

| Moment | Format | Durée | Action |
|---|---|---|---|
| Jour franchi | Bandeau « Jour 6 franchi ! +12 » en cyan | 2,5 s | aucune |
| Colosse vaincu | Bandeau et confettis en cubes (`Rate` 20) | 3 s | aucune |
| Arrivée au Labo | Carte « La Foreuse a creusé 64 gemmes » | jusqu'au tap | « Récupérer » |
| Recherche lancée | Travelling de caméra vers l'Alcôve, la machine apparaît avec l'effet élastique | 2 s | « Passer » |
| Palier de la Galerie | Petit message avec la nouvelle variante | 3 s | « Équiper » |
| Achat Robux | Carte « Merci ! » avec aperçu | jusqu'au tap | « Équiper » |

**Fin de run**, en trois temps :

1. **0 à 1 s** : la Maison éclate en cubes, sans écran noir.
2. **1 à 3,5 s** : panneau « La Maison a tenu 12 jours ! » (jamais « Défaite »), avec un badge Or « Nouveau record ! » le cas échéant.
   - Les gemmes sont détaillées par source : Mine, Dorés, Jours franchis, Défi du Jour.
   - Chaque compteur défile en 1,2 s.
   - La mention « Déjà sauvegardé » rassure le joueur.
3. **Ensuite** : les 3 barres de la Galerie les plus proches d'un palier, et un seul bouton « Laboratoire » de 320 × 80 px. Le retour est automatique au bout de 20 s.

**Données** : le serveur envoie le récapitulatif par le `RemoteEvent` `RecapRun`.

**Arrivée au Laboratoire** : les cartes passent dans une file stricte, Foreuse puis Défi du Jour.

## 9. Code serveur

```lua
-- ServerScriptService/Etabli.server.lua (place Prairie)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local demande = ReplicatedStorage.Remotes:WaitForChild("AcheterAmelioration") :: RemoteFunction
local etabli = workspace:WaitForChild("Etabli") :: Model

local PORTEE_MAX, DELAI_MIN, CROISSANCE = 14, 0.25, 1.45
local CATALOGUE = { -- prix provisoires, à valider par l'économie
	Degats = { base = 20, max = 10 }, Cadence = { base = 20, max = 10 },
	Portee = { base = 15, max = 8 }, Butin = { base = 25, max = 8 },
	BallesExplosives = { base = 60, max = 5 },
	Solidite = { base = 30, max = 10, equipe = true },
	Reparation = { base = 15, max = 10, equipe = true },
	Regeneration = { base = 35, max = 8, equipe = true },
}
local dernierAchat: { [Player]: number } = {}

demande.OnServerInvoke = function(joueur: Player, id: unknown)
	if typeof(id) ~= "string" or not CATALOGUE[id] then
		return false, "inconnu"
	end
	local maintenant = os.clock()
	if maintenant - (dernierAchat[joueur] or 0) < DELAI_MIN then
		return false, "trop_vite"
	end
	local perso = joueur.Character
	local racine = perso and perso:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not racine or (racine.Position - etabli:GetPivot().Position).Magnitude > PORTEE_MAX then
		return false, "trop_loin"
	end
	local fiche = CATALOGUE[id]
	local porteur: Instance = if fiche.equipe then workspace else joueur
	local niveau = porteur:GetAttribute("Niv_" .. id) or 0
	if niveau >= fiche.max then
		return false, "max"
	end
	local cout = math.floor(fiche.base * CROISSANCE ^ niveau + 0.5)
	local solde = joueur:GetAttribute("Pieces") or 0
	if solde < cout then
		return false, "pieces"
	end
	dernierAchat[joueur] = maintenant
	joueur:SetAttribute("Pieces", solde - cout)
	porteur:SetAttribute("Niv_" .. id, niveau + 1) -- lu par l'UI, le Blaster et la Maison
	return true, niveau + 1
end

Players.PlayerRemoving:Connect(function(joueur)
	dernierAchat[joueur] = nil
end)
```

```lua
-- ServerScriptService/Boutique.server.lua (place Laboratoire)
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local store = DataStoreService:GetDataStore("Cosmetiques_v1")
local demandeAchat = ReplicatedStorage.Remotes:WaitForChild("DemandeAchatCosmetique") :: RemoteEvent
local OFFRES = { Tenue_Apicultrice = 1111, Blaster_Arcade = 2222 } -- ProductId réels à saisir
local PRODUITS = {}
for offre, produitId in OFFRES do
	PRODUITS[produitId] = offre
end

demandeAchat.OnServerEvent:Connect(function(joueur: Player, offre: unknown)
	if typeof(offre) ~= "string" or not OFFRES[offre] then return end
	if joueur:GetAttribute("Possede_" .. offre) then return end
	MarketplaceService:PromptProductPurchase(joueur, OFFRES[offre])
end)

MarketplaceService.ProcessReceipt = function(recu)
	local offre = PRODUITS[recu.ProductId]
	if not offre then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok = pcall(function()
		store:UpdateAsync(tostring(recu.PlayerId), function(donnees)
			donnees = donnees or { possede = {}, recus = {} }
			if not donnees.recus[recu.PurchaseId] then -- idempotence
				donnees.recus[recu.PurchaseId] = true
				donnees.possede[offre] = true
			end
			return donnees
		end)
	end)
	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local joueur = Players:GetPlayerByUserId(recu.PlayerId)
	if joueur then
		joueur:SetAttribute("Possede_" .. offre, true)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

## 10. Réglages communs

- **`ScreenGui`** : `IgnoreGuiInset` true, `ResetOnSpawn` false, `ScreenInsets` `DeviceSafeInsets`.
- **Échelle** : `UIScale.Scale = math.clamp(ViewportSize.Y / 390, 1, 1.6)`.
- **Texte** : police `Enum.Font.FredokaOne`, taille de 16 px au minimum.
- **Boutons** : 60 px au minimum, 72 px sur les HUD.
- **Animations** : `TweenInfo.new(0.15, Enum.EasingStyle.Back)`.
- **Couleurs** : lues uniquement dans `ReplicatedStorage.Charte`.
