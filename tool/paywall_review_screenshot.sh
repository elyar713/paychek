#!/usr/bin/env bash
# Prépare une capture « review » abonnement App Store Connect (IAP).
# Usage: ./tool/paywall_review_screenshot.sh capture.png [1284x2778]
#
# Apple n’accepte que des tailles EXACTES (voir screenshot-specifications Apple).
# Si redimensionner à la main échoue, préférer une capture Simulator (voir tool/apple_iap_setup.md).
set -euo pipefail
cd "$(dirname "$0")/.."

INPUT="${1:?Usage: $0 chemin/capture.png [1284x2778]}"
SIZE="${2:-1284x2778}"
W="${SIZE%x*}"
H="${SIZE#*x}"
OUT="build/paywall_review_${W}x${H}.jpg"
mkdir -p build

if [[ ! -f "$INPUT" ]]; then
  echo "Fichier introuvable: $INPUT" >&2
  exit 1
fi

echo ">> Source: $INPUT"
sips -g pixelWidth -g pixelHeight -g format "$INPUT" 2>/dev/null || true

if command -v magick >/dev/null 2>&1; then
  echo ">> ImageMagick → ${W}x${H} JPEG (sRGB, sans alpha, sans EXIF orientation)"
  magick "$INPUT" \
    -auto-orient \
    -resize "${W}x${H}!" \
    -background black \
    -alpha remove \
    -alpha off \
    -colorspace sRGB \
    -strip \
    -interlace None \
    -quality 92 \
    "$OUT"
elif command -v convert >/dev/null 2>&1; then
  convert "$INPUT" \
    -auto-orient \
    -resize "${W}x${H}!" \
    -background black \
    -alpha remove \
    -alpha off \
    -colorspace sRGB \
    -strip \
    -quality 92 \
    "$OUT"
else
  echo ">> sips (sans ImageMagick) → ${W}x${H} JPEG"
  TMP="$(mktemp /tmp/paychek_screenshot.XXXXXX.png)"
  sips -z "$H" "$W" "$INPUT" --out "$TMP" >/dev/null
  sips -s format jpeg -s formatOptions 92 "$TMP" --out "$OUT" >/dev/null
  rm -f "$TMP"
fi

echo ">> Sortie: $OUT"
sips -g pixelWidth -g pixelHeight -g format "$OUT"

ACTUAL_W=$(sips -g pixelWidth "$OUT" 2>/dev/null | awk '/pixelWidth/ {print $2}')
ACTUAL_H=$(sips -g pixelHeight "$OUT" 2>/dev/null | awk '/pixelHeight/ {print $2}')
if [[ "$ACTUAL_W" != "$W" || "$ACTUAL_H" != "$H" ]]; then
  echo "ERREUR: dimensions incorrectes ($ACTUAL_W x $ACTUAL_H)" >&2
  exit 1
fi

echo ""
echo "Upload dans App Store Connect → abonnement → Informations review → Choisir:"
echo "  $(pwd)/$OUT"
echo ""
echo "Si refusé, regénère avec une autre taille Apple, ex.:"
echo "  $0 \"$INPUT\" 1260x2736"
echo "  $0 \"$INPUT\" 1320x2868"
echo "  $0 \"$INPUT\" 1242x2688"
echo "  $0 \"$INPUT\" 1179x2556"
echo ""
echo "Méthode la plus fiable: capture depuis le Simulateur iOS (voir tool/apple_iap_setup.md)."
