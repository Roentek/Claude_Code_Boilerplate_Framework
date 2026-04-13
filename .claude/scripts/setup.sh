#!/bin/bash
# ============================================================
# Claude Code Boilerplate Framework — First-Time Setup
# Runs once via the "Setup" hook when Claude Code initializes
# the project for the first time on a new machine.
# ============================================================

MARKER=".claude/.setup-complete"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Skip if already completed on this machine
if [ -f "$ROOT/$MARKER" ]; then
  exit 0
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Claude Code Boilerplate — First-Time Setup         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

ERRORS=0

# ── 1. Make hooks executable (Unix / macOS only) ───────────
if [[ "$OSTYPE" != "msys"* && "$OSTYPE" != "cygwin"* && "$OS" != "Windows_NT" ]]; then
  if [ -f "$ROOT/.claude/hooks/stop.sh" ]; then
    chmod +x "$ROOT/.claude/hooks/stop.sh"
    echo "✓ stop.sh marked executable"
  fi
  if [ -f "$ROOT/.claude/scripts/setup.sh" ]; then
    chmod +x "$ROOT/.claude/scripts/setup.sh"
  fi
else
  echo "✓ Windows detected — skipping chmod"
fi

# ── 2. Verify Python is available ──────────────────────────
PYTHON_CMD=""
if command -v python3 &>/dev/null; then
  PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
  PYTHON_CMD="python"
else
  echo "✗ Python not found — install Python 3.8+ and add it to PATH"
  echo "  The context-monitor statusline will not work without Python."
  ERRORS=$((ERRORS + 1))
fi

if [ -n "$PYTHON_CMD" ]; then
  PY_VERSION=$("$PYTHON_CMD" --version 2>&1 | grep -oP '\d+\.\d+')
  echo "✓ Python found: $PYTHON_CMD ($PY_VERSION)"
fi

# ── 3. Verify context-monitor.py is present ────────────────
if [ -f "$ROOT/.claude/scripts/context-monitor.py" ]; then
  echo "✓ context-monitor.py found"
else
  echo "✗ .claude/scripts/context-monitor.py is missing"
  echo "  Re-run: npx claude-code-templates@latest --setting statusline/context-monitor"
  ERRORS=$((ERRORS + 1))
fi

# ── 4. Create .env from .env.example if not present ────────
if [ ! -f "$ROOT/.env" ]; then
  if [ -f "$ROOT/.env.example" ]; then
    cp "$ROOT/.env.example" "$ROOT/.env"
    echo "✓ .env created from .env.example — fill in your API keys"
  else
    echo "⚠ No .env.example found — create .env manually"
  fi
else
  echo "✓ .env already exists"
fi

# ── 5. Summary ─────────────────────────────────────────────
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✓ Setup complete. Context monitor statusline is ready."
  # Write marker so this doesn't run again on this machine
  touch "$ROOT/$MARKER"
else
  echo "✗ Setup finished with $ERRORS error(s). Fix the issues above, then"
  echo "  delete .claude/.setup-complete (if it was created) and re-open."
fi
echo ""