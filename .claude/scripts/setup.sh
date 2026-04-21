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

# ── 5. Verify uvx is installed (required for google-workspace-mcp + alpaca) ──
echo ""
echo "── uvx (required for google-workspace-mcp and alpaca) ──────"
if command -v uvx &>/dev/null; then
  UVX_VERSION=$(uvx --version 2>&1 | head -1)
  echo "✓ uvx found: $UVX_VERSION"
else
  echo "✗ uvx not found — two MCP servers require it:"
  echo "  • google-workspace-mcp  (Google Gmail, Drive, Sheets, Docs, Calendar)"
  echo "  • alpaca                (Alpaca trading MCP)"
  echo ""
  if [[ "$OSTYPE" != "msys"* && "$OSTYPE" != "cygwin"* && "$OS" != "Windows_NT" ]]; then
    echo "  Install uv/uvx (macOS / Linux):"
    echo "    curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  Then restart your terminal and re-open the project."
  else
    echo "  Install uv/uvx (Windows — PowerShell):"
    echo "    powershell -ExecutionPolicy ByPass -c \"irm https://astral.sh/uv/install.ps1 | iex\""
    echo "  Then restart your terminal and re-open the project."
  fi
  ERRORS=$((ERRORS + 1))
fi

# ── 6. Verify memory MCP server is reachable ───────────────
echo ""
echo "── Memory MCP Server (@modelcontextprotocol/server-memory) ─"
if command -v npx &>/dev/null; then
  echo "✓ npx found — memory MCP server will be launched via npx on first use"
  echo "  Config: .mcp.json → \"memory\" → npx @modelcontextprotocol/server-memory"
  echo "  Reference: https://app.aitmpl.com/component/mcp/integration/memory-integration"
else
  echo "✗ npx not found — memory MCP server requires Node.js/npx"
  echo "  Install Node.js from https://nodejs.org (LTS recommended)"
  ERRORS=$((ERRORS + 1))
fi

# ── 7. Install marketplace plugins ─────────────────────────
echo ""
echo "── Marketplace Plugins ──────────────────────────────────"

if command -v claude &>/dev/null; then
  echo "  Attempting to install third-party plugins via CLI..."
  echo ""

  # ui-ux-pro-max — design intelligence (67 styles, 161 palettes, 57 fonts)
  # Source: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
  if claude plugins install ui-ux-pro-max@ui-ux-pro-max-skill 2>/dev/null; then
    echo "  ✓ ui-ux-pro-max installed"
  else
    echo "  ⚠ ui-ux-pro-max auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill"
    echo "      /plugin install ui-ux-pro-max@ui-ux-pro-max-skill"
  fi

  # andrej-karpathy-skills — coding behavior guidelines
  # Source: https://github.com/forrestchang/andrej-karpathy-skills
  if claude plugins install andrej-karpathy-skills@karpathy-skills 2>/dev/null; then
    echo "  ✓ andrej-karpathy-skills installed"
  else
    echo "  ⚠ andrej-karpathy-skills auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add forrestchang/andrej-karpathy-skills"
    echo "      /plugin install andrej-karpathy-skills@karpathy-skills"
  fi
else
  echo "  claude CLI not found — install third-party plugins manually."
  echo "  Run these slash commands inside a Claude Code chat session:"
  echo ""
  echo "  UI UX Pro Max (design system + 67 styles, 161 palettes, 57 fonts):"
  echo "    /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill"
  echo "    /plugin install ui-ux-pro-max@ui-ux-pro-max-skill"
  echo ""
  echo "  Andrej Karpathy Skills (coding behavior guidelines):"
  echo "    /plugin marketplace add forrestchang/andrej-karpathy-skills"
  echo "    /plugin install andrej-karpathy-skills@karpathy-skills"
fi

echo ""
echo "  Marketplace sources are pre-configured in .claude/settings.json"
echo "  under extraKnownMarketplaces — no manual marketplace registration"
echo "  is needed if using the slash commands above."

# ── 8. Summary ─────────────────────────────────────────────
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