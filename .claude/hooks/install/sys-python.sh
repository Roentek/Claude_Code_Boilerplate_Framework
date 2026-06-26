#!/usr/bin/env bash
# Verify Python 3 is available (skips Windows Store fake alias).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

PYTHON_CMD=""
for _py in python3 python py; do
  if _ver=$("$_py" --version 2>&1) && echo "$_ver" | grep -qiE '^python [0-9]'; then
    PYTHON_CMD="$_py"
    PY_VERSION=$(echo "$_ver" | grep -oE '[0-9]+\.[0-9]+' | head -1)
    break
  fi
done

if [ -n "$PYTHON_CMD" ]; then
  echo "✓ Python found: $PYTHON_CMD ($PY_VERSION)"
else
  echo "✗ Python not found — install Python 3.8+ and add it to PATH"
  echo "  Required by: context-monitor statusline, ui-ux-pro-max design search scripts"
  exit 1
fi
