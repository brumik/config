#!/usr/bin/env bash
set -euo pipefail

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

mkdir -p "${REPORT_PATH}"

# Find all MP3 files print only the folder names
find "${SEARCH_PATH}" -type f -iname "*.mp3" -printf '%h\n' | sort -u > "${REPORT_PATH}/${PATHS_MP3_FILE}"
find "${SEARCH_PATH}" -type f -iname "*.flac" -printf '%h\n' | sort -u > "${REPORT_PATH}/${PATHS_FLAC_FILE}"

# Find all other common formats (FLAC, AAC, M4A, OGG, WAV, etc.)
find "${SEARCH_PATH}" -type f \( \
  -iname "*.aac"  -o \
  -iname "*.m4a"  -o \
  -iname "*.ogg"  -o \
  -iname "*.wav"  -o \
  -iname "*.wma"  \
  \) > "${REPORT_PATH}/${PATHS_OTHERS_FILE}"
# I want here the full name to see what extension is it, the bellow line gives only the path
# \) -printf '%h\n' | sort -u > "${REPORT_PATH}/${PATHS_OTHERS_FILE}"

echo "Scan complete. See files ${PATHS_MP3_FILE} ${PATHS_OTHERS_FILE} and ${PATHS_FLAC_FILE}"
