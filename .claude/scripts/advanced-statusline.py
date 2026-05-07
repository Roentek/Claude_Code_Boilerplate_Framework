#!/usr/bin/env python3
"""
Combined Status Line — Context Monitor + Context Mode Savings
Merges context usage monitoring with context-mode token savings metrics
"""

import json
import sys
import subprocess
import os

def get_context_monitor_output(data):
    """Get output from the existing context-monitor.py script."""
    try:
        # Path to context-monitor.py
        script_dir = os.path.dirname(os.path.abspath(__file__))
        context_monitor = os.path.join(script_dir, "context-monitor.py")

        if not os.path.exists(context_monitor):
            return None

        # Pass the JSON data to context-monitor.py via stdin
        result = subprocess.run(
            ["python", "-X", "utf8", context_monitor],
            input=json.dumps(data),
            capture_output=True,
            text=True,
            timeout=5
        )

        if result.returncode == 0:
            return result.stdout.strip()
        else:
            return None

    except Exception:
        return None


def get_context_mode_stats():
    """Get context-mode savings from the statusline command."""
    try:
        # Call context-mode statusline
        result = subprocess.run(
            ["context-mode", "statusline"],
            capture_output=True,
            text=True,
            timeout=5
        )

        if result.returncode == 0:
            output = result.stdout.strip()
            # Parse the output: "$ saved this session · $ saved across sessions · % efficient"
            # Example output: "$2.45 this session · $12.89 total · 87% efficient"
            return output if output else None
        else:
            return None

    except Exception:
        return None


def main():
    try:
        # Read JSON input from Claude Code
        data = json.load(sys.stdin)

        # Get context monitor baseline
        context_line = get_context_monitor_output(data)

        # Get context-mode savings
        savings_line = get_context_mode_stats()

        # Combine outputs
        if context_line and savings_line:
            # Add context-mode metrics after session metrics
            combined = f"{context_line} \033[90m|\033[0m \033[36m💎 {savings_line}\033[0m"
            print(combined)
        elif context_line:
            # Only context monitor available
            print(context_line)
        elif savings_line:
            # Only context-mode available (fallback)
            directory = os.path.basename(data.get("workspace", {}).get("project_dir", os.getcwd()))
            print(f"\033[94m[Claude]\033[0m \033[93m📁 {directory}\033[0m \033[90m|\033[0m \033[36m💎 {savings_line}\033[0m")
        else:
            # Both failed — show minimal fallback
            directory = os.path.basename(data.get("workspace", {}).get("project_dir", os.getcwd()))
            print(f"\033[94m[Claude]\033[0m \033[93m📁 {directory}\033[0m")

    except Exception as e:
        # Fallback display on any error
        print(
            f"\033[94m[Claude]\033[0m \033[93m📁 {os.path.basename(os.getcwd())}\033[0m 🧠 \033[31m[Error: {str(e)[:20]}]\033[0m"
        )


if __name__ == "__main__":
    main()
