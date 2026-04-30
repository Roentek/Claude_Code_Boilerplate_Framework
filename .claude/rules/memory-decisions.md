# Project Decisions

Architectural and technical decisions made during sessions — with date and rationale. Update this file whenever a non-trivial decision is made or confirmed.

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


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-04-30 — edit or delete below -->
- `./CLAUDE.md` (Project Root)\n\n**Score: 83/100 (Grade: B)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 14/20 | Has trigger.dev, setup, statusline â€” missing playwright example command |\n| Architecture clarity | 18/20 | Routing table is excellent; WAT summary is tight |\n| Non-obvious patterns | 11/15 | Skill subdirectory format documented; missing the Alpaca OS env var gotcha |\n| Conciseness | 13/15 | Well-trimmed after 04-30 optimization â€” appropriate density |\n| Currency | 14/15 | All links correct â€” `.claude/docs/trigger-api-reference.md` is accurate |\n| Actionability | 13/15 | Memory trigger table and routing table are highly actionable |\n\n**Issues:**\n- Known gotcha from the Alpaca 401 session is undocumented: `${VAR}` in `.mcp.json` reads from OS process env, **not** from `.env`.
- `./README.md`\n\n**Score: 77/100 (Grade: C+)**\n\n| Criterion | Score | Notes |\n|-----------|-------|-------|\n| Commands/workflows | 18/20 | 14-step Quick Start is thorough and copy-paste ready |\n| Architecture clarity | 19/20 | Project structure tree + WAT section are excellent |\n| Non-obvious patterns | 10/15 | Alpaca paper-mode note is good; missing OS env var gotcha |\n| Conciseness | 8/15 | ~676 lines â€” appropriate for a README but duplicates CLAUDE.md in several tables |\n| Currency | 9/15 | **4 stale `trigger-api-reference.md` links** (points to `.claude/rules/` â€” file moved to `.claude/docs/`); \"18 MCP servers\" count is stale (actual: 20) |\n| Actionability | 14/15 | Platform-specific instructions and numbered steps throughout |\n\n**Issues (by severity):**\n\n**High â€” stale paths (4 locations):**\n- Line 277 (project structure tree): `trigger-api-reference.md` shown under `rules/` â€” should be under `docs/`\n- Line 537 (Rules table): link is `.claude/rules/trigger-api-reference.md` â€” should be `.claude/docs/`\n- Line 627 (WAT section): same stale `.claude/rules/` link\n- Line 93 (trim table): path implied by `trigger-api-reference.md` row â€” no link but will mislead\n\n**Medium â€” stale count:**\n- Line 36: \"18 pre-configured MCP integrations\" â€” actual table has 20 servers (monet, stitch, 21st-dev-magic, playwright-mcp, firecrawl-mcp were added after this count was set)\n\n---\n\n### Proposed Updates\n\nOnly README.md needs fixes.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-04-30 — edit or delete below -->
- `./CLAUDE.md`\n\n**Score: 88/100 (Grade: B+)**\n\n| Criterion | Before | After | Notes |\n|-----------|--------|-------|-------|\n| Commands/workflows | 14/20 | 16/20 | Playwright example added; gotcha note makes setup actionable |\n| Architecture clarity | 18/20 | 18/20 | Unchanged â€” routing table remains excellent |\n| Non-obvious patterns | 11/15 | 13/15 | OS env var gotcha now documented |\n| Conciseness | 13/15 | 13/15 | Addition is earned weight, not padding |\n| Currency | 14/15 | 14/15 | All links correct |\n| Actionability | 13/15 | 14/15 | Concrete tool command improves developer flow |\n\n---\n\n### 2.
- `./README.md`\n\n**Score: 84/100 (Grade: B)**\n\n| Criterion | Before | After | Notes |\n|-----------|--------|-------|-------|\n| Commands/workflows | 18/20 | 18/20 | Unchanged |\n| Architecture clarity | 19/20 | 19/20 | Tree now accurate â€” `trigger-api-reference.md` in `docs/` |\n| Non-obvious patterns | 10/15 | 11/15 | Trim table now clarifies which dir each file lives in |\n| Conciseness | 8/15 | 8/15 | Length appropriate for a README |\n| Currency | 9/15 | 14/15 | All 4 stale paths fixed; server count updated 18â†’20; Reference Docs table now complete |\n| Actionability | 14/15 | 14/15 | Unchanged |\n\n**Changes applied:**\n- `trigger-api-reference.md` removed from rules/ tree â†’ added to docs/ tree\n- All 3 stale `.claude/rules/trigger-api-reference.md` links â†’ `.claude/docs/`\n- `trigger-api-reference.md` removed from auto-loaded Rules table (it's not auto-loaded anymore)\n- `trigger-api-reference.md` added to Reference Docs table with correct path\n- \"18 pre-configured\" â†’ \"20 pre-configured\" MCP integrations\n- Trim guidance clarified to show which directory each Trigger.dev file lives in\n\n---\n\n**No further issues found.** Both files are consistent with each other and with the current repo state."}
