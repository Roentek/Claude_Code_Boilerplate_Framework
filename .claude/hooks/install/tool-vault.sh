#!/usr/bin/env bash
# Scaffold the Obsidian vault/ directory in the project root. Idempotent.
# Shared layer (wiki/) is gittracked. Private layer (private/) is gitignored.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

echo "=== Step: Obsidian Vault ==="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Walk up to find project root (contains CLAUDE.md)
PROJECT_ROOT="$SCRIPT_DIR"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; do
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
VAULT_DIR="$PROJECT_ROOT/vault"

if [ -f "$VAULT_DIR/CLAUDE.md" ]; then
  echo "  [skip] Vault already scaffolded ($VAULT_DIR)"
else
  echo "  Vault not found or incomplete — scaffold is handled by git (vault/ is in the repo)"
  echo "  Ensuring private/ directories exist (gitignored, not tracked)..."
fi

# Always ensure private/ dirs exist (gitignored, won't be cloned)
mkdir -p "$VAULT_DIR/private/sessions"
mkdir -p "$VAULT_DIR/private/projects"
mkdir -p "$VAULT_DIR/private/agents"
mkdir -p "$VAULT_DIR/.raw"

# Create private/hot.md if missing (gitignored — each user starts fresh)
if [ ! -f "$VAULT_DIR/private/hot.md" ]; then
  cat > "$VAULT_DIR/private/hot.md" << 'EOF'
---
type: meta
title: "Private Hot Cache"
updated: YYYY-MM-DD
tags: [meta, hot-cache, private]
---

# Private Hot Cache

> This file is gitignored. Personal context only.

## Last Updated
[date]. Vault initialized on this machine.

## Current Focus
[What you're working on right now]

## Open Threads
[Things in progress across sessions]
EOF
  echo "  Created private/hot.md"
fi

# Initialize git in vault if not already done
if [ ! -d "$VAULT_DIR/.git" ]; then
  echo "  Initializing git in vault/..."
  cd "$VAULT_DIR"
  git init -q
  git add -A
  git commit -q -m "Initial vault scaffold"
  echo "  Git initialized in vault/"
else
  echo "  [skip] vault/.git already exists"
fi

echo "  Vault ready at: $VAULT_DIR"
echo "  Open in Obsidian: Manage Vaults > Open Folder as Vault > select vault/"
