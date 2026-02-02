# Story 4.4: LORE et option de saut

**Story ID:** 4.4  
**Epic:** 4 – Énigmes & Content  
**Story Key:** 4-4-lore-option-saut  
**Status:** ready-for-dev  
**Depends on:** Story 4.1  
**Parallelizable with:** —  
**Lane:** B  
**FR:** FR34, FR35, FR37  

---

## Story

As a **utilisateur**,  
I want **vivre le LORE des détectives pendant l'enquête et pouvoir sauter les éléments narratifs si je préfère aller directement aux énigmes**,  
So that **l'expérience s'adapte à ma préférence**.

---

## Acceptance Criteria

1. **Given** une enquête avec contenu LORE  
   **When** le LORE est affiché  
   **Then** l'utilisateur peut le vivre (FR34) ou le sauter (FR35)  
   **And** photos et contexte historique des lieux sont disponibles (FR37)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Affichage du LORE pendant l'enquête
  - [ ] 1.1 Intégrer les séquences LORE dans le flux enquête : contenu narratif (texte, visuels) affiché à des moments définis (ex. avant une énigme, entre énigmes, intro enquête) (FR34).
  - [ ] 1.2 Backend : exposer le contenu LORE par enquête ou par énigme (ex. champs `loreContent`, `loreSequence` sur Investigation/Enigma, ou query `getLoreContent(investigationId, sequenceIndex)`). Données : texte, références images, ordre d'affichage (FR34, FR37).
  - [ ] 1.3 Flutter : écran ou widget « LORE » (titre, texte narratif, photos/contexte historique des lieux) ; affiché selon le flux enquête (ex. après une énigme, avant la suivante, ou au démarrage) (FR34, FR37).
- [ ] **Task 2** (AC1) – Option de saut
  - [ ] 2.1 Sur chaque écran/panneau LORE, ajouter un bouton « Sauter » (ou « Passer », « Aller à l'énigme ») visible et accessible (FR35).
  - [ ] 2.2 Au clic sur « Sauter » : fermer ou quitter la séquence LORE et passer directement à l'énigme suivante (ou à la suite du flux) sans obliger l'utilisateur à lire (FR35).
  - [ ] 2.3 Optionnel : mémoriser la préférence « Toujours sauter le LORE » (paramètre utilisateur) pour les séquences suivantes ; sinon, proposer le saut à chaque séquence (FR35).
- [ ] **Task 3** (AC1) – Photos et contexte historique des lieux
  - [ ] 3.1 Afficher les photos et le contexte historique des lieux dans le contenu LORE (ex. galerie d'images, légendes, texte historique) (FR37).
  - [ ] 3.2 Backend : exposer les médias (URLs images, texte contexte) par séquence LORE ou par lieu ; stockage en DB ou assets selon contenu (FR37).
  - [ ] 3.3 Flutter : afficher images (chargement async, cache si besoin) et texte ; design system « carnet de détective » (FR37).
- [ ] **Task 4** (AC1) – Intégration flux enquête
  - [ ] 4.1 Définir où le LORE s'insère dans le flux : ex. séquence LORE optionnelle avant/après certaines énigmes, ou écran intro LORE au démarrage de l'enquête. Réutiliser le flux enquête (3.1, 4.1, 4.2) ; insérer les étapes LORE sans casser la navigation (FR34).
  - [ ] 4.2 Après « Sauter » ou fin de lecture du LORE : passage à l'énigme suivante (ou écran suivant) ; cohérence avec 4.1, 4.2, 4.3 (FR35).
- [ ] **Task 5** – Qualité et conformité
  - [ ] 5.1 Backend : test d'intégration pour la lecture du contenu LORE (ex. `tests/api/enigmas_test.rs` ou `investigations_test.rs`) – au moins un cas nominal (FR34, FR37).
  - [ ] 5.2 Flutter : tests widget pour affichage LORE, présence du bouton « Sauter », action saut (passage à la suite) ; mocker API (FR34, FR35).
  - [ ] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 4.1–4.3.
  - [ ] 5.4 Accessibilité : labels pour bouton Sauter, contenu LORE (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 4.4 = LORE + option de saut.** S'appuie sur 4.1 (flux enquête, énigmes) ; le LORE est un contenu narratif affiché à des moments définis dans l'enquête. L'utilisateur peut (1) vivre le LORE (lire, voir les photos), (2) sauter à tout moment pour aller directement aux énigmes (FR34, FR35). Photos et contexte historique des lieux = FR37.
- **Flutter** : Réutiliser `lib/features/investigation/` et `lib/features/enigma/` ; ajouter un écran ou widget partagé « LORE » (affichage texte + images, bouton Sauter). Intégrer les séquences LORE dans le routeur/dispatcher du flux enquête (3.1, 4.1).
- **Backend** : Schéma GraphQL étendu pour contenu LORE (séquences, texte, médias) ; pas de mutation pour le LORE (lecture seule). Content & LORE mappé à `lib/features/investigation/` et `lib/features/enigma/` (architecture).

### Project Structure Notes

- **Flutter** : `lib/features/enigma/` ou `lib/features/investigation/` – écran ou widget `lore_screen.dart` / `lore_content_widget.dart` pour afficher le LORE et le bouton Sauter. Intégration dans le flux « enquête en cours » (après/before énigmes selon modèle de données). Réutiliser router et providers existants.
- **Backend** : `src/services/enigma_service.rs` ou module dédié (ex. `lore_service.rs`) pour lecture contenu LORE ; `src/api/graphql/queries.rs` (ex. `getLoreContent`, ou champs sur Investigation/Enigma). Tables : séquences LORE par enquête (texte, ordre, médias) (FR34, FR37).
- [Source: architecture.md § Content & LORE, Requirements to Structure Mapping]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 4, Story 4.4]
- [Source: _bmad-output/planning-artifacts/architecture.md – Content & LORE, GraphQL]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md – Option sauter LORE, design]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 4.4 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/enigma/` ou `lib/features/investigation/` (écran/widget LORE) |
| Structure Backend | `src/services/` (lore ou enigma), `src/api/graphql/queries.rs` |
| État Flutter | `AsyncValue` pour chargement contenu LORE ; pas de booléen `isLoading` séparé |
| API GraphQL | Champs ou query pour contenu LORE ; pas de mutation (lecture seule) |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour Sauter et contenu LORE |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Affichage images : `cached_network_image` ou équivalent si images distantes ; sinon `Image.asset`. Pas de nouvelle dépendance obligatoire si contenu local (assets).
- **Backend** : Pas de nouvelle dépendance obligatoire ; stockage texte et références médias (URLs ou chemins) en DB.
- [Source: architecture.md – Content & LORE]

---

## File Structure Requirements

- **Flutter** : `lib/features/enigma/screens/lore_screen.dart` (ou `lib/features/investigation/widgets/lore_content_widget.dart`) ; intégration dans le flux enquête (route ou étape conditionnelle). Fichiers GraphQL : query `getLoreContent` ou champs sur Investigation/Enigma.
- **Backend** : Résolveurs GraphQL pour contenu LORE ; table ou champs pour séquences LORE (investigation_id, sequence_index, content_text, media_urls, etc.).
- **Assets** : Images LORE dans `assets/` si contenu local ; références dans le backend ou config (FR37).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour la lecture du contenu LORE (ex. `tests/api/enigmas_test.rs` ou investigations) – au moins un cas nominal (FR34, FR37).
- **Flutter** : Tests widget pour affichage LORE (texte, images), présence et action du bouton « Sauter » (navigation vers la suite) ; mocker les queries GraphQL (FR34, FR35).
- **Qualité** : Pas de régression sur 4.1–4.3 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 4.1–4.3)

- **Flux enquête** : 4.1 (photo, géo), 4.2 (mots, puzzle), 4.3 (aide, explications après résolution) définissent le flux : énigme → validation → explications (4.3) → énigme suivante. En 4.4, insérer les séquences LORE à des points définis (ex. avant une énigme, après une énigme, intro) ; le LORE est une « étape » optionnelle que l'utilisateur peut sauter (FR35).
- **Ne pas dupliquer** : réutiliser le routeur/dispatcher du flux enquête ; ajouter une étape « LORE » avec écran/widget dédié et bouton Sauter. Les explications historiques après résolution (4.3) restent distinctes du LORE narratif (4.4) ; le LORE = récit/narration, les explications = contenu éducatif post-résolution.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **UX** : Option sauter LORE (ux-design-specification) ; design system « carnet de détective » pour le contenu narratif et les photos (FR37).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
