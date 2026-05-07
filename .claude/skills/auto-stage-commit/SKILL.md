---
name: auto-stage-commit
description: Stages all changes and generates a lean Conventional Commits message via caveman-commit — user reviews and commits manually. Triggers on any commit intent: "commit", "stage my changes", "ready to push", "let's commit", "make a commit", "commit this", "push changes", "squash and commit", or any variation. Use whenever the user signals they're done with changes and ready to commit, even if they don't mention "message" or "caveman". Does NOT run git commit — outputs a ready-to-run command for the user to execute after review.
---

# Auto Stage + Commit Message

Stage all changes, then delegate message generation to the `caveman-commit` skill. Stop before committing.

## Workflow

### 1. Read the diff

```bash
git status
git diff HEAD
```

If changes are already staged, use `git diff --cached HEAD` instead.
For large diffs, `git diff --stat HEAD` is enough to infer the message.

### 2. Stage everything

```bash
git add -A
```

If the user specified particular files or exclusions, stage selectively instead.

### 3. Generate the commit message via caveman-commit

**Invoke the `caveman-commit` skill** to generate the message. Do not write your own message logic — caveman-commit is the user's preferred message format and contains the exact rules for this project.

Pass it the diff context from step 1 so it has full information about what changed.

caveman-commit will produce a Conventional Commits message with:
- Subject ≤50 chars, imperative mood, no trailing period
- Body only when the WHY is non-obvious
- No AI attribution, no "this commit does X"

### 4. Output

Show three things:

**Staged files** (run after `git add -A`):
```bash
git diff --cached --stat
```

**Commit message** (code block from caveman-commit output)

**Ready-to-run command:**
```bash
git commit -m "type(scope): summary"
# or with body:
git commit -m "type(scope): summary" -m "Body explaining why."
```

### 5. Stop

Do not run `git commit`. User inspects staged files and message, then runs the command themselves.

---

## Edge cases

| Situation | Action |
|-----------|--------|
| Nothing changed | Report "nothing to commit, working tree clean" and stop |
| Only untracked files | `git add -A` stages them — proceed normally |
| Submodule pointer changed | Stage it; caveman-commit will note it if it's the main change |
| Mixed concerns (many files) | Pass full diff to caveman-commit — it picks the dominant change and notes others in body |
| Already staged (user ran git add) | Skip `git add -A`; use what's staged; pass staged diff to caveman-commit |
