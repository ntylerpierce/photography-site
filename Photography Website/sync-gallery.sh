#!/usr/bin/env bash
set -euo pipefail

# Scans images/, diffs against scripts/categories.js, regenerates it if anything
# changed, then stages → commits → pushes.  Exits cleanly if nothing changed.
# Replaces push-photos.sh and rename-category.sh — run this for everything.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PS_DIFF="scripts/.sync-diff.ps1"
DIFF_OUT="scripts/.sync-diff-out.txt"
trap 'rm -f "$PS_DIFF" "$DIFF_OUT"' EXIT

echo "Scanning images/ folder..."

# ── 1. Write the PowerShell diff script ────────────────────────────────────
cat > "$PS_DIFF" << 'PSEOF'
$ErrorActionPreference = 'Stop'

$imageExts  = @('.jpg', '.jpeg', '.png', '.webp', '.gif', '.avif')
$catsJsPath = 'scripts\categories.js'
$imagesDir  = 'images'

# ── Parse categories.js ──────────────────────────────────────────────────────
$content = Get-Content $catsJsPath -Raw

# Locate each id: "..." and its file position
$idMatches = [regex]::Matches($content, 'id:\s*"([^"]+)"')
$curCatIds = @($idMatches | ForEach-Object { $_.Groups[1].Value })

# For each category block (from its id: to the next id:), collect photo srcs.
# Use src: "..." instead of cover: "..." so the cover field is never double-counted.
$catBlocks = @{}
for ($i = 0; $i -lt $idMatches.Count; $i++) {
    $catId = $curCatIds[$i]
    $start = $idMatches[$i].Index
    $end   = if ($i + 1 -lt $idMatches.Count) { $idMatches[$i + 1].Index } else { $content.Length }
    $block = $content.Substring($start, $end - $start)
    $srcs  = @([regex]::Matches($block, 'src:\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
    $catBlocks[$catId] = $srcs
}
$curCatSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$curCatIds)

# ── Scan filesystem ──────────────────────────────────────────────────────────
$fsDirs = @()
if (Test-Path $imagesDir) {
    $fsDirs = @(Get-ChildItem $imagesDir -Directory | Sort-Object Name | Select-Object -ExpandProperty Name)
}
$fsCatSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$fsDirs)

$fsPhotos = @{}
foreach ($cat in $fsDirs) {
    $files = @(
        Get-ChildItem (Join-Path $imagesDir $cat) -File |
        Where-Object { $imageExts -contains $_.Extension.ToLower() } |
        Sort-Object Name |
        ForEach-Object { "images/$cat/$($_.Name)" }
    )
    $fsPhotos[$cat] = [System.Collections.Generic.HashSet[string]]::new([string[]]$files)
}

# ── Category-level diff ───────────────────────────────────────────────────────
$addedCats   = @($fsDirs    | Where-Object { -not $curCatSet.Contains($_) })
$removedCats = @($curCatIds | Where-Object { -not $fsCatSet.Contains($_)  })

# ── Photo-level diff (existing categories only) ───────────────────────────────
$addedPhotos   = @{}
$removedPhotos = @{}
foreach ($cat in $fsDirs) {
    if (-not $catBlocks.ContainsKey($cat)) { continue }
    $curSet  = [System.Collections.Generic.HashSet[string]]::new([string[]]@($catBlocks[$cat]))
    $fsSet   = $fsPhotos[$cat]
    $added   = @($fsSet  | Where-Object { -not $curSet.Contains($_) })
    $removed = @($curSet | Where-Object { -not $fsSet.Contains($_)  })
    if ($added.Count   -gt 0) { $addedPhotos[$cat]   = $added   }
    if ($removed.Count -gt 0) { $removedPhotos[$cat] = $removed }
}

# ── Totals ────────────────────────────────────────────────────────────────────
$changed = ($addedCats.Count + $removedCats.Count +
            $addedPhotos.Count + $removedPhotos.Count) -gt 0

$photoAdded   = 0
$photoRemoved = 0
foreach ($v in $addedPhotos.Values)   { $photoAdded   += $v.Count }
foreach ($v in $removedPhotos.Values) { $photoRemoved += $v.Count }
# Photos inside newly-added categories also count as added
foreach ($cat in $addedCats) {
    if ($fsPhotos.ContainsKey($cat)) { $photoAdded += $fsPhotos[$cat].Count }
}

# ── Commit message ────────────────────────────────────────────────────────────
$parts = @()
if ($addedCats.Count -gt 0) {
    $noun = if ($addedCats.Count -eq 1) { 'category' } else { 'categories' }
    $parts += "added $($addedCats.Count) $noun ($($addedCats -join ', '))"
}
if ($removedCats.Count -gt 0) {
    $noun = if ($removedCats.Count -eq 1) { 'category' } else { 'categories' }
    $parts += "removed $($removedCats.Count) $noun ($($removedCats -join ', '))"
}
if ($photoAdded   -gt 0) { $parts += "added $photoAdded photo$(if ($photoAdded   -ne 1) { 's' })" }
if ($photoRemoved -gt 0) { $parts += "removed $photoRemoved photo$(if ($photoRemoved -ne 1) { 's' })" }

$today     = (Get-Date).ToString('yyyy-MM-dd')
$commitMsg = if ($parts.Count -gt 0) {
    "Sync gallery: $($parts -join '; ') -- $today"
} else {
    "Sync gallery: updates -- $today"
}

# ── Output (line-keyed so bash can parse it) ──────────────────────────────────
Write-Output "CHANGED:$($changed.ToString().ToLower())"

foreach ($cat in $addedCats)   { Write-Output "DISPLAY:+ category added:   $cat" }
foreach ($cat in $removedCats) { Write-Output "DISPLAY:- category removed: $cat" }
foreach ($cat in $addedPhotos.Keys) {
    Write-Output "DISPLAY:+ $($addedPhotos[$cat].Count) photo(s) added in:     $cat"
}
foreach ($cat in $removedPhotos.Keys) {
    Write-Output "DISPLAY:- $($removedPhotos[$cat].Count) photo(s) removed from: $cat"
}

Write-Output "COMMIT_MSG:$commitMsg"
PSEOF

# ── 2. Run the diff ─────────────────────────────────────────────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "scripts/.sync-diff.ps1" > "$DIFF_OUT"

# ── 3. Check whether anything changed ───────────────────────────────────────
CHANGED=$(grep '^CHANGED:' "$DIFF_OUT" | cut -d: -f2 | tr -d '[:space:]\r')

if [[ "$CHANGED" != "true" ]]; then
  echo "No changes detected — nothing to update."
  exit 0
fi

# ── 4. Show change summary ──────────────────────────────────────────────────
echo "Changes detected:"
grep '^DISPLAY:' "$DIFF_OUT" | sed 's/^DISPLAY:/  /' | tr -d '\r'
echo ""

COMMIT_MSG=$(grep '^COMMIT_MSG:' "$DIFF_OUT" | cut -d: -f2- | tr -d '\r')

# ── 5. Regenerate scripts/categories.js ─────────────────────────────────────
echo "Regenerating scripts/categories.js..."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/generate-categories.ps1

# ── 6. Stage all changes ─────────────────────────────────────────────────────
git add images/ scripts/categories.js

STAGED=$(git diff --cached --name-only 2>/dev/null || true)
if [[ -z "$STAGED" ]]; then
  echo "Nothing staged after regeneration — already up to date."
  exit 0
fi

# ── 7. Commit ────────────────────────────────────────────────────────────────
echo "Committing: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# ── 8. Push to GitHub ────────────────────────────────────────────────────────
echo "Pushing to origin/main..."
git push origin main

echo ""
echo "Done. Gallery synced on $(date +%Y-%m-%d)."
