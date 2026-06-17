#!/usr/bin/env bash
set -euo pipefail

# Move to the project root (wherever this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Regenerate categories.js from the current images/ folders
echo "Scanning images/ and regenerating categories.js..."
powershell.exe -ExecutionPolicy Bypass -File scripts/generate-categories.ps1

# 2. Stage all new/modified images and the updated categories.js
git add images/ scripts/categories.js

# 3. Count only the image files being staged
IMAGE_COUNT=$(git diff --cached --name-only | grep -Ei '\.(jpg|jpeg|png|webp|gif|avif)$' | wc -l | tr -d '[:space:]')

if [[ "$IMAGE_COUNT" -eq 0 ]]; then
  echo "No new images to commit. Exiting."
  exit 0
fi

# 4. Commit with auto-generated message
DATE=$(date +"%Y-%m-%d")
COMMIT_MSG="Add ${IMAGE_COUNT} photo(s) — ${DATE}"
echo "Committing: ${COMMIT_MSG}"
git commit -m "$COMMIT_MSG"

# 5. Push to main
echo "Pushing to origin/main..."
git push origin main

echo "Done. ${IMAGE_COUNT} photo(s) pushed on ${DATE}."
