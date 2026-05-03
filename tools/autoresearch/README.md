# AutoResearch - Autonomous ML Research

> **Source:** [karpathy/autoresearch](https://github.com/karpathy/autoresearch) (33K+ stars)

Autonomous AI-driven machine learning research. An agent modifies training code, runs 5-minute experiments, evaluates improvements, and iterates without human intervention.

## What It Does

AutoResearch enables AI agents to conduct autonomous machine learning research overnight. The agent:

- Modifies GPT training code (`train.py`)
- Runs 5-minute experiments on a single GPU
- Checks if results improved (lower `val_bpb` = better)
- Keeps improvements, discards failures
- Repeats autonomously (~12 experiments/hour, ~100 while you sleep)

## Quick Start

**Requirements:**

- Single NVIDIA GPU (tested on H100, see Platform Support below for other platforms)
- Python 3.10+
- `uv` package manager (auto-installed by setup.sh)

```bash
# 1. First-time setup runs automatically via setup.sh, or manually:
cd tools/autoresearch
uv sync    # Downloads PyTorch and ML dependencies (may take 5-10 minutes)

# 2. Verify dependencies are installed correctly:
uv run python verify_setup.py

# 3. Download data and train tokenizer (one-time, ~2 min)
uv run prepare.py

# 4. Manually run a single training experiment (~5 min)
uv run train.py

# 5. Start autonomous research (via Claude Code)
# Open this directory in Claude Code and use /autoresearch skill, or prompt:
# "Hi have a look at program.md and let's kick off a new experiment! let's do the setup first."
```

## File Structure

| File | Purpose | Editable By |
| ------ | --------- | ------------- |
| `prepare.py` | Fixed constants, data prep, tokenizer, dataloader, evaluation | Read-only |
| `train.py` | GPT model, optimizer, training loop | **Agent modifies** |
| `program.md` | Agent instructions and research context | **Human edits** |
| `pyproject.toml` | Dependencies | Read-only |
| `results.tsv` | Experiment log (auto-generated, git-ignored) | Agent writes |

## How It Works

**Fixed 5-minute time budget** per experiment (wall clock, excluding startup).
**Metric: val_bpb** (validation bits per byte) — lower is better.

The agent:

1. Creates a branch `autoresearch/<tag>` (e.g., `autoresearch/mar5`)
2. Modifies `train.py` with experimental ideas
3. Commits the change
4. Runs `uv run train.py > run.log 2>&1`
5. Extracts `val_bpb` from logs
6. If improved → keeps commit; if not → reverts
7. Logs to `results.tsv`
8. Repeats indefinitely until stopped

## Platform Support

### NVIDIA GPU (Default)

This code is optimized for single NVIDIA GPU (H100 tested).

### Other Platforms (Community Forks)

For CPU, MacOS, Windows, or AMD:

- [miolini/autoresearch-macos](https://github.com/miolini/autoresearch-macos) (MacOS)
- [trevin-creator/autoresearch-mlx](https://github.com/trevin-creator/autoresearch-mlx) (MacOS)
- [jsegov/autoresearch-win-rtx](https://github.com/jsegov/autoresearch-win-rtx) (Windows)
- [andyluo7/autoresearch](https://github.com/andyluo7/autoresearch) (AMD)

### Tuning for Smaller Compute

If running on smaller hardware (not H100), see the README recommendations:

1. Use smaller dataset (e.g., TinyStories)
2. Lower `vocab_size` in `prepare.py`
3. Lower `MAX_SEQ_LEN` (down to 256 for very small compute)
4. Increase `DEVICE_BATCH_SIZE` slightly to compensate
5. Decrease `EVAL_TOKENS`
6. Lower `DEPTH` in `train.py` (from 8 to 4 for small models)
7. Use `WINDOW_PATTERN = "L"` instead of `"SSSL"`
8. Lower `TOTAL_BATCH_SIZE` (down to `2**14` or ~16K)

## Design Principles

- **Single file to modify** — Agent only edits `train.py` (keeps scope manageable)
- **Fixed time budget** — 5 minutes per run makes experiments directly comparable
- **Self-contained** — No external dependencies beyond PyTorch, single GPU, one metric
- **Simplicity criterion** — All else equal, simpler is better. Don't add complexity for tiny gains.

## Experiment Loop

The agent runs this loop forever (until manually stopped):

1. Review current git state
2. Modify `train.py` with an experimental idea
3. Commit the change
4. Run experiment: `uv run train.py > run.log 2>&1`
5. Extract results: `grep "^val_bpb:\|^peak_vram_mb:" run.log`
6. Log to `results.tsv` (tab-separated, NOT CSV)
7. If improved → advance branch (keep commit)
8. If not improved → `git reset` (discard)
9. Repeat

**Timeout:** If run exceeds 10 minutes, kill it and treat as failure.
**Crashes:** Fix if trivial (typo), otherwise skip and log as "crash".
**Never stop:** Agent runs indefinitely until manually interrupted.

## Example Results Log

`results.tsv` format (tab-separated):

```tsv
commit	val_bpb	memory_gb	status	description
a1b2c3d	0.997900	44.0	keep	baseline
b2c3d4e	0.993200	44.2	keep	increase LR to 0.04
c3d4e5f	1.005000	44.0	discard	switch to GeLU activation
d4e5f6g	0.000000	0.0	crash	double model width (OOM)
```

## Integration with Claude Code Boilerplate

- **Skill:** `/autoresearch` at `.claude/skills/autoresearch/SKILL.md`
- **Setup:** Auto-installed via `setup.sh` (step 13)
- **Permissions:** `Bash(uv *)` and `PowerShell(uv *)` added to `settings.json`
- **Location:** `autoresearch/` directory in project root

## License

MIT (inherited from karpathy/autoresearch)

## Additional Resources

- Original announcement: [Tweet 1](https://x.com/karpathy/status/2029701092347630069), [Tweet 2](https://x.com/karpathy/status/2031135152349524125)
- ["Dummy's Guide" to neural networks](https://x.com/hooeem/status/2030720614752039185)
- Parent project: [nanochat](https://github.com/karpathy/nanochat)
