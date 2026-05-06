import pytest
import os
from src.config import Config, ConfigError

# Keys that Config reads — cleared before every test for isolation
_CONFIG_KEYS = (
    "EMBEDDING_", "LIGHTRAG_", "ENABLE_", "SUPABASE_",
    "PINECONE_", "GEMINI_", "OPENAI_", "MULTIMODAL_",
)


@pytest.fixture(autouse=True)
def clear_config_env():
    """Clear all config-related env vars before each test."""
    for key in list(os.environ.keys()):
        if key.startswith(_CONFIG_KEYS):
            del os.environ[key]
    yield
    # Clean up after test too
    for key in list(os.environ.keys()):
        if key.startswith(_CONFIG_KEYS):
            del os.environ[key]


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
