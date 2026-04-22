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
- **Plugins** — Extend Claude Code with specialized modes (superpowers, frontend-design, agent-sdk, etc.)
- **Skills** — Reusable slash commands you invoke with `/skill-name`
- **MCP Servers** — 15 pre-configured Model Context Protocol integrations (Supabase, Google Workspace, Pinecone, Trigger.dev, n8n, Vapi, Apify, Alpaca, Monet, and more)
- **Hooks** — Lifecycle shell scripts that run on session start, stop, and tool events
- **Scripts** — A context monitor statusline and a first-time setup bootstrapper
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
| Not building frontend UI | `frontend-instructions.md`, `ui-ux-pro-max-instructions.md` |
| Not using Trigger.dev | `trigger-workflow-builder.md`, `trigger-api-reference.md` |
| Not using the WAT agent pattern | `agent-instructions.md` |

The four `memory-*.md` files are always worth keeping — they hold your project's accumulated context.

#### Skills (`.claude/skills/`)

Delete any `.md` skill files you didn't create and don't plan to use. Skills only fire when invoked, so unused skills don't hurt performance — but removing them keeps the project clean.

### Step 3 — Add what your project needs

Once trimmed, add only the tools you actually need:

- **New MCP server**: add a block to `.mcp.json`, enable it in `settings.json`, add credentials to `.env`
- **New rule**: create a `.md` file in `.claude/rules/` — it auto-loads next session
- **New skill**: create a `.md` file in `.claude/skills/` — it becomes `/skill-name` instantly
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
| **uv / uvx** | Google Workspace MCP and Alpaca MCP use `uvx` | See below |

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

On first open, a `Setup` hook automatically runs `.claude/scripts/setup.sh`, which:

1. **Makes hooks executable** — `chmod +x` on `stop.sh` and `pre-commit.sh` (Unix/macOS only)
2. **Verifies Python** — checks `python3` / `python` is in PATH
3. **Verifies context-monitor.py** — confirms the statusline script is present
4. **Creates `.env`** — copies `.env.example` → `.env` if none exists
5. **Verifies uvx** — required for `google-workspace-mcp` and `alpaca` MCP servers
6. **Verifies npx** — required for the `memory` MCP server
7. **Installs marketplace plugins** — attempts to auto-install `ui-ux-pro-max` and `andrej-karpathy-skills` via CLI
8. **Installs pre-commit hook** — writes a thin wrapper to `.git/hooks/pre-commit` pointing to `.claude/hooks/pre-commit.sh`
9. **Writes a marker** — creates `.claude/.setup-complete` so setup only runs once per machine

**Re-run setup manually** (e.g. fresh clone on a new machine):

```bash
rm -f .claude/.setup-complete && bash .claude/scripts/setup.sh
```

**If setup never ran automatically**, run it directly:

```bash
bash .claude/scripts/setup.sh
```

---

## Project Structure

```txt
.
├── CLAUDE.md                        # Session rules: philosophy, routing table, memory triggers
├── README.md                        # This file
├── .env                             # Your API keys (gitignored — never commit)
├── .env.example                     # Template for all required keys
├── .mcp.json                        # MCP server definitions (version-controlled)
├── .gitignore
├── LICENSE
│
├── .claude/
│   ├── settings.json                # Permissions, enabled plugins, hooks, statusline
│   ├── settings.local.json          # Machine-local permissions (gitignored)
│   ├── agents/                      # Custom sub-agent definitions (.md files)
│   ├── docs/                        # Reference docs loaded with the project
│   │   ├── Claude_Code_Beginners_Guide.md
│   │   ├── Claude_Code_Context_Management_Hacks.md
│   │   └── The_Shift_to_Agentic_AI_Workflows.md
│   ├── hooks/
│   │   ├── stop.sh                  # Stop hook: quality scan + doc-sync check at session end
│   │   └── pre-commit.sh            # Pre-commit hook: auto-updates CLAUDE.md/README.md for tracked-path changes
│   ├── rules/                       # Auto-loaded Markdown instructions (every session)
│   │   ├── agent-instructions.md
│   │   ├── frontend-instructions.md
│   │   ├── ui-ux-pro-max-instructions.md
│   │   ├── trigger-workflow-builder.md
│   │   ├── trigger-api-reference.md
│   │   ├── memory-guidelines.md
│   │   ├── memory-profile.md
│   │   ├── memory-preferences.md
│   │   ├── memory-decisions.md
│   │   ├── memory-sessions.md
│   │   └── karpathy-guidelines.md
│   ├── scripts/
│   │   ├── setup.sh                 # First-time machine setup bootstrapper
│   │   └── context-monitor.py       # Statusline: context %, cost, git branch, duration
│   └── skills/                      # Project-local slash-command skills (.md files)
│
├── brand_assets/                    # Logos, color guides, design tokens
├── docs/                            # Project-level documentation
├── src/
│   └── trigger/                     # Trigger.dev TypeScript task files
├── tools/                           # Python scripts for deterministic execution
├── workflows/                       # Markdown SOPs defining automation tasks
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

Machine-local permissions and overrides — gitignored. Add tool call pre-approvals specific to your local environment (e.g., local MCP server tools) without committing them to the repo. Keeps project-wide `settings.json` clean of machine-specific noise.

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

### Installing Third-Party Marketplace Plugins

The two third-party plugins below are enabled in `settings.json` but must be installed before they activate. `setup.sh` attempts to install them automatically via the CLI — if that fails, run these slash commands inside a Claude Code chat session:

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
| **agent-sdk-dev** | `agent-sdk-dev@claude-plugins-official` | Agent scaffolding — creates Claude sub-agent definitions |
| **claude-code-setup** | `claude-code-setup@claude-plugins-official` | Project bootstrapping and Claude Code automation recommendations |
| **claude-md-management** | `claude-md-management@claude-plugins-official` | CLAUDE.md creation, auditing, and improvement |
| **playground** | `playground@claude-plugins-official` | Sandboxed HTML explorers for testing prompts and tool chains |

### Disabled Plugins (enable in `settings.json`)

| Plugin | Why disabled by default |
| --- | --- |
| `github@claude-plugins-official` | Only needed if using GitHub-specific workflows |
| `pinecone@claude-plugins-official` | Pinecone is already available via MCP server |
| `supabase@claude-plugins-official` | Supabase is already available via MCP server |
| `plugin-dev@claude-plugins-official` | Only needed when authoring new plugins |

---

## Skills (Slash Commands)

Skills are Markdown files that expand into full instructions when invoked. Project-local skills live in `.claude/skills/` — any `.md` file you add there becomes a `/skill-name` command automatically.

### Core Skills (always available)

| Slash Command | What It Does |
| -------------- | ------------- |
| `/frontend-design` | Mandatory first step before writing any frontend code. Activates design system generation. |
| `/claude-api` | Scaffolds an app using the Anthropic SDK or Claude Agent SDK with prompt caching. |
| `/simplify` | Reviews recently changed code for reuse, quality, and efficiency — then fixes issues found. |
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

| Slash Command | What It Does |
| -------------- | ------------- |
| `/site-teardown [url]` | Reverse engineers any website into a complete build blueprint — tech stack, every visual effect with implementation details, full design system (colors, typography, spacing), and a section-by-section build plan ready to hand off to a fresh Claude Code session. |

---

## MCP Servers

All servers are defined in `.mcp.json` and enabled in `.claude/settings.json`. Add the required keys to `.env` for each server you use.

> **Trim this list.** Every enabled server adds tools to your session context. Only keep servers you actively use — remove the rest from `.mcp.json` and `settings.json`.

| Server | Transport | `.env` Keys Required | Purpose |
| -------- | ----------- | --------------------- | --------- |
| **memory** | `npx @modelcontextprotocol/server-memory` | — | Persistent knowledge graph across sessions (entities, relations, observations) |
| **supabase-mcp** | `npx @supabase/mcp-server-supabase` | `SUPABASE_API_PAT` | Postgres queries, auth, storage, migrations via Supabase |
| **openrouter-mcp** | `npx @physics91/openrouter-mcp` | `OPENROUTER_API_KEY` | Multi-model LLM routing — chat, compare, benchmark 200+ models |
| **kie-ai** | `npx @felores/kie-ai-mcp-server` | `KIE_AI_API_KEY` | AI media generation: images (Flux, Midjourney, DALL-E), video (Kling, Sora), audio (ElevenLabs) |
| **tavily-mcp** | `npx tavily-mcp` | `TAVILY_API_KEY` | Web search, extract, crawl, and deep research |
| **google-workspace-mcp** | `uvx workspace-mcp` | `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_USER_EMAIL` | Gmail, Drive, Sheets, Docs, Calendar, Forms, Chat, Tasks, Contacts |
| **trigger** | `npx trigger.dev mcp` | — (uses Trigger.dev CLI auth) | Deploy, trigger, and monitor Trigger.dev tasks |
| **pinecone-mcp** | `npx @pinecone-database/mcp` | `PINECONE_API_KEY` | Vector search, RAG — upsert, search, rerank, describe indexes |
| **vapi-mcp** | `npx @vapi-ai/mcp-server` | `VAPI_API_TOKEN` | Voice AI — create assistants, make calls, manage phone numbers and tools |
| **alpaca** | `uvx alpaca-mcp-server` | `ALPACA_API_KEY`, `ALPACA_SECRET_KEY` | Algorithmic trading via Alpaca (paper mode enabled by default) |
| **n8n-mcp** | `npx n8n-mcp` | `N8N_HOST_URL`, `N8N_API_KEY` | n8n workflow automation — search nodes, validate, build via MCP |
| **apify** | `npx @apify/actors-mcp-server` | `APIFY_API_PAT` | Web scraping marketplace — search actors, call actors, retrieve results |
| **zep-mcp** | `npx mcp-remote` (remote) | — | Zep long-term memory documentation search |
| **canva-dev** | `npx @canva/cli mcp` | — (browser OAuth) | Canva app SDK, UI kit, CLI docs, design operations |
| **monet-mcp** | SSE remote (`monet.design`) | `MONET_API_KEY` | Landing page UI component library — search by natural language, retrieve full React/TypeScript source code. Tools: `search_components`, `get_component_code`, `get_component_details`, `list_categories`, `get_registry_stats`, `list_collections`, `get_collection`. Categories: hero, pricing, testimonial, feature, cta, faq, footer, gallery, and more. |

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
| [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) | Frontend standards: local server, screenshot workflow, anti-generic guardrails |
| [`ui-ux-pro-max-instructions.md`](.claude/rules/ui-ux-pro-max-instructions.md) | Design intelligence database: 67 styles, 161 palettes, 57 fonts, 99 UX rules, 25 chart types |
| [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md) | Step-by-step guide for building Trigger.dev TypeScript automations |
| [`trigger-api-reference.md`](.claude/rules/trigger-api-reference.md) | Full Trigger.dev SDK v4 code patterns, examples, and critical rules |
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
| **Setup** | `setup.sh` | First session open on a new machine | Bootstraps the project (see [Quick Start](#quick-start)) |
| **Stop** | `stop.sh` | Every time Claude finishes responding | Scans session output for fixes/discoveries; checks if tracked paths changed and prompts doc update |
| **pre-commit** (git) | `pre-commit.sh` | Before every `git commit` | Detects staged changes to tracked paths; auto-runs `claude --print` to update CLAUDE.md and README.md, then stages the updated docs alongside the original changes |

**`stop.sh` logic:**

- If the session contains words like `fixed`, `workaround`, `turns out`, `discovered` → suggests running `/reflect` to capture learnings
- If the session contains softer signals like `error`, `bug`, `issue` → gentle nudge to update docs
- If any tracked paths (`.claude/rules/`, `.claude/hooks/`, `.claude/scripts/`, `.mcp.json`, `workflows/`, `tools/`, etc.) were modified during the session → reports the count and prompts a manual or commit-triggered doc sync
- Always approves (never blocks completion)

**`pre-commit.sh` logic:**

- Runs only when tracked paths are staged: `.claude/rules/`, `.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `.claude/scripts/`, `.mcp.json`, `workflows/`, `tools/`
- If CLAUDE.md or README.md is already staged, assumes a manual update was done and skips auto-sync
- Calls `claude --print` with a targeted prompt to update only the sections of CLAUDE.md and README.md that reference the changed files
- Stages the updated docs automatically so they land in the same commit
- Fails gracefully (exits 0 with a warning) if the `claude` CLI is not found — never blocks a commit

### Scripts (`.claude/scripts/`)

| Script | Purpose |
| -------- | --------- |
| [`setup.sh`](.claude/scripts/setup.sh) | First-time machine setup: chmod hooks, verify Python, check context-monitor, create `.env` |
| [`context-monitor.py`](.claude/scripts/context-monitor.py) | Powers the statusline — reads session transcript, parses token usage, renders colored bar |

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

**Trigger.dev** (`src/trigger/`) — TypeScript tasks extend the Tools layer for cloud-based, scheduled, and event-driven execution. See [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md) and [`trigger-api-reference.md`](.claude/rules/trigger-api-reference.md).

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

---

## Reference Docs

Reference documents ship in `.claude/docs/` and are available as context within sessions:

| File | Contents |
| ------ | --------- |
| [`Claude_Code_Beginners_Guide.md`](.claude/docs/Claude_Code_Beginners_Guide.md) | End-to-end walkthrough of Claude Code for new users |
| [`Claude_Code_Context_Management_Hacks.md`](.claude/docs/Claude_Code_Context_Management_Hacks.md) | Techniques for managing the context window effectively |
| [`The_Shift_to_Agentic_AI_Workflows.md`](.claude/docs/The_Shift_to_Agentic_AI_Workflows.md) | Conceptual foundation for agentic AI architecture |

---

## License

MIT License — Copyright (c) 2026 Roentek Designs. See [LICENSE](LICENSE) for details.
