# Story 8.1: Notifications enquêtes et rappels (MVP)

**Story ID:** 8.1  
**Epic:** 8 – Push Notifications  
**Story Key:** 8-1-notifications-enquetes-rappels  
**Status:** ready-for-dev  
**Depends on:** Story 1.2, Story 2.1  
**Parallelizable with:** Story 5.1, Story 6.1, Story 9.1  
**Lane:** C  
**FR:** FR85, FR86, FR87  

---

## Story

As a **utilisateur**,  
I want **recevoir des notifications sur les nouvelles enquêtes dans ma ville, les rappels d'enquêtes incomplètes et les nouvelles villes dans ma région**,  
So that **je reste engagé**.

---

## Acceptance Criteria

1. **Given** le backend push est configuré (tokens, FCM/APNs)  
   **When** un événement pertinent se produit (nouvelle enquête, rappel, nouvelle ville)  
   **Then** l'utilisateur reçoit la notification correspondante (FR85, FR86, FR87)

---

## Tasks / Subtasks

- [ ] **Task 1** – Enregistrement des tokens et configuration Flutter
  - [ ] 1.1 Flutter : intégrer `firebase_messaging` ; récupérer le token FCM (APNs sur iOS via FCM) après connexion utilisateur (1.2) ; demander les permissions notification si nécessaire (FR85, FR86, FR87).
  - [ ] 1.2 Flutter : mutation ou endpoint pour enregistrer le token côté backend (ex. `registerPushToken(token, platform)`) ; appeler après obtention du token et après login ; mettre à jour le token si il change (FR85, FR86, FR87).
  - [ ] 1.3 Flutter : `lib/core/services/push_service.dart` (ou équivalent) — initialisation Firebase Messaging, écoute des messages (foreground / background), navigation ou affichage selon le type de notification (FR85, FR86, FR87).
- [ ] **Task 2** – Backend : stockage des tokens et envoi push
  - [ ] 2.1 Backend : table `push_tokens` (user_id, token, platform, created_at, updated_at) ; mutation `registerPushToken(token, platform)` protégée par JWT ; upsert par (user_id, platform) pour mettre à jour le token (FR85, FR86, FR87).
  - [ ] 2.2 Backend : intégration avec FCM (Firebase Admin SDK ou API HTTP FCM) pour envoyer des notifications ; service ex. `push_service.rs` ou module dédié qui envoie à un ou plusieurs tokens (FR85, FR86, FR87).
  - [ ] 2.3 Déclencheurs : (a) **Nouvelle enquête dans la ville** (FR85) : lorsqu’une enquête est publiée (7.3) pour une ville donnée, envoyer une notification aux utilisateurs ayant cette ville (ou ville préférée / dernière ville utilisée) ; (b) **Rappel enquête incomplète** (FR86) : job planifié ou événement qui identifie les utilisateurs avec enquête en cours non terminée depuis X jours et envoie un rappel ; (c) **Nouvelle ville dans la région** (FR87) : lorsqu’une nouvelle ville est ajoutée dans une « région » (à définir : groupe de villes ou zone), notifier les utilisateurs de cette région (FR85, FR86, FR87).
- [ ] **Task 3** – Données utilisateur pour ciblage
  - [ ] 3.1 Définir comment « ma ville » et « ma région » sont déterminées : ex. ville préférée en profil, ville de la dernière enquête démarrée, ou champ `user_preferences.city_id` / `region_id` ; backend doit pouvoir filtrer les utilisateurs par ville/région pour les envois (FR85, FR87).
  - [ ] 3.2 Enquêtes incomplètes : s’appuyer sur les données de progression (3.x) — utilisateurs avec au moins une enquête démarrée et non complétée ; stratégie de rappel (ex. 24h ou 48h après dernière activité) (FR86).
- [ ] **Task 4** – Contenu et expérience des notifications
  - [ ] 4.1 Contenu des notifications : titre et corps adaptés (ex. « Nouvelle enquête à Lyon », « Tu n’as pas terminé « Le mystère du Parc » », « Nouvelle ville : Marseille ») ; payload optionnel (investigation_id, type) pour ouvrir l’app sur la bonne écran (FR85, FR86, FR87).
  - [ ] 4.2 Flutter : au tap sur la notification, ouvrir l’app et naviguer vers l’enquête concernée ou la liste des enquêtes (GoRouter, deep link ou paramètre) (FR85, FR86, FR87).
- [ ] **Task 5** – Qualité et conformité
  - [ ] 5.1 Backend : test d’intégration pour `registerPushToken` (persistance, mise à jour) ; test unitaire ou mock pour la logique d’envoi (liste de tokens, appel FCM) (FR85, FR86, FR87).
  - [ ] 5.2 Flutter : test widget ou unitaire pour push_service (mock Firebase) ; vérifier que le token est envoyé au backend après login (FR85, FR86, FR87).
  - [ ] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 1.2, 2.1.
  - [ ] 5.4 Documenter la configuration Firebase (FCM, clés, Android/iOS) dans README ou .env.example ; pas de clés secrètes committées (FR85, FR86, FR87).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 8.1 = premier pas Epic 8 (push MVP).** S’appuie sur 1.2 (auth, utilisateur connecté) et 2.1 (catalogue enquêtes). Architecture : `firebase_messaging` (Flutter), Firebase pour push ; backend enregistre les tokens (architecture : « backend enregistrement des tokens ») et envoie les notifications (via Firebase Admin SDK ou API FCM).
- **Ville / région** : Pour FR85 et FR87, il faut une notion de « ville de l’utilisateur » et « région ». Options : champ préférence utilisateur (ville_id, region_id), ou déduction depuis les enquêtes démarrées / complétées. Préciser en implémentation (ex. table `user_preferences` ou champs sur `users`).
- **Rappels (FR86)** : Déclenchement par cron/worker (ex. une fois par jour) ou événement « inactivité » ; définir le délai (24h, 48h) et éviter le spam (ex. max 1 rappel par enquête par semaine).
- **8.2** couvrira les préférences de notifications (FR91) ; en 8.1 on peut envoyer les trois types par défaut et filtrer en 8.2 selon les préférences.

### Project Structure Notes

- **Flutter** : `lib/core/services/push_service.dart` (architecture) ; initialisation FCM, enregistrement token, écoute des messages ; appel mutation `registerPushToken` via repository ou GraphQL. Configuration Firebase (google-services.json, GoogleService-Info.plist) hors repo ou documentée.
- **Backend** : `src/services/push_service.rs` (ou `notification_service.rs`) — enregistrement token, envoi via FCM ; table `push_tokens` ; mutation `registerPushToken` ; logique de déclenchement (après publication enquête 7.3, job rappels, nouvelle ville). Dépendance Rust : crate pour Firebase Admin (ex. `fcm` ou appel HTTP à l’API FCM).
- [Source: architecture.md § Push Notifications, § Requirements to Structure Mapping]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 8, Story 8.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – Push notifications, firebase_messaging, backend enregistrement tokens]
- [Source: _bmad-output/project-context.md – Technology Stack, firebase_messaging]
- [Source: Stories 1.2, 2.1, 3.x (progression), 7.3 (publication)]

---

## Architecture Compliance

| Règle | Application pour 8.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/core/services/push_service.dart` ; pas de logique métier dans les handlers de message |
| Structure Backend | `src/services/push_service.rs` ; table `push_tokens` ; mutation registerPushToken |
| API GraphQL | Mutation `registerPushToken(token, platform)` ; champs camelCase |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Sécurité | Pas de clés FCM/API dans le repo ; .env / config serveur |

---

## Library / Framework Requirements

- **Flutter** : `firebase_messaging` (architecture) ; `firebase_core` si requis. Aucune autre dépendance obligatoire pour 8.1.
- **Backend** : Crate pour appeler FCM (ex. `fcm`, `reqwest` pour HTTP) ou Firebase Admin SDK (Rust) ; stockage tokens en PostgreSQL (sqlx). Vérifier la doc Firebase pour envoi depuis un backend Rust.
- [Source: architecture.md – Push notifications, Firebase]

---

## File Structure Requirements

- **Flutter** : `lib/core/services/push_service.dart` ; éventuellement `lib/core/graphql/register_push_token.graphql` ou appel dans un repository ; configuration Firebase dans `android/` et `ios/` selon doc Flutter Firebase.
- **Backend** : `src/services/push_service.rs` ; `src/api/graphql/mutations.rs` (registerPushToken) ; migration pour table `push_tokens` (user_id, token, platform, created_at, updated_at).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d’intégration pour registerPushToken (token persisté, mise à jour pour même user+platform). Test ou mock de l’envoi FCM (liste de tokens, pas d’envoi réel en CI sans clé).
- **Flutter** : Test unitaire ou mock du push_service (enregistrement token, pas d’appel Firebase réel en test). Vérifier que la mutation est appelée avec le token après login.
- **Qualité** : Pas de régression sur 1.2, 2.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Dependency Context (Story 1.2, 2.1)

- **1.2** : Utilisateur connecté et JWT ; le token push est enregistré pour le user_id dérivé du JWT. Envoyer le token après login et le mettre à jour si FCM le renouvelle.
- **2.1** : Catalogue enquêtes ; les notifications « nouvelle enquête » concernent les enquêtes du catalogue (par ville). La liste des enquêtes et le modèle Investigation (avec ville si présent) sont utilisés pour le ciblage.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **NFR13** : Intégrations push 95 %+ livraison ; concevoir les retries et la gestion des tokens invalides (FCM renvoie des erreurs pour tokens expirés).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
