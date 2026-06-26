#!/usr/bin/env bash
# Install claude-mem plugin (persistent memory across sessions; web viewer at localhost:37777).
# Source: https://github.com/thedotmack/claude-mem
# Requires: Bun runtime (run sys-bun.sh first)
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if _install_plugin "claude-mem" "claude-mem"; then
  echo "  Web viewer: http://localhost:37777 (requires Bun — restart terminal first)"
fi
