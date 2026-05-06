# OpenSpace Git Submodule Setup — Complete

## ✅ What Was Done

### 1. Created Auto-Sync Hook

**File:** `.claude/hooks/openspace-sync.sh`

- Auto-syncs `tools/openspace/` git submodule with upstream HKUDS/OpenSpace
- Runs at the end of every session via `stop.sh`
- Silent if no changes; pulls updates if available
- Skips if uncommitted changes exist
- Updates submodule pointer in parent repo

### 2. Updated Stop Hook

**File:** `.claude/hooks/stop.sh`

Added openspace-sync.sh call after autoresearch-sync.sh:

```bash
# ── Sync OpenSpace submodule with upstream ─────────────────
bash "$(dirname "$0")/openspace-sync.sh" 2>/dev/null || true
```

### 3. Updated Setup Script

**File:** `.claude/hooks/setup.sh` (Step 15)

Added submodule initialization check:

```bash
# Check if OpenSpace is configured as a git submodule
if [ -f "$ROOT/.gitmodules" ] && grep -q "path = tools/openspace" "$ROOT/.gitmodules"; then
  # It's a submodule — initialize if not already done
  if [ ! -d "$OPENSPACE_DIR/.git" ] && [ ! -f "$OPENSPACE_DIR/.git" ]; then
    echo "  📦 Initializing OpenSpace submodule..."
    (cd "$ROOT" && git submodule update --init --recursive tools/openspace)
  else
    echo "  ✓ OpenSpace submodule already initialized"
  fi
fi
```

Now handles both fresh clones (auto-initializes submodule) and existing setups (proceeds to pip install).

### 4. Created Conversion Guide

**File:** `.claude/docs/openspace-submodule-conversion.md`

Complete step-by-step guide for converting the existing OpenSpace clone to a git submodule:

- Prerequisites checklist
- 6-step conversion process
- Auto-sync behavior explanation
- Fresh clone instructions
- Integrations preserved verification
- Troubleshooting section
- Benefits summary

### 5. Updated Documentation

#### CLAUDE.md

1. **Key Commands section** — Added submodule note and manual update command:

   ```bash
   # OpenSpace — self-evolving skill system (CLI first, MCP backup)
   # Git submodule — auto-syncs with upstream every session via openspace-sync.sh hook
   
   # Submodule updates (automatic via stop hook, or manual)
   git submodule update --remote tools/openspace  # Manual: pull latest from upstream
   ```

2. **First-Time Setup section** — Updated step 2 description to mention submodule initialization

3. **Hooks section** — Updated table:
   - Stop hook now mentions both autoresearch-sync and openspace-sync
   - Added autoresearch-sync row
   - Added openspace-sync row

4. **Project Structure section** — Updated openspace/ entry:

   ```txt
   openspace/  ← Self-evolving skill system (git submodule — auto-syncs with upstream)
   ```

5. **Conversion guide reference** — Added note after First-Time Setup:
   > If you cloned OpenSpace before the submodule setup, see `.claude/docs/openspace-submodule-conversion.md`

#### README.md

1. **Quick Start section** — Updated step 15:
   > **Initializes OpenSpace submodule and installs** — checks if `tools/openspace/` is a git submodule and initializes it...

2. **Hooks & Scripts section** — Updated table:
   - Setup hook: now mentions "git submodules" in step list
   - Stop hook: now lists 4 steps (autoresearch sync, openspace sync, memory draft, doc-sync check)
   - Added openspace-sync row

3. **Hooks & Scripts section** — Updated stop.sh logic:

   ```text
   1. Autoresearch sync
   2. OpenSpace submodule sync
   3. Memory auto-draft
   4. Doc-sync check
   5. Always approves
   ```

4. **Project Structure section**:
   - Updated hooks/ section to include openspace-sync.sh
   - Updated openspace/ entry: `# Self-evolving skill system (git submodule → HKUDS/OpenSpace)`

5. **Conversion guide reference** — Added note after setup instructions with full description

---

## ✅ Integrations Verified — All Intact

| Integration | Status | Details |
| ------------- | -------- | --------- |
| **Environment** | ✅ Intact | `.env` has `OPENSPACE_HOST_SKILL_DIRS` and `OPENSPACE_WORKSPACE` |
| **VSCode Launch Configs** | ✅ Intact | 5 configs present: LightRAG Server, LightRAG Test Script, OpenSpace Backend Server, OpenSpace Frontend, OpenSpace Dashboard (Full Stack) |
| **Skills** | ✅ Intact | `.claude/skills/openspace/`, `.claude/skills/delegate-task/`, `.claude/skills/skill-discovery/` all present |
| **MCP Server** | ✅ Intact | `.mcp.json` has openspace config with env vars |
| **MCP Enabled** | ✅ Intact | `settings.json` has `"openspace"` in `enabledMcpjsonServers` |

---

## 🎯 Next Steps — Convert to Submodule

**IMPORTANT:** The infrastructure is ready, but the conversion hasn't been executed yet.

### Option 1: Hybrid Submodule + Auto-Sync (Recommended)

This is what you requested — git submodule with automatic upstream sync via hooks.

**Run these commands from the project root:**

```bash
# 1. Check for uncommitted changes in OpenSpace
cd tools/openspace
git status

# If you have uncommitted changes, either:
# - Commit them: git add . && git commit -m "Local changes before submodule conversion"
# - Stash them: git stash
# - Or back up: cd ../.. && cp -r tools/openspace tools/openspace-backup

# 2. Return to project root and remove the current OpenSpace directory
cd ../..
rm -rf tools/openspace

# 3. Add OpenSpace as a git submodule
git submodule add https://github.com/HKUDS/OpenSpace.git tools/openspace

# 4. Initialize and update the submodule
git submodule update --init --recursive tools/openspace

# 5. Commit the submodule configuration
git add .gitmodules tools/openspace
git commit -m "Convert OpenSpace to git submodule with auto-sync hook"

# 6. Verify the setup
git submodule status
ls -la tools/openspace/
cat .claude/hooks/openspace-sync.sh
```

### What Happens After Conversion

1. **Auto-sync every session** — `stop.sh` calls `openspace-sync.sh` at the end of every session
2. **Fresh clones work** — `setup.sh` auto-initializes the submodule for new team members
3. **Manual updates available** — You can still manually update with `git submodule update --remote tools/openspace`
4. **All integrations preserved** — Skills, MCP, launch configs, .env paths all work exactly as before

---

## 📋 Conversion Guide

For full step-by-step instructions with troubleshooting and examples, see:

**[`.claude/docs/openspace-submodule-conversion.md`](.claude/docs/openspace-submodule-conversion.md)**

---

## 🔧 How Auto-Sync Works

### Every Session End (via stop.sh)

1. **Check if submodule** — Verifies `.gitmodules` has `path = tools/openspace`
2. **Initialize if needed** — Runs `git submodule update --init --recursive` if not initialized
3. **Check for uncommitted changes** — Skips sync if you have local work in progress
4. **Fetch from upstream** — Runs `git fetch origin main` in the submodule
5. **Compare commits** — Checks if local commit matches remote
6. **Pull if behind** — Runs `git pull --ff-only` if updates are available
7. **Update parent repo** — Runs `git add tools/openspace` in the parent to track the new commit
8. **Silent if up-to-date** — No output if already on latest

### Fresh Clone (via setup.sh)

1. **Detect submodule** — Checks if `.gitmodules` has `tools/openspace` entry
2. **Initialize** — Runs `git submodule update --init --recursive tools/openspace`
3. **Install** — Proceeds with `pip install -e .` and frontend setup

---

## 🛡️ Safety Features

1. **Never overwrites uncommitted work** — Auto-sync skips if you have local changes
2. **Fast-forward only** — Won't pull if history diverged (prevents merge conflicts)
3. **Silent success** — Only shows output when changes are pulled
4. **Graceful fallback** — If submodule isn't configured, just proceeds with regular directory

---

## 🎓 Benefits of This Hybrid Approach

| Feature | Git Submodule | Auto-Sync Hook | Hybrid (Both) |
| --------- | --------------- | ---------------- | --------------- |
| Reproducible builds (pinned commits) | ✅ | ❌ | ✅ |
| Always up-to-date | ❌ | ✅ | ✅ |
| Safe updates (no overwrites) | ✅ | ✅ | ✅ |
| Fresh clone friendly | ✅ | ❌ | ✅ |
| Standard Git workflow | ✅ | ❌ | ✅ |
| Manual control (pin versions) | ✅ | ❌ | ✅ |
| Zero maintenance | ❌ | ✅ | ✅ |

---

## 📝 Summary

**What you asked for:**

- ✅ Git submodule setup (Option 1)
- ✅ Auto-sync via hooks (Option 2 as hybrid enhancement)
- ✅ All integrations preserved (skills, MCP, launch configs, .env)
- ✅ Documentation updated (CLAUDE.md, README.md)
- ✅ Conversion guide created

**What's ready to use:**

- ✅ `openspace-sync.sh` hook
- ✅ `setup.sh` submodule initialization
- ✅ `stop.sh` auto-sync call
- ✅ Full conversion guide
- ✅ Updated documentation

**What you need to do:**

- Run the 6 conversion commands above (or follow the full guide)
- Verify with `git submodule status`
- Test by running `bash .claude/hooks/openspace-sync.sh` manually
- Enjoy automatic upstream sync every session!

---

**File created:** `OPENSPACE_SUBMODULE_SETUP.md` (this file)  
**Conversion guide:** `.claude/docs/openspace-submodule-conversion.md`  
**Hook script:** `.claude/hooks/openspace-sync.sh`  
**Updated files:** `CLAUDE.md`, `README.md`, `setup.sh`, `stop.sh`
