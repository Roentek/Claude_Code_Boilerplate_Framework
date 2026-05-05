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


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-04 — edit or delete below -->
- For example:\n\n```env\n# Option A: Single storage type selector\nLIGHTRAG_STORAGE_BACKEND=supabase  # or: local, pinecone\n\n# Option B: Boolean flags\nLIGHTRAG_USE_SUPABASE=true\nLIGHTRAG_USE_PINECONE=false\n```\n\nWhich pattern do you prefer?\n\n### 6.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-04 — edit or delete below -->
- I'll ask one key question at a time.\n\n## Question 1: Multimodal Processing Strategy\n\nYour reference repo has specialized ingestors that extract text/metadata from multimodal files before embedding:\n\n- **Images**: Resize if needed, then embed the raw image bytes\n- **Video**: Extract keyframes every 5 seconds, embed each frame  \n- **Audio**: Embed the raw audio file directly\n\nLightRAG's strength is its knowledge graph built from text entities and relationships.\n\n**Which approach do you prefer for multimodal integration?**\n\n**A) Multimodal-First** (closer to your reference repo)\n- Embed images/video/audio directly with Gemini\n- Store these embeddings ONLY in Supabase/Pinecone (not in LightRAG's graph)\n- At query time: search both LightRAG graph (text) and Supabase/Pinecone (multimodal)\n- Pro: Preserves multimodal semantic search exactly as your reference repo does\n- Con: Creates two separate search systems\n\n**B) Text-Extraction Bridge** (preserves LightRAG graph)\n- Preprocess multimodal files to extract text (OCR for images, transcription for audio/video)\n- Feed the extracted text to LightRAG â†’ builds graph with entities/relations\n- Also embed original multimodal content with Gemini â†’ store in Supabase/Pinecone\n- Pro: Everything participates in the knowledge graph\n- Con: Adds dependency on OCR/transcription services\n\n**C) Hybrid** (my recommendation)\n- Support both workflows as options\n- Simple mode: Extract text only, feed to LightRAG (no multimodal embeddings)\n- Advanced mode: Extract text for graph + embed multimodal for vector search\n- Pro: Maximum flexibility\n- Con: More configuration complexity\n\nWhich approach fits your workflow best?"}


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-04 — edit or delete below -->
- Moving to the next question.\n\n## Question 2: Query-Time Search Strategy\n\nWhen a user queries the system and you have multiple backends enabled (local graph + Supabase + Pinecone), how should the system search?\n\n**A) Sequential Fallback**\n- Search LightRAG graph first (primary)\n- If no good results (low confidence), then search Supabase/Pinecone\n- Pro: Fast, predictable latency\n- Con: May miss relevant multimodal content if text results are \"good enough\"\n\n**B) Parallel Search + Merge**\n- Search all enabled backends simultaneously\n- Merge and re-rank results by similarity score\n- Return top-K combined results\n- Pro: Best recall, leverages all available data\n- Con: Higher latency (waits for slowest backend), needs ranking strategy\n\n**C) Mode-Based Routing** (my recommendation)\n- Text queries â†’ LightRAG graph only\n- Multimodal queries (or queries with `--multimodal` flag) â†’ all backends\n- Explicit mode parameter: `query(..., mode=\"graph\")` vs `query(..., mode=\"hybrid\")`\n- Pro: User controls speed vs comprehensiveness trade-off\n- Con: Requires users to understand when to use which mode\n\n**D) User-Configurable Default**\n- Set a default strategy in config (e.g., `QUERY_STRATEGY=parallel` or `QUERY_STRATEGY=graph-only`)\n- Allow per-query override via parameter\n- Pro: Works well out of the box, advanced users can customize\n- Con: Needs sensible default\n\nWhich query strategy do you prefer?


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-04 — edit or delete below -->
- Moving on.\n\n## Question 3: Embedding Sync & Error Handling\n\nWhen LightRAG generates embeddings and you have Supabase/Pinecone enabled, the system needs to mirror those embeddings to the remote backends.\n\n**Sync Timing:**\n\n**A) Synchronous** (my recommendation for simplicity)\n- During `insert()`, embed locally â†’ immediately mirror to enabled backends\n- Operation only completes when all backends succeed or fail\n- Pro: Simple, consistent state across backends\n- Con: Slower inserts if remote APIs are slow\n\n**B) Async Fire-and-Forget**\n- Insert to local graph immediately\n- Queue background task to sync to remote backends\n- Pro: Fast inserts\n- Con: Temporary inconsistency, needs queue infrastructure\n\n**C) Manual Sync**\n- Insert to local only by default\n- Provide explicit `sync_to_remotes()` function user calls when ready\n- Pro: Full user control, no surprises\n- Con: Easy to forget, backends can drift\n\n**Error Handling:**\n\nIf Supabase or Pinecone fails during sync (API down, auth error, rate limit):\n\n**A) Fail Entire Operation** (strict consistency)\n- Rollback local insert, raise error\n- Pro: All-or-nothing guarantees\n- Con: Local graph unavailable if remote is down\n\n**B) Log Warning, Continue** (my recommendation)\n- Insert succeeds locally even if remote fails\n- Log the error with retry details\n- Optionally: store failed syncs for later retry\n- Pro: System stays usable, LightRAG always works\n- Con: Backends can be out of sync\n\nWhich combination do you prefer?


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-04 — edit or delete below -->
- `src/lightrag_enhanced.py` - Wrapper that injects adapters into LightRAG\n\n**Does this approach sound good, or would you prefer one of the others?**"}
