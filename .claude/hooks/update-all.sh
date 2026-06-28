#!/usr/bin/env bash
# ============================================================
# Claude Code Boilerplate — Update All
# Updates npm globals, uv tools, Python venvs, npm project
# deps, and git submodules.
#
# New installs auto-register:
#   • npm globals  — add to NPM_GLOBALS below
#   • uv tools     — auto: uv tool upgrade --all covers all
#   • Python venvs — auto: scans tools/*/pyproject.toml
#   • plugins      — manual: claude plugin install <name>@<marketplace>
# ============================================================

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

UPDATED=()
SKIPPED=()
FAILED=()

_ok()   { echo "  ✓ $1"; UPDATED+=("$1"); }
_warn() { echo "  ⚠ $1"; FAILED+=("$1"); }
_skip() { echo "  · $1"; SKIPPED+=("$1"); }

# ── Repair broken venv ────────────────────────────────────────
# Removes dist-info dirs whose METADATA was deleted (OneDrive issue)
# then reinstalls known transitive deps.
_repair_venv() {
  local dir="$1"
  local site
  site=$(find "$dir/.venv" -name "site-packages" -type d 2>/dev/null | head -1)
  if [ -n "$site" ]; then
    local removed=0
    for d in "$site/"*dist-info; do
      [ -d "$d" ] && [ ! -f "$d/METADATA" ] && { rm -rf "$d"; removed=$((removed+1)); }
    done
    [ "$removed" -gt 0 ] && echo "    Removed $removed broken dist-info dirs"
  fi
  # Reinstall known transitive deps that OneDrive tends to delete
  (cd "$dir" && uv pip install \
    "pydantic>=2.0.0" "json-repair" propcache requests \
    "google-auth>=2.14.1" idna iniconfig pluggy >/dev/null 2>&1) || true
}

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Claude Code Boilerplate — Update All             ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── 1. npm global tools ───────────────────────────────────────
# Add new entries here when setup.sh installs a new npm global.
echo "── npm global tools ─────────────────────────────────────"
NPM_GLOBALS=(
  "skillui"
  "firecrawl-cli"
  "@openai/codex"
  "@google/gemini-cli"
  "codeburn"
  "designlang"
  "@felores/kie-cli"
  "@higgsfield/cli"
)

if command -v npm &>/dev/null; then
  for pkg in "${NPM_GLOBALS[@]}"; do
    label="${pkg##*/}"; label="${label%%@*}"
    # Check if installed (scope-aware)
    if npm list -g --depth=0 "${pkg}" &>/dev/null 2>&1; then
      printf "  Updating %-30s" "$pkg..."
      # designlang postinstall runs `npx playwright install chromium` which fails
      # on corporate proxy (TLS interception). --ignore-scripts skips it safely.
      if [ "$pkg" = "designlang" ]; then
        npm_flags="--ignore-scripts"
      else
        npm_flags=""
      fi
      if npm install -g "${pkg}@latest" $npm_flags >/dev/null 2>&1; then
        echo "✓"; UPDATED+=("npm: $label")
      else
        echo "⚠"; FAILED+=("npm: $label")
      fi
    else
      _skip "npm: $label (not installed — run setup.sh to install)"
    fi
  done
else
  _warn "npm not found — skipping global tools"
fi

# ── 2. uv tools ───────────────────────────────────────────────
echo ""
echo "── uv tools ─────────────────────────────────────────────"
if command -v uv &>/dev/null; then
  echo "  Running uv tool upgrade --all..."
  if uv tool upgrade --all 2>&1 | grep -E "^(Updated|Installed|Upgraded|warning)" | sed 's/^/    /'; then
    _ok "uv tools upgraded"
  else
    echo "  (all already up-to-date)"
    _ok "uv tools checked"
  fi
else
  _warn "uv not found — skipping"
fi

# ── 3. Python venvs ───────────────────────────────────────────
# Auto-detects any tools/*/pyproject.toml directory with a venv.
echo ""
echo "── Python venvs ─────────────────────────────────────────"
if command -v uv &>/dev/null; then
  for pyproject in "$ROOT"/tools/*/pyproject.toml; do
    [ -f "$pyproject" ] || continue
    tool_dir=$(dirname "$pyproject")
    tool_name=$(basename "$tool_dir")

    # lightrag-hku is pinned ==1.4.15 in uv.lock due to OneDrive upgrade
    # corruption risk — sync from lockfile only, do NOT --upgrade.
    # openspace: uv sync fails cross-version resolution (pyatspi has no py3.15+
    # release); use uv pip install -e . which skips lockfile resolution entirely.
    echo "  $tool_name..."
    if [ "$tool_name" = "openspace" ]; then
      if (cd "$tool_dir" && uv pip install -e . >/dev/null 2>&1); then
        _ok "venv: $tool_name"
      else
        _warn "venv: $tool_name (uv pip install -e . failed)"
      fi
      continue
    fi
    if (cd "$tool_dir" && UV_NATIVE_TLS=true uv sync --all-extras 2>/dev/null); then
      # Integrity check — catches OneDrive deletions mid-install
      if ! (cd "$tool_dir" && uv pip check >/dev/null 2>&1); then
        echo "    ⚠ Broken deps detected — repairing..."
        _repair_venv "$tool_dir"
        (cd "$tool_dir" && UV_NATIVE_TLS=true uv sync --all-extras >/dev/null 2>&1) || true
      fi
      _ok "venv: $tool_name"
    else
      _warn "venv: $tool_name (uv sync failed)"
    fi
  done
else
  _skip "Python venvs (uv not found)"
fi

# ── 4. GitHub CLI ─────────────────────────────────────────────
echo ""
echo "── GitHub CLI ───────────────────────────────────────────"
if command -v gh &>/dev/null; then
  echo "  Checking for gh updates..."
  if _is_windows; then
    _skip "gh (Windows: winget upgrade GitHub.cli)"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null && brew upgrade gh >/dev/null 2>&1; then
      _ok "gh upgraded via brew"
    else
      _skip "gh (already at latest or brew unavailable)"
    fi
  else
    if sudo apt upgrade gh -y -qq >/dev/null 2>&1; then
      _ok "gh upgraded via apt"
    else
      _skip "gh (auto-upgrade failed — run: sudo apt upgrade gh)"
    fi
  fi
else
  _skip "gh (not installed — run: bash .claude/hooks/install/sys-github-cli.sh)"
fi

# ── 5. Supabase CLI ──────────────────────────────────────────
echo ""
echo "── Supabase CLI ─────────────────────────────────────────"
if command -v supabase &>/dev/null; then
  if _is_windows; then
    if command -v scoop &>/dev/null; then
      scoop update supabase >/dev/null 2>&1 && _ok "supabase (scoop)" || _skip "supabase (scoop up-to-date)"
    else
      _skip "supabase (Windows: scoop update supabase  OR  npm install -g supabase@latest)"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null && brew upgrade supabase >/dev/null 2>&1; then
      _ok "supabase (brew)"
    else
      _skip "supabase (already at latest or brew unavailable)"
    fi
  else
    if command -v npm &>/dev/null && npm install -g supabase@latest >/dev/null 2>&1; then
      _ok "supabase (npm)"
    else
      _skip "supabase (npm update failed)"
    fi
  fi
else
  _skip "supabase (not installed — run: bash .claude/hooks/install/sys-supabase-cli.sh)"
fi

# ── 6. Ollama ─────────────────────────────────────────────────
echo ""
echo "── Ollama ───────────────────────────────────────────────"
if command -v ollama &>/dev/null; then
  echo "  Checking for Ollama updates..."
  # Ollama has no `ollama update` CLI — re-run the installer to update binary
  if _is_windows; then
    _skip "Ollama (Windows: update via winget: winget upgrade Ollama.Ollama)"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    _skip "Ollama (macOS: update via brew: brew upgrade ollama)"
  else
    # Linux: re-run the official install script (idempotent, updates binary)
    if curl -fsSL https://ollama.ai/install.sh 2>/dev/null | sh >/dev/null 2>&1; then
      _ok "Ollama binary updated"
    else
      _skip "Ollama (auto-update failed — run: curl -fsSL https://ollama.ai/install.sh | sh)"
    fi
  fi
else
  _skip "Ollama (not installed — run setup.sh to install)"
fi

# ── 6. npm project dependencies ──────────────────────────────
echo ""
echo "── npm project deps ─────────────────────────────────────"
if [ -f "$ROOT/package.json" ] && command -v npm &>/dev/null; then
  echo "  Running npm update..."
  if (cd "$ROOT" && npm update >/dev/null 2>&1); then
    _ok "npm project deps"
  else
    _warn "npm project deps (update failed)"
  fi
else
  _skip "npm project deps (no package.json or npm not found)"
fi

# ── 7. git submodules ─────────────────────────────────────────
echo ""
echo "── git submodules ───────────────────────────────────────"
if git -C "$ROOT" submodule status >/dev/null 2>&1 && \
   git -C "$ROOT" submodule status 2>/dev/null | grep -q .; then
  echo "  Pulling latest submodule commits..."
  if git -C "$ROOT" submodule update --remote 2>/dev/null; then
    _ok "git submodules updated"
  else
    _skip "git submodules (up-to-date or local uncommitted changes)"
  fi
else
  _skip "git submodules (none configured)"
fi

# ── 8. LightRAG import verification ──────────────────────────
echo ""
echo "── LightRAG verification ────────────────────────────────"
if [ -d "$ROOT/tools/lightrag-plus/.venv" ]; then
  if (cd "$ROOT/tools/lightrag-plus" && uv run python -c \
      "from lightrag import LightRAG, QueryParam" >/dev/null 2>&1); then
    _ok "LightRAG import"
  else
    _warn "LightRAG import failed — run: cd tools/lightrag-plus && uv pip check"
  fi
else
  _skip "LightRAG venv (not found)"
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════════"
printf "  Updated: %d  |  Skipped: %d  |  Failed: %d\n" \
  "${#UPDATED[@]}" "${#SKIPPED[@]}" "${#FAILED[@]}"
if [ "${#FAILED[@]}" -gt 0 ]; then
  echo ""
  echo "  Failed:"
  for f in "${FAILED[@]}"; do echo "    • $f"; done
fi
echo ""
echo "  Not auto-updated (manual steps):"
echo "    Plugins  — claude plugin install <name>@<marketplace>"
echo "    MCP      — restart Claude Code (npx @latest packages refresh automatically)"
echo "    lightrag — uv.lock governs version; cd tools/lightrag-plus && python check_update.py"
echo "══════════════════════════════════════════════════════════"
