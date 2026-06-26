#!/usr/bin/env bash
# Install designlang CLI (DTCG tokens, Tailwind, shadcn, Figma vars, WCAG scores).
# Source: https://github.com/Manavarya09/design-extract
# Note: --ignore-scripts skips Playwright browser download (fails on corporate SSL proxy).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v designlang &>/dev/null; then
  echo "✓ designlang already installed: $(designlang --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g designlang --ignore-scripts"; exit 0; }
echo "  Installing designlang globally..."
if _timeout 120 npm install -g designlang --ignore-scripts; then
  echo "✓ designlang installed (usage: designlang <url>)"
  echo "  Note: Playwright browser skipped. Run if needed: npx playwright install chromium"
else
  echo "⚠ designlang install failed — run: npm install -g designlang --ignore-scripts"
fi
