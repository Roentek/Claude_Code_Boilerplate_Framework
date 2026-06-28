# Project Decisions

Architectural and technical decisions made during sessions — with date and rationale. Update this file whenever a non-trivial decision is made or confirmed.

---

## 2026-06-28 — notebooklm-py replaces notebooklm-mcp-cli (CLI: notebooklm, MCP: notebooklm-mcp)
- **Decision:** Replaced `notebooklm-mcp-cli` (jacob-bd, CLI: `nlm`) with `notebooklm-py[browser,mcp]` (teng-lin/notebooklm-py, CLI: `notebooklm`). Same pattern: CLI-first, MCP fallback via `notebooklm-mcp`.
- **Why:** `notebooklm-py` is dramatically more capable — quizzes, mind maps, research agents (web + Drive, fast/deep), source labels, sharing controls, multi-profile auth, headless token auth. Old `nlm` only covered notebooks/sources/basic generation.
- **Auth:** `notebooklm login` (browser, Chromium ~170MB first run). Headless: `notebooklm login --master-token --account you@gmail.com`. Multi-account via `notebooklm profile`.
- **MCP:** `.mcp.json` updated from `notebooklm-mcp-cli` → `notebooklm-py[mcp]` (same `uvx` pattern). Auto-config: `notebooklm mcp install claude-code`.
- **Files changed:** `cli-notebooklm.sh`, `.mcp.json`, `.claude/skills/notebooklm/SKILL.md`, `auth-reminders.sh`, `CLAUDE.md` (5 locations).
- **Source:** https://github.com/teng-lin/notebooklm-py (MIT)

## 2026-06-28 — Higgsfield CLI + plugin integrated (CLI-first over existing MCP-only)
- **Decision:** Added `@higgsfield/cli` (npm global) + `higgsfield@higgsfield-ai` plugin from `higgsfield-ai/skills` marketplace alongside the existing `higgsfield` MCP. Pattern: CLI-first, MCP fallback.
- **Why:** Higgsfield was already wired as MCP-only but the CLI and skills plugin were never integrated. CLI costs zero context tokens per call; MCP loads all tool schemas every turn. Skills plugin provides 4 slash commands for guided workflows.
- **Skills:** `/higgsfield:generate`, `/higgsfield:soul-id`, `/higgsfield:product-photoshoot`, `/higgsfield:marketplace-cards`
- **Auth:** `higgsfield auth login` (browser OAuth, one-time) — same credentials shared with MCP.
- **Integration:** `cli-higgsfield.sh` + `plugin-higgsfield.sh` in `.claude/hooks/install/`; both wired into `setup.sh` (step 7f for plugin, CLI tools section); `@higgsfield/cli` in `update-all.sh` NPM_GLOBALS; `higgsfield@higgsfield-ai` in `enabledPlugins`; `higgsfield-ai` marketplace in `extraKnownMarketplaces`; Bash/PowerShell permissions added; 4 Skill permissions in `settings.local.json.example`.
- **Source:** CLI: https://github.com/higgsfield-ai/cli | Skills: https://github.com/higgsfield-ai/skills (MIT)

---

## 2026-06-27 — Obsidian vault integrated as dual-layer knowledge base in repo

- **Decision:** Added `vault/` to repo root as a single Obsidian vault with two layers: `vault/wiki/` (gittracked, shared boilerplate knowledge) and `vault/private/` (gitignored, per-user sessions/projects/agents). MCPVault (`@bitbonsai/mcpvault`) registered at user scope for filesystem MCP access without requiring Obsidian app.
- **Why:** Dual-layer solves the fork dilemma: shared architectural knowledge travels with the repo (onboarding), while each user's private context stays local (privacy). Single vault = single Obsidian graph view, cross-linking between layers, one open-in-Obsidian action.
- **Mode:** B (GitHub/Repository) + C (Business/Project) hybrid — modules/, integrations/, decisions/, flows/, dependencies/ for repo knowledge; private/projects/ for user's downstream work.
- **MCP choice:** Option B (MCPVault filesystem) over Option A (REST API) — no Obsidian app dependency, no TLS bypass needed, works headless/CI, better for boilerplate new users who may not have Obsidian running.
- **Install scripts:** `sys-obsidian.sh` (app install), `tool-vault.sh` (scaffold private/ dirs + git init), `mcp-vault.sh` (register MCPVault user-scope); all wired into `setup.sh` Step 14.
- **Vault structure:** `wiki/` (index, log, hot, overview, modules/, integrations/, decisions/, flows/, dependencies/), `private/` (sessions/, projects/, agents/, hot.md), `_templates/` (module, integration, decision, flow, project), `.obsidian/snippets/vault-colors.css`.
- **Cross-project referencing:** Any downstream project can add `vault/CLAUDE.md` pattern to its own CLAUDE.md to read `hot.md` → `index.md` → domain pages without loading the whole vault.
- **Gitignore:** `vault/.gitignore` ignores `private/`, `.raw/`, `workspace.json` — shared knowledge travels, personal context stays.

## 2026-06-27 — claude-obsidian plugin integrated (Obsidian + Claude AI second brain)
- **Decision:** Added `claude-obsidian@agricidaniel-claude-obsidian` (AgriciDaniel/claude-obsidian v1.9.2) as a Claude plugin. No CLI tool, no MCP server — plugin-only install.
- **Why:** Implements Karpathy's LLM Wiki pattern — persistent, compounding knowledge base across sessions. Fills the gap between claude-mem (passive observations) and LightRAG (code/doc graph RAG) by providing a human-curated Obsidian vault with hybrid retrieval (+32pp top-1 vs baseline). Methodology modes (LYT/PARA/Zettelkasten/Generic) give structured organization no other Claude+Obsidian tool offers.
- **Skills:** `/wiki` (scaffold/route), `/wiki-ingest`, `/wiki-query`, `/wiki-lint`, `/wiki-cli`, `/wiki-retrieve` (opt-in BM25+cosine), `/wiki-mode`, `/wiki-fold` (DragonScale), `/save`, `/canvas`, `/think`.
- **Integration:** `plugin-claude-obsidian.sh`; `setup.sh` after mattpocock-skills; `claude-obsidian@agricidaniel-claude-obsidian: true` in `enabledPlugins`; `agricidaniel-claude-obsidian` in `extraKnownMarketplaces`; activation guide in `settings.local.json.example`; routing table + plugins table + 12-row skills section in `CLAUDE.md`.
- **First-run:** Run `/wiki` to scaffold vault. `bash bin/setup-retrieve.sh` for hybrid retrieval. `bash bin/setup-mode.sh` for methodology mode.
- **Optional dep:** Obsidian app for vault viewing. Transport fallback chain: Obsidian CLI → mcp-obsidian → mcpvault → filesystem.
- **Source:** https://github.com/AgriciDaniel/claude-obsidian (MIT)

## 2026-06-27 — grill-me-codex skills integrated (3 skills from chaseai-yt/grill-me-codex)
- **Decision:** Added `grill-me-codex`, `grill-with-docs-codex`, and `codex-review` as project skills at `.claude/skills/`. No new plugin or CLI install — codex-cli (`@openai/codex@latest`) already installed via `cli-codex.sh`.
- **Why:** Closes the two core AI coding failure modes: (1) building the wrong thing (`grill-me` interview), (2) a plan that sounds right but breaks (Codex adversarial review). Cross-model review (Claude + Codex) avoids echo chamber. Builds on Matt Pocock's `grill-me`/`grill-with-docs` (MIT) with Act 2 (iterative Codex review loop) added by Chase AI.
- **Integration:** 3 SKILL.md files in `.claude/skills/`; `skills-project.sh` auto-copies on fresh clones; `auth-reminders.sh` updated with `codex login` step; CLAUDE.md skills table updated.
- **Auth required:** `codex login` once (ChatGPT account fine); `codex --version` must be ≥ 0.130. Do NOT pin `-m` — ChatGPT-account auth rejects `gpt-5.x-codex` variants.
- **Safety note:** `codex exec resume` rejects `-s read-only`; skills force `-c sandbox_mode="read-only"` on all resume calls so Codex never writes files.
- **Source:** https://github.com/chaseai-yt/grill-me-codex (MIT)

## 2026-06-26 — mattpocock-skills plugin integrated for real-engineering workflows
- **Decision:** Added `mattpocock-skills@mattpocock-skills` (mattpocock/skills) as a Claude plugin via `plugin-mattpocock-skills.sh`.
- **Why:** Provides 16 composable engineering skills designed to fix core AI agent failure modes — misalignment (`/grill-with-docs`), ball-of-mud architecture (`/improve-codebase-architecture`), broken code (`/tdd`, `/diagnosing-bugs`), verbosity (`/domain-modeling` + `CONTEXT.md`). Skills are small, model-agnostic, and hackable. Install via `npx skills@latest add mattpocock/skills`.
- **Integration:** `plugin-mattpocock-skills.sh`; `setup.sh` after ponytail; `mattpocock-skills@mattpocock-skills: true` in `enabledPlugins`; `mattpocock-skills` marketplace in `extraKnownMarketplaces`; activation guide + 16 Skill permissions in `settings.local.json.example`; Plugins table + 16-row Skills section in `CLAUDE.md`.
- **First-run required:** `/setup-matt-pocock-skills` must be run once per repo to configure issue tracker (GitHub/Linear/local) and triage labels before other engineering skills work correctly.

## 2026-06-26 — Supabase CLI integrated for local dev, migrations, and type generation
- **Decision:** Added `supabase` CLI (`sys-supabase-cli.sh`) as primary interface for local Supabase dev. `supabase-mcp` remains active for in-context database queries.
- **Why:** CLI-first pattern — `db push`, `migration new`, `gen types typescript`, `functions deploy` are CLI operations. MCP better for schema introspection + running queries inside the conversation.
- **Install:** Windows: scoop → npm fallback; macOS: `brew install supabase/tap/supabase`; Linux: `npm install -g supabase`. Auth: `supabase login` (browser OAuth, one-time).
- **Integration:** `sys-supabase-cli.sh`; `setup.sh` after GitHub CLI section; `update-all.sh` section 5 (platform-aware); `auth-reminders.sh` login step; CLAUDE.md routing table, key commands, MCP Servers table note.
- **Docker note:** `supabase start` requires Docker — not auto-started by setup.sh.

## 2026-06-26 — tools/ffmpeg.js integrated for programmatic video/audio processing
- **Decision:** Created `tools/ffmpeg.js` — thin Node.js CLI wrapper around system ffmpeg using `child_process.spawnSync`. No npm dependency (fluent-ffmpeg archived May 2025; ffmpeg.wasm 10-20x slower). Follows same pattern as `tools/playwright.js`.
- **Why:** Distinct from claude-video (`/watch`) which is video *understanding*. This covers video *manipulation* — trim, transcode, thumbnail, extract-audio, probe, concat — needed for Trigger.dev automations and batch processing pipelines. User confirmed use case.
- **Integration:** `tools/ffmpeg.js` (6 commands, all JSON output); `sys-ffmpeg.sh` (auto-installs system ffmpeg via winget/brew/apt); `setup.sh` calls `sys-ffmpeg.sh` in Runtime Checks section; `/ffmpeg` skill at `.claude/skills/ffmpeg/SKILL.md`; CLAUDE.md routing table, key commands, project structure, skills table updated.
- **Commands:** `probe`, `transcode`, `trim`, `thumbnail`, `extract-audio`, `concat`

## 2026-06-26 — ponytail plugin integrated for YAGNI/minimal-code discipline
- **Decision:** Added `ponytail@ponytail` (DietrichGebert/ponytail) as a Claude plugin via `plugin-ponytail.sh`. Always-on after install — no per-session activation needed.
- **Why:** Measured -54% LOC, -22% tokens, -20% cost, -27% time vs baseline on agentic benchmarks. Enforces YAGNI + platform-native + stdlib-first discipline without dropping validation/security/a11y. Complements Caveman (output compression) at the code-generation discipline layer.
- **Integration:** `plugin-ponytail.sh`; `setup.sh` marketplace plugins; `ponytail` marketplace in `settings.json` `extraKnownMarketplaces`; `ponytail@ponytail: true` in `enabledPlugins`; `PONYTAIL_DEFAULT_MODE=full` in `.env.example`; activation guide + Skill permissions in `settings.local.json.example`; Plugins table in `CLAUDE.md`.
- **Levels:** `lite` (suggest only), `full` (default — enforce), `ultra` (strict), `off`. Set via `PONYTAIL_DEFAULT_MODE` env or `/ponytail [level]` per session.

## 2026-06-26 — graphify integrated for codebase knowledge graph
- **Decision:** Added `graphifyy[mcp]` (PyPI: graphifyy, CLI: graphify) as a uv tool install under `tool-graphify.sh`. Installs graphify with MCP support and auto-runs `graphify install` to register the skill globally.
- **Why:** AST-parses 25+ languages into a queryable knowledge graph — answers "what calls X?", "what depends on Y?" instantly. 72K stars, YC S26. Skill mode (no API key) + optional `graphify-mcp` MCP server for persistent access.
- **Integration:** `tool-graphify.sh`; `setup.sh` heavy tools section; `graphify-mcp` in `.mcp.json` + `enabledMcpjsonServers`; `GRAPHIFY_API_KEY` in `.env.example` + `settings.local.json.example` (optional); Bash/PowerShell/Skill permissions in `settings.json`/`settings.local.json.example`; routing table + plugins/skills/MCP tables in `CLAUDE.md`.
- **Usage:** Run `/graphify .` once per repo → builds `graphify-out/graph.json` → MCP server serves that graph.

## 2026-06-26 — claude-video plugin integrated for video analysis
- **Decision:** Added `watch@claude-video` (bradautomates/claude-video) as a Claude plugin via `plugin-claude-video.sh`.
- **Why:** Gives Claude the ability to watch and analyze any video (YouTube, TikTok, Vimeo, local). Downloads via yt-dlp, extracts frames via ffmpeg, pulls captions or transcribes with Whisper. Usage: `/watch <url> <question>`.
- **Integration:** `plugin-claude-video.sh`; `setup.sh` marketplace plugins; `claude-video` marketplace in `settings.json` `extraKnownMarketplaces`; `watch@claude-video: true` in `enabledPlugins`; `GROQ_API_KEY` in `.env.example`; routing + plugins + skills tables in `CLAUDE.md`.
- **System deps:** ffmpeg + yt-dlp (Windows: winget; plugin prints install instructions on first `/watch` run). API keys optional — native captions work without any key.

## 2026-06-26 — setup.sh modularized into .claude/hooks/install/ scripts
- **Decision:** Broke monolithic `setup.sh` (1148 lines) into 35 standalone scripts under `.claude/hooks/install/`. `setup.sh` now orchestrates by calling each via `_run`. Any script can be run standalone: `bash .claude/hooks/install/cli-firecrawl.sh`.
- **Why:** Agentic OS goal — install individual elements (plugin, CLI, skill, tool) selectively on new machines without running everything. Full install still works via `setup.sh`. Fresh-clone path unchanged.
- **Structure:** `lib.sh` (shared helpers: `_timeout`, `_is_windows`, `_user_home`, `_install_plugin`, `_install_skill`), `sys-*.sh` (prereqs), `plugin-*.sh` (plugins), `skill-apify-*.sh` + `skills-project.sh` (skills), `cli-*.sh` (global CLIs), `tool-*.sh` (heavy tools: autoresearch/lightrag/ollama/openspace), `auth-reminders.sh`.
- **mcp-cleanup.sh:** Added `*kie-ai-mcp-server*` and `*designlang*mcp*` orphan-kill patterns (two servers missing from previous version).

## 2026-06-23 — kie-ai CLI-first integration with MCP fallback
- **Decision:** Added `@felores/kie-cli` as primary interface for kie.ai media generation; `kie-ai` MCP becomes fallback.
- **Why:** MCP loads all 29 tool schemas into context every turn — significant token overhead. `kie-cli` costs zero context tokens; auto-switch rule in `/kie-ai` skill triggers on any MCP failure.
- **Integration:** `npm install -g @felores/kie-cli`; `/kie-ai` skill at `.claude/skills/kie-ai/SKILL.md` (installed globally); `setup.sh` step 11 installs CLI; `update-all.sh` NPM_GLOBALS includes `@felores/kie-cli`; `Bash/PowerShell(kie-cli *)` permissions added to `settings.json`.
- **API verified:** `kie-cli list_tasks --json` returns `{"success":true,"tasks":[],"count":0}` — connection confirmed.
- **Separate packages:** `@felores/kie-ai-mcp-server` (MCP, bin: `kie-ai-mcp-server`) and `@felores/kie-cli` (CLI, bin: `kie-cli`) — both installed.

## 2026-06-23 — designlang integrated for design language extraction
- **Decision:** Added `designlang` (Manavarya09/design-extract, npm `designlang`) as global CLI + Claude plugin for extracting complete design languages from any website.
- **Why:** Fills a gap between `skillui` (design system → SKILL.md tokens) and `stitch` (screen DNA). Produces 8 simultaneous output formats: DTCG tokens, Tailwind config, shadcn theme, Figma vars, CSS vars, React theme, HTML preview, WCAG scores. Plugin adds 13 slash commands (/extract /site /grade /battle /remix /pack /theme-swap /brand /pair /studio /verify /fidelity /gallery).
- **Integration:** `setup.sh` step 11 installs via `npm install -g designlang --ignore-scripts`; `update-all.sh` NPM_GLOBALS includes `"designlang"`; Claude plugin `designlang@designlang` installed; `designlang-mcp` in `.mcp.json` uses `cmd /c npx` Windows pattern; `/extract-design` skill installed globally.
- **Corporate SSL gotcha:** postinstall runs `npx playwright install chromium` → SSL cert failure on corporate proxy. `--ignore-scripts` skips it. Base CLI works without the Playwright browser.
- **Plugin marketplace:** key is `designlang` (from `.claude-plugin/marketplace.json`), NOT `design-extract` (the repo slug). Install: `claude plugin install designlang@designlang`.

## 2026-06-22 — browser-harness integrated for real Chrome CDP automation
- **Decision:** Added `browser-harness` (browser-use/browser-harness, Python uv tool) as real-Chrome CDP automation layer alongside existing Playwright CLI.
- **Why:** Complements Playwright (headless/scripted) with live-Chrome control — coordinate clicks, screenshots, JS eval, drag-drop, iframes, shadow DOM, downloads, cloud browsers. Particularly useful for sites that block headless or require authenticated sessions already in Chrome. Has 100+ domain skills (Amazon, LinkedIn, Reddit, GitHub, etc.) and 17 interaction-skill guides.
- **Integration:** `uv tool install --python 3.12 --upgrade --force browser-harness`; skill generated from CLI via `browser-harness skill > ~/.claude/skills/browser-harness/SKILL.md`; setup.sh step 11 auto-installs + auto-generates skill; CLAUDE.md routing table distinguishes CDP (browser-harness) vs headless (playwright).
- **Chrome setup required:** `chrome://inspect/#remote-debugging` → tick "Allow remote debugging"; `browser-harness --doctor` for diagnostics. Cloud mode optional (`BROWSER_USE_API_KEY`).
- **Skill is dynamic:** Content comes from `browser-harness skill` CLI output — updates with each release. setup.sh regenerates on install.

## 2026-06-22 — codeburn integrated for AI spend analytics
- **Decision:** Added `codeburn` (npm package, getagentseal/codeburn) as a global CLI tool for tracking AI token cost and spend across 31 AI tools including Claude Code.
- **Why:** Provides per-task, per-model, per-tool, per-project cost breakdowns by reading session files already on disk — no data leaves the machine. Fills the gap between Caveman's session token stats (output-focused) and full cross-session budget tracking.
- **Integration points:** `setup.sh` step 11 installs via `npm install -g codeburn`; `update-all.sh` NPM_GLOBALS includes `"codeburn"`; `/codeburn` skill at `.claude/skills/codeburn/SKILL.md` installed globally; routing table + Skills section in `CLAUDE.md` updated.
- **No MCP server** — codeburn is CLI-only; reads `~/.claude/projects/**/*.jsonl` directly. Run `codeburn` for TUI dashboard, `codeburn status` for one-liner, `codeburn optimize` for waste scan.

## 2026-05-14 — update-all.sh + self-healing lightrag install
- **Decision:** Created `.claude/hooks/update-all.sh` as a unified updater + `/update-all` skill. Also hardened `setup.sh` step 14 with self-healing logic after `uv sync`.
- **Why:** OneDrive repeatedly deletes transitive deps from `.venv` mid-install. Needed both (a) a way to keep all tools current and (b) setup that never requires manual troubleshooting.
- **Auto-registration design:** npm globals read from `NPM_GLOBALS` array in `update-all.sh` (add entries when setup.sh adds a new global); uv tools covered by `uv tool upgrade --all` (zero config); Python venvs auto-detected by scanning `tools/*/pyproject.toml`.
- **Self-healing pattern in setup.sh:** `uv sync` → `uv pip check` → if broken: remove dist-info dirs missing METADATA → `uv sync` again → force-install 8 known transitive deps → final import verification.
- **Not auto-updated:** Claude plugins (reinstall via CLI), MCP servers (restart Claude Code for `@latest` refresh), `lightrag-hku` (governed by `uv.lock` pin, use `check_update.py`).

## 2026-05-14 — lightrag-hku pin constraint (OneDrive upgrade corruption)
- **Decision:** `lightrag-hku` pinned to `>=1.4.15,<2.0.0` in `tools/lightrag/pyproject.toml`. Do not upgrade to a new minor without manual verification.
- **Why:** OneDrive path causes pip/uv upgrades to delete source `.py` files mid-install while leaving `.pyc` files in `__pycache__`. Upgrading to 1.4.16 broke all imports (`ImportError: cannot import name 'LightRAG'`). Fix: manually delete broken `lightrag_hku-*.dist-info` dirs + `lightrag/` dir, then reinstall pinned version.
- **How to apply:** To upgrade, do it on a non-OneDrive path (e.g., WSL or a local non-synced dir), verify imports work, then widen the pin.

## 2026-05-13 — setup.sh is the idempotent boot loader for the agentic OS layer
- **Decision:** `setup.sh` is not a one-time installer — it is the canonical boot for the entire project. Every new capability added to the framework must be wired into `setup.sh` so re-running it brings any environment (fresh clone, new machine, updated repo) fully current.
- **Why:** The framework is designed to be reused as a standard agentic OS base. Idempotency is required — all steps must be safe to re-run (e.g., `provision.py` skips if already provisioned, `uv sync` is a no-op if deps current, plugin installs check before installing).
- **How to apply:** When adding any new tool, MCP server, CLI, skill, or backend integration — always add a corresponding step to `setup.sh`. If the step can't be made idempotent, add a guard check. Never leave a capability that requires manual setup undocumented in setup.sh.

## 2026-05-12 — LightRAG Plus (Phase 2) built and merged
- **Decision:** Implemented full LightRAG Plus stack — renamed from "enhanced" to "plus" throughout.
- **Why:** "Enhanced" is generic; "Plus" is distinctive. User explicitly requested the rename.
- **Architecture (decisions from prior design sessions):**
  - Multimodal: Hybrid — simple mode (text → graph only), advanced mode (text → graph + raw media → remote backends)
  - Query routing: Mode-based (`mode="graph"` vs `mode="hybrid"`)
  - Sync: Synchronous insert, log-warning-and-continue on remote failure
  - LightRAG core untouched — `EmbeddingFunc` wrapper intercepts embeddings post-generation
- **Files built:** `src/lightrag_plus.py`, `src/embedders/{openai,gemini}_embedder.py`, `src/adapters/{supabase,pinecone}_adapter.py`, `src/ingestors/{image,audio,video}_ingestor.py`, `schema/supabase_schema.sql`, `setup_backends.py`
- **New deps:** `google-genai>=1.0.0`, `supabase>=2.0.0`, `pinecone>=3.0.0`, `Pillow>=10.0.0`
- **Video note:** `VideoIngestor` requires `opencv-python-headless` (optional — not in pyproject.toml; graceful no-op if missing)
- **Validate:** `uv run python setup_backends.py` — checks Supabase/Pinecone connections before use

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
