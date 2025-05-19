#!/usr/bin/env bash

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/gh-job-status"
mkdir -p "$CACHE_DIR"

# Ensure inside a Git repo
GIT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$GIT_DIR" ]; then
  return 2
fi

CACHE_FILE="$CACHE_DIR/$(echo "$GIT_DIR" | md5sum | cut -d' ' -f1)"

# Use cache if file is recent (< 120 seconds)
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt 120 ]; then
  cat "$CACHE_FILE"
  return 2
fi

# Get GitHub repo and branch
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)

if [ -z "$repo" ] || [ -z "$branch" ]; then
  return 2
fi

# Query latest run status
result=$(gh run list --limit 1 --branch "$branch" --json status,conclusion -q '.[0] | "\(.status) \(.conclusion)"' 2>/dev/null)

emoji=""
case "$result" in
  *success*) emoji="✅" ;;
  *failure*) emoji="❌" ;;
  *cancelled*) emoji="🚫" ;;
  *in_progress*) emoji="🔄" ;;
  *) emoji="⚠️" ;;
esac

output="$emoji $result"
echo "$output" > "$CACHE_FILE"
echo -n "$output"
return 0
