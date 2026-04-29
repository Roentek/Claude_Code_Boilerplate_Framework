---
name: firecrawl
description: Web scraping, site crawling, URL discovery, web search with content extraction, and AI-powered structured data extraction using Firecrawl. Invoke this skill whenever the user wants to scrape a page, extract content from a URL, crawl a website across multiple pages, search the web and retrieve page content, map all URLs on a domain, or pull structured data from web sources. Use it even for casual requests like "get the content from this site", "scrape this page for me", "crawl docs.example.com", "search the web for X and extract the results", or "what's on this URL" — any time web content needs to land in the session.
---

# Firecrawl — Web Scraping & Extraction

Always use the `firecrawl` CLI first. Fall back to the `firecrawl-mcp` MCP server only when the CLI genuinely cannot do the job. The CLI runs token-free via Bash and is faster; the MCP costs context on every call.

## Step 0 — Verify prerequisites

Before running anything, confirm the CLI is installed and the API key is set:

```bash
firecrawl --version          # should print a version number
echo $FIRECRAWL_API_KEY      # should print fc-...
```

If the CLI is missing:
```bash
npm install -g firecrawl-cli
```

If the API key is empty, add it to `.env` and export it:
```bash
export FIRECRAWL_API_KEY=fc-your-key-here
# Get your key at: https://www.firecrawl.dev/app/api-keys
```

---

## Step 1 — Choose the right command (CLI first)

Work through this decision in order. Stop at the first match.

**Is the task a single URL scrape?** → `firecrawl <url>`

```bash
firecrawl https://example.com                          # Markdown (default)
firecrawl https://example.com --format html,links      # specific formats
firecrawl https://example.com -o .tmp/page.md          # save to file
firecrawl https://example.com --json --pretty > .tmp/page.json
```

**Is the task a web search?** → `firecrawl search`

```bash
firecrawl search "your query"
firecrawl search "AI pricing" --limit 10               # cap results
firecrawl search "topic" --scrape --scrape-formats markdown  # fetch full pages
```

**Is the task a multi-page site crawl?** → `firecrawl crawl`

```bash
firecrawl crawl https://example.com --wait --progress
firecrawl crawl https://example.com --limit 50 --max-depth 3 --wait > .tmp/crawl.json
```

**Is the task URL discovery across a domain?** → `firecrawl map`

```bash
firecrawl map https://example.com
firecrawl map https://example.com --search "blog" --json > .tmp/urls.json
```

**Is the task AI-driven open-ended extraction?** → `firecrawl agent`

```bash
firecrawl agent "Extract all pricing plans from this site" --wait
firecrawl agent "Extract contact info" \
  --schema '{"type":"object","properties":{"email":{"type":"string"}}}' \
  --wait
```

Save all output to `.tmp/` — never to tracked paths.

---

## Step 2 — Escalate to MCP only when CLI cannot do the job

The CLI covers ~90% of use cases. The MCP is the right choice only for:

| Scenario | MCP tool to use |
|---|---|
| Scraping a **pre-built list of URLs** in one call | `firecrawl_batch_scrape` |
| **Schema-driven LLM extraction** where structured output feeds directly into a downstream tool call | `firecrawl_extract` |
| Polling an **async crawl job** without keeping a terminal open | `firecrawl_check_crawl_status`, `firecrawl_check_batch_status` |

If none of those apply, use the CLI. The MCP has the same underlying API — it just adds protocol overhead.

Available MCP tools (firecrawl-mcp): `firecrawl_scrape`, `firecrawl_batch_scrape`, `firecrawl_search`, `firecrawl_crawl`, `firecrawl_map`, `firecrawl_agent`, `firecrawl_extract`, `firecrawl_check_crawl_status`, `firecrawl_check_batch_status`, `firecrawl_agent_status`

---

## Step 3 — Handle errors and escalate when stuck

| Error | What to do |
|---|---|
| `firecrawl: command not found` | `npm install -g firecrawl-cli` |
| `FIRECRAWL_API_KEY not set` / `401 Unauthorized` | Add key to `.env` + `export FIRECRAWL_API_KEY=fc-...`; regenerate at firecrawl.dev if expired |
| `429 Rate Limit` | Reduce `--limit`; wait and retry |
| Crawl timeout | Add `--max-depth 2`, reduce `--limit 20` |
| Empty / blocked content | Try `--format html`; if still blocked, escalate to Apify MCP (handles bot detection) |
| Need interactive browser (login flows, JS forms) | Use `node tools/playwright.js` or `playwright-mcp` instead |
| 1 000+ pages | Use Apify MCP — it handles massive scale Firecrawl cannot |

---

## Output handling

- Always write to `.tmp/` (scratch space, not committed)
- Read `.tmp/page.md` inline to inspect content in-session
- Pass `.tmp/page.json` to a Python script or the next pipeline step
- Final deliverables go to cloud services: Google Drive, Supabase, Sheets, email, etc.
