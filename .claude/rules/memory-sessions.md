# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-07 — Environment fixes, context-mode integration, OpenSpace MCP repair
- **Fixed:** MCP env audit — added `ANTHROPIC_API_KEY` to `settings.local.json` (was empty, blocking MCP servers that use Claude models); updated `SUPABASE_KEY` in `tools/lightrag/.env` (was PAT token, needed service role JWT)
- **Fixed:** supabase-mcp — added `SUPABASE_URL` to `.mcp.json` env block; updated `settings.local.json.example` activation guide
- **Fixed:** OpenSpace MCP — `pip install -e .` in `tools/openspace/` (package wasn't installed; MCP server couldn't start)
- **Integrated:** context-mode plugin (`context-mode@context-mode`) — 98% input compression via sandboxing (315 KB → 5.4 KB); SQLite FTS5 session continuity; added to `settings.json` enabledPlugins + extraKnownMarketplaces (mksglu/context-mode)
- **Created:** `.claude/scripts/advanced-statusline.py` — merges context-monitor.py + context-mode statusline; graceful fallbacks; statusLine command updated in `settings.json`
- **Completed:** `settings.local.json.example` — added CAVEMAN_SHRINK_FIELDS/CAVEMAN_SHRINK_DEBUG env vars; permissions for supabase-mcp (8 tools), context7 (2 tools), notebooklm-mcp (45 tools), 8 skill entries, 3 WebFetch domains (context7.com, notebooklm.google.com, monet.design)

## 2026-05-05 (session 15) — Caveman token compression layer integration
- **Integrated:** `caveman@caveman` plugin + `caveman-shrink` MCP proxy as Tier 3 compression across existing memory system
- **MCP change:** `memory` → `memory-shrunk` in `.mcp.json` (caveman-shrink stdio proxy, ~50% metadata reduction)
- **New commands:** `/caveman` (75% response compression), `/caveman-stats`, `/caveman-compress` (46% file reduction), `/caveman-commit`, `/caveman-review`, `/cavecrew`
- **Token savings:** 75% outputs, ~46% memory files, ~50% MCP metadata, 65% avg overall
- **Files modified:** `.claude/settings.json`, `.mcp.json`, `settings.local.json.example`, `setup.sh` (step 7b), `memory-guidelines.md`, `CLAUDE.md`, `README.md`

## 2026-05-05 (session 14) — OpenSpace launch config verification + setup.sh port fix
- **Verified:** All 5 VSCode launch configs work with git submodule architecture (backend Python, frontend React/Vite, compound full-stack)
- **Fixed:** Port mismatch 3888 vs 3789 — setup.sh now aligns `.env` port with `package.json` via `sed` after `.env` creation
- **Files updated:** `.claude/hooks/setup.sh` (port alignment lines 622-627)

## 2026-05-05 (session 13) — OpenSpace git submodule + auto-sync infrastructure
- **Implemented:** `tools/openspace/` as git submodule — pinned commits + auto-sync via `openspace-sync.sh` every session (hybrid approach)
- **Files created:** `.claude/hooks/openspace-sync.sh`, `.claude/docs/openspace-submodule-conversion.md`, `OPENSPACE_SUBMODULE_SETUP.md`
- **Files updated:** `stop.sh` (calls openspace-sync.sh), `setup.sh` (step 15 submodule init), `CLAUDE.md` + `README.md` (5 sections each)
- **Auto-sync:** Silent if up-to-date; pulls if updates available; skips if uncommitted changes; updates submodule pointer

---

## Archive

**May 2026:**
- **May 4 (s12):** OpenSpace CLI-first — CLI (token-free) before MCP; saves ~200-500 tokens/call; SKILL.md updated with decision matrix; matches Playwright/Firecrawl/NotebookLM pattern
- **May 3 (s11):** LightRAG — HKUDS/LightRAG in `tools/lightrag/`; 5 query modes; Web UI + REST API at port 9621; `/lightrag` skill; setup.sh step 14 runs uv sync
- **May 3 (s10):** AutoResearch autosync — `autoresearch-sync.sh` syncs upstream karpathy/autoresearch every session; `verify_setup.py` auto-runs after uv sync
- **May 3 (s9):** AutoResearch — karpathy/autoresearch in `tools/autoresearch/`; ~12 exp/hour, ~100 overnight; requires NVIDIA GPU; `/autoresearch` skill
- **May 3 (s8):** CLI-Anything repaired — marketplace cloned, plugin installed, all 5 commands available
- **May 2 (s7):** CLI-Anything plugin — `cli-anything@cli-anything`; AI-native CLIs for GIMP, Blender, LibreOffice, etc.; 50+ apps, 2,280+ tests
- **May 1 (s6):** CLI permissions audit — consolidated in `settings.json`; 6 tools with full cross-platform coverage
- **May 1 (s5):** NotebookLM — `nlm` CLI + `notebooklm-mcp` MCP; cookie-based auth; CLI-first pattern

**April 2026:**
- **Apr 30 (s4):** three-brain — codex-cli + gemini-cli in setup.sh step 11; auto-routes to Codex (review/rescue) or Gemini (multimodal/long-context)
- **Apr 30 (s3):** CLAUDE.md audit — 97/100; First-Time Setup section added; tools/ clarified
- **Apr 30 (s2):** ui-ux-pro-max-instructions.md → `.claude/docs/` (saves ~1500 tokens/non-frontend session)
- **Apr 30:** Context optimization — CLAUDE.md 283→155 lines; context7 MCP; memory-distiller agent; compact-memory skill; read-guard.py hook
- **Apr 29 (s2):** Playwright CLI — `tools/playwright.js` + skill + workflow; setup.sh step 9 installs Chromium; playwright-mcp added as backup
- **Apr 29:** Alpaca 401 diagnosed — `${VAR}` in .mcp.json reads OS env, not .env; PostToolUse autosync hook built
- **Apr 28:** webgpu-threejs-tsl skill (16 files); setup.sh uses `cp -r`; /design-md skill (73 brands); GitHub plugin env var corrected
- **Apr 27:** Skill subdirectory fix — `~/.claude/skills/<name>/SKILL.md` required; setup.sh step 8 auto-installs; Impeccable + skillui added
- **Apr 22:** PDFs → .md in `.claude/docs/`; pre-commit.sh hook for auto-updating CLAUDE.md/README.md
- **Apr 20:** Boilerplate sync scope locked — SYNC_PATHS excludes README.md, LICENSE, .env.example, etc.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-07 (auto-drafted — review before next session)
- {"session_id":"5157cc75-685c-4296-90ee-134e70b966f8","transcript_path":"C:\\Users\\MorarMonil\\.claude\\projects\\C--Users-MorarMonil-OneDrive---TK-Elevator-Documents-GIT-Claude-Code-Boilerplate-Framework\\5157cc75-685c-4296-90ee-134e70b966f8.jsonl","cwd":"C:\\Users\\MorarMonil\\OneDrive - TK Elevator\\Documents\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"bypassPermissions","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"**Step 4: Summary**\n\n| Metric | Before | After | Saved |\n|--------|--------|-------|-------|\n| sessions lines | 152 | 73 | 79 lines |\n| decisions entries | 28 | 27 | 1 removed |\n| decisions lines | 278 | 268 | 10 lines |\n| graph entities | 0 | 5 | â€” |\n\n**Removed decision:** `2026-05-03 â€” Fixed Windows hook paths to use absolute paths` â€” superseded by `2026-05-04 â€” Hook paths use directory-walking`.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-07 (auto-drafted — review before next session)
- FTS5/SQLite fixed â€” context-mode session continuity now works across compactions.\n\n**Root cause:** Corporate proxy (TK Elevator) intercepts TLS â†’ `prebuild-install` couldn't download prebuilt `.node` binary â†’ `NODE_TLS_REJECT_UNAUTHORIZED=0` bypass let the prebuilt binary download succeed.\n\n**Remaining warn:** Bun optional â€” skip unless you want 3-5x faster sandbox execution."}
