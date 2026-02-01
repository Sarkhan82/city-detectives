---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: complete
completedAt: '2026-01-26'
inputDocuments:
  - '_bmad-output/planning-artifacts/product-brief-city-detectives-2026-01-24.md'
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/prd-validation-report.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
  - '_bmad-output/planning-artifacts/ux-design-directions.html'
  - '_bmad-output/planning-artifacts/ux-mockup-analysis.md'
workflowType: 'architecture'
project_name: 'city-detectives'
user_name: 'Sarkhan'
date: '2026-01-26T17:47:33'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
Le projet City Detectives comprend 94 functional requirements organisés en 12 catégories principales :
- Onboarding & Account Management (5 FRs)
- Enquête Discovery & Selection (6 FRs)
- Enquête Gameplay & Navigation (11 FRs)
- Énigme Resolution & Validation (11 FRs) - supportant 12 types d'énigmes différents
- Content & LORE (5 FRs)
- Progression & Tracking (9 FRs)
- Monetization & Purchases (14 FRs)
- Social & Group Features (7 FRs, V1.0+)
- Admin & Content Management (11 FRs)
- Technical Capabilities (13 FRs)
- Push Notifications (7 FRs)
- User Feedback & Ratings (3 FRs)

**Non-Functional Requirements:**
Les NFRs critiques qui façonneront l'architecture incluent :
- **Performance** : Temps de réponse <2s (95e percentile), chargement <2s depuis cache, précision GPS <10m, enquête complète sur une charge
- **Offline** : >95% des opérations fonctionnent sans réseau, <2s pour charger une enquête en cache, >98% de synchronisation réussie
- **Stabilité** : Taux de crash <0.5%
- **Sécurité** : Conformité RGPD, chiffrement des données en transit et au repos, sécurité des paiements App Store/Google Play
- **Scalabilité** : Support de 500-1100 utilisateurs actifs (3 mois) → 5000-11000 utilisateurs actifs (12 mois)
- **Accessibilité** : WCAG 2.1 Level A minimum

**Scale & Complexity:**
- Primary domain: Mobile Application (Flutter, iOS/Android)
- Complexity level: Medium-High
  - Application mobile native avec contraintes matérielles critiques (GPS, batterie, stockage)
  - Mode offline-first complexe avec synchronisation intelligente
  - Géolocalisation précise (<10m) avec gestion d'erreurs et fallbacks
  - Support de 12 types d'énigmes différents avec interfaces adaptatives
  - Gamification et progression avec synchronisation multi-appareils
- Estimated architectural components: 15-20 composants principaux (UI, State Management, Offline Storage, Geolocation Service, Payment Service, Push Notifications, Analytics, etc.)

### Technical Constraints & Dependencies

**Contraintes techniques identifiées :**
- **Framework** : Flutter (cross-platform iOS/Android) - décision technique déjà prise
- **Plateformes** : iOS 13.0+, Android 8.0+ (API level 26+)
- **Permissions critiques** : GPS (précision <10m), Caméra, Stockage
- **Mode offline** : Fonctionnement complet sans réseau requis (V1.0+)
- **Géolocalisation** : Précision <10m pour validation des énigmes, optimisation batterie critique
- **Paiements** : Intégration App Store In-App Purchase et Google Play Billing (conformité stores)
- **Push Notifications** : Firebase Cloud Messaging (Android) et Apple Push Notification Service (iOS)
- **Conformité** : RGPD, App Store Guidelines, Google Play Policies

**Dépendances techniques :**
- Packages Flutter clés : `geolocator` (géolocalisation), `sqflite`/`hive` (cache local), `firebase_messaging` (push notifications), `in_app_purchase` (paiements), `camera`/`image_picker` (photos)
- Services backend : Firebase (push notifications), serveur de validation (paiements, synchronisation)
- APIs externes : Services de cartes (pour affichage), services de géolocalisation

### Cross-Cutting Concerns Identified

**Préoccupations transversales qui affecteront plusieurs composants :**

1. **Gestion d'état et synchronisation**
   - Architecture offline-first avec synchronisation intelligente
   - Gestion des conflits (stratégie "dernière modification gagne" pour MVP)
   - État local vs état serveur avec réconciliation
   - **Recommandation Party Mode** : Pattern Repository pour la couche données (offline-first avec sync)

2. **Géolocalisation et précision GPS**
   - Service de géolocalisation centralisé avec gestion de précision
   - Validation des énigmes basées sur localisation (<10m)
   - Optimisation batterie (mode économie d'énergie, gestion GPS en arrière-plan)
   - Fallbacks pour zones à faible précision
   - **Recommandation Party Mode** : Service Layer centralisé pour géolocalisation avec cache de coordonnées et validation serveur quand disponible

3. **Cache et stockage local**
   - Système de cache intelligent avec préchargement automatique
   - Gestion de l'espace de stockage (nettoyage automatique des enquêtes complétées)
   - Préchargement des enquêtes disponibles dans la ville actuelle
   - Téléchargement manuel optionnel pour d'autres villes
   - **Recommandation Party Mode** : `hive` recommandé pour performance avec objets complexes (enquêtes, énigmes)

4. **Performance et optimisation**
   - Optimisation batterie pour enquête complète (1h-1h30) sur une charge
   - Temps de réponse <2s pour toutes les interactions
   - Gestion mémoire pour éviter les crashes (<0.5% taux de crash)
   - Préchargement intelligent des données
   - **Recommandation Party Mode** : Optimisation des rebuilds Flutter, widgets performants pour animations <200ms

5. **Gestion des permissions**
   - Demande de permissions au moment approprié avec justification claire
   - Fallbacks gracieux si permissions refusées (mode alternatif si possible)
   - Gestion des erreurs de permissions avec messages clairs

6. **Paiements in-app**
   - Intégration App Store In-App Purchase et Google Play Billing
   - Validation serveur pour prévenir la fraude
   - Gestion des erreurs de paiement avec messages clairs
   - Simulation de paiement pour MVP (tracking de propension à payer)
   - **Recommandation Party Mode** : Analytics intégré dès le MVP pour tracking de propension à payer même avec paiement simulé

7. **Push notifications**
   - Firebase Cloud Messaging (Android) et Apple Push Notification Service (iOS)
   - Gestion des tokens et abonnements
   - Segmentation des utilisateurs pour notifications ciblées
   - Analytics sur l'engagement avec les notifications

8. **Analytics et monitoring**
   - Métriques techniques (taux de crash, performance offline, géolocalisation)
   - Métriques business (revenus, conversion, rétention)
   - Métriques utilisateurs (complétion, satisfaction, engagement)
   - Monitoring continu en production
   - **Recommandation Party Mode** : Architecture analytics robuste dès le départ pour support du modèle freemium

### Architectural Patterns & Structure Recommendations

**Recommandations issues de la discussion Party Mode :**

1. **Architecture modulaire par features**
   - Structure de dossiers claire dès le départ :
     ```
     lib/
       core/
         services/        # GeolocationService, PaymentService, PushService
         repositories/    # InvestigationRepository, UserRepository
         models/          # Investigation, Enigma, User
       features/
         onboarding/
         investigation/
         enigma/
         profile/
       shared/
         widgets/         # Reusable UI components
         utils/           # Helpers
     ```

2. **Pattern Strategy pour types d'énigmes**
   - Extensibilité pour les 12 types d'énigmes (photo, GPS, mots, puzzles, etc.)
   - Chaque type d'énigme avec son propre handler et interface commune
   - Évite la duplication de code et facilite l'ajout de nouveaux types

3. **Design System**
   - Widgets réutilisables pour cohérence UX :
     - `DetectiveButton` (styles cohérents)
     - `PrecisionCircle` (indicateur GPS)
     - `EnigmaCard` (cartes d'énigmes)
     - `ProgressIndicator` (progression)
   - Garantit la cohérence UX et facilite la maintenance

4. **Service Layer centralisé**
   - Services dédiés pour : géolocalisation, paiements, push notifications, analytics
   - Séparation claire des responsabilités
   - Facilite les tests et la maintenance

5. **State Management**
   - **Riverpod recommandé** (plus léger que Bloc pour MVP)
   - Éviter Bloc pour MVP (trop verbeux)
   - Architecture extensible pour évoluer si nécessaire

6. **Préchargement intelligent**
   - Précharger l'énigme suivante pendant la résolution actuelle
   - Transitions fluides garanties
   - Optimisation de l'expérience utilisateur

### Backend Technology Decision

**Décision : Backend Rust + Axum**

**Rationale :**
Après analyse critique des options (Firebase, Supabase, Node.js, Go, Rust), la décision a été prise de développer un backend custom en Rust pour les raisons suivantes :

1. **Qualité et pérennité** : Éviter le recodage complet dans une autre technologie plus tard
2. **Performance** : 2-3x plus rapide que Go, 5-10x plus rapide que Node.js
3. **Coûts serveur** : Réduction significative des coûts d'hébergement grâce à l'efficacité
4. **Capacités techniques complètes** :
   - ✅ Géolocalisation : GeoRust, nominatim, google_maps
   - ✅ Audio : CPAL (Cross-Platform Audio Library, 488k downloads/mois)
   - ✅ VR/AR : OpenXR, WebXR (support mature)
   - ✅ Web Backend : Axum/Actix-web (production-ready)

**Stack Backend :**
- **Langage** : Rust
- **Framework Web** : Axum (recommandé pour intégration Tokio native)
- **Database** : PostgreSQL + sqlx (type-safe) ou Diesel (ORM)
- **Géolocalisation** : `geo`, `nominatim`, `google_maps`
- **Audio** : `cpal` (si traitement serveur nécessaire)
- **VR/AR** : `openxr` (si backend processing nécessaire)
- **Auth** : JWT + bcrypt (ou OAuth2)
- **Async Runtime** : Tokio (intégré avec Axum)
- **Serialization** : `serde` (JSON, etc.)
- **Hosting** : Railway, Render, ou Fly.io (~$5-15/mois MVP)

**Trade-offs acceptés :**
- Développement plus lent initialement (courbe d'apprentissage Rust)
- Mais code plus solide, moins de bugs, pas de recodage nécessaire
- Timeline réaliste : 4-6 semaines backend MVP (vs 2-3 semaines Node.js)

**Architecture complète :**
```
Frontend: Flutter (iOS/Android)
Backend: Rust + Axum
  - Database: PostgreSQL + sqlx
  - Geolocation: GeoRust + nominatim/google_maps
  - Audio: CPAL (si nécessaire) ou storage simple
  - VR/AR: OpenXR (si backend processing)
  - Auth: JWT + bcrypt
  - Hosting: Railway ou Fly.io
```

## Starter Template Evaluation

### Primary Technology Domain

**Mobile Application (Flutter)** + **Backend API (Rust + Axum)** basé sur l'analyse des exigences du projet.

### Starter Options Considered

#### Flutter Frontend

**Option 1 : Flutter Standard (`flutter create`)**
- Commande : `flutter create city_detectives --org com.citydetectives`
- Structure de base officielle Flutter
- Avantages : Officiel, toujours à jour, structure standard
- Inconvénients : Structure minimale, nécessite configuration manuelle

**Option 2 : Ultimate Flutter Project Template**
- Repository : `jassim-bashir/ultimate-flutter-project-template`
- Features : Clean architecture, Riverpod, GoRouter, CI/CD, offline caching
- Avantages : Production-ready, architecture solide
- Inconvénients : Peut être trop complexe pour MVP, dépendances potentiellement inutiles

**Option 3 : Flutter Starter App**
- Repository : `momentous-developments/flutter-starter-app`
- Features : Riverpod, GoRouter, Material 3, Authentication, Dashboard
- Avantages : Complet, bien maintenu
- Inconvénients : Peut inclure features non nécessaires

#### Rust Backend

**Option 1 : Création manuelle (`cargo new`)**
- Commande : `cargo new city-detectives-api --bin`
- Structure de base Cargo
- Avantages : Contrôle total, structure simple
- Inconvénients : Tout à configurer manuellement

**Option 2 : Axum Boilerplate (fabienbellanger)**
- Repository : `fabienbellanger/axum-boilerplate`
- Features : Structure Axum, CI/CD, Database tooling, Docker
- Avantages : Structure prête, bonnes pratiques
- Inconvénients : Peut nécessiter ajustements, dépendances potentiellement inutiles

**Option 3 : Rust Axum Starter (PropelAuth)**
- Repository : `PropelAuth/rust-axum-starter`
- Features : Structure Axum simple, Authentication intégrée
- Avantages : Simple, auth incluse
- Inconvénients : Moins de features

### Selected Starter: Custom Structure (Approche Hybride)

**Rationale for Selection:**

Après discussion Party Mode, la décision a été prise d'utiliser une **approche hybride** : partir de zéro avec les commandes officielles, puis structurer manuellement en s'inspirant des templates (sans copier-coller).

**Pour Flutter** : Utiliser `flutter create` avec structure personnalisée, puis ajouter manuellement Riverpod, GoRouter, et architecture modulaire. Cela permet un contrôle total et une structure adaptée exactement aux besoins du projet.

**Pour Rust Backend** : Utiliser `cargo new` puis structurer manuellement avec Axum, en s'inspirant de `fabienbellanger/axum-boilerplate` pour la structure. Cela permet un contrôle total et une structure adaptée.

**Avantages de cette approche :**
- Contrôle total de l'architecture
- Pas de dépendances inutiles
- Structure adaptée au projet
- Compréhension complète dès le départ
- Qualité > Rapidité (aligné avec la philosophie du projet)

**Trade-off accepté :**
- 1-2 semaines de setup structuré (vs 2-3 jours avec templates)
- Mais architecture plus solide et adaptée au projet

**Initialization Commands:**

```bash
# Flutter Frontend
flutter create city_detectives --org com.citydetectives

# Rust Backend
cargo new city-detectives-api --bin
```

**Architectural Decisions Provided by Starter:**

**Flutter Frontend:**
- **Language & Runtime**: Dart (Flutter SDK)
- **Project Structure**: Standard Flutter avec architecture modulaire personnalisée
- **State Management**: Riverpod (à ajouter manuellement)
- **Navigation**: GoRouter (à ajouter manuellement)
- **Build Tooling**: Flutter build system
- **Code Organization**: Architecture modulaire par features (à structurer manuellement)
- **Structure cible** :
  ```
  lib/
    core/
      services/        # GeolocationService, PaymentService, PushService
      repositories/    # InvestigationRepository, UserRepository
      models/          # Investigation, Enigma, User
    features/
      onboarding/
      investigation/
      enigma/
      profile/
    shared/
      widgets/         # Reusable UI components
      utils/           # Helpers
  ```

**Rust Backend:**
- **Language & Runtime**: Rust (stable)
- **Framework**: Axum (à ajouter manuellement)
- **Database**: PostgreSQL + sqlx (à configurer)
- **Project Structure**: Cargo standard avec structure modulaire personnalisée
- **Build Tooling**: Cargo
- **Code Organization**: Architecture modulaire (à structurer manuellement)
- **Structure cible** :
  ```
  src/
    api/
      handlers/       # Request handlers
      routes/         # Route definitions
    services/         # Business logic services
    models/           # Data models
    config/           # Configuration
    db/               # Database migrations and setup
  ```

**Development Experience:**
- **Flutter** : Hot reload natif, debugging intégré, testing framework
- **Rust** : Compilation rapide en dev, excellent error messages, testing intégré

**Note:** L'initialisation des projets Flutter et Rust devrait être la première story d'implémentation.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- ✅ Backend technology: Rust + Axum
- ✅ Database: PostgreSQL + sqlx
- ✅ API design: GraphQL
- ✅ Frontend: Flutter
- ✅ State management: Riverpod (Notifier pattern)
- ✅ Authentication: JWT custom
- ✅ Infrastructure: Docker containers + VPS

**Important Decisions (Shape Architecture):**
- ✅ Data validation: Backend uniquement
- ✅ Caching: In-memory (moka) MVP, Redis V1.0+
- ✅ Offline storage: Hive avec TypeAdapters
- ✅ Navigation: GoRouter (routes déclaratives)
- ✅ CI/CD: GitHub Actions
- ✅ Monitoring: Sentry (Flutter) + Logging structuré (Rust)

**Deferred Decisions (Post-MVP):**
- OAuth2 (Google, Apple Sign-In) - V1.0+ pour améliorer UX
- Redis cache distribué - V1.0+ si besoin
- Chiffrement au repos (AES) - V1.0+ pour données sensibles
- GraphQL Subscriptions - V1.0+ pour modes groupe
- Log aggregation (Loki, etc.) - V1.0+ si nécessaire
- **Security Enhancements (V1.0+)**:
  - Refresh tokens avec rotation et blacklist
  - Rate limiting distribué (Redis)
  - Docker secrets management
  - Security monitoring avancé (alertes intrusion, détection anomalies)
  - Audit logs complets
  - Images Docker minimales (Alpine) avec non-root users
  - Security scanning des images

### Data Architecture

**Database Choice:**
- **PostgreSQL** + **sqlx** (Query Builder Type-Safe)
- **Version**: sqlx 0.8.x (stable)
- **Rationale**: Type-safe, compile-time checks, performance, contrôle SQL total, aligné avec approche qualité

**Migration Strategy:**
- **sqlx-cli** (officiel) pour migrations
- **Rationale**: Intégré avec sqlx, vérification compile-time, migrations versionnées automatiquement
- **Commandes**: `sqlx migrate add <name>` puis `sqlx migrate run`

**Caching Strategy:**
- **MVP**: In-memory cache avec `moka` (Rust)
- **V1.0+**: Redis si besoin de cache distribué
- **Rationale**: Simple, performant, suffisant pour 500-1100 utilisateurs MVP

**Data Validation:**
- **Validation backend uniquement**
- **Rationale**: Meilleure architecture, source de vérité unique, sécurité garantie, moins de complexité
- **Library**: `validator` crate (Rust)
- **Note**: Validation frontend peut être ajoutée plus tard si nécessaire (UX improvement)

**Offline Storage (Flutter):**
- **Hive avec TypeAdapters**
- **Rationale**: Type-safe, performant, aligné avec approche qualité
- **Libraries**: `hive` + `hive_generator` (Flutter)

### Authentication & Security

**Authentication Method:**
- **JWT custom** (JWT + bcrypt)
- **Rationale**: Contrôle total, simplicité, aligné avec approche qualité
- **Libraries**: `jsonwebtoken`, `bcrypt` (Rust)
- **JWT Security (MVP)**:
  - Expiration courte (15 min access token)
  - Signature forte (HS256 ou RS256)
  - Validation stricte côté serveur
- **JWT Security (V1.0+)**:
  - Refresh tokens avec rotation
  - Blacklist pour tokens révoqués (Redis ou DB)
  - Expiration refresh token (7 jours)
- **Note**: OAuth2 peut être ajouté en V1.0+ pour améliorer UX

**Token Storage (Flutter):**
- **flutter_secure_storage**
- **Rationale**: Stockage sécurisé natif (Keychain iOS, Keystore Android), standard pour tokens sensibles

**Data Encryption:**
- **bcrypt** pour mots de passe + **HTTPS (TLS)** pour transit
- **Rationale**: Standard, suffisant pour MVP
- **V1.0+**: Chiffrement au repos (AES) pour données sensibles
- **Implementation**: HTTPS via Nginx reverse proxy
- **Secrets Management (MVP)**: Variables d'environnement (.env) avec .gitignore strict
- **Secrets Management (V1.0+)**: Docker secrets ou vault pour production

**API Security:**
- **Rate Limiting**: `tower-governor` 0.8.0 (Rust)
- **Rationale**: Simple, efficace, suffisant pour MVP. Redis pour V1.0+ si besoin distribué
- **CORS**: Restrictif avec configuration par environnement (`tower-http` 0.6.8)
- **Rationale**: Sécurisé en production, permissif en dev
- **GraphQL Security (MVP)**:
  - Désactiver introspection en production
  - Query depth limiting (max 10 niveaux)
  - Query complexity analysis (max 1000 points)
  - Query timeout (max 5 secondes)
- **GraphQL Security (V1.0+)**:
  - Rate limiting par query type
  - Monitoring des queries suspectes

### API & Communication Patterns

**API Design:**
- **GraphQL** avec `async-graphql` 7.1.0 + `async-graphql-axum` 7.2.1
- **Frontend**: `graphql_flutter` 5.2.1
- **Rationale**: Support natif polymorphisme pour 12 types d'énigmes, évite over-fetching, type-safe, subscriptions pour modes groupe V1.0+

**API Versioning:**
- **Schema evolution GraphQL** (pas de versioning explicite)
- **Rationale**: Approche standard GraphQL, utilisation de `@deprecated` pour champs obsolètes

**Error Handling:**
- **GraphQL Error Format standard** + **logging complet**
- **Rationale**: Standard GraphQL, bien supporté, logging important pour debugging
- **Implementation**: Format standard GraphQL + logging détaillé côté backend (toutes erreurs loggées)

**API Documentation:**
- **GraphQL Playground** (dev) + **Schema introspection désactivée** (production)
- **Rationale**: Interactif en dev, sécurisé en production (pas d'exposition schema)
- **Implementation**: `async-graphql` supporte nativement GraphiQL, désactiver introspection en production

**Real-time Communication:**
- **GraphQL Subscriptions** pour V1.0+ (modes groupe)
- **Rationale**: Intégré avec GraphQL, standard, bien supporté par `async-graphql` et `graphql_flutter`

### Frontend Architecture

**State Management:**
- **Riverpod 2.0+** avec pattern **Notifier**
- **Rationale**: Moderne, moins verbeux, recommandé pour nouveaux projets

**Dependency Injection:**
- **Riverpod Providers uniquement**
- **Rationale**: Intégré avec Riverpod, architecture propre, pas de dépendances supplémentaires, code simple et efficace

**Navigation Structure:**
- **GoRouter** avec **routes déclaratives**
- **Rationale**: Type-safe, déclaratif, aligné avec approche qualité

**Testing Strategy:**
- **Tests unitaires** + **intégration** (backend Rust) + **widget tests** (Flutter) + **E2E tests** (Flutter)
- **Rationale**: Couverture complète, qualité garantie, aligné avec approche qualité
- **Libraries**: `cargo test` (Rust), `flutter test` (Flutter), `integration_test` (Flutter E2E)
- **CI/CD**: Tests inclus dans pipeline GitHub Actions
- **Note**: Tests E2E manuels pour MVP, automatiques en CI/CD pour V1.0+

**Code Quality Tools:**
- **Linting + Formatting**
- **Rationale**: Qualité garantie, code cohérent
- **Tools**:
  - Rust : `clippy` (linting) + `rustfmt` (formatting)
  - Flutter : `dart analyze` (linting) + `dart format` (formatting)
- **CI/CD**: Linting + formatting vérifiés dans pipeline

### Infrastructure & Deployment

**Hosting Strategy:**
- **Docker containers** séparés déployés sur **VPS** (Hostinger VPS KVM2 ou autre)
- **Architecture Docker**:
  - Container PostgreSQL (database)
  - Container Backend Rust (API GraphQL)
  - Nginx reverse proxy (routing + SSL)
- **Rationale**: Contrôle total, pas de coûts externes, containers isolés (sécurité), facile à déployer/migrer
- **Container Security (MVP)**:
  - Variables d'environnement pour secrets (.env)
  - Network isolation (Docker networks)
  - Health checks pour monitoring
- **Container Security (V1.0+)**:
  - Docker secrets ou vault
  - Images minimales (Alpine Linux)
  - Non-root users dans containers
  - Security scanning des images

**Frontend Build Strategy:**
- **Build mobile uniquement** (APK/IPA) pour MVP
- **Rationale**: Focus mobile, pas besoin de container Docker pour frontend MVP
- **Note**: Si web app future → container Docker Flutter web possible

**Reverse Proxy & SSL:**
- **Nginx reverse proxy** + **Let's Encrypt SSL**
- **Rationale**: Standard, SSL gratuit, bien supporté, sécurisé

**CI/CD Pipeline:**
- **GitHub Actions**
- **Rationale**: Gratuit, intégré GitHub, bien supporté pour Flutter et Rust
- **Inclusions**: Tests unitaires + intégration + widget tests, linting, formatting

**Environment Configuration:**
- **.env files** + **.gitignore strict**
- **Rationale**: Simple pour MVP, suffisant avec bonne discipline

**Monitoring & Logging:**
- **Sentry** (Flutter) + **Logging structuré backend** (Rust)
- **Rationale**: Couverture complète, Sentry gratuit pour petits projets, logging complet pour debugging
- **Libraries**: `sentry_flutter` (Flutter), `tracing` + `tracing-subscriber` (Rust)
- **Logging Strategy**: Structured logging (JSON) + stdout (Docker logs)
- **Rationale**: Intégré avec Docker, facile à collecter, format JSON parseable
- **Security Monitoring (MVP)**:
  - Logging de toutes les authentifications
  - Logging des erreurs de sécurité
- **Security Monitoring (V1.0+)**:
  - Alertes sur tentatives d'intrusion
  - Détection d'anomalies (tentatives multiples, patterns suspects)
  - Audit logs pour actions sensibles
  - Monitoring des queries GraphQL suspectes

**Database Backup Strategy:**
- **pg_dump automatique** (cron) + **backup vers storage local** (Docker volume)
- **Rationale**: Simple, efficace, protection des données, backup local dans container Docker

**Health Checks:**
- **Health checks Docker** + **endpoint `/health`**
- **Rationale**: Standard, monitoring automatique, Docker peut redémarrer containers si unhealthy

### Security Audit Findings & Enhancements

**Security Audit réalisé avec 3 personas (Hacker, Défenseur, Auditeur) :**

**Vulnérabilités identifiées et mitigations :**

**1. GraphQL Security :**
- **Risque MVP** : Introspection en production, queries complexes (DoS)
- **Mitigation MVP** : Désactiver introspection en production, query depth limiting (max 10), query complexity analysis (max 1000 points), query timeout (max 5 secondes)
- **Enhancement V1.0+** : Rate limiting par query type, monitoring des queries suspectes

**2. JWT Security :**
- **Risque MVP** : Tokens rejoués, pas de révoquation
- **Mitigation MVP** : Expiration courte (15 min access token), signature forte (HS256 ou RS256), validation stricte côté serveur
- **Enhancement V1.0+** : Refresh tokens avec rotation, blacklist pour tokens révoqués (Redis ou DB), expiration refresh token (7 jours)

**3. Rate Limiting :**
- **Risque MVP** : In-memory (vulnérable aux attaques distribuées)
- **Mitigation MVP** : Rate limiting par IP avec `tower-governor`
- **Enhancement V1.0+** : Rate limiting distribué (Redis), rate limiting par IP + user ID

**4. Container Security :**
- **Risque MVP** : Secrets dans images, containers non sécurisés
- **Mitigation MVP** : Variables d'environnement (.env) avec .gitignore strict, network isolation (Docker networks), health checks
- **Enhancement V1.0+** : Docker secrets ou vault, images minimales (Alpine Linux), non-root users, security scanning des images

**5. Data Protection :**
- **Risque MVP** : Pas de chiffrement au repos pour données sensibles
- **Mitigation MVP** : HTTPS (TLS) pour transit, bcrypt pour mots de passe
- **Enhancement V1.0+** : Chiffrement au repos (AES) pour données sensibles

**6. Security Monitoring :**
- **Risque MVP** : Pas de détection d'intrusions
- **Mitigation MVP** : Logging de toutes les authentifications, logging des erreurs de sécurité
- **Enhancement V1.0+** : Alertes sur tentatives d'intrusion, détection d'anomalies, audit logs complets, monitoring des queries GraphQL suspectes

**7. RGPD Compliance :**
- **MVP** : HTTPS (TLS), bcrypt, logging
- **V1.0+** : Chiffrement au repos (AES), consentement utilisateur explicite, droit à l'oubli, portabilité données, anonymisation données pour analytics

### Decision Impact Analysis

**Implementation Sequence:**
1. Initialisation projets (Flutter + Rust)
2. Setup Docker containers (PostgreSQL, Backend, Nginx)
3. Configuration GraphQL schema avec interfaces polymorphiques
4. Setup authentication (JWT + bcrypt)
5. Implementation services (géolocalisation, paiements, etc.)
6. Setup CI/CD (GitHub Actions)
7. Configuration monitoring (Sentry + logging)

**Cross-Component Dependencies:**
- GraphQL schema définit les types d'énigmes → affecte frontend et backend
- Authentication JWT → affecte toutes les routes API
- Docker infrastructure → affecte déploiement et scaling
- Hive offline storage → affecte synchronisation avec backend
- Riverpod state management → affecte architecture frontend complète

---

## Implementation Patterns & Consistency Rules

_Ces patterns assurent que plusieurs agents (humains ou IA) produisent du code cohérent et compatible. Conventions traditionnelles et standards par écosystème._

### Pattern Categories Defined

**Critical Conflict Points Identified:** 5 catégories (naming, structure, format, communication, process) où les agents pourraient diverger sans règles explicites.

### Naming Patterns

**Database (PostgreSQL + sqlx):**
- Tables : `snake_case` — ex. `users`, `investigations`, `enigma_responses`
- Colonnes : `snake_case` — ex. `user_id`, `created_at`, `is_completed`
- Clés étrangères : `{table}_id` — ex. `user_id`, `investigation_id`
- Index : `idx_{table}_{column}` — ex. `idx_users_email`

**GraphQL Schema:**
- Types : `PascalCase` — ex. `User`, `Investigation`, `EnigmaResponse`
- Champs : `camelCase` — ex. `userId`, `createdAt`, `isCompleted`
- Queries : `camelCase` verbe — ex. `getUser`, `listInvestigations`
- Mutations : `camelCase` verbe — ex. `createUser`, `updateInvestigation`

**Flutter (Dart):**
- Classes : `PascalCase` — ex. `User`, `InvestigationCard`
- Fichiers : `snake_case.dart` — ex. `user_repository.dart`, `investigation_card.dart`
- Variables / fonctions : `camelCase` — ex. `userId`, `getUserData()`
- Constantes : `lowerCamelCase` avec `const` — ex. `const apiBaseUrl`

**Rust:**
- Types / structs : `PascalCase` — ex. `User`, `Investigation`
- Fichiers : `snake_case.rs` — ex. `user_handler.rs`, `investigation_service.rs`
- Fonctions / variables : `snake_case` — ex. `get_user`, `user_id`
- Constantes : `SCREAMING_SNAKE_CASE` — ex. `API_BASE_URL`

### Structure Patterns

**Flutter — Organisation par feature (déjà décidée):**
- `lib/core/` — services, repositories, models partagés
- `lib/features/{feature}/` — widgets, notifiers, repositories par feature (ex. `onboarding`, `investigation`, `enigma`, `profile`)
- `lib/shared/` — widgets réutilisables, utils
- **Fichiers d'opérations GraphQL** : `lib/core/graphql/` (queries/mutations globales) ou `lib/features/{feature}/graphql/` (spécifiques à une feature) ; nom de fichier en **snake_case** reflétant l'opération (ex. `get_user.graphql`, `list_investigations.graphql`)
- Tests : `test/` miroir de `lib/` (ex. `test/features/investigation/investigation_repository_test.dart`) ; E2E dans `integration_test/`

**Rust — Organisation modulaire:**
- `src/api/` — handlers, routes (GraphQL)
- `src/services/` — logique métier (auth, geolocation, etc.)
- `src/models/` — modèles et DTOs
- `src/config/` — configuration
- `src/db/` — migrations, pool
- Tests : `#[cfg(test)]` dans les modules ou `tests/` pour intégration

**Fichiers de configuration:**
- `.env` à la racine du backend ; `.env` (ou variantes par env) pour Flutter si besoin ; jamais committés (`.gitignore` strict)

### Format Patterns

**API GraphQL:**
- Réponse : format standard GraphQL `{ data?, errors? }` ; pas de wrapper custom
- Erreurs : format GraphQL standard avec `message`, `path`, `extensions` (code, champs) si besoin
- Dates : **ISO 8601** en string (ex. `2026-01-26T12:00:00Z`) dans le schema GraphQL et en JSON
- IDs : string opaque (UUID) côté API ; pas d’entiers séquentiels exposés
- **Types** : tout type exposé dans le schema GraphQL a un **nom explicite** (pas de types anonymes ou inférés) pour garder le contrat front/back lisible

**JSON (échange frontend/backend):**
- Champs : `camelCase` dans les payloads GraphQL (convention GraphQL) ; le backend Rust sérialise en camelCase pour l’API (serde rename)
- Booléens : `true` / `false` uniquement
- Null : explicite ; pas de champs absents pour signifier null si le champ est déclaré nullable

**Logging (backend Rust):**
- Format structuré JSON (tracing-subscriber) ; niveaux : `error`, `warn`, `info`, `debug` ; pas de logs sensibles (tokens, mots de passe)

### Communication Patterns

**Riverpod (Flutter):**
- State : **immuable** ; Notifier/AsyncNotifier mettent à jour via `state = newState`
- Providers : nommage `xxxProvider` (ex. `authStateProvider`, `investigationListProvider`)
- Nom des notifiers : `XxxNotifier` / `XxxAsyncNotifier` selon synchrone/async

**GraphQL (client Flutter):**
- Nom des queries/mutations : refléter le schema (ex. `getUser`, `listInvestigations`)
- Variables : `camelCase` ; mêmes noms que dans le schema
- Gestion du cache : stratégie définie par `graphql_flutter` (cache-first par défaut ; invalidation explicite après mutations)

**Events / side-effects:**
- Pas de bus d’events global ; préférer callbacks, Riverpod (ref.invalidate), ou paramètres de route (GoRouter) pour la navigation et le rafraîchissement

### Process Patterns

**Gestion d’erreurs:**
- Backend : erreurs GraphQL avec `extensions.code` (ex. `UNAUTHENTICATED`, `NOT_FOUND`, `VALIDATION_ERROR`) ; log détaillé côté serveur ; message utilisateur court et non technique dans `message`
- Flutter : `AsyncValue` (Riverpod) pour chargement/erreur/données ; affichage message utilisateur ; log/sentry pour stack trace

**États de chargement:**
- Naming : `AsyncValue<T>` (idle / loading / data / error) ; pas de booléen `isLoading` séparé pour les données async
- UI : indicateur de chargement local par écran/widget ; pas de loader global sauf cas explicite (ex. splash)

**Validation:**
- Backend : unique source de vérité (crate `validator` + règles métier) ; messages d’erreur cohérents dans les réponses GraphQL
- Flutter : pas de validation métier côté client pour le MVP ; affichage des erreurs renvoyées par l’API

**Tests (nommage et structure):**
- Flutter : nom de fichier `{fichier_sous_test}_test.dart` (ex. `investigation_repository_test.dart`) ; Rust : `tests/{module}_integration_test.rs` ou tests dans le module avec `#[cfg(test)]`
- Pour les cas non triviaux : structure **Arrange / Act / Assert** (ou Given / When / Then) pour garder les tests lisibles et cohérents

### Enforcement Guidelines

**Tous les agents (humains ou IA) doivent :**
- Respecter les conventions de nommage par couche (DB, GraphQL, Dart, Rust)
- Placer les fichiers dans la structure par feature (Flutter) et par module (Rust) définie ci-dessus
- Utiliser les formats d’API et de données (dates ISO 8601, camelCase JSON/GraphQL, structure d’erreur GraphQL)
- Utiliser `AsyncValue` et pas de pattern ad-hoc pour le chargement/erreur côté Flutter
- Ne pas introduire de wrapper custom autour des réponses GraphQL

**Vérification des patterns :**
- Linting : `dart analyze` + `dart format` (Flutter), `clippy` + `rustfmt` (Rust) dans le pipeline CI
- Revue de code : vérifier nommage et emplacement des fichiers ; tests : nommage des fichiers de test (voir ci-dessus) et structure AAA/GWT pour les cas non triviaux
- Les violations sont documentées en commentaire ou en issue avec référence à cette section

### Pattern Examples

**Bon (Flutter):**
- Fichier : `lib/features/investigation/repositories/investigation_repository.dart`
- Provider : `final investigationListProvider = AsyncNotifierProvider<InvestigationListNotifier, AsyncValue<List<Investigation>>>`

**Bon (Rust):**
- Fichier : `src/services/investigation_service.rs`, fonction `pub async fn get_investigation_by_id(...)`
- Table : `investigations`, colonne `created_at` (timestamptz)

**À éviter :**
- Mélanger camelCase et snake_case dans la même couche (ex. champs GraphQL en snake_case)
- Fichiers Flutter en PascalCase (ex. `InvestigationCard.dart`) ou Rust en camelCase pour fonctions
- Dates en timestamp entier ou format libre dans l’API
- Loader global + booléen `isLoading` au lieu d’`AsyncValue`

---

## Project Structure & Boundaries

### Complete Project Directory Structure

**Deux projets au même niveau** (monorepo ou deux dépôts) : `city_detectives` (Flutter) et `city-detectives-api` (Rust).

**Flutter — `city_detectives/`**

```
city_detectives/
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── .env.example
├── .gitignore
├── .github/workflows/ci.yml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── config/
│   │   ├── graphql/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   └── router/
│   ├── features/
│   │   ├── onboarding/
│   │   ├── investigation/
│   │   │   ├── graphql/
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   ├── enigma/
│   │   │   ├── types/
│   │   │   │   ├── photo/
│   │   │   │   ├── geolocation/
│   │   │   │   ├── words/
│   │   │   │   ├── puzzle/
│   │   │   │   └── ... (un sous-dossier par type d'énigme, 12 au total)
│   │   │   ├── graphql/
│   │   │   ├── providers/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── profile/
│   └── shared/
│       ├── widgets/
│       └── utils/
├── test/
├── integration_test/
├── assets/
└── ios/ & android/
```

**Rust Backend — `city-detectives-api/`**

```
city-detectives-api/
├── README.md
├── Cargo.toml
├── .env.example
├── .gitignore
├── .github/workflows/ci.yml
├── src/
│   ├── main.rs
│   ├── api/
│   │   ├── graphql/
│   │   │   ├── schema.rs
│   │   │   ├── queries.rs
│   │   │   └── mutations.rs
│   │   ├── handlers/
│   │   └── middleware/
│   ├── services/
│   │   ├── auth_service.rs
│   │   ├── investigation_service.rs
│   │   ├── enigma_service.rs
│   │   ├── geolocation_service.rs
│   │   └── payment_service.rs
│   ├── models/
│   ├── config/
│   └── db/
│       ├── pool.rs
│       └── migrations/
├── tests/
│   ├── api/
│   │   ├── auth_test.rs
│   │   ├── investigations_test.rs
│   │   └── enigmas_test.rs
│   └── ...
└── migrations/
```

**Infrastructure (optionnel à la racine du monorepo)** : `docker/` (Dockerfile.api, Dockerfile.nginx, docker-compose.yml).

### Architectural Boundaries

**API Boundaries**
- Externe : endpoint GraphQL unique (`POST /graphql`), `GET /health` ; Nginx reverse proxy + SSL.
- Auth : JWT dans `Authorization: Bearer <token>` ; middleware Axum avant resolvers GraphQL.
- Données : resolvers → services → db ; pas d'accès DB direct depuis les handlers.

**Schema GraphQL canonique**
- **Source de vérité** : backend Rust (`city-detectives-api`), ex. `src/api/graphql/schema.rs` (ou fichier `.graphql` dédié). Le client Flutter s'y conforme ; les fichiers `.graphql` dans `lib/core/graphql/` et `lib/features/*/graphql/` reflètent ce schéma.

**Frontend Boundaries**
- Navigation : GoRouter ; pas de `Navigator.push` direct pour les écrans principaux.
- État : Riverpod (Notifier/AsyncNotifier) ; pas de bus d'events global.
- Données : repositories → GraphQL client ou Hive ; cache Hive pour offline.

**Service Boundaries**
- Backend : `api/` → `services/` → `db/` + `models/` ; pas de logique métier dans les handlers.
- Flutter : screens/widgets → providers → repositories → services ou GraphQL.

**Data Boundaries**
- PostgreSQL : schéma unique ; migrations sqlx dans `db/migrations`.
- Hive : boxes par domaine ; TypeAdapters dans core/features ; sync via repositories.
- Cache : moka in-memory dans les services backend.

### Requirements to Structure Mapping

**Par catégorie fonctionnelle**
- Onboarding & Account → `lib/features/onboarding/`, `lib/core/services/auth_service.dart`, `lib/core/repositories/user_repository.dart` ; backend `src/services/auth_service.rs`, `src/api/graphql/`.
- Enquête Discovery & Selection / Gameplay → `lib/features/investigation/`, `lib/core/graphql/` ou `lib/features/investigation/graphql/` ; backend `src/services/investigation_service.rs`, `src/api/graphql/queries.rs`.
- **Énigme Resolution & Validation** : `lib/features/enigma/` avec **un sous-dossier par type d'énigme** sous `lib/features/enigma/types/` (ex. `photo/`, `geolocation/`, `words/`, `puzzle/`, etc. — liste des 12 types alignée avec le schéma GraphQL). Backend : `src/services/enigma_service.rs` et modules par type si besoin (`src/services/enigma/`).
- Content & LORE, Progression → `lib/core/models/`, `lib/features/investigation/` et `lib/features/enigma/` ; backend `src/models/`, `src/services/`.
- Monetization → `lib/core/services/payment_service.dart` ; backend `src/services/payment_service.rs`.
- Push Notifications → `lib/core/services/push_service.dart` ; backend enregistrement des tokens.
- Admin, User Feedback → backend `src/api/`, `src/services/` ; frontend feature dédiée ou outil externe.

**Cross-cutting**
- Auth : `lib/core/services/auth_service.dart`, `lib/core/repositories/user_repository.dart`, `lib/core/router/` ; backend `src/api/middleware/auth.rs`, `src/services/auth_service.rs`.
- Géolocalisation : `lib/core/services/geolocation_service.dart` ; backend `src/services/geolocation_service.rs`.
- Offline / sync : `lib/core/repositories/`, Hive + TypeAdapters.

### Integration Points

**Internal**
- Flutter : providers → repositories → GraphQL client ou Hive ; `ref.invalidate` après mutations.
- Backend : route GraphQL → middleware (auth, rate limit) → resolvers → services → db.
- Données : schéma GraphQL partagé (types nommés, camelCase) ; Flutter conforme au schéma backend.

**External**
- Firebase : push (FCM) côté Flutter uniquement.
- Stores : In-App Purchase / Google Play Billing côté Flutter ; validation serveur backend.
- Maps / géoloc : packages Flutter ; backend validation des coordonnées si besoin.

**Data flow**
- Lecture : App → GraphQL query (ou Hive si offline) → API → services → DB.
- Écriture : App → GraphQL mutation → API → services → DB ; invalidation Riverpod + mise à jour Hive.
- Auth : login → mutation → JWT → `flutter_secure_storage` → header sur chaque requête GraphQL.

### File Organization Patterns

**Configuration** : Flutter `.env.example` à la racine, config dans `lib/core/config/` ; Backend `.env` à la racine de `city-detectives-api/`, `src/config/settings.rs`.

**Source** : Flutter par feature sous `lib/features/{feature}/` ; Backend `src/api/`, `src/services/`, `src/models/`, `src/config/`, `src/db/`.

**Tests**
- Flutter : `test/` miroir de `lib/` ; `integration_test/` pour E2E ; nommage `*_test.dart`, structure AAA/GWT.
- Backend : `#[cfg(test)]` dans les modules ; **tests d'intégration API/GraphQL** dans `tests/api/` avec un fichier par domaine : `auth_test.rs`, `investigations_test.rs`, `enigmas_test.rs`.

**Assets** : Flutter `assets/images/` ; référencés dans `pubspec.yaml`.

### Development Workflow Integration

**Dev** : Flutter `flutter run` ; Backend `cargo run` ; option `docker-compose up` pour PostgreSQL + API.

**Build** : Flutter `flutter build apk` / `flutter build ios` ; Backend `cargo build --release` ; CI dans `.github/workflows/` pour les deux projets.

**Deploy** : Backend image Docker + Nginx ; Flutter livraison binaires (stores).

---

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:** Toutes les décisions techniques sont compatibles (Flutter, Rust/Axum, PostgreSQL/sqlx, GraphQL, Riverpod, GoRouter, Hive, JWT, Docker/VPS). Versions documentées, pas de conflit identifié.

**Pattern Consistency:** Les patterns d'implémentation (naming, structure, format, communication, process) sont alignés avec la stack et les décisions. Conventions cohérentes par couche.

**Structure Alignment:** L'arborescence projet (city_detectives/ + city-detectives-api/ + docker/) supporte les décisions, les frontières et les points d'intégration sont définis.

### Requirements Coverage Validation ✅

**Epic/Feature Coverage:** Les 12 catégories de FR sont mappées vers des dossiers et services (onboarding, investigation, enigma/types/, profile, core, admin, feedback). Social & Group reporté en V1.0+.

**Functional Requirements Coverage:** Chaque catégorie FR a un support architectural explicite (structure, services, API, repositories). Énigmes : un sous-dossier par type sous lib/features/enigma/types/.

**Non-Functional Requirements Coverage:** Performance (Rust, cache, Hive), offline (Hive, sync), stabilité (Sentry, health checks), sécurité (JWT, audit, mitigations MVP+V1.0+), scalabilité (Docker/VPS, Redis V1.0+), accessibilité (NFR citée ; patterns UI à appliquer en implémentation).

### Implementation Readiness Validation ✅

**Decision Completeness:** Décisions critiques documentées avec versions ; patterns et règles de cohérence définis ; exemples et anti-patterns fournis.

**Structure Completeness:** Arborescence complète Flutter et Rust ; tests/api/ pour intégration GraphQL ; boundaries et mapping FR → structure documentés.

**Pattern Completeness:** Conflits potentiels (naming, structure, format, communication, process) adressés ; erreurs, chargement (AsyncValue), tests (AAA/GWT) spécifiés.

### Gap Analysis Results

**Critical Gaps:** Aucun.

**Important Gaps (non bloquants):**
- Liste des 12 types d'énigmes à figer lors de la définition du schéma GraphQL et de lib/features/enigma/types/.
- Accessibilité WCAG 2.1 Level A : NFR présente ; patterns UI (contraste, focus, screen readers) à intégrer en implémentation (design system / shared widgets).

**Nice-to-Have:** Liste exhaustive des 12 types dans l'architecture ou le PRD ; rappel accessibilité dans les guidelines d'implémentation.

### Validation Issues Addressed

Aucun point bloquant. Les écarts importants sont documentés ci-dessus pour traitement en phase d'implémentation.

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Contexte projet analysé
- [x] Échelle et complexité évaluées
- [x] Contraintes techniques identifiées
- [x] Préoccupations transversales mappées

**✅ Architectural Decisions**
- [x] Décisions critiques documentées avec versions
- [x] Stack technique spécifiée
- [x] Patterns d'intégration définis
- [x] Considérations performance et sécurité adressées

**✅ Implementation Patterns**
- [x] Conventions de nommage établies
- [x] Patterns de structure définis
- [x] Patterns de communication spécifiés
- [x] Patterns de processus documentés (erreurs, chargement, tests)

**✅ Project Structure**
- [x] Arborescence définie (Flutter + Rust + docker)
- [x] Frontières composants établies
- [x] Points d'intégration mappés
- [x] Mapping exigences → structure complété

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** Élevé — cohérence, couverture et complétude validées ; écarts restants non bloquants et traitables en implémentation.

**Key Strengths:**
- Stack cohérente et décisions documentées avec versions
- Patterns et structure détaillés, adaptés à une implémentation multi-agents
- Sécurité et NFR pris en compte (MVP + V1.0+)
- Schéma GraphQL canonique et frontières claires

**Areas for Future Enhancement:**
- Figer la liste des 12 types d'énigmes (schéma + dossiers)
- Renforcer les patterns d'accessibilité (WCAG) dans le design system
- Inclure les critères d'accessibilité (WCAG 2.1 Level A : contraste, focus, tailles tactiles, screen readers) dans les critères d'acceptation des écrans clés et dans le design system

### Implementation Handoff

**AI Agent Guidelines:**
- Suivre les décisions et patterns du présent document
- Respecter la structure projet et les frontières (API, services, repositories)
- Utiliser les conventions de nommage et les formats (GraphQL, JSON, AsyncValue)
- Consulter ce document pour toute question d'architecture
- **Référence pour les stories :** utiliser ce document (architecture.md) comme référence dans les stories et le project-context ; les critères d'acceptation ne doivent pas contredire l'architecture

**Quality Gates:**
- Avant merge : `dart analyze` + `flutter test` verts (Flutter) ; `cargo test` + `clippy` verts (Rust)
- Backend : au moins un test d'intégration API par domaine (auth, investigations, enigmas) pour considérer le domaine implémenté

**First Implementation Priority:**
1. Initialiser les projets : `flutter create city_detectives --org com.citydetectives` et `cargo new city-detectives-api --bin`
2. Structurer les dossiers selon Project Structure & Boundaries
3. Mettre en place Docker (PostgreSQL, backend, Nginx) et CI (GitHub Actions)

---

## Architecture Completion Summary

### Workflow Completion

**Architecture Decision Workflow:** COMPLETED ✅  
**Total Steps Completed:** 8  
**Date Completed:** 2026-01-26  
**Document Location:** _bmad-output/planning-artifacts/architecture.md

### Final Architecture Deliverables

**📋 Complete Architecture Document**
- All architectural decisions documented with specific versions
- Implementation patterns ensuring AI agent consistency
- Complete project structure with all files and directories
- Requirements to architecture mapping
- Validation confirming coherence and completeness

**🏗️ Implementation Ready Foundation**
- Critical decisions: Backend Rust+Axum, PostgreSQL+sqlx, GraphQL, Flutter, Riverpod, GoRouter, Hive, JWT, Docker/VPS
- Implementation patterns: naming, structure, format, communication, process (errors, loading, tests)
- Project structure: city_detectives/ (Flutter) + city-detectives-api/ (Rust) + docker/
- 12 FR categories mapped to structure ; NFRs addressed (performance, offline, security, scalability, accessibilité)

**📚 AI Agent Implementation Guide**
- Technology stack with verified versions
- Consistency rules and quality gates (dart analyze, flutter test, cargo test, clippy)
- Project structure with clear boundaries
- Reference architecture.md in stories and project-context ; AC must not contradict architecture

### Implementation Handoff

**For AI Agents:** This architecture document is the complete guide for implementing city-detectives. Follow all decisions, patterns, and structures exactly as documented.

**First Implementation Priority:**
1. `flutter create city_detectives --org com.citydetectives`
2. `cargo new city-detectives-api --bin`
3. Structure directories per Project Structure & Boundaries
4. Set up Docker (PostgreSQL, backend, Nginx) and CI (GitHub Actions)

**Development Sequence:**
1. Initialize projects using commands above
2. Set up development environment per architecture
3. Implement core foundations (auth, GraphQL schema, repositories)
4. Build features following established patterns
5. Maintain consistency with documented rules and quality gates

### Quality Assurance Checklist

**✅ Architecture Coherence**
- [x] All decisions work together without conflicts
- [x] Technology choices are compatible
- [x] Patterns support the architectural decisions
- [x] Structure aligns with all choices

**✅ Requirements Coverage**
- [x] All functional requirements are supported
- [x] All non-functional requirements are addressed
- [x] Cross-cutting concerns are handled
- [x] Integration points are defined

**✅ Implementation Readiness**
- [x] Decisions are specific and actionable
- [x] Patterns prevent agent conflicts
- [x] Structure is complete and unambiguous
- [x] Examples and quality gates are provided

### Project Success Factors

**🎯 Clear Decision Framework** — Every technology choice was made collaboratively with clear rationale.

**🔧 Consistency Guarantee** — Implementation patterns and quality gates ensure compatible, consistent code across agents.

**📋 Complete Coverage** — All project requirements are architecturally supported, with clear mapping to implementation.

**🏗️ Solid Foundation** — Flutter + Rust stack, GraphQL, offline-first, and security mitigations provide a production-ready base.

---

**Architecture Status:** READY FOR IMPLEMENTATION ✅

**Next Phase:** Begin implementation using the architectural decisions and patterns documented herein.

**Document Maintenance:** Update this architecture when major technical decisions are made during implementation.
