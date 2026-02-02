# City Detectives

Application mobile d’**escape game urbain** : découvrir une ville en résolvant des énigmes (patrimoine, histoire). Projet **Flutter** (app) + **Rust** (API GraphQL).

Vous pouvez **lancer l’app sur un ordinateur** (Windows ou navigateur Chrome) sans téléphone — voir la section [Lancer l’app sur un PC](#lancer-lapp-sur-un-pc-sans-téléphone).

---

## Ce qu’il faut installer

Pour faire tourner le projet sur votre machine, installez les outils suivants **dans l’ordre**. Vérification à chaque étape : ouvrir un **nouveau terminal** après installation.

### 1. Git

- **À quoi ça sert** : cloner le dépôt depuis GitHub.
- **Installation** : [git-scm.com](https://git-scm.com/) → télécharger et installer. Vérifier : `git --version`.

### 2. Flutter

- **À quoi ça sert** : l’application (mobile, mais aussi **Windows** et **Chrome** sur PC).
- **Installation** : [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install). Choisir votre OS (ex. Windows : ZIP ou winget).
- **Vérifier** : `flutter doctor -v`. Pour lancer l’app sur PC, il suffit que **Chrome** et/ou **Windows desktop** soient OK ; Android/iOS sont optionnels.

### 3. Rust (pour l’API backend)

- **À quoi ça sert** : le serveur API (GraphQL) qui tourne sur le PC.
- **Installation** : [rustup.rs](https://rustup.rs) — sous Windows : lancer `rustup-init.exe`, suivre les instructions, puis **redémarrer le terminal**.
- **Vérifier** : `cargo --version`. Si la commande n’est pas trouvée, ajouter `%USERPROFILE%\.cargo\bin` au PATH.

**Windows uniquement (Rust)** : si lors de `cargo build` vous voyez *link.exe not found* ou *msvc linker*, installer [Build Tools pour Visual Studio](https://visualstudio.microsoft.com/fr/visual-cpp-build-tools/) avec la charge **« Développement Desktop en C++ »**.

### Récap des prérequis

| Outil | Usage | Vérification |
|-------|--------|----------------|
| **Git** | Cloner le repo | `git --version` |
| **Flutter** | App (mobile + PC) | `flutter doctor -v` |
| **Rust** (rustup) | API backend | `cargo --version` |

---

## Lancer le projet en local (depuis GitHub)

### 1. Cloner le dépôt

```bash
git clone https://github.com/<votre-org>/city-detectives-bmad.git
cd city-detectives-bmad
```

*(Remplacez `<votre-org>` par l’organisation ou le compte GitHub du repo.)*

### 2. Vérifier l’environnement (optionnel)

Depuis la **racine** du repo (PowerShell) :

```powershell
.\scripts\check-local.ps1
```

Le script vérifie la présence de `flutter` et `cargo`, puis lance les tests Flutter et Rust (unitaires uniquement).

### 3. Backend (API Rust)

```powershell
cd city-detectives-api
cargo build
cargo run
```

L’API écoute sur **http://localhost:8080** (route GraphQL : `POST /graphql`).

- **Variables d’environnement** (optionnel) : créer un fichier `.env` à la racine du repo (voir `.env.example`) avec par exemple `JWT_SECRET=...`, `DATABASE_URL=...` si besoin.

### 4. Application Flutter

Dans un **autre terminal** :

```powershell
cd city_detectives
flutter pub get
flutter run
```

Flutter vous demandera de choisir une **plateforme**. Sur un PC, choisir **Chrome** ou **Windows** (voir section suivante). Pour forcer une cible : `flutter run -d chrome` ou `flutter run -d windows`.

- **Pointer vers l’API locale** :  
  `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080`  
  (ou remplacer `chrome` par `windows` si vous lancez en app Windows.)

---

## Lancer l’app sur un PC (sans téléphone)

L’app est pensée pour mobile, mais **Flutter permet de l’exécuter sur un ordinateur** sans émulateur ni téléphone. Deux options sur PC :

### Option A : Dans le navigateur (Chrome)

- **Prérequis** : Flutter installé, Chrome installé. `flutter doctor` doit indiquer que Chrome est disponible.
- **Lancement** :
  1. Démarrer l’API : dans un terminal `cd city-detectives-api` puis `cargo run`.
  2. Dans un autre terminal : `cd city_detectives`, puis :
  ```powershell
  flutter pub get
  flutter run -d chrome
  ```
- Une fenêtre Chrome s’ouvre avec l’app. Pour utiliser l’API locale :  
  `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080`

### Option B : Application Windows (fenêtre native)

- **Prérequis** : Flutter installé. `flutter doctor` doit indiquer que le support **Windows desktop** est activé (Flutter l’active en général au premier `flutter run -d windows`).
- **Lancement** :
  1. Démarrer l’API : `cd city-detectives-api` puis `cargo run`.
  2. Dans un autre terminal :
  ```powershell
  cd city_detectives
  flutter pub get
  flutter run -d windows
  ```
- Une fenêtre Windows s’ouvre avec l’app. Même principe pour l’API : ajouter `--dart-define=API_BASE_URL=http://localhost:8080` si besoin.

### Résumé

| Où lancer l’app | Commande | Remarque |
|------------------|----------|----------|
| **Chrome** (navigateur) | `flutter run -d chrome` | Rapide, pas d’installation supplémentaire. |
| **Windows** (app native) | `flutter run -d windows` | Fenêtre desktop ; peut demander une première compilation plus longue. |

Dans les deux cas, l’**API doit tourner** sur le même PC (`cargo run` dans `city-detectives-api`).

### 5. Résumé des commandes

| Action | Où | Commande |
|--------|-----|----------|
| Lancer l’API | `city-detectives-api` | `cargo run` |
| Lancer l’app | `city_detectives` | `flutter pub get` puis `flutter run` |
| Tests Flutter | `city_detectives` | `flutter test` |
| Tests Rust (unitaires) | `city-detectives-api` | `cargo test` |
| Tests Rust (intégration API) | `city-detectives-api` | Lancer l’API dans un terminal, puis `cargo test -- --ignored` |

Plus de détails (erreurs fréquentes, tests sur Chrome, etc.) : **[docs/CONFIG-LOCAL.md](docs/CONFIG-LOCAL.md)**.

---

## Structure du dépôt

```
city-detectives-bmad/
├── city_detectives/          # App Flutter (mobile / desktop / web)
├── city-detectives-api/      # API GraphQL (Rust, Axum)
├── _bmad/                    # Méthodo / specs BMAD
├── _bmad-output/             # Livrables (artefacts, planning, sprint)
├── docs/                     # Config locale, CI
├── scripts/                  # check-local.ps1, flutter-test-fix.ps1
├── .env.example              # Exemple de variables d’environnement
└── .github/workflows/        # CI (Quality pipeline)
```

---

## CI (GitHub Actions)

- **Workflow** : [.github/workflows/quality.yml](.github/workflows/quality.yml)
- **Déclencheurs** : push / PR sur `main`, `master`, `develop`, `feature/**`
- **Jobs** :
  - **Flutter** : `dart analyze`, format check, `flutter test --coverage`
  - **Rust** : `cargo fmt`, `cargo clippy`, `cargo test` + tests d’intégration API (serveur sur 8080)

Voir [docs/ci.md](docs/ci.md) pour reproduire les étapes en local.

---

## Ce qui a été fait jusqu’ici

Suivi détaillé : **_bmad-output/implementation-artifacts/sprint-status.yaml**.

### Épics et stories livrées

| Epic | Description | Stories (état) |
|------|-------------|----------------|
| **Epic 1** | Onboarding & compte | 1-1 App shell & installation ✅ — 1-2 Création de compte ✅ — 1-3 Découverte première enquête gratuite / onboarding (en review) |
| **Epic 2** | Catalogue enquêtes | 2-1 Parcourir / consulter enquêtes ✅ — 2-2 Sélection, visibilité gratuit/payant ✅ |
| **Epic 3** | Jouer une enquête | 3-1 Démarrer enquête, navigation énigmes ✅ — 3-2 Progression, carte interactive, position ✅ — 3-3 Pause, reprise, abandon, sauvegarde ✅ — 3-4 Capacités techniques (ready-for-dev) |
| **Epic 4** | Énigmes & aide | 4-1 Photo / géolocalisation, 4-2 Mots / puzzle, 4-3 Aide contextuelle (ready-for-dev) ; 4-4 Lore / saut (backlog) |
| **Epic 5–9** | Complétion, badges, monétisation, admin, notifications, avis | Backlog |

### Fonctionnalités implémentées

- **App Flutter**  
  - Shell Material, navigation (GoRouter), Riverpod.  
  - Inscription / auth (JWT, `flutter_secure_storage`), écrans onboarding, liste et détail des enquêtes, puce gratuit/payant.  
  - Écran de jeu : navigation énigmes, carte interactive (flutter_map), géolocalisation (geolocator).  
  - Pause / reprise / abandon : sauvegarde locale (Hive), modèle de progression.

- **API Rust (Axum + GraphQL)**  
  - Mutation d’inscription, JWT, middleware auth.  
  - Schéma GraphQL : auth + enquêtes (liste, détail).  
  - CORS, tests unitaires et tests d’intégration (auth, enquêtes).

- **Qualité & DevOps**  
  - Pipeline CI (Flutter + Rust), scripts locaux (`check-local.ps1`, `flutter-test-fix.ps1`), documentation dans `docs/`.

### Artefacts d’implémentation

Les specs et comptes rendus des stories sont dans **\_bmad-output/implementation-artifacts/** (fichiers du type `1-2-creation-de-compte.md`, `3-3-pause-reprise-abandon-sauvegarde.md`, code reviews, etc.).

---

## Variables d’environnement

- **Racine** : copier `.env.example` vers `.env` et adapter (voir commentaires dans le fichier). Ne pas committer `.env`.
- **API** : `JWT_SECRET`, `DATABASE_URL` (optionnel selon les stories).
- **App** : `API_BASE_URL` peut être passé en `--dart-define=API_BASE_URL=...` au build/run.

---

## Licence & contact

Voir le dépôt GitHub pour la licence et les contributeurs.
