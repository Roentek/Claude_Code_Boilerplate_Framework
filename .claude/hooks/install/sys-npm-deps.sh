#!/usr/bin/env bash
# Install project npm dependencies + Playwright Chromium browser.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if [ ! -f "$ROOT/package.json" ]; then
  echo "  (no package.json found — skipping)"
  exit 0
fi

if ! command -v npm &>/dev/null; then
  echo "✗ npm not found — install Node.js first, then run: npm install"
  exit 1
fi

echo "  Installing project npm dependencies..."
if (cd "$ROOT" && npm install); then
  echo "✓ npm install complete"
else
  echo "✗ npm install failed — run: npm install"
  exit 1
fi

echo "  Installing Playwright Chromium (~150MB)..."
if (cd "$ROOT" && NODE_TLS_REJECT_UNAUTHORIZED=0 npx playwright install chromium); then
  echo "✓ Playwright Chromium installed"
else
  echo "⚠ Playwright Chromium install failed — run: NODE_TLS_REJECT_UNAUTHORIZED=0 npx playwright install chromium"
fi
