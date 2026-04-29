#!/usr/bin/env python
import json, sys, re

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

path = data.get('tool_input', {}).get('file_path', '')
if not path:
    sys.exit(0)

p = path.replace('\\', '/')

# Never fire on the doc files themselves to avoid update loops
if re.search(r'(CLAUDE\.md|README\.md)$', p):
    sys.exit(0)

tracked = [
    r'\.claude/(rules|agents|skills|hooks|scripts)/',
    r'workflows/',
    r'(^|/)tools/',
    r'\.mcp\.json$',
]

for pattern in tracked:
    if re.search(pattern, p):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PostToolUse",
                "additionalContext": (
                    f"AUTOSYNC: '{path}' is in a tracked path. "
                    "Per memory-guidelines.md, update CLAUDE.md and/or README.md NOW "
                    "if this change affects project structure, rules, hooks, MCP servers, or configuration. "
                    "Do not wait until end of session."
                )
            }
        }))
        break

sys.exit(0)
