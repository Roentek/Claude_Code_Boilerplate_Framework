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
#   • plugins      — add to PLUGINS below + setup.sh step 7
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
)

if command -v npm &>/dev/null; then
  for pkg in "${NPM_GLOBALS[@]}"; do
    label="${pkg##*/}"; label="${label%%@*}"
    # Check if installed (scope-aware)
    if npm list -g --depth=0 "${pkg}" &>/dev/null 2>&1; then
      printf "  Updating %-30s" "$pkg..."
      if npm install -g "${pkg}@latest" >/dev/null 2>&1; then
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

# ── 4. npm project dependencies ───────────────────────────────
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

# ── 5. git submodules ─────────────────────────────────────────
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

# ── 6. LightRAG import verification ──────────────────────────
echo ""
echo "── LightRAG verification ────────────────────────────────"
if [ -d "$ROOT/tools/lightrag/.venv" ]; then
  if (cd "$ROOT/tools/lightrag" && uv run python -c \
      "from lightrag import LightRAG, QueryParam" >/dev/null 2>&1); then
    _ok "LightRAG import"
  else
    _warn "LightRAG import failed — run: cd tools/lightrag && uv pip check"
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
echo "    lightrag — uv.lock governs version; cd tools/lightrag && python check_update.py"
echo "══════════════════════════════════════════════════════════"
