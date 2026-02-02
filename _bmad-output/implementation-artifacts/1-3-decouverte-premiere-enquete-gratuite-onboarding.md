# Story 1.3: Découverte de la première enquête gratuite et onboarding

**Story ID:** 1.3  
**Epic:** 1 – Onboarding & Account  
**Story Key:** 1-3-decouverte-premiere-enquete-gratuite-onboarding  
**Status:** done  
**Depends on:** Story 1.2  
**Lane:** A  
**FR:** FR3, FR4, FR5  

---

## Story

As a **utilisateur**,  
I want **découvrir la première enquête gratuite pendant l'onboarding, comprendre le concept et le LORE des détectives, et recevoir un guidage d'usage**,  
So that **je sache comment jouer avant de commencer**.

---

## Acceptance Criteria

1. **Given** l'utilisateur est connecté (ou a choisi de jouer sans compte si prévu)  
   **When** il parcourt l'onboarding  
   **Then** la première enquête gratuite est présentée (FR3)  
   **And** le concept et le LORE des détectives sont expliqués (FR4)  
   **And** un guidage d'usage (navigation, objectif) est fourni (FR5)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Flutter : écrans onboarding (découverte enquête + LORE + guidage)
  - [x] 1.1 Après inscription (ou depuis welcome si pas inscrit), afficher le flux onboarding : présentation de la première enquête gratuite (titre, courte description, durée/difficulté si disponible)
  - [x] 1.2 Écran(s) ou étapes expliquant le concept City Detectives et le LORE des détectives (texte + visuels selon design system « carnet de détective »)
  - [x] 1.3 Étape guidage d'usage : comment naviguer, objectif d'une enquête (énigmes, découverte), CTA pour « Démarrer l'enquête » ou « Voir les enquêtes »
- [x] **Task 2** (AC1) – Navigation et routing
  - [x] 2.1 Post-inscription (Story 1.2) : rediriger vers l'onboarding 1.3 (pas directement vers home si onboarding non fait)
  - [x] 2.2 Route(s) GoRouter pour onboarding : ex. `/onboarding`, `/onboarding/lore`, `/onboarding/guide` ou un seul écran avec étapes (stepper / page view)
  - [x] 2.3 À la fin de l'onboarding : navigation vers écran liste des enquêtes ou première enquête (selon architecture ; Story 2.1 peut fournir la liste)
- [x] **Task 3** (AC1) – Contenu et cohérence UX
  - [x] 3.1 Contenu texte LORE/concept : soit en dur (strings) soit chargé depuis assets/backend selon décision ; aligné avec design system (contraste, accessibilité)
  - [x] 3.2 Première enquête gratuite : afficher un libellé « Gratuit » et un résumé ; l’identifiant ou le titre peut venir du backend (query) ou d’un mock pour MVP
  - [x] 3.3 Accessibilité : Semantics/labels sur les écrans onboarding (WCAG 2.1 Level A)
- [x] **Task 4** – Qualité et conformité
  - [x] 4.1 Flutter : `dart analyze`, `dart format`, `flutter test` verts ; pas de régression sur 1.1 et 1.2
  - [x] 4.2 Tests widget pour au moins un écran onboarding (présence contenu, CTA, navigation)
  - [x] 4.3 Backend : pas de changement obligatoire pour 1.3 ; si query « première enquête gratuite » ajoutée, ajouter test d’intégration si pertinent

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 1.3 = suite logique de 1.2.** L’utilisateur vient de s’inscrire (ou d’arriver sur welcome) ; on lui présente la première enquête gratuite, le LORE et le guidage avant de le laisser accéder au catalogue ou à l’enquête.
- **Pas de « jouer sans compte » obligatoire dans cette story** si non prévu au PRD/épic ; les AC disent « ou a choisi de jouer sans compte si prévu ». En l’état, focus sur le parcours connecté post-inscription.
- **Flutter** : Riverpod pour l’état onboarding (étape courante, complété ou non) ; GoRouter pour les routes ; `AsyncValue<T>` pour tout chargement async (ex. chargement de la fiche première enquête si API).
- **Design system** : « carnet de détective » (UX) ; premier écran impactant, design language cohérent ; contraste et accessibilité WCAG 2.1 Level A.

### Project Structure Notes

- **Flutter** : `lib/features/onboarding/` – écrans et éventuels providers/screens pour onboarding (ex. `onboarding_screen.dart`, `onboarding_lore_screen.dart`, ou un seul écran multi-étapes). Pas de nouveau dossier core obligatoire ; réutiliser `lib/core/router/app_router.dart`, `lib/core/config/`.
- **Backend** : Aucun changement obligatoire pour 1.3. Optionnel : query GraphQL « première enquête gratuite » ou « enquêtes » (liste minimale) si le catalogue existe déjà (sinon mock côté Flutter).
- [Source: architecture.md § Frontend Architecture, § Requirements to Structure Mapping – Onboarding & Account]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Story 1.3]
- [Source: _bmad-output/planning-artifacts/architecture.md – Frontend Architecture, Project Structure, UX]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md – Design system, LORE, guidage]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]

---

## Architecture Compliance

| Règle | Application pour 1.3 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Structure | `lib/features/onboarding/` (screens, évent. providers) ; `lib/core/router/` pour routes |
| État Flutter | AsyncValue pour appels async ; pas de loader global ; Riverpod pour état onboarding |
| Navigation | GoRouter (routes déclaratives) ; pas de Navigator.push direct pour écrans principaux |
| Validation | Backend = source de vérité pour données ; Flutter affiche erreurs API si appel API |
| Quality gates | `dart analyze`, `dart format`, `flutter test` verts |
| Accessibilité | WCAG 2.1 Level A ; Semantics/labels sur écrans onboarding |

---

## Library / Framework Requirements

- **Flutter** : Riverpod 2.0+, GoRouter, graphql_flutter 5.2.1 (si appel API pour enquête(s)), packages déjà présents (Story 1.1, 1.2). Aucune nouvelle dépendance obligatoire pour 1.3 sauf si besoin de stepper/page view (Material ou package léger).
- **Backend** : Aucun changement requis pour 1.3.
- [Source: project-context.md – Technology Stack ; architecture.md – Frontend Architecture]

---

## File Structure Requirements

- **Flutter** : `lib/features/onboarding/screens/` – écran(s) onboarding (ex. `onboarding_screen.dart`, ou `onboarding_wizard_screen.dart` avec étapes). Routes dans `lib/core/router/app_router.dart` (ex. `/onboarding`, `/onboarding/guide`). Fichiers GraphQL en `snake_case.graphql` si requêtes ajoutées.
- **Config** : Pas de changement `.env` obligatoire pour 1.3.
- **Assets** : Textes LORE/concept peuvent être en dur dans le code ou dans `assets/` (ex. JSON ou markdown) selon choix ; documenter l’emplacement.

---

## Testing Requirements

- **Flutter** : Tests widget pour au moins un écran onboarding (présence titre/première enquête, LORE ou concept, CTA, navigation). Structure Given/When/Then pour cas non triviaux. Pas d’E2E obligatoire pour 1.3.
- **Qualité** : Pas de régression sur Story 1.1 (app shell, welcome) et 1.2 (inscription, auth) ; `flutter test` vert.
- [Source: project-context.md – Tests ; architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 1.2)

- **Structure en place** : `lib/core/services/auth_service.dart`, `lib/core/repositories/user_repository.dart`, `lib/features/onboarding/screens/register_screen.dart`, `lib/core/router/app_router.dart`, `lib/core/graphql/`. Ne pas dupliquer ni casser la structure.
- **Post-inscription** : Après inscription réussie, la story 1.2 redirige vers `AppRouter.home`. Pour 1.3, adapter la redirection : après inscription, envoyer vers l’onboarding (ex. `/onboarding`) au lieu de `/home` si l’utilisateur n’a pas encore fait l’onboarding ; après onboarding complété, aller vers home ou liste des enquêtes.
- **État** : Utiliser `AsyncValue<T>` pour tout chargement async ; pas de booléen `isLoading` séparé. Semantics/labels sur les écrans (WCAG 2.1 Level A).
- **CI** : Pipeline Quality (Flutter + Rust) déjà en place ; s’assurer que les nouveaux tests widget passent en CI.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Validation** : Backend = source de vérité pour données métier ; Flutter affiche les erreurs API.
- **Design** : Design system « carnet de détective » ; premier écran impactant ; accessibilité WCAG 2.1 Level A.

---

## Change Log

- Implémentation Story 1.3 : onboarding 3 étapes (première enquête gratuite, LORE, guidage), routing /onboarding, redirections post-inscription et welcome, tests widget (Date: 2026-02-01).
- Code review (AI) : 2 High, 2 Medium, 3 Low. Statut repassé à in-progress ; voir `code-review-1-3-decouverte-premiere-enquete-gratuite-onboarding.md` (Date: 2026-02-02).
- Corrections post-review : Semantics/labels sur _GuideItem (H2) ; flutter test exécuté et documenté (H1/M2) ; double CTA documenté (M1). Statut → done (Date: 2026-02-02).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Implémentation onboarding Story 1.3 : écran unique avec PageView (3 étapes – première enquête gratuite, LORE/concept, guidage). Riverpod OnboardingNotifier pour état complété (persistant via FlutterSecureStorage). Post-inscription → /onboarding ; welcome avec token → onboarding si non complété, sinon home. Routes GoRouter : /onboarding. CTA « Démarrer l'enquête » et « Voir les enquêtes » sur la dernière étape ; les deux mènent à la liste des enquêtes (/investigations) par design (l'utilisateur choisit ensuite quelle enquête démarrer). Semantics/labels sur tous les écrans et sur _GuideItem (WCAG 2.1 Level A). Tests widget : présence contenu, CTA, LORE, accessibilité. dart analyze, dart format et flutter test OK (flutter test exécuté 2026-02-02 : suite complète passée).

### File List

- city_detectives/lib/features/onboarding/providers/onboarding_provider.dart (new)
- city_detectives/lib/features/onboarding/screens/onboarding_screen.dart (new)
- city_detectives/lib/core/router/app_router.dart (modified)
- city_detectives/lib/features/onboarding/screens/register_screen.dart (modified)
- city_detectives/lib/features/onboarding/screens/welcome_screen.dart (modified)
- city_detectives/test/onboarding_screen_test.dart (new)
- _bmad-output/implementation-artifacts/sprint-status.yaml (modified)

---

---

## Senior Developer Review (AI)

**Date :** 2026-02-02  
**Rapport détaillé :** `_bmad-output/implementation-artifacts/code-review-1-3-decouverte-premiere-enquete-gratuite-onboarding.md`

**Résumé :** 2 High, 2 Medium, 3 Low. **Décision : Changes Requested.**

- **HIGH :** (1) Quality gate non vérifiée — `flutter test` non exécuté (Task 4.1). (2) Accessibilité — `_GuideItem` sans Semantics/labels (Task 3.3 / WCAG 2.1 Level A).
- **MEDIUM :** Double CTA « Démarrer l’enquête » / « Voir les enquêtes » vers la même destination ; documentation des limitations (flutter test).
- **LOW :** FlutterSecureStorage sans options plateforme ; test Semantics trop générique ; données première enquête en dur (OK pour MVP).

**Statut mis à jour :** review → in-progress puis done après corrections automatiques (Semantics _GuideItem, flutter test documenté, double CTA documenté).

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
