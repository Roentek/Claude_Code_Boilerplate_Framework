#!/usr/bin/env bash
# Install cli-anything plugin (AI-native CLIs for 50+ apps — GIMP, Blender, LibreOffice...).
# Source: https://github.com/HKUDS/CLI-Anything
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "cli-anything" "cli-anything"
