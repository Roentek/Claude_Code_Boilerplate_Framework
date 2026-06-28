#!/usr/bin/env bash
# Install notebooklm-py (Google NotebookLM CLI + MCP server via 'notebooklm' command).
# Source: https://github.com/teng-lin/notebooklm-py  Auth: notebooklm login
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v notebooklm &>/dev/null; then
  echo "✓ notebooklm-py already installed: $(notebooklm --version 2>&1 | head -1)"
  exit 0
fi
command -v uv &>/dev/null || { echo "⚠ uv not found — run: uv tool install 'notebooklm-py[browser]'"; exit 0; }
echo "  Installing notebooklm-py via uv..."
if _timeout 180 uv tool install "notebooklm-py[browser]"; then
  echo "✓ notebooklm-py installed (CLI: notebooklm, MCP: notebooklm-mcp)"
  echo "  ⚠ Run 'notebooklm login' to authenticate with Google before first use"
else
  echo "⚠ install failed — run: uv tool install 'notebooklm-py[browser]'"
fi
