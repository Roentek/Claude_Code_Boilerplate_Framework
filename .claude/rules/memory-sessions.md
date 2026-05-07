# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-05 (session 15) — Caveman token compression layer integration
- **Integrated:** `caveman@caveman` plugin and `caveman-shrink` MCP proxy as Tier 3 compression layer across existing memory system
- **Files modified:**
  - `.claude/settings.json` — added caveman marketplace + enabled plugin, replaced `memory` with `memory-shrunk` in enabledMcpjsonServers
  - `.mcp.json` — added `memory-shrunk` server (wraps memory MCP with caveman-shrink stdio proxy)
  - `.claude/settings.local.json.example` — added activation guides for caveman plugin and memory-shrunk MCP
  - `.claude/hooks/setup.sh` — added step 7b for caveman plugin installation
  - `memory-guidelines.md` — added Tier 3: Compression Layer section with full integration guide
  - `CLAUDE.md` — updated Plugins, Skills, MCP Servers, Key Commands, First-Time Setup sections
  - `README.md` — updated Plugins marketplace table, installation instructions, Enabled Plugins, Skills, MCP Servers, setup.sh steps
  - `memory-decisions.md` — logged integration decision with full rationale and implications
  - `memory-sessions.md` — this entry
- **New commands available:** `/caveman` (75% response compression), `/caveman-stats` (session token tracking), `/caveman-compress` (46% memory file reduction), `/caveman-commit` (terse commits), `/caveman-review` (single-line PR comments), `/cavecrew` (compressed subagents)
- **Token savings:** 75% on outputs, ~46% on memory files, ~50% on MCP metadata, 65% average overall (validated benchmarks)
- **Architecture:** Caveman operates as a **transparent optimization layer** — doesn't change what you store or how you query memory, just reduces the token cost
- **Integration quality:** Complete — plugin marketplace added, MCP server configured, setup automation added (step 7b), all documentation updated (5 files), decision logged
- **Source:** [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — stdio proxy for MCP compression + plugin for output compression
- **Summary document:** Created `.tmp/CAVEMAN_INTEGRATION_COMPLETE.md` with activation instructions, verification steps, trade-offs, and cost impact analysis

## 2026-05-05 (session 14) — OpenSpace launch config verification + setup.sh port fix
- **Verified:** All 5 VSCode launch configurations work correctly with git submodule architecture
- **Tested:** Backend server (Python), frontend dev server (React/Vite), compound full-stack config
- **Issues found & fixed:**
  - Missing frontend dependencies → Already automated in setup.sh (npm install)
  - Missing .env file → Already automated in setup.sh (copy from .env.example)
  - Port mismatch (3888 vs 3789) → **NEW:** Added auto-fix to setup.sh
- **Enhancement implemented:** setup.sh now runs `sed` to align .env port with package.json (3789)
- **Files updated:**
  - `.claude/hooks/setup.sh` — Added port alignment after .env creation (lines 622-627)
  - `.tmp/openspace-launch-verification.md` — Complete test report with all findings
  - `.tmp/openspace-setup-automation-verification.md` — Automation analysis + enhancement documentation
  - `memory-sessions.md` — This entry
- **Result:** Fresh clones now get properly aligned .env file with zero user confusion
- **Git submodule status:** Initialized at commit d1e367d0, all integrations intact (skills, MCP, VSCode, .env paths)
- **VSCode configs verified:** 3 individual + 1 compound = all working, paths correct for submodule

## 2026-05-05 (session 13) — OpenSpace git submodule + auto-sync infrastructure
- **Implemented:** Complete git submodule infrastructure for `tools/openspace/` with automatic upstream sync (hybrid approach: Option 1 + Option 2)
- **Files created:**
  - `.claude/hooks/openspace-sync.sh` — Auto-sync hook (pulls upstream HKUDS/OpenSpace, updates submodule pointer, skips if uncommitted changes)
  - `.claude/docs/openspace-submodule-conversion.md` — Complete 6-step conversion guide with troubleshooting, integrations checklist, benefits summary
  - `OPENSPACE_SUBMODULE_SETUP.md` — Executive summary of all work done + next steps for user
- **Files updated:**
  - `.claude/hooks/stop.sh` — Added `openspace-sync.sh` call after `autoresearch-sync.sh`
  - `.claude/hooks/setup.sh` — Added submodule initialization check in step 15 (before pip install)
  - `CLAUDE.md` — Updated 5 sections: Key Commands (submodule note + manual update command), First-Time Setup (submodule initialization), Hooks table (autoresearch-sync + openspace-sync rows), Project Structure (openspace/ marked as git submodule), conversion guide reference
  - `README.md` — Updated 5 sections: Quick Start step 15 (submodule initialization), Hooks table (openspace-sync row), stop.sh logic (added step 2), Project Structure (hooks/ + openspace/ entries), conversion guide reference
  - `memory-decisions.md` — Logged hybrid submodule decision with full rationale
  - `memory-sessions.md` — This entry
- **Integrations verified (all intact):**
  - ✅ Environment: `.env` paths (`OPENSPACE_HOST_SKILL_DIRS`, `OPENSPACE_WORKSPACE`)
  - ✅ VSCode: 5 launch configs (2 LightRAG + 3 OpenSpace)
  - ✅ Skills: `openspace/`, `delegate-task/`, `skill-discovery/`
  - ✅ MCP: `.mcp.json` config + `settings.json` enabled
- **Auto-sync behavior:** Runs every session via `stop.sh`; silent if up-to-date; pulls if updates available; skips if uncommitted changes; updates submodule pointer
- **User action required:** Run 6-step conversion from `.claude/docs/openspace-submodule-conversion.md` to convert existing clone to submodule
- **Benefits:** Reproducible builds (pinned commits) + always up-to-date (auto-sync) + fresh clone friendly (auto-init) + manual control (can pin versions)

---

## 2026-05-04 (session 12) — OpenSpace CLI-first priority established
- **Updated:** OpenSpace documentation to establish CLI-first token-saving pattern (matching Playwright, Firecrawl, NotebookLM)
- **Files updated:**
  - `.claude/skills/openspace/SKILL.md` — added “CLI vs MCP: Token-Saving Priority” section with decision matrix; added “CLI Commands (Use These First)” section with examples
  - `CLAUDE.md` — updated routing table entry (CLI first; MCP backup), updated Key Commands section with CLI/MCP priority comments
  - `README.md` — updated MCP servers table entry for openspace (CLI is always primary tool, saves ~200-500 tokens per call vs MCP)
  - `memory-decisions.md` — logged CLI-first decision with full rationale and implications
  - `memory-sessions.md` — this entry
- **Priority order:** (1) `openspace` CLI via Bash (token-free) → (2) `mcp__openspace__*` tools as backup (protocol overhead)
- **CLI commands:** `openspace --query “task”`, `openspace --search “keyword”`, `openspace-download-skill <id>`, `openspace-upload-skill /path/`
- **MCP escalation triggers:** structured output needed, multi-step workflows with state persistence, integration with other MCP tools, automatic skill evolution tracking
- **Token savings:** ~200-500 tokens per call; over 20 OpenSpace operations = 4K-10K tokens saved
- **Pattern consistency:** OpenSpace, Playwright, Firecrawl, NotebookLM all follow same CLI-first architecture

---

## Archive

**May 2026:**
- **May 3 (s11):** LightRAG graph-based RAG integration — HKUDS/LightRAG (13K+ stars) for knowledge graphs, multimodal RAG (PDFs/images/tables), 5 query modes; supports OpenAI/Claude/Gemini/Ollama; Web UI + REST API; `tools/lightrag/` with skill
- **May 3 (s10):** AutoResearch setup automation & upstream autosync hook — `verify_setup.py` auto-runs after `uv sync`; `.claude/hooks/autoresearch-sync.sh` syncs `tools/autoresearch/` with upstream karpathy/autoresearch every session
- **May 3 (s9):** AutoResearch integration — karpathy/autoresearch (33K+ stars) for autonomous ML research (overnight GPT training experiments); `tools/autoresearch/` with prepare.py, train.py, program.md; ~12 exp/hour, ~100 overnight; requires NVIDIA GPU
- **May 3 (s8):** CLI-Anything installation repaired — marketplace repo cloned, plugin installed to cache; all 5 commands confirmed available
- **May 2 (s7):** CLI-Anything plugin integration — `cli-anything@cli-anything` from HKUDS/CLI-Anything marketplace; generates AI-native CLIs for GIMP, Blender, LibreOffice, Audacity, etc.; 50+ apps, 2,280+ tests
- **May 1 (s6):** CLI permissions audit — consolidated all CLI tool permissions in `settings.json`; removed from `settings.local.json.example` (project-level, not machine-specific); 6 tools now have complete cross-platform permission coverage
- **May 1 (s5):** NotebookLM MCP CLI integration — `notebooklm-mcp-cli` added as both CLI (`nlm`) and MCP server following CLI-first pattern; cookie-based auth via `nlm login`; supports research workflows, content generation (podcasts/videos/briefings)

**April 2026:**
- **Apr 30 (s4):** three-brain skill integration & CLI tools — added codex-cli and gemini-cli to setup.sh step 11; documented three-brain auto-routing (Codex for review/rescue, Gemini for multimodal/long-context)
- **Apr 30 (s3):** CLAUDE.md quality audit — claude-md-improver skill scored 97/100; added First-Time Setup section; clarified tools/ directory purpose
- **Apr 30 (s2):** Memory cleanup & ui-ux-pro-max relocation — moved ui-ux-pro-max-instructions.md to `.claude/docs/` (reference-only); saves ~1500 tokens per non-frontend session
- **Apr 30:** Context & memory optimization — CLAUDE.md refactor (283→155 lines, 45% reduction); added context7 MCP for on-demand SDK docs; moved trigger-api-reference.md to docs/; created memory-distiller agent, compact-memory skill, memory-drafter.py, read-guard.py hook
- **Apr 29 (s3):** Clarified kie-ai vs Higgsfield routing in CLAUDE.md routing table
- **Apr 29 (s2):** Integrated Playwright CLI as direct Bash tool — created `package.json`, `tools/playwright.js`, skill, workflow; setup.sh step 9 installs Playwright + Chromium
- **Apr 29:** Diagnosed Alpaca MCP 401 — `${VAR}` in `.mcp.json` reads from OS process env, not `.env`; built PostToolUse autosync hook for CLAUDE.md/README.md updates
- **Apr 28:** webgpu-threejs-tsl skill integrated (855 stars, 16 files); setup.sh switched to `cp -r` for skill subdirectories
- **Apr 28 (s2):** /design-md skill added — 73 brand DESIGN.md files via `npx getdesign@latest add <brand>`
- **Apr 28 (s3):** 21st-dev-magic MCP server name corrected
- **Apr 28 (s4):** GitHub plugin fix — correct env var is `GITHUB_PERSONAL_ACCESS_TOKEN`
- **Apr 27:** `settings.local.json.example` created with credential template and `__activation_guide`
- **Apr 27 (s2):** Diagnosed skill loading failure — Claude Code requires `~/.claude/skills/<name>/SKILL.md` subdirectory format; setup.sh step 8 auto-installs skills; Impeccable plugin added
- **Apr 22:** PDFs in `.claude/docs/` converted to `.md` for direct context loading
- **Apr 22 (s2):** `pre-commit.sh` git hook created for auto-updating CLAUDE.md/README.md; stop.sh enhanced with doc-sync check
- **Apr 22 (s3):** README.md updated for pre-commit hook; expanded setup steps (5→9); hooks table corrected
- **Apr 20:** Boilerplate sync scope locked — `SYNC_PATHS` permanently excludes project-specific files (README.md, LICENSE, .env.example, .gitignore, .gitattributes, CODEOWNERS, PR template)
