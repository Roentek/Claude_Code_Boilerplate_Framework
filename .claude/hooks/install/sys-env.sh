#!/usr/bin/env bash
# Create .env from .env.example and configure platform-specific paths (OpenSpace).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

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

# Configure OpenSpace runtime skill dirs.
# The agent evolves skills by rewriting SKILL.md at each skill's path — so point at the
# git-tracked REPO source (durable, committable), NOT the global installed copies. Global
# ~/.claude/skills stays out of runtime; seed it into the dashboard tree on demand via
# `tools/openspace_overrides/seed_openspace_skills.py --include-global`.
# Paths MUST be native — Windows Python can't resolve git-bash /c/... paths (Path.exists()=False).
if [ -f "$ROOT/.env" ]; then
  # Native repo root: cygpath -m gives C:/... on Windows; passthrough on Unix.
  if command -v cygpath >/dev/null 2>&1; then
    REPO_NATIVE="$(cygpath -m "$ROOT")"
  else
    REPO_NATIVE="$ROOT"
  fi
  SKILL_DIRS_VALUE="$REPO_NATIVE/.claude/skills"

  # Only rewrite the untouched placeholder — never clobber a customized value.
  if grep -q "OPENSPACE_HOST_SKILL_DIRS=~/\.claude/skills" "$ROOT/.env" 2>/dev/null; then
    sed "s|OPENSPACE_HOST_SKILL_DIRS=~/\.claude/skills|OPENSPACE_HOST_SKILL_DIRS=$SKILL_DIRS_VALUE|g" \
      "$ROOT/.env" > "$ROOT/.env.tmp" && mv "$ROOT/.env.tmp" "$ROOT/.env"
    echo "✓ OpenSpace runtime skill dirs (repo): $SKILL_DIRS_VALUE"

    # .mcp.json forwards ${OPENSPACE_HOST_SKILL_DIRS} from the OS environment, not .env —
    # persist to OS env so the MCP server process actually receives it (Windows only).
    if _is_windows && command -v setx >/dev/null 2>&1; then
      setx OPENSPACE_HOST_SKILL_DIRS "$SKILL_DIRS_VALUE" >/dev/null 2>&1 \
        && echo "✓ OS env OPENSPACE_HOST_SKILL_DIRS set (restart Claude Code to apply)"
    fi
  fi
fi
