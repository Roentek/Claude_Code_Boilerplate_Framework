#!/usr/bin/env bash
# Install apify-actor-commands skill (/create-actor and other Actor slash commands).
# Marketplace: https://github.com/apify/agent-skills
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_skill "apify-actor-commands" "apify-agent-skills"
