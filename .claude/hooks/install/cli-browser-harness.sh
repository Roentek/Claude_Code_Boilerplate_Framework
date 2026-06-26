#!/usr/bin/env bash
# Install browser-harness CLI (real Chrome CDP automation via DevTools Protocol).
# Source: https://github.com/browser-use/browser-harness  Requires: Chrome with remote debugging
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v browser-harness &>/dev/null; then
  echo "✓ browser-harness already installed: $(browser-harness --version 2>&1 | head -1)"
  exit 0
fi
command -v uv &>/dev/null || { echo "⚠ uv not found — run: uv tool install --python 3.12 browser-harness"; exit 0; }
echo "  Installing browser-harness via uv (~10MB)..."
if UV_NATIVE_TLS=true _timeout 180 uv tool install --python 3.12 --upgrade --force browser-harness; then
  echo "✓ browser-harness installed"
  # Generate live SKILL.md (content updates with each CLI release)
  USER_HOME="$(_user_home)"
  BH_SKILL_DIR="$USER_HOME/.claude/skills/browser-harness"
  mkdir -p "$BH_SKILL_DIR"
  browser-harness skill > "$BH_SKILL_DIR/SKILL.md" 2>/dev/null \
    && echo "  ✓ browser-harness skill registered at $BH_SKILL_DIR/SKILL.md"
  echo "  ⚠ Enable Chrome remote debugging: chrome://inspect/#remote-debugging"
else
  echo "⚠ install failed — run: UV_NATIVE_TLS=true uv tool install --python 3.12 browser-harness"
fi
