# Relecture équilibrage : économie, progression, monétisation

*Stan Bogaert (a43), QA & Équilibrage. Barème de référence : a07, le seul chiffré de bout en bout.*

**Verdict.** La monétisation (a46) est saine : aucun pay-to-win, 1 087 R$ pour tout posséder, aucun article au-dessus de 199 R$, aucun Robux sur la Prairie. Les vignettes (a47) ne montrent rien au-delà du Jour 12. Le risque est ailleurs : trois barèmes de gemmes, trois courbes d'Établi, et aucune run n'a de fin garantie.

## Temps réels calculés

| Repère | Calcul | Résultat |
|---|---|---|
| Chute au jour N | 20 + (N − 1) × 95 + ≈ 40 s | J6 : 9 min, J8 : 12 min, J11 : 17 min |
| Colosse du J15 | 20 + 14 × 95 + 40 | entrée à 23 min 10, combat sans limite |
| Gemmes par run (a07) | jours + Mine + 75 % des Dorés | J6 : 111, J9 : 197, J11 : 294 |
| 1re heure | 4 runs, Défi débloqué dès la 2e | 607 gemmes et 7 recherches (a07 annonce 457 et 5) |
| Arbre complet | Σ base × 1,7^(n − 1) | 83 100 gemmes ≈ 65 h, dont 34 % pour la Foreuse |
| Niveau 30 (a08) | 116 310 XP à ≈ 3 300 XP/jour | 5e-6e semaine, conforme |

## Bloquants

1. **a06 : deux barèmes de gemmes.** `BoucleDuJour` crédite 2 + ⌊N ÷ 2⌋ dans `Gemmes_v1`, sans anti-AFK, en parallèle d'`Economie.franchirJour` (5 + 2 × min(N, 15)). Résultat : double crédit, ou gains ÷ 2,4 (≈ 97 gemmes contre 231 au J10). La Mine suit trois règles différentes (a06, a07, a09). → Supprimer `verserGemmes` et appeler `Economie.franchirJour(jour)`. Mine : 1 gemme / 20 s par Survivant actif, stock 6, vidée pour toute l'équipe au contact.
2. **a27 : quatre adresses pour les gemmes** (`Gemmes_v1`, `Zsurvie_Profils_v1` sous `Survivant_` puis `Joueur_`, `Zsurvie_Joueurs_v1`) : une gemme gagnée sur la Prairie n'arrive pas au Laboratoire. Le plafond « Jour 100 » rogne un J15 à 70 gemmes × 1,5 (Difficile) × 2 (week-end), soit 210. → Store unique `Zsurvie_Joueurs_v1`, clé `J_<UserId>`, écrit par `Donnees.AjouterGemmes` seul ; plafond Jour à 210 ; retirer la source ZbireSemaine.
3. **a26 : trois courbes pour l'Établi.** a07 vend 10 niveaux, mais a09 plafonne Portée au 4, Cadence au 5, Dégâts au 8 et Explosives au 3 : 9 800 des 20 000 Pièces n'achèteraient rien. Les Perforantes de a07 atteignent 140 % au niveau 10. À 45 % de Visée critique, le Casqué subit 1,18 × les dégâts normaux. → `BlasterStats` unique aux prix a07 : Dégâts 10 + 2/niv ; Cadence 4 + 0,2/niv ; Portée 40 + 1,2/niv, rayon du tir auto compris ; Explosives 5 %/niv (rayon 6, 50 % des dégâts) ; Visée critique 5 % + 2 points/niv (25 % au max, Casqué à 0,875) ; Perforantes 45 % + 5 points/niv (95 %). a07 et a09 reprennent ce tableau.
4. **a08 : recherches invisibles au premier retour.** Après la 1re run (≈ 840 XP, niveau 4), seule la Foreuse (100 gemmes) est visible. Le novice n'a que 74 gemmes, et la Tourelle de toit (40 gemmes, l'achat guidé) n'apparaît qu'au niveau 5. Deux verrous se doublent aussi : Difficile au niv 10 ou au Record Jour 10 (a06), Défi au niv 3 ou au 1er Colosse (a07). → Tourelle de toit visible au niv 1, Visée critique au 3, Perforantes au 4, Foreuse au 5 ; Difficile = Record Jour 10 ; Défi = 1er Colosse repoussé.

## Majeurs

5. **a06 : pas de fin garantie.** Le Jour du Colosse dure « tant qu'il est debout », `LIMITE_RUN` ne fait qu'un `warn`, et la Tension manque dans la formule de a26. → Colosse à 2 500 × 1,15^(jour − 1) PV avant coop (≈ 45 s de combat au J5 en solo), enragé 60 s après son entrée (vitesse × 1,5, dégâts × 3), fin forcée à 25:00 avec les gemmes normales, Tension × 1,3^cran sur les PV et les paquets.
6. **a07 : la coop n'est pas neutre.** À 6, le DPS est × 6 contre des PV × 2,75, soit une capacité × 2,18 et ≈ 3,5 jours de plus (331 à 371 gemmes au lieu de 197). → Multiplier le nombre de Zbires par jour par (1 + 0,2 × (actifs − 1)) : bonus coop ≈ +0,6 jour. Recalculer le §5 à 2,5 Survivants.
7. **a07 : les Pièces suivent quatre règles** (aimant 8 ou 10 studs ; 12, 15 ou 20 s au sol ; 50 ou 100 % au Répit ; Doré dès J2 ou J3). Le revenu réel varie donc de 50 à 100 % du §3. → Aimant serveur 8 studs, 20 s au sol, 50 % au Répit, Doré au J3, cumuls à 85 % (≈ 780 au J5, 2 700 au J10). a09, a14 et a28 s'alignent.
8. **a07 : la Foreuse est un mauvais placement.** Chaque niveau rapporte +16 gemmes par nuit et coûte de 170 à 11 860 : le niveau 10 se rentabilise en 741 jours. → 5 niveaux, 5/9/14/20/27 gemmes/h, prix de 100 à 835. L'arbre passe à ≈ 56 300 gemmes (≈ 45 h), aligné sur le niveau 30.
9. **a09 : réparation cumulable.** À 6 avec Réparation 5, la Maison regagne 20 %/s : elle est pleine en 5 s à chaque Répit. Les PV de la Maison et les dégâts des Zbires manquent aux livrables. → 1,5 % × (1 + 0,25 × niv) × (1 + 0,5 × (réparateurs − 1)), 3 réparateurs comptés au plus ; Maison 1 000 PV (Solidité +12 %/niv) ; Zbire au contact 4 × 1,15^(jour − 1) PV/s.
10. **a09 : défenses figées.** Mini-Tourelle (10 DPS) et Muret (150 PV) ne progressent pas, alors que leur prix monte de 15 % par jour : au J10, 141 Pièces pour 10 DPS contre des Zbires à × 3,5. → Mini-Tourelle à 50 % des dégâts du Blaster du poseur ; Muret à 150 × 1,15^(jour − 1).
11. **a10 : premier achat hors délai.** Le prix codé est 10, le prix réel 25 (13 Marcheurs). L'ouverture démarre à A+3 malgré les 20 s d'Arrivée de a06 : l'achat tombe vers T 95. La cadence est de 3 au lieu de 4. → Lire `Economie.prixEtabli("Degats", 1)`, envoyer 13 Marcheurs entre +3 et +30 s, sauter l'Arrivée si `aDesNovices()` (Colosse à 7:00) : achat vers T 75.
12. **a50 : mur mal placé.** Une « plus grosse marche J5 → J6 » donne une médiane de 8 min, contre 12-18 min visées. → Marche attendue entre J8 et J12 pour les runs de rang ≥ 4, perte J5 → J6 ≤ 20 % ; 3 premières runs analysées à part ; tranches J1-4, J5-7, J8-11, J12+.
13. **a49 : gemmes hors canon.** Avent : 1 000 ; missions : 300 par semaine. → Convertir en XP (a08), cosmétiques ou Foreuse Turbo, avec l'accord de Victor Lanoue.
14. **a49 : pack Robux d'événement.** Rien ne garantit qu'il reste en vente après l'événement : ce serait une offre limitée, que a46 interdit. → Le laisser en vente toute l'année après sa sortie, sans compte à rebours.
15. **a13 : secrets à 50 gemmes par jour.** C'est une source hors canon, contraire aux règles de a15 et de a22. → Récompenser en cosmétiques, badges, XP et Pièces de run.

## Mineurs

16. **a06 : Jour parfait à +10 Pièces fixes.** Le 2e achat promis est impossible dès le J3. → Bonus de 25 % des Pièces du jour.
17. **a07 : §5 incomplet.** Il omet le Défi en 1re heure, Difficile × 1,5, le Filon et le Panier (≈ +10 % au J10), et mélange jour UTC et jour de Paris. → Recalculer ; `Transactions.cleJourParis` partout.
18. **a48 : deux erreurs de fiche.** Serveur privé à 100 R$ (a46 : 50) ; « tir automatique sur mobile » alors qu'il est actif sur tous les appareils. → Corriger les deux.
