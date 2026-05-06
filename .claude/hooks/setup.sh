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

  # codex — OpenAI Codex plugin (rescue + diagnosis subagent via Codex CLI)
  # Source: https://github.com/openai/codex-plugin-cc
  if claude plugins install codex@openai-codex 2>/dev/null; then
    echo "  ✓ codex installed"
  else
    echo "  ⚠ codex auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add openai/codex-plugin-cc"
    echo "      /plugin install codex@openai-codex"
  fi

  # cc-gemini-plugin — Gemini bridge for large-context codebase exploration
  # Source: https://github.com/thepushkarp/cc-gemini-plugin
  # Requires: GEMINI_API_KEY in .claude/settings.local.json (get at aistudio.google.com/apikey)
  if claude plugins install cc-gemini-plugin@cc-gemini-plugin 2>/dev/null; then
    echo "  ✓ cc-gemini-plugin installed"
  else
    echo "  ⚠ cc-gemini-plugin auto-install failed — run these inside Claude Code:"
    echo "      /plugin marketplace add thepushkarp/cc-gemini-plugin"
    echo "      /plugin install cc-gemini-plugin@cc-gemini-plugin"
  fi

  # cli-anything — Generate AI-native CLIs for any software (GIMP, Blender, LibreOffice, etc.)
  # Source: https://github.com/HKUDS/CLI-Anything
  # 50+ supported applications, 2,280+ passing tests
  if claude plugins install cli-anything@cli-anything 2>/dev/null; then
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
echo "── Apify Agent Skills (.agents/skills/) ────────────────"

if command -v claude &>/dev/null; then
  echo "  Installing Apify agent skills from apify/agent-skills..."
  echo ""

  # apify-ultimate-scraper — universal web scraper (130+ Actors)
  if claude skill install apify-ultimate-scraper@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-ultimate-scraper installed"
  else
    echo "  ⚠ apify-ultimate-scraper — run in Claude Code:"
    echo "      /skill install apify-ultimate-scraper@apify-agent-skills"
  fi

  # apify-actor-development — create, debug, deploy Actors
  if claude skill install apify-actor-development@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-actor-development installed"
  else
    echo "  ⚠ apify-actor-development — run in Claude Code:"
    echo "      /skill install apify-actor-development@apify-agent-skills"
  fi

  # apify-actorization — convert code to Actors
  if claude skill install apify-actorization@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-actorization installed"
  else
    echo "  ⚠ apify-actorization — run in Claude Code:"
    echo "      /skill install apify-actorization@apify-agent-skills"
  fi

  # apify-generate-output-schema — generate Actor output schemas
  if claude skill install apify-generate-output-schema@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-generate-output-schema installed"
  else
    echo "  ⚠ apify-generate-output-schema — run in Claude Code:"
    echo "      /skill install apify-generate-output-schema@apify-agent-skills"
  fi

  # apify-actor-commands — slash command pack (/create-actor, etc.)
  if claude skill install apify-actor-commands@apify-agent-skills 2>/dev/null; then
    echo "  ✓ apify-actor-commands installed"
  else
    echo "  ⚠ apify-actor-commands — run in Claude Code:"
    echo "      /skill install apify-actor-commands@apify-agent-skills"
  fi
else
  echo "  claude CLI not found — install Apify skills manually."
  echo "  Run these slash commands inside a Claude Code chat session:"
  echo ""
  echo "  /skill install apify-ultimate-scraper@apify-agent-skills"
  echo "  /skill install apify-actor-development@apify-agent-skills"
  echo "  /skill install apify-actorization@apify-agent-skills"
  echo "  /skill install apify-generate-output-schema@apify-agent-skills"
  echo "  /skill install apify-actor-commands@apify-agent-skills"
fi

# ── 7b. Install Caveman plugin (token compression) ─────────
echo ""
echo "── Caveman Plugin (75% token reduction) ────────────────"
if command -v claude &>/dev/null; then
  echo "  Installing caveman plugin from JuliusBrussee/caveman..."

  if claude plugin install caveman@caveman 2>/dev/null; then
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

# codex-cli — OpenAI Codex CLI for /three-brain skill + codex plugin
# Source: https://github.com/openai/codex-plugin-cc
# Used by: three-brain auto-router (review/rescue routes), codex:rescue, codex:setup
if command -v codex &>/dev/null; then
  CODEX_VERSION=$(codex --version 2>&1 | head -1 || echo "unknown")
  echo "✓ codex-cli already installed: $CODEX_VERSION"
elif command -v npm &>/dev/null; then
  echo "  Installing codex-cli globally..."
  if npm install -g @openai/codex@latest --silent 2>/dev/null; then
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
  echo "  Installing gemini-cli globally..."
  if npm install -g @google/gemini-cli@latest --silent 2>/dev/null; then
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
  if uv tool install notebooklm-mcp-cli 2>/dev/null; then
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
    echo "  Installing autoresearch dependencies (PyTorch download may take 5-10 minutes)..."

    # Run uv sync (suppress quiet flag to show progress)
    if (cd "$AUTORESEARCH_DIR" && uv sync 2>&1 >/dev/null); then
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
        echo "  Re-run: cd tools/autoresearch && uv sync"
        echo "  Then verify: uv run python verify_setup.py"
      fi
    else
      echo "⚠ uv sync may need to run — complete it manually:"
      echo "    cd tools/autoresearch && uv sync"
      echo "  Then verify:"
      echo "    uv run python verify_setup.py"
    fi
  else
    echo "⚠ uv not found — autoresearch requires uv to install dependencies"
    echo "  Install uv (see step 5 above), then run:"
    echo "    cd tools/autoresearch && uv sync"
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
  if command -v uv &>/dev/null; then
    echo "  Installing LightRAG dependencies..."

    if (cd "$LIGHTRAG_DIR" && uv sync --quiet 2>&1 >/dev/null); then
      echo "✓ LightRAG dependencies installed (lightrag-hku)"
      echo ""
      echo "  Next steps:"
      echo "    1. Add LLM API key to .env (OPENAI_API_KEY, ANTHROPIC_API_KEY, GEMINI_API_KEY, or OLLAMA_HOST)"
      echo "    2. Use /lightrag skill for setup + usage guide"
      echo "    3. Optional: Start LightRAG Server for Web UI:"
      echo "       cd tools/lightrag && python -m lightrag.server --port 9621"
    else
      echo "⚠ uv sync failed — complete it manually:"
      echo "    cd tools/lightrag && uv sync"
    fi
  else
    echo "⚠ uv not found — LightRAG requires uv to install dependencies"
    echo "  Install uv (see step 5 above), then run:"
    echo "    cd tools/lightrag && uv sync"
  fi
else
  echo "  (tools/lightrag/ directory not found — skipping)"
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
  echo "  Installing OpenSpace from tools/openspace/ via pip..."
  if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
  elif command -v py &>/dev/null; then
    PYTHON_CMD="py"
  elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
  else
    PYTHON_CMD=""
  fi

  if [ -n "$PYTHON_CMD" ]; then
    # Check Python version (requires 3.12+)
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 12 ]; then
      # Install in editable mode
      if (cd "$OPENSPACE_DIR" && $PYTHON_CMD -m pip install -e . --quiet 2>&1 >/dev/null); then
        echo "✓ OpenSpace installed successfully"
        # Verify installation
        if command -v openspace-mcp &>/dev/null; then
          echo "✓ openspace-mcp command available"
        else
          echo "⚠ openspace-mcp not found in PATH — may need to restart shell or add Python scripts dir to PATH"
        fi
      else
        echo "⚠ OpenSpace installation failed — complete it manually:"
        echo "    cd tools/openspace && pip install -e ."
      fi
    else
      echo "⚠ OpenSpace requires Python 3.12+ (found $PYTHON_VERSION)"
      echo "  Install Python 3.12+ then run:"
      echo "    cd tools/openspace && pip install -e ."
    fi
  else
    echo "⚠ Python not found — OpenSpace requires Python 3.12+"
    echo "  Install Python 3.12+, then run:"
    echo "    cd tools/openspace && pip install -e ."
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
          echo "  Installing frontend dependencies (React/Vite)..."
          if (cd "$OPENSPACE_FRONTEND" && npm install --silent 2>&1 >/dev/null); then
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
