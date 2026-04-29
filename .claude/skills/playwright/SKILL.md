---
name: playwright
description: Browser automation via Playwright CLI — screenshots, scraping JS-rendered pages, PDF generation, link extraction. Runs directly via Bash (no MCP server, no token overhead).
---

# Playwright Browser Automation

Run `node tools/playwright.js` directly via Bash. All commands output JSON. No MCP server required.

## Prerequisites (run once per machine)

```bash
npm install
```

Uses your system Chrome or Edge — no separate browser download needed. Falls back to Playwright's bundled Chromium automatically if neither is found (e.g. CI).

## Decision: Which Tool to Use

| Need | Tool |
|------|------|
| Screenshot any URL | `node tools/playwright.js screenshot` |
| Scrape JS-rendered page | `node tools/playwright.js scrape` |
| Generate PDF from URL | `node tools/playwright.js pdf` |
| Extract all page links | `node tools/playwright.js links` |
| Quick one-off screenshot (no install) | `npx playwright screenshot <url> <file>` |
| Large-scale scraping (1000+ pages) | Apify MCP |
| Static HTML / REST API content | Tavily MCP or `curl` |
| localhost screenshots (frontend dev) | `node screenshot.mjs` (see frontend-instructions.md) |

## Commands

### screenshot
```bash
node tools/playwright.js screenshot <url> [output-path] [--fullpage] [--headed] [--wait-for <selector>] [--timeout <ms>]
```
- Default output: `.tmp/screenshot.png`
- `--fullpage` — capture full scrollable page, not just viewport
- `--wait-for` — wait for a CSS selector to appear before capturing

```bash
node tools/playwright.js screenshot https://example.com .tmp/example.png
node tools/playwright.js screenshot https://example.com .tmp/full.png --fullpage
node tools/playwright.js screenshot https://app.example.com .tmp/app.png --wait-for "#dashboard"
```

### scrape
```bash
node tools/playwright.js scrape <url> [--selector <css>] [--headed] [--wait-for <selector>] [--timeout <ms>]
```
- Without `--selector`: returns `{ title, url, text, metaDescription }` for the whole page
- With `--selector`: returns array of `{ text, html, href }` per matched element

```bash
# Full page text
node tools/playwright.js scrape https://example.com

# Specific elements
node tools/playwright.js scrape https://example.com --selector "h2"
node tools/playwright.js scrape https://store.example.com --selector ".product-name" --wait-for ".product-name"
```

### pdf
```bash
node tools/playwright.js pdf <url> [output-path] [--format <A4|Letter>] [--headed] [--timeout <ms>]
```
- Default output: `.tmp/output.pdf`

```bash
node tools/playwright.js pdf https://example.com .tmp/report.pdf
node tools/playwright.js pdf https://example.com .tmp/report.pdf --format Letter
```

### links
```bash
node tools/playwright.js links <url> [--headed] [--timeout <ms>]
```
Returns array of `{ text, href }` for all external links on the page.

```bash
node tools/playwright.js links https://example.com
```

## Output Handling

All commands write JSON to stdout. Save or inspect:

```bash
# Save to file
node tools/playwright.js scrape https://example.com > .tmp/data.json

# Pretty-print
node tools/playwright.js scrape https://example.com | python -m json.tool
```

Screenshots: after saving, use the Read tool to visually inspect the PNG.

## Quick CLI (no npm install needed)

```bash
npx playwright screenshot https://example.com .tmp/screenshot.png
npx playwright screenshot --full-page https://example.com .tmp/full.png
npx playwright pdf https://example.com .tmp/output.pdf
```

## Error Handling

| Error | Fix |
|-------|-----|
| `Cannot find module 'playwright'` | Run `npm install` |
| `Executable doesn't exist` (after fallback) | Run `npx playwright install chromium` (CI / no system Chrome) |
| `net::ERR_NAME_NOT_RESOLVED` | URL typo or site is down |
| `Timeout` | Increase `--timeout 60000` or add `--wait-for` |

## WAT Integration

For multi-step automation tasks, follow `workflows/browser-automation.md`.
