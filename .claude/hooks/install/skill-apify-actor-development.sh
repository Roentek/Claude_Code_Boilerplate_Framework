#!/usr/bin/env bash
# Install apify-actor-development skill (create, debug, deploy Actors in JS/TS/Python).
# Marketplace: https://github.com/apify/agent-skills
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_skill "apify-actor-development" "apify-agent-skills"
