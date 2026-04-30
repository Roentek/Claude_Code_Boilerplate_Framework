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
| Slash-command skill | `~/.claude/skills/<name>/SKILL.md` | Skills must be subdirectory + `SKILL.md`; `setup.sh` auto-installs |
| MCP server integration | `.mcp.json` + `.claude/settings.local.json` | Copy `settings.local.json.example` → `settings.local.json`, fill keys, restart |
| Claude API / SDK app | `/claude-api` skill | Scaffolds Anthropic SDK boilerplate |
| n8n workflow | `n8n-mcp` tools | Search nodes, validate, build via MCP |
| Voice AI (Vapi) | `vapi-mcp` tools | Create assistants, calls, phone numbers |
| Browser automation | `/playwright` skill → `tools/playwright.js` | `workflows/browser-automation.md` — CLI first; `playwright-mcp` as backup |
| Web scraping (single page / crawl) | `/firecrawl` skill → `firecrawl` CLI | `workflows/web-scraping.md` — CLI first; `firecrawl-mcp` backup for batch/schema |
| Web scraping (large-scale / actors) | `apify` MCP | Search actors, fetch details, call actors |
| Vector search / RAG | `pinecone-mcp` tools | Upsert, search, rerank records |
| UI component search | `monet-mcp` tools | Search landing page components, get React/TS code |
| UI component inspiration / SVG logos | `21st-dev-magic` tools | Search UI components, SVG brand logos, generate variants |
| AI image/video (cinematic, managed) | `higgsfield` MCP | No API key — browser OAuth; cinematic video, media library |
| AI image/video/audio (specific model) | `kie-ai` MCP | Midjourney, Sora, ElevenLabs, Kling, Suno, etc. Requires API key |

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
```

> **MCP credential gotcha:** `.mcp.json` `${VAR}` substitution reads from the **OS process environment**, not `.env`. On a fresh machine, run `setx VAR_NAME "value"` (Windows) or `export VAR_NAME=value` (Unix) in your terminal before starting Claude Code.

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
tools/                        ← Python scripts for deterministic execution
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
| `/compact-memory` | Full memory hygiene — compress sessions, prune decisions, sync facts to MCP graph |

**Superpowers skills** auto-trigger based on context (brainstorming, TDD, debugging, code review, planning, subagents, git worktrees). No manual invoke needed.

> Add skills: create `<name>/SKILL.md` in `.claude/skills/` → re-run `setup.sh` or restart Claude Code.

---

## MCP Servers

Defined in [`.mcp.json`](.mcp.json). Add credentials to [`.env`](.env.example).

> **Requires `uvx`:** `google-workspace-mcp` and `alpaca` use `uvx`. Install: `curl -LsSf https://astral.sh/uv/install.sh | sh`

| Server | Use For |
| ------ | ------- |
| `memory` | Persistent knowledge graph memory across sessions |
| `supabase-mcp` | Postgres database + Supabase platform |
| `openrouter-mcp` | Multi-model LLM routing, benchmarking |
| `tavily-mcp` | Web search and content extraction |
| `google-workspace-mcp` | Gmail, Drive, Sheets, Docs, Calendar, Forms |
| `pinecone-mcp` | Vector search / RAG |
| `n8n-mcp` | n8n workflow automation |
| `vapi-mcp` | Voice AI — assistants, calls, phone numbers |
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

## Hooks

| Hook | File | Behavior |
| ---- | ---- | -------- |
| `PreToolUse` (Read) | [`.claude/hooks/read-guard.py`](.claude/hooks/read-guard.py) | Warns when large files are read without `offset`+`limit` to save tokens |
| `Stop` | [`.claude/hooks/stop.sh`](.claude/hooks/stop.sh) | Scans session for fixes; auto-drafts memory entries; flags tracked-path doc changes |
| `PostToolUse` (Write/Edit) | [`.claude/hooks/autosync-docs.sh`](.claude/hooks/autosync-docs.sh) | After edits to tracked paths, injects context to update CLAUDE.md/README.md |
| `pre-commit` (git) | [`.claude/hooks/pre-commit.sh`](.claude/hooks/pre-commit.sh) | Auto-updates CLAUDE.md and README.md before commits that touch tracked paths |

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

Full rules: [`memory-guidelines.md`](.claude/rules/memory-guidelines.md)
