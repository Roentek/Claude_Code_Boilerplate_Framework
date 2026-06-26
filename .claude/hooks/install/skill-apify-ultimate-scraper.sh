#!/usr/bin/env bash
# Install apify-ultimate-scraper skill (universal web scraper, 130+ Actors).
# Marketplace: https://github.com/apify/agent-skills
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_skill "apify-ultimate-scraper" "apify-agent-skills"
