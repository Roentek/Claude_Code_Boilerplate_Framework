#!/usr/bin/env python3
"""
memory-drafter.py — Stop hook helper
Scans the session transcript for signals that warrant memory updates,
then appends draft entries to the appropriate memory-*.md files.
Drafts are marked so the user can review before they become permanent.
"""
import json
import sys
import re
import os
from datetime import date

RULES_DIR = os.path.join(os.path.dirname(__file__), "..", "rules")
TODAY = date.today().isoformat()

PATTERNS = {
    "memory-decisions.md": [
        r"\b(decided|we('ll| will) use|chose|going with|switched to|replacing|architecture)\b",
        r"\b(from now on|always use|never use|rule is|policy is)\b",
    ],
    "memory-preferences.md": [
        r"\b(prefer|i like|i don't like|i hate|please (always|never)|stop doing|keep doing)\b",
        r"\b(response style|be (more|less)|shorter|longer|concise|verbose)\b",
    ],
    "memory-sessions.md": [
        r"\b(implemented|created|built|added|fixed|resolved|discovered|realized|turns out|gotcha)\b",
    ],
}

DRAFT_TAG = "<!-- DRAFT: review and edit before treating as permanent -->"


def extract_sentences(text: str) -> list[str]:
    sentences = re.split(r'(?<=[.!?])\s+', text)
    return [s.strip() for s in sentences if len(s.strip()) > 30]


def find_matches(text: str, patterns: list[str]) -> list[str]:
    matches = []
    for sentence in extract_sentences(text):
        for pattern in patterns:
            if re.search(pattern, sentence, re.IGNORECASE):
                matches.append(sentence)
                break
    return list(dict.fromkeys(matches))[:3]  # dedupe, cap at 3


def append_draft(filename: str, entries: list[str]) -> None:
    filepath = os.path.join(RULES_DIR, filename)
    if not os.path.exists(filepath):
        return
    block_lines = [f"\n\n{DRAFT_TAG}\n"]
    if filename == "memory-sessions.md":
        block_lines.append(f"## {TODAY} (auto-drafted — review before next session)\n")
        for e in entries:
            block_lines.append(f"- {e}\n")
    else:
        block_lines.append(f"<!-- Drafted {TODAY} — edit or delete below -->\n")
        for e in entries:
            block_lines.append(f"- {e}\n")
    with open(filepath, "a", encoding="utf-8") as f:
        f.writelines(block_lines)


def main() -> None:
    raw = sys.stdin.read()
    # Extract plain text from JSON transcript if present
    try:
        data = json.loads(raw)
        # Transcript may be a list of messages or a dict with a transcript key
        if isinstance(data, list):
            text = " ".join(
                m.get("content", "") if isinstance(m.get("content"), str)
                else " ".join(c.get("text", "") for c in m.get("content", []) if isinstance(c, dict))
                for m in data if isinstance(m, dict)
            )
        elif isinstance(data, dict):
            text = data.get("transcript", raw)
        else:
            text = raw
    except (json.JSONDecodeError, TypeError):
        text = raw

    if not text or len(text) < 100:
        return

    drafted = []
    for filename, patterns in PATTERNS.items():
        matches = find_matches(text, patterns)
        if matches:
            append_draft(filename, matches)
            drafted.append(f"{filename} ({len(matches)} draft entries)")

    if drafted:
        # Plain string — stop.sh captures this and merges into its own JSON output
        print("Memory drafts appended to: " + ", ".join(drafted) + ". Review before next session.")


if __name__ == "__main__":
    main()
