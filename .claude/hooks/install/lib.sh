#!/usr/bin/env bash
# Shared helpers sourced by every install script.
# Source: . "$(dirname "$0")/lib.sh"   (from a sibling script)
# or    : . "$ROOT/.claude/hooks/install/lib.sh"  (from setup.sh)

ROOT="${ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# ── Cross-platform timeout ────────────────────────────────────
# GNU timeout absent on Windows; fall back to background-kill pattern.
_timeout() {
  local secs=$1; shift
  "$@" &
  local pid=$! deadline=$((SECONDS + secs))
  while kill -0 "$pid" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do
    sleep 1
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; return 124
  fi
  wait "$pid"
}

# ── Platform detection ────────────────────────────────────────
_is_windows() {
  [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OS" == "Windows_NT" || -n "$WINDIR" || -n "$SystemRoot" ]]
}

# ── Cross-platform home dir ───────────────────────────────────
_user_home() {
  if [[ -n "$HOME" ]]; then
    echo "$HOME"
  elif [[ -n "$USERPROFILE" ]]; then
    cygpath "$USERPROFILE" 2>/dev/null \
      || echo "$USERPROFILE" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\1|'
  else
    echo "~"
  fi
}

# ── Install a Claude plugin ───────────────────────────────────
# Usage: _install_plugin <plugin-name> <marketplace-key>
_install_plugin() {
  local name="$1" mkt="$2"
  if command -v claude &>/dev/null; then
    if _timeout 30 claude plugin install "${name}@${mkt}" 2>/dev/null; then
      echo "  ✓ $name installed"
      return 0
    else
      echo "  ⚠ $name — run in Claude Code: /plugin install ${name}@${mkt}"
      return 1
    fi
  else
    echo "  ⚠ claude CLI not found — run in Claude Code: /plugin install ${name}@${mkt}"
    return 1
  fi
}

# ── Install a marketplace skill ───────────────────────────────
# Usage: _install_skill <skill-name> <marketplace-key>
_install_skill() {
  local name="$1" mkt="$2"
  if command -v claude &>/dev/null; then
    if _timeout 30 claude skill install "${name}@${mkt}" 2>/dev/null; then
      echo "  ✓ $name installed"
      return 0
    else
      echo "  ⚠ $name — run in Claude Code: /skill install ${name}@${mkt}"
      return 1
    fi
  else
    echo "  ⚠ claude CLI not found — run in Claude Code: /skill install ${name}@${mkt}"
    return 1
  fi
}
