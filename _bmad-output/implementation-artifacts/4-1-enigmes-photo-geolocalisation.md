# Story 4.1: Énigmes photo et géolocalisation

**Story ID:** 4.1  
**Epic:** 4 – Énigmes & Content  
**Story Key:** 4-1-enigmes-photo-geolocalisation  
**Status:** done  
**Depends on:** Story 3.2  
**Parallelizable with:** Story 7.4  
**Lane:** B  
**FR:** FR23, FR24, FR28, FR29, FR33  

---

## Story

As a **utilisateur**,  
I want **résoudre des énigmes photo (prendre une photo d'un point précis) et géolocalisation (atteindre un lieu)**,  
So that **je progresse dans l'enquête en explorant la ville**.

---

## Acceptance Criteria

1. **Given** une énigme photo ou géo est affichée  
   **When** l'utilisateur prend une photo du bon point ou atteint le lieu (précision <10 m)  
   **Then** la réponse est validée et un retour positif est affiché (FR23, FR24, FR28)  
   **And** en cas d'erreur, un retour explicite est fourni (FR29)  
   **And** si la caméra est refusée, la galerie peut être utilisée en fallback (FR33)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Backend : validation énigmes photo et géo
  - [x] 1.1 Schéma GraphQL : types pour énigmes photo et géolocalisation (ex. `PhotoEnigma`, `GeolocationEnigma` ou interface `Enigma` avec type discriminant) ; champs : point cible (lat/lng ou référence photo), tolérance (mètres pour géo) (FR23, FR24).
  - [x] 1.2 Mutation ou query de validation : ex. `validateEnigmaResponse(enigmaId, payload)` – payload = photo (URL/base64 ou ref) ou coordonnées utilisateur ; retour = validé / non validé + message (FR28, FR29).
  - [x] 1.3 Service `src/services/enigma_service.rs` (ou modules `enigma/photo.rs`, `enigma/geolocation.rs`) : validation photo (comparaison avec référence ou seuil de similarité) ; validation géo (distance <10 m entre position utilisateur et point cible, ex. formule Haversine ou crate `geo`) (FR72, FR73 pour précision).
- [x] **Task 2** (AC1) – Flutter : énigme photo
  - [x] 2.1 Créer `lib/features/enigma/types/photo/` : écran ou widget « énigme photo » (titre, consigne, bouton Prendre une photo) (FR23).
  - [x] 2.2 Intégration `camera` et/ou `image_picker` : prise de photo ; si permission caméra refusée, proposer galerie en fallback (FR33).
  - [x] 2.3 Envoi de la photo (ou référence) au backend pour validation ; affichage retour positif si validé (FR28), message explicite si erreur (FR29).
- [x] **Task 3** (AC1) – Flutter : énigme géolocalisation
  - [x] 3.1 Créer `lib/features/enigma/types/geolocation/` : écran ou widget « énigme géo » (titre, consigne, objectif à atteindre, indicateur de distance ou « Vous y êtes ! ») (FR24).
  - [x] 3.2 Utiliser `lib/core/services/geolocation_service.dart` pour obtenir la position actuelle ; précision <10 m (Story 3.4). Envoyer les coordonnées au backend pour validation (FR24, FR72, FR73).
  - [x] 3.3 Retour positif si validé (FR28), message explicite si erreur (ex. « Vous n'êtes pas encore au bon endroit ») (FR29).
- [x] **Task 4** (AC1) – Intégration écran enquête et progression
  - [x] 4.1 Depuis l'écran enquête en cours (3.1), selon le type de l'énigme courante (photo / géo), afficher le widget/écran correspondant (types dans `lib/features/enigma/types/`).
  - [x] 4.2 Après validation réussie : marquer l'énigme comme complétée (mise à jour progression 3.2/3.3), afficher retour positif, passer à l'énigme suivante ou écran de fin d'enquête selon le flux.
  - [x] 4.3 Design system « carnet de détective » ; feedback visuel riche (FR28, FR29) ; accessibilité WCAG 2.1 Level A.
- [x] **Task 5** – Qualité et conformité
  - [x] 5.1 Backend : test d'intégration pour la validation énigmes photo et géo (ex. `tests/api/enigmas_test.rs`) – cas validé / non validé (FR28, FR29).
  - [x] 5.2 Flutter : tests widget pour écran énigme photo (prise photo, fallback galerie) et énigme géo (affichage, envoi position) ; mocker geolocation_service et API validation.
  - [x] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 3.1–3.4.

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 4.1 = premier type d'énigmes résolubles.** S'appuie sur 3.2 (progression, carte, position) ; l'utilisateur est déjà sur l'écran enquête avec navigation entre énigmes (3.1). Ici on ajoute la **résolution** pour les types photo et géolocalisation : prise de photo ou atteinte du lieu, validation backend, feedback.
- **Flutter** : Structure par type d'énigme sous `lib/features/enigma/types/photo/` et `lib/features/enigma/types/geolocation/` (architecture). Réutiliser `geolocation_service` (3.2, 3.4) ; ajouter `camera` / `image_picker` pour la photo. Riverpod pour l'état énigme (chargement, envoi, résultat).
- **Backend** : GraphQL polymorphique pour les 12 types d'énigmes (architecture) ; pour 4.1, implémenter uniquement photo et géo. Validation : distance <10 m pour géo (crate `geo` ou Haversine) ; photo : comparaison ou validation manuelle côté admin en V1 (ou seuil de similarité si traitement d'image).

### Project Structure Notes

- **Flutter** : `lib/features/enigma/types/photo/` (screens, widgets, providers si besoin) ; `lib/features/enigma/types/geolocation/` (idem). `lib/features/enigma/` peut contenir un routeur ou dispatcher qui affiche le bon type selon l'énigme courante. Réutiliser `lib/core/services/geolocation_service.dart`.
- **Backend** : `src/services/enigma_service.rs` ; modules `src/services/enigma/photo.rs`, `geolocation.rs` si découpage ; `src/api/graphql/` (mutations/queries validation). Tables : `enigma_responses` ou équivalent pour tracer les réponses (optionnel pour 4.1 ; peut être ajouté en 4.2+).
- [Source: architecture.md § Énigme Resolution & Validation, Requirements to Structure Mapping]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 4, Story 4.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – Enigma types, GraphQL, Géolocalisation]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 4.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/enigma/types/photo/`, `lib/features/enigma/types/geolocation/` |
| Structure Backend | `src/services/enigma_service.rs`, `src/api/graphql/`, modules enigma/photo, geolocation |
| État Flutter | `AsyncValue` pour chargement/envoi validation ; pas de booléen `isLoading` séparé |
| API GraphQL | Types nommés (PhotoEnigma, GeolocationEnigma ou interface) ; mutation validateEnigmaResponse ; champs camelCase |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour boutons photo, message validation/erreur |

---

## Library / Framework Requirements

- **Flutter** : `camera` et/ou `image_picker` (architecture) ; `geolocator` déjà en place (3.2, 3.4). Riverpod, GoRouter, graphql_flutter pour appeler la mutation de validation.
- **Backend** : `geo` (Rust) ou calcul Haversine pour distance géo ; async-graphql pour types polymorphiques ; pas de traitement d'image obligatoire pour MVP (validation photo peut être manuelle ou par référence d'URL).
- [Source: architecture.md – Packages Flutter clés, Backend stack]

---

## File Structure Requirements

- **Flutter** : `lib/features/enigma/types/photo/` – ex. `photo_enigma_screen.dart`, `photo_enigma_widget.dart` ; `lib/features/enigma/types/geolocation/` – ex. `geolocation_enigma_screen.dart`, `geolocation_enigma_widget.dart`. Fichiers GraphQL pour mutation validation dans `lib/features/enigma/graphql/` (ex. `validate_enigma_response.graphql`).
- **Backend** : `src/services/enigma_service.rs` ; `src/services/enigma/photo.rs`, `geolocation.rs` ; `src/api/graphql/mutations.rs` (validateEnigmaResponse). Migrations sqlx si table `enigma_responses` ou équivalent.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour validation énigme géo (distance <10 m → validé ; >10 m → non validé) et énigme photo (mock ou payload minimal → validé/non validé) (FR28, FR29).
- **Flutter** : Tests widget pour écran énigme photo (bouton prise photo, fallback galerie si permission refusée) et écran énigme géo (affichage, envoi position) ; mocker geolocation_service et client GraphQL.
- **Qualité** : Pas de régression sur 3.1–3.4 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Dependency Context (Story 3.2)

- **Story 3.2** fournit : écran enquête en cours, progression affichée, carte, position utilisateur (geolocation_service). En 4.1, on réutilise la position pour les énigmes géo et on ajoute la prise de photo pour les énigmes photo. L'affichage de l'énigme courante (3.1) doit être étendu pour afficher le contenu selon le type (photo ou géo).
- **Ne pas dupliquer** : réutiliser `geolocation_service` pour la position ; ne pas recréer un service de géoloc dans la feature enigma.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Précision géo** : <10 m (NFR, architecture) ; validation côté backend avec tolérance configurable.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Backend : schéma GraphQL (PhotoEnigma, GeolocationEnigma, ValidateEnigmaPayload, ValidateEnigmaResult), mutation validateEnigmaResponse, EnigmaService avec validation géo (Haversine <10 m) et photo (présence photo en MVP). IDs énigmes déterministes (UUID v5) partagés avec InvestigationService. Tests intégration enigmas_test.rs (géolocalisation validé/non validé, photo validé/non validé).
- Flutter : PhotoEnigmaWidget (image_picker caméra puis galerie fallback, envoi base64, feedback validé/erreur), GeolocationEnigmaWidget (geolocation_service, envoi coords, feedback). Intégration dans InvestigationPlayScreen via _EnigmaContent selon type (photo/geolocation). EnigmaValidationRepository + provider. Tests widget photo et géo (affichage, boutons).
- Quality gates : dart analyze, flutter test, cargo test, clippy verts.

### File List

- city-detectives-api/Cargo.toml
- city-detectives-api/src/lib.rs
- city-detectives-api/src/main.rs
- city-detectives-api/src/models/enigma.rs
- city-detectives-api/src/services/enigma_service.rs
- city-detectives-api/src/services/mod.rs
- city-detectives-api/src/services/investigation_service.rs
- city-detectives-api/src/api/graphql.rs
- city-detectives-api/tests/api/enigmas_test.rs
- city_detectives/pubspec.yaml
- city_detectives/lib/features/enigma/repositories/enigma_validation_repository.dart
- city_detectives/lib/features/enigma/providers/enigma_validation_provider.dart
- city_detectives/lib/features/enigma/types/photo/photo_enigma_widget.dart
- city_detectives/lib/features/enigma/types/geolocation/geolocation_enigma_widget.dart
- city_detectives/lib/features/investigation/screens/investigation_play_screen.dart
- city_detectives/test/features/enigma/types/photo/photo_enigma_widget_test.dart
- city_detectives/test/features/enigma/types/geolocation/geolocation_enigma_widget_test.dart
- city-detectives-api/Cargo.lock
- city_detectives/pubspec.lock
- city_detectives/windows/flutter/generated_plugin_registrant.cc
- city_detectives/windows/flutter/generated_plugins.cmake
- _bmad-output/implementation-artifacts/sprint-status.yaml
- _bmad-output/implementation-artifacts/4-1-enigmes-photo-geolocalisation.md
- _bmad-output/implementation-artifacts/code-review-4-1-enigmes-photo-geolocalisation.md

### Change Log

- Story 4.1 implémentée : énigmes photo et géolocalisation (backend validation, Flutter widgets, intégration écran enquête, tests). Date : 2026-02-03.
- Code review (2026-02-03) : correctifs appliqués – auth sur validateEnigmaResponse, AsyncValue dans widgets photo/géo, limite 3 Mo photo, client GraphQL authentifié pour enigma, File List complétée, consigne géo « Vous y êtes ! » clarifiée.

### Senior Developer Review (AI)

**Date :** 2026-02-03  
**Résultat :** Approve (après correctifs)

**Points traités :**
- HIGH : Mutation validateEnigmaResponse protégée par auth (Bearer token requis) ; tests enigmas avec token ; client Flutter utilise authToken via authTokenProvider.
- MEDIUM : État d'envoi refactoré en AsyncValue dans photo et géolocation widgets.
- MEDIUM : Limite 3 Mo sur la photo avant envoi base64 ; message explicite si dépassement.
- MEDIUM : File List complétée (Cargo.lock, pubspec.lock, generated_*).
- MEDIUM : Consigne géo précisée : « Validez pour vérifier si vous y êtes (message « Vous y êtes ! » en cas de succès). »

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
