# Story 7.3: Prévisualisation, publication et rollback

**Story ID:** 7.3  
**Epic:** 7 – Admin & Content Management  
**Story Key:** 7-3-previsualisation-publication-rollback  
**Status:** done  
**Depends on:** Story 7.2  
**Parallelizable with:** Story 3.1  
**Lane:** B  
**FR:** FR65, FR66, FR67  

---

## Story

As an **admin**,  
I want **prévisualiser une enquête avant publication, la publier pour les utilisateurs, et faire un rollback en cas d'erreur**,  
So that **les utilisateurs ne voient que du contenu validé**.

---

## Acceptance Criteria

1. **Given** une enquête est prête  
   **When** l'admin prévisualise puis publie  
   **Then** la prévisualisation reflète l'expérience utilisateur (FR65)  
   **And** la publication rend l'enquête disponible (FR66)  
   **And** un rollback est possible si des erreurs sont détectées (FR67)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Prévisualisation (FR65)
  - [x] 1.1 Backend : query ou mode « prévisualisation » pour une enquête (ex. `getInvestigationForPreview(id)` ou `getInvestigation(id, preview: true)`) retournant l’enquête et ses énigmes même si statut brouillon, réservée aux admins (FR65).
  - [x] 1.2 Flutter : écran ou mode prévisualisation dans l’admin : afficher l’enquête comme un utilisateur la verrait (liste énigmes, contenu, ordre) — réutilisation des widgets/écrans app si possible (ex. lecture seule du parcours) ou vue dédiée « preview » (FR65).
  - [x] 1.3 Accès depuis l’édition d’une enquête (7.2) : bouton « Prévisualiser » ouvrant cette vue (FR65).
- [x] **Task 2** (AC1) – Publication (FR66)
  - [x] 2.1 Backend : mutation ex. `publishInvestigation(id)` réservée aux admins ; met à jour le statut de l’enquête (ex. `status: draft` → `published`) et éventuellement `published_at` (FR66).
  - [x] 2.2 Backend : s’assurer que les queries côté app utilisateur (ex. `listInvestigations`) ne retournent que les enquêtes publiées (filtrer par `status = published`) ; les admins voient brouillons et publiées (FR66).
  - [x] 2.3 Flutter admin : depuis l’écran édition ou détail d’une enquête brouillon, bouton « Publier » ; appel à `publishInvestigation` ; feedback succès et rafraîchissement (FR66).
  - [x] 2.4 Après publication, l’enquête apparaît dans le catalogue utilisateur (2.1, 2.2) sans action supplémentaire (FR66).
- [x] **Task 3** (AC1) – Rollback (FR67)
  - [x] 3.1 Backend : mutation ex. `rollbackInvestigation(id)` (ou `unpublishInvestigation`) réservée aux admins ; remet le statut à brouillon (ou à une version précédente si historique implémenté) (FR67).
  - [x] 3.2 Sémantique rollback : au minimum « dépublier » (l’enquête n’est plus visible pour les utilisateurs) ; optionnel : restaurer une version précédente (snapshot/historique) si défini en 7.2 (FR67).
  - [x] 3.3 Flutter admin : pour une enquête publiée, bouton « Rollback » (ou « Dépublier ») avec confirmation ; appel à la mutation ; rafraîchissement (FR67).
- [x] **Task 4** – Cohérence catalogue et qualité
  - [x] 4.1 Vérifier que le catalogue app (listInvestigations) filtre bien sur `status = published` (et éventuellement autres critères métier) ; pas de fuite de brouillons côté utilisateur (FR66, FR67).
  - [x] 4.2 Backend : tests d’intégration pour publishInvestigation (enquête devient visible côté query catalogue) et rollbackInvestigation (enquête n’apparaît plus) ; accès prévisualisation avec JWT admin (FR65, FR66, FR67).
  - [x] 4.3 Flutter : tests widget pour boutons Prévisualiser, Publier, Rollback et confirmation ; mocker les mutations (FR65, FR66, FR67).
  - [x] 4.4 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 7.1, 7.2, 2.1, 2.2.
  - [x] 4.5 Accessibilité : labels pour Prévisualiser, Publier, Rollback (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 7.3 = cycle publication / rollback.** S’appuie sur 7.2 (enquêtes et énigmes éditables, statut brouillon/publié). Prévisualisation = voir l’enquête comme l’utilisateur (FR65) ; publication = rendre visible dans le catalogue (FR66) ; rollback = dépublier ou revenir en arrière (FR67).
- **Statut enquête** : en 7.2 un statut type `draft` / `published` (ou équivalent) est prévu. Ici on utilise ce statut pour publier (draft → published) et rollback (published → draft). Si historique des versions est prévu plus tard, rollback peut restaurer une version antérieure.
- **Prévisualisation** : idéalement réutiliser les écrans/parcours de l’app (mode lecture seule ou sans sauvegarde de progression) pour que « reflète l’expérience utilisateur » soit garanti ; sinon une vue admin dédiée (liste énigmes + contenu) acceptable pour le MVP.

### Project Structure Notes

- **Flutter** : `lib/features/admin/` — écran ou mode prévisualisation (ex. `investigation_preview_screen.dart` ou réutilisation de `lib/features/investigation/` en mode preview) ; boutons Publier / Rollback sur l’écran détail/édition enquête (7.2). Mutations GraphQL `publish_investigation.graphql`, `rollback_investigation.graphql`.
- **Backend** : `src/services/investigation_service.rs` (ou admin_service) avec `publish_investigation`, `rollback_investigation` ; query prévisualisation (ou paramètre sur getInvestigation) ; filtrage par `status` dans `list_investigations` pour les utilisateurs non-admin.
- [Source: architecture.md § Requirements to Structure Mapping, Admin]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 7, Story 7.3]
- [Source: _bmad-output/planning-artifacts/architecture.md – Project Structure, investigation_service]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]
- [Source: Story 7.2 – statut draft/published]

---

## Architecture Compliance

| Règle | Application pour 7.3 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/admin/` – prévisualisation, boutons Publier/Rollback ; réutilisation investigation si possible |
| Structure Backend | `investigation_service.rs` (publish, rollback) ; filtrage status dans listInvestigations |
| API GraphQL | Mutations publishInvestigation, rollbackInvestigation ; query preview réservée aux admins ; champs camelCase |
| Catalogue utilisateur | listInvestigations ne retourne que les enquêtes publiées pour les non-admins |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels Prévisualiser, Publier, Rollback |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Aucune nouvelle dépendance obligatoire pour 7.3.
- **Backend** : Réutilisation de async-graphql, sqlx ; pas de nouvelle dépendance.
- [Source: architecture.md – GraphQL]

---

## File Structure Requirements

- **Flutter** : `lib/features/admin/screens/investigation_preview_screen.dart` (ou équivalent) ; boutons Publier/Rollback dans l’écran d’édition/détail enquête (7.2) ; `lib/features/admin/graphql/publish_investigation.graphql`, `rollback_investigation.graphql`, et query preview si dédiée.
- **Backend** : `src/services/investigation_service.rs` (publish_investigation, rollback_investigation) ; `src/api/graphql/mutations.rs` (publishInvestigation, rollbackInvestigation) ; dans list_investigations (ou resolver), filtre `status = published` pour les appels non-admin.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d’intégration : publishInvestigation → ensuite listInvestigations (sans rôle admin) retourne l’enquête ; rollbackInvestigation → listInvestigations ne la retourne plus. Test prévisualisation avec JWT admin (accès à une enquête brouillon). Test refus des mutations avec JWT non-admin.
- **Flutter** : Tests widget pour écran prévisualisation (présence du contenu) et pour boutons Publier/Rollback avec confirmation ; mocker les mutations.
- **Qualité** : Pas de régression sur 7.1, 7.2, 2.1, 2.2 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 7.2)

- **7.2** introduit les mutations create/update pour enquêtes et énigmes et un statut (draft/published) pour préparer 7.3. En 7.3 on utilise ce statut pour publier (draft → published) et rollback (published → draft). Les écrans d’édition (7.2) reçoivent les boutons Prévisualiser, Publier et Rollback.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Catalogue** : côté app (2.1, 2.2), seules les enquêtes publiées sont visibles ; l’admin voit toutes les enquêtes (brouillons et publiées) pour pouvoir prévisualiser, publier et rollback.

---

## Change Log

- 2026-02-03 : Implémentation complète (FR65, FR66, FR67) – prévisualisation, publication, rollback ; backend + Flutter admin ; tests d'intégration.
- 2026-02-03 : Code review (adversarial) – 7 constats (1 critique, 2 hauts, 2 moyens, 2 bas). Corrections appliquées : messages d’erreur utilisateur, gestion `status` null, Semantics bouton erreur, tests widget prévisualisation/liste/détail (Task 4.3), correction `context.go(AppRouter.adminInvestigationListPath())`.

---

## Senior Developer Review (AI)

**Date :** 2026-02-03  
**Verdict :** Changes Requested → **Approuvé** (après corrections)

**Problèmes identifiés et résolus :**
- **[CRITICAL]** Task 4.3 marquée [x] sans tests widget → ajout de `investigation_preview_screen_test.dart`, `admin_investigation_list_screen_test.dart`, `admin_investigation_detail_screen_test.dart` (8 tests, providers mockés).
- **[HIGH]** Messages d’erreur techniques dans SnackBar (detail) → remplacés par messages utilisateur (« Impossible de publier / dépublier l’enquête. Réessayez plus tard. »).
- **[HIGH]** `status` null non géré (list + detail) → détail : `status ?? 'draft'` ; liste : affichage « — » si `status` null ou vide.
- **[MEDIUM]** Semantics manquant sur bouton « Retour au dashboard » (preview, état erreur) → ajout de `Semantics(label: 'Retour au dashboard admin', …)`.
- Correction : `context.go(AppRouter.adminInvestigationListPath())` (appel de la méthode).

**Fichiers modifiés pour la revue :** admin_investigation_detail_screen.dart, admin_investigation_list_screen.dart, investigation_preview_screen.dart ; ajout des 3 fichiers de test ci-dessus.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Story 7.3 implémentée (2026-02-03). Backend : query `investigationForPreview(id)` admin-only ; `investigation(id)` ne retourne pas les brouillons aux non-admins ; `listInvestigations` filtre `status = published` pour non-admin ; mutations `publishInvestigation(id)` et `rollbackInvestigation(id)` ; tests admin_test.rs (preview, publish, rollback, list filter). Flutter : écran prévisualisation, liste admin, détail admin avec boutons Prévisualiser / Publier / Rollback (confirmation) ; routes ShellRoute /admin avec enfants ; labels Semantics WCAG 2.1 Level A.
- 2026-02-03 (code review) : Corrections appliquées (erreurs utilisateur, status null, Semantics, tests widget Task 4.3, go(adminInvestigationListPath())).

### File List

- city-detectives-api/src/api/graphql.rs
- city-detectives-api/src/services/investigation_service.rs
- city-detectives-api/tests/api/admin_test.rs
- city_detectives/lib/features/admin/providers/dashboard_provider.dart
- city_detectives/lib/features/admin/repositories/admin_investigation_repository.dart
- city_detectives/lib/features/admin/screens/admin_investigation_detail_screen.dart
- city_detectives/lib/features/admin/screens/admin_investigation_list_screen.dart
- city_detectives/lib/features/admin/screens/dashboard_screen.dart
- city_detectives/lib/features/admin/screens/investigation_preview_screen.dart
- city_detectives/lib/features/admin/widgets/admin_route_guard.dart
- city_detectives/lib/core/router/app_router.dart
- city_detectives/lib/features/investigation/models/investigation.dart
- city_detectives/lib/features/investigation/repositories/investigation_repository.dart
- city_detectives/test/features/admin/screens/investigation_preview_screen_test.dart
- city_detectives/test/features/admin/screens/admin_investigation_list_screen_test.dart
- city_detectives/test/features/admin/screens/admin_investigation_detail_screen_test.dart
- _bmad-output/implementation-artifacts/sprint-status.yaml

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
