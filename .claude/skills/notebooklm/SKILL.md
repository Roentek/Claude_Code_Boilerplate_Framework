---
name: notebooklm
description: Google NotebookLM integration - create notebooks, add sources, generate AI content (podcasts, quizzes, mind maps, briefings, slides), query notebooks, run research agents, and manage research workflows
---

# NotebookLM CLI + MCP

Programmatic access to Google NotebookLM via CLI (`notebooklm`) and MCP server (`notebooklm-mcp`).
Source: https://github.com/teng-lin/notebooklm-py

## When to Use

- **Research & discovery**: Create notebooks, run web/Drive research agents, import sources
- **AI analysis**: Query notebooks, get summaries, configure chat personas
- **Content generation**: Podcasts, videos, quizzes, mind maps, briefings, flashcards, infographics, slides
- **Management**: Share notebooks, source labels, sync Drive sources

## CLI First (Always Primary)

Use `notebooklm` CLI commands via Bash tool for all operations.

```bash
# Auth
notebooklm login                                        # browser sign-in (one-time)
notebooklm auth check --test --json                     # verify auth
notebooklm doctor --fix                                 # diagnose + auto-fix issues

# Notebooks
notebooklm list
notebooklm create "Research Project" --use              # create + set active
notebooklm use <id>                                     # set active notebook
notebooklm rename "New Title"
notebooklm summary --topics

# Sources
notebooklm source add --url "https://example.com"
notebooklm source add --file /path/to/doc.pdf
notebooklm source add --text "Pasted content here"
notebooklm source add --youtube "https://youtube.com/watch?v=..."
notebooklm source list
notebooklm source delete <source-id>

# Chat
notebooklm chat ask "What are the key findings?"
notebooklm chat ask "Summarize this" --save-to-notes    # persist answer as note

# Content generation
notebooklm audio create                                 # podcast
notebooklm audio status <task-id>
notebooklm audio download <task-id> --output podcast.mp3

notebooklm video create
notebooklm video status <task-id>
notebooklm video download <task-id> --output video.mp4

notebooklm quiz create --difficulty medium
notebooklm quiz download <task-id> --output quiz.json --format json

notebooklm mind-map create
notebooklm mind-map download <task-id> --output mindmap.json

notebooklm briefing create
notebooklm flashcards create
notebooklm infographic create --orientation landscape
notebooklm slides create

# Notes
notebooklm note list
notebooklm note create "My insight"
notebooklm note delete <note-id>

# Research agents
notebooklm research add-web "enterprise AI adoption 2025"
notebooklm research add-web "cloud costs" --mode deep
notebooklm research add-drive "product roadmap"

# Sharing
notebooklm share public                                 # make public
notebooklm share invite user@example.com --role viewer

# Profiles (multiple Google accounts)
notebooklm profile create work
notebooklm profile switch work
notebooklm profile list

# MCP auto-config (run once)
notebooklm mcp install claude-code
```

## MCP Tools (Backup Only)

Only use when CLI cannot handle the task. Common MCP tools via `notebooklm-mcp`:
- `notebook_list`, `notebook_create`, `notebook_delete`, `notebook_query`
- `source_add`, `source_list`, `source_delete`, `source_sync_drive`
- `studio_create` (audio, video, quiz, mind_map, briefing, flashcards, infographic, slides)
- `download_artifact`, `export_artifact`
- `notebook_share_public`, `notebook_share_invite`
- `research_start` (web + Drive discovery)
- `note`, `label`, `tag`, `batch`, `pipeline`

## Authentication

**First use:**
```bash
uv tool install "notebooklm-py[browser]"
notebooklm login                    # browser opens, Chromium downloads ~170MB first time
notebooklm auth check --test --json # expect {"status": "ok"}
```

**Headless (CI/server):**
```bash
notebooklm login --master-token --account you@gmail.com
```

**Auth expires:** `notebooklm auth refresh` or `notebooklm login` again.

## Common Workflows

### Research Notebook from Web Sources

```bash
notebooklm create "Cloud Trends 2025" --use
notebooklm research add-web "cloud marketplace growth 2025" --mode deep
notebooklm chat ask "What are the top 3 trends?"
notebooklm audio create
notebooklm audio status <task-id>          # poll until done
notebooklm audio download <task-id> --output podcast.mp3
```

### Generate Multiple Content Types

```bash
# All generation is async — create → status → download
notebooklm audio create && notebooklm audio status <id> && notebooklm audio download <id>
notebooklm quiz create --difficulty hard && ...
notebooklm mind-map create && ...
notebooklm slides create && ...
```

### Import from Google Drive

```bash
notebooklm research add-drive "product roadmap" --max-results 10
notebooklm source add --drive "<file-id>"
```

## Decision Matrix: CLI vs MCP

| Task | Use |
|------|-----|
| All single operations | CLI |
| Batch ops across many notebooks | MCP: `batch` tool |
| Pipeline (create→add→generate) | MCP: `pipeline` tool |
| Cross-notebook queries | MCP: `cross_notebook_query` |
| Structured output needed in-context | MCP |

**Default: CLI for everything.** MCP is backup only.

## Installation

Already configured. On fresh clones, `setup.sh` installs via:

```bash
uv tool install "notebooklm-py[browser]"
```

Upgrade: `uv tool upgrade notebooklm-py`

## Troubleshooting

```bash
notebooklm doctor --fix      # auto-detect + fix common issues
notebooklm auth check --test # test auth
notebooklm --version         # check version
```

## Documentation

- CLI Reference: https://github.com/teng-lin/notebooklm-py/blob/main/docs/cli-reference.md
- MCP Guide: https://github.com/teng-lin/notebooklm-py/blob/main/docs/mcp-guide.md
- Python API: https://github.com/teng-lin/notebooklm-py/blob/main/docs/python-api.md
