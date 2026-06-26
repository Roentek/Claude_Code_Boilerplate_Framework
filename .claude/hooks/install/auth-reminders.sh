#!/usr/bin/env bash
# Print one-time manual authentication steps for services that require browser login.
# Nothing to install here — purely informational.
cat <<'AUTH'

── Authentication Reminders ─────────────────────────────
  These require a one-time manual step before first use:

  NotebookLM  →  nlm login
    (browser opens — sign in to Google; cookies auto-extracted)
    OR: nlm login --manual (import from file)

  Trigger.dev  →  npx trigger.dev@latest login
    (browser opens — authenticates the trigger MCP server)

  Google Workspace MCP
    Set GOOGLE_OAUTH_CLIENT_ID + GOOGLE_OAUTH_CLIENT_SECRET
    in .claude/settings.local.json, then open Claude Code —
    browser OAuth consent window opens on first tool call.

  Canva MCP
    No keys needed. Browser OAuth opens automatically on first use.

  Higgsfield MCP
    npx mcp-remote https://mcp.higgsfield.ai/mcp
    Sign in once — mcp-remote caches the token automatically.

  GitHub CLI  →  gh auth login
    Required by: github@claude-plugins-official plugin.

  Gemini Plugin  →  add GEMINI_API_KEY to settings.local.json
    Free key: https://aistudio.google.com/apikey

  Codex Plugin  →  /codex:setup (checks readiness in Claude Code)
    Requires OPENAI_API_KEY in settings.local.json.

  All other MCP servers (supabase, openrouter, kie-ai, tavily,
  pinecone, vapi, n8n, apify, monet, stitch, 21st-dev, firecrawl)
  require API keys in .claude/settings.local.json → env block.
  See .claude/settings.local.json.example → __activation_guide.

AUTH
