#!/usr/bin/env bash
# Install Bun runtime (required by claude-mem worker; 3-5x faster context-mode sandbox).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v bun &>/dev/null; then
  echo "✓ Bun already installed: $(bun --version)"
  exit 0
fi

if _is_windows; then
  echo "  Installing Bun via official PowerShell script..."
  if powershell -NoProfile -ExecutionPolicy Bypass -Command "irm bun.sh/install.ps1 | iex" 2>/dev/null; then
    echo "  ✓ Bun installed — restart terminal + Claude Code to pick up PATH (~\.bun\bin)"
  else
    echo "  ⚠ Bun install failed. Run manually: powershell -c \"irm bun.sh/install.ps1 | iex\""
  fi
else
  if curl -fsSL https://bun.sh/install | bash 2>/dev/null; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    echo "  ✓ Bun installed"
  else
    echo "  ⚠ Bun install failed. Run: curl -fsSL https://bun.sh/install | bash"
  fi
fi
