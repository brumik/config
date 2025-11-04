#!/usr/bin/env bash
# if set -e then the first error in ffmpeg will cause the script to stop and fail
# set -euo pipefail

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo ".env file not found"
  exit 1
fi

# Check argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {incoming|lib}"
  exit 1
fi

case "$1" in
  incoming)
    SEARCH_PATH=$INCOMING_DIR
    REPORT_PATH="$INCOMING_REPORTS_DIR"
    REPORT_FILE="$INCOMING_REPORTS_DIR/$PATHS_CORRUPTED"
    ;;
  lib)
    SEARCH_PATH=$LIB_DIR
    REPORT_PATH="$LIB_REPORTS_DIR"
    REPORT_FILE="$LIB_REPORTS_DIR/$PATHS_CORRUPTED"
    ;;
  *)
    echo "Invalid argument. Usage: $0 {incoming|lib}"
    exit 1
    ;;
esac

mkdir -p "$REPORT_PATH"
> "$REPORT_FILE"

# Counters
bad_count=0
good_count=0

while IFS= read -r -d '' file; do
  if ! output=$(ffmpeg -v error -i "$file" -f null - 2>&1 > /dev/null); then
    # echo "${file/*}" >> "$REPORT_FILE"
    echo "$file" >> "$REPORT_FILE"
    printf "f"
    ((bad_count++))
  else
    printf "."
    ((good_count++))
  fi
done < <(find "$SEARCH_PATH" -type f \( -iname "*.mp3" -o -iname "*.flac" \) -print0)

echo 
echo "Corrupted $bad_count/$((bad_count + good_count)). Results saved to: $REPORT_PATH"
