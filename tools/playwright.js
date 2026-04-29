#!/usr/bin/env node
/**
 * Playwright browser automation tool
 * Commands: screenshot, scrape, pdf, links
 * All output is JSON to stdout; errors to stderr with exit code 1.
 *
 * Usage:
 *   node tools/playwright.js screenshot <url> [output] [--fullpage] [--headed] [--wait-for <selector>] [--timeout <ms>]
 *   node tools/playwright.js scrape <url> [--selector <css>] [--headed] [--wait-for <selector>] [--timeout <ms>]
 *   node tools/playwright.js pdf <url> [output] [--format <A4|Letter>] [--headed] [--timeout <ms>]
 *   node tools/playwright.js links <url> [--headed] [--timeout <ms>]
 *
 * --headed  Open a visible browser window (default: headless)
 */
import { chromium } from 'playwright';
import { resolve } from 'path';

const [,, cmd, ...rawArgs] = process.argv;

if (!cmd) {
  console.error(JSON.stringify({ error: 'No command. Use: screenshot, scrape, pdf, links' }));
  process.exit(1);
}

function parseArgs(rawArgs) {
  const flags = {};
  const positional = [];
  for (let i = 0; i < rawArgs.length; i++) {
    if (rawArgs[i].startsWith('--')) {
      const key = rawArgs[i].slice(2);
      flags[key] = rawArgs[i + 1] !== undefined && !rawArgs[i + 1].startsWith('--')
        ? rawArgs[++i]
        : true;
    } else {
      positional.push(rawArgs[i]);
    }
  }
  return { flags, positional };
}

// Parse --headed before the browser launches so the flag applies globally.
const headed = process.argv.includes('--headed');
const launchOpts = { headless: !headed };

// Use system Chrome/Edge; fall back to Playwright's bundled Chromium (e.g. CI).
let browser;
try {
  browser = await chromium.launch({ ...launchOpts, channel: 'chrome' });
} catch {
  browser = await chromium.launch(launchOpts);
}
const context = await browser.newContext({
  viewport: { width: 1280, height: 900 },
});
const page = await context.newPage();

try {
  const { flags, positional } = parseArgs(rawArgs);
  const timeout = parseInt(flags.timeout ?? '30000');

  switch (cmd) {
    case 'screenshot': {
      const [url, outputPath = '.tmp/screenshot.png'] = positional;
      if (!url) throw new Error('URL required: node tools/playwright.js screenshot <url> [output]');
      await page.goto(url, { waitUntil: 'networkidle', timeout });
      if (flags['wait-for']) await page.waitForSelector(flags['wait-for'], { timeout });
      await page.screenshot({ path: resolve(outputPath), fullPage: 'fullpage' in flags });
      console.log(JSON.stringify({ success: true, path: outputPath }));
      break;
    }

    case 'scrape': {
      const [url] = positional;
      if (!url) throw new Error('URL required: node tools/playwright.js scrape <url>');
      await page.goto(url, { waitUntil: 'networkidle', timeout });
      if (flags['wait-for']) await page.waitForSelector(flags['wait-for'], { timeout });

      let result;
      if (flags.selector) {
        result = await page.$$eval(flags.selector, els =>
          els.map(el => ({
            text: el.innerText?.trim() ?? '',
            html: el.innerHTML,
            href: el.href ?? null,
          }))
        );
      } else {
        result = {
          title: await page.title(),
          url: page.url(),
          text: await page.evaluate(() => document.body?.innerText ?? ''),
          metaDescription: await page.$eval('meta[name="description"]', el => el.content).catch(() => null),
        };
      }
      console.log(JSON.stringify(result, null, 2));
      break;
    }

    case 'pdf': {
      const [url, outputPath = '.tmp/output.pdf'] = positional;
      if (!url) throw new Error('URL required: node tools/playwright.js pdf <url> [output]');
      await page.goto(url, { waitUntil: 'networkidle', timeout });
      await page.pdf({ path: resolve(outputPath), format: flags.format ?? 'A4', printBackground: true });
      console.log(JSON.stringify({ success: true, path: outputPath }));
      break;
    }

    case 'links': {
      const [url] = positional;
      if (!url) throw new Error('URL required: node tools/playwright.js links <url>');
      await page.goto(url, { waitUntil: 'networkidle', timeout });
      const links = await page.$$eval('a[href]', els =>
        els
          .map(el => ({ text: el.innerText?.trim() ?? '', href: el.href }))
          .filter(l => l.href && l.href.startsWith('http'))
      );
      console.log(JSON.stringify(links, null, 2));
      break;
    }

    default:
      throw new Error(`Unknown command: "${cmd}". Available: screenshot, scrape, pdf, links`);
  }
} catch (err) {
  console.error(JSON.stringify({ error: err.message }));
  process.exit(1);
} finally {
  await browser.close();
}
