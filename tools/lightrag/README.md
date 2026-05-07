# LightRAG Enhanced

**LightRAG Enhanced** extends the original LightRAG graph-based RAG system with:

- ✨ **Gemini multimodal embeddings** (text, images, video, audio) alongside OpenAI text embeddings
- ✨ **Multi-backend vector storage** — mirror embeddings to Supabase and/or Pinecone for redundancy and advanced search
- ✨ **Hybrid query modes** — search local graph only (fast) or all backends (comprehensive)
- ✨ **Multimodal processing** — simple mode (text extraction) or advanced mode (raw multimodal embeddings)

**Base System:** [github.com/HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (13K+ stars, EMNLP 2025)

> **Key Principle:** LightRAG core remains unchanged and always functional. Enhanced features are bolt-ons that can be enabled/disabled via configuration flags.

---

## What It Does

### Core Features (From LightRAG)

- **Graph-based RAG** — extracts entities and relationships from documents, stores them in a knowledge graph
- **Multiple query modes** — naive, local, global, hybrid, and mix (with reranker)
- **Storage backends** — Neo4J, MongoDB, PostgreSQL, OpenSearch, or default (nano-vectordb)
- **Web UI + REST API** — optional LightRAG Server for visualization and programmatic access

### Enhanced Features (New)

- **Dual Embedding Providers** — Choose OpenAI (text-only, cost-effective) or Gemini (multimodal)
- **Optional Vector Mirrors** — Enable Supabase and/or Pinecone to mirror embeddings for:
  - Backup and redundancy
  - Cross-backend search comparison
  - Migration flexibility
- **Multimodal RAG** — Process images, videos, and audio:
  - Simple mode: Extract text via OCR/transcription → LightRAG graph
  - Advanced mode: Extract text + embed raw media → searchable multimodal content
- **Fail-Safe Architecture** — Remote backend failures never block local LightRAG operations

---

## Quick Start

### 1. Installation

Handled by `setup.sh` step 14 — installs `lightrag-hku` via `uv` in this directory.

**Manual install:**

```bash
cd tools/lightrag
uv pip install lightrag-hku
```

### 2. Environment Variables

**Copy the template:**

```bash
cp .env.example .env
```

**Edit `.env` and configure:**

**Required (choose one embedding provider):**

```bash
# For text-only RAG (recommended for getting started)
EMBEDDING_PROVIDER=openai
OPENAI_API_KEY=sk-...
OPENAI_EMBEDDING_MODEL=text-embedding-3-small  # or text-embedding-3-large

# OR for multimodal RAG (text + images + video + audio)
EMBEDDING_PROVIDER=gemini
GEMINI_API_KEY=...
GEMINI_EMBEDDING_MODEL=gemini-embedding-2-preview  # or gemini-embedding-2
```

**Optional (enable remote vector storage):**

```bash
# Enable Supabase mirror (requires SQL schema setup)
ENABLE_SUPABASE=true
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key

# Enable Pinecone mirror (auto-created by setup script)
ENABLE_PINECONE=true
PINECONE_API_KEY=...
PINECONE_INDEX=lightrag-vectors
PINECONE_ENVIRONMENT=us-east-1-aws
```

**Optional (multimodal processing):**

```bash
# simple = text extraction only (OCR/transcription)
# advanced = text extraction + raw multimodal embeddings (requires Gemini)
MULTIMODAL_MODE=simple
```

> **Note:** Full `.env` template with all options is in `.env.example`

### 3. Backend Setup (Optional)

**Only needed if you enabled Supabase or Pinecone in `.env`**

```bash
cd tools/lightrag
uv run python setup_backends.py
```

**What this does:**

- ✅ Validates Supabase connection and schema
- ✅ Creates Pinecone index if it doesn't exist
- ✅ Verifies embedding dimensions match across all backends

**Supabase Setup:**

If `ENABLE_SUPABASE=true`, you must run the SQL schema once:

1. Open [Supabase SQL Editor](https://supabase.com/dashboard)
2. Run `schema/supabase_schema.sql`
3. **Important:** Update `VECTOR(3072)` to match your `EMBEDDING_DIM` if using a different dimension

**Pinecone Setup:**

Auto-created by `setup_backends.py` — no manual steps required!

---

### 4. File Ingestion

LightRAG Enhanced supports three file ingestion methods:

**Method 1: Programmatic API** (Recommended for scripts and automation)

```python
from pathlib import Path
from tools.lightrag.src.lightrag_enhanced import LightRAGEnhanced

rag = LightRAGEnhanced(
    working_dir="./rag_storage",
    embedding_provider="gemini",  # For multimodal support
    multimodal_mode="advanced"
)

# Text documents (any provider)
rag.insert("Plain text document content...")

# Multimodal files (requires Gemini provider)
rag.insert(Path("diagram.png"), content_type="image")
rag.insert(Path("tutorial.mp4"), content_type="video")
rag.insert(Path("podcast.mp3"), content_type="audio")
```

**Method 2: HTTP Upload API** (Recommended for web applications)

```bash
# Upload via LightRAG Server (http://localhost:9621)
curl -X POST http://localhost:9621/documents/upload \
  -F "file=@diagram.png"

# Multimodal files automatically routed to correct ingestor
```

**Method 3: Data Folder Monitoring** (Optional — Enable via `.env`)

```bash
# Enable in .env
ENABLE_FILE_WATCHER=true

# Drop files into organized folders
cp *.png ./rag_storage/data/images/
cp *.pdf ./rag_storage/data/text/
cp *.mp4 ./rag_storage/data/video/

# Files auto-ingested within 1.5 seconds
# Server broadcasts real-time status via SSE
```

**Supported File Types:**

| Category | Extensions | Provider Required |
| ---------- | ----------- | ------------------- |
| **Text** | `.txt`, `.md`, `.pdf`, `.docx`, `.pptx`, `.html`, `.json`, `.py`, `.js`, etc. | OpenAI or Gemini |
| **Images** | `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp`, `.tiff`, `.webp`, `.svg` | **Gemini only** |
| **Video** | `.mp4`, `.avi`, `.mov`, `.wmv`, `.webm`, `.mkv` | **Gemini only** |
| **Audio** | `.mp3`, `.wav`, `.m4a`, `.ogg`, `.flac`, `.aac` | **Gemini only** |

> **Note:** Multimodal files (images, video, audio) require `EMBEDDING_PROVIDER=gemini`. OpenAI embeddings are text-only.

---

### 5. Basic Usage

**Insert documents:**

```python
from lightrag import LightRAG, QueryParam
from lightrag.llm import openai_complete_if_cache, openai_embedding

rag = LightRAG(
    working_dir="./rag_storage",
    llm_model_func=openai_complete_if_cache,
    embedding_func=openai_embedding
)

# Insert document
with open("document.txt") as f:
    rag.insert(f.read())
```

**Query:**

```python
# Query modes: naive, local, global, hybrid, mix
result = rag.query("What is the main topic?", param=QueryParam(mode="hybrid"))
print(result)
```

### 6. LightRAG Server (Web UI + API)

Start the server with visualization:

```bash
cd tools/lightrag
python -m lightrag.server --port 9621 --working-dir ./rag_storage
```

Access: `http://localhost:9621`

Features:

- Knowledge graph visualization
- REST API endpoints for insert/query
- Subgraph filtering and node queries

---

## Configuration

### Embedding Providers

| Provider | Capabilities | Best For | Dimensions |
| ---------- | ------------- | ---------- | ----------- |
| **OpenAI** | Text only | Pure text RAG, cost-effective | 1536 (small) 3072 (large) |
| **Gemini** | Text + multimodal | Images, videos, audio | 3072 (preview) 768 (stable) |

**Default Models:**

- OpenAI: `text-embedding-3-small` (1536 dims) — cost-effective
- Gemini: `gemini-embedding-2-preview` (3072 dims) — highest quality

> **Important:** Must use the same embedding model for indexing and querying

### Backend Storage Options

| Backend | Mode | Use Case |
| --------- | ------ | ---------- |
| **Local (nano-vectordb)** | Always active | Default, always works |
| **Supabase** | Optional mirror | Postgres-native stack, backup |
| **Pinecone** | Optional mirror | High-performance vector search |

**You can enable:**

- ❌ Neither → Pure LightRAG (local only)
- ✅ Supabase only → Postgres backup
- ✅ Pinecone only → Vector search mirror
- ✅ Both → Dual redundancy

### Query Modes

| Mode | Searches | Speed | Use When |
| ------ | ---------- | ------- | ---------- |
| `graph` (default) | Local graph only | Fast | Text queries, normal use |
| `hybrid` | All enabled backends | Slower | Multimodal queries, comprehensive search |

**Example:**

```python
# Fast - local graph only
result = rag.query("What is X?")  # mode="graph" default

# Comprehensive - searches local + Supabase + Pinecone
result = rag.query("Show me images of X", mode="hybrid")
```

### LLM Requirements

- **Minimum:** 32B parameters, 32KB context
- **Recommended:** 64KB context, non-reasoning models for indexing
- **Query stage:** Use stronger models than indexing for best results

### Reranker (Optional)

- **Boosts performance** when enabled with "mix" query mode
- **Recommended:** `BAAI/bge-reranker-v2-m3`, Jina reranker services

---

## Storage Architecture

**LightRAG Core (Always Active):**

| Backend | Use When |
| ------- | -------- |
| **Default (nano-vectordb)** | Simple prototyping, small datasets |
| **Neo4J** | Advanced graph queries, visualization, production scale |
| **MongoDB** | Unified storage, existing MongoDB infrastructure |
| **PostgreSQL** | SQL-based queries, pgvector support |
| **OpenSearch** | Elasticsearch-style search, large-scale deployments |

**Enhanced Vector Mirrors (Optional):**

| Backend | Setup | Sync Behavior | Use When |
| --------- | ------- | --------------- | ---------- |
| **Supabase (pgvector)** | Manual SQL schema | Synchronous, fail-safe | Postgres-native stack, backup/redundancy |
| **Pinecone** | Auto-created | Synchronous, fail-safe | High-performance vector search, scalability |

**Sync Behavior:**

- Embeddings are inserted to local graph first (always succeeds)
- Then mirrored to enabled remote backends in parallel
- If a remote backend fails, it logs a warning but doesn't block the operation
- Manual retry available via `rag.sync_to_remotes()`

---

## Usage Examples

### Example 1: Pure LightRAG (Text Only, Local)

```python
from src.lightrag_enhanced import LightRAGEnhanced

rag = LightRAGEnhanced(
    working_dir="./rag_storage",
    embedding_provider="openai",
    enable_supabase=False,
    enable_pinecone=False
)

# Insert
rag.insert("LightRAG is a graph-based RAG system.")

# Query (graph mode - default, fast)
result = rag.query("What is LightRAG?")
print(result["answer"])
```

**Behavior:** Identical to vanilla LightRAG. Fastest, lowest cost.

---

### Example 2: Text RAG with Dual Backend Mirrors

```python
rag = LightRAGEnhanced(
    working_dir="./rag_storage",
    embedding_provider="openai",
    enable_supabase=True,  # Mirror to Supabase
    enable_pinecone=True    # Mirror to Pinecone
)

# Insert (syncs to all 3: local + Supabase + Pinecone)
result = rag.insert("Document text...")
print(result)  # {"local": True, "supabase": True, "pinecone": True}

# Query (graph mode still default - fast)
answer = rag.query("What does the document say?")
```

**Behavior:** Embeddings mirrored to remote backends for backup/redundancy. Queries still use local graph by default (fast).

---

### Example 3: Multimodal RAG (Advanced Mode)

```python
from pathlib import Path

rag = LightRAGEnhanced(
    working_dir="./rag_storage",
    embedding_provider="gemini",  # REQUIRED for multimodal
    enable_supabase=True,
    multimodal_mode="advanced"
)

# Insert image
rag.insert(Path("diagram.png"), content_type="image")
# - Extracts text via OCR → LightRAG graph
# - Embeds raw image → Supabase

# Insert video
rag.insert(Path("tutorial.mp4"), content_type="video")
# - Transcribes audio → LightRAG graph
# - Embeds keyframes → Supabase

# Query in hybrid mode (searches graph + Supabase)
result = rag.query("Show me diagrams about X", mode="hybrid")
print(result["sources"])  # Includes both text and image sources
```

**Behavior:** Full multimodal search. Text graph + visual embeddings.

---

## Vanilla LightRAG Examples

See `examples/` in the LightRAG repo:

- `lightrag_openai_demo.py` — basic OpenAI usage
- `lightrag_openai_compatible_demo.py` — streaming responses
- Integration examples for Azure, Gemini, Ollama, HuggingFace

---

## Advanced Features

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
├── src/                          # Enhanced LightRAG implementation
│   ├── config.py                 # Environment config + feature flags
│   ├── lightrag_enhanced.py      # Main wrapper class
│   ├── embedders/
│   │   ├── base.py               # Abstract embedder interface
│   │   ├── openai_embedder.py    # OpenAI embedding wrapper
│   │   └── gemini_embedder.py    # Gemini multimodal embeddings
│   ├── adapters/
│   │   ├── base.py               # Abstract adapter interface
│   │   ├── supabase_adapter.py   # Supabase vector mirroring
│   │   └── pinecone_adapter.py   # Pinecone vector mirroring
│   └── ingestors/                # Multimodal preprocessing
│       ├── base.py               # Abstract ingestor
│       ├── text_ingestor.py      # Text extraction
│       ├── image_ingestor.py     # Image → text + raw embedding
│       ├── video_ingestor.py     # Video → transcript + keyframes
│       └── audio_ingestor.py     # Audio → transcript + raw embedding
├── schema/
│   └── supabase_schema.sql       # Supabase table definitions
├── setup_backends.py             # Backend validation script
├── .env                          # Configuration (gitignored, populated with keys)
├── .env.example                  # Configuration template
├── pyproject.toml                # Dependencies
├── uv.lock                       # Dependency lock file
├── .gitignore                    # Excludes .venv, .env, rag_storage, build artifacts
├── .venv/                        # Virtual environment (gitignored)
└── rag_storage/                  # LightRAG working directory (gitignored)
```

---

## API Reference

Complete Core API with init parameters, QueryParam options, LLM/embedding provider configs, reranker injection, and entity/relation management:

[docs/ProgramingWithCore.md](https://github.com/HKUDS/LightRAG/blob/main/docs/ProgramingWithCore.md)

---

## Integration Recommendation

From the official docs:

> ⚠️ **If you would like to integrate LightRAG into your project, we recommend utilizing the REST API provided by the LightRAG Server**. LightRAG Core is typically intended for embedded applications or for researchers who wish to conduct studies and evaluations.

For production use, run LightRAG Server and call it via REST API rather than embedding the Python library directly.

---

## Implementation Status

**Current:** Base LightRAG (vanilla) is fully functional ✅

**Enhanced Features:** Design complete, implementation pending

See complete design specification: [`docs/superpowers/specs/2026-05-04-gemini-lightrag-integration-design.md`](../../docs/superpowers/specs/2026-05-04-gemini-lightrag-integration-design.md)

**Implementation Phases:**

1. Core infrastructure (Config, EmbeddingProvider, LightRAGEnhanced wrapper)
2. Supabase adapter
3. Pinecone adapter
4. Gemini embeddings
5. Multimodal ingestors
6. Hybrid query mode
7. Documentation & examples
