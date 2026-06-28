#!/usr/bin/env bash
# Register MCPVault (filesystem-based Obsidian MCP) at user scope.
# No Obsidian app or Local REST API plugin required.
# Uses --scope user so vault is accessible across all Claude Code projects.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Step: MCPVault MCP Server ==="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
VAULT_PATH="$PROJECT_ROOT/vault"

# Resolve absolute path (cross-platform)
if _is_windows; then
  # pwd -W prints Windows path then Unix path on some Git Bash versions — take first line only
  VAULT_ABS="$(cd "$VAULT_PATH" && pwd -W 2>/dev/null | head -1 || cd "$VAULT_PATH" && pwd)"
else
  VAULT_ABS="$(cd "$VAULT_PATH" && pwd)"
fi

# Check if already registered
if claude mcp list 2>/dev/null | grep -q "obsidian-vault"; then
  echo "  [skip] obsidian-vault MCP already registered"
  echo "  Path: $(claude mcp get obsidian-vault 2>/dev/null | grep -i path || echo 'run: claude mcp get obsidian-vault')"
else
  echo "  Registering MCPVault at user scope..."
  echo "  Vault path: $VAULT_ABS"

  claude mcp add obsidian-vault -s user -- npx -y "@bitbonsai/mcpvault@latest" "$VAULT_ABS" 2>/dev/null && {
    echo "  [ok] obsidian-vault MCP registered (user scope)"
    echo "  Available in all Claude Code projects on this machine"
  } || {
    echo "  [warn] claude CLI not available or MCP registration failed"
    echo "  Manual: claude mcp add obsidian-vault -s user -- npx -y @bitbonsai/mcpvault@latest \"$VAULT_ABS\""
  }
fi

echo ""
echo "  MCPVault tools: search_notes, read_note, create_note, update_note, read_multiple_notes"
echo "  Verify: claude mcp list | grep obsidian"
echo "  Test (in session): 'List all notes in wiki/'"
