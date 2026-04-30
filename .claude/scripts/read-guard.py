#!/usr/bin/env python3
"""
read-guard.py — PreToolUse hook for Read tool calls.
When Claude reads a known-large file without specifying a limit,
injects a warning suggesting offset+limit to save tokens.
Always approves — this is advisory only, never blocking.
"""
import json
import sys
import os

# Files known to be large and commonly read in full unnecessarily.
# Paths matched as suffix so they work regardless of absolute prefix.
LARGE_FILES = {
    "memory-sessions.md": "Use offset+limit — only read the section you need (e.g. recent entries are at the end).",
    "ui-ux-pro-max-instructions.md": "This file is ~300 lines. Use offset+limit or grep for a specific section.",
    "Claude_Code_Beginners_Guide.md": "Large reference doc. Use offset+limit to read specific pages/sections.",
    "Claude_Code_Context_Management_Hacks.md": "Large reference doc. Use offset+limit to read specific sections.",
    "The_Shift_to_Agentic_AI_Workflows.md": "Large reference doc. Use offset+limit to read specific sections.",
    "trigger-api-reference.md": "Large code-example file. Use offset+limit or search for the specific pattern you need.",
}

MIN_LINES_WARNING = 200  # only warn if file actually exceeds this (checked live)


def file_line_count(path: str) -> int:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return sum(1 for _ in f)
    except OSError:
        return 0


def main() -> None:
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        print(json.dumps({"decision": "approve"}))
        return

    tool_input = payload.get("tool_input", {})
    file_path = tool_input.get("file_path", "")
    has_limit = "limit" in tool_input
    has_offset = "offset" in tool_input

    if has_limit or has_offset:
        # Already scoped — no warning needed
        print(json.dumps({"decision": "approve"}))
        return

    basename = os.path.basename(file_path)
    hint = LARGE_FILES.get(basename)

    if hint:
        # Verify file is actually large before warning
        line_count = file_line_count(file_path)
        if line_count >= MIN_LINES_WARNING:
            msg = f"[read-guard] {basename} ({line_count} lines) — consider offset+limit. {hint}"
            print(json.dumps({"decision": "approve", "systemMessage": msg}))
            return

    print(json.dumps({"decision": "approve"}))


if __name__ == "__main__":
    main()
