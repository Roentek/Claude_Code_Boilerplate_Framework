# Claude-Code Boilerplate Framework

Defines **how we work**, not what we're building. If a rule doesn't change behavior, it doesn't belong here.

> **Global defaults:** [`~/.claude/CLAUDE.md`](~/.claude/CLAUDE.md) — communication style, platform (Windows/PowerShell), Python toolchain (uv), git conventions. Loaded before this file every session; project rules override.

---

## What Are You Building?

| Building | Start With | Key Rules |
| -------- | ---------- | --------- |
| Trigger.dev automation | `workflows/` → `tools/` | [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md), [`trigger-api-reference.md`](.claude/docs/trigger-api-reference.md) |
| Frontend UI | `/frontend-design` skill → `ui-ux-pro-max` design system | [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) |
| WebGPU / Three.js app | `/webgpu-threejs-tsl` skill | Three.js r171+ with WebGPU renderer, TSL shaders |
| Spline 3D scene integration | `/spline-3d` skill | Embed Spline scenes in React or vanilla HTML; includes perf guide + examples |
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
| Web scraping (large-scale / actors) | `/apify-ultimate-scraper` skill → `apify` CLI + MCP | 130+ curated Actors for Instagram, TikTok, LinkedIn, Google, Reddit, Amazon, etc. — skill routes to CLI or MCP based on task |
| Apify Actor development | `/apify-actor-development` skill | Create, debug, deploy Actors in JS/TS/Python with bundled config schemas |
| Convert code to Apify Actor | `/apify-actorization` skill | Transform existing scripts into Actors (JS/TS SDK, Python async, CLI wrappers) |
| Generate Actor output schemas | `/apify-generate-output-schema` skill | Auto-generate `dataset_schema.json`, `output_schema.json`, `key_value_store_schema.json` from Actor source |
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

# LightRAG — graph-based RAG (see LightRAG Server Setup section below for full start options)
cd tools/lightrag && uv sync && cp .env.example .env  # First-time setup

# OpenSpace — self-evolving skill system (CLI first, MCP backup)
# Git submodule — auto-syncs with upstream every session via openspace-sync.sh hook
cd tools/openspace
pip install -e .                           # Install OpenSpace (done by setup.sh)

# CLI (primary — token-free execution)
openspace --query "Create a monitoring dashboard for Docker containers"
openspace-download-skill <skill_id>      # Download from cloud
openspace-upload-skill /path/to/skill/dir # Upload to cloud (requires OPENSPACE_API_KEY)

# MCP (backup — use when CLI output insufficient or need structured results)
# Search: mcp__openspace__search_skills (no CLI equivalent)
# Use mcp__openspace__* tools via ToolSearch when CLI doesn't meet needs

# Submodule updates (automatic via stop hook, or manual)
git submodule update --remote tools/openspace  # Manual: pull latest from upstream

# Caveman — token compression (75% reduction on responses, 46% on memory files)
/caveman                          # Activate compression mode (lite/full/ultra)
/caveman-stats                    # Show session token usage + savings
/caveman-compress memory-*.md     # Shrink memory files by ~46%
/caveman-commit                   # Terse commit messages (≤50 chars)
/caveman-review                   # Single-line PR comments
/cavecrew                         # Compressed subagents (60% fewer tokens)

# Dashboard (optional — requires Node.js ≥ 20)
# Press F5 → "OpenSpace Dashboard (Full Stack)" — or see tools/openspace/README.md
```

> **MCP credential gotcha:** `.mcp.json` `${VAR}` substitution reads from the **OS process environment**, not `.env`. On a fresh machine, run `setx VAR_NAME "value"` (Windows) or `export VAR_NAME=value` (Unix) in your terminal before starting Claude Code.

---

## First-Time Setup

```bash
# 1. Install dependencies
npm install

# 2. Run initial setup (hooks, skills, permissions, CLI tools, git submodules)
bash .claude/hooks/setup.sh
# Installs: marketplace plugins (ui-ux-pro-max, impeccable, codex, gemini, cli-anything, caveman, context-mode, claude-mem)
# Step 7a:  Apify agent skills (5 skills from apify/agent-skills marketplace) with 30-sec timeout protection; displays manual /skill install commands if timeout/failure occurs
# Step 7b:  Caveman plugin (token compression — 75% response reduction, 46% memory file reduction)
# Step 7c:  Context Mode plugin (98% context reduction via sandboxing; statusline shows session/total savings + efficiency %); auto-installs better-sqlite3 with NODE_TLS_REJECT_UNAUTHORIZED=0 (corporate SSL proxy fix) for FTS5 session continuity
# Step 7d-pre: Bun runtime (required by claude-mem worker for web viewer + MCP search; also 3-5x faster context-mode sandbox); Windows: powershell -c "irm bun.sh/install.ps1 | iex"; Unix: curl -fsSL https://bun.sh/install | bash
# Step 7d:  Claude-Mem plugin (persistent memory across sessions; context survives session end/reconnect; web viewer at http://localhost:37777; requires Bun)
# Step 8:   Project skills with cross-platform path detection (Windows $USERPROFILE fallback, Unix-style path conversion); creates destination directory; verifies each copy succeeded
# Step 9:   npm install (all package.json deps: react, react-dom, @types/react, @splinetool/react-spline, @splinetool/runtime, Playwright) + Playwright Chromium browser
# Step 10:  skillui, firecrawl-cli, codex-cli, gemini-cli, notebooklm-mcp-cli
# Step 11:  autoresearch dependencies in tools/autoresearch/ (via uv sync)
# Step 12:  lightrag dependencies in tools/lightrag/ (via uv sync); auto-runs provision.py if .env exists (idempotent — skips if no credentials)
# Step 12a: Ollama install + llama3.2 pull (local LLM for LightRAG; Windows: shows winget command, Unix: auto-installs)
# Step 13:  openspace submodule initialization + uv pip install -e ".[<platform>]" (windows/linux/macos extras; avoids uv sync cross-version pyatspi resolution failure) + dashboard frontend npm install + .env port alignment (3889 → 3789 to match package.json)

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
  lightrag/                   ← LightRAG Plus (graph-based RAG with multimodal + multi-backend support)
    src/                      ← Plus implementation
      config.py               ← Environment config + feature flags
      lightrag_plus.py        ← Main wrapper class
      embedders/              ← OpenAI (text-only) + Gemini (multimodal) embeddings
      adapters/               ← Supabase + Pinecone vector mirrors (optional)
      ingestors/              ← Multimodal preprocessing (images, video, audio)
    schema/                   ← Backend setup scripts
      supabase_schema.sql     ← Supabase table definitions
    provision.py              ← Auto-provision Supabase schema + Pinecone index (reads .env flags, idempotent)
    check_update.py           ← Check/apply lightrag-hku updates (PyPI diff, pin bump, verify, smoke test)
    setup_backends.py         ← Backend connection validation script
    pyproject.toml            ← Dependencies (lightrag-hku + server + Plus deps)
    uv.lock                   ← Dependency lockfile
    README.md                 ← Full LightRAG Plus documentation
    .env                      ← Server config + API keys (gitignored)
    .env.example              ← Configuration template with all options
    .gitignore                ← Excludes .env, logs, rag_storage, build artifacts
    test_lightrag.py          ← Test script (insert/query example)
    start_server.bat          ← Windows quick launcher
    .venv/                    ← Virtual environment (gitignored)
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
| `caveman` | Token compression — 75% reduction on responses, 46% on memory files; terse commits/reviews; session tracking |
| `context-mode` | Context window optimization — 98% reduction via sandboxing (315 KB → 5.4 KB); session continuity via SQLite FTS5; output compression ~65-75% |
| `claude-mem` | Persistent memory across sessions — captures tool usage observations, generates semantic summaries, [web viewer](http://localhost:37777) |

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
| `/update-all` | Update all npm globals, uv tools, Python venvs, npm deps, and submodules; repairs broken venvs automatically |
| `/three-brain` | Auto-route work to Codex (review/rescue) or Gemini (multimodal/long-context) — requires codex-cli + gemini-cli |
| `/autoresearch` | Autonomous ML research — modify GPT training code, run 5-min experiments, keep improvements (~12 exp/hour, ~100 overnight) |
| `/lightrag` | Graph-based RAG — knowledge extraction, entity-relationship Q&A, multimodal docs (PDFs, images), Web UI + REST API |
| `/openspace` | Self-evolving skill system — skills auto-fix, auto-improve, auto-learn; 46% token reduction; cloud skill sharing |
| `/delegate-task` | Delegate complex tasks to OpenSpace's grounding agent — auto skill evolution, search, fix, upload |
| `/skill-discovery` | Search local + cloud skills before starting work — decide: follow, delegate, or skip |
| `/find-skills` | Inventory all installed skills (global + project) and enabled plugins — shows gaps and orphans |
| `/apify-ultimate-scraper` | Universal web scraper — 130+ Actors for Instagram, TikTok, YouTube, LinkedIn, Google, Reddit, Amazon, Airbnb, Yelp; lead generation, brand monitoring, competitor analysis, trend research |
| `/apify-actor-development` | Create and deploy Apify Actors — JS/TS/Python Actor development with config schemas and logging |
| `/apify-actorization` | Convert existing code to Apify Actors — JS/TS SDK, Python async, CLI wrappers |
| `/apify-generate-output-schema` | Generate Actor output schemas — auto-create `dataset_schema.json`, `output_schema.json`, `key_value_store_schema.json` |
| `/create-actor` | Guided Actor scaffolding — from apify-actor-commands pack |
| `/caveman` | Activate 75% token reduction (lite/full/ultra modes) — telegraphic responses without context loss |
| `/caveman-stats` | Show actual session token usage, savings, and USD costs from JSONL logs |
| `/caveman-compress` | Shrink memory files (memory-*.md, CLAUDE.md) by ~46% — preserves code/URLs/paths exactly |
| `/caveman-commit` | Generate terse commit messages (≤50 chars, Conventional Commits format) |
| `/caveman-review` | Single-line PR comments: "L42: 🔴 bug: user null. Add guard" |
| `/cavecrew` | Compressed subagents (investigator/builder/reviewer with 60% fewer tokens) |
| `/auto-stage-commit` | Stage all changes + generate lean commit message — outputs ready-to-run `git commit` command; **does not commit** (auto-triggers on commit intent) |
| `/spline-3d` | Embed Spline 3D scenes in React or vanilla HTML — includes React wrapper, interactive scene examples, performance guide |

**Superpowers skills** auto-trigger based on context (brainstorming, TDD, debugging, code review, planning, subagents, git worktrees). No manual invoke needed.

> Add skills: create `<name>/SKILL.md` in `.claude/skills/` → re-run `setup.sh` or restart Claude Code.

---

## MCP Servers

Defined in [`.mcp.json`](.mcp.json). Add credentials to [`.env`](.env.example).

> **Requires `uvx`:** `google-workspace-mcp`, `alpaca`, and `notebooklm-mcp` use `uvx`. Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`

| Server | Use For |
| ------ | ------- |
| `memory-shrunk` | **Replaces `memory`** — Caveman-compressed knowledge graph; ~50% metadata reduction on tool descriptions |
| `supabase-mcp` | Postgres database + Supabase platform |
| `openrouter-mcp` | Multi-model LLM routing, benchmarking |
| `tavily-mcp` | Web search and content extraction |
| `google-workspace-mcp` | Gmail, Drive, Sheets, Docs, Calendar, Forms |
| `trigger` | Deploy, trigger, and monitor Trigger.dev tasks |
| `pinecone-mcp` | Vector search / RAG |
| `n8n-mcp` | n8n workflow automation |
| `vapi-mcp` | Voice AI — assistants, calls, phone numbers |
| `notebooklm-mcp` | Google NotebookLM — notebooks, AI queries, podcasts/videos (backup — prefer `nlm` CLI) |
| `openspace` | Self-evolving skills — execute tasks, search/fix/upload skills, auto skill evolution (FIX/DERIVED/CAPTURED). **Windows:** Uses `python -m openspace.mcp_server` command with `PYTHONUTF8=1` (fixes Unicode checkmark encoding). |
| `apify` | Large-scale web scraping via Apify marketplace — 130+ Actors covering Instagram, TikTok, LinkedIn, Google, Reddit, Amazon, etc. Use with `/apify-ultimate-scraper` skill for guided workflows (lead generation, brand monitoring, competitor analysis, influencer vetting, trend research, SEO intelligence, review analysis, recruitment, real estate, e-commerce price monitoring, contact enrichment, RAG data feeds) |
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

Graph-based RAG with multimodal support. See [`tools/lightrag/README.md`](tools/lightrag/README.md).

**Quick start:**

```bash
cd tools/lightrag && uv sync && cp .env.example .env
# Add OPENAI_API_KEY (+ SUPABASE_MANAGEMENT_TOKEN if ENABLE_SUPABASE=true) to .env, then:
uv run python provision.py          # Auto-creates schema/index if backends enabled (idempotent)
uv run python check_update.py      # Check for lightrag-hku updates (add --upgrade to apply)
uv run python src/server.py --port 9621 --working-dir ./rag_storage --embedding-binding-host https://api.openai.com/v1
# Or: Press F5 → "LightRAG Server" (VSCode) / run start_server.bat — both use src/server.py automatically
```

**LightRAGPlus server (`src/server.py`) vs vanilla server:**

| | `src/server.py` (default) | `lightrag.api.lightrag_server` (bypass) |
| --- | --- | --- |
| Text uploads (PDF/MD/TXT) | local graph + cloud mirror | local graph only |
| Media uploads | `/api/plus/insert-media` endpoint | not supported |
| Embedding host bug fix | `--embedding-binding-host` baked in | requires manual flag |

**Extra endpoints added by `src/server.py`:**

- `GET /api/plus/status` — backend config + health check
- `POST /api/plus/insert-media` — image/audio/video → cloud backends only (requires `MULTIMODAL_MODE=advanced` + `EMBEDDING_PROVIDER=gemini`)

**Known gotcha — embedding 404:** `LLM_BINDING_HOST=http://localhost:11434` (Ollama) bleeds into OpenAI embedding calls via `get_default_host("openai")`. Fix: always pass `--embedding-binding-host https://api.openai.com/v1` (baked into `start_server.bat` and `src/server.py` launch command above).

**Running integration tests (Windows):**

```bash
# Step 1: sync venv once (do NOT use `uv run pytest` — it re-syncs on every call and hits Windows file locks)
cd tools/lightrag && uv sync --extra dev

# Step 2: run tests directly via venv python (repeatable, no re-sync)
.venv\Scripts\python.exe -m pytest tests/test_integration.py -v

# If uv sync fails with "Access is denied" or missing RECORD files — self-heal first:
Remove-Item -Force -Recurse .venv\Lib\site-packages\regex-*.dist-info -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse .venv\Lib\site-packages\proto_plus-*.dist-info -ErrorAction SilentlyContinue
uv sync --extra dev
```

**Access:** [Web UI + API Docs](http://localhost:9621)

---

## Hooks

| Hook | File | Behavior |
| ---- | ---- | -------- |
| `SessionStart` | [`.claude/hooks/mcp-cleanup.sh`](.claude/hooks/mcp-cleanup.sh) + [`.claude/hooks/openspace-sync.sh`](.claude/hooks/openspace-sync.sh) | Kills stale MCP node processes; syncs OpenSpace submodule with upstream at session start |
| `PreToolUse` (Read) | [`.claude/hooks/read-guard.py`](.claude/hooks/read-guard.py) | Warns when large files are read without `offset`+`limit` to save tokens |
| `Stop` | [`.claude/hooks/stop.sh`](.claude/hooks/stop.sh) | Calls autoresearch-sync + openspace-sync + lightrag-sync; drafts memory entries; flags tracked-path doc changes |
| `PostToolUse` (Write/Edit) | [`.claude/hooks/autosync-docs.sh`](.claude/hooks/autosync-docs.sh) | After edits to tracked paths, injects context to update CLAUDE.md/README.md |
| `pre-commit` (git) | [`.claude/hooks/pre-commit.sh`](.claude/hooks/pre-commit.sh) | Auto-updates CLAUDE.md and README.md before commits that touch tracked paths |
| `autoresearch-sync` | [`.claude/hooks/autoresearch-sync.sh`](.claude/hooks/autoresearch-sync.sh) | Auto-syncs `tools/autoresearch/` with upstream karpathy/autoresearch (called by stop hook) |
| `openspace-sync` | [`.claude/hooks/openspace-sync.sh`](.claude/hooks/openspace-sync.sh) | Auto-syncs `tools/openspace/` git submodule with upstream HKUDS/OpenSpace; runs on both SessionStart and Stop; skips if uncommitted changes exist |
| `lightrag-sync` | [`.claude/hooks/lightrag-sync.sh`](.claude/hooks/lightrag-sync.sh) | Checks `lightrag-hku` PyPI version against pin on every Stop; notifies if minor/patch or major update available; run `check_update.py --upgrade` to apply |
| `update-all` | [`.claude/hooks/update-all.sh`](.claude/hooks/update-all.sh) | Manual update script — npm globals, uv tools, Python venvs, npm deps, submodules; self-heals broken venvs. Run via `/update-all` skill |

> Add new hooks in [`.claude/settings.json`](.claude/settings.json) under `"hooks"`.

---

## Troubleshooting

| Issue | Fix |
| ------- | ----- |
| `uvx: command not found` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| MCP server timeout | Increase `toolTimeout` in `.mcp.json` (default 600s → 1200s) |
| Git Bash crash (Windows) | Use PowerShell or WSL instead |
| `OPENAI_API_KEY not set` | Add to both `.env` AND OS environment (`setx` on Windows) |
| setup.sh hangs at skill install | Press Ctrl+C, run manual `/skill install` commands shown |
| `better-sqlite3` build fails (corporate proxy) | `NODE_TLS_REJECT_UNAUTHORIZED=0 npm install better-sqlite3 --build-from-source` — or re-run setup.sh (step 7c applies this fix automatically) |

---

## Memory (MANDATORY)

Update memory files **as you go**, not at session end. Do not ask — just update.

| Trigger | File |
| ------- | ---- |
| User shares a fact about themselves | `.claude/rules/memory-profile.md` |
| User states a preference | `.claude/rules/memory-preferences.md` |
| A non-trivial decision is made | `.claude/rules/memory-decisions.md` (with date) |
| Substantive work is completed | `.claude/rules/memory-sessions.md` |

**Maintenance:** Run `/compact-memory` monthly (or when `memory-sessions.md` exceeds ~200 lines) to compress old entries, prune obsolete decisions, and sync key facts to the knowledge graph.

Full rules: [`memory-guidelines.md`](.claude/rules/memory-guidelines.md)
