#!/bin/bash
CONTEXT=$(cat)

STRONG_PATTERNS="fixed|workaround|gotcha|that's wrong|check again|we already|should have|discovered|realized|turns out"
WEAK_PATTERNS="error|bug|issue|problem|fail"

if echo "$CONTEXT" | grep -qiE "$STRONG_PATTERNS"; then
    cat << 'EOF'
{
  "decision": "approve",
  "systemMessage": "This session involved fixes or discoveries. Consider running /reflect to capture learnings in project docs."
}
EOF
elif echo "$CONTEXT" | grep -qiE "$WEAK_PATTERNS"; then
    echo '{"decision":"approve","systemMessage":"If you learned something non-obvious this session, run /reflect to update docs."}'
else
    echo '{"decision": "approve"}'
fi