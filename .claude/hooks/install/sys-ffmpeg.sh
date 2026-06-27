#!/usr/bin/env bash
# Install system ffmpeg binary — required by tools/ffmpeg.js and claude-video plugin
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v ffmpeg &>/dev/null; then
  echo "✓ ffmpeg found: $(ffmpeg -version 2>&1 | head -1)"
else
  echo "⚠ ffmpeg not found — installing..."
  if _is_windows; then
    if command -v winget &>/dev/null; then
      echo "  Running: winget install Gyan.FFmpeg"
      winget install Gyan.FFmpeg --silent --accept-package-agreements --accept-source-agreements 2>&1 || true
      if command -v ffmpeg &>/dev/null; then
        echo "✓ ffmpeg installed via winget"
      else
        echo "  winget may have succeeded — restart terminal to pick up PATH"
        echo "  Or download: https://www.gyan.dev/ffmpeg/builds/"
        echo "  Extract to C:\\ffmpeg and add C:\\ffmpeg\\bin to PATH"
      fi
    else
      echo "  winget not found. Install manually:"
      echo "    Download: https://www.gyan.dev/ffmpeg/builds/"
      echo "    Extract to C:\\ffmpeg, add C:\\ffmpeg\\bin to PATH"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      echo "  Running: brew install ffmpeg"
      brew install ffmpeg && echo "✓ ffmpeg installed via brew"
    else
      echo "  brew not found. Install ffmpeg: https://ffmpeg.org/download.html"
    fi
  else
    echo "  Running: apt install ffmpeg"
    if sudo apt install -y ffmpeg -qq 2>/dev/null; then
      echo "✓ ffmpeg installed via apt"
    else
      echo "  apt install failed. Try: sudo dnf install ffmpeg  OR  sudo snap install ffmpeg"
    fi
  fi
fi
