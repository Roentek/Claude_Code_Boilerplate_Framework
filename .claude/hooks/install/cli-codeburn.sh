#!/usr/bin/env bash
# Install codeburn CLI (AI spend analytics across 31 tools including Claude Code).
# Source: https://github.com/getagentseal/codeburn
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v codeburn &>/dev/null; then
  echo "✓ codeburn already installed: $(codeburn --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g codeburn"; exit 0; }
echo "  Installing codeburn globally..."
if _timeout 120 npm install -g codeburn; then
  echo "✓ codeburn installed (usage: codeburn  |  codeburn status)"
else
  echo "⚠ codeburn install failed — run: npm install -g codeburn"
fi
