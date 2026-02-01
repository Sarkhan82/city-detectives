# Pipeline CI – City Detectives

Pipeline qualité (Flutter + Rust) : analyse, format, tests, burn-in, artefacts.

## Fichier

- **Workflow** : `.github/workflows/quality.yml`

## Déclencheurs

- **Push / PR** : branches `main`, `master`, `develop`
- **Planification** : dimanche 2h UTC (burn-in hebdomadaire)

## Jobs

| Job      | Rôle                          | Durée cible |
|----------|--------------------------------|-------------|
| **flutter** | Analyse, format, tests Flutter | &lt; 15 min  |
| **burn-in** | 3 exécutions de `flutter test` (détection flaky) | &lt; 45 min  |
| **rust**    | `cargo fmt`, `clippy`, `cargo test` (API) | &lt; 15 min  |

- **Burn-in** : exécuté uniquement sur **pull_request** et **schedule** (pas sur chaque push).

## Artefacts en échec

- **Flutter** : en cas d’échec des tests, `city_detectives/coverage` est uploadé (rétention 30 jours).
- **Burn-in** : idem en cas d’échec pendant le burn-in.

## Reproduire en local

```bash
# Flutter
cd city_detectives
flutter pub get
dart analyze
dart format --set-exit-if-changed .
flutter test

# Burn-in (3 itérations)
for i in 1 2 3; do echo "Iteration $i/3"; flutter test || exit 1; done

# Rust
cd city-detectives-api
cargo fmt --all -- --check
cargo clippy -- -D warnings
cargo test
```

## Concurrency

Un seul run du workflow par branche : un nouveau push annule le run en cours (`cancel-in-progress: true`).
