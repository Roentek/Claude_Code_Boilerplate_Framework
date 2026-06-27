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
| Supabase local dev (migrations, local stack, type gen, edge functions) | `supabase` CLI (primary) → `supabase-mcp` (in-context queries) | `supabase login` once; `supabase start` needs Docker; CLI-first for migrations + type gen |
| Claude API / SDK app | `/claude-api` skill | Scaffolds Anthropic SDK boilerplate |
| NotebookLM research / podcasts | `/notebooklm` skill → `nlm` CLI | Create notebooks, add sources, generate podcasts/videos/briefings — CLI first; `notebooklm-mcp` as backup |
| n8n workflow | `n8n-mcp` tools | Search nodes, validate, build via MCP |
| Voice AI (Vapi) | `vapi-mcp` tools | Create assistants, calls, phone numbers |
| Browser automation (real Chrome, CDP) | `/browser-harness` skill → `browser-harness` CLI | Direct CDP control of your real Chrome — coordinate clicks, screenshots, JS eval; `--doctor` for setup; cloud via `browser-harness auth login` |
| Browser automation (headless/scripted) | `/playwright` skill → `tools/playwright.js` | `workflows/browser-automation.md` — CLI first; `playwright-mcp` as backup |
| Web scraping (single page / crawl) | `/firecrawl` skill → `firecrawl` CLI | `workflows/web-scraping.md` — CLI first; `firecrawl-mcp` backup for batch/schema |
| Web scraping (large-scale / actors) | `/apify-ultimate-scraper` skill → `apify` CLI + MCP | 130+ curated Actors for Instagram, TikTok, LinkedIn, Google, Reddit, Amazon, etc. — skill routes to CLI or MCP based on task |
| Apify Actor development | `/apify-actor-development` skill | Create, debug, deploy Actors in JS/TS/Python with bundled config schemas |
| Convert code to Apify Actor | `/apify-actorization` skill | Transform existing scripts into Actors (JS/TS SDK, Python async, CLI wrappers) |
| Generate Actor output schemas | `/apify-generate-output-schema` skill | Auto-generate `dataset_schema.json`, `output_schema.json`, `key_value_store_schema.json` from Actor source |
| Vector search / RAG | `pinecone-mcp` tools | Upsert, search, rerank records |
| Graph-based RAG / knowledge extraction | `/lightrag` skill → `tools/lightrag-plus/` | Knowledge graph RAG, entity-relationship Q&A, multimodal docs — Web UI + REST API |
| UI component search | `monet-mcp` tools | Search landing page components, get React/TS code |
| UI component inspiration / SVG logos | `21st-dev-magic` tools | Search UI components, SVG brand logos, generate variants |
| AI image/video (cinematic, managed) | `higgsfield` MCP | No API key — browser OAuth; cinematic video, media library |
| AI image/video/audio (specific model) | `/kie-ai` skill → `kie-cli` CLI (primary) → `kie-ai` MCP (fallback) | Midjourney, Sora, ElevenLabs, Kling, Suno, etc. CLI = zero context tokens; auto-switches to MCP if needed |
| Self-evolving AI skills / collective intelligence | `/openspace` skill → `openspace` CLI | Skills that auto-fix, auto-improve, auto-learn; 46% token reduction; cloud skill sharing — **CLI first; MCP backup** |
| AI spend tracking / token cost analysis | `/codeburn` skill → `codeburn` CLI | Token + dollar breakdown by task, model, tool, project across 31 AI tools — `codeburn` for TUI dashboard, `codeburn status` for one-liner |
| Extract design tokens from any website | `/extract-design` skill → `designlang` CLI + plugin | DTCG tokens, Tailwind config, shadcn theme, Figma vars, CSS vars, WCAG scores — 13 slash commands (/extract /site /grade /battle /remix /pack /theme-swap /brand /pair /studio /verify /fidelity /gallery) |
| Query codebase as knowledge graph | `/graphify` skill → `graphify` CLI + `graphify-mcp` | AST-parse 25+ languages → queryable graph; answers "what calls X?", "what depends on Y?"; run `/graphify .` once per repo to build; MCP for persistent tool access |
| GitHub operations (issues, PRs, releases, repos) | `gh` CLI (primary) → `github` plugin MCP (fallback) | `gh issue list`, `gh pr create`, `gh repo clone`, `gh release create` — CLI-first; plugin MCP for reading private repo content in-context |
| Watch / analyze video content | `/watch` plugin → `claude-video` | Analyze YouTube, TikTok, Vimeo, local video — extracts frames + transcript; `/watch <url> <question>`; needs ffmpeg + yt-dlp |
| Process / manipulate video files (trim, transcode, thumbnail, extract audio, concat) | `node tools/ffmpeg.js` | All output JSON; requires system ffmpeg (auto-installed via `sys-ffmpeg.sh`); see `/ffmpeg` skill |
| Validate / stress-test an idea before building | `/roast` skill | 5-persona adversarial council attacks from every angle → GO / RESHAPE / KILL verdict + cheapest 48-hour test. **Auto-invoke** when user says "I'm thinking of building X", "what do you think of this idea", "should I build this", or "pressure-test this" — run *before* any significant build starts |
| End a session / hand off to a fresh context | `/session-handoff` skill | Structured handoff (decisions, files, running state, deferrals) so `/clear` loses nothing. **Auto-invoke** when user says "wrap up", "hand off", "summarize before I clear", or context exceeds ~250K tokens |

---

## Key Commands

```bash
# Trigger.dev — start local dev runner
npx trigger.dev@latest dev

# Re-run first-time setup (e.g. fresh clone)
rm -f .claude/.setup-complete && bash .claude/hooks/setup.sh

# Install a single component (modular — no marker needed)
bash .claude/hooks/install/cli-firecrawl.sh      # example: just firecrawl CLI
bash .claude/hooks/install/plugin-caveman.sh     # example: just caveman plugin
bash .claude/hooks/install/tool-lightrag.sh      # example: just LightRAG

# Reinstall context-monitor statusline
npx claude-code-templates@latest --setting statusline/context-monitor

# Browser automation (WAT Tools layer example)
node tools/playwright.js screenshot https://example.com

# FFmpeg — video/audio processing
node tools/ffmpeg.js probe video.mp4                              # inspect metadata
node tools/ffmpeg.js trim input.mp4 --start 00:00:30 --end 00:01:00
node tools/ffmpeg.js thumbnail input.mp4 --at 00:00:10 --width 1280
node tools/ffmpeg.js extract-audio input.mp4 --format mp3
node tools/ffmpeg.js transcode input.avi --format mp4 --resolution 1280x720
node tools/ffmpeg.js concat a.mp4 b.mp4 --output merged.mp4

# Supabase CLI — local dev, migrations, type generation
supabase login                                                     # one-time browser OAuth
supabase init                                                      # init project (first time)
supabase start                                                     # start local stack (Docker required)
supabase db push                                                   # push migrations to remote
supabase migration new <name>                                      # create a new migration file
supabase gen types typescript --project-id <id> > types/db.ts     # generate TypeScript types
supabase functions deploy <function-name>                          # deploy edge function
supabase stop                                                      # stop local stack

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
cd tools/lightrag-plus && UV_NATIVE_TLS=true uv sync --all-extras && cp .env.example .env  # First-time setup

# OpenSpace — self-evolving skill system (CLI first, MCP backup)
# Git submodule — auto-syncs with upstream every session via openspace-sync.sh hook
cd tools/openspace
uv pip install -e ".[windows]"             # Install OpenSpace (done by setup.sh; use linux/macos on those platforms)

# CLI (primary — token-free execution)
openspace --query "Create a monitoring dashboard for Docker containers"
openspace-download-skill <skill_id>      # Download from cloud
openspace-upload-skill /path/to/skill/dir # Upload to cloud (requires OPENSPACE_API_KEY)

# MCP (backup — use when CLI output insufficient or need structured results)
# Search: mcp__openspace__search_skills (no CLI equivalent)
# Use mcp__openspace__* tools via ToolSearch when CLI doesn't meet needs

# Submodule updates (automatic via stop hook, or manual)
git submodule update --remote tools/openspace  # Manual: pull latest from upstream

# Graphify — one-time per repo (must build before /graphify or graphify-mcp work)
graphify .                                          # Parse codebase → graphify-out/graph.json
graphify query "what calls authMiddleware?"         # Query without MCP

# Session management
/roast <idea>                     # Pressure-test idea before building (5-persona council)
/session-handoff                  # Structured wrap-up before /clear — chat-only

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
# Installs: marketplace plugins (ui-ux-pro-max, impeccable, codex, gemini, cli-anything, caveman, context-mode, claude-mem, claude-video, ponytail)
# Step 7a:  Apify agent skills (5 skills from apify/agent-skills marketplace) with 30-sec timeout protection; displays manual /skill install commands if timeout/failure occurs
# Step 7b:  Caveman plugin (token compression — 75% response reduction, 46% memory file reduction)
# Step 7c:  Context Mode plugin (98% context reduction via sandboxing; statusline shows session/total savings + efficiency %); auto-installs better-sqlite3 with NODE_TLS_REJECT_UNAUTHORIZED=0 (corporate SSL proxy fix) for FTS5 session continuity
# Step 7d-pre: Bun runtime (required by claude-mem worker for web viewer + MCP search; also 3-5x faster context-mode sandbox); Windows: powershell -c "irm bun.sh/install.ps1 | iex"; Unix: curl -fsSL https://bun.sh/install | bash
# Step 7d:  Claude-Mem plugin (persistent memory across sessions; context survives session end/reconnect; web viewer at http://localhost:37777; requires Bun)
# Step 8:   Project skills with cross-platform path detection (Windows $USERPROFILE fallback, Unix-style path conversion); creates destination directory; verifies each copy succeeded
# Step 9:   npm install (all package.json deps: react, react-dom, @types/react, @splinetool/react-spline, @splinetool/runtime, Playwright) + Playwright Chromium browser
# Step 10:  skillui, firecrawl-cli, codex-cli, gemini-cli, notebooklm-mcp-cli, codeburn, browser-harness, designlang, kie-cli (@felores/kie-cli)
# Step 11:  autoresearch dependencies in tools/autoresearch/ (via uv sync)
# Step 12:  lightrag dependencies in tools/lightrag-plus/ (via uv sync); auto-creates tools/lightrag-plus/.env from .env.example if missing (so EMBEDDING_BINDING_HOST is set on first boot); auto-runs provision.py if .env exists (idempotent — skips if no credentials)
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
    install/                  ← Modular install scripts — one per plugin/CLI/tool/skill; run standalone or via setup.sh
      lib.sh                  ← Shared helpers (_timeout, _is_windows, _user_home, _install_plugin, _install_skill)
      sys-*.sh                ← System prerequisites (python, node, uvx, bun, env, npm-deps, pre-commit, github-cli)
      plugin-*.sh             ← Claude plugins (ui-ux-pro-max, impeccable, caveman, context-mode, claude-mem, designlang, claude-video…)
      skill-apify-*.sh        ← Apify marketplace skills (ultimate-scraper, actor-development, actorization…)
      skills-project.sh       ← Copies .claude/skills/* → ~/.claude/skills/
      cli-*.sh                ← Global CLI tools (firecrawl, codex, gemini, notebooklm, codeburn, browser-harness, kie…)
      tool-*.sh               ← Heavy tools (autoresearch, lightrag, ollama, openspace, graphify)
      auth-reminders.sh       ← Prints one-time manual auth steps (NotebookLM, Trigger, Google, GitHub…)
  scripts/                    ← Utility scripts (statusline, context monitor)
  docs/                       ← Reference docs
  settings.local.json         ← Machine-local credentials + permissions (gitignored)
  settings.local.json.example ← Template: all keys cleared + activation guide per MCP server
.mcp.json                     ← MCP server definitions (version-controlled)
.env / .env.example           ← API keys (gitignored — never commit)
tools/                        ← Deterministic execution scripts (Python/Node)
  playwright.js               ← Browser automation CLI wrapper
  ffmpeg.js                   ← FFmpeg video/audio processing CLI wrapper
  autoresearch/               ← Autonomous ML research (prepare.py, train.py, program.md)
  lightrag-plus/              ← LightRAG Plus (graph-based RAG with multimodal + multi-backend support)
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
    tests/                    ← Integration tests (35 tests, 7 backend scenarios)
      conftest.py             ← SSL + env fixtures
      test_integration.py     ← Parametrized backend tests
      fixtures/               ← Sample media files
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
| `github` | Reading private repo content in-context, reviewing PRs via MCP — **CLI-first:** prefer `gh` CLI for all GitHub operations; plugin is fallback for in-context repo reads. Requires `GITHUB_PERSONAL_ACCESS_TOKEN` |
| `cli-anything` | Generating AI-native CLIs for existing software (GIMP, Blender, LibreOffice, etc.) — 50+ apps, 2,280+ tests |
| `claude-video` | Watch + analyze video — `/watch <url> <question>`; extracts frames + transcript; YouTube, TikTok, Vimeo, 500+ sites; needs ffmpeg + yt-dlp |
| `ponytail` | YAGNI/minimal-code discipline — always-on; -54% LOC, -22% tokens, -20% cost; `/ponytail [lite\|full\|ultra\|off]`, `/ponytail-review`, `/ponytail-audit` |
| `caveman` | Token compression — 75% reduction on responses, 46% on memory files; terse commits/reviews; session tracking |
| `context-mode` | Context window optimization — 98% reduction via sandboxing (315 KB → 5.4 KB); session continuity via SQLite FTS5; output compression ~65-75% |
| `claude-mem` | Persistent memory across sessions — captures tool usage observations, generates semantic summaries, [web viewer](http://localhost:37777) |

> Disabled Claude *plugins* (MCP servers for pinecone/supabase are still active — see MCP Servers table): `pinecone`, `supabase`, `plugin-dev` — enable in [`.claude/settings.json`](.claude/settings.json) → `enabledPlugins`.

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
| `/site-teardown [url]` | User provides a URL and asks to clone, match, or understand a site's structure/design before building |
| `/skillui` | Prepping to match an existing site's design in a build session — extracts tokens into SKILL.md/DESIGN.md for session use. Use *before* writing any UI code that should match an existing site |
| `/extract-design` | When the extracted tokens/configs are themselves the deliverable (DTCG, Tailwind, shadcn, Figma vars, CSS vars, WCAG report). 13 plugin commands for export formats |
| `/webgpu-threejs-tsl` | WebGPU + Three.js TSL — renderer, node materials, compute shaders |
| `/design-md` | Load a ready-made brand DESIGN.md for 73 brands via `npx getdesign@latest add <brand>` |
| `/taste-skill` | Anti-slop frontend enforcement — bans generic patterns, enforces Bento 2.0 |
| `/firecrawl` | Scrape pages, search, crawl sites, map URLs via Firecrawl CLI |
| `/notebooklm` | Google NotebookLM — create notebooks, add sources, generate podcasts/videos/briefings via `nlm` CLI |
| `/browser-harness` | Real Chrome CDP automation — coordinate clicks, screenshots, JS eval, drag-drop, iframes, downloads; `browser-harness --doctor` for setup |
| `/playwright` | Browser automation — screenshots, scraping, PDFs, link extraction via Playwright CLI |
| `/compact-memory` | When `memory-sessions.md` exceeds ~200 lines, monthly, or before a major new project phase. Compresses sessions, prunes decisions, syncs facts to MCP graph |
| `/update-all` | Update all npm globals, uv tools, Python venvs, npm deps, and submodules; repairs broken venvs automatically |
| `/three-brain` | Task needs deep code review or rescue (→ Codex) OR multimodal/large-context analysis (→ Gemini). Requires both CLIs installed (`codex-cli` + `gemini-cli`) |
| `/autoresearch` | Autonomous ML research — modify GPT training code, run 5-min experiments, keep improvements (~12 exp/hour, ~100 overnight) |
| `/lightrag` | Graph-based RAG — knowledge extraction, entity-relationship Q&A, multimodal docs (PDFs, images), Web UI + REST API |
| `/openspace` | Self-evolving skill system — skills auto-fix, auto-improve, auto-learn; 46% token reduction; cloud skill sharing |
| `/skill-discovery` | **Run first** before any non-trivial task — searches local + cloud skills to decide: follow existing skill, delegate, or proceed manually |
| `/delegate-task` | After `/skill-discovery` when task is complex and an OpenSpace agent should own it — auto skill evolution + upload |
| `/find-skills` | Auditing what's installed: gap analysis, orphaned skills, plugin inventory |
| `/apify-ultimate-scraper` | Universal web scraper — 130+ Actors for Instagram, TikTok, YouTube, LinkedIn, Google, Reddit, Amazon, Airbnb, Yelp; lead generation, brand monitoring, competitor analysis, trend research |
| `/apify-actor-development` | Create and deploy Apify Actors — JS/TS/Python Actor development with config schemas and logging |
| `/apify-actorization` | Convert existing code to Apify Actors — JS/TS SDK, Python async, CLI wrappers |
| `/apify-generate-output-schema` | Generate Actor output schemas — auto-create `dataset_schema.json`, `output_schema.json`, `key_value_store_schema.json` |
| `/create-actor` | Guided Actor scaffolding — from apify-actor-commands pack |
| `/caveman` | Activate 75% token reduction (lite/full/ultra modes) — telegraphic responses without context loss |
| `/kie-ai` | AI media generation — 29 models (Midjourney, Veo3, Suno, ElevenLabs, Kling, Flux, etc.); CLI-first (`kie-cli`), auto-falls back to MCP; async task polling |
| `/codeburn` | AI spend analytics — token + dollar breakdown by task/model/tool/project across 31 AI tools; `codeburn` opens TUI dashboard, `codeburn status` for one-liner |
| `/caveman-stats` | Show actual session token usage, savings, and USD costs from JSONL logs |
| `/caveman-compress` | Shrink memory files (memory-*.md, CLAUDE.md) by ~46% — preserves code/URLs/paths exactly |
| `/caveman-commit` | Generate terse commit messages (≤50 chars, Conventional Commits format) |
| `/caveman-review` | Single-line PR comments: "L42: 🔴 bug: user null. Add guard" |
| `/cavecrew` | Compressed subagents (investigator/builder/reviewer with 60% fewer tokens) |
| `/auto-stage-commit` | Stage all changes + generate lean commit message — outputs ready-to-run `git commit` command; **does not commit** (auto-triggers on commit intent) |
| `/spline-3d` | Embed Spline 3D scenes in React or vanilla HTML — includes React wrapper, interactive scene examples, performance guide |
| `/graphify` | AST-parse codebase (25+ languages) → queryable knowledge graph; answers "what calls X?", "what depends on Y?"; run once per repo; `graphify-mcp` for persistent access |
| `/watch` | Watch + analyze video — frames + transcript fed to Claude; `/watch <url> <question>`; `--start`/`--end` window; optional Whisper transcription (Groq/OpenAI) |
| `/ffmpeg` | Process / manipulate video files — `node tools/ffmpeg.js`; transcode, trim, thumbnail, extract-audio, probe, concat; all output JSON; requires system ffmpeg |
| `/roast` | When user says "roast", "pressure-test", "should I build this?", "what do you think of this idea?" — or before any unvalidated build starts. 5-persona council → GO / RESHAPE / KILL + cheapest 48-hour test |
| `/session-handoff` | When user says "wrap up", "hand off", "summarize before I clear", "session handoff" — or before any `/clear`. Chat-only structured summary, never writes a file |

**Superpowers skills** auto-trigger based on context (brainstorming, TDD, debugging, code review, planning, subagents, git worktrees). No manual invoke needed.

**Additional auto-trigger rules:**
- `/roast` — invoke before any significant feature or product build when the idea is unvalidated. Fire on: "I'm thinking of building X", "what do you think of this idea?", "should I build this?", "pressure-test this", "roast this". Do not skip just because the user seems excited — sycophancy is the failure mode.
- `/session-handoff` — invoke when user says "wrap up", "hand off", "summarize before I clear", "session handoff", or is about to `/clear`. Also invoke proactively when context approaches ~250K tokens without a handoff having been run.
- `/auto-stage-commit` — invoke when user says "commit", "stage this", "let's commit", or shows intent to commit changes. Outputs the ready-to-run `git commit` command; does not execute it.

> Add skills: create `<name>/SKILL.md` in `.claude/skills/` → re-run `setup.sh` or restart Claude Code.

---

## MCP Servers

Defined in [`.mcp.json`](.mcp.json). Add credentials to [`.env`](.env.example).

> **Requires `uvx`:** `google-workspace-mcp`, `alpaca`, and `notebooklm-mcp` use `uvx`. Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`

| Server | Use For |
| ------ | ------- |
| `memory-shrunk` | **Replaces `memory`** — Caveman-compressed knowledge graph; ~50% metadata reduction on tool descriptions |
| `supabase-mcp` | Postgres database + Supabase platform — in-context queries/migrations; **CLI-first:** prefer `supabase` CLI for local dev, migrations, type gen, edge functions |
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
| `kie-ai` | Multi-provider AI media — Midjourney, Sora, ElevenLabs, Kling, Suno, etc. **CLI-first:** use `kie-cli` (zero context tokens); MCP is fallback. Auto-switches on failure. |
| `higgsfield` | Cinematic AI video/images — browser OAuth, no API key |
| `context7` | Live SDK/library documentation lookup — fetch on demand instead of loading static reference files |
| `monet-mcp` | Landing page UI components — search + retrieve React/TS code |
| `stitch` | Extract design DNA from screens (fonts, colors, layouts) |
| `21st-dev-magic` | UI component search + SVG brand logos |
| `playwright-mcp` | Interactive browser sessions (backup — prefer `node tools/playwright.js`) |
| `firecrawl-mcp` | Batch scraping / schema-driven extraction (backup — prefer `firecrawl` CLI) |
| `designlang-mcp` | Expose extracted design tokens via MCP after running `designlang <url>` — no API key; reads `./design-extract-output/` |
| `graphify-mcp` | Query codebase knowledge graph — `query_graph`, `get_node`, `get_neighbors`, `shortest_path`, `list_prs`, `get_pr_impact`; requires `graphify-out/graph.json` (build with `/graphify .`); optional `GRAPHIFY_API_KEY` for HTTP auth |

> **Setup:** Copy [`.claude/settings.local.json.example`](.claude/settings.local.json.example) → `.claude/settings.local.json`. The `__activation_guide` inside lists where to get each credential.

---

## LightRAG Server Setup

Graph-based RAG with multimodal support. See [`tools/lightrag-plus/README.md`](tools/lightrag-plus/README.md).

**Quick start:**

```bash
cd tools/lightrag-plus && UV_NATIVE_TLS=true uv sync --all-extras && cp .env.example .env
# Add OPENAI_API_KEY (+ SUPABASE_MANAGEMENT_TOKEN if ENABLE_SUPABASE=true) to .env, then:
uv run python provision.py          # Auto-creates schema/index if backends enabled (idempotent)
uv run python check_update.py      # Check for lightrag-hku updates (add --upgrade to apply)
uv run python src/server.py --port 9621 --working-dir ./rag_storage
# Or: Press F5 → "LightRAG Server" (VSCode) / run start_server.bat — both use src/server.py automatically
# LLM_TIMEOUT=1800 + EMBEDDING_TIMEOUT=60 in .env extend Ollama timeouts (defaults 180s/30s are too short for large chunks; 1800s required on slow hardware)
# EMBEDDING_BINDING_HOST in .env fixes the LLM_BINDING_HOST bleed-into-OpenAI-embedding bug (--embedding-binding-host CLI flag removed in newer lightrag-hku)
```

**LightRAGPlus server (`src/server.py`) vs vanilla server:**

| | `src/server.py` (default) | `lightrag.api.lightrag_server` (bypass) |
| --- | --- | --- |
| Text uploads (PDF/MD/TXT) | local graph + cloud mirror | local graph only |
| Media uploads | `/api/plus/insert-media` endpoint | not supported |
| Embedding host bug fix | `EMBEDDING_BINDING_HOST` in `.env` (CLI flag removed in newer lightrag-hku) | requires env var |

**Extra endpoints added by `src/server.py`:**

- `GET /api/plus/status` — backend config + health check
- `POST /api/plus/insert-media` — image/audio/video → cloud backends only (requires `MULTIMODAL_MODE=advanced` + `EMBEDDING_PROVIDER=gemini`)

**Known gotcha — embedding 404:** `LLM_BINDING_HOST=http://localhost:11434` (Ollama) bleeds into OpenAI embedding calls via `get_default_host("openai")`. Fix: `EMBEDDING_BINDING_HOST=https://api.openai.com/v1` in `.env` (already set). The `--embedding-binding-host` CLI flag was removed in newer lightrag-hku — env var is the only fix.

**Running integration tests (Windows):**

```bash
# Step 1: sync venv once (do NOT use `uv run pytest` — it re-syncs on every call and hits Windows file locks)
cd tools/lightrag-plus && UV_NATIVE_TLS=true uv sync --all-extras

# Step 2: run tests directly via venv python (repeatable, no re-sync)
.venv\Scripts\python.exe -m pytest tests/test_integration.py -v

# If uv sync fails with "Access is denied" or missing RECORD files — self-heal first:
Remove-Item -Force -Recurse .venv\Lib\site-packages\regex-*.dist-info -ErrorAction SilentlyContinue
Remove-Item -Force -Recurse .venv\Lib\site-packages\proto_plus-*.dist-info -ErrorAction SilentlyContinue
UV_NATIVE_TLS=true uv sync --all-extras
```

**Access:** [Web UI + API Docs](http://localhost:9621)

---

## OpenSpace Integration Tests

Tests live at `tests/openspace/` (outside the submodule — preserves auto-sync). Three tiers: Tier 1 no key, Tier 2 any LLM key, Tier 3 `OPENSPACE_API_KEY`.

```bash
# Step 1: install pytest into openspace venv (one-time)
cd tools/openspace && uv pip install pytest pytest-asyncio python-dotenv

# Step 2: run from project root (repeatable)
cd C:\GIT\Claude_Code_Boilerplate_Framework
tools\openspace\.venv\Scripts\python.exe -m pytest tests\openspace\ -v

# Tier 1 only (no API key needed):
tools\openspace\.venv\Scripts\python.exe -m pytest tests\openspace\ -v -k "not TestOpenSpaceInit and not TestCloudRegistry"
```

Tier 2 tests (`TestOpenSpaceInit`) read LLM key from `tools/openspace/.env` or OS env — they call `initialize()` with shell-only backend (no task execution, no token cost). Tier 3 tests (`TestCloudRegistry`) require `OPENSPACE_API_KEY`.

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
| Playwright Chromium download fails: `UNABLE_TO_GET_ISSUER_CERT_LOCALLY` | Corporate proxy intercepts TLS. Fix: `NODE_TLS_REJECT_UNAUTHORIZED=0 npx playwright install chromium` — baked into `sys-npm-deps.sh` automatically |
| `uv sync` fails with `UnknownIssuer` / `invalid peer certificate` | Corporate proxy intercepts TLS. Fix: `UV_NATIVE_TLS=true uv sync` — uses Windows cert store. Already baked into `update-all.sh`. |
| LightRAG uploads fail: `httpx.ReadTimeout` during entity extraction | Ollama LLM exceeds default timeout on large chunks. Fix: increase `LLM_TIMEOUT` in `tools/lightrag-plus/.env` — set `1800` (30 min) for slow hardware. Both `asyncio.wait_for` and httpx client use this value. `--timeout` CLI arg only affects gunicorn, not uvicorn — do NOT use it. |
| `designlang` postinstall fails with Playwright/SSL error | Corporate proxy blocks Playwright browser download. Fix: `npm install -g designlang --ignore-scripts` — CLI works fully without the Playwright browser |

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
