#!/usr/bin/env bash
# Install pre-commit hook that delegates to .claude/hooks/pre-commit.sh.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

HOOKS_DIR="$ROOT/.git/hooks"
DEST="$HOOKS_DIR/pre-commit"

if [ -f "$DEST" ] && ! grep -q "pre-commit.sh" "$DEST" 2>/dev/null; then
  echo "⚠  Existing pre-commit hook from another source — append manually:"
  echo "   \"$ROOT/.claude/hooks/pre-commit.sh\""
  exit 0
fi

mkdir -p "$HOOKS_DIR"
printf '#!/bin/bash\nexec "$(git rev-parse --show-toplevel)/.claude/hooks/pre-commit.sh"\n' > "$DEST"
_is_windows || chmod +x "$DEST"
echo "✓ pre-commit doc-sync hook installed → .git/hooks/pre-commit"
