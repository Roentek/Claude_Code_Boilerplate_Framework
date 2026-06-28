#!/usr/bin/env bash
# Install Higgsfield CLI — @higgsfield/cli
# Standalone: bash .claude/hooks/install/cli-higgsfield.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

echo "→ Installing Higgsfield CLI..."
if command -v higgsfield &>/dev/null; then
  echo "  · higgsfield already installed ($(higgsfield version 2>/dev/null | head -1 || echo 'unknown version'))"
else
  _timeout 120 npm install -g @higgsfield/cli >/dev/null 2>&1 && \
    echo "  ✓ @higgsfield/cli installed" || \
    echo "  ⚠ @higgsfield/cli install failed — run: npm install -g @higgsfield/cli"
fi
echo "  → Auth: higgsfield auth login (browser OAuth, one-time)"
