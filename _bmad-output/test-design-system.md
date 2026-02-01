# Test Design – Niveau système (Phase 3)

**Date :** 2026-01-26  
**Projet :** city-detectives  
**Auteur :** BMAD workflow (test-design optionnel)  
**Statut :** Brouillon

---

## Contexte

Revue de testabilité au niveau système (Phase 3 – Solutioning) : architecture, PRD, epics. Ce document alimente la stratégie de tests (framework, CI, plans par epic) et le gate implementation-readiness.

**Sources :** architecture.md, prd.md, epics.md, ux-design-specification.md.

---

## Testability Assessment

### Controllability

**PASS** (avec précisions)

- **État système pour les tests :** Backend Rust + GraphQL permet du seeding (données de test) et des mutations contrôlées. Flutter : Riverpod + repositories permettent d’injecter des mocks (repositories, services) pour tests unitaires/widgets sans backend.
- **Dépendances externes :** APIs GraphQL mockables (clients GraphQL injectables). GPS, caméra, stockage : abstractions (services) mockables en tests. Firebase/APNs : mockables ou désactivables en env de test.
- **Déclencher des erreurs :** Gestion d’erreurs documentée (architecture, project-context) ; scénarios erreur réseau, permission refusée, GPS imprécis testables via mocks.

**Points d’attention :** Géolocalisation <10 m et mode offline (Hive, sync) nécessitent des tests sur device/émulateur avec données contrôlées (coordonnées injectées ou fixtures) pour éviter la non-déterminisme.

### Observability

**PASS**

- **État et comportement :** Logging côté backend (Rust) ; Sentry prévu pour monitoring. Flutter : possibilité de logs / analytics en dev/test. Métriques techniques (crash, perfs) prévues (NFR).
- **Déterminisme des tests :** Avec mocks (GPS, réseau, repositories), les tests UI et logique peuvent être déterministes. E2E sur device : prévoir des timeouts et des conditions stables (éviter attentes floues).
- **Validation des NFR :** Performance (temps de réponse, chargement cache), stabilité (crash rate), sécurité (auth, RGPD) peuvent être couverts par tests automatisés + monitoring (Sentry, métriques).

### Reliability

**PASS** (avec précisions)

- **Isolation des tests :** Tests unitaires (Dart/Rust) isolés par construction. Tests d’intégration API (Rust) avec base de test ou transactions rollback. E2E : un environnement de test dédié (backend + app) évite les interférences.
- **Reproductibilité des échecs :** Données de test versionnées (fixtures, seed). Pas de dépendance à l’heure ou à l’état global non contrôlé dans les scénarios critiques.
- **Couplage :** Architecture par features + repositories + services permet des frontières testables (mocks, contrats API/GraphQL).

**Points d’attention :** Tests E2E mobiles (Flutter driver / integration_test ou outil type Maestro) : gestion des timeouts GPS et réseau pour éviter flakiness.

---

## Architecturally Significant Requirements (ASRs)

Exigences qualité qui impactent l’architecture et la testabilité, dérivées du PRD et de l’architecture.

| ASR | Source | Impact testabilité | Risque (P×I) |
|-----|--------|--------------------|--------------|
| Réponse <2 s (95e percentile) | NFR | Tests de performance (API, chargement écrans) ; seuils dans CI | Moyen |
| Chargement enquête depuis cache <2 s | NFR | Tests de performance + intégration Hive/Repository | Moyen |
| Précision GPS <10 m | NFR | Tests avec coordonnées injectées + tests device/émulateur | Moyen |
| Enquête 1h–1h30 sur une charge | NFR | Métriques batterie ; tests manuels ou scénarios ciblés | Faible |
| Taux de crash <0,5 % | NFR | Monitoring Sentry ; tests de stabilité (smoke, parcours critiques) | Moyen |
| Offline >95 % opérations, sync >98 % | NFR | Tests offline (Hive, sync) et reprise réseau | Élevé |
| RGPD, auth sécurisée | NFR | Tests auth (JWT, bcrypt), scénarios consentement/suppression données | Moyen |
| WCAG 2.1 Level A | NFR | Tests d’accessibilité (outils + manuels) | Moyen |

---

## Test Levels Strategy

Recommandation pour une app mobile (Flutter) + backend API (Rust), avec forte logique métier et contraintes device (GPS, offline).

| Niveau | Part cible | Rationale |
|--------|------------|-----------|
| **Unit** | ~60 % | Logique métier (validation énigmes, règles, repositories, services) en Dart et Rust ; rapide, stable, peu de flakiness. |
| **Integration** | ~25 % | API GraphQL (Rust), repositories + Hive, services (géoloc, auth) avec mocks partiels ; valider contrats et flux critiques. |
| **E2E** | ~15 % | Parcours critiques (onboarding, démarrage enquête, une énigme, sauvegarde/reprise) sur émulateur/device ; Flutter integration_test ou Maestro. |

**Environnements :**  
- Local : tests unitaires + intégration API (Rust, DB de test).  
- CI : mêmes tests + E2E sur émulateur Android (et iOS si disponible).  
- Staging (optionnel) : E2E + tests de charge légers (k6 ou équivalent) sur API.

---

## NFR Testing Approach

- **Sécurité :** Tests d’auth (login, token, refresh), champs protégés (GraphQL), pas de fuite de données sensibles dans les réponses. RGPD : scénarios export/suppression compte. Outils : tests API + manuels/checklist.
- **Performance :** Temps de réponse API (GraphQL) et chargement écrans (Flutter) sous seuils ; chargement enquête depuis cache <2 s. Backend : tests de charge (k6) en CI ou staging. App : métriques + Sentry.
- **Fiabilité :** Gestion d’erreurs (réseau, GPS, permissions) via tests unitaires et intégration ; smoke E2E sur parcours critiques ; monitoring crash (Sentry).
- **Maintenabilité :** Couverture minimale sur code critique (repositories, services, résolution d’énigmes) ; quality gates en CI (lint, tests, couverture).

---

## Test Environment Requirements

- **Backend :** PostgreSQL de test (Docker en CI), migrations + seed pour données reproductibles. Pas de dépendance à des services externes réels (Firebase mock ou stub).
- **App :** Émulateur Android (CI) ; iOS si possible. Géolocalisation : coordonnées mock ou mock du service de position.
- **Réseau :** Mode offline simulable (mock réseau ou proxy) pour tests sync et reprise.

---

## Testability Concerns (si applicable)

- **Géolocalisation en E2E :** Comportement variable selon device/émulateur ; privilégier des tests avec position injectée et un nombre limité de E2E “vrais” GPS sur device.
- **Sync offline :** Scénarios de conflit (dernière écriture gagne) et de reprise après coupure à couvrir explicitement (tests d’intégration + un E2E ciblé).
- **Paiements (MVP simulé) :** Vérifier que les parcours “achat” sont testables sans appel réel aux stores (mocks in-app purchase).

Aucun point bloquant identifié pour une stratégie de tests réaliste (unit + intégration + E2E ciblés).

---

## Recommendations for Sprint 0 / Prochaines étapes

1. **Framework (Phase 3/4) :** Mettre en place tests unitaires Dart (test/) et Rust (cargo test), tests d’intégration API Rust (tests/api/), et structure Flutter integration_test pour un parcours E2E minimal (ex. onboarding → liste enquêtes).
2. **CI :** Pipeline (ex. GitHub Actions) : lint, unit + intégration, build app ; job E2E sur émulateur Android (optionnel en PR, obligatoire sur main).
3. **Données de test :** Fixtures GraphQL (enquêtes, énigmes) et seed DB partagés entre intégration et E2E.
4. **Par epic :** Utiliser ce document comme entrée pour les plans de test par epic (test-design-epic-N.md) en Phase 4 si besoin (risques, P0/P1, niveaux de test par story).

---

*Document produit dans le cadre du workflow test-design (optionnel) Phase 3 – Solutioning.*
