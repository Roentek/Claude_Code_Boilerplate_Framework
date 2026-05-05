# Memory Guidelines

## Auto-Update Memory (MANDATORY)

**Update memory files AS YOU GO, not at the end.** When you learn something new, update immediately.

| Trigger | Action |
|---------|--------|
| User shares a fact about themselves | → Update [`memory-profile.md`](memory-profile.md) |
| User states a preference | → Update [`memory-preferences.md`](memory-preferences.md) |
| A decision is made | → Update [`memory-decisions.md`](memory-decisions.md) with date |
| Completing substantive work | → Add to [`memory-sessions.md`](memory-sessions.md) |

**Skip:** Quick factual questions, trivial tasks with no new info.

**DO NOT ASK. Just update the files when you learn something.**

## What To Capture

- **Decisions with rationale** — architecture choices, tool selections, API preferences, and *why*
- **Recurring corrections** — anything corrected more than once; save it so it never needs repeating
- **Non-obvious constraints** — rate limits, auth quirks, edge cases discovered through debugging
- **Workflow preferences** — output formats, verbosity, communication style, how tasks should be structured
- **Project-specific context** — business rules, naming conventions, integration details not in the code
- **Confirmed approaches** — when an unusual or non-default approach was validated by the user

## What NOT to Capture

- **Derivable from code** — file structure, class names, function signatures — read the code instead
- **Git history** — `git log` is authoritative
- **Ephemeral task state** — in-progress todos or "just finished X" — belongs in a plan/task list
- **Already in CLAUDE.md** — never duplicate what's in a rules file
- **Secrets or credentials** — never write API keys or tokens to memory files

## Memory Decay

Memories about rapidly-changing state go stale fast. When recalling them, verify against current code before acting. If a memory conflicts with current state, trust what you observe now — then update or delete the stale entry.

---

## Three-Tier Memory System + Compression Layer

This project has three memory tiers plus an optional compression layer. Use the right one for the right purpose.

### Tier 1: File-Based Memory (`.claude/rules/memory-*.md`)

Markdown files auto-loaded every session. Best for **human-readable, session-priming context** that Claude should absorb at startup.

| File | Stores |
|------|--------|
| [`memory-profile.md`](memory-profile.md) | User role, background, domain knowledge |
| [`memory-preferences.md`](memory-preferences.md) | Communication style, workflow preferences |
| [`memory-decisions.md`](memory-decisions.md) | Architecture decisions with dates |
| [`memory-sessions.md`](memory-sessions.md) | Session log of substantive work |

**Use for:** Preferences, decisions, user facts, session summaries — anything narrative or contextual.

### Tier 2: Knowledge Graph Memory (`memory` MCP — `@modelcontextprotocol/server-memory`)

A persistent graph database of **entities**, **relations**, and **observations**. Survives across sessions independently of file edits.

| Tool | Purpose |
|------|---------|
| `mcp__memory__create_entities` | Create named nodes (people, projects, concepts, services) |
| `mcp__memory__create_relations` | Link two entities (e.g., "project uses supabase") |
| `mcp__memory__add_observations` | Attach facts to an existing entity |
| `mcp__memory__search_nodes` | Semantic/keyword search across the graph |
| `mcp__memory__open_nodes` | Retrieve specific entities by name |
| `mcp__memory__read_graph` | Dump the full graph (use sparingly) |
| `mcp__memory__delete_entities` | Remove a node and all its relations |
| `mcp__memory__delete_observations` | Remove specific facts from an entity |
| `mcp__memory__delete_relations` | Remove a specific link between entities |

**Use for:** Structured, queryable facts — API integrations, service configurations, project entities, dependency maps, and anything you'd want to look up by name or relationship rather than read narratively.

### Decision Rule

| Situation | Use |
|-----------|-----|
| "User prefers concise responses" | File-based ([`memory-preferences.md`](memory-preferences.md)) |
| "We chose Supabase over PlanetScale on 2026-04-07" | File-based ([`memory-decisions.md`](memory-decisions.md)) |
| "This project uses the `jobs` table in Supabase" | Knowledge graph (entity + observation) |
| "The `scraper` service depends on `apify` and outputs to `supabase`" | Knowledge graph (entities + relations) |
| "Searching for all entities related to a service" | Knowledge graph (`search_nodes`) |

**Never duplicate** the same fact across both tiers. Pick the tier that best matches the query pattern you'll use to retrieve it.

### Tier 3: Compression Layer (Caveman — Optional)

An **optional token optimization layer** that reduces context overhead across all memory tiers without changing their structure.

| Tool | Purpose |
|------|---------|
| `/caveman` | Activate 75% token reduction on all Claude responses (lite/full/ultra modes) |
| `/caveman-compress` | Shrink memory files (memory-*.md, CLAUDE.md) by ~46% — preserves code/URLs/paths exactly |
| `/caveman-stats` | Show actual token usage and savings from session JSONL |
| `memory-shrunk` MCP | Wraps the `memory` MCP server to compress tool descriptions (~50% metadata reduction) |
| `/caveman-commit` | Generate terse commit messages (≤50 chars, Conventional Commits format) |
| `/caveman-review` | Single-line PR comments: "L42: 🔴 bug: user null. Add guard" |
| `/cavecrew` | Compressed subagents (investigator/builder/reviewer with 60% fewer tokens) |

**How it integrates:**

- **Input compression:** `/caveman-compress` can shrink Tier 1 memory files; `memory-shrunk` MCP compresses Tier 2 tool descriptions
- **Output compression:** `/caveman` reduces all Claude responses by 75% without affecting memory storage
- **Session tracking:** `/caveman-stats` reads Claude Code session JSONL for actual token counts and cost analysis
- **Statusline badge:** `CAVEMAN_STATUSLINE_SAVINGS=1` shows lifetime token savings in statusline

**When to use:**

- **Heavy sessions:** Enable `/caveman` when working with large codebases or long research tasks
- **Memory cleanup:** Run `/caveman-compress` on memory files after `/compact-memory` for additional savings
- **Cost optimization:** Use `/caveman-stats` to track token costs and identify high-usage patterns
- **Quick commits/reviews:** Use `/caveman-commit` and `/caveman-review` for terse, token-efficient git workflows

**Trade-offs:**

- **Readability:** Compressed output is telegraphic (fragments, dropped articles) — readable but less formal
- **Reversibility:** Memory file compression is one-way; keep backups if experimenting
- **Selective use:** Not needed for simple queries; most valuable in long sessions with heavy context

Caveman is a **transparent optimization layer** — it doesn't change what you store or how you query it, just how much space it takes.
