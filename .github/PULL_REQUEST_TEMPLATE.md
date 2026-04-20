# Summary

<!-- One or two sentences describing what this PR does and why. -->

## Type of change

- [ ] Feature
- [ ] Bug fix
- [ ] Refactor / cleanup
- [ ] Docs
- [ ] Boilerplate sync (automated)
- [ ] Infra / config / CI
- [ ] Other:

## Related

<!-- Link issues, tickets, or upstream PRs. Use "Closes #123" to auto-close issues on merge. -->

## Changes

<!-- Bullet list of the meaningful changes in this PR. -->
-
-
-

## Screenshots / recordings

<!-- For UI changes, attach before/after screenshots or a short Loom. Delete if N/A. -->

## How to test

<!-- Step-by-step so a reviewer can verify locally. Include URLs, commands, seed data, or test users. -->
1.
2.
3.

## Checklist

- [ ] Code follows the workspace coding standards (TypeScript strict, Tailwind only, no `any`, no `console.log`)
- [ ] Dark mode and light mode both verified (if UI)
- [ ] Mobile (375px), tablet (768px), and desktop (1280px) verified (if UI)
- [ ] Accessibility: semantic HTML, keyboard nav, ARIA on icon-only buttons
- [ ] No secrets, API keys, or `.env` values committed
- [ ] RLS policies reviewed for any new Supabase tables/columns
- [ ] Migrations are additive and reversible (if applicable)
- [ ] Tests / manual verification completed
- [ ] Documentation updated (`README.md`, `CLAUDE.md`, `/workflows`, or relevant skill)

## Boilerplate sync notes

<!-- Only fill out if this PR was opened by the weekly sync-boilerplate Supabase edge function. -->
- Source repo: `Roentek/Claude_Code_Boilerplate_Framework`
- Branch: `boilerplate-sync/YYYYMMDD`
- Auto-merged via REST API squash-merge after creation

### SYNC_PATHS — LOCKED (do not modify)

Only these paths are synced from the boilerplate upstream:

| Path | Reason |
| --- | --- |
| `.claude/` | Claude Code rules, hooks, skills, agents |
| `workflows/` | Automation SOPs |
| `tools/` | Deterministic Python scripts |
| `brand_assets/` | Shared design tokens |
| `CLAUDE.md` | Root instruction file |
| `.mcp.json` | MCP server definitions |

### Never sync — owned by lovable.dev or project-specific

These files are managed by **lovable.dev** or carry per-project customizations. Syncing them would destroy project state:

`README.md` · `LICENSE` · `.env.example` · `.gitignore` · `.gitattributes` · `CODEOWNERS` · `.github/PULL_REQUEST_TEMPLATE.md`

> If any of these appear in a sync PR diff, **reject the PR immediately** and fix the edge function's `SYNC_PATHS` config.
