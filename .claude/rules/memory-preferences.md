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


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-12 — edit or delete below -->
- {"session_id":"7ec6afc9-d811-4029-985b-574facdf1531","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--Users-MorarMonil-OneDrive---TK-Elevator-Documents-GIT-Claude-Code-Boilerplate-Framework\\7ec6afc9-d811-4029-985b-574facdf1531.jsonl","cwd":"C:\\Users\\MorarMonil\\OneDrive - TK Elevator\\Documents\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"bypassPermissions","effort":{"level":"high"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"```\nfix(setup): verbose large installs, auto-pull Ollama on Windows\n```\n\nBody needed â€” two distinct non-obvious fixes:\n\n```\nfix(setup): verbose large installs, auto-pull Ollama on Windows\n\nLarge installs (PyTorch ~3GB, lightrag ~200MB, Playwright ~150MB,\nnpm -g tools) were fully suppressed â€” no way to tell if hung or\nprogressing.
- Removed --silent/>/dev/null; native progress shows.\n\nWindows Ollama path previously only printed manual instructions.\nNow attempts winget auto-install, then finds ollama.exe at\n%LOCALAPPDATA%\\Programs\\Ollama\\ (PATH not updated in-session after\nwinget) to run the pull without requiring a terminal restart.\n```\n\n---\n\n**Staged files:**\n```\n .claude/hooks/setup.sh           | 82 +++++++++++++++++++++++++++++-----------\n .claude/rules/memory-sessions.md |  5 +++\n README.md                        |  2 +-\n 3 files changed, 65 insertions(+), 24 deletions(-)\n```\n\n**Ready-to-run:**\n```bash\ngit commit -m \"fix(setup): verbose large installs, auto-pull Ollama on Windows\" -m \"Large installs (PyTorch ~3GB, lightrag ~200MB, Playwright ~150MB,\nnpm -g tools) were fully suppressed â€” no way to tell if hung or\nprogressing.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-12 — edit or delete below -->
- `ENABLE_*` flags no longer affect provisioning â€” they only control runtime mirroring.\n- **`test_lightrag.py`** â€” deleted.
