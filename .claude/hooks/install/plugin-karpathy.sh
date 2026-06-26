#!/usr/bin/env bash
# Install andrej-karpathy-skills plugin (coding behavior guidelines).
# Source: https://github.com/forrestchang/andrej-karpathy-skills
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"
_install_plugin "andrej-karpathy-skills" "karpathy-skills"
