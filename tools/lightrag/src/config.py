"""Configuration management for LightRAG Plus"""

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
        self.SUPABASE_MANAGEMENT_TOKEN = os.getenv("SUPABASE_MANAGEMENT_TOKEN", "")

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
