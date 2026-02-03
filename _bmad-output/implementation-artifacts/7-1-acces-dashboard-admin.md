# Story 7.1: Accès dashboard admin

**Story ID:** 7.1  
**Epic:** 7 – Admin & Content Management  
**Story Key:** 7-1-acces-dashboard-admin  
**Status:** done  
**Depends on:** Story 1.2  
**Parallelizable with:** Story 2.1  
**Lane:** B  
**FR:** FR61  

---

## Story

As an **admin**,  
I want **accéder à un dashboard de gestion du contenu**,  
So that **je puisse gérer les enquêtes et les énigmes**.

---

## Acceptance Criteria

1. **Given** un compte admin authentifié  
   **When** l'admin se connecte au dashboard  
   **Then** la vue d'ensemble (contenu, métriques de base) s'affiche (FR61)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Rôle admin et autorisation
  - [x] 1.1 Backend : étendre le modèle User avec un rôle (ex. champ `role` : `user` | `admin` ou `is_admin: bool`) ; migration sqlx si table `users` existe (colonnes `role` ou `is_admin`) (FR61).
  - [x] 1.2 Backend : inclure le rôle dans les claims JWT (ex. `role` ou `isAdmin`) pour que le middleware puisse restreindre les accès admin (FR61).
  - [x] 1.3 Backend : middleware ou guard « admin only » : vérifier que le JWT contient le rôle admin avant d’autoriser l’accès aux resolvers/queries du dashboard (FR61).
  - [x] 1.4 Flutter : après connexion, si l’utilisateur est admin, afficher un accès au dashboard (lien, onglet ou route dédiée) ; sinon ne pas exposer l’entrée (FR61).
- [x] **Task 2** (AC1) – API dashboard (vue d’ensemble)
  - [x] 2.1 Backend : query GraphQL ex. `getAdminDashboard` ou `getDashboardOverview` réservée aux admins, retournant une vue d’ensemble : par ex. nombre d’enquêtes (total, publiées, brouillons), nombre d’énigmes, métriques de base (optionnel : derniers comptes créés, dernière activité) (FR61).
  - [x] 2.2 Backend : service dédié ex. `admin_service.rs` ou `dashboard_service.rs` qui agrège les données (enquêtes, énigmes, compteurs) ; pas de logique métier lourde dans le resolver (FR61).
  - [x] 2.3 Schéma GraphQL : type nommé ex. `DashboardOverview` avec champs camelCase (ex. `investigationCount`, `publishedCount`, `enigmaCount`, `draftCount`) (FR61).
- [x] **Task 3** (AC1) – Interface dashboard (Flutter ou web)
  - [x] 3.1 Flutter : feature `lib/features/admin/` avec écran dashboard (ex. `dashboard_screen.dart`) affichant la vue d’ensemble : cartes ou listes pour contenu (enquêtes, énigmes) et métriques de base (FR61).
  - [x] 3.2 Navigation : route protégée (ex. `/admin` ou `/admin/dashboard`) accessible uniquement si l’utilisateur connecté est admin ; redirection vers home ou login si non-admin (FR61).
  - [x] 3.3 Provider/Repository : appeler la query `getAdminDashboard` (ou équivalent) ; afficher les données avec `AsyncValue` ; gérer erreur (ex. 403) avec message clair (FR61).
  - [x] 3.4 Design : cohérent avec le reste de l’app (design system existant) ; lisibilité des chiffres et libellés (FR61).
- [x] **Task 4** – Qualité et conformité
  - [x] 4.1 Backend : test d’intégration pour la query dashboard avec JWT admin (données retournées) et avec JWT utilisateur normal (erreur 403 / UNAUTHORIZED) (FR61).
  - [x] 4.2 Flutter : test widget pour l’écran dashboard (données mockées) et test d’accès refusé pour utilisateur non-admin (FR61).
  - [x] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 1.2.
  - [x] 4.4 Accessibilité : labels pour les métriques et la navigation admin (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 7.1 = premier pas Epic 7.** S’appuie sur 1.2 (auth, JWT, compte utilisateur). On introduit le rôle admin, une API dashboard (vue d’ensemble contenu + métriques de base) et l’interface d’accès (Flutter feature admin). Pas de création/édition de contenu dans 7.1 (7.2).
- **Rôle admin :** Définir comment un compte devient admin (seed en base, migration, ou champ éditable côté backend uniquement) ; le JWT doit refléter le rôle pour que le middleware refuser l’accès aux non-admins.
- **Architecture** indique « Admin, User Feedback → backend `src/api/`, `src/services/` ; frontend feature dédiée ou outil externe ». Ici on choisit une **feature Flutter dédiée** (`lib/features/admin/`) pour le dashboard ; une alternative serait un outil web externe (hors scope de cette story).

### Project Structure Notes

- **Flutter** : `lib/features/admin/` (screens, providers, repositories, graphql) ; écran dashboard ; route `/admin` (ou équivalent) protégée par rôle. Réutilisation de `auth_service` / user pour connaître le rôle.
- **Backend** : `src/services/admin_service.rs` ou `dashboard_service.rs` ; `src/api/graphql/queries.rs` (query getAdminDashboard) ; middleware admin dans `src/api/middleware/` ; table `users` avec colonne `role` ou `is_admin`.
- [Source: architecture.md § Requirements to Structure Mapping, Admin]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 7, Story 7.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – Auth, Project Structure, Admin]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]

---

## Architecture Compliance

| Règle | Application pour 7.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/admin/` – dashboard screen, providers, graphql |
| Structure Backend | `src/services/admin_service.rs` (ou dashboard_service.rs), middleware admin, query getAdminDashboard |
| API GraphQL | Type `DashboardOverview` (nom explicite), champs `camelCase` ; query réservée aux admins |
| Auth | JWT avec claim `role` ou `isAdmin` ; middleware admin-only sur les resolvers dashboard |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels métriques et navigation admin |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Aucune nouvelle dépendance obligatoire pour 7.1 (écran dashboard = widgets + query GraphQL).
- **Backend** : Aucune nouvelle dépendance ; réutilisation de JWT (jsonwebtoken), sqlx pour agrégations (counts). Pas de Sentry/analytics spécifique admin dans 7.1 (7.4).
- [Source: architecture.md – Auth, GraphQL]

---

## File Structure Requirements

- **Flutter** : `lib/features/admin/screens/dashboard_screen.dart` ; `lib/features/admin/providers/dashboard_provider.dart` (ou équivalent) ; `lib/features/admin/repositories/` ou appels GraphQL dans `lib/features/admin/graphql/` (ex. `get_admin_dashboard.graphql`). Route admin dans `lib/core/router/`.
- **Backend** : `src/services/admin_service.rs` (ou `dashboard_service.rs`) ; query dans `src/api/graphql/queries.rs` ; type `DashboardOverview` dans le schéma ; middleware admin (ex. `src/api/middleware/admin.rs`) ; migration pour `users.role` ou `users.is_admin` si nécessaire.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d’intégration avec JWT admin : query `getAdminDashboard` retourne des données cohérentes (compteurs). Test avec JWT utilisateur non-admin : erreur (FORBIDDEN / UNAUTHORIZED).
- **Flutter** : Tests widget pour l’écran dashboard avec données mockées ; test de redirection ou masquage de l’accès admin pour un utilisateur non-admin.
- **Qualité** : Pas de régression sur 1.2 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Dependency Context (Story 1.2)

- **1.2** : Création de compte, JWT, middleware auth. En 7.1 on s’appuie sur le même flux d’auth ; on étend le modèle User avec un rôle (admin/user) et on restreint l’accès au dashboard aux seuls admins. Pas de modification du flux d’inscription utilisateur standard.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Admin** : Dashboard = vue d’ensemble contenu + métriques de base (FR61). Stories 7.2 à 7.4 ajouteront création/édition, publication/rollback, monitoring détaillé.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Task 1 : User.role (Role::User | Admin), JWT claims `role`, require_admin() guard, query `me { id isAdmin }`, Flutter currentUserProvider et lien « Dashboard admin » sur home si isAdmin. Seed admin : `admin@city-detectives.local`.
- Task 2 : AdminService.get_dashboard_overview(), type GraphQL DashboardOverview (camelCase), query getAdminDashboard protégée par require_admin().
- Task 3 : DashboardScreen avec cartes métriques, AdminRouteGuard (redirection si non-admin), DashboardRepository + adminDashboardProvider, AsyncValue et message 403 clair. Design cohérent (Material 3, Semantics).
- Task 4 : tests/api/admin_test.rs (JWT admin → données, JWT user → FORBIDDEN), test/features/admin/screens/dashboard_screen_test.dart (données mockées + 403). dart analyze, flutter test, cargo test, clippy verts. Labels accessibilité (Semantics/semanticLabel) sur métriques et navigation admin.

### File List

- city-detectives-api/src/models/user.rs
- city-detectives-api/src/services/auth_service.rs
- city-detectives-api/src/services/admin_service.rs
- city-detectives-api/src/services/mod.rs
- city-detectives-api/src/api/graphql.rs
- city-detectives-api/src/main.rs
- city-detectives-api/src/lib.rs
- city-detectives-api/Cargo.toml
- city-detectives-api/tests/api/admin_test.rs
- city-detectives-api/tests/api/enigmas_test.rs
- city-detectives-api/tests/api/gamification_test.rs
- city_detectives/lib/core/repositories/user_repository.dart
- city_detectives/lib/core/services/auth_provider.dart
- city_detectives/lib/core/screens/home_screen.dart
- city_detectives/lib/core/router/app_router.dart
- city_detectives/lib/features/admin/models/dashboard_overview.dart
- city_detectives/lib/features/admin/repositories/dashboard_repository.dart
- city_detectives/lib/features/admin/providers/dashboard_provider.dart
- city_detectives/lib/features/admin/screens/dashboard_screen.dart
- city_detectives/lib/features/admin/widgets/admin_route_guard.dart
- city_detectives/test/features/admin/screens/dashboard_screen_test.dart
- city_detectives/test/features/admin/widgets/admin_route_guard_test.dart
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Senior Developer Review (AI)

- **Date :** 2026-02-03  
- **Résultat :** Changes Requested → corrigés automatiquement  
- **Problèmes traités :**  
  - MEDIUM : File List complétée (enigmas_test.rs, gamification_test.rs).  
  - MEDIUM : Test ajouté pour `me { id isAdmin }` avec token admin (admin_test.rs).  
  - MEDIUM : Comportement AdminRouteGuard en erreur documenté (commentaire dans le code).  
  - LOW : Semantics sur le bouton « Retour à l'accueil » du dashboard.  
  - LOW : Test widget AdminRouteGuard (redirection si non-admin, affichage si admin).  
  - LOW : Test unitaire auth `register_with_admin_seed_email_returns_token_with_admin_role`.  
  - LOW : Commentaire sur ADMIN_SEED_EMAIL (config env en prod).  
- **Fichiers modifiés par la review :** auth_service.rs, admin_test.rs, admin_route_guard.dart, dashboard_screen.dart, admin_route_guard_test.dart (nouveau), story File List et Dev Agent Record.

### Change Log

- 2026-02-03 : Story 7.1 implémentée – rôle admin, JWT role, getAdminDashboard, dashboard Flutter, tests et accessibilité (FR61).
- 2026-02-03 : Code review – correctifs appliqués (File List, test me/isAdmin, test guard, test auth admin, Semantics, documentation guard).

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
