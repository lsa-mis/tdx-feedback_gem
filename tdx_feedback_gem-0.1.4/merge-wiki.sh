#!/bin/bash
set -euo pipefail

WIKI_DIR="wiki"
WIKI_GIT_DIR="tdx-feedback_gem.wiki"
BACKUP_DIR=".backup"
AUTO_COMMIT=false

# Check for --auto-commit flag
if [[ "${1:-}" == "--auto-commit" ]]; then
  AUTO_COMMIT=true
fi

mkdir -p "$BACKUP_DIR"

# Arrays to track summary
SUMMARY_AUTO=()
SUMMARY_CONFLICT=()
SUMMARY_SINGLE=()

# Sort files for predictable order
FILES=$(find "$WIKI_DIR" "$WIKI_GIT_DIR" -maxdepth 1 -type f -name "*.md" | sort)

for FILEPATH in $FILES; do
  BASENAME=$(basename "$FILEPATH")
  FILE_WIKI="$WIKI_DIR/$BASENAME"
  FILE_WIKI_GIT="$WIKI_GIT_DIR/$BASENAME"
  MERGED_FILE="$WIKI_DIR/$BASENAME.merged"

  # Identify files that exist in only one directory
  if [[ -f "$FILE_WIKI" && ! -f "$FILE_WIKI_GIT" ]]; then
    echo "Only in wiki/: $BASENAME"
    SUMMARY_SINGLE+=("$BASENAME (wiki only)")
    cp "$FILE_WIKI" "$MERGED_FILE"
    continue
  elif [[ -f "$FILE_WIKI_GIT" && ! -f "$FILE_WIKI" ]]; then
    echo "Only in wiki.git/: $BASENAME"
    SUMMARY_SINGLE+=("$BASENAME (wiki.git only)")
    cp "$FILE_WIKI_GIT" "$MERGED_FILE"
    continue
  fi

  # Backup originals with timestamp
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  cp "$FILE_WIKI" "$BACKUP_DIR/${BASENAME}.wiki.$TIMESTAMP.bak"
  cp "$FILE_WIKI_GIT" "$BACKUP_DIR/${BASENAME}.wiki_git.$TIMESTAMP.bak"

  # Use git merge-file to merge unchanged lines automatically
  TMP_FILE=$(mktemp)
  git merge-file -p "$FILE_WIKI" "$FILE_WIKI" "$FILE_WIKI_GIT" > "$TMP_FILE"

  # Insert provenance markers around conflicting sections
  awk '
  BEGIN{conflict=0}
  /^<</{print "--- [wiki] ---"; conflict=1; next}
  /^==/ {print "--- [CONFLICT SEPARATOR] ---"; next}
  /^>>/{print "--- [wiki.git] ---"; conflict=0; next}
  {print}
  ' "$TMP_FILE" > "$MERGED_FILE"

  rm "$TMP_FILE"

  # Check if there are conflicts
  if grep -q "\[CONFLICT SEPARATOR\]" "$MERGED_FILE"; then
    SUMMARY_CONFLICT+=("$BASENAME")
    echo "Opening VS Code for conflicts in $MERGED_FILE..."
    code -w "$MERGED_FILE"
  else
    SUMMARY_AUTO+=("$BASENAME")
  fi

  # Auto-commit merged file if flag is set
  if $AUTO_COMMIT; then
    mv "$MERGED_FILE" "$FILE_WIKI"
  fi
done

# Print summary
echo
echo "====== Merge Summary ======"

if [ ${#SUMMARY_AUTO[@]} -gt 0 ]; then
  echo "Automatically merged files:"
  for f in "${SUMMARY_AUTO[@]}"; do echo "  $f"; done
  echo
fi

if [ ${#SUMMARY_CONFLICT[@]} -gt 0 ]; then
  echo "Files with conflicts (opened in VS Code):"
  for f in "${SUMMARY_CONFLICT[@]}"; do echo "  $f"; done
  echo
fi

if [ ${#SUMMARY_SINGLE[@]} -gt 0 ]; then
  echo "Files copied from single source:"
  for f in "${SUMMARY_SINGLE[@]}"; do echo "  $f"; done
  echo
fi

echo "============================"
