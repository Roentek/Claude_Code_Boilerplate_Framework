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
