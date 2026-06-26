#!/usr/bin/env bash
# Make hook scripts executable (Unix/macOS only — no-op on Windows).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if _is_windows; then
  echo "✓ Windows detected — skipping chmod"
  exit 0
fi

for f in stop.sh pre-commit.sh autosync-docs.sh setup.sh mcp-cleanup.sh; do
  fp="$ROOT/.claude/hooks/$f"
  [ -f "$fp" ] && chmod +x "$fp" && echo "✓ $f marked executable"
done
