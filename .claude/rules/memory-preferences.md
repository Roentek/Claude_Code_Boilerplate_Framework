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


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-04 — edit or delete below -->
- **Verify Connection**:\n   ```bash\n   cd tools/lightrag\n   uv run python setup_backends.py\n   ```\n\n### Pinecone (if enabled)\n\n**Auto-created** by setup script - no manual steps required!\n\nThe setup script will:\n- Check if index exists\n- Create index with correct dimension if missing\n- Validate dimension matches `.env` config\n\n### Manual Setup (Alternative)\n\nIf you prefer to create Pinecone index manually:\n\n```python\nfrom pinecone import Pinecone, ServerlessSpec\n\npc = Pinecone(api_key=\"your-api-key\")\n\npc.create_index(\n    name=\"lightrag-vectors\",\n    dimension=3072,  # Match EMBEDDING_DIM\n    metric=\"cosine\",\n    spec=ServerlessSpec(cloud=\"aws\", region=\"us-east-1\")\n)\n```\n\n### Troubleshooting\n\n**Supabase dimension mismatch:**\n```\nError: operator does not exist: vector(1536) <=> vector(3072)\n```\nâ†’ Your schema has wrong dimension.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-07 — edit or delete below -->
- {"session_id":"8ee1971d-4530-405f-a762-55a7112f55b2","transcript_path":"C:\\Users\\mdmor\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\8ee1971d-4530-405f-a762-55a7112f55b2.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"bypassPermissions","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"## CLAUDE.md Quality Report\n\n### Summary\n- **Files found:** 1 (primary project root)\n- **Score:** 96/100 (Grade: **A**)\n- **Status:** Excellent â€” minor polish opportunities only\n\n---\n\n### Assessment: ./CLAUDE.md (Project Root)\n\n**Score: 96/100 (Grade: A)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 20/20 | Exceptional â€” 10+ command sections, all copy-paste ready |\n| Architecture clarity | 20/20 | Outstanding â€” routing table, WAT framework, full directory tree |\n| Non-obvious patterns | 14/15 | Strong â€” MCP gotcha, CLI-first patterns, hook behavior documented |\n| Conciseness | 12/15 | Good â€” 463 lines, comprehensive but some sections verbose |\n| Currency | 15/15 | Perfect â€” reflects current state, just updated today |\n| Actionability | 15/15 | Perfect â€” every command is executable, no vague instructions |\n\n---\n\n### Strengths\n\n**Outstanding:**\n1.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-07 — edit or delete below -->
- See [`tools/lightrag/README.md`](tools/lightrag/README.md).\n+ \n+ **Quick start:**\n+ ```bash\n+ cd tools/lightrag && uv sync && cp .env.example .env\n+ # Add OPENAI_API_KEY to .env, then:\n+ uv run python -m lightrag.api.lightrag_server --port 9621\n+ # Or: Press F5 â†’ \"LightRAG Server\" (VSCode)\n+ ```\n+ \n+ **Access:** http://localhost:9621 (Web UI + API docs)\n```\n\n**Impact:** Keeps CLAUDE.md concise, full details in tool README where they evolve independently.\n\n---\n\n### New Score: 98/100 (A+)\n\n| Criterion | Before | After | Change |\n|-----------|--------|-------|--------|\n| Commands/workflows | 20/20 | 20/20 | â€” |\n| Architecture clarity | 20/20 | 20/20 | â€” |\n| Non-obvious patterns | 14/15 | 15/15 | +1 (troubleshooting added) |\n| Conciseness | 12/15 | 14/15 | +2 (70 lines removed) |\n| Currency | 15/15 | 15/15 | â€” |\n| Actionability | 15/15 | 14/15 | âˆ’1 (less LightRAG detail) |\n| **Total** | **96** | **98** | **+2** |\n\nFile now 13% shorter, more actionable troubleshooting, same comprehensive coverage."}


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-07 — edit or delete below -->
- Starting assessment.\n\n## CLAUDE.md Quality Report\n\n### Summary\n- **Files found:** 1 (`./CLAUDE.md`)\n- **Lines:** 405\n- **Score:** 92/100 (Grade: **A**)\n- **Files needing update:** 1 (minor polish only)\n\n---\n\n### ./CLAUDE.md (Project Root)\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 19/20 | Exceptional â€” routing table, Key Commands, First-Time Setup all copy-paste ready |\n| Architecture clarity | 19/20 | Full dir tree, WAT philosophy, plugin/skills/MCP tables â€” outstanding |\n| Non-obvious patterns | 13/15 | MCP env-var gotcha, proxy fix, CLI-first pattern â€” all documented |\n| Conciseness | 11/15 | 405 lines; justified by scope, but 3 verbose sections can be trimmed ~30 lines |\n| Currency | 15/15 | Updated today, reflects current state |\n| Actionability | 15/15 | Every command is executable, no vague instructions |\n\n---\n\n### Issues Found\n\n**1.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-07 — edit or delete below -->
- {"session_id":"b70f41a2-c94c-4722-bd40-2f659494db1b","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--Users-MorarMonil-OneDrive---TK-Elevator-Documents-GIT-Claude-Code-Boilerplate-Framework\\b70f41a2-c94c-4722-bd40-2f659494db1b.jsonl","cwd":"C:\\Users\\MorarMonil\\OneDrive - TK Elevator\\Documents\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"bypassPermissions","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"## CLAUDE.md Quality Report (Re-assessment)\n\n### Summary\n- **Files found:** 1 (`./CLAUDE.md`) + 0 global (`~/.claude/CLAUDE.md` â€” not found)\n- **Lines:** 390 (down from 405 at session start)\n- **Score:** 95/100 (Grade: **A**)\n- **Remaining issues:** 2 minor\n\n---\n\n### ./CLAUDE.md (Project Root)\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 19/20 | Excellent â€” all 4 edits applied correctly |\n| Architecture clarity | 19/20 | Unchanged â€” still outstanding |\n| Non-obvious patterns | 14/15 | Corporate proxy row now present |\n| Conciseness | 12/15 | One verbose block remains (see below) |\n| Currency | 15/15 | Current |\n| Actionability | 15/15 | All commands executable |\n\n---\n\n### Remaining Issues\n\n**1.
- Good place for personal cross-project preferences (caveman mode default, response style, etc.) â€” not a project-level fix, just a tip.\n\n---\n\n### Proposed Update\n\n**Update 1 â€” Trim LightRAG Key Commands (saves ~7 lines)**\n\n```diff\n-# LightRAG â€” graph-based RAG\n-cd tools/lightrag\n-uv sync                                    # Install dependencies\n-cp .env.example .env                       # Copy environment template\n-# Edit .env and add your OPENAI_API_KEY\n-\n-# Option 1: Start via VSCode (recommended)\n-# Press F5 â†’ Select \"LightRAG Server\" â†’ Browser opens automatically at http://localhost:9621\n-\n-# Option 2: Start via command line\n-uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage\n-\n-# Option 3: Quick start script (Windows)\n-./start_server.bat\n+# LightRAG â€” graph-based RAG (see LightRAG Server Setup section below for full start options)\n+cd tools/lightrag && uv sync && cp .env.example .env  # First-time setup\n```\n\n**Why:** LightRAG Server Setup section already has the quick-start block.
- default caveman mode, response style).


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-07 — edit or delete below -->
- Subdirectory `CLAUDE.md` files â€” scoped context\n\n**What to put there (things true across ALL your projects):**\n\n```markdown\n# Global Defaults\n\n## Communication\n- Caveman mode full by default â€” drop articles, fragments OK\n- No trailing summaries â€” I can read the diff\n\n## Git\n- Always conventional commits (feat/fix/chore)\n- Never --no-verify\n\n## Code style\n- No comments unless WHY is non-obvious\n- No docstrings on obvious functions\n- TypeScript: strict mode assumed\n\n## Tools\n- PowerShell on Windows, not Git Bash\n- Prefer uv over pip for Python\n```\n\n**What NOT to put there:** Project-specific routing, tool configs, MCP servers, memory rules â€” those belong in project CLAUDE.md.\n\n**Create it:**\n```bash\nnotepad $env:USERPROFILE\\.claude\\CLAUDE.md\n```\n\nAnything you find yourself correcting Claude on repeatedly across different projects â†’ belongs in global CLAUDE.md so you never repeat it."}


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-08 — edit or delete below -->
- Good to go.\n\n**Launch:** F5 â†’ select **\"LightRAG Server\"** â†’ browser auto-opens at `http://localhost:9621`\n\nWeb UI lets you:\n- Insert documents (text/files)\n- Query with 5 modes (naive, local, global, hybrid, mix)\n- Visualize the knowledge graph\n\nAlso available: `tools/lightrag/start_server.bat` if you prefer terminal over F5."}


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-11 — edit or delete below -->
- **Extend existing** `find-skills` to include installed-skills section before marketplace search\n\nWhich do you prefer?
