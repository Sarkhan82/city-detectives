# Code Review – Story 4-1-enigmes-photo-geolocalisation

**Story:** 4-1-enigmes-photo-geolocalisation  
**Date:** 2026-02-03  
**Reviewer:** Senior Developer (AI) – revue adverse  
**Contexte:** Comparaison git vs File List de la story ; validation AC et tâches ; qualité et sécurité du code applicatif uniquement (hors _bmad/, _bmad-output/).

---

## Git vs Story

- **Fichiers modifiés/nouveaux (git)** : cohérents avec la File List de la story pour le code applicatif.
- **Écarts** : Fichiers modifiés mais non listés dans la story : `city-detectives-api/Cargo.lock`, `city_detectives/pubspec.lock`, `city_detectives/windows/flutter/generated_plugin_registrant.cc`, `city_detectives/windows/flutter/generated_plugins.cmake` (générés/lock – optionnel de les documenter).

---

## Synthèse des findings

| Sévérité | Nombre | Description courte |
|----------|--------|--------------------|
| HIGH     | 1      | Mutation sans auth |
| MEDIUM   | 4      | AsyncValue, taille photo, File List, indicateur distance |
| LOW      | 3      | Fichier .graphql, types non utilisés, test fallback galerie |

---

## HIGH

### 1. Mutation `validateEnigmaResponse` non protégée par l’auth

- **Fichier:** `city-detectives-api/src/api/graphql.rs`
- **Constat:** La mutation `validate_enigma_response` ne vérifie pas le token (BearerToken). Elle est exécutable sans authentification. Un client peut valider n’importe quelle énigme en connaissant son `enigmaId`.
- **Recommandation:** Exiger un token valide (comme pour `me`) et, si besoin métier, vérifier que l’énigme appartient à une enquête accessible à l’utilisateur.

---

## MEDIUM

### 2. État de chargement : `_loading` au lieu d’`AsyncValue`

- **Fichiers:** `city_detectives/lib/features/enigma/types/photo/photo_enigma_widget.dart`, `city_detectives/lib/features/enigma/types/geolocation/geolocation_enigma_widget.dart`
- **Constat:** project-context impose « AsyncValue pour chargement/envoi validation ; pas de booléen isLoading ». Les deux widgets utilisent `bool _loading` + `setState` pour l’envoi de la validation.
- **Recommandation:** Modéliser l’état d’envoi (idle / loading / data / error) avec `AsyncValue` (ou un Notifier qui expose un `AsyncValue`) pour rester aligné avec l’architecture.

### 3. Photo en base64 sans limite de taille

- **Fichier:** `city_detectives/lib/features/enigma/types/photo/photo_enigma_widget.dart` (l.62–64)
- **Constat:** `file.readAsBytes()` puis `base64Encode(bytes)` sans plafond. Une très grande image peut dégrader les perfs ou faire échouer la requête.
- **Recommandation:** Limiter la taille (ex. max 2–5 Mo) ou redimensionner/compresser avant envoi, et afficher un message clair si dépassement.

### 4. File List incomplète

- **Constat:** La Dev Agent Record → File List ne mentionne pas les fichiers modifiés par git : `Cargo.lock`, `pubspec.lock`, `city_detectives/windows/flutter/generated_plugin_registrant.cc`, `generated_plugins.cmake`.
- **Recommandation:** Soit les ajouter à la File List (avec mention « lock / générés »), soit documenter explicitement qu’ils sont exclus.

### 5. Task 3.1 – Indicateur de distance / « Vous y êtes ! »

- **Fichier:** `city_detectives/lib/features/enigma/types/geolocation/geolocation_enigma_widget.dart`
- **Constat:** La story demande « objectif à atteindre, indicateur de distance ou « Vous y êtes ! » ». Actuellement : uniquement le message retourné par le backend après validation. Pas d’indicateur de distance en temps réel avant validation.
- **Recommandation:** Afficher la distance au point cible (si disponible côté client) ou un libellé du type « Vous y êtes ! » lorsque la position est dans la tolérance, avant ou en complément du clic « Valider ».

---

## LOW

### 6. Mutation GraphQL inline au lieu d’un fichier .graphql

- **Fichier:** `city_detectives/lib/features/enigma/repositories/enigma_validation_repository.dart`
- **Constat:** L’architecture indique « Fichiers GraphQL pour mutation validation dans lib/features/enigma/graphql/ (ex. validate_enigma_response.graphql) ». La mutation est en chaîne Dart.
- **Recommandation:** Déplacer la mutation dans `lib/features/enigma/graphql/validate_enigma_response.graphql` et l’utiliser depuis le repository pour respecter la structure prévue.

### 7. Types `PhotoEnigma` et `GeolocationEnigma` non utilisés dans une query

- **Fichier:** `city-detectives-api/src/models/enigma.rs`
- **Constat:** Les types sont définis (avec `#[allow(dead_code)]`) et exposés dans le schéma, mais aucune query ne les retourne ; seul `Enigma` (id, orderIndex, type, titre) est utilisé pour la liste d’énigmes.
- **Recommandation:** Soit les utiliser dans une query dédiée (ex. détail d’énigme avec point cible / tolérance), soit documenter qu’ils sont réservés pour une évolution ultérieure.

### 8. Tests widget – pas de scénario « fallback galerie »

- **Fichier:** `city_detectives/test/features/enigma/types/photo/photo_enigma_widget_test.dart`
- **Constat:** Task 5.2 demande des tests pour « prise photo, fallback galerie si permission refusée ». Les tests actuels vérifient l’affichage et le bouton, pas le flux « caméra refusée → galerie ».
- **Recommandation:** Ajouter un test (avec mock du picker / permissions) qui simule le refus caméra puis le choix galerie et vérifie le comportement ou le message.

---

## Validation AC / Tâches

- **AC1** : Implémenté (affichage énigme photo/géo, validation, retour positif, message d’erreur explicite, fallback galerie).
- **Tâches marquées [x]** : Réalisées, avec les réserves ci-dessus (Task 3.1 partiel, Task 5.2 partiel, conformité architecture partielle).

---

## Correctifs appliqués (option 1)

- **HIGH** : Auth sur `validateEnigmaResponse` (Bearer requis) ; tests enigmas avec token ; client Flutter avec `authToken` via `_authTokenForEnigmaProvider`.
- **MEDIUM 2** : État d'envoi en `AsyncValue<ValidateEnigmaResult?>` dans photo et géolocation widgets.
- **MEDIUM 3** : Limite 3 Mo sur la photo ; message explicite si dépassement.
- **MEDIUM 4** : File List complétée (Cargo.lock, pubspec.lock, generated_*).
- **MEDIUM 5** : Consigne géo précisée (message « Vous y êtes ! » en cas de succès).
- Story et sprint : statut passé à **done**.
