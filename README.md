# Claude Code Boilerplate Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A ready-to-clone starting point for Claude Code as an agentic AI workspace. Ships with pre-configured plugins, skills, MCP servers, hooks, rules, and workflow patterns so you can skip boilerplate and start building immediately.

---

## Table of Contents

- [What This Is](#what-this-is)
- [How to Use This Boilerplate](#how-to-use-this-boilerplate)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration Files](#configuration-files)
- [Plugins](#plugins)
- [Skills (Slash Commands)](#skills-slash-commands)
- [MCP Servers](#mcp-servers)
- [Rules (Auto-Loaded Instructions)](#rules-auto-loaded-instructions)
- [Hooks & Scripts](#hooks--scripts)
- [Context Monitor Statusline](#context-monitor-statusline)
- [WAT Framework](#wat-framework)
- [Memory System](#memory-system)
- [Reference Docs](#reference-docs)

---

## What This Is

This framework wires together every layer of a Claude Code project:

- **Rules** — Markdown instruction files auto-loaded into every session
- **Plugins** — Extend Claude Code with specialized modes (superpowers, frontend-design, agent-sdk, cli-anything, etc.)
- **Skills** — Reusable slash commands you invoke with `/skill-name`
- **MCP Servers** — 22 pre-configured Model Context Protocol integrations (Supabase, Google Workspace, Pinecone, Trigger.dev, n8n, Vapi, Apify, Alpaca, Firecrawl, NotebookLM, OpenSpace, Monet, 21st.dev Magic, and more)
- **Hooks** — Lifecycle shell scripts that run on session start, stop, and tool events
- **Scripts** — A context monitor statusline, first-time setup bootstrapper, and memory management tools
- **WAT Framework** — Architecture pattern: Workflows → Agents → Tools

---

## How to Use This Boilerplate

This repo ships with everything enabled so you can see what's possible. **You are not expected to use all of it.** The right approach is to clone it, then immediately strip out anything you don't need. Fewer active MCP servers, rules, and plugins = less context consumed every session = faster, cheaper, more focused responses.

### Step 1 — Clone and open

```bash
git clone https://github.com/your-org/claude-code-boilerplate-framework.git my-project
cd my-project
cp .env.example .env
claude .
```

### Step 2 — Remove what you don't need

Work through each layer and delete or disable anything irrelevant to your project:

#### MCP Servers (`.mcp.json` + `.claude/settings.json`)

Each server adds tools to every session. Remove any you won't use:

1. Delete the server block from `.mcp.json`
2. Remove its entry from `enabledMcpjsonServers` in `.claude/settings.json`
3. Remove its `ENV_VAR` lines from `.env.example` (and `.env`)

**Keep:** Only servers whose tools you expect to call within the next week.
**Remove everything else.** You can add them back in 30 seconds when needed.

#### Plugins (`.claude/settings.json → enabledPlugins`)

Set any plugin to `false` to disable it:

```json
"enabledPlugins": {
  "superpowers": true,
  "frontend-design": false,
  "ui-ux-pro-max": false,
  "agent-sdk-dev": false
}
```

**Keep:** `superpowers` is recommended for all projects — it provides planning, debugging, and code review workflows that apply universally.

#### Rules (`.claude/rules/`)

Every `.md` file here is injected into every session. Remove files that don't apply to your work:

| Remove if... | Files to delete |
| --- | --- |
| Not building frontend UI | `frontend-instructions.md`, `.claude/docs/ui-ux-pro-max-instructions.md` |
| Not using Trigger.dev | `trigger-workflow-builder.md` (in `rules/`); `trigger-api-reference.md` (in `docs/`) |
| Not using the WAT agent pattern | `agent-instructions.md` |

The four `memory-*.md` files are always worth keeping — they hold your project's accumulated context.

#### Skills (`.claude/skills/`)

Delete any `.md` skill files you didn't create and don't plan to use. Skills only fire when invoked, so unused skills don't hurt performance — but removing them keeps the project clean.

### Step 3 — Add what your project needs

Once trimmed, add only the tools you actually need:

- **New MCP server**: add a block to `.mcp.json`, enable it in `settings.json`, add credentials to `.env`
- **New rule**: create a `.md` file in `.claude/rules/` — it auto-loads next session
- **New skill**: create `<name>/SKILL.md` in `.claude/skills/`, then re-run `bash .claude/hooks/setup.sh` to install it to `~/.claude/skills/`
- **New plugin**: `claude plugins install <plugin-name>` then enable in `settings.json`

### What's tested and ready out of the box

Everything in this repo has been validated:

| Layer | Tested |
| ----- | ------ |
| All MCP servers | Connection verified, `.env` keys documented |
| All plugins | Installed and configured via `settings.json` |
| Context monitor statusline | Works on macOS, Linux, Windows |
| Setup hook | Runs on first `claude .` open |
| Stop hook | Fires after every response |
| Pre-commit hook | Auto-syncs CLAUDE.md/README.md on tracked-path commits |
| Memory system | Both file-based and knowledge graph tiers |

---

## Prerequisites

All of the below must be on your `PATH` before setup runs.

### Required

| Tool | Why | Install |
| ------ | ----- | --------- |
| **Node.js 18+** | Runs `npx` for all MCP servers | `https://nodejs.org` or `nvm install --lts` |
| **npm** | Bundled with Node.js | — |
| **Python 3.8+** | Context monitor statusline + `ui-ux-pro-max` design search scripts | `https://python.org` or see below |
| **Git** | Clone the repo | `https://git-scm.com` |
| **Claude Code CLI** | The AI assistant itself | `npm install -g @anthropic-ai/claude-code` |

### Required for specific MCP servers

| Tool | Why | Install |
| ------ | ----- | --------- |
| **uv / uvx** | Google Workspace MCP, Alpaca MCP, and NotebookLM MCP use `uvx` | See below |

### Install Python

**macOS / Linux:**

```bash
# Homebrew
brew install python3

# or pyenv
curl https://pyenv.run | bash
pyenv install 3.11 && pyenv global 3.11
```

**Windows:**

```powershell
# winget
winget install Python.Python.3.11

# or download from https://python.org/downloads/
```

Verify: `python3 --version`

### Install uv / uvx

`uv` is a fast Python package manager. `uvx` (bundled with `uv`) runs Python tools without installing them globally.

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# via pip (any platform)
pip install uv
```

Verify: `uvx --version`

### Install Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

Verify: `claude --version`

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/your-org/claude-code-boilerplate-framework.git
cd claude-code-boilerplate-framework

# 2. Copy and fill in your API keys
cp .env.example .env
# Edit .env — add only the keys for the services you plan to use

# 3. Open in Claude Code
claude .
```

On first open, a `Setup` hook automatically runs `.claude/hooks/setup.sh`, which:

1. **Makes hooks executable** — `chmod +x` on `stop.sh` and `pre-commit.sh` (Unix/macOS only)
2. **Verifies Python** — checks `python3` / `python` is in PATH; required by the context-monitor statusline and `ui-ux-pro-max` design search scripts
3. **Verifies context-monitor.py** — confirms the statusline script is present
4. **Creates `.env`** — copies `.env.example` → `.env` if none exists, then auto-configures OpenSpace paths (`OPENSPACE_HOST_SKILL_DIRS` and `OPENSPACE_WORKSPACE`) based on your platform (detects home directory automatically — works on Windows, macOS, Linux)
5. **Verifies uvx** — required for `google-workspace-mcp`, `alpaca`, and `notebooklm-mcp` MCP servers
6. **Verifies Node.js / npx** — required by all 17 npx-based MCP servers (memory, supabase, openrouter, kie-ai, tavily, trigger, pinecone, vapi, n8n, apify, zep, canva, 21st-dev, playwright-mcp, firecrawl-mcp, higgsfield, context7)
7. **Installs marketplace plugins** — attempts to auto-install `ui-ux-pro-max`, `andrej-karpathy-skills`, `impeccable`, `codex`, `cc-gemini-plugin`, and `cli-anything` via CLI
8. **Installs project skills** — copies `.claude/skills/*/` to `~/.claude/skills/` where Claude Code reads them (full directory, not just SKILL.md — preserves supporting docs and examples)
9. **Installs npm dependencies + Playwright browser** — runs `npm install` for the `playwright` package, then `npx playwright install chromium` for the browser binary used by `tools/playwright.js`
10. **Verifies GitHub CLI** — checks `gh` is installed; required by `github@claude-plugins-official` for `Bash(gh ...)` tool calls; prints platform-specific install instructions if missing
11. **Installs global CLI tools** — `skillui` (design system extractor for `/skillui` skill), `firecrawl-cli` (web scraping CLI for `/firecrawl` skill), `codex-cli` (OpenAI Codex CLI for `/three-brain` auto-router and `codex` plugin), `gemini-cli` (Google Gemini CLI for `/three-brain` multimodal routes and `cc-gemini-plugin`), and `notebooklm-mcp-cli` (Google NotebookLM CLI + MCP for `/notebooklm` skill via `uv tool install`)
12. **Prints authentication reminders** — lists integrations requiring a manual one-time auth step: NotebookLM (`nlm login`), Trigger.dev (`npx trigger.dev@latest login`), Google Workspace (browser OAuth), Canva (browser OAuth), Higgsfield (browser OAuth via `npx mcp-remote`), GitHub CLI (`gh auth login`), Gemini plugin (`GEMINI_API_KEY` at aistudio.google.com), and Codex plugin (`npm install -g @openai/codex`)
13. **Installs autoresearch dependencies** — runs `uv sync` in the `tools/autoresearch/` directory to install PyTorch and ML dependencies for autonomous research experiments
14. **Installs LightRAG dependencies** — runs `uv sync` in the `tools/lightrag/` directory to install `lightrag-hku` and dependencies for graph-based RAG
15. **Initializes OpenSpace submodule and installs** — checks if `tools/openspace/` is a git submodule and initializes it via `git submodule update --init --recursive` if not already done; then runs `pip install -e .` to install the self-evolving skill system (requires Python 3.12+); sets up the optional dashboard frontend by copying `.env.example` → `.env` and running `npm install` in `tools/openspace/frontend/` (requires Node.js ≥ 20)
16. **Installs pre-commit hook** — writes a thin wrapper to `.git/hooks/pre-commit` pointing to `.claude/hooks/pre-commit.sh`
17. **Writes a marker** — creates `.claude/.setup-complete` so setup only runs once per machine

**Re-run setup manually** (e.g. fresh clone on a new machine):

```bash
rm -f .claude/.setup-complete && bash .claude/hooks/setup.sh
```

**If setup never ran automatically**, run it directly:

```bash
bash .claude/hooks/setup.sh
```

**Converting existing OpenSpace clone to submodule:**

If you cloned OpenSpace before the submodule setup was added, see [`.claude/docs/openspace-submodule-conversion.md`](.claude/docs/openspace-submodule-conversion.md) for step-by-step conversion instructions. This preserves all integrations (skills, MCP, launch configs, .env paths) while enabling auto-sync with upstream.

---

## Project Structure

```txt
.
├── CLAUDE.md                        # Session rules: philosophy, routing table, memory triggers
├── README.md                        # This file
├── package.json                     # Node.js dependencies (playwright browser automation)
├── .env                             # Your API keys (gitignored — never commit)
├── .env.example                     # Template for all required keys
├── .mcp.json                        # MCP server definitions (version-controlled)
├── .gitignore
├── LICENSE
│
├── .claude/
│   ├── settings.json                # Permissions, enabled plugins, hooks, statusline
│   ├── settings.local.json          # Machine-local credentials + permissions (gitignored)
│   ├── settings.local.json.example  # Template: all MCP credential keys cleared + activation guide
│   ├── agents/                      # Custom sub-agent definitions (.md files)
│   ├── docs/                        # Reference docs loaded with the project
│   │   ├── Claude_Code_Beginners_Guide.md
│   │   ├── Claude_Code_Context_Management_Hacks.md
│   │   ├── The_Shift_to_Agentic_AI_Workflows.md
│   │   ├── trigger-api-reference.md
│   │   └── ui-ux-pro-max-instructions.md
│   ├── hooks/
│   │   ├── setup.sh                 # Setup hook: first-time machine bootstrapper
│   │   ├── stop.sh                  # Stop hook: syncs autoresearch + openspace, drafts memory, checks doc updates
│   │   ├── pre-commit.sh            # Pre-commit hook: auto-updates CLAUDE.md/README.md for tracked-path changes
│   │   ├── autosync-docs.sh         # PostToolUse hook: detects tracked-path edits, injects doc-sync reminder
│   │   ├── autoresearch-sync.sh     # Autoresearch upstream sync (called by stop.sh every session)
│   │   ├── openspace-sync.sh        # OpenSpace submodule sync (called by stop.sh every session)
│   │   └── read-guard.py            # PreToolUse hook: warns on unscoped reads of large files (>200 lines)
│   ├── rules/                       # Auto-loaded Markdown instructions (every session)
│   │   ├── agent-instructions.md
│   │   ├── frontend-instructions.md
│   │   ├── trigger-workflow-builder.md
│   │   ├── memory-guidelines.md
│   │   ├── memory-profile.md
│   │   ├── memory-preferences.md
│   │   ├── memory-decisions.md
│   │   ├── memory-sessions.md
│   │   └── karpathy-guidelines.md
│   ├── scripts/
│   │   ├── autosync-docs.py         # Python logic for autosync-docs.sh (path matching + additionalContext JSON)
│   │   ├── context-monitor.py       # Statusline: context %, cost, git branch, duration
│   │   └── memory-drafter.py        # Auto-drafts memory entries from session transcript (called by stop.sh)
│   └── skills/                      # Project-local slash-command skills (<name>/SKILL.md)
│       ├── site-teardown/SKILL.md   # Reverse-engineer any website into a build blueprint
│       ├── skillui/SKILL.md         # Extract design system from site/repo via skillui CLI
│       ├── webgpu-threejs-tsl/      # WebGPU + Three.js TSL skill (SKILL.md + docs/ + examples/ + templates/)
│       ├── design-md/SKILL.md       # Load brand DESIGN.md for 73 brands via getdesign CLI
│       ├── taste-skill/SKILL.md     # Anti-slop frontend enforcement: design dials, banned patterns, Bento 2.0
│       ├── playwright/SKILL.md      # Browser automation: screenshot, scrape, pdf, links via tools/playwright.js
│       ├── firecrawl/SKILL.md       # Web scraping: single-page, crawl, search, map, AI agent via firecrawl CLI
│       ├── notebooklm/SKILL.md      # Google NotebookLM: create notebooks, add sources, generate podcasts/videos/briefings
│       ├── three-brain/SKILL.md     # Multi-model router: Claude (standard), Codex (review/rescue), Gemini (multimodal)
│       ├── compact-memory/SKILL.md  # Memory hygiene: compress sessions, prune decisions, sync to knowledge graph
│       ├── autoresearch/SKILL.md    # Autonomous ML research: modify GPT code, run 5-min experiments, iterate overnight
│       ├── lightrag/SKILL.md        # Graph-based RAG: knowledge extraction, entity-relationship Q&A, multimodal docs
│       ├── openspace/SKILL.md       # Self-evolving skill system: auto-fix, auto-improve, auto-learn, cloud sharing
│       ├── delegate-task/SKILL.md   # OpenSpace host skill: delegate tasks to grounding agent with auto evolution
│       └── skill-discovery/SKILL.md # OpenSpace host skill: search local + cloud skills before starting work
│
├── brand_assets/                    # Logos, color guides, design tokens
├── docs/                            # Project-level documentation
├── src/
│   └── trigger/                     # Trigger.dev TypeScript task files
├── tools/
│   ├── playwright.js                # Browser automation: screenshot, scrape, pdf, links (node tools/playwright.js)
│   ├── autoresearch/                # Autonomous ML research (karpathy/autoresearch)
│   │   ├── prepare.py               # Data prep, tokenizer, eval (read-only, agent never modifies)
│   │   ├── train.py                 # GPT model, optimizer, training loop (agent modifies this)
│   │   ├── program.md               # Agent instructions (human edits to guide research)
│   │   ├── pyproject.toml           # Dependencies (PyTorch, etc.)
│   │   ├── uv.lock                  # Dependency lockfile
│   │   └── README.md                # Full autoresearch documentation
│   ├── lightrag/                    # Graph-based RAG server (HKUDS/LightRAG)
│   │   ├── pyproject.toml           # Dependencies (lightrag-hku + server deps)
│   │   ├── uv.lock                  # Dependency lockfile
│   │   ├── README.md                # Full LightRAG documentation
│   │   ├── .env                     # Server config + OPENAI_API_KEY (gitignored)
│   │   ├── .env.example             # Configuration template (safe to commit)
│   │   ├── .gitignore               # Excludes .env, logs, rag_storage, build artifacts
│   │   ├── test_lightrag.py         # Test script: insert/query example
│   │   ├── start_server.bat         # Windows quick launcher
│   │   ├── .venv/                   # Virtual environment (gitignored, recreated by uv sync)
│   │   └── rag_storage/             # Knowledge graph data (gitignored, auto-created on first use)
│   └── openspace/                   # Self-evolving skill system (git submodule → HKUDS/OpenSpace)
│       ├── openspace/               # Core Python package (grounding, skill_engine, cloud, agents)
│       ├── pyproject.toml           # Dependencies (litellm, anthropic, openai, mcp, etc.)
│       ├── README.md                # Full OpenSpace documentation
│       ├── frontend/                # Dashboard UI (React + Tailwind, requires Node.js ≥ 20)
│       ├── gdpval_bench/            # Benchmark experiments & results (GDPVal dataset)
│       ├── showcase/                # Example projects built with OpenSpace (My Daily Monitor)
│       ├── .openspace/              # Skill database + embedding cache (gitignored)
│       └── logs/                    # Execution logs & recordings (gitignored)
├── workflows/
│   ├── browser-automation.md        # WAT SOP for Playwright-based automation tasks
│   └── web-scraping.md              # WAT SOP for Firecrawl-based web scraping tasks
└── .tmp/                            # Scratch space (disposable, not committed)
```

---

## Configuration Files

### `.claude/settings.json`

Controls all Claude Code behavior for this project:

- **`permissions.allow`** — Pre-approved Bash commands and MCP tool calls (no confirmation prompt)
- **`enabledMcpjsonServers`** — Which MCP servers from `.mcp.json` are active
- **`hooks`** — Shell commands wired to lifecycle events (`Setup`, `Stop`, `PreToolUse`, etc.)
- **`statusLine`** — Command that renders the statusline bar
- **`enabledPlugins`** — Which marketplace plugins are active (set to `false` to disable)
- **`extraKnownMarketplaces`** — Additional plugin registries beyond the official Claude Code marketplace

### `.claude/settings.local.json`

Machine-local credentials and permissions — gitignored. Holds the API keys injected into MCP servers at runtime (via the `env` block) and any tool-call pre-approvals specific to your machine. Never committed.

### `.claude/settings.local.json.example`

A checked-in template for `settings.local.json`. All credential fields are cleared. Copy it to `settings.local.json` and fill in only the keys for the MCP servers you plan to use.

The file contains three sections:

| Section | Purpose |
| ------- | ------- |
| `__readme` | One-line copy instruction |
| `__activation_guide` | Per-server notes: where to get each key, which servers need no key (memory, trigger, zep, canva), and which require a one-time CLI auth step |
| `env` | All 18 credential env vars pre-listed with empty values, ready to fill in |
| `permissions.allow` | Pre-built allowlist of read/query MCP tool calls across all servers — paste into your `settings.local.json` to eliminate repeated permission prompts |

> `settings.local.json` is already in `.gitignore`. The `.example` file is version-controlled and safe to commit.

### `.mcp.json`

Defines all MCP server connections. Credentials are injected from `.env` at runtime using `${VAR_NAME}` syntax. Version-controlled so the whole team gets the same integrations.

### `.env` / `.env.example`

All secrets live here. `.env` is gitignored. Copy `.env.example` → `.env` and fill in only what you need. Unused servers simply won't connect.

---

## Plugins

Plugins extend Claude Code with specialized modes and skills. Managed in `.claude/settings.json` → `enabledPlugins`.

> **Trim this list.** Disable plugins you won't use by setting them to `false` in `settings.json`. `superpowers` is recommended for all projects. The rest are optional — enable only what your project actively uses.

### Plugin Marketplaces

Two registries are configured in `extraKnownMarketplaces`:

| Marketplace key | Source repo |
| --- | --- |
| `claude-code-plugins` | `github.com/anthropics/claude-code` (official) |
| `ui-ux-pro-max-skill` | `github.com/nextlevelbuilder/ui-ux-pro-max-skill` |
| `karpathy-skills` | `github.com/forrestchang/andrej-karpathy-skills` |
| `impeccable` | `github.com/pbakaus/impeccable` |
| `cli-anything` | `github.com/HKUDS/CLI-Anything` |

### Installing Third-Party Marketplace Plugins

The three third-party plugins below are enabled in `settings.json` but must be installed before they activate. `setup.sh` attempts to install them automatically via the CLI — if that fails, run these slash commands inside a Claude Code chat session:

**UI UX Pro Max** — design intelligence (67 styles, 161 palettes, 57 font pairings, 99 UX rules):

```bash
/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
/plugin install ui-ux-pro-max@ui-ux-pro-max-skill
```

**Andrej Karpathy Skills** — coding behavior guidelines (think first, simplicity, surgical edits):

```bash
/plugin marketplace add forrestchang/andrej-karpathy-skills
/plugin install andrej-karpathy-skills@karpathy-skills
```

**Impeccable** — frontend design skill with 23 commands (`/impeccable polish`, `/impeccable audit`, `/impeccable critique`, etc.) and 24-issue anti-pattern detection. Also available standalone: `npx impeccable detect [file/URL/dir]`:

```bash
/plugin marketplace add pbakaus/impeccable
/plugin install impeccable@impeccable
```

**CLI-Anything** — generates AI-native CLIs for existing software (GIMP, Blender, LibreOffice, Audacity, etc.). Transforms applications into agent-controllable command-line interfaces through automated source code analysis. 50+ supported applications, 2,280+ passing tests:

```bash
/plugin marketplace add HKUDS/CLI-Anything
/plugin install cli-anything@cli-anything
```

> The marketplace sources are already registered in `extraKnownMarketplaces` inside `.claude/settings.json`, so no separate marketplace registration step is needed when using the CLI: `claude plugins install ui-ux-pro-max@ui-ux-pro-max-skill`.

Install or update official plugins via CLI:

```bash
claude plugins install <plugin-name>
```

### Enabled Plugins

| Plugin | Package | What It Provides |
| -------- | -------- | ----------------- |
| **superpowers** | `superpowers@claude-plugins-official` | Full dev workflow: TDD, planning, subagents, debugging, code review, git worktrees, skill authoring |
| **frontend-design** | `frontend-design@claude-plugins-official` | `/frontend-design` skill — distinctive, production-grade UI generation |
| **ui-ux-pro-max** | `ui-ux-pro-max@ui-ux-pro-max-skill` | Design intelligence: 67 styles, 161 palettes, 57 font pairings, 99 UX rules, 25 chart types |
| **impeccable** | `impeccable@impeccable` | Frontend design skill: 23 commands (`/impeccable polish`, `/impeccable audit`, etc.) + 24-issue anti-pattern detection. Standalone: `npx impeccable detect` |
| **cli-anything** | `cli-anything@cli-anything` | Generates AI-native CLIs for existing software (GIMP, Blender, LibreOffice, Audacity, etc.). 50+ apps, 2,280+ tests. Commands: `/cli-anything`, `/cli-anything:refine`, `/cli-anything:test`, `/cli-anything:validate`, `/cli-anything:list` |
| **github** | `github@claude-plugins-official` | GitHub operations — read/write repos, PRs, issues, branches, file contents, code search. Requires `GITHUB_PERSONAL_ACCESS_TOKEN` in `settings.local.json` |
| **agent-sdk-dev** | `agent-sdk-dev@claude-plugins-official` | Agent scaffolding — creates Claude sub-agent definitions |
| **claude-code-setup** | `claude-code-setup@claude-plugins-official` | Project bootstrapping and Claude Code automation recommendations |
| **claude-md-management** | `claude-md-management@claude-plugins-official` | CLAUDE.md creation, auditing, and improvement |
| **playground** | `playground@claude-plugins-official` | Sandboxed HTML explorers for testing prompts and tool chains |

### Disabled Plugins (enable in `settings.json`)

| Plugin | Why disabled by default |
| --- | --- |
| `pinecone@claude-plugins-official` | Pinecone is already available via MCP server |
| `supabase@claude-plugins-official` | Supabase is already available via MCP server |
| `plugin-dev@claude-plugins-official` | Only needed when authoring new plugins |

---

## Skills (Slash Commands)

Skills are Markdown files that expand into full instructions when invoked. Project skills live in `.claude/skills/<name>/SKILL.md` — `setup.sh` installs them to `~/.claude/skills/` where Claude Code picks them up. Restart Claude Code after adding a new skill.

### Core Skills (always available)

| Slash Command | What It Does |
| -------------- | ------------- |
| `/frontend-design` | Mandatory first step before writing any frontend code. Activates design system generation. |
| `/claude-api` | Scaffolds an app using the Anthropic SDK or Claude Agent SDK with prompt caching. |
| `/simplify` | Reviews recently changed code for reuse, quality, and efficiency — then fixes issues found. |
| `/compact-memory` | Full memory hygiene — compresses old sessions, prunes obsolete decisions, syncs facts to knowledge graph. Run monthly or when memory files exceed ~200 lines. |
| `/schedule` | Creates cron-scheduled remote agents via Trigger.dev. |
| `/loop [interval] [command]` | Runs a prompt or command on a recurring interval (e.g. `/loop 5m /command`). |
| `/update-config` | Configures hooks, permissions, and automated behaviors in `settings.json`. |
| `/keybindings-help` | Customizes keyboard shortcuts in `keybindings.json`. |

### Superpowers Skills (auto-trigger based on context)

| Slash Command | When It Fires |
| -------------- | -------------- |
| `/brainstorming` | Before writing any code — refines rough ideas, explores alternatives, saves a design doc |
| `/writing-plans` | After design approval — breaks work into 2–5 min tasks with file paths and verification steps |
| `/subagent-driven-development` | Executing a plan — dispatches subagents per task with two-stage review |
| `/executing-plans` | Alternative to subagent-dev — batch execution with human checkpoints |
| `/test-driven-development` | During implementation — enforces RED → GREEN → REFACTOR |
| `/systematic-debugging` | Diagnosing a bug — 4-phase root cause process |
| `/verification-before-completion` | Before marking anything done — confirms the fix actually works |
| `/requesting-code-review` | Between tasks — reviews against plan, blocks on critical issues |
| `/receiving-code-review` | After review feedback — structured response workflow |
| `/dispatching-parallel-agents` | When tasks are independent — concurrent subagent execution |
| `/using-git-worktrees` | After design approval — isolates work on a new branch with clean baseline |
| `/finishing-a-development-branch` | When tasks complete — verifies tests, presents merge/PR/discard options |
| `/writing-skills` | Creating a new skill — follows best practices with adversarial testing |

### Project Skills (`.claude/skills/`)

Source files live in `.claude/skills/<name>/SKILL.md`. `setup.sh` installs them to `~/.claude/skills/` automatically.

| Slash Command | What It Does |
| -------------- | ------------- |
| `/site-teardown [url]` | Reverse engineers any website into a complete build blueprint — tech stack, every visual effect with implementation details, full design system (colors, typography, spacing), and a section-by-section build plan ready to hand off to a fresh Claude Code session. |
| `/skillui` | Runs the `skillui` CLI to extract a design system from any website, local project, or GitHub repo. Outputs `SKILL.md`, `DESIGN.md`, and token JSON (colors, spacing, typography) — auto-loaded by Claude Code. Install: `npm install -g skillui`. |
| `/webgpu-threejs-tsl` | Comprehensive guide for developing WebGPU-enabled Three.js applications using TSL (Three.js Shading Language). Covers renderer setup, node materials, compute shaders, post-processing, WGSL integration, and GPU device loss handling. Source: [dgreenheck/webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill). |
| `/design-md` | Fetches a ready-made `DESIGN.md` for any of 73 brands (Linear, Stripe, Vercel, Notion, Figma, Spotify, Tesla, Supabase, BMW, Coinbase, and more) via `npx getdesign@latest add <brand>`. Each file contains the full color palette, typography, component styles, spacing system, and pre-written AI agent prompts. Source: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md). |
| `/taste-skill` | Anti-slop frontend design enforcement. Overrides LLM biases with three configurable dials (DESIGN_VARIANCE, MOTION_INTENSITY, VISUAL_DENSITY) and 10 sections of strict rules: bans Inter font, AI purple, centered heroes, 3-column cards, pure black, and emoji-as-icons. Enforces Framer Motion spring physics, Bento 2.0 paradigm, magnetic micro-physics, full interaction states (loading/empty/error), and a pre-flight checklist. Source: [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill). |
| `/playwright` | Browser automation via Playwright CLI — screenshots, JS-rendered page scraping, PDF generation, link extraction. Runs `node tools/playwright.js` directly via Bash with no MCP server overhead. Requires `npm install && npx playwright install chromium` on first use. Source: [microsoft/playwright-cli](https://github.com/microsoft/playwright-cli). |
| `/firecrawl` | Web scraping via Firecrawl CLI — scrape single pages to Markdown, web search with optional result scraping, full-site crawls with depth limits, URL mapping, and AI-powered agent extraction. CLI primary (`firecrawl`); `firecrawl-mcp` backup for batch or schema-driven tasks. Requires `npm install -g firecrawl-cli` and `FIRECRAWL_API_KEY`. Source: [firecrawl/cli](https://github.com/firecrawl/cli). |
| `/notebooklm` | Google NotebookLM integration via `nlm` CLI — create notebooks, add sources (URLs, text, Google Drive files), generate AI content (podcasts, videos, briefings, flashcards, infographics, slides), query notebooks with natural language, manage research workflows, share notebooks. CLI primary (`nlm`); `notebooklm-mcp` backup for multi-step interactive flows. Requires `uv tool install notebooklm-mcp-cli` and cookie-based auth via `nlm login`. Source: [jacob-bd/notebooklm-mcp-cli](https://github.com/jacob-bd/notebooklm-mcp-cli). |
| `/three-brain` | Auto-router for multi-model work coordination. Routes tasks invisibly to Claude (standard dev), Codex/GPT-5.5 (review/rescue after 2× failures, risk-path edits to auth/billing/deploy/migrations), or Gemini 2.5 Pro (multimodal analysis, whole-codebase scans). Forced routes trigger on risk paths or repeated failures with one-line announcement before handoff. Requires `codex-cli` (`npm i -g @openai/codex`) and `gemini-cli` (`npm i -g @google/gemini-cli`). |
| `/compact-memory` | Full memory hygiene cycle — compresses `memory-sessions.md` (entries >30 days → archive block), prunes obsolete decisions from `memory-decisions.md`, and syncs 3-5 key project facts to the knowledge graph (memory MCP) for queryable access without loading full files. Run monthly or when memory files exceed ~200 lines. Saves ~100-200 lines per run (~500-1000 tokens/session). |
| `/autoresearch` | Autonomous ML research (karpathy/autoresearch). Agent modifies GPT training code (`train.py`), runs 5-minute experiments on a single GPU, evaluates improvements (lower `val_bpb` = better), keeps successful changes, discards failures, and repeats indefinitely until stopped (~12 experiments/hour, ~100 overnight while you sleep). Requires single NVIDIA GPU (H100 tested; see [tools/autoresearch/README.md](tools/autoresearch/README.md) for other platforms), Python 3.10+, and `uv` package manager. Auto-syncs with upstream karpathy/autoresearch every session via stop hook. Source: [karpathy/autoresearch](https://github.com/karpathy/autoresearch) (33K+ stars). |
| `/lightrag` | Graph-based Retrieval-Augmented Generation (LightRAG). Extracts knowledge graphs from documents (entities + relationships), performs entity-aware Q&A with 5 query modes (naive, local, global, hybrid, mix with reranker), supports multimodal docs (PDFs, images, tables via RAG-Anything), and includes Web UI + REST API for visualization and programmatic access. Requires Python 3.10+, `uv` package manager, and LLM API key (OpenAI, Claude, Gemini, or Ollama). Storage backends: default (nano-vectordb), Neo4J, MongoDB, PostgreSQL, OpenSearch. Source: [HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (EMNLP 2025, 13K+ stars). |
| `/openspace` | Self-evolving skill system (OpenSpace). Skills that automatically learn, fix themselves, and improve over time. Provides 3 evolution modes (FIX: repair broken skills in-place, DERIVED: create enhanced versions, CAPTURED: extract novel patterns from successful executions), quality monitoring that tracks skill/tool/code execution metrics, and cloud skill community for sharing improvements across agents. Token reduction: 46% fewer tokens through skill reuse and evolution. Performance: 4.2× better on professional tasks (GDPVal benchmark). Use for complex multi-step tasks, skill evolution workflows, or accessing cloud skill community. Requires Python 3.12+ and `pip install -e tools/openspace`. Optional: `OPENSPACE_API_KEY` for cloud features (register at open-space.cloud). Source: [HKUDS/OpenSpace](https://github.com/HKUDS/OpenSpace) (13K+ stars). |
| `/delegate-task` | OpenSpace host skill — delegates complex tasks to OpenSpace's grounding agent with automatic skill evolution. Teaches Claude Code when to use `execute_task` vs handling directly, how to interpret OpenSpace results, when to trigger skill evolution (`fix_skill`), and how to upload successful patterns (`upload_skill`). Auto-installed by setup.sh to `~/.claude/skills/delegate-task/`. |
| `/skill-discovery` | OpenSpace host skill — searches local + cloud skills before starting work. Teaches Claude Code when to search for skills (before complex tasks), how to evaluate search results (local vs cloud), decision framework (follow skill yourself, delegate to OpenSpace, or skip), and how to import cloud skills to local registry. Auto-installed by setup.sh to `~/.claude/skills/skill-discovery/`. |

---

## MCP Servers

All servers are defined in `.mcp.json` and enabled in `.claude/settings.json`. Credentials are injected at runtime from the `env` block in `.claude/settings.local.json`.

---
> **Quick setup:** Copy `.claude/settings.local.json.example` → `.claude/settings.local.json`. The `__activation_guide` inside it lists exactly where to get each key and which servers need no key at all.
---
> **Trim this list.** Every enabled server adds tools to your session context. Only keep servers you actively use — remove the rest from `.mcp.json` and `settings.json`.
---

| Server | Transport | `.env` Keys Required | Purpose |
| -------- | ----------- | --------------------- | --------- |
| **memory** | `npx @modelcontextprotocol/server-memory` | — | Persistent knowledge graph across sessions (entities, relations, observations) |
| **supabase-mcp** | `npx @supabase/mcp-server-supabase` | `SUPABASE_API_PAT` | Postgres queries, auth, storage, migrations via Supabase |
| **openrouter-mcp** | `npx @physics91/openrouter-mcp` | `OPENROUTER_API_KEY` | Multi-model LLM routing — chat, compare, benchmark 200+ models |
| **kie-ai** | `npx @felores/kie-ai-mcp-server` | `KIE_AI_API_KEY` | AI media generation: images (Flux, Midjourney, DALL-E), video (Kling, Sora), audio (ElevenLabs) |
| **higgsfield** | `npx mcp-remote https://mcp.higgsfield.ai/mcp` | None (browser OAuth) | AI image & video generation — cinematic video, model exploration, media management |
| **tavily-mcp** | `npx tavily-mcp` | `TAVILY_API_KEY` | Web search, extract, crawl, and deep research |
| **google-workspace-mcp** | `uvx workspace-mcp` | `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_USER_EMAIL` | Gmail, Drive, Sheets, Docs, Calendar, Forms, Chat, Tasks, Contacts |
| **trigger** | `npx trigger.dev mcp` | — (uses Trigger.dev CLI auth) | Deploy, trigger, and monitor Trigger.dev tasks |
| **pinecone-mcp** | `npx @pinecone-database/mcp` | `PINECONE_API_KEY` | Vector search, RAG — upsert, search, rerank, describe indexes |
| **vapi-mcp** | `npx @vapi-ai/mcp-server` | `VAPI_API_TOKEN` | Voice AI — create assistants, make calls, manage phone numbers and tools |
| **notebooklm-mcp** | `uvx --from notebooklm-mcp-cli notebooklm-mcp` | — (cookie auth via `nlm login`) | Google NotebookLM — create notebooks, add sources (URLs, text, Google Drive), generate podcasts/videos/briefings, query notebooks. **CLI (`nlm`) is always the primary tool** — use MCP only for multi-step interactive flows. Run `nlm login` before first use to authenticate with Google. |
| **openspace** | `openspace-mcp` (installed via `pip install -e tools/openspace`) | `OPENSPACE_API_KEY` (optional), `OPENSPACE_HOST_SKILL_DIRS`, `OPENSPACE_WORKSPACE` | Self-evolving skill system — execute tasks with auto skill evolution (FIX/DERIVED/CAPTURED modes), search local + cloud skills, fix broken skills, upload evolved skills to cloud community. **CLI (`openspace`, `openspace-download-skill`, `openspace-upload-skill`) is always the primary tool** — saves ~200-500 tokens per call vs MCP. Use MCP only when structured output parsing or MCP state persistence is needed. 4 MCP tools: `execute_task` (multi-step grounding agent), `search_skills`, `fix_skill`, `upload_skill`. Requires Python 3.12+. **Host skills (`/delegate-task`, `/skill-discovery`) teach Claude Code when/how to use these tools.** Cloud features require `OPENSPACE_API_KEY` from open-space.cloud — local features work without it. Source: [HKUDS/OpenSpace](https://github.com/HKUDS/OpenSpace) (13K+ stars). |
| **alpaca** | `uvx alpaca-mcp-server` | `ALPACA_API_KEY`, `ALPACA_SECRET_KEY` | Algorithmic trading via Alpaca (paper mode enabled by default) |
| **n8n-mcp** | `npx n8n-mcp` | `N8N_HOST_URL`, `N8N_API_KEY` | n8n workflow automation — search nodes, validate, build via MCP |
| **apify** | `npx @apify/actors-mcp-server` | `APIFY_API_PAT` | Web scraping marketplace — search actors, call actors, retrieve results |
| **zep-mcp** | `npx mcp-remote` (remote) | — | Zep long-term memory documentation search |
| **canva-dev** | `npx @canva/cli mcp` | — (browser OAuth) | Canva app SDK, UI kit, CLI docs, design operations |
| **monet-mcp** | SSE remote (`monet.design`) | `MONET_API_KEY` | Landing page UI component library — search by natural language, retrieve full React/TypeScript source code. Tools: `search_components`, `get_component_code`, `get_component_details`, `list_categories`, `get_registry_stats`, `list_collections`, `get_collection`. Categories: hero, pricing, testimonial, feature, cta, faq, footer, gallery, and more. |
| **stitch** | HTTP remote (`stitch.googleapis.com`) | `STITCH_API_KEY` | Google Stitch — extract design DNA (fonts, colors, layouts) from screens; fetch screen HTML/code and images. Tools: `generate_screen_from_text`, `edit_screens`, `get_screen`, `list_screens`, `list_projects`. |
| **21st-dev-magic** | `npx @21st-dev/magic@latest` | `TWENTYFIRST_DEV_API_KEY` | 21st.dev Magic — semantic search across thousands of UI components + SVG brand logos via SVGL (free); build and refine polished UI variants (Pro). Tools: `21st_magic_component_inspiration`, `21st_magic_component_builder`, `21st_magic_component_refiner`, `logo_search`. |
| **playwright-mcp** | `npx @playwright/mcp@latest` | — | Microsoft Playwright MCP — backup for interactive browser sessions (`browser_navigate`, `browser_screenshot`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_pdf_save`). **CLI (`node tools/playwright.js`) is always the primary tool.** Use MCP only when interactive control or JS evaluation is needed. |
| **firecrawl-mcp** | `npx firecrawl-mcp` | `FIRECRAWL_API_KEY` | Firecrawl MCP — backup for batch scraping and schema-driven LLM extraction (`firecrawl_scrape`, `firecrawl_batch_scrape`, `firecrawl_search`, `firecrawl_crawl`, `firecrawl_map`, `firecrawl_agent`, `firecrawl_extract`). **CLI (`firecrawl`) is always the primary tool** — see `/firecrawl` skill and `workflows/web-scraping.md`. |
| **context7** | `npx @upstash/context7-mcp@latest` | `CONTEXT7_API_KEY` | Live SDK/library documentation lookup — fetch on demand instead of loading static reference files |

### Google Workspace Setup

Google Workspace uses OAuth — you need a Google Cloud project with the APIs enabled:

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a project → enable Gmail API, Drive API, Sheets API, etc.
3. Create OAuth 2.0 credentials (Desktop app type)
4. Copy `Client ID` and `Client Secret` to `.env`
5. On first use, a browser window opens for authorization

### Alpaca Paper Trading

`ALPACA_PAPER_TRADE=true` is hardcoded in `.mcp.json`. No real money is at risk. Switch to live trading by setting it to `false` and using live API keys.

---

## Rules (Auto-Loaded Instructions)

Every `.md` file in `.claude/rules/` is injected into every Claude Code session automatically. These shape Claude's behavior without requiring manual prompting.

> **Trim this list.** Each rule file consumes context on every session open. Delete files that don't apply to your project — you can always recreate them from the original repo.

| File | What It Does |
| ------ | ------------- |
| [`agent-instructions.md`](.claude/rules/agent-instructions.md) | WAT framework — how to orchestrate tools, recover from errors, and keep workflows current |
| [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) | Frontend standards: local server, screenshot workflow, anti-generic guardrails, Google Fonts embed guide ['google fonts'](https://fonts.google.com/) |
| [`ui-ux-pro-max-instructions.md`](.claude/docs/ui-ux-pro-max-instructions.md) | Design intelligence database: 67 styles, 161 palettes, 57 font pairings (Google Fonts), 99 UX rules, 25 chart types *(reference-only, not auto-loaded)* |
| [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md) | Step-by-step guide for building Trigger.dev TypeScript automations |
| [`memory-guidelines.md`](.claude/rules/memory-guidelines.md) | When and what to save — auto-update trigger rules for both memory tiers |
| [`memory-profile.md`](.claude/rules/memory-profile.md) | User role, background, domain knowledge (filled in as you work) |
| [`memory-preferences.md`](.claude/rules/memory-preferences.md) | Communication style and workflow preferences (filled in as you work) |
| [`memory-decisions.md`](.claude/rules/memory-decisions.md) | Architectural decisions with dates and rationale |
| [`memory-sessions.md`](.claude/rules/memory-sessions.md) | Log of substantive work completed per session |
| [`karpathy-guidelines.md`](.claude/rules/karpathy-guidelines.md) | Coding behavior rules: think first, simplicity, surgical edits, goal-driven execution |

---

## Hooks & Scripts

### Hooks (`.claude/hooks/`)

Hooks are shell commands wired to Claude Code lifecycle events, configured in `.claude/settings.json`.

| Hook | File | Trigger | Behavior |
| ------ | ------ | --------- | --------- |
| **Setup** | [`setup.sh`](.claude/hooks/setup.sh) | First session open on a new machine | Bootstraps the project (see [Quick Start](#quick-start)) — 16 steps: dependencies, plugins, skills, CLI tools, git submodules, autoresearch setup, lightrag setup, openspace submodule init + installation |
| **Stop** | [`stop.sh`](.claude/hooks/stop.sh) | Every time Claude finishes responding | (1) Auto-syncs `tools/autoresearch/` with upstream via `autoresearch-sync.sh`, (2) auto-syncs `tools/openspace/` git submodule with upstream via `openspace-sync.sh`, (3) auto-drafts memory entries via `memory-drafter.py`, (4) checks if tracked paths changed and prompts doc update |
| **PreToolUse** (Read) | [`read-guard.py`](.claude/hooks/read-guard.py) | Before every Read tool call | Warns when large files (>200 lines) are read without `offset`+`limit` to save tokens; always approves — advisory only |
| **PostToolUse** | [`autosync-docs.sh`](.claude/hooks/autosync-docs.sh) | After every Write/Edit tool call | Checks if the edited file is in a tracked path; if so, injects `additionalContext` telling Claude to update CLAUDE.md/README.md immediately. CLAUDE.md and README.md are excluded to prevent update loops. Logic in `autosync-docs.py`. |
| **pre-commit** (git) | [`pre-commit.sh`](.claude/hooks/pre-commit.sh) | Before every `git commit` | Detects staged changes to tracked paths; auto-runs `claude --print` to update CLAUDE.md and README.md, then stages the updated docs alongside the original changes |
| **autoresearch-sync** | [`autoresearch-sync.sh`](.claude/hooks/autoresearch-sync.sh) | Called by stop.sh every session | Syncs `tools/autoresearch/` with upstream karpathy/autoresearch repo; runs silently if no changes; pulls updates if available; skips if local uncommitted changes exist |
| **openspace-sync** | [`openspace-sync.sh`](.claude/hooks/openspace-sync.sh) | Called by stop.sh every session | Syncs `tools/openspace/` git submodule with upstream HKUDS/OpenSpace repo; pulls latest commits; updates submodule pointer in parent repo; skips if uncommitted changes exist |
| **openspace-sync** | [`openspace-sync.sh`](.claude/hooks/openspace-sync.sh) | Called by stop.sh every session | Syncs `tools/openspace/` git submodule with upstream HKUDS/OpenSpace repo; pulls latest commits; updates submodule pointer in parent repo; skips if uncommitted changes exist |

**`stop.sh` logic:**

1. **Autoresearch sync** — Calls `autoresearch-sync.sh` to pull upstream updates from karpathy/autoresearch if available (silent if no changes)
2. **OpenSpace submodule sync** — Calls `openspace-sync.sh` to pull upstream updates from HKUDS/OpenSpace if available; updates submodule pointer in parent repo (silent if no changes)
3. **Memory auto-draft** — Calls `memory-drafter.py` to scan session transcript for memory signals (decisions, fixes, learnings) and auto-draft memory file updates
4. **Doc-sync check** — If any tracked paths (`.claude/rules/`, `.claude/hooks/`, `.claude/scripts/`, `.mcp.json`, `workflows/`, `tools/`, etc.) were modified during the session → reports the count and prompts a manual or commit-triggered doc sync
5. Always approves (never blocks completion)

**`pre-commit.sh` logic:**

- Runs only when tracked paths are staged: `.claude/rules/`, `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `.claude/scripts/`, `.mcp.json`, `workflows/`, `tools/`
- If CLAUDE.md or README.md is already staged, assumes a manual update was done and skips auto-sync
- Calls `claude --print` with a targeted prompt to update only the sections of CLAUDE.md and README.md that reference the changed files
- Stages the updated docs automatically so they land in the same commit
- Fails gracefully (exits 0 with a warning) if the `claude` CLI is not found — never blocks a commit

### Scripts (`.claude/scripts/`)

| Script | Purpose |
| -------- | --------- |
| [`autosync-docs.py`](.claude/scripts/autosync-docs.py) | Python logic for `autosync-docs.sh` — path matching and `additionalContext` JSON output |
| [`context-monitor.py`](.claude/scripts/context-monitor.py) | Powers the statusline — reads session transcript, parses token usage, renders colored bar |
| [`memory-drafter.py`](.claude/scripts/memory-drafter.py) | Scans session transcript for memory signals (decisions, fixes, user preferences); auto-drafts memory file updates at session end (called by `stop.sh`) |

---

## Context Monitor Statusline

The statusline renders in the Claude Code interface and shows real-time session data:

```text
[claude-sonnet-4-6] 📁 project | 🌿 main (3) | 🧠 🟢 ████▁▁▁▁ 42% | 💰 $0.012 ⏱ 8m
```

| Segment | What It Shows |
| --------- | -------------- |
| `[claude-sonnet-4-6]` | Active model (color shifts yellow → red as context fills) |
| `📁 project` | Current directory name |
| `🌿 main (3)` | Git branch + number of uncommitted changes (green = clean, red = dirty) |
| `🧠 ████▁▁▁▁ 42%` | Context window fill — green → yellow → orange → red → 🚨 CRIT |
| `💰 $0.012` | Session cost in USD |
| `⏱ 8m` | Session duration |

**Requirements:** Python 3.8+ in PATH (uses only standard library — no pip installs needed).

**If the statusline shows an error**, reinstall it:

```bash
npx claude-code-templates@latest --setting statusline/context-monitor
```

---

## WAT Framework

The core architecture pattern used throughout this project:

```text
Workflows  →  Agents (Claude)  →  Tools
(what to do)  (how to decide)   (how to execute)
```

- **Workflows** (`workflows/`) — Markdown SOPs defining objectives, required inputs, tool sequence, expected outputs, and edge cases
- **Agents** — Claude: reads workflows, makes decisions, orchestrates tools, handles failures
- **Tools** (`tools/`) — Python scripts doing deterministic work: API calls, data transforms, file ops

**Why it matters:** AI chained through 5 steps at 90% accuracy = 59% end-to-end success. Offloading execution to deterministic scripts keeps Claude focused on orchestration where it excels.

**Trigger.dev** (`src/trigger/`) — TypeScript tasks extend the Tools layer for cloud-based, scheduled, and event-driven execution. See [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md) and [`trigger-api-reference.md`](.claude/docs/trigger-api-reference.md).

---

## Memory System

Two tiers of persistent memory work together across sessions.

### Tier 1: File-Based Memory (`.claude/rules/memory-*.md`)

Markdown files auto-loaded every session. Best for narrative, human-readable context.

| File | Stores |
| ------ | -------- |
| `memory-profile.md` | User role, background, domain knowledge |
| `memory-preferences.md` | Communication style, workflow preferences |
| `memory-decisions.md` | Architecture decisions with dates |
| `memory-sessions.md` | Session log of substantive work |

Claude updates these files automatically (no prompting needed) when you share facts, preferences, or decisions.

### Tier 2: Knowledge Graph (memory MCP server)

A persistent graph database of entities, relations, and observations — queryable by name or relationship across sessions.

| Use case | Tier |
| ---------- | ------ |
| "User prefers concise responses" | File-based |
| "We chose Supabase over PlanetScale on 2026-04-07" | File-based |
| "This project uses the `jobs` table in Supabase" | Knowledge graph |
| "The `scraper` service depends on `apify` and outputs to `supabase`" | Knowledge graph |

### Context Optimization Features

The framework includes several automated features to minimize token consumption:

| Feature | How It Works | Token Savings |
| --------- | ------------- | --------------- |
| **Reference docs on demand** | `ui-ux-pro-max-instructions.md` and `trigger-api-reference.md` moved to `.claude/docs/` (not auto-loaded). Frontend/Trigger work loads them on demand via rule file references. | ~1700 tokens/session when not doing frontend or Trigger work |
| **Read-guard hook** | Warns when large files (>200 lines) are read without `offset`+`limit` parameters. Advisory only — never blocks. | Prevents accidental full-file reads |
| **Memory compression** | `/compact-memory` skill compresses old sessions (>30 days) into archive block, prunes obsolete decisions. Run monthly or when memory files exceed ~200 lines. | ~100-200 lines (~500-1000 tokens) per run |
| **Knowledge graph memory** | Store structured facts in memory MCP graph instead of narrative files. Query by name/relationship without loading full files. | Queryable facts don't consume session context |
| **Auto-drafted memory cleanup** | `memory-drafter.py` (Stop hook) auto-drafts memory entries from session transcript. Review and merge/delete at session end to prevent draft accumulation. | Prevents memory file bloat from unreviewed drafts |
| **CLI-first architecture** | Playwright, Firecrawl, NotebookLM use direct CLI execution (token-free) with MCP as backup for interactive flows only. | Eliminates MCP protocol overhead for single-shot operations |

**Monthly maintenance:** Run `/compact-memory` when `memory-sessions.md` exceeds ~200 lines or after ~30 days.

---

## LightRAG Server Setup

**LightRAG** is a graph-based RAG (Retrieval-Augmented Generation) system that extracts knowledge graphs from documents for entity-relationship-aware Q&A. Includes Web UI, REST API, and knowledge graph visualization.

**Source:** [github.com/HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (EMNLP 2025, 13K+ stars)

### LightRAG Quick Start

```bash
# 1. Navigate to LightRAG directory
cd tools/lightrag

# 2. Install dependencies
uv sync

# 3. Configure API key
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY

# 4. Start server (choose one method below)
```

### Starting the Server

**Method 1: VSCode Debug (Recommended)**  

1. Press `F5` (or Run → Start Debugging)
2. Select "**LightRAG Server**" from dropdown
3. Browser automatically opens at [LightRAG Server](http://localhost:9621)
4. Full debugging support with breakpoints

**Method 2: Quick Start Script (Windows)**  

```bash
cd tools/lightrag
./start_server.bat
```

**Method 3: Command Line**  

```bash
cd tools/lightrag
uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage
```

### Access Points

- [Web UI](http://localhost:9621) (knowledge graph visualization, insert/query forms)
- [API Documentation](http://localhost:9621/docs) (Swagger UI)
- [Alternative Docs](http://localhost:9621/redoc) (ReDoc)

### Configuration

The `tools/lightrag/.env` file controls all server settings:

```ini
# Required
OPENAI_API_KEY=your-api-key-here

# LLM Configuration
LLM_BINDING=openai              # Options: openai, anthropic, gemini, ollama
LLM_MODEL=gpt-4o-mini

# Embedding Configuration
EMBEDDING_BINDING=openai
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIM=1536

# Server Settings
HOST=0.0.0.0
PORT=9621
```

**Alternative LLM Providers:**

- **Anthropic Claude:** Set `LLM_BINDING=anthropic` + `ANTHROPIC_API_KEY`
- **Google Gemini:** Set `LLM_BINDING=gemini` + `GEMINI_API_KEY`
- **Local Ollama:** Set `LLM_BINDING=ollama` + `OLLAMA_HOST=http://localhost:11434`

### VSCode Debug Configurations

`.vscode/launch.json` includes 4 individual configs + 1 compound config:

**Individual Configurations:**

1. **LightRAG Server**
   - Starts web server on port 9621
   - Auto-opens browser when ready
   - Loads environment from `tools/lightrag/.env`
   - UTF-8 encoding enabled (fixes Windows Unicode issues)

2. **LightRAG Test Script**
   - Runs `test_lightrag.py` (insert/query example)
   - Uses same `.env` configuration
   - Good for testing API integration

3. **OpenSpace Backend Server**
   - Starts dashboard API on port 7788
   - Debuggable Python Flask server
   - Can be launched individually

4. **OpenSpace Frontend**
   - Starts Vite dev server on port 3789
   - Auto-opens browser when ready
   - Automatically checks/installs dependencies before launch
   - Can be launched individually (requires backend running first)

5. **OpenSpace Dashboard (Full Stack)** ⭐ **Compound Configuration Recommended**
   - **One-click launch** — starts both backend and frontend together
   - Automatically verifies and installs frontend dependencies if missing
   - Auto-opens browser to [Frontend UI](http://127.0.0.1:3789) when ready
   - Stops both servers when you click the Stop button
   - **Usage:** Press `F5` → Select "**OpenSpace Dashboard (Full Stack)**"
   - [Backend API](http://127.0.0.1:7788) | [Frontend UI](http://127.0.0.1:3789)

### Testing the Setup

Run the test script to verify everything works:

```bash
cd tools/lightrag
uv run python test_lightrag.py
```

Expected output:

```text
[1/4] Initializing LightRAG...
[2/4] Initializing storage...
[3/4] Inserting test document...
      Document inserted successfully!
[4/4] Querying: 'What is LightRAG?'
================================================================================
QUERY RESULT:
================================================================================
LightRAG is a graph-based Retrieval-Augmented Generation system...
```

### Features

- **Knowledge Graph Extraction:** Automatically extracts entities and relationships
- **Multiple Query Modes:** naive, local, global, hybrid, mix (with reranker)
- **Storage Backends:** Default (nano-vectordb), Neo4J, MongoDB, PostgreSQL, OpenSearch
- **Multimodal Support:** Process PDFs, Office docs, images, tables
- **Web UI:** Visual knowledge graph explorer with filtering and search
- **REST API:** Programmatic access for integration with other tools

### Dependencies

The following packages are automatically installed by `uv sync`:

- `lightrag-hku>=0.1.0` — Core library
- `fastapi>=0.115.0` + `uvicorn>=0.32.0` — Web server
- `openai>=1.0.0` — OpenAI integration
- `pyjwt>=2.0.0`, `bcrypt>=4.0.0`, `passlib>=1.7.4` — Authentication
- `python-multipart>=0.0.6` — File upload support
- `aiofiles>=24.0.0` — Async file operations

### Troubleshooting

**Port already in use:**

```powershell
# Stop any process using port 9621
Get-NetTCPConnection -LocalPort 9621 | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }
```

**API key not found:**

- Verify `OPENAI_API_KEY` is set in `tools/lightrag/.env`
- Check that `.env` file exists (not just `.env.example`)
- Restart the server after editing `.env`

**Unicode errors on Windows:**

- The VSCode debug config sets `PYTHONIOENCODING=utf-8` automatically
- For command line: `$env:PYTHONIOENCODING="utf-8"` before starting server

---

## Reference Docs

Reference documents ship in `.claude/docs/` and are available as context within sessions:

| File | Contents |
| ------ | --------- |
| [`Claude_Code_Beginners_Guide.md`](.claude/docs/Claude_Code_Beginners_Guide.md) | End-to-end walkthrough of Claude Code for new users |
| [`Claude_Code_Context_Management_Hacks.md`](.claude/docs/Claude_Code_Context_Management_Hacks.md) | Techniques for managing the context window effectively |
| [`The_Shift_to_Agentic_AI_Workflows.md`](.claude/docs/The_Shift_to_Agentic_AI_Workflows.md) | Conceptual foundation for agentic AI architecture |
| [`trigger-api-reference.md`](.claude/docs/trigger-api-reference.md) | Full Trigger.dev SDK v4 code patterns, task definitions, schedules, waits, and critical rules |

---

## License

MIT License — Copyright (c) 2026 Roentek Designs. See [LICENSE](LICENSE) for details.
