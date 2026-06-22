---
name: codeburn
description: AI spend analytics — see where your token budget goes by task, model, tool, and project across 31 AI coding tools including Claude Code. Use when the user asks about AI costs, token usage, spend breakdown, or wants to optimize their AI budget.
---

# CodeBurn — AI Spend Analytics

**See where your AI spend goes** — by task, model, tool, and project, across 31 AI tools (Claude Code, Codex, Cursor, Gemini CLI, Cline, and more).

## When to Use

- "How much am I spending on Claude Code?"
- "Show me my token usage breakdown"
- "Which tasks are costing the most?"
- "Am I using the right model for the job?"
- "Optimize my AI spend"
- Any cost/budget/token-usage question about AI tools

## Quick Start

```bash
# Interactive dashboard (last 7 days)
npx codeburn

# Or install globally (faster)
npm install -g codeburn
codeburn
```

## Core Commands

```bash
# Dashboard views
codeburn              # Interactive TUI — last 7 days (default)
codeburn today        # Today's usage
codeburn month        # This calendar month

# One-liner status
codeburn status                   # Today + month totals
codeburn status --format json     # Same as JSON

# Reports
codeburn overview                             # Plain-text monthly summary
codeburn report -p 30days                     # Rolling 30-day window
codeburn report -p all                        # All recorded sessions
codeburn report --from 2026-04-01 --to 2026-04-30  # Date range
codeburn report --format json                 # Full data as JSON

# Export
codeburn export                  # CSV (today, 7d, 30d)
codeburn export -f json          # JSON export

# Analysis
codeburn optimize                # Scan for waste + copy-paste fixes (30d)
codeburn optimize -p week        # Scope to last 7 days
codeburn compare                 # Side-by-side model comparison

# Web dashboard with charts
codeburn web                     # http://localhost:4747

# Filter by provider or project
codeburn report --provider claude
codeburn report --project my-app
```

## Task Categories (Auto-Classified)

| Category | What triggers it |
|----------|-----------------|
| Coding | Edit, Write tools |
| Debugging | Error/fix keywords + tool usage |
| Feature Dev | "add", "create", "implement" |
| Refactoring | "refactor", "rename", "simplify" |
| Testing | pytest, vitest, jest in Bash |
| Exploration | Read, Grep, WebSearch without edits |
| Planning | EnterPlanMode, TaskCreate tools |
| Delegation | Agent tool spawns |
| Git Ops | git push/commit/merge in Bash |
| Build/Deploy | npm build, docker, pm2 |
| Brainstorming | "brainstorm", "what if", "design" |
| Conversation | No tools, pure text exchange |
| General | Skill tool, uncategorized |

## Reading the Dashboard — Key Signals

| Signal | What it might mean |
|--------|--------------------|
| Cache hit < 80% | System prompt or context not stable |
| Lots of `Read` calls per session | Agent re-reading same files, missing context |
| Low 1-shot rate (Coding 30%) | Agent struggling with edits, retry loops |
| Opus dominating cost on small turns | Overpowered model for simple tasks |
| Conversation category dominant | Agent talking instead of doing |
| No MCP usage shown | Either not using MCP, or config is broken |

## Claude Code Data Location

CodeBurn reads Claude Code session files from:
```
~/.claude/projects/<sanitized-path>/<session-id>.jsonl
```

Each session carries: model name, token usage (input/output/cache read/cache write), tool_use blocks, timestamps. No data leaves your machine.

Multiple Claude config dirs: set `CLAUDE_CONFIG_DIRS` (`:` on POSIX, `;` on Windows).

## Installation

Already installed in this project. On fresh clones, `setup.sh` installs via:

```bash
npm install -g codeburn
```

Verify:
```bash
codeburn --version
```

## Upgrade

```bash
npm install -g codeburn@latest
# Or via /update-all skill
```

## Source

https://github.com/getagentseal/codeburn
