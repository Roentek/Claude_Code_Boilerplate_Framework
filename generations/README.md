# generations/

Media library for the `/generate` skill (`.claude/skills/generate/SKILL.md`). Every image/video the skill makes lands here, flat, automatically — no manual import step.

## Layout

```text
generations/
├── README.md            this file
├── gallery.html          the gallery page (served, not opened as file://)
├── gallery-server.mjs     tiny node server: serves gallery.html + lists this folder as JSON
├── styles.json            reusable style presets (name, prompt, refs) — edit by hand or via the gallery's Styles panel
├── refs/                  reference images (logos, faces, style shots) the skill passes into API calls
├── {name}.{png|jpg|mp4|...}  generated media, flat, no subfolders
└── {name}.json             sidecar log next to each generated file — prompt, model, params, timestamp
```

## Why a server instead of opening `gallery.html` directly

Browsers can't list an arbitrary local folder from a `file://` page (security sandboxing). `gallery-server.mjs` is a zero-dependency Node HTTP server (same pattern as the deck `serve.mjs` files in `src/*/`) that exposes this folder as `GET /api/media` and serves the media files themselves — so the gallery auto-refreshes as new generations land, with no import or rebuild step.

## Running it

```bash
node generations/gallery-server.mjs
# → http://localhost:3737
```

Or launch it from VS Code: Run & Debug → **Generate Gallery**.

## Styles panel

Click **Styles** in the gallery header to see saved presets from `styles.json`. Clicking one copies its prompt + reference paths to your clipboard — paste into a `/generate` request instead of re-describing a look from scratch. Add new presets by editing `styles.json` directly, or ask the agent to save one after a generation you like.

## Sidecar logs

Every generated file gets a matching `.json` file with the same basename — what prompt, model, and params made it, and when. This is written automatically by the `/generate` skill per its `SKILL.md` rules. Any file dropped into this folder without one just won't show metadata in the gallery tile — it still displays fine.
