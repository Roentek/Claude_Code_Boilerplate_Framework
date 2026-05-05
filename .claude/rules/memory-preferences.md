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
