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

# Configure platform-specific OpenSpace paths
if [ -f "$ROOT/.env" ]; then
  if [[ -n "$HOME" ]]; then
    SKILLS_DIR="$HOME/.claude/skills"
  elif [[ -n "$USERPROFILE" ]]; then
    SKILLS_DIR="$USERPROFILE/.claude/skills"
  else
    SKILLS_DIR="~/.claude/skills"
  fi

  if grep -q "OPENSPACE_HOST_SKILL_DIRS=~/\.claude/skills" "$ROOT/.env" 2>/dev/null; then
    sed "s|OPENSPACE_HOST_SKILL_DIRS=~/\.claude/skills|OPENSPACE_HOST_SKILL_DIRS=$SKILLS_DIR|g" \
      "$ROOT/.env" > "$ROOT/.env.tmp" && mv "$ROOT/.env.tmp" "$ROOT/.env"
    echo "✓ OpenSpace skills path configured: $SKILLS_DIR"
  fi
fi
