# Memory Guidelines

## Auto-Update Memory (MANDATORY)

**Update memory files AS YOU GO, not at the end.** When you learn something new, update immediately.

| Trigger | Action |
|---------|--------|
| User shares a fact about themselves | → Update `memory-profile.md` |
| User states a preference | → Update `memory-preferences.md` |
| A decision is made | → Update `memory-decisions.md` with date |
| Completing substantive work | → Add to `memory-sessions.md` |

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

## Two-Tier Memory System

This project has two memory layers. Use the right one for the right purpose.

### Tier 1: File-Based Memory (`.claude/rules/memory-*.md`)

Markdown files auto-loaded every session. Best for **human-readable, session-priming context** that Claude should absorb at startup.

| File | Stores |
|------|--------|
| `memory-profile.md` | User role, background, domain knowledge |
| `memory-preferences.md` | Communication style, workflow preferences |
| `memory-decisions.md` | Architecture decisions with dates |
| `memory-sessions.md` | Session log of substantive work |

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
| "User prefers concise responses" | File-based (`memory-preferences.md`) |
| "We chose Supabase over PlanetScale on 2026-04-07" | File-based (`memory-decisions.md`) |
| "This project uses the `jobs` table in Supabase" | Knowledge graph (entity + observation) |
| "The `scraper` service depends on `apify` and outputs to `supabase`" | Knowledge graph (entities + relations) |
| "Searching for all entities related to a service" | Knowledge graph (`search_nodes`) |

**Never duplicate** the same fact across both tiers. Pick the tier that best matches the query pattern you'll use to retrieve it.
