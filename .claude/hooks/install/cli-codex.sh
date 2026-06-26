#!/usr/bin/env bash
# Install OpenAI Codex CLI (used by /three-brain + codex plugin).
# Source: https://github.com/openai/codex-plugin-cc  Requires: OPENAI_API_KEY
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v codex &>/dev/null; then
  echo "✓ codex-cli already installed: $(codex --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g @openai/codex@latest"; exit 0; }
echo "  Installing codex-cli globally (~50MB)..."
if _timeout 120 npm install -g @openai/codex@latest; then
  echo "✓ codex-cli installed"
  echo "  ⚠ Add OPENAI_API_KEY to .env and settings.local.json"
else
  echo "⚠ codex-cli install failed — run: npm install -g @openai/codex@latest"
fi
