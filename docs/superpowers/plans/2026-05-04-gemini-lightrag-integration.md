# LightRAG Enhanced: Gemini Embeddings & Multi-Backend Integration

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate Gemini multimodal embeddings and multi-backend vector storage (Supabase/Pinecone) into LightRAG without modifying the core library.

**Architecture:** Adapter layer pattern that wraps LightRAG's embedding function to intercept and mirror embeddings to remote backends. LightRAG core remains unchanged and always functional locally.

**Tech Stack:** LightRAG (graph RAG), OpenAI/Gemini embeddings, Supabase (pgvector), Pinecone (serverless), FastAPI

---

## File Structure

**New files to create:**

```text
tools/lightrag/src/
├── config.py                      # Environment config + validation
├── lightrag_enhanced.py           # Main wrapper class
├── embedders/
│   ├── __init__.py
│   ├── base.py                    # Abstract embedder interface
│   ├── openai_embedder.py         # OpenAI text embeddings
│   └── gemini_embedder.py         # Gemini multimodal embeddings
├── adapters/
│   ├── __init__.py
│   ├── base.py                    # Abstract adapter interface
│   ├── supabase_adapter.py        # Supabase pgvector sync
│   └── pinecone_adapter.py        # Pinecone serverless sync
└── ingestors/
    ├── __init__.py
    ├── base.py                    # Abstract ingestor interface
    ├── text_ingestor.py           # Pass-through (already text)
    ├── image_ingestor.py          # OCR extraction + raw embedding
    ├── video_ingestor.py          # Transcription + keyframe embedding
    └── audio_ingestor.py          # Transcription + raw embedding

tools/lightrag/schema/
└── supabase_schema.sql            # Supabase vector table schema

tools/lightrag/tests/
├── test_config.py
├── test_embedders.py
├── test_adapters.py
├── test_ingestors.py
└── test_integration.py

tools/lightrag/
├── setup_backends.py              # Backend validation script
├── .env.example                   # Configuration template (updated)
└── README.md                      # Usage guide (updated)
```

**Existing files to modify:**

- `tools/lightrag/.env` — add new configuration variables
- `tools/lightrag/pyproject.toml` — add dependencies
- `tools/lightrag/README.md` — add file ingestion workflow section (already updated)
- `CLAUDE.md` — document new capabilities (final step)

---

## Phase 1: Core Infrastructure

### Task 1.1: Create Config Class

**Files:**

- Create: `tools/lightrag/src/__init__.py`
- Create: `tools/lightrag/src/config.py`
- Create: `tools/lightrag/tests/test_config.py`

- [ ] **Step 1: Write failing test for config loading**

```python
# tools/lightrag/tests/test_config.py
import pytest
import os
from src.config import Config, ConfigError


def test_default_config_loads():
    """Test config loads with defaults when no env vars set"""
    # Clear all env vars
    for key in list(os.environ.keys()):
        if key.startswith(("EMBEDDING_", "LIGHTRAG_", "ENABLE_", "SUPABASE_", "PINECONE_", "GEMINI_", "OPENAI_", "MULTIMODAL_")):
            del os.environ[key]
    
    config = Config()
    
    assert config.EMBEDDING_PROVIDER == "openai"
    assert config.OPENAI_EMBEDDING_MODEL == "text-embedding-3-small"
    assert config.EMBEDDING_DIM == 1536
    assert config.ENABLE_SUPABASE == False
    assert config.ENABLE_PINECONE == False
    assert config.MULTIMODAL_MODE == "simple"


def test_config_rejects_invalid_provider():
    """Test config raises error for invalid embedding provider"""
    os.environ["EMBEDDING_PROVIDER"] = "invalid"
    
    with pytest.raises(ConfigError, match="must be 'openai' or 'gemini'"):
        Config()


def test_config_rejects_advanced_mode_with_openai():
    """Test config raises error for advanced multimodal with OpenAI"""
    os.environ["EMBEDDING_PROVIDER"] = "openai"
    os.environ["MULTIMODAL_MODE"] = "advanced"
    
    with pytest.raises(ConfigError, match="requires.*gemini"):
        Config()


def test_config_requires_supabase_url_when_enabled():
    """Test config requires Supabase URL when enabled"""
    os.environ["ENABLE_SUPABASE"] = "true"
    os.environ.pop("SUPABASE_URL", None)
    
    with pytest.raises(EnvironmentError, match="SUPABASE_URL required"):
        Config()
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd tools/lightrag && uv run pytest tests/test_config.py -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.config'"

- [ ] **Step 3: Create config implementation**

```python
# tools/lightrag/src/__init__.py
"""LightRAG Enhanced - Gemini multimodal embeddings and multi-backend storage"""

__version__ = "0.1.0"
```

```python
# tools/lightrag/src/config.py
"""Configuration management for LightRAG Enhanced"""

import os
from pathlib import Path
from typing import Optional
from dotenv import load_dotenv


class ConfigError(Exception):
    """Raised when configuration is invalid"""
    pass


class Config:
    """
    Load and validate configuration from environment variables.
    
    Supports both new variable names (preferred) and legacy LightRAG names
    for backward compatibility.
    """
    
    # Model dimension mapping
    MODEL_DIMENSIONS = {
        "text-embedding-3-small": 1536,
        "text-embedding-3-large": 3072,
        "gemini-embedding-2-preview": 3072,
        "gemini-embedding-2": 768,
    }
    
    def __init__(self, env_file: Optional[Path] = None):
        """
        Initialize configuration from environment variables.
        
        Args:
            env_file: Path to .env file (defaults to current directory)
        """
        # Load .env file
        if env_file is None:
            env_file = Path.cwd() / ".env"
        
        if env_file.exists():
            load_dotenv(env_file)
        
        # Embedding Provider (with backward compatibility)
        self.EMBEDDING_PROVIDER = os.getenv("EMBEDDING_PROVIDER") or os.getenv("EMBEDDING_BINDING", "openai")
        
        if self.EMBEDDING_PROVIDER not in ["openai", "gemini"]:
            raise ConfigError(
                f"EMBEDDING_PROVIDER must be 'openai' or 'gemini', got '{self.EMBEDDING_PROVIDER}'"
            )
        
        # OpenAI Configuration
        self.OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
        self.OPENAI_EMBEDDING_MODEL = os.getenv("OPENAI_EMBEDDING_MODEL") or os.getenv("EMBEDDING_MODEL", "text-embedding-3-small")
        
        # Gemini Configuration
        self.GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
        self.GEMINI_EMBEDDING_MODEL = os.getenv("GEMINI_EMBEDDING_MODEL", "gemini-embedding-2-preview")
        
        # Embedding Dimension (auto-detect or override)
        self.EMBEDDING_DIM = self._get_embedding_dimension()
        
        # Vector Backends
        self.ENABLE_SUPABASE = os.getenv("ENABLE_SUPABASE", "false").lower() == "true"
        self.ENABLE_PINECONE = os.getenv("ENABLE_PINECONE", "false").lower() == "true"
        
        # Supabase
        self.SUPABASE_URL = os.getenv("SUPABASE_URL", "")
        self.SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
        
        # Pinecone
        self.PINECONE_API_KEY = os.getenv("PINECONE_API_KEY", "")
        self.PINECONE_INDEX = os.getenv("PINECONE_INDEX", "lightrag-vectors")
        self.PINECONE_ENVIRONMENT = os.getenv("PINECONE_ENVIRONMENT", "us-east-1-aws")
        
        # Multimodal Processing
        self.MULTIMODAL_MODE = os.getenv("MULTIMODAL_MODE", "simple")
        
        if self.MULTIMODAL_MODE not in ["simple", "advanced"]:
            raise ConfigError(
                f"MULTIMODAL_MODE must be 'simple' or 'advanced', got '{self.MULTIMODAL_MODE}'"
            )
        
        # LightRAG Core Settings (with backward compatibility)
        self.LIGHTRAG_WORKING_DIR = os.getenv("LIGHTRAG_WORKING_DIR", "./rag_storage")
        self.LIGHTRAG_LLM_PROVIDER = os.getenv("LIGHTRAG_LLM_PROVIDER") or os.getenv("LLM_BINDING", "openai")
        self.LIGHTRAG_LLM_MODEL = os.getenv("LIGHTRAG_LLM_MODEL") or os.getenv("LLM_MODEL", "gpt-4o-mini")
        
        # Validate configuration
        self._validate()
    
    def _get_embedding_dimension(self) -> int:
        """Auto-detect embedding dimension from model or use explicit override"""
        explicit_dim = os.getenv("EMBEDDING_DIM")
        if explicit_dim:
            return int(explicit_dim)
        
        # Auto-detect from model
        if self.EMBEDDING_PROVIDER == "openai":
            model = self.OPENAI_EMBEDDING_MODEL
        else:
            model = self.GEMINI_EMBEDDING_MODEL
        
        if model not in self.MODEL_DIMENSIONS:
            raise ConfigError(
                f"Unknown model '{model}'. Supported models: {list(self.MODEL_DIMENSIONS.keys())}. "
                "Set EMBEDDING_DIM explicitly to override."
            )
        
        return self.MODEL_DIMENSIONS[model]
    
    def _validate(self):
        """Validate configuration combinations"""
        # Check required API keys
        if self.EMBEDDING_PROVIDER == "openai" and not self.OPENAI_API_KEY:
            raise EnvironmentError(
                "OPENAI_API_KEY is required when EMBEDDING_PROVIDER=openai"
            )
        
        if self.EMBEDDING_PROVIDER == "gemini" and not self.GEMINI_API_KEY:
            raise EnvironmentError(
                "GEMINI_API_KEY is required when EMBEDDING_PROVIDER=gemini"
            )
        
        # Check multimodal mode compatibility
        if self.MULTIMODAL_MODE == "advanced" and self.EMBEDDING_PROVIDER == "openai":
            raise ConfigError(
                "MULTIMODAL_MODE=advanced requires EMBEDDING_PROVIDER=gemini. "
                "OpenAI embeddings only support text. Options: "
                "1) Switch to EMBEDDING_PROVIDER=gemini, or "
                "2) Keep EMBEDDING_PROVIDER=openai and set MULTIMODAL_MODE=simple"
            )
        
        # Check backend requirements
        if self.ENABLE_SUPABASE:
            if not self.SUPABASE_URL:
                raise EnvironmentError("SUPABASE_URL required when ENABLE_SUPABASE=true")
            if not self.SUPABASE_KEY:
                raise EnvironmentError("SUPABASE_KEY required when ENABLE_SUPABASE=true")
        
        if self.ENABLE_PINECONE:
            if not self.PINECONE_API_KEY:
                raise EnvironmentError("PINECONE_API_KEY required when ENABLE_PINECONE=true")
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_config.py -v`  
Expected: 4 tests PASS

- [ ] **Step 5: Add backward compatibility tests**

```python
# Add to tools/lightrag/tests/test_config.py

def test_backward_compatibility_embedding_binding():
    """Test config supports legacy EMBEDDING_BINDING variable"""
    os.environ.clear()
    os.environ["EMBEDDING_BINDING"] = "gemini"  # Legacy name
    os.environ["GEMINI_API_KEY"] = "test-key"
    
    config = Config()
    
    assert config.EMBEDDING_PROVIDER == "gemini"


def test_backward_compatibility_embedding_model():
    """Test config supports legacy EMBEDDING_MODEL variable"""
    os.environ.clear()
    os.environ["EMBEDDING_MODEL"] = "text-embedding-3-large"  # Legacy name
    os.environ["OPENAI_API_KEY"] = "test-key"
    
    config = Config()
    
    assert config.OPENAI_EMBEDDING_MODEL == "text-embedding-3-large"
    assert config.EMBEDDING_DIM == 3072


def test_new_variables_take_precedence():
    """Test new variables override legacy ones"""
    os.environ.clear()
    os.environ["EMBEDDING_PROVIDER"] = "gemini"  # New
    os.environ["EMBEDDING_BINDING"] = "openai"   # Legacy
    os.environ["GEMINI_API_KEY"] = "test-key"
    
    config = Config()
    
    assert config.EMBEDDING_PROVIDER == "gemini"  # New takes precedence
```

- [ ] **Step 6: Run backward compatibility tests**

Run: `cd tools/lightrag && uv run pytest tests/test_config.py::test_backward_compatibility_embedding_binding -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_config.py::test_backward_compatibility_embedding_model -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_config.py::test_new_variables_take_precedence -v`  
Expected: All 3 tests PASS

- [ ] **Step 7: Commit config module**

```bash
git add tools/lightrag/src/__init__.py tools/lightrag/src/config.py tools/lightrag/tests/test_config.py
git commit -m "feat(lightrag): add Config class with backward compatibility

- Load and validate environment configuration
- Support both new and legacy variable names
- Auto-detect embedding dimensions from models
- Validate provider/mode combinations
- 7 passing tests"
```

---

### Task 1.2: Create Abstract Embedding Provider

**Files:**

- Create: `tools/lightrag/src/embedders/__init__.py`
- Create: `tools/lightrag/src/embedders/base.py`
- Modify: `tools/lightrag/tests/test_embedders.py` (create)

- [ ] **Step 1: Write failing test for embedding provider interface**

```python
# tools/lightrag/tests/test_embedders.py
import pytest
from abc import ABC
from pathlib import Path
from src.embedders.base import EmbeddingProvider


def test_embedding_provider_is_abstract():
    """Test EmbeddingProvider cannot be instantiated directly"""
    with pytest.raises(TypeError, match="Can't instantiate abstract class"):
        EmbeddingProvider()


def test_embedding_provider_has_required_methods():
    """Test EmbeddingProvider defines all required abstract methods"""
    required_methods = [
        "embed_text",
        "embed_image",
        "embed_video",
        "embed_audio",
        "embedding_dim",
    ]
    
    for method in required_methods:
        assert hasattr(EmbeddingProvider, method)
        assert getattr(EmbeddingProvider, method).__isabstractmethod__
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_embedding_provider_is_abstract -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.embedders.base'"

- [ ] **Step 3: Create abstract embedding provider**

```python
# tools/lightrag/src/embedders/__init__.py
"""Embedding providers for OpenAI and Gemini"""

from .base import EmbeddingProvider

__all__ = ["EmbeddingProvider"]
```

```python
# tools/lightrag/src/embedders/base.py
"""Abstract base class for embedding providers"""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import List


class EmbeddingProvider(ABC):
    """
    Abstract interface for embedding providers.
    
    Implementations must support text embeddings at minimum.
    Multimodal methods (image/video/audio) can raise NotImplementedError
    for text-only providers.
    """
    
    @abstractmethod
    async def embed_text(self, text: str, task_type: str = "RETRIEVAL_DOCUMENT") -> List[float]:
        """
        Generate text embedding.
        
        Args:
            text: Text content to embed
            task_type: "RETRIEVAL_DOCUMENT" for indexing, "RETRIEVAL_QUERY" for search
        
        Returns:
            List of floats representing the embedding vector
        """
        pass
    
    @abstractmethod
    async def embed_image(self, image_path: Path) -> List[float]:
        """
        Generate image embedding.
        
        Args:
            image_path: Path to image file
        
        Returns:
            List of floats representing the embedding vector
        
        Raises:
            NotImplementedError: If provider doesn't support images
        """
        pass
    
    @abstractmethod
    async def embed_video(self, video_path: Path, strategy: str = "keyframes") -> List[float]:
        """
        Generate video embedding.
        
        Args:
            video_path: Path to video file
            strategy: "whole" (single embedding) or "keyframes" (multiple embeddings)
        
        Returns:
            List of floats representing the embedding vector (or averaged embedding for keyframes)
        
        Raises:
            NotImplementedError: If provider doesn't support video
        """
        pass
    
    @abstractmethod
    async def embed_audio(self, audio_path: Path) -> List[float]:
        """
        Generate audio embedding.
        
        Args:
            audio_path: Path to audio file
        
        Returns:
            List of floats representing the embedding vector
        
        Raises:
            NotImplementedError: If provider doesn't support audio
        """
        pass
    
    @property
    @abstractmethod
    def embedding_dim(self) -> int:
        """
        Get the dimensionality of embeddings produced by this provider.
        
        Returns:
            Integer dimension (e.g., 1536, 3072, 768)
        """
        pass
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py -v`  
Expected: 2 tests PASS

- [ ] **Step 5: Commit abstract embedding provider**

```bash
git add tools/lightrag/src/embedders/ tools/lightrag/tests/test_embedders.py
git commit -m "feat(lightrag): add abstract EmbeddingProvider interface

- Define abstract methods for text/image/video/audio embedding
- Include task_type parameter for retrieval optimization
- 2 passing tests for interface validation"
```

---

### Task 1.3: Implement OpenAI Embedder

**Files:**

- Create: `tools/lightrag/src/embedders/openai_embedder.py`
- Modify: `tools/lightrag/tests/test_embedders.py`

- [ ] **Step 1: Write failing test for OpenAI embedder**

```python
# Add to tools/lightrag/tests/test_embedders.py

import asyncio
from unittest.mock import AsyncMock, patch, MagicMock
from src.embedders.openai_embedder import OpenAIEmbedder
from src.config import Config


@pytest.fixture
def mock_config():
    """Create mock config for testing"""
    config = MagicMock(spec=Config)
    config.OPENAI_API_KEY = "test-key"
    config.OPENAI_EMBEDDING_MODEL = "text-embedding-3-small"
    config.EMBEDDING_DIM = 1536
    return config


@pytest.mark.asyncio
async def test_openai_embedder_text_embedding(mock_config):
    """Test OpenAI embedder generates text embeddings"""
    embedder = OpenAIEmbedder(mock_config)
    
    # Mock OpenAI API response
    mock_response = MagicMock()
    mock_response.data = [MagicMock(embedding=[0.1] * 1536)]
    
    with patch("openai.AsyncOpenAI") as mock_client:
        mock_client.return_value.embeddings.create = AsyncMock(return_value=mock_response)
        
        result = await embedder.embed_text("test text")
        
        assert isinstance(result, list)
        assert len(result) == 1536
        assert all(isinstance(x, float) for x in result)


@pytest.mark.asyncio
async def test_openai_embedder_dimension_property(mock_config):
    """Test OpenAI embedder returns correct dimension"""
    embedder = OpenAIEmbedder(mock_config)
    
    assert embedder.embedding_dim == 1536


@pytest.mark.asyncio
async def test_openai_embedder_rejects_multimodal():
    """Test OpenAI embedder raises error for multimodal content"""
    config = MagicMock(spec=Config)
    config.OPENAI_API_KEY = "test-key"
    config.EMBEDDING_DIM = 1536
    
    embedder = OpenAIEmbedder(config)
    
    with pytest.raises(NotImplementedError, match="OpenAI.*not support.*images"):
        await embedder.embed_image(Path("test.png"))
    
    with pytest.raises(NotImplementedError, match="OpenAI.*not support.*video"):
        await embedder.embed_video(Path("test.mp4"))
    
    with pytest.raises(NotImplementedError, match="OpenAI.*not support.*audio"):
        await embedder.embed_audio(Path("test.mp3"))
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_openai_embedder_text_embedding -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.embedders.openai_embedder'"

- [ ] **Step 3: Implement OpenAI embedder**

```python
# tools/lightrag/src/embedders/openai_embedder.py
"""OpenAI text-only embedding provider"""

import logging
from pathlib import Path
from typing import List
from openai import AsyncOpenAI

from .base import EmbeddingProvider
from ..config import Config

logger = logging.getLogger(__name__)


class OpenAIEmbedder(EmbeddingProvider):
    """
    OpenAI text-only embedding provider.
    
    Supports text embeddings via text-embedding-3-small or text-embedding-3-large.
    Multimodal methods raise NotImplementedError.
    """
    
    def __init__(self, config: Config):
        """
        Initialize OpenAI embedder.
        
        Args:
            config: Configuration object with OPENAI_API_KEY and model settings
        """
        self.config = config
        self.client = AsyncOpenAI(api_key=config.OPENAI_API_KEY)
        self.model = config.OPENAI_EMBEDDING_MODEL
        self._embedding_dim = config.EMBEDDING_DIM
        
        logger.info(f"Initialized OpenAI embedder (model={self.model}, dim={self._embedding_dim})")
    
    async def embed_text(self, text: str, task_type: str = "RETRIEVAL_DOCUMENT") -> List[float]:
        """
        Generate text embedding using OpenAI API.
        
        Args:
            text: Text content to embed
            task_type: Ignored for OpenAI (kept for interface compatibility)
        
        Returns:
            List of floats representing the embedding vector
        """
        try:
            response = await self.client.embeddings.create(
                model=self.model,
                input=text,
                encoding_format="float"
            )
            
            embedding = response.data[0].embedding
            
            logger.debug(f"Generated OpenAI embedding (len={len(embedding)})")
            
            return embedding
        
        except Exception as e:
            logger.error(f"OpenAI embedding failed: {e}")
            raise
    
    async def embed_image(self, image_path: Path) -> List[float]:
        """OpenAI does not support image embeddings"""
        raise NotImplementedError(
            "OpenAI embeddings do not support images. "
            "Use EMBEDDING_PROVIDER=gemini for multimodal support."
        )
    
    async def embed_video(self, video_path: Path, strategy: str = "keyframes") -> List[float]:
        """OpenAI does not support video embeddings"""
        raise NotImplementedError(
            "OpenAI embeddings do not support video. "
            "Use EMBEDDING_PROVIDER=gemini for multimodal support."
        )
    
    async def embed_audio(self, audio_path: Path) -> List[float]:
        """OpenAI does not support audio embeddings"""
        raise NotImplementedError(
            "OpenAI embeddings do not support audio. "
            "Use EMBEDDING_PROVIDER=gemini for multimodal support."
        )
    
    @property
    def embedding_dim(self) -> int:
        """Get embedding dimension from config"""
        return self._embedding_dim
```

- [ ] **Step 4: Update embedders __init__.py**

```python
# tools/lightrag/src/embedders/__init__.py
"""Embedding providers for OpenAI and Gemini"""

from .base import EmbeddingProvider
from .openai_embedder import OpenAIEmbedder

__all__ = ["EmbeddingProvider", "OpenAIEmbedder"]
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_openai_embedder_text_embedding -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_openai_embedder_dimension_property -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_openai_embedder_rejects_multimodal -v`  
Expected: All 3 tests PASS

- [ ] **Step 6: Commit OpenAI embedder**

```bash
git add tools/lightrag/src/embedders/openai_embedder.py tools/lightrag/src/embedders/__init__.py tools/lightrag/tests/test_embedders.py
git commit -m "feat(lightrag): add OpenAI text-only embedder

- Implements EmbeddingProvider interface
- Uses AsyncOpenAI client for text embeddings
- Raises NotImplementedError for multimodal content
- 5 passing tests (including interface tests)"
```

---

### Task 1.4: Create LightRAGEnhanced Wrapper (Text-Only, No Adapters)

**Files:**

- Create: `tools/lightrag/src/lightrag_enhanced.py`
- Create: `tools/lightrag/tests/test_integration.py`

- [ ] **Step 1: Write failing test for LightRAGEnhanced**

```python
# tools/lightrag/tests/test_integration.py
import pytest
import asyncio
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch
from src.lightrag_enhanced import LightRAGEnhanced
from src.config import Config


@pytest.fixture
def test_working_dir(tmp_path):
    """Create temporary working directory"""
    working_dir = tmp_path / "test_rag_storage"
    working_dir.mkdir()
    return str(working_dir)


@pytest.mark.asyncio
async def test_lightrag_enhanced_initializes_with_openai(test_working_dir):
    """Test LightRAGEnhanced initializes with OpenAI provider"""
    with patch.dict("os.environ", {
        "EMBEDDING_PROVIDER": "openai",
        "OPENAI_API_KEY": "test-key",
        "ENABLE_SUPABASE": "false",
        "ENABLE_PINECONE": "false",
    }):
        rag = LightRAGEnhanced(working_dir=test_working_dir)
        
        assert rag.config.EMBEDDING_PROVIDER == "openai"
        assert rag.config.ENABLE_SUPABASE == False
        assert rag.config.ENABLE_PINECONE == False
        assert rag.lightrag is not None  # Native LightRAG instance


@pytest.mark.asyncio
async def test_lightrag_enhanced_insert_text(test_working_dir):
    """Test text insertion via LightRAGEnhanced"""
    with patch.dict("os.environ", {
        "EMBEDDING_PROVIDER": "openai",
        "OPENAI_API_KEY": "test-key",
    }):
        rag = LightRAGEnhanced(working_dir=test_working_dir)
        
        # Mock native LightRAG insert
        rag.lightrag.ainsert = AsyncMock()
        
        result = await rag.insert("Test document text")
        
        assert result["local"] == True
        assert "supabase" not in result  # Disabled
        assert "pinecone" not in result  # Disabled
        rag.lightrag.ainsert.assert_called_once()


@pytest.mark.asyncio
async def test_lightrag_enhanced_query(test_working_dir):
    """Test query via LightRAGEnhanced"""
    with patch.dict("os.environ", {
        "EMBEDDING_PROVIDER": "openai",
        "OPENAI_API_KEY": "test-key",
    }):
        rag = LightRAGEnhanced(working_dir=test_working_dir)
        
        # Mock native LightRAG query
        mock_result = "Test answer"
        rag.lightrag.aquery = AsyncMock(return_value=mock_result)
        
        result = await rag.query("What is this?")
        
        assert result["answer"] == "Test answer"
        assert result["mode"] == "graph"
        rag.lightrag.aquery.assert_called_once()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_integration.py::test_lightrag_enhanced_initializes_with_openai -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.lightrag_enhanced'"

- [ ] **Step 3: Implement LightRAGEnhanced wrapper (text-only)**

```python
# tools/lightrag/src/lightrag_enhanced.py
"""LightRAG Enhanced - Wrapper with embedding provider support"""

import logging
import asyncio
from pathlib import Path
from typing import Optional, Dict, Any, List
from lightrag import LightRAG, QueryParam
from lightrag.llm import openai_complete_if_cache, openai_embedding

from .config import Config
from .embedders import OpenAIEmbedder

logger = logging.getLogger(__name__)


class LightRAGEnhanced:
    """
    Enhanced LightRAG wrapper with configurable embedding providers.
    
    Phase 1 Implementation:
    - OpenAI text embeddings only
    - No adapter syncing (local only)
    - Simple text insert/query
    
    Future phases will add:
    - Gemini multimodal embeddings
    - Supabase/Pinecone adapters
    - Multimodal ingestors
    - Hybrid query mode
    """
    
    def __init__(
        self,
        working_dir: Optional[str] = None,
        embedding_provider: Optional[str] = None,
        embedding_model: Optional[str] = None,
        enable_supabase: Optional[bool] = None,
        enable_pinecone: Optional[bool] = None,
        multimodal_mode: Optional[str] = None,
    ):
        """
        Initialize LightRAG Enhanced.
        
        Args:
            working_dir: Directory for LightRAG storage (overrides .env)
            embedding_provider: "openai" or "gemini" (overrides .env)
            embedding_model: Model name (overrides .env defaults)
            enable_supabase: Enable Supabase sync (overrides .env)
            enable_pinecone: Enable Pinecone sync (overrides .env)
            multimodal_mode: "simple" or "advanced" (overrides .env)
        """
        # Load config from .env
        self.config = Config()
        
        # Override with constructor arguments
        if working_dir is not None:
            self.config.LIGHTRAG_WORKING_DIR = working_dir
        
        if embedding_provider is not None:
            self.config.EMBEDDING_PROVIDER = embedding_provider
        
        if embedding_model is not None:
            if self.config.EMBEDDING_PROVIDER == "openai":
                self.config.OPENAI_EMBEDDING_MODEL = embedding_model
            else:
                self.config.GEMINI_EMBEDDING_MODEL = embedding_model
        
        if enable_supabase is not None:
            self.config.ENABLE_SUPABASE = enable_supabase
        
        if enable_pinecone is not None:
            self.config.ENABLE_PINECONE = enable_pinecone
        
        if multimodal_mode is not None:
            self.config.MULTIMODAL_MODE = multimodal_mode
        
        # Re-validate after overrides
        self.config._validate()
        
        # Initialize embedding provider
        if self.config.EMBEDDING_PROVIDER == "openai":
            self.embedder = OpenAIEmbedder(self.config)
        else:
            # Phase 4 will add Gemini
            raise NotImplementedError("Gemini embeddings coming in Phase 4")
        
        # Initialize adapters (Phase 2-3 will implement these)
        self.adapters: List[Any] = []
        
        # Create working directory
        Path(self.config.LIGHTRAG_WORKING_DIR).mkdir(parents=True, exist_ok=True)
        
        # Initialize native LightRAG with wrapped embedding function
        self.lightrag = LightRAG(
            working_dir=self.config.LIGHTRAG_WORKING_DIR,
            llm_model_func=openai_complete_if_cache,  # Use default LLM for now
            embedding_func=self._create_embedding_wrapper()
        )
        
        logger.info(
            f"LightRAG Enhanced initialized "
            f"(provider={self.config.EMBEDDING_PROVIDER}, "
            f"dim={self.config.EMBEDDING_DIM}, "
            f"adapters={len(self.adapters)})"
        )
    
    def _create_embedding_wrapper(self):
        """
        Create embedding function wrapper for LightRAG.
        
        Phase 1: Simple pass-through to embedder (no adapter syncing)
        Future phases: Add background adapter syncing
        
        Returns:
            Async function that LightRAG will call for embeddings
        """
        async def embedding_func(text: str) -> List[float]:
            """
            Embedding function passed to native LightRAG.
            
            Args:
                text: Text to embed
            
            Returns:
                Embedding vector
            """
            # Get embedding from provider
            embedding = await self.embedder.embed_text(text, task_type="RETRIEVAL_DOCUMENT")
            
            # Phase 2-3: Add background adapter syncing here
            # if self.adapters:
            #     asyncio.create_task(self._sync_to_adapters(...))
            
            return embedding
        
        return embedding_func
    
    async def insert(self, content: str, content_type: str = "text") -> Dict[str, bool]:
        """
        Insert content into LightRAG.
        
        Phase 1: Text-only insertion
        Phase 5: Add multimodal support
        
        Args:
            content: Text content to insert
            content_type: Content type ("text" only for Phase 1)
        
        Returns:
            Dict indicating success/failure per backend
        """
        if content_type != "text":
            raise NotImplementedError("Multimodal content coming in Phase 5")
        
        # Insert into native LightRAG
        await self.lightrag.ainsert(content)
        
        result = {"local": True}
        
        # Phase 2-3: Add adapter sync results
        # result.update(adapter_results)
        
        return result
    
    async def query(
        self,
        text: str,
        mode: str = "graph",
        top_k: int = 10,
    ) -> Dict[str, Any]:
        """
        Query the knowledge graph.
        
        Phase 1: Graph-only queries
        Phase 8: Add hybrid mode (search all adapters)
        
        Args:
            text: Query text
            mode: "graph" (default) or "hybrid" (Phase 8)
            top_k: Number of results to return
        
        Returns:
            Dict with answer and metadata
        """
        if mode != "graph":
            raise NotImplementedError("Hybrid mode coming in Phase 8")
        
        # Query native LightRAG
        answer = await self.lightrag.aquery(
            text,
            param=QueryParam(mode="hybrid", top_k=top_k)  # LightRAG's hybrid mode (not our multi-backend hybrid)
        )
        
        return {
            "answer": answer,
            "mode": "graph",
            "sources": [],  # Phase 8 will populate this
        }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_integration.py -v`  
Expected: 3 tests PASS

- [ ] **Step 5: Commit LightRAGEnhanced wrapper**

```bash
git add tools/lightrag/src/lightrag_enhanced.py tools/lightrag/tests/test_integration.py
git commit -m "feat(lightrag): add LightRAGEnhanced wrapper (Phase 1)

- Wraps native LightRAG with configurable embedding provider
- OpenAI text embeddings only (Phase 1)
- Embedding function wrapper pattern (adapter hooks ready)
- Text-only insert/query operations
- 3 passing integration tests

Phases 2-8 will add:
- Supabase/Pinecone adapters
- Gemini multimodal embeddings
- Multimodal ingestors
- Hybrid query mode"
```

---

## Phase 2: Supabase Adapter

### Task 2.1: Create Supabase Schema

**Files:**

- Create: `tools/lightrag/schema/supabase_schema.sql`
- Create: `tools/lightrag/schema/README.md`

- [ ] **Step 1: Create Supabase schema directory**

```bash
mkdir -p tools/lightrag/schema
```

- [ ] **Step 2: Write Supabase SQL schema**

```sql
-- tools/lightrag/schema/supabase_schema.sql
-- LightRAG Enhanced - Supabase Vector Storage Schema
--
-- Run this SQL in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/YOUR_PROJECT/sql/new
--
-- IMPORTANT: Update VECTOR(3072) to match your EMBEDDING_DIM if different

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Content type enum
CREATE TYPE content_type_enum AS ENUM ('text', 'image', 'video', 'audio');

-- Main embeddings table
CREATE TABLE IF NOT EXISTS lightrag_embeddings (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source          TEXT NOT NULL UNIQUE,              -- File path or chunk ID
    content_type    content_type_enum NOT NULL,        -- Type of content
    content_text    TEXT,                              -- Extracted text (null for raw multimodal)
    metadata        JSONB DEFAULT '{}'::jsonb,         -- Additional metadata
    embedding       VECTOR(3072) NOT NULL,             -- MUST match EMBEDDING_DIM in .env
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- HNSW index for fast cosine similarity search
-- Parameters: m=16 (connections per layer), ef_construction=64 (build quality)
CREATE INDEX IF NOT EXISTS lightrag_embeddings_embedding_idx
    ON lightrag_embeddings
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

-- Index on source for fast lookups
CREATE INDEX IF NOT EXISTS lightrag_embeddings_source_idx
    ON lightrag_embeddings (source);

-- Index on content_type for filtering
CREATE INDEX IF NOT EXISTS lightrag_embeddings_content_type_idx
    ON lightrag_embeddings (content_type);

-- Similarity search function
CREATE OR REPLACE FUNCTION match_lightrag_embeddings(
    query_embedding VECTOR(3072),              -- MUST match table vector dimension
    match_threshold FLOAT DEFAULT 0.5,         -- Minimum cosine similarity
    match_count INT DEFAULT 10,                -- Max results to return
    filter_type content_type_enum DEFAULT NULL -- Optional content type filter
)
RETURNS TABLE (
    id UUID,
    source TEXT,
    content_type content_type_enum,
    content_text TEXT,
    metadata JSONB,
    similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        le.id,
        le.source,
        le.content_type,
        le.content_text,
        le.metadata,
        1 - (le.embedding <=> query_embedding) AS similarity
    FROM
        lightrag_embeddings le
    WHERE
        1 - (le.embedding <=> query_embedding) > match_threshold
        AND (filter_type IS NULL OR le.content_type = filter_type)
    ORDER BY
        le.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER update_lightrag_embeddings_updated_at
    BEFORE UPDATE ON lightrag_embeddings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions (adjust role name if needed)
-- GRANT USAGE ON SCHEMA public TO anon, authenticated;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON lightrag_embeddings TO anon, authenticated;

-- Verification query (run after schema creation)
-- SELECT
--     table_name,
--     column_name,
--     data_type,
--     udt_name
-- FROM information_schema.columns
-- WHERE table_name = 'lightrag_embeddings'
-- ORDER BY ordinal_position;
```

- [ ] **Step 3: Create schema README**

```markdown
<!-- tools/lightrag/schema/README.md -->
# Supabase Schema Setup

## Prerequisites

1. Create a Supabase project at https://supabase.com/dashboard
2. Copy your project URL and service role key
3. Add to `.env`:
   ```bash
   ENABLE_SUPABASE=true
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your-service-role-key
   ```

## Installation Steps

### 1. Run the SQL Schema

1. Open [Supabase SQL Editor](https://supabase.com/dashboard/project/YOUR_PROJECT/sql/new)
2. Copy the entire contents of `supabase_schema.sql`
3. Paste into the SQL editor
4. Click "Run" to execute

### 2. Verify Schema

Run this query in the SQL editor to verify the table was created:

```sql
SELECT
    table_name,
    column_name,
    data_type,
    udt_name
FROM information_schema.columns
WHERE table_name = 'lightrag_embeddings'
ORDER BY ordinal_position;
```

Expected output:

- `id` (uuid)
- `source` (text)
- `content_type` (USER-DEFINED: content_type_enum)
- `content_text` (text)
- `metadata` (jsonb)
- `embedding` (USER-DEFINED: vector)
- `created_at` (timestamp with time zone)
- `updated_at` (timestamp with time zone)

### 3. Verify RPC Function

```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_name = 'match_lightrag_embeddings';
```

Expected output: 1 row with `match_lightrag_embeddings`

### 4. Test Similarity Search (After Data Insertion)

```sql
-- Insert test embedding
INSERT INTO lightrag_embeddings (source, content_type, content_text, embedding)
VALUES (
    'test-document',
    'text',
    'This is a test document',
    ARRAY[0.1, 0.2, ...]::VECTOR(3072)  -- Replace ... with actual 3072 floats
);

-- Test similarity search
SELECT * FROM match_lightrag_embeddings(
    query_embedding := ARRAY[0.1, 0.2, ...]::VECTOR(3072),
    match_threshold := 0.5,
    match_count := 10
);
```

## Important Notes

### Vector Dimension

**The vector dimension MUST match your `EMBEDDING_DIM` in `.env`.**

Default dimensions by provider:

- OpenAI `text-embedding-3-small`: 1536
- OpenAI `text-embedding-3-large`: 3072
- Gemini `gemini-embedding-2-preview`: 3072
- Gemini `gemini-embedding-2`: 768

If you change `EMBEDDING_DIM`, you must:

1. Update `VECTOR(3072)` in the SQL schema to match
2. Drop and recreate the table (or create a new table)
3. Re-run the schema SQL

### Changing Dimensions Later

If you need to change embedding dimensions after data exists:

```sql
-- Option 1: Drop and recreate (DELETES ALL DATA)
DROP TABLE lightrag_embeddings CASCADE;
-- Then re-run supabase_schema.sql with new dimension

-- Option 2: Create new table with new dimension
-- Rename old table, create new, migrate data if needed
```

## Troubleshooting

### Error: "type vector does not exist"

Solution: Run `CREATE EXTENSION IF NOT EXISTS vector;`

### Error: "column embedding has wrong type"

Solution: Dimension mismatch. Check `VECTOR(N)` in schema matches `EMBEDDING_DIM` in `.env`.

### Error: "function match_lightrag_embeddings does not exist"

Solution: Re-run the RPC function creation SQL from `supabase_schema.sql`.

- [ ] **Step 4: Commit Supabase schema files**

```bash
git add tools/lightrag/schema/
git commit -m "feat(lightrag): add Supabase pgvector schema

- CREATE TABLE lightrag_embeddings with vector(3072)
- HNSW index for fast cosine similarity search
- match_lightrag_embeddings RPC function
- Content type enum and filtering support
- Setup documentation with verification steps"
```

---

### Task 2.2: Implement Abstract Vector Adapter

**Files:**

- Create: `tools/lightrag/src/adapters/__init__.py`
- Create: `tools/lightrag/src/adapters/base.py`
- Create: `tools/lightrag/tests/test_adapters.py`

- [ ] **Step 1: Write failing test for adapter interface**

```python
# tools/lightrag/tests/test_adapters.py
import pytest
from src.adapters.base import VectorAdapter


def test_vector_adapter_is_abstract():
    """Test VectorAdapter cannot be instantiated directly"""
    with pytest.raises(TypeError, match="Can't instantiate abstract class"):
        VectorAdapter()


def test_vector_adapter_has_required_methods():
    """Test VectorAdapter defines all required abstract methods"""
    required_methods = ["upsert", "similarity_search", "delete"]
    
    for method in required_methods:
        assert hasattr(VectorAdapter, method)
        assert getattr(VectorAdapter, method).__isabstractmethod__
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_vector_adapter_is_abstract -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.adapters.base'"

- [ ] **Step 3: Create abstract vector adapter**

```python
# tools/lightrag/src/adapters/__init__.py
"""Vector storage adapters for remote backends"""

from .base import VectorAdapter

__all__ = ["VectorAdapter"]
```

```python
# tools/lightrag/src/adapters/base.py
"""Abstract base class for vector storage adapters"""

from abc import ABC, abstractmethod
from typing import List, Dict, Any


class VectorAdapter(ABC):
    """
    Abstract interface for vector storage adapters.
    
    Adapters mirror embeddings to remote vector databases.
    All methods must be fail-safe - catch exceptions and log, never throw.
    """
    
    @abstractmethod
    async def upsert(
        self,
        id: str,
        embedding: List[float],
        metadata: Dict[str, Any]
    ) -> bool:
        """
        Insert or update an embedding.
        
        Args:
            id: Unique identifier (file path or chunk ID)
            embedding: Vector embedding
            metadata: Additional data (content_text, content_type, etc.)
        
        Returns:
            True if successful, False if failed (never raises)
        """
        pass
    
    @abstractmethod
    async def similarity_search(
        self,
        query_embedding: List[float],
        top_k: int = 10,
        filter_type: str | None = None
    ) -> List[Dict[str, Any]]:
        """
        Find similar embeddings via cosine similarity.
        
        Args:
            query_embedding: Query vector
            top_k: Maximum results to return
            filter_type: Optional content type filter ('text', 'image', etc.)
        
        Returns:
            List of results with 'id', 'similarity', 'metadata' fields
            Empty list if search fails (never raises)
        """
        pass
    
    @abstractmethod
    async def delete(self, id: str) -> bool:
        """
        Delete an embedding by ID.
        
        Args:
            id: Unique identifier to delete
        
        Returns:
            True if successful, False if failed (never raises)
        """
        pass
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py -v`  
Expected: 2 tests PASS

- [ ] **Step 5: Commit abstract adapter**

```bash
git add tools/lightrag/src/adapters/ tools/lightrag/tests/test_adapters.py
git commit -m "feat(lightrag): add abstract VectorAdapter interface

- Define fail-safe adapter methods (upsert, search, delete)
- All methods return success/failure, never raise
- 2 passing tests for interface validation"
```

---

### Task 2.3: Implement Supabase Adapter

**Files:**

- Create: `tools/lightrag/src/adapters/supabase_adapter.py`
- Modify: `tools/lightrag/tests/test_adapters.py`
- Modify: `tools/lightrag/pyproject.toml` (add supabase dependency)

- [ ] **Step 1: Add supabase dependency**

```toml
# Add to tools/lightrag/pyproject.toml dependencies array
dependencies = [
    "lightrag-hku>=0.1.0",
    "fastapi>=0.115.0",
    "uvicorn>=0.32.0",
    "openai>=1.0.0",
    "supabase>=2.0.0",  # NEW
    "python-dotenv>=1.0.0",
]
```

- [ ] **Step 2: Install new dependency**

Run: `cd tools/lightrag && uv sync`  
Expected: supabase package installed

- [ ] **Step 3: Write failing test for Supabase adapter**

```python
# Add to tools/lightrag/tests/test_adapters.py

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from src.adapters.supabase_adapter import SupabaseAdapter
from src.config import Config


@pytest.fixture
def mock_supabase_config():
    """Create mock config for Supabase testing"""
    config = MagicMock(spec=Config)
    config.SUPABASE_URL = "https://test.supabase.co"
    config.SUPABASE_KEY = "test-key"
    config.EMBEDDING_DIM = 3072
    return config


@pytest.mark.asyncio
async def test_supabase_adapter_upsert_success(mock_supabase_config):
    """Test Supabase adapter successfully upserts embedding"""
    adapter = SupabaseAdapter(mock_supabase_config)
    
    # Mock Supabase client response
    mock_response = MagicMock()
    mock_response.data = [{"id": "test-id"}]
    
    with patch.object(adapter.client.table("lightrag_embeddings"), "upsert", return_value=MagicMock(execute=AsyncMock(return_value=mock_response))):
        result = await adapter.upsert(
            id="test-id",
            embedding=[0.1] * 3072,
            metadata={"content_text": "test", "content_type": "text"}
        )
        
        assert result == True


@pytest.mark.asyncio
async def test_supabase_adapter_upsert_handles_failure(mock_supabase_config):
    """Test Supabase adapter handles upsert failures gracefully"""
    adapter = SupabaseAdapter(mock_supabase_config)
    
    # Mock Supabase client to raise exception
    with patch.object(adapter.client.table("lightrag_embeddings"), "upsert", side_effect=Exception("Network error")):
        result = await adapter.upsert(
            id="test-id",
            embedding=[0.1] * 3072,
            metadata={"content_text": "test", "content_type": "text"}
        )
        
        assert result == False  # Fail-safe: returns False, doesn't raise


@pytest.mark.asyncio
async def test_supabase_adapter_similarity_search(mock_supabase_config):
    """Test Supabase adapter similarity search via RPC"""
    adapter = SupabaseAdapter(mock_supabase_config)
    
    # Mock RPC response
    mock_response = MagicMock()
    mock_response.data = [
        {
            "id": "result-1",
            "source": "doc1.txt",
            "content_text": "test content",
            "similarity": 0.9,
            "metadata": {}
        }
    ]
    
    with patch.object(adapter.client, "rpc", return_value=MagicMock(execute=AsyncMock(return_value=mock_response))):
        results = await adapter.similarity_search(
            query_embedding=[0.1] * 3072,
            top_k=10
        )
        
        assert len(results) == 1
        assert results[0]["id"] == "result-1"
        assert results[0]["similarity"] == 0.9
```

- [ ] **Step 4: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_supabase_adapter_upsert_success -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.adapters.supabase_adapter'"

- [ ] **Step 5: Implement Supabase adapter**

```python
# tools/lightrag/src/adapters/supabase_adapter.py
"""Supabase pgvector storage adapter"""

import logging
from typing import List, Dict, Any
from supabase import create_client, Client

from .base import VectorAdapter
from ..config import Config

logger = logging.getLogger(__name__)


class SupabaseAdapter(VectorAdapter):
    """
    Supabase pgvector adapter for embedding storage and similarity search.
    
    Uses the lightrag_embeddings table created by supabase_schema.sql.
    All methods are fail-safe - catch exceptions and return success/failure.
    """
    
    def __init__(self, config: Config):
        """
        Initialize Supabase adapter.
        
        Args:
            config: Configuration with SUPABASE_URL and SUPABASE_KEY
        """
        self.config = config
        self.client: Client = create_client(
            supabase_url=config.SUPABASE_URL,
            supabase_key=config.SUPABASE_KEY
        )
        self.table_name = "lightrag_embeddings"
        self.rpc_function = "match_lightrag_embeddings"
        
        logger.info(f"Initialized Supabase adapter (url={config.SUPABASE_URL})")
    
    async def upsert(
        self,
        id: str,
        embedding: List[float],
        metadata: Dict[str, Any]
    ) -> bool:
        """
        Insert or update embedding in Supabase.
        
        Uses 'source' field as conflict key for idempotent upserts.
        
        Args:
            id: Unique source identifier
            embedding: Vector embedding
            metadata: Must include 'content_type' and optionally 'content_text'
        
        Returns:
            True if successful, False if failed
        """
        try:
            # Validate dimension
            if len(embedding) != self.config.EMBEDDING_DIM:
                logger.error(
                    f"Dimension mismatch: expected {self.config.EMBEDDING_DIM}, "
                    f"got {len(embedding)}"
                )
                return False
            
            # Build upsert payload
            payload = {
                "source": id,
                "content_type": metadata.get("content_type", "text"),
                "content_text": metadata.get("content_text"),
                "metadata": {
                    k: v for k, v in metadata.items()
                    if k not in ["content_type", "content_text"]
                },
                "embedding": embedding,
            }
            
            # Upsert with conflict resolution on 'source' field
            response = self.client.table(self.table_name).upsert(
                payload,
                on_conflict="source"
            ).execute()
            
            if response.data:
                logger.debug(f"✓ Supabase upsert: {id}")
                return True
            else:
                logger.warning(f"✗ Supabase upsert failed: {id} (no data returned)")
                return False
        
        except Exception as e:
            logger.error(f"✗ Supabase upsert failed: {id} - {e}")
            return False
    
    async def similarity_search(
        self,
        query_embedding: List[float],
        top_k: int = 10,
        filter_type: str | None = None
    ) -> List[Dict[str, Any]]:
        """
        Search for similar embeddings using cosine similarity.
        
        Calls the match_lightrag_embeddings RPC function created by schema.
        
        Args:
            query_embedding: Query vector
            top_k: Maximum results
            filter_type: Optional content type filter ('text', 'image', etc.)
        
        Returns:
            List of result dicts with 'id', 'similarity', 'metadata' fields
            Empty list if search fails
        """
        try:
            # Call RPC function
            response = self.client.rpc(
                self.rpc_function,
                {
                    "query_embedding": query_embedding,
                    "match_threshold": 0.5,  # Minimum similarity
                    "match_count": top_k,
                    "filter_type": filter_type,
                }
            ).execute()
            
            if not response.data:
                logger.debug("Supabase search returned no results")
                return []
            
            # Format results
            results = [
                {
                    "id": row["source"],
                    "similarity": row["similarity"],
                    "metadata": {
                        "content_text": row.get("content_text"),
                        "content_type": row["content_type"],
                        **row.get("metadata", {}),
                    }
                }
                for row in response.data
            ]
            
            logger.debug(f"✓ Supabase search: {len(results)} results")
            return results
        
        except Exception as e:
            logger.error(f"✗ Supabase search failed: {e}")
            return []
    
    async def delete(self, id: str) -> bool:
        """
        Delete embedding by source ID.
        
        Args:
            id: Source identifier to delete
        
        Returns:
            True if successful, False if failed
        """
        try:
            response = self.client.table(self.table_name).delete().eq(
                "source", id
            ).execute()
            
            logger.debug(f"✓ Supabase delete: {id}")
            return True
        
        except Exception as e:
            logger.error(f"✗ Supabase delete failed: {id} - {e}")
            return False
```

- [ ] **Step 6: Update adapters __init__.py**

```python
# tools/lightrag/src/adapters/__init__.py
"""Vector storage adapters for remote backends"""

from .base import VectorAdapter
from .supabase_adapter import SupabaseAdapter

__all__ = ["VectorAdapter", "SupabaseAdapter"]
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_supabase_adapter_upsert_success -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_supabase_adapter_upsert_handles_failure -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_supabase_adapter_similarity_search -v`  
Expected: All 3 tests PASS

- [ ] **Step 8: Commit Supabase adapter**

```bash
git add tools/lightrag/src/adapters/supabase_adapter.py tools/lightrag/src/adapters/__init__.py tools/lightrag/tests/test_adapters.py tools/lightrag/pyproject.toml
git commit -m "feat(lightrag): add Supabase pgvector adapter

- Implements VectorAdapter interface
- Upsert with source conflict resolution (idempotent)
- Similarity search via match_lightrag_embeddings RPC
- Fail-safe error handling (returns False, never raises)
- 5 passing tests (including interface tests)
- Add supabase>=2.0.0 dependency"
```

---

### Task 2.4: Create Backend Setup Script (Supabase Validation)

**Files:**

- Create: `tools/lightrag/setup_backends.py`

- [ ] **Step 1: Write backend validation script**

```python
# tools/lightrag/setup_backends.py
"""Backend setup and validation for LightRAG Enhanced"""

import asyncio
import sys
from pathlib import Path

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from src.config import Config, ConfigError
from src.adapters import SupabaseAdapter


async def validate_supabase(config: Config) -> bool:
    """
    Validate Supabase connection and schema.
    
    Checks:
    1. Can connect to Supabase
    2. lightrag_embeddings table exists
    3. match_lightrag_embeddings RPC function exists
    
    Args:
        config: Configuration object
    
    Returns:
        True if validation passed, False otherwise
    """
    print("\n" + "=" * 60)
    print("Supabase Setup")
    print("=" * 60)
    
    try:
        # Create adapter (tests connection)
        adapter = SupabaseAdapter(config)
        print("✓ Connected to Supabase")
        
        # Check if table exists
        try:
            response = adapter.client.table("lightrag_embeddings").select("id").limit(1).execute()
            print("✓ Table 'lightrag_embeddings' exists")
        except Exception as e:
            print(f"✗ Table 'lightrag_embeddings' NOT FOUND")
            print(f"  Error: {e}")
            print(f"\n  Please run schema/supabase_schema.sql in your Supabase SQL Editor:")
            print(f"  https://supabase.com/dashboard")
            return False
        
        # Check if RPC function exists
        try:
            # Test RPC with dummy embedding (all zeros)
            dummy_embedding = [0.0] * config.EMBEDDING_DIM
            response = adapter.client.rpc(
                "match_lightrag_embeddings",
                {
                    "query_embedding": dummy_embedding,
                    "match_threshold": 0.5,
                    "match_count": 1,
                }
            ).execute()
            print("✓ RPC function 'match_lightrag_embeddings' exists")
        except Exception as e:
            print(f"✗ RPC function 'match_lightrag_embeddings' NOT FOUND")
            print(f"  Error: {e}")
            print(f"\n  Please run schema/supabase_schema.sql in your Supabase SQL Editor")
            return False
        
        print("✓ Supabase setup complete!")
        return True
    
    except Exception as e:
        print(f"✗ Supabase connection failed: {e}")
        print(f"\n  Check your .env file:")
        print(f"  - SUPABASE_URL should be https://your-project.supabase.co")
        print(f"  - SUPABASE_KEY should be your service role key")
        return False


async def main():
    """Main setup routine"""
    print("=" * 60)
    print("LightRAG Enhanced - Backend Setup")
    print("=" * 60)
    
    try:
        # Load configuration
        config = Config()
        
        print(f"\nEmbedding Provider: {config.EMBEDDING_PROVIDER}")
        print(f"Embedding Dimension: {config.EMBEDDING_DIM}")
        print(f"Multimodal Mode: {config.MULTIMODAL_MODE}")
        
        # Track overall success
        all_valid = True
        
        # Validate Supabase if enabled
        if config.ENABLE_SUPABASE:
            supabase_valid = await validate_supabase(config)
            all_valid = all_valid and supabase_valid
        else:
            print("\n(Supabase disabled - skipping)")
        
        # Validate Pinecone if enabled (Phase 3)
        if config.ENABLE_PINECONE:
            print("\n(Pinecone validation coming in Phase 3)")
        
        # Final status
        print("\n" + "=" * 60)
        if all_valid:
            print("✓ All enabled backends are ready!")
        else:
            print("✗ Setup incomplete - please fix errors above")
            sys.exit(1)
        print("=" * 60)
    
    except ConfigError as e:
        print(f"\n✗ Configuration Error: {e}")
        print("\nPlease check your .env file and try again.")
        sys.exit(1)
    
    except Exception as e:
        print(f"\n✗ Unexpected Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
```

- [ ] **Step 2: Test setup script with valid Supabase config**

Run: `cd tools/lightrag && uv run python setup_backends.py`  
Expected:

```text
============================================================
LightRAG Enhanced - Backend Setup
============================================================

Embedding Provider: openai
Embedding Dimension: 1536
Multimodal Mode: simple

============================================================
Supabase Setup
============================================================
✓ Connected to Supabase
✓ Table 'lightrag_embeddings' exists
✓ RPC function 'match_lightrag_embeddings' exists
✓ Supabase setup complete!

============================================================
✓ All enabled backends are ready!
============================================================
```

- [ ] **Step 3: Commit setup script**

```bash
git add tools/lightrag/setup_backends.py
git commit -m "feat(lightrag): add backend setup validation script

- Validates Supabase connection
- Checks for lightrag_embeddings table
- Verifies match_lightrag_embeddings RPC function
- Clear error messages guide users to fix issues
- Phase 3 will add Pinecone auto-creation"
```

---

## Phase 3: Pinecone Adapter

### Task 3.1: Implement Pinecone Adapter

**Files:**

- Create: `tools/lightrag/src/adapters/pinecone_adapter.py`
- Modify: `tools/lightrag/tests/test_adapters.py`
- Modify: `tools/lightrag/pyproject.toml` (add pinecone dependency)

- [ ] **Step 1: Add pinecone dependency**

```toml
# Add to tools/lightrag/pyproject.toml dependencies array
dependencies = [
    "lightrag-hku>=0.1.0",
    "fastapi>=0.115.0",
    "uvicorn>=0.32.0",
    "openai>=1.0.0",
    "supabase>=2.0.0",
    "pinecone-client>=5.0.0",  # NEW
    "python-dotenv>=1.0.0",
]
```

- [ ] **Step 2: Install new dependency**

Run: `cd tools/lightrag && uv sync`  
Expected: pinecone-client package installed

- [ ] **Step 3: Write failing test for Pinecone adapter**

```python
# Add to tools/lightrag/tests/test_adapters.py

from src.adapters.pinecone_adapter import PineconeAdapter


@pytest.fixture
def mock_pinecone_config():
    """Create mock config for Pinecone testing"""
    config = MagicMock(spec=Config)
    config.PINECONE_API_KEY = "test-key"
    config.PINECONE_INDEX = "lightrag-vectors"
    config.PINECONE_ENVIRONMENT = "us-east-1-aws"
    config.EMBEDDING_DIM = 3072
    return config


@pytest.mark.asyncio
async def test_pinecone_adapter_upsert_success(mock_pinecone_config):
    """Test Pinecone adapter successfully upserts embedding"""
    adapter = PineconeAdapter(mock_pinecone_config)
    
    # Mock Pinecone index
    with patch.object(adapter.index, "upsert", return_value=MagicMock(upserted_count=1)):
        result = await adapter.upsert(
            id="test-id",
            embedding=[0.1] * 3072,
            metadata={"content_text": "test", "content_type": "text"}
        )
        
        assert result == True


@pytest.mark.asyncio
async def test_pinecone_adapter_similarity_search(mock_pinecone_config):
    """Test Pinecone adapter similarity search"""
    adapter = PineconeAdapter(mock_pinecone_config)
    
    # Mock query response
    mock_match = MagicMock()
    mock_match.id = "result-1"
    mock_match.score = 0.9
    mock_match.metadata = {"content_text": "test", "content_type": "text"}
    
    mock_response = MagicMock()
    mock_response.matches = [mock_match]
    
    with patch.object(adapter.index, "query", return_value=mock_response):
        results = await adapter.similarity_search(
            query_embedding=[0.1] * 3072,
            top_k=10
        )
        
        assert len(results) == 1
        assert results[0]["id"] == "result-1"
        assert results[0]["similarity"] == 0.9
```

- [ ] **Step 4: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_pinecone_adapter_upsert_success -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.adapters.pinecone_adapter'"

- [ ] **Step 5: Implement Pinecone adapter**

```python
# tools/lightrag/src/adapters/pinecone_adapter.py
"""Pinecone serverless vector storage adapter"""

import logging
from typing import List, Dict, Any
from pinecone import Pinecone, ServerlessSpec

from .base import VectorAdapter
from ..config import Config

logger = logging.getLogger(__name__)


class PineconeAdapter(VectorAdapter):
    """
    Pinecone serverless adapter for embedding storage and similarity search.
    
    Automatically creates index if it doesn't exist.
    All methods are fail-safe - catch exceptions and return success/failure.
    """
    
    def __init__(self, config: Config):
        """
        Initialize Pinecone adapter.
        
        Args:
            config: Configuration with PINECONE_API_KEY, INDEX, and ENVIRONMENT
        """
        self.config = config
        self.pc = Pinecone(api_key=config.PINECONE_API_KEY)
        self.index_name = config.PINECONE_INDEX
        
        # Get or create index
        try:
            if self.index_name not in self.pc.list_indexes().names():
                logger.info(f"Creating Pinecone index '{self.index_name}'...")
                self.pc.create_index(
                    name=self.index_name,
                    dimension=config.EMBEDDING_DIM,
                    metric="cosine",
                    spec=ServerlessSpec(
                        cloud="aws",
                        region=config.PINECONE_ENVIRONMENT
                    )
                )
                logger.info(f"✓ Created Pinecone index '{self.index_name}'")
            
            self.index = self.pc.Index(self.index_name)
            logger.info(f"Initialized Pinecone adapter (index={self.index_name})")
        
        except Exception as e:
            logger.error(f"Failed to initialize Pinecone: {e}")
            raise
    
    async def upsert(
        self,
        id: str,
        embedding: List[float],
        metadata: Dict[str, Any]
    ) -> bool:
        """
        Insert or update embedding in Pinecone.
        
        Args:
            id: Unique identifier
            embedding: Vector embedding
            metadata: Additional data (content_text, content_type, etc.)
        
        Returns:
            True if successful, False if failed
        """
        try:
            # Validate dimension
            if len(embedding) != self.config.EMBEDDING_DIM:
                logger.error(
                    f"Dimension mismatch: expected {self.config.EMBEDDING_DIM}, "
                    f"got {len(embedding)}"
                )
                return False
            
            # Upsert vector
            response = self.index.upsert(
                vectors=[(id, embedding, metadata)],
                namespace=""  # Use default namespace
            )
            
            if response.upserted_count > 0:
                logger.debug(f"✓ Pinecone upsert: {id}")
                return True
            else:
                logger.warning(f"✗ Pinecone upsert failed: {id} (0 upserted)")
                return False
        
        except Exception as e:
            logger.error(f"✗ Pinecone upsert failed: {id} - {e}")
            return False
    
    async def similarity_search(
        self,
        query_embedding: List[float],
        top_k: int = 10,
        filter_type: str | None = None
    ) -> List[Dict[str, Any]]:
        """
        Search for similar embeddings using cosine similarity.
        
        Args:
            query_embedding: Query vector
            top_k: Maximum results
            filter_type: Optional content type filter ('text', 'image', etc.)
        
        Returns:
            List of result dicts with 'id', 'similarity', 'metadata' fields
            Empty list if search fails
        """
        try:
            # Build filter
            query_filter = None
            if filter_type:
                query_filter = {"content_type": {"$eq": filter_type}}
            
            # Query index
            response = self.index.query(
                vector=query_embedding,
                top_k=top_k,
                include_metadata=True,
                filter=query_filter
            )
            
            if not response.matches:
                logger.debug("Pinecone search returned no results")
                return []
            
            # Format results
            results = [
                {
                    "id": match.id,
                    "similarity": match.score,
                    "metadata": match.metadata,
                }
                for match in response.matches
            ]
            
            logger.debug(f"✓ Pinecone search: {len(results)} results")
            return results
        
        except Exception as e:
            logger.error(f"✗ Pinecone search failed: {e}")
            return []
    
    async def delete(self, id: str) -> bool:
        """
        Delete embedding by ID.
        
        Args:
            id: Identifier to delete
        
        Returns:
            True if successful, False if failed
        """
        try:
            self.index.delete(ids=[id])
            logger.debug(f"✓ Pinecone delete: {id}")
            return True
        
        except Exception as e:
            logger.error(f"✗ Pinecone delete failed: {id} - {e}")
            return False
```

- [ ] **Step 6: Update adapters __init__.py**

```python
# tools/lightrag/src/adapters/__init__.py
"""Vector storage adapters for remote backends"""

from .base import VectorAdapter
from .supabase_adapter import SupabaseAdapter
from .pinecone_adapter import PineconeAdapter

__all__ = ["VectorAdapter", "SupabaseAdapter", "PineconeAdapter"]
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_pinecone_adapter_upsert_success -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_adapters.py::test_pinecone_adapter_similarity_search -v`  
Expected: Both tests PASS

- [ ] **Step 8: Commit Pinecone adapter**

```bash
git add tools/lightrag/src/adapters/pinecone_adapter.py tools/lightrag/src/adapters/__init__.py tools/lightrag/tests/test_adapters.py tools/lightrag/pyproject.toml
git commit -m "feat(lightrag): add Pinecone serverless adapter

- Implements VectorAdapter interface
- Auto-creates index if missing (serverless AWS)
- Cosine similarity search with metadata filtering
- Fail-safe error handling (returns False, never raises)
- 7 passing tests (including interface tests)
- Add pinecone-client>=5.0.0 dependency"
```

---

### Task 3.2: Update Backend Setup Script (Pinecone Auto-Creation)

**Files:**

- Modify: `tools/lightrag/setup_backends.py`

- [ ] **Step 1: Add Pinecone validation to setup script**

```python
# Replace the "Pinecone validation coming in Phase 3" comment in setup_backends.py with:

from src.adapters import PineconeAdapter


async def validate_pinecone(config: Config) -> bool:
    """
    Validate Pinecone connection and create index if needed.
    
    Checks:
    1. Can connect to Pinecone
    2. Index exists or can be created
    3. Dimension matches config
    
    Args:
        config: Configuration object
    
    Returns:
        True if validation passed, False otherwise
    """
    print("\n" + "=" * 60)
    print("Pinecone Setup")
    print("=" * 60)
    
    try:
        # Create adapter (auto-creates index if missing)
        adapter = PineconeAdapter(config)
        print("✓ Connected to Pinecone")
        
        # Verify index stats
        stats = adapter.index.describe_index_stats()
        print(f"✓ Index '{config.PINECONE_INDEX}' ready")
        print(f"  Dimension: {config.EMBEDDING_DIM}")
        print(f"  Metric: cosine")
        print(f"  Cloud: aws ({config.PINECONE_ENVIRONMENT})")
        print(f"  Vector count: {stats.total_vector_count}")
        
        print("✓ Pinecone setup complete!")
        return True
    
    except Exception as e:
        print(f"✗ Pinecone setup failed: {e}")
        print(f"\n  Check your .env file:")
        print(f"  - PINECONE_API_KEY should be valid")
        print(f"  - PINECONE_INDEX is the index name (auto-created if missing)")
        print(f"  - PINECONE_ENVIRONMENT is the cloud region (e.g., us-east-1-aws)")
        return False


# In main(), replace the Pinecone comment with:

        # Validate Pinecone if enabled
        if config.ENABLE_PINECONE:
            pinecone_valid = await validate_pinecone(config)
            all_valid = all_valid and pinecone_valid
        else:
            print("\n(Pinecone disabled - skipping)")
```

- [ ] **Step 2: Test setup script with Pinecone enabled**

Run: `cd tools/lightrag && uv run python setup_backends.py`  
Expected:

```text
============================================================
Pinecone Setup
============================================================
✓ Connected to Pinecone
✓ Index 'lightrag-vectors' ready
  Dimension: 1536
  Metric: cosine
  Cloud: aws (us-east-1-aws)
  Vector count: 0
✓ Pinecone setup complete!
```

- [ ] **Step 3: Commit updated setup script**

```bash
git add tools/lightrag/setup_backends.py
git commit -m "feat(lightrag): add Pinecone validation to setup script

- Auto-creates Pinecone index if missing
- Validates dimension matches config
- Shows index stats (dimension, metric, vector count)
- Both Supabase and Pinecone now fully validated"
```

---

## Phase 4: Gemini Embeddings

### Task 4.1: Implement Gemini Embedder

**Files:**

- Create: `tools/lightrag/src/embedders/gemini_embedder.py`
- Modify: `tools/lightrag/tests/test_embedders.py`
- Modify: `tools/lightrag/pyproject.toml` (add httpx dependency)

- [ ] **Step 1: Add httpx dependency for Gemini API**

```toml
# Add to tools/lightrag/pyproject.toml dependencies array
dependencies = [
    "lightrag-hku>=0.1.0",
    "fastapi>=0.115.0",
    "uvicorn>=0.32.0",
    "openai>=1.0.0",
    "supabase>=2.0.0",
    "pinecone-client>=5.0.0",
    "httpx>=0.27.0",  # NEW - For Gemini REST API
    "python-dotenv>=1.0.0",
]
```

- [ ] **Step 2: Install dependency**

Run: `cd tools/lightrag && uv sync`  
Expected: httpx package installed

- [ ] **Step 3: Write failing test for Gemini embedder**

```python
# Add to tools/lightrag/tests/test_embedders.py

from src.embedders.gemini_embedder import GeminiEmbedder


@pytest.fixture
def mock_gemini_config():
    """Create mock config for Gemini testing"""
    config = MagicMock(spec=Config)
    config.GEMINI_API_KEY = "test-key"
    config.GEMINI_EMBEDDING_MODEL = "gemini-embedding-2-preview"
    config.EMBEDDING_DIM = 3072
    return config


@pytest.mark.asyncio
async def test_gemini_embedder_text_embedding(mock_gemini_config):
    """Test Gemini embedder generates text embeddings"""
    embedder = GeminiEmbedder(mock_gemini_config)
    
    # Mock API response
    mock_response = {
        "embedding": {
            "values": [0.1] * 3072
        }
    }
    
    with patch.object(embedder.client, "post", return_value=AsyncMock(json=AsyncMock(return_value=mock_response))):
        result = await embedder.embed_text("test text", task_type="RETRIEVAL_DOCUMENT")
        
        assert isinstance(result, list)
        assert len(result) == 3072
        assert all(isinstance(x, float) for x in result)


@pytest.mark.asyncio
async def test_gemini_embedder_image_embedding(mock_gemini_config, tmp_path):
    """Test Gemini embedder generates image embeddings"""
    embedder = GeminiEmbedder(mock_gemini_config)
    
    # Create test image file
    test_image = tmp_path / "test.png"
    test_image.write_bytes(b"fake image data")
    
    # Mock API response
    mock_response = {
        "embedding": {
            "values": [0.2] * 3072
        }
    }
    
    with patch.object(embedder.client, "post", return_value=AsyncMock(json=AsyncMock(return_value=mock_response))):
        result = await embedder.embed_image(test_image)
        
        assert isinstance(result, list)
        assert len(result) == 3072
```

- [ ] **Step 4: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_gemini_embedder_text_embedding -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.embedders.gemini_embedder'"

- [ ] **Step 5: Implement Gemini embedder**

```python
# tools/lightrag/src/embedders/gemini_embedder.py
"""Google Gemini multimodal embedding provider"""

import logging
import base64
from pathlib import Path
from typing import List
import httpx

from .base import EmbeddingProvider
from ..config import Config

logger = logging.getLogger(__name__)


class GeminiEmbedder(EmbeddingProvider):
    """
    Google Gemini multimodal embedding provider.
    
    Supports text, image, video, and audio embeddings via REST API.
    Uses gemini-embedding-2-preview or gemini-embedding-2 models.
    """
    
    API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"
    
    def __init__(self, config: Config):
        """
        Initialize Gemini embedder.
        
        Args:
            config: Configuration with GEMINI_API_KEY and model settings
        """
        self.config = config
        self.client = httpx.AsyncClient()
        self.model = config.GEMINI_EMBEDDING_MODEL
        self._embedding_dim = config.EMBEDDING_DIM
        self.api_key = config.GEMINI_API_KEY
        
        logger.info(f"Initialized Gemini embedder (model={self.model}, dim={self._embedding_dim})")
    
    async def embed_text(self, text: str, task_type: str = "RETRIEVAL_DOCUMENT") -> List[float]:
        """
        Generate text embedding using Gemini API.
        
        Args:
            text: Text content to embed
            task_type: "RETRIEVAL_DOCUMENT" for indexing, "RETRIEVAL_QUERY" for search
        
        Returns:
            List of floats representing the embedding vector
        """
        try:
            url = f"{self.API_BASE}/{self.model}:embedContent?key={self.api_key}"
            
            payload = {
                "model": f"models/{self.model}",
                "content": {
                    "parts": [{"text": text}]
                },
                "taskType": task_type,
            }
            
            response = await self.client.post(url, json=payload)
            response.raise_for_status()
            
            data = response.json()
            embedding = data["embedding"]["values"]
            
            logger.debug(f"Generated Gemini text embedding (len={len(embedding)})")
            
            return embedding
        
        except Exception as e:
            logger.error(f"Gemini text embedding failed: {e}")
            raise
    
    async def embed_image(self, image_path: Path) -> List[float]:
        """
        Generate image embedding using Gemini API.
        
        Args:
            image_path: Path to image file (PNG, JPEG, etc.)
        
        Returns:
            List of floats representing the embedding vector
        """
        try:
            # Read and encode image
            image_bytes = image_path.read_bytes()
            image_b64 = base64.b64encode(image_bytes).decode('utf-8')
            
            # Detect MIME type from extension
            mime_types = {
                ".png": "image/png",
                ".jpg": "image/jpeg",
                ".jpeg": "image/jpeg",
                ".gif": "image/gif",
                ".webp": "image/webp",
            }
            mime_type = mime_types.get(image_path.suffix.lower(), "image/png")
            
            url = f"{self.API_BASE}/{self.model}:embedContent?key={self.api_key}"
            
            payload = {
                "model": f"models/{self.model}",
                "content": {
                    "parts": [{
                        "inlineData": {
                            "mimeType": mime_type,
                            "data": image_b64
                        }
                    }]
                },
            }
            
            response = await self.client.post(url, json=payload)
            response.raise_for_status()
            
            data = response.json()
            embedding = data["embedding"]["values"]
            
            logger.debug(f"Generated Gemini image embedding (len={len(embedding)})")
            
            return embedding
        
        except Exception as e:
            logger.error(f"Gemini image embedding failed: {e}")
            raise
    
    async def embed_video(self, video_path: Path, strategy: str = "keyframes") -> List[float]:
        """
        Generate video embedding using Gemini API.
        
        For Phase 4: Raises NotImplementedError (Phase 5 will implement)
        
        Args:
            video_path: Path to video file
            strategy: "whole" or "keyframes"
        
        Returns:
            List of floats representing the embedding vector
        """
        raise NotImplementedError(
            "Video embeddings coming in Phase 5 (multimodal ingestors)"
        )
    
    async def embed_audio(self, audio_path: Path) -> List[float]:
        """
        Generate audio embedding using Gemini API.
        
        For Phase 4: Raises NotImplementedError (Phase 5 will implement)
        
        Args:
            audio_path: Path to audio file
        
        Returns:
            List of floats representing the embedding vector
        """
        raise NotImplementedError(
            "Audio embeddings coming in Phase 5 (multimodal ingestors)"
        )
    
    @property
    def embedding_dim(self) -> int:
        """Get embedding dimension from config"""
        return self._embedding_dim
    
    async def close(self):
        """Close HTTP client"""
        await self.client.aclose()
```

- [ ] **Step 6: Update embedders __init__.py**

```python
# tools/lightrag/src/embedders/__init__.py
"""Embedding providers for OpenAI and Gemini"""

from .base import EmbeddingProvider
from .openai_embedder import OpenAIEmbedder
from .gemini_embedder import GeminiEmbedder

__all__ = ["EmbeddingProvider", "OpenAIEmbedder", "GeminiEmbedder"]
```

- [ ] **Step 7: Update LightRAGEnhanced to support Gemini**

```python
# In tools/lightrag/src/lightrag_enhanced.py, replace the Gemini NotImplementedError:

        # Initialize embedding provider
        if self.config.EMBEDDING_PROVIDER == "openai":
            self.embedder = OpenAIEmbedder(self.config)
        elif self.config.EMBEDDING_PROVIDER == "gemini":
            from .embedders import GeminiEmbedder
            self.embedder = GeminiEmbedder(self.config)
        else:
            raise ValueError(f"Unknown embedding provider: {self.config.EMBEDDING_PROVIDER}")
```

- [ ] **Step 8: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_gemini_embedder_text_embedding -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_embedders.py::test_gemini_embedder_image_embedding -v`  
Expected: Both tests PASS

- [ ] **Step 9: Commit Gemini embedder**

```bash
git add tools/lightrag/src/embedders/gemini_embedder.py tools/lightrag/src/embedders/__init__.py tools/lightrag/src/lightrag_enhanced.py tools/lightrag/tests/test_embedders.py tools/lightrag/pyproject.toml
git commit -m "feat(lightrag): add Gemini multimodal embedder

- Implements EmbeddingProvider interface
- Text and image embeddings via REST API
- Uses task_type for retrieval optimization
- Base64 image encoding with MIME type detection
- Video/audio embeddings deferred to Phase 5
- Add httpx>=0.27.0 dependency
- Update LightRAGEnhanced to support Gemini provider"
```

---

## Phase 5: Multimodal Ingestors & File Ingestion

### Task 5.1: Create Abstract Content Ingestor

**Files:**

- Create: `tools/lightrag/src/ingestors/__init__.py`
- Create: `tools/lightrag/src/ingestors/base.py`
- Create: `tools/lightrag/tests/test_ingestors.py`

- [ ] **Step 1: Write failing test for ingestor interface**

```python
# tools/lightrag/tests/test_ingestors.py
import pytest
from src.ingestors.base import ContentIngestor


def test_content_ingestor_is_abstract():
    """Test ContentIngestor cannot be instantiated directly"""
    with pytest.raises(TypeError, match="Can't instantiate abstract class"):
        ContentIngestor(None, None, None)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_ingestors.py::test_content_ingestor_is_abstract -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.ingestors.base'"

- [ ] **Step 3: Create abstract ingestor**

```python
# tools/lightrag/src/ingestors/__init__.py
"""Content ingestors for multimodal file processing"""

from .base import ContentIngestor

__all__ = ["ContentIngestor"]
```

```python
# tools/lightrag/src/ingestors/base.py
"""Abstract base class for content ingestors"""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Dict, Any, List


class IngestionResult:
    """Result of content ingestion"""
    
    def __init__(
        self,
        extracted_text: str,
        chunks_ingested: int = 0,
        embeddings_generated: int = 0,
        errors: List[str] | None = None
    ):
        self.extracted_text = extracted_text
        self.chunks_ingested = chunks_ingested
        self.embeddings_generated = embeddings_generated
        self.errors = errors or []


class ContentIngestor(ABC):
    """
    Abstract interface for content ingestors.
    
    Ingestors extract text from multimodal files and optionally
    embed raw content for advanced multimodal search.
    """
    
    def __init__(self, embedder, adapters: List[Any], config):
        """
        Initialize ingestor.
        
        Args:
            embedder: EmbeddingProvider instance
            adapters: List of VectorAdapter instances
            config: Configuration object
        """
        self.embedder = embedder
        self.adapters = adapters
        self.config = config
    
    @abstractmethod
    async def extract_text(self, file_path: Path) -> str:
        """
        Extract text from file.
        
        Args:
            file_path: Path to file
        
        Returns:
            Extracted text content
        """
        pass
    
    @abstractmethod
    async def ingest(self, file_path: Path) -> IngestionResult:
        """
        Ingest file: extract text + optionally embed raw content.
        
        Args:
            file_path: Path to file
        
        Returns:
            IngestionResult with extracted text and metadata
        """
        pass
    
    def should_embed_raw(self) -> bool:
        """
        Check if raw content should be embedded.
        
        Returns:
            True for advanced mode, False for simple mode
        """
        return self.config.MULTIMODAL_MODE == "advanced"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd tools/lightrag && uv run pytest tests/test_ingestors.py -v`  
Expected: 1 test PASS

- [ ] **Step 5: Commit abstract ingestor**

```bash
git add tools/lightrag/src/ingestors/ tools/lightrag/tests/test_ingestors.py
git commit -m "feat(lightrag): add abstract ContentIngestor interface

- Define extract_text and ingest methods
- IngestionResult class for return values
- should_embed_raw() checks advanced vs simple mode
- 1 passing test for interface validation"
```

---

### Task 5.2: Implement Image Ingestor

**Files:**

- Create: `tools/lightrag/src/ingestors/image_ingestor.py`
- Modify: `tools/lightrag/tests/test_ingestors.py`
- Modify: `tools/lightrag/pyproject.toml` (add pytesseract dependency)

- [ ] **Step 1: Add OCR dependency**

```toml
# Add to tools/lightrag/pyproject.toml dependencies array
dependencies = [
    # ... existing dependencies ...
    "pytesseract>=0.3.10",  # NEW - OCR for image text extraction
    "Pillow>=10.0.0",       # NEW - Image processing
]
```

- [ ] **Step 2: Install dependencies**

Run: `cd tools/lightrag && uv sync`  
Expected: pytesseract and Pillow packages installed

- [ ] **Step 3: Write failing test for image ingestor**

```python
# Add to tools/lightrag/tests/test_ingestors.py

from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch
from src.ingestors.image_ingestor import ImageIngestor
from src.config import Config


@pytest.fixture
def mock_ingestor_config():
    """Create mock config for ingestor testing"""
    config = MagicMock(spec=Config)
    config.MULTIMODAL_MODE = "simple"
    config.EMBEDDING_PROVIDER = "gemini"
    config.EMBEDDING_DIM = 3072
    return config


@pytest.mark.asyncio
async def test_image_ingestor_simple_mode(mock_ingestor_config, tmp_path):
    """Test image ingestor in simple mode (text extraction only)"""
    # Create test image
    test_image = tmp_path / "test.png"
    test_image.write_bytes(b"fake image data")
    
    # Mock embedder and adapters
    mock_embedder = MagicMock()
    mock_adapters = []
    
    ingestor = ImageIngestor(mock_embedder, mock_adapters, mock_ingestor_config)
    
    # Mock OCR result
    with patch("pytesseract.image_to_string", return_value="Test OCR text"):
        result = await ingestor.ingest(test_image)
        
        assert result.extracted_text == "Test OCR text"
        assert result.chunks_ingested == 0  # Simple mode: no embeddings
        assert len(result.errors) == 0


@pytest.mark.asyncio
async def test_image_ingestor_advanced_mode(mock_ingestor_config, tmp_path):
    """Test image ingestor in advanced mode (text + raw embedding)"""
    mock_ingestor_config.MULTIMODAL_MODE = "advanced"
    
    # Create test image
    test_image = tmp_path / "test.png"
    test_image.write_bytes(b"fake image data")
    
    # Mock embedder
    mock_embedder = MagicMock()
    mock_embedder.embed_image = AsyncMock(return_value=[0.1] * 3072)
    
    # Mock adapter
    mock_adapter = MagicMock()
    mock_adapter.upsert = AsyncMock(return_value=True)
    mock_adapters = [mock_adapter]
    
    ingestor = ImageIngestor(mock_embedder, mock_adapters, mock_ingestor_config)
    
    # Mock OCR
    with patch("pytesseract.image_to_string", return_value="Test OCR text"):
        result = await ingestor.ingest(test_image)
        
        assert result.extracted_text == "Test OCR text"
        assert result.embeddings_generated == 1  # Advanced mode: raw embedding created
        mock_embedder.embed_image.assert_called_once()
        mock_adapter.upsert.assert_called_once()
```

- [ ] **Step 4: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_ingestors.py::test_image_ingestor_simple_mode -v`  
Expected: FAIL with "ModuleNotFoundError: No module named 'src.ingestors.image_ingestor'"

- [ ] **Step 5: Implement image ingestor**

```python
# tools/lightrag/src/ingestors/image_ingestor.py
"""Image content ingestor with OCR text extraction"""

import logging
from pathlib import Path
from PIL import Image
import pytesseract

from .base import ContentIngestor, IngestionResult

logger = logging.getLogger(__name__)


class ImageIngestor(ContentIngestor):
    """
    Image ingestor with OCR text extraction.
    
    Simple mode: Extract text via OCR
    Advanced mode: Extract text + embed raw image
    """
    
    async def extract_text(self, file_path: Path) -> str:
        """
        Extract text from image using OCR.
        
        Args:
            file_path: Path to image file
        
        Returns:
            Extracted text (empty string if OCR fails)
        """
        try:
            image = Image.open(file_path)
            text = pytesseract.image_to_string(image)
            
            logger.debug(f"OCR extracted {len(text)} chars from {file_path.name}")
            
            return text.strip()
        
        except Exception as e:
            logger.warning(f"OCR failed for {file_path.name}: {e}")
            return ""
    
    async def ingest(self, file_path: Path) -> IngestionResult:
        """
        Ingest image file.
        
        Simple mode: Extract text only
        Advanced mode: Extract text + embed raw image → adapters
        
        Args:
            file_path: Path to image file
        
        Returns:
            IngestionResult with extracted text and stats
        """
        errors = []
        extracted_text = ""
        embeddings_generated = 0
        
        try:
            # Step 1: Extract text via OCR
            extracted_text = await self.extract_text(file_path)
            
            if not extracted_text:
                errors.append("No text extracted from image")
            
            # Step 2: Advanced mode - embed raw image
            if self.should_embed_raw():
                try:
                    # Generate raw image embedding
                    embedding = await self.embedder.embed_image(file_path)
                    
                    # Sync to adapters
                    metadata = {
                        "content_type": "image",
                        "content_text": extracted_text,
                        "source": str(file_path),
                    }
                    
                    for adapter in self.adapters:
                        success = await adapter.upsert(
                            id=str(file_path),
                            embedding=embedding,
                            metadata=metadata
                        )
                        
                        if success:
                            embeddings_generated += 1
                    
                    logger.info(f"✓ Ingested image: {file_path.name} (text + embedding)")
                
                except Exception as e:
                    errors.append(f"Raw embedding failed: {e}")
                    logger.error(f"Failed to embed image {file_path.name}: {e}")
            
            else:
                logger.info(f"✓ Ingested image: {file_path.name} (text only)")
        
        except Exception as e:
            errors.append(f"Ingestion failed: {e}")
            logger.error(f"Failed to ingest image {file_path.name}: {e}")
        
        return IngestionResult(
            extracted_text=extracted_text,
            chunks_ingested=0,
            embeddings_generated=embeddings_generated,
            errors=errors
        )
```

- [ ] **Step 6: Update ingestors __init__.py**

```python
# tools/lightrag/src/ingestors/__init__.py
"""Content ingestors for multimodal file processing"""

from .base import ContentIngestor, IngestionResult
from .image_ingestor import ImageIngestor

__all__ = ["ContentIngestor", "IngestionResult", "ImageIngestor"]
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_ingestors.py::test_image_ingestor_simple_mode -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_ingestors.py::test_image_ingestor_advanced_mode -v`  
Expected: Both tests PASS

- [ ] **Step 8: Commit image ingestor**

```bash
git add tools/lightrag/src/ingestors/image_ingestor.py tools/lightrag/src/ingestors/__init__.py tools/lightrag/tests/test_ingestors.py tools/lightrag/pyproject.toml
git commit -m "feat(lightrag): add image ingestor with OCR

- Extract text via pytesseract OCR
- Simple mode: text extraction only
- Advanced mode: text + raw image embedding to adapters
- Add pytesseract>=0.3.10 and Pillow>=10.0.0 dependencies
- 3 passing tests (including interface test)"
```

---

### Task 5.3: Update LightRAGEnhanced for Multimodal Insert

**Files:**

- Modify: `tools/lightrag/src/lightrag_enhanced.py`
- Modify: `tools/lightrag/tests/test_integration.py`

- [ ] **Step 1: Write failing test for multimodal insert**

```python
# Add to tools/lightrag/tests/test_integration.py

@pytest.mark.asyncio
async def test_lightrag_enhanced_insert_image_simple_mode(test_working_dir, tmp_path):
    """Test image insertion in simple mode (text extraction only)"""
    test_image = tmp_path / "test.png"
    test_image.write_bytes(b"fake image data")
    
    with patch.dict("os.environ", {
        "EMBEDDING_PROVIDER": "gemini",
        "GEMINI_API_KEY": "test-key",
        "MULTIMODAL_MODE": "simple",
    }):
        rag = LightRAGEnhanced(working_dir=test_working_dir)
        
        # Mock OCR and LightRAG insert
        with patch("pytesseract.image_to_string", return_value="Test OCR text"):
            rag.lightrag.ainsert = AsyncMock()
            
            result = await rag.insert(test_image, content_type="image")
            
            assert result["local"] == True
            rag.lightrag.ainsert.assert_called_once_with("Test OCR text")


@pytest.mark.asyncio
async def test_lightrag_enhanced_insert_image_advanced_mode(test_working_dir, tmp_path):
    """Test image insertion in advanced mode (text + raw embedding)"""
    test_image = tmp_path / "test.png"
    test_image.write_bytes(b"fake image data")
    
    with patch.dict("os.environ", {
        "EMBEDDING_PROVIDER": "gemini",
        "GEMINI_API_KEY": "test-key",
        "MULTIMODAL_MODE": "advanced",
        "ENABLE_SUPABASE": "true",
        "SUPABASE_URL": "https://test.supabase.co",
        "SUPABASE_KEY": "test-key",
    }):
        rag = LightRAGEnhanced(working_dir=test_working_dir)
        
        # Mock OCR, embedder, and adapters
        with patch("pytesseract.image_to_string", return_value="Test OCR text"):
            rag.lightrag.ainsert = AsyncMock()
            rag.embedder.embed_image = AsyncMock(return_value=[0.1] * 3072)
            rag.adapters[0].upsert = AsyncMock(return_value=True)
            
            result = await rag.insert(test_image, content_type="image")
            
            assert result["local"] == True
            assert result["supabase"] == True
            rag.lightrag.ainsert.assert_called_once_with("Test OCR text")
            rag.adapters[0].upsert.assert_called_once()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd tools/lightrag && uv run pytest tests/test_integration.py::test_lightrag_enhanced_insert_image_simple_mode -v`  
Expected: FAIL (insert() doesn't support Path or content_type yet)

- [ ] **Step 3: Update LightRAGEnhanced.insert() for multimodal**

```python
# In tools/lightrag/src/lightrag_enhanced.py, replace the insert() method:

    async def insert(self, content, content_type: str = "text") -> Dict[str, bool]:
        """
        Insert content into LightRAG.
        
        Args:
            content: Text string or Path to file
            content_type: "text", "image", "video", or "audio"
        
        Returns:
            Dict indicating success/failure per backend
        """
        from pathlib import Path
        
        result = {}
        extracted_text = ""
        
        # Handle text content
        if content_type == "text":
            if isinstance(content, Path):
                extracted_text = content.read_text()
            else:
                extracted_text = str(content)
        
        # Handle multimodal content
        elif content_type in ["image", "video", "audio"]:
            if not isinstance(content, Path):
                raise ValueError(f"Multimodal content must be a Path, got {type(content)}")
            
            # Get appropriate ingestor
            if content_type == "image":
                from .ingestors import ImageIngestor
                ingestor = ImageIngestor(self.embedder, self.adapters, self.config)
            elif content_type == "video":
                raise NotImplementedError("Video ingestors coming in Phase 5.4")
            elif content_type == "audio":
                raise NotImplementedError("Audio ingestors coming in Phase 5.5")
            
            # Ingest file (extracts text + optionally embeds raw content)
            ingest_result = await ingestor.ingest(content)
            extracted_text = ingest_result.extracted_text
            
            # Track adapter results from ingestor
            if ingest_result.embeddings_generated > 0:
                for adapter in self.adapters:
                    # Adapter results tracked inside ingestor
                    # Here we just mark that adapters were used
                    adapter_name = adapter.__class__.__name__.replace("Adapter", "").lower()
                    result[adapter_name] = True
        
        else:
            raise ValueError(f"Unknown content_type: {content_type}")
        
        # Insert extracted text into native LightRAG
        if extracted_text:
            await self.lightrag.ainsert(extracted_text)
            result["local"] = True
        else:
            result["local"] = False
            result["error"] = "No text extracted"
        
        return result
```

- [ ] **Step 4: Initialize adapters in __init__**

```python
# In tools/lightrag/src/lightrag_enhanced.py __init__, replace the adapters line:

        # Initialize adapters based on config
        self.adapters = []
        
        if self.config.ENABLE_SUPABASE:
            from .adapters import SupabaseAdapter
            self.adapters.append(SupabaseAdapter(self.config))
            logger.info("✓ Supabase adapter enabled")
        
        if self.config.ENABLE_PINECONE:
            from .adapters import PineconeAdapter
            self.adapters.append(PineconeAdapter(self.config))
            logger.info("✓ Pinecone adapter enabled")
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd tools/lightrag && uv run pytest tests/test_integration.py::test_lightrag_enhanced_insert_image_simple_mode -v`  
Run: `cd tools/lightrag && uv run pytest tests/test_integration.py::test_lightrag_enhanced_insert_image_advanced_mode -v`  
Expected: Both tests PASS

- [ ] **Step 6: Commit multimodal insert support**

```bash
git add tools/lightrag/src/lightrag_enhanced.py tools/lightrag/tests/test_integration.py
git commit -m "feat(lightrag): add multimodal file insert support

- Update insert() to accept Path and content_type
- Route multimodal files to appropriate ingestor
- Initialize adapters in __init__ based on config
- Simple mode: text extraction → LightRAG graph
- Advanced mode: text + raw embedding → graph + adapters
- 5 passing integration tests"
```

---

## Phase 6-9 Summary

**Remaining implementation tasks:**

### Phase 6: HTTP Upload API Extension (Optional)

- Extend LightRAG Server's `/documents/upload` endpoint
- Add multimodal file type support to DocumentManager
- Route uploads to appropriate ingestor based on file extension

### Phase 7: File Watcher (Optional - Deferred)

- Port watcher.py from reference repo
- Implement startup_sync and watch_data_folder
- Add SSE broadcast for real-time UI updates

### Phase 8: Hybrid Query Mode

- Implement result merging from multiple backends
- De-duplication by source ID
- Re-ranking by similarity score

### Phase 9: Documentation & Examples

- Update README.md with complete file ingestion guide
- Add usage examples for all 3 ingestion methods
- Create troubleshooting guide
- Update CLAUDE.md with new capabilities

---

## Final Checklist

**Before marking plan complete:**

- [ ] Review all tasks for placeholders (TBD, TODO, etc.)
- [ ] Verify all code blocks are complete and runnable
- [ ] Check test commands are correct
- [ ] Confirm commit messages follow conventional commits
- [ ] Validate all file paths are absolute and correct

**Dependencies Added:**

- supabase>=2.0.0
- pinecone-client>=5.0.0
- httpx>=0.27.0
- pytesseract>=0.3.10
- Pillow>=10.0.0

**Tests Coverage:**

- Config: 7 tests
- Embedders: 5 tests
- Adapters: 7 tests
- Ingestors: 3 tests
- Integration: 5 tests
- **Total: 27 passing tests**

---

## Plan Complete

This implementation plan covers Phases 1-5 in full detail with:

- ✅ Exact file paths and code blocks
- ✅ Bite-sized steps (2-5 minutes each)
- ✅ Test-first approach
- ✅ No placeholders
- ✅ Commit after each task

**Phases 6-9** are summarized as optional/future work, with Phase 1-5 providing the complete core functionality.

**Plan saved to:** `docs/superpowers/plans/2026-05-04-gemini-lightrag-integration.md`
