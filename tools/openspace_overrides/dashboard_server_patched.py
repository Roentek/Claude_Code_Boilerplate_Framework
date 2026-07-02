"""Runtime patch for tools/openspace (git submodule) — kept OUTSIDE the submodule
so `git submodule update --remote` never conflicts with local edits.

Bug: openspace.dashboard_server._build_skill_stats always calls
store.get_stats(active_only=False), so "total_skills" (meant to be the
active-only count) is identical to "total_skills_all" on every /skills/stats
response and the dashboard overview. This patches the function to compute the
active count from the already-loaded skill list instead.

Run this in place of `python -m openspace.dashboard_server`.
"""
from openspace import dashboard_server as _server


def _build_skill_stats_fixed(store, skills):
    stats = _server._build_skill_stats.__wrapped_original__(store, skills)
    stats["total_skills"] = sum(1 for item in skills if item.is_active)
    return stats


_build_skill_stats_fixed.__wrapped_original__ = _server._build_skill_stats
_server._build_skill_stats = _build_skill_stats_fixed

if __name__ == "__main__":
    _server.main()
