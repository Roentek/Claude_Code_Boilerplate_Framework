#!/usr/bin/env bash
# Install designlang Claude plugin (13 slash commands: /extract /site /grade /battle etc.).
# Source: https://github.com/Manavarya09/design-extract
# Note: CLI install is in cli-designlang.sh — this is the Claude plugin only.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v claude &>/dev/null; then
  if _timeout 60 claude plugin install designlang@designlang 2>/dev/null; then
    echo "  ✓ designlang plugin installed (13 slash commands active)"
  else
    echo "  ⚠ designlang plugin — run in Claude Code: /plugin install designlang@designlang"
  fi
else
  echo "  ⚠ claude CLI not found — run in Claude Code: /plugin install designlang@designlang"
fi
