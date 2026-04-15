# Claude-Code Boilerplate Framework

## Purpose

This is the entry point for every Claude Code session to provide the context and tooling needed to design various frameworks. It defines **how we work**, not what we're building. Keep it short. If a rule doesn't change behavior, it doesn't belong here.

---

## What Are You Building?

Start here — each path routes to the right tools and rules.

| Building | Start With | Key Rules |
| ---------- | ----------- | ----------- |
| Trigger.dev automation | `workflows/` → `tools/` | [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md), [`trigger-api-reference.md`](.claude/rules/trigger-api-reference.md) |
| Frontend UI | `/frontend-design` skill → `ui-ux-pro-max` design system | [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) → [`ui-ux-pro-max-instructions.md`](.claude/rules/ui-ux-pro-max-instructions.md) |
| Claude AI agent | `agent-sdk-dev` plugin → `.claude/agents/` | [`agent-instructions.md`](.claude/rules/agent-instructions.md) |
| Slash-command skill | `.claude/skills/` — add a `.md` file | Invoke with `/skill-name`; see existing skills below |
| MCP server integration | `.mcp.json` + `.env` | Add server config, add credentials, restart Claude Code |
| Claude API / SDK app | `/claude-api` skill | Scaffolds Anthropic SDK boilerplate |
| n8n workflow | `n8n-mcp` tools | Search nodes, validate, build via MCP |
| Voice AI (Vapi) | `vapi-mcp` tools | Create assistants, calls, phone numbers |
| Web scraping | `apify` MCP | Search actors, fetch details, call actors |
| Vector search / RAG | `pinecone-mcp` tools | Upsert, search, rerank records |

---

## Key Commands

```bash
# Open this project in Claude Code
claude .

# Trigger.dev — start local dev runner
npx trigger.dev@latest dev

# Re-run first-time setup (e.g. fresh clone)
rm -f .claude/.setup-complete && bash .claude/scripts/setup.sh

# Reinstall context-monitor statusline
npx claude-code-templates@latest --setting statusline/context-monitor
```

---

## Core Philosophy: The WAT Framework

Every task flows through three layers:

```txt
Workflows  →  Agents (Claude)  →  Tools
(what to do)  (how to decide)   (how to execute)
```

- **Workflows** — Markdown SOPs in `workflows/` defining what to do and in what order
- **Agents** — You (Claude): reasoning, coordination, and recovery from failures
- **Tools** — Python scripts in `tools/` that execute deterministically

**Why this matters:** AI chained through 5 steps at 90% accuracy = 59% success. Offload execution to deterministic scripts; keep Claude focused on orchestration.

> Full architecture details: [`agent-instructions.md`](.claude/rules/agent-instructions.md)

---

## Project Structure

```txt
CLAUDE.md                    ← You are here (philosophy + routing only)
.claude/
  rules/                     ← Auto-loaded instructions (all .md files loaded every session)
  agents/                    ← Custom sub-agent definitions
  skills/                    ← Reusable slash-command skills (add .md → get /skill-name)
  hooks/                     ← Lifecycle shell scripts (Stop, PreToolUse, etc.)
  scripts/                   ← Utility scripts (status line, context monitor)
  docs/                      ← Reference PDFs and guides
.mcp.json                    ← MCP server definitions (version-controlled)
.env                         ← API keys (gitignored — never commit)
.env.example                 ← Template for all required keys
tools/                       ← Python scripts for deterministic execution
workflows/                   ← Markdown SOPs defining automation tasks
src/trigger/                 ← Trigger.dev TypeScript task files
brand_assets/                ← Logos, color guides, design tokens
.tmp/                        ← Scratch space — disposable, regenerable
```

---

## Plugins (Enabled)

Plugins extend Claude Code with specialized modes and skills. Invoke via `/plugin-skill-name`.

| Plugin | Provides | Use When |
| -------- | ---------- | --------- |
| `frontend-design` | `/frontend-design` skill | Building any UI — **always invoke before writing frontend code** |
| `ui-ux-pro-max` | Design intelligence — 67 styles, 161 palettes, 57 fonts, 99 UX rules | Every frontend task — run `--design-system` before writing any UI code |
| `agent-sdk-dev` | Agent scaffolding tools | Creating custom Claude sub-agents |
| `claude-code-setup` | Project setup automation | Bootstrapping a new Claude Code project |
| `claude-md-management` | CLAUDE.md creation/editing | Refactoring or generating instruction files |
| `playground` | Sandboxed experimentation | Testing prompts and tool chains without side effects |
| `superpowers` | Full dev workflow — TDD, planning, subagents, debugging, code review | Any non-trivial feature or fix — triggers automatically based on context |
| `skill-creator` | Create, edit, test, and benchmark skills | When building or refining slash-command skills |

> Disabled: `github`, `pinecone`, `supabase`, `plugin-dev` — enable in [`.claude/settings.json`](.claude/settings.json) → `enabledPlugins`.

---

## Skills (Built-In Slash Commands)

Always available regardless of plugins. Invoke with `/skill-name`.

| Slash Command | Use When |
| -------------- | --------- |
| `/frontend-design` | Starting any frontend task (mandatory first step) |
| `/claude-api` | Scaffolding an app with the Anthropic SDK or Claude Agent SDK |
| `/simplify` | Reviewing changed code for quality, reuse, and efficiency |
| `/schedule` | Creating cron-scheduled remote agents |
| `/loop 5m /command` | Running a prompt or command on a recurring interval |
| `/update-config` | Configuring hooks, permissions, and automated behaviors in `settings.json` |
| `/keybindings-help` | Customizing keyboard shortcuts in `keybindings.json` |

**Superpowers skills** (auto-trigger based on context — no manual invoke needed):

| Slash Command | When It Fires |
| -------------- | -------------- |
| `/brainstorming` | Before writing any code — refines rough ideas, explores alternatives, saves design doc |
| `/writing-plans` | After design approval — breaks work into 2–5 min tasks with file paths and verification steps |
| `/subagent-driven-development` | Executing a plan — dispatches subagents per task with two-stage review |
| `/executing-plans` | Alternative to subagent-dev — batch execution with human checkpoints |
| `/test-driven-development` | During implementation — enforces RED-GREEN-REFACTOR cycle |
| `/systematic-debugging` | Diagnosing a bug — 4-phase root cause process |
| `/verification-before-completion` | Before marking anything done — confirms the fix actually works |
| `/requesting-code-review` | Between tasks — reviews against plan, blocks on critical issues |
| `/receiving-code-review` | After getting review feedback — structured response workflow |
| `/dispatching-parallel-agents` | When tasks are independent — concurrent subagent execution |
| `/using-git-worktrees` | After design approval — isolates work on a new branch with clean test baseline |
| `/finishing-a-development-branch` | When tasks complete — verifies tests, presents merge/PR/discard options |
| `/writing-skills` | Creating a new reusable skill — follows best practices with adversarial testing |

> Add project-specific skills: create `.md` files in `.claude/skills/` — they become `/skill-name` commands automatically.

---

## Agents

Custom sub-agents live in `.claude/agents/`. Each agent is a `.md` file defining a specialized role, tool access, and behavior constraints.

- Use the `agent-sdk-dev` plugin to scaffold new agent definitions
- Agents can be invoked as sub-processes within the WAT framework for parallel or specialized work
- See [`agent-instructions.md`](.claude/rules/agent-instructions.md) for orchestration patterns

---

## MCP Servers

Defined in [`.mcp.json`](.mcp.json), loaded automatically. Add credentials to [`.env`](.env.example).

> **Requires `uvx`:** `google-workspace-mcp` and `alpaca` use `uvx` (not `npx`). Install with: `curl -LsSf https://astral.sh/uv/install.sh | sh`

| Server | Tools Available | Use For |
| -------- | ---------------- | --------- |
| `memory` | create/search entities, relations, observations | Persistent knowledge graph memory across sessions |
| `supabase-mcp` | DB queries, auth, storage, migrations | Postgres database + Supabase platform |
| `openrouter-mcp` | Chat, compare models, benchmark | Multi-model LLM routing |
| `tavily-mcp` | Search, extract, crawl, research | Web search and content extraction |
| `google-workspace-mcp` | Gmail, Drive, Sheets, Docs, Calendar, Forms | Google productivity suite |
| `pinecone-mcp` | Upsert, search, rerank, describe indexes | Vector search / RAG |
| `n8n-mcp` | Search nodes, validate, get templates | n8n workflow automation |
| `vapi-mcp` | Create assistants, calls, phone numbers, tools | Voice AI (Vapi) |
| `apify` | Search actors, call actors, get output | Web scraping (Apify marketplace) |
| `zep-mcp` | Search Zep documentation | Long-term memory research |
| `alpaca-mcp` | Stock bars, trading operations | Algorithmic trading (paper mode) |
| `canva-dev` | Canva app SDK, UI kit, CLI docs | Canva app development |
| `kie-ai` | Image, video, audio, lip-sync generation | AI media generation |

---

## Rules (Auto-Loaded)

All `.md` files in `.claude/rules/` are loaded automatically every session.

| File | Purpose |
| ------ | --------- |
| [`agent-instructions.md`](.claude/rules/agent-instructions.md) | WAT framework — orchestration, tool use, error recovery |
| [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md) | Step-by-step guide for building Trigger.dev automations |
| [`trigger-api-reference.md`](.claude/rules/trigger-api-reference.md) | Full Trigger.dev SDK v4 code patterns and examples |
| [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) | Frontend standards, screenshot workflow, anti-generic guardrails — loads `ui-ux-pro-max-instructions.md` |
| [`ui-ux-pro-max-instructions.md`](.claude/rules/ui-ux-pro-max-instructions.md) | Design intelligence — 67 styles, 161 palettes, 57 fonts, 99 UX rules, pre-delivery checklist |
| [`memory-guidelines.md`](.claude/rules/memory-guidelines.md) | When and what to save — auto-update trigger rules |
| [`memory-profile.md`](.claude/rules/memory-profile.md) | User role, background, domain knowledge |
| [`memory-preferences.md`](.claude/rules/memory-preferences.md) | How the user likes Claude to behave and communicate |
| [`memory-decisions.md`](.claude/rules/memory-decisions.md) | Architectural decisions with dates and rationale |
| [`memory-sessions.md`](.claude/rules/memory-sessions.md) | Log of substantive work completed each session |
| [`karpathy-guidelines.md`](.claude/rules/karpathy-guidelines.md) | Coding behavior rules: think first, simplicity, surgical edits, goal-driven execution |

---

## Memory: Auto-Update (MANDATORY)

**Update memory files as you go — not at the end of a session.**

| Trigger | File to update |
| --------- | ---------------- |
| User shares a fact about themselves | `memory-profile.md` |
| User states a preference | `memory-preferences.md` |
| A non-trivial decision is made | `memory-decisions.md` (with date) |
| Substantive work is completed | `memory-sessions.md` |

**Do not ask. Just update.**

> Full rules: [`memory-guidelines.md`](.claude/rules/memory-guidelines.md)

---

## Hooks

| Hook | File | Behavior |
| ------ | ------ | --------- |
| `Stop` | [`.claude/hooks/stop.sh`](.claude/hooks/stop.sh) | Scans session for fixes/discoveries; prompts `/reflect` if warranted |

> Add new hooks in [`.claude/settings.json`](.claude/settings.json) under `"hooks"`.

---

## Environment Variables

All secrets live in `.env` (gitignored). Copy `.env.example` → `.env` and fill in only what you need.

- Never log secret values — never hardcode credentials, even temporarily
- Validate at task start:

```ts
if (!apiKey) throw new Error("KEY not set");
```

- Before deploying: add ALL env vars to the Trigger.dev dashboard — local `.env` is not enough

---

## Working Principles

1. **Look before you build** — check `tools/` for existing scripts before writing new ones
2. **Fail forward** — read errors fully, fix root causes, update the workflow so it doesn't recur
3. **Workflows evolve** — update `workflows/` when you find better methods; don't overwrite without asking
4. **No speculation** — only build what the task requires; no extra features or hypothetical abstractions
5. **Cloud = truth** — final outputs go to cloud services; `.tmp/` is scratch space only
6. **Never deploy without approval** — confirm automation works locally before pushing to production
