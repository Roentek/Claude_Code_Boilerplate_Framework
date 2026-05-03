#!/usr/bin/env python3
"""
Verification script for autoresearch dependencies.
Run this after `uv sync` completes to verify all dependencies are installed correctly.

Usage:
    uv run python verify_setup.py
"""

import sys
import importlib.util

def check_module(module_name, package_name=None):
    """Check if a module can be imported."""
    display_name = package_name or module_name
    spec = importlib.util.find_spec(module_name)
    if spec is not None:
        try:
            module = importlib.import_module(module_name)
            version = getattr(module, '__version__', 'unknown')
            print(f"[OK] {display_name:20s} version {version}")
            return True
        except Exception as e:
            print(f"[FAIL] {display_name:20s} import failed: {e}")
            return False
    else:
        print(f"[FAIL] {display_name:20s} not found")
        return False

def main():
    print("=" * 60)
    print("AutoResearch Dependency Verification")
    print("=" * 60)
    print()

    # Required dependencies from pyproject.toml
    dependencies = [
        ('torch', 'PyTorch'),
        ('numpy', 'NumPy'),
        ('pandas', 'Pandas'),
        ('matplotlib', 'Matplotlib'),
        ('pyarrow', 'PyArrow'),
        ('requests', 'Requests'),
        ('tiktoken', 'TikToken'),
    ]

    # Check Python version
    print(f"Python version: {sys.version}")
    print()

    if sys.version_info < (3, 10):
        print("[FAIL] Python 3.10+ required")
        sys.exit(1)
    else:
        print("[OK] Python version OK (>= 3.10)")
        print()

    # Check all dependencies
    print("Checking dependencies:")
    print("-" * 60)

    all_ok = True
    for module_name, display_name in dependencies:
        if not check_module(module_name, display_name):
            all_ok = False

    print()
    print("=" * 60)

    if all_ok:
        print("[OK] All dependencies installed successfully!")
        print()
        print("Next steps:")
        print("  1. uv run prepare.py    # Download data and train tokenizer (~2 min)")
        print("  2. uv run train.py       # Test baseline training run (~5 min)")
        print("  3. Use /autoresearch skill to start autonomous research")
        return 0
    else:
        print("[FAIL] Some dependencies are missing or failed to import")
        print()
        print("Try running: uv sync")
        return 1

if __name__ == '__main__':
    sys.exit(main())
