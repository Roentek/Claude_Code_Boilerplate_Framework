#!/usr/bin/env bash
# Verify GitHub CLI (gh) — required by github@claude-plugins-official plugin.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v gh &>/dev/null; then
  echo "✓ gh found: $(gh --version 2>&1 | head -1)"
else
  echo "⚠ gh not found — GitHub plugin Bash(gh ...) tools won't work"
  if _is_windows; then
    echo "  Install: winget install GitHub.cli   OR   scoop install gh"
    echo "  Download: https://cli.github.com/"
  else
    echo "  macOS:  brew install gh"
    echo "  Linux:  https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  fi
  echo "  Then authenticate: gh auth login"
fi
