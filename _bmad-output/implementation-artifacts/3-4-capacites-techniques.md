# Story 3.4: Capacités techniques (GPS, permissions, cache, batterie, erreurs)

**Story ID:** 3.4  
**Epic:** 3 – Core Gameplay & Navigation  
**Story Key:** 3-4-capacites-techniques  
**Status:** ready-for-dev  
**Depends on:** Story 3.1  
**Parallelizable with:** —  
**Lane:** A  
**Note:** Peut être découpée en sous-tâches (GPS/permissions, cache, batterie/erreurs) si un agent est surchargé.  
**FR:** FR72, FR73, FR74, FR75, FR78, FR80, FR81, FR82, FR84  

---

## Story

As a **utilisateur**,  
I want **que l'app gère la localisation précise, les permissions (GPS, caméra, stockage), le cache, la batterie et les erreurs de manière claire**,  
So that **l'expérience reste fluide et fiable**.

---

## Acceptance Criteria

1. **Given** l'app est utilisée en conditions réelles  
   **When** la localisation, les permissions ou le réseau sont sollicités  
   **Then** la position est déterminée avec une précision <10 m lorsque possible (FR72, FR73)  
   **And** les permissions sont demandées au bon moment avec un message clair (FR74, FR75)  
   **And** le statut de connexion est affiché (FR82)  
   **And** les données d'enquête sont mises en cache local pour performance (FR78)  
   **And** la consommation batterie est raisonnable ; messages de fallback si GPS imprécis (FR80, FR81)  
   **And** les erreurs d'enquête sont gérées avec un message explicite (FR84)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Géolocalisation précision <10 m
  - [ ] 1.1 Service `lib/core/services/geolocation_service.dart` : utiliser `geolocator` avec paramètres haute précision (LocationAccuracy.high ou équivalent) ; exposer la précision (mètres) dans le résultat (FR72, FR73).
  - [ ] 1.2 Afficher l'indicateur de précision (ex. `PrecisionCircle` ou équivalent) lorsque la précision est >10 m ou instable ; message clair si imprécis (FR81).
  - [ ] 1.3 Backend optionnel : `src/services/geolocation_service.rs` pour validation future (énigmes géo) ; pas obligatoire pour 3.4 côté app.
- [ ] **Task 2** (AC1) – Permissions (GPS, caméra, stockage)
  - [ ] 2.1 Demander les permissions au moment approprié : GPS avant affichage carte / énigme géo ; caméra avant première énigme photo ; stockage si écriture locale (FR74). Utiliser `permission_handler` ou APIs plateforme (Android `requestPermission`, iOS `requestWhenInUseAuthorization`).
  - [ ] 2.2 Message clair et justification : expliquer pourquoi la permission est nécessaire (ex. « Pour afficher votre position sur la carte ») ; ne pas bloquer l'app si refus (FR75).
  - [ ] 2.3 Fallback si refus : carte sans position, énigme photo avec galerie (déjà prévu Epic 4), message explicite (FR75).
- [ ] **Task 3** (AC1) – Statut de connexion
  - [ ] 3.1 Afficher le statut de connexion (en ligne / hors ligne ou dégradé) de manière discrète (indicateur dans l'UI, ex. barre ou icône) (FR82).
  - [ ] 3.2 Utiliser `connectivity_plus` ou équivalent pour détecter l'état réseau ; mettre à jour l'affichage quand l'état change.
  - [ ] 3.3 Design : indicateurs discrets (UX) ; pas de popup intrusif sauf si action requise.
- [ ] **Task 4** (AC1) – Cache local des données d'enquête
  - [ ] 4.1 Mettre en cache local les données d'enquête (liste, détails, énigmes) pour performance : Hive ou cache GraphQL (`graphql_flutter` cache-first) (FR78).
  - [ ] 4.2 Chargement depuis cache en priorité (<2s) ; rafraîchissement en arrière-plan si réseau disponible (architecture : chargement <2s depuis cache).
  - [ ] 4.3 Réutiliser repositories / Hive déjà en place (3.1, 3.2, 3.3) ; étendre si besoin pour enquêtes complètes (métadonnées + énigmes).
- [ ] **Task 5** (AC1) – Batterie et fallback GPS imprécis
  - [ ] 5.1 Optimiser l'usage GPS : ne pas garder le flux position en continu si pas nécessaire ; mode basse consommation quand carte non visible (FR80).
  - [ ] 5.2 Messages de fallback si GPS imprécis : « Position imprécise », « Déplacez-vous pour améliorer la précision » (FR81). Indicateur clair (design system).
  - [ ] 5.3 Pas de polling agressif ; géoloc à la demande ou intervalle raisonnable pour la carte.
- [ ] **Task 6** (AC1) – Gestion des erreurs d'enquête
  - [ ] 6.1 Intercepter les erreurs liées aux enquêtes : chargement échoué, API indisponible, données invalides (FR84).
  - [ ] 6.2 Afficher un message explicite à l'utilisateur (non technique) : ex. « Impossible de charger l'enquête. Vérifiez votre connexion. » ; bouton réessayer si pertinent.
  - [ ] 6.3 Logger les erreurs (stack, contexte) pour debug / Sentry ; ne pas exposer les détails techniques à l'utilisateur.
- [ ] **Task 7** – Qualité et conformité
  - [ ] 7.1 Flutter : tests unitaires pour geolocation_service (mock geolocator) ; tests pour affichage statut connexion et messages d'erreur.
  - [ ] 7.2 `dart analyze`, `flutter test` verts ; pas de régression sur 3.1–3.3.
  - [ ] 7.3 Accessibilité : labels pour indicateurs (connexion, précision, erreur) (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 3.4 = capacités techniques transverses.** S'appuie sur 3.1 (enquête en cours) ; renforce 3.2 (carte, position) et 3.3 (cache, persistance). Peut être découpée en sous-tâches si charge trop importante : (1) GPS + permissions, (2) cache + connexion, (3) batterie + erreurs.
- **Flutter** : Service centralisé géolocalisation (architecture) ; `permission_handler` pour les permissions ; `connectivity_plus` pour le réseau ; Hive/cache déjà utilisés en 3.3. Design system : indicateurs discrets, messages clairs (UX).
- **Backend** : Optionnel pour 3.4 ; `geolocation_service.rs` pour validation future (Epic 4). Pas de nouvel endpoint obligatoire.

### Project Structure Notes

- **Flutter** : `lib/core/services/geolocation_service.dart` (précision, fallback) ; `lib/core/services/` ou `lib/features/investigation/` pour connectivity/error handling si feature-specific. Permissions : helper ou service dans `lib/core/` (ex. `permission_service.dart`). Indicateurs UI dans `lib/shared/widgets/` ou feature investigation.
- **Backend** : `src/services/geolocation_service.rs` (stub ou validation coordonnées) si besoin pour Epic 4.
- [Source: architecture.md § Géolocalisation, Gestion des permissions, Cache, Design System]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 3, Story 3.4]
- [Source: _bmad-output/planning-artifacts/architecture.md – Géolocalisation, Permissions, Cache, Performance]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md – Indicateurs discrets, fallback GPS]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 3.4 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Structure Flutter | `lib/core/services/` (geolocation, permissions, connectivity) ; `lib/shared/widgets/` pour indicateurs |
| État Flutter | `AsyncValue` pour état connexion / position si async ; pas de booléen `isLoading` séparé |
| Géolocalisation | Service centralisé (architecture) ; précision <10 m ; fallbacks clairs |
| Cache | Hive / cache GraphQL (architecture) ; chargement <2s depuis cache |
| Quality gates | `dart analyze`, `dart format`, `flutter test` |
| Accessibilité | WCAG 2.1 Level A ; labels pour indicateurs et messages d'erreur |

---

## Library / Framework Requirements

- **Flutter** : `geolocator` (déjà prévu architecture) ; `permission_handler` pour demandes de permissions (GPS, caméra, stockage) ; `connectivity_plus` pour statut réseau. Hive déjà en place (3.3). Sentry optionnel pour logging erreurs (architecture).
- **Backend** : Aucune nouvelle dépendance obligatoire pour 3.4.
- [Source: architecture.md – Packages Flutter clés, Gestion des permissions]

---

## File Structure Requirements

- **Flutter** : `lib/core/services/geolocation_service.dart` (précision, accuracy, fallback) ; `lib/core/services/permission_service.dart` ou helper permissions ; widget ou service pour statut connexion (ex. `connectivity_service.dart` + indicateur dans shared/widgets). Gestion erreurs : dans repositories ou layer dédié (ex. `error_handler.dart`) avec messages utilisateur.
- **Config** : Pas de changement `.env` obligatoire pour 3.4.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Flutter** : Tests unitaires pour geolocation_service avec mock `geolocator` (précision, erreur, fallback). Tests pour affichage statut connexion (mock connectivity). Tests pour affichage message d'erreur enquête (mock erreur API). Structure Given/When/Then pour cas non triviaux.
- **Qualité** : Pas de régression sur 3.1, 3.2, 3.3 ; `flutter test` vert.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Stories 3.1–3.3)

- **3.1** : Écran enquête en cours, navigation énigmes ; geolocation_service peut déjà exister pour la carte (3.2). En 3.4, renforcer précision (<10 m), permissions au bon moment, messages fallback.
- **3.2** : Carte, position utilisateur, PrecisionCircle. En 3.4, s'assurer que la précision est exposée et que les messages « GPS imprécis » sont affichés ; permissions demandées avant ou au premier usage carte/énigme géo.
- **3.3** : Hive, cache progression. En 3.4, cache des données d'enquête (liste, détails) pour performance (FR78) ; réutiliser pattern repository + Hive.
- **Ne pas dupliquer** : unifier la gestion des permissions et du geolocation_service ; ne pas créer un second service de géoloc.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **UX** : Indicateurs de statut connexion discrets ; gestion faible précision GPS avec indicateurs clairs (ux-design-specification).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
