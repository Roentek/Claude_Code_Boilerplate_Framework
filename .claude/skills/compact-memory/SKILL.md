---
name: compact-memory
description: Full memory hygiene cycle — compresses memory-sessions.md, deduplicates memory-decisions.md, and syncs key project facts to the memory MCP graph. Run monthly or when context feels heavy.
---

Run the following steps in order. Report results after each step.

## Step 1: Compress sessions

Read `.claude/rules/memory-sessions.md`. Summarize all entries older than 30 days into a `## Archive` block. Keep the 4 most recent sessions in full. Rewrite the file.

Report: lines before → lines after.

## Step 2: Prune decisions

Read `.claude/rules/memory-decisions.md`. Identify decisions whose tools, files, or patterns no longer exist in the project (check with Glob/Grep). Remove obsolete entries. Flag anything you removed so the user can restore it if needed.

Report: decisions before → decisions after, what was removed.

## Step 3: Sync to knowledge graph

Extract 3–5 key project facts from the memory files (active integrations, key constraints, architectural choices). Write each as an entity to the `memory` MCP graph using `mcp__memory__create_entities`. This makes them queryable in future sessions without loading the full files.

Report: entities written.

## Step 4: Summary

Print a single table: lines saved, decisions pruned, entities synced.
