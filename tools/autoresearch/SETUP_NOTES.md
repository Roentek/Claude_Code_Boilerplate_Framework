# AutoResearch Setup Notes

## Automatic Installation

The `setup.sh` script (step 13) automatically runs `uv sync` to install all Python dependencies. However, this can take **5-10 minutes** due to the large PyTorch download (~2-3 GB).

## Manual Installation

If you need to install or reinstall dependencies manually:

```bash
cd tools/autoresearch
uv sync
```

**Note:** The first run downloads:

- PyTorch 2.9.1 with CUDA 12.8 support (~2-3 GB)
- NumPy, Pandas, Matplotlib, and other ML libraries
- Total download size: ~3-4 GB

## Verification

After `uv sync` completes, verify all dependencies are installed:

```bash
cd tools/autoresearch
uv run python verify_setup.py
```

Expected output:

```text
============================================================
AutoResearch Dependency Verification
============================================================

Python version: 3.10.20 ...

✓ Python version OK (>= 3.10)

Checking dependencies:
------------------------------------------------------------
✓ PyTorch              version 2.9.1
✓ NumPy                version 2.2.6
✓ Pandas               version 2.3.3
✓ Matplotlib           version 3.10.8
✓ PyArrow              version 21.0.0
✓ Requests             version 2.32.0
✓ TikToken             version 0.11.0

============================================================
✓ All dependencies installed successfully!
```

## Troubleshooting

### uv sync fails or hangs

**Problem:** `uv sync` takes too long or appears frozen

**Solution:**

- This is normal for the first install (PyTorch is large)
- Wait 5-10 minutes for download to complete
- If it truly hangs, press Ctrl+C and retry

### Import errors after uv sync

**Problem:** `verify_setup.py` shows modules not found

**Solution:**

```bash
# Remove the virtual environment and reinstall
cd tools/autoresearch
rm -rf .venv
uv sync
```

### PyTorch GPU detection issues

**Problem:** torch.cuda.is_available() returns False

**Solution:**

- Check that you have an NVIDIA GPU with CUDA drivers installed
- Verify CUDA version matches (CUDA 12.8 expected)
- See community forks in README.md for CPU/MacOS/AMD alternatives

## Next Steps After Successful Installation

Once `verify_setup.py` passes:

1. **Download training data** (~2 minutes):

   ```bash
   uv run prepare.py
   ```

2. **Test baseline run** (~5 minutes):

   ```bash
   uv run train.py
   ```

3. **Start autonomous research**:
   - Use `/autoresearch` skill in Claude Code
   - Or follow the experiment setup in `program.md`

## Dependencies Installed

From `pyproject.toml`:

| Package | Version | Purpose |
| --------- | --------- | --------- |
| torch | 2.9.1 | PyTorch deep learning framework (with CUDA 12.8) |
| numpy | >=2.2.6 | Numerical computing |
| pandas | >=2.3.3 | Data manipulation |
| matplotlib | >=3.10.8 | Plotting and visualization |
| pyarrow | >=21.0.0 | Apache Arrow data format |
| requests | >=2.32.0 | HTTP requests |
| rustbpe | >=0.1.0 | BPE tokenizer (Rust-based) |
| tiktoken | >=0.11.0 | OpenAI tokenizer |
| kernels | >=0.11.7 | Custom CUDA kernels |

## File Structure After Installation

```text
tools/autoresearch/
├── .venv/                    # Virtual environment (created by uv sync)
│   ├── Lib/                  # Python packages
│   ├── Scripts/              # Python executables
│   └── pyvenv.cfg           # Virtual environment config
├── prepare.py                # Data prep script
├── train.py                  # Training script (agent modifies this)
├── program.md                # Agent instructions
├── verify_setup.py           # Dependency verification script (NEW)
├── pyproject.toml            # Dependency definitions
└── uv.lock                   # Dependency lockfile
```

## Integration with setup.sh

The `setup.sh` script (`.claude/hooks/setup.sh`) includes autoresearch installation in step 13:

- Detects if `tools/autoresearch/` exists
- Checks if `uv` is available
- Runs `uv sync` to install dependencies
- Provides verification instructions

This runs automatically on first project setup when you run:

```bash
bash .claude/hooks/setup.sh
```

Or if you delete `.claude/.setup-complete` and re-open the project in Claude Code.
