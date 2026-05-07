# LightRAG Enhanced: Gemini Embeddings & Multi-Backend Vector Storage Integration

**Date:** 2026-05-04  
**Author:** Claude Sonnet 4.5  
**Status:** Design Approved  
**Implementation:** Pending

---

## Executive Summary

Integrate Google's Gemini multimodal embedding framework into the existing LightRAG system with flexible vector storage backends. The integration uses an **adapter layer pattern** that preserves LightRAG's core knowledge graph functionality while adding optional:

1. **Gemini multimodal embeddings** (text, images, video, audio) alongside OpenAI text embeddings
2. **Multi-backend vector storage** - mirror embeddings to Supabase and/or Pinecone
3. **Hybrid query modes** - search local graph only (fast) or all backends (comprehensive)
4. **Multimodal processing** - simple mode (text extraction) or advanced mode (raw multimodal embeddings)

**Key Principle:** LightRAG core remains unchanged and always functional. Adapters are bolt-ons that can be enabled/disabled via configuration flags.

---

## Design Goals

1. ✅ **Preserve LightRAG Core** - No modifications to native LightRAG, always works locally
2. ✅ **Embedding Provider Choice** - OpenAI (text-only) or Gemini (multimodal), configurable
3. ✅ **Multi-Backend Storage** - Enable Supabase, Pinecone, both, or neither
4. ✅ **Fail-Safe Syncing** - Remote failures log warnings but don't block local operations
5. ✅ **Mode-Based Queries** - Default to graph-only (fast), opt-in hybrid (multimodal)
6. ✅ **Configuration Guardrails** - Prevent invalid combinations (e.g., multimodal + OpenAI)

---

## Architecture Overview

### System Layers

```text
┌─────────────────────────────────────────────────────────────┐
│                       User Application                       │
│                  (insert/query interface)                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   LightRAGEnhanced                          │
│  - Wraps native LightRAG with adapter hooks                 │
│  - Routes based on content type and mode                    │
│  - Handles simple vs advanced modes                         │
└─────────────────────────────────────────────────────────────┘
                           ↓
        ┌──────────────────┴──────────────────┐
        ↓                                      ↓
┌───────────────────┐              ┌─────────────────────────┐
│  LightRAG Core    │              │  EmbeddingProvider      │
│  (Local Graph)    │              │  - OpenAI (default)     │
│  - Always Active  │              │  - Gemini (optional)    │
│  - nano-vectordb  │              │  - Configurable dims    │
└───────────────────┘              └─────────────────────────┘
                                               ↓
                                   ┌─────────────────────────┐
                                   │   VectorSyncAdapter     │
                                   │   (Optional Mirroring)  │
                                   └─────────────────────────┘
                                               ↓
                        ┌──────────────────────┴───────────────────┐
                        ↓                                           ↓
            ┌──────────────────────┐                  ┌──────────────────────┐
            │  SupabaseAdapter     │                  │  PineconeAdapter     │
            │  (if enabled)        │                  │  (if enabled)        │
            │  - Upserts vectors   │                  │  - Upserts vectors   │
            │  - Similarity search │                  │  - Similarity search │
            └──────────────────────┘                  └──────────────────────┘
```

### File Structure

```text
tools/lightrag/
├── src/
│   ├── config.py                      # Environment config + feature flags
│   ├── lightrag_enhanced.py           # Main wrapper class
│   ├── embedders/
│   │   ├── base.py                    # Abstract embedder interface
│   │   ├── openai_embedder.py         # OpenAI embedding wrapper
│   │   └── gemini_embedder.py         # Gemini embedding (from reference repo)
│   ├── adapters/
│   │   ├── base.py                    # Abstract adapter interface
│   │   ├── supabase_adapter.py        # Supabase vector mirroring
│   │   └── pinecone_adapter.py        # Pinecone vector mirroring
│   └── ingestors/                     # Multimodal preprocessing
│       ├── base.py                    # Abstract ingestor
│       ├── text_ingestor.py           # Text extraction (OCR, etc.)
│       ├── image_ingestor.py          # Image → text + raw embedding
│       ├── video_ingestor.py          # Video → transcript + keyframes
│       └── audio_ingestor.py          # Audio → transcript + raw embedding
├── schema/
│   └── supabase_schema.sql            # Supabase table definitions
├── setup_backends.py                  # Backend validation script
├── .env                               # Configuration (populated with keys)
├── .env.example                       # Configuration template
├── pyproject.toml                     # Dependencies
└── README.md                          # Usage guide
```

---

## Component Breakdown

### 1. LightRAGEnhanced (Main Entry Point)

**Purpose:** Wraps native LightRAG with optional adapter functionality.

**Key Design Principle:** LightRAG core is instantiated as-is, untouched. Adapters intercept embeddings after generation.

**Interface:**

```python
class LightRAGEnhanced:
    def __init__(
        self,
        working_dir: str,
        embedding_provider: str = "openai",  # or "gemini"
        embedding_model: str | None = None,  # Auto-selects default if None
        enable_supabase: bool = False,
        enable_pinecone: bool = False,
        multimodal_mode: str = "simple"  # or "advanced"
    )
    
    def insert(self, content, content_type="text") -> dict
    def query(self, text, mode="graph", top_k=10) -> dict
    def sync_to_remotes(self) -> dict  # Manual sync trigger
```

---

### 2. EmbeddingProvider (Abstract Base)

**Purpose:** Abstract interface for swapping embedding providers without code changes.

**Implementations:**

| Provider | Capabilities | Models | Dimensions |
|----------|-------------|--------|-----------|
| **OpenAI** | Text only | `text-embedding-3-small` (default)<br>`text-embedding-3-large` | 1536<br>3072 |
| **Gemini** | Text + multimodal | `gemini-embedding-2-preview` (default)<br>`gemini-embedding-2` | 3072<br>768 |

**Interface:**

```python
class EmbeddingProvider(ABC):
    @abstractmethod
    async def embed_text(self, text: str, task_type: str) -> list[float]
    
    @abstractmethod
    async def embed_image(self, image_path: Path) -> list[float]
    
    @abstractmethod
    async def embed_video(self, video_path: Path) -> list[float]
    
    @abstractmethod
    async def embed_audio(self, audio_path: Path) -> list[float]
    
    @property
    @abstractmethod
    def embedding_dim(self) -> int  # Auto-detected from model
```

---

### 3. VectorAdapter (Abstract Base)

**Purpose:** Mirror embeddings to remote vector stores with fail-safe error handling.

**Interface:**

```python
class VectorAdapter(ABC):
    @abstractmethod
    def upsert(self, id: str, embedding: list[float], metadata: dict) -> None
    
    @abstractmethod
    def similarity_search(self, query_embedding: list[float], top_k: int) -> list[dict]
    
    @abstractmethod
    def delete(self, id: str) -> None
```

**Implementations:**
- `SupabaseAdapter` - Uses Supabase pgvector with `lightrag_embeddings` table
- `PineconeAdapter` - Uses Pinecone serverless index

**Error Handling:** All adapter methods catch exceptions, log errors, and never throw. This ensures local LightRAG remains functional even when remote backends fail.

---

### 4. ContentIngestor (Multimodal Preprocessing)

**Purpose:** Convert multimodal content to text for LightRAG graph, optionally embed raw content for vector search.

**Interface:**

```python
class ContentIngestor(ABC):
    @abstractmethod
    def extract_text(self, file_path: Path) -> str
    
    @abstractmethod
    def should_embed_raw(self) -> bool  # True for advanced mode
```

**Implementations:**
- `TextIngestor` - Pass-through (already text)
- `ImageIngestor` - OCR extraction + optional raw embedding
- `VideoIngestor` - Transcript + optional keyframe embedding
- `AudioIngestor` - Transcription + optional raw embedding

---

### 5. Config (Environment Configuration)

**Purpose:** Load, validate, and provide feature flags from environment variables.

**Key Fields:**

```python
class Config:
    # Embedding Provider
    EMBEDDING_PROVIDER: str = "openai"  # openai | gemini
    OPENAI_API_KEY: str
    OPENAI_EMBEDDING_MODEL: str = "text-embedding-3-small"  # DEFAULT
    GEMINI_API_KEY: str
    GEMINI_EMBEDDING_MODEL: str = "gemini-embedding-2-preview"  # DEFAULT
    EMBEDDING_DIM: int | None = None  # Auto-detect from model
    
    # Vector Backends
    ENABLE_SUPABASE: bool = False
    ENABLE_PINECONE: bool = False
    SUPABASE_URL: str
    SUPABASE_KEY: str
    PINECONE_API_KEY: str
    PINECONE_INDEX: str
    PINECONE_ENVIRONMENT: str
    
    # Multimodal
    MULTIMODAL_MODE: str = "simple"  # simple | advanced
```

**Validation Rules:**
1. Provider must be `openai` or `gemini`
2. Required API key for selected provider must be set
3. `MULTIMODAL_MODE=advanced` requires `EMBEDDING_PROVIDER=gemini`
4. Embedding dimension must match model (auto-detected or explicit override)

**Backward Compatibility:**

The Config class supports both new and legacy LightRAG variable names:

```python
class Config:
    def __init__(self):
        # NEW variables (preferred) with fallback to legacy names
        self.EMBEDDING_PROVIDER = os.getenv("EMBEDDING_PROVIDER") or os.getenv("EMBEDDING_BINDING", "openai")
        
        self.OPENAI_EMBEDDING_MODEL = os.getenv("OPENAI_EMBEDDING_MODEL") or os.getenv("EMBEDDING_MODEL", "text-embedding-3-small")
        
        self.LIGHTRAG_LLM_PROVIDER = os.getenv("LIGHTRAG_LLM_PROVIDER") or os.getenv("LLM_BINDING", "openai")
        
        self.LIGHTRAG_LLM_MODEL = os.getenv("LIGHTRAG_LLM_MODEL") or os.getenv("LLM_MODEL", "gpt-4o-mini")
```

**Legacy Variable Mapping:**

| New Variable (Preferred) | Legacy Variable (Supported) | Purpose |
|-------------------------|----------------------------|---------|
| `EMBEDDING_PROVIDER` | `EMBEDDING_BINDING` | Embedding provider selection |
| `OPENAI_EMBEDDING_MODEL` | `EMBEDDING_MODEL` | OpenAI model selection |
| `LIGHTRAG_LLM_PROVIDER` | `LLM_BINDING` | LLM provider for answer generation |
| `LIGHTRAG_LLM_MODEL` | `LLM_MODEL` | LLM model for answer generation |

This ensures existing LightRAG server configs continue to work without modification.

---

## Integration Mechanism

### How Adapters Intercept Embeddings Without Modifying LightRAG

**Challenge:** LightRAG generates embeddings internally. How do we sync to remote adapters without modifying LightRAG's code?

**Solution:** Embedding Function Wrapper Pattern

**Step 1: Create Wrapped Embedding Function**

```python
class LightRAGEnhanced:
    def _create_embedding_wrapper(self):
        """
        Create a wrapped embedding function that syncs to adapters.
        This function is passed to native LightRAG, replacing its default embedder.
        """
        # Get base embedding function (OpenAI or Gemini)
        if self.config.EMBEDDING_PROVIDER == "openai":
            base_embedder = self._get_openai_embedder()
        else:
            base_embedder = self._get_gemini_embedder()
        
        # Wrap it with adapter sync logic
        async def embedding_func_with_sync(text: str) -> list[float]:
            # 1. Get embedding from provider (OpenAI or Gemini)
            embedding = await base_embedder.embed_text(text, task_type="RETRIEVAL_DOCUMENT")
            
            # 2. Sync to adapters (async in background, don't block LightRAG)
            if self.adapters_enabled:
                # Fire-and-forget: launch sync but don't wait for completion
                asyncio.create_task(
                    self._sync_to_adapters(
                        id=self._generate_id(text),
                        embedding=embedding,
                        metadata={"content_text": text, "content_type": "text"}
                    )
                )
            
            # 3. Return embedding to LightRAG (continues immediately, unblocked)
            return embedding
        
        return embedding_func_with_sync
```

**Step 2: Pass Wrapped Function to LightRAG**

```python
    def __init__(self, ...):
        config = Config()
        
        # Create embedding wrapper
        embedding_func = self._create_embedding_wrapper()
        
        # Initialize native LightRAG with OUR function
        self.lightrag = LightRAG(
            working_dir=config.LIGHTRAG_WORKING_DIR,
            llm_model_func=self._get_llm_func(config),
            embedding_func=embedding_func  # Our wrapper, not LightRAG's default
        )
```

**Data Flow:**

```
LightRAG calls embedding_func(text)  [thinks it's calling OpenAI directly]
    ↓
Our wrapper intercepts the call
    ├─→ Step 1: Call actual provider (OpenAI/Gemini) → get embedding
    ├─→ Step 2: Launch background task to sync to Supabase/Pinecone
    │            (async, non-blocking)
    └─→ Step 3: Return embedding to LightRAG (continues immediately)
```

**Key Benefits:**
1. ✅ **Non-invasive** - LightRAG code is never modified
2. ✅ **Transparent** - LightRAG doesn't know adapters exist
3. ✅ **Non-blocking** - Sync happens in background, doesn't slow down LightRAG
4. ✅ **Fail-safe** - If sync fails, LightRAG still succeeds
5. ✅ **Maintainable** - All adapter logic isolated in wrapper, easy to debug

**Integration Points Summary:**

| LightRAG Component | How We Integrate | Modification Level |
|--------------------|------------------|-------------------|
| Embedding function | **Replace** with our wrapper | ✅ Zero modification |
| LLM function | Pass our configured function | ✅ Zero modification |
| Storage | Use LightRAG's default (nano-vectordb) | ✅ Zero modification |
| Insert/Query methods | Call native methods as-is | ✅ Zero modification |

---

## Data Flow

### Insert Flow (Text Content)

```
User: rag.insert("Document text...")
    ↓
LightRAGEnhanced.insert()
    ↓
Embedding Provider → embed_text() → [float] × dimension
    ↓
LightRAG Core (UNCHANGED)
    ├─→ Extracts entities/relationships
    ├─→ Stores in local graph
    └─→ Returns success
    ↓
VectorSyncAdapter (if enabled)
    ├─→ Supabase.upsert() (parallel)
    ├─→ Pinecone.upsert() (parallel)
    └─→ Log results (never throw)
    ↓
Return to user
```

**Key Points:**
- LightRAG completes **before** remote sync
- Local graph **always** updated successfully
- Remote failures logged but don't block

---

### Insert Flow (Multimodal - Simple Mode)

```
User: rag.insert(Path("image.jpg"), content_type="image")
    ↓
ImageIngestor.extract_text() → OCR result
    ↓
LightRAG Core (receives text)
    ├─→ Processes text
    ├─→ Builds graph
    └─→ Stores locally
    ↓
(No multimodal embedding in simple mode)
```

---

### Insert Flow (Multimodal - Advanced Mode)

```
User: rag.insert(Path("image.jpg"), content_type="image")
    ↓
Fork TWO parallel paths:
    ↓                           ↓
Text Extraction          Raw Embedding
    ↓                           ↓
ImageIngestor           GeminiEmbedder
.extract_text()         .embed_image()
    ↓                           ↓
LightRAG Core           VectorSyncAdapter
(builds graph)          (Supabase/Pinecone)
```

**Advanced Mode Benefits:**
- Text goes into knowledge graph (entities, relationships)
- Raw multimodal embedding enables semantic visual search
- Queryable via hybrid mode

---

### Query Flow (Graph Mode - Default)

```
User: rag.query("What is X?")  # mode="graph" default
    ↓
Embed query → [float] × dimension
    ↓
LightRAG Core ONLY
    ├─→ Similarity search in local graph
    ├─→ Finds relevant entities/chunks
    └─→ Generates answer
    ↓
Return answer + sources
```

**Fast, local-only, default behavior.**

---

### Query Flow (Hybrid Mode)

```
User: rag.query("Show me images of X", mode="hybrid")
    ↓
Embed query → [float] × dimension
    ↓
Parallel search ALL enabled backends:
    ├─→ LightRAG (local graph)
    ├─→ Supabase (if enabled)
    └─→ Pinecone (if enabled)
    ↓
ResultMerger
    ├─→ Combine results
    ├─→ De-duplicate by source ID
    ├─→ Re-rank by similarity
    └─→ Take top-K
    ↓
Generate answer with merged context
```

**Comprehensive, slower, opt-in.**

---

## Configuration & Environment

### Provider Capabilities

| Provider | Text | Images | Video | Audio | Use Case |
|----------|------|--------|-------|-------|----------|
| **OpenAI** | ✅ | ❌ | ❌ | ❌ | Pure text RAG |
| **Gemini** | ✅ | ✅ | ✅ | ✅ | Multimodal RAG |

### Valid Configurations

| Provider | Multimodal Mode | Content Types | Backend Sync | Valid? |
|----------|----------------|---------------|--------------|--------|
| `openai` | `simple` | Text only | Supabase/Pinecone (text) | ✅ |
| `openai` | `advanced` | Any | - | ❌ ERROR: OpenAI can't embed multimodal |
| `gemini` | `simple` | Text only | Supabase/Pinecone (text) | ✅ |
| `gemini` | `advanced` | Text + multimodal | Supabase/Pinecone (all) | ✅ |

### Backend Combinations

| Supabase | Pinecone | Behavior |
|----------|----------|----------|
| ❌ | ❌ | Local only (vanilla LightRAG) |
| ✅ | ❌ | Sync to Supabase only |
| ❌ | ✅ | Sync to Pinecone only |
| ✅ | ✅ | Sync to both in parallel |

**All combinations are valid.** Adapters are independent.

---

## Backend Setup

### Supabase (Manual SQL Required)

**File:** `schema/supabase_schema.sql`

User must run this once in Supabase SQL Editor:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TYPE content_type_enum AS ENUM ('text', 'image', 'video', 'audio');

CREATE TABLE IF NOT EXISTS lightrag_embeddings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source          TEXT NOT NULL UNIQUE,
    content_type    content_type_enum NOT NULL,
    content_text    TEXT,
    metadata        JSONB DEFAULT '{}'::jsonb,
    embedding       VECTOR(3072) NOT NULL,  -- Match EMBEDDING_DIM
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX lightrag_embeddings_embedding_idx
    ON lightrag_embeddings
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

CREATE OR REPLACE FUNCTION match_lightrag_embeddings(...)
RETURNS TABLE (...) AS $$ ... $$;
```

**Important:** Vector dimension must match `EMBEDDING_DIM` in `.env`.

---

### Pinecone (Auto-Created)

No manual setup required. The `setup_backends.py` script will:

1. Check if index exists
2. Create index with correct dimension if missing
3. Validate dimension matches config

**Index Spec:**
- Dimension: Matches `EMBEDDING_DIM` (e.g., 3072)
- Metric: `cosine`
- Type: Serverless (AWS)
- Region: Configurable via `PINECONE_ENVIRONMENT`

---

### Setup Validation Script

**File:** `setup_backends.py`

```bash
cd tools/lightrag
uv run python setup_backends.py
```

**What it does:**
1. ✅ Validates Supabase connection
2. ✅ Checks if `lightrag_embeddings` table exists
3. ✅ Checks if RPC function exists
4. ✅ Creates Pinecone index if missing
5. ✅ Validates dimensions match across all backends

**Output:**
```
════════════════════════════════════════════════════════════
LightRAG Enhanced - Backend Setup
════════════════════════════════════════════════════════════

Embedding Provider: openai
Embedding Dimension: 1536
Multimodal Mode: simple

════════════════════════════════════════════════════════════
Supabase Setup
════════════════════════════════════════════════════════════
✓ Connected to Supabase
✓ Table 'lightrag_embeddings' exists
✓ RPC function 'match_lightrag_embeddings' exists
✓ Supabase setup complete!

════════════════════════════════════════════════════════════
Pinecone Setup
════════════════════════════════════════════════════════════
✓ Connected to Pinecone
Creating index 'lightrag-vectors'...
  Dimension: 1536
  Metric: cosine
  Cloud: aws (us-east-1)
✓ Index 'lightrag-vectors' created successfully!
✓ Pinecone setup complete!

════════════════════════════════════════════════════════════
✓ All enabled backends are ready!
════════════════════════════════════════════════════════════
```

---

## Error Handling

### Configuration Errors (Fail Fast)

Raised during `Config()` initialization:

```python
# Invalid provider
if EMBEDDING_PROVIDER not in ["openai", "gemini"]:
    raise ValueError("EMBEDDING_PROVIDER must be 'openai' or 'gemini'")

# Advanced mode requires Gemini
if MULTIMODAL_MODE == "advanced" and EMBEDDING_PROVIDER == "openai":
    raise ConfigError(
        "MULTIMODAL_MODE=advanced requires EMBEDDING_PROVIDER=gemini. "
        "OpenAI embeddings only support text."
    )

# Missing required keys
if ENABLE_SUPABASE and not SUPABASE_URL:
    raise EnvironmentError("SUPABASE_URL required when ENABLE_SUPABASE=true")
```

**Result:** Clear error messages guide users to fix `.env` before startup.

---

### Runtime Errors (Fail Safe)

**Adapter sync failures:**

```python
async def sync_to_remotes(id, embedding, metadata):
    results = {}
    
    for adapter_name, adapter in enabled_adapters:
        try:
            await adapter.upsert(id, embedding, metadata)
            results[adapter_name] = True
            logger.info(f"✓ Synced to {adapter_name}: {id}")
        except Exception as e:
            results[adapter_name] = False
            logger.error(f"✗ Failed to sync to {adapter_name}: {e}")
            # Log but don't raise - fail-safe behavior
    
    return results
```

**Result:** Local insert succeeds even if all remotes fail. User can retry sync manually later.

---

### Invalid Content Type

```python
def validate_content_type(content_type, provider, mode):
    multimodal_types = ["image", "video", "audio"]
    
    if content_type in multimodal_types and provider == "openai":
        if mode == "advanced":
            raise ValueError(
                f"Cannot embed {content_type} with OpenAI. "
                "Options: 1) Switch to EMBEDDING_PROVIDER=gemini, or "
                "2) Keep openai + MULTIMODAL_MODE=simple (text extraction only)"
            )
        elif mode == "simple":
            logger.info(f"Extracting text from {content_type} (OpenAI text-only)")
            # Proceeds with OCR/transcription
```

**Result:** Prevents runtime crashes from invalid configurations.

---

## Testing Strategy

### Unit Tests

**Coverage:**
- `Config` validation rules
- Embedding provider dimension detection
- Adapter error handling (mocked backends)
- Content type validation logic

**Example:**
```python
def test_config_rejects_advanced_mode_with_openai():
    os.environ["EMBEDDING_PROVIDER"] = "openai"
    os.environ["MULTIMODAL_MODE"] = "advanced"
    with pytest.raises(ConfigError, match="requires.*gemini"):
        Config()
```

---

### Integration Tests

**Coverage:**
- Supabase adapter CRUD operations
- Pinecone adapter CRUD operations
- LightRAG + adapter sync flow
- Query result merging (hybrid mode)

**Requirements:**
- Test Supabase project (dimension 1536)
- Test Pinecone index (dimension 1536)
- Environment: `ENABLE_SUPABASE=true`, `ENABLE_PINECONE=true`

**Example:**
```python
async def test_dual_backend_sync():
    rag = LightRAGEnhanced(
        working_dir="./test_storage",
        embedding_provider="openai",
        enable_supabase=True,
        enable_pinecone=True
    )
    
    result = await rag.insert("Test document")
    
    assert result["local"] == True
    assert result["supabase"] == True
    assert result["pinecone"] == True
```

---

### Manual Tests

**Scenarios:**
1. Pure text RAG (OpenAI + local only)
2. Text RAG with Supabase mirror
3. Text RAG with Pinecone mirror
4. Text RAG with both mirrors
5. Multimodal RAG (Gemini + advanced mode + Supabase)
6. Backend failure recovery (kill Supabase mid-insert, verify local succeeds)

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

# Query (graph mode - default)
result = rag.query("What is LightRAG?")
print(result["answer"])
```

**Behavior:** Identical to vanilla LightRAG. Fastest, lowest cost.

---

### Example 2: Text RAG with Dual Backends

```python
rag = LightRAGEnhanced(
    working_dir="./rag_storage",
    embedding_provider="openai",
    enable_supabase=True,
    enable_pinecone=True
)

# Insert (syncs to all 3: local + Supabase + Pinecone)
result = rag.insert("Document text...")
print(result)  # {"local": True, "supabase": True, "pinecone": True}

# Query (graph mode still default)
answer = rag.query("What does the document say?")
```

**Behavior:** Embeddings mirrored to remote backends for backup/redundancy. Queries still use local graph by default (fast).

---

### Example 3: Multimodal RAG (Advanced Mode)

```python
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

## File Ingestion Workflow

### Current State Analysis

**LightRAG Server (tools/lightrag/.venv/Lib/site-packages/lightrag/api/):**
- ✅ **HTTP Upload API**: `/documents/upload` endpoint (`document_routes.py:2118`)
- ✅ **Background Processing**: FastAPI BackgroundTasks for async ingestion
- ✅ **Duplicate Detection**: Filename and content-based deduplication
- ✅ **Web UI**: React/TypeScript SPA with graph visualization (`webui/index.html`)
- ❌ **Multimodal Support**: Only text-based files (`.txt`, `.md`, `.pdf`, `.docx`, code files, etc.)
- ❌ **File Watching**: No automatic data folder monitoring

**Reference Repo (Gemini RAG Framework):**
- ✅ **Automatic File Watcher**: `watcher.py` monitors `data/` folder with 1.5s debounce
- ✅ **Multimodal Support**: text, images (`.png`, `.jpg`), video (`.mp4`, `.mov`), audio (`.mp3`, `.wav`)
- ✅ **SSE Broadcast**: Real-time status updates pushed to web UI via `/sync-events`
- ✅ **Startup Sync**: Diffs disk vs DB on server start, removes deleted files

### Gap Identified

LightRAG Enhanced needs to support multimodal files when using Gemini embeddings, but:
1. LightRAG Server's `/documents/upload` only accepts text-based file types
2. No automatic file watching for drop-and-ingest workflows
3. Web UI not designed for multimodal file uploads

### Proposed Solution: Three-Tiered Ingestion

**Tier 1: Programmatic API** (Already in Design)
```python
rag.insert(Path("diagram.png"), content_type="image")  # Direct method call
```

**Tier 2: HTTP Upload API Extension**
Extend LightRAG Server's `/documents/upload` endpoint to support multimodal files:

```python
# In document_routes.py DocumentManager.__init__
supported_extensions: tuple = (
    # Existing text-based extensions
    ".txt", ".md", ".pdf", ".docx", ".pptx", ...,
    
    # New multimodal extensions (only if EMBEDDING_PROVIDER=gemini)
    ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff", ".webp",  # images
    ".mp4", ".avi", ".mov", ".wmv", ".webm", ".mkv",            # video
    ".mp3", ".wav", ".m4a", ".ogg", ".flac", ".aac",            # audio
)
```

**File Type Routing Logic:**
```python
async def process_upload(file_path: Path):
    ext = file_path.suffix.lower()
    
    # Text-based files → LightRAG native processing
    if ext in TEXT_EXTENSIONS:
        await rag.ainsert(file_path.read_text())
    
    # Multimodal files → ingestor layer (only if Gemini enabled)
    elif ext in IMAGE_EXTENSIONS:
        from src.ingestors.image_ingestor import ImageIngestor
        await ImageIngestor(embedder, adapters, config).ingest(file_path)
    
    elif ext in VIDEO_EXTENSIONS:
        from src.ingestors.video_ingestor import VideoIngestor
        await VideoIngestor(embedder, adapters, config).ingest(file_path)
    
    elif ext in AUDIO_EXTENSIONS:
        from src.ingestors.audio_ingestor import AudioIngestor
        await AudioIngestor(embedder, adapters, config).ingest(file_path)
```

**Tier 3: Optional File Watcher** (Inspired by Reference Repo)
For users who want drop-and-ingest workflow:

```python
# tools/lightrag/src/watcher.py (new file, adapted from reference repo)
async def sync_then_watch(rag_enhanced, data_dir, on_event=None):
    """Auto-ingest files from data/ folder"""
    
    # Startup sync: diff disk vs LightRAG doc_status
    await startup_sync(rag_enhanced, data_dir, on_event)
    
    # Live watcher: 1.5s debounce
    async for changes in awatch(data_dir):
        for change_type, path in changes:
            if change_type == Change.deleted:
                await rag_enhanced.delete_document(path)
            else:
                await rag_enhanced.insert_from_file(path)
```

**Server Integration (Optional Flag):**
```python
# In lightrag_server.py lifespan
if Config.ENABLE_FILE_WATCHER:  # New env var: ENABLE_FILE_WATCHER=true
    DATA_DIR = Path(args.working_dir) / "data"
    DATA_DIR.mkdir(exist_ok=True)
    
    watcher_task = asyncio.create_task(
        sync_then_watch(rag_enhanced, DATA_DIR, on_event=broadcast_to_ui)
    )
```

### User-Facing Workflow

**Option A: Web UI Upload** (Existing LightRAG Flow)
1. User opens http://localhost:9621 (LightRAG Server)
2. Uploads file via UI (drag-and-drop or file picker)
3. Server validates file type based on embedding provider
4. Background task processes file
5. Web UI shows ingestion progress

**Option B: Data Folder Drop** (Optional, New)
1. User drops files into `tools/lightrag/data/images/`, `data/text/`, `data/video/`
2. File watcher detects changes with 1.5s debounce
3. Auto-ingests new/modified files
4. Removes embeddings for deleted files
5. SSE broadcast shows real-time status (if UI connected)

**Option C: Programmatic API** (Existing in Design)
```python
from pathlib import Path
from tools.lightrag.src.lightrag_enhanced import LightRAGEnhanced

rag = LightRAGEnhanced(embedding_provider="gemini")
await rag.insert(Path("diagram.png"), content_type="image")
```

### Implementation Decision

**Phase 1 (Core Infrastructure):** Programmatic API only (Option C)
- `rag.insert(Path(...), content_type=...)` works immediately
- No server changes required
- Sufficient for power users and scripting

**Phase 2 (HTTP API Extension):** Extend `/documents/upload` endpoint
- Multimodal file type support based on embedding provider
- File type routing to appropriate ingestor
- Backward compatible — text files still work as before

**Phase 3 (Optional):** File watcher for drop-and-ingest workflow
- Controlled by `ENABLE_FILE_WATCHER` env var (default: false)
- Creates `data/` subdirectory in `working_dir`
- Startup sync + live watching with SSE broadcast

### Configuration

**New Environment Variables:**
```bash
# File Ingestion (Optional)
ENABLE_FILE_WATCHER=false  # Enable automatic data folder monitoring
```

### Documentation Updates

**README.md additions:**
```markdown
### File Ingestion Methods

**Method 1: Programmatic API**
```python
rag.insert(Path("document.pdf"))                   # Text extraction
rag.insert(Path("diagram.png"), content_type="image")  # Multimodal
```

**Method 2: HTTP Upload**
```bash
curl -X POST http://localhost:9621/documents/upload \
  -F "file=@diagram.png"
```

**Method 3: Data Folder (Optional)**
```bash
# Enable in .env
ENABLE_FILE_WATCHER=true

# Drop files
cp *.png tools/lightrag/data/images/
cp *.pdf tools/lightrag/data/text/

# Auto-ingested within 1.5 seconds
```
```

---

## Implementation Phases

**Phase 1: Core Infrastructure**
1. `Config` class with validation
2. `EmbeddingProvider` base + OpenAI implementation
3. `LightRAGEnhanced` wrapper (text-only, no adapters)
4. Unit tests

**Phase 2: Supabase Adapter**
1. `SupabaseAdapter` implementation
2. `supabase_schema.sql`
3. Integration tests
4. `setup_backends.py` (Supabase validation only)

**Phase 3: Pinecone Adapter**
1. `PineconeAdapter` implementation
2. `setup_backends.py` (Pinecone auto-create)
3. Integration tests

**Phase 4: Gemini Embeddings**
1. `GeminiEmbedder` (port from reference repo)
2. Model configuration
3. Multimodal tests

**Phase 5: Multimodal Ingestors & File Ingestion**
1. `ImageIngestor`, `VideoIngestor`, `AudioIngestor`
2. Simple mode (text extraction)
3. Advanced mode (raw embeddings)
4. Programmatic file ingestion API (`rag.insert(Path(...), content_type=...)`)
5. End-to-end multimodal tests

**Phase 6: HTTP Upload API Extension** (Optional)
1. Extend DocumentManager supported_extensions for multimodal files
2. File type routing in `/documents/upload` endpoint
3. Backward compatibility tests

**Phase 7: File Watcher** (Optional — Deferred to Future Release)
1. Port `watcher.py` from reference repo
2. `ENABLE_FILE_WATCHER` configuration flag
3. SSE broadcast integration
4. Startup sync + live watching

**Phase 8: Hybrid Query Mode**
1. Result merging logic
2. De-duplication
3. Re-ranking by similarity
4. Performance optimization

**Phase 9: Documentation & Examples**
1. README updates (all file ingestion methods documented)
2. Usage examples (programmatic, HTTP, data folder)
3. Troubleshooting guide

---

## Dependencies

**New dependencies to add to `pyproject.toml`:**

```toml
dependencies = [
    "lightrag-hku>=0.1.0",           # Existing
    "fastapi>=0.115.0",              # Existing
    "uvicorn>=0.32.0",               # Existing
    "openai>=1.0.0",                 # Existing
    "supabase>=2.0.0",               # NEW - Supabase client
    "pinecone-client>=5.0.0",        # NEW - Pinecone client
    "httpx>=0.27.0",                 # NEW - For Gemini API
    "opencv-python-headless>=4.0.0", # NEW - Video keyframe extraction
    "pytesseract>=0.3.10",           # NEW - OCR for images (simple mode)
    "python-dotenv>=1.0.0",          # Existing
]
```

---

## Success Criteria

**Must Have:**
1. ✅ LightRAG core untouched, fully functional without any adapters
2. ✅ OpenAI and Gemini embeddings both supported
3. ✅ Supabase and Pinecone adapters work independently and together
4. ✅ Configuration validation prevents invalid setups
5. ✅ Remote sync failures never block local operations
6. ✅ Setup script validates or creates required schemas
7. ✅ Comprehensive error messages guide users to fix issues

**Should Have:**
1. ✅ Simple and advanced multimodal modes
2. ✅ Hybrid query mode with result merging
3. ✅ Auto-detected embedding dimensions
4. ✅ Clear usage examples in README

**Nice to Have:**
1. Batch sync operation (sync multiple embeddings at once)
2. Retry logic for transient remote failures
3. Sync status dashboard
4. Performance benchmarks (latency vs vanilla LightRAG)

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Dimension mismatch between providers/backends | High - breaks similarity search | Config validation + setup script dimension checks |
| Remote backend downtime blocks inserts | High - system unusable | Fail-safe adapter pattern - local always succeeds |
| Multimodal content submitted to OpenAI | Medium - runtime crash | Validation in `insert()` before processing |
| Supabase schema changes break adapter | Medium - sync failures | Version schema, add migration docs |
| Performance degradation (sync overhead) | Low - slower inserts | Async sync, measured benchmarks |

---

## Conclusion

This design integrates Gemini multimodal embeddings and multi-backend vector storage into LightRAG using a clean adapter layer pattern. The system remains fully functional as vanilla LightRAG when all adapters are disabled, while offering powerful multimodal and multi-backend capabilities when enabled.

**Next Steps:**
1. Review and approve this design document
2. Create implementation plan via `writing-plans` skill
3. Execute implementation in phases
4. Test against success criteria
5. Update CLAUDE.md and README.md with new capabilities

---

**Design Status:** ✅ Ready for Implementation
