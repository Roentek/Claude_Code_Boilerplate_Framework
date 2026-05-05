# Claude-Code Boilerplate Framework

Defines **how we work**, not what we're building. If a rule doesn't change behavior, it doesn't belong here.

---

## What Are You Building?

| Building | Start With | Key Rules |
| -------- | ---------- | --------- |
| Trigger.dev automation | `workflows/` → `tools/` | [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md), [`trigger-api-reference.md`](.claude/docs/trigger-api-reference.md) |
| Frontend UI | `/frontend-design` skill → `ui-ux-pro-max` design system | [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) |
| WebGPU / Three.js app | `/webgpu-threejs-tsl` skill | Three.js r171+ with WebGPU renderer, TSL shaders |
| Claude AI agent | `agent-sdk-dev` plugin → `.claude/agents/` | [`agent-instructions.md`](.claude/rules/agent-instructions.md) |
| Autonomous ML research (overnight experiments) | `/autoresearch` skill → `tools/autoresearch/` | Modify GPT training code, run 5-min experiments, keep improvements — ~100 runs while you sleep |
| AI-native CLI for existing software | `/cli-anything` plugin | Generate CLIs for GIMP, Blender, LibreOffice, Audacity, etc. — 50+ apps supported |
| Slash-command skill | `~/.claude/skills/<name>/SKILL.md` | Skills must be subdirectory + `SKILL.md`; `setup.sh` auto-installs |
| MCP server integration | `.mcp.json` + `.claude/settings.local.json` | Copy `settings.local.json.example` → `settings.local.json`, fill keys, restart |
| Claude API / SDK app | `/claude-api` skill | Scaffolds Anthropic SDK boilerplate |
| NotebookLM research / podcasts | `/notebooklm` skill → `nlm` CLI | Create notebooks, add sources, generate podcasts/videos/briefings — CLI first; `notebooklm-mcp` as backup |
| n8n workflow | `n8n-mcp` tools | Search nodes, validate, build via MCP |
| Voice AI (Vapi) | `vapi-mcp` tools | Create assistants, calls, phone numbers |
| Browser automation | `/playwright` skill → `tools/playwright.js` | `workflows/browser-automation.md` — CLI first; `playwright-mcp` as backup |
| Web scraping (single page / crawl) | `/firecrawl` skill → `firecrawl` CLI | `workflows/web-scraping.md` — CLI first; `firecrawl-mcp` backup for batch/schema |
| Web scraping (large-scale / actors) | `apify` MCP | Search actors, fetch details, call actors |
| Vector search / RAG | `pinecone-mcp` tools | Upsert, search, rerank records |
| Graph-based RAG / knowledge extraction | `/lightrag` skill → `tools/lightrag/` | Knowledge graph RAG, entity-relationship Q&A, multimodal docs — Web UI + REST API |
| UI component search | `monet-mcp` tools | Search landing page components, get React/TS code |
| UI component inspiration / SVG logos | `21st-dev-magic` tools | Search UI components, SVG brand logos, generate variants |
| AI image/video (cinematic, managed) | `higgsfield` MCP | No API key — browser OAuth; cinematic video, media library |
| AI image/video/audio (specific model) | `kie-ai` MCP | Midjourney, Sora, ElevenLabs, Kling, Suno, etc. Requires API key |
| Self-evolving AI skills / collective intelligence | `/openspace` skill → `openspace` CLI | Skills that auto-fix, auto-improve, auto-learn; 46% token reduction; cloud skill sharing — **CLI first; MCP backup** |

---

## Key Commands

```bash
# Trigger.dev — start local dev runner
npx trigger.dev@latest dev

# Re-run first-time setup (e.g. fresh clone)
rm -f .claude/.setup-complete && bash .claude/hooks/setup.sh

# Reinstall context-monitor statusline
npx claude-code-templates@latest --setting statusline/context-monitor

# Browser automation (WAT Tools layer example)
node tools/playwright.js screenshot https://example.com

# NotebookLM — authenticate and create research notebook
nlm login
nlm notebook create "Research Project"
nlm source add <notebook-id> --url "https://example.com"
nlm audio create <notebook-id> --confirm

# Upgrade NotebookLM CLI
uv tool upgrade notebooklm-mcp-cli

# AutoResearch — autonomous ML experiments
cd tools/autoresearch
uv run prepare.py              # One-time data prep (~2 min)
uv run train.py                # Test baseline run (~5 min)
# Then use /autoresearch skill to start autonomous research loop

# LightRAG — graph-based RAG
cd tools/lightrag
uv sync                                    # Install dependencies
cp .env.example .env                       # Copy environment template
# Edit .env and add your OPENAI_API_KEY

# Option 1: Start via VSCode (recommended)
# Press F5 → Select "LightRAG Server" → Browser opens automatically at http://localhost:9621

# Option 2: Start via command line
uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage

# Option 3: Quick start script (Windows)
./start_server.bat

# OpenSpace — self-evolving skill system (CLI first, MCP backup)
# Git submodule — auto-syncs with upstream every session via openspace-sync.sh hook
cd tools/openspace
pip install -e .                           # Install OpenSpace (done by setup.sh)

# CLI (primary — token-free execution)
openspace --query "Create a monitoring dashboard for Docker containers"
openspace --search "docker monitoring"   # Search skills before starting work
openspace-download-skill <skill_id>      # Download from cloud
openspace-upload-skill /path/to/skill/dir # Upload to cloud (requires OPENSPACE_API_KEY)

# MCP (backup — use when CLI output insufficient or need structured results)
# Use mcp__openspace__* tools via ToolSearch when CLI doesn't meet needs

# Submodule updates (automatic via stop hook, or manual)
git submodule update --remote tools/openspace  # Manual: pull latest from upstream

# Dashboard (optional — requires Node.js ≥ 20)
# Option 1: VSCode one-click launch (recommended)
# Press F5 → Select "OpenSpace Dashboard (Full Stack)" → Starts both backend + frontend

# Option 2: VSCode individual launch
# Press F5 → Select "OpenSpace Backend Server" → http://127.0.0.1:7788
# Then F5 → Select "OpenSpace Frontend" → Browser opens at http://127.0.0.1:3789

# Option 3: Manual terminal launch
openspace-dashboard --host 127.0.0.1 --port 7788  # Terminal 1: Backend
cd tools/openspace/frontend
cp .env.example .env                              # First-time only (setup.sh does this)
npm install                                        # First-time only (setup.sh does this)
npm run dev                                        # Terminal 2: Frontend → http://127.0.0.1:3789
```

> **MCP credential gotcha:** `.mcp.json` `${VAR}` substitution reads from the **OS process environment**, not `.env`. On a fresh machine, run `setx VAR_NAME "value"` (Windows) or `export VAR_NAME=value` (Unix) in your terminal before starting Claude Code.

---

## First-Time Setup

```bash
# 1. Install dependencies
npm install

# 2. Run initial setup (hooks, skills, permissions, CLI tools, git submodules)
bash .claude/hooks/setup.sh
# Installs: marketplace plugins (ui-ux-pro-max, impeccable, codex, gemini, cli-anything),
#           project skills, npm deps, Playwright browser,
#           skillui, firecrawl-cli, codex-cli, gemini-cli, notebooklm-mcp-cli,
#           autoresearch dependencies in tools/autoresearch/ (via uv sync),
#           lightrag dependencies in tools/lightrag/ (via uv sync),
#           openspace submodule initialization + pip install -e . + dashboard frontend npm install

# 3. Configure MCP credentials
cp .claude/settings.local.json.example .claude/settings.local.json
# Edit settings.local.json and add your API keys (see __activation_guide inside)

# 4. Add API keys to .env
cp .env.example .env
# Edit .env and fill in required keys
# Note: OpenSpace paths (OPENSPACE_HOST_SKILL_DIRS, OPENSPACE_WORKSPACE) are
# auto-configured by setup.sh for your platform — no manual editing needed

# 5. Restart Claude Code to activate MCP servers
```

**First run check:**

```bash
# If setup.sh was already run, you'll see:
cat .claude/.setup-complete
```

**Converting existing OpenSpace clone to submodule:**

If you cloned OpenSpace before the submodule setup, see [`.claude/docs/openspace-submodule-conversion.md`](.claude/docs/openspace-submodule-conversion.md) for conversion instructions.

---

## Core Philosophy: WAT Framework

```text
Workflows → Agents (Claude) → Tools
```

AI chained through 5 steps at 90% accuracy = 59% success. Offload execution to deterministic scripts in `tools/`; keep Claude focused on orchestration. Full details: [`agent-instructions.md`](.claude/rules/agent-instructions.md)

---

## Project Structure

```txt
CLAUDE.md                     ← You are here (routing only)
.claude/
  rules/                      ← Auto-loaded every session (all .md files)
  agents/                     ← Custom sub-agent definitions
  skills/                     ← Project skills (<name>/SKILL.md) — setup.sh installs to ~/.claude/skills/
  hooks/                      ← Lifecycle shell scripts (Stop, PostToolUse, pre-commit)
  scripts/                    ← Utility scripts (statusline, context monitor)
  docs/                       ← Reference docs
  settings.local.json         ← Machine-local credentials + permissions (gitignored)
  settings.local.json.example ← Template: all keys cleared + activation guide per MCP server
.mcp.json                     ← MCP server definitions (version-controlled)
.env / .env.example           ← API keys (gitignored — never commit)
tools/                        ← Deterministic execution scripts (Python/Node)
  playwright.js               ← Browser automation CLI wrapper
  autoresearch/               ← Autonomous ML research (prepare.py, train.py, program.md)
  lightrag/                   ← Graph-based RAG server
    pyproject.toml            ← Dependencies (lightrag-hku + server deps)
    uv.lock                   ← Dependency lockfile
    README.md                 ← Full LightRAG documentation
    .env                      ← Server config + OPENAI_API_KEY (gitignored)
    .env.example              ← Template (safe to commit)
    .gitignore                ← Excludes .env, logs, rag_storage
    test_lightrag.py          ← Test script (insert/query example)
    start_server.bat          ← Windows quick launcher
    rag_storage/              ← Knowledge graph data (gitignored, auto-created)
  openspace/                  ← Self-evolving skill system (git submodule — auto-syncs with upstream)
    openspace/                ← Core Python package
    pyproject.toml            ← Dependencies (litellm, anthropic, openai, etc.)
    README.md                 ← Full OpenSpace documentation
    frontend/                 ← Dashboard UI (optional, requires Node.js ≥ 20)
    gdpval_bench/             ← Benchmark experiments & results
    showcase/                 ← Example projects built with OpenSpace
    .openspace/               ← Skill database + embeddings cache
    logs/                     ← Execution logs & recordings
workflows/                    ← Markdown SOPs defining automation tasks
src/trigger/                  ← Trigger.dev TypeScript task files
brand_assets/                 ← Logos, color guides, design tokens
docs/                         ← Project-level documentation
.tmp/                         ← Scratch space — disposable
```

---

## Plugins (Enabled)

| Plugin | Use When |
| ------ | -------- |
| `frontend-design` | Building any UI — **always invoke before writing frontend code** |
| `ui-ux-pro-max` | Every frontend task — run `--design-system` before writing any UI code |
| `agent-sdk-dev` | Creating custom Claude sub-agents |
| `claude-code-setup` | Bootstrapping a new Claude Code project |
| `claude-md-management` | Refactoring or generating CLAUDE.md files |
| `playground` | Testing prompts and tool chains without side effects |
| `superpowers` | Any non-trivial feature or fix — triggers automatically based on context |
| `skill-creator` | Building or refining slash-command skills |
| `impeccable` | Frontend critique/polish/audit — 23 commands + anti-pattern detection |
| `github` | Reading private repos, reviewing PRs — requires `GITHUB_PERSONAL_ACCESS_TOKEN` |
| `cli-anything` | Generating AI-native CLIs for existing software (GIMP, Blender, LibreOffice, etc.) — 50+ apps, 2,280+ tests |

> Disabled: `pinecone`, `supabase`, `plugin-dev` — enable in [`.claude/settings.json`](.claude/settings.json) → `enabledPlugins`.

---

## Skills (Slash Commands)

**Built-in:**

| Command | Use When |
| ------- | -------- |
| `/frontend-design` | Starting any frontend task (mandatory first step) |
| `/claude-api` | Scaffolding an Anthropic SDK or Claude Agent SDK app |
| `/simplify` | Reviewing changed code for quality, reuse, and efficiency |
| `/schedule` | Creating cron-scheduled remote agents |
| `/loop 5m /command` | Running a prompt or command on a recurring interval |
| `/update-config` | Configuring hooks, permissions, and automated behaviors |
| `/keybindings-help` | Customizing keyboard shortcuts |

**Project skills** (source: `.claude/skills/` — installed by `setup.sh`):

| Command | Use When |
| ------- | -------- |
| `/site-teardown [url]` | Reverse engineer a website into a build blueprint |
| `/skillui` | Extract a design system from any site, dir, or GitHub repo |
| `/webgpu-threejs-tsl` | WebGPU + Three.js TSL — renderer, node materials, compute shaders |
| `/design-md` | Load a ready-made brand DESIGN.md for 73 brands via `npx getdesign@latest add <brand>` |
| `/taste-skill` | Anti-slop frontend enforcement — bans generic patterns, enforces Bento 2.0 |
| `/firecrawl` | Scrape pages, search, crawl sites, map URLs via Firecrawl CLI |
| `/notebooklm` | Google NotebookLM — create notebooks, add sources, generate podcasts/videos/briefings via `nlm` CLI |
| `/playwright` | Browser automation — screenshots, scraping, PDFs, link extraction via Playwright CLI |
| `/compact-memory` | Full memory hygiene — compress sessions, prune decisions, sync facts to MCP graph |
| `/three-brain` | Auto-route work to Codex (review/rescue) or Gemini (multimodal/long-context) — requires codex-cli + gemini-cli |
| `/autoresearch` | Autonomous ML research — modify GPT training code, run 5-min experiments, keep improvements (~12 exp/hour, ~100 overnight) |
| `/lightrag` | Graph-based RAG — knowledge extraction, entity-relationship Q&A, multimodal docs (PDFs, images), Web UI + REST API |
| `/openspace` | Self-evolving skill system — skills auto-fix, auto-improve, auto-learn; 46% token reduction; cloud skill sharing |
| `/delegate-task` | Delegate complex tasks to OpenSpace's grounding agent — auto skill evolution, search, fix, upload |
| `/skill-discovery` | Search local + cloud skills before starting work — decide: follow, delegate, or skip |

**Superpowers skills** auto-trigger based on context (brainstorming, TDD, debugging, code review, planning, subagents, git worktrees). No manual invoke needed.

> Add skills: create `<name>/SKILL.md` in `.claude/skills/` → re-run `setup.sh` or restart Claude Code.

---

## MCP Servers

Defined in [`.mcp.json`](.mcp.json). Add credentials to [`.env`](.env.example).

> **Requires `uvx`:** `google-workspace-mcp`, `alpaca`, and `notebooklm-mcp` use `uvx`. Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`

| Server | Use For |
| ------ | ------- |
| `memory` | Persistent knowledge graph memory across sessions |
| `supabase-mcp` | Postgres database + Supabase platform |
| `openrouter-mcp` | Multi-model LLM routing, benchmarking |
| `tavily-mcp` | Web search and content extraction |
| `google-workspace-mcp` | Gmail, Drive, Sheets, Docs, Calendar, Forms |
| `trigger` | Deploy, trigger, and monitor Trigger.dev tasks |
| `pinecone-mcp` | Vector search / RAG |
| `n8n-mcp` | n8n workflow automation |
| `vapi-mcp` | Voice AI — assistants, calls, phone numbers |
| `notebooklm-mcp` | Google NotebookLM — notebooks, AI queries, podcasts/videos (backup — prefer `nlm` CLI) |
| `openspace` | Self-evolving skills — execute tasks, search/fix/upload skills, auto skill evolution (FIX/DERIVED/CAPTURED) |
| `apify` | Large-scale web scraping via Apify marketplace |
| `zep-mcp` | Zep long-term memory documentation |
| `alpaca-mcp` | Algorithmic trading (paper mode) |
| `canva-dev` | Canva app SDK and CLI docs |
| `kie-ai` | Multi-provider AI media — Midjourney, Sora, ElevenLabs, Kling, Suno, etc. |
| `higgsfield` | Cinematic AI video/images — browser OAuth, no API key |
| `context7` | Live SDK/library documentation lookup — fetch on demand instead of loading static reference files |
| `monet-mcp` | Landing page UI components — search + retrieve React/TS code |
| `stitch` | Extract design DNA from screens (fonts, colors, layouts) |
| `21st-dev-magic` | UI component search + SVG brand logos |
| `playwright-mcp` | Interactive browser sessions (backup — prefer `node tools/playwright.js`) |
| `firecrawl-mcp` | Batch scraping / schema-driven extraction (backup — prefer `firecrawl` CLI) |

> **Setup:** Copy [`.claude/settings.local.json.example`](.claude/settings.local.json.example) → `.claude/settings.local.json`. The `__activation_guide` inside lists where to get each credential.

---

## LightRAG Server Setup

**LightRAG** is a graph-based RAG system with Web UI + REST API for knowledge extraction and Q&A.

### Quick Start (3 steps)

```bash
# 1. Install dependencies
cd tools/lightrag
uv sync

# 2. Configure API key
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY

# 3. Start server (choose one method)
```

**Method 1: VSCode Debug (Recommended)**  

- Press `F5` → Select "**LightRAG Server**"
- Browser opens automatically at [LightRAG Web UI](http://localhost:9621)
- Full debugging support with breakpoints

**Method 2: Quick Start Script**  

```bash
./start_server.bat
```

**Method 3: Command Line**  

```bash
uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage
```

### Access Points

- [Web UI](http://localhost:9621) - Knowledge Graph Visualization, Insert/Query
- [API Docs](http://localhost:9621/docs) - Swagger UI
- [Alt Docs](http://localhost:9621/redoc) - ReDoc

### Configuration (`.env`)

```ini
# Required
OPENAI_API_KEY=sk-proj-...

# LLM Configuration
LLM_BINDING=openai          # Options: openai, anthropic, gemini, ollama
LLM_MODEL=gpt-4o-mini

# Embedding Configuration
EMBEDDING_BINDING=openai
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIM=1536
```

### VSCode Integration

The `.vscode/launch.json` includes two debug configurations:

1. **LightRAG Server** — Starts the web server with auto-browser-open
2. **LightRAG Test Script** — Runs `test_lightrag.py` for insert/query testing

Both configs automatically load environment variables from `tools/lightrag/.env`.

### File Structure

```text
tools/lightrag/
  ├── .env                 ← API key + server config (gitignored)
  ├── .env.example         ← Template (commit this)
  ├── pyproject.toml       ← Dependencies
  ├── test_lightrag.py     ← Example usage
  ├── start_server.bat     ← Windows launcher
  └── rag_storage/         ← Knowledge graph data (gitignored)
```

### Dependencies Installed

- `lightrag-hku` — Core library
- `fastapi` + `uvicorn` — Web server
- `openai` — OpenAI integration
- `pyjwt`, `bcrypt`, `passlib` — Authentication
- `aiofiles` — Async file I/O

---

## Hooks

| Hook | File | Behavior |
| ---- | ---- | -------- |
| `PreToolUse` (Read) | [`.claude/hooks/read-guard.py`](.claude/hooks/read-guard.py) | Warns when large files are read without `offset`+`limit` to save tokens |
| `Stop` | [`.claude/hooks/stop.sh`](.claude/hooks/stop.sh) | Calls autoresearch-sync + openspace-sync; drafts memory entries; flags tracked-path doc changes |
| `PostToolUse` (Write/Edit) | [`.claude/hooks/autosync-docs.sh`](.claude/hooks/autosync-docs.sh) | After edits to tracked paths, injects context to update CLAUDE.md/README.md |
| `pre-commit` (git) | [`.claude/hooks/pre-commit.sh`](.claude/hooks/pre-commit.sh) | Auto-updates CLAUDE.md and README.md before commits that touch tracked paths |
| `autoresearch-sync` | [`.claude/hooks/autoresearch-sync.sh`](.claude/hooks/autoresearch-sync.sh) | Auto-syncs `tools/autoresearch/` with upstream karpathy/autoresearch (called by stop hook) |
| `openspace-sync` | [`.claude/hooks/openspace-sync.sh`](.claude/hooks/openspace-sync.sh) | Auto-syncs `tools/openspace/` git submodule with upstream HKUDS/OpenSpace; pulls latest commits; updates submodule pointer in parent repo; skips if uncommitted changes exist (called by stop hook) |

> Add new hooks in [`.claude/settings.json`](.claude/settings.json) under `"hooks"`.

---

## Memory (MANDATORY)

Update memory files **as you go**, not at session end. Do not ask — just update.

| Trigger | File |
| ------- | ---- |
| User shares a fact about themselves | `memory-profile.md` |
| User states a preference | `memory-preferences.md` |
| A non-trivial decision is made | `memory-decisions.md` (with date) |
| Substantive work is completed | `memory-sessions.md` |

**Maintenance:** Run `/compact-memory` monthly (or when `memory-sessions.md` exceeds ~200 lines) to compress old entries, prune obsolete decisions, and sync key facts to the knowledge graph.

Full rules: [`memory-guidelines.md`](.claude/rules/memory-guidelines.md)
