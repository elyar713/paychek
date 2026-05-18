#!/usr/bin/env bash
# Installer Paychek sur TON iPhone (test) — Mac + câble USB + Xcode requis.
# Fonctionne avec un Apple ID personnel (7 jours) ou compte Développeur validé.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION_LINE="$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')"
echo ">> Paychek iOS sur iPhone — version $VERSION_LINE"
echo ""

flutter pub get
flutter gen-l10n

cd ios
pod install
cd ..

echo ">> Ouverture Xcode (signing manuel sur ton iPhone)"
open ios/Runner.xcworkspace

cat <<'EOF'

Dans Xcode :
  1. Branche l’iPhone, déverrouille-le, fais « Faire confiance » à l’ordinateur si demandé.
  2. En haut : cible « Runner » + sélectionne ton iPhone (pas un simulateur).
  3. Runner (projet) → Signing & Capabilities → Team : ton Apple ID / équipe Paychek.
     Bundle ID : pro.paychek.app (doit correspondre au compte).
  4. Menu Product → Run (▶)  ou  Cmd+R

Flutter en ligne de commande (alternative si signing OK) :
  flutter devices
  flutter run --release -d <id_de_ton_iphone>

App Store / TestFlight (tous les utilisateurs) :
  Compte Apple Developer doit être « Active » → ./tool/build_ios_release.sh

EOF
