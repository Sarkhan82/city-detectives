# check-local.ps1 – Vérifier la config locale Flutter + Rust et lancer les tests.
# Usage : depuis la racine du repo : .\scripts\check-local.ps1
# Option : -FlutterOnly ou -RustOnly pour ne lancer qu'un des deux.

param(
    [switch]$FlutterOnly,
    [switch]$RustOnly
)

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

Write-Host "=== Vérification config locale (Flutter + Rust) ===" -ForegroundColor Cyan
Write-Host ""

# --- Flutter ---
if (-not $RustOnly) {
    $flutterOk = $null -ne (Get-Command flutter -ErrorAction SilentlyContinue)
    if (-not $flutterOk) {
        Write-Host "[FLUTTER] flutter non trouvé dans le PATH." -ForegroundColor Red
        Write-Host "  Installez Flutter : https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
        Write-Host "  Puis redémarrez le terminal." -ForegroundColor Yellow
    } else {
        Write-Host "[FLUTTER] flutter trouvé." -ForegroundColor Green
        Set-Location "$root\city_detectives"
        & flutter pub get 2>&1 | Out-Null
        Write-Host "  Lancement: flutter test ..." -ForegroundColor Gray
        $flutterResult = & flutter test 2>&1; $fe = $LASTEXITCODE
        if ($fe -eq 0) {
            Write-Host "[FLUTTER] Tests OK." -ForegroundColor Green
        } else {
            Write-Host "[FLUTTER] Tests en échec ou erreur (ex. Invalid SDK hash)." -ForegroundColor Red
            Write-Host "  Voir docs/CONFIG-LOCAL.md (section Invalid SDK hash)." -ForegroundColor Yellow
            $flutterResult | Write-Host
        }
        Set-Location $root
    }
    Write-Host ""
}

# --- Rust ---
if (-not $FlutterOnly) {
    $cargoOk = $null -ne (Get-Command cargo -ErrorAction SilentlyContinue)
    if (-not $cargoOk) {
        Write-Host "[RUST] cargo non trouvé dans le PATH." -ForegroundColor Red
        Write-Host "  Installez Rust : https://rustup.rs (Windows : rustup-init.exe)" -ForegroundColor Yellow
        Write-Host "  Puis redémarrez le terminal (ou ajoutez %USERPROFILE%\.cargo\bin au PATH)." -ForegroundColor Yellow
    } else {
        Write-Host "[RUST] cargo trouvé." -ForegroundColor Green
        Set-Location "$root\city-detectives-api"
        Write-Host "  Lancement: cargo test (tests unitaires uniquement) ..." -ForegroundColor Gray
        $rustResult = & cargo test 2>&1; $re = $LASTEXITCODE
        if ($re -eq 0) {
            Write-Host "[RUST] Tests OK." -ForegroundColor Green
        } else {
            Write-Host "[RUST] Tests en échec." -ForegroundColor Red
            $rustResult | Write-Host
        }
        Set-Location $root
    }
}

Write-Host ""
Write-Host "Récap : docs/CONFIG-LOCAL.md" -ForegroundColor Cyan
