# Claude-Code Boilerplate Framework

This file is the entry point for every Claude Code session. It defines **how we work**, not what we're building. Keep it short. If a rule doesn't change behavior, it doesn't belong here.

## Core Philosophy: The WAT Framework

Every task flows through three layers:

```txt
Workflows  →  Agents (Claude)  →  Tools
(what to do)  (how to decide)   (how to execute)
```

- **Workflows** are Markdown SOPs in `workflows/` — plain-language instructions for recurring tasks
- **Agents** (you) handle reasoning, coordination, and recovery from failures
- **Tools** are Python scripts in `tools/` that execute deterministically

**Why this matters:** AI chained through 5 steps at 90% accuracy = 59% success. Offload execution to deterministic scripts; keep Claude focused on orchestration.

> Full architecture: [`.claude/rules/agent-instructions.md`](.claude/rules/agent-instructions.md)

## Project Structure

```txt
CLAUDE.md                    ← You are here (philosophy only)
.claude/
  rules/                     ← Auto-loaded instructions per domain
  agents/                    ← Custom sub-agent definitions
  skills/                    ← Reusable slash-command skills
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

**Deliverables always go to cloud services** (Google Sheets, Slides, etc.) where they're accessible. Local files are for processing only.

## Rules (Auto-Loaded)

All `.md` files in `.claude/rules/` are loaded automatically every session.

| File | Purpose |
| ------ | --------- |
| [`agent-instructions.md`](.claude/rules/agent-instructions.md) | WAT framework — how to coordinate workflows, tools, and error recovery |
| [`trigger-workflow-builder.md`](.claude/rules/trigger-workflow-builder.md) | Step-by-step guide for building Trigger.dev automations |
| [`trigger-api-reference.md`](.claude/rules/trigger-api-reference.md) | Full Trigger.dev SDK v4 code patterns and examples |
| [`frontend-instructions.md`](.claude/rules/frontend-instructions.md) | Frontend design standards, screenshot workflow, anti-generic guardrails |
| [`memory-guidelines.md`](.claude/rules/memory-guidelines.md) | When and what to save to memory — auto-update trigger rules |
| [`memory-profile.md`](.claude/rules/memory-profile.md) | Facts about the user — role, background, domain knowledge |
| [`memory-preferences.md`](.claude/rules/memory-preferences.md) | How the user likes Claude to behave and communicate |
| [`memory-decisions.md`](.claude/rules/memory-decisions.md) | Architectural decisions with dates and rationale |
| [`memory-sessions.md`](.claude/rules/memory-sessions.md) | Log of substantive work completed each session |

## Memory: Auto-Update (MANDATORY)

**Update memory files as you go — not at the end of a session.**

| Trigger | File to update |
| --------- | ---------------- |
| User shares a fact about themselves | `memory-profile.md` |
| User states a preference | `memory-preferences.md` |
| A non-trivial decision is made | `memory-decisions.md` (with date) |
| Substantive work is completed | `memory-sessions.md` |

**Do not ask. Just update.**

> Full rules: [`.claude/rules/memory-guidelines.md`](.claude/rules/memory-guidelines.md)

## MCP Servers

Defined in [`.mcp.json`](.mcp.json), loaded automatically. Credentials live in [`.env`](.env.example).

| Server | Use for |
| -------- | --------- |
| `supabase-mcp` | Database queries, auth, storage |
| `openrouter-mcp` | Multi-model LLM routing |
| `tavily-mcp` | Web search and research |
| `google-workspace-mcp` | Gmail, Drive, Sheets, Docs, Calendar |
| `pinecone-mcp` | Vector search / RAG |
| `n8n-mcp` | n8n workflow automation |
| `vapi-mcp` | Voice AI |
| `apify` | Web scraping |
| `zep-mcp` | Long-term memory (Zep docs) |
| `alpaca-mcp` | Algorithmic trading |
| `canva-dev` | Canva app development |
| `kie-ai` | AI media generation |

## Hooks

| Hook | File | Behavior |
| ------ | ------ | --------- |
| `Stop` | [`.claude/hooks/stop.sh`](.claude/hooks/stop.sh) | Scans session for fixes/discoveries; prompts `/reflect` if warranted |

> Add new hooks in [`.claude/settings.json`](.claude/settings.json) under `"hooks"`.

## Agents & Skills

- **Agents** — custom sub-agents in `.claude/agents/` (definitions for specialized roles)
- **Skills** — reusable slash-commands in `.claude/skills/` (invoke with `/skill-name`)

These directories are currently empty placeholders — add your own as the project grows.

## Environment Variables

All secrets live in `.env` (gitignored). Copy `.env.example` to `.env` and fill in only what you need.

**Security rules:**

- Never log secret values
- Never hardcode credentials — not even temporarily
- Validate at the top of every task: `if (!apiKey) throw new Error("KEY not set")`
- Before deploying: add ALL env vars to the Trigger.dev dashboard (local `.env` alone is not enough)

## Working Principles

1. **Look before you build** — check `tools/` for existing scripts before writing new ones
2. **Fail forward** — read errors fully, fix root causes, update the relevant workflow so it doesn't happen again
3. **Workflows evolve** — update `workflows/` when you find better methods or hit new constraints; don't overwrite without asking
4. **No speculation** — only build what the task requires; no extra features, fallbacks, or abstractions for hypothetical needs
5. **Cloud = truth** — final outputs always go to cloud services; local `.tmp/` is scratch space only
6. **Never deploy without approval** — always confirm the automation works locally before pushing to production

## Quick Reference

```txt
New automation?      → Read workflows/ → Check tools/ → Follow agent-instructions.md
Trigger.dev task?    → Follow trigger-workflow-builder.md + trigger-api-reference.md
Frontend work?       → Invoke frontend-design skill first → Follow frontend-instructions.md
Something broke?     → Read error → Fix tool → Verify → Update workflow
End of session?      → Update memory-sessions.md if substantive work was done
```
