#!/usr/bin/env bash
# Print one-time manual authentication steps for services that require browser login.
# Nothing to install here — purely informational.
cat <<'AUTH'

── Authentication Reminders ─────────────────────────────
  These require a one-time manual step before first use:

  NotebookLM  →  notebooklm login
    (browser opens — sign in to Google; Chromium auto-downloaded ~170MB on first run)
    Check: notebooklm auth check --test --json
    Headless: notebooklm login --master-token --account you@gmail.com

  Trigger.dev  →  npx trigger.dev@latest login
    (browser opens — authenticates the trigger MCP server)

  Google Workspace MCP
    Set GOOGLE_OAUTH_CLIENT_ID + GOOGLE_OAUTH_CLIENT_SECRET
    in .claude/settings.local.json, then open Claude Code —
    browser OAuth consent window opens on first tool call.

  Canva MCP
    No keys needed. Browser OAuth opens automatically on first use.

  Higgsfield CLI + MCP
    higgsfield auth login
    (browser opens — sign in to your Higgsfield account; token cached)
    Required by: /higgsfield:generate, /higgsfield:soul-id, /higgsfield:product-photoshoot, /higgsfield:marketplace-cards
    MCP fallback: npx mcp-remote https://mcp.higgsfield.ai/mcp (same credentials)

  Google Workspace CLI  →  gw auth login
    Browser OAuth — links gw CLI to your Google account.
    Required by: /gw skill (Gmail, Drive, Calendar via CLI).
    Multi-account: gw auth login again for each account; switch with gw auth switch.
    MCP fallback: google-workspace-mcp (same OAuth credentials via settings.local.json).

  Vercel CLI  →  vercel login
    Browser OAuth — links CLI to your Vercel account.
    Required by: /vercel skill (deploy, preview, env vars, domains, logs).
    Token for vercel-mcp: vercel.com/account/tokens → add VERCEL_TOKEN to settings.local.json

  GitHub CLI  →  gh auth login
    Required by: github@claude-plugins-official plugin.

  Supabase CLI  →  supabase login
    Browser OAuth — links CLI to your Supabase account.
    Required for: supabase db push, gen types, edge functions deploy.

  Gemini Plugin  →  add GEMINI_API_KEY to settings.local.json
    Free key: https://aistudio.google.com/apikey

  Codex CLI  →  codex login
    One-time browser auth (ChatGPT account fine; Free/Plus/Pro/Max all work).
    Required by: /grill-me-codex, /grill-with-docs-codex, /codex-review.
    Also: codex --version must be ≥ 0.130 (npm install -g @openai/codex@latest).

  Codex Plugin  →  /codex:setup (checks readiness in Claude Code)
    Requires OPENAI_API_KEY in settings.local.json.

  All other MCP servers (supabase, openrouter, kie-ai, tavily,
  pinecone, vapi, n8n, apify, monet, stitch, 21st-dev, firecrawl)
  require API keys in .claude/settings.local.json → env block.
  See .claude/settings.local.json.example → __activation_guide.

AUTH
