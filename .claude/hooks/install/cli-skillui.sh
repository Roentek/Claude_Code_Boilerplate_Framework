#!/usr/bin/env bash
# Install skillui CLI (design system extractor — URL, dir, or GitHub repo).
# Source: https://github.com/amaancoderx/npxskillui
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v skillui &>/dev/null; then
  echo "✓ skillui already installed"
  exit 0
fi
command -v npm &>/dev/null || { echo "✗ npm not found — install Node.js first"; exit 1; }
echo "  Installing skillui globally..."
if _timeout 120 npm install -g skillui; then
  echo "✓ skillui installed (usage: skillui --url <url>)"
else
  echo "⚠ skillui install failed — run: npm install -g skillui"
fi
