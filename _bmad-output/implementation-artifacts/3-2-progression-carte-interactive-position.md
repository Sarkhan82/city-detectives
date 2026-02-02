# Story 3.2: Progression, carte interactive et position

**Story ID:** 3.2  
**Epic:** 3 – Core Gameplay & Navigation  
**Story Key:** 3-2-progression-carte-interactive-position  
**Status:** done  
**Depends on:** Story 3.1  
**Parallelizable with:** —  
**Lane:** A  
**FR:** FR14, FR15, FR17, FR18, FR19  

---

## Story

As a **utilisateur**,  
I want **voir ma progression dans l'enquête, une carte de la ville avec ma position, et un retour visuel sur mes actions**,  
So that **je sache où j'en suis et où aller**.

---

## Acceptance Criteria

1. **Given** une enquête est en cours  
   **When** l'utilisateur consulte la progression ou la carte  
   **Then** la progression (énigmes complétées / restantes) est visible (FR14, FR15)  
   **And** une carte interactive de la ville est affichée, visible ou accessible à la demande (FR17)  
   **And** la position actuelle de l'utilisateur est indiquée sur la carte (FR18)  
   **And** un retour visuel sur la progression est fourni (FR19)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Progression (énigmes complétées / restantes)
  - [x] 1.1 Afficher sur l'écran enquête en cours un indicateur de progression : énigmes complétées vs restantes (ex. « 2/5 énigmes », barre ou stepper) (FR14, FR15)
  - [x] 1.2 État local ou API : savoir quelles énigmes sont « complétées » (pour 3.2, peut être mock ou état local ; validation réelle des énigmes = Epic 4). Mettre à jour l’affichage quand l’utilisateur avance ou « valide » une énigme (placeholder si pas encore de résolution)
  - [x] 1.3 Retour visuel sur la progression : design system « carnet de détective » ; indicateurs clairs (FR19)
- [x] **Task 2** (AC1) – Carte interactive de la ville
  - [x] 2.1 Intégrer une carte interactive (ex. Google Maps / OpenStreetMap via package Flutter : `google_maps_flutter`, `flutter_map`, ou équivalent selon architecture/UX). Carte centrée sur la zone de l’enquête (ville) (FR17)
  - [x] 2.2 Carte visible en permanence sur l’écran enquête ou accessible à la demande (bouton « Voir la carte », panneau rabattable, etc.) selon UX
  - [x] 2.3 Données de la carte : zone/centre de l’enquête (coordonnées ou bounds) depuis le backend ou les métadonnées de l’enquête si disponible
- [x] **Task 3** (AC1) – Position utilisateur sur la carte
  - [x] 3.1 Service de géolocalisation : `lib/core/services/geolocation_service.dart` (architecture) ; package `geolocator` pour obtenir la position actuelle (FR18)
  - [x] 3.2 Afficher la position de l’utilisateur sur la carte (marqueur ou cercle de précision). Widget type `PrecisionCircle` (indicateur GPS) si défini dans le design system
  - [x] 3.3 Demander la permission de localisation au moment approprié (premier accès à la carte ou au démarrage de l’enquête) ; message clair si refusée (Story 3.4 détaille permissions)
- [x] **Task 4** – Backend (si nécessaire)
  - [x] 4.1 Exposer la zone géographique de l’enquête (centre, bounds ou polygone) dans le schéma GraphQL si pas déjà présent (ex. champs sur Investigation : `centerLat`, `centerLng`, ou `bounds`)
  - [x] 4.2 Optionnel pour 3.2 : pas de validation serveur de la position pour les énigmes (Epic 4) ; uniquement données pour afficher la carte
- [x] **Task 5** – Qualité et conformité
  - [x] 5.1 Flutter : tests widget pour l’écran enquête avec progression visible et accès à la carte ; mock du service de géolocalisation pour les tests
  - [x] 5.2 `dart analyze`, `flutter test` verts ; pas de régression sur 3.1
  - [x] 5.3 Accessibilité : labels/sémantique pour la progression et le bouton carte (WCAG 2.1 Level A)
- [x] **Review Follow-ups (AI)**
  - [x] [AI-Review][Medium] Task 2.3 – Utiliser centerLat/centerLng du backend pour le centre de la carte (modèle Investigation + requête GraphQL + map sheet). [investigation_repository.dart, investigation.dart, investigation_map_sheet.dart]
  - [x] [AI-Review][Medium] Task 3.3 – Afficher un message clair lorsque la permission de localisation est refusée. [investigation_map_sheet.dart]
  - [ ] [AI-Review][Low] Task 3.2 – PrecisionCircle ou indicateur GPS design system (actuellement Icon seul). [investigation_map_sheet.dart]
  - [x] [AI-Review][Low] Supprimer ou utiliser le paramètre scrollController dans InvestigationMapSheet. [investigation_map_sheet.dart]
  - [x] [AI-Review][Low] Logger les exceptions dans GeolocatorServiceImpl.getCurrentPosition. [geolocator_service_impl.dart]
  - [x] [AI-Review][Low] Semantics(label) pour le bouton Fermer du sheet carte. [investigation_map_sheet.dart]
  - [x] [AI-Review][Low] Tests carte : cas position non null et/ou permission refusée. [investigation_map_sheet_test.dart]
  - [x] [AI-Review][Medium] Android : ajouter ACCESS_FINE_LOCATION et ACCESS_COARSE_LOCATION dans android/app/src/main/AndroidManifest.xml. [AndroidManifest.xml]
  - [x] [AI-Review][Medium] iOS : ajouter NSLocationWhenInUseUsageDescription dans ios/Runner/Info.plist. [Info.plist]

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 3.2 = progression + carte + position.** S’appuie sur 3.1 (enquête en cours, navigation entre énigmes). La sauvegarde automatique et pause/reprise sont en 3.3 ; les capacités techniques détaillées (GPS <10m, permissions, batterie) en 3.4.
- **Flutter** : Riverpod pour l’état progression (énigmes complétées/restantes) et pour la position (géoloc) ; `AsyncValue` pour la position si chargement async. Design system « carnet de détective », carte immersive (UX), indicateur de précision GPS (`PrecisionCircle` si défini).
- **Géolocalisation** : service centralisé `lib/core/services/geolocation_service.dart` (architecture) ; backend `src/services/geolocation_service.rs` pour validation future (Epic 4). Pour 3.2, affichage de la position sur la carte suffit.

### Project Structure Notes

- **Flutter** : `lib/features/investigation/` – réutiliser l’écran enquête en cours (3.1) ; ajouter widget/vue progression et widget carte. `lib/core/services/geolocation_service.dart` pour la position. Carte : widget dans `lib/features/investigation/widgets/` ou `lib/shared/widgets/` (ex. `investigation_map.dart`). Design system : `PrecisionCircle` dans `lib/shared/widgets/` si pas déjà présent.
- **Backend** : Optionnel pour 3.2 – ajout de champs géographiques sur Investigation (centre/bounds) si besoin pour centrer la carte ; `src/services/geolocation_service.rs` peut être préparé pour Epic 4 (validation position).
- [Source: architecture.md § Requirements to Structure Mapping – Géolocalisation, Design System]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 3, Story 3.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – Géolocalisation, Design System, Frontend Architecture]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md – Carte interactive immersive, indicateurs]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 3.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Structure Flutter | `lib/features/investigation/` (screens, widgets) ; `lib/core/services/geolocation_service.dart` |
| État Flutter | `AsyncValue` pour position si async ; Notifier pour état progression ; pas de booléen `isLoading` séparé |
| Navigation | GoRouter ; pas de `Navigator.push` direct pour écrans principaux |
| Géolocalisation | Service centralisé (architecture) ; package `geolocator` (architecture) |
| Quality gates | `dart analyze`, `dart format`, `flutter test` |
| Accessibilité | WCAG 2.1 Level A ; Semantics/labels pour progression et carte |

---

## Library / Framework Requirements

- **Flutter** : Riverpod 2.0+, GoRouter (déjà en place). **Géolocalisation** : `geolocator` (architecture). **Carte** : `google_maps_flutter` ou `flutter_map` (OpenStreetMap) selon choix projet/UX – vérifier avec architecture ou UX ; architecture mentionne « Services de cartes (pour affichage) ». Aucune autre dépendance obligatoire si client GraphQL et router déjà configurés.
- **Backend** : Pas de changement obligatoire pour 3.2 ; optionnel : champs géographiques sur Investigation, `geolocation_service.rs` pour usage futur.
- [Source: architecture.md – Packages Flutter clés ; project-context.md – Technology Stack]

---

## File Structure Requirements

- **Flutter** : `lib/core/services/geolocation_service.dart` ; `lib/features/investigation/widgets/` (ex. `investigation_progress_indicator.dart`, `investigation_map.dart`) ; écran enquête en cours (3.1) étendu avec progression et carte. `lib/shared/widgets/` pour `PrecisionCircle` si design system le définit.
- **Backend** : Optionnel – `src/services/geolocation_service.rs` (stub ou implémentation minimale) ; champs sur modèle Investigation si zone enquête exposée en API.
- **Config** : Clés API carte (Google Maps / etc.) si requises : `.env` ou `lib/core/config/` ; ne pas committer les clés.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Flutter** : Tests widget pour l’écran enquête : indicateur de progression visible (énigmes complétées/restantes) ; accès à la carte (affichage ou bouton) ; mock du `GeolocationService` pour ne pas appeler le device en test. Structure Given/When/Then pour cas non triviaux.
- **Qualité** : Pas de régression sur Story 3.1 ; `flutter test` vert.
- [Source: architecture.md – Testing Strategy ; project-context.md – Quality gates]

---

## Previous Story Intelligence (Story 3.1)

- **Écran enquête en cours** : 3.1 fournit l’écran avec enquête + liste ordonnée d’énigmes + navigation entre énigmes. En 3.2, ajouter sur ce même écran (ou layout adjacent) : indicateur de progression (complétées/restantes), carte interactive, position utilisateur.
- **État** : Réutiliser le provider « enquête en cours » (investigation + énigmes + index courante) ; ajouter un état « énigmes complétées » (liste d’ids ou indices) pour le calcul de la progression. Pour 3.2, « complétée » peut être simulée (ex. bouton « Marquer comme vue ») si la résolution réelle des énigmes est en Epic 4.
- **Routes** : Pas de nouvelle route obligatoire ; même route `/investigations/:id/play` avec contenu enrichi (progression + carte).
- **Ne pas dupliquer** : réutiliser écran et providers de 3.1 ; étendre sans casser la navigation entre énigmes.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Design** : Design system « carnet de détective » ; carte interactive immersive ; indicateurs de statut discrets ; gestion faible précision GPS avec indicateurs clairs (UX). Précision <10 m et permissions détaillées = Story 3.4.

---

## Change Log

- **2026-02-02** : Implémentation Story 3.2 – progression (énigmes complétées/restantes), carte interactive (flutter_map + OSM), position utilisateur (GeolocationService + geolocator), backend centerLat/centerLng optionnels, tests widget et mock géoloc.
- **2026-02-02** : Revue de code (Senior Developer AI) – Outcome: Changes Requested. 2 Medium, 5 Low ; section « Review Follow-ups (AI) » et « Senior Developer Review (AI) » ajoutées.
- **2026-02-02** : Corrections revue – centerLat/centerLng utilisés côté Flutter (modèle + query + carte), message permission refusée, scrollController retiré, log exceptions géoloc, Semantics bouton Fermer, tests carte (position null + non null). Statut → review.
- **2026-02-02** : 2e revue de code – Outcome: Changes Requested. 2 Medium (permissions Android/iOS pour géoloc), 1 Low (PrecisionCircle). Follow-ups ajoutés ; statut → in-progress.
- **2026-02-02** : 3e revue de code – 2 Medium (permissions) corrigés (AndroidManifest.xml, Info.plist). 1 Low restant (PrecisionCircle). Statut → done.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Progression : indicateur « X / N énigmes » + barre (design carnet de détective) ; état local `completedEnigmaIdsProvider` ; marquage à l’avance (Suivant).
- Carte : `flutter_map` + OpenStreetMap ; sheet « Voir la carte » (bouton AppBar) ; centre Paris ou depuis `investigation.centerLat`/`centerLng` ; position utilisateur + marqueur ; message si localisation refusée/indisponible.
- Géolocalisation : `GeolocationService` abstrait + `GeolocatorServiceImpl` (geolocator) ; permission à l’ouverture de la carte ; `currentPositionForMapProvider` (mockable en test) ; log debug en cas d'exception.
- Backend : champs optionnels `centerLat` / `centerLng` sur Investigation (GraphQL). Flutter : modèle + requête + carte utilisent le centre enquête si présent.
- Corrections revue (2026-02-02) : scrollController retiré ; Semantics « Fermer la carte » ; tests carte (position null + non null).
- Corrections 3e revue (2026-02-02) : permissions Android (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION) et iOS (NSLocationWhenInUseUsageDescription) ajoutées.
- Tests : progression, mise à jour au Suivant, bouton carte ; test carte avec mock (message indisponible + marqueur si position). `dart analyze` et `flutter test` verts.

### File List

- city_detectives/pubspec.yaml
- city_detectives/lib/core/services/geolocation_service.dart
- city_detectives/lib/core/services/geolocator_service_impl.dart
- city_detectives/lib/core/services/geolocation_provider.dart
- city_detectives/lib/features/investigation/models/investigation.dart
- city_detectives/lib/features/investigation/providers/investigation_play_provider.dart
- city_detectives/lib/features/investigation/repositories/investigation_repository.dart
- city_detectives/lib/features/investigation/screens/investigation_play_screen.dart
- city_detectives/lib/features/investigation/widgets/investigation_map_sheet.dart
- city_detectives/test/features/investigation/models/investigation_test.dart
- city_detectives/test/features/investigation/screens/investigation_play_screen_test.dart
- city_detectives/test/features/investigation/widgets/investigation_map_sheet_test.dart
- city-detectives-api/src/models/investigation.rs
- city_detectives/android/app/src/main/AndroidManifest.xml
- city_detectives/ios/Runner/Info.plist
- _bmad-output/implementation-artifacts/sprint-status.yaml
- _bmad-output/implementation-artifacts/3-2-progression-carte-interactive-position.md

---

## Senior Developer Review (AI)

**Reviewer:** Senior Developer (adversarial code review)  
**Date:** 2026-02-02  
**Outcome:** Changes Requested

### Summary

- **Git vs File List:** 3 fichiers modifiés par git non listés dans la File List (pubspec.lock, generated_plugin_registrant.cc, generated_plugins.cmake – les deux derniers sont générés).
- **Issues trouvées:** 2 Medium, 5 Low. Aucun Critical/High bloquant.

### Action Items

- [ ] **[Medium]** Task 2.3 – Utiliser le centre depuis le backend : le schéma GraphQL expose `centerLat`/`centerLng` mais le modèle Flutter `Investigation` ne les contient pas et la requête `getInvestigationById` ne les demande pas ; la carte utilise toujours Paris en dur. [investigation_repository.dart, investigation.dart, investigation_map_sheet.dart]
- [ ] **[Medium]** Task 3.3 – Message clair si permission refusée : quand la localisation est refusée, afficher un message explicite à l’utilisateur (ex. « Localisation refusée – la carte s’affiche sans votre position ») au lieu de rester silencieux. [investigation_map_sheet.dart]
- [ ] **[Low]** Task 3.2 – Design system : la story mentionne `PrecisionCircle` (indicateur GPS) ; l’implémentation utilise uniquement `Icon(Icons.my_location)`. Créer ou réutiliser un widget type PrecisionCircle si défini dans le design system. [investigation_map_sheet.dart]
- [ ] **[Low]** Paramètre mort : `InvestigationMapSheet.scrollController` est requis mais jamais utilisé dans le widget. [investigation_map_sheet.dart]
- [ ] **[Low]** Géoloc : `GeolocatorServiceImpl` – `catch (_)` avale toutes les exceptions sans log ; ajouter un log (niveau debug/warn) pour faciliter le débogage. [geolocator_service_impl.dart]
- [ ] **[Low]** Accessibilité : le bouton Fermer du sheet (IconButton close) n’a pas de `Semantics(label: 'Fermer la carte')` pour les lecteurs d’écran (WCAG 2.1 Level A). [investigation_map_sheet.dart]
- [ ] **[Low]** Tests carte : ajouter un test avec position non null (marqueur affiché) et/ou un test du cas erreur/permission refusée pour renforcer la couverture. [investigation_map_sheet_test.dart]

### Notes

- AC1 (progression, carte, position, retour visuel) : implémenté ; progression et carte accessibles, position affichée si autorisée.
- Tâches marquées [x] : toutes réalisées à un niveau suffisant pour la story ; les points ci‑dessus sont des améliorations de conformité (Task 2.3, 3.3) et de qualité (design system, accessibilité, tests, logs).
- Fichiers générés (plugin registrant, cmake) : volontairement exclus de la File List ; pas d’action requise sauf si la convention projet exige de les lister.

### Second Review (2026-02-02)

- **Outcome:** Changes Requested – permissions plateformes manquantes.
- **Issues (2e revue):** 2 Medium (Android + iOS permissions pour géoloc), 1 Low (PrecisionCircle restant).
- **Action Items (2e):** [ ] Android : ACCESS_FINE_LOCATION + ACCESS_COARSE_LOCATION dans AndroidManifest.xml. [ ] iOS : NSLocationWhenInUseUsageDescription dans Info.plist. [ ] Low : PrecisionCircle (design system).

### Third Review (2026-02-02)

- **Outcome:** Changes Requested → puis **Done** après corrections.
- **Issues (3e revue):** 2 Medium (permissions Android/iOS), 1 Low (PrecisionCircle). Les 2 Medium ont été corrigés automatiquement (AndroidManifest.xml, Info.plist). 1 Low restant en action item optionnel.

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
