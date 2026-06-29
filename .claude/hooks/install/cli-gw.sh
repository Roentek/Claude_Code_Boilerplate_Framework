#!/usr/bin/env bash
# Install gw — Google Workspace CLI for Claude Code (Gmail, Drive, Calendar).
# Source: https://github.com/googleworkspace/cli  Auth: gw auth login
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v gw &>/dev/null; then
  echo "✓ gw already installed: $(gw --version 2>&1 | head -1)"
  exit 0
fi
command -v uv &>/dev/null || { echo "⚠ uv not found — run: uv tool install google-workspace-cli"; exit 0; }
echo "  Installing google-workspace-cli via uv..."
if _timeout 120 uv tool install google-workspace-cli; then
  echo "✓ gw installed (CLI: gw, MCP fallback: google-workspace-mcp)"
  echo "  ⚠ Run 'gw auth login' to authenticate with Google before first use"
else
  echo "⚠ install failed — run: uv tool install google-workspace-cli"
fi
