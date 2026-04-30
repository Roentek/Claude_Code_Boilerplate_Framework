#!/bin/bash
# ============================================================
# Claude Code Stop Hook
# Runs at the end of every session. Scans for notable patterns
# and checks whether tracked paths changed during the session
# to prompt doc updates before the next commit.
# ============================================================

CONTEXT=$(cat)

# ── Auto-draft memory entries ───────────────────────────────
DRAFT_MSG=$(echo "$CONTEXT" | python "$(dirname "$0")/../scripts/memory-drafter.py" 2>/dev/null || true)

# ── Session quality scan ────────────────────────────────────
STRONG_PATTERNS="fixed|workaround|gotcha|that's wrong|check again|we already|should have|discovered|realized|turns out"
WEAK_PATTERNS="error|bug|issue|problem|fail"

SESSION_MSG=""
if echo "$CONTEXT" | grep -qiE "$STRONG_PATTERNS"; then
    SESSION_MSG="This session involved fixes or discoveries. Consider running /reflect to capture learnings in project docs."
elif echo "$CONTEXT" | grep -qiE "$WEAK_PATTERNS"; then
    SESSION_MSG="If you learned something non-obvious this session, run /reflect to update docs."
fi

# ── Doc-sync check ──────────────────────────────────────────
# Checks both unstaged and staged changes for paths that affect
# CLAUDE.md and README.md documentation.
TRACKED_PATTERN="^\.claude/(rules|agents|skills|hooks|scripts)/|^\.mcp\.json|^workflows/|^tools/"
CHANGED_TRACKED=$( (git diff --name-only 2>/dev/null; git diff --staged --name-only 2>/dev/null) | sort -u | grep -E "$TRACKED_PATTERN" || true )

DOC_MSG=""
if [ -n "$CHANGED_TRACKED" ]; then
    COUNT=$(echo "$CHANGED_TRACKED" | wc -l | tr -d ' ')
    DOC_MSG="${COUNT} tracked file(s) changed this session may need CLAUDE.md/README.md updated. Commit to trigger auto-sync, or update manually now."
fi

# ── Combine and output ──────────────────────────────────────
PARTS=()
[ -n "$SESSION_MSG" ] && PARTS+=("$SESSION_MSG")
[ -n "$DOC_MSG" ]     && PARTS+=("$DOC_MSG")
[ -n "$DRAFT_MSG" ]   && PARTS+=("$DRAFT_MSG")

if [ ${#PARTS[@]} -eq 0 ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

FINAL=$(IFS=" | "; echo "${PARTS[*]}")

# Escape double-quotes for JSON safety
SAFE=$(echo "$FINAL" | sed 's/"/\\"/g')
echo "{\"decision\":\"approve\",\"systemMessage\":\"${SAFE}\"}"
