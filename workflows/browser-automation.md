# Browser Automation Workflow

## Objective

Automate browser interactions using Playwright: screenshots, scraping JS-rendered content, PDF generation, and link extraction. All execution goes through `tools/playwright.js` via Bash — no MCP server needed.

## Tool Selection

| Need | Tool |
| ------ | ------ |
| Screenshot any URL | `node tools/playwright.js screenshot` |
| Scrape JS-rendered page | `node tools/playwright.js scrape` |
| Generate PDF from URL | `node tools/playwright.js pdf` |
| Extract all page links | `node tools/playwright.js links` |
| Large-scale scraping (1000+ pages) | Apify MCP |
| Static HTML or REST API content | Tavily MCP or `curl` |
| localhost screenshots (frontend dev) | `node screenshot.mjs` |

## Steps

### 1. Verify Playwright is Installed

```bash
node -e "import('playwright').then(() => console.log('ok')).catch(() => console.log('missing'))"
```

If missing:

```bash
npm install
npx playwright install chromium
```

### 2. Run the Automation

Save all output to `.tmp/` — never to tracked paths.

**Screenshot:**

```bash
node tools/playwright.js screenshot <url> .tmp/screenshot.png
```

**Scrape full page:**

```bash
node tools/playwright.js scrape <url> > .tmp/data.json
```

**Scrape specific elements:**

```bash
node tools/playwright.js scrape <url> --selector "<css>" > .tmp/data.json
```

**PDF:**

```bash
node tools/playwright.js pdf <url> .tmp/output.pdf
```

**Links:**

```bash
node tools/playwright.js links <url> > .tmp/links.json
```

### 3. Inspect the Output

- **Screenshots** — use the Read tool to visually inspect the PNG
- **Scraped JSON** — parse with Python or pass directly to the next step
- **PDFs** — confirm file exists with `ls .tmp/`

### 4. Handle Errors

| Error | Action |
| ------- | -------- |
| `Cannot find module 'playwright'` | Run `npm install` |
| `Executable doesn't exist` | Run `npx playwright install chromium` |
| `Timeout` | Add `--timeout 60000`; add `--wait-for <selector>` if page is JS-heavy |
| `net::ERR_NAME_NOT_RESOLVED` | Check URL; site may be down |
| Partial / empty content | Page may be gated behind auth or bot detection; try Apify |

### 5. Store Final Outputs

`.tmp/` is scratch space — regenerable, not committed.
Final outputs belong in cloud services: Google Drive, Supabase storage, email, Slack, etc.

## Self-Improvement Loop

When you hit a recurring issue (rate limits, bot detection, slow load):

1. Fix the command (add flags, increase timeout, switch selector)
2. Update this workflow with the new approach
3. Note any site-specific quirks as comments in the relevant workflow
