#!/usr/bin/env bash
# Installs a debug build with its Play asset packs, using bundletool's
# local testing mode (D-141). The real Play Asset Delivery client runs,
# serving packs from device storage instead of Google Play.
#
# Usage: tool/install_with_packs.sh [device-serial]
# Needs: java (JDK 17), adb, and bundletool.jar. Set BUNDLETOOL to the
# jar path (download from https://github.com/google/bundletool/releases).
set -euo pipefail

BUNDLETOOL="${BUNDLETOOL:-$HOME/.android/bundletool.jar}"
if [[ ! -f "$BUNDLETOOL" ]]; then
  echo "bundletool.jar not found at $BUNDLETOOL; set BUNDLETOOL." >&2
  exit 2
fi

OUT="build/app/outputs/moksharan-local.apks"
flutter build appbundle --debug
rm -f "$OUT"
java -jar "$BUNDLETOOL" build-apks \
  --bundle=build/app/outputs/bundle/debug/app-debug.aab \
  --output="$OUT" --local-testing

DEVICE_ARGS=()
if [[ $# -ge 1 ]]; then DEVICE_ARGS=(--device-id="$1"); fi
java -jar "$BUNDLETOOL" install-apks --apks="$OUT" "${DEVICE_ARGS[@]}"
