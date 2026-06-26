#!/usr/bin/env bash
# Install cc-gemini-plugin (Gemini bridge for large-context codebase exploration).
# Source: https://github.com/thepushkarp/cc-gemini-plugin
# Requires: GEMINI_API_KEY in .claude/settings.local.json
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "cc-gemini-plugin" "cc-gemini-plugin"
