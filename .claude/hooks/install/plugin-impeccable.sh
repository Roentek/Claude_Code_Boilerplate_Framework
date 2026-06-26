#!/usr/bin/env bash
# Install impeccable plugin (23 frontend design commands + anti-pattern detection).
# Source: https://github.com/pbakaus/impeccable
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "impeccable" "impeccable"
