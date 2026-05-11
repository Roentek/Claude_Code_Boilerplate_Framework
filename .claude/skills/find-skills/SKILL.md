---
name: find-skills
description: |
  Inventory all currently installed skills and plugins. Shows what's in ~/.claude/skills/ (global) and .claude/skills/ (project), with descriptions from each SKILL.md. Cross-references with enabled plugins from settings.json. Use when you want to know what skills/plugins are available in the current environment.

  Triggers: "what skills do I have", "list my skills", "what plugins are installed", "show installed skills", "what commands are available", "/find-skills"
---

# Find Skills — Inventory

Show all installed skills and plugins in current environment.

## Step 1: List Global Skills

Read every `SKILL.md` in `~/.claude/skills/` and extract the `name` + first line of `description` from frontmatter.

```powershell
# PowerShell
Get-ChildItem "$env:USERPROFILE\.claude\skills" -Directory | ForEach-Object {
    $skill = $_.Name
    $skillmd = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $skillmd) {
        $content = Get-Content $skillmd -Raw
        if ($content -match 'name:\s*(.+)') { $name = $matches[1].Trim() } else { $name = $skill }
        Write-Output "  $name ($skill)"
    }
}
```

## Step 2: List Project Skills

Check `.claude/skills/` relative to current working directory:

```bash
# Bash
for dir in .claude/skills/*/; do
  skill=$(basename "$dir")
  if [ -f "$dir/SKILL.md" ]; then
    echo "  $skill"
  fi
done
```

## Step 3: Cross-Reference with Plugins

Read `.claude/settings.json` → `enabledPlugins` array and list enabled plugin names.

Use Read tool on `.claude/settings.json`, extract the `enabledPlugins` field.

## Step 4: Report

Present a clean table:

```
## Installed Skills

### Global (~/.claude/skills/)
| Skill | Description |
|-------|-------------|
| auto-stage-commit | Stage changes + generate commit message |
| ... | ... |

### Project (.claude/skills/) — only those NOT already in global
| Skill | Status |
|-------|--------|
| three-brain | ✓ in project, ✗ not yet in global (run setup.sh) |

## Enabled Plugins
- frontend-design
- ui-ux-pro-max
- ...

## Gaps
Skills in project but missing from global: [list]
Skills in global but not tracked in project: [list]
```

## Step 5: Flag Gaps

- Project skill NOT in global → "run `bash .claude/hooks/setup.sh` to sync"
- Global skill NOT in project `.claude/skills/` → "installed externally, not tracked by repo"
