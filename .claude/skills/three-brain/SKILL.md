---
name: three-brain
description: |
  Auto-routes work to GPT-5.5 (Codex) or Gemini 2.5 Pro when the task fits their unique capabilities better than Claude alone. Claude stays the driver — the others are tools it calls.

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HARD RULE — THE NO-SELF-REVIEW LAW (READ THIS FIRST)
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  When the user asks Claude to "check / review / look over / proof / verify / audit / sanity-check / second-opinion" ANY work Claude (you) just produced — code, writing, plan, design, edit, anything — this is a MUST-FIRE situation. You MUST route to Codex.

  Claude reviewing Claude's own output is the exact failure mode this skill exists to prevent. Same architecture = same blind spots. A self-review catches nothing meaningful and defeats the entire purpose of the three-brain stack.

  Phrases that MUST trigger Codex review (not exhaustive):
  • "check over your work" / "check your work"
  • "review what you just did" / "review your code" / "review the code you wrote"
  • "look over this" / "give it a once-over" / "go over what you wrote"
  • "is this right?" / "is the code right?" / "anything wrong with this?"
  • "second opinion" / "sanity check" / "double-check" / "proof this"
  • "audit this" / "verify this" / "make sure this works"

  Do NOT silently self-review. Do NOT say "I'll review it inline." Route to Codex via Bash:
    git diff | codex exec --skip-git-repo-check "Review this. Find bugs, risks, missing tests."
  OR for un-tracked code, pipe the file content directly.

  After Codex returns, integrate findings into your reply. State at the end: "(Routed via three-brain → Codex review.)"

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FIRE THIS SKILL WHEN (full list):
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • [MUST-FIRE — see above] User asks to review/check/look-over ANY work Claude just produced → Codex review
  • User says "tear apart / sanity check / stress test / find what's wrong / break this / poke holes" → Codex adversarial review
  • User says "I'm stuck / can't figure this out / hand it off / try GPT" OR Claude has failed the same operation 2+ times in a row (same test fail, same error, same loop) → Codex rescue
  • Active edit touches a risky file path: src/auth/**, src/billing/**, **/migrations/**, **/deploy/**, **/.env*, **/secrets/**, **/policy/**, infra/**, payment/Stripe/Plaid integrations → forced Codex adversarial review BEFORE saying "done" (announce it visibly)
  • Message contains a video file (.mp4 .mov .webm .avi .mkv), audio file (.wav .mp3 .flac .m4a .ogg), PDF >50pg, or YouTube URL → Gemini multimodal (with preprocessing contract — see body)
  • User says "scan the whole repo / find every place X / pattern across the codebase / map the architecture" → Gemini 1M-context whole-repo scan
  • User explicitly invokes high-stakes consensus mode ("ask all three / get cross-architecture consensus / before I commit to this") → all three in parallel with structured output

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DO NOT FIRE FOR:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • "Explain / what is / how does / walk me through" → Claude direct
  • "Write / draft / create / build / make" on non-risky paths → Claude direct (but if user immediately says "now check over your work" — MUST-FIRE applies)
  • "Edit / change / update / refactor" on non-risky paths → Claude direct
  • "Plan / brainstorm / outline / design" on non-risky paths → Claude direct
  • "Review my notes / review my draft email / look at my Google Doc" — content the user wrote, not Claude → Claude direct (different from Claude's own code)
  • Conversational chat, status questions, file ops, git/bash/grep, normal Q&A → Claude direct

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  AMBIGUITY RULE — biased toward firing
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  When uncertain whether a phrase fires the skill on Claude's own work: FIRE IT. The cost of a 20-second Codex call is small. The cost of a self-review missing a real bug is huge. Bias toward firing on review verbs targeted at Claude's output. Bias toward staying asleep on review verbs targeted at user's own non-code content.

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  POSITIVE EXAMPLES (MUST FIRE):
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    "yo check over your work" → Codex review (MUST-FIRE)
    "review the code you just wrote" → Codex review (MUST-FIRE)
    "is this right?" (after Claude wrote code) → Codex review (MUST-FIRE)
    "tear this apart" → Codex adversarial review
    "is the auth flow right?" → Codex adversarial review (auth path = forced)
    "watch this clip and tell me what's interesting" + video → gemini @./file
    "I've tried this 3 times, you're not getting it" → Codex rescue
    "find every place we hit the Stripe API" → cc-gemini-plugin --dirs

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  NEGATIVE EXAMPLES (STAY ASLEEP):
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    "explain how MCP servers work" → Claude
    "refactor this CSS variable" (non-risky path) → Claude
    "write me a tweet about X" → Claude
    "review my draft email for tone" (user's content, not Claude's code) → Claude
    "look up what we decided about pricing" → recall skill, not three-brain
---

# Three-Brain Auto-Router

A single skill that routes work invisibly. Three brains, one terminal:

- **Claude** = builder, driver, IDE harness — stays in front of the user the whole time
- **Codex (GPT-5.5)** = reviewer, second brain, rescue
- **Gemini 2.5 Pro** = eyes, ears, long-context — handles anything Claude literally cannot see or hear

## Startup self-check (run once per session, before first route)

Before the first route fires in a session, verify the tooling. If anything's missing, announce it once, fall back gracefully, and don't retry every turn.

```bash
codex --version 2>&1 | head -1   # expect: codex-cli 0.125+
gemini --version 2>&1 | head -1  # expect: 0.39+
```

If `codex` is missing → Codex routes unavailable. Tell the user: *"Codex CLI not found — review/rescue routes off until installed."* Continue without those routes.

If `gemini` is missing → Gemini routes unavailable. Tell the user the same way. Continue without those routes.

## Announcement protocol (REQUIRED for all forced routes)

Whenever the skill fires a route the user did NOT explicitly request — i.e. **risk-path detection** or **failure-counter rescue** — announce it in **one line BEFORE running**. The user must be able to interrupt with one word.

Format:

```
[three-brain] routing to Codex (adversarial-review) — risk path: src/auth/
[three-brain] handing off to Codex rescue — Claude failed same test 2× in a row
```

For routes the user explicitly asked for ("yo check this") — no announcement needed. They asked, just do it.

## Failure-detection rule (HARD)

This is a deterministic counter, not a vibe. After Claude attempts the same operation and fails:

- **2× same test failure on same code path** → MUST invoke Codex rescue. Not optional. Announce it.
- **2× same error on same shell command** → MUST invoke Codex rescue. Announce it.
- **2× same edit re-tried with no progress** → MUST invoke Codex rescue. Announce it.

Reset the counter only when (a) the test/build passes, (b) the user changes the goal, or (c) the user explicitly says "keep trying."

When invoking rescue, send full context: the failing output, what's been tried, the relevant files. Use:

```bash
cat <context-bundle> | codex exec --skip-git-repo-check "rescue: [task]. Claude has tried 2x and failed. Full context attached."
```

## Gemini preprocessing contract

Long media must be prepped before sending to Gemini — raw 2-hour videos blow rate limits and produce noise.

**Video pipeline:**

```bash
# 1. Acquire (if YouTube URL)
yt-dlp -f "best[ext=mp4][height<=720]" "<url>" -o /tmp/three-brain/in.mp4

# 2. Cap duration (default: 120s for demos, 600s for analysis)
ffmpeg -t 120 -i /tmp/three-brain/in.mp4 /tmp/three-brain/clip.mp4 -y

# 3. Extract audio for transcript (parallel track)
ffmpeg -i /tmp/three-brain/clip.mp4 -vn -ac 1 -ar 16000 /tmp/three-brain/audio.wav -y

# 4. Send with explicit ask for TIMESTAMPED findings
gemini -p "Analyze frame-by-frame. Return findings as a timestamped list: [MM:SS] event. Cover: graphics, lower-thirds, transitions, on-screen text, speaker actions. Cap output at 800 words." @/tmp/three-brain/clip.mp4
```

**Audio pipeline:** same as above without the video step.

**PDF pipeline:**

```bash
# Cap page count for very long docs
qpdf --pages input.pdf 1-100 -- /tmp/three-brain/doc.pdf 2>/dev/null || cp input.pdf /tmp/three-brain/doc.pdf

gemini -p "Extract: key claims, data tables, chart findings, page-numbered. Cap at 1000 words." @/tmp/three-brain/doc.pdf
```

**Whole-codebase scan:**

```bash
# Use the plugin which handles directory packaging
/cc-gemini-plugin:gemini --dirs <comma-separated-paths> "Find every place X. Return file:line list."
```

Always demand **timestamps, page numbers, or file:line citations** in the output — don't accept a flat summary.

## Risk-path detection (path-based, not keyword-based)

Codex's review is forced — without the user asking — when an active edit touches any of these:

```
src/auth/**          # authentication flows
src/billing/**       # payments, subscriptions
**/migrations/**     # DB schema changes
**/deploy/**         # deployment scripts
**/.env*             # env handling
**/secrets/**        # credentials
**/policy/**         # ACLs, permissions
infra/**             # Terraform, k8s, IaC
**/Stripe* **/Plaid* # payment integrations
**/jwt* **/oauth*    # token handling
```

Keywords alone (auth, payments, prod) in casual chat do NOT trigger forced review — it has to be an active edit on the file paths.

This avoids false positives on docs/comments/test fixtures, and false negatives on code that uses domain names like `billingFlow` or `policy.ts` instead of generic words.

## Risk-by-reversibility rule

Even task verbs that normally don't fire (refactor/plan/explain/design) DO fire if the target is irreversible or high-blast-radius:

- "Refactor the auth middleware" → fires Codex review (auth path)
- "Plan the Stripe migration" → fires Codex review (billing + migration path)
- "Design the deployment pipeline" → fires Codex review (deploy path)

Verb is irrelevant if the target is risky.

## Parallel consensus mode (high-stakes)

Only when explicitly invoked: *"ask all three / before I commit to this / cross-architecture consensus."*

All three answer the SAME question. Claude does not summarize a vibe-consensus — it forces structured output:

```
Recommendation: <one line>
Blocking risks: <bullet list>
Assumptions: <bullet list>
Confidence: low / medium / high
Tests required to verify: <bullet list>
```

Each model returns this template. Claude diffs them: where they agree, where they disagree, and adjudicates *by evidence*, not by averaging.

## Output filing

Anything the skill produces goes to `./three-brain-out/<YYYY-MM-DD>-<slug>/`:

```
./three-brain-out/2026-04-27-alex-graphic/
  ├── input.txt          # what the user asked
  ├── gemini-analysis.md # Gemini's output
  ├── claude-build.html  # what Claude built
  ├── codex-review.md    # Codex's review
  └── log.md             # one-line summary, dated
```

Append to `./three-brain-out/log.md` (root-level) every time the skill runs:

```
[2026-04-27 16:24] route=video-build target=alex-clip duration=187s files=4
```

That's the compounding ledger.

## Calling pattern (Bash, since slash commands aren't issuable from inside a skill)

```bash
# Codex review
git diff | codex exec --skip-git-repo-check "Review this diff. Flag bugs, risks, missing tests. Be specific."

# Codex adversarial
git diff | codex exec --skip-git-repo-check "Adversarial review. Challenge the design. Find what's wrong. Prove it's broken."

# Codex rescue
cat <bundle> | codex exec --skip-git-repo-check "Rescue mode. Claude tried 2x and failed. Solve it from scratch."

# Gemini multimodal
gemini -p "<focused ask with output format>" @./file

# Gemini whole-codebase
/cc-gemini-plugin:gemini --dirs <paths> "<focused question>"
```

Prefer the plugin slash commands (`/codex:review`, etc.) when the calling context is interactive — they have prompt engineering baked in. Fall back to the raw CLI when the slash commands are not available or when piping context.

## Stay-asleep rules (explicit)

Do not fire on:
- Casual conversation, greetings, status checks
- Any question Claude can answer directly without external help
- "Recall / what did we decide / look up" → that's the `recall` skill's job
- "Save this / wrap up / log this" → that's `wrap-up`'s job
- "What's my strategy on X" → that's `strategy-awareness`
- Any task already in another skill's territory

When uncertain: **stay asleep**. Under-firing is fine. Over-firing breaks trust.
