# User Preferences

Stated preferences about how Claude should behave, communicate, and structure work. Update this file immediately when the user expresses a preference or corrects an approach.

---

<!-- Example entry format:
- **Response style:** Concise — lead with the answer, skip preamble
- **Code style:** No trailing summaries after edits; the diff speaks for itself
- **Commits:** Always bundle related changes into one PR rather than splitting
- **Error handling:** Only validate at system boundaries; don't add defensive checks inside internal code
- **Testing:** Integration tests must hit a real database — no mocks
-->


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-04-30 — edit or delete below -->
- All 5 optimizations are complete.\n\n---\n\nHere's what was implemented:\n\n| # | Optimization | Files Changed |\n|---|---|---|\n| 1 | **context7 MCP** â€” live SDK docs on demand | `.mcp.json`, `settings.json` |\n| 2 | **trigger-api-reference.md moved** â€” stops auto-loading every session (~200 lines saved) | `.claude/docs/`, `trigger-workflow-builder.md`, `CLAUDE.md` |\n| 3 | **memory-distiller agent** â€” compresses sessions >30 days into archive | `.claude/agents/memory-distiller.md` |\n| 4 | **`/compact-memory` skill** â€” full hygiene: compress, prune, sync to MCP graph | `.claude/skills/compact-memory/SKILL.md`, `~/.claude/skills/` |\n| 5 | **read-guard PreToolUse hook** â€” warns on unscoped reads of large files | `.claude/hooks/read-guard.py`, `settings.json` |\n| + | **Stop hook enhanced** â€” auto-drafts memory entries from session transcript | `.claude/scripts/memory-drafter.py`, `.claude/hooks/stop.sh` |\n\n**To activate context7:** Restart Claude Code â€” it will pick up the new MCP server from `.mcp.json` automatically.\n\n**Immediate token savings:** `trigger-api-reference.md` no longer loads every session (~200 lines).


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-04-30 — edit or delete below -->
- Here's a summary of all three changes made:\n\n| File | Change | Reason |\n|------|--------|--------|\n| `setup.sh` | Python detection now tests actual execution (`python3 --version` exit code) instead of `command -v`; also tries `py` as fallback | Windows has a fake `python3.exe` Store alias that fools `command -v` but exits 49 â€” was showing empty version `()` |\n| `setup.sh` | Switched `grep -oP` â†’ `grep -oE` for version extraction | `-P` (Perl regex) not available in Git Bash on Windows |\n| `read-guard.py` | Raised `MIN_LINES_WARNING` from 80 â†’ 200; shortened systemMessage format | 80 lines is too aggressive â€” fires on many normal files; verbose message added tokens every read |"}


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-04-30 — edit or delete below -->
- Path Updates\n- âœ“ **README.md** (3 locations) â€” updated paths, added \"(reference-only, not auto-loaded)\" note\n- âœ“ **frontend-instructions.md** (2 locations) â€” fixed relative paths to `../docs/ui-ux-pro-max-instructions.md`\n- âœ“ **read-guard.py** â€” removed ui-ux-pro-max from large-file warnings (no longer auto-loaded)\n\n### 3.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-03 — edit or delete below -->
- {"session_id":"9e748c9e-4fc6-4527-8328-8107e87d386a","transcript_path":"C:\\Users\\mdmor\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\9e748c9e-4fc6-4527-8328-8107e87d386a.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"acceptEdits","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"For this simple setting, you can use the `/config` slash command instead:\n\n```\n/config permissions.defaultMode bypassPermissions\n```\n\nThis is faster than manually editing settings.json for basic settings like permission mode, theme, model, etc.\n\nHowever, if you'd prefer I edit settings.json directly, I can do that too.
