# /21st-magic — 21st.dev Magic UI Component Tools

AI-powered UI component generation and inspiration via 21st.dev Magic MCP.

**MCP-first** (no standalone CLI for component ops — `@21st-dev/cli` is setup-only).
**Requires** `TWENTYFIRST_DEV_API_KEY` in `.claude/settings.local.json`.

---

## Tools Available

| Tool | Use When |
|------|----------|
| `mcp__21st-dev-magic__21st_magic_component_inspiration` | Browse/search existing components by description or style — free tier |
| `mcp__21st-dev-magic__21st_magic_component_builder` | Generate a new UI component from a prompt — Pro required |
| `mcp__21st-dev-magic__21st_magic_component_refiner` | Improve or restyle an existing component — Pro required |
| `mcp__21st-dev-magic__logo_search` | Find SVG brand logos by company name — free tier |

---

## Routing

**Use `/21st-magic` when asked to:**
- "Find a component for X" → `21st_magic_component_inspiration`
- "Build/generate a component for X" → `21st_magic_component_builder`
- "Improve this component" / "make it look like Y" → `21st_magic_component_refiner`
- "Get the logo for [Brand]" → `logo_search`

**Prefer monet-mcp** for landing page section components (hero, pricing, testimonials).
**Prefer /extract-design** when you need design tokens, not components.

---

## Usage

### Component Inspiration (free)
Search the 21st.dev registry for existing components matching a description.
Returns component previews, code snippets, and registry URLs.

### Component Builder (Pro)
Generates a production-ready React/TypeScript component from a natural language prompt.
Follows Tailwind CSS + shadcn/ui conventions by default.

### Component Refiner (Pro)
Takes existing component code + a refinement instruction.
Returns improved code preserving the component's structure.

### Logo Search (free)
Returns SVG markup for brand logos. Use for nav bars, partner sections, tech stacks.

---

## Setup

Two separate keys — both go in `.claude/settings.local.json` → `env` block:

```json
"TWENTYFIRST_DEV_MAGIC_API_KEY": "your-magic-key",
"TWENTYFIRST_DEV_CLI_API_KEY":   "your-cli-key"
```

| Key | Source | Used by |
|-----|--------|---------|
| `TWENTYFIRST_DEV_MAGIC_API_KEY` | https://21st.dev/magic/console → API Keys | `21st-dev-magic` MCP (component gen/search) |
| `TWENTYFIRST_DEV_CLI_API_KEY` | https://21st.dev/studio → Settings → API Keys | `@21st-dev/cli` (publish to registry) |

Restart Claude Code after adding keys — MCP activates automatically.
Free tier (Magic key): Inspiration + Logo Search. Pro ($20/mo): Builder + Refiner.

---

## Notes

- `@21st-dev/cli` with `TWENTYFIRST_DEV_CLI_API_KEY` — studio operations (publish, manage components in the 21st.dev registry). Not needed for component generation.
- `21st-dev-magic` MCP with `TWENTYFIRST_DEV_MAGIC_API_KEY` — all component generation/search in Claude Code.
- All component output is React + TypeScript by default.
- Components reference `@/components/ui/` (shadcn/ui) path aliases — adjust for your project.
