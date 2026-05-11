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
<!-- Drafted 2026-05-11 — edit or delete below -->
- `./CLAUDE.md` (Project Root) â€” 390 lines\n\n**Score: 95/100 (Grade: A)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 20/20 | All commands copy-paste ready, labeled by tool |\n| Architecture clarity | 18/20 | Routing table + WAT framework excellent; LightRAG structure stale |\n| Non-obvious patterns | 14/15 | MCP env var gotcha, proxy fix, CLI-first pattern documented |\n| Conciseness | 13/15 | 390 lines â€” justified; one verbose block (stale LightRAG src/) |\n| Currency | 14/15 | `/spline-3d` now in Skills table âœ“; LightRAG enhanced branch info still present |\n| Actionability | 15/15 | All commands executable |\n\n**Issues:**\n\n1.
