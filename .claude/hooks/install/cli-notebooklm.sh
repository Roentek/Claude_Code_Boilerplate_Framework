#!/usr/bin/env bash
# Install notebooklm-mcp-cli (Google NotebookLM CLI + MCP server via 'nlm' command).
# Source: https://github.com/jacob-bd/notebooklm-mcp-cli  Auth: nlm login
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v nlm &>/dev/null; then
  echo "✓ notebooklm-mcp-cli already installed: $(nlm --version 2>&1 | head -1)"
  exit 0
fi
command -v uv &>/dev/null || { echo "⚠ uv not found — run: uv tool install notebooklm-mcp-cli"; exit 0; }
echo "  Installing notebooklm-mcp-cli via uv..."
if _timeout 120 uv tool install notebooklm-mcp-cli; then
  echo "✓ notebooklm-mcp-cli installed (CLI: nlm)"
  echo "  ⚠ Run 'nlm login' to authenticate with Google before first use"
else
  echo "⚠ install failed — run: uv tool install notebooklm-mcp-cli"
fi
