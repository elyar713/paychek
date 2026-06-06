#!/usr/bin/env bash
# Lit DEVELOPMENT_TEAM depuis ios/Flutter/Signing.xcconfig (gitignored).
set -euo pipefail

paychek_ios_read_team_id() {
  local cfg="ios/Flutter/Signing.xcconfig"
  if [[ ! -f "$cfg" ]]; then
    return 1
  fi
  local raw
  raw="$(grep -E '^DEVELOPMENT_TEAM=' "$cfg" | head -1 | cut -d= -f2- | tr -d '[:space:]')"
  if [[ -z "$raw" || "$raw" == "XXXXXXXXXX" ]]; then
    return 1
  fi
  printf '%s' "$raw"
}

# ExportOptions.plist + teamID si Signing.xcconfig existe.
paychek_ios_export_plist_with_team() {
  local base="${1:-ios/ExportOptions.plist}"
  local team_id
  if ! team_id="$(paychek_ios_read_team_id)"; then
    printf '%s' "$base"
    return 0
  fi
  local out
  out="$(mktemp "${TMPDIR:-/tmp}/paychek-export-options.XXXXXX")"
  cp "$base" "$out"
  if /usr/libexec/PlistBuddy -c "Print :teamID" "$out" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c "Set :teamID $team_id" "$out"
  else
    /usr/libexec/PlistBuddy -c "Add :teamID string $team_id" "$out"
  fi
  printf '%s' "$out"
}

paychek_ios_unlock_login_keychain() {
  local kc="${HOME}/Library/Keychains/login.keychain-db"
  if [[ ! -f "$kc" ]]; then
    kc="${HOME}/Library/Keychains/login.keychain"
  fi
  if [[ -f "$kc" ]]; then
    security unlock-keychain "$kc" 2>/dev/null || true
    security set-keychain-settings -lut 21600 "$kc" 2>/dev/null || true
  fi
}
