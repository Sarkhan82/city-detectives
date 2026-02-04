# Story 8.2: Préférences de notifications

**Story ID:** 8.2  
**Epic:** 8 – Push Notifications  
**Story Key:** 8-2-preferences-notifications  
**Status:** ready-for-dev  
**Depends on:** Story 8.1  
**Parallelizable with:** Story 5.2, Story 6.2, Story 9.2  
**Lane:** C  
**FR:** FR91  

---

## Story

As a **utilisateur**,  
I want **choisir quels types de notifications je reçois**,  
So that **je ne sois pas submergé**.

---

## Acceptance Criteria

1. **Given** l'utilisateur est dans les paramètres  
   **When** il modifie les préférences de notifications  
   **Then** les types de notifications (enquêtes, rappels, villes, etc.) sont configurables (FR91)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Backend : stockage et API des préférences
  - [ ] 1.1 Backend : table ou champs pour les préférences de notifications (ex. `user_notification_preferences` : user_id, notify_new_investigations, notify_reminders, notify_new_cities ; ou colonnes sur `users` / table `user_preferences`) ; migration sqlx (FR91).
  - [ ] 1.2 Backend : mutation `updateNotificationPreferences(input)` protégée par JWT (user_id du token) ; input avec champs booléens par type (ex. newInvestigations, reminders, newCities) ; persistance (FR91).
  - [ ] 1.3 Backend : query pour lire les préférences (ex. `getNotificationPreferences` ou champs dans `getUser` / `me`) ; retour type nommé ex. `NotificationPreferences` avec champs camelCase (FR91).
  - [ ] 1.4 Backend : lors de l’envoi des notifications (8.1), filtrer les destinataires selon leurs préférences — n’envoyer « nouvelle enquête » que si `notify_new_investigations`, « rappel » que si `notify_reminders`, « nouvelle ville » que si `notify_new_cities` (FR91).
- [ ] **Task 2** (AC1) – Interface paramètres (Flutter)
  - [ ] 2.1 Flutter : écran ou section « Paramètres » (ex. `lib/features/profile/screens/settings_screen.dart` ou `lib/features/settings/`) avec une sous-section « Notifications » (FR91).
  - [ ] 2.2 Flutter : afficher les options par type (ex. « Nouvelles enquêtes dans ma ville », « Rappels d’enquêtes incomplètes », « Nouvelles villes dans ma région ») avec interrupteurs (Switch) ou cases à cocher ; état initial chargé via query (getNotificationPreferences ou getUser) (FR91).
  - [ ] 2.3 Flutter : à chaque modification, appeler la mutation `updateNotificationPreferences` ; feedback succès/erreur ; AsyncValue pour chargement (FR91).
  - [ ] 2.4 Design : cohérent avec le design system ; libellés clairs et accessibles (FR91).
- [ ] **Task 3** – Valeurs par défaut et cohérence
  - [ ] 3.1 Définir les valeurs par défaut (ex. toutes les notifications activées à la création du compte ou au premier accès aux paramètres) ; créer l’enregistrement de préférences à la première lecture ou à l’inscription (FR91).
  - [ ] 3.2 S’assurer que les utilisateurs sans enregistrement de préférences sont traités de manière cohérente (ex. défaut = tout activé, ou tout désactivé selon produit) (FR91).
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d’intégration pour updateNotificationPreferences (persistance, lecture) et vérifier que le filtre d’envoi push respecte les préférences (FR91).
  - [ ] 4.2 Flutter : tests widget pour l’écran/section préférences (affichage des options, soumission mockée) (FR91).
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 8.1.
  - [ ] 4.4 Accessibilité : labels pour chaque option (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 8.2 = contrôle utilisateur sur les types de notifications (FR91).** S’appuie sur 8.1 (envoi des trois types : nouvelles enquêtes, rappels, nouvelles villes). Ici on persiste les préférences et on filtre les envois côté backend ; l’utilisateur voit et modifie les options dans les paramètres.
- **Alignement avec 8.1** : Les déclencheurs (nouvelle enquête, rappel, nouvelle ville) restent tels quels ; avant d’envoyer à un utilisateur, le backend consulte ses préférences et n’envoie que les types autorisés.
- **Évolutivité** : Prévoir une structure extensible (ex. type enum ou champs nommés) pour ajouter plus tard d’autres types (FR88, FR89, FR90 en V1.0+ : amis, badges, défis) sans refonte.

### Project Structure Notes

- **Flutter** : `lib/features/profile/` ou `lib/features/settings/` — écran paramètres avec section Notifications ; provider/repository pour get/update préférences ; GraphQL `get_notification_preferences.graphql`, `update_notification_preferences.graphql`.
- **Backend** : table `user_notification_preferences` (ou équivalent) ; `src/services/user_preferences_service.rs` ou extension de `user_service` ; mutations et query dans `src/api/graphql/` ; dans `push_service.rs`, appeler la lecture des préférences avant envoi et filtrer (FR91).
- [Source: architecture.md § Push Notifications, § Requirements to Structure Mapping]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 8, Story 8.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – Push notifications]
- [Source: _bmad-output/project-context.md – Technology Stack]
- [Source: Story 8.1 – envoi push, types de notifications]

---

## Architecture Compliance

| Règle | Application pour 8.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/profile/` ou `lib/features/settings/` – section préférences notifications |
| Structure Backend | Table préférences ; service user_preferences ou user ; filtre dans push_service |
| API GraphQL | Type NotificationPreferences, mutation updateNotificationPreferences, query getNotificationPreferences ; champs camelCase |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels options |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, graphql_flutter déjà en place. Widgets standard (Switch, Checkbox) pour les options ; aucune nouvelle dépendance obligatoire.
- **Backend** : sqlx pour persistance ; pas de nouvelle dépendance ; réutilisation du push_service pour le filtre (FR91).
- [Source: architecture.md – Push notifications]

---

## File Structure Requirements

- **Flutter** : `lib/features/profile/screens/settings_screen.dart` (ou `lib/features/settings/settings_screen.dart`) avec section notifications ; `lib/features/profile/graphql/` (ou core) pour les opérations préférences.
- **Backend** : migration pour `user_notification_preferences` (user_id, notify_new_investigations, notify_reminders, notify_new_cities, etc.) ; `src/services/user_preferences_service.rs` ou équivalent ; `src/api/graphql/mutations.rs` (updateNotificationPreferences), queries (getNotificationPreferences ou champs dans me) ; adaptation de `push_service.rs` pour filtrer par préférences.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d’intégration pour updateNotificationPreferences et getNotificationPreferences ; test que l’envoi push (mock ou unitaire) n’envoie pas à un utilisateur qui a désactivé le type concerné (FR91).
- **Flutter** : Tests widget pour la section préférences (affichage, bascule des options, appel mutation avec mocks) (FR91).
- **Qualité** : Pas de régression sur 8.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 8.1)

- **8.1** met en place l’enregistrement des tokens et l’envoi des trois types de notifications (nouvelles enquêtes, rappels, nouvelles villes). En 8.2 on ajoute le stockage des préférences par utilisateur et on filtre les envois : avant d’envoyer une notification de type X, le backend vérifie que l’utilisateur a activé le type X. L’UI paramètres permet de modifier ces préférences.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **FR91** : Contrôle explicite des types de notifications ; les préférences doivent être persistées et prises en compte à chaque envoi.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
