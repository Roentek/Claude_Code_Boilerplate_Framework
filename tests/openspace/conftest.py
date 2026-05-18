"""
Shared fixtures for OpenSpace integration tests.

Run with the openspace venv so the package is importable:
    tools/openspace/.venv/Scripts/python.exe -m pytest tests/openspace/ -v        # Windows
    tools/openspace/.venv/bin/python -m pytest tests/openspace/ -v                # Unix

Tier 1 tests (no API key) run unconditionally.
Tier 2 tests require any of: ANTHROPIC_API_KEY, OPENAI_API_KEY, OPENROUTER_API_KEY.
Tier 3 tests require: OPENSPACE_API_KEY.
"""

import os
from pathlib import Path
import pytest

# Load tools/openspace/.env into os.environ if present (non-overriding).
_OPENSPACE_ENV = Path(__file__).parents[2] / "tools" / "openspace" / ".env"
if _OPENSPACE_ENV.exists():
    try:
        from dotenv import load_dotenv
        load_dotenv(_OPENSPACE_ENV, override=False)
    except ImportError:
        pass  # python-dotenv not installed — env must be set externally


# ---------------------------------------------------------------------------
# Helpers (also exported so test modules can use them)
# ---------------------------------------------------------------------------

def has_llm_key() -> bool:
    return any(
        os.environ.get(k)
        for k in ("ANTHROPIC_API_KEY", "OPENAI_API_KEY", "OPENROUTER_API_KEY")
    )


def has_cloud_key() -> bool:
    return bool(os.environ.get("OPENSPACE_API_KEY"))


def pick_llm_model() -> str:
    """Return a cheap model based on which key is available."""
    if os.environ.get("ANTHROPIC_API_KEY"):
        return "anthropic/claude-haiku-4-5-20251001"
    if os.environ.get("OPENAI_API_KEY"):
        return "openai/gpt-4o-mini"
    if os.environ.get("OPENROUTER_API_KEY"):
        return "openrouter/anthropic/claude-haiku-4-5-20251001"
    return "anthropic/claude-haiku-4-5-20251001"


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def tmp_db(tmp_path):
    """Isolated SkillStore database path — never pollutes .openspace/openspace.db."""
    return tmp_path / "test.db"


@pytest.fixture
def fixture_skills_root(tmp_path):
    """Temp directory containing two minimal valid skill subdirs."""
    for name, desc in [
        ("alpha-skill", "Does alpha things for testing"),
        ("beta-skill", "Does beta things for testing"),
    ]:
        d = tmp_path / name
        d.mkdir()
        (d / "SKILL.md").write_text(
            f"---\nname: {name}\ndescription: {desc}\n---\n\n"
            f"# {name}\n\nDoes nothing. Exists only for testing.\n",
            encoding="utf-8",
        )
    return tmp_path


@pytest.fixture
def single_skill_dir(tmp_path):
    """Temp directory containing one skill subdir."""
    d = tmp_path / "test-skill"
    d.mkdir()
    (d / "SKILL.md").write_text(
        "---\nname: test-skill\ndescription: Minimal skill for unit tests\n---\n\n"
        "# Test Skill\n\nNo-op — testing only.\n",
        encoding="utf-8",
    )
    return tmp_path
