#!/usr/bin/env bash
# Install Higgsfield AI plugin — higgsfield@higgsfield (higgsfield-ai/skills)
# Standalone: bash .claude/hooks/install/plugin-higgsfield.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

_install_plugin higgsfield higgsfield-ai/skills
