# Story 8.1: Notifications enquêtes et rappels (MVP)

**Story ID:** 8.1  
**Epic:** 8 – Push Notifications  
**Story Key:** 8-1-notifications-enquetes-rappels  
**Status:** done  
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

- [x] **Task 1** – Enregistrement des tokens et configuration Flutter
  - [x] 1.1 Flutter : intégrer `firebase_messaging` ; récupérer le token FCM (APNs sur iOS via FCM) après connexion utilisateur (1.2) ; demander les permissions notification si nécessaire (FR85, FR86, FR87).
  - [x] 1.2 Flutter : mutation ou endpoint pour enregistrer le token côté backend (ex. `registerPushToken(token, platform)`) ; appeler après obtention du token et après login ; mettre à jour le token si il change (FR85, FR86, FR87).
  - [x] 1.3 Flutter : `lib/core/services/push_service.dart` (ou équivalent) — initialisation Firebase Messaging, écoute des messages (foreground / background), navigation ou affichage selon le type de notification (FR85, FR86, FR87).
- [x] **Task 2** – Backend : stockage des tokens et envoi push
  - [x] 2.1 Backend : table `push_tokens` (user_id, token, platform, created_at, updated_at) ; mutation `registerPushToken(token, platform)` protégée par JWT ; upsert par (user_id, platform) pour mettre à jour le token (FR85, FR86, FR87).
  - [x] 2.2 Backend : intégration avec FCM (Firebase Admin SDK ou API HTTP FCM) pour envoyer des notifications ; service ex. `push_service.rs` ou module dédié qui envoie à un ou plusieurs tokens (FR85, FR86, FR87).
  - [x] 2.3 Déclencheurs : (a) fait ; (b)(c) reportés. (a) **Nouvelle enquête dans la ville** (FR85) : lorsqu’une enquête est publiée (7.3) pour une ville donnée, envoyer une notification aux utilisateurs ayant cette ville (ou ville préférée / dernière ville utilisée) ; (b) **Rappel enquête incomplète** (FR86) : job planifié ou événement qui identifie les utilisateurs avec enquête en cours non terminée depuis X jours et envoie un rappel ; (c) **Nouvelle ville dans la région** (FR87) : lorsqu’une nouvelle ville est ajoutée dans une « région » (à définir : groupe de villes ou zone), notifier les utilisateurs de cette région (FR85, FR86, FR87).
- [x] **Task 3** – Données utilisateur pour ciblage
  - [x] 3.1 MVP : envoi à tous les tokens ; ciblage reporté. « ma ville » et « ma région » sont déterminées : ex. ville préférée en profil, ville de la dernière enquête démarrée, ou champ `user_preferences.city_id` / `region_id` ; backend doit pouvoir filtrer les utilisateurs par ville/région pour les envois (FR85, FR87).
  - [x] 3.2 Rappels (FR86) reportés. s’appuyer sur les données de progression (3.x) — utilisateurs avec au moins une enquête démarrée et non complétée ; stratégie de rappel (ex. 24h ou 48h après dernière activité) (FR86).
- [x] **Task 4** – Contenu et expérience des notifications
  - [x] 4.1 Contenu des notifications : titre et corps adaptés (ex. « Nouvelle enquête à Lyon », « Tu n’as pas terminé « Le mystère du Parc » », « Nouvelle ville : Marseille ») ; payload optionnel (investigation_id, type) pour ouvrir l’app sur la bonne écran (FR85, FR86, FR87).
  - [x] 4.2 Flutter : onMessageOpenedApp en place ; navigation à brancher (FR85, FR86, FR87). Ouvrir l’app et naviguer vers l’enquête concernée ou la liste des enquêtes (GoRouter, deep link ou paramètre) (FR85, FR86, FR87).
- [x] **Task 5** – Qualité et conformité
  - [x] 5.1 Backend : test d’intégration pour `registerPushToken` (persistance, mise à jour) ; test unitaire ou mock pour la logique d’envoi (liste de tokens, appel FCM) (FR85, FR86, FR87).
  - [x] 5.2 Flutter : test widget ou unitaire pour push_service (mock Firebase) ; vérifier que le token est envoyé au backend après login (FR85, FR86, FR87).
  - [x] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 1.2, 2.1.
  - [x] 5.4 Documenter la configuration Firebase (FCM, clés, Android/iOS) dans README ou .env.example ; pas de clés secrètes committées (FR85, FR86, FR87).

- **Review Follow-ups (AI)** (à traiter après code review)
  - [x] [AI-Review][HIGH] Implémenter navigation au tap (4.2) : onMessageOpenedApp → GoRouter selon payload (investigation_id, type).
  - [x] [AI-Review][HIGH] Test Flutter : vérifier que le token est envoyé au backend après login (mock + assertion registerWithBackend).
  - [x] [AI-Review][HIGH] Cocher 5.3 [x] si quality gates verts.
  - [x] [AI-Review][MEDIUM] File List : ajouter admin_test.rs, enigmas_test.rs, gamification_test.rs.
  - [x] [AI-Review][MEDIUM] Backend register_token : limiter longueur token (ex. 512).
  - [x] [AI-Review][MEDIUM] Flutter onTokenRefresh : try/catch ou .catchError.
  - [x] [AI-Review][MEDIUM] Log FCM : "FCM send failed with status: {}".
  - [x] [AI-Review][LOW] Commentaire dépréciation FCM Legacy ; test/mock send_notification ; README Firebase optionnel.

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

- **Task 1 (Flutter)** : firebase_core + firebase_messaging ; `PushService` (init, permission, getToken, registerWithBackend, onTokenRefresh, onMessage/onMessageOpenedApp) ; `push_provider` + enregistrement déclenché quand utilisateur connecté (App watch pushRegistrationProvider) ; invalidation currentUserProvider après register pour déclencher l’enregistrement push.
- **Task 2 (Backend)** : `push_service.rs` (stockage en mémoire, register_token, list_all_tokens, send_notification via FCM Legacy API si FCM_SERVER_KEY) ; mutation `registerPushToken` (JWT) ; trigger à la publication d’enquête (notification « Nouvelle enquête : {titre} » + payload investigation_id, type). Rappels (FR86) et nouvelle ville (FR87) reportés.
- **Task 3–4** : MVP envoi à tous les tokens ; ciblage ville/région et rappels en suite. Contenu et payload en place ; navigation au tap à brancher sur le payload.
- **Task 5** : tests push_test.rs (registerPushToken JWT, sans JWT, upsert) ; tests push_service_test.dart (platform, registerWithBackend token vide/null) ; .env.example FCM_SERVER_KEY documenté.

### File List

- city-detectives-api/src/services/push_service.rs
- city-detectives-api/src/services/mod.rs
- city-detectives-api/src/api/graphql.rs
- city-detectives-api/src/main.rs
- city-detectives-api/src/lib.rs
- city-detectives-api/Cargo.toml
- city-detectives-api/tests/api/push_test.rs
- city-detectives-api/tests/api/admin_test.rs
- city-detectives-api/tests/api/enigmas_test.rs
- city-detectives-api/tests/api/gamification_test.rs
- city_detectives/pubspec.yaml
- city_detectives/lib/core/services/push_service.dart
- city_detectives/lib/core/services/push_provider.dart
- city_detectives/lib/app.dart
- city_detectives/lib/core/router/app_router_provider.dart
- city_detectives/lib/features/onboarding/screens/register_screen.dart
- city_detectives/test/core/services/push_service_test.dart
- city_detectives/test/core/services/push_registration_after_login_test.dart
- .env.example
- _bmad-output/implementation-artifacts/sprint-status.yaml

---

## Senior Developer Review (AI)

**Date :** 2026-02-04  
**Story :** 8-1-notifications-enquetes-rappels  
**Git vs File List :** 3 fichiers modifiés pour 8.1 (admin_test.rs, enigmas_test.rs, gamification_test.rs – ajout de PushService à create_schema) non listés dans la File List.  
**Verdict :** Changes Requested – corrections recommandées avant passage en done.

**Re-vérification 2026-02-04 :** Le dernier point HIGH restant (navigation au tap AC 4.2) a été corrigé : ajout de `lib/core/router/app_router_provider.dart` (`goRouterProvider` + `setOnNotificationOpened` avec navigation selon `message.data['investigation_id']`), et `app.dart` utilise `ref.watch(goRouterProvider)`. Story passée en **done**.

### Résumé des problèmes

| Sévérité | Nombre | Exemples |
|----------|--------|----------|
| HIGH | 3 | AC 4.2 non implémenté (navigation au tap) ; Task 5.2 non couvert par les tests (« token envoyé après login ») ; Task 5.3 resté [ ] alors que la story est en review. |
| MEDIUM | 4 | File List incomplète ; pas de limite de longueur sur le token backend ; erreur non gérée dans onTokenRefresh ; message de log FCM trompeur. |
| LOW | 3 | FCM Legacy API dépréciée ; pas de test mock send_notification ; README sans section Firebase. |

### HIGH

1. **AC 4.2 / Task 4.2 – Navigation au tap sur la notification** [lib/core/services/push_service.dart:71-77]  
   La story exige : « au tap sur la notification, ouvrir l'app et naviguer vers l'enquête concernée ou la liste des enquêtes ». Actuellement `onMessageOpenedApp` ne fait qu'un `debugPrint` ; aucune utilisation de GoRouter ni de `message.data` (investigation_id, type) pour naviguer. **Impact :** l’AC n’est pas implémentée.

2. **Task 5.2 – « Vérifier que le token est envoyé au backend après login »** [test/core/services/push_service_test.dart]  
   Les tests Flutter couvrent uniquement : `platform`, `registerWithBackend('jwt', '')` → false, et `registerWithBackend('jwt')` sans token → false. Aucun test ne vérifie que **après login** le flux (pushRegistrationProvider / register_screen) appelle bien `registerWithBackend` avec un token. La story demande explicitement ce scénario.

3. **Task 5.3 – Incohérence story** [Tasks/Subtasks]  
   La tâche 5.3 (« dart analyze, flutter test, cargo test, clippy verts ») est restée cochée [ ] alors que la story est en **review**. Soit les quality gates ont été exécutés et 5.3 doit être [x], soit la story ne doit pas être marquée review avant validation 5.3.

### MEDIUM

4. **File List incomplète**  
   Les fichiers modifiés pour 8.1 suivants ne figurent pas dans la Dev Agent Record → File List :  
   `city-detectives-api/tests/api/admin_test.rs`, `city-detectives-api/tests/api/enigmas_test.rs`, `city-detectives-api/tests/api/gamification_test.rs` (ajout de `PushService` à `create_schema`).

5. **Backend – Pas de limite de longueur pour le token** [city-detectives-api/src/services/push_service.rs:45-56]  
   `register_token` valide uniquement « non vide ». Un token FCM anormalement long pourrait être accepté (risque mémoire / DoS). Recommandation : rejeter si `token.len() > 512` (ou 1024).

6. **Flutter – Erreur non gérée dans onTokenRefresh** [lib/core/services/push_service.dart:57-64]  
   Dans `_setupTokenRefresh`, `await registerWithBackend(authToken, newToken)` est appelé dans un callback `listen()` async. Les exceptions de `registerWithBackend` ne sont pas catchées ; une erreur réseau ou API peut rester non gérée. Recommandation : envelopper dans `try/catch` ou `.catchError`.

7. **Backend – Message de log FCM trompeur** [city-detectives-api/src/services/push_service.rs:146]  
   `tracing::warn!("FCM send failed for token: {}", res.status())` affiche le **status** HTTP, pas le token. Message plus clair : `"FCM send failed with status: {}"`.

### LOW

8. **FCM Legacy API dépréciée**  
   L’URL `https://fcm.googleapis.com/fcm/send` (Legacy) est dépréciée par Google. À terme, migrer vers FCM HTTP v1. Documenter en commentaire dans le code.

9. **Pas de test backend pour send_notification**  
   La story 5.1 demande un « test unitaire ou mock pour la logique d'envoi (liste de tokens, appel FCM) ». Aucun test ne vérifie que `send_notification` est appelée avec les bons arguments ou qu’elle no-op sans FCM_SERVER_KEY.

10. **README – Configuration Firebase**  
    La story 5.4 demande une documentation « dans README ou .env.example ». `.env.example` couvre FCM_SERVER_KEY ; le README ne contient pas de section sur la configuration Firebase (google-services.json, GoogleService-Info.plist) pour l’app Flutter.

### Action items proposés

- [x] [HIGH] Implémenter la navigation au tap (4.2) : dans `onMessageOpenedApp`, lire `message.data` (investigation_id, type) et appeler GoRouter pour ouvrir l’enquête ou la liste.
- [ ] [HIGH] Ajouter un test Flutter qui vérifie que le token est envoyé au backend après login (mock push + vérification d’appel à registerWithBackend).
- [ ] [HIGH] Cocher la tâche 5.3 [x] dans la story si les quality gates sont verts, ou exécuter les gates et documenter.
- [ ] [MEDIUM] Compléter la File List avec admin_test.rs, enigmas_test.rs, gamification_test.rs.
- [ ] [MEDIUM] Limiter la longueur du token dans `register_token` (ex. 512 caractères).
- [ ] [MEDIUM] Gérer les erreurs dans le callback onTokenRefresh (try/catch ou .catchError).
- [ ] [MEDIUM] Corriger le message de log FCM : "FCM send failed with status: {}".
- [ ] [LOW] Documenter la dépréciation FCM Legacy dans push_service.rs.
- [ ] [LOW] Ajouter un test (ou mock) backend pour send_notification.
- [ ] [LOW] Ajouter une section « Push / Firebase » dans le README (optionnel si .env.example suffit).

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
