#!/usr/bin/env bash
# Install apify-actorization skill (convert existing code to Apify Actors).
# Marketplace: https://github.com/apify/agent-skills
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_skill "apify-actorization" "apify-agent-skills"
