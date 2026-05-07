---
name: openspace
description: Self-evolving skill system - skills that auto-fix, auto-improve, and auto-learn from usage. Provides collective intelligence where agents share improvements, 46% token reduction through skill evolution, and quality monitoring that tracks performance. Use for complex multi-step tasks, skill evolution, or accessing cloud skill community.
---

# OpenSpace: Self-Evolving Skill System

**What it does:** OpenSpace is a self-evolving engine that makes AI agents smarter and more cost-efficient. Skills automatically learn, fix themselves, and improve over time. One agent's improvement becomes every agent's upgrade through cloud skill sharing.

## Core Capabilities

### 🧬 Self-Evolution
- **AUTO-FIX** — When a skill breaks, it fixes itself instantly
- **AUTO-IMPROVE** — Successful patterns become better skill versions  
- **AUTO-LEARN** — Captures winning workflows from actual usage
- **Quality monitoring** — Tracks skill performance, error rates, execution success

### 🌐 Collective Intelligence
- **Shared evolution** — One agent's improvement becomes every agent's upgrade
- **Network effects** — More agents → richer data → faster evolution
- **Easy sharing** — Upload and download evolved skills with one command
- **Access control** — Public, private, or team-only access per skill

### 💰 Token Efficiency
- **46% fewer tokens** through skill reuse and evolution
- **4.2× better performance** on real-world professional tasks
- **Stop repeating work** → Reuse successful solutions
- **Small updates only** → Fix what's broken, don't rebuild everything

## CLI vs MCP: Token-Saving Priority

**ALWAYS try CLI first.** MCP tools consume tokens through protocol overhead; CLI calls via Bash are token-free beyond the command itself.

### Priority Order:

```
1. OpenSpace CLI → Direct Bash execution (token-free)
2. OpenSpace MCP → Protocol overhead (use when CLI insufficient)
```

### When to use CLI (Primary):
- ✅ Task execution: `openspace --query "task description"`
- ✅ Skill download: `openspace-download-skill <skill_id>`
- ✅ Skill upload: `openspace-upload-skill /path/to/skill/dir`
- ✅ Quick task execution without needing structured results back

### When to escalate to MCP (Backup):
- ⬆️ Need structured output parsed into conversation context
- ⬆️ Multi-step workflows where MCP state persistence helps
- ⬆️ Integration with other MCP tools in a single flow
- ⬆️ Automatic skill evolution tracking across tool calls
- ⬆️ Need result objects for conditional logic

**CLI saves ~200-500 tokens per call compared to MCP.** Over 20 OpenSpace calls, that's 4K-10K tokens saved.

## When to Use OpenSpace

**Use OpenSpace for:**
- ✅ **Complex multi-step tasks** that would benefit from evolved, battle-tested workflows
- ✅ **Repeated similar tasks** where skill evolution can save tokens over time
- ✅ **Tasks with unclear approaches** — OpenSpace can search and apply community skills
- ✅ **Skill evolution** — automatically fix broken skills or derive improved versions
- ✅ **Knowledge sharing** — upload successful patterns or download community skills

**Don't use OpenSpace for:**
- ❌ Simple one-off tasks with clear solutions
- ❌ Tasks that already have well-defined local skills
- ❌ Quick reads, simple calculations, or trivial operations

## CLI Commands (Use These First)

OpenSpace provides a standalone CLI for token-free execution:

```bash
# Execute a task
openspace --query "Create a monitoring dashboard for Docker containers"

# Download a skill from cloud
openspace-download-skill <skill_id>

# Upload a skill to cloud
openspace-upload-skill /path/to/skill/dir

# Local dashboard (optional)
openspace-dashboard --port 7788
```

**CLI examples:**

```bash
# Task execution
openspace --query "Generate a Python script to process CSV files"

# Download and use community skill
openspace-download-skill sk_abc123xyz
```

**Search is MCP-only** — use `mcp__openspace__search_skills` tool:

```python
# Search via MCP tool (not CLI)
mcp__openspace__search_skills(
    query="csv processing",
    source="all",  # local + cloud
    limit=10
)
```

## Available MCP Tools (Use as Backup)

OpenSpace exposes 4 MCP tools via the `openspace` MCP server when CLI is insufficient:

### 1. `mcp__openspace__execute_task`
Execute complex tasks through OpenSpace's grounding agent with automatic skill evolution.

**Parameters:**
- `task` (required) — Task description in natural language
- `max_iterations` (optional, default: 20) — Maximum reasoning loops
- `search_scope` (optional, default: "all") — "local", "cloud", or "all"

**When to use:**
- Multi-step tasks requiring tool orchestration
- Tasks that might benefit from evolved skills
- Complex workflows that Claude Code struggles with

**Returns:**
- `response` — Task result/summary
- `evolved_skills` — List of skills that evolved during execution (FIX/DERIVED/CAPTURED)
- `status` — "completed" or "failed"

### 2. `mcp__openspace__search_skills`
Search for skills in local registry and cloud community.

**Parameters:**
- `query` (required) — Search query (natural language or keywords)
- `scope` (optional, default: "all") — "local", "cloud", or "all"
- `top_k` (optional, default: 5) — Number of results to return

**When to use:**
- Before starting a complex task — check if community skills exist
- Discovering reusable patterns for common workflows
- Finding specialized skills for specific domains

**Returns:**
- List of matching skills with:
  - `name` — Skill name
  - `description` — What it does
  - `source` — "local" or "cloud"
  - `skill_id` — Unique identifier (for cloud skills)

### 3. `mcp__openspace__fix_skill`
Repair a broken or outdated skill.

**Parameters:**
- `skill_name` (required) — Name of the skill to fix
- `error_context` (optional) — Error message or failure context
- `suggestion` (optional) — Specific fix suggestion

**When to use:**
- A skill failed due to API changes or outdated instructions
- Tool behavior changed and skill needs updating
- You notice a skill producing incorrect results

**Returns:**
- `success` — Boolean indicating if fix succeeded
- `new_version` — Version number of the fixed skill
- `diff` — Changes made to the skill

### 4. `mcp__openspace__upload_skill`
Upload a skill to the cloud community.

**Parameters:**
- `skill_dir` (required) — Path to skill directory
- `visibility` (optional, default: "private") — "public", "private", or "group"
- `group_id` (optional) — Group ID for group-only sharing

**When to use:**
- You've created or evolved a valuable skill worth sharing
- You want to back up a skill to the cloud
- Sharing skills within a team/group

**Requires:** `OPENSPACE_API_KEY` in environment

**Returns:**
- `skill_id` — Cloud skill identifier
- `url` — Skill URL on open-space.cloud

## Host Skills Integration

Two host skills are automatically installed to `.claude/skills/`:

### 1. **delegate-task** 
Teaches Claude Code when and how to delegate complex tasks to OpenSpace.

**Teaches:**
- When to use `execute_task` vs handling directly
- How to interpret OpenSpace results
- When to trigger skill evolution (`fix_skill`)
- How to upload successful patterns (`upload_skill`)

### 2. **skill-discovery**
Teaches Claude Code how to search and discover skills before starting work.

**Teaches:**
- When to search for skills (before complex tasks)
- How to evaluate search results (local vs cloud)
- Decision: follow skill yourself, delegate to OpenSpace, or skip
- How to import cloud skills to local registry

## Skill Evolution Modes

OpenSpace evolves skills in three ways:

### 🔧 FIX
Repairs broken or outdated instructions in-place. Same skill, new version.

**Triggers:**
- Skill execution failure
- Tool degradation (success rate drops)
- API/tool behavior changes

### 🚀 DERIVED
Creates enhanced or specialized versions from parent skills. New skill directory.

**Triggers:**
- Successful pattern improvement opportunity
- Specialization for specific use case
- Combination of multiple complementary skills

### ✨ CAPTURED
Extracts novel reusable patterns from successful executions. Brand new skill.

**Triggers:**
- Novel workflow emerges from multi-step execution
- Repeatable pattern identified across tasks
- Successful recovery strategy worth preserving

## Environment Configuration

**Required:**
- Python 3.12+
- `pip install -e tools/openspace` (auto-handled by setup.sh)

**Optional:**
- `OPENSPACE_API_KEY` — Cloud skill access (register at https://open-space.cloud)
- `OPENSPACE_WORKSPACE` — Custom workspace path (default: `tools/openspace`)
- `OPENSPACE_DEBUG` — Enable debug logging

**LLM credentials auto-detected from:**
1. Provider-native env vars (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.)
2. OPENSPACE_LLM_* overrides (if needed)

## Workflow Example

**Before OpenSpace:**
```
User: "Create a monitoring dashboard for Docker containers"
Claude: [Reasons from scratch, writes code, debugs, 50K tokens]
```

**With OpenSpace:**
```
User: "Create a monitoring dashboard for Docker containers"
Claude: [Searches skills via skill-discovery]
  → Found: docker-monitoring, dashboard-layout-v3, data-polling
  → Delegates to execute_task
OpenSpace: [Applies evolved skills, auto-fixes issues, 27K tokens]
  → Returns: Working dashboard
  → CAPTURED: docker-stats-api-fallback (new skill)
```

**Next similar task:**
```
User: "Create a monitoring dashboard for system processes"
Claude: [Searches skills]
  → Found: docker-stats-api-fallback (from previous task)
  → DERIVED: process-stats-api (specialized version)
OpenSpace: [Applies derived skill, 15K tokens]
```

## Quality Monitoring

OpenSpace tracks:
- **Skill metrics** — Applied rate, completion rate, effective rate, fallback rate
- **Tool metrics** — Success rate, latency, flagged issues
- **Code execution** — Status, error patterns

**Auto-triggers evolution when:**
- Tool success rates drop below threshold
- Skill completion rates decline
- Error patterns emerge across multiple executions
- Manual evolution requested via `fix_skill`

## Cloud Skill Community

**Browse:** https://open-space.cloud (no account needed)

**Register:** Get `OPENSPACE_API_KEY` to:
- Upload evolved skills (public/private/group)
- Access private/group skills
- Track skill lineage and evolution
- View performance metrics

**CLI tools:**
```bash
# Download a skill from cloud
openspace-download-skill <skill_id>

# Upload a skill to cloud
openspace-upload-skill /path/to/skill/dir
```

## Dashboard (Optional)

Local web UI to browse skills, track lineage, compare diffs.

**Requirements:** Node.js ≥ 20

**Start:**
```bash
# Terminal 1: Backend API
openspace-dashboard --port 7788

# Terminal 2: Frontend dev server
cd tools/openspace/frontend
npm install        # first time only
npm run dev
```

**Features:**
- Browse local and cloud skills
- View evolution lineage graphs
- Compare skill diffs between versions
- Track workflow session history
- Monitor skill performance metrics

## Troubleshooting

**"Missing environment variables"**
- Ensure LLM API key is set (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.)
- For cloud features, add OPENSPACE_API_KEY

**"Skill not found"**
- Check `search_scope` parameter (local/cloud/all)
- Verify skill was registered to local registry
- For cloud skills, ensure OPENSPACE_API_KEY is valid

**"Evolution failed"**
- Check execution logs in `tools/openspace/logs/`
- Verify skill directory structure (must have SKILL.md)
- Ensure diff-based patches are valid

**"MCP server timeout"**
- Increase `toolTimeout` in .mcp.json (default: 600s)
- Long evolutions may need 1200s+
- Check if evolution confirmation is hanging (requires user input)

## Performance Benchmarks

From GDPVal benchmark (50 professional tasks, 6 industries):

| Metric | Result |
|--------|--------|
| **Income vs Baseline** | 4.2× higher (same LLM) |
| **Token Reduction** | 46% fewer tokens (Phase 2 vs Phase 1) |
| **Quality Improvement** | +30pp above best baseline |
| **Value Capture** | 72.8% ($11,484 / $15,764) |

**Task categories improved:**
- Documents & Correspondence: +3.3pp quality, −56% tokens
- Compliance & Forms: +18.5pp quality, −51% tokens
- Media Production: +5.8pp quality, −46% tokens
- Engineering: +8.7pp quality, −43% tokens
- Spreadsheets: +7.3pp quality, −37% tokens
- Strategy & Analysis: +1.0pp quality, −32% tokens

**165 skills evolved** across benchmark, with most focusing on:
- File format I/O (44 skills)
- Execution recovery (29 skills)
- Document generation (26 skills)
- Quality assurance (23 skills)

## Source & Documentation

- **GitHub:** https://github.com/HKUDS/OpenSpace (13K+ stars)
- **Cloud Platform:** https://open-space.cloud
- **Full README:** `tools/openspace/README.md`
- **Config Guide:** `tools/openspace/openspace/config/README.md`
- **Benchmark Details:** `tools/openspace/gdpval_bench/README.md`

## Bottom Line

OpenSpace turns individual agent learning into collective intelligence. Every task makes every agent smarter and more cost-efficient. Skills evolve automatically, agents share improvements, and token costs drop over time.

Use it when the task is complex enough that evolved, battle-tested workflows will save time and tokens compared to reasoning from scratch.
