# /update-all

Keep the project current. Updates npm globals, uv tools, Python venvs, npm project deps, and git submodules. Repairs broken venvs (OneDrive file-deletion pattern) automatically.

## Run

```bash
bash .claude/hooks/update-all.sh
```

## What updates automatically

| Category | Mechanism |
|----------|-----------|
| npm global tools | `npm install -g <pkg>@latest` for each entry in `NPM_GLOBALS` |
| uv tools | `uv tool upgrade --all` — all uv-installed tools, no config needed |
| Python venvs | Scans `tools/*/pyproject.toml` — new tool dirs auto-register |
| npm project deps | `npm update` |
| git submodules | `git submodule update --remote` |
| Broken venv repair | `uv pip check` → removes bad dist-infos → reinstalls missing transitive deps |

## What does NOT auto-update

| Item | Manual step |
|------|-------------|
| Claude plugins | `claude plugin install <name>@<marketplace>` |
| MCP servers | Restart Claude Code — `npx @latest` servers refresh automatically |
| lightrag-hku | Pinned in `uv.lock` (OneDrive upgrade risk) — use `python check_update.py` |

## Adding new packages to the update list

- **npm global**: add entry to `NPM_GLOBALS` array in `.claude/hooks/update-all.sh`
- **uv tool**: nothing — `uv tool upgrade --all` covers all installed tools
- **Python venv**: nothing — any `tools/<name>/pyproject.toml` dir is auto-scanned
- **Claude plugin**: add `claude plugin install <name>@<marketplace>` line to setup.sh step 7 and document in CLAUDE.md

## Schedule weekly (optional)

```
/schedule weekly update-all
```

## Run via Claude

```
/update-all
```

Claude will run the script and report what was updated, skipped, and failed.
