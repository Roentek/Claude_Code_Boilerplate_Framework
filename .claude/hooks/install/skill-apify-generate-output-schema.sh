#!/usr/bin/env bash
# Install apify-generate-output-schema skill (auto-generate Actor output schemas).
# Marketplace: https://github.com/apify/agent-skills
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_skill "apify-generate-output-schema" "apify-agent-skills"
