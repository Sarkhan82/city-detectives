# Story 5.1: Statut de complétion et historique

**Story ID:** 5.1  
**Epic:** 5 – Progression & Gamification  
**Story Key:** 5-1-statut-completion-historique  
**Status:** ready-for-dev  
**Depends on:** Story 4.1  
**Parallelizable with:** Story 6.1, Story 8.1, Story 9.1  
**Lane:** B  
**FR:** FR39, FR40, FR41  

---

## Story

As a **utilisateur**,  
I want **voir mon statut de complétion par enquête, ma progression globale et mon historique d'enquêtes complétées**,  
So that **je sache où j'en suis**.

---

## Acceptance Criteria

1. **Given** l'utilisateur a complété ou commencé des enquêtes  
   **When** il consulte son profil ou l'écran progression  
   **Then** le statut de complétion par enquête est visible (FR39)  
   **And** la progression globale et l'historique des enquêtes complétées sont affichés (FR40, FR41)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Statut de complétion par enquête
  - [ ] 1.1 Afficher pour chaque enquête un statut clair : non démarrée / en cours / complétée (FR39). Données : progression locale (Hive, 3.3) et/ou backend (si sync progression existante).
  - [ ] 1.2 Backend : exposer la progression par utilisateur et par enquête (ex. query `getUserProgress(userId)` ou `getUserInvestigationsStatus(userId)` : liste enquêtes avec statut, pourcentage ou énigmes complétées). Si pas encore d'API : s'appuyer sur Hive côté Flutter et afficher les enquêtes « en cours » + complétées à partir des données locales (FR39).
  - [ ] 1.3 Flutter : écran « Profil » ou « Progression » (route ex. `/profile` ou `/progression`) ; liste ou grille des enquêtes avec indicateur de statut (non démarrée, en cours, complétée) (FR39).
- [ ] **Task 2** (AC1) – Progression globale
  - [ ] 2.1 Afficher une progression globale : ex. nombre d'enquêtes complétées / total, ou pourcentage, ou résumé (FR40).
  - [ ] 2.2 Données : agrégation des statuts par enquête (local Hive + optionnel backend). Calcul côté Flutter si pas d'API dédiée (FR40).
  - [ ] 2.3 Design : design system « carnet de détective » ; indicateur visuel clair (barre, chiffres, etc.) (FR40).
- [ ] **Task 3** (AC1) – Historique des enquêtes complétées
  - [ ] 3.1 Afficher l'historique des enquêtes complétées : liste ordonnée (ex. par date de complétion) avec titre, date, éventuellement durée (FR41).
  - [ ] 3.2 Données : marquer « complétée » quand l'utilisateur a validé la dernière énigme d'une enquête (4.1, 4.2) ; persister en local (Hive) et optionnellement en backend (FR41).
  - [ ] 3.3 Flutter : section « Historique » ou « Enquêtes complétées » sur l'écran profil/progression ; liste scrollable (FR41).
- [ ] **Task 4** (AC1) – Navigation et entrée
  - [ ] 4.1 Route GoRouter pour l'écran profil/progression (ex. `/profile`, `/progression`) ; accès depuis le menu principal, la barre de navigation ou l'écran liste des enquêtes (FR39, FR40, FR41).
  - [ ] 4.2 Réutiliser le router et la structure existants (2.1, 2.2, 3.1) ; pas de régression sur la navigation vers les enquêtes (FR39).
- [ ] **Task 5** – Qualité et conformité
  - [ ] 5.1 Backend : test d'intégration pour la query progression/utilisateur si ajoutée (ex. `tests/api/user_progress_test.rs` ou équivalent) – au moins un cas nominal (FR39, FR40, FR41).
  - [ ] 5.2 Flutter : tests widget pour l'écran profil/progression (présence statut par enquête, progression globale, historique) ; mocker données locales ou API (FR39, FR40, FR41).
  - [ ] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 4.1–4.4, 3.3.
  - [ ] 5.4 Accessibilité : labels pour statuts, progression, historique (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 5.1 = écran profil / progression.** S'appuie sur 4.1 (énigmes résolubles, donc « complétée » = dernière énigme validée) et 3.3 (progression sauvegardée en Hive). Pas de badges/leaderboard (5.2, V1.0+) : uniquement statut par enquête, progression globale, historique complété (FR39, FR40, FR41).
- **Flutter** : Feature `lib/features/profile/` (architecture) ; écran « Progression » ou « Mon profil » avec statuts, progression globale, historique. Réutiliser Hive (progression 3.3) pour les enquêtes en cours ; définir « complétée » (dernière énigme validée) et persister en local (ex. liste investigation_ids complétées dans Hive) (FR39, FR40, FR41).
- **Backend** : Optionnel pour 5.1 : si pas encore d'API progression, tout peut être dérivé du local (Hive). Si API : query `getUserProgress` ou équivalent pour cohérence multi-appareils future (FR39, FR40, FR41).

### Project Structure Notes

- **Flutter** : `lib/features/profile/` – écran `progression_screen.dart` ou `profile_screen.dart` (statuts, progression globale, historique) ; providers pour charger progression (Hive + optionnel API). Route dans `lib/core/router/app_router.dart` (ex. `/profile`, `/progression`) (FR39, FR40, FR41).
- **Backend** : Optionnel – `src/services/user_progress_service.rs` ou extension `user_service` ; query GraphQL `getUserProgress` (liste enquêtes + statut, complétées). Table ou champs : `user_investigation_progress` (user_id, investigation_id, status, completed_at) si persistance serveur (FR39, FR40, FR41).
- [Source: architecture.md § Requirements to Structure Mapping – Progression & Tracking, profile/]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 5, Story 5.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – profile/, Progression, Content & LORE]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 5.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/profile/` (screens, providers) ; route `/profile` ou `/progression` |
| Structure Backend | `src/services/` (user_progress ou user_service) ; query GraphQL getUserProgress |
| État Flutter | `AsyncValue` pour chargement progression ; pas de booléen `isLoading` séparé |
| Données | Hive pour progression locale (3.3) ; optionnel API pour sync (FR39, FR40, FR41) |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour statuts, progression, historique |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Hive déjà utilisé (3.3) pour progression ; réutiliser pour « enquêtes complétées » (liste ou marqueur par enquête). Pas de nouvelle dépendance obligatoire pour 5.1.
- **Backend** : Pas de nouvelle dépendance obligatoire ; optionnel : table/user_progress et query GraphQL (FR39, FR40, FR41).
- [Source: architecture.md – profile/, Progression]

---

## File Structure Requirements

- **Flutter** : `lib/features/profile/screens/progression_screen.dart` (ou `profile_screen.dart`) ; `lib/features/profile/providers/` (ex. `user_progress_provider.dart`) ; route dans `lib/core/router/app_router.dart`. Réutiliser Hive (box progression 3.3) ; étendre si besoin pour marquer « complétée » (ex. `completed_investigation_ids`).
- **Backend** : Optionnel – `src/services/user_progress_service.rs`, `src/api/graphql/queries.rs` (getUserProgress). Migrations sqlx si table `user_investigation_progress` (FR39, FR40, FR41).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d'intégration pour la query getUserProgress si implémentée (ex. `tests/api/user_progress_test.rs`) – au moins un cas nominal (FR39, FR40, FR41).
- **Flutter** : Tests widget pour l'écran profil/progression : affichage statut par enquête (non démarrée, en cours, complétée), progression globale, liste historique ; mocker Hive ou API (FR39, FR40, FR41).
- **Qualité** : Pas de régression sur 4.1–4.4, 3.3 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Stories 3.3, 4.1)

- **3.3** : Progression « enquête en cours » persistée en Hive (investigation_id, index énigme, énigmes complétées). Pour 5.1, réutiliser ces données pour afficher « en cours » ; ajouter la notion « complétée » quand la dernière énigme est validée (4.1, 4.2) et persister (Hive : liste completed_investigation_ids ou champ par enquête) (FR39, FR41).
- **4.1, 4.2** : Validation d'énigme et marquage énigme complétée. Au moment où la dernière énigme d'une enquête est validée, marquer l'enquête comme « complétée » (côté Flutter/Hive pour 5.1 ; optionnel backend) (FR41).
- **Ne pas dupliquer** : un seul écran profil/progression ; une seule source de vérité pour « complétée » (dérivée de la progression 3.3 + règle « dernière énigme validée »).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Progression** : Content & LORE, Progression → `lib/features/profile/` (architecture).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
