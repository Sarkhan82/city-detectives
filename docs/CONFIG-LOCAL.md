# Configuration locale – Flutter et Rust

Ce document décrit comment configurer l’environnement local pour lancer les tests Flutter et Rust (city_detectives + city-detectives-api).

### Démarrage rapide

1. **Vérifier la config** : à la racine du repo, exécuter `.\scripts\check-local.ps1` (PowerShell). Le script indique si `flutter` et `cargo` sont trouvés et lance les tests.
2. **Flutter** : installer [Flutter](https://docs.flutter.dev/get-started/install), puis `cd city_detectives && flutter pub get && flutter test`.
3. **Rust** : installer [rustup](https://rustup.rs) (Windows : `rustup-init.exe`), **redémarrer le terminal**, puis `cd city-detectives-api && cargo test`.

---

## Flutter (city_detectives)

### Prérequis

- **Flutter SDK** : [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- Vérifier : `flutter doctor -v`

Pour les tests uniquement, **Android SDK et Visual Studio ne sont pas obligatoires** : les tests peuvent tourner sur **Chrome** (web) ou en mode headless.

### Erreur « Invalid SDK hash »

Si `flutter test` affiche :

```text
Dart Error: Can't load Kernel binary: Invalid SDK hash.
```

À faire dans l’ordre :

1. **Nettoyer le projet**
   ```powershell
   cd city_detectives
   flutter clean
   ```
2. **Fermer** Cursor/VS Code (ou tout processus qui utilise `.dart_tool`) pour que `flutter clean` puisse supprimer `.dart_tool` si besoin.
3. **Réinstaller les deps et relancer les tests**
   ```powershell
   flutter pub get
   flutter test
   ```

Si ça persiste :

- Vérifier qu’**aucun ancien Dart SDK** n’est dans le `PATH` **avant** le répertoire Flutter (Flutter embarque son propre Dart).
- Réparer le cache Dart : `dart pub cache repair` puis `flutter pub get` et `flutter test`.
- **Script automatique** : à la racine du repo, exécuter `.\scripts\flutter-test-fix.ps1` (nettoie, répare le cache, lance les tests sur Chrome).
- **Solution avancée** (si rien ne fonctionne) : forcer le retéléchargement des artefacts Flutter :
  ```powershell
  # Arrêter tout processus flutter/dart (ou fermer Cursor)
  Get-Process -Name "flutter*","dart*" -ErrorAction SilentlyContinue | Stop-Process -Force
  flutter precache --force
  cd city_detectives
  flutter test
  ```

### Lancer les tests Flutter

```powershell
cd city_detectives
flutter pub get   # une fois après clone / pull
flutter test
```

- **Tests sur Chrome** (évite parfois des soucis de shell desktop) :  
  `flutter test -d chrome`
- **Un seul fichier** :  
  `flutter test test/onboarding_screen_test.dart`

---

## Rust (city-detectives-api)

### Prérequis

- **Rust** via rustup : [https://rustup.rs](https://rustup.rs)  
  Sous Windows : télécharger et lancer `rustup-init.exe`, puis **redémarrer le terminal** (ou Cursor) pour que `cargo` et `rustup` soient dans le `PATH`.

- Vérifier :
  ```powershell
  rustup show
  cargo --version
  ```

Si `cargo` ou `rustup` ne sont pas reconnus :

- Vérifier que `%USERPROFILE%\.cargo\bin` est dans le **PATH** (rustup l’ajoute en général automatiquement).
- Sous PowerShell (session en cours) :
  ```powershell
  $env:Path += ";$env:USERPROFILE\.cargo\bin"
  ```

### Erreur « link.exe not found » (Windows)

Si `cargo build` ou `cargo test` affiche : `linker link.exe not found` ou `the msvc targets depend on the msvc linker` :

**Solution recommandée :** installer **Build Tools pour Visual Studio 2022** (gratuit) avec la charge **« Développement Desktop en C++ »** :

1. Télécharger : [Build Tools Visual Studio](https://visualstudio.microsoft.com/fr/visual-cpp-build-tools/)
2. Lancer l’installateur, cocher **« Développement Desktop en C++ »**, installer.
3. Redémarrer le terminal, puis `cargo test`.

**Alternative (sans Visual Studio) :** utiliser la cible GNU (MinGW). Voir `city-detectives-api/.cargo/config.toml.example` (il faut **MinGW-w64 64 bits**, pas MinGW 32 bits ; vérifier avec `gcc -dumpmachine` → doit afficher `x86_64-w64-mingw32`) : installer MinGW-w64, l’ajouter au PATH, copier le fichier en `config.toml`, puis `rustup target add x86_64-pc-windows-gnu` et `cargo test`.

### Lancer les tests Rust

**Tests unitaires** (pas besoin de serveur) :

```powershell
cd city-detectives-api
cargo test
```

Les tests marqués `#[ignore]` (ex. `auth_test` qui appelle l’API sur `localhost:8080`) sont **ignorés** par défaut.

**Tests d’intégration API** (serveur sur 8080) :

1. Démarrer l’API :
   ```powershell
   cd city-detectives-api
   cargo run
   ```
2. Dans un autre terminal :
   ```powershell
   cd city-detectives-api
   cargo test --test auth_test -- --ignored --nocapture
   ```

---

## Récap – commandes pour l’agent / CI

| Projet              | Commande principale | Note                          |
|---------------------|---------------------|-------------------------------|
| Flutter             | `flutter test`      | Après `flutter pub get`      |
| Rust (unitaires)     | `cargo test`        | Sans serveur                  |
| Rust (intégration)   | `cargo test -- --ignored` | Avec API sur 8080   |

---

## Script de vérification (optionnel)

À la racine du repo, vous pouvez utiliser :

- **PowerShell** : `.\scripts\check-local.ps1`
- Il vérifie la présence de `flutter` et `cargo`, puis lance `flutter test` et `cargo test` (sans `--ignored`).

Voir `scripts/check-local.ps1` pour le détail.
