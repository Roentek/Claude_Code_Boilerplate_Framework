#!/usr/bin/env python3
"""
Combined Status Line — Context Monitor + Context Mode Savings
Delegates to context-monitor.py; handles UTF-8 BOM from Windows stdin pipes.
"""

import json
import sys
import subprocess
import os


def read_stdin_safe():
    """Read JSON from stdin, stripping UTF-8 BOM if present (Windows PowerShell)."""
    raw = sys.stdin.buffer.read()
    # Strip UTF-8 BOM (EF BB BF) if present
    if raw.startswith(b'\xef\xbb\xbf'):
        raw = raw[3:]
    return json.loads(raw.decode('utf-8'))


def get_context_monitor_output(data):
    """Run context-monitor.py and return its stdout."""
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        context_monitor = os.path.join(script_dir, "context-monitor.py")

        if not os.path.exists(context_monitor):
            return None

        result = subprocess.run(
            [sys.executable, "-X", "utf8", context_monitor],
            input=json.dumps(data).encode('utf-8'),
            capture_output=True,
            timeout=5
        )

        if result.returncode == 0:
            return result.stdout.decode('utf-8', errors='replace').strip()
        return None

    except Exception:
        return None


def main():
    try:
        data = read_stdin_safe()
        line = get_context_monitor_output(data)

        if line:
            print(line)
        else:
            # Minimal fallback if context-monitor fails
            directory = os.path.basename(
                data.get("workspace", {}).get("project_dir", os.getcwd())
            )
            model = data.get("model", {}).get("display_name", "Claude")
            print(f"\033[94m[{model}]\033[0m \033[93m📁 {directory}\033[0m")

    except Exception as e:
        print(
            f"\033[94m[Claude]\033[0m \033[93m📁 {os.path.basename(os.getcwd())}\033[0m"
            f" 🧠 \033[31m[Error: {str(e)[:30]}]\033[0m"
        )


if __name__ == "__main__":
    main()
