# Code Review – Story 1.2 : Création de compte

**Story :** 1-2-creation-de-compte  
**Fichier story :** `_bmad-output/implementation-artifacts/1-2-creation-de-compte.md`  
**Date :** 2026-02-02  
**Revue :** Adversariale (Senior Developer) – troisième pass

---

## Contexte

La story a déjà fait l’objet de deux revues (2026-01-26) avec de nombreux correctifs appliqués. Cette revue vérifie l’état actuel du code et cherche d’éventuels problèmes restants ou régressions.

**Git vs Story :** Les changements non commités actuels concernent la story 3.3 (pause/reprise). Les fichiers de la story 1.2 sont supposés déjà intégrés. Aucune divergence Git/File List analysée pour ce pass (hors scope des modifs 3.3).

---

## Synthèse des problèmes

| Sévérité | Nombre | Description |
|----------|--------|-------------|
| MEDIUM   | 1      | Pas de test widget pour l’affichage d’une erreur API (ex. email dupliqué) |
| LOW      | 4      | Accessibilité bouton Retour ; getter _userRepo ; ordre des champs dans les tests ; doc cargo test local |

**Total : 5 problèmes identifiés.**

---

## MEDIUM

### 1. [MEDIUM] Aucun test widget pour l’affichage d’une erreur API

**Fichier :** `city_detectives/test/register_screen_test.dart`  
**Story :** Task 4.2 – « au moins un test widget … affichage erreur » ; AC – « erreurs API affichées ».

Il existe un test pour l’erreur locale « Les mots de passe ne correspondent pas », mais **aucun test** qui :
- mocke un échec de `register()` (ex. `Exception('Email déjà utilisé')` ou erreur réseau),
- déclenche le submit avec des champs valides,
- et vérifie que le message d’erreur est affiché à l’écran.

Donc la branche « erreur API → affichage à l’utilisateur » n’est pas couverte par un test widget.

**Correction suggérée :** Ajouter un test avec `ProviderScope` + override du provider auth (ou du repository) pour faire échouer `register()` avec une `Exception('Email déjà utilisé')` (ou message API), puis `expect(find.text('...'), findsOneWidget)` sur ce message.

---

## LOW

### 2. [LOW] Accessibilité – bouton Retour sans Semantics

**Fichier :** `city_detectives/lib/features/onboarding/screens/register_screen.dart`  
**Lignes :** 83–87.

Le bouton `leading` (retour) est un `IconButton` sans `Semantics` avec un label. Les autres champs du formulaire ont des `Semantics` (WCAG 2.1 Level A). Pour la cohérence et les lecteurs d’écran, ajouter par exemple :

```dart
Semantics(
  label: 'Retour à l\'écran d\'accueil',
  button: true,
  child: IconButton(...),
)
```

---

### 3. [LOW] AuthService – getter _userRepo recrée un client à chaque accès

**Fichier :** `city_detectives/lib/core/services/auth_service.dart`  
**Ligne :** 21.

`UserRepository get _userRepo => UserRepository(createGraphQLClient());` crée un nouveau `UserRepository` (et un nouveau client GraphQL) à chaque lecture de `_userRepo`. Pour l’instant `_userRepo` n’est utilisé que dans `register()`, donc une seule fois par inscription, mais le pattern est fragile si d’autres méthodes utilisent `_userRepo` plus souvent. Pour plus de clarté et de maîtrise du cycle de vie, on peut stocker le repository dans un champ final (créé une fois) au lieu d’un getter.

---

### 4. [LOW] Tests RegisterScreen – dépendance à l’ordre des champs

**Fichier :** `city_detectives/test/register_screen_test.dart`  
**Lignes :** 44–48 (et similaires).

Les tests utilisent `find.byType(TextFormField).first`, `.at(1)`, `.at(2)` pour cibler email, mot de passe, confirmation. Si l’ordre des champs change dans le formulaire, les tests cassent sans que la cause soit évidente. Pour plus de robustesse, utiliser des `Key` sur les champs (ex. `key: Key('email')`) et `find.byKey(Key('email'))`, ou des `find.text('Email')` / `find.bySemanticsLabel` si disponibles.

---

### 5. [LOW] Documentation – cargo test et tests d’intégration en local

**Fichier :** `city-detectives-api/tests/api/auth_test.rs` ; story Completion Notes.

Les tests HTTP dans `auth_test.rs` sont `#[ignore]`. En local, `cargo test` ne les exécute pas ; il faut lancer `cargo test --test auth_test -- --ignored` (avec le serveur sur 8080). La CI (quality.yml) exécute bien ces tests après démarrage du serveur. Les Completion Notes ou la story pourraient rappeler que « en local, les tests d’intégration auth s’exécutent avec `cargo test --test auth_test -- --ignored` (serveur sur 8080) » pour éviter toute ambiguïté.

---

## Validation AC / Tasks

- **AC1** (compte créé, JWT, données sécurisées) : Implémenté (register backend + Flutter, bcrypt, JWT, secure storage, HTTPS rappelé en config).
- **Task 1.2** (table users, migrations) : Correctement **non cochée** (MVP in-memory).
- **Tasks 2–4** : Coherent avec le code (écran inscription, auth service, repository, navigation, tests unitaires + intégration backend, .env.example).

---

## Recommandation

- **À traiter en priorité :** #1 (test widget erreur API) pour renforcer la couverture et la conformité à la story.
- **Optionnel :** #2 à #5 (accessibilité, petit refactor, robustesse des tests, doc).

Après ajout du test d’affichage d’erreur API (#1), la story peut rester en **review** puis être passée en **done** selon votre processus. Les points LOW peuvent être traités dans cette story ou en suivi.
