#!/usr/bin/env bash
# Install Google Gemini CLI (used by /three-brain + cc-gemini-plugin).
# Source: https://github.com/google-gemini/gemini-cli  Requires: GEMINI_API_KEY
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v gemini &>/dev/null; then
  echo "✓ gemini-cli already installed: $(gemini --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g @google/gemini-cli@latest"; exit 0; }
echo "  Installing gemini-cli globally (~50MB)..."
if _timeout 120 npm install -g @google/gemini-cli@latest; then
  echo "✓ gemini-cli installed"
  echo "  ⚠ Add GEMINI_API_KEY to .env — free key: https://aistudio.google.com/apikey"
else
  echo "⚠ gemini-cli install failed — run: npm install -g @google/gemini-cli@latest"
fi
