# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-13 — LightRAG Plus integration tests: 0/35 → 35/35
- **Root causes fixed:**
  - `_embed_and_mirror` returned `list[list[float]]` → LightRAG `EmbeddingFunc.__call__` calls `.size` (numpy attr) → `AttributeError`; fix: `return np.array(embeddings)`
  - Pinecone v9: `ssl_verify=False` silently ignored when custom `_RetryTransport` wraps `httpx.HTTPTransport`; fix: monkey-patch `httpx.HTTPTransport.__init__` to `kwargs.setdefault("verify", False)` before import
  - Supabase adapter: `SyncClientOptions(httpx_client=httpx.Client(verify=False))` — `ClientOptions(verify=False)` doesn't exist in supabase-py v2.30.0
  - `provision.py` treating HTTP 201 as failure (Supabase Management API returns 201 Created); fix: `if resp.status_code in (200, 201)`
  - `conftest.py` only patched sync transport; OpenAI/Gemini async SDK hit SSL errors; fix: patch `httpx.AsyncHTTPTransport.__init__` too
  - Ollama LLM wrapper passed `model` via `kwargs.setdefault` but `ollama_model_complete` already injects model from `hashing_kv` → "multiple values for argument 'model'"; fix: removed redundant kwargs
  - Tests loaded `.env` with `LLM_BINDING=ollama` → entity extraction failed (Ollama can't run gpt-4o-mini); fix: `_apply_env` forces `LIGHTRAG_LLM_PROVIDER=openai` + `LIGHTRAG_LLM_MODEL=gpt-4o-mini`
- **Files modified:** `tests/conftest.py`, `tests/test_integration.py`, `provision.py`, `src/adapters/pinecone_adapter.py`, `src/adapters/supabase_adapter.py`, `src/lightrag_plus.py`
- **Commit:** `e272f55`

## 2026-05-12 — LightRAG Plus Phase 2: provision, check_update, README, hooks fixes
- **Built:** `provision.py` — auto-creates Supabase schema + Pinecone index from `.env` credentials; idempotent; `SUPABASE_MANAGEMENT_TOKEN` required; called by `start_server.bat` before server start
- **Built:** `check_update.py` — checks PyPI for lightrag-hku updates; `--upgrade` bumps pin, runs `uv sync`, smoke-tests imports; called by `start_server.bat` before provision
- **Fixed:** `start_server.bat` — added `.env` loading via batch loop (LightRAG reads OS env vars, not `.env` natively)
- **Fixed:** `openspace-sync.sh` — added `cd "$PROJECT_ROOT"` via `dirname "$0"` to fix fragile `cd -`; `stop.sh` removed `2>/dev/null` to make errors visible; `settings.json` added `openspace-sync.sh` to SessionStart hook
- **Fixed:** `setup.sh` — pure-bash `_timeout()` (no GNU timeout dep); all plugin installs wrapped; redirect order fixed `2>&1 >/dev/null` → `>/dev/null 2>&1`; fixed `claude plugins install` → `claude plugin install`
- **Fixed:** `interactive-scene.tsx` — memory leak (event listeners in handleLoad), cursor reset via `canvas.addEventListener('mouseleave')`, TS type errors
- **Rewrote:** `tools/lightrag/README.md` — full "LightRAG Plus" rewrite; removed fake ENABLE_FILE_WATCHER method; corrected async API examples; updated file structure
- **Added:** `tests/conftest.py` + `tests/test_integration.py` — 35 parametrized tests across 7 backend scenarios

## 2026-05-07 — Environment fixes, context-mode integration, OpenSpace MCP repair
- **Fixed:** MCP env audit — added `ANTHROPIC_API_KEY` to `settings.local.json`; updated `SUPABASE_KEY` in `tools/lightrag/.env` (was PAT token, needed service role JWT)
- **Fixed:** supabase-mcp — added `SUPABASE_URL` to `.mcp.json` env block
- **Fixed:** OpenSpace MCP — `pip install -e .` in `tools/openspace/` (package wasn't installed; MCP server couldn't start)
- **Integrated:** context-mode plugin (`context-mode@context-mode`) — 98% input compression via sandboxing (315 KB → 5.4 KB); SQLite FTS5 session continuity; added to `settings.json` enabledPlugins + extraKnownMarketplaces (mksglu/context-mode)
- **Created:** `.claude/scripts/advanced-statusline.py` — merges context-monitor.py + context-mode statusline; graceful fallbacks
- **Completed:** `settings.local.json.example` — CAVEMAN_SHRINK_* env vars; permissions for supabase-mcp (8 tools), context7 (2 tools), notebooklm-mcp (45 tools), 8 skills, 3 WebFetch domains

## 2026-05-05 (session 15) — Caveman token compression layer integration
- **Integrated:** `caveman@caveman` plugin + `caveman-shrink` MCP proxy as Tier 3 compression across existing memory system
- **MCP change:** `memory` → `memory-shrunk` in `.mcp.json` (caveman-shrink stdio proxy, ~50% metadata reduction)
- **New commands:** `/caveman` (75% response compression), `/caveman-stats`, `/caveman-compress` (46% file reduction), `/caveman-commit`, `/caveman-review`, `/cavecrew`
- **Token savings:** 75% outputs, ~46% memory files, ~50% MCP metadata, 65% avg overall
- **Files modified:** `.claude/settings.json`, `.mcp.json`, `settings.local.json.example`, `setup.sh` (step 7b), `memory-guidelines.md`, `CLAUDE.md`, `README.md`

---

## Archive

**May 2026:**
- **May 14 (s1):** update-all skill + hook built; setup.sh hardened with self-healing venv logic for OneDrive corruption
- **May 12 (s1):** setup.sh step 14a — Ollama Windows auto-install via winget + `%LOCALAPPDATA%/Programs/Ollama/ollama.exe` path fallback (PATH not updated in-session after winget)
- **May 11 (s3):** spline-3d prereqs fixed — `react`, `react-dom`, `@types/react` added to `package.json`; React default import added to `react-spline-wrapper.tsx`; `setup.sh` step 9 simplified
- **May 11 (s3):** Bun winget broken — winget installs empty dir; `setup.sh` updated to use official PS script (`irm bun.sh/install.ps1 | iex`); CLAUDE.md step 7d-pre updated
- **May 11 (s2):** VSCode launch configs added for claude-mem web viewer (Edge + Chrome variants)
- **May 11 (s1):** find-skills skill created + installed globally; three-brain synced to `~/.claude/skills/`; claude-mem requires Bun to start worker
- **May 9 (s2):** setup.sh step 14a added — Ollama install (Windows: winget instructions, Unix: auto-install); `tools/lightrag/.env` reset to `ollama`/`llama3.2`
- **May 9 (s1):** LightRAG enhanced branch (Gemini multimodal, Supabase/Pinecone mirrors) not merged to `main`; vanilla LightRAG + Ollama is active setup
- **May 7 (s4):** caveman-shrink: added `-y` flag; removed duplicate `memory` from `.mcp.json`; `cmd /c npx` required on Windows
- **May 7 (s3):** auto-stage-commit skill created + installed globally
- **May 7 (s2):** FTS5/better-sqlite3 fixed via `NODE_TLS_REJECT_UNAUTHORIZED=0` (corporate proxy TLS interception)
- **May 7 (s1):** CLAUDE.md audited to 97/100; global `~/.claude/CLAUDE.md` created; `settings.local.json.example` completed
- **May 5 (s14):** OpenSpace launch config verification + setup.sh port fix (3888 → 3789 via sed)
- **May 5 (s13):** OpenSpace git submodule + auto-sync via `openspace-sync.sh` every session
- **May 4 (s12):** OpenSpace CLI-first pattern — saves ~200-500 tokens/call vs MCP
- **May 3 (s11):** LightRAG — HKUDS/LightRAG in `tools/lightrag/`; 5 query modes; Web UI + REST API port 9621; `/lightrag` skill
- **May 3 (s10):** AutoResearch autosync — `autoresearch-sync.sh` syncs upstream karpathy/autoresearch every session
- **May 3 (s9):** AutoResearch — karpathy/autoresearch in `tools/autoresearch/`; ~12 exp/hour; `/autoresearch` skill
- **May 3 (s8):** CLI-Anything repaired — marketplace cloned, plugin installed
- **May 2 (s7):** CLI-Anything plugin — 50+ apps, 2,280+ tests
- **May 1 (s6):** CLI permissions audit — consolidated in `settings.json`
- **May 1 (s5):** NotebookLM — `nlm` CLI + `notebooklm-mcp` MCP; CLI-first pattern

**April 2026:**
- **Apr 30 (s4):** three-brain — codex-cli + gemini-cli; auto-routes Codex/Gemini
- **Apr 30 (s3):** CLAUDE.md audit 97/100; First-Time Setup section added
- **Apr 30 (s2):** ui-ux-pro-max-instructions.md → `.claude/docs/` (saves ~1500 tokens/session)
- **Apr 30:** Context optimization — CLAUDE.md 283→155 lines; context7 MCP; compact-memory skill; read-guard.py hook
- **Apr 29 (s2):** Playwright CLI — `tools/playwright.js` + skill + workflow; playwright-mcp as backup
- **Apr 29:** Alpaca 401 — `${VAR}` in .mcp.json reads OS env, not .env; PostToolUse autosync hook
- **Apr 28:** webgpu-threejs-tsl skill (16 files); /design-md skill (73 brands); GitHub plugin env var corrected
- **Apr 27:** Skill subdirectory fix — `~/.claude/skills/<name>/SKILL.md` required; Impeccable + skillui added
- **Apr 22:** PDFs → .md in `.claude/docs/`; pre-commit.sh hook
- **Apr 20:** Boilerplate sync scope locked — SYNC_PATHS excludes README.md, LICENSE, .env.example, etc.

## 2026-05-14 — LightRAG test runner fix + test idempotency
- **Root cause:** `uv run --extra dev pytest` re-syncs the venv on every invocation. On second run, Windows holds file locks on venv files left by the previous pytest process (Windows Defender or delayed file release). `uv sync` hits `Access is denied (os error 5)` on `regex-*.dist-info\licenses`, exits code 2 before pytest starts.
- **Immediate fix:** Delete corrupted/locked dist-info dirs (`regex`, `proto_plus`, `pytz`), then `uv sync --extra dev`.
- **Structural fix:** Run tests via `.venv\Scripts\python.exe -m pytest` (not `uv run pytest`). Skips venv sync entirely. Do `uv sync --extra dev` once, then pytest directly — repeatable N times.
- **Config fix:** Added `asyncio_mode = "auto"` to `[tool.pytest.ini_options]` in `pyproject.toml`.
- **CLAUDE.md updated:** LightRAG Server Setup section now documents two-step test command + self-heal recipe.
- **Pattern (Windows):** Always separate `uv sync` (once) from test execution (direct python). Never `uv run pytest` in a loop.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-14 (auto-drafted — review before next session)
- Summary of what was found and fixed:\n\n**Root cause:** `uv run --extra dev pytest` triggers a venv sync on every invocation.
- `uv` fails with `Access is denied (os error 5)` on `regex-*.dist-info\\licenses` and exits before pytest starts.\n\n**Fixes applied:**\n\n| What | Change |\n|------|--------|\n| Immediate | Deleted `regex`, `proto_plus`, `pytz` dist-info dirs, re-ran `uv sync` |\n| Structural | Use `.venv\\Scripts\\python.exe -m pytest` â€” no sync on each call |\n| Config | Added `asyncio_mode = \"auto\"` to `pyproject.toml` |\n| Docs | CLAUDE.md LightRAG section updated with correct 2-step test command + self-heal recipe |\n\n**Correct test command going forward:**\n```powershell\n# Once (or after any uv.lock change):\ncd tools/lightrag && uv sync --extra dev\n\n# Every test run (repeatable, no re-sync):\n.venv\\Scripts\\python.exe -m pytest tests/test_integration.py -v\n```"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-14 (auto-drafted — review before next session)
- Changes:\n\n- **setup.sh** â€” OpenSpace now installs via `uv pip install -e \".[windows]\"` (platform-aware, correct extras from first boot); uv-not-found falls back to system pip with warning\n- **update-all.sh** â€” already fixed (uses `uv pip install -e .` skipping `uv sync`)\n- **CLAUDE.md** â€” step 13 comment updated\n\nBoth paths now consistent: `uv pip install` instead of `uv sync`, platform extras on first install."}
