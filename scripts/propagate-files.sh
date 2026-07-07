#!/usr/bin/env bash
# propagate-files.sh -- Copy file(s) to one or all org repos, committing to main.
#
# Usage:
#   propagate-files.sh
#     --source <path>           File or directory to copy from this repo
#     --destination <path>      Where to place it in target repo(s)
#     [--repo <name>]           Single target repo
#     [--all]                   All org repos
#     [--exclude <name>]        Repo to skip (repeatable: --exclude a --exclude b)
#     [--message <msg>]         Commit message (default: "Propagate <source>")
#     [--branch <name>]         Target branch (default: main)
#
# Requires GH_TOKEN env var set to a PAT with repo scope.
# The ORG env var must also be set.
#
# Examples:
#   propagate-files.sh --source workflows/ocr-review.yml \
#     --destination .github/workflows/ocr-review.yml \
#     --repo feedBack --message "Add code review"
#
#   propagate-files.sh --source templates/ --destination .github/ \
#     --all --exclude community-code-review \
#     --message "Sync org templates"
set -euo pipefail

# ── Parse args ─────────────────────────────────────────────────────────────
SOURCE=""
DEST=""
TARGET_REPO=""
TARGET_ALL=false
EXCLUDES=()
MESSAGE=""
BRANCH="main"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)      SOURCE="$2";       shift 2 ;;
    --destination) DEST="$2";         shift 2 ;;
    --repo)        TARGET_REPO="$2";  shift 2 ;;
    --all)         TARGET_ALL=true;   shift   ;;
    --exclude)     EXCLUDES+=("$2");  shift 2 ;;
    --message)     MESSAGE="$2";      shift 2 ;;
    --branch)      BRANCH="$2";       shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${ORG:?ORG is required}"
: "${SOURCE:?--source is required}"
: "${DEST:?--destination is required}"

if [ -z "$MESSAGE" ]; then
  MESSAGE="Propagate ${SOURCE}"
fi

# ── Gather target repos ─────────────────────────────────────────────────────
REPOS=()
if [ -n "$TARGET_REPO" ]; then
  REPOS=("$TARGET_REPO")
elif [ "$TARGET_ALL" = true ]; then
  mapfile -t REPOS < <(gh repo list "$ORG" --limit 500 --json name --jq '.[].name')
else
  echo "Specify --repo <name> or --all"
  exit 1
fi

# ── Build exclude regex ──────────────────────────────────────────────────────
EXCLUDE_PATTERN=""
for ex in "${EXCLUDES[@]}"; do
  EXCLUDE_PATTERN="${EXCLUDE_PATTERN}|${ex}"
done
EXCLUDE_PATTERN="${EXCLUDE_PATTERN#|}"

# ── Propagate ────────────────────────────────────────────────────────────────
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd /tmp

success=0 skipped=0 failed=0
for repo in "${REPOS[@]}"; do
  # Check exclusion
  if [ -n "$EXCLUDE_PATTERN" ] && [[ "$repo" =~ ^($EXCLUDE_PATTERN)$ ]]; then
    echo "  - $repo: excluded"; ((skipped++)); continue
  fi

  # Clone
  if ! gh repo clone "$ORG/$repo" "/tmp/propagate-$repo" -- --depth 1 2>/dev/null; then
    echo "  ✗ $repo: clone failed"; ((failed++)); continue
  fi

  TARGET="/tmp/propagate-$repo"
  mkdir -p "$(dirname "$TARGET/$DEST")"

  # Copy — support both file and directory sources
  if [ -d "$ROOT/$SOURCE" ]; then
    rm -rf "${TARGET:?}/$DEST"
    cp -r "$ROOT/$SOURCE" "$TARGET/$DEST"
  else
    cp "$ROOT/$SOURCE" "$TARGET/$DEST"
  fi

  cd "$TARGET"
  git config user.name "web-flow"
  git config user.email "noreply@github.com"
  git add -A

  if git diff --cached --quiet; then
    echo "  - $repo: no change"; ((skipped++)); cd /; rm -rf "$TARGET"; continue
  fi

  if git commit -m "$MESSAGE" >/dev/null 2>&1; then
    if git push origin "HEAD:$BRANCH" 2>/dev/null; then
      echo "  ✓ $repo: updated"; ((success++))
    else
      echo "  ✗ $repo: push failed"; ((failed++))
    fi
  else
    echo "  - $repo: commit failed (unexpected)"; ((failed++))
  fi

  cd /; rm -rf "$TARGET"
done

# ── Report ────────────────────────────────────────────────────────────────────
echo ""
echo "Done: $success updated, $skipped skipped, $failed failed"
[ "$failed" -eq 0 ] || exit 1
