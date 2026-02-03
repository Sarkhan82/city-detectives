# Story 6.2: Achat et simulation paiement (MVP)

**Story ID:** 6.2  
**Epic:** 6 – Monetization & Purchases  
**Story Key:** 6-2-achat-simulation-paiement  
**Status:** ready-for-dev  
**Depends on:** Story 6.1  
**Parallelizable with:** Story 5.2, Story 8.2, Story 9.2  
**Lane:** C  
**FR:** FR48, FR52, FR53  
**Note:** MVP = flux de paiement simulé (pas d'intégration réelle App Store / Google Play) ; tracking d'intention pour mesurer la conversion.

---

## Story

As a **utilisateur**,  
I want **acheter des enquêtes supplémentaires ; pour le MVP le flux de paiement est simulé et les clics d'intention sont trackés**,  
So that **la conversion soit mesurable sans intégration réelle**.

---

## Acceptance Criteria

1. **Given** l'utilisateur consulte une enquête payante  
   **When** il déclenche l'achat  
   **Then** le flux de paiement complet est simulé (FR53)  
   **And** les clics d'intention d'achat sont enregistrés (FR52)  
   **And** l'accès aux enquêtes achetées (simulé) est cohérent (FR48)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Flux de paiement simulé
  - [ ] 1.1 Sur l'écran détail d'une enquête payante (ou depuis la liste), bouton « Acheter » (ou « Débloquer ») ; au clic, afficher un flux simulé : écran récap (enquête, prix), confirmation « Payer » (simulé), puis écran succès « Achat réussi » (FR53).
  - [ ] 1.2 Aucun appel aux APIs App Store / Google Play ; le flux est entièrement simulé (écrans successifs, délai optionnel pour réalisme) (FR53).
  - [ ] 1.3 Flutter : écran(s) ou étapes « Simulation achat » (récap → confirmation → succès) ; design system « carnet de détective » (FR53).
- [ ] **Task 2** (AC1) – Enregistrement des clics d'intention d'achat
  - [ ] 2.1 Enregistrer chaque clic « Acheter » / « Payer » (intention d'achat) : enquête_id, user_id, timestamp ; envoyer au backend pour analytics (FR52).
  - [ ] 2.2 Backend : mutation ou endpoint ex. `recordPurchaseIntent(investigationId)` (ou `trackPurchaseIntent`) ; persister en DB (ex. table `purchase_intents` : user_id, investigation_id, created_at) (FR52).
  - [ ] 2.3 Optionnel : enregistrer aussi la « complétion » du flux simulé (achat simulé réussi) pour distinguer intention vs conversion (FR52).
- [ ] **Task 3** (AC1) – Accès aux enquêtes achetées (simulé)
  - [ ] 3.1 Après « achat » simulé réussi, marquer l'enquête comme achetée pour l'utilisateur : backend mutation ex. `simulatePurchase(investigationId)` qui enregistre l'achat (user_id, investigation_id) ; côté Flutter, l'enquête devient accessible (plus de bouton « Acheter », accès direct comme pour la gratuite) (FR48).
  - [ ] 3.2 Backend : table ou relation `user_purchases` (user_id, investigation_id) ; query `getUserPurchases(userId)` ou champ sur User/Investigation pour savoir si l'utilisateur a « acheté » l'enquête (FR48).
  - [ ] 3.3 Flutter : après achat simulé, mettre à jour l'état (Riverpod invalidation, rechargement catalogue) ; afficher l'enquête comme débloquée (libellé « Achetée » ou plus de paywall) ; l'utilisateur peut la démarrer (3.1) (FR48).
- [ ] **Task 4** (AC1) – Intégration catalogue et cohérence
  - [ ] 4.1 Depuis le catalogue (6.1), pour une enquête payante non achetée : bouton « Acheter » ; pour une enquête déjà achetée (ou gratuite) : accès direct « Démarrer » (FR48).
  - [ ] 4.2 Réutiliser l'écran liste/détail des enquêtes (2.1, 2.2, 6.1) ; intégrer le flux simulé et la vérification « achetée » (FR48, FR52, FR53).
- [ ] **Task 5** – Qualité et conformité
  - [ ] 5.1 Backend : test d'intégration pour recordPurchaseIntent et simulatePurchase (ou équivalent) ; vérifier persistance et lecture des achats (FR52, FR48).
  - [ ] 5.2 Flutter : tests widget pour le flux simulé (bouton Acheter → récap → confirmation → succès) et pour l'affichage « enquête achetée » (accès direct) ; mocker API (FR48, FR52, FR53).
  - [ ] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 6.1.
  - [ ] 5.4 Accessibilité : labels pour boutons Acheter, Payer, écrans simulation (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 6.2 = simulation paiement MVP.** S'appuie sur 6.1 (catalogue, prix, première gratuite). Pas d'intégration réelle in_app_purchase (App Store / Google Play) pour le MVP : flux 100 % simulé (FR53). Tracking des clics d'intention (FR52) et enregistrement des « achats » simulés pour débloquer l'accès (FR48). Architecture : payment_service (Flutter + Rust) peut gérer simulation + tracking.
- **Flutter** : `lib/core/services/payment_service.dart` (architecture) : méthodes ex. `simulatePurchase(investigationId)`, `recordPurchaseIntent(investigationId)` ; appels au backend. Écrans ou étapes du flux simulé dans `lib/features/investigation/` ou `lib/features/payment/` (ex. `purchase_simulation_screen.dart`) (FR48, FR52, FR53).
- **Backend** : `src/services/payment_service.rs` : `record_purchase_intent`, `simulate_purchase` ; mutations GraphQL ; tables `purchase_intents`, `user_purchases` (ou équivalent) (FR48, FR52, FR53).

### Project Structure Notes

- **Flutter** : `lib/core/services/payment_service.dart` ; écran(s) flux achat simulé (ex. `lib/features/investigation/screens/` ou `lib/features/payment/`) ; réutilisation écran détail/liste enquêtes (6.1). Fichiers GraphQL : mutations `recordPurchaseIntent`, `simulatePurchase` (ou noms choisis).
- **Backend** : `src/services/payment_service.rs` ; `src/api/graphql/mutations.rs` (recordPurchaseIntent, simulatePurchase) ; tables `purchase_intents`, `user_purchases` ; query getUserPurchases ou champs sur User/Investigation (FR48, FR52, FR53).
- [Source: architecture.md § Monetization, payment_service]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 6, Story 6.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – Monetization, payment_service, simulation MVP]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 6.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/core/services/payment_service.dart` ; écran(s) flux achat simulé |
| Structure Backend | `src/services/payment_service.rs`, mutations GraphQL, tables purchase_intents, user_purchases |
| État Flutter | `AsyncValue` pour appels payment ; invalidation après achat pour rafraîchir catalogue |
| API GraphQL | Mutations recordPurchaseIntent, simulatePurchase ; query getUserPurchases ou champs |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels flux achat |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Pas d'utilisation de `in_app_purchase` pour le MVP (simulation uniquement) ; peut être préparé pour V1.0+ (FR53).
- **Backend** : Pas de nouvelle dépendance obligatoire ; persistance en DB (purchase_intents, user_purchases) (FR48, FR52, FR53).
- [Source: architecture.md – Monetization, simulation MVP]

---

## File Structure Requirements

- **Flutter** : `lib/core/services/payment_service.dart` ; écran(s) `purchase_simulation_screen.dart` ou étapes dans feature investigation ; mutations GraphQL `record_purchase_intent.graphql`, `simulate_purchase.graphql` (ou noms choisis).
- **Backend** : `src/services/payment_service.rs` ; mutations dans `src/api/graphql/mutations.rs` ; migrations sqlx pour `purchase_intents`, `user_purchases` (FR48, FR52, FR53).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour recordPurchaseIntent (persistance) et simulatePurchase (enregistrement achat + lecture getUserPurchases) (FR48, FR52, FR53).
- **Flutter** : Tests widget pour flux simulé (bouton Acheter → étapes → succès) et pour affichage enquête achetée (accès direct) ; mocker payment_service / API (FR48, FR52, FR53).
- **Qualité** : Pas de régression sur 6.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 6.1)

- **Catalogue et prix** : 6.1 fournit la première enquête gratuite accessible, les enquêtes payantes avec prix affichés. En 6.2, pour les enquêtes payantes non achetées : bouton « Acheter » qui déclenche le flux simulé ; après achat simulé, l'enquête est considérée achetée et accessible (FR48).
- **Ne pas dupliquer** : réutiliser l'écran liste/détail (6.1) ; ajouter le flux achat simulé et la logique « achetée » (backend + Flutter). Un seul payment_service (Flutter + Rust) pour simulation et tracking (FR52, FR53).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **MVP** : Simulation paiement (architecture) ; tracking de propension à payer (FR52) ; pas d'intégration réelle stores pour le MVP (FR53).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
