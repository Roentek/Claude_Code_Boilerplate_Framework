# GPT Image 2

Advanced tier for images. Best at text inside images — signs, posters, menus, packaging, UI mockups. Use only when the cheap tier can't get readable text right.

| Field | Value |
| --- | --- |
| Model ID | `openai/gpt-image-2` (edit endpoint adds `/edit`) |
| Provider | Kie AI (cheapest observed route — ~$0.05/image at medium; fal.ai is the documented alternate route, not yet wired) |
| Method | Sync (instant reply) |
| Type | Image |
| API key | `.env` / `settings.local.json` → `KIE_AI_API_KEY` |
| Cost | ~$0.03 (1K) / $0.05 (2K) / $0.08 (4K) per image via Kie AI |

## Call

Prefer `kie-cli`. Fall back to `kie-ai` MCP tool `gpt_image_2`.

```bash
kie-cli generate --model gpt-image-2 --prompt "..." --refs generations/refs/logo.png --resolution 2K --out generations/
```

## Response handling

Sync — finished image comes back in one call, no polling.

## Notes

- This is the advanced/quality tier — quote cost before running if it's not obviously a draft iteration.
- Pass real reference files for any logo/brand text, never describe it.
