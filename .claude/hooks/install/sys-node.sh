#!/usr/bin/env bash
# Verify Node.js / npx is available (required by 17+ MCP servers).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v npx &>/dev/null; then
  echo "✓ npx found — Node.js $(node --version 2>&1)"
else
  echo "✗ npx not found — 18 MCP servers require Node.js/npx"
  echo "  Install Node.js from https://nodejs.org (LTS recommended)"
  exit 1
fi
