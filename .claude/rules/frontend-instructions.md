# Frontend Instructions

> This file is the top-level reference for all frontend work. Load in order:
> 1. **This file** — local server, screenshot workflow, output defaults, anti-generic guardrails
> 2. **[`ui-ux-pro-max-instructions.md`](ui-ux-pro-max-instructions.md)** — design intelligence: styles, palettes, typography, UX rules, pre-delivery checklist

## Always Do First

- **Invoke the `frontend-design` skill** before writing any frontend code, every session, no exceptions.
- **Then read [`ui-ux-pro-max-instructions.md`](ui-ux-pro-max-instructions.md)** and run the design system generator before writing any UI code.
- **If the reference is a known brand (Linear, Stripe, Vercel, Notion, etc.):** run `/design-md` first — it fetches a ready-made `DESIGN.md` for any of 73 brands via `npx getdesign@latest add <brand>`. Each file contains the brand's full color palette, typography, component styles, spacing, and pre-written AI agent prompts. Source: [github.com/VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md).
- **If matching an existing site's visual language (not in the 73-brand collection):** run `/skillui` first — it extracts the design system (colors, typography, spacing, animations) into `SKILL.md`/`DESIGN.md` token files that auto-load into the session. Usage: `skillui --url <url>`, `skillui --dir ./my-app`, or `skillui --repo <github-url>`. Add `--mode ultra` for full visual extraction with screenshots.
- **For critique, polish, or audit passes:** use `impeccable` commands — `/impeccable audit [section]`, `/impeccable polish [section]`, `/impeccable critique`. These enforce design laws (OKLCH color space, no side-stripe borders, no gradient text, no identical card grids) and run 24-issue anti-pattern detection. Standalone: `npx impeccable detect [file/URL/dir]`.

## Reference Images

- If a reference image is provided: match layout, spacing, typography, and color exactly. Swap in placeholder content (images via `https://placehold.co/`, generic copy). Do not improve or add to the design.
- If no reference image: design from scratch with high craft (see guardrails below).
- Screenshot your output, compare against reference, fix mismatches, re-screenshot. Do at least 2 comparison rounds. Stop only when no visible differences remain or user says so.

## Local Server

- **Always serve on localhost** — never screenshot a `file:///` URL.
- Start the dev server: `node serve.mjs` (serves the project root at `http://localhost:3000`)
- `serve.mjs` lives in the project root. Start it in the background before taking any screenshots.
- If the server is already running, do not start a second instance.

## Screenshot Workflow

- **Always screenshot from localhost:** `node screenshot.mjs http://localhost:3000`
- Screenshots are saved automatically to `./temporary screenshots/screenshot-N.png` (auto-incremented, never overwritten).
- Optional label suffix: `node screenshot.mjs http://localhost:3000 label` → saves as `screenshot-N-label.png`
- `screenshot.mjs` lives in the project root. Use it as-is.
- After screenshotting, read the PNG from `temporary screenshots/` with the Read tool — Claude can see and analyze the image directly.
- When comparing, be specific: "heading is 32px but reference shows ~24px", "card gap is 16px but should be 24px"
- Check: spacing/padding, font size/weight/line-height, colors (exact hex), alignment, border-radius, shadows, image sizing

## Output Defaults

- Single `index.html` file, all styles inline, unless user says otherwise
- Tailwind CSS via CDN: `<script src="https://cdn.tailwindcss.com"></script>`
- Placeholder images: `https://placehold.co/WIDTHxHEIGHT`
- Mobile-first responsive

## Component Library (monet-mcp)

Before building sections from scratch, search the **monet-mcp** component library for ready-made, production-grade React/TS components:

```
Tools: search_components, get_component_code, get_component_details, list_categories, get_collection
```

- **Search first** — use `search_components` with natural language before writing any section from scratch (e.g., "dark hero with gradient", "pricing cards with toggle", "testimonial carousel")
- **Available categories:** hero, stats, testimonial, feature, pricing, cta, contact, faq, how-it-works, showcase, header, footer, gallery, team, logo-cloud, newsletter
- **Get the code** — use `get_component_code` once you've found a match; adapt colors and copy to the project's brand
- **Browse collections** — use `list_collections` / `get_collection` to explore curated component sets
- Requires `MONET_API_KEY` in `.env`

## Brand Assets

- Always check the `brand_assets/` folder before designing. It may contain logos, color guides, style guides, or images.
- If assets exist there, use them. Do not use placeholders where real assets are available.
- If a logo is present, use it. If a color palette is defined, use those exact values — do not invent brand colors.

## Anti-Generic Guardrails

- **Colors:** Never use default Tailwind palette (indigo-500, blue-600, etc.). Pick a custom brand color and derive from it.
- **Shadows:** Never use flat `shadow-md`. Use layered, color-tinted shadows with low opacity.
- **Typography:** Never use the same font for headings and body. Pair a display/serif with a clean sans. Apply tight tracking (`-0.03em`) on large headings, generous line-height (`1.7`) on body.
- **Gradients:** Layer multiple radial gradients. Add grain/texture via SVG noise filter for depth.
- **Animations:** Only animate `transform` and `opacity`. Never `transition-all`. Use spring-style easing.
- **Interactive states:** Every clickable element needs hover, focus-visible, and active states. No exceptions.
- **Images:** Add a gradient overlay (`bg-gradient-to-t from-black/60`) and a color treatment layer with `mix-blend-multiply`.
- **Spacing:** Use intentional, consistent spacing tokens — not random Tailwind steps.
- **Depth:** Surfaces should have a layering system (base → elevated → floating), not all sit at the same z-plane.

## Hard Rules

- Do not add sections, features, or content not in the reference
- Do not "improve" a reference design — match it
- Do not stop after one screenshot pass
- Do not use `transition-all`
- Do not use default Tailwind blue/indigo as primary color
