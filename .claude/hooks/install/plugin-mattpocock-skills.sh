#!/usr/bin/env bash
# Install mattpocock-skills plugin — engineering skills for real engineers
# Standalone: bash .claude/hooks/install/plugin-mattpocock-skills.sh
#
# Skills: /grill-with-docs, /tdd, /to-prd, /to-issues, /triage, /improve-codebase-architecture,
#         /prototype, /diagnosing-bugs, /domain-modeling, /codebase-design, /grill-me,
#         /handoff, /teach, /writing-great-skills, /grilling, /ask-matt
# After install: run /setup-matt-pocock-skills once per repo to configure issue tracker + labels

. "$(dirname "$0")/lib.sh"

echo "  Installing mattpocock-skills plugin (mattpocock-skills@mattpocock-skills)..."
_install_plugin "mattpocock-skills" "mattpocock-skills"
