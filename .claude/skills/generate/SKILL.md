---
name: generate
description: Generate images and videos via AI model APIs (Kie AI, with fal.ai and WaveSpeed AI as optional future providers). Routes each request to the cheapest capable model for the task, or an advanced model for high-fidelity work. Triggers on /generate, generate image, generate video, create image, create video, thumbnail, animate.
---

# /generate

Playbook for AI media generation. Reads this file, picks a model, generates, saves flat, logs.

## Models

| Task | Tier | Model | Recipe |
| --- | --- | --- | --- |
| Image, everyday/draft | cheap | Nano Banana 2 Lite | `models/nano-banana-2-lite.md` |
| Image, text-in-image (signs, posters, UI) | advanced | GPT Image 2 | `models/gpt-image-2.md` |
| Video, general/default | cheap | Kling 3.0 | `models/kling-3.0.md` |
| Video, higher quality from a start frame | advanced | Veo 3.1 | `models/veo-3.1.md` |
| Video, animate reference images | advanced | Seedance 2.0 Fast | `models/seedance-2.0-fast.md` |

Read the recipe file before every generation — it has the exact model id, endpoint, request shape, and cost.

**Tier selection:** default to the cheap tier (Nano Banana 2 Lite / Kling 3.0) for drafts, iteration, and simple requests. Move to the advanced tier only when the task needs it: readable text in the image (GPT Image 2), a hero-quality video shot (Veo 3.1), or animating 2-9 reference images instead of a text prompt (Seedance 2.0 Fast). If unsure which tier fits, say so and ask rather than guessing toward the expensive option.

## Provider routing

1. **Kie AI is the only wired provider right now** — use `kie-cli` (CLI-first, zero token overhead) or the `kie-ai` MCP tools as fallback. Key: `KIE_AI_API_KEY` (already in `.claude/settings.local.json`).
2. fal.ai and WaveSpeed AI are documented as future fallbacks (see `models/*.md` provider notes) but are **not yet wired** — no `FAL_KEY` / `WAVESPEED_API_KEY` exist in this project. If a model isn't available on Kie AI, say so and ask before doing anything else; don't silently invent a fal.ai/WaveSpeed call.
3. Never hide a provider swap. Say which route ran and why.

## Output

- Save every file FLAT into `generations/` (project root). No subfolders.
- Reference images live in `generations/refs/`.
- Naming: `{project}_{description}_{timestamp}.{ext}`
- After every save, write the sidecar log: `{basename}.json` next to the media file (same rules as `generations/README.md`).

## Rules

- Quote the cost and wait for explicit go-ahead before any paid video run. One approval = one run.
- Draft on the cheap tier first. Only rerun on the advanced tier once a favorite is picked.
- Never describe a logo or face in text. Pass the real image file from `generations/refs/` as a reference. If it's missing, stop and ask for it.
- Run multiple generations one at a time to avoid rate limits.
- If a request would generate more than a handful of items (e.g. "generate 100 images"), stop and confirm the count and total cost before running any of it.

## Styles

`generations/styles.json` holds reusable style presets (prompt fragment + reference file paths), editable from the gallery's Styles panel or by hand. When the user references a saved style by name, load its prompt fragment and refs from there instead of re-describing the look from scratch.

## Gallery

`generations/gallery-server.mjs` serves a local gallery at the media library — see `generations/README.md` for how to launch it. The gallery reads `generations/` directly; no manual import step, files just need to land in that folder per the Output rule above.
