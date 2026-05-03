# Project Decisions

Architectural and technical decisions made during sessions — with date and rationale. Update this file whenever a non-trivial decision is made or confirmed.

---

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


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-04-30 — edit or delete below -->


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-01 — edit or delete below -->
- Here's what was implemented:\n\n---\n\n## âœ… Integration Complete\n\n### What Was Added\n\n**CLI Tool** â€” `notebooklm-mcp-cli` (Python package)\n- **Primary interface:** `nlm` CLI command\n- **Backup:** `notebooklm-mcp` MCP server (35 tools)\n- **Pattern:** CLI-first (matches Playwright and Firecrawl)\n\n### Files Created\n\n| File | Purpose |\n|------|---------|\n| `.claude/skills/notebooklm/SKILL.md` | Complete usage guide â€” CLI commands, MCP tools, authentication, workflows, decision matrix |\n\n### Files Updated\n\n| File | Changes |\n|------|---------|\n| `setup.sh` | Step 11: `uv tool install notebooklm-mcp-cli`; Step 12: authentication reminder (`nlm login`) |\n| `settings.json` | Added CLI permissions (`Bash(nlm:*)`, `PowerShell(nlm *)`); enabled `notebooklm-mcp` in `enabledMcpjsonServers` |\n| `.mcp.json` | Already present (line 181-184) â€” uses `uvx --from notebooklm-mcp-cli notebooklm-mcp` |\n| `CLAUDE.md` | Routing table, Skills section, MCP Servers section, First-Time Setup, uvx requirement note |\n| `README.md` | setup.sh steps 11-12, Prerequisites table, Project Skills table, MCP Servers table, uvx verification |\n| `memory-decisions.md` | Decision logged with rationale and implications |\n| `memory-sessions.md` | Session work recorded |\n\n### How to Use\n\n**On fresh clone:**\n```bash\nbash .claude/hooks/setup.sh  # Installs notebooklm-mcp-cli via uv\nnlm login                     # Authenticate (launches browser, extracts cookies)\n```\n\n**CLI commands** (primary):\n```bash\nnlm notebook list\nnlm notebook create \"Research Project\"\nnlm source add <notebook> --url \"https://...\"\nnlm audio create <notebook> --confirm\nnlm download audio <notebook> <artifact-id>\n```\n\n**MCP tools** (backup only) â€” for multi-step interactive flows\n\n### Architecture\n\nFollows the established **CLI-first pattern**:\n- Direct CLI execution via Bash = token-free\n- MCP server = backup for interactive flows only\n- Minimizes context window consumption while preserving full functionality\n\n### Authentication\n\n- **Method:** Cookie-based via `nlm login`\n- **Duration:** 2-4 weeks (auto-refreshes)\n- **Modes:** Auto (launches browser) or manual (import file)\n- **Profiles:** Supports multiple Google accounts\n\n### Source\n\nhttps://github.com/jacob-bd/notebooklm-mcp-cli\n\n---\n\nAll documentation is updated and the skill is ready to use.


<!-- DRAFT: review and edit before treating as permanent -->
<!-- Drafted 2026-05-03 — edit or delete below -->
- {"session_id":"e3c32a9b-8036-4cec-b5ad-2338570e0b28","transcript_path":"C:\\Users\\mdmor\\.claude\\projects\\C--GIT-Claude-Code-Boilerplate-Framework\\e3c32a9b-8036-4cec-b5ad-2338570e0b28.jsonl","cwd":"C:\\GIT\\Claude_Code_Boilerplate_Framework","permission_mode":"default","hook_event_name":"Stop","stop_hook_active":false,"last_assistant_message":"## How It All Works Together\n\nHere's the complete architecture:\n\n### 1.
