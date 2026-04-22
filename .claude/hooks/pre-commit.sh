#!/bin/bash
# ============================================================
# Doc-Sync Pre-Commit Hook
# Detects staged changes to tracked paths and automatically
# updates CLAUDE.md and README.md before the commit lands.
#
# Installed to .git/hooks/pre-commit by .claude/scripts/setup.sh.
# The wrapper in .git/hooks/ calls this file so updates here
# take effect immediately on the next commit.
# ============================================================

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Paths whose changes are likely to affect CLAUDE.md / README.md
TRACKED_PATTERN="^\.claude/(rules|agents|skills|hooks|scripts)/|^\.mcp\.json|^workflows/|^tools/"

STAGED=$(git diff --staged --name-only 2>/dev/null)
[ -z "$STAGED" ] && exit 0

RELEVANT=$(echo "$STAGED" | grep -E "$TRACKED_PATTERN" || true)
[ -z "$RELEVANT" ] && exit 0

# If the user already staged CLAUDE.md or README.md alongside tracked files,
# trust their manual update and skip auto-sync.
if echo "$STAGED" | grep -qE "^(CLAUDE\.md|README\.md)$"; then
    echo "doc-sync: CLAUDE.md/README.md already staged — skipping auto-update."
    exit 0
fi

echo ""
echo "doc-sync: tracked paths changed — syncing CLAUDE.md and README.md..."
RELEVANT_DISPLAY=$(echo "$RELEVANT" | head -5 | tr '\n' ' ')
echo "  files: $RELEVANT_DISPLAY"

# Require claude CLI — fail gracefully, never block commits
if ! command -v claude &>/dev/null; then
    echo "  warning: claude CLI not found — update docs manually if needed."
    exit 0
fi

CHANGED_LIST=$(echo "$RELEVANT" | tr '\n' ' ')
PROMPT="The following files were staged for a git commit and they affect what is documented in CLAUDE.md and README.md: ${CHANGED_LIST}. Read both files, then apply only the targeted changes needed to keep them accurate — update project structure trees, tables, and any section content that directly references these paths. Do not rewrite or touch sections unaffected by these specific files."

# Run claude non-interactively.
# --dangerously-skip-permissions prevents interactive prompts in the
# non-TTY git hook environment; this is safe because the operation is
# scoped to reading and editing local doc files only.
claude --print "$PROMPT" --dangerously-skip-permissions > /dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "  warning: doc-sync encountered an error (exit $EXIT_CODE) — verify CLAUDE.md/README.md manually."
    exit 0
fi

# Stage the updated docs alongside the original changes
git add "$ROOT/CLAUDE.md" "$ROOT/README.md" 2>/dev/null

echo "  done."
echo ""
exit 0
