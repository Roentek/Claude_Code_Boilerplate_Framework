#!/usr/bin/env bash
# Install codex plugin (OpenAI Codex rescue + diagnosis subagent).
# Source: https://github.com/openai/codex-plugin-cc
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "codex" "openai-codex"
