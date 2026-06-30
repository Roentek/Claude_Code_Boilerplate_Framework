#!/usr/bin/env bash
# Install @21st-dev/cli — setup helper for 21st.dev Magic MCP configuration.
# Source: https://github.com/21st-dev/magic-mcp  API key: 21st.dev/magic/console
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v magic &>/dev/null; then
  echo "✓ @21st-dev/magic already installed: $(npx @21st-dev/magic@latest --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g @21st-dev/cli"; exit 0; }
echo "  Installing @21st-dev/cli globally..."
if _timeout 120 npm install -g @21st-dev/cli; then
  echo "✓ @21st-dev/cli installed"
  echo "  ⚠ Get API key: https://21st.dev/magic/console"
  echo "  ⚠ Add TWENTYFIRST_DEV_MAGIC_API_KEY to .claude/settings.local.json"
  echo "  ⚠ MCP (21st-dev-magic) already wired — restart Claude Code to activate"
else
  echo "⚠ @21st-dev/cli install failed — run: npm install -g @21st-dev/cli"
fi
