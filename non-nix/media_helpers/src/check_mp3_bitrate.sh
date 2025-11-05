#!/usr/bin/env bash
# set -euo pipefail

# Load environment variables from ../.env
if [ -f .env ]; then
  source .env
else
  echo ".env file not found at ../.env"
  exit 1
fi

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {incoming|lib}"
  exit 1
fi

# Validate the argument
case "$1" in
  incoming)
    SEARCH_PATH=$INCOMING_DIR
    REPORT_PATH=$INCOMING_REPORTS_DIR
    ;;
  lib)
    SEARCH_PATH=$LIB_DIR
    REPORT_PATH=$LIB_REPORTS_DIR
    ;;
  *)
    echo "Invalid argument. Usage: $0 {incoming|lib}"
    exit 1
    ;;
esac

OUT_PATH="${REPORT_PATH}/${PATHS_LOW_QUALITY}"
MP3_LIST_FILE="${REPORT_PATH}/${PATHS_MP3_FILE}"

mkdir -p "${REPORT_PATH}"

# Empty files
> "$OUT_PATH_FILTERED"
> "$OUT_PATH"

# Counters
bad_count=0
good_count=0

# === MAIN LOOP ===
while IFS= read -r folder; do
  [ -z "$folder" ] && continue
  [ ! -d "$folder" ] && continue

  # Find all mp3 files in the folder
  mp3s=$(find "$folder" -type f -iname "*.mp3")
  [ -z "$mp3s" ] && continue

  folder_bad=false

  # Check each MP3 file’s bitrate
  while IFS= read -r file; do
    br=$(ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate \
         -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null || echo 0)
    [ -z "$br" ] && br=0

    if [ "$br" -lt 250000 ]; then
      folder_bad=true
      break
    fi
  done <<< "$mp3s"

  if [ "$folder_bad" = true ]; then
    echo "$folder" >> "$OUT_PATH"
    printf "f"
    ((bad_count++))
  else
    printf "."
    ((good_count++))
  fi

done < "$MP3_LIST_FILE"

echo
echo "Low Quality MP3 folders $bad_count/$((bad_count + good_count)). Results saved to: $OUT_PATH"

