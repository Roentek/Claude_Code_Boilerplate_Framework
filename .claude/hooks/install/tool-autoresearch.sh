#!/usr/bin/env bash
# Install autoresearch dependencies (autonomous ML experiments — ~3GB PyTorch).
# Source: karpathy/autoresearch  Requires: NVIDIA GPU, uv
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

DIR="$ROOT/tools/autoresearch"
[ -d "$DIR" ] || { echo "  (tools/autoresearch/ not found — skipping)"; exit 0; }
command -v uv &>/dev/null || {
  echo "⚠ uv not found — run: cd tools/autoresearch && UV_NATIVE_TLS=true uv sync --all-extras"
  exit 0
}

echo "  Installing autoresearch dependencies (~3GB PyTorch — takes 5-15 min)..."
if (cd "$DIR" && UV_NATIVE_TLS=true uv sync --all-extras); then
  echo "✓ autoresearch dependencies installed"
  echo "  Verifying installation..."
  (cd "$DIR" && uv run python verify_setup.py 2>&1) || echo "⚠ Verify failed — re-run: cd tools/autoresearch && uv run python verify_setup.py"
  echo "  Next: cd tools/autoresearch && uv run prepare.py && uv run train.py"
else
  echo "⚠ uv sync incomplete — run: cd tools/autoresearch && UV_NATIVE_TLS=true uv sync --all-extras"
fi
