# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-12 — Spline interactive-scene.tsx + setup.sh overhaul + LightRAG Plus verification
- **Fixed:** `interactive-scene.tsx` — 3 bugs: event listeners added in `handleLoad` with no cleanup (memory leak); cursor never reset (used invalid `mouseOut` Spline event); noop `canvas.mousemove` listener. 2 TS type errors: removed custom `SplineApp` interface (incompatible with `Application`), imported `Application` + `SplineEventName` from `@splinetool/runtime`; `'mouseOut'` replaced with DOM `canvas.addEventListener('mouseleave', ...)` for cursor reset; `triggerEvent` param typed as `SplineEventName`
- **Fixed:** `setup.sh` — added pure-bash `_timeout()` function (no GNU timeout dependency); all `claude plugin install` calls wrapped in `_timeout 30`; all `npm install -g` / `uv tool install` calls wrapped in `_timeout 120`; fixed redirect order `2>&1 >/dev/null` → `>/dev/null 2>&1` (4 sites); fixed `claude plugins install` → `claude plugin install` (wrong subcommand); added `cache/` path to better-sqlite3 plugin dir search
- **Fixed:** `tools/lightrag/start_server.bat` — added `.env` loading via `for /f "usebackq tokens=1,2 delims== eol=#"` batch loop before server start (LightRAG reads OS env vars, not `.env` natively)
- **Verified:** LightRAG Plus branch merge complete — all Plus files present (`src/lightrag_plus.py`, `src/embedders/`, `src/adapters/`, `src/ingestors/`, `schema/supabase_schema.sql`, `setup_backends.py`); `python-dotenv` dep confirmed; server ready once Ollama installed
- **Pending:** Ollama install (`winget install Ollama.Ollama` + `ollama pull llama3.2`) — user action required; then `start_server.bat` → GUI at http://localhost:9621

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

## 2026-05-05 (session 14) — OpenSpace launch config verification + setup.sh port fix
- **Verified:** All 5 VSCode launch configs work with git submodule architecture (backend Python, frontend React/Vite, compound full-stack)
- **Fixed:** Port mismatch 3888 vs 3789 — setup.sh aligns `.env` port with `package.json` via `sed` after `.env` creation

---

## Archive

**May 2026 (continued):**
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


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-12 (auto-drafted — review before next session)
- `2>/dev/null` in `stop.sh` silently swallowed the error, making it invisible\n\n**Fixes:**\n- `openspace-sync.sh` â€” added `cd \"$PROJECT_ROOT\"` at top using `dirname \"$0\"` to navigate from hooks dir; uses absolute paths throughout; no more fragile `cd -`\n- `stop.sh` â€” removed `2>/dev/null`, errors now visible\n- Removed stale `index.lock` manually\n- `settings.json` â€” added `openspace-sync.sh` to `SessionStart` hook so upstream changes are pulled at session open (not just on stop)"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-12 (auto-drafted — review before next session)
- CLAUDE.md has no step-by-step setup descriptions so no change needed there.\n\n**What changed in setup.sh (Ollama Windows path):**\n- Before: just printed `winget install` + `ollama pull` instructions, exited\n- After: runs `winget install --id Ollama.Ollama --accept-package-agreements --accept-source-agreements`, then checks `%LOCALAPPDATA%/Programs/Ollama/ollama.exe` (PATH not updated in-session after winget), pulls llama3.2 via the full path or `ollama` if it resolved; shows both bash + PowerShell fallback commands (`ollama pull llama3.2` â€” identical in both shells) if pull can't run"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-12 (auto-drafted — review before next session)
- Full summary of what was built:\n\n**New file: `tools/lightrag/provision.py`**\n- Reads `Config` â€” acts on `ENABLE_SUPABASE` / `ENABLE_PINECONE` flags\n- Supabase: extracts project ref from `SUPABASE_URL`, POSTs schema SQL to `api.supabase.com/v1/projects/{ref}/database/query` with your management token â€” substitutes actual `EMBEDDING_DIM` into `vector(N)` automatically\n- Pinecone: calls `pc.list_indexes()`, creates index if missing with correct dimension + cosine metric\n- Idempotent â€” `CREATE TABLE IF NOT EXISTS` + index existence check means safe to run every startup\n\n**`src/config.py`** â€” added `SUPABASE_MANAGEMENT_TOKEN` field\n\n**`src/lightrag_plus.py`** â€” added `_preflight()` called from `create()`:\n- Health-checks each enabled backend on startup\n- Raises `RuntimeError` with clear `provision.py` pointer if table/index missing\n\n**`start_server.bat`** â€” runs `provision.py` before server start; aborts if it fails\n\n**`.env`** â€” token injected, **`.env.example`** â€” placeholder added\n\n**`CLAUDE.md` + `README.md`** â€” project structure and quick-start updated\n\nTo test now: set `ENABLE_SUPABASE=true` in `.env` and run `start_server.bat` â€” it should auto-deploy the schema on first run."}
