---
name: autoresearch
description: Autonomous ML research - agent modifies GPT training code, runs 5-min experiments, keeps improvements
---

# AutoResearch - Autonomous ML Research Agent

**Use when:** User wants to run autonomous machine learning experiments, optimize neural network training, or conduct overnight research runs.

**Source:** [karpathy/autoresearch](https://github.com/karpathy/autoresearch) (33K+ stars)

## What This Does

AutoResearch enables autonomous AI-driven machine learning research. You (the agent) modify GPT training code, run 5-minute experiments on a GPU, evaluate improvements, and iterate without human intervention. The human can leave you running overnight for ~100 experiments while they sleep.

## Core Concept

- **You modify:** `train.py` (model architecture, optimizer, hyperparameters, training loop)
- **You don't touch:** `prepare.py` (data prep, tokenizer, evaluation — read-only)
- **You edit for human:** `program.md` (your instructions — human can update to guide research direction)
- **Metric:** `val_bpb` (validation bits per byte) — **lower is better**
- **Fixed time budget:** 5 minutes per experiment (wall clock, excluding startup)

## Quick Start (First Time)

When user says to start autoresearch, verify setup first:

```bash
# 1. Navigate to autoresearch directory
cd tools/autoresearch

# 2. Check if data exists
ls ~/.cache/autoresearch/

# If missing, run data prep (one-time, ~2 min):
uv run prepare.py

# 3. Test baseline run (~5 min)
uv run train.py
```

## Experiment Setup

Before starting the autonomous loop, work with the user to:

1. **Agree on a run tag** based on today's date (e.g., `may3`, `may3-gpu0`)
   - Branch name: `autoresearch/<tag>`
   - Branch must NOT already exist (this is a fresh run)

2. **Create the branch:**
   ```bash
   git checkout -b autoresearch/<tag>
   ```

3. **Read in-scope files** for full context:
   - `README.md` (repo overview)
   - `prepare.py` (fixed constants, evaluation harness)
   - `train.py` (what you'll modify)
   - `program.md` (your instructions)

4. **Initialize results log:**
   ```bash
   echo -e "commit\tval_bpb\tmemory_gb\tstatus\tdescription" > results.tsv
   ```

5. **Run baseline** (unchanged `train.py`):
   ```bash
   uv run train.py > run.log 2>&1
   grep "^val_bpb:\|^peak_vram_mb:" run.log
   ```

6. **Log baseline to results.tsv**

7. **Confirm with user** before starting the autonomous loop

## The Autonomous Loop

**CRITICAL:** Once the loop starts, **NEVER STOP** unless the user manually interrupts you. Do NOT ask "should I continue?" — the user might be asleep. You run indefinitely.

### Loop Steps (Repeat Forever)

1. **Review state:** Check current branch/commit
2. **Ideate:** Pick an experimental idea (architecture change, optimizer tweak, hyperparameter adjustment, etc.)
3. **Modify:** Edit `train.py`
4. **Commit:**
   ```bash
   git add train.py
   git commit -m "experiment: [short description]"
   ```
5. **Run experiment:**
   ```bash
   uv run train.py > run.log 2>&1
   ```
6. **Extract results:**
   ```bash
   grep "^val_bpb:\|^peak_vram_mb:" run.log
   ```
7. **Check status:**
   - If grep output is empty → run crashed → read `tail -n 50 run.log` for stack trace
   - If trivial fix (typo, missing import) → fix and re-run
   - If fundamental issue → skip, log as "crash", move on
8. **Log to results.tsv:**
   ```tsv
   [commit_hash]	[val_bpb]	[memory_gb]	[status]	[description]
   ```
   - `commit`: 7-char short hash
   - `val_bpb`: 6 decimal places (e.g., 0.997900), or 0.000000 for crashes
   - `memory_gb`: peak VRAM in GB, rounded to .1f (divide `peak_vram_mb` by 1024), or 0.0 for crashes
   - `status`: `keep`, `discard`, or `crash`
   - `description`: short text (NO COMMAS — tab-separated format)
9. **Decide:**
   - If `val_bpb` **improved** (lower) → **keep** commit, advance branch
   - If `val_bpb` equal or worse → **discard** via `git reset --hard HEAD~1`
10. **Repeat** from step 1

### Timeout Handling
- Each run should take ~5 minutes + overhead (~6-7 min total)
- If run exceeds **10 minutes**, kill it and treat as failure (discard)

### Simplicity Criterion
All else being equal, **simpler is better**:
- A 0.001 val_bpb improvement that adds 20 lines of hacky code? **Probably not worth it.**
- A 0.001 val_bpb improvement from **deleting** code? **Definitely keep.**
- Improvement of ~0 but much simpler code? **Keep** (simplification win).

## What You CAN Modify

In `train.py`, everything is fair game:
- Model architecture (depth, width, attention patterns)
- Optimizer (Muon, AdamW, learning rate, warmup, decay)
- Hyperparameters (batch size, gradient accumulation)
- Training loop (mixed precision, gradient clipping, etc.)

## What You CANNOT Do

- Modify `prepare.py` (it's read-only)
- Install new packages or change dependencies
- Modify the evaluation harness (`evaluate_bpb` function)
- Change the 5-minute time budget

## VRAM Constraint

VRAM is a **soft constraint**:
- Some increase is acceptable for meaningful val_bpb gains
- Don't blow it up dramatically
- If OOM crash → log as "crash" and try something smaller

## Expected Throughput

- ~12 experiments per hour (~5 min each)
- ~100 experiments over 8 hours of sleep
- User wakes up to a full log of results and (hopefully) a better model

## Results Format

**Example output from a run:**
```
---
val_bpb:          0.997900
training_seconds: 300.1
total_seconds:    325.9
peak_vram_mb:     45060.2
mfu_percent:      39.80
total_tokens_M:   499.6
num_steps:        953
num_params_M:     50.3
depth:            8
```

**Example results.tsv:**
```tsv
commit	val_bpb	memory_gb	status	description
a1b2c3d	0.997900	44.0	keep	baseline
b2c3d4e	0.993200	44.2	keep	increase LR to 0.04
c3d4e5f	1.005000	44.0	discard	switch to GeLU activation
d4e5f6g	0.000000	0.0	crash	double model width (OOM)
```

## Platform Support

**Default:** Single NVIDIA GPU (tested on H100)

**Other platforms:** See community forks in [tools/autoresearch/README.md](../../../tools/autoresearch/README.md):
- MacOS: miolini/autoresearch-macos, trevin-creator/autoresearch-mlx
- Windows: jsegov/autoresearch-win-rtx
- AMD: andyluo7/autoresearch

**Smaller compute tuning:** See [tools/autoresearch/README.md](../../../tools/autoresearch/README.md) for hyperparameter recommendations (TinyStories dataset, lower vocab_size, MAX_SEQ_LEN, DEPTH, etc.)

## Key Commands

```bash
# Navigate to autoresearch
cd tools/autoresearch

# Install dependencies (first time)
uv sync

# Data prep (one-time)
uv run prepare.py

# Run single experiment
uv run train.py

# Run with log capture
uv run train.py > run.log 2>&1

# Extract results
grep "^val_bpb:\|^peak_vram_mb:" run.log

# Read error trace
tail -n 50 run.log

# Check git state
git log --oneline -n 10

# Discard failed experiment
git reset --hard HEAD~1
```

## Integration Notes

- **Location:** `tools/autoresearch/` directory
- **Setup:** Auto-installed via `setup.sh` step 13
- **Permissions:** `Bash(uv *)` and `PowerShell(uv *)` in `settings.json`
- **Files tracked:** `prepare.py`, `train.py`, `program.md`, `pyproject.toml`, `uv.lock`
- **Files git-ignored:** `results.tsv`, data cache (`~/.cache/autoresearch/`)

## Usage Example

**User:** "Run autoresearch overnight on the baseline GPT model"

**You:**
1. `cd tools/autoresearch`
2. "Let's set up a new run. I propose the tag `may3`. Creating branch `autoresearch/may3`..."
3. `git checkout -b autoresearch/may3`
4. Read `prepare.py`, `train.py`, `program.md`, `README.md`
5. Check if data exists: `ls ~/.cache/autoresearch/`
6. If missing: `uv run prepare.py`
7. Initialize `results.tsv` with header
8. Run baseline: `uv run train.py > run.log 2>&1`
9. Extract results and log to `results.tsv`
10. "Baseline is logged. Starting autonomous research loop. I'll run experiments until you stop me."
11. **LOOP FOREVER:** ideate → modify → commit → run → evaluate → keep/discard → repeat

## Remember

- **Never stop** unless manually interrupted
- **Never ask** "should I continue?" mid-loop
- **Always log** every experiment to `results.tsv`
- **Simplicity matters** — don't add complexity for tiny gains
- **VRAM is soft** — some increase OK, but don't blow it up
- **Fixed 5-min budget** — experiments are always comparable
- **Lower val_bpb = better** — that's the only metric that matters
