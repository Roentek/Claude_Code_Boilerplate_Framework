#!/usr/bin/env bash
# Install Vercel CLI for deployments, previews, env management, and local dev.
# Source: https://github.com/vercel/vercel  Auth: vercel login
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v vercel &>/dev/null; then
  echo "✓ vercel already installed: $(vercel --version 2>&1 | head -1)"
  exit 0
fi
command -v npm &>/dev/null || { echo "⚠ npm not found — run: npm install -g vercel"; exit 0; }
echo "  Installing vercel CLI globally..."
if _timeout 120 npm install -g vercel; then
  echo "✓ vercel installed (usage: vercel deploy | vercel dev | vercel ls)"
  echo "  ⚠ Run 'vercel login' to authenticate before first use"
else
  echo "⚠ vercel install failed — run: npm install -g vercel"
fi
