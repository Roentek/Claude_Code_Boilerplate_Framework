#!/usr/bin/env bash
# Verify context-monitor.py statusline script is present.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if [ -f "$ROOT/.claude/scripts/context-monitor.py" ]; then
  echo "✓ context-monitor.py found"
else
  echo "✗ .claude/scripts/context-monitor.py is missing"
  echo "  Re-run: npx claude-code-templates@latest --setting statusline/context-monitor"
  exit 1
fi
