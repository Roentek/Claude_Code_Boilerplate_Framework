#!/usr/bin/env bash
# Install context-mode plugin (98% context reduction via sandboxing; SQLite FTS5 session continuity).
# Source: https://github.com/mksglu/context-mode
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if ! _install_plugin "context-mode" "context-mode"; then
  exit 1
fi

echo "  Installing better-sqlite3 (FTS5 session continuity)..."
PLUGIN_DIR=""
USER_HOME="$(_user_home)"
for candidate in \
  "$USER_HOME/.claude/plugins/cache/context-mode/context-mode/"*/ \
  "$USER_HOME/.claude/plugins/marketplaces/context-mode"; do
  if [[ -f "$candidate/package.json" ]]; then
    PLUGIN_DIR="$candidate"
    break
  fi
done

if [[ -n "$PLUGIN_DIR" ]]; then
  if NODE_TLS_REJECT_UNAUTHORIZED=0 npm install better-sqlite3 \
      --include=optional --prefix "$PLUGIN_DIR" --no-package-lock 2>/dev/null; then
    echo "  ✓ better-sqlite3 installed — FTS5 session continuity active"
  else
    echo "  ⚠ better-sqlite3 failed — run /context-mode:ctx-doctor after restart"
  fi
else
  echo "  ⚠ context-mode plugin dir not found — run /context-mode:ctx-doctor after restart"
fi
