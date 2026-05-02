---
name: notebooklm
description: Google NotebookLM integration - create notebooks, add sources, generate AI content (podcasts, videos, briefings), query notebooks, and manage research workflows
---

# NotebookLM CLI + MCP

Programmatic access to Google NotebookLM via CLI (`nlm`) and MCP server (`notebooklm-mcp`).

## When to Use

- **Research & discovery**: Create notebooks, start web/Drive research, import sources
- **AI analysis**: Query notebooks, get summaries, configure chat personas
- **Content generation**: Create podcasts, videos, briefings, flashcards, infographics, slides
- **Management**: Share notebooks, sync Drive sources, batch operations

## CLI First (Always Primary)

Use `nlm` CLI commands via Bash tool for all operations. The MCP server (`notebooklm-mcp`) is a backup for multi-step interactive flows only.

```bash
# List notebooks
nlm notebook list

# Create notebook
nlm notebook create "AI Strategy Research"

# Add sources
nlm source add <notebook-id> --url "https://example.com/article"
nlm source add <notebook-id> --text "Meeting notes content here"
nlm source add <notebook-id> --drive "<google-drive-file-id>"

# Query notebook
nlm notebook query <notebook-id> "What are the key findings?"

# Generate audio podcast
nlm audio create <notebook-id> --confirm

# Check generation status
nlm audio status <notebook-id> <artifact-id>

# Download audio file
nlm download audio <notebook-id> <artifact-id>

# Share notebook
nlm share public <notebook-id>

# Web research (discover sources)
nlm research start <notebook-id> "enterprise AI ROI metrics"
```

## MCP Tools (Backup Only)

Only use MCP tools when the CLI cannot handle the task (rare). The MCP server provides 35 tools but uses significant context window space.

Common MCP tools:
- `notebook_list`, `notebook_create`, `notebook_delete`
- `source_add`, `source_list`, `source_delete`, `source_sync_drive`
- `notebook_query` (persists to web UI chat history)
- `studio_create` (audio, video, briefing, flashcards, infographics, slides)
- `download_artifact` (get URLs for generated content)
- `notebook_share_public`, `notebook_share_invite`
- `research_start` (web/Drive discovery)

## Authentication

**Required before first use:**

```bash
nlm login
```

This launches a browser, you log in to Google, and cookies are extracted automatically. Authentication persists for ~2-4 weeks and auto-refreshes.

**Manual mode** (if auto-login fails):
```bash
nlm login --manual --file cookies.txt
```

**Check auth status:**
```bash
nlm login --check
```

**Multiple Google accounts** (profiles):
```bash
nlm login --profile work
nlm login --profile personal
nlm login switch <profile>
nlm login profile list
```

## Common Workflows

### Research Notebook from Web Sources

```bash
# 1. Create notebook
nlm notebook create "Cloud Marketplace Trends"

# 2. Start research (discovers sources)
nlm research start <notebook-id> "cloud marketplace growth 2025" --depth deep

# 3. Query the research
nlm notebook query <notebook-id> "What are the top 3 trends?"

# 4. Generate podcast overview
nlm audio create <notebook-id> --format "deep dive" --confirm

# 5. Check status until complete
nlm audio status <notebook-id> <artifact-id>

# 6. Download audio file
nlm download audio <notebook-id> <artifact-id>
```

### Import Google Drive Documents

```bash
# 1. Search Drive for documents
nlm research start <notebook-id> --drive-query "product roadmap" --max-results 10

# 2. Add specific Drive file
nlm source add <notebook-id> --drive "<file-id>"

# 3. Sync Drive sources (check for updates)
nlm source sync <notebook-id>
```

### Generate Multiple Content Types

```bash
# Audio podcast (deep dive style)
nlm audio create <notebook-id> --format "deep dive" --confirm

# Video explainer (classic visual style)
nlm video create <notebook-id> --style classic --confirm

# Briefing doc
nlm studio create <notebook-id> --type briefing --confirm

# Flashcards (medium difficulty)
nlm studio create <notebook-id> --type flashcards --difficulty medium --confirm

# Infographic (landscape, professional style)
nlm studio create <notebook-id> --type infographic --orientation landscape --style professional --confirm

# Slide deck presentation
nlm studio create <notebook-id> --type slides --confirm
```

## Rate Limits

- **Free tier**: ~50 queries/day
- **Generation**: Audio/video creation may take several minutes — poll status before downloading

## Troubleshooting

### Authentication Expired

Cookies expire every 2-4 weeks. Re-authenticate:

```bash
nlm login
```

### Upgrade CLI

```bash
uv tool upgrade notebooklm-mcp-cli
```

After upgrading, restart Claude Code to reconnect to the updated MCP server.

### Check Installation

```bash
# Verify CLI is installed
nlm --version

# Verify MCP server is available
uvx --from notebooklm-mcp-cli notebooklm-mcp --version
```

## Context Window Warning

The MCP server provides **35 tools**. Disable it when not using NotebookLM to preserve context:

```bash
# In Claude Code chat
@notebooklm-mcp  # Toggle on/off
```

## Decision Matrix: CLI vs MCP

| Task | Use |
|------|-----|
| List notebooks | CLI: `nlm notebook list` |
| Create notebook | CLI: `nlm notebook create` |
| Add single source | CLI: `nlm source add` |
| Query notebook | CLI: `nlm notebook query` |
| Generate content | CLI: `nlm audio/video/studio create` |
| Download artifacts | CLI: `nlm download` |
| Share notebook | CLI: `nlm share public/invite` |
| Multi-step interactive flow | MCP (rare) |
| Batch operations on many notebooks | MCP: `batch` tool |
| Cross-notebook queries | MCP: `cross_notebook_query` |

**Default to CLI for everything.** MCP is backup only.

## Installation

Already configured in this project. On fresh clones, `setup.sh` installs via:

```bash
uv tool install notebooklm-mcp-cli
```

This provides both `nlm` (CLI) and `notebooklm-mcp` (MCP server).

## Documentation

- **CLI Guide**: https://github.com/jacob-bd/notebooklm-mcp-cli/blob/main/docs/CLI_GUIDE.md
- **MCP Guide**: https://github.com/jacob-bd/notebooklm-mcp-cli/blob/main/docs/MCP_GUIDE.md
- **Authentication**: https://github.com/jacob-bd/notebooklm-mcp-cli/blob/main/docs/AUTHENTICATION.md

## Source

https://github.com/jacob-bd/notebooklm-mcp-cli
