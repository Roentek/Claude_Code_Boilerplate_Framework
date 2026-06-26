#!/usr/bin/env bash
# Install ponytail plugin — YAGNI/minimal-code discipline for AI agents
# Standalone: bash .claude/hooks/install/plugin-ponytail.sh
#
# Measured impact: -54% LOC, -22% tokens, -20% cost, -27% time vs baseline
# Always-on after install. Use PONYTAIL_DEFAULT_MODE in .env to set level.

. "$(dirname "$0")/lib.sh"

echo "  Installing ponytail plugin (ponytail@ponytail)..."
_install_plugin "ponytail" "ponytail"
