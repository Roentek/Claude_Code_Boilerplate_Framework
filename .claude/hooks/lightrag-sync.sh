#!/bin/bash
# Check tools/lightrag-plus for lightrag-hku updates via PyPI
# Runs silently if up to date; notifies if update available

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LIGHTRAG_DIR="$ROOT/tools/lightrag-plus"
CHECK_SCRIPT="$LIGHTRAG_DIR/check_update.py"

# Exit silently if lightrag not installed
if [ ! -f "$CHECK_SCRIPT" ]; then
  exit 0
fi

if [ ! -f "$LIGHTRAG_DIR/pyproject.toml" ]; then
  exit 0
fi

# Run check (no --upgrade — notify only; user runs --upgrade manually)
OUTPUT=$(cd "$LIGHTRAG_DIR" && uv run python check_update.py 2>/dev/null)
EXIT_CODE=$?

case $EXIT_CODE in
  0)
    # Up to date — silent
    ;;
  2)
    # Major version available
    echo "⚠ lightrag-hku: MAJOR update available — manual review required"
    echo "  Run: cd tools/lightrag-plus && uv run python check_update.py --upgrade"
    echo "  Release notes: https://github.com/HKUDS/LightRAG/releases"
    ;;
  *)
    # Minor/patch update available
    echo "$OUTPUT"
    echo "  Run: cd tools/lightrag-plus && uv run python check_update.py --upgrade"
    ;;
esac

exit 0
