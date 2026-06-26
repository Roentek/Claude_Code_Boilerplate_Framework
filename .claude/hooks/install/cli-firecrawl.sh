#!/usr/bin/env bash
# Install firecrawl-cli (web scraping CLI — pairs with firecrawl-mcp as backup).
# Source: https://github.com/firecrawl/cli  Requires: FIRECRAWL_API_KEY
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v firecrawl &>/dev/null; then
  echo "✓ firecrawl already installed: $(firecrawl --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "✗ npm not found — install Node.js first"; exit 1; }
echo "  Installing firecrawl-cli globally..."
if _timeout 120 npm install -g firecrawl-cli; then
  echo "✓ firecrawl-cli installed"
  echo "  ⚠ Add FIRECRAWL_API_KEY to .env: https://www.firecrawl.dev/app/api-keys"
else
  echo "✗ firecrawl-cli install failed — run: npm install -g firecrawl-cli"
  exit 1
fi
