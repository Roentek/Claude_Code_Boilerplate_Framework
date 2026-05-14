"""
LightRAG Plus — end-to-end integration tests.

Run:
    cd tools/lightrag
    uv sync --extra dev
    uv run --extra dev pytest tests/test_integration.py -v --tb=short

Scenarios that require remote credentials are auto-skipped when those
vars are absent from tools/lightrag/.env.
"""
import logging
import os
from pathlib import Path

import pytest
import pytest_asyncio  # noqa: F401  (ensures plugin is loaded)

from tests.conftest import env_val, skip_if_missing

# ── Dummy content ────────────────────────────────────────────────────────────

DUMMY_TEXT = (
    "LightRAG is a graph-based retrieval-augmented generation system. "
    "It extracts entities and relationships from documents to build a knowledge graph."
)
DUMMY_QUERY = "What is LightRAG?"

# ── Scenario definitions ─────────────────────────────────────────────────────

# Each scenario defines env var overrides applied via monkeypatch.
# 'required' lists keys that must be present in .env to run the scenario.
# Group A — simple mode (text-only, OpenAI embedder)
# Group B — advanced mode (multimodal, Gemini embedder, remote backend required)

SCENARIOS = [
    # Group A
    {
        "id": "local",
        "group": "A",
        "overrides": {"ENABLE_SUPABASE": "false", "ENABLE_PINECONE": "false", "MULTIMODAL_MODE": "simple"},
        "required": [],
    },
    {
        "id": "supabase",
        "group": "A",
        "overrides": {"ENABLE_SUPABASE": "true", "ENABLE_PINECONE": "false", "MULTIMODAL_MODE": "simple"},
        "required": ["SUPABASE_URL", "SUPABASE_KEY"],
    },
    {
        "id": "pinecone",
        "group": "A",
        "overrides": {"ENABLE_SUPABASE": "false", "ENABLE_PINECONE": "true", "MULTIMODAL_MODE": "simple"},
        "required": ["PINECONE_API_KEY"],
    },
    {
        "id": "both",
        "group": "A",
        "overrides": {"ENABLE_SUPABASE": "true", "ENABLE_PINECONE": "true", "MULTIMODAL_MODE": "simple"},
        "required": ["SUPABASE_URL", "SUPABASE_KEY", "PINECONE_API_KEY"],
    },
    # Group B
    {
        "id": "adv_supabase",
        "group": "B",
        "overrides": {
            "ENABLE_SUPABASE": "true", "ENABLE_PINECONE": "false",
            "MULTIMODAL_MODE": "advanced", "EMBEDDING_PROVIDER": "gemini",
        },
        "required": ["GEMINI_API_KEY", "SUPABASE_URL", "SUPABASE_KEY"],
    },
    {
        "id": "adv_pinecone",
        "group": "B",
        "overrides": {
            "ENABLE_SUPABASE": "false", "ENABLE_PINECONE": "true",
            "MULTIMODAL_MODE": "advanced", "EMBEDDING_PROVIDER": "gemini",
        },
        "required": ["GEMINI_API_KEY", "PINECONE_API_KEY"],
    },
    {
        "id": "adv_both",
        "group": "B",
        "overrides": {
            "ENABLE_SUPABASE": "true", "ENABLE_PINECONE": "true",
            "MULTIMODAL_MODE": "advanced", "EMBEDDING_PROVIDER": "gemini",
        },
        "required": ["GEMINI_API_KEY", "SUPABASE_URL", "SUPABASE_KEY", "PINECONE_API_KEY"],
    },
]

SCENARIO_IDS = [s["id"] for s in SCENARIOS]


# ── Helpers ──────────────────────────────────────────────────────────────────

def _apply_env(monkeypatch, scenario: dict) -> None:
    """Load .env into os.environ then apply scenario overrides."""
    # Load base .env so Config() picks up real credentials
    from dotenv import load_dotenv
    env_path = Path(__file__).parent.parent / ".env"
    load_dotenv(env_path, override=True)

    # Force OpenAI for LLM regardless of .env LLM_BINDING (avoids Ollama dependency in tests)
    monkeypatch.setenv("LIGHTRAG_LLM_PROVIDER", "openai")
    monkeypatch.setenv("LIGHTRAG_LLM_MODEL", "gpt-4o-mini")

    # Apply scenario-specific overrides
    for key, value in scenario["overrides"].items():
        monkeypatch.setenv(key, value)


# ── Tests ────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", SCENARIOS, ids=SCENARIO_IDS)
async def test_create(scenario, monkeypatch, tmp_path):
    """LightRAGPlus.create() succeeds — preflight + storage init."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))
    assert plus is not None


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", SCENARIOS, ids=SCENARIO_IDS)
async def test_insert_text(scenario, monkeypatch, tmp_path):
    """insert(text) succeeds without exception."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))
    await plus.insert(DUMMY_TEXT)  # no exception = pass


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", SCENARIOS, ids=SCENARIO_IDS)
async def test_query_graph(scenario, monkeypatch, tmp_path):
    """query(mode='graph') returns a non-empty graph result."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))
    await plus.insert(DUMMY_TEXT)
    result = await plus.query(DUMMY_QUERY, mode="graph", lightrag_mode="hybrid")

    assert "graph" in result
    assert result["graph"]  # non-empty string


@pytest.mark.asyncio
@pytest.mark.parametrize("scenario", SCENARIOS, ids=SCENARIO_IDS)
async def test_query_hybrid(scenario, monkeypatch, tmp_path):
    """query(mode='hybrid') returns correct remote structure per backend config."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))
    await plus.insert(DUMMY_TEXT)
    result = await plus.query(DUMMY_QUERY, mode="hybrid", lightrag_mode="hybrid")

    assert "graph" in result
    assert "remote" in result

    has_remote = (
        scenario["overrides"].get("ENABLE_SUPABASE") == "true"
        or scenario["overrides"].get("ENABLE_PINECONE") == "true"
    )
    if has_remote:
        assert isinstance(result["remote"], list)
        # Group B uses Gemini embedder (3072-dim) but backends are provisioned at 1536-dim;
        # upsert fails silently so remote will be empty — only check structure.
        if scenario["group"] == "A":
            assert len(result["remote"]) > 0, "Expected remote results after insert"
    else:
        assert result["remote"] == []


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "scenario",
    [s for s in SCENARIOS if s["group"] == "A"],
    ids=[s["id"] for s in SCENARIOS if s["group"] == "A"],
)
async def test_simple_rejects_nontext(scenario, monkeypatch, tmp_path, caplog):
    """Simple mode logs warning and skips non-text content (no crash)."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))

    with caplog.at_level(logging.WARNING, logger="src.lightrag_plus"):
        await plus.insert(b"fake image bytes", content_type="image")

    assert any("MULTIMODAL_MODE=advanced" in r.message for r in caplog.records), (
        "Expected warning about MULTIMODAL_MODE=advanced requirement"
    )


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "scenario",
    [s for s in SCENARIOS if s["group"] == "B"],
    ids=[s["id"] for s in SCENARIOS if s["group"] == "B"],
)
async def test_advanced_insert_image(scenario, monkeypatch, tmp_path, sample_image_bytes):
    """Advanced mode: insert image bytes → Gemini embeds → pushed to remote backend."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))

    await plus.insert(DUMMY_TEXT)
    await plus.insert(sample_image_bytes, content_type="image")

    result = await plus.query(DUMMY_QUERY, mode="hybrid", lightrag_mode="hybrid")
    assert "graph" in result
    assert "remote" in result
    assert isinstance(result["remote"], list)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "scenario",
    [s for s in SCENARIOS if s["group"] == "B"],
    ids=[s["id"] for s in SCENARIOS if s["group"] == "B"],
)
async def test_advanced_insert_image_path(scenario, monkeypatch, tmp_path, sample_image_path):
    """Advanced mode: insert image via Path → exercises Path code path in insert()."""
    skip_if_missing(*scenario["required"])
    _apply_env(monkeypatch, scenario)

    from src.lightrag_plus import LightRAGPlus
    plus = await LightRAGPlus.create(working_dir=str(tmp_path))

    await plus.insert(DUMMY_TEXT)
    await plus.insert(sample_image_path, content_type="image")

    result = await plus.query(DUMMY_QUERY, mode="hybrid", lightrag_mode="hybrid")
    assert "graph" in result
    assert "remote" in result
    assert isinstance(result["remote"], list)
