#!/usr/bin/env bash
# Install claude-obsidian plugin — Obsidian + Claude AI second brain / wiki vault
# Standalone: bash .claude/hooks/install/plugin-claude-obsidian.sh
#
# Skills: /wiki, /wiki-ingest, /wiki-query, /wiki-lint, /wiki-cli, /wiki-retrieve,
#         /wiki-mode, /wiki-fold, /save, /canvas, /think
# After install: run /wiki to scaffold vault or open an existing Obsidian vault

. "$(dirname "$0")/lib.sh"

echo "  Installing claude-obsidian plugin (claude-obsidian@agricidaniel-claude-obsidian)..."
_install_plugin "claude-obsidian" "agricidaniel-claude-obsidian"

echo ""
echo "  First-run setup (run inside the vault directory):"
echo "    /wiki                        — scaffold new vault or check setup status"
echo "    bash bin/setup-retrieve.sh   — opt-in: hybrid BM25 + cosine-rerank retrieval"
echo "    bash bin/setup-mode.sh       — set methodology mode (LYT / PARA / Zettelkasten / Generic)"
echo ""
echo "  Obsidian CLI transport (optional — falls back to filesystem if absent):"
if _is_windows; then
  echo "    winget install Obsidian.Obsidian"
else
  echo "    brew install --cask obsidian  (macOS)"
fi
echo "  No API key required."
