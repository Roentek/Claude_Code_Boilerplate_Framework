# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

## 2026-05-01 (session 6) — CLI permissions audit & completion
- **Audited CLI tool permissions** across `settings.json` and `settings.local.json.example`
- **Consolidated all CLI permissions in main `settings.json`** (version-controlled, available to all users):
  - Fixed `Bash(codex --version)` → `Bash(codex *)` (general pattern)
  - Fixed `bash(gemini --version)` (lowercase) → `Bash(gemini *)` (correct casing + general pattern)
  - Added all missing PowerShell variants for: skillui, playwright, firecrawl, nlm, codex, gemini
- **Removed CLI permissions from `settings.local.json.example`** — they're project-level config, not machine-specific
- **Final permission coverage in settings.json:**
  - skillui: Bash + PowerShell (npx variants)
  - playwright: Bash + PowerShell (node tools/playwright.js + npx variants)
  - firecrawl: Bash + PowerShell (firecrawl + npx firecrawl-cli variants)
  - nlm: Bash + PowerShell (nlm + uvx variants)
  - codex: Bash + PowerShell (general pattern)
  - gemini: Bash + PowerShell (general pattern)
- All 6 CLI tools installed by `setup.sh` now have complete cross-platform permission coverage in the main project settings file

## 2026-05-01 (session 5) — NotebookLM MCP CLI integration complete
- **Tool integrated:** `notebooklm-mcp-cli` — Python package providing both `nlm` CLI and `notebooklm-mcp` MCP server
- **Files created:** `.claude/skills/notebooklm/SKILL.md` (usage guide with CLI-first pattern)
- **Files updated:**
  - `setup.sh` — added step 11 installation (`uv tool install notebooklm-mcp-cli`), authentication reminder (`nlm login`)
  - `settings.json` — added `nlm` CLI permissions (Bash/PowerShell), enabled `notebooklm-mcp` in `enabledMcpjsonServers`
  - `.mcp.json` — already present (line 181-184)
  - `CLAUDE.md` — routing table, Skills section, MCP Servers section, First-Time Setup, uvx requirement note
  - `README.md` — setup.sh steps 11-12, Prerequisites table, Project Skills table, MCP Servers table, uvx verification step
  - `memory-decisions.md` — decision logged with rationale
- **Architecture pattern:** CLI-first (like Playwright and Firecrawl) — `nlm` CLI is primary, `notebooklm-mcp` MCP server is backup for interactive flows only
- **Authentication:** Cookie-based via `nlm login` (auto mode launches browser, extracts cookies, persists 2-4 weeks)
- **Use cases:** Research workflows (create notebooks, add sources from URLs/Drive), AI queries, content generation (podcasts, videos, briefings, flashcards, infographics, slides), sharing
- **Source:** https://github.com/jacob-bd/notebooklm-mcp-cli

## 2026-04-30 (session 4) — three-brain skill integration & CLI tool installations
- **codex-cli and gemini-cli added to setup.sh** — step 11 now installs 4 global CLI tools: skillui, firecrawl-cli, codex-cli (`@openai/codex`), gemini-cli (`@google/gemini-cli`)
- **three-brain skill documented** — added to CLAUDE.md Skills table and README.md Project Skills section with full description of auto-routing behavior (Codex for review/rescue, Gemini for multimodal/long-context)
- **Startup self-check results** — codex-cli v0.124.0 installed (slightly below expected 0.125+, but functional); gemini-cli not found (user corrected package name from `@google/generative-ai-cli` to `@google/gemini-cli`)
- **Documentation updates** — CLAUDE.md First-Time Setup section updated to mention CLI tool installations; README.md setup.sh step 11 expanded to list all 4 CLI tools with use cases
- **Decision logged** — memory-decisions.md entry created documenting the CLI installation additions with rationale and implications

## 2026-04-30 (session 3) — CLAUDE.md quality audit & improvements
- **claude-md-improver skill invoked** — full quality assessment of project CLAUDE.md
- **Quality score: 97/100 (Grade A)** — excellent baseline with minor gaps identified
- **Two improvements applied:**
  1. Added "First-Time Setup" section consolidating scattered setup commands
  2. Clarified `tools/` directory purpose (Python/Node scripts, includes playwright.js)
- **Assessment strengths:** routing table, WAT philosophy, non-obvious gotchas, conciseness, actionability
- **Minor gaps filled:** npm install was missing, tools/ description was ambiguous for boilerplate users

## 2026-04-30 (session 2) — Memory cleanup & ui-ux-pro-max relocation
- **ui-ux-pro-max-instructions.md moved** — `.claude/rules/` → `.claude/docs/` (reference-only, not auto-loaded). Duplicate removed from rules.
- **Path updates** — `README.md`, `frontend-instructions.md`, `read-guard.py` updated to reflect new location.
- **memory-distiller run** — verified no compression needed (all sessions from last 10 days).
- **CLAUDE.md maintenance note** — added monthly `/compact-memory` recommendation.
- **5 entities synced to memory MCP** — WAT Framework, Trigger.dev Integration, CLI-First Pattern, Frontend Toolchain, Two-Tier Memory System.

## 2026-04-30 — Context & memory optimization
- **CLAUDE.md refactor** — cut from 283 → ~155 lines (45%). Removed redundant sections already in auto-loaded rule files.
- **context7 MCP** — added to `.mcp.json` + `enabledMcpjsonServers` for on-demand live SDK docs.
- **trigger-api-reference.md moved** — `.claude/rules/` → `.claude/docs/` (stops auto-loading). References in `trigger-workflow-builder.md` updated.
- **memory-distiller agent** — `.claude/agents/memory-distiller.md` — compresses sessions >30 days old into archive block.
- **compact-memory skill** — `.claude/skills/compact-memory/SKILL.md` — full hygiene cycle: compress, prune, sync to memory MCP.
- **memory-drafter.py** — Stop hook helper auto-drafts memory entries from session transcript signals.
- **read-guard.py** — PreToolUse hook warns when large files are read without offset+limit.
- **stop.sh** — enhanced to call memory-drafter.py and merge output into session-end message.
- **settings.json** — PreToolUse hook wired to read-guard.py for all Read calls.

## 2026-04-29 (session 3)
- **Clarified kie-ai vs Higgsfield routing** in `CLAUDE.md`: added two explicit rows to the "What Are You Building?" routing table; expanded MCP Servers table with bold decisional descriptions.

## 2026-04-29 (session 2)
- **Integrated Playwright CLI** as direct Bash tool for browser automation.
- Created `package.json`, `tools/playwright.js` (screenshot/scrape/pdf/links), `.claude/skills/playwright/SKILL.md`, `workflows/browser-automation.md`.
- Added `setup.sh` step 9: `npm install && npx playwright install chromium`.
- Added Bash permissions to `settings.json`: `node tools/playwright.js:*`, `npx playwright:*`.

## 2026-04-29
- Diagnosed Alpaca MCP 401: `${VAR}` in `.mcp.json` reads from OS process env, **not** `.env`. Fix: `setx ALPACA_API_KEY "..."` then restart Claude Code.
- Built PostToolUse autosync hook — `.claude/hooks/autosync-docs.sh` + `autosync-docs.py`: fires after Write/Edit on tracked paths, injects context to update CLAUDE.md/README.md.

---

## Archive

- **2026-04-28** — webgpu-threejs-tsl skill integrated from dgreenheck/webgpu-claude-skill (855 stars, 16 files). `setup.sh` step 8 switched to `cp -r` to preserve skill subdirectories with supporting docs/examples.
- **2026-04-28 (s2)** — `/design-md` skill added from VoltAgent/awesome-design-md: 73 brand DESIGN.md files via `npx getdesign@latest add <brand>`. Frontend routing: brand-named → `/design-md` first, unknown sites → `/skillui`.
- **2026-04-28 (s3)** — 21st-dev-magic MCP server name corrected (`21st-dev-mcp` → `21st-dev-magic`); tool names updated in CLAUDE.md/README.md.
- **2026-04-28 (s4)** — GitHub plugin fix: correct env var is `GITHUB_PERSONAL_ACCESS_TOKEN` (not `GITHUB_TOKEN`). Plugin: `github@claude-plugins-official`.
- **2026-04-27** — `settings.local.json.example` created: credential template with `__activation_guide`, cleared env block, and pre-built `permissions.allow` for all MCP servers.
- **2026-04-27 (s2)** — Diagnosed skill loading failure: Claude Code requires `~/.claude/skills/<name>/SKILL.md` subdirectory format — flat `.md` files are silently ignored. `setup.sh` step 8 now auto-installs skills. Impeccable plugin added.
- **2026-04-22** — PDFs in `.claude/docs/` converted to `.md` for direct context loading. `pdftotext` (bundled with Git for Windows) used for 23MB file.
- **2026-04-22 (s2)** — `pre-commit.sh` git hook created: auto-updates CLAUDE.md/README.md before commits touching tracked paths. `stop.sh` enhanced with doc-sync check.
- **2026-04-22 (s3)** — README.md updated to reflect pre-commit hook, expanded setup steps (5→9), hooks table corrected.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Path Updates\n- âœ“ **README.md** (3 locations) â€” updated paths, added \"(reference-only, not auto-loaded)\" note\n- âœ“ **frontend-instructions.md** (2 locations) â€” fixed relative paths to `../docs/ui-ux-pro-max-instructions.md`\n- âœ“ **read-guard.py** â€” removed ui-ux-pro-max from large-file warnings (no longer auto-loaded)\n\n### 3.
- Documentation\n- âœ“ **CLAUDE.md** â€” added monthly `/compact-memory` maintenance note\n- âœ“ **memory-sessions.md** â€” recorded this session's work\n- âœ“ **memory-decisions.md** â€” documented ui-ux-pro-max move with rationale\n\n## Token Savings\n- **~1500 tokens saved per non-frontend session** by moving ui-ux-pro-max-instructions.md out of auto-loaded rules\n- Frontend work still has full access via `frontend-instructions.md` â†’ loads on demand\n\nAll docs are now in sync and memory is optimized."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- First-Time Setup Section Added**\n- Consolidated 5 scattered setup steps into one copy-paste block\n- Includes: npm install, setup.sh, credentials config, .env setup, restart reminder\n- Added verification command to check if setup already ran\n\n**2.
- tools/ Directory Clarified**\n- Updated description from \"Python scripts\" to \"Deterministic execution scripts (Python/Node)\"\n- Added `playwright.js` example to show what's actually there\n- Signals flexibility for future per-project scripts\n\n### Files Updated\n- âœ… **CLAUDE.md** - both improvements applied\n- âœ… **memory-decisions.md** - decision documented with rationale\n- âœ… **memory-sessions.md** - session work recorded\n\nAll documentation is now in sync.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-01 (auto-drafted — review before next session)
- Here's what was completed:\n\n---\n\n## âœ… Three-Brain CLI Integration Complete\n\n### Files Updated\n\n| File | Changes |\n|------|---------|\n| **setup.sh** | Added codex-cli (`@openai/codex`) and gemini-cli (`@google/gemini-cli`) to step 11 global CLI installations |\n| **CLAUDE.md** | Updated First-Time Setup section; added `/three-brain` to Skills table |\n| **README.md** | Updated setup.sh step 11 description; added `/three-brain` to Project Skills table with full description |\n| **memory-decisions.md** | Logged decision with rationale and implications |\n| **memory-sessions.md** | Recorded session work |\n\n### What Gets Installed\n\nOn fresh clones, `setup.sh` now installs **4 global CLI tools**:\n\n1.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-01 (auto-drafted — review before next session)
- Here's the complete summary:\n\n---\n\n## âœ… API Keys Added to All Credential Files\n\n### Files Updated\n\n| File | Changes |\n|------|---------|\n| **`.env.example`** | Added CLI tools section header + `OPENAI_API_KEY` and `GEMINI_API_KEY` with usage docs |\n| **`.env`** | Added same CLI tools section + both keys (empty placeholders) |\n| **`settings.local.json.example`** | Added `__note_cli_tools` activation guide entry + `OPENAI_API_KEY` to env block |\n| **`settings.local.json`** | Added `OPENAI_API_KEY=\"\"` to env block (GEMINI_API_KEY already present) |\n| **`memory-decisions.md`** | Updated decision entry to document credential file changes |\n\n---\n\n## Clear Separation: CLI vs MCP\n\n### In `.env` and `.env.example`\n\n```env\n# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€\n# CLI TOOLS (local execution, not MCP)\n# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€\n# OpenAI API Key â€” platform.openai.com â†’ API Keys â†’ Create new secret key\n# Used by: codex-cli (three-brain skill review/rescue routes, codex plugin)\nOPENAI_API_KEY=\n\n# Gemini API Key â€” aistudio.google.com/apikey â†’ Create API key in new project\n# Used by: gemini-cli (three-brain skill multimodal/long-context routes), cc-gemini-plugin\nGEMINI_API_KEY=\n\n# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€\n# MCP SERVER CREDENTIALS\n# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€\n```\n\n### In `settings.local.json.example` `__activation_guide`\n\n```json\n\"__note_cli_tools\": \"The keys below are for global CLI tools installed by setup.sh (codex-cli, gemini-cli).


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-01 (auto-drafted — review before next session)
- Here's what was implemented:\n\n---\n\n## âœ… Integration Complete\n\n### What Was Added\n\n**CLI Tool** â€” `notebooklm-mcp-cli` (Python package)\n- **Primary interface:** `nlm` CLI command\n- **Backup:** `notebooklm-mcp` MCP server (35 tools)\n- **Pattern:** CLI-first (matches Playwright and Firecrawl)\n\n### Files Created\n\n| File | Purpose |\n|------|---------|\n| `.claude/skills/notebooklm/SKILL.md` | Complete usage guide â€” CLI commands, MCP tools, authentication, workflows, decision matrix |\n\n### Files Updated\n\n| File | Changes |\n|------|---------|\n| `setup.sh` | Step 11: `uv tool install notebooklm-mcp-cli`; Step 12: authentication reminder (`nlm login`) |\n| `settings.json` | Added CLI permissions (`Bash(nlm:*)`, `PowerShell(nlm *)`); enabled `notebooklm-mcp` in `enabledMcpjsonServers` |\n| `.mcp.json` | Already present (line 181-184) â€” uses `uvx --from notebooklm-mcp-cli notebooklm-mcp` |\n| `CLAUDE.md` | Routing table, Skills section, MCP Servers section, First-Time Setup, uvx requirement note |\n| `README.md` | setup.sh steps 11-12, Prerequisites table, Project Skills table, MCP Servers table, uvx verification |\n| `memory-decisions.md` | Decision logged with rationale and implications |\n| `memory-sessions.md` | Session work recorded |\n\n### How to Use\n\n**On fresh clone:**\n```bash\nbash .claude/hooks/setup.sh  # Installs notebooklm-mcp-cli via uv\nnlm login                     # Authenticate (launches browser, extracts cookies)\n```\n\n**CLI commands** (primary):\n```bash\nnlm notebook list\nnlm notebook create \"Research Project\"\nnlm source add <notebook> --url \"https://...\"\nnlm audio create <notebook> --confirm\nnlm download audio <notebook> <artifact-id>\n```\n\n**MCP tools** (backup only) â€” for multi-step interactive flows\n\n### Architecture\n\nFollows the established **CLI-first pattern**:\n- Direct CLI execution via Bash = token-free\n- MCP server = backup for interactive flows only\n- Minimizes context window consumption while preserving full functionality\n\n### Authentication\n\n- **Method:** Cookie-based via `nlm login`\n- **Duration:** 2-4 weeks (auto-refreshes)\n- **Modes:** Auto (launches browser) or manual (import file)\n- **Profiles:** Supports multiple Google accounts\n\n### Source\n\nhttps://github.com/jacob-bd/notebooklm-mcp-cli\n\n---\n\nAll documentation is updated and the skill is ready to use.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-01 (auto-drafted — review before next session)
- {"session_id":"e89d0044-abb6-4cb0-a6ca-aeb85fe5bee1","transcript_path":"C:\\Users\\mdmor\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\e89d0044-abb6-4cb0-a6ca-aeb85fe5bee1.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"acceptEdits","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"## âœ… CLI Permissions Audit Complete\n\nAll CLI tool permissions are now properly configured in both files:\n\n### Fixed in `settings.json`:\n- âœ… **codex** - changed `Bash(codex --version)` â†’ `Bash(codex *)` (general pattern)\n- âœ… **gemini** - changed `bash(gemini --version)` â†’ `Bash(gemini *)` (fixed casing + general pattern)\n- âœ… Added missing PowerShell permissions for: skillui, playwright, firecrawl\n\n### Added to `settings.local.json.example`:\nComplete CLI permission block (20 permissions total) for all 6 CLI tools:\n\n| Tool | Bash Patterns | PowerShell Patterns |\n|------|---------------|-------------------|\n| **skillui** | `skillui *`, `npx skillui *` | `skillui *`, `npx skillui *` |\n| **playwright** | `node tools/playwright.js:*`, `npx playwright:*` | `node tools/playwright.js *`, `npx playwright *` |\n| **firecrawl** | `firecrawl:*`, `npx firecrawl-cli:*` | `firecrawl *`, `npx firecrawl-cli *` |\n| **nlm** | `nlm:*`, `uvx --from notebooklm-mcp-cli nlm:*` | `nlm *`, `uvx --from notebooklm-mcp-cli nlm *` |\n| **codex** | `codex *` | `codex *` |\n| **gemini** | `gemini *` | `gemini *` |\n\nAll CLI tools installed by `setup.sh` now have complete cross-platform permission coverage in both the project settings and the example template file."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-05-01 (auto-drafted — review before next session)
- {"session_id":"11cc1cad-5abf-4678-bf70-a1d30c1f19d7","transcript_path":"C:\\Users\\mdmor\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\11cc1cad-5abf-4678-bf70-a1d30c1f19d7.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"default","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"---\n\n## âœ… **Audit Complete**\n\n### Summary\n\n**setup.sh is in excellent shape.** All critical installations are properly integrated:\n\nâœ… **5 marketplace plugins** â€” all installed and enabled  \nâœ… **20 MCP servers** â€” all documented with runtime requirements  \nâœ… **5 global CLI tools** â€” all installed with full permissions  \nâœ… **10 project skills** â€” auto-installed via `cp -r` pattern  \nâœ… **npm deps + Playwright** â€” both handled  \nâœ… **Git hooks** â€” safe pre-commit wrapper installed  \nâœ… **Authentication** â€” comprehensive reminders for all interactive auth flows  \n\n### Fixed Issues\n\nâœ… **MCP server count** â€” updated from \"17\" to \"18\" to include monet-mcp and stitch in the list\n\n---\n\n## Recommendations (Optional Improvements)\n\n### 1.
