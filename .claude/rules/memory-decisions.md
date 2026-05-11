# Project Decisions

Architectural and technical decisions made during sessions — with date and rationale. Update this file whenever a non-trivial decision is made or confirmed.

---

## 2026-05-11 — Claude-Mem plugin integrated for persistent cross-session memory
- **Decision:** Integrated `claude-mem@claude-mem` plugin (thedotmack/claude-mem) as an additional memory layer on top of the existing three-tier system.
- **Why:** Existing memory (file-based + MCP graph) requires explicit writes. Claude-Mem automatically captures tool usage observations and generates semantic summaries passively — no manual update required. Complements the existing system rather than replacing it.
- **Implication:**
  - Plugin added to `settings.json` → `enabledPlugins` and `extraKnownMarketplaces` (github: thedotmack/claude-mem)
  - `setup.sh` step 7d: auto-installs via `claude plugin install claude-mem@claude-mem`
  - Settings auto-created at `~/.claude-mem/settings.json` on first run (no manual config needed)
  - `CLAUDE_MEM_MODE` env var added to `.env.example` (default: `code`; options: `code--zh`, `code--ja`)
  - Web viewer at http://localhost:37777 for real-time memory stream
  - Docs updated: `CLAUDE.md` (Plugins table, First-Time Setup), `README.md` (marketplace table, install block, Enabled Plugins table, setup.sh step 7d)
- **Pattern:** Passive observation layer — automatically captures without requiring Claude to explicitly write memory files. Works alongside existing Tier 1 (files) + Tier 2 (MCP graph) + Tier 3 (Caveman compression).

## 2026-05-07 — Context Mode integrated for 98% context window reduction
- **Decision:** Integrated `context-mode@context-mode` plugin (mksglu/context-mode, 13.8K stars) with combined statusline showing both context monitoring AND context-mode savings metrics.
- **Why:** Complements Caveman's output compression (75%) with input compression (98% via sandboxing). Context-mode sandboxes tool output (315 KB → 5.4 KB), tracks session continuity in SQLite FTS5 (survives conversation compaction), and compresses output ~65-75%. Together with Caveman: 75% output + 98% input = maximum token savings.
- **Implication:**
  - **Plugin integration:** Added `context-mode@context-mode` to `settings.json` → `enabledPlugins` and `extraKnownMarketplaces` (GitHub repo: mksglu/context-mode)
  - **Setup automation:** Step 7c added to `setup.sh` — auto-installs context-mode plugin via CLI; shows slash commands on success; displays manual `/plugin install` instructions if CLI unavailable
  - **Statusline combined:** Created `.claude/scripts/advanced-statusline.py` wrapper that calls both `context-monitor.py` (existing context usage + session metrics) and `context-mode statusline` (savings metrics), then merges output with pipe separator. Graceful fallbacks if either script fails. Updated `settings.json` statusLine command to use wrapper.
  - **Statusline format:** `[Model] 📁 directory | 🌿 branch (N) | 🧠 🟢 bar N% | 💰 $X.XX ⏱ Nm 📝 +N | 💎 $X.XX this session · $X.XX total · N% efficient`
  - **6 sandbox tools:** `ctx_batch_execute`, `ctx_execute`, `ctx_execute_file`, `ctx_index`, `ctx_search`, `ctx_fetch_and_index`
  - **5 meta tools:** `ctx_stats`, `ctx_doctor`, `ctx_upgrade`, `ctx_purge`, `ctx_insight` (personal analytics dashboard with 90 metrics, 37 insight patterns, 4 composite scores)
  - **Auto-installed hooks:** SessionStart (routing injection), PreToolUse (intercept large-output tools), PostToolUse (index to SQLite FTS5), PreCompact (preserve session data)
  - **Documentation updated:**
    - `CLAUDE.md` — Plugins table (context-mode row), First-Time Setup (step 7c added to comment)
    - `README.md` — Plugins → Marketplace table (context-mode entry), Installation instructions (full context-mode block), Enabled Plugins table (context-mode row with commands), Quick Start (step 7c description)
    - `.claude/settings.local.json.example` — activation guide for context-mode@context-mode
  - **Integration quality:** A+ — zero config needed (NO_KEY_NEEDED), statusline auto-combines both systems, graceful fallbacks, no breaking changes, preserves existing context-monitor.py
  - **Files created:** `.claude/scripts/advanced-statusline.py`, `.tmp/CONTEXT_MODE_INTEGRATION_COMPLETE.md` (full integration report)
  - **Files modified:** `.claude/settings.json` (plugin + statusLine), `.claude/hooks/setup.sh` (step 7c), `CLAUDE.md` (2 sections), `README.md` (4 sections), `.claude/settings.local.json.example` (activation guide), `memory-decisions.md` (this entry)
- **Verification:** After restart, run `/context-mode:ctx-doctor` to verify installation. Statusline shows `💎 $0.00 this session · $0.00 total · 0% efficient` initially, accumulates with usage.
- **Pattern:** Follows same integration pattern as Caveman — marketplace + setup.sh + combined approach + full docs. Context-mode handles INPUT compression (98%), Caveman handles OUTPUT compression (75%). Together = maximum savings.

## 2026-05-07 — settings.local.json.example completed with missing integrations
- **Decision:** Audited and updated `.claude/settings.local.json.example` to include all MCP servers, plugins, skills, and WebFetch domains from `.mcp.json` and `CLAUDE.md`.
- **Why:** The example file was missing activation guides, environment variables, permissions, and WebFetch domains for several integrations (OpenSpace, Context7, NotebookLM, Supabase MCP, Caveman, memory-shrunk). New users copying the template would miss critical configuration.
- **Implication:**
  - **Line 5 activation guide:** Changed from `"memory"` to `"memory-shrunk"` (reflects 2026-05-05 decision to use caveman-wrapped memory MCP)
  - **Env vars added:** `CAVEMAN_SHRINK_FIELDS`, `CAVEMAN_SHRINK_DEBUG` (lines 92-93)
  - **Permissions added:**
    - supabase-mcp: 8 tools (list_tables, describe_table, query, apply_migration, get_logs, get_advisors, get_project_url, get_publishable_api_key)
    - context7: 2 tools (query-docs, resolve-library-id)
    - notebooklm-mcp: 45 tools (notebook_*, source_*, studio_*, research_*, etc.)
    - Skills: 8 new entries (create-actor, caveman, caveman-stats, caveman-compress, caveman-commit, caveman-review, cavecrew, caveman-help)
    - WebFetch domains: 3 new (context7.com, notebooklm.google.com, monet.design)
  - **Files updated:** `.claude/settings.local.json.example` (7 sections modified)
  - **User impact:** Fresh clones now have complete configuration template; no more "Missing environment variables" errors for standard integrations

## 2026-05-06 — setup.sh PowerShell compatibility fixes
- **Problem:** setup.sh hangs indefinitely in PowerShell during Apify skill installation (step 7a); project skills installation fails with "cannot find folder /Path/.claude/skills" error (step 8)
- **Root causes:**
  1. `claude skill install` commands hang when invoked from bash script running in PowerShell environment (CLI waits for input that never comes)
  2. Path detection used `$HOME` which may not be correctly set in all Windows shells; no fallback to `$USERPROFILE`
  3. Destination directory `~/.claude/skills` not created before copying, causing failures if directory doesn't exist
  4. No verification that files actually copied successfully
- **Fixes implemented:**
  - **Step 7a (Apify skills):** Added 30-second timeout protection (if `timeout` command available); marketplace installation via `claude skill install <name>@apify-agent-skills` attempted for each of 5 skills; if timeout/failure occurs, displays manual `/skill install` commands; preserves automation where it works while providing graceful fallback
  - **Step 8 (project skills):** Enhanced cross-platform path detection with explicit `$USERPROFILE` fallback for Windows; converts Windows paths to Unix-style for bash compatibility using `cygpath` or sed; creates destination directory if missing; verifies each copy succeeded by checking for `SKILL.md` file; adds verbose output showing source and destination paths for debugging
- **Files updated:**
  - `.claude/hooks/setup.sh` — rewrote steps 7a (lines 256-319) and 8 (lines 321-364)
  - `CLAUDE.md` — updated First-Time Setup step 7a description (line 138)
  - `README.md` — updated Quick Start step 7a and 8 descriptions (lines 222, 224)
  - `memory-decisions.md` — this entry
- **Testing:** User should run `rm -f .claude/.setup-complete && bash .claude/hooks/setup.sh` in PowerShell to verify fixes
- **Timeout strategy:** Uses `timeout 30` if available (Linux/macOS with coreutils); falls back to no timeout on systems without the command; warns users they can Ctrl+C if hanging; marketplace configuration in `settings.json` → `extraKnownMarketplaces` → `apify-agent-skills`

## 2026-05-05 — Caveman integrated as transparent token compression layer (Tier 3)
- **Decision:** Integrated `caveman@caveman` plugin and `caveman-shrink` MCP proxy as an optional compression layer across the existing 3-tier memory system. Replaced `memory` MCP with `memory-shrunk` (caveman-wrapped) in `.mcp.json`.
- **Why:** The framework already has robust memory systems (file-based + MCP knowledge graph), but every session loads substantial context. Caveman adds a transparent optimization layer that reduces token overhead on both inputs (via `/caveman-compress` for files and `caveman-shrink` for MCP metadata) and outputs (via `/caveman` compression modes) without changing the underlying memory architecture.
- **Implication:**
  - **Three-tier system becomes four** — added Tier 3: Compression Layer to `memory-guidelines.md` with full explanation of when/how to use each Caveman tool
  - **MCP server change:** `memory` → `memory-shrunk` in `.mcp.json` and `settings.json` — wraps the standard memory MCP with `npx caveman-shrink` stdio proxy for ~50% metadata reduction
  - **Plugin added:** `caveman@caveman` to `settings.json` → `enabledPlugins` and `extraKnownMarketplaces`
  - **Setup automation:** Step 7b added to `setup.sh` — auto-installs caveman plugin via CLI
  - **Documentation updated:**
    - `memory-guidelines.md` — new Tier 3 section with tool matrix, integration points, when-to-use guide, trade-offs
    - `CLAUDE.md` — added to Plugins, Skills (6 new commands), MCP Servers (`memory-shrunk` entry), Key Commands (caveman commands), First-Time Setup (step 7b)
    - `README.md` — added to Plugins marketplace table, installation instructions, Enabled Plugins table, Skills section (6 commands), MCP Servers table (`memory-shrunk` entry), setup.sh step 7b
    - `.claude/settings.local.json.example` — added activation guides for `caveman@caveman` and `memory-shrunk`
  - **New commands available:** `/caveman` (activate compression), `/caveman-stats` (session tracking), `/caveman-compress` (shrink memory files), `/caveman-commit` (terse commits), `/caveman-review` (single-line PR comments), `/cavecrew` (compressed subagents)
  - **Token savings:** 75% on Claude responses (output), ~46% on memory files (input), ~50% on MCP metadata (input)
  - **Statusline integration:** `CAVEMAN_STATUSLINE_SAVINGS=1` env var shows lifetime token savings in statusline badge
  - **Trade-offs:** Compressed output is telegraphic (fragments, dropped articles) — readable but less formal; memory file compression is one-way (keep backups); most valuable in heavy sessions, not needed for simple queries
  - **Pattern:** Caveman is a **transparent optimization** — doesn't change what you store or how you query it, just reduces the token cost of loading/generating that content
- **Source:** [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — 75% token reduction validated via benchmarks (22-87% range, 65% average across diverse tasks)

---

<!-- Example entry format:
## 2026-04-06 — Use Trigger.dev for background jobs
- **Decision:** All async/scheduled work runs as Trigger.dev tasks, not cron scripts
- **Why:** Checkpointing, retry logic, and observability built-in; no infra to manage
- **Implication:** New background tasks must follow the orchestrator+processor pattern

## 2026-04-06 — Supabase as primary database
- **Decision:** Postgres via Supabase for all persistent storage
- **Why:** OAuth auth, RLS, and real-time subscriptions needed; team already has access
- **Implication:** All schema changes go through Supabase migrations, not raw SQL
-->

---

## 2026-05-05 — Apify agent skills integrated (5 skills from apify/agent-skills marketplace)
- **Decision:** Added `apify/agent-skills` marketplace to `settings.json` and integrated all 5 skills: `apify-ultimate-scraper`, `apify-actor-development`, `apify-actorization`, `apify-generate-output-schema`, and `apify-actor-commands`.
- **Why:** Provides comprehensive guided workflows for the entire Apify ecosystem — from using existing Actors for data extraction (130+ platforms) to developing custom Actors in JS/TS/Python. Previously only `apify-ultimate-scraper` was installed manually; now all skills install automatically via `setup.sh`.
- **Implication:**
  - Marketplace added to `settings.json` → `extraKnownMarketplaces` → `apify-agent-skills`
  - Setup.sh step 7a: auto-installs all 5 Apify skills via `claude skill install <skill>@apify-agent-skills`
  - CLAUDE.md routing table expanded: 4 new rows for Actor development workflows
  - CLAUDE.md Skills section: 5 new skills documented (apify-ultimate-scraper, actor-development, actorization, generate-output-schema, create-actor)
  - CLAUDE.md MCP Servers section: apify entry expanded with full skill integration details (14 workflow guides, intelligent CLI/MCP routing)
  - README.md updated: step 7a added to Quick Start, new "Apify Agent Skills" section in Skills table, marketplace table updated, MCP Servers → apify entry expanded
  - Apify MCP integration now routes through skills: `/apify-ultimate-scraper` intelligently chooses between `apify` CLI (lightweight, token-free) and MCP tools (batch operations, schema extraction) based on task type
  - 14 pre-written workflow guides cover: lead generation, competitive intel, influencer vetting, brand monitoring, review analysis, content/SEO, social analytics, trend research, job market/recruitment, real estate/hospitality, e-commerce price monitoring, contact enrichment, knowledge base/RAG, company research
  - Actor development stack now fully supported: create → debug → actorize existing code → generate schemas → deploy
  - Source: https://github.com/apify/agent-skills

## 2026-05-05 — OpenSpace converted to git submodule with auto-sync
- **Decision:** `tools/openspace/` is now a git submodule (hybrid: Option 1 + Option 2) — tracks specific upstream commits while auto-syncing every session via `openspace-sync.sh` hook.
- **Why:** 
  - Reproducible builds: Each commit in the parent repo tracks an exact OpenSpace version
  - Always up-to-date: Auto-sync hook pulls latest from HKUDS/OpenSpace every session
  - Fresh clone friendly: `setup.sh` auto-initializes submodule for new team members
  - Standard Git workflow: Anyone familiar with submodules can work with it
  - Manual control: Can pin to a specific version if needed; auto-sync can be disabled
- **Implication:**
  - Infrastructure complete: `openspace-sync.sh` hook created, `stop.sh` updated to call it, `setup.sh` updated to initialize submodule
  - Conversion complete: `tools/openspace/` is an active git submodule (verified 2026-05-11)
  - All integrations preserved: Skills (`openspace/`, `delegate-task/`, `skill-discovery/`), MCP server (`.mcp.json` + `settings.json`), VSCode launch configs (5 total), `.env` paths
  - Auto-sync behavior: Silent if up-to-date; pulls updates if available; skips if uncommitted changes exist; updates submodule pointer in parent repo
  - Documentation updated: `CLAUDE.md` (Key Commands, First-Time Setup, Hooks, Project Structure), `README.md` (Quick Start, Hooks, Project Structure), conversion guide created
  - Pattern matches autoresearch-sync.sh: Same upstream sync pattern, called by `stop.sh`

## 2026-05-04 — Hook paths use directory-walking instead of git rev-parse
- **Decision:** All hook commands in `settings.json` now search upwards from the current directory to find `.claude/hooks/*.sh` scripts instead of using `git rev-parse --show-toplevel`.
- **Why:** The `tools/openspace/` directory contains its own `.git` repository (cloned from HKUDS/OpenSpace), so `git rev-parse --show-toplevel` returns the wrong root when executed from within that subdirectory. This caused stop.sh to fail with "No such file or directory" errors when the working directory was inside `tools/openspace/`.
- **Implication:** 
  - All four hooks (Setup, PreToolUse, PostToolUse, Stop) now use: `bash -c 'dir="$(pwd)"; while [ "$dir" != "/" ] && [ ! -f "$dir/.claude/hooks/<script>.sh" ]; do dir="$(dirname "$dir")"; done; if [ -f "$dir/.claude/hooks/<script>.sh" ]; then bash "$dir/.claude/hooks/<script>.sh"; fi'`
  - Hooks work from any directory in the project, including nested git repositories
  - More robust than git-based path resolution
  - Pattern is portable across all Unix-like systems (macOS, Linux, Git Bash on Windows)

## 2026-05-04 — OpenSpace CLI-first priority established
- **Decision:** OpenSpace follows CLI-first pattern (like Playwright and Firecrawl). Always try CLI commands before escalating to MCP tools.
- **Why:** MCP protocol overhead consumes ~200-500 tokens per call. CLI execution via Bash is token-free beyond the command itself. Over 20 OpenSpace operations, this saves 4K-10K tokens.
- **Implication:** 
  - Priority order: (1) `openspace` CLI via Bash → (2) `mcp__openspace__*` tools as backup
  - CLI handles: task execution (`--query`), skill search (`--search`), download/upload (`openspace-download-skill`, `openspace-upload-skill`)
  - MCP escalation only when: structured output needed, multi-step workflows require state persistence, integration with other MCP tools, automatic skill evolution tracking
  - CLI saves cumulative tokens on repeated OpenSpace usage
  - SKILL.md updated with CLI vs MCP decision matrix
  - CLAUDE.md routing table and Key Commands section updated to reflect CLI-first pattern
  - Pattern consistency: OpenSpace, Playwright, Firecrawl, NotebookLM all follow same CLI-first architecture

## 2026-05-03 — LightRAG integrated for graph-based RAG
- **Decision:** Integrated HKUDS/LightRAG (13K+ stars, EMNLP 2025) in `tools/lightrag/` directory. Provides graph-based knowledge extraction and entity-relationship Q&A, multimodal document processing, and Web UI + REST API.
- **Why:** Fills the gap between simple vector search (Pinecone MCP) and full graph-based RAG with knowledge extraction. LightRAG extracts entities and relationships from documents, stores them in a queryable graph, and supports 5 query modes (naive, local, global, hybrid, mix with reranker). Includes Web UI for visualization and REST API for programmatic access — recommended for production use over embedded Python library.
- **Implication:** 
  - New directory: `tools/lightrag/` with pyproject.toml (lightrag-hku dependency) and README.md (full documentation)
  - New skill: `/lightrag` at `.claude/skills/lightrag/SKILL.md`
  - setup.sh step 14: runs `uv sync` in tools/lightrag/ to install dependencies
  - .env.example: added ANTHROPIC_API_KEY and OLLAMA_HOST (alongside existing OPENAI_API_KEY and GEMINI_API_KEY)
  - CLAUDE.md: added to routing table ("Graph-based RAG / knowledge extraction"), Key Commands section (lightrag server command), First-Time Setup (lightrag dependencies), Project Structure (tools/lightrag/), Skills section (/lightrag entry)
  - README.md: updated setup.sh step 14 description, added tools/lightrag/ to Project Structure with file listing, added /lightrag to Project Skills table with complete description, updated hooks table (setup.sh now 16 steps)
  - Requirements: Python 3.10+, `uv` package manager (auto-installed by setup.sh step 5), LLM API key (OpenAI/Claude/Gemini/Ollama)
  - Storage backends: default nano-vectordb (no setup), Neo4J, MongoDB, PostgreSQL, OpenSearch (optional)
  - Use cases: Document Q&A, knowledge bases, semantic search with graph relationships, multimodal RAG (PDFs, images, tables)
  - Production recommendation: Use LightRAG Server (REST API + Web UI) instead of embedding Python library directly
  - Located in tools/ since it's a reusable utility for any project created in this framework

## 2026-05-03 — AutoResearch setup automation & upstream autosync
- **Decision:** Enhanced setup.sh step 13 to automatically run `verify_setup.py` after `uv sync` completes, showing immediate dependency verification. Created `.claude/hooks/autoresearch-sync.sh` to automatically sync `tools/autoresearch/` with upstream karpathy/autoresearch repo via Stop hook every session.
- **Why:** Eliminates manual verification step — users get instant confirmation that PyTorch and all 7 dependencies installed correctly (or specific error messages if something failed). Autosync ensures local copy stays current with upstream improvements/fixes without requiring manual `git pull` commands.
- **Implication:** 
  - setup.sh now runs full dependency check automatically after PyTorch installation (shows [OK]/[FAIL] status for each package)
  - New hook: `.claude/hooks/autoresearch-sync.sh` (runs silently if no changes; pulls updates if available; skips if local uncommitted changes exist)
  - Stop hook updated to call autoresearch-sync.sh every session
  - Consolidated SETUP_NOTES.md and verify_setup.py to `tools/autoresearch/` root level (removed nested `tools/autoresearch/tools/` subdirectory that had duplicate files)
  - All documentation paths now reference correct locations

## 2026-05-03 — AutoResearch integrated for autonomous ML experiments
- **Decision:** Integrated karpathy/autoresearch (33K+ stars) in `tools/autoresearch/` directory. Agent modifies GPT training code, runs 5-minute experiments, evaluates improvements autonomously.
- **Why:** Enables overnight autonomous machine learning research. Agent can run ~100 experiments while user sleeps, automatically keeping improvements and discarding failures based on validation bits-per-byte metric. Located in tools/ since it's a reusable utility for any project created in this framework.
- **Implication:** 
  - New directory: `tools/autoresearch/` with prepare.py (data prep, read-only), train.py (agent edits this), program.md (agent instructions), pyproject.toml (dependencies)
  - New skill: `/autoresearch` at `.claude/skills/autoresearch/SKILL.md`
  - setup.sh step 13: runs `uv sync` to install PyTorch and ML dependencies in tools/autoresearch/
  - settings.json: added `Bash(uv *)` and `PowerShell(uv *)` permissions
  - CLAUDE.md: added to routing table, Skills section, Project Structure, Key Commands
  - README.md: added to setup.sh steps, Project Structure, Project Skills table
  - Requires: single NVIDIA GPU (H100 tested), Python 3.10+, `uv` package manager (auto-installed by setup.sh)
  - Platform support: Windows/MacOS/AMD via community forks documented in tools/autoresearch/README.md

## 2026-05-02 — CLI-Anything plugin integrated for AI-native CLI generation
- **Decision:** Added `cli-anything@cli-anything` plugin from HKUDS/CLI-Anything marketplace. Added to `extraKnownMarketplaces` and `enabledPlugins` in `settings.json`. Setup.sh step 7 auto-installs the plugin.
- **Why:** Enables automatic generation of AI-native command-line interfaces for existing software with accessible source code (GIMP, Blender, LibreOffice, Audacity, etc.). Bridges the gap between AI agents and professional applications through structured CLI commands rather than fragile GUI automation or limited APIs. 50+ supported applications with 2,280+ passing tests demonstrating production-grade reliability.
- **Implication:** Plugin provides 5 slash commands: `/cli-anything` (build CLI harness), `/cli-anything:refine` (expand coverage), `/cli-anything:test` (run test suite), `/cli-anything:validate` (standards validation), `/cli-anything:list` (list available tools). Added to CLAUDE.md routing table ("AI-native CLI for existing software" row) and Plugins section. README.md updated with marketplace entry, installation instructions, and Enabled Plugins table entry. Setup.sh updated to install via `claude plugins install cli-anything@cli-anything` with manual fallback instructions.

## 2026-05-01 — NotebookLM MCP CLI integrated following CLI-first pattern
- **Decision:** Added `notebooklm-mcp-cli` as both a CLI tool (`nlm`) and MCP server (`notebooklm-mcp`), with CLI as primary and MCP as backup — matching the pattern established for Playwright and Firecrawl.
- **Why:** Follows the established CLI-first architecture pattern to minimize token consumption (MCP protocol overhead) while preserving MCP backup for multi-step interactive flows. The tool provides programmatic access to Google NotebookLM for creating notebooks, adding sources, generating AI content (podcasts, videos, briefings), and managing research workflows.
- **Implication:** `setup.sh` step 11 now installs 5 global CLI tools (was 4): skillui, firecrawl-cli, codex-cli, gemini-cli, and notebooklm-mcp-cli (via `uv tool install`). Authentication requires `nlm login` (cookie-based, persists 2-4 weeks). MCP server requires `uvx` (already installed for google-workspace-mcp and alpaca). Skill at `.claude/skills/notebooklm/SKILL.md` provides full usage guide. CLI permissions added to `settings.json`. MCP server added to `.mcp.json` and `enabledMcpjsonServers`. Documentation updated in CLAUDE.md (routing table, Skills section, MCP Servers section, First-Time Setup) and README.md (setup.sh steps, Prerequisites, Project Skills table, MCP Servers table).

## 2026-05-01 — codex-cli and gemini-cli added to setup.sh global CLI installations
- **Decision:** Added `codex-cli` (`@openai/codex@latest`) and `gemini-cli` (`@google/gemini-cli@latest`) to setup.sh step 11 — both install globally via npm with `@latest` tag to ensure newest versions. Added `OPENAI_API_KEY` and `GEMINI_API_KEY` to all credential files with clear CLI vs MCP usage documentation.
- **Why:** Required by the `/three-brain` skill (auto-router for Codex review/rescue and Gemini multimodal/long-context routes). Codex startup check expects v0.125+, Gemini expects v0.39+. The `@latest` tag ensures fresh installs always get the newest versions (codex v0.128.0, gemini v0.40.1 as of 2026-05-01).
- **Implication:** First-time setup now installs 4 global CLI tools with `@latest` tag: skillui, firecrawl-cli, codex-cli, gemini-cli. API keys added to `.env.example` (with CLI tools section header), `.env` (with actual keys filled in), `settings.local.json.example` (with `__note_cli_tools` guide entry), and `settings.local.json` (OPENAI_API_KEY added). Documentation updated in CLAUDE.md (First-Time Setup section, Skills table) and README.md (setup.sh step 11, Project Skills table).

## 2026-04-30 — CLAUDE.md improvements: First-Time Setup section & tools/ clarity
- **Decision:** Added "First-Time Setup" consolidation section to CLAUDE.md. Clarified `tools/` directory as "Deterministic execution scripts (Python/Node)" with `playwright.js` example.
- **Why:** Quality audit (97/100) identified two minor gaps: (1) `npm install` command was missing, scattered setup steps weren't consolidated; (2) "Python scripts" claim was ambiguous for a boilerplate template that ships with Node scripts and may have Python added per-project.
- **Implication:** New contributors get a single copy-paste setup flow. tools/ directory description now matches reality (playwright.js exists) and signals flexibility for future scripts.

## 2026-04-30 — ui-ux-pro-max-instructions.md moved to docs/ (reference-only)
- **Decision:** `ui-ux-pro-max-instructions.md` moved from `.claude/rules/` (auto-loaded) to `.claude/docs/` (reference-only). Removed from `read-guard.py` large-file warnings.
- **Why:** 300-line design reference doc was loading every session (~1500 tokens). Only needed when actively doing frontend work. Similar optimization to `trigger-api-reference.md` move.
- **Implication:** Frontend work still references it via `frontend-instructions.md` → load on demand. Path updates in README.md, frontend-instructions.md, and read-guard.py. Saves ~1500 tokens per non-frontend session.

## 2026-04-28 — design-md skill added from awesome-design-md collection
- **Decision:** Added `/design-md` as a project skill at `.claude/skills/design-md/SKILL.md`. Uses `npx getdesign@latest add <brand>` to fetch any of 73 brand DESIGN.md files on demand.
- **Why:** Fills a gap between `skillui` (scrapes live sites) and designing from scratch. Covers 73 known brands (Linear, Stripe, Vercel, Notion, Figma, Spotify, Tesla, Supabase, etc.) with pre-built design system docs that LLMs read natively. No API keys or scraping required.
- **Implication:** `frontend-instructions.md` updated to route brand-named requests to `/design-md` first, before `/skillui`. `CLAUDE.md` and `README.md` updated to document the skill. Decision guide in SKILL.md clarifies which tool to use when.

## 2026-04-28 — webgpu-threejs-tsl skill integrated; setup.sh copies full skill dirs
- **Decision:** Added `dgreenheck/webgpu-claude-skill` as a project skill at `.claude/skills/webgpu-threejs-tsl/`. setup.sh step 8 now uses `cp -r` to copy the entire skill directory instead of just `SKILL.md`.
- **Why:** The webgpu skill ships with 7 reference docs, 5 JS examples, and 2 templates that SKILL.md references by relative path. Copying only SKILL.md would leave broken relative-path references on fresh clones. The `cp -r` approach is backward-compatible — existing skills (site-teardown, skillui) have only SKILL.md and are unaffected.
- **Implication:** Any future skill with supporting files will be fully preserved by setup.sh without extra config. Skills can now ship with any directory structure.

## 2026-04-22 — Reference docs converted from PDF to Markdown
- **Decision:** All three PDFs in `.claude/docs/` converted to `.md`. `Claude_Code_Context_Management_Hacks.pdf` (23MB) required `pdftotext` (bundled with Git for Windows) since it exceeded Claude's 20MB read limit.
- **Why:** `.md` files are directly readable as session context; PDFs require external tooling and consume more context overhead.
- **Implication:** All `README.md` and `CLAUDE.md` references updated. Original PDFs remain in place alongside the `.md` files.

## 2026-04-27 — Project skills use subdirectory + SKILL.md format
- **Decision:** Skills in `.claude/skills/` must follow `<skill-name>/SKILL.md` structure (not flat `.md` files). `setup.sh` step 8 copies them to `~/.claude/skills/<name>/SKILL.md` where Claude Code actually reads them.
- **Why:** Claude Code's skill discovery only scans `~/.claude/skills/` and requires the subdirectory + `SKILL.md` naming convention. Flat `.md` files at `.claude/skills/skill-name.md` are silently ignored — skills won't appear in the available list and `/skill-name` returns "Unknown command."
- **Implication:** Any new project skill must be created as `.claude/skills/<name>/SKILL.md`, then re-run `bash .claude/scripts/setup.sh` (or restart Claude Code after manual copy) to activate.

## 2026-04-27 — impeccable added as frontend design plugin
- **Decision:** `impeccable@impeccable` (github.com/pbakaus/impeccable) added to `enabledPlugins` and `extraKnownMarketplaces` in `settings.json`. `setup.sh` step 7 auto-installs it.
- **Why:** Provides 23 structured commands (`/impeccable polish`, `/impeccable audit`, `/impeccable critique`, etc.) and 24-issue anti-pattern detection that explicitly targets LLM-generated UI mistakes. Complements `frontend-design` and `ui-ux-pro-max` with opinionated design laws.
- **Implication:** `frontend-instructions.md` updated to include impeccable in the "Always Do First" workflow for critique/polish/audit passes.

## 2026-04-27 — skillui CLI added for design system extraction
- **Decision:** `skillui` (npm install -g skillui, github.com/amaancoderx/npxskillui) added as a project skill and CLI tool. The `/skillui` skill is at `.claude/skills/skillui/SKILL.md`.
- **Why:** Pure-static design system extraction from live sites, repos, or local dirs — no AI or API keys required. Outputs `SKILL.md`, `DESIGN.md`, and token JSON files that Claude Code auto-loads, enabling "match this site's design" workflows before any frontend build.
- **Implication:** Use `skillui` before building any UI that should match an existing site's visual language. `frontend-instructions.md` updated to include it in the "Always Do First" section.

## 2026-04-28 — GitHub plugin enabled; GITHUB_PERSONAL_ACCESS_TOKEN is the correct env var
- **Decision:** `github@claude-plugins-official` is enabled (`true`) in `settings.json`. The required env var is `GITHUB_PERSONAL_ACCESS_TOKEN` (not `GITHUB_TOKEN`).
- **Why:** The plugin raises "Invalid MCP server config for 'github': Missing environment variables: GITHUB_PERSONAL_ACCESS_TOKEN" if the key is missing or named incorrectly. `GITHUB_TOKEN` was a redundant duplicate that has been removed.
- **Implication:** `settings.local.json` holds only `GITHUB_PERSONAL_ACCESS_TOKEN`. The example file and both docs now document this correctly. Token needs `repo` + `read:org` scopes to read private repos.

## 2026-04-29 — Playwright CLI integrated as direct Bash tool instead of MCP server
- **Decision:** Browser automation uses `node tools/playwright.js` (direct Bash execution) rather than a Playwright MCP server. `package.json` adds `playwright` as a dev dependency. A `/playwright` skill at `.claude/skills/playwright/SKILL.md` guides usage.
- **Why:** MCP servers consume tokens for every tool call via the protocol overhead. Direct CLI execution via Bash is token-free beyond the command itself. The `playwright` npm package ships its own CLI (`npx playwright screenshot/pdf`) and a Node API for structured scraping — no extra server process needed.
- **Implication:** `setup.sh` step 9 runs `npm install && npx playwright install chromium` on fresh clones. `tools/playwright.js` handles screenshot, scrape, pdf, and links commands. Large-scale scraping (1000+ pages) still routes to Apify MCP.

## 2026-04-29 — playwright-mcp added as backup; CLI remains primary
- **Decision:** `@playwright/mcp@latest` added to `.mcp.json` and `enabledMcpjsonServers` as a backup option. The `node tools/playwright.js` CLI remains the primary tool for all browser automation.
- **Why:** CLI is token-free and sufficient for screenshots, scraping, PDFs, and link extraction. MCP is only needed for multi-step interactive flows (login → navigate → form fill), accessibility tree extraction (`browser_snapshot`), mid-session JS evaluation (`browser_evaluate`), or keeping a browser session alive across tool calls.
- **Implication:** `workflows/browser-automation.md` updated with "CLI first" priority rule and a clear decision matrix for when to escalate to MCP. No API key required — activates automatically.

## 2026-04-29 — Firecrawl CLI + MCP integrated; CLI is always primary
- **Decision:** Firecrawl integrated as two layers: `firecrawl` CLI (global npm install) as the primary tool, `firecrawl-mcp` (`npx firecrawl-mcp`) as backup. Both share the same `FIRECRAWL_API_KEY`. Skill at `.claude/skills/firecrawl/SKILL.md`, workflow at `workflows/web-scraping.md`.
- **Why:** Same CLI-first pattern used for Playwright — CLI calls are token-free and faster. MCP backup is only needed for batch scraping (`firecrawl_batch_scrape`) or schema-driven LLM extraction (`firecrawl_extract`) where in-session structured results are needed. Apify MCP remains the choice for 1000+ page large-scale scraping.
- **Implication:** `FIRECRAWL_API_KEY` added to `.env.example` and `settings.local.json.example`. `firecrawl-mcp` added to `.mcp.json` and `enabledMcpjsonServers`. `Bash(firecrawl:*)` added to `settings.json` permissions. Routing table in `CLAUDE.md` distinguishes: Firecrawl for structured extraction/crawl, Playwright for interactive/JS-heavy pages, Apify for massive scale.

## 2026-04-20 — Boilerplate sync scope is locked
- **Decision:** `SYNC_PATHS` is permanently locked to: `.claude/`, `workflows/`, `tools/`, `brand_assets/`, `CLAUDE.md`, `.mcp.json`
- **Why:** Project-specific files (`README.md`, `LICENSE`, `.env.example`, `.gitignore`, `.gitattributes`, `CODEOWNERS`, `.github/PULL_REQUEST_TEMPLATE.md`) must never be overwritten by upstream boilerplate syncs — they carry per-project customizations
- **Implication:** Never re-add the excluded files to `SYNC_PATHS` in any sync script, edge function, or workflow config


## 2026-05-07 — memory-shrunk Windows fix: use cmd /c npx as upstream command
- **Decision:** Changed `memory-shrunk` upstream args in `.mcp.json` from `["npx", "-y", "@modelcontextprotocol/server-memory"]` to `["cmd", "/c", "npx", "-y", "@modelcontextprotocol/server-memory"]`.
- **Why:** `caveman-shrink` calls `spawn(args[0], args.slice(1))` without `shell: true`. On Windows, `npx` is `npx.cmd` — a CMD script — which Node.js `spawn` cannot resolve without shell mode, causing `ENOENT`. Using `cmd /c npx ...` works because `cmd.exe` is a real executable, and it passes stdin through to npx correctly.
- **How to apply:** Any `caveman-shrink` wrapper in `.mcp.json` on Windows must use `cmd /c npx` instead of bare `npx` as the upstream command.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-11 — edit or delete below -->
- `./CLAUDE.md` (Project Root) â€” 390 lines\n\n**Score: 97/100 (Grade: A+)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 20/20 | 10+ command blocks, all copy-paste ready, labeled by tool |\n| Architecture clarity | 20/20 | Routing table, WAT framework, full dir tree â€” outstanding |\n| Non-obvious patterns | 14/15 | MCP env var gotcha, proxy fix, CLI-first pattern documented |\n| Conciseness | 13/15 | 390 lines â€” justified by scope; prior trimming removed verbose blocks |\n| Currency | 15/15 | Bun PS script updated, find-skills added, spline prereqs reflected |\n| Actionability | 15/15 | All commands executable |\n\n**No blocking issues.** One minor gap:\n\n- **`/spline-3d` skill missing from Skills table.** It's in the routing table (\"Embed Spline 3D scenes\") but not listed in the Built-in or Project skills section.
