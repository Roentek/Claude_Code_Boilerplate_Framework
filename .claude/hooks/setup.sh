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
  if [ -f "$ROOT/.claude/hooks/pre-commit.sh" ]; then
    chmod +x "$ROOT/.claude/hooks/pre-commit.sh"
    echo "✓ pre-commit.sh marked executable"
  fi
  if [ -f "$ROOT/.claude/hooks/setup.sh" ]; then
    chmod +x "$ROOT/.claude/hooks/setup.sh"
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
  echo "  Required by: context-monitor statusline, ui-ux-pro-max design search scripts"
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

# ── 5. Verify uvx (google-workspace-mcp + alpaca) ──────────
echo ""
echo "── uvx ──────────────────────────────────────────────────"
echo "   Required by: google-workspace-mcp, alpaca"
if command -v uvx &>/dev/null; then
  UVX_VERSION=$(uvx --version 2>&1 | head -1)
  echo "✓ uvx found: $UVX_VERSION"
else
  echo "✗ uvx not found — two MCP servers require it:"
  echo "  • google-workspace-mcp  (Gmail, Drive, Sheets, Docs, Calendar)"
  echo "  • alpaca                (Alpaca trading)"
  echo ""
  if [[ "$OSTYPE" != "msys"* && "$OSTYPE" != "cygwin"* && "$OS" != "Windows_NT" ]]; then
    echo "  Install (macOS / Linux):"
    echo "    curl -LsSf https://astral.sh/uv/install.sh | sh"
  else
    echo "  Install (Windows — PowerShell):"
    echo "    powershell -ExecutionPolicy ByPass -c \"irm https://astral.sh/uv/install.ps1 | iex\""
  fi
  echo "  Then restart your terminal and re-open the project."
  ERRORS=$((ERRORS + 1))
fi

# ── 6. Verify Node.js / npx (15 npx-based MCP servers) ────
echo ""
echo "── Node.js / npx ────────────────────────────────────────"
echo "   Required by: memory, supabase-mcp, openrouter-mcp, kie-ai, tavily-mcp,"
echo "   trigger, pinecone-mcp, vapi-mcp, n8n-mcp, apify, zep-mcp, canva-dev,"
echo "   21st-dev-magic, playwright-mcp, firecrawl-mcp"
if command -v npx &>/dev/null; then
  NODE_VERSION=$(node --version 2>&1)
  echo "✓ npx found — Node.js $NODE_VERSION"
else
  echo "✗ npx not found — 15 MCP servers require Node.js/npx"
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

  # impeccable — frontend design skill (23 commands + anti-pattern detection)
  # Source: https://github.com/pbakaus/impeccable
  if claude plugins install impeccable@impeccable 2>/dev/null; then
    echo "  ✓ impeccable installed"
  else
    echo "  ⚠ impeccable auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add pbakaus/impeccable"
    echo "      /plugin install impeccable@impeccable"
  fi
else
  echo "  claude CLI not found — install third-party plugins manually."
  echo "  Run these slash commands inside a Claude Code chat session:"
  echo ""
  echo "  UI UX Pro Max (design system — 67 styles, 161 palettes, 57 fonts):"
  echo "    /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill"
  echo "    /plugin install ui-ux-pro-max@ui-ux-pro-max-skill"
  echo ""
  echo "  Andrej Karpathy Skills (coding behavior guidelines):"
  echo "    /plugin marketplace add forrestchang/andrej-karpathy-skills"
  echo "    /plugin install andrej-karpathy-skills@karpathy-skills"
  echo ""
  echo "  Impeccable (frontend design — 23 commands + anti-pattern detection):"
  echo "    /plugin marketplace add pbakaus/impeccable"
  echo "    /plugin install impeccable@impeccable"
fi

echo ""
echo "  Marketplace sources are pre-configured in .claude/settings.json"
echo "  under extraKnownMarketplaces — no manual marketplace registration"
echo "  is needed if using the slash commands above."

# ── 8. Install project skills to ~/.claude/skills/ ─────────
echo ""
echo "── Project Skills (~/.claude/skills/) ──────────────────"
SKILLS_SRC="$ROOT/.claude/skills"
SKILLS_DEST="$HOME/.claude/skills"
SKILLS_INSTALLED=0

if [ -d "$SKILLS_SRC" ]; then
  for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    if [ -f "$skill_file" ]; then
      dest_dir="$SKILLS_DEST/$skill_name"
      # Copy the entire skill directory (SKILL.md + any docs/, examples/, templates/)
      rm -rf "$dest_dir"
      cp -r "$skill_dir" "$dest_dir"
      echo "  ✓ $skill_name → ~/.claude/skills/$skill_name/"
      SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
    fi
  done
  if [ $SKILLS_INSTALLED -eq 0 ]; then
    echo "  (no skills found in .claude/skills/)"
  else
    echo "  $SKILLS_INSTALLED skill(s) installed. Restart Claude Code to activate."
  fi
else
  echo "  .claude/skills/ not found — skipping"
fi

# ── 9. Install npm dependencies + Playwright browser ───────
echo ""
echo "── npm Dependencies + Playwright Browser ────────────────"
if [ -f "$ROOT/package.json" ]; then
  if command -v npm &>/dev/null; then
    if (cd "$ROOT" && npm install --silent 2>/dev/null); then
      echo "✓ npm install complete"
    else
      echo "✗ npm install failed — run: npm install"
      ERRORS=$((ERRORS + 1))
    fi
    # Install Playwright Chromium browser for tools/playwright.js
    if (cd "$ROOT" && npx playwright install chromium 2>/dev/null); then
      echo "✓ Playwright Chromium browser installed"
    else
      echo "⚠ Playwright Chromium install failed — run: npx playwright install chromium"
    fi
  else
    echo "✗ npm not found — install Node.js first, then run: npm install"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  (no package.json found — skipping)"
fi

# ── 10. Install global CLI tools ────────────────────────────
echo ""
echo "── Global CLI Tools ─────────────────────────────────────"

# skillui — design system extractor for /skillui skill
# Source: https://github.com/amaancoderx/npxskillui
if command -v skillui &>/dev/null; then
  echo "✓ skillui already installed"
elif command -v npm &>/dev/null; then
  echo "  Installing skillui globally..."
  if npm install -g skillui --silent 2>/dev/null; then
    echo "✓ skillui installed (usage: skillui --url <url> | --dir <path> | --repo <github-url>)"
  else
    echo "⚠ skillui install failed — run manually: npm install -g skillui"
  fi
else
  echo "⚠ npm not found — cannot install skillui (optional: npm install -g skillui)"
fi

# firecrawl-cli — web scraping CLI for /firecrawl skill + workflows/web-scraping.md
# Also pairs with firecrawl-mcp as backup. Source: https://github.com/firecrawl/cli
if command -v firecrawl &>/dev/null; then
  FC_VERSION=$(firecrawl --version 2>&1 | head -1)
  echo "✓ firecrawl already installed: $FC_VERSION"
elif command -v npm &>/dev/null; then
  echo "  Installing firecrawl-cli globally..."
  if npm install -g firecrawl-cli --silent 2>/dev/null; then
    echo "✓ firecrawl-cli installed"
    echo "  ⚠ Add FIRECRAWL_API_KEY to .env — get it at: https://www.firecrawl.dev/app/api-keys"
  else
    echo "✗ firecrawl-cli install failed — run manually: npm install -g firecrawl-cli"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "✗ npm not found — install Node.js, then run: npm install -g firecrawl-cli"
  ERRORS=$((ERRORS + 1))
fi

# ── 11. Authentication reminders (interactive — cannot automate) ──
echo ""
echo "── Authentication Reminders ─────────────────────────────"
echo "  These require a one-time manual step before first use:"
echo ""
echo "  Trigger.dev MCP"
echo "    Run: npx trigger.dev@latest login"
echo "    (opens browser — authenticates the trigger MCP server)"
echo ""
echo "  Google Workspace MCP"
echo "    Set GOOGLE_OAUTH_CLIENT_ID + GOOGLE_OAUTH_CLIENT_SECRET in"
echo "    .claude/settings.local.json, then open Claude Code — a browser"
echo "    OAuth consent window opens automatically on first tool call."
echo ""
echo "  Canva MCP"
echo "    No keys needed. A browser OAuth window opens automatically"
echo "    on first use of the canva-dev MCP server."
echo ""
echo "  All other MCP servers (supabase, openrouter, kie-ai, tavily,"
echo "  pinecone, vapi, n8n, apify, monet, stitch, 21st-dev, firecrawl)"
echo "  require API keys in .claude/settings.local.json → env block."
echo "  See .claude/settings.local.json.example → __activation_guide"
echo "  for where to obtain each key."

# ── 12. Install pre-commit doc-sync hook ────────────────────
echo ""
echo "── Git Pre-Commit Hook (doc-sync) ───────────────────────"
HOOKS_DIR="$ROOT/.git/hooks"
PRE_COMMIT_DEST="$HOOKS_DIR/pre-commit"

if [ -f "$PRE_COMMIT_DEST" ] && ! grep -q "pre-commit.sh" "$PRE_COMMIT_DEST" 2>/dev/null; then
  echo "⚠  A pre-commit hook already exists from another source."
  echo "   To enable doc-sync, manually append to $PRE_COMMIT_DEST:"
  echo "     \"$ROOT/.claude/hooks/pre-commit.sh\""
else
  mkdir -p "$HOOKS_DIR"
  # Write a thin wrapper so .git/hooks/pre-commit never needs updating;
  # the actual hook logic lives in the version-controlled .claude/hooks/ file.
  printf '#!/bin/bash\nexec "$(git rev-parse --show-toplevel)/.claude/hooks/pre-commit.sh"\n' > "$PRE_COMMIT_DEST"
  if [[ "$OSTYPE" != "msys"* && "$OSTYPE" != "cygwin"* && "$OS" != "Windows_NT" ]]; then
    chmod +x "$PRE_COMMIT_DEST"
  fi
  echo "✓ pre-commit doc-sync hook installed → .git/hooks/pre-commit"
fi

# ── 13. Summary ────────────────────────────────────────────
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
