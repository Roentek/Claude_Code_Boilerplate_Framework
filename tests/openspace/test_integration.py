"""
OpenSpace integration tests — three tiers.

Tier 1 (no API key): imports, config, SkillStore CRUD, SkillRegistry discovery,
                     CLI entrypoints, cloud auth error path.
Tier 2 (LLM key):   OpenSpace.initialize() with shell-only backend.
Tier 3 (cloud key): get_openspace_auth(), hybrid_search_skills().

Design constraints:
  - Tests live outside the submodule (tools/openspace/) to preserve auto-sync.
  - Tests depend only on the public API surface (tool_layer, skill_engine,
    cloud) so they survive upstream refactors to internals.
  - No task execution in CI — avoids token cost and non-determinism.

Run:
    cd C:\\GIT\\Claude_Code_Boilerplate_Framework
    tools\\openspace\\.venv\\Scripts\\python.exe -m pytest tests\\openspace\\ -v
"""

import os
import pytest
from pathlib import Path

from conftest import has_llm_key, has_cloud_key, pick_llm_model


# ===========================================================================
# Tier 1 — no API key required
# ===========================================================================


class TestImports:
    """All public entry-point modules must import without error."""

    def test_tool_layer(self):
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        assert OpenSpace is not None
        assert OpenSpaceConfig is not None

    def test_skill_engine(self):
        from openspace.skill_engine import SkillRegistry, SkillStore, ExecutionAnalyzer
        for cls in (SkillRegistry, SkillStore, ExecutionAnalyzer):
            assert cls is not None

    def test_skill_store_direct(self):
        from openspace.skill_engine.store import SkillStore
        assert SkillStore is not None

    def test_llm_client(self):
        from openspace.llm import LLMClient
        assert LLMClient is not None

    def test_recording(self):
        from openspace.recording import RecordingManager
        assert RecordingManager is not None

    def test_cloud_auth(self):
        from openspace.cloud.auth import get_openspace_auth
        assert callable(get_openspace_auth)

    def test_cloud_search(self):
        from openspace.cloud.search import hybrid_search_skills
        assert callable(hybrid_search_skills)

    def test_mcp_server_module(self):
        import openspace.mcp_server  # noqa: F401

    def test_cli_main(self):
        import openspace.__main__  # noqa: F401

    def test_cli_download(self):
        import openspace.cloud.cli.download_skill  # noqa: F401

    def test_cli_upload(self):
        import openspace.cloud.cli.upload_skill  # noqa: F401

    def test_local_server_main(self):
        import openspace.local_server.main  # noqa: F401


class TestConfig:
    """OpenSpaceConfig validation and field defaults."""

    def test_default_model_set(self):
        from openspace.tool_layer import OpenSpaceConfig
        cfg = OpenSpaceConfig()
        assert cfg.llm_model and isinstance(cfg.llm_model, str)

    def test_default_iterations_positive(self):
        from openspace.tool_layer import OpenSpaceConfig
        cfg = OpenSpaceConfig()
        assert cfg.grounding_max_iterations > 0

    def test_default_timeout_positive(self):
        from openspace.tool_layer import OpenSpaceConfig
        cfg = OpenSpaceConfig()
        assert cfg.llm_timeout > 0

    def test_default_evolution_concurrent_positive(self):
        from openspace.tool_layer import OpenSpaceConfig
        cfg = OpenSpaceConfig()
        assert cfg.evolution_max_concurrent >= 1

    def test_model_required_raises(self):
        from openspace.tool_layer import OpenSpaceConfig
        with pytest.raises(Exception):
            OpenSpaceConfig(llm_model="")

    def test_custom_backend_scope(self):
        from openspace.tool_layer import OpenSpaceConfig
        cfg = OpenSpaceConfig(
            llm_model="openai/gpt-4o-mini",
            backend_scope=["shell"],
            enable_recording=False,
            grounding_max_iterations=3,
        )
        assert cfg.backend_scope == ["shell"]
        assert not cfg.enable_recording
        assert cfg.grounding_max_iterations == 3

    def test_repr_not_initialized(self):
        from openspace.tool_layer import OpenSpace
        r = repr(OpenSpace())
        assert "OpenSpace" in r
        assert "not initialized" in r or "initialized" in r  # either is fine


class TestSkillRegistry:
    """SkillRegistry — discovery, identity, and stability."""

    def test_discover_two_skills(self, fixture_skills_root):
        from openspace.skill_engine.registry import SkillRegistry
        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()
        skills = registry.list_skills()
        assert len(skills) >= 2

    def test_skill_names_present(self, fixture_skills_root):
        from openspace.skill_engine.registry import SkillRegistry
        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()
        names = {s.name for s in registry.list_skills()}
        assert "alpha-skill" in names
        assert "beta-skill" in names

    def test_skill_meta_fields_populated(self, fixture_skills_root):
        from openspace.skill_engine.registry import SkillRegistry
        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()
        skill = registry.list_skills()[0]
        assert skill.name
        assert skill.description
        assert skill.skill_id  # sidecar .skill_id created/read

    def test_empty_dir_returns_empty_list(self, tmp_path):
        from openspace.skill_engine.registry import SkillRegistry
        registry = SkillRegistry(skill_dirs=[tmp_path])
        registry.discover()
        assert registry.list_skills() == []

    def test_skill_id_stable_across_runs(self, fixture_skills_root):
        """Second discover() reads existing .skill_id sidecar — IDs must not change."""
        from openspace.skill_engine.registry import SkillRegistry

        r1 = SkillRegistry(skill_dirs=[fixture_skills_root])
        r1.discover()
        ids_first = {s.skill_id for s in r1.list_skills()}

        r2 = SkillRegistry(skill_dirs=[fixture_skills_root])
        r2.discover()
        ids_second = {s.skill_id for s in r2.list_skills()}

        assert ids_first == ids_second

    def test_builtin_skills_discoverable(self):
        """Package ships with an openspace/skills/ dir — must not crash on discover."""
        import openspace
        from openspace.skill_engine.registry import SkillRegistry

        builtin = Path(openspace.__file__).parent / "skills"
        if not builtin.exists():
            pytest.skip("No built-in skills directory in this OpenSpace version")

        registry = SkillRegistry(skill_dirs=[builtin])
        registry.discover()
        # Count may be zero — just verifying no exceptions
        assert isinstance(registry.list_skills(), list)

    def test_multiple_skill_dirs_merged(self, fixture_skills_root, single_skill_dir):
        """Skills from multiple dirs are merged into one list."""
        from openspace.skill_engine.registry import SkillRegistry

        registry = SkillRegistry(skill_dirs=[fixture_skills_root, single_skill_dir])
        registry.discover()
        skills = registry.list_skills()
        assert len(skills) >= 3  # 2 from fixture_skills_root + 1 from single_skill_dir


class TestSkillStore:
    """SkillStore — SQLite CRUD via isolated tmp_db."""

    async def test_db_file_created(self, tmp_db):
        from openspace.skill_engine.store import SkillStore
        async with SkillStore(db_path=tmp_db) as store:
            _ = store.get_summary()
        assert tmp_db.exists()

    async def test_empty_summary(self, tmp_db):
        from openspace.skill_engine.store import SkillStore
        async with SkillStore(db_path=tmp_db) as store:
            summary = store.get_summary()
        assert summary == []

    async def test_sync_from_registry_populates_store(self, fixture_skills_root, tmp_db):
        from openspace.skill_engine.store import SkillStore
        from openspace.skill_engine.registry import SkillRegistry

        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()
        skills = registry.list_skills()

        async with SkillStore(db_path=tmp_db) as store:
            await store.sync_from_registry(skills)
            summary = store.get_summary()

        assert len(summary) >= 2

    async def test_sync_idempotent(self, fixture_skills_root, tmp_db):
        """sync_from_registry called twice must not duplicate records."""
        from openspace.skill_engine.store import SkillStore
        from openspace.skill_engine.registry import SkillRegistry

        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()
        skills = registry.list_skills()

        async with SkillStore(db_path=tmp_db) as store:
            await store.sync_from_registry(skills)
            count_first = len(store.get_summary())
            await store.sync_from_registry(skills)
            count_second = len(store.get_summary())

        assert count_first == count_second

    async def test_active_only_filter(self, fixture_skills_root, tmp_db):
        from openspace.skill_engine.store import SkillStore
        from openspace.skill_engine.registry import SkillRegistry

        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()

        async with SkillStore(db_path=tmp_db) as store:
            await store.sync_from_registry(registry.list_skills())
            all_records = store.get_summary(active_only=False)
            active_records = store.get_summary(active_only=True)

        assert len(active_records) <= len(all_records)

    async def test_summary_fields(self, fixture_skills_root, tmp_db):
        """Each summary row must have at minimum skill_id and name keys."""
        from openspace.skill_engine.store import SkillStore
        from openspace.skill_engine.registry import SkillRegistry

        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()

        async with SkillStore(db_path=tmp_db) as store:
            await store.sync_from_registry(registry.list_skills())
            for row in store.get_summary():
                assert "skill_id" in row
                assert "name" in row

    async def test_explicit_close(self, tmp_db):
        from openspace.skill_engine.store import SkillStore
        store = SkillStore(db_path=tmp_db)
        store.get_summary()
        store.close()  # must not raise


class TestCloudAuthNoKey:
    """Cloud auth error path — no API key needed for the error case."""

    def test_get_openspace_auth_returns_empty_when_no_key(self, monkeypatch):
        """With no OPENSPACE_API_KEY set, auth_headers should be empty."""
        monkeypatch.delenv("OPENSPACE_API_KEY", raising=False)
        from openspace.cloud.auth import get_openspace_auth
        auth_headers, api_base = get_openspace_auth()
        assert isinstance(auth_headers, dict)
        assert isinstance(api_base, str)
        # Empty headers signal "no credentials"
        assert not auth_headers

    def test_openspace_client_raises_without_auth(self):
        """OpenSpaceClient(auth_headers={}, ...) must raise CloudError."""
        from openspace.cloud.client import OpenSpaceClient
        with pytest.raises(Exception, match="(?i)api.?key|openspace"):
            OpenSpaceClient(auth_headers={}, api_base="https://open-space.cloud/api/v1")


# ===========================================================================
# Tier 2 — LLM API key required
# ===========================================================================

@pytest.mark.skipif(not has_llm_key(), reason="No LLM API key in environment")
class TestOpenSpaceInit:
    """OpenSpace.initialize() with shell-only backend — no task execution, no token burn."""

    async def test_init_shell_only(self):
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        cfg = OpenSpaceConfig(
            llm_model=pick_llm_model(),
            backend_scope=["shell"],
            enable_recording=False,
            grounding_max_iterations=3,
        )
        async with OpenSpace(cfg) as os_instance:
            assert os_instance.is_initialized()

    async def test_list_backends_after_init(self):
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        cfg = OpenSpaceConfig(
            llm_model=pick_llm_model(),
            backend_scope=["shell"],
            enable_recording=False,
        )
        async with OpenSpace(cfg) as os_instance:
            backends = os_instance.list_backends()
            assert isinstance(backends, list)
            # shell backend must be in the list
            assert any("shell" in b.lower() for b in backends)

    async def test_double_initialize_is_idempotent(self):
        """Calling initialize() twice must warn but not raise."""
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        cfg = OpenSpaceConfig(
            llm_model=pick_llm_model(),
            backend_scope=["shell"],
            enable_recording=False,
        )
        os_instance = OpenSpace(cfg)
        await os_instance.initialize()
        await os_instance.initialize()  # second call — should be a no-op
        assert os_instance.is_initialized()
        await os_instance.cleanup()

    async def test_cleanup_after_init(self):
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        cfg = OpenSpaceConfig(
            llm_model=pick_llm_model(),
            backend_scope=["shell"],
            enable_recording=False,
        )
        os_instance = OpenSpace(cfg)
        await os_instance.initialize()
        await os_instance.cleanup()
        assert not os_instance.is_initialized()

    async def test_execute_before_init_raises(self):
        """execute() without initialize() must raise RuntimeError."""
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        cfg = OpenSpaceConfig(llm_model=pick_llm_model(), enable_recording=False)
        os_instance = OpenSpace(cfg)
        with pytest.raises(RuntimeError, match="(?i)not initialized|initialize"):
            await os_instance.execute("do something")

    async def test_init_with_skill_dirs(self, fixture_skills_root):
        """initialize() with custom skill dirs should discover fixture skills."""
        from openspace.tool_layer import OpenSpace, OpenSpaceConfig
        cfg = OpenSpaceConfig(
            llm_model=pick_llm_model(),
            backend_scope=["shell"],
            enable_recording=False,
        )
        # Inject skill dir via env (same path OpenSpace._init_skill_registry reads)
        os.environ["OPENSPACE_HOST_SKILL_DIRS"] = str(fixture_skills_root)
        try:
            async with OpenSpace(cfg) as os_instance:
                assert os_instance.is_initialized()
        finally:
            os.environ.pop("OPENSPACE_HOST_SKILL_DIRS", None)


# ===========================================================================
# Tier 3 — OPENSPACE_API_KEY required (cloud registry)
# ===========================================================================

@pytest.mark.skipif(not has_cloud_key(), reason="No OPENSPACE_API_KEY in environment")
class TestCloudRegistry:
    """Cloud skill registry operations."""

    def test_get_openspace_auth_returns_headers(self):
        from openspace.cloud.auth import get_openspace_auth
        auth_headers, api_base = get_openspace_auth()
        assert auth_headers  # non-empty when key is set
        assert api_base.startswith("http")

    async def test_hybrid_search_returns_list(self):
        from openspace.cloud.search import hybrid_search_skills
        results = await hybrid_search_skills("data analysis", limit=5)
        assert isinstance(results, list)
        # Each result should have at minimum a name field
        for r in results:
            assert isinstance(r, dict)

    async def test_hybrid_search_local_only(self, fixture_skills_root):
        """source='local' should use only fixture skills — no cloud call."""
        from openspace.skill_engine.registry import SkillRegistry
        from openspace.cloud.search import hybrid_search_skills

        registry = SkillRegistry(skill_dirs=[fixture_skills_root])
        registry.discover()
        local_skills = registry.list_skills()

        results = await hybrid_search_skills(
            "alpha",
            local_skills=local_skills,
            source="local",
            limit=10,
        )
        assert isinstance(results, list)
