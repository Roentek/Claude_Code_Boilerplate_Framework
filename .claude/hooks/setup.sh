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

# Cross-platform timeout — GNU timeout absent on Windows; fall back to
# background-kill pattern using bash's $SECONDS built-in.
# Usage: _timeout <seconds> <cmd> [args...]
_timeout() {
  local secs=$1; shift
  "$@" &
  local pid=$! deadline=$((SECONDS + secs))
  while kill -0 "$pid" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do
    sleep 1
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; return 124
  fi
  wait "$pid"
}

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
  if [ -f "$ROOT/.claude/hooks/autosync-docs.sh" ]; then
    chmod +x "$ROOT/.claude/hooks/autosync-docs.sh"
    echo "✓ autosync-docs.sh marked executable"
  fi
  if [ -f "$ROOT/.claude/hooks/setup.sh" ]; then
    chmod +x "$ROOT/.claude/hooks/setup.sh"
  fi
else
  echo "✓ Windows detected — skipping chmod"
fi

# ── 2. Verify Python is available ──────────────────────────
# Use actual execution test — Windows has a fake python3.exe Store alias
# (exit 9009/49) that fools command -v but isn't real Python.
PYTHON_CMD=""
for _py in python3 python py; do
  if _ver=$("$_py" --version 2>&1) && echo "$_ver" | grep -qiE '^python [0-9]'; then
    PYTHON_CMD="$_py"
    PY_VERSION=$(echo "$_ver" | grep -oE '[0-9]+\.[0-9]+' | head -1)
    break
  fi
done

if [ -n "$PYTHON_CMD" ]; then
  echo "✓ Python found: $PYTHON_CMD ($PY_VERSION)"
else
  echo "✗ Python not found — install Python 3.8+ and add it to PATH"
  echo "  Required by: context-monitor statusline, ui-ux-pro-max design search scripts"
  ERRORS=$((ERRORS + 1))
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

# ── 4a. Configure OpenSpace paths (platform-specific) ──────
# Auto-detect platform and set correct paths for OpenSpace in .env
if [ -f "$ROOT/.env" ]; then
  # Detect user's home directory (works on all platforms)
  if [[ -n "$HOME" ]]; then
    SKILLS_DIR="$HOME/.claude/skills"
  elif [[ -n "$USERPROFILE" ]]; then
    # Windows fallback
    SKILLS_DIR="$USERPROFILE/.claude/skills"
  else
    SKILLS_DIR="~/.claude/skills"
  fi

  # Workspace is always relative to project root
  WORKSPACE_DIR="./tools/openspace"

  # Replace placeholder paths in .env if they contain the generic values
  if grep -q "OPENSPACE_HOST_SKILL_DIRS=~/\.claude/skills" "$ROOT/.env" 2>/dev/null; then
    # Using a temporary file for cross-platform sed compatibility
    sed "s|OPENSPACE_HOST_SKILL_DIRS=~/\.claude/skills|OPENSPACE_HOST_SKILL_DIRS=$SKILLS_DIR|g" "$ROOT/.env" > "$ROOT/.env.tmp"
    mv "$ROOT/.env.tmp" "$ROOT/.env"
    echo "✓ OpenSpace skills directory configured: $SKILLS_DIR"
  fi

  if grep -q "OPENSPACE_WORKSPACE=\./tools/openspace" "$ROOT/.env" 2>/dev/null; then
    echo "✓ OpenSpace workspace configured: $WORKSPACE_DIR"
  fi
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

# ── 6. Verify Node.js / npx (17 npx-based MCP servers) ────
echo ""
echo "── Node.js / npx ────────────────────────────────────────"
echo "   Required by: memory, supabase-mcp, openrouter-mcp, kie-ai, tavily-mcp,"
echo "   trigger, pinecone-mcp, vapi-mcp, n8n-mcp, apify, zep-mcp, canva-dev,"
echo "   monet-mcp, stitch, 21st-dev-magic, playwright-mcp, firecrawl-mcp, higgsfield, context7"
if command -v npx &>/dev/null; then
  NODE_VERSION=$(node --version 2>&1)
  echo "✓ npx found — Node.js $NODE_VERSION"
else
  echo "✗ npx not found — 18 MCP servers require Node.js/npx"
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
  if _timeout 30 claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill 2>/dev/null; then
    echo "  ✓ ui-ux-pro-max installed"
  else
    echo "  ⚠ ui-ux-pro-max auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill"
    echo "      /plugin install ui-ux-pro-max@ui-ux-pro-max-skill"
  fi

  # andrej-karpathy-skills — coding behavior guidelines
  # Source: https://github.com/forrestchang/andrej-karpathy-skills
  if _timeout 30 claude plugin install andrej-karpathy-skills@karpathy-skills 2>/dev/null; then
    echo "  ✓ andrej-karpathy-skills installed"
  else
    echo "  ⚠ andrej-karpathy-skills auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add forrestchang/andrej-karpathy-skills"
    echo "      /plugin install andrej-karpathy-skills@karpathy-skills"
  fi

  # impeccable — frontend design skill (23 commands + anti-pattern detection)
  # Source: https://github.com/pbakaus/impeccable
  if _timeout 30 claude plugin install impeccable@impeccable 2>/dev/null; then
    echo "  ✓ impeccable installed"
  else
    echo "  ⚠ impeccable auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add pbakaus/impeccable"
    echo "      /plugin install impeccable@impeccable"
  fi

  # codex — OpenAI Codex plugin (rescue + diagnosis subagent via Codex CLI)
  # Source: https://github.com/openai/codex-plugin-cc
  if _timeout 30 claude plugin install codex@openai-codex 2>/dev/null; then
    echo "  ✓ codex installed"
  else
    echo "  ⚠ codex auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add openai/codex-plugin-cc"
    echo "      /plugin install codex@openai-codex"
  fi

  # cc-gemini-plugin — Gemini bridge for large-context codebase exploration
  # Source: https://github.com/thepushkarp/cc-gemini-plugin
  # Requires: GEMINI_API_KEY in .claude/settings.local.json (get at aistudio.google.com/apikey)
  if _timeout 30 claude plugin install cc-gemini-plugin@cc-gemini-plugin 2>/dev/null; then
    echo "  ✓ cc-gemini-plugin installed"
  else
    echo "  ⚠ cc-gemini-plugin auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add thepushkarp/cc-gemini-plugin"
    echo "      /plugin install cc-gemini-plugin@cc-gemini-plugin"
  fi

  # cli-anything — Generate AI-native CLIs for any software (GIMP, Blender, LibreOffice, etc.)
  # Source: https://github.com/HKUDS/CLI-Anything
  # 50+ supported applications, 2,280+ passing tests
  if _timeout 30 claude plugin install cli-anything@cli-anything 2>/dev/null; then
    echo "  ✓ cli-anything installed"
  else
    echo "  ⚠ cli-anything auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add HKUDS/CLI-Anything"
    echo "      /plugin install cli-anything@cli-anything"
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
  echo ""
  echo "  Codex (OpenAI Codex rescue + diagnosis subagent):"
  echo "    /plugin marketplace add openai/codex-plugin-cc"
  echo "    /plugin install codex@openai-codex"
  echo ""
  echo "  Gemini Plugin (large-context codebase exploration via Gemini):"
  echo "    /plugin marketplace add thepushkarp/cc-gemini-plugin"
  echo "    /plugin install cc-gemini-plugin@cc-gemini-plugin"
  echo ""
  echo "  CLI-Anything (generate AI-native CLIs for any software):"
  echo "    /plugin marketplace add HKUDS/CLI-Anything"
  echo "    /plugin install cli-anything@cli-anything"
fi

echo ""
echo "  Marketplace sources are pre-configured in .claude/settings.json"
echo "  under extraKnownMarketplaces — no manual marketplace registration"
echo "  is needed if using the slash commands above."

# ── 7a. Install Apify agent skills ─────────────────────────
echo ""
echo "── Apify Agent Skills (marketplace) ─────────────────────"
echo "   Source: https://github.com/apify/agent-skills"

if command -v claude &>/dev/null; then
  echo "  Attempting marketplace installation via CLI (30s timeout each)..."
  echo ""

  # apify-ultimate-scraper — universal web scraper (130+ Actors)
  if _timeout 30 claude skill install apify-ultimate-scraper@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-ultimate-scraper installed"
  else
    echo "  ⚠ apify-ultimate-scraper timed out or failed — install manually in Claude Code:"
    echo "      /skill install apify-ultimate-scraper@apify-agent-skills"
  fi

  # apify-actor-development — create, debug, deploy Actors
  if _timeout 30 claude skill install apify-actor-development@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-actor-development installed"
  else
    echo "  ⚠ apify-actor-development timed out or failed — install manually in Claude Code:"
    echo "      /skill install apify-actor-development@apify-agent-skills"
  fi

  # apify-actorization — convert code to Actors
  if _timeout 30 claude skill install apify-actorization@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-actorization installed"
  else
    echo "  ⚠ apify-actorization timed out or failed — install manually in Claude Code:"
    echo "      /skill install apify-actorization@apify-agent-skills"
  fi

  # apify-generate-output-schema — generate Actor output schemas
  if _timeout 30 claude skill install apify-generate-output-schema@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-generate-output-schema installed"
  else
    echo "  ⚠ apify-generate-output-schema timed out or failed — install manually in Claude Code:"
    echo "      /skill install apify-generate-output-schema@apify-agent-skills"
  fi

  # apify-actor-commands — slash command pack (/create-actor, etc.)
  if _timeout 30 claude skill install apify-actor-commands@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-actor-commands installed"
  else
    echo "  ⚠ apify-actor-commands timed out or failed — install manually in Claude Code:"
    echo "      /skill install apify-actor-commands@apify-agent-skills"
  fi

  echo ""
  echo "  Marketplace configured in .claude/settings.json → extraKnownMarketplaces"
else
  echo "  claude CLI not found — install Apify skills manually."
  echo "  Run these slash commands inside a Claude Code chat session:"
  echo ""
  echo "  /skill install apify-ultimate-scraper@apify-agent-skills"
  echo "  /skill install apify-actor-development@apify-agent-skills"
  echo "  /skill install apify-actorization@apify-agent-skills"
  echo "  /skill install apify-generate-output-schema@apify-agent-skills"
  echo "  /skill install apify-actor-commands@apify-agent-skills"
  echo ""
  echo "  Marketplace: https://github.com/apify/agent-skills"
fi

# ── 7b. Install Caveman plugin (token compression) ─────────
echo ""
echo "── Caveman Plugin (75% token reduction) ────────────────"
if command -v claude &>/dev/null; then
  echo "  Installing caveman plugin from JuliusBrussee/caveman..."

  if _timeout 30 claude plugin install caveman@caveman 2>/dev/null; then
    echo "  ✓ caveman plugin installed"
    echo "  Commands: /caveman, /caveman-commit, /caveman-review, /caveman-stats, /caveman-compress, /cavecrew"
    echo "  MCP proxy: memory-shrunk (wraps memory server for compressed descriptions)"
  else
    echo "  ⚠ caveman — run in Claude Code:"
    echo "      /plugin install caveman@caveman"
  fi
else
  echo "  claude CLI not found — install caveman manually."
  echo "  Run this slash command inside a Claude Code chat session:"
  echo ""
  echo "  /plugin install caveman@caveman"
fi

# ── 7c. Install Context Mode plugin (98% context reduction) ─
echo ""
echo "── Context Mode Plugin (98% context reduction) ─────────"
if command -v claude &>/dev/null; then
  echo "  Installing context-mode plugin from mksglu/context-mode..."

  if _timeout 30 claude plugin install context-mode@context-mode 2>/dev/null; then
    echo "  ✓ context-mode plugin installed"
    echo "  Slash commands: /context-mode:ctx-stats, /context-mode:ctx-doctor, /context-mode:ctx-upgrade"
    echo "  Statusline: Shows $ saved this session · $ saved across sessions · % efficient"
    echo "  Sandboxes tool output — 315 KB becomes 5.4 KB (98% reduction)"

    # Install better-sqlite3 (optional native dep — required for FTS5/session continuity)
    # Uses NODE_TLS_REJECT_UNAUTHORIZED=0 to bypass corporate SSL proxy interception.
    echo "  Installing better-sqlite3 (FTS5 session continuity)..."
    PLUGIN_DIR=""
    # Find installed plugin directory (marketplaces or cache location)
    for candidate in \
      "$HOME/.claude/plugins/cache/context-mode/context-mode/"*/ \
      "$HOME/.claude/plugins/marketplaces/context-mode" \
      "$USERPROFILE/.claude/plugins/cache/context-mode/context-mode/"*/ \
      "$USERPROFILE/.claude/plugins/marketplaces/context-mode" \
      "$(cygpath "$USERPROFILE" 2>/dev/null)/.claude/plugins/cache/context-mode/context-mode/"*/; do
      if [[ -f "$candidate/package.json" ]]; then
        PLUGIN_DIR="$candidate"
        break
      fi
    done
    if [[ -n "$PLUGIN_DIR" ]]; then
      if NODE_TLS_REJECT_UNAUTHORIZED=0 npm install better-sqlite3 --include=optional --prefix "$PLUGIN_DIR" \
          --no-package-lock 2>/dev/null; then
        echo "  ✓ better-sqlite3 installed — FTS5 session continuity active"
      else
        echo "  ⚠ better-sqlite3 install failed — run /context-mode:ctx-doctor to diagnose"
      fi
    else
      echo "  ⚠ context-mode plugin dir not found — run /context-mode:ctx-doctor after restart"
    fi
  else
    echo "  ⚠ context-mode — run in Claude Code:"
    echo "      /plugin install context-mode@context-mode"
  fi
else
  echo "  claude CLI not found — install context-mode manually."
  echo "  Run this slash command inside a Claude Code chat session:"
  echo ""
  echo "  /plugin install context-mode@context-mode"
fi

# ── 7d-pre. Install Bun (required by claude-mem worker + 3-5x faster context-mode) ─
echo ""
echo "── Bun Runtime (claude-mem worker + context-mode speedup) ──"
if command -v bun &>/dev/null; then
  echo "  ✓ Bun already installed: $(bun --version)"
else
  IS_WINDOWS=false
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
  elif [[ -n "$WINDIR" || -n "$SystemRoot" ]]; then
    IS_WINDOWS=true
  fi

  if $IS_WINDOWS; then
    echo "  Installing Bun via official PowerShell script..."
    # winget silently succeeds but leaves empty dir — official script is reliable
    if powershell -NoProfile -ExecutionPolicy Bypass -Command "irm bun.sh/install.ps1 | iex" 2>/dev/null; then
      echo "  ✓ Bun installed — restart terminal + Claude Code to pick up PATH (~\.bun\bin)"
    else
      echo "  ⚠ Bun install failed. Run manually in PowerShell:"
      echo "      powershell -c \"irm bun.sh/install.ps1 | iex\""
    fi
  else
    echo "  Installing Bun via install script..."
    if curl -fsSL https://bun.sh/install | bash 2>/dev/null; then
      echo "  ✓ Bun installed"
      # Add to PATH for rest of this script
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    else
      echo "  ⚠ Bun install failed. Install manually: curl -fsSL https://bun.sh/install | bash"
    fi
  fi
fi

# ── 7d. Install Claude-Mem plugin (persistent memory across sessions) ─
echo ""
echo "── Claude-Mem Plugin (persistent memory across sessions) ──"
if command -v claude &>/dev/null; then
  echo "  Installing claude-mem plugin from thedotmack/claude-mem..."

  if _timeout 30 claude plugin install claude-mem@claude-mem 2>/dev/null; then
    echo "  ✓ claude-mem plugin installed"
    echo "  Context preserved across sessions via ~/.claude-mem/settings.json"
    echo "  Web viewer: http://localhost:37777 (requires Bun — restart terminal first)"
  else
    echo "  ⚠ claude-mem — run in Claude Code:"
    echo "      /plugin install claude-mem@claude-mem"
  fi
else
  echo "  claude CLI not found — install claude-mem manually."
  echo "  Run this slash command inside a Claude Code chat session:"
  echo ""
  echo "  /plugin install claude-mem@claude-mem"
fi

# ── 8. Install project skills to ~/.claude/skills/ ─────────
echo ""
echo "── Project Skills (~/.claude/skills/) ──────────────────"

# Detect user's home directory (cross-platform)
if [[ -n "$HOME" ]]; then
  USER_HOME="$HOME"
elif [[ -n "$USERPROFILE" ]]; then
  # Windows fallback - convert to Unix-style path for bash compatibility
  USER_HOME="$(cygpath "$USERPROFILE" 2>/dev/null || echo "$USERPROFILE" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|')"
else
  echo "  ✗ Cannot determine user home directory (\$HOME or \$USERPROFILE not set)"
  echo "    Skipping project skills installation"
  USER_HOME=""
fi

if [[ -n "$USER_HOME" ]]; then
  SKILLS_SRC="$ROOT/.claude/skills"
  SKILLS_DEST="$USER_HOME/.claude/skills"
  SKILLS_INSTALLED=0

  echo "  Skills source: $SKILLS_SRC"
  echo "  Skills dest:   $SKILLS_DEST"

  if [ -d "$SKILLS_SRC" ]; then
    # Create destination directory if it doesn't exist
    mkdir -p "$SKILLS_DEST"

    for skill_dir in "$SKILLS_SRC"/*/; do
      skill_name=$(basename "$skill_dir")
      skill_file="$skill_dir/SKILL.md"
      if [ -f "$skill_file" ]; then
        dest_dir="$SKILLS_DEST/$skill_name"
        # Copy the entire skill directory (SKILL.md + any docs/, examples/, templates/)
        rm -rf "$dest_dir"
        mkdir -p "$dest_dir"
        cp -r "$skill_dir"/* "$dest_dir/" 2>/dev/null
        if [ -f "$dest_dir/SKILL.md" ]; then
          echo "  ✓ $skill_name → $SKILLS_DEST/$skill_name/"
          SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
        else
          echo "  ✗ $skill_name copy failed"
        fi
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
fi

# ── 9. Install npm dependencies + Playwright browser ───────
echo ""
echo "── npm Dependencies + Playwright Browser ────────────────"
if [ -f "$ROOT/package.json" ]; then
  if command -v npm &>/dev/null; then
    echo "  Installing project npm dependencies..."
    if (cd "$ROOT" && npm install); then
      echo "✓ npm install complete"
    else
      echo "✗ npm install failed — run: npm install"
      ERRORS=$((ERRORS + 1))
    fi
    # Install Playwright Chromium browser for tools/playwright.js
    echo "  Installing Playwright Chromium (~150MB)..."
    if (cd "$ROOT" && npx playwright install chromium); then
      echo "✓ Playwright Chromium browser installed"
    else
      echo "⚠ Playwright Chromium install failed — run: npx playwright install chromium"
    fi

    # Spline 3D + React deps (react, react-dom, @types/react, @splinetool/react-spline, @splinetool/runtime)
    # are declared in package.json — already installed by the npm install above.
  else
    echo "✗ npm not found — install Node.js first, then run: npm install"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  (no package.json found — skipping)"
fi

# ── 10. Verify GitHub CLI (gh) ──────────────────────────────
echo ""
echo "── GitHub CLI (gh) ──────────────────────────────────────"
echo "   Required by: github@claude-plugins-official plugin (Bash gh api / gh repo)"
if command -v gh &>/dev/null; then
  GH_VERSION=$(gh --version 2>&1 | head -1)
  echo "✓ gh found: $GH_VERSION"
else
  echo "⚠ gh not found — the GitHub plugin won't be able to use Bash(gh ...) tools"
  echo "  Install GitHub CLI:"
  if [[ "$OSTYPE" != "msys"* && "$OSTYPE" != "cygwin"* && "$OS" != "Windows_NT" ]]; then
    echo "    macOS:  brew install gh"
    echo "    Linux:  https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  else
    echo "    Windows (winget): winget install GitHub.cli"
    echo "    Windows (scoop):  scoop install gh"
    echo "    Or download from: https://cli.github.com/"
  fi
  echo "  Then authenticate: gh auth login"
fi

# ── 11. Install global CLI tools ────────────────────────────
echo ""
echo "── Global CLI Tools ─────────────────────────────────────"

# skillui — design system extractor for /skillui skill
# Source: https://github.com/amaancoderx/npxskillui
if command -v skillui &>/dev/null; then
  echo "✓ skillui already installed"
elif command -v npm &>/dev/null; then
  echo "  Installing skillui globally (~5MB)..."
  if _timeout 120 npm install -g skillui; then
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
  echo "  Installing firecrawl-cli globally (~10MB)..."
  if _timeout 120 npm install -g firecrawl-cli; then
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

# codex-cli — OpenAI Codex CLI for /three-brain skill + codex plugin
# Source: https://github.com/openai/codex-plugin-cc
# Used by: three-brain auto-router (review/rescue routes), codex:rescue, codex:setup
if command -v codex &>/dev/null; then
  CODEX_VERSION=$(codex --version 2>&1 | head -1 || echo "unknown")
  echo "✓ codex-cli already installed: $CODEX_VERSION"
elif command -v npm &>/dev/null; then
  echo "  Installing codex-cli globally (~50MB)..."
  if _timeout 120 npm install -g @openai/codex@latest; then
    echo "✓ codex-cli installed"
    echo "  ⚠ Requires OpenAI API key — add OPENAI_API_KEY to .env and settings.local.json"
  else
    echo "⚠ codex-cli install failed — run manually: npm install -g @openai/codex@latest"
  fi
else
  echo "⚠ npm not found — cannot install codex-cli (run: npm install -g @openai/codex@latest)"
fi

# gemini-cli — Google Gemini CLI for /three-brain skill + cc-gemini-plugin
# Source: https://github.com/google-gemini/gemini-cli
# Used by: three-brain auto-router (multimodal/long-context routes), /cc-gemini-plugin:gemini
if command -v gemini &>/dev/null; then
  GEMINI_VERSION=$(gemini --version 2>&1 | head -1 || echo "unknown")
  echo "✓ gemini-cli already installed: $GEMINI_VERSION"
elif command -v npm &>/dev/null; then
  echo "  Installing gemini-cli globally (~50MB)..."
  if _timeout 120 npm install -g @google/gemini-cli@latest; then
    echo "✓ gemini-cli installed"
    echo "  ⚠ Requires Gemini API key — add GEMINI_API_KEY to .env and settings.local.json"
    echo "  Get a free key at: https://aistudio.google.com/apikey"
  else
    echo "⚠ gemini-cli install failed — run manually: npm install -g @google/gemini-cli@latest"
  fi
else
  echo "⚠ npm not found — cannot install gemini-cli (run: npm install -g @google/gemini-cli@latest)"
fi

# notebooklm-mcp-cli — Google NotebookLM CLI + MCP server
# Source: https://github.com/jacob-bd/notebooklm-mcp-cli
# Used by: /notebooklm skill — notebook management, AI queries, podcast/video generation
# Requires: uv or uvx for installation, cookie-based authentication (nlm login)
if command -v nlm &>/dev/null; then
  NLM_VERSION=$(nlm --version 2>&1 | head -1 || echo "unknown")
  echo "✓ notebooklm-mcp-cli already installed: $NLM_VERSION"
elif command -v uv &>/dev/null; then
  echo "  Installing notebooklm-mcp-cli via uv tool..."
  if _timeout 120 uv tool install notebooklm-mcp-cli; then
    echo "✓ notebooklm-mcp-cli installed (CLI: nlm, MCP: notebooklm-mcp)"
    echo "  ⚠ Run 'nlm login' to authenticate with Google NotebookLM before first use"
  else
    echo "⚠ notebooklm-mcp-cli install failed — run manually: uv tool install notebooklm-mcp-cli"
  fi
else
  echo "⚠ uv not found — cannot install notebooklm-mcp-cli"
  echo "  Install uv first (see step 5 above), then run: uv tool install notebooklm-mcp-cli"
fi

# ── 12. Authentication reminders (interactive — cannot automate) ──
echo ""
echo "── Authentication Reminders ─────────────────────────────"
echo "  These require a one-time manual step before first use:"
echo ""
echo "  NotebookLM CLI + MCP"
echo "    Run: nlm login"
echo "    (launches browser — you log in to Google, cookies extracted automatically)"
echo "    OR run: nlm login --manual (import cookies from file)"
echo "    Required by: /notebooklm skill and notebooklm-mcp MCP server"
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
echo "  Higgsfield MCP"
echo "    No keys needed. Run this once to authenticate:"
echo "      npx mcp-remote https://mcp.higgsfield.ai/mcp"
echo "    A browser OAuth window opens — sign in to your Higgsfield account."
echo "    After authenticating once, mcp-remote caches the token automatically."
echo ""
echo "  GitHub CLI (gh)"
echo "    After installing gh (see step 10 above), authenticate once:"
echo "      gh auth login"
echo "    Required by: github@claude-plugins-official plugin."
echo ""
echo "  Gemini Plugin (cc-gemini-plugin)"
echo "    Add GEMINI_API_KEY to .claude/settings.local.json → env block."
echo "    Get a free key at: https://aistudio.google.com/apikey"
echo ""
echo "  Codex Plugin (codex@openai-codex)"
echo "    The plugin dispatches work to the Codex CLI. Check readiness with /codex:setup."
echo "    Codex CLI install: npm install -g @openai/codex (requires OpenAI API key)"
echo ""
echo "  All other MCP servers (supabase, openrouter, kie-ai, tavily,"
echo "  pinecone, vapi, n8n, apify, monet, stitch, 21st-dev, firecrawl)"
echo "  require API keys in .claude/settings.local.json → env block."
echo "  See .claude/settings.local.json.example → __activation_guide"
echo "  for where to obtain each key."

# ── 13. Install autoresearch dependencies ──────────────────
echo ""
echo "── AutoResearch (Autonomous ML Research) ────────────────"
AUTORESEARCH_DIR="$ROOT/tools/autoresearch"

if [ -d "$AUTORESEARCH_DIR" ]; then
  if command -v uv &>/dev/null; then
    echo "  Installing autoresearch dependencies..."
    echo "  ⚠ PyTorch download is ~3GB — this will take 5-15 minutes on first run."
    echo "  Progress shown below:"
    echo ""

    if (cd "$AUTORESEARCH_DIR" && UV_NATIVE_TLS=true uv sync --all-extras); then
      echo "✓ autoresearch dependencies installed"
      echo ""
      echo "  Verifying installation..."

      # Run verify_setup.py to confirm all dependencies installed correctly
      if (cd "$AUTORESEARCH_DIR" && uv run python verify_setup.py 2>&1); then
        echo ""
        echo "  Next steps:"
        echo "    1. cd tools/autoresearch"
        echo "    2. uv run prepare.py  (one-time data prep, ~2 min)"
        echo "    3. uv run train.py    (test baseline run, ~5 min)"
        echo "    4. Use /autoresearch skill to start autonomous research"
      else
        echo ""
        echo "⚠ Verification failed — some dependencies may be missing"
        echo "  Re-run: cd tools/autoresearch && UV_NATIVE_TLS=true uv sync --all-extras"
        echo "  Then verify: uv run python verify_setup.py"
      fi
    else
      echo "⚠ uv sync may need to run — complete it manually:"
      echo "    cd tools/autoresearch && UV_NATIVE_TLS=true uv sync --all-extras"
      echo "  Then verify:"
      echo "    uv run python verify_setup.py"
    fi
  else
    echo "⚠ uv not found — autoresearch requires uv to install dependencies"
    echo "  Install uv (see step 5 above), then run:"
    echo "    cd tools/autoresearch && UV_NATIVE_TLS=true uv sync --all-extras"
    echo "    uv run python verify_setup.py"
  fi
else
  echo "  (tools/autoresearch/ directory not found — skipping)"
fi

# ── 14. Install LightRAG dependencies ───────────────────────
echo ""
echo "── LightRAG (Graph-Based RAG) ───────────────────────────"
LIGHTRAG_DIR="$ROOT/tools/lightrag"

if [ -d "$LIGHTRAG_DIR" ]; then
  # Auto-create .env from .env.example so EMBEDDING_BINDING_HOST and defaults are set
  if [ ! -f "$LIGHTRAG_DIR/.env" ] && [ -f "$LIGHTRAG_DIR/.env.example" ]; then
    cp "$LIGHTRAG_DIR/.env.example" "$LIGHTRAG_DIR/.env"
    echo "✓ tools/lightrag/.env created from .env.example — add OPENAI_API_KEY to enable uploads"
  fi

  if command -v uv &>/dev/null; then
    echo "  Installing LightRAG dependencies (~200MB, may take 2-5 minutes)..."
    echo ""

    if (cd "$LIGHTRAG_DIR" && UV_NATIVE_TLS=true uv sync --all-extras); then
      echo "✓ LightRAG Plus dependencies installed"

      # Integrity check — guards against OneDrive deleting transitive dep files mid-install
      if ! (cd "$LIGHTRAG_DIR" && uv pip check >/dev/null 2>&1); then
        echo "  ⚠ Incomplete transitive dependencies detected — auto-repairing..."
        # Remove dist-info dirs whose METADATA was deleted (OneDrive signature)
        _site=$(find "$LIGHTRAG_DIR/.venv" -name "site-packages" -type d 2>/dev/null | head -1)
        if [ -n "$_site" ]; then
          for _d in "$_site/"*dist-info; do
            [ -d "$_d" ] && [ ! -f "$_d/METADATA" ] && rm -rf "$_d"
          done
        fi
        # Re-sync then force-install known transitive deps OneDrive tends to delete
        (cd "$LIGHTRAG_DIR" && UV_NATIVE_TLS=true uv sync --all-extras >/dev/null 2>&1) || true
        (cd "$LIGHTRAG_DIR" && uv pip install \
          "pydantic>=2.0.0" "json-repair" propcache requests \
          "google-auth>=2.14.1" idna iniconfig pluggy >/dev/null 2>&1) || true
        echo "  ✓ Repair complete"
      fi

      # Final import verification — catches any remaining breakage
      if (cd "$LIGHTRAG_DIR" && uv run python -c \
          "from lightrag import LightRAG, QueryParam" >/dev/null 2>&1); then
        echo "✓ LightRAG import verified"
      else
        echo "⚠ LightRAG import check failed after install"
        echo "    Run: cd tools/lightrag && uv pip check"
      fi

      echo ""
      echo "  Provisioning backends (skips if no credentials in .env)..."
      if [ -f "$LIGHTRAG_DIR/.env" ]; then
        (cd "$LIGHTRAG_DIR" && uv run python provision.py) || echo "⚠ Backend provisioning failed — run manually: cd tools/lightrag && uv run python provision.py"
      else
        echo "  (.env not found — copy .env.example, add credentials, then run: cd tools/lightrag && uv run python provision.py)"
      fi
      echo ""
      echo "  Next steps:"
      echo "    1. Add API keys to tools/lightrag/.env (OPENAI_API_KEY or GEMINI_API_KEY)"
      echo "    2. Use /lightrag skill for setup + usage guide"
      echo "    3. Optional: Start LightRAG Server for Web UI:"
      echo "       cd tools/lightrag && uv run python -m lightrag.api.lightrag_server --port 9621"
    else
      echo "⚠ uv sync failed — complete it manually:"
      echo "    cd tools/lightrag && UV_NATIVE_TLS=true uv sync --all-extras"
    fi
  else
    echo "⚠ uv not found — LightRAG requires uv to install dependencies"
    echo "  Install uv (see step 5 above), then run:"
    echo "    cd tools/lightrag && UV_NATIVE_TLS=true uv sync --all-extras"
  fi
else
  echo "  (tools/lightrag/ directory not found — skipping)"
fi

# ── 14a. Install Ollama (local LLM for LightRAG) ────────────
echo ""
echo "── Ollama (Local LLM) ───────────────────────────────────"

IS_WIN=false
if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OS" == "Windows_NT" ]]; then
  IS_WIN=true
fi

if command -v ollama &>/dev/null; then
  echo "✓ Ollama already installed"
  # Pull llama3.2 if not already present
  if ollama list 2>/dev/null | grep -q "llama3.2"; then
    echo "✓ llama3.2 model already pulled"
  else
    echo "  Pulling llama3.2 (~2GB, this may take a few minutes)..."
    if ollama pull llama3.2; then
      echo "✓ llama3.2 pulled"
    else
      echo "⚠ ollama pull failed — run manually: ollama pull llama3.2"
      ERRORS=$((ERRORS + 1))
    fi
  fi
else
  if [ "$IS_WIN" = true ]; then
    if command -v winget &>/dev/null; then
      echo "  Installing Ollama via winget..."
      winget install --id Ollama.Ollama --accept-package-agreements --accept-source-agreements
      # winget doesn't update PATH in the current session — check known install location
      OLLAMA_BIN=""
      if [ -n "$LOCALAPPDATA" ]; then
        UNIX_LOCALAPPDATA="$(cygpath "$LOCALAPPDATA" 2>/dev/null || echo "$LOCALAPPDATA" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|')"
        CANDIDATE="$UNIX_LOCALAPPDATA/Programs/Ollama/ollama.exe"
        if [ -f "$CANDIDATE" ]; then
          OLLAMA_BIN="$CANDIDATE"
        fi
      fi
      if command -v ollama &>/dev/null; then
        OLLAMA_BIN="ollama"
      fi
      if [ -n "$OLLAMA_BIN" ]; then
        echo "✓ Ollama found"
        echo "  Pulling llama3.2 (~2GB, this may take a few minutes)..."
        if "$OLLAMA_BIN" pull llama3.2; then
          echo "✓ llama3.2 pulled"
        else
          echo "⚠ Pull failed — run in bash or PowerShell (same command):"
          echo "    ollama pull llama3.2"
          ERRORS=$((ERRORS + 1))
        fi
      else
        echo "  ⚠ Ollama installed but not in PATH yet — restart terminal then run:"
        echo "  Bash:        ollama pull llama3.2"
        echo "  PowerShell:  ollama pull llama3.2"
      fi
    else
      echo "  winget not found. Install Ollama manually, then pull the model."
      echo "  Download: https://ollama.com/download/OllamaSetup.exe"
      echo "  Bash:        ollama pull llama3.2"
      echo "  PowerShell:  ollama pull llama3.2"
    fi
  else
    echo "  Installing Ollama..."
    if curl -fsSL https://ollama.com/install.sh | sh; then
      echo "✓ Ollama installed"
      echo "  Pulling llama3.2..."
      if ollama pull llama3.2; then
        echo "✓ llama3.2 pulled"
      else
        echo "⚠ Pull failed — run manually: ollama pull llama3.2"
        ERRORS=$((ERRORS + 1))
      fi
    else
      echo "⚠ Ollama install failed — install manually: https://ollama.com"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ── 15. Install OpenSpace (self-evolving skill system) ───────
echo ""
echo "── OpenSpace (Self-Evolving Skill System) ───────────────"
OPENSPACE_DIR="$ROOT/tools/openspace"

# Check if OpenSpace is configured as a git submodule
if [ -f "$ROOT/.gitmodules" ] && grep -q "path = tools/openspace" "$ROOT/.gitmodules"; then
  # It's a submodule — initialize if not already done
  if [ ! -d "$OPENSPACE_DIR/.git" ] && [ ! -f "$OPENSPACE_DIR/.git" ]; then
    echo "  📦 Initializing OpenSpace submodule..."
    (cd "$ROOT" && git submodule update --init --recursive tools/openspace)
  else
    echo "  ✓ OpenSpace submodule already initialized"
  fi
fi

if [ -d "$OPENSPACE_DIR" ]; then
  echo "  Installing OpenSpace from tools/openspace/ via uv pip..."
  # Detect platform extra — uv pip install avoids cross-version lockfile resolution
  # (uv sync fails: pyatspi has no Python 3.15+ release, breaks [all] extra on Windows)
  case "$(uname -s 2>/dev/null)" in
    Darwin*)  OS_EXTRA="macos" ;;
    Linux*)   OS_EXTRA="linux" ;;
    *)        OS_EXTRA="windows" ;;  # Git Bash / MSYS / Windows
  esac

  if command -v uv &>/dev/null; then
    if (cd "$OPENSPACE_DIR" && uv pip install -e ".[$OS_EXTRA]" 2>&1 | tail -3); then
      echo "✓ OpenSpace installed ([$OS_EXTRA] extras)"
      if command -v openspace-mcp &>/dev/null; then
        echo "✓ openspace-mcp command available"
      else
        echo "⚠ openspace-mcp not in PATH — restart shell or add uv venv Scripts dir to PATH"
      fi
    else
      echo "⚠ OpenSpace installation failed — complete manually:"
      echo "    cd tools/openspace && uv pip install -e '.[$OS_EXTRA]'"
    fi
  else
    # uv not available — fall back to system pip (no platform extras, no venv)
    if command -v python3 &>/dev/null; then PYTHON_CMD="python3"
    elif command -v py &>/dev/null; then PYTHON_CMD="py"
    elif command -v python &>/dev/null; then PYTHON_CMD="python"
    else PYTHON_CMD=""; fi

    if [ -n "$PYTHON_CMD" ]; then
      if (cd "$OPENSPACE_DIR" && $PYTHON_CMD -m pip install -e . --quiet 2>&1); then
        echo "✓ OpenSpace installed via pip (no platform extras — install uv for full deps)"
      else
        echo "⚠ OpenSpace installation failed — complete manually:"
        echo "    cd tools/openspace && pip install -e ."
      fi
    else
      echo "⚠ uv and Python not found — install uv first: https://docs.astral.sh/uv/getting-started/installation/"
    fi
  fi

  # Set up OpenSpace frontend (optional dashboard — requires Node.js ≥ 20)
  OPENSPACE_FRONTEND="$OPENSPACE_DIR/frontend"
  if [ -d "$OPENSPACE_FRONTEND" ]; then
    echo ""
    echo "  Setting up OpenSpace Dashboard Frontend..."

    # Copy .env.example to .env if not present
    if [ ! -f "$OPENSPACE_FRONTEND/.env" ]; then
      if [ -f "$OPENSPACE_FRONTEND/.env.example" ]; then
        cp "$OPENSPACE_FRONTEND/.env.example" "$OPENSPACE_FRONTEND/.env"
        echo "  ✓ frontend/.env created from .env.example"

        # Fix port mismatch: upstream .env.example has 3888, but package.json uses 3789
        # The npm script's --port flag overrides .env, but we align them to avoid confusion
        if command -v sed &>/dev/null; then
          sed -i.bak 's/VITE_PORT=3888/VITE_PORT=3789/' "$OPENSPACE_FRONTEND/.env" 2>/dev/null && rm -f "$OPENSPACE_FRONTEND/.env.bak"
          echo "  ✓ Port aligned to 3789 (matches package.json)"
        fi
      fi
    else
      echo "  ✓ frontend/.env already exists"
    fi

    # Install npm dependencies if Node.js is available
    if command -v npm &>/dev/null; then
      # Check Node.js version (requires ≥ 20)
      NODE_MAJOR=$(node --version 2>&1 | grep -oE '[0-9]+' | head -1)

      if [ "$NODE_MAJOR" -ge 20 ]; then
        if [ ! -d "$OPENSPACE_FRONTEND/node_modules" ]; then
          echo "  Installing frontend dependencies (React/Vite, ~30MB)..."
          if (cd "$OPENSPACE_FRONTEND" && npm install); then
            echo "  ✓ Frontend dependencies installed"
            echo ""
            echo "  Dashboard ready — launch via VSCode:"
            echo "    Press F5 → Select 'OpenSpace Backend Server' → http://127.0.0.1:7788"
            echo "    Press F5 → Select 'OpenSpace Frontend' → Browser opens at http://127.0.0.1:3789"
          else
            echo "  ⚠ Frontend npm install failed — complete it manually:"
            echo "      cd tools/openspace/frontend && npm install"
          fi
        else
          echo "  ✓ Frontend dependencies already installed"
          echo "  Dashboard ready — launch via VSCode (F5 → OpenSpace Backend/Frontend)"
        fi
      else
        echo "  ⚠ OpenSpace frontend requires Node.js ≥ 20 (found v$NODE_MAJOR)"
        echo "    Dashboard backend (openspace-dashboard) will work, but frontend won't run"
        echo "    Update Node.js to v20+ to use the Web UI"
      fi
    else
      echo "  ⚠ npm not found — frontend requires Node.js ≥ 20"
      echo "    Dashboard backend (openspace-dashboard) will work, but frontend requires npm"
      echo "    Install Node.js v20+ from https://nodejs.org to use the Web UI"
    fi
  fi
else
  echo "  (tools/openspace/ directory not found — skipping)"
fi

# ── 16. Install pre-commit doc-sync hook ────────────────────
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

# ── 17. Summary ────────────────────────────────────────────
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
