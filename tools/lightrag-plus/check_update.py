#!/usr/bin/env python3
"""
LightRAG update checker and auto-upgrader.

Usage:
  uv run python check_update.py           # check: report if update available
  uv run python check_update.py --upgrade # upgrade: update pin, sync, verify, smoke test

Exit codes:
  0 — up to date, or upgrade succeeded
  1 — error
  2 — major version available (manual review required)
"""

import argparse
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

PYPROJECT = Path(__file__).parent / "pyproject.toml"
PYPI_URL = "https://pypi.org/pypi/lightrag-hku/json"
TAG = "[lightrag-check]"


def get_latest_pypi():
    try:
        with urllib.request.urlopen(PYPI_URL, timeout=10) as r:
            return json.loads(r.read())["info"]["version"]
    except Exception as e:
        print(f"{TAG} PyPI lookup failed: {e}")
        sys.exit(1)


def get_pin(content):
    m = re.search(r'"lightrag-hku>=(\d+\.\d+\.\d+),<(\d+)\.0\.0"', content)
    return (m.group(1), int(m.group(2))) if m else (None, None)


def parse_ver(v):
    return tuple(int(x) for x in v.split("."))


def run(cmd, cwd=None):
    r = subprocess.run(cmd, cwd=cwd or PYPROJECT.parent, capture_output=True, text=True)
    if r.returncode != 0:
        print(f"{TAG} FAILED: {' '.join(str(c) for c in cmd)}\n{r.stderr}")
        sys.exit(1)
    if r.stdout.strip():
        print(r.stdout.strip())
    return r


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--upgrade", action="store_true", help="Apply upgrade if available")
    args = parser.parse_args()

    content = PYPROJECT.read_text(encoding="utf-8")
    current_min, max_major = get_pin(content)
    if not current_min:
        print(f"{TAG} ERROR: could not parse lightrag-hku pin in pyproject.toml")
        sys.exit(1)

    latest = get_latest_pypi()
    latest_t = parse_ver(latest)
    current_t = parse_ver(current_min)

    if latest_t[0] >= max_major:
        print(f"{TAG} MAJOR update available: {latest} (pin blocks at <{max_major}.0.0)")
        print(f"{TAG} Review: https://github.com/HKUDS/LightRAG/releases")
        print(f"{TAG} To upgrade major: bump <{max_major}.0.0 → <{latest_t[0] + 1}.0.0 in pyproject.toml, then run --upgrade")
        sys.exit(2)

    if latest_t <= current_t:
        print(f"{TAG} Up to date ({current_min})")
        sys.exit(0)

    print(f"{TAG} Update available: {current_min} → {latest}")

    if not args.upgrade:
        print(f"{TAG} To upgrade: uv run python check_update.py --upgrade")
        sys.exit(0)

    # Upgrade
    print(f"{TAG} Upgrading {current_min} → {latest} ...")

    new_content = content.replace(
        f'"lightrag-hku>={current_min},<{max_major}.0.0"',
        f'"lightrag-hku>={latest},<{max_major}.0.0"',
    )
    PYPROJECT.write_text(new_content, encoding="utf-8")
    print(f"{TAG} pyproject.toml updated")

    run(["uv", "sync", "--upgrade-package", "lightrag-hku"])
    print(f"{TAG} uv sync complete")

    # Verify the 3 integration symbols
    run([
        "uv", "run", "python", "-c",
        "from lightrag import LightRAG, QueryParam; from lightrag.utils import EmbeddingFunc; "
        "print('[lightrag-check] core imports OK')",
    ])

    # Smoke test Plus layer
    run([
        "uv", "run", "python", "-c",
        "import sys; sys.path.insert(0, 'src'); from lightrag_plus import LightRAGPlus; "
        "print('[lightrag-check] LightRAGPlus import OK')",
    ])

    print(f"{TAG} Done: {current_min} → {latest}")


if __name__ == "__main__":
    main()
