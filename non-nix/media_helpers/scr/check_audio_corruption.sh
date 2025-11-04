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

check_file() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}"  # lowercase

    if [[ "$ext" == "flac" ]]; then
        flac -t "$file" &> /dev/null
    elif [[ "$ext" == "mp3" ]]; then
        mp3val "$file" -f -nb &> /dev/null
    else
        return 0  # skip unknown extensions
    fi
}

declare -A unique_paths

while IFS= read -r -d '' file; do
  if ! check_file "$file"; then
      # echo "$file" >> "$REPORT_FILE"
      # Extract the path by removing the filename
      path="${file%/*}"
      # Add the path to the associative array (unique due to nature of associative arrays)
      unique_paths["$path"]=1
      printf "f"
      ((bad_count++))
  else
      printf "."
      ((good_count++))
  fi
done < <(find "$SEARCH_PATH" -type f \( -iname "*.mp3" -o -iname "*.flac" \) -print0)


for path in "${!unique_paths[@]}"; do
    echo "$path"
done | sort > "$REPORT_FILE"

echo 
echo "Corrupted $bad_count/$((bad_count + good_count)). Results saved to: $REPORT_FILE"
