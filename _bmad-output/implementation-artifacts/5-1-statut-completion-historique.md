# Story 5.1: Statut de complétion et historique

**Story ID:** 5.1  
**Epic:** 5 – Progression & Gamification  
**Story Key:** 5-1-statut-completion-historique  
**Status:** done  
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

- [x] **Task 1** (AC1) – Statut de complétion par enquête
  - [x] 1.1 Afficher pour chaque enquête un statut clair : non démarrée / en cours / complétée (FR39). Données : progression locale (Hive, 3.3) et/ou backend (si sync progression existante).
  - [x] 1.2 Backend : exposer la progression par utilisateur et par enquête (ex. query `getUserProgress(userId)` ou `getUserInvestigationsStatus(userId)` : liste enquêtes avec statut, pourcentage ou énigmes complétées). Si pas encore d'API : s'appuyer sur Hive côté Flutter et afficher les enquêtes « en cours » + complétées à partir des données locales (FR39).
  - [x] 1.3 Flutter : écran « Profil » ou « Progression » (route ex. `/profile` ou `/progression`) ; liste ou grille des enquêtes avec indicateur de statut (non démarrée, en cours, complétée) (FR39).
- [x] **Task 2** (AC1) – Progression globale
  - [x] 2.1 Afficher une progression globale : ex. nombre d'enquêtes complétées / total, ou pourcentage, ou résumé (FR40).
  - [x] 2.2 Données : agrégation des statuts par enquête (local Hive + optionnel backend). Calcul côté Flutter si pas d'API dédiée (FR40).
  - [x] 2.3 Design : design system « carnet de détective » ; indicateur visuel clair (barre, chiffres, etc.) (FR40).
- [x] **Task 3** (AC1) – Historique des enquêtes complétées
  - [x] 3.1 Afficher l'historique des enquêtes complétées : liste ordonnée (ex. par date de complétion) avec titre, date, éventuellement durée (FR41).
  - [x] 3.2 Données : marquer « complétée » quand l'utilisateur a validé la dernière énigme d'une enquête (4.1, 4.2) ; persister en local (Hive) et optionnellement en backend (FR41).
  - [x] 3.3 Flutter : section « Historique » ou « Enquêtes complétées » sur l'écran profil/progression ; liste scrollable (FR41).
- [x] **Task 4** (AC1) – Navigation et entrée
  - [x] 4.1 Route GoRouter pour l'écran profil/progression (ex. `/profile`, `/progression`) ; accès depuis le menu principal, la barre de navigation ou l'écran liste des enquêtes (FR39, FR40, FR41).
  - [x] 4.2 Réutiliser le router et la structure existants (2.1, 2.2, 3.1) ; pas de régression sur la navigation vers les enquêtes (FR39).
- [x] **Task 5** – Qualité et conformité
  - [x] 5.1 Backend : test d'intégration pour la query progression/utilisateur si ajoutée (ex. `tests/api/user_progress_test.rs` ou équivalent) – au moins un cas nominal (FR39, FR40, FR41).
  - [x] 5.2 Flutter : tests widget pour l'écran profil/progression (présence statut par enquête, progression globale, historique) ; mocker données locales ou API (FR39, FR40, FR41).
  - [x] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 4.1–4.4, 3.3.
  - [x] 5.4 Accessibilité : labels pour statuts, progression, historique (WCAG 2.1 Level A).

- [x] **Review Follow-ups (AI)**
  - [x] [AI-Review][MEDIUM] Utiliser constantes/helpers AppRouter pour les routes dans progression_screen (au lieu de chaînes en dur) [progression_screen.dart:241, 307]
  - [x] [AI-Review][MEDIUM] Ajouter accès à l'écran Progression depuis le menu principal ou la barre de navigation (Task 4.1 partielle)
  - [x] [AI-Review][MEDIUM] Compléter File List avec investigation_progress.g.dart si le fichier est versionné
  - [ ] [AI-Review][LOW] Optionnel FR41 : afficher la durée d'enquête dans l'historique (reporté MVP)
  - [x] [AI-Review][LOW] Documenter ou corriger la branche forTest du repository (completed_investigation_repository.dart L36–39)
  - [x] [AI-Review][LOW] Ajouter Semantics au bouton « Réessayer » sur l'écran Progression (état erreur)

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

- Implémentation 100 % côté Flutter/Hive (pas d’API backend pour 5.1, conforme aux Dev Notes). Modèle `CompletedInvestigation` (Hive typeId 1) et repository pour persister les enquêtes complétées. Marquage « complétée » dans `investigation_play_screen.dart` lorsque la dernière énigme est validée ; suppression de la progression « en cours » pour cette enquête. Écran `ProgressionScreen` avec statut par enquête (non démarrée / en cours / complétée), barre de progression globale (X / Y enquêtes), et historique ordonné par date. Route `/progression` et accès depuis la liste des enquêtes (icône « Ma progression »). Tests unitaires repository + tests widget écran progression ; Semantics pour accessibilité WCAG 2.1 Level A.
- **Code review 2026-02-03 :** Corrigé bug critique (ne plus appeler _saveProgress après complétion pour éviter enquête à la fois complétée et en cours). Corrigé invalidation de userProgressDataProvider après complétion pour rafraîchir l’écran Progression.

- **Review follow-ups 2026-02-03 :** AppRouter.investigationDetailPath/StartPath ; accès « Ma progression » depuis l'écran home ; File List complétée ; commentaire forTest ; Semantics bouton Réessayer. FR41 durée laissé optionnel.
- **Code review 2e passage 2026-02-03 :** Navigation Historique→détail corrigée (passage de `extra: investigation` dans _HistoryTile) ; context.mounted ajouté sur les onTap de l'écran home.

### File List

- city_detectives/lib/features/investigation/models/completed_investigation.dart
- city_detectives/lib/features/investigation/models/completed_investigation.g.dart
- city_detectives/lib/features/investigation/models/investigation_progress.g.dart (régénéré build_runner)
- city_detectives/lib/features/investigation/repositories/completed_investigation_repository.dart
- city_detectives/lib/features/investigation/screens/investigation_play_screen.dart
- city_detectives/lib/main.dart
- city_detectives/lib/features/profile/providers/user_progress_provider.dart
- city_detectives/lib/features/profile/screens/progression_screen.dart
- city_detectives/lib/core/router/app_router.dart
- city_detectives/lib/features/investigation/screens/investigation_list_screen.dart
- city_detectives/test/features/investigation/repositories/completed_investigation_repository_test.dart
- city_detectives/test/features/profile/screens/progression_screen_test.dart

### Change Log

- 2026-02-03 : Story 5.1 implémentée – statut par enquête, progression globale, historique complétées, écran Progression, route /progression, tests et accessibilité.
- 2026-02-03 : Code review (adversarial) – 1 critique et 1 élevé corrigés (_saveProgress après complétion, invalidation userProgressDataProvider). 3 moyen et 3 faible reportés en Review Follow-ups.
- 2026-02-03 : Review follow-ups traités (routes AppRouter, accès home, File List, forTest, Semantics). Statut repassé en review.
- 2026-02-03 : Code review 2e passage – HIGH navigation Historique→détail (extra) et MEDIUM context.mounted (home) corrigés. Outcome Approve. Statut → done.

---

## Senior Developer Review (AI)

**Outcome:** Approve (après 2e passage)  
**Date:** 2026-02-03  
**Action Items:** 6 traités ; 2e passage : 1 HIGH + 1 MEDIUM corrigés.

### Résumé

- **CRITICAL (corrigé)** : Ré-enregistrement de la progression après complétion → enquête à la fois « complétée » et « en cours ». Corrigé en n’appelant plus `_saveProgress` lorsque la dernière énigme est validée.
- **HIGH (corrigé)** : Données de progression obsolètes sur l’écran Progression après complétion. Corrigé par `ref.invalidate(userProgressDataProvider)` après marquage complété.
- **MEDIUM** : Routes en dur dans progression_screen ; accès progression uniquement depuis la liste (Task 4.1 partielle) ; File List incomplète (investigation_progress.g.dart).
- **LOW** : Durée non affichée (FR41 optionnel) ; branche forTest du repository ; Semantics du bouton Réessayer → traités sauf durée (reporté MVP).
- **2e passage** : HIGH navigation Historique→détail (extra) + MEDIUM context.mounted (home) corrigés. Story validée → done.

### Action Items (détails)

Voir section **Review Follow-ups (AI)** dans Tasks/Subtasks. Rapport détaillé : `implementation-artifacts/code-review-5-1-statut-completion-historique.md`.

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
