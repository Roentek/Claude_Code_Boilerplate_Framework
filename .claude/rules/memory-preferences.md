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
