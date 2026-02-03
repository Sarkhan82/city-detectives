# Story 6.1: Première enquête gratuite et visibilité payant

**Story ID:** 6.1  
**Epic:** 6 – Monetization & Purchases  
**Story Key:** 6-1-premiere-enquete-gratuite-visibilite-payant  
**Status:** ready-for-dev  
**Depends on:** Story 2.2, Story 4.1  
**Parallelizable with:** Story 5.1, Story 8.1, Story 9.1  
**Lane:** C  
**FR:** FR46, FR47, FR49  

---

## Story

As a **utilisateur**,  
I want **accéder à la première enquête gratuite et voir clairement les enquêtes payantes et leurs prix**,  
So that **je sache quoi acheter si je veux continuer**.

---

## Acceptance Criteria

1. **Given** l'utilisateur est connecté  
   **When** il consulte le catalogue  
   **Then** la première enquête gratuite est accessible sans paiement (FR46)  
   **And** les enquêtes payantes et leurs prix sont affichés (FR47, FR49)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Première enquête gratuite accessible
  - [ ] 1.1 Définir et exposer « la première enquête gratuite » : une enquête désignée comme gratuite (ex. `is_free = true` pour une enquête, ou champ `is_first_free` / règle métier « première du catalogue ») (FR46).
  - [ ] 1.2 Backend : s'assurer que la query catalogue (ex. `listInvestigations`) permet d'identifier cette enquête (champ `isFree` déjà en 2.2) ; optionnel : query `getFirstFreeInvestigation()` ou règle « première enquête avec is_free = true » (FR46).
  - [ ] 1.3 Flutter : pour l'enquête gratuite désignée, aucun paywall ni écran d'achat ; l'utilisateur peut la sélectionner et la démarrer directement (comme en 2.2, 3.1) (FR46).
- [ ] **Task 2** (AC1) – Enquêtes payantes et prix affichés
  - [ ] 2.1 Afficher pour chaque enquête payante un libellé « Payant » et le prix (ex. « 2,99 € », « 4,99 € ») (FR47, FR49).
  - [ ] 2.2 Backend : exposer le prix par enquête (ex. champ `price` ou `priceAmount`, `priceCurrency` sur Investigation dans le schéma GraphQL). Données en DB (colonnes `price_amount`, `price_currency` ou équivalent) (FR47, FR49).
  - [ ] 2.3 Flutter : sur l'écran liste ou détail des enquêtes (2.1, 2.2), afficher le prix pour les enquêtes payantes ; design system « carnet de détective » (FR47, FR49).
- [ ] **Task 3** (AC1) – Catalogue et cohérence
  - [ ] 3.1 Catalogue : réutiliser l'écran liste des enquêtes (2.1, 2.2) ; s'assurer qu'une enquête est bien marquée gratuite (première gratuite) et que les autres affichent prix si payantes (FR46, FR47, FR49).
  - [ ] 3.2 Pas de blocage pour l'enquête gratuite : pas d'écran « Acheter » ni de vérification d'achat pour celle-ci ; pour les payantes, afficher le prix et préparer le terrain pour 6.2 (bouton « Acheter » ou équivalent, sans implémenter le flux complet dans 6.1) (FR46, FR47).
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d'intégration pour le champ prix dans listInvestigations (ou getInvestigationById) ; vérifier qu'une enquête est retournée comme gratuite (FR46, FR47, FR49).
  - [ ] 4.2 Flutter : tests widget pour la liste avec première enquête gratuite accessible (pas de paywall) et prix affichés pour les payantes ; mocker API (FR46, FR47, FR49).
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 2.1, 2.2, 4.1.
  - [ ] 4.4 Accessibilité : labels pour Gratuit, Payant, prix (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 6.1 = première enquête gratuite + visibilité payant/prix.** S'appuie sur 2.2 (liste enquêtes, libellé gratuit/payant, sélection pour démarrer) et 4.1 (énigmes résolubles). Ici on renforce : (1) une enquête est explicitement « première gratuite » et accessible sans paiement (FR46), (2) les enquêtes payantes affichent leur prix (FR47, FR49). Pas de flux d'achat dans 6.1 (6.2).
- **Flutter** : Réutiliser `lib/features/investigation/` (liste, détail) ; s'assurer qu'aucun paywall ne bloque l'enquête gratuite ; afficher le prix (champ `price` ou équivalent) pour les enquêtes payantes. Architecture : `lib/core/services/payment_service.dart` pour usage futur (6.2) ; pas obligatoire pour 6.1 si uniquement affichage.
- **Backend** : Champ `price` (ou `price_amount`, `price_currency`) sur Investigation ; une enquête avec `is_free = true` (ou désignée comme première gratuite) ; pas de mutation d'achat dans 6.1 (FR46, FR47, FR49).

### Project Structure Notes

- **Flutter** : `lib/features/investigation/` – écran liste/détail (2.1, 2.2) ; affichage prix pour enquêtes payantes ; pas de blocage pour l'enquête gratuite. Optionnel : `lib/core/services/payment_service.dart` (stub ou préparation 6.2).
- **Backend** : `src/services/investigation_service.rs` (ou `payment_service.rs` pour règles tarifaires) ; schéma GraphQL Investigation avec `price`, `priceCurrency` (ou équivalent) ; une enquête marquée gratuite (ex. `is_free = true`). Table `investigations` : colonnes `price_amount`, `price_currency` (nullable pour gratuites) (FR46, FR47, FR49).
- [Source: architecture.md § Monetization, payment_service]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 6, Story 6.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – Monetization, payment_service]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 6.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/investigation/` (liste, détail) ; affichage prix ; pas de paywall pour gratuite |
| Structure Backend | `src/services/investigation_service.rs`, schéma GraphQL (price, isFree) |
| API GraphQL | Champs `price`, `priceCurrency` (ou équivalent) sur Investigation ; camelCase |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels Gratuit, Payant, prix |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Pas de nouvelle dépendance obligatoire pour 6.1 (affichage prix = texte ou widget standard). `in_app_purchase` (architecture) pour 6.2, pas pour 6.1.
- **Backend** : Pas de nouvelle dépendance obligatoire ; champs prix en DB (décimal ou entier centimes) (FR47, FR49).
- [Source: architecture.md – Monetization, in_app_purchase]

---

## File Structure Requirements

- **Flutter** : Réutiliser `lib/features/investigation/screens/` (liste, détail) ; afficher `price` (et `priceCurrency`) pour les enquêtes payantes ; s'assurer que l'enquête gratuite n'a pas de paywall. Fichiers GraphQL : schéma étendu avec `price`, `priceCurrency` sur Investigation.
- **Backend** : `src/services/investigation_service.rs` (ou modèle Investigation) ; colonnes `price_amount`, `price_currency` (nullable) ; résolution GraphQL pour ces champs. Migrations sqlx si ajout de colonnes (FR46, FR47, FR49).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d'intégration pour listInvestigations (ou getInvestigationById) avec champs `isFree`, `price`, `priceCurrency` ; au moins une enquête gratuite et une payante avec prix (FR46, FR47, FR49).
- **Flutter** : Tests widget pour liste/détail : enquête gratuite accessible (pas d'écran achat), enquêtes payantes avec prix affiché ; mocker API (FR46, FR47, FR49).
- **Qualité** : Pas de régression sur 2.1, 2.2, 4.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Dependency Context (Story 2.2, 4.1)

- **2.2** : Liste des enquêtes avec libellé Gratuit/Payant (`isFree`), sélection pour démarrer. En 6.1, réutiliser cette liste ; ajouter l'affichage du **prix** pour les payantes (FR49) et s'assurer qu'**une** enquête est bien la « première gratuite » et accessible sans aucun paiement (FR46).
- **4.1** : Énigmes résolubles ; pas de lien direct avec 6.1 sauf que l'utilisateur peut compléter des enquêtes (contexte catalogue). Pas de duplication : 6.1 ne modifie pas le flux de démarrage (3.1), uniquement la désignation « première gratuite » et l'affichage des prix.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Monetization** : Simulation paiement MVP (6.2) ; pour 6.1, uniquement visibilité gratuit/prix et accès sans paiement à la première enquête (FR46, FR47, FR49).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
