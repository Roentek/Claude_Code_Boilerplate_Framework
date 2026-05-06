#!/bin/bash
# Auto-sync OpenSpace submodule with upstream
# Runs on every Stop hook to keep OpenSpace current

OPENSPACE_DIR="tools/openspace"
UPSTREAM_REPO="https://github.com/HKUDS/OpenSpace.git"
UPSTREAM_BRANCH="main"

# Check if OpenSpace exists as a git submodule
if [ ! -f ".gitmodules" ] || ! grep -q "path = $OPENSPACE_DIR" .gitmodules; then
  echo "⚠ OpenSpace is not configured as a submodule — skipping sync"
  echo "  Run: git submodule add $UPSTREAM_REPO $OPENSPACE_DIR"
  exit 0
fi

# Check if submodule is initialized
if [ ! -d "$OPENSPACE_DIR/.git" ] && [ ! -f "$OPENSPACE_DIR/.git" ]; then
  echo "📦 Initializing OpenSpace submodule..."
  git submodule update --init --recursive "$OPENSPACE_DIR"
  exit 0
fi

# Check for uncommitted changes in submodule
cd "$OPENSPACE_DIR" || exit 1

if [ -n "$(git status --porcelain)" ]; then
  echo "⚠ OpenSpace submodule has uncommitted changes — skipping sync"
  cd - > /dev/null
  exit 0
fi

# Fetch latest from upstream
git fetch origin "$UPSTREAM_BRANCH" --quiet

# Get current and remote commit hashes
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/$UPSTREAM_BRANCH)

if [ "$LOCAL" = "$REMOTE" ]; then
  # Already up to date — silent success
  cd - > /dev/null
  exit 0
fi

# Pull latest changes
echo "📥 Syncing OpenSpace submodule with upstream..."
git checkout "$UPSTREAM_BRANCH" --quiet
git pull --ff-only origin "$UPSTREAM_BRANCH" --quiet

if [ $? -eq 0 ]; then
  echo "✓ OpenSpace submodule updated to latest"
  cd - > /dev/null

  # Update the parent repo to track the new submodule commit
  git add "$OPENSPACE_DIR"
  echo "  (Submodule pointer updated in parent repo — commit when ready)"
else
  echo "✗ Failed to sync OpenSpace submodule"
  cd - > /dev/null
  exit 1
fi
