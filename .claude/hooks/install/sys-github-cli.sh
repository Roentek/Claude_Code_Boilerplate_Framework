#!/usr/bin/env bash
# Install GitHub CLI (gh) — CLI-first for GitHub operations; plugin is MCP fallback.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v gh &>/dev/null; then
  echo "✓ gh found: $(gh --version 2>&1 | head -1)"
else
  echo "⚠ gh not found — installing GitHub CLI..."
  if _is_windows; then
    if command -v winget &>/dev/null; then
      echo "  Running: winget install GitHub.cli --silent"
      winget install GitHub.cli --silent --accept-package-agreements --accept-source-agreements 2>&1 || true
      # PATH not updated in-session after winget — check common install location
      GH_BIN="$LOCALAPPDATA/Programs/GitHub CLI/gh.exe"
      if [ -f "$GH_BIN" ] || command -v gh &>/dev/null; then
        echo "✓ gh installed via winget"
        echo "  Authenticate: gh auth login"
      else
        echo "  winget install may have succeeded — open a new terminal and run: gh auth login"
        echo "  Or download: https://cli.github.com/"
      fi
    else
      echo "  winget not found. Install manually:"
      echo "    Download: https://cli.github.com/"
      echo "    Or: scoop install gh"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      echo "  Running: brew install gh"
      brew install gh && echo "✓ gh installed via brew"
    else
      echo "  brew not found. Install: https://cli.github.com/"
    fi
  else
    # Linux — official install script
    echo "  Running GitHub CLI install script..."
    if curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null && \
       echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
       sudo apt update -qq 2>/dev/null && sudo apt install gh -y -qq 2>/dev/null; then
      echo "✓ gh installed via apt"
    else
      echo "  apt install failed. Try: sudo dnf install gh  OR  sudo zypper install gh"
      echo "  Full guide: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    fi
  fi
  echo "  After install, authenticate: gh auth login"
fi
