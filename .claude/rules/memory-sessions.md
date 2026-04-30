# Session Log

Summary of substantive work completed each session — what was built, what was learned, what changed. Add an entry at the end of any session where meaningful work was done.

---

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

## 2026-04-28 (session 4)
- **Cleaned up GitHub plugin configuration** — removed duplicate `GITHUB_TOKEN` from `settings.local.json`; confirmed `GITHUB_PERSONAL_ACCESS_TOKEN` is the env var the `github@claude-plugins-official` plugin actually requires.
- Added GitHub read-only permissions (`mcp__plugin_github_github__*`) to `settings.local.json` allow list.
- Updated `settings.local.json.example`: added `github@claude-plugins-official` entry in `__activation_guide`, `GITHUB_PERSONAL_ACCESS_TOKEN` in env block, and GitHub read permissions in `permissions.allow`.
- Updated `CLAUDE.md`: added GitHub row to plugins table; removed `github` from the Disabled list.
- Updated `README.md`: moved GitHub from Disabled to Enabled plugins table; corrected env var count to 18.
- Updated `memory-decisions.md` with decision rationale for correct env var name.

## 2026-04-28 (session 3)
- **Updated 21st-dev-magic MCP docs** in `CLAUDE.md` and `README.md`: corrected server name from `21st-dev-mcp` → `21st-dev-magic` (matching `.mcp.json`); updated tool names to current: `21st_magic_component_inspiration`, `21st_magic_component_builder`, `21st_magic_component_refiner`, `logo_search`; bumped server count from 16 → 17; added routing table row in `CLAUDE.md` for UI component inspiration / SVG logos.

## 2026-04-28 (session 2)
- **Added `/design-md` skill** from [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) — 73 brand DESIGN.md files (Linear, Stripe, Vercel, Notion, Figma, Spotify, Tesla, Supabase, BMW, Coinbase, etc.) fetched on demand via `npx getdesign@latest add <brand>`.
- Created `.claude/skills/design-md/SKILL.md` and installed to `~/.claude/skills/design-md/` for immediate activation.
- Updated `frontend-instructions.md` — added `/design-md` as first step for brand-named references, clarifying `/skillui` is for sites not in the 73-brand collection.
- Updated `CLAUDE.md` project skills table with `/design-md` row linking to the GitHub repo.
- Updated `README.md` project structure tree and project skills table with the new skill.
- Updated `memory-decisions.md` with decision rationale and implications.

## 2026-04-28
- **Integrated webgpu-threejs-tsl skill** from [dgreenheck/webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill) — 855-star community skill for WebGPU + Three.js TSL development.
- Downloaded all 16 files into `.claude/skills/webgpu-threejs-tsl/` (SKILL.md, REFERENCE.md, 7 docs, 5 examples, 2 templates) and copied to `~/.claude/skills/webgpu-threejs-tsl/` for immediate activation.
- Updated `setup.sh` step 8 to copy entire skill directory (not just SKILL.md) — ensures supporting docs/examples/templates survive fresh clones.
- Updated `CLAUDE.md`: added WebGPU/Three.js row to routing table, added `/webgpu-threejs-tsl` to project skills table.
- Updated `README.md`: added skill to project skills table, expanded project structure tree to show skill subdirectories.

## 2026-04-29 (session 3)
- **Clarified kie-ai vs Higgsfield routing** in `CLAUDE.md`: added two explicit rows to the "What Are You Building?" routing table distinguishing the two; expanded MCP Servers table entries with full tool lists and bold decisional descriptions ("Multi-provider AI media aggregator" vs "Single-platform cinematic AI") so the correct tool is unambiguous based on the user's inquiry.

## 2026-04-29 (session 2)
- **Integrated Playwright CLI** as a direct Bash tool replacing any future MCP server approach for browser automation.
- Created `package.json` with `playwright` devDependency; created `tools/playwright.js` (ESM, Node 18+) with four commands: `screenshot`, `scrape`, `pdf`, `links` — all output JSON to stdout.
- Created `.claude/skills/playwright/SKILL.md` — immediately visible as `/playwright` skill; documents commands, flags, error table, and tool-selection decision matrix.
- Created `workflows/browser-automation.md` — WAT SOP covering tool selection, install verification, error handling, and output storage rules.
- Added `setup.sh` step 9: runs `npm install && npx playwright install chromium` on fresh clones.
- Added Bash permissions to `settings.json`: `node tools/playwright.js:*`, `npx playwright:*`, `npm run playwright:*`.
- Updated CLAUDE.md routing table, README project structure tree, project skills table, setup steps list, and scripts table.
- Updated `memory-decisions.md` with rationale: direct Bash execution avoids MCP protocol token overhead; Apify MCP still handles large-scale scraping (1000+ pages).

## 2026-04-29
- Diagnosed Alpaca MCP 401: `${VAR}` substitution in `.mcp.json` reads from OS process env, not `.env` or `settings.local.json`. Fix: `setx ALPACA_API_KEY "..."` + `setx ALPACA_SECRET_KEY "..."` in terminal, then restart Claude Code.
- Built `PostToolUse` autosync hook — `.claude/hooks/autosync-docs.sh` + `autosync-docs.py`: fires after Write/Edit on tracked paths, injects `additionalContext` telling Claude to update CLAUDE.md/README.md immediately. CLAUDE.md/README.md excluded to prevent loops.
- Updated CLAUDE.md and README.md: added autosync hook to Hooks tables; added hook files to README project structure; added missing `stitch` MCP entry to README MCP table.

## 2026-04-22
- Converted `.claude/docs/Claude_Code_Beginners_Guide.pdf` → `Claude_Code_Beginners_Guide.md`
- Converted `.claude/docs/The_Shift_to_Agentic_AI_Workflows.pdf` → `The_Shift_to_Agentic_AI_Workflows.md`
- Converted `Claude_Code_Context_Management_Hacks.pdf` → `Claude_Code_Context_Management_Hacks.md` using `pdftotext` (bundled with Git for Windows at `mingw64/bin/pdftotext.exe`)
- Updated `README.md` (Reference Docs section + project structure) and `CLAUDE.md` (project structure) to reference `.md` files
- Scrubbed `CLAUDE.md` and `README.md` for accuracy: fixed stale PDF reference in `.claude/docs/` comment, documented root `docs/` folder, added `settings.local.json` to README structure and configuration section, added `karpathy-guidelines.md` to README rules list and project structure tree

## 2026-04-22 (session 3)
- Updated `README.md` to reflect hooks added in session 2: added `pre-commit.sh` to project structure tree; added pre-commit row to hooks table with full behavior description; expanded `stop.sh` logic section to include doc-sync check; updated Quick Start setup steps from 5 → 9 to match actual `setup.sh`; added pre-commit hook to "What's tested" table
- `CLAUDE.md` was already accurate from session 2

## 2026-04-22 (session 2)
- Created `.claude/hooks/pre-commit.sh` — git pre-commit hook that detects staged changes to tracked paths (`.claude/rules/`, `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `.claude/scripts/`, `.mcp.json`, `workflows/`, `tools/`) and auto-updates CLAUDE.md and README.md via `claude --print` before the commit lands
- Installed `.git/hooks/pre-commit` wrapper (thin caller so `.claude/hooks/pre-commit.sh` stays version-controlled and the wrapper never needs updating)
- Enhanced `.claude/hooks/stop.sh` — added doc-sync check: at session end, detects modified tracked-path files (unstaged + staged) and surfaces a system message count/prompt if docs may need updating
- Updated `.claude/scripts/setup.sh` — added step 8 to install the pre-commit wrapper on fresh clones; added `chmod +x` for `pre-commit.sh` on non-Windows
- Updated `CLAUDE.md` hooks table to document both the `Stop` and `pre-commit` hooks with tracked paths listed

## 2026-04-27
- Created `.claude/settings.local.json.example` — checked-in credential template for all 16 MCP servers. Contains `__activation_guide` (per-server notes on where to get each key and which need no key), `env` block with all keys cleared, and `permissions.allow` pre-built with read/query MCP tool calls across all servers.
- Updated `CLAUDE.md`: routing table now points MCP integration to the example file; project structure tree documents `settings.local.json` and `settings.local.json.example`; added callout below MCP Servers table linking to the example file.
- Updated `README.md`: project structure tree shows the new example file; Configuration Files section gains a full `settings.local.json.example` subsection with table of its three parts; MCP Servers section gains a Quick Setup callout.

## 2026-04-27 (session 2)
- **Diagnosed skill loading failure:** `.claude/skills/*.md` flat files were silently ignored by Claude Code. Root cause: Claude Code requires `~/.claude/skills/<name>/SKILL.md` subdirectory format, not flat project-level `.md` files.
- **Restructured project skills:** moved `site-teardown.md` → `site-teardown/SKILL.md` and `skillui.md` → `skillui/SKILL.md` within `.claude/skills/`. Also copied both to `~/.claude/skills/` for immediate activation.
- **Added `setup.sh` step 8:** auto-installs all `.claude/skills/*/SKILL.md` to `~/.claude/skills/` on fresh clone. Skills are now activated on `setup.sh` run without manual copying.
- **Added impeccable plugin:** `impeccable@impeccable` (github.com/pbakaus/impeccable) — 23 frontend design commands + 24-issue anti-pattern detection. Added to `setup.sh` step 7, `README.md` plugins section, and `CLAUDE.md` plugins table.
- **Added skillui CLI integration:** documented `skillui` (npm install -g skillui) for design system extraction from sites/repos/local dirs. `/skillui` skill fully documented.
- **Updated `frontend-instructions.md`:** added skillui and impeccable to "Always Do First" workflow — skillui for matching existing sites, impeccable for critique/polish/audit passes.
- **Updated `memory-decisions.md`:** recorded skill format decision, impeccable decision, and skillui decision with rationale.

<!-- Example entry format:
## 2026-04-06
- Built YouTube monitoring task in Trigger.dev (`src/trigger/youtube/`)
- Discovered YouTube Data API rate limit: 10,000 units/day; batch fetching costs 1 unit/video
- Switched from polling every hour to every 8 hours to stay within quota
- Deployed to production; first run succeeded
- Updated `workflow-builder-instructions.md` with rate limit note
-->


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- All 5 optimizations are complete.\n\n---\n\nHere's what was implemented:\n\n| # | Optimization | Files Changed |\n|---|---|---|\n| 1 | **context7 MCP** â€” live SDK docs on demand | `.mcp.json`, `settings.json` |\n| 2 | **trigger-api-reference.md moved** â€” stops auto-loading every session (~200 lines saved) | `.claude/docs/`, `trigger-workflow-builder.md`, `CLAUDE.md` |\n| 3 | **memory-distiller agent** â€” compresses sessions >30 days into archive | `.claude/agents/memory-distiller.md` |\n| 4 | **`/compact-memory` skill** â€” full hygiene: compress, prune, sync to MCP graph | `.claude/skills/compact-memory/SKILL.md`, `~/.claude/skills/` |\n| 5 | **read-guard PreToolUse hook** â€” warns on unscoped reads of large files | `.claude/hooks/read-guard.py`, `settings.json` |\n| + | **Stop hook enhanced** â€” auto-drafts memory entries from session transcript | `.claude/scripts/memory-drafter.py`, `.claude/hooks/stop.sh` |\n\n**To activate context7:** Restart Claude Code â€” it will pick up the new MCP server from `.mcp.json` automatically.\n\n**Immediate token savings:** `trigger-api-reference.md` no longer loads every session (~200 lines).
