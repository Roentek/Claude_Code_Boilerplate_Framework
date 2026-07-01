#!/usr/bin/env bash
# Install OpenSpace (self-evolving skill system) from tools/openspace/ git submodule.
# Source: HKUDS/OpenSpace  Requires: uv (preferred) or pip
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

DIR="$ROOT/tools/openspace"

# Init submodule if not done yet
if [ -f "$ROOT/.gitmodules" ] && grep -q "path = tools/openspace" "$ROOT/.gitmodules"; then
  if [ ! -d "$DIR/.git" ] && [ ! -f "$DIR/.git" ]; then
    echo "  Initializing OpenSpace submodule..."
    (cd "$ROOT" && git submodule update --init --recursive tools/openspace)
  fi
fi

[ -d "$DIR" ] || { echo "  (tools/openspace/ not found — skipping)"; exit 0; }

# Detect platform extra
case "$(uname -s 2>/dev/null)" in
  Darwin*) OS_EXTRA="macos" ;;
  Linux*)  OS_EXTRA="linux" ;;
  *)       OS_EXTRA="windows" ;;
esac

if command -v uv &>/dev/null; then
  echo "  Installing OpenSpace [$OS_EXTRA] via uv pip..."
  if (cd "$DIR" && uv pip install -e ".[$OS_EXTRA]" 2>&1 | tail -3); then
    echo "✓ OpenSpace installed"
    command -v openspace-mcp &>/dev/null \
      && echo "✓ openspace-mcp command available" \
      || echo "⚠ openspace-mcp not in PATH — restart shell"
  else
    echo "⚠ OpenSpace install failed — run: cd tools/openspace && uv pip install -e '.[$OS_EXTRA]'"
  fi
else
  # Fallback to system pip
  for _py in python3 py python; do command -v "$_py" &>/dev/null && { PY="$_py"; break; }; done
  if [ -n "$PY" ]; then
    (cd "$DIR" && $PY -m pip install -e . --quiet 2>&1) \
      && echo "✓ OpenSpace installed via pip (install uv for platform extras)" \
      || echo "⚠ pip install failed — run: cd tools/openspace && pip install -e ."
  else
    echo "⚠ uv and Python not found — install uv: https://docs.astral.sh/uv/"
    exit 1
  fi
fi

# Dashboard frontend (optional — requires Node.js ≥ 20)
FRONTEND="$DIR/frontend"
if [ -d "$FRONTEND" ] && command -v npm &>/dev/null; then
  NODE_MAJOR=$(node --version 2>&1 | grep -oE '[0-9]+' | head -1)
  if [ "$NODE_MAJOR" -ge 20 ]; then
    if [ ! -f "$FRONTEND/.env" ] && [ -f "$FRONTEND/.env.example" ]; then
      cp "$FRONTEND/.env.example" "$FRONTEND/.env"
      sed -i.bak 's/VITE_PORT=3888/VITE_PORT=3789/' "$FRONTEND/.env" 2>/dev/null
      rm -f "$FRONTEND/.env.bak"
      echo "  ✓ frontend/.env created (port aligned to 3789)"
    fi
    if [ ! -d "$FRONTEND/node_modules" ]; then
      echo "  Installing OpenSpace frontend deps (~30MB)..."
      (cd "$FRONTEND" && npm install) \
        || echo "  ⚠ Frontend npm install failed — run: cd tools/openspace/frontend && npm install"
    else
      echo "  ✓ Frontend dependencies already installed"
    fi
    # Build static assets so the backend at port 3789 can serve them immediately
    if [ ! -d "$FRONTEND/dist" ]; then
      echo "  Building OpenSpace frontend (first-time build)..."
      (cd "$FRONTEND" && npm run build) \
        && echo "  ✓ Frontend built — http://127.0.0.1:3789/dashboard ready after backend start" \
        || echo "  ⚠ Frontend build failed — run: cd tools/openspace/frontend && npm run build"
    else
      echo "  ✓ Frontend already built (dist/ exists)"
    fi
  else
    echo "  ⚠ Frontend requires Node.js ≥ 20 (found v$NODE_MAJOR)"
  fi
fi
