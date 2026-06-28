#!/usr/bin/env bash
# Install Higgsfield AI plugin — higgsfield@higgsfield (higgsfield-ai/skills)
# Standalone: bash .claude/hooks/install/plugin-higgsfield.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# ponytail: plugin source type "./" not yet supported by Claude Code — install manually when fixed:
# claude plugin marketplace add higgsfield-ai/skills && claude plugin install higgsfield@higgsfield
echo "  ⚠ higgsfield plugin: marketplace added but source type './' unsupported in current Claude Code"
echo "    CLI (@higgsfield/cli) is fully functional — plugin skills are bonus"
echo "    Run: claude plugin marketplace add higgsfield-ai/skills"
