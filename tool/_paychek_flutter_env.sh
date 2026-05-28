# shellcheck shell=bash
# Résout `flutter` sur macOS (PATH, FLUTTER_ROOT, ~/flutter, FVM).
paychek_resolve_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    return 0
  fi
  if [[ -x "${FLUTTER_ROOT:-}/bin/flutter" ]]; then
    export PATH="${FLUTTER_ROOT}/bin:$PATH"
    return 0
  fi
  if [[ -x "$HOME/flutter/bin/flutter" ]]; then
    export PATH="$HOME/flutter/bin:$PATH"
    return 0
  fi
  if [[ -x "$HOME/development/flutter/bin/flutter" ]]; then
    export PATH="$HOME/development/flutter/bin:$PATH"
    return 0
  fi
  if [[ -f .fvm/flutter_sdk/bin/flutter ]]; then
    export PATH="$(pwd)/.fvm/flutter_sdk/bin:$PATH"
    return 0
  fi
  if command -v fvm >/dev/null 2>&1; then
    local sdk
    sdk="$(fvm flutter sdk-path 2>/dev/null || true)"
    if [[ -n "$sdk" && -x "$sdk/bin/flutter" ]]; then
      export PATH="$sdk/bin:$PATH"
      return 0
    fi
  fi
  return 1
}

paychek_require_flutter() {
  if paychek_resolve_flutter; then
    return 0
  fi
  echo "ERREUR: commande « flutter » introuvable." >&2
  echo "  • Installe Flutter: https://docs.flutter.dev/get-started/install/macos" >&2
  echo "  • Puis: export PATH=\"\$HOME/flutter/bin:\$PATH\"" >&2
  echo "  • Ou: export FLUTTER_ROOT=/chemin/vers/flutter" >&2
  exit 127
}
