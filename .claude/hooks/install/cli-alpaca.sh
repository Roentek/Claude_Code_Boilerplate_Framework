#!/usr/bin/env bash
# Install Alpaca CLI — trade stocks/crypto, market data, account management from CLI.
# Designed for AI agents, scripts, and automation pipelines (no confirmation prompts).
# Source: https://github.com/alpacahq/cli  Auth: alpaca profile login OR env vars
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v alpaca &>/dev/null; then
  echo "✓ alpaca CLI already installed: $(alpaca version 2>&1 | head -1)"
  exit 0
fi

echo "  Installing Alpaca CLI..."

if _is_windows; then
  # Windows: use Go if available, else print manual instructions
  if command -v go &>/dev/null; then
    echo "  Installing via go install..."
    if _timeout 120 go install github.com/alpacahq/cli/cmd/alpaca@latest; then
      echo "✓ alpaca CLI installed (go install)"
    else
      echo "⚠ go install failed — download binary from https://github.com/alpacahq/cli/releases"
    fi
  else
    echo "⚠ Go not found. Install alpaca CLI manually:"
    echo "    Option 1: Install Go (go.dev/dl), then: go install github.com/alpacahq/cli/cmd/alpaca@latest"
    echo "    Option 2: Download binary from https://github.com/alpacahq/cli/releases"
    echo "    Set ALPACA_API_KEY + ALPACA_SECRET_KEY env vars after install."
  fi
elif command -v brew &>/dev/null; then
  # macOS: use Homebrew tap
  echo "  Installing via brew..."
  if _timeout 120 brew install alpacahq/tap/cli; then
    echo "✓ alpaca CLI installed (brew)"
  else
    echo "⚠ brew install failed — try: go install github.com/alpacahq/cli/cmd/alpaca@latest"
  fi
elif command -v go &>/dev/null; then
  # Linux: use go install
  echo "  Installing via go install..."
  if _timeout 120 go install github.com/alpacahq/cli/cmd/alpaca@latest; then
    echo "✓ alpaca CLI installed (go install)"
  else
    echo "⚠ go install failed — download binary from https://github.com/alpacahq/cli/releases"
  fi
else
  echo "⚠ Neither brew nor go found — install alpaca CLI manually:"
  echo "    go install github.com/alpacahq/cli/cmd/alpaca@latest"
  echo "    or download from https://github.com/alpacahq/cli/releases"
fi

if command -v alpaca &>/dev/null; then
  echo "  ⚠ Auth: alpaca profile login (OAuth, paper trading only)"
  echo "    Or set: ALPACA_API_KEY + ALPACA_SECRET_KEY env vars"
  echo "    Paper keys: alpaca.markets → Paper Trading → API Keys (free, no real money)"
  echo "  ⚠ Default mode is PAPER trading — add ALPACA_LIVE_TRADE=true for live"
fi
