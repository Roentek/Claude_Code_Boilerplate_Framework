#!/usr/bin/env bash
# ============================================================
# Claude Code Boilerplate Framework — First-Time Setup
# Runs once via the "Setup" hook when Claude Code initializes
# the project for the first time on a new machine.
#
# Architecture: each installable element lives in its own
# .claude/hooks/install/<category>-<name>.sh script.
# Run any of those standalone to install just that component.
# ============================================================

MARKER=".claude/.setup-complete"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [ -f "$ROOT/$MARKER" ]; then
  exit 0
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Claude Code Boilerplate — First-Time Setup         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

INSTALL="$ROOT/.claude/hooks/install"
ERRORS=0

_run() {
  # Run an install script; accumulate ERRORS on hard failure (exit 1).
  local script="$INSTALL/$1"
  if [ -f "$script" ]; then
    bash "$script" || ERRORS=$((ERRORS + 1))
  else
    echo "⚠ Missing install script: $1"
  fi
}

# ── System prerequisites ────────────────────────────────────
echo "── System Prerequisites ─────────────────────────────────"
_run sys-hooks.sh
_run sys-python.sh
_run sys-context-monitor.sh
_run sys-env.sh
echo ""
echo "── Runtime Checks ───────────────────────────────────────"
_run sys-uvx.sh
_run sys-node.sh
_run sys-ffmpeg.sh

# ── Marketplace plugins ─────────────────────────────────────
echo ""
echo "── Marketplace Plugins ──────────────────────────────────"
_run plugin-ui-ux-pro-max.sh
_run plugin-karpathy.sh
_run plugin-impeccable.sh
_run plugin-codex.sh
_run plugin-gemini.sh
_run plugin-cli-anything.sh
_run plugin-claude-video.sh
_run plugin-ponytail.sh
_run plugin-mattpocock-skills.sh
_run plugin-claude-obsidian.sh
_run plugin-higgsfield.sh
echo ""
echo "  Marketplace sources pre-configured in .claude/settings.json → extraKnownMarketplaces"

# ── Apify marketplace skills ────────────────────────────────
echo ""
echo "── Apify Agent Skills ───────────────────────────────────"
echo "   Source: https://github.com/apify/agent-skills"
_run skill-apify-ultimate-scraper.sh
_run skill-apify-actor-development.sh
_run skill-apify-actorization.sh
_run skill-apify-generate-output-schema.sh
_run skill-apify-actor-commands.sh

# ── Token compression + context optimization ────────────────
echo ""
echo "── Token Compression + Context Optimization ─────────────"
_run plugin-caveman.sh
_run plugin-context-mode.sh
_run sys-bun.sh
_run plugin-claude-mem.sh

# ── Design language ─────────────────────────────────────────
echo ""
echo "── Design Language ──────────────────────────────────────"
_run cli-designlang.sh
_run plugin-designlang.sh

# ── Project skills ──────────────────────────────────────────
echo ""
echo "── Project Skills (~/.claude/skills/) ──────────────────"
_run skills-project.sh

# ── npm dependencies + Playwright browser ──────────────────
echo ""
echo "── npm Dependencies + Playwright Browser ────────────────"
_run sys-npm-deps.sh

# ── GitHub CLI ──────────────────────────────────────────────
echo ""
echo "── GitHub CLI ───────────────────────────────────────────"
_run sys-github-cli.sh

# ── Supabase CLI ─────────────────────────────────────────────
echo ""
echo "── Supabase CLI ─────────────────────────────────────────"
_run sys-supabase-cli.sh

# ── Global CLI tools ────────────────────────────────────────
echo ""
echo "── Global CLI Tools ─────────────────────────────────────"
_run cli-skillui.sh
_run cli-firecrawl.sh
_run cli-codex.sh
_run cli-gemini.sh
_run cli-notebooklm.sh
_run cli-codeburn.sh
_run cli-browser-harness.sh
_run cli-kie.sh
_run cli-higgsfield.sh
_run cli-llmfit.sh

# ── Authentication reminders ─────────────────────────────────
_run auth-reminders.sh

# ── Heavy tools (long-running — shown last) ─────────────────
echo ""
echo "── AutoResearch (Autonomous ML Research) ────────────────"
_run tool-autoresearch.sh

echo ""
echo "── LightRAG (Graph-Based RAG) ───────────────────────────"
_run tool-lightrag.sh

echo ""
echo "── Ollama (Local LLM) ───────────────────────────────────"
_run tool-ollama.sh

echo ""
echo "── OpenSpace (Self-Evolving Skill System) ───────────────"
_run tool-openspace.sh

echo ""
echo "── Graphify (Codebase Knowledge Graph) ─────────────────"
_run tool-graphify.sh

echo ""
echo "── Obsidian (App + Vault + MCP) ────────────────────────"
_run sys-obsidian.sh
_run tool-vault.sh
_run mcp-vault.sh

# ── Git pre-commit hook ──────────────────────────────────────
echo ""
echo "── Git Pre-Commit Hook ──────────────────────────────────"
_run sys-pre-commit.sh

# ── Summary ─────────────────────────────────────────────────
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✓ Setup complete."
  touch "$ROOT/$MARKER"
else
  echo "✗ Setup finished with $ERRORS error(s). Fix the issues above, then"
  echo "  delete $MARKER and re-open Claude Code."
fi
echo ""
echo "  To install any component individually:"
echo "    bash .claude/hooks/install/<category>-<name>.sh"
echo ""
