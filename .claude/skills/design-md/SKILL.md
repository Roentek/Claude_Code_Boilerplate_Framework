---
name: design-md
description: "Load a ready-made brand design system (DESIGN.md) from the awesome-design-md collection into your project. 73 brands available including Linear, Stripe, Vercel, Notion, Figma, Spotify, Tesla, Supabase, and more. Use when the user wants to build a UI that looks like a known brand, wants to use a specific company's design language as a reference, or says things like 'make it look like Linear', 'use Stripe's design system', 'build something Notion-style', 'I want the Vercel aesthetic', or names any specific brand as a visual reference."
---

# Design MD — Brand Design System Loader

Fetches a ready-made `DESIGN.md` for any of 73 known brands from the [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) collection. Each file documents a brand's complete design system in plain markdown — colors, typography, components, spacing, and AI agent prompts — so Claude can generate pixel-perfect brand-aligned UI without any Figma exports or scraping.

## When to Use

- User names a specific brand as a visual reference ("looks like Linear", "Stripe aesthetic")
- User wants to clone or match the design language of a known product
- User needs a polished starting point without designing from scratch
- Use alongside `/skillui` (for custom sites) and `impeccable` (for critique/polish)

## Available Brands (73 total)

**AI & LLM Platforms**
Claude, Cohere, ElevenLabs, Minimax, Mistral.ai, Ollama, OpenCode.ai, Replicate, RunwayML, Together.ai, VoltAgent, X.ai

**Developer Tools**
Cal, Composio, Cursor, Expo, Framer, Lovable, Raycast, Warp

**Backend, Database & DevOps**
ClickHouse, HashiCorp, IBM, MongoDB, PostHog, Sanity, Sentry, Supabase

**Productivity & SaaS**
Airtable, Intercom, Linear.app, Miro, Notion, Semrush, Superhuman

**Design & Creative Tools**
Clay, Figma, Mintlify, Vercel, Webflow, Zapier

**Fintech & Crypto**
Coinbase, Kraken, Resend, Revolut, Stripe, Wise

**E-commerce & Retail**
Airbnb, Apple, Pinterest, Spotify, Uber

**Media & Consumer Tech**
Nvidia, SpaceX, Tesla, X.ai (see AI above)

**Automotive**
BMW, Ferrari, Lamborghini, Renault, Tesla

> Full list: [github.com/VoltAgent/awesome-design-md/tree/main/design-md](https://github.com/VoltAgent/awesome-design-md/tree/main/design-md)

## Workflow

### Step 1 — Fetch the DESIGN.md

```bash
npx getdesign@latest add <brand-slug>
```

The brand slug is the folder name from the repo (lowercase, e.g. `linear.app`, `stripe`, `notion`).

**Examples:**
```bash
npx getdesign@latest add linear.app
npx getdesign@latest add stripe
npx getdesign@latest add notion
npx getdesign@latest add vercel
npx getdesign@latest add supabase
npx getdesign@latest add figma
npx getdesign@latest add spotify
npx getdesign@latest add tesla
```

The command drops a `DESIGN.md` file into your current directory.

### Step 2 — Read it into the session

Once generated, read the `DESIGN.md` using the Read tool so it's in context:

```
Read the DESIGN.md in the project root
```

### Step 3 — Build with the design system

With `DESIGN.md` in context, reference it when building UI:

- "Build a pricing page using the design system in DESIGN.md"
- "Create a dashboard hero section following DESIGN.md"
- "Apply the color palette from DESIGN.md to this component"

The file contains pre-written agent prompts for common pages — use those directly.

### Step 4 — Polish and audit

After building, run `/impeccable audit` to catch anti-patterns, then use the frontend-design skill's comparison workflow to verify fidelity.

## Decision Guide: Which Tool to Use?

| Situation | Tool |
|-----------|------|
| Brand is one of the 73 in the collection | `/design-md` (this skill) |
| Brand/site not in the collection | `/skillui` — scrape it live |
| No specific brand reference, designing fresh | `ui-ux-pro-max --design-system` |
| Need to reverse-engineer how a site was built | `/site-teardown` |
| Audit/polish existing frontend output | `/impeccable` |

## Notes

- Each `DESIGN.md` includes: visual mood, full color palette with roles, typography hierarchy, component styles (buttons, cards, inputs), spacing scale, shadow/elevation system, do's and don'ts, responsive breakpoints, and AI agent prompts
- No API keys required — `npx getdesign@latest` is a public CLI
- The collection is actively maintained: [github.com/VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)
- Contributions welcome — see `CONTRIBUTING.md` in the repo
