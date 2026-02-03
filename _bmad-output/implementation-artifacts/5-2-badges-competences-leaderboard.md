# Story 5.2: Badges, compétences et leaderboard (V1.0+)

**Story ID:** 5.2  
**Epic:** 5 – Progression & Gamification  
**Story Key:** 5-2-badges-competences-leaderboard  
**Status:** ready-for-dev  
**Depends on:** Story 5.1  
**Parallelizable with:** Story 6.2, Story 8.2, Story 9.2  
**Lane:** B  
**FR:** FR42, FR43, FR44, FR45  
**Note:** V1.0+ – gamification avancée ; peut être implémentée avec structure minimale et données mock si priorité MVP.

---

## Story

As a **utilisateur**,  
I want **voir mes badges et accomplissements, ma progression de compétences détective, les cartes postales virtuelles et le classement leaderboard**,  
So that **je sois motivé à progresser**.

---

## Acceptance Criteria

1. **Given** l'utilisateur a débloqué des accomplissements (V1.0+)  
   **When** il consulte la section gamification  
   **Then** badges, compétences détective, cartes postales et leaderboard sont visibles (FR42–FR45)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Badges et accomplissements
  - [ ] 1.1 Afficher les badges débloqués par l'utilisateur (ex. « Première enquête », « 5 énigmes résolues », « Ville explorée ») (FR42).
  - [ ] 1.2 Backend : exposer les badges par utilisateur (ex. query `getUserBadges(userId)` ou champs sur `UserProgress` : liste de badge_ids ou équivalent). Données : définition des badges (critères, icône, libellé) ; déblocage basé sur la progression (enquêtes complétées, énigmes résolues, etc.) (FR42).
  - [ ] 1.3 Flutter : section « Badges » ou « Accomplissements » sur l'écran profil/gamification (5.1) ; grille ou liste des badges (débloqués visibles, non débloqués en grisé ou cachés selon UX) (FR42).
- [ ] **Task 2** (AC1) – Progression de compétences détective
  - [ ] 2.1 Afficher la progression des compétences détective (ex. niveaux, barres de progression par compétence : exploration, résolution, rapidité, etc.) (FR43).
  - [ ] 2.2 Backend : exposer les compétences par utilisateur (ex. query `getUserSkills(userId)` ou champs sur `UserProgress` : niveau, XP ou équivalent). Règles de progression dérivées de la progression (énigmes résolues, enquêtes complétées) (FR43).
  - [ ] 2.3 Flutter : section « Compétences » sur l'écran gamification ; indicateurs visuels (barres, niveaux) (FR43).
- [ ] **Task 3** (AC1) – Cartes postales virtuelles
  - [ ] 3.1 Afficher les cartes postales virtuelles collectées (lieux découverts pendant les enquêtes) (FR44).
  - [ ] 3.2 Backend : exposer les cartes postales par utilisateur (ex. query `getUserPostcards(userId)` ou champs sur `UserProgress` : liste de lieux/énigmes « découverts »). Données : image, lieu, date de déblocage (FR44).
  - [ ] 3.3 Flutter : section « Cartes postales » sur l'écran gamification ; galerie ou grille (débloquées avec image, non débloquées placeholder) (FR44).
- [ ] **Task 4** (AC1) – Leaderboard
  - [ ] 4.1 Afficher le classement leaderboard (ex. par enquête, global : score ou temps ou nombre d'énigmes) (FR45).
  - [ ] 4.2 Backend : exposer le leaderboard (ex. query `getLeaderboard(investigationId?)` ou `getGlobalLeaderboard()` : liste utilisateurs avec score/rang). Données : agrégation des scores ou métriques (complétions, temps, etc.) (FR45).
  - [ ] 4.3 Flutter : section « Leaderboard » sur l'écran gamification ; liste ou tableau (rang, pseudo ou userId, score) ; position de l'utilisateur mise en évidence (FR45).
- [ ] **Task 5** (AC1) – Section gamification et navigation
  - [ ] 5.1 Créer une section « Gamification » ou « Accomplissements » accessible depuis le profil/progression (5.1) : onglet, sous-écran ou route ex. `/profile/gamification` (FR42–FR45).
  - [ ] 5.2 Regrouper badges, compétences, cartes postales et leaderboard sur cet écran ; design system « carnet de détective » ; accessibilité WCAG 2.1 Level A (FR42–FR45).
- [ ] **Task 6** – Qualité et conformité
  - [ ] 6.1 Backend : test d'intégration pour les queries badges, compétences, cartes postales, leaderboard si implémentées (ex. `tests/api/gamification_test.rs` ou équivalent) – au moins un cas nominal (FR42–FR45).
  - [ ] 6.2 Flutter : tests widget pour l'écran gamification (présence sections badges, compétences, cartes postales, leaderboard) ; mocker API (FR42–FR45).
  - [ ] 6.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 5.1.
  - [ ] 6.4 Accessibilité : labels pour badges, compétences, cartes postales, leaderboard (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 5.2 = gamification avancée (V1.0+).** S'appuie sur 5.1 (écran profil/progression). Badges, compétences, cartes postales et leaderboard (FR42–FR45) peuvent être implémentés avec une structure minimale : modèles backend, queries GraphQL, écran Flutter avec sections ; données mock ou dérivées de la progression (5.1, 4.1, 4.2) pour le MVP/V1.0.
- **Flutter** : Feature `lib/features/profile/` (architecture) ; écran ou section « Gamification » (badges, compétences, cartes postales, leaderboard). Réutiliser l'écran profil/progression (5.1) ; ajouter onglet ou route gamification (FR42–FR45).
- **Backend** : Modèles et queries pour badges, compétences, cartes postales, leaderboard ; règles de déblocage basées sur la progression (enquêtes complétées, énigmes résolues). Peut être simplifié pour V1.0 (ex. badges basés sur completed_investigation_count, leaderboard sur liste fictive ou agrégation minimale).

### Project Structure Notes

- **Flutter** : `lib/features/profile/screens/gamification_screen.dart` (ou section dans `profile_screen.dart`) ; providers pour badges, compétences, cartes postales, leaderboard. Route ex. `/profile/gamification` dans `lib/core/router/app_router.dart` (FR42–FR45).
- **Backend** : `src/services/gamification_service.rs` ou extension `user_service` ; queries GraphQL `getUserBadges`, `getUserSkills`, `getUserPostcards`, `getLeaderboard`. Tables : `badges`, `user_badges`, `user_skills`, `user_postcards`, `leaderboard_entries` ou équivalent (FR42–FR45).
- [Source: architecture.md § Progression & Gamification, profile/]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 5, Story 5.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – profile/, Progression]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 5.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/profile/` (screens gamification, providers) ; route `/profile/gamification` |
| Structure Backend | `src/services/` (gamification_service ou user_service) ; queries GraphQL getUserBadges, getLeaderboard, etc. |
| État Flutter | `AsyncValue` pour chargement badges, compétences, cartes postales, leaderboard ; pas de booléen `isLoading` séparé |
| API GraphQL | Queries pour gamification ; champs camelCase ; IDs opaques (FR42–FR45) |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour sections gamification |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Pas de nouvelle dépendance obligatoire pour 5.2 (affichage grilles, listes, barres de progression = widgets Flutter standard).
- **Backend** : Pas de nouvelle dépendance obligatoire ; agrégations et règles métier en Rust (FR42–FR45).
- [Source: architecture.md – profile/, Progression]

---

## File Structure Requirements

- **Flutter** : `lib/features/profile/screens/gamification_screen.dart` ; `lib/features/profile/providers/` (badges_provider, skills_provider, postcards_provider, leaderboard_provider) ; route dans `lib/core/router/app_router.dart`. Fichiers GraphQL : queries `getUserBadges`, `getUserSkills`, `getUserPostcards`, `getLeaderboard`.
- **Backend** : `src/services/gamification_service.rs` (ou modules badges, skills, postcards, leaderboard) ; `src/api/graphql/queries.rs`. Migrations sqlx si tables badges, user_badges, user_skills, user_postcards, leaderboard_entries (FR42–FR45).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour les queries gamification (badges, compétences, cartes postales, leaderboard) si implémentées (ex. `tests/api/gamification_test.rs`) – au moins un cas nominal (FR42–FR45).
- **Flutter** : Tests widget pour l'écran gamification (présence sections badges, compétences, cartes postales, leaderboard) ; mocker les queries GraphQL (FR42–FR45).
- **Qualité** : Pas de régression sur 5.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 5.1)

- **Écran profil/progression** : 5.1 fournit l'écran avec statut par enquête, progression globale, historique complété. En 5.2, ajouter un accès à la section « Gamification » (onglet, bouton ou route `/profile/gamification`) et afficher badges, compétences, cartes postales, leaderboard (FR42–FR45).
- **Données** : Réutiliser la progression (5.1, Hive/API) pour dériver les déblocages (badges basés sur enquêtes complétées, énigmes résolues ; compétences sur même logique ; cartes postales sur lieux/énigmes découverts ; leaderboard sur agrégation scores ou métriques) (FR42–FR45).
- **Ne pas dupliquer** : un seul écran gamification ; une seule source pour les règles de déblocage (backend ou logique partagée).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **V1.0+** : Story marquée V1.0+ dans les epics ; implémentation possible avec structure minimale et données mock pour livraison progressive (FR42–FR45).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
