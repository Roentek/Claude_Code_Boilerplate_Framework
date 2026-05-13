"""
Shared fixtures and report writer for LightRAG Plus integration tests.
"""
import os
import sys
from datetime import datetime
from pathlib import Path

import pytest

# Ensure src/ is importable when running from tools/lightrag/
sys.path.insert(0, str(Path(__file__).parent.parent))

# ── SSL bypass (corporate proxy) ─────────────────────────────────────────────
# Must run at module import time (before any httpx client is created).
# Patches both sync and async transports so all httpx-based clients
# (OpenAI SDK, Gemini, Pinecone, Supabase) skip certificate verification.
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


# ── Auto-provision ───────────────────────────────────────────────────────────

def pytest_configure(config):
    """Run provision.py at session start to ensure remote backends are ready.

    Idempotent — skips cleanly if credentials are absent or resources already exist.
    Any failure is printed as a warning; remote tests will skip via skip_if_missing.
    """
    lightrag_dir = Path(__file__).parent.parent
    provision_script = lightrag_dir / "provision.py"

    has_supabase = bool(env_val("SUPABASE_URL") and env_val("SUPABASE_MANAGEMENT_TOKEN"))
    has_pinecone = bool(env_val("PINECONE_API_KEY"))

    if not (has_supabase or has_pinecone):
        return  # nothing to provision — skip silently

    import os
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


# ── Report writer ────────────────────────────────────────────────────────────

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
