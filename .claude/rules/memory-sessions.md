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


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Here's a summary of every gap that was fixed:\n\n| Step | What changed |\n|------|-------------|\n| **Step 1** | Added `chmod +x autosync-docs.sh` â€” the PostToolUse hook was missing from the executable list on Unix/macOS |\n| **Step 6** | Updated count `15 â†’ 17` in both the header comment and the error message; added `higgsfield` and `context7` to the server list |\n| **Step 7** | Added installation blocks for `codex@openai-codex` and `cc-gemini-plugin@cc-gemini-plugin` â€” both were in `enabledPlugins` but had no setup.sh entry.
- Manual fallback instructions added to the `else` branch too |\n| **Step 10** (new) | Added `gh` CLI check with platform-specific install instructions â€” required by `github@claude-plugins-official` and the `Bash(gh api/gh repo)` permissions |\n| **Step 12** (auth reminders, renumbered) | Added reminders for `gh auth login`, `GEMINI_API_KEY` (with aistudio.google.com link), and Codex CLI (`npm install -g @openai/codex`) |\n| **Steps 11â†’14** | Renumbered to stay sequential after the new step 10 insertion |"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Here's a summary of all three changes made:\n\n| File | Change | Reason |\n|------|--------|--------|\n| `setup.sh` | Python detection now tests actual execution (`python3 --version` exit code) instead of `command -v`; also tries `py` as fallback | Windows has a fake `python3.exe` Store alias that fools `command -v` but exits 49 â€” was showing empty version `()` |\n| `setup.sh` | Switched `grep -oP` â†’ `grep -oE` for version extraction | `-P` (Perl regex) not available in Git Bash on Windows |\n| `read-guard.py` | Raised `MIN_LINES_WARNING` from 80 â†’ 200; shortened systemMessage format | 80 lines is too aggressive â€” fires on many normal files; verbose message added tokens every read |"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- `./CLAUDE.md` (Project Root)\n\n**Score: 83/100 (Grade: B)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 14/20 | Has trigger.dev, setup, statusline â€” missing playwright example command |\n| Architecture clarity | 18/20 | Routing table is excellent; WAT summary is tight |\n| Non-obvious patterns | 11/15 | Skill subdirectory format documented; missing the Alpaca OS env var gotcha |\n| Conciseness | 13/15 | Well-trimmed after 04-30 optimization â€” appropriate density |\n| Currency | 14/15 | All links correct â€” `.claude/docs/trigger-api-reference.md` is accurate |\n| Actionability | 13/15 | Memory trigger table and routing table are highly actionable |\n\n**Issues:**\n- Known gotcha from the Alpaca 401 session is undocumented: `${VAR}` in `.mcp.json` reads from OS process env, **not** from `.env`.
- fresh clone)\n rm -f .claude/.setup-complete && bash .claude/hooks/setup.sh\n \n # Reinstall context-monitor statusline\n npx claude-code-templates@latest --setting statusline/context-monitor\n+\n+# Browser automation (WAT Tools layer example)\n+node tools/playwright.js screenshot https://example.com\n ```\n+\n+> **MCP credential gotcha:** `.mcp.json` `${VAR}` substitution reads from the **OS process environment**, not `.env`.
- `./README.md`\n\n**Score: 77/100 (Grade: C+)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 18/20 | 14-step Quick Start is thorough and copy-paste ready |\n| Architecture clarity | 19/20 | Project structure tree + WAT section are excellent |\n| Non-obvious patterns | 10/15 | Alpaca paper-mode note is good; missing OS env var gotcha |\n| Conciseness | 8/15 | ~676 lines â€” appropriate for a README but duplicates CLAUDE.md in several tables |\n| Currency | 9/15 | **4 stale `trigger-api-reference.md` links** (points to `.claude/rules/` â€” file moved to `.claude/docs/`); \"18 MCP servers\" count is stale (actual: 20) |\n| Actionability | 14/15 | Platform-specific instructions and numbered steps throughout |\n\n**Issues (by severity):**\n\n**High â€” stale paths (4 locations):**\n- Line 277 (project structure tree): `trigger-api-reference.md` shown under `rules/` â€” should be under `docs/`\n- Line 537 (Rules table): link is `.claude/rules/trigger-api-reference.md` â€” should be `.claude/docs/`\n- Line 627 (WAT section): same stale `.claude/rules/` link\n- Line 93 (trim table): path implied by `trigger-api-reference.md` row â€” no link but will mislead\n\n**Medium â€” stale count:**\n- Line 36: \"18 pre-configured MCP integrations\" â€” actual table has 20 servers (monet, stitch, 21st-dev-magic, playwright-mcp, firecrawl-mcp were added after this count was set)\n\n---\n\n### Proposed Updates\n\nOnly README.md needs fixes.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- `./CLAUDE.md`\n\n**Score: 88/100 (Grade: B+)**\n\n| Criterion | Before | After | Notes |\n|-----------|--------|-------|-------|\n| Commands/workflows | 14/20 | 16/20 | Playwright example added; gotcha note makes setup actionable |\n| Architecture clarity | 18/20 | 18/20 | Unchanged â€” routing table remains excellent |\n| Non-obvious patterns | 11/15 | 13/15 | OS env var gotcha now documented |\n| Conciseness | 13/15 | 13/15 | Addition is earned weight, not padding |\n| Currency | 14/15 | 14/15 | All links correct |\n| Actionability | 13/15 | 14/15 | Concrete tool command improves developer flow |\n\n---\n\n### 2.
- `./README.md`\n\n**Score: 84/100 (Grade: B)**\n\n| Criterion | Before | After | Notes |\n|-----------|--------|-------|-------|\n| Commands/workflows | 18/20 | 18/20 | Unchanged |\n| Architecture clarity | 19/20 | 19/20 | Tree now accurate â€” `trigger-api-reference.md` in `docs/` |\n| Non-obvious patterns | 10/15 | 11/15 | Trim table now clarifies which dir each file lives in |\n| Conciseness | 8/15 | 8/15 | Length appropriate for a README |\n| Currency | 9/15 | 14/15 | All 4 stale paths fixed; server count updated 18â†’20; Reference Docs table now complete |\n| Actionability | 14/15 | 14/15 | Unchanged |\n\n**Changes applied:**\n- `trigger-api-reference.md` removed from rules/ tree â†’ added to docs/ tree\n- All 3 stale `.claude/rules/trigger-api-reference.md` links â†’ `.claude/docs/`\n- `trigger-api-reference.md` removed from auto-loaded Rules table (it's not auto-loaded anymore)\n- `trigger-api-reference.md` added to Reference Docs table with correct path\n- \"18 pre-configured\" â†’ \"20 pre-configured\" MCP integrations\n- Trim guidance clarified to show which directory each Trigger.dev file lives in\n\n---\n\n**No further issues found.** Both files are consistent with each other and with the current repo state."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- You set it in `settings.local.json` under `\"env\": { \"CONTEXT7_API_KEY\": \"your-key-here\" }`.\n\n### Servers that need NO key\n\n`memory`, `trigger`, `zep-mcp`, `canva-dev`, `higgsfield`, `playwright-mcp` â€” these activate automatically with no credentials needed.\n\n### The critical gotcha\n\n**`.env` is NOT read by Claude Code / `.mcp.json` at all.** `.env` is only for your own code (Trigger.dev tasks, Python tools, etc.) that explicitly loads it via `dotenv`.


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Added `SUPABASE_PROJECT_URL`, `SUPABASE_PROJECT_KEY`, `CONTEXT7_API_KEY`, and `GITHUB_PERSONAL_ACCESS_TOKEN` which were previously missing.\n\n**`settings.local.json.example`** â€” two additions:\n- `context7` entry added to `__activation_guide` (was in `env` block but had no guide entry)\n- 6 previously missing vars added to both `__activation_guide` (with a `__note_app_code_vars` section divider explaining they're app-code vars) and the `env` block: `SUPABASE_PROJECT_URL`, `SUPABASE_PROJECT_KEY`, `OPENROUTER_BASE_URL`, `OPENROUTER_MODEL`, `VAPI_SDK_KEY`, `ALPACA_BASE_URL`"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Added all 6 new vars to `settings.local.json` with their actual values from context:\n\n| Var | Value |\n|-----|-------|\n| `SUPABASE_PROJECT_URL` | `https://pyztdrdxegvyqsbcqfiy.supabase.co` |\n| `SUPABASE_PROJECT_KEY` | Supabase service-role JWT |\n| `OPENROUTER_BASE_URL` | `https://openrouter.ai/api/v1` |\n| `OPENROUTER_MODEL` | `openrouter/auto` |\n| `VAPI_SDK_KEY` | Vapi client SDK key |\n| `ALPACA_BASE_URL` | `https://paper-api.alpaca.markets/v2` |"}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Here's what was added to `settings.local.json.example`:\n\n- **`__note_model_switching`** section in `__activation_guide` â€” explains the OpenRouter routing pattern, all 10 ANTHROPIC/`CLAUDE_CODE_*` vars, and the full list of model slugs (`openrouter/auto`, `anthropic/claude-opus-4`, `openai/gpt-4o`, `deepseek/deepseek-chat`, etc.)\n- **10 new keys** in the `env` block â€” all blank by default, ready to fill when you want to switch models or route through OpenRouter\n\nThe `.env.example` comment block (lines 40â€“54) can now be removed or left as-is â€” `settings.local.json.example` is the authoritative reference since these vars must go in the `env` block there, not in `.env`."}


<!-- DRAFT: review and edit before treating as permanent -->
## 2026-04-30 (auto-drafted — review before next session)
- Header now redirects new users to `settings.local.json.example` for the full credential setup.\n\n**`settings.local.json.example`** â€” added the missing `OPENROUTER_API_KEY` to the `env` block (it was in the activation guide but absent from the block, so new users copying the template would have skipped it).\n\nThe comment at the top of the old `.env` (\"Keys shared with MCP servers must be set in BOTH files\") is now obsolete â€” `settings.local.json` is the single source of truth for all credentials."}
