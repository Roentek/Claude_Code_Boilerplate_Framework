#!/usr/bin/env bash
# Copy all project skills from .claude/skills/ → ~/.claude/skills/.
# Each skill dir must contain SKILL.md. Entire directory is copied (supports
# skills that ship with docs/, examples/, templates/ alongside SKILL.md).
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$INSTALL_DIR/lib.sh"

USER_HOME="$(_user_home)"
if [[ -z "$USER_HOME" ]]; then
  echo "  ✗ Cannot determine home directory — skipping project skills"
  exit 1
fi

SKILLS_SRC="$ROOT/.claude/skills"
SKILLS_DEST="$USER_HOME/.claude/skills"
COUNT=0

if [ ! -d "$SKILLS_SRC" ]; then
  echo "  (.claude/skills/ not found — skipping)"
  exit 0
fi

mkdir -p "$SKILLS_DEST"

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue

  dest_dir="$SKILLS_DEST/$skill_name"
  rm -rf "$dest_dir"
  mkdir -p "$dest_dir"
  cp -r "$skill_dir"/* "$dest_dir/" 2>/dev/null

  if [ -f "$dest_dir/SKILL.md" ]; then
    echo "  ✓ $skill_name → $dest_dir/"
    COUNT=$((COUNT + 1))
  else
    echo "  ✗ $skill_name copy failed"
  fi
done

if [ $COUNT -eq 0 ]; then
  echo "  (no skills found in .claude/skills/)"
else
  echo "  $COUNT skill(s) installed. Restart Claude Code to activate."
fi
