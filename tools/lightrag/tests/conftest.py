"""
Shared fixtures and report writer for LightRAG Plus integration tests.
"""
import asyncio
import os
import sys
from datetime import datetime
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))

# ── SSL bypass (corporate proxy) ─────────────────────────────────────────────
# Must run at module import time — before any httpx client is created.
import httpx as _httpx

_orig_sync = _httpx.HTTPTransport.__init__
_orig_async = _httpx.AsyncHTTPTransport.__init__


def _no_verify_sync(self, *args, **kwargs):
    kwargs.setdefault("verify", False)
    _orig_sync(self, *args, **kwargs)


def _no_verify_async(self, *args, **kwargs):
    kwargs.setdefault("verify", False)
    _orig_async(self, *args, **kwargs)


_httpx.HTTPTransport.__init__ = _no_verify_sync
_httpx.AsyncHTTPTransport.__init__ = _no_verify_async


# ── .env helpers ──────────────────────────────────────────────────────────────

def load_dotenv_dict(env_path: Path) -> dict[str, str]:
    """Parse .env file into a dict. Skips comments and blank lines."""
    result = {}
    if not env_path.exists():
        return result
    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" in line:
            key, _, value = line.partition("=")
            result[key.strip()] = value.strip().strip('"').strip("'")
    return result


ENV_PATH = Path(__file__).parent.parent / ".env"
_dotenv = load_dotenv_dict(ENV_PATH)


def env_val(key: str) -> str:
    """Return value from .env file (not os.environ — avoids test bleed)."""
    return _dotenv.get(key, "")


def skip_if_missing(*keys: str) -> None:
    """Call at top of a test — pytest.skip if any key absent/empty in .env."""
    missing = [k for k in keys if not env_val(k)]
    if missing:
        pytest.skip(f"Missing .env vars: {', '.join(missing)}")


# ── Cloud ID tracking for post-run cleanup ───────────────────────────────────

_SUPA_IDS: set[str] = set()
_PINE_IDS: set[str] = set()


def _patch_adapters() -> None:
    """Wrap adapter upsert at class level to record every ID pushed to cloud."""
    try:
        from src.adapters.supabase_adapter import SupabaseAdapter
        from src.adapters.pinecone_adapter import PineconeAdapter

        _orig_supa = SupabaseAdapter.upsert
        _orig_pine = PineconeAdapter.upsert

        async def _supa_tracked(self, id: str, embedding, metadata):
            _SUPA_IDS.add(id)
            return await _orig_supa(self, id, embedding, metadata)

        async def _pine_tracked(self, id: str, embedding, metadata):
            _PINE_IDS.add(id)
            return await _orig_pine(self, id, embedding, metadata)

        SupabaseAdapter.upsert = _supa_tracked
        PineconeAdapter.upsert = _pine_tracked
    except Exception as exc:
        print(f"[conftest] adapter patch skipped: {exc}")


_patch_adapters()


# ── Auto-provision ────────────────────────────────────────────────────────────

def pytest_configure(config):
    """Run provision.py at session start to ensure remote backends are ready."""
    lightrag_dir = Path(__file__).parent.parent
    provision_script = lightrag_dir / "provision.py"

    has_supabase = bool(env_val("SUPABASE_URL") and env_val("SUPABASE_MANAGEMENT_TOKEN"))
    has_pinecone = bool(env_val("PINECONE_API_KEY"))

    if not (has_supabase or has_pinecone):
        return

    import subprocess
    env = {**os.environ, "PYTHONIOENCODING": "utf-8", "PYTHONDONTWRITEBYTECODE": "1"}
    result = subprocess.run(
        [sys.executable, str(provision_script)],
        cwd=str(lightrag_dir),
        capture_output=True,
        text=True,
        env=env,
    )
    if result.returncode != 0:
        print(
            f"\n[conftest] provision.py failed (remote tests may fail):\n"
            f"{result.stdout}\n{result.stderr}"
        )


# ── Cloud cleanup ─────────────────────────────────────────────────────────────

def pytest_sessionfinish(session, exitstatus):
    """Delete all test-inserted vectors from Supabase and Pinecone."""
    supa_count = len(_SUPA_IDS)
    pine_count = len(_PINE_IDS)

    if not (supa_count or pine_count):
        return

    print(f"\n{'-' * 60}")
    print(f"[cleanup] Pruning test vectors from cloud backends")
    print(f"          Supabase: {supa_count} | Pinecone: {pine_count}")

    async def _prune():
        if supa_count and env_val("SUPABASE_URL") and env_val("SUPABASE_KEY"):
            try:
                import httpx
                from supabase import create_client
                from supabase.lib.client_options import SyncClientOptions

                client = create_client(
                    env_val("SUPABASE_URL"),
                    env_val("SUPABASE_KEY"),
                    options=SyncClientOptions(httpx_client=httpx.Client(verify=False)),
                )
                ids = list(_SUPA_IDS)
                await asyncio.to_thread(
                    lambda: client.table("lightrag_vectors")
                    .delete()
                    .in_("id", ids)
                    .execute()
                )
                print(f"[cleanup] OK Supabase: deleted {len(ids)} rows from lightrag_vectors")
            except Exception as exc:
                print(f"[cleanup] FAIL Supabase prune failed: {exc}")

        if pine_count and env_val("PINECONE_API_KEY"):
            try:
                from pinecone import Pinecone

                index_name = env_val("PINECONE_INDEX") or "lightrag-vectors"
                pc = Pinecone(api_key=env_val("PINECONE_API_KEY"), ssl_verify=False)
                index = pc.Index(index_name)
                ids = list(_PINE_IDS)
                await asyncio.to_thread(index.delete, ids=ids)
                print(f"[cleanup] OK Pinecone: deleted {len(ids)} vectors from '{index_name}'")
            except Exception as exc:
                print(f"[cleanup] FAIL Pinecone prune failed: {exc}")

    asyncio.run(_prune())
    print(f"{'-' * 60}")


# ── Report writer ─────────────────────────────────────────────────────────────

_RESULTS: list[dict] = []


def record_result(scenario_id: str, check: str, passed: bool, detail: str = "") -> None:
    _RESULTS.append({"scenario": scenario_id, "check": check, "passed": passed, "detail": detail})


def pytest_terminal_summary(terminalreporter, exitstatus, config):
    """Write Markdown report to .tmp/ after test run."""
    project_root = Path(__file__).parent.parent.parent.parent
    tmp_dir = project_root / ".tmp"
    tmp_dir.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_path = tmp_dir / f"lightrag-test-report-{timestamp}.md"

    passed = terminalreporter.stats.get("passed", [])
    failed = terminalreporter.stats.get("failed", [])
    errors = terminalreporter.stats.get("error", [])
    skipped = terminalreporter.stats.get("skipped", [])

    lines = [
        "# LightRAG Plus Integration Test Report",
        f"\n**Run:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"**Total:** {len(passed)} passed · {len(failed)} failed · {len(errors)} errors · {len(skipped)} skipped\n",
        "## Results\n",
        "| Status | Test |",
        "|--------|------|",
    ]

    for item in passed:
        lines.append(f"| ✅ PASS | `{item.nodeid}` |")
    for item in skipped:
        reason = item.longrepr[2] if item.longrepr else ""
        lines.append(f"| ⏭ SKIP | `{item.nodeid}` — {reason} |")
    for item in failed + errors:
        lines.append(f"| ❌ FAIL | `{item.nodeid}` |")

    if failed or errors:
        lines.append("\n## Failures\n")
        for item in failed + errors:
            lines.append(f"### `{item.nodeid}`\n```\n{item.longreprtext}\n```\n")

    report_path.write_text("\n".join(lines), encoding="utf-8")
    terminalreporter.write_sep("-", f"Report: {report_path}")
