# Tools

Deterministic execution scripts and AI research tools. These are the execution layer of the WAT framework — Claude orchestrates, tools execute. Each tool is independent and runnable standalone.

---

## Directory Overview

| Tool | Type | Purpose |
| ------ | ------ | --------- |
| [`ffmpeg.js`](#ffmpegjs) | Node.js CLI | Video/audio processing — trim, transcode, thumbnail, extract audio, concat |
| [`playwright.js`](#playwrightjs) | Node.js CLI | Browser automation — screenshots, scraping, PDFs, link extraction |
| [`autoresearch/`](#autoresearch) | Python (uv) | Autonomous ML experiments — agent edits training code overnight |
| [`lightrag-plus/`](#lightrag-plus) | Python (uv) | Graph-based RAG — knowledge extraction, entity Q&A, multimodal docs |
| [`openspace/`](#openspace) | Python (uv, git submodule) | Self-evolving agent skills — skills that fix, improve, and share themselves |

**Prerequisites:** `node`, `uv`, `ffmpeg` (system). Run `bash .claude/hooks/setup.sh` to install everything automatically.

---

## ffmpeg.js

Node.js CLI wrapper around system `ffmpeg`. No npm dependencies — calls `child_process.spawnSync` directly. All output is JSON so Claude can parse results without regex.

**Install system ffmpeg:**

```bash
# Windows
winget install Gyan.FFmpeg

# macOS
brew install ffmpeg

# Linux
sudo apt install ffmpeg
```

**Commands:**

```bash
# Inspect a video file
node tools/ffmpeg.js probe video.mp4

# Trim a clip (30s to 1min mark)
node tools/ffmpeg.js trim input.mp4 --start 00:00:30 --end 00:01:00

# Transcode to mp4 at 1280x720
node tools/ffmpeg.js transcode input.avi --format mp4 --resolution 1280x720

# Extract a thumbnail at 10 seconds
node tools/ffmpeg.js thumbnail input.mp4 --at 00:00:10 --width 1280

# Extract audio as mp3
node tools/ffmpeg.js extract-audio input.mp4 --format mp3

# Concatenate multiple clips
node tools/ffmpeg.js concat a.mp4 b.mp4 c.mp4 --output merged.mp4
```

**Output example (`probe`):**

```json
{
  "format": "mov,mp4,m4a,3gp,3g2,mj2",
  "duration": "62.5",
  "size": "12345678",
  "bitrate": "1580000",
  "streams": [...]
}
```

**Use with Claude:** Claude invokes this via `Bash(node tools/ffmpeg.js ...)`. Use the `/ffmpeg` skill to guide Claude through video tasks.

---

## playwright.js

Node.js browser automation CLI using Playwright + Chromium. Headless by default. All output is JSON.

**Install:**

```bash
npm install       # installs playwright package
npx playwright install chromium
```

**Commands:**

```bash
# Screenshot a page
node tools/playwright.js screenshot https://example.com output.png

# Full-page screenshot
node tools/playwright.js screenshot https://example.com --fullpage

# Scrape all text content
node tools/playwright.js scrape https://example.com

# Scrape specific elements
node tools/playwright.js scrape https://example.com --selector "h2, p"

# Generate a PDF
node tools/playwright.js pdf https://example.com output.pdf --format A4

# Extract all links
node tools/playwright.js links https://example.com

# Wait for a selector before capturing
node tools/playwright.js screenshot https://example.com --wait-for ".dashboard"

# Open a visible browser (for debugging)
node tools/playwright.js screenshot https://example.com --headed
```

**Note:** For interactive sessions (login flows, multi-step forms), use `playwright-mcp` instead — it keeps a browser session alive across tool calls. This CLI is for one-shot operations.

**Use with Claude:** Use the `/playwright` skill. For large-scale scraping (1000+ pages), route to `/apify-ultimate-scraper` instead.

---

## autoresearch/

Autonomous ML research agent. Based on [karpathy/autoresearch](https://github.com/karpathy/autoresearch) (33K+ stars). The agent modifies `train.py`, runs 5-minute experiments, checks if results improved, and iterates overnight — ~12 experiments/hour, ~100 while you sleep.

**Requirements:** Single NVIDIA GPU (H100 tested). Python 3.10+. `uv` (auto-installed by setup.sh).

> Community forks: [miolini/autoresearch-macos](https://github.com/miolini/autoresearch-macos) for macOS/AMD/CPU.

### Autoresearch Setup

```bash
cd tools/autoresearch

# 1. Install dependencies (PyTorch ~3GB — takes 5-10 min first time)
uv sync

# 2. Verify everything installed
uv run python verify_setup.py

# 3. Download data + train tokenizer (one-time, ~2 min)
uv run prepare.py

# 4. Test a single training run (~5 min — confirms GPU is working)
uv run train.py
```

### File Structure

| File | Purpose | Who Touches It |
| ------ | --------- | ---------------- |
| `prepare.py` | Data prep, tokenizer, evaluation constants | Read-only |
| `train.py` | GPT model + training loop | **Agent modifies this** |
| `program.md` | Agent instructions and research goals | **You edit this** |
| `results.tsv` | Experiment log (auto-generated) | Agent writes |

### How It Works

Each experiment:

1. Agent creates branch `autoresearch/<tag>`
2. Modifies `train.py` with a new idea
3. Commits the change
4. Runs `uv run train.py` (5-minute wall clock budget)
5. Extracts `val_bpb` (validation bits per byte — lower = better)
6. If improved → keeps commit; if not → reverts
7. Logs to `results.tsv`
8. Repeats until stopped

**Metric:** `val_bpb` (validation bits per byte). Lower is better.

### Running Autonomous Research

```bash
# Via Claude Code — open project root, then prompt:
# "Have a look at program.md and kick off a new experiment."

# Or use the /autoresearch skill directly
```

Edit `program.md` to define what you want the agent to explore (learning rate schedules, architecture changes, regularization, etc.).

---

## lightrag-plus/

Graph-based RAG with multimodal support. Extends [HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (13K+ stars, EMNLP 2025) with Gemini multimodal embeddings, Supabase/Pinecone vector mirrors, and auto-provisioning.

**Key idea:** LightRAG extracts entities and relationships from documents → stores them in a knowledge graph → answers questions using graph traversal + vector search together. Better than pure vector search for connected knowledge.

### LightRAG-Plus Setup

```bash
cd tools/lightrag-plus

# 1. Install dependencies
UV_NATIVE_TLS=true uv sync --all-extras

# 2. Create config
cp .env.example .env
# Edit .env — minimum required: OPENAI_API_KEY (for embeddings)

# 3. Auto-provision backends (idempotent — safe to re-run)
uv run python provision.py

# 4. Check for lightrag-hku updates
uv run python check_update.py
```

### Configuration

Choose embedding provider based on your content:

```bash
# Text-only (PDFs, docs, markdown) — default
EMBEDDING_BINDING=openai
EMBEDDING_BINDING_API_KEY=sk-...
EMBEDDING_MODEL=text-embedding-3-small

# Multimodal (images, video, audio)
EMBEDDING_BINDING=gemini
EMBEDDING_BINDING_API_KEY=your-gemini-key
EMBEDDING_MODEL=gemini-embedding-2-preview

# LLM for entity extraction — local Ollama (free)
LLM_BINDING=ollama
LLM_MODEL=llama3.2
LLM_BINDING_HOST=http://localhost:11434

# Or use OpenAI
LLM_BINDING=openai
LLM_BINDING_API_KEY=sk-...
LLM_MODEL=gpt-4o-mini
```

**Timeout settings (important for large docs):**

```bash
LLM_TIMEOUT=1800       # 30 min — required for slow local models on large chunks
EMBEDDING_TIMEOUT=60   # 1 min
EMBEDDING_BINDING_HOST=https://api.openai.com/v1  # prevents Ollama host bleeding into OpenAI calls
```

### Start the Server

```bash
cd tools/lightrag-plus
uv run python src/server.py --port 9621 --working-dir ./rag_storage

# Or on Windows — double-click start_server.bat
# Or F5 in VSCode → "LightRAG Server"
```

Access at [http://localhost:9621](http://localhost:9621) — Web UI + Swagger docs.

### Inserting Documents

```bash
# Via REST API
curl -X POST http://localhost:9621/documents/text \
  -H "Content-Type: application/json" \
  -d '{"text": "Your document content here", "description": "My doc"}'

# Upload a file via Web UI at http://localhost:9621
```

### Querying

```bash
# Five query modes available:
curl -X POST http://localhost:9621/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are the main entities?", "mode": "hybrid"}'
```

| Mode | Description |
| ------ | ------------- |
| `naive` | Simple vector similarity — fastest, least accurate |
| `local` | Searches entity neighborhood in graph |
| `global` | Searches across entire knowledge graph |
| `hybrid` | Combines local + global — recommended default |
| `mix` | Hybrid + reranker — most accurate, slowest |

### Running Tests

```bash
cd tools/lightrag-plus

# One-time sync (do NOT use uv run pytest — hits Windows file lock bug on repeat runs)
UV_NATIVE_TLS=true uv sync --all-extras

# Run tests via venv python directly
.venv\Scripts\python.exe -m pytest tests/test_integration.py -v   # Windows
.venv/bin/python -m pytest tests/test_integration.py -v           # Unix
```

### Optional Remote Backends

```bash
# Mirror embeddings to Supabase
ENABLE_SUPABASE=true
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_MANAGEMENT_TOKEN=your-management-token  # for auto-provisioning

# Mirror to Pinecone
ENABLE_PINECONE=true
PINECONE_API_KEY=...
PINECONE_INDEX=lightrag-vectors
```

Backends are optional — disable all and it runs identically to vanilla LightRAG with local nano-vectordb.

---

## openspace/

**Self-evolving agent skills platform.** [HKUDS/OpenSpace](https://github.com/HKUDS/OpenSpace) (git submodule — auto-syncs upstream every session).

OpenSpace plugs into any agent (Claude Code, Codex, Cursor, etc.) and gives it three superpowers:

- **Self-Evolution** — Skills that auto-fix when broken, auto-improve from successes, auto-learn from usage
- **Collective Intelligence** — One agent's evolved skill becomes available to all agents via the cloud registry
- **Token Efficiency** — Reuse successful patterns instead of reasoning from scratch; 46% fewer tokens on average

**Benchmark:** On 50 real-world professional tasks (GDPVal), OpenSpace agents earn 4.2× more than baseline using the same LLM, while using 46% fewer tokens.

### Openspace Setup

```bash
cd tools/openspace

# 1. Install (setup.sh does this automatically)
uv pip install -e ".[windows]"   # Windows
uv pip install -e ".[linux]"     # Linux
uv pip install -e ".[macos]"     # macOS

# 2. Create config
cp openspace/.env.example openspace/.env
# Edit openspace/.env — add your LLM API key
```

**Minimum `.env` for local use (no API key needed):**

```bash
ANTHROPIC_API_KEY=sk-ant-...   # if using Claude
# OR
OPENAI_API_KEY=sk-...          # if using OpenAI
# OR
OPENROUTER_API_KEY=...         # recommended — routes to any model
OPENSPACE_MODEL=openrouter/auto
```

**Optional cloud access:**

```bash
OPENSPACE_API_KEY=sk-xxx       # register at open-space.cloud
```

### Running OpenSpace

**CLI (primary — zero context tokens):**

```bash
# Interactive mode
openspace

# Execute a specific task
openspace --query "Create a monitoring dashboard for Docker containers"
openspace --model "anthropic/claude-sonnet-4-6" --query "Analyze my codebase and suggest improvements"
```

**MCP (backup — use for structured in-session results):**

Already wired into `.mcp.json`. Restart Claude Code to activate. Then use `mcp__openspace__*` tools.

### Dashboard

```bash
# Terminal 1 — start backend
openspace-dashboard --port 7788
# OR use the existing project config: http://127.0.0.1:3789/dashboard

# Terminal 2 — build and start frontend
cd tools/openspace/frontend
npm install    # one-time
npm run build  # build static assets
npm run dev    # OR run dev server at http://localhost:5173
```

The dashboard shows:

- **Skill Classes** — Browse, search, and sort all local skills
- **Version Lineage** — Graph showing skill evolution history (parent → derived → fixed)
- **Workflow Sessions** — Execution history, token usage, metrics
- **Cloud Skills** — Browse and discover community-evolved skills

### How Skills Work

A **skill** is a directory containing a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: my-skill
description: What this skill does — used for discovery/search
---

# My Skill

Instructions for the agent...
```

Skills are stored in a SQLite database (`tools/openspace/.openspace/openspace.db`) and versioned in a DAG (directed acyclic graph). Every evolution creates a new node connected to its parent.

**Three evolution modes:**

- `FIX` — Repairs a broken skill in-place. Same name, new version.
- `DERIVED` — Creates an enhanced version in a new directory. Coexists with parent.
- `CAPTURED` — Extracts a novel pattern from a successful execution. No parent — brand new skill.

### Creating a Skill

Create a directory with a `SKILL.md` inside `tools/openspace/openspace/skills/`:

```bash
mkdir tools/openspace/openspace/skills/my-skill
```

```markdown
# tools/openspace/openspace/skills/my-skill/SKILL.md
---
name: my-skill
description: Generates a weekly summary report from a CSV of tasks
---

## When to Use
Use when the user has a CSV file of tasks and wants a formatted weekly report.

## Steps
1. Read the CSV file
2. Group tasks by status (done/in-progress/blocked)
3. Calculate completion rate
4. Generate markdown report with table + summary

## Output Format
Return a markdown file saved as `weekly-report-{date}.md`.
```

Skills in `openspace/skills/` are lowest priority. To inject your own skills at higher priority, set the env var:

```bash
OPENSPACE_HOST_SKILL_DIRS=/path/to/your/skills
```

This is how the Claude Code integration works — it points OpenSpace at `~/.claude/skills/`.

### Importing Skills from the Cloud

```bash
# Browse at open-space.cloud (no account needed)

# Download a specific skill by ID
openspace-download-skill <skill_id>

# Search locally (MCP — returns structured results)
# Use mcp__openspace__search_skills in Claude Code
```

### Skill Relationship Tree (Evolution Graph)

The evolution graph is the core concept: every skill has a lineage showing where it came from and what it spawned.

```text
document-gen-fallback (IMPORTED)
    ↓ FIX (v2) — fixed PDF encoding issue
    ↓ DERIVED → document-gen-pdf (specialized for PDF output)
        ↓ FIX (v2) — updated reportlab API
        ↓ DERIVED → document-gen-pdf-verified (adds verification step)
    ↓ DERIVED → document-gen-docx (specialized for Word output)
```

**Browse the graph:**

1. Start the dashboard (see above)
2. Click **Version Lineage** tab
3. Each node = a skill version; edges = evolution relationships
4. Click a node to see the diff from its parent

**Query the graph via Python:**

```python
from openspace.skill_engine.store import SkillStore

store = SkillStore("tools/openspace/.openspace/openspace.db")

# Get all skills
skills = store.list_skills()

# Get evolution history for a skill
lineage = store.get_skill_lineage("my-skill__imp_abc123")

# Get all versions of a skill family
versions = store.get_skill_versions("document-gen-fallback")
```

**Explore the showcase graph (SQLite):**

```bash
# The My Daily Monitor showcase includes 60+ evolved skills
# Load in any SQLite browser:
tools/openspace/showcase/.openspace/openspace.db
```

### Uploading Skills to the Cloud

```bash
# Upload a skill directory to open-space.cloud (requires OPENSPACE_API_KEY)
openspace-upload-skill /path/to/skill/dir

# Set visibility
openspace-upload-skill /path/to/skill/dir --visibility public
openspace-upload-skill /path/to/skill/dir --visibility private
```

### Integrating with Other Repos

To use OpenSpace skills in another project, configure the MCP server in that project's `.mcp.json`:

```json
{
  "mcpServers": {
    "openspace": {
      "command": "openspace-mcp",
      "toolTimeout": 600,
      "env": {
        "OPENSPACE_HOST_SKILL_DIRS": "/path/to/other-project/.claude/skills",
        "OPENSPACE_WORKSPACE": "/path/to/openspace",
        "OPENSPACE_API_KEY": "sk-xxx"
      }
    }
  }
}
```

Then copy the two bootstrap skills into that project:

```bash
cp -r tools/openspace/openspace/host_skills/delegate-task/ /path/to/other-project/.claude/skills/
cp -r tools/openspace/openspace/host_skills/skill-discovery/ /path/to/other-project/.claude/skills/
```

These two skills teach the agent when and how to use OpenSpace — no additional prompting needed.

### Submodule Sync

`tools/openspace/` is a git submodule tracking [HKUDS/OpenSpace](https://github.com/HKUDS/OpenSpace). It auto-syncs every session via the Stop hook.

```bash
# Manual sync
git submodule update --remote tools/openspace

# Skip sync if you have local changes
# The sync hook checks for uncommitted changes before pulling
```

---

## Troubleshooting

| Issue | Fix |
| ------- | ----- |
| `ffmpeg: command not found` | `winget install Gyan.FFmpeg` or `brew install ffmpeg` |
| `uv: command not found` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Playwright Chromium SSL error | `NODE_TLS_REJECT_UNAUTHORIZED=0 npx playwright install chromium` |
| LightRAG `ReadTimeout` during insert | Set `LLM_TIMEOUT=1800` in `tools/lightrag-plus/.env` |
| LightRAG embedding 404 | Set `EMBEDDING_BINDING_HOST=https://api.openai.com/v1` in `.env` |
| `uv sync` fails (`UnknownIssuer`) | `UV_NATIVE_TLS=true uv sync` — uses Windows cert store |
| `uv run pytest` fails on second run (Windows) | Use `.venv\Scripts\python.exe -m pytest` instead |
| OpenSpace MCP not starting | `cd tools/openspace && uv pip install -e ".[windows]"` |
| OpenSpace dashboard API only (no UI) | Build frontend: `cd tools/openspace/frontend && npm run build` |
