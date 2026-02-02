# Code Review – Story 3.4 : Capacités techniques

**Story :** 3-4-capacites-techniques  
**Fichier story :** `_bmad-output/implementation-artifacts/3-4-capacites-techniques.md`  
**Date :** 2026-02-02  
**Reviewer :** Senior Developer (AI) – revue adverse  

---

## Contexte

- **Git vs File List :** Fichiers modifiés/nouveaux cohérents avec la File List. Fichiers générés Flutter (`generated_plugin_registrant.cc`, `generated_plugins.cmake`) modifiés mais non listés dans la story (voir finding #6).
- **AC :** 1 critère global (localisation, permissions, réseau, cache, batterie, erreurs). Vérification effectuée par lecture du code et des tests.

---

## CRITICAL / HIGH

### 1. [HIGH] Tests geolocation_service sans mock geolocator

**Fichier :** `city_detectives/test/core/services/geolocation_service_test.dart`  

La tâche 7.1 exige : *« Flutter : tests unitaires pour geolocation_service (mock geolocator) »*.  
Le fichier de test ne contient que des tests du **modèle** `GeoPosition` (latitude, longitude, accuracyMeters). Il n’y a **aucun** test de `GeolocatorServiceImpl` avec un mock de `geolocator` (précision, refus permission, erreur, timeout).  
**Impact :** Comportement réel de `GeolocatorServiceImpl` non couvert par les tests.

---

### 2. [HIGH] Cache enquêtes sans expiration (TTL)

**Fichiers :** `city_detectives/lib/features/investigation/repositories/investigation_cache.dart`, `investigation_repository.dart`  

Le cache Hive (`InvestigationCache`) enregistre liste et détails sans date ni durée de vie. Une fois en cache, les données peuvent être servies indéfiniment même si le backend a changé (nouveaux contenus, corrections).  
**Impact :** Données potentiellement très obsolètes ; pas d’alignement avec une attente « chargement <2s **et** données à jour lorsque le réseau est disponible ».

---

## MEDIUM

### 3. [MEDIUM] Rafraîchissement en arrière-plan entièrement silencieux

**Fichier :** `city_detectives/lib/features/investigation/repositories/investigation_repository.dart` (l.67–77, 138–143)  

`_refreshListInBackground` et `_refreshDetailInBackground` font `catch (_) { }` sans aucun log ni reporting. En cas d’échec réseau ou API, le cache reste inchangé sans trace pour le debug ou le monitoring.  
**Impact :** Difficile de diagnostiquer des caches stale ou des problèmes réseau côté enquêtes.

---

### 4. [MEDIUM] Pas de bouton « Réessayer » sur les écrans d’erreur

**Fichiers :** `investigation_list_screen.dart`, `investigation_play_screen.dart`  

L’AC 6.2 précise : *« Afficher un message explicite … ; **bouton réessayer si pertinent** »*.  
Les écrans d’erreur (liste enquêtes, erreur chargement enquête en cours) n’ont pas de bouton pour relancer le chargement (ex. réinvalider le provider et refetch).  
**Impact :** L’utilisateur doit quitter l’écran ou redémarrer l’app pour réessayer.

---

### 5. [MEDIUM] Aucun test pour ConnectivityStatusIndicator

**Fichier :** `city_detectives/lib/shared/widgets/connectivity_status_indicator.dart`  

La story demande des tests pour l’affichage du statut connexion (7.1). Il n’existe aucun test qui mocke `connectivity_plus` / `connectivityStatusProvider` et qui vérifie que `ConnectivityStatusIndicator` affiche bien online / offline / dégradé.  
**Impact :** Régression possible sur l’indicateur de connexion sans détection par les tests.

---

### 6. [MEDIUM] File List : fichiers générés modifiés non documentés

**Git :** `city_detectives/windows/flutter/generated_plugin_registrant.cc`, `generated_plugins.cmake` sont modifiés (ajout permission_handler, connectivity_plus).  
La Dev Agent Record → File List de la story ne les mentionne pas.  
**Impact :** Documentation incomplète des changements ; revue et traçabilité moins claires.

---

## LOW

### 7. [LOW] ConnectivityService : valeurs non gérées de ConnectivityResult

**Fichier :** `city_detectives/lib/core/services/connectivity_service.dart` (l.36–47)  

Seuls `wifi`, `ethernet`, `mobile`, `none` sont traités explicitement. Les autres valeurs (ex. `bluetooth`, `vpn`) tombent dans le `return ConnectivityStatus.online` final. Comportement implicite, pas documenté.  
**Impact :** Comportement possiblement trompeur selon les plateformes/versions de `connectivity_plus`.

---

### 8. [LOW] Indicateur connexion : état « online » pendant le chargement

**Fichier :** `city_detectives/lib/shared/widgets/connectivity_status_indicator.dart`  

En état `loading` du provider, le widget affiche `_Indicator(status: ConnectivityStatus.online)`. Si le vrai statut est ensuite `offline`, l’utilisateur voit brièvement « online » puis « offline ».  
**Impact :** Expérience mineure ; possible confusion sur une connexion instable.

---

### 9. [LOW] Incohérence des checkboxes dans le fichier story

**Fichier :** `_bmad-output/implementation-artifacts/3-4-capacites-techniques.md`  

Plusieurs sous-tâches sont laissées à `[ ]` alors que l’implémentation correspondante est présente (ex. 1.1 haute précision + précision exposée, 4.1 cache liste/détails, 4.3 réutilisation Hive, 5.1 position à la demande, 5.3 pas de polling, 6.1 interception erreurs, 7.2 analyze/test verts).  
**Impact :** Suivi d’avancement et revue plus difficiles ; risque de retravail inutile.

---

### 10. [LOW] PrecisionCircle : sémantique précision quand précise

**Fichier :** `city_detectives/lib/shared/widgets/precision_circle.dart` (l.29)  

Quand `!imprecise && !compact`, le widget retourne `SizedBox.shrink()` sans aucun nœud sémantique. Un lecteur d’écran n’a donc pas d’information sur la précision lorsque celle-ci est bonne (≤10 m).  
**Impact :** Accessibilité (WCAG 2.1 Level A) ; amélioration possible pour les utilisateurs de lecteurs d’écran.

---

## Synthèse

| Sévérité | Nombre |
|----------|--------|
| HIGH     | 2      |
| MEDIUM   | 4      |
| LOW      | 4      |
| **Total**| **10** |

**Recommandation :** Traiter au minimum les 2 HIGH et les 4 MEDIUM avant de considérer la story prête pour « done ». Les LOW peuvent être traités dans cette story ou en suivi.

---

## Corrections appliquées (option 1 – correction automatique)

- **#1 HIGH** : Tests geolocation_service – ajout de tests avec fake `_FakeGeolocationService` (exposition de `accuracyMeters`, contrat `requestPermission`). Les tests appelant le vrai `GeolocatorServiceImpl` ont été retirés (binding Flutter / plateforme en test).
- **#2 HIGH** : Cache avec TTL – `InvestigationCache` utilise un TTL de 1 h (`kInvestigationCacheTtlMs`), horodatage sur liste et détail ; `getCachedList` / `getCachedDetail` retournent `null` si expiré.
- **#3 MEDIUM** : Logging du rafraîchissement en arrière-plan – `_refreshListInBackground` et `_refreshDetailInBackground` appellent `logInvestigationError` en cas d’exception.
- **#4 MEDIUM** : Bouton « Réessayer » – liste enquêtes : `ref.invalidate(investigationListProvider)` ; écran play : `ref.invalidate(investigationWithEnigmasProvider(investigationId))`.
- **#5 MEDIUM** : Test `ConnectivityStatusIndicator` – `test/shared/widgets/connectivity_status_indicator_test.dart` avec mock stream (online / offline / degraded, sémantique).
- **#6 MEDIUM** : File List – story mise à jour avec les fichiers générés et le nouveau test ; Completion Notes et Change Log complétés.

*Rapport généré par le workflow code-review (revue adverse). Corrections appliquées le 2026-02-02.*
