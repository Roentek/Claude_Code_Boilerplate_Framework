# 18 Token Management Hacks

> Source: AI Automation Society

---

## How Tokens Actually Work

A token is the smallest unit of text that an AI model reads and charges you for — roughly one token per word. Every time you send a message, Claude re-reads the entire conversation from the beginning. Message 1, its reply, message 2, its reply... all the way to your latest prompt. Every. Single. Time.

**Cost compounds, not adds.** Message 1 might cost 500 tokens. Message 30 costs 15,000+, because it's re-reading everything before it. One developer tracked a 100+ message chat: 98.5% of all tokens were spent re-reading old history. Only 1.5% went toward new output.

On top of your messages, Claude also re-loads your `CLAUDE.md` file, all connected MCP server tool definitions, system prompts, and referenced files on every single turn. This overhead is invisible but constant.

**Bloated context doesn't just cost more — it produces worse output.** Research on the "lost in the middle" phenomenon shows models pay less attention to content buried in long contexts. Keeping context tight isn't just a cost move. It's a quality move.

---

## Tier 1 Hacks

### 1. Start Fresh Conversations

Use `/clear` between unrelated tasks. Don't carry context about topic A into a conversation about topic B. Every message in a long chat is exponentially more expensive than the same message in a fresh chat. This single habit is the #1 thing that extends session life.

### 2. Disconnect MCP Servers

Every connected MCP server loads ALL its tool definitions into your context on EVERY message, even if you never touch it. One server alone = ~17,600 tokens per message. Run `/mcp` at the start of each session. Disconnect everything you won't use. Use CLIs instead.

### 3. Batch Prompts Into 1 Message

Three separate messages cost 3x what one combined message costs. Instead of "summarize this" → "now extract the issues" → "now suggest a fix", send it all in one prompt. If Claude gets something slightly wrong, **edit your original message and regenerate** instead of sending a follow-up correction. Follow-ups stack onto history permanently. Edits replace the bad exchange entirely.

### 4. Plan Mode Before Any Real Task

Claude maps out its approach and you approve before it writes a single line. Prevents the single biggest source of token waste: Claude going down the wrong path, writing code, then needing to undo and redo.

Add this to your `CLAUDE.md`:
> "Do not make any changes until you have 95% confidence in what you need to build. Ask me follow-up questions until you reach that confidence."

### 5. Run `/context` and `/cost`

`/context` shows you exactly what's eating your tokens right now: conversation history size, MCP overhead, loaded files, everything. `/cost` shows your actual token usage and estimated spend for the current session. Most people have no idea where their tokens are going. These two commands make the invisible visible. You can't fix what you can't see.

### 6. Set Up a Status Line

This sits in your terminal while you work. Without it, you can get deep into a coding session, feel productive, and then suddenly hit a wall because you burned through everything without realizing. Run `/statusline` to set it up.

### 7. Keep Your Dashboard Open

Monitor your usage dashboard for remaining allocation and reset time so you can make informed decisions about when to compact or clear.

### 8. Be Smart with Pasting

Before you drop a document, file, or error log into the chat, ask yourself: does Claude need the entire thing, or just one section? If the bug is in one function, paste that function. If the error is in the last 10 lines of a log, paste those 10 lines. Claude should be precise about what it reads, and you should be precise about what you feed it.

### 9. Watch Claude Work

Don't just fire off a prompt and walk away. Watch what Claude is doing, especially on longer tasks. Sometimes it gets stuck in its own loops — re-reading the same files, retrying the same approach, or exploring paths that clearly aren't going anywhere.

If you see it doing something unnecessary, stop it early. Hit Escape. You'll save every token it would have burned finishing a useless loop. In a bad loop, 80%+ of the tokens being used are producing zero value. A few seconds of attention can save thousands of tokens.

---

## Tier 2 Hacks

### 1. Lean `CLAUDE.md`

Place it in your project root. Claude auto-reads it at the start of every chat as system context. Keep it under 200 lines.

**Include:** your tech stack, coding conventions, build commands, the 95% confidence rule. Treat it like an index — route to where more data lives.

**Keep it lean and trim ruthlessly.** Every token in your `CLAUDE.md` loads on every single message, so a bloated one defeats its own purpose. Include only what Claude needs to avoid exploring or asking you about. Don't put your project's entire history or documentation that Claude can find by reading source files when needed.

### 2. Be Surgical with File References

- **Don't:** "Here's my whole repo, go find the bug."
- **Do:** "Check the `verifyUser` function inside `auth.js`."

Use `@filename` to point at specific files instead of letting Claude explore freely.

### 3. Compact at ~60% Capacity

Auto-compact triggers at ~95%, by which point your context is already degraded. Run `/context` to check your capacity percentage. At ~60%, run `/compact` with specific instructions on what to preserve. After 3–4 compacts in a row, quality starts to degrade. At that point, ask Claude to write a session summary and `/clear`.

### 4. Short Breaks Cost You

Claude Code uses prompt caching to avoid re-processing unchanged context. But **the cache has a 5-minute timeout**. After 5 minutes, your next message re-processes everything from scratch at full cost. This is why some people feel like their usage spikes "randomly" after pausing. If you're stepping away for more than a few minutes, consider doing a `/compact` or `/clear` before.

### 5. Command Output Bloat

When Claude runs shell commands, the full output enters your context window. A `git log` with 200 commits, a verbose test suite, a build log full of warnings... all tokens, all re-sent every turn after. Be intentional about what you let Claude run. Pipe long outputs through `head` or `tail`, or ask Claude to limit output before running a command.

This is one of those invisible token drains that people never think about because the output scrolls by and feels "free." It's not.

---

## Tier 3 Hacks

### 1. Pick the Right Model

| Model | Use Case | Cost |
| ------- | ---------- | ------ |
| **Sonnet** | Default for most coding work | Baseline |
| **Haiku** | Subagents, formatting, simple tasks | 3× cheaper than Sonnet |
| **Opus** | Deep architectural planning only — when Sonnet wasn't enough | Most expensive — keep under 20% of total usage |

### 2. Cost of Subagents

Agent workflows use roughly **7–10× more tokens** than a standard single-agent session. Delegate to subagents for one-off tasks that can use Haiku. Each subagent runs its own full context window as a separate Claude instance. Agent teams are very expensive.

### 3. Understand Peak Hours

Anthropic adjusts how fast your 5-hour session window drains based on demand:

- **Peak (drains faster):** 8 AM – 2 PM ET on weekdays
- **Off-peak (lasts longer):** Afternoons, evenings, weekends

Run your big refactors, multi-agent sessions, and codebase rewrites in the evenings or on weekends.

### 3.5. Play the Clock

If you're near a reset with room left in your allocation, go heavy. Run the big refactor, let the agents loose. Get your money's worth before it resets anyway.

If you're near your limit but the reset is only 30–45 minutes away, step away. Take a walk, grab a snack. Come back to a full budget instead of burning the last 5% on something small and getting stuck mid-task.

### 4. Your System's Constitution

Your `CLAUDE.md` should contain stable decisions, architecture rules, and progress summaries. Think of it as the source of truth that makes every future prompt shorter. Save decisions, not conversations. Every architectural call you store there is a paragraph you never have to type again.

Add context rules directly into it, like:
> "Use subagents for any exploration or research. If a task needs 3+ files or multi-file analysis, spawn a subagent and return only summarized insights."

This offloads decision-making from your prompts to your config.

---

## Your Action List

- [ ] Run `/context` and `/cost`
- [ ] Set up status line (shows model, context %, and token count)
- [ ] Open Claude usage dashboard (remaining allocation + reset time)
- [ ] Disconnect unused MCP servers via `/mcp`
- [ ] Start complex tasks in Plan Mode (Shift+Tab) before writing code
- [ ] Use `/clear` when switching to an unrelated task
- [ ] Manually `/compact` at ~60% context capacity
- [ ] Batch multi-step instructions into single messages
- [ ] Schedule heavy sessions for off-peak hours

---

## Bottom Line

Most people don't need a bigger plan. They need to stop re-sending their entire conversation history 30 times when they could send it 5 times. It's not a limits problem. It's a **context hygiene problem**.

The Tier 1 moves alone will make most people feel like they doubled their subscription.
