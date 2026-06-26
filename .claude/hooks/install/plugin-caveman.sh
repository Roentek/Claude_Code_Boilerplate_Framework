#!/usr/bin/env bash
# Install caveman plugin (75% token reduction via telegraphic compression).
# Source: https://github.com/JuliusBrussee/caveman
# Commands: /caveman /caveman-commit /caveman-review /caveman-stats /caveman-compress /cavecrew
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "caveman" "caveman"
