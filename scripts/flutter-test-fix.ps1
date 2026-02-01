# flutter-test-fix.ps1 – Nettoyer le cache Flutter puis lancer les tests.
# Utiliser en cas d'erreur "Invalid SDK hash".
# Usage : depuis la racine du repo : .\scripts\flutter-test-fix.ps1

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location "$root\city_detectives"

# Mettre le Dart de Flutter en tête du PATH (évite conflit avec un Dart standalone)
$flutterBin = (Get-Command flutter -ErrorAction SilentlyContinue)?.Source
if ($flutterBin) {
    $flutterDir = Split-Path -Parent $flutterBin
    $env:PATH = "$flutterDir;$env:PATH"
}

Write-Host "=== Nettoyage Flutter (fix Invalid SDK hash) ===" -ForegroundColor Cyan
flutter clean 2>&1 | Out-Null
Write-Host "  flutter clean OK" -ForegroundColor Gray
dart pub cache repair 2>&1 | Out-Null
Write-Host "  dart pub cache repair OK" -ForegroundColor Gray
flutter pub get 2>&1 | Out-Null
Write-Host "  flutter pub get OK" -ForegroundColor Gray
Write-Host ""
Write-Host "Lancement des tests (Chrome)..." -ForegroundColor Cyan
& flutter test --platform=chrome 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Si les tests échouent encore, fermez Cursor/VS Code, relancez ce script depuis un terminal externe." -ForegroundColor Yellow
}
