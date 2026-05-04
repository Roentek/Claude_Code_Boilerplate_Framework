# LightRAG Integration

**LightRAG** is a fast, graph-based Retrieval-Augmented Generation (RAG) system from EMNLP 2025. It extracts knowledge graphs from documents and performs entity-relationship-aware retrieval for superior Q&A performance.

**Source:** [github.com/HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (13K+ stars)

---

## What It Does

- **Graph-based RAG** — extracts entities and relationships from documents, stores them in a knowledge graph
- **Multiple query modes** — naive, local, global, hybrid, and mix (with reranker)
- **Storage backends** — Neo4J, MongoDB, PostgreSQL, OpenSearch, or default (nano-vectordb)
- **Multimodal support** — processes PDFs, Office docs, images, tables via RAG-Anything integration
- **Web UI + REST API** — optional LightRAG Server for visualization and programmatic access

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

Add to `.env`:

```bash
# LightRAG — choose one LLM provider
OPENAI_API_KEY=sk-...           # OpenAI
# or
ANTHROPIC_API_KEY=sk-ant-...    # Claude
# or
GEMINI_API_KEY=...              # Google Gemini
# or
OLLAMA_HOST=http://localhost:11434  # Local Ollama
```

### 3. Basic Usage

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

### 4. LightRAG Server (Web UI + API)

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

### LLM Requirements

- **Minimum:** 32B parameters, 32KB context
- **Recommended:** 64KB context, non-reasoning models for indexing
- **Query stage:** Use stronger models than indexing for best results

### Embedding Model

- **Recommended:** `BAAI/bge-m3`, `text-embedding-3-large`
- **Important:** Must use the same embedding model for indexing and querying
- **Dimension lock:** PostgreSQL requires setting vector dimension at table creation — changing models requires recreating tables

### Reranker (Optional)

- **Boosts performance** when enabled with "mix" query mode
- **Recommended:** `BAAI/bge-reranker-v2-m3`, Jina reranker services

---

## Storage Backends

| Backend | Use When |
| ------- | -------- |
| **Default (nano-vectordb)** | Simple prototyping, small datasets |
| **Neo4J** | Advanced graph queries, visualization, production scale |
| **MongoDB** | Unified storage, existing MongoDB infrastructure |
| **PostgreSQL** | SQL-based queries, pgvector support |
| **OpenSearch** | Elasticsearch-style search, large-scale deployments |

---

## Examples

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
  pyproject.toml        ← Dependencies (lightrag-hku)
  README.md             ← This file
  uv.lock               ← Dependency lock file
  .gitignore            ← Excludes .venv, rag_storage, build artifacts
  .venv/                ← Virtual environment (gitignored, recreated by `uv sync`)
  rag_storage/          ← Working directory (gitignored, auto-created on first use)
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
