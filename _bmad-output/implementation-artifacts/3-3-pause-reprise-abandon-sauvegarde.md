# Story 3.3: Pause, reprise, abandon et sauvegarde

**Story ID:** 3.3  
**Epic:** 3 – Core Gameplay & Navigation  
**Story Key:** 3-3-pause-reprise-abandon-sauvegarde  
**Status:** done  
**Depends on:** Story 3.2  
**Parallelizable with:** —  
**Lane:** A  
**FR:** FR16, FR20, FR21  

---

## Story

As a **utilisateur**,  
I want **mettre en pause une enquête, la reprendre plus tard, ou l'abandonner et y revenir plus tard, sans perdre ma progression**,  
So that **je puisse jouer à mon rythme**.

---

## Acceptance Criteria

1. **Given** une enquête est en cours  
   **When** l'utilisateur met en pause, quitte l'app ou abandonne  
   **Then** la progression est sauvegardée automatiquement (FR21)  
   **And** il peut reprendre l'enquête plus tard au point où il s'est arrêté (FR16, FR20)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Sauvegarde automatique de la progression
  - [x] 1.1 Persister localement l'état « enquête en cours » : investigation id, index énigme courante, énigmes complétées (liste ou bits), timestamp (FR21). Architecture : **Hive** avec TypeAdapters (offline-first) ; box dédiée ou clé par enquête (ex. `investigation_progress_{id}`).
  - [x] 1.2 Déclencher la sauvegarde à des points clés : changement d'énigme, pause explicite, sortie de l'écran enquête (dispose / route pop), et optionnellement périodiquement (ex. toutes les N secondes) pour couvrir crash ou fermeture brutale.
  - [x] 1.3 Repository ou service de persistance : `lib/core/repositories/` ou `lib/features/investigation/repositories/` (ex. `investigation_progress_repository.dart`) ; lecture/écriture Hive ; pas de dépendance à un backend obligatoire pour 3.3 (sync = V1.0+ si prévu).
- [x] **Task 2** (AC1) – Pause et reprise
  - [x] 2.1 Bouton ou action « Mettre en pause » sur l'écran enquête ; à l'action : sauvegarder l'état puis naviguer hors de l'écran enquête (ex. retour liste des enquêtes ou écran « Mes enquêtes en cours ») (FR16).
  - [x] 2.2 Reprise : depuis la liste des enquêtes ou un écran « Enquêtes en cours », l'utilisateur peut reprendre une enquête sauvegardée ; charger l'état depuis Hive et rouvrir l'écran enquête au bon index énigme (FR16).
  - [x] 2.3 Afficher les enquêtes « en cours » (avec progression sauvegardée) distinctement des enquêtes non démarrées ; entrée claire pour reprendre.
- [x] **Task 3** (AC1) – Abandon et retour
  - [x] 3.1 Action « Abandonner » (ou « Quitter l'enquête ») : sauvegarder l'état actuel (pour permettre de revenir plus tard au même point), puis quitter l'écran enquête (FR20).
  - [x] 3.2 Différence sémantique avec « Pause » : optionnel – « Pause » = intention de reprendre bientôt ; « Abandonner » = quitter sans supprimer la progression (l'utilisateur peut revenir plus tard). Implémentation peut être identique (sauvegarde + sortie) ; libellés UX distincts.
  - [x] 3.3 Gestion de la fermeture de l'app (back button, kill) : s'appuyer sur la sauvegarde automatique (Task 1) pour que au prochain lancement l'utilisateur puisse reprendre (FR20).
- [x] **Task 4** – Backend (optionnel pour 3.3)
  - [x] 4.1 Pour MVP, la progression peut rester uniquement locale (Hive). Si l'API expose déjà une mutation « saveProgress » ou « updateInvestigationProgress », l'appeler après sauvegarde locale pour sync future ; sinon, reporté V1.0+.
  - [x] 4.2 Pas de blocage : 3.3 est satisfaite avec persistance locale seule.
- [x] **Task 5** – Qualité et conformité
  - [x] 5.1 Flutter : tests widget ou unitaires pour le repository de progression (écriture/lecture Hive avec mock ou test box) ; tests pour écran « reprendre » (présence liste enquêtes en cours, reprise au bon index).
  - [x] 5.2 `dart analyze`, `flutter test` verts ; pas de régression sur 3.1, 3.2.
  - [x] 5.3 Accessibilité : labels pour « Pause », « Reprendre », « Abandonner » (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 3.3 = persistance locale de la progression.** S'appuie sur 3.1 (écran enquête, navigation entre énigmes) et 3.2 (progression affichée). Pas de sync serveur obligatoire pour le MVP ; Hive = source de vérité locale (architecture : Hive avec TypeAdapters, offline-first).
- **Flutter** : Riverpod pour l'état ; repository qui lit/écrit Hive ; sauvegarde déclenchée depuis les écrans/providers existants (3.1/3.2). Design system « carnet de détective », messages clairs (pause, abandon, reprise).

### Project Structure Notes

- **Flutter** : `lib/features/investigation/` – repository `investigation_progress_repository.dart` (ou dans `lib/core/repositories/` si partagé) ; modèle de progression (investigationId, currentEnigmaIndex, completedEnigmaIds, updatedAt) avec TypeAdapter Hive. Écran ou section « Enquêtes en cours » pour reprendre (peut être un onglet/vue sur l'écran liste des enquêtes).
- **Hive** : box `investigation_progress` ou `user_progress` ; clé = `investigation_id` (ou `user_id + investigation_id` si multi-comptes) ; valeur = objet sérialisé (TypeAdapter).
- [Source: architecture.md § Offline storage, Data flow, Requirements to Structure Mapping]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 3, Story 3.3]
- [Source: _bmad-output/planning-artifacts/architecture.md – Hive, Repositories, Offline / sync]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 3.3 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Structure Flutter | `lib/features/investigation/repositories/` ou `lib/core/repositories/` ; Hive boxes par domaine |
| État Flutter | Réutilisation des providers 3.1/3.2 ; repository pour persistance ; pas de booléen `isLoading` séparé |
| Données | Hive = persistance locale ; lecture/écriture via repository ; pas d'accès Hive direct depuis les écrans |
| Navigation | GoRouter ; après pause/abandon, navigation vers liste ou « enquêtes en cours » |
| Quality gates | `dart analyze`, `dart format`, `flutter test` |
| Accessibilité | WCAG 2.1 Level A ; Semantics pour Pause, Reprendre, Abandonner |

---

## Library / Framework Requirements

- **Flutter** : **Hive** + **hive_flutter** (et **hive_generator** + **build_runner** pour TypeAdapters si utilisé). Riverpod, GoRouter déjà en place. Vérifier que Hive est déjà ajouté au projet (architecture) ; sinon l'ajouter pour 3.3.
- **Backend** : Aucun changement obligatoire pour 3.3 ; optionnel : endpoint/mutation pour enregistrer la progression (sync future).
- [Source: architecture.md – Offline storage: Hive avec TypeAdapters]

---

## File Structure Requirements

- **Flutter** : `lib/features/investigation/repositories/investigation_progress_repository.dart` ; modèle `InvestigationProgress` (ou équivalent) dans `lib/features/investigation/models/` ou `lib/core/models/` avec TypeAdapter Hive. Initialisation Hive dans `main.dart` ou équivalent (Hive.init, ouverture des boxes). Écran ou section « Enquêtes en cours » dans la feature investigation.
- **Hive** : Fichiers générés par build_runner si TypeAdapter généré : ex. `*.g.dart` ; ne pas committer les boxes (données utilisateur).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Flutter** : Tests unitaires ou widget pour le repository (sauvegarde + relecture ; état cohérent). Tests pour le flux « reprendre » : affichage des enquêtes en cours, reprise au bon index. Utiliser Hive en mémoire ou box de test pour éviter les effets de bord.
- **Qualité** : Pas de régression sur 3.1, 3.2 ; `flutter test` vert.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 3.2)

- **Écran enquête en cours** : 3.1 + 3.2 fournissent l'écran avec enquête, énigmes, progression affichée, carte, position. En 3.3, ajouter sur cet écran les actions « Pause » et « Abandonner », et déclencher la sauvegarde (état : investigation id, index courante, énigmes complétées).
- **État progression** : 3.2 introduit l'affichage « énigmes complétées / restantes ». Pour 3.3, ce même état (ou une structure dérivée) doit être persisté dans Hive ; au retour sur l'écran, recharger depuis Hive et réinitialiser le provider avec cet état.
- **Ne pas dupliquer** : réutiliser les providers et l'écran enquête ; injecter le repository de progression et appeler save aux bons moments (pause, abandon, changement d'énigme, dispose).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Offline-first** : Hive est la source de vérité locale pour la progression ; sync avec le backend peut être ajoutée en V1.0+.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Story 3.3 implémentée : modèle InvestigationProgress (Hive TypeAdapter), repository investigation_progress_repository (box `investigation_progress`, clé par investigationId), sauvegarde aux points clés (changement d’énigme, pause, abandon, retour). Boutons Pause et Abandonner sur l’écran enquête ; section « Enquêtes en cours » sur la liste avec Reprendre. Reprise au bon index énigme au retour. Tests : repository (forTest), liste « Enquêtes en cours », overrides pour tests sans Hive. `dart analyze` et `flutter test` verts.
- Code review (2026-02-02) : corrections appliquées – (1) setState pendant build corrigé (addPostFrameCallback quand pas de progression), (2) _saveProgress attendu avant navigation (retour, pause, abandon), (3) File List complété (pubspec.lock), (4) test widget « reprise au bon index » ajouté.

### Change Log

- 2026-02-02 : Story 3.3 implémentée (pause, reprise, abandon, sauvegarde Hive, section Enquêtes en cours, tests).

### File List

- city_detectives/pubspec.yaml (hive, hive_flutter, hive_generator, build_runner)
- city_detectives/pubspec.lock (dépendances résolues après ajout Hive)
- city_detectives/lib/main.dart (Hive.initFlutter, registerAdapter, openBox)
- city_detectives/lib/features/investigation/models/investigation_progress.dart (nouveau)
- city_detectives/lib/features/investigation/models/investigation_progress.g.dart (généré)
- city_detectives/lib/features/investigation/repositories/investigation_progress_repository.dart (nouveau)
- city_detectives/lib/features/investigation/screens/investigation_play_screen.dart (modifié : pause, abandon, sauvegarde, restauration)
- city_detectives/lib/features/investigation/screens/investigation_list_screen.dart (modifié : section Enquêtes en cours, Reprendre)
- city_detectives/lib/core/router/app_router.dart (import utilisé par play screen)
- city_detectives/test/features/investigation/repositories/investigation_progress_repository_test.dart (nouveau)
- city_detectives/test/features/investigation/investigation_list_screen_test.dart (override repo, test Enquêtes en cours)
- city_detectives/test/features/investigation/screens/investigation_play_screen_test.dart (override repo)
- _bmad-output/implementation-artifacts/sprint-status.yaml (3-3: in-progress → review)

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
