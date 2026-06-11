#!/usr/bin/env bash
# Test Sign in with Apple sur simulateur iPad (macOS + Xcode requis).
# Usage : depuis la racine du repo
#   chmod +x scripts/ios/test_apple_signin_ipad.sh
#   ./scripts/ios/test_apple_signin_ipad.sh
#
# Options :
#   RELEASE=1     → flutter run --release (plus proche du build App Review)
#   DEVICE_NAME=  → nom exact du simulateur (défaut : iPad Air 11-inch)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

RELEASE="${RELEASE:-0}"
DEVICE_NAME="${DEVICE_NAME:-iPad Air 11-inch (M3)}"

echo "==> Paychek — test Sign in with Apple (iPad)"
echo "    Repo: $ROOT"
echo "    Simulateur cible: $DEVICE_NAME"
echo ""

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERREUR: flutter introuvable. Installez Flutter sur ce Mac."
  exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "ERREUR: Xcode (xcrun) introuvable. Ce script doit tourner sur macOS."
  exit 1
fi

echo "==> flutter pub get"
flutter pub get

echo "==> Recherche du simulateur iPad"
DEVICE_ID="$(xcrun simctl list devices available | grep -F "$DEVICE_NAME" | head -1 | sed -E 's/^[[:space:]]*([0-9A-F-]+).*/\1/' || true)"

if [[ -z "$DEVICE_ID" ]]; then
  echo "Simulateur '$DEVICE_NAME' non trouvé. Simulateurs iPad disponibles :"
  xcrun simctl list devices available | grep -i ipad || true
  echo ""
  echo "Relancez avec : DEVICE_NAME='iPad Pro 13-inch (M4)' $0"
  exit 1
fi

echo "    ID: $DEVICE_ID"
echo "==> Boot simulateur"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
open -a Simulator

echo "==> Désinstallation de l'app (état propre, comme App Review)"
xcrun simctl uninstall "$DEVICE_ID" pro.paychek.app 2>/dev/null || true

RUN_ARGS=(
  -d "$DEVICE_ID"
  -t lib/main.dart
)

if [[ "$RELEASE" == "1" ]]; then
  RUN_ARGS+=(--release)
  echo "==> Mode RELEASE"
else
  echo "==> Mode DEBUG (pour logs). Pour release : RELEASE=1 $0"
fi

echo ""
echo "=========================================="
echo " CHECKLIST MANUELLE (pendant que l'app tourne)"
echo "=========================================="
echo " 1. Attendre splash + choix de langue"
echo " 2. Sur l'écran connexion → « Sign in with Apple »"
echo " 3. Se connecter avec un Apple ID de test (Settings → Apple ID sur le simu)"
echo " 4. SUCCÈS si l'écran login disparaît (questionnaire ou dashboard)"
echo " 5. ÉCHEC si vous restez sur login sans message d'erreur visible"
echo ""
echo " Logs utiles dans le terminal :"
echo "   [Paychek] Apple Sign-In"
echo "   FirebaseAuth / authorization-error"
echo ""
echo " Appuyez sur q dans le terminal Flutter pour quitter."
echo "=========================================="
echo ""

flutter run "${RUN_ARGS[@]}"
