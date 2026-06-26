#!/usr/bin/env bash
# Install ui-ux-pro-max plugin (67 styles, 161 palettes, 57 fonts).
# Source: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "ui-ux-pro-max" "ui-ux-pro-max-skill"
