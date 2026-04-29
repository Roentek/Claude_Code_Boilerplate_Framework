# Web Scraping Workflow

## Objective

Extract content from websites: single pages, full site crawls, web searches, URL mapping, and AI-powered structured data extraction. The `firecrawl` CLI is always the primary execution path. The `firecrawl-mcp` MCP server is a fallback for the narrow set of tasks the CLI cannot handle.

---

## Decision Flow (follow in order, stop at first match)

```text
Task involves web content?
│
├─ Single URL scrape          → firecrawl <url>                    [CLI]
├─ Web search                 → firecrawl search "<query>"         [CLI]
├─ Multi-page crawl           → firecrawl crawl <url> --wait       [CLI]
├─ URL discovery on a domain  → firecrawl map <url>               [CLI]
├─ AI-driven extraction       → firecrawl agent "<prompt>" --wait  [CLI]
│
├─ Batch scrape (list of URLs)     → firecrawl_batch_scrape        [MCP fallback]
├─ Schema-driven LLM extraction    → firecrawl_extract             [MCP fallback]
├─ Async status check in-session   → firecrawl_check_crawl_status  [MCP fallback]
│
├─ Interactive browser / login     → node tools/playwright.js      [different tool]
└─ 1000+ pages / bot-heavy sites   → Apify MCP                    [different tool]
```

The CLI runs token-free via Bash and is faster. Escalate to MCP only when the CLI genuinely cannot do the job (batch lists, schema extraction, async polling).

---

## Steps

### 1. Verify the environment

```bash
firecrawl --version
echo $FIRECRAWL_API_KEY
```

If CLI is missing:

```bash
npm install -g firecrawl-cli
```

If API key is empty — add to `.env`, then export:

```bash
export FIRECRAWL_API_KEY=fc-your-key-here
# Get key: https://www.firecrawl.dev/app/api-keys
```

### 2. Run the extraction (CLI)

Save all output to `.tmp/` — never to tracked paths.

**Scrape a single page:**

```bash
firecrawl https://example.com > .tmp/page.md
firecrawl https://example.com --json --pretty > .tmp/page.json
firecrawl https://example.com --format html,links -o .tmp/page.html
```

**Search the web:**

```bash
firecrawl search "your query" > .tmp/search.md
firecrawl search "your query" --limit 10 --scrape > .tmp/search-full.md
```

**Crawl a full site:**

```bash
firecrawl crawl https://example.com --wait --progress --limit 50 > .tmp/crawl.json
```

**Map all URLs:**

```bash
firecrawl map https://example.com --json > .tmp/urls.json
```

**AI agent extraction:**

```bash
firecrawl agent "Extract all pricing plans" --wait > .tmp/products.json
```

### 3. Fall back to MCP (when CLI can't do it)

Use `firecrawl-mcp` tools only for:

| Need | Tool |
| ------ | ------ |
| Batch scrape a known URL list | `firecrawl_batch_scrape` |
| Schema-driven LLM structured extraction | `firecrawl_extract` |
| Poll an async job without a terminal | `firecrawl_check_crawl_status` |

### 4. Handle errors

| Error | Action |
| ------- | -------- |
| `firecrawl: command not found` | `npm install -g firecrawl-cli` |
| `FIRECRAWL_API_KEY not set` / `401` | Export key; regenerate at firecrawl.dev if expired |
| `429 Rate Limit` | Reduce `--limit`; wait and retry |
| Crawl timeout | Add `--max-depth 2`, reduce `--limit 20` |
| Empty / blocked content | Try `--format html`; escalate to Apify MCP |

### 5. Store outputs

`.tmp/` is scratch space — regenerable, not committed. Final outputs go to cloud services: Google Drive, Supabase, Sheets, email, Slack.

---

## Self-Improvement Loop

When a recurring issue appears (bot detection, rate limits, malformed output):

1. Fix the command (add flags, adjust depth/limit, try alternate format)
2. Update this workflow with the new approach
3. Note site-specific quirks here for future reference
