#!/usr/bin/env bash
# Install LightRAG Plus dependencies (graph-based RAG — ~200MB).
# Dir: tools/lightrag-plus  Requires: uv, OPENAI_API_KEY or GEMINI_API_KEY
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

DIR="$ROOT/tools/lightrag-plus"
[ -d "$DIR" ] || { echo "  (tools/lightrag-plus/ not found — skipping)"; exit 0; }

# Auto-create .env so EMBEDDING_BINDING_HOST default is set from the start
if [ ! -f "$DIR/.env" ] && [ -f "$DIR/.env.example" ]; then
  cp "$DIR/.env.example" "$DIR/.env"
  echo "✓ tools/lightrag-plus/.env created — add OPENAI_API_KEY to enable uploads"
fi

command -v uv &>/dev/null || {
  echo "⚠ uv not found — run: cd tools/lightrag-plus && UV_NATIVE_TLS=true uv sync --all-extras"
  exit 0
}

echo "  Installing LightRAG dependencies (~200MB, 2-5 min)..."
if (cd "$DIR" && UV_NATIVE_TLS=true uv sync --all-extras); then
  echo "✓ LightRAG Plus dependencies installed"

  # Self-heal OneDrive mid-install corruption (missing METADATA files)
  if ! (cd "$DIR" && uv pip check >/dev/null 2>&1); then
    echo "  ⚠ Incomplete deps detected — auto-repairing..."
    _site=$(find "$DIR/.venv" -name "site-packages" -type d 2>/dev/null | head -1)
    if [ -n "$_site" ]; then
      for _d in "$_site/"*dist-info; do
        [ -d "$_d" ] && [ ! -f "$_d/METADATA" ] && rm -rf "$_d"
      done
    fi
    (cd "$DIR" && UV_NATIVE_TLS=true uv sync --all-extras >/dev/null 2>&1) || true
    (cd "$DIR" && uv pip install \
      "pydantic>=2.0.0" "json-repair" propcache requests \
      "google-auth>=2.14.1" idna iniconfig pluggy >/dev/null 2>&1) || true
    echo "  ✓ Repair complete"
  fi

  if (cd "$DIR" && uv run python -c "from lightrag import LightRAG, QueryParam" >/dev/null 2>&1); then
    echo "✓ LightRAG import verified"
  else
    echo "⚠ Import check failed — run: cd tools/lightrag-plus && uv pip check"
  fi

  # Provision backends (idempotent — skips if no credentials)
  if [ -f "$DIR/.env" ]; then
    echo "  Provisioning backends..."
    (cd "$DIR" && uv run python provision.py) \
      || echo "⚠ Provision failed — run: cd tools/lightrag-plus && uv run python provision.py"
  fi
else
  echo "⚠ uv sync failed — run: cd tools/lightrag-plus && UV_NATIVE_TLS=true uv sync --all-extras"
fi
