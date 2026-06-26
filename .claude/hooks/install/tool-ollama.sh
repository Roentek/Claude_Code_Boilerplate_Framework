#!/usr/bin/env bash
# Install Ollama (local LLM runtime) and pull llama3.2 (~2GB).
# Used by: LightRAG local inference mode
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

_pull_model() {
  local bin="${1:-ollama}"
  if "$bin" list 2>/dev/null | grep -q "llama3.2"; then
    echo "✓ llama3.2 already pulled"
  else
    echo "  Pulling llama3.2 (~2GB)..."
    if "$bin" pull llama3.2; then echo "✓ llama3.2 pulled"
    else echo "⚠ Pull failed — run: ollama pull llama3.2"; fi
  fi
}

if command -v ollama &>/dev/null; then
  echo "✓ Ollama already installed"
  _pull_model ollama
  exit 0
fi

if _is_windows; then
  if command -v winget &>/dev/null; then
    echo "  Installing Ollama via winget..."
    winget install --id Ollama.Ollama --accept-package-agreements --accept-source-agreements
    # winget doesn't update PATH in current session — check known install location
    OLLAMA_BIN=""
    if [ -n "$LOCALAPPDATA" ]; then
      _lad="$(cygpath "$LOCALAPPDATA" 2>/dev/null || echo "$LOCALAPPDATA" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|')"
      [ -f "$_lad/Programs/Ollama/ollama.exe" ] && OLLAMA_BIN="$_lad/Programs/Ollama/ollama.exe"
    fi
    command -v ollama &>/dev/null && OLLAMA_BIN="ollama"
    if [ -n "$OLLAMA_BIN" ]; then
      echo "✓ Ollama installed"
      _pull_model "$OLLAMA_BIN"
    else
      echo "  ⚠ Ollama installed but not in PATH — restart terminal then run: ollama pull llama3.2"
    fi
  else
    echo "  winget not found — download Ollama: https://ollama.com/download/OllamaSetup.exe"
    echo "  Then run: ollama pull llama3.2"
  fi
else
  echo "  Installing Ollama..."
  if curl -fsSL https://ollama.com/install.sh | sh; then
    echo "✓ Ollama installed"
    _pull_model ollama
  else
    echo "⚠ Ollama install failed — visit: https://ollama.com"
  fi
fi
