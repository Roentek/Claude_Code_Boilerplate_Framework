#!/usr/bin/env bash
# Install Supabase CLI — local dev stack, migrations, type generation, edge functions.
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

if command -v supabase &>/dev/null; then
  echo "✓ supabase found: $(supabase --version 2>&1 | head -1)"
else
  echo "⚠ supabase not found — installing Supabase CLI..."
  if _is_windows; then
    if command -v scoop &>/dev/null; then
      echo "  Running: scoop bucket add supabase + scoop install supabase"
      scoop bucket add supabase https://github.com/supabase/scoop-bucket.git 2>/dev/null || true
      if scoop install supabase 2>&1 && command -v supabase &>/dev/null; then
        echo "✓ supabase installed via scoop"
      else
        echo "  scoop install failed — trying npm..."
        if command -v npm &>/dev/null && npm install -g supabase 2>&1; then
          echo "✓ supabase installed via npm"
        else
          echo "  Manual install: https://supabase.com/docs/guides/local-development/cli/getting-started"
        fi
      fi
    elif command -v npm &>/dev/null; then
      echo "  Running: npm install -g supabase"
      npm install -g supabase 2>&1 && echo "✓ supabase installed via npm" || true
    else
      echo "  Install manually (scoop preferred on Windows):"
      echo "    scoop bucket add supabase https://github.com/supabase/scoop-bucket.git"
      echo "    scoop install supabase"
      echo "    Or: npm install -g supabase"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      echo "  Running: brew install supabase/tap/supabase"
      brew install supabase/tap/supabase && echo "✓ supabase installed via brew" || true
    elif command -v npm &>/dev/null; then
      echo "  Running: npm install -g supabase"
      npm install -g supabase && echo "✓ supabase installed via npm" || true
    else
      echo "  Install manually:"
      echo "    brew install supabase/tap/supabase"
      echo "    Or: npm install -g supabase"
    fi
  else
    # Linux — npm global (most reliable; no apt package available)
    if command -v npm &>/dev/null; then
      echo "  Running: npm install -g supabase"
      npm install -g supabase && echo "✓ supabase installed via npm" || true
    else
      echo "  Install manually: npm install -g supabase"
      echo "  Or see: https://supabase.com/docs/guides/local-development/cli/getting-started"
    fi
  fi
  echo "  After install, authenticate: supabase login"
fi
