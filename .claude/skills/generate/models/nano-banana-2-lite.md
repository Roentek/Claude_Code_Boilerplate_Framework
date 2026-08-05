# Nano Banana 2 Lite

Cheap tier default for images. Fast, strong with reference images. Use for everyday drafts and iteration.

| Field | Value |
| --- | --- |
| Model ID | `gemini-3.1-flash-lite-image` (full quality: `gemini-3.1-flash-image-preview`) |
| Provider | Kie AI (primary) — also on Google AI Studio direct, fal.ai (future fallback) |
| Method | Sync (instant reply) |
| Type | Image |
| API key | `.env` / `settings.local.json` → `KIE_AI_API_KEY` |
| Cost | ~$0.034 per 1K image |

## Call

Prefer `kie-cli` (Bash, zero token overhead). Fall back to `kie-ai` MCP tool `nano_banana_image` if the CLI can't reach this model.

```bash
kie-cli generate --model nano-banana-2-lite --prompt "..." --refs generations/refs/logo.png --out generations/
```

If CLI flags differ, check `kie-cli --help` first — don't guess syntax.

## Response handling

Kie AI returns the finished image URL (or base64) in one call — no polling. Download and save flat into `generations/`.

## Notes

- Never describe a reference image in words — pass the real file path.
- If Kie AI doesn't have this model wired, stop and ask before trying another provider (fal.ai/WaveSpeed are documented but not yet keyed in this project).
