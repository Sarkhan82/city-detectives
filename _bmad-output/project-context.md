---
project_name: city-detectives
user_name: Sarkhan
date: '2026-01-26'
source: _bmad-output/planning-artifacts/architecture.md
---

# Project Context for AI Agents

_Ce fichier contient les règles et patterns critiques que les agents doivent suivre lors de l'implémentation. Référence complète : `_bmad-output/planning-artifacts/architecture.md`. Les AC des stories ne doivent pas contredire l'architecture._

---

## Technology Stack & Versions

**Frontend (Flutter)**  
- Dart (Flutter SDK) ; Riverpod 2.0+ (pattern Notifier) ; GoRouter ; Hive + hive_generator ; graphql_flutter 5.2.1 ; flutter_secure_storage ; geolocator, firebase_messaging, in_app_purchase selon besoins.

**Backend (Rust)**  
- Rust (stable) ; Axum ; PostgreSQL + sqlx 0.8.x ; async-graphql 7.1.0 + async-graphql-axum 7.2.1 ; jsonwebtoken, bcrypt ; tower-governor 0.8.0, tower-http 0.6.8 ; tracing + tracing-subscriber ; validator ; Tokio.

**Infra**  
- Docker (PostgreSQL, backend, Nginx) ; GitHub Actions ; Sentry (Flutter) ; logging structuré JSON (Rust).

---

## Critical Implementation Rules

### Référence architecture
- **Source de vérité :** `_bmad-output/planning-artifacts/architecture.md`. Consulter pour toute décision technique. Les critères d'acceptation des stories ne doivent pas contredire ce document.

### Nommage
- **DB (PostgreSQL/sqlx)** : tables et colonnes en `snake_case` ; FK `{table}_id` ; index `idx_{table}_{column}`.
- **GraphQL** : types `PascalCase`, champs `camelCase`, queries/mutations `camelCase` verbe. Types exposés avec **nom explicite** (pas de types anonymes).
- **Dart** : classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase`.
- **Rust** : types `PascalCase`, fichiers/fonctions/variables `snake_case`, constantes `SCREAMING_SNAKE_CASE`.

### Structure
- **Flutter** : `lib/core/` (services, repositories, models, graphql, router), `lib/features/{feature}/` (onboarding, investigation, enigma, profile), `lib/shared/` (widgets, utils). Fichiers GraphQL : `lib/core/graphql/` ou `lib/features/{feature}/graphql/`, nom `snake_case.graphql` (ex. `get_user.graphql`). **Énigmes** : un sous-dossier par type sous `lib/features/enigma/types/` (photo, geolocation, words, puzzle, etc.).
- **Rust** : `src/api/` (graphql, handlers, middleware), `src/services/`, `src/models/`, `src/config/`, `src/db/`. Tests d'intégration API dans `tests/api/` : `auth_test.rs`, `investigations_test.rs`, `enigmas_test.rs`.
- **Tests Flutter** : `test/` miroir de `lib/` ; nom `{fichier}_test.dart`. E2E dans `integration_test/`.

### Formats & API
- **GraphQL** : réponse standard `{ data?, errors? }` ; pas de wrapper custom. Erreurs avec `message`, `path`, `extensions.code`. Dates **ISO 8601** en string. IDs en UUID (string). Backend = **schéma canonique** ; Flutter conforme.
- **JSON** : champs `camelCase` (serde rename côté Rust). Booléens `true`/`false`. Null explicite.

### Flutter (Riverpod, état, erreurs)
- **État** : immuable ; Notifier/AsyncNotifier avec `state = newState`. Providers `xxxProvider` ; Notifiers `XxxNotifier` / `XxxAsyncNotifier`.
- **Chargement/erreur** : **toujours** `AsyncValue<T>` pour données async ; pas de `isLoading` booléen séparé. Pas de loader global sauf cas explicite (ex. splash).
- **Navigation** : GoRouter (déclaratif) ; pas de bus d'events global ; utiliser `ref.invalidate`, callbacks ou paramètres de route.
- **Validation** : backend = source de vérité ; Flutter affiche les erreurs API, pas de validation métier côté client pour le MVP.

### Tests
- **Structure** : Arrange / Act / Assert (ou Given / When / Then) pour les cas non triviaux.
- **Backend** : au moins un test d'intégration API par domaine (auth, investigations, enigmas) pour considérer le domaine implémenté.

### Quality gates (avant merge)
- Flutter : `dart analyze` + `dart format` + `flutter test` verts.
- Rust : `cargo test` + `clippy` + `rustfmt` verts.

### Accessibilité
- NFR : WCAG 2.1 Level A. Inclure critères (contraste, focus, tailles tactiles, screen readers) dans les AC des écrans clés et dans le design system (shared widgets).

---

## Anti-patterns à éviter

- Mélanger camelCase et snake_case dans la même couche (ex. champs GraphQL en snake_case).
- Fichiers Flutter en `PascalCase.dart` ou Rust en camelCase pour fonctions.
- Dates en timestamp entier ou format libre dans l'API.
- Loader global + booléen `isLoading` au lieu d'`AsyncValue<T>`.
- Wrapper custom autour des réponses GraphQL.
- Logs contenant tokens ou mots de passe.
- Fichiers `.env` committés (toujours dans `.gitignore`).

---

## First implementation priority

1. `flutter create city_detectives --org com.citydetectives` et `cargo new city-detectives-api --bin`.
2. Structurer les dossiers selon Project Structure & Boundaries dans `architecture.md`.
3. Mettre en place Docker (PostgreSQL, backend, Nginx) et CI (GitHub Actions).
