# Plan de playtests : 8 hypothèses à risque

*Félix Onana, coordinateur playtests. Base : canon de Victor Lanoue et décisions a06 à a50.*

## Cadre commun

- **Testeurs :** 9-15 ans, dont deux tiers de 9-12 ans. Accord parental écrit, comptes de test, serveur privé, chat et voix coupés, capture d'écran sans visage.
- **Appareils :** 70 % téléphone (Android 3 Go de référence, iPhone SE), 20 % PC, 10 % iPad. FPS et `Stats:GetTotalMemoryUsageMb()` relevés ; une session sous 25 FPS part au test performance.
- **Build :** place privée, valeurs figées dans `ReplicatedStorage.Config`, télémétrie `ServerScriptService.Telemetrie` (a50).
- **Méthode :** observation muette, puis 5 questions au plus avec une échelle de 5 visages ; 45 min au plus par session.
- **Vagues :** V1 = H1 à H4 (12 enfants, solo et duo) ; V2 = H5 à H7 (24 enfants, groupes de 4 à 6) ; V3 = H8 (bêta fermée de 7 jours, 40 comptes).

## Les 8 hypothèses

### H1. Un novice comprend la run sans un mot (a10)
- **Profil :** 8 novices de 9-11 ans, sur téléphone.
- **Scénario :** SpawnNovice, Capsule Normale en solo, ouverture scriptée du Jour 1, arrêt après le Jour 3.
- **Questions :** « Qu'est-ce qui donne des pièces ? » « À quoi sert l'Établi ? » « Que protèges-tu ? »
- **Succès :** 7/8 éclatent un Zbire avant 45 s ; 6/8 achètent seuls avant 90 s ; aucun abandon avant le Jour 2.

### H2. Les contrôles mobiles tiennent sans saut (a28, a35)
- **Profil :** 10 joueurs de 9-15 ans sur téléphone 5,5" et iPhone SE, dont 3 habitués de Roblox.
- **Scénario :** A/B entre le saut à 0 avec la grappe de a28 et `JumpHeight` 5. Consigne : poser 3 Murets, puis courir à l'Établi.
- **Mesures :** taps hors cible, poses annulées, Survivant bloqué plus de 3 s.
- **Succès :** moins de 5 % de taps ratés ; aucun Survivant enfermé ; 8/10 posent en 2 taps du premier coup.

### H3. Avec le tir automatique, le Survivant reste l'arme (a09, a28)
- **Profil :** 12 joueurs, 6 sur téléphone et 6 sur PC.
- **Scénario :** une run jusqu'à la chute, tir auto actif partout.
- **Mesures :** temps immobile, taps de cible prioritaire, gemmes retenues par l'anti-AFK. Question : « Qui bat les Zbires, toi ou le jeu ? »
- **Succès :** immobile moins de 30 % de la horde ; 9/12 disent « moi » ; aucun joueur actif privé de gemmes.

### H4. La horde se lit en une seconde (pilier 1)
- **Profil :** 10 joueurs de 9-13 ans sur téléphone.
- **Scénario :** run jusqu'au Jour 9 (bestiaire complet), puis reconnaissance des 10 portraits à 32 px (a34).
- **Questions :** « Pourquoi le casqué résiste ? » « Que fait le gluant ? » « D'où venait le Zbire qui t'a étourdi ? »
- **Succès :** 8/10 énoncent les règles du Gluant et du Volant, 6/10 celle du Casqué ; moins de 20 % des étourdissements viennent d'un Zbire hors champ au sud.

### H5. On coopère sans chat (pilier 2)
- **Profil :** 2 groupes d'amis de 4 et 2 groupes d'inconnus de 6, appareils mêlés.
- **Scénario :** 2 runs par groupe, Roue des Pings seule.
- **Mesures :** pings par minute, contributions à la cagnotte commune, réparations par joueur.
- **Succès :** à chaque Colosse, un ping suivi d'effet en 5 s ; personne à 0 contribution ; jour atteint à 6 joueurs à ± 2 jours du solo (multiplicateur 0,35).

### H6. Le Répit de 15 s suffit (a06, a07, a15)
- **Profil :** les groupes de H5 et 6 solos.
- **Scénario :** mêmes runs ; on chronomètre achat, réparation, pose et énigme de chaque Répit.
- **Question :** « Le moment calme : trop court, bien, trop long ? »
- **Succès :** 80 % des Répits comptent au moins 1 achat ; « trop court » sous 25 % ; aucune énigme ne fait rater un achat.

### H7. La run dure ce que promet le canon (§4, §9)
- **Profil :** 30 runs en Capsule Normale, de 1 à 6 joueurs.
- **Scénario :** runs libres sur une seule table jour → PV et nombre de Zbires.
- **Succès :** 70 % des premières runs voient le Colosse (7 min 20) ; chute médiane entre J8 et J11 ; aucune run au-delà de 25 min.

### H8. Les gemmes font revenir (pilier 3)
- **Profil :** 40 comptes, dont 25 novices, 70 % sur téléphone.
- **Scénario :** bêta fermée de 7 jours, journal parent-enfant de 2 questions par jour.
- **Questions :** « Qu'as-tu lancé au Laboratoire, et qu'est-ce que ça change ? » « Pourquoi es-tu revenu ? »
- **Succès :** 100 % peuvent lancer une recherche après la 1re run ; 2e run ≥ 55 % ; J1 ≥ 22 % et J7 ≥ 8 % ; moins de 10 % de « j'étais obligé ».

## Préalables : aucune vague sur des valeurs contradictoires

| Gravité | Agent | Problème | Correction |
|---|---|---|---|
| Bloquant | a09 | Saut à 0, 4,5, 5 ou 7,2 selon les agents ; Muret « franchissable d'un saut » | `Config.Mouvement` unique, Murets non collidables pour les Survivants |
| Bloquant | a07 | Dégâts niv. 1 à 25 pièces pour 14 pièces gagnées à 70 s | Base de Dégâts à 10 pièces |
| Bloquant | a08 | Au retour, seule la Foreuse (100 gemmes) est visible | Tourelle de toit (40) visible dès le niveau 1 |
| Bloquant | a27 | 3 DataStores et 2 formats de clé pour les gemmes | `Zsurvie_Joueurs_v1`, clé `J_<UserId>`, schéma unique |
| Majeur | a07 | Barèmes de gemmes contradictoires (a06, a07, a09) | Une table dans `ReplicatedStorage.Catalogue` |
| Majeur | a06 | PV × 1,15 par jour puis +30 % dès J11 ; Zbires par jour non fixés | Table jour → PV, Zbires, paquets |
| Majeur | a13 | Secrets à 50 gemmes par jour, hors sources du canon | Cosmétiques et badges, ou écart soumis à Victor |
| Majeur | a10 | Entonnoir de 7 étapes contre 12 (a50) | Étapes de a50 via `Telemetrie` |
| Majeur | a11 | Mine au sud-est ou au nord-est, Établi au sud ou à l'est, portails de R 80 à 86 | `ReplicatedStorage.Plan` v1 figé, atterrissage à 10 studs de l'Établi |
| Majeur | a36 | 4 règles de `ClockTime`, dont une nuit pendant le Répit | Un seul script client, pas de nuit au Répit |
| Majeur | a07 | « Actif » vaut 4 studs, 20 studs ou 90 s selon l'agent | Un seul `Economie.marquerActif`, fenêtre de 90 s |
| Majeur | a09 | Pièces perdues à 15 s, à 20 s, rapatriées ou aspirées à 50 % | Aucune pièce perdue : aimant automatique à 20 s |
| Majeur | a35 | 5 maquettes de boutons, de 64 à 100 px | Maquette unique alignée sur a28 |
| Majeur | a27 | Jour qui change à minuit UTC ou à Paris | `Temps.cleJour()` en heure de Paris |
