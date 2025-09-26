#!/usr/bin/env bash
set -euo pipefail

# Simple ADB screencap helper.
# Usage:
#   scripts/adb_screencap.sh [DEVICE_ID] [OUTPUT_DIR]
# Defaults:
#   DEVICE_ID: 54281JEBF23381 (Pixel)
#   OUTPUT_DIR: screenshots

DEVICE_ID=${1:-54281JEBF23381}
OUTDIR=${2:-screenshots}

mkdir -p "$OUTDIR"
TS=$(date +%Y%m%d-%H%M%S)
OUTFILE="$OUTDIR/pixel_${TS}.png"

echo "📱 Capturing screencap from device: $DEVICE_ID"
if adb -s "$DEVICE_ID" exec-out screencap -p > "$OUTFILE" 2>/dev/null; then
  echo "✅ Saved: $OUTFILE"
  exit 0
fi

echo "⚠️ exec-out failed; falling back to sdcard pull method"
adb -s "$DEVICE_ID" shell screencap -p /sdcard/screen.png
adb -s "$DEVICE_ID" pull /sdcard/screen.png "$OUTFILE"
adb -s "$DEVICE_ID" shell rm /sdcard/screen.png || true
echo "✅ Saved: $OUTFILE"

