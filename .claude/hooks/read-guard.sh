#!/usr/bin/env bash
# PreToolUse hook — warns when large files are read without offset+limit to save tokens.
# Delegates to read-guard.py; stdin (JSON hook payload) is forwarded automatically.
python "$(dirname "$0")/../scripts/read-guard.py"
