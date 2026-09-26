# Zsurvie : note de coordination a03

*Marc Aubry, chef de projet, 26/09/2026. Ces arbitrages font foi pour le build de test H1 à H8. (V) = écart soumis à Victor Lanoue ; en attendant sa réponse, on construit avec l'option retenue.*

## 1. Arbitrages

1. **État de run.** Un seul `ReplicatedStorage.EtatRun`, créé par a27 et écrit par la BoucleDuJour de a06 : Jour, Phase (Arrivee, Horde, Repit), FinPhase, JourColosse, ColosseActif, PV de la Maison et du Colosse, MaisonEtat, Tension. Workspace ne garde que TypePlace, CentrePlace et RayonPlace.
2. **Réseau.** Un module `ReplicatedStorage.Reseau` (a27), généré depuis `ReglesRemotes` (a29) : RemoteEvent uniquement, refus par `Annonce`, `EtatZbires` en 9 octets à 10 Hz, un seul flux `Evenements` de 8 octets par fait. RemoteFunction, `Impact`, `Eclatement`, `VfxRapide` et `Retour` sont supprimés.
3. **Sauvegarde.** `Zsurvie_Joueurs_v1`, clé `J_<UserId>`, schéma v2, écrit par `Donnees.Modifier`, `AjouterGemmes` et `CrediterRun`. Tous les autres stores disparaissent. Le jour change à minuit heure de Paris (`Temps.cleJour()`), partout.
4. **Gemmes.** Les 5 sources du canon, barème a07 dans `ReplicatedStorage.Catalogue` : jour franchi 5 + 2 × min(N, 15), doublé aux J5, J10 et J15 ; Mine commune, 1 gemme toutes les 20 s, stock 6, versée à chaque Survivant actif au contact ; Doré 4 dès le J3 ; 1re recherche à 40. Secrets, Avent et missions : aucune gemme.
5. **Pièces.** Prix a07 (Dégâts niveau 1 = 25) ; le CATALOGUE de a33 est supprimé. Aimant serveur de 8 studs, 20 s au sol, puis 50 % crédités au Répit avec un « +X » gris (V). Jour parfait : 25 % des Pièces du jour (V).
6. **Survivant actif.** Un seul `Economie.marquerActif` (4 studs cumulés, réparation, pose, ping ou tap de ciblage ; fenêtre de 90 s ; « Zzz » à 75 s) pour les gemmes, l'XP et la coop (V).
7. **Combat.** `BlasterStats` unique sur 10 niveaux : Dégâts 10 → 30, Cadence 4 → 6, Portée 40 → 52, Visée critique 5 → 25 % (Casqué à 0,875), Perforantes 45 → 95 %, Explosives 5 → 50 %. Tir auto sur tous les appareils, rayon = Portée (V), une seule boucle chez a26.
8. **Difficulté.** `ZbiresDefs.JOURS` (a06) : PV × 1,15^(j−1) × 1,3^max(0, j−10) × coop ; (18 + 7j) × (1 + 0,2 × (actifs − 1)) Zbires par jour ; rampe de 1 chemin (J1-3, jamais le Sud), 2 portails (J4-8), puis 3 ou 4. Colosse à 2 500 × 1,15^(j−1), enragé 60 s après son entrée ; fin de run forcée à 25:00. Arrivée de 20 s gardée (V).
9. **Plan v1 (a11).** Mine X 20 → 32, Z 20 → 32 (V) ; 8 portails à R 80, le SE décalé de 20° vers le Sud ; barrière à R 72 ; pose jusqu'à R 66 via `Plan.posePermise`, client et serveur ; Établi (−12, 14) ; atterrissage (−3 ; 0,5 ; 16) ; aucun palier C sur les axes des portails.
10. **3C.** `Config.Mouvement` : Prairie 18, 24 au Répit, 8 en réparation, saut à 0 (V) ; Laboratoire 16 et 7,2. Seul `GardienMouvement` les applique. Les défenses ne bloquent pas les Survivants, la 4e pose est refusée, la reprise rend 50 %.
11. **HUD.** Maquette unique 800 × 360, codée par a28 seule (HudController de a32 retiré) : bandeau Maison en haut, Réparer 96 px dans le coin, Muret, Mini-Tourelle, Tapis Collant et Ping en 64 px sur l'arc, Établi en bouton contextuel de 72 px ; touches E, 1-2-3, Q, F. Variante B de H2 : la rangée Poser/Pings.
12. **Progression.** Recherches visibles aux niveaux 1 (Tourelle de toit), 3, 4 et 5 (Foreuse). Le niveau ne verrouille que les défenses et le Calendrier. Capsule Difficile : Record Jour 10. Capsule du Jour et Défi : premier Colosse repoussé.
13. **Lumière.** Un seul écrivain, `AmbianceClient` (a36) : ClockTime 14, puis 17,5 le Jour du Colosse après un fondu de 8 s au Répit précédent. `workspace.Lumieres` recense les 12 sources.
14. **Performance.** Statique de 6 500 Parts, pic ≈ 7 900. Zbires en pool de 70 (Racine + 3 à 5 MeshParts, un seul BulkMoveTo, ni ombre ni Neon). Seuls propriétaires : a17 (forêt), a37 (24 émetteurs), a39 (16 voix), a30 (`Charte.Couleurs` et `Charte.teinte`).

## 2. Révisions de la vague 1

Dans l'ordre du kanban. Le 29/09 : a30 (Charte, Forge, Auditeur), a11 (Plan, Gabarit), a27 (store, Reseau, Temps). Le 02/10 : a07 (Catalogue), a06 (table des jours), a09 (3C, défenses), a26 (horde, Blaster, rendu), a29 (gardien), a28 (HUD), a08 (visibilité), a10 (rythme, 1re recherche), a36 (lumière).

## 3. Vague 2

a13, a14, a15, a18, a19, a21, a32, a33, a37, a38, a39, a49 et a50 appliquent les arbitrages détaillés dans `a03-coordination.json`, sans consigne nominative.

## 4. Paquet pour Victor Lanoue (réponse souhaitée le 30/09)

Arrivée de 20 s, Jour parfait, Tension au J11, coop limitée aux actifs, aspiration de 50 %, tir auto sur tous les appareils, saut à 0, caméra (0, 52, 32) au Colosse, caméra Custom au Laboratoire, Mine bord à bord, StreamingEnabled au Laboratoire, Niveau de Survivant et Galons, Calendrier, Foreuse Turbo, glossaire EN, 5e canal pad, et les noms nouveaux (Parvis, Ronde, Grand Portail, Voie d'arrivée, quartiers, Tuyauterie, Ressorts, Douve, Vestiaire, Cabine d'Essayage, Pompon).
