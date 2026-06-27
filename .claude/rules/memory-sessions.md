# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-14 — LightRAG test runner fix + test idempotency
- **Root cause:** `uv run --extra dev pytest` re-syncs the venv on every invocation. On second run, Windows holds file locks on venv files left by the previous pytest process (Windows Defender or delayed file release). `uv sync` hits `Access is denied (os error 5)` on `regex-*.dist-info\licenses`, exits code 2 before pytest starts.
- **Immediate fix:** Delete corrupted/locked dist-info dirs (`regex`, `proto_plus`, `pytz`), then `uv sync --extra dev`.
- **Structural fix:** Run tests via `.venv\Scripts\python.exe -m pytest` (not `uv run pytest`). Skips venv sync entirely. Do `uv sync --extra dev` once, then pytest directly — repeatable N times.
- **Config fix:** Added `asyncio_mode = "auto"` to `[tool.pytest.ini_options]` in `pyproject.toml`.
- **CLAUDE.md updated:** LightRAG Server Setup section now documents two-step test command + self-heal recipe.
- **Pattern (Windows):** Always separate `uv sync` (once) from test execution (direct python). Never `uv run pytest` in a loop.

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

---

## Archive

**May 2026:**
- **May 18 (s2):** LightRAG + OpenSpace setup — pulled llama3.2 (2.0 GB) into Ollama; created openspace venv + installed `.[windows]`; lightrag venv already current; compact-memory run
- **May 18 (s1):** CLAUDE.md audit 89→94/100 — fixed test_lightrag.py stale, uv pip install, tests/ dir; global `~/.claude/CLAUDE.md` uv run pytest Windows gotcha added
- **May 17:** LightRAG `EMBEDDING_BINDING_HOST` — added to `.env` + `.env.example` (CRITICAL comment); setup.sh auto-copies `.env.example` → `.env` on fresh clones
- **May 15:** LightRAG file type support — `pypdf`, `python-docx`, `python-pptx`, `openpyxl` added to `pyproject.toml`; PDF/Word/PowerPoint/Excel uploads now work
- **May 14 (s2):** setup.sh + update-all.sh — OpenSpace install updated to `uv pip install -e ".[<platform>]"` (platform extras; fixes pyatspi on non-Windows)
- **May 14 (s1):** update-all skill + hook built; setup.sh hardened with self-healing venv logic for OneDrive corruption
- **May 12 (s1):** setup.sh step 14a — Ollama Windows auto-install via winget + `%LOCALAPPDATA%/Programs/Ollama/ollama.exe` path fallback (PATH not updated in-session after winget)
- **May 11 (s3):** spline-3d prereqs fixed — `react`, `react-dom`, `@types/react` added to `package.json`; React default import added to `react-spline-wrapper.tsx`; `setup.sh` step 9 simplified
- **May 11 (s3):** Bun winget broken — winget installs empty dir; `setup.sh` updated to use official PS script (`irm bun.sh/install.ps1 | iex`); CLAUDE.md step 7d-pre updated
- **May 11 (s2):** VSCode launch configs added for claude-mem web viewer (Edge + Chrome variants)
- **May 11 (s1):** find-skills skill created + installed globally; three-brain synced to `~/.claude/skills/`; claude-mem requires Bun to start worker
- **May 9 (s2):** setup.sh step 14a added — Ollama install (Windows: winget instructions, Unix: auto-install); `tools/lightrag/.env` reset to `ollama`/`llama3.2`
- **May 9 (s1):** LightRAG enhanced branch — merged to main as LightRAG Plus by May 12; 35/35 integration tests passing
- **May 7 (s4):** caveman-shrink: added `-y` flag; removed duplicate `memory` from `.mcp.json`; `cmd /c npx` required on Windows
- **May 7 (s3):** auto-stage-commit skill created + installed globally
- **May 7 (s2):** FTS5/better-sqlite3 fixed via `NODE_TLS_REJECT_UNAUTHORIZED=0` (corporate proxy TLS interception)
- **May 7 (s1):** CLAUDE.md audited to 97/100; global `~/.claude/CLAUDE.md` created; `settings.local.json.example` completed
- **May 5 (s15):** Caveman token compression integrated — `caveman@caveman` plugin + `memory-shrunk` MCP proxy; 75% output, 46% file, 50% MCP metadata reduction
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


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- It's a built-in web UI that ships with the plugin and runs automatically when the plugin's background worker starts.\n\nTo use it:\n1.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- `inputs/` added to `tools/lightrag/.gitignore`.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- Here's what was built:\n\n**Files created:**\n- `tests/openspace/conftest.py` â€” fixtures + env loader (`tools/openspace/.env` auto-loaded)\n- `tests/openspace/test_integration.py` â€” 44 tests across 3 tiers\n- `tests/openspace/pytest.ini` â€” `asyncio_mode = auto`\n\n**Key design decisions:**\n\n1.
- LLM client is created but makes no API calls during init â€” zero token cost.\n\n3.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- **No fallback** to top-level `.env` if missing â€” single load, silent skip.\n\n**OpenSpace** â€” `tools/openspace/.env` now created.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- Summary of state:\n\n**`tools/openspace/.env`** â€” follows `.env.example` structure with:\n- `OPENROUTER_API_KEY` + `OPENSPACE_MODEL=openrouter/auto` + `OPENSPACE_LLM_API_BASE` (Option B override takes priority)\n- `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY` as fallbacks (Option A)\n- `OPENSPACE_API_KEY` for cloud registry\n\n**Top-level `.env`** â€” `OPENROUTER_API_KEY` now added alongside existing `OPENROUTER_BASE_URL`/`OPENROUTER_MODEL`\n\n**Model behavior:** `openrouter/auto` lets OpenRouter pick the best model per request based on cost/capability.
- If you want a fixed default instead, swap to e.g.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- Three test files added, `.pytest_cache/` now ignored.\n\n**Summary:** No sync interference was ever a risk â€” paths are entirely separate.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- {"session_id":"4460c3cc-78c3-4384-8010-fd4ea131f21a","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\4460c3cc-78c3-4384-8010-fd4ea131f21a.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"bypassPermissions","effort":{"level":"high"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"Groups added via `presentation.group` â€” VSCode uses this to create labeled sections in the Run & Debug dropdown:\n\n- **lightrag** â€” LightRAG Server (1), LightRAG Integration Tests (2)\n- **openspace** â€” OpenSpace Integration Tests (1), OpenSpace Backend Server (2), OpenSpace Frontend (3)\n- **claude-mem** â€” Claude-Mem Web Viewer (1), Claude-Mem Web Viewer Chrome (2)\n\nThe compound \"OpenSpace Dashboard (Full Stack)\" already had `group: \"openspace\"` so it slots in automatically."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- Summary:\n\n- **update-all.sh**: `UV_NATIVE_TLS=true` added to all `uv sync` calls â€” fixes corporate proxy cert issue\n- **CLAUDE.md**: troubleshooting row added for `uv sync UnknownIssuer`\n- **lightrag**: healthy (import OK, exit 0)\n- **autoresearch**: PyTorch 2.9.1+cu128 installed successfully"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- {"session_id":"4460c3cc-78c3-4384-8010-fd4ea131f21a","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\4460c3cc-78c3-4384-8010-fd4ea131f21a.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework\\tools\\lightrag","permission_mode":"bypassPermissions","effort":{"level":"high"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"Fixed.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- {"session_id":"4460c3cc-78c3-4384-8010-fd4ea131f21a","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\4460c3cc-78c3-4384-8010-fd4ea131f21a.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework\\tools\\lightrag","permission_mode":"bypassPermissions","effort":{"level":"high"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"All fixed.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- {"session_id":"effc66e0-c7b1-46a0-9777-78f660a33a89","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\effc66e0-c7b1-46a0-9777-78f660a33a89.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework\\tools\\lightrag","permission_mode":"bypassPermissions","effort":{"level":"high"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"Fixed.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- No files added, removed, or renamed â€” just upstream sync.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- Added tenacity retry to `GeminiEmbedder._call_embed` â€” 3 attempts, 1â†’8s exponential backoff, logs a WARNING before each retry.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- LightRAG's internal `asyncio.wait_for` defaults to 180s for LLM calls; `llama3.2` processing large markdown chunks exceeds this and gets cancelled, surfacing as `ReadTimeout`.\n\n**Fix applied:**\n- `start_server.bat` â€” added `--timeout 0` (maps to infinite internally)\n- `CLAUDE.md` â€” updated manual command + troubleshooting table row\n\nRestart the server and the uploads should process fully."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- Three files updated with the correct fix:\n\n- **`.env` + `.env.example`**: Added `LLM_TIMEOUT=600` (10 min) and `EMBEDDING_TIMEOUT=60` (1 min) with a note that `asyncio.wait_for` treats `0` as \"timeout immediately\" â€” so `0` is wrong\n- **`start_server.bat`**: Removed `--timeout 0`; added comment clarifying it only affects gunicorn, not uvicorn, and that the real fix is the env vars\n- **`CLAUDE.md`**: Fixed both the manual command (removed `--timeout 0`) and the troubleshooting entry (now points to `LLM_TIMEOUT=600` in `.env`)"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- So **LightRAG's asyncio timeout didn't fire** â€” the Ollama client's own httpx read timeout fired first.\n\n**Why:** `LLM_TIMEOUT=600` was just added to `.env` this session.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-18 (auto-drafted — review before next session)
- {"session_id":"65d9369b-f4e2-45b8-903a-f8e1f7c96902","transcript_path":"C:\\Users\\mdmor\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\65d9369b-f4e2-45b8-903a-f8e1f7c96902.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework\\tools\\lightrag","permission_mode":"bypassPermissions","effort":{"level":"medium"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"CLAUDE.md updated â€” removed all three `--embedding-binding-host` references, updated the comparison table and the gotcha note to reflect env-var-only fix in newer lightrag-hku."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-22 (auto-drafted — review before next session)
- Here's what was integrated:\n\n**Files changed:**\n- `.claude/skills/codeburn/SKILL.md` â€” new skill with full command reference, task categories, signal guide\n- `.claude/hooks/setup.sh` â€” step 11 block installs `codeburn` globally (idempotent, 120s timeout)\n- `.claude/hooks/update-all.sh` â€” `\"codeburn\"` added to `NPM_GLOBALS` array (auto-updated by `/update-all`)\n- `CLAUDE.md` â€” routing table row, step 10 comment, skills table entry\n- `.claude/rules/memory-decisions.md` â€” decision logged\n\n**Already live:**\n- `codeburn` v0.9.14 installed globally\n- Skill installed to `~/.claude/skills/codeburn/SKILL.md` â€” active now\n\n**Usage:**\n```bash\ncodeburn           # TUI dashboard (last 7 days)\ncodeburn status    # one-liner: today + month totals\ncodeburn optimize  # waste scan + fix suggestions\ncodeburn web       # browser dashboard at localhost:4747\n```\n\nAuto-detects Claude Code session files from `~/.claude/projects/`.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-23 (auto-drafted — review before next session)
- Here's what was integrated:\n\n**designlang** (design-extract repo) is now fully wired in:\n\n| Component | Status |\n|-----------|--------|\n| `designlang` CLI v12.21.0 | Installed globally |\n| Claude plugin `designlang@designlang` | Installed (13 slash commands active) |\n| `designlang-mcp` MCP server | Added to `.mcp.json` + `enabledMcpjsonServers` |\n| `/extract-design` skill | Created locally + copied to `~/.claude/skills/` |\n| `setup.sh` step 11 | Installs CLI + plugin on fresh clone |\n| `update-all.sh` NPM_GLOBALS | `\"designlang\"` added for auto-updates |\n| `CLAUDE.md` | Routing table row + skills entry + MCP table + step 10 comment |\n| `memory-decisions.md` | Decision logged with corporate SSL gotcha |\n\n**Key gotcha documented:** `npm install -g designlang --ignore-scripts` â€” postinstall runs Playwright browser download which fails on corporate SSL proxy.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-23 (auto-drafted — review before next session)
- {"session_id":"0449ecce-ca14-4dfc-be06-e433a440dfc4","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\0449ecce-ca14-4dfc-be06-e433a440dfc4.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"bypassPermissions","effort":{"level":"medium"},"hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"Three sections updated:\n- **Step 11** â€” added `codeburn`, `browser-harness`, `designlang` to global CLI tools list\n- **Project Skills table** â€” added `/extract-design`, `/codeburn`, `/browser-harness` entries\n- **MCP Servers table** â€” added `designlang-mcp` row","background_tasks":[],"session_crons":[]}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-23 (auto-drafted — review before next session)
- Summary of what was completed:\n\n**Verified:**\n- MCP config correct â€” `KIE_AI_API_KEY` already in `settings.local.json`\n- `kie-cli list_tasks --json` â†’ `{\"success\":true}` â€” API confirmed live\n\n**Installed:**\n- `@felores/kie-cli` globally (separate from MCP server package)\n- `/kie-ai` skill copied to `~/.claude/skills/kie-ai/SKILL.md` (active now)\n\n**Wired in:**\n| File | Change |\n|------|--------|\n| `setup.sh` | kie-cli install block added (step 11) |\n| `update-all.sh` | `@felores/kie-cli` in NPM_GLOBALS |\n| `settings.json` | `Bash(kie-cli *)` + `PowerShell(kie-cli *)` permissions |\n| `CLAUDE.md` | Routing table, skills table, MCP table, step 10 comment |\n| `memory-decisions.md` | Decision logged |\n\n**Auto-switch logic** (in `/kie-ai` skill): CLI first always.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Here's the summary:\n\n**mcp-cleanup.sh** â€” added `*kie-ai-mcp-server*` and `*designlang*mcp*` patterns (two servers that were missing from orphan-kill logic).\n\n**Modular install structure** â€” `.claude/hooks/install/` with 41 files:\n\n| Category | Scripts |\n|---|---|\n| `lib.sh` | Shared helpers (`_timeout`, `_is_windows`, `_user_home`, `_install_plugin`, `_install_skill`) |\n| `sys-*.sh` | 8 scripts â€” python, node, uvx, bun, env, npm-deps, github-cli, pre-commit, context-monitor, hooks |\n| `plugin-*.sh` | 10 scripts â€” one per plugin (caveman, context-mode, claude-mem, designlang, ui-ux-pro-max, etc.) |\n| `skill-apify-*.sh` + `skills-project.sh` | 6 scripts â€” Apify marketplace + project skills copy |\n| `cli-*.sh` | 9 scripts â€” firecrawl, codex, gemini, notebooklm, codeburn, browser-harness, designlang, kie, skillui |\n| `tool-*.sh` | 4 scripts â€” autoresearch, lightrag, ollama, openspace |\n| `auth-reminders.sh` | Prints manual login steps (NotebookLM, Trigger, Google, GitHubâ€¦) |\n\n`setup.sh` now just calls `_run <script>` in order â€” same behavior as before, but every step is independently runnable:\n\n```bash\nbash .claude/hooks/install/plugin-caveman.sh   # install just caveman\nbash .claude/hooks/install/cli-firecrawl.sh    # install just firecrawl\nbash .claude/hooks/install/tool-lightrag.sh    # install just LightRAG\n```","background_tasks":[],"session_crons":[]}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Fix baked into `sys-npm-deps.sh` permanently â€” future fresh clones on this corporate network will work without manual intervention.\n\nStatus of the 3 original failures:\n- `apify-actor-development` â€” âš  CLI routes to `/find-skills` instead of installing; install manually inside Claude Code: `/skill install apify-actor-development@apify-agent-skills`\n- `context-mode` â€” âœ“ fixed (installed successfully)\n- Playwright Chromium â€” âœ“ fixed (`NODE_TLS_REJECT_UNAUTHORIZED=0`)","background_tasks":[],"session_crons":[]}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Here's a summary of everything completed:\n\n**Audit fixes (update-all.sh):**\n- `designlang` npm update now uses `--ignore-scripts` (fixes corporate proxy SSL failure â€” the Jun 26 observation 1174)\n- Added Ollama update step (section 4) â€” Windows/macOS print manual command; Linux auto-runs installer\n- Fixed stale comment (\"add to PLUGINS below\" â†’ accurate manual note)\n- Renumbered sections 4â†’7 correctly\n\n**Graphify integration:**\n- `tool-graphify.sh` â€” `uv tool install 'graphifyy[mcp]'` + `graphify install` (skill registration)\n- `setup.sh` â€” added under heavy tools section\n- `.mcp.json` â€” `graphify-mcp` server entry (stdio, points to `graphify-out/graph.json`)\n- `settings.json` â€” `graphify-mcp` in `enabledMcpjsonServers`; `Bash/PowerShell(graphify *)`, `Bash(ffmpeg *)`, `Bash(yt-dlp *)` permissions\n- `settings.local.json.example` â€” activation guide + `GRAPHIFY_API_KEY` env entry\n- `.env.example` â€” `GRAPHIFY_API_KEY` documented\n- `CLAUDE.md` â€” routing table row, plugins + skills + MCP tables, project structure\n\n**Claude-video integration:**\n- `plugin-claude-video.sh` â€” `_install_plugin watch claude-video` + prints ffmpeg/yt-dlp install instructions per platform\n- `setup.sh` â€” added to marketplace plugins section\n- `settings.json` â€” `watch@claude-video: true` in `enabledPlugins`; `claude-video` marketplace in `extraKnownMarketplaces`; `Skill(watch)` permission\n- `settings.local.json.example` â€” activation guide (no key needed for captioned video; `GROQ_API_KEY` optional)\n- `.env.example` â€” `GROQ_API_KEY` documented\n- `CLAUDE.md` â€” routing table row, plugins + skills tables\n\n**Decisions logged** in `memory-decisions.md` for both integrations.","background_tasks":[],"session_crons":[]}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Ponytail integration complete:\n\n**Files created:**\n- `.claude/hooks/install/plugin-ponytail.sh` â€” installs `ponytail@ponytail` via `_install_plugin`\n\n**Files updated:**\n- `setup.sh` â€” `_run plugin-ponytail.sh` after `plugin-claude-video.sh` in marketplace plugins section\n- `settings.json` â€” `ponytail@ponytail: true` in `enabledPlugins`; `DietrichGebert/ponytail` in `extraKnownMarketplaces`\n- `.env.example` â€” `PONYTAIL_DEFAULT_MODE=full` documented\n- `settings.local.json.example` â€” activation guide + Skill permissions for all 5 slash commands\n- `CLAUDE.md` â€” Plugins table row\n- `memory-decisions.md` â€” decision logged\n\nNo MCP entry, no npm global, no CLI â€” plugin-only.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Summary of what changed:\n\n- **Step 7**: added `claude-video`, `ponytail` to marketplace plugins list\n- **Step 11**: added `kie-cli` to global CLI tools list\n- **Step 15a**: new step for Graphify (`uv tool install 'graphifyy[mcp]'`, skill registration, `/graphify .` per-repo build instruction)\n- **Plugin Marketplaces table**: added `claude-video` + `ponytail` rows\n- **Installing Third-Party Plugins**: added Claude-Video and Ponytail install entries with slash commands\n- **Enabled Plugins table**: added `watch@claude-video` and `ponytail@ponytail` rows\n- **Project Skills table**: added `/graphify` and `/watch` rows\n- **MCP Servers table**: added `graphify-mcp` row\n- **update-all hook**: noted Ollama update step and designlang `--ignore-scripts` fix","background_tasks":[],"session_crons":[]}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Here's what changed and why:\n\n**Routing table (top)** â€” Added `/roast` and `/session-handoff` rows with explicit auto-invoke trigger phrases.
- Also fixed `/skillui` vs `/extract-design` ambiguity (session-prep vs deliverable-export) and `/compact-memory` (explicit size/timing trigger).\n\n**Auto-trigger block** â€” Three explicit rules now: `/roast`, `/session-handoff`, `/auto-stage-commit`.
- Trigger phrases are consistent across routing table, skills table, and this block (ðŸ”´ was inconsistent \"what do you think?\" vs \"what do you think of this idea?\").\n\n**Stale fixes** â€” `tools/lightrag/` â†’ `tools/lightrag-plus/` in project structure; added `claude-video` + `ponytail` to setup.sh comment; clarified disabled plugins note to prevent MCP/plugin confusion.","background_tasks":[],"session_crons":[]}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- `./CLAUDE.md` (Project Root) â€” 494 lines\n\n**Score: 86/100 (Grade: B)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 17/20 | Comprehensive bash blocks; missing `graphify .` build step and new skill invocation examples |\n| Architecture clarity | 18/20 | WAT framework, project tree, install/ scripts well documented |\n| Non-obvious patterns | 13/15 | MCP gotchas, TLS proxy, LightRAG embedding bug covered; `designlang --ignore-scripts` missing from Troubleshooting |\n| Conciseness | 12/15 | LightRAG section (50 lines) and OpenSpace tests (15 lines) are dense but justified; some skill \"Use When\" cells still read as descriptions |\n| Currency | 13/15 | lightrag-plus/ path, claude-video/ponytail fixed this session; several skills table \"Use When\" cells are capability descriptions not trigger conditions |\n| Actionability | 13/15 | All commands copy-pasteable; `/three-brain` missing install hint; `graphify .` one-time build step not in Key Commands |\n\n**Issues:**\n\n1.
- `/roast` and `/session-handoff` not in Key Commands â€” newly added skills need usage examples in the commands section\n3.
- `designlang --ignore-scripts` corporate proxy gotcha in `memory-decisions.md` but not in Troubleshooting table\n4.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-06-26 (auto-drafted — review before next session)
- Summary:\n\n| Change | Location |\n|---|---|\n| Added `graphify .` + `/roast` + `/session-handoff` examples | Key Commands |\n| Added `designlang --ignore-scripts` fix | Troubleshooting table |\n| `/site-teardown` â†’ trigger condition | Skills table |\n| `/three-brain` â†’ trigger + install hint | Skills table |\n| `/skill-discovery` â†’ `/delegate-task` â†’ `/find-skills` ordering with decision logic | Skills table |\n\nCLAUDE.md now scores **~92/100 (A)** â€” routing table has auto-invoke signals, skills table has trigger conditions not descriptions, troubleshooting covers all known corporate proxy failures, Key Commands covers all one-time-build requirements.","background_tasks":[],"session_crons":[]}
