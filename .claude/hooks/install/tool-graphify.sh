#!/usr/bin/env bash
# Install graphify — codebase knowledge graph (AST-parse → queryable graph)
# Standalone: bash .claude/hooks/install/tool-graphify.sh

. "$(dirname "$0")/lib.sh"

echo "  Installing graphify (graphifyy[mcp] via uv tool)..."

if ! command -v uv &>/dev/null; then
  echo "  ⚠ uv not found — install uv first: curl -LsSf https://astral.sh/uv/install.sh | sh"
  exit 1
fi

if uv tool install "graphifyy[mcp]" >/dev/null 2>&1; then
  echo "  ✓ graphifyy[mcp] installed"
else
  echo "  ⚠ graphifyy[mcp] install failed — try manually: uv tool install 'graphifyy[mcp]'"
fi

# Register skill with Claude Code — writes ~/.claude/skills/graphify/SKILL.md + references/
echo "  Registering graphify skill..."
if command -v graphify &>/dev/null; then
  if graphify install 2>/dev/null; then
    echo "  ✓ graphify skill registered globally"
  else
    echo "  ⚠ graphify skill install failed — run manually: graphify install"
  fi
else
  echo "  · graphify CLI not in PATH yet — re-open terminal, then run: graphify install"
fi

echo ""
echo "  Usage: open Claude Code in any repo, run /graphify . to build graph"
echo "  MCP server (graphify-mcp in .mcp.json) activates after first graph build"
