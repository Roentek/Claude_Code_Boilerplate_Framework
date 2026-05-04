---
name: lightrag
description: Graph-based RAG system for knowledge extraction and Q&A
---

# LightRAG — Fast Graph-Based RAG

**LightRAG** is a graph-based Retrieval-Augmented Generation system that extracts knowledge graphs from documents for entity-relationship-aware Q&A. Outperforms naive RAG, HyDE, and GraphRAG across multiple domains.

**Use when:** Building document Q&A systems, knowledge bases, semantic search with graph relationships, or multimodal RAG (PDFs, images, tables).

**Source:** [github.com/HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) (EMNLP 2025, 13K+ stars)

---

## Setup Workflow

### 1. Install Dependencies
```bash
cd tools/lightrag
uv sync
```

Installs `lightrag-hku` and dependencies in isolated venv.

### 2. Configure LLM Provider

Add **one** of these to `.env`:
```bash
# OpenAI
OPENAI_API_KEY=sk-...

# Claude
ANTHROPIC_API_KEY=sk-ant-...

# Gemini
GEMINI_API_KEY=...

# Ollama (local)
OLLAMA_HOST=http://localhost:11434
```

### 3. Choose Storage Backend

**Default (nano-vectordb)** — no setup, good for prototyping:
```python
rag = LightRAG(working_dir="./rag_storage")
```

**Neo4J** — advanced graph queries:
```bash
# Add to .env
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=...
```

**MongoDB** — unified storage:
```bash
# Add to .env
MONGODB_URI=mongodb://localhost:27017
```

**PostgreSQL** — SQL-based queries:
```bash
# Add to .env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=...
POSTGRES_PASSWORD=...
POSTGRES_DB=lightrag
```

---

## Usage Patterns

### Pattern 1: Core Library (Embedded)

**Insert documents:**
```python
from lightrag import LightRAG, QueryParam
from lightrag.llm import openai_complete_if_cache, openai_embedding

rag = LightRAG(
    working_dir="./rag_storage",
    llm_model_func=openai_complete_if_cache,
    embedding_func=openai_embedding
)

# Insert
with open("document.txt") as f:
    rag.insert(f.read())
```

**Query:**
```python
# Modes: naive, local, global, hybrid, mix
result = rag.query(
    "What is the main topic?",
    param=QueryParam(mode="hybrid")
)
print(result)
```

### Pattern 2: Server Mode (Recommended for Production)

**Start server:**
```bash
cd tools/lightrag
python -m lightrag.server --port 9621 --working-dir ./rag_storage
```

**Query via REST API:**
```bash
# Insert document
curl -X POST http://localhost:9621/insert \
  -H "Content-Type: application/json" \
  -d '{"text": "Your document text here"}'

# Query
curl -X POST http://localhost:9621/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What is...?", "mode": "hybrid"}'
```

**Web UI:** `http://localhost:9621` — knowledge graph visualization, node queries, subgraph filtering

---

## Query Modes

| Mode | When to Use |
| ---- | ----------- |
| `naive` | Baseline retrieval without graph context |
| `local` | Local entity-based retrieval (fast) |
| `global` | Community-based global retrieval |
| `hybrid` | Combines local + global (best for broad queries) |
| `mix` | Uses reranker — best performance when reranker is configured |

**Default:** `hybrid` (no reranker) or `mix` (with reranker)

---

## LLM/Embedding Configuration

### LLM Requirements
- **Minimum:** 32B params, 32KB context
- **Recommended:** 64KB context
- **Indexing:** Non-reasoning models (faster)
- **Query:** Stronger models than indexing for best results

### Embedding Model
- **Recommended:** `BAAI/bge-m3`, `text-embedding-3-large`
- **Critical:** Same model for indexing AND querying
- **Dimension lock:** PostgreSQL requires dimension at table creation — changing models = drop tables and recreate

### Reranker (Optional)
- **Boosts performance** significantly when enabled with `mode="mix"`
- **Recommended:** `BAAI/bge-reranker-v2-m3`, Jina reranker API

---

## LLM Provider Examples

**OpenAI:**
```python
from lightrag.llm import openai_complete_if_cache, openai_embedding

rag = LightRAG(
    working_dir="./rag_storage",
    llm_model_func=openai_complete_if_cache,
    embedding_func=openai_embedding
)
```

**Claude (Anthropic):**
```python
from lightrag.llm import anthropic_complete, openai_embedding  # use OpenAI for embeddings

rag = LightRAG(
    working_dir="./rag_storage",
    llm_model_func=anthropic_complete,
    embedding_func=openai_embedding
)
```

**Ollama (Local):**
```python
from lightrag.llm import ollama_model_complete, ollama_embedding

rag = LightRAG(
    working_dir="./rag_storage",
    llm_model_func=ollama_model_complete,
    llm_model_name="llama3.2:latest",
    embedding_func=ollama_embedding,
    embedding_model_name="nomic-embed-text"
)
```

**Gemini:**
```python
from lightrag.llm import gemini_complete, openai_embedding

rag = LightRAG(
    working_dir="./rag_storage",
    llm_model_func=gemini_complete,
    embedding_func=openai_embedding
)
```

---

## Advanced Features

- **Token tracking** — `rag.token_usage()`
- **Export KG data** — `rag.export_knowledge_graph()`
- **LLM cache** — `kv_store_llm_response_cache.json` in working_dir
- **Delete documents** — `rag.delete_document(doc_id)` with auto KG regeneration
- **Langfuse tracing** — observability integration
- **RAGAS evaluation** — measure retrieval quality
- **Multimodal RAG** — integrate with RAG-Anything for PDFs, images, tables

Full docs: [docs/AdvancedFeatures.md](https://github.com/HKUDS/LightRAG/blob/main/docs/AdvancedFeatures.md)

---

## File Structure

```txt
tools/lightrag/
  pyproject.toml        ← Dependencies (lightrag-hku)
  README.md             ← Full documentation
  uv.lock               ← Dependency lock file
  .gitignore            ← Excludes .venv, rag_storage, build artifacts
  .venv/                ← Virtual environment (gitignored, recreated by `uv sync`)
  rag_storage/          ← Working directory (gitignored, auto-created on first use)
```

---

## Commands

```bash
# Install
cd tools/lightrag && uv sync

# Start server
cd tools/lightrag && python -m lightrag.server --port 9621 --working-dir ./rag_storage

# Test insert/query via Python
cd tools/lightrag && uv run python -c "
from lightrag import LightRAG, QueryParam
rag = LightRAG(working_dir='./rag_storage')
rag.insert('The capital of France is Paris.')
print(rag.query('What is the capital of France?', param=QueryParam(mode='naive')))
"
```

---

## Platform Support

- **Windows:** Full support (requires Python 3.10+)
- **macOS:** Full support
- **Linux:** Full support

---

## References

- **GitHub:** https://github.com/HKUDS/LightRAG
- **Paper:** https://arxiv.org/abs/2410.05779 (EMNLP 2025)
- **PyPI:** https://pypi.org/project/lightrag-hku/
- **Core API:** [docs/ProgramingWithCore.md](https://github.com/HKUDS/LightRAG/blob/main/docs/ProgramingWithCore.md)
- **Server docs:** [docs/LightRAG-API-Server.md](https://github.com/HKUDS/LightRAG/blob/main/docs/LightRAG-API-Server.md)
