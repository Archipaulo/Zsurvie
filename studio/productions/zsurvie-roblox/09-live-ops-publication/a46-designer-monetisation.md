## 1. Règle d'or : payer pour se montrer, jamais pour gagner

Canon §9 : les Robux n'achètent que des cosmétiques et des serveurs privés. Tout le reste en découle.

- **Jamais en vente** : Pièces, Gemmes, Recherches, améliorations d'Établi, temps de Foreuse, défense supplémentaire, PV, vitesse, réduction d'étourdissement, saut de jour, relance de run, accès aux Capsules Difficile et du Jour.
- **Rien d'aléatoire** : ni caisse, ni roue, ni œuf. On voit et on essaie exactement ce qu'on achète.
- **Rien d'intermédiaire** : prix affichés en Robux, aucune monnaie premium.
- **Aucune urgence** : ni minuteur, ni « dernière chance », ni promo limitée, ni pastille rouge sur le bouton Boutique.
- **Le mérite ne s'achète pas** : les variantes de la Galerie des Zbires (10, 100, 1 000 éliminations) et les récompenses du Défi du Jour ne sont jamais vendues.
- **Aucune pression** : ni « Tes amis l'ont déjà », ni « Demande à tes parents ». Doc Boulon ne parle jamais de la Boutique.

## 2. Catalogue de lancement

### Game passes (achat unique, permanent)

| Pass | Prix | Contenu | Justification |
|---|---|---|---|
| **Garde-robe Pixel-bloc** | 149 R$ | 4 tenues (Explorateur, Pompier, Astronaute, Pique-niqueur) et 4 teintes de Sac à dos | Premier achat type : 8 objets, soit environ 19 R$ l'objet |
| **Blasters de collection** | 199 R$ | 3 modèles : Pistolet à eau, Tromblon à confettis, Rayon rétro | Le Blaster reste à l'écran en permanence : c'est la plus forte valeur perçue |
| **Alcôve de Luxe** | 199 R$ | 3 thèmes (Serre, Garage, Observatoire) qui habillent le sol, les murs et les socles des machines de recherche | Pilier 3 : l'Alcôve est vue par les 11 autres joueurs du Laboratoire |
| **Emotes du Labo** | 99 R$ | 6 emotes : Salut, Bravo, Danse robot, Pas chassé, Bâillement, Pose héroïque | Petit prix social, jouables au Laboratoire et pendant le Répit |

### Developer products

| Produit | Prix | Contenu | Justification |
|---|---|---|---|
| **Feux d'artifice ×5** | 25 R$ | 5 tirs au-dessus de la Maison (pendant le Répit) ou de son Alcôve | Plus petit achat, plaisir collectif : toute l'équipe en profite |
| **Bonnet de Zbire** (9 produits : les 8 Zbires et le Colosse) | 49 R$ l'unité | Bonnet peluche en forme de tête de Zbire, recoloré Crème et Toit orange | Collection liée au Zbire de la Semaine : le samedi à 17 h, le mannequin de la Cabine porte le bonnet vedette. Les 9 restent en vente toute l'année |

### Serveur privé

**50 R$ par mois**, sur la place Laboratoire. Jouer seulement entre amis rassure les parents. Aucune différence de jeu : les Capsules partent vers les mêmes serveurs réservés, avec les mêmes gains.

### Bornes et chemin gratuit

- Aucun article au-dessus de 199 R$.
- Tout posséder au lancement : 646 R$ de passes + 441 R$ de bonnets = **1 087 R$** (hors Feux et serveur privé). Chaque ajout futur respecte ces bornes.
- **Chemin gratuit** dans chaque catégorie : 7 Défis du Jour réussis = 1 teinte de Sac à dos ; vaincre le 2e Colosse (Jour 10) = tenue « Vétéran » ; variantes de la Galerie.

## 3. Grille de lisibilité (tout cosmétique)

| Règle | Valeur |
|---|---|
| Stats | Le Blaster cosmétique garde les dégâts, la cadence, la portée, la hitbox et le son du Blaster de base. Seul le `Model` visuel change |
| Couleurs | `ReplicatedStorage.Charte` uniquement. Interdits sur un Survivant : Violet horde #9B5DE5, Alerte #FF2E63, Or #FFC933, Gemme cyan #33D6F0 |
| Tirs | Toujours Toit orange #EF7A2F et Crème #F6E7C1 |
| Taille | 40 cubes de 0,5 stud au maximum, 1 stud de dépassement de la silhouette au plus |
| Propriétés | `CanCollide`, `CanQuery` et `CanTouch` à false, `Massless` à true, aucune Part `Neon` |
| Thèmes d'Alcôve | 120 Parts au maximum, aucune `PointLight` ajoutée |
| Hors limites | Aucun cosmétique sur la Maison, les Zbires, le Muret, la Mini-Tourelle, le Tapis Collant ou la Roue des Pings |
| Feux d'artifice | `ParticleEmitter.Rate` 20, `Lifetime` 1,5 s, aucune `PointLight`, son chiptune `Volume` 0,4. 1 tir par joueur toutes les 15 s, jamais pendant la horde |
| Emotes | Demandées au serveur (même contrôle que `Equiper`), bloquées pendant la horde et l'étourdissement |

## 4. Placement

| Lieu | Dispositif | Règle |
|---|---|---|
| **Cabine d'Essayage** (Laboratoire) | Comptoir de 12 × 12 studs, mannequin portant le Bonnet de la Semaine, `ProximityPrompt` (`ActionText` « Essayer », `HoldDuration` 0, `MaxActivationDistance` 10) | Entre l'anneau des Alcôves et la Galerie, hors du trajet entre l'apparition et le Quai des Capsules |
| **Alcôve du joueur** | Pupitre « Thème » : aperçu gratuit des 3 thèmes sur place | Prompt visible par le seul propriétaire |
| **HUD du Laboratoire** | Bouton Boutique de 64 × 64 px, coin haut droit, icône cintre | Masqué tant que la première run n'est pas terminée |
| **Prairie** | Aucune boutique, aucun appel `Prompt…Purchase` | Seul bouton : « Feu d'artifice » (64 × 64 px) pendant le Répit, s'il reste du stock |
| **Fin de run** | Gemmes gagnées, bouton Recherches | Aucun lien vers la Boutique |

Parcours d'achat : essai gratuit et illimité sur son propre Survivant dans un `ViewportFrame`, puis bouton « Acheter » qui appelle `PromptGamePassPurchase` ou `PromptProductPurchase`. Aucun prompt automatique, jamais.

**Écart au canon :** la Cabine d'Essayage est un nouvel élément du Laboratoire, absent du §5. Elle est soumise à la validation de Victor Lanoue.

## 5. Code serveur

`ReplicatedStorage.Catalogue` (ModuleScript partagé avec l'UI) décrit passes, produits et cosmétiques. Roblox rejoue un reçu non traité à la prochaine connexion du joueur : ce script tourne donc dans **les deux places**. Le DataStore `Boutique_v1` est séparé de la sauvegarde des Gemmes.

```lua
-- ServerScriptService.Boutique (Script) : places Laboratoire ET Prairie
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalogue = require(ReplicatedStorage.Catalogue)
-- Catalogue.produits[ProductId] = { feux = 5 } ou { cosmetique = "BonnetCasque" }
-- Catalogue.passes[PassId] = { "TenueExplorateur", "SacCreme", ... }
-- Catalogue.cosmetiques[id] = { emplacement = "Tete", gratuit = false }
local store = DataStoreService:GetDataStore("Boutique_v1")
local remotes = ReplicatedStorage.Remotes
local sessions = {} -- [Player] = { possedes = {}, feux = 0 }
local dernierFeu = {}

local function modifier(userId, transformer)
	return pcall(store.UpdateAsync, store, "u_" .. userId, function(data)
		data = data or { possedes = {}, feux = 0, recus = {} }
		return transformer(data)
	end)
end

local function publier(joueur, session)
	remotes.BoutiqueMaj:FireClient(joueur, session.possedes, session.feux)
end

local function accorderPass(session, passId)
	for _, id in Catalogue.passes[passId] or {} do
		session.possedes[id] = true
	end
end

local function charger(joueur)
	local ok, data = pcall(store.GetAsync, store, "u_" .. joueur.UserId)
	data = (ok and data) or { possedes = {}, feux = 0 }
	local session = { possedes = table.clone(data.possedes), feux = data.feux }
	for passId in Catalogue.passes do
		local okPass, possede = pcall(MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService, joueur.UserId, passId)
		if okPass and possede then accorderPass(session, passId) end
	end
	if joueur.Parent then
		sessions[joueur] = session
		publier(joueur, session)
	end
end

MarketplaceService.ProcessReceipt = function(recu)
	local produit = Catalogue.produits[recu.ProductId]
	if not produit then
		warn("[Boutique] ProductId inconnu :", recu.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok, data = modifier(recu.PlayerId, function(data)
		if table.find(data.recus, recu.PurchaseId) then return data end -- déjà accordé
		if produit.feux then data.feux += produit.feux end
		if produit.cosmetique then data.possedes[produit.cosmetique] = true end
		table.insert(data.recus, recu.PurchaseId)
		if #data.recus > 50 then table.remove(data.recus, 1) end
		return data
	end)
	if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local joueur = Players:GetPlayerByUserId(recu.PlayerId)
	local session = joueur and sessions[joueur]
	if session then
		session.feux = data.feux
		for id in data.possedes do session.possedes[id] = true end
		publier(joueur, session)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(joueur, passId, achete)
	local session = sessions[joueur]
	if achete and session then
		accorderPass(session, passId)
		publier(joueur, session)
	end
end)

remotes.Equiper.OnServerEvent:Connect(function(joueur, id)
	if typeof(id) ~= "string" then return end
	local session, def = sessions[joueur], Catalogue.cosmetiques[id]
	if not session or not def then return end
	if not (def.gratuit or session.possedes[id]) then return end
	joueur:SetAttribute("Cosmetique_" .. def.emplacement, id) -- visuel seul, aucune stat
end)

remotes.LancerFeu.OnServerEvent:Connect(function(joueur)
	local session = sessions[joueur]
	if not session or session.feux <= 0 then return end
	if workspace:GetAttribute("Phase") == "Horde" then return end -- Répit ou Laboratoire
	local maintenant = os.clock()
	if maintenant - (dernierFeu[joueur] or -math.huge) < 15 then return end
	dernierFeu[joueur] = maintenant
	session.feux -= 1
	task.spawn(modifier, joueur.UserId, function(data)
		data.feux = math.max(0, data.feux - 1)
		return data
	end)
	remotes.FeuLance:FireAllClients(joueur) -- chaque client joue l'effet
end)

Players.PlayerAdded:Connect(charger)
for _, joueur in Players:GetPlayers() do task.spawn(charger, joueur) end
Players.PlayerRemoving:Connect(function(joueur)
	sessions[joueur] = nil
	dernierFeu[joueur] = nil
end)
```

## 6. Contrôle

- **Tests Studio** : achats simulés. Couper le serveur pendant `ProcessReceipt` : le reçu est rejoué sans doublon grâce au `PurchaseId`. DataStore en panne : `NotProcessedYet`, rien d'accordé ni de débité à tort.
- **Audit anti-pay-to-win à J+14** : à nombre de runs égal, l'écart du jour moyen atteint entre payeurs et non-payeurs doit rester sous 3 %. Au-delà, on cherche la fuite d'avantage.
- **Objectif** : 2 à 4 % d'acheteurs parmi les joueurs actifs du mois, zéro avis « pay-to-win ».
- **Revue** : tout nouvel article passe la grille du §3 et la validation du directeur créatif.
