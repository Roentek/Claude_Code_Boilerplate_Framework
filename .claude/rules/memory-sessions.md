# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-03 (session 10) — AutoResearch setup automation & upstream autosync hook
- **Enhanced setup.sh step 13** — now automatically runs `verify_setup.py` after `uv sync` completes, showing immediate [OK]/[FAIL] status for all 7 Python dependencies (PyTorch, NumPy, Pandas, Matplotlib, PyArrow, Requests, TikToken)
- **Created autosync hook** — `.claude/hooks/autoresearch-sync.sh` automatically syncs `tools/autoresearch/` with upstream karpathy/autoresearch every session via Stop hook
- **Hook behavior:**
  - Runs silently if no changes exist
  - Fetches from upstream and pulls updates if available
  - Skips if local uncommitted changes exist (shows warning message)
  - Initializes as git repo with upstream remote if not already initialized
- **File cleanup:**
  - Moved `SETUP_NOTES.md` from nested `tools/autoresearch/tools/` to `tools/autoresearch/` root
  - Removed duplicate `verify_setup.py` from nested tools/ subdirectory
  - Removed empty `tools/autoresearch/tools/` directory
- **Files updated:**
  - `setup.sh` — integrated verify_setup.py execution after dependency installation (shows full verification output)
  - `stop.sh` — added autoresearch-sync.sh call before memory-drafter
  - `memory-decisions.md` — logged setup automation & autosync decision
  - `memory-sessions.md` — this entry
- **Result:** First-time setup now provides automatic verification feedback; tools/autoresearch stays current with upstream improvements without manual intervention

## 2026-05-03 (session 9) — AutoResearch integration complete + relocated to tools/
- **Integrated:** karpathy/autoresearch (33K+ stars) — autonomous ML research framework for overnight GPT training experiments
- **Files created:**
  - `tools/autoresearch/` directory — copied all files from upstream repo (prepare.py, train.py, program.md, pyproject.toml, uv.lock, analysis.ipynb, .gitignore, .python-version)
  - `tools/autoresearch/README.md` — comprehensive documentation: what it does, quick start, file structure, platform support, tuning for smaller compute
  - `.claude/skills/autoresearch/SKILL.md` — complete skill with setup workflow, autonomous loop steps, commands, platform support, usage examples
- **Files updated:**
  - `setup.sh` — added step 13 (autoresearch dependencies via `uv sync` in tools/autoresearch/), renumbered pre-commit hook to step 14, summary to step 15
  - `settings.json` — added `Bash(uv *)` and `PowerShell(uv *)` permissions for uv package manager
  - `CLAUDE.md` — added to routing table ("Autonomous ML research (overnight experiments)"), Key Commands section (cd tools/autoresearch), First-Time Setup, Skills section (/autoresearch entry), Project Structure (tools/autoresearch/ under tools/ section)
  - `README.md` — updated setup.sh step 13 description, added tools/autoresearch/ to Project Structure under tools/ with full file listing, added /autoresearch to Project Skills table with complete description
  - `memory-decisions.md` — logged decision with full rationale and implications
  - `memory-sessions.md` — this entry
- **Location rationale:** Moved to tools/ instead of project root since autoresearch is a reusable utility for any project created in this framework
- **How it works:** Agent modifies `train.py` (GPT model, optimizer, training loop), runs 5-min experiments, evaluates `val_bpb` (lower = better), keeps improvements, discards failures, repeats indefinitely (~12 exp/hour, ~100 overnight)
- **Requirements:** Single NVIDIA GPU (H100 tested), Python 3.10+, `uv` package manager (auto-installed by setup.sh step 5)
- **Platform support:** Community forks for MacOS, Windows, AMD documented in tools/autoresearch/README.md
- **Source:** https://github.com/karpathy/autoresearch

## 2026-05-03 (session 8) — CLI-Anything installation repaired
- **Issue:** Plugin was configured in `settings.json` but never actually installed — marketplace repo was never cloned, plugin was never installed to cache
- **Root cause:** Adding entries to `settings.json` doesn't trigger automatic marketplace cloning or plugin installation — those must happen separately
- **Files repaired:**
  - Cloned marketplace repo → `~/.claude/plugins/marketplaces/cli-anything/` (1,359 files)
  - Added marketplace entry → `~/.claude/plugins/known_marketplaces.json`
  - Installed plugin → `~/.claude/plugins/cache/cli-anything/cli-anything/unknown/`
  - Updated plugin registry → `~/.claude/plugins/installed_plugins.json` (added cli-anything@cli-anything entry)
- **Verification:** All 5 commands confirmed available (cli-anything, list, refine, test, validate)
- **Git commit:** bc03f9bac44a665ddf3a140f3589114e2c813f78
- **Status:** ✅ Installation complete — restart Claude Code to activate

## 2026-05-02 (session 7) — CLI-Anything plugin integration
- **Plugin integrated:** `cli-anything@cli-anything` from HKUDS/CLI-Anything marketplace — generates AI-native CLIs for existing software (GIMP, Blender, LibreOffice, Audacity, etc.)
- **Files updated:**
  - `settings.json` — added `cli-anything` to `extraKnownMarketplaces` and `enabledPlugins`
  - `setup.sh` — added CLI-Anything to step 7 marketplace plugin installation (both auto-install and manual fallback sections)
  - `CLAUDE.md` — added "AI-native CLI for existing software" row to routing table, added cli-anything entry to Plugins section, updated First-Time Setup comment to list cli-anything
  - `README.md` — added cli-anything to marketplace table, installation instructions, Enabled Plugins table, setup.sh step 7 description, intro section
  - `memory-decisions.md` — decision logged with rationale and implications
  - `memory-sessions.md` — this session entry
- **Plugin capabilities:** 5 slash commands — `/cli-anything` (build CLI harness), `/cli-anything:refine` (expand coverage), `/cli-anything:test` (run test suite), `/cli-anything:validate` (standards validation), `/cli-anything:list` (list available tools)
- **Coverage:** 50+ supported applications, 2,280+ passing tests
- **Use cases:** Transforms professional software into agent-controllable CLIs through automated source code analysis — enables AI agents to control applications via structured commands instead of fragile GUI automation
- **Source:** https://github.com/HKUDS/CLI-Anything (33,235 stars)

---

## Archive

**May 2026:**
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


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-03 (auto-drafted — review before next session)
- **Scripts section** â€” Added `memory-drafter.py` to `.claude/scripts/` in Project Structure\n3.
- **Hooks section** â€” Added `autoresearch-sync.sh` and updated hook descriptions with new behaviors\n4.
- **Skills list** â€” Added `/compact-memory`, `/notebooklm`, and `/three-brain` to Project Structure\n5.
