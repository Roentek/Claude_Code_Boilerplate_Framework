# LightRAG Plus

**LightRAG Plus** extends the original LightRAG graph-based RAG system with:

- **Gemini multimodal embeddings** (text, images, video, audio) alongside OpenAI text embeddings
- **Multi-backend vector storage** — mirror embeddings to Supabase and/or Pinecone for redundancy and advanced search
- **Hybrid query modes** — search local graph only (fast) or all backends (comprehensive)
- **Multimodal processing** — simple mode (text extraction) or advanced mode (raw multimodal embeddings)
- **Auto-provisioning** — `provision.py` creates Supabase schema and Pinecone index on first run
- **Auto-update checks** — `check_update.py` notifies when `lightrag-hku` has a new release

**Base System:** [github.com/HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (13K+ stars, EMNLP 2025)

> **Key Principle:** LightRAG core is UNTOUCHED. Plus features bolt on after embeddings are generated. Disable all backends and it behaves identically to vanilla LightRAG.

---

## What It Does

### Core Features (From LightRAG)

- **Graph-based RAG** — extracts entities and relationships from documents, stores them in a knowledge graph
- **Multiple query modes** — naive, local, global, hybrid, and mix (with reranker)
- **Storage backends** — Neo4J, MongoDB, PostgreSQL, OpenSearch, or default (nano-vectordb)
- **Web UI + REST API** — optional LightRAG Server for visualization and programmatic access

### Plus Features

- **Dual Embedding Providers** — Choose OpenAI (text-only, cost-effective) or Gemini (multimodal)
- **Optional Vector Mirrors** — Enable Supabase and/or Pinecone to mirror embeddings for backup, redundancy, and cross-backend search
- **Multimodal RAG** — Process images, videos, and audio:
  - Simple mode: Extract text via OCR/transcription → LightRAG graph
  - Advanced mode: Extract text + embed raw media → searchable multimodal content
- **Fail-Safe Architecture** — Remote backend failures log a warning but never block local LightRAG operations

---

## Quick Start

### 1. Installation

Handled by `setup.sh` step 14. Manual:

```bash
cd tools/lightrag
uv sync
cp .env.example .env
```

### 2. Environment Variables

Edit `.env` — choose embedding provider based on content type:

| Content | Provider | Why |
| ------- | -------- | --- |
| Text only (PDFs, markdown, docs) | `openai` | Cheaper, faster — use by default |
| Images / video / audio | `gemini` | Only provider that embeds non-text |

```bash
# LLM — local Ollama (free, private)
LLM_BINDING=ollama
LLM_MODEL=llama3.2
LLM_BINDING_HOST=http://localhost:11434

# Embedding — TEXT ONLY (default)
EMBEDDING_BINDING=openai
EMBEDDING_BINDING_API_KEY=sk-...
EMBEDDING_MODEL=text-embedding-3-small

# Embedding — MULTIMODAL (switch when needed)
# EMBEDDING_BINDING=gemini
# EMBEDDING_BINDING_API_KEY=your-gemini-key
# EMBEDDING_MODEL=gemini-embedding-2-preview
```

**Optional — remote vector mirrors:**

```bash
# Supabase (auto-provisioned by provision.py)
ENABLE_SUPABASE=true
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_MANAGEMENT_TOKEN=your-management-token   # required for auto-provisioning

# Pinecone (auto-provisioned by provision.py)
ENABLE_PINECONE=true
PINECONE_API_KEY=...
PINECONE_INDEX=lightrag-vectors
PINECONE_ENVIRONMENT=us-east-1-aws
```

**Optional — multimodal mode:**

```bash
# simple = text extraction only (default)
# advanced = text extraction + raw multimodal embeddings (requires gemini + at least one remote backend)
MULTIMODAL_MODE=simple
```

### 3. Backend Provisioning

If `ENABLE_SUPABASE=true` or `ENABLE_PINECONE=true`, run once before first use:

```bash
uv run python provision.py
```

**What this does (idempotent — safe to re-run):**

- Creates Supabase `lightrag_vectors` table with correct vector dimension
- Creates Pinecone index if missing

`start_server.bat` runs `provision.py` automatically on every server start.

Validate connections after provisioning:

```bash
uv run python setup_backends.py
```

### 4. File Ingestion

**Method 1: Python library** (scripts and automation)

```python
import asyncio
import sys
sys.path.insert(0, 'src')
from lightrag_plus import LightRAGPlus

async def main():
    plus = await LightRAGPlus.create(working_dir="./rag_storage")

    # Text documents
    await plus.insert("Plain text document content...")

    # Multimodal files (requires EMBEDDING_PROVIDER=gemini + MULTIMODAL_MODE=advanced)
    from pathlib import Path
    await plus.insert(Path("diagram.png"), content_type="image")
    await plus.insert(Path("tutorial.mp4"), content_type="video")
    await plus.insert(Path("podcast.mp3"), content_type="audio")

asyncio.run(main())
```

**Method 2: REST API** (server must be running)

```bash
# Upload a document
curl -X POST http://localhost:9621/api/documents/text \
  -H "Content-Type: application/json" \
  -d '{"text": "Document content here", "description": "my doc"}'

# Upload a file
curl -X POST http://localhost:9621/api/documents/upload \
  -F "file=@document.pdf"
```

**Supported File Types:**

| Category | Extensions | Provider Required |
| -------- | ---------- | ----------------- |
| **Text** | `.txt`, `.md`, `.pdf`, `.docx`, `.html`, `.json`, `.py`, `.js`, etc. | OpenAI or Gemini |
| **Images** | `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp`, `.tiff`, `.webp` | Gemini only |
| **Video** | `.mp4`, `.avi`, `.mov`, `.wmv`, `.webm`, `.mkv` | Gemini only |
| **Audio** | `.mp3`, `.wav`, `.m4a`, `.ogg`, `.flac`, `.aac` | Gemini only |

### 5. Querying

```python
import asyncio
import sys
sys.path.insert(0, 'src')
from lightrag_plus import LightRAGPlus

async def main():
    plus = await LightRAGPlus.create(working_dir="./rag_storage")

    # graph mode — LightRAG knowledge graph only (fast, default)
    result = await plus.query("What is the main topic?")
    print(result["graph"])   # LightRAG answer string

    # hybrid mode — graph + all enabled remote backends
    result = await plus.query("Show me diagrams of X", mode="hybrid")
    print(result["graph"])   # LightRAG answer
    print(result["remote"])  # vector matches from Supabase/Pinecone

asyncio.run(main())
```

**`plus.query()` parameters:**

| Parameter | Default | Description |
| --------- | ------- | ----------- |
| `text` | — | Query string |
| `mode` | `"graph"` | `"graph"` (local only, fast) or `"hybrid"` (graph + remote backends) |
| `top_k` | `10` | Max remote results per backend |
| `lightrag_mode` | `"hybrid"` | Passed to LightRAG: `naive`, `local`, `global`, `hybrid`, `mix` |

**`plus.query()` return value:**

```python
{
    "graph": "LightRAG answer string",
    "remote": [   # empty list if mode="graph" or no remote backends enabled
        {"id": "...", "score": 0.95, "text": "...", "content_type": "text"},
        ...
    ]
}
```

### 6. Server (Web UI + REST API)

**Windows:**

```bat
start_server.bat
```

**Any platform:**

```bash
uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage
```

**VSCode:** Press `F5` → select "LightRAG Server"

Access: `http://localhost:9621` — Web UI, graph visualization, and `/docs` for API reference.

The GUI is optional — the REST API endpoints work regardless of whether a browser is open. Run the server headlessly in any terminal and query via curl or Python `requests`.

---

## Headless and Library Usage

You do not need the GUI or even the server to use LightRAG Plus.

**Library mode** (no server, direct Python):

```python
import asyncio, sys
sys.path.insert(0, 'src')   # run from tools/lightrag/
from lightrag_plus import LightRAGPlus

async def main():
    plus = await LightRAGPlus.create()
    await plus.insert("Document text goes here")
    result = await plus.query("Your question?")
    print(result["graph"])

asyncio.run(main())
```

**Headless server** (REST API without opening a browser):

```bash
# Start server in background (Windows)
start /B uv run python -m lightrag.api.lightrag_server --port 9621 --working-dir ./rag_storage

# Query via curl
curl -s -X POST http://localhost:9621/api/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What is X?", "mode": "hybrid"}'

# Insert text via curl
curl -s -X POST http://localhost:9621/api/documents/text \
  -H "Content-Type: application/json" \
  -d '{"text": "Document content", "description": "my doc"}'
```

---

## Maintenance

### Checking for Updates

`check_update.py` tracks `lightrag-hku` releases against the pinned version in `pyproject.toml`.

```bash
cd tools/lightrag

# Check only (no changes)
uv run python check_update.py

# Apply update (bumps pin, syncs, verifies imports, smoke-tests Plus layer)
uv run python check_update.py --upgrade
```

**Automatic:** `lightrag-sync.sh` runs `check_update.py` at every Claude Code session end (via stop hook) and notifies if an update is available.

**Major versions** are blocked by the `<X.0.0` pin — the script prints manual upgrade steps when a major version is detected.

---

## Configuration Reference

### Embedding Providers

| Provider | Capabilities | Best For | Dimensions |
| -------- | ------------ | -------- | ---------- |
| **OpenAI** | Text only | Pure text RAG, cost-effective | 1536 (small), 3072 (large) |
| **Gemini** | Text + multimodal | Images, videos, audio | 3072 (preview), 768 (stable) |

**Default Models:**

- OpenAI: `text-embedding-3-small` (1536 dims)
- Gemini: `gemini-embedding-2-preview` (3072 dims)

> Must use the same embedding model for indexing and querying.

### Backend Storage

| Backend | Mode | Use Case |
| ------- | ---- | -------- |
| **Local (nano-vectordb)** | Always active | Default, always works |
| **Supabase** | Optional mirror | Postgres-native stack, backup |
| **Pinecone** | Optional mirror | High-performance vector search |

Combinations:

- Neither → Pure LightRAG (local only)
- Supabase only → Postgres backup
- Pinecone only → Vector search mirror
- Both → Dual redundancy

### Query Modes

| `mode` | Searches | Speed | Use When |
| ------ | -------- | ----- | -------- |
| `"graph"` (default) | LightRAG knowledge graph only | Fast | Text queries, normal use |
| `"hybrid"` | LightRAG graph + all enabled remote backends | Slower | Multimodal queries, comprehensive search |

The `lightrag_mode` parameter controls LightRAG's internal query strategy independently:

| `lightrag_mode` | Behavior |
| --------------- | -------- |
| `"naive"` | Simple similarity search |
| `"local"` | Entity-focused search |
| `"global"` | Relationship-focused search |
| `"hybrid"` | local + global (default) |
| `"mix"` | hybrid + naive + reranker |

---

## Storage Architecture

**LightRAG Core (Always Active):**

| Backend | Use When |
| ------- | -------- |
| **Default (nano-vectordb)** | Simple prototyping, small datasets |
| **Neo4J** | Advanced graph queries, production scale |
| **MongoDB** | Unified storage, existing MongoDB infrastructure |
| **PostgreSQL** | SQL-based queries, pgvector support |
| **OpenSearch** | Elasticsearch-style search, large deployments |

**Plus Vector Mirrors (Optional):**

| Backend | Setup | Sync Behavior |
| ------- | ----- | ------------- |
| **Supabase (pgvector)** | Auto via `provision.py` | Synchronous per insert, fail-safe |
| **Pinecone** | Auto via `provision.py` | Synchronous per insert, fail-safe |

Embeddings insert to local graph first (always succeeds), then mirror to enabled remote backends. Remote failures log a warning but don't block. Manual re-sync: `await plus.sync_to_remotes()` (currently a no-op — inserts sync immediately).

---

## Usage Examples

### Example 1: Pure LightRAG (Text Only, Local)

```python
import asyncio, sys
sys.path.insert(0, 'src')
from lightrag_plus import LightRAGPlus

async def main():
    plus = await LightRAGPlus.create(working_dir="./rag_storage")
    await plus.insert("LightRAG is a graph-based RAG system.")
    result = await plus.query("What is LightRAG?")
    print(result["graph"])

asyncio.run(main())
```

Behavior: identical to vanilla LightRAG. Fastest, lowest cost.

---

### Example 2: Text RAG with Dual Backend Mirrors

Set in `.env`:

```bash
ENABLE_SUPABASE=true
ENABLE_PINECONE=true
```

```python
import asyncio, sys
sys.path.insert(0, 'src')
from lightrag_plus import LightRAGPlus

async def main():
    plus = await LightRAGPlus.create(working_dir="./rag_storage")

    # Insert syncs to local + Supabase + Pinecone
    await plus.insert("Document text...")

    # Graph mode — fast (local only)
    result = await plus.query("What does the document say?")
    print(result["graph"])

asyncio.run(main())
```

---

### Example 3: Multimodal RAG (Advanced Mode)

Set in `.env`:

```bash
EMBEDDING_BINDING=gemini
GEMINI_API_KEY=...
MULTIMODAL_MODE=advanced
ENABLE_SUPABASE=true
```

```python
import asyncio, sys
from pathlib import Path
sys.path.insert(0, 'src')
from lightrag_plus import LightRAGPlus

async def main():
    plus = await LightRAGPlus.create(working_dir="./rag_storage")

    # Image: OCR text → LightRAG graph; raw embedding → Supabase
    await plus.insert(Path("diagram.png"), content_type="image")

    # Video: transcription → LightRAG graph; keyframe embedding → Supabase
    await plus.insert(Path("tutorial.mp4"), content_type="video")

    # Hybrid: searches graph + Supabase
    result = await plus.query("Show me diagrams about X", mode="hybrid")
    print(result["graph"])   # text answer from graph
    print(result["remote"])  # vector matches including image embeddings

asyncio.run(main())
```

---

## Advanced Features (Upstream LightRAG)

- **Token tracking** — monitor API usage
- **KG data export** — extract graph data for analysis
- **LLM cache** — reuse responses to reduce costs
- **Langfuse observability** — trace and debug RAG pipelines
- **RAGAS evaluation** — measure retrieval quality
- **Document deletion** — remove docs with automatic KG regeneration
- **Multimodal RAG** — process images, tables, PDFs via RAG-Anything

Full docs: [docs/AdvancedFeatures.md](https://github.com/HKUDS/LightRAG/blob/main/docs/AdvancedFeatures.md)

---

## File Structure

```txt
tools/lightrag/
├── src/                          # LightRAG Plus implementation
│   ├── config.py                 # Environment config + feature flags
│   ├── lightrag_plus.py          # Main wrapper class (LightRAGPlus)
│   ├── embedders/
│   │   ├── base.py               # Abstract embedder interface
│   │   ├── openai_embedder.py    # OpenAI text embeddings
│   │   └── gemini_embedder.py    # Gemini multimodal embeddings
│   ├── adapters/
│   │   ├── base.py               # Abstract adapter interface
│   │   ├── supabase_adapter.py   # Supabase vector mirroring
│   │   └── pinecone_adapter.py   # Pinecone vector mirroring
│   └── ingestors/                # Multimodal preprocessing
│       ├── base.py
│       ├── image_ingestor.py     # Image → text + raw embedding
│       ├── video_ingestor.py     # Video → transcript + keyframes
│       └── audio_ingestor.py     # Audio → transcript + raw embedding
├── schema/
│   └── supabase_schema.sql       # Supabase table definitions (applied by provision.py)
├── provision.py                  # Auto-provision Supabase schema + Pinecone index (idempotent)
├── check_update.py               # Check/apply lightrag-hku PyPI updates
├── setup_backends.py             # Validate backend connections after provisioning
├── start_server.bat              # Windows launcher (runs provision.py + server)
├── .env                          # Configuration (gitignored)
├── .env.example                  # Configuration template
├── pyproject.toml                # Dependencies (lightrag-hku pinned to current major)
├── uv.lock                       # Dependency lockfile
├── .gitignore
├── .venv/                        # Virtual environment (gitignored, recreated by uv sync)
└── rag_storage/                  # LightRAG working directory (gitignored, auto-created)
```

---

## API Reference

Core API docs (QueryParam options, LLM/embedding provider configs, reranker, entity management):

[docs/ProgramingWithCore.md](https://github.com/HKUDS/LightRAG/blob/main/docs/ProgramingWithCore.md)

---

## Integration Recommendation

From the official LightRAG docs:

> If you would like to integrate LightRAG into your project, we recommend utilizing the **REST API provided by the LightRAG Server**. LightRAG Core is typically intended for embedded applications or for researchers.

For production use, run the server and call it via REST API. For scripts and automation, the library mode (`LightRAGPlus.create()`) is simpler and avoids the network layer entirely.
