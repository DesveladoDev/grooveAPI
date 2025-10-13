#!/usr/bin/env bash
set -euo pipefail

# Upload iOS dSYM files to Firebase Crashlytics
# Usage:
#   ./scripts/upload_dsyms.sh                # uploads dSYMs from latest Xcode archive
#   ./scripts/upload_dsyms.sh --uuid <UUID>  # uploads only the dSYM matching a UUID
#   ARCHIVE_PATH=/path/to/MyApp.xcarchive ./scripts/upload_dsyms.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

UPLOAD_BIN="$PROJECT_DIR/ios/Pods/FirebaseCrashlytics/upload-symbols"
GSP="$PROJECT_DIR/ios/Runner/GoogleService-Info.plist"

UUID_FILTER=""
if [[ "${1:-}" == "--uuid" && -n "${2:-}" ]]; then
  UUID_FILTER="$2"
fi

if [[ ! -f "$UPLOAD_BIN" ]]; then
  echo "[Error] upload-symbols not found at: $UPLOAD_BIN"
  echo "Run: (cd ios && pod install) and try again."
  exit 1
fi

if [[ ! -f "$GSP" ]]; then
  echo "[Error] GoogleService-Info.plist not found at: $GSP"
  exit 1
fi

# Resolve archive path
ARCHIVE_PATH_DEFAULT=""
if [[ -d "$HOME/Library/Developer/Xcode/Archives" ]]; then
  # Pick latest archive in the most recent date folder
  LATEST_DATE_DIR=$(ls -1 "$HOME/Library/Developer/Xcode/Archives" | sort | tail -n1 || true)
  if [[ -n "$LATEST_DATE_DIR" ]]; then
    ARCHIVE_PATH_DEFAULT=$(ls -1d "$HOME/Library/Developer/Xcode/Archives/$LATEST_DATE_DIR"/*.xcarchive 2>/dev/null | sort | tail -n1 || true)
  fi
fi

ARCHIVE_PATH="${ARCHIVE_PATH:-$ARCHIVE_PATH_DEFAULT}"

if [[ -z "$ARCHIVE_PATH" || ! -d "$ARCHIVE_PATH" ]]; then
  echo "[Error] Could not locate an Xcode .xcarchive."
  echo "Open Xcode and Product > Archive, then re-run this script."
  exit 1
fi

DSYMS_DIR="$ARCHIVE_PATH/dSYMs"
if [[ ! -d "$DSYMS_DIR" ]]; then
  echo "[Error] dSYMs directory not found in archive: $ARCHIVE_PATH"
  exit 1
fi

echo "Using archive: $ARCHIVE_PATH"
echo "GoogleService-Info: $GSP"

FOUND=0
while IFS= read -r -d '' DSYM; do
  if [[ -n "$UUID_FILTER" ]]; then
    if dwarfdump --uuid "$DSYM" | grep -qi "$UUID_FILTER"; then
      echo "Uploading dSYM (UUID match): $DSYM"
      "$UPLOAD_BIN" -gsp "$GSP" -p ios "$DSYM"
      FOUND=1
    fi
  else
    echo "Uploading dSYM: $DSYM"
    "$UPLOAD_BIN" -gsp "$GSP" -p ios "$DSYM"
    FOUND=1
  fi
done < <(find "$DSYMS_DIR" -name "*.dSYM" -print0)

if [[ "$FOUND" -eq 0 ]]; then
  if [[ -n "$UUID_FILTER" ]]; then
    echo "[Warning] No dSYM found matching UUID: $UUID_FILTER"
  else
    echo "[Warning] No dSYM files found to upload in: $DSYMS_DIR"
  fi
fi

echo "Done. Crashlytics dSYMs upload process completed."