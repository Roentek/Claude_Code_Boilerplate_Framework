#!/usr/bin/env bash
# Install llmfit — right-size LLM models to your hardware. CLI + MCP server.
# Source: https://github.com/AlexsJones/llmfit  No auth required.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v llmfit &>/dev/null; then
  echo "✓ llmfit already installed: $(llmfit --version 2>&1 | head -1)"
  exit 0
fi
command -v uv &>/dev/null || { echo "⚠ uv not found — run: uv tool install llmfit"; exit 0; }
echo "  Installing llmfit via uv..."
if _timeout 120 uv tool install llmfit; then
  echo "✓ llmfit installed (CLI: llmfit, MCP: llmfit serve --mcp)"
  echo "  Optional: set LOCALMAXXING_API_KEY for community benchmark data"
else
  echo "⚠ install failed — run: uv tool install llmfit"
fi
