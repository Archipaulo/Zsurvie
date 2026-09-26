# Zsurvie : plan de production

*Sonia Verne (a02), productrice. Version du 26/09/2026. Le détail des 45 tâches (T01 à T45) est dans `a02-plan-de-production.json`.*

## 1. Décisions de production

- **Lancement de la v1.0 : vendredi 20 novembre 2026.** Je ne confirme pas le 16 octobre. Les 473 tâches proposées représentent environ 1 170 jours-personne bruts (S = 1 j, M = 3 j, L = 6 j), soit environ 950 après dédoublonnage. Le chemin critique, du Plan à la performance, demande à lui seul 7 semaines.
- **Dédoublonnage :** les 7 greybox proposées pour la Prairie deviennent une seule (T09). Les tâches supprimées par les arbitrages ne sont pas planifiées : HudController (a32), Horde.Portails (a14), AcheterAmelioration (a33), CycleCiel sur la Prairie (a19), forêts de a20 et a21, boucles SoundService (a20), stores Boutique_v1 et Cosmetiques_v1.
- **Correction :** le tableur v2 de a07 prend Dégâts niveau 1 à 25 Pièces, et non 10.
- **Après le lancement :** la v1.1 sort le 01/12 avec l'Avent de Doc Boulon (sous réserve de l'accord de Victor Lanoue) et les peluches de a22. La v1.2 sort en janvier avec le Grand Givre et les traductions ES et PT-BR. La Nuit des Citrouilles tombe avant le lancement, elle est reportée à 2027.

## 2. Jalons

| Jalon | Date | Critères de validation |
|---|---|---|
| J0 Canon et contrats gelés | ven. 02/10 | Victor Lanoue a répondu par écrit à chaque écart bloquant. Plan v1 et Charte publiés le 29/09. Catalogue, ZbiresDefs.Jours, Config.Mouvement, Reseau, EtatRun et schéma v2 versionnés. Maquettes des 8 écrans validées |
| J1 Greybox jouable | ven. 09/10 | Aller-retour par Teleport entre les 2 places. Auditeur à 0 bloquant, 6 500 Parts statiques au plus, CountCells() = 0. Caméra (0, 45, 28) validée depuis 12 points. Playtest interne à 6 sur les jours 1 à 3 |
| J2 Alpha : run complète | ven. 23/10 | Arrivée → Horde → Répit jusqu'au Colosse du J5 à 7:20. 8 Zbires (modèles provisoires admis), Établi et 3 défenses. Gemmes créditées une seule fois. 1re recherche achetée au Laboratoire. Partie à 6 clients. 1re mesure sur l'Android 3 Go |
| Revue de coupe | ven. 30/10 | Tout contenu de T34 qui n'est pas jouable passe en v1.1 |
| J3 Contenu complet | ven. 06/11 | Phases 3 et 4 closes. 10 types de Zbires finaux. Onboarding jusqu'à PremiereRecherche. Défi du Jour, Foreuse, Capsules et boutique en place. Entonnoir de 12 étapes visible. Assets uploadés et modérés |
| J4 Gel et bêta fermée | ven. 13/11 | 30 FPS et moins de 800 Mo sur l'Android 3 Go avec 6 joueurs et 60 Zbires, sur 3 mesures consécutives. Tests enfants au seuil. 0 bug bloquant. Audits à 0 faute |
| J5 Lancement v1.0 | ven. 20/11 | Go/no-go le 18/11 à 17 h. Fiche FR/EN et label Léger. Premier Zbire de la Semaine le 21/11 à 17 h (heure de Paris) |
| J6 v1.1 et bilan | 01/12 et 20/12 | Avent en ligne. Bilan à J+30 : rétention J1 d'au moins 22 %, J7 d'au moins 8 % |

## 3. Fenêtres par phase

| Phase | Fenêtre | Tâches |
|---|---|---|
| 0 Concept | 28/09 → 02/10 | T01 à T07 |
| 1 Greybox | 29/09 → 09/10 | T08 à T11 |
| 2 Environnement | 12/10 → 23/10 | T12 à T15 |
| 3 Construction | 12/10 → 06/11 | T16 à T22 |
| 4 Scripting | 05/10 → 06/11 | T23 à T34 ; T35 du 16/11 au 27/11 |
| 5 UI, lumière, polish | 26/10 → 13/11 | T36 à T39 |
| 6 Tests, publication | 23/10 → 20/12 | T40 à T45 |

Le scripting démarre sur la greybox dès le 05/10, sans attendre les décors.

## 4. Dépendances critiques

**Chemin critique :** T02 (Plan v1, 29/09) → T09 (greybox de la Prairie) → T23 (Donnees et Passage), T24 (BoucleDuJour) et T25 (HordeService) → T17 (Zbires finaux, 30/10) → T40 (performance) → T44 (go/no-go). Chaque jour perdu sur cette chaîne décale le lancement d'autant.

- T04 bloque T23 à T33 : aucune remote en dehors de ReglesRemotes, aucune RemoteFunction.
- T03 bloque T27, T28, T30 et T41 : aucun prix en dur hors du Catalogue.
- T17 alimente le pool de 70 modèles de T25. Dès l'Alpha, les modèles provisoires respectent la structure Racine + MeshParts.
- T23 (Donnees.Modifier) passe avant T27, T28, T33 et T34.
- T31 (AmbianceClient) passe avant T37 : pas de passe de lumière avant que le seul script qui écrit dans Lighting existe.
- T01 débloque T26 (rayon du tir automatique), T29 (ReservePour), T20 (Cabine d'Essayage) et le StreamingEnabled du Laboratoire.

## 5. Risques de planning

| Risque | Parade |
|---|---|
| **5 profils surchargés** pour 40 jours ouvrés : a09 ≈ 47 j, a21 ≈ 46 j, a20 ≈ 46 j, a22 ≈ 42 j, a24 ≈ 41 j | Transferts actés : retours de collecte et liaisons ContextActionService à a28, pack de retours à a37, portails à a14 et a21 seuls, forêt à a17 seul, modules du Quai à a23, peluches de a22 en v1.1. a24 fait passer les Zbires avant tout le reste |
| **Victor Lanoue en goulot** : plus de 20 validations en attente | Séance unique le 29/09 et réponse sous 24 h. Sans réponse, la valeur du canon s'applique |
| **Performance sur l'Android 3 Go** (60 Zbires, VFX, Laboratoire à 12 joueurs) | Mesure chaque vendredi dès le 23/10. Leviers dans cet ordre : Animator sur 12 Zbires au lieu de 20, attribut Qualite, attributs Nombre des VFX, Touffes au pas de 6. Le plafond de 60 Zbires reste fixe |
| **Intégration réseau et données** | Contrat v2 versionné. Tout changement passe en revue devant a27 et a03. T43 démarre dès l'Alpha |
| **Dérive de périmètre** | Ordre de coupe au 30/10 : Circuit et Ombres, Tuyauterie, secrets du Laboratoire, météo Orage et Neige, Cabine d'Essayage |
| **Runs de plus de 25 min** | T41 démarre dès l'Alpha. Seuls ZbiresDefs.Jours et le Catalogue s'ajustent |
| **Passage à l'heure d'hiver le 25/10** | Test de Temps.cleJour le 26/10 (T43) |
| **Modération des assets** (atlas, sons, vignettes) | Tous les uploads au nom du groupe avant le 06/11 |

## 6. Règles de pilotage

- Une tâche est finie quand son critère chiffré est vérifié dans Studio ou sur l'Android 3 Go, pas quand le fichier existe.
- Revue de jalon chaque vendredi à 16 h (a01, a02, a03), et point quotidien de 15 min par pôle.
- Si un bug bloquant reste ouvert au go/no-go, le lancement recule d'une semaine, au 27/11.
