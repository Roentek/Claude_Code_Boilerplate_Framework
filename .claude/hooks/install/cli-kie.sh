#!/usr/bin/env bash
# Install @felores/kie-cli (AI media generation CLI — Midjourney, Veo3, Suno, ElevenLabs...).
# Source: https://github.com/felores/kie-cli-mcp  Requires: KIE_AI_API_KEY
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v kie-cli &>/dev/null; then
  echo "✓ kie-cli already installed"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g @felores/kie-cli"; exit 0; }
echo "  Installing @felores/kie-cli globally..."
if _timeout 120 npm install -g @felores/kie-cli; then
  echo "✓ kie-cli installed (usage: kie-cli <tool> --prompt '...' --json)"
  echo "  ⚠ Set KIE_AI_API_KEY in .claude/settings.local.json or OS env"
else
  echo "⚠ kie-cli install failed — run: npm install -g @felores/kie-cli"
fi
