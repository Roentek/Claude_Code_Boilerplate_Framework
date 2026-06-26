#!/usr/bin/env bash
# Verify uvx is available (required by google-workspace-mcp, alpaca, notebooklm-mcp).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v uvx &>/dev/null; then
  echo "✓ uvx found: $(uvx --version 2>&1 | head -1)"
else
  echo "✗ uvx not found — google-workspace-mcp, alpaca, and notebooklm-mcp require it"
  if _is_windows; then
    echo "  Install (PowerShell): powershell -ExecutionPolicy ByPass -c \"irm https://astral.sh/uv/install.ps1 | iex\""
  else
    echo "  Install: curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
  exit 1
fi
