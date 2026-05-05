# OpenSpace Git Submodule Conversion Guide

This guide converts the existing `tools/openspace/` clone into a git submodule with automatic upstream sync.

## What This Does

- **Before:** `tools/openspace/` is a regular git clone attached to the HKUDS/OpenSpace repo
- **After:** `tools/openspace/` becomes a git submodule that:
  - Tracks a specific commit (reproducible builds)
  - Auto-syncs with upstream on every session via `openspace-sync.sh` hook
  - Works seamlessly with fresh clones (auto-initialized by `setup.sh`)
  - Preserves all integrations (skills, MCP, launch configs, .env paths)

## Prerequisites

1. **Backup any local changes** in `tools/openspace/` if you have uncommitted work
2. **Commit or stash changes** in the main repo before converting

## Conversion Steps

### Step 1: Check for uncommitted changes in OpenSpace

```bash
cd tools/openspace
git status
```

If you have uncommitted changes, either:

- Commit them: `git add . && git commit -m "Local changes before submodule conversion"`
- Stash them: `git stash`
- Or back up the directory: `cp -r tools/openspace tools/openspace-backup`

### Step 2: Remove the current OpenSpace directory

```bash
cd ../..  # Back to project root
rm -rf tools/openspace
```

### Step 3: Add OpenSpace as a git submodule

```bash
git submodule add https://github.com/HKUDS/OpenSpace.git tools/openspace
```

### Step 4: Initialize and update the submodule

```bash
git submodule update --init --recursive tools/openspace
```

### Step 5: Commit the submodule configuration

```bash
git add .gitmodules tools/openspace
git commit -m "Convert OpenSpace to git submodule with auto-sync hook"
```

### Step 6: Verify the setup

```bash
# Check submodule status
git submodule status

# Check that OpenSpace files are present
ls -la tools/openspace/

# Verify the sync hook is configured
cat .claude/hooks/openspace-sync.sh
```

## What Happens Next

### Auto-Sync Behavior

The `openspace-sync.sh` hook runs at the end of every session via `stop.sh`:

1. **If submodule is up-to-date:** Silent success (no output)
2. **If updates are available:** Pulls latest from upstream, updates submodule pointer
3. **If you have uncommitted changes:** Skips sync and warns you

### Manual Updates (Optional)

You can also manually update the submodule:

```bash
cd tools/openspace
git pull origin main
cd ../..
git add tools/openspace
git commit -m "Update OpenSpace submodule to latest"
```

### Fresh Clones (For Team Members)

When someone clones this repo fresh, the submodule will auto-initialize via `setup.sh`:

```bash
git clone <your-repo-url>
cd <your-repo>
bash .claude/hooks/setup.sh
# → OpenSpace submodule auto-initialized in step 15
```

Or manually:

```bash
git submodule update --init --recursive
```

## Integrations Preserved

All OpenSpace integrations remain intact after conversion:

✅ **Skills:**

- `.claude/skills/openspace/SKILL.md`
- `.claude/skills/delegate-task/SKILL.md`
- `.claude/skills/skill-discovery/SKILL.md`

✅ **Environment:**

- `.env` paths (`OPENSPACE_HOST_SKILL_DIRS`, `OPENSPACE_WORKSPACE`)
- `tools/openspace/.openspace/` skill database
- `tools/openspace/logs/` execution logs

✅ **MCP Server:**

- `.mcp.json` configuration
- `settings.json` enabledMcpjsonServers

✅ **VSCode:**

- `.vscode/launch.json` (4 debug configs: LightRAG + OpenSpace backend/frontend)
- `.vscode/tasks.json`

✅ **Commands:**

- CLI: `openspace --query`, `openspace-download-skill`, `openspace-upload-skill`
- MCP: `mcp__openspace__*` tools (backup)

## Troubleshooting

### "Submodule not initialized" error

Run from project root:

```bash
git submodule update --init --recursive tools/openspace
```

### Submodule shows uncommitted changes

Check what changed:

```bash
cd tools/openspace
git status
git diff
```

If it's `.openspace/` or `logs/` (gitignored by OpenSpace), you can safely ignore it.

### Auto-sync failed

Check the sync hook log:

```bash
bash .claude/hooks/openspace-sync.sh
```

### Want to pin to a specific OpenSpace version

```bash
cd tools/openspace
git checkout <commit-hash-or-tag>
cd ../..
git add tools/openspace
git commit -m "Pin OpenSpace to version X"
```

Then disable auto-sync by commenting out the hook call in `stop.sh`:

```bash
# bash "$(dirname "$0")/openspace-sync.sh" 2>/dev/null || true
```

## Reverting (If Needed)

If you need to go back to a regular clone:

```bash
# Remove submodule
git submodule deinit -f tools/openspace
git rm -f tools/openspace
rm -rf .git/modules/tools/openspace

# Clone OpenSpace normally
git clone https://github.com/HKUDS/OpenSpace.git tools/openspace

# Commit the change
git add .
git commit -m "Revert OpenSpace to regular clone"
```

## Benefits of Submodule + Auto-Sync Hybrid

1. **Reproducible builds** — Each commit in your repo tracks an exact OpenSpace version
2. **Always up-to-date** — Auto-sync hook keeps you current with upstream
3. **Safe updates** — Only syncs when you have no uncommitted changes
4. **Fresh clone friendly** — setup.sh auto-initializes for new team members
5. **Standard Git workflow** — Anyone familiar with submodules can work with it
6. **Manual control** — Can pin to a specific version if needed

## References

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [OpenSpace GitHub](https://github.com/HKUDS/OpenSpace)
- [Setup Script](../../.claude/hooks/setup.sh) (step 15)
- [Auto-Sync Hook](../../.claude/hooks/openspace-sync.sh)
