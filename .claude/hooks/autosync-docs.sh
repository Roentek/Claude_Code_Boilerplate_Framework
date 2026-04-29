#!/usr/bin/env bash
# PostToolUse hook — detects edits to tracked paths and injects a reminder to sync CLAUDE.md/README.md.
# Delegates to autosync-docs.py; stdin (JSON hook payload) is forwarded automatically.
python "$(dirname "$0")/autosync-docs.py"
