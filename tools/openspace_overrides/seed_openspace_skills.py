"""Seed the OpenSpace skill tree (SQLite) from local skill directories.

Lives OUTSIDE the OpenSpace submodule, under tools/openspace_overrides/ (all
non-submodule OpenSpace wrappers/patches live here — see dashboard_server_patched.py)
so it is tracked by the parent repo and never blocks the submodule auto-sync hook.
Run it with the OpenSpace venv python (which has the `openspace` package installed):

    tools/openspace/.venv/Scripts/python.exe tools/openspace_overrides/seed_openspace_skills.py

Discovers skills on disk and upserts them into ``tools/openspace/.openspace/openspace.db``
as tree roots (``origin=IMPORTED``) so they show up in the dashboard immediately,
without waiting for a task run to select them.

Sources (in priority order):
  1. repo  .claude/skills                    (durable — evolution writes to git-tracked source)
  2.       tools/openspace/showcase/skills   (bundled examples)
  3. global ~/.claude/skills                  (only with --include-global; repo copies win on name dedup)

Usage:
  python tools/openspace_overrides/seed_openspace_skills.py                  # repo + showcase
  python tools/openspace_overrides/seed_openspace_skills.py --include-global # + global-only skills (deduped vs repo by name)

Reuses OpenSpace internals unchanged: SkillRegistry.discover() and
SkillStore.sync_from_registry(). Idempotent — safe to re-run.
"""

from __future__ import annotations

import argparse
import asyncio
import os
from pathlib import Path

from openspace.skill_engine import SkillRegistry, SkillStore

SCRIPT_DIR = Path(__file__).resolve().parent            # tools/openspace_overrides/
REPO_ROOT = SCRIPT_DIR.parent.parent                    # repo root
REPO_SKILLS = REPO_ROOT / ".claude" / "skills"
SHOWCASE_SKILLS = REPO_ROOT / "tools" / "openspace" / "showcase" / "skills"
GLOBAL_SKILLS = Path.home() / ".claude" / "skills"


def _source_dirs(include_global: bool) -> list[tuple[Path, str]]:
    """Return (dir, category) pairs that exist, in discovery priority order.

    Sources are computed from the repo layout — not from OPENSPACE_HOST_SKILL_DIRS
    (that env var drives the *runtime agent*; the seeder must stay deterministic and
    lean-by-default, or a stray env value silently pulls global skills into the tree).
    """
    pairs = [(REPO_SKILLS, "local"), (SHOWCASE_SKILLS, "showcase")]
    if include_global:
        pairs.append((GLOBAL_SKILLS, "global"))
    return [(d, c) for d, c in pairs if d.exists()]


def _categorize(path: Path, dirs: list[tuple[Path, str]]) -> str:
    for d, cat in dirs:
        try:
            path.relative_to(d)
            return cat
        except ValueError:
            continue
    return "unknown"


def _dedup_by_name(skills, dirs):
    """Keep one skill per name — the highest-priority source wins (repo > showcase > global)."""
    priority = {cat: i for i, (_, cat) in enumerate(dirs)}
    best: dict[str, object] = {}
    for meta in skills:
        cat = _categorize(meta.path, dirs)
        rank = priority.get(cat, len(dirs))
        cur = best.get(meta.name)
        if cur is None or rank < priority.get(_categorize(cur.path, dirs), len(dirs)):
            best[meta.name] = meta
    return list(best.values())


async def main() -> None:
    ap = argparse.ArgumentParser(description="Seed OpenSpace skill tree from local dirs.")
    ap.add_argument(
        "--include-global",
        action="store_true",
        default=os.environ.get("OPENSPACE_INCLUDE_GLOBAL", "").lower() in ("1", "true", "yes"),
        help="Also import global-only skills from ~/.claude/skills (deduped against repo by name).",
    )
    args = ap.parse_args()

    dirs = _source_dirs(args.include_global)
    if not dirs:
        print("No skill directories found. Checked:")
        print(f"  repo:     {REPO_SKILLS}")
        print(f"  showcase: {SHOWCASE_SKILLS}")
        if args.include_global:
            print(f"  global:   {GLOBAL_SKILLS}")
        return

    print("Scanning skill directories (priority order):")
    for d, cat in dirs:
        print(f"  [{cat:8}] {d}")

    registry = SkillRegistry(skill_dirs=[d for d, _ in dirs])
    skills = registry.discover()

    before = len(skills)
    if args.include_global:
        skills = _dedup_by_name(skills, dirs)
    deduped = before - len(skills)

    counts: dict[str, int] = {}
    for meta in skills:
        cat = _categorize(meta.path, dirs)
        counts[cat] = counts.get(cat, 0) + 1

    store = SkillStore()
    try:
        created = await store.sync_from_registry(skills)
    finally:
        store.close()

    print()
    print(f"Synced {len(skills)} skill(s) into {store.db_path}")
    print(f"  created (new roots): {created}")
    print(f"  unchanged:           {len(skills) - created}")
    if deduped:
        print(f"  deduped (repo won):  {deduped}")
    for cat in ("local", "showcase", "global", "unknown"):
        if counts.get(cat):
            print(f"  {cat:8}: {counts[cat]}")


if __name__ == "__main__":
    asyncio.run(main())
