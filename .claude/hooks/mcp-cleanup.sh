#!/usr/bin/env bash
# Kills orphaned MCP node processes from previous crashed Claude Code sessions.
#
# Safety: only kills processes whose parent PID is dead (orphaned).
# Claude Desktop's MCP servers have a living parent (Claude.exe) → untouched.
# Current session hasn't spawned MCP servers yet (SessionStart fires first) → nothing to find.

powershell.exe -NoProfile -NonInteractive -Command "
\$killed = 0

Get-Process -Name 'node' -ErrorAction SilentlyContinue | ForEach-Object {
    \$proc = \$_
    try {
        \$wmi = Get-CimInstance Win32_Process -Filter \"ProcessId=\$(\$proc.Id)\" -ErrorAction SilentlyContinue
        if (-not \$wmi) { return }

        \$cmd = \$wmi.CommandLine
        \$isMcp = \$cmd -and (
            \$cmd -like '*n8n-mcp*' -or
            \$cmd -like '*firecrawl-mcp*' -or
            \$cmd -like '*@playwright/mcp*' -or
            \$cmd -like '*actors-mcp-server*' -or
            \$cmd -like '*mcp-server-supabase*' -or
            \$cmd -like '*caveman-shrink*' -or
            \$cmd -like '*server-memory*' -or
            \$cmd -like '*@pinecone-database/mcp*' -or
            \$cmd -like '*@vapi-ai/mcp-server*' -or
            \$cmd -like '*context7-mcp*' -or
            \$cmd -like '*openrouter-mcp*' -or
            \$cmd -like '*@21st-dev/magic*' -or
            \$cmd -like '*tavily-mcp*' -or
            \$cmd -like '*@canva/cli*mcp*' -or
            \$cmd -like '*mcp-remote*' -or
            \$cmd -like '*trigger.dev*mcp*' -or
            \$cmd -like '*kie-ai-mcp-server*' -or
            \$cmd -like '*designlang*mcp*' -or
            \$cmd -like '*stdio-wrapper*'
        )

        if (\$isMcp) {
            \$parentId = \$wmi.ParentProcessId
            \$parentAlive = [bool](Get-Process -Id \$parentId -ErrorAction SilentlyContinue)

            if (-not \$parentAlive) {
                Stop-Process -Id \$proc.Id -Force -ErrorAction SilentlyContinue
                \$killed++
            }
        }
    } catch {}
}

if (\$killed -gt 0) {
    Write-Host \"[mcp-cleanup] Killed \$killed orphaned MCP process(es) from previous session\"
}
" 2>/dev/null

exit 0
