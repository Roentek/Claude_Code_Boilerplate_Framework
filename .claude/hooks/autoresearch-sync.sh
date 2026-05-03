#!/bin/bash
# Auto-sync tools/autoresearch with upstream karpathy/autoresearch
# Runs silently if no changes; pulls updates if available

set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AUTORESEARCH_DIR="$ROOT/tools/autoresearch"
UPSTREAM_REPO="https://github.com/karpathy/autoresearch.git"

# Exit silently if directory doesn't exist
if [ ! -d "$AUTORESEARCH_DIR" ]; then
  exit 0
fi

# Check if it's a git repository
if [ ! -d "$AUTORESEARCH_DIR/.git" ]; then
  # Not a git repo — initialize it with upstream remote
  echo "Initializing tools/autoresearch as git repository..."
  (cd "$AUTORESEARCH_DIR" && git init -q)
  (cd "$AUTORESEARCH_DIR" && git remote add origin "$UPSTREAM_REPO")
  (cd "$AUTORESEARCH_DIR" && git fetch origin main -q 2>/dev/null || true)
  (cd "$AUTORESEARCH_DIR" && git branch -M main)
  (cd "$AUTORESEARCH_DIR" && git reset --hard origin/main -q 2>/dev/null || true)
  echo "✓ tools/autoresearch synced with upstream"
  exit 0
fi

# Fetch from upstream (silent)
(cd "$AUTORESEARCH_DIR" && git fetch origin main -q 2>/dev/null || exit 0)

# Check if local is behind remote
LOCAL_COMMIT=$(cd "$AUTORESEARCH_DIR" && git rev-parse HEAD 2>/dev/null || echo "")
REMOTE_COMMIT=$(cd "$AUTORESEARCH_DIR" && git rev-parse origin/main 2>/dev/null || echo "")

if [ -z "$LOCAL_COMMIT" ] || [ -z "$REMOTE_COMMIT" ]; then
  # Can't determine commits — skip silently
  exit 0
fi

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
  # Already up to date — exit silently
  exit 0
fi

# Check if there are local uncommitted changes
if [ -n "$(cd "$AUTORESEARCH_DIR" && git status --porcelain 2>/dev/null)" ]; then
  echo "⚠ tools/autoresearch has local changes — skipping sync"
  echo "  Commit or stash changes, then manually pull: cd tools/autoresearch && git pull origin main"
  exit 0
fi

# Pull updates
echo "Updating tools/autoresearch from upstream..."
if (cd "$AUTORESEARCH_DIR" && git pull origin main -q 2>/dev/null); then
  echo "✓ tools/autoresearch synced with upstream ($(cd "$AUTORESEARCH_DIR" && git log -1 --format='%h - %s')))"
else
  echo "⚠ Failed to sync tools/autoresearch — run manually: cd tools/autoresearch && git pull origin main"
fi
